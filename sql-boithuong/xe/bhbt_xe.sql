create or replace function FBH_BT_XE_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return varchar2
AS
    b_kq varchar2(100):=' '; b_i1 number; b_txt clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
select count(*) into b_i1 from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    b_kq:=FKH_JS_GTRIs(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_BT_XE_TTRANG(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra tinh trang
select nvl(min(ttrang),'X') into b_kq from bh_bt_xe where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_XE_NV(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra nghiep vu
select nvl(min(kieu_hs),'G') into b_kq from bh_bt_xe where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_XE_BTH_LKE(b_so_id_dt number) return clob
as
    dt_bth clob;
begin
-- Dan - Luy ke boi thuong GCN
select JSON_ARRAYAGG(json_object(ma,bt_lke) returning clob) into dt_bth from
    (select ma,sum(tien) bt_lke from bh_bt_xe_dk where (ma_dvi,so_id) in 
    (select ma_dvi,so_id from bh_bt_xe where so_id_dt=b_so_id_dt and ttrang='D')
    and tc='C' group by ma);
return dt_bth;
end;
/
create or replace procedure PBH_BT_XE_MO
    (b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(200); b_ngay number:=PKH_NG_CSO(sysdate);
    cs_kbt clob; cs_ttt clob;
begin
-- Dan - Lay gia tri ban dau
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt) into cs_kbt from bh_kh_ttt where ps='KBT' and nv='XE';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_ttt
    from bh_kh_ttt where ps='BT' and nv='XE';
select json_object('cs_kbt' value cs_kbt,'cs_ttt' value cs_ttt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_BT_XE_SO_HS(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(20);
begin
-- Dan - Tra so_id
select min(so_hs) into b_kq from bh_bt_xe where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_XE_SO_IDn(b_ma_dvi varchar2,b_so_hs varchar2) return number
AS
    b_kq number;
begin
-- Dan - Tra so_id
select nvl(min(so_id),0) into b_kq from bh_bt_xe where ma_dvi=b_ma_dvi and so_hs=b_so_hs;
return b_kq;
end;
/
create or replace procedure FBH_BT_XE_SO_ID(b_so_hs varchar2,b_ma_dvi out varchar2,b_so_id out number)
AS
begin
-- Dan - Tra ma_dvi, so_id
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_bt_xe where so_hs=b_so_hs;
end;
/
create or replace procedure PBH_BT_XE_SO_ID(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_hs varchar2(30):=FKH_JS_GTRIs(b_oraIn,'so_hs');
    b_ma_dvi varchar2(10); b_so_id number;
begin
-- Dan - Tra ma_dvi,so_id
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FBH_BT_XE_SO_ID(b_so_hs,b_ma_dvi,b_so_id);
if b_so_id=0 then b_loi:='loi:Ho so da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_XE_LKE_GCN
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_gcn varchar2(20):=FKH_JS_GTRIs(b_oraIn,'gcn'); 
    b_ma_dvi_ql varchar2(10); b_so_id_hd number; b_so_id_dt number;
    cs_phi clob; cs_bth clob;
begin
-- Dan - Liet ke phi va boi thuong cua 1 GCN
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FBH_XE_HD_SO_ID_DTd(b_gcn,b_ma_dvi_ql,b_so_id_hd,b_so_id_dt);
FBH_BT_LKE_PHI(b_ma_dvi_ql,b_so_id_hd,cs_phi);
select JSON_ARRAYAGG(json_object(so_hs,ngay_mo,ttrang,tien,ma_dvi,so_id) order by ngay_mo desc)
    into cs_bth from bh_bt_xe where so_id_dt=b_so_id_dt;
select json_object('cs_phi' value cs_phi,'cs_bth' value cs_bth) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_XE_GCN(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000);
    b_so_id_dt number; b_ngay_xr number; 
    b_ma_dvi varchar2(10); b_so_id number;
    dt_ct clob:=''; dt_kbt clob:=''; dt_btlke clob:=''; dt_dk clob:=''; dt_lt clob:=''; dt_txt clob:='';
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id_dt,ngay_xr');
EXECUTE IMMEDIATE b_lenh into b_so_id_dt,b_ngay_xr using b_oraIn;
FBH_XE_SO_ID_DTf(b_so_id_dt,b_ma_dvi,b_so_id,b_ngay_xr);
if b_so_id=0 then b_loi:='loi:GCN xe da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object(a.so_hd,a.ten,'ma_dvi_ql' value a.ma_dvi,b.gcn,b.tenC,
    'bien_xe' value decode(b.bien_xe,' ',b.so_khung,b.bien_xe),b.ng_huong,
    b.ngay_hl,b.ngay_kt,a.nt_tien,a.c_thue,'lhe_ten' value a.ten,'lhe_mobi' value a.mobi,'lhe_mail' value a.email) into dt_ct
    from bh_xe a,bh_xe_ds b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and
    b.ma_dvi=b_ma_dvi and b.so_id=b_so_id and b.so_id_dt=b_so_id_dt;
select dk,lt,kbt into dt_dk,dt_lt,dt_kbt from bh_xe_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
select JSON_ARRAYAGG(json_object('loai' value 'dt_dk','txt' value dt_dk returning clob) returning clob) into dt_txt from dual;
select JSON_ARRAYAGG(json_object(ma,ten,'tien_bh' value tien, 'tien' value 0,'bt' value bt) order by bt returning clob) into dt_dk
    from bh_xe_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
dt_btlke:=FBH_BT_XE_BTH_LKE(b_so_id_dt);
select json_object('so_id_dt' value b_so_id_dt,'dt_ct' value dt_ct,'dt_lt' value dt_lt,'dt_kbt' value dt_kbt,
    'dt_btlke' value dt_btlke,'dt_dk' value dt_dk,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_XE_GCNd(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma_dvi varchar2(10); b_so_id number; b_so_id_dt number; 
begin
-- Dan - Tra so_id_dt qua GCN
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','XE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FBH_XE_SO_ID_GCN(b_oraIn,b_ma_dvi,b_so_id,b_so_id_dt);
select json_object('so_id_dt' value b_so_id_dt) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_XE_LKE
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
    select count(*) into b_dong from bh_bt_xe where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hs,nsd) obj,rownum sott from bh_bt_xe where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_hs)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','BT','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_bt_xe where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hs,nsd) obj,rownum sott from bh_bt_xe  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_hs)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_bt_xe where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hs,nsd) obj,rownum sott from bh_bt_xe  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_hs)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_XE_LKE_ID
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
b_so_hs:=FBH_BT_XE_SO_HS(b_ma_dvi,b_so_id);
if b_so_hs is null then b_loi:='loi:Ho so da xoa:loi'; raise PROGRAM_ERROR; end if;
if b_klk ='N' then
    select count(*) into b_dong from bh_bt_xe where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hs,rownum sott from bh_bt_xe where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_hs)
        where so_hs>=b_so_hs;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hs,nsd) obj,rownum sott from bh_bt_xe where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_hs)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','BT','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_bt_xe where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hs,rownum sott from bh_bt_xe where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_hs)
        where so_hs>=b_so_hs;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hs,nsd) obj,rownum sott from bh_bt_xe where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_hs)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_bt_xe where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hs,rownum sott from bh_bt_xe where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_hd)
        where so_hs>=b_so_hs;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hs,nsd) obj,rownum sott from bh_bt_xe where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
