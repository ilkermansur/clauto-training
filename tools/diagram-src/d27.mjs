import { C, text, rect, arrow, box, save } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;
const PINK = '#c2255c', GR = '#e9ecef';
const e = [];
e.push(text(150, 0, 'Python fundamentals', { size: 18, stroke: C.green, align: 'center' }));
['types · if · loops', 'functions · modules', 'exceptions · files', 'classes · secrets'].forEach((t, i) =>
  e.push(box(40, 30 + i * 52, 220, 42, t, { fill: C.fillYellow, round: true, size: 16 })));
e.push(arrow([[266, 128], [336, 128]], { stroke: PINK }));
e.push(text(301, 100, 'applied to', { size: 14, stroke: PINK, align: 'center' }));
e.push(text(500, 0, 'Collaboration APIs', { size: 18, stroke: C.blue, align: 'center' }));
[['AXL', 'configure CUCM'], ['RisPort70', 'live status'], ['Webex / CMS REST', 'cloud + meetings'], ['Netmiko · CGI', 'CUBE + phones']].forEach(([a, b], i) => {
  e.push(box(342, 30 + i * 52, 170, 42, a, { fill: C.fillBlue, round: true, size: 16 }));
  e.push(text(524, 51 + i * 52, b, { size: 15, stroke: C.gray, middle: true }));
});
e.push(rect(30, 250, 640, 50, { fill: C.fillGreen, round: true }));
e.push(text(350, 275, 'read  >  validate  >  dry run  >  apply  >  verify  >  record', { size: 17, align: 'center', middle: true }));
save(D + 'course-map.excalidraw', e);
