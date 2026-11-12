#!/usr/bin/env python3
"""Run the existing R sweep followed by four allowlisted Python checks.

Usage from the Evo-M1-Trait-Data root:
    python3 run_all_scripts_v3.py
    python3 run_all_scripts_v3.py --python-only
    python3 run_all_scripts_v3.py --dry-run

The R sweep may rebuild project data. Python checks are limited to the local
folder audit, naming check, taxon-clarity check, and source-statement verifier.
The taxon check uses the existing observed CSV; regenerating it with
_keys/build_taxon_clarity_observed.py is a separate, opt-in build step.
Other builders/extractors, EndNote-DB checks (gap_scan.py, score_gaps.py,
inspect_tables.py), and the online find_paper_pdfs.py tool are excluded.
Dry-run starts no processes and writes no files. Actual runs write a separate
combined report and console log under _checks; the R sweep still writes its own logs.
"""

import argparse
import csv
import importlib.util
import os
import re
import shlex
import shutil
import signal
import subprocess
import sys
import time
from collections import Counter, deque
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Tuple


ROOT = Path(__file__).resolve().parent
R_RUNNER = "run_all_scripts_v2.R"
R_LOG = Path("_checks/script_execution_log.csv")
REPORT = Path("_checks/run_all_scripts_v3_report.csv")
OUTPUT_LOG = Path("_checks/run_all_scripts_v3_output.log")
FAILURE_STATUSES = {"FAILED", "TIMEOUT", "INTERRUPTED"}
FIELDS = ("phase", "script", "command", "status", "started_at", "ended_at",
          "elapsed_seconds", "exit_code", "detail")


@dataclass(frozen=True)
class Check:
    path: str
    inputs: Tuple[str, ...] = ()
    needs_pdfium: bool = False


PYTHON_CHECKS = (
    Check("_tools/audit_folders.py", ("__ReadMe.xlsx",)),
    Check("_tools/check_naming.py", ("__ReadMe.xlsx",)),
    Check("_checks/check_taxon_clarity.py",
          ("_keys/taxon_clarity.csv", "_keys/taxon_clarity_observed.csv")),
    Check("_keys/verify_source_statements.py",
          ("_keys/build_brain_size_basis.py",), needs_pdfium=True),
)


def timestamp():
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def command_text(command):
    return " ".join(shlex.quote(str(part)) for part in command)


def row(phase, script, status, command="", started_at="", ended_at="",
        elapsed_seconds="", exit_code="", detail=""):
    return dict(phase=phase, script=script, command=command, status=status,
                started_at=started_at, ended_at=ended_at,
                elapsed_seconds=elapsed_seconds, exit_code=exit_code,
                detail=detail)


def check_preflight(root, check):
    if not (root / check.path).is_file():
        return "FAILED", "allowlisted check is missing"
    missing = [name for name in check.inputs if not (root / name).is_file()]
    if missing:
        note = "missing input: " + ", ".join(missing)
        if "_keys/taxon_clarity_observed.csv" in missing:
            note += "; refresh the observed snapshot separately if needed"
        return "SKIPPED", note
    if check.needs_pdfium and importlib.util.find_spec("pypdfium2") is None:
        return "SKIPPED", "optional pypdfium2 is not installed; install it to verify source PDFs"
    return None, ""


def stop_process(proc):
    if proc.poll() is not None:
        return
    try:
        if os.name == "posix":
            os.killpg(proc.pid, signal.SIGTERM)
        else:
            proc.terminate()
    except ProcessLookupError:
        pass
    try:
        proc.wait(timeout=5)
    except subprocess.TimeoutExpired:
        try:
            if os.name == "posix":
                os.killpg(proc.pid, signal.SIGKILL)
            else:
                proc.kill()
        except ProcessLookupError:
            pass
        proc.wait()


def output_summary(path, offset, source_verifier):
    """Read a short output tail; only the PDF verifier needs a full scan."""
    tail = deque(maxlen=4)
    pdf_skips = 0
    checked = None
    with path.open("rb") as fh:
        if source_verifier:
            fh.seek(offset)
            lines = fh
        else:
            end = fh.seek(0, os.SEEK_END)
            fh.seek(max(offset, end - 16384))
            lines = fh
        for raw in lines:
            line = raw.decode("utf-8", errors="replace").strip()
            if not line:
                continue
            tail.append(line[:400])
            if source_verifier:
                if re.search(r"\bSKIP\b.*no PDF in folder", line):
                    pdf_skips += 1
                match = re.match(r"(\d+) statements checked, \d+ failed", line)
                if match:
                    checked = int(match.group(1))
    return list(tail), pdf_skips, checked


