import { C, text, rect, arrow, box, save } from '../exlib.mjs';
const D = new URL('../../diagrams/', import.meta.url).pathname;
const PINK = '#c2255c', GR = '#e9ecef', RED = '#ffc9c9';
// netmiko ssh
{
  const e = [];
  e.push(box(0, 50, 130, 60, 'script', { fill: C.fillYellow, round: true, size: 19 }));
  e.push(arrow([[136, 66], [276, 66]], { stroke: C.green })); e.push(text(206, 38, 'send_command()', { size: 15, stroke: C.green, align: 'center' }));
  e.push(arrow([[276, 96], [136, 96]], { stroke: C.blue })); e.push(text(206, 104, 'output (str)', { size: 15, stroke: C.blue, align: 'center' }));
  e.push(rect(282, 30, 200, 100, { fill: GR, round: true }));
  e.push(text(382, 54, 'cube-01.clauto.lab', { size: 17, align: 'center', middle: true }));
  e.push(text(382, 84, 'cube-01# show …', { size: 15, align: 'center', middle: true }));
  e.push(text(382, 110, 'SSH, port 22', { size: 14, stroke: C.gray, align: 'center', middle: true }));
  e.push(text(240, 158, 'Netmiko types the command, waits for the prompt, returns the text', { size: 15, stroke: C.gray, align: 'center' }));
  save(D + 'netmiko-ssh.excalidraw', e);
}
// parsing
{
  const e = [];
  e.push(rect(0, 0, 240, 120, { fill: GR, round: true }));
  ['SIP call-legs: 4', 'H323 call-legs: 0', 'Total call-legs: 4'].forEach((t, i) => e.push(text(14, 26 + i * 32, t, { size: 16, middle: true, stroke: i === 2 ? C.green : C.ink })));
  e.push(arrow([[246, 30], [366, 30]], { stroke: C.gray })); e.push(text(306, -14, 'by position', { size: 15, stroke: C.red, align: 'center' }));
  e.push(box(372, 8, 220, 44, 'breaks on new IOS', { fill: RED, size: 16 }));
  e.push(arrow([[246, 90], [366, 90]], { stroke: C.green })); e.push(text(306, 104, 'by label (regex)', { size: 14, stroke: C.green, align: 'center' }));
  e.push(box(372, 68, 220, 44, 'Total call-legs = 4', { fill: C.fillGreen, size: 16 }));
  e.push(text(296, 150, 'TextFSM templates turn known commands into a list of dicts', { size: 15, stroke: C.gray, align: 'center' }));
  save(D + 'netmiko-parse.excalidraw', e);
}
// config set
{
  const e = [];
  e.push(rect(0, 0, 250, 112, { fill: C.fillYellow, round: true }));
  e.push(text(14, 20, 'commands = [', { size: 16, middle: true }));
  e.push(text(30, 48, '"dial-peer voice 9000 voip",', { size: 15, middle: true }));
  e.push(text(30, 74, '"no shutdown",', { size: 15, middle: true }));
  e.push(text(14, 98, ']', { size: 16, middle: true }));
  e.push(arrow([[256, 56], [376, 56]])); e.push(text(316, 34, 'send_config_set', { size: 14, stroke: C.green, align: 'center' }));
  const steps = ['configure terminal', 'your lines', 'end'];
  steps.forEach((t, i) => e.push(box(382, i * 40, 180, 34, t, { fill: i === 1 ? C.fillGreen : GR, size: 15 })));
  e.push(arrow([[568, 56], [618, 56]])); e.push(box(624, 34, 120, 44, 'save_config()', { fill: C.fillBlue, size: 15 }));
  e.push(text(470, 140, 'enter and leave config mode are added for you', { size: 15, stroke: C.gray, align: 'center' }));
  save(D + 'netmiko-config.excalidraw', e);
}
// monitor loop
{
  const e = [];
  e.push(box(0, 60, 140, 50, 'every 60 s', { fill: '#fcc2d7', round: true, size: 17 }));
  e.push(arrow([[146, 85], [196, 85]]));
  e.push(box(202, 20, 170, 44, 'RIS: agents up?', { fill: C.fillBlue, size: 16 }));
  e.push(box(202, 106, 170, 44, 'CUBE: call count', { fill: GR, size: 16 }));
  e.push(arrow([[378, 42], [448, 80]])); e.push(arrow([[378, 128], [448, 92]]));
  e.push(box(454, 62, 120, 46, 'decide', { fill: C.fillYellow, size: 17 }));
  e.push(arrow([[580, 85], [630, 85]], { stroke: C.red }));
  e.push(box(636, 52, 170, 66, 'enable alternate\nannouncement', { fill: RED, size: 15 }));
  e.push(arrow([[70, 116], [70, 170], [720, 170], [720, 124]], { stroke: C.gray, style: 'dashed' }));
  e.push(text(395, 182, 'log every action with a timestamp', { size: 15, stroke: C.gray, align: 'center' }));
  save(D + 'netmiko-monitor.excalidraw', e);
}
