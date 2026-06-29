package com.tikgate.dao;

import com.tikgate.model.Tournament;
import com.tikgate.util.DBConnection;
import com.tikgate.util.ValidationUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TournamentDAO {
    public List<Tournament> getAllTournaments() {
        List<Tournament> tournaments = new ArrayList<>();
        String sql = "SELECT * FROM TOURNAMENT";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                int categoryId = rs.getInt("CATEGORY_ID");
                if (rs.wasNull()) categoryId = 0;
                tournaments.add(new Tournament(
                    rs.getInt("TOURNAMENT_ID"),
                    rs.getString("TOURNAMENT_NAME"),
                    rs.getString("DESCRIPTION"),
                    categoryId
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tournaments;
    }

    public List<Tournament> getTournamentsByCategory(int categoryId) {
        List<Tournament> tournaments = new ArrayList<>();
        String sql = "SELECT * FROM TOURNAMENT WHERE CATEGORY_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, categoryId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    int categoryIdResult = rs.getInt("CATEGORY_ID");
                    if (rs.wasNull()) categoryIdResult = 0;
                    tournaments.add(new Tournament(
                        rs.getInt("TOURNAMENT_ID"),
                        rs.getString("TOURNAMENT_NAME"),
                        rs.getString("DESCRIPTION"),
                        categoryIdResult
                    ));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tournaments;
    }

    public boolean addTournament(Tournament t) {
        String sql = "INSERT INTO TOURNAMENT (TOURNAMENT_ID, TOURNAMENT_NAME, DESCRIPTION, CATEGORY_ID) VALUES (TOURNAMENT_SEQ.NEXTVAL, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, ValidationUtil.clean(t.getTournamentName()));
            pstmt.setString(2, ValidationUtil.clean(t.getDescription()));
            pstmt.setInt(3, t.getCategoryId());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean tournamentExists(int tournamentId) {
        String sql = "SELECT COUNT(*) FROM TOURNAMENT WHERE TOURNAMENT_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, tournamentId);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean tournamentNameExists(int categoryId, String name) {
        String sql = "SELECT COUNT(*) FROM TOURNAMENT WHERE CATEGORY_ID = ? AND LOWER(TOURNAMENT_NAME) = LOWER(?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, categoryId);
            pstmt.setString(2, ValidationUtil.clean(name));
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
