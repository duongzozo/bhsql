/*** BIEU PHI ***/
create or replace function FBH_HANG_PT_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Nam
select min(ten) into b_kq from bh_hang_pt where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_HANG_PT_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Nam
select min(ma||'|'||ten) into b_kq from bh_hang_pt where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_HANG_PT_TAI(b_ma varchar2) return varchar2
AS
    b_kq nvarchar2(200);
begin
-- Nam
select nvl(min(tai),'K') into b_kq from bh_hang_pt where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_HANG_LOAI_MRR(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1);
begin
-- Nam - Kiem tra con hieu luc
select nvl(min(mrr),'1') into b_kq from bh_hang_dgoi where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_HANG_LOAI_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Nam
select min(ten) into b_kq from bh_hang_loai where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_HANG_NHANG_UOC(b_ma varchar2) return number
AS
    b_kq number;
begin
-- Nam
select nvl(min(uoc),0) into b_kq from bh_hang_nhom where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_HANG_NHANG_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Nam
select min(ten) into b_kq from bh_hang_nhom where ma=b_ma;
return b_kq;
end;

/
create or replace function FBH_HANG_QTAC_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Nam
select min(ten) into b_kq from bh_ma_qtac where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_HANG_DGOI_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Nam
select min(ma||'|'||ten) into b_kq from bh_hang_dgoi where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_HANG_DGOI_MA(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Nam
select min(ma) into b_kq from bh_hang_dgoi where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_HANG_DGOI_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Nam
select min(ten) into b_kq from bh_hang_dgoi where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_HANG_PT_MA(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Nam
select min(ma) into b_kq from bh_hang_pt where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_HANG_NHANG_MA(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Nam
select min(ma) into b_kq from bh_hang_nhom where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_HANG_QTAC_MA(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Nam
select min(ma) into b_kq from bh_ma_qtac where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_HANG_LOAI_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Nam
select min(ma||'|'||ten) into b_kq from bh_hang_loai where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_HANG_DKGH_MA(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Nam
select min(ma) into b_kq from bh_hang_dkgh where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_HANG_PPT_MA(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Nam
select min(ma) into b_kq from bh_hang_pp where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_HANG_CANG_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Nam
select min(ten) into b_kq from bh_hang_cang where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_HANG_PHITT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000); b_ngay number:=PKH_NG_CSO(sysdate);
    b_loi varchar2(100); b_ma_nhang varchar2(500); b_nt_phi varchar2(5); b_phiT number; b_tgP number:=1;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_nhang,nt_phi');
EXECUTE IMMEDIATE b_lenh into b_ma_nhang,b_nt_phi using b_oraIn;
b_ma_nhang:=PKH_MA_TENl(b_ma_nhang);
if b_nt_phi<>'VND' then b_tgP:=FBH_TT_TRA_TGTT(b_ngay,b_nt_phi); end if;
select nvl(phi,0) into b_phiT from bh_hang_nhom where ma=b_ma_nhang;
select json_object('phi' value round(b_phiT/b_tgP,2)) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_HANG_BPHI_SO_ID
    (b_ma_pt varchar2,b_ma_nhang varchar2,b_ma_qtac varchar2, b_khoang_cachN number, b_thoi_gianN number,b_ngay_hl number:=0) return number
AS
    b_so_id number:=0; b_ngay number:=b_ngay_hl;
begin
-- Nam - Tra so ID phi
if b_ngay in(0,30000101) then b_ngay:=PKH_NG_CSO(sysdate); end if;

select nvl(max(so_id),0) into b_so_id from bh_hang_phi where
           pt=b_ma_pt and nhang=b_ma_nhang and qtac=b_ma_qtac and khoang_cach in (0, b_khoang_cachN) and thoi_gian in (0, b_thoi_gianN) ;
return b_so_id;
end;
/
create or replace function FBH_HANG_BPHI_SO_IDd(
    b_ma_vchuyen varchar2,b_ma_nhang varchar2,b_ma_qtac varchar2, b_khoang_cachN number, b_thoi_gianN number,b_ngay_hl number:=0) return number
AS
    b_so_id number:=0; b_ngay number:=b_ngay_hl;
begin
-- Nam - Tra so ID phi dung
if b_ngay in(0,30000101) then b_ngay:=PKH_NG_CSO(sysdate); end if;
if b_khoang_cachN>0 then
   select nvl(max(so_id),0) into b_so_id from bh_hang_phi where
           pt=b_ma_vchuyen and nhang=b_ma_nhang and qtac=b_ma_qtac and khoang_cach in (0, b_khoang_cachN) and b_ngay between ngay_bd and ngay_kt;
elsif b_thoi_gianN >0 then
  select nvl(max(so_id),0) into b_so_id from bh_hang_phi where
           pt=b_ma_vchuyen and nhang=b_ma_nhang and qtac=b_ma_qtac and thoi_gian <= b_thoi_gianN and b_ngay between ngay_bd and ngay_kt;
else
  select nvl(max(so_id),0) into b_so_id from bh_hang_phi where
           pt=b_ma_vchuyen and nhang=b_ma_nhang and qtac=b_ma_qtac and b_ngay between ngay_bd and ngay_kt;
end if;
return b_so_id;
end;
/
/*** MA ***/
-- MA NHOM HANG --
create or replace function FBH_HANG_MA_NHOM_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Nam
select min(ma||':'||ten) into b_kq from bh_hang_nhom where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_HANG_MA_HANG_TEN(b_ma varchar2,b_dk varchar2:='C') return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Nam - Tra ten
select min(ten) into b_kq from bh_hang_loai where ma=b_ma and tc in('C',b_dk);
return b_kq;
end;
/
create or replace function FBH_HANG_MA_HANG_TENl(b_ma varchar2,b_dk varchar2:='C') return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Nam - Tra ten
select min(ma||':'||ten) into b_kq from bh_hang_loai where ma=b_ma and tc in('C',b_dk);
return b_kq;
end;
/
create or replace function FBH_HANG_MA_HANG_HAN(b_ma varchar2,b_dk varchar2:='C') return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Nam - Kiem tra con dung
select count(*) into b_i1 from bh_hang_loai where ma=b_ma and tc in('C',b_dk) and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_HANGH_BPHI_SO_ID
    (b_ma_pt varchar2,b_ma_nhang varchar2,b_ma_qtac varchar2, b_khoang_cachN number, b_thoi_gianN number,b_ngay_hl number:=0) return number
AS
    b_so_id number:=0; b_khoang_cach number; b_thoi_gian number; b_ngay number:=b_ngay_hl;
begin
-- Nam - Tra so ID phi
if b_ngay in(0,30000101) then b_ngay:=PKH_NG_CSO(sysdate); end if;
select nvl(max(khoang_cach),-1),nvl(max(thoi_gian),-1) into b_khoang_cach,b_thoi_gian from bh_hang_phi where
       pt=b_ma_pt and nhang=b_ma_nhang and qtac=b_ma_qtac and (khoang_cach <= b_khoang_cachN or thoi_gian <= b_thoi_gianN) and b_ngay between ngay_bd and ngay_kt;
if b_khoang_cach>0 then
   select nvl(max(so_id),0) into b_so_id from bh_hang_phi where
           pt=b_ma_pt and nhang=b_ma_nhang and qtac=b_ma_qtac and khoang_cach <= b_khoang_cach and b_ngay between ngay_bd and ngay_kt;
elsif b_thoi_gian >0 then
  select nvl(max(so_id),0) into b_so_id from bh_hang_phi where
           pt=b_ma_pt and nhang=b_ma_nhang and qtac=b_ma_qtac and thoi_gian <= b_thoi_gian and b_ngay between ngay_bd and ngay_kt;
else
  select nvl(max(so_id),0) into b_so_id from bh_hang_phi where
           pt=b_ma_pt and nhang=b_ma_nhang and qtac=b_ma_qtac and b_ngay between ngay_bd and ngay_kt;
end if;
return b_so_id;
end;
/
create or replace function FBH_HANG_LHANG_HAN(b_ma varchar2,b_dk varchar2:='C') return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Nam - Kiem tra con hieu luc
select count(*) into b_i1 from bh_hang_loai where ma=b_ma and ngay_bd<=b_ngay and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
-- PHUONG THUC VAN CHUYEN
create or replace procedure PBH_HANG_MA_PT_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;  
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_hang_pt;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,tai,nsd) returning clob) into cs_lke from
        (select  ma,ten,tai,nsd,rownum sott from bh_hang_pt a order by ma)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_hang_pt where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,tai,nsd) returning clob) into cs_lke from
        (select ma,ten,tai,nsd,rownum sott from bh_hang_pt where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;

/
create or replace procedure PBH_HANG_MA_PT_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_hang_pt;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_hang_pt;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_PT_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,tai) into b_kq from bh_hang_pt where ma=b_ma;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_PT_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_tai varchar2(1);
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tai');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_tai using b_oraIn;
b_ma:=nvl(trim(b_ma),' '); b_ten:=nvl(trim(b_ten),' ');
if b_ma=' ' or b_ten=' ' then b_loi:='loi:Nhap ma,ten:loi'; raise PROGRAM_ERROR; end if;
b_tai:=nvl(trim(b_tai),'C');
if b_tai not in('C','K') then b_tai:='C'; end if;
b_loi:='';
delete bh_hang_pt where ma=b_ma;
insert into bh_hang_pt values(b_ma_dvi,b_ma,b_ten,b_tai,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_PT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_hang_pt where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_NHOM_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_hang_nhom;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,phi,uoc,nsd) returning clob) into cs_lke from
        (select  ma,ten,phi,uoc,nsd,rownum sott from bh_hang_nhom a order by ma)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_hang_nhom where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,phi,uoc,nsd) returning clob) into cs_lke from
        (select ma,ten,phi,uoc,nsd,rownum sott from bh_hang_nhom where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_NHOM_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_hang_nhom;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_hang_nhom;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_NHOM_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,phi,uoc) into b_kq from bh_hang_nhom where ma=b_ma;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_NHOM_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_phi number; b_uoc number;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,phi,uoc');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_phi,b_uoc using b_oraIn;
