create or replace function FBH_BT_PKT_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return varchar2
AS
    b_kq varchar2(100):=' '; b_i1 number; b_txt clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
select count(*) into b_i1 from bh_bt_pkt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_bt_pkt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    b_kq:=FKH_JS_GTRIs(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_BT_PKT_TTRANG(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra tinh trang
select nvl(min(ttrang),'X') into b_kq from bh_bt_pkt where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_PKT_NV(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra nghiep vu
select nvl(min(ttrang),'G') into b_kq from bh_bt_pkt where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_PKT_BTH_LKE(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay_xr number) return clob
as
    dt_bth clob; b_ngay_ph number;
begin
-- Dan - Luy ke boi thuong GCN
b_ngay_ph:=FBH_PKT_NGAY_PH(b_ma_dvi,b_so_id,b_so_id_dt,b_ngay_xr);
select JSON_ARRAYAGG(json_object(ma,bt_lke) returning clob) into dt_bth from
    (select ma,sum(tien_bh-t_that) bt_con,sum(t_that) bt_lke from bh_bt_pkt_dk where (ma_dvi,so_id) in 
    (select ma_dvi,so_id from bh_bt_pkt where ma_dvi_ql=b_ma_dvi and so_id_hd=b_so_id and
    so_id_dt=b_so_id_dt and ttrang='D' and ngay_xr between b_ngay_ph and b_ngay_xr) group by ma);
return dt_bth;
end;
/
create or replace procedure PBH_BT_PKT_MO
    (b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(200); b_ngay number:=PKH_NG_CSO(sysdate);
    cs_kbt clob; cs_ttt clob;
begin
-- Dan - Lay gia tri ban dau
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt) into cs_kbt from bh_kh_ttt where ps='KBT' and nv='PKT';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_ttt
    from bh_kh_ttt where ps='BT' and nv='PKT';
select json_object('cs_kbt' value cs_kbt,'cs_ttt' value cs_ttt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_BT_PKT_SO_HS(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(30);
begin
-- Dan - Tra so_id
select min(so_hs) into b_kq from bh_bt_pkt where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure FBH_BT_PKT_SO_ID(b_so_hs varchar2,b_ma_dvi out varchar2,b_so_id out number)
AS
begin
-- Dan - Tra ma_dvi, so_id
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_bt_pkt where so_hs=b_so_hs;
end;
/
create or replace procedure PBH_BT_PKT_SO_ID(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_hs varchar2(30):=FKH_JS_GTRIs(b_oraIn,'so_hs');
    b_ma_dvi varchar2(10); b_so_id number;
begin
-- Dan - Tra ma_dvi,so_id
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FBH_BT_PKT_SO_ID(b_so_hs,b_ma_dvi,b_so_id);
if b_so_id=0 then b_loi:='loi:Ho so da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_PKT_FBPHI(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma_dvi varchar2(10); b_so_id number;
    b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_id_dt number; b_so_idP number;
begin
-- Dan - Tra ma_dvi,so_id
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ho so da xoa:loi';
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_ma_dvi:=nvl(trim(b_ma_dvi),' '); b_so_id:=nvl(b_so_id,0);
select ma_dvi_ql,so_id_hd,so_id_dt into b_ma_dvi_hd,b_so_id_hd,b_so_id_dt from bh_bt_pkt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select nvl(min(so_idP),0) into b_so_idP from bh_pkt_dvi where ma_dvi=b_ma_dvi_hd and so_id=b_so_id_hd and so_id_dt=b_so_id_dt;
b_oraOut:=to_char(b_so_idP);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_PKT_FHD(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma_dvi varchar2(10); b_so_id number;
    b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_id_dt number;
begin
-- Dan - Tra ma_dvi,so_id
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ho so da xoa:loi';
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_ma_dvi:=nvl(trim(b_ma_dvi),' '); b_so_id:=nvl(b_so_id,0);
select ma_dvi_ql,so_id_hd,so_id_dt into b_ma_dvi_hd,b_so_id_hd,b_so_id_dt from bh_bt_pkt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select json_object('ma_dvi' value b_ma_dvi_hd,'so_id' value b_so_id_hd,'so_id_dt' value b_so_id_dt) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_PKT_LKE_GCN(
	b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ma_dvi_ql varchar2(10); b_so_hd varchar2(20); b_so_id_hd number; b_so_id_dt number;
    cs_phi clob; cs_bth clob;
begin
-- Dan - Liet ke phi va boi thuong cua 1 GCN
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi_ql,so_hd,so_id_dt');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi_ql,b_so_hd,b_so_id_dt using b_oraIn;
b_so_id_hd:=FBH_pkt_HD_SO_IDd(b_ma_dvi_ql,b_so_hd);
FBH_BT_LKE_PHI(b_ma_dvi_ql,b_so_id_hd,cs_phi);
select JSON_ARRAYAGG(json_object(so_hs,ngay_mo,ttrang,tien,ma_dvi,so_id) order by ngay_mo desc)
    into cs_bth from bh_bt_pkt where so_id_dt=b_so_id_dt;
select json_object('cs_phi' value cs_phi,'cs_bth' value cs_bth) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_PKT_GCN(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000);
    b_so_id_dt number; b_ngay_xr number; b_nt_tien varchar2(5); b_i1 number;
    b_ma_dvi varchar2(10); b_so_idG number; b_so_id number; b_tg number:=1;
    dt_ct clob; dt_kbt clob; dt_hk clob; dt_btlke clob; dt_dk clob; dt_lt clob; dt_pvi clob;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id_dt,ngay_xr');
EXECUTE IMMEDIATE b_lenh into b_so_id_dt,b_ngay_xr using b_oraIn;
b_so_id_dt:=nvl(b_so_id_dt,0); b_ngay_xr:=nvl(b_ngay_xr,0); 
b_loi:='loi:Dia diem bao hiem da xoa:loi';
FBH_PKT_SO_ID_DTf(b_so_id_dt,b_ma_dvi,b_so_idG);
if b_so_idG=0 then raise PROGRAM_ERROR; end if;
b_so_id:=FBH_PKT_SO_IDb(b_ma_dvi,b_so_idG,b_ngay_xr);
select nt_tien into b_nt_tien from bh_pkt where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nt_tien<>'VND' then b_tg:=FBH_TT_TRA_TGTT(b_ngay_xr,b_nt_tien); end if;
select json_object(a.so_hd,b.gcn,a.ten,'ma_dvi_ql' value a.ma_dvi,b.dvi,b.ngay_hl,b.ngay_kt,a.nt_tien,a.c_thue,
    'lhe_ten' value a.ten,'lhe_mobi' value a.mobi,'lhe_mail' value a.email,'tygia' value b_tg) into dt_ct
    from bh_pkt a,bh_pkt_dvi b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and
    b.ma_dvi=b_ma_dvi and b.so_id=b_so_id and b.so_id_dt=b_so_id_dt;
select JSON_ARRAYAGG(json_object('chon' value '',MA,ten,'tien_bh' value tien,
    'pt_bt' value 0,'ycau' value 0,'t_that' value 0,'tien' value 0,'nd' value '','ktru' value 0,
    't_hoi' value 0,'bt_con' value 0,'bt_lke' value 0,'bt' value bt,
    cap,tc,ma_ct,ma_dk,ma_dkC,kieu,lh_nv,t_suat,ptB,lkeP,lkeB,luy,lbh,nv,'ktruk' value ktru,pvi_ktru)
    order by bt returning clob) into dt_dk from bh_pkt_dk where
    ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and pvi_ma=' ' and nv<>'M';
-- nam: lay dklt, dkbt
select lt,kbt into dt_lt,dt_kbt from bh_pkt_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
dt_btlke:=FBH_BT_PKT_BTH_LKE(b_ma_dvi,b_so_id,b_so_id_dt,b_ngay_xr);
select count(*) into b_i1 from bh_pkt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
if b_i1=1 then
    select txt into dt_hk from bh_pkt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
end if;
select JSON_ARRAYAGG(json_object('ten' value FBH_PKT_PVI_TEN(ma),'chon' value '',ma,ktru) order by ma returning clob) into dt_pvi from
    (select distinct pvi_ma ma,pvi_ktru ktru from bh_pkt_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and pvi_ma<>' ');
select json_object('so_id_dt' value b_so_id_dt,'dt_ct' value dt_ct,'dt_lt' value dt_lt,'dt_kbt' value dt_kbt,'dt_hk' value dt_hk,
    'dt_btlke' value dt_btlke,'dt_dk' value dt_dk,'dt_pvi' value dt_pvi returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_PKT_GCNd(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma_dvi varchar2(10); b_so_id number; b_so_id_dt number; 
begin
-- Dan - Tra so_id_dt qua GCN
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','PKT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FBH_PKT_SO_ID_GCN(b_oraIn,b_ma_dvi,b_so_id,b_so_id_dt);
select json_object('so_id_dt' value b_so_id_dt) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_PKT_GCNdk(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000);
    b_so_id_dt number; b_ngay_xr number;
    b_ma_dvi varchar2(10); b_so_idG number; b_so_id number;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id_dt,ngay_xr');
EXECUTE IMMEDIATE b_lenh into b_so_id_dt,b_ngay_xr using b_oraIn;
b_so_id_dt:=nvl(b_so_id_dt,0); b_ngay_xr:=nvl(b_ngay_xr,0);
b_loi:='loi:Dia diem bao hiem da xoa:loi';
FBH_PKT_SO_ID_DTf(b_so_id_dt,b_ma_dvi,b_so_idG);
if b_so_idG=0 then raise PROGRAM_ERROR; end if;
b_so_id:=FBH_PKT_SO_IDb(b_ma_dvi,b_so_idG,b_ngay_xr);
select JSON_ARRAYAGG(json_object('chon' value '',MA,ten,'tien_bh' value tien,
    'pt_bt' value 0,'ycau' value 0,'t_that' value 0,'tien' value 0,'nd' value '','ktru' value 0,
    't_hoi' value 0,'bt_con' value 0,'bt_lke' value 0,
    cap,tc,ma_ct,ma_dk,ma_dkC,kieu,lh_nv,t_suat,ptB,lkeP,lkeB,luy,lbh,nv,'ktruk' value ktru,pvi_ktru,'bt' value bt)
    order by bt returning clob) into b_oraOut from bh_pkt_dk where
    ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and pvi_ma=' ';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_PKT_GCNpv(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000);
    b_so_id_dt number; b_ngay_xr number;
    b_ma_dvi varchar2(10); b_so_idG number; b_so_id number;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id_dt,ngay_xr');
EXECUTE IMMEDIATE b_lenh into b_so_id_dt,b_ngay_xr using b_oraIn;
b_so_id_dt:=nvl(b_so_id_dt,0); b_ngay_xr:=nvl(b_ngay_xr,0);
b_loi:='loi:Dia diem bao hiem da xoa:loi';
FBH_PKT_SO_ID_DTf(b_so_id_dt,b_ma_dvi,b_so_idG);
if b_so_idG=0 then raise PROGRAM_ERROR; end if;
b_so_id:=FBH_PKT_SO_IDb(b_ma_dvi,b_so_idG,b_ngay_xr);
select JSON_ARRAYAGG(json_object('ten' value FBH_PKT_PVI_TEN(ma),'chon' value '',ma,ktru) order by ma returning clob) into b_oraOut from
    (select distinct pvi_ma ma,pvi_ktru ktru from bh_pkt_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and pvi_ma<>' ');
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;

/
create or replace procedure PBH_BT_PKT_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10);
    b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number;
    b_dong number; cs_lke clob;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_bt_pkt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hs,nsd) obj,rownum sott from bh_bt_pkt where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_hs)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','BT','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_bt_pkt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hs,nsd) obj,rownum sott from bh_bt_pkt  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_hs)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_bt_pkt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hs,nsd) obj,rownum sott from bh_bt_pkt  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_hs)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_PKT_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10); b_so_hs varchar2(30);
    b_so_id number; b_ngay_ht number; b_klk varchar2(1); b_trangKt number; b_tu number; b_den number;
    b_trang number; b_dong number; cs_lke clob;
begin
-- Dan - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,klk,trangkt,tu,den');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_klk,b_trangKt,b_tu,b_den using b_oraIn;
b_so_hs:=FBH_BT_PKT_SO_HS(b_ma_dvi,b_so_id);
if b_so_hs is null then b_loi:='loi:Ho so da xoa:loi'; raise PROGRAM_ERROR; end if;
if b_klk ='N' then
    select count(*) into b_dong from bh_bt_pkt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hs,rownum sott from bh_bt_pkt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_hs)
        where so_hs>=b_so_hs;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hs,nsd) obj,rownum sott from bh_bt_pkt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_hs)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','BT','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_bt_pkt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hs,rownum sott from bh_bt_pkt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_hs)
        where so_hs>=b_so_hs;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hs,nsd) obj,rownum sott from bh_bt_pkt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_hs)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_bt_pkt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hs,rownum sott from bh_bt_pkt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_hd)
        where so_hs>=b_so_hs;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hs,nsd) obj,rownum sott from bh_bt_pkt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_PKT_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(3000); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number; b_ngay_xr number;
    b_ma_dvi_ql varchar2(10); b_so_id_hd number; b_so_id_hdB number; b_so_id_dt number;
    dt_ct clob; dt_dk clob; dt_hk clob:=''; dt_tba clob:=''; dt_lt clob:='';
    dt_thoi clob:=''; dt_kbt clob:=''; dt_ttt clob:=''; dt_pvi clob:=''; dt_txt clob;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','PKT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_loi:='loi:Ho so da xoa:loi';
