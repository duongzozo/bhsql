CREATE OR REPLACE FUNCTION FBH_BC_TTT_ND(dt_ttt clob,b_ma varchar2)
RETURN NVARCHAR2
IS
    b_ketqua NVARCHAR2(1000):= ' ';
    b_lenh varchar2(1000);
    a_ttt_ma pht_type.a_var; a_ttt_nd pht_type.a_nvar;
BEGIN
    b_lenh := FKH_JS_LENH('ma,nd');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ttt_ma,a_ttt_nd USING dt_ttt;
    for b_lp in 1..a_ttt_ma.count loop
        if a_ttt_ma(b_lp) = b_ma then
            b_ketqua := a_ttt_nd(b_lp);
        end if;
    end loop;
    return b_ketqua;
END;
/
create or replace procedure PBH_BCTK_HH_SP(
    dk_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    dt_sp clob;b_loi VARCHAR2(100):= ' ';
begin
delete temp_1;
insert into temp_1(c1,c2) values('', N'----Chọn sản phẩm----');
insert into temp_1(c1,c2) select ma,ten from bh_tau_sp;
insert into temp_1(c1,c2) select ma,ten from bh_hang_nhom;
insert into temp_1(c1,c2) select ma,ten from bh_ptncc_sp a,(select distinct ma_sp from bh_ptnvc_phi) b where a.ma=b.ma_sp and FBH_PTNCC_SP_HAN(a.ma)='C';

select JSON_ARRAYAGG(json_object('ma' VALUE c1,'ten' value c2 returning clob) returning clob) into dt_sp from temp_1;
delete temp_1;commit;

select json_object('dt_sp' value dt_sp returning clob) into b_oraOut from dual;

exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
/
create or replace procedure PBH_BC_BCTK_HH(
    dk_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000);
    b_loi varchar2(100); b_i1 number;
    b_ngayd number :=FKH_JS_GTRIn(b_oraIn,'ngayd');
    b_ngayc number :=FKH_JS_GTRIn(b_oraIn,'ngayc');
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_ma_sp varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_sp');
    b_ttrang varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ttrang');
    b_loai_bc varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'loai_bc');

    dt_ct clob;dt_ds clob;
 
