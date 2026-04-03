create or replace function FBH_TAU_TUOI(b_nam_sx number) return number
AS
    b_kq number:=0; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Tra tuoi theo nam SX
if b_nam_sx is null then b_kq:=0;
elsif b_nam_sx>1900 then
    b_kq:=b_nam_sx*10000+101;
    b_kq:=FKH_KHO_NASO(b_kq,b_ngay);
end if;
if b_kq not between 0 and 100 then b_kq:=0; end if;
return b_kq;
end;
/
-- Nhom tau ---
create or replace function FBH_TAU_NHOM_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_tau_nhom where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_TAU_NHOM_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_tau_nhom where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_TAU_NHOM_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_tau_nhom where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_TAU_NHOM_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into cs_lke from bh_tau_nhom;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_NHOM_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
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
    select count(*) into b_dong from bh_tau_nhom;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select * from bh_tau_nhom order by ma))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_tau_nhom where upper(ma) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,json_object(a.*,'xep' value ma) obj from bh_tau_nhom a)
            where upper(ma) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_NHOM_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_tau_nhom;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_tau_nhom;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_NHOM_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,ngay_kt) into b_kq from bh_tau_nhom where ma=b_ma;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_NHOM_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_ngay_kt using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_tau_nhom where ma=b_ma;
insert into bh_tau_nhom values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_NHOM_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_tau_nhom where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Loai tau ---
create or replace function FBH_TAU_LOAI_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_tau_loai where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_TAU_LOAI_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_tau_loai where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_TAU_LOAI_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_tau_loai where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_TAU_LOAI_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into cs_lke from bh_tau_loai;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_LOAI_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
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
    select count(*) into b_dong from bh_tau_loai;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select * from bh_tau_loai order by ma))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_tau_loai where upper(ma) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,json_object(a.*,'xep' value ma) obj from bh_tau_loai a)
            where upper(ma) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_LOAI_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_tau_loai;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_tau_loai;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_LOAI_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,ngay_kt) into b_kq from bh_tau_loai where ma=b_ma;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_LOAI_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_ngay_kt using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_tau_loai where ma=b_ma;
insert into bh_tau_loai values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_LOAI_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_tau_loai where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Ma cap tau --
create or replace function FBH_TAU_CAP_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_tau_cap where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_TAU_CAP_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_tau_cap where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_TAU_CAP_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_tau_cap where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_TAU_CAP_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into cs_lke from bh_tau_cap;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_CAP_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
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
    select count(*) into b_dong from bh_tau_cap;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select * from bh_tau_cap order by ma))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_tau_cap where upper(ma) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,json_object(a.*,'xep' value ma) obj from bh_tau_cap a)
            where upper(ma) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;

/
create or replace procedure PBH_TAU_CAP_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_tau_cap;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_tau_cap;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_CAP_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,ngay_kt) into b_kq from bh_tau_cap where ma=b_ma;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_CAP_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_ngay_kt using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_tau_cap where ma=b_ma;
insert into bh_tau_cap values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_CAP_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_tau_cap where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Ma vat lieu dong --
create or replace function FBH_TAU_VLIEU_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_tau_vlieu where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_TAU_VLIEU_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_tau_vlieu where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_TAU_VLIEU_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_tau_vlieu where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_TAU_VLIEU_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into cs_lke from bh_tau_vlieu;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_VLIEU_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
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
    select count(*) into b_dong from bh_tau_vlieu;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select * from bh_tau_vlieu order by ma))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_tau_vlieu where upper(ma) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,json_object(a.*,'xep' value ma) obj from bh_tau_vlieu a)
            where upper(ma) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_VLIEU_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_tau_vlieu;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_tau_vlieu;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_VLIEU_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,ngay_kt) into b_kq from bh_tau_vlieu where ma=b_ma;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_VLIEU_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_ngay_kt using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_tau_vlieu where ma=b_ma;
insert into bh_tau_vlieu values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_VLIEU_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_tau_vlieu where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Ma hoi --
create or replace function FBH_TAU_HOI_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_tau_hoi where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_TAU_HOI_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_tau_hoi where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_TAU_HOI_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_tau_hoi where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_TAU_HOI_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into cs_lke from bh_tau_hoi;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_HOI_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
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
    select count(*) into b_dong from bh_tau_hoi;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select * from bh_tau_hoi order by ma))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_tau_hoi where upper(ma) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,json_object(a.*,'xep' value ma) obj from bh_tau_hoi a)
            where upper(ma) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_HOI_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_tau_hoi;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_tau_hoi;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_HOI_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(20):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,loai,ngay_kt) into b_kq from bh_tau_hoi where ma=b_ma;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_HOI_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(20); b_ten nvarchar2(500); b_loai varchar2(1); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,loai,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_loai,b_ngay_kt using b_oraIn;
if trim(b_ma) is null or trim(b_ten) is null then b_loi:='loi:Nhap ma, ten:loi'; raise PROGRAM_ERROR; end if;
b_loai:=nvl(trim(b_loai),'C');
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_tau_hoi where ma=b_ma;
insert into bh_tau_hoi values(b_ma_dvi,b_ma,b_ten,b_loai,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_HOI_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(20):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_tau_hoi where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Ma dieu kien chinh --
create or replace function FBH_TAU_DKC_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_tau_dkc where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_TAU_DKC_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_tau_dkc where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_TAU_DKC_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_tau_dkc where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_TAU_DKC_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into cs_lke from bh_tau_dkc;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_DKC_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
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
    select count(*) into b_dong from bh_tau_dkc;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select * from bh_tau_dkc order by ma))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_tau_dkc where upper(ma) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,json_object(a.*,'xep' value ma) obj from bh_tau_dkc a)
            where upper(ma) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;

/
create or replace procedure PBH_TAU_DKC_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_tau_dkc;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_tau_dkc;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_DKC_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(20):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,'ma_sp' value FBH_TAU_SP_TENl(ma_sp),ngay_kt) into b_kq from bh_tau_dkc where ma=b_ma;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_DKC_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma varchar2(20); b_ten nvarchar2(500); b_ma_sp varchar2(20); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,ma_sp,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_ma_sp,b_ngay_kt using b_oraIn;
if trim(b_ma) is null or trim(b_ten) is null then b_loi:='loi:Nhap ma, ten:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_tau_dkc where ma=b_ma;
insert into bh_tau_dkc values(b_ma_dvi,b_ma,b_ten,b_ma_sp,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_DKC_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(20):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_tau_dkc where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Ma san pham --
create or replace function FBH_TAU_SP_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_tau_sp where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_TAU_SP_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_tau_sp where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_TAU_SP_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_tau_sp where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_TAU_SP_XEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into cs_lke from bh_tau_sp;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_SP_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
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
    select count(*) into b_dong from bh_tau_sp;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select * from bh_tau_sp order by ma))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_tau_sp where upper(ma) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,json_object(a.*,'xep' value ma) obj from bh_tau_sp a)
            where upper(ma) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_SP_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_tau_sp;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_tau_sp;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_SP_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,ngay_kt) into b_kq from bh_tau_sp where ma=b_ma;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_SP_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_ngay_kt using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_tau_sp where ma=b_ma;
insert into bh_tau_sp values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_SP_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_tau_sp where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_TAU_MDSD_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_tau_mdsd where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_TAU_MDSD_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_tau_mdsd where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_TAU_MDSD_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_tau_mdsd where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_TAU_MDSD_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into cs_lke from bh_tau_mdsd;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_MDSD_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_tau_mdsd;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_tau_mdsd;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_MDSD_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_tau_mdsd;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_tau_mdsd;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_MDSD_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,ngay_kt) into b_kq from bh_tau_mdsd where ma=b_ma;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_MDSD_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_ngay_kt using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_tau_mdsd where ma=b_ma;
insert into bh_tau_mdsd values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_MDSD_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_tau_mdsd where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Ma nguyen nhan ton that
create or replace function FBH_TAU_NNTT_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_tau_nntt where ma=b_ma and tc='C';
return b_kq;
end;
/
create or replace function FBH_TAU_NNTT_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_tau_nntt where ma=b_ma and tc='C';
return b_kq;
end;
/
create or replace function FBH_TAU_NNTT_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_tau_nntt where ma=b_ma and tc='C' and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_TAU_NNTT_XEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngay number:=PKH_NG_CSO(sysdate); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma) into cs_lke from bh_tau_nntt a where tc='C' and ngay_kt>b_ngay;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_NNTT_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_tau_nntt;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep)) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_tau_nntt order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_tau_nntt where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma)) into cs_lke from
        (select a.*,rownum sott from bh_tau_nntt a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_NNTT_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_tau_nntt;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_tau_nntt order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_tau_nntt order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep)) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_tau_nntt order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_tau_nntt where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_tau_nntt where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma)) into cs_lke from
        (select a.*,rownum sott from bh_tau_nntt a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_NNTT_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma'); cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma chua nhap hoac da xoa:loi';
select json_object(ma,txt) into cs_ct from bh_tau_nntt  where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_NNTT_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_tc varchar2(1);
    b_ma_ct varchar2(10); b_ngay_kt number;
begin
-- Dan
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
    select 0 into b_i1 from bh_tau_nntt where ma=b_ma_ct and tc='T';
end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_tau_nntt where ma=b_ma;
insert into bh_tau_nntt values(b_ma_dvi,b_ma,b_ten,b_tc,b_ma_ct,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_NNTT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_tau_nntt where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_tau_nntt where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Ty le phi / tgian BH
create or replace function FBH_TAU_TLTG_TLE(b_ngay_hl number,b_ngay_kt number) return number
AS
    b_kq number:=0; b_i1 number; b_th number:=FKH_KHO_THSO(b_ngay_hl,b_ngay_kt); b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Tra ty le phi < 12 thang
if b_th<12 then
    select nvl(max(tltg),0) into b_i1 from bh_tau_tltg where tltg<=b_th and b_ngay between ngay_bd and ngay_kt;
    if b_i1<>0 then
        select tlph into b_kq from bh_tau_tltg where tltg=b_i1 and b_ngay between ngay_bd and ngay_kt;
        b_kq:=b_kq/100;
    end if;
end if;
if b_kq=0 then
    b_kq:=FKH_KHO_NGSO(b_ngay_hl,b_ngay_kt)+1;
    if b_kq in(365,366) then b_kq:=1; else b_kq:=b_kq/365; end if;
end if;
return b_kq;
end;
/
create or replace procedure PBH_TAU_TLTG_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_tltg number:=FKH_JS_GTRIs(b_oraIn,'tltg');
    cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Thoi gian da xoa:loi';
select json_object(tltg,tlph,ngay_bd,ngay_kt) into cs_ct from bh_tau_tltg where tltg=b_tltg;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_TLTG_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(tltg,tlph,nsd) order by tltg) into cs_lke from bh_tau_tltg;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_TLTG_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000);
    b_tltg number; b_tlph number; b_ngay_bd number; b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tltg,tlph,ngay_bd,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_tltg,b_tlph,b_ngay_bd,b_ngay_kt using b_oraIn;
if b_tltg is null then b_loi:='loi:Nhap so thang:loi'; raise PROGRAM_ERROR; end if;
if b_tlph is null then b_loi:='loi:Nhap ty le phi:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
delete bh_tau_tltg where tltg=b_tltg;
insert into bh_tau_tltg values(b_ma_dvi,b_tltg,b_tlph,b_ngay_bd,b_ngay_kt,b_nsd);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_TLTG_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn cLob)
AS
    b_loi varchar2(100); b_tltg number:=FKH_JS_GTRIs(b_oraIn,'tltg');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_tltg is null then b_loi:='loi:Nhap thoi gian:loi'; raise PROGRAM_ERROR; end if;
delete bh_tau_tltg where tltg=b_tltg;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_TLTG_TLE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_ngay_hl number; b_ngay_kt number; b_tlph number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_bd,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ngay_hl,b_ngay_kt using b_oraIn;
b_tlph:=FBH_TAU_TLTG_TLE(b_ngay_hl,b_ngay_kt);
select json_object('tlph' value b_tlph) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Pham vi hoat dong --
create or replace function FBH_TAU_PVI_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_tau_pvi where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_TAU_PVI_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_tau_pvi where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_TAU_PVI_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_tau_pvi where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_TAU_PVI_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into cs_lke from bh_tau_pvi;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_PVI_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
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
    select count(*) into b_dong from bh_tau_pvi;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select * from bh_tau_pvi order by ma))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_tau_pvi where upper(ma) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,json_object(a.*,'xep' value ma) obj from bh_tau_pvi a)
            where upper(ma) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_PVI_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_tau_pvi;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_tau_pvi;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_PVI_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,ngay_kt) into b_kq from bh_tau_pvi where ma=b_ma;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_PVI_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_ngay_kt using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_tau_pvi where ma=b_ma;
