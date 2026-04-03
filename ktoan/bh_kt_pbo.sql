create or replace procedure PBH_KT_PBO_DTt(b_ma_dvi varchar2,b_ngayD number,b_ngayC number)
AS
    b_so_idR number; b_tienR number; b_ma_dviG varchar2(10):=FTBH_DVI_TA();
	b_nv varchar2(10); b_sp varchar2(20);
    b_so_id number:=0; b_so_idB number; b_phi number; b_tien number; b_lh_nv varchar2(20);
begin
-- Dan - Phi thuc thu phat sinh con lai
for r_lp in(select so_id,lh_nv,sum(phi_qd) phi from bh_hd_goc_ttpb where
    ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and pt in('G','N')
    group by so_id,lh_nv having sum(phi)<>0 order by so_id) loop
    b_lh_nv:=r_lp.lh_nv; b_phi:=r_lp.phi;
    if b_so_id<>r_lp.so_id then
        b_so_id:=r_lp.so_id; b_so_idB:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,b_ngayC);
		PBH_HD_NV_SP(b_ma_dvi,b_so_idB,b_nv,b_sp);
    end if;
    select nvl(max(so_id),0) into b_so_idR from tbh_ghep_hd where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id;
    if b_so_idR<>0 then
        select nvl(sum(tien),0) into b_tienR from tbh_ghep_pbo where
            --ma_dvi=b_ma_dviG and 
            so_id=b_so_idR and ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id and lh_nv=b_lh_nv;
        if b_tienR<>0 then
            select nvl(sum(tien),0) into b_tien from bh_hd_goc_dk where ma_dvi=b_ma_dvi and so_id=b_so_idB and lh_nv=b_lh_nv;
            if b_tien<>0 then b_phi:=round(b_phi*b_tienR/b_tien,0); end if;
        end if;
    end if;
    insert into bh_kt_pbo_dt_temp values(b_ma_dvi,b_so_id,b_nv,b_sp,b_lh_nv,b_phi);
end loop;
end;
/
create or replace procedure PBH_KT_PBO_BTt(b_ma_dvi varchar2,b_ngayD number,b_ngayC number)
AS
    b_so_id_hd number; b_so_id_hdB number; b_nv varchar2(10); b_sp varchar2(20);
begin
-- Dan - Tao so boi thuong phat sinh
for r_lp in(select ma_dvi,so_id,so_id_hd from bh_bt_hs where ma_dvi_ql=b_ma_dvi and (
    ngay_ht between b_ngayD and b_ngayC or ngay_qd between b_ngayD and b_ngayC or (ngay_ht<b_ngayD and ngay_qd='30000101'))) loop
    b_so_id_hd:=r_lp.so_id_hd; b_so_id_hdB:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id_hdB,b_ngayC);
    PBH_HD_NV_SP(b_ma_dvi,b_so_id_hdB,b_nv,b_sp);
    insert into bh_kt_pbo_bt_temp select b_ma_dvi,b_so_id_hd,b_nv,b_sp,lh_nv,sum(tien_qd)
        from bh_bt_hs_nv where ma_dvi=r_lp.ma_dvi and so_id=r_lp.so_id group by lh_nv;
end loop;
end;
/
create or replace procedure PBH_KT_PBO_HO(
    a_ma_dvi pht_type.a_var,a_nhom pht_type.a_var,a_loai pht_type.a_var,
	a_nv pht_type.a_var,a_sp pht_type.a_var,a_ma_tke pht_type.a_var,a_tien pht_type.a_num,
    a_ma_dviK out pht_type.a_var,a_nhomK out pht_type.a_var,a_loaiK out pht_type.a_var,
	a_nvK out pht_type.a_var,a_spK out pht_type.a_var,a_ma_tkeK out pht_type.a_var,a_tienK out pht_type.a_num)
AS
    b_phiT number:=0; b_kt number:=0; b_con number; b_tl number; b_pbo number;
    a_ma_dviT pht_type.a_num; a_tienT pht_type.a_num;
