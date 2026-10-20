import { C, text, rect, arrow, box, save } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;
const els = [];
// objects (boxes)
els.push(box(170, 60, 190, 100, '"1001"', { fill: C.fillYellow, round: true, size: 30 }));
els.push(text(350, 132, 'str', { size: 18, stroke: C.green, align: 'right' }));
els.push(text(265, 168, 'id 4372019504', { size: 17, stroke: C.gray, align: 'center' }));
els.push(box(450, 60, 190, 100, '"1002"', { fill: C.fillBlue, round: true, size: 30 }));
els.push(text(630, 132, 'str', { size: 18, stroke: C.green, align: 'right' }));
els.push(text(545, 168, 'id 4372020016', { size: 17, stroke: C.gray, align: 'center' }));
// labels (names)
els.push(box(0, 90, 110, 42, 'backup', { size: 22 }));
els.push(arrow([[114, 111], [164, 111]]));
els.push(box(355, -40, 80, 42, 'dn', { size: 22 }));
els.push(arrow([[370, 4], [300, 54]], { stroke: C.gray, style: 'dashed' }));
els.push(arrow([[420, 4], [495, 54]]));
els.push(text(300, 0, 'before', { size: 16, stroke: C.gray, align: 'right' }));
els.push(text(470, 0, 'after', { size: 16, stroke: C.green }));
els.push(text(405, 205, 'dn = "1002" moves the label,\nthe "1001" box stays', { size: 20, stroke: C.red, align: 'center' }));
save(D + 'variables-labels.excalidraw', els);