select ma_dvi_ql,so_id_hd,so_id_dt,ngay_xr into b_ma_dvi_ql,b_so_id_hd,b_so_id_dt,b_ngay_xr from bh_bt_pkt where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_so_id_hdB:=Fbh_pkt_SO_IDb(b_ma_dvi_ql,b_so_id_hd,b_ngay_xr);
select lt,kbt into dt_lt,dt_kbt from bh_pkt_kbt where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB and so_id_dt=b_so_id_dt;
select json_object(so_hs,tien,tienHK,'ma_nn' value FBH_PKT_NNTT_TENl(ma_nn) returning clob)
    into dt_ct from bh_bt_pkt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ma returning clob) order by bt returning clob) into dt_dk
    from bh_bt_pkt_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ten,tien) order by bt) into dt_hk
    from bh_bt_pkt_hk where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ten,ma_nt,tien) order by bt) into dt_tba from bh_bt_pkt_tba where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ma,'t_hoi' value tien)) into dt_thoi from
    (select ma,sum(tien) tien from bh_bt_thoi_ct where ma_dvi=b_ma_dvi and so_id_hs=b_so_id group by ma having sum(tien)<>0);
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_bt_pkt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai not in('dt_tba','dt_kbt','dt_pvi');
select count(*) into b_i1 from bh_bt_pkt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
if b_i1<>0 then
    select txt into dt_ttt from bh_bt_pkt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
