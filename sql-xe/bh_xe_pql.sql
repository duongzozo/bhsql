-- Ma nguyen nhan ton that
create or replace function FBH_XE_NNTT_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_xe_nntt where ma=b_ma and tc='C';
return b_kq;
end;
/
create or replace function FBH_XE_NNTT_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_xe_nntt where ma=b_ma and tc='C';
return b_kq;
end;
/
create or replace function FBH_XE_NNTT_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_xe_nntt where ma=b_ma and tc='C' and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_XE_NNTT_XEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngay number:=PKH_NG_CSO(sysdate); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma) into cs_lke from bh_xe_nntt a where tc='C' and ngay_kt>b_ngay;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_NNTT_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_xe_nntt;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep)) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_xe_nntt order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_xe_nntt where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma)) into cs_lke from
        (select a.*,rownum sott from bh_xe_nntt a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_NNTT_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_xe_nntt;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_xe_nntt order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_xe_nntt order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep)) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_xe_nntt order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_xe_nntt where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_xe_nntt where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma)) into cs_lke from
        (select a.*,rownum sott from bh_xe_nntt a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_NNTT_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma'); cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma chua nhap hoac da xoa:loi';
select json_object(ma,txt) into cs_ct from bh_xe_nntt  where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_NNTT_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_tc varchar2(1);
    b_ma_ct varchar2(10); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
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
    select 0 into b_i1 from bh_xe_nntt where ma=b_ma_ct and tc='T';
end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_xe_nntt where ma=b_ma;
insert into bh_xe_nntt values(b_ma_dvi,b_ma,b_ten,b_tc,b_ma_ct,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_NNTT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_xe_nntt where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_xe_nntt where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** Loai xe ***/
create or replace function FBH_XE_LOAI_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_xe_loai where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_XE_LOAI_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_xe_loai where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_XE_LOAI_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_xe_loai where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_XE_LOAI_LKE(
     b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_xe_loai;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,ROW_NUMBER() over (order by ma) as sott from
            (select * from bh_xe_loai order by ma))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_xe_loai where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,ROW_NUMBER() over (order by ma) as sott from
            (select ma,ten,json_object(a.*,'xep' value ma) obj from bh_xe_loai a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_LOAI_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_xe_loai;
select nvl(min(sott),0) into b_tu from (select ma,ROW_NUMBER() over (order by ma) as sott from bh_xe_loai order by ma) where ma>=b_ma;
PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
    (select ma,ten,nsd,ROW_NUMBER() over (order by ma) as sott from bh_xe_loai order by ma)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_LOAI_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_ct clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,ngay_kt) into cs_ct from bh_xe_loai where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_LOAI_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_ngay_kt using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_xe_loai where ma=b_ma;
insert into bh_xe_loai values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_LOAI_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_xe_loai where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* Ma nhom xe */
create or replace function FBH_XE_NHOM_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_xe_nhom where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_XE_NHOM_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_xe_nhom where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_XE_NHOM_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_xe_nhom where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_XE_NHOM_LKE(
     b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_xe_nhom;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select * from bh_xe_nhom order by ma))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_xe_nhom where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(a.*,'xep' value ma) obj from bh_xe_nhom a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_NHOM_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_xe_nhom;
select nvl(min(sott),0) into b_tu from (select ma,ROW_NUMBER() over (order by ma) sott from bh_xe_nhom order by ma) where ma>=b_ma;
PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
    (select ma,ten,nsd,ROW_NUMBER() over (order by ma) sott from bh_xe_nhom order by ma)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_NHOM_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_ct clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,ngay_kt) into cs_ct from bh_xe_nhom where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_NHOM_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_ngay_kt using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_xe_nhom where ma=b_ma;
insert into bh_xe_nhom values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_NHOM_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_xe_nhom where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* Ma dong xe */
create or replace function FBH_XE_DONG_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_xe_dong where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_XE_DONG_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_xe_dong where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_XE_DONG_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_xe_dong where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_XE_DONG_LKE(
     b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_xe_dong;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from (select * from bh_xe_dong order by ma))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_xe_dong where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(a.*,'xep' value ma) obj from bh_xe_dong a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_DONG_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_xe_dong;
select nvl(min(sott),0) into b_tu from (select ma,rownum sott from bh_xe_dong order by ma) where ma>=b_ma;
PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
    (select ma,ten,nsd,rownum sott from bh_xe_dong order by ma)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_DONG_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_ct clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,ngay_kt) into cs_ct from bh_xe_dong where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_DONG_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_ngay_kt using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_xe_dong where ma=b_ma;
insert into bh_xe_dong values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_DONG_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_xe_dong where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* Hang */
create or replace function FBH_XE_HANG_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_xe_hang where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_XE_HANG_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_xe_hang where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_XE_HANG_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_xe_hang where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_XE_HANG_HAN_LISTt(b_nv varchar2,b_nhom varchar2,b_lay_all varchar2)
AS
    b_ngay number:=PKH_NG_CSO(sysdate);
begin
  -- viet anh -- hang het han
insert into temp_1(c1,c2,c3)
  select '1',ma,ten from bh_xe_hang where FBH_XE_HANG_HAN(ma)='C';
end;
/
create or replace procedure PBH_XE_HANG_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_xe_hang;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,ROW_NUMBER() over (order by ma) as sott from
            (select * from bh_xe_hang order by ma))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_xe_hang where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,ROW_NUMBER() over (order by ma) as sott from
            (select ten,ma,json_object(a.*,'xep' value ma) obj from bh_xe_hang a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_HANG_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(20); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin       
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,hangkt');                  
EXECUTE IMMEDIATE b_lenh into b_ma,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_xe_hang;
select nvl(min(sott),0) into b_tu from (select ma,ROW_NUMBER() over(ORDER BY ma) as sott from bh_xe_hang order by ma) where ma>=b_ma;
PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
    (select ma,ten,nsd,ROW_NUMBER() over(ORDER BY ma) as sott from bh_xe_hang order by ma)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_HANG_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_ct clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,ngay_kt) into cs_ct from bh_xe_hang where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_HANG_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(20); b_ten nvarchar2(500); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_ngay_kt using b_oraIn;
if trim(b_ma||b_ten) is null then b_loi:='loi:Nhap ma, ten:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
delete bh_xe_hang where ma=b_ma;
insert into bh_xe_hang values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_HANG_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_xe_hang where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* Hieu xe */
create or replace function FBH_XE_HIEU_HAN(b_hang varchar2,b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_xe_hieu where hang=b_hang and ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_XE_HIEU_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- viet anh
select min(ten) into b_kq from bh_xe_hieu where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_XE_HIEU_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- viet anh
select min(ma||'|'||ten) into b_kq from bh_xe_hieu where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_XE_HIEU_HANG(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_hang varchar2(20); cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_hang:=trim(b_oraIn);
if b_hang is not null then
    select JSON_ARRAYAGG(json_object(ma,ten) order by ten returning clob) into cs_lke from bh_xe_hieu where hang=b_hang;
end if;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_HIEU_HANG_LIST(b_hang varchar2,b_loi out varchar2)
AS
begin
-- viet anh
b_loi:='loi:Loi xu ly PBH_XE_HIEU_HANG_LIST:loi';
insert into bh_kh_hoi_temp1 select ma,ten from bh_xe_hieu where hang=PKH_MA_TENl(b_hang) 
       and FBH_XE_HIEU_HAN(PKH_MA_TENl(b_hang),ma)='C' order by ten;
b_loi:='';
exception when others then null;
end;
/
create or replace procedure PBH_XE_HIEU_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob;
begin
-- viet anh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_xe_hieu;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(ten,'ten_hang' value FBH_XE_HANG_TEN(hang),hang,ma) 
                obj,row_number() over (order by FBH_XE_HANG_TEN(hang),ten) sott from
            (select ten,hang,ma from bh_xe_hieu order by FBH_XE_HANG_TEN(hang),ten))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_xe_hieu where FKH_BO_UNICODE(ten,'C','C') like FKH_BO_UNICODE(b_tim,'C','C');
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(ten,'ten_hang' value FBH_XE_HANG_TEN(hang),hang,ma) 
                obj,row_number() over (order by hang,ten) sott from
            (select ten,hang,ma,json_object(a.*,'xep' value ma) obj from bh_xe_hieu a)
            where FKH_BO_UNICODE(ten,'C','C') like FKH_BO_UNICODE(b_tim,'C','C') order by FBH_XE_HANG_TEN(hang),ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_HIEU_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_hang varchar2(10); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- viet anh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,hang,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_hang,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_xe_hieu;
select nvl(min(sott),0) into b_tu from
  (select ma,hang,ten,ROW_NUMBER() over(order by ma) as sott from bh_xe_hieu)
          where hang>=b_hang and ma>=b_ma;
PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(ten,'ten_hang' value FBH_XE_HANG_TEN(hang),hang,ma,nsd) returning clob) into cs_lke from
    (select ten,hang,ma,nsd,ROW_NUMBER() over(order by ma) as sott from bh_xe_hieu)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_HIEU_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_hang varchar2(20); b_ma varchar2(20); cs_ct clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('hang,ma');
EXECUTE IMMEDIATE b_lenh into b_hang,b_ma using b_oraIn;
select count(*) into b_i1 from bh_xe_hieu where hang=b_hang and ma=b_ma;
if b_i1<>0 then
    select json_object(ten,ma,'hang' value FBH_XE_HANG_TENl(hang),ngay_kt) into cs_ct from bh_xe_hieu where hang=b_hang and ma=b_ma;
