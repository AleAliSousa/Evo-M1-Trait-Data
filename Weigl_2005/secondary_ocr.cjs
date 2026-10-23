// Independent OCR of the printed data pages for comparison with the PDF text layer.
// Requires tesseract.js, pdftoppm, and an official eng.traineddata model in LANG_DIR.
const { createWorker } = require('tesseract.js');
const { execFileSync } = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');

const root = __dirname;
const pdf = path.join(root, 'Weigl_2005_LongevityOfMammalsInCaptivity_pp21-210.pdf');
const out = process.env.OCR_OUT_DIR || '/tmp/weigl-secondary-ocr';
const langPath = process.env.LANG_DIR;
const pdftoppm = process.env.PDFTOPPM || 'pdftoppm';
const firstPage = Number(process.env.FIRST_PAGE || 2);
const lastPage = Number(process.env.LAST_PAGE || 180);
if (!langPath) throw new Error('Set LANG_DIR to a directory containing eng.traineddata');
fs.mkdirSync(out, { recursive: true });

(async () => {
  const worker = await createWorker('eng', 1, { langPath, gzip: false, cacheMethod: 'none' });
  try {
    for (let page = firstPage; page <= lastPage; page++) {
      const stem = path.join(out, `page-${String(page).padStart(3, '0')}`);
      const tsv = `${stem}.tsv`;
      if (fs.existsSync(tsv)) continue;
      execFileSync(pdftoppm, ['-f', String(page), '-l', String(page), '-singlefile', '-r', '180', '-png', pdf, stem]);
      const image = `${stem}.png`;
      const result = await worker.recognize(image, {}, { tsv: true });
      fs.writeFileSync(tsv, result.data.tsv);
      fs.writeFileSync(`${stem}.txt`, result.data.text);
      fs.unlinkSync(image);
      if (page % 10 === 0 || page === 180) console.log(`OCR complete through PDF page ${page}`);
    }
  } finally {
    await worker.terminate();
  }
})().catch((error) => { console.error(error); process.exitCode = 1; });
