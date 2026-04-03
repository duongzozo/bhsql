create or replace procedure PBH_SOAN_DK_2B(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_loi out varchar2)
AS
    a_so_id_dtK pht_type.a_num; a_dviK pht_type.a_var; a_ma_dtK pht_type.a_var;
    a_lh_nvK pht_type.a_var; a_nt_tienK pht_type.a_var; a_tienK pht_type.a_num;
    a_nt_phiK pht_type.a_var; a_phiK pht_type.a_num;
    b_ngay_ht number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Dan - Liet ke nghiep vu theo hop dong
delete bh_hd_nv_temp;
select ngay_ht,nt_tien,nt_phi into b_ngay_ht,b_nt_tien,b_nt_phi from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_id;
select a.so_id_dt,decode(a.bien_xe,' ',a.so_khung,a.bien_xe),a.loai_xe,b.lh_nv,b_nt_tien,b.tien,b_nt_phi,b.phi
    bulk collect into a_so_id_dtK,a_dviK,a_ma_dtK,a_lh_nvK,a_nt_tienK,a_tienK,a_nt_phiK,a_phiK
    from bh_2b_ds a,bh_2b_dk b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id
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
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_SOAN_DK_2B:loi'; end if;
end;
/
create or replace procedure PTBH_SOAN_NV_2Bd(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,
    b_ngay_ht number,b_ngay_hl number,b_ngay_kt number,
    b_nt_tien varchar2,b_nt_phi varchar2,b_loi out varchar2)
AS
begin
-- Dan - Ghep nghiep vu bao => nghiep vu tai cho 1 doi tuong
PBH_SOAN_DK_2B(b_ma_dvi,b_so_id,b_so_id_dt,b_loi);
if b_loi is not null then return; end if;
PTBH_BAO_TEMP2(b_ma_dvi,b_so_id,b_so_id_dt,b_ngay_ht,b_nt_tien,b_nt_phi,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_SOAN_NV_2Bd:loi'; end if;
end;
/
create or replace PROCEDURE PTBH_SOAN_NV_2B(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,
    b_ma_dt out varchar2,b_loi out varchar2)
AS
    b_ngay_ht number; b_ngay_hl number; b_ngay_kt number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Dan - Ghep nghiep vu xe
b_loi:='loi:Loi xu ly PTBH_SOAN_NV_2B:loi';
select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
    from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_ma_dt:=FBH_2B_MA_DT(b_ma_dvi,b_so_id,b_so_id_dt);
PTBH_SOAN_NV_2Bd(b_ma_dvi,b_so_id,b_so_id_dt,b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_loi);
if b_loi is not null then return; end if;
PTBH_BAO_TEMP(b_ma_dvi,b_so_id,b_so_id_dt,b_nt_tien,b_nt_phi,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_SOAN_NV_2B:loi'; end if;
end;
/
