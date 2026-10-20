import { C, text, rect, arrow, box, save } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;
const PINK = '#c2255c', GR = '#e9ecef';
// phone web
{
  const e = [];
  e.push(box(0, 60, 120, 56, 'script', { fill: C.fillYellow, round: true, size: 19 }));
  e.push(arrow([[126, 70], [256, 30]], { stroke: C.blue })); e.push(text(166, 22, '1. where is it?', { size: 14, stroke: C.blue, align: 'center' }));
  e.push(box(262, 6, 150, 44, 'RIS (2.5)', { fill: C.fillBlue, size: 16 }));
  e.push(arrow([[126, 100], [256, 124]], { stroke: C.green })); e.push(text(176, 128, '2. POST /CGI/Execute', { size: 14, stroke: C.green, align: 'center' }));
  e.push(rect(262, 96, 170, 90, { fill: GR, round: true }));
  e.push(text(347, 118, 'SEP0A1B2C3D4E5F', { size: 15, align: 'center', middle: true }));
  e.push(text(347, 146, 'web server', { size: 14, stroke: C.gray, align: 'center', middle: true }));
  e.push(text(347, 168, 'Web Access: on', { size: 14, stroke: C.green, align: 'center', middle: true }));
  e.push(arrow([[438, 140], [498, 140]], { stroke: PINK })); e.push(text(468, 112, 'login?', { size: 14, stroke: PINK, align: 'center' }));
  e.push(box(504, 116, 110, 48, 'CUCM', { fill: C.fillBlue, round: true, size: 18 }));
  e.push(text(560, 186, 'checks user + controlled device', { size: 13, stroke: C.gray, align: 'center' }));
  save(D + 'phone-web.excalidraw', e);
}
// key sequence
{
  const e = [];
  const keys = ['Applications', '6', '4', '4', 'Soft3', 'Soft1'];
  let x = 0;
  keys.forEach((k, i) => {
    const w = k.length > 2 ? 104 : 46;
    e.push(box(x, 20, w, 44, k, { fill: i < 4 ? C.fillBlue : C.fillGreen, round: true, size: 16 }));
    if (i < keys.length - 1) e.push(arrow([[x + w + 3, 42], [x + w + 21, 42]]));
    x += w + 24;
  });
  e.push(text(x / 2, 0, '88xx: erase the ITL file', { size: 16, stroke: PINK, align: 'center' }));
  e.push(text(x / 2, 86, 'one POST per key press, with a pause so the menu can open', { size: 14, stroke: C.gray, align: 'center' }));
  save(D + 'phone-keys.excalidraw', e);
}
