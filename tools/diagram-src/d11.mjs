import { C, text, rect, arrow, box, save, measure } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;
const PINK = '#c2255c';
const lbl = (x, y, s, o = {}) => text(x, y, s, { size: 16, stroke: C.green, align: 'center', ...o });
// function machine
{
  const e = [];
  const inT = '"0a:1b:2c:3d:4e:5f"', outT = '"SEP0A1B2C3D4E5F"';
  const wi = measure(inT, 18) + 26, wo = measure(outT, 18) + 26;
  e.push(box(0, 50, wi, 50, inT, { fill: C.fillYellow, round: true, size: 18 }));
  let x = wi;
  e.push(arrow([[x + 8, 75], [x + 88, 75]])); e.push(lbl(x + 48, 40, 'argument'));
  x += 96;
  const wm = measure('build_device_name(mac)', 18) + 30;
  e.push(rect(x, 26, wm, 98, { fill: C.fillBlue, round: true }));
  e.push(text(x + wm / 2, 56, 'build_device_name(mac)', { size: 18, align: 'center', middle: true }));
  e.push(text(x + wm / 2, 94, 'strip · upper · replace', { size: 15, stroke: C.gray, align: 'center', middle: true }));
  e.push(text(x, -4, 'def', { size: 20, stroke: PINK }));
  x += wm;
  e.push(arrow([[x + 8, 75], [x + 88, 75]])); e.push(lbl(x + 48, 40, 'return'));
  x += 96;
  e.push(box(x, 50, wo, 50, outT, { fill: C.fillGreen, round: true, size: 18 }));
  e.push(text(wi / 2, 112, 'input', { size: 15, stroke: C.gray, align: 'center' }));
  e.push(text(x + wo / 2, 112, 'output', { size: 15, stroke: C.gray, align: 'center' }));
  save(D + 'function-machine.excalidraw', e);
}
// *args pack
{
  const e = [];
  e.push(text(0, 0, 'reset_phones("SEP…5F", "SEP…60")', { size: 18 }));
  e.push(box(20, 40, 110, 40, '"SEP…5F"', { fill: C.fillYellow, size: 17 }));
  e.push(box(150, 40, 110, 40, '"SEP…60"', { fill: C.fillYellow, size: 17 }));
  e.push(arrow([[75, 86], [75, 128]])); e.push(arrow([[205, 86], [205, 128]]));
  e.push(lbl(330, 98, '*names packs\nthem into a tuple', { align: 'left', size: 16 }));
  e.push(rect(10, 134, 260, 54, { fill: C.fillLime, round: true }));
  e.push(text(140, 161, '("SEP…5F", "SEP…60")', { size: 18, align: 'center', middle: true }));
  e.push(text(140, 196, 'names', { size: 16, stroke: C.gray, align: 'center' }));
  // unpack
  e.push(box(380, 246, 230, 46, '["SEP…5F", "SEP…60"]', { fill: C.fillBlue, round: true, size: 17 }));
  e.push(text(495, 300, 'phones (list)', { size: 15, stroke: C.gray, align: 'center' }));
  e.push(arrow([[374, 269], [300, 269], [300, 60], [266, 60]], { stroke: C.blue }));
  e.push(text(312, 186, 'reset_phones(*phones)\nunpacks the list', { size: 16, stroke: C.blue }));
  save(D + 'args-pack.excalidraw', e);
}
// **kwargs pack
{
  const e = [];
  e.push(text(0, 0, 'keyword arguments in the call', { size: 16, stroke: C.gray }));
  e.push(box(0, 30, 240, 42, 'devicePoolName="DP_HQ"', { fill: C.fillYellow, size: 17 }));
  e.push(box(0, 86, 240, 42, 'description="Alice desk"', { fill: C.fillYellow, size: 17 }));
  e.push(arrow([[246, 51], [320, 70]])); e.push(arrow([[246, 107], [320, 90]]));
  e.push(lbl(283, 128, '**fields', { size: 18 }));
  e.push(rect(326, 22, 300, 114, { fill: C.fillLime, round: true }));
  e.push(text(476, 50, '"devicePoolName": "DP_HQ"', { size: 17, align: 'center', middle: true }));
  e.push(text(476, 84, '"description": "Alice desk"', { size: 17, align: 'center', middle: true }));
  e.push(text(476, 116, 'fields (dict)', { size: 15, stroke: C.gray, align: 'center', middle: true }));
  save(D + 'kwargs-pack.excalidraw', e);
}
// modules import
{
  const e = [];
  const file = (x, y, w, name, lines, fill) => {
    e.push(rect(x, y, w, 36, { fill: '#e9ecef' }));
    e.push(text(x + 12, y + 18, name, { size: 18, middle: true }));
    e.push(rect(x, y + 36, w, lines.length * 30 + 20, { fill }));
    lines.forEach((l, i) => e.push(text(x + 14, y + 56 + i * 30, l, { size: 16, middle: true })));
  };
  file(0, 0, 270, 'cucm_tools.py', ['def build_device_name(mac):', '    ...', 'CUCM_HOST = "cucm-pub…"'], C.fillYellow);
  file(390, 0, 300, 'main.py', ['import cucm_tools', '', 'cucm_tools.build_device_name(…)'], C.fillGreen);
  e.push(arrow([[276, 80], [384, 80]], { stroke: PINK }));
  e.push(text(330, 50, 'import', { size: 20, stroke: PINK, align: 'center' }));
  e.push(text(345, 160, 'same folder: Python finds the file by its name', { size: 16, stroke: C.gray, align: 'center' }));
  save(D + 'modules-import.excalidraw', e);
}
// python layers
{
  const e = [];
  e.push(rect(0, 0, 600, 230, { fill: C.fillBlue, round: true }));
  e.push(text(18, 24, 'PyPI packages  ·  pip install', { size: 19, stroke: C.blue, middle: true }));
  e.push(text(582, 24, 'requests  zeep  lxml', { size: 17, align: 'right', middle: true }));
  e.push(rect(24, 50, 552, 160, { fill: C.fillYellow, round: true }));
  e.push(text(42, 74, 'standard library  ·  import', { size: 19, stroke: '#e8590c', middle: true }));
  e.push(text(558, 74, 'json  csv  time  datetime', { size: 17, align: 'right', middle: true }));
  e.push(rect(48, 100, 504, 90, { fill: C.fillGreen, round: true }));
  e.push(text(66, 126, 'built-ins  ·  always there', { size: 19, stroke: C.green, middle: true }));
  e.push(text(300, 162, 'print  len  int  str  open  range', { size: 17, align: 'center', middle: true }));
  save(D + 'python-layers.excalidraw', e);
}
// __name__ main
{
  const e = [];
  const W1 = measure('python cucm_tools.py', 17) + 26, W2 = measure('__name__ == "cucm_tools"', 17) + 26;
  const row = (y, cmd, val, res, col) => {
    e.push(box(0, y, W1, 46, cmd, { fill: '#e9ecef', size: 17 }));
    e.push(arrow([[W1 + 6, y + 23], [W1 + 60, y + 23]]));
    e.push(box(W1 + 66, y, W2, 46, val, { fill: C.fillBlue, round: true, size: 17 }));
    const x = W1 + 66 + W2;
    e.push(arrow([[x + 6, y + 23], [x + 60, y + 23]], { stroke: col }));
    e.push(text(x + 68, y + 23, res, { size: 17, stroke: col, middle: true }));
  };
  row(0, 'python cucm_tools.py', '__name__ == "__main__"', 'test block runs', C.green);
  row(80, 'import cucm_tools', '__name__ == "cucm_tools"', 'test block skipped', C.red);
  save(D + 'name-main.excalidraw', e);
}