b_ma:=nvl(trim(b_ma),' '); b_ten:=nvl(trim(b_ten),' ');
if b_ma=' ' or b_ten=' ' then b_loi:='loi:Nhap ma,ten:loi'; raise PROGRAM_ERROR; end if;
b_phi:=nvl(b_phi,0); b_uoc:=nvl(b_uoc,0);
b_loi:='';
delete bh_hang_nhom where ma=b_ma;
insert into bh_hang_nhom values(b_ma_dvi,b_ma,b_ten,b_phi,b_uoc,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_NHOM_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_hang_nhom where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_HANG_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    bi1 number; b_loi varchar2(100); cs_qly clob;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into bi1 from bh_hang_loai where tc='T';
if bi1<>0 then
   select JSON_ARRAYAGG(json_object(ma,ten) order by ten returning clob) into cs_qly from bh_hang_loai where tc='T';
end if;
select json_object('cs_qly' value cs_qly returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_HANG_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number:=0; cs_lke clob:='';
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_hang_loai;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma,ten,nsd,xep) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_hang_loai order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_hang_loai where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(ma,ten,nsd,'xep' value ma) obj from bh_hang_loai a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_HANG_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_hang_loai;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_hang_loai order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_hang_loai order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma,ten,nsd,xep) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep,rownum sott from
                    (select * from bh_hang_loai order by ma) a
                    start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_hang_loai where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_hang_loai where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(ma,ten,nsd,'xep' value ma) obj from bh_hang_loai a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_HANG_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
    cs_ct clob:=''; cs_dk clob:='';
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is not null then
  b_loi:='loi:Ma da xoa:loi';
  select json_object(ma,txt returning clob) into cs_ct from bh_hang_loai where ma=b_ma;
  select JSON_ARRAYAGG(obj returning clob) into cs_dk from
    (select json_object(ma,ten,ma_ct,tc,mrr,ngay_bd,ngay_kt,nsd) obj from bh_hang_loai where ma=b_ma order by ngay_bd desc);
end if;
select json_object('cs_ct' value cs_ct,'cs_dk' value cs_dk returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_HANG_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(1000); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_tc varchar2(1); b_ma_ct varchar2(10);
    b_ngay_bd number; b_ngay_kt number; b_mrr varchar2(1);
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,ngay_bd,ngay_kt,mrr');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_tc,b_ma_ct,b_ngay_bd,b_ngay_kt,b_mrr using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
b_ma_ct:=nvl(trim(b_ma_ct),' ');
if b_ma_ct = ' ' then b_tc:= 'T';
else b_tc:= 'C';
end if;
b_tc:=nvl(trim(b_tc),'C');
if b_ma_ct<>' ' then
    b_loi:='loi:Sai ma cap tren:loi';
    if b_ma=b_ma_ct then raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from bh_hang_loai where ma=b_ma_ct and tc='T';
end if;
b_mrr:=nvl(trim(b_mrr),'1');
if b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_hang_loai where ma=b_ma;
insert into bh_hang_loai values(b_ma_dvi,b_ma,b_ten,b_ma_ct,b_tc,b_mrr,b_ngay_bd,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_HANG_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn cLob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_hang_loai where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_hang_loai where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- MA CANG --
create or replace procedure PBH_HANG_MA_CANG_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number:=0; cs_lke clob:='';
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_hang_cang;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd)) into cs_lke from
            (select t.*,rownum sott from bh_hang_cang t order by ma)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_hang_cang where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd)) into cs_lke from
        (select a.*,rownum sott from bh_hang_cang a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_CANG_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_hang_cang;
    select nvl(min(sott),0) into b_tu from (select t.*,rownum sott from bh_hang_cang t order by t.ma) where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select t.*, rownum sott from bh_hang_cang t order by t.ma)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select * from bh_hang_cang order by ma) a)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_hang_cang where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_hang_cang where upper(ten) like b_tim order by ma)
        where ma>=b_ma;

    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select ma,ten,json_object(a.*) obj,rownum sott from bh_hang_cang a where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_CANG_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,'nuoc' value FBH_MA_NUOC_TENl(nuoc),txt returning clob) into b_kq from bh_hang_cang where ma=b_ma;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_CANG_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_nuoc varchar(200);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,nuoc');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_nuoc using b_oraIn;
