import { C, text, rect, arrow, box, save } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;
const PINK = '#c2255c', GR = '#e9ecef', RED = '#ffc9c9';
// cms flow
{
  const e = [];
  e.push(box(0, 50, 120, 56, 'script', { fill: C.fillYellow, round: true, size: 19 }));
  e.push(arrow([[126, 64], [256, 64]], { stroke: C.green })); e.push(text(186, 36, 'GET · POST · PUT', { size: 13, stroke: C.green, align: 'center' }));
  e.push(text(191, 10, 'form data', { size: 13, stroke: C.gray, align: 'center' }));
  e.push(arrow([[256, 94], [126, 94]], { stroke: C.blue })); e.push(text(191, 102, 'XML reply', { size: 14, stroke: C.blue, align: 'center' }));
  e.push(rect(262, 34, 210, 86, { fill: C.fillBlue, round: true }));
  e.push(text(367, 58, 'cms-01.clauto.lab', { size: 17, align: 'center', middle: true }));
  e.push(text(367, 90, ':445/api/v1/…', { size: 15, stroke: C.gray, align: 'center', middle: true }));
  e.push(arrow([[60, 112], [60, 152]]));
  e.push(box(0, 158, 300, 44, 'xmltodict.parse()  =  dict', { fill: C.fillGreen, size: 16 }));
  save(D + 'cms-flow.excalidraw', e);
}
// xmltodict mapping
{
  const e = [];
  e.push(rect(0, 0, 300, 120, { fill: GR, round: true }));
  ['<coSpaces total="45">', '  <coSpace id="69e4…">', '    <name>Space 01</name>', '  </coSpace> …'].forEach((t, i) => e.push(text(12, 22 + i * 26, t, { size: 15, middle: true })));
  e.push(arrow([[306, 60], [366, 60]]));
  e.push(rect(372, 0, 300, 120, { fill: C.fillYellow, round: true }));
  ['data["coSpaces"]["@total"]', 'space["@id"]', 'space["name"]'].forEach((t, i) => e.push(text(386, 26 + i * 34, t, { size: 15, middle: true })));
  e.push(text(336, 146, 'attributes get an @ prefix, elements become keys', { size: 15, stroke: C.gray, align: 'center' }));
  save(D + 'cms-xmltodict.excalidraw', e);
}
// create spaces from csv
{
  const e = [];
  e.push(rect(0, 0, 200, 96, { fill: GR }));
  ['user,name', 'alice.smith,Alice Smith', 'bob.jones,Bob Jones'].forEach((t, i) => e.push(text(10, 20 + i * 28, t, { size: 15, middle: true })));
  e.push(arrow([[206, 48], [276, 48]])); e.push(text(241, 20, 'POST', { size: 15, stroke: C.green, align: 'center' }));
  e.push(box(282, 6, 200, 40, 'Alice Smith Space', { fill: C.fillGreen, round: true, size: 15 }));
  e.push(box(282, 54, 200, 40, 'Bob Jones Space', { fill: C.fillGreen, round: true, size: 15 }));
  e.push(text(382, 112, 'reply: 200 + Location header', { size: 14, stroke: C.blue, align: 'center' }));
  e.push(text(382, 132, '/api/v1/coSpaces/<new id>', { size: 14, stroke: C.blue, align: 'center' }));
  save(D + 'cms-create.excalidraw', e);
}
// calls -> legs
{
  const e = [];
  e.push(box(0, 40, 150, 50, 'GET /calls', { fill: C.fillBlue, size: 17 }));
  e.push(arrow([[156, 65], [206, 65]]));
  e.push(box(212, 40, 160, 50, 'Space 01 (call)', { fill: C.fillYellow, round: true, size: 16 }));
  e.push(arrow([[378, 58], [438, 26]])); e.push(arrow([[378, 72], [438, 104]]));
  e.push(box(444, 6, 200, 40, 'Alice Smith', { fill: C.fillGreen, size: 15 }));
  e.push(box(444, 86, 200, 40, 'Bob Jones', { fill: C.fillGreen, size: 15 }));
  e.push(text(544, 66, '/calls/<id>/callLegs', { size: 14, stroke: C.gray, align: 'center', middle: true }));
  save(D + 'cms-calls.excalidraw', e);
}
