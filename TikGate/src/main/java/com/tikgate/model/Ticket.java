package com.tikgate.model;

import java.util.Date;

public class Ticket {
    private int ticketId;
    private int bookingItemId;
    private String qrCode;
    private String pdfFile;
    private Date generatedDate;
    private String status;

    public Ticket() {}
    public Ticket(int ticketId, int bookingItemId, String qrCode, String pdfFile, Date generatedDate, String status) {
        this.ticketId = ticketId;
        this.bookingItemId = bookingItemId;
        this.qrCode = qrCode;
        this.pdfFile = pdfFile;
        this.generatedDate = generatedDate;
        this.status = status;
    }

    public int getTicketId() { return ticketId; }
    public void setTicketId(int ticketId) { this.ticketId = ticketId; }
    public int getBookingItemId() { return bookingItemId; }
    public void setBookingItemId(int bookingItemId) { this.bookingItemId = bookingItemId; }
    public String getQrCode() { return qrCode; }
    public void setQrCode(String qrCode) { this.qrCode = qrCode; }
    public String getPdfFile() { return pdfFile; }
    public void setPdfFile(String pdfFile) { this.pdfFile = pdfFile; }
    public Date getGeneratedDate() { return generatedDate; }
    public void setGeneratedDate(Date generatedDate) { this.generatedDate = generatedDate; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
