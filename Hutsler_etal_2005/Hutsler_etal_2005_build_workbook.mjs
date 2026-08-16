import fs from "node:fs/promises";
import path from "node:path";
import { SpreadsheetFile, Workbook } from "@oai/artifact-tool";

const folder = path.dirname(new URL(import.meta.url).pathname);
const outputDir = path.join(folder, "outputs", "01a00701-b6a8-7343-9e6c-abf25a22eb95");
await fs.mkdir(outputDir, { recursive: true });
const previewDir = "/tmp/hutsler_workbook_previews";
await fs.mkdir(previewDir, { recursive: true });

const speciesCsv = await fs.readFile(path.join(folder, "Hutsler_etal_2005_Table1.csv"), "utf8");
const workbook = await Workbook.fromCSV(speciesCsv, { sheetName: "Species" });
const species = workbook.worksheets.getItem("Species");
const readme = workbook.worksheets.add("Read Me");

async function addCsvSheet(sheetName, fileName) {
  const csv = await fs.readFile(path.join(folder, fileName), "utf8");
  const imported = await Workbook.fromCSV(csv, { sheetName });
  const importedSheet = imported.worksheets.getItem(sheetName);
  const values = importedSheet.getUsedRange().values;
  const sheet = workbook.worksheets.add(sheetName);
  if (values.length && values[0]?.length) {
    sheet.getRangeByIndexes(0, 0, values.length, values[0].length).values = values;
  }
  return sheet;
}

const figure3 = await addCsvSheet("Figure3 S1", "Hutsler_etal_2005_Figure3.csv");
const figure6 = await addCsvSheet("Figure6 regional", "Hutsler_etal_2005_Figure6.csv");
const reported = await addCsvSheet("Reported values", "Hutsler_etal_2005_ReportedValues.csv");
const defTable1 = await addCsvSheet("Def Table1", "reference_tables/Hutsler_etal_2005_Table1_definitions.csv");
const defFigure3 = await addCsvSheet("Def Figure3", "reference_tables/Hutsler_etal_2005_Figure3_definitions.csv");
const defFigure6 = await addCsvSheet("Def Figure6", "reference_tables/Hutsler_etal_2005_Figure6_definitions.csv");
const defReported = await addCsvSheet("Def Reported", "reference_tables/Hutsler_etal_2005_ReportedValues_definitions.csv");
const qa = workbook.worksheets.add("QA");

const colors = {
  navy: "#17324D",
  teal: "#0F766E",
  paleTeal: "#DFF3EF",
  paleGold: "#FFF4CC",
  paleRed: "#FDE8E7",
  paleGreen: "#E4F4E8",
  white: "#FFFFFF",
  text: "#1F2937",
  border: "#CBD5E1",
};

function styleHeader(sheet, address) {
  const header = sheet.getRange(address);
  header.format = {
    fill: colors.teal,
    font: { bold: true, color: colors.white },
    wrapText: true,
    verticalAlignment: "center",
    borders: { preset: "outside", style: "thin", color: colors.border },
  };
  header.format.rowHeight = 32;
  sheet.freezePanes.freezeRows(1);
  sheet.showGridLines = false;
}

function widths(sheet, rowCount, specifications) {
  for (const [column, width] of specifications) {
    sheet.getRange(`${column}1:${column}${rowCount}`).format.columnWidth = width;
  }
}

styleHeader(species, "A1:J1");
widths(species, 15, [["A", 12], ["B", 20], ["C", 26], ["D", 25], ["E", 12], ["F", 44], ["G", 18], ["H", 18], ["I", 18], ["J", 29]]);
species.getRange("A2:J15").format = { font: { color: colors.text }, verticalAlignment: "top" };
species.getRange("F2:F15").format.wrapText = true;

