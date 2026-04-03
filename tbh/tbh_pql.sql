create or replace function FTBH_MA_RR_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from tbh_ma_rr where ma=b_ma;
return b_kq;
end;
/
create or replace function FTBH_MA_RR_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from tbh_ma_rr where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PTBH_MA_RR_LKE(
     b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000);
    b_dong number; cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from tbh_ma_rr;
select JSON_ARRAYAGG(json_object(ma,ten) returning clob) into cs_lke from tbh_ma_rr order by ma;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_MA_RR_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100);
begin
-- Dan
PTBH_MA_RR_LKE(b_ma_dvi,b_nsd,b_pas,b_oraIn,b_oraOut);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_MA_RR_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_ct clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten) into cs_ct from tbh_ma_rr where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_MA_RR_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_ngay_kt using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete tbh_ma_rr where ma=b_ma;
insert into tbh_ma_rr values(b_ma,b_ten,b_nsd);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_MA_RR_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete tbh_ma_rr where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** PHUONG THUC TAI ***/
create or replace FUNCTION FTBH_MA_PTHUC_TEN (b_ma varchar2) return nvarchar2
AS
	b_kq nvarchar2(200);
begin
-- Dan - Liet ke
select min(ten) into b_kq from tbh_ma_pthuc where ma=b_ma;
return b_kq;
end;
/
create or replace function FTBH_MA_PTHUC_PP(b_pthuc varchar2) return varchar2
AS
	b_kq varchar2(1);
begin
-- Dan - Tra pp tinh
select min(pp) into b_kq from tbh_ma_pthuc where ma=b_pthuc;
return b_kq;
end;
/
create or replace procedure PTBH_MA_PTHUC_ARR(a_pthuc out pht_type.a_var,a_pp out pht_type.a_var)
AS
begin
-- Dan - Tra mang phuong thuc
select ma,pp BULK COLLECT into a_pthuc,a_pp from tbh_ma_pthuc order by bt;
end;
/
create or replace procedure PTBH_MA_PTHUC_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob:='';
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by bt returning clob) into b_oraOut from tbh_ma_pthuc;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_MA_PTHUC_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(*) order by bt returning clob) into b_oraOut from tbh_ma_pthuc;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_MA_PTHUC_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    a_ma pht_type.a_var; a_ten pht_type.a_nvar; a_pp pht_type.a_var;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,pp');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma,a_ten,a_pp using b_oraIn;
for b_lp in 1..a_ma.count loop
    if trim(a_ma(b_lp)) is null or trim(a_ten(b_lp)) is null then
        b_loi:='loi:Phai nhap ma, ten:loi'; raise PROGRAM_ERROR;
    end if;
    if a_pp(b_lp) is null or a_pp(b_lp) not in ('Q','S') then
        b_loi:='loi:Sai phuong phap tinh:loi'; raise PROGRAM_ERROR;
    end if;
end loop;
b_loi:='loi:Va cham NSD:loi';
delete tbh_ma_pthuc;
for b_lp in 1..a_ma.count loop
    insert into tbh_ma_pthuc values(b_ma_dvi,a_ma(b_lp),a_ten(b_lp),a_pp(b_lp),b_lp,b_nsd);
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_PBO_NOP(
    b_lh_nv varchar2,b_nha_bh varchar2,b_ng_tai number,b_phi number,
    b_tp number,b_tsuat out number,b_thue out number,b_loi out varchar2,b_dk varchar2:='T')
AS
    b_k_nop varchar2(1); b_k_thau varchar2(1);
    b_nop number:=0; b_thau number:=0;
begin
-- Dan - Tinh tien nop
b_loi:='loi:Loi xu ly PTBH_PBO_NOP:loi';
PBH_MA_NBH_THUE(b_nha_bh,b_k_nop,b_k_thau);
PBH_MA_LHNV_NOP(b_lh_nv,b_nop,b_thau,b_dk);
b_tsuat:=0;
if b_k_nop='C' then b_tsuat:=b_tsuat+b_nop; end if;
if b_k_thau='C' then b_tsuat:=b_tsuat+b_thau; end if;
b_thue:=round(b_phi*b_tsuat/100,b_tp);
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function FTBH_MA_DT
    (b_ma_dvi varchar2,b_ngay_ht number,a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num,a_so_id_dt pht_type.a_num) return varchar2
AS
    b_ma_dt varchar2(30); b_so_id number; b_so_id_bs number;
begin
for b_lp in 1..a_ma_dvi.count loop
    b_ma_dt:=FBH_HD_MA_DT(a_ma_dvi(b_lp),a_so_id(b_lp),a_so_id_dt(b_lp),b_ngay_ht);
    if trim(b_ma_dt) is not null then return b_ma_dt; end if;
end loop;
return ' ';
end;
/