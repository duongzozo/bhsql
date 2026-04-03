create or replace function FBH_BAO_BGHD_HOP(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1):=' '; b_i1 number;
begin
-- Nam - Tra da chuyen HD
select count(*) into b_i1 from bh_hop where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then b_kq:='V'; end if;
return b_kq;
end;
/
create or replace procedure PTBH_BAO_GHDT_HOP(
    b_ma_dvi varchar2,b_so_id number,a_so_id_dt out pht_type.a_num,b_loi out varchar2)
AS
begin
-- Nam - Doi tuong bao gia hon hop
b_loi:='loi:Loi xu ly PTBH_BAO_GHDT_HOP:loi';
if FBH_BAO_BGHD_HOP(b_ma_dvi,b_so_id)=' ' then
	select so_id_dt bulk collect into a_so_id_dt from bh_hopB_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
	select so_id_dt bulk collect into a_so_id_dt from bh_hop_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace  procedure PBH_BAO_DK_HOP(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_loi out varchar2)
AS
    a_so_id_dtK pht_type.a_num; a_dviK pht_type.a_var; a_ma_dtK pht_type.a_var;
    a_lh_nvK pht_type.a_var; a_nt_tienK pht_type.a_var; a_tienK pht_type.a_num;
    a_nt_phiK pht_type.a_var; a_phiK pht_type.a_num;
    b_ngay_ht number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Nam - Liet ke nghiep vu theo hop dong
b_loi:='';
end;
/
