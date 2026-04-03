create or replace function FBH_SK_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_id number; b_txt clob;
    a_ds_ct pht_type.a_clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
select count(*) into b_i1 from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
	select txt into b_txt from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
	PKH_JS_BONH(b_txt); b_kq:=FKH_JS_GTRIs(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_SK_TXTn(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return number
AS
    b_kq number:=0; b_i1 number; b_id number; b_txt clob; b_lenh varchar2(1000);
    a_ds_ct pht_type.a_clob;
begin
-- Dan - Tra gia tri num trong txt
select count(*) into b_i1 from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    PKH_JS_BONH(b_txt); b_kq:=FKH_JS_GTRIn(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace procedure FBH_SK_BPHI_DKm(
    b_so_id number,b_ma varchar2,b_tien number,b_lh_bh varchar2,b_pt out number,b_phi out number,b_loi out varchar2)
AS
    b_i1 number; b_tienM number;
begin
-- Dan - Lay %phi theo khoang muc trach nhiem
b_loi:='loi:Loi xu ly FBH_SK_BPHI_DKm:loi';
select count(*),nvl(max(tien),0) into b_i1,b_tienM from bh_sk_phi_dk where
    so_id=b_so_id and ma=b_ma and lh_bh=b_lh_bh and tien<=b_tien;
if b_i1=0 then b_loi:='loi:Khong tim duoc ty le phi theo muc trach nhiem:loi'; return; end if;
select nvl(max(pt),0),nvl(max(phi),0) into b_pt,b_phi from bh_sk_phi_dk
    where so_id=b_so_id and ma=b_ma and lh_bh=b_lh_bh and tien=b_tienM;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_SK_BPHI_DKm(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000);
    b_so_id number; b_ma varchar2(10); b_tien number; b_pt number; b_phi number;
    b_nhom varchar2(10); b_ma_sp varchar2(10); b_cdich varchar2(200); b_goi varchar2(200);
    b_ngay_hl number; b_ng_sinh number; b_lh_bh varchar2(5);
begin
-- Dan - Lay %phi theo khoang muc trach nhiem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nhom,ma_sp,cdich,goi,ngay_hl,ng_sinh,ma,tien,lh_bh');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_ma_sp,b_cdich,b_goi,b_ngay_hl,b_ng_sinh,b_ma,b_tien,b_lh_bh using b_oraIn;
b_ma_sp:=nvl(trim(b_ma_sp),' '); b_ng_sinh:=nvl(b_ng_sinh,0);
b_cdich:=PKH_MA_TENl(b_cdich); b_goi:=PKH_MA_TENl(b_goi);
b_so_id:=FBH_SK_BPHI_SO_IDh(b_nhom,b_ma_sp,b_cdich,b_goi,b_ng_sinh,b_ngay_hl);
if b_so_id=0 then b_loi:='loi:Khong tim duoc bieu phi phu hop:loi'; raise PROGRAM_ERROR; end if;
FBH_SK_BPHI_DKm(b_so_id,b_ma,b_tien,b_lh_bh,b_pt,b_phi,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('pt' value b_pt,'phi' value b_phi) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;

/
create or replace procedure PBH_SK_BKH_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob;
begin
-- Dan - Liet ke bkh muc 6
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ten) order by ten) into cs_lke from (select distinct ten from bh_sk_bkh where muc=6);
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_BKH_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
	a_ten pht_type.a_nvar; a_muc pht_type.a_num;
begin
-- Dan - Dat bkh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','Q');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ten,muc');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ten,a_muc using b_oraIn;
if a_ten.count=0 then b_loi:='loi:Chon benh:loi'; raise PROGRAM_ERROR; end if;
forall b_lp in 1..a_ten.count
    update bh_sk_bkh set muc=a_muc(b_lp) where muc=6 and ten=a_ten(b_lp);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_SK_LUONG(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return number
AS
    b_kq number;
begin
-- Dan - Tra luong
select nvl(min(luong),0) into b_kq from bh_sk_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace function FBH_SK_SO_ID_NHOM(b_ma_dvi varchar2,b_so_id number,b_nhom varchar2) return number
AS
    b_kq number;
begin
-- Dan - Tra so ID nhom
select nvl(min(so_id_nh),0) into b_kq from bh_sk_nh where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom;
return b_kq;
end;
/
create or replace function FBH_SK_SP(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra san phm
select nvl(min(ma_sp),'*') into b_kq from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_SK_NV(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Kiem tra hieu luc
select min(nv) into b_kq from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure FBH_SK_DT_NGd(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay_hld out date,b_ngay_ktd out date)
AS
    b_ngay_hl number; b_ngay_kt number;
begin
-- Dan - Ngay hieu luc, ngay ket thuc doi tuong
select nvl(min(ngay_hl),0),nvl(min(ngay_kt),0) into b_ngay_hl,b_ngay_kt from bh_sk_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
if b_ngay_hl=0 then
	select nvl(min(ngay_hl),0),nvl(min(ngay_kt),0) into b_ngay_hl,b_ngay_kt from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
b_ngay_hld:=PKH_SO_CDT(b_ngay_hl); b_ngay_ktd:=PKH_SO_CDT(b_ngay_kt);
end;
/
create or replace function FBH_SK_HL(b_ma_dvi varchar2,b_so_id number,b_ngay number,b_ngayd number,b_ngayc number) return varchar2
AS
    b_so_idB number; b_ngay_hl number; b_ngay_kt number; b_kq varchar2(1):='K';
begin
-- Dan - Kiem tra hieu luc
b_so_idB:=FBH_SK_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_idB;
if b_ngayd<=b_ngay_kt and b_ngay_hl<=b_ngayc then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_SK_KIEU_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Dan - Tra so hop dong
select nvl(min(kieu_hd),' ') into b_kq from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_SK_KIEU_HDd(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(1); b_so_idD number:=FBH_SK_SO_IDd(b_ma_dvi,b_so_id);
begin
-- Dan - Tra so hop dong
select nvl(min(kieu_hd),' ') into b_kq from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_idD;
return b_kq;
end;
/
create or replace function FBH_SK_SO_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Dan - Tra so hop dong
select min(so_hd) into b_kq from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_SK_SO_HDd(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50); b_so_idD number;
begin
-- Dan - Tra so hop dong dau
b_so_idD:=FBH_SK_SO_IDd(b_ma_dvi,b_so_id);
b_kq:=FBH_SK_SO_HD(b_ma_dvi,b_so_idD);
return b_kq;
end;
/
create or replace function FBH_SK_SO_ID(b_ma_dvi varchar2,b_so_hd varchar2,b_nv varchar2:='') return number
as
    b_kq number;
begin
-- Dan - Tra so id
if nvl(b_nv,' ')=' ' then
    select nvl(min(so_id),0) into b_kq from bh_sk where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
else
    select nvl(min(so_id),0) into b_kq from bh_sk where ma_dvi=b_ma_dvi and so_hd=b_so_hd and nv=b_nv;
end if;
return b_kq;
end;
/
create or replace function FBH_SK_ID_ID_DT(b_ma_dvi varchar2,b_so_id number,b_gcn varchar2) return number
as
    b_kq number;
begin
-- Dan - Tra so_id_dt
select nvl(min(so_id_dt),0) into b_kq from bh_sk_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and gcn=b_gcn;
return b_kq;
end;
/
create or replace function FBH_NGSK_ID_GCN(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return varchar2
as
    b_kq varchar2(20);
begin
-- Dan - Tra gcn
select min(gcn) into b_kq from bh_sk_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace function FBH_SK_HD_ID_DT(b_ma_dvi varchar2,b_so_hd number,b_gcn varchar2) return number
as
    b_kq number:=0; b_so_id number;
begin
-- Dan - Tra so id DT
b_so_id:=FBH_SK_SO_ID(b_ma_dvi,b_so_hd);
if b_so_id<>0 then b_kq:=FBH_SK_ID_ID_DT(b_ma_dvi,b_so_id,b_gcn); end if;
return b_kq;
end;
/
create or replace function FBH_SK_SO_IDd(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Dan - Tra so id dau
select nvl(min(so_id_d),0) into b_kq from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_SK_HD_SO_IDd(b_ma_dvi varchar2,b_so_hd varchar2) return number
as
    b_kq number;
begin
-- Dan - Tra so id dau
select nvl(min(so_id_d),0) into b_kq from bh_sk where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
return b_kq;
end;
/
create or replace function FBH_SK_SO_GCNd(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return number
as
    b_kq number; b_so_idD number;
begin
-- Dan - Tra so GCN dau
b_so_idD:=FBH_SK_SO_IDd(b_ma_dvi,b_so_id);
select min(gcn) into b_kq from bh_sk_ds where ma_dvi=b_ma_dvi and so_id=b_so_idD and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace function FBH_SK_SO_IDc(b_ma_dvi varchar2,b_so_id number,b_ttrang varchar2:='K') return number
as
    b_kq number:=0; b_so_idD number:=b_so_id;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_SK_SO_IDd(b_ma_dvi,b_so_id);
if b_ttrang<>'C' then
    select nvl(max(so_id),0) into b_kq from bh_sk where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
else
    select nvl(max(so_id),0) into b_kq from bh_sk where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D';
end if;
return b_kq;
end;
/
create or replace function FBH_SK_HD_SO_IDc(b_ma_dvi varchar2,b_so_hd varchar2,b_ttrang varchar2:='K') return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_SK_HD_SO_IDd(b_ma_dvi,b_so_hd);
if b_ttrang<>'C' then
    select nvl(max(so_id),0) into b_kq from bh_sk where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
else
    select nvl(max(so_id),0) into b_kq from bh_sk where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D';
end if;
return b_kq;
end;
/
create or replace function FBH_SK_SO_IDb(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id bo sung den ngay
b_so_idD:=FBH_SK_SO_IDd(b_ma_dvi,b_so_id);
select nvl(max(so_id),0) into b_kq from bh_sk where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D' and ngay_ht<=b_ngay;
return b_kq;
end;
/
create or replace function FBH_SK_HD_SO_IDb(
    b_ma_dvi varchar2,b_so_hd varchar2,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id bo sung den ngay
b_so_idD:=FBH_SK_HD_SO_IDd(b_ma_dvi,b_so_hd);
select nvl(max(so_id),0) into b_kq from bh_sk where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D' and ngay_ht<=b_ngay;
return b_kq;
end;
/
create or replace procedure FBH_SK_HD_SO_ID_DT(
    b_gcn varchar2,b_ngay number,b_ma_dvi out varchar2,b_so_id out number,b_so_id_dt out number)
as
begin
-- Dan - Tra so id qua GCN
select nvl(min(so_id_dt),0) into b_so_id_dt from bh_sk_ds where gcn=b_gcn;
if b_so_id_dt<>0 then
	FBH_SK_SO_ID_DT(b_so_id_dt,b_ma_dvi,b_so_id,b_ngay);
else
	b_so_id:=0; b_ma_dvi:='';
end if;
end;
/
create or replace procedure FBH_SK_HD_SO_ID_DTd(
    b_gcn varchar2,b_ma_dvi out varchar2,b_so_id out number,b_so_id_dt out number)
as
begin
-- Dan - Tra so id dau qua GCN
select min(ma_dvi),nvl(min(so_id),0),nvl(min(so_id_dt),0) into b_ma_dvi,b_so_id,b_so_id_dt from bh_sk_ds where gcn=b_gcn;
if b_so_id<>0 then b_so_id:=FBH_SK_SO_IDd(b_ma_dvi,b_so_id); end if;
end;
/
create or replace procedure FBH_SK_SO_ID_DT(
    b_so_id_dt number,b_ma_dvi out varchar2,b_so_id out number,b_ngay number:=30000101)
as
begin
-- Dan - Tra so id cuoi qua so_id_dt
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_sk_ds where so_id_dt=b_so_id_dt;
if b_so_id<>0 then b_so_id:=FBH_SK_SO_IDb(b_ma_dvi,b_so_id,b_ngay); end if;
end;
/
create or replace procedure FBH_SK_SO_ID_DTd(
    b_so_id_dt number,b_ma_dvi out varchar2,b_so_id out number)
as
begin
-- Dan - Tra so id dau qua so_id_dt
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_sk_ds where so_id_dt=b_so_id_dt;
if b_so_id<>0 then b_so_id:=FBH_SK_SO_IDd(b_ma_dvi,b_so_id); end if;
end;
/

create or replace function FBH_SK_HD_NHOM(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(1);
begin
-- Dan - Tra nhom
select min(nv) into b_kq from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
end;
/
create or replace function FBH_SK_NT_TIEN(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(5); b_so_idB number;
begin
-- Dan - Tra loai tien bao hiem
b_so_idB:=FBH_SK_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select nvl(min(nt_tien),'VND') into b_kq from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_idB;
return b_kq;
end;
/
create or replace function FBH_SK_NT_PHI(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(5); b_so_idB number;
begin
-- Dan - Tra loai tien phi
b_so_idB:=FBH_SK_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select nvl(min(nt_phi),'VND') into b_kq from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_idB;
return b_kq;
end;
/
create or replace function FBH_SK_MA_DT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(5); b_so_idB number;
begin
-- Dan - Tra so id cuoi
b_so_idB:=FBH_SK_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select nvl(min(nghe),' ') into b_kq from bh_sk_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id=b_so_id_dt;
return b_kq;
end;
/
create or replace function FBH_SK_CAP(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Dan - Tra ngay cap
select min(ngay_cap) into b_kq from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_SK_NGAY(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Dan - Tra nhap
select nvl(min(ngay_ht),0) into b_kq from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_SK_SO_IDp(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return number
as
    b_kq number;
begin
-- Dan - Tra so_idP
select min(so_idP) into b_kq from bh_sk_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace function FBH_SK_TTRANG(b_ma_dvi varchar2,b_so_id number,b_dk varchar2:='K',b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(1); b_i1 number;
begin
-- Dan - Tra ngay cap
select nvl(min(ttrang),'X') into b_kq from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_kq<>'X' and b_dk='C' then
    select count(*) into b_i1 from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay;
    if b_i1<>0 then b_kq:='H'; end if;
end if;
return b_kq;
end;
/
create or replace procedure PBH_SK_SO_ID_KTRA(b_ma_dvi varchar2,b_so_id_g number,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Kiem tra SO_ID moi nhap
if b_so_id_g=0 then b_loi:=''; return; end if;
select count(*) into b_i1 from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id_g and ttrang<>'D';
if b_i1<>0 then b_loi:='loi:Hop dong cu da xoa hoac chua ky:loi'; return; end if;
select count(*) into b_i1 from bh_sk where ma_dvi=b_ma_dvi and so_id_g=b_so_id_g and kieu_hd<>'K';
if b_i1<>0 then b_loi:='loi:Hop dong cu da co bo sung, sua doi:loi'; return; end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
CREATE OR REPLACE procedure PBH_SK_BS
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
b_so_idD:=FBH_SK_SO_IDd(b_ma_dvi,b_so_id);
select JSON_ARRAYAGG(obj) into cs_lke from
    (select json_object(ngay_ht,so_hd,gcn) obj from
        (select distinct a.ngay_ht,a.so_hd,b.gcn from bh_sk a,bh_sk_ds b
        where a.ma_dvi=b_ma_dvi and a.so_id_d=b_so_idD and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id and b.so_id_dt=b_so_id_dt order by a.ngay_ht,a.so_hd,b.gcn));
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
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
    select count(*) into b_dong from bh_sk where ma_dvi=b_ma_dvi and 
        ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd and dsach=b_dsach;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_sk where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd and
            dsach=b_dsach order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','NG','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_sk where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong and dsach=b_dsach;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_sk  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong and
            dsach=b_dsach order by so_hd)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_sk where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and
    nv=b_nv and dsach=b_dsach;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_sk  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and
            dsach=b_dsach order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10); b_so_hd varchar2(20);
    b_so_id number; b_ngay_ht number; b_nv varchar2(1); b_dsach varchar2(1);
    b_klk varchar2(1); b_trangKt number; b_tu number; b_den number;
    b_trang number; b_dong number; cs_lke clob;
begin
-- Dan - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,nv,klk,trangkt,dsach');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_nv,b_klk,b_trangKt,b_dsach using b_oraIn;
b_dsach:=nvl(trim(b_dsach),'C');
b_so_hd:=FBH_SK_SO_HD(b_ma_dvi,b_so_id);
if b_so_hd is null then b_loi:='loi:GCN, hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
if b_klk ='N' then
    select count(*) into b_dong from bh_sk where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd and dsach=b_dsach;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_sk where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd and dsach=b_dsach order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_sk  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd and
            dsach=b_dsach order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','NG','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_sk where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong and dsach=b_dsach;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_sk where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong and
            dsach=b_dsach order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_sk  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong and
            dsach=b_dsach order by so_hd)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_sk where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and
        nv=b_nv and dsach=b_dsach;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_sk where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and
        nv=b_nv and dsach=b_dsach order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_sk  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and
            dsach=b_dsach order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_SO_ID(
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
b_so_id:=FBH_SK_SO_ID(b_ma_dvi,b_so_hd,b_nv);
if b_so_id=0 then b_loi:='loi:So hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh varchar2,b_loi out varchar2)
AS
    b_ttrang varchar2(1); b_so_hdL varchar(10); b_nv varchar(10); b_i1 number; b_so_idD number; b_so_idK number;  b_ksoat varchar2(20); b_nsdC varchar2(20);
begin
-- Dan - Xoa
select count(*) into b_i1 from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select ttrang,so_hdl,nv,so_id_d,so_id_kt,ksoat,nsd into b_ttrang,b_so_hdL,b_nv,b_so_idD,b_so_idK,b_ksoat,b_nsdC
    from bh_sk where so_id=b_so_id;
if b_so_idK>0 then b_loi:='loi:Khong sua, xoa phuc hoi da hach toan ke toan:loi'; return; end if;
if b_nsdC<>b_nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
if trim(b_ksoat) is not null and b_ksoat<>b_nsd then b_loi:='loi:Khong sua, xoa GCN, hop dong da kiem soat:loi'; return; end if;
select count(*) into b_i1 from bh_sk where ma_dvi=b_ma_dvi and so_id_g=b_so_id;
if b_i1<>0 then b_loi:='loi:Khong sua, xoa GCN, hop dong da tao SDBS:loi'; return; end if;
--CNGA - AC
if b_ttrang='D' and b_so_hdL='P' then
    if b_nv = 'T' then
       PBH_SKT_DON(b_ma_dvi,b_so_id,'X',b_loi);
    else
       PBH_SK_DON(b_ma_dvi,b_so_id,'X',b_loi);
    end if;
    if b_loi is not null then return; end if;
end if;
if b_ttrang in('T','D') then
    PBH_NG_GOC_XOA(b_ma_dvi,b_nsd,b_so_id,b_nh,b_loi);
    if b_loi is not null then return; end if;
end if;
delete bh_hd_goc_ttindt where ma_dvi=b_ma_dvi and so_id=b_so_idD;
delete bh_sk_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_sk_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_sk_bkh where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_sk_lsb where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_sk_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_sk_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_sk_nh where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_SK_XOA_XOA:loi'; end if;
end;
/
create or replace procedure PBH_SK_XOA(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Dan - Xoa GCN
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','SK','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_SK_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'X',b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_DON(b_ma_dvi varchar2,b_so_id number,b_nv varchar2,b_loi out varchar2)
AS
    b_i1 number; b_ma_dl varchar2(20):=' '; b_ks varchar2(1); a_ds_ct pht_type.a_clob;
    b_loai_ac varchar(20);b_mau varchar2(200);b_lenh varchar2(1000);
    dt_ct_txt clob; dt_ds_txt clob;
    a_mau_ac pht_type.a_var;a_loai_ac pht_type.a_var;a_gcn_m pht_type.a_var; a_gcn_c pht_type.a_var; a_gcn pht_type.a_var;  r_hd bh_sk%rowtype;
begin
-- Dan - Kiem soat an chi
b_loi:='loi:So an chi khong hop le:loi';
select count(*) into b_i1 from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select * into r_hd from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_ks:=FBH_HT_THUE_TS(b_ma_dvi,r_hd.ngay_ht,'gcn_xe');
if b_ks is null then b_loi:='loi:Chua khai bao kieu theo doi an chi:loi'; return; end if;
if r_hd.kieu_kt<>'T' then b_ma_dl:=r_hd.ma_kt; end if;
if r_hd.nv='C' then
  select txt into a_ds_ct(1) from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
  b_lenh:=FKH_JS_LENH('loai_ac,mau_ac,gcn');
  EXECUTE IMMEDIATE b_lenh into a_loai_ac(1),a_mau_ac(1),a_gcn(1) using a_ds_ct(1);
elsif r_hd.nv='G' then
  select count(1) into b_i1 from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
  if b_i1 > 0 then
     select FKH_JS_BONH(txt) into dt_ds_txt from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
  end if;
  b_lenh:=FKH_JS_LENH('dt_ds_ct');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_ct using dt_ds_txt;
  if a_ds_ct.count=0 then b_loi:='loi:Nhap danh sach xe:loi'; return; end if;
  for b_i1 in 1..a_ds_ct.count loop
    b_lenh:=FKH_JS_LENH('mau_ac,gcn');
    a_loai_ac(b_i1):='CN';
    EXECUTE IMMEDIATE b_lenh into a_mau_ac(b_i1),a_gcn(b_i1) using a_ds_ct(b_i1);
  end loop;
else
  select count(1) into b_i1 from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
  if b_i1 > 0 then
     select FKH_JS_BONH(txt) into dt_ds_txt from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
  end if;
  b_lenh:=FKH_JS_LENH('ds_ct');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_ct using dt_ds_txt;
  if a_ds_ct.count=0 then b_loi:='loi:Nhap danh sach xe:loi'; return; end if;
  for b_i1 in 1..a_ds_ct.count loop
    b_lenh:=FKH_JS_LENH('mau_ac,gcn');
    a_loai_ac(b_i1):='CN';
    EXECUTE IMMEDIATE b_lenh into a_mau_ac(b_i1),a_gcn(b_i1) using a_ds_ct(b_i1);
  end loop;
end if;
for b_lp in 1..a_loai_ac.count loop
  if a_loai_ac(b_lp) is not null then
    a_gcn_m(b_lp):=a_loai_ac(b_lp)||'>'||a_mau_ac(b_lp);
    a_gcn_c(b_lp):=nvl(substr(a_gcn(b_i1), 1, length(a_gcn(b_i1)) - 7), ' ');
  end if;
end loop;
PHD_PH_DON(b_ma_dvi,b_nv,r_hd.ngay_ht,b_so_id,a_gcn_m,a_gcn_c,a_gcn,r_hd.ma_cb,b_ma_dl,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
create or replace procedure PBH_SKT_DON(b_ma_dvi varchar2,b_so_id number,b_nv varchar2,b_loi out varchar2)
AS
    b_i1 number; b_ma_dl varchar2(20):=' '; b_ks varchar2(1); a_ds_ct pht_type.a_clob;
    b_loai_ac varchar(20);b_mau varchar2(200);b_lenh varchar2(1000);
    dt_ct_txt clob; dt_ds_txt clob;
    a_mau_ac pht_type.a_var;a_loai_ac pht_type.a_var;a_gcn_m pht_type.a_var; a_gcn_c pht_type.a_var; a_gcn pht_type.a_var;  r_hd bh_sk%rowtype;
begin
-- Dan - Kiem soat an chi
b_loi:='loi:So an chi khong hop le:loi';
select count(*) into b_i1 from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select * into r_hd from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_ks:=FBH_HT_THUE_TS(b_ma_dvi,r_hd.ngay_ht,'gcn_xe');
if b_ks is null then b_loi:='loi:Chua khai bao kieu theo doi an chi:loi'; return; end if;
if r_hd.kieu_kt<>'T' then b_ma_dl:=r_hd.ma_kt; end if;
if r_hd.nv='C' then
  b_lenh:=FKH_JS_LENH('mau_ac,loai_ac');
  select FKH_JS_BONH(txt) into dt_ct_txt from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
  EXECUTE IMMEDIATE b_lenh into b_mau,b_loai_ac using dt_ct_txt;
  select gcn bulk collect into a_gcn from bh_sk_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
  a_loai_ac(1):=b_loai_ac;a_mau_ac(1):=b_mau;
  if a_loai_ac(1) is not null then
      a_gcn_m(1):=a_loai_ac(1)||'>'||a_mau_ac(1);
      a_gcn_c(1):='';
    end if;
  PBH_LAY_SOAC(b_ma_dvi,a_loai_ac(1),a_mau_ac(1),a_gcn(1),b_loi);
else
  select count(1) into b_i1 from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
  if b_i1 > 0 then
     select FKH_JS_BONH(txt) into dt_ds_txt from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
  end if;
  b_lenh:=FKH_JS_LENH('mau_ac,gcn');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_mau_ac,a_gcn using dt_ds_txt;
  for b_lp in 1..a_gcn.count loop
    if trim(a_gcn(b_lp)) is null then b_loi:='loi:Khong lay duoc so an chi:loi'; return; end if;
    a_gcn_m(b_i1):='CN'||'>'||a_mau_ac(b_i1);
    a_gcn_c(b_i1):='';
    PBH_LAY_SOAC(b_ma_dvi,'CN',a_mau_ac(b_lp),a_gcn(b_lp),b_loi);
    if b_loi is not null then return; end if;
  end loop;
end if;
PHD_PH_DON(b_ma_dvi,b_nv,r_hd.ngay_ht,b_so_id,a_gcn_m,a_gcn_c,a_gcn,r_hd.ma_cb,b_ma_dl,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
create or replace procedure PBH_SK_PHIb(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000); b_loi varchar2(100); b_i1 number; b_i2 number; dt_ct clob;
    b_ma varchar2(20); b_so_hdG varchar2(20); b_ngay_hl number; b_ngay_kt number; b_ngay_cap number;
    b_ngay_hlC number; b_ngay_ktC number; b_so_idG number:=0;

    b_tienG number; b_ptG number; b_phiG number;

begin
-- Nam - tinh phi prorata
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct');
EXECUTE IMMEDIATE b_lenh into dt_ct using b_oraIn;
FKH_JS_NULL(dt_ct);
b_lenh:=FKH_JS_LENH('so_hd_g,ngay_hl,ngay_kt,ngay_cap,ma');
EXECUTE IMMEDIATE b_lenh into b_so_hdG,b_ngay_hl,b_ngay_kt,b_ngay_cap,b_ma using dt_ct;
if b_ma is null then b_loi:=''; return; end if;
if b_so_hdG<>' ' then
    b_so_idG:=FBH_SK_SO_ID(b_ma_dvi,b_so_hdG);
    if b_so_idG=0 then b_loi:='loi:GCN goc da xoa:loi'; return; end if;
end if;
if b_so_idG<>0 and b_ngay_hl<b_ngay_cap then
    select ngay_hl,ngay_kt into b_ngay_hlC,b_ngay_ktC from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_idG;
    b_i1:=FKH_KHO_NGSO(b_ngay_cap,b_ngay_ktC)/FKH_KHO_NGSO(b_ngay_hlC,b_ngay_ktC);
    b_i2:=FKH_KHO_NGSO(b_ngay_cap,b_ngay_kt)/FKH_KHO_NGSO(b_ngay_hl,b_ngay_kt);
    b_i1:=round(b_i1,2); b_i2:=round(b_i2,2);
    select tien,pt,phi into b_tienG,b_ptG,b_phiG from bh_sk_dk where ma_dvi=b_ma_dvi and so_id=b_so_idG and ma=b_ma;
end if;
select json_object('hsc' value b_i1,'hsm' value b_i2 ,'tien' value b_tienG,'pt' value b_ptG,'phi' value b_phiG returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_PHIGr(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_i2 number; b_iX number; b_lenh varchar2(1000);
    dt_ct clob; dt_dk clob; dt_dkbs clob;
    b_tp number:=0; b_nt_phi varchar2(5); b_nt_tien varchar2(5);
    b_so_hdG varchar2(20); b_ngay_hl number; b_ngay_kt number; b_ngay_cap number;
    b_tygia number:=1; b_ngay_hlC number; b_ngay_ktC number; b_kt number;
    b_phi number:=0; b_tien number; b_so_idG number:=0; b_so_id_dt number; b_kho number:=1;

    dk_ma pht_type.a_var;dk_ten pht_type.a_nvar;dk_tc pht_type.a_var;
    dk_maG pht_type.a_var;dk_tienG pht_type.a_num;dk_ptG pht_type.a_num;
    dk_phiG pht_type.a_num;
    dk_ma_ct pht_type.a_var;dk_kieu pht_type.a_var;
    dk_lkeM pht_type.a_var;dk_lkeP pht_type.a_var;dk_lkeB pht_type.a_var;
    dk_luy pht_type.a_var;dk_ma_dk pht_type.a_var;dk_ma_dkC pht_type.a_var;
    dk_lh_nv pht_type.a_var;dk_t_suat pht_type.a_num;dk_cap pht_type.a_num;
    dk_tien pht_type.a_num;dk_tienC pht_type.a_num;dk_pt pht_type.a_num;dk_phi pht_type.a_num;dk_ttoan pht_type.a_num;
    dk_ptB pht_type.a_num;dk_phiB pht_type.a_num;
    dk_pp pht_type.a_var;dk_ptk pht_type.a_var;dk_bt pht_type.a_num;

    dkbs_ma pht_type.a_var;dkbs_ten pht_type.a_nvar;dkbs_tc pht_type.a_var;
    dkbs_maG pht_type.a_var; dkbs_tienG pht_type.a_num; dkbs_ptG pht_type.a_num;
    dkbs_phiG pht_type.a_num;
    dkbs_ma_ct pht_type.a_var;dkbs_kieu pht_type.a_var;
    dkbs_lkeM pht_type.a_var;dkbs_lkeP pht_type.a_var;dkbs_lkeB pht_type.a_var;
    dkbs_luy pht_type.a_var;dkbs_ma_dk pht_type.a_var;dkbs_ma_dkC pht_type.a_var;
    dkbs_lh_nv pht_type.a_var;dkbs_t_suat pht_type.a_num;dkbs_cap pht_type.a_num;
    dkbs_tien pht_type.a_num;dkbs_tienC pht_type.a_num;dkbs_pt pht_type.a_num;dkbs_phi pht_type.a_num;dkbs_ttoan pht_type.a_num;
    dkbs_ptB pht_type.a_num;dkbs_phiB pht_type.a_num;
    dkbs_pp pht_type.a_var;dkbs_ptk pht_type.a_var;dkbs_bt pht_type.a_num;

    cs_dk clob; cs_dkbs clob; b_dk_txt clob; b_dkbs_txt clob; b_ma_dk varchar2(10);
    
    -- Biến bổ sung cho logic TINHBS
    b_ma_dkC_ref varchar2(10); b_hangC number; b_tien_ref number; b_mtn number; b_tienm number; b_phim number;

begin
-- Nam - tinh phi prorata theo grid
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_dkbs');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_dkbs using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_dkbs);
b_lenh:=FKH_JS_LENH('so_id_dt,so_hd_g,ngay_hl,ngay_kt,ngay_cap,nt_phi,nt_tien,tygia');
EXECUTE IMMEDIATE b_lenh into b_so_id_dt,b_so_hdG,b_ngay_hl,b_ngay_kt,b_ngay_cap,b_nt_phi,b_nt_tien,b_tygia using dt_ct;
b_so_id_dt:=nvl(b_so_id_dt,0);
if b_so_hdG<>' ' then
    b_so_idG:=FBH_SK_SO_ID(b_ma_dvi,b_so_hdG);
    if b_so_idG=0 then b_loi:='loi:GCN goc da xoa:loi'; return; end if;
end if;
if b_tygia is null or b_tygia=0 then b_tygia:=1; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tien,tienc,ptb,pp,pt,phi,cap,tc,ma_ct,ma_dk,ma_dkc,kieu,lh_nv,t_suat,phib,lkem,lkep,lkeb,ptk,luy,bt');
EXECUTE IMMEDIATE b_lenh bulk collect into dk_ma,dk_ten,dk_tien,dk_tienC,dk_ptB,dk_pp,dk_pt,dk_phi,dk_cap,dk_tc,dk_ma_ct,
        dk_ma_dk,dk_ma_dkC,dk_kieu,dk_lh_nv,dk_t_suat,dk_phiB,dk_lkeM,dk_lkeP,dk_lkeB,dk_ptk,dk_luy,dk_bt using dt_dk;
if dk_ma.count=0 then b_loi:='loi:Nhap so tien bao hiem:loi'; return; end if;
if trim(dt_dkbs) is not null then
  EXECUTE IMMEDIATE b_lenh bulk collect into dkbs_ma,dkbs_ten,dkbs_tien,dkbs_tienC,dkbs_ptB,dkbs_pp,dkbs_pt,dkbs_phi,dkbs_cap,dkbs_tc,dkbs_ma_ct,
        dkbs_ma_dk,dkbs_ma_dkC,dkbs_kieu,dkbs_lh_nv,dkbs_t_suat,dkbs_phiB,dkbs_lkeM,dkbs_lkeP,dkbs_lkeB,dkbs_ptk,dkbs_luy,dkbs_bt using dt_dkbs;
end if;
if b_nt_phi<>'VND' then b_tp:=2; end if;
FBH_HD_KHO(b_ngay_hl,b_ngay_kt,b_kho,b_loi);
if b_loi is not null then return; end if;
select ma,tien,pt,phi bulk collect into dk_maG,dk_tienG,dk_ptG,dk_phiG from bh_sk_dk
     where ma_dvi=b_ma_dvi and so_id=b_so_idG and b_so_id_dt in (0,so_id_dt) and lh_bh<>'M' order by bt;
select ma,tien,pt,phi bulk collect into dkbs_maG,dkbs_tienG,dkbs_ptG,dkbs_phiG from bh_sk_dk
     where ma_dvi=b_ma_dvi and so_id=b_so_idG and b_so_id_dt in (0,so_id_dt) and lh_bh<>'C' order by bt;
for b_lp_dkbs in 1..dkbs_ma.count loop
    b_ma_dkC_ref:=nvl(dkbs_ma_dkC(b_lp_dkbs),' ');
    if b_ma_dkC_ref <> ' ' then
      b_hangC := 0;
      for b_lp_dk in 1..dk_ma.count loop
          if dk_ma(b_lp_dk) = b_ma_dkC_ref then
              b_hangC := b_lp_dk; exit;
          end if;
      end loop;
      if b_hangC>0 then
          b_tien_ref:=nvl(dk_tien(b_hangC),0);
          if nvl(dkbs_lkeM(b_lp_dkbs),' ') = 'I' and b_tien_ref<>0 then
              b_tienm := ROUND(b_tien_ref * nvl(dkbs_tienC(b_lp_dkbs),0)/100,b_tp);
              dkbs_tien(b_lp_dkbs):=b_tienm;
          end if;
          if nvl(dkbs_lkeP(b_lp_dkbs),' ')='I' and b_tien_ref<>0 then
              b_mtn:=b_tien_ref;
              if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
                  b_mtn:=b_mtn / b_tygia;
              elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
                  b_mtn:=b_mtn * b_tygia;
              end if;
              b_phim:=ROUND(b_mtn * nvl(dkbs_ptB(b_lp_dkbs), 0) / 100, b_tp);
              dkbs_tien(b_lp_dkbs):=b_mtn; dkbs_phi(b_lp_dkbs):=b_phim;
          end if;
      end if;
    end if;
end loop;
for i in 1..dkbs_tienG.count loop
  if nvl(dkbs_lkeP(i),' ') = 'I' and nvl(dkbs_tienG(i),0) = 0 then
    b_tien_ref := 0;
    for j in reverse 1..i-1 loop
      if nvl(dk_tienG(j),0) <> 0 then
         b_tien_ref := dk_tienG(j);
         exit;
      end if;
    end loop;
    if b_tien_ref<>0 then
       dkbs_tienG(i) := b_tien_ref;
    end if;
  end if;
end loop;
b_kt:=0;
for b_lp_dk in 1..dk_ma.count loop
  if dk_ptk(b_lp_dk)<>'P' then
      if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
         dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) / b_tygia *b_kho,b_tp);
      elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
         dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) * b_tygia *b_kho,b_tp);
      else
         dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) *b_kho,b_tp);
      end if;
   elsif dk_ptk(b_lp_dk)<>'T' and dk_tien(b_lp_dk)<>0 and dk_ptB(b_lp_dk)<>0 then
      if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
         dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk)* dk_tien(b_lp_dk) / b_tygia *b_kho/ 100,b_tp);
      elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
         dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk)* dk_tien(b_lp_dk) * b_tygia *b_kho/ 100,b_tp);
      else
         dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk)* dk_tien(b_lp_dk) *b_kho/ 100,b_tp);
      end if;
   else dk_phiB(b_lp_dk):=0;
  end if;
end loop;
for b_lp_dkbs in 1..dkbs_ma.count loop
  if dkbs_ptk(b_lp_dkbs)<>'P' then
      if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
         dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs) / b_tygia *b_kho,b_tp);
      elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
         dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs) * b_tygia *b_kho,b_tp);
      else
         dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs) *b_kho,b_tp);
      end if;
   elsif dkbs_ptk(b_lp_dkbs)<>'T' and dkbs_tien(b_lp_dkbs)<>0 and dkbs_ptB(b_lp_dkbs)<>0 then
      if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
         dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs)* dkbs_tien(b_lp_dkbs) / b_tygia *b_kho/ 100,b_tp);
      elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
         dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs)* dkbs_tien(b_lp_dkbs) * b_tygia *b_kho/ 100,b_tp);
      else
         dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs)* dkbs_tien(b_lp_dkbs) *b_kho/ 100,b_tp);
      end if;
   else dkbs_phiB(b_lp_dkbs):=0;
   end if;