b_nuoc:=PKH_MA_TENl(b_nuoc);
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
b_loi:='';
delete bh_hang_cang where ma=b_ma;
insert into bh_hang_cang values(b_ma_dvi,b_ma,b_ten,b_nuoc,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_CANG_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_hang_cang where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Phuong thuc dong goi --
create or replace function FBH_HANG_DGOI_MRR(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1);
begin
-- Nam - Kiem tra con hieu luc
select nvl(min(mrr),'1') into b_kq from bh_hang_dgoi where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_HANG_MA_DGOI_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number:=0; cs_lke clob:='';
begin
-- Namhttp://localhost:3336/App_form/bhma/bhma_xe/
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_hang_dgoi;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd)) into cs_lke from
            (select t.*,rownum sott from bh_hang_dgoi t order by ma)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_hang_dgoi where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd)) into cs_lke from
        (select a.*,rownum sott from bh_hang_dgoi a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_DGOI_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_hang_dgoi;
    select nvl(min(sott),0) into b_tu from (select t.*,rownum sott from bh_hang_dgoi t order by t.ma) where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select t.*, rownum sott from bh_hang_dgoi t order by t.ma)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select * from bh_hang_dgoi order by ma) a)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_hang_dgoi where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_hang_dgoi where upper(ten) like b_tim order by ma)
        where ma>=b_ma;

    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select ma,ten,json_object(a.*) obj,rownum sott from bh_hang_dgoi a where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_DGOI_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,mrr,txt returning clob) into b_kq from bh_hang_dgoi where ma=b_ma;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_DGOI_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_mrr varchar2(1);
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,mrr');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_mrr using b_oraIn;
b_ma:=nvl(trim(b_ma),' '); b_ten:=nvl(trim(b_ten),' '); b_mrr:=nvl(trim(b_mrr),'1');
if b_ma=' ' or b_ten=' ' then b_loi:='loi:Nhap ma,ten:loi'; raise PROGRAM_ERROR; end if;
delete bh_hang_dgoi where ma=b_ma;
insert into bh_hang_dgoi values(b_ma_dvi,b_ma,b_ten,b_mrr,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_DGOI_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_hang_dgoi where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- PHUONG PHAP TINH --
create or replace  procedure PBH_HANG_MA_PP_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number:=0; cs_lke clob:='';
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_hang_pp;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd)) into cs_lke from
            (select t.*,rownum sott from bh_hang_pp t order by ma)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_hang_pp where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd)) into cs_lke from
        (select a.*,rownum sott from bh_hang_pp a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace  procedure PBH_HANG_MA_PP_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_hang_pp;
    select nvl(min(sott),0) into b_tu from (select t.*,rownum sott from bh_hang_pp t order by t.ma) where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select t.*, rownum sott from bh_hang_pp t order by t.ma)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select * from bh_hang_pp order by ma) a)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_hang_pp where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_hang_pp where upper(ten) like b_tim order by ma)
        where ma>=b_ma;

    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select ma,ten,json_object(a.*) obj,rownum sott from bh_hang_pp a where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_PP_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,txt returning clob) into b_kq from bh_hang_pp where ma=b_ma;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_PP_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500);
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
b_loi:='';
delete bh_hang_pp where ma=b_ma;
insert into bh_hang_pp values(b_ma_dvi,b_ma,b_ten,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_PP_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_hang_pp where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_PPTINH(
   b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
   b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;b_s varchar2(200);
   b_gia_tri number; b_cphi number; b_ma_pptinh varchar(10); b_tlp number; b_mtn number; b_nt_tien varchar(5);
begin
-- Dan - Kiem soat dieu kien rieng
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('gia_tri,cphi,ma_pptinh,tlp,nt_tien');
execute immediate b_lenh into b_gia_tri,b_cphi,b_ma_pptinh,b_tlp,b_nt_tien using b_oraIn;
b_s:='PBH_HANG_PPTINH_'||b_ma_pptinh;
select count(*) into b_i1 from USER_PROCEDURES where OBJECT_NAME=b_s;
if b_i1=0 then b_loi:='loi:Chua tao thu tuc '||b_s||':loi'; return; end if;
b_lenh:='begin '||b_s||'(:gt,:cp,:tlp,:nt_tien,:mtn,:b_mtn); end;';
execute immediate b_lenh using b_gia_tri,b_cphi,b_tlp,b_nt_tien,out b_mtn,out b_loi;
if b_loi is not null then b_loi:='loi:'||b_loi||':loi'; return; end if;
select json_object('mtn' value b_mtn) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_PPTINH_100(
   b_gia_tri number, b_cpN number, b_tlpN number,nt_tien varchar2, b_mtn out number,b_loi out varchar2)
AS
   b_lenh varchar2(1000);
begin
  if(b_gia_tri <=0) then b_loi:='Sai gia tri'; return; end if;
  b_mtn :=b_gia_tri;
  exception when others then null;
end;
/
create or replace procedure PBH_HANG_PPTINH_110(
   b_gia_tri number, b_cpN number, b_tlpN number, nt_tien varchar2, b_mtn out number,b_loi out varchar2)
AS
   b_lenh varchar2(1000); b_tp number:=0; b_pp number:=1.1; b_nt_tien varchar2(5);
begin
  if b_nt_tien<>'VND' then b_tp:=2; end if;
  if(b_gia_tri <=0) then b_loi:='Sai gia tri'; return; end if;
  b_mtn := ROUND(b_gia_tri*b_pp,b_tp);
  exception when others then null;
end;
/
create or replace procedure PBH_HANG_PPTINH_100CIF(
   b_gia_tri number, b_cpN number, b_tlpN number,nt_tien varchar2, b_mtn out number,b_loi out varchar2)
AS
   b_lenh varchar2(1000); b_tp number:=0; b_nt_tien varchar2(5);
   b_cp number; b_tlp number;
begin
  if b_nt_tien<>'VND' then b_tp:=2; end if;
  if(b_gia_tri <=0) then b_loi:='Sai gia tri'; return; end if;
  if(b_cpN < 1) then b_cp:=1; else b_cp:= b_cpN; end if;
  if(b_tlpN <=0 or b_tlpN/100 > 1) then b_tlp:=0; else b_tlp := b_tlpN/100; end if;
  b_mtn := ROUND((b_gia_tri+b_cp)/(1-b_tlp),b_tp);
  exception when others then null;
end;
/
create or replace procedure PBH_HANG_PPTINH_110CIF(
   b_gia_tri number, b_cpN number, b_tlpN number, nt_tien varchar2, b_mtn out number,b_loi out varchar2)
AS
   b_lenh varchar2(1000); b_tp number:=0; b_pp number:= 1.1; b_nt_tien varchar2(5);
   b_cp number; b_tlp number;
begin
  if b_nt_tien<>'VND' then b_tp:=2; end if;
  if(b_gia_tri <=0) then b_loi:='Sai gia tri'; return; end if;
  if(b_cpN < 1) then b_cp:=1; else b_cp:= b_cpN; end if;
  if(b_tlpN <=0 or b_tlpN/100 > 1) then b_tlp:=0; else b_tlp := b_tlpN/100; end if;
  b_mtn := ROUND((b_gia_tri+b_cp)*b_pp/(1-b_tlp),b_tp);
  exception when others then null;
end;
/
-- dieu kien giao hang --
create or replace  procedure PBH_HANG_MA_DKGH_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number:=0; cs_lke clob:='';
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_hang_dkgh;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd)) into cs_lke from
            (select t.*,rownum sott from bh_hang_dkgh t order by ma)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_hang_dkgh where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd)) into cs_lke from
        (select a.*,rownum sott from bh_hang_dkgh a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace  procedure PBH_HANG_MA_DKGH_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_hang_dkgh;
    select nvl(min(sott),0) into b_tu from (select t.*,rownum sott from bh_hang_dkgh t order by t.ma) where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select t.*, rownum sott from bh_hang_dkgh t order by t.ma)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select * from bh_hang_dkgh order by ma) a)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_hang_dkgh where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_hang_dkgh where upper(ten) like b_tim order by ma)
        where ma>=b_ma;

    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select ma,ten,json_object(a.*) obj,rownum sott from bh_hang_dkgh a where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_DKGH_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,txt returning clob) into b_kq from bh_hang_dkgh where ma=b_ma;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_DKGH_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500);
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
b_loi:='';
delete bh_hang_dkgh where ma=b_ma;
insert into bh_hang_dkgh values(b_ma_dvi,b_ma,b_ten,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_MA_DKGH_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_hang_dkgh where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Ma nguyen nhan ton that
create or replace function FBH_HANG_NNTT_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Nam
select min(ten) into b_kq from bh_hang_nntt where ma=b_ma and tc='C';
return b_kq;
end;
/
create or replace function FBH_HANG_NNTT_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Nam
select min(ma||'|'||ten) into b_kq from bh_hang_nntt where ma=b_ma and tc='C';
return b_kq;
end;
/
create or replace function FBH_HANG_NNTT_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Nam - Kiem tra con hieu luc
select count(*) into b_i1 from bh_hang_nntt where ma=b_ma and tc='C' and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_HANG_NNTT_XEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngay number:=PKH_NG_CSO(sysdate); cs_lke clob;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma) into cs_lke from bh_hang_nntt a where tc='C' and ngay_kt>b_ngay;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_NNTT_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number:=0; cs_lke clob:='';
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_hang_nntt;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep)) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_hang_nntt order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_hang_nntt where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma)) into cs_lke from
        (select a.*,rownum sott from bh_hang_nntt a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_NNTT_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_hang_nntt;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_hang_nntt order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_hang_nntt order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep)) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_hang_nntt order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_hang_nntt where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_hang_nntt where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma)) into cs_lke from
        (select a.*,rownum sott from bh_hang_nntt a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_NNTT_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma'); cs_ct clob;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma chua nhap hoac da xoa:loi';
select json_object(ma,txt) into cs_ct from bh_hang_nntt  where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_NNTT_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_tc varchar2(1);
    b_ma_ct varchar2(10); b_ngay_kt number;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_tc,b_ma_ct,b_ngay_kt using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_tc is null or b_tc<>'T' then b_tc:='C'; end if;
if trim(b_ma_ct) is null then
    b_ma_ct:=' ';
else
    b_loi:='loi:Sai ma cap tren:loi';
    if b_ma=b_ma_ct then raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from bh_hang_nntt where ma=b_ma_ct and tc='T';
end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_hang_nntt where ma=b_ma;
insert into bh_hang_nntt values(b_ma_dvi,b_ma,b_ten,b_tc,b_ma_ct,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_NNTT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_hang_nntt where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_hang_nntt where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_BPHI_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_so_id number;
  b_ma_pt varchar2(10);b_ma_nhang varchar2(10);b_ma_qtac varchar2(10);b_ma_lhang varchar2(10);
  b_ma_dgoi varchar2(10);b_khoang_cachN number; b_thoi_gianN number;
begin
-- Nam - Tra so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('vchuyen,ma_nhang,ma_qtac,khoang_cach,thoi_gian');
EXECUTE IMMEDIATE b_lenh into b_ma_pt,b_ma_nhang,b_ma_qtac,b_ma_lhang,b_ma_dgoi,b_khoang_cachN,b_thoi_gianN using b_oraIn;
    b_ma_pt:=nvl(b_ma_pt,' '); b_ma_nhang:=nvl(b_ma_nhang,' ');b_ma_qtac:=nvl(b_ma_qtac,' ');
    b_khoang_cachN:=nvl(b_khoang_cachN,0); b_thoi_gianN:=nvl(b_thoi_gianN,0); 
    b_so_id:=FBH_HANG_BPHI_SO_ID(b_ma_pt,b_ma_nhang,b_ma_qtac,b_khoang_cachN,b_thoi_gianN);
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_BPHI_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_pt clob; cs_nhang clob; cs_qtac clob; cs_lt clob; cs_khd clob; cs_kbt clob;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten returning clob) order by ten returning clob) into cs_pt from bh_hang_pt;
select JSON_ARRAYAGG(json_object(ma,ten returning clob) order by ten returning clob) into cs_nhang from bh_hang_nhom;
select JSON_ARRAYAGG(json_object(ma,ten returning clob) order by ten returning clob) into cs_qtac from bh_ma_qtac where FBH_MA_NV_CO(nv,'HANG')='C';
select JSON_ARRAYAGG(json_object(ma_dk,ten,'ma_lt' value ma returning clob) returning clob) into cs_lt from bh_ma_dklt a where FBH_MA_NV_CO(nv,'HANG')='C' and FBH_MA_DKLT_HAN(ma_dk,ma)='C' and MA <> ' '; -- ma = ' ' la goc
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra returning clob) order by bt returning clob) into cs_khd from bh_kh_ttt where ps='KHD' and FBH_MA_NV_CO(nv,'HANG')='C';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra returning clob) order by bt returning clob) into cs_kbt from bh_kh_ttt where ps='KBT' and FBH_MA_NV_CO(nv,'HANG')='C';
select json_object('cs_pt' value cs_pt,'cs_nhang' value cs_nhang,'cs_qtac' value cs_qtac,
    'cs_lt' value cs_lt,'cs_khd' value cs_khd,'cs_kbt' value cs_kbt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_BPHI_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_pt varchar2(500); b_nhom varchar2(500); b_qtac varchar2(500);
    b_tu number; b_den number; b_dong number; cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('pt,nhang,qtac,tu,den');
EXECUTE IMMEDIATE b_lenh into b_pt,b_nhom,b_qtac,b_tu,b_den using b_oraIn;
b_pt:=PKH_MA_TENl(b_pt);
b_nhom:=PKH_MA_TENl(b_nhom); b_qtac:=PKH_MA_TENl(b_qtac);
b_pt:=nvl(trim(b_pt),' '); b_nhom:=nvl(trim(b_nhom),' '); b_qtac:=nvl(trim(b_qtac),' ');
select count(*) into b_dong from bh_hang_phi where b_nhom in (' ',nhang) and b_pt in (' ',pt) and b_qtac in (' ',qtac);
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(so_id,'nhang' value FBH_HANG_NHANG_TEN(nhang),
       'pt' value FBH_HANG_PT_TEN(pt),'qtac' value FBH_HANG_QTAC_TEN(qtac),khoang_cach,thoi_gian,ngay_bd,ngay_kt) returning clob) into cs_lke from
      (select so_id,nhang,pt,qtac,khoang_cach,thoi_gian,ngay_bd,ngay_kt,rownum sott from bh_hang_phi
      where b_nhom in(' ',nhang) and b_pt in(' ',pt) and b_qtac in(' ',qtac)
      order by nhang,pt,qtac)
      where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_HANG_BPHI_DKm(
    b_so_id number,b_ma varchar2,b_tien number,b_lh_bh varchar2,b_pt out number,b_phi out number,b_loi out varchar2)
