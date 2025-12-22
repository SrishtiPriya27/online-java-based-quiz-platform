📝 Online Quiz Platform

📌 Project Overview

The Online Quiz Platform is a Java-based web application that allows users to take quizzes online.
It supports different user roles such as Admin, Quiz Creator, and Participant.
The application is built using Java, JSP, Servlets, and MySQL, and runs on Apache Tomcat.

🏗️ Project Structure
```bash
quiz-platform
│
├── src
│   └── main
│       ├── java
│       │   └── com.example.quizplatform
│       │       ├── dao
│       │       │   ├── UserDAO.java
│       │       │   ├── QuizDAO.java
│       │       │   └── AttemptDAO.java
│       │       │
│       │       ├── model
│       │       │   ├── User.java
│       │       │   ├── Quiz.java
│       │       │   └── Attempt.java
│       │       │
│       │       ├── service
│       │       │   ├── UserService.java
│       │       │   ├── QuizService.java
│       │       │   └── AttemptService.java
│       │       │
│       │       ├── util
│       │       │   ├── DBUtil.java
│       │       │   ├── PasswordUtil.java
│       │       │   └── QuizTimer.java
│       │       │
│       │       └── web
│       │           ├── servlet
│       │           └── filter
│       │
│       └── webapp
│           ├── admin
│           │   ├── quizzes.jsp
│           │   ├── users.jsp
│           │   └── reports.jsp
│           │
│           ├── creator
│           │   ├── create-quiz.jsp
│           │   └── dashboard.jsp
│           │
│           ├── participant
│           │   ├── dashboard.jsp
│           │   ├── take-quiz.jsp
│           │   └── leaderboard.jsp
│           │
│           ├── css
│           │   └── style.css
│           │
│           ├── WEB-INF
│           │   └── web.xml
│           │
│           └── login.jsp
│
├── pom.xml
└── README.md
```
📂 Folder Explanation

dao → Handles all database operations

model → Represents application data (User, Quiz, Attempt)

service → Contains business logic

util → Helper classes (database connection, password hashing, timer)

servlet → Handles HTTP requests and responses

webapp → Contains JSP pages and frontend resources

WEB-INF → Configuration files (not directly accessible)

🧰 Technology Stack
🔹 Backend

Java
JSP (Java Server Pages)

Servlets
JDBC

🔹 Frontend
HTML
CSS
JSP

🔹 Database
MySQL

🔹 Server
Apache Tomcat 9

🔹 Build Tool
Maven

🔹 IDE
Eclipse IDE


⚙️ How to Run the Project

Import the project into Eclipse as a Maven Project
Configure Apache Tomcat 9 in Eclipse
Set up the MySQL database
Update database credentials in DBUtil.java
Run the project on Tomcat

Open in browser:

http://localhost:8081/quiz-platform/login.jsp

👩‍🎓 Author
 Srishti Priya(Team Leader)
 Swarnika Singh(Member)
 Khushi Kumari(Member)
