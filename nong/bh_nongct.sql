create or replace function FBH_NONGCT_DVI(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngayN number:=30000101) return nvarchar2
AS
    b_kq nvarchar2(500); b_so_idB number; b_ngay number:=b_ngayN;
begin
-- Nam - Tra dvi rui ro
if b_ngay=0 then b_ngay:=30000101; end if;
b_so_idB:=FBH_NONGCT_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select min(dvi) into b_kq from bh_nongct_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace function FBH_NONGCT_HL(
    b_ma_dvi varchar2,b_so_id number,b_ngay number,b_ngayd number,b_ngayc number) return varchar2
AS
    b_so_idB number; b_ngay_hl number; b_ngay_kt number; b_kq varchar2(1):='K';
begin
-- Nam - Kiem tra hieu luc
b_so_idB:=FBH_NONGCT_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from bh_nongct where ma_dvi=b_ma_dvi and so_id=b_so_idB;
if b_ngayd<=b_ngay_kt and b_ngay_hl<=b_ngayc then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_NONGCT_HLd(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay number) return varchar2
AS
    b_so_idB number; b_ngay_hl number; b_ngay_kt number; b_kq varchar2(1):='K';
begin
-- Nam - Kiem tra hieu luc
b_so_idB:=FBH_NONGCT_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
if b_so_idB<>0 then
    select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from bh_nongct_dvi  where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
    if b_ngay between b_ngay_hl and b_ngay_kt then b_kq:='C'; end if;