begin
-- Dan - Phan bo HO theo boi thuong
for b_lpH in 1..a_ma_dvi.count loop
    if trim(a_ma_dvi(b_lpH)) is null and a_nhom(b_lpH)='H' then
        if a_loai(b_lpH)='D' then
            select ma_dvi,sum(phi) bulk collect into a_ma_dviT,a_tienT from bh_kt_pbo_dt_temp
				where a_nv(b_lpH) in('*',nv) and a_sp(b_lpH) in('*',sp) group by ma_dvi;
        else
            select ma_dvi,sum(tien) bulk collect into a_ma_dviT,a_tienT from bh_kt_pbo_bt_temp
				where a_nv(b_lpH) in('*',nv) and a_sp(b_lpH) in('*',sp) group by ma_dvi;
        end if;
        for b_lp in 1..a_ma_dviT.count loop
            b_phiT:=b_phiT+a_tienT(b_lp);
        end loop;
        b_tl:=a_tienT(b_lpH)/b_phiT; b_con:=b_phiT;
        for b_lp1 in 2..a_ma_dviT.count loop
            b_pbo:=round(a_tienT(b_lp1)*b_tl,0);
            if b_pbo>b_con then b_pbo:=b_con; end if;
            b_kt:=b_kt+1; b_con:=b_con-b_pbo;
            a_ma_dviK(b_kt):=a_ma_dviT(b_lp1); a_nhomK(b_kt):='H'; a_loaiK(b_kt):=a_loai(b_lpH);
            a_nvK(b_kt):=a_nv(b_lpH); a_spK(b_kt):=a_sp(b_lpH); a_ma_tkeK(b_kt):=a_ma_tke(b_lpH); a_tienK(b_kt):=b_pbo;
            if b_con=0 then exit; end if;
        end loop;
        if b_con<>0 then
            b_kt:=b_kt+1;
            a_ma_dviK(b_kt):=a_ma_dviT(1); a_nhomK(b_kt):='H'; a_loaiK(b_kt):=a_loai(b_lpH);
            a_nvK(b_kt):=a_nv(b_lpH); a_spK(b_kt):=a_sp(b_lpH); a_ma_tkeK(b_kt):=a_ma_tke(b_lpH); a_tienK(b_kt):=b_con;
        end if;
    end if;
end loop;
end;
/
create or replace procedure PBH_KT_PBO_DVI(
    b_ma_dvi varchar2,a_nhom pht_type.a_var,a_loai pht_type.a_var,a_nv pht_type.a_var,a_sp pht_type.a_var,a_ma_tke pht_type.a_var,a_tien pht_type.a_num)
AS
    b_phiT number:=0; b_con number; b_tl number; b_pbo number;
    a_so_id pht_type.a_num; a_lh_nv pht_type.a_var; a_phi pht_type.a_num;
begin
-- Dan - Phan bo tai don vi
for b_lp in 1..a_nhom.count loop
    if a_loai(b_lp)='D' then
        select so_id,lh_nv,sum(phi) bulk collect into a_so_id,a_lh_nv,a_phi from bh_kt_pbo_dt_temp
            where ma_dvi=b_ma_dvi and a_nv(b_lp) in('*',nv) and a_sp(b_lp) in('*',sp) group by so_id,lh_nv;
    else
        select so_id,lh_nv,sum(tien) bulk collect into a_so_id,a_lh_nv,a_phi from bh_kt_pbo_bt_temp
            where ma_dvi=b_ma_dvi and a_nv(b_lp) in('*',nv) and a_sp(b_lp) in('*',sp) group by so_id,lh_nv;
    end if;
    for b_lp in 1..a_so_id.count loop
        b_phiT:=b_phiT+a_phi(b_lp);
    end loop;
    b_tl:=a_tien(b_lp)/b_phiT; b_con:=b_phiT;
    for b_lp1 in 2..a_so_id.count loop
        b_pbo:=round(a_phi(b_lp1)*b_tl,0);
        if b_pbo>b_con then b_pbo:=b_con; end if;
        b_con:=b_con-b_pbo;
        insert into bh_kt_pbo_temp values(b_ma_dvi,a_nhom(b_lp),a_loai(b_lp),a_ma_tke(b_lp),a_so_id(b_lp1),a_lh_nv(b_lp1),a_phi(b_lp1),b_pbo);
        if b_con=0 then exit; end if;
    end loop;
    if b_con<>0 then
        insert into bh_kt_pbo_temp values(b_ma_dvi,a_nhom(b_lp),a_loai(b_lp),a_ma_tke(b_lp),a_so_id(1),a_lh_nv(1),a_phi(1),b_con);
    end if;
