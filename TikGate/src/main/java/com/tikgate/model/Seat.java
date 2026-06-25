package com.tikgate.model;

public class Seat {
    private int seatId;
    private String sectionName;
    private String rowNo;
    private String seatNumber;

    public Seat() {}

    public Seat(int seatId, String sectionName, String rowNo, String seatNumber) {
        this.seatId = seatId;
        this.sectionName = sectionName;
        this.rowNo = rowNo;
        this.seatNumber = seatNumber;
    }

    public int getSeatId() { return seatId; }
    public void setSeatId(int seatId) { this.seatId = seatId; }
    public String getSectionName() { return sectionName; }
    public void setSectionName(String sectionName) { this.sectionName = sectionName; }
    public String getRowNo() { return rowNo; }
    public void setRowNo(String rowNo) { this.rowNo = rowNo; }
    public String getSeatNumber() { return seatNumber; }
    public void setSeatNumber(String seatNumber) { this.seatNumber = seatNumber; }
}