CREATE OR REPLACE PROCEDURE PBH_BT_XE_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(3000); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number; b_ngay_xr number;
    b_ma_dvi_ql varchar2(10); b_so_id_hd number; b_so_id_hdB number; b_so_id_dt number;
    dt_ct clob; dt_dk clob; dt_hk clob:=''; dt_tba clob:=''; dt_lt clob:=''; dt_kbt clob:=''; dt_ttt clob:=''; dt_txt clob;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','XE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_loi:='loi:Ho so da xoa:loi';
select ma_dvi_ql,so_id_hd,so_id_dt,ngay_xr into b_ma_dvi_ql,b_so_id_hd,b_so_id_dt,b_ngay_xr
    from bh_bt_xe where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_so_id_hdB:=FBH_XE_SO_IDb(b_ma_dvi_ql,b_so_id_hd,b_ngay_xr);
select lt,kbt into dt_lt,dt_kbt from bh_xe_kbt where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB and so_id_dt=b_so_id_dt;
select json_object(so_hs,tien,tienHK,'ma_nn' value FBH_XE_NNTT_TENl(ma_nn) returning clob)
    into dt_ct from bh_bt_xe where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ma) order by bt returning clob) into dt_dk from bh_bt_xe_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(nhom,ma,ten,ma_nt,tien,thue,ttoan) order by bt returning clob) into dt_hk
    from bh_bt_xe_hk where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ten,ma_nt,tien) order by bt returning clob) into dt_tba
    from bh_bt_xe_tba where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai not in('dt_hk','dt_tba','dt_kbt');
select count(*) into b_i1 from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
if b_i1<>0 then
    select txt into dt_ttt from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_id_dt' value b_so_id_dt,
    'dt_ttt' value dt_ttt,'dt_lt' value dt_lt,'dt_kbt' value dt_kbt,'dt_ct' value dt_ct,'dt_dk' value dt_dk,
    'dt_hk' value dt_hk,'dt_tba' value dt_tba,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_XE_TESTr(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id_dt number, b_so_id number,
    dt_ct clob,dt_dk clob,dt_hk clob,dt_tba clob,dt_kbt out clob,

    b_gcn out varchar2,b_ma_dvi_ql out varchar2,b_so_hd out varchar2,b_so_id_hd out number,
    b_ma_kh out varchar2,b_ten out nvarchar2,b_tienHK out number,b_ma_nn out varchar2,
    b_bien_xe out varchar2,b_ng_huong out nvarchar2,b_xe_id out number,

    dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,
    dk_tc out pht_type.a_var,dk_ma_ct out pht_type.a_var,
    dk_tien_bh out pht_type.a_num,dk_pt_bt out pht_type.a_num,dk_t_that out pht_type.a_num,
    dk_tien out pht_type.a_num,dk_thue out pht_type.a_num,
    dk_tien_qd out pht_type.a_num,dk_thue_qd out pht_type.a_num,
    dk_cap out pht_type.a_var,dk_ma_dk out pht_type.a_var,dk_ma_bs out pht_type.a_var,
    dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,dk_nd out pht_type.a_nvar,dk_lkeB out pht_type.a_var,
    hk_nhom out pht_type.a_var,hk_ma out pht_type.a_var,hk_ten out pht_type.a_nvar,hk_ma_nt out pht_type.a_var,
    hk_tien out pht_type.a_num,hk_thue out pht_type.a_num,
    hk_tien_qd out pht_type.a_num,hk_thue_qd out pht_type.a_num,
    tba_ten out pht_type.a_nvar,tba_ma_nt out pht_type.a_var,tba_tien out pht_type.a_num,b_loi out varchar2)

