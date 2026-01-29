let salario = Number (prompt("salario"));
let aluguel = Number (prompt ("aluguel"));
let alimentacao = Number (prompt ("alimentacao"));
let lazer = Number (prompt ("lazer"));

totaldespesa = (aluguel + alimentacao + lazer);
saldo = (salario - totaldespesa);

if (saldo >0){
    alert(`seu saldo é positivo: ${saldo} `)
}
else if (saldo == 0){
    alert (`seu saldo está no limite: ${saldo}`)
}
else if (saldo < 0) {
    alert(`seu saldo é negativo: ${saldo}`)
}
else{
    alert('invalido')
}

