-- Ma nguyen nhan ton that
create or replace function FBH_PKT_NNTT_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_pkt_nntt where ma=b_ma and tc='C';
return b_kq;
end;
/
create or replace function FBH_PKT_NNTT_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_pkt_nntt where ma=b_ma and tc='C';
return b_kq;
end;
/
create or replace function FBH_PKT_NNTT_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_pkt_nntt where ma=b_ma and tc='C' and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_PKT_NNTT_XEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngay number:=PKH_NG_CSO(sysdate); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma) into cs_lke from bh_pkt_nntt a where tc='C' and ngay_kt>b_ngay;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_NNTT_LKE(
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
    select count(*) into b_dong from bh_pkt_nntt;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep)) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_pkt_nntt order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_pkt_nntt where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma)) into cs_lke from
        (select a.*,rownum sott from bh_pkt_nntt a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_NNTT_MA(
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
    select count(*) into b_dong from bh_pkt_nntt;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_pkt_nntt order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_pkt_nntt order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep)) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_pkt_nntt order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_pkt_nntt where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_pkt_nntt where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma)) into cs_lke from
        (select a.*,rownum sott from bh_pkt_nntt a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_NNTT_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma'); cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma chua nhap hoac da xoa:loi';
select json_object(ma,txt) into cs_ct from bh_pkt_nntt  where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_NNTT_NH
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
    select 0 into b_i1 from bh_pkt_nntt where ma=b_ma_ct and tc='T';
end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_pkt_nntt where ma=b_ma;
insert into bh_pkt_nntt values(b_ma_dvi,b_ma,b_ten,b_tc,b_ma_ct,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--duchq import dia danh muc nguyen nhan ton that ky thuat
create or replace procedure PBH_PKT_NNTT_NHf
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
	b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    a_ma pht_type.a_var; a_ten pht_type.a_nvar; a_tc pht_type.a_var;
    a_ma_ct pht_type.a_var; a_ngay_kt pht_type.a_num;
	b_txt clob:='"{}"';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,ngay_kt');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma,a_ten,a_tc,a_ma_ct,a_ngay_kt using b_oraIn;
for b_lp in 1..a_ma.count loop
	if trim(a_ma(b_lp)) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
	if trim(a_ten(b_lp)) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
	if a_tc(b_lp) is null or a_tc(b_lp)<>'T' then a_tc(b_lp):='C'; end if;
	if trim(a_ma_ct(b_lp)) is null then
		a_ma_ct(b_lp):=' ';
	else
		b_loi:='loi:Sai ma cap tren:loi';
		if a_ma(b_lp)=a_ma_ct(b_lp) then raise PROGRAM_ERROR; end if;
		select 0 into b_i1 from bh_pkt_nntt where ma=a_ma_ct(b_lp) and tc='T';
	end if;
	a_ngay_kt(b_lp):=nvl(a_ngay_kt(b_lp),0);
	if a_ngay_kt(b_lp)=0 then a_ngay_kt(b_lp):=30000101; end if;
	b_loi:='';
	delete bh_pkt_nntt where ma=a_ma(b_lp);
	PKH_JS_THAYa(b_txt,'ma,ten,tc,ma_ct,ngay_kt',a_ma(b_lp) || ',' || a_ten(b_lp) || ',' || a_tc(b_lp) || ',' || a_ma_ct(b_lp) || ',' || a_ngay_kt(b_lp));
	insert into bh_pkt_nntt values(b_ma_dvi,a_ma(b_lp),a_ten(b_lp),a_tc(b_lp),a_ma_ct(b_lp),a_ngay_kt(b_lp),b_nsd,b_txt);
end loop;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_NNTT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_pkt_nntt where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_pkt_nntt where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Dieu kien thi cong
create or replace function FBH_PKT_MA_DKTC_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_pkt_ma_dktc where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_PKT_MA_DKTC_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_pkt_ma_dktc where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_PKT_MA_DKTC_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_pkt_ma_dktc where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_PKT_MA_DKTC_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into cs_lke from bh_pkt_ma_dktc;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_DKTC_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_pkt_ma_dktc;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_pkt_ma_dktc;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_DKTC_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_pkt_ma_dktc;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_pkt_ma_dktc;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_DKTC_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,ngay_kt) into b_kq from bh_pkt_ma_dktc where ma=b_ma;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_DKTC_NH
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
delete bh_pkt_ma_dktc where ma=b_ma;
insert into bh_pkt_ma_dktc values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_DKTC_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_pkt_ma_dktc where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Dieu kien dia ly
create or replace function FBH_PKT_MA_DKDL_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_pkt_ma_dkdl where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_PKT_MA_DKDL_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_pkt_ma_dkdl where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_PKT_MA_DKDL_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_pkt_ma_dkdl where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_PKT_MA_DKDL_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into cs_lke from bh_pkt_ma_dkdl;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_DKDL_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_pkt_ma_dkdl;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_pkt_ma_dkdl;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_DKDL_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_pkt_ma_dkdl;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_pkt_ma_dkdl;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_DKDL_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,ngay_kt) into b_kq from bh_pkt_ma_dkdl where ma=b_ma;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_DKDL_NH
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
delete bh_pkt_ma_dkdl where ma=b_ma;
insert into bh_pkt_ma_dkdl values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_DKDL_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_pkt_ma_dkdl where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Nhom may thiet bi
create or replace function FBH_PKT_MA_NTB_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_pkt_ma_ntb where ma=b_ma and tc='C';
return b_kq;
end;
/
create or replace function FBH_PKT_MA_NTB_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_pkt_ma_ntb where ma=b_ma and tc='C';
return b_kq;
end;
/
create or replace function FBH_PKT_MA_NTB_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_pkt_ma_ntb where ma=b_ma and tc='C' and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_PKT_MA_NTB_XEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngay number:=PKH_NG_CSO(sysdate); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma) into cs_lke from bh_pkt_ma_ntb a where tc='C' and ngay_kt>b_ngay;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_NTB_LKE(
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
    select count(*) into b_dong from bh_pkt_ma_ntb;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep)) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_pkt_ma_ntb order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_pkt_ma_ntb where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma)) into cs_lke from
        (select a.*,rownum sott from bh_pkt_ma_ntb a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_NTB_MA(
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
    select count(*) into b_dong from bh_pkt_ma_ntb;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_pkt_ma_ntb order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_pkt_ma_ntb order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep)) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_pkt_ma_ntb order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_pkt_ma_ntb where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_pkt_ma_ntb where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma)) into cs_lke from
        (select a.*,rownum sott from bh_pkt_ma_ntb a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_NTB_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma'); cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma chua nhap hoac da xoa:loi';
select json_object(ma,txt) into cs_ct from bh_pkt_ma_ntb  where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_NTB_NH
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
    select 0 into b_i1 from bh_pkt_ma_ntb where ma=b_ma_ct and tc='T';
end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_pkt_ma_ntb where ma=b_ma;
insert into bh_pkt_ma_ntb values(b_ma_dvi,b_ma,b_ten,b_tc,b_ma_ct,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_NTB_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_pkt_ma_ntb where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_pkt_ma_ntb where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Cap cong trinh
create or replace function FBH_PKT_MA_CCT_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_pkt_ma_cct where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_PKT_MA_CCT_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_pkt_ma_cct where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_PKT_MA_CCT_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_pkt_ma_cct where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_PKT_MA_CCT_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into cs_lke from bh_pkt_ma_cct;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_CCT_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_pkt_ma_cct;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_pkt_ma_cct;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_CCT_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_pkt_ma_cct;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_pkt_ma_cct;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_CCT_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten,ngay_kt) into b_kq from bh_pkt_ma_cct where ma=b_ma;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_CCT_NH
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
delete bh_pkt_ma_cct where ma=b_ma;
insert into bh_pkt_ma_cct values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_CCT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_pkt_ma_cct where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Nhom cong trinh
create or replace function FBH_PKT_MA_NCT_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ten) into b_kq from bh_pkt_ma_nct where ma=b_ma and tc='C';
return b_kq;
end;
/
create or replace function FBH_PKT_MA_NCT_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_pkt_ma_nct where ma=b_ma and tc='C';
return b_kq;
end;
/
create or replace function FBH_PKT_MA_NCT_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_pkt_ma_nct where ma=b_ma and tc='C' and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_PKT_MA_NCT_XEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngay number:=PKH_NG_CSO(sysdate); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma) into cs_lke from bh_pkt_ma_nct a where tc='C' and ngay_kt>b_ngay;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_NCT_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number:=0; cs_lke clob:=''; b_i1 number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_pkt_ma_nct;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep)) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_pkt_ma_nct order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    -- chuclh: tao phan cap cha con theo b_tim
    delete from temp_1; commit;
    insert into temp_1(c1,c2,c3,c4) 
           select distinct a.ma,a.ten,a.nsd,a.ma_ct from bh_pkt_ma_nct a 
           start with a.ma in (select ma from bh_pkt_ma_nct  where upper(ten) like b_tim) CONNECT BY prior a.ma_ct=a.ma;
    select count(*) into b_i1 from temp_1;
    if b_i1 > 0 then
        select count(*) into b_dong from temp_1;
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object('ma' value c1,'ten' value c2,'nsd' value c3,xep)) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||a.c1,20) xep from temp_1 a
             start with a.c4=' ' CONNECT BY prior a.c1=a.c4) b)
        where sott between b_tu and b_den;
    end if;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_NCT_MA(
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
    select count(*) into b_dong from bh_pkt_ma_nct;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_pkt_ma_nct order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_pkt_ma_nct order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep)) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_pkt_ma_nct order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_pkt_ma_nct where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_pkt_ma_nct where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma)) into cs_lke from
        (select a.*,rownum sott from bh_pkt_ma_nct a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_NCT_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma'); cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma chua nhap hoac da xoa:loi';
select json_object(ma,txt) into cs_ct from bh_pkt_ma_nct  where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_CTRINH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); bil number;  b_ma varchar2(20):=FKH_JS_GTRIs(b_oraIn,'ma');
    cs_ct clob:='';