end if;
select count(*) into b_i1 from bh_bt_pkt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_pvi';
if b_i1<>0 then
    select txt into dt_pvi from bh_bt_pkt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_pvi';
end if;
select count(*) into b_i1 from bh_bt_pkt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
if b_i1<>0 then
    select txt into dt_hk from bh_bt_pkt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_id_dt' value b_so_id_dt,
    'dt_ttt' value dt_ttt,'dt_pvi' value dt_pvi,'dt_lt' value dt_lt,'dt_kbt' value dt_kbt,
    'dt_hk' value dt_hk, 'dt_tba' value dt_tba,'dt_thoi' value dt_thoi,'dt_hk' value dt_hk,
    'dt_ct' value dt_ct,'dt_dk' value dt_dk,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_PKT_TESTr(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id_dt number,
    dt_ct clob,dt_dk clob,dt_hk clob,dt_tba clob,dt_kbt out clob,

    b_gcn out varchar2,b_ma_dvi_ql out varchar2,b_so_hd out varchar2,b_so_id_hd out number,
    b_ma_kh out varchar2,b_ten out nvarchar2,b_tienHK out number,b_ma_nn out varchar2,

    dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,dk_tc out pht_type.a_var,dk_ma_ct out pht_type.a_var,
    dk_tien_bh out pht_type.a_num,dk_pt_bt out pht_type.a_num,dk_t_that out pht_type.a_num,
    dk_tien out pht_type.a_num,dk_thue out pht_type.a_num,dk_tien_qd out pht_type.a_num,dk_thue_qd out pht_type.a_num,
    dk_cap out pht_type.a_num,dk_ma_dk out pht_type.a_var,dk_ma_dkC out pht_type.a_var,
    dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,dk_lkeB out pht_type.a_var,dk_luy out pht_type.a_var,
    dk_ktru out pht_type.a_var,
    hk_ma out pht_type.a_var,hk_ten out pht_type.a_nvar,hk_ma_nt out pht_type.a_var,
    hk_tien out pht_type.a_num,hk_thue out pht_type.a_num,hk_tien_qd out pht_type.a_num,hk_thue_qd out pht_type.a_num,
    tba_ten out pht_type.a_nvar,tba_ma_nt out pht_type.a_var,tba_tien out pht_type.a_num,b_loi out varchar2)