AS
    b_i1 number; b_tienM number;
begin
-- Nam - Lay %phi theo khoang muc trach nhiem
b_loi:='loi:Loi xu ly FBH_HANG_BPHI_DKm:loi';
select count(*),nvl(max(tien),0) into b_i1,b_tienM from bh_hang_phi_dk where
    so_id=b_so_id and ma=b_ma and lh_bh=b_lh_bh and tien<=b_tien;
if b_i1=0 then b_loi:='loi:Khong tim duoc ty le phi theo muc trach nhiem:loi'; return; end if;
select nvl(max(pt),0),nvl(max(phi),0) into b_pt,b_phi from bh_hang_phi_dk
    where so_id=b_so_id and ma=b_ma and lh_bh=b_lh_bh and tien=b_tienM;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HANG_BPHI_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
    dt_khd clob:=''; dt_kbt clob:=''; dt_ct clob; dt_ds clob:=''; dt_dk clob:=''; dt_dkbs clob:=''; dt_lt clob:=''; dt_txt clob;
begin
-- Dan - Xem chi tiet theo so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Bieu phi da xoa:loi';
select JSON_ARRAYAGG(json_object(so_id,
    'pt' value FBH_HANG_PT_MA(pt),'nhang' value FBH_HANG_NHANG_MA(nhang),'qtac' value FBH_HANG_QTAC_MA(qtac)) returning clob)
    into dt_ct from bh_hang_phi where so_id=b_so_id;
select txt into dt_dk from bh_hang_phi_txt where so_id=b_so_id and loai='dt_dk';
select txt into dt_ds from bh_hang_phi_txt where so_id=b_so_id and loai='dt_ds';
select count(*) into b_i1 from bh_hang_phi_txt where so_id=b_so_id and loai='dt_dkbs';
if b_i1<>0 then
  select txt into dt_dkbs from bh_hang_phi_txt where so_id=b_so_id and loai='dt_dkbs';
end if;
select JSON_ARRAYAGG(json_object(ma_lt) order by bt returning clob) into dt_lt from bh_hang_phi_lt where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt from bh_hang_phi_txt where so_id=b_so_id and loai in('dt_ct','dt_lt');
select count(*) into b_i1 from bh_hang_phi_txt where so_id=b_so_id and loai='dt_khd';
if b_i1<>0 then
    select txt into dt_khd from bh_hang_phi_txt where so_id=b_so_id and loai='dt_khd';
end if;
select count(*) into b_i1 from bh_hang_phi_txt where so_id=b_so_id and loai='dt_kbt';
if b_i1<>0 then
    select txt into dt_kbt from bh_hang_phi_txt where so_id=b_so_id and loai='dt_kbt';