def run_command(phase, script, command, root, timeout, output, env=None,
                source_verifier=False):
    started = timestamp()
    started_clock = time.monotonic()
    output.write(("\n=== {}: {} ===\n$ {}\n".format(
        phase, script, command_text(command))).encode("utf-8"))
    output.flush()
    offset = output.tell()
    status = "FAILED"
    detail = ""
    exit_code = ""
    proc = None
    try:
        proc = subprocess.Popen(command, cwd=str(root), env=env, stdout=output,
                                stderr=subprocess.STDOUT,
                                start_new_session=(os.name == "posix"))
        try:
            exit_code = proc.wait(timeout=timeout)
            status = "SUCCESS" if exit_code == 0 else "FAILED"
            if status == "FAILED":
                detail = "exit code {}".format(exit_code)
        except subprocess.TimeoutExpired:
            stop_process(proc)
            exit_code = proc.returncode
            status = "TIMEOUT"
            detail = "timed out after {} seconds".format(timeout)
    except KeyboardInterrupt:
        if proc is not None:
            stop_process(proc)
            exit_code = proc.returncode
        status = "INTERRUPTED"
        detail = "interrupted by user"
    except OSError as exc:
        detail = "could not start: {}".format(exc)
    output.flush()
    tail, pdf_skips, checked = output_summary(Path(output.name), offset, source_verifier)
    if status == "FAILED" and tail:
        detail += "; last output: " + tail[-1]
    if status == "SUCCESS" and source_verifier and pdf_skips:
        status = "SKIPPED" if checked == 0 else "PARTIAL"
        detail = "{} source statement(s) skipped: paper PDF missing".format(pdf_skips)
        if checked == 0:
            detail = "no statements checked; " + detail
    return row(phase, script, status, command_text(command), started, timestamp(),
               "{:.2f}".format(time.monotonic() - started_clock), exit_code, detail)


def file_signature(path):
    try:
        st = path.stat()
    except FileNotFoundError:
        return None
    return st.st_mtime_ns, st.st_ctime_ns, st.st_size, st.st_ino


def read_r_log(path):
    with path.open(newline="", encoding="utf-8-sig") as fh:
        reader = csv.DictReader(fh)
        if not reader.fieldnames or not {"script", "status", "error"}.issubset(reader.fieldnames):
            raise ValueError("R execution log has no script/status/error columns")
        entries = []
        for item in reader:
            raw_status = (item.get("status") or "").strip().upper()
            status = raw_status if raw_status in {"SUCCESS", "SKIPPED", "FAILED"} else "FAILED"
            detail = (item.get("error") or "").strip()
            if raw_status not in {"SUCCESS", "SKIPPED", "FAILED"}:
                detail = "unknown R status {!r}; {}".format(raw_status, detail)
            entries.append(row("R script", (item.get("script") or "(unnamed)").strip(),
                               status, started_at=item.get("start_time") or "",
                               ended_at=item.get("end_time") or "",
                               elapsed_seconds=item.get("elapsed_seconds") or "",
                               detail=detail))
    if not entries:
        raise ValueError("R execution log has no script rows")
    return entries


def run_r(root, timeout, output):
    command = ("Rscript", R_RUNNER)
    if not (root / R_RUNNER).is_file():
        return [row("R runner", R_RUNNER, "FAILED", command_text(command),
                    detail="existing R runner is missing")]
    if shutil.which("Rscript") is None:
        return [row("R runner", R_RUNNER, "FAILED", command_text(command),
                    detail="Rscript is not on PATH")]
    log_path = root / R_LOG
    before = file_signature(log_path)
    summary = run_command("R runner", R_RUNNER, command, root, timeout, output)
    if summary["status"] in {"TIMEOUT", "INTERRUPTED"}:
        return [summary]
    after = file_signature(log_path)
    if after is None or after == before:
        summary["status"] = "FAILED"
        summary["detail"] = (summary["detail"] + "; " if summary["detail"] else "") + \
            "R execution log was not freshly written; old results were not used"
        return [summary]
    try:
        scripts = read_r_log(log_path)
    except (OSError, UnicodeError, csv.Error, ValueError) as exc:
        summary["status"] = "FAILED"
        summary["detail"] = (summary["detail"] + "; " if summary["detail"] else "") + \
            "cannot read this run's R log: {}".format(exc)
        return [summary]
    counts = Counter(item["status"] for item in scripts)
    if counts["FAILED"]:
        summary["status"] = "FAILED"
    tally = "{} R scripts: {} passed, {} skipped, {} failed".format(
        len(scripts), counts["SUCCESS"], counts["SKIPPED"], counts["FAILED"])
    summary["detail"] = (summary["detail"] + "; " if summary["detail"] else "") + tally
    return [summary] + scripts