end if;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_HIEU_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000);
    b_ma varchar2(20); b_hang varchar2(20); b_ngay_kt number;
    b_ten nvarchar2(500);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('hang,ma,ten,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_hang,b_ma,b_ten,b_ngay_kt using b_oraIn;
b_hang:=trim(b_hang); b_ma:=trim(b_ma);
if b_hang is null or b_ma is null then b_loi:='loi:Nhap hang, hieu:loi'; raise PROGRAM_ERROR; end if;
if FBH_XE_HANG_HAN(b_hang)<>'C' then b_loi:='loi:Ma hang '||b_hang||' da xoa:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
delete bh_xe_hieu where hang=b_hang and ma=b_ma;
insert into bh_xe_hieu values(b_ma_dvi,b_hang,b_ma,b_ten,b_ngay_kt,b_nsd);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_HIEU_XOA(
  b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma varchar2(10); b_hang varchar2(10); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('hang,ma,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_hang,b_ma,b_ngay_kt using b_oraIn;
b_hang:=trim(b_hang); b_ma:=trim(b_ma);
if b_hang is null or b_ma is null then b_loi:='loi:Nhap hang, hieu:loi'; raise PROGRAM_ERROR; end if;
delete bh_xe_hieu where hang=b_hang and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* Phien ban */
create or replace function FBH_XE_PB_HAN(b_hang varchar2,b_hieu varchar2,b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_xe_pb where hang=b_hang and hieu=b_hieu and ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_XE_PB_TEN(b_hang varchar2,b_hieu varchar2,b_ma varchar2) return nvarchar2
AS
    b_kq varchar2(500);
begin
-- Dan - Kiem tra con hieu luc
select min(ten) into b_kq from bh_xe_pb where hang=b_hang and hieu=b_hieu and ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_XE_PB_TENl(b_hang varchar2,b_hieu varchar2,b_ma varchar2) return nvarchar2
AS
    b_kq varchar2(500);
begin
-- Dan - Kiem tra con hieu luc
select min(ma||'|'||ten) into b_kq from bh_xe_pb where hang=b_hang and hieu=b_hieu and ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_XE_PB_HANG(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_hang varchar2(20); b_hieu varchar2(20); cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('hang,hieu');
EXECUTE IMMEDIATE b_lenh into b_hang,b_hieu using b_oraIn;
if b_hang is not null and b_hieu is not null then
    select JSON_ARRAYAGG(json_object(ma,'ten' value ten) order by ma) into cs_lke from bh_xe_pb where hang=b_hang and hieu=b_hieu;
end if;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_PBAN_HIEU_LIST(b_tso varchar2,b_loi out varchar2)
AS
     b_lenh varchar2(1000); b_hang varchar2(20); b_hieu varchar2(20);
begin
-- viet anh -- phan trang pb
b_loi:='loi:Loi xu ly PBH_XE_PBAN_HIEU_LIST:loi';
b_lenh:=FKH_JS_LENHc('hang,hieu');
EXECUTE IMMEDIATE b_lenh into b_hang,b_hieu using b_tso;
if b_hang is not null and b_hieu is not null then
    insert into bh_kh_hoi_temp1 select ma,ten from bh_xe_pb where FBH_XE_PB_HAN(b_hang,b_hieu,ma)='C' 
           and hang=b_hang and hieu=b_hieu order by ten;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_PB_TSO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(2000); cs_lke clob:='';
    b_hang varchar2(20); b_hieu varchar2(20); b_ma varchar2(20);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,hang,hieu');
EXECUTE IMMEDIATE b_lenh into b_ma,b_hang,b_hieu using b_oraIn;
if b_hang is null or b_hieu is null or b_ma is null then
    b_loi:='loi:Nhap hang, hieu, phien ban:loi'; raise PROGRAM_ERROR;
end if;
select count(*) into b_i1 from bh_xe_pb where hang=b_hang and hieu=b_hieu and ma=b_ma;
if b_i1<>0 then
    select json_object(ttai,so_cn,csuat,dco,
        'dong' value FBH_XE_DONG_TENl(dong),'loai_xe' value FBH_XE_LOAI_TENl(loai_xe)) into cs_lke
        from bh_xe_pb where hang=b_hang and hieu=b_hieu and ma=b_ma;
end if;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_PB_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob;
begin
-- viet anh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_xe_pb;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object('ten_hang' value FBH_XE_HANG_TEN(hang),'ten_hieu' value FBH_XE_HIEU_TEN(hieu),ten,hang,hieu,ma) 
                obj,row_number() over (order by FBH_XE_HANG_TEN(hang), FBH_XE_HIEU_TEN(hieu)) sott from
            (select ten,hang,hieu,ma from bh_xe_pb order by FBH_XE_HANG_TEN(hang),FBH_XE_HIEU_TEN(hieu),ten))
        where sott between b_tu and b_den;
else
    b_tim:=FKH_BO_UNICODE(b_tim,'C','C');
    select count(*) into b_dong from bh_xe_pb where FKH_BO_UNICODE(FBH_XE_HANG_TEN(hang),'C','C') like b_tim 
                  or FKH_BO_UNICODE(FBH_XE_HIEU_TEN(hieu),'C','C') like b_tim 
                  or FKH_BO_UNICODE(ten,'C','C') like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object('ten_hang' value FBH_XE_HANG_TEN(hang),'ten_hieu' value FBH_XE_HIEU_TEN(hieu),ten,hang,hieu,ma) 
                obj,row_number() over (order by FBH_XE_HANG_TEN(hang), FBH_XE_HIEU_TEN(hieu)) sott from
            (select hang,hieu,ma,ten,json_object(a.*,'xep' value ma) obj from bh_xe_pb a)
            where FKH_BO_UNICODE(FBH_XE_HANG_TEN(hang),'C','C') like b_tim 
                  or FKH_BO_UNICODE(FBH_XE_HIEU_TEN(hieu),'C','C') like b_tim 
                  or FKH_BO_UNICODE(ten,'C','C') like b_tim 
              order by FBH_XE_HANG_TEN(hang),FBH_XE_HIEU_TEN(hieu),ten)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_PB_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_tu number; b_den number; b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
    b_ma varchar2(20); b_hang varchar2(20); b_hieu varchar2(20);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('hang,hieu,ma,hangkt');
EXECUTE IMMEDIATE b_lenh into b_hang,b_hieu,b_ma,b_hangkt using b_oraIn;
if b_hang is null or b_hieu is null or b_ma is null then
  b_loi:='loi:Nhap hang, hieu, phien ban:loi'; raise PROGRAM_ERROR; 
end if;
select count(*) into b_dong from bh_xe_pb;
select nvl(min(sott),0) into b_tu from
  (select hang,hieu,ma,ROW_NUMBER() over(order by ma) as sott from bh_xe_pb)
  where hang>=b_hang and hieu>=b_hieu and ma>=b_ma;
PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object('ten_hang' value FBH_XE_HANG_TEN(hang),'ten_hieu' value FBH_XE_HIEU_TEN(hieu),ten,hang,hieu,ma) 
       returning clob) into cs_lke from
    (select hang,hieu,ma,ten,ROW_NUMBER() over(order by ma) as sott from bh_xe_pb)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_PB_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(2000); cs_ct clob:='';
    b_hang varchar2(20); b_hieu varchar2(20); b_ma varchar2(20);
begin
-- viet anh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,hang,hieu');
EXECUTE IMMEDIATE b_lenh into b_ma,b_hang,b_hieu using b_oraIn;
if b_hang is null or b_hieu is null or b_ma is null then
    b_loi:='loi:Nhap hang, hieu, phien ban:loi'; raise PROGRAM_ERROR; 
end if;
select count(*) into b_i1 from bh_xe_pb where hang=b_hang and hieu=b_hieu and ma=b_ma;
if b_i1<>0 then
    select json_object(ma,ten,ttai,so_cn,csuat,dco,ngay_kt,
        'hang' value FBH_XE_HANG_TENl(hang),'hieu' value FBH_XE_HIEU_TENl(hieu),
        'loai_xe' value FBH_XE_LOAI_TENl(loai_xe),'dong' value FBH_XE_DONG_TENl(dong)) into cs_ct
        from bh_xe_pb where hang=b_hang and hieu=b_hieu and ma=b_ma;
end if;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_PB_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma varchar2(20); b_ten nvarchar2(500);
    b_hang varchar2(20); b_hieu varchar2(20); b_dong varchar2(20); b_loai_xe varchar2(10);
    b_ttai number; b_so_cn number; b_csuat number; b_dco varchar2(20); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,hang,hieu,loai_xe,dong,ttai,so_cn,csuat,dco,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_hang,b_hieu,b_loai_xe,b_dong,b_ttai,b_so_cn,b_csuat,b_dco,b_ngay_kt using b_oraIn;
b_hang:=trim(b_hang); b_hieu:=trim(b_hieu); b_ma:=trim(b_ma);
b_loai_xe:=trim(b_loai_xe); b_dong:=nvl(trim(b_dong),' ');
if b_hang is null or b_hieu is null or b_ma is null then
    b_loi:='loi:Nhap hang, hieu, phien ban:loi'; raise PROGRAM_ERROR; 
end if;
if FBH_XE_HANG_HAN(b_hang)<>'C' then b_loi:='loi:Sai hang:loi'; raise PROGRAM_ERROR; end if;
if FBH_XE_HIEU_HAN(b_hang,b_hieu)<>'C' then b_loi:='loi:Sai hieu:loi'; raise PROGRAM_ERROR; end if;
-- viet anh xoa chan dco, loai xe
if b_dong!=' ' and FBH_XE_DONG_HAN(b_dong)<>'C' then b_loi:='loi:Sai dong:loi'; raise PROGRAM_ERROR; end if;
b_ttai:=nvl(b_ttai,0); b_so_cn:=nvl(b_so_cn,0); b_csuat:=nvl(b_csuat,0);
if b_ngay_kt is null or b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
delete bh_xe_pb where hang=b_hang and hieu=b_hieu and ma=b_ma;
insert into bh_xe_pb values(b_ma_dvi,b_hang,b_hieu,b_ma,b_ten,b_loai_xe,b_dong,b_ttai,b_so_cn,b_csuat,b_dco,b_ngay_kt,b_nsd);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;

/
--duchq import dia o man xe phien ban
create or replace procedure PBH_XE_PB_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_hang varchar2(20); b_hieu varchar2(20); b_ma varchar2(20);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,hang,hieu');
EXECUTE IMMEDIATE b_lenh into b_ma,b_hang,b_hieu using b_oraIn;
if b_hang is null or b_hieu is null or b_ma is null then
  b_loi:='loi:Nhap hang, hieu, phien ban:loi'; raise PROGRAM_ERROR; 
end if;
delete bh_xe_pb where hang=b_hang and hieu=b_hieu and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* Gia tham khao */
create or replace function FBH_XE_GTK_GIA(
  b_hang varchar2,b_hieu varchar2,b_pban varchar2,b_nam_sx number) return number
AS
    b_kq number:=0; b_i1 number;
begin
-- Dan - Kiem tra con hieu luc
select max(nam_sx) into b_i1 from bh_xe_gtk where hang=b_hang and hieu=b_hieu and pban=b_pban and nam_sx<=b_nam_sx;
if b_i1<>0 then
  select nvl(min(gia),0) into b_kq from bh_xe_gtk where hang=b_hang and hieu=b_hieu and pban=b_pban and nam_sx=b_i1;
end if;
return b_kq;
end;
/
create or replace procedure PBH_XE_GTK_GIA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(2000); b_gia number:=0;
    b_hang varchar2(20); b_hieu varchar2(20); b_pban varchar2(20); b_nam_sx number;
    b_bien_do number:=0;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('pban,hang,hieu,nam_sx');
EXECUTE IMMEDIATE b_lenh into b_pban,b_hang,b_hieu,b_nam_sx using b_oraIn;
b_nam_sx:=nvl(b_nam_sx,0);
b_hang:=nvl(trim(b_hang),' '); b_hieu:=nvl(trim(b_hieu),' '); b_pban:=nvl(trim(b_pban),' ');
if b_hang<>' ' and b_hieu<>' ' and b_pban<>' ' then
  select count(*) into b_i1 from bh_xe_gtk where hang=b_hang and hieu=b_hieu and pban=b_pban and nam_sx=b_nam_sx;
  if b_i1 > 1 then b_loi:='loi:Co nhieu hon 1 gia tham khao:loi'; raise PROGRAM_ERROR; end if;
  if b_i1 > 0 then
     select gia,bien_do into b_gia,b_bien_do from bh_xe_gtk where hang=b_hang and hieu=b_hieu and pban=b_pban and nam_sx=b_nam_sx;
  end if;
end if;
select json_object('gia' value b_gia, 'bien_do' value b_bien_do) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_GTK_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000);
    b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob;
begin
-- viet anh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_xe_gtk;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object('ten_hang' value FBH_XE_HANG_TEN(hang),'ten_hieu' value FBH_XE_HIEU_TEN(hieu),
           'ten_pban' value FBH_XE_PB_TEN(hang,hieu,pban),hang,hieu,'ma' value pban,nam_sx,gia,bien_do)) into cs_lke from
        (select hang,hieu,pban,nam_sx,gia,bien_do,row_number() over (order by FBH_XE_HANG_TEN(hang),FBH_XE_HIEU_TEN(hieu)) as sott from bh_xe_gtk)
        where sott between b_tu and b_den;
else
    b_tim:=FKH_BO_UNICODE(b_tim,'C','C');
    select count(*) into b_dong  from 
           (select hang,hieu,pban,nam_sx,gia,bien_do from bh_xe_gtk a where
                       a.hang in (select b.ma from bh_xe_hang b where FKH_BO_UNICODE(b.ten,'C','C') like b_tim)
                UNION                                            
                select hang,hieu,pban,nam_sx,gia,bien_do from bh_xe_gtk a where
                       a.hieu in (select b.ma from bh_xe_hieu b where FKH_BO_UNICODE(b.ten,'C','C') like b_tim)
                UNION
                select hang,hieu,pban,nam_sx,gia,bien_do from bh_xe_gtk a where
                       a.pban in (select b.ma from bh_xe_pb b where FKH_BO_UNICODE(b.ten,'C','C') like b_tim));
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object('ten_hang' value FBH_XE_HANG_TEN(hang),'ten_hieu' value FBH_XE_HIEU_TEN(hieu),
           'ten_pban' value FBH_XE_PB_TEN(hang,hieu,pban),hang,hieu,'ma' value pban,nam_sx,gia,bien_do)) into cs_lke from
        (select hang,hieu,pban,nam_sx,gia,bien_do,row_number() over (order by FBH_XE_HANG_TEN(hang),FBH_XE_HIEU_TEN(hieu),FBH_XE_PB_TEN(hang,hieu,pban)) as sott from 
            (select hang,hieu,pban,nam_sx,gia,bien_do from bh_xe_gtk a where
                       a.hang in (select b.ma from bh_xe_hang b where FKH_BO_UNICODE(b.ten,'C','C') like b_tim)
                UNION                                            
                select hang,hieu,pban,nam_sx,gia,bien_do from bh_xe_gtk a where
                       a.hieu in (select b.ma from bh_xe_hieu b where FKH_BO_UNICODE(b.ten,'C','C') like b_tim)
                UNION
                select hang,hieu,pban,nam_sx,gia,bien_do from bh_xe_gtk a where
                       a.pban in (select b.ma from bh_xe_pb b where FKH_BO_UNICODE(b.ten,'C','C') like b_tim)))
                                            where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_GTK_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_tu number; b_den number; b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
    b_ma varchar2(20); b_hang varchar2(20); b_hieu varchar2(20); b_nam_sx number;
begin
-- viet anh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('hang,hieu,ma,nam_sx,hangkt');
EXECUTE IMMEDIATE b_lenh into b_hang,b_hieu,b_ma,b_nam_sx,b_hangkt using b_oraIn;
if b_hang is null or b_hieu is null or b_ma is null then
  b_loi:='loi:Nhap hang, hieu, phien ban:loi'; raise PROGRAM_ERROR; 
end if;
select count(*) into b_dong from bh_xe_gtk;
select nvl(min(sott),0) into b_tu from
  (select hang,hieu,pban,nam_sx,row_number() over ( order by hang,hieu,pban,nam_sx ) as sott from bh_xe_gtk order by hang,hieu,pban,nam_sx)
  where hang=b_hang and hieu=b_hieu and pban=b_ma and nam_sx=b_nam_sx;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from 
        (select hang,hieu,pban,nam_sx,row_number() over ( order by hang,hieu,pban,nam_sx ) as sott from bh_xe_gtk order by hang,hieu,pban,nam_sx)
  where hang>b_hang and hieu>b_hieu and pban>b_ma and nam_sx>b_nam_sx;
    end if;
PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object('ten_hang' value FBH_XE_HANG_TEN(hang),'ten_hieu' value FBH_XE_HIEU_TEN(hieu),
           'ten_pban' value FBH_XE_PB_TEN(hang,hieu,pban),hang,hieu,'ma' value pban,nam_sx,gia,bien_do) order by pban returning clob) into cs_lke from
    (select hang,hieu,pban,nam_sx,gia,bien_do,row_number() over ( order by hang,hieu,pban,nam_sx ) as sott from bh_xe_gtk order by hang,hieu,pban,nam_sx)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_GTK_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(2000); cs_ct clob:='';
    b_hang varchar2(20); b_hieu varchar2(20); b_ma varchar2(20); b_nam_sx number;
begin
-- viet anh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,hang,hieu,nam_sx');
EXECUTE IMMEDIATE b_lenh into b_ma,b_hang,b_hieu,b_nam_sx using b_oraIn;
if b_hang is null or b_hieu is null or b_ma is null or b_nam_sx is null then
    b_loi:='loi:Nhap hang, hieu, phien ban:loi'; raise PROGRAM_ERROR;
end if;
select count(*) into b_i1 from bh_xe_gtk where hang=b_hang and hieu=b_hieu and pban=b_ma and nam_sx=b_nam_sx;
if b_i1<>0 then
    select json_object(nam_sx,gia,'hang' value FBH_XE_HANG_TENl(hang),
        'hieu' value FBH_XE_HIEU_TENl(hieu),'ma' value FBH_XE_PB_TENl(hang,hieu,pban),bien_do) into cs_ct
        from bh_xe_gtk where hang=b_hang and hieu=b_hieu and pban=b_ma and nam_sx=b_nam_sx;
end if;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_GTK_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_pban varchar2(20); b_hang varchar2(20); b_hieu varchar2(20); b_nam_sx number; b_gia number;
    b_bien_do number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('hang,hieu,ma,nam_sx,gia,bien_do');
EXECUTE IMMEDIATE b_lenh into b_hang,b_hieu,b_pban,b_nam_sx,b_gia,b_bien_do using b_oraIn;
b_hang:=trim(b_hang); b_hieu:=trim(b_hieu); b_pban:=trim(b_pban); b_nam_sx:=nvl(b_nam_sx,0);
if b_hang is null or b_hieu is null or b_pban is null or b_nam_sx=0 then
    b_loi:='loi:Nhap hang, hieu, phien ban, nam SX:loi'; raise PROGRAM_ERROR;
