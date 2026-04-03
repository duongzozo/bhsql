create or replace function FTBH_XOL_PS_SO_CT(b_so_ct varchar2) return number
AS
    b_so_id number;
begin
-- Dan - Tra so ID qua so CT
select nvl(min(so_id),0) into b_so_id from tbh_xol_ps where so_ct=b_so_ct;
return b_so_id;
end;
/
create or replace function FTBH_XOL_PS_SO_CTd(b_so_ct varchar2) return number
AS
    b_so_id number;
begin
-- Dan - Tra so ID qua so CT
select nvl(min(so_id_d),0) into b_so_id from tbh_xol_ps where so_ct=b_so_ct;
return b_so_id;
end;
/
create or replace function FTBH_XOL_PS_NGAY_DAU(b_so_id number) return number
AS
    b_so_idD number; b_ngayD number;
begin
-- Dan - Tra so ID tai dau
b_so_idD:=FTBH_XOL_PS_SO_ID_DAU(b_so_id);
select nvl(min(ngay_hl),0) into b_ngayD from tbh_xol_ps where so_id=b_so_idD;
return b_ngayD;
end;
/
create or replace function FTBH_XOL_PS_NT_TA(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(5);
begin
-- Dan - Nguyen te hop dong tai di
select nvl(min(nt_tien),'USD') into b_kq from tbh_xol_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FTBH_XOL_SO_TA(b_ma_dvi varchar2,b_nv varchar2,b_ngay_ht number) return varchar2
AS
    b_kq varchar2(50); b_stt number; b_nam number;
begin
-- Dan - Tra so tai
b_nam:=round(b_ngay_ht/10000,0);
b_stt:=FBH_KH_SO_TT(b_ma_dvi,'TAX',b_nv,b_nam);
b_kq:=trim(to_char(b_stt))||'/'||substr(trim(to_char(b_nam)),3)||'/TAX-'||b_nv;
return b_kq;
end;
/
create or replace function FTBH_XOL_SO_BS(b_so_id number) return varchar2
AS
    b_so_idD number; b_so_ct varchar2(20); b_so_bs varchar2(20); b_stt number; b_i1 number:=1; 
begin
-- Dan - Tra so sua doi bo sung
b_so_idD:=FTBH_XOL_PS_SO_ID_DAU(b_so_id);
select min(so_ct),count(*) into b_so_ct,b_stt from tbh_xol_ps where so_id_d=b_so_idD;
while b_i1<>0 loop
     b_so_bs:=b_so_ct||'/'||'BS'||trim(to_char(b_stt));
     select count(*) into b_i1 from tbh_xol_ps where so_ct=b_so_bs;
     b_stt:=b_stt+1;
end loop;
return b_so_bs;
end;
/
create or replace function FTBH_XOL_SO_ID_TA(
    b_ngay number,b_so_id number,b_ma_ta varchar2) return number
AS
    b_so_id_ta number:=0; b_so_idB number; b_ngay_hl number; b_ngay_kt number; b_nv varchar2(10);
begin
-- Dan - Tra ID cua hop dong tai XOL
b_so_idB:=FTBH_XOL_PS_SO_ID_BS(b_so_id,b_ngay);
select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from tbh_xol_ps where so_id=b_so_idB;
if b_ngay between b_ngay_hl and b_ngay_kt then
    select nvl(min(so_id_ta),0) into b_so_id_ta from tbh_xol_ps_tl where so_id=b_so_idB and ma_ta=b_ma_ta;
end if;
return b_so_id_ta;
end;
/
create or replace procedure PTBH_XOL_SO_ID_TA(
    b_ma_dvi_hd varchar2,b_so_id_hd number,a_so_id_ta out pht_type.a_num)
AS
    b_so_idD number;
begin
-- Dan - Tra mang so ID dau tai XOL qua so ID hop dong
b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi_hd,b_so_id_hd);
select distinct b.so_id_d BULK COLLECT into a_so_id_ta from tbh_xol_ps_hd a,tbh_xol_ps b where
    a.ma_dvi_hd=b_ma_dvi_hd and a.so_id_hd=b_so_idD and b.so_id=a.so_id;