insert into bh_tau_pvi values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_PVI_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_tau_pvi where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--- DANH SACH TAU---
create or replace function FBH_TAU_DSACH_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Nam - Kiem tra con hieu luc
select count(*) into b_i1 from bh_tau_dsach where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_TAU_DSACH_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Nam
select min(ten) into b_kq from bh_tau_dsach where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_TAU_DSACH_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Nam
select min(ma||'|'||ten) into b_kq from bh_tau_dsach where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_TAU_DSACH_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob:='';
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into cs_lke from bh_tau_dsach;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_DSACH_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS 
    b_loi varchar2(1000); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_tau_ID;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object('so_id' value tau_id,so_dk,ten) obj,rownum sott from
            (select tau_id,so_dk,ten from bh_tau_ID order by tau_id))
        where sott between b_tu and b_den;
else 
    select count(*) into b_dong from bh_tau_ID where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object('so_id' value tau_id,so_dk,ten) obj,rownum sott from
            (select tau_id,so_dk,ten from bh_tau_ID where upper(ten) like b_tim order by tau_id))
        where sott between b_tu and b_den; 
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_DSACH_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_tau_dsach;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_tau_dsach;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_DSACH_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(so_dk,'ten_tau' value ten,tenc,qtich,'loai' value FBH_TAU_LOAI_TENl(loai),'cap' value FBH_TAU_CAP_TENl(cap),
       'vlieu' value FBH_TAU_VLIEU_TENl(vlieu),vtoc,tvo,may,tbi,hcai,'pvi' value FBH_TAU_PVI_TENl(pvi),
       ttai,csuat,dtich,so_cn,gia,nam_sx) into b_kq from bh_tau_ID where tau_id=b_so_id;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_DSACH_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ten_tau nvarchar2(500); b_tenc nvarchar2(500);
    b_so_dk varchar2(20); b_loai varchar2(10); b_cap varchar2(10); b_qtich varchar2(10);
    b_vlieu varchar2(10); b_vtoc number; b_ttai number;
    b_csuat number; b_dtich number; b_so_cn number; b_gia number; b_tvo number; b_may number;
    b_tbi number; b_nam_sx number; b_hcai varchar2(1); b_pvi nvarchar2(500);
    b_tau_id number;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ten_tau,tenc,so_dk,loai,cap,qtich,vlieu,vtoc,ttai,csuat,dtich,so_cn,gia,tvo,may,tbi,nam_sx,hcai,pvi');
EXECUTE IMMEDIATE b_lenh into b_ten_tau,b_tenc,b_so_dk,b_loai,b_cap,b_qtich,b_vlieu,b_vtoc,b_ttai,b_csuat,
                  b_dtich,b_so_cn,b_gia,b_tvo,b_may,b_tbi,b_nam_sx,b_hcai,b_pvi using b_oraIn;
b_tau_id:=FBH_TAUTSO_SO_ID(b_so_dk);
if b_tau_id<>0 then 
  delete bh_tau_ID where tau_id=b_tau_id;
else 
  PHT_ID_MOI(b_tau_id,b_loi);
  if b_loi is not null then return; end if;
end if;
insert into bh_tau_ID values(b_tau_id,b_ten_tau,b_tenc,b_so_dk,b_loai,b_cap,b_qtich,b_vlieu,b_vtoc,
            b_ttai,b_csuat,b_dtich,b_so_cn,b_gia,b_tvo,b_may,b_tbi,b_nam_sx,b_hcai,b_pvi);
commit;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Bieu phi --
create or replace function FBH_TAU_BPHI_NV_BH(b_nvB varchar2,b_nvN varchar2) return varchar2
AS
    b_kq varchar(1):='K';
begin
-- Dan - Ktra co nv_bh tren GCN va bieu phi
if instr(b_nvN,b_nvB)>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure FBH_TAU_BPHI_SO_ID(
    b_nhom varchar2,b_loai varchar2,b_cap varchar2,b_vlieu varchar2,
    b_ttai number,b_so_cn number,b_dtich number,b_csuat number,b_gia number,b_tuoi number,
    b_ma_sp varchar2,b_dkien varchar2,b_md_sd varchar2,b_nv_bh varchar2,
    b_ngay_bdN number,b_so_id out number,b_loi out varchar2)
AS
    b_ngay_bd number:=b_ngay_bdN;
    b_ttaiM number; b_so_cnM number; b_dtichM number; b_csuatM number; b_giaM number; b_tuoiM number;
begin
-- Dan - Tra so ID phi
b_loi:='Loi:Loi xu ly FBH_TAU_BPHI_SO_ID:loi';
if b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
b_so_id:=0;
select nvl(max(ttai),0),nvl(max(so_cn),0),nvl(max(dtich),0),nvl(max(csuat),0),nvl(max(tuoi),0),nvl(max(gia),0)
    into b_ttaiM,b_so_cnM,b_dtichM,b_csuatM,b_tuoiM,b_giaM from bh_tau_phi where
    nhom in(' ',b_nhom) and loai in(' ',b_loai) and cap in(' ',b_cap) and vlieu in(' ',b_vlieu) and 
    ma_sp in(' ',b_ma_sp) and dkien in(' ',b_dkien) and md_sd in(' ',b_md_sd) and nv_bh=b_nv_bh and
    b_ngay_bd between ngay_bd and ngay_kt and ttai<=b_ttai and so_cn<=b_so_cn and
    dtich<=b_dtich and csuat<=b_csuat and gia<=b_gia and tuoi<=b_tuoi;
select nvl(max(so_id),0) into b_so_id from bh_tau_phi where
    nhom in(' ',b_nhom) and loai in(' ',b_loai) and cap in(' ',b_cap) and vlieu in(' ',b_vlieu) and 
    ma_sp in(' ',b_ma_sp) and dkien in(' ',b_dkien) and md_sd in(' ',b_md_sd) and nv_bh=b_nv_bh and
    b_ngay_bd between ngay_bd and ngay_kt and ttai=b_ttaiM and so_cn=b_so_cnM and
    dtich=b_dtichM and csuat=b_csuatM and gia=b_giaM and tuoi=b_tuoiM;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_TAU_BPHI_TSO(
    b_oraIn clob,b_nhom out varchar2,b_loai out varchar2,b_cap out varchar2,b_vlieu out varchar2,
    b_ttai out number,b_so_cn out number,b_dtich out number,b_csuat out number,b_gia out number,b_tuoi out number,
    b_ma_sp out varchar2,b_dkien out varchar2,b_md_sd out varchar2,b_nv_bh out varchar2,
    b_ngay_bd out number,b_ngay_kt out number,b_ngay_hl out number,b_loi out varchar2)
AS
    b_lenh varchar2(2000);
begin
-- Dan - Dat gia tri
b_loi:='loi:Loi xu ly PBH_TAU_BPHI_TSO:loi';
b_lenh:=FKH_JS_LENH('nhom,loai,cap,vlieu,ttai,so_cn,dtich,csuat,gia,tuoi,ma_sp,dkien,md_sd,nv_bh,ngay_bd,ngay_kt,ngay_hl');
EXECUTE IMMEDIATE b_lenh into
    b_nhom,b_loai,b_cap,b_vlieu,b_ttai,b_so_cn,b_dtich,b_csuat,b_gia,b_tuoi,
    b_ma_sp,b_dkien,b_md_sd,b_nv_bh,b_ngay_bd,b_ngay_kt,b_ngay_hl using b_oraIn;
