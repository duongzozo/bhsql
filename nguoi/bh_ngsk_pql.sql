-- Thoi gian cho
create or replace function FBH_SK_CHO_TEN(b_ma varchar2,b_dk varchar2:='C') return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan - Tra ten
select min(ten) into b_kq from bh_sk_cho where ma=b_ma and tc in('C',b_dk);
return b_kq;
end;
/
create or replace function FBH_SK_CHO_TENl(b_ma varchar2,b_dk varchar2:='C') return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan - Tra ten
select min(ma||'|'||ten) into b_kq from bh_sk_cho where ma=b_ma and tc in('C',b_dk);
return b_kq;
end;
/
create or replace function FBH_SK_CHO_HAN(b_ma varchar2,b_dk varchar2:='C') return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con dung
select count(*) into b_i1 from bh_sk_cho where ma=b_ma and tc in('C',b_dk) and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_SK_CHO_LKE(
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
    select count(*) into b_dong from bh_sk_cho;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma,ten,so_ngay,xep) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_sk_cho order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_sk_cho where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(ma,ten,so_ngay,'xep' value ma) obj from bh_sk_cho a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_CHO_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_sk_cho;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_sk_cho order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_sk_cho order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma,ten,so_ngay,xep) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep,rownum sott from
                    (select * from bh_sk_cho order by ma) a
                    start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_sk_cho where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_sk_cho where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(ma,ten,so_ngay,'xep' value ma) obj from bh_sk_cho a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_CHO_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
    cs_ct clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is not null then
    b_loi:='loi:Ma da xoa:loi';
    select json_object(ma,txt returning clob) into cs_ct from bh_sk_cho where ma=b_ma;