end;
/
create or replace function FTBH_XOL_PS_SO_ID_DT_TA(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_hd varchar2,b_so_id_hd number,b_so_id_dt number) return boolean
AS
    b_so_idD number; b_i1 number; b_kq boolean:=false;
begin
-- Dan - Ktra hop dong tai XOL chua so ID hop dong va so ID doi tuong
b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi_hd,b_so_id_hd);
select count(*) into b_i1 from (select * from tbh_xol_ps_hd where so_id=b_so_id)
    where ma_dvi_hd=b_ma_dvi_hd and so_id_hd=b_so_idD and so_id_dt=b_so_id_dt;
if b_i1<>0 then b_kq:=true; end if;
return b_kq;
end;
/
create or replace function FTBH_XOL_PS_SO_ID_TR(b_so_id number,b_ngay_ht number:=30000101) return number
AS
    b_so_idD number; b_kq number;
begin
-- Dan - Tra so ID truoc
b_so_idD:=FTBH_XOL_PS_SO_ID_DAU(b_so_id);
select nvl(max(so_id),0) into b_kq from (select so_id,ngay_ht from tbh_xol_ps where so_id_d=b_so_idD) where ngay_ht<=b_ngay_ht;
return b_kq;
end;
/
create or replace function FTBH_XOL_PS_SO_ID_BS(b_so_id number,b_ngay_ht number:=30000101) return number
AS
    b_so_idD number; b_kq number;
begin
-- Dan - Tra so ID tai bo sung qua so ID
b_so_idD:=FTBH_XOL_PS_SO_ID_DAU(b_so_id);
select nvl(max(so_id),b_so_id) into b_kq from (select so_id,ngay_ht from tbh_xol_ps where so_id_d=b_so_idD) where ngay_ht<=b_ngay_ht;
return b_kq;
end;
/
create or replace function FTBH_XOL_PS_SO_ID_DAU(b_so_id number) return number
AS
    b_so_idD number;
begin
-- Dan - Tra so ID tai dau qua so ID
select nvl(min(so_id_d),0) into b_so_idD from tbh_xol_ps where so_id=b_so_id;
return b_so_idD;
end;
/
create or replace function FTBH_XOL_PS_SO_CT_DAU(b_so_ct varchar2) return number
AS
    b_so_idD number;
begin
-- Dan - Tra so ID tai dau qua so_ct
select nvl(min(so_id_d),0) into b_so_idD from tbh_xol_ps where so_ct=b_so_ct;
return b_so_idD;
end;
/
create or replace function FTBH_XOL_PS_SO_ID_GOC(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_so_id_g number;
begin
--  Tra so ID goc qua so ID xu ly
select nvl(min(so_id_g),0) into b_so_id_g from tbh_xol_ps where so_id=b_so_id;
return b_so_id_g;
end;
/
create or replace function FTBH_XOL_PS_NV(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
select min(nv) into b_kq from tbh_xol_ps where so_id=b_so_id;
return b_kq;
end;
/
create or replace function FTBH_XOL_PS_NGAY_XL(b_so_id number) return number
AS
    b_kq number;
begin
-- Dan - Ngay xu ly XOL
select nvl(min(ngay_ht),0) into b_kq from tbh_xol_ps where so_id=b_so_id;
return b_kq;
end;
/
create or replace function FTBH_XOL_PS_NGAY_HL(b_so_id number) return number
AS
    b_kq number;
begin
-- Dan - Ngay hieu luc XOL
select nvl(min(ngay_hl),0) into b_kq from tbh_xol_ps where so_id=b_so_id;
return b_kq;
end;
/
create or replace function FTBH_XOL_PS_NGAY_KT(b_so_id number) return number
AS
    b_kq number;
begin
-- Dan - Ngay ket thuc XOL
select nvl(min(ngay_kt),0) into b_kq from tbh_xol_ps where so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure PTBH_XOL_PS_NGAYf(
	b_so_id number,b_ngay_ht out number,b_ngay_hl out number,b_ngay_kt out number)
AS
begin
-- Dan - Ngay hop dong tai
select nvl(min(ngay_ht),0),nvl(min(ngay_hl),0),nvl(min(ngay_kt),0)
	into b_ngay_ht,b_ngay_hl,b_ngay_kt from tbh_xol_ps where so_id=b_so_id;
end;
/
