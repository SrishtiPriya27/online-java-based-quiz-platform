import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import axios from 'axios';

export default function Results({ user }) {
  const { attemptId } = useParams();
  const navigate = useNavigate();
  
  const [results, setResults] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    loadResults();
  }, [attemptId]);

  const loadResults = async () => {
    try {
      const response = await axios.get(`/quizweb/api/attempts/${attemptId}/results`, {
        withCredentials: true
      });
      setResults(response.data);
    } catch (err) {
      setError('Failed to load results');
      console.error('Error loading results:', err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="loading">Loading results...</div>;
  }

  if (error) {
    return (
      <div className="error-container">
        <div className="error-message">{error}</div>
        <button onClick={() => navigate('/quizzes')} className="btn-primary">
          Back to Quizzes
        </button>
      </div>
    );
  }

  if (!results) {
    return <div className="error-message">Results not found</div>;
  }

  const percentage = results.totalMarks > 0 
    ? Math.round((results.score / results.totalMarks) * 100) 
    : 0;

  const getGrade = (percent) => {
    if (percent >= 90) return { grade: 'A+', color: '#10b981' };
    if (percent >= 80) return { grade: 'A', color: '#10b981' };
    if (percent >= 70) return { grade: 'B', color: '#3b82f6' };
    if (percent >= 60) return { grade: 'C', color: '#f59e0b' };
    if (percent >= 50) return { grade: 'D', color: '#f97316' };
    return { grade: 'F', color: '#ef4444' };
  };

  const gradeInfo = getGrade(percentage);

  return (
    <div className="results-container">
      <div className="results-card">
        <h2>Quiz Results</h2>
        
        <div className="score-display">
          <div className="score-circle" style={{ borderColor: gradeInfo.color }}>
            <div className="score-value" style={{ color: gradeInfo.color }}>
              {results.score}
            </div>
            <div className="score-total">out of {results.totalMarks}</div>
          </div>
          
          <div className="grade-info">
            <div className="grade" style={{ color: gradeInfo.color }}>
              {gradeInfo.grade}
            </div>
            <div className="percentage">{percentage}%</div>
          </div>
        </div>

        {results.quizTitle && (
          <div className="quiz-info">
            <h3>{results.quizTitle}</h3>
          </div>
        )}

        {results.submittedAt && (
          <div className="submission-time">
            Submitted: {new Date(results.submittedAt).toLocaleString()}
          </div>
        )}

        {results.questionResults && results.questionResults.length > 0 && (
          <div className="detailed-results">
            <h3>Question Breakdown</h3>
            <div className="question-results">
              {results.questionResults.map((qr, index) => (
                <div 
                  key={qr.questionId || index} 
                  className={`question-result ${qr.marksAwarded === qr.maxMarks ? 'correct' : 'incorrect'}`}
                >
                  <div className="question-header">
                    <span className="question-number">Question {index + 1}</span>
                    <span className="question-score">
                      {qr.marksAwarded} / {qr.maxMarks} marks
                    </span>
                  </div>
                  {qr.questionText && (
                    <p className="question-text-small">{qr.questionText}</p>
                  )}
                  {qr.feedback && (
                    <p className="feedback">{qr.feedback}</p>
                  )}
                </div>
              ))}
            </div>
          </div>
        )}

        <div className="results-actions">
          <button 
            onClick={() => navigate('/quizzes')} 
            className="btn-primary"
          >
            Back to Quizzes
          </button>
        </div>
      </div>
    </div>
  );
}