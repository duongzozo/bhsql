DROP PROCEDURE PBH_PKT_HD_XDLD;
/

CREATE OR REPLACE PROCEDURE PBH_PKT_HD_XDLD(
    b_ma_dviN varchar2, b_nsd varchar2, b_pas varchar2, b_oraIn clob, b_oraOut OUT clob)
AS
    -- ===== VARIABLES =====
    b_loi varchar2(100);
    b_i1 number;
    b_ma_dt varchar2(500);
    b_nd_dkhoan nvarchar2(1000);
    b_nd_qtac nvarchar2(500);
    b_ma_qtac varchar2(10);
    b_lenh varchar2(1000);
    
    -- Input parameters
    b_ma_dvi varchar2(10) := FKH_JS_GTRIs(b_oraIn, 'ma_dvi');
    b_so_id number := FKH_JS_GTRIs(b_oraIn, 'so_id');
    
    -- Array types
    a_pvbh_ma pht_type.a_var;
    a_pvbh_ten pht_type.a_nvar;
    a_pvbh_tc pht_type.a_var;
    a_pvbh_pttsb pht_type.a_var;
    a_pvbh_ptts pht_type.a_var;
    a_pvbh_ptkhb pht_type.a_var;
    a_pvbh_ptkh pht_type.a_var;
    a_pvbh_ktru pht_type.a_var;
    
    -- Output CLOBs
    dt_ct clob;
    dt_dk clob;
    dt_lt clob;
    dt_kbt clob;
    dt_kytt clob;
    dt_pvi clob;
    dt_dkbs clob;
    dt_pvi_nd clob;
    dt_phi clob;
    dt_lbh clob;
    dt_ttt clob;
    ds_ct clob;
    dt_lt_nd clob;
    dt_bs_nd clob;
    
    -- PVI & QTAC
    pvi_ts clob;
    pvi_gdkd clob;
    b_dvi clob;
    qt_ts clob;
    qt_gdkd clob;
    c_quy_tac clob;
    
    -- Thue & Phi
    thue_ts number := 0;
    thue_ts_rr number := 0;
    thue_kh number := 0;
    phi_ts number := 0;
    phi_ts_rr number := 0;
    phi_kh number := 0;
    
    -- Other variables
    b_ma_sp varchar2(20);
    b_ten_sp nvarchar2(500) := ' ';
    b_bhanh number := 0;
    b_kh_ttt clob;
    b_ktru varchar2(100) := ' ';
    mkt_tt clob;
    mkt_rr clob;
    mkt_tntb clob;
    mkt_xdbb clob;
    a_kbt_ma pht_type.a_var;
    a_kbt pht_type.a_clob;
    kbt_ma pht_type.a_var;
    kbt_nd pht_type.a_var;
    b_ten_lbh nvarchar2(500) := ' ';
    a_dk_ma pht_type.a_var;
    a_dkbs_ten pht_type.a_nvar;
    b_mkt_bs nvarchar2(200) := ' ';
    b_nd clob;
    b_pt_ts number := 0;
    b_pt_kh number := 0;
    b_pt_rr number := 0;
    b_tien_ts number := 0;
    b_tien_kh number := 0;
    b_tsuat_ts number := 0;
    b_tsuat_kh number := 0;
    b_ptp number := 0;
    b_nt_tien varchar2(10) := ' ';
    b_temp nvarchar2(1000) := ' ';
    
