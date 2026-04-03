create or replace FUNCTION PKH_NG_QUI(B_NGAY NUMBER) RETURN VARCHAR2
AS
    B_NGAY0 NUMBER;
BEGIN
B_NGAY0:=ROUND(B_NGAY,-4);
IF B_NGAY BETWEEN B_NGAY0+0101 AND B_NGAY0+0399 THEN RETURN '1';
ELSIF B_NGAY BETWEEN B_NGAY0+0401 AND B_NGAY0+0699 THEN RETURN '2';
ELSIF B_NGAY BETWEEN B_NGAY0+0701 AND B_NGAY0+0999 THEN RETURN '3';
ELSIF B_NGAY BETWEEN B_NGAY0+1001 AND B_NGAY0+1299 THEN RETURN '4';
END IF;
END;
/
create or replace procedure PTBH_IN_SOA_TREATY(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number;b_i2 number;b_c1 varchar2(10);
    b_ma_dvi varchar2(10);
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
    b_so_ct varchar2(50) :=FKH_JS_GTRIs(b_oraIn,'so_ct');
    b_kieu varchar2(50) :=FKH_JS_GTRIs(b_oraIn,'kieu');
    b_so_id_xl number;
    dt_ct clob; dt_dk clob;

begin
--b_loi:='loi:So doi '||b_so_id||':loi'; raise PROGRAM_ERROR;
-- Dan - Xem
b_ma_dvi:= b_ma_dviN;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select nvl(so_id_xl,0) into b_so_id_xl from tbh_xl where so_ct=b_so_ct;
select count(*) into b_i1 from tbh_dc_txt where  so_id_dc = b_so_id and loai='dt_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(txt) into dt_ct from tbh_dc_txt where  so_id_dc = b_so_id and loai='dt_ct';
end if;
select JSON_OBJECT('ma_dvi' value t.ma_dvi,'so_id_dc' value b_so_id,'so_ct' value b_so_ct, 'kieu' value b_kieu ,'so_id_xl' value b_so_id_xl

         returning clob) into dt_ct from tbh_dc t
          where  t.so_id_dc=b_so_id ;

select count(*) into b_i1 from tbh_dc_txt where  so_id_dc=b_so_id and loai='dt_dk';
if b_i1<>0 then
    select FKH_JS_BONH(txt) into dt_dk from tbh_dc_txt where so_id_dc=b_so_id and loai='dt_dk';
end if;
 select json_object('so_id' value b_so_id,'kieu' value b_kieu,'dt_ct' value dt_ct,'dt_dk' value dt_dk returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
/ 

create or replace procedure PTBH_IN_SOA_FAC (
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob )
AS
    b_loi varchar2(100); b_i1 number;
    b_ma_dvi varchar2(10) :=FTBH_DVI_TA();
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
    b_kieu varchar2(50) :=SUBSTR(FKH_JS_GTRIs(b_oraIn,'kieu'), 1, INSTR(FKH_JS_GTRIs(b_oraIn,'kieu'), '|') - 1);
    b_nha_bh varchar2(50) ; b_ten_nha_bh nvarchar2(1000):=' ' ; b_dc_nha_bh nvarchar2(1000):=' ' ;
    b_so_id_xl number; b_so_id_ta_ps number;b_so_id_ta_hd number;
    b_ma_dvi_hd varchar2(10); b_so_id_hd number;b_so_id_dt number;
    b_tien_bh number; b_phi_bh number;b_ten_ng_dbh nvarchar2(1000):=' ' ;
    b_nv varchar2(50) ;b_hl_hd_tai varchar2(100) ;b_hl_bh varchar2(100) ;
    b_tien number; b_hhong number;b_pt_ta number; b_pt_hhong number;b_pt_thue number;
    b_lenh varchar2(2000); b_cot varchar2(1000);
    dt_ct clob; dt_dk clob;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete bh_hd_nv_temp;
if b_so_id is null or b_so_id=0 then b_loi:='loi:So doi chieu da xoa:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
select count(*) into b_i1 from tbh_dc_txt where ma_dvi=b_ma_dvi and so_id_dc = b_so_id and loai='dt_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(txt) into dt_ct from tbh_dc_txt where ma_dvi=b_ma_dvi and so_id_dc = b_so_id and loai='dt_ct';
end if;
 b_cot:='nha_bh';
b_lenh:=FKH_JS_LENH(b_cot);
EXECUTE IMMEDIATE b_lenh into b_nha_bh using dt_ct;
b_nha_bh:=nvl(trim(b_nha_bh),' ');
select nvl(trim(ten),' '),nvl(trim(dchi),' ') into b_ten_nha_bh,b_dc_nha_bh from bh_ma_nbh where  ma=b_nha_bh;
select nvl(max(so_id_xl),'0') into b_so_id_xl from tbh_dc_ct where ma_dvi=b_ma_dvi and so_id_dc = b_so_id;
select nvl(max(so_id_ta_ps),'0'),nvl(max(so_id_ta_hd),'0') into b_so_id_ta_ps,b_so_id_ta_hd from tbh_xl_pbo where ma_dvi=b_ma_dvi and so_id_xl=b_so_id_xl;
select nv into b_nv from tbh_xl where ma_dvi=b_ma_dvi and so_id_xl = b_so_id_xl;
--select 'From '||TO_CHAR(pkh_so_cng_date(ngay_bd),'DD Mon YYYY')||' to '||TO_CHAR(pkh_so_cng_date(ngay_kt), 'DD Mon YYYY') into b_hl_hd_tai from tbh_hd_di where so_id=b_so_id_ta_hd;
select sum(tien),sum(hhong) into b_tien,b_hhong from tbh_xl_dc where so_id_dc=b_so_id;
select nvl(pt,0),nvl(pt_hh,0),nvl(tl_thue,0) into b_pt_ta,b_pt_hhong,b_pt_thue from tbh_tm_phi where so_id=b_so_id_ta_ps;
select max(ma_dvi_hd),max(so_id_hd),max(so_id_dt) into b_ma_dvi_hd,b_so_id_hd,b_so_id_dt from tbh_tm_hd where so_id=b_so_id_ta_ps;

/*select nvl(pt,0),nvl(hhong,0),nvl(tien,0) into b_pt_ta,b_pt_hhong,b_pt_thue from tbh_ghep_pbo where so_id=b_so_id_ta_ps and rownum=1;
select max(ma_dvi_hd),max(so_id_hd),max(so_id_dt) into b_ma_dvi_hd,b_so_id_hd,b_so_id_dt from tbh_ghep_hd where so_id=b_so_id_ta_ps;*/

PBH_HD_DS_NV_BANG(b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_loi);
if b_loi is not null then return; end if;
select sum(tien),sum(phi) into b_tien_bh,b_phi_bh from bh_hd_nv_temp;
select TO_CHAR(pkh_so_cng_date(ngay_hl),'DD/Mon/YYYY')||' - '||TO_CHAR(pkh_so_cng_date(ngay_kt), 'DD/Mon/YYYY') into b_hl_bh from bh_hd_goc where so_id=b_so_id_hd;
select nvl(trim(ten),' ') into b_ten_ng_dbh from bh_hd_goc where so_id=b_so_id_hd;

select JSON_OBJECT('ma_dvi' value t.ma_dvi,'so_id_dc' value t.so_id_dc,'ngay_ht' value t.ngay_ht,'kieu' value t.kieu,'nha_bh' value t.nha_bh,
        'so_bk' value t.so_bk,'so_dc' value  t.so_dc,'ngay_dc' value (case when nvl(ng_dc,0)<>0 then TO_CHAR(pkh_so_cng_date(ng_dc),'DD/Mon/YYYY')else ' ' end),'nt_tra' value t.nt_tra,'tra' value t.tra,'tra_qd' value t.tra_qd,nsd,'so_id_tt' value t.so_id_tt
        ,'ten_nha_bh' value b_ten_nha_bh,'dc_nha_bh' value b_dc_nha_bh,'nv' value b_nv,'hl_bh' value b_hl_bh
        ,'tien' value b_tien,'hhong' value b_hhong,'pt_ta' value b_pt_ta,'pt_hhong' value b_pt_hhong,'pt_thue' value b_pt_thue
         ,'tien_bh' value b_tien_bh,'phi_bh' value b_phi_bh,'ten_ng_dbh' value b_ten_ng_dbh

         returning clob) into dt_ct from tbh_dc t
          where t.ma_dvi=b_ma_dvi and t.so_id_dc=b_so_id --and kieu in ('T','B')
          ;
select count(*) into b_i1 from tbh_dc_txt where ma_dvi=b_ma_dvi and so_id_dc=b_so_id and loai='dt_dk';
if b_i1<>0 then
    select FKH_JS_BONH(txt) into dt_dk from tbh_dc_txt where ma_dvi=b_ma_dvi and so_id_dc=b_so_id and loai='dt_dk';
end if;
 select json_object('so_id' value b_so_id,'kieu' value b_kieu,'dt_ct' value dt_ct,'dt_dk' value dt_dk returning clob) into b_oraOut from dual;

COMMIT;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;


/
create or replace procedure PTBH_IN_SOA_SLIP (
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob )
AS
    b_loi varchar2(100); b_i1 number;
    b_ma_dvi varchar2(10) :=FTBH_DVI_TA();
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
    b_kieu varchar2(50) :=FKH_JS_GTRIs(b_oraIn,'kieu');
    b_nha_bh varchar2(50) ; b_ten_nha_bh nvarchar2(1000):=' ' ; b_dc_nha_bh nvarchar2(1000):=' ' ;
    b_so_id_xl number; b_so_id_ta_ps number;b_so_id_ta_hd number;
    b_ma_dvi_hd varchar2(10); b_so_id_hd number;b_so_id_dt number;
    b_ten_dvi nvarchar2(1000):=' ' ;b_ma_kh varchar2(100); b_dchi_kh nvarchar2(1000):=' ' ;b_nd nvarchar2(2000):=' ' ;
    b_tien_bh number; b_phi_bh number;b_ten_ng_dbh nvarchar2(1000):=' ' ;
    b_nv varchar2(50) ;b_hl_hd_tai varchar2(100) ;b_hl_bh varchar2(100) ;
    b_tien number; b_hhong number;b_pt_ta number; b_pt_hhong number;b_pt_thue number;
    b_lenh varchar2(2000); b_cot varchar2(1000);
    dt_ct clob; dt_dk clob;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete bh_hd_nv_temp;
if b_so_id is null or b_so_id=0 then b_loi:='loi:So doi chieu da xoa:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
select count(*) into b_i1 from tbh_dc_txt where ma_dvi=b_ma_dvi and so_id_dc = b_so_id and loai='dt_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(txt) into dt_ct from tbh_dc_txt where ma_dvi=b_ma_dvi and so_id_dc = b_so_id and loai='dt_ct';
end if;
 b_cot:='nha_bh,nd';
b_lenh:=FKH_JS_LENH(b_cot);
EXECUTE IMMEDIATE b_lenh into b_nha_bh,b_nd using dt_ct;
b_nha_bh:=nvl(trim(b_nha_bh),' ');
select nvl(trim(ten),' '),nvl(trim(dchi),' ') into b_ten_nha_bh,b_dc_nha_bh from bh_ma_nbh where  ma=b_nha_bh;
select nvl(max(so_id_xl),'0') into b_so_id_xl from tbh_dc_ct where ma_dvi=b_ma_dvi and so_id_dc = b_so_id;
select nvl(max(so_id_ta_ps),'0'),nvl(max(so_id_ta_hd),'0') into b_so_id_ta_ps,b_so_id_ta_hd from tbh_xl_pbo where ma_dvi=b_ma_dvi and so_id_xl=b_so_id_xl;
select nv into b_nv from tbh_xl where ma_dvi=b_ma_dvi and so_id_xl = b_so_id_xl;
--select 'From '||TO_CHAR(pkh_so_cng_date(ngay_bd),'DD Mon YYYY')||' to '||TO_CHAR(pkh_so_cng_date(ngay_kt), 'DD Mon YYYY') into b_hl_hd_tai from tbh_hd_di where so_id=b_so_id_ta_hd;
select sum(tien),sum(hhong) into b_tien,b_hhong from tbh_xl_dc where so_id_dc=b_so_id;
select nvl(pt,0),nvl(pt_hh,0),nvl(tl_thue,0) into b_pt_ta,b_pt_hhong,b_pt_thue from tbh_tm_phi where so_id=b_so_id_ta_ps;
select max(ma_dvi_hd),max(so_id_hd),max(so_id_dt) into b_ma_dvi_hd,b_so_id_hd,b_so_id_dt from tbh_tm_hd where so_id=b_so_id_ta_ps;
/*
select nvl(pt,0),nvl(hhong,0),nvl(tien,0) into b_pt_ta,b_pt_hhong,b_pt_thue from tbh_ghep_pbo where so_id=b_so_id_ta_ps and rownum=1;
select max(ma_dvi_hd),max(so_id_hd),max(so_id_dt) into b_ma_dvi_hd,b_so_id_hd,b_so_id_dt from tbh_ghep_hd where so_id=b_so_id_ta_ps;*/
PBH_HD_DS_NV_BANG(b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_loi);
if b_loi is not null then return; end if;
select sum(tien),sum(phi) into b_tien_bh,b_phi_bh from bh_hd_nv_temp;
select TO_CHAR(pkh_so_cng_date(ngay_hl),'DD/Mon/YYYY')||' - '||TO_CHAR(pkh_so_cng_date(ngay_kt), 'DD/Mon/YYYY') into b_hl_bh from bh_hd_goc where so_id=b_so_id_hd;
select nvl(trim(ten),' '),nvl(trim(ma_kh),' ') into b_ten_ng_dbh,b_ma_kh from bh_hd_goc where so_id=b_so_id_hd;
select nvl(trim(ten),' ') into b_ten_dvi from ht_ma_dvi where ma=b_ma_dvi_hd;
select nvl(trim(dchi),' ') into b_dchi_kh from bh_hd_ma_kh where ma=b_ma_kh;

select JSON_OBJECT('ma_dvi' value t.ma_dvi,'so_id_dc' value t.so_id_dc,'ngay_ht' value t.ngay_ht,'kieu' value t.kieu,'nha_bh' value t.nha_bh,'nd' value b_nd,
        'so_bk' value t.so_bk,'so_dc' value  t.so_dc,'ngay_dc' value (case when nvl(ng_dc,0)<>0 then TO_CHAR(pkh_so_cng_date(ng_dc),'DD/Mon/YYYY')else ' ' end),'nt_tra' value t.nt_tra,'tra' value t.tra,'tra_qd' value t.tra_qd,nsd,'so_id_tt' value t.so_id_tt
        ,'ten_nha_bh' value b_ten_nha_bh,'dc_nha_bh' value b_dc_nha_bh,'nv' value b_nv,'hl_bh' value b_hl_bh
        ,'tien' value b_tien,'hhong' value b_hhong,'pt_ta' value b_pt_ta,'pt_hhong' value b_pt_hhong,'pt_thue' value b_pt_thue
         ,'tien_bh' value b_tien_bh,'phi_bh' value b_phi_bh,'ten_ng_dbh' value b_ten_ng_dbh,'ten_dvi' value b_ten_dvi,'dchi_kh' value b_dchi_kh

         returning clob) into dt_ct from tbh_dc t
          where t.ma_dvi=b_ma_dvi and t.so_id_dc=b_so_id --and kieu in ('T','B')
          ;
select count(*) into b_i1 from tbh_dc_txt where ma_dvi=b_ma_dvi and so_id_dc=b_so_id and loai='dt_dk';
if b_i1<>0 then
    select FKH_JS_BONH(txt) into dt_dk from tbh_dc_txt where ma_dvi=b_ma_dvi and so_id_dc=b_so_id and loai='dt_dk';
end if;
 select json_object('so_id' value b_so_id,'kieu' value b_kieu,'dt_ct' value dt_ct,'dt_dk' value dt_dk returning clob) into b_oraOut from dual;

COMMIT;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;

/
/*
PROCEDURE PTBH_DC_IN1
    (B_MA_DVI VARCHAR2,B_NSD VARCHAR2,B_PAS VARCHAR2,B_SO_ID_DC NUMBER,B_SO_ID_XL NUMBER,CS1 OUT PHT_TYPE.CS_TYPE)
AS
    B_LOI VARCHAR2(100); B_KIEU VARCHAR2(1); B_ND NVARCHAR2(400); B_SO_HD VARCHAR2(30);B_TEN_DT NVARCHAR2(100);
    B_SO_ID_HD NUMBER:=0; B_SO_ID_DT NUMBER:=0; B_SO_ID_PS NUMBER:=0;
BEGIN

DELETE TEMP_1;
B_LOI:=FHT_MA_NSD_KTRA(B_MA_DVI,B_NSD,B_PAS,'BH','TA','NX');
IF B_LOI IS NOT NULL THEN RAISE PROGRAM_ERROR; END IF;

INSERT INTO TEMP_1(C1,N1,N2,C2,C3,C4,C8,C9,C7)
    SELECT MA_DVI,SO_ID_DC,NGAY_HT,NHA_BH,SO_BK,SO_DC,KIEU,NT_TRA,ND
    FROM TBH_DC WHERE MA_DVI=B_MA_DVI AND SO_ID_DC=B_SO_ID_DC;

UPDATE TEMP_1 SET (C5,C6)=(SELECT TEN,DCHI FROM TBH_MA_NBH WHERE MA_DVI=C1 AND MA=C2);
UPDATE TEMP_1 SET (N3,N4,N5,N6)=(SELECT SUM(TIEN),SUM(HHONG),SUM(TRA), MAX(SO_ID_XL) FROM TBH_XL_DC
    WHERE MA_DVI=B_MA_DVI AND SO_ID_DC=B_SO_ID_DC);
UPDATE TEMP_1 SET C10=(SELECT GOC FROM TBH_PS A, TBH_XL_CT B WHERE A.SO_ID=B.SO_ID_PS AND B.SO_ID_XL=B_SO_ID_XL);

UPDATE TEMP_1 SET N7=N5,C11=C9 WHERE C10 IN('HD_PS');

UPDATE TEMP_1 SET N8=N5,C12=C9 WHERE C10 IN('BT_GD','BT_HS','HD_HU');

SELECT MIN(NVL(SO_ID_PS,0)) INTO B_SO_ID_PS FROM TBH_XL_PBO WHERE MA_DVI=B_MA_DVI  AND SO_ID_XL=B_SO_ID_XL;

IF B_SO_ID_PS=0 OR B_SO_ID_PS IS NULL THEN B_LOI:='loi: Chua co phat sinh :loi'; RAISE PROGRAM_ERROR; END IF;
SELECT KIEU INTO B_KIEU FROM TBH_DC WHERE MA_DVI=B_MA_DVI AND SO_ID_DC=B_SO_ID_DC;

IF B_KIEU IN ('C','D') THEN
    FOR R_LP IN(SELECT SO_ID_HD,SO_ID_DT FROM TBH_GHEP_HD WHERE  MA_DVI_HD=B_MA_DVI AND SO_ID=B_SO_ID_PS) LOOP
        SELECT SO_HD INTO B_SO_HD FROM BH_HD_GOC WHERE MA_DVI=B_MA_DVI AND SO_ID=R_LP.SO_ID_HD;
        B_TEN_DT:= FBH_HD_TEN_DT(B_MA_DVI,R_LP.SO_ID_HD,R_LP.SO_ID_DT);
        B_ND:= B_SO_HD ||'-'|| B_TEN_DT;
    END LOOP;
ELSIF B_KIEU='T' THEN
    SELECT MIN(NVL(SO_ID_HD,0)), MIN(NVL(SO_ID_DT,0)) INTO B_SO_ID_HD, B_SO_ID_DT FROM TBH_TM_HD
        WHERE MA_DVI_HD=B_MA_DVI AND SO_ID=B_SO_ID_PS;
END IF;


OPEN CS1 FOR SELECT N1 SO_ID_DC,N2 NGAY,C2 NHA_BH,C3 SO_BK,C4 SO_DC,C5 TEN,C6 DCHI,N3 TIEN,N4 HHONG,
    N7 TIEN_THU,C11 MA_THU, N8 TIEN_TRA,C12 MA_TRA,C7 ND,C8 KIEU FROM TEMP_1;
EXCEPTION WHEN OTHERS THEN RAISE_APPLICATION_ERROR(-20105,B_LOI);
END;
/

PROCEDURE PTBH_DC_IN_FSS
    (B_MA_DVI VARCHAR2,B_NSD VARCHAR2,B_PAS VARCHAR2,B_SO_ID_DC NUMBER,B_SO_ID_XL NUMBER,B_NV VARCHAR2,
        B_LH_NV VARCHAR2,B_KIEU VARCHAR2,CS1 OUT PHT_TYPE.CS_TYPE)
AS
    B_I1 NUMBER:=0; B_LOI VARCHAR2(100); B_ND NVARCHAR2(400); B_SO_HD VARCHAR2(30);B_MA_TA VARCHAR2(30);
    B_LOAI_DN VARCHAR2(10); B_NHA_BH VARCHAR2(10); B_QUI VARCHAR2(1); B_MA_NT VARCHAR2(5);
    B_SO_ID_HD NUMBER:=0; B_SO_ID_DT NUMBER:=0; B_SO_ID_PS NUMBER:=0; B_SO_ID_TA_HD NUMBER:=0; B_NGAY_HT NUMBER:=0; B_NAM NUMBER:=0;
    B_MAX_C2 VARCHAR2(10);
BEGIN

DELETE TEMP_1;DELETE TEMP_2; DELETE TEMP_3;
B_LOI:=FHT_MA_NSD_KTRA(B_MA_DVI,B_NSD,B_PAS,'BH','TA','NX');
IF B_LOI IS NOT NULL THEN RAISE PROGRAM_ERROR; END IF;

SELECT NHA_BH INTO B_NHA_BH FROM TBH_DC WHERE MA_DVI=B_MA_DVI AND SO_ID_DC=B_SO_ID_DC;
INSERT INTO TEMP_1(C1,N1,N2,C2,C3,C4,C8,C9,C20) SELECT MA_DVI,SO_ID_DC,NGAY_HT,NHA_BH,SO_BK,SO_DC,KIEU,NT_TRA,ND
    FROM TBH_DC WHERE MA_DVI=B_MA_DVI AND SO_ID_DC=B_SO_ID_DC;
UPDATE TEMP_1 SET (C5,C6,C17)=(SELECT TEN,DCHI,TEN_E FROM TBH_MA_NBH WHERE MA_DVI=C1 AND MA=C2);
SELECT LOAI INTO B_LOAI_DN FROM TBH_MA_NBH WHERE MA_DVI=B_MA_DVI AND MA=B_NHA_BH;
SELECT MIN(NVL(SO_ID_TA_PS,0)),MIN(NVL(SO_ID_TA_HD,0)),MIN(NVL(NGAY_HT,0)),MIN(MA_TA) INTO B_SO_ID_PS,B_SO_ID_TA_HD,B_NGAY_HT,B_MA_TA
    FROM TBH_XL_PBO WHERE MA_DVI=B_MA_DVI AND SO_ID_XL=B_SO_ID_XL AND KIEU=B_KIEU AND NHA_BH=B_NHA_BH;
IF B_SO_ID_PS=0 OR B_SO_ID_PS IS NULL THEN B_LOI:='loi: Chua co xu ly cho nghiep vu'||B_NV||' :loi'; RAISE PROGRAM_ERROR; END IF;

IF B_KIEU='C' OR B_KIEU='D' THEN
    INSERT INTO TEMP_3(C1,N1,C2,N2,C3,N4) SELECT B.MA_DVI,B.SO_ID,B.NT_PHI,SUM(B.PHI_DT),A.MA_DVI,FTBH_VE_SO_ID_BS(B_MA_DVI,A.SO_ID,B_NGAY_HT) FROM TBH_GHEP_HD A, BH_HD_GOC_DK B
        WHERE A.MA_DVI=B_MA_DVI AND A.SO_ID=B_SO_ID_PS AND A.SO_ID_HD=B.SO_ID AND A.MA_DVI_HD=B.MA_DVI
        GROUP BY B.MA_DVI,B.SO_ID,B.NT_PHI,A.MA_DVI,A.SO_ID;
ELSIF B_KIEU='T' OR B_KIEU='B' THEN
    INSERT INTO TEMP_3(C1,N1,C2,N2,C3,N4) SELECT B.MA_DVI,B.SO_ID,B.NT_PHI,SUM(B.PHI_DT),A.MA_DVI,FTBH_VE_SO_ID_BS(B_MA_DVI,A.SO_ID,B_NGAY_HT) FROM TBH_TM_HD A, BH_HD_GOC_DK B
        WHERE A.MA_DVI=B_MA_DVI AND A.SO_ID=B_SO_ID_PS AND A.SO_ID_HD=B.SO_ID AND A.MA_DVI_HD=B.MA_DVI
        GROUP BY B.MA_DVI,B.SO_ID,B.NT_PHI,A.MA_DVI,A.SO_ID;
ELSIF B_KIEU='V' OR B_KIEU='N' THEN
    INSERT INTO TEMP_3(C1,N1,C2,N2,C3,N4) SELECT B.MA_DVI,B.SO_ID,B.NT_PHI,SUM(B.PHI_DT),A.MA_DVI,FTBH_VE_SO_ID_BS(B_MA_DVI,A.SO_ID,B_NGAY_HT) FROM TBH_VE_HD A, BH_HD_GOC_DK B
        WHERE A.MA_DVI=B_MA_DVI AND A.SO_ID=B_SO_ID_PS AND A.SO_ID_HD=B.SO_ID AND A.MA_DVI_HD=B.MA_DVI
        GROUP BY B.MA_DVI,B.SO_ID,B.NT_PHI,A.MA_DVI,A.SO_ID;
END IF;
B_QUI:=PKH_NG_QUI(B_NGAY_HT);
B_NAM:=ROUND(B_NGAY_HT,-4)/10000;

IF  B_KIEU='C' OR B_KIEU='D' THEN
    INSERT INTO TEMP_2(C1,C2,N1,N2,N3,N5,N6)
        SELECT A.MA_DVI,SO_HD,A.SO_ID,NGAY_BD,NGAY_KT,PT,HH FROM TBH_HD_DI A,TBH_HD_DI_NHA_BH B
            WHERE A.MA_DVI=B_MA_DVI AND A.MA_DVI=B.MA_DVI AND A.SO_ID=B.SO_ID AND (B_NV IS NULL OR NV=B_NV) AND NHA_BH=B_NHA_BH;
    UPDATE TEMP_1 SET (C7,N21,N22,N5,N6)=(SELECT C2,N2,N3,N5,N6 FROM TEMP_2 A
        WHERE A.C1=B_MA_DVI AND A.N1=B_SO_ID_TA_HD);
ELSIF B_KIEU='T' OR B_KIEU='B' THEN
    INSERT INTO TEMP_2(C1,N1,N5,N6) SELECT MA_DVI,SO_ID,SUM(PT),SUM(PT_HH) FROM TBH_TM_PHI
            WHERE MA_DVI=B_MA_DVI AND SO_ID=B_SO_ID_PS AND NHA_BH=B_NHA_BH GROUP BY MA_DVI,SO_ID;
    UPDATE TEMP_1 SET (N5,N6)=(SELECT N5,N6 FROM TEMP_2 A
        WHERE A.C1=B_MA_DVI AND A.N1=B_SO_ID_PS);
ELSIF B_KIEU='V' OR B_KIEU='N' THEN
    INSERT INTO TEMP_2(C1,N1,N5,N6) SELECT MA_DVI,SO_ID,SUM(PT),SUM(PT_HH) FROM TBH_VE_PHI
            WHERE MA_DVI=B_MA_DVI AND SO_ID=B_SO_ID_PS AND NHA_BH=B_NHA_BH GROUP BY MA_DVI,SO_ID;
    UPDATE TEMP_1 SET (N5,N6)=(SELECT N5,N6 FROM TEMP_2 A
        WHERE A.C1=B_MA_DVI AND A.N1=B_SO_ID_PS);
END IF;

UPDATE TEMP_1 SET (N3)=(SELECT SUM(FTT_TUNG_QD(A.MA_DVI,B_NGAY_HT,A.MA_NT,A.TIEN,B.C2)) FROM TBH_XL_PBO A,TEMP_3 B
    WHERE A.MA_DVI=B_MA_DVI AND A.MA_DVI=B.C3 AND A.MA_DVI_PS=B.C1 AND A.SO_ID_TA_PS=B.N4 AND SO_ID_XL=B_SO_ID_XL
        AND GOC='HD_HU' AND KIEU=B_KIEU AND (B_NV IS NULL OR NV=B_NV) GROUP BY MA_NT);

UPDATE TEMP_1 SET (N19)=(SELECT SUM(FTT_TUNG_QD(A.MA_DVI,B_NGAY_HT,A.MA_NT,A.TIEN,B.C2)) FROM TBH_XL_PBO A,TEMP_3 B
    WHERE A.MA_DVI=B_MA_DVI AND A.MA_DVI=B.C3 AND A.MA_DVI_PS=B.C1 AND A.SO_ID_TA_PS=B.N4 AND SO_ID_XL=B_SO_ID_XL
        AND GOC='BT_HS' AND KIEU=B_KIEU AND (B_NV IS NULL OR NV=B_NV) GROUP BY MA_NT);

UPDATE TEMP_1 SET (N20)=(SELECT SUM(FTT_TUNG_QD(A.MA_DVI,B_NGAY_HT,A.MA_NT,A.TIEN,B.C2)) FROM TBH_XL_PBO A,TEMP_3 B
    WHERE A.MA_DVI=B_MA_DVI AND A.MA_DVI=B.C3 AND A.MA_DVI_PS=B.C1 AND A.SO_ID_TA_PS=B.N4 AND SO_ID_XL=B_SO_ID_XL
        AND GOC='BT_GD' AND KIEU=B_KIEU AND (B_NV IS NULL OR NV=B_NV) GROUP BY MA_NT);


UPDATE TEMP_1 SET (N13,N14,N15)=(SELECT SUM(FTT_TUNG_QD(A.MA_DVI,B_NGAY_HT,A.MA_NT,A.TIEN,B.C2)),SUM(FTT_TUNG_QD(A.MA_DVI,B_NGAY_HT,A.MA_NT,A.THUE,B.C2)),
    SUM(FTT_TUNG_QD(A.MA_DVI,B_NGAY_HT,A.MA_NT,A.HHONG,B.C2)) FROM TBH_XL_PBO A,TEMP_3 B
    WHERE A.MA_DVI=B_MA_DVI AND A.MA_DVI=B.C3 AND A.MA_DVI_PS=B.C1 AND A.SO_ID_TA_PS=B.N4 AND SO_ID_XL=B_SO_ID_XL
        AND GOC='HD_HU' AND KIEU=B_KIEU AND (B_NV IS NULL OR NV=B_NV) AND NHA_BH=B_NHA_BH GROUP BY MA_NT);

UPDATE TEMP_1 SET (N16)=(SELECT SUM(FTT_TUNG_QD(A.MA_DVI,B_NGAY_HT,A.MA_NT,A.TIEN,B.C2)) FROM TBH_XL_PBO A,TEMP_3 B
    WHERE A.MA_DVI=B_MA_DVI AND A.MA_DVI=B.C3 AND A.MA_DVI_PS=B.C1 AND A.SO_ID_TA_PS=B.N4 AND SO_ID_XL=B_SO_ID_XL
        AND GOC='BT_HS' AND KIEU=B_KIEU AND (B_NV IS NULL OR NV=B_NV) AND NHA_BH=B_NHA_BH GROUP BY MA_NT,GOC);
IF B_KIEU='C' OR B_KIEU='D' THEN

     UPDATE TEMP_1 SET (N9,N10,N30)=(SELECT SUM(FTT_TUNG_QD(MA_DVI,B_NGAY_HT,NT_TRA,TIEN,C9)),
        SUM(FTT_TUNG_QD(MA_DVI,B_NGAY_HT,NT_TRA,HHONG,C9)),SUM(FTT_TUNG_QD(MA_DVI,B_NGAY_HT,NT_TRA,THUE,C9))
        FROM TBH_XL_DC WHERE MA_DVI=B_MA_DVI AND SO_ID_XL=B_SO_ID_XL AND SO_ID_DC=B_SO_ID_DC AND NHA_BH=B_NHA_BH
            AND KIEU=B_KIEU GROUP BY MA_DVI,NT_TRA);

     UPDATE TEMP_1 SET (N7,N8,N23,C10,C13)=(SELECT SUM(FTT_TUNG_QD(A.MA_DVI_HD,B_NGAY_HT,NT_PHI,PHI_DT,C9)),
        SUM(FTT_TUNG_QD(A.MA_DVI_HD,B_NGAY_HT,NT_TIEN,TIEN,C9)),
        A.SO_ID_HD,A.MA_DVI_HD,max(B.LH_NV) FROM TBH_GHEP_HD A,BH_HD_GOC_DK B
        WHERE A.MA_DVI=B_MA_DVI AND A.SO_ID_HD=B.SO_ID AND A.MA_DVI_HD=B.MA_DVI AND A.SO_ID=B_SO_ID_PS
            AND (B_LH_NV IS NULL OR B.LH_NV LIKE B_LH_NV||'%') GROUP BY B.NT_PHI,A.SO_ID_HD,A.MA_DVI_HD,C9);

ELSIF B_KIEU='T' OR B_KIEU='B' THEN

     UPDATE TEMP_1 SET (N9,N10,N30)=(SELECT SUM(FTT_TUNG_QD(MA_DVI,B_NGAY_HT,NT_TRA,TIEN,C9)),
        SUM(FTT_TUNG_QD(MA_DVI,B_NGAY_HT,NT_TRA,HHONG,C9)),SUM(FTT_TUNG_QD(MA_DVI,B_NGAY_HT,NT_TRA,THUE,C9))
        FROM TBH_XL_DC WHERE MA_DVI=B_MA_DVI AND SO_ID_XL=B_SO_ID_XL AND SO_ID_DC=B_SO_ID_DC AND NHA_BH=B_NHA_BH
            AND KIEU=B_KIEU GROUP BY MA_DVI,NT_TRA);

     UPDATE TEMP_1 SET (N7,N8,N23,C10,C13)=(SELECT SUM(FTT_TUNG_QD(A.MA_DVI_HD,B_NGAY_HT,NT_PHI,PHI_DT,C9)),
        SUM(FTT_TUNG_QD(A.MA_DVI_HD,B_NGAY_HT,NT_TIEN,TIEN,C9)),
        A.SO_ID_HD,A.MA_DVI_HD,'' FROM TBH_TM_HD A,BH_HD_GOC_DK B
        WHERE A.MA_DVI=B_MA_DVI AND A.SO_ID_HD=B.SO_ID AND A.MA_DVI_HD=B.MA_DVI AND A.SO_ID=B_SO_ID_PS
            AND (B_LH_NV IS NULL OR B.LH_NV LIKE B_LH_NV||'%') GROUP BY B.NT_PHI,A.SO_ID_HD,A.MA_DVI_HD,C9);

ELSIF B_KIEU='V' OR B_KIEU='N' THEN

     UPDATE TEMP_1 SET (N9,N10,N30)=(SELECT SUM(FTT_TUNG_QD(MA_DVI,B_NGAY_HT,NT_TRA,TIEN,C9)),
        SUM(FTT_TUNG_QD(MA_DVI,B_NGAY_HT,NT_TRA,HHONG,C9)),SUM(FTT_TUNG_QD(MA_DVI,B_NGAY_HT,NT_TRA,THUE,C9))
        FROM TBH_XL_DC WHERE MA_DVI=B_MA_DVI AND SO_ID_XL=B_SO_ID_XL AND SO_ID_DC=B_SO_ID_DC AND NHA_BH=B_NHA_BH
            AND KIEU=B_KIEU GROUP BY MA_DVI,NT_TRA);

     UPDATE TEMP_1 SET (N7,N8,N23,C10,C13)=(SELECT SUM(FTT_TUNG_QD(A.MA_DVI_HD,B_NGAY_HT,NT_PHI,PHI_DT,C9)),
        SUM(FTT_TUNG_QD(A.MA_DVI_HD,B_NGAY_HT,NT_TIEN,TIEN,C9)),
        A.SO_ID_HD,A.MA_DVI_HD,'' FROM TBH_VE_HD A,BH_HD_GOC_DK B
        WHERE A.MA_DVI=B_MA_DVI AND A.SO_ID_HD=B.SO_ID AND A.MA_DVI_HD=B.MA_DVI AND A.SO_ID=B_SO_ID_PS
            AND FBH_MA_LHNV_TAI(B_MA_DVI,B.LH_NV)=B_MA_TA AND (B_LH_NV IS NULL OR B.LH_NV LIKE B_LH_NV||'%') GROUP BY B.NT_PHI,A.SO_ID_HD,A.MA_DVI_HD,C9);
END IF;
UPDATE TEMP_1 SET (C11,C12,D1,D2)=(SELECT SO_HD,TEN,NGAY_HL,NGAY_KT FROM BH_HD_GOC WHERE N23=SO_ID AND C10=MA_DVI);
UPDATE TEMP_1 SET C14=(SELECT TEN FROM BH_MA_LHNV WHERE MA=C13 AND C10=MA_DVI);
 
IF B_KIEU IN ('C','T') THEN
   UPDATE TEMP_1 SET N28=0,N11=NVL(N9,0),N29=0,N12=NVL(N10,0),N31=0,N32=NVL(N30,0),N33=NVL(N13,0),N34=0,N36=0,N35=NVL(N14,0),N38=0,N37=NVL(N15,0),N17=NVL(N16,0),N18=0;
ELSE UPDATE TEMP_1 SET N28=NVL(N9,0),N11=0,N29=NVL(N10,0),N12=0,N31=NVL(N30,0),N32=0,N33=0,N34=NVL(N13,0),N36=NVL(N14,0),N35=0,N38=NVL(N15,0),N37=0,N17=0,N18=NVL(N16,0);
END IF;

UPDATE TEMP_1 SET N39=N28+N12+N17+N31+N34+N37+N36;
UPDATE TEMP_1 SET C18=LTRIM(TO_CHAR(N39,'999,999,999,999,999,999,999.99'));

UPDATE TEMP_1 SET N40=N11+N29+N18+N32+N33+N38+N35;
UPDATE TEMP_1 SET C19=LTRIM(TO_CHAR(N40,'999,999,999,999,999,999,999.99'));

IF B_LOAI_DN='N' THEN
    UPDATE TEMP_1 SET N4=(NVL(N7,0)*0.1)/100;
END IF;

UPDATE TEMP_1 SET N23=(SELECT SUM(TIEN) FROM TBH_PS WHERE MA_DVI=B_MA_DVI AND KIEU=B_KIEU AND SO_ID_TA_PS=B_SO_ID_PS);
UPDATE TEMP_1 SET N24=ROUND(NVL(N11,0)/NVL(N23,0)*100,2) WHERE NVL(N11,0)>0 and NVL(N23,0)>0;
UPDATE TEMP_1 SET N24=ROUND(NVL(N28,0)/NVL(N23,0)*100,2) WHERE NVL(N28,0)>0  and NVL(N23,0)>0;

UPDATE TEMP_1 SET N39=N39-N40,N40=0 WHERE N39>N40;
UPDATE TEMP_1 SET N40=N40-N39, N39=0 WHERE N40>N39;

UPDATE TEMP_1 SET N25=NVL(N25,0),N26=NVL(N26,0),N27=NVL(N27,0);

OPEN CS1 FOR SELECT N1 SO_ID_DC,N2 NGAY,C2 NHA_BH,C3 SO_BK,C4 SO_DC,C5 TEN,C6 DCHI,C11 SO_HD,C12 TEN_KH,C14 LH_NV,
    N3 PHI_HT,N4 THUE_NT,N5 PT,N6 HH,N9 PHI_TA, N10 HH_TA,C20 ND,NVL(N24,0) KY_TT,
    LTRIM(TO_CHAR(N19,'999,999,999,999,999,999,999.99')) PHI_BT,LTRIM(TO_CHAR(N20,'999,999,999,999,999,999,999.99')) PHI_GD,
    LTRIM(TO_CHAR(N7,'999,999,999,999,999,999,999.99')) PHI_BH,LTRIM(TO_CHAR(N8,'999,999,999,999,999,999,999.99')) TIEN_BH,
    LTRIM(TO_CHAR(N11,'999,999,999,999,999,999,999.99')) PHI_TA_D,LTRIM(TO_CHAR(N28,'999,999,999,999,999,999,999.99')) PHI_TA_V,
    LTRIM(TO_CHAR(N12,'999,999,999,999,999,999,999.99')) HH_TA_D,LTRIM(TO_CHAR(N29,'999,999,999,999,999,999,999.99')) HH_TA_V,
    LTRIM(TO_CHAR(N32,'999,999,999,999,999,999,999.99')) THUE_TA_D,LTRIM(TO_CHAR(N31,'999,999,999,999,999,999,999.99')) THUE_TA_V,
    LTRIM(TO_CHAR(N33,'999,999,999,999,999,999,999.99')) PHI_TA_HT_D,LTRIM(TO_CHAR(N34,'999,999,999,999,999,999,999.99')) PHI_TA_HT_V,
    LTRIM(TO_CHAR(N35,'999,999,999,999,999,999,999.99')) THUE_TA_HT_D,LTRIM(TO_CHAR(N36,'999,999,999,999,999,999,999.99')) THUE_TA_HT_V,
    LTRIM(TO_CHAR(N37,'999,999,999,999,999,999,999.99')) HH_TA_HT_D,LTRIM(TO_CHAR(N38,'999,999,999,999,999,999,999.99')) HH_TA_HT_V,
    LTRIM(TO_CHAR(N17,'999,999,999,999,999,999,999.99')) BT_TA_D,LTRIM(TO_CHAR(N18,'999,999,999,999,999,999,999.99')) BT_TA_V,
    LTRIM(TO_CHAR(N22,'999,999,999,999,999,999,999.99')) THU_KH_V,LTRIM(TO_CHAR(N25,'999,999,999,999,999,999,999.99')) THU_KH_D,
    LTRIM(TO_CHAR(N26,'999,999,999,999,999,999,999.99')) CHI_KH_V,LTRIM(TO_CHAR(N27,'999,999,999,999,999,999,999.99')) CHI_KH_D,
    LTRIM(TO_CHAR(N39,'999,999,999,999,999,999,999.99')) D_THU,LTRIM(TO_CHAR(N40,'999,999,999,999,999,999,999.99')) C_TRA,

    TO_CHAR(D1,'dd/mm/yyyy') NGAY_BD,TO_CHAR(D2,'dd/mm/yyyy') NGAY_KT,
    C18 T_THU,C19 T_TRA,C7 SO_HD_TA,C8 KIEU,C9 MA_NT,B_QUI QUI,B_NAM NAM,C17 TEN_E,B_NGAY_HT NGAY_XL
    FROM TEMP_1;
--EXCEPTION WHEN OTHERS THEN RAISE_APPLICATION_ERROR(-20105,B_LOI);
END;*/
/

CREATE OR REPLACE PROCEDURE PTBH_DC_INHD_D
    (B_MA_DVI VARCHAR2,B_NSD VARCHAR2,B_PAS VARCHAR2,B_ORAIN CLOB,B_ORAOUT OUT CLOB)
AS
  B_SO_ID_DC NUMBER:=FKH_JS_GTRIN(B_ORAIN,'so_id_dc');
  B_SO_ID_XL NUMBER:=FKH_JS_GTRIN(B_ORAIN,'so_id_xl');
  B_NV VARCHAR2(20):=FKH_JS_GTRIS(B_ORAIN,'nv');
    B_LH_NV VARCHAR2(20):=FKH_JS_GTRIS(B_ORAIN,'lh_nv');
  B_KIEU NVARCHAR2(500):=FKH_JS_GTRIS(B_ORAIN,'kieu');

    B_I1 NUMBER:=0; B_LOI VARCHAR2(100); B_ND NVARCHAR2(400); B_NV_TA NVARCHAR2(400);B_SO_HD VARCHAR2(30);
  B_NHA_BH VARCHAR2(50); B_MA_NT VARCHAR2(50);B_QUI VARCHAR2(1);
    B_SO_ID_HD NUMBER:=0; B_SO_ID_DT NUMBER:=0; B_SO_ID_PS NUMBER:=0; B_SO_ID_TA_HD NUMBER:=0; B_NGAY_HT NUMBER:=0;
  B_NAM NUMBER:=0;
    B_TL_THUE NUMBER; B_THUE_USD NUMBER; B_THUE_VND NUMBER; B_TP_P NUMBER:=2;
    B_TENP NVARCHAR2(2000);

  B_DT CLOB;
BEGIN


DELETE TEMP_1;DELETE TEMP_2; DELETE TEMP_3;

SELECT NHA_BH,NT_TRA INTO B_NHA_BH,B_MA_NT FROM TBH_DC WHERE SO_ID_DC=B_SO_ID_DC;
IF B_MA_NT='VND' THEN B_TP_P:=0; END IF;

INSERT INTO TEMP_1(C1,N1,N2,C2,C3,C4,C8,C9,C15)
    SELECT MA_DVI,SO_ID_DC,NGAY_HT,NHA_BH,SO_BK,SO_DC,KIEU,NT_TRA,'' ND
    FROM TBH_DC WHERE SO_ID_DC=B_SO_ID_DC;
UPDATE TEMP_1 SET (C5,C6)=(SELECT TEN,DCHI FROM BH_MA_NBH WHERE MA_DVI=C1 AND MA=C2);
SELECT MIN(NVL(SO_ID_TA_PS,0)),MIN(NVL(SO_ID_TA_HD,0)),MIN(NVL(NGAY_HT,0)),MIN(NVL(NV,'')) INTO B_SO_ID_PS,B_SO_ID_TA_HD,B_NGAY_HT,B_NV_TA
    FROM TBH_XL_PBO WHERE SO_ID_XL=B_SO_ID_XL AND (B_NV IS NULL OR NV=B_NV) AND KIEU=B_KIEU;
IF B_SO_ID_PS=0 OR B_SO_ID_PS IS NULL THEN B_LOI:='LOI: CHUA CO XU LY CHO NGHIEP VU'||B_NV||' :LOI'; RAISE PROGRAM_ERROR; END IF;

IF B_LH_NV='HH' THEN
    IF B_KIEU IN ('C','D') THEN
        INSERT INTO TEMP_3(C1,N1,C2,N2) SELECT B.MA_DVI,B.SO_ID,B.NT_PHI,B.TTOAN FROM TBH_GHEP_HD A, BH_HD_GOC_DK B WHERE  A.SO_ID=B_SO_ID_PS
            AND A.SO_ID_HD=B.SO_ID AND A.MA_DVI_HD=B.MA_DVI AND B.LH_NV LIKE B_LH_NV||'%';
    ELSIF B_KIEU IN ('T','B') THEN
        INSERT INTO TEMP_3(C1,N1,C2,N2) SELECT B.MA_DVI,B.SO_ID,B.NT_PHI,B.TTOAN FROM TBH_TM_HD A, BH_HD_GOC_DK B WHERE  A.SO_ID=B_SO_ID_PS
            AND A.SO_ID_HD=B.SO_ID AND  B.LH_NV LIKE B_LH_NV||'%';
    END IF;
SELECT COUNT(*) INTO B_I1 FROM TEMP_3;
IF B_I1=0 OR B_I1 IS NULL THEN B_LOI:='LOI: CHUA CO XU LY LOAI HINH NGHIEP VU HON HOP:LOI'; RAISE PROGRAM_ERROR; END IF;
END IF;

B_QUI:=PKH_NG_QUI(B_NGAY_HT);
B_NAM:=ROUND(B_NGAY_HT,-4)/10000;


INSERT INTO TEMP_2(C1,C2,N1,N2,N3,N5,N6)
    SELECT DISTINCT A.MA_DVI,SO_HD,A.SO_ID,NGAY_BD,NGAY_KT,PT,HH FROM TBH_HD_DI A,TBH_HD_DI_NHA_BH B
        WHERE  A.MA_DVI=B.MA_DVI AND A.SO_ID=B.SO_ID AND (B_NV IS NULL OR NV=B_NV) AND A.SO_ID=B_SO_ID_TA_HD;-- AND NHA_BH=B_NHA_BH;
UPDATE TEMP_1 SET (C7,N21,N22,N5,N6)=(SELECT MAX(C2),MAX(N2),MAX(N3),MAX(N5),MAX(N6) FROM TEMP_2 A
    WHERE A.N1=B_SO_ID_TA_HD);

UPDATE TEMP_1 SET (N3,N4)=(SELECT DECODE(TRIM(MA_NT),'USD',SUM(TIEN),0),DECODE(TRIM(MA_NT),'VND',SUM(TIEN),0) FROM TBH_XL_PBO
    WHERE  SO_ID_XL=B_SO_ID_XL AND GOC='HD_HU' AND KIEU=B_KIEU AND (B_NV IS NULL OR NV=B_NV) GROUP BY MA_NT);

UPDATE TEMP_1 SET (N19,N20)=(SELECT DECODE(TRIM(MA_NT),'USD',SUM(TIEN),0),DECODE(TRIM(MA_NT),'VND',SUM(TIEN),0) FROM TBH_XL_PBO
    WHERE  SO_ID_XL=B_SO_ID_XL AND GOC='BT_HS' AND KIEU=B_KIEU AND (B_NV IS NULL OR NV=B_NV) GROUP BY MA_NT);

UPDATE TEMP_1 SET (N13,N14,N15,N16)=(SELECT DECODE(TRIM(MA_NT),'USD',SUM(TIEN),0),DECODE(TRIM(MA_NT),'VND',SUM(TIEN),0),
    DECODE(TRIM(MA_NT),'USD',SUM(HHONG),0),DECODE(TRIM(MA_NT),'VND',SUM(HHONG),0) FROM TBH_XL_PBO
    WHERE  SO_ID_XL=B_SO_ID_XL AND GOC='HD_HU' AND KIEU=B_KIEU AND (B_NV IS NULL OR NV=B_NV) AND NHA_BH=B_NHA_BH GROUP BY MA_NT);

UPDATE TEMP_1 SET (N17,N18)=(SELECT DECODE(TRIM(MA_NT),'USD',SUM(TIEN),0),DECODE(TRIM(MA_NT),'VND',SUM(TIEN),0) FROM TBH_XL_PBO
    WHERE  SO_ID_XL=B_SO_ID_XL AND GOC='BT_HS' AND KIEU=B_KIEU AND (B_NV IS NULL OR NV=B_NV) AND NHA_BH=B_NHA_BH GROUP BY MA_NT);
IF B_KIEU IN ('C','D') THEN

    UPDATE TEMP_1 SET (C16)=(SELECT MAX(PTHUC) FROM TBH_GHEP_PHI WHERE  SO_ID=B_SO_ID_PS AND NHA_BH=B_NHA_BH);
    UPDATE TEMP_1 SET (N5,N6)=(SELECT SUM(PT),SUM(PT_HH) FROM TBH_GHEP_PHI WHERE  SO_ID=B_SO_ID_PS AND NHA_BH=B_NHA_BH);
    -- LAM SACH
--     UPDATE TEMP_1 SET (N9,N10,N11,N12)=(SELECT DECODE(TRIM(B.NT_PHI),'USD',SUM(A.PHI),0),DECODE(TRIM(B.NT_PHI),'VND',SUM(A.PHI),0),
--         DECODE(TRIM(B.NT_PHI),'USD',SUM(A.HHONG),0),DECODE(TRIM(B.NT_PHI),'VND',SUM(A.HHONG),0) FROM TBH_GHEP_PHI A,TBH_GHEP B
--         WHERE  A.MA_DVI=B.MA_DVI AND A.SO_ID=B.SO_ID AND A.SO_ID=B_SO_ID_PS AND A.NHA_BH=B_NHA_BH GROUP BY B.NT_PHI);
    --PT HH
--       UPDATE TEMP_1 SET (N32,N33)=(SELECT DECODE(TRIM(B.NT_PHI),'USD',PT_HH,0)*100,DECODE(TRIM(B.NT_PHI),'VND',PT_HH,0)*100 FROM TBH_GHEP_PHI A,TBH_GHEP B
--         WHERE  A.MA_DVI=B.MA_DVI AND A.SO_ID=B.SO_ID AND A.SO_ID=B_SO_ID_PS AND A.NHA_BH=B_NHA_BH);
    --THUE
--     UPDATE TEMP_1 SET (N28,N29,N30,N31)=(SELECT DECODE(TRIM(B.NT_PHI),'USD',TL_THUE,0),DECODE(TRIM(B.NT_PHI),'VND',TL_THUE,0),
--         DECODE(TRIM(B.NT_PHI),'USD',SUM(A.THUE),0),DECODE(TRIM(B.NT_PHI),'VND',SUM(A.THUE),0) FROM TBH_GHEP_PHI A,TBH_GHEP B
--         WHERE  A.MA_DVI=B.MA_DVI AND A.SO_ID=B.SO_ID AND A.SO_ID=B_SO_ID_PS AND A.NHA_BH=B_NHA_BH GROUP BY B.NT_PHI,TL_THUE);

    UPDATE TEMP_1 SET (N7,N8,N23,C10,C13)=(SELECT DECODE(TRIM(B.NT_PHI),'USD',SUM(B.TTOAN),0),DECODE(TRIM(B.NT_PHI),'VND',SUM(B.TTOAN),0),
        A.SO_ID_HD,A.MA_DVI_HD,B.LH_NV FROM TBH_GHEP_HD A, BH_HD_GOC_DK B
        WHERE  A.SO_ID=B_SO_ID_PS AND A.SO_ID_HD=B.SO_ID AND A.MA_DVI_HD=B.MA_DVI
            AND (B_LH_NV IS NULL OR B.LH_NV LIKE B_LH_NV||'%') GROUP BY B.NT_PHI,A.SO_ID_HD,A.MA_DVI_HD,B.LH_NV );
ELSIF B_KIEU IN ('T','B') THEN

    UPDATE TEMP_1 SET (N5,N6)=(SELECT SUM(PT),SUM(PT_HH) FROM TBH_TM_PHI WHERE  SO_ID=B_SO_ID_PS/* AND NHA_BH=B_NHA_BH*/);
--     UPDATE TEMP_1 SET (N9,N10,N11,N12)=(SELECT DECODE(TRIM(B.NT_PHI),'USD',SUM(A.PHI),0),DECODE(TRIM(B.NT_PHI),'VND',SUM(A.PHI),0),
--         DECODE(TRIM(B.NT_PHI),'USD',SUM(A.HHONG),0),DECODE(TRIM(B.NT_PHI),'VND',SUM(A.HHONG),0) FROM TBH_TM_PHI A,TBH_TM B
--         WHERE  A.MA_DVI=B.MA_DVI AND A.SO_ID=B.SO_ID AND A.SO_ID=B_SO_ID_PS /*AND A.NHA_BH=B_NHA_BH */GROUP BY B.NT_PHI);

    UPDATE TEMP_1 SET (N7,N8,N23,C10,C13)=(SELECT DECODE(TRIM(B.NT_PHI),'USD',SUM(B.TTOAN),0),DECODE(TRIM(B.NT_PHI),'VND',SUM(B.TTOAN),0),
        A.SO_ID_HD,A.MA_DVI_HD,B.LH_NV FROM TBH_TM_HD A, BH_HD_GOC_DK B
        WHERE  A.SO_ID=B_SO_ID_PS AND A.SO_ID_HD=B.SO_ID AND A.MA_DVI_HD=B.MA_DVI
            AND (B_LH_NV IS NULL OR B.LH_NV = B_LH_NV) AND B.TTOAN>0 GROUP BY B.NT_PHI,A.SO_ID_HD,A.MA_DVI_HD,B.LH_NV );
END IF;
UPDATE TEMP_1 SET (C11,C12)=(SELECT SO_HD,TEN FROM BH_HD_GOC WHERE N23=SO_ID AND C10=MA_DVI);
UPDATE TEMP_1 SET C14=(SELECT TEN FROM BH_MA_LHNV WHERE MA=C13 AND C10=MA_DVI);

UPDATE TEMP_1 SET N24=N7*90/100 WHERE B_NV='PHH';
UPDATE TEMP_1 SET N25=N8*90/100 WHERE B_NV='PHH';
UPDATE TEMP_1 SET N26=N7*10/100 WHERE B_NV='PHH';
UPDATE TEMP_1 SET N27=N8*10/100 WHERE B_NV='PHH';
DELETE TEMP_1 WHERE N7=0 AND N8=0;

FOR R_LP IN (SELECT A.TEN FROM BH_MA_NBH A, TBH_HD_DI_NHA_BH B WHERE A.MA=B.NHA_BH AND B.SO_ID=B_SO_ID_TA_HD AND A.MA_DVI=B.MA_DVI AND B.KIEU='P') LOOP
    B_TENP:=B_TENP||','||R_LP.TEN;
END LOOP;
DELETE TEMP_4;
-- FOR R_LP IN (SELECT B.NHA_BH,A.LH_NV,DECODE(TRIM(A.NT_PHI),'USD',PHI,0)*B.PT/100 PHI_USD,DECODE(TRIM(A.NT_PHI),'VND',PHI,0)*B.PT/100 PHI_VND FROM TBH_GHEP_PBO A, TBH_HD_DI_NHA_BH B WHERE B.SO_ID=B_SO_ID_TA_HD AND A.SO_ID=B_SO_ID_PS AND A.SO_ID_HD_TA=B.SO_ID AND A.MA_DVI=B.MA_DVI AND B.KIEU='P') LOOP
--     PTBH_PBO_NOP(R_LP.LH_NV,R_LP.NHA_BH,B_NGAY_HT,R_LP.PHI_USD,B_TP_P,B_TL_THUE,B_THUE_USD,B_LOI);
--     INSERT INTO TEMP_4(N1,N2,N3)VALUES(B_TL_THUE,B_THUE_USD,0);
--     PTBH_PBO_NOP(R_LP.LH_NV,R_LP.NHA_BH,B_NGAY_HT,R_LP.PHI_VND,B_TP_P,B_TL_THUE,B_THUE_VND,B_LOI);
--     INSERT INTO TEMP_4(N1,N2,N3)VALUES(B_TL_THUE,0,B_THUE_VND);
-- END LOOP;
B_TL_THUE:=0;B_THUE_USD:=0;B_THUE_VND:=0;
SELECT MAX(N1) INTO B_TL_THUE FROM TEMP_4;
SELECT SUM(N2) INTO B_THUE_USD FROM TEMP_4;
SELECT SUM(N3) INTO B_THUE_VND FROM TEMP_4;
--PTBH_PBO_NOP(A_MA_TA(B_LP),A_BH_NBH(B_LP1),B_NG_TAI,B_PHI_XL,B_TP_P,B_TL_THUE,B_THUE,B_LOI);

SELECT JSON_ARRAYAGG(JSON_OBJECT('SO_ID_DC' VALUE N1,'NGAY' VALUE N2 ,'NHA_BH' VALUE C2 ,'SO_BK' VALUE C3 ,'SO_DC' VALUE C4 ,'TEN' VALUE C5 ,'DCHI' VALUE C6 ,'SO_HD' VALUE C11 ,'TEN_KH' VALUE C12 ,'LH_NV' VALUE C14 ,'PTHUC' VALUE C16 ,'TENP' VALUE B_TENP
,'PHI_HT_USD' VALUE N3 ,'PHI_HT_VND' VALUE N4 ,'PHI_BT_VND' VALUE N19 ,'PHI_BT_USD' VALUE N20 ,'PT_TA' VALUE N5 ,'PT_HH' VALUE N6 ,'PHI_BH_USD' VALUE N7 ,'PHI_BH_VND' VALUE N8
,'PHI_TA_USD' VALUE N9 ,'PHI_TA_VND' VALUE N10 ,'HH_TA_USD' VALUE N11 ,'HH_TA_VND' VALUE N12 ,'PHI_TA_HT_USD' VALUE N13 ,'PHI_TA_HT_VND' VALUE N14
,'HH_TA_HT_USD' VALUE N15 ,'HH_TA_HT_VND' VALUE N16 ,'PHI_BT_TA_USD' VALUE N17 ,'PHI_BT_TA_VND' VALUE N18 ,'PHI_FI_USD' VALUE N24 ,'PHI_FI_VND' VALUE N25 ,'PHI_SF_USD' VALUE N26 ,'PHI_SF_VND' VALUE N27
,'PT_HH_USD' VALUE N32 ,'PT_HH_VND' VALUE N33
,'PT_THUE_USD' VALUE B_TL_THUE ,'PT_THUE_V' VALUE B_TL_THUE ,'THUE_TA_USD' VALUE B_THUE_USD ,'THUE_TA_VND' VALUE B_THUE_VND
,'SO_HD_TA' VALUE C7 ,'KIEU' VALUE C8 ,'MA_NT' VALUE C9 ,'ND' VALUE C15 ,'NGAY_BD' VALUE N21 ,'NGAY_KT' VALUE N22 ,'QUI' VALUE B_QUI ,'NAM' VALUE B_NAM ,'NV_TA' VALUE B_NV_TA   RETURNING CLOB
) RETURNING CLOB) INTO B_DT FROM TEMP_1;

SELECT JSON_OBJECT('b_dt' VALUE B_DT RETURNING CLOB) INTO B_ORAOUT FROM DUAL;

EXCEPTION WHEN OTHERS THEN IF B_LOI IS NULL THEN RAISE PROGRAM_ERROR; ELSE RAISE_APPLICATION_ERROR(-20105,B_LOI); ROLLBACK; END IF;
END;
