import React, { useState, useEffect } from 'react';
import './Dashboard.css';

export default function CreatorDashboard({ user, onLogout }) {
  const [activeTab, setActiveTab] = useState('quizzes');
  const [quizzes, setQuizzes] = useState([]);
  const [showQuizModal, setShowQuizModal] = useState(false);
  const [newQuiz, setNewQuiz] = useState({
    title: '',
    description: '',
    duration: 30,
    questions: []
  });
  const [currentQuestion, setCurrentQuestion] = useState({
    question: '',
    options: ['', '', '', ''],
    correctAnswer: 0
  });

  useEffect(() => {
    fetchQuizzes();
  }, []);

  const fetchQuizzes = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch('http://localhost:3000/api/creator/quizzes', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      const data = await response.json();
      setQuizzes(data);
    } catch (err) {
      console.error('Error fetching quizzes:', err);
    }
  };

  const handleAddQuestion = () => {
    if (currentQuestion.question && currentQuestion.options.every(opt => opt)) {
      setNewQuiz({
        ...newQuiz,
        questions: [...newQuiz.questions, currentQuestion]
      });
      setCurrentQuestion({
        question: '',
        options: ['', '', '', ''],
        correctAnswer: 0
      });
    } else {
      alert('Please fill all question fields');
    }
  };

  const handleCreateQuiz = async (e) => {
    e.preventDefault();
    if (newQuiz.questions.length === 0) {
      alert('Please add at least one question');
      return;
    }

    try {
      const token = localStorage.getItem('token');
      const response = await fetch('http://localhost:3000/api/creator/quizzes', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(newQuiz)
      });

      if (response.ok) {
        alert('Quiz created successfully!');
        setShowQuizModal(false);
        setNewQuiz({ title: '', description: '', duration: 30, questions: [] });
        fetchQuizzes();
      } else {
        alert('Failed to create quiz');
      }
    } catch (err) {
      console.error('Error creating quiz:', err);
    }
  };

  const handleDeleteQuiz = async (quizId) => {
    if (!window.confirm('Are you sure you want to delete this quiz?')) return;

    try {
      const token = localStorage.getItem('token');
      const response = await fetch(`http://localhost:3000/api/creator/quizzes/${quizId}`, {
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${token}` }
      });

      if (response.ok) {
        alert('Quiz deleted successfully!');
        fetchQuizzes();
      }
    } catch (err) {
      console.error('Error deleting quiz:', err);
    }
  };

  return (
    <div className="dashboard">
      <aside className="sidebar">
        <h2>Creator Panel</h2>
        <nav>
          <ul>
            <li>
              <a 
                href="#quizzes" 
                className={activeTab === 'quizzes' ? 'active' : ''}
                onClick={() => setActiveTab('quizzes')}
              >
                📝 My Quizzes
              </a>
            </li>
            <li>
              <a 
                href="#results" 
                className={activeTab === 'results' ? 'active' : ''}
                onClick={() => setActiveTab('results')}
              >
                📊 Quiz Results
              </a>
            </li>
            <li>
              <a 
                href="#participants" 
                className={activeTab === 'participants' ? 'active' : ''}
                onClick={() => setActiveTab('participants')}
              >
                👥 Participants
              </a>
            </li>
          </ul>
        </nav>
        <button className="logout-btn" onClick={onLogout}>Logout</button>
      </aside>

      <main className="main-content">
        <div className="header">
          <h1>Quiz Creator Dashboard</h1>
          <div className="user-info">
            <div className="user-avatar">{user.username.charAt(0).toUpperCase()}</div>
            <span>{user.username}</span>
          </div>
        </div>

        {activeTab === 'quizzes' && (
          <div className="card">
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
              <h3>My Quizzes</h3>
              <button className="btn btn-primary" onClick={() => setShowQuizModal(true)}>
                + Create Quiz
              </button>
            </div>
            <div className="quiz-grid">
              {quizzes.map(quiz => (
                <div key={quiz.id} className="quiz-card">
                  <h4>{quiz.title}</h4>
                  <p>{quiz.description}</p>
                  <div className="quiz-meta">
                    <span>⏱️ {quiz.duration} min</span>
                    <span>❓ {quiz.questions?.length || 0} questions</span>
                    <span className={`badge badge-${quiz.status}`}>{quiz.status}</span>
                  </div>
                  <div className="quiz-actions">
                    <button className="btn btn-secondary btn-sm">View</button>
                    <button className="btn btn-secondary btn-sm">Edit</button>
                    <button 
                      className="btn btn-danger btn-sm"
                      onClick={() => handleDeleteQuiz(quiz.id)}
                    >
                      Delete
                    </button>
                  </div>
                </div>
              ))}
              {quizzes.length === 0 && (
                <p className="empty-state">No quizzes created yet. Click "Create Quiz" to get started!</p>
              )}
            </div>
          </div>
        )}

        {activeTab === 'results' && (
          <div className="card">
            <h3>Quiz Results & Analytics</h3>
            <p>View detailed performance analytics and participant results here.</p>
          </div>
        )}

        {activeTab === 'participants' && (
          <div className="card">
            <h3>Participant Interactions</h3>
            <p>Communicate with quiz participants and view their feedback.</p>
          </div>
        )}
      </main>

      {showQuizModal && (
        <div className="modal-overlay" onClick={() => setShowQuizModal(false)}>
          <div className="modal modal-lg" onClick={(e) => e.stopPropagation()}>
            <h3>Create New Quiz</h3>
            <form onSubmit={handleCreateQuiz}>
              <div className="form-group">
                <label>Quiz Title</label>
                <input 
                  type="text" 
                  value={newQuiz.title}
                  onChange={(e) => setNewQuiz({...newQuiz, title: e.target.value})}
                  required 
                />
              </div>
              <div className="form-group">
                <label>Description</label>
                <textarea 
                  value={newQuiz.description}
                  onChange={(e) => setNewQuiz({...newQuiz, description: e.target.value})}
                  rows="3"
                  required
                />
              </div>
              <div className="form-group">
                <label>Duration (minutes)</label>
                <input 
                  type="number" 
                  value={newQuiz.duration}
                  onChange={(e) => setNewQuiz({...newQuiz, duration: parseInt(e.target.value)})}
                  min="5"
                  required 
                />
              </div>

              <hr />
              <h4>Add Questions ({newQuiz.questions.length} added)</h4>
              
              <div className="form-group">
                <label>Question</label>
                <textarea 
                  value={currentQuestion.question}
                  onChange={(e) => setCurrentQuestion({...currentQuestion, question: e.target.value})}
                  rows="2"
                  placeholder="Enter your question here"
                />
              </div>

              {currentQuestion.options.map((option, index) => (
                <div className="form-group" key={index}>
                  <label>Option {index + 1}</label>
                  <input 
                    type="text" 
                    value={option}
                    onChange={(e) => {
                      const newOptions = [...currentQuestion.options];
                      newOptions[index] = e.target.value;
                      setCurrentQuestion({...currentQuestion, options: newOptions});
                    }}
                    placeholder={`Option ${index + 1}`}
                  />
                </div>
              ))}

              <div className="form-group">
                <label>Correct Answer</label>
                <select 
                  value={currentQuestion.correctAnswer}
                  onChange={(e) => setCurrentQuestion({...currentQuestion, correctAnswer: parseInt(e.target.value)})}
                >
                  <option value={0}>Option 1</option>
                  <option value={1}>Option 2</option>
                  <option value={2}>Option 3</option>
                  <option value={3}>Option 4</option>
                </select>
              </div>

              <button 
                type="button" 
                className="btn btn-secondary" 
                onClick={handleAddQuestion}
                style={{ marginBottom: '20px' }}
              >
                + Add Question
              </button>

              {newQuiz.questions.length > 0 && (
                <div className="questions-preview">
                  <h5>Added Questions:</h5>
                  {newQuiz.questions.map((q, idx) => (
                    <div key={idx} className="question-preview-item">
                      <strong>Q{idx + 1}:</strong> {q.question}
                    </div>
                  ))}
                </div>
              )}

              <div className="modal-actions">
                <button type="button" className="btn btn-secondary" onClick={() => setShowQuizModal(false)}>
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary">
                  Create Quiz
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}