end if;
select json_object('cs_ct' value cs_ct returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_CHO_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(1000); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_tc varchar2(1); b_ma_ct varchar2(10);
    b_ngay_bd number; b_ngay_kt number; b_muc number; b_so_ngay number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,so_ngay,ngay_bd,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_tc,b_ma_ct,b_so_ngay,b_ngay_bd,b_ngay_kt using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
b_tc:=nvl(trim(b_tc),'C'); b_ma_ct:=nvl(trim(b_ma_ct),' ');
if b_ma_ct<>' ' then
    b_loi:='loi:Sai ma cap tren:loi';
    if b_ma=b_ma_ct then raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from bh_sk_cho where ma=b_ma_ct and tc='T';
end if;
if b_tc='C' then
    b_muc:=nvl(trim(b_muc),1);
else
    b_muc:=0;
end if;
if b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_sk_cho where ma=b_ma;
insert into bh_sk_cho values(b_ma_dvi,b_ma,b_ten,b_tc,b_ma_ct,b_so_ngay,b_ngay_bd,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_CHO_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn cLob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_sk_cho where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_sk_cho where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** Ma pthuat ***/
create or replace function FBH_SK_PTHUAT_TEN(b_ma varchar2,b_dk varchar2:='C') return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan - Tra ten
select min(ten) into b_kq from bh_sk_pthuat where ma=b_ma and tc in('C',b_dk);
return b_kq;
end;
/
create or replace function FBH_SK_PTHUAT_TENl(b_ma varchar2,b_dk varchar2:='C') return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan - Tra ten
select min(ma||'|'||ten) into b_kq from bh_sk_pthuat where ma=b_ma and tc in('C',b_dk);
return b_kq;
end;
/
create or replace function FBH_SK_PTHUAT_HAN(b_ma varchar2,b_dk varchar2:='C') return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con dung
select count(*) into b_i1 from bh_sk_pthuat where ma=b_ma and tc in('C',b_dk) and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_SK_PTHUAT_LKE(
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
    select count(*) into b_dong from bh_sk_pthuat;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma,ten,tlbtM,tlbtX,nsd,xep) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_sk_pthuat order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_sk_pthuat where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(ma,ten,tlbtM,tlbtX,nsd,'xep' value ma) obj from bh_sk_pthuat a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_PTHUAT_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_sk_pthuat;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_sk_pthuat order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_sk_pthuat order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma,ten,tlbtM,tlbtX,nsd,xep) obj,rownum sott from
        (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep,rownum sott from
        (select * from bh_sk_pthuat order by ma) a
        start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_sk_pthuat where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_sk_pthuat where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(ma,ten,tlbtM,tlbtX,nsd,'xep' value ma) obj from bh_sk_pthuat a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_PTHUAT_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
    cs_ct clob:=''; cs_dk clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is not null then
    b_loi:='loi:Ma da xoa:loi';
    select json_object(ma,txt returning clob) into cs_ct from bh_sk_pthuat where ma=b_ma;
end if;
select json_object('cs_ct' value cs_ct,'cs_dk' value cs_dk returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_PTHUAT_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(1000); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_tc varchar2(1); b_ma_ct varchar2(10);
    b_ngay_kt number; b_tlbtM number; b_tlbtX number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,ngay_kt,tlbtm,tlbtx');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_tc,b_ma_ct,b_ngay_kt,b_tlbtM,b_tlbtX using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
b_tc:=nvl(trim(b_tc),'C'); b_ma_ct:=nvl(trim(b_ma_ct),' ');
if b_ma_ct<>' ' then
    b_loi:='loi:Sai ma cap tren:loi';
    if b_ma=b_ma_ct then raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from bh_sk_pthuat where ma=b_ma_ct and tc='T';
end if;
b_tlbtM:=nvl(b_tlbtM,0); b_tlbtX:=nvl(b_tlbtX,0);
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
delete bh_sk_pthuat where ma=b_ma;
insert into bh_sk_pthuat values(b_ma_dvi,b_ma,b_ten,b_tc,b_ma_ct,b_tlbtM,b_tlbtX,b_ngay_kt,b_nsd,b_oraIn);
commit;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_PTHUAT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn cLob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_sk_pthuat where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_sk_pthuat where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_PTHUAT_CAY(b_ma varchar2,b_tim nvarchar2)
AS
    b_maN varchar2(50); b_timB nvarchar2(100);
begin
-- viet anh - Liet ke theo cay
-- chua dung y a Dan doi sua lai sau
b_timB:=FKH_BO_UNICODE(b_tim,'C','C');
insert into kh_cay select ma,ten,tc,to_char(tlbtM)||'-'||to_char(tlbtX) muc 
       from bh_sk_pthuat where ma_ct=b_ma 
          and (b_timB = ' ' or FKH_BO_UNICODE(ten,'C','C') like '%' || b_timB || '%')
          and FBH_SK_PTHUAT_HAN(ma,'T')='C' order by ten;
end;
/
/* Ty le thuong tat */
create or replace function FBH_SK_TTTL_TEN(b_ma varchar2,b_dk varchar2:='C') return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan - Tra ten
select min(ten) into b_kq from bh_sk_tttl where ma=b_ma and tc in('C',b_dk);
return b_kq;
end;
/
create or replace function FBH_SK_TTTL_TENl(b_ma varchar2,b_dk varchar2:='C') return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan - Tra ten
select min(ma||'|'||ten) into b_kq from bh_sk_tttl where ma=b_ma and tc in('C',b_dk);
return b_kq;
end;
/
create or replace function FBH_SK_TTTL_HAN(b_ma varchar2,b_dk varchar2:='C') return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con dung
select count(*) into b_i1 from bh_sk_tttl where ma=b_ma and tc in('C',b_dk) and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_SK_TTTL_LKE(
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
    select count(*) into b_dong from bh_sk_tttl;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma,ten,tlbtM,tlbtX,nsd,xep) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_sk_tttl order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_sk_tttl where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(ma,ten,tlbtM,tlbtX,nsd,'xep' value ma) obj from bh_sk_tttl a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_TTTL_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_sk_tttl;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_sk_tttl order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_sk_tttl order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma,ten,tlbtM,tlbtX,nsd,xep) obj,rownum sott from
        (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep,rownum sott from
        (select * from bh_sk_tttl order by ma) a
        start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_sk_tttl where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_sk_tttl where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(ma,ten,tlbtM,tlbtX,nsd,'xep' value ma) obj from bh_sk_tttl a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_TTTL_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
    cs_ct clob:=''; cs_dk clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is not null then
    b_loi:='loi:Ma da xoa:loi';
    select json_object(ma,txt returning clob) into cs_ct from bh_sk_tttl where ma=b_ma;
end if;
select json_object('cs_ct' value cs_ct,'cs_dk' value cs_dk returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_TTTL_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(1000); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_tc varchar2(1); b_ma_ct varchar2(10);
    b_ngay_kt number; b_tlbtM number; b_tlbtX number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,ngay_kt,tlbtm,tlbtx');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_tc,b_ma_ct,b_ngay_kt,b_tlbtM,b_tlbtX using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
b_tc:=nvl(trim(b_tc),'C'); b_ma_ct:=nvl(trim(b_ma_ct),' ');
if b_ma_ct<>' ' then
    b_loi:='loi:Sai ma cap tren:loi';
    if b_ma=b_ma_ct then raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from bh_sk_tttl where ma=b_ma_ct and tc='T';
end if;
b_tlbtM:=nvl(b_tlbtM,0); b_tlbtX:=nvl(b_tlbtX,0);
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
delete bh_sk_tttl where ma=b_ma;
insert into bh_sk_tttl values(b_ma_dvi,b_ma,b_ten,b_tc,b_ma_ct,b_tlbtM,b_tlbtX,b_ngay_kt,b_nsd,b_oraIn);
commit;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_TTTL_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn cLob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_sk_tttl where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_sk_tttl where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_TTTL_CAY(
    b_ma varchar2, b_tim nvarchar2
)
AS
    b_maN varchar2(50); b_timB nvarchar2(100);
begin
-- viet anh - Liet ke theo cay -- them tim kiem
-- chua dung y a Dan doi sua lai sau
b_timB:=FKH_BO_UNICODE(b_tim,'C','C');
insert into kh_cay select ma,ten,tc,to_char(tlbtM)||'-'||to_char(tlbtX) muc 
    from bh_sk_tttl where ma_ct=b_ma 
          and (b_timB = ' ' or FKH_BO_UNICODE(ten,'C','C') like '%' || b_timB || '%')
          and FBH_SK_TTTL_HAN(ma,'T')='C' order by ten;
end;

/
/*** Ma benh ***/
create or replace function FBH_SK_BENH_TEN(b_ma varchar2,b_dk varchar2:='C') return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan - Tra ten
select min(ten) into b_kq from bh_sk_benh where ma=b_ma and tc in('C',b_dk);
return b_kq;
end;
/
create or replace function FBH_SK_BENH_TENl(b_ma varchar2,b_dk varchar2:='C') return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan - Tra ten
select min(ma||'|'||ten) into b_kq from bh_sk_benh where ma=b_ma and tc in('C',b_dk);
return b_kq;
end;
/
create or replace function FBH_SK_BENH_HAN(b_ma varchar2,b_dk varchar2:='C') return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con dung
select count(*) into b_i1 from bh_sk_benh where ma=b_ma and tc in('C',b_dk) and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_SK_BENH_LKE(
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
    select count(*) into b_dong from bh_sk_benh;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma,ten,nsd,xep) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_sk_benh order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_sk_benh where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(ma,ten,nsd,'xep' value ma) obj from bh_sk_benh a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_BENH_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=1; b_dong number:=0; cs_lke clob:=''; cs_dk clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_sk_benh;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_sk_benh order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_sk_benh order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma,ten,nsd,xep) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep,rownum sott from
                    (select * from bh_sk_benh order by ma) a
                    start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
    select JSON_ARRAYAGG(obj returning clob) into cs_dk from
		(select json_object(ma,ngay_bd,muc) obj from bh_sk_benhL where ma=b_ma order by ngay_bd desc);
else
    select count(*) into b_dong from bh_sk_benh where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_sk_benh where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(ma,ten,nsd,'xep' value ma) obj from bh_sk_benh a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
    select JSON_ARRAYAGG(obj returning clob) into cs_dk from
		(select json_object(ma,ngay_bd,muc) obj from bh_sk_benhL where ma=b_ma order by ngay_bd desc);
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke, 'cs_dk' value cs_dk) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_BENH_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
    cs_ct clob:=''; cs_dk clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is not null then
	b_loi:='loi:Ma da xoa:loi';
	select json_object(ma,txt returning clob) into cs_ct from bh_sk_benh where ma=b_ma;
	select JSON_ARRAYAGG(obj returning clob) into cs_dk from
		(select json_object(ma,ngay_bd,muc) obj from bh_sk_benhL where ma=b_ma order by ngay_bd desc);
end if;
select json_object('cs_ct' value cs_ct,'cs_dk' value cs_dk returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_BENH_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(1000); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_tc varchar2(1); b_ma_ct varchar2(10);
    b_ngay_bd number; b_ngay_kt number; b_muc number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,ngay_bd,ngay_kt,muc');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_tc,b_ma_ct,b_ngay_bd,b_ngay_kt,b_muc using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
b_tc:=nvl(trim(b_tc),'C'); b_ma_ct:=nvl(trim(b_ma_ct),' ');
if b_ma_ct<>' ' then
    b_loi:='loi:Sai ma cap tren:loi';
    if b_ma=b_ma_ct then raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from bh_sk_benh where ma=b_ma_ct and tc='T';
end if;
if b_tc='C' then
    b_muc:=nvl(trim(b_muc),1);
else
    b_muc:=0;
end if;
if b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
if b_tc='C' then
    delete bh_sk_benhL where ma=b_ma and ngay_bd=b_ngay_bd;
    insert into bh_sk_benhL select ma,ngay_bd,muc
        from bh_sk_benh where ma=b_ma and ngay_bd<>b_ngay_bd;
end if;
delete bh_sk_benh where ma=b_ma;
insert into bh_sk_benh values(b_ma_dvi,b_ma,b_ten,b_tc,b_ma_ct,b_muc,b_ngay_bd,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_BENH_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn cLob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_sk_benh where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_sk_benhL where ma=b_ma;
delete bh_sk_benh where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_BENH_CAY(b_ma varchar2, b_tim nvarchar2)
AS
    b_maN varchar2(50); b_timB nvarchar2(100);
begin
-- viet anh - Liet ke theo cay
-- chua dung y a Dan doi sua lai sau
b_timB:=FKH_BO_UNICODE(b_tim,'C','C');
insert into kh_cay select ma,ten,tc,to_char(muc) from bh_sk_benh where ma_ct=b_ma 
          and (b_timB = ' ' or FKH_BO_UNICODE(ten,'C','C') like '%' || b_timB || '%')
          and FBH_SK_BENH_HAN(ma,'T')='C' order by ten;
end;
/
-- Ty le phi / tgian BH
create or replace function FBH_SK_TLTG_HAN(b_tltg number) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con dung
select count(*) into b_i1 from bh_sk_tltg where tltg=b_tltg and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_SK_TLTG_TLE(b_ngay_hl number,b_ngay_kt number) return number
AS
    b_kq number:=0; b_i1 number; b_th number:=FKH_KHO_THSO(b_ngay_hl,b_ngay_kt); b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Tra ty le phi < 12 thang
if b_th<12 then
    select nvl(max(tltg),0) into b_i1 from bh_sk_tltg where tltg<=b_th and b_ngay between ngay_bd and ngay_kt;
    if b_i1<>0 then
        select tlph into b_kq from bh_sk_tltg where tltg=b_i1 and b_ngay between ngay_bd and ngay_kt;
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
create or replace procedure PBH_SK_TLTG_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_tltg number:=FKH_JS_GTRIs(b_oraIn,'tltg');
    cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Thoi gian da xoa:loi';
select json_object(tltg,tlph,ngay_bd,ngay_kt) into cs_ct from bh_sk_tltg where tltg=b_tltg;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_TLTG_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(tltg,tlph,nsd) order by tltg) into cs_lke from bh_sk_tltg;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_TLTG_NH
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
delete bh_sk_tltg where tltg=b_tltg;
insert into bh_sk_tltg values(b_ma_dvi,b_tltg,b_tlph,b_ngay_bd,b_ngay_kt,b_nsd);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_TLTG_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn cLob)
AS
    b_loi varchar2(100); b_tltg number:=FKH_JS_GTRIs(b_oraIn,'tltg');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_tltg is null then b_loi:='loi:Nhap thoi gian:loi'; raise PROGRAM_ERROR; end if;
delete bh_sk_tltg where tltg=b_tltg;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_TLTG_TLE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_ngay_hl number; b_ngay_kt number; b_tlph number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_bd,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ngay_hl,b_ngay_kt using b_oraIn;
b_tlph:=FBH_SK_TLTG_TLE(b_ngay_hl,b_ngay_kt);
select json_object('tlph' value b_tlph) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- ty le giam phi toi da / so nguoi
create or replace function FBH_SK_TLGI_HAN(b_so_ng number) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con dung
select count(*) into b_i1 from bh_sk_tlgi where so_ng=b_so_ng and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_SK_TLGI_TLE(b_ngay_hl number,b_ngay_kt number) return number
AS
    b_kq number:=0; b_i1 number; b_th number:=FKH_KHO_THSO(b_ngay_hl,b_ngay_kt); b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Tra ty le phi < 12 thang
if b_th<12 then
    select nvl(max(so_ng),0) into b_i1 from bh_sk_tlgi where so_ng<=b_th and b_ngay between ngay_bd and ngay_kt;
    if b_i1<>0 then
        select tl_giam into b_kq from bh_sk_tlgi where so_ng=b_i1 and b_ngay between ngay_bd and ngay_kt;
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
create or replace procedure PBH_SK_TLGI_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_ng number:=FKH_JS_GTRIs(b_oraIn,'so_ng');
    cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Thoi gian da xoa:loi';
select json_object(so_ng,tl_giam,ngay_bd,ngay_kt) into cs_ct from bh_sk_tlgi where so_ng=b_so_ng;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_TLGI_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(so_ng,tl_giam,nsd) order by so_ng) into cs_lke from bh_sk_tlgi;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_TLGI_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000);
    b_so_ng number; b_tl_giam number; b_ngay_bd number; b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_ng,tl_giam,ngay_bd,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_so_ng,b_tl_giam,b_ngay_bd,b_ngay_kt using b_oraIn;
