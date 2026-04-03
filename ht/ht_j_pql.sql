-- ma phong
create or replace function FHT_MA_PHONGJ_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan - Tra ten
select min(ten) into b_kq from ht_ma_phong where ma=b_ma;
return b_kq;
end;
/
create or replace function FHT_MA_PHONGJ_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con dung
select count(*) into b_i1 from ht_ma_phong where ma=b_ma;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PHT_MA_PHONGJ_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_dvi varchar2(500); b_tim nvarchar2(100);
    b_dong number; cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('dvi,tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_dvi,b_tim,b_tu,b_den using b_oraIn;
if nvl(trim(b_dvi),' ') = ' ' then b_dvi:=b_ma_dvi; else b_dvi := pkh_ma_tenl(b_dvi); end if;
if b_tim is null then
    select count(*) into b_dong from ht_ma_phong where ma_dvi=b_dvi;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,ma,ten,nsd,xep) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from ht_ma_phong where ma_dvi=b_dvi order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from ht_ma_phong where ma_dvi=b_dvi and upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(ma_dvi,ma,ten,nsd,'xep' value ma) obj from ht_ma_phong a where ma_dvi=b_dvi)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_PHONGJ_MA(
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
    select count(*) into b_dong from ht_ma_phong;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from ht_ma_phong order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from ht_ma_phong order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma,ten,nsd,xep) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep,rownum sott from
                    (select * from ht_ma_phong order by ma) a
                    start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from ht_ma_phong where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from ht_ma_phong where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(ma,ten,nsd,'xep' value ma) obj from ht_ma_phong a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_PHONGJ_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma'); b_dvi varchar2(500):=FKH_JS_GTRIs(b_oraIn,'dvi');
    dt_ct clob; dt_txt clob; b_il number;
begin
-- viet anh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if nvl(trim(b_dvi),' ') = ' ' then b_dvi:=b_ma_dvi; else b_dvi := pkh_ma_tenl(b_dvi); end if;
select count(1) into b_il from ht_ma_phong where ma=b_ma;
if b_il > 0 then 
  select json_object(ma,ten,nhom,pnhan,ma_ct,nsd) into dt_ct from ht_ma_phong where ma=b_ma;
  select count(1) into b_il from ht_ma_phong_txt where ma=b_ma;
  if b_il > 0 then
    select json_object('loai' value 'dt_ct',txt ) into dt_txt from ht_ma_phong_txt where ma=b_ma;
  end if;
end if;
select json_object('dt_ct' value dt_ct,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_PHONGJ_NH
    (b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_idvung number; b_i1 number; b_lenh varchar2(1000);
    b_ma_dvi varchar2(200); b_ma varchar2(10); b_ten nvarchar2(500);
    b_nhom varchar2(1); b_pnhan varchar2(1); b_ma_ct varchar2(10);
begin
-- Dan
PHT_MA_NSD_KTRA_VU(b_ma_dviN,b_nsd,b_pas,b_idvung,b_loi,'HT','HT','NM');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('dvi,ma,ten,nhom,pnhan,ma_ct');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_ma,b_ten,b_nhom,b_pnhan,b_ma_ct using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma phong:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_nhom is null or b_nhom not in ('T','G') then b_loi:='loi:Sai khoi:loi'; raise PROGRAM_ERROR; end if;
b_ma_ct:=nvl(trim(b_ma_ct),' ');
b_pnhan:=nvl(trim(b_pnhan),' ');
b_ma_dvi:=PKH_MA_TENl(b_ma_dvi);
if trim(b_ma_ct) is not null then
    select count(*) into b_i1 from ht_ma_phong where ma_dvi=b_ma_dvi and ma=b_ma_ct;
    if b_i1=0 then b_loi:='loi:Ma cap tren chua dang ky:loi'; raise PROGRAM_ERROR; end if;
end if;
b_loi:='loi:Va cham NSD:loi';
delete ht_ma_phong where ma=b_ma;
delete ht_ma_phong_txt where ma=b_ma;
insert into ht_ma_phong values(b_ma_dvi,b_ma,b_ten,b_nhom,b_pnhan,b_ma_ct,b_nsd,0);
insert into ht_ma_phong_txt values(b_ma_dvi,b_ma,b_oraIn);
commit;
select json_object('ma' value b_ma) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_PHONGJ_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn cLob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from ht_ma_phong where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete ht_ma_phong where ma=b_ma;
delete ht_ma_phong_txt where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_PHONGJ_DVI(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob, b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_gtri nvarchar2(500);
    b_dvi varchar2(500);
    b_kieu varchar2(1); b_dong number; b_tu number:=1; cs_lke clob;
begin
-- viet anh - ma nguoi dai dien
delete temp_1; commit;
b_lenh:=FKH_JS_LENH('kieu,gtri,dvi');
EXECUTE IMMEDIATE b_lenh into b_kieu,b_gtri,b_dvi using b_oraIn;
if b_dvi is not null then
    b_dvi:=PKH_MA_TENl(b_dvi);
end if;
insert into temp_1(c1,c2,c3) select '1',ma,ten from ht_ma_phong where ma_dvi=b_dvi;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_kieu<>'C' then
    PBH_MA_DMUC_LIST(b_oraIn,b_dong,cs_lke,b_loi);
elsif trim(b_gtri) is not null then
    PBH_MA_DMUC_LIST_MA(b_oraIn,b_dong,cs_lke,b_loi);
else
    PBH_MA_DMUC_LIST_SL(b_oraIn,b_tu,b_dong,cs_lke,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('kieu' value b_kieu,'dong' value b_dong,'tu' value b_tu,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_PHONGJ_MA_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); b_dvi varchar2(20); cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_dvi:=pkh_ma_tenl(b_oraIn);
if b_dvi is not null then
    select JSON_ARRAYAGG(json_object(ma,'ten' value ten) order by ma returning clob) into cs_lke from ht_ma_phong where ma_dvi=b_dvi and MA_CT = ' ';
end if;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_PHONG_LIST(b_ma_dvi varchar2,b_loi out varchar2)
AS
begin
-- chuclh
b_loi:='loi:Loi xu ly PHT_MA_PHONG_LIST:loi';
insert into bh_kh_hoi_temp1 select ma,ten from ht_ma_phong where ma_dvi=b_ma_dvi order by ten;
b_loi:='';
exception when others then null;
end;
/
-- Chuc vu
create or replace function FHT_MA_CVUJ_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan - Tra ten
select min(ten) into b_kq from ht_ma_cvu where ma=b_ma;
return b_kq;
end;
/
create or replace function FHT_MA_CVUJ_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con dung
select count(*) into b_i1 from ht_ma_cvu where ma=b_ma;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PHT_MA_CVUJ_LKE(
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
    select count(*) into b_dong from ht_ma_cvu;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma,ten,nsd,xep) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from ht_ma_cvu order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from ht_ma_cvu where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(ma,ten,nsd,'xep' value ma) obj from ht_ma_cvu a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_CVUJ_MA(
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
    select count(*) into b_dong from ht_ma_cvu;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from ht_ma_cvu order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from ht_ma_cvu order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma,ten,nsd,xep) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep,rownum sott from
                    (select * from ht_ma_cvu order by ma) a
                    start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from ht_ma_cvu where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from ht_ma_cvu where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(ma,ten,nsd,'xep' value ma) obj from ht_ma_cvu a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_CVUJ_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
    cs_ct clob; dt_txt clob; b_il number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma da xoa:loi';
select json_object(ma,ten,ma_ct,nsd) into cs_ct from ht_ma_cvu where ma=b_ma;
select count(1) into b_il from ht_ma_cvu_txt where ma=b_ma;
if b_il <> 0 then
   select json_object(txt returning clob) into dt_txt from ht_ma_cvu_txt where ma=b_ma;
end if;                 
select json_object('cs_ct' value dt_txt, 'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_CVUJ_NH
    (b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(1000); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); 
    b_ma_ct varchar2(10);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,ma_ct');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_ma_ct using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_ma_ct is null or trim(b_ma_ct) = '' then b_ma_ct:= ' '; end if;

if b_ma_ct<>' ' then
    b_loi:='loi:Sai ma cap tren:loi';
    if b_ma=b_ma_ct then raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from ht_ma_cvu where ma=b_ma_ct;
end if;
b_loi:='';
delete ht_ma_cvu where ma=b_ma;
delete ht_ma_cvu_txt where ma=b_ma;
insert into ht_ma_cvu values(b_ma_dviN,b_ma,b_ten,b_ma_ct,b_nsd,0);
insert into ht_ma_cvu_txt values(b_ma,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_CVUJ_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn cLob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from ht_ma_cvu where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete ht_ma_cvu where ma=b_ma;
delete ht_ma_cvu_txt where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Ma Can bo
create or replace function PHT_MA_CBJ_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ten) into b_kq from ht_ma_cb where ma=b_ma;
return b_kq;
end;
/
create or replace function PHT_MA_CBJ_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from ht_ma_cb where ma=b_ma; --nam: : -> |
return b_kq;
end;
/
-- DA CHUYEN DOI
create or replace procedure PHT_MA_CBJ_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_ngay number:=PKH_NG_CSO(sysdate);
    b_loi varchar2(100);
    cs_phong clob; cs_cvu clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten returning clob) order by ten returning clob) into cs_phong from ht_ma_phong ;
select JSON_ARRAYAGG(json_object(ma,ten returning clob) order by ten returning clob) into cs_cvu from ht_ma_cvu;
select json_object('cs_phong' value cs_phong,'cs_cvu' value cs_cvu returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_CBJ_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from ht_ma_cb where ma_dvi=b_ma_dvi and b_nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten) returning clob) into cs_lke from
        (select ma,ten,rownum sott from ht_ma_cb where ma_dvi=b_ma_dvi order by upper(ten))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from ht_ma_cb where ma_dvi=b_ma_dvi and upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten) returning clob) into cs_lke from
        (select ma,ten,rownum sott from ht_ma_cb where ma_dvi=b_ma_dvi and upper(ten) like b_tim order by upper(ten))
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_CBJ_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(100); b_so_cmt varchar2(30); b_phong varchar2(100); b_cv varchar2(100); b_ma_tk varchar2(30);
    b_nhang varchar2(100); b_ten_nh nvarchar2(200); b_mobi varchar2(20); b_mail varchar(50);

    b_idvung number:=0;
