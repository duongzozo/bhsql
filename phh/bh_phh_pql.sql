create or replace function FBH_PHH_DKTH_LHNV(b_ma varchar2) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan
select nvl(min(lh_nv),' ') into b_kq from bh_phh_dkth where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_PHH_DKTH_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_phh_dkth where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_PHH_DKTH_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_phh_dkth where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_PHH_DKTH_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_phh_dkth where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_PHH_DKTH_XEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngay number:=PKH_NG_CSO(sysdate); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma) into cs_lke from bh_phh_dkth a where ngay_kt>b_ngay;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_DKTH_LKE(
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
    select count(*) into b_dong from bh_phh_dkth;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select * from bh_phh_dkth order by ma))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_phh_dkth where upper(ma) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,json_object(a.*,'xep' value ma) obj from bh_phh_dkth a)
            where upper(ma) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_DKTH_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_phh_dkth;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_phh_dkth;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_DKTH_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma'); cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma chua nhap hoac da xoa:loi';
select json_object(ma,txt) into cs_ct from bh_phh_dkth  where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_DKTH_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_lh_nv varchar2(10); b_nvB varchar2(10); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,lh_nv,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_lh_nv,b_ngay_kt using b_oraIn;
b_ma:=nvl(trim(b_ma),' '); b_ten:=nvl(trim(b_ten),' '); b_lh_nv:=nvl(trim(b_lh_nv),' ');
if b_ma=' ' or b_ten=' ' then b_loi:='loi:Nhap ma, ten:loi'; raise PROGRAM_ERROR; end if;
if b_lh_nv<>' ' then
    if FBH_MA_LHNV_HAN(b_lh_nv)<>'C' then b_loi:='loi:Sai loai hinh nghiep vu:loi'; raise PROGRAM_ERROR; end if;
    b_nvB:=FBH_MA_LHNV_NV(b_lh_nv);
    if FBH_MA_NV_BAO(b_nvB,'PHH')<>'C' then
        b_loi:='loi:Loai hinh nghiep vu khong ap dung cho Tai san:loi'; raise PROGRAM_ERROR;
    end if;
end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_phh_dkth where ma=b_ma;
insert into bh_phh_dkth values(b_ma_dvi,b_ma,b_ten,b_lh_nv,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_DKTH_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_phh_dkth where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Ma nguyen nhan ton that
create or replace function FBH_PHH_NNTT_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_phh_nntt where ma=b_ma and tc='C';
return b_kq;
end;
/
create or replace function FBH_PHH_NNTT_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_phh_nntt where ma=b_ma and tc='C';
return b_kq;
end;
/
create or replace function FBH_PHH_NNTT_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_phh_nntt where ma=b_ma and tc='C' and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_PHH_NNTT_XEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngay number:=PKH_NG_CSO(sysdate); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma) into cs_lke from bh_phh_nntt a where tc='C' and ngay_kt>b_ngay;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_NNTT_LKE(
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
    select count(*) into b_dong from bh_phh_nntt;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep)) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_phh_nntt order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_phh_nntt where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma)) into cs_lke from
        (select a.*,rownum sott from bh_phh_nntt a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_NNTT_MA(
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
    select count(*) into b_dong from bh_phh_nntt;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_phh_nntt order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_phh_nntt order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep)) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_phh_nntt order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_phh_nntt where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_phh_nntt where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma)) into cs_lke from
        (select a.*,rownum sott from bh_phh_nntt a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_NNTT_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma'); cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma chua nhap hoac da xoa:loi';
select json_object(ma,txt) into cs_ct from bh_phh_nntt  where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_NNTT_NH
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
    select 0 into b_i1 from bh_phh_nntt where ma=b_ma_ct and tc='T';
end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_phh_nntt where ma=b_ma;
insert into bh_phh_nntt values(b_ma_dvi,b_ma,b_ten,b_tc,b_ma_ct,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_NNTT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_phh_nntt where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_phh_nntt where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** Ma muc rui ro ***/
create or replace function FBH_PHH_MRR_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_phh_mrr where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_PHH_MRR_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_phh_mrr where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_PHH_MRR_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_phh_mrr where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_PHH_MRR_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into cs_lke from bh_phh_mrr;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_MRR_LKE(    
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
    select count(*) into b_dong from bh_phh_mrr;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select * from bh_phh_mrr order by ma))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_phh_mrr where upper(ma) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,json_object(a.*,'xep' value ma) obj from bh_phh_mrr a)
            where upper(ma) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_MRR_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_phh_mrr;
select nvl(min(sott),0) into b_tu from (select ma,rownum sott from bh_phh_mrr order by ma) where ma>=b_ma;
PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(ma,ten,nsd) order by ma returning clob) into cs_lke from
    (select ma,ten,nsd,rownum sott from bh_phh_mrr order by ma)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_MRR_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,ngay_kt) into b_kq from bh_phh_mrr where ma=b_ma;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_MRR_NH
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
delete bh_phh_mrr where ma=b_ma;
insert into bh_phh_mrr values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_MRR_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_phh_mrr where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* MA NHOM */
create or replace function FBH_PHH_NHOM_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ten) into b_kq from bh_phh_nhom where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_PHH_NHOM_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_phh_nhom where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_PHH_NHOM_HAN(b_ma varchar2,b_dk varchar2:='C') return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_phh_nhom where ma=b_ma and tc in('C',b_dk) and ngay_bd<=b_ngay and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_PHH_NHOM_MRR(b_ma varchar2) return nvarchar2
AS
    b_kq varchar2(10);
begin
-- Dan
select nvl(min(mrr),' ') into b_kq from bh_phh_nhom where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_PHH_NHOM_CAT(b_ma varchar2) return nvarchar2
AS
    b_kq varchar2(10);
