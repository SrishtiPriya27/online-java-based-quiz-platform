package com.example.quizplatform.model;

import java.util.Date;

public class Quiz {

    private int quizId;
    private String title;
    private String description;
    private int creatorId;
    private int durationMinutes;
    private double passingScore;
    private boolean active;
    private Date createdAt;

    // getters & setters
    public int getQuizId() { return quizId; }
    public void setQuizId(int quizId) { this.quizId = quizId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public int getCreatorId() { return creatorId; }
    public void setCreatorId(int creatorId) { this.creatorId = creatorId; }

    public int getDurationMinutes() { return durationMinutes; }
    public void setDurationMinutes(int durationMinutes) { this.durationMinutes = durationMinutes; }

    public double getPassingScore() { return passingScore; }
    public void setPassingScore(double passingScore) { this.passingScore = passingScore; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}
