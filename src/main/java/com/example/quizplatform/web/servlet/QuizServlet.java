package com.example.quizplatform.web.servlet;

import com.example.quizplatform.model.Quiz;
import com.example.quizplatform.model.User;
import com.example.quizplatform.service.QuizService;
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

@WebServlet("/QuizServlet")
public class QuizServlet extends HttpServlet {

    private QuizService quizService;
    private Gson gson;

    @Override
    public void init() {
        quizService = new QuizService();
        gson = new Gson();
    }

    /* ===================== GET ===================== */
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Login required\"}");
            return;
        }

        String role = user.getRole().toLowerCase();

        try {
            if ("list".equals(action)) {
                // everyone can list active quizzes
                List<Quiz> quizzes = quizService.getActiveQuizzes();
                response.getWriter().write(gson.toJson(quizzes));

            } else if ("myQuizzes".equals(action)) {
                // creator only
                if (!role.equals("creator") && !role.equals("admin")) {
                    forbidden(response);
                    return;
                }
                List<Quiz> quizzes = quizService.getQuizzesByCreator(user.getUserId());
                response.getWriter().write(gson.toJson(quizzes));

            } else if ("get".equals(action)) {
                int quizId = Integer.parseInt(request.getParameter("quizId"));
                Quiz quiz = quizService.getQuizById(quizId);
                response.getWriter().write(gson.toJson(quiz));

            } else if ("stats".equals(action)) {
                // admin only
                if (!role.equals("admin")) {
                    forbidden(response);
                    return;
                }
                Map<String, Integer> stats = new HashMap<>();
                stats.put("total", quizService.getTotalQuizCount());
                stats.put("active", quizService.getActiveQuizCount());
                response.getWriter().write(gson.toJson(stats));

            } else {
                badRequest(response);
            }

        } catch (Exception e) {
            serverError(response, e);
        }
    }

    /* ===================== POST ===================== */
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Login required\"}");
            return;
        }

        String role = user.getRole().toLowerCase();

        try {
            if ("create".equals(action)) {
                // creator or admin
                if (!role.equals("creator") && !role.equals("admin")) {
                    forbidden(response);
                    return;
                }

                Quiz quiz = new Quiz();
                quiz.setTitle(request.getParameter("title"));
                quiz.setDescription(request.getParameter("description"));
                quiz.setCreatorId(user.getUserId());
                quiz.setDurationMinutes(Integer.parseInt(request.getParameter("duration")));
                quiz.setPassingScore(Double.parseDouble(request.getParameter("passingScore")));
                quiz.setActive(true);

                boolean success = quizService.createQuiz(quiz);
                writeResult(response, success,
                        "Quiz created successfully",
                        "Failed to create quiz");

            } else if ("update".equals(action)) {
                // creator or admin
                if (!role.equals("creator") && !role.equals("admin")) {
                    forbidden(response);
                    return;
                }

                Quiz quiz = new Quiz();
                quiz.setQuizId(Integer.parseInt(request.getParameter("quizId")));
                quiz.setTitle(request.getParameter("title"));
                quiz.setDescription(request.getParameter("description"));
                quiz.setDurationMinutes(Integer.parseInt(request.getParameter("duration")));
                quiz.setPassingScore(Double.parseDouble(request.getParameter("passingScore")));
                quiz.setActive(Boolean.parseBoolean(request.getParameter("isActive")));

                boolean success = quizService.updateQuiz(quiz);
                writeResult(response, success,
                        "Quiz updated successfully",
                        "Failed to update quiz");

            } else if ("toggle".equals(action)) {
                // admin only
                if (!role.equals("admin")) {
                    forbidden(response);
                    return;
                }

                int quizId = Integer.parseInt(request.getParameter("quizId"));
                boolean success = quizService.toggleQuizStatus(quizId);
                writeResult(response, success,
                        "Quiz status updated",
                        "Failed to update quiz status");

            } else if ("delete".equals(action)) {
                // admin only
                if (!role.equals("admin")) {
                    forbidden(response);
                    return;
                }

                int quizId = Integer.parseInt(request.getParameter("quizId"));
                boolean success = quizService.deleteQuiz(quizId);
                writeResult(response, success,
                        "Quiz deleted successfully",
                        "Failed to delete quiz");

            } else {
                badRequest(response);
            }

        } catch (Exception e) {
            serverError(response, e);
        }
    }

    /* ===================== HELPERS ===================== */

    private void forbidden(HttpServletResponse response) throws IOException {
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        response.getWriter().write("{\"error\":\"Access denied\"}");
    }

    private void badRequest(HttpServletResponse response) throws IOException {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        response.getWriter().write("{\"error\":\"Invalid action\"}");
    }

    private void serverError(HttpServletResponse response, Exception e)
            throws IOException {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
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