begin
-- Dan
select nvl(min(ma_ta),' ') into b_kq from bh_phh_nhom where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_PHH_NHOM_LKE(
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
    select count(*) into b_dong from bh_phh_nhom;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_phh_nhom order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_phh_nhom where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(a.*,'xep' value ma) obj from bh_phh_nhom a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_NHOM_MA(
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
    select count(*) into b_dong from bh_phh_nhom;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_phh_nhom order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_phh_nhom order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep,rownum sott from
                (select * from bh_phh_nhom order by ma) a
                start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_phh_nhom where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_phh_nhom where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(a.*,'xep' value ma) obj from bh_phh_nhom a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_NHOM_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma'); cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,'mrr' value FBH_PHH_MRR_TENl(mrr),'ma_ta' value FTBH_MA_RR_TENl(ma_ta),txt returning clob)
	into cs_ct from bh_phh_nhom where ma=b_ma;
select json_object('cs_ct' value cs_ct returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_NHOM_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_tc varchar2(1);
    b_ma_ct varchar2(10); b_mrr varchar2(10); b_ma_ta varchar2(10); b_ngay_bd number; b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,mrr,ma_ta,ngay_bd,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_tc,b_ma_ct,b_mrr,b_ma_ta,b_ngay_bd,b_ngay_kt using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_tc is null or b_tc<>'T' then b_tc:='C'; end if;
b_loi:='loi:Ma nhom da co ma chi tiet:loi';
if b_tc='C' then 
    select count(*) into b_i1 from bh_phh_nhom where ma_ct=b_ma and tc='C';
    if b_i1>0 then raise PROGRAM_ERROR; end if;
end if;
if trim(b_ma_ct) is null then
    b_ma_ct:=' ';
else
    b_loi:='loi:Sai ma cap tren:loi';
    if b_ma=b_ma_ct then raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from bh_phh_nhom where ma=b_ma_ct and tc='T';
end if;
b_mrr:=nvl(trim(b_mrr),' ');
if b_tc='T' then b_mrr:=' ';
elsif b_mrr=' ' or FBH_PHH_MRR_HAN(b_mrr)<>'C' then
    b_loi:='loi:Sai muc rui ro:loi'; raise PROGRAM_ERROR;
end if;
b_ma_ta:=nvl(trim(b_ma_ta),' ');
if b_tc='T' then b_ma_ta:=' ';
elsif b_ma_ta=' ' or FTBH_MA_RR_TEN(b_ma_ta) is null then
    b_loi:='loi:Sai ma tai:loi'; raise PROGRAM_ERROR;
end if;
if b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_phh_nhom where ma=b_ma;
insert into bh_phh_nhom values(b_ma_dvi,b_ma,b_ten,b_tc,b_ma_ct,b_mrr,b_ma_ta,b_ngay_bd,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_NHOM_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_phh_nhom where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_phh_nhom where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* Doi tuong */
create or replace function FBH_PHH_DTUONG_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ten) into b_kq from bh_phh_dtuong where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_PHH_DTUONG_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_phh_dtuong where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_PHH_DTUONG_HAN(b_ma varchar2,b_dk varchar2:='C') return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_phh_dtuong where ma=b_ma and tc in('C',b_dk) and ngay_bd<=b_ngay and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_PHH_DTUONG_NHOM(b_ma varchar2) return nvarchar2
AS
    b_kq varchar2(10):='';
begin
-- Dan
select min(nhom) into b_kq from bh_phh_dtuong where ma=b_ma;
return b_kq;
end;
/
-- chuclh: bo
create or replace function FBH_PHH_DTUONG_MRR(b_ma varchar2) return nvarchar2
AS
    b_kq varchar2(10):=''; b_nhom varchar2(10):=FBH_PHH_DTUONG_NHOM(b_ma);
begin
-- Dan
if b_nhom is not null then b_kq:=FBH_PHH_NHOM_MRR(b_nhom); end if;
return b_kq;
end;
/
create or replace function FBH_PHH_DTUONG_CAT(b_ma varchar2) return varchar2
AS
    b_kq varchar2(10):=' '; b_nhom varchar2(10);
begin
-- Dan - Tra cat
b_nhom:=FBH_PHH_DTUONG_NHOM(b_ma);
if b_nhom is not null then
    b_kq:=FBH_PHH_NHOM_CAT(b_nhom);
    b_kq:=nvl(trim(b_kq),' ');
end if;
return b_kq;
end;
/
create or replace procedure PBH_PHH_DTUONG_MRR (
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ten nvarchar2(1000); b_ma_dt varchar2(500):=trim(b_oraIn); b_nhom varchar2(10);
    b_mrr varchar2(10); b_mrrL nvarchar2(500):=' '; b_cat varchar2(10);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ma_dt:=PKH_MA_TENl(b_ma_dt); b_ten:=PKH_TEN_TENl(b_oraIn); 
b_nhom:=FBH_PHH_DTUONG_NHOM(b_ma_dt);
if b_nhom is not null then
    select nvl(min(mrr),' '),nvl(min(ma_ta),' ') into b_mrr,b_cat from bh_phh_nhom where ma=b_nhom;
end if;
if b_mrr<>' ' then b_mrrL:=FBH_PHH_MRR_TENl(b_mrr); end if;
select json_object('lvuc' value b_ten,'mrr' value b_mrrL, 'cat' value b_cat) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_PHH_CAT_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from tbh_ma_rr where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_PHH_MA_DT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); bil number;  b_ma varchar2(20):=FKH_JS_GTRIs(b_oraIn,'ma');
    cs_ct clob:='';
begin
-- Dan - Tra ttin ma
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into bil from bh_phh_dtuong where ma=b_ma;
if bil<>0 then
  select min(ma||'|'||ten) into cs_ct from bh_phh_dtuong where ma=b_ma;
  end if;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_DTUONG_LKE(
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
    select count(*) into b_dong from bh_phh_dtuong;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_phh_dtuong order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_phh_dtuong where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(a.*,'xep' value ma) obj from bh_phh_dtuong a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_DTUONG_MA(
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
    select count(*) into b_dong from bh_phh_dtuong;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_phh_dtuong order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_phh_dtuong order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep,rownum sott from
                (select * from bh_phh_dtuong order by ma) a
                start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_phh_dtuong where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_phh_dtuong where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(a.*,'xep' value ma) obj from bh_phh_dtuong a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_DTUONG_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma'); cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,'nhom' value FBH_PHH_NHOM_TENl(nhom),txt returning clob) into cs_ct from bh_phh_dtuong where ma=b_ma;
select json_object('cs_ct' value cs_ct returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_DTUONG_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_tc varchar2(1);
    b_ma_ct varchar2(10); b_nhom varchar2(10); b_ngay_bd number; b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,nhom,ngay_bd,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_tc,b_ma_ct,b_nhom,b_ngay_bd,b_ngay_kt using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_tc is null or b_tc<>'T' then b_tc:='C'; end if;
if trim(b_ma_ct) is null then
    b_ma_ct:=' ';
else
    b_loi:='loi:Sai ma cap tren:loi';
    if b_ma=b_ma_ct then raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from bh_phh_dtuong where ma=b_ma_ct and tc='T';
end if;
if b_tc='T' then b_nhom:=' ';
elsif trim(b_nhom) is null or FBH_PHH_NHOM_HAN(b_nhom)<>'C' then
    b_loi:='loi:Sai nhom:loi'; raise PROGRAM_ERROR;
end if;
if b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_phh_dtuong where ma=b_ma;
insert into bh_phh_dtuong values(b_ma_dvi,b_ma,b_ten,b_tc,b_ma_ct,b_nhom,b_ngay_bd,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_DTUONG_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_phh_dtuong where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_phh_dtuong where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Ty le phi / tgian BH
create or replace function FBH_PHH_TLTG_TLE(b_ngay_hl number,b_ngay_kt number) return number
AS
    b_kq number:=0; b_i1 number; b_th number:=FKH_KHO_THSO(b_ngay_hl,b_ngay_kt); b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Tra ty le phi < 12 thang
if b_th<12 then
    select nvl(max(tltg),0) into b_i1 from bh_phh_tltg where tltg<=b_th and b_ngay between ngay_bd and ngay_kt;
    if b_i1<>0 then
        select tlph into b_kq from bh_phh_tltg where tltg=b_i1 and b_ngay between ngay_bd and ngay_kt;
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
create or replace procedure PBH_PHH_TLTG_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_tltg number:=FKH_JS_GTRIs(b_oraIn,'tltg');
    cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Thoi gian da xoa:loi';
select json_object(tltg,tlph,ngay_bd,ngay_kt) into cs_ct from bh_phh_tltg where tltg=b_tltg;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_TLTG_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(tltg,tlph,nsd) order by tltg) into cs_lke from bh_phh_tltg;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_TLTG_NH
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
delete bh_phh_tltg where tltg=b_tltg;
insert into bh_phh_tltg values(b_ma_dvi,b_tltg,b_tlph,b_ngay_bd,b_ngay_kt,b_nsd);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_TLTG_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn cLob)
AS
    b_loi varchar2(100); b_tltg number:=FKH_JS_GTRIs(b_oraIn,'tltg');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_tltg is null then b_loi:='loi:Nhap thoi gian:loi'; raise PROGRAM_ERROR; end if;
delete bh_phh_tltg where tltg=b_tltg;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_TLTG_TLE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_ngay_hl number; b_ngay_kt number; b_tlph number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_bd,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ngay_hl,b_ngay_kt using b_oraIn;
b_tlph:=FBH_PHH_TLTG_TLE(b_ngay_hl,b_ngay_kt);
select json_object('tlph' value b_tlph) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- San pham --
create or replace function FBH_PHH_SP_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ten) into b_kq from bh_phh_sp where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_PHH_SP_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_phh_sp where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_PHH_SP_HAN(b_ma varchar2,b_dk varchar2:='C') return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_phh_sp where ma=b_ma and tc in('C',b_dk) and ngay_bd<=b_ngay and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_PHH_SP_LKE(
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
    select count(*) into b_dong from bh_phh_sp;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(* returning clob) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_phh_sp order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_phh_sp where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(a.*,'xep' value ma) obj from bh_phh_sp a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_SP_LKE_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_tim) is null then
    select count(*) into b_dong from bh_phh_sp;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_phh_sp order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_phh_sp order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep,rownum sott from
                (select * from bh_phh_sp order by ma) a
                start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;    
else
    select count(*) into b_dong from bh_phh_sp where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_phh_sp where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(a.*,'xep' value ma) obj from bh_phh_sp a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_SP_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=trim(b_oraIn);
    dt_ct clob:=''; dt_dl clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_phh_sp where ma=b_ma;
if b_i1=1 then
    select json_object(ma,txt returning clob) into dt_ct from bh_phh_sp where ma=b_ma;
    select JSON_ARRAYAGG(json_object('ma_dl' value FBH_DTAC_MA_TENl(ma_dl)) returning clob) into dt_dl from bh_phh_sp_dl where ma=b_ma;
end if;
select json_object('dt_ct' value dt_ct,'dt_dl' value dt_dl returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_SP_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_tc varchar2(1);
    b_ma_ct varchar2(10); b_ngay_bd number; b_ngay_kt number;
    a_ma_dl pht_type.a_var;
    dt_ct clob; dt_dl clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dl');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dl using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dl);
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,ngay_bd,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_tc,b_ma_ct,b_ngay_bd,b_ngay_kt using dt_ct;
if b_ma=' ' or b_ten=' ' then b_loi:='loi:Nhap ma, ten:loi'; raise PROGRAM_ERROR; end if;
if b_tc is null or b_tc<>'T' then b_tc:='C'; end if;
if b_ma_ct<>' ' then
    b_loi:='loi:Sai ma cap tren:loi';
    if b_ma=b_ma_ct then raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from bh_phh_sp where ma=b_ma_ct and tc='T';
    b_loi:='';
end if;
if trim(dt_dl) is not null then
    b_lenh:=FKH_JS_LENH('ma_dl');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_ma_dl using dt_dl;
    for b_lp in 1..a_ma_dl.count loop
        if FBH_DTAC_MA_HAN(a_ma_dl(b_lp))='K' then
            b_loi:='loi:Dai ly '||a_ma_dl(b_lp)||' chua nhap hoac het han:loi'; return;
        end if;
    end loop;
end if;
if b_ngay_bd=30000101 then b_ngay_bd:=0; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
delete bh_phh_sp where ma=b_ma;
delete bh_phh_sp_dl where ma=b_ma;
b_loi:='loi:Ma:'||b_ma||':loi';
insert into bh_phh_sp values(b_ma_dvi,b_ma,b_ten,b_tc,b_ma_ct,b_ngay_bd,b_ngay_kt,b_nsd,dt_ct);
if trim(dt_dl) is not null then
    forall b_lp in 1..a_ma_dl.count
        insert into bh_phh_sp_dl values(b_ma_dvi,b_ma,a_ma_dl(b_lp));
end if;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_SP_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=trim(b_oraIn);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_phh_sp where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_phh_sp_dl where ma=b_ma;
delete bh_phh_sp where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* Ma goi*/
create or replace function FBH_PHH_GOI_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_phh_goi where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_PHH_GOI_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_phh_goi where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_PHH_GOI_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_phh_goi;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_phh_goi;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_GOI_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_phh_goi;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_phh_goi;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_GOI_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,ngay_kt) into b_kq from bh_phh_goi where ma=b_ma;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_GOI_NH
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
delete bh_phh_goi where ma=b_ma;
insert into bh_phh_goi values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_GOI_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_phh_goi where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* Ma pham vi*/
create or replace function FBH_PHH_PVI_TC(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra tc
select nvl(min(tc),'C') into b_kq from bh_phh_pvi where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_PHH_PVI_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_phh_pvi where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_PHH_PVI_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_phh_pvi where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_PHH_PVI_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_phh_pvi where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_PHH_PVI_LKE(
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
    select count(*) into b_dong from bh_phh_pvi;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select * from bh_phh_pvi order by ma))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_phh_pvi where upper(ma) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,json_object(a.*,'xep' value ma) obj from bh_phh_pvi a)
            where upper(ma) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_PVI_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_phh_pvi;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_phh_pvi;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_PVI_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(txt returning clob) into b_kq from bh_phh_pvi where ma=b_ma;
select json_object('cs_ct' value b_kq returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_PVI_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_tc varchar2(1); b_ten nvarchar2(500); b_ngay_kt number;
    b_loai varchar2(1); b_ma_ct varchar2(10); b_ma_dk varchar2(500); 
    b_ma_qtac varchar2(500);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,loai,ma_ct,ma_dk,ma_qtac,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_tc,b_loai,b_ma_ct,b_ma_dk,b_ma_qtac,b_ngay_kt using b_oraIn;
b_ma_dk:=PKH_MA_TENl(b_ma_dk); b_ma_qtac:=PKH_MA_TENl(b_ma_qtac);
b_ma:=nvl(trim(b_ma),' '); b_ten:=nvl(trim(b_ten),' ');
if b_ma=' ' or b_ten=' ' then b_loi:='loi:Nhap ma,ten:loi'; raise PROGRAM_ERROR; end if;
b_tc:=nvl(trim(b_tc),' '); b_loai:=nvl(trim(b_loai),' ');
if b_loai not in('C','D','B','M','P') then b_loi:='loi:Sai loai:loi'; raise PROGRAM_ERROR; end if;
if b_tc not in('C','T') then b_loi:='loi:Sai tinh chat:loi'; raise PROGRAM_ERROR; end if;
b_ma_ct:=nvl(trim(b_ma_ct),' ');
if b_ma_ct<>' ' then
    if b_ma_ct=b_ma then b_loi:='loi:Trung ma:loi'; raise PROGRAM_ERROR; end if;
    select count(*) into b_i1 from bh_phh_pvi where ma=b_ma_ct;
    if b_i1=0 then  b_loi:='loi:Ma cap tren chua dang ky:loi'; raise PROGRAM_ERROR; end if;
end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_phh_pvi where ma=b_ma;
insert into bh_phh_pvi values(b_ma_dvi,b_ma,b_tc,b_ten,b_loai,b_ma_ct,b_ma_dk,b_ma_qtac,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_PVI_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_phh_pvi where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* Ma loai BH */
create or replace function FBH_PHH_LBH_TC(b_ma varchar2) return varchar2
AS
    b_kq varchar2(5);
begin
-- Dan - Kiem tra con hieu luc
select nvl(min(tc),' ') into b_kq from bh_phh_lbh where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_PHH_LBH_LOAI(b_ma varchar2) return varchar2
AS
    b_kq varchar2(5);
begin
-- Dan - Kiem tra con hieu luc
select nvl(min(loai),' ') into b_kq from bh_phh_lbh where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_PHH_LBH_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_phh_lbh where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_PHH_LBH_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_phh_lbh where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_PHH_LBH_LKE(
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
    select count(*) into b_dong from bh_phh_lbh;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,ROW_NUMBER() over (order by ma) as sott from
            (select * from bh_phh_lbh order by ma))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_phh_lbh where upper(ma) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,ROW_NUMBER() over (order by ma) as sott from
            (select ma,json_object(a.*,'xep' value ma) obj from bh_phh_lbh a)
            where upper(ma) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_LBH_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_phh_lbh;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_phh_lbh;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--duchq update xem chi tiet lay tu txt
create or replace procedure PBH_PHH_LBH_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,txt) into b_kq from bh_phh_lbh where ma=b_ma;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_LBH_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_loai varchar2(5); b_ten nvarchar2(500);
    b_tc varchar2(1); b_ma_ct varchar2(10); b_ma_dk varchar2(10); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,loai,ma_dk,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_tc,b_ma_ct,b_loai,b_ma_dk,b_ngay_kt using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
b_loai:=nvl(trim(b_loai),' '); b_tc:=nvl(trim(b_tc),'C'); b_ma_ct:=nvl(trim(b_ma_ct),' ');
if b_loai not in('TS','TB','HH','BI','KH') then b_loi:='loi:Sai loai:loi'; raise PROGRAM_ERROR; end if;
if b_ma_ct<>' ' then
    select count(*) into b_i1 from bh_phh_lbh where ma=b_ma_ct;
    if b_i1=0 then b_loi:='loi:Sai ma bac cao:loi'; raise PROGRAM_ERROR; return; end if;
end if;
b_ma_dk:=nvl(trim(b_ma_dk),' ');
if b_ma_dk<>' ' and FBH_MA_DK_HAN(b_ma_dk)='K' then
    b_loi:='loi:Dieu khoan da het su dung:loi'; raise PROGRAM_ERROR;
end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_phh_lbh where ma=b_ma;
insert into bh_phh_lbh values(b_ma_dvi,b_ma,b_loai,b_ten,b_tc,b_ma_ct,b_ma_dk,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_LBH_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_phh_lbh where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/*** BIEU PHI ***/
/
create or replace procedure PBH_PHH_BPHIp_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_ngay number:=PKH_NG_CSO(sysdate);
    b_loi varchar2(100); cs_sp clob; cs_cdich clob; cs_goi clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ten) into cs_sp from bh_phh_sp where FBH_PHH_SP_HAN(ma)='C';
select JSON_ARRAYAGG(json_object(ma,ten) order by ten) into cs_cdich
	from bh_ma_cdich where FBH_MA_NV_CO(nv,'PHH')='C' and FBH_MA_CDICH_HAN(ma)='C';
select JSON_ARRAYAGG(json_object(ma,ten) order by ma) into cs_goi from bh_phh_goi where FBH_PHH_GOI_HAN(ma)='C';
select json_object('cs_sp' value cs_sp,'cs_cdich' value cs_cdich,'cs_goi' value cs_goi) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Bieu phi theo danh muc
create or replace function FBH_PHH_BPHId_SO_ID
    (b_nhom varchar2,b_ma_sp varchar2,b_cdich varchar2,b_goi varchar2,b_mrr varchar2,b_ngay_hl number:=0) return number
AS
    b_so_id number:=0; b_mrrM varchar2(10); b_ngay number:=b_ngay_hl;
begin
-- Dan - Tra so ID phi
if b_ngay in(0,30000101) then b_ngay:=PKH_NG_CSO(sysdate); end if;
select max(mrr) into b_mrrM from bh_phh_phi where
    nhom=b_nhom and ma_sp=b_ma_sp and cdich=b_cdich and goi=b_goi and mrr<=b_mrr and b_ngay between ngay_bd and ngay_kt;
if b_mrrM is not null then
    select nvl(max(so_id),0) into b_so_id from bh_phh_phi where
        nhom=b_nhom and ma_sp=b_ma_sp and cdich=b_cdich and goi=b_goi and mrr=b_mrr and b_ngay between ngay_bd and ngay_kt;
end if;
return b_so_id;
end;
/
create or replace procedure PBH_PHH_BPHId_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_so_id number;
    b_nhom varchar2(1); b_ma_sp varchar2(10); b_cdich varchar2(10); b_goi varchar2(10); b_mrr varchar2(10);
begin
-- Dan - Tra so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nhom,ma_sp,cdich,goi,mrr');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_ma_sp,b_cdich,b_goi,b_mrr using b_oraIn;
if trim(b_ma_sp) is null then
    b_so_id:=0;
else
    b_cdich:=nvl(trim(b_cdich),' '); b_goi:=nvl(trim(b_goi),' '); b_mrr:=nvl(PKH_MA_TENl(b_mrr),' ');
    b_so_id:=FBH_PHH_BPHId_SO_ID(b_nhom,b_ma_sp,b_cdich,b_goi,b_mrr);
end if;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_BPHId_LBHt(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_oraOut:=FBH_PHH_LBH_TEN(b_oraIn);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_BPHId_LBH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,tc,ma_ct,ma_dk) returning clob) into cs_lke from
    (select ma,tc,ma_ct,ma_dk,rpad(lpad('-',2*(level-1),'-')||ten,50) ten from
    (select * from bh_phh_lbh order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct);
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_BPHId_DKBS(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,'ma_dk' value ma,lh_nv) order by ma returning clob) into cs_lke
    from bh_ma_dkbs where FBH_MA_NV_CO(nv,'PHH')='C' order by ma;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_BPHId_PVI(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob; b_i1 number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_phh_pvi where loai='T';
if b_i1=0 then
    select JSON_ARRAYAGG(json_object(ma,ten,tc,loai,ma_ct) order by ma returning clob) into cs_lke from bh_phh_pvi order by ma;
else
    select JSON_ARRAYAGG(json_object(ma,tc,loai,ma_ct,
        'ten' value decode(loai,'T',ten,'--'||ten)) order by ma returning clob) into cs_lke from bh_phh_pvi order by ma;
end if;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_BPHID_LT (
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma_dk,ten,'ma_lt' value ma)) into cs_lke
    from bh_ma_dklt a where FBH_MA_NV_CO(nv,'PHH')='C' and FBH_MA_DKLT_HAN(ma_dk,ma)='C' and MA <> ' ';
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
CREATE OR REPLACE procedure PBH_PHH_BPHID_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_ngay number:=PKH_NG_CSO(sysdate);
    b_loi varchar2(100); cs_sp clob; cs_cdich clob; cs_goi clob; cs_lt clob; cs_khd clob; cs_kbt clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ten) into cs_sp from bh_phh_sp where FBH_PHH_SP_HAN(ma)='C';
select JSON_ARRAYAGG(json_object(ma,ten) order by ten) into cs_cdich
    from bh_ma_cdich where FBH_MA_NV_CO(nv,'PHH')='C' and FBH_MA_CDICH_HAN(ma)='C';
select JSON_ARRAYAGG(json_object(ma,ten) order by ma) into cs_goi from bh_phh_goi where FBH_PHH_GOI_HAN(ma)='C';
select JSON_ARRAYAGG(json_object(ma_dk,ten,'ma_lt' value ma returning clob) returning clob) into cs_lt
    from bh_ma_dklt a where FBH_MA_NV_CO(nv,'PHH')='C' and FBH_MA_DKLT_HAN(ma_dk,ma)='C' and MA <> ' '; -- ma = ' ' la goc
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt) into cs_khd from bh_kh_ttt where ps='KHD' and nv='PHH';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt) into cs_kbt from bh_kh_ttt where ps='KBT' and nv='PHH';
select json_object('cs_sp' value cs_sp,'cs_cdich' value cs_cdich,'cs_goi' value cs_goi,
    'cs_lt' value cs_lt,'cs_khd' value cs_khd,'cs_kbt' value cs_kbt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_BPHId_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); 
    b_nhom varchar2(1); b_mrr varchar2(200); b_ma_sp varchar2(10); b_cdich varchar2(10); b_goi varchar2(10);
    b_tu number; b_den number; b_dong number; cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nhom,mrr,ma_sp,cdich,goi,tu,den');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_mrr,b_ma_sp,b_cdich,b_goi,b_tu,b_den using b_oraIn;
