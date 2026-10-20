// Renders .excalidraw files to hand-drawn SVGs that Typst can embed.
// Usage: node excalidraw2svg.mjs <dir-or-file> [...]
// Text is emitted as <text> with the font-family name; Typst resolves it
// from --font-path ../fonts (Excalifont / Virgil).
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import rough from 'roughjs';
import * as fontkit from 'fontkit';

const here = path.dirname(fileURLToPath(import.meta.url));
const fontDir = path.join(here, '..', 'fonts');

const FAMILY = {
  1: 'Virgil', 5: 'Excalifont',
  2: 'Fira Sans', 6: 'Fira Sans', 7: 'Fira Sans',
  3: 'JetBrains Mono', 8: 'JetBrains Mono',
};
const METRIC_FONT = {
  Virgil: 'Virgil-Regular.ttf',
  Excalifont: 'Excalifont-Regular.ttf',
};
const metricCache = {};
function metrics(family) {
  if (!(family in metricCache)) {
    const file = METRIC_FONT[family];
    const f = file && fs.existsSync(path.join(fontDir, file))
      ? fontkit.openSync(path.join(fontDir, file)) : null;
    metricCache[family] = f
      ? { asc: f.ascent / f.unitsPerEm, desc: -f.descent / f.unitsPerEm, font: f }
      : { asc: 0.9, desc: 0.25 };
  }
  return metricCache[family];
}

const esc = (s) => String(s)
  .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

const gen = rough.generator();

function roughOpts(el) {
  const sw = el.strokeWidth ?? 2;
  const o = {
    seed: el.seed ?? 1,
    roughness: el.roughness ?? 1,
    strokeWidth: sw,
    stroke: el.strokeColor ?? '#1e1e1e',
    bowing: 1,
    fillWeight: sw / 2,
    hachureGap: sw * 4,
    preserveVertices: (el.roughness ?? 1) < 2,
    disableMultiStroke: el.strokeStyle && el.strokeStyle !== 'solid',
  };
  if (el.strokeStyle === 'dashed') o.strokeLineDash = [8, 8 + sw];
  if (el.strokeStyle === 'dotted') o.strokeLineDash = [1.5, 6 + sw];
  if (el.backgroundColor && el.backgroundColor !== 'transparent') {
    o.fill = el.backgroundColor;
    o.fillStyle = el.fillStyle ?? 'hachure';
  }
  return o;
}

function roundedRectPath(w, h, r) {
  return `M ${r} 0 L ${w - r} 0 Q ${w} 0, ${w} ${r} L ${w} ${h - r} Q ${w} ${h}, ${w - r} ${h} `
    + `L ${r} ${h} Q 0 ${h}, 0 ${h - r} L 0 ${r} Q 0 0, ${r} 0`;
}

// Tip + direction taken from the rendered (roughened) path, so the head
// follows the stroke the viewer actually sees.
function pathEnd(drawable, atEnd) {
  const ops = drawable.sets[0].ops;
  if (atEnd) {
    const last = [...ops].reverse().find((o) => o.op === 'bcurveTo' || o.op === 'lineTo');
    const d = last.data;
    return last.op === 'bcurveTo' ? [[d[4], d[5]], [d[2], d[3]]] : [[d[0], d[1]], null];
  }
  const mv = ops.find((o) => o.op === 'move').data;
  const first = ops.find((o) => o.op === 'bcurveTo' || o.op === 'lineTo');
  return [[mv[0], mv[1]], first.op === 'bcurveTo' ? [first.data[0], first.data[1]] : null];
}

function arrowhead(points, atEnd, sw, kind, line) {
  const n = points.length;
  let [tip, prev] = atEnd ? [points[n - 1], points[n - 2]] : [points[0], points[1]];
  const segLen = Math.hypot(tip[0] - prev[0], tip[1] - prev[1]) || 1;
  if (line) {
    const [t, c] = pathEnd(line, atEnd);
    tip = t;
    if (c && Math.hypot(t[0] - c[0], t[1] - c[1]) > 2) prev = c;
  }
  const dx = tip[0] - prev[0], dy = tip[1] - prev[1];
  const len = Math.hypot(dx, dy) || 1;
  const size = Math.min(15 + sw * 2, segLen * 0.6);
  const ang = Math.atan2(dy, dx);
  const spread = kind === 'triangle' ? 0.45 : 0.42;
  const p1 = [tip[0] - size * Math.cos(ang - spread), tip[1] - size * Math.sin(ang - spread)];
  const p2 = [tip[0] - size * Math.cos(ang + spread), tip[1] - size * Math.sin(ang + spread)];
  return { tip, p1, p2 };
}

