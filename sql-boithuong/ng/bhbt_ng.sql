create or replace function FBH_BT_NG_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return varchar2
AS
    b_kq varchar2(100):=' '; b_i1 number; b_txt clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
select count(*) into b_i1 from bh_bt_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_bt_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    b_kq:=FKH_JS_GTRIs(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_BT_NG_GRV_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return varchar2
AS
    b_kq varchar2(100):=' '; b_i1 number; b_txt clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
select count(*) into b_i1 from bh_bt_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_grv';
if b_i1=1 then
    select txt into b_txt from bh_bt_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_grv';
    b_kq:=FKH_JS_GTRIs(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_BT_NG_TTRANG(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra tinh trang
select nvl(min(ttrang),'X') into b_kq from bh_bt_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_NG_NV(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan - Tra nghiep vu
select min(nv) into b_kq from bh_bt_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_NG_LOAI(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(10);
begin
-- Nam - Tra loai ho so boi thuong
select min(loai_hs) into b_kq from bh_bt_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_NG_TPA(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(20);
begin
-- Dan - Tra nghiep vu
select nvl(min(tpa),' ') into b_kq from bh_bt_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_NG_SO_TPA(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(20);
begin
-- Dan - Tra nghiep vu
select nvl(min(so_tpa),' ') into b_kq from bh_bt_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_NG_BTH_LKE(b_so_id_dt number) return clob
as
    dt_bth clob;
begin
-- Dan - Luy ke boi thuong GCN, nhom
select JSON_ARRAYAGG(json_object(ma,bt_lke) returning clob) into dt_bth from
    (select ma,sum(tien) bt_lke from bh_bt_ng_dk where (ma_dvi,so_id) in
    (select ma_dvi,so_id from bh_bt_ng where so_id_dt=b_so_id_dt and ttrang='D')
    and tc='C' group by ma);
return dt_bth;
end;
/
create or replace procedure PBH_BT_NG_MO(
	b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(200); b_ngay number:=PKH_NG_CSO(sysdate);
    cs_nn clob; cs_kbt clob; cs_ttt clob; cs_tpa clob;
begin
-- Dan - Lay gia tri ban dau
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt) into cs_kbt from bh_kh_ttt where ps='KBT' and nv='NG';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_ttt
    from bh_kh_ttt where ps='BT' and nv='NG';
select JSON_ARRAYAGG(json_object(ma,ten) order by ten returning clob) into cs_tpa from
    bh_ma_gdinh where FBH_MA_GDINH_NV(ma,'NG')='C' and FBH_MA_GDINH_HAN(ma)='C';
select json_object('cs_kbt' value cs_kbt,'cs_ttt' value cs_ttt,'cs_tpa' value cs_tpa returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_BT_NG_SO_HS(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(30);
begin
-- Dan - Tra so_id
select min(so_hs) into b_kq from bh_bt_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure FBH_BT_NG_SO_ID(b_so_hs varchar2,b_ma_dvi out varchar2,b_so_id out number)
AS
begin
-- Dan - Tra ma_dvi, so_id
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_bt_ng where so_hs=b_so_hs;
end;
/
create or replace procedure PBH_BT_NG_SO_ID(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_hs varchar2(30):=FKH_JS_GTRIs(b_oraIn,'so_hs');
    b_ma_dvi varchar2(10); b_so_id number;
begin
-- Dan - Tra ma_dvi,so_id
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FBH_BT_NG_SO_ID(b_so_hs,b_ma_dvi,b_so_id);
if b_so_id=0 then b_loi:='loi:Ho so da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_NG_FBPHI(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma_dvi varchar2(10); b_so_id number;
    b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_id_dt number; b_so_idP number;
    b_nv varchar2(5); 
begin
-- Dan - Tra ma_dvi,so_id
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ho so da xoa:loi';
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_ma_dvi:=nvl(trim(b_ma_dvi),' '); b_so_id:=nvl(b_so_id,0);
select ma_dvi_ql,so_id_hd,so_id_dt,nv into b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_nv from bh_bt_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
select nvl(min(so_idp),0) into b_so_idP from bh_ng_ds where ma_dvi=b_ma_dvi_hd and so_id=b_so_id_hd and so_id_dt=b_so_id_dt;
select json_object('so_idP' value b_so_idP,'nv' value b_nv) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_NGSKU_FBPHI(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma_dvi varchar2(10); b_so_id number; b_nv varchar2(10);
    b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_id_dt number; b_so_idP number;
begin
-- Dan - Tra ma_dvi,so_id
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ho so da xoa:loi';
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_ma_dvi:=nvl(trim(b_ma_dvi),' '); b_so_id:=nvl(b_so_id,0);
select ma_dvi_ql,so_id_hd,so_id_dt,nv into b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_nv from bh_bt_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
select so_idp into b_so_idP from bh_sk_nh where ma_dvi=b_ma_dvi_hd and so_id=b_so_id_hd and so_id_nh=b_so_id_dt;
select json_object('so_idP' value b_so_idP,'nv' value b_nv) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_NGDLU_FBPHI(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma_dvi varchar2(10); b_so_id number; b_nv varchar2(10);
    b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_id_dt number; b_so_idP number;
begin
-- Dan - Tra ma_dvi,so_id
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ho so da xoa:loi';
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_ma_dvi:=nvl(trim(b_ma_dvi),' '); b_so_id:=nvl(b_so_id,0);
select ma_dvi_ql,so_id_hd,so_id_dt,nv into b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_nv from bh_bt_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
select so_idp into b_so_idP from bh_ngdl_nh where ma_dvi=b_ma_dvi_hd and so_id=b_so_id_hd and so_id_nh=b_so_id_dt;
select json_object('so_idP' value b_so_idP,'nv' value b_nv) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_NG_FHD(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma_dvi varchar2(10); b_so_id number;
    b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_id_dt number;
    b_nv varchar2(5);
begin
-- Dan - Tra ma_dvi,so_id
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ho so da xoa:loi';
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_ma_dvi:=nvl(trim(b_ma_dvi),' '); b_so_id:=nvl(b_so_id,0);
select ma_dvi_ql,so_id_hd,so_id_dt,nv into b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_nv from bh_bt_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
select json_object('ma_dvi' value b_ma_dvi_hd,'so_id' value b_so_id_hd,'so_id_dt' value b_so_id_dt,'nv' value b_nv) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_NG_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10);
    b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number; b_dsach varchar2(1); b_nv varchar2(10);
    b_dong number; cs_lke clob;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,klk,tu,den,dsach,nv');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_klk,b_tu,b_den,b_dsach,b_nv using b_oraIn;
b_dsach:=nvl(trim(b_dsach),'C');
if b_klk='N' then
    select count(*) into b_dong from bh_bt_ng where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd and dsach=b_dsach and nv like b_nv || '%';
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_hs,nsd) order by so_hs desc) into cs_lke from
        (select ma_dvi,so_id,so_hs,nsd,ROW_NUMBER() over(ORDER BY so_hd desc) sott from bh_bt_ng where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd and dsach=b_dsach and nv like b_nv || '%' order by so_hs desc)
        where sott between b_tu and b_den;
elsif b_klk='P' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_bt_ng where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong and dsach=b_dsach and nv like b_nv || '%';
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_hs,nsd) order by so_hs desc) into cs_lke from
        (select ma_dvi,so_id,so_hs,nsd,ROW_NUMBER() over(ORDER BY so_hd desc) sott from bh_bt_ng where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong and dsach=b_dsach and nv like b_nv || '%' order by so_hs desc)
        where sott between b_tu and b_den;
elsif FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','BT','X')='C' then
    select count(*) into b_dong from bh_bt_ng where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and dsach=b_dsach and nv like b_nv || '%';
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_hs,nsd) order by so_hs desc) into cs_lke from
        (select ma_dvi,so_id,so_hs,nsd,ROW_NUMBER() over(ORDER BY so_hd desc) sott from bh_bt_ng where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and dsach=b_dsach and nv like b_nv || '%' order by so_hs desc)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_NG_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10); b_so_hs varchar2(30);
    b_so_id number; b_ngay_ht number; b_klk varchar2(1); b_trangKt number;
    b_tu number; b_den number; b_dsach varchar2(1); b_nv varchar2(10);
    b_trang number; b_dong number; cs_lke clob;
begin
-- Dan - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,klk,trangkt,tu,den,dsach,nv');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_klk,b_trangKt,b_tu,b_den,b_dsach,b_nv using b_oraIn;
b_so_hs:=FBH_BT_NG_SO_HS(b_ma_dvi,b_so_id); b_dsach:=nvl(trim(b_dsach),'C');
if b_so_hs is null then b_loi:='loi:Ho so da xoa:loi'; raise PROGRAM_ERROR; end if;
if b_klk='N' then
    select count(*) into b_dong from bh_bt_ng where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd and dsach=b_dsach and nv like b_nv || '%';
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hs,ROW_NUMBER() over(ORDER BY so_hd desc) sott from bh_bt_ng where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd and dsach=b_dsach and nv like b_nv || '%' order by so_hs desc)
        where so_hs>=b_so_hs;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_hs,nsd) order by so_hs desc) into cs_lke from
        (select ma_dvi,so_id,so_hs,nsd,ROW_NUMBER() over(ORDER BY so_hd desc) sott from bh_bt_ng where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd and dsach=b_dsach and nv like b_nv || '%' order by so_hs desc)
        where sott between b_tu and b_den;
elsif b_klk='P' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_bt_ng where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong and dsach=b_dsach and nv like b_nv || '%';
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hs,ROW_NUMBER() over(ORDER BY so_hd desc) sott from bh_bt_ng where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong and dsach=b_dsach and nv like b_nv || '%' order by so_hs desc)
        where so_hs>=b_so_hs;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_hs,nsd) order by so_hs desc) into cs_lke from
        (select ma_dvi,so_id,so_hs,nsd,ROW_NUMBER() over(ORDER BY so_hd desc) sott from bh_bt_ng where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong and dsach=b_dsach and nv like b_nv || '%' order by so_hs desc)
        where sott between b_tu and b_den;