begin
-- Dan
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'HT','HT','MN');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,so_cmt,phong,cv,ma_tk,nhang,ten_nh,mobi,mail');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_so_cmt,b_phong,b_cv,b_ma_tk,b_nhang,b_ten_nh,b_mobi,b_mail using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if trim(b_phong) is null then b_loi:='loi:Nhap phong:loi'; raise PROGRAM_ERROR; end if;

--b_loi:='loi:Sai ma phong:loi';
--b_phong:=PKH_MA_TENl(b_phong);
--if trim(b_phong) is null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma phong chua dang ky:loi';
select count(0) into b_i1 from ht_ma_phong where ma=b_phong;
if b_i1 <= 0 then raise PROGRAM_ERROR; end if;
if trim(b_cv) is not null then
    b_loi:='loi:Ma chuc vu chua dang ky:loi';
    --b_cv:=PKH_MA_TENl(b_cv);
    select count(0) into b_i1 from ht_ma_cvu where ma_dvi=b_ma_dvi and ma=b_cv;
    if b_i1 <= 0 then raise PROGRAM_ERROR; end if;
end if;
if trim(b_nhang) is not null then
    b_loi:='loi:Ma ngan hang chua dang ky:loi';
    select count(0) into b_i1 from bh_ma_nhang where ma_dvi=b_ma_dvi and ma=b_nhang;
    if b_i1 <= 0 then raise PROGRAM_ERROR; end if;
end if;
b_loi:='';
delete ht_ma_cb where ma_dvi=b_ma_dvi and ma=b_ma;
delete ht_ma_cb_txt where ma_dvi=b_ma_dvi and ma=b_ma;
select count(*) into b_i1 from ht_ma_cb where ma=' ';
insert into ht_ma_cb values(b_ma_dvi,b_ma,b_ten,b_so_cmt,b_phong,b_cv,b_ma_tk,b_nhang,b_ten_nh,b_mobi,b_mail,b_nsd,0);
insert into ht_ma_cb_txt values(b_ma_dvi,b_ma,b_oraIn);
commit;
select json_object('ma' value b_ma) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/

/
create or replace procedure PHT_MA_CBJ_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(100); b_i1 number; b_ma varchar2(10);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','MN');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ma:=FKH_JS_GTRIs(b_oraIn,'ma');
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete ht_ma_cb where ma_dvi=b_ma_dvi and ma=b_ma;
delete ht_ma_cb_txt where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_CBJ_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from ht_ma_cb;
    select nvl(min(sott),b_dong) into b_tu from
        (select a.*,rownum sott from ht_ma_cb a order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj RETURNING CLOB) into cs_lke from
        (select json_object(*) obj,rownum sott from ht_ma_cb order by ten)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from ht_ma_cb where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from ht_ma_cb where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj RETURNING CLOB) into cs_lke from
        (select a.*,rownum sott from
        (select ten,json_object(*) obj from ht_ma_cb) a
        where upper(ten) like b_tim order by ten)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke RETURNING CLOB) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_CBJ_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma'); dt_ct clob; dt_txt clob;
    b_il number;
begin
-- viet anh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','MN');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(1) into b_il from ht_ma_cb where ma_dvi=b_ma_dvi and ma=b_ma;
if b_il > 0 then
   select json_object(ma,ten,so_cmt,phong,cv,ma_tk,nhang,ten_nh,mobi,mail,nsd) into dt_ct from ht_ma_cb where ma_dvi=b_ma_dvi and ma=b_ma;
   select count(1) into b_il from ht_ma_cb_txt where ma_dvi=b_ma_dvi and ma=b_ma;
    if b_il > 0 then
      select json_object('loai' value 'dt_ct',txt) into dt_txt from ht_ma_cb_txt where ma_dvi=b_ma_dvi and ma=b_ma;
    end if;
end if;
select json_object('dt_ct' value dt_ct, 'txt' value dt_txt) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function PHT_MA_CBJ_HAN(b_ma varchar2,b_dk varchar2:='C') return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from ht_ma_cb where ma=b_ma;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PHT_MA_CBJ_LIST(b_ma_dvi varchar2,b_loi out varchar2)
AS
begin
-- chuclh
b_loi:='loi:Loi xu ly PHT_MA_CBJ_LIST:loi';
insert into bh_kh_hoi_temp1 select ma,ten from ht_ma_cb where ma_dvi=b_ma_dvi order by ten;
b_loi:='';
exception when others then null;
end;
/
create or replace procedure PHT_MA_CBJ_PHONG_LIST(b_oraIn varchar2,b_loi out varchar2)
AS
  b_lenh varchar2(1000); b_maN varchar2(20); b_ma_dviN varchar2(20); b_ma varchar2(20); b_phong varchar2(20); b_ma_dvi varchar2(20);
begin
-- chuclh: lay danh sach ma can bo theo phong ban va nguoi dung. HDAC: 17/11/2023
b_lenh:=FKH_JS_LENH('ma_dvi,ma');
EXECUTE IMMEDIATE b_lenh into b_ma_dviN,b_maN using b_oraIn;
select nvl(ma,' '),ma_dvi into b_ma,b_ma_dvi from ht_ma_nsd where ma=b_maN and ma_dvi=b_ma_dviN;
if b_ma = '' then return; end if;
select nvl(phong,' ') into b_phong from ht_ma_cb where ma=b_ma and ma_dvi=b_ma_dvi;
if b_phong = ' ' then return; end if;
insert into bh_kh_hoi_temp1 select ma,ten from ht_ma_cb where ma_dvi=b_ma_dvi and phong=b_phong order by ten;
b_loi:='';
exception when others then null;
end;
/
-- ma nhom
create or replace procedure PHT_MA_NHOMJ_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_md varchar(10):='BH';
    b_tu number; b_den number; b_ma varchar2(10); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from ht_ma_nhom where md=b_md;
select nvl(min(sott),0) into b_tu from (select ma,rownum sott from ht_ma_nhom where md=b_md and ma=b_ma order by ma);
PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
    (select ma,ten,nsd,rownum sott from ht_ma_nhom where md=b_md order by ma)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_NHOMJ_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_dong number:=0; dt_lke clob:=''; dt_nv clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tu,den');
EXECUTE IMMEDIATE b_lenh into b_tu,b_den using b_oraIn;
select count(*) into b_dong from ht_ma_nhom where md='BH';
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(ma_dvi,md,ma,ten) order by ma returning clob) into dt_lke from
    (select a.*,rownum sott from ht_ma_nhom a where a.md='BH' order by ma)
    where sott between b_tu and b_den;