end loop;
for b_lp_dk in 1..dk_ma.count loop
  b_kt:=b_kt+1;
  b_ma_dk:=nvl(dk_ma_dkC(b_lp_dk),' ');  dk_pp(b_lp_dk):=nvl(dk_pp(b_lp_dk),' ');
  if dk_lkeP(b_lp_dk) not in ('T','N','K') then
      if dk_tien(b_lp_dk)=0 and (dk_pt(b_lp_dk)<>0 or dk_ptB(b_lp_dk)<>0) and b_ma_dk<>' ' and dk_lkeM(b_lp_dk) = 'C' then
        for b_lp1 in 1..dk_ma.count loop
           if b_ma_dk=dk_ma(b_lp1) then
              dk_tien(b_lp_dk):=dk_tien(b_lp1);
           end if;
        end loop;
      elsif b_ma_dk<>' ' and dk_lkeM(b_lp_dk) = 'P' then
        for b_lp1 in 1..dk_ma.count loop
           if b_ma_dk=dk_ma(b_lp1) then
              dk_tien(b_lp_dk):=ROUND(dk_tien(b_lp1) *dk_tienC(b_lp_dk) /100 ,b_tp);
           end if;
        end loop;
      end if;
      if dk_pp(b_lp_dk) = 'DG' and dk_pt(b_lp_dk)>0 then dk_phi(b_lp_dk):=ROUND(dk_pt(b_lp_dk),b_tp);
      elsif dk_pp(b_lp_dk) = 'DP' and dk_tien(b_lp_dk)<>0 and dk_pt(b_lp_dk)<>0 then
           dk_phi(b_lp_dk):=ROUND(dk_pt(b_lp_dk) * dk_tien(b_lp_dk) *b_kho/ 100,b_tp);
      elsif dk_phiB(b_lp_dk)<>0 then
           dk_phi(b_lp_dk):=ROUND(dk_phiB(b_lp_dk),b_tp);
        if dk_pp(b_lp_dk) = 'GG' then
             dk_phi(b_lp_dk):=ROUND((dk_phi(b_lp_dk)-dk_pt(b_lp_dk)),b_tp);
        elsif dk_pp(b_lp_dk) = 'GT' and dk_tien(b_lp_dk)<>0 and dk_pt(b_lp_dk)<>0 then
             dk_phi(b_lp_dk):= dk_phi(b_lp_dk) - ROUND(dk_pt(b_lp_dk) * dk_tien(b_lp_dk) *b_kho/ 100,b_tp);
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
  b_ma_dk:=nvl(dkbs_ma_dkC(b_lp_dkbs),' '); dkbs_pp(b_lp_dkbs):=nvl(dkbs_pp(b_lp_dkbs),' ');
   if dkbs_lkeP(b_lp_dkbs) not in ('T','N','K') then
    if dkbs_tien(b_lp_dkbs)=0 and (dkbs_pt(b_lp_dkbs)<>0 or dkbs_ptB(b_lp_dkbs)<>0) and b_ma_dk<>' ' and dkbs_lkeM(b_lp_dkbs) = 'C' then
      for b_lp1 in 1..dkbs_ma.count loop
         if b_ma_dk=dkbs_ma_dk(b_lp1) then
            dkbs_tien(b_lp_dkbs):=dkbs_tien(b_lp1);
         end if;
      end loop;
    elsif b_ma_dk<>' ' and dkbs_lkeM(b_lp_dkbs) = 'P' then
      for b_lp1 in 1..dkbs_ma.count loop
         if b_ma_dk=dkbs_ma_dk(b_lp1) then
            dkbs_tien(b_lp_dkbs):=ROUND(dkbs_tien(b_lp1) *dkbs_tienC(b_lp_dkbs) /100 ,b_tp);
         end if;
      end loop;
    end if;
    if dkbs_pp(b_lp_dkbs) = 'DG' and dkbs_pt(b_lp_dkbs)>0 then
        dkbs_phi(b_lp_dkbs):=ROUND(dkbs_pt(b_lp_dkbs),b_tp);
    elsif dkbs_pp(b_lp_dkbs) = 'DP' and dkbs_tien(b_lp_dkbs)<>0 and dkbs_pt(b_lp_dkbs)<>0 then
        dkbs_phi(b_lp_dkbs):=ROUND(dkbs_pt(b_lp_dkbs)*dkbs_tien(b_lp_dkbs) *b_kho/ 100,b_tp);
    elsif dkbs_phiB(b_lp_dkbs)<>0 then
        dkbs_phi(b_lp_dkbs):=dkbs_phiB(b_lp_dkbs);
      if dkbs_pp(b_lp_dkbs) = 'GG' then
        dkbs_phi(b_lp_dkbs):=ROUND((dkbs_phi(b_lp_dkbs)-dkbs_pt(b_lp_dkbs)),b_tp);
      elsif dkbs_pp(b_lp_dkbs) = 'GT' and dkbs_tien(b_lp_dkbs)<>0 and dkbs_pt(b_lp_dkbs)<>0 then
        dkbs_phi(b_lp_dkbs):= dkbs_phi(b_lp_dkbs) - ROUND(dkbs_pt(b_lp_dkbs)*dkbs_tien(b_lp_dkbs) *b_kho/ 100,b_tp);
      elsif dkbs_pp(b_lp_dkbs) = 'GP' and dkbs_pt(b_lp_dkbs)<>0 then
        dkbs_phi(b_lp_dkbs):= dkbs_phi(b_lp_dkbs) - ROUND(dkbs_pt(b_lp_dkbs)*dkbs_phiB(b_lp_dkbs)/ 100,b_tp);
      if dkbs_phi(b_lp_dkbs)<0 then dkbs_phi(b_lp_dkbs):=0; end if;
      end if;
    elsif dkbs_phiB(b_lp_dkbs)=0 then dkbs_phi(b_lp_dkbs):=0;
    end if;
    if dkbs_phiB(b_lp_dkbs)=0 then dkbs_phiB(b_lp_dkbs):=dkbs_phi(b_lp_dkbs); end if;
  end if;
  if nvl(dkbs_lkeP(b_lp_dkbs), ' ') = 'I' then
    dkbs_tien(b_lp_dkbs) := 0;
  end if;