elsif FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','BT','X')='C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_bt_ng where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and dsach=b_dsach;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hs,ROW_NUMBER() over(ORDER BY so_hd desc) sott from bh_bt_ng where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and dsach=b_dsach and nv like b_nv || '%' order by so_hs desc)
        where so_hs>=b_so_hs;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_hs,nsd) order by so_hs desc) into cs_lke from
        (select ma_dvi,so_id,so_hs,nsd,ROW_NUMBER() over(ORDER BY so_hd desc) sott from bh_bt_ng where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and dsach=b_dsach and nv like b_nv || '%' order by so_hs desc)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_NG_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number; b_ngay_xr number; b_nhom varchar2(10); b_nv varchar2(10);
    b_ma_dvi_ql varchar2(10); b_so_id_hd number; b_so_id_hdB number; b_so_id_dt number;
    dt_ct clob; dt_dk clob; dt_grv clob:=''; dt_tltt clob:=''; dt_tlpt clob:=''; dt_hk clob:=''; dt_tba clob:='';
    dt_lt clob:=''; dt_kbt clob:=''; dt_ttt clob:=''; dt_nhom clob:=''; dt_cho clob:=''; dt_bvi clob:=''; dt_txt clob;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_loi:='loi:Ho so da xoa:loi';
select nv,ma_dvi_ql,so_id_hd,so_id_dt,ngay_xr into b_nv,b_ma_dvi_ql,b_so_id_hd,b_so_id_dt,b_ngay_xr
    from bh_bt_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_so_id_hdB:=FBH_NG_SO_IDb(b_ma_dvi_ql,b_so_id_hd,b_ngay_xr);
