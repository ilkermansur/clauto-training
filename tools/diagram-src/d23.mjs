import { C, text, rect, arrow, box, ellipse, save } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;
const PINK = '#c2255c', GR = '#e9ecef', RED = '#ffc9c9';
// axl vs ris
{
  const e = [];
  e.push(box(0, 70, 120, 56, 'script', { fill: C.fillYellow, round: true, size: 19 }));
  e.push(arrow([[126, 84], [236, 40]], { stroke: C.blue })); e.push(text(170, 30, 'AXL', { size: 17, stroke: C.blue, align: 'center' }));
  e.push(arrow([[126, 112], [236, 158]], { stroke: C.green })); e.push(text(170, 150, 'RisPort70', { size: 17, stroke: C.green, align: 'center' }));
  e.push(rect(242, 6, 220, 70, { fill: C.fillBlue, round: true }));
  e.push(text(352, 28, 'configuration DB', { size: 17, align: 'center', middle: true }));
  e.push(text(352, 54, 'what a phone should be', { size: 15, stroke: C.gray, align: 'center', middle: true }));
  e.push(rect(242, 122, 220, 70, { fill: C.fillGreen, round: true }));
  e.push(text(352, 144, 'real-time state', { size: 17, align: 'center', middle: true }));
  e.push(text(352, 170, 'what a phone is right now', { size: 15, stroke: C.gray, align: 'center', middle: true }));
  e.push(text(480, 40, 'name, model, DN,\ndevice pool, CSS …', { size: 15, middle: true }));
  e.push(text(480, 156, 'Registered?\non which node?', { size: 15, middle: true }));
  save(D + 'axl-vs-ris.excalidraw', e);
}
// ris tree
{
  const e = [];
  const row = (x, y, t, f, w = 200) => e.push(box(x, y, w, 36, t, { fill: f, size: 16, rough: 0.8 }));
  row(0, 0, 'SelectCmDeviceResult', GR, 220);
  row(30, 50, 'CmNodes.item[0]  cucm-pub', C.fillBlue, 250);
  row(60, 96, 'SEP…5F   Registered', C.fillGreen, 230);
  row(30, 146, 'CmNodes.item[1]  cucm-sub1', C.fillBlue, 250);
  row(60, 192, 'SEP…60   UnRegistered', RED, 230);
  row(60, 234, 'CSFALICE   Registered', C.fillGreen, 230);
  for (const [y1, y2, x] of [[36, 68, 14], [36, 164, 14], [86, 114, 44], [182, 210, 44], [182, 252, 44]])
    e.push(arrow([[x, y1], [x, y2], [x + 14, y2]], { line: true, sw: 1.5, rough: 0.5 }));
  e.push(text(310, 120, 'one entry per CUCM node:\nloop over all of them,\nnot just item[0]', { size: 15, stroke: C.red, middle: true }));
  save(D + 'ris-tree.excalidraw', e);
}
// join
{
  const e = [];
  e.push(ellipse(0, 20, 260, 170, { fill: C.fillBlue }));
  e.push(ellipse(140, 20, 260, 170, { fill: C.fillGreen }));
  e.push(text(100, 0, 'AXL: configured', { size: 17, stroke: C.blue, align: 'center' }));
  e.push(text(320, 0, 'RIS: registered', { size: 17, stroke: C.green, align: 'center' }));
  e.push(text(70, 105, 'SEP…60\nSEP…61', { size: 16, align: 'center', middle: true }));
  e.push(text(200, 105, 'SEP…5F', { size: 16, align: 'center', middle: true }));
  e.push(text(70, 204, 'not registered:\nthe report', { size: 15, stroke: C.red, align: 'center' }));
  e.push(text(200, 204, 'OK', { size: 15, stroke: C.green, align: 'center' }));
  save(D + 'ris-join.excalidraw', e);
}
