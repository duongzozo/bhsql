/*** TY LE DONG ***/
create or replace function FBH_DONG_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return varchar2
AS
begin
-- Dan - Tra gia tri varchar2 trong txt
return FBH_HD_DO_NH_TXT(b_ma_dvi,b_so_id,'D',b_tim);
end;
/
create or replace function FBH_DONG_TXTn(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return number
AS
begin
-- Dan - Tra gia tri varchar2 trong txt
return FBH_HD_DO_NH_TXTn(b_ma_dvi,b_so_id,'D',b_tim);
end;
/
-- chuclh: hàm lệch với db
create or replace function FBH_DONG(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra dong bao hiem: G-Goc, D-di, V-Ve
select nvl(max(kieu),'G') into b_kq from bh_hd_do where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_DONG_PHV(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
begin
-- Dan - Tra tu thu phi
return FBH_HD_DO_NH_TXTn(b_ma_dvi,b_so_id,'D','ph');
end;
/
create or replace function FBH_DONG_THV(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
begin
-- Dan - Tra nhan VAT
return FBH_HD_DO_NH_TXT(b_ma_dvi,b_so_id,'D','vat');
end;
/
create or replace function FBH_DONG_HHV(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
begin
-- Dan - Xac dinh tu tra hoa hong
return FBH_HD_DO_NH_TXT(b_ma_dvi,b_so_id,'D','dl');
end;
/
create or replace function FBH_DONG_HH_TL(b_ma_dvi varchar2,b_so_id number) return number
AS
begin
-- Dan - Tra %hh dai ly (tu tra hoa hong)
return FBH_HD_DO_NH_TXTn(b_ma_dvi,b_so_id,'D','pt_dl');
end;
/
create or replace procedure PBH_DONG_NBH(b_ma_dvi varchar2,b_so_id number,a_nbh out pht_type.a_var)
AS
    b_kq varchar2(20); b_i1 number;
begin
-- Dan - Xac dinh nha BH
select distinct nha_bh bulk collect into a_nbh from bh_hd_do_tl where ma_dvi=b_ma_dvi and so_id=b_so_id and pthuc='C';
end;
/
create or replace procedure PBH_DONG_NBHd(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,a_nbh out pht_type.a_var)
AS
    b_kq varchar2(20); b_i1 number;
begin
-- Dan - Xac dinh nha BH
select distinct nha_bh bulk collect into a_nbh from bh_hd_do_tl where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt in(0,b_so_id_dt) and pthuc='C';
end;
/
create or replace function FBH_DONG_TL(b_ma_dvi varchar2,b_so_id number,b_lh_nv varchar2,b_nbh varchar2:=' ') return number
AS
    b_kq number:=0;
begin
-- Dan - Xac dinh ty le dong bao hiem theo nghiep vu
select nvl(sum(pt),0) into b_kq from bh_hd_do_tl where
    ma_dvi=b_ma_dvi and so_id=b_so_id and pthuc='C' and lh_nv in (' ',b_lh_nv) and b_nbh in(' ',nha_bh);
if b_kq<>0 and FBH_DONG(b_ma_dvi,b_so_id)='V' then b_kq:=100-b_kq; end if;
return b_kq;
end;
/
create or replace function FBH_DONG_TL_DT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_lh_nv varchar2,b_nbh varchar2:=' ') return number
AS
    b_kq number;
begin
-- Dan - Xac dinh ty le dong bao hiem di theo nghiep vu cua doi tuong
select nvl(sum(pt),0) into b_kq from bh_hd_do_tl where
    ma_dvi=b_ma_dvi and so_id=b_so_id and pthuc='C' and so_id_dt in (0,b_so_id_dt) and
    lh_nv in (' ',b_lh_nv) and b_nbh in(' ',nha_bh);
if b_kq<>0 and FBH_DONG(b_ma_dvi,b_so_id)='V' then b_kq:=100-b_kq; end if;
return b_kq;
end;
/
create or replace function FBH_DONG_TL_HH(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_lh_nv varchar2,b_phi number,b_tp number:=0) return number
AS
    b_kq number:=0;
begin
-- Dan - Tinh hoa hong
for r_lp in (select pt,hh from bh_hd_do_tl where
    ma_dvi=b_ma_dvi and so_id=b_so_id and pthuc='C' and
    so_id_dt in (0,b_so_id_dt) and lh_nv in (' ',b_lh_nv)) loop
    b_kq:=b_kq+round(b_phi*r_lp.pt*r_lp.hh/10000,b_tp);
end loop;
return b_kq;
end;
/
create or replace function FBH_DONG_TL_TIEN(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_lh_nv varchar2,b_tien number,b_nbh varchar2:=' ') return number
AS
    b_kq number; b_tl number; b_nt_phi varchar2(5); b_tp number:=0;
begin
-- Dan - Xac dinh tien da dong di
b_tl:=FBH_DONG_TL_DT(b_ma_dvi,b_so_id,b_so_id_dt,b_lh_nv,b_nbh);
select nvl(min(nt_phi),' ') into b_nt_phi from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nt_phi<>'VND' then b_tp:=2; end if;
b_kq:=round(b_tien*b_tl/100,b_tp);
return b_kq;
end;
/
create or replace procedure FBH_DONGf(
    b_ma_dvi varchar2,b_so_id number,
	b_kieu_do out varchar2,b_kieu_phv out varchar2,b_kieu_thv out varchar2)
AS
begin
-- Dan - Tra tham so dong
b_kieu_do:=FBH_DONG(b_ma_dvi,b_so_id);
b_kieu_phv:=FBH_DONG_PHV(b_ma_dvi,b_so_id);
b_kieu_thv:=FBH_DONG_THV(b_ma_dvi,b_so_id);
end;
/
create or replace function FBH_HD_DO_TL_NBH(b_pthuc varchar2,b_nha_bh varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan - Ten nha BH
if b_pthuc='D' then
    select min(ma||'|'||ten) into b_kq from ht_ma_dvi where ma=b_nha_bh;
elsif b_pthuc='P' then
    select min(ma||'|'||ten) into b_kq from ht_ma_phong where ma=b_nha_bh;
else
    b_kq:=FBH_MA_NBH_TENl(b_nha_bh);
end if;
return b_kq;
end;
/
create or replace function FBH_HD_DO_TL_DTUONG(
    b_nv varchar2,b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay number:=30000101) return nvarchar2
AS
    b_kq nvarchar2(500):=''; b_ten nvarchar2(500); b_so_idB number;
begin
-- Dan - Tra ten doi tuong
if b_nv='PHH' then
    b_so_idB:=FBH_PHH_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
    b_kq:=FBH_PHH_DVI(b_ma_dvi,b_so_idB,b_so_id_dt,b_ngay);
elsif b_nv='PKT' then
    b_so_idB:=FBH_PKT_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
    b_kq:=FBH_PKT_DVI(b_ma_dvi,b_so_idB,b_so_id_dt,b_ngay);
elsif b_nv='XE' then
    b_so_idB:=FBH_XE_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
    select decode(bien_xe,' ',so_khung,bien_xe) into b_kq from bh_xe_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='TAU' then
    b_so_idB:=FBH_TAU_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
    select so_dk into b_kq from bh_tau_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='2B' then
    b_so_idB:=FBH_2B_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
    select decode(bien_xe,' ',so_khung,bien_xe) into b_kq from bh_2b_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='NG' then
    b_so_idB:=FBH_NG_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
    select ten into b_kq from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_idB;
end if;
return b_kq;
end;
/
-- chuclh: file a dan khong co
create or replace function FBH_TMN(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number;
begin
-- Dan - Tra co tam
select count(*) into b_kq from tbh_tmN where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
