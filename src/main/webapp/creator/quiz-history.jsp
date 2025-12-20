<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.quizplatform.model.User" %>

<%
    // Prevent caching after logout
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    User user = (User) session.getAttribute("user");
    if (user == null || 
        (!"creator".equalsIgnoreCase(user.getRole()) && !"admin".equalsIgnoreCase(user.getRole()))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Quiz History - Quiz Platform</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">

    <style>
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.4);
        }
        .modal-content {
            background-color: white;
            margin: 5% auto;
            padding: 30px;
            border-radius: 10px;
            width: 90%;
            max-width: 800px;
            max-height: 80vh;
            overflow-y: auto;
            box-shadow: 0 4px 20px rgba(0,0,0,0.3);
        }
        .close {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
        }
        .close:hover {
            color: #000;
        }
        .question-item {
            background: #f8f9fa;
            padding: 15px;
            margin-bottom: 15px;
            border-radius: 5px;
            border-left: 4px solid #667eea;
        }
    </style>
</head>

<body>

<nav class="navbar">
    <h1>🎓 Quiz Platform - Creator</h1>
    <div class="user-info">
        <span>Welcome, <%= user.getFullName() %></span>
        <a href="${pageContext.request.contextPath}/creator/dashboard.jsp">Dashboard</a>
        <a href="${pageContext.request.contextPath}/creator/create-quiz.jsp">Create Quiz</a>
        <a href="${pageContext.request.contextPath}/creator/quiz-history.jsp">My Quizzes</a>
        <a href="${pageContext.request.contextPath}/LogoutServlet">Logout</a>
    </div>
</nav>

<div class="container">
    <h2 style="margin-bottom: 30px;">My Quiz History</h2>

    <div id="message"></div>

    <div id="quizzesContainer">
        <p>Loading your quizzes...</p>
    </div>
</div>

<!-- Questions Modal -->
<div id="questionsModal" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeModal()">&times;</span>
        <h3 id="modalTitle"></h3>
        <div id="questionsContent"></div>
    </div>
</div>

<script>
window.onload = function () {
    loadMyQuizzes();
};

function loadMyQuizzes() {
    fetch('${pageContext.request.contextPath}/QuizServlet?action=myQuizzes')
        .then(res => res.json())
        .then(displayQuizzes)
        .catch(() => showMessage('Error loading quizzes', 'danger'));
}

function displayQuizzes(quizzes) {
    if (quizzes.length === 0) {
        document.getElementById('quizzesContainer').innerHTML = `
            <div style="text-align:center;padding:50px;background:white;border-radius:10px;">
                <h3>You haven't created any quizzes yet</h3>
                <p style="margin:20px 0;color:#666;">Start creating quizzes to see them here.</p>
                <a href="${pageContext.request.contextPath}/creator/create-quiz.jsp" class="btn btn-primary">
                    Create Your First Quiz
                </a>
            </div>`;
        return;
    }

    let html = `<table>
        <thead>
            <tr>
                <th>Title</th><th>Description</th><th>Duration</th>
                <th>Questions</th><th>Attempts</th><th>Passing</th>
                <th>Status</th><th>Created</th><th>Actions</th>
            </tr>
        </thead><tbody>`;

    quizzes.forEach(q => {
        const statusColor = q.active ? '#28a745' : '#dc3545';
        html += `
        <tr>
            <td><strong>${q.title}</strong></td>
            <td>${q.description || 'No description'}</td>
            <td>${q.durationMinutes} mins</td>
            <td>${q.totalQuestions || 0}</td>
            <td>${q.totalAttempts || 0}</td>
            <td>${q.passingScore}%</td>
            <td><span style="color:${statusColor};font-weight:600;">
                ${q.active ? 'Active' : 'Inactive'}
            </span></td>
            <td>${new Date(q.createdAt).toLocaleDateString()}</td>
            <td>
                <button class="btn btn-info btn-small"
                        onclick="viewQuestions(${q.quizId},'${q.title}')">Questions</button>
                <button class="btn btn-warning btn-small"
                        onclick="toggleStatus(${q.quizId})">
                        ${q.active ? 'Deactivate' : 'Activate'}
                </button>
                <a class="btn btn-success btn-small"
                   href="${pageContext.request.contextPath}/creator/results.jsp?quizId=${q.quizId}">
                   Results
                </a>
                <button class="btn btn-danger btn-small"
                        onclick="deleteQuiz(${q.quizId},'${q.title}')">Delete</button>
            </td>
        </tr>`;
    });

    html += '</tbody></table>';
    document.getElementById('quizzesContainer').innerHTML = html;
}

function viewQuestions(quizId, title) {
    fetch('${pageContext.request.contextPath}/QuestionServlet?action=list&quizId=' + quizId)
        .then(res => res.json())
        .then(qs => {
            document.getElementById('modalTitle').textContent =
                title + ' - Questions (' + qs.length + ')';

            let html = qs.length === 0
                ? '<p style="padding:30px;text-align:center;">No questions added.</p>'
                : qs.map((q,i)=>`
                    <div class="question-item">
                        <h4>Question ${i+1} (${q.points} pts)</h4>
                        <p><strong>${q.questionText}</strong></p>
                        <p>A) ${q.optionA}</p>
                        <p>B) ${q.optionB}</p>
                        <p>C) ${q.optionC}</p>
                        <p>D) ${q.optionD}</p>
                        <p style="color:#28a745;font-weight:600;">
                            ✓ Correct: ${q.correctAnswer}
                        </p>
                    </div>`).join('');

            document.getElementById('questionsContent').innerHTML = html;
            document.getElementById('questionsModal').style.display = 'block';
        });
}

function toggleStatus(id) {
    if (!confirm('Toggle quiz status?')) return;

    const data = new URLSearchParams();
    data.append('action', 'toggle');
    data.append('quizId', id);

    fetch('${pageContext.request.contextPath}/QuizServlet', {
        method: 'POST',
        body: data
    }).then(()=>loadMyQuizzes());
}

function deleteQuiz(id, title) {
    if (!confirm(`Delete "${title}"?\nThis removes all questions & attempts.`)) return;

    fetch('${pageContext.request.contextPath}/QuizServlet?quizId=' + id,
        { method: 'DELETE' })
        .then(()=>loadMyQuizzes());
}

function closeModal() {
    document.getElementById('questionsModal').style.display = 'none';
}

function showMessage(msg, type) {
    const div = document.getElementById('message');
    div.innerHTML = `<div class="alert alert-${type}">${msg}</div>`;
    setTimeout(()=>div.innerHTML='',5000);
}

window.onclick = e => {
    if (e.target === document.getElementById('questionsModal')) closeModal();
};
</script>

</body>
</html>
