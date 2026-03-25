let today = new Date('2025/1/20');
let eventday = new Date('3000/9/10');

let time = (eventday - today);
let day = ( 24 * 60 * 60 * 1000 );

let conversion = Math.ceil(time / day);
alert(`faltam ${conversion} dias para o evento`);
