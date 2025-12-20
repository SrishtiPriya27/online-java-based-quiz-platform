<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.quizplatform.model.User" %>
<%
    // Prevent caching
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    User user = (User) session.getAttribute("user");
    if (user == null ||
        (!"participant".equalsIgnoreCase(user.getRole())
         && !"admin".equalsIgnoreCase(user.getRole()))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String quizIdParam = request.getParameter("quizId");
    if (quizIdParam == null) {
        response.sendRedirect(request.getContextPath() + "/participant/dashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Take Quiz - Quiz Platform</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<nav class="navbar">
    <h1>🎓 Quiz Platform</h1>
    <div class="user-info">
        <span>Welcome, <%= user.getFullName() %></span>
    </div>
</nav>

<div class="container">
    <div class="quiz-header">
        <h2 id="quizTitle">Loading...</h2>
        <div class="timer">Time Remaining: <span id="timeDisplay">00:00</span></div>
    </div>

    <form id="quizForm">
        <div id="questionsContainer"></div>
        <button type="submit" class="btn btn-primary" style="margin-top: 20px;">
            Submit Quiz
        </button>
    </form>
</div>

<script>
    const quizId = Number('<%= quizIdParam %>');
    let questions = [];
    let startTime = Date.now();
    let duration = 0;
    let timerInterval;

    Promise.all([
        fetch('${pageContext.request.contextPath}/QuizServlet?action=get&quizId=' + quizId),
        fetch('${pageContext.request.contextPath}/QuestionServlet?action=forAttempt&quizId=' + quizId)
    ])
    .then(responses => Promise.all(responses.map(r => r.json())))
    .then(([quiz, questionsData]) => {
        document.getElementById('quizTitle').textContent = quiz.title;
        duration = quiz.durationMinutes;
        questions = questionsData;
        displayQuestions(questions);
        startTimer(duration);
    });

    function displayQuestions(questions) {
        const container = document.getElementById('questionsContainer');
        container.innerHTML = questions.map((q, i) => `
            <div class="question-card">
                <div class="question-text">${i + 1}. ${q.questionText}</div>
                <div class="options">
                    ${['A','B','C','D'].map(o => `
                        <label class="option">
                            <input type="radio" name="q${q.questionId}" value="${o}">
                            <span>${o}) ${q['option' + o]}</span>
                        </label>
                    `).join('')}
                </div>
            </div>
        `).join('');

        document.querySelectorAll('.option').forEach(opt => {
            opt.addEventListener('click', function () {
                this.parentElement.querySelectorAll('.option')
                    .forEach(o => o.classList.remove('selected'));
                this.classList.add('selected');
            });
        });
    }

    function startTimer(minutes) {
        const endTime = startTime + minutes * 60000;

        timerInterval = setInterval(() => {
            const remaining = endTime - Date.now();
            if (remaining <= 0) {
                clearInterval(timerInterval);
                submitQuiz();
                return;
            }
            const m = Math.floor(remaining / 60000);
            const s = Math.floor((remaining % 60000) / 1000);
            document.getElementById('timeDisplay').textContent =
                `${String(m).padStart(2,'0')}:${String(s).padStart(2,'0')}`;
        }, 1000);
    }

    document.getElementById('quizForm').addEventListener('submit', e => {
        e.preventDefault();
        if (confirm('Submit quiz?')) submitQuiz();
    });

    function submitQuiz() {
        clearInterval(timerInterval);

        const answers = {};
        questions.forEach(q => {
            const sel = document.querySelector(`input[name="q${q.questionId}"]:checked`);
            if (sel) answers[q.questionId] = sel.value;
        });

        const timeTaken = Math.floor((Date.now() - startTime) / 60000);

        const data = new URLSearchParams({
            action: 'submit',
            quizId,
            timeTaken,
            answers: JSON.stringify(answers)
        });

        fetch('${pageContext.request.contextPath}/AttemptServlet', {
            method: 'POST',
            body: data
        })
        .then(r => r.json())
        .then(d => {
            if (d.success) {
                alert(`Score: ${d.attempt.score.toFixed(2)}%`);
                window.location.href =
                    '${pageContext.request.contextPath}/participant/performance.jsp';
            } else {
                alert('Submission failed');
            }
        });
    }
</script>
</body>
</html>