select count(*) into b_i1 from bh_ng_kbt where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB and so_id_dt=b_so_id_dt;
if b_i1=1 then
    select lt,kbt into dt_lt,dt_kbt from bh_ng_kbt where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB and so_id_dt=b_so_id_dt;
end if;
select json_object(so_hs,tien,tienHK,'tpa' value FBH_DTAC_MA_TENl(tpa),gcn,'ma_nn' value FBH_NG_NNTT_TENl(ma_nn,nv),'ma_dtri' value FBH_SK_DTRI_TENl(ma_dtri)) into dt_ct from bh_bt_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ma) order by bt) into dt_dk from bh_bt_ng_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ten) order by bt) into dt_grv from bh_bt_ng_grv where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object('ma' value ma,'ten' value ten,'muc' value muc) order by bt) into dt_tltt
    from bh_bt_ng_tttl where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ten,tien) order by bt) into dt_hk from bh_bt_ng_hk where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ten,ma_nt,tien) order by bt) into dt_tba from bh_bt_ng_tba where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt from
    bh_bt_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai not in('dt_tba','dt_kbt');
select count(*) into b_i1 from bh_bt_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_tltt';
if b_i1=1 then
    select txt into dt_tltt from bh_bt_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_tltt';
end if;
select count(*) into b_i1 from bh_bt_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_tlpt';
if b_i1=1 then
    select txt into dt_tlpt from bh_bt_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_tlpt';
