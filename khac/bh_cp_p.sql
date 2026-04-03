create or replace function FBH_CP_TKE_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_cp_tke where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_CP_TKE_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_cp_tke where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_CP_TKE_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_cp_tke where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_CP_TKE_LOAI(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan
select nvl(min(loai),' ') into b_kq from bh_cp_tke where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_CP_TKE_LKE(
     b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_cp_tke;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select * from bh_cp_tke order by ma))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_cp_tke where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(a.*,'xep' value ma) obj from bh_cp_tke a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_CP_TKE_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_cp_tke;
select nvl(min(sott),0) into b_tu from (select ma,rownum sott from bh_cp_tke order by ma) where ma>=b_ma;
PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(ma,ten,nsd) order by ma returning clob) into cs_lke from
    (select ma,ten,nsd,rownum sott from bh_cp_tke order by ma)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_CP_TKE_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_ct clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,loai,ngay_kt) into cs_ct from bh_cp_tke where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_CP_TKE_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_loai varchar2(1); b_ten nvarchar2(500); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','2B','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,loai,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_loai,b_ngay_kt using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
b_loai:=nvl(trim(b_loai),'C');
if b_loai<>'C' then b_loai:='T'; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_cp_tke where ma=b_ma;
insert into bh_cp_tke values(b_ma_dvi,b_ma,b_ten,b_loai,b_ngay_kt,b_nsd);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_CP_TKE_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','2B','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_cp_tke where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** Chi phi khac ***/
create or replace function FBH_CP_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_txt clob;
begin
-- Dan
select count(*) into b_i1 from bh_cp_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_cp_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    b_kq:=FKH_JS_GTRIu(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_CP_SO_ID(b_ma_dvi varchar2,b_so_ct varchar2) return number
AS
    b_kq number;
begin
-- Dan - Tra so ID
select nvl(min(so_id),0) into b_kq from bh_cp where ma_dvi=b_ma_dvi and so_ct=b_so_ct;
return b_kq;
end;
/
create or replace procedure PBH_CP_DON(b_ma_dvi varchar2,b_so_id number,b_nv varchar2,b_loi out varchar2)
AS
    b_i1 number; b_kt number; r_hd bh_cp%rowtype;
    a_gcn_m pht_type.a_var; a_gcn_c pht_type.a_var; a_gcn_s pht_type.a_var;
begin 
-- Dan - Phat hanh hoa don
b_loi:=''; b_kt:=0;
select * into r_hd from bh_cp where ma_dvi=b_ma_dvi and so_id=b_so_id;
if r_hd.l_ct='T' and r_hd.tien>0 and trim(r_hd.so_don) is not null then
    b_kt:=b_kt+1;
    a_gcn_m(b_kt):=' '; a_gcn_c(b_kt):=' '; a_gcn_s(b_kt):=r_hd.so_don;
    PHD_PH_DON(b_ma_dvi,b_nv,r_hd.ngay_ht,b_so_id,a_gcn_m,a_gcn_c,a_gcn_s,r_hd.nsd,'',b_loi);
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_CP_PT(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_so_hd varchar2(50); b_so_hs varchar2(50); b_so_id_bt number:=0; b_so_id_hd number;
    b_ngay_ht number; b_l_ct varchar2(1); b_nv varchar2(10); b_ma_tke varchar2(10); b_ma_nt varchar2(5);
    b_tien number; b_tien_qd number; b_thue number; b_thue_qd number;
    a_so_id_dt pht_type.a_num; a_lh_nv pht_type.a_var; a_tien pht_type.a_num;
    a_tien_qd pht_type.a_num; a_thue pht_type.a_num; a_thue_qd pht_type.a_num;
Begin
-- Dan - Phan tich
select so_hs,so_hd,ma_nt,tien,tien_qd,thue,thue_qd,ngay_ht,l_ct,nv,ma_tke
    into b_so_hs,b_so_hd,b_ma_nt,b_tien,b_tien_qd,b_thue,b_thue_qd,b_ngay_ht,b_l_ct,b_nv,b_ma_tke
    from bh_cp where ma_dvi=b_ma_dvi and so_id=b_so_id;
if trim(b_so_hs) is null and trim(b_so_hd) is null then
    insert into bh_cp_pt values(b_ma_dvi,b_so_id,0,0,0,b_ngay_ht,
        b_l_ct,b_nv,b_ma_tke,' ',b_ma_nt,b_tien,b_tien_qd,b_thue,b_thue_qd);
    b_loi:=''; return;
end if;
if trim(b_so_hs) is not null then
    b_so_id_bt:=PBH_BT_HS_SOID(b_ma_dvi,b_so_hs);
    if b_so_id_bt=0 then b_loi:='loi:Ho so boi thuong da xoa:loi'; return; end if;
    PBH_BT_HS_PT(b_ma_dvi,b_so_id_bt,b_ngay_ht,b_ma_nt,b_tien,b_tien_qd,b_thue,b_thue_qd,
        a_so_id_dt,a_lh_nv,a_tien,a_tien_qd,a_thue,a_thue_qd,b_loi);
    if b_loi is not null then return; end if;
    b_so_id_hd:=PBH_BT_HS_HD_SO_ID(b_ma_dvi,b_so_id_bt);
else
    b_so_id_hd:=FBH_HD_GOC_SO_ID(b_ma_dvi,b_so_hd);
    if b_so_id_hd=0 then b_loi:='loi:Hop dong da xoa:loi'; return; end if;
    PBH_HD_PT(b_ma_dvi,b_so_id_hd,b_ngay_ht,b_ma_nt,b_tien,b_tien_qd,b_thue,b_thue_qd,
        a_so_id_dt,a_lh_nv,a_tien,a_tien_qd,a_thue,a_thue_qd,b_loi);
    if b_loi is not null then return; end if;
end if;
forall b_lp in 1..a_so_id_dt.count
    insert into bh_cp_pt values(b_ma_dvi,b_so_id,b_so_id_bt,b_so_id_hd,a_so_id_dt(b_lp),b_ngay_ht,
        b_l_ct,b_nv,b_ma_tke,a_lh_nv(b_lp),b_ma_nt,a_tien(b_lp),a_tien_qd(b_lp),a_thue(b_lp),a_thue_qd(b_lp));
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_CP_PT:loi'; end if;
end;
/
/*** Chi phi ***/
create or replace procedure PBH_CP_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number; b_so_ct varchar2(20):=trim(b_oraIn);
begin
-- Dan - Hoi so ID qua so hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KH','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FBH_CP_SO_ID(b_ma_dvi,b_so_ct);
if b_so_id=0 then b_loi:='loi:So thu, chi khac da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_CP_SO_HD(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_so_hd varchar2(20):=trim(b_oraIn);
begin
-- Dan - Kiem tra so HD
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KH','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if FBH_HD_GOC_SO_IDd(b_ma_dvi,b_so_hd)=0 then
    b_loi:='loi:So hop dong da xoa hoac chua duyet:loi'; raise PROGRAM_ERROR;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_CP_SO_HS(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_so_hs varchar2(20):=trim(b_oraIn);
begin
-- Dan - Kiem tra so HS
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KH','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if PBH_BT_HS_SOID(b_ma_dvi,b_so_hs)=0 then
    b_loi:='loi:So ho so boi thuong da xoa:loi'; raise PROGRAM_ERROR;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_CP_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10);
    b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number;
    b_dong number; cs_lke clob;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KH','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_cp where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(so_id,l_ct,so_ct,ttoan) order by sott returning clob) into cs_lke from
        (select so_id,l_ct,so_ct,ttoan,row_number() over (order by so_id desc) as sott from bh_cp where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc)
        where sott between b_tu and b_den;
elsif b_klk='P' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_cp where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(so_id,l_ct,so_ct,ttoan) order by sott returning clob) into cs_lke from
        (select so_id,l_ct,so_ct,ttoan,row_number() over (order by so_id desc) as sott from bh_cp where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id desc)
        where sott between b_tu and b_den;