end if;
if FBH_XE_HANG_HAN(b_hang)<>'C' then b_loi:='loi:Sai hang:loi'; raise PROGRAM_ERROR; end if;
if FBH_XE_HIEU_HAN(b_hang,b_hieu)<>'C' then b_loi:='loi:Sai hieu:loi'; raise PROGRAM_ERROR; end if;
if b_bien_do > 100 then
  b_loi:='loi: bien do tham chieu phai nho hon 100:loi'; raise PROGRAM_ERROR;
end if;
b_gia:=nvl(b_gia,0);
delete bh_xe_gtk where hang=b_hang and hieu=b_hieu and pban=b_pban and nam_sx=b_nam_sx;
insert into bh_xe_gtk values(b_ma_dvi,b_hang,b_hieu,b_pban,b_nam_sx,b_gia,b_bien_do,b_nsd);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--duchq import dia o man xe gia tham khao
create or replace procedure PBH_XE_GTK_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_hang varchar2(20); b_hieu varchar2(20); b_ma varchar2(20); b_nam_sx number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,hang,hieu,nam_sx');
EXECUTE IMMEDIATE b_lenh into b_ma,b_hang,b_hieu,b_nam_sx using b_oraIn;
if b_hang is null or b_hieu is null or b_ma is null or b_nam_sx is null then
  b_loi:='loi:Nhap hang, hieu, phien ban, nam SX:loi'; raise PROGRAM_ERROR; 
end if;
delete bh_xe_gtk where hang=b_hang and hieu=b_hieu and pban=b_ma and nam_sx=b_nam_sx;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* MDSD */
create or replace function FBH_XE_MDSD_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ten) into b_kq from bh_xe_mdsd where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_XE_MDSD_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_xe_mdsd where ma=b_ma;
if b_kq is not null then b_kq:=b_ma||'|'||b_kq; end if;
return b_kq;
end;
/
create or replace function FBH_XE_MDSD_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_xe_mdsd where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_XE_MDSD_LKE(
     b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_xe_mdsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select * from bh_xe_mdsd order by ma))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_xe_mdsd where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(a.*,'xep' value ma) obj from bh_xe_mdsd a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_MDSD_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_hangkt number;
    b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_xe_mdsd;
select nvl(min(sott),0) into b_tu from (select ma,rownum sott from bh_xe_mdsd order by ma) where ma=b_ma;
PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
select JSON_ARRAYAGG(obj) into cs_lke from
    (select json_object(ma,ten,nsd) obj,rownum sott from bh_xe_mdsd order by ma)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_MDSD_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma'); cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select obj into cs_ct from
    (select ma,json_object(*) obj from bh_xe_mdsd)
    where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_MDSD_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_txt clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_ngay_kt using b_txt;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_xe_mdsd where ma=b_ma;
insert into bh_xe_mdsd values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd,b_txt);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_MDSD_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_xe_mdsd where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Ty le phi / tgian BH
create or replace procedure PBH_XE_TLTG_TLE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_tu number; b_ngay_hl number; b_ngay_kt number; b_ngay_cap number;
    b_so_id number; b_so_idD number; b_tltgB number:=-1; b_tltgT number:=-1;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_hl,ngay_kt,ngay_cap');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_hl,b_ngay_kt,b_ngay_cap using b_oraIn;
if b_so_id is not null and b_so_id<>0 then
    b_so_idD:=FBH_XE_SO_IDd(b_ma_dvi,b_so_id);
    if b_so_idD not in(0,b_so_id) then
        b_ngay_cap:=FBH_XE_CAP(b_ma_dvi,b_so_idD);
    else
        b_ngay_cap:=nvl(b_ngay_cap,0);
    end if;
end if;
b_ngay_hl:=nvl(b_ngay_hl,0); b_ngay_kt:=nvl(b_ngay_kt,0);
if b_ngay_hl not in(0,30000101) and b_ngay_kt not in(0,30000101) and
    b_ngay_cap not in(0,30000101) and b_ngay_kt>=b_ngay_hl then
    b_tu:=FKH_KHO_THSO(b_ngay_hl,b_ngay_kt);
    select nvl(min(tle),0) into b_tltgB from bh_xe_tltg
        where nv='B' and b_tu between tu and den and b_ngay_cap between ngay_bd and ngay_kt;
    select nvl(min(tle),0) into b_tltgT from bh_xe_tltg
        where nv='T' and b_tu between tu and den and b_ngay_cap between ngay_bd and ngay_kt;
end if;
select json_object('tltgb' value b_tltgB,'tltgt' value b_tltgT) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_TLTG_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_nv varchar2(10); b_tu number; b_ngay_bd number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,tu,ngay_bd');
EXECUTE IMMEDIATE b_lenh into b_nv,b_tu,b_ngay_bd using b_oraIn;
b_nv:=nvl(trim(b_nv),' '); b_tu:=nvl(b_tu,0); b_ngay_bd:=nvl(b_ngay_bd,0);
b_loi:='loi:Khai bao da xoa:loi';
select json_object(nv,tu,den,tle,ngay_bd,ngay_kt) into b_oraOut
    from bh_xe_tltg where nv=b_nv and tu=b_tu and ngay_bd=b_ngay_bd;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_TLTG_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(*) order by ngay_bd,nv,tu) into b_oraOut from bh_xe_tltg;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_TLTG_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000);
	b_nv varchar2(10); b_tu number; b_den number; b_tle number; b_ngay_bd number; b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,tu,den,tle,ngay_bd,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_nv,b_tu,b_den,b_tle,b_ngay_bd,b_ngay_kt using b_oraIn;
b_nv:=nvl(trim(b_nv),' '); b_tu:=nvl(b_tu,0); b_den:=nvl(b_den,0);
b_tle:=nvl(b_tle,0); b_ngay_bd:=nvl(b_ngay_bd,0); b_ngay_kt:=nvl(b_ngay_kt,0);
if b_nv not in('B','T') then b_loi:='loi:Nhap loai bao hiem:loi'; raise PROGRAM_ERROR; end if;
if b_den=0 or b_tu>b_den then b_loi:='loi:Nhap sai khoang thang:loi'; raise PROGRAM_ERROR; end if;
if b_tle=0 then b_loi:='loi:Nhap he so phi:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
delete bh_xe_tltg where nv=b_nv and tu=b_tu and ngay_bd=b_ngay_bd;
insert into bh_xe_tltg values(b_nv,b_tu,b_den,b_tle,b_ngay_bd,b_ngay_kt,b_nsd);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_TLTG_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn cLob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000);
	b_nv varchar2(10); b_tu number; b_ngay_bd number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,tu,ngay_bd');
EXECUTE IMMEDIATE b_lenh into b_nv,b_tu,b_ngay_bd using b_oraIn;
b_nv:=nvl(trim(b_nv),' '); b_tu:=nvl(b_tu,0); b_ngay_bd:=nvl(b_ngay_bd,0);
delete bh_xe_tltg where nv=b_nv and tu=b_tu and ngay_bd=b_ngay_bd;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Ty le phi ngan han BH bat buoc
create or replace function FBH_XE_TLTGB_TLE(b_ngay_hl number,b_ngay_kt number) return number
AS
    b_kq number:=0; b_i1 number; b_th number:=FKH_KHO_THSO(b_ngay_hl,b_ngay_kt); b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Tra ty le phi < 12 thang
if b_th<12 then
    select nvl(max(tltg),0) into b_i1 from bh_xe_tltgB where tltg<=b_th and b_ngay between ngay_bd and ngay_kt;
    if b_i1<>0 then
        select tlph into b_kq from bh_xe_tltgB where tltg=b_i1 and b_ngay between ngay_bd and ngay_kt;
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
create or replace procedure PBH_XE_TLTGB_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_tltg number:=FKH_JS_GTRIs(b_oraIn,'tltg');
    cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Thoi gian da xoa:loi';
select json_object(tltg,tlph,ngay_bd,ngay_kt) into cs_ct from bh_xe_tltgB where tltg=b_tltg;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_TLTGB_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(tltg,tlph,nsd) order by tltg) into cs_lke from bh_xe_tltgB;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_TLTGB_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000);
    b_tltg number; b_tlph number; b_ngay_bd number; b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tltg,tlph,ngay_bd,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_tltg,b_tlph,b_ngay_bd,b_ngay_kt using b_oraIn;
if b_tltg is null then b_loi:='loi:Nhap so thang:loi'; raise PROGRAM_ERROR; end if;
if b_tlph is null then b_loi:='loi:Nhap ty le phi:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
delete bh_xe_tltgB where tltg=b_tltg;
insert into bh_xe_tltgB values(b_ma_dvi,b_tltg,b_tlph,b_ngay_bd,b_ngay_kt,b_nsd);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_TLTGB_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn cLob)
AS
    b_loi varchar2(100); b_tltg number:=FKH_JS_GTRIs(b_oraIn,'tltg');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_tltg is null then b_loi:='loi:Nhap thoi gian:loi'; raise PROGRAM_ERROR; end if;
delete bh_xe_tltgB where tltg=b_tltg;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_TLTGB_TLE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_ngay_hl number; b_ngay_kt number; b_tlph number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_bd,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ngay_hl,b_ngay_kt using b_oraIn;
b_tlph:=FBH_XE_TLTGB_TLE(b_ngay_hl,b_ngay_kt);
select json_object('tlph' value b_tlph) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Ma SP
create or replace function FBH_XE_SP_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_xe_sp where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_XE_SP_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_xe_sp where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_XE_SP_HAN(b_ma varchar2,b_dk varchar2:='C') return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_xe_sp where ma=b_ma and tc in('C',b_dk) and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace PROCEDURE PBH_XE_SP_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_xe_sp;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(* returning clob) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_xe_sp order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_xe_sp where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(a.*,'xep' value ma) obj from bh_xe_sp a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_SP_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_xe_sp;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_xe_sp order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_xe_sp order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep,rownum sott from
                (select * from bh_xe_sp order by ma) a
                start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_xe_sp where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_xe_sp where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(a.*,'xep' value ma) obj from bh_xe_sp a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_SP_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma'); cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma da xoa:loi';
select json_object(ma,txt returning clob) into cs_ct from bh_xe_sp where ma=b_ma;
select json_object('cs_ct' value cs_ct returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_SP_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_tc varchar2(1);
    b_ma_ct varchar2(10); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
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
    select 0 into b_i1 from bh_xe_sp where ma=b_ma_ct and tc='T';
end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_xe_sp where ma=b_ma;
insert into bh_xe_sp values(b_ma_dvi,b_ma,b_ten,b_tc,b_ma_ct,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_SP_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_xe_sp where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_xe_sp where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* Ma goi*/
create or replace function FBH_XE_GOI_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_xe_goi where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_XE_GOI_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_xe_goi where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_XE_GOI_LKE(
     b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_xe_goi;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select * from bh_xe_goi order by ma))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_xe_goi where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(a.*,'xep' value ma) obj from bh_xe_goi a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_GOI_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_xe_goi;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_xe_goi;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_GOI_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,ngay_kt) into b_kq from bh_xe_goi where ma=b_ma;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_GOI_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_ngay_kt using b_oraIn;
if trim(b_ma) is null or trim(b_ten) is null then b_loi:='loi:Nhap ma, ten:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_xe_goi where ma=b_ma;
insert into bh_xe_goi values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_GOI_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_xe_goi where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_XE_KTRU_HAN(b_muc number) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con dung
select count(*) into b_i1 from bh_xe_ktru where muc=b_muc and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_XE_KTRU_TLE(b_muc number) return number
AS
    b_kq number:=0; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Tra % giam phi
select nvl(min(pt),0) into b_kq from bh_xe_ktru where muc=b_muc and ngay_kt>b_ngay;
return b_kq;
end;
/
create or replace procedure PBH_XE_KTRU_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_muc number:=FKH_JS_GTRIn(b_oraIn,'muc');
    cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Thoi gian da xoa:loi';
select json_object(muc,pt,ngay_kt) into cs_ct from bh_xe_ktru where muc=b_muc;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_KTRU_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(muc,pt,nsd) order by muc) into cs_lke from bh_xe_ktru;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_KTRU_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000);
    b_muc number; b_pt number; b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('muc,pt,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_muc,b_pt,b_ngay_kt using b_oraIn;
if b_muc is null then b_loi:='loi:Nhap muc khau tru:loi'; raise PROGRAM_ERROR; end if;
b_pt:=nvl(b_pt,0);
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
delete bh_xe_ktru where muc=b_muc;
insert into bh_xe_ktru values(b_muc,b_pt,b_ngay_kt,b_nsd);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_KTRU_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn cLob)
AS
    b_loi varchar2(100); b_muc number:=FKH_JS_GTRIn(b_oraIn,'muc');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_muc is null then b_loi:='loi:Nhap thoi gian:loi'; raise PROGRAM_ERROR; end if;
delete bh_xe_ktru where muc=b_muc;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_KTRU_TLE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_muc number:=FKH_JS_GTRIn(b_oraIn,'muc'); b_pt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_pt:=FBH_XE_KTRU_TLE(b_muc);
select json_object('pt' value b_pt) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* Bieu phi */
create or replace function FBH_XE_BPHI_NV_BH(b_nvB varchar2,b_nvN varchar2) return varchar2
AS
    b_kq varchar(1):='K';
begin
-- Dan - Ktra co nv_bh tren GCN va bieu phi
if instr(b_nvN,b_nvB)>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_XE_BPHI_DK_LOAI(b_so_id number,b_ma varchar2) return varchar2
AS
	b_kq varchar2(5):=' '; b_lh_nv varchar2(10);
begin
-- Dan - Tra loai cua lh_bh cua ma: BN,BV,TN,TV,TTN,TTV
if b_ma='--' then return b_kq; end if;
select nvl(min(lh_nv),' ') into b_lh_nv from bh_xe_phi_dk where so_id=b_so_id and ma=b_ma;
if b_lh_nv<>' ' then
	select nvl(min(bb||loai),' ') into b_kq from bh_ma_lhnv where ma=b_lh_nv;
end if;
return b_kq;
end;
/
create or replace function FBH_XE_BPHI_DK_LHBH(b_so_id number,b_ma varchar2) return varchar2
AS
	b_kq varchar2(5):=' '; b_lh_bh varchar2(10);