begin
-- Dan - Tra ttin ma
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into bil from bh_pkt_ma_nct where ma=b_ma;
if bil<>0 then
  select min(ma||'|'||ten) into cs_ct from bh_pkt_ma_nct where ma=b_ma;
  end if;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_NCT_NH
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
    select 0 into b_i1 from bh_pkt_ma_nct where ma=b_ma_ct and tc='T';
end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_pkt_ma_nct where ma=b_ma;
insert into bh_pkt_ma_nct values(b_ma_dvi,b_ma,b_ten,b_tc,b_ma_ct,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--duchq import dia danh muc loai cong trinh ky thuat
create or replace procedure PBH_PKT_MA_NCT_NHf
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    a_ma pht_type.a_var; a_ten pht_type.a_nvar; a_tc pht_type.a_var;
    a_ma_ct pht_type.a_var; a_ngay_kt pht_type.a_num;
	b_txt clob:='"{}"';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,ngay_kt');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma,a_ten,a_tc,a_ma_ct,a_ngay_kt using b_oraIn;
for b_lp in 1..a_ma.count loop
	if trim(a_ma(b_lp)) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
	if trim(a_ten(b_lp)) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
	if a_tc(b_lp) is null or a_tc(b_lp)<>'T' then a_tc(b_lp):='C'; end if;
	if trim(a_ma_ct(b_lp)) is null then
		a_ma_ct(b_lp):=' ';
	else
		b_loi:='loi:Sai ma cap tren:loi';
		if a_ma(b_lp)=a_ma_ct(b_lp) then raise PROGRAM_ERROR; end if;
		select 0 into b_i1 from bh_pkt_ma_nct where ma=a_ma_ct(b_lp) and tc='T';
	end if;
	a_ngay_kt(b_lp):=nvl(a_ngay_kt(b_lp),0);
	if a_ngay_kt(b_lp)=0 then a_ngay_kt(b_lp):=30000101; end if;
	b_loi:='';
	delete bh_pkt_ma_nct where ma=a_ma(b_lp);
	PKH_JS_THAYa(b_txt,'ma,ten,tc,ma_ct,ngay_kt',a_ma(b_lp) || ',' || a_ten(b_lp) || ',' || a_tc(b_lp) || ',' || a_ma_ct(b_lp) || ',' || a_ngay_kt(b_lp));
	insert into bh_pkt_ma_nct values(b_ma_dvi,a_ma(b_lp),a_ten(b_lp),a_tc(b_lp),a_ma_ct(b_lp),a_ngay_kt(b_lp),b_nsd,b_txt);
end loop;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_NCT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_pkt_ma_nct where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_pkt_ma_nct where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Ty le phi / tgian BH
create or replace function FBH_PKT_TLTG_TLE(b_ngay_hl number,b_ngay_kt number) return number
AS
    b_kq number:=0; b_i1 number; b_th number:=FKH_KHO_THSO(b_ngay_hl,b_ngay_kt); b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Tra ty le phi < 12 thang
if b_th<12 then
    select nvl(max(tltg),0) into b_i1 from bh_pkt_tltg where tltg<=b_th and b_ngay between ngay_bd and ngay_kt;
    if b_i1<>0 then
        select tlph into b_kq from bh_pkt_tltg where tltg=b_i1 and b_ngay between ngay_bd and ngay_kt;
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
create or replace procedure PBH_PKT_TLTG_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_tltg number:=FKH_JS_GTRIs(b_oraIn,'tltg');
    cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Thoi gian da xoa:loi';
select json_object(tltg,tlph,ngay_bd,ngay_kt) into cs_ct from bh_pkt_tltg where tltg=b_tltg;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_TLTG_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(tltg,tlph,nsd) order by tltg) into cs_lke from bh_pkt_tltg;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_TLTG_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000);
    b_tltg number; b_tlph number; b_ngay_bd number; b_ngay_kt number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tltg,tlph,ngay_bd,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_tltg,b_tlph,b_ngay_bd,b_ngay_kt using b_oraIn;