function drawablesFor(el) {
  const o = roughOpts(el);
  const w = el.width, h = el.height;
  switch (el.type) {
    case 'rectangle':
      if (el.roundness) {
        const r = Math.min(w, h) * 0.25 > 32 ? 32 : Math.min(w, h) * 0.25;
        return [gen.path(roundedRectPath(w, h, r), o)];
      }
      return [gen.rectangle(0, 0, w, h, o)];
    case 'diamond':
      return [gen.polygon([[w / 2, 0], [w, h / 2], [w / 2, h], [0, h / 2]], o)];
    case 'ellipse':
      return [gen.ellipse(w / 2, h / 2, w, h, o)];
    case 'line':
    case 'arrow': {
      const pts = el.points;
      const lo = { ...o };
      if (el.type === 'arrow') { delete lo.fill; }
      const out = [];
      const curved = el.roundness && pts.length > 2;
      const stroke = curved ? gen.curve(pts, lo) : gen.linearPath(pts, lo);
      out.push(stroke);
      if (el.type === 'arrow') {
        const head = { ...lo, strokeLineDash: undefined, roughness: Math.min(lo.roughness, 0.6) };
        for (const [atEnd, kind] of [[true, el.endArrowhead], [false, el.startArrowhead]]) {
          if (!kind) continue;
          const { tip, p1, p2 } = arrowhead(pts, atEnd, o.strokeWidth, kind, stroke);
          if (kind === 'triangle') {
            out.push(gen.polygon([tip, p1, p2], { ...head, fill: o.stroke, fillStyle: 'solid' }));
          } else {
            out.push(gen.line(p1[0], p1[1], tip[0], tip[1], head));
            out.push(gen.line(p2[0], p2[1], tip[0], tip[1], head));
          }
        }
      }
      return out;
    }
    case 'freedraw': {
      const d = el.points.map((p, i) => `${i ? 'L' : 'M'} ${p[0]} ${p[1]}`).join(' ');
      return [{ raw: `<path d="${d}" fill="none" stroke="${o.stroke}" stroke-width="${o.strokeWidth}" stroke-linecap="round" stroke-linejoin="round"/>` }];
    }
    default:
      return [];
  }
}

function drawableToSvg(d) {
  if (d.raw) return d.raw;
  return gen.toPaths(d).map((p) => {
    const dash = d.options.strokeLineDash && p.fill === 'none' && p.stroke !== 'none'
      ? ` stroke-dasharray="${d.options.strokeLineDash.join(' ')}"` : '';
    return `<path d="${p.d}" stroke="${p.stroke}" stroke-width="${p.strokeWidth}" fill="${p.fill ?? 'none'}"`
      + ` stroke-linecap="round" stroke-linejoin="round"${dash}/>`;
  }).join('');
}

function textSvg(el) {
  const family = FAMILY[el.fontFamily] ?? 'Excalifont';
  const fs_ = el.fontSize ?? 20;
  const lh = (el.lineHeight ?? 1.25) * fs_;
  const m = metrics(family);
  const glyphH = (m.asc + m.desc) * fs_;
  const anchor = { left: 'start', center: 'middle', right: 'end' }[el.textAlign ?? 'left'];
  const ax = { left: 0, center: el.width / 2, right: el.width }[el.textAlign ?? 'left'];
  const lines = String(el.text ?? '').split('\n');
  if (m.font) {
    const missing = [...new Set([...String(el.text ?? '')].filter((c) => c.trim() && !m.font.hasGlyphForCodePoint(c.codePointAt(0))))];
    if (missing.length) console.warn(`  ! ${family} has no glyph for ${missing.join(' ')} in "${el.text}" (text falls back to another font)`);
  }
  return lines.map((line, i) => {
    const y = i * lh + (lh - glyphH) / 2 + m.asc * fs_;
    return `<text x="${ax}" y="${y.toFixed(2)}" font-family="${family}" font-size="${fs_}"`
      + ` fill="${el.strokeColor ?? '#1e1e1e'}" text-anchor="${anchor}" xml:space="preserve">${esc(line)}</text>`;
  }).join('');
}

function bounds(els) {
  let x1 = Infinity, y1 = Infinity, x2 = -Infinity, y2 = -Infinity;
  for (const el of els) {
    if (el.points) {
      for (const [px, py] of el.points) {
        x1 = Math.min(x1, el.x + px); y1 = Math.min(y1, el.y + py);
        x2 = Math.max(x2, el.x + px); y2 = Math.max(y2, el.y + py);
      }
    } else {
      x1 = Math.min(x1, el.x); y1 = Math.min(y1, el.y);
      x2 = Math.max(x2, el.x + el.width); y2 = Math.max(y2, el.y + el.height);
    }
  }
  return { x1, y1, x2, y2 };
}

function render(scene) {
  const els = scene.elements.filter((e) => !e.isDeleted);
  const pad = 12;
  const b = bounds(els);
  const W = b.x2 - b.x1 + pad * 2, H = b.y2 - b.y1 + pad * 2;
  const body = els.map((el) => {
    const tx = el.x - b.x1 + pad, ty = el.y - b.y1 + pad;
    const rot = el.angle ? ` rotate(${(el.angle * 180) / Math.PI} ${el.width / 2} ${el.height / 2})` : '';
    const op = el.opacity != null && el.opacity !== 100 ? ` opacity="${el.opacity / 100}"` : '';
    const inner = el.type === 'text' ? textSvg(el) : drawablesFor(el).map(drawableToSvg).join('');
    return `<g transform="translate(${tx.toFixed(2)} ${ty.toFixed(2)})${rot}"${op}>${inner}</g>`;
  }).join('\n');
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${W.toFixed(0)} ${H.toFixed(0)}"`
    + ` width="${W.toFixed(0)}" height="${H.toFixed(0)}">\n${body}\n</svg>\n`;
}

const targets = process.argv.slice(2);
if (!targets.length) { console.error('usage: node excalidraw2svg.mjs <dir|file> ...'); process.exit(1); }
for (const t of targets) {
  const files = fs.statSync(t).isDirectory()
    ? fs.readdirSync(t).filter((f) => f.endsWith('.excalidraw')).map((f) => path.join(t, f))
    : [t];
  for (const f of files) {
    const out = f.replace(/\.excalidraw$/, '.svg');
    fs.writeFileSync(out, render(JSON.parse(fs.readFileSync(f, 'utf8'))));
    console.log('✓', path.relative(process.cwd(), out));
  }
}
