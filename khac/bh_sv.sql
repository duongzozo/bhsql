create or replace procedure PBH_SV_KH_SODT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_sodt varchar2,cs1 out pht_type.cs_type,cs2 out pht_type.cs_type)
AS
    b_loi varchar2(100); a_ma_dvi pht_type.a_var; a_ma_kh pht_type.a_var; a_so_id pht_type.a_num;
begin
-- Dan - Thong tin KH qua so DT
delete bh_sv_kh_temp1;
commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select ma_dvi,ma BULK COLLECT into a_ma_dvi,a_ma_kh from bh_hd_ma_kh where phone=b_sodt;
if a_ma_dvi.count=0 then b_loi:='Khong tim thay'; raise PROGRAM_ERROR;
elsif a_ma_dvi.count>100 then b_loi:='Tim thay nhieu hon 100 dong'; raise PROGRAM_ERROR;
end if;
open cs1 for select a.*,FHT_MA_DVI_TEN(ma_dvi) ten_dvi from bh_hd_ma_kh a where phone=b_sodt order by ten;
for b_lp in 1..a_ma_dvi.count loop
    select distinct so_id_d BULK COLLECT into a_so_id from bh_hd_goc where ma_dvi=a_ma_dvi(b_lp) and ma_kh=a_ma_kh(b_lp);
    for b_lp1 in 1..a_so_id.count loop
        insert into bh_sv_kh_temp1 select a_ma_dvi(b_lp),a_ma_kh(b_lp),so_hd,nv from bh_hd_goc
            where ma_dvi=a_ma_dvi(b_lp) and ma_kh=a_ma_kh(b_lp) and so_id_d=a_so_id(b_lp1);
    end loop;
end loop;
open cs2 for select * from bh_sv_kh_temp1;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
