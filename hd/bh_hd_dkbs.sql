/*** DIEU KHOAN BO XUNG HOP DONG GOC ***/
create or replace procedure PBH_DKBS_BANG
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_dkbs out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Dan - Cau truc bang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs_dkbs for select * from bh_hd_goc_dkbs where rownum=0;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DKBS_DK(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Dan - Liet ke dieu khoan co bo sung
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs1 for select ma,ten from bh_ma_dk where ma_dvi=b_ma_dvi and ma in
	(select distinct ma_dk from bh_ma_dk_bs where ma_dvi=b_ma_dvi) order by ma;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DKBS_DKBS(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_dk varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Dan - Liet ke dieu khoan bo sung cua 1 dieu khoan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs1 for select ma,ten,'X' as tt from bh_ma_dk_bs where ma_dvi=b_ma_dvi and ma_dk=b_ma_dk order by ma;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DKBS_TEN(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
	b_ma_dk varchar2,b_ma varchar2,b_ten out varchar2)
AS
	b_loi varchar2(100);
begin
-- Dan - Ten dieu khoan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Dieu khoan bo sung '||b_ma||' chua dang ky:loi';
select ten into b_ten from bh_ma_dk_bs where ma_dvi=b_ma_dvi and ma_dk=b_ma_dk and ma=b_ma;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DKBS_TINH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
	b_so_hd_g varchar2,b_ngay_ht number,b_nt_phi varchar2,
	a_lh_nv pht_type.a_var,a_k_phi pht_type.a_var,a_phi pht_type.a_num,b_thue out number,b_ttoan out number)
AS
	b_loi varchar2(200); b_ngay_phi number;
	a_nt_phi pht_type.a_var; a_phi_dt pht_type.a_num; a_thue pht_type.a_num;
	a_ttoan pht_type.a_num; a_k_thue pht_type.a_var; a_c_thue pht_type.a_var; a_t_suat pht_type.a_num;
begin
-- Dan - Tinh tong phi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
for b_lp in 1..a_lh_nv.count loop
	a_nt_phi(b_lp):=b_nt_phi;
end loop;
b_ngay_phi:=FBH_HD_NGAY_DAU(b_ma_dvi,b_so_hd_g,b_ngay_ht);
PBH_HD_GOC_TINH_CT(b_ma_dvi,b_ngay_phi,a_lh_nv,a_k_phi,a_nt_phi,a_phi,a_k_thue,a_c_thue,a_t_suat,a_thue,a_ttoan,a_phi_dt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_thue:=0; b_ttoan:=0;
for b_lp in 1..a_lh_nv.count loop
	b_thue:=b_thue+a_thue(b_lp); b_ttoan:=b_ttoan+a_ttoan(b_lp);
end loop;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DKBS_XL(b_ma_dvi varchar2,b_ngay_d number,b_nt_phi varchar2,
	dkbs_lh_nv pht_type.a_var,dkbs_tien pht_type.a_num,dkbs_k_phi pht_type.a_var,dkbs_phi pht_type.a_num,
	dkbs_nt_phi out pht_type.a_var,dkbs_k_thue out pht_type.a_var,dkbs_c_thue out pht_type.a_var,
	dkbs_t_suat out pht_type.a_num,dkbs_thue out pht_type.a_num,dkbs_ttoan out pht_type.a_num,
	dkbs_phi_dt out pht_type.a_num,dkbs_kphi out pht_type.a_var,dkbs_giam out pht_type.a_num,b_loi out varchar2)
AS
begin
-- Dan - Xu ly mang tinh phi bo sung
for b_lp in 1..dkbs_lh_nv.count loop
	dkbs_nt_phi(b_lp):=b_nt_phi; dkbs_giam(b_lp):=0;
	if dkbs_tien(b_lp)<>0 then dkbs_kphi(b_lp):='C'; else dkbs_kphi(b_lp):='P'; end if;
end loop;
PBH_HD_GOC_TINH_CT(b_ma_dvi,b_ngay_d,dkbs_lh_nv,dkbs_k_phi,dkbs_nt_phi,dkbs_phi,
	dkbs_k_thue,dkbs_c_thue,dkbs_t_suat,dkbs_thue,dkbs_ttoan,dkbs_phi_dt,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
