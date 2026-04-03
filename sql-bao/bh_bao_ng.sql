create or replace function FBH_BAO_BGHD_NG(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(10):=' '; b_i1 number;
begin
-- Dan - Tra da chuyen HD
select count(*) into b_i1 from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then b_kq:='SK';
else
	select count(*) into b_i1 from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_id;
	if b_i1<>0 then b_kq:='DL'; end if;
end if;
return b_kq;
end;
/
create or replace procedure PBH_BAO_DK_NG(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_loi out varchar2)
AS
    b_i1 number; b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_ch varchar2(1);
begin
-- Dan - Liet ke nghiep vu theo hop dong
delete bh_hd_nv_temp;
select nvl(min(nt_tien),' '),min(nt_phi) into b_nt_tien,b_nt_phi from bh_bao where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nt_tien=' ' then b_loi:=''; return; end if;
b_ch:=FBH_BAO_BGHD_NG(b_ma_dvi,b_so_id);
if b_ch=' ' then
    insert into bh_hd_nv_temp select 0,' ',' ', lh_nv,b_nt_tien,sum(tien),0,b_nt_phi,sum(phi)
        from bh_ngB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id group by lh_nv;
else
    select count(*) into b_i1 from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 then
        insert into bh_hd_nv_temp select 0,' ',' ', lh_nv,b_nt_tien,sum(tien),0,b_nt_phi,sum(phi)
            from bh_ng_dk where ma_dvi=b_ma_dvi and so_id=b_so_id group by lh_nv;
    elsif b_ch='SK' then
        insert into bh_hd_nv_temp select 0,' ',' ', lh_nv,b_nt_tien,sum(tien),0,b_nt_phi,sum(phi)
            from bh_sk_dk where ma_dvi=b_ma_dvi and so_id=b_so_id group by lh_nv;
    elsif b_ch='DL' then
        insert into bh_hd_nv_temp select 0,' ',' ', lh_nv,b_nt_tien,sum(tien),0,b_nt_phi,sum(phi)
            from bh_ngdl_dk where ma_dvi=b_ma_dvi and so_id=b_so_id group by lh_nv;
    else
        insert into bh_hd_nv_temp select 0,' ',' ', lh_nv,b_nt_tien,sum(tien),0,b_nt_phi,sum(phi)
            from bh_ngtd_dk where ma_dvi=b_ma_dvi and so_id=b_so_id group by lh_nv;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BAO_DK_NG:loi'; else null; end if;
end;
/
create or replace procedure PTBH_BAO_NV_NGd(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ngay_ht number; b_ngay_hl number; b_ngay_kt number; b_i1 number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_ch varchar2(10);
begin
-- Dan - Ghep nghiep vu bao => nghiep vu tai cho 1 doi tuong
b_ch:=FBH_BAO_BGHD_NG(b_ma_dvi,b_so_id);
if b_ch=' ' then
    select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
        from bh_ngB where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    select count(*) into b_i1 from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 then
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_ch='SK' then
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_ch='DL' then
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_id;
    else
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_id;
    end if;
end if;
PBH_BAO_DK_NG(b_ma_dvi,b_so_id,0,b_loi);
if b_loi is not null then return; end if;
PTBH_BAO_TEMP2(b_ma_dvi,b_so_id,0,b_ngay_ht,b_nt_tien,b_nt_phi,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_BAO_NV_NGd:loi'; else null; end if;
end;
/
create or replace procedure PTBH_BAO_NV_NG(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ngay_ht number; b_ngay_hl number; b_ngay_kt number; b_tp number:=0;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_i1 number; b_ch varchar2(10);
    a_ma_taT pht_type.a_var; a_ptT pht_type.a_num;
begin
-- Dan - Ghep nghiep vu ng
delete tbh_ghep_nv_temp; delete tbh_ghep_nv_temp2;
b_ch:=FBH_BAO_BGHD_NG(b_ma_dvi,b_so_id);
if b_ch=' ' then
    select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
        from bh_ngB where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    select count(*) into b_i1 from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 then
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_ch='SK' then
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_ch='DL' then
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_id;
    else
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_id;
    end if;
end if;
if b_nt_tien<>'VND' then b_tp:=2; end if;
PTBH_BAO_NV_NGd(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
PTBH_BAO_TEMP(b_ma_dvi,b_so_id,0,b_nt_tien,b_nt_phi,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_BAO_NV_NG:loi'; else null; end if;
end;
/
create or replace procedure PTBH_BAO_NV_NGc(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_ngay_ht number; b_ngay_hl number; b_ngay_kt number; b_tp number:=0;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Dan - Ghep nghiep vu ng
if FBH_BAO_BGHD_NG(b_ma_dvi,b_so_id)=' ' then
    select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
        from bh_ngB where ma_dvi=b_ma_dvi and so_id=b_so_id;
    PTBH_BAO_NV_NGd(b_ma_dvi,b_so_id,b_loi);
else
    select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
        from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
    PTBH_GHEP_NV_1(0,b_ngay_ht,b_ngay_hl,b_nt_tien,b_nt_phi,b_ma_dvi,b_so_id,0,b_loi,'{"xly":"C","nv":"NG"}');
end if;
if b_loi is not null then return; end if;
PTBH_BAO_TEMPc(b_nt_tien,b_nt_phi,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_BAO_NV_NGc:loi'; end if;
end;
/
create or replace function FTBH_BAO_NV_NGd(b_ma_dvi varchar2,b_so_id number,b_dk varchar2:='H') return number
AS
    b_kq number:=0; b_tienX number;
begin
-- Dan - Tim doi tuong co muc TN cao nhat
if b_dk='H' then
    select nvl(max(tien),0) into b_tienX from bh_ng_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_tienX<>0 then
        select nvl(min(so_id_dt),0) into b_kq from bh_ng_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and tien=b_tienX;
    end if;
end if;
if b_kq=0 then
    select nvl(max(tien),0) into b_tienX from bh_ngB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_tienX<>0 then
        select nvl(min(so_id_dt),0) into b_kq from bh_ngB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and tien=b_tienX;
    end if;
end if;
return b_kq;
end;
/