AS
    b_lenh varchar2(2000); b_i1 number; b_i2 number; b_noite varchar2(5):='VND'; b_tp number:=0; b_tg number;
    b_ttrang varchar2(1); b_so_id_hdB number; b_ngay_xr number; b_nt_tien varchar2(5); b_c_thue varchar2(1);
    b_tienH number; b_thueH number; b_tien number; b_thue number; b_ma_sp varchar2(10); b_bhanh number; b_ngay_kt number; b_ngay_bhanh number; -- Nam: thoi gian bth = ngay_kt + ngay bao hanh
    dk_bt_con pht_type.a_num;
begin
-- Dan kiem tra thong tin nhap ho so boi thuong
b_lenh:=FKH_JS_LENH('ttrang,ma_dvi_ql,so_hd,ngay_xr,nt_tien,c_thue,tien,thue,ma_nn');
EXECUTE IMMEDIATE b_lenh into b_ttrang,b_ma_dvi_ql,b_so_hd,b_ngay_xr,b_nt_tien,b_c_thue,b_tienH,b_thueH,b_ma_nn using dt_ct;
if b_ma_dvi_ql is null or b_so_hd is null then b_loi:='loi:Chon hop dong bao hiem:loi'; return; end if;
b_so_id_hd:=FBH_PKT_SO_ID(b_ma_dvi_ql,b_so_hd);
if b_so_id_hd=0 then b_loi:='loi:Hop dong da xoa:loi'; return; end if;
if b_so_id_dt is null then b_loi:='loi:Chon dia diem bao hiem:loi'; return; end if;
b_so_id_hdB:=FBH_PKT_SO_IDb(b_ma_dvi_ql,b_so_id_hd,b_ngay_xr);
select count(*) into b_i1 from bh_pkt where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB and nt_tien=b_nt_tien and c_thue=b_c_thue;
if b_i1=0 then b_loi:='loi:Sai loai tien bao hiem, loai thue so voi hop dong:loi'; return; end if;
if b_nt_tien<>'VND' then b_tp:=2; end if;
select min(bhanh),min(ngay_kt) into b_bhanh,b_ngay_kt from bh_pkt_dvi where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB and
    so_id_dt=b_so_id_dt and ngay_cap<=b_ngay_xr;
b_ngay_bhanh:=PKH_NG_CSO(ADD_MONTHS(PKH_SO_CDT(b_ngay_kt), b_bhanh)); -- Nam: thoi gian bth = ngay_kt + ngay bao hanh 
select min(gcn) into b_gcn from bh_pkt_dvi where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB and
    so_id_dt=b_so_id_dt and ngay_cap<=b_ngay_xr and b_ngay_xr between ngay_hl and b_ngay_bhanh;
if b_gcn is null then b_loi:='loi:Ngay xay ra ngoai hieu luc bao hiem:loi'; return; end if;
select so_hd,ma_kh,ten,ma_sp into b_so_hd,b_ma_kh,b_ten,b_ma_sp from bh_pkt where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,tien_bh,pt_bt,t_that,tien,cap,ma_dk,ma_dkc,lh_nv,t_suat,lkeb,luy,ktruk,bt_con');
EXECUTE IMMEDIATE b_lenh bulk collect into
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_tien_bh,dk_pt_bt,dk_t_that,dk_tien,
    dk_cap,dk_ma_dk,dk_ma_dkC,dk_lh_nv,dk_t_suat,dk_lkeB,dk_luy,dk_ktru,dk_bt_con using dt_dk;
if dk_ma.count=0 then b_loi:='loi:Nhap dieu khoan:loi'; return; end if;
PBH_BT_BCAO_PBO(dk_ma,dk_ma_ct,dk_cap,dk_t_that,dk_tien,b_loi);
b_tg:=FBH_TT_TRA_TGTT(b_ngay_xr,b_nt_tien);
b_tien:=0; b_thue:=0;
for b_lp in 1..dk_ma.count loop
    if dk_t_suat(b_lp) is null then dk_t_suat(b_lp):=0; end if;
    b_c_thue:='K';
    if b_c_thue<>'C' then dk_thue(b_lp):=0;
    else dk_thue(b_lp):= round(dk_tien(b_lp)*dk_t_suat(b_lp)/100, b_tp);
    end if;
    if b_nt_tien=b_noite then
        dk_tien_qd(b_lp):=dk_tien(b_lp); dk_thue_qd(b_lp):=dk_thue(b_lp);
    else
        dk_tien_qd(b_lp):=round(b_tg*dk_tien(b_lp),0); dk_thue_qd(b_lp):=round(b_tg*dk_thue(b_lp),0);
    end if;
    dk_ktru(b_lp):=nvl(trim(dk_ktru(b_lp)),'K');
    if nvl(dk_lh_nv(b_lp),' ')<>' ' then
       b_tien:=b_tien+dk_tien(b_lp); b_thue:=b_thue+dk_thue(b_lp);
    end if;
end loop;
if b_tienH<>b_tien or b_thueH<>b_thue then
    b_loi:='loi:Chenh tong tien,thue chi tiet va ho so:loi'; return;
end if;
b_tienHK:=0;
if trim(dt_hk) is null then
    PKH_MANG_KD_N(hk_tien);
else
    b_lenh:=FKH_JS_LENH('ma,ten,tien,thue');
    EXECUTE IMMEDIATE b_lenh bulk collect into hk_ma,hk_ten,hk_tien,hk_thue using dt_hk;
    b_i1:=0;
    for b_lp in 1..hk_tien.count loop
        hk_ma_nt(b_lp):=b_nt_tien; hk_tien(b_lp):=nvl(hk_tien(b_lp),0); hk_thue(b_lp):=nvl(hk_thue(b_lp),0);
        if hk_ma_nt(b_lp)=b_nt_tien then
            hk_tien_qd(b_lp):=hk_tien(b_lp); hk_thue_qd(b_lp):=hk_thue(b_lp);
        else
            if hk_ma_nt(b_lp)=b_nt_tien then
                b_i2:=b_tg;
            else
                b_i2:=FTT_TRA_TGTT(b_ma_dvi,b_ngay_xr,hk_ma_nt(b_lp));
            end if;
            hk_tien_qd(b_lp):=round(hk_tien(b_lp)*b_i2,0); hk_thue_qd(b_lp):=round(hk_thue(b_lp)*b_i2,0);
        end if;
        b_tienHK:=b_tienHK+hk_tien(b_lp);
        if trim(hk_ma(b_lp)) is not null then
            b_i2:=PKH_LOC_CHU_SO(hk_ma(b_lp),'F','F');
            if b_i2<100000 and b_i2>b_i1 then b_i1:=b_i2; end if;
        end if;
    end loop;
    for b_lp in 1..hk_tien.count loop
        if trim(hk_ma(b_lp)) is null then
            b_i1:=b_i1+1; hk_ma(b_lp):=to_char(b_i1);
        end if;
    end loop;
