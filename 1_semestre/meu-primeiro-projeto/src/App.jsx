import './App.css'

function Saudacao() {
  return (
    <div style={{ 
      backgroundColor: '#FFFAF0', padding: '10px', borderRadius: '8px', marginBottom: '10px' 
    }}>
      <h2 style={{ color: 'blue' }}>Olá, professor!</h2> 
      <p>Este componente foi criado separadamente</p>
    </div>
  );
}

// Criando o componente Secao
// Criando o componente Secao
function Secao({Titulo, Subtitulo}) {
  return (
    <div style={{backgroundColor:'#FFFAF0', padding: '10px', borderRadius: '8px', marginBottom: '10px' }}>
      <h2 style={{ color: 'green' }}>Está pronto para uma aventura no framework?</h2>
      <h3>olk bixo ta pegando fogo</h3>
      <h3>{Titulo}</h3>
      <p>{Subtitulo}</p>
      <p>tenha um bom dia meu heroi</p>
      
    </div>
  );
}


function App() {
  return (
    <div>
      <h1>Olá, React!</h1>
      <p>Estou alterando meu primeiro componente.</p>

      <div style={{ padding: '20px' }}>
        <h1>Minha primeira Aula de React</h1>
        <hr />
        
        <Saudacao />
        <Saudacao />
        <Saudacao />
      <hr />
      
        {/* CHAMANDO A SEÇÃO AQUI PARA ELA APARECER */}
        <Secao /> 
        <Secao Titulo="kkk" Subtitulo="ta complicado"/>
        

        
      </div>
    </div>
  );
}

export default App;