select JSON_ARRAYAGG(json_object(*)) into dt_nv from ht_manv;
select json_object('dong' value b_dong,'dt_lke' value dt_lke,'dt_nv' value dt_nv returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_NHOMJ_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_il number;
    b_ma varchar(10):=FKH_JS_GTRIs(b_oraIn,'ma');
    dt_ct clob; dt_qu clob; b_md varchar(10):='BH';
begin
-- Dan - Xem chi tiet theo so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(1) into b_il from ht_ma_nhom where md=b_md and ma=b_ma;
if b_il > 0 then
  select json_object(ma,ten) into dt_ct from ht_ma_nhom where md=b_md and ma=b_ma;
  select JSON_ARRAYAGG(json_object(
        MD,NV,'ma' VALUE CASE WHEN INSTR(tc, 'M') > 0 THEN 'C' ELSE 'K' END,
               'nhap' VALUE CASE WHEN INSTR(tc, 'N') > 0 THEN 'C' ELSE 'K' END,
               'xem' VALUE CASE WHEN INSTR(tc, 'X') > 0 THEN 'C' ELSE 'K' END,
               'han' VALUE CASE WHEN INSTR(tc, 'H') > 0 THEN 'C' ELSE 'K' END,
               'qly' VALUE CASE WHEN INSTR(tc, 'Q') > 0 THEN 'C' ELSE 'K' END) order by ma returning clob) into dt_qu
     FROM ht_ma_nhom_nv where md in ('HT','HD',b_md) and ma=b_ma;
end if;
select json_object('ma' value b_ma,'dt_ct' value dt_ct,'dt_qu' value dt_qu returning clob) into b_oraOut from dual;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_NHOMJ_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma varchar2(10); b_md varchar(10):='BH';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','NM');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma');
EXECUTE IMMEDIATE b_lenh into b_ma using b_oraIn;
b_ma := nvl(b_ma,' ');
if b_ma<>' ' then
  b_loi:='loi:Nhom da phan quyen khai thac:loi';
  select count(*) into b_i1 from bh_pqu_nhom where nhom=b_ma;
  if b_i1 > 0 then raise PROGRAM_ERROR; end if;
  b_loi:='loi:Nhom da gioi han khai thac/phan quyen khac:loi';
  select count(*) into b_i1 from bh_pqu_nhom_kh where nhom=b_ma;
  if b_i1 > 0 then raise PROGRAM_ERROR; end if;
  delete ht_ma_nhom_nv where md in ('HT','HD',b_md) and ma=b_ma;
  delete ht_ma_nhom where md=b_md and ma=b_ma;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_NHOMJ_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(1000); b_lenh varchar2(2000);
    b_ma varchar2(10); b_ten NVARCHAR2(100); b_md varchar2(10):='BH';b_idvung number:=0;
    a_tc varchar2(10);
    a_md pht_type.a_var;b_nv pht_type.a_var; b_nv_ma pht_type.a_var;b_nv_nhap pht_type.a_var;b_nv_xem pht_type.a_var;b_nv_han pht_type.a_var;b_nv_qly pht_type.a_var;
    dt_ct clob; dt_pqu clob:='';
begin
-- Dan
PHTG_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'HT','HT','NM');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_pqu');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_pqu using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_pqu);
b_lenh:=FKH_JS_LENH('ma,ten');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten using dt_ct;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;

b_lenh:=FKH_JS_LENH('md,nv,ma,nhap,xem,han,qly');
EXECUTE IMMEDIATE b_lenh bulk collect into a_md,b_nv,b_nv_ma,b_nv_nhap,b_nv_xem,b_nv_han,b_nv_qly using dt_pqu;
delete ht_ma_nhom_nv where md in ('HT','HD',b_md) and ma=b_ma;
delete ht_ma_nhom where md=b_md and ma=b_ma;
insert into ht_ma_nhom values(b_ma_dvi,b_md,b_ma,b_ten,b_nsd,b_idvung);
for b_lp in 1..b_nv.count loop
    a_tc := ''; 
    if b_nv_ma(b_lp) = 'C' then
        a_tc := a_tc || 'M';
    end if;
    if b_nv_nhap(b_lp) = 'C' then
        a_tc := a_tc || 'N';
    end if;
    if b_nv_xem(b_lp) = 'C' then
        a_tc := a_tc || 'X';
    end if;
    if b_nv_han(b_lp) = 'C' then
        a_tc := a_tc || 'H';
    end if;
    if b_nv_qly(b_lp) = 'C' then
        a_tc := a_tc || 'Q';
    end if;

    insert into ht_ma_nhom_nv values(b_ma_dvi,a_md(b_lp),b_ma,b_nv(b_lp),a_tc,b_idvung);
end loop;

select json_object('ma' value b_ma) into b_oraOut from dual;
if b_comm='C' then commit; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- ma nsd
create or replace procedure PHT_MA_NSDJ_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_md varchar(10):='BH'; b_dvi varchar2(500); 
    b_tu number; b_den number; b_ma varchar2(10); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,dvi,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_dvi,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if nvl(trim(b_dvi),' ') = ' ' then b_dvi:=b_ma_dvi; else b_dvi := pkh_ma_tenl(b_dvi); end if;
if FHTG_MA_NSD_QU(b_ma_dvi,b_nsd,'HT','ND','X')<>'C' then
    b_dong:=1;
    select JSON_ARRAYAGG(json_object(phong,ma,ten)) into cs_lke from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_nsd;