end if;
select json_object('so_id' value b_so_id,'dt_khd' value dt_khd,'dt_kbt' value dt_kbt,'dt_ct' value dt_ct,'dt_ds' value dt_ds,
    'dt_dk' value dt_dk,'dt_dkbs' value dt_dkbs,'dt_lt' value dt_lt,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_BPHI_CTs(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)

AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma_qtac varchar2(500); b_ma_nhang varchar2(500); b_ma_vchuyen varchar2(500);
    b_khoang_cach number; b_thoi_gian number; b_so_id number;
begin
-- Nam - Tra so_id bieu phi theo dieu kien
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_qtac,ma_nhang,vchuyen');
EXECUTE IMMEDIATE b_lenh into b_ma_qtac,b_ma_nhang,b_ma_vchuyen using b_oraIn;
b_ma_qtac:= PKH_MA_TENl(b_ma_qtac);b_ma_nhang:= PKH_MA_TENl(b_ma_nhang);b_ma_vchuyen:= PKH_MA_TENl(b_ma_vchuyen);
b_khoang_cach:=0; b_thoi_gian:=0;
b_so_id:=FBH_HANG_BPHI_SO_IDd(b_ma_vchuyen,b_ma_nhang,b_ma_qtac,b_khoang_cach,b_thoi_gian);
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_BPHI_CTd(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)

AS
    b_loi varchar2(100); b_i1 number; b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
    cs_dk clob; cs_dkbs clob; dt_khd clob:=''; cs_kbt clob:=''; cs_lt clob:='';
begin
-- Nam - Tra bieu phi theo so_id
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
select JSON_ARRAYAGG(json_object(ma,kieu,tc,lkep,lkeb,luy,ma_dk,lh_nv,t_suat,cap,lh_bh,bt) order by bt returning clob) into cs_dk
    from bh_hang_phi_dk where so_id=b_so_id and lh_bh<>'M';

select JSON_ARRAYAGG(json_object(so_id,bt,ma,ten,tc,ma_ct,kieu,tien,'ptB' value pt,phi,lkep,lkeb,luy,ma_dk,lh_nv,t_suat,cap,lh_bh,bt) order by bt returning clob) into cs_dkbs
    from bh_hang_phi_dk where so_id=b_so_id and lh_bh='M';
select JSON_ARRAYAGG(json_object(ma_lt,ten) order by bt returning clob) into cs_lt from bh_hang_phi_lt where so_id=b_so_id;
select count(*) into b_i1 from bh_hang_phi_txt where so_id=b_so_id and loai='dt_khd';
if b_i1<>0 then
    select txt into dt_khd from bh_hang_phi_txt where so_id=b_so_id and loai='dt_khd';
end if;
select count(*) into b_i1 from bh_hang_phi_txt where so_id=b_so_id and loai='dt_kbt';
if b_i1<>0 then
    select txt into cs_kbt from bh_hang_phi_txt where so_id=b_so_id and loai='dt_kbt';
end if;
select json_object('dt_khd' value dt_khd,'dt_kbt' value cs_kbt,'dt_dk' value cs_dk,'dt_dkbs' value cs_dkbs,'dt_lt' value cs_lt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--duchq lay lai bieu phi update
create or replace procedure PBH_HANG_BPHI_CTu(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)

AS
    b_loi varchar2(100); b_lenh varchar2(1000);b_so_id number; b_i1 number; b_dt_ds clob;
    ds_ma_hang pht_type.a_var;ds_ma_dgoi pht_type.a_var;b_first boolean := true;
    b_cs_txt clob:=''; cs_dk clob; cs_dkbs clob; dt_khd clob:=''; cs_kbt clob:=''; cs_lt clob:='';cs_txt clob:='[';

begin
-- Duc - Tr? % phi update
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ds');
EXECUTE IMMEDIATE b_lenh into b_dt_ds using b_oraIn;
b_lenh:=FKH_JS_LENH('ma_hang,dgoi');
EXECUTE IMMEDIATE b_lenh bulk collect into ds_ma_hang,ds_ma_dgoi using b_dt_ds;
for b_lp in 1..ds_ma_hang.count loop
  if ds_ma_hang(b_lp) is null then b_loi:='loi:Nhap thong tin hang hoa:loi'; raise PROGRAM_ERROR; end if;
  ds_ma_dgoi(b_lp):=PKH_MA_TENl(ds_ma_dgoi(b_lp));
  select count(*) into b_i1 from bh_hang_phi_ds where so_id=b_so_id and ma=ds_ma_hang(b_lp) and dgoi in (ds_ma_dgoi(b_lp), ' ');
  if b_i1=0 then b_loi:='loi:Khong tim duoc thong tin hang hoa theo bieu phi:loi'; raise PROGRAM_ERROR; end if;
  if trim(ds_ma_dgoi(b_lp))<>' ' then
    select JSON_ARRAYAGG(json_object('ma_hang' value ma,'ten' value ten,'dgoi' value FBH_HANG_DGOI_TENl(dgoi),'ptb' value pt)returning clob) into b_cs_txt
      from bh_hang_phi_ds where so_id=b_so_id and ma = ds_ma_hang(b_lp) and dgoi = ds_ma_dgoi(b_lp);
  else
    select JSON_ARRAYAGG(json_object('ma_hang' value ma,'ten' value ten,'dgoi' value FBH_HANG_DGOI_TENl(dgoi),'ptb' value pt)returning clob) into b_cs_txt
           from bh_hang_phi_ds where so_id=b_so_id and ma=ds_ma_hang(b_lp) and dgoi=' ';
  end if;
  if cs_txt is not null then
  b_cs_txt := trim(both '[]' from b_cs_txt);
  if b_cs_txt is not null then
    if not b_first then
      cs_txt := cs_txt || ',';
    end if;
    cs_txt := cs_txt || b_cs_txt;
    b_first := false;
  end if;
  end if;
 end loop;
cs_txt := cs_txt || ']';
select JSON_ARRAYAGG(json_object(ma,kieu,lkep,lkeb,luy,ma_dk,lh_nv,t_suat,cap,lh_bh) order by bt returning clob) into cs_dk
    from bh_hang_phi_dk where so_id=b_so_id and lh_bh<>'M';

select JSON_ARRAYAGG(json_object(so_id,bt,ma,ten,tc,ma_ct,kieu,tien,pt,'ptb' value pt,phi,lkep,lkeb,luy,ma_dk,lh_nv,t_suat,cap,lh_bh) order by bt returning clob) into cs_dkbs
    from bh_hang_phi_dk where so_id=b_so_id and lh_bh='M';
select JSON_ARRAYAGG(json_object(ma_lt,ten) order by bt returning clob) into cs_lt from bh_hang_phi_lt where so_id=b_so_id;
select count(*) into b_i1 from bh_hang_phi_txt where so_id=b_so_id and loai='dt_khd';
if b_i1<>0 then
    select txt into dt_khd from bh_hang_phi_txt where so_id=b_so_id and loai='dt_khd';
end if;
select count(*) into b_i1 from bh_hang_phi_txt where so_id=b_so_id and loai='dt_kbt';
if b_i1<>0 then
    select txt into cs_kbt from bh_hang_phi_txt where so_id=b_so_id and loai='dt_kbt';
end if;
select json_object('cs_txt' value cs_txt,'dt_khd' value dt_khd,'dt_kbt' value cs_kbt,'dt_dk' value cs_dk,'dt_dkbs' value cs_dkbs,'dt_lt' value cs_lt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_BPHI_DKBS(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,'ma_dk' value ma,lh_nv) order by ma returning clob) into cs_lke
    from bh_ma_dkbs where FBH_MA_NV_CO(nv,'HANG')='C' order by ma;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_BPHId_THEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)

AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_qtac varchar2(500); b_ma_nhang varchar2(500); b_ma_pt varchar2(500);
    b_khoang_cach number; b_thoi_gian number; b_so_id number; b_vu varchar2(10);
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tygia number; b_pt number; b_phi number;
    b_dk_lt clob; a_ma_lt pht_type.a_var; a_ma_dk_lt pht_type.a_var; a_ten_lt pht_type.a_nvar; a_chon_lt pht_type.a_var;
    a_maDK pht_type.a_var; a_btDK pht_type.a_num;
begin
-- Nam - Tra bieu phi theo dieu kien
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_qtac,ma_nhang,ma_pt,vu,nt_tien,nt_phi,tygia');
EXECUTE IMMEDIATE b_lenh into b_ma_qtac,b_ma_nhang,b_ma_pt,b_vu,b_nt_tien,b_nt_phi,b_tygia using b_oraIn;
b_ma_qtac:= PKH_MA_TENl(b_ma_qtac);b_ma_nhang:= PKH_MA_TENl(b_ma_nhang);b_ma_pt:= PKH_MA_TENl(b_ma_pt);
b_khoang_cach:=0; b_thoi_gian:=0;
b_nt_phi:=NVL(trim(b_nt_phi),'VND'); b_nt_tien:=NVL(trim(b_nt_tien),'VND');
b_tygia:=nvl(b_tygia,1);
if nvl(trim(b_nt_phi),'VND')='VND' and b_tygia<=0 then b_tygia:=1; end if;
b_so_id:=FBH_HANG_BPHI_SO_IDd(b_ma_pt,b_ma_nhang,b_ma_qtac,b_khoang_cach,b_thoi_gian);
b_oraOut:='';
if b_so_id<>0 then
  if b_vu='dk' then
   select JSON_ARRAYAGG(json_object(ma,ten,'tien' value case when b_nt_tien='VND' then tien else round(tien/b_tygia,2) end,
                'ptB' value case when b_nt_phi<>'VND' then decode(sign(pt-100),1,round(pt/b_tygia,4),pt) else pt end,
                'pt' value '',ma_ct,tc,phi,cap,lh_nv,lkeP,bt,'ptk' value decode(sign(pt-50),1,'T','P')) order by bt,ma,ten returning clob) into b_oraOut from
        (select ma,ten,tien,pt,ma_ct,tc,phi,cap,lh_nv,lkeP,bt
                from bh_hang_phi_dk where so_id=b_so_id and lh_bh='M' union
        select ma,ten,null tien,null pt,'' ma_ct,'T' tc,null phi,null cap,'' lh_nv,'' lkeP,999 from bh_ma_dkbs where FBH_MA_NV_CO(nv,'HANG')='C');
  elsif b_vu='lt' then
        select count(*) into b_i1 from bh_hang_phi_txt where so_id=b_so_id and loai='dt_lt';
        if b_i1 >0 then
             select txt into b_dk_lt from bh_hang_phi_txt where so_id=b_so_id and loai='dt_lt';
             b_lenh:=FKH_JS_LENH('ma_lt,ten,ma_dk,chon');
             EXECUTE IMMEDIATE b_lenh bulk collect into a_ma_lt,a_ten_lt,a_ma_dk_lt,a_chon_lt using b_dk_lt;
             if a_ma_lt.count > 0 then
               for b_i1 in 1..a_ma_lt.count loop
                    insert into temp_1(c1,c2,c3,c4) VALUES (a_ma_lt(b_i1),a_ten_lt(b_i1),a_ma_dk_lt(b_i1),a_chon_lt(b_i1));
               end loop;
             end if;
          end if;
          for r_lp in (select ma,ten,ma_dk from bh_ma_dklt where FBH_MA_NV_CO(nv,'HANG')='C') loop
            select count(*) into b_i1 from temp_1 where c1=r_lp.ma;
            if b_i1=0 then insert into temp_1(c1,c2,c3,c4) values(r_lp.ma,r_lp.ten,r_lp.ma_dk,' '); end if;
          end loop;
          select JSON_ARRAYAGG(json_object('ma_lt' value c1,'ten' value c2,'ma_dk' value c3,'chon' value c4)
              order by c1,c2 returning clob) into b_oraOut from temp_1;
    end if;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_BPHI_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_i1 number; b_ma_ct varchar2(10);
    b_kt number; b_i2 number;
    -- thong tin chung
    b_ma_pt varchar2(10); b_ma_nhang varchar2(10); b_ma_qtac varchar2(10);
    b_khoang_cach number; b_thoi_gian number; b_ngay_bd number; b_ngay_kt number;
    -- danh sach hang
    ds_ma pht_type.a_var; ds_ten pht_type.a_nvar; ds_dgoi pht_type.a_var; ds_pt pht_type.a_num;
    -- dieu khoan chinh
    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var; dk_ma_ct pht_type.a_var;
    dk_ma_dk pht_type.a_var; dk_kieu pht_type.a_var; dk_tien pht_type.a_num; dk_pt pht_type.a_num;
    dk_phi pht_type.a_num; dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var; dk_luy pht_type.a_var;
    dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num; dk_lh_bh pht_type.a_var;
    -- dieu khoan bo sung
    dkB_ma pht_type.a_var; dkB_ten pht_type.a_nvar; dkB_tc pht_type.a_var; dkB_ma_ct pht_type.a_var;
    dkB_kieu pht_type.a_var; dkB_tien pht_type.a_num; dkB_pt pht_type.a_num;
    dkB_phi pht_type.a_num; dkB_lkeP pht_type.a_var; dkB_lkeB pht_type.a_var; dkB_luy pht_type.a_var;
    dkB_ma_dk pht_type.a_var;

    lt_ma_dk pht_type.a_var; lt_ma_lt pht_type.a_var; lt_ten pht_type.a_nvar;
    b_dt_ct clob; b_dt_ds clob; b_dt_dk clob:=''; b_dt_dkbs clob:=''; b_dt_lt clob:=''; b_dt_khd clob:=''; b_dt_kbt clob:=''; b_so_id number;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_ds,dt_dk,dt_dkbs,dt_lt,dt_khd,dt_kbt');
EXECUTE IMMEDIATE b_lenh into b_dt_ct,b_dt_ds,b_dt_dk,b_dt_dkbs,b_dt_lt,b_dt_khd,b_dt_kbt using b_oraIn;
FKH_JS_NULL(b_dt_ct); FKH_JSa_NULL(b_dt_dk); FKH_JSa_NULL(b_dt_dkbs); 
FKH_JSa_NULL(b_dt_lt); FKH_JSa_NULL(b_dt_khd); FKH_JSa_NULL(b_dt_kbt);
b_lenh:=FKH_JS_LENH('pt,nhang,qtac,khoang_cach,thoi_gian,ngay_bd,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma_pt,b_ma_nhang,b_ma_qtac,b_khoang_cach,b_thoi_gian,b_ngay_bd,b_ngay_kt using b_dt_ct;
if trim(b_ma_pt) is null then
    b_loi:='loi:Nhap van chuyen:loi'; raise PROGRAM_ERROR;
end if;
if trim(b_ma_nhang) is null then
    b_loi:='loi:Nhap nhom hang:loi'; raise PROGRAM_ERROR;
end if;
if trim(b_ma_qtac) is null then
    b_loi:='loi:Nhap quy tac:loi'; raise PROGRAM_ERROR;
end if;
if b_khoang_cach > 0  and b_thoi_gian > 0 then
    b_loi:='loi:Chi nhap khoang cach hoac thoi gian:loi'; raise PROGRAM_ERROR;
end if;
if b_khoang_cach is null then b_khoang_cach:=0; end if;
if b_thoi_gian is null then b_thoi_gian:=0; end if;
if b_ngay_bd is null or b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
if b_ngay_kt is null or b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_lenh:=FKH_JS_LENH('ma,ten,dgoi,pt');
EXECUTE IMMEDIATE b_lenh bulk collect into ds_ma,ds_ten,ds_dgoi,ds_pt using b_dt_ds;
b_kt:=ds_ma.count;
if b_kt=0 then b_loi:='loi:Nhap danh sach:loi'; raise PROGRAM_ERROR; end if;
for b_lp in 1..ds_ma.count loop
    if ds_ma(b_lp)=' ' then b_loi:='loi:Sai chi tiet dong '||to_char(b_lp)||':loi'; raise PROGRAM_ERROR; end if;
    ds_ten(b_lp):=FBH_HANG_LOAI_TEN(ds_ma(b_lp));
    b_i1:=b_lp+1;
    for b_lp1 in b_i1..ds_ma.count loop
        if ds_ma(b_lp)=ds_ma(b_lp1) and ds_dgoi(b_lp)=ds_dgoi(b_lp1) then b_loi:='loi:Trung ma hang: '||ds_ma(b_lp)||':loi'; raise PROGRAM_ERROR;
        end if;
    end loop;
end loop;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,ma_dk,kieu,tien,pt,phi,lkep,lkeb,luy');
EXECUTE IMMEDIATE b_lenh bulk collect into
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_ma_dk,dk_kieu,dk_tien,dk_pt,dk_phi,dk_lkeP,dk_lkeB,dk_luy using b_dt_dk;
b_kt:=dk_ma.count;
if b_kt=0 then b_loi:='loi:Nhap dieu khoan:loi'; raise PROGRAM_ERROR; end if;
for b_lp in 1..b_kt loop dk_lh_bh(b_lp):='C'; end loop;
if trim(b_dt_dkbs) is not null then
    EXECUTE IMMEDIATE b_lenh bulk collect into
        dkB_ma,dkB_ten,dkB_tc,dkB_ma_ct,dkB_ma_dk,dkB_kieu,dkB_tien,dkB_pt,dkB_phi,
        dkB_lkeP,dkB_lkeB,dkB_luy using b_dt_dkbs;
    for b_lp in 1..dkB_ma.count loop
        b_kt:=b_kt+1; dk_lh_bh(b_kt):='M';
        dk_ma(b_kt):=dkB_ma(b_lp); dk_ten(b_kt):=dkB_ten(b_lp); dk_tc(b_kt):=dkB_tc(b_lp);
        dk_ma_ct(b_kt):=dkB_ma_ct(b_lp); dk_ma_dk(b_kt):=dkB_ma_dk(b_lp); dk_kieu(b_kt):=dkB_kieu(b_lp);
        dk_tien(b_kt):=dkB_tien(b_lp); dk_pt(b_kt):=dkB_pt(b_lp); dk_phi(b_kt):=dkB_phi(b_lp);
        dk_lkeP(b_kt):=dkB_lkeP(b_lp); dk_lkeB(b_kt):=dkB_lkeB(b_lp); dk_luy(b_kt):=dkB_luy(b_lp);
    end loop;
end if;
for b_lp in 1..dk_ma.count loop
    b_loi:='loi:Sai chi tiet dong '||to_char(b_lp)||':loi';
    dk_ma(b_lp):=nvl(trim(dk_ma(b_lp)),' ');
    if dk_ma(b_lp)=' ' then return; end if;
    if trim(dk_ten(b_lp)) is null then
        b_i1:=b_lp-1; b_i2:=0;
        for b_lp1 in 1..b_i1 loop
            if dk_ma(b_lp1)=dk_ma(b_lp) then b_i2:=1; exit; end if;
        end loop;
        if b_i2=0 then return; end if;
    end if;
    dk_tc(b_lp):=nvl(trim(dk_tc(b_lp)),'C');
    dk_ma_ct(b_lp):=nvl(trim(dk_ma_ct(b_lp)),' ');
    if dk_ma(b_lp)=dk_ma_ct(b_lp) then b_loi:='loi:Trung ma cap tren ma: '||dk_ma(b_lp)||':loi'; raise PROGRAM_ERROR; end if;
    if dk_tc(b_lp)='C' then
        dk_lkeP(b_lp):=nvl(trim(dk_lkeP(b_lp)),'G'); dk_lkeB(b_lp):=nvl(trim(dk_lkeB(b_lp)),'G');
    else
        dk_lkeP(b_lp):=nvl(trim(dk_lkeP(b_lp)),'T'); dk_lkeB(b_lp):=nvl(trim(dk_lkeB(b_lp)),'T');
    end if;
    dk_luy(b_lp):=nvl(trim(dk_luy(b_lp)),'C'); dk_kieu(b_lp):=nvl(trim(dk_kieu(b_lp)),'T');
    dk_ma_dk(b_lp):=nvl(trim(dk_ma_dk(b_lp)),' '); dk_lh_nv(b_lp):=' '; dk_t_suat(b_lp):=0;
    if dk_ma_dk(b_lp)<>' ' then
        if dk_lh_bh(b_lp)='C' then
            if FBH_MA_DK_HAN(dk_ma_dk(b_lp))='K' then
                b_loi:='loi:Dieu khoan: '||dk_ma_dk(b_lp)||' da het su dung:loi'; raise PROGRAM_ERROR;
            end if;
            select nvl(min(lh_nv),' ') into dk_lh_nv(b_lp) from bh_ma_dk where ma=dk_ma_dk(b_lp);
        else
            if FBH_MA_DKBS_HAN(dk_ma_dk(b_lp))='K' then
                b_loi:='loi:Dieu khoan bo sung: '||dk_ma_dk(b_lp)||' da het su dung:loi'; raise PROGRAM_ERROR;
            end if;
            select nvl(min(lh_nv),' ') into dk_lh_nv(b_lp) from bh_ma_dkbs where ma=dk_ma_dk(b_lp);
        end if;
        if dk_lh_nv(b_lp)<>' ' then dk_t_suat(b_lp):=FBH_MA_LHNV_THUE(dk_lh_nv(b_lp)); end if;
    end if;
end loop;
for b_lp in 1..dk_ma.count loop
    b_i1:=b_lp+1;
    for b_lp1 in b_i1..dk_ma.count loop
        if dk_ma(b_lp)=dk_ma(b_lp1) and dk_tien(b_lp)=dk_tien(b_lp1) then b_loi:='loi:Trung ma: '||dk_ma(b_lp)||':loi'; raise PROGRAM_ERROR;
        end if;
    end loop;
    if dk_tc(b_lp)='T' then
        b_i1:=0;
        for b_lp1 in 1..dk_ma.count loop
            if dk_ma(b_lp)=dk_ma_ct(b_lp1) and dk_tc(b_lp1)<>'K' then b_i1:=1; exit; end if;
        end loop;
        if b_i1=0 then b_loi:='loi:Nhap ma chi tiet ma: '||dk_ma(b_lp)||':loi'; raise PROGRAM_ERROR; end if;
    end if;
end loop;
for b_lp in 1..dk_ma.count loop
    if dk_tc(b_lp)='C' and dk_ma_ct(b_lp)!=' ' then
        b_i1:=0;
        for b_lp1 in 1..dk_ma.count loop
            if dk_ma(b_lp1)=dk_ma_ct(b_lp) and dk_tc(b_lp1)='T' then b_i1:=1; exit; end if;
        end loop;
        if b_i1=0 then b_loi:='loi:Nhap ma cap tren ma: '||dk_ma(b_lp)||':loi'; raise PROGRAM_ERROR; end if;
    end if;
end loop;
for b_lp in 1..dk_ma.count loop
    if dk_tc(b_lp)='C' and dk_ma_ct(b_lp)!=' ' then
        b_lenh:=dk_ma(b_lp); b_ma_ct:=dk_ma_ct(b_lp);
        while b_ma_ct<>' ' loop
            b_i1:=0;
            for b_lp1 in 1..dk_ma.count loop
                if dk_ma(b_lp1)=b_ma_ct then b_i1:=b_lp1; exit; end if;
            end loop;
            if b_i1=0 then
                b_ma_ct:='';
            else
                b_ma_ct:=dk_ma_ct(b_i1);
                if PKH_MA_MA(b_lenh,b_ma_ct) then b_loi:='loi:Vong lap ma cap tren ma: '||dk_ma(b_lp)||':loi'; raise PROGRAM_ERROR; end if;
                b_lenh:=b_lenh||','||dk_ma(b_i1);
            end if;
        end loop;
    end if;
end loop;
if trim(b_dt_lt) is not null then
    b_lenh:=FKH_JS_LENH('ma_dk,ma_lt,ten');
    EXECUTE IMMEDIATE b_lenh bulk collect into lt_ma_dk,lt_ma_lt,lt_ten using b_dt_lt;
    for b_lp in 1..lt_ma_lt.count loop
        if trim(lt_ma_lt(b_lp)) is null then
            b_loi:='loi:Nhap ma loai tru dong '||to_char(b_lp)||':loi'; raise PROGRAM_ERROR;
        end if;
        if trim(lt_ma_dk(b_lp)) is null then lt_ma_dk(b_lp):=' '; end if;
        if FBH_MA_DKLT_HAN(lt_ma_dk(b_lp),lt_ma_lt(b_lp))='K' then
            b_loi:='loi:Dieu khoan loai tru: '||lt_ma_lt(b_lp)||' da het su dung:loi'; raise PROGRAM_ERROR;
        end if;
    end loop;
end if;
b_so_id:=FBH_HANGH_BPHI_SO_ID(b_ma_pt,b_ma_nhang,b_ma_qtac,b_khoang_cach,b_thoi_gian);
if b_so_id<>0 then
    delete bh_hang_phi_txt where so_id=b_so_id;
    delete bh_hang_phi_lt where so_id=b_so_id;
    delete bh_hang_phi_dk where so_id=b_so_id;
    delete bh_hang_phi_ds where so_id=b_so_id;
    delete bh_hang_phi where so_id=b_so_id;
else
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_loi:='loi:Loi Table bh_hang_phi:loi';
insert into bh_hang_phi values(b_ma_dvi,b_so_id,b_ma_pt,b_ma_nhang,b_ma_qtac,b_khoang_cach,b_thoi_gian,b_ngay_bd,b_ngay_kt,b_nsd);
insert into bh_hang_phi_txt values(b_ma_dvi,b_so_id,'dt_ct',b_dt_ct);
insert into bh_hang_phi_txt values(b_ma_dvi,b_so_id,'dt_dk',b_dt_dk);
insert into bh_hang_phi_txt values(b_ma_dvi,b_so_id,'dt_dkbs',b_dt_dkbs);
insert into bh_hang_phi_txt values(b_ma_dvi,b_so_id,'dt_ds',b_dt_ds);
for b_lp in 1..dk_ma.count loop
    insert into bh_hang_phi_dk values(b_ma_dvi,b_so_id,b_lp,dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),
        dk_kieu(b_lp),dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),dk_lkeP(b_lp),dk_lkeB(b_lp),dk_luy(b_lp),
        dk_ma_dk(b_lp),dk_lh_nv(b_lp),dk_t_suat(b_lp),0,dk_lh_bh(b_lp));