AS
    b_lenh varchar2(2000); b_i1 number; b_i2 number; b_tp number:=0; b_tg number:=1;
    b_ttrang varchar2(1); b_so_id_hdB number; b_ngay_xr number; b_nt_tien varchar2(5); b_c_thue varchar2(1):='K';
    b_tienH number; b_thueH number; b_tien number; b_thue number;
    b_ma_sp varchar2(10);
    dk_bt_con pht_type.a_num;
begin
-- Dan kiem tra thong tin nhap ho so boi thuong
b_lenh:=FKH_JS_LENH('ttrang,ma_dvi_ql,so_hd,ngay_xr,nt_tien,tien,thue,ma_nn');
EXECUTE IMMEDIATE b_lenh into b_ttrang,b_ma_dvi_ql,b_so_hd,b_ngay_xr,b_nt_tien,b_tienH,b_thueH,b_ma_nn using dt_ct;
if b_ma_dvi_ql is null or b_so_hd is null then b_loi:='loi:Chon hop dong bao hiem:loi'; return; end if;
b_nt_tien:=nvl(trim(b_nt_tien),' '); b_tienH:=nvl(b_tienH,0); b_thueH:=nvl(b_thueH,0);
b_so_id_hd:=FBH_XE_SO_ID(b_ma_dvi_ql,b_so_hd);
if b_so_id_hd=0 then b_loi:='loi:Hop dong da xoa:loi'; return; end if;
if b_so_id_dt is null then b_loi:='loi:Chon GCN:loi'; return; end if;
b_so_id_hdB:=FBH_XE_SO_IDb(b_ma_dvi_ql,b_so_id_hd,b_ngay_xr);
select count(*) into b_i1 from bh_xe where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB and nt_tien=b_nt_tien;
if b_i1=0 then b_loi:='loi:Sai loai tien bao hiem, loai thue so voi hop dong:loi'; return; end if;
if b_nt_tien<>'VND' then
    b_tp:=2; b_tg:=FBH_TT_TRA_TGTT(b_ngay_xr,b_nt_tien);
end if;
select count(*) into b_i1 from bh_xe_ds where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB and
    so_id_dt=b_so_id_dt and ngay_cap<=b_ngay_xr and b_ngay_xr between ngay_hl and ngay_kt;
if b_i1 is null then b_loi:='loi:Ngay xay ra ngoai hieu luc bao hiem:loi'; return; end if;
select gcn,decode(bien_xe,' ',so_khung,bien_xe),ng_huong,xe_id,ma_sp into b_gcn,b_bien_xe,b_ng_huong,b_xe_id,b_ma_sp
    from bh_xe_ds where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB and so_id_dt=b_so_id_dt;
select so_hd,ma_kh,ten into b_so_hd,b_ma_kh,b_ten from bh_xe where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,tien_bh,pt_bt,t_that,tien,cap,ma_dk,ma_bs,lh_nv,t_suat,nd,lkeb,bt_con');
EXECUTE IMMEDIATE b_lenh bulk collect into
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_tien_bh,dk_pt_bt,dk_t_that,dk_tien,
    dk_cap,dk_ma_dk,dk_ma_bs,dk_lh_nv,dk_t_suat,dk_nd,dk_lkeB,dk_bt_con using dt_dk;
if dk_ma.count=0 then b_loi:='loi:Nhap dieu khoan:loi'; return; end if;
b_tien:=0; b_thue:=0;
for b_lp in 1..dk_ma.count loop
    dk_lh_nv(b_lp):=nvl(trim(dk_lh_nv(b_lp)),' ');
    if dk_t_suat(b_lp) is null then dk_t_suat(b_lp):=0; end if;
    if b_c_thue<>'C' then dk_thue(b_lp):=0;
    else dk_thue(b_lp):=round(dk_tien(b_lp)*dk_t_suat(b_lp)/100, b_tp);
    end if;
    if b_nt_tien='VND' then
        dk_tien_qd(b_lp):=dk_tien(b_lp); dk_thue_qd(b_lp):=dk_thue(b_lp);
    else
        dk_tien_qd(b_lp):=round(b_tg*dk_tien(b_lp),0); dk_thue_qd(b_lp):=round(b_tg*dk_thue(b_lp),0);
    end if;
    if dk_lh_nv(b_lp)<>' ' then
        b_tien:=b_tien+dk_tien(b_lp); b_thue:=b_thue+dk_thue(b_lp);
    end if;
end loop;
if b_tienH<>b_tien or b_thueH<>b_thue then
    b_loi:='loi:Chenh tong tien,thue chi tiet va ho so loi'; return;
end if;
b_tienHK:=0;
if trim(dt_hk) is null then
    PKH_MANG_KD(hk_ma_nt);
