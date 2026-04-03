create or replace procedure PBH_LAY_SOAC(b_ma_dvi varchar2,b_loai_ac varchar2,b_mau_ac varchar2,b_so_hd in out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_thang number; b_so number;
begin
-- Dan - Tra so trong chuoi ac
b_loi:='loi:So an chi khong duoc su dung:loi';

if length(b_so_hd) >= 7 then
  b_so:=to_number(substr(PKH_LOC_CHU_SO(b_so_hd),-7));
else
  b_i1:=instr(b_so_hd,'.');
  if b_i1=2 then b_so_hd:=substr(b_so_hd,3); end if;
  b_so:=PKH_LOC_CHU_SO(b_so_hd);
end if;
select count(*) into b_i1 from hd_sc where ma_dvi=b_ma_dvi and loai_bp='C' and ma=b_loai_ac||'>'||b_mau_ac and b_so between dau and cuoi;
if b_i1<>0 then
    select min(thang) into b_thang from hd_sc where ma_dvi=b_ma_dvi and loai_bp='C' and ma=b_loai_ac||'>'||b_mau_ac and b_so between dau and cuoi;
    select trim(seri)||lpad(b_so,7,0) into b_so_hd from hd_sc where ma_dvi=b_ma_dvi and loai_bp='C' and ma=b_loai_ac||'>'||b_mau_ac and b_so between dau and cuoi and thang=b_thang;
    b_loi:='';
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PHD_SO_TT_J
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000); b_d1 number; b_d2 number; b_ngay_ht number; b_loai varchar2(1); b_so_tt varchar2(20);
begin
b_lenh:=FKH_JS_LENH('ngay_ht,l_ct');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_loai using b_oraIn;
-- Lan - Hoi so thu tu tiep theo cua CT HD
b_so_tt:=PHD_SOTT(b_ma_dvi,b_ngay_ht,b_loai);
select json_object('so_tt' value b_so_tt) into b_oraOut from dual;
end;
/
create or replace procedure PHD_LKE_CT_J
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000); b_loi varchar2(100);
    b_ngay_ht number;b_klk varchar2(1); b_tu number; b_den number;
    b_dong number; cs_lke clob;
begin
-- Nga - Liet ke chung tu hoa don theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','NX','X');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
b_lenh:=FKH_JS_LENH('ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk ='T' then
    select count(*) into b_dong from hd_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(JSON_OBJECT(a.so_id,a.l_ct,a.so_ct,a.ngay_ct,a.ma_cc,a.loai_n,a.ma_n,a.nd,a.nsd) returning clob) into cs_lke from (select * from (
        select so_id,l_ct,so_ct,ngay_ct,ma_cc,loai_n,ma_n,nd,nsd,row_number() over (order by so_id) sott
        from hd_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id) where sott between b_tu and b_den) a;
else
    select count(*) into b_dong from hd_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd);
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    --b_loi:='loi:'||b_ma_dvi || ' - ' || b_ngay_ht || ' - ' || b_nsd || ' - ' || b_tu || ' - ' || b_den ||':loi';
    --if b_loi is not null then raise_application_error(-20105,b_loi); end if;
    select JSON_ARRAYAGG(JSON_OBJECT(a.so_id,a.l_ct,a.so_ct,a.ngay_ct,a.ma_cc,a.loai_n,a.ma_n,a.nd,a.nsd) returning clob) into cs_lke
        from (select so_id,l_ct,so_ct,ngay_ct,ma_cc,loai_n,ma_n,nd,nsd,row_number() over (order by so_id) sott
                   from hd_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd) order by so_id) a where a.sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function PHD_SOTT (b_ma_dvi varchar2,b_ngay_ht number,b_loai varchar2) return varchar2
AS
    b_d1 number; b_d2 number; b_i1 number; b_c2 varchar2(2);
begin
-- Lan - Cho so thu tu tiep theo cua CT HD
b_d1:=round(b_ngay_ht,-2);b_d2:=b_d1+100; b_c2:=substr(b_loai,1,1)||'%';
select nvl(max(PKH_LOC_CHU_SO(so_ct)),0) into b_i1 from hd_1 where
    ma_dvi=b_ma_dvi and (ngay_ht between b_d1 and b_d2) and l_ct like b_c2;
if b_i1<10000 then b_i1:=1; else b_i1:=round(b_i1/10000,0)+1; end if;
return trim(to_char(b_i1))||'/'||substr(b_loai,1,1)||'/'||substr(to_char(b_ngay_ht),5,2)||':'||substr(to_char(b_ngay_ht),3,2);
end;
/
create or replace procedure PHD_MA_NHJ_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma varchar2(10);b_ten nvarchar2(50);
begin
-- viet anh - Nhap ma nhom hoa don
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','MA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma nhom:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham NSD:loi';
delete hd_ma_nhom where ma_dvi=b_ma_dvi and ma=b_ma;
insert into hd_ma_nhom values(b_ma_dvi,b_ma,b_ten,b_nsd);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHD_MA_NHJ_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- viet anh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','MA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from hd_ma_nhom;
select nvl(min(sott),0) into b_tu from (select ma,ROW_NUMBER() over (order by ma) as sott from hd_ma_nhom order by ma) where ma>=b_ma;
PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
    (select ma,ten,nsd,ROW_NUMBER() over (order by ma) as sott from hd_ma_nhom order by ma)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHD_MA_NHJ_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_ct clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- viet anh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','MA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten) into cs_ct from hd_ma_nhom where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_PHONG_LIST(b_ma_dvi varchar2,b_loi out varchar2)
AS
begin
-- chuclh
b_loi:='loi:Loi xu ly PHT_MA_PHONG_LIST:loi';
insert into bh_kh_hoi_temp1 select ma,ten from ht_ma_phong where ma_dvi=b_ma_dvi order by ten;
b_loi:='';
exception when others then null;
end;
/
create or replace procedure PHD_MA_TTIN
    (b_ma_dvi varchar2,b_ma varchar2,b_ten out nvarchar2,b_do_dai out number,b_so_to out number,b_loi out varchar2)
AS
-- Dan - Thong tin ve loai hoa don
begin
b_loi:='loi:Loai hoa don '||b_ma||' chua dang ky:loi';
select ten,do_dai,so_to into b_ten,b_do_dai,b_so_to from hd_ma_hd where ma_dvi=b_ma_dvi and ma=b_ma;
b_loi:='';
exception when others then null;
end;
/
create or replace procedure PHD_TON_GIU
  (b_ma varchar2,b_seri varchar2,b_so number,b_ma_dvi_g out varchar2,b_loai_bp out varchar2,b_ma_bp out varchar2)
AS
  b_dau number; b_cuoi number; b_kq varchar2(20):='';
begin
-- Dan - Tim bo phan giu hoa don trong so cai hoa don ton
select nvl(max(b_dau),0) into b_dau from hd_sc_ton where ma=b_ma and seri=b_seri and dau<=b_so;
if b_dau=0 then b_ma_dvi_g:=''; b_loai_bp:=''; b_ma_bp:='';
else
  select ma_dvi,loai_bp,ma_bp,cuoi into b_ma_dvi_g,b_loai_bp,b_ma_bp,b_cuoi
    from hd_sc_ton where ma=b_ma and seri=b_seri and dau=b_dau;
  if b_cuoi<b_so then b_ma_dvi_g:=''; b_loai_bp:=''; b_ma_bp:=''; end if;
end if;
end;