b_nhom:=PKH_MA_TENl(b_nhom); b_loai:=PKH_MA_TENl(b_loai); b_cap:=PKH_MA_TENl(b_cap); b_vlieu:=PKH_MA_TENl(b_vlieu);
b_ttai:=nvl(b_ttai,0); b_so_cn:=nvl(b_so_cn,0); b_dtich:=nvl(b_dtich,0); b_csuat:=nvl(b_csuat,0); b_gia:=nvl(b_gia,0); b_tuoi:=nvl(b_tuoi,0);
b_ma_sp:=NVL(trim(b_ma_sp),' '); b_dkien:=PKH_MA_TENl(b_dkien); b_md_sd:=NVL(trim(b_md_sd),' '); b_nv_bh:=NVL(trim(b_nv_bh),' ');
b_ngay_bd:=nvl(b_ngay_bd,0); b_ngay_kt:=nvl(b_ngay_kt,30000101);
if b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
if b_ngay_hl in(0,30000101) then b_ngay_hl:=PKH_NG_CSO(sysdate); end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_TAU_BPHI_MUC(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_dk varchar2(1);
    b_so_id number; b_ma varchar2(10); b_tien number; b_pt number:=0; b_phi number:=0;
begin
-- Dan - Tra so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('dk,so_id,ma,tien');
EXECUTE IMMEDIATE b_lenh into b_dk,b_so_id,b_ma,b_tien using b_oraIn;
b_dk:=nvl(trim(b_dk),' '); b_so_id:=nvl(b_so_id,0); b_ma:=nvl(trim(b_ma),' '); b_tien:=nvl(b_tien,0);
if b_so_id<>0 and b_ma<>' ' and b_tien<>0 then
    select nvl(max(pt),0),nvl(max(phi),0) into b_pt,b_phi from bh_tau_phi_dk where so_id=b_so_id and ma=b_ma;
end if;
select json_object('pt' value b_pt,'phi' value b_phi) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_BPHI_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_so_id number;
    b_nhom varchar2(10); b_loai varchar2(10); b_cap varchar2(10); b_vlieu varchar2(10); 
    b_ttai number; b_so_cn number; b_dtich number; b_csuat number; b_gia number; b_tuoi number; 
    b_ma_sp varchar2(10); b_dkien varchar2(10); b_md_sd varchar2(10); b_nv_bh varchar2(10); 
    b_ngay_bd number; b_ngay_kt number; b_ngay_hl number; b_nam_sx number;
begin
-- Dan - Tra so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_BPHI_TSO(
    b_oraIn,b_nhom,b_loai,b_cap,b_vlieu,b_ttai,b_so_cn,b_dtich,b_csuat,b_gia,b_tuoi,
    b_ma_sp,b_dkien,b_md_sd,b_nv_bh,b_ngay_bd,b_ngay_kt,b_ngay_hl,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
FBH_TAU_BPHI_SO_ID(
    b_nhom,b_loai,b_cap,b_vlieu,
    b_ttai,b_so_cn,b_dtich,b_csuat,b_gia,b_tuoi,
    b_ma_sp,b_dkien,b_md_sd,b_nv_bh,b_ngay_bd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_BPHI_DKBS(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,'ma_dk' value ma,lh_nv) order by ma returning clob) into cs_lke
    from bh_ma_dkbs where FBH_MA_NV_CO(nv,'TAU')='C' order by ma;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_TAU_BPHI_CTs(
    dt_ct clob,b_nv out varchar2,b_so_idS out varchar2,b_pphiS out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_lenh varchar2(1000); b_so_id number;
    b_nhom varchar2(500); b_loai varchar2(500); b_cap varchar2(500); b_vlieu varchar2(500);
    b_ttai number; b_so_cn number; b_dtich number; b_csuat number; b_gia number; b_tuoi number;
    b_ma_sp varchar2(10); b_dkien varchar2(500); b_md_sd varchar2(10); b_nv_bh varchar2(10);
    b_ngay_bd number; b_ngay_kt number; b_ngay_hl number; b_nam_sx number; b_hcai varchar2(1); b_vtoc number;
    a_nv pht_type.a_var;
begin
-- Dan - Tra so ID
b_nv:=''; b_so_idS:=''; b_pphiS:='';
PBH_TAU_BPHI_TSO(
    dt_ct,b_nhom,b_loai,b_cap,b_vlieu,b_ttai,b_so_cn,b_dtich,b_csuat,b_gia,b_tuoi,
    b_ma_sp,b_dkien,b_md_sd,b_nv_bh,b_ngay_bd,b_ngay_kt,b_ngay_hl,b_loi);
if b_loi is not null then return; end if;
b_loi:='loi:Loi xu ly FBH_TAU_BPHI_CTs:loi';
b_lenh:=FKH_JS_LENH('nvv,nvt,nvd,nvn,nam_sx,hcai,vtoc');
EXECUTE IMMEDIATE b_lenh into a_nv(1),a_nv(2),a_nv(3),a_nv(4),b_nam_sx,b_hcai,b_vtoc using dt_ct;
b_tuoi:=FBH_TAU_TUOI(b_nam_sx); b_hcai:=nvl(trim(b_hcai),'K'); b_vtoc:=nvl(b_vtoc,0);
for b_lp in 1..4 loop
    if nvl(trim(a_nv(b_lp)),' ')='C' then
        if b_lp=1 then a_nv(b_lp):='V';
        elsif b_lp=2 then a_nv(b_lp):='T';
        elsif b_lp=3 then a_nv(b_lp):='D';
        elsif b_lp=4 then a_nv(b_lp):='N';
        end if;
        FBH_TAU_BPHI_SO_ID(
            b_nhom,b_loai,b_cap,b_vlieu,
            b_ttai,b_so_cn,b_dtich,b_csuat,b_gia,b_tuoi,
            b_ma_sp,b_dkien,b_md_sd,a_nv(b_lp),b_ngay_hl,b_so_id,b_loi);
        if b_loi is not null then return; end if;
        if b_so_id<>0 then
            PKH_GHEP(b_nv,a_nv(b_lp)); PKH_GHEP(b_so_idS,to_char(b_so_id));
            if b_hcai<>'C' then b_i1:=0; else b_i1:=FBH_TAU_PPHCAI_PT(b_nhom,b_loai,a_nv(b_lp)); end if;
            b_i1:=b_i1+FBH_TAU_PPTUOI_PT(b_nhom,b_loai,a_nv(b_lp),b_tuoi)+
                FBH_TAU_PPVTOC_PT(b_nhom,b_loai,a_nv(b_lp),b_vtoc)+
                FBH_TAU_PPVLIEU_PT(b_nhom,b_loai,a_nv(b_lp),b_vlieu)+
                FBH_TAU_PPCAP_PT(b_nhom,b_loai,a_nv(b_lp),b_cap);
            PKH_GHEP(b_pphiS,to_char(b_i1));
        else
            b_nv:=a_nv(b_lp); b_so_idS:='0'; exit;
        end if;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure FBH_TAU_BPHI_CTbs(
    dt_ct clob,b_nv out varchar2,b_so_idS out varchar2,b_pphiS out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_lenh varchar2(1000); b_so_id number;
    b_nhom varchar2(10); b_loai varchar2(10); b_cap varchar2(10); b_vlieu varchar2(10);
    b_ttai number; b_so_cn number; b_dtich number; b_csuat number; b_gia number; b_tuoi number;
    b_ma_sp varchar2(10); b_dkien varchar2(10); b_md_sd varchar2(10); b_nv_bh varchar2(10);
    b_ngay_bd number; b_ngay_kt number; b_ngay_hl number; b_nam_sx number; b_hcai varchar2(1); b_vtoc number;
    a_nv pht_type.a_var;
begin
-- Dan - Tra so ID
b_nv:=''; b_so_idS:=''; b_pphiS:='';
PBH_TAU_BPHI_TSO(
    dt_ct,b_nhom,b_loai,b_cap,b_vlieu,b_ttai,b_so_cn,b_dtich,b_csuat,b_gia,b_tuoi,
    b_ma_sp,b_dkien,b_md_sd,b_nv_bh,b_ngay_bd,b_ngay_kt,b_ngay_hl,b_loi);
if b_loi is not null then return; end if;
b_loi:='loi:Loi xu ly FBH_TAU_BPHI_CTbs:loi';
b_lenh:=FKH_JS_LENH('nam_sx,hcai,vtoc');
EXECUTE IMMEDIATE b_lenh into b_nam_sx,b_hcai,b_vtoc using dt_ct;
b_tuoi:=FBH_TAU_TUOI(b_nam_sx); b_hcai:=nvl(trim(b_hcai),'K'); b_vtoc:=nvl(b_vtoc,0);
for b_lp in 1..1 loop
      a_nv(b_lp):='M';
      FBH_TAU_BPHI_SO_ID(
          b_nhom,b_loai,b_cap,b_vlieu,
          b_ttai,b_so_cn,b_dtich,b_csuat,b_gia,b_tuoi,
          b_ma_sp,b_dkien,b_md_sd,a_nv(b_lp),b_ngay_hl,b_so_id,b_loi);
      if b_loi is not null then return; end if;
      if b_so_id<>0 then
          PKH_GHEP(b_nv,a_nv(b_lp)); PKH_GHEP(b_so_idS,to_char(b_so_id));
          if b_hcai<>'C' then b_i1:=0; else b_i1:=FBH_TAU_PPHCAI_PT(b_nhom,b_loai,a_nv(b_lp)); end if;
          b_i1:=b_i1+FBH_TAU_PPTUOI_PT(b_nhom,b_loai,a_nv(b_lp),b_tuoi)+
              FBH_TAU_PPVTOC_PT(b_nhom,b_loai,a_nv(b_lp),b_vtoc)+
              FBH_TAU_PPVLIEU_PT(b_nhom,b_loai,a_nv(b_lp),b_vlieu);
          PKH_GHEP(b_pphiS,to_char(b_i1));
      else
          b_nv:=a_nv(b_lp); b_so_idS:='0'; exit;
      end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_TAU_BPHI_CTs(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_nv varchar2(10); b_so_idS varchar2(100); b_pphiS varchar2(100);
begin
-- Dan - Tra so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FBH_TAU_BPHI_CTs(b_oraIn,b_nv,b_so_idS,b_pphiS,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('nv' value b_nv,'so_id' value b_so_idS,'pphi' value b_pphiS) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_BPHI_CTd(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_i1 number;
    b_nv varchar2(1); b_so_id number; b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tygia number;
    dt_khd clob:=''; cs_kbt clob:=''; cs_dk clob; cs_dkbs clob; cs_lt clob; cs_txt clob;
begin
-- Dan - Tra bieu phi theo so_id
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,so_id,nt_tien,nt_phi,tygia');
EXECUTE IMMEDIATE b_lenh into b_nv,b_so_id,b_nt_tien,b_nt_phi,b_tygia using b_oraIn;
b_tygia:=nvl(b_tygia,1);
if trim(b_nt_tien)<>trim(b_nt_phi) and trim(b_nt_tien)<>'VND' and trim(b_nt_phi)<>'VND' then
   b_loi:='loi:Sai nguyen te phi:loi'; raise PROGRAM_ERROR;
end if;
if nvl(trim(b_nt_phi),'VND')='VND' and b_tygia<=0 then b_tygia:=1; end if;
insert into temp_1(c1,n1) select ma,min(bt) from bh_tau_phi_dk where so_id=b_so_id and lh_bh<>'M' group by ma;
select JSON_ARRAYAGG(json_object(
    a.ma,ten,
    'tien' value case when b_nt_tien<>'VND' then round(tien/b_tygia,2) else tien end,
    'ptB' value case when b_nt_phi<>'VND' then decode(sign(pt-100),1,round(pt/b_tygia,4),pt) else pt end,
    'pt' value '',phi,cap,tc,ma_ct,ma_dk,kieu,lh_nv,t_suat,lkeM,lkeP,lkeB,luy,lh_bh,gvu,
    'nv' value b_nv,'ptk' value decode(sign(pt-100),1,'T','P'),'bt' value a.bt)
    order by a.bt returning clob) into cs_dk
    from bh_tau_phi_dk a,temp_1 b where a.so_id=b_so_id and lh_bh<>'M' and b.n1=a.bt order by a.bt;

insert into temp_1(c1,n1) select ma,min(bt) from bh_tau_phi_dk where so_id=b_so_id and lh_bh='M' group by ma;
select JSON_ARRAYAGG(json_object(
    a.ma,ten,
    'tien' value case when b_nt_tien<>'VND' then round(tien/b_tygia,2) else tien end,
    'ptB' value case when b_nt_phi<>'VND' then decode(sign(pt-100),1,round(pt/b_tygia,4),pt) else pt end,
    'pt' value '',phi,cap,tc,ma_ct,ma_dk,kieu,lh_nv,t_suat,lkeM,lkeP,lkeB,luy,lh_bh,
    'nv' value b_nv,'ptk' value decode(sign(pt-100),1,'T','P'),'bt' value a.bt)
    order by a.bt returning clob) into cs_dkbs
    from bh_tau_phi_dk a,temp_1 b where a.so_id=b_so_id and lh_bh='M' and b.n1=a.bt order by a.bt;
select JSON_ARRAYAGG(json_object(ma_lt,ten) order by bt returning clob)
    into cs_lt from bh_tau_phi_lt where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into cs_txt
    from bh_tau_phi_txt where so_id=b_so_id and loai='dt_dk';
select count(*) into b_i1 from bh_tau_phi_txt where so_id=b_so_id and loai='dt_khd';
if b_i1<>0 then
    select txt into dt_khd from bh_tau_phi_txt where so_id=b_so_id and loai='dt_khd';
end if;
select count(*) into b_i1 from bh_tau_phi_txt where so_id=b_so_id and loai='dt_kbt';
if b_i1<>0 then
    select txt into cs_kbt from bh_tau_phi_txt where so_id=b_so_id and loai='dt_kbt';
end if;
select json_object('nv' value b_nv,'dt_khd' value dt_khd,'dt_kbt' value cs_kbt,'dt_lt' value cs_lt,
    'dt_dk' value cs_dk,'dt_dkbs' value cs_dkbs,'txt' value cs_txt returning clob) into b_oraOut from dual;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_BPHId_THEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_so_idS varchar2(500);
    b_i1 number; b_i2 number;
    b_vu varchar2(10); b_nhom varchar2(500); b_loai varchar2(500); b_cap varchar2(500); b_vlieu varchar2(500);
    b_ttai number; b_so_cn number; b_dtich number; b_csuat number; b_gia number; b_tuoi number;
    b_ma_sp varchar2(10); b_dkien varchar2(500); b_md_sd varchar2(10); b_nv_bh varchar2(10);
    b_ngay_bd number; b_ngay_kt number; b_ngay_hl number; b_nam_sx number; b_hcai varchar2(1); b_vtoc number;
    b_so_id number; b_so_idN pht_type.a_num; b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tygia number;
    a_so_idN pht_type.a_num; a_nvN pht_type.a_var;
    b_dk_lt clob; a_ma_lt pht_type.a_var; a_ma_dk_lt pht_type.a_var; a_ten_lt pht_type.a_nvar;
    a_chon_lt pht_type.a_var; a_nv pht_type.a_var;
    b_nv varchar2(10):='';
    a_maDK pht_type.a_var; a_btDK pht_type.a_num; cs_lke clob;
begin
-- Dan - Tra so ID
delete from temp_1; delete from temp_2; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_BPHI_TSO(
    b_oraIn,b_nhom,b_loai,b_cap,b_vlieu,b_ttai,b_so_cn,b_dtich,b_csuat,b_gia,b_tuoi,
    b_ma_sp,b_dkien,b_md_sd,b_nv_bh,b_ngay_bd,b_ngay_kt,b_ngay_hl,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nvv,nvt,nvd,nvn,nam_sx,hcai,vtoc,vu,nt_tien,nt_phi,tygia');
EXECUTE IMMEDIATE b_lenh into a_nv(1),a_nv(2),a_nv(3),a_nv(4),b_nam_sx,b_hcai,b_vtoc,b_vu,b_nt_tien,b_nt_phi,b_tygia using b_oraIn;
b_tuoi:=FBH_TAU_TUOI(b_nam_sx);
b_nt_phi:=NVL(trim(b_nt_phi),'VND'); b_nt_tien:=NVL(trim(b_nt_tien),'VND');
b_tygia:=nvl(b_tygia,1);
if nvl(trim(b_nt_phi),'VND')='VND' and b_tygia<=0 then b_tygia:=1; end if;

b_oraOut:='';
for b_lp in 1..4 loop
    if nvl(trim(a_nv(b_lp)),' ')<>'C' then continue; end if;
  if b_lp=1 then a_nv(b_lp):='V';
  elsif b_lp=2 then a_nv(b_lp):='T';
  elsif b_lp=3 then a_nv(b_lp):='D';
  elsif b_lp=4 then a_nv(b_lp):='N';
  end if;
  FBH_TAU_BPHI_SO_ID(
            b_nhom,b_loai,b_cap,b_vlieu,
            b_ttai,b_so_cn,b_dtich,b_csuat,b_gia,b_tuoi,
            b_ma_sp,b_dkien,b_md_sd,a_nv(b_lp),b_ngay_hl,b_so_id,b_loi);
  if b_loi is not null then return; end if;
  if b_so_id=0 then return;
    else
        if b_nv is not null then b_nv:=b_nv||','; b_so_idS:=b_so_idS||','; end if;
        b_nv:=b_nv||a_nv(b_lp); b_so_idS:=b_so_idS||to_char(b_so_id);
    end if;
  b_i1:=a_so_idN.count+1;
    a_so_idN(b_i1):=b_so_id; a_nvN(b_i1):=a_nv(b_lp);
end loop;

if a_so_idN.count=0 then return; end if;

if b_vu='dk' then
    for b_lp in 1..a_so_idN.count loop
        insert into temp_1(c1,n1,c2,n2) select a_nvN(b_lp),min(bt),ma,a_so_idN(b_lp) from bh_tau_phi_dk where so_id=a_so_idN(b_lp) and lh_bh<>'M' group by ma;
    end loop;
    select JSON_ARRAYAGG(json_object(ma,ten,'tien' value case when b_nt_tien='VND' then tien else round(tien/b_tygia,2) end,
      'ptB' value case when b_nt_phi<>'VND' then decode(sign(pt-100),1,round(pt/b_tygia,2),pt) else pt end,
      'pt' value '',phi,cap,tc,ma_ct,ma_dk,kieu,lh_nv,t_suat,lkeM,lkeP,lkeB,luy,lh_bh,gvu,
      'nv' value b.c1,'ptk' value decode(sign(pt-100),1,'T','P'),'bt' value bt) order by b.c1,bt returning clob)
        into cs_lke from bh_tau_phi_dk a,temp_1 b where a.so_id=b.n2 and a.bt=b.n1 and a.lh_bh<>'M' order by a.bt;
elsif b_vu='dkbs' then
    for b_lp in 1..a_so_idN.count loop
        insert into temp_1(n1) values (a_so_idN(b_lp));
    end loop;
    select JSON_ARRAYAGG(json_object('ma' value ma,ten,'tien' value case when b_nt_tien='VND' then tien else round(tien/b_tygia,2) end,
                'ptB' value case when b_nt_phi<>'VND' then decode(sign(pt-100),1,round(pt/b_tygia,4),pt) else pt end,
                pt,ma_ct,tc,phi,cap,lh_nv,lkeM,lkeP,'bt' value bt,'ptk' value decode(sign(pt-50),1,'T','P')) order by ma,ten returning clob) into cs_lke from
                (select ma,ten,tien,pt,ma_ct,ma_dk,kieu,tc,phi,cap,lh_nv,t_suat,lkeM,lkeP,bt
                        from bh_tau_phi_dk where so_id in (select n1 from temp_1) and lh_bh='M' union
                select ma,ten,null tien,null pt,'' ma_ct,ma_dk,'' kieu,'T' tc,null phi,null cap,lh_nv,0 t_suat,'G' lkeM,'G' lkeP,999 bt from bh_ma_dkbs where FBH_MA_NV_CO(nv,'TAU')='C');
elsif b_vu='lt' then
    for b_lp in 1..a_so_idN.count loop
        select count(*) into b_i1 from bh_tau_phi_txt where so_id=a_so_idN(b_lp) and loai='dt_lt';
        if b_i1 > 0 then
          select FKH_JS_BONH(txt) into b_dk_lt from bh_tau_phi_txt where so_id=a_so_idN(b_lp) and loai='dt_lt';
          b_lenh:=FKH_JS_LENH('ma_lt,ma_dk,ten,chon');
          EXECUTE IMMEDIATE b_lenh bulk collect into a_ma_lt,a_ma_dk_lt,a_ten_lt,a_chon_lt using b_dk_lt;
          if a_ma_lt.count > 0 then
              for b_lp2 in 1..a_ma_lt.count loop
                  insert into temp_2(c1,c2,c3,c4) VALUES (a_ma_lt(b_lp2),a_ma_dk_lt(b_lp2),a_ten_lt(b_lp2),a_chon_lt(b_lp2));
              end loop;
          end if;
        end if;
    end loop;
    for r_lp in (select ma,ten,ma_dk from bh_ma_dklt where FBH_MA_NV_CO(nv,'TAU')='C') loop
        select count(*) into b_i1 from temp_2 where c1=r_lp.ma;
        if b_i1=0 then insert into temp_2(c1,c2,c3,c4) values(r_lp.ma,r_lp.ma_dk,r_lp.ten,' '); end if;
    end loop;
    select JSON_ARRAYAGG(json_object('ma_lt' value c1,'ten' value c3,'ma_dk' value c2,'chon' value c4)
        order by c1,c2 returning clob) into cs_lke from temp_2;
end if;
select json_object('so_ids' value b_so_idS,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_BPHI_CTm(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_so_id number;
    b_nhom varchar2(10); b_loai varchar2(10); b_cap varchar2(10); b_vlieu varchar2(10); 
    b_ttai number; b_so_cn number; b_dtich number; b_csuat number; b_gia number; b_tuoi number; 
    b_ma_sp varchar2(10); b_dkien varchar2(10); b_md_sd varchar2(10); b_nv_bh varchar2(10); 
    b_ngay_bd number; b_ngay_kt number; b_ngay_hl number; b_nam_sx number;
	b_dvi_ta varchar2(10):=FTBH_DVI_TA(); b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tgT number:=1; b_tgP number:=1;
    cs_dk clob:=''; cs_txt clob:='';
begin
-- Dan - Tra dieu khoan mo rong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_BPHI_TSO(
    b_oraIn,b_nhom,b_loai,b_cap,b_vlieu,b_ttai,b_so_cn,b_dtich,b_csuat,b_gia,b_tuoi,
    b_ma_sp,b_dkien,b_md_sd,b_nv_bh,b_ngay_bd,b_ngay_kt,b_ngay_hl,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nt_tien,nt_phi,nam_sx');
EXECUTE IMMEDIATE b_lenh into b_nt_tien,b_nt_phi,b_nam_sx using b_oraIn;
b_tuoi:=FBH_TAU_TUOI(b_nam_sx);
FBH_TAU_BPHI_SO_ID(
    b_nhom,b_loai,b_cap,b_vlieu,
    b_ttai,b_so_cn,b_dtich,b_csuat,b_gia,b_tuoi,
    b_ma_sp,b_dkien,b_md_sd,'M',b_ngay_hl,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_nt_tien<>'VND' then b_tgT:=FTT_TRA_TGTT(b_dvi_ta,b_ngay_hl,b_nt_tien); end if;
if b_nt_phi<>'VND' then b_tgP:=FTT_TRA_TGTT(b_dvi_ta,b_ngay_hl,b_nt_phi); end if;
select JSON_ARRAYAGG(json_object('nv' value 'M',ma,cap,ma_dk,lh_nv,t_suat,gvu,'ptB' value pt,
    'tien' value case when b_tgT=1 then tien else round(tien/b_tgT,0) end,
    'pt' value case when pt<100 then pt else round(pt/b_tgP,2) end) order by bt returning clob)
    into cs_dk from bh_tau_phi_dk where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into cs_txt
    from bh_tau_phi_txt where so_id=b_so_id and loai='dt_dk';
select json_object('dt_dk' value cs_dk,'txt' value cs_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_TAU_BPHI_DKm(
    b_so_id number,b_ma varchar2,b_tien number,b_pt out number,b_phi out number,b_gvu out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_tienM number;
begin
-- Dan - Lay %phi theo khoang muc trach nhiem
b_loi:='loi:Loi xu ly FBH_TAU_BPHI_DKm:loi';
select count(*),nvl(max(tien),0) into b_i1,b_tienM from bh_tau_phi_dk where so_id=b_so_id and ma=b_ma and tien<=b_tien;
if b_i1=0 then b_loi:='loi:Khong tim duoc ty le phi theo muc trach nhiem:loi'; return; end if;
select nvl(max(pt),0),nvl(max(phi),0),nvl(min(gvu),' ') into b_pt,b_phi,b_gvu from bh_tau_phi_dk where so_id=b_so_id and ma=b_ma and tien=b_tienM;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_TAU_BPHI_DKm(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_nv varchar2(10);
    b_so_id number; b_ma varchar2(10); b_tien number; b_pt number; b_phi number;
    b_nhom varchar2(10); b_loai varchar2(10); b_cap varchar2(10); b_vlieu varchar2(10); 
    b_ttai number; b_so_cn number; b_dtich number; b_csuat number; b_gia number; b_tuoi number; 
    b_ma_sp varchar2(10); b_dkien varchar2(10); b_md_sd varchar2(10); b_nv_bh varchar2(10); 
    b_ngay_bd number; b_ngay_kt number; b_ngay_hl number; b_nam_sx number;
    b_dvi_ta varchar2(10):=FTBH_DVI_TA(); b_ngay number:=PKH_NG_CSO(sysdate);
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tgP number; b_gvu varchar2(100);
begin
-- Dan - Lay %phi theo khoang muc trach nhiem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_BPHI_TSO(
    b_oraIn,b_nhom,b_loai,b_cap,b_vlieu,b_ttai,b_so_cn,b_dtich,b_csuat,b_gia,b_tuoi,
    b_ma_sp,b_dkien,b_md_sd,b_nv_bh,b_ngay_bd,b_ngay_kt,b_ngay_hl,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,ma,nt_tien,nt_phi,tien,nam_sx');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ma,b_nt_tien,b_nt_phi,b_tien,b_nam_sx using b_oraIn;
b_tuoi:=FBH_TAU_TUOI(b_nam_sx);
if b_nt_tien<>'VND' then b_tien:=FTT_VND_QD(b_dvi_ta,b_ngay,b_nt_tien,b_tien); end if;
FBH_TAU_BPHI_SO_ID(
    b_nhom,b_loai,b_cap,b_vlieu,
    b_ttai,b_so_cn,b_dtich,b_csuat,b_gia,b_tuoi,
    b_ma_sp,b_dkien,b_md_sd,b_nv,b_ngay_hl,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
FBH_TAU_BPHI_DKm(b_so_id,b_ma,b_tien,b_pt,b_phi,b_gvu,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_nt_phi<>'VND' then
    b_tgP:=FTT_TRA_TGTT(b_dvi_ta,b_ngay_hl,b_nt_phi);
    if b_pt>100 then b_pt:=round(b_pt/b_tgP,2); end if;
    b_phi:=round(b_phi/b_tgP,2);
end if;
select json_object('pt' value b_pt,'phi' value b_phi,'gvu' value b_gvu) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- nam sua
create or replace procedure FBH_TAU_BPHI_DKp(
    b_so_id number,b_ma varchar2,b_tien number,b_tgT number,b_bt out number,b_loi out varchar2)
AS
    b_i1 number; b_tienM number;
begin
-- Dan - Lay %phi theo khoang muc trach nhiem
b_loi:='loi:Loi xu ly FBH_TAU_BPHI_DKm:loi';
select count(*),nvl(max(tien),0) into b_i1,b_tienM from bh_tau_phi_dk where so_id=b_so_id and ma=b_ma and tien<=round(b_tien * b_tgT,2);
if b_i1=0 then b_loi:='loi:Khong tim duoc ty le phi theo muc trach nhiem:loi'; return; end if;
select nvl(min(bt),0) into b_bt from bh_tau_phi_dk where so_id=b_so_id and ma=b_ma and tien=b_tienM;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_TAU_BPHI_DKp(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number:=0; b_lenh varchar2(1000); b_bt number;
    b_nv varchar2(10); b_so_id number; b_ma varchar2(10); b_tien number; b_pt number; b_phi number;
    b_nhom varchar2(200); b_loai varchar2(200); b_cap varchar2(200); b_vlieu varchar2(200); 
    b_ttai number; b_so_cn number; b_dtich number; b_csuat number; b_gia number; b_tuoi number; 
    b_ma_sp varchar2(10); b_dkien varchar2(200); b_md_sd varchar2(10); b_nv_bh varchar2(10); 
    b_ngay_bd number; b_ngay_kt number; b_ngay_hl number; b_nam_sx number;
    b_dvi_ta varchar2(10):=FTBH_DVI_TA(); b_ngay number:=PKH_NG_CSO(sysdate);
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tgP number:=1; b_tgT number:=1;
begin
-- Dan - Lay %phi theo khoang muc trach nhiem va cac ma phu thuoc
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_BPHI_TSO(
    b_oraIn,b_nhom,b_loai,b_cap,b_vlieu,b_ttai,b_so_cn,b_dtich,b_csuat,b_gia,b_tuoi,
    b_ma_sp,b_dkien,b_md_sd,b_nv_bh,b_ngay_bd,b_ngay_kt,b_ngay_hl,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,ma,nt_tien,nt_phi,tien,nam_sx');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ma,b_nt_tien,b_nt_phi,b_tien,b_nam_sx using b_oraIn;
b_tuoi:=FBH_TAU_TUOI(b_nam_sx);
FBH_TAU_BPHI_SO_ID(
    b_nhom,b_loai,b_cap,b_vlieu,
    b_ttai,b_so_cn,b_dtich,b_csuat,b_gia,b_tuoi,
    b_ma_sp,b_dkien,b_md_sd,b_nv,b_ngay_hl,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_nt_tien<>'VND' then b_tgT:=FTT_TRA_TGTT(b_dvi_ta,b_ngay,b_nt_tien);end if;
if b_nt_phi<>'VND' then b_tgP:=FTT_TRA_TGTT(b_dvi_ta,b_ngay_hl,b_nt_phi);end if;
FBH_TAU_BPHI_DKp(b_so_id,b_ma,b_tien,b_tgT,b_bt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
for r_lp in (select * from bh_tau_phi_dk where so_id=b_so_id and bt>=b_bt order by bt) loop
    if b_i1<>0 and r_lp.ma=b_ma then exit; end if;
    b_pt:=r_lp.pt; b_phi:=r_lp.phi;
    if b_nt_phi<>'VND' then
        if b_pt>100 then b_pt:=round(b_pt/b_tgP,2); end if;
        b_phi:=round(b_phi/b_tgP,2);
    end if;
    insert into temp_1(c1,n1,n2,c2,n3) values(r_lp.ma,b_pt,b_phi,r_lp.gvu,r_lp.bt);
    b_i1:=1;
end loop;
select JSON_ARRAYAGG(json_object('ma' value c1,'ptb' value n1,'phi' value n2,'gvu' value c2) order by n3 returning clob) into b_oraOut from temp_1;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_BPHI_DKt(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_i2 number; b_lenh varchar2(1000);
    b_ngay_capC number; b_ttoanC number; b_phi number; b_thue number; b_ttoan number; b_tp number:=0; b_nt_phi varchar2(5);
    b_so_hdG varchar2(20); b_kieu_hd varchar2(1); b_ngay_hl number; b_ngay_kt number; b_ngay_cap number;
begin
-- Nam - tinh phi va thue prorata
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hd_g,kieu_hd,ngay_hl,ngay_kt,ngay_cap,phi,thue,nt_phi');
EXECUTE IMMEDIATE b_lenh into b_so_hdG,b_kieu_hd,b_ngay_hl,b_ngay_kt,b_ngay_cap,b_phi,b_thue,b_nt_phi using b_oraIn;
b_kieu_hd:=nvl(trim(b_kieu_hd),'G'); b_so_hdG:=nvl(trim(b_so_hdG),' ');
if b_nt_phi<>'VND' then b_tp:=2; end if;
if b_kieu_hd='B' and b_so_hdG<>' ' and b_phi > 0 then
    select nvl(min(ttoan),0),nvl(min(ngay_cap),0) into b_ttoanC,b_ngay_capC from bh_tau where ma_dvi=b_ma_dvi and so_hd=b_so_hdG;
    if b_ngay_capC<>0 then
        b_i2:=(FKH_KHO_NGSO(b_ngay_hl,b_ngay_cap))/(FKH_KHO_NGSO(b_ngay_hl,b_ngay_kt)+1);
        b_i1:=(FKH_KHO_NGSO(b_ngay_cap,b_ngay_kt)+1)/(FKH_KHO_NGSO(b_ngay_hl,b_ngay_kt)+1);
        b_ttoan:=b_phi+b_thue;
        b_i1:=b_i1*b_ttoan+b_i2*b_ttoanC;
        if b_ttoan<>0 then b_i2:=b_i1/b_ttoan; end if;
        b_phi:=round(b_phi*b_i2,b_tp); b_thue:=round(b_thue*b_i2,b_tp);
        insert into temp_1(n1,n2) values(b_phi,b_thue);
    end if;
end if;
select JSON_ARRAYAGG(json_object('phi' value n1,'thue' value n2) returning clob) into b_oraOut from temp_1;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_BPHI_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_sp clob; cs_lt clob; cs_khd clob; cs_kbt clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma_dk,ten,'ma_lt' value ma)) into cs_lt
    from bh_ma_dklt a where FBH_MA_NV_CO(nv,'TAU')='C' and FBH_MA_DKLT_HAN(ma_dk,ma)='C' and MA <> ' '; -- ma = ' ' la goc
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt) into cs_khd from bh_kh_ttt where ps='KHD' and nv='TAU';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt) into cs_kbt from bh_kh_ttt where ps='KBT' and nv='TAU';
select json_object('cs_sp' value cs_sp,'cs_lt' value cs_lt,'cs_khd' value cs_khd,'cs_kbt' value cs_kbt) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_BPHI_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); cs_lke clob; b_dong number;
    b_nhom varchar2(200); b_loai varchar2(200); b_md_sd varchar2(1); b_nv_bh varchar2(1);
    b_tu number; b_den number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nhom,loai,md_sd,nv_bh,tu,den');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_loai,b_md_sd,b_nv_bh,b_tu,b_den using b_oraIn;
b_nhom:=PKH_MA_TENl(b_nhom); b_loai:=PKH_MA_TENl(b_loai);
b_nhom:=nvl(trim(b_nhom),' '); b_loai:=nvl(trim(b_loai),' '); b_md_sd:=nvl(trim(b_md_sd),' '); b_nv_bh:=nvl(trim(b_nv_bh),' ');
select count(*) into b_dong from bh_tau_phi where b_nhom in(' ',nhom) and b_loai in(' ',loai) and b_md_sd in(' ',md_sd) and b_nv_bh in(' ',nv_bh);
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(so_id,ngay_bd,ngay_kt,
    'nhom' value FBH_TAU_NHOM_TEN(nhom),'loai' value FBH_TAU_LOAI_TEN(loai),
    'cap' value FBH_TAU_CAP_TEN(cap),'vlieu' value FBH_TAU_VLIEU_TEN(vlieu),
    ttai,so_cn,dtich,csuat,gia,tuoi,'ma_sp' value FBH_TAU_SP_TEN(ma_sp),
    'dkien' value FBH_TAU_DKC_TEN(dkien),'md_sd' value FBH_TAU_MDSD_TEN(md_sd),
    'nv_bh' value decode(nv_bh,'V','Vat chat','T','TNDS chu tau','D','TNDS mo rong','N','Tai nan thuyen vien','Mo rong'))
    returning clob) into cs_lke from
    (select nhom,loai,cap,vlieu,ttai,so_cn,dtich,csuat,gia,tuoi,
    ma_sp,dkien,md_sd,nv_bh,ngay_bd,ngay_kt,so_id,rownum sott from bh_tau_phi
    where b_nhom in(' ',nhom) and b_loai in(' ',loai) and b_md_sd in(' ',md_sd) and b_nv_bh in(' ',nv_bh)
    order by nhom,loai,cap,vlieu,ttai,so_cn,dtich,csuat,gia,tuoi,ma_sp,dkien,md_sd,nv_bh)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_BPHI_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_i1 number; 
    b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
    dt_khd clob:=''; dt_kbt clob:=''; dt_ct clob; dt_dk clob; dt_dkbs clob; dt_lt clob; dt_txt clob;
begin
-- Dan - Xem chi tiet theo so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Bieu phi da xoa:loi';
select JSON_ARRAYAGG(json_object(so_id,
    'nhom' value FBH_TAU_NHOM_TENl(nhom),'loai' value FBH_TAU_LOAI_TENl(loai),
    'cap' value FBH_TAU_CAP_TENl(cap),'vlieu' value FBH_TAU_VLIEU_TENl(vlieu),
    'ma_sp' value FBH_TAU_SP_TENl(ma_sp),'dkien' value FBH_TAU_DKC_TENl(dkien),'md_sd' value FBH_TAU_MDSD_TENl(md_sd)) returning clob)
    into dt_ct from bh_tau_phi where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ma,cap) order by bt returning clob) into dt_dk from bh_tau_phi_dk where so_id=b_so_id and lh_bh<>'M';
select count(*) into b_i1 from bh_tau_phi_txt where so_id=b_so_id and loai='dt_dkbs';
if b_i1<>0 then
    select txt into dt_dkbs from bh_tau_phi_txt where so_id=b_so_id and loai='dt_dkbs';
end if;
select JSON_ARRAYAGG(json_object(ma_lt) order by bt returning clob) into dt_lt from bh_tau_phi_lt where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_tau_phi_txt where so_id=b_so_id and loai in('dt_ct','dt_dk','dt_lt');
select count(*) into b_i1 from bh_tau_phi_txt where so_id=b_so_id and loai='dt_khd';
if b_i1<>0 then
    select txt into dt_khd from bh_tau_phi_txt where so_id=b_so_id and loai='dt_khd';
end if;
select count(*) into b_i1 from bh_tau_phi_txt where so_id=b_so_id and loai='dt_kbt';
if b_i1<>0 then
    select txt into dt_kbt from bh_tau_phi_txt where so_id=b_so_id and loai='dt_kbt';
end if;
select json_object('so_id' value b_so_id,'dt_khd' value dt_khd,'dt_kbt' value dt_kbt,'dt_ct' value dt_ct,
    'dt_dk' value dt_dk,'dt_dkbs' value dt_dkbs,'dt_lt' value dt_lt,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_BPHI_XOA_XOA(b_so_id number, b_loi out varchar2)
AS 
begin
-- Dan - Xoa bieu phi
b_loi:='loi:Loi xoa phi:loi';
delete bh_tau_phi_txt where so_id=b_so_id;
delete bh_tau_phi_lt where so_id=b_so_id;
delete bh_tau_phi_dk where so_id=b_so_id;
delete bh_tau_phi where so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_TAU_BPHI_TEST(
    b_dt_dk clob,b_dt_dkbs clob,b_dt_lt clob,
    dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,dk_tc out pht_type.a_var,dk_ma_ct out pht_type.a_var,
    dk_ma_dk out pht_type.a_var,dk_ma_dkC out pht_type.a_var,dk_kieu out pht_type.a_var,
    dk_tien out pht_type.a_num,dk_pt out pht_type.a_num,
    dk_phi out pht_type.a_num,dk_lkeM out pht_type.a_var,dk_lkeP out pht_type.a_var,dk_lkeB out pht_type.a_var,
    dk_luy out pht_type.a_var,dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,
    dk_gvu out pht_type.a_var,dk_lh_bh out pht_type.a_var,    
    lt_ma_dk out pht_type.a_var,lt_ma_lt out pht_type.a_var,lt_ten out pht_type.a_nvar,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_lenh varchar2(2000); b_ma_ct varchar2(10); b_kt number;
    b_ict1 number; b_ict2 number;
    
    dkB_ma pht_type.a_var; dkB_ten pht_type.a_nvar; dkB_tc pht_type.a_var;
    dkB_ma_ct pht_type.a_var; dkB_ma_dk pht_type.a_var; dkB_ma_dkC pht_type.a_var;
    dkB_ma_dkC pht_type.a_var; dkB_kieu pht_type.a_var; dkB_tien pht_type.a_num; dkB_pt pht_type.a_num;
    dkB_phi pht_type.a_num; dkB_lkeM pht_type.a_var; dkB_lkeP pht_type.a_var; dkB_lkeB pht_type.a_var;
    dkB_luy pht_type.a_var; dkB_gvu pht_type.a_var;
begin
b_loi:='loi:Loi xu ly PBH_TAU_BPHI_TEST:loi';
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,ma_dk,kieu,tien,pt,phi,lkem,lkep,lkeb,luy,gvu');
EXECUTE IMMEDIATE b_lenh bulk collect into
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_ma_dk,dk_kieu,dk_tien,dk_pt,dk_phi,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy,dk_gvu using b_dt_dk;
b_kt:=dk_ma.count;
if b_kt=0 then b_loi:='loi:Nhap dieu khoan:loi'; raise PROGRAM_ERROR; end if;
for b_lp in 1..b_kt loop dk_lh_bh(b_lp):='C'; end loop;
if trim(b_dt_dkbs) is not null then
    EXECUTE IMMEDIATE b_lenh bulk collect into
        dkB_ma,dkB_ten,dkB_tc,dkB_ma_ct,dkB_ma_dk,dkB_kieu,dkB_tien,dkB_pt,dkB_phi,dkB_lkeM,dkB_lkeP,dkB_lkeB,dkB_luy,dkB_gvu using b_dt_dkbs;
    for b_lp in 1..dkB_ma.count loop
        b_kt:=b_kt+1; dk_lh_bh(b_kt):='M';
        dk_ma(b_kt):=dkB_ma(b_lp); dk_ten(b_kt):=dkB_ten(b_lp); dk_tc(b_kt):=dkB_tc(b_lp);
        dk_ma_ct(b_kt):=dkB_ma_ct(b_lp); dk_ma_dk(b_kt):=dkB_ma_dk(b_lp); dk_kieu(b_kt):=dkB_kieu(b_lp);
        dk_tien(b_kt):=dkB_tien(b_lp); dk_pt(b_kt):=dkB_pt(b_lp); dk_phi(b_kt):=dkB_phi(b_lp);
        dk_lkeM(b_kt):=dkB_lkeM(b_lp); dk_lkeP(b_kt):=dkB_lkeP(b_lp);
        dk_lkeB(b_kt):=dkB_lkeB(b_lp); dk_luy(b_kt):=dkB_luy(b_lp); dk_gvu(b_kt):=dkB_gvu(b_lp);
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
    dk_tc(b_lp):=nvl(trim(dk_tc(b_lp)),'C'); dk_ma_ct(b_lp):=nvl(trim(dk_ma_ct(b_lp)),' ');
    if dk_ma(b_lp)=dk_ma_ct(b_lp) then b_loi:='loi:Trung ma cap tren ma: '||dk_ma(b_lp)||':loi'; return; end if;
    if dk_tc(b_lp)='C' then
        dk_lkeM(b_lp):=nvl(trim(dk_lkeM(b_lp)),'G'); dk_lkeP(b_lp):=nvl(trim(dk_lkeP(b_lp)),'G');
        dk_lkeB(b_lp):=nvl(trim(dk_lkeB(b_lp)),'G');
    else
        dk_lkeM(b_lp):=nvl(trim(dk_lkeM(b_lp)),'K'); dk_lkeP(b_lp):=nvl(trim(dk_lkeP(b_lp)),'T'); 
        dk_lkeB(b_lp):=nvl(trim(dk_lkeB(b_lp)),'T');
    end if;
    dk_kieu(b_lp):=nvl(trim(dk_kieu(b_lp)),'T'); dk_luy(b_lp):=nvl(trim(dk_luy(b_lp)),'C');
    dk_ma_dk(b_lp):=nvl(trim(dk_ma_dk(b_lp)),' ');
    if dk_ma_dk(b_lp)<>' ' then
        if dk_lh_bh(b_lp)<>'M' then
            if FBH_MA_DK_HAN(dk_ma_dk(b_lp))='K' then
                b_loi:='loi:Dieu khoan: '||dk_ma_dk(b_lp)||' da het su dung:loi'; return;
            end if;
            select min(lh_nv) into dk_lh_nv(b_lp) from bh_ma_dk where ma=dk_ma_dk(b_lp);
        else
            if FBH_MA_DKBS_HAN(dk_ma_dk(b_lp))='K' then
                b_loi:='loi:Dieu khoan bo sung : '||dk_ma_dk(b_lp)||' da het su dung:loi'; return;
            end if;
            select min(lh_nv) into dk_lh_nv(b_lp) from bh_ma_dkbs where ma=dk_ma_dk(b_lp);
        end if;
        dk_t_suat(b_lp):=FBH_MA_LHNV_THUE(dk_lh_nv(b_lp));
    else
        dk_ma_dk(b_lp):=' '; dk_lh_nv(b_lp):=' '; dk_t_suat(b_lp):=0;
    end if;
    dk_gvu(b_lp):=nvl(trim(dk_gvu(b_lp)),' ');
end loop;
for b_lp in 1..dk_ma.count loop
    b_ict1:=0;
    if b_lp>1 and dk_ma_ct(b_lp)<>' ' then
        b_i1:=b_lp-1;
        for b_lp1 in 1..b_i1 loop
            if dk_ma(b_lp1)=dk_ma_ct(b_lp) then b_ict1:=b_lp1; end if;
        end loop;
    end if;
    b_i2:=b_lp+1;
    for b_lp1 in b_i2..dk_ma.count loop
        if dk_ma(b_lp)=dk_ma(b_lp1) and dk_tien(b_lp)=dk_tien(b_lp1) then
            b_ict2:=0;
            if dk_ma_ct(b_lp1)<>' ' then
                b_i1:=b_lp1-1;
                for b_lp2 in 1..b_i1 loop
                    if dk_ma(b_lp2)=dk_ma_ct(b_lp1) then b_ict2:=b_lp1; end if;
                end loop;
            end if;
            if b_ict1=b_ict2 then b_loi:='loi:Trung ma: '||dk_ma(b_lp)||':loi'; return; end if;
        end if;
    end loop;
    if dk_tc(b_lp)='T' then
        b_i1:=0;
        for b_lp1 in 1..dk_ma.count loop
            if dk_ma(b_lp)=dk_ma_ct(b_lp1) and dk_tc(b_lp1)<>'K' then b_i1:=1; exit; end if;
        end loop;
        if b_i1=0 then b_loi:='loi:Nhap ma chi tiet ma: '||dk_ma(b_lp)||':loi'; return; end if;
    end if;
end loop;
for b_lp in 1..dk_ma.count loop
    if dk_tc(b_lp)='C' and dk_ma_ct(b_lp)!=' ' then
        b_i1:=0;
        for b_lp1 in 1..dk_ma.count loop
            if dk_ma(b_lp1)=dk_ma_ct(b_lp) and dk_tc(b_lp1)='T' then b_i1:=1; exit; end if;
        end loop;
        if b_i1=0 then b_loi:='loi:Nhap ma cap tren ma: '||dk_ma(b_lp)||':loi'; return; end if;
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
                if PKH_MA_MA(b_lenh,b_ma_ct) then
                    b_loi:='loi:Vong lap ma cap tren ma: '||dk_ma(b_lp)||':loi'; return;
                end if;
                b_lenh:=b_lenh||','||dk_ma(b_i1);
            end if;
        end loop;
    end if;
end loop;
for b_lp in 1..dk_ma.count loop
    if dk_lkeM(b_lp)<>'C' then
        dk_ma_dkC(b_lp):=' ';
    elsif dk_lh_bh(b_lp)='C' then
        dk_ma_dkC(b_lp):=dk_ma_ct(b_lp);
    else
        dk_ma_dkC(b_lp):=FBH_MA_DKBS_MA_DK(dk_ma_dk(b_lp));
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
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_TAU_BPHI_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_so_id number;
    b_nhom varchar2(10); b_loai varchar2(10); b_cap varchar2(10); b_vlieu varchar2(10);
    b_ttai number; b_so_cn number; b_dtich number; b_csuat number; b_gia number; b_tuoi number;
    b_ma_sp varchar2(10); b_dkien varchar2(10); b_md_sd varchar2(10); b_nv_bh varchar2(10);
    b_ngay_bd number; b_ngay_kt number; b_ngay_hl number;

    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var;
	  dk_ma_ct pht_type.a_var; dk_ma_dk pht_type.a_var; dk_ma_dkC pht_type.a_var;
	  dk_kieu pht_type.a_var; dk_tien pht_type.a_num; dk_pt pht_type.a_num;
    dk_lkeM pht_type.a_var; dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var; dk_luy pht_type.a_var;
    dk_phi pht_type.a_num; dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num; dk_gvu pht_type.a_var; dk_lh_bh pht_type.a_var;
    
    lt_ma_dk pht_type.a_var; lt_ma_lt pht_type.a_var; lt_ten pht_type.a_nvar;
    b_dt_ct clob; b_dt_dk clob; b_dt_dkbs clob; b_dt_lt clob; b_dt_khd clob; b_dt_kbt clob;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_dkbs,dt_lt,dt_khd,dt_kbt');
EXECUTE IMMEDIATE b_lenh into b_dt_ct,b_dt_dk,b_dt_dkbs,b_dt_lt,b_dt_khd,b_dt_kbt using b_oraIn;
FKH_JS_NULL(b_dt_ct); FKH_JSa_NULL(b_dt_dk); FKH_JSa_NULL(b_dt_dkbs);
FKH_JSa_NULL(b_dt_lt); FKH_JSa_NULL(b_dt_khd); FKH_JSa_NULL(b_dt_kbt);
PBH_TAU_BPHI_TSO(
    b_dt_ct,b_nhom,b_loai,b_cap,b_vlieu,b_ttai,b_so_cn,b_dtich,b_csuat,b_gia,b_tuoi,
    b_ma_sp,b_dkien,b_md_sd,b_nv_bh,b_ngay_bd,b_ngay_kt,b_ngay_hl,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_nhom<>' ' and FBH_TAU_NHOM_HAN(b_nhom)<>'C' then
    b_loi:='loi:Sai nhom tau:loi'; raise PROGRAM_ERROR;
end if;
if b_loai<>' ' and FBH_TAU_LOAI_HAN(b_loai)<>'C' then
    b_loi:='loi:Sai loai tau:loi'; raise PROGRAM_ERROR;
end if;
if b_cap<>' ' and FBH_TAU_CAP_HAN(b_cap)<>'C' then
    b_loi:='loi:Sai cap tau:loi'; raise PROGRAM_ERROR;
end if;
if b_vlieu<>' ' and FBH_TAU_VLIEU_HAN(b_vlieu)<>'C' then
    b_loi:='loi:Sai vat lieu tau:loi'; raise PROGRAM_ERROR;
end if;
if b_ma_sp<>' ' and FBH_TAU_SP_HAN(b_ma_sp)<>'C' then
    b_loi:='loi:Sai ma san pham:loi'; raise PROGRAM_ERROR;
end if;
if b_nv_bh not in('V','T','D','N') then
    b_loi:='loi:Sai loai BH:loi'; raise PROGRAM_ERROR;
end if;
PBH_TAU_BPHI_TEST(b_dt_dk,b_dt_dkbs,b_dt_lt,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_ma_dk,dk_ma_dkC,dk_kieu,
    dk_tien,dk_pt,dk_phi,dk_lkeM,dk_lkeP,dk_lkeB,
    dk_luy,dk_lh_nv,dk_t_suat,dk_gvu,dk_lh_bh,lt_ma_dk,lt_ma_lt,lt_ten,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if dk_ma.count=0 then b_loi:='loi:Nhap dieu khoan:loi'; raise PROGRAM_ERROR; end if;
FBH_TAU_BPHI_SO_ID(b_nhom,b_loai,b_cap,b_vlieu,b_ttai,b_so_cn,b_dtich,b_csuat,b_gia,b_tuoi,
   b_ma_sp,b_dkien,b_md_sd,b_nv_bh,b_ngay_bd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id<>0 then
    PBH_TAU_BPHI_XOA_XOA(b_so_id,b_loi);
else
    PHT_ID_MOI(b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table bh_tau_phi:loi';
insert into bh_tau_phi values(
    b_ma_dvi,b_so_id,b_nhom,b_loai,b_cap,b_vlieu,
    b_ttai,b_so_cn,b_dtich,b_csuat,b_gia,b_tuoi,
    b_ma_sp,b_dkien,b_md_sd,b_nv_bh,b_ngay_bd,b_ngay_kt,b_nsd);
for b_lp in 1..dk_ma.count loop
    insert into bh_tau_phi_dk values(b_ma_dvi,b_so_id,b_lp,dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),
        dk_kieu(b_lp),dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),dk_lkeP(b_lp),dk_lkeM(b_lp),dk_lkeB(b_lp),dk_luy(b_lp),
        dk_ma_dk(b_lp),dk_lh_nv(b_lp),dk_t_suat(b_lp),0,dk_gvu(b_lp),dk_lh_bh(b_lp));
end loop;
for r_lp in(select * from
    (select bt,level from bh_tau_phi_dk where so_id=b_so_id start with ma_ct=' ' CONNECT BY prior ma=ma_ct)) loop
    update bh_tau_phi_dk set cap=r_lp.level where so_id=b_so_id and bt=r_lp.bt;
end loop;
insert into bh_tau_phi_txt values(b_ma_dvi,b_so_id,'dt_ct',b_dt_ct);
insert into bh_tau_phi_txt values(b_ma_dvi,b_so_id,'dt_dk',b_dt_dk);
if trim(b_dt_dkbs) is not null then
    insert into bh_tau_phi_txt values(b_ma_dvi,b_so_id,'dt_dkbs',b_dt_dkbs);
end if;
if lt_ma_lt.count<>0 then
    for b_lp in 1..lt_ma_lt.count loop
        insert into bh_tau_phi_lt values(b_ma_dvi,b_so_id,b_lp,lt_ma_lt(b_lp),lt_ma_dk(b_lp),lt_ten(b_lp));
    end loop;
    insert into bh_tau_phi_txt values(b_ma_dvi,b_so_id,'dt_lt',b_dt_lt);
end if;
if trim(b_dt_khd) is not null then
    insert into bh_tau_phi_txt values(b_ma_dvi,b_so_id,'dt_khd',b_dt_khd);
end if;
if trim(b_dt_kbt) is not null then
    insert into bh_tau_phi_txt values(b_ma_dvi,b_so_id,'dt_kbt',b_dt_kbt);
end if;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_BPHI_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS 
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Dan - Xoa bieu phi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then b_loi:='loi:Chon bieu phi can xoa:loi'; raise PROGRAM_ERROR; end if;
PBH_TAU_BPHI_XOA_XOA(b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/



-- Phu phi hoan cai
create or replace procedure PBH_TAU_PPTSO(
    b_oraIn clob,b_nhom out varchar2,b_loai out varchar2,b_nv_bh out varchar2,b_loi out varchar2,b_dk varchar2:='K')
AS
    b_lenh varchar2(1000);
begin
-- Dan
b_loi:='loi:Loi xu ly PBH_TAU_PPTSO:loi';
b_lenh:=FKH_JS_LENH('nhom,loai,nv_bh');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_loai,b_nv_bh using b_oraIn;
b_nhom:=nvl(trim(b_nhom),' '); b_loai:=nvl(trim(b_loai),' '); b_nv_bh:=nvl(trim(b_nv_bh),' ');
b_loi:='';
if b_dk='C' then
    if b_nhom<>' ' and FBH_TAU_NHOM_HAN(b_nhom)<>'C' then b_loi:='loi:Sai nhom tau:loi'; end if;
    if b_loai<>' ' and FBH_TAU_LOAI_HAN(b_loai)<>'C' then b_loi:='loi:Sai loai tau:loi'; end if;
    if b_nv_bh not in(' ','V','T','D','N','M') then b_loi:='loi:Sai loai bao hiem:loi'; end if;
    if trim(b_nhom||b_loai||b_nv_bh) is null then b_loi:='loi:Nhap tham so phu phi:loi'; end if;
end if;
end;
/
create or replace procedure PBH_TAU_PPHCAI_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tu,den');
EXECUTE IMMEDIATE b_lenh into b_tu,b_den using b_oraIn;
select count(*) into b_dong from bh_tau_pphcai;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(nhom,loai,nv_bh,pt,
    'nhomT' value FBH_TAU_NHOM_TEN(nhom),'loaiT' value FBH_TAU_LOAI_TEN(loai),
    'nv_bhT' value decode(nv_bh,'V','Vat chat','T','TNDS chu tau','D','TNDS mo rong','N','Tai nan thuyen vien','Mo rong'))
    order by nhom,loai,nv_bh,pt returning clob) into cs_lke from
    (select nhom,loai,nv_bh,pt,rownum sott from bh_tau_pphcai)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_PPHCAI_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_kq clob:='';
    b_nhom varchar2(10); b_loai varchar2(10); b_nv_bh varchar2(1);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_PPTSO(b_oraIn,b_nhom,b_loai,b_nv_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_tau_pphcai where nhom=b_nhom and loai=b_loai and nv_bh=b_nv_bh;
if b_i1=1 then
    select json_object('nhom' value FBH_TAU_NHOM_TENl(nhom),'loai' value FBH_TAU_LOAI_TENl(loai),
		nv_bh,pt,ngay_kt) into b_kq from bh_tau_pphcai where nhom=b_nhom and loai=b_loai and nv_bh=b_nv_bh;
end if;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_PPHCAI_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_nhom varchar2(10); b_loai varchar2(10); b_nv_bh varchar2(1);
    b_pt number; b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_PPTSO(b_oraIn,b_nhom,b_loai,b_nv_bh,b_loi,'C');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('pt,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_pt,b_ngay_kt using b_oraIn;
b_pt:=nvl(b_pt,0); b_ngay_kt:=nvl(b_ngay_kt,30000101);
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
delete bh_tau_pphcai where nhom=b_nhom and loai=b_loai and nv_bh=b_nv_bh;
insert into bh_tau_pphcai values(b_ma_dvi,b_nhom,b_loai,b_nv_bh,b_pt,b_ngay_kt,b_nsd);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_PPHCAI_XOA(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100);
    b_nhom varchar2(10); b_loai varchar2(10); b_nv_bh varchar2(1);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_PPTSO(b_oraIn,b_nhom,b_loai,b_nv_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete bh_tau_pphcai where nhom=b_nhom and loai=b_loai and nv_bh=b_nv_bh;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_TAU_PPHCAI_PT(
    b_nhom varchar2,b_loai varchar2,b_nv_bh varchar2) return number
AS
    b_kq number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select nvl(max(pt),0) into b_kq from bh_tau_pphcai where nhom=b_nhom and loai in (' ',b_loai) and nv_bh=b_nv_bh and ngay_kt>b_ngay;
return b_kq;
end;
/
create or replace procedure PBH_TAU_PPHCAI_PT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_pt number;
    b_nhom varchar2(10); b_loai varchar2(10); b_nv_bh varchar2(1);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_PPTSO(b_oraIn,b_nhom,b_loai,b_nv_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_pt:=FBH_TAU_PPHCAI_PT(b_nhom,b_loai,b_nv_bh);
select json_object('pt' value b_pt) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Phu phi tuoi
create or replace procedure PBH_TAU_PPTUOI_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tu,den');
EXECUTE IMMEDIATE b_lenh into b_tu,b_den using b_oraIn;
select count(*) into b_dong from bh_tau_pphcai;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(nhom,loai,tuoi,nv_bh,pt,
    'nhomT' value FBH_TAU_NHOM_TEN(nhom),'loaiT' value FBH_TAU_LOAI_TEN(loai),
    'nv_bhT' value decode(nv_bh,'V','Vat chat','T','TNDS chu tau','D','TNDS mo rong','N','Tai nan thuyen vien','Mo rong'))
    order by nhom,loai,tuoi,nv_bh,pt returning clob) into cs_lke from
    (select nhom,loai,tuoi,nv_bh,pt,rownum sott from bh_tau_pptuoi)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_PPTUOI_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_kq clob:='';
    b_nhom varchar2(10); b_loai varchar2(10); b_nv_bh varchar2(1); b_tuoi number:=FKH_JS_GTRIn(b_oraIn,'tuoi');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_PPTSO(b_oraIn,b_nhom,b_loai,b_nv_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_tau_pptuoi where nhom=b_nhom and loai=b_loai and nv_bh=b_nv_bh and tuoi=b_tuoi;
if b_i1=1 then
    select json_object('nhom' value FBH_TAU_NHOM_TENl(nhom),'loai' value FBH_TAU_LOAI_TENl(loai),
        tuoi,nv_bh,pt,ngay_kt) into b_kq from bh_tau_pptuoi where nhom=b_nhom and loai=b_loai and nv_bh=b_nv_bh and tuoi=b_tuoi;
end if;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_PPTUOI_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_nhom varchar2(10); b_loai varchar2(10); b_nv_bh varchar2(1); b_tuoi number;
    b_pt number; b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_PPTSO(b_oraIn,b_nhom,b_loai,b_nv_bh,b_loi,'C');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tuoi,pt,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_tuoi,b_pt,b_ngay_kt using b_oraIn;
b_pt:=nvl(b_pt,0); b_ngay_kt:=nvl(b_ngay_kt,30000101);
delete bh_tau_pptuoi where nhom=b_nhom and loai=b_loai and nv_bh=b_nv_bh and tuoi=b_tuoi;
insert into bh_tau_pptuoi values(b_ma_dvi,b_nhom,b_loai,b_nv_bh,b_tuoi,b_pt,b_ngay_kt,b_nsd);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_PPTUOI_XOA(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100);
    b_nhom varchar2(10); b_loai varchar2(10); b_nv_bh varchar2(1); b_tuoi number:=FKH_JS_GTRIn(b_oraIn,'tuoi');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_PPTSO(b_oraIn,b_nhom,b_loai,b_nv_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete bh_tau_pptuoi where nhom=b_nhom and loai=b_loai and nv_bh=b_nv_bh and tuoi=b_tuoi;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_TAU_PPTUOI_PT(
    b_nhom varchar2,b_loai varchar2,b_nv_bh varchar2,b_tuoi number) return number
AS
    b_kq number:=0;  b_tuoiM number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select nvl(max(tuoi),-1) into b_tuoiM from bh_tau_pptuoi where nhom=b_nhom and loai in (' ',b_loai) and nv_bh=b_nv_bh and tuoi<=b_tuoi and ngay_kt>b_ngay;
if b_tuoiM<>-1 then
    select nvl(max(pt),0) into b_kq from bh_tau_pptuoi where nhom=b_nhom and loai in (' ',b_loai) and nv_bh=b_nv_bh and tuoi=b_tuoiM;
end if;
return b_kq;
end;
/
create or replace procedure PBH_TAU_PPTUOI_PT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_pt number;
    b_nhom varchar2(10); b_loai varchar2(10); b_nv_bh varchar2(1); b_tuoi number:=FKH_JS_GTRIn(b_oraIn,'tuoi');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_PPTSO(b_oraIn,b_nhom,b_loai,b_nv_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_pt:=FBH_TAU_PPTUOI_PT(b_nhom,b_loai,b_nv_bh,b_tuoi);
select json_object('pt' value b_pt) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Phu phi vtoc
create or replace procedure PBH_TAU_PPVTOC_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tu,den');
EXECUTE IMMEDIATE b_lenh into b_tu,b_den using b_oraIn;
select count(*) into b_dong from bh_tau_pphcai;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(nhom,loai,vtoc,nv_bh,pt,
    'nhomT' value FBH_TAU_NHOM_TEN(nhom),'loaiT' value FBH_TAU_LOAI_TEN(loai),
    'nv_bhT' value decode(nv_bh,'V','Vat chat','T','TNDS chu tau','D','TNDS mo rong','N','Tai nan thuyen vien','Mo rong'))
    order by nhom,loai,vtoc,nv_bh returning clob) into cs_lke from
    (select nhom,loai,vtoc,nv_bh,pt,rownum sott from bh_tau_ppvtoc)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_PPVTOC_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_kq clob:='';
    b_nhom varchar2(10); b_loai varchar2(10); b_nv_bh varchar2(1); b_vtoc number:=FKH_JS_GTRIn(b_oraIn,'vtoc');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_PPTSO(b_oraIn,b_nhom,b_loai,b_nv_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_tau_ppvtoc where nhom=b_nhom and loai=b_loai and nv_bh=b_nv_bh and vtoc=b_vtoc;
if b_i1=1 then
    select json_object('nhom' value FBH_TAU_NHOM_TENl(nhom),'loai' value FBH_TAU_LOAI_TENl(loai),
		vtoc,nv_bh,pt,ngay_kt) into b_kq from bh_tau_ppvtoc where nhom=b_nhom and loai=b_loai and nv_bh=b_nv_bh and vtoc=b_vtoc;
end if;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_PPVTOC_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_nhom varchar2(10); b_loai varchar2(10); b_nv_bh varchar2(1); b_vtoc number;
    b_pt number; b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_PPTSO(b_oraIn,b_nhom,b_loai,b_nv_bh,b_loi,'C');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('vtoc,pt,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_vtoc,b_pt,b_ngay_kt using b_oraIn;
b_pt:=nvl(b_pt,0); b_ngay_kt:=nvl(b_ngay_kt,30000101);
delete bh_tau_ppvtoc where nhom=b_nhom and loai=b_loai and nv_bh=b_nv_bh and vtoc=b_vtoc;
insert into bh_tau_ppvtoc values(b_ma_dvi,b_nhom,b_loai,b_nv_bh,b_vtoc,b_pt,b_ngay_kt,b_nsd);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_PPVTOC_XOA(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100);
    b_nhom varchar2(10); b_loai varchar2(10); b_nv_bh varchar2(1); b_vtoc number:=FKH_JS_GTRIn(b_oraIn,'vtoc');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_PPTSO(b_oraIn,b_nhom,b_loai,b_nv_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete bh_tau_ppvtoc where nhom=b_nhom and loai=b_loai and nv_bh=b_nv_bh and vtoc=b_vtoc;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_TAU_PPVTOC_PT(
    b_nhom varchar2,b_loai varchar2,b_nv_bh varchar2,b_vtoc number) return number
AS
    b_kq number:=0;  b_vtocM number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select nvl(max(vtoc),-1) into b_vtocM from bh_tau_ppvtoc where nhom=b_nhom and loai in (' ',b_loai) and nv_bh=b_nv_bh and vtoc<=b_vtoc and ngay_kt>b_ngay;
if b_vtocM<>-1 then
    select nvl(max(pt),0) into b_kq from bh_tau_ppvtoc where nhom=b_nhom and loai in (' ',b_loai) and nv_bh=b_nv_bh and vtoc=b_vtocM;
end if;
return b_kq;
end;
/
create or replace procedure PBH_TAU_PPVTOC_PT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_pt number;
    b_nhom varchar2(10); b_loai varchar2(10); b_nv_bh varchar2(1); b_vtoc number:=FKH_JS_GTRIn(b_oraIn,'vtoc');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_PPTSO(b_oraIn,b_nhom,b_loai,b_nv_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_pt:=FBH_TAU_PPVTOC_PT(b_nhom,b_loai,b_nv_bh,b_vtoc);
select json_object('pt' value b_pt) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Phu phi vlieu
create or replace procedure PBH_TAU_PPVLIEU_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tu,den');
EXECUTE IMMEDIATE b_lenh into b_tu,b_den using b_oraIn;
select count(*) into b_dong from bh_tau_pphcai;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(nhom,loai,vlieu,nv_bh,pt,
    'nhomT' value FBH_TAU_NHOM_TEN(nhom),'loaiT' value FBH_TAU_LOAI_TEN(loai),'vlieuT' value FBH_TAU_VLIEU_TEN(vlieu),
    'nv_bhT' value decode(nv_bh,'V','Vat chat','T','TNDS chu tau','D','TNDS mo rong','N','Tai nan thuyen vien','Mo rong'))
    order by nhom,loai,vlieu,nv_bh returning clob) into cs_lke from
    (select nhom,loai,vlieu,nv_bh,pt,rownum sott from bh_tau_ppvlieu)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_PPVLIEU_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_tau_ppvlieu;
select JSON_ARRAYAGG(json_object(*) order by nhom,loai,nv_bh,vlieu returning clob) into cs_lke from bh_tau_ppvlieu;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_PPVLIEU_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_kq clob:='';
    b_nhom varchar2(10); b_loai varchar2(10); b_nv_bh varchar2(1); b_vlieu varchar2(10):=FKH_JS_GTRIs(b_oraIn,'vlieu');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_PPTSO(b_oraIn,b_nhom,b_loai,b_nv_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_tau_ppvlieu where nhom=b_nhom and loai=b_loai and nv_bh=b_nv_bh and vlieu=b_vlieu;
if b_i1=1 then
    select json_object('nhom' value FBH_TAU_NHOM_TENl(nhom),'loai' value FBH_TAU_LOAI_TENl(loai),'vlieu' value FBH_TAU_VLIEU_TENl(vlieu),
	nv_bh,pt,ngay_kt) into b_kq from bh_tau_ppvlieu where nhom=b_nhom and loai=b_loai and nv_bh=b_nv_bh and vlieu=b_vlieu;
end if;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_PPVLIEU_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_nhom varchar2(10); b_loai varchar2(10); b_nv_bh varchar2(1); b_vlieu varchar2(10);
    b_pt number; b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_PPTSO(b_oraIn,b_nhom,b_loai,b_nv_bh,b_loi,'C');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('vlieu,pt,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_vlieu,b_pt,b_ngay_kt using b_oraIn;
b_pt:=nvl(b_pt,0); b_ngay_kt:=nvl(b_ngay_kt,30000101);
delete bh_tau_ppvlieu where nhom=b_nhom and loai=b_loai and nv_bh=b_nv_bh and vlieu=b_vlieu;
insert into bh_tau_ppvlieu values(b_ma_dvi,b_nhom,b_loai,b_nv_bh,b_vlieu,b_pt,b_ngay_kt,b_nsd);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_PPVLIEU_XOA(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100);
    b_nhom varchar2(10); b_loai varchar2(10); b_nv_bh varchar2(1); b_vlieu varchar2(10):=FKH_JS_GTRIs(b_oraIn,'vlieu');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_PPTSO(b_oraIn,b_nhom,b_loai,b_nv_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete bh_tau_ppvlieu where nhom=b_nhom and loai=b_loai and nv_bh=b_nv_bh and vlieu=b_vlieu;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_TAU_PPVLIEU_PT(
    b_nhom varchar2,b_loai varchar2,b_nv_bh varchar2,b_vlieu varchar2) return number
AS
    b_kq number:=0; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select nvl(max(pt),0) into b_kq from bh_tau_ppvlieu where nhom=b_nhom and loai in (' ',b_loai) and nv_bh=b_nv_bh and vlieu=b_vlieu;
return b_kq;
end;
/
create or replace procedure PBH_TAU_PPVLIEU_PT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_pt number;
    b_nhom varchar2(10); b_loai varchar2(10); b_nv_bh varchar2(1); b_vlieu varchar2(10):=FKH_JS_GTRIs(b_oraIn,'vlieu');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_PPTSO(b_oraIn,b_nhom,b_loai,b_nv_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_pt:=FBH_TAU_PPVLIEU_PT(b_nhom,b_loai,b_nv_bh,b_vlieu);
select json_object('pt' value b_pt) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Phu phi cap tau
create or replace procedure PBH_TAU_PPCAP_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_dong number:=0; cs_lke clob:='';
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tu,den');
EXECUTE IMMEDIATE b_lenh into b_tu,b_den using b_oraIn;
select count(*) into b_dong from bh_tau_pphcai;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(nhom,loai,cap,nv_bh,pt,
    'nhomT' value FBH_TAU_NHOM_TEN(nhom),'loaiT' value FBH_TAU_LOAI_TEN(loai),'capT' value FBH_TAU_CAP_TEN(cap),
    'nv_bhT' value decode(nv_bh,'V','Vat chat','T','TNDS chu tau','D','TNDS mo rong','N','Tai nan thuyen vien','Mo rong'))
    order by nhom,loai,cap,nv_bh returning clob) into cs_lke from
    (select nhom,loai,cap,nv_bh,pt,rownum sott from bh_tau_ppcap)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_PPCAP_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_tau_ppcap;
select JSON_ARRAYAGG(json_object(*) order by nhom,loai,nv_bh,cap returning clob) into cs_lke from bh_tau_ppcap;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_PPCAP_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_kq clob:='';
    b_nhom varchar2(10); b_loai varchar2(10); b_nv_bh varchar2(1); b_cap varchar2(10):=FKH_JS_GTRIs(b_oraIn,'cap');
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_PPTSO(b_oraIn,b_nhom,b_loai,b_nv_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_tau_ppcap where nhom=b_nhom and loai=b_loai and nv_bh=b_nv_bh and cap=b_cap;
if b_i1=1 then
    select json_object('nhom' value FBH_TAU_NHOM_TENl(nhom),'loai' value FBH_TAU_LOAI_TENl(loai),'cap' value FBH_TAU_CAP_TENl(cap),
  nv_bh,pt,ngay_kt) into b_kq from bh_tau_ppcap where nhom=b_nhom and loai=b_loai and nv_bh=b_nv_bh and cap=b_cap;
end if;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_PPCAP_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_nhom varchar2(10); b_loai varchar2(10); b_nv_bh varchar2(1); b_cap varchar2(10);
    b_pt number; b_ngay_kt number;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_PPTSO(b_oraIn,b_nhom,b_loai,b_nv_bh,b_loi,'C');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('cap,pt,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_cap,b_pt,b_ngay_kt using b_oraIn;
b_pt:=nvl(b_pt,0); b_ngay_kt:=nvl(b_ngay_kt,30000101);
delete bh_tau_ppcap where nhom=b_nhom and loai=b_loai and nv_bh=b_nv_bh and cap=b_cap;
insert into bh_tau_ppcap values(b_ma_dvi,b_nhom,b_loai,b_nv_bh,b_cap,b_pt,b_ngay_kt,b_nsd);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_PPCAP_XOA(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100);
    b_nhom varchar2(10); b_loai varchar2(10); b_nv_bh varchar2(1); b_cap varchar2(10):=FKH_JS_GTRIs(b_oraIn,'cap');
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_PPTSO(b_oraIn,b_nhom,b_loai,b_nv_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete bh_tau_ppcap where nhom=b_nhom and loai=b_loai and nv_bh=b_nv_bh and cap=b_cap;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_TAU_PPCAP_PT(
    b_nhom varchar2,b_loai varchar2,b_nv_bh varchar2,b_cap varchar2) return number
AS
    b_kq number:=0; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select nvl(max(pt),0) into b_kq from bh_tau_ppcap where nhom=b_nhom and loai in (' ',b_loai) and nv_bh=b_nv_bh and cap=b_cap;
return b_kq;
end;
/
create or replace procedure PBH_TAU_PPCAP_PT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_pt number;
    b_nhom varchar2(10); b_loai varchar2(10); b_nv_bh varchar2(1); b_cap varchar2(10):=FKH_JS_GTRIs(b_oraIn,'cap');
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_PPTSO(b_oraIn,b_nhom,b_loai,b_nv_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_pt:=Fbh_tau_ppcap_PT(b_nhom,b_loai,b_nv_bh,b_cap);
select json_object('pt' value b_pt) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_BPHI_THEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_i1 number; b_lenh varchar2(1000); b_so_id number;
    b_nhom varchar2(10); b_loai varchar2(10); b_cap varchar2(10); b_vlieu varchar2(10);
    b_ttai number; b_so_cn number; b_dtich number; b_csuat number; b_gia number; b_tuoi number;
    b_ma_sp varchar2(10); b_dkien varchar2(10); b_md_sd varchar2(10); b_nv_bh varchar2(10);
    b_ngay_bd number; b_ngay_kt number; b_ngay_hl number; b_nam_sx number;
    b_so_idS varchar2(100):=''; b_hcai varchar2(1); b_vtoc number;
    a_nv pht_type.a_var; b_vu varchar2(10);
begin
-- Dan - Tra so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAU_BPHI_TSO(
    b_oraIn,b_nhom,b_loai,b_cap,b_vlieu,b_ttai,b_so_cn,b_dtich,b_csuat,b_gia,b_tuoi,
    b_ma_sp,b_dkien,b_md_sd,b_nv_bh,b_ngay_bd,b_ngay_kt,b_ngay_hl,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nvv,nvt,nvn,nam_sx,hcai,vtoc,vu');
EXECUTE IMMEDIATE b_lenh into a_nv(1),a_nv(2),a_nv(3),b_nam_sx,b_hcai,b_vtoc,b_vu using b_oraIn;
b_tuoi:=FBH_TAU_TUOI(b_nam_sx); b_hcai:=nvl(trim(b_hcai),'K'); b_vtoc:=nvl(b_vtoc,0);
for b_lp in 1..3 loop
    if nvl(trim(a_nv(b_lp)),' ')='C' then
        if b_lp=1 then a_nv(b_lp):='V';
        elsif b_lp=2 then a_nv(b_lp):='T';
        elsif b_lp=3 then a_nv(b_lp):='N';
        end if;
        FBH_TAU_BPHI_SO_ID(
            b_nhom,b_loai,b_cap,b_vlieu,
            b_ttai,b_so_cn,b_dtich,b_csuat,b_gia,b_tuoi,
            b_ma_sp,b_dkien,b_md_sd,a_nv(b_lp),b_ngay_hl,b_so_id,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
        if b_so_id<>0 then
            b_so_idS:=b_so_idS||',';
            b_so_idS:=b_so_idS||to_char(b_so_id);
            if b_hcai<>'C' then b_i1:=0; else b_i1:=FBH_TAU_PPHCAI_PT(b_nhom,b_loai,a_nv(b_lp)); end if;
            b_i1:=b_i1+FBH_TAU_PPTUOI_PT(b_nhom,b_loai,a_nv(b_lp),b_tuoi)+
        FBH_TAU_PPVTOC_PT(b_nhom,b_loai,a_nv(b_lp),b_vtoc)+
        FBH_TAU_PPVLIEU_PT(b_nhom,b_loai,a_nv(b_lp),b_vlieu);
        else
            b_so_idS:='0'; exit;
        end if;
    end if;
end loop;
b_oraOut:='';
if b_so_idS <> '0' then
  if b_vu='dk' then
        select JSON_ARRAYAGG(json_object(ma,ten,tc,ma_ct,kieu,tien,pt,phi,lkep,lkeb,luy,ma_dk,lh_nv,t_suat,cap,lh_bh) order by bt returning clob)
            into b_oraOut from bh_tau_phi_dk where so_id=b_so_idS and lh_bh<>'M' order by bt;
  elsif b_vu='dkbs' then
        select JSON_ARRAYAGG(json_object(ma,ten,tc,ma_ct,kieu,tien,pt,phi,lkep,lkeb,luy,ma_dk,lh_nv,t_suat,cap,lh_bh) order by bt returning clob)
            into b_oraOut from bh_tau_phi_dk where so_id=b_so_idS and lh_bh='M' order by bt;
  elsif b_vu='lt' then
        select txt into b_oraOut from bh_tau_phi_txt where so_id=b_so_idS and loai='dt_lt';
    end if;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_KBT_KVU_TAU(b_ma_dvi varchar2, b_so_id number, b_gcn varchar2) return varchar2
as
    b_kq varchar2(1000):=''; b_lenh varchar2(1000); dt_kbt clob; dt_ds clob;
    b_nv varchar2(1);
    a_kbt_ma pht_type.a_var; a_kbt pht_type.a_clob; a_gcn pht_type.a_clob; 
    kbt_ma pht_type.a_var; kbt_nd pht_type.a_var;
    a_dt_kbt pht_type.a_clob;
begin
-- viet anh -- lay KVU theo so_id trong txt phuc vu bao cao
if b_so_id is not null then
    select t.nv into b_nv from bh_tau t where t.ma_dvi = b_ma_dvi and t.so_id = b_so_id;
    if b_nv='G' then
        select FKH_JS_BONH(t.txt) into dt_kbt from bh_tau_txt t where t.ma_dvi = b_ma_dvi and t.so_id = b_so_id and t.loai='dt_kbt';
    else
        select FKH_JS_BONH(t.txt) into dt_kbt from bh_tau_txt t where t.ma_dvi = b_ma_dvi and t.so_id = b_so_id and t.loai='ds_kbt';
        b_lenh := FKH_JS_LENH('');
        EXECUTE IMMEDIATE b_lenh bulk collect into a_dt_kbt using dt_kbt;
        
        select FKH_JS_BONH(t.txt) into dt_ds from bh_tau_txt t where t.ma_dvi = b_ma_dvi and t.so_id = b_so_id and t.loai='ds_ct';
        b_lenh := FKH_JS_LENH('');
        EXECUTE IMMEDIATE b_lenh bulk collect into a_gcn using dt_ds;
        for b_lp in 1..a_gcn.count loop            
           if b_gcn = FKH_JS_GTRIs(a_gcn(b_lp),'gcn') then
              dt_kbt:= a_dt_kbt(b_lp);
           end if;
        end loop;
    end if;
    b_lenh := FKH_JS_LENH('ma,kbt');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_kbt_ma,a_kbt USING dt_kbt;
    for b_lp in 1..a_kbt_ma.count loop
       if a_kbt(b_lp) is not null then
         b_lenh:=FKH_JS_LENH('ma,nd');
         EXECUTE IMMEDIATE b_lenh bulk collect into kbt_ma,kbt_nd using a_kbt(b_lp);
         for b_lp1 in 1..kbt_ma.count loop
           -- neu ma  = KVU
           if kbt_ma(b_lp1) = 'KVU' then
                b_kq := kbt_nd(b_lp1);
                exit;
           end if;
         end loop;
       end if;
    end loop;
end if;
return b_kq;
end;