if b_so_ng is null then b_loi:='loi:Nhap so thang:loi'; raise PROGRAM_ERROR; end if;
if b_tl_giam is null then b_loi:='loi:Nhap ty le phi:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
delete bh_sk_tlgi where so_ng=b_so_ng;
insert into bh_sk_tlgi values(b_ma_dvi,b_so_ng,b_tl_giam,b_ngay_bd,b_ngay_kt,b_nsd);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_TLGI_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn cLob)
AS
    b_loi varchar2(100); b_so_ng number:=FKH_JS_GTRIs(b_oraIn,'so_ng');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_ng is null then b_loi:='loi:Nhap thoi gian:loi'; raise PROGRAM_ERROR; end if;
delete bh_sk_tlgi where so_ng=b_so_ng;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_TLGI_TLE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_ngay_hl number; b_ngay_kt number; b_tl_giam number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_hl,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ngay_hl,b_ngay_kt using b_oraIn;
b_tl_giam:=FBH_SK_TLGI_TLE(b_ngay_hl,b_ngay_kt);
select json_object('tl_giam' value b_tl_giam) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* Goi */
create or replace function FBH_SK_GOI_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_sk_goi where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_SK_GOI_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_sk_goi where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_SK_GOI_LKE(       
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
    select count(*) into b_dong from bh_sk_goi;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select * from bh_sk_goi order by ma))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_sk_goi where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(a.*,'xep' value ma) obj from bh_sk_goi a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_GOI_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_sk_goi;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_sk_goi;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_GOI_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,ngay_kt) into b_kq from bh_sk_goi where ma=b_ma;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_GOI_NH
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
delete bh_sk_goi where ma=b_ma;
insert into bh_sk_goi values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_GOI_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_sk_goi where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* Ma san pham */
create or replace function FBH_SK_SP_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ten) into b_kq from bh_sk_sp where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_SK_SP_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_sk_sp where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_SK_SP_HAN(b_ma varchar2,b_dk varchar2:='C') return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_sk_sp where ma=b_ma and tc in('C',b_dk) and ngay_bd<=b_ngay and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_SK_SP_DSACH(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='C'; b_i1 number; b_txt clob;
begin
-- Dan
select count(*) into b_i1 from bh_sk_sp where ma=b_ma;
if b_i1=1 then
    select txt into b_txt from bh_sk_sp where ma=b_ma;
    b_kq:=nvl(FKH_JS_GTRIs(b_txt,'dsach'),'C');
end if;
return b_kq;
exception when others then return 'C';
end;
/
create or replace procedure PBH_SK_SP_DSACH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=trim(b_oraIn);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_oraOut:=FBH_SK_SP_DSACH(b_ma);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_SK_SP_CCCD(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='C'; b_i1 number; b_txt clob;
begin
-- nampb
select count(*) into b_i1 from bh_sk_sp where ma=b_ma;
if b_i1=1 then
    select txt into b_txt from bh_sk_sp where ma=b_ma;
    b_kq:=nvl(FKH_JS_GTRIs(b_txt,'cccd'),'C');
end if;
return b_kq;
exception when others then return 'C';
end;
/
create or replace procedure PBH_SK_SP_LKE(
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
    select count(*) into b_dong from bh_sk_sp;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_sk_sp order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_sk_sp where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(a.*,'xep' value ma) obj from bh_sk_sp a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_SP_MA(
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
    select count(*) into b_dong from bh_sk_sp;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_sk_sp order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_sk_sp order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep,rownum sott from
                (select * from bh_sk_sp order by ma) a
                start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_sk_sp where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_sk_sp where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(a.*,'xep' value ma) obj from bh_sk_sp a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_SP_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma'); cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,txt returning clob) into cs_ct from bh_sk_sp where ma=b_ma;
select json_object('cs_ct' value cs_ct returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_SP_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_tc varchar2(1);
    b_ma_ct varchar2(10); b_ngay_bd number; b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,ngay_bd,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_tc,b_ma_ct,b_ngay_bd,b_ngay_kt using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_tc is null or b_tc<>'T' then b_tc:='C'; end if;
if trim(b_ma_ct) is null then
    b_ma_ct:=' ';
else
    b_loi:='loi:Sai ma cap tren:loi';
    if b_ma=b_ma_ct then raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from bh_sk_sp where ma=b_ma_ct and tc='T';
end if;
if b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_sk_sp where ma=b_ma;
insert into bh_sk_sp values(b_ma_dvi,b_ma,b_ten,b_tc,b_ma_ct,b_ngay_bd,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_SP_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_sk_sp where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_sk_sp where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* bieu phi suc khoe*/
create or replace function FBH_SK_BPHI_DK_TSO(b_so_id number,b_ma varchar2,b_ten varchar2) return varchar2
AS
    b_kq varchar2(2000):=''; b_lenh varchar2(2000); b_i1 number; b_dk clob;
    dk_ma pht_type.a_var; dk_gtri pht_type.a_var; 
begin
-- Dan - Tra tham so dieu khoan cua bieu phi
select count(*) into b_i1 from bh_sk_phi_txt where so_id=b_so_id and loai='dt_dk';
if b_i1<>0 then
    select txt into b_dk from bh_sk_phi_txt where so_id=b_so_id and loai='dt_dk';
    b_dk:=substr(b_dk,2,length(b_dk)-2);
    b_lenh:=FKH_JS_LENH('ma,'||b_ten);
    EXECUTE IMMEDIATE b_lenh bulk collect into dk_ma,dk_gtri using b_dk;
    b_i1:=FKH_ARR_VTRI(dk_ma,b_ma);
    if b_i1<>0 then b_kq:=dk_gtri(b_i1); end if;
end if;
return b_kq;
end;
/
create or replace function FBH_SK_BPHI_SO_ID(
    b_nhom varchar2,b_ma_sp varchar2,b_cdich varchar2,b_goi varchar2,
	b_tuoiN number,b_luongN number,b_ngay_hl number:=0) return number
AS
    b_so_id number:=0; b_tuoi number; b_luong number; b_ngay number:=b_ngay_hl;
begin
-- Dan - Tra so ID phi gan nhat
if b_ngay in(0,30000101) then b_ngay:=PKH_NG_CSO(sysdate); end if;
select nvl(max(tuoi),-1),nvl(max(luong),0) into b_tuoi,b_luong from bh_sk_phi where
    nhom=b_nhom and ma_sp=b_ma_sp and cdich=b_cdich and goi=b_goi and
    tuoi<=b_tuoiN and luong<=b_luongN and b_ngay between ngay_bd and ngay_kt;
if b_tuoi>=0 then
    select nvl(max(so_id),0) into b_so_id from bh_sk_phi where
        nhom=b_nhom and ma_sp=b_ma_sp and cdich=b_cdich and goi=b_goi and
        tuoi=b_tuoi and luong=b_luong and b_ngay between ngay_bd and ngay_kt;
end if;
return b_so_id;
end;
/
create or replace function FBH_SK_BPHI_SO_IDd(
    b_nhom varchar2,b_ma_sp varchar2,b_cdich varchar2,b_goi varchar2,b_tuoi number,b_luong number) return number
AS
    b_so_id number;
begin
-- Dan - Tra so ID phi dung
select nvl(max(so_id),0) into b_so_id from bh_sk_phi where
    nhom=b_nhom and ma_sp=b_ma_sp and cdich=b_cdich and goi=b_goi and tuoi=b_tuoi and luong=b_luong;
return b_so_id;
end;
/
create or replace function FBH_SK_BPHI_SO_IDh(
    b_nhom varchar2,b_ma_sp varchar2,b_cdich varchar2,b_goi varchar2,
	b_ng_sinh number,b_luong number,b_ngay_hl number:=0) return number
AS
    b_ngay number:=b_ngay_hl; b_so_id number; b_tuoi number;
begin
-- Dan - Tra so ID con han su dung
if b_ngay in(0,30000101) then b_ngay:=PKH_NG_CSO(sysdate); end if;
if b_nhom='T' then
    b_tuoi:=b_ng_sinh;
else
    b_tuoi:=FKH_KHO_NASO(b_ng_sinh,b_ngay);
    if b_tuoi < 0 then b_tuoi:=0; end if;
end if;
b_so_id:=FBH_SK_BPHI_SO_ID(b_nhom,b_ma_sp,b_cdich,b_goi,b_tuoi,b_luong,b_ngay);
return b_so_id;
end;
/
create or replace function FBH_SK_BPHI_HAN(b_so_id number,b_ngay_hl number) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number;
begin
-- Dan - Tra so ID phi dung
select count(*) into b_i1 from bh_sk_phi where so_id=b_so_id and b_ngay_hl between ngay_bd and ngay_kt;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_SK_GOI_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ten) into b_kq from bh_sk_goi where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_SK_BPHI_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_sp clob; cs_cdich clob; cs_goi clob; cs_lt clob; cs_khd clob; cs_kbt clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten returning clob) order by ten returning clob) into cs_sp from bh_sk_sp where FBH_SK_SP_HAN(ma)='C';
select JSON_ARRAYAGG(json_object(ma,ten returning clob) order by ten returning clob) into cs_cdich
    from bh_ma_cdich where FBH_MA_NV_CO(nv,'NG')='C' and FBH_MA_CDICH_HAN(ma)='C';
select JSON_ARRAYAGG(json_object(ma,ten returning clob) order by ma returning clob) into cs_goi from bh_sk_goi where FBH_SK_GOI_HAN(ma)='C';
select JSON_ARRAYAGG(json_object(ma_dk,ten,'ma_lt' value ma) returning clob) into cs_lt
    from bh_ma_dklt a where FBH_MA_NV_CO(nv,'NG')='C' and FBH_MA_DKLT_HAN(ma_dk,ma)='C';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra returning clob) order by bt returning clob) into cs_khd from bh_kh_ttt where ps='KHD' and FBH_MA_NV_CO(nv,'NG')='C';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra returning clob) order by bt returning clob) into cs_kbt from bh_kh_ttt where ps='KBT' and FBH_MA_NV_CO(nv,'NG')='C';
