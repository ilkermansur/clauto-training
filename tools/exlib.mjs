// Helpers for authoring .excalidraw files from code.
// Write a small script, e.g. tools/diagram-src/my-diagram.mjs:
//
//   import { C, text, box, arrow, save } from '../exlib.mjs';
//   save('my-diagram', [box(0, 0, 160, 56, 'CUCM', { fill: C.fillBlue, round: true }),
//                       arrow([[166, 28], [260, 28]])]);
//
// Run: node tools/diagram-src/my-diagram.mjs && cd tools && npm run diagrams
// The .excalidraw file stays editable in excalidraw.com / VS Code.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import * as fontkit from 'fontkit';

const here = path.dirname(fileURLToPath(import.meta.url));
const DIAGRAMS = path.join(here, '..', 'diagrams');
const FONT = fontkit.openSync(path.join(here, '..', 'fonts', 'Excalifont-Regular.ttf'));

let n = 0;
const id = () => 'el' + Date.now().toString(36) + (++n);
const seed = () => Math.floor(Math.random() * 2 ** 31);

export const C = {
  ink: '#1e1e1e', green: '#2f9e44', red: '#e03131', blue: '#1971c2', gray: '#868e96', pink: '#c2255c', orange: '#e8590c',
  fillBlue: '#a5d8ff', fillGreen: '#b2f2bb', fillGray: '#495057', fillYellow: '#ffec99', fillLime: '#d8f5a2',
  fillRed: '#ffc9c9', fillLight: '#e9ecef', fillPink: '#fcc2d7',
};

const base = (type, x, y, w, h, o = {}) => ({
  id: id(), type, x, y, width: w, height: h, angle: o.angle ?? 0,
  strokeColor: o.stroke ?? C.ink, backgroundColor: o.fill ?? 'transparent',
  fillStyle: o.fillStyle ?? 'hachure', strokeWidth: o.sw ?? 2, strokeStyle: o.style ?? 'solid',
  roughness: o.rough ?? 1, opacity: 100, groupIds: [], frameId: null,
  roundness: o.round ? { type: 3 } : null, seed: seed(), version: 1, versionNonce: seed(),
  isDeleted: false, boundElements: null, updated: Date.now(), link: null, locked: false,
});

/** Width of a (multi-line) string in Excalifont at size fs. Use it to size boxes. */
export const measure = (s, fs) => Math.max(...s.split('\n').map((l) => FONT.layout(l).advanceWidth / FONT.unitsPerEm * fs));

/** Text. o.align: left|center|right (x is the anchor), o.middle: y is the vertical centre. */
export function text(x, y, s, o = {}) {
  const fs = o.size ?? 20, lh = 1.25, w = measure(s, fs), h = s.split('\n').length * fs * lh;
  const align = o.align ?? 'left';
  const ax = align === 'center' ? x - w / 2 : align === 'right' ? x - w : x;
  return { ...base('text', ax, o.middle ? y - h / 2 : y, w, h, o), text: s, originalText: s, fontSize: fs,
    fontFamily: 5, textAlign: align, verticalAlign: 'top', containerId: null, lineHeight: lh, autoResize: true };
}
export const rect = (x, y, w, h, o = {}) => base('rectangle', x, y, w, h, o);
export const diamond = (x, y, w, h, o = {}) => base('diamond', x, y, w, h, o);
export const ellipse = (x, y, w, h, o = {}) => base('ellipse', x, y, w, h, o);

/** Arrow through absolute points. o.round: curved, o.line: no head, o.start/o.end: 'arrow'|'triangle'|null. */
export function arrow(pts, o = {}) {
  const [x0, y0] = pts[0]; const rel = pts.map(([x, y]) => [x - x0, y - y0]);
  const xs = rel.map((p) => p[0]), ys = rel.map((p) => p[1]);
  return { ...base(o.line ? 'line' : 'arrow', x0, y0, Math.max(...xs) - Math.min(...xs), Math.max(...ys) - Math.min(...ys), o),
    points: rel, lastCommittedPoint: null, startBinding: null, endBinding: null,
    startArrowhead: o.start ?? null, endArrowhead: o.line ? null : (o.end === undefined ? 'arrow' : o.end), elbowed: false };
}

/** Rectangle with a centred label. o.textColor, o.size. */
export function box(x, y, w, h, label, o = {}) {
  return [rect(x, y, w, h, o), text(x + w / 2, y + h / 2, label, { align: 'center', middle: true, size: o.size ?? 20, stroke: o.textColor ?? o.stroke })];
}

/** Save diagrams/<name>.excalidraw (name without extension, or a full path). */
export function save(name, elements) {
  const file = name.endsWith('.excalidraw') ? name : path.join(DIAGRAMS, name + '.excalidraw');
  fs.writeFileSync(file, JSON.stringify({ type: 'excalidraw', version: 2, source: 'https://excalidraw.com',
    elements: elements.flat(), appState: { viewBackgroundColor: '#ffffff', gridSize: null }, files: {} }, null, 2));
  console.log('wrote', path.relative(process.cwd(), file));
}