end if;
select count(*) into b_i1 from bh_bt_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
if b_i1=1 then
    select txt into dt_ttt from bh_bt_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
end if;
select count(*) into b_i1 from bh_bt_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_bvi';
if b_i1=1 then
    select txt into dt_bvi from bh_bt_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_bvi';
end if;
if b_nv='SKC' then
    dt_cho:=FBH_BT_NG_CHOc(b_ma_dvi_ql,b_so_id_hdB);
elsif b_nv='SKG' then
    dt_cho:=FBH_BT_NG_CHOg(b_ma_dvi_ql,b_so_id_hdB,b_so_id_dt);
elsif b_nv='SKT' then
    dt_cho:=FBH_BT_NG_CHOt(b_ma_dvi_ql,b_so_id_hdB,b_so_id_dt);
end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,
    'dt_nhom' value dt_nhom,'dt_ttt' value dt_ttt,'dt_lt' value dt_lt,'dt_kbt' value dt_kbt,
    'dt_tltt' value dt_tltt,'dt_tba' value dt_tba,
    'dt_tlpt' value dt_tlpt,'dt_cho' value dt_cho,'dt_bvi' value dt_bvi,
    'dt_ct' value dt_ct,'dt_dk' value dt_dk,'dt_grv' value dt_grv,
    'dt_hk' value dt_hk,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_NG_XOA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh boolean,b_loi out varchar2)
AS
    b_i1 number; r_hs bh_bt_ng%rowtype;
