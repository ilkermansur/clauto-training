import { C, text, box, arrow, save } from '../exlib.mjs';

save('hello-flow', [
  box(0, 20, 150, 56, 'script', { fill: C.fillYellow, round: true }),
  arrow([[156, 48], [256, 48]], { stroke: C.green }),
  text(206, 0, 'request', { size: 16, stroke: C.green, align: 'center' }),
  box(262, 20, 170, 56, 'server', { fill: C.fillBlue, round: true }),
]);
