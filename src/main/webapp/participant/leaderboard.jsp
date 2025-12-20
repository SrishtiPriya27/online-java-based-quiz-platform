<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.quizplatform.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || (!"participant".equals(user.getRole()) && !"admin".equals(user.getRole()))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Leaderboard - Quiz Platform</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .quiz-selector {
            background: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .quiz-selector select {
            width: 100%;
            padding: 12px;
            font-size: 16px;
            border: 2px solid #ddd;
            border-radius: 5px;
        }
        .my-rank {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <h1>🎓 Quiz Platform</h1>
        <div class="user-info">
            <span>Welcome, <%= user.getFullName() %></span>
            <a href="${pageContext.request.contextPath}/participant/dashboard.jsp">Dashboard</a>
            <a href="${pageContext.request.contextPath}/participant/performance.jsp">My Performance</a>
            <a href="${pageContext.request.contextPath}/participant/leaderboard.jsp">Leaderboard</a>
            <a href="${pageContext.request.contextPath}/LogoutServlet">Logout</a>
        </div>
    </nav>

    <div class="container">
        <h2 style="margin-bottom: 30px;">🏆 Leaderboard</h2>

        <!-- Quiz Selector -->
        <div class="quiz-selector">
            <label for="quizSelect" style="font-weight: 600; margin-bottom: 10px; display: block;">Select Quiz:</label>
            <select id="quizSelect" onchange="loadLeaderboard()">
                <option value="">-- Select a Quiz --</option>
            </select>
        </div>

        <!-- Leaderboard -->
        <div id="leaderboardContainer"></div>
    </div>

    <script>
        const currentUsername = '<%= user.getUsername() %>';
        let allQuizzes = [];

        window.onload = function() {
            loadQuizzes();
        };

        function loadQuizzes() {
            fetch('${pageContext.request.contextPath}/QuizServlet?action=list&roleFilter=active')
                .then(response => response.json())
                .then(quizzes => {
                    allQuizzes = quizzes;
                    populateQuizSelector(quizzes);
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Error loading quizzes');
                });
        }

        function populateQuizSelector(quizzes) {
            const select = document.getElementById('quizSelect');
            
            quizzes.forEach(quiz => {
                const option = document.createElement('option');
                option.value = quiz.quizId;
                option.textContent = quiz.title + ' (' + (quiz.totalAttempts || 0) + ' attempts)';
                select.appendChild(option);
            });

            // Auto-select first quiz if available
            if (quizzes.length > 0) {
                select.selectedIndex = 1;
                loadLeaderboard();
            } else {
                document.getElementById('leaderboardContainer').innerHTML = `
                    <div style="text-align: center; padding: 50px; background: white; border-radius: 10px;">
                        <h3>No quizzes available</h3>
                        <p style="color: #666;">Check back later for new quizzes!</p>
                    </div>
                `;
            }
        }

        function loadLeaderboard() {
            const quizId = document.getElementById('quizSelect').value;
            
            if (!quizId) {
                document.getElementById('leaderboardContainer').innerHTML = '';
                return;
            }

            Promise.all([
                fetch('${pageContext.request.contextPath}/AttemptServlet?action=leaderboard&quizId=' + quizId),
                fetch('${pageContext.request.contextPath}/AttemptServlet?action=quizAttempts&quizId=' + quizId)
            ])
            .then(responses => Promise.all(responses.map(r => r.json())))
            .then(([leaderboard, allAttempts]) => {
                displayLeaderboard(leaderboard, allAttempts);
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Error loading leaderboard');
            });
        }

        function displayLeaderboard(leaderboard, allAttempts) {
            if (leaderboard.length === 0) {
                document.getElementById('leaderboardContainer').innerHTML = `
                    <div style="text-align: center; padding: 50px; background: white; border-radius: 10px;">
                        <h3>No attempts yet</h3>
                        <p style="color: #666;">Be the first to take this quiz!</p>
                        <a href="${pageContext.request.contextPath}/participant/dashboard.jsp" class="btn btn-primary">Take Quiz</a>
                    </div>
                `;
                return;
            }

            // Find current user's best attempt
            const myAttempts = allAttempts.filter(a => a.username === currentUsername);
            const myBestAttempt = myAttempts.length > 0 ? 
                myAttempts.reduce((best, current) => current.score > best.score ? current : best) : null;
            
            // Find user's rank in all attempts
            const sortedAttempts = [...allAttempts].sort((a, b) => 
                b.score !== a.score ? b.score - a.score : a.timeTakenMinutes - b.timeTakenMinutes
            );
            const myRank = myBestAttempt ? 
                sortedAttempts.findIndex(a => a.attemptId === myBestAttempt.attemptId) + 1 : null;

            let html = '<div style="background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">';
            
            // Show user's rank if they have attempted
            if (myBestAttempt) {
                html += `
                    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 10px; margin-bottom: 20px;">
                        <h3 style="margin-bottom: 10px;">Your Best Performance</h3>
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <div>
                                <div style="font-size: 24px; font-weight: bold;">Rank #${myRank}</div>
                                <div style="opacity: 0.9;">out of ${allAttempts.length} attempts</div>
                            </div>
                            <div style="text-align: right;">
                                <div style="font-size: 32px; font-weight: bold;">${myBestAttempt.score.toFixed(2)}%</div>
                                <div style="opacity: 0.9;">${myBestAttempt.correctAnswers}/${myBestAttempt.totalQuestions} correct</div>
                            </div>
                        </div>
                    </div>
                `;
            } else {
                html += `
                    <div style="background: #f8f9fa; padding: 20px; border-radius: 10px; margin-bottom: 20px; text-align: center;">
                        <p style="margin: 0;">You haven't attempted this quiz yet. <a href="${pageContext.request.contextPath}/participant/dashboard.jsp">Take it now</a> to appear on the leaderboard!</p>
                    </div>
                `;
            }

            html += '<h3 style="margin-bottom: 20px;">Top 10 Performers</h3>';
            html += '<div class="leaderboard">';

            leaderboard.forEach((attempt, index) => {
                const isCurrentUser = attempt.username === currentUsername;
                const rankClass = index === 0 ? 'gold' : (index === 1 ? 'silver' : (index === 2 ? 'bronze' : ''));
                const medal = index === 0 ? '🥇' : (index === 1 ? '🥈' : (index === 2 ? '🥉' : ''));
                const itemClass = isCurrentUser ? 'my-rank' : '';
                
                html += `
                    <div class="leaderboard-item ${itemClass}">
                        <div style="display: flex; align-items: center; gap: 15px;">
                            <span class="rank ${rankClass}">${medal || (index + 1)}</span>
                            <div>
                                <div style="font-weight: 600;">
                                    ${attempt.username}
                                    ${isCurrentUser ? '<span style="margin-left: 10px; padding: 2px 8px; background: rgba(255,255,255,0.3); border-radius: 3px; font-size: 12px;">YOU</span>' : ''}
                                </div>
                                <div style="font-size: 12px; ${isCurrentUser ? 'opacity: 0.9' : 'color: #666;'}">
                                    ${new Date(attempt.attemptedAt).toLocaleDateString()} • ${attempt.timeTakenMinutes} mins
                                </div>
                            </div>
                        </div>
                        <div style="text-align: right;">
                            <div style="font-size: 24px; font-weight: bold; color: ${isCurrentUser ? 'white' : '#667eea'};">
                                ${attempt.score.toFixed(2)}%
                            </div>
                            <div style="font-size: 12px; ${isCurrentUser ? 'opacity: 0.9' : 'color: #666;'}">
                                ${attempt.correctAnswers}/${attempt.totalQuestions} correct
                            </div>
                        </div>
                    </div>
                `;
            });

            html += '</div></div>';
            document.getElementById('leaderboardContainer').innerHTML = html;
        }
    </script>
</body>
</html>