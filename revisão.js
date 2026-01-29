
let horario = Number(prompt("Olá, qual o horário? (0 a 23)"));
let prioridade = Number(prompt("Qual o nível de prioridade? (1 a 10)"));

let turno = "";


if (horario < 0 || horario > 23) {
    alert("Horário inválido");
} else if (prioridade < 1 || prioridade > 10) {
    alert("Nível de prioridade inválida");
} else {


    if (horario >= 0 && horario <= 11) {
        turno = "Manhã";
        alert("Está de manhã");
    } else if (horario >= 12 && horario <= 17) {
        turno = "Tarde";
        alert("Está de tarde");
    } else {
        turno = "Noite";
        alert("Está de noite");
    }

    if (prioridade > 8 && turno !== "Noite") {
        alert("TAREFA CRÍTICA/URGENTE");
    } 
    else if (prioridade >= 7 && prioridade < 9 && turno !== "Noite") {
        alert("TAREFA IMPORTANTE");
    } 
    else if (turno === "Noite") {
        alert("TAREFA NÃO IMPORTANTE");
    }
}