else
    select count(*) into b_dong from ht_ma_nsd where ma_dvi=b_dvi;
    select nvl(min(sott),0) into b_tu from (select ma,rownum sott from ht_ma_nsd where ma_dvi=b_dvi and ma=b_ma order by ma);
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
        (select ma,ten,nsd,rownum sott from ht_ma_nsd where ma_dvi=b_dvi order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_NSDJ_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_md varchar2(10):='BH'; b_dvi varchar2(500); b_tim varchar2(500);
    b_dong number:=0; dt_lke clob:=''; dt_nv clob:=''; dt_nhom clob:=''; dt_dvi clob:=''; b_vp varchar(1);
begin
-- Dan
b_lenh:=FKH_JS_LENH('tu,den,md,dvi,tim');
EXECUTE IMMEDIATE b_lenh into b_tu,b_den,b_md,b_dvi,b_tim using b_oraIn;
b_loi:=FHTG_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,b_md,'','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete temp_1; delete temp_2; commit;
b_dvi := pkh_ma_tenl(b_dvi);
if nvl(trim(b_dvi),' ') = ' ' then return; end if;
select vp into b_vp from ht_ma_dvi where ma=b_dvi;
if b_tim is null then
  select count(*) into b_dong from ht_ma_nsd where ma_dvi=b_dvi;
  PKH_LKE_TRANG(b_dong,b_tu,b_den);
  if FHTG_MA_NSD_QU(b_ma_dvi,b_nsd,'HT','ND','X')<>'C' then
      b_dong:=1;
      select JSON_ARRAYAGG(json_object(phong,ma,ten)) into dt_lke from ht_ma_nsd where ma_dvi=b_dvi and ma=b_nsd;
  elsif trim(b_md) is null then
      select JSON_ARRAYAGG(json_object(phong,ma,ten) order by ma returning clob) into dt_lke from
          (select a.*,rownum sott from ht_ma_nsd a where a.ma_dvi=b_dvi order by ma)
          where sott between b_tu and b_den;
  else
      insert into temp_1(c1) select distinct ma from ht_ma_nsd_nv where ma_dvi=b_dvi and md in(b_md,'HT');
      insert into temp_1(c1) select distinct ma from ht_ma_nsd_nhom where ma_dvi=b_dvi and md in(b_md,'HT');
      insert into temp_2(c1) select distinct c1 from temp_1;
      select JSON_ARRAYAGG(json_object(phong,ma,ten) order by ma returning clob) into dt_lke from
      (select a.*,rownum sott from ht_ma_nsd a where a.ma_dvi=b_dvi and a.ma in(select c1 from temp_2) order by ma)
      where sott between b_tu and b_den;
  end if;
else
  select count(*) into b_dong from ht_ma_nsd where ma_dvi=b_dvi and upper(ten) like b_tim;
  PKH_LKE_TRANG(b_dong,b_tu,b_den);
  if FHTG_MA_NSD_QU(b_ma_dvi,b_nsd,'HT','ND','X')<>'C' then
      b_dong:=1;
      select JSON_ARRAYAGG(json_object(phong,ma,ten)) into dt_lke from ht_ma_nsd where ma_dvi=b_dvi and ma=b_nsd and upper(ten) like b_tim;
  elsif trim(b_md) is null then
      select JSON_ARRAYAGG(json_object(phong,ma,ten) order by ma returning clob) into dt_lke from
          (select a.*,rownum sott from ht_ma_nsd a where a.ma_dvi=b_dvi and upper(ten) like b_tim order by upper(ten))
          where sott between b_tu and b_den;
  else
      insert into temp_1(c1) select distinct ma from ht_ma_nsd_nv where ma_dvi=b_dvi and md in(b_md,'HT');
      insert into temp_1(c1) select distinct ma from ht_ma_nsd_nhom where ma_dvi=b_dvi and md in(b_md,'HT');
      insert into temp_2(c1) select distinct c1 from temp_1;
      select JSON_ARRAYAGG(json_object(phong,ma,ten) order by ma returning clob) into dt_lke from
      (select a.*,rownum sott from ht_ma_nsd a where a.ma_dvi=b_dvi and a.ma in(select c1 from temp_2) and upper(ten) like b_tim order by upper(ten))
      where sott between b_tu and b_den;
  end if;
end if;
select JSON_ARRAYAGG(json_object(ma,ten,'NHOM' value ma) returning clob) into dt_nhom from ht_ma_nhom where md=b_md order by ma;
select JSON_ARRAYAGG(json_object(ma,ten,'DVI' value ma) returning clob) into dt_dvi from ht_ma_dvi where b_dvi in(ma,ma_ct) order by ma;
if b_md='HD' then 
   select JSON_ARRAYAGG(json_object(*)) into dt_nv from ht_manv where md='HD';
else
  select JSON_ARRAYAGG(json_object(*)) into dt_nv from ht_manv;
end if;
select json_object('dong' value b_dong,'vp' value b_vp,'dt_lke' value dt_lke,'dt_nv' value dt_nv,'dt_nhom' value dt_nhom,'dt_dvi' value dt_dvi returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_NSDJ_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000);b_lenh varchar2(1000); b_il number;
    b_ma varchar(10);b_dvi varchar(500);
    dt_ct clob; dt_qu clob; dt_dvi clob; dt_nhom clob; dt_txt clob; b_md varchar(10):='';
begin
-- Dan - Xem chi tiet theo so ID
b_lenh:=FKH_JS_LENH('ma,dvi,md');
EXECUTE IMMEDIATE b_lenh into b_ma,b_dvi,b_md using b_oraIn;
b_md:=NVL(b_md,'BH');
b_loi:=FHTG_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,b_md,'','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if nvl(trim(b_dvi),' ') = ' ' then b_dvi:=b_ma_dvi; else b_dvi := pkh_ma_tenl(b_dvi); end if;
if b_nsd<>b_ma then
    if FHTG_MA_NSD_QU(b_ma_dvi,b_nsd,'HT','ND','X')<>'C' then b_loi:='loi:Khong vuot quyen:loi'; raise PROGRAM_ERROR; end if;
end if;
select count(1) into b_il from ht_ma_nsd where ma_dvi=b_dvi and ma=b_ma;
if b_il > 0 then
  select json_object(ma_login,ma) into dt_ct from ht_ma_nsd where ma_dvi=b_dvi and ma=b_ma;
end if;
select count(1) into b_il from ht_ma_nsd_txt where ma_dvi=b_dvi and ma=b_ma;
if b_il > 0 then
  select json_object('loai' value 'dt_ct',txt) into dt_txt from ht_ma_nsd_txt where ma_dvi=b_dvi and ma=b_ma;
end if;

select JSON_ARRAYAGG(json_object(
        MD,NV,'ma' VALUE CASE WHEN INSTR(tc, 'M') > 0 THEN 'C' ELSE 'K' END,
               'nhap' VALUE CASE WHEN INSTR(tc, 'N') > 0 THEN 'C' ELSE 'K' END,
               'xem' VALUE CASE WHEN INSTR(tc, 'X') > 0 THEN 'C' ELSE 'K' END,
               'han' VALUE CASE WHEN INSTR(tc, 'H') > 0 THEN 'C' ELSE 'K' END,
               'qly' VALUE CASE WHEN INSTR(tc, 'Q') > 0 THEN 'C' ELSE 'K' END) order by ma returning clob) into dt_qu
     FROM ht_ma_nsd_nv where ma_dvi=b_dvi and md in('HT','HD',b_md) and ma=b_ma;
select JSON_ARRAYAGG(json_object(a.dvi,b.ten) returning clob) into dt_dvi from ht_ma_nsd_qly a,ht_ma_dvi b
    where a.ma_dvi=b_dvi and a.ma=b_ma and a.md=b_md and b.ma=a.dvi;
select JSON_ARRAYAGG(json_object(b.ten,a.nhom,'chon' value 'X') returning clob) into dt_nhom from ht_ma_nsd_nhom a, ht_ma_nhom b
                     where a.nhom=b.ma and a.ma_dvi=b_dvi and a.ma=b_ma and a.md=b_md;
select json_object('ma' value b_ma,'dt_ct' value dt_ct,'dt_qu' value dt_qu,
                   'dt_dvi' value dt_dvi,'dt_nhom' value dt_nhom, 'txt' value dt_txt returning clob) into b_oraOut from dual;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_NSD_MA_LOGINJ(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_il number;
    b_dvi varchar(10):=FKH_JS_GTRIs(b_oraIn,'dvi');
    b_ma varchar(10):=FKH_JS_GTRIs(b_oraIn,'ma');
    b_ma_login varchar(20):=FKH_JS_GTRIs(b_oraIn,'ma_login');
begin
-- Dan - Xem chi tiet theo so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PHT_MA_NSD_MA_LOGIN(b_dvi,b_nsd,b_pas,b_ma_dvi,b_ma,b_ma_login);
select json_object('ma_login' value b_ma_login) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_NSDJ_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(1000); b_i1 number; b_lenh varchar2(2000);
    b_dvi varchar2(500);b_phong varchar2(500); b_ma varchar2(10); b_ten NVARCHAR2(100); b_pas_n varchar2(20);
    b_ma_login varchar2(50); b_md varchar2(10):='BH';b_idvung number:=0;

    a_nten pht_type.a_nvar; a_nnhom pht_type.a_var;a_nchon pht_type.a_var;
    a_dten pht_type.a_nvar; a_ddvi pht_type.a_var;
    a_nv pht_type.a_var;a_md pht_type.a_var; a_tc varchar2(10); a_nv_ma pht_type.a_var;a_nv_nhap pht_type.a_var;a_nv_xem pht_type.a_var;a_nv_han pht_type.a_var;a_nv_qly pht_type.a_var;
    dt_ct clob; dt_pqu clob:=''; dt_nhom clob; dt_dvi clob:='';
    b_qu varchar2(1):='K'; b_ten_nv nvarchar2(100); b_nsd_c varchar2(10); b_tc varchar2(10);
    b_ma_g varchar2(50); b_ma_login_c varchar2(50); b_pas_c varchar2(20);
begin
-- Dan - Nhap ma NSD
PHTG_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,b_md,'','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_pqu,dt_nhom,dt_dvi');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_pqu,dt_nhom,dt_dvi using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_pqu); FKH_JSa_NULL(dt_nhom); FKH_JSa_NULL(dt_dvi);
b_lenh:=FKH_JS_LENH('dvi,phong,ma,ma_login,ten,pas');
EXECUTE IMMEDIATE b_lenh into b_dvi,b_phong,b_ma,b_ma_login,b_ten,b_pas_n using dt_ct;
b_dvi:=PKH_MA_TENl(b_dvi);
b_phong:=PKH_MA_TENl(b_phong);

