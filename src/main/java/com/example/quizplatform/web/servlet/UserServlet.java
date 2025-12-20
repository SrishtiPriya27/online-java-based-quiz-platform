package com.example.quizplatform.web.servlet;

import com.example.quizplatform.model.User;
import com.example.quizplatform.service.UserService;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/UserServlet")
public class UserServlet extends HttpServlet {

    private UserService userService;
    private Gson gson;

    @Override
    public void init() {
        userService = new UserService();
        gson = new Gson();
    }

    /* ===================== GET ===================== */
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // 🔐 Admin-only access
        if (!isAdmin(request)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"error\":\"Access denied\"}");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("list".equals(action)) {

                List<User> users = userService.getAllUsers();
                response.getWriter().write(gson.toJson(users));

            } else if ("get".equals(action)) {

                int userId = Integer.parseInt(request.getParameter("userId"));
                User user = userService.getUserById(userId);
                response.getWriter().write(gson.toJson(user));

            } else if ("stats".equals(action)) {

                Map<String, Integer> stats = new HashMap<>();
                stats.put("total", userService.getTotalUserCount());
                stats.put("admins", userService.getUserCountByRole("admin"));
                stats.put("creators", userService.getUserCountByRole("creator"));
                stats.put("participants", userService.getUserCountByRole("participant"));
                response.getWriter().write(gson.toJson(stats));

            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\":\"Invalid action\"}");
            }

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter()
                    .write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    /* ===================== POST ===================== */
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // 🔐 Admin-only access
        if (!isAdmin(request)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"error\":\"Access denied\"}");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("create".equals(action)) {

                User user = new User();
                user.setUsername(request.getParameter("username"));
                user.setPassword(request.getParameter("password"));
                user.setFullName(request.getParameter("fullName"));
                user.setEmail(request.getParameter("email"));
                user.setRole(request.getParameter("role"));

                boolean success = userService.registerUser(user);
                writeResult(response, success,
                        "User created successfully",
                        "Failed to create user");

            } else if ("update".equals(action)) {

                User user = new User();
                user.setUserId(Integer.parseInt(request.getParameter("userId")));
                user.setFullName(request.getParameter("fullName"));
                user.setEmail(request.getParameter("email"));
                user.setRole(request.getParameter("role"));

                boolean success = userService.updateUser(user);
                writeResult(response, success,
                        "User updated successfully",
                        "Failed to update user");

            } else if ("delete".equals(action)) {

                int userId = Integer.parseInt(request.getParameter("userId"));
                boolean success = userService.deleteUser(userId);

                writeResult(response, success,
                        "User deleted successfully",
                        "Failed to delete user");

            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\":\"Invalid action\"}");
            }

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter()
                    .write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    /* ===================== HELPERS ===================== */

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;

        User user = (User) session.getAttribute("user");
        return user != null && "admin".equalsIgnoreCase(user.getRole());
    }

    private void writeResult(HttpServletResponse response,
                             boolean success,
                             String successMsg,
                             String failureMsg) throws IOException {

        Map<String, Object> result = new HashMap<>();
        result.put("success", success);
        result.put("message", success ? successMsg : failureMsg);
        response.getWriter().write(gson.toJson(result));
    }
}
    