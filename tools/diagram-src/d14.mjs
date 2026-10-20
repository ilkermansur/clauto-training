import { C, text, rect, arrow, box, save, measure } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;
const PINK = '#c2255c', GRAYF = '#e9ecef';
// with block
{
  const e = [];
  e.push(rect(0, 0, 330, 170, { stroke: C.green, style: 'dashed', fill: '#ebfbee', fillStyle: 'solid' }));
  e.push(text(14, 22, 'with open("phones.txt") as f:', { size: 18, stroke: PINK, middle: true }));
  e.push(box(30, 56, 120, 44, 'f.read()', { fill: C.fillBlue, size: 18 }));
  e.push(box(180, 56, 120, 44, 'f.write()', { fill: C.fillBlue, size: 18 }));
  e.push(text(165, 140, 'file is open only inside', { size: 16, stroke: C.green, align: 'center', middle: true }));
  e.push(arrow([[336, 78], [430, 78]], { start: 'arrow' }));
  e.push(rect(436, 40, 140, 80, { fill: GRAYF }));
  e.push(text(506, 68, 'phones.txt', { size: 18, align: 'center', middle: true }));
  e.push(text(506, 98, 'on disk', { size: 15, stroke: C.gray, align: 'center', middle: true }));
  e.push(text(165, 196, 'block ends = f.close(), even after an error', { size: 16, stroke: C.gray, align: 'center', middle: true }));
  save(D + 'file-with.excalidraw', e);
}
// text lines
{
  const e = [];
  e.push(text(0, 0, 'phones.txt', { size: 17, stroke: C.gray }));
  const L = ['SEP0A1B2C3D4E5F\\n', 'SEP0A1B2C3D4E60\\n', '\\n', 'SEP0A1B2C3D4E61\\n'];
  L.forEach((l, i) => {
    const y = 28 + i * 44;
    e.push(box(0, y, 210, 38, l, { fill: GRAYF, size: 17, rough: 0.7 }));
    e.push(arrow([[216, y + 19], [290, y + 19]], { stroke: i === 2 ? C.red : C.green }));
    if (i === 2) e.push(text(298, y + 19, 'empty: continue', { size: 17, stroke: C.red, middle: true }));
    else e.push(text(298, y + 19, `"${l.replace('\\n', '')}"`, { size: 17, middle: true }));
  });
  e.push(text(253, 0, '.strip()', { size: 17, stroke: C.green, align: 'center' }));
  save(D + 'text-lines.excalidraw', e);
}
// csv -> dict
{
  const e = [];
  const cols = [['user', 120], ['dn', 70], ['device', 170]];
  const rows = [['user', 'dn', 'device'], ['alice.smith', '1001', 'SEP0A1B2…5F'], ['bob.jones', '1002', 'SEP0A1B2…60']];
  rows.forEach((r, ri) => {
    let x = 0;
    r.forEach((v, ci) => {
      e.push(box(x, ri * 38, cols[ci][1], 38, v, { fill: ri === 0 ? C.fillYellow : (ri === 1 ? C.fillLime : 'transparent'), size: 16, rough: 0.6, sw: 1.5 }));
      x += cols[ci][1];
    });
  });
  e.push(text(-10, 19, 'header', { size: 15, stroke: C.gray, align: 'right', middle: true }));
  e.push(text(-10, 57, 'row 1', { size: 15, stroke: C.gray, align: 'right', middle: true }));
  e.push(arrow([[180, 124], [180, 168]], { stroke: C.green }));
  e.push(text(190, 136, 'csv.DictReader', { size: 16, stroke: C.green }));
  e.push(box(0, 174, 360, 46, '{"user": "alice.smith", "dn": "1001", ...}', { fill: C.fillBlue, round: true, size: 16 }));
  e.push(text(370, 198, 'one dict per row,\nheader = keys,\nall values are str', { size: 15, stroke: C.gray, middle: true }));
  save(D + 'csv-dict.excalidraw', e);
}
// json map
{
  const e = [];
  e.push(text(110, 0, 'Python dict', { size: 18, stroke: C.gray, align: 'center' }));
  e.push(box(0, 30, 220, 96, '{"lines": ["1001"],\n "registered": True,\n "description": None}', { fill: C.fillYellow, round: true, size: 16 }));
  e.push(text(480, 0, 'JSON text', { size: 18, stroke: C.gray, align: 'center' }));
  e.push(box(370, 30, 220, 96, '{"lines": ["1001"],\n "registered": true,\n "description": null}', { fill: GRAYF, round: true, size: 16 }));
  e.push(arrow([[226, 50], [296, 34], [364, 50]], { round: true, stroke: C.green }));
  e.push(text(295, 6, 'dump / dumps', { size: 16, stroke: C.green, align: 'center' }));
  e.push(arrow([[364, 108], [296, 124], [226, 108]], { round: true, stroke: C.blue }));
  e.push(text(295, 132, 'load / loads', { size: 16, stroke: C.blue, align: 'center' }));
  save(D + 'json-map.excalidraw', e);
}
