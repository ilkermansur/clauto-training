import { C, text, rect, arrow, box, ellipse, save } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;

// 1. mutability
{
  const e = [];
  e.push(text(0, -78, 'str · immutable', { size: 20, stroke: C.gray }));
  e.push(box(0, 48, 60, 40, 'dn', { size: 20 }));
  e.push(box(110, 40, 130, 56, '"1001"', { fill: C.fillYellow, round: true, size: 24 }));
  e.push(arrow([[64, 68], [104, 68]], { stroke: C.gray, style: 'dashed' }));
  e.push(box(330, 40, 150, 56, '"10010"', { fill: C.fillYellow, round: true, size: 24 }));
  e.push(arrow([[30, 44], [215, -12], [400, 36]], { round: true }));
  e.push(text(215, -48, 'dn += "0"', { size: 18, stroke: C.green }));
  e.push(text(495, 56, 'new box,\nnew id', { size: 18, stroke: C.red }));
  e.push(text(0, 150, 'list · mutable', { size: 20, stroke: C.gray }));
  e.push(box(0, 198, 70, 40, 'lines', { size: 20 }));
  e.push(arrow([[74, 218], [104, 218]]));
  e.push(box(110, 190, 280, 56, '["1001", "1002"]', { fill: C.fillLime, round: true, size: 24 }));
  e.push(text(405, 198, 'same box,\nsame id', { size: 18, stroke: C.green }));
  e.push(text(250, 256, '.append("1002") changes the box itself', { size: 17, stroke: C.gray, align: 'center' }));
  save(D + 'mutability.excalidraw', e);
}
// 2. str index
{
  const e = [];
  const s = 'SEP0A1B2C3D4E5F', W = 36;
  [...s].forEach((ch, i) => {
    e.push(box(i * W, 34, W, 44, ch, { fill: i < 3 ? C.fillYellow : C.fillBlue, size: 22, rough: 0.8 }));
    e.push(text(i * W + W / 2, 84, String(i), { size: 15, stroke: C.gray, align: 'center' }));
  });
  e.push(arrow([[2, 24], [3 * W - 2, 24]], { line: true, stroke: C.green }));
  e.push(text(54, -4, 'name[:3]', { size: 18, stroke: C.green, align: 'center' }));
  e.push(arrow([[3 * W + 2, 24], [15 * W - 2, 24]], { line: true, stroke: C.blue }));
  e.push(text(9 * W, -4, 'name[3:]  =  MAC address', { size: 18, stroke: C.blue, align: 'center' }));
  save(D + 'str-index.excalidraw', e);
}
// 3. list index
{
  const e = [];
  ['"1001"', '"1002"', '"1003"'].forEach((v, i) => {
    e.push(box(i * 110, 34, 110, 50, v, { fill: C.fillLime, size: 22 }));
    e.push(text(i * 110 + 55, 4, String(i), { size: 18, stroke: C.green, align: 'center' }));
    e.push(text(i * 110 + 55, 92, String(i - 3), { size: 18, stroke: C.red, align: 'center' }));
  });
  e.push(box(360, 34, 110, 50, '"1004"', { style: 'dashed', stroke: C.gray, textColor: C.gray, size: 22 }));
  e.push(arrow([[415, 125], [415, 92]], { stroke: C.gray }));
  e.push(text(415, 130, '.append()', { size: 18, stroke: C.gray, align: 'center' }));
  e.push(text(-12, 4, 'index', { size: 15, stroke: C.green, align: 'right' }));
  e.push(text(-12, 92, 'from end', { size: 15, stroke: C.red, align: 'right' }));
  save(D + 'list-index.excalidraw', e);
}
// 4. range number line
{
  const e = [];
  const S = 48;
  e.push(arrow([[0, 50], [11 * S - 10, 50]], { line: true }));
  for (let i = 0; i <= 10; i++) {
    const x = i * S + 8;
    const last = i === 10;
    e.push(ellipse(x - 7, 43, 14, 14, last ? { stroke: C.red, sw: 2 } : { fill: C.green, fillStyle: 'solid', stroke: C.green }));
    e.push(text(x, 66, String(1001 + i), { size: 14, stroke: last ? C.red : C.ink, align: 'center' }));
  }
  e.push(text(8, 10, 'start', { size: 17, stroke: C.green, align: 'center' }));
  e.push(text(488, -22, 'stop\n(excluded)', { size: 17, stroke: C.red, align: 'center' }));
  e.push(text(248, 100, 'range(1001, 1011)  =  10 numbers', { size: 19, stroke: C.green, align: 'center' }));
  save(D + 'range-line.excalidraw', e);
}
// 5. dict map
{
  const e = [];
  e.push(text(70, 0, 'keys', { size: 18, stroke: C.gray, align: 'center' }));
  e.push(text(400, 0, 'values', { size: 18, stroke: C.gray, align: 'center' }));
  [['"name"', '"SEP0A1B2C3D4E5F"'], ['"model"', '"Cisco 8851"'], ['"devicePool"', '"DP_HQ"']].forEach(([k, v], i) => {
    const y = 32 + i * 58;
    e.push(box(0, y, 140, 44, k, { fill: C.fillYellow, round: true, size: 20 }));
    e.push(arrow([[146, y + 22], [214, y + 22]]));
    e.push(box(220, y, 260, 44, v, { fill: C.fillBlue, round: true, size: 20 }));
  });
  e.push(text(70, 212, 'unique,\nimmutable', { size: 16, stroke: C.red, align: 'center' }));
  e.push(text(350, 212, 'any type', { size: 16, stroke: C.green, align: 'center' }));
  save(D + 'dict-map.excalidraw', e);
}
// 6. set venn
{
  const e = [];
  e.push(ellipse(0, 34, 300, 170, { fill: C.fillBlue }));
  e.push(ellipse(150, 34, 300, 170, { fill: C.fillGreen }));
  e.push(text(110, 0, 'in CUCM', { size: 19, stroke: C.blue, align: 'center' }));
  e.push(text(340, 0, 'in template', { size: 19, stroke: C.green, align: 'center' }));
  e.push(text(90, 119, 'PT_Old', { size: 18, align: 'center', middle: true }));
  e.push(text(225, 119, 'PT_Internal\nPT_Local', { size: 17, align: 'center', middle: true }));
  e.push(text(375, 119, 'PT_Intl', { size: 18, align: 'center', middle: true }));
  e.push(text(90, 212, 'cucm - need', { size: 16, stroke: C.red, align: 'center' }));
  e.push(text(225, 212, 'cucm & need', { size: 16, stroke: C.gray, align: 'center' }));
  e.push(text(375, 212, 'need - cucm', { size: 16, stroke: C.red, align: 'center' }));
  save(D + 'set-venn.excalidraw', e);
}