end loop;
if b_so_idG<>0 and b_ngay_hl<b_ngay_cap then
    select ngay_hl,ngay_kt into b_ngay_hlC,b_ngay_ktC from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_idG;
    b_i1:=FKH_KHO_NGSO(b_ngay_cap,b_ngay_ktC)/FKH_KHO_NGSO(b_ngay_hlC,b_ngay_ktC);
    b_i2:=FKH_KHO_NGSO(b_ngay_cap,b_ngay_kt)/FKH_KHO_NGSO(b_ngay_hl,b_ngay_kt);
    b_i1:=round(b_i1,2); b_i2:=round(b_i2,2);
    for b_lp in 1..dk_maG.count loop
        b_iX:=b_lp; b_tien:=0;
        for b_lp1 in reverse 1..b_iX loop
            if dk_tienG(b_lp1)<>0 then b_tien:=dk_tienG(b_lp1); exit; end if;
        end loop;
        b_iX:=FKH_ARR_VTRI(dk_ma,dk_maG(b_lp));
        if b_iX=0 or b_tien=0 then continue; end if;
        b_phi:=b_tien*dk_ptG(b_lp)/100;
        b_phi:=dk_phiG(b_lp)-round(b_phi*b_i1,b_tp);               
        if dk_pp(b_iX)<>'DG' then
           dk_phi(b_iX):=b_phi+round(dk_phi(b_iX)*b_i2,b_tp);
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
        b_phi:=dkbs_phiG(b_lp)-round(b_phi*b_i1,b_tp);           
        if dkbs_pp(b_iX)<>'DG' then
           dkbs_phi(b_iX):=b_phi+round(dkbs_phi(b_iX)*b_i2,b_tp);
        end if;
    end loop;
