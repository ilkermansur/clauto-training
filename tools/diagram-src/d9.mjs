import { C, text, arrow, box, diamond, ellipse, save } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;
const dot = (x, y, lbl) => [ellipse(x, y, 46, 46, { fill: C.fillGray }), text(x + 23, y + 54, lbl, { size: 17, align: 'center' })];
function loopFlow(cond, body, kw, extra) {
  const e = [];
  e.push(dot(0, 94, 'Start'));
  e.push(arrow([[52, 117], [96, 117]]));
  e.push(diamond(100, 57, 190, 120, { fill: C.fillBlue }));
  e.push(text(195, 117, cond, { size: 18, align: 'center', middle: true }));
  e.push(text(120, 34, kw, { size: 22, stroke: '#c2255c' }));
  e.push(arrow([[195, 181], [195, 226]]));
  e.push(text(205, 190, 'True', { size: 17, stroke: C.green }));
  e.push(box(105, 232, 180, 62, body, { fill: C.fillGreen, size: 18 }));
  e.push(arrow([[101, 263], [50, 263], [50, 175], [128, 150]], { round: true, stroke: C.green }));
  e.push(text(4, 300, 'repeat', { size: 17, stroke: C.green }));
  e.push(arrow([[294, 117], [446, 117]]));
  e.push(text(310, 88, 'False', { size: 17, stroke: C.red }));
  e.push(dot(452, 94, 'End'));
  if (extra) extra(e);
  return e;
}
save(D + 'for-flow.excalidraw', loopFlow('items left\nin dns?', 'dn = next item\nrun the body', 'for', (e) => {
  ['"1001"', '"1002"', '"1003"'].forEach((v, i) => e.push(box(330 + i * 70, 236, 70, 40, v, { fill: C.fillLime, size: 16 })));
  e.push(text(435, 284, 'dns: one item per round', { size: 15, stroke: C.gray, align: 'center' }));
  e.push(arrow([[326, 256], [292, 260]], { style: 'dashed', stroke: C.gray }));
}));
save(D + 'while-flow.excalidraw', loopFlow('status !=\n"Registered"', 'ask RIS again\nattempts += 1', 'while', (e) => {
  e.push(text(330, 238, 'the body must change\nthe condition, or the\nloop never ends', { size: 16, stroke: C.red }));
}));
// break / continue
{
  const e = [];
  const items = [['"SEP0A1B2C3D4E5F"', 'check it', C.ink, C.fillLime], ['"CSFALICE"', 'continue: skip', C.gray, '#e9ecef'], ['"SEP0A1B2C3D4E60"', 'break: stop here', C.red, '#ffc9c9']];
  let x = 0;
  const W = [200, 140, 200];
  items.forEach(([v, l, c, f], i) => {
    e.push(box(x, 40, W[i], 48, v, { fill: f, round: true, size: 17 }));
    e.push(text(x + W[i] / 2, 100, l, { size: 17, stroke: c, align: 'center' }));
    if (i < 2) e.push(arrow([[x + W[i] / 2 + 20, 34], [x + W[i] + 40, 6], [x + W[i] + 30 + W[i + 1] / 2 - 10, 34]], { round: true, stroke: C.gray }));
    x += W[i] + 30;
  });
  e.push(arrow([[x - 30 - 100, 130], [x - 130, 170], [x + 20, 170]], { stroke: C.red }));
  e.push(text(x + 26, 170, 'exit loop', { size: 17, stroke: C.red, middle: true }));
  save(D + 'break-continue.excalidraw', e);
}
