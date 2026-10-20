import { C, text, arrow, box, save, measure } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;
const PINK = '#c2255c';
function segs(parts, y = 0) {
  const e = []; let x = 0;
  for (const [t, fill, label, lc] of parts) {
    const w = Math.max(measure(t, 20) + (fill ? 22 : 8), label ? measure(label, 16) + 12 : 0);
    if (fill) e.push(box(x, y, w, 46, t, { fill, size: 20 }));
    else e.push(text(x + w / 2, y + 23, t, { size: 24, align: 'center', middle: true }));
    if (label) e.push(text(x + w / 2, y + 60, label, { size: 16, stroke: lc, align: 'center' }));
    x += w + 6;
  }
  return [e, x];
}
{
  const [e, w] = segs([
    ['[', null], ['p[3:]', C.fillYellow, '1. what to keep', '#e8590c'],
    ['for p in phones', C.fillBlue, '2. the loop', C.blue],
    ['if p.startswith("SEP")', C.fillGreen, '3. filter (optional)', C.green], [']', null],
  ], 30);
  e.push(text(w / 2, 0, 'list comprehension', { size: 18, stroke: PINK, align: 'center' }));
  e.push(text(w / 2, 130, 'read it as: "p[3:] for every p in phones, if p starts with SEP"', { size: 16, stroke: C.gray, align: 'center' }));
  save(D + 'comp-anatomy.excalidraw', e);
}
{
  const [e, w] = segs([
    ['lambda', '#fcc2d7', 'keyword', PINK], ['p', C.fillYellow, 'parameter', '#e8590c'], [':', null],
    ['p["dn"]', C.fillGreen, 'returned value', C.green],
  ], 0);
  e.push(text(w + 40, 23, '=', { size: 26, align: 'center', middle: true }));
  e.push(box(w + 70, 0, measure('def f(p): return p["dn"]', 18) + 24, 46, 'def f(p): return p["dn"]', { fill: '#e9ecef', size: 18 }));
  e.push(text(w + 70 + (measure('def f(p): return p["dn"]', 18) + 24) / 2, 60, 'same thing, with a name', { size: 16, stroke: C.gray, align: 'center' }));
  save(D + 'lambda-anatomy.excalidraw', e);
}
