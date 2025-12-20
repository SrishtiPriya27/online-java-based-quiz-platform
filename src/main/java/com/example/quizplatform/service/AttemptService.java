package com.example.quizplatform.service;

import com.example.quizplatform.dao.AttemptDAO;
import com.example.quizplatform.dao.QuestionDAO;
import com.example.quizplatform.dao.QuizDAO;
import com.example.quizplatform.model.Attempt;
import com.example.quizplatform.model.Question;
import com.example.quizplatform.model.Quiz;

import java.util.List;
import java.util.Map;

public class AttemptService {
    private final AttemptDAO attemptDAO;
    private final QuestionDAO questionDAO;
    private final QuizDAO quizDAO;

    public AttemptService() {
        this.attemptDAO = new AttemptDAO();
        this.questionDAO = new QuestionDAO();
        this.quizDAO = new QuizDAO();
    }

    public Attempt submitAttempt(int quizId,
                                 int userId,
                                 Map<Integer, String> answers,
                                 int timeTakenMinutes) {

        List<Question> questions = questionDAO.getQuestionsByQuizId(quizId);

        if (questions == null || questions.isEmpty()) {
            return null;
        }

        int correctAnswers = 0;
        int totalPoints = 0;
        int earnedPoints = 0;

        for (Question question : questions) {
            totalPoints += question.getPoints();
            String userAnswer = answers.get(question.getQuestionId());

            if (userAnswer != null &&
                userAnswer.equalsIgnoreCase(question.getCorrectAnswer())) {
                correctAnswers++;
                earnedPoints += question.getPoints();
            }
        }

        double score = totalPoints > 0
                ? (earnedPoints * 100.0 / totalPoints)
                : 0;

        Attempt attempt = new Attempt();
        attempt.setQuizId(quizId);
        attempt.setUserId(userId);
        attempt.setScore(score);
        attempt.setTotalQuestions(questions.size());
        attempt.setCorrectAnswers(correctAnswers);
       attempt.setTimeTakenSeconds(timeTakenMinutes * 60);


        if (!attemptDAO.createAttempt(attempt)) {
            return null;
        }

        for (Question question : questions) {
            String userAnswer = answers.get(question.getQuestionId());
            boolean isCorrect = userAnswer != null &&
                    userAnswer.equalsIgnoreCase(question.getCorrectAnswer());

            attemptDAO.saveAttemptAnswers(
                    attempt.getAttemptId(),
                    question.getQuestionId(),
                    userAnswer != null ? userAnswer : "",
                    isCorrect
            );
        }

        Quiz quiz = quizDAO.getQuizById(quizId);
        if (quiz != null) {
            attempt.setPassed(score >= quiz.getPassingScore());
        }

        return attempt;
    }

    public Attempt getAttemptById(int attemptId) {
        return attemptDAO.getAttemptById(attemptId);
    }

    public List<Attempt> getAttemptsByUserId(int userId) {
        return attemptDAO.getAttemptsByUserId(userId);
    }

    public List<Attempt> getAttemptsByQuizId(int quizId) {
        return attemptDAO.getAttemptsByQuizId(quizId);
    }

    public List<Attempt> getAllAttempts() {
        return attemptDAO.getAllAttempts();
    }

    public List<Attempt> getLeaderboard(int quizId) {
        return attemptDAO.getLeaderboard(quizId);
    }

    public int getTotalAttemptCount() {
        return attemptDAO.getTotalAttemptCount();
    }

    public int getAttemptCountByUser(int userId) {
        return attemptDAO.getAttemptCountByUserId(userId);
    }

    public double getAverageScore(int quizId) {
        return attemptDAO.getAverageScoreByQuizId(quizId);
    }

    public boolean deleteAttempt(int attemptId) {
        return attemptDAO.deleteAttempt(attemptId);
    }
}

