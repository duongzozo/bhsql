/* Ma san pham */
create or replace function FBH_PTNCH_SP_HAN(b_ma varchar2,b_dk varchar2:='C') return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Nam - Kiem tra con hieu luc
select count(*) into b_i1 from bh_ptnch_sp where ma=b_ma and tc in('C',b_dk) and b_ngay between ngay_bd and ngay_kt;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_PTNCH_SP_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
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
    select count(*) into b_dong from bh_ptnch_sp;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_ptnch_sp order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ptnch_sp where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(a.*,'xep' value ma) obj from bh_ptnch_sp a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNCH_SP_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(20); b_tim nvarchar2(500); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_ptnch_sp;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_ptnch_sp order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_ptnch_sp order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(*) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep,rownum sott from
                (select * from bh_ptnch_sp order by ma) a
                start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ptnch_sp where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_ptnch_sp where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(a.*,'xep' value ma) obj from bh_ptnch_sp a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNCH_SP_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma'); cs_ct clob;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,txt) into cs_ct from bh_ptnch_sp where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNCH_SP_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(20); b_ten nvarchar2(500); b_tc varchar2(1);
    b_ma_ct varchar2(10); b_nhom varchar2(10); b_ngay_bd number; b_ngay_kt number;
begin
-- Nam
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
    select 0 into b_i1 from bh_ptnch_sp where ma=b_ma_ct and tc='T';
end if;
if b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_ptnch_sp where ma=b_ma;
insert into bh_ptnch_sp values(b_ma_dvi,b_ma,b_ten,b_tc,b_ma_ct,b_nhom,b_ngay_bd,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNCH_SP_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_ptnch_sp where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_ptnch_sp where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_PTNCH_SP_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Nam
select min(ten) into b_kq from bh_ptnch_sp where ma=b_ma;
return b_kq;
end;
/
/* bieu phi trach nhiem */
create or replace function FBH_PTNCH_BPHI_SO_ID
    (b_ma_sp varchar2,b_cdich varchar2,b_ngay_hl number:=0) return number
AS
    b_so_id number:=0; b_ma_spM varchar2(10);b_ngay number:=b_ngay_hl;
begin
-- Nam - Tra so ID phi 
if b_ngay in(0,30000101) then b_ngay:=PKH_NG_CSO(sysdate); end if;
select max(ma_sp) into b_ma_spM from bh_ptnch_phi where ma_sp=b_ma_sp and cdich=b_cdich and b_ngay between ngay_bd and ngay_kt;
if b_ma_spM is not null then
    select nvl(max(so_id),0) into b_so_id from bh_ptnch_phi where 
    ma_sp=b_ma_sp and cdich=b_cdich and b_ngay between ngay_bd and ngay_kt;
end if;
return b_so_id;
end;
/
create or replace function FBH_PTNCH_BPHI_SO_IDh(
    b_nhom varchar2,b_ma_sp varchar2,b_cdich varchar2,b_ghan varchar2,b_ngay_hl number:=0) return number
AS
    b_so_id number:=0; b_ma_spM varchar2(10); b_ngay number:=b_ngay_hl;
begin
-- Nam - Tra so ID con han su dung
if b_ngay in(0,30000101) then b_ngay:=PKH_NG_CSO(sysdate); end if;
select max(ma_sp) into b_ma_spM from bh_ptnch_phi where 
       nhom=b_nhom and ma_sp=b_ma_sp and cdich in (' ',b_cdich) and ghan in (' ',b_ghan) and b_ngay between ngay_bd and ngay_kt;
if b_ma_spM is not null then
    select nvl(max(so_id),0) into b_so_id from bh_ptnch_phi where 
           nhom=b_nhom and ma_sp=b_ma_sp and cdich in (' ',b_cdich) and ghan in (' ',b_ghan) and b_ngay between ngay_bd and ngay_kt;
end if;
return b_so_id;
end;
/
create or replace procedure PBH_PTNCH_BPHI_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob, b_oraOut out clob)
AS
    b_loi varchar2(100); b_nv varchar2(10):=FKH_JS_GTRIs(b_oraIn,'nv'); cs_sp clob; cs_cdich clob; cs_lt clob; cs_khd clob; cs_kbt clob;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten returning clob) order by ten returning clob) into cs_sp from bh_ptnch_sp where FBH_PTNCH_SP_HAN(ma)='C' and nhom=b_nv;  
