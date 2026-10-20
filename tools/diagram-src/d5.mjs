import { C, text, arrow, box, save } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;
const cats = [
  ['Numeric', C.fillBlue,   [['int', 'whole numbers'], ['float', 'decimal numbers']]],
  ['Text',    C.fillYellow, [['str', 'text, characters']]],
  ['Boolean', C.fillGreen,  [['bool', 'True / False']]],
  ['Sequence',C.fillLime,   [['list', 'ordered, changeable'], ['tuple', 'ordered, fixed'], ['range', 'number sequence']]],
  ['Mapping', C.fillYellow, [['dict', 'key : value pairs']]],
  ['Set',     C.fillBlue,   [['set', 'unique, unordered']]],
  ['Binary',  '#e9ecef',    [['bytes', 'raw binary data'], ['bytearray', 'changeable bytes']]],
  ['None',    '#ffc9c9',    [['NoneType', 'no value']]],
];
const els = [];
const ROW = 34, GAP = 12, CX = 180, CW = 130, CH = 40, LX = 370;
let y = 0; const catY = [];
for (const [name, fill, leaves] of cats) {
  const h = leaves.length * ROW;
  const cy = y + h / 2;
  catY.push(cy);
  els.push(box(CX, cy - CH / 2, CW, CH, name, { fill, round: true, size: 20 }));
  leaves.forEach(([t, d], i) => {
    const ly = y + i * ROW + ROW / 2;
    els.push(arrow([[CX + CW + 4, cy], [LX - 8, ly]], { line: true, sw: 1, rough: 0.6 }));
    els.push(text(LX, ly, t, { size: 21, middle: true }));
    els.push(text(LX + 128, ly, d, { size: 17, middle: true, stroke: C.gray }));
  });
  y += h + GAP;
}
const total = y - GAP, ry = total / 2;
els.push(box(0, ry - 32, 120, 64, 'data\ntypes', { fill: C.fillLime, round: true, size: 22, sw: 2 }));
for (const cy of catY) els.push(arrow([[124, ry], [CX - 6, cy]], { line: true, sw: 1.5, rough: 0.6 }));
save(D + 'data-types-map.excalidraw', els);