if b_tltg is null then b_loi:='loi:Nhap so thang:loi'; raise PROGRAM_ERROR; end if;
if b_tlph is null then b_loi:='loi:Nhap ty le phi:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
delete bh_pkt_tltg where tltg=b_tltg;
insert into bh_pkt_tltg values(b_ma_dvi,b_tltg,b_tlph,b_ngay_bd,b_ngay_kt,b_nsd);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_TLTG_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn cLob)
AS
    b_loi varchar2(100); b_tltg number:=FKH_JS_GTRIs(b_oraIn,'tltg');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_tltg is null then b_loi:='loi:Nhap thoi gian:loi'; raise PROGRAM_ERROR; end if;
delete bh_pkt_tltg where tltg=b_tltg;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_TLTG_TLE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_ngay_hl number; b_ngay_kt number; b_tlph number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_bd,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ngay_hl,b_ngay_kt using b_oraIn;
b_tlph:=FBH_PKT_TLTG_TLE(b_ngay_hl,b_ngay_kt);
select json_object('tlph' value b_tlph) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* San pham */
create or replace function FBH_PKT_MA_SP_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ten) into b_kq from bh_pkt_sp where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_PKT_MA_SP_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_pkt_sp where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_PKT_MA_SP_HAN(b_ma varchar2,b_dk varchar2:='C') return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_pkt_sp where ma=b_ma and tc in('C',b_dk) and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_PKT_MA_SP_LKE(
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
    select count(*) into b_dong from bh_pkt_sp;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(* returning clob) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_pkt_sp order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_pkt_sp where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(a.*,'xep' value ma) obj from bh_pkt_sp a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_SP_MA(
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
    select count(*) into b_dong from bh_pkt_sp;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_pkt_sp order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_pkt_sp order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep,rownum sott from
                (select * from bh_pkt_sp order by ma) a
                start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_pkt_sp where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_pkt_sp where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(a.*,'xep' value ma) obj from bh_pkt_sp a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_SP_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma'); cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma da xoa:loi';
select json_object(ma,txt returning clob) into cs_ct from bh_pkt_sp where ma=b_ma;
select json_object('cs_ct' value cs_ct returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_SP_NH
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
    select 0 into b_i1 from bh_pkt_sp where ma=b_ma_ct and tc='T';
end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_pkt_sp where ma=b_ma;
insert into bh_pkt_sp values(b_ma_dvi,b_ma,b_ten,b_tc,b_ma_ct,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_MA_SP_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_pkt_sp where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_pkt_sp where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* Ma pham vi*/
create or replace function FBH_PKT_PVI_TC(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra tc
select nvl(min(tc),'C') into b_kq from bh_pkt_pvi where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_PKT_PVI_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_pkt_pvi where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_PKT_PVI_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_pkt_pvi where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_PKT_PVI_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_pkt_pvi where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_PKT_PVI_LKE(
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
    select count(*) into b_dong from bh_pkt_pvi;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,ROW_NUMBER() over (order by ma) as sott from
            (select * from bh_pkt_pvi order by ma))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_pkt_pvi where upper(ma) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,ROW_NUMBER() over (order by ma) as sott from
            (select ma,json_object(a.*,'xep' value ma) obj from bh_pkt_pvi a)
            where upper(ma) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_PVI_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_pkt_pvi;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_pkt_pvi;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_PVI_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(txt returning clob) into b_kq from bh_pkt_pvi where ma=b_ma;
select json_object('cs_ct' value b_kq returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_PVI_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_tc varchar2(1); b_ten nvarchar2(500); b_ngay_kt number;
    b_loai varchar2(1); b_ma_ct varchar2(10); b_ma_dk varchar2(200); 
    b_ma_qtac varchar2(200):= FKH_JS_GTRIc(b_oraIn,'ma_qtac');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,loai,ma_ct,ma_dk,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_tc,b_loai,b_ma_ct,b_ma_dk,b_ngay_kt using b_oraIn;
b_ma_dk:=PKH_MA_TENl(b_ma_dk); b_ma_qtac:=PKH_MA_TENl(b_ma_qtac);
b_ma:=nvl(trim(b_ma),' '); b_ten:=nvl(trim(b_ten),' ');
if b_ma=' ' or b_ten=' ' then b_loi:='loi:Nhap ma,ten:loi'; raise PROGRAM_ERROR; end if;
b_tc:=nvl(trim(b_tc),' '); b_loai:=nvl(trim(b_loai),' ');
if b_loai not in('C','D','B','M','P') then b_loi:='loi:Sai loai:loi'; raise PROGRAM_ERROR; end if;
if b_tc not in('C','T') then b_loi:='loi:Sai tinh chat:loi'; raise PROGRAM_ERROR; end if;
b_ma_ct:=nvl(trim(b_ma_ct),' ');
if b_ma_ct<>' ' then
    if b_ma_ct=b_ma then b_loi:='loi:Trung ma:loi'; raise PROGRAM_ERROR; end if;
    select count(*) into b_i1 from bh_pkt_pvi where ma=b_ma_ct;
    if b_i1=0 then  b_loi:='loi:Ma cap tren chua dang ky:loi'; raise PROGRAM_ERROR; end if;
end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_pkt_pvi where ma=b_ma;
insert into bh_pkt_pvi values(b_ma_dvi,b_ma,b_tc,b_ten,b_loai,b_ma_ct,b_ma_dk,b_ma_qtac,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--duchq import dia danh muc pham vi ky thuat
create or replace procedure PBH_PKT_PVI_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_pkt_pvi where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* Ma loai BH */
create or replace function FBH_PKT_LBH_LOAI(b_ma varchar2) return varchar2
AS
    b_kq varchar2(5);
begin
-- Dan - Kiem tra con hieu luc
select nvl(min(loai),' ') into b_kq from bh_pkt_lbh where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_PKT_LBH_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_pkt_lbh where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_PKT_LBH_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_pkt_lbh where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_PKT_LBH_LKE(
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
    select count(*) into b_dong from bh_pkt_lbh;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select * from bh_pkt_lbh order by ma))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_pkt_lbh where upper(ma) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,json_object(a.*,'xep' value ma) obj from bh_pkt_lbh a)
            where upper(ma) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_LBH_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_pkt_lbh;
select JSON_ARRAYAGG(json_object(*) order by ma returning clob) into cs_lke from bh_pkt_lbh;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--duchq update xem chi tiet lay tu txt
create or replace procedure PBH_PKT_LBH_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,txt) into b_kq from bh_pkt_lbh where ma=b_ma;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_LBH_NH
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
if b_loai not in('TS','BI','KH') then b_loi:='loi:Sai loai:loi'; raise PROGRAM_ERROR; end if;
if b_ma_ct<>' ' then
    select count(*) into b_i1 from bh_pkt_lbh where ma=b_ma_ct;
    if b_i1=0 then b_loi:='loi:Sai ma bac cao:loi'; raise PROGRAM_ERROR; return; end if;
end if;
b_ma_dk:=nvl(trim(b_ma_dk),' ');
if b_ma_dk<>' ' and FBH_MA_DK_HAN(b_ma_dk)='K' then
    b_loi:='loi:Dieu khoan da het su dung:loi'; raise PROGRAM_ERROR;
end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_pkt_lbh where ma=b_ma;
insert into bh_pkt_lbh values(b_ma_dvi,b_ma,b_loai,b_ten,b_tc,b_ma_ct,b_ma_dk,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--duchq import dia danh muc loai bao hiem ky thuat
create or replace procedure PBH_PKT_LBH_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_pkt_lbh where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Bieu phi
/*** BIEU PHI ***/
create or replace procedure PBH_PKT_BPHI_TSO(
    b_oraIn clob,b_nhom out varchar2,b_ma_sp out varchar2,b_ma_nct out varchar2,
    b_rru out varchar2,b_ma_ntb out nvarchar2,b_ngay_hl out number)
AS
    b_lenh varchar2(1000);
begin
-- Dan - Tra tso
b_lenh:=FKH_JS_LENH('nhom,ma_sp,ma_nct,rru,ma_ntb,ngay_hl');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_ma_sp,b_ma_nct,b_rru,b_ma_ntb,b_ngay_hl using b_oraIn;
 b_ma_sp:=PKH_MA_TENl(b_ma_sp); b_ma_nct:=PKH_MA_TENl(b_ma_nct); b_ma_ntb:=PKH_MA_TENl(b_ma_ntb);
b_nhom:=nvl(trim(b_nhom),' '); b_rru:=nvl(trim(b_rru),' ');
b_ngay_hl:=nvl(b_ngay_hl,0);
end;
/
create or replace procedure PBH_PKT_BPHI_TSOt(
    b_ma_sp varchar2,b_ma_cct varchar2,b_ma_nct varchar2,b_ma_dkdl varchar2,
  b_ma_dktc varchar2,b_rru varchar2,b_ma_ntb nvarchar2,b_loi out varchar2)
AS
begin
-- Dan - Ktra tso
if b_ma_sp<>' ' and  FBH_PKT_SP_HAN(b_ma_sp)<>'C' then
    b_loi:='loi:Ma san pham '||b_ma_sp||'da het su dung:loi'; return;
end if;
if b_ma_cct<>' ' and  FBH_PKT_MA_CCT_HAN(b_ma_cct)<>'C' then
    b_loi:='loi:Ma cap C.trinh '||b_ma_cct||'da het su dung:loi'; return;
end if;
if b_ma_nct<>' ' and  FBH_PKT_MA_NCT_HAN(b_ma_nct)<>'C' then
    b_loi:='loi:Ma nhom C.trinh '||b_ma_nct||'da het su dung:loi'; return;
end if;
if b_ma_ntb<>' ' and  FBH_PKT_MA_NTB_HAN(b_ma_ntb)<>'C' then
    b_loi:='loi:Ma loai thiet bi '||b_ma_ntb||'da het su dung:loi'; return;
end if;
if b_ma_dkdl<>' ' and  FBH_PKT_MA_DKDL_HAN(b_ma_dkdl)<>'C' then
    b_loi:='loi:Ma dieu kien dia ly '||b_ma_dkdl||'da het su dung:loi'; return;
end if;
if b_ma_dktc<>' ' and  FBH_PKT_MA_DKTC_HAN(b_ma_dktc)<>'C' then
    b_loi:='loi:Ma dieu kien thi cong '||b_ma_dktc||'da het su dung:loi'; return;
end if;
b_loi:='';
end;
/
create or replace function FBH_PKT_BPHI_SO_ID(
    b_nhom varchar2,b_ma_sp varchar2,b_ma_nct varchar2,b_rru varchar2,b_ma_ntb varchar2,b_ngay_hl number:=0) return number
AS
    b_so_id number;
begin
-- Dan - Tra so ID phi
select nvl(max(so_id),0) into b_so_id from bh_pkt_phi where
    nhom in('T',b_nhom) and ma_sp=b_ma_sp and
    ma_nct=b_ma_nct and rru=b_rru and ma_ntb=b_ma_ntb and b_ngay_hl between ngay_bd and ngay_kt;
return b_so_id;
end;
/
create or replace procedure PBH_PKT_BPHI_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number; b_ngay_hl number;
    b_nhom varchar2(1); b_ma_sp varchar2(500);b_ma_nct varchar2(500);
    b_rru varchar2(1); b_ma_ntb varchar2(10);
begin
-- Dan - Tra so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_PKT_BPHI_TSO(b_oraIn,b_nhom,b_ma_sp,b_ma_nct,b_rru,b_ma_ntb,b_ngay_hl);
b_so_id:=FBH_PKT_BPHI_SO_ID(b_nhom,b_ma_sp,b_ma_nct,b_rru,' ',b_ngay_hl);
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_BPHI_LBHt(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_oraOut:=FBH_PKT_LBH_TEN(b_oraIn);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_BPHI_LBH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,tc,ma_ct,ma_dk) returning clob) into cs_lke from
    (select ma,tc,ma_ct,ma_dk,rpad(lpad('-',2*(level-1),'-')||ten,50) ten from
    (select * from bh_pkt_lbh order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct);
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_BPHI_DKBS(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,'ma_dk' value ma,lh_nv) order by ma returning clob) into cs_lke
    from bh_ma_dkbs where FBH_MA_NV_CO(nv,'PKT')='C' order by ma;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_BPHI_LT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma_dk,ten,'ma_lt' value ma)) into cs_lke
    from bh_ma_dklt a where FBH_MA_NV_CO(nv,'PKT')='C' and FBH_MA_DKLT_HAN(ma_dk,ma)='C' and MA <> ' ';
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_BPHI_PVI(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob; b_i1 number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_pkt_pvi where loai='T';
if b_i1=0 then
    select JSON_ARRAYAGG(json_object(ma,ten,tc,loai,ma_ct) order by ma returning clob) into cs_lke from bh_pkt_pvi order by ma;
else
    select JSON_ARRAYAGG(json_object(ma,tc,loai,ma_ct,
        'ten' value decode(loai,'T',ten,'--'||ten)) order by ma returning clob) into cs_lke from bh_pkt_pvi order by ma;
end if;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_BPHI_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_ngay number:=PKH_NG_CSO(sysdate);
    b_loi varchar2(100); cs_sp clob; cs_lt clob; cs_khd clob; cs_kbt clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ten) into cs_sp from bh_pkt_sp where FBH_PKT_SP_HAN(ma)='C';
select JSON_ARRAYAGG(json_object(ma_dk,ten,'ma_lt' value ma)) into cs_lt
    from bh_ma_dklt a where FBH_MA_NV_CO(nv,'PKT')='C' and FBH_MA_DKLT_HAN(ma_dk,ma)='C' and MA <> ' '; -- ma = ' ' la goc
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt) into cs_khd from bh_kh_ttt where ps='KHD' and nv='PKT';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt) into cs_kbt from bh_kh_ttt where ps='KBT' and nv='PKT';
select json_object('cs_sp' value cs_sp,'cs_lt' value cs_lt,'cs_khd' value cs_khd,'cs_kbt' value cs_kbt) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_BPHI_MOs(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_sp clob;
begin
-- Dan- Liet ke san pham
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ten) into cs_sp from bh_pkt_ma_sp where FBH_PKT_SP_HAN(ma)='C';
select json_object('cs_sp' value cs_sp) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- nam
create or replace procedure PBH_PKT_BPHI_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_nhom varchar2(1); b_ma_sp varchar2(500); b_rru varchar2(1); b_ma_nct varchar2(500);
    b_ma_ntb varchar2(500); b_tu number; b_den number; b_dong number; cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nhom,ma_sp,rru,ma_nct,ma_ntb,tu,den');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_ma_sp,b_rru,b_ma_nct,b_ma_ntb,b_tu,b_den using b_oraIn;
