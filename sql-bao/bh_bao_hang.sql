create or replace function FBH_BAO_BGHD_HANG(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1):=''; b_i1 number;
begin
-- Dan - Tra da chuyen HD
select count(*) into b_i1 from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then b_kq:='V'; end if;
return b_kq;
end;
/
create or replace procedure PTBH_BAO_TAO_HANG(
    b_ma_dvi varchar2,b_so_id number,
    a_ma_dvi out pht_type.a_var,a_kieu out pht_type.a_var,
    a_so_hd out pht_type.a_var,a_so_id out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_ngay_hl number; b_ngay_kt number;
    b_kieu_ps varchar2(1); b_nv varchar2(10);b_so_hd varchar2(20);
    b_bt number:=1; b_kt number:=1; b_bd number; b_uoc number; b_vchuyen varchar2(10); b_nhang varchar2(10);
    a_ngay_hl pht_type.a_num; a_ngay_kt pht_type.a_num;
begin
-- Dan - Tim doi tuong ghep
PTBH_TM_TTIN(b_ma_dvi,b_so_id,b_kieu_ps,b_nv,b_so_hd,b_loi);
if b_loi is not null then return; end if;
if b_kieu_ps='H' then
    select vchuyen,thoi_gian,nhang,ngay_cap into b_vchuyen,b_uoc,b_nhang,b_ngay_hl
    from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    select vchuyen,thoi_gian,nhang,ngay_cap into b_vchuyen,b_uoc,b_nhang,b_ngay_hl
    from bh_hangB where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
if b_uoc=0 then b_uoc:=FBH_HANG_NHANG_UOC(b_nhang); end if;
if b_uoc=0 then
   PKH_MANG_KD(a_ma_dvi); PKH_MANG_KD_N(a_so_id); PKH_MANG_KD(a_kieu); PKH_MANG_KD(a_so_hd);
end if;
a_ma_dvi(1):=b_ma_dvi; a_so_id(1):=b_so_id; a_kieu(1):=b_kieu_ps; a_so_hd(1):=b_so_hd;
b_ngay_kt:=PKH_NG_CSO(PKH_SO_CDT(b_ngay_hl)+b_uoc);
if b_uoc<>0 and FBH_HANG_PT_TAI(b_vchuyen)='C' then 
   for r_lp in (select pt,ten_pt,so_imo from bh_hangB_ptvc where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
     if nvl(r_lp.so_imo,' ')<>' ' or nvl(r_lp.ten_pt,' ')<>' 'then
       for r_lp1 in (select ma_dvi,so_id,pt,ten_pt,so_imo,ngay_cap,ngay_hl,ngay_kt,ttrang from bh_hang_ttu
            where so_id<>b_so_id and hd_kem='K' and kieu_hd in('G','K') and ttrang='D' and vchuyen=b_vchuyen and
              pt=r_lp.pt and ten_pt=r_lp.ten_pt and so_imo=r_lp.so_imo and
              FKH_GIAO(b_ngay_hl,b_ngay_kt,ngay_cap,PKH_NG_CSO(PKH_SO_CDT(ngay_cap)+b_uoc))='C') loop
              if FBH_HD_CO_TAM(r_lp1.ma_dvi,r_lp1.so_id)='C' then
                b_bt:=b_bt+1;
                a_ma_dvi(b_bt):=r_lp1.ma_dvi; a_so_id(b_bt):=r_lp1.so_id;
                a_ngay_hl(b_bt):=r_lp1.ngay_hl; a_ngay_kt(b_bt):=r_lp1.ngay_kt;
                a_kieu(b_bt):='H';
            end if;
         end loop;
     end if;
     loop
          b_bd:=b_kt+1; b_kt:=b_bt;
          for b_lp in b_bd..b_kt loop
              for r_lp1 in (select ma_dvi,so_id,pt,ten_pt,so_imo,ngay_cap,ngay_hl,ngay_kt,ttrang from bh_hang_ttu
                where so_id<>b_so_id and hd_kem='K' and kieu_hd in('G','K') and ttrang='D' and vchuyen=b_vchuyen and
                  pt=r_lp.pt and ten_pt=r_lp.ten_pt and so_imo=r_lp.so_imo and
                  FKH_GIAO(a_ngay_hl(b_lp),a_ngay_kt(b_lp),ngay_hl,ngay_kt)='C') loop
                  b_i1:=0;
                  for b_lp1 in 1..a_ma_dvi.count loop
                      if r_lp1.so_id=a_so_id(b_lp1) then b_i1:=1; exit; end if;
                  end loop;
                  if b_i1=0 then
                      b_bt:=b_bt+1;
                      a_ma_dvi(b_bt):=r_lp1.ma_dvi; a_so_id(b_bt):=r_lp1.so_id;
                      a_ngay_hl(b_bt):=r_lp1.ngay_hl; a_ngay_kt(b_bt):=r_lp1.ngay_kt;
                      a_kieu(b_bt):='H';
                  end if;
              end loop;
          end loop;
          exit when b_kt=b_bt;
      end loop;
    end loop;
end if;
for b_lp in 2..b_kt loop
    a_so_hd(b_lp):=FBH_HANG_SO_HDd(a_ma_dvi(b_lp),a_so_id(b_lp));
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_CBI_TAO_HANG:loi'; else null; end if;
end;
/
create or replace procedure PBH_BAO_DK_HANG(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_loi out varchar2)
AS
    b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Dan - Liet ke nghiep vu theo hop dong
delete bh_hd_nv_temp;
select nvl(min(nt_tien),' '),min(nt_phi) into b_nt_tien,b_nt_phi from bh_bao where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nt_tien<>' ' then
    insert into bh_hd_nv_temp 
    select 0,a.ten_hang,a.ma_lhang,b.lh_nv,b_nt_tien,b.tien,b.tien,b_nt_phi,b.phi
        from bh_hangB_ds a,bh_hangB_dk b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id
        and b.ma_dvi=b_ma_dvi and b.so_id=b_so_id;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BAO_DK_HANG:loi'; else null; end if;
end;
/
create or replace procedure PTBH_BAO_NV_HANGd(
    b_ma_dvi varchar2,b_so_id number,
    b_ngay_ht number,b_ngay_hl number,b_ngay_kt number,
    b_nt_tien varchar2,b_nt_phi varchar2,b_loi out varchar2)
AS
begin
-- Dan - Ghep nghiep vu bao => nghiep vu tai cho 1 doi tuong
PBH_BAO_DK_HANG(b_ma_dvi,b_so_id,0,b_loi);
if b_loi is not null then return; end if;
PTBH_BAO_TEMP2(b_ma_dvi,b_so_id,0,b_ngay_ht,b_nt_tien,b_nt_phi,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_BAO_NV_HANGd:loi'; else null; end if;
end;
/
create or replace procedure PTBH_BAO_NV_HANG(
    b_ma_dvi varchar2,b_so_id number,b_ma_dt out varchar2,b_loi out varchar2)
AS
    b_ngay_ht number; b_ngay_hl number; b_ngay_kt number; b_tp number:=0;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5);
    a_ma_taT pht_type.a_var; a_ptT pht_type.a_num;
begin
-- Dan - Ghep nghiep vu hang
delete tbh_ghep_nv_temp; delete tbh_ghep_nv_temp2;
select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
    from bh_hangB where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nt_tien<>'VND' then b_tp:=2; end if;
PTBH_BAO_NV_HANGd(b_ma_dvi,b_so_id,b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_loi);
if b_loi is not null then return; end if;
b_ma_dt:=' ';
PTBH_BAO_TEMP(b_ma_dvi,b_so_id,0,b_nt_tien,b_nt_phi,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_BAO_NV_HANG:loi'; else null; end if;
end;
/
create or replace procedure PTBH_BAO_NV_HANGc(
    b_ma_dvi varchar2,b_so_id number,
    a_ma_dvi pht_type.a_var,a_kieu pht_type.a_var,a_so_id pht_type.a_num,
    b_ma_dt out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_ngay_ht number; b_ngay_hl number; b_ngay_kt number; b_tp number:=0;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_kieu varchar2(1);
begin
-- Dan - Ghep nghiep vu hang
select count(*) into b_i1 from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then
    b_kieu:='H';
    select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
        from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    b_kieu:='B';
    select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
        from bh_hangB where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
if b_nt_tien<>'VND' then b_tp:=2; end if;
b_ma_dt:=' ';
for b_lp in 1..a_ma_dvi.count loop
    if a_kieu(b_lp)='B' then
        PTBH_BAO_NV_HANGd(a_ma_dvi(b_lp),a_so_id(b_lp),b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_loi);
        if b_loi is not null then return; end if;
    else
        PTBH_GHEP_NV_1(0,b_ngay_ht,b_ngay_hl,b_nt_tien,b_nt_phi,
            a_ma_dvi(b_lp),a_so_id(b_lp),0,b_loi,'{"xly":"C","nv":"HANG"}');
    end if;
    if b_loi is not null then return; end if;
end loop;
PTBH_BAO_TEMPc(b_nt_tien,b_nt_phi,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_BAO_NV_HANG:loi'; else null; end if;
end;
/