select json_object('cs_sp' value cs_sp,'cs_cdich' value cs_cdich,'cs_goi' value cs_goi,
    'cs_lt' value cs_lt,'cs_khd' value cs_khd,'cs_kbt' value cs_kbt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_BPHI_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_so_id number;
    b_nhom varchar2(1); b_ma_sp varchar2(10); b_cdich varchar2(10);
	b_goi varchar2(10); b_tuoi number; b_luong number;
begin
-- Dan - Tra so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nhom,ma_sp,cdich,goi,tuoi,luong');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_ma_sp,b_cdich,b_goi,b_tuoi,b_luong using b_oraIn;
if trim(b_ma_sp) is null then
    b_so_id:=0;
else
    b_cdich:=nvl(b_cdich,' '); b_goi:=nvl(b_goi,' '); b_tuoi:=nvl(b_tuoi,0); b_luong:=nvl(b_luong,0);
    b_so_id:=FBH_SK_BPHI_SO_ID(b_nhom,b_ma_sp,b_cdich,b_goi,b_tuoi,b_luong);
end if;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_BPHI_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_tu number; b_den number;
     b_nhom varchar2(10); b_ma_sp varchar2(20); b_goi varchar2(20);
     b_dong number; cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nhom,ma_sp,goi,tu,den');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_ma_sp,b_goi,b_tu,b_den using b_oraIn;
b_nhom:=nvl(trim(b_nhom),' '); b_ma_sp:=nvl(trim(b_ma_sp),' '); b_goi:=nvl(trim(b_goi),' '); 
--viet anh
select count(*) into b_dong from 
       (select so_id,nhom,ma_sp,cdich,tuoi,goi,ROW_NUMBER() over(ORDER BY nhom,ma_sp,goi,cdich,tuoi) as sott from bh_sk_phi
    where b_nhom in(' ',nhom) and b_ma_sp in(' ',ma_sp) and b_goi in(' ',goi));
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(so_id,nhom,'ma_sp' value FBH_SK_SP_TEN(ma_sp),
    'cdich' value FBH_MA_CDICH_TEN(cdich),tuoi,luong,'goi' value FBH_SK_GOI_TEN(goi),ngay_bd,ngay_kt) returning clob) into cs_lke from 
    (select so_id,nhom,ma_sp,cdich,tuoi,luong,goi,ngay_bd,ngay_kt,ROW_NUMBER() over(ORDER BY nhom,ma_sp,goi,cdich,tuoi) as sott from bh_sk_phi
    where b_nhom in(' ',nhom) and b_ma_sp in(' ',ma_sp) and b_goi in(' ',goi))
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_BPHI_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_tu number; b_den number; b_hangKt number; b_dt_ct clob;
    b_nhom varchar2(1); b_ma_sp varchar2(10); b_cdich varchar2(10); b_goi varchar2(10); b_tuoi number;
    b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('hangKt,dt_ct');