b_loi:=FHT_MA_DVI_KTRA(b_idvung,b_dvi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma_login) is null then b_loi:='loi:Nhap ma login:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma quan ly:loi'; raise PROGRAM_ERROR; end if;
if trim(b_md) is null then b_loi:='loi:Nhap Modul:loi'; raise PROGRAM_ERROR; end if;
if b_nsd=b_ma and FHTG_MA_NSD_ACC(b_ma_dvi,b_nsd)<>'C' then
  if trim(b_pas_n) is null then  b_loi:='loi:Nhap password:loi'; raise PROGRAM_ERROR; end if;
  b_loi:='loi:Loi doi Password:loi';
  select ma_login into b_ma_login_c from ht_ma_nsd where ma_dvi=b_dvi and ma=b_nsd;
  b_nsd_c:=FHT_MA_NSD_LUU(b_ma_dvi,b_nsd);
  if b_ma_login_c<>b_ma_login then raise PROGRAM_ERROR; end if;
  update ht_login set pas=b_pas_n where ma=b_ma_login;
  
  delete ht_ma_nsd where ma=b_ma;
  delete ht_ma_nsd_txt where ma=b_ma;
  insert into ht_ma_nsd values(b_dvi,b_ma,b_ten,b_pas_n,b_phong,b_nsd_c,b_ma_login,b_idvung);
  insert into ht_ma_nsd_txt values(b_ma,b_dvi,dt_ct);
  if b_comm='C' then commit; end if;
  select json_object('ma' value b_ma) into b_oraOut from dual;
  return;
end if;
b_ma_g:=FHTG_MA_NSD_LOGIN(b_ma_dvi,b_ma);
b_loi:=FHT_MA_NSD_XET(b_ma_g,b_dvi,b_ma,b_ma_login);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma phong:loi';
if b_phong is null then raise PROGRAM_ERROR;
elsif trim(b_phong) is not null then
    select count(*) into b_i1 from ht_ma_phong where ma_dvi=b_dvi;
    if b_i1<>0 then
        select 0 into b_i1 from ht_ma_phong where ma_dvi=b_dvi and ma=b_phong;
    end if;
end if;
b_lenh:=FKH_JS_LENH('ten,nhom,chon');
EXECUTE IMMEDIATE b_lenh bulk collect into a_nten,a_nnhom,a_nchon using dt_nhom;
for b_lp in 1..a_nnhom.count loop
    b_loi:='loi:Ma nhom#'||a_nnhom(b_lp)||'#chua dang ky:loi';
    select 0 into b_i1 from ht_ma_nhom where md=b_md and ma=a_nnhom(b_lp);
end loop;
b_lenh:=FKH_JS_LENH('ten,dvi');
EXECUTE IMMEDIATE b_lenh bulk collect into a_dten,a_ddvi using dt_dvi;
for b_lp in 1..a_ddvi.count loop
    b_loi:='loi:Ma don vi dong chua dang ky#'||a_ddvi(b_lp)||':loi';
    select 0 into b_i1 from ht_ma_dvi where ma=a_ddvi(b_lp);
end loop;
if FHTG_MA_NSD_QU(b_ma_dvi,b_nsd,'HT','ND','N')<>'C' then
    b_loi:='loi:Khong vuot quyen:loi'; raise PROGRAM_ERROR;
end if;
b_lenh:=FKH_JS_LENH('nv,md,ma,nhap,xem,han,qly');
EXECUTE IMMEDIATE b_lenh bulk collect into a_nv,a_md,a_nv_ma,a_nv_nhap,a_nv_xem,a_nv_han,a_nv_qly using dt_pqu;
if FHTG_MA_NSD_ACC(b_ma_dvi,b_nsd)<>'C' then
    for b_lp in 1..a_nv.count loop
        a_tc := '';
        if a_nv_ma(b_lp) = 'C' then
            a_tc := a_tc || 'M';
        end if;
        if a_nv_nhap(b_lp) = 'C' then
            a_tc := a_tc || 'N';
        end if;
        if a_nv_xem(b_lp) = 'C' then
            a_tc := a_tc || 'X';
        end if;
        if a_nv_han(b_lp) = 'C' then
            a_tc := a_tc || 'H';
        end if;
        if a_nv_qly(b_lp) = 'C' then
            a_tc := a_tc || 'Q';
        end if;
        b_loi:='loi:Sai nghiep vu#'||a_nv(b_lp)||':loi';
        if trim(a_tc) is not null then
        b_i1:=length(a_tc);
        if a_md(b_lp)='HT' then
            select min(tc) into b_tc from ht_ma_nsd_nv where ma_dvi=b_ma_dvi and ma=b_nsd and md='HT' and nv=a_nv(b_lp);
            if b_tc is null or b_tc<>a_tc then
                for b_lp1 in 1..b_i1 loop
                    if FHTG_MA_NSD_QU(b_ma_dvi,b_nsd,'HT',a_nv(b_lp),substr(a_tc,b_lp1,1))<>'C' then
                        b_loi:='loi:Khong cap vuot quyen#'||trim(b_ten_nv)||':loi'; raise PROGRAM_ERROR;
                    end if;
                end loop;
            end if;
        elsif FHTG_MA_NSD_QU(b_ma_dvi,b_nsd,'HT','ND','Q')<>'C' then
            for b_lp1 in 1..b_i1 loop
                if FHTG_MA_NSD_QU(b_ma_dvi,b_nsd,b_md,a_nv(b_lp),substr(a_tc,b_lp1,1))<>'C' then
                    b_loi:='loi:Khong cap vuot quyen#'||trim(b_ten_nv)||':loi'; raise PROGRAM_ERROR;
                end if;
            end loop;
        end if;
        end if;
    end loop;
    if a_nnhom.count<>0 then
        if FHTG_MA_NSD_QU(b_ma_dvi,b_nsd,'HT','ND','Q')<>'C' then
            for b_lp in 1..a_nnhom.count loop
                b_loi:='loi:Khong cap vuot quyen nhom#'||a_nnhom(b_lp)||':loi';
                select 0 into b_i1 from ht_ma_nsd_nhom where ma_dvi=b_ma_dvi and ma=b_nsd and md=b_md and nhom=a_nnhom(b_lp);
            end loop;
        end if;
    end if;
    for b_lp in 1..a_ddvi.count loop
        b_loi:='loi:Ma don vi#'||a_ddvi(b_lp)||'#chua dang ky:loi';
        select 0 into b_i1 from ht_ma_dvi where ma=a_ddvi(b_lp);
    end loop;
end if;
b_qu:=FHTG_MA_NSD_ACC('',b_ma_login); b_nsd_c:=FHT_MA_NSD_LUU(b_ma_dvi,b_nsd);
select count(*),min(pas),min(ma_login) into b_i1,b_pas_c,b_ma_login_c from ht_ma_nsd where ma_dvi=b_dvi and ma=b_ma;
if b_i1<>0 then
    delete ht_ma_nsd_nv where ma_dvi=b_dvi and ma=b_ma and md in(b_md,'HT','HD');
    delete ht_ma_nsd_qly where ma_dvi=b_dvi and ma=b_ma and md=b_md;
    delete ht_ma_nsd_nhom where ma_dvi=b_dvi and ma=b_ma and md=b_md;
    delete ht_ma_nsd where ma_dvi=b_dvi and ma=b_ma;
    delete ht_ma_nsd_txt where ma_dvi=b_dvi and ma=b_ma;
    if trim(b_pas_n) is not null then b_pas_c:=b_pas_n; end if;
else
    if trim(b_pas_n) is null then  b_loi:='loi:Nhap password:loi'; raise PROGRAM_ERROR; end if;
    b_pas_c:=b_pas_n; b_ma_login_c:=b_ma_login;
end if;
delete ht_login where ma=b_ma_login_c;
insert into ht_ma_nsd values(b_dvi,b_ma,b_ten,b_pas_c,b_phong,b_nsd_c,b_ma_login,b_idvung);
insert into ht_ma_nsd_txt values(b_ma,b_dvi,dt_ct);
for b_lp in 1..a_md.count loop
    a_tc := '';
    if a_nv_ma(b_lp) = 'C' then
        a_tc := a_tc || 'M';
    end if;
    if a_nv_nhap(b_lp) = 'C' then
        a_tc := a_tc || 'N';
    end if;
    if a_nv_xem(b_lp) = 'C' then
        a_tc := a_tc || 'X';
    end if;
    if a_nv_han(b_lp) = 'C' then
        a_tc := a_tc || 'H';
    end if;
    if a_nv_qly(b_lp) = 'C' then
        a_tc := a_tc || 'Q';
    end if;
    insert into ht_ma_nsd_nv values(b_dvi,b_ma,a_md(b_lp),a_nv(b_lp),a_tc,b_idvung);
end loop;
for b_lp in 1..a_ddvi.count loop
    insert into ht_ma_nsd_qly values(b_dvi,b_ma,b_md,a_ddvi(b_lp),b_idvung);
