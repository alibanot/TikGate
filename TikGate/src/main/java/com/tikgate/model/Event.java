package com.tikgate.model;

import java.util.Date;

public class Event {
    private int eventId;
    private int tournamentId;
    private String eventName;
    private Date eventDate;
    private String startTime;
    private String endTime;
    private String description;
    private String status;

    // Constructors, Getters, and Setters
    public Event() {}

    public Event(int eventId, int tournamentId, String eventName, Date eventDate, String startTime, String endTime, String description, String status) {
        this.eventId = eventId;
        this.tournamentId = tournamentId;
        this.eventName = eventName;
        this.eventDate = eventDate;
        this.startTime = startTime;
        this.endTime = endTime;
        this.description = description;
        this.status = status;
    }

    public int getEventId() { return eventId; }
    public void setEventId(int eventId) { this.eventId = eventId; }
    public int getTournamentId() { return tournamentId; }
    public void setTournamentId(int tournamentId) { this.tournamentId = tournamentId; }
    public String getEventName() { return eventName; }
    public void setEventName(String eventName) { this.eventName = eventName; }
    public Date getEventDate() { return eventDate; }
    public void setEventDate(Date eventDate) { this.eventDate = eventDate; }
    public String getStartTime() { return startTime; }
    public void setStartTime(String startTime) { this.startTime = startTime; }
    public String getEndTime() { return endTime; }
    public void setEndTime(String endTime) { this.endTime = endTime; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
