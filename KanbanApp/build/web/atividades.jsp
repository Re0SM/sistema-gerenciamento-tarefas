<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gerenciador de Tarefas</title>

    <!-- Estilos CSS -->
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: flex-start;
            flex-direction: column;
            min-height: 100vh; 
            margin: 0;
            background-color: #f7f7f7;
            overflow-x: hidden; 
        }

        
        header {
            background-color: #1E3A8A;
            color: white;
            width: 100%;
            text-align: center;
            padding: 20px 0;
            font-size: 2rem;
            margin-bottom: 20px;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 10;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        
        .add-task {
            background-color: #4CAF50;
            color: white;
            padding: 8px 15px;
            width: auto;
            border: none;
            cursor: pointer;
            border-radius: 5px;
            font-size: 1rem;
            margin-left: 20px; 
        }

        .add-task:hover {
            background-color: #45a049;
        }

        .kanban-board {
            display: flex;
            gap: 20px;
            padding: 20px;
            justify-content: center; 
            width: 100%;
            margin-top: 120px; 
        }

        .column {
            background-color: #fff;
            border-radius: 8px;
            width: 250px;
            padding: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            min-height: 300px;
            display: flex;
            flex-direction: column;
            gap: 10px;
            position: relative;
            overflow-y: auto; 
            height: auto; 
            max-height: none; 
        }

        .column h2 {
            text-align: center;
            margin-bottom: 10px;
            font-size: 1.2rem;
        }

        .task {
            background-color: #f2f2f2;
            padding: 10px;
            margin: 10px 0;
            border-radius: 5px;
            cursor: pointer;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            transition: background-color 0.3s ease;
            z-index: 1;
            position: relative;
            margin-bottom: 10px; 
        }

        .task:hover {
            background-color: #e0e0e0;
        }

        .task input, .task textarea {
            border: none;
            background: transparent;
            width: 100%;
            font-size: 1rem;
            resize: vertical; 
        }

        .task button {
            background-color: #f44336;
            color: white;
            border: none;
            padding: 3px 6px; 
            cursor: pointer;
            margin-top: 5px;
            width: 25px;
            height: 25px;
            border-radius: 5px;
            position: absolute;
            top: 5px;
            right: 5px;
            display: block; 
        }

        .task button:hover {
            background-color: #e53935;
        }

        .column.dragover {
            background-color: #e8f7e8;
        }

        .task.dragging {
            opacity: 0.5;
            z-index: 10;
        }

        /* Cores das tarefas conforme o status */
        .todo-task {
            background-color: #ffcccb; /* Vermelho */
        }

        .inprogress-task {
            background-color: #ffeb3b; /* Amarelo */
        }

        .done-task {
            background-color: #81c784; /* Verde */
        }

    </style>

</head>
<body>

    <!-- Cabeçalho -->
    <header>
        <div>Gerenciador de Tarefas</div>
        <!-- Botão Adicionar Tarefa no Cabeçalho -->
        <button class="add-task" onclick="addTask('todo')">Adicionar Tarefa</button>
    </header>

    <div class="kanban-board">
        <!-- To Do Column -->
        <div class="column" id="todo" ondrop="drop(event)" ondragover="allowDrop(event)">
            <h2>Tarefas a Fazer</h2>
            <div id="todo-tasks"></div>
        </div>

        <!-- In Progress Column -->
        <div class="column" id="inProgress" ondrop="drop(event)" ondragover="allowDrop(event)">
            <h2>Em Andamento</h2>
            <div id="inProgress-tasks"></div>
        </div>

        <!-- Done Column -->
        <div class="column" id="done" ondrop="drop(event)" ondragover="allowDrop(event)">
            <h2>Concluídas</h2>
            <div id="done-tasks"></div>
        </div>
    </div>

    <!-- Script JavaScript -->
    <script>
        let currentTaskId = 0;
        let currentTaskElement = null;

        // Função para adicionar uma tarefa
        function addTask(column) {
            const taskContainer = document.createElement('div');
            taskContainer.classList.add('task', 'todo-task');
            taskContainer.setAttribute('data-id', currentTaskId);
            taskContainer.setAttribute('draggable', true);
            taskContainer.setAttribute('ondragstart', 'drag(event)');
            taskContainer.setAttribute('ondragend', 'dragEnd(event)');
            taskContainer.setAttribute('ondblclick', 'editTask(event)');

            const taskTitle = document.createElement('input');
            taskTitle.placeholder = 'Digite a tarefa...';
            taskTitle.classList.add('task-title');

            const taskDescription = document.createElement('textarea');
            taskDescription.placeholder = 'Descrição da tarefa...';

            const deleteButton = document.createElement('button');
            deleteButton.innerHTML = '<span class="delete-icon">🗑️</span>';
            deleteButton.onclick = (event) => {
                event.stopPropagation(); 
                deleteTask(taskContainer);
            };

            taskContainer.appendChild(taskTitle);
            taskContainer.appendChild(taskDescription);
            taskContainer.appendChild(deleteButton);

            
            document.getElementById(column + '-tasks').appendChild(taskContainer);

            currentTaskId++;
        }

        
        function deleteTask(taskContainer) {
            taskContainer.remove();
        }

        
        function allowDrop(event) {
            event.preventDefault();
            event.target.classList.add('dragover');
        }

        
        function drop(event) {
            event.preventDefault();
            event.target.classList.remove('dragover');
            const task = document.querySelector('.dragging');
            if (task) {
                event.target.appendChild(task);
                task.classList.remove('dragging');

                
                if (currentTaskElement !== event.target) {
                    event.target.appendChild(currentTaskElement);
                }

                // Atualiza a cor conforme o novo status
                if (event.target.id === 'todo') {
                    task.classList.remove('inprogress-task', 'done-task');
                    task.classList.add('todo-task');
                } else if (event.target.id === 'inProgress') {
                    task.classList.remove('todo-task', 'done-task');
                    task.classList.add('inprogress-task');
                } else if (event.target.id === 'done') {
                    task.classList.remove('todo-task', 'inprogress-task');
                    task.classList.add('done-task');
                }
            }
        }

        
        function drag(event) {
            event.dataTransfer.setData('text', event.target.id);
            currentTaskElement = event.target;
            event.target.classList.add('dragging');
        }

        
        function dragEnd(event) {
            event.target.classList.remove('dragging');
        }

       
        function editTask(event) {
            const taskTitle = event.target.querySelector('input');
            const taskDescription = event.target.querySelector('textarea');
            taskTitle.disabled = !taskTitle.disabled;
            taskDescription.disabled = !taskDescription.disabled;
        }
    </script>

</body>
</html>