EXECUTE IMMEDIATE b_lenh into b_hangKt,b_dt_ct using b_oraIn;
b_lenh:=FKH_JS_LENH('nhom,ma_sp,cdich,goi,tuoi');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_ma_sp,b_cdich,b_goi,b_tuoi using b_dt_ct;
b_cdich:=nvl(b_cdich,' '); b_goi:=nvl(b_goi,' '); b_tuoi:=nvl(b_tuoi,0);
select count(*) into b_dong from bh_sk_phi;
select nvl(min(sott),b_dong) into b_tu from
    (select a.*,rownum sott from bh_sk_phi a order by nhom,ma_sp,cdich,goi,tuoi)
    where nhom=b_nhom and ma_sp=b_ma_sp and cdich=b_cdich and goi=b_goi and tuoi>=b_tuoi;
PKH_LKE_VTRI(b_hangKt,b_tu,b_den,b_trang);
select JSON_ARRAYAGG(obj returning clob) into cs_lke from
    (select json_object(a.*) obj,rownum sott from bh_sk_phi a order by nhom,ma_sp,cdich,goi,tuoi)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_BPHI_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)

AS
    b_loi varchar2(100); b_i1 number; b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
    dt_dk clob; dt_dkbs clob:=''; dt_khd clob:='';  dt_kbt clob:=''; dt_cho clob:='';
    dt_bvi clob:=''; dt_ct clob; dt_lt clob; dt_txt clob;
begin
-- Dan - Xem chi tiet theo so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Bieu phi da xoa:loi';
select json_object(so_id,nsd,'ma_sp' value FBH_SK_SP_TENl(ma_sp),'goi' value FBH_SK_GOI_TENl(goi),ngay_bd,ngay_kt) into dt_ct
       from bh_sk_phi where so_id=b_so_id;
select count(*) into b_i1 from bh_sk_phi_txt where so_id=b_so_id and loai='dt_dk';
if b_i1<>0 then     
   select txt into dt_dk from bh_sk_phi_txt where so_id=b_so_id and loai='dt_dk';
end if;   
select count(*) into b_i1 from bh_sk_phi_txt where so_id=b_so_id and loai='dt_dkbs';
if b_i1<>0 then
    select txt into dt_dkbs from bh_sk_phi_txt where so_id=b_so_id and loai='dt_dkbs';
end if;
select JSON_ARRAYAGG(json_object(ma_lt) order by bt) into dt_lt from bh_sk_phi_lt where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob)
    into dt_txt from bh_sk_phi_txt where so_id=b_so_id and loai in('dt_ct','dt_lt');