elsif FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','KH','X')='C' then
    select count(*) into b_dong from bh_cp where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(so_id,l_ct,so_ct,ttoan) order by sott returning clob) into cs_lke from
        (select so_id,l_ct,so_ct,ttoan,row_number() over (order by so_id desc) as sott from bh_cp where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id desc)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_CP_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10); b_so_hd varchar2(20);
    b_so_id number; b_ngay_ht number; b_klk varchar2(1); b_trangKt number; b_tu number; b_den number;
    b_trang number; b_dong number; cs_lke clob;
begin
-- Dan - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KH','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_klk,b_trangKt using b_oraIn;
if b_klk ='N' then
    select count(*) into b_dong from bh_cp where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_id,row_number() over (order by so_id desc) as sott from bh_cp where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id)
        where so_id>=b_so_id;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id,l_ct,so_ct,ttoan) order by sott returning clob) into cs_lke from
        (select so_id,l_ct,so_ct,ttoan,row_number() over (order by so_id desc) as sott from bh_cp  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id)
        where sott between b_tu and b_den;
elsif b_klk='P' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_cp where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_id,row_number() over (order by so_id desc) as sott from bh_cp where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id)
        where so_id>=b_so_id;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id,l_ct,so_ct,ttoan) order by sott returning clob) into cs_lke from
        (select so_id,l_ct,so_ct,ttoan,row_number() over (order by so_id desc) as sott from bh_cp  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id)
        where sott between b_tu and b_den;
