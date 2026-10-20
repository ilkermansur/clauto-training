import { C, text, rect, arrow, box, save, measure } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;
const PINK = '#c2255c', GR = '#e9ecef', RED = '#ffc9c9';
// zeep flow
{
  const e = [];
  e.push(rect(0, 0, 150, 70, { fill: GR }));
  e.push(text(75, 24, 'AXLAPI.wsdl', { size: 18, align: 'center', middle: true }));
  e.push(text(75, 50, 'the contract', { size: 15, stroke: C.gray, align: 'center', middle: true }));
  e.push(arrow([[75, 76], [75, 116]])); e.push(text(85, 86, 'read once', { size: 14, stroke: C.gray }));
  e.push(box(0, 122, 150, 56, 'zeep Client', { fill: C.fillYellow, round: true, size: 19 }));
  e.push(arrow([[156, 150], [226, 150]])); e.push(text(191, 122, 'builds XML', { size: 14, stroke: C.green, align: 'center' }));
  e.push(rect(232, 110, 190, 80, { fill: C.fillBlue, round: true }));
  e.push(text(327, 136, 'cucm-pub.clauto.lab', { size: 17, align: 'center', middle: true }));
  e.push(text(327, 164, 'POST :8443/axl/', { size: 15, stroke: C.gray, align: 'center', middle: true }));
  e.push(box(0, 230, 230, 46, 'axl.getPhone(name=…)', { fill: C.fillGreen, round: true, size: 17 }));
  e.push(arrow([[75, 224], [75, 184]], { start: 'arrow', end: null, stroke: C.green }));
  e.push(arrow([[327, 196], [327, 253], [236, 253]], { stroke: C.blue }));
  e.push(text(337, 222, 'reply = Python object', { size: 15, stroke: C.blue }));
  save(D + 'zeep-flow.excalidraw', e);
}
// zeep layers
{
  const e = [];
  const L = [['Client(wsdl, settings, transport)', C.fillYellow], ['Transport(session, cache, timeout)', C.fillBlue], ['Session: auth + verify (TLS)', C.fillGreen]];
  L.forEach(([t, f], i) => {
    const p = i * 28;
    e.push(rect(p, p, 470 - p * 2, 190 - p * 2, { fill: f, round: true }));
    e.push(text(p + 12, p + 15, t, { size: 16, middle: true }));
  });
  e.push(arrow([[476, 95], [536, 95]], { stroke: PINK }));
  e.push(text(506, 66, 'create_service', { size: 15, stroke: PINK, align: 'center' }));
  e.push(box(542, 70, 80, 50, 'axl', { fill: '#fcc2d7', round: true, size: 20 }));
  save(D + 'zeep-layers.excalidraw', e);
}
// get vs list
{
  const e = [];
  e.push(text(120, 0, 'getPhone', { size: 20, stroke: PINK, align: 'center' }));
  e.push(rect(0, 30, 250, 150, { fill: C.fillBlue, round: true }));
  e.push(text(120, 52, 'one phone, every field', { size: 16, align: 'center', middle: true }));
  ['name', 'model', 'description', 'devicePool', 'lines', '… 100+ more'].forEach((f, i) => e.push(text(16 + (i % 2) * 96, 86 + Math.floor(i / 2) * 28, f, { size: 15, middle: true, stroke: i === 5 ? C.gray : C.ink })));
  const X = 290;
  e.push(text(X + 140, 0, 'listPhone', { size: 20, stroke: PINK, align: 'center' }));
  for (let i = 0; i < 4; i++) {
    e.push(box(X, 30 + i * 38, 280, 32, i < 3 ? `SEP0A1B2…   name · description` : '… up to the page size', { fill: i < 3 ? C.fillGreen : 'transparent', size: 15, rough: 0.7, sw: 1.5 }));
  }
  e.push(text(X + 140, 196, 'many phones, only the returnedTags you ask for', { size: 15, stroke: C.gray, align: 'center' }));
  save(D + 'get-vs-list.excalidraw', e);
}
// axl paging
{
  const e = [];
  const pg = [['first=500, skip=0', '500 rows'], ['first=500, skip=500', '500 rows'], ['first=500, skip=1000', '137 rows']];
  pg.forEach(([a, b], i) => {
    const y = i * 56;
    e.push(box(0, y, 220, 44, a, { fill: C.fillBlue, size: 16 }));
    e.push(arrow([[226, y + 22], [286, y + 22]]));
    e.push(box(292, y, 110, 44, b, { fill: i === 2 ? C.fillYellow : C.fillGreen, size: 16 }));
  });
  e.push(text(414, 134, 'short page: stop', { size: 16, stroke: C.green, middle: true }));
  save(D + 'axl-paging.excalidraw', e);
}
// write and verify
{
  const e = [];
  e.push(box(0, 40, 160, 50, 'updatePhone(…)', { fill: C.fillYellow, round: true, size: 17 }));
  e.push(arrow([[166, 52], [246, 30]], { stroke: C.red })); e.push(text(204, 0, 'Fault', { size: 16, stroke: C.red, align: 'center' }));
  e.push(box(252, 6, 200, 44, 'log error, next device', { fill: RED, size: 16 }));
  e.push(arrow([[166, 78], [246, 100]], { stroke: C.green })); e.push(text(204, 106, 'ok', { size: 16, stroke: C.green, align: 'center' }));
  e.push(box(252, 80, 200, 44, 'getPhone again', { fill: C.fillBlue, size: 16 }));
  e.push(arrow([[458, 102], [508, 102]]));
  e.push(box(514, 80, 130, 44, 'compare', { fill: C.fillGreen, size: 16 }));
  e.push(text(400, 150, 'a successful reply only means CUCM accepted the request', { size: 15, stroke: C.gray, align: 'center' }));
  save(D + 'axl-write-verify.excalidraw', e);
}
// workflow pipeline
{
  const e = [];
  const steps = [['read input', GR], ['validate', C.fillBlue], ['plan (diff)', C.fillBlue], ['dry run', '#ffec99'], ['rollback file', C.fillYellow], ['apply', C.fillGreen], ['verify', C.fillGreen], ['record', GR]];
  steps.forEach(([t, f], i) => {
    const col = i % 4, row = Math.floor(i / 4);
    const x = row === 0 ? col * 150 : (3 - col) * 150, y = row * 100;
    e.push(box(x, y, 126, 48, t, { fill: f, round: true, size: 17 }));
    if (i < 7 && col < 3) e.push(row === 0 ? arrow([[x + 130, y + 24], [x + 146, y + 24]]) : arrow([[x - 4, y + 24], [x - 20, y + 24]]));
  });
  e.push(arrow([[513, 54], [513, 94]]));
  e.push(text(513 + 130, 24, 'default:\nstops here', { size: 15, stroke: '#e8590c', middle: true }));
  e.push(arrow([[600, 24], [578, 24]], { stroke: '#e8590c' }));
  e.push(text(300, 168, 'only --apply goes past the dry run', { size: 15, stroke: C.gray, align: 'center' }));
  save(D + 'axl-workflow.excalidraw', e);
}