styleHeader(figure3, "A1:P1");
widths(figure3, 15, [["A", 12], ["B", 20], ["C", 25], ["D", 25], ["E", 30], ["F", 17], ["G", 20], ["H", 20], ["I", 19], ["J", 19], ["K", 14], ["L", 18], ["M", 25], ["N", 48], ["O", 55], ["P", 30]]);
figure3.getRange("F2:H15").format.numberFormat = "#,##0";
figure3.getRange("I2:J15").format.numberFormat = "0.0%";
figure3.getRange("L2:L15").format.numberFormat = "0.0%";
figure3.getRange("N2:O15").format.wrapText = true;
figure3.getRange("A2:P15").format.verticalAlignment = "top";

styleHeader(figure6, "A1:P1");
widths(figure6, 10, [["A", 12], ["B", 12], ["C", 30], ["D", 34], ["E", 11], ["F", 18], ["G", 18], ["H", 15], ["I", 19], ["J", 19], ["K", 18], ["L", 25], ["M", 58], ["N", 30], ["O", 22], ["P", 24]]);
figure6.getRange("F2:F10").format.numberFormat = "#,##0";
figure6.getRange("G2:G10").format.numberFormat = "0.0%";
figure6.getRange("I2:I10").format.numberFormat = "0.0%";
figure6.getRange("K2:K10").format.numberFormat = "0.0%";
figure6.getRange("P2:P10").format.numberFormat = "0.0%";
figure6.getRange("M2:M10").format.wrapText = true;
figure6.getRange("A2:P10").format.verticalAlignment = "top";

styleHeader(reported, "A1:R1");
widths(reported, 45, [["A", 18], ["B", 38], ["C", 12], ["D", 36], ["E", 22], ["F", 13], ["G", 13], ["H", 12], ["I", 12], ["J", 13], ["K", 14], ["L", 14], ["M", 11], ["N", 28], ["O", 48], ["P", 30], ["Q", 55], ["R", 34]]);
reported.getRange("G2:G45").format.numberFormat = "0.000";
reported.getRange("J2:J45").format.numberFormat = "0.000";
reported.getRange("B2:B45").format.wrapText = true;
reported.getRange("N2:Q45").format.wrapText = true;
reported.getRange("A2:R45").format.verticalAlignment = "top";

for (const [sheet, rows] of [[defTable1, 11], [defFigure3, 18], [defFigure6, 18], [defReported, 19]]) {
  styleHeader(sheet, "A1:J1");
  widths(sheet, rows, [["A", 35], ["B", 48], ["C", 30], ["D", 22], ["E", 14], ["F", 12], ["G", 28], ["H", 34], ["I", 55], ["J", 30]]);
  sheet.getRange(`A2:J${rows}`).format = { wrapText: true, verticalAlignment: "top" };
}