Begin
-- Dan - Xoa boi thuong
select count(*) into b_i1 from bh_bt_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
b_loi:='loi:Loi xoa ho so:loi';
select * into r_hs from bh_bt_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
if trim(r_hs.nsd) is not null and b_nsd<>r_hs.nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
PBH_BT_GOC_XOA(b_ma_dvi,b_nsd,b_so_id,b_nh,b_loi);
if b_loi is not null then return; end if;
delete bh_bt_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_ng_xl where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_ng_tttl where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_ng_grv where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_ng_hk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_ng_tba where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_ng_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
--nam: xoa du phong
delete bh_bt_ng_duph where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BT_NG_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    dt_ct clob,dt_dk clob,dt_grv clob,dt_hk clob,dt_tba clob,dt_kbt clob,dt_tltt clob,
    dt_tlpt clob,dt_ttt clob,dt_bvi clob,
    
    b_ngay_ht number,b_nv varchar2,b_so_hs varchar2,b_ttrang varchar2,
    b_kieu_hs varchar2,b_so_hs_g varchar2,b_loai_hs varchar2,b_dsach varchar2,b_phong varchar2,
    b_ngay_gui number,b_ngay_mo number,b_ngay_do number,b_ngay_xr number,
    b_n_trinh varchar2,b_n_duyet varchar2,b_ngay_qd number,
    b_nt_tien varchar2,b_c_thue varchar2,b_tien number,b_thue number,
    b_noP varchar2,b_bphi varchar2,b_dung varchar2,b_traN varchar2,
    b_gcn varchar2,b_ma_dvi_ql varchar2,b_so_hd varchar2,b_so_id_hd number,b_so_id_dt number,
    b_ma_khH varchar2,b_tenH nvarchar2,b_ma_kh varchar2,b_ten nvarchar2,b_tienHK number,
    b_ma_nn varchar2,b_ma_dtri varchar2,b_tpa varchar2,b_so_tpa varchar2,

    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tc pht_type.a_var,dk_ma_ct pht_type.a_var,
    dk_tien_bh pht_type.a_num,dk_pt_bt pht_type.a_num,dk_t_that pht_type.a_num,
    dk_tien pht_type.a_num,dk_thue pht_type.a_num,dk_tien_qd pht_type.a_num,dk_thue_qd pht_type.a_num,
    dk_cap pht_type.a_var,dk_ma_dk pht_type.a_var,dk_ma_bs pht_type.a_var,
    dk_lh_nv pht_type.a_var,dk_t_suat pht_type.a_num,dk_lkeB pht_type.a_var,

    grv_ma pht_type.a_var,grv_ten pht_type.a_nvar,grv_so pht_type.a_var,grv_ng_cap pht_type.a_num,grv_tien pht_type.a_num,
    hk_ma pht_type.a_var,hk_ten pht_type.a_nvar,hk_ma_nt pht_type.a_var,
    hk_tien pht_type.a_num,hk_thue pht_type.a_num,hk_tien_qd pht_type.a_num,hk_thue_qd pht_type.a_num,
    tba_ten pht_type.a_nvar,tba_ma_nt pht_type.a_var,tba_tien pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_so_id_kt number:=-1; b_dvi_ksoat varchar2(10):=''; b_ksoat varchar2(10):=''; b_duph varchar2(1); b_tpaN varchar2(20);
begin
-- Dan - Nhap boi thuong
if b_ttrang='D' then b_so_id_kt:=0; end if;
if b_ngay_qd<30000101 then b_dvi_ksoat:=b_ma_dvi; b_ksoat:=b_nsd; end if;
b_duph:=FKH_JS_GTRIs(dt_ct,'duph'); b_duph:=nvl(trim(b_duph),'K');
b_loi:='loi:Loi Table bh_bt_ng:loi';
b_tpaN:=PKH_MA_TENl(b_tpa);
insert into bh_bt_ng values(b_ma_dvi,b_so_id,b_ngay_ht,b_nv,b_so_hs,b_ttrang,b_kieu_hs,b_so_hs_g,b_loai_hs,b_dsach,
    b_gcn,b_ma_dvi_ql,b_ma_dvi,b_so_id_hd,b_so_id_dt,b_so_hd,b_ma_khH,b_tenH,b_ma_kh,b_ten,
    b_ngay_gui,b_ngay_mo,b_ngay_do,b_ngay_xr,b_ma_nn,b_ma_dtri,b_n_trinh,b_n_duyet,b_ngay_qd,b_nt_tien,
    b_c_thue,b_tien,b_tienHK,b_thue,b_tien+b_thue,b_tpaN,b_so_tpa,b_noP,b_bphi,b_dung,b_traN,
    b_nsd,b_phong,b_so_id_kt,b_dvi_ksoat,b_ksoat,sysdate);
b_loi:='loi:Loi Table bh_bt_ng_DK:loi';
for b_lp in 1..dk_ma.count loop
    insert into bh_bt_ng_dk values(b_ma_dvi,b_so_id,b_lp,
        dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),dk_cap(b_lp),
        dk_ma_dk(b_lp),dk_ma_bs(b_lp),dk_lh_nv(b_lp),dk_t_suat(b_lp),
        dk_tien_bh(b_lp),dk_pt_bt(b_lp),dk_t_that(b_lp),dk_tien(b_lp),dk_thue(b_lp),dk_tien(b_lp)+dk_thue(b_lp),
        dk_tien_qd(b_lp),dk_thue_qd(b_lp),dk_tien_qd(b_lp)+dk_thue_qd(b_lp),dk_lkeB(b_lp));
