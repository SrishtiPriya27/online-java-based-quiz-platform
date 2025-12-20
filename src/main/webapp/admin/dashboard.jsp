<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.quizplatform.model.User" %>
<%
    // Prevent caching
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
    <title>Admin Dashboard - Quiz Platform</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <nav class="navbar">
        <h1>🎓 Quiz Platform - Admin</h1>
        <div class="user-info">
            <span>Welcome, <%= user.getFullName() %></span>
            <a href="${pageContext.request.contextPath}/admin/users.jsp">Users</a>
            <a href="${pageContext.request.contextPath}/admin/quizzes.jsp">Quizzes</a>
            <a href="${pageContext.request.contextPath}/admin/reports.jsp">Reports</a>
            <a href="${pageContext.request.contextPath}/LogoutServlet">Logout</a>
        </div>
    </nav>

    <div class="container">
        <h2 style="margin-bottom: 30px;">Dashboard Overview</h2>

        <div class="dashboard" id="stats"></div>

        <h3>Recent Activity</h3>
        <div id="recentAttempts"></div>
    </div>

    <script>
        fetch('${pageContext.request.contextPath}/UserServlet?action=stats')
            .then(r => r.json())
            .then(data => {
                document.getElementById('stats').innerHTML = `
                    <div class="card"><h3>${data.total}</h3><p>Total Users</p></div>
                    <div class="card"><h3>${data.participants}</h3><p>Participants</p></div>
                    <div class="card"><h3>${data.creators}</h3><p>Creators</p></div>
                    <div class="card"><h3>${data.admins}</h3><p>Admins</p></div>
                `;
            });

        fetch('${pageContext.request.contextPath}/QuizServlet?action=stats')
            .then(r => r.json())
            .then(data => {
                document.getElementById('stats').innerHTML += `
                    <div class="card"><h3>${data.total}</h3><p>Total Quizzes</p></div>
                    <div class="card"><h3>${data.active}</h3><p>Active Quizzes</p></div>
                `;
            });

        fetch('${pageContext.request.contextPath}/AttemptServlet?action=all')
            .then(r => r.json())
            .then(attempts => {
                let html = '<table><thead><tr><th>User</th><th>Quiz</th><th>Score</th><th>Date</th></tr></thead><tbody>';
                attempts.slice(0, 10).forEach(a => {
                    html += `<tr>
                        <td>${a.username}</td>
                        <td>${a.quizTitle}</td>
                        <td>${a.score.toFixed(2)}%</td>
                        <td>${new Date(a.attemptedAt).toLocaleDateString()}</td>
                    </tr>`;
                });
                html += '</tbody></table>';
                document.getElementById('recentAttempts').innerHTML = html;
            });
    </script>
</body>
</html>