select JSON_ARRAYAGG(json_object(ma,ten returning clob) order by ten returning clob) into cs_cdich from bh_ma_cdich where FBH_MA_NV_CO(nv,'PTN')='C' and FBH_MA_CDICH_HAN(ma)='C';
select JSON_ARRAYAGG(json_object(ma_dk,ten,'ma_lt' value ma) returning clob) into cs_lt from bh_ma_dklt a where FBH_MA_NV_CO(nv,'PTN')='C' and FBH_MA_DKLT_HAN(ma_dk,ma)='C' and MA <> ' '; -- ma = ' ' la goc
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_khd from bh_kh_ttt where ps='KHD' and nv='PTN';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_kbt from bh_kh_ttt where ps='KBT' and nv='PTN';
select json_object('cs_sp' value cs_sp,'cs_cdich' value cs_cdich,'cs_lt' value cs_lt,'cs_khd' value cs_khd,'cs_kbt' value cs_kbt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNCH_BPHI_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_so_id number;
    b_ma_sp varchar2(10); b_cdich varchar2(10);
begin
-- Nam - Tra so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_sp,cdich');
EXECUTE IMMEDIATE b_lenh into b_ma_sp,b_cdich using b_oraIn;
if trim(b_ma_sp) is null then
    b_so_id:=0;
else
    b_cdich:=nvl(b_cdich,' ');
    b_so_id:=FBH_PTNCH_BPHI_SO_ID(b_ma_sp,b_cdich);
end if;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNCH_BPHI_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma_sp varchar2(500);
    b_tu number; b_den number; b_dong number; cs_lke clob;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_sp,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ma_sp,b_tu,b_den using b_oraIn;
b_ma_sp:=PKH_MA_TENl(b_ma_sp);
b_ma_sp:=nvl(b_ma_sp,' ');
select count(*) into b_dong from bh_ptnch_phi where b_ma_sp in(' ',ma_sp);
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(so_id,nhom,'ma_sp' value FBH_PTNCH_SP_TEN(ma_sp),'cdich' value FBH_MA_CDICH_TEN(cdich),
       tlph,ghan,ngay_bd,ngay_kt) returning clob) into cs_lke from
    (select so_id,nhom,ma_sp,cdich,tlph,ghan,ngay_bd,ngay_kt,rownum sott from bh_ptnch_phi
    where b_ma_sp in(' ',ma_sp)
    order by ma_sp,nhom,ngay_bd)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNCH_BPHI_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_tu number; b_den number; b_hangKt number; b_dt_ct clob;
    b_ma_sp varchar2(100); b_cdich varchar2(100); b_tl_phi number;
    b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('hangKt,dt_ct');
EXECUTE IMMEDIATE b_lenh into b_hangKt,b_dt_ct using b_oraIn;
b_lenh:=FKH_JS_LENH('ma_sp,cdich,tlph');
EXECUTE IMMEDIATE b_lenh into b_ma_sp,b_cdich,b_tl_phi using b_dt_ct;
b_ma_sp:=nvl(trim(b_ma_sp),' '); b_cdich:=nvl(trim(b_cdich),' '); b_tl_phi:=nvl(b_tl_phi,0);
select count(*) into b_dong from bh_ptnch_phi;
select nvl(min(sott),b_dong) into b_tu from
    (select a.*,rownum sott from bh_ptnch_phi a order by ma_sp,cdich,tlph)
    where ma_sp=b_ma_sp and cdich=b_cdich and tlph=b_tl_phi;
PKH_LKE_VTRI(b_hangKt,b_tu,b_den,b_trang);
select JSON_ARRAYAGG(obj returning clob) into cs_lke from
    (select json_object(a.*) obj,rownum sott from bh_ptnch_phi a order by ma_sp,cdich,tlph)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNCH_BPHI_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)

AS
    b_loi varchar2(100); b_i1 number; b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
    dt_dk clob; dt_dkbs clob:=''; dt_khd clob:=''; dt_kbt clob:=''; dt_ct clob; dt_lt clob; dt_txt clob;