b_ma_sp:=PKH_MA_TENl(b_ma_sp);
b_ma_nct:=PKH_MA_TENl(b_ma_nct);
b_ma_ntb:=PKH_MA_TENl(b_ma_ntb);
select count(*) into b_dong from bh_pkt_phi where b_nhom in (' ',nhom) and b_ma_sp in (' ',ma_sp) and b_rru in (' ',rru)
       and b_ma_nct in (' ',ma_nct) and b_ma_ntb in (' ',ma_ntb);
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(nhom,'ma_sp' value FBH_PKT_MA_SP_TEN(ma_sp),
       'ma_nct' value FBH_PKT_MA_NCT_TEN(ma_nct),'ma_ntb' value FBH_PKT_MA_NTB_TEN(ma_ntb),rru,ngay_bd,ngay_kt,nsd,so_id)
    order by nhom,ma_sp,ma_nct,ma_ntb,rru returning clob) into cs_lke from
    (select nhom,ma_sp,ma_nct,ma_ntb,rru,ngay_bd,ngay_kt,nsd,so_id,rownum sott
    from bh_pkt_phi where b_nhom in (' ',nhom) and b_ma_sp in (' ',ma_sp) and b_rru in (' ',rru) 
         and b_ma_nct in (' ',ma_nct) and b_ma_ntb in (' ',ma_ntb) order by nhom,ma_sp,ma_nct,ma_ntb,rru)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_BPHI_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_i1 number;
    b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
    dt_khd clob:=''; dt_kbt clob:=''; dt_ct clob; dt_dk clob; dt_dkbs clob; dt_pvi clob; dt_lt clob; dt_txt clob;