end loop;
for b_lp in 1..a_nnhom.count loop
    insert into ht_ma_nsd_nhom values(b_dvi,b_ma,b_md,a_nnhom(b_lp),b_idvung);
end loop;
insert into ht_login values(b_ma_login,b_pas_c,b_idvung,b_qu,sysdate,0);
if b_comm='C' then commit; end if;
select json_object('ma' value b_ma) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_NSDJ_MA_LOGIN(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_il number;
    b_dvi varchar(500):=FKH_JS_GTRIs(b_oraIn,'dvi');
    b_ma varchar(10):=FKH_JS_GTRIs(b_oraIn,'ma');
    b_ma_login varchar(20):=FKH_JS_GTRIs(b_oraIn,'ma_login');
begin
PHT_MA_NSD_MA_LOGIN(b_ma_dvi,b_nsd,b_pas,b_dvi,b_ma,b_ma_login);
select json_object('ma_login' value b_ma_login) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_NSDJ_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_lenh varchar2(2000);b_loi varchar2(100); b_i1 number; b_dvi varchar(500);b_ma varchar2(10);b_idvung number; b_nsd_c varchar2(10); b_ma_login varchar2(50);
begin
-- Dan
PHTG_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'HT','ND','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('dvi,ma');
EXECUTE IMMEDIATE b_lenh into b_dvi,b_ma using b_oraIn;
b_dvi:=PKH_MA_TENl(b_dvi);
b_loi:=FHT_MA_DVI_KTRA(b_idvung,b_dvi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma da xoa:loi';
select nsd,ma_login into b_nsd_c,b_ma_login from ht_ma_nsd where ma_dvi=b_dvi and ma=b_ma;
if trim(b_nsd_c) is not null and b_nsd_c<>b_nsd then b_loi:='loi:Khong xoa ma do nguoi khac khai bao:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:NSD da phan quyen khai thac:loi';
select count(*) into b_i1 from bh_pqu_nsd where nsd=b_ma;
if b_i1 > 0 then raise PROGRAM_ERROR; end if;
b_loi:='loi:NSD da gioi han khai thac/phan quyen khac:loi';
select count(*) into b_i1 from bh_pqu_nsd_kh where nsd=b_ma;
if b_i1 > 0 then raise PROGRAM_ERROR; end if;
b_loi:='loi:NSD phan quyen khai thac khach hang:loi';
select count(*) into b_i1 from bh_pqu_khang where nsd=b_ma;
if b_i1 > 0 then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma dang su dung:loi';
update ht_ma_nsd set nsd=b_nsd where ma_dvi=b_dvi and nsd=b_ma;
delete ht_ma_nsd_qly where ma_dvi=b_dvi and ma=b_ma;
delete ht_ma_nsd_nv where ma_dvi=b_dvi and ma=b_ma;
delete ht_ma_nsd_nhom where ma_dvi=b_dvi and ma=b_ma;
delete ht_ma_nsd where ma_dvi=b_dvi and ma=b_ma;
delete ht_ma_nsd_txt where ma_dvi=b_dvi and ma=b_ma;
if FHTG_MA_NSD_ACC('',b_ma_login)<>'C' then delete ht_login where ma=b_ma_login; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- ma don vi
create or replace procedure PHT_MA_DVIJ_LKE(
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
    select count(*) into b_dong from ht_ma_dvi;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from ht_ma_dvi order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from ht_ma_dvi where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(a.*,'xep' value ma) obj from ht_ma_dvi a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_DVIJ_MA(
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
    select count(*) into b_dong from ht_ma_dvi;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from ht_ma_dvi order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from ht_ma_dvi order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma,ten,nsd,xep) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep,rownum sott from
                    (select * from ht_ma_dvi order by ma) a
                    start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from ht_ma_dvi where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from ht_ma_dvi where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(ma,ten,nsd,'xep' value ma) obj from ht_ma_dvi a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_DVIJ_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(20);b_cap varchar2(1);b_ten nvarchar2(100);b_ten_gon nvarchar2(100);b_dchi nvarchar2(100);b_ma_thue varchar2(30);b_g_doc nvarchar2(60);
    b_ktt nvarchar2(60);b_ten_sv varchar2(50);b_ten_db varchar2(50);b_ten_dbo varchar2(50);b_ip varchar2(50);b_ma_tk varchar2(20);b_nhang varchar2(50);
    b_kvuc varchar2(10);b_ma_ct varchar2(20);b_pas_di varchar2(10);b_pas_den varchar2(10);b_tt_hd varchar2(1);b_loai varchar2(1);b_vp varchar2(1);
    b_ngay_bd number;b_ngay_kt number;b_idvung number:=0;b_ma_goc varchar2(20);b_ma_ct_goc varchar2(20);b_tdx number;b_tdy number;
    b_ngay_bd_d date;b_ngay_kt_d date;
    b_ma_v varchar2(20); b_ma_ct_v varchar2(20); b_nsd_l varchar2(10);
begin
-- Dan
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'HT','HT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,cap,ten,ten_gon,dchi,ma_thue,g_doc,ktt,ten_sv,ten_db,ten_dbo,ip,ma_tk,nhang,kvuc,ma_ct,pas_di,pas_den,tt_hd,loai,vp,ngay_bd,ngay_kt,idvung,ma_goc,ma_ct_goc,tdx,tdy');
EXECUTE IMMEDIATE b_lenh into b_ma,b_cap,b_ten,b_ten_gon,b_dchi,b_ma_thue,b_g_doc,b_ktt,b_ten_sv,b_ten_db,b_ten_dbo,b_ip,b_ma_tk,b_nhang,b_kvuc,b_ma_ct,b_pas_di,b_pas_den,b_tt_hd,b_loai,b_vp,b_ngay_bd,b_ngay_kt,b_idvung,b_ma_goc,b_ma_ct_goc,b_tdx,b_tdy using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma don vi:loi'; raise PROGRAM_ERROR; end if;
if b_tt_hd is null or b_tt_hd not in('T','P') then
    b_loi:='loi:Trang thai Server: T-Tai cho; P-Phan tan:loi'; raise PROGRAM_ERROR;
end if;
if b_loai is null or b_loai not in('P','R','D') then
    b_loi:='loi:Loai: P-Hach toan phu thuoc, R-Hach toan rieng, D-Hach toan doc lap:loi'; raise PROGRAM_ERROR;
end if;
if trim(b_vp) is null then b_loi:='loi:Sai nho,:loi'; raise PROGRAM_ERROR; end if;
if b_cap is null or b_cap not between '1' and '5' then
    b_loi:='loi:Cap don vi tu 1-5:loi'; raise PROGRAM_ERROR;
end if;
if b_nhang is not null then
    b_loi:='loi:Ma ngan hang chua dang ky:loi';
    select count(1) into b_i1 from bh_ma_nhang where ma_dvi=b_ma_dvi and ma=b_nhang;
    if b_i1 <=0 then 
       raise PROGRAM_ERROR;
    end if;
end if;
if b_ma_ct is null then b_ma_ct:=' '; end if;
if b_ma_ct=b_ma then b_loi:='loi:Trung ma dang khai bao va ma cap tren:loi'; raise PROGRAM_ERROR; end if;
b_idvung:=0;
if b_idvung=0 then
    b_ma_v:=b_ma; b_ma_ct_v:=b_ma_ct;
else
    b_ma_ct_v:=to_char(b_idvung);
    b_ma_v:=b_ma_ct_v||'_'||b_ma;
    if trim(b_ma_ct) is not null then
        b_ma_ct_v:=b_ma_ct_v||'_'||b_ma_ct;
    end if;
end if;
if b_ngay_bd=0 then b_ngay_kt:=30000101; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_ngay_bd_d := PKH_SO_CDT(b_ngay_bd);
b_ngay_kt_d := PKH_SO_CDT(b_ngay_kt);
b_loi:='loi:Sai ma cap tren:loi';
b_loi:='loi:Va cham nguoi su dung:loi'; b_nsd_l:=FHT_MA_NSD_LUU(b_ma_dvi,b_nsd);
delete ht_ma_dvi where ma=b_ma_v;
delete ht_ma_dvi_txt where ma=b_ma_v;
insert into ht_ma_dvi values
    (b_ma_v,b_cap,b_ten,b_ten_gon,b_dchi,b_ma_thue,b_g_doc,b_ktt,b_ten_sv,b_ten_db,b_ten_dbo,b_ip,b_ma_tk,b_nhang,b_kvuc,
    b_ma_ct_v,b_pas_di,b_pas_den,b_tt_hd,b_loai,b_vp,b_ngay_bd,b_ngay_kt,b_nsd_l,b_idvung,b_ma,b_ma_ct,b_tdx,b_tdy);  
insert into ht_ma_dvi_txt values(b_ma,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_DVIJ_CT
      (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
      b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
      cs_ct clob; dt_txt clob; b_il number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma da xoa:loi';
select json_object(ma,cap,ten,ten_gon,dchi,ma_thue,g_doc,ktt,ten_sv,ten_db,
         ten_dbo,ip,ma_tk,nhang,kvuc,ma_ct,pas_di,pas_den,tt_hd,
         loai,vp,ngay_bd,ngay_kt,nsd,idvung,ma_goc,ma_ct_goc,tdx,tdy)
         into cs_ct from ht_ma_dvi where ma=b_ma;
select count(1) into b_il from ht_ma_dvi_txt where ma=b_ma;
if b_il<>0 then
   select json_object(txt returning clob) into cs_ct from ht_ma_dvi_txt where ma=b_ma;
end if;
--select json_object('cs_ct' value cs_ct, 'txt' value dt_txt returning clob) into b_oraOut from dual;
select json_object('cs_ct' value cs_ct returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_DVIJ_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma'); b_ma_cd varchar2(10);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_ma_dvi=b_ma then b_loi:='loi:Khong xoa don vi cua chinh NSD:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from ht_ma_dvi where ma_ct=b_ma;
if b_i1<>0 then
    select min(ma) into b_ma_cd from ht_ma_dvi where ma_ct=b_ma;
    b_loi:='loi:Co ma cap duoi#'||b_ma_cd||':loi'; raise PROGRAM_ERROR;
end if;
delete ht_ma_dvi where ma=b_ma;
delete ht_ma_dvi_txt where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/
create or replace procedure PKH_NSD_TSO_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,a_ma in out pht_type.a_var,a_tso pht_type.a_var)
AS
     b_loi varchar2(100); b_idvung number;
begin
-- Dan - Liet ke
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKH_MANG(a_ma);
delete kh_nsd_tso where ma_dvi=b_ma_dvi and nsd=b_nsd;
for b_lp in 1..a_ma.count loop
    insert into kh_nsd_tso values(b_ma_dvi,b_nsd,' ',a_ma(b_lp),a_tso(b_lp),b_idvung);
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_NSD_TSO_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,cs_lke out pht_type.cs_type)
AS
     b_loi varchar2(100); b_il number;
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_md is null then b_loi:='loi:Nhap Modul:loi'; end if;
select count(1) into b_il from kh_nsd_tso where ma_dvi=b_ma_dvi and nsd=b_nsd and md = b_md;
if b_il > 0 then 
   open cs_lke for select ma,tso from kh_nsd_tso where ma_dvi=b_ma_dvi and nsd=b_nsd and md = b_md;
else
   open cs_lke for select ma,tso from kh_nsd_tso where ma_dvi=b_ma_dvi and nsd=b_nsd and md = ' ';
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- ty gia thuc te
create or replace procedure PBH_MA_TGTTJ_LKE(
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
    select count(*) into b_dong from tt_tgtt;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select ma,PKH_NG_CSO(ngay) as ngay,ty_gia from tt_tgtt order by ma,ngay))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from tt_tgtt where upper(ma) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,rownum sott from
            (select ma,PKH_NG_CSO(ngay) as ngay,json_object(a.*,'xep' value ma) obj from tt_tgtt a)
            where upper(ma) like b_tim order by ma,ngay)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_TGTTJ_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_ct clob; b_ma varchar2(10);
    b_lenh varchar2(1000);
    b_ngay number; b_ngayD date;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
 
b_lenh:=FKH_JS_LENH('ma,ngay');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ngay using b_oraIn;
b_ngayD:=PKH_SO_CDT(b_ngay);
select json_object(ma,'ngay' value b_ngay,ty_gia) into cs_ct from tt_tgtt where ma=b_ma and ngay=b_ngayD;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_TGTTJ_NH
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2, b_oraIn clob)
AS
  b_loi varchar2(100); b_i1 number; b_idvung number:=0; b_lenh varchar2(1000);
  b_ma varchar2(10);b_ngay number;b_ty_gia number; b_ngayD date;
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
b_ngayD:= PKH_SO_CDT(b_ngay);
b_loi:='loi:Ma ngoai te chua dang ky:loi';
select 0 into b_i1 from tt_ma_nt where ma_dvi=b_ma_dvi and ma=b_ma;
if b_ty_gia<=0 then b_loi:='loi:Sai ty gia phai:loi'; raise PROGRAM_ERROR;end if;
b_loi:='loi:Va cham NSD:loi';
delete tt_tgtt where ma_dvi=b_ma_dvi and ma=b_ma and ngay=b_ngayD;
insert into tt_tgtt values (b_ma_dvi,b_ma,b_ngayD,b_ty_gia,b_nsd,b_idvung);
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
create or replace procedure PBH_HT_THUEJ_CT
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
  b_loi varchar2(100); b_lenh varchar2(1000);
  b_ngay number; cs_ct clob;