begin
b_ma_dvi:=nvl(trim(b_ma_dvi),dk_ma_dviN);
---dt_ct
select json_object('ngayd' value FBH_IN_CSO_NG(b_ngayd,'DD/MM/YYYY'),'ngayc' value FBH_IN_CSO_NG(b_ngayc,'DD/MM/YYYY'),
'ma_dvi' value b_ma_dvi,'ma_sp' value b_ma_sp,'user' value b_nsd,'ngay_ht' value FBH_IN_CSO_NG(TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDD')),'DD/MM/YYYY') returning clob) into dt_ct from dual;

--------------------bh ptnhang
insert into temp_1(C1,C2,C3,c4,c5,c6,c7,c9,c10,c11,c12,c13,c18,c22,c19,c14,c15,c20,c21,c16,c17,c32,c33,c34,c35)
SELECT
    a.ma_dvi,
    dvi.ten        AS ten_dvi,
    case when a.so_id_g <> 0 then SUBSTR(to_char(a.so_id_d), 3)  else a.so_hd end,
    case when a.so_id_g <> 0 then to_char(a.so_id) else '' end,
    case when a.so_id_g <> 0 then a.so_hd else '' end,
    a.ma_kh         AS dtac_ma,
    dt.ten          AS ten_dtac,
    a.ma_sp,
    FBH_IN_CSO_NG(a.ngay_ht,'DD/MM/YYYY'),
    FBH_IN_CSO_NG(a.ngay_cap,'DD/MM/YYYY'),
    FBH_IN_CSO_NG(a.ngay_hl,'DD/MM/YYYY'),
    FBH_IN_CSO_NG(a.ngay_kt,'DD/MM/YYYY'),
    dk.ma,
    dk.ma_dk,
    dk.ten          AS ten_dk,
    FBH_CSO_TIEN(dk.tien,''),
    FBH_CSO_TIEN(dk.phi,''),
    a.ma_kt,
    CASE a.kieu_kt
        WHEN 'T' THEN cb.ten
        WHEN 'D' THEN kh.ten
        WHEN 'M' THEN kh.ten
        WHEN 'N' THEN nh.ten
    END AS ten_kt,
    a.ma_gt,
    CASE a.kieu_gt
        WHEN 'C' THEN cb2.ten
        WHEN 'K' THEN kh2.ten
        WHEN 'D' THEN kh2.ten
        WHEN 'N' THEN nh2.ten
    END AS ten_gt,
    a.nt_tien,
    a.nt_phi,
    FKH_JS_GTRIs(dt_ct.txt ,'tygia') as tygia,
    FBH_IN_SUBSTR(a.so_hd,'B','S')
FROM bh_ptnvc a
JOIN bh_ptnvc_DK dk  ON a.ma_dvi = dk.ma_dvi AND a.so_id  = dk.so_id
LEFT JOIN HT_MA_DVI dvi  ON a.ma_dvi = dvi.ma
LEFT JOIN BH_DTAC_MA dt ON a.ma_dvi = dt.ma_dvi AND a.ma_kh  = dt.ma
LEFT JOIN BH_HD_GOC g ON a.ma_dvi = g.ma_dvi AND a.so_id  = g.so_id
LEFT JOIN ht_ma_cb cb ON cb.ma = a.ma_kt 
LEFT JOIN bh_dl_ma_kh kh ON kh.ma = a.ma_kt
LEFT JOIN bh_ma_nhang nh ON nh.ma = a.ma_kt
LEFT JOIN ht_ma_cb cb2 ON cb2.ma = a.ma_gt 
LEFT JOIN bh_dl_ma_kh kh2 ON kh2.ma = a.ma_gt
LEFT JOIN bh_ma_nhang nh2 ON nh2.ma = a.ma_gt
LEFT JOIN bh_ptnvc_txt dt_ct ON a.so_id = dt_ct.so_id and dt_ct.loai = 'dt_ct'
WHERE a.ma_dvi   = b_ma_dvi
  AND a.ngay_cap BETWEEN b_ngayd AND b_ngayc
  AND (b_ma_sp IS NULL OR a.ma_sp = b_ma_sp)
  AND (b_ttrang IS NULL OR a.ttrang = b_ttrang)
  AND (
    b_loai_bc IS NULL
        OR (b_loai_bc = 'TKHH_01' AND a.ngay_kt <= TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDD')) AND a.ttrang <> 'S')
        OR (b_loai_bc = 'TKHH_02' AND a.ngay_kt >  TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDD')) AND a.ttrang <> 'S')
        OR (b_loai_bc = 'TKHH_03' AND a.kieu_hd = 'B' and a.ttrang <> 'D')
    )
ORDER BY a.ma_dvi, a.so_hd, dk.bt;

---------------------tau
insert into temp_1(C1,C2,C3,c4,c5,c6,c7,c9,c10,c11,c12,c13,c18,c22,c19,c14,c15,c20,c21,c16,c17,c23,c24,c25,c32,c33,c34,c35)
SELECT
    a.ma_dvi,
    dvi.ten        AS ten_dvi,
    case when a.so_id_g <> 0 then SUBSTR(to_char(a.so_id_d), 3) else a.so_hd end,
    case when a.so_id_g <> 0 then to_char(a.so_id) else '' end,
    case when a.so_id_g <> 0 then a.so_hd else '' end,
    a.ma_kh         AS dtac_ma,
    dt.ten          AS ten_dtac,
    ds.ma_sp,
    FBH_IN_CSO_NG(a.ngay_ht,'DD/MM/YYYY'),
    FBH_IN_CSO_NG(a.ngay_cap,'DD/MM/YYYY'),
    FBH_IN_CSO_NG(a.ngay_hl,'DD/MM/YYYY'),
    FBH_IN_CSO_NG(a.ngay_kt,'DD/MM/YYYY'),
    dk.ma,
    dk.ma_dk,
    dk.ten          AS ten_dk,
    FBH_CSO_TIEN(dk.tien,''),
    FBH_CSO_TIEN(dk.phi,''),
    a.ma_kt,
    CASE a.kieu_kt
        WHEN 'T' THEN cb.ten
        WHEN 'D' THEN kh.ten
        WHEN 'M' THEN kh.ten
        WHEN 'N' THEN nh.ten
    END AS ten_kt,
    a.ma_gt,
    CASE a.kieu_gt
        WHEN 'C' THEN cb2.ten
        WHEN 'K' THEN kh2.ten
        WHEN 'D' THEN kh2.ten
        WHEN 'N' THEN nh2.ten
    END AS ten_gt,
    ----
    ds.so_dk as ma_tau,
    ds.ten_tau,
    ds.tenc,
    a.nt_tien,
    a.nt_phi,
    FKH_JS_GTRIs(dt_ct.txt ,'tygia') as tygia,
    FBH_IN_SUBSTR(a.so_hd,'B','S')
FROM BH_TAU a
JOIN BH_TAU_DK dk ON a.ma_dvi = dk.ma_dvi AND a.so_id  = dk.so_id
LEFT JOIN HT_MA_DVI dvi ON a.ma_dvi = dvi.ma
LEFT JOIN BH_DTAC_MA dt ON a.ma_dvi = dt.ma_dvi AND a.ma_kh  = dt.ma
LEFT JOIN BH_tau_ds ds  ON a.ma_dvi = ds.ma_dvi  AND a.so_id  = ds.so_id
LEFT JOIN BH_HD_GOC g ON a.ma_dvi = g.ma_dvi AND a.so_id  = g.so_id

LEFT JOIN ht_ma_cb cb ON cb.ma = g.ma_kt
LEFT JOIN bh_dl_ma_kh kh ON kh.ma = g.ma_kt
LEFT JOIN bh_ma_nhang nh ON nh.ma = g.ma_kt
LEFT JOIN ht_ma_cb cb2 ON cb2.ma = a.ma_gt 
LEFT JOIN bh_dl_ma_kh kh2 ON kh2.ma = a.ma_gt
LEFT JOIN bh_ma_nhang nh2 ON nh2.ma = a.ma_gt
LEFT JOIN BH_tau_txt dt_ct ON a.so_id = dt_ct.so_id and dt_ct.loai = 'dt_ct'
WHERE a.ma_dvi   = b_ma_dvi
    AND a.ngay_cap BETWEEN b_ngayd AND b_ngayc
    AND (b_ma_sp IS NULL OR ds.ma_sp = b_ma_sp)
    AND (b_ttrang IS NULL OR a.ttrang = b_ttrang)
    AND (
    b_loai_bc IS NULL
        OR (b_loai_bc = 'TKHH_01' AND a.ngay_kt <= TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDD')) AND a.ttrang <> 'S')
        OR (b_loai_bc = 'TKHH_02' AND a.ngay_kt >  TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDD')) AND a.ttrang <> 'S')
        OR (b_loai_bc = 'TKHH_03' AND a.kieu_hd = 'B' and a.ttrang <> 'D')
    )
ORDER BY a.ma_dvi, a.so_hd, dk.bt;

-------------------hang
insert into temp_1(C1,C2,C3,c4,c5,c6,c7,c9,c10,c11,c12,c13,c18,c22,c19,c14,c15,c20,c21,c16,c17,c29,c26,c27,c28,c30,c31,c32,c33,c34,c8,c35)
SELECT
    a.ma_dvi,
    dvi.ten        AS ten_dvi,
    case when a.so_id_g <> 0 then SUBSTR(to_char(a.so_id_d), 3) else a.so_hd end as so_hd,
    case when a.so_id_g <> 0 then to_char(a.so_id) else '' end as so_dkbs_id,
    case when a.so_id_g <> 0 then a.so_hd else '' end as  so_dkbs,
    a.ma_kh         AS dtac_ma,
    dt.ten          AS ten_dtac,
    a.NHANG,
    FBH_IN_CSO_NG(a.ngay_ht,'DD/MM/YYYY'),
    FBH_IN_CSO_NG(a.ngay_cap,'DD/MM/YYYY'),
    FBH_IN_CSO_NG(a.ngay_hl,'DD/MM/YYYY'),
    FBH_IN_CSO_NG(a.ngay_kt,'DD/MM/YYYY'),
    dk.ma,
    dk.ma_dk,
    dk.ten          AS ten_dk,
    FBH_CSO_TIEN(dk.tien,''),
    FBH_CSO_TIEN(dk.phi,''),
    g.ma_kt,
    CASE a.kieu_kt
        WHEN 'T' THEN cb.ten
        WHEN 'D' THEN kh.ten
        WHEN 'M' THEN kh.ten
        WHEN 'N' THEN nh.ten
    END AS ten_kt,
    a.ma_gt,
    CASE a.kieu_gt
        WHEN 'C' THEN cb2.ten
        WHEN 'K' THEN kh2.ten
        WHEN 'D' THEN kh2.ten
        WHEN 'N' THEN nh2.ten
    END AS ten_gt,
    ds.ma_lhang,
    FKH_JS_GTRIs(txt.txt ,'noi_di') ||  ' - ' || FKH_JS_GTRIs(txt.txt ,'noi_den')  as chuyen_di,
    FKH_JS_GTRIs(txt.txt ,'cang_di'),
    FKH_JS_GTRIs(txt.txt ,'cang_den'),
    FBH_BC_TTT_ND(FKH_JS_BONH(ttt.txt),'SVD') as SVD,
    FBH_BC_TTT_ND(FKH_JS_BONH(ttt.txt),'NVD') as NVD,
    a.nt_tien,
    a.nt_phi,
    FKH_JS_GTRIs(txt.txt ,'tygia') as tygia,
    FKH_JS_GTRIs(txt.txt ,'bsungd') as bsungd,
    FBH_IN_SUBSTR(a.so_hd,'B','S')
FROM BH_hang a
JOIN BH_hang_DK dk ON a.ma_dvi = dk.ma_dvi AND a.so_id  = dk.so_id
LEFT JOIN HT_MA_DVI dvi ON a.ma_dvi = dvi.ma
LEFT JOIN BH_DTAC_MA dt ON a.ma_dvi = dt.ma_dvi AND a.ma_kh  = dt.ma
LEFT JOIN BH_hang_DS ds ON a.ma_dvi = ds.ma_dvi AND a.so_id  = ds.so_id
LEFT JOIN BH_HD_GOC g ON a.ma_dvi = g.ma_dvi AND a.so_id  = g.so_id
LEFT JOIN ht_ma_cb cb ON cb.ma = g.ma_kt
LEFT JOIN bh_dl_ma_kh kh ON kh.ma = g.ma_kt
LEFT JOIN bh_ma_nhang nh ON nh.ma = g.ma_kt
LEFT JOIN ht_ma_cb cb2 ON cb2.ma = a.ma_gt 
LEFT JOIN bh_dl_ma_kh kh2 ON kh2.ma = a.ma_gt
LEFT JOIN bh_ma_nhang nh2 ON nh2.ma = a.ma_gt
LEFT JOIN BH_hang_txt txt ON a.so_id = txt.so_id and txt.loai = 'dt_ct'
LEFT JOIN BH_hang_txt ttt ON a.so_id = ttt.so_id and ttt.loai = 'dt_ttt'
WHERE a.ma_dvi   = b_ma_dvi
  AND a.ngay_cap BETWEEN b_ngayd AND b_ngayc
  AND (b_ma_sp IS NULL OR a.nhang = b_ma_sp)
  AND (b_ttrang IS NULL OR a.ttrang = b_ttrang)
  AND (
    b_loai_bc IS NULL
        OR (b_loai_bc = 'TKHH_01' AND a.ngay_kt <= TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDD')) AND a.ttrang <> 'S')
        OR (b_loai_bc = 'TKHH_02' AND a.ngay_kt >  TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDD')) AND a.ttrang <> 'S')
        OR (b_loai_bc = 'TKHH_03' AND a.kieu_hd = 'B' and a.ttrang <> 'D')
    )
  
ORDER BY a.ma_dvi, a.so_hd, dk.bt;

select JSON_ARRAYAGG(json_object(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15,C16,C17,C18,C19,C20,
C21,C22,C23,C24,C25,C26,C27,C28,C29,C30,C31,c32,c33,c34,c35) returning clob) into dt_ds from temp_1;
delete temp_1;commit;

select json_object('dt_ct' value dt_ct,'dt_ds' value dt_ds returning clob) into b_oraOut from dual;

exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;