/*** Phuc hoi hop dong khong hoan phi ***/
create or replace function FBH_HD_PHOI_NGAY
    (b_ma_dvi varchar2,b_so_id varchar2,b_ngay_ht number:=30000101) return number
AS
    b_kq number;
begin
-- Dan - Tra ngay phuc hoi gan nhat
select nvl(max(ngay_ht),0) into b_kq from bh_hd_goc_phoi where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay_ht;
return b_kq;
end;
/
create or replace procedure PBH_HD_PHOI_SO_HD(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_i2 number; b_so_hd varchar2(20):=trim(b_oraIn);
    b_so_idD number; b_so_idB number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
    b_ngayH number; b_tp number:=0; b_bth number;
    b_phi number; b_thue number; b_phiB number; b_phiT number; b_nopP number; b_nopT number;
    b_con number:=0; b_hoanP number:=0; b_hoanT number:=0;
    r_hd bh_hd_goc%rowtype;
begin
-- Dan - Thong tin hop dong huy
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HUY','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_hd is null then b_loi:='loi:Nhap hop dong:loi'; raise PROGRAM_ERROR; end if;
b_so_idD:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi,b_so_hd);
if b_so_idD=0 then b_loi:='loi:Hop dong, GCN da xoa:loi'; raise PROGRAM_ERROR; end if;
b_ngayH:=FBH_HD_HU_NGAY(b_ma_dvi,b_so_idD);
if b_ngayH=0 or FBH_HD_HU(b_ma_dvi,b_so_idD)<>'C' then
	b_loi:='loi:Hop dong chua cham dut:loi'; raise PROGRAM_ERROR;
end if;
select txt into b_oraOut from bh_hd_goc_hu_txt where ma_dvi=b_ma_dvi and so_id=b_so_idD and ngay_ht=b_ngayH;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_PHOI_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(2000);
    b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number; b_phong varchar2(10);
    b_so_idB number;
    b_dong number; cs_lke clob:='';
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HUY','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_hd_goc_phoi where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(so_hd,ngay_ht) returning clob) into cs_lke from
        (select so_hd,ngay_ht,rownum sott from bh_hd_goc_phoi where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_hd_goc_phoi where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(so_hd,ngay_ht) returning clob) into cs_lke from
        (select so_hd,ngay_ht,rownum sott from bh_hd_goc_phoi where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_PHOI_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_phong varchar2(10); b_tu number; b_den number;
    b_so_hd varchar2(20); b_so_id number; b_ngay_ht number; b_klk varchar2(1); b_trangkt number;
    b_trang number; b_dong number; cs_lke clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HUY','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hd,ngay_ht,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_ngay_ht,b_klk,b_trangKt using b_oraIn;
b_so_id:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi,b_so_hd);
if b_klk ='N' then
    select count(*) into b_dong from bh_hd_goc_phoi where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_hd,rownum sott from bh_hd_goc_phoi where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_hd) where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_hd,ngay_ht) returning clob) into cs_lke from
        (select so_hd,ngay_ht,rownum sott from bh_hd_goc_phoi where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_hd_goc_phoi where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from (select so_hd,rownum sott from bh_hd_goc_phoi where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_hd) where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_hd,ngay_ht) returning clob) into cs_lke from
        (select so_hd,ngay_ht,rownum sott from bh_hd_goc_phoi where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_PHOI_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_so_hd varchar2(20); b_so_id number; b_ngay_ht number;
    b_ngayH number; b_ngayP number; b_ldo nvarchar2(500);
begin
-- Dan - Xem chi tiet huy hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HUY','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hd,ngay_ht');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_ngay_ht using b_oraIn;
if trim(b_so_hd)='' then b_loi:='loi:Nhap so hop dong:loi'; raise PROGRAM_ERROR; end if;
b_so_id:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi,b_so_hd);
if b_so_id=0 then b_loi:='loi:Hop dong goc da xoa:loi'; raise PROGRAM_ERROR; end if;
b_ngay_ht:=nvl(b_ngay_ht,0);
b_ngayP:=FBH_HD_PHOI_NGAY(b_ma_dvi,b_so_id,b_ngay_ht);
if b_ngayP=0 then b_loi:='loi:Phuc hoi hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
b_ngayH:=FBH_HD_HU_NGAY(b_ma_dvi,b_so_id,b_ngayP);
if b_ngayH=0 then b_loi:='loi:Cham dut hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
select ldo into b_ldo from bh_hd_goc_phoi where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht=b_ngayP;
select txt into b_oraOut from bh_hd_goc_hu_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht=b_ngayH;
b_oraOut:=FKH_JS_BONH(b_oraOut);
PKH_JS_THAYn(b_oraOut,'ngay_ph',b_ngayP); PKH_JS_THAY(b_oraOut,'ldo',b_ldo);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PBH_HD_PHOI_TEST(
    b_ma_dvi varchar2,b_so_id number,dt_ct clob,
    b_ngayH out number,b_ngayP out number,b_ldo out nvarchar2,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_hoanP number;
begin
-- Dan - Kiem tra so lieu huy hop dong
b_lenh:=FKH_JS_LENH('ngay_ph,ldo');
EXECUTE IMMEDIATE b_lenh into b_ngayP,b_ldo using dt_ct;
if b_ngayP is null or b_ngayP in(0,30000101) then b_loi:='loi:Nhap ngay phuc hoi:loi'; return; end if;
if FBH_HD_HU(b_ma_dvi,b_so_id)<>'C' then
    b_loi:='loi:Hop dong chua cham dut phuc hoi:loi'; return;
end if;
b_ngayH:=FBH_HD_HU_NGAY(b_ma_dvi,b_so_id);
if b_ngayH=0 or b_ngayH>=b_ngayP then
    b_loi:='loi:Ngay phuc hoi phai sau ngay cham dut:loi'; return;
end if;
select max(hoanP) into b_hoanP from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_hoanP<>0 then
    b_loi:='loi:Khong phuc hoi hop dong da hoan phi:loi'; return;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_PHOI_TEST:loi'; end if;
end;
/
create or replace procedure PBH_HD_PHOI_NH_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_ngayH number,b_ngayP number,b_ldo nvarchar2,b_loi out varchar2)
AS
begin
-- Dan - Nhap phuc hoi hop dong
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngayP,'BH','TT');
if b_loi is not null then return; end if;
b_loi:='loi:Loi Table bh_hd_goc_phoi:loi';
insert into bh_hd_goc_phoi select b_ma_dvi,b_so_id,b_ngayP,b_ldo,so_hd,phong,ma_kh,ten,ma_dl,b_nsd
    from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht=b_ngayH;