begin
-- Dan - Xem chi tiet theo so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Bieu phi da xoa:loi';
select JSON_ARRAYAGG(json_object(
    so_id,nhom,'ma_sp' value FBH_PKT_MA_SP_TENl(ma_sp),
    'ma_cct' value FBH_PKT_MA_CCT_TENl(ma_cct),'ma_nct' value FBH_PKT_MA_NCT_TENl(ma_nct),
    'ma_dkdl' value FBH_PKT_MA_DKDL_TENl(ma_dkdl),'ma_dktc' value FBH_PKT_MA_DKTC_TENl(ma_dktc),
    'ma_ntb' value FBH_PKT_MA_NTB_TENl(ma_ntb)) returning clob)
    into dt_ct from bh_pkt_phi where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ma,cap) order by bt returning clob) into dt_dk from bh_pkt_phi_dk where so_id=b_so_id and nv<>'M';
select JSON_ARRAYAGG(json_object(ma,cap) order by bt returning clob) into dt_dkbs from bh_pkt_phi_dk where so_id=b_so_id and nv='M';
select JSON_ARRAYAGG(json_object(ma,ten) order by bt returning clob) into dt_pvi from bh_pkt_phiP_dk where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ma_lt) order by bt returning clob) into dt_lt from bh_pkt_phi_lt where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_pkt_phi_txt where so_id=b_so_id and loai in('dt_ct','dt_dk','dt_dkbs','dt_pvi','dt_lt');
select count(*) into b_i1 from bh_pkt_phi_txt where so_id=b_so_id and loai='dt_khd';
if b_i1<>0 then
    select txt into dt_khd from bh_pkt_phi_txt where so_id=b_so_id and loai='dt_khd';
end if;
select count(*) into b_i1 from bh_pkt_phi_txt where so_id=b_so_id and loai='dt_kbt';
if b_i1<>0 then
    select txt into dt_kbt from bh_pkt_phi_txt where so_id=b_so_id and loai='dt_kbt';
