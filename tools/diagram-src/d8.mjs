import { C, text, arrow, box, diamond, ellipse, save } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;
const dot = (x, y, lbl) => [ellipse(x, y, 46, 46, { fill: C.fillGray }), text(x + 23, y + 54, lbl, { size: 17, align: 'center' })];
// if flow
{
  const e = [];
  e.push(dot(0, 112, 'Start'));
  e.push(arrow([[52, 135], [96, 135]]));
  e.push(diamond(100, 75, 190, 120, { fill: C.fillBlue }));
  e.push(text(195, 135, 'status !=\n"Registered"', { size: 18, align: 'center', middle: true }));
  e.push(text(140, 50, 'if', { size: 22, stroke: '#c2255c' }));
  // true branch
  e.push(arrow([[195, 72], [195, 26], [336, 26]]));
  e.push(text(250, 0, 'True', { size: 19, stroke: C.green }));
  e.push(box(342, 2, 150, 48, 'send alert', { fill: C.fillGreen, size: 20 }));
  e.push(arrow([[498, 26], [570, 26], [570, 104]]));
  e.push(text(418, 62, 'do this', { size: 17, stroke: C.green, align: 'center' }));
  // false branch
  e.push(arrow([[294, 135], [540, 135]]));
  e.push(text(300, 105, 'False', { size: 19, stroke: C.red }));
  e.push(text(418, 146, 'do nothing', { size: 17, stroke: C.red, align: 'center' }));
  e.push(dot(547, 112, 'End'));
  save(D + 'if-flow.excalidraw', e);
}
// elif flow
{
  const e = [];
  e.push(diamond(0, 0, 170, 100, { fill: C.fillBlue }));
  e.push(text(85, 50, 'mos >= 4.0', { size: 18, align: 'center', middle: true }));
  e.push(text(6, -10, 'if', { size: 20, stroke: '#c2255c' }));
  e.push(arrow([[174, 50], [246, 50]])); e.push(text(184, 22, 'False', { size: 16, stroke: C.red }));
  e.push(diamond(250, 0, 170, 100, { fill: C.fillBlue }));
  e.push(text(335, 50, 'mos >= 3.6', { size: 18, align: 'center', middle: true }));
  e.push(text(256, -10, 'elif', { size: 20, stroke: '#c2255c' }));
  e.push(arrow([[424, 50], [496, 50], [496, 140]])); e.push(text(434, 22, 'False', { size: 16, stroke: C.red }));
  e.push(text(506, 80, 'else', { size: 20, stroke: '#c2255c' }));
  e.push(arrow([[85, 104], [85, 140]])); e.push(text(92, 108, 'True', { size: 16, stroke: C.green }));
  e.push(arrow([[335, 104], [335, 140]])); e.push(text(342, 108, 'True', { size: 16, stroke: C.green }));
  e.push(box(25, 146, 120, 46, '"good"', { fill: C.fillGreen, round: true, size: 20 }));
  e.push(box(275, 146, 120, 46, '"fair"', { fill: C.fillYellow, round: true, size: 20 }));
  e.push(box(436, 146, 120, 46, '"poor"', { fill: '#ffc9c9', round: true, size: 20 }));
  e.push(text(290, 212, 'checked top to bottom, only the first True branch runs', { size: 17, stroke: C.gray, align: 'center' }));
  save(D + 'elif-flow.excalidraw', e);
}
