package com.example.quizplatform.web.servlet;

import com.example.quizplatform.model.Attempt;
import com.example.quizplatform.model.User;
import com.example.quizplatform.service.AttemptService;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.lang.reflect.Type;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/AttemptServlet")
public class AttemptServlet extends HttpServlet {

    private AttemptService attemptService;
    private Gson gson;

    @Override
    public void init() {
        attemptService = new AttemptService();
        gson = new Gson();
    }

    /* ===================== GET ===================== */
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Login required\"}");
            return;
        }

        String action = request.getParameter("action");
        String role = user.getRole().toLowerCase();

        try {
            if ("myAttempts".equals(action)) {

                List<Attempt> attempts =
                        attemptService.getAttemptsByUserId(user.getUserId());
                response.getWriter().write(gson.toJson(attempts));

            } else if ("leaderboard".equals(action)) {

                int quizId = Integer.parseInt(request.getParameter("quizId"));
                response.getWriter()
                        .write(gson.toJson(attemptService.getLeaderboard(quizId)));

            } else if ("quizAttempts".equals(action)) {

                if (!role.equals("creator") && !role.equals("admin")) {
                    forbidden(response);
                    return;
                }

                int quizId = Integer.parseInt(request.getParameter("quizId"));
                response.getWriter()
                        .write(gson.toJson(attemptService.getAttemptsByQuizId(quizId)));

            } else if ("get".equals(action)) {

                int attemptId = Integer.parseInt(request.getParameter("attemptId"));
                Attempt attempt = attemptService.getAttemptById(attemptId);

                if (attempt == null ||
                        (!role.equals("admin")
                                && attempt.getUserId() != user.getUserId())) {
                    forbidden(response);
                    return;
                }

                response.getWriter().write(gson.toJson(attempt));

            } else if ("all".equals(action)) {

                if (!role.equals("admin")) {
                    forbidden(response);
                    return;
                }

                response.getWriter()
                        .write(gson.toJson(attemptService.getAllAttempts()));

            } else if ("stats".equals(action)) {

                Map<String, Object> stats = new HashMap<>();
                stats.put("totalAttempts",
                        attemptService.getAttemptCountByUser(user.getUserId()));
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

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Login required\"}");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("submit".equals(action)) {

                int quizId = Integer.parseInt(request.getParameter("quizId"));
                int timeTakenMinutes =
                        Integer.parseInt(request.getParameter("timeTaken"));

                String answersJson = request.getParameter("answers");

                Type type = new TypeToken<Map<String, String>>() {}.getType();
                Map<String, String> rawMap =
                        answersJson != null
                                ? gson.fromJson(answersJson, type)
                                : new HashMap<>();

                Map<Integer, String> answers = new HashMap<>();
                for (Map.Entry<String, String> e : rawMap.entrySet()) {
                    answers.put(Integer.parseInt(e.getKey()), e.getValue());
                }

                Attempt attempt = attemptService.submitAttempt(
                        quizId,
                        user.getUserId(),
                        answers,
                        timeTakenMinutes
                );

                writeResult(response,
                        attempt != null,
                        attempt,
                        "Quiz submitted successfully",
                        "Failed to submit quiz");

            } else if ("delete".equals(action)) {

                if (!user.getRole().equalsIgnoreCase("admin")) {
                    forbidden(response);
                    return;
                }

                int attemptId = Integer.parseInt(request.getParameter("attemptId"));
                boolean success = attemptService.deleteAttempt(attemptId);

                writeResult(response,
                        success,
                        null,
                        "Attempt deleted successfully",
                        "Failed to delete attempt");

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
                             Attempt attempt,
                             String successMsg,
                             String failureMsg) throws IOException {

        Map<String, Object> result = new HashMap<>();
        result.put("success", success);
        result.put("attempt", attempt);
        result.put("message", success ? successMsg : failureMsg);
        response.getWriter().write(gson.toJson(result));
    }
}
