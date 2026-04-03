-- quy mo -- 
create or replace function FBH_DTAU_QMO_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_dtau_qmo where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_DTAU_QMO_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_dtau_qmo where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_DTAU_QMO_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_dtau_qmo where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_DTAU_QMO_LKE(       
       b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); cs_lke clob; 
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,ngay_kt)) into cs_lke from bh_dtau_qmo order by ma;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_QMO_CT(
	b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma varchar2(10); cs_ct clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma');
EXECUTE IMMEDIATE b_lenh into b_ma using b_oraIn;
select count(*) into b_i1 from bh_dtau_qmo where ma=b_ma;
if b_i1=1 then
    select json_object(ma,ten,ngay_kt) into cs_ct from bh_dtau_qmo where ma=b_ma;
end if;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_QMO_NH(
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
b_ma:=nvl(trim(b_ma),' '); b_ten:=nvl(trim(b_ten),' ');
if b_ma=' ' or b_ten=' ' then b_loi:='loi:Nhap nghiep vu,ma,ten:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_dtau_qmo where ma=b_ma;
insert into bh_dtau_qmo values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_QMO_XOA(
	b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_ma varchar2(10); 
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma');
EXECUTE IMMEDIATE b_lenh into b_ma using b_oraIn;
b_ma:=nvl(trim(b_ma),' ');
delete bh_dtau_qmo where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- noi thi cong --
create or replace function FBH_DTAU_NTC_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_dtau_ntc where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_DTAU_NTC_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_dtau_ntc where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_DTAU_NTC_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_dtau_ntc where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_DTAU_NTC_LKE(       
       b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); cs_lke clob; 
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,ngay_kt)) into cs_lke from bh_dtau_ntc order by ma;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_NTC_CT(
	b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma varchar2(10); cs_ct clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma');
EXECUTE IMMEDIATE b_lenh into b_ma using b_oraIn;
select count(*) into b_i1 from bh_dtau_ntc where ma=b_ma;
if b_i1=1 then
    select json_object(ma,ten,ngay_kt) into cs_ct from bh_dtau_ntc where ma=b_ma;
end if;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_NTC_NH(
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
b_ma:=nvl(trim(b_ma),' '); b_ten:=nvl(trim(b_ten),' ');
if b_ma=' ' or b_ten=' ' then b_loi:='loi:Nhap nghiep vu,ma,ten:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_dtau_ntc where ma=b_ma;
insert into bh_dtau_ntc values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_NTC_XOA(
	b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_ma varchar2(10); 
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma');
EXECUTE IMMEDIATE b_lenh into b_ma using b_oraIn;
b_ma:=nvl(trim(b_ma),' ');
delete bh_dtau_ntc where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- vat lieu dan do --

create or replace function FBH_DTAU_VLIEUDA_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_dtau_vlieuda where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_DTAU_VLIEUDA_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_dtau_vlieuda where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_DTAU_VLIEUDA_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_dtau_vlieuda where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_DTAU_VLIEUDA_LKE(       
       b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); cs_lke clob; 
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,ngay_kt)) into cs_lke from bh_dtau_vlieuda order by ma;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_VLIEUDA_CT(
	b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma varchar2(10); cs_ct clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma');
EXECUTE IMMEDIATE b_lenh into b_ma using b_oraIn;
select count(*) into b_i1 from bh_dtau_vlieuda where ma=b_ma;
if b_i1=1 then
    select json_object(ma,ten,ngay_kt) into cs_ct from bh_dtau_vlieuda where ma=b_ma;
end if;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_VLIEUDA_NH(
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
b_ma:=nvl(trim(b_ma),' '); b_ten:=nvl(trim(b_ten),' ');
if b_ma=' ' or b_ten=' ' then b_loi:='loi:Nhap nghiep vu,ma,ten:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_dtau_vlieuda where ma=b_ma;
insert into bh_dtau_vlieuda values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_VLIEUDA_XOA(
	b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_ma varchar2(10); 
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma');
EXECUTE IMMEDIATE b_lenh into b_ma using b_oraIn;
b_ma:=nvl(trim(b_ma),' ');
delete bh_dtau_vlieuda where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- loai tau --

create or replace function FBH_DTAU_LOAI_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_dtau_loai where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_DTAU_LOAI_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_dtau_loai where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_DTAU_LOAI_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_dtau_loai where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_DTAU_LOAI_LKE(       
       b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); cs_lke clob; 
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,ngay_kt)) into cs_lke from bh_dtau_loai order by ma;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_LOAI_CT(
	b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma varchar2(10); cs_ct clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma');
EXECUTE IMMEDIATE b_lenh into b_ma using b_oraIn;
select count(*) into b_i1 from bh_dtau_loai where ma=b_ma;
if b_i1=1 then
    select json_object(ma,ten,ngay_kt) into cs_ct from bh_dtau_loai where ma=b_ma;
end if;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_LOAI_NH(
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
b_ma:=nvl(trim(b_ma),' '); b_ten:=nvl(trim(b_ten),' ');
if b_ma=' ' or b_ten=' ' then b_loi:='loi:Nhap nghiep vu,ma,ten:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_dtau_loai where ma=b_ma;
insert into bh_dtau_loai values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_LOAI_XOA(
	b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_ma varchar2(10); 
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma');
EXECUTE IMMEDIATE b_lenh into b_ma using b_oraIn;
b_ma:=nvl(trim(b_ma),' ');
delete bh_dtau_loai where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- vat lieu dong tau --

create or replace function FBH_DTAU_VLIEUDO_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_dtau_vlieudo where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_DTAU_VLIEUDO_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_dtau_vlieudo where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_DTAU_VLIEUDO_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_dtau_vlieudo where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_DTAU_VLIEUDO_LKE(       
       b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); cs_lke clob; 
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,ngay_kt)) into cs_lke from bh_dtau_vlieudo order by ma;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_VLIEUDO_CT(
	b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma varchar2(10); cs_ct clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma');
EXECUTE IMMEDIATE b_lenh into b_ma using b_oraIn;
select count(*) into b_i1 from bh_dtau_vlieudo where ma=b_ma;
if b_i1=1 then
    select json_object(ma,ten,ngay_kt) into cs_ct from bh_dtau_vlieudo where ma=b_ma;
end if;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_VLIEUDO_NH(
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
b_ma:=nvl(trim(b_ma),' '); b_ten:=nvl(trim(b_ten),' ');
if b_ma=' ' or b_ten=' ' then b_loi:='loi:Nhap nghiep vu,ma,ten:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_dtau_vlieudo where ma=b_ma;
insert into bh_dtau_vlieudo values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_VLIEUDO_XOA(
	b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_ma varchar2(10); 
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma');
EXECUTE IMMEDIATE b_lenh into b_ma using b_oraIn;
b_ma:=nvl(trim(b_ma),' ');
delete bh_dtau_vlieudo where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- cach ha thuy --

create or replace function FBH_DTAU_HTHUY_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_dtau_hthuy where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_DTAU_HTHUY_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_dtau_hthuy where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_DTAU_HTHUY_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_dtau_hthuy where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_DTAU_HTHUY_LKE(       
       b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); cs_lke clob; 
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,ngay_kt)) into cs_lke from bh_dtau_hthuy order by ma;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_HTHUY_CT(
	b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma varchar2(10); cs_ct clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma');
EXECUTE IMMEDIATE b_lenh into b_ma using b_oraIn;
select count(*) into b_i1 from bh_dtau_hthuy where ma=b_ma;
if b_i1=1 then
    select json_object(ma,ten,ngay_kt) into cs_ct from bh_dtau_hthuy where ma=b_ma;
end if;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_HTHUY_NH(
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
b_ma:=nvl(trim(b_ma),' '); b_ten:=nvl(trim(b_ten),' ');
if b_ma=' ' or b_ten=' ' then b_loi:='loi:Nhap nghiep vu,ma,ten:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_dtau_hthuy where ma=b_ma;
insert into bh_dtau_hthuy values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_HTHUY_XOA(
	b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_ma varchar2(10); 
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma');
EXECUTE IMMEDIATE b_lenh into b_ma using b_oraIn;
b_ma:=nvl(trim(b_ma),' ');
delete bh_dtau_hthuy where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- cap tau --
create or replace function FBH_DTAU_CAP_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_dtau_cap where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_DTAU_CAP_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_dtau_cap where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_DTAU_CAP_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_dtau_cap where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_DTAU_CAP_LKE(       
       b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); cs_lke clob; 
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,ngay_kt)) into cs_lke from bh_dtau_cap order by ma;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_CAP_CT(
	b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma varchar2(10); cs_ct clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma');
EXECUTE IMMEDIATE b_lenh into b_ma using b_oraIn;
select count(*) into b_i1 from bh_dtau_cap where ma=b_ma;
if b_i1=1 then
    select json_object(ma,ten,ngay_kt) into cs_ct from bh_dtau_cap where ma=b_ma;
end if;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_CAP_NH(
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
b_ma:=nvl(trim(b_ma),' '); b_ten:=nvl(trim(b_ten),' ');
if b_ma=' ' or b_ten=' ' then b_loi:='loi:Nhap nghiep vu,ma,ten:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_dtau_cap where ma=b_ma;
insert into bh_dtau_cap values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_CAP_XOA(
	b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_ma varchar2(10); 
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma');
EXECUTE IMMEDIATE b_lenh into b_ma using b_oraIn;
b_ma:=nvl(trim(b_ma),' ');
delete bh_dtau_cap where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_DTAU_BPHI_SO_ID(
    b_nhom varchar2,b_qmo varchar2,b_ntc varchar2,b_vlieuda varchar2,
    b_loai varchar2,b_vlieudo varchar2,b_hthuy varchar2,b_dtich number,b_ttai number,b_kcach number,b_tgian number,
    b_nv_bh varchar2,b_ngay_bdN number,b_so_id out number,b_loi out varchar2)
AS
    b_ngay_bd number:=b_ngay_bdN;
    b_ttaiM number; b_dtichM number; b_kcachM number; b_tgianM number;
begin
-- Nam - Tra so ID phi
b_loi:='Loi:Loi xu ly FBH_DTAU_BPHI_SO_ID:loi';
if b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
b_so_id:=0;
select nvl(max(ttai),0),nvl(max(dtich),0),nvl(max(kcach),0),nvl(max(tgian),0)
    into b_ttaiM,b_dtichM,b_kcachM,b_tgianM from bh_dtau_phi where
    nhom in(' ',b_nhom) and loai in(' ',b_loai) and qmo in(' ',b_qmo) and ntc in(' ',b_ntc) and vlieuda in(' ',b_vlieuda) and
    vlieudo in(' ',b_vlieudo) and hthuy in(' ',b_hthuy) and nv_bh=b_nv_bh and
    b_ngay_bd between ngay_bd and ngay_kt and ttai<=b_ttai and kcach<=b_kcach and
    dtich<=b_dtich and tgian<=b_tgian;
select nvl(max(so_id),0) into b_so_id from bh_dtau_phi where
    nhom in(' ',b_nhom) and loai in(' ',b_loai) and qmo in(' ',b_qmo) and ntc in(' ',b_ntc) and vlieuda in(' ',b_vlieuda) and
    vlieudo in(' ',b_vlieudo) and hthuy in(' ',b_hthuy) and nv_bh=b_nv_bh and
    b_ngay_bd between ngay_bd and ngay_kt and ttai=b_ttaiM and kcach=b_kcachM and
    dtich=b_dtichM and tgian=b_tgianM;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_DTAU_BPHI_CTs(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_nv varchar2(10); b_so_idS varchar2(100);
begin
-- Dan - Tra so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HOP','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FBH_DTAU_BPHI_CTs(b_oraIn,b_nv,b_so_idS,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:=' ';
select json_object('nv' value b_nv,'so_id' value b_so_idS) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_DTAU_BPHI_CTs(
    dt_ct clob,b_nv out varchar2,b_so_idS out varchar2,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_so_id number;
    a_nv pht_type.a_var;
    b_qmo varchar2(10); b_ntc varchar2(10); b_vlieuda varchar2(10);
    b_loai varchar2(10); b_vlieudo varchar2(10); b_dtich number;
    b_ttai number; b_hthuy varchar2(10); b_tgian number; b_kcach number;
    b_ngay_bd number;
begin
-- Dan - Tra so ID
b_loi:='loi:Loi xu ly FBH_DTAU_BPHI_CTs:loi';
b_nv:=''; b_so_idS:='';
b_lenh:=FKH_JS_LENH('nvv,nvt,nvd,nvn');
EXECUTE IMMEDIATE b_lenh into a_nv(1),a_nv(2),a_nv(3),a_nv(4) using dt_ct;
b_lenh:=FKH_JS_LENH('qmo,ntc,vlieuda,loai,vlieudo,dtich,ttai,hthuy,tgian,kcach,ngay_bd');
EXECUTE IMMEDIATE b_lenh into b_qmo,b_ntc,b_vlieuda,b_loai,b_vlieudo,b_dtich,b_ttai,b_hthuy,b_tgian,
        b_kcach,b_ngay_bd using dt_ct;
b_ttai:=nvl(b_ttai,0); b_dtich:=nvl(b_dtich,0); b_tgian:=nvl(b_tgian,0); b_kcach:=nvl(b_kcach,0);
b_qmo:=NVL(trim(b_qmo),' '); b_ntc:=NVL(trim(b_ntc),' '); b_vlieuda:=NVL(trim(b_vlieuda),' ');
b_loai:=NVL(trim(b_loai),' '); b_vlieudo:=NVL(trim(b_vlieudo),' '); b_ngay_bd:=nvl(b_ngay_bd,0);
if b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
for b_lp in 1..4 loop
    if nvl(trim(a_nv(b_lp)),' ')='C' then
        if b_lp=1 then a_nv(b_lp):='V';
        elsif b_lp=2 then a_nv(b_lp):='T';
        elsif b_lp=3 then a_nv(b_lp):='D';
        elsif b_lp=4 then a_nv(b_lp):='N';
        end if;
        FBH_DTAU_BPHI_SO_ID('G',b_qmo,b_ntc,b_vlieuda,b_loai,b_vlieudo,b_hthuy,b_dtich,b_ttai,
           b_kcach,b_tgian,a_nv(b_lp),b_ngay_bd,b_so_id,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
        if b_so_id<>0 then
            PKH_GHEP(b_nv,a_nv(b_lp)); PKH_GHEP(b_so_idS,to_char(b_so_id));
        else
            b_nv:=a_nv(b_lp); b_so_idS:='0'; exit;
        end if;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_DTAU_BPHI_CTd(
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
insert into temp_1(c1,n1) select ma,min(bt) from bh_dtau_phi_dk where so_id=b_so_id and lh_bh<>'M' group by ma;
select JSON_ARRAYAGG(json_object(
    a.ma,ten,
    'tien' value case when b_nt_tien<>'VND' then round(tien/b_tygia,2) else tien end,
    'ptB' value case when b_nt_phi<>'VND' then decode(sign(pt-100),1,round(pt/b_tygia,4),pt) else pt end,
    'pt' value '',phi,cap,tc,ma_ct,ma_dk,kieu,lh_nv,t_suat,lkeM,lkeP,lkeB,luy,lh_bh,
    'nv' value b_nv,'ptk' value decode(sign(pt-100),1,'T','P'),'bt' value a.bt)
    order by a.bt returning clob) into cs_dk
    from bh_dtau_phi_dk a,temp_1 b where a.so_id=b_so_id and lh_bh<>'M' and b.n1=a.bt order by a.bt;

insert into temp_1(c1,n1) select ma,min(bt) from bh_dtau_phi_dk where so_id=b_so_id and lh_bh='M' group by ma;
select JSON_ARRAYAGG(json_object(
    a.ma,ten,
    'tien' value case when b_nt_tien<>'VND' then round(tien/b_tygia,2) else tien end,
    'ptB' value case when b_nt_phi<>'VND' then decode(sign(pt-100),1,round(pt/b_tygia,4),pt) else pt end,
    'pt' value '',phi,cap,tc,ma_ct,ma_dk,kieu,lh_nv,t_suat,lkeM,lkeP,lkeB,luy,lh_bh,
    'nv' value b_nv,'ptk' value decode(sign(pt-100),1,'T','P'),'bt' value a.bt)
    order by a.bt returning clob) into cs_dkbs
    from bh_dtau_phi_dk a,temp_1 b where a.so_id=b_so_id and lh_bh='M' and b.n1=a.bt order by a.bt;
select JSON_ARRAYAGG(json_object(ma_lt,ten) order by bt returning clob)
    into cs_lt from bh_dtau_phi_lt where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into cs_txt
    from bh_dtau_phi_txt where so_id=b_so_id and loai='dt_dk';
select count(*) into b_i1 from bh_dtau_phi_txt where so_id=b_so_id and loai='dt_khd';
if b_i1<>0 then
    select txt into dt_khd from bh_dtau_phi_txt where so_id=b_so_id and loai='dt_khd';
end if;
select count(*) into b_i1 from bh_dtau_phi_txt where so_id=b_so_id and loai='dt_kbt';
if b_i1<>0 then
    select txt into cs_kbt from bh_dtau_phi_txt where so_id=b_so_id and loai='dt_kbt';
end if;
select json_object('nv' value b_nv,'dt_khd' value dt_khd,'dt_kbt' value cs_kbt,'dt_lt' value cs_lt,
    'dt_dk' value cs_dk,'dt_dkbs' value cs_dkbs,'txt' value cs_txt returning clob) into b_oraOut from dual;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAUG_BPHId_THEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_i1 number;
    b_vu varchar2(10); b_nt_tien varchar2(5); b_nt_phi varchar2(5);
    b_qmo varchar2(10); b_ntc varchar2(10); b_vlieuda varchar2(10);
    b_loai varchar2(10); b_vlieudo varchar2(10); b_dtich number;
    b_ttai number; b_hthuy varchar2(10); b_tgian number; b_kcach number;
    b_ngay_bd number;
    b_so_id number;  b_so_idS varchar2(100); b_tygia number;
    a_nv pht_type.a_var; a_so_idN pht_type.a_num; a_nvN pht_type.a_var; b_nv varchar2(10):=''; cs_lke clob;
    b_dk_lt clob; a_ma_lt pht_type.a_var; a_ma_dk_lt pht_type.a_var; a_ten_lt pht_type.a_nvar; a_chon_lt pht_type.a_var;
begin
-- Dan - Tra so ID
delete from temp_1; delete from temp_2; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HOP','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_idS:='';
b_lenh:=FKH_JS_LENH('nvv,nvt,nvd,nvn,vu,nt_tien,nt_phi,tygia');
EXECUTE IMMEDIATE b_lenh into a_nv(1),a_nv(2),a_nv(3),a_nv(4),b_vu,b_nt_tien,b_nt_phi,b_tygia using b_oraIn;
b_lenh:=FKH_JS_LENH('qmo,ntc,vlieuda,loai,vlieudo,dtich,ttai,hthuy,tgian,kcach,ngay_bd');
EXECUTE IMMEDIATE b_lenh into b_qmo,b_ntc,b_vlieuda,b_loai,b_vlieudo,b_dtich,b_ttai,b_hthuy,b_tgian,
        b_kcach,b_ngay_bd using b_oraIn;
b_ttai:=nvl(b_ttai,0); b_dtich:=nvl(b_dtich,0); b_tgian:=nvl(b_tgian,0); b_kcach:=nvl(b_kcach,0);
b_qmo:=NVL(trim(b_qmo),' '); b_ntc:=NVL(trim(b_ntc),' '); b_vlieuda:=NVL(trim(b_vlieuda),' ');
b_loai:=NVL(trim(b_loai),' '); b_vlieudo:=NVL(trim(b_vlieudo),' '); b_ngay_bd:=nvl(b_ngay_bd,0);
if b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
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
  FBH_DTAU_BPHI_SO_ID('G',b_qmo,b_ntc,b_vlieuda,b_loai,b_vlieudo,b_hthuy,b_dtich,b_ttai,
           b_kcach,b_tgian,a_nv(b_lp),b_ngay_bd,b_so_id,b_loi);
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
        insert into temp_1(c1,n1,c2,n2) select a_nvN(b_lp),min(bt),ma,a_so_idN(b_lp) from bh_dtau_phi_dk where so_id=a_so_idN(b_lp) and lh_bh<>'M' group by ma;
    end loop;
    select JSON_ARRAYAGG(json_object(ma,ten,'tien' value case when b_nt_tien='VND' then tien else round(tien/b_tygia,2) end,
      'ptB' value case when b_nt_phi<>'VND' then decode(sign(pt-100),1,round(pt/b_tygia,2),pt) else pt end,
      'pt' value '',phi,cap,tc,ma_ct,ma_dk,kieu,lh_nv,t_suat,lkeM,lkeP,lkeB,luy,lh_bh,
      'nv' value b.c1,'ptk' value decode(sign(pt-100),1,'T','P'),'bt' value bt) order by b.c1,bt returning clob)
        into cs_lke from bh_dtau_phi_dk a,temp_1 b where a.so_id=b.n2 and a.bt=b.n1 and a.lh_bh<>'M' order by a.bt;
elsif b_vu='dkbs' then
    for b_lp in 1..a_so_idN.count loop
        insert into temp_1(n1) values (a_so_idN(b_lp));
    end loop;
    select JSON_ARRAYAGG(json_object('ma' value ma,ten,'tien' value case when b_nt_tien='VND' then tien else round(tien/b_tygia,2) end,
                'ptB' value case when b_nt_phi<>'VND' then decode(sign(pt-100),1,round(pt/b_tygia,4),pt) else pt end,
                pt,ma_ct,tc,phi,cap,lh_nv,lkeM,lkeP,'bt' value bt,'ptk' value decode(sign(pt-50),1,'T','P')) order by ma,ten returning clob) into cs_lke from
                (select ma,ten,tien,pt,ma_ct,ma_dk,kieu,tc,phi,cap,lh_nv,t_suat,lkeM,lkeP,bt
                        from bh_dtau_phi_dk where so_id in (select n1 from temp_1) and lh_bh='M' union
                select ma,ten,null tien,null pt,'' ma_ct,ma_dk,'' kieu,'T' tc,null phi,null cap,lh_nv,0 t_suat,'G' lkeM,'G' lkeP,999 bt from bh_ma_dkbs where FBH_MA_NV_CO(nv,'HOP')='C');
elsif b_vu='lt' then
    for b_lp in 1..a_so_idN.count loop
        select count(*) into b_i1 from bh_dtau_phi_txt where so_id=a_so_idN(b_lp) and loai='dt_lt';
        if b_i1 > 0 then
          select FKH_JS_BONH(txt) into b_dk_lt from bh_dtau_phi_txt where so_id=a_so_idN(b_lp) and loai='dt_lt';
          b_lenh:=FKH_JS_LENH('ma_lt,ma_dk,ten,chon');
          EXECUTE IMMEDIATE b_lenh bulk collect into a_ma_lt,a_ma_dk_lt,a_ten_lt,a_chon_lt using b_dk_lt;
          if a_ma_lt.count > 0 then
              for b_lp2 in 1..a_ma_lt.count loop
                  insert into temp_2(c1,c2,c3,c4) VALUES (a_ma_lt(b_lp2),a_ma_dk_lt(b_lp2),a_ten_lt(b_lp2),a_chon_lt(b_lp2));
              end loop;
          end if;
        end if;
    end loop;
    for r_lp in (select ma,ten,ma_dk from bh_ma_dklt where FBH_MA_NV_CO(nv,'HOP')='C') loop
        select count(*) into b_i1 from temp_2 where c1=r_lp.ma;
        if b_i1=0 then insert into temp_2(c1,c2,c3,c4) values(r_lp.ma,r_lp.ten,' ',r_lp.ma_dk); end if;
    end loop;
    select JSON_ARRAYAGG(json_object('ma_lt' value c1,'ten' value c2,'ma_dk' value c4)
        order by c1,c2 returning clob) into cs_lke from temp_2;
end if;
delete from temp_1; delete from temp_2; commit;
select json_object('so_ids' value b_so_idS,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_BPHI_DKp(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000);
    b_nv varchar2(10); b_so_id varchar2(100);
    b_tgT number:=1; b_tgP number:=1; b_i1 number; b_bt number;
    b_ma varchar2(10); b_tien number; b_pt number; b_phi number;
    b_qmo varchar2(10); b_ntc varchar2(10); b_vlieuda varchar2(10);
    b_loai varchar2(10); b_vlieudo varchar2(10); b_dtich number;
    b_ttai number; b_hthuy varchar2(10); b_tgian number; b_kcach number;
    b_ngay_bd number; b_ngay number:=PKH_NG_CSO(sysdate);
    b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Nam - Lay %phi theo khoang muc trach nhiem va cac ma phu thuoc
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HOP','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,ma,nt_tien,nt_phi,tien');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ma,b_nt_tien,b_nt_phi,b_tien using b_oraIn;
b_lenh:=FKH_JS_LENH('qmo,ntc,vlieuda,loai,vlieudo,dtich,ttai,hthuy,tgian,kcach,ngay_bd');
EXECUTE IMMEDIATE b_lenh into b_qmo,b_ntc,b_vlieuda,b_loai,b_vlieudo,b_dtich,b_ttai,b_hthuy,b_tgian,
        b_kcach,b_ngay_bd using b_oraIn;
b_ttai:=nvl(b_ttai,0); b_dtich:=nvl(b_dtich,0); b_tgian:=nvl(b_tgian,0); b_kcach:=nvl(b_kcach,0);
b_qmo:=NVL(trim(b_qmo),' '); b_ntc:=NVL(trim(b_ntc),' '); b_vlieuda:=NVL(trim(b_vlieuda),' ');
b_loai:=NVL(trim(b_loai),' '); b_vlieudo:=NVL(trim(b_vlieudo),' '); b_ngay_bd:=nvl(b_ngay_bd,0);
if b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_nt_tien<>'VND' then b_tgT:=FBH_TT_TRA_TGTT(b_ngay,b_nt_tien);end if;
if b_nt_phi<>'VND' then b_tgP:=FBH_TT_TRA_TGTT(b_ngay,b_nt_phi);end if;
FBH_DTAU_BPHI_SO_ID('G',b_qmo,b_ntc,b_vlieuda,b_loai,b_vlieudo,b_hthuy,b_dtich,b_ttai,
           b_kcach,b_tgian,b_nv,b_ngay_bd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
FBH_DTAU_BPHI_DKp(b_so_id,b_ma,b_tien,b_tgT,b_bt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
for r_lp in (select * from bh_dtau_phi_dk where so_id=b_so_id and bt>=b_bt order by bt) loop
    if b_i1<>0 and r_lp.ma=b_ma then exit; end if;
    b_pt:=r_lp.pt; b_phi:=r_lp.phi;
    if b_nt_phi<>'VND' then
        if b_pt>100 then b_pt:=round(b_pt/b_tgP,2); end if;
        b_phi:=round(b_phi/b_tgP,2);
    end if;
    insert into temp_1(c1,n1,n2,n3) values(r_lp.ma,b_pt,b_phi,r_lp.bt);
    b_i1:=1;
end loop;
select JSON_ARRAYAGG(json_object('ma' value c1,'ptb' value n1,'phi' value n2) order by n3 returning clob) into b_oraOut from temp_1;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_DTAU_BPHI_DKp(
    b_so_id number,b_ma varchar2,b_tien number,b_tgT number,b_bt out number,b_loi out varchar2)
AS
    b_i1 number; b_tienM number;
begin
-- Nam - Lay %phi theo khoang muc trach nhiem
b_loi:='loi:Loi xu ly FBH_DTAU_BPHI_DKm:loi';
select count(*),nvl(max(tien),0) into b_i1,b_tienM from bh_dtau_phi_dk where so_id=b_so_id and ma=b_ma and tien<=round(b_tien * b_tgT,2);
if b_i1=0 then b_loi:='loi:Khong tim duoc ty le phi theo muc trach nhiem:loi'; return; end if;
select nvl(min(bt),0) into b_bt from bh_dtau_phi_dk where so_id=b_so_id and ma=b_ma and tien=b_tienM;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
-- dong tau --
create or replace procedure PBH_DTAU_BPHI_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100);
    cs_qmo clob; cs_ntc clob; cs_vlieuda clob; cs_loai clob; cs_vlieudo clob;
    cs_hthuy clob; cs_lt clob; cs_khd clob; cs_kbt clob;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ten) into cs_qmo from bh_dtau_qmo where FBH_DTAU_QMO_HAN(ma)='C';
select JSON_ARRAYAGG(json_object(ma,ten) order by ten) into cs_ntc from bh_dtau_ntc where FBH_DTAU_NTC_HAN(ma)='C';
select JSON_ARRAYAGG(json_object(ma,ten) order by ma) into cs_vlieuda from bh_dtau_vlieuda where FBH_DTAU_VLIEUDA_HAN(ma)='C';
select JSON_ARRAYAGG(json_object(ma,ten) order by ten) into cs_loai from bh_dtau_loai where FBH_DTAU_LOAI_HAN(ma)='C';
select JSON_ARRAYAGG(json_object(ma,ten) order by ten) into cs_vlieudo from bh_dtau_vlieudo where FBH_DTAU_VLIEUDO_HAN(ma)='C';
select JSON_ARRAYAGG(json_object(ma,ten) order by ten) into cs_hthuy from bh_dtau_hthuy where FBH_DTAU_HTHUY_HAN(ma)='C';
select JSON_ARRAYAGG(json_object(ma_dk,ten,'ma_lt' value ma)) into cs_lt
    from bh_ma_dklt a where FBH_MA_NV_CO(nv,'HOP')='C' and FBH_MA_DKLT_HAN(ma_dk,ma)='C' and MA <> ' ';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_khd from bh_kh_ttt where ps='KHD' and nv='HOP';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_kbt from bh_kh_ttt where ps='KBT' and nv='HOP';
select json_object('cs_qmo' value cs_qmo,'cs_ntc' value cs_ntc,'cs_vlieuda' value cs_vlieuda,'cs_loai' value cs_loai,
    'cs_vlieudo' value cs_vlieudo,'cs_hthuy' value cs_hthuy,'cs_lt' value cs_lt,'cs_khd' value cs_khd,'cs_kbt' value cs_kbt) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_BPHI_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_i1 number; b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
  dt_dk clob; dt_dkbs clob:=''; dt_khd clob:=''; dt_kbt clob:=''; dt_ct clob; dt_lt clob:=''; dt_txt clob:='';
begin
-- Dan - Xem chi tiet theo so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HOP','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Bieu phi da xoa:loi';
select JSON_ARRAYAGG(json_object(so_id,nsd)) into dt_ct from bh_dtau_phi where so_id=b_so_id;
select txt into dt_dk from bh_dtau_phi_txt where so_id=b_so_id and loai='dt_dk';
select count(*) into b_i1 from bh_dtau_phi_txt where so_id=b_so_id and loai='dt_dkbs';
if b_i1<>0 then
    select txt into dt_dkbs from bh_dtau_phi_txt where so_id=b_so_id and loai='dt_dkbs';
end if;
select JSON_ARRAYAGG(json_object(ma_lt) order by bt) into dt_lt from bh_dtau_phi_lt where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt from bh_dtau_phi_txt where so_id=b_so_id and loai in('dt_ct','dt_lt');
select count(*) into b_i1 from bh_dtau_phi_txt where so_id=b_so_id and loai='dt_khd';
if b_i1<>0 then
    select txt into dt_khd from bh_dtau_phi_txt where so_id=b_so_id and loai='dt_khd';
end if;
select count(*) into b_i1 from bh_dtau_phi_txt where so_id=b_so_id and loai='dt_kbt';
if b_i1<>0 then
    select txt into dt_kbt from bh_dtau_phi_txt where so_id=b_so_id and loai='dt_kbt';
end if;
select json_object('so_id' value b_so_id,'dt_ct' value dt_ct,'dt_dk' value dt_dk,
  'dt_dkbs' value dt_dkbs,'dt_lt' value dt_lt,'dt_khd' value dt_khd,'dt_kbt' value dt_kbt ,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_BPHI_DKBS(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,'ma_dk' value ma,lh_nv) order by ma returning clob) into cs_lke
    from bh_ma_dkbs where FBH_MA_NV_CO(nv,'HOP')='C' order by ma;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_BPHI_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob; b_dong number; b_lenh varchar2(1000);
    b_tu number; b_den number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HOP','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tu,den');
EXECUTE IMMEDIATE b_lenh into b_tu,b_den using b_oraIn;
select count(*) into b_dong from bh_dtau_phi;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(so_id,
    'qmo' value FBH_DTAU_QMO_TEN(qmo),'loai' value FBH_DTAU_LOAI_TEN(loai),
    'ntc' value FBH_DTAU_NTC_TEN(ntc),'vlieuda' value FBH_DTAU_VLIEUDA_TEN(vlieuda),
    'vlieudo' value FBH_DTAU_VLIEUDO_TEN(vlieudo),'hthuy' value FBH_DTAU_HTHUY_TEN(hthuy),dtich,ttai,tgian,kcach,nv_bh,ngay_bd,ngay_kt) order by so_id returning clob) into cs_lke
    from (select so_id,qmo,loai,ntc,vlieuda,vlieudo,hthuy,dtich,ttai,tgian,kcach,nv_bh,ngay_bd,ngay_kt,rownum sott from bh_dtau_phi order by so_id)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_BPHI_TEST(
    b_dt_dk clob,b_dt_dkbs clob,b_dt_lt clob,
    dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,dk_tc out pht_type.a_var,dk_ma_ct out pht_type.a_var,
    dk_ma_dk out pht_type.a_var,dk_ma_dkC out pht_type.a_var,dk_kieu out pht_type.a_var,
    dk_tien out pht_type.a_num,dk_pt out pht_type.a_num,
    dk_phi out pht_type.a_num,dk_lkeM out pht_type.a_var,dk_lkeP out pht_type.a_var,dk_lkeB out pht_type.a_var,
    dk_luy out pht_type.a_var,dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,
    dk_lh_bh out pht_type.a_var,    
    lt_ma_dk out pht_type.a_var,lt_ma_lt out pht_type.a_var,lt_ten out pht_type.a_nvar,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_lenh varchar2(2000); b_ma_ct varchar2(10); b_kt number;
    b_ict1 number; b_ict2 number;
    
    dkB_ma pht_type.a_var; dkB_ten pht_type.a_nvar; dkB_tc pht_type.a_var;
    dkB_ma_ct pht_type.a_var; dkB_ma_dk pht_type.a_var; dkB_ma_dkC pht_type.a_var;
    dkB_ma_dkC pht_type.a_var; dkB_kieu pht_type.a_var; dkB_tien pht_type.a_num; dkB_pt pht_type.a_num;
    dkB_phi pht_type.a_num; dkB_lkeM pht_type.a_var; dkB_lkeP pht_type.a_var; dkB_lkeB pht_type.a_var;
    dkB_luy pht_type.a_var;
begin
b_loi:='loi:Loi xu ly PBH_TAU_BPHI_TEST:loi';
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,ma_dk,kieu,tien,pt,phi,lkem,lkep,lkeb,luy');
EXECUTE IMMEDIATE b_lenh bulk collect into
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_ma_dk,dk_kieu,dk_tien,dk_pt,dk_phi,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy using b_dt_dk;
b_kt:=dk_ma.count;
if b_kt=0 then b_loi:='loi:Nhap dieu khoan:loi'; raise PROGRAM_ERROR; end if;
for b_lp in 1..b_kt loop dk_lh_bh(b_lp):='C'; end loop;
if trim(b_dt_dkbs) is not null then
    EXECUTE IMMEDIATE b_lenh bulk collect into
        dkB_ma,dkB_ten,dkB_tc,dkB_ma_ct,dkB_ma_dk,dkB_kieu,dkB_tien,dkB_pt,dkB_phi,dkB_lkeM,dkB_lkeP,dkB_lkeB,dkB_luy using b_dt_dkbs;
    for b_lp in 1..dkB_ma.count loop
        b_kt:=b_kt+1; dk_lh_bh(b_kt):='M';
        dk_ma(b_kt):=dkB_ma(b_lp); dk_ten(b_kt):=dkB_ten(b_lp); dk_tc(b_kt):=dkB_tc(b_lp);
        dk_ma_ct(b_kt):=dkB_ma_ct(b_lp); dk_ma_dk(b_kt):=dkB_ma_dk(b_lp); dk_kieu(b_kt):=dkB_kieu(b_lp);
        dk_tien(b_kt):=dkB_tien(b_lp); dk_pt(b_kt):=dkB_pt(b_lp); dk_phi(b_kt):=dkB_phi(b_lp);
        dk_lkeM(b_kt):=dkB_lkeM(b_lp); dk_lkeP(b_kt):=dkB_lkeP(b_lp);
        dk_lkeB(b_kt):=dkB_lkeB(b_lp); dk_luy(b_kt):=dkB_luy(b_lp);
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
create or replace procedure PBH_DTAU_BPHI_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000);
    b_so_id number;
    b_qmo varchar2(10); b_ntc varchar2(10); b_vlieuda varchar2(10);
    b_loai varchar2(10); b_vlieudo varchar2(10); b_dtich number;
    b_ttai number; b_hthuy varchar2(10); b_tgian number; b_kcach number; b_nv_bh varchar2(1);
    b_ngay_bd number; b_ngay_kt number;

    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var; dk_ma_ct pht_type.a_var;
    dk_ma_dk pht_type.a_var; dk_ma_dkC pht_type.a_var; dk_kieu pht_type.a_var; dk_tien pht_type.a_num; dk_pt pht_type.a_num;
    dk_phi pht_type.a_num; dk_lkeM pht_type.a_var; dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var;
    dk_luy pht_type.a_var; dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num; dk_lh_bh pht_type.a_var;
    lt_ma_dk pht_type.a_var; lt_ma_lt pht_type.a_var; lt_ten pht_type.a_nvar;
    b_dt_ct clob; b_dt_dk clob; b_dt_dkbs clob; b_dt_lt clob; b_dt_khd clob; b_dt_kbt clob;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HOP','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_dkbs,dt_lt,dt_khd,dt_kbt');
EXECUTE IMMEDIATE b_lenh into b_dt_ct,b_dt_dk,b_dt_dkbs,b_dt_lt,b_dt_khd,b_dt_kbt using b_oraIn;
FKH_JS_NULL(b_dt_ct); FKH_JSa_NULL(b_dt_dk); FKH_JSa_NULL(b_dt_dkbs); 
FKH_JSa_NULL(b_dt_lt); FKH_JSa_NULL(b_dt_khd); FKH_JSa_NULL(b_dt_kbt);
b_lenh:=FKH_JS_LENH('qmo,ntc,vlieuda,loai,vlieudo,dtich,ttai,hthuy,tgian,kcach,nv_bh,ngay_bd,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_qmo,b_ntc,b_vlieuda,b_loai,b_vlieudo,b_dtich,b_ttai,b_hthuy,b_tgian,
        b_kcach,b_nv_bh,b_ngay_bd,b_ngay_kt using b_dt_ct;
if b_qmo<>' ' and FBH_DTAU_QMO_HAN(b_qmo)<>'C' then
    b_loi:='loi:Quy mo da het su dung:loi'; raise PROGRAM_ERROR;
end if;
if b_ntc<>' ' and FBH_DTAU_NTC_HAN(b_ntc)<>'C' then
    b_loi:='loi:Noi thi cong da het su dung:loi'; raise PROGRAM_ERROR;
end if;
if b_vlieuda<>' ' and FBH_DTAU_VLIEUDA_HAN(b_vlieuda)<>'C' then
    b_loi:='loi:Ma vat lieu dan do da het su dung:loi'; raise PROGRAM_ERROR;
end if;
if b_vlieudo<>' ' and FBH_DTAU_VLIEUDO_HAN(b_vlieudo)<>'C' then
    b_loi:='loi:Ma vat lieu dong tau da het su dung:loi'; raise PROGRAM_ERROR;
end if;
if b_loai<>' ' and FBH_DTAU_LOAI_HAN(b_loai)<>'C' then
    b_loi:='loi:Ma loai tau da het su dung:loi'; raise PROGRAM_ERROR;
end if;
if b_loai<>' ' and FBH_DTAU_LOAI_HAN(b_loai)<>'C' then
    b_loi:='loi:Ma loai tau da het su dung:loi'; raise PROGRAM_ERROR;
end if;
if b_nv_bh not in('V','T','D','N','M') then
    b_loi:='loi:Sai loai BH:loi'; raise PROGRAM_ERROR;
end if;
if b_ngay_bd is null or b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
if b_ngay_kt is null or b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
PKH_JS_THAYn(b_dt_ct,'ngay_bd',b_ngay_bd);
PBH_DTAU_BPHI_TEST(b_dt_dk,b_dt_dkbs,b_dt_lt,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_ma_dk,dk_ma_dkC,dk_kieu,
    dk_tien,dk_pt,dk_phi,dk_lkeM,dk_lkeP,dk_lkeB,
    dk_luy,dk_lh_nv,dk_t_suat,dk_lh_bh,lt_ma_dk,lt_ma_lt,lt_ten,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
if dk_ma.count=0 then b_loi:='loi:Nhap dieu khoan:loi'; raise PROGRAM_ERROR; end if;
FBH_DTAU_BPHI_SO_ID('G',b_qmo,b_ntc,b_vlieuda,b_loai,b_vlieudo,b_hthuy,b_dtich,b_ttai,b_kcach,b_tgian,b_nv_bh,b_ngay_bd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id<>0 then
    PBH_DTAU_BPHI_XOA_XOA(b_ma_dvi,b_so_id,b_loi);
else
    PHT_ID_MOI(b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table bh_dtau_phi:loi';
insert into bh_dtau_phi values(b_ma_dvi,b_so_id,'G',b_qmo,b_ntc,b_vlieuda,b_loai,b_vlieudo,
       b_hthuy,b_dtich,b_ttai,b_kcach,b_tgian,b_nv_bh,b_ngay_bd,b_ngay_kt,b_nsd);
for b_lp in 1..dk_ma.count loop
    insert into bh_dtau_phi_dk values(b_ma_dvi,b_so_id,b_lp,dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),
        dk_kieu(b_lp),dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),dk_lkeP(b_lp),dk_lkeM(b_lp),dk_lkeB(b_lp),dk_luy(b_lp),
        dk_ma_dk(b_lp),dk_lh_nv(b_lp),dk_t_suat(b_lp),0,dk_lh_bh(b_lp));
end loop;
for r_lp in(select ma,ma_ct,so_id,bt,level from
    (select t.so_id,t.bt,t.ma,t.ma_ct from bh_dtau_phi_dk t where t.so_id = b_so_id) t start with t.ma_ct=' ' CONNECT BY prior t.ma=t.ma_ct) loop
    update bh_dtau_phi_dk set cap=r_lp.level where so_id=b_so_id and bt=r_lp.bt;
end loop;
insert into bh_dtau_phi_txt values(b_ma_dvi,b_so_id,'dt_ct',b_dt_ct);
insert into bh_dtau_phi_txt values(b_ma_dvi,b_so_id,'dt_dk',b_dt_dk);
if lt_ma_lt.count<>0 then
    for b_lp in 1..lt_ma_lt.count loop
        insert into bh_dtau_phi_lt values(b_ma_dvi,b_so_id,b_lp,lt_ma_lt(b_lp),lt_ma_dk(b_lp),lt_ten(b_lp));
    end loop;
    insert into bh_dtau_phi_txt values(b_ma_dvi,b_so_id,'dt_lt',b_dt_lt);
end if;
if trim(b_dt_khd) is not null then
    insert into bh_dtau_phi_txt values(b_ma_dvi,b_so_id,'dt_khd',b_dt_khd);
end if;
if trim(b_dt_kbt) is not null then
    insert into bh_dtau_phi_txt values(b_ma_dvi,b_so_id,'dt_kbt',b_dt_kbt);
end if;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_BPHI_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Nam - Xoa bieu phi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HOP','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then b_loi:='loi:Chon bieu phi can xoa:loi'; raise PROGRAM_ERROR; end if;
PBH_DTAU_BPHI_XOA_XOA(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAU_BPHI_XOA_XOA(
    b_ma_dvi varchar2,b_so_id number, b_loi out varchar2)
AS 
begin
-- Nam - Xoa bieu phi
b_loi:='loi:Loi xoa phi:loi';
delete bh_dtau_phi_txt where so_id=b_so_id;
delete bh_dtau_phi_lt where so_id=b_so_id;
delete bh_dtau_phi_dk where so_id=b_so_id;
delete bh_dtau_phi where so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;




