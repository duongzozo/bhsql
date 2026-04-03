create or replace function FBH_NGTD_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_id number; b_txt clob;
    a_ds_ct pht_type.a_clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
select count(*) into b_i1 from bh_ngtd_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
	select txt into b_txt from bh_ngtd_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
	PKH_JS_BONH(b_txt); b_kq:=FKH_JS_GTRIs(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_NGTD_TXTn(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return number
AS
    b_kq number:=0; b_i1 number; b_id number; b_txt clob; b_lenh varchar2(1000);
    a_ds_ct pht_type.a_clob;
begin
-- Dan - Tra gia tri num trong txt
select count(*) into b_i1 from bh_ngtd_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_ngtd_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    PKH_JS_BONH(b_txt); b_kq:=FKH_JS_GTRIn(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_NGTD_NV(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra nghiep vu
select min(nv) into b_kq from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure FBH_NGTD_DT_NGd(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay_hld out date,b_ngay_ktd out date)
AS
    b_ngay_hl number; b_ngay_kt number;
begin
-- Dan - Ngay hieu luc, ngay ket thuc doi tuong
select nvl(min(ngay_hl),0),nvl(min(ngay_kt),0) into b_ngay_hl,b_ngay_kt from bh_ngtd_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
if b_ngay_hl=0 then
    select nvl(min(ngay_hl),0),nvl(min(ngay_kt),0) into b_ngay_hl,b_ngay_kt from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
b_ngay_hld:=PKH_SO_CDT(b_ngay_hl); b_ngay_ktd:=PKH_SO_CDT(b_ngay_kt);
end;
/
create or replace function FBH_NGTD_HL(b_ma_dvi varchar2,b_so_id number,b_ngay number,b_ngayd number,b_ngayc number) return varchar2
AS
    b_so_idB number; b_ngay_hl number; b_ngay_kt number; b_kq varchar2(1):='K';
begin
-- Dan - Kiem tra hieu luc
b_so_idB:=FBH_NGTD_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_idB;
if b_ngayd<=b_ngay_kt and b_ngay_hl<=b_ngayc then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_NGTD_KIEU_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Dan - Tra so hop dong
select nvl(min(kieu_hd),' ') into b_kq from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_NGTD_KIEU_HDd(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(1); b_so_idD number:=FBH_NGTD_SO_IDd(b_ma_dvi,b_so_id);
begin
-- Dan - Tra so hop dong
select nvl(min(kieu_hd),' ') into b_kq from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_idD;
return b_kq;
end;
/
create or replace function FBH_NGTD_SO_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Dan - Tra so hop dong
select min(so_hd) into b_kq from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_NGTD_SO_HDd(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50); b_so_idD number;
begin
-- Dan - Tra so hop dong dau
b_so_idD:=FBH_NGTD_SO_IDd(b_ma_dvi,b_so_id);
b_kq:=FBH_NGTD_SO_HD(b_ma_dvi,b_so_idD);
return b_kq;
end;
/
create or replace function FBH_NGTD_SO_ID(b_ma_dvi varchar2,b_so_hd varchar2,b_nv varchar2:='') return number
as
    b_kq number;
begin
-- Dan - Tra so id
if nvl(b_nv,' ')=' ' then 
    select nvl(min(so_id),0) into b_kq from bh_ngtd where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
else 
    select nvl(min(so_id),0) into b_kq from bh_ngtd where ma_dvi=b_ma_dvi and so_hd=b_so_hd and nv=b_nv;
end if;
return b_kq;
end;
/
create or replace function FBH_NGTD_ID_ID_DT(b_ma_dvi varchar2,b_so_id number,b_gcn varchar2) return number
as
    b_kq number;
begin
-- Dan - Tra so_id_dt
select nvl(min(so_id_dt),0) into b_kq from bh_ngtd_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and gcn=b_gcn;
return b_kq;
end;
/
create or replace function FBH_NGTD_ID_GCN(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return varchar2
as
    b_kq varchar2(20);
begin
-- Dan - Tra gcn
select min(gcn) into b_kq from bh_ngtd_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace function FBH_NGTD_HD_ID_DT(b_ma_dvi varchar2,b_so_hd number,b_gcn varchar2) return number
as
    b_kq number:=0; b_so_id number;
begin
-- Dan - Tra so id DT
b_so_id:=FBH_NGTD_SO_ID(b_ma_dvi,b_so_hd);
if b_so_id<>0 then b_kq:=FBH_NGTD_ID_ID_DT(b_ma_dvi,b_so_id,b_gcn); end if;
return b_kq;
end;
/
create or replace function FBH_NGTD_SO_IDd(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Dan - Tra so id dau
select nvl(min(so_id_d),0) into b_kq from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_NGTD_HD_SO_IDd(b_ma_dvi varchar2,b_so_hd varchar2) return number
as
    b_kq number;
begin
-- Dan - Tra so id dau
select nvl(min(so_id_d),0) into b_kq from bh_ngtd where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
return b_kq;
end;
/
create or replace function FBH_NGTD_SO_GCNd(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return number
as
    b_kq varchar2(20); b_so_idD number;
begin
-- Dan - Tra so GCN dau
b_so_idD:=FBH_NGTD_SO_IDd(b_ma_dvi,b_so_id);
select min(gcn) into b_kq from bh_ngtd_ds where ma_dvi=b_ma_dvi and so_id=b_so_idD and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace function FBH_NGTD_SO_IDc(b_ma_dvi varchar2,b_so_id number,b_ttrang varchar2:='K') return number
as
    b_kq number:=0; b_so_idD number:=b_so_id;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_NGTD_SO_IDd(b_ma_dvi,b_so_id);
if b_ttrang<>'C' then
    select nvl(max(so_id),0) into b_kq from bh_ngtd where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
else
    select nvl(max(so_id),0) into b_kq from bh_ngtd where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D';
end if;
return b_kq;
end;
/
create or replace function FBH_NGTD_HD_SO_IDc(b_ma_dvi varchar2,b_so_hd varchar2,b_ttrang varchar2:='K') return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_NGTD_HD_SO_IDd(b_ma_dvi,b_so_hd);
if b_ttrang<>'C' then
    select nvl(max(so_id),0) into b_kq from bh_ngtd where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
else
    select nvl(max(so_id),0) into b_kq from bh_ngtd where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D';
end if;
return b_kq;
end;
/
create or replace function FBH_NGTD_SO_IDb(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id 
b_so_idD:=FBH_NGTD_SO_IDd(b_ma_dvi,b_so_id);
select nvl(max(so_id),0) into b_kq from bh_ngtd where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D' and ngay_ht<=b_ngay;
return b_kq;
end;
/
create or replace function FBH_NGTD_HD_SO_IDb(
    b_ma_dvi varchar2,b_so_hd varchar2,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_NGTD_HD_SO_IDd(b_ma_dvi,b_so_hd);
select nvl(max(so_id),0) into b_kq from bh_ngtd where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D' and ngay_ht<=b_ngay;
return b_kq;
end;
/
create or replace procedure FBH_NGTD_HD_SO_ID_DT(
    b_gcn varchar2,b_ngay number,b_ma_dvi out varchar2,b_so_id out number,b_so_id_dt out number)
as
begin
-- Dan - Tra so id qua GCN
select min(ma_dvi),nvl(min(so_id),0),nvl(min(so_id_dt),0) into b_ma_dvi,b_so_id,b_so_id_dt from bh_ngtd_ds where gcn=b_gcn;
if b_so_id<>0 then b_so_id:=FBH_NGTD_SO_IDb(b_ma_dvi,b_so_id,b_ngay); end if;
end;
/
create or replace procedure FBH_NGTD_HD_SO_ID_DTd(
    b_gcn varchar2,b_ma_dvi out varchar2,b_so_id out number,b_so_id_dt out number)
as
begin
-- Dan - Tra so id dau qua GCN
select min(ma_dvi),nvl(min(so_id),0),nvl(min(so_id_dt),0) into b_ma_dvi,b_so_id,b_so_id_dt from bh_ngtd_ds where gcn=b_gcn;
if b_so_id<>0 then b_so_id:=FBH_NGTD_SO_IDd(b_ma_dvi,b_so_id); end if;
end;
/
create or replace procedure FBH_NGTD_SO_ID_DT(
    b_so_id_dt number,b_ma_dvi out varchar2,b_so_id out number,b_ngay number:=30000101)
as
begin
-- Dan - Tra so id cuoi qua so_id_dt
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_ngtd_ds where so_id_dt=b_so_id_dt;
if b_so_id<>0 then b_so_id:=FBH_NGTD_SO_IDb(b_ma_dvi,b_so_id,b_ngay); end if;
end;
/
create or replace procedure FBH_NGTD_SO_ID_DTd(
    b_so_id_dt number,b_ma_dvi out varchar2,b_so_id out number)
as
begin
-- Dan - Tra so id dau qua so_id_dt
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_ngtd_ds where so_id_dt=b_so_id_dt;
if b_so_id<>0 then b_so_id:=FBH_NGTD_SO_IDd(b_ma_dvi,b_so_id); end if;
end;
/

create or replace function FBH_NGTD_HD_NHOM(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(1);
begin
-- Dan - Tra nhom
select min(nv) into b_kq from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_id;
end;
/
create or replace function FBH_NGTD_NT_TIEN(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(5); b_so_idB number;
begin
-- Dan - Tra loai tien bao hiem
b_so_idB:=FBH_NGTD_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select nvl(min(nt_tien),'VND') into b_kq from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_idB;
return b_kq;
end;
/
create or replace function FBH_NGTD_NT_PHI(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(5); b_so_idB number;
begin
-- Dan - Tra loai tien phi
b_so_idB:=FBH_NGTD_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select nvl(min(nt_phi),'VND') into b_kq from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_idB;
return b_kq;
end;
/
create or replace function FBH_NGTD_CAP(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Dan - Tra ngay cap
select min(ngay_cap) into b_kq from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_NGTD_NGAY(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Dan - Tra nhap
select nvl(min(ngay_ht),0) into b_kq from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_NGTD_SO_IDp(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number:=0) return number
as
    b_kq number;
begin
-- Dan - Tra so_idP
if b_so_id_dt=0 then
    select min(so_idP) into b_kq from bh_ngtd_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    select min(so_idP) into b_kq from bh_ngtd_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
end if;
return b_kq;
end;
/
create or replace function FBH_NGTD_TTRANG(b_ma_dvi varchar2,b_so_id number,b_dk varchar2:='K',b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(1); b_i1 number;
begin
-- Dan - Tra ngay cap
select nvl(min(ttrang),'X') into b_kq from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_kq<>'X' and b_dk='C' then
    select count(*) into b_i1 from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay;
    if b_i1<>0 then b_kq:='H'; end if;
end if;
return b_kq;
end;
/
create or replace procedure PBH_NGTD_SO_ID_KTRA(b_ma_dvi varchar2,b_so_id_g number,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Kiem tra SO_ID moi nhap
if b_so_id_g=0 then b_loi:=''; return; end if;
select count(*) into b_i1 from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_id_g and ttrang<>'D';
if b_i1<>0 then b_loi:='loi:Hop dong cu da xoa hoac chua ky:loi'; return; end if;
select count(*) into b_i1 from bh_ngtd where ma_dvi=b_ma_dvi and so_id_g=b_so_id_g and kieu_hd<>'K';
if b_i1<>0 then b_loi:='loi:Hop dong cu da co bo sung, sua doi:loi'; return; end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
create or replace procedure PBH_NGTD_TTU(b_ma_dvi varchar2,b_so_id number)
as
    b_so_idD number; b_so_idC number;
begin
-- Dan - Tao tich tu
b_so_idD:=FBH_NGTD_SO_IDd(b_ma_dvi,b_so_id);
b_so_idC:=FBH_NGTD_SO_IDc(b_ma_dvi,b_so_idD,'D');
delete bh_ngtd_ttu where ma_dvi=b_ma_dvi and so_id=b_so_idD;
insert into bh_ngtd_ttu select distinct b_ma_dvi,b_so_idD,so_id_dt,min(ngay_hl),max(ngay_kt),max(ma_kh)
    from bh_ngtd_ds where ma_dvi=b_ma_dvi and so_id=b_so_idC and ma_kh<>' ';
end;
/
create or replace function FBH_NGTD_TTU(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return varchar2
AS
    b_kq varchar2(20);
begin
-- Dan - Tra ma tich tu
select nvl(min(ma_kh),' ') into b_kq from bh_ngtd_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
return b_kq;
end;
/   
CREATE OR REPLACE procedure PBH_NGTD_BS
    (b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_so_idD number;
    b_ma_dvi varchar2(10); b_so_id number; b_so_id_dt number; cs_lke clob;
begin
-- Dan - Liet ke sua doi theo doi tuong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id,so_id_dt');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id,b_so_id_dt using b_oraIn;
if b_so_id=0 then b_loi:='loi:GCN/Hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
b_so_idD:=FBH_NGTD_SO_IDd(b_ma_dvi,b_so_id);
select JSON_ARRAYAGG(obj) into cs_lke from
    (select json_object(ngay_ht,so_hd,gcn) obj from
        (select distinct a.ngay_ht,a.so_hd,b.gcn from bh_ngtd a,bh_ngtd_ds b
        where a.ma_dvi=b_ma_dvi and a.so_id_d=b_so_idD and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id and b.so_id_dt=b_so_id_dt order by a.ngay_ht,a.so_hd,b.gcn));
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGTD_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10);
    b_ngay_ht number; b_nv varchar2(1); b_klk varchar2(1); b_tu number; b_den number;
    b_dong number; cs_lke clob;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,nv,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_nv,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_ngtd where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ngtd where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','NG','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_ngtd where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ngtd  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong order by so_hd)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ngtd where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ngtd  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGTD_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10); b_so_hd varchar2(20);
    b_so_id number; b_ngay_ht number; b_nv varchar2(1); b_klk varchar2(1); b_trangKt number; b_tu number; b_den number;
    b_trang number; b_dong number; cs_lke clob;
begin
-- Dan - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,nv,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_nv,b_klk,b_trangKt using b_oraIn;
b_so_hd:=FBH_NGTD_SO_HD(b_ma_dvi,b_so_id);
if b_so_hd is null then b_loi:='loi:GCN, hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
if b_klk ='N' then
    select count(*) into b_dong from bh_ngtd where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_ngtd where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ngtd  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','NG','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_ngtd where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_ngtd where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ngtd  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong order by so_hd)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ngtd where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_ngtd where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ngtd  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGTD_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_so_id number; b_so_hd varchar2(20);b_nv varchar2(10);
    b_lenh varchar2(2000); b_loi varchar2(100);
begin
-- Dan - Hoi so ID qua so hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
b_lenh:=FKH_JS_LENH('so_hd,nv');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_nv using b_oraIn;
b_so_id:=FBH_NGTD_SO_ID(b_ma_dvi,b_so_hd,b_nv);
if b_so_id=0 then b_loi:='loi:So hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGTD_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(100); b_lenh varchar2(2000);
    b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36)); cs_lke clob:='';
    b_so_idD number; b_so_idC number; b_so_id_dt number; b_nv varchar2(1);
    b_ma_kh varchar2(20):=''; b_so_hd varchar2(20); b_ttrang varchar2(1);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ten nvarchar2(200); b_gioi varchar2(1); b_ng_sinh number; b_dong number;
    b_ngayD number; b_ngayC number; b_ngay_ht number; b_ttrangT varchar2(1);
    b_tu number; b_den number; b_qu varchar2(1); b_phong varchar2(10);
begin
-- viet anh
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,gioi,ng_sinh,so_hd,tu,den,');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrangT,b_cmt,b_mobi,b_email,b_ten,b_gioi,b_ng_sinh,b_so_hd,b_tu,b_den using b_oraIn;
b_ttrangT:=nvl(trim(b_ttrangT),' ');
b_so_hd:=nvl(trim(b_so_hd),' ');
b_ten:=upper(nvl(TRIM(b_ten), ' '));
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
-- them phan quyen
b_qu:=FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','NG','X');
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAf('','',b_cmt,b_mobi,b_email,b_gioi,b_ng_sinh);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    select count(*) into b_i1 from  (
        select distinct so_id_d from bh_ngtd a, bh_ngtd_ds b where
           a.so_id=b.so_id and a.ma_kh=b_ma_kh and a.ma_dvi=b_ma_dvi
           and a.ngay_ht between b_ngayD and b_ngayC and b_ttrangT in (' ',a.ttrang)
           and (b_ten = ' ' OR upper(a.ten) LIKE '%' || b_ten || '%')
           and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%'));
    if b_i1 > 500 then b_loi:='loi:Tim thay hon 500 ban ghi, them dieu kien tim kiem:loi'; raise PROGRAM_ERROR; end if;
    if b_i1 > 0 then insert into temp_1(n1)
        select distinct so_id_d from bh_ngtd a, bh_ngtd_ds b where
           a.so_id=b.so_id and a.ma_kh=b_ma_kh and a.ma_dvi=b_ma_dvi
           and a.ngay_ht between b_ngayD and b_ngayC and b_ttrangT in (' ',a.ttrang)
           and (b_ten = ' ' OR upper(a.ten) LIKE '%' || b_ten || '%')
           and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%');
    end if;
elsif b_ngayD between b_ngay and 30000101 then
    select count(*) into b_i1 from bh_ngtd a, bh_ngtd_ds b where
           a.so_id=b.so_id and a.ma_dvi=b_ma_dvi
           and a.ngay_ht between b_ngayD and b_ngayC and b_ttrangT in (' ',a.ttrang)
           and (b_ten = ' ' OR upper(a.ten) LIKE '%' || b_ten || '%')
           and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%');
    if b_i1 > 500 then b_loi:='loi:Tim thay hon 500 ban ghi, them dieu kien tim kiem:loi'; raise PROGRAM_ERROR; end if;
    if b_i1 > 0 then insert into temp_1(n1)
        select distinct so_id_d from bh_ngtd a, bh_ngtd_ds b where
           a.so_id=b.so_id and a.ma_dvi=b_ma_dvi
           and a.ngay_ht between b_ngayD and b_ngayC and b_ttrangT in (' ',a.ttrang)
           and (b_ten = ' ' OR upper(a.ten) LIKE '%' || b_ten || '%')
           and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%');
    end if;
end if;
for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
  b_so_idC:=FBH_NGTD_SO_IDc(b_ma_dvi,r_lp.so_id_d);
  select max(so_hd) into b_so_hd from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_idC;
     insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10,c10,c14)
        select t.so_hd,FBH_NGTD_TTRANG(b_ma_dvi,b_so_idC),t.ten,t.cmt,t.ngay_hl,t.ngay_kt,t.ngay_cap,b_so_idC,t.nv,gcn
            from bh_ngtd t, bh_ngtd_ds t1 where t.so_id=t1.so_id and t.ma_dvi=b_ma_dvi and t.so_id=b_so_idC;
end loop;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'ma_dvi' value b_ma_dvi,'so_id' value n10,'nv' value c10,
     'gcn' value c14) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n10 desc) as sott from ket_qua t
      ) where sott between b_tu and b_den);
select count(*) into b_dong from ket_qua;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGTD_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh varchar2,b_loi out varchar2)
AS
    b_ttrang varchar2(1); b_i1 number; b_so_idD number; b_so_idK number;  b_ksoat varchar2(20); b_nsdC varchar2(20);
begin
-- Dan - Xoa
select count(*) into b_i1 from bh_ngtd where so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select ttrang,so_id_d,so_id_kt,ttrang,ksoat,nsd into b_ttrang,b_so_idD,b_so_idK,b_ttrang,b_ksoat,b_nsdC
    from bh_ngtd where so_id=b_so_id;
if b_so_idK>0 then b_loi:='loi:Khong sua, xoa phuc hoi da hach toan ke toan:loi'; return; end if;
if b_nsdC<>b_nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
if trim(b_ksoat) is not null and b_ksoat<>b_nsd then b_loi:='loi:Khong sua, xoa GCN, hop dong da kiem soat:loi'; return; end if;
select count(*) into b_i1 from bh_ngtd where ma_dvi=b_ma_dvi and so_id_g=b_so_id;
if b_i1<>0 then b_loi:='loi:Khong sua, xoa GCN, hop dong da tao SDBS:loi'; return; end if;
if b_ttrang in('T','D') then
    PBH_NG_GOC_XOA(b_ma_dvi,b_nsd,b_so_id,b_nh,b_loi);
    if b_loi is not null then return; end if;
end if;
delete bh_hd_goc_ttindt where ma_dvi=b_ma_dvi and so_id=b_so_idD;
delete bh_ngtd_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ngtd_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ngtd_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ngtd_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ngtd_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_NGTD_XOA_XOA:loi'; end if;
end;
/
create or replace procedure PBH_NGTD_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_so_id number;
begin
-- Dan - Xoa GCN
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
PBH_NGTD_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'X',b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGTD_NV(b_ma_dvi varchar2,b_so_id number,
    a_lh_nv out pht_type.a_var,a_nt_tien out pht_type.a_var,
    a_nt_phi out pht_type.a_var,a_k_phi out pht_type.a_var,a_pt out pht_type.a_num,
    a_kphi out pht_type.a_var,a_k_thue out pht_type.a_var,a_c_thue out pht_type.a_var,
    a_t_suat out pht_type.a_num,a_tien out pht_type.a_num,a_phi out pht_type.a_num,
    a_thue out pht_type.a_num,a_ttoan out pht_type.a_num,a_phi_dt out pht_type.a_num,
    tt_ngay out pht_type.a_num,tt_ma_nt out pht_type.a_var,tt_tien out pht_type.a_num,
    a_ma_dtD out pht_type.a_var,a_lh_nvD out pht_type.a_var,a_nt_tienD out pht_type.a_var,
    a_tienD out pht_type.a_num,a_phiD out pht_type.a_num,b_loi out varchar2)
AS
    b_nt_tien varchar2(5):='VND'; b_nt_phi varchar2(5):='VND'; b_c_thue varchar2(1);
begin
-- Dan - Lay so lieu goc
b_loi:='loi:Loi lay so lieu goc:loi';
select c_thue into b_c_thue from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_id;
select lh_nv,b_nt_tien,b_nt_phi,'C','K','K',b_c_thue,t_suat,sum(tien),sum(phiG),sum(thue),sum(ttoan),sum(phi),max(pt)
    bulk collect into a_lh_nv,a_nt_tien,a_nt_phi,a_k_phi,a_kphi,a_k_thue,a_c_thue,a_t_suat,a_tien,a_phi,a_thue,a_ttoan,a_phi_dt,a_pt
    from bh_ngtd_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv,t_suat;
select ' ',lh_nv,b_nt_tien,sum(tien),sum(phiG) bulk collect into a_ma_dtD,a_lh_nvD,a_nt_tienD,a_tienD,a_phiD
    from bh_ngtd_ds a,bh_ngtd_dk b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and
    b.ma_dvi=b_ma_dvi and b.so_id=b_so_id and b.so_id_dt=a.so_id_dt and b.lh_nv<>' '  group by lh_nv;
select ngay,b_nt_phi,tien bulk collect into tt_ngay,tt_ma_nt,tt_tien from bh_ngtd_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
create or replace procedure PBH_NGTD_HDBS(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma_dvi varchar2(10); b_so_id number; b_so_idD number;
    b_dong number; cs_lke clob:='';
begin
-- Dan - Liet ke sua doi bo sung
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','PHH','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_so_idD:=FBH_NGTD_SO_IDd(b_ma_dvi,b_so_id);
if b_so_idD<>0 then       
    select count(*) into b_dong from bh_ngtd where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hd,ttoan,ttrang,ma_dvi,so_id,
           'ma_sdbs' value PKH_TEN_TENl(FBH_NGTD_TXT(ma_dvi,so_id,'ma_sdbs'))
    ) order by so_id desc returning clob)
        into cs_lke from bh_ngtd where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;  
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGTD_BPHId_THEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000);  b_i1 number;
    b_nhom varchar2(1); b_ma_sp varchar2(10); b_cdich varchar2(200); b_goi varchar2(200);
    b_ngay_hl number; b_ng_sinh number; b_so_id number; b_vu varchar2(10);
    b_dk_lt clob; a_ma_lt pht_type.a_var; a_ma_dk_lt pht_type.a_var; a_ten_lt pht_type.a_nvar; a_chon_lt pht_type.a_var;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tygia number; b_pt number; b_phi number;
    a_maDK pht_type.a_var; a_btDK pht_type.a_num;
begin
-- Dan - Tra so_id bieu phi theo dieu kien
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete temp_1;
b_lenh:=FKH_JS_LENH('nhom,ma_sp,cdich,goi,ngay_hl,ng_sinh,vu,nt_tien,nt_phi,tygia');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_ma_sp,b_cdich,b_goi,b_ngay_hl,b_ng_sinh,b_vu,b_nt_tien,b_nt_phi,b_tygia using b_oraIn;
b_ma_sp:=nvl(trim(b_ma_sp),' '); b_cdich:=PKH_MA_TENl(b_cdich); b_goi:=PKH_MA_TENl(b_goi);
b_nt_phi:=NVL(trim(b_nt_phi),'VND'); b_nt_tien:=NVL(trim(b_nt_tien),'VND');
b_tygia:=nvl(b_tygia,1);
if nvl(trim(b_nt_phi),'VND')='VND' and b_tygia<=0 then b_tygia:=1; end if;
b_so_id:=FBH_NGTD_BPHI_SO_IDh(b_nhom,b_ma_sp,b_cdich,b_goi,b_ng_sinh,b_ngay_hl);
b_oraOut:='';
if b_so_id<>0 then
    if b_vu='dk' then
        select ma,min(bt) bulk collect into a_maDK,a_btDK from bh_ngtd_phi_dk where so_id=b_so_id and lh_bh<>'M' group by ma;
        forall b_lp in 1..a_maDK.count
            insert into temp_1(c1,n1,n11,n12,n13) select a_maDK(b_lp),a_btDK(b_lp),tien,pt,phi from bh_ngtd_phi_dk where so_id=b_so_id and ma=a_maDK(b_lp) and bt=a_btDK(b_lp);
        commit;
        for r_lp in (select c1 ma,n1 bt,n11 tien from temp_1) loop
            FBH_NGTD_BPHI_DKm(b_so_id,r_lp.ma,r_lp.tien,'C',b_pt,b_phi,b_loi);
            if b_loi is not null then raise PROGRAM_ERROR; end if;
            update temp_1 set n12=b_pt,n13=b_phi where c1=r_lp.ma and n1=r_lp.bt;
        end loop;
            select JSON_ARRAYAGG(json_object(a.ma,ten,'tien' value case when b_nt_tien='VND' then b.n11 else round(b.n11/b_tygia,2) end, 'tienC' value b.n11,
            'ptB' value case when b_nt_phi<>'VND' then decode(sign(b.n12-100),1,round(b.n12/b_tygia,2),b.n12) else b.n12 end,
            'pt' value '',cap,tc,ma_ct,ma_dk,kieu,
            lh_nv,t_suat,lkeM,lkeP,lkeB,luy,a.bt,'ptk' value decode(sign(pt-99),1,'T','P'))
            order by a.bt returning clob) into b_oraOut from bh_ngtd_phi_dk a,temp_1 b where a.so_id=b_so_id and b.n1=a.bt order by a.bt;
    elsif b_vu='dkbs' then
      select JSON_ARRAYAGG(json_object(ma,ten,'tien' value case when b_nt_tien='VND' then tien else round(tien/b_tygia,2) end,'tienC' value tien,
                    'ptB' value case when b_nt_phi<>'VND' then decode(sign(pt-100),1,round(pt/b_tygia,4),pt) else pt end,
                    'pt' value '',ma_ct,tc,phi,cap,lh_nv,lkeM,ma_dk,ma_dkC,kieu,lkeP,lkeB,luy,bt,'ptk' value decode(sign(pt-99),1,'T','P')) order by bt,ma,ten returning clob) into b_oraOut from
            (select ma,ten,tien,pt,ma_ct,tc,phi,cap,lh_nv,lkeM,ma_dk,ma_dkC,kieu,lkeP,lkeB,luy,bt
                    from bh_ngtd_phi_dk where so_id=b_so_id and lh_bh='M');
    elsif b_vu='lt' then
      select count(*) into b_i1 from bh_ngtd_phi_txt where so_id=b_so_id and loai='dt_lt';
        if b_i1 >0 then
             select txt into b_dk_lt from bh_ngtd_phi_txt where so_id=b_so_id and loai='dt_lt';
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
    end if;
end if;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGTDC_PHIb(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_i2 number; b_iX number; b_lenh varchar2(1000);
    dt_ct clob; dt_dk clob; dt_dkbs clob;
    b_tp number:=0; b_nt_phi varchar2(5); b_nt_tien varchar2(5);
    b_so_hdG varchar2(20); b_ngay_hl number; b_ngay_kt number; b_ngay_cap number;
    b_tygia number:=1; b_ngay_hlC number; b_ngay_ktC number; b_kt number;
    b_phi number:=0; b_tien number; b_so_idG number:=0;

    dk_ma pht_type.a_var;dk_ten pht_type.a_nvar;dk_tc pht_type.a_var;
    dk_maG pht_type.a_var;dk_tienG pht_type.a_num;dk_ptG pht_type.a_num;
    dk_phiG pht_type.a_num;
    dk_ma_ct pht_type.a_var;dk_kieu pht_type.a_var;
    dk_lkeM pht_type.a_var;dk_lkeP pht_type.a_var;dk_lkeB pht_type.a_var;
    dk_luy pht_type.a_var;dk_ma_dk pht_type.a_var;dk_ma_dkC pht_type.a_var;
    dk_lh_nv pht_type.a_var;dk_t_suat pht_type.a_num;dk_cap pht_type.a_num;
    dk_tien pht_type.a_num;dk_pt pht_type.a_num;dk_phi pht_type.a_num;dk_ttoan pht_type.a_num;
    dk_ptB pht_type.a_num;dk_phiB pht_type.a_num;
    dk_pp pht_type.a_var;dk_ptk pht_type.a_var;dk_bt pht_type.a_num;

    dkbs_ma pht_type.a_var;dkbs_ten pht_type.a_nvar;dkbs_tc pht_type.a_var;
    dkbs_maG pht_type.a_var; dkbs_tienG pht_type.a_num; dkbs_ptG pht_type.a_num;
    dkbs_phiG pht_type.a_num;
    dkbs_ma_ct pht_type.a_var;dkbs_kieu pht_type.a_var;
    dkbs_lkeM pht_type.a_var;dkbs_lkeP pht_type.a_var;dkbs_lkeB pht_type.a_var;
    dkbs_luy pht_type.a_var;dkbs_ma_dk pht_type.a_var;dkbs_ma_dkC pht_type.a_var;
    dkbs_lh_nv pht_type.a_var;dkbs_t_suat pht_type.a_num;dkbs_cap pht_type.a_num;
    dkbs_tien pht_type.a_num;dkbs_pt pht_type.a_num;dkbs_phi pht_type.a_num;dkbs_ttoan pht_type.a_num;
    dkbs_ptB pht_type.a_num;dkbs_phiB pht_type.a_num;
    dkbs_pp pht_type.a_var;dkbs_ptk pht_type.a_var;dkbs_bt pht_type.a_num;
    
    a_ma pht_type.a_var;
    cs_dk clob; cs_dkbs clob; b_dk_txt clob; b_dkbs_txt clob;

begin
-- Nam - tinh phi prorata
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_dkbs');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_dkbs using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_dkbs);
b_lenh:=FKH_JS_LENH('so_hd_g,ngay_hl,ngay_kt,ngay_cap,nt_phi,nt_tien,tygia');
EXECUTE IMMEDIATE b_lenh into b_so_hdG,b_ngay_hl,b_ngay_kt,b_ngay_cap,b_nt_phi,b_nt_tien,b_tygia using dt_ct;
if b_so_hdG<>' ' then
    b_so_idG:=FBH_NGTD_SO_ID(b_ma_dvi,b_so_hdG);
    if b_so_idG=0 then b_loi:='loi:GCN goc da xoa:loi'; return; end if;
end if;
if b_tygia is null or b_tygia=0 then b_tygia:=1; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tien,ptb,pp,pt,phi,ttoan,cap,tc,ma_ct,ma_dk,ma_dkc,kieu,lh_nv,t_suat,phib,lkem,lkep,lkeb,ptk,luy,bt');
EXECUTE IMMEDIATE b_lenh bulk collect into dk_ma,dk_ten,dk_tien,dk_ptB,dk_pp,dk_pt,dk_phi,dk_ttoan,dk_cap,dk_tc,dk_ma_ct,
        dk_ma_dk,dk_ma_dkC,dk_kieu,dk_lh_nv,dk_t_suat,dk_phiB,dk_lkeM,dk_lkeP,dk_lkeB,dk_ptk,dk_luy,dk_bt using dt_dk;
if dk_ma.count=0 then b_loi:='loi:Nhap so tien bao hiem:loi'; return; end if;
if trim(dt_dkbs) is not null then
  EXECUTE IMMEDIATE b_lenh bulk collect into dkbs_ma,dkbs_ten,dkbs_tien,dkbs_ptB,dkbs_pp,dkbs_pt,dkbs_phi,dkbs_ttoan,dkbs_cap,dkbs_tc,dkbs_ma_ct,
        dkbs_ma_dk,dkbs_ma_dkC,dkbs_kieu,dkbs_lh_nv,dkbs_t_suat,dkbs_phiB,dkbs_lkeM,dkbs_lkeP,dkbs_lkeB,dkbs_ptk,dkbs_luy,dkbs_bt using dt_dkbs;
end if;
if b_nt_phi<>'VND' then b_tp:=2; end if;
b_kt:=0;
for b_lp_dk in 1..dk_ma.count loop
  b_kt:=b_kt+1;
  a_ma(b_kt):=dk_ma(b_lp_dk);  dk_pp(b_lp_dk):=nvl(dk_pp(b_lp_dk),' ');
  if dk_lkeP(b_lp_dk) not in ('T','N','K') then
      if dk_ptk(b_lp_dk)<>'P' then
          if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
             dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) / b_tygia ,b_tp);
          elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
             dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) * b_tygia ,b_tp);
          else
             dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) ,b_tp);
          end if;
       elsif dk_ptk(b_lp_dk)<>'T' and dk_tien(b_lp_dk)<>0 and dk_ptB(b_lp_dk)<>0 then
          if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
             dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk)* dk_tien(b_lp_dk) / b_tygia / 100,b_tp);
          elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
             dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk)* dk_tien(b_lp_dk) * b_tygia / 100,b_tp);
          else
             dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk)* dk_tien(b_lp_dk) / 100,b_tp);
          end if;
       else dk_phiB(b_lp_dk):=0;
      end if;
      if dk_pp(b_lp_dk) = 'DG' and dk_pt(b_lp_dk)>0 then dk_phi(b_lp_dk):=ROUND(dk_pt(b_lp_dk),b_tp);
      elsif dk_pp(b_lp_dk) = 'DP' and dk_tien(b_lp_dk)<>0 and dk_pt(b_lp_dk)<>0 then
           dk_phi(b_lp_dk):=ROUND(dk_pt(b_lp_dk) * dk_tien(b_lp_dk) / 100,b_tp);
      elsif dk_phiB(b_lp_dk)<>0 then
           dk_phi(b_lp_dk):=dk_phiB(b_lp_dk);
        if dk_pp(b_lp_dk) = 'GG' then
             dk_phi(b_lp_dk):=ROUND((dk_phi(b_lp_dk)-dk_pt(b_lp_dk)),b_tp);
        elsif dk_pp(b_lp_dk) = 'GT' and dk_tien(b_lp_dk)<>0 and dk_pt(b_lp_dk)<>0 then
             dk_phi(b_lp_dk):= dk_phi(b_lp_dk) - ROUND(dk_pt(b_lp_dk) * dk_tien(b_lp_dk) / 100,b_tp);
        elsif dk_pp(b_lp_dk) = 'GP' and dk_pt(b_lp_dk)<>0 then
             dk_phi(b_lp_dk):= dk_phi(b_lp_dk) - ROUND(dk_pt(b_lp_dk)*dk_phiB(b_lp_dk)/ 100,b_tp);
        if dk_phi(b_lp_dk)<0 then dk_phi(b_lp_dk):=0; end if;
        end if;
      elsif dk_phiB(b_lp_dk)=0 then dk_phi(b_lp_dk):=0;
      end if;
      if dk_phiB(b_lp_dk)=0 then dk_phiB(b_lp_dk):=dk_phi(b_lp_dk); end if;
  end if;
