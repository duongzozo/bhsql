/* Ma ke hoach */
create or replace function FBH_KE_THU_MA_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_ke_thu_ma where ma=b_ma and tc='C';
return b_kq;
end;
/
create or replace function FBH_KE_THU_MA_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_ke_thu_ma where ma=b_ma and tc='C';
return b_kq;
end;
/
create or replace function FBH_KE_THU_MA_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_ke_thu_ma where ma=b_ma and tc='C' and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_KE_THU_MA_XEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngay number:=PKH_NG_CSO(sysdate); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma) into b_oraOut from bh_ke_thu_ma where tc='C' and ngay_kt>b_ngay;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_THU_MA_LKE(
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
    select count(*) into b_dong from bh_ke_thu_ma;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep)) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_ke_thu_ma order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ke_thu_ma where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma)) into cs_lke from
        (select a.*,rownum sott from bh_ke_thu_ma a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_THU_MA_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(20); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_ke_thu_ma;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_ke_thu_ma order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_ke_thu_ma order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep)) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_ke_thu_ma order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ke_thu_ma where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_ke_thu_ma where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma)) into cs_lke from
        (select a.*,rownum sott from bh_ke_thu_ma a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_THU_MA_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(20):=FKH_JS_GTRIs(b_oraIn,'ma'); cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma chua nhap hoac da xoa:loi';
select json_object(ma,txt) into cs_ct from bh_ke_thu_ma  where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_THU_MA_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(20); b_ten nvarchar2(500); b_tc varchar2(1);
    b_ma_ct varchar2(20); b_loai varchar2(10); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,loai,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_tc,b_ma_ct,b_loai,b_ngay_kt using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_tc is null or b_tc<>'T' then b_tc:='C'; end if;
if trim(b_ma_ct) is null then
    b_ma_ct:=' ';
else
    b_loi:='loi:Sai ma cap tren:loi';
    if b_ma=b_ma_ct then raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from bh_ke_thu_ma where ma=b_ma_ct and tc='T';
end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_ke_thu_ma where ma=b_ma;
insert into bh_ke_thu_ma values(b_ma_dvi,b_ma,b_ten,b_tc,b_ma_ct,b_loai,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_THU_MA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(20):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_ke_thu_ma where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_ke_thu_ma where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* DOI TUONG */
create or replace function FBH_KE_THU_DT_HAN(b_nv varchar2,b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_ke_thu_dt where nv=b_nv and ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_KE_THU_DT_TEN(b_nv varchar2,b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_ke_thu_dt where nv=b_nv and ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_KE_THU_DT_TENl(b_nv varchar2,b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_ke_thu_dt where nv=b_nv and ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_KE_THU_DT_XEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_nv varchar2(10):=nvl(trim(b_oraIn),' '); b_ngay number:=PKH_NG_CSO(sysdate);
    cs_nhom clob; cs_lhnv clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into cs_nhom
    from bh_ke_thu_dt where nv=b_nv and tc='C' and ngay_kt>=b_ngay;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into cs_lhnv
    from bh_ma_lhnv where tc='C' and ngay_kt>=b_ngay and FBH_MA_NV_CO(nv,b_nv)='C';
select json_object('cs_nhom' value cs_nhom,'cs_lhnv' value cs_lhnv) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_THU_DT_LKE(
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
    select count(*) into b_dong from bh_ke_thu_dt;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(nv,xep,ten,ma)) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_ke_thu_dt order by nv,ma) a
            start with ma_ct=' ' CONNECT BY prior nv=nv and ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ke_thu_dt where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(nv,'xep' value ma,ten,ma)) into cs_lke from
        (select a.*,rownum sott from bh_ke_thu_dt a where upper(ten) like b_tim order by nv,ma)
    where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_THU_DT_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(20); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_ke_thu_dt;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_ke_thu_dt order by nv,ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_ke_thu_dt order by nv,ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(nv,xep,ten,ma)) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_ke_thu_dt order by nv,ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ke_thu_dt where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_ke_thu_dt where upper(ten) like b_tim order by nv,ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(nv,'xep' value ma,ma,ten)) into cs_lke from
        (select a.*,rownum sott from bh_ke_thu_dt a where upper(ten) like b_tim order by nv,ma)
    where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_THU_DT_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_nv varchar2(10); b_ma varchar2(20);
    dt_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,ma');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ma using b_oraIn;
if trim(b_nv) is null or trim(b_ma) is null then b_loi:='loi:Nhap nghiep vu va ma:loi'; raise PROGRAM_ERROR; end if;
select json_object(nv,ma,ten,tc,ma_ct,ngay_kt) into dt_ct from bh_ke_thu_dt where nv=b_nv and ma=b_ma;
select json_object('cs_ct' value dt_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_THU_DT_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_nv varchar2(10); b_ma varchar2(20); b_ten nvarchar2(500);
    b_tc varchar(1); b_ma_ct varchar2(20); b_ngay_kt number;
    b_txt clob:=b_oraIn;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FKH_JS_NULL(b_txt);
b_lenh:=FKH_JS_LENH('nv,ma,ten,tc,ma_ct,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ma,b_ten,b_tc,b_ma_ct,b_ngay_kt using b_txt;
if b_nv=' ' or b_ma=' ' or b_ten=' ' then b_loi:='loi:Nhap nghiep vu,ma,ten:loi'; raise PROGRAM_ERROR; end if;
if b_tc<>'T' then b_tc:='C'; end if;
if b_ma_ct<>' ' then
    b_loi:='loi:Sai ma cap tren:loi';
    if b_ma=b_ma_ct then raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from bh_ke_thu_dt where ma=b_ma_ct and tc='T';
end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
delete bh_ke_thu_dt where nv=b_nv and ma=b_ma;
insert into bh_ke_thu_dt values(b_ma_dvi,b_nv,b_ma,b_ten,b_tc,b_ma_ct,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_THU_DT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number; b_nv varchar2(10); b_ma varchar2(20);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,ma');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ma using b_oraIn;
if trim(b_nv) is null or trim(b_ma) is null then b_loi:='loi:Nhap nghiep vu va ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_ke_thu_dt where nv=b_nv and ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_ke_thu_dt where nv=b_nv and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* Tham so doi tuong */
create or replace procedure PBH_KE_THU_TSO_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_nv varchar2(10);
begin
-- Dan - 
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_nv:=nvl(trim(b_oraIn),' ');
select count(*) into b_i1 from bh_ke_thu_tso where nv=b_nv;
if b_i1<>1 then
    b_oraOut:='';
else
    select txt into b_oraOut from bh_ke_thu_tso where nv=b_nv;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_THU_TSO_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_nv varchar2(10); dt_ttt clob;
    a_ma pht_type.a_var; a_ten pht_type.a_nvar; a_loai pht_type.a_var; a_bb pht_type.a_var; a_ktra pht_type.a_var;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_nv:=FKH_JS_GTRIs(b_oraIn,'nv');
b_lenh:=FKH_JS_LENHc('dt_ttt');
EXECUTE IMMEDIATE b_lenh into dt_ttt using b_oraIn;
FKH_JSa_NULL(dt_ttt);
b_lenh:=FKH_JS_LENH('ma,ten,loai,bb,ktra');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma,a_ten,a_loai,a_bb,a_ktra using dt_ttt;
if a_ma.count=0 then b_loi:='loi:Nhap thong tin:loi'; raise PROGRAM_ERROR; end if;
for b_lp in 1..a_ma.count loop
    if a_ma(b_lp)=' ' or a_ten(b_lp)=' ' then
        b_loi:='loi:Nhap sai dong '||to_char(b_lp)||':loi'; raise PROGRAM_ERROR;
    end if;
    if a_loai(b_lp) not in('H','S','N','G') then a_loai(b_lp):='C'; end if;
    if a_bb(b_lp)<>'C' then a_bb(b_lp):='K'; end if;
end loop;
b_loi:='loi:Va cham NSD:loi';
delete bh_ke_thu_tso where nv=b_nv;
insert into bh_ke_thu_tso values(b_ma_dvi,b_nv,b_nsd,dt_ttt);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_THU_TSO_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_nv varchar2(10):=trim(b_oraIn);
begin
-- Dan - 
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham NSD:loi';
delete bh_ke_thu_tso where nv=b_nv;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* Chi tieu doi tuong */
create or replace procedure PBH_KE_THU_CTI_NV(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_nv varchar2(10):=nvl(trim(b_oraIn),' '); dt_nh clob; dt_cti clob;
begin
-- Dan - Tra tham so
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_ke_thu_tso where nv=b_nv;
if b_i1<>1 then b_loi:='loi:Chua nhap tham so doi tuong:loi'; raise PROGRAM_ERROR; end if;
select txt into dt_cti from bh_ke_thu_tso where nv=b_nv;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into dt_nh from bh_ke_thu_dt where nv=b_nv and tc='C';
select json_object('dt_nh' value dt_nh,'dt_cti' value dt_cti returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_THU_CTI_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000);
    b_nv varchar2(10); b_tu number; b_den number;
    b_dong number; cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,tu,den');
EXECUTE IMMEDIATE b_lenh into b_nv,b_tu,b_den using b_oraIn;
b_nv:=nvl(trim(b_nv),' ');
select count(*) into b_dong from bh_ke_thu_cti;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(ngay_hl,'ten' value FBH_KE_THU_DT_TEN(nv,ma),so_id) order by ngay_hl,ma returning clob) into cs_lke from
    (select nv,ngay_hl,ma,so_id,rownum sott from bh_ke_thu_cti where nv=b_nv order by ngay_hl,ma)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_THU_CTI_LKE_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_tu number; b_den number;
    b_nv varchar2(10); b_ma varchar2(20); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,ma,hangkt');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ma,b_hangkt using b_oraIn;
if b_nv is null or b_ma is null then b_loi:='loi:Nhap nghiep vu va ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_ke_thu_cti;
select nvl(min(sott),0) into b_tu from (select ma,rownum sott from bh_ke_thu_cti where nv=b_nv order by ma) where ma>=b_ma;
PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(ngay_hl,'ten' value FBH_KE_THU_DT_TEN(nv,ma),so_id) order by ngay_hl,ma returning clob) into cs_lke from
    (select nv,ngay_hl,ma,so_id,rownum sott from bh_ke_thu_cti where nv=b_nv order by ngay_hl,ma)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_THU_CTI_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
    dt_ct clob; dt_cti clob;
begin
-- Dan - CT
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_ke_thu_cti_txt where so_id=b_so_id;
if b_i1=0 then b_loi:='loi:Chua nhap chi tieu nhom:loi'; raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(nv,'ma' value FBH_KE_THU_DT_TENl(nv,ma),ngay_hl) order by ngay_hl,ma returning clob)
    into dt_ct from bh_ke_thu_cti where so_id=b_so_id;
select txt into dt_cti from bh_ke_thu_cti_txt where so_id=b_so_id and loai='dt_cti';
select json_object('so_id' value b_so_id,'dt_ct' value dt_ct,'dt_cti' value dt_cti returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_THU_CTI_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_i1 number; b_lenh varchar2(1000);
    b_so_id number; b_nv varchar2(10); b_ma varchar2(20); b_ngay_hl number;
    a_ma pht_type.a_var; a_ten pht_type.a_nvar; a_loai pht_type.a_var;
    a_tu_dk pht_type.a_var; a_tu_nd pht_type.a_var;
    a_den_dk pht_type.a_var; a_den_nd pht_type.a_var;
    dt_ct clob; dt_cti clob;
begin
-- Dan - Nhap thong tin them chung tu theo nghiep vu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_cti');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_cti using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_cti);
b_lenh:=FKH_JS_LENH('nv,ma,ngay_hl');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ma,b_ngay_hl using dt_ct;
b_lenh:=FKH_JS_LENH('ma,ten,loai,tu_dk,tu_nd,den_dk,den_nd');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma,a_ten,a_loai,a_tu_dk,a_tu_nd,a_den_dk,a_den_nd using dt_cti;
if b_nv=' ' or b_ma=' ' then b_loi:='loi:Nhap nghiep vu va nhom:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_hl in(0,30000101) then b_ngay_hl:=PKH_NG_CSO(sysdate); end if;
select nvl(min(so_id),0) into b_so_id from bh_ke_thu_cti where nv=b_nv and ma=b_ma and ngay_hl=b_ngay_hl;
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
else
    delete bh_ke_thu_cti_ct where so_id=b_so_id;
    delete bh_ke_thu_cti_txt where so_id=b_so_id;
    delete bh_ke_thu_cti where so_id=b_so_id;
end if;
b_i1:=0;
insert into bh_ke_thu_cti values(b_ma_dvi,b_so_id,b_nv,b_ma,b_ngay_hl,b_nsd);
for b_lp in 1..a_ma.count loop
    if a_ma(b_lp)<>' ' and ((a_tu_dk(b_lp)<>' ' and a_tu_nd(b_lp)<>' ') or (a_den_dk(b_lp)<>' ' and a_den_nd(b_lp)<>' ')) then
        insert into bh_ke_thu_cti_ct values(b_so_id,a_ma(b_lp),a_ten(b_lp),a_loai(b_lp),
            a_tu_dk(b_lp),a_tu_nd(b_lp),a_den_dk(b_lp),a_den_nd(b_lp),b_lp);
        b_i1:=b_i1+1;
    end if;
end loop;
if b_i1=0 then b_loi:='loi:Nhap chi tieu nhom:loi'; raise PROGRAM_ERROR; end if;
insert into bh_ke_thu_cti_txt values(b_so_id,'dt_ct',dt_ct);
insert into bh_ke_thu_cti_txt values(b_so_id,'dt_cti',dt_cti);
select json_object('so_id' value b_so_id) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_THU_CTI_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(1000); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Dan - Nhap thong tin them chung tu theo nghiep vu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete bh_ke_thu_cti_ct where so_id=b_so_id;
delete bh_ke_thu_cti_txt where so_id=b_so_id;
delete bh_ke_thu_cti where so_id=b_so_id;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* Co che chi */
create or replace function FBH_KE_CHI_MA_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_ke_chi_ma where ma=b_ma and tc='C';
return b_kq;
end;
/
create or replace function FBH_KE_CHI_MA_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_ke_chi_ma where ma=b_ma and tc='C';
return b_kq;
end;
/
create or replace function FBH_KE_CHI_MA_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_ke_chi_ma where ma=b_ma and tc='C' and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_KE_CHI_MA_XEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngay number:=PKH_NG_CSO(sysdate); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma) into cs_lke from bh_ke_chi_ma a where tc='C' and ngay_kt>b_ngay;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_CHI_MA_LKE(
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
    select count(*) into b_dong from bh_ke_chi_ma;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep)) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_ke_chi_ma order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ke_chi_ma where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma)) into cs_lke from
        (select a.*,rownum sott from bh_ke_chi_ma a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_CHI_MA_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(20); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_ke_chi_ma;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_ke_chi_ma order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_ke_chi_ma order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep)) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_ke_chi_ma order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ke_chi_ma where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_ke_chi_ma where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma)) into cs_lke from
        (select a.*,rownum sott from bh_ke_chi_ma a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_CHI_MA_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(20):=FKH_JS_GTRIs(b_oraIn,'ma'); cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma chua nhap hoac da xoa:loi';
select json_object(ma,txt) into cs_ct from bh_ke_chi_ma  where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_CHI_MA_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(20); b_ten nvarchar2(500); b_tc varchar2(1);
    b_ma_ct varchar2(20); b_loai varchar2(10); b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,loai,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_tc,b_ma_ct,b_loai,b_ngay_kt using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_tc is null or b_tc<>'T' then b_tc:='C'; end if;
if trim(b_ma_ct) is null then
    b_ma_ct:=' ';
else
    b_loi:='loi:Sai ma cap tren:loi';
    if b_ma=b_ma_ct then raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from bh_ke_chi_ma where ma=b_ma_ct and tc='T';
end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_ke_chi_ma where ma=b_ma;
insert into bh_ke_chi_ma values(b_ma_dvi,b_ma,b_ten,b_tc,b_ma_ct,b_loai,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_CHI_MA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(20):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_ke_chi_ma where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_ke_chi_ma where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* Tham so doi tac */
create or replace procedure PBH_KE_KHTSO_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_nv varchar2(10);
begin
-- Dan - 
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_nv:=nvl(trim(b_oraIn),' ');
select count(*) into b_i1 from bh_ke_khtso where nv=b_nv;
if b_i1<>1 then
    b_oraOut:='';
else
    select txt into b_oraOut from bh_ke_khtso where nv=b_nv;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_KHTSO_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_nv varchar2(10); dt_ttt clob;
    a_ma pht_type.a_var; a_ten pht_type.a_nvar; a_diem pht_type.a_num;
    a_loai pht_type.a_var; a_bb pht_type.a_var; a_ktra pht_type.a_var;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_nv:=FKH_JS_GTRIs(b_oraIn,'nv');
b_lenh:=FKH_JS_LENHc('dt_ttt');
EXECUTE IMMEDIATE b_lenh into dt_ttt using b_oraIn;
FKH_JSa_NULL(dt_ttt);
b_lenh:=FKH_JS_LENH('ma,ten,diem,loai,bb,ktra');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma,a_ten,a_diem,a_loai,a_bb,a_ktra using dt_ttt;
if a_ma.count=0 then b_loi:='loi:Nhap thong tin:loi'; raise PROGRAM_ERROR; end if;
for b_lp in 1..a_ma.count loop
    if a_ma(b_lp)=' ' or a_ten(b_lp)=' ' then
        b_loi:='loi:Nhap sai dong '||to_char(b_lp)||':loi'; raise PROGRAM_ERROR;
    end if;
    if a_loai(b_lp) not in('H','S','N','G') then a_loai(b_lp):='C'; end if;
    if a_bb(b_lp)<>'C' then a_bb(b_lp):='K'; end if;
end loop;
b_loi:='loi:Va cham NSD:loi';
delete bh_ke_khtso where nv=b_nv;
insert into bh_ke_khtso values(b_ma_dvi,b_nv,b_nsd,dt_ttt);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_KHTSO_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_nv varchar2(10):=trim(b_oraIn);
begin
-- Dan - Xem thong tin them chung tu theo nghiep vu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham NSD:loi';
delete bh_ke_khtso where nv=b_nv;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* Chi tieu doi tac */
create or replace procedure PBH_KE_KHCTI_NV(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_nv varchar2(10):=nvl(trim(b_oraIn),' '); dt_nh clob; dt_cti clob;
begin
-- Dan - Tra tham so
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_ke_khtso where nv=b_nv;
if b_i1<>1 then b_loi:='loi:Chua nhap tham so doi tac:loi'; raise PROGRAM_ERROR; end if;
select txt into dt_cti from bh_ke_khtso where nv=b_nv;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into dt_nh from bh_dtac_khpl where nv=b_nv;
select json_object('dt_nh' value dt_nh,'dt_cti' value dt_cti returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_KHCTI_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000);
    b_nv varchar2(10); b_tu number; b_den number;
    b_dong number; cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,tu,den');
EXECUTE IMMEDIATE b_lenh into b_nv,b_tu,b_den using b_oraIn;
b_nv:=nvl(trim(b_nv),' ');
select count(*) into b_dong from bh_ke_khcti;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(
    ngay_hl,'ten' value FBH_DTAC_KHPL_TEN(nv,ma),so_id) order by ngay_hl,ma returning clob) into cs_lke from
    (select nv,ngay_hl,ma,so_id,rownum sott from bh_ke_khcti where nv=b_nv order by ngay_hl,ma)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_KHCTI_LKE_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_tu number; b_den number;
    b_nv varchar2(10); b_ma varchar2(20); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,ma,hangkt');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ma,b_hangkt using b_oraIn;
if b_nv is null or b_ma is null then b_loi:='loi:Nhap doi tac va ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_ke_khcti;
select nvl(min(sott),0) into b_tu from (select ma,rownum sott from bh_ke_khcti where nv=b_nv order by ma) where ma>=b_ma;
PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(
    ngay_hl,'ten' value FBH_DTAC_KHPL_TEN(nv,ma),so_id) order by ngay_hl,ma returning clob) into cs_lke from
    (select nv,ngay_hl,ma,so_id,rownum sott from bh_ke_khcti where nv=b_nv order by ngay_hl,ma)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_KHCTI_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
    dt_ct clob; dt_cti clob;
begin
-- Dan - CT
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_ke_khcti_txt where so_id=b_so_id;
if b_i1=0 then b_loi:='loi:Chua nhap chi tieu nhom doi tac:loi'; raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(nv,'ma' value FBH_DTAC_KHPL_TENl(nv,ma),ngay_hl) order by ngay_hl,ma returning clob)
    into dt_ct from bh_ke_khcti where so_id=b_so_id;
