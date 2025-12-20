<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.quizplatform.model.User" %>

<%
    // Prevent caching after logout
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reports & Analytics - Quiz Platform</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>

<body>
<nav class="navbar">
    <h1>🎓 Quiz Platform - Admin</h1>
    <div class="user-info">
        <span>Welcome, <%= user.getFullName() %></span>
        <a href="${pageContext.request.contextPath}/admin/dashboard.jsp">Dashboard</a>
        <a href="${pageContext.request.contextPath}/admin/users.jsp">Users</a>
        <a href="${pageContext.request.contextPath}/admin/quizzes.jsp">Quizzes</a>
        <a href="${pageContext.request.contextPath}/admin/reports.jsp">Reports</a>
        <a href="${pageContext.request.contextPath}/LogoutServlet">Logout</a>
    </div>
</nav>

<div class="container">
    <h2 style="margin-bottom: 30px;">Reports & Analytics</h2>

    <!-- Summary Cards -->
    <div class="dashboard">
        <div class="card">
            <h3 id="totalUsers">0</h3>
            <p>Total Users</p>
        </div>
        <div class="card">
            <h3 id="totalQuizzes">0</h3>
            <p>Total Quizzes</p>
        </div>
        <div class="card">
            <h3 id="totalAttempts">0</h3>
            <p>Total Attempts</p>
        </div>
        <div class="card">
            <h3 id="avgScore">0%</h3>
            <p>Average Score</p>
        </div>
    </div>

    <!-- Top Performers -->
    <div class="leaderboard">
        <h3>Top Performers (All Time)</h3>
        <div id="topPerformers"></div>
    </div>

    <!-- Quiz Performance -->
    <div class="leaderboard">
        <h3>Quiz Performance Analysis</h3>
        <div id="quizPerformance"></div>
    </div>

    <!-- Recent Activity -->
    <div class="leaderboard">
        <h3>Recent Activity (Last 50 Attempts)</h3>
        <div id="recentActivity"></div>
    </div>
</div>

<script>
window.onload = function () {
    loadReports();
};

function loadReports() {
    Promise.all([
        fetch('${pageContext.request.contextPath}/UserServlet?action=stats'),
        fetch('${pageContext.request.contextPath}/QuizServlet?action=stats'),
        fetch('${pageContext.request.contextPath}/AttemptServlet?action=all')
    ])
    .then(responses => Promise.all(responses.map(r => r.json())))
    .then(([userStats, quizStats, attempts]) => {

        document.getElementById('totalUsers').textContent = userStats.total;
        document.getElementById('totalQuizzes').textContent = quizStats.total;
        document.getElementById('totalAttempts').textContent = attempts.length;

        if (attempts.length > 0) {
            const avg = attempts.reduce((s, a) => s + a.score, 0) / attempts.length;
            document.getElementById('avgScore').textContent = avg.toFixed(2) + '%';
        }

        displayTopPerformers(attempts);
        displayQuizPerformance(attempts);
        displayRecentActivity(attempts);
    });
}

function displayTopPerformers(attempts) {
    const map = {};
    attempts.forEach(a => {
        if (!map[a.username]) map[a.username] = { total: 0, count: 0, best: 0 };
        map[a.username].total += a.score;
        map[a.username].count++;
        map[a.username].best = Math.max(map[a.username].best, a.score);
    });

    const list = Object.keys(map).map(u => ({
        username: u,
        avg: map[u].total / map[u].count,
        best: map[u].best,
        count: map[u].count
    })).sort((a, b) => b.avg - a.avg);

    let html = '<table><thead><tr><th>Rank</th><th>User</th><th>Avg</th><th>Best</th><th>Attempts</th></tr></thead><tbody>';
    list.slice(0, 10).forEach((u, i) => {
        html += `<tr>
            <td>${i + 1}</td>
            <td>${u.username}</td>
            <td>${u.avg.toFixed(2)}%</td>
            <td>${u.best.toFixed(2)}%</td>
            <td>${u.count}</td>
        </tr>`;
    });
    html += '</tbody></table>';

    document.getElementById('topPerformers').innerHTML = html;
}

function displayQuizPerformance(attempts) {
    const map = {};
    attempts.forEach(a => {
        if (!map[a.quizTitle]) map[a.quizTitle] = { total: 0, count: 0, pass: 0 };
        map[a.quizTitle].total += a.score;
        map[a.quizTitle].count++;
        if (a.passed) map[a.quizTitle].pass++;
    });

    let html = '<table><thead><tr><th>Quiz</th><th>Attempts</th><th>Avg</th><th>Pass %</th></tr></thead><tbody>';
    Object.keys(map).forEach(q => {
        const d = map[q];
        html += `<tr>
            <td>${q}</td>
            <td>${d.count}</td>
            <td>${(d.total / d.count).toFixed(2)}%</td>
            <td>${((d.pass / d.count) * 100).toFixed(2)}%</td>
        </tr>`;
    });
    html += '</tbody></table>';

    document.getElementById('quizPerformance').innerHTML = html;
}

function displayRecentActivity(attempts) {
    const recent = attempts.sort((a, b) => new Date(b.attemptedAt) - new Date(a.attemptedAt)).slice(0, 50);
    let html = '<table><thead><tr><th>Date</th><th>User</th><th>Quiz</th><th>Score</th><th>Status</th></tr></thead><tbody>';

    recent.forEach(a => {
        html += `<tr>
            <td>${new Date(a.attemptedAt).toLocaleString()}</td>
            <td>${a.username}</td>
            <td>${a.quizTitle}</td>
            <td>${a.score.toFixed(2)}%</td>
            <td>${a.passed ? 'Passed' : 'Failed'}</td>
        </tr>`;
    });

    html += '</tbody></table>';
    document.getElementById('recentActivity').innerHTML = html;
}
</script>

</body>
</html>
