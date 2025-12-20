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
    <title>My Performance - Quiz Platform</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
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
        <h2 style="margin-bottom: 30px;">My Performance</h2>

        <!-- Statistics Cards -->
        <div class="dashboard">
            <div class="card">
                <h3 id="totalAttempts">0</h3>
                <p>Total Attempts</p>
            </div>
            <div class="card">
                <h3 id="avgScore">0%</h3>
                <p>Average Score</p>
            </div>
            <div class="card">
                <h3 id="bestScore">0%</h3>
                <p>Best Score</p>
            </div>
            <div class="card">
                <h3 id="passRate">0%</h3>
                <p>Pass Rate</p>
            </div>
        </div>

        <!-- Performance Chart -->
        <div style="background: white; padding: 30px; border-radius: 10px; margin-bottom: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
            <h3>Performance Over Time</h3>
            <div id="performanceChart" style="min-height: 200px;">
                <canvas id="chart" width="800" height="300"></canvas>
            </div>
        </div>

        <!-- Attempt History -->
        <div style="background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
            <h3>My Attempt History</h3>
            <div id="attemptHistory"></div>
        </div>
    </div>

    <script>
        window.onload = function() {
            loadPerformance();
        };

        function loadPerformance() {
            fetch('${pageContext.request.contextPath}/AttemptServlet?action=myAttempts')
                .then(response => response.json())
                .then(attempts => {
                    displayStatistics(attempts);
                    drawPerformanceChart(attempts);
                    displayAttemptHistory(attempts);
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Error loading performance data');
                });
        }

        function displayStatistics(attempts) {
            document.getElementById('totalAttempts').textContent = attempts.length;

            if (attempts.length === 0) {
                document.getElementById('avgScore').textContent = 'N/A';
                document.getElementById('bestScore').textContent = 'N/A';
                document.getElementById('passRate').textContent = 'N/A';
                return;
            }

            const totalScore = attempts.reduce((sum, a) => sum + a.score, 0);
            const avgScore = totalScore / attempts.length;
            const bestScore = Math.max(...attempts.map(a => a.score));
            const passCount = attempts.filter(a => a.passed).length;
            const passRate = (passCount / attempts.length * 100);

            document.getElementById('avgScore').textContent = avgScore.toFixed(2) + '%';
            document.getElementById('bestScore').textContent = bestScore.toFixed(2) + '%';
            document.getElementById('passRate').textContent = passRate.toFixed(2) + '%';
        }

        function drawPerformanceChart(attempts) {
            if (attempts.length === 0) {
                document.getElementById('performanceChart').innerHTML = '<p style="text-align: center; padding: 50px;">No attempts yet. Take a quiz to see your performance!</p>';
                return;
            }

            const canvas = document.getElementById('chart');
            const ctx = canvas.getContext('2d');
            const width = canvas.width;
            const height = canvas.height;
            const padding = 50;

            // Clear canvas
            ctx.clearRect(0, 0, width, height);

            // Sort attempts by date
            const sortedAttempts = [...attempts].sort((a, b) => 
                new Date(a.attemptedAt) - new Date(b.attemptedAt)
            );

            // Draw axes
            ctx.strokeStyle = '#333';
            ctx.lineWidth = 2;
            ctx.beginPath();
            ctx.moveTo(padding, padding);
            ctx.lineTo(padding, height - padding);
            ctx.lineTo(width - padding, height - padding);
            ctx.stroke();

            // Draw data points and lines
            if (sortedAttempts.length > 0) {
                const maxX = width - padding * 2;
                const maxY = height - padding * 2;
                const stepX = maxX / (sortedAttempts.length - 1 || 1);

                ctx.strokeStyle = '#667eea';
                ctx.lineWidth = 3;
                ctx.beginPath();

                sortedAttempts.forEach((attempt, index) => {
                    const x = padding + (index * stepX);
                    const y = height - padding - (attempt.score / 100 * maxY);

                    if (index === 0) {
                        ctx.moveTo(x, y);
                    } else {
                        ctx.lineTo(x, y);
                    }

                    // Draw point
                    ctx.fillStyle = attempt.passed ? '#28a745' : '#dc3545';
                    ctx.beginPath();
                    ctx.arc(x, y, 5, 0, Math.PI * 2);
                    ctx.fill();
                });

                ctx.strokeStyle = '#667eea';
                ctx.stroke();
            }

            // Draw labels
            ctx.fillStyle = '#333';
            ctx.font = '14px Arial';
            ctx.textAlign = 'center';
            ctx.fillText('Attempts →', width / 2, height - 10);
            
            ctx.save();
            ctx.translate(15, height / 2);
            ctx.rotate(-Math.PI / 2);
            ctx.fillText('Score (%) →', 0, 0);
            ctx.restore();

            // Draw score markers
            ctx.textAlign = 'right';
            ctx.font = '12px Arial';
            for (let i = 0; i <= 100; i += 25) {
                const y = height - padding - (i / 100 * (height - padding * 2));
                ctx.fillText(i + '%', padding - 10, y + 4);
                
                // Grid line
                ctx.strokeStyle = '#ddd';
                ctx.lineWidth = 1;
                ctx.beginPath();
                ctx.moveTo(padding, y);
                ctx.lineTo(width - padding, y);
                ctx.stroke();
            }
        }

        function displayAttemptHistory(attempts) {
            if (attempts.length === 0) {
                document.getElementById('attemptHistory').innerHTML = `
                    <p style="text-align: center; padding: 30px;">
                        No attempts yet. <a href="${pageContext.request.contextPath}/participant/dashboard.jsp">Take a quiz</a> to see your history!
                    </p>
                `;
                return;
            }

            let html = '<table><thead><tr>';
            html += '<th>Quiz</th><th>Score</th><th>Correct</th><th>Time Taken</th><th>Result</th><th>Date</th>';
            html += '</tr></thead><tbody>';

            attempts.forEach(attempt => {
                const date = new Date(attempt.attemptedAt).toLocaleDateString() + ' ' + new Date(attempt.attemptedAt).toLocaleTimeString();
                const resultColor = attempt.passed ? '#28a745' : '#dc3545';
                const resultText = attempt.passed ? '✓ Passed' : '✗ Failed';
                const scoreColor = attempt.score >= 80 ? '#28a745' : (attempt.score >= 50 ? '#ffc107' : '#dc3545');
                
                html += `<tr>
                    <td><strong>${attempt.quizTitle}</strong></td>
                    <td><span style="color: ${scoreColor}; font-weight: 600;">${attempt.score.toFixed(2)}%</span></td>
                    <td>${attempt.correctAnswers}/${attempt.totalQuestions}</td>
                    <td>${attempt.timeTakenMinutes} mins</td>
                    <td><span style="color: ${resultColor}; font-weight: 600;">${resultText}</span></td>
                    <td>${date}</td>
                </tr>`;
            });

            html += '</tbody></table>';
            document.getElementById('attemptHistory').innerHTML = html;
        }
    </script>
</body>
</html>