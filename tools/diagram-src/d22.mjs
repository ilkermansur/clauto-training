import { C, text, rect, arrow, box, save } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;
const PINK = '#c2255c', GR = '#e9ecef';
// plural wrapper -> singular items
{
  const e = [];
  e.push(text(120, 0, 'Python', { size: 17, stroke: C.gray, align: 'center' }));
  e.push(text(480, 0, 'AXL XML', { size: 17, stroke: C.gray, align: 'center' }));
  e.push(rect(0, 28, 250, 150, { fill: C.fillYellow, round: true }));
  e.push(text(14, 50, '"lines": {', { size: 17, middle: true }));
  e.push(text(30, 78, '"line": [', { size: 17, middle: true, stroke: PINK }));
  e.push(box(46, 96, 180, 30, '{ index 1, dirn … }', { fill: C.fillLime, size: 15 }));
  e.push(box(46, 132, 180, 30, '{ index 2, dirn … }', { fill: C.fillLime, size: 15 }));
  e.push(arrow([[256, 103], [346, 103]]));
  e.push(rect(352, 28, 250, 150, { fill: GR, round: true }));
  e.push(text(366, 50, '<lines>', { size: 17, middle: true }));
  e.push(box(380, 70, 200, 40, '<line> … </line>', { fill: C.fillLime, size: 15 }));
  e.push(box(380, 116, 200, 40, '<line> … </line>', { fill: C.fillLime, size: 15 }));
  e.push(text(300, 200, 'plural wrapper, singular items: lines/line, members/member, speeddials/speeddial', { size: 15, stroke: C.gray, align: 'center' }));
  save(D + 'axl-nested-write.excalidraw', e);
}
// history plugin
{
  const e = [];
  e.push(box(0, 60, 130, 54, 'axl.addPhone()', { fill: C.fillYellow, round: true, size: 17 }));
  e.push(rect(170, 20, 200, 134, { fill: '#fcc2d7', round: true }));
  e.push(text(270, 40, 'HistoryPlugin', { size: 18, align: 'center', middle: true, stroke: PINK }));
  e.push(box(186, 62, 168, 36, 'last_sent', { fill: C.fillGreen, size: 16 }));
  e.push(box(186, 106, 168, 36, 'last_received', { fill: C.fillBlue, size: 16 }));
  e.push(arrow([[136, 87], [164, 87]]));
  e.push(arrow([[376, 87], [436, 87]]));
  e.push(box(442, 60, 110, 54, 'CUCM', { fill: C.fillBlue, round: true, size: 19 }));
  e.push(text(270, 176, 'keeps a copy of the raw XML in both directions', { size: 15, stroke: C.gray, align: 'center' }));
  save(D + 'axl-history.excalidraw', e);
}
