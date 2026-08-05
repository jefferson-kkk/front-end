import React, { useState, useEffect } from "react";
import "./App.css";

function App() {
  // --- 1. ESTADOS PRINCIPAIS ---
  const [eventTitle, setEventTitle] = useState("");
  const [eventType, setEventType] = useState("Palestra");
  const [eventVagas, setEventVagas] = useState(10);
  const [eventList, setEventList] = useState([]);
  const [filter, setFilter] = useState("Todos");
  const [searchTerm, setSearchTerm] = useState("");
  const [showModal, setShowModal] = useState(false);

  // --- 2. PERSISTÊNCIA (LocalStorage) ---
  useEffect(() => {
    const savedEvents = localStorage.getItem("@eventpulse_data");
    if (savedEvents) setEventList(JSON.parse(savedEvents));
  }, []);

  useEffect(() => {
    localStorage.setItem("@eventpulse_data", JSON.stringify(eventList));
  }, [eventList]);

  // --- 3. FUNÇÕES DE AÇÃO ---
  const addEvent = (e) => {
    e.preventDefault();
    if (!eventTitle.trim()) return;

    const newEvent = {
      id: crypto.randomUUID(),
      title: eventTitle,
      type: eventType,
      vagas: Number(eventVagas),
      status: "Agendado",
      date: new Date().toLocaleDateString(),
    };

    setEventList([newEvent, ...eventList]);
    setEventTitle("");
  };

  const toggleStatus = (id) => {
    setEventList(eventList.map(evt => {
      if (evt.id === id) {
        const nextStatus = evt.status === "Agendado" ? "Em Andamento" :
                           evt.status === "Em Andamento" ? "Encerrado" : "Agendado";
        return { ...evt, status: nextStatus };
      }
      return evt;
    }));
  };
// inscrever alunos
  const inscreverAluno = (id) => {
    setEventList(eventList.map(evt => 
      evt.id === id && evt.vagas > 0 ? { ...evt, vagas: evt.vagas - 1 } : evt
    ));
  };

  const deleteEvent = (id) => {
    setEventList(eventList.filter(evt => evt.id !== id));   
  };


// exlui todas as tarefas
  const clearSchedule = () => {
    if (window.confirm("Deseja realmente limpar TODO o cronograma? Esta ação é irreversível.")) {
      setEventList([]);
      localStorage.removeItem("@eventpulse_data");
    }
  };

  // --- 4. LÓGICA DE FILTRAGEM E ORDENAÇÃO ---
  const filteredEvents = eventList
    .filter((evt) => {
      const matchStatus = filter === "Todos" ? true : evt.status === filter;
      const matchSearch = evt.title.toLowerCase().includes(searchTerm.toLowerCase());
      return matchStatus && matchSearch;
    })
    .sort((a, b) => {
      // Workshop sempre no topo (Peso 1), outros (Peso 0)
      const weightA = a.type === "Workshop" ? 1 : 0;
      const weightB = b.type === "Workshop" ? 1 : 0;
      return weightB - weightA;
    });

  return (
    <div className="app-container">
      <header>
        <h1>EventPulse</h1>
        <p>Gestão de Eventos Acadêmicos</p>
        <button onClick={clearSchedule} className="clear-btn">Limpar Cronograma</button>
      </header>

      {/* Formulário de Cadastro */}
      <section className="form-section">
        <form onSubmit={addEvent}>
          <input
            value={eventTitle}
            onChange={(e) => setEventTitle(e.target.value)}
            placeholder="Nome do evento..."
          />
          <select value={eventType} onChange={(e) => setEventType(e.target.value)}>
            <option value="Palestra">Palestra</option>
            <option value="Workshop">Workshop</option>
            <option value="Painel">Painel</option>
          </select>
          <select value={eventVagas} onChange={(e) => setEventVagas(e.target.value)}>
            <option value={10}>10 Vagas</option>
            <option value={30}>30 Vagas</option>
            <option value={50}>50 Vagas</option>
          </select>
          <button type="submit">Agendar</button>
        </form>
      </section>

      {/* Busca e Filtros */}
      <section className="filter-section">
        <input 
          type="text" 
          placeholder="Pesquisar por título..." 
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="search-bar"
        />
        <div className="filter-btns">
          {["Todos", "Agendado", "Em Andamento", "Encerrado"].map((f) => (
            <button
              key={f}
              className={filter === f ? "active" : ""}
              onClick={() => setFilter(f)}
            >
              {f}
            </button>
          ))}
        </div>
      </section>
      

      {/* Listagem de Eventos */}
      <main className="event-grid">
        {filteredEvents.map((item) => (
          <div key={item.id} className={`event-card ${item.type.toLowerCase()} ${item.status.toLowerCase().replace(" ", "-")}`}>
            <div className="event-content">
              <h3>{item.title}</h3>
              <span className="event-tag">{item.type}</span>
              <span className="vagas-count">Vagas restantes: <strong>{item.vagas}</strong></span>
              <small>Data: {item.date}</small>
            </div>
            
            <div className="event-actions">
              <button onClick={() => toggleStatus(item.id)} className="status-btn">
                {item.status === "Agendado" ? "Iniciar" : item.status === "Em Andamento" ? "Encerrar" : "Reiniciar"}
              </button>
              
              <button 
                onClick={() => inscreverAluno(item.id)} 
                disabled={item.vagas === 0}
                className="enroll-btn"
              >
                {item.vagas > 0 ? "Inscrever Aluno" : "Esgotado"}
              </button>

              <button onClick={() => deleteEvent(item.id)} className="delete">Remover</button>
            </div>
          </div>
        ))}
      </main>

      {/* Botão Flutuante (agora o ícone vem direto do CSS) */}
      <button className="fab-button" onClick={() => setShowModal(true)}></button>

      {/* Modal de Alterações */}
      {showModal && (
        <div className="modal-overlay">
          <div className="modal-content">
            <h2>Alterações Realizadas</h2>
            <ul>
              <li><strong>1. Ordenação:</strong> Workshops fixados no topo.</li>
              <li><strong>2. Busca:</strong> Filtro em tempo real por título.</li>
              <li><strong>3. Vagas:</strong> Sistema de inscrição com limite numérico.</li>
              <li><strong>4. Limpeza:</strong> Botão global com confirmação de segurança.</li>
              <li><strong>5. Estética:</strong> Layout adaptativo e botões dinâmicos.</li>
            </ul>
            <button onClick={() => setShowModal(false)}>Fechar</button>
          </div>
        </div>
      )}
    </div>
  );
}

export default App;