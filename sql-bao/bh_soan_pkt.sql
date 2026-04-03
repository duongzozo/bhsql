create or replace procedure PBH_SOAN_DK_PKT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_loi out varchar2)
AS
    b_ngay_ht number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
    b_nv varchar2(10); b_so_hd varchar2(20); b_ngay_hl number; b_ngay_kt number;
    a_so_id_dtK pht_type.a_num; a_dviK pht_type.a_var; a_ma_dtK pht_type.a_var;
    a_lh_nvK pht_type.a_var; a_nt_tienK pht_type.a_var; a_tienK pht_type.a_num;
    a_nt_phiK pht_type.a_var; a_phiK pht_type.a_num;
begin
-- Dan - Liet ke nghiep vu theo hop dong
delete bh_hd_nv_temp;
PTBH_SOAN_TTINf(b_ma_dvi,b_so_id,b_nv,b_so_hd,b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_loi);
if b_loi is not null then return; end if;
select a.so_id_dt,a.ddiem,a.ma_dt,b.lh_nv,b_nt_tien,b.tien,b_nt_phi,b.phi
    bulk collect into a_so_id_dtK,a_dviK,a_ma_dtK,a_lh_nvK,a_nt_tienK,a_tienK,a_nt_phiK,a_phiK
    from bh_pkt_dvi a,bh_pkt_dk b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id
    and b.ma_dvi=b_ma_dvi and b.so_id=b_so_id and b.so_id_dt=a.so_id_dt;
for b_lp in 1..a_so_id_dtK.count loop
    if b_so_id_dt in(0,a_so_id_dtK(b_lp)) then
        insert into bh_hd_nv_temp values(a_so_id_dtK(b_lp),a_dviK(b_lp),a_ma_dtK(b_lp),
            a_lh_nvK(b_lp),a_nt_tienK(b_lp),a_tienK(b_lp),a_tienK(b_lp),a_nt_phiK(b_lp),a_phiK(b_lp));
    end if;
end loop;
if b_nt_tien<>'VND' then
    update bh_hd_nv_temp set tien_vnd=FBH_TT_VND_QD(b_ngay_ht,b_nt_tien,tien);
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_SOAN_DK_PKT:loi'; end if;
end;
/
create or replace procedure PTBH_SOAN_NV_PKTd(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,
    b_ngay_ht number,b_ngay_hl number,b_ngay_kt number,
    b_nt_tien varchar2,b_nt_phi varchar2,b_loi out varchar2)
AS
begin
-- Dan - Ghep nghiep vu bao => nghiep vu tai cho 1 doi tuong
PBH_SOAN_DK_PKT(b_ma_dvi,b_so_id,b_so_id_dt,b_loi);
if b_loi is not null then return; end if;
PTBH_BAO_TEMP2(b_ma_dvi,b_so_id,b_so_id_dt,b_ngay_ht,b_nt_tien,b_nt_phi,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_SOAN_NV_PKTd:loi'; end if;
end;
/
CREATE OR REPLACE PROCEDURE PTBH_SOAN_NV_PKT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,
    a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num,a_so_id_dt pht_type.a_num,
    b_ma_dt out varchar2,b_loi out varchar2)
AS
    b_ngay_ht number; b_ngay_hl number; b_ngay_kt number; b_tp number:=0; b_i1 number;
    b_kieu_ps varchar2(1); b_nv varchar2(10); b_so_hd varchar2(20); b_ttrang varchar2(1);
    b_nt_tien varchar2(5); b_nt_phi varchar2(5);
    a_ma_taT pht_type.a_var; a_ptT pht_type.a_num;
begin
-- Dan - Ghep tich tu voi 1 dtuong bao gia
b_loi:='loi:Loi xu ly PTBH_BAO_NV_PKT:loi';
delete tbh_ghep_nv_temp; delete tbh_ghep_nv_temp2;
PTBH_SOAN_TTINf(b_ma_dvi,b_so_id,b_nv,b_so_hd,b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_loi);
if b_loi is not null then return; end if;
if b_nt_tien<>'VND' then b_tp:=2; end if;
b_ma_dt:=' ';
for b_lp in 1..a_ma_dvi.count loop
    select nvl(max(ma_dt),' ') into b_ma_dt from bh_pkt_dvi where
        ma_dvi=a_ma_dvi(b_lp) and so_id=a_so_id(b_lp) and so_id_dt=a_so_id_dt(b_lp);
    PTBH_SOAN_NV_PKTd(a_ma_dvi(b_lp),a_so_id(b_lp),a_so_id_dt(b_lp),b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_loi);
    if b_loi is not null then return; end if;
end loop;
PTBH_BAO_TEMP(b_ma_dvi,b_so_id,b_so_id_dt,b_nt_tien,b_nt_phi,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_BAO_NV_PKT:loi'; end if;
end;
/