else
    b_lenh:=FKH_JS_LENH('nhom,ma,ten,ma_nt,tien,thue');
    EXECUTE IMMEDIATE b_lenh bulk collect into hk_nhom,hk_ma,hk_ten,hk_ma_nt,hk_tien,hk_thue using dt_hk;
    b_i1:=0;
    for b_lp in 1..hk_ma_nt.count loop
        if hk_ma_nt(b_lp)='VND' then
            hk_tien_qd(b_lp):=hk_tien(b_lp); hk_thue_qd(b_lp):=hk_thue(b_lp);
        else
            if hk_ma_nt(b_lp)=b_nt_tien then
                b_i2:=b_tg;
            else
                b_i2:=FBH_TT_TRA_TGTT(b_ngay_xr,hk_ma_nt(b_lp));
            end if;
            hk_tien_qd(b_lp):=round(hk_tien(b_lp)*b_i2,0); hk_thue_qd(b_lp):=round(hk_thue(b_lp)*b_i2,0);
        end if;
        b_tienHK:=b_tienHK+hk_tien(b_lp);
        if trim(hk_ma(b_lp)) is not null then
            b_i2:=PKH_LOC_CHU_SO(hk_ma(b_lp),'F','F');
            if b_i2<100000 and b_i2>b_i1 then b_i1:=b_i2; end if;
        else
            b_i1:=b_i1+1; hk_ma(b_lp):=to_char(b_i1);
        end if;
    end loop;
    if b_tien<b_tienHK then b_loi:='loi:Tien ho so nho hon tien huong khac:loi'; return; end if;
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
    if b_ttrang='D' then
        PBH_PQU_NHOM_BTHa(b_ma_dvi,b_nsd,'XE',b_ma_sp,dk_ma,dk_ten,dk_tien,b_loi);
        if b_loi is not null then return; end if;
        -- viet anh -- chan duyet bt khi chua duyet pabt
        PBH_BT_XE_PABT_DU(b_ma_dvi,b_so_id,b_loi);
        if b_loi is not null then return; end if;
    end if;
    if FBH_HD_HU(b_ma_dvi_ql,b_so_id_hd,b_ngay_xr)='C' then b_loi:='loi:Da cham dut hop dong:loi'; return; end if;
    if FBH_XE_HLd(b_ma_dvi_ql,b_so_id_hd,b_so_id_dt,b_ngay_xr)='K' then
         b_loi:='loi:Ngay xay ra ngoai ngay hieu luc:loi'; return;
    end if;
    for b_lp in 1..dk_ma.count loop
        if dk_bt_con(b_lp)<0 then
            b_loi:='loi:Dieu khoan '||dk_ma(b_lp)||' boi thuong vuot muc trach nhiem :loi'; return;
        end if;
    end loop;
    select kbt into dt_kbt from bh_xe_kbt where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB and so_id_dt=b_so_id_dt;
    dt_kbt:=FKH_JS_BONH(dt_kbt);
    PBH_BT_XE_KBT(b_ma_dvi_ql,b_so_id_hd,b_so_id_dt,dt_ct,dt_dk,dt_kbt,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_XE_TESTr:loi'; end if;
end;
/
create or replace procedure PBH_BT_XE_XOA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh boolean,b_loi out varchar2)
AS 
    b_i1 number; r_hs bh_bt_xe%rowtype;
Begin
-- Dan - Xoa boi thuong
select count(*) into b_i1 from bh_bt_xe where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select * into r_hs from bh_bt_xe where ma_dvi=b_ma_dvi and so_id=b_so_id;
if trim(r_hs.nsd) is not null and b_nsd<>r_hs.nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
PBH_BT_GOC_XOA(b_ma_dvi,b_nsd,b_so_id,b_nh,b_loi);
if b_loi is not null then return; end if;
delete bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_xe_hk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_xe_tba where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_xe_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_xe_ct where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_xe where ma_dvi=b_ma_dvi and so_id=b_so_id;
--nam: xoa du phong
delete bh_bt_xe_duph where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_XE_XOA_XOA:loi'; end if;
end;
/
create or replace procedure PBH_BT_XE_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    dt_ct clob,dt_dk clob,dt_hk clob,dt_tba clob,dt_kbt clob,dt_ttt clob,    
-- Test chung
    b_ngay_ht number,b_so_hs in out varchar2,b_ttrang varchar2,
    b_kieu_hs varchar2,b_so_hs_g varchar2,b_phong varchar2,
    b_ngay_gui number,b_ngay_mo number,b_ngay_do number,b_ngay_xr number,
    b_n_trinh varchar2,b_n_duyet varchar2,b_ngay_qd number,
    b_nt_tien varchar2,b_c_thue varchar2,b_tien number,b_thue number,
    b_noP varchar2,b_bphi varchar2,b_dung varchar2,b_traN varchar2,