end loop;
for b_lp in 1..ds_ma.count loop
    insert into bh_hang_phi_ds values(b_ma_dvi,b_so_id,b_lp,ds_ma(b_lp),ds_ten(b_lp),ds_dgoi(b_lp),ds_pt(b_lp));
end loop;
for r_lp in(select ma,ma_ct,so_id,bt,level from (select t.so_id,t.bt,t.ma,t.ma_ct from bh_hang_phi_dk t where t.so_id = b_so_id) t start with t.ma_ct=' ' CONNECT BY prior t.ma=t.ma_ct) loop
    update bh_hang_phi_dk set cap=r_lp.level where so_id=b_so_id and bt=r_lp.bt;
end loop;
if lt_ma_lt.count<>0 then
    for b_lp in 1..lt_ma_lt.count loop
        insert into bh_hang_phi_lt values(b_ma_dvi,b_so_id,b_lp,lt_ma_dk(b_lp),lt_ma_lt(b_lp),lt_ten(b_lp));
    end loop;
    insert into bh_hang_phi_txt values(b_ma_dvi,b_so_id,'dt_lt',b_dt_lt);
end if;
if trim(b_dt_khd) is not null then
    insert into bh_hang_phi_txt values(b_ma_dvi,b_so_id,'dt_khd',b_dt_khd);