select txt into dt_cti from bh_ke_khcti_txt where so_id=b_so_id and loai='dt_cti';
select json_object('so_id' value b_so_id,'dt_ct' value dt_ct,'dt_cti' value dt_cti returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_KHCTI_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_i1 number; b_lenh varchar2(1000);
    b_so_id number; b_nv varchar2(10); b_ma varchar2(20); b_ngay_hl number;
    a_ma pht_type.a_var; a_ten pht_type.a_nvar; a_loai pht_type.a_var;
    a_tu_dk pht_type.a_var; a_tu_nd pht_type.a_var;
    a_den_dk pht_type.a_var; a_den_nd pht_type.a_var;
    dt_ct clob; dt_cti clob;
begin
-- Dan - Nhap thong tin them chung tu theo nghiep vu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_cti');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_cti using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_cti);
b_lenh:=FKH_JS_LENH('nv,ma,ngay_hl');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ma,b_ngay_hl using dt_ct;
b_lenh:=FKH_JS_LENH('ma,ten,loai,tu_dk,tu_nd,den_dk,den_nd');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma,a_ten,a_loai,a_tu_dk,a_tu_nd,a_den_dk,a_den_nd using dt_cti;
if a_ma.count=0 then b_loi:='loi:Nhap chi tieu nhomdoi tac:loi'; raise PROGRAM_ERROR; end if;
if b_nv=' ' or b_ma=' ' then b_loi:='loi:Nhap doi tac va nhom:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_hl in(0,30000101) then b_ngay_hl:=PKH_NG_CSO(sysdate); end if;
select nvl(min(so_id),0) into b_so_id from bh_ke_khcti where nv=b_nv and ma=b_ma and ngay_hl=b_ngay_hl;
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
else
    delete bh_ke_khcti_ct where so_id=b_so_id;
    delete bh_ke_khcti_txt where so_id=b_so_id;
    delete bh_ke_khcti where so_id=b_so_id;
end if;
b_i1:=0;
insert into bh_ke_khcti values(b_ma_dvi,b_so_id,b_nv,b_ma,b_ngay_hl,b_nsd);
for b_lp in 1..a_ma.count loop
    if a_ma(b_lp)<>' ' or (a_tu_dk(b_lp)<>' ' and a_tu_nd(b_lp)<>' ') or (a_den_dk(b_lp)<>' ' and a_den_nd(b_lp)<>' ') then
        insert into bh_ke_khcti_ct values(b_so_id,a_ma(b_lp),a_ten(b_lp),a_loai(b_lp),
            a_tu_dk(b_lp),a_tu_nd(b_lp),a_den_dk(b_lp),a_den_nd(b_lp),b_lp);
        b_i1:=b_i1+1;
    end if;
end loop;
if b_i1=0 then b_loi:='loi:Nhap doi tac va nhom:loi'; raise PROGRAM_ERROR; end if;
insert into bh_ke_khcti_txt values(b_so_id,'dt_ct',dt_ct);
insert into bh_ke_khcti_txt values(b_so_id,'dt_cti',dt_cti);
select json_object('so_id' value b_so_id) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_KHCTI_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(1000); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Dan - Nhap thong tin them chung tu theo nghiep vu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete bh_ke_khcti_ct where so_id=b_so_id;
delete bh_ke_khcti_txt where so_id=b_so_id;
delete bh_ke_khcti where so_id=b_so_id;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Tai khoan phan bo
create or replace procedure PBH_KE_TK_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngay_bd number:=FKH_JS_GTRIn(b_oraIn,'ngay_bd');
    dt_ct varchar2(100); dt_dk clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma_tk,ma_tke,pp,bt) order by bt returning clob) into dt_dk
    from bh_ke_tk where ngay_bd=b_ngay_bd;
