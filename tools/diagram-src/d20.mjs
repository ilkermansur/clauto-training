import { C, text, rect, arrow, box, save, measure } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;
const PINK = '#c2255c', GR = '#e9ecef';
// requests call
{
  const e = [];
  e.push(box(0, 30, 200, 56, 'requests.get(url, ...)', { fill: C.fillYellow, round: true, size: 18 }));
  e.push(arrow([[206, 46], [316, 46]], { stroke: C.green })); e.push(text(261, 18, 'HTTP request', { size: 15, stroke: C.green, align: 'center' }));
  e.push(box(322, 22, 150, 72, 'webexapis.com', { fill: C.fillBlue, round: true, size: 18 }));
  e.push(arrow([[316, 74], [206, 74]], { stroke: C.blue })); e.push(text(261, 82, 'HTTP response', { size: 15, stroke: C.blue, align: 'center' }));
  e.push(arrow([[100, 92], [100, 132]]));
  e.push(rect(0, 138, 472, 56, { fill: GR, round: true }));
  e.push(text(14, 166, 'r', { size: 20, stroke: PINK, middle: true }));
  let x = 44;
  for (const a of ['.status_code', '.ok', '.json()', '.text', '.headers']) { const w = measure(a, 16) + 16; e.push(box(x, 149, w, 34, a, { fill: C.fillGreen, size: 16 })); x += w + 8; }
  save(D + 'requests-call.excalidraw', e);
}
// args -> http parts
{
  const e = [];
  const rows = [['params={...}', 'query string ?email=…'], ['headers={...}', 'request headers'], ['json={...}', 'body + Content-Type: json'], ['auth=(user, pw)', 'Authorization: Basic …'], ['timeout=10', 'give up after 10 s']];
  e.push(text(90, 0, 'Python argument', { size: 16, stroke: C.gray, align: 'center' }));
  e.push(text(430, 0, 'what goes on the wire', { size: 16, stroke: C.gray, align: 'center' }));
  rows.forEach(([a, b], i) => {
    const y = 28 + i * 50;
    e.push(box(0, y, 180, 40, a, { fill: C.fillYellow, size: 17 }));
    e.push(arrow([[186, y + 20], [286, y + 20]]));
    e.push(box(292, y, 280, 40, b, { fill: i === 4 ? '#ffec99' : C.fillBlue, size: 17 }));
  });
  save(D + 'requests-args.excalidraw', e);
}
// session
{
  const e = [];
  e.push(rect(0, 0, 250, 150, { fill: C.fillLime, round: true }));
  e.push(text(14, 22, 's = requests.Session()', { size: 18, stroke: PINK, middle: true }));
  ['headers (token)', 'auth', 'open connection'].forEach((t, i) => e.push(text(28, 56 + i * 28, '· ' + t, { size: 17, middle: true })));
  ['s.get(".../people")', 's.get(".../devices")', 's.post(".../messages")'].forEach((t, i) => {
    const y = 4 + i * 54;
    e.push(arrow([[256, 75], [330, y + 22]], { stroke: C.green }));
    e.push(box(336, y, 220, 44, t, { fill: C.fillBlue, size: 16 }));
  });
  e.push(text(280, 182, 'set once, reused by every call: less code, faster', { size: 15, stroke: C.gray, align: 'center' }));
  save(D + 'requests-session.excalidraw', e);
}
// pagination
{
  const e = [];
  const pages = ['page 1', 'page 2', 'page 3'];
  pages.forEach((p, i) => {
    const x = i * 200;
    e.push(box(x, 20, 130, 56, p, { fill: i === 2 ? C.fillGreen : C.fillBlue, round: true, size: 19 }));
    if (i < 2) { e.push(arrow([[x + 136, 48], [x + 194, 48]])); e.push(text(x + 165, 0, 'Link: next', { size: 14, stroke: C.green, align: 'center' })); }
  });
  e.push(text(465, 92, 'no next link: stop', { size: 15, stroke: C.green, align: 'center' }));
  e.push(box(0, 130, 120, 46, 'request', { fill: GR, size: 18 }));
  e.push(arrow([[126, 153], [196, 153]]));
  e.push(box(202, 130, 100, 46, '429', { fill: '#ffc9c9', size: 20, stroke: C.red, textColor: C.red }));
  e.push(arrow([[252, 182], [252, 210], [60, 210], [60, 182]], { stroke: C.red }));
  e.push(text(156, 216, 'sleep(Retry-After), try again', { size: 15, stroke: C.red, align: 'center' }));
  save(D + 'requests-paging.excalidraw', e);
}
