import React, { useState } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import Login from './components/Login';
import QuizList from './components/QuizList';
import QuizAttempt from './components/QuizAttempt';
import Results from './components/Results';
import './App.css';

export default function App() {
  const [user, setUser] = useState(null);

  return (
    <BrowserRouter>
      <div className="app">
        <header className="app-header">
          <h1>📝 Quiz Platform</h1>
          {user && (
            <div className="user-info">
              <span>Welcome, {user.username}!</span>
              <button onClick={() => setUser(null)}>Logout</button>
            </div>
          )}
        </header>
        
        <main className="app-main">
          <Routes>
            <Route 
              path="/" 
              element={user ? <Navigate to="/quizzes" /> : <Login setUser={setUser} />} 
            />
            <Route 
              path="/quizzes" 
              element={user ? <QuizList user={user} /> : <Navigate to="/" />} 
            />
            <Route 
              path="/quiz/:quizId" 
              element={user ? <QuizAttempt user={user} /> : <Navigate to="/" />} 
            />
            <Route 
              path="/results/:attemptId" 
              element={user ? <Results user={user} /> : <Navigate to="/" />} 
            />
          </Routes>
        </main>
      </div>
    </BrowserRouter>
  );
}