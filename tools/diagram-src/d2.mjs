import { C, text, arrow, box, save } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;
const els = [];
const W = 180, H = 74;
const L = 0, R = 470, CX = 245, CY = 165;
els.push(box(CX, CY, 150, 70, '{ python }', { fill: C.fillYellow, round: true, size: 26 }));
const spokes = [
  [L, 0,   'CUCM\nAXL · SOAP', C.fillBlue],
  [R, 0,   'RISPort\nphone status', C.fillBlue],
  [L, 170, 'Excel / CSV\ninput', C.fillLime],
  [R, 170, 'Webex\nREST API', C.fillGreen],
  [L, 340, 'Unity\nCUPI · REST', C.fillBlue],
  [R, 340, 'CDR / CMR\nreports', C.fillLime],
];
for (const [x, y, label, fill] of spokes) {
  els.push(box(x, y, W, H, label, { fill, round: true, size: 20 }));
  const left = x === L;
  const sx = left ? CX - 4 : CX + 154, sy = CY + 35 + (y - 170) * 0.18;
  const ex = left ? L + W + 6 : R - 6, ey = y + H / 2;
  els.push(arrow([[sx, sy], [ex, ey]], { start: 'arrow', end: 'arrow' }));
}
els.push(text(CX + 75, CY + 92, 'one language,\nevery API', { size: 22, align: 'center', stroke: C.green }));
save(D + 'python-collab-hub.excalidraw', els);
