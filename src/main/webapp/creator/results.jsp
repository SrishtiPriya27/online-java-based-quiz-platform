<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.quizplatform.model.User" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null || (!"creator".equals(user.getRole()) && !"admin".equals(user.getRole()))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String quizId = request.getParameter("quizId");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quiz Results - Quiz Platform</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>

<body>

<nav class="navbar">
    <h1>🎓 Quiz Platform - Results</h1>
    <div class="user-info">
        <span>Welcome, <%= user.getFullName() %></span>
        <a href="<%= request.getContextPath() %>/creator/dashboard.jsp">Dashboard</a>
        <a href="<%= request.getContextPath() %>/creator/quiz-history.jsp">My Quizzes</a>
        <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
    </div>
</nav>

<div class="container">
    <h2 id="quizTitle">Loading results...</h2>

    <div class="dashboard" id="stats"></div>

    <h3>Leaderboard</h3>
    <div id="leaderboard"></div>

    <h3>All Attempts</h3>
    <div id="attempts"></div>
</div>

<script>
    const quizId = <%= quizId %>;

    window.onload = function () {
        loadQuizResults();
    };

    function loadQuizResults() {
        Promise.all([
            fetch('<%= request.getContextPath() %>/QuizServlet?action=get&quizId=' + quizId),
            fetch('<%= request.getContextPath() %>/AttemptServlet?action=quizAttempts&quizId=' + quizId),
            fetch('<%= request.getContextPath() %>/AttemptServlet?action=leaderboard&quizId=' + quizId)
        ])
        .then(responses => Promise.all(responses.map(r => r.json())))
        .then(([quiz, attempts, leaderboard]) => {
            document.getElementById('quizTitle').textContent = quiz.title + ' - Results';
            displayLeaderboard(leaderboard);
            displayAttempts(attempts);
        })
        .catch(err => {
            console.error(err);
            alert('Error loading results');
        });
    }

    function displayLeaderboard(data) {
        let html = '<table><thead><tr><th>Rank</th><th>User</th><th>Score</th></tr></thead><tbody>';
        data.forEach((a, i) => {
            html += `<tr>
                <td>${i + 1}</td>
                <td>${a.username}</td>
                <td>${a.score.toFixed(2)}%</td>
            </tr>`;
        });
        html += '</tbody></table>';
        document.getElementById('leaderboard').innerHTML = html;
    }

    function displayAttempts(data) {
        let html = '<table><thead><tr><th>User</th><th>Score</th><th>Date</th></tr></thead><tbody>';
        data.forEach(a => {
            html += `<tr>
                <td>${a.username}</td>
                <td>${a.score.toFixed(2)}%</td>
                <td>${new Date(a.attemptedAt).toLocaleString()}</td>
            </tr>`;
        });
        html += '</tbody></table>';
        document.getElementById('attempts').innerHTML = html;
    }
</script>

</body>
</html>
