package com.tikgate.model;

public class Tournament {
    private int tournamentId;
    private String tournamentName;
    private String description;
    private int categoryId;

    public Tournament() {}
    public Tournament(int tournamentId, String tournamentName, String description) {
        this.tournamentId = tournamentId;
        this.tournamentName = tournamentName;
        this.description = description;
    }

    public Tournament(int tournamentId, String tournamentName, String description, int categoryId) {
        this.tournamentId = tournamentId;
        this.tournamentName = tournamentName;
        this.description = description;
        this.categoryId = categoryId;
    }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public int getTournamentId() { return tournamentId; }
    public void setTournamentId(int tournamentId) { this.tournamentId = tournamentId; }
    public String getTournamentName() { return tournamentName; }
    public void setTournamentName(String tournamentName) { this.tournamentName = tournamentName; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}