end loop;

for b_lp_dkbs in 1..dkbs_ma.count loop
  b_kt:=b_kt+1;
  a_ma(b_kt):=dkbs_ma(b_lp_dkbs); dkbs_pp(b_lp_dkbs):=nvl(dkbs_pp(b_lp_dkbs),' ');
  if dkbs_lkeP(b_lp_dkbs) not in ('T','N','K') then
      if dkbs_ptk(b_lp_dkbs)<>'P' then
        if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
           dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs) / b_tygia ,b_tp);
        elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
           dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs) * b_tygia ,b_tp);
        else
           dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs) ,b_tp);
        end if;
     elsif dkbs_ptk(b_lp_dkbs)<>'T' and dkbs_tien(b_lp_dkbs)<>0 and dkbs_ptB(b_lp_dkbs)<>0 then
        if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
           dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs)* dkbs_tien(b_lp_dkbs) / b_tygia / 100,b_tp);
        elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
           dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs)* dkbs_tien(b_lp_dkbs) * b_tygia / 100,b_tp);
        else
           dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs)* dkbs_tien(b_lp_dkbs) / 100,b_tp);
        end if;
     else dkbs_phiB(b_lp_dkbs):=0;
     end if;
    if dkbs_pp(b_lp_dkbs) = 'DG' and dkbs_pt(b_lp_dkbs)>0 then
        dkbs_phi(b_lp_dkbs):=ROUND(dkbs_pt(b_lp_dkbs),b_tp);
    elsif dkbs_pp(b_lp_dkbs) = 'DP' and dkbs_tien(b_lp_dkbs)<>0 and dkbs_pt(b_lp_dkbs)<>0 then
        dkbs_phi(b_lp_dkbs):=ROUND(dkbs_pt(b_lp_dkbs)*dkbs_tien(b_lp_dkbs) / 100,b_tp);
    elsif dkbs_phiB(b_lp_dkbs)<>0 then
        dkbs_phi(b_lp_dkbs):=dkbs_phiB(b_lp_dkbs);
      if dkbs_pp(b_lp_dkbs) = 'GG' then
        dkbs_phi(b_lp_dkbs):=ROUND((dkbs_phi(b_lp_dkbs)-dkbs_pt(b_lp_dkbs)),b_tp);
      elsif dkbs_pp(b_lp_dkbs) = 'GT' and dkbs_tien(b_lp_dkbs)<>0 and dkbs_pt(b_lp_dkbs)<>0 then
        dkbs_phi(b_lp_dkbs):= dkbs_phi(b_lp_dkbs) - ROUND(dkbs_pt(b_lp_dkbs)*dkbs_tien(b_lp_dkbs) / 100,b_tp);
      elsif dkbs_pp(b_lp_dkbs) = 'GP' and dkbs_pt(b_lp_dkbs)<>0 then
        dkbs_phi(b_lp_dkbs):= dkbs_phi(b_lp_dkbs) - ROUND(dkbs_pt(b_lp_dkbs)*dkbs_phiB(b_lp_dkbs)/ 100,b_tp);
      if dkbs_phi(b_lp_dkbs)<0 then dkbs_phi(b_lp_dkbs):=0; end if;
      end if;
    elsif dkbs_phiB(b_lp_dkbs)=0 then dkbs_phi(b_lp_dkbs):=0;
    end if;
    if dkbs_phiB(b_lp_dkbs)=0 then dkbs_phiB(b_lp_dkbs):=dkbs_phi(b_lp_dkbs); end if;
  end if;