PBH_SK_BPHI_CTk(b_so_id,dt_khd,dt_kbt,dt_cho,dt_bvi);
select json_object('so_id' value b_so_id,'dt_dk' value dt_dk,'dt_dkbs' value dt_dkbs,
    'dt_khd' value dt_khd,'dt_kbt' value dt_kbt,'dt_cho' value dt_cho,'dt_bvi' value dt_bvi,
    'dt_ct' value dt_ct,'dt_lt' value dt_lt,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_BPHI_CTs(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); dt_ct clob:=FKH_JS_GTRIs(b_oraIn,'dt_ct');
    b_nhom varchar2(1); b_ma_sp varchar2(10); b_cdich varchar2(200); b_goi varchar2(200);
    b_ngay_hl number; b_ng_sinh number; b_luong number; b_so_id number;
begin
-- Dan - Tra so_id bieu phi theo dieu kien
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nhom,ma_sp,cdich,goi,ngay_hl,ng_sinh,luong');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_ma_sp,b_cdich,b_goi,b_ngay_hl,b_ng_sinh,b_luong using dt_ct;
b_cdich:=PKH_MA_TENl(b_cdich); b_goi:=PKH_MA_TENl(b_goi); b_ng_sinh:=nvl(b_ng_sinh,0); b_luong:=nvl(b_luong,0);
b_so_id:=FBH_SK_BPHI_SO_IDh(b_nhom,b_ma_sp,b_cdich,b_goi,b_ng_sinh,b_luong,b_ngay_hl);
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_SK_BPHI_CTk(b_so_id number,b_dk varchar2) return clob
AS
    b_kq clob:=''; b_i1 number;
begin
-- Dan - Tra phi theo so_id,dk
if b_dk='H' then
    select count(*) into b_i1 from bh_sk_phi_txt where so_id=b_so_id and loai='dt_khd';
    if b_i1<>0 then
        select txt into b_kq from bh_sk_phi_txt where so_id=b_so_id and loai='dt_khd';
    end if;
elsif b_dk='B' then
    select count(*) into b_i1 from bh_sk_phi_txt where so_id=b_so_id and loai='dt_kbt';
    if b_i1<>0 then
        select txt into b_kq from bh_sk_phi_txt where so_id=b_so_id and loai='dt_kbt';
    end if;
elsif b_dk='L' then
    select count(*) into b_i1 from bh_sk_phi_txt where so_id=b_so_id and loai='dt_lt';
    if b_i1<>0 then
        select txt into b_kq from bh_sk_phi_txt where so_id=b_so_id and loai='dt_lt';
    end if;
end if;
return b_kq;
end;
/
create or replace procedure PBH_SK_BPHI_CTk(
    b_so_id number,dt_khd out clob,dt_kbt out clob,dt_cho out clob,dt_bvi out clob)
AS
    b_i1 number;
begin
-- Dan
dt_khd:=''; dt_kbt:=''; dt_cho:=''; dt_bvi:='';
select count(*) into b_i1 from bh_sk_phi_txt where so_id=b_so_id and loai='dt_khd';
if b_i1=1 then
    select txt into dt_khd from bh_sk_phi_txt where so_id=b_so_id and loai='dt_khd';
end if;
select count(*) into b_i1 from bh_sk_phi_txt where so_id=b_so_id and loai='dt_kbt';
if b_i1=1 then
    select txt into dt_kbt from bh_sk_phi_txt where so_id=b_so_id and loai='dt_kbt';
end if;
select count(*) into b_i1 from bh_sk_phi_txt where so_id=b_so_id and loai='dt_cho';
if b_i1<>0 then
    select txt into dt_cho from bh_sk_phi_txt where so_id=b_so_id and loai='dt_cho';
end if;
select count(*) into b_i1 from bh_sk_phi_txt where so_id=b_so_id and loai='dt_bvi';
if b_i1<>0 then
    select txt into dt_bvi from bh_sk_phi_txt where so_id=b_so_id and loai='dt_bvi';
end if;
end;
/
create or replace procedure PBH_SK_BPHI_CTd(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(3000); b_lenh varchar2(1000); b_i1 number;
    b_so_id number; b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tygia number;
    cs_dk clob; cs_dkbs clob; cs_khd clob:=''; cs_lt clob; cs_kbt clob:=''; cs_cho clob:=''; cs_bvi clob:='';
    b_pt number; b_phi number;
    a_maDK pht_type.a_var;a_kieuDK pht_type.a_var; a_btDK pht_type.a_num;
begin
-- Dan - Tra bieu phi theo so_id
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete from temp_1; delete from temp_2;
b_lenh:=FKH_JS_LENH('so_id,nt_tien,nt_phi,tygia');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_nt_tien,b_nt_phi,b_tygia using b_oraIn;
b_tygia:=nvl(b_tygia,1);
if nvl(trim(b_nt_phi),'VND')='VND' and b_tygia<=0 then b_tygia:=1; end if;
select ma,kieu,min(bt) bulk collect into a_maDK,a_kieuDK,a_btDK from bh_sk_phi_dk where so_id=b_so_id and lh_bh<>'M' group by ma,kieu;
forall b_lp in 1..a_maDK.count
    insert into temp_1(c1,c2,n1,n11,n12,n13) select a_maDK(b_lp),a_kieuDK(b_lp),a_btDK(b_lp),tien,pt,phi from bh_sk_phi_dk where so_id=b_so_id and ma=a_maDK(b_lp) and bt=a_btDK(b_lp);
commit;
for r_lp in (select c1 ma,n1 bt,n11 tien from temp_1) loop
    FBH_SK_BPHI_DKm(b_so_id,r_lp.ma,r_lp.tien,'C',b_pt,b_phi,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    update temp_1 set n12=b_pt,n13=b_phi where c1=r_lp.ma and n1=r_lp.bt;
end loop;
select JSON_ARRAYAGG(json_object(
        a.ma,ten,'tien' value case when b_nt_tien='VND' or b.c2<>'T' then b.n11 else round(b.n11/b_tygia,2) end, 'tienC' value b.n11,
        'ptB' value case when b_nt_phi<>'VND' then decode(sign(b.n12-100),1,round(b.n12/b_tygia,2),b.n12) else b.n12 end,
        'pt' value '',cap,tc,ma_ct,ma_dk,ma_dkC,kieu,
        lh_nv,t_suat,lkeM,lkeP,lkeB,luy,a.bt,'ptk' value decode(sign(pt-99),1,'T','P'))
        order by a.bt returning clob) into cs_dk
        from bh_sk_phi_dk a,temp_1 b where a.so_id=b_so_id and b.n1=a.bt order by a.bt;

select ma,min(bt) bulk collect into a_maDK,a_btDK from bh_sk_phi_dk where so_id=b_so_id and lh_bh='M' group by ma;
forall b_lp in 1..a_maDK.count
    insert into temp_2(c1,n1,n11,n12,n13) select a_maDK(b_lp),a_btDK(b_lp),tien,pt,phi from bh_sk_phi_dk where so_id=b_so_id and ma=a_maDK(b_lp) and bt=a_btDK(b_lp);
commit;
for r_lp in (select c1 ma,n1 bt,n11 tien from temp_2) loop
    FBH_SK_BPHI_DKm(b_so_id,r_lp.ma,r_lp.tien,'M',b_pt,b_phi,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    update temp_2 set n12=b_pt,n13=b_phi where c1=r_lp.ma and n1=r_lp.bt;
end loop;
select JSON_ARRAYAGG(json_object(
        a.ma,a.ten,'tien' value case when b_nt_tien='VND' or b.c2<>'T' then b.n11 else round(b.n11/b_tygia,2) end, 'tienC' value b.n11 ,
        'ptB' value case when b_nt_phi<>'VND' then decode(sign(b.n12-100),1,round(b.n12/b_tygia,2),b.n12) else b.n12 end,
        'pt' value '',cap,tc,ma_ct,a.ma_dk,'ma_dkC' value a.ma_dkc, kieu,a.lh_nv,t_suat,lkeM,lkeP,lkeB,luy,a.bt,'ptk' value decode(sign(pt-99),1,'T','P'))
        order by a.bt returning clob) into cs_dkbs
        from bh_sk_phi_dk a,temp_2 b
        where a.so_id=b_so_id and b.n1=a.bt order by a.bt;

select JSON_ARRAYAGG(json_object(ma_lt,ten) order by bt returning clob) into cs_lt from bh_sk_phi_lt where so_id=b_so_id;
PBH_SK_BPHI_CTk(b_so_id,cs_khd,cs_kbt,cs_cho,cs_bvi);
select json_object('dt_dk' value cs_dk,'dt_dkbs' value cs_dkbs,'dt_khd' value cs_khd,'dt_kbt' value cs_kbt,
    'dt_lt' value cs_lt,'dt_cho' value cs_cho,'dt_bvi' value cs_bvi returning clob) into b_oraOut from dual;
delete from temp_1; delete from temp_2; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_BPHId_THEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_nhom varchar2(1); b_ma_sp varchar2(10); b_cdich varchar2(200); b_goi varchar2(200);
    b_ngay_hl number; b_ng_sinh number; b_luong number; b_so_id number; b_vu varchar2(10);
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tygia number; b_pt number; b_phi number;
    b_dk_lt clob; a_ma_lt pht_type.a_var; a_ma_dk_lt pht_type.a_var; a_ten_lt pht_type.a_nvar; a_chon_lt pht_type.a_var;
    a_maDK pht_type.a_var; a_btDK pht_type.a_num;
begin
-- Dan - Tra so_id bieu phi theo dieu kien
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nhom,ma_sp,cdich,goi,ngay_hl,ng_sinh,luong,vu,nt_tien,nt_phi,tygia');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_ma_sp,b_cdich,b_goi,b_ngay_hl,b_ng_sinh,b_luong,b_vu,b_nt_tien,b_nt_phi,b_tygia using b_oraIn;
b_cdich:=PKH_MA_TENl(b_cdich); b_goi:=PKH_MA_TENl(b_goi); b_ng_sinh:=nvl(b_ng_sinh,0); b_luong:=nvl(b_luong,0);
b_so_id:=FBH_SK_BPHI_SO_IDh(b_nhom,b_ma_sp,b_cdich,b_goi,b_ng_sinh,b_luong,b_ngay_hl);
b_nt_phi:=NVL(trim(b_nt_phi),'VND'); b_nt_tien:=NVL(trim(b_nt_tien),'VND');
b_tygia:=nvl(b_tygia,1);
if nvl(trim(b_nt_phi),'VND')='VND' and b_tygia<=0 then b_tygia:=1; end if;
b_oraOut:='';
if b_so_id<>0 then
    if b_vu='dk' then
        select ma,min(bt) bulk collect into a_maDK,a_btDK from bh_sk_phi_dk where so_id=b_so_id and lh_bh<>'M' group by ma;
        forall b_lp in 1..a_maDK.count
            insert into temp_1(c1,n1,n11,n12,n13) select a_maDK(b_lp),a_btDK(b_lp),tien,pt,phi from bh_sk_phi_dk where so_id=b_so_id and ma=a_maDK(b_lp) and bt=a_btDK(b_lp);
        commit;
        for r_lp in (select c1 ma,n1 bt,n11 tien from temp_1) loop
            FBH_SK_BPHI_DKm(b_so_id,r_lp.ma,r_lp.tien,'C',b_pt,b_phi,b_loi);
            if b_loi is not null then raise PROGRAM_ERROR; end if;
            update temp_1 set n12=b_pt,n13=b_phi where c1=r_lp.ma and n1=r_lp.bt;
        end loop;
        select JSON_ARRAYAGG(json_object(a.ma,ten,'tien' value case when b_nt_tien='VND' then b.n11 else round(b.n11/b_tygia,2) end, 'tienC' value b.n11,
        'ptB' value case when b_nt_phi<>'VND' then decode(sign(b.n12-100),1,round(b.n12/b_tygia,2),b.n12) else b.n12 end,
        'pt' value '',cap,tc,ma_ct,ma_dk,ma_dkC,kieu,
        lh_nv,t_suat,lkeM,lkeP,lkeB,luy,a.bt,'ptk' value decode(sign(pt-99),1,'T','P'))
        order by a.bt returning clob) into b_oraOut from bh_sk_phi_dk a,temp_1 b where a.so_id=b_so_id and b.n1=a.bt order by a.bt;
    elsif b_vu='dkbs' then
        select JSON_ARRAYAGG(json_object(ma,ten,'tien' value case when b_nt_tien='VND' then tien else round(tien/b_tygia,2) end,'tienC' value tien,
                    'ptB' value case when b_nt_phi<>'VND' then decode(sign(pt-100),1,round(pt/b_tygia,4),pt) else pt end,
                    'pt' value '',ma_ct,tc,phi,cap,lh_nv,lkeM,ma_dk,ma_dkC,kieu,lkeP,lkeB,luy,bt,'ptk' value decode(sign(pt-99),1,'T','P')) order by bt,ma,ten returning clob) into b_oraOut from
            (select ma,ten,tien,pt,ma_ct,tc,phi,cap,lh_nv,lkeM,ma_dk,ma_dkC,kieu,lkeP,lkeB,luy,bt
                    from bh_sk_phi_dk where so_id=b_so_id and lh_bh='M');
    elsif b_vu='lt' then
        select count(*) into b_i1 from bh_sk_phi_txt where so_id=b_so_id and loai='dt_lt';
        if b_i1 >0 then
             select txt into b_dk_lt from bh_sk_phi_txt where so_id=b_so_id and loai='dt_lt';
             b_lenh:=FKH_JS_LENH('ma_lt,ten,ma_dk,chon');
             EXECUTE IMMEDIATE b_lenh bulk collect into a_ma_lt,a_ten_lt,a_ma_dk_lt,a_chon_lt using b_dk_lt;
             if a_ma_lt.count > 0 then
               for b_i1 in 1..a_ma_lt.count loop
                    insert into temp_1(c1,c2,c3,c4) VALUES (a_ma_lt(b_i1),a_ten_lt(b_i1),a_ma_dk_lt(b_i1),a_chon_lt(b_i1));
               end loop;
             end if;
          end if;
          for r_lp in (select ma,ten,ma_dk from bh_ma_dklt where FBH_MA_NV_CO(nv,'NG')='C') loop
            select count(*) into b_i1 from temp_1 where c1=r_lp.ma;
            if b_i1=0 then insert into temp_1(c1,c2,c3,c4) values(r_lp.ma,r_lp.ten,r_lp.ma_dk,' '); end if;
          end loop;
          select JSON_ARRAYAGG(json_object('ma_lt' value c1,'ten' value c2,'ma_dk' value c3,'chon' value c4)
              order by c1,c2 returning clob) into b_oraOut from temp_1;
     elsif b_vu='cho' then
        select JSON_ARRAYAGG(json_object(ma,ten,so_ngay) order by ma,ten returning clob) into b_oraOut from
            (select ma,ten,so_ngay from bh_sk_cho);
    end if;
end if;
delete from temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_BPHI_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_i1 number; b_ma_ct varchar2(10);
    a_ma pht_type.a_var; b_kt number; b_i2 number; b_so_id number;
    b_nhom varchar2(1); b_ma_sp varchar2(10); b_cdich varchar2(10); b_goi varchar2(10);
    b_tuoi number; b_luong number; b_ngay_bd number; b_ngay_kt number;

    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var; dk_ma_ct pht_type.a_var;
    dk_kieu pht_type.a_var; dk_tien pht_type.a_num; dk_pt pht_type.a_num;
    dk_phi pht_type.a_num; dk_lkeM pht_type.a_var; dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var; dk_luy pht_type.a_var;
    dk_ma_dk pht_type.a_var; dk_ma_dkC pht_type.a_var; dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num; dk_lh_bh pht_type.a_var;

    dkB_ma pht_type.a_var; dkB_ten pht_type.a_nvar; dkB_tc pht_type.a_var; dkB_ma_ct pht_type.a_var;
    dkB_kieu pht_type.a_var; dkB_tien pht_type.a_num; dkB_pt pht_type.a_num;
    dkB_phi pht_type.a_num; dkB_lkeM pht_type.a_var; dkB_lkeP pht_type.a_var; dkB_lkeB pht_type.a_var; dkB_luy pht_type.a_var;
    dkB_ma_dk pht_type.a_var; dkB_ma_dkC pht_type.a_var; dkB_lh_nv pht_type.a_var; dkB_t_suat pht_type.a_num;

    lt_ma_dk pht_type.a_var; lt_ma_lt pht_type.a_var; lt_ten pht_type.a_nvar;
    b_dt_ct clob; b_dt_dk clob; b_dt_dkbs clob; b_dt_lt clob; b_dt_khd clob;
    b_dt_kbt clob; b_dt_cho clob; b_dt_bvi clob;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_dkbs,dt_lt,dt_khd,dt_kbt,dt_cho,dt_bvi');
EXECUTE IMMEDIATE b_lenh into b_dt_ct,b_dt_dk,b_dt_dkbs,b_dt_lt,b_dt_khd,b_dt_kbt,b_dt_cho,b_dt_bvi using b_oraIn;
FKH_JS_NULL(b_dt_ct); FKH_JSa_NULL(b_dt_dk); FKH_JSa_NULL(b_dt_dkbs); FKH_JSa_NULL(b_dt_lt);
FKH_JSa_NULL(b_dt_khd); FKH_JSa_NULL(b_dt_kbt); FKH_JSa_NULL(b_dt_cho); FKH_JSa_NULL(b_dt_bvi);
b_lenh:=FKH_JS_LENH('nhom,ma_sp,cdich,goi,tuoi,luong,ngay_bd,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_ma_sp,b_cdich,b_goi,b_tuoi,b_luong,b_ngay_bd,b_ngay_kt using b_dt_ct;
if trim(b_ma_sp) is null then
    b_loi:='loi:Nhap san pham:loi'; raise PROGRAM_ERROR;
elsif FBH_SK_SP_HAN(b_ma_sp)<>'C' then
    b_loi:='loi:Ma san pham '||b_ma_sp||'da het su dung:loi'; raise PROGRAM_ERROR;
end if;
if trim(b_cdich) is null then
    b_cdich:=' ';
elsif FBH_MA_CDICH_HAN(b_cdich)<>'C' then
    b_loi:='loi:Da het chien dich:loi'; raise PROGRAM_ERROR;
end if;
if trim(b_goi) is null then b_goi:=' ';
elsif FBH_SK_GOI_HAN(b_goi)<>'C' then
    b_loi:='loi:Ma goi da het su dung:loi'; raise PROGRAM_ERROR;
end if;
b_tuoi:=nvl(b_tuoi,0); b_luong:=nvl(b_luong,0);
if b_ngay_bd is null or b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
if b_ngay_kt is null or b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,ma_dk,kieu,tien,pt,phi,lkem,lkep,lkeb,luy');
EXECUTE IMMEDIATE b_lenh bulk collect into
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_ma_dk,dk_kieu,dk_tien,dk_pt,dk_phi,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy using b_dt_dk;
b_kt:=dk_ma.count;
if b_kt=0 then b_loi:='loi:Nhap dieu khoan:loi'; raise PROGRAM_ERROR; end if;
for b_lp in 1..b_kt loop dk_lh_bh(b_lp):='C'; end loop;
if trim(b_dt_dkbs) is not null then
    b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,ma_dk,ma_dkc,kieu,tien,pt,phi,lkem,lkep,lkeb,luy');
    EXECUTE IMMEDIATE b_lenh bulk collect into
        dkB_ma,dkB_ten,dkB_tc,dkB_ma_ct,dkB_ma_dk,dkB_ma_dkC,dkB_kieu,dkB_tien,dkB_pt,dkB_phi,
        dkB_lkeM,dkB_lkeP,dkB_lkeB,dkB_luy using b_dt_dkbs;
    for b_lp in 1..dkB_ma.count loop
        b_kt:=b_kt+1; dk_lh_bh(b_kt):='M';
        dk_ma(b_kt):=dkB_ma(b_lp); dk_ten(b_kt):=dkB_ten(b_lp); dk_tc(b_kt):=dkB_tc(b_lp);
        dk_ma_ct(b_kt):=dkB_ma_ct(b_lp); dk_ma_dk(b_kt):=dkB_ma_dk(b_lp); dk_ma_dkC(b_kt):=dkB_ma_dkC(b_lp); dk_kieu(b_kt):=dkB_kieu(b_lp);
        dk_tien(b_kt):=dkB_tien(b_lp); dk_pt(b_kt):=dkB_pt(b_lp); dk_phi(b_kt):=dkB_phi(b_lp);dk_lkeM(b_kt):=dkB_lkeM(b_lp);
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
    dk_lkeM(b_lp):=nvl(trim(dk_lkeM(b_lp)),'K');
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
-- nam
for b_lp in 1..dk_ma.count loop
    if 'I' in (dk_lkeM(b_lp),dk_lkeP(b_lp),dk_lkeB(b_lp)) then continue; end if;
    if dk_lkeM(b_lp) not in('C','P') then dk_ma_dkC(b_lp):=' ';
    elsif dk_lh_bh(b_lp) in ('C','P') then dk_ma_dkC(b_lp):=dk_ma_ct(b_lp);
    else dk_ma_dkC(b_lp):=FBH_MA_DKBS_MA_DK(dk_ma_dk(b_lp));
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
b_so_id:=FBH_SK_BPHI_SO_IDd(b_nhom,b_ma_sp,b_cdich,b_goi,b_tuoi,b_luong);
if b_so_id<>0 then
    delete bh_sk_phi_txt where so_id=b_so_id;
    delete bh_sk_phi_lt where so_id=b_so_id;
    delete bh_sk_phi_dk where so_id=b_so_id;
    delete bh_sk_phi where so_id=b_so_id;
else
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_loi:='loi:Loi Table bh_sk_phi:loi';
insert into bh_sk_phi values(b_ma_dvi,b_so_id,b_nhom,b_ma_sp,b_cdich,b_goi,b_tuoi,b_luong,b_ngay_bd,b_ngay_kt,b_nsd);
for b_lp in 1..dk_ma.count loop
       insert into bh_sk_phi_dk values(b_ma_dvi,b_so_id,b_lp,dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),
        dk_kieu(b_lp),dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),dk_lkeM(b_lp),dk_lkeP(b_lp),dk_lkeB(b_lp),dk_luy(b_lp),
        dk_ma_dk(b_lp),dk_ma_dkC(b_lp),dk_lh_nv(b_lp),dk_t_suat(b_lp),0,dk_lh_bh(b_lp));
end loop;
-- chuclh
for r_lp in(select t.so_id,t.bt,level from
  (select * from bh_sk_phi_dk where so_id=b_so_id) t start with t.ma_ct=' ' CONNECT BY prior t.ma=t.ma_ct) loop
    update bh_sk_phi_dk set cap=r_lp.level where so_id=b_so_id and bt=r_lp.bt;
end loop;
insert into bh_sk_phi_txt values(b_ma_dvi,b_so_id,'dt_ct',b_dt_ct);
insert into bh_sk_phi_txt values(b_ma_dvi,b_so_id,'dt_dk',b_dt_dk);
if trim(b_dt_dkbs) is not null then
    insert into bh_sk_phi_txt values(b_ma_dvi,b_so_id,'dt_dkbs',b_dt_dkbs);
end if;
if lt_ma_lt.count<>0 then
    for b_lp in 1..lt_ma_lt.count loop
        insert into bh_sk_phi_lt values(b_ma_dvi,b_so_id,b_lp,lt_ma_lt(b_lp),lt_ma_dk(b_lp),lt_ten(b_lp));
    end loop;
    insert into bh_sk_phi_txt values(b_ma_dvi,b_so_id,'dt_lt',b_dt_lt);
end if;
if trim(b_dt_khd) is not null then
    insert into bh_sk_phi_txt values(b_ma_dvi,b_so_id,'dt_khd',b_dt_khd);
end if;
if trim(b_dt_kbt) is not null then
    insert into bh_sk_phi_txt values(b_ma_dvi,b_so_id,'dt_kbt',b_dt_kbt);
end if;
if trim(b_dt_cho) is not null then
    insert into bh_sk_phi_txt values(b_ma_dvi,b_so_id,'dt_cho',b_dt_cho);
end if;
if trim(b_dt_bvi) is not null then
    insert into bh_sk_phi_txt values(b_ma_dvi,b_so_id,'dt_bvi',b_dt_bvi);
end if;
commit;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_BPHI_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS 
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Dan - Xoa bieu phi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then b_loi:='loi:Chon bieu phi can xoa:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table bh_sk_phi:loi';
delete bh_sk_phi_txt where so_id=b_so_id;
delete bh_sk_phi_lt where so_id=b_so_id;
delete bh_sk_phi_dk where so_id=b_so_id;
delete bh_sk_phi where so_id=b_so_id;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_CHO_XEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,so_ngay) order by ten returning clob) into cs_lke from bh_sk_cho where tc='C';
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;

create or replace procedure FBH_SK_KHO(
   b_ngay_hl number,b_ngay_kt number,b_kho out number,b_loi out varchar2)
AS
    b_i1 number; b_tltg number;
begin
-- Dan - Tinh he so phi
b_loi:='loi:Loi xu ly FBH_SK_KHO:loi';
if substr(to_char(b_ngay_hl), 5)=substr(to_char(b_ngay_kt), 5) then b_kho:=FKH_KHO_NASO(b_ngay_hl,b_ngay_kt);
else
  b_kho:=FKH_KHO_NGSO(b_ngay_hl,b_ngay_kt)+1;
  select count(*) into b_i1 from bh_sk_tltg;
  if b_kho<365 and b_i1<>0 then
      b_kho:=FKH_KHO_THSO(b_ngay_hl,b_ngay_kt);
      select count(*),nvl(min(tltg),0) into b_i1,b_tltg from bh_sk_tltg
          where tltg>b_kho and b_ngay_hl between ngay_bd and ngay_kt;
      if b_i1=0 then b_kho:=1;
      else
          select tlph into b_kho from bh_sk_tltg where tltg=b_tltg and b_ngay_hl between ngay_bd and ngay_kt;
          b_kho:=b_kho/100;
      end if;
  elsif b_kho<365 or b_kho>366 then
      b_kho:=b_kho/365;
  else b_kho:=1;
  end if;
end if;
b_loi:='';
end;
/
create or replace function FBH_SK_GOI_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- viet anh
select min(ma||'|'||ten) into b_kq from bh_sk_goi where ma=b_ma;
return b_kq;
end;
