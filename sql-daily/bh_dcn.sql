create or replace function FBH_DCN_MAt(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number;
begin
-- Dan - Tra dai ly ca nhan
select count(*) into b_i1 from bh_dcn_ma where ma=b_ma;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_DCN_MAl(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='T'; b_i1 number;
begin
-- Dan - Tra dai ly hay tu van vien
select count(*) into b_i1 from bh_dcn_ma_cc where ma=b_ma;
if b_i1<>0 then b_kq:='D'; end if;
return b_kq;
end;
/
create or replace function FBH_DCN_MAc(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra chuc danh
select nvl(min(chuc),'0') into b_kq from bh_dcn_ma_cd where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_DCN_MA_DVI(b_ma varchar2) return varchar2
AS
    b_kq varchar2(10):='K';
begin
-- Dan - Tra don vi huong doanh thu
select nvl(min(ma_dvi),'000') into b_kq from bh_dcn_ma_dvi where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_DCN_MA_THUE(b_ngay number) return number
AS
    b_kq number:=0; b_ngayM number;
begin
-- Dan - Tra thue suat thu nhap dai ly
select nvl(max(ngay),0) into b_ngayM from bh_dcn_ma_thue where ngay<=b_ngay;
if b_ngayM<>0 then
	select nvl(min(ts),0) into b_kq from bh_dcn_ma_thue where ngay=b_ngayM;
end if;
return b_kq;
end;
/
create or replace function FBH_DCN_MA_TD(b_ma varchar2) return varchar2
AS
    b_kq varchar2(30);
begin
-- Dan - Tra ma tuyen dung
select min(ma_ql) into b_kq from bh_dcn_ma_td where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_DCN_MA_TC(b_ma varchar2) return varchar2
AS
    b_kq varchar2(30);
begin
-- Dan - Tra ma to chuc
select min(ma_ql) into b_kq from bh_dcn_ma_tc where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_DCN_MA_QL(b_ma varchar2) return varchar2
AS
    b_kq varchar2(30);
begin
-- Dan - Tra ma quan ly
b_kq:=FBH_DCN_MA_TD(b_ma);
if b_kq is null then b_kq:=FBH_DCN_MA_TC(b_ma); end if;
return b_kq;
end;
/
create or replace function FBH_DCN_MA_DENt(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number;
begin
-- Dan - Tra thuoc danh sach den
select count(*) into b_i1 from bh_dcn_ma_den where ma=b_ma;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_DCN_MA_DENc(b_ma varchar2,b_lydo nvarchar2,b_loi out varchar2)
AS
begin
-- Chuyen danh sach den
b_loi:='loi:Loi chuyen danh sach den:loi';
if trim(b_ma) is null then return; end if;
insert into bh_dcn_ma_den select ma,b_lydo from bh_dcn_ma_den where ma=b_ma;
b_loi:='';
end;
/
create or replace procedure PBH_DCN_MA_SP(b_ma varchar2,cs_lke out pht_type.cs_type)
AS
begin
-- Dan - Danh sach form san pham dai ly duoc phep ban
open cs_lke for select sp from bh_dcn_ma_sp where ma=b_ma;
end;
/
create or replace procedure PBH_DCN_MA_HHONG(
	b_ma varchar2,b_nv varchar2,b_sp varchar2,b_lh_nv varchar2,b_ngay number,b_hhong out number,b_htro out number,b_dvu out number)
AS
    b_ngayM number;
begin
-- Tra ty le hoa hong
select nvl(max(ngay),0) into b_ngayM from bh_dcn_ma_hh where nv=b_nv and sp=b_sp and ngay<=b_ngay;
if b_ngay=0 then
	b_hhong:=0; b_htro:=0; b_dvu:=0;
else
	select nvl(min(hhong),0),nvl(min(htro),0),nvl(min(dvu),0) into b_hhong,b_htro,b_dvu
		from bh_dcn_ma_hh where nv=b_nv and sp=b_sp and ngay=b_ngayM and lh_nv=b_lh_nv;
end if;
end;
/
create or replace function FBH_DCN_MA_HSOd(b_ngay number,b_dthu number) return number
AS
    b_kq number:=0; b_ngayM number; b_dthuM number;
begin
-- Dan - Tra he so tra dvu theo doanh thu
select nvl(max(ngay),0) into b_ngayM from bh_dcn_ma_hsoD where ngay<=b_ngay;
if b_ngayM<>0 then
    select nvl(max(dthu),0) into b_dthuM from bh_dcn_ma_hsoD where ngay=b_ngayM and dthu<=b_dthu;
    if b_dthuM<>0 then
        select hso into b_kq from bh_dcn_ma_hsoD where ngay=b_ngayM and dthu=b_dthuM;
    end if;
end if;
return b_kq;
end;
/
create or replace function FBH_DCN_MA_HSOq(b_ngay number,b_ma varchar2,b_dthu number) return number
AS
    b_kq number:=0; b_ngayM number; b_dthuM number; b_cd varchar2(1);
begin
-- Dan - Tra he so thuong theo doanh thu nhom cho quan ly
b_cd:=FBH_DCN_MAc(b_ma);
if b_cd>'0' then b_cd:='1'; end if;
select nvl(max(ngay),0) into b_ngayM from bh_dcn_ma_hsoQ where ngay<=b_ngay;
if b_ngayM<>0 then
    select nvl(max(dthu),0) into b_dthuM from bh_dcn_ma_hsoQ where ngay=b_ngayM and cd=b_cd and dthu<=b_dthu;
    if b_dthuM<>0 then
        select hso into b_kq from bh_dcn_ma_hsoQ where ngay=b_ngayM and cd=b_cd and dthu=b_dthuM;
    end if;
end if;
return b_kq;
end;
/
create or replace function FBH_DCN_MA_HSOt(b_ngay number) return number
AS
    b_kq number:=0; b_ngayM number;
begin
-- Dan - Tra thuong tuyen dung
select nvl(max(ngay),0) into b_ngayM from bh_dcn_ma_hsot where ngay<=b_ngay;
if b_ngayM<>0 then
    select tien into b_kq from bh_dcn_ma_hsoT where ngay=b_ngayM;
end if;
return b_kq;
end;
/
/*** Dai ly to chuc tra hoa hong ca nhan ***/
create or replace function FBH_DTC_MA_HHONG(
	b_ma varchar2,b_nv varchar2,b_sp varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number;
begin
-- Kiem tra dai ly to chuc tra hoa hong cho ca nhan
select count(*) into b_i1 from bh_dtc_ma_hh where ma=b_ma and nv=b_nv and sp=b_sp;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_DTC_MA_PBO(b_ma varchar2,ngay number) return number
AS
    b_kq number:=100; b_ngayM number;
begin
-- Tra ho so phan bo ca nhan va to chuc
select nvl(max(ngay),0) into b_ngayM from bh_dtc_ma_pbo where ma=b_ma;
if b_ngayM<>0 then
	select nvl(min(pbo),100) into b_kq from bh_dtc_ma_pbo where ma=b_ma and ngay=b_ngayM;
end if;
return b_kq;
end;
/
create or replace procedure PBH_DTC_MA_HHONG(
	b_ma varchar2,b_nv varchar2,b_sp varchar2,b_lh_nv varchar2,b_ngay number,b_hhong out number,b_htro out number,b_dvu out number)
AS
    b_ngayM number;
begin
-- Tra ty le hoa hong
select nvl(max(ngay),0) into b_ngayM from bh_dtc_ma_hh where ma=b_ma and nv=b_nv and sp=b_sp and ngay<=b_ngay;
if b_ngay=0 then
	b_hhong:=0; b_htro:=0; b_dvu:=0;
else
	select nvl(min(hhong),0),nvl(min(htro),0),nvl(min(dvu),0) into b_hhong,b_htro,b_dvu
		from bh_dtc_ma_hh where ma=b_ma and nv=b_nv and sp=b_sp and ngay=b_ngayM and lh_nv=b_lh_nv;
end if;
end;
/
