import { C, text, rect, arrow, box, save, measure } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;
const PINK = '#c2255c';
// data tree
{
  const e = [];
  e.push(box(0, 80, 110, 46, 'phone', { fill: C.fillBlue, round: true, size: 20 }));
  const kids = [['name', '"SEP0A1B2C3D4E5F"', 0], ['model', '"Cisco 8851"', 60], ['lines', null, 120]];
  for (const [k, v, y] of kids) {
    e.push(arrow([[116, 103], [176, y + 20]], { line: true, sw: 1.5 }));
    e.push(box(182, y, 90, 40, k, { fill: C.fillYellow, size: 18 }));
    if (v) e.push(text(286, y + 20, v, { size: 18, middle: true }));
  }
  e.push(arrow([[278, 140], [318, 140]], { line: true, sw: 1.5 }));
  e.push(box(324, 120, 80, 40, '"1001"', { fill: C.fillLime, size: 17 }));
  e.push(box(404, 120, 80, 40, '"1002"', { fill: C.fillLime, size: 17 }));
  e.push(text(0, 200, 'JSON:  object { }  for phone,  array [ ]  for lines', { size: 16, stroke: C.blue }));
  e.push(text(0, 226, 'XML:   element <phone>,  repeated <line> elements', { size: 16, stroke: PINK }));
  save(D + 'data-tree.excalidraw', e);
}
// xml anatomy
{
  const e = [];
  const parts = [['<user', C.fillBlue, 'start tag'], [' uri="…/alice.smith"', C.fillYellow, 'attribute'], ['>', C.fillBlue, null], ['alice.smith', C.fillGreen, 'text'], ['</user>', C.fillBlue, 'end tag']];
  let x = 0;
  for (const [t, f, l] of parts) {
    const w = Math.max(measure(t, 20) + 16, l ? measure(l, 16) + 10 : 0);
    e.push(box(x, 0, w, 46, t.trim(), { fill: f, size: 20, rough: 0.8 }));
    if (l) e.push(text(x + w / 2, 58, l, { size: 16, stroke: C.gray, align: 'center' }));
    x += w;
  }
  e.push(text(x / 2, 94, 'element = start tag + content + end tag; elements nest inside elements', { size: 15, stroke: C.gray, align: 'center' }));
  save(D + 'xml-anatomy.excalidraw', e);
}
// soap envelope
{
  const e = [];
  const layers = [['soapenv:Envelope', '#e9ecef'], ['soapenv:Body', '#e9ecef'], ['ns:getPhoneResponse', C.fillBlue], ['return', C.fillYellow], ['phone', C.fillGreen]];
  layers.forEach(([t, f], i) => {
    const pad = i * 30;
    e.push(rect(pad, pad, 560 - pad * 2, 330 - pad * 2, { fill: f, round: true }));
    e.push(text(pad + 12, pad + 17, t, { size: 18, middle: true, stroke: i === 4 ? C.green : C.ink }));
  });
  e.push(text(280, 178, 'name · model · lines …', { size: 17, align: 'center', middle: true }));
  e.push(text(580, 178, 'your data\nis here', { size: 17, stroke: C.green, middle: true }));
  e.push(arrow([[576, 178], [520, 178]], { stroke: C.green }));
  save(D + 'soap-envelope.excalidraw', e);
}