end if;
if trim(b_dt_kbt) is not null then
    insert into bh_hang_phi_txt values(b_ma_dvi,b_so_id,'dt_kbt',b_dt_kbt);
end if;
commit;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_BPHI_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
begin
-- Nam - Xoa bieu phi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then b_loi:='loi:Chon bieu phi can xoa:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table bh_hang_phi:loi';
delete bh_hang_phi_txt where so_id=b_so_id;
delete bh_hang_phi_lt where so_id=b_so_id;
delete bh_hang_phi_dk where so_id=b_so_id;
delete bh_hang_phi where so_id=b_so_id;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_QTAC(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(1000); cs_lke clob:='';
begin
-- Tra ma quy tac theo nv
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into cs_lke from bh_ma_qtac where nv='HANG';
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_HANG_BPHI_DSp(
    b_so_id number,b_ma_lhang varchar2,b_ma_dgoi varchar2,dt_txt out clob,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Nam - Lay %phi theo khoang muc trach nhiem
select count(*) into b_i1 from bh_hang_phi_ds where so_id=b_so_id and ma=b_ma_lhang and dgoi in (b_ma_dgoi, ' ');
if b_i1=0 then b_loi:='loi:Khong tim duoc ty le phi theo hang hoa:loi'; return; end if;
if trim(b_ma_dgoi)<>' ' then
  select JSON_ARRAYAGG(json_object('ptB' value pt,'ptK' value decode(sign(pt-100),1,'T','P')) returning clob)
         into dt_txt from bh_hang_phi_ds where so_id=b_so_id and ma=b_ma_lhang and dgoi=b_ma_dgoi;
else
  select JSON_ARRAYAGG(json_object('ptB' value pt,'ptK' value decode(sign(pt-100),1,'T','P')) returning clob)
         into dt_txt from bh_hang_phi_ds where so_id=b_so_id and ma=b_ma_lhang and dgoi=' ';
end if;
end;
/
create or replace procedure PBH_HANG_BPHI_DSp(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)

AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma_lhang varchar2(10); b_ma_dgoi varchar2(200); b_so_idP number;
    dt_txt clob:= ' ';
begin
-- Nam - Tra so_id bieu phi theo dieu kien
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_lhang,ma_dgoi,so_idP');
EXECUTE IMMEDIATE b_lenh into b_ma_lhang,b_ma_dgoi,b_so_idP using b_oraIn;
b_ma_dgoi:=PKH_MA_TENl(b_ma_dgoi);
b_ma_dgoi:=nvl(trim(b_ma_dgoi),' ');
if b_ma_dgoi<>' ' then
  FBH_HANG_BPHI_DSp(b_so_idP,b_ma_lhang,b_ma_dgoi,dt_txt,b_loi);
  if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
select json_object('dt_txt' value dt_txt) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--Danh muc kiem soat
create or replace function FBH_HANG_PQU_KS_SO_ID(b_pt varchar2,b_ma_qtac varchar2,b_loai varchar2,b_dgoi varchar2) return number
AS
    b_kq number;
begin
-- Nam
select nvl(min(so_id),0) into b_kq from bh_hang_ks where pt=b_pt and ma_qtac=b_ma_qtac and loai=b_loai and dgoi=b_dgoi;
return b_kq;
end;
/
create or replace function FBH_HANG_KS_KTRA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pt varchar2,b_qtac varchar2,
    a_loai pht_type.a_var,a_dgoi pht_type.a_var) return varchar2
as
    b_i1 number; b_kq varchar2(1):='K';
begin
    for b_lp in 1..a_loai.count loop
        select count(*) into b_i1 from bh_hang_ks where ma_dvi=b_ma_dvi and nsd=b_nsd 
           and pt in (' ',b_pt) and ma_qtac in (' ',b_qtac) and loai in (' ',a_loai(b_lp)) and dgoi in (' ',a_dgoi(b_lp));
        if b_i1<> 0 then b_kq:='C'; end if;
    end loop;
return b_kq;
end;
/
create or replace procedure PBH_HANG_PQU_KS_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_so_id number;
    b_pt varchar2(10); b_ma_qtac varchar2(10); b_loai varchar2(10); b_dgoi varchar2(10);
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('pt,ma_qtac,loai,dgoi');
EXECUTE IMMEDIATE b_lenh into b_pt,b_ma_qtac,b_loai,b_dgoi using b_oraIn;
select nvl(min(so_id),0) into b_so_id from bh_hang_ks where pt=b_pt and ma_qtac=b_ma_qtac and loai=b_loai and dgoi=b_dgoi;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_PQU_KS_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_so_id number;
    b_pt varchar2(10); b_ma_qtac varchar2(10); b_loai varchar2(10); b_dgoi varchar2(10);
    dt_ct clob;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct');
EXECUTE IMMEDIATE b_lenh into dt_ct using b_oraIn;
FKH_JS_NULL(dt_ct);
b_lenh:=FKH_JS_LENH('pt,ma_qtac,loai,dgoi');
EXECUTE IMMEDIATE b_lenh into b_pt,b_ma_qtac,b_loai,b_dgoi using dt_ct;
b_so_id:=FBH_HANG_PQU_KS_SO_ID(b_pt,b_ma_qtac,b_loai,b_dgoi);
if b_so_id<>0 then
    delete bh_hang_ks where so_id=b_so_id;
else
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
insert into bh_hang_ks values(b_ma_dvi,b_so_id,b_pt,b_ma_qtac,b_loai,b_dgoi,b_nsd,sysdate);
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_PQU_KS_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_tu number; b_den number; b_dong number:=0; dt_lke clob:='';
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tu,den');
EXECUTE IMMEDIATE b_lenh into b_tu,b_den using b_oraIn;
select count(*) into b_dong from bh_hang_ks;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object('pt' value FBH_HANG_PT_TEN(pt),'ma_qtac' value FBH_MA_QTAC_TEN(ma_qtac),
            'loai' value FBH_HANG_LOAI_TEN(loai),'dgoi' value FBH_HANG_DGOI_TEN(dgoi),so_id) order by pt,ma_qtac,loai,dgoi returning clob) into dt_lke from
    (select pt,ma_qtac,loai,dgoi,so_id,rownum sott from bh_hang_ks order by pt,ma_qtac,loai,dgoi)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'dt_lke' value dt_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_PQU_KS_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_tu number; b_den number; b_hangKt number;
    b_pt varchar2(10); b_ma_qtac varchar2(10); b_loai varchar2(10); b_dgoi varchar2(10);
    b_trang number:=1; b_dong number:=0; dt_lke clob:='';
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('pt,ma_qtac,loai,dgoi,hangkt');
EXECUTE IMMEDIATE b_lenh into b_pt,b_ma_qtac,b_loai,b_dgoi,b_hangKt using b_oraIn;
b_pt:=nvl(trim(b_pt),' '); b_ma_qtac:=nvl(trim(b_ma_qtac),' ');
b_loai:=nvl(trim(b_loai),' '); b_dgoi:=nvl(trim(b_dgoi),' ');
select count(*) into b_dong from bh_hang_ks;
select nvl(min(sott),b_dong) into b_tu from
    (select a.*,rownum sott from bh_hang_ks a order by pt,ma_qtac,loai,dgoi)
    where pt>=b_pt and ma_qtac>=b_ma_qtac and loai>=b_loai and dgoi>=b_dgoi;
