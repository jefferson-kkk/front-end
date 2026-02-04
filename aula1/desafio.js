// let agendar_horarios = [8, 12, 25, 15, 2, 20];
// let horario_valido= false;
// let horario_lido = 0;

// for (let i = 0; i < agendar_horarios.length; i++){
//      if( agendar_horarios[i] ===  horario_lido && horario_lido >= 0 && horario_lido <=23 ){
//         horario_valido = true;
//         alert(`O horario ${horario_valido} é valido`)
//         break;
//      }
//  }


let agendar_horarios = [8, 12, 25, 15, 2, 20];
let horario_valido= 0;
let horario_invalido = 0;

for(const agendar of agendar_horarios ){
   
      if (agendar >= 0 && agendar <= 23){
        alert(`compromisso agendado as ${agendar}h`)
        horario_valido++;
    }
     else {
    alert(`Atenção: O horário ${agendar} é inválido!`)
      horario_invalido++;
    }
}