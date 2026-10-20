import { C, text, rect, arrow, box, ellipse, save, measure } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;
const label = (x, y, s, o = {}) => text(x, y, s, { size: 17, stroke: C.green, align: 'center', ...o });

// str clean pipeline
{
  const e = [];
  const items = [['"  sep0a1b2c3d4e5f \\n"', C.fillYellow], ['"sep0a1b2c3d4e5f"', C.fillYellow], ['"SEP0A1B2C3D4E5F"', C.fillGreen]];
  const ops = ['.strip()', '.upper()'];
  let x = 0;
  items.forEach(([t, f], i) => {
    const w = measure(t, 20) + 28;
    e.push(box(x, 30, w, 54, t, { fill: f, round: true, size: 20 }));
    x += w;
    if (i < 2) { e.push(arrow([[x + 6, 57], [x + 66, 57]])); e.push(label(x + 36, 2, ops[i])); x += 72; }
  });
  e.push(text(x / 2, 100, 'each method returns a new str, so calls can be chained', { size: 17, stroke: C.gray, align: 'center' }));
  save(D + 'str-clean.excalidraw', e);
}
// device prefix
{
  const e = [];
  e.push(box(0, 92, 150, 56, 'name[:3]', { fill: C.fillYellow, round: true, size: 21 }));
  const rows = [['SEP', 'desk phone'], ['CSF', 'Jabber for PC / Mac'], ['BOT', 'Jabber Android'], ['TCT', 'Jabber iPhone']];
  rows.forEach(([p, d], i) => {
    const y = 20 + i * 66;
    e.push(arrow([[156, 120], [226, y + 20]]));
    e.push(box(232, y, 80, 40, p, { fill: C.fillBlue, size: 20 }));
    e.push(text(326, y + 20, d, { size: 19, middle: true }));
  });
  save(D + 'device-prefix.excalidraw', e);
}
// split / join
{
  const e = [];
  e.push(box(0, 30, 290, 52, '"alice.smith,1001,DP_HQ"', { fill: C.fillYellow, round: true, size: 19 }));
  e.push(arrow([[296, 56], [376, 56]])); e.push(label(336, 0, '.split(",")'));
  const cells = [['"alice.smith"', 140], ['"1001"', 80], ['"DP_HQ"', 96]];
  let x = 382;
  for (const [v, w] of cells) { e.push(box(x, 30, w, 52, v, { fill: C.fillLime, size: 18 })); x += w; }
  e.push(arrow([[540, 90], [540, 150]])); e.push(label(548, 108, '" | ".join(...)', { align: 'left' }));
  e.push(box(382, 156, 316, 52, '"alice.smith | 1001 | DP_HQ"', { fill: C.fillYellow, round: true, size: 18 }));
  e.push(text(145, 104, 'str', { size: 17, stroke: C.gray, align: 'center' }));
  e.push(text(708, 40, 'list', { size: 17, stroke: C.gray }));
  e.push(text(708, 168, 'str', { size: 17, stroke: C.gray }));
  save(D + 'str-split-join.excalidraw', e);
}
// list ops
{
  const e = [];
  const X = 170;
  ['"1001"', '"1002"', '"1003"'].forEach((v, i) => e.push(box(X + i * 100, 70, 100, 50, v, { fill: C.fillLime, size: 20 })));
  e.push(box(0, 70, 100, 50, '"1000"', { style: 'dashed', stroke: C.gray, textColor: C.gray, size: 20 }));
  e.push(arrow([[104, 95], [164, 95]], { stroke: C.green })); e.push(label(134, 40, '.insert(0, x)'));
  e.push(box(540, 70, 100, 50, '"1004"', { style: 'dashed', stroke: C.gray, textColor: C.gray, size: 20 }));
  e.push(arrow([[536, 95], [476, 95]], { stroke: C.green })); e.push(label(506, 40, '.append(x)'));
  e.push(arrow([[420, 126], [420, 178]], { stroke: C.red })); e.push(label(430, 160, '.pop()  last item out', { stroke: C.red, align: 'left' }));
  e.push(arrow([[250, 4], [250, 20], [270, 40], [270, 62]], { stroke: C.red, round: true }));
  e.push(label(250, -22, '.remove("1002")', { stroke: C.red }));
  save(D + 'list-ops.excalidraw', e);
}
// sort vs sorted
{
  const e = [];
  const L = '["1003", "1001", "1002"]', S = '["1001", "1002", "1003"]';
  e.push(text(0, 0, 'sorted(dns)', { size: 20, stroke: C.green }));
  e.push(box(0, 30, 250, 48, L, { fill: C.fillYellow, round: true, size: 18 }));
  e.push(arrow([[256, 54], [326, 54]]));
  e.push(box(332, 30, 250, 48, S, { fill: C.fillGreen, round: true, size: 18 }));
  e.push(text(457, 86, 'new list, dns unchanged', { size: 16, stroke: C.green, align: 'center' }));
  e.push(text(0, 120, 'dns.sort()', { size: 20, stroke: C.green }));
  e.push(box(0, 150, 250, 48, S, { fill: C.fillGreen, round: true, size: 18 }));
  e.push(arrow([[60, 204], [70, 230], [180, 230], [190, 204]], { round: true, stroke: C.gray }));
  e.push(text(125, 236, 'same list, sorted in place', { size: 16, stroke: C.gray, align: 'center' }));
  e.push(text(300, 164, 'returns None!', { size: 20, stroke: C.red }));
  save(D + 'sort-vs-sorted.excalidraw', e);
}
// dict get
{
  const e = [];
  e.push(box(0, 58, 120, 56, 'phone', { fill: C.fillBlue, round: true, size: 22 }));
  e.push(arrow([[126, 74], [240, 30]], { stroke: C.red }));
  e.push(arrow([[126, 98], [240, 142]], { stroke: C.green }));
  e.push(text(250, 30, 'phone["css"]', { size: 20, middle: true }));
  e.push(box(420, 8, 150, 44, 'KeyError', { fill: '#ffc9c9', round: true, size: 20, stroke: C.red, textColor: C.red }));
  e.push(text(250, 142, 'phone.get("css", "CSS_Internal")', { size: 20, middle: true }));
  e.push(box(420, 172, 180, 44, '"CSS_Internal"', { fill: C.fillGreen, round: true, size: 19 }));
  e.push(arrow([[510, 154], [510, 168]], { stroke: C.green }));
  save(D + 'dict-get.excalidraw', e);
}
// axl nested
{
  const e = [];
  const rows = [
    [0, 'reply', null], [1, '"phone"', null], [2, '"name"', '"SEP0A1B2C3D4E5F"'], [2, '"lines"', null],
    [3, '"line"', '[0]'], [4, '"dirn"', null], [5, '"pattern"', '"1001"'],
  ];
  const H = 36, I = 44;
  rows.forEach(([lvl, k, v], i) => {
    const y = i * H, x = lvl * I;
    const last = i === rows.length - 1;
    const w = measure(k, 19) + 22;
    e.push(box(x, y, w, 28, k, { fill: last ? C.fillGreen : (lvl === 0 ? C.fillBlue : C.fillYellow), size: 19, rough: 0.8 }));
    if (v) e.push(text(x + w + 12, y + 14, v, { size: 19, middle: true, stroke: last ? C.green : C.ink }));
    if (lvl > 0) {
      let p = i - 1; while (rows[p][0] !== lvl - 1) p--;
      const px = (lvl - 1) * I + 14;
      e.push(arrow([[px, p * H + 30], [px, y + 14], [x - 3, y + 14]], { line: true, sw: 1.5, rough: 0.6 }));
    }
  });
  save(D + 'axl-nested.excalidraw', e);
}
// set subset
{
  const e = [];
  e.push(ellipse(0, 20, 400, 190, { fill: C.fillBlue }));
  e.push(text(200, -16, 'pts', { size: 20, stroke: C.blue, align: 'center' }));
  e.push(ellipse(30, 60, 190, 110, { fill: C.fillGreen }));
  e.push(text(125, 115, 'PT_Internal\nPT_Local', { size: 17, align: 'center', middle: true }));
  e.push(text(125, 176, 'required', { size: 16, stroke: C.green, align: 'center' }));
  e.push(text(300, 115, 'PT_Intl\nPT_Old', { size: 17, align: 'center', middle: true }));
  e.push(ellipse(450, 70, 150, 90, { fill: '#ffc9c9' }));
  e.push(text(525, 115, 'PT_Blocked', { size: 17, align: 'center', middle: true }));
  e.push(text(125, 222, 'required.issubset(pts)\n= True', { size: 16, stroke: C.green, align: 'center' }));
  e.push(text(525, 172, 'pts.isdisjoint(...)\n= True', { size: 16, stroke: C.red, align: 'center' }));
  save(D + 'set-subset.excalidraw', e);
}
// encode / decode
{
  const e = [];
  e.push(box(0, 50, 150, 60, '"café"', { fill: C.fillYellow, round: true, size: 24 }));
  e.push(text(75, 118, 'str', { size: 17, stroke: C.gray, align: 'center' }));
  e.push(box(330, 50, 200, 60, "b'caf\\xc3\\xa9'", { fill: '#e9ecef', round: true, size: 22 }));
  e.push(text(430, 118, 'bytes (UTF-8)', { size: 17, stroke: C.gray, align: 'center' }));
  e.push(arrow([[156, 62], [240, 30], [324, 62]], { round: true, stroke: C.green }));
  e.push(label(240, 0, '.encode()'));
  e.push(arrow([[324, 100], [240, 132], [156, 100]], { round: true, stroke: C.blue }));
  e.push(label(240, 140, '.decode()', { stroke: C.blue }));
  save(D + 'encode-decode.excalidraw', e);
}