PKH_LKE_VTRI(b_hangKt,b_tu,b_den,b_trang);
select JSON_ARRAYAGG(json_object('pt' value FBH_HANG_PT_TEN(pt),'ma_qtac' value FBH_MA_QTAC_TEN(ma_qtac),
            'loai' value FBH_HANG_LOAI_TEN(loai),'dgoi' value FBH_HANG_DGOI_TEN(dgoi),so_id) order by pt,ma_qtac,loai,dgoi returning clob) into dt_lke from
    (select pt,ma_qtac,loai,dgoi,so_id,rownum sott from bh_hang_ks order by pt,ma_qtac,loai,dgoi)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'dt_lke' value dt_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_PQU_KS_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
    dt_ct clob;
begin
-- Nam - Xem chi tiet theo so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('pt' value FBH_HANG_PT_TENl(pt),'ma_qtac' value FBH_MA_QTAC_TENl(ma_qtac),
            'loai' value FBH_HANG_LOAI_TENl(loai),'dgoi' value FBH_HANG_DGOI_TENl(dgoi))
       into dt_ct from bh_hang_ks where so_id=b_so_id;
select json_object('so_id' value b_so_id,'dt_ct' value dt_ct returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_PQU_KS_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100);
    b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=nvl(b_so_id,0);
if b_so_id<>0 then
    delete bh_hang_ks where so_id=b_so_id;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_HANG_MA_SDBS(b_so_id number) return nvarchar2
as
    b_kq nvarchar2(200);
begin
-- Dan - Tra so id dau
select FKH_JS_GTRIs(FKH_JS_BONH(txt),'ma_sdbs') into b_kq from bh_hang_txt where so_id=b_so_id and loai='dt_ct';
return b_kq;
end;