-- Test rieng
    b_gcn varchar2,b_ma_dvi_ql varchar2,b_so_hd varchar2,b_so_id_hd number,b_so_id_dt number,
    b_ma_kh varchar2,b_ten nvarchar2,b_tienHK number,b_ma_nn varchar2,
    b_bien_xe varchar2,b_ng_huong nvarchar2,b_xe_id number,
    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tc pht_type.a_var,
    dk_ma_ct pht_type.a_var,dk_tien_bh pht_type.a_num,dk_pt_bt pht_type.a_num,dk_t_that pht_type.a_num,
    dk_tien pht_type.a_num,dk_thue pht_type.a_num,dk_tien_qd pht_type.a_num,dk_thue_qd pht_type.a_num,
    dk_cap pht_type.a_var,dk_ma_dk pht_type.a_var,dk_ma_bs pht_type.a_var,
    dk_lh_nv pht_type.a_var,dk_t_suat pht_type.a_num,dk_nd pht_type.a_nvar,dk_lkeB pht_type.a_var,
    hk_nhom pht_type.a_var,hk_ma pht_type.a_var,hk_ten pht_type.a_nvar,hk_ma_nt pht_type.a_var,
    hk_tien pht_type.a_num,hk_thue pht_type.a_num,hk_tien_qd pht_type.a_num,hk_thue_qd pht_type.a_num,
    tba_ten pht_type.a_nvar,tba_ma_nt pht_type.a_var,tba_tien pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_so_id_kt number:=-1; b_so_idB number; b_ma_khH varchar2(20); b_tenH nvarchar2(500):=b_ng_huong;
    b_dvi_ksoat varchar2(10):=''; b_ksoat varchar2(10):=''; b_duph varchar2(1); b_ma_dt varchar2(10);
    a_so_id_dtC pht_type.a_num; a_ma_dtC pht_type.a_var; a_ma_ntC pht_type.a_var; a_lh_nvC pht_type.a_var; 
    a_tien_bhC pht_type.a_num; a_pt_btC pht_type.a_num; a_t_thatC pht_type.a_num; 
    a_tienC pht_type.a_num; a_tien_qdC pht_type.a_num; a_thueC pht_type.a_num; a_thue_qdC pht_type.a_num; 
begin
-- Dan - Nhap boi thuong
if b_ttrang='D' then b_so_id_kt:=0; end if;
if b_ngay_qd<30000101 then b_dvi_ksoat:=b_ma_dvi; b_ksoat:=b_nsd; end if;
b_duph:=FKH_JS_GTRIs(dt_ct,'duph'); b_duph:=nvl(trim(b_duph),'K');
b_loi:='loi:Loi Table bh_bt_xe:loi';
insert into bh_bt_xe values(b_ma_dvi,b_so_id,b_ngay_ht,b_so_hs,b_ttrang,b_kieu_hs,b_so_hs_g,
    b_gcn,b_ma_dvi_ql,b_ma_dvi,b_so_id_hd,b_so_id_dt,b_so_hd,b_ma_kh,b_ten,b_ngay_gui,b_ngay_mo,b_ngay_do,b_ngay_xr,
    b_ma_nn,b_n_trinh,b_n_duyet,b_ngay_qd,b_nt_tien,b_c_thue,b_tien,b_tienHK,b_thue,b_tien+b_thue,b_noP,b_bphi,b_dung,b_traN,
    b_nsd,b_phong,b_so_id_kt,b_dvi_ksoat,b_ksoat,sysdate);
b_loi:='loi:Loi Table bh_bt_xe_ct:loi';
insert into bh_bt_xe_ct values(b_ma_dvi,b_so_id,b_bien_xe,b_ng_huong,b_xe_id);
b_loi:='loi:Loi Table bh_bt_xe_dk:loi';
for b_lp in 1..dk_ma.count loop
    insert into bh_bt_xe_dk values(b_ma_dvi,b_so_id,b_lp,
        dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),dk_cap(b_lp),
        dk_ma_dk(b_lp),dk_ma_bs(b_lp),dk_lh_nv(b_lp),dk_t_suat(b_lp),
        dk_tien(b_lp),dk_pt_bt(b_lp),dk_t_that(b_lp),dk_tien(b_lp),dk_thue(b_lp),dk_tien(b_lp)+dk_thue(b_lp),
        dk_tien_qd(b_lp),dk_thue_qd(b_lp),dk_tien_qd(b_lp)+dk_thue_qd(b_lp),dk_nd(b_lp),dk_lkeB(b_lp));
end loop;
if hk_ma_nt.count<>0 then
    b_loi:='loi:Loi Table bh_bt_xe_HK:loi';
    for b_lp in 1..hk_ma_nt.count loop
        insert into bh_bt_xe_hk values(
        b_ma_dvi,b_so_id,b_lp,hk_nhom(b_lp),hk_ma(b_lp),hk_ten(b_lp),hk_ma_nt(b_lp),
        hk_tien(b_lp),hk_thue(b_lp),hk_tien(b_lp)+hk_thue(b_lp),
        hk_tien_qd(b_lp),hk_thue_qd(b_lp),hk_tien_qd(b_lp)+hk_thue_qd(b_lp));
    end loop;
end if;
if tba_ma_nt.count<>0 then
    b_loi:='loi:Loi Table bh_bt_xe_tba:loi';
    for b_lp in 1..tba_ma_nt.count loop
        insert into bh_bt_xe_tba values(b_ma_dvi,b_so_id,b_lp,tba_ten(b_lp),tba_ma_nt(b_lp),tba_tien(b_lp));
    end loop;
end if;
insert into bh_bt_xe_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
insert into bh_bt_xe_txt values(b_ma_dvi,b_so_id,'dt_dk',dt_dk);
if dt_hk is not null then
    insert into bh_bt_xe_txt values(b_ma_dvi,b_so_id,'dt_hk',dt_hk);