end if;
FBH_SK_PHIb(b_tp,dk_ma,dk_ma_ct,dk_lkeP,dk_cap,dk_phi,dk_ttoan,b_loi);
if b_loi is not null then return; end if;
FBH_SK_PHIb(b_tp,dkbs_ma,dkbs_ma_ct,dkbs_lkeP,dkbs_cap,dkbs_phi,dkbs_ttoan,b_loi);
if b_loi is not null then return; end if;
b_oraOut:='';
for b_lp in 1..dk_ma.count loop
    select json_object('ma' value dk_ma(b_lp),'ten' value dk_ten(b_lp),'tc' value dk_tc(b_lp),'ma_ct' value dk_ma_ct(b_lp),
    'kieu' value dk_kieu(b_lp),'lkeM' value dk_lkeM(b_lp),'lkeP' value dk_lkeP(b_lp),'lkeB' value dk_lkeB(b_lp),
    'luy' value dk_luy(b_lp),'ma_dk' value dk_ma_dk(b_lp),'ma_dkC' value dk_ma_dkC(b_lp),
    'lh_nv' value dk_lh_nv(b_lp),'t_suat' value dk_t_suat(b_lp),'cap' value dk_cap(b_lp),
    'pp' value dk_pp(b_lp),'ptK' value dk_ptk(b_lp),'bt' value dk_bt(b_lp),
    'tien' value dk_tien(b_lp),'tienc' value dk_tienC(b_lp),'pt' value dk_pt(b_lp),
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
    'tien' value dkbs_tien(b_lp),'tienc' value dkbs_tienC(b_lp),'pt' value dkbs_pt(b_lp),
    'phi' value dkbs_phi(b_lp),'ttoan' value dkbs_ttoan(b_lp),
    'ptB' value dkbs_ptB(b_lp),'phiB' value dkbs_phiB(b_lp) returning clob) into b_dkbs_txt from dual;
    if b_lp>1 then cs_dkbs:=cs_dkbs||','; end if;
    cs_dkbs:=cs_dkbs||b_dkbs_txt;