begin
-- Nam - Xem chi tiet theo so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Bieu phi da xoa:loi';
select JSON_ARRAYAGG(json_object(so_id,nsd)) into dt_ct from bh_ptnch_phi where so_id=b_so_id;
select txt into dt_dk from bh_ptnch_phi_txt where so_id=b_so_id and loai='dt_dk';
select count(*) into b_i1 from bh_ptnch_phi_txt where so_id=b_so_id and loai='dt_dkbs';
if b_i1<>0 then
    select txt into dt_dkbs from bh_ptnch_phi_txt where so_id=b_so_id and loai='dt_dkbs';
end if;
select JSON_ARRAYAGG(json_object(ma_lt) order by bt) into dt_lt from bh_ptnch_phi_lt where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt from bh_ptnch_phi_txt where so_id=b_so_id and loai in('dt_ct','dt_lt');
select count(*) into b_i1 from bh_ptnch_phi_txt where so_id=b_so_id and loai='dt_khd';
if b_i1<>0 then
    select txt into dt_khd from bh_ptnch_phi_txt where so_id=b_so_id and loai='dt_khd';
end if;
select count(*) into b_i1 from bh_ptnch_phi_txt where so_id=b_so_id and loai='dt_kbt';
if b_i1<>0 then
    select txt into dt_kbt from bh_ptnch_phi_txt where so_id=b_so_id and loai='dt_kbt';