end if;
if dt_tba is not null then
    insert into bh_bt_xe_txt values(b_ma_dvi,b_so_id,'dt_tba',dt_tba);
end if;
if dt_kbt is not null then
    insert into bh_bt_xe_txt values(b_ma_dvi,b_so_id,'dt_kbt',dt_kbt);
end if;
if dt_ttt is not null then
    insert into bh_bt_xe_txt values(b_ma_dvi,b_so_id,'dt_ttt',dt_ttt);
end if;
PBH_BT_HSBS_NH(b_ma_dvi,b_so_id,b_so_hs,b_ma_dvi_ql,b_so_hd,b_tien+b_thue,
    dt_ct,dt_dk,dt_hk,dt_tba,'',dt_kbt,b_loi);
if b_loi is not null then return; end if;
if b_ttrang in('T','D') then
    b_so_idB:=FBH_XE_SO_IDb(b_ma_dvi_ql,b_so_id_hd);
    select loai_xe into b_ma_dt from bh_xe_ds where ma_dvi=b_ma_dvi_ql and so_id=b_so_idB and so_id_dt=b_so_id_dt;
    select b_so_id_dt,b_ma_dt,b_nt_tien,lh_nv,tien_bh,pt_bt,t_that,tien,tien_qd,thue,thue_qd bulk collect into 
        a_so_id_dtC,a_ma_dtC,a_ma_ntC,a_lh_nvC,a_tien_bhC,a_pt_btC,a_t_thatC,a_tienC,a_tien_qdC,a_thueC,a_thue_qdC from 
        (select lh_nv,sum(tien_bh) tien_bh,max(pt_bt) pt_bt,sum(t_that) t_that,
        sum(tien) tien,sum(tien_qd) tien_qd,sum(thue) thue,sum(thue_qd) thue_qd
        from bh_bt_xe_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv);
    PBH_BT_GOC_NH(b_ma_dvi,b_nsd,b_so_id,b_ngay_ht,'XE',b_so_hs,b_ttrang,
        b_kieu_hs,b_so_hs_g,b_ma_dvi_ql,b_so_hd,b_ma_kh,b_ten,b_ma_khH,b_tenH,
        b_ngay_gui,b_ngay_xr,b_ngay_do,b_n_trinh,b_n_duyet,b_ngay_qd,b_noP,b_bphi,b_dung,b_traN,'bh_bt_xe',
        a_so_id_dtC,a_ma_dtC,a_ma_ntC,a_lh_nvC,a_tien_bhC,a_pt_btC,a_t_thatC,a_tienC,a_tien_qdC,a_thueC,a_thue_qdC,
        hk_ma,hk_ten,hk_ma_nt,hk_tien,hk_tien_qd,hk_thue,hk_thue_qd,
        tba_ten,tba_ma_nt,tba_tien,b_loi,b_duph);
    if b_loi is not null then return; end if;
end if;
if b_ttrang='T' and b_duph='C' then
    b_i1:=PKH_NG_CSO(sysdate);
    insert into bh_bt_xe_duph select a.*,b_i1 from bh_bt_xe_txt a where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_XE_NH_NH:loi'; end if;
end;
/
create or replace procedure PBH_BT_XE_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(2000); b_lenh varchar2(2000); b_i1 number; b_ngay_htC number:=0; b_ma_dviC varchar2(20);
    dt_ct clob; dt_dk clob; dt_hk clob; dt_tba clob; dt_kbt clob; dt_ttt clob;
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
    b_bien_xe varchar2(20); b_ng_huong nvarchar2(1000); b_xe_id number;
    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var; dk_ma_ct pht_type.a_var; 
    dk_tien_bh pht_type.a_num; dk_pt_bt pht_type.a_num; dk_t_that pht_type.a_num; 
    dk_tien pht_type.a_num; dk_thue pht_type.a_num; dk_tien_qd pht_type.a_num; dk_thue_qd pht_type.a_num; 
    dk_cap pht_type.a_var; dk_ma_dk pht_type.a_var; dk_ma_bs pht_type.a_var; 
    dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num; dk_nd pht_type.a_nvar;  dk_lkeB pht_type.a_var; 
    hk_nhom pht_type.a_var; hk_ma pht_type.a_var; hk_ten pht_type.a_nvar; hk_ma_nt pht_type.a_var; 
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
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_hk,dt_tba,dt_ttt');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_hk,dt_tba,dt_ttt using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_hk); FKH_JSa_NULL(dt_tba); FKH_JSa_NULL(dt_ttt);
if b_so_id<>0 then
    select count(*) into b_i1 from bh_bt_xe where so_id=b_so_id;
    if b_i1=0 then b_so_id:=0; end if;
