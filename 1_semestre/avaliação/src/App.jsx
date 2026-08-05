import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  // --- ESTADOS BÁSICOS ---
  const [taskText, setTaskText] = useState("");
  const [priority, setPriority] = useState("Baixa");
  const [taskList, setTaskList] = useState([]);
  const [filter, setFilter] = useState("Todas");
  const [searchTerm, setSearchTerm] = useState("");

  // --- ESTADOS DE EDIÇÃO (O seu 'pacote' de alteração) ---
  const [editingId, setEditingId] = useState(null);
  const [editTaskText, setEditTaskText] = useState("");
  const [editPriority, setEditPriority] = useState("Baixa");

  // --- CARREGAR/SALVAR DADOS ---
  useEffect(() => {
    const saved = localStorage.getItem("@taskflow_data");
    if (saved) setTaskList(JSON.parse(saved));
  }, []);

  useEffect(() => {
    localStorage.setItem("@taskflow_data", JSON.stringify(taskList));
  }, [taskList]);

  // --- FUNÇÕES DE AÇÃO ---
  const addTask = (e) => {
    e.preventDefault();
    if (!taskText.trim()) return;
    const newTask = {
      id: crypto.randomUUID(),
      text: taskText,
      priority: priority,
      completed: false,
      createdAt: new Date().toLocaleDateString()
    };
    setTaskList([newTask, ...taskList]);
    setTaskText("");
  };

  const deleteTask = (id) => {
    if (window.confirm('Tem certeza disso?')) {
      setTaskList(taskList.filter(t => t.id !== id));
    }
  };

  const toggleTask = (id) => {
    setTaskList(taskList.map(t => t.id === id ? { ...t, completed: !t.completed } : t));
  };

  // Funções para gerenciar o "Modo de Edição"
  const startEdit = (task) => {
    setEditingId(task.id);
    setEditTaskText(task.text);
    setEditPriority(task.priority);
  };

  const saveEdit = (id) => {
    setTaskList(taskList.map(t => 
      t.id === id ? { ...t, text: editTaskText, priority: editPriority } : t
    ));
    setEditingId(null); // Sai do modo de edição
  };

  // --- LÓGICA DE FILTRAGEM E ORDENAÇÃO ---
  const filteredTasks = taskList
    .filter(t => {
      const matchStatus = filter === "Todas" ? true : (filter === "Pendentes" ? !t.completed : t.completed);
      const matchSearch = t.text.toLowerCase().includes(searchTerm.toLowerCase());
      return matchStatus && matchSearch;
    })
    .sort((a, b) => {
      // Ordenação: Alta (3), Média (2), Baixa (1)
      const weights = { "Alta": 3, "Média": 2, "Baixa": 1 };
      return weights[b.priority] - weights[a.priority];
    });

  return (
    <div className="app-container">
      <header>
        <h1>TaskFlow</h1>
        <p>Gestão de Produtividade</p>
      </header>

      {/* Formulário de Criação */}
      <section className="form-section">
        <form onSubmit={addTask}>
          <input value={taskText} onChange={(e) => setTaskText(e.target.value)} placeholder="Nova tarefa..." />
          <select value={priority} onChange={(e) => setPriority(e.target.value)}>
            <option value="Baixa">Baixa</option>
            <option value="Média">Média</option>
            <option value="Alta">Alta</option>
          </select>
          <button type="submit">Criar</button>
        </form>
      </section>

      {/* Filtros e Busca */}
      <section className="filter-section">
        <input type="text" placeholder='Pesquisar...' value={searchTerm} onChange={(e) => setSearchTerm(e.target.value)} />
        {["Todas", "Pendentes", "Concluídas"].map(f => (
          <button key={f} className={filter === f ? "active" : ""} onClick={() => setFilter(f)}>{f}</button>
        ))}
      </section>

      {/* Lista de Tarefas */}
      <main className="task-grid">
        {filteredTasks.map(item => (
          <div key={item.id} className={`task-card ${item.priority.toLowerCase()} ${item.completed ? 'done' : ''}`}>
            
            {editingId === item.id ? (
              // VISÃO DE EDIÇÃO (Input + Select)
              <div className="edit-mode">
                <input value={editTaskText} onChange={(e) => setEditTaskText(e.target.value)} />
                <select value={editPriority} onChange={(e) => setEditPriority(e.target.value)}>
                  <option value="Baixa">Baixa</option>
                  <option value="Média">Média</option>
                  <option value="Alta">Alta</option>
                </select>
                <div className="task-actions">
                   <button onClick={() => saveEdit(item.id)}>Salvar</button>
                   <button onClick={() => setEditingId(null)}>Cancelar</button>
                </div>
              </div>
            ) : (
              // VISÃO NORMAL
              <>
                <div className="task-content">
                  <h3>{item.text}</h3>
                  <span>Prioridade: <strong>{item.priority}</strong></span>
                  <small>Criada em: {item.createdAt}</small>
                </div>
                <div className="task-actions">
                  <button onClick={() => toggleTask(item.id)}>{item.completed ? "Reabrir" : "Concluir"}</button>
                  <button onClick={() => startEdit(item)}>Editar</button>
                  <button onClick={() => deleteTask(item.id)} className="delete">Remover</button>
                </div>
              </>
            )}

          </div>
        ))}
      </main>
    </div>
  );
}

export default App;