package com.example.quizplatform.dao;

import com.example.quizplatform.model.Attempt;
import com.example.quizplatform.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class AttemptDAO {

    // CREATE ATTEMPT
    public boolean createAttempt(Attempt attempt) {
        String sql = "INSERT INTO attempts " +
                "(quiz_id, user_id, score, total_questions, correct_answers, time_taken_seconds) " +
                "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, attempt.getQuizId());
            stmt.setInt(2, attempt.getUserId());
            stmt.setDouble(3, attempt.getScore());
            stmt.setInt(4, attempt.getTotalQuestions());
            stmt.setInt(5, attempt.getCorrectAnswers());
            stmt.setInt(6, attempt.getTimeTakenSeconds());

            int rows = stmt.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        attempt.setAttemptId(rs.getInt(1));
                    }
                }
                return true;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // SAVE ANSWERS
    public boolean saveAttemptAnswers(int attemptId, int questionId,
                                      String selectedAnswer, boolean isCorrect) {
        String sql = "INSERT INTO attempt_answers " +
                "(attempt_id, question_id, selected_answer, is_correct) " +
                "VALUES (?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, attemptId);
            stmt.setInt(2, questionId);
            stmt.setString(3, selectedAnswer);
            stmt.setBoolean(4, isCorrect);

            return stmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // GET ATTEMPT BY ID
    public Attempt getAttemptById(int attemptId) {
        String sql = "SELECT a.*, u.username, q.title AS quiz_title, q.passing_score " +
                "FROM attempts a " +
                "JOIN users u ON a.user_id = u.user_id " +
                "JOIN quizzes q ON a.quiz_id = q.quiz_id " +
                "WHERE a.id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, attemptId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Attempt attempt = extractAttempt(rs);
                    attempt.setPassed(attempt.getScore() >= rs.getDouble("passing_score"));
                    return attempt;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ATTEMPTS BY USER
    public List<Attempt> getAttemptsByUserId(int userId) {
        List<Attempt> list = new ArrayList<>();
        String sql = "SELECT a.*, u.username, q.title AS quiz_title, q.passing_score " +
                "FROM attempts a " +
                "JOIN users u ON a.user_id = u.user_id " +
                "JOIN quizzes q ON a.quiz_id = q.quiz_id " +
                "WHERE a.user_id = ? " +
                "ORDER BY a.attempt_time DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Attempt attempt = extractAttempt(rs);
                    attempt.setPassed(attempt.getScore() >= rs.getDouble("passing_score"));
                    list.add(attempt);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ATTEMPTS BY QUIZ
    public List<Attempt> getAttemptsByQuizId(int quizId) {
        List<Attempt> list = new ArrayList<>();
        String sql = "SELECT a.*, u.username, q.title AS quiz_title, q.passing_score " +
                "FROM attempts a " +
                "JOIN users u ON a.user_id = u.user_id " +
                "JOIN quizzes q ON a.quiz_id = q.quiz_id " +
                "WHERE a.quiz_id = ? " +
                "ORDER BY a.score DESC, a.time_taken_seconds ASC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, quizId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Attempt attempt = extractAttempt(rs);
                    attempt.setPassed(attempt.getScore() >= rs.getDouble("passing_score"));
                    list.add(attempt);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // LEADERBOARD (top 10)
    public List<Attempt> getLeaderboard(int quizId) {
        List<Attempt> list = new ArrayList<>();
        String sql = "SELECT a.*, u.username, q.title AS quiz_title, q.passing_score " +
                "FROM attempts a " +
                "JOIN users u ON a.user_id = u.user_id " +
                "JOIN quizzes q ON a.quiz_id = q.quiz_id " +
                "WHERE a.quiz_id = ? " +
                "ORDER BY a.score DESC, a.time_taken_seconds ASC " +
                "LIMIT 10";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, quizId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Attempt attempt = extractAttempt(rs);
                    attempt.setPassed(attempt.getScore() >= rs.getDouble("passing_score"));
                    list.add(attempt);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // STATS
    public int getTotalAttemptCount() {
        String sql = "SELECT COUNT(*) FROM attempts";

        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next()) return rs.getInt(1);

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public double getAverageScoreByQuizId(int quizId) {
        String sql = "SELECT AVG(score) FROM attempts WHERE quiz_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, quizId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getDouble(1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    // DELETE
    public boolean deleteAttempt(int attemptId) {
        String sql = "DELETE FROM attempts WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, attemptId);
            return stmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ALL ATTEMPTS
    public List<Attempt> getAllAttempts() {
        List<Attempt> list = new ArrayList<>();
        String sql = "SELECT a.*, u.username, q.title AS quiz_title, q.passing_score " +
                "FROM attempts a " +
                "JOIN users u ON a.user_id = u.user_id " +
                "JOIN quizzes q ON a.quiz_id = q.quiz_id " +
                "ORDER BY a.attempt_time DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Attempt attempt = extractAttempt(rs);
                attempt.setPassed(attempt.getScore() >= rs.getDouble("passing_score"));
                list.add(attempt);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // COUNT BY USER
    public int getAttemptCountByUserId(int userId) {
        String sql = "SELECT COUNT(*) FROM attempts WHERE user_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // HELPER
    private Attempt extractAttempt(ResultSet rs) throws SQLException {
        Attempt attempt = new Attempt();
        // DB columns: id, quiz_id, user_id, score, total_questions, correct_answers, time_taken_seconds, attempt_time
        attempt.setAttemptId(rs.getInt("id"));
        attempt.setQuizId(rs.getInt("quiz_id"));
        attempt.setUserId(rs.getInt("user_id"));
        try {
            attempt.setUsername(rs.getString("username"));
        } catch (SQLException ignore) {
        }
        try {
            attempt.setQuizTitle(rs.getString("quiz_title"));
        } catch (SQLException ignore) {
        }
        attempt.setScore(rs.getDouble("score"));
        attempt.setTotalQuestions(rs.getInt("total_questions"));
        attempt.setCorrectAnswers(rs.getInt("correct_answers"));
        attempt.setTimeTakenSeconds(rs.getInt("time_taken_seconds"));
        attempt.setAttemptedAt(rs.getTimestamp("attempt_time"));
        return attempt;
    }

}
