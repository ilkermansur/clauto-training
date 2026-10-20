import { C, text, arrow, box, diamond, save } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;
const e = [];
// panel A: for
e.push(text(130, 0, 'for: once per item', { size: 20, stroke: C.green, align: 'center' }));
['"SEP…5F"', '"SEP…60"', '"CSF…"'].forEach((v, i) => e.push(box(i * 88, 40, 88, 44, v, { fill: C.fillLime, size: 16 })));
e.push(box(70, 140, 124, 48, 'body', { fill: C.fillGreen, size: 20 }));
e.push(arrow([[44, 90], [60, 120], [92, 136]], { round: true }));
e.push(arrow([[132, 90], [132, 134]]));
e.push(arrow([[220, 90], [204, 120], [172, 136]], { round: true }));
e.push(text(132, 200, 'runs 3 times: the collection\ndecides how often', { size: 16, stroke: C.gray, align: 'center' }));
// panel B: while
const X = 340;
e.push(text(X + 140, 0, 'while: until a condition', { size: 20, stroke: C.blue, align: 'center' }));
e.push(diamond(X + 60, 36, 160, 84, { fill: C.fillBlue }));
e.push(text(X + 140, 78, 'still\nTrue?', { size: 18, align: 'center', middle: true }));
e.push(box(X + 78, 150, 124, 44, 'body', { fill: C.fillGreen, size: 20 }));
e.push(arrow([[X + 140, 124], [X + 140, 146]])); e.push(text(X + 148, 124, 'yes', { size: 15, stroke: C.green }));
e.push(arrow([[X + 74, 172], [X + 30, 172], [X + 30, 90], [X + 74, 82]], { round: true, stroke: C.green }));
e.push(arrow([[X + 224, 78], [X + 290, 78]], { stroke: C.red })); e.push(text(X + 232, 52, 'no: stop', { size: 15, stroke: C.red }));
e.push(text(X + 140, 206, 'runs until the answer\nchanges: count unknown', { size: 16, stroke: C.gray, align: 'center' }));
save(D + 'loop-kinds.excalidraw', e);