b_nhom:=nvl(b_nhom,' '); b_ma_sp:=nvl(b_ma_sp,' '); b_cdich:=nvl(b_cdich,' '); b_goi:=nvl(b_goi,' ');
b_mrr:=PKH_MA_TENl(b_mrr); b_mrr:=nvl(b_mrr,' '); 
select count(*) into b_dong from bh_phh_phi where b_nhom in (' ',nhom) and b_ma_sp in (' ',ma_sp) and b_mrr in (' ',mrr)
       and b_cdich in (' ',cdich) and b_goi in (' ',goi);
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(nhom,
     'ma_sp' value FBH_PHH_SP_TEN(ma_sp),'cdich' value FBH_MA_CDICH_TEN(cdich),'goi' value FBH_PHH_GOI_TEN(goi),
     'mrr' value FBH_PHH_MRR_TEN(mrr),ngay_bd,ngay_kt,nsd,so_id) order by nhom,ma_sp,cdich,goi,mrr returning clob) into cs_lke from
    (select nhom,ma_sp,cdich,goi,mrr,ngay_bd,ngay_kt,nsd,so_id,rownum sott 
    from bh_phh_phi where b_nhom in (' ',nhom) and b_ma_sp in (' ',ma_sp) and b_mrr in (' ',mrr)
       and b_cdich in (' ',cdich) and b_goi in (' ',goi) order by nhom,ma_sp,cdich,goi,mrr)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_BPHId_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_i1 number; 
    b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
    dt_khd clob:=''; dt_kbt clob:=''; dt_ct clob; dt_dk clob; dt_dkbs clob; dt_pvi clob; dt_lt clob; dt_txt clob;
