create or replace function FBH_SOAN_BGHD_PTN(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(10):=' '; b_i1 number;
begin
-- Nam - Tra da chuyen HD
select count(*) into b_i1 from bh_ptncc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then
    b_kq:='CC';
else
    select count(*) into b_i1 from bh_ptnnn where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 then
        b_kq:='NN';
    else
        select count(*) into b_i1 from bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_id;
        if b_i1<>0 then b_kq:='HH'; end if;
    end if;
end if;
return b_kq;
end;
/
create or replace procedure PBH_SOAN_DK_PTN(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    a_so_id_dtK pht_type.a_num; a_dviK pht_type.a_var; a_ma_dtK pht_type.a_var;
    a_lh_nvK pht_type.a_var; a_nt_tienK pht_type.a_var; a_tienK pht_type.a_num;
    a_nt_phiK pht_type.a_var; a_phiK pht_type.a_num; 
    b_ngay_ht number; b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_ch varchar(10);
begin
-- Dan - Liet ke nghiep vu theo hop dong
delete bh_hd_nv_temp;
b_ch:=FBH_SOAN_BGHD_PTN(b_ma_dvi,b_so_id);
if b_ch=' ' then
    select ngay_ht,nt_tien,nt_phi into b_ngay_ht,b_nt_tien,b_nt_phi from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
    insert into bh_hd_nv_temp select 0,' ',' ', lh_nv,b_nt_tien,sum(tien),0,b_nt_phi,sum(phi)
        from bh_ptn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id group by lh_nv;
elsif b_ch='CC' then
    select ngay_ht,nt_tien,nt_phi into b_ngay_ht,b_nt_tien,b_nt_phi from bh_ptncc where ma_dvi=b_ma_dvi and so_id=b_so_id;
    insert into bh_hd_nv_temp select 0,' ',' ', lh_nv,b_nt_tien,sum(tien),0,b_nt_phi,sum(phi)
        from bh_ptncc_dk where ma_dvi=b_ma_dvi and so_id=b_so_id group by lh_nv;
elsif b_ch='NN' then
    select ngay_ht,nt_tien,nt_phi into b_ngay_ht,b_nt_tien,b_nt_phi from bh_ptnnn where ma_dvi=b_ma_dvi and so_id=b_so_id;
    insert into bh_hd_nv_temp select 0,' ',' ', lh_nv,b_nt_tien,sum(tien),0,b_nt_phi,sum(phi)
        from bh_ptnnn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id group by lh_nv;
else
    select ngay_ht,nt_tien,nt_phi into b_ngay_ht,b_nt_tien,b_nt_phi from bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_id;
    insert into bh_hd_nv_temp select 0,' ',' ', lh_nv,b_nt_tien,sum(tien),0,b_nt_phi,sum(phi)
        from bh_ptnvc_dk where ma_dvi=b_ma_dvi and so_id=b_so_id group by lh_nv;
end if;
update bh_hd_nv_temp set tien_vnd=tien;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_SOAN_DK_PTN:loi'; end if;
end;
/
create or replace procedure PTBH_SOAN_NV_PTNd(
    b_ma_dvi varchar2,b_so_id number,
    b_ngay_ht number,b_ngay_hl number,b_ngay_kt number,
    b_nt_tien varchar2,b_nt_phi varchar2,b_loi out varchar2)
AS
begin
-- Dan - Ghep nghiep vu SOAN => nghiep vu tai cho 1 doi tuong
PBH_SOAN_DK_PTN(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
PTBH_BAO_TEMP2(b_ma_dvi,b_so_id,0,b_ngay_ht,b_nt_tien,b_nt_phi,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_SOAN_NV_PTNd:loi'; end if;
end;
/
create or replace procedure PTBH_SOAN_NV_PTN(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ngay_ht number; b_ngay_hl number; b_ngay_kt number;b_tp number:=0;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_ch varchar2(5);
begin
-- Dan - Ghep nghiep vu ptn
b_ch:=FBH_SOAN_BGHD_PTN(b_ma_dvi,b_so_id);
    if b_ch=' ' then
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_ch='CC' then
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_ptncc where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_ch='NN' then
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_ptnnn where ma_dvi=b_ma_dvi and so_id=b_so_id;
    else
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_id;
    end if;
PTBH_SOAN_NV_PTNd(b_ma_dvi,b_so_id,b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_loi);
if b_loi is not null then return; end if;
PTBH_BAO_TEMP(b_ma_dvi,b_so_id,0,b_nt_tien,b_nt_phi,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_SOAN_NV_PTN:loi'; end if;
end;
/
