# Online Java-Based Quiz Platform

A simple React + Vite frontend for a Java-based quiz platform (backend expected to be a Java server that exposes APIs for authentication, quizzes, attempts, admin/creator actions, etc.).

## 🚀 Overview

This repository contains the frontend application for an online quiz platform. It provides an interface for three user roles:
- **Admin**: Manages users and quizzes, checks stats.
- **Creator**: Creates and manages quizzes and questions.
- **Participant**: Views available quizzes, attempts them, and views results.

The frontend is built with React, Vite, and uses axios/fetch for API requests.

## 🧰 Tech Stack
- React
- Vite
- axios
- react-router-dom

## 🗂️ Project Structure
```
frontend/
  ├─ package.json
  ├─ vite.config.js        # dev server + proxy config
  └─ src/
     ├─ main.jsx
     ├─ App.jsx
     └─ components/        # Login, Dashboard(s), QuizList, QuizAttempt, Results
```

## 🔁 Development (Local)

Prerequisites: Node.js (>= 18 recommended)

1. Install dependencies:

```powershell
cd frontend
npm install
```

2. Start the dev server:

```powershell
npm run dev
```

By default, Vite is configured to run on port **3000** (see `vite.config.js`) and proxies `'/quizweb/api'` requests to `http://localhost:8080` (backend). Make sure your backend server is running on port 8080 for proxied APIs to work.

> Note: There are some inconsistent API URLs in the code:
> - In `Login.jsx`, login is performed with `fetch('http://localhost:3000/api/login')`, which points to the frontend host and will not automatically get proxied. Ideally this should use a proxied path (e.g. `/api/login`) or an environment variable like `VITE_API_URL` to reference the backend.

## 🔌 Backend Integration
The frontend expects these API endpoints (examples found across components):
- POST `/api/login` — authenticate user (or proxied path like `/login` if using a different prefix)
- GET `/quizweb/api/quizzes` — list quizzes
- GET `/quizweb/api/attempts/{attemptId}/results` — get attempt results
- Admin endpoints: `/api/admin/users`, `/api/admin/quizzes`, `/api/admin/stats`
- Creator endpoints: `/api/creator/quizzes` (create, delete, list)

If you're running the backend on the standard port `8080`, the current `vite.config.js` proxy will forward `'/quizweb/api'` requests to it. Consider aligning the login route to follow the same proxied path pattern or defining a `VITE_API_URL` in `.env` and updating API calls to use it.

## 🔧 Local Development Recommendations
- Make all API calls to proxied paths (e.g., `/quizweb/api/`) so CORS is handled by the dev proxy, unless your backend implements appropriate CORS headers.
- For login, replace absolute URLs with relative ones or env-based endpoints.
- Use `localStorage.setItem('token', ...)` or session-based auth depending on backend tokens implementation.

## 👩‍💻 Demo Credentials
There are demo credentials hard-coded into the login form for testing locally:
- Admin: `admin` / `admin123`
- Creator: `creator` / `creator123`
- Participant: `participant` / `participant123`

These are only for local/demo usage. Make sure to remove any hardcoded credentials in production.

## 📜 Notes / Caveats
- The repository currently contains only the frontend application; the Java backend is expected to run separately.
- A rebase or other git operation could be in progress in your local repo — fix any in-progress git operations before creating commits or pushing. If you run into a rebase conflict, use `git rebase --continue` or `git rebase --abort` as appropriate.
- Several components make assumptions about backend paths and common behaviors; if your backend uses different prefixes, update `vite.config.js`'s proxy or the components accordingly.

## 📘 Contributing
- Fork and open a PR against the `main` branch.
- Please run `npm install` and `npm run dev` to validate changes locally before submitting a PR.

## 📄 License
Add your license here (e.g., MIT) or follow your project's licensing policy.

---

If you'd like, I can also:
- Add a `.env.example` and update `vite.config.js` to use `VITE_API_URL` (or similar) for clearer environment configuration.
- Update `Login.jsx` to use a relative/proxied endpoint instead of the absolute `http://localhost:3000/api/login` URL.

---

## Backend (Java Servlet) Update
The backend has been updated to support a Java 21 Servlet-based implementation. See `backend/README.md` for details on how to build, deploy, and configure the backend (Tomcat 10.1+, MySQL database and JDBC/Hikari configuration).

Let me know how you'd like to proceed.