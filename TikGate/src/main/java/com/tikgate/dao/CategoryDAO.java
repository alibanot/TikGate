package com.tikgate.dao;

import com.tikgate.model.Category;
import com.tikgate.util.DBConnection;
import com.tikgate.util.ValidationUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO {
    public List<Category> getAllCategories() {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT * FROM CATEGORY";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                categories.add(new Category(
                    rs.getInt("CATEGORY_ID"),
                    rs.getString("CATEGORY_NAME"),
                    rs.getString("DESCRIPTION")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return categories;
    }

    public boolean addCategory(Category c) {
        String sql = "INSERT INTO CATEGORY (CATEGORY_ID, CATEGORY_NAME, DESCRIPTION) VALUES (CATEGORY_SEQ.NEXTVAL, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, ValidationUtil.clean(c.getCategoryName()));
            pstmt.setString(2, ValidationUtil.clean(c.getDescription()));
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean categoryExists(int categoryId) {
        String sql = "SELECT COUNT(*) FROM CATEGORY WHERE CATEGORY_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, categoryId);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean categoryNameExists(String name) {
        String sql = "SELECT COUNT(*) FROM CATEGORY WHERE LOWER(CATEGORY_NAME) = LOWER(?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, ValidationUtil.clean(name));
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
