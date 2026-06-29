package com.tikgate.dao;

import com.tikgate.model.User;
import com.tikgate.util.DBConnection;
import com.tikgate.util.SecurityUtil;
import com.tikgate.util.ValidationUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {
    public User login(String username, String password) {
        String sql = "SELECT * FROM USERS WHERE USERNAME = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, ValidationUtil.clean(username));
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    String storedPassword = rs.getString("PASSWORD");
                    if (SecurityUtil.passwordMatches(password, storedPassword)) {
                        int userId = rs.getInt("USER_ID");
                        if (SecurityUtil.isLegacyPlainPassword(storedPassword)) {
                            updatePasswordHash(conn, userId, SecurityUtil.hashPassword(password));
                        }
                        return mapUser(rs);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean register(User user) {
        String sql = "INSERT INTO USERS (USER_ID, ROLE_ID, USERNAME, PASSWORD, FULL_NAME, EMAIL, PHONE) VALUES (USER_SEQ.NEXTVAL, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, user.getRoleId());
            pstmt.setString(2, ValidationUtil.clean(user.getUsername()));
            pstmt.setString(3, SecurityUtil.hashPassword(user.getPassword()));
            pstmt.setString(4, ValidationUtil.clean(user.getFullName()));
            pstmt.setString(5, ValidationUtil.clean(user.getEmail()).toLowerCase());
            pstmt.setString(6, ValidationUtil.clean(user.getPhone()));
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean usernameExists(String username) {
        return exists("SELECT COUNT(*) FROM USERS WHERE LOWER(USERNAME) = LOWER(?)", username);
    }

    public boolean emailExists(String email) {
        return exists("SELECT COUNT(*) FROM USERS WHERE LOWER(EMAIL) = LOWER(?)", email);
    }

    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM USERS";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                users.add(mapUser(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }

    public User getUserById(int userId) {
        String sql = "SELECT * FROM USERS WHERE USER_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private boolean exists(String sql, String value) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, ValidationUtil.clean(value));
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private void updatePasswordHash(Connection conn, int userId, String passwordHash) throws SQLException {
        String sql = "UPDATE USERS SET PASSWORD = ? WHERE USER_ID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, passwordHash);
            pstmt.setInt(2, userId);
            pstmt.executeUpdate();
        }
    }

    private User mapUser(ResultSet rs) throws SQLException {
        return new User(
            rs.getInt("USER_ID"),
            rs.getInt("ROLE_ID"),
            rs.getString("USERNAME"),
            rs.getString("PASSWORD"),
            rs.getString("FULL_NAME"),
            rs.getString("EMAIL"),
            rs.getString("PHONE")
        );
    }
}