readme.showGridLines = false;
readme.mergeCells("A1:H1");
readme.getRange("A1:H1").values = [["Hutsler et al. 2005 — Comparative cortical layering build"]];
readme.getRange("A1:H1").format = {
  fill: colors.navy,
  font: { bold: true, color: colors.white, size: 16 },
  horizontalAlignment: "left",
  verticalAlignment: "center",
};
readme.getRange("A1:H1").format.rowHeight = 34;
readme.getRange("A3:B10").values = [
  ["Citation", "Hutsler JJ, Lee DG, Porter KK (2005). Brain Research 1052:71–81."],
  ["DOI", "https://doi.org/10.1016/j.brainres.2005.06.015"],
  ["PMID", "16018988"],
  ["Species-level data", "Figure 3: primary somatosensory cortex only (14 species; digitized)."],
  ["M1 data", "Figure 6 and prose: order-level / pooled summaries only (13 species; mouse excluded)."],
  ["Primary caution", "Figure 3, Figure 6 and narrative group means are not numerically self-consistent."],
  ["Figure 6 caution", "Axes indicate A=absolute and B=proportional supragranular II/III; caption is internally inconsistent."],
  ["Merge status", "Local source build complete. Central registry/public TSV intentionally pending curatorial sign-off."],
];
readme.getRange("A3:A10").format = { fill: colors.paleTeal, font: { bold: true, color: colors.navy }, verticalAlignment: "top" };
readme.getRange("B3:B10").format = { wrapText: true, verticalAlignment: "top", font: { color: colors.text } };
readme.getRange("A3:B10").format.borders = { preset: "inside", style: "thin", color: colors.border };
readme.getRange("A3:A10").format.columnWidth = 24;
readme.getRange("B3:B10").format.columnWidth = 95;
readme.getRange("A12:H12").merge();
readme.getRange("A12:H12").values = [["Workbook guide"]];
readme.getRange("A12:H12").format = { fill: colors.teal, font: { bold: true, color: colors.white } };
readme.getRange("A13:B18").values = [
  ["Species", "Exact Table 1 metadata and analysis-availability flags."],
  ["Figure3 S1", "Provisional species-level S1 digitization; keep separate from exact order summaries."],
  ["Figure6 regional", "Order × region digitization, including the only M1 layer-II/III bars."],
  ["Reported values", "Exact prose values with conflicts retained and standardized units."],
  ["Def ...", "Machine-readable data dictionaries for each item."],
  ["QA", "Formula-driven row checks and Figure 3 vs narrative reconciliation."],
];
readme.getRange("A13:A18").format = { font: { bold: true, color: colors.navy } };
readme.getRange("B13:B18").format = { wrapText: true };

qa.showGridLines = false;
qa.mergeCells("A1:J1");
qa.getRange("A1:J1").values = [["Build QA and source reconciliation"]];
qa.getRange("A1:J1").format = { fill: colors.navy, font: { bold: true, color: colors.white, size: 15 } };
qa.getRange("A3:D3").values = [["Row-count check", "Result", "Expected", "Status"]];
qa.getRange("A3:D3").format = { fill: colors.teal, font: { bold: true, color: colors.white } };
qa.getRange("A4:A7").values = [["Species"], ["Figure3 S1"], ["Figure6 regional"], ["Reported values"]];
qa.getRange("B4:B7").formulas = [
  ["=COUNTA('Species'!A2:A15)"],
  ["=COUNTA('Figure3 S1'!A2:A15)"],
  ["=COUNTA('Figure6 regional'!A2:A10)"],
  ["=COUNTA('Reported values'!A2:A45)"],
];
qa.getRange("C4:C7").values = [[14], [14], [9], [44]];
qa.getRange("D4").formulas = [["=IF(B4=C4,\"OK\",\"CHECK\")"]];
qa.getRange("D4:D7").fillDown();
qa.getRange("D4:D7").conditionalFormats.add("containsText", { text: "OK", format: { fill: colors.paleGreen, font: { color: "#166534", bold: true } } });
qa.getRange("D4:D7").conditionalFormats.add("containsText", { text: "CHECK", format: { fill: colors.paleRed, font: { color: "#991B1B", bold: true } } });
qa.getRange("A3:D7").format.borders = { preset: "all", style: "thin", color: colors.border };

