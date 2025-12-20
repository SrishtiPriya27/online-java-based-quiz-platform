package com.example.quizplatform.dao;

import com.example.quizplatform.model.Quiz;
import java.util.ArrayList;
import java.util.List;

public class QuizDAO {

    public List<Quiz> getAllQuizzes() {
        return new ArrayList<>();
    }

    public List<Quiz> getActiveQuizzes() {
        return new ArrayList<>();
    }

    public Quiz getQuizById(int quizId) {
        return null;
    }

    public boolean createQuiz(Quiz quiz) {
        return true;
    }

    public boolean updateQuiz(Quiz quiz) {
        return true;
    }

    public boolean deleteQuiz(int quizId) {
        return true;
    }

    public boolean toggleQuizStatus(int quizId) {
        return true;
    }

    // Return quizzes created by a specific creator (stub)
    public List<Quiz> getQuizzesByCreator(int creatorId) {
        return new ArrayList<>();
    }

    // Statistics (stubs)
    public int getTotalQuizCount() {
        return 0;
    }

    public int getActiveQuizCount() {
        return 0;
    }
}
