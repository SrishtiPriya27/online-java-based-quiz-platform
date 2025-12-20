package com.example.quizplatform.service;

import com.example.quizplatform.dao.UserDAO;
import com.example.quizplatform.model.User;
import com.example.quizplatform.util.PasswordUtil;

import java.util.List;

public class UserService {

    private final UserDAO userDAO;

    public UserService() {
        this.userDAO = new UserDAO();
    }

    /* ================= AUTH ================= */

    public User authenticateUser(String username, String password) {
        if (username == null || password == null) return null;

        String hashedPassword = PasswordUtil.hashPassword(password);
        return userDAO.authenticate(username.trim(), hashedPassword);
    }

    /* ================= READ ================= */

    public User getUserById(int userId) {
        return userDAO.getUserById(userId);
    }

    public User getUserByUsername(String username) {
        return userDAO.getUserByUsername(username);
    }

    public List<User> getAllUsers() {
        return userDAO.getAllUsers();
    }

    public List<User> getUsersByRole(String role) {
        return userDAO.getUsersByRole(role);
    }

    /* ================= CREATE ================= */

    public boolean registerUser(User user) {
        if (user == null) return false;

        if (user.getUsername() == null || user.getUsername().isEmpty())
            return false;

        if (user.getPassword() == null || user.getPassword().length() < 6)
            return false;

        if (user.getEmail() == null || !user.getEmail().contains("@"))
            return false;

        // hash password before saving
        user.setPassword(PasswordUtil.hashPassword(user.getPassword()));

        return userDAO.createUser(user);
    }

    /* ================= UPDATE ================= */

    public boolean updateUser(User user) {
        return userDAO.updateUser(user);
    }

    public boolean updatePassword(int userId, String newPassword) {
        if (newPassword == null || newPassword.length() < 6)
            return false;

        String hashed = PasswordUtil.hashPassword(newPassword);
        return userDAO.updatePassword(userId, hashed);
    }

    /* ================= DELETE ================= */

    public boolean deleteUser(int userId) {
        return userDAO.deleteUser(userId);
    }

    /* ================= STATS ================= */

    public int getTotalUserCount() {
        return userDAO.getTotalUserCount();
    }

    public int getUserCountByRole(String role) {
        return userDAO.getUserCountByRole(role);
    }
}