end if;
if trim(dt_tba) is null then
    PKH_MANG_KD(tba_ma_nt);
else
    b_lenh:=FKH_JS_LENH('ten,ma_nt,tien');
    EXECUTE IMMEDIATE b_lenh bulk collect into tba_ten,tba_ma_nt,tba_tien using dt_tba;
    for b_lp in 1..tba_ma_nt.count loop
        tba_ma_nt(b_lp):=nvl(trim(tba_ma_nt(b_lp)),'VND');
    end loop;
end if;
dt_kbt:='';
if b_ttrang in('T','D') then
    if b_tien<b_tienHK then b_loi:='loi:Tien ho so nho hon tien huong khac:loi'; return; end if;
    if FBH_HD_HU(b_ma_dvi_ql,b_so_id_hd,b_ngay_xr)='C' then b_loi:='loi:Da cham dut hop dong:loi'; return; end if;
    -- ben tren da chan roi + them thoi gian bao hanh
    --if FBH_pkt_HLd(b_ma_dvi_ql,b_so_id_hd,b_so_id_dt,b_ngay_xr)='K' then
    --     b_loi:='loi:Ngay xay ra ngoai ngay hieu luc:loi'; return;
    --end if;
    for b_lp in 1..dk_ma.count loop
        if dk_bt_con(b_lp)<0 then
            b_loi:='loi:Dieu khoan '||dk_ma(b_lp)||' boi thuong vuot muc trach nhiem :loi'; return;
        end if;
    end loop;
    select kbt into dt_kbt from bh_pkt_kbt where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB and so_id_dt=b_so_id_dt;
    dt_kbt:=FKH_JS_BONH(dt_kbt);
    PBH_BT_PKT_KBT(b_ma_dvi_ql,b_so_id_hd,b_so_id_dt,dt_ct,dt_dk,dt_kbt,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BT_PKT_XOA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh boolean,b_loi out varchar2)
AS 
    b_i1 number; r_hs bh_bt_pkt%rowtype;
Begin
-- Dan - Xoa boi thuong
select count(*) into b_i1 from bh_bt_pkt where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
b_loi:='loi:Loi xoa ho so:loi';
select * into r_hs from bh_bt_pkt where ma_dvi=b_ma_dvi and so_id=b_so_id;
if trim(r_hs.nsd) is not null and b_nsd<>r_hs.nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
PBH_BT_GOC_XOA(b_ma_dvi,b_nsd,b_so_id,b_nh,b_loi);
if b_loi is not null then return; end if;
delete bh_bt_pkt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_pkt_hk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_pkt_tba where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_pkt_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_pkt where ma_dvi=b_ma_dvi and so_id=b_so_id;
--nam: xoa du phong
delete bh_bt_pkt_duph where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BT_PKT_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    dt_ct clob,dt_dk clob,dt_hk clob,dt_tba clob,dt_kbt clob,dt_ttt clob,dt_pvi clob,   
-- Test chung
    b_ngay_ht number,b_so_hs varchar2,b_ttrang varchar2,
    b_kieu_hs varchar2,b_so_hs_g varchar2,b_phong varchar2,
    b_ngay_gui number,b_ngay_mo number,b_ngay_do number,b_ngay_xr number,
    b_n_trinh varchar2,b_n_duyet varchar2,b_ngay_qd number,
    b_nt_tien varchar2,b_c_thue varchar2,b_tien number,b_thue number,
    b_noP varchar2,b_bphi varchar2,b_dung varchar2,b_traN varchar2,
-- Test rieng
    b_gcn varchar2,b_ma_dvi_ql varchar2,b_so_hd varchar2,b_so_id_hd number,b_so_id_dt number,
    b_ma_kh varchar2,b_ten nvarchar2,b_tienHK number,b_ma_nn varchar2,
    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tc pht_type.a_var,dk_ma_ct pht_type.a_var,
    dk_tien_bh pht_type.a_num,dk_pt_bt pht_type.a_num,dk_t_that pht_type.a_num,
    dk_tien pht_type.a_num,dk_thue pht_type.a_num,dk_tien_qd pht_type.a_num,dk_thue_qd pht_type.a_num,
    dk_cap pht_type.a_num,dk_ma_dk pht_type.a_var,dk_ma_dkC pht_type.a_var,
    dk_lh_nv pht_type.a_var,dk_t_suat pht_type.a_num,dk_lkeB pht_type.a_var,dk_luy pht_type.a_var,
    hk_ma pht_type.a_var,hk_ten pht_type.a_nvar,hk_ma_nt pht_type.a_var,
    hk_tien pht_type.a_num,hk_thue pht_type.a_num,hk_tien_qd pht_type.a_num,hk_thue_qd pht_type.a_num,
    tba_ten pht_type.a_nvar,tba_ma_nt pht_type.a_var,tba_tien pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_so_id_kt number:=-1; b_dvi_ksoat varchar2(10):=''; b_ksoat varchar2(10):=''; b_duph varchar2(1);
