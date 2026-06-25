package com.tikgate.model;

import java.util.Date;

public class Booking {
    private int bookingId;
    private int userId;
    private int eventId;
    private Date bookingDate;
    private double totalAmount;
    private String status;

    public Booking() {}

    public Booking(int bookingId, int userId, int eventId, Date bookingDate, double totalAmount, String status) {
        this.bookingId = bookingId;
        this.userId = userId;
        this.eventId = eventId;
        this.bookingDate = bookingDate;
        this.totalAmount = totalAmount;
        this.status = status;
    }

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public int getEventId() { return eventId; }
    public void setEventId(int eventId) { this.eventId = eventId; }
    public Date getBookingDate() { return bookingDate; }
    public void setBookingDate(Date bookingDate) { this.bookingDate = bookingDate; }
    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