begin
-- Dan - Tra loai cua lh_bh cua ma: C-Chinh, M-Mo rong
if b_ma<>'--' then
	select nvl(min(lh_bh),' ') into b_kq from bh_xe_phi_dk where so_id=b_so_id and ma=b_ma;
end if;
return b_kq;
end;
/
create or replace function FBH_XE_BPHI_DK_BTH(b_ma varchar2,b_nv varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number;
begin
-- Dan - Xac dinh nghiep vu boi thuong
if b_nv='V' then
    select count(*) into b_i1 from bh_xe_phi a,bh_xe_phi_dk b where a.nv_bh='V' and b.so_id=a.so_id and b.ma=b_ma;
else
    select count(*) into b_i1 from bh_xe_phi a,bh_xe_phi_dk b where a.nv_bh<>'V' and b.so_id=a.so_id and b.ma=b_ma;
end if;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_XE_BPHI_TSOm(
    b_oraIn clob,b_nhom out varchar2, b_bh_tbo out varchar2, b_cdich out varchar2, b_goi out varchar2,
    b_ttai out number, b_so_cn out number, b_loai_xe out varchar2, b_nhom_xe out varchar2, b_gia out number,b_tuoi out number,
    b_ma_sp out varchar2, b_md_sd out varchar2, b_nv_bh out varchar2,
    b_dong out varchar2, b_dco out varchar2,b_ngay_hl out number,b_lh_bh out varchar2,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_nam_sx number; b_thang_sx number;
begin
-- Dan - Dat gia tri
b_loi:='loi:Loi xu ly PBH_XE_BPHI_TSOm:loi';
b_lenh:=FKH_JS_LENH('nhom,bh_tbo,cdich,goi,ttai,so_cn,thang_sx,nam_sx,loai_xe,nhom_xe,gia,ma_sp,md_sd,nv_bh,dong,dco,ngay_hl,lh_bh');
EXECUTE IMMEDIATE b_lenh into
    b_nhom,b_bh_tbo,b_cdich,b_goi,b_ttai,b_so_cn,b_thang_sx,b_nam_sx,b_loai_xe,b_nhom_xe,b_gia,
    b_ma_sp,b_md_sd,b_nv_bh,b_dong,b_dco,b_ngay_hl,b_lh_bh using b_oraIn;
b_thang_sx:=nvl(b_thang_sx,0); b_nam_sx:=nvl(b_nam_sx,0);
b_tuoi:=FBH_XE_TUOIt(b_thang_sx,b_nam_sx);
b_nhom:=NVL(trim(b_nhom),'T'); b_bh_tbo:=NVL(trim(b_bh_tbo),' ');
b_cdich:=NVL(trim(b_cdich),' '); b_goi:=NVL(trim(b_goi),' ');
b_ttai:=nvl(b_ttai,0); b_so_cn:=nvl(b_so_cn,0); b_loai_xe:=PKH_MA_TENl(b_loai_xe); 
b_nhom_xe:=PKH_MA_TENl(b_nhom_xe); b_gia:=nvl(b_gia,0); b_tuoi:=nvl(b_tuoi,0);
b_ma_sp:=NVL(trim(b_ma_sp),' '); b_md_sd:=PKH_MA_TENl(b_md_sd); b_nv_bh:=NVL(trim(b_nv_bh),' ');
b_dong:=PKH_MA_TENl(b_dong); b_dco:=NVL(trim(b_dco),' ');
if b_ngay_hl is null or b_ngay_hl in(0,30000101) then b_ngay_hl:=PKH_NG_CSO(sysdate); end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_XE_BPHI_TSO(
    b_oraIn clob,b_nhom out varchar2,b_nv_bh out varchar2,b_bh_tbo out varchar2,
    b_md_sd out varchar2,b_ma_sp out varchar2,b_cdich out varchar2,b_goi out varchar2,
    b_loai_xe out varchar2,b_nhom_xe out varchar2,b_dong out varchar2,
    b_dco out varchar2,b_ttai out number,b_so_cn out number,b_tuoi out number,
    b_gia out number,b_ngay_bd out number,b_ngay_kt out number,b_ngay_hl out number,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_c varchar2(500);
begin
-- Dan - Dat gia tri
b_loi:='loi:Loi xu ly bien vao:loi';
b_lenh:=FKH_JS_LENH('nhom,nv_bh,bh_tbo,md_sd,ma_sp,cdich,goi,
    loai_xe,nhom_xe,dong,dco,ttai,so_cn,tuoi,gia,ngay_bd,ngay_kt,ngay_hl');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_nv_bh,b_bh_tbo,b_md_sd,b_ma_sp,b_cdich,b_goi,
    b_loai_xe,b_nhom_xe,b_dong,b_dco,b_ttai,b_so_cn,b_tuoi,b_gia,b_ngay_bd,b_ngay_kt,b_ngay_hl using b_oraIn;

b_nhom:=PKH_MA_TENl(b_nhom); b_nv_bh:=PKH_MA_TENl(b_nv_bh); b_bh_tbo:=nvl(trim(b_bh_tbo),'C');
b_md_sd:=PKH_MA_TENl(b_md_sd); b_ma_sp:=PKH_MA_TENl(b_ma_sp);
b_cdich:=PKH_MA_TENl(b_cdich); b_goi:=PKH_MA_TENl(b_goi);
b_loai_xe:=PKH_MA_TENl(b_loai_xe); b_nhom_xe:=PKH_MA_TENl(b_nhom_xe);
b_dong:=PKH_MA_TENl(b_dong); b_dco:=PKH_MA_TENl(b_dco);
b_ttai:=nvl(b_ttai,0); b_so_cn:=nvl(b_so_cn,0); b_gia:=nvl(b_gia,0); b_tuoi:=nvl(b_tuoi,0);
b_ngay_bd:=nvl(b_ngay_bd,0); b_ngay_kt:=nvl(b_ngay_kt,30000101);
if b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
if b_ngay_hl is null or b_ngay_hl in(0,30000101) then b_ngay_hl:=PKH_NG_CSO(sysdate); end if;
b_nhom:= nvl(trim(b_nhom),'T');
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_XE_BPHI_TSOt(
    b_nhom varchar2,b_nv_bh varchar2,b_bh_tbo varchar2,b_md_sd varchar2,b_ma_sp varchar2,b_cdich varchar2,
    b_goi varchar2,b_loai_xe varchar2,b_nhom_xe varchar2,b_dong varchar2,b_dco varchar2,b_loi out varchar2)
AS
begin
-- Dan - Ktra tso
if b_nhom not in('G','H','T') then b_loi:='loi:Sai nhom '||b_nhom||':loi';  return; end if;
if b_nv_bh not in('B','T','V','M') then
    b_loi:='loi:Sai loai:loi'; return;
end if;
if b_bh_tbo not in('C','K') then
    b_loi:='loi:Bao hiem toan bo: C-Co, K-Khong:loi';  return;
end if;
if b_md_sd<>' ' and FBH_XE_MDSD_HAN(b_md_sd)<>'C' then
    b_loi:='loi:Sai ma muc dich su dung:loi';  return;
end if;
if b_ma_sp<>' ' and FBH_XE_SP_HAN(b_ma_sp)<>'C' then
    b_loi:='loi:Sai ma san pham:loi';  return;
end if;
if b_cdich<>' ' and FBH_MA_CDICH_HAN(b_cdich)<>'C' then
    b_loi:='loi:Da het chien dich:loi';  return;
end if;
if b_goi<>' ' and FBH_XE_GOI_HAN(b_goi)<>'C' then
    b_loi:='loi:Sai ma goi:loi';  return;
end if;
if b_loai_xe<>' ' and FBH_XE_LOAI_HAN(b_loai_xe)<>'C' then
    b_loi:='loi:Sai loai xe:loi';  return;
end if;
if b_nhom_xe<>' ' and FBH_XE_NHOM_HAN(b_nhom_xe)<>'C' then
    b_loi:='loi:Sai nhom xe:loi';  return;
end if;
if b_dong<>' ' and FBH_XE_DONG_HAN(b_dong)<>'C' then
    b_loi:='loi:Sai dong xe:loi';  return;
end if;
if b_dco not in(' ','X','D','E','H') then
    b_loi:='loi:Sai loai dong co:loi';  return;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure FBH_XE_BPHI_SO_ID(
    b_nhom varchar2,b_nv_bh varchar2,b_bh_tbo varchar2,
    b_md_sd varchar2,b_ma_sp varchar2,b_cdich varchar2,b_goi varchar2,
    b_loai_xe varchar2,b_nhom_xe varchar2,b_dong varchar2,b_dco varchar2,
    b_ttai number,b_so_cn number,b_tuoi number,b_gia number,b_ngay_hlN number,
    b_so_id out number,b_loi out varchar2)
AS
    b_i1 number; b_ngay_hl number:=b_ngay_hlN;
    b_ttaiM number; b_so_cnM number; b_tuoiM number; b_giaM number;
begin
-- Dan - Tra so ID phi
b_loi:='Loi:Loi lay bieu phi:loi';
if b_ngay_hl in(0,30000101) then b_ngay_hl:=PKH_NG_CSO(sysdate); end if;
b_so_id:=0;
-- viet anh -- sua dk lay bphi ma_sp,cdich,goi
select nvl(max(ttai),0),nvl(max(so_cn),0),nvl(max(tuoi),0),nvl(max(gia),0)
    into b_ttaiM,b_so_cnM,b_tuoiM,b_giaM from bh_xe_phi where
    nhom in('T',b_nhom) and nv_bh=b_nv_bh and md_sd=b_md_sd and
    ma_sp=b_ma_sp and cdich=b_cdich and goi=b_goi and
    loai_xe=b_loai_xe and nhom_xe=b_nhom_xe and dong=b_dong and dco=b_dco and
    ttai<=b_ttai and so_cn<=b_so_cn and tuoi<=b_tuoi and gia<=b_gia and b_ngay_hl between ngay_bd and ngay_kt;
select nvl(max(so_id),0) into b_so_id from bh_xe_phi where
    nv_bh=b_nv_bh and nhom in('T',b_nhom) and md_sd=b_md_sd and 
    ma_sp=b_ma_sp and cdich=b_cdich and goi=b_goi and
    loai_xe=b_loai_xe and nhom_xe=b_nhom_xe and dong=b_dong and dco=b_dco and
    ttai=b_ttaiM and so_cn=b_so_cnM and tuoi=b_tuoiM and gia=b_giaM and
    b_ngay_hl between ngay_bd and ngay_kt;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure FBH_XE_BPHI_SO_IDj(
    b_nhom varchar2,b_nv_bh varchar2,b_bh_tbo varchar2,
    b_md_sd varchar2,b_ma_sp varchar2,b_cdich varchar2,b_goi varchar2,
    b_loai_xe varchar2,b_nhom_xe varchar2,b_dong varchar2,b_dco varchar2,
    b_ttai number,b_so_cn number,b_tuoi number,b_gia number,b_ngay_hlN number,
    b_so_id out number,b_loi out varchar2)
AS
    b_i1 number; b_ngay_hl number:=b_ngay_hlN;
    b_ttaiM number; b_so_cnM number; b_tuoiM number; b_giaM number;
begin
-- viet anh - Tra so ID phi khi tao bieu phi
b_loi:='Loi:Loi lay bieu phi:loi';
if b_ngay_hl in(0,30000101) then b_ngay_hl:=PKH_NG_CSO(sysdate); end if;
b_so_id:=0;
select nvl(max(ttai),0),nvl(max(so_cn),0),nvl(max(tuoi),0),nvl(max(gia),0)
    into b_ttaiM,b_so_cnM,b_tuoiM,b_giaM from bh_xe_phi where
    nhom in('T',b_nhom) and nv_bh=b_nv_bh and md_sd=b_md_sd and
    ma_sp=b_ma_sp and cdich=b_cdich and goi=b_goi and
    loai_xe=b_loai_xe and nhom_xe=b_nhom_xe and dong=b_dong and dco=b_dco and
    b_ngay_hl between ngay_bd and ngay_kt and ttai=b_ttai and so_cn=b_so_cn and tuoi=b_tuoi and gia=b_gia;
select nvl(max(so_id),0) into b_so_id from bh_xe_phi where
    nhom in('T',b_nhom) and nv_bh=b_nv_bh and md_sd=b_md_sd and
    ma_sp=b_ma_sp and cdich=b_cdich and goi=b_goi and
    loai_xe=b_loai_xe and nhom_xe=b_nhom_xe and dong=b_dong and dco=b_dco and
    b_ngay_hl between ngay_bd and ngay_kt and ttai=b_ttaiM and so_cn=b_so_cnM and tuoi=b_tuoiM and gia=b_giaM;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_XE_BPHI_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_so_id number;
    b_nhom varchar2(1); b_nv_bh varchar2(10); b_bh_tbo varchar2(1); b_md_sd varchar2(500);
    b_ma_sp varchar2(10); b_cdich varchar2(10); b_goi varchar2(10); 
    b_loai_xe varchar2(500); b_nhom_xe varchar2(500); b_dong varchar2(500); b_dco varchar2(500); 
    b_ttai number; b_so_cn number; b_tuoi number; b_gia number; b_nam_sx number;
    b_ngay_bd number; b_ngay_kt number; b_ngay_hl number;
begin
-- Dan - Tra so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_XE_BPHI_TSO(
    b_oraIn,b_nhom,b_nv_bh,b_bh_tbo,b_md_sd,b_ma_sp,b_cdich,b_goi,b_loai_xe,b_nhom_xe,
    b_dong,b_dco,b_ttai,b_so_cn,b_tuoi,b_gia,b_ngay_bd,b_ngay_kt,b_ngay_hl,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
FBH_XE_BPHI_SO_ID(
    b_nhom,b_nv_bh,b_bh_tbo,b_md_sd,b_ma_sp,b_cdich,b_goi,b_loai_xe,
    b_nhom_xe,b_dong,b_dco,b_ttai,b_so_cn,b_tuoi,b_gia,b_ngay_bd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_BPHI_DKBS(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,'ma_dk' value ma,lh_nv) order by ma returning clob) into cs_lke
    from bh_ma_dkbs where FBH_MA_NV_CO(nv,'XE')='C' order by ma;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_BPHI_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_sp clob; cs_cdich clob; cs_goi clob; cs_lt clob; cs_khd clob; cs_kbt clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ten) into cs_sp from bh_xe_sp where FBH_XE_SP_HAN(ma)='C';
select JSON_ARRAYAGG(json_object(ma,ten) order by ten) into cs_cdich
    from bh_ma_cdich where FBH_MA_NV_CO(nv,'XE')='C' and FBH_MA_CDICH_HAN(ma)='C';
select JSON_ARRAYAGG(json_object(ma,ten) order by ma) into cs_goi from bh_xe_goi where FBH_XE_GOI_HAN(ma)='C';
select JSON_ARRAYAGG(json_object(ma_dk,ten,'ma_lt' value ma)) into cs_lt
    from bh_ma_dklt a where FBH_MA_NV_CO(nv,'XE')='C' and FBH_MA_DKLT_HAN(ma_dk,ma)='C' and MA <> ' ';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_khd from bh_kh_ttt where ps='KHD' and nv='XE';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_kbt from bh_kh_ttt where ps='KBT' and nv='XE';
select json_object('cs_sp' value cs_sp,'cs_cdich' value cs_cdich,'cs_goi' value cs_goi,
    'cs_lt' value cs_lt,'cs_khd' value cs_khd,'cs_kbt' value cs_kbt) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_BPHI_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_i1 number; b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
	dt_dk clob; dt_dkbs clob:=''; dt_khd clob:=''; dt_kbt clob:=''; dt_ct clob; dt_lt clob; dt_txt clob;
begin
-- Dan - Xem chi tiet theo so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Bieu phi da xoa:loi';
select JSON_ARRAYAGG(json_object(so_id,'nhom' value FBH_XE_NHOM_TENl(nhom),'loai_xe' value FBH_XE_LOAI_TENl(loai_xe),
    'dong' value FBH_XE_DONG_TENl(dong),'md_sd' value FBH_XE_MDSD_TENl(md_sd)) returning clob)
into dt_ct from bh_xe_phi where so_id=b_so_id;
select txt into dt_dk from bh_xe_phi_txt where so_id=b_so_id and loai='dt_dk';
select count(*) into b_i1 from bh_xe_phi_txt where so_id=b_so_id and loai='dt_dkbs';
if b_i1<>0 then
    select txt into dt_dkbs from bh_xe_phi_txt where so_id=b_so_id and loai='dt_dkbs';
end if;
select JSON_ARRAYAGG(json_object(ma_lt) order by bt returning clob) into dt_lt from bh_xe_phi_lt where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt) returning clob) into dt_txt from bh_xe_phi_txt where so_id=b_so_id and loai in('dt_ct','dt_lt');
select count(*) into b_i1 from bh_xe_phi_txt where so_id=b_so_id and loai='dt_khd';
if b_i1<>0 then
    select txt into dt_khd from bh_xe_phi_txt where so_id=b_so_id and loai='dt_khd';
end if;
select count(*) into b_i1 from bh_xe_phi_txt where so_id=b_so_id and loai='dt_kbt';
if b_i1<>0 then
    select txt into dt_kbt from bh_xe_phi_txt where so_id=b_so_id and loai='dt_kbt';
end if;
select json_object('so_id' value b_so_id,'dt_khd' value dt_khd,'dt_kbt' value dt_kbt,'dt_ct' value dt_ct,
    'dt_dk' value dt_dk,'dt_dkbs' value dt_dkbs,'dt_lt' value dt_lt,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_BPHI_CTs(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_so_id number;
    b_nhom varchar2(1); b_nv_bh varchar2(10); b_lh_bh  varchar2(10);
    b_bh_tbo varchar2(1); b_md_sd varchar2(500);
    b_ma_sp varchar2(10); b_cdich varchar2(10); b_goi varchar2(10); 
    b_loai_xe varchar2(500); b_nhom_xe varchar2(500); b_dong varchar2(500); b_dco varchar2(500); 
    b_ttai number; b_so_cn number; b_tuoi number; b_gia number; b_ngay_hl number;
    a_nv pht_type.a_var;
    b_nv varchar2(10):=''; b_so_idS varchar2(100):='';
begin
-- Dan - Tra so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_XE_BPHI_TSOm(
    b_oraIn,b_nhom,b_bh_tbo,b_cdich,b_goi,b_ttai,b_so_cn,b_loai_xe,b_nhom_xe,b_gia,b_tuoi,
    b_ma_sp,b_md_sd,b_nv_bh,b_dong,b_dco,b_ngay_hl,b_lh_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nvb,nvt,nvv');
EXECUTE IMMEDIATE b_lenh into a_nv(1),a_nv(2),a_nv(3) using b_oraIn;
for b_lp in 1..3 loop
    if nvl(trim(a_nv(b_lp)),' ')='C' then
        if b_lp=1 then a_nv(b_lp):='B';
        elsif b_lp=2 then a_nv(b_lp):='T';
        elsif b_lp=3 then a_nv(b_lp):='V';
        end if;
        FBH_XE_BPHI_SO_ID(
            b_nhom,a_nv(b_lp),b_bh_tbo,b_md_sd,b_ma_sp,b_cdich,b_goi,b_loai_xe,
            b_nhom_xe,b_dong,b_dco,b_ttai,b_so_cn,b_tuoi,b_gia,b_ngay_hl,b_so_id,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
        if b_so_id=0 then
            b_nv:=a_nv(b_lp); b_so_idS:='0'; exit;
        else
            if b_nv is not null then b_nv:=b_nv||','; b_so_idS:=b_so_idS||','; end if;
            b_nv:=b_nv||a_nv(b_lp); b_so_idS:=b_so_idS||to_char(b_so_id);
        end if;
    end if;
end loop;
select json_object('nv' value b_nv,'so_id' value b_so_idS) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_BPHI_CTd(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_nv varchar2(1); b_so_id number; b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tygia number;
    cs_dk clob; cs_dkbs clob; dt_khd clob:=''; cs_kbt clob:=''; cs_lt clob; cs_txt clob;
    b_pt number; b_phi number;
    a_maDK pht_type.a_var; a_btDK pht_type.a_num;
begin
-- Dan - Tra bieu phi theo so_id
delete temp_1; delete temp_2; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,so_id,nt_tien,nt_phi,tygia');
EXECUTE IMMEDIATE b_lenh into b_nv,b_so_id,b_nt_tien,b_nt_phi,b_tygia using b_oraIn;
b_tygia:=nvl(b_tygia,1);
if nvl(trim(b_nt_phi),'VND')='VND' and b_tygia<=0 then b_tygia:=1; end if;
-- viet anh -- them NT_tien, sap xep dk
select ma,min(bt) bulk collect into a_maDK,a_btDK from bh_xe_phi_dk where so_id=b_so_id and lh_bh<>'M' group by ma;
forall b_lp in 1..a_maDK.count
    insert into temp_1(c1,n1,n11,n12,n13) select a_maDK(b_lp),a_btDK(b_lp),tien,pt,phi from bh_xe_phi_dk where so_id=b_so_id and ma=a_maDK(b_lp) and bt=a_btDK(b_lp);
commit;
for r_lp in (select c1 ma,n1 bt,n11 tien from temp_1) loop
    FBH_XE_BPHI_DKm(b_so_id,r_lp.ma,r_lp.tien,'C',b_pt,b_phi,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    update temp_1 set n12=b_pt,n13=b_phi where c1=r_lp.ma and n1=r_lp.bt;
end loop;
select JSON_ARRAYAGG(json_object(
        a.ma,ten,'tien' value case when b_nt_tien='VND' then b.n11 else round(b.n11/b_tygia,2) end,
        'tienC' value case when b_nt_tien='VND' then b.n11 else round(b.n11/b_tygia,2) end,
        'ptB' value case when b_nt_phi<>'VND' then decode(sign(b.n12-100),1,round(b.n12/b_tygia,2),b.n12) else b.n12 end,
        'pt' value '',phi,cap,tc,ma_ct,ma_dk,ma_dkC,kieu,lh_nv,t_suat,lkeM,lkeP,lkeB,luy,lh_bh,
        'nv' value b_nv,a.bt,'ptk' value decode(sign(pt-50),1,'T','P'))
        order by a.bt returning clob) into cs_dk
        from bh_xe_phi_dk a,temp_1 b where a.so_id=b_so_id and b.n1=a.bt order by a.bt;
select ma,min(bt) bulk collect into a_maDK,a_btDK from bh_xe_phi_dk where so_id=b_so_id and lh_bh='M' group by ma;
forall b_lp in 1..a_maDK.count
    insert into temp_2(c1,n1,n11,n12,n13) select a_maDK(b_lp),a_btDK(b_lp),tien,pt,phi from bh_xe_phi_dk where so_id=b_so_id and ma=a_maDK(b_lp) and bt=a_btDK(b_lp);
commit;
for r_lp in (select c1 ma,n1 bt,n11 tien from temp_2) loop
    FBH_XE_BPHI_DKm(b_so_id,r_lp.ma,r_lp.tien,'M',b_pt,b_phi,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    update temp_2 set n12=b_pt,n13=b_phi where c1=r_lp.ma and n1=r_lp.bt;
end loop;
select JSON_ARRAYAGG(json_object(
        a.ma,ten,'tien' value case when b_nt_tien='VND' then b.n11 else round(b.n11/b_tygia,2) end,
        'tienC' value case when b_nt_tien='VND' then b.n11 else round(b.n11/b_tygia,2) end,
        'ptB' value case when b_nt_phi<>'VND' then decode(sign(b.n12-100),1,round(b.n12/b_tygia,2),b.n12) else b.n12 end,
        'pt' value '',phi,cap,tc,ma_ct,ma_dk,ma_dkC,kieu,lh_nv,t_suat,lkeM,lkeP,lkeB,luy,lh_bh,
        'nv' value b_nv,a.bt,'ptk' value decode(sign(pt-50),1,'T','P'))
        order by a.bt returning clob) into cs_dkbs
        from bh_xe_phi_dk a,temp_2 b where a.so_id=b_so_id and b.n1=a.bt order by a.bt;
-- end
select JSON_ARRAYAGG(json_object(ma_lt,ten) order by bt returning clob) into cs_lt from bh_xe_phi_lt where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into cs_txt
    from bh_xe_phi_txt where so_id=b_so_id and loai in('dt_dk','dt_dkbs');
select count(*) into b_i1 from bh_xe_phi_txt where so_id=b_so_id and loai='dt_khd';
if b_i1<>0 then
    select txt into dt_khd from bh_xe_phi_txt where so_id=b_so_id and loai='dt_khd';
end if;
select count(*) into b_i1 from bh_xe_phi_txt where so_id=b_so_id and loai='dt_kbt';
if b_i1<>0 then
    select txt into cs_kbt from bh_xe_phi_txt where so_id=b_so_id and loai='dt_kbt';
end if;
select json_object('nv' value b_nv,'dt_dk' value cs_dk,'dt_dkbs' value cs_dkbs, 'dt_khd' value dt_khd,
    'dt_kbt' value cs_kbt,'dt_lt' value cs_lt,'txt' value cs_txt returning clob) into b_oraOut from dual;
delete temp_1; delete temp_2; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_BPHI_DKm(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_nv varchar2(10);
    b_so_id number; b_ma varchar2(10); b_tien number; b_pt number; b_phi number;
    b_nhom varchar2(1); b_bh_tbo varchar2(10); b_cdich varchar2(10); b_goi varchar2(10);
    b_ttai number; b_so_cn number; b_loai_xe varchar2(500); b_nhom_xe varchar2(500); b_gia number; b_tuoi number;
    b_ma_sp varchar2(10); b_md_sd varchar2(500); b_nv_bh varchar2(10); b_lh_bh  varchar2(10);
    b_dong varchar2(500); b_dco varchar2(1); b_ngay_hl number;
    b_dvi_ta varchar2(10):=FTBH_DVI_TA(); b_ngay number:=PKH_NG_CSO(sysdate);
    b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Dan - Tra dieu khoan mo rong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_XE_BPHI_TSOm(
    b_oraIn,b_nhom,b_bh_tbo,b_cdich,b_goi,b_ttai,b_so_cn,b_loai_xe,b_nhom_xe,b_gia,b_tuoi,
    b_ma_sp,b_md_sd,b_nv_bh,b_dong,b_dco,b_ngay_hl,b_lh_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loai_xe:=PKH_MA_TENl(b_loai_xe); b_nhom_xe:=PKH_MA_TENl(b_nhom_xe);
b_md_sd:=PKH_MA_TENl(b_md_sd); b_dong:=PKH_MA_TENl(b_dong);
b_lenh:=FKH_JS_LENH('nv,ma,nt_tien,nt_phi,tien');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ma,b_nt_tien,b_nt_phi,b_tien using b_oraIn;
-- viet anh -- da quy doi ngoai js
-- if b_nt_tien<>'VND' then b_tien:=FTT_VND_QD(b_dvi_ta,b_ngay,b_nt_tien,b_tien); end if;
FBH_XE_BPHI_SO_ID(
    b_nhom,b_nv,'C',b_md_sd,b_ma_sp,b_cdich,b_goi,b_loai_xe,b_nhom_xe,b_dong,b_dco,b_ttai,b_so_cn,b_tuoi,b_gia,
    b_ngay_hl,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
FBH_XE_BPHI_DKm(b_so_id,b_ma,b_tien,b_lh_bh,b_pt,b_phi,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_nt_phi<>'VND' then
  if b_pt>100 then b_pt:=FTT_TUNG_QD(b_dvi_ta,b_ngay,'VND',b_pt,b_nt_phi); end if;
  b_phi:=FTT_TUNG_QD(b_dvi_ta,b_ngay,'VND',b_phi,b_nt_phi);
end if;
select json_object('pt' value b_pt,'phi' value b_phi) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- chuclh: so khong dung nen bo
--create or replace procedure PBH_XE_BPHI_DKt(
create or replace procedure PBH_XE_BPHId_THEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_so_id number; b_i1 number; b_i2 number;
    b_nhom varchar2(1); b_nv_bh varchar2(10); b_lh_bh  varchar2(10);
    b_bh_tbo varchar2(1); b_md_sd varchar2(500);
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tygia number; b_pt number; b_phi number;
    b_ma_sp varchar2(10); b_cdich varchar2(10); b_goi varchar2(10);
    b_loai_xe varchar2(500); b_nhom_xe varchar2(500); b_dong varchar2(500); b_dco varchar2(500);
    b_ttai number; b_so_cn number; b_tuoi number; b_gia number;
    b_ngay_bd number; b_ngay_kt number; b_ngay_hl number;
    a_nv pht_type.a_var; b_so_idS varchar2(100):=''; b_nvS varchar2(100); b_vu varchar2(10);
    a_so_idN pht_type.a_num; a_nvN pht_type.a_var;
    b_dk_lt clob; a_ma_lt pht_type.a_var; a_ma_dk_lt pht_type.a_var; a_ten_lt pht_type.a_nvar; a_chon_lt pht_type.a_var;
    -- viet anh -- tra ra them b_so_idS
    b_nv varchar2(10):='';
    a_maDK pht_type.a_var; a_btDK pht_type.a_num;
begin
-- Dan - Tra so ID
delete from temp_1; delete from temp_2; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_XE_BPHI_TSOm(
    b_oraIn,b_nhom,b_bh_tbo,b_cdich,b_goi,b_ttai,b_so_cn,b_loai_xe,b_nhom_xe,b_gia,b_tuoi,
    b_ma_sp,b_md_sd,b_nv_bh,b_dong,b_dco,b_ngay_hl,b_lh_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nvb,nvt,nvv,vu,nt_tien,nt_phi,tygia');
EXECUTE IMMEDIATE b_lenh into a_nv(1),a_nv(2),a_nv(3),b_vu,b_nt_tien,b_nt_phi,b_tygia using b_oraIn;
b_nt_phi:=NVL(trim(b_nt_phi),'VND'); b_nt_tien:=NVL(trim(b_nt_tien),'VND');
b_tygia:=nvl(b_tygia,1);
if nvl(trim(b_nt_phi),'VND')='VND' and b_tygia<=0 then b_tygia:=1; end if;
b_oraOut:='';
for b_lp in 1..3 loop
    if nvl(trim(a_nv(b_lp)),' ')<>'C' then continue; end if;
    if b_lp=1 then a_nv(b_lp):='B';
    elsif b_lp=2 then a_nv(b_lp):='T';
    elsif b_lp=3 then a_nv(b_lp):='V';
    end if;
    FBH_XE_BPHI_SO_ID(
        b_nhom,a_nv(b_lp),b_bh_tbo,b_md_sd,b_ma_sp,b_cdich,b_goi,b_loai_xe,
        b_nhom_xe,b_dong,b_dco,b_ttai,b_so_cn,b_tuoi,b_gia,b_ngay_hl,b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    -- viet anh -- tra ra them b_so_idS
    if b_so_id=0 then return;
    else
        if b_nv is not null then b_nv:=b_nv||','; b_so_idS:=b_so_idS||','; end if;
        b_nv:=b_nv||a_nv(b_lp); b_so_idS:=b_so_idS||to_char(b_so_id);
    end if;
    b_i1:=a_so_idN.count+1;
    a_so_idN(b_i1):=b_so_id; a_nvN(b_i1):=a_nv(b_lp);
end loop;
if a_so_idN.count=0 then return; end if;
for b_lp in 1..a_so_idN.count loop
  if b_vu='dk' then
    insert into temp_1(c1,n1,c2,n2) select a_nvN(b_lp),min(bt),ma,a_so_idN(b_lp) from bh_xe_phi_dk where so_id=a_so_idN(b_lp) and lh_bh<>'M' group by ma;
  elsif b_vu='dkbs' then
    insert into temp_1(c1,n1,c2,n2) select a_nvN(b_lp),min(bt),ma,a_so_idN(b_lp) from bh_xe_phi_dk where so_id=a_so_idN(b_lp) and lh_bh='M' group by ma;
  end if;
end loop;
if b_vu='dk' then
    select JSON_ARRAYAGG(json_object(ma,ten,'tien' value case when b_nt_tien='VND' then tien else round(tien/b_tygia,2) end,
      'ptB' value case when b_nt_phi<>'VND' then decode(sign(pt-100),1,round(pt/b_tygia,2),pt) else pt end,
      'pt' value '',phi,cap,tc,ma_ct,ma_dk,ma_dkC,kieu,lh_nv,t_suat,lkeM,lkeP,lkeB,luy,lh_bh,
      'nv' value b.c1,'ptk' value decode(sign(pt-100),1,'T','P'),'so_ids' value b_so_idS,'bt' value bt) order by bt returning clob)
        into b_oraOut from bh_xe_phi_dk a,temp_1 b where a.so_id=b.n2 and a.bt=b.n1 and a.lh_bh<>'M' order by bt;
elsif b_vu='dkbs' then
    select JSON_ARRAYAGG(json_object(ma,ten,'tien' value case when b_nt_tien='VND' then tien else round(tien/b_tygia,2) end,
      'ptB' value case when b_nt_phi<>'VND' then decode(sign(pt-100),1,round(pt/b_tygia,2),pt) else pt end,
      'pt' value '',phi,cap,tc,ma_ct,ma_dk,ma_dkC,kieu,lh_nv,t_suat,lkeM,lkeP,lkeB,luy,lh_bh,
      'nv' value b.c1,'ptk' value decode(sign(pt-100),1,'T','P'),'so_ids' value b_so_idS,'bt' value bt) order by bt returning clob)
        into b_oraOut from bh_xe_phi_dk a,temp_1 b where a.so_id=b.n2 and a.bt=b.n1 and a.lh_bh='M' order by bt;
elsif b_vu='lt' then
    for b_lp in 1..a_so_idN.count loop
        select count(*) into b_i2 from bh_xe_phi_txt where so_id=a_so_idN(b_lp) and loai='dt_lt';
        if b_i2 > 0 then
            select FKH_JS_BONH(txt) into b_dk_lt from bh_xe_phi_txt where so_id=a_so_idN(b_lp) and loai='dt_lt';
            b_lenh:=FKH_JS_LENH('ma_lt,ma_dk,ten,chon');
            EXECUTE IMMEDIATE b_lenh bulk collect into a_ma_lt,a_ma_dk_lt,a_ten_lt,a_chon_lt using b_dk_lt;
            if a_ma_lt.count > 0 then
                for b_lp2 in 1..a_ma_lt.count loop
                    insert into temp_2(c1,c2,c3,c4) VALUES (a_ma_lt(b_lp2),a_ma_dk_lt(b_lp2),a_ten_lt(b_lp2),a_chon_lt(b_lp2));
                end loop;
            end if;
        end if;
    end loop;
    select JSON_ARRAYAGG(json_object('ma_lt' value c1,'ma_dk' value c2,'ten' value c3,'so_ids' value b_so_idS)
        order by c1,c2 returning clob) into b_oraOut from temp_2;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_BPHI_TEST(
    b_nv_bh varchar2,b_dt_dk clob,b_dt_dkbs clob,b_dt_lt clob,
    dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,dk_tc out pht_type.a_var,dk_ma_ct out pht_type.a_var,
    dk_ma_dk out pht_type.a_var,dk_ma_dkC out pht_type.a_var,dk_kieu out pht_type.a_var,
    dk_tien out pht_type.a_num,dk_pt out pht_type.a_num,
    dk_phi out pht_type.a_num,dk_lkeM out pht_type.a_var,dk_lkeP out pht_type.a_var,dk_lkeB out pht_type.a_var,
    dk_luy out pht_type.a_var,dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,dk_lh_bh out pht_type.a_var,    
    lt_ma_dk out pht_type.a_var,lt_ma_lt out pht_type.a_var,lt_ten out pht_type.a_nvar,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_lenh varchar2(2000); b_ma varchar2(10); b_ma_ct varchar2(10); b_kt number;
    
    dkB_ma pht_type.a_var; dkB_ten pht_type.a_nvar; dkB_tc pht_type.a_var;
    dkB_ma_ct pht_type.a_var; dkB_ma_dk pht_type.a_var; dkB_ma_dkC pht_type.a_var;
    dkB_ma_dkC pht_type.a_var; dkB_kieu pht_type.a_var; dkB_tien pht_type.a_num; dkB_pt pht_type.a_num;
    dkB_phi pht_type.a_num; dkB_lkeM pht_type.a_var; dkB_lkeP pht_type.a_var; dkB_lkeB pht_type.a_var;
    dkB_luy pht_type.a_var; dkB_lh_nv pht_type.a_var; dkB_t_suat pht_type.a_num;
begin
b_loi:='loi:Loi xu ly PBH_XE_BPHI_TEST:loi';
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
    dk_tc(b_lp):=nvl(trim(dk_tc(b_lp)),'C');
    dk_ma_ct(b_lp):=nvl(trim(dk_ma_ct(b_lp)),' ');
    if dk_ma(b_lp)=dk_ma_ct(b_lp) then b_loi:='loi:Trung ma cap tren ma: '||dk_ma(b_lp)||':loi'; return; end if;
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
        if dk_ma(b_lp)=dk_ma(b_lp1) and dk_tien(b_lp)=dk_tien(b_lp1) then
            b_loi:='loi:Trung ma: '||dk_ma(b_lp)||':loi'; return;
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
    if dk_tc(b_lp)='C' and dk_ma_ct(b_lp)<>' ' then
        b_i1:=0;
        for b_lp1 in 1..dk_ma.count loop
            if dk_ma(b_lp1)=dk_ma_ct(b_lp) and dk_tc(b_lp1)='T' then b_i1:=1; exit; end if;
        end loop;
        if b_i1=0 then b_loi:='loi:Nhap ma cap tren ma: '||dk_ma(b_lp)||':loi'; return; end if;
    end if;
end loop;
for b_lp in 1..dk_ma.count loop
    if dk_tc(b_lp)='C' and dk_ma_ct(b_lp)<>' ' then
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
create or replace procedure PBH_XE_BPHI_XOA_XOA(
    b_ma_dvi varchar2,b_so_id number, b_loi out varchar2)
AS 
begin
-- Dan - Xoa bieu phi
b_loi:='loi:Loi xoa phi:loi';
delete bh_xe_phi_txt where so_id=b_so_id;
delete bh_xe_phi_lt where so_id=b_so_id;
delete bh_xe_phi_dk where so_id=b_so_id;
delete bh_xe_phi where so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_XE_BPHI_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000);

    b_so_id number; b_nhom varchar2(1); b_nv_bh varchar2(10); b_bh_tbo varchar2(1); b_md_sd varchar2(500);
    b_ma_sp varchar2(10); b_cdich varchar2(10); b_goi varchar2(10); 
    b_loai_xe varchar2(500); b_nhom_xe varchar2(500); b_dong varchar2(500); b_dco varchar2(500); 
    b_ttai number; b_so_cn number; b_tuoi number; b_gia number;
    b_ngay_bd number; b_ngay_kt number; b_ngay_hl number;

    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var;
	dk_ma_ct pht_type.a_var; dk_ma_dk pht_type.a_var; dk_ma_dkC pht_type.a_var;
	dk_kieu pht_type.a_var; dk_tien pht_type.a_num; dk_pt pht_type.a_num;
    dk_lkeM pht_type.a_var; dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var; dk_luy pht_type.a_var;
    dk_phi pht_type.a_num; dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num; dk_lh_bh pht_type.a_var;

    lt_ma_dk pht_type.a_var; lt_ma_lt pht_type.a_var; lt_ten pht_type.a_nvar;
    b_dt_ct clob; b_dt_dk clob; b_dt_dkbs clob; b_dt_lt clob; b_dt_khd clob; b_dt_kbt clob;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_dkbs,dt_lt,dt_khd,dt_kbt');
EXECUTE IMMEDIATE b_lenh into b_dt_ct,b_dt_dk,b_dt_dkbs,b_dt_lt,b_dt_khd,b_dt_kbt using b_oraIn;
FKH_JS_NULL(b_dt_ct); FKH_JSa_NULL(b_dt_dk); FKH_JSa_NULL(b_dt_dkbs); FKH_JSa_NULL(b_dt_lt);
FKH_JSa_NULL(b_dt_khd); FKH_JSa_NULL(b_dt_kbt);
PBH_XE_BPHI_TSO(
    b_dt_ct,b_nhom,b_nv_bh,b_bh_tbo,b_md_sd,b_ma_sp,b_cdich,b_goi,b_loai_xe,b_nhom_xe,
    b_dong,b_dco,b_ttai,b_so_cn,b_tuoi,b_gia,b_ngay_bd,b_ngay_kt,b_ngay_hl,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_XE_BPHI_TSOt(b_nhom,b_nv_bh,b_bh_tbo,b_md_sd,b_ma_sp,b_cdich,b_goi,b_loai_xe,b_nhom_xe,b_dong,b_dco,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_XE_BPHI_TEST(b_nv_bh,b_dt_dk,b_dt_dkbs,b_dt_lt,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_ma_dk,dk_ma_dkC,dk_kieu,
    dk_tien,dk_pt,dk_phi,dk_lkeM,dk_lkeP,dk_lkeB,
    dk_luy,dk_lh_nv,dk_t_suat,dk_lh_bh,lt_ma_dk,lt_ma_lt,lt_ten,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if dk_ma.count=0 then b_loi:='loi:Nhap dieu khoan:loi'; raise PROGRAM_ERROR; end if;
-- viet anh
FBH_XE_BPHI_SO_IDj(
    b_nhom,b_nv_bh,b_bh_tbo,b_md_sd,b_ma_sp,b_cdich,b_goi,b_loai_xe,
    b_nhom_xe,b_dong,b_dco,b_ttai,b_so_cn,b_tuoi,b_gia,b_ngay_hl,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id<>0 then
    PBH_XE_BPHI_XOA_XOA(b_ma_dvi,b_so_id,b_loi);
else
    PHT_ID_MOI(b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table bh_xe_phi:loi';
insert into bh_xe_phi values(
    b_ma_dvi,b_so_id,b_nhom,b_nv_bh,b_bh_tbo,b_loai_xe,b_nhom_xe,b_dong,b_dco,b_ttai,b_so_cn,
    b_tuoi,b_gia,b_md_sd,b_ma_sp,b_cdich,b_goi,b_ngay_bd,b_ngay_kt,b_nsd);
for b_lp in 1..dk_ma.count loop
    insert into bh_xe_phi_dk values(b_ma_dvi,b_so_id,b_lp,dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),
        dk_kieu(b_lp),dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),dk_lkeM(b_lp),dk_lkeP(b_lp),dk_lkeB(b_lp),dk_luy(b_lp),
        dk_ma_dk(b_lp),dk_ma_dkC(b_lp),dk_lh_nv(b_lp),dk_t_suat(b_lp),0,dk_lh_bh(b_lp));
end loop;
-- chuclh - khong xoa - neu can thiet tao them index so_id ma ma_ct
for r_lp in(select ma,ma_ct,so_id,bt,level from
    (select t.so_id,t.bt,t.ma,t.ma_ct from bh_xe_phi_dk t where t.so_id = b_so_id) t start with t.ma_ct=' ' CONNECT BY prior t.ma=t.ma_ct) loop
    update bh_xe_phi_dk set cap=r_lp.level where so_id=b_so_id and bt=r_lp.bt;
end loop;
insert into bh_xe_phi_txt values(b_ma_dvi,b_so_id,'dt_ct',b_dt_ct);
insert into bh_xe_phi_txt values(b_ma_dvi,b_so_id,'dt_dk',b_dt_dk);
if trim(b_dt_dkbs) is not null then
    insert into bh_xe_phi_txt values(b_ma_dvi,b_so_id,'dt_dkbs',b_dt_dkbs);
end if;
if lt_ma_lt.count<>0 then
    for b_lp in 1..lt_ma_lt.count loop
        insert into bh_xe_phi_lt values(b_ma_dvi,b_so_id,b_lp,lt_ma_lt(b_lp),lt_ma_dk(b_lp),lt_ten(b_lp));
    end loop;
    insert into bh_xe_phi_txt values(b_ma_dvi,b_so_id,'dt_lt',b_dt_lt);
end if;
if trim(b_dt_khd) is not null then
    insert into bh_xe_phi_txt values(b_ma_dvi,b_so_id,'dt_khd',b_dt_khd);
end if;
if trim(b_dt_kbt) is not null then
    insert into bh_xe_phi_txt values(b_ma_dvi,b_so_id,'dt_kbt',b_dt_kbt);
end if;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_BPHI_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS 
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Dan - Xoa bieu phi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then b_loi:='loi:Chon bieu phi can xoa:loi'; raise PROGRAM_ERROR; end if;
PBH_XE_BPHI_XOA_XOA(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_BPHI_MOs(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_sp clob;
begin
-- Dan- Liet ke san pham
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ten) into cs_sp from bh_xe_sp where FBH_XE_SP_HAN(ma)='C';
select json_object('cs_sp' value cs_sp) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- chuclh tim kiem bieu phi
create or replace procedure PBH_XE_BPHI_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); cs_lke clob; b_dong number;
    b_loai_xe varchar2(200);b_nhom_xe varchar2(200); b_dong_xe varchar2(200); b_dco varchar2(200); b_ttai number; b_so_cn number;
    b_gia number; b_tuoi number; b_md_sd varchar2(100); b_nv_bh varchar2(100); b_tu number; b_den number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('loai_xe,nhom_xe,dong_xe,dco,ttai,so_cn,gia,tuoi,md_sd,nv_bh,tu,den');
EXECUTE IMMEDIATE b_lenh into b_loai_xe,b_nhom_xe,b_dong_xe,b_dco,b_ttai,b_so_cn,b_gia,b_tuoi,b_md_sd,b_nv_bh,b_tu,b_den using b_oraIn;
b_loai_xe:=PKH_MA_TENl(b_loai_xe); b_nhom_xe:=PKH_MA_TENl(b_nhom_xe);
b_dong_xe:=PKH_MA_TENl(b_dong_xe); b_dco:=PKH_MA_TENl(b_dco);
b_md_sd:=PKH_MA_TENl(b_md_sd); b_nv_bh:=PKH_MA_TENl(b_nv_bh);
select count(*) into b_dong from bh_xe_phi
    where b_loai_xe in (' ',loai_xe) and b_nhom_xe in (' ',nhom_xe) and b_dong_xe in (' ',dong) and b_dco in (' ',dco)
    and b_ttai in (0,ttai) and b_so_cn in (0,so_cn) and b_gia in (0,gia) and b_tuoi in (0,tuoi) and b_md_sd in (' ',md_sd)  and b_nv_bh in (' ',nv_bh);
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(
    'ma_sp' value FBH_XE_SP_TEN(ma_sp),'cdich' value FBH_MA_CDICH_TEN(cdich),'goi' value FBH_XE_GOI_TEN(goi),
    nhom,nv_bh,bh_tbo,'md_sd' value FBH_XE_MDSD_TEN(md_sd),
    'loai_xe' value FBH_XE_LOAI_TEN(loai_xe),'nhom_xe' value FBH_XE_NHOM_TEN(nhom_xe),
    'dong' value FBH_XE_DONG_TEN(dong),dco,ttai,so_cn,tuoi,gia,ngay_bd,ngay_kt,so_id  returning clob)
    order by ma_sp,cdich,goi,nhom,nv_bh,bh_tbo,md_sd,loai_xe,nhom_xe,dong,dco,
    ttai,so_cn,tuoi,gia returning clob) into cs_lke from
    (select ma_sp,cdich,goi,nhom,nv_bh,bh_tbo,md_sd,loai_xe,nhom_xe,dong,
    dco,ttai,so_cn,tuoi,gia,ngay_bd,ngay_kt,so_id,rownum sott from bh_xe_phi
    where b_loai_xe in (' ',loai_xe) and b_nhom_xe in (' ',nhom_xe) and b_dong_xe in (' ',dong) and b_dco in (' ',dco)
    and b_ttai in (0,ttai) and b_so_cn in (0,so_cn) and b_gia in (0,gia) and b_tuoi in (0,tuoi) and b_md_sd in (' ',md_sd)  and b_nv_bh in (' ',nv_bh)
    order by cdich,goi,bh_tbo,loai_xe,nhom_xe,dong,dco,ttai,so_cn,tuoi,gia)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_XE_MA_SDBS(b_so_id number) return nvarchar2
as
    b_kq nvarchar2(200);
begin
-- Dan - Tra so id dau
select FKH_JS_GTRIs(FKH_JS_BONH(txt),'ma_sdbs') into b_kq from bh_xe_txt where  so_id=b_so_id and loai='dt_ct';
return b_kq;
end;
/
/*** Ma phu tung ***/
create or replace function FBH_XE_PTU_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_xe_ptu where ma=b_ma and tc='C';
return b_kq;
end;
/
create or replace function FBH_XE_PTU_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_xe_ptu where ma=b_ma and tc='C';
return b_kq;
end;
/
create or replace function FBH_XE_PTU_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_xe_ptu where ma=b_ma and tc='C' and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_XE_PTU_XEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngay number:=PKH_NG_CSO(sysdate); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma) into cs_lke from bh_xe_ptu a where tc='C' and ngay_kt>b_ngay;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_PTU_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_xe_ptu;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep)) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_xe_ptu order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_xe_ptu where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma)) into cs_lke from
        (select a.*,rownum sott from bh_xe_ptu a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_PTU_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(20); b_tim nvarchar2(100); b_hangkt number; -- viet anh -- tang do dai b_ma len 20
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_xe_ptu;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_xe_ptu order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_xe_ptu order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep)) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_xe_ptu order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_xe_ptu where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_xe_ptu where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma)) into cs_lke from
        (select a.*,rownum sott from bh_xe_ptu a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_PTU_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(20):=FKH_JS_GTRIs(b_oraIn,'ma'); cs_ct clob; -- viet anh -- tang do dai b_ma len 20
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma chua nhap hoac da xoa:loi';
select json_object(ma,ten,tc,ma_ct,dvi,ngay_kt) into cs_ct from bh_xe_ptu  where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_PTU_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(20):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_xe_ptu where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_xe_ptu where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_PTU_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(20); b_ten nvarchar2(500); b_tc varchar2(1);
    b_ma_ct varchar2(10); b_dvi nvarchar2(20); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,dvi,ma_ct,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_tc,b_dvi,b_ma_ct,b_ngay_kt using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
b_tc:=nvl(trim(b_tc),'C');
if b_tc<>'C' then b_tc:='T'; end if;
if trim(b_ma_ct) is null then
    b_ma_ct:=' ';
else
    b_loi:='loi:Sai ma cap tren:loi';
    if b_ma=b_ma_ct then raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from bh_xe_ptu where ma=b_ma_ct and tc='T';
end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_xe_ptu where ma=b_ma;
insert into bh_xe_ptu values(b_ma,b_ten,b_tc,b_dvi,b_ma_ct,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** Gia phu tung ***/
create or replace function FBH_XE_GIA_KEY(
    b_hang varchar2,b_hieu varchar2,b_pban varchar2,b_doi number,b_ma varchar2) return varchar2
AS
    b_kq varchar2(100);
begin
-- Dan - Tao key
b_kq:=nvl(trim(b_hang),' ')||'|'||nvl(trim(b_hieu),' ')||'|'||nvl(trim(b_pban),' ')||'|'||to_char(b_doi)||'|'||nvl(trim(b_ma),' ');
return b_kq;
end;
/
create or replace procedure PBH_XE_GIA_TKHAOt(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_maKey varchar2(100);
    b_hang varchar2(20); b_hieu varchar2(20); b_pban varchar2(20); b_doi number;
    b_ma varchar2(20); b_kieu varchar2(1); b_gia number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('hang,hieu,pban,doi,ma,kieu');
EXECUTE IMMEDIATE b_lenh into b_hang,b_hieu,b_pban,b_doi,b_ma,b_kieu using b_oraIn;
b_maKey:=FBH_XE_GIA_KEY(b_hang,b_hieu,b_pban,b_doi,b_ma);
if nvl(trim(b_kieu),' ')='H' then
    select nvl(min(Hptu),0) into b_gia from bh_xe_gia where maKey=b_maKey;
else
    select nvl(min(Nptu),0) into b_gia from bh_xe_gia where maKey=b_maKey;
end if;
select json_object('gia' value b_gia) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_GIA_TKHAOs(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_maKey varchar2(100);
    b_hang varchar2(20); b_hieu varchar2(20); b_pban varchar2(20); b_doi number;
    b_ma varchar2(20); b_kieu varchar2(1); b_lap number; b_sua number; b_son number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('hang,hieu,pban,doi,ma,kieu');
EXECUTE IMMEDIATE b_lenh into b_hang,b_hieu,b_pban,b_doi,b_ma,b_kieu using b_oraIn;
b_maKey:=FBH_XE_GIA_KEY(b_hang,b_hieu,b_pban,b_doi,b_ma);
if nvl(trim(b_kieu),' ')='H' then
    select nvl(min(Hlap),0),nvl(min(Hgo),0),nvl(min(Hson),0) into b_lap,b_sua,b_son from bh_xe_gia where maKey=b_maKey;
else
    select nvl(min(Nlap),0),nvl(min(Ngo),0),nvl(min(Nson),0) into b_lap,b_sua,b_son from bh_xe_gia where maKey=b_maKey;
end if;
select json_object('lap' value b_lap,'sua' value b_sua,'son' value b_son) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_GIA_LSU(
     b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_dvi_ta varchar2(10):=FTBH_DVI_TA();
	b_maKey varchar2(100):=nvl(trim(b_oraIn),' ');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_maKey=' ' then b_loi:='loi:Chon phu tung xem lich su gia:loi'; raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ngay,Hptu,Hlap,Hgo,Hson,Hgia,Nptu,Nlap,Ngo,Nson,Ngia,
	'duyet' value FHT_MA_NSD_TEN(b_dvi_ta,duyet)) order by ngay returning clob) into b_oraOut
	from bh_xe_giaL where maKey=b_maKey;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_GIA_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_dvi_ta varchar2(10):=FTBH_DVI_TA();
	cs_ct clob; b_maKey varchar2(100):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('hang' value FBH_XE_HANG_TENl(hang),'hieu' value FBH_XE_HIEU_TENl(hieu),
    'pban' value FBH_XE_PB_TENl(hang,hieu,pban),doi,'ma' value FBH_XE_PTU_TENl(ma),
	Hptu,Hlap,Hgo,Hson,Hgia,Nptu,Nlap,Ngo,Nson,Ngia,'duyet' value FHT_MA_NSD_TENl(b_dvi_ta,duyet),ngay)
    into cs_ct from bh_xe_gia where maKey=b_maKey;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_GIA_LKE(
     b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_xe_gia;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object('hang' value FBH_XE_HANG_TEN(hang),'hieu' value FBH_XE_HIEU_TEN(hieu),
        'pban' value FBH_XE_PB_TEN(hang,hieu,pban),doi,ten,'ma' value maKey) order by maKey returning clob) into cs_lke from
        (select maKey,hang,hieu,pban,doi,ten,rownum sott from bh_xe_gia order by maKey)
        where sott between b_tu and b_den;
else
	b_tim:='%'||upper(b_tim)||'%';
    select count(*) into b_dong from bh_xe_gia where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object('hang' value FBH_XE_HANG_TEN(hang),'hieu' value FBH_XE_HIEU_TEN(hieu),
        'pban' value FBH_XE_PB_TEN(hang,hieu,pban),doi,ten,'ma' value maKey) order by maKey returning clob) into cs_lke from
        (select maKey,hang,hieu,pban,doi,ten,rownum sott from bh_xe_gia where upper(ten) like b_tim order by maKey)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_GIA_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_tu number; b_den number; b_hangkt number; b_tim nvarchar2(100); b_maKey varchar2(100);
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('makey,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_maKey,b_tim,b_hangkt using b_oraIn;
b_tim:=nvl(trim(b_tim),' ');
if b_tim=' ' then
    select count(*) into b_dong from bh_xe_gia;
    select nvl(min(sott),0) into b_tu from (select maKey,rownum sott from bh_xe_gia order by maKey) where maKey>=b_maKey;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object('hang' value FBH_XE_HANG_TEN(hang),'hieu' value FBH_XE_HIEU_TEN(hieu),
        'pban' value FBH_XE_PB_TEN(hang,hieu,pban),doi,ten,'ma' value maKey) order by maKey returning clob) into cs_lke from
        (select maKey,hang,hieu,pban,doi,ten,rownum sott from bh_xe_gia order by maKey)
        where sott between b_tu and b_den;
else
	b_tim:='%'||upper(b_tim)||'%';
    select count(*) into b_dong from bh_xe_gia where upper(ten) like b_tim;
    select nvl(min(sott),0) into b_tu from (select maKey,rownum sott from bh_xe_gia where upper(ten) like b_tim order by maKey) where maKey>=b_maKey;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object('hang' value FBH_XE_HANG_TEN(hang),'hieu' value FBH_XE_HIEU_TEN(hieu),
        'pban' value FBH_XE_PB_TEN(hang,hieu,pban),doi,ten,'ma' value maKey) order by maKey returning clob) into cs_lke from
        (select maKey,hang,hieu,pban,doi,ten,rownum sott from bh_xe_gia where upper(ten) like b_tim order by maKey)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_GIA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_maKey varchar2(100):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_maKey is null then b_loi:='loi:Chon dong xoa:loi'; raise PROGRAM_ERROR; end if;
delete bh_xe_gia where maKey=b_maKey;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_GIA_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_i1 number; b_lenh varchar2(1000); b_ngayC number;
    b_hang varchar2(20); b_hieu varchar2(20); b_pban varchar2(20); b_doi number; b_ma varchar2(20);
    b_Hptu number; b_Hlap number; b_Hgo number; b_Hson number; b_Hgia number;
    b_Nptu number; b_Nlap number; b_Ngo number; b_Nson number; b_Ngia number;
    b_duyet varchar2(20); b_ngay number; b_maKey varchar2(100); b_ten nvarchar2(500);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('hang,hieu,pban,doi,ma,hptu,hlap,hgo,hson,hgia,nptu,nlap,ngo,nson,ngia,duyet,ngay');
EXECUTE IMMEDIATE b_lenh into b_hang,b_hieu,b_pban,b_doi,b_ma,b_Hptu,b_Hlap,b_Hgo,b_Hson,b_Hgia,
    b_Nptu,b_Nlap,b_Ngo,b_Nson,b_Ngia,b_duyet,b_ngay using b_oraIn;
b_hang:=nvl(trim(b_hang),' '); b_hieu:=nvl(trim(b_hieu),' '); b_pban:=nvl(trim(b_pban),' ');
if b_hang<>' ' and FBH_XE_HANG_HAN(b_hang)<>'C' then b_loi:='loi:Ma hang xe da het han su dung:loi'; raise PROGRAM_ERROR; end if;
if b_hieu<>' ' and FBH_XE_HIEU_HAN(b_hang,b_hieu)<>'C' then b_loi:='loi:Ma hieu xe da het han su dung:loi'; raise PROGRAM_ERROR; end if;
if b_pban<>' ' and FBH_XE_PB_HAN(b_hang,b_hieu,b_pban)<>'C' then b_loi:='loi:Ma phien ban xe da het han su dung:loi'; raise PROGRAM_ERROR; end if;
b_doi:=nvl(b_doi,0);
if b_doi<1900 or b_doi>FKH_NG_NAM(sysdate) then b_doi:=0; end if;
b_ma:=nvl(trim(b_ma),' '); b_ten:=FBH_XE_PTU_TEN(b_ma);
if b_ten is null then b_loi:='loi:Nhap ma phu tung:loi'; raise PROGRAM_ERROR; end if;
if FBH_XE_PTU_HAN(b_ma)<>'C' then b_loi:='loi:Ma phu tung da het han su dung:loi'; raise PROGRAM_ERROR; end if;
b_ngay:=nvl(b_ngay,0);
if b_ngay=0 then b_ngay:=PKH_NG_CSO(sysdate); end if;
b_maKey:=FBH_XE_GIA_KEY(b_hang,b_hieu,b_pban,b_doi,b_ma);
b_loi:='loi:Loi Table bh_xe_gia:loi';
select nvl(min(ngay),0) into b_ngayC from bh_xe_gia where maKey=b_maKey;
if b_ngayC<>0 then
    if b_ngayC<b_ngay then
        delete bh_xe_giaL where maKey=b_maKey and ngay=b_ngayC;
        insert into bh_xe_giaL select maKey,Hptu,Hlap,Hgo,Hson,Hgia,Nptu,Nlap,Ngo,Nson,Ngia,duyet,ngay
            from bh_xe_gia where maKey=b_maKey;
    end if;
    delete bh_xe_gia where maKey=b_maKey;
end if;
insert into bh_xe_gia values(
    b_maKey,b_hang,b_hieu,b_pban,b_doi,b_ma,b_ten,b_Hptu,b_Hlap,b_Hgo,b_Hson,b_Hgia,
    b_Nptu,b_Nlap,b_Ngo,b_Nson,b_Ngia,b_duyet,b_ngay,b_nsd,b_oraIn);
select json_object('ma' value b_maKey) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/




/*** He so gia phu tung theo khu vuc ***/
create or replace procedure PBH_XE_KVUC_LSU(
     b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_dvi_ta varchar2(10):=FTBH_DVI_TA();
	b_ma varchar2(10):=nvl(trim(b_oraIn),' ');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma=' ' then b_loi:='loi:Chon phu tung xem lich su he so gia:loi'; raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ngay,Hptu,Hlap,Hgo,Hson,Hgia,Nptu,Nlap,Ngo,Nson,Ngia,
	'duyet' value FHT_MA_NSD_TEN(b_dvi_ta,duyet)) order by ngay returning clob) into b_oraOut
	from bh_xe_kvucL where ma=b_ma;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_KVUC_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_dvi_ta varchar2(10):=FTBH_DVI_TA();
	cs_ct clob; b_ma varchar2(100):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('ma' value ma||'|'||ten,
	Hptu,Hlap,Hgo,Hson,Hgia,Nptu,Nlap,Ngo,Nson,Ngia,'duyet' value FHT_MA_NSD_TENl(b_dvi_ta,duyet),ngay)
    into cs_ct from bh_xe_kvuc where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_KVUC_LKE(
     b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_xe_kvuc;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ten,ma) order by ma returning clob) into cs_lke from
        (select ma,ten,rownum sott from bh_xe_kvuc order by ma)
        where sott between b_tu and b_den;
else
	b_tim:='%'||upper(b_tim)||'%';
    select count(*) into b_dong from bh_xe_kvuc where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ten,ma) order by ma returning clob) into cs_lke from
        (select ma,ten,rownum sott from bh_xe_kvuc where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_KVUC_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_tu number; b_den number; b_hangkt number; b_tim nvarchar2(100); b_ma varchar2(100);
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
b_tim:=nvl(trim(b_tim),' ');
if b_tim=' ' then
    select count(*) into b_dong from bh_xe_kvuc;
    select nvl(min(sott),0) into b_tu from (select ma,rownum sott from bh_xe_kvuc order by ma) where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ten,ma) order by ma returning clob) into cs_lke from
        (select ma,ten,rownum sott from bh_xe_kvuc order by ma) where sott between b_tu and b_den;
else
	b_tim:='%'||upper(b_tim)||'%';
    select count(*) into b_dong from bh_xe_kvuc where upper(ten) like b_tim;
    select nvl(min(sott),0) into b_tu from (select ma,rownum sott from bh_xe_kvuc where upper(ten) like b_tim order by ma) where ma>=b_ma;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ten,ma) order by ma returning clob) into cs_lke from
        (select ma,ten,rownum sott from bh_xe_kvuc where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_KVUC_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(100):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Chon dong xoa:loi'; raise PROGRAM_ERROR; end if;
delete bh_xe_kvuc where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_KVUC_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_i1 number; b_lenh varchar2(1000); b_ngayC number;
    b_ma varchar2(10); b_duyet varchar2(20); b_ngay number; b_ten nvarchar2(500);
    b_Hptu number; b_Hlap number; b_Hgo number; b_Hson number; b_Hgia number;
    b_Nptu number; b_Nlap number; b_Ngo number; b_Nson number; b_Ngia number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,hptu,hlap,hgo,hson,hgia,nptu,nlap,ngo,nson,ngia,duyet,ngay');
EXECUTE IMMEDIATE b_lenh into b_ma,b_Hptu,b_Hlap,b_Hgo,b_Hson,b_Hgia,
    b_Nptu,b_Nlap,b_Ngo,b_Nson,b_Ngia,b_duyet,b_ngay using b_oraIn;
b_ma:=nvl(trim(b_ma),' '); b_ten:=FBH_MA_KVUC_TEN(b_ma);
if b_ten is null then b_loi:='loi:Nhap ma khu vuc:loi'; raise PROGRAM_ERROR; end if;
b_ngay:=nvl(b_ngay,0);
if b_ngay=0 then b_ngay:=PKH_NG_CSO(sysdate); end if;
b_loi:='loi:Loi Table bh_xe_kvuc:loi';
select nvl(min(ngay),0) into b_ngayC from bh_xe_kvuc where ma=b_ma;
if b_ngayC<>0 then
    if b_ngayC<b_ngay then
        delete bh_xe_kvucL where ma=b_ma and ngay=b_ngayC;
        insert into bh_xe_kvucL select ma,Hptu,Hlap,Hgo,Hson,Hgia,Nptu,Nlap,Ngo,Nson,Ngia,duyet,ngay
            from bh_xe_kvuc where ma=b_ma;
    end if;
    delete bh_xe_kvuc where ma=b_ma;
end if;
insert into bh_xe_kvuc values(
    b_ma,b_ten,b_Hptu,b_Hlap,b_Hgo,b_Hson,b_Hgia,
    b_Nptu,b_Nlap,b_Ngo,b_Nson,b_Ngia,b_duyet,b_ngay,b_nsd);
select json_object('ma' value b_ma) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_KVUC_NHf
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(1000);
    b_ngay number; b_ngayC number;
    a_Hptu pht_type.a_num; a_Hlap pht_type.a_num; a_Hgo pht_type.a_num; a_Hson pht_type.a_num; a_Hgia pht_type.a_num;
    a_Nptu pht_type.a_num; a_Nlap pht_type.a_num; a_Ngo pht_type.a_num; a_Nson pht_type.a_num; a_Ngia pht_type.a_num;
    a_duyet pht_type.a_var; a_ngay pht_type.a_num; a_ten pht_type.a_nvar; a_ma pht_type.a_var;
begin
-- Dan - Nhap tu file
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,hptu,hlap,hgo,hson,hgia,nptu,nlap,ngo,nson,ngia,duyet,ngay');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma,a_Hptu,a_Hlap,a_Hgo,a_Hson,a_Hgia,
    a_Nptu,a_Nlap,a_Ngo,a_Nson,a_Ngia,a_duyet,a_ngay using b_oraIn;
for b_lp in 1..a_ma.count loop
    a_ma(b_lp):=nvl(trim(a_ma(b_lp)),' ');
    if a_ma(b_lp)<>' ' then
        a_ten(b_lp):=FBH_MA_KVUC_TEN(a_ma(b_lp));
        if a_ten(b_lp) is null then
            b_loi:='loi:Ma khu vuc: '||a_ma(b_lp)||' da xoa:loi'; raise PROGRAM_ERROR;
        end if;
        a_ngay(b_lp):=nvl(a_ngay(b_lp),0);
        if a_ngay(b_lp) in(0,30000101) then a_ngay(b_lp):=PKH_NG_CSO(sysdate); end if;
    end if;
end loop;
for b_lp in 1..a_ma.count loop
    if a_ma(b_lp)=' ' then continue; end if;
    b_loi:='loi:Loi Table bh_xe_kvuc:loi';
    select nvl(min(ngay),0) into b_ngayC from bh_xe_kvuc where ma=a_ma(b_lp);
    if b_ngayC<>0 then
        if b_ngayC<b_ngay then
            delete bh_xe_kvucL where ma=a_ma(b_lp) and ngay=b_ngayC;
            insert into bh_xe_kvucL select ma,Hptu,Hlap,Hgo,Hson,Hgia,Nptu,Nlap,Ngo,Nson,Ngia,duyet,ngay
                from bh_xe_kvuc where ma=a_ma(b_lp);
        end if;
        delete bh_xe_kvuc where ma=a_ma(b_lp);
    end if;
    insert into bh_xe_kvuc values(
        a_ma(b_lp),a_ten(b_lp),a_Hptu(b_lp),a_Hlap(b_lp),a_Hgo(b_lp),a_Hson(b_lp),a_Hgia(b_lp),
        a_Nptu(b_lp),a_Nlap(b_lp),a_Ngo(b_lp),a_Nson(b_lp),a_Ngia(b_lp),a_duyet(b_lp),a_ngay(b_lp),b_nsd);
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_BPHId_File_TT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000); b_i1 number;
    ds_ct clob; dt_ds_ct pht_type.a_clob; b_so_idp clob;
    b_loai varchar2(500); b_nhom varchar2(500); b_hang varchar2(500); b_hieu varchar2(500); b_pban varchar2(500); b_mdsd varchar2(500);
begin
  b_lenh:=FKH_JS_LENHc('');
  EXECUTE IMMEDIATE b_lenh bulk collect into dt_ds_ct using b_oraIn;
  b_lenh:=FKH_JS_LENH('loai_xe,nhom_xe,hang,hieu,pban,md_sd');
  for b_lp in 1..dt_ds_ct.count loop
    EXECUTE IMMEDIATE b_lenh into b_loai,b_nhom,b_hang,b_hieu,b_pban,b_mdsd using dt_ds_ct(b_lp);
    b_pban:=FBH_XE_PB_TENl(PKH_MA_TENl(b_hang),PKH_MA_TENl(b_hieu),PKH_MA_TENl(b_pban));
    b_loai:=FBH_XE_LOAI_TENl(PKH_MA_TENl(b_loai));b_nhom:=FBH_XE_NHOM_TENl(PKH_MA_TENl(b_nhom));b_hang:=FBH_XE_HANG_TENl(PKH_MA_TENl(b_hang));
    b_hieu:=FBH_XE_HIEU_TENl(PKH_MA_TENl(b_hieu));b_mdsd:=FBH_XE_MDSD_TENl(PKH_MA_TENl(b_mdsd));
    -- thong tin phi
--     PBH_XE_BPHI_CTs(b_ma_dvi,b_nsd,b_pas,dt_ds_ct(b_lp),b_so_idp);
    PKH_JS_THAYa(dt_ds_ct(b_lp),'loai_xe,nhom_xe,hang,hieu,pban,md_sd',b_loai||','||b_nhom||','||b_hang||','||b_hieu||','|| b_pban||','||b_mdsd); 
  end loop;
  b_oraOut:=FKH_ARRc_JS(dt_ds_ct);
  exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
