-- ma nuoc
create or replace function FBH_MA_NUOC_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Nam
select min(ma||'|'||ten) into b_kq from bh_ma_nuoc where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_MA_NUOCJ_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob, b_oraOut out clob
    )
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ten nvarchar2(100); b_tim nvarchar2(100); b_hangkt number;

    b_trang number;b_dong number;cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ten,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ten,b_tim,b_hangkt using b_oraIn;
if b_ten is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_ma_nuoc;
    if b_dong=0 then
        b_trang:=0;
        select * into cs_lke from dual where 1=2;
    else
        select nvl(min(sott),b_dong) into b_tu from
            (select ten,rownum sott from bh_ma_nuoc order by ten)
            where ten>=b_ten;
        PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);

        select JSON_ARRAYAGG(json_object(ma,ten,nsd,sott) returning clob) into cs_lke from
            (select ma,ten,nsd,rownum sott from bh_ma_nuoc a order by ten) where sott between b_tu and b_den;
    end if;
else
    select count(*) into b_dong from bh_ma_nuoc where upper(ten) like b_tim;
    if b_dong=0 then
        b_trang:=0;
        select * into cs_lke from dual where 1=2;
    else
        select nvl(min(sott),b_dong) into b_tu from (
            select ten,rownum sott from bh_ma_nuoc where upper(ten) like b_tim order by ten)
            where ten>=b_ten;
        PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
        --open cs_lke for select * from
        select JSON_ARRAYAGG(json_object(ma,ten,nsd,sott) returning clob) into cs_lke from
            (select ma,ten,nsd,rownum sott from bh_ma_nuoc a where upper(ten) like b_tim order by ten)
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_NUOCJ_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
b_loi:='';
delete bh_ma_nuoc where ma=b_ma;
insert into bh_ma_nuoc values(b_ma_dvi,b_ma,b_ten,b_nsd);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_NUOCJ_LKE(
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
    select count(*) into b_dong from bh_ma_nuoc;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select * from bh_ma_nuoc order by ma))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_nuoc where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(a.*,'xep' value ma) obj from bh_ma_nuoc a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_NUOCJ_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
    cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma_dvi,ma,ten,nsd) into cs_ct from bh_ma_nuoc where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_NUOCJ_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_ma_nuoc where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--- Ma khu vuc 
create or replace function FBH_MA_KVUC_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_ma_kvuc where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_MA_KVUC_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_ma_kvuc where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_MA_KVUCJ_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob, b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number;cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_ma_kvuc;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma,ten,nsd,xep) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_ma_kvuc order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_kvuc where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(ma,ten,nsd,'xep' value ma) obj from bh_ma_kvuc a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_KVUCJ_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
    cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma_dvi,ma,ten,ma_ct,ngay_kt,nsd) into cs_ct from bh_ma_kvuc where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_KVUCJ_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_ma_ct varchar2(10); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,ma_ct,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_ma_ct,b_ngay_kt using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ma_ct) is null then
    b_ma_ct:=' ';
else
    b_loi:='loi:Sai ma cap tren:loi';
    if b_ma=b_ma_ct then raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from bh_ma_kvuc where ma=b_ma_ct;
end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_ma_kvuc where ma=b_ma;
insert into bh_ma_kvuc values(b_ma_dvi,b_ma,b_ten,b_ma_ct,b_ngay_kt,b_nsd);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_KVUCJ_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_ma_kvuc where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_ma_kvuc where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_KVUCJ_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_trang number;b_dong number;cs_lke clob;
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ten nvarchar2(500); b_tim nvarchar2(100); b_hangkt number;
    b_ma varchar2(10);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_tim,b_hangkt using b_oraIn;
if b_ten is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_ma_kvuc;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_ma_kvuc order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_ma_kvuc order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma,ten,nsd,xep) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep,rownum sott from
                    (select * from bh_ma_kvuc order by ma) a
                    start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_kvuc where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_ma_kvuc where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(ma,ten,nsd,'xep' value ma) obj from bh_ma_kvuc a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- ty gia
create or replace procedure PTT_TGTTJ_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2, b_oraIn clob)
AS
	b_loi varchar2(100); b_i1 number; b_idvung number:=0; b_lenh varchar2(1000);
  b_ma varchar2(10);b_ngay date;b_ty_gia number;
begin
-- Dan - Nhap ty gia thuc te
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ngay,ty_gia');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ngay,b_ty_gia using b_oraIn;

--PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','TT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null or b_ma=FTT_TRA_NOITE(b_ma_dvi) then b_loi:='loi:Sai ma ngoai te:loi'; raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
b_ngay:= TO_CHAR(TO_DATE(b_ngay, 'DD/MM/YYYY'), 'MM/DD/YYYY');
b_loi:='loi:Ma ngoai te chua dang ky:loi';
select 0 into b_i1 from tt_ma_nt where ma_dvi=b_ma_dvi and ma=b_ma;
if b_ty_gia<=0 then b_loi:='loi:Sai ty gia phai:loi'; raise PROGRAM_ERROR;end if;
b_loi:='loi:Va cham NSD:loi';
delete tt_tgtt where ma_dvi=b_ma_dvi and ma=b_ma and ngay=b_ngay;
insert into tt_tgtt values (b_ma_dvi,b_ma,b_ngay,b_ty_gia,b_nsd,b_idvung);
/*
--Nhap ty gia cho toan bo cong ty
delete tt_tgtt where ma=b_ma and ngay=b_ngay;
for b_lp in (select distinct ma_dvi from kt_sc) loop
	insert into tt_tgtt values (b_lp.ma_dvi,b_ma,b_ngay,b_ty_gia,b_nsd);
end loop;
*/
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--ma don vi
create or replace function FHT_MA_DVI_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(100);
begin
-- Dan
select min(ten) into b_kq from ht_ma_dvi where ma=b_ma;
return b_kq;
end;
/
create or replace function FHT_MA_DVI_QLY (b_ma varchar2) return varchar2
AS
    b_kq varchar2(20);
begin
-- Dan - Tra don vi cao nhat
select min(ma_ct) into b_kq from ht_ma_dvi where ma=b_ma;
return b_kq;
end;
/
create or replace function fht_ma_dvi_teng (b_ma varchar2) return nvarchar2
as
    b_kq nvarchar2(100);
begin
-- dan - tra ten gon
select ten_gon into b_kq from ht_ma_dvi where ma=b_ma;
return b_kq;
end;
/
create or replace function fht_ma_phong_ten (b_ma_dvi varchar2,b_ma varchar2) return nvarchar2
as
    b_kq varchar2(200);
begin
-- dan - tra ten phong
select nvl(min(ten),' ') into b_kq from ht_ma_phong where ma_dvi=b_ma_dvi and ma=b_ma;
return b_kq;
end;
/
create or replace function FHT_MA_CB_TEN (b_ma_dvi varchar2,b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(100);
begin
-- Dan - Tra ten cua can bo
select min(ten) into b_kq from ht_ma_cb where ma_dvi=b_ma_dvi and ma=b_ma;
return b_kq;
end;

/
create or replace function FBH_PKT_SP_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ten) into b_kq from bh_pkt_sp where ma=b_ma;
return b_kq;
end;