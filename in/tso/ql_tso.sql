-- =====================================================
-- STORED PROCEDURES CHO BH_IN_GCN_TSO
-- =====================================================

-- 1. Procedure SELECT/SEARCH data
CREATE OR REPLACE PROCEDURE PBH_IN_TSO_SELECT (
    p_search_nv     IN VARCHAR2 DEFAULT NULL,
    p_search_ma     IN VARCHAR2 DEFAULT NULL,
    p_cursor        OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_cursor FOR
        SELECT NV, TEN, DUONG_DAN, HAM, MA, KYSO, PBH 
        FROM BH_IN_GCN_TSO
        WHERE 1=1
          AND (p_search_nv IS NULL OR UPPER(NV) LIKE '%' || UPPER(p_search_nv) || '%')
          AND (p_search_ma IS NULL OR UPPER(MA) LIKE '%' || UPPER(p_search_ma) || '%')
        ORDER BY MA;
END;
/

-- 2. Procedure INSERT data
CREATE OR REPLACE PROCEDURE PBH_IN_TSO_INSERT (
    p_nv            IN VARCHAR2,
    p_ten           IN VARCHAR2,
    p_duong_dan     IN VARCHAR2,
    p_ham           IN VARCHAR2,
    p_ma            IN VARCHAR2,
    p_kyso          IN VARCHAR2,
    p_pbh           IN VARCHAR2,
    p_result        OUT NUMBER,
    p_message       OUT VARCHAR2
)
AS
BEGIN
    INSERT INTO BH_IN_GCN_TSO (NV, TEN, DUONG_DAN, HAM, MA, KYSO, PBH)
    VALUES (p_nv, p_ten, p_duong_dan, p_ham, p_ma, p_kyso, p_pbh);
    
    p_result := 1;
    p_message := 'Add success!';
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        p_result := 0;
        p_message := 'Code exists!';
        ROLLBACK;
    WHEN OTHERS THEN
        p_result := 0;
        p_message := 'Error: ' || SQLERRM;
        ROLLBACK;
END;
/

-- 3. Procedure UPDATE data
CREATE OR REPLACE PROCEDURE PBH_IN_TSO_UPDATE (
    p_nv            IN VARCHAR2,
    p_ten           IN VARCHAR2,
    p_duong_dan     IN VARCHAR2,
    p_ham           IN VARCHAR2,
    p_ma            IN VARCHAR2,
    p_kyso          IN VARCHAR2,
    p_pbh           IN VARCHAR2,
    p_result        OUT NUMBER,
    p_message       OUT VARCHAR2
)
AS
    v_count NUMBER;
BEGIN
    UPDATE BH_IN_GCN_TSO
    SET NV = p_nv,
        TEN = p_ten,
        DUONG_DAN = p_duong_dan,
        HAM = p_ham,
        KYSO = p_kyso,
        PBH = p_pbh
    WHERE MA = p_ma;
    
    v_count := SQL%ROWCOUNT;
    
    IF v_count > 0 THEN
        p_result := 1;
        p_message := 'Update success!';
        COMMIT;
    ELSE
        p_result := 0;
        p_message := 'No data found with MA: ' || p_ma;
        ROLLBACK;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        p_result := 0;
        p_message := 'Error: ' || SQLERRM;
        ROLLBACK;
END;
/

-- 4. Procedure DELETE data
CREATE OR REPLACE PROCEDURE PBH_IN_TSO_DELETE (
    p_ma            IN VARCHAR2,
    p_result        OUT NUMBER,
    p_message       OUT VARCHAR2
)
AS
    v_count NUMBER;
BEGIN
    DELETE FROM BH_IN_GCN_TSO WHERE MA = p_ma;
    
    v_count := SQL%ROWCOUNT;
    
    IF v_count > 0 THEN
        p_result := 1;
        p_message := 'Delete success!';
        COMMIT;
    ELSE
        p_result := 0;
        p_message := 'No data found with MA: ' || p_ma;
        ROLLBACK;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        p_result := 0;
        p_message := 'Error: ' || SQLERRM;
        ROLLBACK;
END;
/

-- 5. Procedure GET BY MA (for Edit)
CREATE OR REPLACE PROCEDURE PBH_IN_TSO_GET_BY_MA (
    p_ma            IN VARCHAR2,
    p_cursor        OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_cursor FOR
        SELECT NV, TEN, DUONG_DAN, HAM, MA, KYSO, PBH 
        FROM BH_IN_GCN_TSO
        WHERE MA = p_ma;
END;
/