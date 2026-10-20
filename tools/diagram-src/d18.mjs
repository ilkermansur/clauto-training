import { C, text, rect, arrow, box, save, measure } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;
const PINK = '#c2255c', RED = '#ffc9c9';
// http cycle
{
  const e = [];
  e.push(box(0, 70, 150, 70, 'your script\n(client)', { fill: C.fillYellow, round: true, size: 19 }));
  e.push(box(520, 70, 170, 70, 'CUCM / Webex\n(server)', { fill: C.fillBlue, round: true, size: 19 }));
  e.push(arrow([[156, 88], [514, 88]], { stroke: C.green }));
  e.push(text(335, 22, 'request', { size: 19, stroke: C.green, align: 'center' }));
  e.push(text(335, 50, 'method · URL · headers · body', { size: 16, stroke: C.gray, align: 'center' }));
  e.push(arrow([[514, 124], [156, 124]], { stroke: C.blue }));
  e.push(text(335, 138, 'response', { size: 19, stroke: C.blue, align: 'center' }));
  e.push(text(335, 166, 'status code · headers · body', { size: 16, stroke: C.gray, align: 'center' }));
  e.push(text(335, 200, 'one request, one response, then the connection is free again', { size: 15, stroke: C.gray, align: 'center' }));
  save(D + 'http-cycle.excalidraw', e);
}
// url anatomy
{
  const e = [];
  const parts = [['https://', C.fillYellow, 'scheme'], ['webexapis.com', C.fillBlue, 'host'], ['/v1/people', C.fillGreen, 'path'], ['?email=alice.smith@clauto.lab', '#e9ecef', 'query']];
  let x = 0;
  for (const [t, f, l] of parts) {
    const w = measure(t, 19) + 20;
    e.push(box(x, 0, w, 46, t, { fill: f, size: 19, rough: 0.8 }));
    e.push(text(x + w / 2, 58, l, { size: 16, stroke: C.gray, align: 'center' }));
    x += w;
  }
  e.push(text(x / 2, 94, 'CUCM:  https://cucm-pub.clauto.lab:8443/axl/      (host + port + path)', { size: 16, stroke: PINK, align: 'center' }));
  save(D + 'url-anatomy.excalidraw', e);
}
// status bands
{
  const e = [];
  const rows = [['2xx', 'success', C.fillGreen, C.green], ['3xx', 'redirect', '#e9ecef', C.gray], ['4xx', 'your request is wrong', '#ffec99', '#e8590c'], ['5xx', 'the server failed', RED, C.red]];
  rows.forEach(([c, m, f, s], i) => {
    e.push(box(0, i * 52, 90, 44, c, { fill: f, size: 22, stroke: s, textColor: s }));
    e.push(text(104, i * 52 + 22, m, { size: 19, middle: true }));
  });
  e.push(text(330, 22, '200 OK · 201 Created · 204 No Content', { size: 15, stroke: C.gray, middle: true }));
  e.push(text(330, 126, '401 · 403 · 404 · 429', { size: 15, stroke: C.gray, middle: true }));
  e.push(text(330, 178, '500 · 503', { size: 15, stroke: C.gray, middle: true }));
  save(D + 'http-status.excalidraw', e);
}
