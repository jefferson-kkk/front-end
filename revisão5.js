let agendar_horarios = [8, 12, 25, 15, 2, 20];

for (let i = 0; i < agendar_horarios.length; i++){
    let horario = agendar_horarios[i];

    if (horario >= 0 && horario <= 23){
        alert(`compromisso agendado as ${horario}h`);
    }
     else {
    alert(`Atenção: O horário ${horario} é inválido!`);
    }
}