end loop;
if b_so_idG<>0 and b_ngay_hl<b_ngay_cap then
    select ngay_hl,ngay_kt into b_ngay_hlC,b_ngay_ktC from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_idG;
    b_i1:=FKH_KHO_NGSO(b_ngay_cap,b_ngay_ktC)/FKH_KHO_NGSO(b_ngay_hlC,b_ngay_ktC);
    b_i2:=FKH_KHO_NGSO(b_ngay_cap,b_ngay_kt)/FKH_KHO_NGSO(b_ngay_hl,b_ngay_kt);
    b_i1:=round(b_i1,2); b_i2:=round(b_i2,2);
    select ma,tien,pt,phi bulk collect into dk_maG,dk_tienG,dk_ptG,dk_phiG from bh_ngtd_dk
        where ma_dvi=b_ma_dvi and so_id=b_so_idG and lh_bh<>'M' order by bt;
    select ma,tien,pt,phi bulk collect into dkbs_maG,dkbs_tienG,dkbs_ptG,dkbs_phiG from bh_ngtd_dk
        where ma_dvi=b_ma_dvi and so_id=b_so_idG and lh_bh<>'C' order by bt;
    for b_lp in 1..dk_maG.count loop
        b_iX:=b_lp; b_tien:=0;
        for b_lp1 in reverse 1..b_iX loop
            if dk_tienG(b_lp1)<>0 then b_tien:=dk_tienG(b_lp1); exit; end if;
        end loop;
        b_iX:=FKH_ARR_VTRI(dk_ma,dk_maG(b_lp));
        if b_iX=0 or b_tien=0 then continue; end if;
        b_phi:=b_tien*dk_ptG(b_lp)/100;
        b_phi:=dk_phiG(b_lp)-round(b_phi*b_i1,b_tp);               -- Phi da dung
        if dk_pp(b_iX)<>'DG' then
           dk_phi(b_iX):=b_phi+round(dk_phi(b_iX)*b_i2,b_tp);      -- Phi con lai: round(dk_phi(b_iX)*b_i2,b_tp);
        end if;
    end loop;
    for b_lp in 1..dkbs_maG.count loop
        b_iX:=b_lp; b_tien:=0;
        for b_lp1 in reverse 1..b_iX loop
            if dkbs_tienG(b_lp1)<>0 then b_tien:=dkbs_tienG(b_lp1); exit; end if;
        end loop;
        b_iX:=FKH_ARR_VTRI(dkbs_ma,dkbs_maG(b_lp));
        if b_iX=0 or b_tien=0 then continue; end if;
        b_phi:=b_tien*dkbs_ptG(b_lp)/100;
        b_phi:=dkbs_phiG(b_lp)-round(b_phi*b_i1,b_tp);                 -- Phi da dung
        if dkbs_pp(b_iX)<>'DG' then
           dkbs_phi(b_iX):=b_phi+round(dkbs_phi(b_iX)*b_i2,b_tp);      -- Phi con lai: round(dk_phi(b_iX)*b_i2,b_tp);
        end if;
    end loop;