if sql%rowcount<>1 then b_loi:='loi:Loi Table bh_hd_goc_hu:loi'; return; end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HD_PHOI_XOA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ngayP number; b_nsdC varchar2(20);
Begin
-- Dan - Xoa phuc hoi hop dong
b_loi:='loi:Loi xu ly PBH_HD_PHOI_XOA_XOA:loi';
if FBH_HD_HU(b_ma_dvi,b_so_id)='C' then b_loi:='loi:Hop dong da cham dut:loi'; end if;
b_ngayP:=FBH_HD_PHOI_NGAY(b_ma_dvi,b_so_id);
if b_ngayP=0 then b_loi:=''; return; end if;
select nsd into b_nsdC from bh_hd_goc_phoi where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht=b_ngayP;
if b_nsd<>b_nsdC then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
delete bh_hd_goc_phoi where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht=b_ngayP;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HD_PHOI_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_so_id number;
    b_so_hd varchar2(20); b_ngayH number; b_ngayP number; b_ldo nvarchar2(500);
begin
-- Dan - Nhap huy hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HUY','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_hd:=FKH_JS_GTRIs(b_oraIn,'so_hd');
if trim(b_so_hd)='' then b_loi:='loi:Nhap so hop dong:loi'; raise PROGRAM_ERROR; end if;
b_so_id:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi,b_so_hd);
if b_so_id=0 then b_loi:='loi:Hop dong goc da xoa:loi'; raise PROGRAM_ERROR; end if;
PBH_HD_PHOI_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_HD_PHOI_TEST(b_ma_dvi,b_so_id,b_oraIn,b_ngayH,b_ngayP,b_ldo,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_HD_PHOI_NH_NH(b_ma_dvi,b_nsd,b_so_id,b_ngayH,b_ngayP,b_ldo,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_PHOI_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_so_hd varchar2(20):=trim(b_oraIn); b_so_id number; 
begin
-- Dan - Xoa huy hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HUY','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_hd is null then b_loi:='loi:Nhap so hop dong:loi'; raise PROGRAM_ERROR; end if;
b_so_id:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi,b_so_hd);
if b_so_id=0 then b_loi:='loi:Hop dong goc da xoa:loi'; raise PROGRAM_ERROR; end if;
PBH_HD_PHOI_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