begin
-- Dan - Nhap boi thuong
if b_ttrang='D' then b_so_id_kt:=0; end if;
if b_ngay_qd<30000101 then b_dvi_ksoat:=b_ma_dvi; b_ksoat:=b_nsd; end if;
b_duph:=FKH_JS_GTRIs(dt_ct,'duph'); b_duph:=nvl(trim(b_duph),'K');
b_loi:='loi:Loi Table bh_bt_pkt:loi';
insert into bh_bt_pkt values(b_ma_dvi,b_so_id,b_ngay_ht,b_so_hs,b_ttrang,b_kieu_hs,b_so_hs_g,
    b_gcn,b_ma_dvi_ql,b_ma_dvi,b_so_id_hd,b_so_id_dt,b_so_hd,b_ma_kh,b_ten,b_ngay_gui,b_ngay_mo,b_ngay_do,b_ngay_xr,
    b_ma_nn,b_n_trinh,b_n_duyet,b_ngay_qd,b_nt_tien,b_c_thue,b_tien,b_tienHK,b_thue,b_tien+b_thue,b_noP,b_bphi,b_dung,b_traN,
    b_nsd,b_phong,b_so_id_kt,b_dvi_ksoat,b_ksoat,sysdate);
b_loi:='loi:Loi Table bh_bt_pkt_dk:loi';
for b_lp in 1..dk_ma.count loop
    insert into bh_bt_pkt_dk values(b_ma_dvi,b_so_id,b_lp,
        dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),dk_cap(b_lp),
        dk_ma_dk(b_lp),dk_ma_dkC(b_lp),dk_lh_nv(b_lp),dk_t_suat(b_lp),
        dk_tien(b_lp),dk_pt_bt(b_lp),dk_t_that(b_lp),dk_tien(b_lp),dk_thue(b_lp),dk_tien(b_lp)+dk_thue(b_lp),
        dk_tien_qd(b_lp),dk_thue_qd(b_lp),dk_tien_qd(b_lp)+dk_thue_qd(b_lp),dk_lkeB(b_lp),dk_luy(b_lp));
end loop;
b_loi:='loi:day 1:loi';
if hk_ma_nt.count<>0 then
    b_loi:='loi:Loi Table bh_bt_pkt_HK:loi';
    for b_lp in 1..hk_ma_nt.count loop
        insert into bh_bt_pkt_hk values(
        b_ma_dvi,b_so_id,b_lp,hk_ma(b_lp),hk_ten(b_lp),hk_ma_nt(b_lp),
        hk_tien(b_lp),hk_thue(b_lp),hk_tien(b_lp)+hk_thue(b_lp),
        hk_tien_qd(b_lp),hk_thue_qd(b_lp),hk_tien_qd(b_lp)+hk_thue_qd(b_lp));
    end loop;
end if;
if tba_ma_nt.count<>0 then
    b_loi:='loi:Loi Table bh_bt_pkt_tba:loi';
    for b_lp in 1..tba_ma_nt.count loop
        insert into bh_bt_pkt_tba values(b_ma_dvi,b_so_id,b_lp,tba_ten(b_lp),tba_ma_nt(b_lp),tba_tien(b_lp));
    end loop;
end if;
insert into bh_bt_pkt_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
insert into bh_bt_pkt_txt values(b_ma_dvi,b_so_id,'dt_dk',dt_dk);
if length(dt_hk)<>0 then
    insert into bh_bt_pkt_txt values(b_ma_dvi,b_so_id,'dt_hk',dt_hk);
end if;
if length(dt_tba)<>0 then
    insert into bh_bt_pkt_txt values(b_ma_dvi,b_so_id,'dt_tba',dt_tba);
end if;
if length(dt_kbt)<>0 then
    insert into bh_bt_pkt_txt values(b_ma_dvi,b_so_id,'dt_kbt',dt_kbt);
end if;
if length(dt_ttt)<>0 then
    insert into bh_bt_pkt_txt values(b_ma_dvi,b_so_id,'dt_ttt',dt_ttt);
end if;
if length(dt_pvi)<>0 then
    insert into bh_bt_pkt_txt values(b_ma_dvi,b_so_id,'dt_pvi',dt_pvi);
end if;
PBH_BT_HSBS_NH(b_ma_dvi,b_so_id,b_so_hs,b_ma_dvi_ql,b_so_hd,b_tien+b_thue,
    dt_ct,dt_dk,dt_hk,dt_tba,'',dt_kbt,b_loi);
if b_loi is not null then return; end if;
PBH_BT_PKT_GOC(b_ma_dvi,b_nsd,b_so_id,b_duph,b_loi);
if b_loi is not null then return; end if;
if b_ttrang='T' and b_duph='C' then
    b_i1:=PKH_NG_CSO(sysdate);
    insert into bh_bt_pkt_duph select a.*,b_i1 from bh_bt_pkt_txt a where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BT_PKT_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(2000); b_lenh varchar2(2000); b_i1 number; b_ngay_htC number:=0; b_ma_dviC varchar2(20);
    dt_ct clob; dt_dk clob; dt_hk clob; dt_tba clob; dt_kbt clob; dt_ttt clob; dt_pvi clob;
    b_so_id number;
-- Test chung
    b_ngay_ht number; b_so_hs varchar2(30); b_ttrang varchar2(1);
    b_kieu_hs varchar2(1); b_so_hs_g varchar2(20); b_phong varchar2(10);
    b_ngay_gui number; b_ngay_mo number; b_ngay_do number; b_ngay_xr number;
    b_n_trinh varchar2(200); b_n_duyet varchar2(200); b_ngay_qd number;
    b_nt_tien varchar2(5); b_c_thue varchar2(1); b_tien number; b_thue number;
    b_noP varchar2(1); b_bphi varchar2(1); b_dung varchar2(1); b_traN varchar2(1);
