import { C, text, rect, arrow, box, save, ellipse, diamond } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;
// variables -> objects
{
  const rows = [
    ['dn', '"1001"', 'str', C.fillYellow],
    ['ring_count', '4', 'int', C.fillBlue],
    ['is_registered', 'True', 'bool', C.fillGreen],
    ['codecs', '["G722", "G711u"]', 'list', C.fillLime],
  ];
  const els = [text(20, 0, 'names', { size: 22, stroke: C.gray }), text(260, 0, 'objects', { size: 22, stroke: C.gray }),
               text(545, 0, 'type', { size: 22, stroke: C.gray })];
  rows.forEach(([n, v, t, f], i) => {
    const y = 50 + i * 72;
    els.push(text(20, y + 10, n, { size: 24 }));
    els.push(arrow([[175, y + 24], [250, y + 24]]));
    els.push(box(258, y, 250, 48, v, { fill: f, round: true, size: 22 }));
    els.push(text(545, y + 10, t, { size: 26, stroke: C.green }));
  });
  els.push(text(300, 360, 'the name has no type,\nthe object does!', { size: 22, stroke: C.red }));
  els.push(arrow([[545, 372], [575, 360], [578, 325]], { stroke: C.red, round: true }));
  save(D + 'variables-objects.excalidraw', els);
}
// cover art
{
  const els = [];
  els.push(box(0, 120, 170, 80, '{ python }', { fill: C.fillYellow, round: true, size: 26 }));
  els.push(arrow([[180, 145], [250, 90], [330, 70]], { round: true }));
  els.push(arrow([[180, 175], [250, 230], [330, 250]], { round: true }));
  els.push(text(212, 40, 'SOAP / AXL', { size: 20, stroke: C.green }));
  els.push(text(212, 262, 'REST', { size: 20, stroke: C.green }));
  els.push(box(340, 35, 190, 70, 'CUCM', { fill: C.fillBlue, round: true, size: 26 }));
  els.push(box(340, 215, 190, 70, 'Webex', { fill: C.fillGreen, round: true, size: 26 }));
  els.push(text(85, 225, 'automate it!', { size: 22, align: 'center', stroke: C.green }));
  save(D + 'cover.excalidraw', els);
}