end loop;
end;
/
create or replace procedure PBH_KT_PBO(b_ngayD number,b_ngayC number,
    a_ma_dvi pht_type.a_var,a_nhom pht_type.a_var,a_loai pht_type.a_var,
    a_nv pht_type.a_var,a_sp pht_type.a_var,a_ma_tke pht_type.a_var,a_tien pht_type.a_num)
AS
    b_kt number;
    a_ma_dviP pht_type.a_var; a_nhomX pht_type.a_var; a_loaiX pht_type.a_var;
    a_nvX pht_type.a_var; a_spX pht_type.a_var; a_ma_tkeX pht_type.a_var; a_tienX pht_type.a_num;
    a_ma_dviH pht_type.a_var; a_nhomH pht_type.a_var; a_loaiH pht_type.a_var;
    a_nvH pht_type.a_var; a_spH pht_type.a_var; a_ma_tkeH pht_type.a_var; a_tienH pht_type.a_num;
begin
-- Dan - Phan bo
-- Nhom: H- Tu HO, D-cua don vi
-- Loai: D- Doanh thu, B-Boi thuong
-- nv: Nghiep vu-xe, nguoi
-- sp: San pham (SK)
delete bh_kt_pbo_dt_temp; delete bh_kt_pbo_bt_temp; delete bh_kt_pbo_temp; commit;
select distinct ma_dvi bulk collect into a_ma_dviP from kt_1 where ngay_ht between b_ngayD and b_ngayC;
for b_lp in 1..a_ma_dviP.count loop
    PBH_KT_PBO_DTt(a_ma_dviP(b_lp),b_ngayD,b_ngayC);
    PBH_KT_PBO_BTt(a_ma_dviP(b_lp),b_ngayD,b_ngayC);
    commit;
end loop;
PBH_KT_PBO_HO(a_ma_dvi,a_nhom,a_loai,a_nv,a_sp,a_ma_tke,a_tien,a_ma_dviH,a_nhomH,a_loaiH,a_nvH,a_spH,a_ma_tkeH,a_tienH);
PKH_MANG_KD(a_nhomX); PKH_MANG_KD(a_loaiX); PKH_MANG_KD(a_nvX); PKH_MANG_KD(a_spX); PKH_MANG_KD(a_ma_tkeX); PKH_MANG_KD_N(a_tienX);
for b_lp in 1..a_ma_dviP.count loop
    b_kt:=0;
    PKH_MANG_XOA(a_nhomX); PKH_MANG_XOA(a_loaiX); PKH_MANG_XOA(a_nvX);
	PKH_MANG_XOA(a_spX); PKH_MANG_XOA(a_ma_tkeX); PKH_MANG_XOA_N(a_tienX);
    for b_lp1 in 1..a_ma_dvi.count loop
        if trim(a_ma_dvi(b_lp1)) is not null and a_ma_dvi(b_lp1)=a_ma_dviP(b_lp) then
            b_kt:=b_kt+1;
            a_nhomX(b_kt):=a_nhom(b_lp1); a_loaiX(b_kt):=a_loai(b_lp1);
            a_nvX(b_kt):=a_nv(b_lp1); a_spX(b_kt):=a_sp(b_lp1);
            a_ma_tkeX(b_kt):=a_ma_tke(b_lp1); a_tienX(b_kt):=a_tien(b_lp1);
        end if;
    end loop;
    for b_lp1 in 1..a_ma_dviH.count loop
        if a_ma_dviH(b_lp1)=a_ma_dviP(b_lp) then
            b_kt:=b_kt+1;
            a_nhomX(b_kt):=a_nhomH(b_lp1); a_loaiX(b_kt):=a_loaiH(b_lp1);
            a_nvX(b_kt):=a_nvH(b_lp1); a_spX(b_kt):=a_spH(b_lp1);
            a_ma_tkeX(b_kt):=a_ma_tkeH(b_lp1); a_tienX(b_kt):=a_tienH(b_lp1);
        end if;
    end loop;
    PBH_KT_PBO_DVI(a_ma_dviP(b_lp),a_nhomX,a_loaiX,a_nvX,a_spX,a_ma_tkeX,a_tienX);
    commit;
end loop;
delete bh_kt_pbo_dt_temp; delete bh_kt_pbo_bt_temp; commit;
end;
/