begin
-- Dan - Xem chi tiet theo so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Bieu phi da xoa:loi';
select JSON_ARRAYAGG(json_object(so_id,nhom,'mrr' value FBH_PHH_MRR_TENl(mrr)) returning clob) into dt_ct from bh_phh_phi where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ma,cap) order by bt returning clob) into dt_dk from bh_phh_phi_dk where so_id=b_so_id and nv<>'M';
select JSON_ARRAYAGG(json_object(ma,cap) order by bt returning clob) into dt_dkbs from bh_phh_phi_dk where so_id=b_so_id and nv='M';
select JSON_ARRAYAGG(json_object(ma,ten) order by bt returning clob) into dt_pvi from bh_phh_phiP_dk where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ma_lt) order by bt returning clob) into dt_lt from bh_phh_phi_lt where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_phh_phi_txt where so_id=b_so_id and loai in('dt_ct','dt_dk','dt_dkbs','dt_pvi','dt_lt');
select count(*) into b_i1 from bh_phh_phi_txt where so_id=b_so_id and loai='dt_khd';
if b_i1<>0 then
    select txt into dt_khd from bh_phh_phi_txt where so_id=b_so_id and loai='dt_khd';
end if;
select count(*) into b_i1 from bh_phh_phi_txt where so_id=b_so_id and loai='dt_kbt';
if b_i1<>0 then
    select txt into dt_kbt from bh_phh_phi_txt where so_id=b_so_id and loai='dt_kbt';
