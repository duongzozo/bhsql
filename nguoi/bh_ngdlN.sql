CREATE OR REPLACE procedure PBH_NGDLN_BS
    (b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_so_idD number;
    b_ma_dvi varchar2(10); b_so_id number; b_so_id_dt number; cs_lke clob;
begin
-- Dan - Liet ke sua doi theo doi tuong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
if b_so_id=0 then b_loi:='loi:Hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
b_so_idD:=FBH_NGDLN_SO_IDd(b_ma_dvi,b_so_id);
select JSON_ARRAYAGG(json_object(ngay_ht,so_hd) order by ngay_ht desc,so_hd) into cs_lke
    from bh_ngdlN where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGDLN_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number; b_so_hd varchar2(20):=FKH_JS_GTRIs(b_oraIn,'so_hd');
begin
-- Dan - Hoi so ID qua so hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
b_so_id:=FBH_NGDLN_SO_ID(b_ma_dvi,b_so_hd);
if b_so_id=0 then b_loi:='loi:So hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGDLN_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngay number:=PKH_NG_CSO(sysdate);
    cs_sp clob; cs_cdich clob; cs_tpa clob; cs_tltg clob; cs_tlgi clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten returning clob) into cs_sp from
    bh_sk_sp a,(select distinct ma_sp from bh_sk_phi where nhom='T' and ngay_bd<=b_ngay and ngay_kt>b_ngay) b
    where a.ma=b.ma_sp and FBH_SK_SP_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten returning clob) into cs_cdich from
    bh_ma_cdich a,(select distinct cdich from bh_sk_phi where nhom='T' and ngay_bd<=b_ngay and ngay_kt>b_ngay) b
    where a.ma=b.cdich and FBH_MA_NV_CO(a.nv,'NG')='C' and FBH_MA_CDICH_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(ma,ten) order by ten returning clob) into cs_tpa
    from bh_ma_gdinh where FBH_MA_GDINH_NV(ma,'NG')='C' and FBH_MA_GDINH_HAN(ma)='C';
select JSON_ARRAYAGG(json_object('TLTG' value tltg,'TLPH' value tlph) order by tltg returning clob) into cs_tltg
    from bh_sk_tltg where b_ngay between ngay_bd and ngay_kt;
select JSON_ARRAYAGG(JSON_ARRAY(so_ng,tl_giam) order by so_ng) into cs_tlgi
    from bh_sk_tlgi where FBH_SK_TLGI_HAN(so_ng)='C' order by so_ng;
select json_object('cs_sp' value cs_sp,'cs_cdich' value cs_cdich,
    'cs_tpa' value cs_tpa,'cs_tltg' value cs_tltg,'cs_tlgi' value cs_tlgi returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGDLN_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number; b_chd varchar2(1);
    dt_nh clob; dt_ct clob; dt_giam clob; dt_ds clob; dt_dvi clob; dt_kytt clob; dt_txt clob;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id,chd');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id,b_chd using b_oraIn;
select json_object(so_hd,ma_kh returning clob) into dt_ct from bh_ngdlN where ma_dvi=b_ma_dvi and so_id=b_so_id;
select txt into dt_nh from bh_ngdlN_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_nh';
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_ngdlN_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'chd' value b_chd,'dt_nh' value dt_nh,
    'dt_giam' value '','dt_ct' value dt_ct,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGDLN_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10);
    b_ngay_ht number; b_nv varchar2(1); b_klk varchar2(1); b_tu number; b_den number;
    b_ntac varchar2(1); b_dsach varchar2(1);
    b_dong number; cs_lke clob;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,nv,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_nv,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_ngdlN where ma_dvi=b_ma_dvi and 
        ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ngdlN where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','NG','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_ngdlN where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ngdlN  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong order by so_hd)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ngdlN where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ngdlN  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGDLN_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10); b_so_hd varchar2(20);
    b_so_id number; b_ngay_ht number; b_nv varchar2(1);
    b_klk varchar2(1); b_trangKt number; b_tu number; b_den number;
    b_trang number; b_dong number; cs_lke clob;
