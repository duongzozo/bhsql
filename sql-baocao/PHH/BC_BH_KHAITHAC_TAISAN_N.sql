create or replace  function FBH_PHH_LHNV_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Duong
select min(ten) into b_kq from bh_ma_lhnv where ma=b_ma;
return b_kq;
end;
/
drop PROCEDURE BC_BH_KHAITHAC_TAISAN;
/
CREATE OR REPLACE PROCEDURE BC_BH_KHAITHAC_TAISAN (
    b_madvi VARCHAR2,b_nsd VARCHAR2,b_pas VARCHAR2,b_ma_dvi VARCHAR2,b_ma_nv VARCHAR2,b_phong VARCHAR2,b_loai_kh VARCHAR2,
    b_ma_kh VARCHAR2,b_ma_cb VARCHAR2,b_tc VARCHAR2,b_ttrang VARCHAR2,b_ngayd NUMBER,b_ngayc NUMBER,
    cs_kq OUT pht_type.cs_type
)
AS
    b_loi  VARCHAR2(100);
    b_ngaydn NUMBER;
    b_rr VARCHAR2(100);
BEGIN
    -- Kiem tra user
    b_loi := FHT_MA_NSD_KTRA(b_madvi, b_nsd, b_pas, 'BH', 'PHH', 'X');
    IF b_loi IS NOT NULL THEN
  RAISE PROGRAM_ERROR;
    END IF;
    -- Kiem tra ngay bao cao
    IF b_ngayd IS NULL OR b_ngayc IS NULL THEN
  b_loi := 'loi:Nhap ngay bao cao:loi';
  RAISE PROGRAM_ERROR;
    END IF;

    b_ngaydn := ROUND(b_ngayd, -4) + 101;

    DELETE FROM temp_6;
    COMMIT;

    FOR r_lp IN (
        SELECT a.so_id, a.so_hd, a.ngay_cap, a.ten, a.ma_sp,a.kieu_kt,a.ma_kt,a.phong,a.ma_dvi,
        b.ma_dt,dt.nhom, b.mrr, b.dvi, b.ngay_hl, b.ngay_kt, a.nt_tien,
        b.so_id_dt
        FROM bh_phh a
        JOIN bh_phh_dvi b ON a.so_id = b.so_id
        JOIN bh_phh_dtuong dt ON dt.ma = b.ma_dt
        WHERE a.ngay_ht BETWEEN b_ngayd AND b_ngayc
        and b.ma_dvi=a.ma_dvi and b.so_id=a.so_id
        and (b_ma_dvi is null or a.ma_dvi = b_ma_dvi) and (b_ma_kh is null or a.ma_kh = b_ma_kh)
        and (b_phong is null or a.phong = b_phong) order by ngay_cap,so_hd
    )
    LOOP
        SELECT LISTAGG(ma, ',') WITHIN GROUP (ORDER BY ma) into b_rr
            FROM (SELECT DISTINCT ma
                FROM bh_phh_dk
                WHERE so_id = r_lp.so_id AND so_id_dt = r_lp.so_id_dt
                    AND TRIM(ma_ct) IS NULL and tc = 'T');

        FOR r IN (
        SELECT t.TONG_TIEN,t.TONG_THUE,t.TONG_TTOAN,t.TONG_PT
        FROM
            (
            SELECT  SUM(TIEN) AS TONG_TIEN,SUM(THUE) AS TONG_THUE, SUM(TTOAN) AS TONG_TTOAN, SUM(PT) AS TONG_PT
            FROM bh_phh_dk
            WHERE so_id = r_lp.so_id AND so_id_dt = r_lp.so_id_dt
            AND lh_nv<>' '
            ) t
        )
        LOOP
            INSERT INTO temp_6 (n1, c1, n2, c2, c3, c4, c5, c6,n3, n4, c7, n5, n6, n7, n8, n9,c9,c11,c12,c13,c14) VALUES (
            r_lp.so_id, r_lp.so_hd, r_lp.ngay_cap, r_lp.ten, FBH_PHH_SP_TEN(r_lp.ma_sp),FBH_PHH_NHOM_CAT(r_lp.nhom), b_rr, r_lp.dvi, r_lp.ngay_hl, r_lp.ngay_kt,
            r_lp.nt_tien, r_lp.so_id_dt, r.TONG_TIEN, r.TONG_THUE, r.TONG_TTOAN, r.TONG_PT,r_lp.ma_dt,
            r_lp.kieu_kt,r_lp.ma_kt,r_lp.phong,r_lp.ma_dvi
            );
        END LOOP;
    END LOOP;

    OPEN cs_kq FOR
  SELECT rownum stt,n1, c1 so_hd, PKH_SO_CNG(n2) ngay_cap, c2 ten, c3 ma_sp, c4 ma_dt, c5 rr_bh, c6 ddiem,PKH_SO_CNG(n3) ngay_hl, PKH_SO_CNG(n4) ngay_kt, c7 ma_nt, n5 so_id_dt,
  FBH_CSO_TIEN_KNT(n6) tien, FBH_CSO_TIEN_KNT(n7) TONG_THUE, FBH_CSO_TIEN_KNT(n8) phi, n9 tyle,c9 doi_tuong, c11 kieu_kt, c12 ma_kt, c13 phong, c14 dvi
  FROM temp_6;

  delete temp_6;
  commit;
EXCEPTION
    WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR(-20105, NVL(b_loi, SQLERRM));
END;