end if;
select json_object('so_id' value b_so_id,'dt_khd' value dt_khd,'dt_kbt' value dt_kbt,'dt_ct' value dt_ct,
    'dt_dk' value dt_dk,'dt_dkbs' value dt_dkbs,'dt_pvi' value dt_pvi,'dt_lt' value dt_lt,
    'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_BPHI_CTs(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number; b_ngay_hl number;
    b_nhom varchar2(1); b_ma_sp varchar2(10); b_ma_nct varchar2(500);
    b_rru varchar2(1); b_ma_ntb nvarchar2(500);
begin
-- Dan - Tra so_id bieu phi theo dieu kien
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_PKT_BPHI_TSO(b_oraIn,b_nhom,b_ma_sp,b_ma_nct,b_rru,b_ma_ntb,b_ngay_hl);
b_so_id:=FBH_PKT_BPHI_SO_ID(b_nhom,b_ma_sp,b_ma_nct,b_rru,b_ma_ntb,b_ngay_hl);
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_BPHI_CTd(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_so_id number; b_nt_phi varchar2(5); b_tygia number;
    cs_dk clob; cs_dkbs clob; cs_pvi clob; dt_khd clob:=''; cs_kbt clob:=''; cs_lt clob; cs_txt clob;
begin
-- Dan - Tra bieu phi theo so_id
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,nt_phi,tygia');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_nt_phi,b_tygia using b_oraIn;
b_nt_phi:=NVL(trim(b_nt_phi),'VND');
if b_tygia is null or b_tygia=0 then b_tygia:=1; end if;
if b_nt_phi='VND' or b_tygia=1 then
    select JSON_ARRAYAGG(json_object(ma,ma_dk,ten,cap,ma_ct,lkeM,'ptB' value pt,'pt' value '','bt' value bt) order by bt returning clob)
           into cs_dk from bh_pkt_phi_dk where so_id=b_so_id and nv<>'M' order by bt;
    select JSON_ARRAYAGG(json_object(ma,ten,lbh,'ptB' value pt,'pt' value '',ma_dkc,
           'ptK' value decode(sign(pt-50),1,'T','P'),
           'bt' value bt) order by bt returning clob)
           into cs_dkbs from bh_pkt_phi_dk where so_id=b_so_id and nv='M' order by bt;
    select JSON_ARRAYAGG(json_object(ma,ten,'ptTSB' value ptTS,'ptTS' value '',
           'ptKHB' value ptKH,'ptKH' value '',ktru,tc,loai,
           'ptkTS' value decode(sign(ptTS-50),1,'T','P'),
           'ptkKH' value decode(sign(ptKH-50),1,'T','P'),
           'bt' value bt) order by bt returning clob)
           into cs_pvi from bh_pkt_phiP_dk where so_id=b_so_id order by bt;
else 
    select JSON_ARRAYAGG(json_object(ma,ma_dk,ten,cap,ma_ct,lkeM,'ptB' value pt,'pt' value '','bt' value bt) order by bt returning clob)
           into cs_dk from bh_pkt_phi_dk where so_id=b_so_id and nv<>'M' order by bt;
    select JSON_ARRAYAGG(json_object(ma,ten,lbh,'pt' value '',ma_dkc,
            'ptB' value decode(sign(pt-50),1,round(pt/b_tygia,2),pt),
            'ptK' value decode(sign(pt-50),1,'T','P'),
            'bt' value bt) order by bt returning clob)
            into cs_dkbs from bh_pkt_phi_dk where so_id=b_so_id and nv='M' order by bt;
    select JSON_ARRAYAGG(json_object(ma,ten,
            'ptTSB' value decode(sign(ptTS-50),1,round(ptTS/b_tygia,2),ptTS),'ptTS' value '',
            'ptKHB' value decode(sign(ptKH-50),1,round(ptKH/b_tygia,2),ptKH),'ptKH' value '',ktru,tc,loai,
            'ptkTS' value decode(sign(ptTS-50),1,'T','P'),
            'ptkKH' value decode(sign(ptKH-50),1,'T','P'),
            'bt' value bt) order by bt returning clob)
            into cs_pvi from bh_pkt_phiP_dk where so_id=b_so_id order by bt;
end if;
select JSON_ARRAYAGG(json_object(ma_lt,ten) order by bt returning clob) into cs_lt from bh_pkt_phi_lt where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into cs_txt
    from bh_pkt_phi_txt where so_id=b_so_id and loai='dt_lt';
select count(*) into b_i1 from bh_pkt_phi_txt where so_id=b_so_id and loai='dt_khd';
if b_i1<>0 then
    select txt into dt_khd from bh_pkt_phi_txt where so_id=b_so_id and loai='dt_khd';
end if;
select count(*) into b_i1 from bh_pkt_phi_txt where so_id=b_so_id and loai='dt_kbt';
if b_i1<>0 then
    select txt into cs_kbt from bh_pkt_phi_txt where so_id=b_so_id and loai='dt_kbt';
end if;
select json_object('dt_dk' value cs_dk,'dt_dkbs' value cs_dkbs,'dt_pvi' value cs_pvi,
    'dt_khd' value dt_khd,'dt_kbt' value cs_kbt,'dt_lt' value cs_lt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_BPHI_THEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_i1 number;
    b_nhom varchar2(1); b_ma_sp varchar2(10); b_ma_nct varchar2(500);
    b_rru varchar2(1); b_ma_ntb nvarchar2(500);
    b_ngay_hl number; b_so_id number; b_vu varchar2(10);
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tygia number;
    b_dk_lt clob; a_ma_lt pht_type.a_var; a_ma_dk_lt pht_type.a_var; a_ten_lt pht_type.a_nvar; a_chon_lt pht_type.a_var;
begin
-- Dan - Tra so_id bieu phi theo dieu kien
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('vu,nt_tien,nt_phi,tygia');
EXECUTE IMMEDIATE b_lenh into b_vu,b_nt_tien,b_nt_phi,b_tygia using b_oraIn;
PBH_PKT_BPHI_TSO(b_oraIn,b_nhom,b_ma_sp,b_ma_nct,b_rru,b_ma_ntb,b_ngay_hl);
b_so_id:=FBH_PKT_BPHI_SO_ID(b_nhom,b_ma_sp,b_ma_nct,b_rru,b_ma_ntb,b_ngay_hl);
b_oraOut:='';
if b_vu='dkbs' then
    select JSON_ARRAYAGG(json_object(ma,ten,'tien' value case when b_nt_tien='VND' then tien else round(tien/b_tygia,2) end,
                'ptB' value case when b_nt_phi<>'VND' then decode(sign(pt-100),1,round(pt/b_tygia,4),pt) else pt end,
                'pt' value '',ma_ct,tc,phi,cap,lh_nv,'t_suat' value FBH_MA_LHNV_THUE(lh_nv),lkeM,lkeP,bt,'ptk' value decode(sign(pt-50),1,'T','P')) order by bt,ma,ten returning clob) into b_oraOut from
        (select ma,ten,tien,pt,ma_ct,tc,phi,cap,lh_nv,lkeM,lkeP,lbh,bt
                from bh_pkt_phi_dk where so_id=b_so_id and nv='M' union
        select ma,ten,null tien,null pt,'' ma_ct,'T' tc,null phi,null cap,lh_nv,'K' lkeM,'K' lkeP,'' lbh,999 from bh_ma_dkbs where FBH_MA_NV_CO(nv,'PKT')='C');
elsif b_vu='lt' then
    select count(*) into b_i1 from bh_pkt_phi_txt where so_id=b_so_id and loai='dt_lt';
    if b_i1 >0 then
        select txt into b_dk_lt from bh_pkt_phi_txt where so_id=b_so_id and loai='dt_lt';
        b_lenh:=FKH_JS_LENH('ma_lt,ma_dk,ten,chon');
        EXECUTE IMMEDIATE b_lenh bulk collect into a_ma_lt,a_ma_dk_lt,a_ten_lt,a_chon_lt using b_dk_lt;
        if a_ma_lt.count > 0 then
        for b_i1 in 1..a_ma_lt.count loop
            insert into temp_1(c1,c2,c3,c4) VALUES (a_ma_lt(b_i1),a_ma_dk_lt(b_i1),a_ten_lt(b_i1),a_chon_lt(b_i1));
        end loop;
        end if;
    end if;
    for r_lp in (select ma,ten,ma_dk from bh_ma_dklt where FBH_MA_NV_CO(nv,'PKT')='C') loop
        select count(*) into b_i1 from temp_1 where c1=r_lp.ma;
        if b_i1=0 then insert into temp_1(c1,c2,c3,c4) values(r_lp.ma,r_lp.ten,' ',r_lp.ma_dk); end if;
    end loop;
    select JSON_ARRAYAGG(json_object('ma_lt' value c1,'ten' value c2,'ma_dk' value c3)
        order by c1,c2 returning clob) into b_oraOut from temp_1;
elsif b_so_id<>0 then
    if b_vu='dk' then
        select JSON_ARRAYAGG(json_object(ma,ten,'tien' value case when b_nt_tien='VND' then tien else round(tien/b_tygia,2) end,
            'tienC' value tien,
            'ptB' value case when b_nt_phi<>'VND' then decode(sign(pt-100),1,round(pt/b_tygia,2),pt) else pt end,
            'pt' value '',cap,tc,ma_ct,ma_dk,
            nv,t_suat,lkeM,lkeP,lkeB,luy,bt,lbh,'ptk' value decode(sign(pt-50),1,'T','P'))
            order by bt returning clob) into b_oraOut from bh_pkt_phi_dk where so_id=b_so_id and nv<>'M' order by bt;
    elsif b_vu='pvi' then
        select JSON_ARRAYAGG(json_object(ma,ten,'ptTSB' value ptTS,'ptTS' value '',
            'ptKHB' value ptKH,'ptKH' value '',ktru,tc,loai) order by bt returning clob)
            into b_oraOut from bh_pkt_phiP_dk where so_id=b_so_id order by bt;
    end if;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_BPHI_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_i1 number; b_ma_ct varchar2(10);
    b_nhom varchar2(1); b_ma_sp varchar2(500); b_ma_cct varchar2(10); b_ma_nct varchar2(10);
    b_ma_dkdl varchar2(10); b_ma_dktc varchar2(10); b_rru varchar2(1); b_ma_ntb nvarchar2(10);
    b_ngay_bd number; b_ngay_kt number; b_kt number;

    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var; dk_ma_ct pht_type.a_var; dk_kieu pht_type.a_var;
    dk_lkeM pht_type.a_var; dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var; dk_luy pht_type.a_var;
    dk_ma_dk pht_type.a_var; dk_ma_dkC pht_type.a_var; dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num;
    dk_lbh pht_type.a_var; dk_nv pht_type.a_var; dk_pt pht_type.a_num; dk_ktru pht_type.a_var;

    dkX_ma pht_type.a_var; dkX_ten pht_type.a_nvar; dkX_tc pht_type.a_var; dkX_ma_ct pht_type.a_var; dkX_kieu pht_type.a_var;
    dkX_lkeM pht_type.a_var; dkX_lkeP pht_type.a_var; dkX_lkeB pht_type.a_var; dkX_luy pht_type.a_var; dkX_ktru pht_type.a_var;
    dkX_ma_dk pht_type.a_var; dkX_pt pht_type.a_num;

    pvi_ma pht_type.a_var; pvi_ten pht_type.a_nvar; pvi_tc pht_type.a_var;
    pvi_ptTS pht_type.a_num; pvi_ptKH pht_type.a_num; pvi_ktru pht_type.a_var;
	  pvi_loai pht_type.a_var; pvi_ma_ct pht_type.a_var;

    lt_ma_dk pht_type.a_var; lt_ma_lt pht_type.a_var; lt_ten pht_type.a_nvar;
    b_dt_ct clob; b_dt_dk clob; b_dt_dkbs clob; b_dt_pvi clob; b_dt_lt clob; b_dt_khd clob; b_dt_kbt clob; b_so_id number;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_dkbs,dt_pvi,dt_lt,dt_khd,dt_kbt');
EXECUTE IMMEDIATE b_lenh into b_dt_ct,b_dt_dk,b_dt_dkbs,b_dt_pvi,b_dt_lt,b_dt_khd,b_dt_kbt using b_oraIn;
FKH_JS_NULL(b_dt_ct); FKH_JSa_NULL(b_dt_dk); FKH_JSa_NULL(b_dt_dkbs); FKH_JSa_NULL(b_dt_pvi);
FKH_JSa_NULL(b_dt_lt); FKH_JSa_NULL(b_dt_khd); FKH_JSa_NULL(b_dt_kbt);
PBH_PKT_BPHI_TSO(b_dt_ct,b_nhom,b_ma_sp,b_ma_nct,b_rru,b_ma_ntb,b_i1);
PBH_PKT_BPHI_TSOt(b_ma_sp,b_ma_cct,b_ma_nct,b_ma_dkdl,b_ma_dktc,b_rru,b_ma_ntb,b_loi);
b_lenh:=FKH_JS_LENH('ngay_bd,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ngay_bd,b_ngay_kt using b_dt_ct;
if b_nhom not in('G','H','T') then b_loi:='loi:Sai nhom '||b_nhom||':loi'; raise PROGRAM_ERROR; end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay_bd is null or b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
if b_ngay_kt is null or b_ngay_kt in(0,30000101) then b_ngay_kt:=30000101; end if;
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
            dk_lbh(b_lp):=FBH_PKT_LBH_LOAI(dk_ma(b_lp));
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
                    dk_lbh(b_lp):=FBH_PKT_LBH_LOAI(dk_ma_dk(b_lp1)); exit;
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
    if FBH_PKT_PVI_HAN(pvi_ma(b_lp))<>'C' then
        b_loi:='loi:Pham vi: '||pvi_ma(b_lp)||' da het su dung:loi'; raise PROGRAM_ERROR;
    end if;
    pvi_ten(b_lp):=FBH_PKT_PVI_TEN(pvi_ma(b_lp)); pvi_tc(b_lp):=FBH_PKT_PVI_TC(pvi_ma(b_lp));
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
b_so_id:=FBH_PKT_BPHI_SO_ID(b_nhom,b_ma_sp,b_ma_nct,b_rru,b_ma_ntb,b_ngay_bd);
if b_so_id<>0 then
    delete bh_pkt_phi_txt where so_id=b_so_id;
    delete bh_pkt_phi_lt where so_id=b_so_id;
    delete bh_pkt_phi_dk where so_id=b_so_id;
    delete bh_pkt_phiP_dk where so_id=b_so_id;
    delete bh_pkt_phi where so_id=b_so_id;
else
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
insert into bh_pkt_phi values(b_ma_dvi,b_so_id,b_nhom,b_ma_sp,
    b_ma_cct,b_ma_nct,b_ma_dkdl,b_ma_dktc,b_rru,b_ma_ntb,
    b_ngay_bd,b_ngay_kt,b_nsd);
for b_lp in 1..dk_ma.count loop
    insert into bh_pkt_phi_dk values(b_ma_dvi,b_so_id,b_lp,dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),
        0,dk_pt(b_lp),0,dk_lkeM(b_lp),dk_lkeP(b_lp),dk_lkeB(b_lp),dk_luy(b_lp),
        dk_ma_dk(b_lp),dk_ma_dkC(b_lp),dk_lh_nv(b_lp),dk_t_suat(b_lp),0,dk_lbh(b_lp),dk_nv(b_lp),dk_ktru(b_lp));
end loop;
for r_lp in(select t.so_id,t.bt,level from
 (select * from bh_pkt_phi_dk where so_id=b_so_id) t start with t.ma_ct=' ' CONNECT BY prior t.ma=t.ma_ct) loop
    update bh_pkt_phi_dk set cap=r_lp.level where so_id=b_so_id and bt=r_lp.bt;
end loop;
for b_lp in 1..pvi_ma.count loop
    insert into bh_pkt_phiP_dk values(b_ma_dvi,b_so_id,b_lp,pvi_ma(b_lp),
    pvi_ten(b_lp),pvi_ptTS(b_lp),pvi_ptKH(b_lp),pvi_ktru(b_lp),pvi_tc(b_lp),pvi_loai(b_lp),pvi_ma_ct(b_lp));
end loop;
insert into bh_pkt_phi_txt values(b_ma_dvi,b_so_id,'dt_ct',b_dt_ct);
insert into bh_pkt_phi_txt values(b_ma_dvi,b_so_id,'dt_dk',b_dt_dk);
if length(b_dt_dkbs)<>0 then
    insert into bh_pkt_phi_txt values(b_ma_dvi,b_so_id,'dt_dkbs',b_dt_dkbs);
end if;
if length(b_dt_pvi)<>0 then
    insert into bh_pkt_phi_txt values(b_ma_dvi,b_so_id,'dt_pvi',b_dt_pvi);
end if;
if lt_ma_lt.count<>0 then
    for b_lp in 1..lt_ma_lt.count loop
        insert into bh_pkt_phi_lt values(b_ma_dvi,b_so_id,b_lp,lt_ma_lt(b_lp),lt_ma_dk(b_lp),lt_ten(b_lp));
    end loop;
    insert into bh_pkt_phi_txt values(b_ma_dvi,b_so_id,'dt_lt',b_dt_lt);
end if;
if length(b_dt_khd)<>0 then
    insert into bh_pkt_phi_txt values(b_ma_dvi,b_so_id,'dt_khd',b_dt_khd);
end if;
if length(b_dt_kbt)<>0 then
    insert into bh_pkt_phi_txt values(b_ma_dvi,b_so_id,'dt_kbt',b_dt_kbt);
end if;
commit;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_BPHI_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS 
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Dan - Xoa bieu phi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then b_loi:='loi:Chon bieu phi can xoa:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table bh_pkt_phi:loi';
delete bh_pkt_phi_txt where so_id=b_so_id;
delete bh_pkt_phi_lt where so_id=b_so_id;
delete bh_pkt_phi_dk where so_id=b_so_id;
delete bh_pkt_phiP_dk where so_id=b_so_id;
delete bh_pkt_phi where so_id=b_so_id;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_NCT_LIST(b_tso varchar2,b_loi out varchar2)
AS
     b_lenh varchar2(1000); b_ma_sp varchar2(20); b_nv varchar2(1);
begin
-- viet anh -- loc ma nhom cong trinh theo sp
b_loi:='loi:Loi xu ly PBH_PKT_NCT_LIST:loi';
b_lenh:=FKH_JS_LENH('ma_sp,nv');
EXECUTE IMMEDIATE b_lenh into b_ma_sp,b_nv using b_tso;
b_ma_sp:=nvl(trim(b_ma_sp),' ');
insert into bh_kh_hoi_temp1 select a.ma,a.ten from bh_pkt_ma_nct a,(select distinct ma_nct 
       from bh_pkt_phi where b_ma_sp in (' ',ma_sp) and nhom=b_nv) b where a.ma=b.ma_nct order by a.ten;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_NTB_LIST(b_tso varchar2,b_loi out varchar2)
AS
     b_lenh varchar2(1000); b_ma_sp varchar2(20); b_nv varchar2(1);
begin
-- viet anh -- loc ma nhom thiet bi theo sp
b_loi:='loi:Loi xu ly PBH_PKT_NTB_LIST:loi';
b_lenh:=FKH_JS_LENH('ma_sp,nv');
EXECUTE IMMEDIATE b_lenh into b_ma_sp,b_nv using b_tso;
b_ma_sp:=nvl(trim(b_ma_sp),' ');
insert into bh_kh_hoi_temp1 select a.ma,a.ten from bh_pkt_ma_ntb a,(select distinct ma_ntb 
       from bh_pkt_phi where b_ma_sp in (' ',ma_sp) and nhom=b_nv) b where a.ma=b.ma_ntb order by a.ten;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_PKT_SP_HAN(b_ma varchar2,b_dk varchar2:='C') return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_pkt_sp where ma=b_ma and tc in('C',b_dk) and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;