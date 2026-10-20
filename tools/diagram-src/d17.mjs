import { C, text, rect, arrow, box, save } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;
const RED = '#ffc9c9';
// secrets flow
{
  const e = [];
  e.push(text(110, 0, 'hard-coded', { size: 19, stroke: C.red, align: 'center' }));
  e.push(box(0, 30, 220, 50, 'password = "Cisco123!"', { fill: RED, size: 17 }));
  ['git repo', 'email / chat', 'screen share'].forEach((t, i) => {
    const x = 20 + i * 90;
    e.push(arrow([[110, 86], [x + 20, 126]], { stroke: C.red }));
    e.push(text(x + 20, 132 + (i % 2) * 24, t, { size: 16, stroke: C.red, align: 'center' }));
  });
  const X = 320;
  e.push(text(X + 120, 0, 'kept outside the code', { size: 19, stroke: C.green, align: 'center' }));
  ['getpass() prompt', 'environment variable', '.env file'].forEach((t, i) => e.push(box(X, 30 + i * 52, 170, 40, t, { fill: C.fillGreen, size: 16 })));
  e.push(box(X + 220, 72, 100, 56, 'script', { fill: C.fillBlue, round: true, size: 19 }));
  [50, 102, 154].forEach((y) => e.push(arrow([[X + 176, y], [X + 214, 100]], { stroke: C.green })));
  e.push(text(X + 270, 146, 'reads at run time', { size: 15, stroke: C.gray, align: 'center' }));
  save(D + 'secrets-flow.excalidraw', e);
}
// dotenv flow
{
  const e = [];
  e.push(rect(0, 0, 220, 110, { fill: '#e9ecef' }));
  e.push(text(12, 18, '.env', { size: 19, middle: true }));
  ['AXL_USER=axl_svc', 'AXL_PASSWORD=****', 'WEBEX_TOKEN=****'].forEach((l, i) => e.push(text(12, 46 + i * 22, l, { size: 15, middle: true })));
  e.push(arrow([[226, 55], [336, 55]])); e.push(text(281, 22, 'load_dotenv()', { size: 15, stroke: C.green, align: 'center' }));
  e.push(box(342, 30, 140, 50, 'os.environ', { fill: C.fillYellow, round: true, size: 18 }));
  e.push(arrow([[488, 55], [548, 55]]));
  e.push(box(554, 30, 100, 50, 'script', { fill: C.fillBlue, round: true, size: 18 }));
  e.push(arrow([[110, 116], [110, 170]], { stroke: C.red }));
  e.push(text(122, 140, '.gitignore', { size: 16, stroke: C.red }));
  e.push(box(40, 176, 140, 44, 'git repo', { fill: RED, size: 17, stroke: C.red, textColor: C.red }));
  e.push(text(196, 198, '.env never reaches git;\n.env.example does, with fake values', { size: 15, stroke: C.gray, middle: true }));
  save(D + 'dotenv-flow.excalidraw', e);
}