elsif FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','KH','X')='C' then
    select count(*) into b_dong from bh_cp where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_id,row_number() over (order by so_id desc) as sott from bh_cp where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id)
        where so_id>=b_so_id;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id,l_ct,so_ct,ttoan) order by sott returning clob) into cs_lke from
        (select so_id,l_ct,so_ct,ttoan,row_number() over (order by so_id desc) as sott from bh_cp  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_CP_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number:=PKH_LOC_CHU_SO(trim(b_oraIn));
    dt_ct clob; dt_txt clob;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KH','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(so_ct,'ma_tke' value FBH_CP_TKE_TENl(ma_tke))) into dt_ct
    from bh_cp where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_cp_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
select json_object('so_id' value b_so_id,'dt_ct' value dt_ct,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_CP_TEST
    (b_ma_dvi varchar2,b_so_id number,dt_ct in out clob,
    b_ngay_ht out number,b_l_ct out varchar2,b_so_ct out varchar2,
    b_nv out varchar2,b_ma_tke out varchar2,b_so_don out varchar2,
    b_so_hd out varchar2,b_so_hs out varchar2,b_so_id_hd out number,b_so_id_hs out number,
    b_c_thue out varchar2,b_t_suat out number,b_ma_nt out varchar2,b_tien out number,
    b_tien_qd out number,b_thue out number,b_thue_qd out number,
    b_ma_thue out varchar2,b_ten out nvarchar2,b_dchi out nvarchar2,b_nd out nvarchar2,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_i1 number;
begin
-- Dan - Kiem tra thong tin nhap chi phi khac
b_lenh:=FKH_JS_LENH('ngay_ht,l_ct,so_ct,nv,ma_tke,so_don,so_hd,so_hs,c_thue,t_suat,ma_nt,tien,thue,ma_thue,ten,dchi,nd');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_l_ct,b_so_ct,b_nv,b_ma_tke,b_so_don,b_so_hd,b_so_hs,
    b_c_thue,b_t_suat,b_ma_nt,b_tien,b_thue,b_ma_thue,b_ten,b_dchi,b_nd using dt_ct;
b_c_thue:=nvl(trim(b_c_thue),'C'); b_ma_nt:=nvl(trim(b_ma_nt),'VND');
if b_l_ct not in ('T','C') or b_tien<=0 or b_t_suat<0 or b_thue<0 then
    b_loi:='loi:So lieu nhap sai:loi'; return;
end if;
if b_ma_tke=' ' then
    b_loi:='loi:Chon ma thong ke:loi'; return;
elsif FBH_CP_TKE_HAN(b_ma_tke)<>'C' then b_loi:='loi:Sai ma thong ke:loi'; return;
elsif FBH_CP_TKE_LOAI(b_ma_tke)<>b_l_ct then b_loi:='loi:Sai loai ma thong ke:loi'; return;
end if;
if b_so_hd=' ' then 
    b_so_id_hd:=0;
else
    b_so_id_hd:=FBH_HD_GOC_SO_ID(b_ma_dvi,b_so_hd);
    if b_so_id_hd=0 then b_loi:='loi:So hop dong chua nhap:loi'; return; end if;
end if;
if b_so_hs=' ' then 
    b_so_id_hs:=0;
else
    b_so_id_hs:=PBH_BT_HS_SOID(b_ma_dvi,b_so_hs);
    if b_so_id_hs=0 then b_loi:='loi:So ho so chua nhap:loi'; return; end if;
end if;
if b_ma_nt='VND' then
    b_tien_qd:=b_tien; b_thue_qd:=b_thue;
else
    if FBH_TT_KTRA(b_ma_nt)<>'C' then b_loi:='loi:Sai loai tien:loi'; return; end if;
    b_i1:=FBH_TT_TRA_TGTT(b_ngay_ht,b_ma_nt);
    b_tien_qd:=round(b_tien*b_i1,0); b_thue_qd:=round(b_thue*b_i1,0);
end if;
if trim(b_so_ct) is null then
    b_so_ct:=substr(to_char(b_so_id),3); PKH_JS_THAY(dt_ct,'so_ct',b_so_ct);
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_CP_XOA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2)
AS
    r_hd bh_cp%rowtype; b_so_id_hd number;
begin
-- Dan - Xoa chi phi
b_loi:='loi:Chung tu dang xu ly:loi';
select * into r_hd from bh_cp where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nsd<>r_hd.nsd then b_loi:='loi:Khong xoa chung tu nguoi khac:loi'; return; end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,r_hd.ngay_ht,'BH','KH');
if b_loi is not null then return; end if;
if r_hd.so_id_kt>0 then
    PBH_KT_TD_XOA(b_ma_dvi,r_hd.so_id_kt,b_loi);
    if b_loi is not null then return; end if;