end loop;
b_loi:='loi:Loi Table bh_bt_ng_GRV:loi';
for b_lp in 1..grv_ten.count loop
    insert into bh_bt_ng_grv values(b_ma_dvi,b_so_id,b_lp,grv_ma(b_lp),grv_ten(b_lp),
    grv_so(b_lp),grv_ng_cap(b_lp),grv_tien(b_lp),0,grv_tien(b_lp));
end loop;
if hk_ma_nt.count<>0 then
    b_loi:='loi:Loi Table bh_bt_ng_HK:loi';
    for b_lp in 1..hk_ma_nt.count loop
        insert into bh_bt_ng_hk values(
        b_ma_dvi,b_so_id,b_lp,hk_ma(b_lp),hk_ten(b_lp),hk_ma_nt(b_lp),
        hk_tien(b_lp),hk_thue(b_lp),hk_tien(b_lp)+hk_thue(b_lp),
        hk_tien_qd(b_lp),hk_thue_qd(b_lp),hk_tien_qd(b_lp)+hk_thue_qd(b_lp));
    end loop;
end if;
if tba_ma_nt.count<>0 then
    b_loi:='loi:Loi Table bh_bt_ng_tba:loi';
    for b_lp in 1..tba_ma_nt.count loop
        insert into bh_bt_ng_tba values(b_ma_dvi,b_so_id,b_lp,tba_ten(b_lp),tba_ma_nt(b_lp),tba_tien(b_lp));
    end loop;
end if;
insert into bh_bt_ng_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
insert into bh_bt_ng_txt values(b_ma_dvi,b_so_id,'dt_dk',dt_dk);
if dt_grv is not null then
    insert into bh_bt_ng_txt values(b_ma_dvi,b_so_id,'dt_grv',dt_grv);
end if;
if dt_hk is not null then
    insert into bh_bt_ng_txt values(b_ma_dvi,b_so_id,'dt_hk',dt_hk);
end if;
if dt_tba is not null then
    insert into bh_bt_ng_txt values(b_ma_dvi,b_so_id,'dt_tba',dt_tba);
end if;
if dt_kbt is not null then
    insert into bh_bt_ng_txt values(b_ma_dvi,b_so_id,'dt_kbt',dt_kbt);
end if;
if dt_tltt is not null then
    insert into bh_bt_ng_txt values(b_ma_dvi,b_so_id,'dt_tltt',dt_tltt);
end if;
if dt_tlpt is not null then
    insert into bh_bt_ng_txt values(b_ma_dvi,b_so_id,'dt_tlpt',dt_tlpt);
end if;
if dt_ttt is not null then
    insert into bh_bt_ng_txt values(b_ma_dvi,b_so_id,'dt_ttt',dt_ttt);
end if;
if dt_bvi is not null then
    insert into bh_bt_ng_txt values(b_ma_dvi,b_so_id,'dt_bvi',dt_bvi);
end if;
PBH_BT_HSBS_NH(b_ma_dvi,b_so_id,b_so_hs,b_ma_dvi_ql,b_so_hd,b_tien+b_thue,
    dt_ct,dt_dk,dt_hk,dt_tba,'',dt_kbt,b_loi);
