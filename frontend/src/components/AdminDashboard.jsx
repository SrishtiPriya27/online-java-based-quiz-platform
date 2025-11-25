import React, { useState, useEffect } from 'react';
import './Dashboard.css';

export default function AdminDashboard({ user, onLogout }) {
  const [activeTab, setActiveTab] = useState('overview');
  const [users, setUsers] = useState([]);
  const [quizzes, setQuizzes] = useState([]);
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalQuizzes: 0,
    totalAttempts: 0,
    avgScore: 0
  });
  const [showUserModal, setShowUserModal] = useState(false);
  const [newUser, setNewUser] = useState({
    username: '',
    email: '',
    password: '',
    role: 'participant'
  });

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      const token = localStorage.getItem('token');
      
      // Fetch users
      const usersRes = await fetch('http://localhost:3000/api/admin/users', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      const usersData = await usersRes.json();
      setUsers(usersData);

      // Fetch quizzes
      const quizzesRes = await fetch('http://localhost:3000/api/admin/quizzes', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      const quizzesData = await quizzesRes.json();
      setQuizzes(quizzesData);

      // Fetch stats
      const statsRes = await fetch('http://localhost:3000/api/admin/stats', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      const statsData = await statsRes.json();
      setStats(statsData);
    } catch (err) {
      console.error('Error fetching dashboard data:', err);
    }
  };

  const handleCreateUser = async (e) => {
    e.preventDefault();
    try {
      const token = localStorage.getItem('token');
      const response = await fetch('http://localhost:3000/api/admin/users', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(newUser)
      });

      if (response.ok) {
        alert('User created successfully!');
        setShowUserModal(false);
        setNewUser({ username: '', email: '', password: '', role: 'participant' });
        fetchDashboardData();
      } else {
        alert('Failed to create user');
      }
    } catch (err) {
      console.error('Error creating user:', err);
      alert('Error creating user');
    }
  };

  const handleDeleteUser = async (userId) => {
    if (!window.confirm('Are you sure you want to delete this user?')) return;

    try {
      const token = localStorage.getItem('token');
      const response = await fetch(`http://localhost:3000/api/admin/users/${userId}`, {
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${token}` }
      });

      if (response.ok) {
        alert('User deleted successfully!');
        fetchDashboardData();
      } else {
        alert('Failed to delete user');
      }
    } catch (err) {
      console.error('Error deleting user:', err);
    }
  };

  const handleApproveQuiz = async (quizId) => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch(`http://localhost:3000/api/admin/quizzes/${quizId}/approve`, {
        method: 'PATCH',
        headers: { 'Authorization': `Bearer ${token}` }
      });

      if (response.ok) {
        alert('Quiz approved successfully!');
        fetchDashboardData();
      } else {
        alert('Failed to approve quiz');
      }
    } catch (err) {
      console.error('Error approving quiz:', err);
    }
  };

  return (
    <div className="dashboard">
      <aside className="sidebar">
        <h2>Admin Panel</h2>
        <nav>
          <ul>
            <li>
              <a 
                href="#overview" 
                className={activeTab === 'overview' ? 'active' : ''}
                onClick={() => setActiveTab('overview')}
              >
                📊 Overview
              </a>
            </li>
            <li>
              <a 
                href="#users" 
                className={activeTab === 'users' ? 'active' : ''}
                onClick={() => setActiveTab('users')}
              >
                👥 User Management
              </a>
            </li>
            <li>
              <a 
                href="#quizzes" 
                className={activeTab === 'quizzes' ? 'active' : ''}
                onClick={() => setActiveTab('quizzes')}
              >
                📝 Quiz Management
              </a>
            </li>
            <li>
              <a 
                href="#settings" 
                className={activeTab === 'settings' ? 'active' : ''}
                onClick={() => setActiveTab('settings')}
              >
                ⚙️ Settings
              </a>
            </li>
          </ul>
        </nav>
        <button className="logout-btn" onClick={onLogout}>Logout</button>
      </aside>

      <main className="main-content">
        <div className="header">
          <h1>Admin Dashboard</h1>
          <div className="user-info">
            <div className="user-avatar">{user.username.charAt(0).toUpperCase()}</div>
            <span>{user.username}</span>
          </div>
        </div>

        {activeTab === 'overview' && (
          <div>
            <div className="stats-grid">
              <div className="stat-card">
                <h3>Total Users</h3>
                <p className="stat-number">{stats.totalUsers}</p>
              </div>
              <div className="stat-card">
                <h3>Total Quizzes</h3>
                <p className="stat-number">{stats.totalQuizzes}</p>
              </div>
              <div className="stat-card">
                <h3>Total Attempts</h3>
                <p className="stat-number">{stats.totalAttempts}</p>
              </div>
              <div className="stat-card">
                <h3>Average Score</h3>
                <p className="stat-number">{stats.avgScore}%</p>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'users' && (
          <div className="card">
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
              <h3>User Management</h3>
              <button className="btn btn-primary" onClick={() => setShowUserModal(true)}>
                + Add User
              </button>
            </div>
            <table className="table">
              <thead>
                <tr>
                  <th>Username</th>
                  <th>Email</th>
                  <th>Role</th>
                  <th>Created At</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {users.map(u => (
                  <tr key={u.id}>
                    <td>{u.username}</td>
                    <td>{u.email}</td>
                    <td><span className={`badge badge-${u.role}`}>{u.role}</span></td>
                    <td>{new Date(u.createdAt).toLocaleDateString()}</td>
                    <td>
                      <button 
                        className="btn btn-danger btn-sm"
                        onClick={() => handleDeleteUser(u.id)}
                      >
                        Delete
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {activeTab === 'quizzes' && (
          <div className="card">
            <h3>Quiz Content Management</h3>
            <table className="table">
              <thead>
                <tr>
                  <th>Title</th>
                  <th>Creator</th>
                  <th>Questions</th>
                  <th>Duration</th>
                  <th>Status</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {quizzes.map(quiz => (
                  <tr key={quiz.id}>
                    <td>{quiz.title}</td>
                    <td>{quiz.creator}</td>
                    <td>{quiz.questions?.length || 0}</td>
                    <td>{quiz.duration} min</td>
                    <td>
                      <span className={`badge badge-${quiz.status}`}>
                        {quiz.status}
                      </span>
                    </td>
                    <td>
                      {quiz.status === 'pending' && (
                        <button 
                          className="btn btn-primary btn-sm"
                          onClick={() => handleApproveQuiz(quiz.id)}
                        >
                          Approve
                        </button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {activeTab === 'settings' && (
          <div className="card">
            <h3>System Settings</h3>
            <div className="settings-section">
              <div className="form-group">
                <label>Platform Name</label>
                <input type="text" defaultValue="Java Quiz Platform" />
              </div>
              <div className="form-group">
                <label>Max Quiz Duration (minutes)</label>
                <input type="number" defaultValue="60" />
              </div>
              <div className="form-group">
                <label>Passing Score (%)</label>
                <input type="number" defaultValue="70" />
              </div>
              <button className="btn btn-primary">Save Settings</button>
            </div>
          </div>
        )}
      </main>

      {showUserModal && (
        <div className="modal-overlay" onClick={() => setShowUserModal(false)}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <h3>Create New User</h3>
            <form onSubmit={handleCreateUser}>
              <div className="form-group">
                <label>Username</label>
                <input 
                  type="text" 
                  value={newUser.username}
                  onChange={(e) => setNewUser({...newUser, username: e.target.value})}
                  required 
                />
              </div>
              <div className="form-group">
                <label>Email</label>
                <input 
                  type="email" 
                  value={newUser.email}
                  onChange={(e) => setNewUser({...newUser, email: e.target.value})}
                  required 
                />
              </div>
              <div className="form-group">
                <label>Password</label>
                <input 
                  type="password" 
                  value={newUser.password}
                  onChange={(e) => setNewUser({...newUser, password: e.target.value})}
                  required 
                />
              </div>
              <div className="form-group">
                <label>Role</label>
                <select 
                  value={newUser.role}
                  onChange={(e) => setNewUser({...newUser, role: e.target.value})}
                >
                  <option value="participant">Participant</option>
                  <option value="creator">Quiz Creator</option>
                  <option value="admin">Admin</option>
                </select>
              </div>
              <div className="modal-actions">
                <button type="button" className="btn btn-secondary" onClick={() => setShowUserModal(false)}>
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary">
                  Create User
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}