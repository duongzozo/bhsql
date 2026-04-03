create or replace function FBH_BAO_BGHD_TAU(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1):=' '; b_i1 number;
begin
-- Dan - Tra da chuyen HD
select count(*) into b_i1 from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then b_kq:='V'; end if;
return b_kq;
end;
/
create or replace procedure PTBH_BAO_GHDT_TAU(
    b_ma_dvi varchar2,b_so_id number,a_so_id_dt out pht_type.a_num,b_loi out varchar2)
AS
begin
-- Dan - Doi tuong bao gia TAU
--nam: '' -> ' '
if FBH_BAO_BGHD_TAU(b_ma_dvi,b_so_id)=' ' then
	select so_id_dt bulk collect into a_so_id_dt from bh_tauB_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
	select so_id_dt bulk collect into a_so_id_dt from bh_tau_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_BAO_GHDT_TAU:loi'; end if;
end;
/
create or replace procedure PBH_BAO_DK_TAU(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_loi out varchar2)
AS
    b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Dan - Liet ke nghiep vu theo hop dong
delete bh_hd_nv_temp;
select nvl(min(nt_tien),' '),min(nt_phi) into b_nt_tien,b_nt_phi from bh_bao where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nt_tien<>' ' then
    insert into bh_hd_nv_temp 
    select a.so_id_dt,a.ten,a.ma_dt,b.lh_nv,b_nt_tien,b.tien,b.tien,b_nt_phi,b.phi
        from bh_tauB_ds a,bh_tauB_dk b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id
        and b.ma_dvi=b_ma_dvi and b.so_id=b_so_id and b.so_id_dt=a.so_id_dt;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BAO_DK_TAU:loi'; end if;
end;
/
create or replace procedure PTBH_BAO_NV_TAUd(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,
    b_ngay_ht number,b_ngay_hl number,b_ngay_kt number,
    b_nt_tien varchar2,b_nt_phi varchar2,b_loi out varchar2)
AS
begin
-- Dan - Ghep nghiep vu bao => nghiep vu tai cho 1 doi tuong
PBH_BAO_DK_TAU(b_ma_dvi,b_so_id,b_so_id_dt,b_loi);
if b_loi is not null then return; end if;
PTBH_BAO_TEMP2(b_ma_dvi,b_so_id,b_so_id_dt,b_ngay_ht,b_nt_tien,b_nt_phi,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_BAO_NV_TAUd:loi'; end if;
end;
/
create or replace procedure PTBH_BAO_NV_TAU(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,
    b_ma_dt out varchar2,b_loi out varchar2)
AS
    b_ngay_ht number; b_ngay_hl number; b_ngay_kt number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Dan - Ghep nghiep vu tau
--nam
if FBH_BAO_BGHD_TAU(b_ma_dvi,b_so_id)=' ' then
    select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
        from bh_tauB where ma_dvi=b_ma_dvi and so_id=b_so_id;
    b_ma_dt:=FBH_TAUB_MA_DT(b_ma_dvi,b_so_id,b_so_id_dt);
else
    select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
        from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_id;
    b_ma_dt:=FBH_TAU_MA_DT(b_ma_dvi,b_so_id,b_so_id_dt);
end if;
PTBH_BAO_NV_TAUd(b_ma_dvi,b_so_id,b_so_id_dt,b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_loi);
if b_loi is not null then return; end if;
PTBH_BAO_TEMP(b_ma_dvi,b_so_id,b_so_id_dt,b_nt_tien,b_nt_phi,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_BAO_NV_TAU:loi'; end if;
end;
/
create or replace procedure PTBH_BAO_NV_TAUc(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ma_dt out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_ngay_ht number; b_ngay_hl number; b_ngay_kt number; b_tp number:=0;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5);
    a_ma_taT pht_type.a_var; a_ptT pht_type.a_num;
begin
-- Dan - Ghep nghiep vu tau
delete tbh_ghep_nv_temp; delete tbh_ghep_nv_temp2;
if FBH_BAO_BGHD_TAU(b_ma_dvi,b_so_id)=' ' then
--nam
    select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
        from bh_tauB where ma_dvi=b_ma_dvi and so_id=b_so_id;
    b_ma_dt:=FBH_TAUB_MA_DT(b_ma_dvi,b_so_id,b_so_id_dt);
    PTBH_BAO_NV_TAUd(b_ma_dvi,b_so_id,b_so_id_dt,b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_loi);
else
    select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
        from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_id;
    b_ma_dt:=FBH_TAU_MA_DT(b_ma_dvi,b_so_id,b_so_id_dt);
    PTBH_GHEP_NV_1(0,b_ngay_ht,b_ngay_hl,b_nt_tien,b_nt_phi,b_ma_dvi,b_so_id,b_so_id_dt,b_loi,'{"xly":"C","nv":"TAU"}');
end if;
if b_loi is not null then return; end if;
PTBH_BAO_TEMPc(b_nt_tien,b_nt_phi,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_BAO_NV_TAUc:loi'; end if;
end;
/
