<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.example.quizplatform.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Users - Quiz Platform</title>
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
            width: 500px;
            max-width: 90%;
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
    </style>
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
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
            <h2>User Management</h2>
            <button onclick="openCreateModal()" class="btn btn-primary">+ Create New User</button>
        </div>

        <div id="message"></div>

        <div style="margin-bottom: 20px;">
            <label>Filter by Role: </label>
            <select id="roleFilter" onchange="loadUsers()" style="padding: 8px; border-radius: 5px;">
                <option value="all">All Users</option>
                <option value="admin">Admins</option>
                <option value="creator">Creators</option>
                <option value="participant">Participants</option>
            </select>
        </div>

        <div id="usersTable">
            <p>Loading users...</p>
        </div>
    </div>

    <!-- Create User Modal -->
    <div id="createModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeCreateModal()">&times;</span>
            <h3>Create New User</h3>
            <form id="createUserForm">
                <div class="form-group">
                    <label>Username *</label>
                    <input type="text" name="username" required>
                </div>
                <div class="form-group">
                    <label>Password *</label>
                    <input type="password" name="password" required minlength="6">
                </div>
                <div class="form-group">
                    <label>Full Name *</label>
                    <input type="text" name="fullName" required>
                </div>
                <div class="form-group">
                    <label>Email *</label>
                    <input type="email" name="email" required>
                </div>
                <div class="form-group">
                    <label>Role *</label>
                    <select name="role" required>
                        <option value="">Select Role</option>
                        <option value="admin">Admin</option>
                        <option value="creator">Creator</option>
                        <option value="participant">Participant</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary">Create User</button>
                <button type="button" onclick="closeCreateModal()" class="btn btn-danger">Cancel</button>
            </form>
        </div>
    </div>

    <!-- Edit User Modal -->
    <div id="editModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeEditModal()">&times;</span>
            <h3>Edit User</h3>
            <form id="editUserForm">
                <input type="hidden" name="userId" id="editUserId">
                <div class="form-group">
                    <label>Username</label>
                    <input type="text" id="editUsername" disabled style="background: #f5f5f5;">
                </div>
                <div class="form-group">
                    <label>Full Name *</label>
                    <input type="text" name="fullName" id="editFullName" required>
                </div>
                <div class="form-group">
                    <label>Email *</label>
                    <input type="email" name="email" id="editEmail" required>
                </div>
                <div class="form-group">
                    <label>Role *</label>
                    <select name="role" id="editRole" required>
                        <option value="admin">Admin</option>
                        <option value="creator">Creator</option>
                        <option value="participant">Participant</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary">Update User</button>
                <button type="button" onclick="closeEditModal()" class="btn btn-danger">Cancel</button>
            </form>
        </div>
    </div>

    <script>
        // Load users on page load
        window.onload = function() {
            loadUsers();
        };

        function loadUsers() {
            const roleFilter = document.getElementById('roleFilter').value;
            let url = '${pageContext.request.contextPath}/UserServlet?action=list';
            
            fetch(url)
                .then(response => response.json())
                .then(users => {
                    // Filter by role if needed
                    if (roleFilter !== 'all') {
                        users = users.filter(u => u.role === roleFilter);
                    }
                    
                    displayUsers(users);
                })
                .catch(error => {
                    console.error('Error:', error);
                    showMessage('Error loading users', 'danger');
                });
        }

        function displayUsers(users) {
            let html = '<table><thead><tr>';
            html += '<th>Username</th><th>Full Name</th><th>Email</th><th>Role</th><th>Created</th><th>Actions</th>';
            html += '</tr></thead><tbody>';

            users.forEach(user => {
                const date = new Date(user.createdAt).toLocaleDateString();
                const roleColor = user.role === 'admin' ? '#dc3545' : (user.role === 'creator' ? '#28a745' : '#007bff');
                
                html += `<tr>
                    <td><strong>${user.username}</strong></td>
                    <td>${user.fullName}</td>
                    <td>${user.email}</td>
                    <td><span style="color: ${roleColor}; font-weight: 600;">${user.role.toUpperCase()}</span></td>
                    <td>${date}</td>
                    <td>
                        <button onclick="editUser(${user.userId})" class="btn btn-info btn-small">Edit</button>
                        <button onclick="deleteUser(${user.userId}, '${user.username}')" class="btn btn-danger btn-small">Delete</button>
                    </td>
                </tr>`;
            });

            html += '</tbody></table>';
            document.getElementById('usersTable').innerHTML = html;
        }

        // Create User
        document.getElementById('createUserForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const formData = new FormData(this);
            formData.append('action', 'create');
            
            fetch('${pageContext.request.contextPath}/UserServlet', {
                method: 'POST',
                body: new URLSearchParams(formData)
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showMessage('User created successfully!', 'success');
                    closeCreateModal();
                    this.reset();
                    loadUsers();
                } else {
                    showMessage('Error: ' + data.message, 'danger');
                }
            })
            .catch(error => showMessage('Error: ' + error, 'danger'));
        });

        // Edit User
        function editUser(userId) {
            fetch('${pageContext.request.contextPath}/UserServlet?action=get&userId=' + userId)
                .then(response => response.json())
                .then(user => {
                    document.getElementById('editUserId').value = user.userId;
                    document.getElementById('editUsername').value = user.username;
                    document.getElementById('editFullName').value = user.fullName;
                    document.getElementById('editEmail').value = user.email;
                    document.getElementById('editRole').value = user.role;
                    document.getElementById('editModal').style.display = 'block';
                });
        }

        document.getElementById('editUserForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const formData = new FormData(this);
            formData.append('action', 'update');
            
            fetch('${pageContext.request.contextPath}/UserServlet', {
                method: 'POST',
                body: new URLSearchParams(formData)
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showMessage('User updated successfully!', 'success');
                    closeEditModal();
                    loadUsers();
                } else {
                    showMessage('Error: ' + data.message, 'danger');
                }
            })
            .catch(error => showMessage('Error: ' + error, 'danger'));
        });

        // Delete User
        function deleteUser(userId, username) {
            if (!confirm('Are you sure you want to delete user "' + username + '"?')) {
                return;
            }
            
            fetch('${pageContext.request.contextPath}/UserServlet?userId=' + userId, {
                method: 'DELETE'
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showMessage('User deleted successfully!', 'success');
                    loadUsers();
                } else {
                    showMessage('Error: ' + data.message, 'danger');
                }
            })
            .catch(error => showMessage('Error: ' + error, 'danger'));
        }

        // Modal functions
        function openCreateModal() {
            document.getElementById('createModal').style.display = 'block';
        }

        function closeCreateModal() {
            document.getElementById('createModal').style.display = 'none';
        }

        function closeEditModal() {
            document.getElementById('editModal').style.display = 'none';
        }

        function showMessage(message, type) {
            const messageDiv = document.getElementById('message');
            messageDiv.innerHTML = `<div class="alert alert-${type}">${message}</div>`;
            setTimeout(() => messageDiv.innerHTML = '', 5000);
        }

        // Close modal when clicking outside
        window.onclick = function(event) {
            const createModal = document.getElementById('createModal');
            const editModal = document.getElementById('editModal');
            if (event.target == createModal) {
                closeCreateModal();
            }
            if (event.target == editModal) {
                closeEditModal();
            }
        }
    </script>
</body>
</html>