select json_object('ngay_bd' value b_ngay_bd) into dt_ct from dual;
select json_object('dt_ct' value dt_ct,'dt_dk' value dt_dk) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_TK_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ngay_bd) order by ngay_bd desc) into b_oraOut
    from (select distinct ngay_bd from bh_ke_tk);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_TK_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_ngay_bd number:=FKH_JS_GTRIn(b_oraIn,'ngay_bd');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete bh_ke_tk where ngay_bd=b_ngay_bd;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_TK_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(1000); b_i1 number; b_lenh varchar2(1000); b_ngay_bd number;
    a_ma_tk pht_type.a_var; a_ma_tke pht_type.a_var; a_pp pht_type.a_var;
    dt_ct clob; dt_dk clob;
begin
-- Dan - Nhap thong tin them chung tu theo nghiep vu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk);
b_lenh:=FKH_JS_LENH('ngay_bd');
EXECUTE IMMEDIATE b_lenh into b_ngay_bd using dt_ct;
b_lenh:=FKH_JS_LENH('ma_tk,ma_tke,pp');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma_tk,a_ma_tke,a_pp using dt_dk;
if a_ma_tk.count=0 then b_loi:='loi:Nhap tai khoan:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
delete bh_ke_tk where ngay_bd=b_ngay_bd;
for b_lp in 1..a_ma_tk.count loop
    insert into bh_ke_tk values(b_ma_dvi,a_ma_tk(b_lp),a_ma_tke(b_lp),a_pp(b_lp),b_ngay_bd,b_nsd,b_lp);
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
