import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';

export default function QuizList({ user }) {
  const [quizzes, setQuizzes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  useEffect(() => {
    loadQuizzes();
  }, []);

  const loadQuizzes = async () => {
    try {
      const response = await axios.get('/quizweb/api/quizzes', {
        withCredentials: true
      });
      setQuizzes(response.data);
    } catch (err) {
      setError('Failed to load quizzes');
      console.error('Error loading quizzes:', err);
    } finally {
      setLoading(false);
    }
  };

  const isQuizAvailable = (quiz) => {
    const now = new Date();
    const start = quiz.startTime ? new Date(quiz.startTime) : null;
    const end = quiz.endTime ? new Date(quiz.endTime) : null;

    if (start && now < start) return false;
    if (end && now > end) return false;
    return true;
  };

  const formatDateTime = (dateString) => {
    if (!dateString) return 'N/A';
    return new Date(dateString).toLocaleString();
  };

  if (loading) {
    return <div className="loading">Loading quizzes...</div>;
  }

  return (
    <div className="quiz-list-container">
      <h2>Available Quizzes</h2>
      
      {error && <div className="error-message">{error}</div>}
      
      {quizzes.length === 0 ? (
        <p className="no-quizzes">No quizzes available at the moment.</p>
      ) : (
        <div className="quiz-grid">
          {quizzes.map((quiz) => {
            const available = isQuizAvailable(quiz);
            
            return (
              <div 
                key={quiz.id} 
                className={`quiz-card ${!available ? 'quiz-unavailable' : ''}`}
              >
                <h3>{quiz.title}</h3>
                <div className="quiz-details">
                  <p>⏱️ Duration: {quiz.durationMinutes} minutes</p>
                  <p>📅 Start: {formatDateTime(quiz.startTime)}</p>
                  <p>📅 End: {formatDateTime(quiz.endTime)}</p>
                  {quiz.description && (
                    <p className="quiz-description">{quiz.description}</p>
                  )}
                </div>
                
                {available ? (
                  <button 
                    onClick={() => navigate(`/quiz/${quiz.id}`)}
                    className="btn-primary"
                  >
                    Start Quiz
                  </button>
                ) : (
                  <button className="btn-disabled" disabled>
                    Not Available
                  </button>
                )}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}