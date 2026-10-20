import { C, text, rect, arrow, box, save, measure } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;
const PINK = '#c2255c';
// blueprint
{
  const e = [];
  e.push(rect(0, 40, 190, 150, { fill: C.fillBlue, style: 'dashed', round: true }));
  e.push(text(95, 66, 'class Phone', { size: 20, stroke: PINK, align: 'center', middle: true }));
  ['name', 'model', 'dn'].forEach((a, i) => e.push(text(30, 104 + i * 28, a, { size: 18, middle: true })));
  e.push(text(95, 14, 'blueprint', { size: 17, stroke: C.gray, align: 'center' }));
  const inst = [['desk', '"SEP…5F"', '"Cisco 8851"', '"1001"', 0], ['lobby', '"SEP…60"', '"Cisco 8865"', '"1002"', 130]];
  for (const [n, a, b, c, y] of inst) {
    e.push(rect(320, y, 250, 112, { fill: C.fillYellow, round: true }));
    e.push(text(334, y + 20, n, { size: 19, stroke: C.green, middle: true }));
    [a, b, c].forEach((v, i) => e.push(text(350, y + 48 + i * 24, ['name', 'model', 'dn'][i] + ' = ' + v, { size: 16, middle: true })));
    e.push(arrow([[196, 115], [312, y + 56]], { stroke: C.gray }));
  }
  e.push(text(255, 104, 'Phone(...)', { size: 16, stroke: PINK, align: 'center' }));
  e.push(text(445, 252, 'objects (instances): same shape, own values', { size: 16, stroke: C.gray, align: 'center' }));
  save(D + 'class-blueprint.excalidraw', e);
}
// self
{
  const e = [];
  const parts = [['desk.mac()', C.fillYellow], ['Phone.mac(desk)', C.fillBlue], ['return self.name[3:]', C.fillGreen], ['"0A1B2C3D4E5F"', null]];
  const labels = ['Python runs', 'self = desk', 'result'];
  let x = 0;
  parts.forEach(([t, f], i) => {
    const w = measure(t, 19) + 24;
    if (f) e.push(box(x, 24, w, 46, t, { fill: f, round: true, size: 19 }));
    else e.push(text(x + 4, 47, t, { size: 19, middle: true }));
    x += w;
    if (i < 3) { e.push(arrow([[x + 6, 47], [x + 70, 47]], { stroke: i === 1 ? C.green : C.ink })); e.push(text(x + 38, 0, labels[i], { size: 15, stroke: i === 1 ? C.green : C.gray, align: 'center' })); x += 76; }
  });
  save(D + 'class-self.excalidraw', e);
}
// response object
{
  const e = [];
  e.push(rect(0, 0, 520, 150, { fill: '#e9ecef', round: true }));
  e.push(text(16, 22, 'r = requests.get(...)    an object of class Response', { size: 18, middle: true }));
  e.push(text(16, 60, 'attributes', { size: 16, stroke: '#e8590c', middle: true }));
  let x = 120;
  for (const a of ['.status_code', '.headers', '.text']) { const w = measure(a, 17) + 18; e.push(box(x, 44, w, 34, a, { fill: C.fillYellow, size: 17 })); x += w + 10; }
  e.push(text(16, 112, 'methods', { size: 16, stroke: C.green, middle: true }));
  x = 120;
  for (const a of ['.json()', '.raise_for_status()']) { const w = measure(a, 17) + 18; e.push(box(x, 96, w, 34, a, { fill: C.fillGreen, size: 17 })); x += w + 10; }
  save(D + 'response-object.excalidraw', e);
}
