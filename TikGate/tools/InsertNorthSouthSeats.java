import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class InsertNorthSouthSeats {
    public static void main(String[] args) throws Exception {
        Class.forName("oracle.jdbc.OracleDriver");
        try (Connection conn = DriverManager.getConnection(
                "jdbc:oracle:thin:@localhost:1521/FREEPDB1",
                "group4",
                "abc123")) {
            conn.setAutoCommit(false);

            String[] sections = {"North", "South"};
            String[] rows = {"A", "B", "C"};
            int inserted = 0;

            try (PreparedStatement exists = conn.prepareStatement(
                    "SELECT COUNT(*) FROM SEAT WHERE SECTION_NAME = ? AND ROW_NO = ? AND SEAT_NUMBER = ?");
                 PreparedStatement insert = conn.prepareStatement(
                    "INSERT INTO SEAT (SEAT_ID, SECTION_NAME, ROW_NO, SEAT_NUMBER) VALUES (SEAT_SEQ.NEXTVAL, ?, ?, ?)")) {
                for (String section : sections) {
                    for (String row : rows) {
                        for (int seatNo = 1; seatNo <= 10; seatNo++) {
                            String seat = String.valueOf(seatNo);
                            exists.setString(1, section);
                            exists.setString(2, row);
                            exists.setString(3, seat);
                            try (ResultSet rs = exists.executeQuery()) {
                                rs.next();
                                if (rs.getInt(1) == 0) {
                                    insert.setString(1, section);
                                    insert.setString(2, row);
                                    insert.setString(3, seat);
                                    insert.executeUpdate();
                                    inserted++;
                                }
                            }
                        }
                    }
                }
            }

            conn.commit();
            System.out.println("Inserted missing North/South seats: " + inserted);
        }
    }
}
