import { C, text, rect, arrow, box, diamond, save } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;
const RED = '#ffc9c9', PINK = '#c2255c';
// exception flow
{
  const e = [];
  e.push(box(0, 62, 170, 64, 'phone["css"]\nraises KeyError', { fill: RED, size: 18 }));
  e.push(arrow([[176, 94], [232, 94]]));
  e.push(diamond(238, 44, 180, 100, { fill: C.fillBlue }));
  e.push(text(328, 94, 'matching\nexcept?', { size: 18, align: 'center', middle: true }));
  e.push(arrow([[328, 40], [328, 18], [470, 18]], { stroke: C.green })); e.push(text(340, -8, 'yes', { size: 17, stroke: C.green }));
  e.push(box(476, -6, 200, 50, 'handler runs,\nscript goes on', { fill: C.fillGreen, size: 17 }));
  e.push(arrow([[328, 148], [328, 170], [470, 170]], { stroke: C.red })); e.push(text(340, 150, 'no', { size: 17, stroke: C.red }));
  e.push(box(476, 146, 200, 50, 'script stops,\ntraceback printed', { fill: RED, size: 17 }));
  save(D + 'exception-flow.excalidraw', e);
}
// try flow
{
  const e = [];
  e.push(box(0, 80, 120, 50, 'try:', { fill: C.fillBlue, size: 20 }));
  e.push(arrow([[126, 105], [176, 105]]));
  e.push(diamond(182, 60, 130, 90, { fill: '#e9ecef' }));
  e.push(text(247, 105, 'error?', { size: 18, align: 'center', middle: true }));
  e.push(arrow([[247, 56], [247, 26], [356, 26]], { stroke: C.red })); e.push(text(258, 2, 'yes', { size: 16, stroke: C.red }));
  e.push(box(362, 2, 130, 48, 'except:', { fill: RED, size: 20 }));
  e.push(arrow([[247, 154], [247, 184], [356, 184]], { stroke: C.green })); e.push(text(258, 160, 'no', { size: 16, stroke: C.green }));
  e.push(box(362, 160, 130, 48, 'else:', { fill: C.fillGreen, size: 20 }));
  e.push(arrow([[498, 26], [560, 26], [560, 74]])); e.push(arrow([[498, 184], [560, 184], [560, 136]]));
  e.push(box(500, 80, 130, 50, 'finally:', { fill: C.fillYellow, size: 20 }));
  e.push(text(565, 222, 'always runs', { size: 16, stroke: C.gray, align: 'center' }));
  save(D + 'try-flow.excalidraw', e);
}
// bulk errors
{
  const e = [];
  const items = [['SEP…5F', 'added', C.green, C.fillLime], ['SEP…60', 'failed', C.red, RED], ['SEP…61', 'added', C.green, C.fillLime]];
  items.forEach(([n, s, c, f], i) => {
    const x = i * 150;
    e.push(box(x, 30, 120, 46, n, { fill: f, round: true, size: 18 }));
    e.push(text(x + 60, 86, s, { size: 17, stroke: c, align: 'center' }));
    if (i < 2) e.push(arrow([[x + 124, 53], [x + 146, 53]], { stroke: C.gray }));
  });
  e.push(text(210, 0, 'for name in phones:', { size: 18, stroke: PINK, align: 'center' }));
  e.push(arrow([[210, 112], [210, 150]], { stroke: C.red }));
  e.push(box(80, 156, 300, 48, 'failed = [("SEP…60", "duplicate")]', { fill: '#fff5f5', round: true, size: 16, stroke: C.red }));
  e.push(text(460, 180, 'loop goes on,\nreport at the end', { size: 16, stroke: C.gray, middle: true }));
  save(D + 'bulk-errors.excalidraw', e);
}
