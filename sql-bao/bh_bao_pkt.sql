create or replace function FBH_BAO_BGHD_PKT(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra da chuyen HD
select nvl(min(ttrang),' ') into b_kq from bh_pkt where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure PTBH_BAO_TAO_PKT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,
    a_ma_dvi out pht_type.a_var,a_so_id out pht_type.a_num,
    a_so_id_dt out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_so_idD number; b_so_idB number;
    b_bt number:=0; b_kt number:=0; b_bd number; b_ddiem varchar2(500);
    b_ngay_hl number; b_ngay_kt number; b_tdx number; b_tdy number; b_bk number;
    a_tdx pht_type.a_num; a_tdy pht_type.a_num; a_bk pht_type.a_num;
    a_ngay_hl pht_type.a_num; a_ngay_kt pht_type.a_num;
begin
-- Dan - Tim doi tuong ghep
if FBH_BAO_BGHD_PKT(b_ma_dvi,b_so_id)=' ' then
    select ngay_hl,ngay_kt,tdx,tdy,bk,ddiem into b_ngay_hl,b_ngay_kt,b_tdx,b_tdy,b_bk,b_ddiem
        from bh_pktB_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
else
    select ngay_hl,ngay_kt,tdx,tdy,bk,ddiem into b_ngay_hl,b_ngay_kt,b_tdx,b_tdy,b_bk,b_ddiem
        from bh_pkt_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
end if;
PKH_MANG_KD(a_ma_dvi); PKH_MANG_KD_N(a_so_id); PKH_MANG_KD_N(a_so_id_dt);
if b_tdx=0 or REGEXP_COUNT(b_ddiem, ',')<3 then b_loi:=''; return; end if;
for r_lp in (select ma_dvi,so_id,so_id_dt,tdx,tdy,bk,ngay_hl,ngay_kt from bh_pkt_ttu where 
    FBH_KH_AHUONG(b_tdx,b_tdy,b_bk,tdx,tdy,bk)='C' and FKH_GIAO(b_ngay_hl,b_ngay_kt,ngay_hl,ngay_kt)='C') loop
    b_bt:=b_bt+1;
    a_ma_dvi(b_bt):=r_lp.ma_dvi; a_so_id(b_bt):=r_lp.so_id; a_so_id_dt(b_bt):=r_lp.so_id_dt;
    a_tdx(b_bt):=r_lp.tdx; a_tdy(b_bt):=r_lp.tdy; a_bk(b_bt):=r_lp.bk;
    a_ngay_hl(b_bt):=r_lp.ngay_hl; a_ngay_kt(b_bt):=r_lp.ngay_kt;
end loop;
if b_bt=0 then b_loi:=''; return; end if;
loop
    b_bd:=b_kt+1; b_kt:=b_bt;
    for b_lp in b_bd..b_kt loop
        for r_lp in (select ma_dvi,so_id,so_id_dt,tdx,tdy,bk,ngay_hl,ngay_kt from bh_pkt_ttu where
            so_id_dt<>a_so_id_dt(b_lp) and
            FBH_KH_AHUONG(a_tdx(b_lp),a_tdx(b_lp),a_bk(b_lp),tdx,tdy,bk)='C' and
            FKH_GIAO(a_ngay_hl(b_lp),a_ngay_kt(b_lp),ngay_hl,ngay_kt)='C') loop
            b_i1:=0;
            for b_lp1 in 1..a_ma_dvi.count loop
                if r_lp.so_id_dt=a_so_id_dt(b_lp1) then b_i1:=1; exit; end if;
            end loop;
            if b_i1=0 then
                b_bt:=b_bt+1;
                a_ma_dvi(b_bt):=r_lp.ma_dvi; a_so_id(b_bt):=r_lp.so_id; a_so_id_dt(b_bt):=r_lp.so_id_dt;
                a_tdx(b_bt):=r_lp.tdx; a_tdy(b_bt):=r_lp.tdy; a_bk(b_bt):=r_lp.bk;
                a_ngay_hl(b_bt):=r_lp.ngay_hl; a_ngay_kt(b_bt):=r_lp.ngay_kt;
            end if;
        end loop;
    end loop;
    exit when b_kt=b_bt;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_BAO_TAO_PKT:loi'; else null; end if;
end;
/
create or replace procedure PTBH_BAO_TAO_PKTt(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,
    a_ma_dvi out pht_type.a_var,a_kieu out pht_type.a_var,
    a_so_hd out pht_type.a_var,a_ten out pht_type.a_nvar,
    a_so_id out pht_type.a_num,a_so_id_dt out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_so_idD number; b_so_idB number;
    b_bt number:=1; b_kt number:=1; b_bd number; b_ddiem nvarchar2(500);
    b_kieu_ps varchar2(1); b_nv varchar2(10); b_so_hd varchar2(20); b_ten nvarchar2(500);
    b_ngay_hl number; b_ngay_kt number; b_tdx number; b_tdy number; b_bk number;
    a_tdx pht_type.a_num; a_tdy pht_type.a_num; a_bk pht_type.a_num;
    a_ngay_hl pht_type.a_num; a_ngay_kt pht_type.a_num;
begin
-- Dan - Tim doi tuong ghep
PTBH_TM_TTIN(b_ma_dvi,b_so_id,b_kieu_ps,b_nv,b_so_hd,b_loi);
if b_loi is not null then return; end if;
--nam: chua gan bien b_ddiem
if b_kieu_ps='H' then
    select ngay_hl,ngay_kt,tdx,tdy,bk,dvi,ddiem into b_ngay_hl,b_ngay_kt,b_tdx,b_tdy,b_bk,b_ten,b_ddiem
        from bh_pkt_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
else
    select ngay_hl,ngay_kt,tdx,tdy,bk,ten,ddiem into b_ngay_hl,b_ngay_kt,b_tdx,b_tdy,b_bk,b_ten,b_ddiem
        from bh_pktB_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
end if;
PKH_MANG_KD(a_ma_dvi); PKH_MANG_KD_N(a_so_id); PKH_MANG_KD_N(a_so_id_dt);
PKH_MANG_KD(a_kieu); PKH_MANG_KD(a_so_hd); PKH_MANG_KD_U(a_ten);

a_ma_dvi(1):=b_ma_dvi; a_so_id(1):=b_so_id; a_so_id_dt(1):=b_so_id_dt;
a_kieu(1):=b_kieu_ps; a_so_hd(1):=b_so_hd; a_ten(1):=b_ten;
if b_tdx<>0 and REGEXP_COUNT(b_ddiem, ',')>2 then
    if b_bk=0 then b_bk:=25; end if;
    for r_lp in (select ma_dvi,so_id,so_id_dt,tdx,tdy,bk,ngay_hl,ngay_kt,dvi from bh_pkt_ttu where 
        FBH_KH_AHUONG(b_tdx,b_tdy,b_bk,tdx,tdy,bk)='C' and FKH_GIAO(b_ngay_hl,b_ngay_kt,ngay_hl,ngay_kt)='C') loop
        b_bt:=b_bt+1;
        a_ma_dvi(b_bt):=r_lp.ma_dvi; a_so_id(b_bt):=r_lp.so_id; a_so_id_dt(b_bt):=r_lp.so_id_dt;
        a_tdx(b_bt):=r_lp.tdx; a_tdy(b_bt):=r_lp.tdy; a_bk(b_bt):=r_lp.bk;
        a_ngay_hl(b_bt):=r_lp.ngay_hl; a_ngay_kt(b_bt):=r_lp.ngay_kt;
        a_kieu(b_bt):='H'; a_ten(b_bt):=r_lp.dvi;
    end loop;
end if;
if b_bt<>0 then
  loop
    b_bd:=b_kt+1; b_kt:=b_bt;
    for b_lp in b_bd..b_kt loop
        for r_lp in (select ma_dvi,so_id,so_id_dt,tdx,tdy,bk,ngay_hl,ngay_kt,dvi from bh_pkt_ttu where
            so_id_dt<>a_so_id_dt(b_lp) and
            FBH_KH_AHUONG(a_tdx(b_lp),a_tdx(b_lp),a_bk(b_lp),tdx,tdy,bk)='C' and
            FKH_GIAO(a_ngay_hl(b_lp),a_ngay_kt(b_lp),ngay_hl,ngay_kt)='C') loop
            b_i1:=0;
            for b_lp1 in 1..a_ma_dvi.count loop
                if r_lp.so_id_dt=a_so_id_dt(b_lp1) then b_i1:=1; exit; end if;
            end loop;
            if b_i1=0 then
                b_bt:=b_bt+1;
                a_ma_dvi(b_bt):=r_lp.ma_dvi; a_so_id(b_bt):=r_lp.so_id; a_so_id_dt(b_bt):=r_lp.so_id_dt;
                a_tdx(b_bt):=r_lp.tdx; a_tdy(b_bt):=r_lp.tdy; a_bk(b_bt):=r_lp.bk;
                a_ngay_hl(b_bt):=r_lp.ngay_hl; a_ngay_kt(b_bt):=r_lp.ngay_kt;
                a_kieu(b_bt):='H'; a_ten(b_bt):=r_lp.dvi;
            end if;
        end loop;
    end loop;
    exit when b_kt=b_bt;
  end loop;
end if;
for b_lp in 2..b_kt loop
    a_so_hd(b_lp):=FBH_PKT_SO_HDd(a_ma_dvi(b_lp),a_so_id(b_lp));
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_BAO_TAO_PKTt:loi'; else null; end if;
end;
/
create or replace procedure PTBH_BAO_GHDT_PKT(
    b_ma_dvi varchar2,b_so_id number,
    a_so_id_dt out pht_type.a_num,a_ghep out pht_type.a_var,
    a_so_id_dtB out pht_type.a_num,a_ma_dviG out pht_type.a_var,
    a_so_idG out pht_type.a_num,a_so_id_dtG out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_so_id_gh number;
    b_ngay number:=PKH_NG_CSO(sysdate); b_kt number:=0;
    a_ma_dviT pht_type.a_var; a_so_idT pht_type.a_num; a_so_id_dtT pht_type.a_num;
begin
-- Dan - Doi tuong ghep tai PKT
if FBH_BAO_BGHD_PKT(b_ma_dvi,b_so_id)=' ' then
    select so_id_dt bulk collect into a_so_id_dt from bh_pktB_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    select so_id_dt bulk collect into a_so_id_dt from bh_pkt_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
PKH_MANG_KD_N(a_so_id_dtB); PKH_MANG_KD(a_ma_dviG); PKH_MANG_KD_N(a_so_idG); PKH_MANG_KD_N(a_so_id_dtG);
for b_lp in 1..a_so_id_dt.count loop
    PTBH_BAO_TAO_PKT(b_ma_dvi,b_so_id,a_so_id_dt(b_lp),a_ma_dviT,a_so_idT,a_so_id_dtT,b_loi);
    if b_loi is not null then return; end if;
    b_so_id_gh:=0;
    for b_lp1 in 1..a_ma_dviT.count loop
        select nvl(max(so_id),0) into b_so_id_gh from tbh_ghep_hd where
            ma_dvi_hd=a_ma_dviT(b_lp1) and so_id_hd=a_so_idT(b_lp1) and
            so_id_dt=a_so_id_dtT(b_lp1) and FTBH_GHEP_NGAYk(so_id,b_ngay)='C';
        if b_so_id_gh<>0 then exit; end if;
    end loop;
    if b_so_id_gh=0 then
        a_ghep(b_lp):='M';
    else
        a_ghep(b_lp):='T';
        select ma_dvi_hd,so_id_hd,so_id_dt bulk collect into a_ma_dviT,a_so_idT,a_so_id_dtT
            from tbh_ghep_hd where so_id=b_so_id_gh;
    end if;
    for b_lp1 in 1..a_ma_dviT.count loop
        b_kt:=b_kt+1;
        a_so_id_dtB(b_kt):=a_so_id_dt(b_lp); a_ma_dviG(b_kt):=a_ma_dviT(b_lp1);
        a_so_idG(b_kt):=a_so_idT(b_lp1); a_so_id_dtG(b_kt):=a_so_id_dtT(b_lp1);
    end loop;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_BAO_GHDT_PKT:loi'; else null; end if;
end;
/
create or replace procedure PBH_BAO_DK_PKT(
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
    from bh_pktB_dvi a,bh_pktB_dk b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and 
    b.ma_dvi=b_ma_dvi and b.so_id=b_so_id and b.so_id_dt=a.so_id_dt;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BAO_DK_PKT:loi'; end if;
end;
/
create or replace procedure PTBH_BAO_NV_PKTd(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,
    b_ngay_ht number,b_ngay_hl number,b_ngay_kt number,
    b_nt_tien varchar2,b_nt_phi varchar2,b_loi out varchar2)
AS
begin
-- Dan - Ghep nghiep vu bao => nghiep vu tai cho 1 doi tuong
PBH_BAO_DK_PKT(b_ma_dvi,b_so_id,b_so_id_dt,b_loi);
if b_loi is not null then return; end if;
PTBH_BAO_TEMP2(b_ma_dvi,b_so_id,b_so_id_dt,b_ngay_ht,b_nt_tien,b_nt_phi,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_BAO_NV_PKTd:loi'; else null; end if;
end;
/
create or replace PROCEDURE PTBH_BAO_NV_PKT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,
    a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num,a_so_id_dt pht_type.a_num,
    b_ma_dt out varchar2,b_loi out varchar2)
AS
    b_ngay_ht number; b_ngay_hl number; b_ngay_kt number; b_tp number:=0; b_i1 number;
    b_kieu_ps varchar2(1); b_nv varchar2(10); b_so_hd varchar2(20);
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_ma_dtT varchar2(10);
    a_ma_taT pht_type.a_var; a_ptT pht_type.a_num;
begin
-- Dan - Ghep tich tu voi 1 dtuong bao gia
delete tbh_ghep_nv_temp; delete tbh_ghep_nv_temp2;
PTBH_TM_TTINf(b_ma_dvi,b_so_id,b_kieu_ps,b_nv,b_so_hd,b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_loi);
if b_loi is not null then return; end if;
if b_nt_tien<>'VND' then b_tp:=2; end if;
b_ma_dt:=' ';
for b_lp in 1..a_ma_dvi.count loop
    if FBH_BAO_BGHD_PKT(a_ma_dvi(b_lp),a_so_id(b_lp))=' ' then
        select nvl(max(ma_dt),' ') into b_ma_dtT from bh_pktB_dvi where
            ma_dvi=a_ma_dvi(b_lp) and so_id=a_so_id(b_lp) and so_id_dt=a_so_id_dt(b_lp);
        PTBH_BAO_NV_PKTd(a_ma_dvi(b_lp),a_so_id(b_lp),a_so_id_dt(b_lp),
            b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_loi);
    else
        select nvl(max(ma_dt),' ') into b_ma_dtT from bh_pkt_dvi where
            ma_dvi=a_ma_dvi(b_lp) and so_id=a_so_id(b_lp) and so_id_dt=a_so_id_dt(b_lp);
        PTBH_GHEP_NV_1(0,b_ngay_ht,b_ngay_hl,b_nt_tien,b_nt_phi,
            a_ma_dvi(b_lp),a_so_id(b_lp),a_so_id_dt(b_lp),b_loi,'{"xly":"C","nv":"PKT"}');
    end if;
    if b_loi is not null then return; end if;
    b_ma_dtT:=FBH_PHH_DTUONG_CAT(b_ma_dtT);
    if b_ma_dtT>b_ma_dt then b_ma_dt:=b_ma_dtT; end if;
end loop;
PTBH_BAO_TEMP(b_ma_dvi,b_so_id,b_so_id_dt,b_nt_tien,b_nt_phi,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_BAO_NV_PKT:loi'; else null; end if;
end;
/
create or replace PROCEDURE PTBH_BAO_NV_PKTc(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,
    a_ma_dvi pht_type.a_var,a_kieu pht_type.a_var,a_so_id pht_type.a_num,
    a_so_id_dt pht_type.a_num,b_ma_dt out varchar2,b_loi out varchar2)
AS
    b_ngay_ht number; b_ngay_hl number; b_ngay_kt number; b_tp number:=0; b_i1 number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_ma_dtT varchar2(10);
    b_kieu_ps varchar2(1); b_nv varchar2(10); b_so_hd varchar2(20);
    a_ma_taT pht_type.a_var; a_ptT pht_type.a_num;
begin
-- Dan - Xu ly chuan bi chao tai tam thoi
delete tbh_ghep_nv_temp; delete tbh_ghep_nv_temp2;
PTBH_TM_TTINf(a_ma_dvi(1),a_so_id(1),b_kieu_ps,b_nv,b_so_hd,b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_loi);
if b_loi is not null then return; end if;
if b_nt_tien<>'VND' then b_tp:=2; end if;
b_ma_dt:=' ';
for b_lp in 1..a_ma_dvi.count loop
    if FBH_BAO_BGHD_PKT(a_ma_dvi(b_lp),a_so_id(b_lp))=' ' then
        select nvl(max(ma_dt),' ') into b_ma_dtT from bh_pktB_dvi where
            ma_dvi=a_ma_dvi(b_lp) and so_id=a_so_id(b_lp) and so_id_dt=a_so_id_dt(b_lp);
        PTBH_BAO_NV_PKTd(a_ma_dvi(b_lp),a_so_id(b_lp),a_so_id_dt(b_lp),
        b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_loi);
    else
        select nvl(max(ma_dt),' ') into b_ma_dtT from bh_pkt_dvi where
            ma_dvi=a_ma_dvi(b_lp) and so_id=a_so_id(b_lp) and so_id_dt=a_so_id_dt(b_lp);
        PTBH_GHEP_NV_1(0,b_ngay_ht,b_ngay_hl,b_nt_tien,b_nt_phi,
            a_ma_dvi(b_lp),a_so_id(b_lp),a_so_id_dt(b_lp),b_loi,'{"xly":"C","nv":"PKT"}');
    end if;
    if b_loi is not null then return; end if;
    b_ma_dtT:=FBH_PHH_DTUONG_CAT(b_ma_dtT);
    if b_ma_dtT>b_ma_dt then b_ma_dt:=b_ma_dtT; end if;
end loop;
PTBH_BAO_TEMPc(b_nt_tien,b_nt_phi,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_BAO_NV_PKTc:loi'; else null; end if;
end;
/