end if;
select json_object('so_id' value b_so_id,'dt_dk' value dt_dk,'dt_dkbs' value dt_dkbs,
    'dt_khd' value dt_khd,'dt_kbt' value dt_kbt,'dt_ct' value dt_ct,
    'dt_lt' value dt_lt,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNCH_BPHI_CTs(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); dt_ct clob:=FKH_JS_GTRIc(b_oraIn,'dt_ct');
    b_nhom varchar2(1); b_ma_sp varchar2(20); b_cdich varchar2(20); 
    b_ghan varchar2(1); b_ngay_hl number; b_so_id number;
begin
-- Nam - Tra so_id bieu phi theo dieu kien
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nhom,ma_sp,cdich,ghan_m,ngay_hl');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_ma_sp,b_cdich,b_ghan,b_ngay_hl using dt_ct;
b_cdich:=nvl(b_cdich,' '); b_ma_sp:=nvl(b_ma_sp,' '); b_ghan:=nvl(b_ghan,' ');
b_so_id:=FBH_PTNCH_BPHI_SO_IDh(b_nhom,b_ma_sp,b_cdich,b_ghan,b_ngay_hl);
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNCH_BPHI_CTd(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(1000); b_i1 number; b_so_id number;
    cs_dk clob; cs_dkbs clob; dt_khd clob:=''; cs_kbt clob:=''; cs_lt clob; cs_txt clob;
    b_tlph number; b_nt_phi varchar2(5); b_nt_tien varchar2(5); b_tygia number;
begin
-- Nam - Tra bieu phi theo so_id
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,nt_tien,nt_phi,tygia');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_nt_tien,b_nt_phi,b_tygia using b_oraIn;
b_tygia:=nvl(b_tygia,1);
if trim(b_nt_tien)<>trim(b_nt_phi) and trim(b_nt_tien)<>'VND' and trim(b_nt_phi)<>'VND' then
   b_loi:='loi:Sai nguyen te phi:loi'; raise PROGRAM_ERROR;
end if;
if nvl(trim(b_nt_phi),'VND')='VND' and b_tygia<=0 then b_tygia:=1; end if;
insert into temp_1(c1,n1) select ma,min(bt) from bh_ptnch_phi_dk where so_id=b_so_id and lh_bh<>'M' group by ma;
select JSON_ARRAYAGG(json_object(
    a.ma,ten,
    'tien' value case when b_nt_tien<>'VND' then round(tien/b_tygia,2) else tien end,
    'ptB' value case when b_nt_phi<>'VND' then decode(sign(pt-100),1,round(pt/b_tygia,4),pt) else pt end,
    'pt' value '',phi,cap,tc,ma_ct,ma_dk,kieu,lh_nv,t_suat,lkeM,lkeP,lkeB,luy,ktru,lh_bh,bt,
    'ptk' value decode(sign(pt-50),1,'T','P'))
    order by a.bt returning clob) into cs_dk
    from bh_ptnch_phi_dk a,temp_1 b where a.so_id=b_so_id and b.n1=a.bt and lh_bh<>'M' order by a.bt; 
insert into temp_1(c1,n1) select ma,min(bt) from bh_ptnch_phi_dk where so_id=b_so_id and lh_bh='M' group by ma;
select JSON_ARRAYAGG(json_object(
    a.ma,ten,
    'tien' value case when b_nt_tien<>'VND' then round(tien/b_tygia,2) else tien end,
    'ptB' value case when b_nt_phi<>'VND' then decode(sign(pt-100),1,round(pt/b_tygia,4),pt) else pt end,
    'pt' value '',phi,cap,tc,ma_ct,ma_dk,kieu,lh_nv,t_suat,lkeM,lkeP,lkeB,luy,ktru,lh_bh,bt,
    'ptk' value decode(sign(pt-50),1,'T','P'))
    order by a.bt returning clob) into cs_dkbs
    from bh_ptnch_phi_dk a,temp_1 b where a.so_id=b_so_id and b.n1=a.bt and lh_bh='M' order by a.bt;
select JSON_ARRAYAGG(json_object('ma_lt' value ma_lt) order by bt returning clob)
    into cs_lt from bh_ptnch_phi_lt where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into cs_txt
    from bh_ptnch_phi_txt where so_id=b_so_id and loai='dt_lt';
select count(*) into b_i1 from bh_ptnch_phi_txt where so_id=b_so_id and loai='dt_khd';
if b_i1<>0 then
    select txt into dt_khd from bh_ptnch_phi_txt where so_id=b_so_id and loai='dt_khd';
end if;
select count(*) into b_i1 from bh_ptnch_phi_txt where so_id=b_so_id and loai='dt_kbt';
if b_i1<>0 then
    select txt into cs_kbt from bh_ptnch_phi_txt where so_id=b_so_id and loai='dt_kbt';
end if;
select count(tlph) into b_i1 from bh_ptnch_phi where so_id=b_so_id;
if b_i1<>0 then
    select tlph into b_tlph from bh_ptnch_phi where so_id=b_so_id;
end if;
select json_object('dt_dk' value cs_dk,'dt_dkbs' value cs_dkbs,'dt_khd' value dt_khd,'dt_kbt' value cs_kbt,
    'dt_lt' value cs_lt,'tlph' value b_tlph,'txt' value cs_txt returning clob) into b_oraOut from dual;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNCH_BPHI_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_i1 number; b_ma_ct varchar2(10);
    b_kt number; b_i2 number; b_nhom varchar2(1);
    b_ma_sp varchar2(10); b_cdich varchar2(10);
    b_tl_phi number; b_ghan varchar2(1); b_ngay_bd number; b_ngay_kt number;

    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var; dk_ma_ct pht_type.a_var;
    dk_kieu pht_type.a_var; dk_tien pht_type.a_num; dk_pt pht_type.a_num;
    dk_phi pht_type.a_num; dk_lkeM pht_type.a_var; dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var;
    dk_luy pht_type.a_var; dk_ktru pht_type.a_var;
    dk_ma_dk pht_type.a_var; dk_ma_dkC pht_type.a_var; dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num; dk_lh_bh pht_type.a_var;

    dkB_ma pht_type.a_var; dkB_ten pht_type.a_nvar; dkB_tc pht_type.a_var; dkB_ma_ct pht_type.a_var;
    dkB_kieu pht_type.a_var; dkB_tien pht_type.a_num; dkB_pt pht_type.a_num;
    dkB_phi pht_type.a_num; dkB_lkeM pht_type.a_var; dkB_lkeP pht_type.a_var; dkB_lkeB pht_type.a_var;
    dkB_luy pht_type.a_var; dkB_ktru pht_type.a_var; dkB_ma_dk pht_type.a_var;

    lt_ma_dk pht_type.a_var; lt_ma_lt pht_type.a_var; lt_ten pht_type.a_var;
    b_dt_ct clob; b_dt_dk clob; b_dt_dkbs clob; b_dt_lt clob; b_dt_khd clob; b_dt_kbt clob; b_so_id number;
begin
-- Nam - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_dkbs,dt_lt,dt_khd,dt_kbt');
EXECUTE IMMEDIATE b_lenh into b_dt_ct,b_dt_dk,b_dt_dkbs,b_dt_lt,b_dt_khd,b_dt_kbt using b_oraIn;
FKH_JS_NULL(b_dt_ct); FKH_JSa_NULL(b_dt_dk); FKH_JSa_NULL(b_dt_dkbs);
FKH_JSa_NULL(b_dt_lt); FKH_JSa_NULL(b_dt_khd); FKH_JSa_NULL(b_dt_kbt);
b_lenh:=FKH_JS_LENH('nhom,ma_sp,cdich,tlph,ghan,ngay_bd,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_ma_sp,b_cdich,b_tl_phi,b_ghan,b_ngay_bd,b_ngay_kt using b_dt_ct;
if trim(b_ma_sp) is null then
    b_loi:='loi:Nhap san pham:loi'; raise PROGRAM_ERROR;
elsif FBH_PTNCH_SP_HAN(b_ma_sp)<>'C' then
    b_loi:='loi:Ma san pham '||b_ma_sp||'da het su dung:loi'; raise PROGRAM_ERROR;
end if;
if trim(b_cdich) is not null then
   if FBH_MA_CDICH_HAN(b_cdich)<>'C' then
    b_loi:='loi:Da het chien dich:loi'; raise PROGRAM_ERROR;
    end if;
end if;
b_ma_sp:=nvl(b_ma_sp,' '); b_cdich:=nvl(b_cdich,' '); b_tl_phi:=nvl(b_tl_phi,0); b_ghan:=nvl(b_ghan,' ');
if b_ngay_bd is null or b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
if b_ngay_kt is null or b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,ma_dk,kieu,tien,pt,phi,lkem,lkep,lkeb,luy,ktru');
EXECUTE IMMEDIATE b_lenh bulk collect into
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_ma_dk,dk_kieu,dk_tien,dk_pt,dk_phi,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy,dk_ktru using b_dt_dk;
b_kt:=dk_ma.count;
if b_kt=0 then b_loi:='loi:Nhap dieu khoan:loi'; raise PROGRAM_ERROR; end if;
for b_lp in 1..b_kt loop dk_lh_bh(b_lp):='C'; end loop;
if trim(b_dt_dkbs) is not null then
    EXECUTE IMMEDIATE b_lenh bulk collect into
        dkB_ma,dkB_ten,dkB_tc,dkB_ma_ct,dkB_ma_dk,dkB_kieu,dkB_tien,dkB_pt,dkB_phi,
        dkB_lkeM,dkB_lkeP,dkB_lkeB,dkB_luy,dkB_ktru using b_dt_dkbs;
    for b_lp in 1..dkB_ma.count loop
        b_kt:=b_kt+1; dk_lh_bh(b_kt):='M';
        dk_ma(b_kt):=dkB_ma(b_lp); dk_ten(b_kt):=dkB_ten(b_lp); dk_tc(b_kt):=dkB_tc(b_lp);
        dk_ma_ct(b_kt):=dkB_ma_ct(b_lp); dk_ma_dk(b_kt):=dkB_ma_dk(b_lp); dk_kieu(b_kt):=dkB_kieu(b_lp);
        dk_tien(b_kt):=dkB_tien(b_lp); dk_pt(b_kt):=dkB_pt(b_lp); dk_phi(b_kt):=dkB_phi(b_lp);
        dk_lkeM(b_kt):=dkB_lkeM(b_lp); dk_lkeP(b_kt):=dkB_lkeP(b_lp); dk_lkeB(b_kt):=dkB_lkeB(b_lp);
        dk_luy(b_kt):=dkB_luy(b_lp); dk_ktru(b_kt):=dkB_ktru(b_lp);
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
    if dk_ma(b_lp)=dk_ma_ct(b_lp) then b_loi:='loi:Trung ma cap tren ma: '||dk_ma(b_lp)||':loi'; raise PROGRAM_ERROR; end if;
    if dk_tc(b_lp)='C' then
        dk_lkeM(b_lp):=nvl(trim(dk_lkeM(b_lp)),'G'); dk_lkeP(b_lp):=nvl(trim(dk_lkeP(b_lp)),'G');
        dk_lkeB(b_lp):=nvl(trim(dk_lkeB(b_lp)),'G');
    else
        dk_lkeM(b_lp):=nvl(trim(dk_lkeM(b_lp)),'K'); dk_lkeP(b_lp):=nvl(trim(dk_lkeP(b_lp)),'T');
        dk_lkeB(b_lp):=nvl(trim(dk_lkeB(b_lp)),'T');
    end if;
    dk_luy(b_lp):=nvl(trim(dk_luy(b_lp)),'C'); dk_ktru(b_lp):=nvl(trim(dk_ktru(b_lp)),'K'); dk_kieu(b_lp):=nvl(trim(dk_kieu(b_lp)),'T');
    dk_ma_dk(b_lp):=nvl(trim(dk_ma_dk(b_lp)),' '); dk_lh_nv(b_lp):=' '; dk_t_suat(b_lp):=0; dk_lkeM(b_lp):=nvl(trim(dk_lkeM(b_lp)),'G');
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
b_so_id:=FBH_PTNCH_BPHI_SO_IDh(b_nhom,b_ma_sp,b_cdich,b_ghan,b_ngay_bd);
if b_so_id<>0 then
    delete bh_ptnch_phi_txt where so_id=b_so_id;
    delete bh_ptnch_phi_lt where so_id=b_so_id;
    delete bh_ptnch_phi_dk where so_id=b_so_id;
    delete bh_ptnch_phi where so_id=b_so_id;
end if;
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_loi:='loi:Loi Table bh_ptnch_phi:loi';
insert into bh_ptnch_phi values(b_ma_dvi,b_so_id,b_nhom,b_ma_sp,b_cdich,b_tl_phi,b_ghan,b_ngay_bd,b_ngay_kt,b_nsd);
insert into bh_ptnch_phi_txt values(b_ma_dvi,b_so_id,'dt_ct',b_dt_ct);
insert into bh_ptnch_phi_txt values(b_ma_dvi,b_so_id,'dt_dk',b_dt_dk);
if trim(b_dt_dkbs) is not null then
    insert into bh_ptnch_phi_txt values(b_ma_dvi,b_so_id,'dt_dkbs',b_dt_dkbs);
end if;
for b_lp in 1..dk_ma.count loop
   insert into bh_ptnch_phi_dk values(b_ma_dvi,b_so_id,b_lp,dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),
        dk_kieu(b_lp),dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),dk_lkeM(b_lp),dk_lkeP(b_lp),dk_lkeB(b_lp),dk_luy(b_lp),dk_ktru(b_lp),
        dk_ma_dk(b_lp),dk_ma_dkC(b_lp),dk_lh_nv(b_lp),dk_t_suat(b_lp),0,dk_lh_bh(b_lp));
end loop;
for r_lp in(select ma,ma_ct,so_id,bt,level from  (select t.so_id,t.bt,t.ma,t.ma_ct from bh_ptnch_phi_dk t where t.so_id = b_so_id) t start with t.ma_ct=' '  CONNECT BY prior t.ma=t.ma_ct) loop
    update bh_ptnch_phi_dk set cap=r_lp.level where so_id=r_lp.so_id and bt=r_lp.bt;
end loop;
if lt_ma_lt.count<>0 then
    for b_lp in 1..lt_ma_lt.count loop
        insert into bh_ptnch_phi_lt values(b_ma_dvi,b_so_id,b_lp,lt_ma_lt(b_lp),lt_ten(b_lp));
    end loop;
    insert into bh_ptnch_phi_txt values(b_ma_dvi,b_so_id,'dt_lt',b_dt_lt);
end if;
if trim(b_dt_khd) is not null then
    insert into bh_ptnch_phi_txt values(b_ma_dvi,b_so_id,'dt_khd',b_dt_khd);
end if;
if trim(b_dt_kbt) is not null then
    insert into bh_ptnch_phi_txt values(b_ma_dvi,b_so_id,'dt_kbt',b_dt_kbt);
end if;
commit;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNCH_BPHI_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS 
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Nam - Xoa bieu phi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then b_loi:='loi:Chon bieu phi can xoa:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table bh_ptnch_phi:loi';
delete bh_ptnch_phi_txt where so_id=b_so_id;
delete bh_ptnch_phi_lt where so_id=b_so_id;
delete bh_ptnch_phi_dk where so_id=b_so_id;
delete bh_ptnch_phi where so_id=b_so_id;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNCH_BPHId_THEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_i1 number;
    b_nhom varchar2(1); b_ma_sp varchar2(20); b_cdich varchar2(20); b_ngay_hl number; b_so_id number; b_vu varchar2(10);
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tygia number; b_ghan varchar2(1);
    b_dk_lt clob; a_ma_lt pht_type.a_var; a_ma_dk_lt pht_type.a_var; a_ten_lt pht_type.a_nvar; a_chon_lt pht_type.a_var;
begin
-- Nam - Tra so_id bieu phi theo dieu kien
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nhom,ma_sp,cdich,ghan_m,ngay_hl,vu,nt_tien,nt_phi,tygia');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_ma_sp,b_cdich,b_ghan,b_ngay_hl,b_vu,b_nt_tien,b_nt_phi,b_tygia using b_oraIn;
b_cdich:=nvl(b_cdich,' '); b_ghan:=nvl(b_ghan,' ');
b_so_id:=FBH_PTNCH_BPHI_SO_IDh(b_nhom,b_ma_sp,b_cdich,b_ghan,b_ngay_hl);
b_nt_phi:=NVL(trim(b_nt_phi),'VND'); b_nt_tien:=NVL(trim(b_nt_tien),'VND');
b_tygia:=nvl(b_tygia,1);
if nvl(trim(b_nt_phi),'VND')='VND' and b_tygia<=0 then b_tygia:=1; end if;
b_oraOut:='';
if b_vu='dkbs' then
    select JSON_ARRAYAGG(json_object(ma,ten,'tien' value case when b_nt_tien='VND' then tien else round(tien/b_tygia,2) end,
                'ptB' value case when b_nt_phi<>'VND' then decode(sign(pt-100),1,round(pt/b_tygia,4),pt) else pt end,
                pt,ma_ct,tc,phi,cap,lh_nv,lkeM,lkeP,bt,'ptk' value decode(sign(pt-50),1,'T','P')) order by ma,ten returning clob) into b_oraOut from
        (select ma,ten,tien,pt,ma_ct,tc,phi,cap,lh_nv,luy,ktru,lkeM,lkeP,bt
                from bh_ptnch_phi_dk where so_id=b_so_id and lh_bh='M' union
       select ma,ten,null tien,null pt,'' ma_ct,'T' tc,null phi,null cap,lh_nv,'' luy,'K' ktru,'K' lkeM,'K' lkeP,999 from bh_ma_dkbs where FBH_MA_NV_CO(nv,'PTN')='C');
elsif b_so_id<>0 then
    if b_vu='dk' then
        select JSON_ARRAYAGG(json_object(ma,ten,'tien' value case when b_nt_tien='VND' then tien else round(tien/b_tygia,2) end,
                'ptB' value case when b_nt_phi<>'VND' then decode(sign(pt-100),1,round(pt/b_tygia,4),pt) else pt end,
                pt,ma_ct,tc,phi,cap,lh_nv,lkeP,bt,luy,ktru,'ptk' value decode(sign(pt-50),1,'T','P')) order by bt returning clob)
            into b_oraOut from bh_ptnch_phi_dk where so_id=b_so_id and lh_bh<>'M' order by bt;
    elsif b_vu='lt' then
      select count(*) into b_i1 from bh_ptnch_phi_txt where so_id=b_so_id and loai='dt_lt';
        if b_i1 >0 then
             select txt into b_dk_lt from bh_ptnch_phi_txt where so_id=b_so_id and loai='dt_lt';
             b_lenh:=FKH_JS_LENH('ma_lt,ten,ma_dk,chon');
             EXECUTE IMMEDIATE b_lenh bulk collect into a_ma_lt,a_ten_lt,a_ma_dk_lt,a_chon_lt using b_dk_lt;
             if a_ma_lt.count > 0 then
               for b_i1 in 1..a_ma_lt.count loop
                    insert into temp_1(c1,c2,c3,c4) VALUES (a_ma_lt(b_i1),a_ten_lt(b_i1),a_ma_dk_lt(b_i1),a_chon_lt(b_i1));
               end loop;
             end if;
          end if;
          for r_lp in (select ma,ten,ma_dk from bh_ma_dklt where FBH_MA_NV_CO(nv,'PTN')='C') loop
            select count(*) into b_i1 from temp_1 where c1=r_lp.ma;
            if b_i1=0 then insert into temp_1(c1,c2,c3,c4) values(r_lp.ma,r_lp.ten,r_lp.ma_dk,' '); end if;
          end loop;
          select JSON_ARRAYAGG(json_object('ma_lt' value c1,'ten' value c2,'ma_dk' value c3,'chon' value c4)
              order by c1,c2 returning clob) into b_oraOut from temp_1;
    end if;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
