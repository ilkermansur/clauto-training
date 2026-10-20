import { C, text, rect, arrow, box, save, measure } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;
const e = [];
// function side
e.push(text(120, 0, 'function', { size: 21, stroke: '#c2255c', align: 'center' }));
e.push(box(0, 50, 100, 46, 'name', { fill: C.fillYellow, round: true, size: 19 }));
e.push(arrow([[106, 73], [156, 73]]));
e.push(box(162, 40, 90, 66, 'len( )', { fill: C.fillBlue, size: 22 }));
e.push(text(120, 124, 'stands alone,\nobject goes in', { size: 16, stroke: C.gray, align: 'center' }));
// method side
const X = 330;
e.push(text(X + 130, 0, 'method', { size: 21, stroke: '#c2255c', align: 'center' }));
e.push(rect(X, 36, 260, 96, { fill: C.fillYellow, round: true }));
e.push(text(X + 14, 58, 'name  (str)', { size: 19, middle: true }));
['.upper()', '.strip()', '.split()'].forEach((m, i) => e.push(box(X + 12 + i * 82, 82, 76, 36, m, { fill: C.fillBlue, size: 15 })));
e.push(text(X + 130, 150, 'lives on the object,\ncalled with a dot', { size: 16, stroke: C.gray, align: 'center' }));
save(D + 'function-vs-method.excalidraw', e);