end if;
b_oraOut:='';
for b_lp in 1..dk_ma.count loop
    select json_object('ma' value dk_ma(b_lp),'ten' value dk_ten(b_lp),'tc' value dk_tc(b_lp),'ma_ct' value dk_ma_ct(b_lp),
    'kieu' value dk_kieu(b_lp),'lkeM' value dk_lkeM(b_lp),'lkeP' value dk_lkeP(b_lp),'lkeB' value dk_lkeB(b_lp),
    'luy' value dk_luy(b_lp),'ma_dk' value dk_ma_dk(b_lp),'ma_dkC' value dk_ma_dkC(b_lp),
    'lh_nv' value dk_lh_nv(b_lp),'t_suat' value dk_t_suat(b_lp),'cap' value dk_cap(b_lp),
    'pp' value dk_pp(b_lp),'ptK' value dk_ptk(b_lp),'bt' value dk_bt(b_lp),
    'tien' value dk_tien(b_lp),'pt' value dk_pt(b_lp),
    'phi' value dk_phi(b_lp),'ttoan' value dk_ttoan(b_lp),
    'ptB' value dk_ptB(b_lp),'phiB' value dk_phiB(b_lp) returning clob) into b_dk_txt from dual;
    if b_lp>1 then cs_dk:=cs_dk||','; end if;
    cs_dk:=cs_dk||b_dk_txt;
