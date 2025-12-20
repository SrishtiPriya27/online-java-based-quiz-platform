package com.example.quizplatform.model;

import java.sql.Timestamp;

public class Attempt {

    private int attemptId;
    private int quizId;
    private int userId;

    // Extra fields from JOIN queries
    private String username;
    private String quizTitle;

    private double score;
    private int totalQuestions;
    private int correctAnswers;

    // IMPORTANT: use seconds (matches DB + DAO)
    private int timeTakenSeconds;

    private Timestamp attemptedAt;
    private boolean passed;

    // Constructors
    public Attempt() {
    }

    public Attempt(int attemptId, int quizId, int userId, double score,
                   int totalQuestions, int correctAnswers, int timeTakenSeconds) {
        this.attemptId = attemptId;
        this.quizId = quizId;
        this.userId = userId;
        this.score = score;
        this.totalQuestions = totalQuestions;
        this.correctAnswers = correctAnswers;
        this.timeTakenSeconds = timeTakenSeconds;
    }

    // Getters and Setters
    public int getAttemptId() {
        return attemptId;
    }

    public void setAttemptId(int attemptId) {
        this.attemptId = attemptId;
    }

    public int getQuizId() {
        return quizId;
    }

    public void setQuizId(int quizId) {
        this.quizId = quizId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getQuizTitle() {
        return quizTitle;
    }

    public void setQuizTitle(String quizTitle) {
        this.quizTitle = quizTitle;
    }

    public double getScore() {
        return score;
    }

    public void setScore(double score) {
        this.score = score;
    }

    public int getTotalQuestions() {
        return totalQuestions;
    }

    public void setTotalQuestions(int totalQuestions) {
        this.totalQuestions = totalQuestions;
    }

    public int getCorrectAnswers() {
        return correctAnswers;
    }

    public void setCorrectAnswers(int correctAnswers) {
        this.correctAnswers = correctAnswers;
    }

    public int getTimeTakenSeconds() {
        return timeTakenSeconds;
    }

    public void setTimeTakenSeconds(int timeTakenSeconds) {
        this.timeTakenSeconds = timeTakenSeconds;
    }

    public Timestamp getAttemptedAt() {
        return attemptedAt;
    }

    public void setAttemptedAt(Timestamp attemptedAt) {
        this.attemptedAt = attemptedAt;
    }

    public boolean isPassed() {
        return passed;
    }

    public void setPassed(boolean passed) {
        this.passed = passed;
    }

    // Utility method
    public double getPercentage() {
        return totalQuestions > 0
                ? (correctAnswers * 100.0) / totalQuestions
                : 0.0;
    }

    @Override
    public String toString() {
        return "Attempt{" +
                "attemptId=" + attemptId +
                ", quizId=" + quizId +
                ", userId=" + userId +
                ", score=" + score +
                ", correctAnswers=" + correctAnswers +
                ", totalQuestions=" + totalQuestions +
                ", timeTakenSeconds=" + timeTakenSeconds +
                '}';
    }
}