qa.getRange("A9:J9").values = [["Order", "Fig3 supra µm", "Reported supra µm", "Difference µm", "Fig3 supra proportion", "Reported proportion", "Difference", "M1 Fig6 supra µm", "M1 Fig6 proportion", "Interpretation"]];
qa.getRange("A9:J9").format = { fill: colors.teal, font: { bold: true, color: colors.white }, wrapText: true };
qa.getRange("A10:A12").values = [["Primate"], ["Carnivore"], ["Rodent"]];
qa.getRange("B10:B12").formulas = [
  ["=AVERAGEIF('Figure3 S1'!$A$2:$A$15,$A10,'Figure3 S1'!$G$2:$G$15)"],
  ["=AVERAGEIF('Figure3 S1'!$A$2:$A$15,$A11,'Figure3 S1'!$G$2:$G$15)"],
  ["=AVERAGEIF('Figure3 S1'!$A$2:$A$15,$A12,'Figure3 S1'!$G$2:$G$15)"],
];
qa.getRange("C10:C12").formulas = [["='Reported values'!G4"], ["='Reported values'!G5"], ["='Reported values'!G6"]];
qa.getRange("D10").formulas = [["=B10-C10"]];
qa.getRange("D10:D12").fillDown();
qa.getRange("E10:E12").formulas = [
  ["=AVERAGEIF('Figure3 S1'!$A$2:$A$15,$A10,'Figure3 S1'!$I$2:$I$15)"],
  ["=AVERAGEIF('Figure3 S1'!$A$2:$A$15,$A11,'Figure3 S1'!$I$2:$I$15)"],
  ["=AVERAGEIF('Figure3 S1'!$A$2:$A$15,$A12,'Figure3 S1'!$I$2:$I$15)"],
];
qa.getRange("F10:F12").formulas = [["='Reported values'!G10"], ["='Reported values'!G11"], ["='Reported values'!G12"]];
qa.getRange("G10").formulas = [["=E10-F10"]];
qa.getRange("G10:G12").fillDown();
qa.getRange("H10:H12").formulas = [["='Figure6 regional'!F2"], ["='Figure6 regional'!F5"], ["='Figure6 regional'!F8"]];
qa.getRange("I10:I12").formulas = [["='Figure6 regional'!G2"], ["='Figure6 regional'!G5"], ["='Figure6 regional'!G8"]];
qa.getRange("J10:J12").values = [
  ["Figure 3 species bars conflict with narrative means; M1 is order-level only."],
  ["Figure 3 species bars conflict with narrative means; M1 is order-level only."],
  ["Figure 3 species bars conflict with narrative means; M1 is order-level only."],
];
qa.getRange("B10:D12").format.numberFormat = "#,##0.0";
qa.getRange("E10:G12").format.numberFormat = "0.0%";
qa.getRange("H10:H12").format.numberFormat = "#,##0";
qa.getRange("I10:I12").format.numberFormat = "0.0%";
qa.getRange("D10:D12").format.fill = colors.paleGold;
qa.getRange("G10:G12").format.fill = colors.paleGold;
qa.getRange("J10:J12").format.wrapText = true;
qa.getRange("A9:J12").format.borders = { preset: "all", style: "thin", color: colors.border };
qa.getRange("B4:C7").format.horizontalAlignment = "right";
qa.getRange("B10:I12").format.horizontalAlignment = "right";
widths(qa, 12, [["A", 20], ["B", 20], ["C", 22], ["D", 18], ["E", 22], ["F", 20], ["G", 17], ["H", 21], ["I", 22], ["J", 56]]);
qa.freezePanes.freezeRows(1);

const sheetsToRender = [readme, species, figure3, figure6, reported, defTable1, defFigure3, defFigure6, defReported, qa];
for (const sheet of sheetsToRender) {
  const used = sheet.getUsedRange();
  used.format.autofitRows();
  const preview = await workbook.render({ sheetName: sheet.name, autoCrop: "all", scale: 1, format: "png" });
  const safeName = sheet.name.replaceAll(" ", "_");
  await fs.writeFile(path.join(previewDir, `${safeName}.png`), new Uint8Array(await preview.arrayBuffer()));
}

const inspect = await workbook.inspect({
  kind: "table",
  sheetId: "QA",
  range: "A1:J12",
  include: "values,formulas",
  tableMaxRows: 12,
  tableMaxCols: 10,
  maxChars: 9000,
});
console.log(inspect.ndjson);

const errors = await workbook.inspect({
  kind: "match",
  searchTerm: "#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A",
  options: { useRegex: true, maxResults: 100 },
  summary: "final formula error scan",
  maxChars: 4000,
});
console.log(errors.ndjson);

const output = await SpreadsheetFile.exportXlsx(workbook);
const outputPath = path.join(outputDir, "Hutsler_etal_2005_build.xlsx");
await output.save(outputPath);
console.log(`Wrote ${outputPath}`);
