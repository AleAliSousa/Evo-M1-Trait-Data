const artifactModule = process.env.ARTIFACT_TOOL_MODULE || "@oai/artifact-tool";
const { SpreadsheetFile, Workbook } = await import(artifactModule);

const output = new URL("./Corticospinal_terminations_snapshot.xlsx", import.meta.url).pathname;
const wb = Workbook.create();
const ws = wb.worksheets.add("Table1");
ws.showGridLines = false;
ws.freezePanes.freezeRows(1);

const rows = [
  [
    "Species_printed", "species_sci", "CST_termination_grade", "CM_monosynaptic",
    "CM_connection_inference", "Segment_summary", "Method", "Source", "DOI",
    "Source_location", "Evidence_summary", "Curatorial_note"
  ],
  [
    "Cebus apella", "Sapajus apella", 2, null, "likely",
    "C8-T1: dense/extensive lamina IX and ventral-horn terminations",
    "WGA-HRP anterograde tract tracing from primary motor cortex",
    "Bortoff & Strick 1993", "10.1523/JNEUROSCI.13-12-05105.1993",
    "Abstract; Results pp. 5108-5111; Figures 3, 5-11",
    "Three termination zones; the ventral-horn projection is dense and extensively overlaps lamina IX at C8-T1.",
    "Anatomical terminal fields support, but do not prove, a monosynaptic CM connection."
  ],
  [
    "Saimiri sciureus", "Saimiri sciureus", 1, null, "against",
    "C8-T1: sparse at best; termination mainly in two intermediate-zone regions",
    "WGA-HRP anterograde tract tracing from primary motor cortex",
    "Bortoff & Strick 1993", "10.1523/JNEUROSCI.13-12-05105.1993",
    "Abstract; Results pp. 5109-5111; Figures 4, 6, 10-11",
    "Two main intermediate-zone termination fields; lamina IX labeling is absent or sparse and highly restricted.",
    "The paper argues against a CM connection but notes that light microscopy cannot establish monosynaptic absence."
  ]
];

ws.getRange("A1:L3").values = rows;
ws.getRange("A1:L1").format = {
  fill: "#1F4E78",
  font: { bold: true, color: "#FFFFFF" },
  wrapText: true,
  verticalAlignment: "center",
  borders: { preset: "all", style: "thin", color: "#B4C6E7" }
};
ws.getRange("A2:L3").format = {
  fill: "#F7FAFC",
  wrapText: true,
  verticalAlignment: "top",
  borders: { preset: "all", style: "thin", color: "#D9E2F3" }
};
ws.getRange("C2:D3").format.horizontalAlignment = "center";
ws.getRange("A1:L3").format.autofitRows();
const widths = [18, 18, 18, 18, 20, 34, 34, 24, 34, 42, 58, 58];
for (let i = 0; i < widths.length; i++) ws.getRangeByIndexes(0, i, 3, 1).format.columnWidth = widths[i];
ws.getRange("A1:L1").format.rowHeight = 36;

const xlsx = await SpreadsheetFile.exportXlsx(wb);
await xlsx.save(output);