end if;
return b_kq;
end;
/
create or replace function FBH_NONGCT_KIEU_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Nam - Tra so hop dong
select nvl(min(kieu_hd),' ') into b_kq from bh_nongct where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_NONGCT_KIEU_HDd(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(1); b_so_idD number:=FBH_NONGCT_SO_IDd(b_ma_dvi,b_so_id);
begin
-- Nam - Tra kieu hop dong qua so_id
select nvl(min(kieu_hd),' ') into b_kq from bh_nongct where ma_dvi=b_ma_dvi and so_id=b_so_idD;
return b_kq;
end;
/
create or replace function FBH_NONGCT_SO_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Nam - Tra so hop dong
select min(so_hd) into b_kq from bh_nongct where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_NONGCT_SO_HDd(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50); b_so_idD number;
begin
-- Nam - Tra so hop dong dau
b_so_idD:=FBH_NONGCT_SO_IDd(b_ma_dvi,b_so_id);
b_kq:=FBH_NONGCT_SO_HD(b_ma_dvi,b_so_idD);
return b_kq;
end;
/
create or replace function FBH_NONGCT_SO_ID(b_ma_dvi varchar2,b_so_hd varchar2,b_nv varchar2:='') return number
as
    b_kq number;
begin
-- Nam - Tra so id
if nvl(b_nv,' ')=' ' then 
    select nvl(min(so_id),0) into b_kq from bh_nongct where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
else 
    select nvl(min(so_id),0) into b_kq from bh_nongct where ma_dvi=b_ma_dvi and so_hd=b_so_hd and nv=b_nv;
end if;
return b_kq;
end;
/
create or replace function FBH_NONGCT_ID_ID_DT(b_ma_dvi varchar2,b_so_id number,b_gcn varchar2) return number
as
    b_kq number;
begin
-- Nam - Tra so id
select nvl(min(so_id_dt),0) into b_kq from bh_nongct_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id and gcn=b_gcn;
return b_kq;
end;
/
create or replace function FBH_NONGCT_ID_GCN(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return varchar2
as
    b_kq varchar2(20);
begin
-- Nam - Tra gcn
select min(gcn) into b_kq from bh_nongct_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace function FBH_NONGCT_HD_ID_DT(b_ma_dvi varchar2,b_so_hd number,b_gcn varchar2) return number
as
    b_kq number:=0; b_so_id number;
begin
-- Nam - Tra so id DT
b_so_id:=FBH_NONGCT_SO_ID(b_ma_dvi,b_so_hd);
if b_so_id<>0 then b_kq:=FBH_NONGCT_ID_ID_DT(b_ma_dvi,b_so_id,b_gcn); end if;
return b_kq;
end;
/
create or replace function FBH_NONGCT_SO_IDd(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Nam - Tra so id dau
select nvl(min(so_id_d),0) into b_kq from bh_nongct where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_NONGCT_SO_GCNd(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return number
as
    b_kq number; b_so_idD number;
begin
-- Nam - Tra so GCN dau
b_so_idD:=FBH_NONGCT_SO_IDd(b_ma_dvi,b_so_id);
select min(gcn) into b_kq from bh_nongct_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idD and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace procedure PBH_NONGCT_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_so_id number; b_so_hd varchar2(20);b_nv varchar2(10);
    b_lenh varchar2(2000); b_loi varchar2(100);
begin
-- Nam - Hoi so ID qua so hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NONG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hd,nv');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_nv using b_oraIn;
b_so_id:=FBH_NONGCT_SO_ID(b_ma_dvi,b_so_hd,b_nv);
if b_so_id=0 then b_loi:='loi:So hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_NONGCT_SO_IDc(b_ma_dvi varchar2,b_so_id number,b_ttrang varchar2:='K') return number
as
    b_kq number:=0; b_so_idD number:=b_so_id;
begin
-- Nam - Tra so id cuoi
b_so_idD:=FBH_NONGCT_SO_IDd(b_ma_dvi,b_so_id);
if b_ttrang<>'C' then
    select nvl(max(so_id),0) into b_kq from bh_nongct where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
else
    select nvl(max(so_id),0) into b_kq from bh_nongct where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D';
end if;
return b_kq;
end;
/
create or replace function FBH_NONGCT_SO_IDb(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Nam - Tra so id cuoi
b_so_idD:=FBH_NONGCT_SO_IDd(b_ma_dvi,b_so_id);
select nvl(max(so_id),0) into b_kq from bh_nongct where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D' and ngay_cap<=b_ngay;
return b_kq;
end;
/
create or replace procedure FBH_NONGCT_SO_ID_DT(
    b_so_id_dt number,b_ma_dvi out varchar2,b_so_id out number,b_ngay number:=30000101)
as
begin
-- Nam - Tra so id cuoi qua so_id_dt
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_nongct_dvi where so_id_dt=b_so_id_dt;
if b_so_id<>0 then b_so_id:=FBH_NONGCT_SO_IDb(b_ma_dvi,b_so_id,b_ngay); end if;
end;
/
create or replace procedure FBH_NONGCT_SO_ID_DTd(
    b_so_id_dt number,b_ma_dvi out varchar2,b_so_id out number)
as
begin
-- Nam - Tra so id dau qua so_id_dt
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_nongct_dvi where so_id_dt=b_so_id_dt;
if b_so_id<>0 then b_so_id:=FBH_NONGCT_SO_IDd(b_ma_dvi,b_so_id); end if;
end;
/
create or replace procedure FBH_NONGCT_SO_ID_GCN(
    b_gcn varchar2,b_ma_dvi out varchar2,b_so_id out number,b_so_id_dt out number,b_ngay number:=30000101)
as
begin
-- Nam - Tra so id cuoi qua so_id_dt
select count(*) into b_so_id from bh_nongct_dvi where gcn=b_gcn;
if b_so_id<>1 then
    b_ma_dvi:=''; b_so_id:=0; b_so_id_dt:=0;
else
    select ma_dvi,so_id,so_id_dt into b_ma_dvi,b_so_id,b_so_id_dt from bh_nongct_dvi where gcn=b_gcn;
    b_so_id:=FBH_NONGCT_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
end if;
end;
/
create or replace procedure FBH_NONGCT_SO_ID_GCNd(
    b_gcn varchar2,b_ma_dvi out varchar2,b_so_id out number,b_so_id_dt out number,b_ngay number:=30000101)
as
begin
-- Nam - Tra so id dau qua so_id_dt
select count(*) into b_so_id from bh_nongct_dvi where gcn=b_gcn;
if b_so_id<>1 then
    b_ma_dvi:=''; b_so_id:=0; b_so_id_dt:=0;
else
    select ma_dvi,so_id,so_id_dt into b_ma_dvi,b_so_id,b_so_id_dt from bh_nongct_dvi where gcn=b_gcn;
    b_so_id:=FBH_NONGCT_SO_IDd(b_ma_dvi,b_so_id);
end if;
end;
/
create or replace function FBH_NONGCT_NT_TIEN(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(5); b_so_idB number;
begin
-- Nam - Tra loai tien bao hiem
b_so_idB:=FBH_NONGCT_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select nvl(min(nt_tien),'VND') into b_kq from bh_nongct where ma_dvi=b_ma_dvi and so_id=b_so_idB;
return b_kq;
end;
/
create or replace function FBH_NONGCT_NT_PHI(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(5); b_so_idB number;
begin
-- Nam - Tra loai tien phi
b_so_idB:=FBH_NONGCT_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select nvl(min(nt_phi),'VND') into b_kq from bh_nongct where ma_dvi=b_ma_dvi and so_id=b_so_idB;
return b_kq;
end;
/
create or replace function FBH_NONGCT_CAP(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Nam - Tra ngay cap
select min(ngay_cap) into b_kq from bh_nongct where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_NONGCT_NGAY(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Nam - Tra nhap
select nvl(min(ngay_ht),0) into b_kq from bh_nongct where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_NONGCT_SO_IDp(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return number
as
    b_kq number;
begin
-- Nam - Tra so_idP
select min(so_idP) into b_kq from bh_nongct_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace function FBH_NONGCT_TTRANG(
    b_ma_dvi varchar2,b_so_id number,b_dk varchar2:='K',b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(1); b_i1 number;
begin
-- Nam - Tra ngay cap
select nvl(min(ttrang),'X') into b_kq from bh_nongct where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_kq<>'X' and b_dk='C' then
    select count(*) into b_i1 from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay;
    if b_i1<>0 then b_kq:='H'; end if;
end if;
return b_kq;
end;
/
create or replace procedure PBH_NONGCT_SO_ID_KTRA(b_ma_dvi varchar2,b_so_id_g number,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Nam - Kiem tra SO_ID moi nhap
if b_so_id_g=0 then b_loi:=''; return; end if;
select count(*) into b_i1 from bh_nongct where ma_dvi=b_ma_dvi and so_id=b_so_id_g and ttrang<>'D';
if b_i1<>0 then b_loi:='loi:Hop dong cu da xoa hoac chua ky:loi'; return; end if;
select count(*) into b_i1 from bh_nongct where ma_dvi=b_ma_dvi and so_id_g=b_so_id_g and kieu_hd<>'K';
if b_i1<>0 then b_loi:='loi:Hop dong cu da co bo sung, sua doi:loi'; return; end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function FBH_NONGCT_MA_SDBS(b_so_id number) return nvarchar2
as
    b_kq nvarchar2(200);
begin
-- Nam - Tra so id dau
select FKH_JS_GTRIs(FKH_JS_BONH(txt),'ma_sdbs') into b_kq from bh_nongct_txt where  so_id=b_so_id and loai='dt_ct';
return b_kq;
end;
/
create or replace procedure FBH_NONGCT_KHO(
    b_ngay_hl number,b_ngay_kt number,b_kho out number,b_loi out varchar2,b_dk varchar2:='K')
AS
    b_i1 number; b_tltg number;
begin
-- Nam - Tinh he so phi
b_loi:='loi:Loi xu ly FBH_NONGCT_KHO:loi';
if substr(to_char(b_ngay_hl), 5)=substr(to_char(b_ngay_kt), 5) then b_kho:=FKH_KHO_NASO(b_ngay_hl,b_ngay_kt);
else
  b_kho:=FKH_KHO_NGSO(b_ngay_hl,b_ngay_kt)+1;
  select count(*) into b_i1 from bh_nongct_tltg;
  if b_kho<365 and b_i1<>0 and b_dk<>'C' then
      b_kho:=FKH_KHO_THSO(b_ngay_hl,b_ngay_kt);
      select count(*),nvl(min(tltg),0) into b_i1,b_tltg from bh_nongct_tltg
          where tltg>b_kho and b_ngay_hl between ngay_bd and ngay_kt;
      if b_i1=0 then b_kho:=1;
      else
          select tlph into b_kho from bh_nongct_tltg where tltg=b_tltg and b_ngay_hl between ngay_bd and ngay_kt;
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
CREATE OR REPLACE procedure PBH_NONGCT_BS(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_so_idD number;
    b_ma_dvi varchar2(10); b_so_id number; b_so_id_dt number; cs_lke clob;
begin
-- Nam - Liet ke sua doi theo doi tuong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','NONG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id,so_id_dt');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id,b_so_id_dt using b_oraIn;
if b_so_id=0 then b_loi:='loi:GCN/Hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
b_so_idD:=FBH_NONGCT_SO_IDd(b_ma_dvi,b_so_id);
select JSON_ARRAYAGG(json_object(ngay_ht,so_hd,gcn) order by ngay_ht desc,so_hd desc,gcn desc returning clob) into cs_lke from
        (select distinct a.ngay_ht,a.so_hd,b.gcn from bh_nongct a,bh_nongct_dvi b
        where a.ma_dvi=b_ma_dvi and a.so_id_d=b_so_idD and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id and b.so_id_dt=b_so_id_dt);
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NONGCT_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10);
    b_ngay_ht number; b_nv varchar2(1); b_klk varchar2(1); b_tu number; b_den number;
    b_dong number; cs_lke clob;
begin
-- Nam - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NONG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,nv,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_nv,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_nongct where ma_dvi=b_ma_dvi and 
        ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_hd,nsd) order by so_hd desc returning clob) into cs_lke from
        (select  ma_dvi,so_id,so_hd,nsd,rownum sott from bh_nongct where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','NONG','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_nongct where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_hd,nsd) order by so_hd desc returning clob) into cs_lke from
        (select ma_dvi,so_id,so_hd,nsd,rownum sott from bh_nongct  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong order by so_hd)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_nongct where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_hd,nsd) order by so_hd desc returning clob) into cs_lke from
        (select ma_dvi,so_id,so_hd,nsd,rownum sott from bh_nongct  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NONGCT_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10); b_so_hd varchar2(20);
    b_so_id number; b_ngay_ht number; b_nv varchar2(1); b_klk varchar2(1); b_trangKt number; b_tu number; b_den number;
    b_trang number; b_dong number; cs_lke clob;
begin
-- Nam - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NONG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,nv,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_nv,b_klk,b_trangKt using b_oraIn;
b_so_hd:=FBH_NONGCT_SO_HD(b_ma_dvi,b_so_id);
if b_so_hd is null then b_loi:='loi:GCN, hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
if b_klk ='N' then
    select count(*) into b_dong from bh_nongct
        where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_nongct where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_hd,nsd) order by so_hd desc returning clob) into cs_lke from
        (select ma_dvi,so_id,so_hd,nsd,rownum sott from bh_nongct  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','NONG','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_nongct where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_nongct where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_hd,nsd) order by so_hd desc returning clob) into cs_lke from
        (select ma_dvi,so_id,so_hd,nsd,rownum sott from bh_nongct  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong order by so_hd)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_nongct where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_nongct where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_hd,nsd) order by so_hd desc returning clob) into cs_lke from
        (select ma_dvi,so_id,so_hd,nsd,rownum sott from bh_nongct  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NONGCT_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh varchar2,b_loi out varchar2)
AS
    b_i1 number; b_so_idK number; b_ttrang varchar2(1); b_ksoat varchar2(20); b_nsdC varchar2(20);
begin
-- Nam - Xoa
b_loi:='';
select so_id_kt,ttrang,ksoat into b_so_idK,b_ttrang,b_ksoat
    from bh_nongct where so_id=b_so_id;
if b_so_idK>0 then b_loi:='loi:Khong sua, xoa phuc hoi da hach toan ke toan:loi'; return; end if;
if b_nsdC<>b_nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
if trim(b_ksoat) is not null and b_ksoat<>b_nsd then b_loi:='loi:Khong sua, xoa GCN, hop dong da kiem soat:loi'; return; end if;
select count(*) into b_i1 from bh_nongct where ma_dvi=b_ma_dvi and so_id_g=b_so_id;
if b_i1<>0 then b_loi:='loi:Khong sua, xoa GCN, hop dong da tao SDBS:loi'; return; end if;
b_loi:='loi:Loi xoa Table bh_nongct:loi';
delete bh_nongct_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_nongct_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_nongct_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_nongct_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_nongct_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_nongct where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_ttrang in('T','D') then
    PBH_NONG_GOC_XOA(b_ma_dvi,b_nsd,b_so_id,b_nh,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_NONGCT_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Nam - Xoa GCN
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NONG','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_NONGCT_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'X',b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NONGCT_HDBS(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma_dvi varchar2(10); b_so_id number; b_so_idD number;
    b_dong number; cs_lke clob:='';
begin
-- Nam - Liet ke sua doi bo sung
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','NONG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_so_idD:=FBH_NONGCT_SO_IDd(b_ma_dvi,b_so_id);
if b_so_idD<>0 then
    select count(*) into b_dong from bh_nongct where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hd,ttoan,ttrang,ma_dvi,so_id,
           'ma_sdbs' value PKH_TEN_TENl(FBH_NONGCT_MA_SDBS(so_id))
    ) order by so_id desc returning clob)
        into cs_lke from bh_nongct where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;   
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NONGCT_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_so_idC number; b_ma_kh varchar2(20); b_so_hd varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ten nvarchar2(500); b_phong varchar2(10); b_nv varchar2(1); b_ma_sp varchar2(10);
    b_ngayD number; b_ngayC number; b_ngay_ht number; b_ttrang varchar2(1);
begin
-- Nam - Tim hop dong qua CMT, mobi, email
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NONG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,so_hd,nv,ma_sp');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_ten,b_so_hd,b_nv,b_ma_sp using b_oraIn;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd); b_ma_sp:=nvl(trim(b_ma_sp),' ');
b_ttrang:=nvl(trim(b_ttrang),' '); b_ten:=nvl(trim(upper(b_ten)), ' ');
b_i1:=PKH_NG_CSO(add_months(sysdate,-36));
if b_ngayD in (0,30000101) or b_ngayD<b_i1 then b_ngayD:=b_i1; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_i1:=0;
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    for r_lp in (select distinct so_id_d from bh_nongct where ma_dvi=b_ma_dvi and ma_kh = b_ma_kh and nv=b_nv
          and ngay_ht between b_ngayD and b_ngayC and phong=b_phong
          and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%') and b_ma_sp in (' ',ma_sp)
          and b_ttrang in (' ',ttrang) and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') order by so_id_d desc) loop
        b_so_idC:=FBH_NONGCT_SO_IDc(b_ma_dvi,r_lp.so_id_d);
        select max(so_hd),max(ngay_ht) into b_so_hd,b_ngay_ht from bh_nongct where ma_dvi=b_ma_dvi and so_id=b_so_idC;
        insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n4,n10,c11)
            select b_so_hd,ttrang,ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_ngay_ht,b_so_idC,FBH_NONGCT_MA_SP_TEN(ma_sp)
            from bh_nongct where ma_dvi=b_ma_dvi and so_id=b_so_idC;
    end loop;
else
    for r_lp in (select distinct so_id_d from bh_nongct where ma_dvi=b_ma_dvi and nv=b_nv
          and ngay_ht between b_ngayD and b_ngayC and phong=b_phong
          and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%') and b_ma_sp in (' ',ma_sp)
          and b_ttrang in (' ',ttrang) and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') order by so_id_d desc) loop
        b_so_idC:=FBH_NONGCT_SO_IDc(b_ma_dvi,r_lp.so_id_d);
        select max(so_hd),max(ngay_ht) into b_so_hd,b_ngay_ht from bh_nongct where ma_dvi=b_ma_dvi and so_id=b_so_idC;
        insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n4,n10,c11)
            select b_so_hd,ttrang,ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_ngay_ht,b_so_idC,FBH_NONGCT_MA_SP_TEN(ma_sp)
            from bh_nongct where ma_dvi=b_ma_dvi and so_id=b_so_idC;
        b_i1:=b_i1+1;
        if b_i1>300 then exit; end if;
    end loop;
end if;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,
    'ngay_hl' value n1,'ngay_kt' value n2,'ngay_cap' value n3,'ma_sp' value c11,
    'ma_dvi' value b_ma_dvi,'so_id' value n10 returning clob)
    order by n4 desc,c1 returning clob) into b_oraOut from ket_qua;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