-- Test rieng
    b_gcn varchar2(20); b_ma_dvi_ql varchar2(10); b_so_hd varchar2(20); b_so_id_hd number; b_so_id_dt number;
    b_ma_kh varchar2(20); b_ten nvarchar2(500); b_tienHK number; b_ma_nn varchar2(10);
    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var; dk_ma_ct pht_type.a_var;
    dk_tien_bh pht_type.a_num; dk_pt_bt pht_type.a_num; dk_t_that pht_type.a_num;
    dk_tien pht_type.a_num; dk_thue pht_type.a_num; dk_tien_qd pht_type.a_num; dk_thue_qd pht_type.a_num;
    dk_cap pht_type.a_num; dk_ma_dk pht_type.a_var; dk_ma_dkC pht_type.a_var;
    dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num; dk_lkeB pht_type.a_var; dk_luy pht_type.a_var;dk_ktru pht_type.a_var;
    hk_ma pht_type.a_var; hk_ten pht_type.a_nvar; hk_ma_nt pht_type.a_var;
    hk_tien pht_type.a_num; hk_thue pht_type.a_num; hk_tien_qd pht_type.a_num; hk_thue_qd pht_type.a_num;
    tba_ten pht_type.a_nvar; tba_ma_nt pht_type.a_var; tba_tien pht_type.a_num;
begin
-- Dan - Nhap ho so boi thuong
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_lenh:=FKH_JS_LENH('so_id,so_id_dt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_so_id_dt using b_oraIn;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_hk,dt_tba,dt_ttt,dt_pvi');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_hk,dt_tba,dt_ttt,dt_pvi using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_hk); FKH_JSa_NULL(dt_tba); FKH_JSa_NULL(dt_ttt); FKH_JSa_NULL(dt_pvi);
if b_so_id<>0 then
    select count(*) into b_i1 from bh_bt_pkt where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1=0 then b_so_id:=0; end if;