end loop;
if cs_dkbs is not null then cs_dkbs:='['||cs_dkbs||']'; end if;
select json_object('dt_dk' value cs_dk,'dt_dkbs' value cs_dkbs returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_SK_PHIb(b_tp number,
    dk_ma pht_type.a_var,dk_ma_ct pht_type.a_var,dk_lkeP pht_type.a_var,dk_cap pht_type.a_num,
    dk_phi in out pht_type.a_num,dk_ttoan out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_cap number:=1; b_phi number;
begin
-- Nam - Tinh bac cao
b_loi:='loi:Loi xu ly FBH_SK_PHIb:loi';
for b_lp in 1..dk_ma.count loop
    if dk_cap(b_lp)>b_cap then b_cap:=dk_cap(b_lp); end if;
    if dk_lkeP(b_lp) in('T','N') then dk_phi(b_lp):=0; end if;
end loop;
b_cap:=b_cap-1;
while b_cap>0 loop
    for b_lp in 1..dk_ma.count loop
        if dk_cap(b_lp)<>b_cap then continue; end if;
        if dk_lkeP(b_lp)='T' then
            b_phi:=0;
            for b_lp1 in 1..dk_ma.count loop
                if dk_ma_ct(b_lp1)=dk_ma(b_lp) then
                    b_phi:=b_phi+dk_phi(b_lp1);
                end if;
            end loop;
            dk_phi(b_lp):=b_phi; dk_ttoan(b_lp):=b_phi;
        elsif dk_lkeP(b_lp)='N' then
            b_i1:=0;
            for b_lp1 in 1..dk_ma.count loop
                if dk_ma_ct(b_lp1)=dk_ma(b_lp) then
                    if b_i1=0 then
                        b_i1:=1; b_phi:=dk_phi(b_lp1);
                    else
                        b_phi:=ROUND(b_phi*dk_phi(b_lp1),b_tp);
                    end if;
                end if;
            end loop;
            dk_phi(b_lp):=b_phi;
        end if;
    end loop;
    b_cap:=b_cap-1;
end loop;
for b_lp in 1..dk_ma.count loop
    dk_ttoan(b_lp):=dk_phi(b_lp);
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_HDBS(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma_dvi varchar2(10); b_so_id number; b_so_idD number;
    b_dong number; cs_lke clob:='';
begin
-- Dan - Liet ke sua doi bo sung
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_so_idD:=FBH_SK_SO_IDd(b_ma_dvi,b_so_id);
if b_so_idD<>0 then
    select count(*) into b_dong from bh_sk where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hd,ttoan,ttrang,ma_dvi,so_id,
           'ma_sdbs' value PKH_TEN_TENl(FBH_SK_TXT(ma_dvi,so_id,'ma_sdbs')))order by so_id desc returning clob)
        into cs_lke from bh_sk where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