begin
-- Dan - Chi tiet ma thue
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay');
EXECUTE IMMEDIATE b_lenh into b_ngay using b_oraIn;
select json_object(t.ma_dvi,t.ngay,t.no_phi,t.hantt,t.tl_hh,t.tl_ht,t.hh_gt,t.hh_mg,t.hh_ht,t.hh_th,t.hh_do,t.hh_ta,
       t.gcn_2b,t.gcn_xe,t.gcn_ng,t.gcn_hang,t.gcn_tau,t.gcn_phh,t.gcn_pkt,t.gcn_ptn,t.gcn_td,t.phi_do,t.tt_do,t.ch_ta,
       t.gh_phh,t.gh_pkt,t.gh_hang,t.nsd) into cs_ct from bh_ht_thue t where t.ma_dvi=b_ma_dvi and t.ngay=b_ngay;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;

/

create or replace procedure PBH_HT_THUEJ_NH
       (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2, b_oraIn clob)
AS
  b_loi varchar2(100); b_lenh varchar2(1000);
  b_ngay number;b_noPhi varchar2(1);b_hanTT varchar2(3);b_tl_hh varchar2(1);b_tl_ht varchar2(1);
  b_hh_gt varchar2(1);b_hh_mg varchar2(1);b_hh_ht varchar2(1);b_hh_th varchar2(1);b_hh_do varchar2(1);b_hh_ta varchar2(1);
  b_gcn_2b varchar2(1);b_gcn_xe varchar2(1);b_gcn_ng varchar2(1);b_gcn_hang varchar2(1);b_gcn_tau varchar2(1);
  b_gcn_phh varchar2(1);b_gcn_pkt varchar2(1);b_gcn_ptn varchar2(1);b_gcn_td varchar2(1);b_phi_do varchar2(1);
  b_tt_do varchar2(1);b_ch_ta varchar2(1);b_gh_phh varchar2(1);b_gh_pkt varchar2(1);b_gh_hang varchar2(1);
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','Q');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay,nophi,hantt,tl_hh,tl_ht,hh_gt,hh_mg,hh_ht,hh_th,hh_do,hh_ta,
        gcn_2b,gcn_xe,gcn_ng,gcn_hang,gcn_tau,gcn_phh,gcn_pkt,gcn_ptn,gcn_td ,phi_do,
        tt_do ,ch_ta ,gh_phh ,gh_pkt ,gh_hang');
EXECUTE IMMEDIATE b_lenh into b_ngay,b_noPhi,b_hanTT,b_tl_hh,b_tl_ht,b_hh_gt,b_hh_mg,b_hh_ht,b_hh_th,b_hh_do,b_hh_ta,
        b_gcn_2b,b_gcn_xe,b_gcn_ng,b_gcn_hang,b_gcn_tau,b_gcn_phh,b_gcn_pkt,b_gcn_ptn,b_gcn_td ,b_phi_do,
        b_tt_do ,b_ch_ta ,b_gh_phh ,b_gh_pkt ,b_gh_hang using b_oraIn;

if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
if b_tl_hh is null or b_tl_hh not in('C','K') or b_tl_ht is null or b_tl_ht not in('C','K') or b_hh_ht is null or b_hh_gt not in('C','K') then
  b_loi:='loi:Sai kieu tinh hoa hong:loi'; raise PROGRAM_ERROR;