end loop;
if cs_dk is not null then cs_dk:='['||cs_dk||']'; end if;
for b_lp in 1..dkbs_ma.count loop
    select json_object('ma' value dkbs_ma(b_lp),'ten' value dkbs_ten(b_lp),'tc' value dkbs_tc(b_lp),'ma_ct' value dkbs_ma_ct(b_lp),
    'kieu' value dkbs_kieu(b_lp),'lkeM' value dkbs_lkeM(b_lp),'lkeP' value dkbs_lkeP(b_lp),'lkeB' value dkbs_lkeB(b_lp),
    'luy' value dkbs_luy(b_lp),'ma_dk' value dkbs_ma_dk(b_lp),'ma_dkC' value dkbs_ma_dkC(b_lp),
    'lh_nv' value dkbs_lh_nv(b_lp),'t_suat' value dkbs_t_suat(b_lp),'cap' value dkbs_cap(b_lp),
    'pp' value dkbs_pp(b_lp),'ptK' value dkbs_ptk(b_lp),'bt' value dkbs_bt(b_lp),
    'tien' value dkbs_tien(b_lp),'pt' value dkbs_pt(b_lp),
    'phi' value dkbs_phi(b_lp),'ttoan' value dkbs_ttoan(b_lp),
    'ptB' value dkbs_ptB(b_lp),'phiB' value dkbs_phiB(b_lp) returning clob) into b_dkbs_txt from dual;
    if b_lp>1 then cs_dkbs:=cs_dkbs||','; end if;
    cs_dkbs:=cs_dkbs||b_dkbs_txt;
end loop;
if cs_dkbs is not null then cs_dkbs:='['||cs_dkbs||']'; end if;
select json_object('dt_dk' value cs_dk,'dt_dkbs' value cs_dkbs returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;