begin
-- Dan - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,nv,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_nv,b_klk,b_trangKt using b_oraIn;
b_so_hd:=FBH_NGDLN_SO_HD(b_ma_dvi,b_so_id);
if b_so_hd is null then b_loi:='loi:GCN, hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
if b_klk ='N' then
    select count(*) into b_dong from bh_ngdlN where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_ngdlN where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ngdlN  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','NG','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_ngdlN where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_ngdlN where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ngdlN  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong order by so_hd)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ngdlN where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_ngdlN where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ngdlN  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGDLN_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh varchar2,b_loi out varchar2)
AS
    b_nsdC varchar(20); b_i1 number;
begin
-- Dan - Xoa
select nvl(min(trim(nsd)),' ') into b_nsdC from bh_ngdlN where so_id=b_so_id;
if b_nsdC=' ' then b_loi:=''; return;
elsif b_nsd<>b_nsdC then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return;
elsif b_nh='X' then
    select count(*) into b_i1 from bh_ngdlN where so_id_g=b_so_id;
    if b_i1<>0 then b_loi:='loi:Khong xoa hop dong dang co tham chieu:loi'; return; end if;
end if;
b_loi:='loi:Loi xoa Table bh_ngdlN:loi';
delete bh_ngdlN_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ngdlN where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_NGDLN_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(3000); b_lenh varchar2(2000); b_i1 number;
    dt_ct clob; dt_nh clob;
-- Chung
    b_so_id number; b_so_hd varchar2(20); b_ngay_ht number; b_ttrang varchar2(1); b_kieu_hd varchar2(1); b_so_hd_g varchar2(20);
    b_kieu_kt varchar2(1); b_ma_kt varchar2(20); b_kieu_gt varchar2(1); b_ma_gt varchar2(20); b_ma_cb varchar2(20);
    b_so_hdL varchar2(20); b_loai_kh varchar2(1); b_ma_kh varchar2(20); b_ten nvarchar2(500); b_dchi nvarchar2(500);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(50);
    b_gio_hl varchar2(20); b_ngay_hl number; b_gio_kt varchar2(20); b_ngay_kt number; b_ngay_cap number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_c_thue varchar2(1);
    b_tl_giam number; b_phi number; b_giam number; b_thue number; b_ttoan number; b_hhong number;
    b_so_idG number; b_so_idD number; b_ngayD number; b_phong varchar2(10);
    tt_ngay pht_type.a_num; tt_tien pht_type.a_num;
-- Rieng
    b_so_dt number:=0; b_tien number:=0;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_nh');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_nh using b_oraIn;
FKH_JS_NULL(dt_ct);
if b_so_id<>0 then
    select count(*) into b_i1 from bh_ngdlN where so_id=b_so_id;
    if b_i1<>0 then
        select ngay_ht,kieu_hd,ttrang into b_ngay_ht,b_kieu_hd,b_ttrang from bh_ngdlN
            where so_id=b_so_id for update nowait;
        if sql%rowcount=0 then b_loi:='loi:Va cham NSD:loi'; raise PROGRAM_ERROR; end if;
        if b_ttrang not in('T','D') then b_kieu_hd:='X'; else b_kieu_hd:='N'; end if;
        PBH_NGDLN_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_kieu_hd,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
else
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_HD_JS_TEST(
    b_ma_dvi,b_nsd,b_so_id,b_i1,'bh_ngdlN',dt_ct,'',
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_loai_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,
    b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_ngayD,b_phong,b_ma_cb,b_ma_kh,
    tt_ngay,tt_tien,b_loi,'NG');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table bh_ngdl:loi';
insert into bh_ngdlN values(
    b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,'T',b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
    b_phong,b_so_hdL,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,
    b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,'K',b_so_dt,'K',
    b_tien,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,'','',0,b_nsd,sysdate);
PKH_JS_THAYa(dt_ct,'so_hd,ma_kh',b_so_hd||','||b_ma_kh);
insert into bh_ngdlN_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
insert into bh_ngdlN_txt values(b_ma_dvi,b_so_id,'dt_nh',dt_nh);
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hd' value b_so_hd, 'ma_kh' value b_ma_kh) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGDLN_XOA(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Dan - Xoa GCN
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','SK','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_NGDLN_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'X',b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
