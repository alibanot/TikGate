package com.tikgate.dao;

import com.tikgate.model.Event;
import com.tikgate.util.DBConnection;
import com.tikgate.util.ValidationUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EventDAO {
    public List<Event> getAllEvents() {
        List<Event> events = new ArrayList<>();
        String sql = "SELECT * FROM EVENT ORDER BY EVENT_DATE DESC, START_TIME";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Event e = new Event();
                e.setEventId(rs.getInt("EVENT_ID"));
                e.setTournamentId(rs.getInt("TOURNAMENT_ID"));
                e.setEventName(rs.getString("EVENT_NAME"));
                e.setEventDate(rs.getDate("EVENT_DATE"));
                e.setStartTime(rs.getString("START_TIME"));
                e.setEndTime(rs.getString("END_TIME"));
                e.setDescription(rs.getString("DESCRIPTION"));
                e.setStatus(rs.getString("STATUS"));
                events.add(e);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return events;
    }

    public List<Event> getActiveEvents() {
        List<Event> events = new ArrayList<>();
        String sql = "SELECT * FROM EVENT WHERE STATUS = 'ACTIVE' ORDER BY EVENT_DATE, START_TIME";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Event e = new Event();
                e.setEventId(rs.getInt("EVENT_ID"));
                e.setTournamentId(rs.getInt("TOURNAMENT_ID"));
                e.setEventName(rs.getString("EVENT_NAME"));
                e.setEventDate(rs.getDate("EVENT_DATE"));
                e.setStartTime(rs.getString("START_TIME"));
                e.setEndTime(rs.getString("END_TIME"));
                e.setDescription(rs.getString("DESCRIPTION"));
                e.setStatus(rs.getString("STATUS"));
                events.add(e);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return events;
    }

    public boolean addEvent(Event event) {
        String sql = "INSERT INTO EVENT (EVENT_ID, TOURNAMENT_ID, EVENT_NAME, EVENT_DATE, START_TIME, END_TIME, DESCRIPTION, STATUS) " +
                     "VALUES (EVENT_SEQ.NEXTVAL, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, event.getTournamentId());
            pstmt.setString(2, ValidationUtil.clean(event.getEventName()));
            pstmt.setDate(3, new java.sql.Date(event.getEventDate().getTime()));
            pstmt.setString(4, ValidationUtil.clean(event.getStartTime()));
            pstmt.setString(5, ValidationUtil.clean(event.getEndTime()));
            pstmt.setString(6, ValidationUtil.clean(event.getDescription()));
            pstmt.setString(7, ValidationUtil.clean(event.getStatus()));
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public Event getEventById(int id) {
        String sql = "SELECT * FROM EVENT WHERE EVENT_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Event e = new Event();
                    e.setEventId(rs.getInt("EVENT_ID"));
                    e.setTournamentId(rs.getInt("TOURNAMENT_ID"));
                    e.setEventName(rs.getString("EVENT_NAME"));
                    e.setEventDate(rs.getDate("EVENT_DATE"));
                    e.setStartTime(rs.getString("START_TIME"));
                    e.setEndTime(rs.getString("END_TIME"));
                    e.setDescription(rs.getString("DESCRIPTION"));
                    e.setStatus(rs.getString("STATUS"));
                    return e;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean isActiveEvent(int eventId) {
        String sql = "SELECT COUNT(*) FROM EVENT WHERE EVENT_ID = ? AND STATUS = 'ACTIVE'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, eventId);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean eventNameExists(int tournamentId, String eventName, java.util.Date eventDate) {
        String sql = "SELECT COUNT(*) FROM EVENT WHERE TOURNAMENT_ID = ? AND LOWER(EVENT_NAME) = LOWER(?) AND EVENT_DATE = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, tournamentId);
            pstmt.setString(2, ValidationUtil.clean(eventName));
            pstmt.setDate(3, new java.sql.Date(eventDate.getTime()));
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
