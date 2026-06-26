SET SERVEROUTPUT ON

DECLARE
    v_count NUMBER;
BEGIN
    FOR section_row IN (
        SELECT 'North' AS section_name, 'A' AS row_no FROM dual UNION ALL
        SELECT 'North', 'B' FROM dual UNION ALL
        SELECT 'North', 'C' FROM dual UNION ALL
        SELECT 'South', 'A' FROM dual UNION ALL
        SELECT 'South', 'B' FROM dual UNION ALL
        SELECT 'South', 'C' FROM dual
    ) LOOP
        FOR seat_no IN 1..10 LOOP
            SELECT COUNT(*)
            INTO v_count
            FROM SEAT
            WHERE SECTION_NAME = section_row.section_name
              AND ROW_NO = section_row.row_no
              AND SEAT_NUMBER = TO_CHAR(seat_no);

            IF v_count = 0 THEN
                INSERT INTO SEAT (SEAT_ID, SECTION_NAME, ROW_NO, SEAT_NUMBER)
                VALUES (SEAT_SEQ.NEXTVAL, section_row.section_name, section_row.row_no, TO_CHAR(seat_no));
            END IF;
        END LOOP;
    END LOOP;

    COMMIT;
END;
/

EXIT;
