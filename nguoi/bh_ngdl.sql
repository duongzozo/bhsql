create or replace function FBH_NGDL_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_id number; b_txt clob;
    a_ds_ct pht_type.a_clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
select count(*) into b_i1 from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
	select txt into b_txt from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
	PKH_JS_BONH(b_txt); b_kq:=FKH_JS_GTRIs(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_NGDL_TXTn(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return number
AS
    b_kq number:=0; b_i1 number; b_id number; b_txt clob; b_lenh varchar2(1000);
    a_ds_ct pht_type.a_clob;
begin
-- Dan - Tra gia tri num trong txt
select count(*) into b_i1 from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    PKH_JS_BONH(b_txt); b_kq:=FKH_JS_GTRIn(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_DL_SO_ID_NHOM(b_ma_dvi varchar2,b_so_id number,b_nhom varchar2) return number
AS
    b_kq number;
begin
-- Dan - Tra so ID nhom
select nvl(min(so_id_nh),0) into b_kq from bh_ngdl_nh where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom;
return b_kq;
end;
/
create or replace function FBH_NGDL_NV(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Kiem tra hieu luc
select min(nv) into b_kq from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure FBH_NGDL_DT_NGd(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay_hld out date,b_ngay_ktd out date)
AS
    b_ngay_hl number; b_ngay_kt number;
begin
-- Dan - Ngay hieu luc, ngay ket thuc doi tuong
select nvl(min(ngay_hl),0),nvl(min(ngay_kt),0) into b_ngay_hl,b_ngay_kt from bh_ngdl_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
if b_ngay_hl=0 then
    select nvl(min(ngay_hl),0),nvl(min(ngay_kt),0) into b_ngay_hl,b_ngay_kt from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
b_ngay_hld:=PKH_SO_CDT(b_ngay_hl); b_ngay_ktd:=PKH_SO_CDT(b_ngay_kt);
end;
/
create or replace function FBH_NGDL_HL(b_ma_dvi varchar2,b_so_id number,b_ngay number,b_ngayd number,b_ngayc number) return varchar2
AS
    b_so_idB number; b_ngay_hl number; b_ngay_kt number; b_kq varchar2(1):='K';
begin
-- Dan - Kiem tra hieu luc
b_so_idB:=FBH_NGDL_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_idB;
if b_ngayd<=b_ngay_kt and b_ngay_hl<=b_ngayc then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_NGDL_KIEU_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Dan - Tra so hop dong
select nvl(min(kieu_hd),' ') into b_kq from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_NGDL_KIEU_HDd(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(1); b_so_idD number:=FBH_NGDL_SO_IDd(b_ma_dvi,b_so_id);
begin
-- Dan - Tra so hop dong
select nvl(min(kieu_hd),' ') into b_kq from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_idD;
return b_kq;
end;
/
create or replace function FBH_NGDL_SO_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Dan - Tra so hop dong
select min(so_hd) into b_kq from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_NGDL_SO_HDd(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50); b_so_idD number;
begin
-- Dan - Tra so hop dong dau
b_so_idD:=FBH_NGDL_SO_IDd(b_ma_dvi,b_so_id);
b_kq:=FBH_NGDL_SO_HD(b_ma_dvi,b_so_idD);
return b_kq;
end;
/
create or replace function FBH_NGDL_SO_ID(b_ma_dvi varchar2,b_so_hd varchar2,b_nv varchar2:='') return number
as
    b_kq number;
begin
-- Dan - Tra so id
if nvl(b_nv,' ')=' ' then 
    select nvl(min(so_id),0) into b_kq from bh_ngdl where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
else 
    select nvl(min(so_id),0) into b_kq from bh_ngdl where ma_dvi=b_ma_dvi and so_hd=b_so_hd and nv=b_nv;
end if;
return b_kq;
end;
/
create or replace function FBH_NGDL_ID_ID_DT(b_ma_dvi varchar2,b_so_id number,b_gcn varchar2) return number
as
    b_kq number;
begin
-- Dan - Tra so_id_dt
select nvl(min(so_id_dt),0) into b_kq from bh_ngdl_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and gcn=b_gcn;
return b_kq;
end;
/
create or replace function FBH_NGDL_ID_GCN(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return varchar2
as
    b_kq varchar2(20);
begin
-- Dan - Tra gcn
select min(gcn) into b_kq from bh_ngdl_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace function FBH_NGDL_HD_ID_DT(b_ma_dvi varchar2,b_so_hd number,b_gcn varchar2) return number
as
    b_kq number:=0; b_so_id number;
begin
-- Dan - Tra so id DT
b_so_id:=FBH_NGDL_SO_ID(b_ma_dvi,b_so_hd);
if b_so_id<>0 then b_kq:=FBH_NGDL_ID_ID_DT(b_ma_dvi,b_so_id,b_gcn); end if;
return b_kq;
end;
/
create or replace function FBH_NGDL_SO_IDd(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Dan - Tra so id dau
select nvl(min(so_id_d),0) into b_kq from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_NGDL_HD_SO_IDd(b_ma_dvi varchar2,b_so_hd varchar2) return number
as
    b_kq number;
begin
-- Dan - Tra so id dau
select nvl(min(so_id_d),0) into b_kq from bh_ngdl where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
return b_kq;
end;
/
create or replace function FBH_NGDL_SO_GCNd(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return number
as
    b_kq varchar2(20); b_so_idD number;
begin
-- Dan - Tra so GCN dau
b_so_idD:=FBH_NGDL_SO_IDd(b_ma_dvi,b_so_id);
select min(gcn) into b_kq from bh_ngdl_ds where ma_dvi=b_ma_dvi and so_id=b_so_idD and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace function FBH_NGDL_SO_IDc(b_ma_dvi varchar2,b_so_id number,b_ttrang varchar2:='K') return number
as
    b_kq number:=0; b_so_idD number:=b_so_id;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_NGDL_SO_IDd(b_ma_dvi,b_so_id);
if b_ttrang<>'C' then
    select nvl(max(so_id),0) into b_kq from bh_ngdl where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
else
    select nvl(max(so_id),0) into b_kq from bh_ngdl where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D';
end if;
return b_kq;
end;
/
create or replace function FBH_NGDL_HD_SO_IDc(b_ma_dvi varchar2,b_so_hd varchar2,b_ttrang varchar2:='K') return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_NGDL_HD_SO_IDd(b_ma_dvi,b_so_hd);
if b_ttrang<>'C' then
    select nvl(max(so_id),0) into b_kq from bh_ngdl where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
else
    select nvl(max(so_id),0) into b_kq from bh_ngdl where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D';
end if;
return b_kq;
end;
/
create or replace function FBH_NGDL_SO_IDb(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id 
b_so_idD:=FBH_NGDL_SO_IDd(b_ma_dvi,b_so_id);
select nvl(max(so_id),0) into b_kq from bh_ngdl where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D' and ngay_ht<=b_ngay;
return b_kq;
end;
/
create or replace function FBH_NGDL_HD_SO_IDb(
    b_ma_dvi varchar2,b_so_hd varchar2,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_NGDL_HD_SO_IDd(b_ma_dvi,b_so_hd);
select nvl(max(so_id),0) into b_kq from bh_ngdl where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D' and ngay_ht<=b_ngay;
return b_kq;
end;
/
create or replace procedure FBH_NGDL_HD_SO_ID_DT(
    b_gcn varchar2,b_ngay number,b_ma_dvi out varchar2,b_so_id out number,b_so_id_dt out number)
as
begin
-- Dan - Tra so id qua GCN
select min(ma_dvi),nvl(min(so_id),0),nvl(min(so_id_dt),0) into b_ma_dvi,b_so_id,b_so_id_dt from bh_ngdl_ds where gcn=b_gcn;
if b_so_id<>0 then b_so_id:=FBH_NGDL_SO_IDb(b_ma_dvi,b_so_id,b_ngay); end if;
end;
/
create or replace procedure FBH_NGDL_HD_SO_ID_DTd(
    b_gcn varchar2,b_ma_dvi out varchar2,b_so_id out number,b_so_id_dt out number)
as
begin
-- Dan - Tra so id dau qua GCN
select min(ma_dvi),nvl(min(so_id),0),nvl(min(so_id_dt),0) into b_ma_dvi,b_so_id,b_so_id_dt from bh_ngdl_ds where gcn=b_gcn;
if b_so_id<>0 then b_so_id:=FBH_NGDL_SO_IDd(b_ma_dvi,b_so_id); end if;
end;
/
create or replace procedure FBH_NGDL_SO_ID_DT(
    b_so_id_dt number,b_ma_dvi out varchar2,b_so_id out number,b_ngay number:=30000101)
as
begin
-- Dan - Tra so id cuoi qua so_id_dt
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_ngdl_ds where so_id_dt=b_so_id_dt;
if b_so_id<>0 then b_so_id:=FBH_NGDL_SO_IDb(b_ma_dvi,b_so_id,b_ngay); end if;
end;
/
create or replace procedure FBH_NGDL_SO_ID_DTd(
    b_so_id_dt number,b_ma_dvi out varchar2,b_so_id out number)
as
begin
-- Dan - Tra so id dau qua so_id_dt
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_ngdl_ds where so_id_dt=b_so_id_dt;
if b_so_id<>0 then b_so_id:=FBH_NGDL_SO_IDd(b_ma_dvi,b_so_id); end if;
end;
/

create or replace function FBH_NGDL_HD_NHOM(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(1);
begin
-- Dan - Tra nhom
select min(nv) into b_kq from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_id;
end;
/
create or replace function FBH_NGDL_NT_TIEN(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(5); b_so_idB number;
begin
-- Dan - Tra loai tien bao hiem
b_so_idB:=FBH_NGDL_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select nvl(min(nt_tien),'VND') into b_kq from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_idB;
return b_kq;
end;
/
create or replace function FBH_NGDL_NT_PHI(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(5); b_so_idB number;
begin
-- Dan - Tra loai tien phi
b_so_idB:=FBH_NGDL_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select nvl(min(nt_phi),'VND') into b_kq from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_idB;
return b_kq;
end;
/
create or replace function FBH_NGDL_CAP(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Dan - Tra ngay cap
select min(ngay_cap) into b_kq from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_NGDL_NGAY(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Dan - Tra nhap
select nvl(min(ngay_ht),0) into b_kq from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_NGDL_SO_IDp(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number:=0) return number
as
    b_kq number;
begin
-- Dan - Tra so_idP
if b_so_id_dt=0 then
    select min(so_idP) into b_kq from bh_ngdl_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    select min(so_idP) into b_kq from bh_ngdl_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
end if;
return b_kq;
end;
/
create or replace function FBH_NGDL_TTRANG(b_ma_dvi varchar2,b_so_id number,b_dk varchar2:='K',b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(1); b_i1 number;
begin
-- Dan - Tra ngay cap
select nvl(min(ttrang),'X') into b_kq from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_kq<>'X' and b_dk='C' then
    select count(*) into b_i1 from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay;
    if b_i1<>0 then b_kq:='H'; end if;
end if;
return b_kq;
end;
/
create or replace procedure PBH_NGDL_SO_ID_KTRA(b_ma_dvi varchar2,b_so_id_g number,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Kiem tra SO_ID moi nhap
if b_so_id_g=0 then b_loi:=''; return; end if;
select count(*) into b_i1 from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_id_g and ttrang<>'D';
if b_i1<>0 then b_loi:='loi:Hop dong cu da xoa hoac chua ky:loi'; return; end if;
select count(*) into b_i1 from bh_ngdl where ma_dvi=b_ma_dvi and so_id_g=b_so_id_g and kieu_hd<>'K';
if b_i1<>0 then b_loi:='loi:Hop dong cu da co bo sung, sua doi:loi'; return; end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_NGDL_TTU(b_ma_dvi varchar2,b_so_id number)
as
    b_so_idD number; b_so_idC number;
begin
-- Dan - Tao tich tu
b_so_idD:=FBH_NGDL_SO_IDd(b_ma_dvi,b_so_id);
b_so_idC:=FBH_NGDL_SO_IDc(b_ma_dvi,b_so_idD,'D');
delete bh_ngdl_ttu where ma_dvi=b_ma_dvi and so_id=b_so_idD;
insert into bh_ngdl_ttu select distinct b_ma_dvi,b_so_idD,so_id_dt,min(ngay_hl),max(ngay_kt),max(ma_chuyen)
    from bh_ngdl_ds where ma_dvi=b_ma_dvi and so_id=b_so_idC and ma_chuyen<>' ';
end;
/
create or replace function FBH_NGDL_TTU(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return varchar2
AS
    b_kq varchar2(20);
begin
-- Dan - Tra ma tich tu
select nvl(min(ma_chuyen),' ') into b_kq from bh_ngdl_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
return b_kq;
end;
/   
CREATE OR REPLACE procedure PBH_NGDL_BS
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
b_so_idD:=FBH_NGDL_SO_IDd(b_ma_dvi,b_so_id);
select JSON_ARRAYAGG(obj) into cs_lke from
    (select json_object(ngay_ht,so_hd,gcn) obj from
        (select distinct a.ngay_ht,a.so_hd,b.gcn from bh_ngdl a,bh_ngdl_ds b
        where a.ma_dvi=b_ma_dvi and a.so_id_d=b_so_idD and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id and b.so_id_dt=b_so_id_dt order by a.ngay_ht,a.so_hd,b.gcn));
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGDL_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10); b_dsach varchar2(1);
    b_ngay_ht number; b_nv varchar2(1); b_klk varchar2(1); b_tu number; b_den number;
    b_dong number; cs_lke clob;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,nv,klk,tu,den,dsach');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_nv,b_klk,b_tu,b_den,b_dsach using b_oraIn;
b_dsach:=nvl(trim(b_dsach),'C');
if b_klk='N' then
    select count(*) into b_dong from bh_ngdl where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd and dsach=b_dsach;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ngdl where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd and dsach=b_dsach order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','NG','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_ngdl where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong and dsach=b_dsach;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ngdl  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong and dsach=b_dsach order by so_hd)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ngdl where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and dsach=b_dsach;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ngdl  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and dsach=b_dsach order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGDL_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10); b_so_hd varchar2(20); b_dsach varchar2(1);
    b_so_id number; b_ngay_ht number; b_nv varchar2(1); b_klk varchar2(1); b_trangKt number; b_tu number; b_den number;
    b_trang number; b_dong number; cs_lke clob;
begin
-- Dan - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,nv,klk,trangkt,dsach');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_nv,b_klk,b_trangKt,b_dsach using b_oraIn;
b_so_hd:=FBH_NGDL_SO_HD(b_ma_dvi,b_so_id);
if b_so_hd is null then b_loi:='loi:GCN, hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
if nvl(b_dsach,' ') = ' ' then b_dsach:='C'; end if; 
if b_klk ='N' then
    select count(*) into b_dong from bh_ngdl where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd and dsach=b_dsach;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_ngdl where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd and dsach=b_dsach order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ngdl  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd and dsach=b_dsach order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','NG','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_ngdl where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong and dsach=b_dsach;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_ngdl where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong and dsach=b_dsach order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ngdl  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong and dsach=b_dsach order by so_hd)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ngdl where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and dsach=b_dsach;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_ngdl where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and dsach=b_dsach order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ngdl  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and dsach=b_dsach order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGDL_SO_ID(
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
b_so_id:=FBH_NGDL_SO_ID(b_ma_dvi,b_so_hd,b_nv);
if b_so_id=0 then b_loi:='loi:So hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGDL_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh varchar2,b_loi out varchar2)
AS
    b_ttrang varchar2(1); b_i1 number; b_so_idD number; b_so_idK number; b_ksoat varchar2(20); b_nsdC varchar2(20);
begin
-- Dan - Xoa
select count(*),min(ttrang),min(so_id_d) into b_i1,b_ttrang,b_so_idD
    from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
if b_so_idK>0 then b_loi:='loi:Khong sua, xoa phuc hoi da hach toan ke toan:loi'; return; end if;
if b_nsdC<>b_nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
if trim(b_ksoat) is not null and b_ksoat<>b_nsd then b_loi:='loi:Khong sua, xoa GCN, hop dong da kiem soat:loi'; return; end if;
select count(*) into b_i1 from bh_ngdl where ma_dvi=b_ma_dvi and so_id_g=b_so_id;
if b_i1<>0 then b_loi:='loi:Khong sua, xoa GCN, hop dong da tao SDBS:loi'; return; end if;
if b_ttrang in('T','D') then
    PBH_NG_GOC_XOA(b_ma_dvi,b_nsd,b_so_id,b_nh,b_loi);
    if b_loi is not null then return; end if;
end if;
delete bh_hd_goc_ttindt where ma_dvi=b_ma_dvi and so_id=b_so_idD;
delete bh_ngdl_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ngdl_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ngdl_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ngdl_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ngdl_nh where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_NGDL_XOA_XOA:loi'; end if;
end;
/
create or replace procedure PBH_NGDL_XOA(
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
PBH_NGDL_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'X',b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGDL_NV(b_ma_dvi varchar2,b_so_id number,
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
select c_thue into b_c_thue from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_id;
select lh_nv,b_nt_tien,b_nt_phi,'C','K','K',b_c_thue,t_suat,sum(tien),sum(phiG),sum(thue),sum(ttoan),sum(phi),max(pt)
    bulk collect into a_lh_nv,a_nt_tien,a_nt_phi,a_k_phi,a_kphi,a_k_thue,a_c_thue,a_t_suat,a_tien,a_phi,a_thue,a_ttoan,a_phi_dt,a_pt
    from bh_ngdl_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv,t_suat;
select ' ',lh_nv,b_nt_tien,sum(tien),sum(phiG) bulk collect into a_ma_dtD,a_lh_nvD,a_nt_tienD,a_tienD,a_phiD
    from bh_ngdl_ds a,bh_ngdl_dk b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and
    b.ma_dvi=b_ma_dvi and b.so_id=b_so_id and b.so_id_dt=a.so_id_dt and b.lh_nv<>' '  group by lh_nv;
select ngay,b_nt_phi,tien bulk collect into tt_ngay,tt_ma_nt,tt_tien from bh_ngdl_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_NGDL_HDBS(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma_dvi varchar2(10); b_so_id number; b_so_idD number;
    b_dong number; cs_lke clob:='';
begin
-- viet anh - Liet ke sua doi bo sung
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_so_idD:=FBH_NGDL_SO_IDd(b_ma_dvi,b_so_id);
if b_so_idD<>0 then 
    select count(*) into b_dong from bh_ngdl where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hd,ttoan,ttrang,ma_dvi,so_id,
           'ma_sdbs' value PKH_TEN_TENl(FBH_NGDL_TXT(ma_dvi,so_id,'ma_sdbs'))) order by so_id desc returning clob)
        into cs_lke from bh_ngdl where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
