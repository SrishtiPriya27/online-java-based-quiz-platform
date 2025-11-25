import React, { useState } from 'react';

import { useNavigate } from 'react-router-dom';



export default function Login({ setUser }) {

  const [username, setUsername] = useState('');

  const [password, setPassword] = useState('');

  const [loading, setLoading] = useState(false);

  const [error, setError] = useState('');

  const navigate = useNavigate();



  const handleLogin = async (e) => {

    e.preventDefault();

    setLoading(true);

    setError('');



    try {

      const response = await fetch('http://localhost:3000/api/login', {

        method: 'POST',

        headers: {

          'Content-Type': 'application/json',

        },

        body: JSON.stringify({ username, password }),

      });



      const data = await response.json();



      if (response.ok) {

        setUser(data.user);

        localStorage.setItem('user', JSON.stringify(data.user));

        

        // Navigate based on role

        switch(data.user.role) {

          case 'admin':

            navigate('/admin');

            break;

          case 'creator':

            navigate('/creator');

            break;

          case 'participant':

            navigate('/participant');

            break;

          default:

            navigate('/');

        }

      } else {

        setError(data.message || 'Login failed');

      }

    } catch (err) {

      setError('An error occurred. Please try again.');

      console.error('Login error:', err);

    } finally {

      setLoading(false);

    }

  };



  return (

    <div className="login-container">

      <div className="login-card">

        <h2>Login to Quiz Platform</h2>

        {error && <div className="error-message">{error}</div>}

        <form onSubmit={handleLogin}>

          <div className="form-group">

            <label htmlFor="username">Username</label>

            <input

              id="username"

              type="text"

              value={username}

              onChange={(e) => setUsername(e.target.value)}

              placeholder="Enter username"

              required

              disabled={loading}

            />

          </div>

          <div className="form-group">

            <label htmlFor="password">Password</label>

            <input

              id="password"

              type="password"

              value={password}

              onChange={(e) => setPassword(e.target.value)}

              placeholder="Enter password"

              required

              disabled={loading}

            />

          </div>

          <button type="submit" disabled={loading} className="login-btn">

            {loading ? 'Logging in...' : 'Login'}

          </button>

        </form>

        <div className="demo-credentials">

          <p><strong>Demo Credentials:</strong></p>

          <p>Admin: admin / admin123</p>

          <p>Creator: creator / creator123</p>

          <p>Participant: participant / participant123</p>

        </div>

      </div>

    </div>

  );

}