end if;
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
else
    b_loi:='loi:Ho so dang xu ly:loi';
    -- chuclh: theo don vi hsbt
    select ma_dvi,ngay_ht into b_ma_dviC,b_ngay_htC from bh_bt_xe where so_id=b_so_id for update nowait;
    if sql%rowcount=0 then raise PROGRAM_ERROR; end if;
    PBH_BT_XE_XOA_XOA(b_ma_dviC,b_nsd,b_so_id,true,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_BT_TEST(b_ma_dvi,b_nsd,b_so_id,b_ngay_htC,dt_ct,
    b_ngay_ht,b_so_hs,b_ttrang,b_kieu_hs,b_so_hs_g,b_phong,b_ngay_gui,b_ngay_mo,b_ngay_do,b_ngay_xr,
    b_n_trinh,b_n_duyet,b_ngay_qd,b_nt_tien,b_c_thue,b_tien,b_thue,b_noP,b_bphi,b_dung,b_traN,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_XE_TESTr(
    b_ma_dvi,b_nsd,b_so_id_dt,b_so_id,
    dt_ct,dt_dk,dt_hk,dt_tba,dt_kbt,
    b_gcn,b_ma_dvi_ql,b_so_hd,b_so_id_hd,b_ma_kh,b_ten,b_tienHK,b_ma_nn,b_bien_xe,b_ng_huong,b_xe_id,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_tien_bh,dk_pt_bt,dk_t_that,dk_tien,dk_thue,
    dk_tien_qd,dk_thue_qd,dk_cap,dk_ma_dk,dk_ma_bs,dk_lh_nv,dk_t_suat,dk_nd,dk_lkeB,
    hk_nhom,hk_ma,hk_ten,hk_ma_nt,hk_tien,hk_thue,hk_tien_qd,hk_thue_qd,
    tba_ten,tba_ma_nt,tba_tien,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_XE_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,
    dt_ct,dt_dk,dt_hk,dt_tba,dt_kbt,dt_ttt,
-- Test chung
    b_ngay_ht,b_so_hs,b_ttrang,b_kieu_hs,b_so_hs_g,b_phong,
    b_ngay_gui,b_ngay_mo,b_ngay_do,b_ngay_xr,b_n_trinh,b_n_duyet,b_ngay_qd,
    b_nt_tien,b_c_thue,b_tien,b_thue,b_noP,b_bphi,b_dung,b_traN,
-- Test rieng
    b_gcn,b_ma_dvi_ql,b_so_hd,b_so_id_hd,b_so_id_dt,b_ma_kh,b_ten,b_tienHK,b_ma_nn,b_bien_xe,b_ng_huong,b_xe_id,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_tien_bh,dk_pt_bt,dk_t_that,dk_tien,dk_thue,dk_tien_qd,dk_thue_qd,
    dk_cap,dk_ma_dk,dk_ma_bs,dk_lh_nv,dk_t_suat,dk_nd,dk_lkeB,
    hk_nhom,hk_ma,hk_ten,hk_ma_nt,hk_tien,hk_thue,hk_tien_qd,hk_thue_qd,
    tba_ten,tba_ma_nt,tba_tien,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hs' value b_so_hs) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_XE_XOA(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Dan - Xoa GCN
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_BT_XE_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,false,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_XE_THPA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000);
    b_i1 number; b_i2 number; b_s varchar2(500); b_n number;
    b_so_hs varchar2(30); b_so_id number; b_bt number:=0; b_kt number;
    b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_id_dt number; b_ttrang varchar2(1);
    a_so_id pht_type.a_num; a_ma pht_type.a_var; a_ten pht_type.a_var;
    dt_dk clob; dt_btlke clob; dt_txt clob:=''; b_txt clob;
  
  --dt_dk 
  a_nd pht_type.a_nvar;a_pt_bt pht_type.a_num; a_t_that pht_type.a_num; a_tien pht_type.a_num;
  a_ktru pht_type.a_num; a_gtru pht_type.a_num; 
    
begin
-- Dan - Tong hop phuong an
delete temp_1; delete temp_2; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=nvl(FKH_JS_GTRIn(b_oraIn,'so_id'),0);
b_loi:='loi:Ho so boi thuong da xoa:loi';
select ma_dvi_ql,so_id_hd,so_id_dt,ttrang into b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_ttrang
    from bh_bt_xe where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_ttrang<>'T' then b_loi:='loi:Ho so boi thuong phai o trang thai dang trinh:loi'; raise PROGRAM_ERROR; end if;
select so_id bulk collect into a_so_id from bh_bt_xeP where ma_dvi=b_ma_dvi and so_id_bt=b_so_id and ttrang in('T','D');
if a_so_id.count=0 then b_loi:='loi:Chua co phuong an:loi'; raise PROGRAM_ERROR; end if;
if a_so_id.count=1 then
    insert into temp_2(c1,c2,n1,n2,n3,n4,n5) select ma,nd,pt_bt,t_that,tien,0,0
        from bh_bt_xe_dk where ma_dvi=b_ma_dvi and so_id=a_so_id(1);
else
    forall b_lp in 1..a_so_id.count
        insert into temp_1(c1,n1,n2,n3) select ma,pt_bt,t_that,tien
            from bh_bt_xe_dk where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
    insert into temp_2(c1,c2,n1,n2,n3,n4,n5) select c1,' ',sum(n1),sum(n2),sum(n3),0,0
        from temp_1 group by c1 having sum(n2)<>0 or sum(n3)<>0;
end if;
select distinct c1 bulk collect into a_ma from temp_2;
for r_lp in (select ma,nd,pt_bt,t_that,tien from bh_bt_xe_dk where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    if FKH_ARR_VTRI(a_ma,r_lp.ma)=0 then
        insert into temp_2(c1,c2,n1,n2,n3,n4,n5) values(r_lp.ma,r_lp.nd,r_lp.pt_bt,r_lp.t_that,r_lp.tien,0,0);
    end if;
end loop;
update temp_2 a set (c3,n10,n11)=
    (select ten,bt,tien from bh_xe_dk where ma_dvi=b_ma_dvi_hd and so_id=b_so_id_hd and so_id_dt=b_so_id_dt and ma=a.c1);
if a_so_id.count>1 then
    update temp_2 set n1=round(n3*100/n11,2) where n1<>0 and n11<>0;
end if;
-- viet anh -- lay ktru, gtru cua pabt
for r_lp in (
    select so_id from bh_bt_xep where ma_dvi=b_ma_dvi and so_id_bt=b_so_id
) loop
  select count(*) into b_i1 from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=r_lp.so_id and loai='dt_dk';
  if b_i1 <> 0 then
    select FKH_JS_BONH(txt) into b_txt from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=r_lp.so_id and loai='dt_dk';
    b_lenh:= FKH_JS_LENH('ma,nd,pt_bt,t_that,tien,ktru,gtru');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_ma,a_nd,a_pt_bt,a_t_that,a_tien,a_ktru,a_gtru using b_txt;
    for b_lp in 1..a_ma.count loop
      update temp_2 set n4 = (n4 + a_ktru(b_lp)), n5 = (n5 + a_gtru(b_lp)) where c1 = a_ma(b_lp);
    end loop;
  else
    select count(*) into b_i1 from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=r_lp.so_id and loai='dt_ct';
    if b_i1 <> 0 then
      select FKH_JS_BONH(txt) into b_txt from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=r_lp.so_id and loai='dt_ct';
      b_lenh:= FKH_JS_LENH('ma,ktr_vu,gtr_bt');
      EXECUTE IMMEDIATE b_lenh bulk collect into a_ma,a_ktru,a_gtru using b_txt;
      for b_lp in 1..a_ma.count loop
        select ma into a_ma(b_lp) from bh_bt_xe_dk where ma_dvi=b_ma_dvi and so_id=r_lp.so_id;
        update temp_2 set n4 = (n4 + a_ktru(b_lp)), n5 = (n5 + a_gtru(b_lp)) where c1 = a_ma(b_lp);
      end loop;
    end if;
  end if;
end loop;
select JSON_ARRAYAGG(json_object('ma' value c1,'ten' value c3,'tien_bh' value n11,
    'pt_bt' value n1,'t_that' value n2,'tien' value n3,'nd' value c2, 'ktru' value n4, 'gtru' value n5) order by n10 returning clob) into dt_dk from temp_2;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dk';
dt_btlke:=FBH_BT_XE_BTH_LKE(b_so_id_dt);
select json_object('dt_btlke' value dt_btlke,'dt_dk' value dt_dk,
    'txt' value dt_txt returning clob) into b_oraOut from dual;
delete temp_1; delete temp_2; commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/

create or replace procedure PBH_BT_XE_FBPHI(
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
select ma_dvi_ql,so_id_hd,so_id_dt into b_ma_dvi_hd,b_so_id_hd,b_so_id_dt from bh_bt_xe where ma_dvi=b_ma_dvi and so_id=b_so_id;
select nvl(min(so_idP),0) into b_so_idP from bh_xe_ds where ma_dvi=b_ma_dvi_hd and so_id=b_so_id_hd and so_id_dt=b_so_id_dt;
b_oraOut:=to_char(b_so_idP);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_XE_FHD(
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
select ma_dvi_ql,so_id_hd,so_id_dt into b_ma_dvi_hd,b_so_id_hd,b_so_id_dt from bh_bt_xe where ma_dvi=b_ma_dvi and so_id=b_so_id;
select json_object('ma_dvi' value b_ma_dvi_hd,'so_id' value b_so_id_hd,'so_id_dt' value b_so_id_dt) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_XE_GCNDK(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000);
    b_so_id_dt number; b_ngay_xr number;
    b_ma_dvi varchar2(10); b_so_id number;
    dt_ct clob:=''; dt_kbt clob:=''; dt_btlke clob:=''; dt_dk clob:=''; dt_lt clob:=''; dt_txt clob:='';
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id_dt,ngay_xr');
EXECUTE IMMEDIATE b_lenh into b_so_id_dt,b_ngay_xr using b_oraIn;
FBH_XE_SO_ID_DTf(b_so_id_dt,b_ma_dvi,b_so_id,b_ngay_xr);
if b_so_id=0 then b_loi:='loi:GCN xe da xoa:loi'; raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ma_ct,cap,ten,'tien_bh' value tien, 'tien' value 0,'lkeb' value lkeb,'bt' value bt) order by bt returning clob) into b_oraOut
    from bh_xe_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_XE_PABT_DU(
    b_ma_dvi varchar2,b_so_id_bt number,b_loi out varchar2)
AS
    b_ttrang varchar2(1); b_so_id_pa number; b_il number;
begin
-- viet anh - Duyet boi thuong co pabt
b_loi:='loi:Loi PBH_BT_XE_PABT_DU:loi';
select count(*) into b_il from bh_bt_xeP where ma_dvi=b_ma_dvi and so_id_bt=b_so_id_bt and ttrang<>'D';
if b_il<>0 then b_loi:='loi:chua duyet phuong an boi thuong:loi'; return; end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