end if;
select json_object('so_id' value b_so_id,'dt_khd' value dt_khd,'dt_kbt' value dt_kbt,'dt_ct' value dt_ct,
    'dt_dk' value dt_dk,'dt_dkbs' value dt_dkbs,'dt_pvi' value dt_pvi,'dt_lt' value dt_lt,
    'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_BPHId_CTs(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)

AS
    b_loi varchar2(1000); b_lenh varchar2(1000);
    b_nhom varchar2(1); b_ma_sp varchar2(500); b_cdich varchar2(500); b_goi varchar2(500);
    b_mrr varchar2(500); b_ngay_hl number; b_so_id number;
begin
-- Dan - Tra so_id bieu phi theo dieu kien
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nhom,ma_sp,cdich,goi,mrr,ngay_hl');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_ma_sp,b_cdich,b_goi,b_mrr,b_ngay_hl using b_oraIn;
b_cdich:=nvl(trim(b_cdich),' '); b_goi:=nvl(trim(b_goi),' '); b_mrr:=nvl(PKH_MA_TENl(b_mrr),' ');
b_so_id:=FBH_PHH_BPHId_SO_ID(b_nhom,b_ma_sp,b_cdich,b_goi,b_mrr,b_ngay_hl);
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_BPHId_CTd(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_so_id number; b_nt_phi varchar2(5); b_tygia number;
    cs_dk clob; cs_dkbs clob; cs_pvi clob; dt_khd clob:=''; cs_kbt clob:=''; cs_lt clob;
begin
-- Dan - Tra bieu phi theo so_id
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,nt_phi,tygia');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_nt_phi,b_tygia using b_oraIn;
b_nt_phi:=NVL(trim(b_nt_phi),'VND');
if b_tygia is null or b_tygia=0 then b_tygia:=1; end if;
if b_nt_phi='VND' or b_tygia=1 then
    select JSON_ARRAYAGG(json_object(ma,ma_dk,ten,cap,ma_ct,lkeM,'bt' value bt) order by bt returning clob)
        into cs_dk from bh_phh_phi_dk where so_id=b_so_id and nv<>'M' order by bt;
    select JSON_ARRAYAGG(json_object(ma,ten,lbh,'ptB' value pt,'pt' value '',ma_dkc,
        'ptK' value decode(sign(pt-100),1,'T','P'),
        'bt' value bt) order by bt returning clob)
        into cs_dkbs from bh_phh_phi_dk where so_id=b_so_id and nv='M' order by bt;
    select JSON_ARRAYAGG(json_object(ma,ten,'ptTSB' value ptTS,'ptTS' value '',
        'ptKHB' value ptKH,'ptKH' value '',ktru,tc,loai,ma_ct,
        'ptkTS' value decode(sign(ptTS-100),1,'T','P'),
        'ptkKH' value decode(sign(ptKH-100),1,'T','P'),
        'bt' value bt) order by bt returning clob)
        into cs_pvi from bh_phh_phiP_dk where so_id=b_so_id order by bt;
else
    select JSON_ARRAYAGG(json_object(ma,ma_dk,ten,cap,ma_ct,lkeM,'bt' value bt) order by bt returning clob)
        into cs_dk from bh_phh_phi_dk where so_id=b_so_id and nv<>'M' order by bt;
    select JSON_ARRAYAGG(json_object(ma,ten,lbh,'pt' value '',ma_dkc,
        'ptB' value decode(sign(pt-100),1,round(pt/b_tygia,2),pt),
        'ptK' value decode(sign(pt-100),1,'T','P'),
        'bt' value bt) order by bt returning clob)
        into cs_dkbs from bh_phh_phi_dk where so_id=b_so_id and nv='M' order by bt;
    select JSON_ARRAYAGG(json_object(ma,ten,'ptTS' value '',
        'ptTSB' value decode(sign(ptTS-100),1,round(ptTS/b_tygia,2),ptTS),
        'ptKH' value '',ktru,tc,loai,ma_ct,
        'ptKHB' value decode(sign(ptKH-100),1,round(ptKH/b_tygia,2),ptKH),
        'ptkTS' value decode(sign(ptTS-100),1,'T','P'),
        'ptkKH' value decode(sign(ptKH-100),1,'T','P'),
        'bt' value bt) order by bt returning clob)
        into cs_pvi from bh_phh_phiP_dk where so_id=b_so_id order by bt;
end if;
select JSON_ARRAYAGG(json_object(ma_lt,ten) order by bt returning clob) into cs_lt from bh_phh_phi_lt where so_id=b_so_id;
select count(*) into b_i1 from bh_phh_phi_txt where so_id=b_so_id and loai='dt_khd';
if b_i1<>0 then
    select txt into dt_khd from bh_phh_phi_txt where so_id=b_so_id and loai='dt_khd';
end if;
select count(*) into b_i1 from bh_phh_phi_txt where so_id=b_so_id and loai='dt_kbt';
if b_i1<>0 then
    select txt into cs_kbt from bh_phh_phi_txt where so_id=b_so_id and loai='dt_kbt';
end if;
select json_object('dt_dk' value cs_dk,'dt_dkbs' value cs_dkbs,'dt_pvi' value cs_pvi,
    'dt_khd' value dt_khd,'dt_kbt' value cs_kbt,'dt_lt' value cs_lt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_BPHId_THEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_i1 number;
    b_nhom varchar2(1); b_ma_sp varchar2(10); b_cdich varchar2(10); b_goi varchar2(10);
    b_mrr varchar2(500); b_ngay_hl number; b_so_id number; b_vu varchar2(10);
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tygia number;
    b_dk_lt clob; a_ma_lt pht_type.a_var; a_ma_dk_lt pht_type.a_var; a_ten_lt pht_type.a_nvar; a_chon_lt pht_type.a_var;
begin
-- Dan - Tra so_id bieu phi theo dieu kien
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nhom,ma_sp,cdich,goi,mrr,ngay_hl,nt_tien,nt_phi,tygia,vu');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_ma_sp,b_cdich,b_goi,b_mrr,b_ngay_hl,b_nt_tien,b_nt_phi,b_tygia,b_vu using b_oraIn;
b_cdich:=nvl(trim(b_cdich),' '); b_goi:=nvl(trim(b_goi),' '); b_mrr:=nvl(PKH_MA_TENl(b_mrr),' ');
b_so_id:=FBH_PHH_BPHId_SO_ID(b_nhom,b_ma_sp,b_cdich,b_goi,b_mrr,b_ngay_hl);
b_nt_phi:=NVL(trim(b_nt_phi),'VND'); b_nt_tien:=NVL(trim(b_nt_tien),'VND');
b_tygia:=nvl(b_tygia,1);
if nvl(trim(b_nt_phi),'VND')='VND' and b_tygia<=0 then b_tygia:=1; end if;
b_oraOut:='';
if b_vu='dkth' then
    select JSON_ARRAYAGG(json_object(ma,ten,lh_nv,'t_suat' value FBH_MA_LHNV_THUE(lh_nv)) order by ma returning clob) into b_oraOut from bh_phh_dkth;
elsif b_vu='dkbs' then
    select JSON_ARRAYAGG(json_object(ma,ten,'tien' value case when b_nt_tien='VND' then tien else round(tien/b_tygia,2) end,
                'ptB' value case when b_nt_phi<>'VND' then decode(sign(pt-100),1,round(pt/b_tygia,4),pt) else pt end,
                'pt' value '',ma_ct,tc,phi,cap,lh_nv,'t_suat' value FBH_MA_LHNV_THUE(lh_nv),lkeM,lkeP,bt,'ptk' value decode(sign(pt-50),1,'T','P')) order by bt,ma,ten returning clob) into b_oraOut from
        (select ma,ten,tien,pt,ma_ct,tc,phi,cap,lh_nv,lkeM,lkeP,bt
                from bh_phh_phi_dk where so_id=b_so_id and nv='M' union
        select ma,ten,null tien,null pt,'' ma_ct,'T' tc,null phi,null cap,lh_nv,'K' lkeM,'K' lkeP,999 from bh_ma_dkbs where FBH_MA_NV_CO(nv,'PHH')='C');
elsif b_vu='lt' then
    select count(*) into b_i1 from bh_phh_phi_txt where so_id=b_so_id and loai='dt_lt';
    if b_i1 >0 then
        select txt into b_dk_lt from bh_phh_phi_txt where so_id=b_so_id and loai='dt_lt';
        b_lenh:=FKH_JS_LENH('ma_lt,ma_dk,ten,chon');
        EXECUTE IMMEDIATE b_lenh bulk collect into a_ma_lt,a_ma_dk_lt,a_ten_lt,a_chon_lt using b_dk_lt;
        if a_ma_lt.count > 0 then
        for b_i1 in 1..a_ma_lt.count loop
            insert into temp_1(c1,c2,c3,c4) VALUES (a_ma_lt(b_i1),a_ma_dk_lt(b_i1),a_ten_lt(b_i1),a_chon_lt(b_i1));
        end loop;
        end if;
    end if;
    for r_lp in (select ma,ten,ma_dk from bh_ma_dklt where FBH_MA_NV_CO(nv,'PHH')='C') loop
        select count(*) into b_i1 from temp_1 where c1=r_lp.ma;
        if b_i1=0 then insert into temp_1(c1,c2,c3,c4) values(r_lp.ma,r_lp.ma_dk,r_lp.ten,' '); end if;
    end loop;
    select JSON_ARRAYAGG(json_object('ma_lt' value c1,'ten' value c3,'ma_dk' value c2,'chon' value c4)
        order by c1,c2 returning clob) into b_oraOut from temp_1;
elsif b_so_id<>0 then
    if b_vu='dk' then
        select JSON_ARRAYAGG(json_object(ma,ten,'tien' value case when b_nt_tien='VND' then tien else round(tien/b_tygia,2) end,
            'tienC' value tien,
            'ptB' value case when b_nt_phi<>'VND' then decode(sign(pt-100),1,round(pt/b_tygia,2),pt) else pt end,
            'pt' value '',cap,tc,ma_ct,ma_dk,
            nv,t_suat,lkeM,lkeP,lkeB,luy,bt,lbh,'ptk' value decode(sign(pt-50),1,'T','P'))
            order by bt returning clob) into b_oraOut from bh_phh_phi_dk where so_id=b_so_id and nv<>'M' order by bt;
    elsif b_vu='pvi' then
        insert into temp_1(c1,c2,n1,n2,c3,c4,n3,c5) select ma,ten,ptTS,ptKH,ktru,tc,bt,loai from bh_phh_phiP_dk where so_id=b_so_id order by bt;
        for r_lp in (select ma,ten,tc,loai from bh_phh_pvi where loai='P') loop
            select count(*) into b_i1 from temp_1 where c1=r_lp.ma;
            if b_i1=0 then insert into temp_1(c1,c2,n1,n2,c3,c4,n3,c5) values(r_lp.ma,r_lp.ten,0,0,'',r_lp.tc,0,r_lp.loai); end if;
        end loop;
        select JSON_ARRAYAGG(json_object('ma' value c1,'ten' value c2,'ptTSB' value n1,'ptTS' value '',
            'ptKHB' value n2,'ptKH' value '','ktru' value c3,'tc' value c4,'bt' value n3,'loai' value c5) order by n3 returning clob)
            into b_oraOut from temp_1;
    end if;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_BPHId_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_i1 number; b_ma_ct varchar2(10);
    b_nhom varchar2(1); b_ma_sp varchar2(10); b_cdich varchar2(10); b_goi varchar2(10);
    b_mrr varchar2(10); b_ngay_bd number; b_ngay_kt number; b_kt number;

    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var; dk_ma_ct pht_type.a_var; dk_kieu pht_type.a_var;
    dk_lkeM pht_type.a_var; dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var; dk_luy pht_type.a_var;
    dk_ma_dk pht_type.a_var; dk_ma_dkC pht_type.a_var; dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num;
    dk_lbh pht_type.a_var; dk_nv pht_type.a_var; dk_pt pht_type.a_num; dk_ktru pht_type.a_var;

    dkX_ma pht_type.a_var; dkX_ten pht_type.a_nvar; dkX_tc pht_type.a_var; dkX_ma_ct pht_type.a_var; dkX_kieu pht_type.a_var;
    dkX_lkeM pht_type.a_var; dkX_lkeP pht_type.a_var; dkX_lkeB pht_type.a_var; dkX_luy pht_type.a_var; --nam: dkX_ktru a_var
    dkX_ma_dk pht_type.a_var; dkX_lh_nv pht_type.a_var; dkX_t_suat pht_type.a_num; dkX_pt pht_type.a_num; dkX_ktru pht_type.a_var;

    pvi_ma pht_type.a_var; pvi_ten pht_type.a_nvar; pvi_tc pht_type.a_var;
    pvi_ptTS pht_type.a_num; pvi_ptKH pht_type.a_num; pvi_ktru pht_type.a_var;
    pvi_loai pht_type.a_var; pvi_ma_ct pht_type.a_var;

    lt_ma_dk pht_type.a_var; lt_ma_lt pht_type.a_var; lt_ten pht_type.a_nvar;
    b_dt_ct clob; b_dt_dk clob; b_dt_dkbs clob; b_dt_pvi clob; b_dt_lt clob; b_dt_khd clob; b_dt_kbt clob; b_so_id number;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_dkbs,dt_pvi,dt_lt,dt_khd,dt_kbt');
EXECUTE IMMEDIATE b_lenh into b_dt_ct,b_dt_dk,b_dt_dkbs,b_dt_pvi,b_dt_lt,b_dt_khd,b_dt_kbt using b_oraIn;
FKH_JS_NULL(b_dt_ct); FKH_JSa_NULL(b_dt_dk); FKH_JSa_NULL(b_dt_dkbs); FKH_JSa_NULL(b_dt_pvi);
FKH_JSa_NULL(b_dt_lt); FKH_JSa_NULL(b_dt_khd); FKH_JSa_NULL(b_dt_kbt);
b_lenh:=FKH_JS_LENH('nhom,ma_sp,cdich,goi,mrr,ngay_bd,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_ma_sp,b_cdich,b_goi,b_mrr,b_ngay_bd,b_ngay_kt using b_dt_ct;
b_nhom:=nvl(trim(b_nhom),'H');
if trim(b_ma_sp) is null then
    b_loi:='loi:Nhap san pham:loi'; raise PROGRAM_ERROR;
elsif FBH_PHH_SP_HAN(b_ma_sp)<>'C' then
    b_loi:='loi:Ma san pham '||b_ma_sp||'da het su dung:loi'; raise PROGRAM_ERROR;
end if;
if trim(b_cdich) is null then
    b_cdich:=' ';
elsif FBH_MA_CDICH_HAN(b_cdich)<>'C' then
    b_loi:='loi:Da het chien dich:loi'; raise PROGRAM_ERROR;
end if;
if b_nhom='H' or trim(b_goi) is null then
    b_goi:=' ';
elsif FBH_PHH_GOI_HAN(b_goi)<>'C' then
    b_loi:='loi:Ma goi da het su dung:loi'; raise PROGRAM_ERROR;
end if;
if trim(b_mrr) is null then b_mrr:=' ';
elsif FBH_PHH_MRR_HAN(b_mrr)<>'C' then
    b_loi:='loi:Ma muc rui ro da het han:loi'; raise PROGRAM_ERROR;
end if;
if b_ngay_bd is null or b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
if b_ngay_kt is null or b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,pt,ma_dk,kieu,lkem,lkep,lkeb,luy,ktru');
EXECUTE IMMEDIATE b_lenh bulk collect into
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_pt,dk_ma_dk,dk_kieu,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy,dk_ktru using b_dt_dk;
b_kt:=dk_ma.count;
if b_kt=0 then b_loi:='loi:Nhap danh muc bao hiem:loi'; raise PROGRAM_ERROR; end if;
for b_lp in 1..b_kt loop
    dk_pt(b_lp):=0; dk_nv(b_lp):='C';
end loop;
EXECUTE IMMEDIATE b_lenh bulk collect into
    dkX_ma,dkX_ten,dkX_tc,dkX_ma_ct,dkX_pt,dkX_ma_dk,dkX_kieu,dkX_lkeM,dkX_lkeP,dkX_lkeB,dkX_luy,dkX_ktru using b_dt_dkbs;
for b_lp in 1..dkX_ma.count loop
    b_kt:=b_kt+1; dk_nv(b_kt):='M';
    dk_ma(b_kt):=dkX_ma(b_lp); dk_ten(b_kt):=dkX_ten(b_lp); dk_tc(b_kt):=dkX_tc(b_lp);
    dk_ma_ct(b_kt):=dkX_ma_ct(b_lp); dk_pt(b_kt):=dkX_pt(b_lp); dk_ma_dk(b_kt):=dkX_ma_dk(b_lp);
    dk_kieu(b_kt):=dkX_kieu(b_lp); dk_luy(b_kt):=dkX_luy(b_lp); dk_ktru(b_kt):=dkX_ktru(b_lp);
    dk_lkeM(b_kt):=dkX_lkeM(b_lp); dk_lkeP(b_kt):=dkX_lkeP(b_lp); dk_lkeB(b_kt):=dkX_lkeB(b_lp); 
end loop;
for b_lp in 1..dk_ma.count loop
    b_loi:='loi:Sai chi tiet dong '||to_char(b_lp)||':loi';
    if trim(dk_ma(b_lp)) is null or trim(dk_ten(b_lp)) is null then raise PROGRAM_ERROR; end if;
    dk_tc(b_lp):=nvl(trim(dk_tc(b_lp)),'C');
    dk_ma_ct(b_lp):=nvl(trim(dk_ma_ct(b_lp)),' ');
    if dk_ma(b_lp)=dk_ma_ct(b_lp) then b_loi:='loi:Trung ma cap tren ma: '||dk_ma(b_lp)||':loi'; raise PROGRAM_ERROR; end if;
    if dk_tc(b_lp)='C' then
        dk_lkeM(b_lp):=nvl(trim(dk_lkeM(b_lp)),'G'); dk_lkeP(b_lp):=nvl(trim(dk_lkeP(b_lp)),'G');
        dk_lkeB(b_lp):=nvl(trim(dk_lkeB(b_lp)),'G');
    else
        dk_lkeM(b_lp):=nvl(trim(dk_lkeM(b_lp)),'K'); dk_lkeP(b_lp):=nvl(trim(dk_lkeP(b_lp)),'T'); 
        dk_lkeB(b_lp):=nvl(trim(dk_lkeB(b_lp)),'T');
    end if;
    dk_kieu(b_lp):=nvl(trim(dk_kieu(b_lp)),'T'); dk_ma_dk(b_lp):=nvl(trim(dk_ma_dk(b_lp)),' ');
  dk_luy(b_lp):=nvl(trim(dk_luy(b_lp)),'C'); dk_ktru(b_lp):=nvl(trim(dk_ktru(b_lp)),'K');
    if dk_ma_dk(b_lp)<>' ' then
        if dk_nv(b_lp)<>'M' then
            if FBH_MA_DK_HAN(dk_ma_dk(b_lp))='K' then
                b_loi:='loi:Dieu khoan: '||dk_ma_dk(b_lp)||' da het su dung:loi'; raise PROGRAM_ERROR;
            end if;
            dk_lbh(b_lp):=FBH_PHH_LBH_LOAI(dk_ma(b_lp));
            dk_lh_nv(b_lp):=FBH_MA_DK_LHNV(dk_ma_dk(b_lp));
            dk_ma_dkC(b_lp):=' ';
        else
            dk_lbh(b_lp):=' ';
            if FBH_MA_DKBS_HAN(dk_ma_dk(b_lp))='K' then
                b_loi:='loi:Dieu khoan: '||dk_ma_dk(b_lp)||' da het su dung:loi'; raise PROGRAM_ERROR;
            end if;
            dk_ma_dkC(b_lp):=FBH_MA_DKBS_MA_DK(dk_ma_dk(b_lp));
            for b_lp1 in 1..dk_ma.count loop
                if dk_nv(b_lp1)<>'M' and dk_ma_dk(b_lp1)=dk_ma_dkC(b_lp) then
                    dk_lbh(b_lp):=FBH_PHH_LBH_LOAI(dk_ma_dk(b_lp1)); exit;
                end if;
            end loop;
            dk_lh_nv(b_lp):=FBH_MA_DKBS_LHNV(dk_ma_dk(b_lp));
        end if;
        dk_t_suat(b_lp):=FBH_MA_LHNV_THUE(dk_lh_nv(b_lp));
    else
        dk_lh_nv(b_lp):=' '; dk_t_suat(b_lp):=0; dk_lbh(b_lp):=' '; dk_ma_dkC(b_lp):=' ';
    end if;
end loop;
for b_lp in 1..dk_ma.count loop
    b_i1:=b_lp+1;
    for b_lp1 in b_i1..dk_ma.count loop
        if dk_ma(b_lp)=dk_ma(b_lp1) then b_loi:='loi:Trung ma: '||dk_ma(b_lp)||':loi'; raise PROGRAM_ERROR; end if;
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
b_lenh:=FKH_JS_LENH('ma,ptts,ptkh,ktru,loai,ma_ct');
EXECUTE IMMEDIATE b_lenh bulk collect into pvi_ma,pvi_ptTS,pvi_ptKH,pvi_ktru,pvi_loai,pvi_ma_ct using b_dt_pvi;
if pvi_ma.count=0 then b_loi:='loi:Nhap pham vi:loi'; raise PROGRAM_ERROR; end if;
for b_lp in 1..pvi_ma.count loop
    pvi_ma(b_lp):=nvl(trim(pvi_ma(b_lp)),' '); pvi_ktru(b_lp):=nvl(trim(pvi_ktru(b_lp)),' ');
    if pvi_ma(b_lp)=' ' then b_loi:='loi:Nhap ma pham vi dong '||to_char(b_lp)||':loi'; raise PROGRAM_ERROR; end if;
    if FBH_PHH_PVI_HAN(pvi_ma(b_lp))<>'C' then
        b_loi:='loi:Pham vi: '||pvi_ma(b_lp)||' da het su dung:loi'; raise PROGRAM_ERROR;
    end if;
    pvi_ten(b_lp):=FBH_PHH_PVI_TEN(pvi_ma(b_lp)); pvi_tc(b_lp):=FBH_PHH_PVI_TC(pvi_ma(b_lp));
  pvi_loai(b_lp):=nvl(trim(pvi_loai(b_lp)),'C'); pvi_ma_ct(b_lp):=nvl(trim(pvi_ma_ct(b_lp)),' ');
  if pvi_loai(b_lp) not in('C','D','B','M','P') then
    b_loi:='loi:Sai loai pham vi: '||pvi_ma(b_lp)||':loi'; raise PROGRAM_ERROR;
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
b_so_id:=FBH_PHH_BPHId_SO_ID(b_nhom,b_ma_sp,b_cdich,b_goi,b_mrr);
if b_so_id<>0 then
    delete bh_phh_phi_txt where so_id=b_so_id;
    delete bh_phh_phi_lt where so_id=b_so_id;
    delete bh_phh_phi_dk where so_id=b_so_id;
    delete bh_phh_phiP_dk where so_id=b_so_id;
    delete bh_phh_phi where so_id=b_so_id;
else
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
insert into bh_phh_phi values(b_ma_dvi,b_so_id,b_nhom,b_ma_sp,b_cdich,b_goi,b_mrr,b_ngay_bd,b_ngay_kt,b_nsd);
for b_lp in 1..dk_ma.count loop
    insert into bh_phh_phi_dk values(b_ma_dvi,b_so_id,b_lp,dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),
        0,dk_pt(b_lp),0,dk_lkeM(b_lp),dk_lkeP(b_lp),dk_lkeB(b_lp),dk_luy(b_lp),dk_ma_dk(b_lp),dk_ma_dkC(b_lp),
    dk_lh_nv(b_lp),dk_t_suat(b_lp),0,dk_lbh(b_lp),dk_nv(b_lp),dk_ktru(b_lp));
end loop;
for r_lp in(select * from
    (select bt,level from bh_phh_phi_dk where so_id=b_so_id start with ma_ct=' ' CONNECT BY prior ma=ma_ct)) loop
    update bh_phh_phi_dk set cap=r_lp.level where so_id=b_so_id and bt=r_lp.bt;
end loop;
for b_lp in 1..pvi_ma.count loop
    insert into bh_phh_phiP_dk values(b_ma_dvi,b_so_id,b_lp,pvi_ma(b_lp),pvi_ten(b_lp),
    pvi_ptTS(b_lp),pvi_ptKH(b_lp),pvi_ktru(b_lp),pvi_tc(b_lp),pvi_loai(b_lp),pvi_ma_ct(b_lp));
end loop;
insert into bh_phh_phi_txt values(b_ma_dvi,b_so_id,'dt_ct',b_dt_ct);
insert into bh_phh_phi_txt values(b_ma_dvi,b_so_id,'dt_dk',b_dt_dk);
if length(b_dt_dkbs)<>0 then
    insert into bh_phh_phi_txt values(b_ma_dvi,b_so_id,'dt_dkbs',b_dt_dkbs);
end if;
if length(b_dt_pvi)<>0 then
    insert into bh_phh_phi_txt values(b_ma_dvi,b_so_id,'dt_pvi',b_dt_pvi);
end if;
if lt_ma_lt.count<>0 then
    for b_lp in 1..lt_ma_lt.count loop
        insert into bh_phh_phi_lt values(b_ma_dvi,b_so_id,b_lp,lt_ma_lt(b_lp),lt_ma_dk(b_lp),lt_ten(b_lp));
    end loop;
    insert into bh_phh_phi_txt values(b_ma_dvi,b_so_id,'dt_lt',b_dt_lt);
end if;
if length(b_dt_khd)<>0 then
    insert into bh_phh_phi_txt values(b_ma_dvi,b_so_id,'dt_khd',b_dt_khd);
end if;
if length(b_dt_kbt)<>0 then
    insert into bh_phh_phi_txt values(b_ma_dvi,b_so_id,'dt_kbt',b_dt_kbt);
end if;
commit;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_BPHId_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS 
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Dan - Xoa bieu phi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then b_loi:='loi:Chon bieu phi can xoa:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table bh_phh_phi:loi';
delete bh_phh_phi_txt where so_id=b_so_id;
delete bh_phh_phi_lt where so_id=b_so_id;
delete bh_phh_phi_dk where so_id=b_so_id;
delete bh_phh_phiP_dk where so_id=b_so_id;
delete bh_phh_phi where so_id=b_so_id;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_DTUONG_LIST(b_tso varchar2,b_loi out varchar2)
AS
     b_lenh varchar2(1000); b_ma_sp varchar2(20); b_cdich varchar2(20); b_goi varchar2(20);
     b_nv varchar2(1);
begin
-- viet anh -- loc ma doi tuong theo sp,cdich,goi
b_loi:='loi:Loi xu ly PBH_PHH_DTUONG_LIST:loi';
b_lenh:=FKH_JS_LENH('ma_sp,cdich,goi,nv');
EXECUTE IMMEDIATE b_lenh into b_ma_sp,b_cdich,b_goi,b_nv using b_tso;
b_ma_sp:=nvl(trim(b_ma_sp),' '); b_cdich:=nvl(trim(b_cdich),' '); b_goi:=nvl(trim(b_goi),' ');
insert into bh_kh_hoi_temp1 select c.ma,c.ten from bh_phh_phi a, bh_phh_nhom b, bh_phh_dtuong c
       where b_ma_sp in (' ',a.ma_sp) and b_cdich in (' ',a.cdich) and b_goi in (' ',a.goi) and a.mrr=b.mrr 
             and b.ma=c.nhom and a.nhom=b_nv order by c.ten;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
