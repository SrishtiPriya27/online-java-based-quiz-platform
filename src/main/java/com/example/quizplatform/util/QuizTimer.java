package com.example.quizplatform.util;

public class QuizTimer {
    private long startTime;
    private int durationMinutes;

    public QuizTimer(int durationMinutes) {
        this.durationMinutes = durationMinutes;
        this.startTime = System.currentTimeMillis();
    }

    public long getElapsedMinutes() {
        long elapsedMillis = System.currentTimeMillis() - startTime;
        return elapsedMillis / (60 * 1000);
    }

    public long getElapsedSeconds() {
        long elapsedMillis = System.currentTimeMillis() - startTime;
        return elapsedMillis / 1000;
    }

    public long getRemainingMinutes() {
        long elapsed = getElapsedMinutes();
        return Math.max(0, durationMinutes - elapsed);
    }

    public boolean isExpired() {
        return getElapsedMinutes() >= durationMinutes;
    }

    public long getStartTime() {
        return startTime;
    }

    public int getDurationMinutes() {
        return durationMinutes;
    }
}