if b_loi is not null then return; end if;
PBH_BT_NG_GOC(b_ma_dvi,b_nsd,b_so_id,b_duph,b_loi);
if b_loi is not null then return; end if;
if b_ttrang='T' and b_duph='C' then
    b_i1:=PKH_NG_CSO(sysdate);
    insert into bh_bt_ng_duph select a.*,b_i1 from bh_bt_ng_txt a where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BT_NG_XOA(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Dan - Xoa GCN
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_BT_NG_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,false,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_NG_GOC(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_duph varchar2,b_loi out varchar2)
AS
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

    b_i1 number; b_so_id_hd number; b_so_idB number;
    b_so_id_dt number; b_ma_nt varchar2(5); b_ma_dt varchar2(10);
begin
-- Dan - Tra ttin ho so boi thuong
b_loi:='loi:Loi xu ly PBH_BT_NG_GOC:loi';
delete bh_bt_goc_temp1;
select ma_dvi_ql,so_id_hd,so_id_dt,nt_tien into b_ma_dvi_ql,b_so_id_hd,b_so_id_dt,b_ma_nt
    from bh_bt_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_so_idB:=FBH_NG_SO_IDb(b_ma_dvi_ql,b_so_id_hd);
select nvl(min(nghe),' ') into b_ma_dt from bh_ng_ds where ma_dvi=b_ma_dvi_ql and so_id=b_so_idB and so_id_dt=b_so_id_dt;
insert into bh_bt_goc_temp1
    select lh_nv,sum(tien_bh),max(pt_bt),sum(t_that),sum(tien),sum(tien_qd),sum(thue),sum(thue_qd)
    from bh_bt_ng_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
select 'NG',ngay_ht,so_hs,ttrang,kieu_hs,so_hs_g,ma_dvi_ql,so_hd,ma_kh,ten,' ',' ',
    ngay_gui,ngay_xr,ngay_do,n_trinh,n_duyet,ngay_qd,nop,bphi,dung,traN,'bh_bt_ng'
    into b_nv,b_ngay_ht,b_so_hs,b_ttrang,b_kieu_hs,b_so_hs_g,b_ma_dvi_ql,b_so_hd,b_ma_kh,b_ten,b_ma_khH,b_tenH,
    b_ngay_gui,b_ngay_xr,b_ngay_do,b_n_trinh,b_n_duyet,b_ngay_qd,b_noP,b_bphi,b_dung,b_traN,b_bangG
    from bh_bt_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
select b_so_id_dt,b_ma_dt,b_ma_nt,lh_nv,tien_bh,pt_bt,t_that,tien,tien_qd,thue,thue_qd bulk collect
    into a_so_id_dt,a_ma_dt,a_ma_nt,a_lh_nv,a_tien_bh,a_pt_bt,a_t_that,a_tien,a_tien_qd,a_thue,a_thue_qd
    from bh_bt_goc_temp1;
select ma,ten,ma_nt,tien,thue,tien_qd,thue_qd bulk collect
    into hk_ma,hk_ten,hk_ma_nt,hk_tien,hk_thue,hk_tien_qd,hk_thue_qd
    from bh_bt_ng_hk where ma_dvi=b_ma_dvi and so_id=b_so_id;
select ten,ma_nt,tien bulk collect into tba_ten,tba_ma_nt,tba_tien
    from bh_bt_ng_tba where ma_dvi=b_ma_dvi and so_id=b_so_id;
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
create or replace procedure PBH_BT_NG_HSBS(
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
  (select so_hs,ma_dvi_ql,so_hd,tien,ngay_ht,so_id from bh_bt_ng where ma_dvi=b_ma_dvi and so_hs=b_so_hs_g union
  select so_hs,ma_dvi_ql,so_hd,tien,ngay_ht,so_id from bh_bt_ng where ma_dvi=b_ma_dvi and so_hs_g=b_so_hs_g);
else 
  b_so_hs:=FBH_BT_HS_SOHS(b_ma_dvi,b_so_id);
  select JSON_ARRAYAGG(json_object(so_hs,'ma_dvi' value ma_dvi_ql,so_hd,tien,'ngay' value ngay_ht,so_id,'csot' value '') order by so_id desc returning clob) into cs_lke from 
  (select so_hs,ma_dvi_ql,so_hd,tien,ngay_ht,so_id from bh_bt_ng where ma_dvi=b_ma_dvi and so_hs=b_so_hs union
  select so_hs,ma_dvi_ql,so_hd,tien,ngay_ht,so_id from bh_bt_ng where ma_dvi=b_ma_dvi and so_hs_g=b_so_hs);
end if;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_BT_NG_LUONG(
  b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return number
AS
    b_kq number:=0; b_i1 number; b_luongQ number; b_luongN number; b_i2 number;
begin
-- chuclh Uu tien luong ke khai
select luong into b_kq from bh_sk_ds t where t.ma_dvi=b_ma_dvi and t.so_id=b_so_id and t.so_id_dt=b_so_id_dt;
if b_kq > 0 then return b_kq; end if;
select count(1) into b_i1 from bh_sk_nh t,bh_sk_ds t1 where t.ma_dvi=t1.ma_dvi and t.so_id=t1.so_id and t.nhom=t1.nhom
                                                      and t.ma_dvi=b_ma_dvi and t.so_id=b_so_id;
if b_i1 <=0 then return 0; end if;
-- luong: tong quy luong - tong so nhan vien ke khai luong / so nguoi khong ke khai luong
select t.luong,sum(t1.luong) into b_luongQ,b_luongN from bh_sk_nh t,bh_sk_ds t1
                                                    where t.ma_dvi=t1.ma_dvi and t.so_id=t1.so_id and t.nhom=t1.nhom
                                                    and t.ma_dvi=b_ma_dvi and t.so_id=b_so_id group by t.luong;
select count(1) into b_i1 from bh_sk_ds t1 where t1.ma_dvi=b_ma_dvi and t1.so_id=b_so_id and luong=0;
b_kq:=ROUND(b_luongQ-b_luongN/b_i1,0);
if b_kq < 0 then b_kq:=0; end if;
return b_kq;
end;
/
create or replace procedure PBH_BT_NG_TPA_NH(
  b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
as
  b_lenh varchar2(2000);
  b_oraIn_arr pht_type.a_clob; b_kq_nh clob; dt_ct clob; b_gcn varchar2(20);
begin
--nampb: import hs TPA
delete temp_4;
b_lenh:=FKH_JS_LENHc('');
EXECUTE IMMEDIATE b_lenh bulk collect into b_oraIn_arr using b_oraIn;
for b_lp in 1..b_oraIn_arr.count loop
    begin
      b_kq_nh:='';
      PBH_BT_NG_NH(b_ma_dvi,b_nsd,b_pas,b_oraIn_arr(b_lp),b_kq_nh);
      exception when others then
        begin
          b_lenh := FKH_JS_LENHc('dt_ct');
          EXECUTE IMMEDIATE b_lenh into dt_ct using b_oraIn_arr(b_lp);
          b_gcn := FKH_JS_GTRIs(dt_ct, 'gcn');
          b_kq_nh := json_object(
            'gcn' value b_gcn,
            'loi' value SUBSTR(sqlerrm, INSTR(sqlerrm, ':') + 1)
          );
          insert into temp_4(c11, c12, c13) VALUES (b_kq_nh,'DS', 'Loi trang thai dang soan'); commit;
          PKH_JS_THAY(dt_ct, 'ttrang', 'S');
          PKH_JS_THAY(b_oraIn_arr(b_lp), 'dt_ct', dt_ct);
          b_kq_nh := '';
          PBH_BT_NG_NH(b_ma_dvi, b_nsd, b_pas, b_oraIn_arr(b_lp), b_kq_nh);
        exception when others then
          b_kq_nh := json_object(
            'gcn' value b_gcn,
            'loi' value SUBSTR(sqlerrm, INSTR(sqlerrm, ':') + 1)
          );
          insert into temp_4(c11, c12, c13) VALUES (b_kq_nh,'DD', 'Loi trang thai dang da duyet'); commit;
        end;
    end;
end loop;
select JSON_ARRAY(
         JSON_object('loai' value 'DS','data' value (select nvl(JSON_ARRAYAGG(c11 FORMAT JSON returning clob),'[]' )
             from temp_4 where c12 = 'DS') returning clob),
         JSON_object('loai' value 'DD','data' value (select nvl(JSON_ARRAYAGG(c11 FORMAT JSON returning clob),'[]' )
             from temp_4 where c12 = 'DD') returning clob) returning clob) into b_oraOut from dual;
delete temp_4; commit;
exception when others then raise_application_error(-20099, 'loi xu ly: ' || sqlerrm);
end;