end if;
if b_hh_mg is null or b_hh_mg not in('C','T','K')
  or b_hh_ht is null or b_hh_ht not in('C','T','K')
  or b_hh_th is null or b_hh_th not in('T','Q','N')
  or b_hh_do is null or b_hh_do not in('C','K')
  or b_hh_ta is null or b_hh_ta not in('C','K')
  or b_gh_phh is null or b_gh_phh not in('C','K')
  or b_gh_pkt is null or b_gh_pkt not in('C','K')
  or b_gh_hang is null or b_gh_hang not in('C','K') then
  b_loi:='loi:Sai kieu quan ly:loi'; raise PROGRAM_ERROR;
end if;
if b_gcn_2b is null or b_gcn_2b not in('K','T','H','G') or b_gcn_xe is null or b_gcn_xe not in('K','T','H','G')
  or b_gcn_ng is null or b_gcn_ng not in('K','T','H','G') or b_gcn_hang is null or b_gcn_hang not in('K','C')
  or b_gcn_tau is null or b_gcn_tau not in('K','T','H','G') or b_gcn_phh is null or b_gcn_phh not in('K','C')
  or b_gcn_pkt is null or b_gcn_pkt not in('K','C') or b_gcn_ptn is null or b_gcn_ptn not in('K','C')
  or b_gcn_td is null or b_gcn_td not in('K','C') then
  b_loi:='loi:Sai kieu quan ly an chi:loi'; raise PROGRAM_ERROR;
end if;
if b_phi_do is null or b_phi_do not in('K','C') then b_loi:='loi:Sai kieu tinh phi dong BH:loi'; raise PROGRAM_ERROR; end if;
if b_tt_do is null or b_tt_do not in('K','C') then b_loi:='loi:Sai kieu xu ly thanh toan dong BH:loi'; raise PROGRAM_ERROR; end if;
if b_ch_ta is null or b_ch_ta not in('K','C') then b_loi:='loi:Sai kieu xu ly chuyen tai:loi'; raise PROGRAM_ERROR; end if;
delete bh_ht_thue where ma_dvi=b_ma_dvi and ngay=b_ngay;
insert into bh_ht_thue values(b_ma_dvi,b_ngay,b_noPhi,b_hanTT,b_tl_hh,b_tl_ht,b_hh_gt,b_hh_mg,b_hh_ht,b_hh_th,b_hh_do,b_hh_ta,
  b_gcn_2b,b_gcn_xe,b_gcn_ng,b_gcn_hang,b_gcn_tau,b_gcn_phh,b_gcn_pkt,b_gcn_ptn,b_gcn_td,b_phi_do,b_tt_do,
  b_ch_ta,b_gh_phh,b_gh_pkt,b_gh_hang,b_nsd);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FHTG_MA_NSD_QU(
    b_ma_dvi varchar2,b_nsd varchar2,b_md varchar2,b_nv varchar2,b_kt varchar2) return varchar2
AS
    b_i1 number; b_tc varchar2(10); b_i2 number:=length(b_kt);
begin
-- Dan - Kiem tra quyen NSD
if FHTG_MA_NSD_ACC(b_ma_dvi,b_nsd)='C' then return 'C'; end if;
if b_ma_dvi is null then return 'K'; end if;
if b_md is null then return 'C'; end if;
if b_nv is null or b_kt is null then
    if b_md<>'HT' then
        if b_nv is null and b_kt is null then
            select count(*) into b_i1 from ht_ma_nsd_nv where ma=b_nsd and md=b_md;
            if b_i1<>0 then return 'C'; end if;
            select count(*) into b_i1 from ht_ma_nsd_nhom where ma=b_nsd and md=b_md;
            if b_i1<>0 then return 'C'; end if;
        elsif b_nv is null then
            for r_lp in (select tc from ht_ma_nsd_nv where ma_dvi=b_ma_dvi and ma=b_nsd and md=b_md) loop
                b_tc:=r_lp.tc;
                if b_tc is not null then
                    for b_lp in 1..b_i2 loop
                        if instr(b_tc,substr(b_kt,b_lp,1))<>0 then return 'C'; end if;
                    end loop;
                end if;
            end loop;
            for r_lp1 in (select nhom from ht_ma_nsd_nhom where ma=b_nsd and md=b_md) loop
                for r_lp in (select tc from ht_ma_nhom_nv where md=b_md and ma=r_lp1.nhom) loop
                    b_tc:=r_lp.tc;
                    if b_tc is not null then
                        for b_lp in 1..b_i2 loop
                            if instr(b_tc,substr(b_kt,b_lp,1))<>0 then return 'C'; end if;
                        end loop;
                    end if;
                end loop;
            end loop;
        else
            select count(*) into b_i1 from ht_ma_nsd_nv where ma_dvi=b_ma_dvi and ma=b_nsd and md=b_md and nv=b_nv;
            if b_i1<>0 then return 'C'; end if;
            for r_lp in (select nhom from ht_ma_nsd_nhom where ma=b_nsd and md=b_md) loop
                select count(*) into b_i1 from ht_ma_nhom_nv where md=b_md and ma=r_lp.nhom and nv=b_nv;
                if b_i1<>0 then return 'C'; end if;
            end loop;
        end if;
    else return 'C';
    end if;
else
    if b_md<>'HT' then
        select min(tc) into b_tc from ht_ma_nsd_nv where ma_dvi=b_ma_dvi and ma=b_nsd and md='HT' and nv='ND';
        if b_tc is not null and instr(b_tc,'Q')<>0 then return 'C'; end if;
    end if;
    select min(tc) into b_tc from ht_ma_nsd_nv where ma_dvi=b_ma_dvi and ma=b_nsd and md=b_md and nv=b_nv;
    if b_tc is not null then
        for b_lp in 1..b_i2 loop
            if instr(b_tc,substr(b_kt,b_lp,1))<>0 then return 'C'; end if;
        end loop;
    end if;
    for r_lp in (select nhom from ht_ma_nsd_nhom where ma=b_nsd) loop
        select min(tc) into b_tc from ht_ma_nhom_nv where md=b_md and ma=r_lp.nhom and nv=b_nv;
        if b_tc is not null then
            for b_lp in 1..b_i2 loop
                if instr(b_tc,substr(b_kt,b_lp,1))<>0 then return 'C'; end if;
            end loop;
        end if;
    end loop;
end if;
return 'K';
end;
/
/* viet anh -- thong ke thoi gian he thong */
create or replace procedure FHT_TSO_HD_TG_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    dt_tg clob;
    tg_ma pht_type.a_var; tg_ten pht_type.a_nvar; tg_tgian pht_type.a_num;
begin
-- viet anh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('dt_tg');
EXECUTE IMMEDIATE b_lenh into dt_tg using b_oraIn;
b_lenh:=FKH_JS_LENH('ma,ten,tgian');
EXECUTE IMMEDIATE b_lenh bulk collect into tg_ma,tg_ten,tg_tgian using dt_tg;
if tg_ma.count<>0 then
    for b_lp in 1..tg_ma.count loop
        delete ht_tso_hd where ma=tg_ma(b_lp);
        insert into ht_tso_hd values(tg_ma(b_lp),tg_ten(b_lp),tg_tgian(b_lp));
    end loop;
end if;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;

/
create or replace procedure FHT_TSO_HD_TG_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob:='';
begin
-- viet anh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,tgian) order by ma) into cs_lke from ht_tso_hd;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FHT_MA_DVI_KTRA (b_idvung number,b_ma_dvi varchar2) return varchar2
AS
	b_loi varchar2(100); b_i1 number;
begin
-- Dan - Kiem tra ma don vi
b_loi:='loi:Sai ma don vi:loi';
if b_ma_dvi is null then return b_loi; end if;
select count(*) into b_i1 from (select ma from ht_ma_dvi where idvung=b_idvung) where ma=b_ma_dvi;
if b_i1<>0 then b_loi:=''; end if;
return b_loi;
end;
/
create or replace procedure PHT_MA_DVI_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_idvung number;
begin
-- Dan - Liet ke tat ca don vi
b_idvung:=FHT_MA_NSD_VUNG(b_ma_dvi,b_nsd);
if b_idvung<0 then b_loi:='loi:Cam xam nhap:loi'; raise PROGRAM_ERROR; end if;
open cs1 for select ma dvi,ten,ten_gon from ht_ma_dvi where idvung=b_idvung order by ma;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/