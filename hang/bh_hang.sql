create or replace function FBH_HANG_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_txt clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
select count(*) into b_i1 from bh_hang_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_hang_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
else
    select nvl(max(lan),0) into b_i1 from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    if b_i1<>0 then
        select txt into b_txt from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_i1 and loai='dt_ct';
    end if;
end if;
if b_i1=1 then
	PKH_JS_BONH(b_txt); b_kq:=FKH_JS_GTRIs(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_HANG_TXTn(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return number
AS
    b_kq number:=0; b_i1 number; b_id number; b_txt clob; b_lenh varchar2(1000);
    a_ds_ct pht_type.a_clob;
begin
-- Dan - Tra gia tri num trong txt
select count(*) into b_i1 from bh_hang_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_hang_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    PKH_JS_BONH(b_txt); b_kq:=FKH_JS_GTRIn(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_HANG_SO_IDb(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_HANG_SO_IDd(b_ma_dvi,b_so_id);
select nvl(max(so_id),0) into b_kq from bh_hang where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D' and ngay_cap<=b_ngay;
return b_kq;
end;
/
create or replace procedure PBH_HANG_SO_IDt(
    b_so_id in out number,b_ma_dvi out varchar2,b_so_idD out number,b_ngay number:=30000101)
as
begin
-- Nam - Tra so id cuoi
select min(ma_dvi) into b_ma_dvi from bh_hang where so_id=b_so_id;
b_so_idD:=FBH_HANG_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
end;
/
create or replace function FBH_HANG_SO_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Nam - Tra so hop dong
select min(so_hd) into b_kq from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_HANG_HD_SO_IDd(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Nam - Tra so id dau
select nvl(min(so_id_d),0) into b_kq from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_HANG_SO_HDG(b_ma_dvi varchar2,b_so_hd varchar2) return varchar2
as
    b_kq varchar2(50);
begin
-- Nam - Tra so hop dong goc theo so hop dong
select min(so_hd_g) into b_kq from bh_hang where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
return b_kq;
end;
/
create or replace function FBH_HANG_SO_HD_DK(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Nam - Tra so hop dong dieu khoan
select min(so_hd_g) into b_kq from bh_hang_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_HANG_DVI(b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Nam - Tra ma dvi
select ma_dvi into b_kq from bh_hang where so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_HANG_SO_ID(b_ma_dvi varchar2,b_so_hd varchar2) return number
as
    b_kq number;
begin
-- Nam - Tra so id
select nvl(min(so_id),0) into b_kq from bh_hang where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
return b_kq;
end;
/
create or replace function FBH_HANG_SO_ID_BS(
    b_ma_dvi varchar2,b_so_id number,b_ngay_ht number) return number
AS
    b_so_id_d number; b_kq number;
begin
-- Dan - Tra so ID bo sung qua so ID
b_so_id_d:=FBH_HANG_HD_SO_IDd(b_ma_dvi,b_so_id);
select nvl(max(so_id),b_so_id) into b_kq from
    (select so_id,ngay_ht,ttrang from bh_hang where ma_dvi=b_ma_dvi and so_id_d=b_so_id_d) where ngay_ht<=b_ngay_ht and ttrang='D';
return b_kq;
end;
/
create or replace function FBH_HANG_SO_IDc(b_ma_dvi varchar2,b_so_id number,b_ttrang varchar2:='K') return number
as
    b_kq number:=0; b_so_idD number:=b_so_id;
begin    
-- Nam - Tra so id cuoi
b_so_idD:=FBH_HANG_SO_IDd(b_ma_dvi,b_so_id);
if b_ttrang<>'C' then
  select nvl(max(so_id),0) into b_kq from bh_hang where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
else
  select nvl(max(so_id),0) into b_kq from bh_hang where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D';
end if;
return b_kq;
end;
/
create or replace procedure FBH_HANG_SO_ID_HD(
    b_so_hd varchar2,b_ma_dvi out varchar2,b_so_id out number,b_ngay number:=30000101)
as
begin
-- Nam - Tra so id cuoi qua so_hd
select count(*) into b_so_id from bh_hang where so_hd=b_so_hd;
if b_so_id<>1 then
    b_ma_dvi:=''; b_so_id:=0;
else
    select ma_dvi,so_id into b_ma_dvi,b_so_id from bh_hang where so_hd=b_so_hd;
    b_so_id:=FBH_HANG_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
end if;
end;
/
create or replace procedure FBH_HANG_SO_ID_HDd(
    b_so_hd varchar2,b_ma_dvi out varchar2,b_so_id out number,b_ngay number:=30000101)
as
begin
-- Nam - Tra so id dau qua so_hd
select count(*) into b_so_id from bh_hang where so_hd=b_so_hd;
if b_so_id<>1 then
    b_ma_dvi:=''; b_so_id:=0;
else
    select ma_dvi,so_id into b_ma_dvi,b_so_id from bh_hang where so_hd=b_so_hd;
    b_so_id:=FBH_HANG_SO_IDd(b_ma_dvi,b_so_id);
end if;
end;
/
create or replace function FBH_HANG_TTRANG(b_ma_dvi varchar2,b_so_id number,b_dk varchar2:='K',b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(1); b_i1 number;
begin
-- Nam - Tra ngay cap
select nvl(min(ttrang),'X') into b_kq from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_kq<>'X' and b_dk='C' then
    select count(*) into b_i1 from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay;
    if b_i1<>0 then b_kq:='H'; end if;
end if;
return b_kq;
end;
/
create or replace function FBH_HANG_SO_HDd(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50); b_so_idD number;
begin
-- Nam - Tra so hop dong dau
b_so_idD:=FBH_HANG_SO_IDd(b_ma_dvi,b_so_id);
b_kq:=FBH_HANG_SO_HD(b_ma_dvi,b_so_idD);
return b_kq;
end;
/
create or replace procedure PBH_HANG_NOI (
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ten varchar2(1000); b_ma varchar2(20):=b_oraIn;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is not null then b_ten:=FBH_HANG_CANG_TENl(b_ma); end if;
select json_object('b_noi' value b_ten) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_HANG_SO_IDd(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Nam - Tra so id dau
select nvl(min(so_id_d),0) into b_kq from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure FBH_HANG_HD_SO_ID_HD(
    b_so_hd varchar2,b_ma_dvi out varchar2,b_so_id out number,b_so_id_bt out number)
as
begin
-- Nam - Tra so id dau qua GCN
select min(ma_dvi),nvl(min(so_id),0),nvl(min(so_id),0) into b_ma_dvi,b_so_id,b_so_id_bt from bh_hang where so_hd=b_so_hd;
if b_so_id<>0 then b_so_id:=FBH_HANG_SO_IDd(b_ma_dvi,b_so_id); end if;
end;
/
--duchq tim kiem tuong doi cang di
create or replace procedure PBH_HANG_CANG_DI_LISTt(b_ma_dvi varchar2, b_cang_di varchar2)
AS
    b_ngay number:=PKH_NG_CSO(sysdate);
begin
  -- duc -- tim hieu theo nuoc di
insert into temp_1(c1,c2,c3)
  select '1',ma as c2,ten as c3 from bh_hang_cang where nuoc=b_cang_di order by c3;
end;
/
create or replace procedure PBH_HANG_CANG_DI(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_cang_di varchar2(20); cs_lke clob:='';b_dong number;b_tu number;b_den number;
	  b_kieu varchar2(1);b_gtri nvarchar2(500);b_lenh varchar2(1000);
begin
-- Nam
delete temp_1; commit;
b_lenh:=FKH_JS_LENH('kieu,gtri,cang_di');
EXECUTE IMMEDIATE b_lenh into b_kieu,b_gtri,b_cang_di using b_oraIn;
PBH_HANG_CANG_DI_LISTt(b_ma_dvi,b_cang_di);
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
--duchq update tim kiem tuong doi cang den
create or replace procedure PBH_HANG_CANG_DEN_LISTt(b_ma_dvi varchar2, b_cang_den varchar2)
AS
    b_ngay number:=PKH_NG_CSO(sysdate);
begin
  -- duc -- tim hieu theo nuoc den
insert into temp_1(c1,c2,c3)
  select '1',ma as c2,ten as c3 from bh_hang_cang where nuoc=b_cang_den order by c3;
end;
/
create or replace procedure PBH_HANG_CANG_DEN(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_cang_den varchar2(20); cs_lke clob:='';b_dong number;b_tu number;b_den number;
	  b_kieu varchar2(1);b_gtri nvarchar2(500);b_lenh varchar2(1000);
begin
-- Nam
delete temp_1; commit;
b_lenh:=FKH_JS_LENH('kieu,gtri,cang_den');
EXECUTE IMMEDIATE b_lenh into b_kieu,b_gtri,b_cang_den using b_oraIn;
PBH_HANG_CANG_DEN_LISTt(b_ma_dvi,b_cang_den);
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
create or replace procedure PBH_HANG_MA_GD (
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); bil number;  b_ma varchar2(20):=FKH_JS_GTRIs(b_oraIn,'ma');
    cs_ct clob:='';
begin
-- Nam - Tra ttin ma
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ma:=PKH_MA_TENL(b_ma);
select count(*) into bil from bh_ma_gdinh where ma=b_ma;
if bil<>0 then
  select min(ma||'|'||ten) into cs_ct from bh_ma_gdinh where ma=b_ma;
  end if;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_HDBS(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma_dvi varchar2(10); b_so_id number; b_so_idD number;
    b_dong number; cs_lke clob:='';
begin
-- Nam - Liet ke sua doi bo sung
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','HANG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_so_idD:=FBH_HANG_SO_IDd(b_ma_dvi,b_so_id);
if b_so_idD<>0 then
    select count(*) into b_dong from bh_hang where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hd,ttoan,ttrang,ma_dvi,so_id,
           'ma_sdbs' value PKH_TEN_TENl(FBH_HANG_MA_SDBS(so_id))
    ) order by so_id desc returning clob)
        into cs_lke from bh_hang where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10);
    b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number;
    b_dong number; cs_lke clob;
begin
-- Nam - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_hang where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_hang where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd  order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','HANG','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_hang where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and phong=b_phong ;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_hang  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_hd)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_hang where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht ;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_hang  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10); b_so_hd varchar2(20);
    b_so_id number; b_ngay_ht number; b_klk varchar2(1); b_trangKt number; b_tu number; b_den number;
    b_trang number; b_dong number; cs_lke clob;
begin
-- Nam - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_klk,b_trangKt using b_oraIn;
b_so_hd:=FBH_HANG_SO_HD(b_ma_dvi,b_so_id);
if b_so_hd is null then b_loi:='loi:GCN, hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
if b_klk ='N' then
    select count(*) into b_dong from bh_hang where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nsd=b_nsd ;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_hang where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd
             order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_hang  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','HANG','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_hang where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_hang where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong
             order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_hang  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_hd)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_hang where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_hang where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht
             order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_hang  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number; b_so_hd varchar2(20):=FKH_JS_GTRIs(b_oraIn,'so_hd');
begin
-- Nam - Hoi so ID qua so hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FBH_HANG_SO_ID(b_ma_dvi,b_so_hd);
if b_so_id=0 then b_loi:='loi:So hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANGH_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh varchar2,b_loi out varchar2)
AS
    b_i1 number; b_so_idK number; b_so_idD number; b_ttrang varchar2(1); b_ksoat varchar2(20); b_nsdC varchar2(20);
    b_so_hdG varchar2(20); b_kieu_hd varchar2(20);
begin
-- Nam - Xoa
b_loi:='loi:Loi xu ly PBH_HANG_XOA_XOA:loi';
select count(*) into b_i1 from bh_hang where so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select so_id_d,so_id_kt,ttrang,so_hd_g,ksoat,nsd,kieu_hd into b_so_idD,b_so_idK,b_ttrang,b_so_hdG,b_ksoat,b_nsdC,b_kieu_hd
    from bh_hang where so_id=b_so_id;
if b_so_idK>0 then b_loi:='loi:Khong sua, xoa phuc hoi da hach toan ke toan:loi'; return; end if;
if b_nsdC<>b_nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
if trim(b_ksoat) is not null and b_ksoat<>b_nsd then b_loi:='loi:Khong sua, xoa GCN, hop dong da kiem soat:loi'; return; end if;
select count(*) into b_i1 from bh_hang where ma_dvi=b_ma_dvi and so_id_g=b_so_id;
if b_i1<>0 then b_loi:='loi:Khong sua, xoa GCN, hop dong da tao SDBS,hop dong kem:loi'; return; end if;
if b_kieu_hd='K' then
    select nvl(max(so_id),0) into b_i1 from bh_hang where ma_dvi=b_ma_dvi and so_hd_g=b_so_hdG and kieu_hd='K';
    if b_i1<>0 and b_i1<>b_so_id then b_loi:='loi:Khong sua, xoa GCN, hop dong kem cu:loi'; return; end if;
end if;
if b_ttrang in('T','D') then
    PBH_HD_GOC_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi,b_nh);
    if b_loi is not null then return; end if;
end if;
b_loi:='loi:Loi xoa Table bh_hang:loi';
delete bh_hd_goc_ttindt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hang_ttu where ma_dvi=b_ma_dvi and so_id=b_so_idD;
delete bh_hang_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hang_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hang_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hang_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hang_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hang_ptvc where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HANG_XOA(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Nam - Xoa GCN
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_HANGH_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'X',b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_NV(b_ma_dvi varchar2,b_so_id number,
    a_ma_dt out pht_type.a_var,a_nt_tien out pht_type.a_var,a_nt_phi out pht_type.a_var,
    a_lh_nv out pht_type.a_var,a_t_suat out pht_type.a_num,a_pt out pht_type.a_num,a_ptG out pht_type.a_num,
    a_tien out pht_type.a_num,a_phi out pht_type.a_num,a_thue out pht_type.a_num,a_ttoan out pht_type.a_num,
    tt_ngay out pht_type.a_num,tt_ma_nt out pht_type.a_var,tt_tien out pht_type.a_num,b_loi out varchar2)
AS
    b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Dan - Lay so lieu goc
b_loi:='loi:Loi lay so lieu goc:loi';
select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_id;
select ' ',b_nt_tien,b_nt_phi,b.lh_nv,b.t_suat,sum(b.tien),sum(b.phi),sum(b.thue),sum(b.ttoan),min(b.pt),max(b.ptG)
    bulk collect into a_ma_dt,a_nt_tien,a_nt_phi,a_lh_nv,a_t_suat,a_tien,a_phi,a_thue,a_ttoan,a_pt,a_ptG
    from bh_hang_dk b where b.ma_dvi=b_ma_dvi and b.so_id=b_so_id and lh_nv<>' ' group by b.lh_nv,b.t_suat having sum(b.tien)<>0 or sum(b.ttoan)<>0;
select ngay,b_nt_phi,tien bulk collect into tt_ngay,tt_ma_nt,tt_tien from bh_hang_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HANGH_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_ngay number:=PKH_NG_CSO(sysdate); bi1 number;
    b_loi varchar2(100); cs_pt clob; cs_nhang clob; cs_dkgh clob;cs_pptinh clob;
    cs_qtac clob; cs_tpa clob; cs_ttt clob; cs_khd clob; cs_kbt clob; b_ten_dvi varchar2(500);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ten returning clob) into cs_pt from bh_hang_pt;
select JSON_ARRAYAGG(json_object(ma,ten) order by ten returning clob) into cs_nhang from bh_hang_nhom;
select JSON_ARRAYAGG(json_object(ma,ten) order by ten returning clob) into cs_qtac from bh_ma_qtac where FBH_MA_NV_CO(nv,'HANG')='C';
select JSON_ARRAYAGG(json_object(ma,ten returning clob) order by ten returning clob) into cs_dkgh from bh_hang_dkgh;
select JSON_ARRAYAGG(json_object(ma,ten returning clob) order by ma returning clob) into cs_pptinh from bh_hang_pp;
select JSON_ARRAYAGG(json_object(ma,ten returning clob) order by ten returning clob) into cs_tpa from
    bh_ma_gdinh where FBH_MA_GDINH_NV(ma,'HANG')='C' and FBH_MA_GDINH_HAN(ma)='C';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_ttt
    from bh_kh_ttt where ps='HD' and nv='HANG';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_khd from bh_kh_ttt where ps='KHD' and nv='HANG';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_kbt from bh_kh_ttt where ps='KBT' and nv='HANG';
select count(*) into bi1 from ht_ma_dvi where vp='C';
 if bi1<>0 then
    select ten into b_ten_dvi from ht_ma_dvi where vp='C';
end if;
select json_object('cs_pt' value cs_pt,'cs_nhang' value cs_nhang,'cs_dkgh' value cs_dkgh,
       'cs_pptinh' value cs_pptinh,'cs_qtac' value cs_qtac,'cs_tpa' value cs_tpa,
       'cs_ttt' value cs_ttt,'cs_khd' value cs_khd,'cs_kbt' value cs_kbt,'cs_ten_dvi' value b_ten_dvi returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_HANG_PHIb(b_tp number,
    dk_ma pht_type.a_var,dk_ma_ct pht_type.a_var,dk_lkeP pht_type.a_var,dk_cap pht_type.a_num,
    dk_phi in out pht_type.a_num,dk_thue in out pht_type.a_num,dk_ttoan out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_cap number:=1; b_phi number; b_thue number;
begin
-- Nam - Tinh bac cao
b_loi:='loi:Loi xu ly FBH_HANG_PHIb:loi';
for b_lp in 1..dk_ma.count loop
  b_phi:=0; b_thue:=0;
  b_phi:=dk_phi(b_lp); b_thue:=dk_thue(b_lp);
  dk_phi(b_lp):=b_phi; dk_thue(b_lp):=b_thue; dk_ttoan(b_lp):=b_phi+b_thue;    
end loop;
for b_lp in 1..dk_ma.count loop
    dk_ttoan(b_lp):=dk_phi(b_lp)+dk_thue(b_lp);
end loop;
b_loi:='';
end;
/
create or replace procedure FBH_HANG_PHI(
    dt_ct clob,dt_dk clob,dt_ds clob,b_so_idP out number,
    a_ma out pht_type.a_var,a_ma_hang out pht_type.a_var,a_ten out pht_type.a_nvar,a_tc out pht_type.a_var,
    a_ma_ct out pht_type.a_var,a_kieu out pht_type.a_var,
    a_lkeP out pht_type.a_var,a_lkeB out pht_type.a_var,a_luy out pht_type.a_var,
    a_ma_dk out pht_type.a_var,a_ma_dkC out pht_type.a_var,a_lh_nv out pht_type.a_var,a_t_suat out pht_type.a_num,
    a_cap out pht_type.a_num,a_lh_bh out pht_type.a_var,
    a_tien out pht_type.a_num,a_pt out pht_type.a_num,a_phi out pht_type.a_num,
    a_thue out pht_type.a_num,a_ttoan out pht_type.a_num,
    a_ptB out pht_type.a_num,a_ptG out pht_type.a_num,a_phiG out pht_type.a_num,a_ptK out pht_type.a_var,a_pp out pht_type.a_var,
    a_phiB out pht_type.a_num,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_kt number:=0; b_ktL number:=0;
    b_ma_qtac varchar2(500); b_ma_nhang varchar2(500); b_ma_vchuyen varchar2(500); b_kieu_hd varchar2(1);
    b_khoang_cach number; b_thoi_gian number; b_c_thue varchar2(1); b_tien number;
    b_tp number:=0; b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tygia number:=1; dt_txt clob:= ' ';

    ds_ma pht_type.a_var; ds_ma_hang pht_type.a_var; ds_ten pht_type.a_nvar; ds_dgoi pht_type.a_var; ds_cphi pht_type.a_num; 
    ds_gia_tri pht_type.a_num; ds_mtn pht_type.a_num; ds_pp pht_type.a_var; ds_pt pht_type.a_num; ds_ptB pht_type.a_num; ds_t_suat pht_type.a_num; 
    ds_lkeP pht_type.a_var; ds_lkeB pht_type.a_var; ds_ma_dk pht_type.a_var; ds_lh_nv pht_type.a_var;
    ds_ptK pht_type.a_var; ds_luy pht_type.a_var;
    
    ds_gia_tri_qd pht_type.a_num; ds_mtn_qd pht_type.a_num; a_tien_qd pht_type.a_num;
    
    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_ptB pht_type.a_num; dk_pp pht_type.a_var; 
    dk_pt pht_type.a_num; dk_tc pht_type.a_var; 
    dk_ma_ct pht_type.a_var; dk_kieu pht_type.a_var; dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var; dk_luy pht_type.a_var;
    dk_ma_dk pht_type.a_var; dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num; dk_cap pht_type.a_num; dk_lh_bh pht_type.a_var;
    
begin
-- Dan - Tinh phi
b_loi:='loi:Loi xu ly FBH_HANG_PHI:loi';
b_lenh:=FKH_JS_LENH('ma_qtac,ma_nhang,vchuyen,nt_tien,nt_phi,tygia,c_thue,kieu_hd');
EXECUTE IMMEDIATE b_lenh into b_ma_qtac,b_ma_nhang,b_ma_vchuyen,b_nt_tien,b_nt_phi,b_tygia,b_c_thue,b_kieu_hd using dt_ct;
b_ma_qtac:= PKH_MA_TENl(b_ma_qtac); b_ma_nhang:= PKH_MA_TENl(b_ma_nhang); b_ma_vchuyen:= PKH_MA_TENl(b_ma_vchuyen);
b_khoang_cach:=0; b_thoi_gian:=0;
if b_tygia is null or b_tygia=0 then b_tygia:=1; end if;
if b_nt_phi<>'VND' then b_tp:=2; end if;
b_so_idP:=FBH_HANG_BPHI_SO_IDd(b_ma_vchuyen,b_ma_nhang,b_ma_qtac,b_khoang_cach,b_thoi_gian);
if b_so_idP=0 then b_loi:='loi:Khong tim duoc bieu phi:loi'; return; end if;
b_lenh:=FKH_JS_LENH('ma,ma_hang,ten,dgoi,cphi,gia_tri,mtn,pp,pt,ptb,t_suat,lkep,lkeb,ma_dk,lh_nv,ptk,luy');
EXECUTE IMMEDIATE b_lenh bulk collect into ds_ma,ds_ma_hang,ds_ten,ds_dgoi,ds_cphi,ds_gia_tri,ds_mtn,
        ds_pp,ds_pt,ds_ptB,ds_t_suat,ds_lkeP,ds_lkeB,ds_ma_dk,ds_lh_nv,ds_ptK,ds_luy using dt_ds;
if ds_ma_hang.count=0 and b_kieu_hd <> 'U' then b_loi:='loi:Nhap danh sach hang hoa bao hiem:loi'; return; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,ptb,pp,pt,kieu,lkep,lkeb,luy,ma_dk,lh_nv,t_suat,cap,lh_bh');
EXECUTE IMMEDIATE b_lenh bulk collect into dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_ptB,dk_pp,dk_pt,dk_kieu,dk_lkeP,dk_lkeB,dk_luy,
        dk_ma_dk,dk_lh_nv,dk_t_suat,dk_cap,dk_lh_bh using dt_dk;
if b_nt_tien<>'VND' and b_nt_phi='VND' then
  for b_lp in 1..ds_ma_hang.count loop
    ds_mtn_qd(b_lp):=round(ds_mtn(b_lp)*b_tygia,0);
    ds_gia_tri_qd(b_lp):=round(ds_gia_tri(b_lp)*b_tygia,0);
  end loop;
elsif b_nt_tien='VND' and b_nt_phi<>'VND' then
  for b_lp in 1..ds_ma_hang.count loop
    ds_mtn_qd(b_lp):=round(ds_mtn(b_lp)/b_tygia,b_tp);
    ds_gia_tri_qd(b_lp):=round(ds_gia_tri(b_lp)/b_tygia,b_tp);
  end loop;
else
  for b_lp in 1..ds_ma_hang.count loop
    ds_mtn_qd(b_lp):=ds_mtn(b_lp);
    ds_gia_tri_qd(b_lp):=ds_gia_tri(b_lp);
  end loop;
end if;
b_kt:=0;
for b_lp_ds in 1..ds_ma_hang.count loop
    ds_dgoi(b_lp_ds):= PKH_MA_TENl(ds_dgoi(b_lp_ds));
    FBH_HANG_BPHI_DSp(b_so_idP,ds_ma_hang(b_lp_ds),ds_dgoi(b_lp_ds),dt_txt,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    b_kt:=b_kt+1; b_ktL:=b_kt;
    a_ma(b_kt):=ds_ma(1); a_ma_hang(b_kt):=ds_ma_hang(b_lp_ds); a_ten(b_kt):='- '||ds_ten(b_lp_ds); 
    a_tien(b_kt):= ds_mtn(b_lp_ds); a_tien_qd(b_kt):= ds_mtn_qd(b_lp_ds);
    a_ptB(b_kt):=ds_ptB(b_lp_ds); a_pt(b_kt):=ds_pt(b_lp_ds); a_ptK(b_kt):=ds_ptK(b_lp_ds); a_pp(b_kt):=nvl(ds_pp(b_lp_ds),'GP');
    a_lkeP(b_kt):=ds_lkeP(1); a_lkeB(b_kt):=ds_lkeB(1); b_tien:=a_tien_qd(b_kt);
    if a_lkeP(b_kt) not in ('G','T','N') then a_lkeP(b_kt):='K'; else a_lkeP(b_kt):=a_lkeP(b_kt); end if;
    if a_lkeP(b_kt)='K' then
       a_pt(b_kt):=0; a_ptB(b_kt):=0; a_phi(b_kt):=0; a_phiB(b_kt):=0;
    else 
      if a_ptK(b_kt)<>'P' then a_phiB(b_kt):=a_ptB(b_kt);
      else a_phiB(b_kt) :=ROUND(a_ptB(b_kt)*b_tien/100, b_tp);
      end if;
      if a_pp(b_kt) = 'DG' and b_tien<>0 then a_pt(b_kt):=ROUND(a_pt(b_kt)*100/b_tien,20);
        elsif a_pp(b_kt) = 'DP' then a_pt(b_kt):=a_pt(b_kt);
        elsif a_pp(b_kt) = 'GG' and b_tien<>0 then a_pt(b_kt):=a_ptB(b_kt) - ROUND((a_pt(b_kt)/b_tien*100),20);
        elsif a_pp(b_kt) = 'GT' then a_pt(b_kt):= a_ptB(b_kt) - a_pt(b_kt);
        elsif a_pp(b_kt) = 'GP' then a_pt(b_kt):=a_ptB(b_kt) - ROUND(a_pt(b_kt)*a_ptB(b_kt)/100,20);
      else a_pt(b_kt):=a_ptB(b_kt);
      end if;    
    end if;
    if b_tien<>0 and a_pt(b_kt)<>0 then a_phi(b_kt):=ROUND(b_tien*a_pt(b_kt)/ 100, b_tp);
    else a_phi(b_kt):=0;
    end if;
    if a_phiB(b_kt)=0 then a_phiB(b_kt):=a_phi(b_kt); end if;
    if a_phi(b_kt)<0 then a_phi(b_kt):=0; end if;
    a_ma_dk(b_kt):=ds_ma_dk(1); a_ma_dkC(b_kt):=' '; a_lh_bh(b_kt):='C'; a_tc(b_kt):='C';
    a_t_suat(b_kt):=ds_t_suat(1); a_cap(b_kt):=1; a_ma_ct(b_kt):=' ';
    a_kieu(b_kt):='T'; a_luy(b_kt):=ds_luy(b_lp_ds); a_lh_nv(b_kt):=ds_lh_nv(1);  a_ptG(b_kt):=0; a_phiG(b_kt):=0;
        for b_lp_dk in 1..dk_ma.count loop
          b_kt:=b_kt+1;
          a_ma(b_kt):=dk_ma(b_lp_dk);a_ma_hang(b_kt):=a_ma_hang(b_ktL)||'>'||dk_ma(b_lp_dk); a_kieu(b_kt):='T';
          a_ten(b_kt):='-- '||dk_ten(b_lp_dk); a_tc(b_kt):='C'; a_ma_ct(b_kt):=a_ma(b_lp_ds);
          a_lkeP(b_kt):=a_lkeP(b_ktL); a_lkeB(b_kt):=a_lkeB(b_ktL); a_luy(b_kt):=a_luy(b_ktL);
          a_tien(b_kt):=0; a_tien_qd(b_kt):= ds_gia_tri_qd(b_lp_ds); a_ma_dk(b_kt):=dk_ma_dk(b_lp_dk); a_ma_dkC(b_kt):=dk_ma_dk(b_lp_dk); a_lh_nv(b_kt):=a_lh_nv(b_lp_ds);
          a_t_suat(b_kt):=a_t_suat(b_lp_ds); a_cap(b_kt):=1; a_lh_bh(b_kt):='M';
          a_pp(b_kt):= nvl(dk_pp(b_lp_dk),'GP');
          a_pt(b_kt):=dk_pt(b_lp_dk); a_ptB(b_kt):=dk_ptB(b_lp_dk);
          b_tien:=a_tien_qd(b_kt);
          if a_pp(b_kt) = 'DG' and b_tien<>0 then a_pt(b_kt):=ROUND(a_pt(b_kt)*100/b_tien,20);
            elsif a_pp(b_kt) = 'DP' then a_pt(b_kt):=a_pt(b_kt);
            elsif a_pp(b_kt) = 'GG' and b_tien<>0 then a_pt(b_kt):=a_ptB(b_kt) - ROUND((a_pt(b_kt)/b_tien*100),20);
            elsif a_pp(b_kt) = 'GT' then a_pt(b_kt):= a_ptB(b_kt) - a_pt(b_kt);
            elsif a_pp(b_kt) = 'GP' then a_pt(b_kt):=a_ptB(b_kt) - ROUND(a_pt(b_kt)*a_ptB(b_kt)/100,20);
          else a_pt(b_kt):=a_ptB(b_kt);
          end if; 
          a_phi(b_kt):= round(b_tien*a_pt(b_kt)/100,b_tp);
          a_phiB(b_kt):= round(b_tien*a_ptB(b_kt)/100,b_tp);
          a_ptK(b_kt):=a_ptK(b_lp_ds);
          a_ptG(b_kt):=0; a_phiG(b_kt):=0;
          if a_phiB(b_kt)=0 then a_phiB(b_kt):=a_phi(b_kt); end if;
          if a_phi(b_kt)<0 then a_phi(b_kt):=0; end if;
        end loop;
end loop;
if b_c_thue<>'C' then
    for b_lp in 1..a_ma.count loop a_thue(b_lp):=0; end loop;
else
    for b_lp in 1..a_ma.count loop a_thue(b_lp):=round(a_phi(b_lp)*a_t_suat(b_lp)/100,b_tp); end loop;
end if;
FBH_HANG_PHIb(b_tp,a_ma,a_ma_ct,a_lkeP,a_cap,a_phi,a_thue,a_ttoan,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HANG_PHI(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(3000); b_lenh varchar2(2000); b_txt clob;
    dt_ct clob; dt_dk clob; dt_ds clob;
    b_so_idP number;
    a_ma pht_type.a_var;a_ma_hang pht_type.a_var; a_ten pht_type.a_nvar; a_tc pht_type.a_var;
    a_ma_ct pht_type.a_var; a_kieu pht_type.a_var;
    a_lkeP pht_type.a_var; a_lkeB pht_type.a_var; a_luy pht_type.a_var;
    a_ma_dk pht_type.a_var; a_ma_dkC pht_type.a_var; a_lh_nv pht_type.a_var; a_t_suat pht_type.a_num;
    a_cap pht_type.a_num; a_lh_bh pht_type.a_var;
    a_tien pht_type.a_num; a_pt pht_type.a_num; a_phi pht_type.a_num;
    a_thue pht_type.a_num; a_ttoan pht_type.a_num;
    a_ptB pht_type.a_num; a_ptG pht_type.a_num; a_phiG pht_type.a_num;a_ptK pht_type.a_var;a_pp pht_type.a_var;
    a_phiB pht_type.a_num;
begin
-- Dan - Tinh phi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_ds');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_ds using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_ds); 
FBH_HANG_PHI(dt_ct,dt_dk,dt_ds,b_so_idP,
    a_ma,a_ma_hang,a_ten,a_tc,a_ma_ct,a_kieu,a_lkeP,a_lkeB,a_luy,a_ma_dk,a_ma_dkC,
    a_lh_nv,a_t_suat,a_cap,a_lh_bh,a_tien,a_pt,a_phi,a_thue,a_ttoan,a_ptB,a_ptG,a_phiG,a_ptK,a_pp,a_phiB,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_oraOut:='[';
for b_lp in 1..a_ma.count loop
   select json_object('ma' value a_ma(b_lp),'ten' value a_ten(b_lp),'tc' value a_tc(b_lp),
    'ma_ct' value a_ma_ct(b_lp),'kieu' value a_kieu(b_lp),'lkeP' value a_lkeP(b_lp),'lkeB' value a_lkeB(b_lp),
    'luy' value a_luy(b_lp),'ma_dk' value a_ma_dk(b_lp),'ma_dkC' value a_ma_dkC(b_lp),
    'lh_nv' value a_lh_nv(b_lp),'t_suat' value a_t_suat(b_lp),'cap' value a_cap(b_lp),'lh_bh' value a_lh_bh(b_lp),
    'tien' value a_tien(b_lp),'pt' value a_pt(b_lp),
    'phi' value a_phi(b_lp),'thue' value a_thue(b_lp),'ttoan' value a_ttoan(b_lp),
    'ptB' value a_ptB(b_lp),'ptG' value a_ptG(b_lp),'phiG' value a_phiG(b_lp),'ptK' value a_ptK(b_lp),
    'pp' value a_pp(b_lp),'phiB' value a_phiB(b_lp) returning clob) into b_txt from dual;
    if b_lp>1 then b_oraOut:=b_oraOut||','; end if;
    b_oraOut:=b_oraOut||b_txt;
end loop;
b_oraOut:=b_oraOut||']';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANGH_SOHD(
    b_ma_dvi varchar2,dt_ct clob,b_so_hd out varchar2,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_ttrang varchar2(1); b_so_hd_g varchar2(20); b_so_hdL varchar2(1); b_ngay_ht number;
    b_i1 number; b_i2 number; b_ttrangC varchar2(1); b_hd_kem varchar2(1); b_so_idG number; b_so_idD number;
begin
-- Nam - Sinh so hop dong kem
b_loi:='loi:Loi xu ly PBH_HANG_SOHD:loi';
b_lenh:=FKH_JS_LENH('so_hdL,ttrang,so_hd_g,ngay_ht');
EXECUTE IMMEDIATE b_lenh into b_so_hdL,b_ttrang,b_so_hd_g,b_ngay_ht using dt_ct;
select nvl(hd_kem,' '),so_id,so_id_d,ngay_ht into b_hd_kem,b_so_idG,b_so_idD,b_i1 from bh_hang where ma_dvi=b_ma_dvi and so_hd=b_so_hd_g;
if b_hd_kem<>'C' then b_loi:='loi:Khong tao hop dong kem tu hop dong goc mot chuyen:loi';return; end if;
if b_i1>b_ngay_ht then b_loi:='loi:Ngay nhap hop dong kem phai sau ngay goc:loi'; return; end if;
select nvl(max(so_id),0) into b_i1 from bh_hang where ma_dvi=b_ma_dvi and so_id_g=b_so_idG and kieu_hd='K';
if b_i1=0 then
  select nvl(min(so_id),0) into b_i1 from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_idG;
end if;
select ttrang into b_ttrangC from bh_hang where ma_dvi=b_ma_dvi and so_id=b_i1;
if b_ttrangC<>'D' then b_loi:='loi:So hop dong/GCN kem gan nhat chua duyet:loi'; return; end if;
if b_i1<>0 then
  select so_hd into b_so_hd from bh_hang where ma_dvi=b_ma_dvi and so_id=b_i1;
  b_i1:=instr(b_so_hd,'.');
  if b_i1<>0 then
      b_i2:=b_i1-1;
      b_i1:=PKH_LOC_CHU_SO(substr(b_so_hd,b_i1),'F','F');
      b_so_hd:=substr(b_so_hd,1,b_i2);
  end if;
end if;
b_so_hd:=b_so_hd||'.'||'K'||to_char(b_i1+1);      
if b_ttrang<>'D' then b_so_hd:=b_ttrang||'.'||b_so_hd; end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HANGH_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number;
    b_ma_noi_di nvarchar2(500);b_ma_noi_den nvarchar2(500);
    dt_ct clob; dt_ds clob; dt_dk clob; dt_lt clob; dt_kbt clob; dt_pt clob; dt_kytt clob; dt_ttt clob; dt_vch clob; dt_txt clob;
    dt_hk clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','HANG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
if b_so_id=0 then b_loi:='loi:GCN/Hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
select json_object('ma_qtac' value FBH_HANG_QTAC_MA(qtac),'ma_nhang' value FBH_HANG_NHANG_MA(nhang),
    'vchuyen' value FBH_HANG_PT_MA(vchuyen),'cang_di' value FBH_MA_NUOC_TENl(cang_di),'cang_den' value FBH_MA_NUOC_TENl(cang_den)
     returning clob) into dt_ct from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_id;
select count(*) into b_i1 from bh_hang_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
if b_i1=1 then
    select txt into dt_hk from bh_hang_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
end if;
select count(*) into b_i1 from bh_hang_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
if b_i1=1 then
    select txt into dt_ds from bh_hang_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
end if;
select count(*) into b_i1 from bh_hang_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dk';
if b_i1=1 then
    select txt into dt_dk from bh_hang_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dk';
end if;
select count(*) into b_i1 from bh_hang_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_pt';
if b_i1=1 then
    select txt into dt_pt from bh_hang_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_pt';
end if;
select count(*) into b_i1 from bh_hang_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_lt';
if b_i1=1 then
    select txt into dt_lt from bh_hang_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_lt';
end if;
select count(*) into b_i1 from bh_hang_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_kbt';
if b_i1=1 then
    select txt into dt_kbt from bh_hang_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_kbt';
end if;
select count(*) into b_i1 from bh_hang_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
if b_i1<>0 then
    select txt into dt_ttt from bh_hang_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
end if;
select count(*) into b_i1 from bh_hang_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_vch';
if b_i1<>0 then
    select txt into dt_vch from bh_hang_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_vch';
end if;
select JSON_ARRAYAGG(json_object(ngay,tien) order by ngay) into dt_kytt from bh_hang_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
	from bh_hang_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai in('dt_ct','dt_lt');
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'dt_ct' value dt_ct,'dt_hk' value dt_hk,
    'dt_ds' value dt_ds,'dt_dk' value dt_dk,'dt_lt' value dt_lt,'dt_kbt' value dt_kbt,'dt_pt' value dt_pt,
    'dt_kytt' value dt_kytt,'dt_ttt' value dt_ttt,'dt_vch' value dt_vch,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANGH_TESTr(
    b_ma_dvi varchar2,b_nsd varchar2,
    dt_ct clob,dt_ds clob,dt_dk clob,dt_pt clob,
    b_so_idP out number,b_so_idG number, b_so_idD number, b_so_hd in out varchar2,
    b_ma_qtac out varchar2,b_ma_nhang out varchar2,b_hd_kem out varchar2,b_c_ctai out varchar2,b_ma_vchuyen out varchar2,
    b_ngay_hl number, b_ngay_kt in out number, b_ngay_cap number,
    b_khoang_cach out number,b_thoi_gian out number,b_gdinh out varchar2,b_cang_di out varchar2, b_cang_den out varchar2,
    b_noi_di out varchar2,b_noi_den out varchar2,b_ma_dkgh out varchar2, b_ma_pptinh out varchar2,
    b_tong_mtnH out number,b_tpH out number,b_pphiH out number,

    b_cmtH out varchar2, b_mobiH out varchar2, b_emailH out varchar2,
    b_loai_khH out varchar2, b_tenH out nvarchar2, b_dchiH out nvarchar2,b_ch in out varchar2,
    -- thong tin thanh toan
    tt_ngay pht_type.a_num,tt_tien pht_type.a_num,
    -- thong tin hang hoa
    ds_ma_lhang out pht_type.a_var,ds_ten_hang out pht_type.a_var,ds_dvi_tinh out pht_type.a_var,
    ds_ma_dgoi out pht_type.a_var,ds_cphi out pht_type.a_num,ds_sluong out pht_type.a_num,
    ds_gia out pht_type.a_num,ds_gia_tri out pht_type.a_num,ds_mtn out pht_type.a_num,ds_pt out pht_type.a_num,
    ds_lh_nv out pht_type.a_var,ds_lkeB out pht_type.a_var,
    -- thong tin phuong tien
    ds_ma_ptien out pht_type.a_var, ds_ten_ptien out pht_type.a_var, ds_so_imo out pht_type.a_var, ds_so_vdon out pht_type.a_var,
    -- dieu khoan bao hiem
    dk_ma out pht_type.a_var,dk_ma_hang out pht_type.a_var,dk_ten out pht_type.a_nvar,
    dk_tc out pht_type.a_var,dk_ma_ct out pht_type.a_var,dk_kieu out pht_type.a_var,
    dk_tien out pht_type.a_num,dk_pt out pht_type.a_num,dk_phi out pht_type.a_num,
    dk_thue out pht_type.a_num,dk_ttoan out pht_type.a_num,
    dk_cap out pht_type.a_num,dk_ma_dk out pht_type.a_var,dk_ma_dkC out pht_type.a_var,
    dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,
    dk_ptB out pht_type.a_num,dk_ptG out pht_type.a_num,dk_phiG out pht_type.a_num,
    dk_lkeP out pht_type.a_var,dk_lkeB out pht_type.a_var,dk_luy out pht_type.a_var,dk_lh_bh out pht_type.a_var,
    dk_ptK out pht_type.a_var,dk_pp out pht_type.a_var,dk_phiB out pht_type.a_num,
    b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_i2 number; b_txt clob; b_kieu_hd varchar2(1); b_ttrang varchar2(1);
    b_ma_khH varchar2(20); b_c_thueH varchar2(1); b_nt_tienH varchar2(5);b_nt_phiH varchar2(5);
    b_thueH number; b_ttoanH number;b_tygia number;
    dt_khd clob;
begin
-- Nam - Nhap
b_lenh:=FKH_JS_LENH('kieu_hd,ttrang,ma_qtac,ma_nhang,vchuyen,khoang_cach,thoi_gian,cang_di,cang_den,
    noi_di,noi_den,ma_pptinh,hd_kem,gdinh,ma_dkgh,c_ctai,loai_khd,cmtd,mobid,emaild,tend,dchid,c_thue,nt_tien,nt_phi,tp,tong_mtnh,pphi,thue,ttoan,tygia');
EXECUTE IMMEDIATE b_lenh into b_kieu_hd,b_ttrang,b_ma_qtac,b_ma_nhang,b_ma_vchuyen,b_khoang_cach,b_thoi_gian,
    b_cang_di,b_cang_den,b_noi_di,b_noi_den,b_ma_pptinh,b_hd_kem,b_gdinh,b_ma_dkgh,b_c_ctai,b_loai_khH,b_cmtH,b_mobiH,b_emailH,b_tenH,b_dchiH,
    b_c_thueH,b_nt_tienH,b_nt_phiH,b_tpH,b_tong_mtnH,b_pphiH,b_thueH,b_ttoanH,b_tygia using dt_ct;
b_cang_di:=PKH_MA_TENl(b_cang_di); b_cang_den:=PKH_MA_TENl(b_cang_den);
b_ma_qtac:=PKH_MA_TENl(b_ma_qtac); b_ma_nhang:=PKH_MA_TENl(b_ma_nhang);
b_gdinh:=PKH_MA_TENl(b_gdinh); b_ma_vchuyen:=PKH_MA_TENl(b_ma_vchuyen);
b_ma_dkgh:=PKH_MA_TENl(b_ma_dkgh); b_ma_pptinh:=PKH_MA_TENl(b_ma_pptinh);
b_thoi_gian:=nvl(b_thoi_gian,0); b_khoang_cach:=nvl(b_khoang_cach,0);
b_ngay_kt:=PKH_NG_CSO(PKH_SO_CDT(b_ngay_hl) + b_thoi_gian);
if nvl(trim(b_nt_phiH),'VND')<>'VND' then b_tpH:=2; end if;
b_lenh:=FKH_JS_LENH('ma_pt,ten_pt,so_imo,so_vdon');
EXECUTE IMMEDIATE b_lenh bulk collect into ds_ma_ptien,ds_ten_ptien,ds_so_imo,ds_so_vdon using dt_pt;
if ds_ma_ptien.count = 0 then b_loi:='loi:Nhap thong tin phuong tien cho hang hoa:loi'; return; end if;
for b_lp in 1..ds_ma_ptien.count loop
    ds_ma_ptien(b_lp):=PKH_MA_TENl(ds_ma_ptien(b_lp));
end loop;
b_lenh:=FKH_JS_LENH('ma_hang,ten,dvi_tinh,dgoi,cphi,sluong,gia,gia_tri,mtn,pt,lkeB,lh_nv');
EXECUTE IMMEDIATE b_lenh bulk collect into ds_ma_lhang,ds_ten_hang,ds_dvi_tinh,
        ds_ma_dgoi,ds_cphi,ds_sluong,ds_gia,ds_gia_tri,ds_mtn,ds_pt,ds_lkeB,ds_lh_nv using dt_ds;
if ds_ma_lhang.count=0 then b_loi:='loi:Nhap danh sach hang hoa bao hiem:loi'; return; end if;
for b_lp in 1..ds_ma_lhang.count loop
    if trim(ds_ten_hang(b_lp)) is null then b_loi:='loi:ten hang bao hiem dong '||to_char(b_lp)||':loi'; return; end if;
    b_loi:='loi:Sai ma loai hang '||ds_ten_hang(b_lp)||':loi';
    if ds_ma_lhang(b_lp) is null then return; end if;
    ds_ma_lhang(b_lp):=PKH_MA_TENl(ds_ma_lhang(b_lp));
    if FBH_HANG_LHANG_HAN(ds_ma_lhang(b_lp))<>'C' then return; end if;
    b_loi:='loi:Them gia tri hang '||ds_ten_hang(b_lp)||':loi';
    if ds_gia_tri(b_lp) is null or ds_gia_tri(b_lp) <=0 then return; end if;
    for r_lp in (select * from bh_hang_loai where ma=ds_ma_lhang(b_lp)) loop
        if r_lp.ten<>trim(ds_ten_hang(b_lp)) then b_ch:='C'; end if;
    end loop;
end loop;
if b_kieu_hd='K' then
    PBH_HANGH_SOHD(b_ma_dvi,dt_ct,b_so_hd,b_loi);
    if b_loi is not null then return; end if;
end if;
FBH_HANG_PHI(dt_ct,dt_dk,dt_ds,b_so_idP,
    dk_ma,dk_ma_hang,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_lkeP,dk_lkeB,dk_luy,dk_ma_dk,dk_ma_dkC,
    dk_lh_nv,dk_t_suat,dk_cap,dk_lh_bh,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,dk_ptB,dk_ptG,dk_phiG,dk_ptK,dk_pp,dk_phiB,b_loi);
if b_loi is not null then return; end if;
PBH_HD_THAY_PHIg(b_nt_tienH,b_nt_phiH,b_tygia,b_thueH,b_ttoanH,dk_lh_nv,dk_tien,dk_phi,dk_thue,dk_ttoan,b_loi);
if b_loi is not null then return; end if;
if b_hd_kem <> 'C' then
  for b_lp in 1..dk_ma.count loop
      if dk_phiB(b_lp)>dk_phi(b_lp) and dk_tien(b_lp) > 0 and dk_lh_nv(b_lp)<> ' ' then
          dk_phiG(b_lp):=dk_phiB(b_lp)-dk_phi(b_lp);
          dk_ptG(b_lp):=round(dk_phiG(b_lp)*100/dk_phiB(b_lp),10);
      else
          dk_ptG(b_lp):=0; dk_phiG(b_lp):=0;
      end if;
  end loop;
end if;
for b_lp in 1..tt_ngay.count loop
    if tt_ngay(b_lp) is null or tt_tien(b_lp) is null then
        b_loi:='loi:Loi ky thanh toan dong '||to_char(b_lp)||':loi'; return;
    end if;
    if b_kieu_hd in ('G','T') and (tt_ngay(b_lp)>b_ngay_kt or tt_ngay(b_lp)<b_ngay_cap) then
      b_loi:='loi:Ky thanh toan phai truoc ngay het han hieu luc hoac tu ngay cap don dong '||to_char(b_lp)||':loi'; return;
    elsif b_kieu_hd not in ('G','T') and tt_ngay(b_lp)>b_ngay_kt then
      b_loi:='loi:Ky thanh toan phai truoc ngay het han hieu luc don dong '||to_char(b_lp)||':loi'; return;
    end if;
end loop;
for b_lp in 1..tt_ngay.count loop
    b_i1:=b_lp+1;
    if b_i1<=tt_ngay.count then
        for b_lp1 in b_i1..tt_ngay.count loop
            if tt_ngay(b_lp)=tt_ngay(b_lp1) then
                b_loi:='loi:Trung ky thanh toan '||PKH_SO_CNG(tt_ngay(b_lp))||':loi'; return;
            end if;
        end loop;
    end if;
end loop;
if b_ttrang in ('T','D') then
    b_lenh:=FKH_JS_LENH('ma_khd,loai_khd,tend,dchid,cmtd,mobid,emaild');
    EXECUTE IMMEDIATE b_lenh into b_ma_khH,b_loai_khH,b_tenH,b_dchiH,b_cmtH,b_mobiH,b_emailH using dt_ct;
    if trim(b_tenH) is not null then
        select json_object('loai' value b_loai_khH,'ten' value b_tenH,'cmt' value b_cmtH,
            'dchi' value b_dchiH,'mobi' value b_mobiH,'email' value b_emailH) into b_txt from dual;
        PBH_DTAC_MA_NH(b_txt,b_ma_khH,b_loi,b_ma_dvi,b_nsd);
    end if;
    select count(*) into b_i1 from bh_hang_phi_txt where so_id=b_so_idP and loai='dt_khd';
    if b_i1<>0 then
        select txt into dt_khd from bh_hang_phi_txt where so_id=b_so_idP and loai='dt_khd';
        dt_khd:=FKH_JS_BONH(b_txt);
        PBH_HANGH_KHD(dt_ct,dt_dk,dt_khd,b_loi);
        if b_loi is not null then return; end if;
    end if;
    b_i1:=FKH_ARR_MINn(tt_ngay); b_i2:=FKH_KHO_NGSO(b_ngay_hl,b_i1);
    if b_i2>30 and b_kieu_hd<>'B' then b_loi:='loi:Thoi han thanh toan vuot qua 30 ngay:loi'; return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HANGH_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    dt_ct in out clob,dt_hk clob,dt_ds clob,dt_dk clob,dt_lt clob,dt_kbt clob,dt_pt clob,dt_ttt clob, dt_vch clob,
-- Chung
    b_so_hd varchar2, b_ngay_ht number, b_ttrang varchar2,
    b_kieu_hd varchar2, b_so_hd_g varchar2, b_so_idG number, b_so_idD number,
    b_kieu_kt varchar2, b_ma_kt varchar2, b_kieu_gt varchar2, b_ma_gt varchar2, b_ma_cb varchar2,
    b_phong varchar2, b_so_hdl varchar2, b_loai_kh varchar2, b_ma_kh varchar2, b_ten nvarchar2, b_dchi nvarchar2,
    b_cmt varchar2, b_mobi varchar2, b_email varchar2, b_gio_hl varchar2, b_ngay_hl number, b_gio_kt varchar2,
    b_ngay_kt number, b_ma_qtac varchar2, b_ma_nhang varchar2, b_hd_kem varchar2, b_c_ctai varchar2,
    b_ma_vchuyen varchar2, b_khoang_cach number, b_thoi_gian number, b_cang_di varchar2,
    b_cang_den varchar2, b_ngay_cap number,b_c_thue varchar2, b_tong_mtn number,b_phi number,b_giam number, b_thue number,
    b_ttoan number, b_nt_tien varchar2, b_nt_phi varchar2, b_hhong number,
    tt_ngay pht_type.a_num,tt_tien pht_type.a_num,
-- Rieng
    ---- Danh sach hang
    ds_ma_lhang pht_type.a_var,ds_ten_hang pht_type.a_var,ds_dvi_tinh pht_type.a_var,ds_ma_dgoi pht_type.a_var,ds_cphi pht_type.a_num,
    ds_sluong pht_type.a_num,ds_gia pht_type.a_num,ds_gia_tri pht_type.a_num,ds_mtn pht_type.a_num,ds_pt pht_type.a_num,
    ds_lh_nv pht_type.a_var,ds_lkeB pht_type.a_var,
    ---- Phuong tien
    ds_ma_ptien pht_type.a_var, ds_ten_ptien pht_type.a_var, ds_so_imo pht_type.a_var, ds_so_vdon pht_type.a_var,
    ---- Dieu khoan
    dk_ma pht_type.a_var,dk_ma_hang pht_type.a_var,dk_ten pht_type.a_nvar,dk_tc pht_type.a_var,
    dk_ma_ct pht_type.a_var,dk_kieu pht_type.a_var,dk_tien pht_type.a_num,dk_pt pht_type.a_num,
    dk_phi pht_type.a_num,dk_thue pht_type.a_num,dk_ttoan pht_type.a_num,dk_cap pht_type.a_num,
    dk_ma_dk pht_type.a_var,dk_ma_dkC pht_type.a_var,dk_lh_nv pht_type.a_var,dk_t_suat pht_type.a_num,
    dk_ptB pht_type.a_num,dk_ptG pht_type.a_num,dk_phiG pht_type.a_num,dk_lkeP pht_type.a_var,
    dk_lkeB pht_type.a_var,dk_luy pht_type.a_var,dk_lh_bh pht_type.a_var,b_loi out varchar2)
AS
    b_so_id_kt number:=-1; b_txt clob; b_tien number:=0; b_ma_ke varchar2(20):=' ';
begin
-- Nam - Nhap
b_loi:='loi:Loi Table bh_hang:loi';
if b_ttrang='D' then b_so_id_kt:=0; end if;
-- dieu khoan
for b_lp in 1..dk_lh_nv.count loop
    if dk_lh_nv(b_lp)<>' ' and dk_kieu(b_lp)='T' then b_tien:=b_tien+dk_tien(b_lp); end if;
    insert into bh_hang_dk values(
        b_ma_dvi,b_so_id,b_so_hd_g,b_lp,dk_ma_hang(b_lp),dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),dk_kieu(b_lp),
        dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),dk_cap(b_lp),dk_ma_dk(b_lp),dk_ma_dkC(b_lp),dk_lh_nv(b_lp),
        dk_t_suat(b_lp),dk_thue(b_lp),dk_ttoan(b_lp),dk_ptB(b_lp),dk_ptG(b_lp),dk_phiG(b_lp),dk_lkeP(b_lp),
        dk_lkeB(b_lp),dk_luy(b_lp),dk_lh_bh(b_lp));
end loop;
insert into bh_hang
    values (b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,
    b_ma_gt,b_ma_cb,b_phong,b_so_hdl,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,
    b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,b_ma_qtac,b_ma_nhang,b_hd_kem,b_c_ctai,b_ma_vchuyen,
    b_cang_di,b_cang_den,b_khoang_cach,b_thoi_gian,b_tong_mtn,b_tien,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,
    b_so_idD,'','',b_so_id_kt,b_nsd,sysdate);
-- danh sach hang hoa
for b_lp in 1..ds_ma_lhang.count loop
    insert into bh_hang_ds values (b_ma_dvi,b_so_id,b_lp,ds_ma_lhang(b_lp),ds_ten_hang(b_lp),ds_dvi_tinh(b_lp),PKH_MA_TENl(ds_ma_dgoi(b_lp)),
           ds_cphi(b_lp),ds_sluong(b_lp),ds_gia(b_lp),ds_gia_tri(b_lp),ds_mtn(b_lp),ds_pt(b_lp),ds_lkeB(b_lp),ds_lh_nv(b_lp));
    select json_object('hang' value ds_ten_hang(b_lp)) into b_txt from dual;
end loop;
for b_lp in 1..ds_ma_ptien.count loop
    insert into bh_hang_ptvc values (b_ma_dvi,b_so_id,b_so_idD,b_lp,ds_ma_ptien(b_lp),ds_ten_ptien(b_lp),ds_so_imo(b_lp),ds_so_vdon(b_lp));
end loop;
-- ky thanh toan
for b_lp in 1..tt_ngay.count loop
    insert into bh_hang_tt values(b_ma_dvi,b_so_id,tt_ngay(b_lp),tt_tien(b_lp));
end loop;
PKH_JS_THAYa(dt_ct,'so_hd,ma_kh',b_so_hd||','||b_ma_kh);
insert into bh_hang_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
insert into bh_hang_txt values(b_ma_dvi,b_so_id,'dt_ds',dt_ds);
insert into bh_hang_txt values(b_ma_dvi,b_so_id,'dt_pt',dt_pt);
insert into bh_hang_txt values(b_ma_dvi,b_so_id,'dt_dk',dt_dk);
if dt_hk is not null then
    insert into bh_hang_txt values(b_ma_dvi,b_so_id,'dt_hk',dt_hk);
end if;
if dt_lt is not null then
    insert into bh_hang_txt values(b_ma_dvi,b_so_id,'dt_lt',dt_lt);
end if;
if dt_kbt is not null then
    insert into bh_hang_txt values(b_ma_dvi,b_so_id,'dt_kbt',dt_kbt);
end if;
if dt_ttt is not null then
    insert into bh_hang_txt values(b_ma_dvi,b_so_id,'dt_ttt',dt_ttt);
end if;
if dt_vch is not null then
    insert into bh_hang_txt values(b_ma_dvi,b_so_id,'dt_vch',dt_vch);
end if;
if b_ttrang in ('T','D') then
    select JSON_ARRAYAGG(json_object(
        ma,ten,tc,ma_ct,tien,pt,phi,cap,ma_dk,ma_dkC,lh_nv,t_suat,thue,ttoan,ptB,ptG,phiG,lkeP,lkeB,luy,lh_bh)
        order by bt returning clob) into b_txt
        from bh_hang_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
    insert into bh_hang_kbt values(b_ma_dvi,b_so_id,b_txt,dt_lt,dt_kbt);
    for b_lp in 1..ds_ma_ptien.count loop
        PBH_HANG_TTU(b_ma_dvi,b_so_id,ds_ma_ptien(b_lp),ds_ten_ptien(b_lp),ds_so_imo(b_lp),b_loi);
    end loop;
    if b_loi is not null then return; end if;
    select json_object('ma_dvi' value b_ma_dvi,'nsd' value b_nsd,'so_id' value b_so_id,'so_hd' value b_so_hd,
        'kieu_hd' value b_kieu_hd,'nv' value 'HANG','ngay_ht' value b_ngay_ht,'ngay_cap' value b_ngay_cap,
        'ngay_hl' value b_ngay_hl,'ngay_kt' value b_ngay_kt,'cb_ql' value b_ma_cb,'phong' value b_phong,
        'kieu_kt' value b_kieu_kt,'ma_kt' value b_ma_kt,'dly_tke' value ' ','hhong' value b_hhong,
        'pt_hhong' value 'D','ma_kh' value b_ma_kh,'ten' value b_ten,'kieu_gt' value b_kieu_gt,
        'ma_gt' value b_ma_gt,'so_id_d' value b_so_idD,'so_id_g' value b_so_idG,'ttrang' value b_ttrang,
        'dvi_ksoat' value b_ma_dvi,'ksoat' value b_nsd,'bangg' value 'bh_hang',
        'c_thue' value b_c_thue,'nt_tien' value b_nt_tien,'nt_phi' value b_nt_phi,'tien' value b_tien,
        'phi' value b_ttoan-b_thue,'thue' value b_thue returning clob) into b_txt from dual;
    PBH_HD_GOC_NH(b_txt,b_loi);
    if b_loi is not null then return; end if;
end if;
if b_ttrang='D' then
  for b_lp in 1..ds_ma_lhang.count loop
      PBH_KE_CTI_NHOM(b_ma_dvi,b_so_idD,b_so_idD,b_ma_ke,b_loi);
      if b_loi is null then return; end if;
      insert into bh_hd_goc_ttindt values(
          b_ma_dvi,b_so_idD,b_so_idD,'HANG',ds_ma_lhang(b_lp),b_ma_kh,b_ngay_kt,' ',b_ma_ke);
  end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HANGH_NH(
     b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(3000); b_lenh varchar2(2000); b_i1 number;
    dt_ct clob; dt_ds clob; dt_pt clob; dt_dk clob; dt_lt clob; dt_kbt clob; dt_kytt clob; dt_ttt clob; dt_vch clob;dt_hk clob;
    -- Chung
    b_so_id number; b_so_hd varchar2(20); b_ngay_ht number; b_ttrang varchar2(1); b_kieu_hd varchar2(1); b_so_hd_g varchar2(20);
    b_kieu_kt varchar2(1); b_ma_kt varchar2(20); b_kieu_gt varchar2(1); b_ma_gt varchar2(20); b_ma_cb varchar2(20);
    b_loai_kh varchar2(1); b_ma_kh varchar2(20); b_ten nvarchar2(500); b_dchi nvarchar2(500);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_gio_hl varchar2(20); b_ngay_hl number; b_gio_kt varchar2(20); b_ngay_kt number; b_ngay_cap number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_c_thue varchar2(1);
    b_phi number; b_giam number; b_thue number; b_ttoan number; b_hhong number;
    b_so_idG number; b_so_idD number; b_ngayD number; b_phong varchar2(10); b_ch varchar2(1):='K';
    tt_ngay pht_type.a_num; tt_tien pht_type.a_num;
    -- Rieng
    b_so_hdL varchar2(1):='T'; b_so_idP number;
    b_ma_qtac varchar2(500); b_ma_nhang varchar2(500); b_hd_kem varchar2(1); b_c_ctai varchar2(1); b_ma_vchuyen varchar2(500);
    b_khoang_cach number; b_thoi_gian number; b_gdinh varchar2(500); b_cang_di varchar2(500); b_cang_den varchar2(500); b_noi_di varchar2(500);
    b_noi_den varchar2(500); b_ma_dkgh varchar2(500); b_ma_pptinh varchar2(500); b_tong_mtn number; b_tp number; b_pphi number;
    b_cmtH varchar2(20); b_mobiH varchar2(20); b_emailH varchar2(100); b_loai_khH varchar2(1); b_tenH nvarchar2(400); b_dchiH nvarchar2(1000);
    -- danh sach hang hoa
    ds_ma_lhang pht_type.a_var; ds_ten_hang pht_type.a_var; ds_dvi_tinh pht_type.a_var;
    ds_ma_dgoi pht_type.a_var; ds_cphi pht_type.a_num; ds_sluong pht_type.a_num; ds_gia pht_type.a_num;
    ds_gia_tri pht_type.a_num; ds_mtn pht_type.a_num; ds_pt pht_type.a_num;
    ds_lh_nv pht_type.a_var;ds_lkeB pht_type.a_var;
    -- thong tin phuong tien
    ds_ma_ptien pht_type.a_var; ds_ten_ptien pht_type.a_var; ds_so_imo pht_type.a_var; ds_so_vdon pht_type.a_var;
    ---- dieu khoan
    dk_ma pht_type.a_var; dk_ma_hang pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var;
    dk_ma_ct pht_type.a_var; dk_kieu pht_type.a_var; dk_tien pht_type.a_num;
    dk_pt pht_type.a_num; dk_phi pht_type.a_num; dk_thue pht_type.a_num; dk_ttoan pht_type.a_num;
    dk_cap pht_type.a_num; dk_ma_dk pht_type.a_var; dk_ma_dkC pht_type.a_var; dk_lh_nv pht_type.a_var;
    dk_t_suat pht_type.a_num; dk_ptB pht_type.a_num; dk_ptG pht_type.a_num; dk_phiG pht_type.a_num;
    dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var; dk_luy pht_type.a_var; dk_lh_bh pht_type.a_var;
    dk_ptK pht_type.a_var;dk_pp pht_type.a_var;dk_phiB pht_type.a_num;
    -- Xu ly
    b_ngay_htC number;
begin
-- Dan - Nhap
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_hk,dt_ds,dt_pt,dt_dk,dt_lt,dt_kbt,dt_kytt,dt_ttt,dt_vch');
   EXECUTE IMMEDIATE b_lenh into dt_ct,dt_hk,dt_ds,dt_pt,dt_dk,dt_lt,dt_kbt,dt_kytt,dt_ttt,dt_vch using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_kytt); FKH_JSa_NULL(dt_ttt); FKH_JSa_NULL(dt_hk); 
FKH_JSa_NULL(dt_ds); FKH_JSa_NULL(dt_pt); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_lt);
FKH_JSa_NULL(dt_kbt); FKH_JSa_NULL(dt_vch);          
if b_so_id<>0 then
    select count(*) into b_i1 from bh_hang where so_id=b_so_id;
    if b_i1<>0 then
        select ngay_ht,kieu_hd,ttrang into b_ngay_htC,b_kieu_hd,b_ttrang from bh_hang
            where so_id=b_so_id for update nowait;
        if sql%rowcount=0 then b_loi:='loi:Va cham NSD:loi'; raise PROGRAM_ERROR; end if;
        if b_ttrang not in('T','D') then b_kieu_hd:='X'; else b_kieu_hd:='N'; end if;
        PBH_HANGH_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_kieu_hd,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
else
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_HD_JS_TEST(
    b_ma_dvi,b_nsd,b_so_id,b_ngay_htC,'bh_hang',dt_ct,dt_kytt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_loai_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,
    b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_ngayD,b_phong,b_ma_cb,b_ma_kh,
    tt_ngay,tt_tien,b_loi,'HANG');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay_hl in(0,30000101) then b_ngay_hl:=b_ngay_cap; end if;
if b_ngay_kt in(0,30000101) then b_ngay_kt:=PKH_NG_CSO(add_months(PKH_SO_CDT(b_ngay_hl),12)); end if;
if(b_kieu_hd = 'U') then
    PBH_HANGH_NH_U(
      b_ma_dvi,b_nsd,b_so_id,dt_ct,
      b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,b_so_hdL,
      b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
      b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,
      b_so_idG,b_so_idD,b_ngayD,b_phong,b_hhong,tt_ngay,tt_tien,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
else
    PBH_HANGH_TESTr(
      b_ma_dvi,b_nsd,
      dt_ct,dt_ds,dt_dk,dt_pt,b_so_idP,b_so_idG,b_so_idD,b_so_hd,
      b_ma_qtac,b_ma_nhang,b_hd_kem,b_c_ctai,b_ma_vchuyen,b_ngay_hl,b_ngay_kt,b_ngay_cap,
      b_khoang_cach,b_thoi_gian,b_gdinh,b_cang_di,b_cang_den,b_noi_di,
      b_noi_den,b_ma_dkgh,b_ma_pptinh,b_tong_mtn,b_tp,b_pphi,
      b_cmtH,b_mobiH,b_emailH,b_loai_khH,b_tenH,b_dchiH,b_ch,
      -- thong tin thanh toan
      tt_ngay,tt_tien,
      -- danh sach hang
      ds_ma_lhang,ds_ten_hang,ds_dvi_tinh,ds_ma_dgoi,ds_cphi,ds_sluong,ds_gia,ds_gia_tri,ds_mtn,ds_pt,
      ds_lh_nv,ds_lkeB,
      -- thong tin phuong tien
      ds_ma_ptien, ds_ten_ptien, ds_so_imo, ds_so_vdon,
      -- dieu khoan bao hiem
      dk_ma,dk_ma_hang,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,dk_cap,dk_ma_dk,dk_ma_dkC,
      dk_lh_nv,dk_t_suat,dk_ptB,dk_ptG,dk_phiG,dk_lkeP,dk_lkeB,dk_luy,dk_lh_bh,dk_ptK,dk_pp,dk_phiB,b_loi);
   if b_loi is not null then raise PROGRAM_ERROR; end if;
   PBH_HANGH_NH_NH(
      b_ma_dvi,b_nsd,b_so_id,
      dt_ct,dt_hk,dt_ds,dt_dk,dt_lt,dt_kbt,dt_pt,dt_ttt,dt_vch,
      b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_so_idG,b_so_idD,
      b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,b_phong,b_so_hdL,b_loai_kh,b_ma_kh,
      b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,
      b_ma_qtac,b_ma_nhang,b_hd_kem,b_c_ctai,b_ma_vchuyen,b_khoang_cach,b_thoi_gian,b_cang_di,
      b_cang_den,b_ngay_cap,b_c_thue,b_tong_mtn,b_phi,b_giam,b_thue,b_ttoan,b_nt_tien,b_nt_phi,b_hhong,
      tt_ngay,tt_tien,
      -- danh sach hang
      ds_ma_lhang,ds_ten_hang,ds_dvi_tinh,ds_ma_dgoi,ds_cphi,ds_sluong,ds_gia,ds_gia_tri,ds_mtn,ds_pt,
      ds_lh_nv,ds_lkeB,
      -- thong tin phuong tien
      ds_ma_ptien, ds_ten_ptien, ds_so_imo, ds_so_vdon,
      -- dieu khoan bao hiem
      dk_ma,dk_ma_hang,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,dk_cap,dk_ma_dk,dk_ma_dkC,
      dk_lh_nv,dk_t_suat,dk_ptB,dk_ptG,dk_phiG,dk_lkeP,dk_lkeB,dk_luy,dk_lh_bh,b_loi);
   if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
if b_comm='C' then commit; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hd' value b_so_hd, 'ma_kh' value b_ma_kh,'ch' value b_ch) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANGH_NH_U(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,dt_ct in out clob,
-- Chung
    b_so_hd varchar2,b_ngay_ht number,b_ttrang varchar2,b_kieu_hd varchar2,b_so_hd_g varchar2,
    b_kieu_kt varchar2,b_ma_kt varchar2,b_kieu_gt varchar2,b_ma_gt varchar2,b_ma_cb varchar2,
    b_so_hdL varchar2,b_loai_kh varchar2,b_ma_kh varchar2,b_ten nvarchar2,b_dchi nvarchar2,
    b_cmt varchar2,b_mobi varchar2,b_email varchar2,
    b_gio_hl varchar2,b_ngay_hl number,b_gio_kt varchar2,b_ngay_kt number,b_ngay_cap number,
    b_nt_tien varchar2,b_nt_phi varchar2,b_c_thue varchar2,
    b_so_idG number,b_so_idD number,b_ngayD number,b_phong varchar2, b_hhong number,
    tt_ngay pht_type.a_num,tt_tien pht_type.a_num,
    b_loi out varchar2)
AS
    b_lenh varchar2(2000);
    b_ma_qtac varchar2(500); b_ma_nhang varchar2(500); b_hd_kem varchar2(1); b_c_ctai varchar2(1); b_ma_vchuyen varchar2(500);
    b_cang_di varchar2(500); b_cang_den varchar2(500); b_phi number; b_giam number; b_thue number; b_ttoan number;
begin
  -- Dan - Nhap
    b_lenh:=FKH_JS_LENH('ma_qtac,ma_nhang,vchuyen,cang_di,cang_den,hd_kem,c_ctai,phi,giam,thue,ttoan');
    EXECUTE IMMEDIATE b_lenh into b_ma_qtac,b_ma_nhang,b_ma_vchuyen,
                      b_cang_di,b_cang_den,b_hd_kem,b_c_ctai,b_phi,b_giam,b_thue,b_ttoan using dt_ct;
b_ma_qtac:=PKH_MA_TENl(b_ma_qtac); b_ma_nhang:=PKH_MA_TENl(b_ma_nhang);
b_ma_vchuyen:=PKH_MA_TENl(b_ma_vchuyen); b_cang_di:=PKH_MA_TENl(b_cang_di); b_cang_den:=PKH_MA_TENl(b_cang_den);
b_loi:='loi:Loi Table bh_hang:loi';
insert into bh_hang values(
    b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
    b_phong,b_so_hdL,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,
    b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,b_ma_qtac,b_ma_nhang,b_hd_kem,b_c_ctai,b_ma_vchuyen,b_cang_di,b_cang_den,
    0,0,0,0,b_phi,b_giam,b_thue,b_ttoan,0,b_so_idG,b_so_idD,'','',-1,b_nsd,sysdate);
PKH_JS_THAYa(dt_ct,'so_hd,ma_kh',b_so_hd||','||b_ma_kh);
insert into bh_hang_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HANG_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,
	b_ttrang varchar2,b_so_hd out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_txt clob;
begin
-- Nam - Update sau duyet
b_loi:='loi:Loi xu ly PBH_HANG_DU:loi';
select so_hd into b_so_hd from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_i1:=instr(b_so_hd,'.');
if b_ttrang='D' then
    if b_i1=2 then b_so_hd:=substr(b_so_hd,3); end if;
else
    if b_i1<>2 then b_so_hd:=b_ttrang||'.'||b_so_hd; end if;
end if;
select txt into b_txt from bh_hang_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
b_txt:=FKH_JS_BONH(b_txt); PKH_JS_THAY(b_txt,'so_hd',b_so_hd); b_txt:=b_txt;
update bh_hang set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
update bh_hang_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure FBH_HANG_MTN(b_tp number,
    a_ma pht_type.a_var,b_pptinh varchar2,a_cphi pht_type.a_num,a_gtri pht_type.a_num,
    a_pt pht_type.a_num,a_mtn out pht_type.a_num,b_loi out varchar2)
AS
begin
-- Nam - Tinh muc trach nhiem hang hoa theo phuong phap tinh
b_loi:='loi:Loi xu ly FBH_HANG_MTN:loi';
for b_lp in 1..a_ma.count loop
    if b_pptinh = '100' then a_mtn(b_lp):=a_gtri(b_lp);
    elsif b_pptinh = '100CIF' then a_mtn(b_lp):=ROUND((a_gtri(b_lp)+a_cphi(b_lp))/(1 - a_pt(b_lp)),b_tp);
    elsif b_pptinh = '110' then a_mtn(b_lp):=ROUND((a_gtri(b_lp)* 110)/100,b_tp);
    else a_mtn(b_lp):=ROUND((a_gtri(b_lp)+a_cphi(b_lp))/(1 - a_pt(b_lp))*110/100,b_tp);
    end if;
end loop;
b_loi:='';
end;
/
create or replace procedure PBH_HANGGCN_KEM_LKE
   (b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(200); b_lenh varchar2(1000); b_i1 number; b_so_hd varchar2(20); b_ngay number:=PKH_NG_CSO(sysdate);
    b_ma_kh varchar2(20);
    b_ma_dvi varchar2(10); b_thue number; b_ttoan number; b_ngay_ht number;
    b_so_idB number; b_so_idG number; b_so_idD number;
    cs_lke clob;
begin
--Nam-  Liet ke hop dong kem
delete temp_1; delete temp_2; delete temp_3; delete temp_4; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','HANG','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
b_lenh:=FKH_JS_LENH('ma_dvi,ma_kh,so_hd,ngay_ht');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_ma_kh,b_so_hd,b_ngay_ht using b_oraIn;
b_ma_kh:=nvl(trim(b_ma_kh),' '); b_so_hd:=nvl(trim(b_so_hd),' ');
if b_so_hd=' ' and b_ma_kh=' ' then
    b_loi:='loi:Nhap so hop dong/GCN, ma khach hang:loi'; raise PROGRAM_ERROR;
end if;
b_so_idG:=FBH_HANG_SO_ID(b_ma_dvi,b_so_hd);
if b_so_idG=0 then b_loi:='loi:Hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
if b_so_hd<>' ' then
    b_so_idD:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi,b_so_hd);
    if b_so_idD=0 then b_loi:='loi:So hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
    select count(*) into b_i1 from bh_hd_goc_sc_phi_ton where ma_dvi=b_ma_dvi and so_id=b_so_idD;
    if b_i1=0 then
        select count(*) into b_i1 from bh_hd_goc_sc_no_ton where ma_dvi=b_ma_dvi and so_id=b_so_idD;
    end if;
    if b_i1<>0 then insert into temp_1(n1,c1) values(b_so_idD,b_so_hd); end if;
else
    insert into temp_1(n1,c1)
        select so_id,so_hd from bh_hd_goc_sc_phi_ton where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh union all
        select so_id,so_hd from bh_hd_goc_sc_no_ton where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh;
end if;
select count(*) into b_i1 from temp_1;
if b_i1<>0 then
    insert into temp_3(n1,c2,n3) select so_id,'G',sum(ttoan) from bh_hd_goc_cl
        where ma_dvi=b_ma_dvi and so_id in (select n1 from temp_1) group by so_id;
    insert into temp_3(n1,c2,n3) select so_id,'G',-sum(ttoan) from bh_hd_goc_ttpt
        where ma_dvi=b_ma_dvi and pt in('C','G') and so_id in (select n1 from temp_1) group by so_id;
    insert into temp_3(n1,c2,n3) select so_id,'N',sum(ttoan) from bh_hd_goc_ttpt
        where ma_dvi=b_ma_dvi and pt='C' and so_id in (select n1 from temp_1) group by so_id;
    insert into temp_3(n1,c2,n3) select so_id,'N',-sum(ttoan) from bh_hd_goc_ttpt
        where ma_dvi=b_ma_dvi and pt='N' and so_id in (select n1 from temp_1) group by so_id;
    insert into temp_2(n1,c2,n3) select n1,c2,sum(n3) from temp_3 group by n1,c2 having sum(n3)<>0;
    if sql%rowcount<>0 then
        update temp_2 set c1=(select min(c1) from temp_1 where n1=temp_2.n1);
    end if;
end if;
for r_lp in (select so_id,ngay_hl,so_hd,ma_dvi,ttrang from bh_hang where ma_dvi=b_ma_dvi and kieu_hd='K' and so_id_g=b_so_idG) loop
    b_so_idB:=FBH_HANG_SO_ID_BS(b_ma_dvi,r_lp.so_id,b_ngay_ht);
    select sum(thue),sum(ttoan) into b_thue,b_ttoan from bh_hang_dk where ma_dvi=b_ma_dvi and so_id=b_so_idB and lh_nv<>' ';
    insert into temp_4(c1,c2,n1,n2,n3,n4,n5,c3) values(r_lp.so_hd,r_lp.ttrang,r_lp.ngay_hl,b_ttoan-b_thue,b_thue,b_ttoan,r_lp.so_id,r_lp.ma_dvi);
    update temp_4 set n9 = FKH_KHO_NGSO(b_ngay,PKH_NG_CSO(TRUNC(add_months(PKH_SO_CDT(n1),1), 'MM')+ 24)); 
    update temp_4 set n6 = (select sum(ttoan) from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id=b_so_idD and pt='G');
    --tinh tien da thanh toan va tien con no theo thu tu
    update temp_4 t
      set n7 = (
          select
              case
                  when a.n6 - lke >= a.n4 THEN a.n4
                  when a.n6 - lke > 0 THEN a.n6 - lke
                  else 0
              end
          from (
              select rowid rid,n4,n6,
              nvl(sum(n4) over (order by n5 rows between UNBOUNDED PRECEDING and 1 PRECEDING ),0) as lke
              from temp_4
          ) a
          where a.rid = t.rowid
      );
    update temp_4 SET n8 = n4 - n7;
    update temp_4 SET n9 = '' where n8 = 0;
    select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ngay_ht' value n1,
           'phi' value n2,'thue' value n3,'ttoan' value n4,'ttoand' value n7,'no_phi' value n8,'ngay_no' value n9,
           'so_id' value n5,'ma_dvi' value c3) order by c1) into cs_lke from temp_4;
end loop;
delete temp_1; delete temp_2; delete temp_3; delete temp_4; commit;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_TTU(
    b_ma_dvi varchar2,b_so_id number,b_pt varchar2,b_ten_pt nvarchar2,b_so_imo varchar2,b_loi out varchar2)
as
    b_so_idD number; b_so_idC number;
begin
-- Nam - Tao tich tu
b_so_idD:=FBH_HANG_SO_IDd(b_ma_dvi,b_so_id);
b_so_idC:=FBH_HANG_SO_IDc(b_ma_dvi,b_so_idD);
delete bh_hang_ttu where ma_dvi=b_ma_dvi and so_id=b_so_idD;
insert into bh_hang_ttu select b_ma_dvi,b_so_idD,b_pt,b_ten_pt,b_so_imo,hd_kem,kieu_hd,ttrang,vchuyen,ngay_cap,ngay_hl,ngay_kt
    from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_idC and (b_so_imo<>' ' or b_ten_pt<>' ') and ttrang='D' and hd_kem='K' and kieu_hd in('G','K');
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HANG_TTU:loi'; end if;
end;
/
create or replace procedure PBH_HANG_TG_UOC (
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_uoc number;  b_ma varchar2(200):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Nam - Tra thoi gian uoc luong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ma:=PKH_MA_TENL(b_ma);
select nvl(uoc,0) into b_uoc from bh_hang_nhom where ma=b_ma;
select json_object('uoc' value b_uoc) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
