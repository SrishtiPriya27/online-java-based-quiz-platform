package com.example.quizplatform.service;

import com.example.quizplatform.dao.QuizDAO;
import com.example.quizplatform.model.Quiz;

import java.util.List;

public class QuizService {

    private final QuizDAO quizDAO = new QuizDAO();

    public List<Quiz> getAllQuizzes() {
        return quizDAO.getAllQuizzes();
    }

    public List<Quiz> getActiveQuizzes() {
        return quizDAO.getActiveQuizzes();
    }

    public Quiz getQuizById(int quizId) {
        return quizDAO.getQuizById(quizId);
    }

    public boolean createQuiz(Quiz quiz) {
        return quizDAO.createQuiz(quiz);
    }

    public boolean updateQuiz(Quiz quiz) {
        return quizDAO.updateQuiz(quiz);
    }

    public boolean deleteQuiz(int quizId) {
        return quizDAO.deleteQuiz(quizId);
    }

    public boolean toggleQuizStatus(int quizId) {
        return quizDAO.toggleQuizStatus(quizId);
    }

    public List<Quiz> getQuizzesByCreator(int creatorId) {
        return quizDAO.getQuizzesByCreator(creatorId);
    }

    public int getTotalQuizCount() {
        return quizDAO.getTotalQuizCount();
    }

    public int getActiveQuizCount() {
        return quizDAO.getActiveQuizCount();
    }
}
