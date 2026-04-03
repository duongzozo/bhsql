create or replace procedure BC_BH_TK_TAU
    (B_MADVI VARCHAR2,B_NSD VARCHAR2,B_PAS VARCHAR2,b_oraIn clob,b_oraOut out clob)
AS
    B_LENH VARCHAR2(2000);B_LOI VARCHAR2(100);B_NGAYDN NUMBER;B_I1 NUMBER;B_TTRANG1 VARCHAR2(10);
    B_LOAI VARCHAR2(10);B_MA_DVI VARCHAR2(10);B_MA_NV VARCHAR2(10);B_PHONG VARCHAR2(10);B_TTRANG VARCHAR2(10);
    B_NGAYD NUMBER;B_NGAYC NUMBER;dt_ds clob;
Begin
-- Bao cao thong ke tau
b_loi:=FHT_MA_NSD_KTRA(b_madvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,ma_nv,phong,ttrang1,ngayd,ngayc');
EXECUTE IMMEDIATE b_lenh 
into B_MA_DVI,B_MA_NV,B_PHONG,B_TTRANG,B_NGAYD,B_NGAYC using b_oraIn;
B_MA_DVI:= nvl(trim(B_MA_DVI),null); B_MA_NV:= nvl(trim(B_MA_NV),null); B_PHONG:= nvl(trim(B_PHONG),null); B_TTRANG:= nvl(trim(B_TTRANG),null);
if b_ngayd is null or b_ngayc is null then
    b_loi:='loi:Nhap ngay bao cao:loi'; raise PROGRAM_ERROR;
end if;
b_ngaydn:=round(b_ngayd,-4)+101;b_loi:='loi:Ma chua dang ky:loi';
delete temp_1;delete temp_2;delete temp_3;delete ket_qua; commit;

PBC_LAY_DVI(b_madvi,b_ma_dvi,b_nsd,b_pas,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
BC_BH_TK_TAU_MD (b_madvi,b_ma_dvi,b_ma_nv,b_phong,b_ngayd,b_ngayc,b_loi);
if b_ttrang<>'*' then b_ttrang1:=b_ttrang; end if;
select count(*) into b_i1 from temp_bc_dvi;
if b_i1=0 then
    insert into temp_2 (c1,c6,c8,c7,n1,n7,n3,c16,n4,n5,c19,c22,c25,c24,n6,c26,c27,c11,c10,c30,c9)
        select c1,c2,c4,c7,n1,n3,n5,c16,n2,n4,c19,c22,c25,c24,n6,c26,c27,c11,c10,c30,c9
        from temp_1,bh_hd_goc where c1=ma_dvi and n1=so_id and (b_ttrang1 is null or ttrang=b_ttrang1);
else
    insert into temp_2 (c1,c6,c8,c7,n1,n7,n3,c16,n4,n5,c19,c22,c25,c24,n6,c26,c27,c11,c10,c30,c9,n8)
        select c1,c2,c4,c7,n1,n3,n5,c16,n2,n4,c19,c22,c25,c24,n6,c26,c27,c11,c10,c30,c9,n8
        from temp_1,temp_bc_dvi,bh_hd_goc where c1=dvi and c1=ma_dvi and n1=so_id and (b_ttrang1 is null or ttrang=b_ttrang1);
end if;
--update temp_2 set (c5,c7,c11,c12,c13)=(select so_hd,ten,to_char(ngay_hl,'dd/mm/yyyy'),
--    to_char(ngay_kt,'dd/mm/yyyy'),PKH_SO_CNG(ngay_cap)
--    from bh_hd_goc where ma_dvi=temp_2.c1 and so_id=temp_2.n1);
update temp_2 set (c5,c7,c13)=(select so_hd,ten,PKH_SO_CNG(ngay_cap)
    from bh_hd_goc where ma_dvi=temp_2.c1 and so_id=temp_2.n1);

update temp_2 set c18=(select ten from bh_tau_loai where ma_dvi=temp_2.c1 and ma=temp_2.c8);
update temp_2 set (c3)=(select phong from bh_hd_goc where ma_dvi=temp_2.c1 and so_id=temp_2.n1);
update temp_2 set (c5)=(select so_hd from bh_hd_goc where ma_dvi=temp_2.c1 and so_id=temp_2.n1) where c5 is null;
update temp_2 set c4=(select ten from ht_ma_phong where ma_dvi=temp_2.c1 and ma=temp_2.c3);
update temp_2 set c2=(select ten from ht_ma_dvi where ma=temp_2.c1);
-- viet anh -- khai thac KVU trong txt
--update temp_2 set (c15,n8,c14)=(select gcn,gia,FKH_KBT_KVU(ma_dvi,so_id,gcn) from bh_tau_ds where ma_dvi=temp_2.c1 and so_id=temp_2.n1 and so_id_dt=temp_2.n7);-- where c22='TAU';
--update temp_2 set (c15)=(select so_hd from bh_hd_goc where ma_dvi=temp_2.c1 and so_id=temp_2.n1 ) where c22='TAUL';
update temp_2 set (c30,c20)=(select so_hd,ma_kh from bh_hd_goc where ma_dvi=temp_2.c1 and so_id=temp_2.n1 and nv like 'TAU%');-- where c22 in ('TAUL','TAU');
--update temp_2 set c20=(select ma_kh from bh_hd_goc where ma_dvi=temp_2.c1 and so_id=temp_2.n1);

-- khach hang quan doi
/*
update temp_2 set c23=(select 'C' from bh_hd_ma_kh where ma_dvi=temp_2.c1 and ma=temp_2.c20 and loai like '007%');
update temp_2 set c28=(select 'K' from bh_hd_ma_kh where ma_dvi=temp_2.c1 and ma=temp_2.c20 and loai not like '007%') ;
*/
update
    (select temp_2.c23 temp_2_c23
    from temp_2, bh_hd_ma_kh
    where temp_2.c1 = bh_hd_ma_kh.ma_dvi and temp_2.c20 = bh_hd_ma_kh.ma and bh_hd_ma_kh.loai like '007%')
    set temp_2_c23 = 'C';
update
    (select temp_2.c28 temp_2_c28
    from temp_2, bh_hd_ma_kh
    where temp_2.c1 = bh_hd_ma_kh.ma_dvi and temp_2.c20 = bh_hd_ma_kh.ma and bh_hd_ma_kh.loai not like '007%')
    set temp_2_c28 = 'K';
update temp_2 set c29=(decode(c23,'C','C','K'));


--update temp_2 set c21=(select ten from bh_hd_ma_kh where ma_dvi=temp_2.c1 and ma=temp_2.c20);
-- update
--     (select temp_2.c21 temp_2_c21, bh_hd_ma_kh.ten bh_hd_ma_kh_ten 
--     from temp_2, bh_hd_ma_kh
--     where temp_2.c1 = bh_hd_ma_kh.ma_dvi and temp_2.c20 = bh_hd_ma_kh.ma)
--     set temp_2_c21 = bh_hd_ma_kh_ten;

update temp_2 set c21 =(select max(ten) from bh_tau where c1 = ma_dvi and c30 = so_hd);

update temp_2 set n32=(select sum(decode(kieu,'D',100-pt,pt)) from bh_hd_do t,bh_hd_do_tl t1 where t.ma_dvi=t1.ma_dvi and t.so_id=t1.so_id and
                  t1.ma_dvi=c1 and t1.so_id=n1 and t1.pthuc='C'  and t1.so_id_dt in (0,temp_2.n7));
    --update temp_2 set n32=(select sum(decode(kieu,'D',100-pt,pt)) from bh_hd_do_tl where ma_dvi=c1 and so_id=n31 and pthuc='C') where n31<>0 and n32 is null;
    update temp_2 set n32=100 where n32 is null;
commit;

/*
update
       (select temp_2.c21 temp_2_c21, bh_hd_ma_kh.ten bh_hd_ma_kh_ten
              from temp_2, bh_hd_ma_kh
             where temp_2.c1 = bh_hd_ma_kh.ma_dvi and temp_2.c20 = bh_hd_ma_kh.ma)
       set temp_2_c21 = bh_hd_ma_kh_ten;
*/
--select * from  BH_TAU_KBT where FKH_JS_GTRIs(dk,'ma')='KVU'
/*
open cs_kq for select c1 ma_dvi,c2 ten_dvi,c3 phong,c4 ten_phong,c30 so_hd,c15 so_gcn,c6 ten_tau,c7 chu_tau,
    c18 loai_tau,c9 tt_cs,c7 pham_vi,c26 ngay_hl,c27 ngay_kt,c19 ma_dk,c16 nam_sx,n5 mtn,n5 tien_bh,n32 tyle_dong,c21 ten_kh,c24 nhom_tau,c23 loai_kh, --n4 mtn,
    n3 phi,c13 ngay_cap,n8 gia_tau,c14 muc_ktru from temp_2 order by c13, c30, c15; --c14 muc_ktru,
*/

update temp_2 a set c31 =(select max(ten) from bh_ma_dk where c1=ma_dvi and c19=ma);
update temp_2 set n8 =(select gia from bh_tau_ds where ma_dvi=temp_2.c1 and so_id=temp_2.n1 and so_id_dt=temp_2.n7);

select json_arrayagg(json_object('SO_HD' value c30,'TEN_TAU' value c6,'LOAI_TAU' value c18,'NGAY_HL' value c26,
'NGAY_KT' value c27,'MA_DK' value c19,'TEN_DK' value c31,'NAM_SX' value c16,'TIEN_BH' value FBH_CSO_TIEN(nvl(n5,0),''),
'TEN_KH' value c21, 'PHI' value FBH_CSO_TIEN(nvl(n3,0),''),'NGAY_CAP' value c13,'GIA_TAU' value FBH_CSO_TIEN(nvl(n8,0),''),
'MUC_KTRU' value c14) order by c13, c30, c15 returning clob)
into dt_ds from ( select c31,c30,c6,c18,c26,c27,c19,c16,n5,c21,n3,c13,n8,c14, min(c15) c15 
    from temp_2 group by c31,c30,c6,c18,c26,c27,c19,c16,n5,c21,n3,c13,n8,c14);
select json_object('dt_ds' value dt_ds returning clob) into b_oraOut from dual;
delete temp_1;delete temp_2;delete ket_qua; commit;
--exception when others then raise_application_error(-20105,b_loi);
end;
/
CREATE OR REPLACE PROCEDURE BC_BH_TKE_TAU_PS
    (B_MADVI VARCHAR2,B_NSD VARCHAR2,B_PAS VARCHAR2,b_oraIn clob,b_oraOut out clob)
AS
    B_LENH VARCHAR2(2000);B_LOI VARCHAR2(100);B_NGAYDN NUMBER;B_I1 NUMBER;B_TTRANG1 VARCHAR2(10);
    B_LOAI VARCHAR2(10);B_MA_DVI VARCHAR2(10);B_MA_NV VARCHAR2(10);B_PHONG VARCHAR2(10);B_TTRANG VARCHAR2(10);
    B_NGAYD NUMBER;B_NGAYC NUMBER;dt_ds clob; B_MA_KH VARCHAR2(10); B_MA_CB VARCHAR2(10);
BEGIN
B_LOI:=FHT_MA_NSD_KTRA(B_MADVI,B_NSD,B_PAS,'BH','','');
IF B_LOI IS NOT NULL THEN RAISE PROGRAM_ERROR; END IF;
b_lenh:=FKH_JS_LENH('ma_dvi,ma_nv,phong,ttrang1,ngayd,ngayc');
EXECUTE IMMEDIATE b_lenh 
into B_MA_DVI,B_MA_NV,B_PHONG,B_TTRANG,B_NGAYD,B_NGAYC using b_oraIn;
B_MA_DVI:= nvl(trim(B_MA_DVI),null); B_MA_NV:= nvl(trim(B_MA_NV),null); B_PHONG:= nvl(trim(B_PHONG),null); B_TTRANG:= nvl(trim(B_TTRANG),null);
IF B_NGAYD IS NULL OR B_NGAYC IS NULL THEN
    B_LOI:='loi:Nhap ngay bao cao:loi'; RAISE PROGRAM_ERROR;
END IF;
B_NGAYDN:=ROUND(B_NGAYD,-4)+101;B_LOI:='loi:Ma chua dang ky:loi';
DELETE TEMP_1;DELETE TEMP_2;DELETE TEMP_3;DELETE KET_QUA; COMMIT;

PBC_LAY_DVI(B_MADVI,B_MA_DVI,B_NSD,B_PAS,B_LOI);
IF B_LOI IS NOT NULL THEN RAISE PROGRAM_ERROR; END IF;
-- LAM SACH
BC_BH_TKE_TAU_MD(B_LOAI,B_MADVI,B_MA_DVI,B_MA_KH,B_MA_NV,B_PHONG,B_MA_CB,B_NGAYD,B_NGAYC,B_LOI);
--return;
IF B_TTRANG<>'*' THEN B_TTRANG1:=B_TTRANG; END IF;
SELECT COUNT(*) INTO B_I1 FROM TEMP_BC_DVI;
IF B_I1=0 THEN
    INSERT INTO TEMP_2 (C1,C6,C8,C10,N1,N7,N3,C16,N4,N5,C19,C22,C9,C23,C24) SELECT C1,C2,C4,C7,N1,N3,N5,C5,N2,N4,C19,C22,C21,C11,C10
        FROM TEMP_1,BH_HD_GOC WHERE C1=MA_DVI AND N1=SO_ID AND (B_TTRANG1 IS NULL OR TTRANG=B_TTRANG1);
ELSE
    INSERT INTO TEMP_2 (C1,C6,C8,C10,N1,N7,N3,C16,N4,N5,C19,C22,C9,C23,C24) SELECT C1,C2,C4,C7,N1,N3,N5,C5,N2,N4,C19,C22,C21,C11,C10
        FROM TEMP_1,TEMP_BC_DVI,BH_HD_GOC WHERE C1=DVI AND C1=MA_DVI AND N1=SO_ID AND (B_TTRANG1 IS NULL OR TTRANG=B_TTRANG1) ;
END IF;
UPDATE TEMP_2 SET (C5,C7,C11,C12,C13)=(SELECT SO_HD,TEN,PKH_SO_CNG(NGAY_HL),
    PKH_SO_CNG(NGAY_KT),PKH_SO_CNG(NGAY_CAP)
    FROM BH_HD_GOC WHERE MA_DVI=TEMP_2.C1 AND SO_ID=TEMP_2.N1);
UPDATE TEMP_2 SET C18=(SELECT TEN FROM BH_TAU_LOAI WHERE MA_DVI=TEMP_2.C1 AND MA=TEMP_2.C8);
UPDATE TEMP_2 SET (C3)=(SELECT PHONG FROM BH_HD_GOC WHERE MA_DVI=TEMP_2.C1 AND SO_ID=TEMP_2.N1);
UPDATE TEMP_2 SET (C5)=(SELECT SO_HD FROM BH_HD_GOC WHERE MA_DVI=TEMP_2.C1 AND SO_ID=TEMP_2.N1) WHERE C5 IS NULL;
UPDATE TEMP_2 SET C4=(SELECT TEN FROM HT_MA_PHONG WHERE MA_DVI=TEMP_2.C1 AND MA=TEMP_2.C3);
UPDATE TEMP_2 SET C2=(SELECT TEN FROM HT_MA_DVI WHERE MA=TEMP_2.C1);

UPDATE TEMP_2 SET (C15)=(SELECT GCN FROM BH_TAU_ds WHERE MA_DVI=TEMP_2.C1 AND SO_ID=TEMP_2.N1 AND SO_ID_DT=TEMP_2.N7) WHERE C22='TAU';
UPDATE TEMP_2 SET (C15)=(SELECT SO_HD FROM BH_HD_GOC WHERE MA_DVI=TEMP_2.C1 AND SO_ID=TEMP_2.N1 ) WHERE C22='TAUL';
UPDATE TEMP_2 SET (C30)=(SELECT SO_HD FROM BH_HD_GOC WHERE MA_DVI=TEMP_2.C1 AND SO_ID=TEMP_2.N1 ) WHERE C22 IN ('TAUL','TAU');
UPDATE TEMP_2 SET C20=(SELECT MA_KH FROM BH_HD_GOC WHERE MA_DVI=TEMP_2.C1 AND SO_ID=TEMP_2.N1);
UPDATE TEMP_2 SET C21=(SELECT TEN FROM BH_HD_MA_KH WHERE MA_DVI=TEMP_2.C1 AND MA=TEMP_2.C20);
UPDATE TEMP_2 SET C37=(SELECT TEN FROM BH_TAU_NHOM WHERE MA_DVI=C1 AND MA=B_MA_NV);

UPDATE TEMP_2 SET N9=(SELECT MAX(NGAY_TT) FROM BH_HD_GOC_TTPT WHERE MA_DVI=C1 AND SO_ID=N1 AND PT<>'C');
--DQD rao lai
--return;
--UPDATE TEMP_2 SET N10=(SELECT NVL(PT,0) FROM BH_HD_DO_TL WHERE MA_DVI=C1 AND SO_ID=N1 AND KIEU='V');
--UPDATE TEMP_2 SET N11=(SELECT NVL(PT,0) FROM BH_HD_DO_TL WHERE MA_DVI=C1 AND SO_ID=N1 AND KIEU='D' );
--UPDATE TEMP_2 SET C33 =(SELECT NHA_BH FROM BH_HD_DO_TL WHERE MA_DVI=C1 AND SO_ID=N1);
--UPDATE TEMP_2 SET C34 =(SELECT TEN FROM BH_HD_DO_TL A, HT_MA_DVI B WHERE MA_DVI=C29 AND SO_ID=N1
--    AND B.MA=A.NHA_BH AND C33=B.MA AND PTHUC='D');
--UPDATE TEMP_2 SET C35 =(SELECT TEN FROM BH_HD_DO_TL A, TBH_MA_NBH B WHERE A.MA_DVI=C29 AND A.MA_DVI=B.MA_DVI AND SO_ID=N1
--    AND B.MA=A.NHA_BH AND C33=B.MA AND PTHUC='C');
--UPDATE TEMP_2 SET C36 =(SELECT DECODE(PTHUC,'C',C35,C34)||' Ty le '|| PT FROM BH_HD_DO_TL WHERE MA_DVI=C29 AND SO_ID=N1 AND PT<100);
/*
OPEN CS_KQ FOR SELECT C1 MA_DVI,C2 TEN_DVI,C3 PHONG,C4 TEN_PHONG,C30 SO_HD,C15 SO_DON,C6 TEN_TAU,C7 CHU_TAU,
    C18 LOAI_TAU,C9 TT_CS,C10 PHAM_VI,C11 NGAY_HL,C12 NGAY_KT,C19 MA_DK,C16 NAM_SX,N4 MTN,N5 TIEN,C21 TEN_KH,N12 DC_KHAC,
    C14 MUC_KTRU,N2 MTN,N3 PHI,C13 NGAY_CAP,C37 TEN_NHOM,C8||'/'||C16 LT_ND,N9 NGAY_TT,--N10 TYLE_DO_FO,N11 TYLE_DO_LE,C36 GHI_CHU,
    C23 NT_TIEN, C24 NT_PHI FROM TEMP_2 ORDER BY C13, C30, C15;
*/
select json_arrayagg(json_object('STT' value stt,'MA_DVI' value c1,'TEN_DVI' value c2,'PHONG' value c3,'TEN_PHONG' value c4,
'SO_HD' value c30,'SO_DON' value c15,'TEN_TAU' value c6,'CHU_TAU' value c7,'LOAI_TAU' value c18,'TT_CS' value c9,
'PHAM_VI' value c10,'NGAY_HL' value c11,'NGAY_KT' value c12,'MA_DK' value c19,'NAM_SX' value c16,'MTN' value n4,'TIEN' value n5,
'TEN_KH' value c21,'DC_KHAC' value n12,'MUC_KTRU' value c14,'MTN_GOC' value n2,'PHI' value n3,'NGAY_CAP' value c13,
'TEN_NHOM' value c37,'LT_ND' value c8 || '/' || c16,'NGAY_TT' value n9,'TYLE_DO_LE'value n11,'GHI_CHU' value c36,
'NT_TIEN' value c23,'NT_PHI' value c24) order by c13, c30, c15 returning clob)
into dt_ds from (select t.*, row_number() over(order by c13, c30, c15) stt from temp_2 t);
select json_object('dt_ds' value dt_ds returning clob) into b_oraOut from dual;
delete temp_1;delete temp_2;delete ket_qua; commit;
EXCEPTION WHEN OTHERS THEN RAISE_APPLICATION_ERROR(-20105,B_LOI);
END;
/