BEGIN
    b_ma_dvi := NVL(TRIM(b_ma_dvi), b_ma_dviN);
    
    -- ===== LOAD dt_ct & dvi info =====
    BEGIN
        SELECT FKH_JS_BONH(t.txt), 
               FKH_JS_GTRIs(FKH_JS_BONH(t.txt), 'ma_dt'),
               FKH_JS_GTRIs(FKH_JS_BONH(t.txt), 'ma_sp')
        INTO dt_ct, b_ma_dt, b_ma_sp
        FROM bh_pkt_txt t
        WHERE t.so_id = b_so_id AND t.loai = 'dt_ct'
        AND ROWNUM = 1;
        
        -- Get product name
        IF TRIM(b_ma_sp) IS NOT NULL THEN
            BEGIN
                SELECT UPPER(ten) INTO b_ten_sp FROM bh_pkt_sp WHERE ma = b_ma_sp;
            EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
            END;
        END IF;
        
        -- Get DVI info & merge
        SELECT json_object(
            'ten_dvi' VALUE NVL(ten, ' '),
            'dchi_dvi' VALUE NVL(dchi, ' '),
            'ma_tk_dvi' VALUE NVL(ma_tk, ' '),
            'nhang_dvi' VALUE NVL(nhang, ' '),
            'gdoc_dvi' VALUE NVL(g_doc, ' '),
            'ma_thue_dvi' VALUE NVL(ma_thue, ' ') RETURNING CLOB)
        INTO b_dvi
        FROM ht_ma_dvi
        WHERE ma = b_ma_dvi;
        
        dt_ct := FKH_JS_BONH(dt_ct);
        b_dvi := FKH_JS_BONH(b_dvi);
        SELECT json_mergepatch(dt_ct, b_dvi) INTO dt_ct FROM DUAL;
        
        PKH_JS_THAYa(dt_ct, 'ten_sp', b_ten_sp);
        
        -- Get & set bhanh
        SELECT MIN(bhanh) INTO b_bhanh FROM bh_pkt_dvi WHERE so_id = b_so_id;
        PKH_JS_THAYa(dt_ct, 'bhanh', b_bhanh);
        
        -- Get KH_TTT template
        SELECT '{' || LISTAGG('"' || ma || '": ""', ',') WITHIN GROUP (ORDER BY ma) || '}'
        INTO b_kh_ttt
        FROM bh_kh_ttt
        WHERE nv = 'PKT' AND ps = 'HD';
        
        dt_ct := FKH_JS_BONH(dt_ct);
        b_kh_ttt := FKH_JS_BONH(b_kh_ttt);
        SELECT json_mergepatch(dt_ct, b_kh_ttt) INTO dt_ct FROM DUAL;
        
        b_nt_tien := FKH_JS_GTRIs(dt_ct, 'nt_tien');
        b_temp := FKH_JS_GTRIs(dt_ct, 'lvuc');
        b_temp := FBH_IN_SUBSTR(b_temp, '|', 'T');
        PKH_JS_THAY(dt_ct, 'lvuc', b_temp);
        
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;
    
    -- ===== LOAD tong tien (consolidated query) =====
    SELECT SUM(CASE WHEN t2.loai = 'TS' THEN t1.tien ELSE 0 END),
           SUM(CASE WHEN t2.loai = 'TS' THEN t1.t_suat ELSE 0 END),
           SUM(CASE WHEN t2.loai = 'KH' THEN t1.tien ELSE 0 END),
           SUM(CASE WHEN t2.loai = 'KH' THEN t1.t_suat ELSE 0 END)
    INTO b_tien_ts, b_tsuat_ts, b_tien_kh, b_tsuat_kh
    FROM bh_pkt_dk t1
    LEFT JOIN bh_pkt_lbh t2 ON t2.ma = t1.ma
    WHERE t1.so_id = b_so_id AND t1.cap = 1;
    
    -- ===== LOAD ALL TEXT DATA (consolidated - 1 query instead of 6) =====
    FOR r_txt IN (
        SELECT loai, FKH_JS_BONH(txt) AS txt_content
        FROM bh_pkt_txt
        WHERE so_id = b_so_id AND loai IN ('ds_dk', 'ds_pvi', 'ds_lt', 'ds_dkbs', 'ds_ttt', 'ds_ct')
    ) LOOP
        CASE r_txt.loai
            WHEN 'ds_dk' THEN dt_dk := r_txt.txt_content;
            WHEN 'ds_pvi' THEN dt_pvi := r_txt.txt_content;
            WHEN 'ds_lt' THEN dt_lt := r_txt.txt_content;
            WHEN 'ds_dkbs' THEN dt_dkbs := r_txt.txt_content;
            WHEN 'ds_ttt' THEN dt_ttt := r_txt.txt_content;
            WHEN 'ds_ct' THEN ds_ct := r_txt.txt_content;
        END CASE;
    END LOOP;
    
    -- ===== PROCESS dt_lt =====
    IF dt_lt IS NOT NULL AND dt_lt <> '""' THEN
        dt_lt := REPLACE(SUBSTR(dt_lt, 3, LENGTH(dt_lt) - 4), '\', '');
        b_lenh := FKH_JS_LENH('ma_lt,ten');
        EXECUTE IMMEDIATE b_lenh BULK COLLECT INTO a_dk_ma, a_dkbs_ten USING dt_lt;
        
        -- Load all dklt data at once
        FOR i IN 1..a_dk_ma.COUNT LOOP
            BEGIN
                SELECT FKH_JS_GTRIc(FKH_JS_BONH(t.txt), 'nd')
                INTO b_nd
                FROM bh_ma_dklt t
                WHERE t.ma = a_dk_ma(i) AND ROWNUM = 1;
                
                INSERT INTO temp_7(CL1, C1) VALUES(a_dkbs_ten(i) || ': ' || b_nd, a_dk_ma(i));
            EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
            END;
        END LOOP;
    ELSE
        dt_lt := '';
    END IF;
    
    SELECT JSON_ARRAYAGG(json_object('TEN' VALUE cl1, 'MA' VALUE c1 RETURNING CLOB) RETURNING CLOB)
    INTO dt_lt_nd FROM temp_7;
    DELETE temp_7;
    
    -- ===== PROCESS dt_kbt =====
    BEGIN
        SELECT FKH_JS_BONH(kbt) INTO dt_kbt FROM bh_pkt_kbt WHERE so_id = b_so_id;
        
        b_lenh := FKH_JS_LENH('ma,kbt');
        EXECUTE IMMEDIATE b_lenh BULK COLLECT INTO a_kbt_ma, a_kbt USING dt_kbt;
        
        FOR b_lp IN 1..a_kbt_ma.COUNT LOOP
            IF a_kbt(b_lp) IS NOT NULL THEN
                b_lenh := FKH_JS_LENH('ma,nd');
                EXECUTE IMMEDIATE b_lenh BULK COLLECT INTO kbt_ma, kbt_nd USING a_kbt(b_lp);
                
                FOR b_lp1 IN 1..kbt_ma.COUNT LOOP
                    IF kbt_ma(b_lp1) = 'KVU' THEN
                        BEGIN
                            SELECT ten INTO b_ten_lbh FROM bh_pkt_lbh 
                            WHERE ma = a_kbt_ma(b_lp) AND loai = 'KH';
                            INSERT INTO temp_1(C1) VALUES(FBH_MKT(kbt_nd(b_lp1), b_nt_tien));
                        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
                        END;
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
        
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;
    
    SELECT JSON_ARRAYAGG(json_object('TEN' VALUE c1) RETURNING CLOB)
    INTO mkt_tntb FROM TEMP_1;
    DELETE temp_1;
    
    -- ===== PROCESS dt_dkbs =====
    IF dt_dkbs IS NOT NULL AND dt_dkbs <> '""' THEN
        dt_dkbs := REPLACE(SUBSTR(dt_dkbs, 3, LENGTH(dt_dkbs) - 4), '\', '');
        b_lenh := FKH_JS_LENH('ma,ten');
        EXECUTE IMMEDIATE b_lenh BULK COLLECT INTO a_dk_ma, a_dkbs_ten USING dt_dkbs;
        
        -- Pre-load all KBT data for all DKBS
        FOR b_lp IN 1..a_dk_ma.COUNT LOOP
            b_mkt_bs := ' ';
            
            FOR kbt_lp IN 1..a_kbt_ma.COUNT LOOP
                IF a_dk_ma(b_lp) = a_kbt_ma(kbt_lp) AND a_kbt(kbt_lp) IS NOT NULL THEN
                    b_lenh := FKH_JS_LENH('ma,nd');
                    EXECUTE IMMEDIATE b_lenh BULK COLLECT INTO kbt_ma, kbt_nd USING a_kbt(kbt_lp);
                    
                    FOR b_lp1 IN 1..kbt_ma.COUNT LOOP
                        b_mkt_bs := (CASE WHEN TRIM(b_mkt_bs) IS NOT NULL THEN b_mkt_bs || ', ' ELSE '' END) || 
                                   FBH_IN_GBT(kbt_nd(b_lp1), kbt_ma(b_lp1));
                    END LOOP;
                END IF;
            END LOOP;
            
            b_temp := (CASE WHEN TRIM(b_mkt_bs) IS NOT NULL THEN '(' || b_mkt_bs || ')' ELSE ' ' END);
            INSERT INTO TEMP_1(C1) VALUES(a_dkbs_ten(b_lp) || b_temp);
            
            -- Load DKBS details
            BEGIN
                SELECT FKH_JS_GTRIc(FKH_JS_BONH(t.txt), 'nd')
                INTO b_nd
                FROM bh_ma_dkbs t
                WHERE t.ma = a_dk_ma(b_lp) AND ROWNUM = 1;
                INSERT INTO temp_6(CL1, C1) VALUES(a_dkbs_ten(b_lp) || ': ' || b_nd, a_dk_ma(b_lp));
            EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
            END;
        END LOOP;
    ELSE
        dt_dkbs := '';
    END IF;
    
    SELECT JSON_ARRAYAGG(json_object('TEN' VALUE cl1, 'MA' VALUE c1 RETURNING CLOB) RETURNING CLOB)
    INTO dt_bs_nd FROM temp_6;
    SELECT JSON_ARRAYAGG(json_object('TEN' VALUE C1 RETURNING CLOB) RETURNING CLOB)
    INTO dt_dkbs FROM TEMP_1;
    DELETE temp_1;
    DELETE temp_6;
    
    -- ===== LOAD dt_kytt =====
    SELECT JSON_ARRAYAGG(json_object(ngay, tien) ORDER BY ngay)
    INTO dt_kytt FROM bh_pkt_tt WHERE so_id = b_so_id;
    
    -- ===== PROCESS dt_pvi (PVI with consolidated queries) =====
    IF dt_pvi IS NOT NULL AND dt_pvi <> '""' THEN
        dt_pvi := REPLACE(SUBSTR(dt_pvi, 3, LENGTH(dt_pvi) - 4), '\', '');
        b_lenh := FKH_JS_LENH('ten,ma,pttsb,ptts,ptkhb,ptkh,tc,ktru');
        EXECUTE IMMEDIATE b_lenh BULK COLLECT INTO a_pvbh_ten, a_pvbh_ma, a_pvbh_pttsb, a_pvbh_ptts, 
                          a_pvbh_ptkhb, a_pvbh_ptkh, a_pvbh_tc, a_pvbh_ktru USING dt_pvi;
        
        FOR b_lp IN 1..a_pvbh_ma.COUNT LOOP
            BEGIN
                SELECT FKH_JS_GTRIs(FKH_JS_BONH(t.txt), 'ma_dk'),
                       FKH_JS_GTRIs(FKH_JS_BONH(t.txt), 'ma_qtac')
                INTO b_nd_dkhoan, b_nd_qtac
                FROM bh_pkt_pvi t
                WHERE t.ma = a_pvbh_ma(b_lp);
                
                b_nd_dkhoan := SUBSTR(b_nd_dkhoan, 1, INSTR(b_nd_dkhoan, '|') - 1);
                b_ma_qtac := SUBSTR(b_nd_qtac, 1, INSTR(b_nd_qtac, '|') - 1);
                b_nd_qtac := SUBSTR(b_nd_qtac, INSTR(b_nd_qtac, '|') + 1);
                
                -- Get DK details if exists
                BEGIN
                    SELECT NVL(FKH_JS_GTRIc(FKH_JS_BONH(t.txt), 'nd'), '')
                    INTO b_nd_dkhoan
                    FROM BH_MA_DK t
                    WHERE ma = b_nd_dkhoan;
                EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
                END;
                
                -- Insert QTAC if not exists
                INSERT INTO TEMP_4(c1, cl1)
                SELECT b_ma_qtac, b_nd_qtac FROM DUAL
                WHERE NOT EXISTS (SELECT 1 FROM TEMP_4 WHERE c1 = b_ma_qtac);
                
                -- Process based on TC type
                IF a_pvbh_tc(b_lp) <> 'M' THEN
                    INSERT INTO temp_7(cl1, cl2, c3, n1) VALUES(b_nd_dkhoan, b_nd_qtac, a_pvbh_tc(b_lp), 1);
                    
                    -- Process ktru by type
                    IF a_pvbh_tc(b_lp) = 'C' AND TRIM(a_pvbh_ktru(b_lp)) IS NOT NULL THEN
                        INSERT INTO temp_3(c1, c2) VALUES(a_pvbh_ten(b_lp), '- ' || a_pvbh_ten(b_lp) || ': ' || 
                                                         FBH_MKT(a_pvbh_ktru(b_lp), b_nt_tien));
                    ELSIF a_pvbh_tc(b_lp) = 'B' THEN
                        b_temp := NVL(FBH_MKT(a_pvbh_ktru(b_lp), b_nt_tien), N'Không áp dụng mức khấu trừ');
                        INSERT INTO temp_5(c1, c2) VALUES('+ ' || a_pvbh_ten(b_lp), b_temp);
                    ELSIF TRIM(a_pvbh_ktru(b_lp)) IS NOT NULL THEN
                        INSERT INTO temp_2(c1, c2) VALUES('+ ' || a_pvbh_ten(b_lp), FBH_MKT(a_pvbh_ktru(b_lp), b_nt_tien));
                    END IF;
                ELSE
                    INSERT INTO temp_6(cl1, cl2, n1) VALUES(b_nd_dkhoan, b_nd_qtac, 0);
                END IF;
                
                -- Calculate PT (consolidated logic)
                IF a_pvbh_tc(b_lp) = 'B' THEN
                    b_ptp := CASE WHEN ABS(FBH_TONUM(a_pvbh_ptts(b_lp))) < 100 
                                 THEN FBH_TONUM(a_pvbh_ptts(b_lp))
                                 ELSE FBH_TONUM(a_pvbh_ptts(b_lp)) / b_tien_ts
                             END;
                    b_pt_ts := b_pt_ts + FBH_TONUM(a_pvbh_pttsb(b_lp)) - b_ptp;
                    
                ELSIF a_pvbh_tc(b_lp) IN ('C', 'D') THEN
                    b_ptp := CASE WHEN ABS(FBH_TONUM(a_pvbh_ptts(b_lp))) < 100
                                 THEN FBH_TONUM(a_pvbh_ptts(b_lp))
                                 ELSE FBH_TONUM(a_pvbh_ptts(b_lp)) / b_tien_ts
                             END;
                    b_pt_rr := b_pt_rr + FBH_TONUM(a_pvbh_pttsb(b_lp)) - b_ptp;
                    
                ELSIF a_pvbh_tc(b_lp) = 'M' THEN
                    b_ptp := CASE WHEN ABS(FBH_TONUM(a_pvbh_ptkh(b_lp))) < 100
                                 THEN FBH_TONUM(a_pvbh_ptkh(b_lp))
                                 ELSE FBH_TONUM(a_pvbh_ptkh(b_lp)) / b_tien_ts
                             END;
                    b_pt_kh := b_pt_kh + FBH_TONUM(a_pvbh_ptkhb(b_lp)) - b_ptp;
                END IF;
                
            EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
            END;
        END LOOP;
    ELSE
        dt_pvi := '';
    END IF;
    
    -- ===== BUILD JSON AGGREGATES =====
    SELECT JSON_ARRAYAGG(json_object('TEN' VALUE cl1) RETURNING CLOB) INTO c_quy_tac FROM TEMP_4;
    SELECT JSON_ARRAYAGG(json_object('ND_DK' VALUE cl1, 'TC' VALUE c3, 'STT' VALUE N1) 
                        ORDER BY n1 RETURNING CLOB) INTO pvi_ts FROM temp_7 WHERE cl1 IS NOT NULL;
    SELECT JSON_ARRAYAGG(json_object('ND_DK' VALUE cl1, 'STT' VALUE N1) 
                        ORDER BY n1 RETURNING CLOB) INTO pvi_gdkd FROM temp_6 WHERE cl1 IS NOT NULL;
    SELECT JSON_ARRAYAGG(json_object('ND_QTAC' VALUE cl2, 'TC' VALUE c3, 'STT' VALUE N1) 
                        ORDER BY n1 RETURNING CLOB) INTO qt_ts FROM temp_7 WHERE cl2 IS NOT NULL;
    SELECT JSON_ARRAYAGG(json_object('ND_QTAC' VALUE cl2, 'STT' VALUE N1) 
                        ORDER BY n1 RETURNING CLOB) INTO qt_gdkd FROM temp_6 WHERE cl2 IS NOT NULL;
    SELECT JSON_ARRAYAGG(json_object('TEN' VALUE c1, 'ND' VALUE c2) RETURNING CLOB) INTO mkt_tt FROM temp_3;
    SELECT JSON_ARRAYAGG(json_object('TEN' VALUE c1, 'ND' VALUE c2) RETURNING CLOB) INTO mkt_rr FROM temp_2;
    SELECT JSON_ARRAYAGG(json_object('TEN' VALUE c1, 'ND' VALUE c2) RETURNING CLOB) INTO mkt_xdbb FROM temp_5;
    
    -- Clean up all temp tables at once
    DELETE temp_2;
    DELETE temp_3;
    DELETE temp_5;
    DELETE temp_6;
    DELETE temp_7;
    DELETE TEMP_4;
    
    -- ===== CALCULATE THUE & PHI =====
    IF b_tsuat_ts = 0 THEN
        -- Calculate from detailed records
        SELECT SUM(CASE WHEN pvi_tc = 'M' THEN thue ELSE 0 END),
               SUM(CASE WHEN pvi_tc = 'M' THEN phi ELSE 0 END),
               SUM(CASE WHEN pvi_tc = 'B' THEN thue ELSE 0 END),
               SUM(CASE WHEN pvi_tc = 'B' THEN phi ELSE 0 END),
               SUM(CASE WHEN pvi_tc IN ('C', 'D') THEN thue ELSE 0 END),
               SUM(CASE WHEN pvi_tc IN ('C', 'D') THEN phi ELSE 0 END)
        INTO thue_kh, phi_kh, thue_ts, phi_ts, thue_ts_rr, phi_ts_rr
        FROM bh_pkt_dk
        WHERE so_id = b_so_id;
    ELSE
        -- Calculate from PT
        phi_ts := b_tien_ts * b_pt_ts / 100;
        phi_ts_rr := b_tien_ts * b_pt_rr / 100;
        phi_kh := b_tien_kh * b_pt_kh / 100;
        thue_ts := phi_ts * b_tsuat_ts / 100;
        thue_ts_rr := phi_ts_rr * b_tsuat_ts / 100;
        thue_kh := phi_kh * b_tsuat_kh / 100;
    END IF;
    
    PKH_JS_THAYa(dt_ct, 'thue_ts,thue_ts_rr,thue_kh,phi_ts,phi_ts_rr,phi_kh',
                 thue_ts || ',' || thue_ts_rr || ',' || thue_kh || ',' || phi_ts || ',' || phi_ts_rr || ',' || phi_kh);
    PKH_JS_THAYa(dt_ct, 'ptts_rr,ptts_ts,ptts_kh',
                 (FBH_TO_CHAR(b_pt_rr) || '%') || ',' || (FBH_TO_CHAR(b_pt_ts) || '%') || ',' || (FBH_TO_CHAR(b_pt_kh) || '%'));
    
    -- ===== GET LOAI BH =====
    SELECT JSON_ARRAYAGG(json_object(ma, loai) ORDER BY loai RETURNING CLOB)
    INTO dt_lbh FROM bh_pkt_lbh;
    
    -- ===== BUILD FINAL OUTPUT =====
    SELECT json_object(
        'dt_ct' VALUE dt_ct,
        'dt_dk' VALUE dt_dk,
        'dt_pvi' VALUE dt_pvi,
        'dt_dkbs' VALUE dt_dkbs,
        'dt_pvi_nd' VALUE dt_pvi_nd,
        'dt_lt' VALUE dt_lt,
        'dt_kbt' VALUE dt_kbt,
        'dt_kytt' VALUE dt_kytt,
        'dt_phi' VALUE dt_phi,
        'dt_lbh' VALUE dt_lbh,
        'pvi_ts' VALUE pvi_ts,
        'pvi_gdkd' VALUE pvi_gdkd,
        'qt_ts' VALUE qt_ts,
        'qt_gdkd' VALUE qt_gdkd,
        'ds_ct' VALUE ds_ct,
        'dt_qt' VALUE c_quy_tac,
        'dt_ttt' VALUE dt_ttt,
        'mkt_tt' VALUE mkt_tt,
        'mkt_rr' VALUE mkt_rr,
        'mkt_tntb' VALUE mkt_tntb,
        'dt_lt_nd' VALUE dt_lt_nd,
        'dt_bs_nd' VALUE dt_bs_nd,
        'mkt_xdbb' VALUE mkt_xdbb
    RETURNING CLOB)
    INTO b_oraOut FROM DUAL;
    
    COMMIT;
    
EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20105, SQLERRM);
END PBH_PKT_HD_XDLD;
/

-- =====================================================================
DROP PROCEDURE PBH_PKT_B_HD_XDLD;
/

CREATE OR REPLACE PROCEDURE PBH_PKT_B_HD_XDLD(
    b_ma_dviN varchar2, b_nsd varchar2, b_pas varchar2, b_oraIn clob, b_oraOut OUT clob)
AS
    b_loi varchar2(100);
    b_i1 number;
    b_ma_dt varchar2(500);
    b_nd_dkhoan nvarchar2(500);
    b_nd_qtac nvarchar2(500);
    b_ma_qtac varchar2(10);
    b_lenh varchar2(1000);
    
    b_ma_dvi varchar2(10) := FKH_JS_GTRIs(b_oraIn, 'ma_dvi');
    b_so_id number := FKH_JS_GTRIs(b_oraIn, 'so_id');
    b_lan number := TO_NUMBER(FKH_JS_GTRIs(b_oraIn, 'lan_in'));
    
    a_pvbh_ma pht_type.a_var;
    a_pvbh_ten pht_type.a_nvar;
    a_pvbh_ptts pht_type.a_num;
    a_pvbh_tc pht_type.a_var;
    
    dt_ct clob;
    dt_dk clob;
    dt_lt clob;
    dt_kbt clob;
    dt_kytt clob;
    dt_pvi clob;
    dt_dkbs clob;
    dt_pvi_nd clob;
    dt_phi clob;
    dt_lbh clob;
    dt_ttt clob;
    ds_ct clob;
    
    pvi_ts clob;
    pvi_gdkd clob;
    b_dvi clob;
    qt_ts clob;
    qt_gdkd clob;
    c_quy_tac clob;
    
    thue_ts number := 0;
    thue_ts_rr number := 0;
    thue_kh number := 0;
    phi_ts number := 0;
    phi_ts_rr number := 0;
    phi_kh number := 0;
    
    b_ma_sp varchar2(20);
    b_ten_sp nvarchar2(500) := ' ';
    
BEGIN
    b_ma_dvi := NVL(TRIM(b_ma_dvi), b_ma_dviN);
    
    -- ===== LOAD dt_ct & merged info =====
    BEGIN
        SELECT FKH_JS_BONH(t.txt),
               FKH_JS_GTRIs(FKH_JS_BONH(t.txt), 'ma_dt'),
               FKH_JS_GTRIs(FKH_JS_BONH(t.txt), 'ma_sp')
        INTO dt_ct, b_ma_dt, b_ma_sp
        FROM bh_pktB_txt t
        WHERE t.so_id = b_so_id AND t.loai = 'dt_ct' AND lan = b_lan
        AND ROWNUM = 1;
        
        IF TRIM(b_ma_sp) IS NOT NULL THEN
            BEGIN
                SELECT UPPER(ten) INTO b_ten_sp FROM bh_pkt_sp WHERE ma = b_ma_sp;
            EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
            END;
        END IF;
        
        SELECT json_object(
            'ten_dvi' VALUE NVL(ten, ' '),
            'dchi_dvi' VALUE NVL(dchi, ' '),
            'ma_tk_dvi' VALUE NVL(ma_tk, ' '),
            'nhang_dvi' VALUE NVL(nhang, ' '),
            'gdoc_dvi' VALUE NVL(g_doc, ' '),
            'ma_thue_dvi' VALUE NVL(ma_thue, ' ') RETURNING CLOB)
        INTO b_dvi
        FROM ht_ma_dvi
        WHERE ma = b_ma_dvi;
        
        dt_ct := FKH_JS_BONH(dt_ct);
        b_dvi := FKH_JS_BONH(b_dvi);
        SELECT json_mergepatch(dt_ct, b_dvi) INTO dt_ct FROM DUAL;
        
        -- ===== LOAD ALL THUE/PHI IN ONE QUERY =====
        SELECT SUM(CASE WHEN pvi_tc = 'M' THEN thue ELSE 0 END),
               SUM(CASE WHEN pvi_tc = 'M' THEN phi ELSE 0 END),
               SUM(CASE WHEN pvi_tc = 'B' THEN thue ELSE 0 END),
               SUM(CASE WHEN pvi_tc = 'B' THEN phi ELSE 0 END),
               SUM(CASE WHEN pvi_tc IN ('C', 'D') THEN thue ELSE 0 END),
               SUM(CASE WHEN pvi_tc IN ('C', 'D') THEN phi ELSE 0 END)
        INTO thue_kh, phi_kh, thue_ts, phi_ts, thue_ts_rr, phi_ts_rr
        FROM bh_pkt_dk
        WHERE so_id = b_so_id;
        
        PKH_JS_THAYa(dt_ct, 'thue_ts,thue_ts_rr,thue_kh,phi_ts,phi_ts_rr,phi_kh',
                     thue_ts || ',' || thue_ts_rr || ',' || thue_kh || ',' || phi_ts || ',' || phi_ts_rr || ',' || phi_kh);
        PKH_JS_THAYa(dt_ct, 'ten_sp', b_ten_sp);
        
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;
    
    -- ===== LOAD ALL TEXT DATA (consolidated) =====
    FOR r_txt IN (
        SELECT loai, FKH_JS_BONH(txt) AS txt_content
        FROM bh_pktB_txt
        WHERE so_id = b_so_id AND lan = b_lan AND loai IN ('ds_dk', 'ds_pvi', 'ds_dkbs', 'ds_lt', 'ds_kbt', 'ds_ttt', 'ds_ct')
    ) LOOP
        CASE r_txt.loai
            WHEN 'ds_dk' THEN dt_dk := r_txt.txt_content;
            WHEN 'ds_pvi' THEN dt_pvi := r_txt.txt_content;
            WHEN 'ds_dkbs' THEN dt_dkbs := r_txt.txt_content;
            WHEN 'ds_lt' THEN dt_lt := r_txt.txt_content;
            WHEN 'ds_kbt' THEN dt_kbt := r_txt.txt_content;
            WHEN 'ds_ttt' THEN dt_ttt := r_txt.txt_content;
            WHEN 'ds_ct' THEN ds_ct := r_txt.txt_content;
        END CASE;
    END LOOP;
    
    -- ===== LOAD DT_PVI_ND =====
    BEGIN
        SELECT FKH_JS_BONH(ttin) INTO dt_pvi_nd FROM bh_hd_goc_ttdt 
        WHERE so_id = b_so_id AND TRIM(ttin) IS NOT NULL AND ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;
    
    SELECT JSON_ARRAYAGG(json_object(ngay, tien) ORDER BY ngay) INTO dt_kytt FROM bh_pkt_tt WHERE so_id = b_so_id;
    
    -- ===== PROCESS dt_pvi =====
    IF dt_pvi IS NOT NULL AND dt_pvi <> '""' THEN
        dt_pvi := REPLACE(SUBSTR(dt_pvi, 3, LENGTH(dt_pvi) - 4), '\', '');
        b_lenh := FKH_JS_LENH('ten,ma,ptts,tc');
        EXECUTE IMMEDIATE b_lenh BULK COLLECT INTO a_pvbh_ten, a_pvbh_ma, a_pvbh_ptts, a_pvbh_tc USING dt_pvi;
        
        FOR b_lp IN 1..a_pvbh_ma.COUNT LOOP
            BEGIN
                SELECT FKH_JS_GTRIs(FKH_JS_BONH(t.txt), 'ma_dk'),
                       FKH_JS_GTRIs(FKH_JS_BONH(t.txt), 'ma_qtac')
                INTO b_nd_dkhoan, b_nd_qtac
                FROM bh_pkt_pvi t
                WHERE t.ma = a_pvbh_ma(b_lp);
                
                b_nd_dkhoan := SUBSTR(b_nd_dkhoan, 1, INSTR(b_nd_dkhoan, '|') - 1);
                b_ma_qtac := SUBSTR(b_nd_qtac, 1, INSTR(b_nd_qtac, '|') - 1);
                b_nd_qtac := SUBSTR(b_nd_qtac, INSTR(b_nd_qtac, '|') + 1);
                
                BEGIN
                    SELECT NVL(FKH_JS_GTRIs(FKH_JS_BONH(t.txt), 'nd'), '')
                    INTO b_nd_dkhoan
                    FROM BH_MA_DK t
                    WHERE ma = b_nd_dkhoan;
                EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
                END;
                
                INSERT INTO TEMP_4(c1, cl1)
                SELECT b_ma_qtac, b_nd_qtac FROM DUAL
                WHERE NOT EXISTS (SELECT 1 FROM TEMP_4 WHERE c1 = b_ma_qtac);
                
                IF a_pvbh_ptts(b_lp) <> 0 THEN
                    INSERT INTO temp_7(cl1, cl2, c3, n1) VALUES(b_nd_dkhoan, b_nd_qtac, a_pvbh_tc(b_lp), 1);
                ELSE
                    INSERT INTO temp_6(cl1, cl2, n1) VALUES(b_nd_dkhoan, b_nd_qtac, 0);
                END IF;
                
            EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
            END;
        END LOOP;
    ELSE
        dt_pvi := '';
    END IF;
    
    -- ===== BUILD JSON AGGREGATES =====
    SELECT JSON_ARRAYAGG(json_object('TEN' VALUE cl1) RETURNING CLOB) INTO c_quy_tac FROM TEMP_4;
    SELECT JSON_ARRAYAGG(json_object('ND_DK' VALUE cl1, 'TC' VALUE c3, 'STT' VALUE N1) 
                        ORDER BY n1 RETURNING CLOB) INTO pvi_ts FROM temp_7 WHERE cl1 IS NOT NULL;
    SELECT JSON_ARRAYAGG(json_object('ND_DK' VALUE cl1, 'STT' VALUE N1) 
                        ORDER BY n1 RETURNING CLOB) INTO pvi_gdkd FROM temp_6 WHERE cl1 IS NOT NULL;
    SELECT JSON_ARRAYAGG(json_object('ND_QTAC' VALUE cl2, 'TC' VALUE c3, 'STT' VALUE N1) 
                        ORDER BY n1 RETURNING CLOB) INTO qt_ts FROM temp_7 WHERE cl2 IS NOT NULL;
    SELECT JSON_ARRAYAGG(json_object('ND_QTAC' VALUE cl2, 'STT' VALUE N1) 
                        ORDER BY n1 RETURNING CLOB) INTO qt_gdkd FROM temp_6 WHERE cl2 IS NOT NULL;
    
    -- Clean up temp tables
    DELETE TEMP_4;
    DELETE temp_6;
    DELETE temp_7;
    
    SELECT JSON_ARRAYAGG(json_object(ma, loai) ORDER BY loai RETURNING CLOB) INTO dt_lbh FROM bh_pkt_lbh;
    
    -- ===== FINAL OUTPUT =====
    SELECT json_object(
        'dt_ct' VALUE dt_ct,
        'dt_dk' VALUE dt_dk,
        'dt_pvi' VALUE dt_pvi,
        'dt_dkbs' VALUE dt_dkbs,
        'dt_pvi_nd' VALUE dt_pvi_nd,
        'dt_lt' VALUE dt_lt,
        'dt_kbt' VALUE dt_kbt,
        'dt_kytt' VALUE dt_kytt,
        'dt_phi' VALUE dt_phi,
        'dt_lbh' VALUE dt_lbh,
        'pvi_ts' VALUE pvi_ts,
        'pvi_gdkd' VALUE pvi_gdkd,
        'qt_ts' VALUE qt_ts,
        'qt_gdkd' VALUE qt_gdkd,
        'ds_ct' VALUE ds_ct,
        'dt_qt' VALUE c_quy_tac
    RETURNING CLOB)
    INTO b_oraOut FROM DUAL;
    
    COMMIT;
    
EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20105, SQLERRM);
END PBH_PKT_B_HD_XDLD;