def positive_seconds(value):
    try:
        seconds = int(value)
    except ValueError as exc:
        raise argparse.ArgumentTypeError("must be a positive number of seconds") from exc
    if seconds < 1:
        raise argparse.ArgumentTypeError("must be a positive number of seconds")
    return seconds


def parse_args(argv=None):
    parser = argparse.ArgumentParser(
        description="Run the R sweep and four safe, local Python checks (or Python only).",
        epilog="Builders, machine-specific EndNote checks and the online PDF finder are not included. "
               "The taxon check uses the existing observed snapshot; refresh it separately if needed.")
    parser.add_argument("--python-only", action="store_true",
                        help="run only the four Python checks; do not inspect an older R log")
    parser.add_argument("--dry-run", action="store_true",
                        help="show the planned commands and skips; run nothing and write nothing")
    parser.add_argument("--r-timeout", type=positive_seconds, default=43200,
                        metavar="SECONDS", help="R sweep time limit (default: 43200)")
    parser.add_argument("--python-timeout", type=positive_seconds, default=3600,
                        metavar="SECONDS", help="time limit for each Python check (default: 3600)")
    return parser.parse_args(argv)


def dry_run(args, root):
    print("DRY RUN: no processes launched and no project files written.")
    if not args.python_only:
        print("R runner (limit {}s): {}".format(
            args.r_timeout, command_text(("Rscript", R_RUNNER))))
        if not (root / R_RUNNER).is_file():
            print("  WARNING: existing R runner is missing")
        elif shutil.which("Rscript") is None:
            print("  WARNING: Rscript is not on PATH")
    for check in PYTHON_CHECKS:
        command = (sys.executable, check.path)
        status, detail = check_preflight(root, check)
        print("Python check (limit {}s): {}".format(
            args.python_timeout, command_text(command)))
        if status:
            print("  {} if run now: {}".format(status, detail))
    print("On an actual run: report {} and console log {}".format(REPORT, OUTPUT_LOG))
    return 0


def write_report(path, rows):
    with path.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=FIELDS)
        writer.writeheader()
        writer.writerows(rows)


def actual_run(args, root):
    (root / "_checks").mkdir(parents=True, exist_ok=True)
    records = []
    interrupted = False
    with (root / OUTPUT_LOG).open("wb") as output:
        if not args.python_only:
            r_records = run_r(root, args.r_timeout, output)
            records.extend(r_records)
            print("R sweep: {} — {}".format(r_records[0]["status"],
                                         r_records[0]["detail"] or "completed"), flush=True)
            interrupted = r_records[0]["status"] == "INTERRUPTED"
        env = os.environ.copy()
        env["EVOM1_ROOT"] = str(root)
        env.pop("EVOM1_RESTRICTED", None)
        for check in PYTHON_CHECKS:
            if interrupted:
                result = row("Python check", check.path, "SKIPPED",
                             detail="not run after interruption")
            else:
                status, detail = check_preflight(root, check)
                command = (sys.executable, check.path)
                if status:
                    result = row("Python check", check.path, status,
                                 command_text(command), detail=detail)
                else:
                    result = run_command("Python check", check.path, command,
                                         root, args.python_timeout, output, env,
                                         source_verifier=check.needs_pdfium)
                if result["status"] == "INTERRUPTED":
                    interrupted = True
            records.append(result)
            print("{}: {}{}".format(check.path, result["status"],
                                   " — " + result["detail"] if result["detail"] else ""),
                  flush=True)
    write_report(root / REPORT, records)
    r_script_failed = any(item["phase"] == "R script" and
                          item["status"] in FAILURE_STATUSES for item in records)
    failures = [item for item in records if item["status"] in FAILURE_STATUSES
                and not (r_script_failed and item["phase"] == "R runner")]
    print("Combined report: {}; command output: {}".format(REPORT, OUTPUT_LOG))
    if failures:
        print("Failure summary ({}):".format(len(failures)))
        for item in failures[:8]:
            print("  {} {}: {}".format(item["phase"], item["script"], item["detail"]))
        if len(failures) > 8:
            print("  ... {} more; see the combined report".format(len(failures) - 8))
    return 130 if interrupted else (1 if failures else 0)


def main(argv=None):
    args = parse_args(argv)
    try:
        return dry_run(args, ROOT) if args.dry_run else actual_run(args, ROOT)
    except OSError as exc:
        print("Runner failed to write or read project files: {}".format(exc), file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        print("Runner interrupted.", file=sys.stderr)
        return 130


if __name__ == "__main__":
    sys.exit(main())
