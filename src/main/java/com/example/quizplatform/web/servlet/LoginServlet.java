package com.example.quizplatform.web.servlet;

import com.example.quizplatform.model.User;
import com.example.quizplatform.service.UserService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private UserService userService;

    @Override
    public void init() throws ServletException {
        userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        User user = userService.authenticateUser(username, password);

        if (user == null) {
            response.sendRedirect(request.getContextPath()
                    + "/login.jsp?error=invalid_credentials");
            return;
        }

        HttpSession session = request.getSession(true);
        session.setAttribute("user", user);
        session.setMaxInactiveInterval(60 * 60); // 1 hour

        String role = user.getRole().toLowerCase();
        String contextPath = request.getContextPath();

        switch (role) {
            case "admin":
                response.sendRedirect(contextPath + "/admin/dashboard.jsp");
                break;
            case "creator":
                response.sendRedirect(contextPath + "/creator/dashboard.jsp");
                break;
            case "participant":
                response.sendRedirect(contextPath + "/participant/dashboard.jsp");
                break;
            default:
                session.invalidate();
                response.sendRedirect(contextPath + "/login.jsp?error=invalid_role");
        }
    }
}