end if;
if r_hd.l_ct='T' and trim(r_hd.so_don) is not null then
    PBH_CP_DON(b_ma_dvi,b_so_id,'X',b_loi);
    if b_loi is not null then return; end if;
end if;
if r_hd.so_id_hd<>0 and FTBH_PS(b_ma_dvi,r_hd.so_id_hd,b_so_id)<>0 then
    b_loi:='loi:Khong xoa thu, chi khac da xu ly tai BH:loi'; return;
end if;
PBH_TH_DO_XOA_PS(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
PTBH_TH_TA_XOA(b_so_id,0,0,0,b_loi);
if b_loi is not null then return; end if;
b_loi:='loi:Loi Table BH_CP:loi';
delete bh_cp_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_cp_pt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_cp where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_CP_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_so_id number; b_phong varchar2(10);
    b_ngay_ht number; b_l_ct varchar2(1); b_so_ct varchar2(20);
    b_nv varchar2(10); b_ma_tke varchar2(10); b_so_don varchar2(20);
    b_so_hd varchar2(20); b_so_hs varchar2(2); b_so_id_hd number; b_so_id_hs number; 
    b_c_thue varchar2(1); b_t_suat number; b_ma_nt varchar2(10);
    b_tien number; b_tien_qd number; b_thue number; b_thue_qd number;
    b_ma_thue varchar2(20); b_ten nvarchar2(500); b_dchi nvarchar2(500); b_nd nvarchar2(500);
    b_txt clob:=b_oraIn;
begin
-- Dan - Nhap chi chi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KH','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
else
    PBH_CP_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
FKH_JS_NULL(b_txt);
PBH_CP_TEST(b_ma_dvi,b_so_id,b_txt,
    b_ngay_ht,b_l_ct,b_so_ct,b_nv,b_ma_tke,b_so_don,b_so_hd,b_so_hs,b_so_id_hd,b_so_id_hs,
    b_c_thue,b_t_suat,b_ma_nt,b_tien,b_tien_qd,b_thue,b_thue_qd,
    b_ma_thue,b_ten,b_dchi,b_nd,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','KH');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_l_ct='T' and b_so_don<>' ' then
    select count(*) into b_i1 from bh_cp where ma_dvi=b_ma_dvi and b_so_don=b_so_don;
    if b_i1<>0 then b_loi:='loi:Trung so hoa don VAT:loi'; raise PROGRAM_ERROR; end if;
end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
if b_so_ct=' ' then b_so_ct:=substr(to_char(b_so_id),3); end if;
b_loi:='loi:Loi Table BH_CP:loi';
insert into bh_cp values(b_ma_dvi,b_so_id,b_ngay_ht,b_l_ct,b_so_ct,b_nv,b_ma_tke,b_phong,
    b_so_hd,b_so_id_hd,b_so_hs,b_so_id_hs,b_ma_nt,b_tien,b_tien_qd,
    b_thue,b_thue_qd,b_tien+b_thue,b_tien_qd+b_thue_qd,b_so_don,
    b_c_thue,b_t_suat,b_ma_thue,b_ten,b_dchi,b_nd,b_nsd,sysdate,0);
insert into bh_cp_txt values(b_ma_dvi,b_so_id,'dt_ct',b_txt);
PBH_CP_DON(b_ma_dvi,b_so_id,'N',b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id_hd<>0 then
    PBH_CP_PT(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    if FBH_DONG(b_ma_dvi,b_so_id_hd)='D' then
        PBH_TH_DO_CP(b_ma_dvi,b_so_id,b_loi);
        if b_loi is not null then return; end if;
    end if;
    PTBH_TH_TA_CP(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
select json_object('so_id' value b_so_id,'so_ct' value b_so_ct) into b_oraOut from dual;
commit;
exception when others then rollback; raise_application_error(-20105,b_loi);
end;
/
create or replace procedure PBH_CP_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_so_id number:=PKH_LOC_CHU_SO(trim(b_oraIn));
begin
-- Dan - Xoa chi phi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KH','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then b_loi:='loi:Nhap so ID chung tu:loi'; raise PROGRAM_ERROR; end if;
PBH_CP_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_CP_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000); b_dong number; cs_lke clob:='';
    b_ngayD number; b_ngayC number; b_tienD number; b_tienC number; b_nd nvarchar2(100);
Begin
-- Dan - Tim chi phi
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KH','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,tiend,tienc,nd');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_tienD,b_tienC,b_nd using b_oraIn;
b_ngayD:=nvl(b_ngayD,0); b_ngayC:=nvl(b_ngayC,0);
b_tienD:=nvl(b_tienD,0); b_tienC:=nvl(b_tienC,0);
b_i1:=PKH_NG_CSO(add_months(sysdate,-36));
if b_ngayD in (0,30000101) or b_ngayD<b_i1 then b_ngayD:=b_i1; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_nd:=nvl(trim(b_nd),' ');
if b_nd<>' ' then b_nd:='%'||upper(b_nd)||'%'; end if;
insert into temp_1(n1,n2,c1,c2,n3,c3,n10)
    select so_id,ngay_ht,l_ct,so_ct,ttoan,nd,
    row_number() over (order by ngay_ht desc,so_id) from bh_cp where
    ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and
    ((b_tienC=0 and ttoan>b_tienD) or ttoan between b_tienD and b_tienC) and
    (b_nd=' ' or upper(nd||'|'||so_hd||'|'||so_hs||'|'||so_ct) like b_nd)
    order by ngay_ht desc,so_id;
b_dong:=sql%rowcount;
if b_dong>200 then b_dong:=200; end if;
select JSON_ARRAYAGG(json_object(
    'so_id' value n1,'ngay_ht' value n2,'l_ct' value c1,'so_ct' value c2,'tien' value n3,'nd' value c3)
    order by n2 desc,n1 returning clob) into cs_lke from temp_1 where n10<201;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete temp_1; commit;
end;
/