end if;
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
else
    b_loi:='loi:Ho so dang xu ly:loi';
    select ma_dvi,ngay_ht into b_ma_dviC,b_ngay_htC from bh_bt_pkt where so_id=b_so_id for update nowait;
    if sql%rowcount=0 then raise PROGRAM_ERROR; end if;
    PBH_BT_PKT_XOA_XOA(b_ma_dviC,b_nsd,b_so_id,true,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_BT_TEST(b_ma_dvi,b_nsd,b_so_id,b_ngay_htC,
    dt_ct,
    b_ngay_ht,b_so_hs,b_ttrang,b_kieu_hs,b_so_hs_g,b_phong,b_ngay_gui,b_ngay_mo,b_ngay_do,b_ngay_xr,
    b_n_trinh,b_n_duyet,b_ngay_qd,b_nt_tien,b_c_thue,b_tien,b_thue,b_noP,b_bphi,b_dung,b_traN,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_PKT_TESTr(
    b_ma_dvi,b_nsd,b_so_id_dt,
    dt_ct,dt_dk,dt_hk,dt_tba,dt_kbt,
    b_gcn,b_ma_dvi_ql,b_so_hd,b_so_id_hd,b_ma_kh,b_ten,b_tienHK,b_ma_nn,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_tien_bh,dk_pt_bt,dk_t_that,dk_tien,dk_thue,
    dk_tien_qd,dk_thue_qd,dk_cap,dk_ma_dk,dk_ma_dkC,dk_lh_nv,dk_t_suat,dk_lkeB,dk_luy,dk_ktru,
    hk_ma,hk_ten,hk_ma_nt,hk_tien,hk_thue,hk_tien_qd,hk_thue_qd,
    tba_ten,tba_ma_nt,tba_tien,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_PKT_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,
    dt_ct,dt_dk,dt_hk,dt_tba,dt_kbt,dt_ttt,dt_pvi,
-- Test chung
    b_ngay_ht,b_so_hs,b_ttrang,b_kieu_hs,b_so_hs_g,b_phong,
    b_ngay_gui,b_ngay_mo,b_ngay_do,b_ngay_xr,b_n_trinh,b_n_duyet,b_ngay_qd,
    b_nt_tien,b_c_thue,b_tien,b_thue,b_noP,b_bphi,b_dung,b_traN,
-- Test rieng
    b_gcn,b_ma_dvi_ql,b_so_hd,b_so_id_hd,b_so_id_dt,b_ma_kh,b_ten,b_tienHK,b_ma_nn,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_tien_bh,dk_pt_bt,dk_t_that,dk_tien,dk_thue,dk_tien_qd,dk_thue_qd,
    dk_cap,dk_ma_dk,dk_ma_dkC,dk_lh_nv,dk_t_suat,dk_lkeB,dk_luy,
    hk_ma,hk_ten,hk_ma_nt,hk_tien,hk_thue,hk_tien_qd,hk_thue_qd,
    tba_ten,tba_ma_nt,tba_tien,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hs' value b_so_hs) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_PKT_XOA(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Dan - Xoa GCN
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','pkt','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_BT_PKT_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,false,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_PKT_GOC(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_duph varchar2,b_loi out varchar2)
AS
    b_i1 number; b_so_id_hd number; b_so_idB number;
    b_so_id_dt number; b_ma_nt varchar2(5); b_ma_dt varchar2(10);

    b_ngay_ht number; b_nv varchar2(10); b_so_hs varchar2(30); b_ttrang varchar2(1);
    b_kieu_hs varchar2(1); b_so_hs_g varchar2(20); b_ma_dvi_ql varchar2(10); b_so_hd varchar2(20);
    b_ma_kh varchar2(20); b_ten nvarchar2(500); b_ma_khH varchar2(20); b_tenH nvarchar2(500);
    b_ngay_gui number; b_ngay_xr number; b_ngay_do number; b_n_trinh varchar2(10); b_n_duyet varchar2(10); b_ngay_qd number;
    b_noP varchar2(1); b_bphi varchar2(1); b_dung varchar2(1); b_traN varchar2(1); b_bangG varchar2(50);

    a_so_id_dt pht_type.a_num; a_ma_dt pht_type.a_var; a_ma_nt pht_type.a_var; a_lh_nv pht_type.a_var; 
    a_tien_bh pht_type.a_num; a_pt_bt pht_type.a_num; a_t_that pht_type.a_num; 
    a_tien pht_type.a_num; a_tien_qd pht_type.a_num; a_thue pht_type.a_num; a_thue_qd pht_type.a_num; 
    hk_ma pht_type.a_var; hk_ten pht_type.a_nvar; hk_ma_nt pht_type.a_var;
    hk_tien pht_type.a_num; hk_tien_qd pht_type.a_num; hk_thue pht_type.a_num; hk_thue_qd pht_type.a_num;
    tba_ten pht_type.a_nvar; tba_ma_nt pht_type.a_var; tba_tien pht_type.a_num;

begin
-- Dan - Tra ttin ho so boi thuong
b_loi:='loi:Loi lay ttin boi thuong:loi';
delete bh_bt_goc_temp1;
select ma_dvi_ql,so_id_hd,so_id_dt,nt_tien into b_ma_dvi_ql,b_so_id_hd,b_so_id_dt,b_ma_nt
    from bh_bt_pkt where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_so_idB:=FBH_pkt_SO_IDb(b_ma_dvi_ql,b_so_id_hd);
select ma_dt into b_ma_dt from bh_pkt_dvi where ma_dvi=b_ma_dvi_ql and so_id=b_so_idB and so_id_dt=b_so_id_dt;
insert into bh_bt_goc_temp1
    select lh_nv,sum(tien_bh),max(pt_bt),sum(t_that),sum(tien),sum(tien_qd),sum(thue),sum(thue_qd)
    from bh_bt_pkt_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
select 'PKT',ngay_ht,so_hs,ttrang,kieu_hs,so_hs_g,ma_dvi_ql,so_hd,ma_kh,ten,' ',' ',
    ngay_gui,ngay_xr,ngay_do,n_trinh,n_duyet,ngay_qd,nop,bphi,dung,traN,'bh_bt_pkt'
    into b_nv,b_ngay_ht,b_so_hs,b_ttrang,b_kieu_hs,b_so_hs_g,b_ma_dvi_ql,b_so_hd,b_ma_kh,b_ten,b_ma_khH,b_tenH,
    b_ngay_gui,b_ngay_xr,b_ngay_do,b_n_trinh,b_n_duyet,b_ngay_qd,b_noP,b_bphi,b_dung,b_traN,b_bangG
    from bh_bt_pkt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select b_so_id_dt,b_ma_dt,b_ma_nt,lh_nv,tien_bh,pt_bt,t_that,tien,tien_qd,thue,thue_qd bulk collect
    into a_so_id_dt,a_ma_dt,a_ma_nt,a_lh_nv,a_tien_bh,a_pt_bt,a_t_that,a_tien,a_tien_qd,a_thue,a_thue_qd
    from bh_bt_goc_temp1;
select ma,ten,ma_nt,tien,thue,tien_qd,thue_qd bulk collect
    into hk_ma,hk_ten,hk_ma_nt,hk_tien,hk_thue,hk_tien_qd,hk_thue_qd
    from bh_bt_pkt_hk where ma_dvi=b_ma_dvi and so_id=b_so_id;
select ten,ma_nt,tien bulk collect into tba_ten,tba_ma_nt,tba_tien
    from bh_bt_pkt_tba where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_goc_temp1;
PBH_BT_GOC_NH(b_ma_dvi,b_nsd,b_so_id,b_ngay_ht,b_nv,b_so_hs,b_ttrang,
    b_kieu_hs,b_so_hs_g,b_ma_dvi_ql,b_so_hd,b_ma_kh,b_ten,b_ma_khH,b_tenH,
    b_ngay_gui,b_ngay_xr,b_ngay_do,b_n_trinh,b_n_duyet,b_ngay_qd,b_noP,b_bphi,b_dung,b_traN,b_bangG,
    a_so_id_dt,a_ma_dt,a_ma_nt,a_lh_nv,a_tien_bh,a_pt_bt,a_t_that,a_tien,a_tien_qd,a_thue,a_thue_qd,
    hk_ma,hk_ten,hk_ma_nt,hk_tien,hk_tien_qd,hk_thue,hk_thue_qd,
    tba_ten,tba_ma_nt,tba_tien,b_loi,b_duph);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BT_PKT_HSBS(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_ma_dvi varchar2(10); b_so_id number; b_so_hs varchar2(50); b_so_hs_g varchar2(50);
begin
-- Nam - Liet sua doi ho so
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_so_hs_g:=PBH_BT_HS_HD_SO_HS_G(b_ma_dvi,b_so_id);
if b_so_hs_g <>' ' then
  select JSON_ARRAYAGG(json_object(so_hs,'ma_dvi' value ma_dvi_ql,so_hd,tien,'ngay' value ngay_ht,so_id,'csot' value '') order by so_id desc returning clob) into cs_lke from 
  (select so_hs,ma_dvi_ql,so_hd,tien,ngay_ht,so_id from bh_bt_pkt where ma_dvi=b_ma_dvi and so_hs=b_so_hs_g union
  select so_hs,ma_dvi_ql,so_hd,tien,ngay_ht,so_id from bh_bt_pkt where ma_dvi=b_ma_dvi and so_hs_g=b_so_hs_g);
else 
  b_so_hs:=FBH_BT_HS_SOHS(b_ma_dvi,b_so_id);
  select JSON_ARRAYAGG(json_object(so_hs,'ma_dvi' value ma_dvi_ql,so_hd,tien,'ngay' value ngay_ht,so_id,'csot' value '') order by so_id desc returning clob) into cs_lke from 
  (select so_hs,ma_dvi_ql,so_hd,tien,ngay_ht,so_id from bh_bt_pkt where ma_dvi=b_ma_dvi and so_hs=b_so_hs union
  select so_hs,ma_dvi_ql,so_hd,tien,ngay_ht,so_id from bh_bt_pkt where ma_dvi=b_ma_dvi and so_hs_g=b_so_hs);
end if;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;