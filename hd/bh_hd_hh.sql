/*** HOA HONG ***/
create or replace function FBH_TRA_HH(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_kq number;
begin
-- Dan - Tong hoa hong thanh toan cho 1 hop dong
select nvl(sum(hhong_qd),0) into b_kq from bh_hd_goc_hh_ct where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure PBH_HD_HH_TON_CT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_tt number,b_hhong out number,b_htro out number,b_dvu out number)
AS
    b_hhong_tt number; b_htro_tt number; b_dvu_tt number;
begin
-- Dan - Ton hoa hong, ho tro theo so_id,so_id_tt,ma_nt
select nvl(sum(hhong),0),nvl(sum(htro),0),nvl(sum(dvu),0) into b_hhong,b_htro,b_dvu from bh_hd_goc_ttpt
    where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_tt=b_so_id_tt;
select nvl(sum(hhong),0),nvl(sum(htro),0),nvl(sum(dvu),0) into b_hhong_tt,b_htro_tt,b_dvu_tt from bh_hd_goc_hh_ct
    where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_tt=b_so_id_tt;
b_hhong:=b_hhong-b_hhong_tt; b_htro:=b_htro-b_htro_tt; b_dvu:=b_dvu-b_dvu_tt;
end;
/
create or replace procedure PBH_TRA_HH(b_ma_dvi varchar2,b_so_id number,a_lh_nv out pht_type.a_var,a_hh out pht_type.a_num)
AS
    b_kq number;
begin
-- Dan - Tong hoa hong thanh toan cho 1 hop dong
select lh_nv,sum(hhong_qd+htro_qd+dvu_qd) bulk collect into a_lh_nv,a_hh from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id=b_so_id
    group by lh_nv having sum(hhong_qd+htro_qd+dvu_qd)<>0;
end;
/
create or replace function FBH_PS_HH(b_ma_dvi varchar2,b_so_id number,b_so_id_tt number) return number
AS
    b_kq number;
begin
-- Dan - So da phat sinh xu ly
select count(*) into b_kq from bh_hd_goc_hh_ct where dvi_xl=b_ma_dvi and so_id=b_so_id and so_id_tt=b_so_id_tt;
return b_kq;
end;
/
create or replace procedure PBH_HD_HH_CONG
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,b_ngay_ht number,b_ma_dl varchar2,
    a_so_id pht_type.a_num,a_so_id_tt pht_type.a_num,a_ma_nt pht_type.a_var,
    a_hhong pht_type.a_num,a_htro pht_type.a_num,a_dvu pht_type.a_num,b_tien out number,b_thue out number,b_con out number)
AS
    b_loi varchar2(100); b_c_thue varchar2(1);
    a_hhong_qd pht_type.a_num; a_htro_qd pht_type.a_num; a_dvu_qd pht_type.a_num;
    a_thue_hh pht_type.a_num; a_thue_hh_qd pht_type.a_num;
    a_thue_ht pht_type.a_num; a_thue_ht_qd pht_type.a_num;
    a_thue_dv pht_type.a_num; a_thue_dv_qd pht_type.a_num;
begin
-- Dan - Cong thuc linh hoa hong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HH','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_HD_HH_TINH(b_ma_dvi,b_ngay_ht,b_ma_dl,a_so_id,a_so_id_tt,a_ma_nt,a_hhong,a_htro,a_dvu,
    a_hhong_qd,a_htro_qd,a_dvu_qd,a_thue_hh,a_thue_hh_qd,a_thue_ht,a_thue_ht_qd,a_thue_dv,a_thue_dv_qd,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_tien:=0; b_thue:=0; b_con:=0;
for b_lp in 1..a_ma_nt.count loop
    b_tien:=b_tien+a_hhong_qd(b_lp)+a_htro_qd(b_lp)+a_dvu_qd(b_lp);
    b_thue:=b_thue+a_thue_hh_qd(b_lp)+a_thue_ht_qd(b_lp)+a_thue_dv_qd(b_lp);
end loop;
select nvl(min(c_thue),'K') into b_c_thue from bh_dl_ma_kh where ma=b_ma_dl;
if b_c_thue='C' then b_con:=b_tien-b_thue; else b_con:=b_tien+b_thue; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_HH_PT_THUE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_dl varchar2,b_c_thue out varchar2)
AS
    b_loi varchar2(100);
begin
-- Dan - Cong thuc linh hoa hong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HH','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select nvl(min(c_thue),'K') into b_c_thue from bh_dl_ma_kh where ma=b_ma_dl;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_HH_GOM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,b_ngay_ht number,b_ma_dl varchar2,
    a_so_id pht_type.a_num,a_so_id_tt pht_type.a_num,a_ma_nt pht_type.a_var,
    a_hhong pht_type.a_num,a_htro pht_type.a_num,a_dvu pht_type.a_num,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);
    a_hhong_qd pht_type.a_num; a_htro_qd pht_type.a_num; a_dvu_qd pht_type.a_num;
    a_thue_hh pht_type.a_num; a_thue_ht pht_type.a_num; a_thue_dv pht_type.a_num;
    a_thue_hh_qd pht_type.a_num; a_thue_ht_qd pht_type.a_num; a_thue_dv_qd pht_type.a_num;
begin
-- Dan - Gom theo loai tien
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HH','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_HD_HH_TINH(b_ma_dvi,b_ngay_ht,b_ma_dl,a_so_id,a_so_id_tt,a_ma_nt,a_hhong,a_htro,a_dvu,
    a_hhong_qd,a_htro_qd,a_dvu_qd,a_thue_hh,a_thue_hh_qd,a_thue_ht,a_thue_ht_qd,a_thue_dv,a_thue_dv_qd,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete temp_1; commit;
for b_lp in 1..a_ma_nt.count loop
    insert into temp_1(c1,n1,n2,n3,n4) values(a_ma_nt(b_lp),a_hhong(b_lp),a_htro(b_lp),a_dvu(b_lp),a_thue_hh(b_lp)+a_thue_ht(b_lp)+a_thue_dv(b_lp));
end loop;
open cs1 for select c1 ma_nt,sum(n1) hhong,sum(n2) htro,sum(n3) dvu,sum(n4) thue from temp_1 group by c1;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_HH_THL
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_xl number)
AS
    b_loi varchar2(100); b_i1 number; b_i2 number;
    b_le number; b_tl number; b_tl_hh number; b_tl_ht number; b_tl_dv number; b_tl_mg number;
    b_ngay_hd number; b_kieu_kt varchar2(1); b_ma_kt varchar2(30); b_nv varchar2(10);
    b_hhong number; b_htro number; b_dvu number; b_hhong_qd number; b_htro_qd number; b_dvu_qd number;
    b_hhong_tl number; b_htro_tl number; b_dvu_tl number; 
    b_phi number; b_so_id number; b_k_tl_hh varchar2(1); b_k_tl_ht varchar2(1); b_ngcap number;
    b_kieu_do varchar2(1); b_kieu_hhv varchar2(1); b_kieu_phv varchar2(1);
    pbo_ma_dvi pht_type.a_var; pbo_so_id_tt pht_type.a_num; pbo_phi pht_type.a_num;
begin
-- Dan - Tong hop lai hoa hong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','H');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete temp_1; delete temp_2; commit;
insert into temp_1(n1,n2,n3,n4,c1,c2,n5,n6,n7,n15,n16,n17,n8,n9)
    select so_id_tt,bt,so_id,ngay_ht,lh_nv,ma_nt,hhong,htro,dvu,hhong_qd,htro_qd,dvu_qd,phi,phi_qd
    from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and ngay_ht>=b_ngay_xl;
if sqlcode<>0 or sql%rowcount=0 then return; end if;
insert into temp_2(n1,n2,n3,n4,c1,c2,n5,n6,n7,n15,n16,n17,n8,n9) select n1,n2,n3,n4,c1,c2,n5,n6,n7,n15,n16,n17,n8,n9 from temp_1 where n1=n3;
delete temp_1 where n1=n3;
for r_lp in (select n1 so_id_tt,n2 bt,n3 so_id,n4 ngay_ht,c1 lh_nv,c2 ma_nt,
    n5 hhong,n6 htro,n7 dvu,n15 hhong_qd,n16 htro_qd,n17 dvu_qd,n8 phi,n9 phi_qd from temp_1 order by n4,n1,n2) loop
    b_loi:='loi:Loi mat goc hop dong so ID '||to_char(r_lp.so_id)||':loi';
    select nv,kieu_kt,ma_kt,hhong,ngay_cap into b_nv,b_kieu_kt,b_ma_kt,b_tl_mg,b_ngcap
        from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=r_lp.so_id;
    if r_lp.ma_nt<>'VND' then b_le:=2; else b_le:=0; end if;
    b_kieu_do:=FBH_DONG(b_ma_dvi,r_lp.so_id);
    b_hhong:=0; b_htro:=0; b_dvu:=0; b_hhong_tl:=0; b_htro_tl:=0; b_dvu_tl:=0; b_hhong_qd:=0; b_htro_qd:=0; b_dvu_qd:=0;
    b_tl_hh:=0; b_tl_ht:=0; b_tl_dv:=0;
    if b_kieu_kt='M' then
        b_tl_hh:=b_tl_mg;
    elsif b_kieu_do<>'G' then
        b_i1:=FBH_DONG_TL(b_ma_dvi,r_lp.so_id,r_lp.lh_nv);
        if b_kieu_do='D' then
            FBH_DL_MA_KH_LHNV_HH(b_ma_kt,b_nv,r_lp.lh_nv,b_ngcap,b_tl_hh,b_tl_ht,b_tl_dv);
        elsif FBH_HD_DO_NH_TXT(b_ma_dvi,r_lp.so_id,'D','dl')='C' then
            b_tl_hh:=FBH_HD_DO_NH_TXTn(b_ma_dvi,r_lp.so_id,'D','pt_dl');
        end if;
        b_tl_hh:=round(b_tl_hh*b_i1/100,4); b_tl_ht:=round(b_tl_ht*b_i1/100,4); b_tl_dv:=round(b_tl_dv*b_i1/100,4);
    end if;
    if b_tl_hh=0 and b_tl_ht=0 and b_tl_dv=0 then continue; end if;
    b_hhong:=round(r_lp.phi*b_tl_hh/100,b_le); b_htro:=round(r_lp.phi*b_tl_ht/100,b_le); b_dvu:=round(r_lp.phi*b_tl_dv/100,b_le);
    if r_lp.hhong<>b_hhong or r_lp.htro<>b_htro or r_lp.dvu<>b_dvu then
        if b_le=0 then
            b_hhong_qd:=b_hhong; b_htro_qd:=b_htro; b_dvu_qd:=b_dvu;
        else
            b_hhong_qd:=round(r_lp.phi_qd*b_tl_hh/100,0);
            b_htro_qd:=round(r_lp.phi_qd*b_tl_ht/100,0);
            b_dvu_qd:=round(r_lp.phi_qd*b_tl_dv/100,0);
        end if;
        update bh_hd_goc_ttpt set hhong=b_hhong,htro=b_htro,dvu=b_dvu,
            hhong_tl=b_tl_hh,htro_tl=b_tl_ht,dvu_tl=b_tl_dv,
            hhong_qd=b_hhong_qd,htro_qd=b_htro_qd,dvu_qd=b_dvu_qd
            where ma_dvi=b_ma_dvi and so_id_tt=r_lp.so_id_tt and bt=r_lp.bt;
    end if;
end loop;
for r_lp in (select n1 so_id_tt,n2 bt,n3 so_id,n4 ngay_ht,c1 lh_nv,c2 ma_nt,
    n5 hhong,n6 htro,n7 dvu,n15 hhong_qd,n16 htro_qd,n17 dvu_qd,n8 phi from temp_2) loop
    select sum(n5),sum(n6),sum(n7),sum(n15),sum(n16),sum(n17),sum(n8) into b_hhong,b_htro,b_dvu,b_hhong_qd,b_htro_qd,b_dvu_qd,b_phi
        from temp_1 where n3=r_lp.so_id and c1=r_lp.lh_nv and c2=r_lp.ma_nt;
    if r_lp.ma_nt<>'VND' then b_le:=2; else b_le:=0; end if;
    b_tl:=r_lp.phi/b_phi;
    b_hhong:=round(b_hhong*b_tl,b_le); b_htro:=round(b_htro*b_tl,b_le); b_dvu:=round(b_dvu*b_tl,b_le);
    if r_lp.hhong<>b_hhong or r_lp.htro<>b_htro or r_lp.dvu<>b_dvu then
        if b_le=0 then
            b_hhong_qd:=b_hhong; b_htro_qd:=b_htro; b_dvu_qd:=b_dvu;
        else
            b_hhong_qd:=round(b_hhong_qd*b_tl,0); b_htro_qd:=round(b_htro_qd*b_tl,0); b_dvu_qd:=round(b_dvu_qd*b_tl,0);
        end if;
        update bh_hd_goc_ttpt set hhong=b_hhong,htro=b_htro,dvu=b_dvu,
            hhong_qd=b_hhong_qd,htro_qd=b_htro_qd,dvu_qd=b_dvu_qd
            where ma_dvi=b_ma_dvi and so_id_tt=r_lp.so_id_tt and bt=r_lp.bt;
    end if;
end loop;
commit;
delete bh_hd_goc_sc_hh where dvi_xl=b_ma_dvi and ngay_tt>=b_ngay_xl;
for r_lp in (select distinct so_id,so_id_tt from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and ngay_ht>=b_ngay_xl) loop
    PBH_TH_HH(b_ma_dvi,r_lp.so_id,r_lp.so_id_tt,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_HH_SC_THL
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_xl number)
AS
    b_loi varchar2(100);
begin
-- Dan - Tong hop lai so cai hoa hong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','H');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete bh_hd_goc_sc_hh where dvi_xl=b_ma_dvi and ngay_tt>=b_ngay_xl;
for r_lp in (select distinct so_id,so_id_tt from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and ngay_ht>=b_ngay_xl) loop
    PBH_TH_HH(b_ma_dvi,r_lp.so_id,r_lp.so_id_tt,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_HH_NV
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id_hh number,b_dbo out varchar2)
AS
    b_loi varchar2(100); b_nv varchar2(10);
begin
-- Dan - Xac dinh nghiep vu duyet hoa hong
b_dbo:='';
for r_lp in (select distinct so_id from bh_hd_goc_hh_ct where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh) loop
    b_nv:=FBH_HD_NV(b_ma_dvi,r_lp.so_id);
    if b_dbo is null then b_dbo:=b_nv;
    elsif instr(b_dbo,b_nv)=0 then b_dbo:=b_dbo||','||b_nv;
    end if;
end loop;
end;
/
create or replace PROCEDURE PBH_HD_HH_PTDT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_hh number,b_loi out varchar2,b_dk varchar2:='C')
AS
    b_i1 number; b_tp number:=0; b_hs number; b_bt number:=0; b_vt number:=0;
    b_nv varchar2(5); b_so_idD number; b_so_idB number; b_nt_phi varchar2(5);
    b_hhong number; b_htro number; b_dvu number; 
    b_hhong_qd number; b_htro_qd number; b_dvu_qd number;
    b_hhongX number; b_htroX number; b_dvuX number; 
    b_hhong_qdX number; b_htro_qdX number; b_dvu_qdX number;
    b_hhongC number; b_htroC number; b_dvuC number; 
    b_hhong_qdC number; b_htro_qdC number; b_dvu_qdC number;
    b_thue_hh number; b_thue_ht number; b_thue_dv number; 
    b_thue_hh_qd number; b_thue_ht_qd number; b_thue_dv_qd number; 
    b_thue_hhX number; b_thue_htX number; b_thue_dvX number; 
    b_thue_hh_qdX number; b_thue_ht_qdX number; b_thue_dv_qdX number; 
    b_thue_hhC number; b_thue_htC number; b_thue_dvC number; 
    b_thue_hh_qdC number; b_thue_ht_qdC number; b_thue_dv_qdC number; 
    a_so_id_dt pht_type.a_num; a_lh_nv pht_type.a_var; a_phi pht_type.a_num;
    a_lh_nvT pht_type.a_var; a_phiT pht_type.a_num; a_hs pht_type.a_num;
begin
-- Dan - Phan tich cho doi tuong
if b_dk='C' then
    delete bh_hd_goc_hh_ptdt where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh and so_id=b_so_id;
end if;
select count(*) into b_i1 from bh_hd_goc_hh_pt where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select nv,so_id_d,nt_phi into b_nv,b_so_idD,b_nt_phi from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nv not in('PHH','PKT','2B','XE','TAU') then
    insert into bh_hd_goc_hh_ptdt select ma_dvi,so_id_hh,bt,so_id,0,so_id_tt,pt,ma_nt,lh_nv,
        hhong,hhong_qd,htro,htro_qd,dvu,dvu_qd,thue_hh,thue_hh_qd,thue_ht,thue_ht_qd,thue_dv,thue_dv_qd
        from bh_hd_goc_hh_pt where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh and so_id=b_so_id;
    b_loi:=''; return;
else
    select count(*) into b_i1 from bh_hd_goc_dkdt where
        ma_dvi=b_ma_dvi and so_id=b_so_idD and so_id_dt<>b_so_idD;
    if b_i1=0 then
    insert into bh_hd_goc_hh_ptdt select ma_dvi,so_id_hh,bt,so_id,b_so_idD,so_id_tt,pt,ma_nt,lh_nv,
        hhong,hhong_qd,htro,htro_qd,dvu,dvu_qd,thue_hh,thue_hh_qd,thue_ht,thue_ht_qd,thue_dv,thue_dv_qd
        from bh_hd_goc_hh_pt where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh and so_id=b_so_id;
        b_loi:=''; return;
    end if;
end if;
if b_nt_phi<>'VND' then b_tp:=2; end if;
b_so_idB:=FBH_HD_SO_ID_BSd(b_ma_dvi,b_so_id);
select so_id_dt,lh_nv,sum(phi) bulk collect into a_so_id_dt,a_lh_nv,a_phi
    from bh_hd_goc_dkdt where ma_dvi=b_ma_dvi and so_id=b_so_idB group by so_id_dt,lh_nv;
select lh_nv,sum(phi) bulk collect into a_lh_nvT,a_phiT
    from bh_hd_goc_dkdt where ma_dvi=b_ma_dvi and so_id=b_so_idB group by lh_nv having sum(phi)<>0;
for b_lp in 1..a_so_id_dt.count loop
    b_vt:=FKH_ARR_VTRI(a_lh_nvT,a_lh_nv(b_lp));
    if b_vt=0 then a_hs(b_lp):=0; else a_hs(b_lp):=round(a_phi(b_lp)/a_phiT(b_vt),5); end if;
end loop;
for r_lp in(select * from bh_hd_goc_hh_pt where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh and so_id=b_so_id) loop
    b_vt:=0; b_hhong:=r_lp.hhong; b_htro:=r_lp.htro; b_dvu:=r_lp.dvu;
    b_hhong_qd:=r_lp.hhong_qd; b_htro_qd:=r_lp.htro_qd; b_dvu_qd:=r_lp.dvu_qd;
    b_thue_hh:=r_lp.thue_hh; b_thue_ht:=r_lp.thue_ht; b_thue_dv:=r_lp.thue_dv;
    b_thue_hh_qd:=r_lp.thue_hh_qd; b_thue_ht_qd:=r_lp.thue_ht_qd; b_thue_dv_qd:=r_lp.thue_dv_qd;
    b_hhongC:=b_hhong; b_htroC:=b_htro; b_dvuC:=b_dvu;
    b_hhong_qdC:=b_hhong_qd; b_htro_qdC:=b_htro_qd; b_dvu_qdC:=b_dvu_qd;
    b_thue_hhC:=b_thue_hh; b_thue_htC:=b_thue_ht; b_thue_dvC:=b_thue_dv;
    b_thue_hh_qdC:=b_thue_hh_qd; b_thue_ht_qdC:=b_thue_ht_qd; b_thue_dv_qdC:=b_thue_dv_qd;
    for b_lp in 1..a_so_id_dt.count loop
        if a_lh_nv(b_lp)<>r_lp.lh_nv then continue; end if;
        b_hs:=a_hs(b_lp); b_bt:=b_bt+1; b_vt:=1;
        b_hhongX:=round(b_hhong*b_hs,b_tp); b_htroX:=round(b_htro*b_hs,b_tp); b_dvuX:=round(b_dvu*b_hs,b_tp);
        b_hhong_qdX:=round(b_hhong_qd*b_hs,0); b_htro_qdX:=round(b_htro_qd*b_hs,0); b_dvu_qdX:=round(b_dvu_qd*b_hs,0);
        b_thue_hhX:=round(b_thue_hh*b_hs,b_tp); b_thue_htX:=round(b_thue_ht*b_hs,b_tp); b_thue_dvX:=round(b_thue_dv*b_hs,b_tp);
        b_thue_hh_qdX:=round(b_thue_hh_qd*b_hs,0); b_thue_ht_qdX:=round(b_thue_ht_qd*b_hs,0);
        b_thue_dv_qdX:=round(b_thue_dv_qd*b_hs,0);
        b_hhongC:=b_hhongC-b_hhongX; b_htroC:=b_htroC-b_htroX; b_dvuC:=b_dvuC-b_dvuX;
        b_hhong_qdC:=b_hhong_qdC-b_hhong_qdX; b_htro_qdC:=b_htro_qdC-b_htro_qdX; b_dvu_qdC:=b_dvu_qdC-b_dvu_qdX;
        b_thue_hhC:=b_thue_hhC-b_thue_hhX; b_thue_htC:=b_thue_htC-b_thue_htX; b_thue_dvC:=b_thue_dvC-b_thue_dvX; 
        b_thue_hh_qdC:=b_thue_hh_qdC-b_thue_hh_qdX; b_thue_ht_qdC:=b_thue_ht_qdC-b_thue_ht_qdX;
        b_thue_dv_qdC:=b_thue_dv_qdC-b_thue_dv_qdX;
        insert into bh_hd_goc_hh_ptdt values(b_ma_dvi,b_so_id_hh,b_bt,r_lp.so_id,a_so_id_dt(b_lp),r_lp.so_id_tt,r_lp.pt,
            r_lp.ma_nt,r_lp.lh_nv,b_hhongX,b_hhong_qdX,b_htroX,b_htro_qdX,b_dvuX,b_dvu_qdX,
            b_thue_hhX,b_thue_hh_qdX,b_thue_htX,b_thue_ht_qdX,b_thue_dvX,b_thue_dv_qdX);
    end loop;
    if b_vt<>0 then
        update bh_hd_goc_hh_ptdt set
            hhong=hhong+b_hhongC,htro=htro+b_htroC,dvu=dvu+b_dvuC,
            hhong_qd=hhong_qd+b_hhong_qdC,htro_qd=htro_qd+b_htro_qdC,dvu_qd=dvu_qd+b_dvu_qdC,
            thue_hh=thue_hh+b_thue_hhC,thue_ht=thue_ht+b_thue_htC,thue_dv=thue_dv+b_thue_dvC,
            thue_hh_qd=thue_hh_qd+b_thue_hh_qdC,thue_ht_qd=thue_ht_qd+b_thue_ht_qdC,thue_dv_qd=thue_dv_qd+b_thue_dv_qdC
            where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh and bt=b_bt;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_TTPTDT_ID:loi'; end if;
end;
/
create or replace function FBH_HD_HH_TINH(
    b_ma_dvi varchar2,b_ngay_ht number,b_ma_dl varchar2,b_so_id number,
    b_ma_nt varchar2,b_hhong number,b_htro number,b_dvu number) return number
AS
    b_kq number; b_tp number:=0; b_kieu_kt varchar2(1);
begin
-- Dan - Tinh thue hoa hong, ho tro
b_kieu_kt:=FBH_HD_KIEU_KT(b_ma_dvi,b_so_id);
if b_kieu_kt='T' then return 0; end if;
if b_ma_nt<>'VND' then b_tp:=2; end if;
if FBH_DTAC_MA_LOAI(b_ma_dl)='C' then
    b_kq:=round(b_hhong*0.05,b_tp)+round(b_htro*0.05,b_tp)+round(b_dvu*0.05,b_tp);
else
    b_kq:=round(b_htro*0.1,b_tp)+round(b_dvu*0.1,b_tp);
    if b_kieu_kt='M' then b_kq:=b_kq+round(b_hhong*0.1,b_tp); end if;
end if;
return b_kq;
end;
/
create or replace procedure PBH_HD_HH_TINH(
    b_ma_dvi varchar2,b_ngay_ht number,b_ma_dl varchar2,a_so_id pht_type.a_num,a_so_id_tt pht_type.a_num,
    a_ma_nt pht_type.a_var,a_hhong pht_type.a_num,a_htro pht_type.a_num,a_dvu pht_type.a_num,
    a_hhong_qd out pht_type.a_num,a_htro_qd out pht_type.a_num,a_dvu_qd out pht_type.a_num,
    a_thue_hh out pht_type.a_num,a_thue_hh_qd out pht_type.a_num,
    a_thue_ht out pht_type.a_num,a_thue_ht_qd out pht_type.a_num,
    a_thue_dv out pht_type.a_num,a_thue_dv_qd out pht_type.a_num,b_loi out varchar2)
AS
    b_tg number; b_tp number; b_loai varchar2(1); b_kieu_kt varchar2(1); b_ngay_tt number;
begin
-- Dan - Tinh thue hoa hong, ho tro
b_loai:=FBH_DTAC_MA_LOAI(b_ma_dl);
for b_lp in 1..a_so_id.count loop
    b_kieu_kt:=FBH_HD_KIEU_KT(b_ma_dvi,a_so_id(b_lp));
    if a_ma_nt(b_lp)='VND' then b_tp:=0; else b_tp:=2; end if;
    if b_kieu_kt='T' then
        a_thue_hh(b_lp):=0; a_thue_ht(b_lp):=0; a_thue_dv(b_lp):=0;
    elsif b_loai='C' then
        a_thue_hh(b_lp):=round(a_hhong(b_lp)*0.05,b_tp);
        a_thue_ht(b_lp):=round(a_htro(b_lp)*0.05,b_tp);
        a_thue_dv(b_lp):=round(a_dvu(b_lp)*0.05,b_tp);
    else
        a_thue_ht(b_lp):=round(a_htro(b_lp)*0.1,b_tp);
        a_thue_dv(b_lp):=round(a_dvu(b_lp)*0.1,b_tp);
        if b_kieu_kt<>'M' then a_thue_hh(b_lp):=0; else a_thue_hh(b_lp):=round(a_hhong(b_lp)*0.1,b_tp); end if;
    end if;
    if a_ma_nt(b_lp)='VND' then
        a_hhong_qd(b_lp):=a_hhong(b_lp); a_htro_qd(b_lp):=a_htro(b_lp); a_dvu_qd(b_lp):=a_dvu(b_lp);
        a_thue_hh_qd(b_lp):=a_thue_hh(b_lp); a_thue_ht_qd(b_lp):=a_thue_ht(b_lp); a_thue_dv_qd(b_lp):=a_thue_dv(b_lp);
    else
        select ngay_ht into b_ngay_tt from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=a_so_id_tt(b_lp);
        b_tg:=FBH_TT_TRA_TGTT(b_ngay_tt,a_ma_nt(b_lp));
        a_hhong_qd(b_lp):=round(a_hhong(b_lp)*b_tg,0);
        a_htro_qd(b_lp):=round(a_htro(b_lp)*b_tg,0);
        a_dvu_qd(b_lp):=round(a_dvu(b_lp)*b_tg,0);
        a_thue_hh_qd(b_lp):=round(a_thue_hh(b_lp)*b_tg,0);
        a_thue_ht_qd(b_lp):=round(a_thue_ht(b_lp)*b_tg,0);
        a_thue_dv_qd(b_lp):=round(a_thue_dv(b_lp)*b_tg,0);
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_HH_TINH:loi'; end if;
end;
/
/*** THANH TOAN HOA HONG ***/
create or replace function FBH_HD_HH_TXT(b_ma_dvi varchar2,b_so_id_hh number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_txt clob;
begin
select count(*) into b_i1 from bh_hd_goc_hh_txt where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_hd_goc_hh_txt where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh and loai='dt_ct';
    b_kq:=FKH_JS_GTRIu(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace procedure PBH_HD_HH_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100);
    b_so_id_hh number:=FKH_JS_GTRIn(b_oraIn,'so_id_hh');
    dt_ct clob; dt_dk clob; dt_txt clob;
begin
-- Dan - Xem chi tiet thanh toan phi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HH','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Duyet hoa hong da xoa:loi';
select json_object(ma_dl) into dt_ct from bh_hd_goc_hh where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh;
select JSON_ARRAYAGG(json_object(
    'so_hd' value so_hd,'ngay_tt' value ngay_tt,'ma_nt' value ma_nt,
    --nam: lay thue
    'hhong' value hhong,'htro' value htro,'dvu' value dvu,'thue' value thue,'chon' value '',
    'so_id' value so_id,'so_id_tt' value so_id_tt) order by so_hd returning clob) into dt_dk
    from bh_hd_goc_hh_ct where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob)
    into dt_txt from bh_hd_goc_hh_txt where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh;
select json_object('so_id_hh' value b_so_id_hh,'dt_dk' value dt_dk,
    'dt_ct' value dt_ct,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_HH_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_so_hd varchar2(20); b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number; b_phong varchar2(10);
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HH','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hd,ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_hd_goc_hh where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id_hh,ten) returning clob) into cs_lke from
            (select so_id_hh,ten,rownum sott from bh_hd_goc_hh where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id_hh desc)
            where sott between b_tu and b_den;
    end if;
elsif b_klk='P' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_hd_goc_hh where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id_hh,ten) returning clob) into cs_lke from
            (select so_id_hh,ten,rownum sott from bh_hd_goc_hh where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id_hh desc) 
            where sott between b_tu and b_den;
    end if;
elsif trim(b_so_hd) is not null then
    select count(*) into b_dong from bh_hd_goc_hh where ma_dvi=b_ma_dvi and so_id_hh in
        (select distinct so_id_hh from bh_hd_goc_hh_ct where ma_dvi=b_ma_dvi and so_hd=b_so_hd);
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id_hh,ten) returning clob) into cs_lke from
            (select so_id_hh,ten,rownum sott from bh_hd_goc_hh where ma_dvi=b_ma_dvi and
                so_id_hh in(select distinct so_id_hh from bh_hd_goc_hh_ct where ma_dvi=b_ma_dvi and so_hd=b_so_hd)
                order by so_id_hh desc)
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_HH_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_phong varchar2(10); b_tu number; b_den number;
    b_so_id number; b_ngay_ht number; b_klk varchar2(1); b_trangkt number;
    b_trang number; b_dong number; cs_lke clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_klk,b_trangKt using b_oraIn;
if b_klk ='N' then
    select count(*) into b_dong from bh_hd_goc_hh where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_id_hh,rownum sott from bh_hd_goc_hh where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id_hh desc) where so_id_hh<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id_hh,ten) returning clob) into cs_lke from
        (select so_id_hh,ten,rownum sott from bh_hd_goc_hh where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id_hh desc)
        where sott between b_tu and b_den;
elsif b_klk='P' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_hd_goc_hh where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from (select so_id_hh,rownum sott from bh_hd_goc_hh where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id_hh desc) where so_id_hh<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id_hh,ten) returning clob) into cs_lke from
        (select so_id_hh,ten,rownum sott from bh_hd_goc_hh where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id_hh desc) 
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_HH_TON(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_i1 number; b_lenh varchar2(2000);
    b_ngay_ht number; b_ma_dl varchar2(20); b_so_hd varchar2(20);
    b_so_id number; b_so_id_tt number; cs_ton clob:='';
begin
-- Dan - Hoi ten, liet ke no khi nhap thanh toan phi
delete temp_1; delete temp_2; delete temp_3; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,ma_dl,so_hd,so_id_tt');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_ma_dl,b_so_hd,b_so_id_tt using b_oraIn;
if nvl(b_so_id_tt,0)<>0 then
    select min(ma_dl) into b_ma_dl from bh_hd_goc_sc_hh where so_id_tt=b_so_id_tt;
    if b_ma_dl is not null then
        insert into temp_3(n1,n2) select distinct so_id,so_id_tt from bh_hd_goc_sc_hh
            where so_id_tt=b_so_id_tt and ma_dl=b_ma_dl;
        b_i1:=sql%rowcount;
    end if;
elsif trim(b_so_hd) is not null then
    b_so_id:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi,b_so_hd);
    select min(ma_dl) into b_ma_dl from bh_hd_goc_sc_hh where so_id=b_so_id;
    if b_ma_dl is not null then
        insert into temp_3(n1,n2) select distinct so_id,so_id_tt from bh_hd_goc_sc_hh where so_id=b_so_id;
        b_i1:=sql%rowcount;
    end if;
elsif trim(b_ma_dl) is not null then
    insert into temp_3(n1,n2) select distinct so_id,so_id_tt from bh_hd_goc_sc_hh
        where ma_dl=b_ma_dl and ngay_tt<=b_ngay_ht;
    b_i1:=sql%rowcount;
end if;
if b_i1<>0 then
    insert into temp_1(c1,c3,n11,n12,n1,n2,n3)
        select ma_dvi,ma_nt,so_id,so_id_tt,hhong,htro,dvu
        --nam : union all
            from bh_hd_goc_ttpt where (so_id,so_id_tt) in (select n1,n2 from temp_3) union all
        select ma_dvi,ma_nt,so_id,so_id_tt,-hhong,-htro,-dvu
            from bh_hd_goc_hh_ct where (so_id,so_id_tt) in (select n1,n2 from temp_3);
    insert into temp_2(c1,c3,n11,n12,n1,n2,n3) select c1,c3,n11,n12,sum(n1),sum(n2),sum(n3)
        from temp_1 group by c1,c3,n11,n12 having sum(n1)<>0 or sum(n2)<>0 or sum(n3)<>0;
    if sql%rowcount<>0 then
        update temp_2 set c10=FBH_HD_GOC_SO_HD_D(c1,n11),n4=FBH_HD_HH_TINH(c1,b_ngay_ht,b_ma_dl,n11,c3,n1,n2,n3),
            n13=(select min(ngay_ht) from bh_hd_goc_ttpt where ma_dvi=c1 and so_id=n11 and so_id_tt=n12);
        select JSON_ARRAYAGG(json_object('so_id' value n11,'so_id_tt' value n12,'so_hd' value c10,'ngay_tt' value n13,
            'ma_nt' value c3,'hhong' value n1,'htro' value n2,'dvu' value n3,'thue' value n4,'chon' value '')
            order by c2,n13,c1 returning clob) into cs_ton from temp_2;
    end if;
end if;
select json_object('ma_dl' value b_ma_dl,'ten' value FBH_DL_MA_KH_TEN(b_ma_dl),
    'loai' value FBH_DTAC_MA_LOAI(b_ma_dl),'cs_ton' value cs_ton returning clob) into b_oraOut from dual;
delete temp_1; delete temp_2; delete temp_3; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_HH_TEST(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id_hh number,dt_ct in out clob,dt_dk clob,
    b_ngay_ht out number,b_so_ct out varchar2,b_ma_dl out varchar2,b_pt_tra out varchar2,
    b_ttoan_qd out number,b_thue_qd out number,b_phong out varchar2,
    b_nt_tra out varchar2,b_tra out number,b_tra_qd out number,
    a_so_id out pht_type.a_num,a_so_id_tt out pht_type.a_num,a_so_hd out pht_type.a_var,a_pt_tt out pht_type.a_var,
    a_ma_nt out pht_type.a_var,a_hhong out pht_type.a_num,a_htro out pht_type.a_num,a_dvu out pht_type.a_num,
    a_hhong_qd out pht_type.a_num,a_thue_hh out pht_type.a_num,a_thue_hh_qd out pht_type.a_num,
    a_htro_qd out pht_type.a_num,a_thue_ht out pht_type.a_num,a_thue_ht_qd out pht_type.a_num,
    a_dvu_qd out pht_type.a_num,a_thue_dv out pht_type.a_num,a_thue_dv_qd out pht_type.a_num,
    a_ngay_tt out pht_type.a_num,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_i2 number; b_i3 number; b_ngayc_dl number;
    b_tien_m number; b_tien_c number; b_thue_m number; b_thue_c number; b_log boolean:=false;
begin
-- Dan - Kiem tra so lieu duyet hoa hong
b_lenh:=FKH_JS_LENH('so_ct,ngay_ht,ma_dl,pt_tra,nt_tra,tra');
EXECUTE IMMEDIATE b_lenh into b_so_ct,b_ngay_ht,b_ma_dl,b_pt_tra,b_nt_tra,b_tra using dt_ct;
b_lenh:=FKH_JS_LENH('so_id,so_id_tt,ma_nt,hhong,htro,dvu');
EXECUTE IMMEDIATE b_lenh bulk collect into a_so_id,a_so_id_tt,a_ma_nt,a_hhong,a_htro,a_dvu using dt_dk;
if b_ngay_ht is null or trim(b_ma_dl) is null or b_pt_tra is null or b_pt_tra not in('T','H','C') or a_so_id.count=0 then
    b_loi:='loi:Nhap so lieu sai:loi'; return;
end if;
if FBH_DL_MA_KH_HAN(b_ma_dl)<>'C' then b_loi:='loi:Dai ly khong hoat dong:loi'; return; end if;
b_phong:=nvl(FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd),' ');
b_i1:=0;
for b_lp in 1.. a_so_id.count loop
    b_loi:='loi:Sai so lieu goc dong '||to_char(b_lp)||':loi';
    a_hhong(b_lp):=nvl(a_hhong(b_lp),0); a_htro(b_lp):=nvl(a_htro(b_lp),0); a_dvu(b_lp):=nvl(a_dvu(b_lp),0);
    if a_so_id(b_lp) is null or a_so_id_tt(b_lp) is null or a_ma_nt(b_lp) is null or
        a_hhong(b_lp)+a_htro(b_lp)+a_dvu(b_lp)=0 then return; end if;
    select nvl(min(ngay_ht),0),min(pt) into a_ngay_tt(b_lp),a_pt_tt(b_lp) from bh_hd_goc_ttpt
        where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp) and so_id_tt=a_so_id_tt(b_lp); -- and phong=b_phong
    if a_ngay_tt(b_lp)=0 then return; end if;
    if a_ngay_tt(b_lp)>b_ngay_ht then b_loi:='loi:Duyet hoa hong truoc thanh toan:loi'; return; end if;
    PBH_HD_HH_TON_CT(b_ma_dvi,a_so_id(b_lp),a_so_id_tt(b_lp),b_i1,b_i2,b_i3);
    if sign(b_i1-a_hhong(b_lp)) not in(0,sign(b_i1)) or sign(b_i2-a_htro(b_lp)) not in(0,sign(b_i2)) or sign(b_i3-a_dvu(b_lp)) not in(0,sign(b_i3)) then
        b_loi:='loi:Duyet qua so ton:loi'; return;
    end if;
    a_so_hd(b_lp):=FBH_HD_GOC_SO_HD_D(b_ma_dvi,a_so_id(b_lp));
end loop;
if b_pt_tra='T' then
    PBH_DL_CN_TU_TON(b_ma_dvi,b_ma_dl,b_nt_tra,b_ngay_ht,b_i1,b_i2);
    if b_i1<0 then b_loi:='loi:Dai ly con no tien phi khong tra tien mat:loi'; return; end if;
end if;
if b_nt_tra='VND' then
    b_tra_qd:=b_tra;
else
    b_tra_qd:=FBH_TT_VND_QD(b_ngay_ht,b_nt_tra,b_tra);
end if;
PBH_HD_HH_TINH(b_ma_dvi,b_ngay_ht,b_ma_dl,a_so_id,a_so_id_tt,a_ma_nt,a_hhong,a_htro,a_dvu,
    a_hhong_qd,a_htro_qd,a_dvu_qd,a_thue_hh,a_thue_hh_qd,a_thue_ht,a_thue_ht_qd,a_thue_dv,a_thue_dv_qd,b_loi);
b_ttoan_qd:=0; b_thue_qd:=0;
for b_lp in 1..a_so_id.count loop
    b_ttoan_qd:=b_ttoan_qd+a_hhong_qd(b_lp)+a_htro_qd(b_lp)+a_dvu_qd(b_lp);
    b_thue_qd:=b_thue_qd+a_thue_hh_qd(b_lp)+a_thue_ht_qd(b_lp)+a_thue_dv_qd(b_lp);
end loop;
if trim(b_so_ct) is null then
    b_so_ct:=substr(to_char(b_so_id_hh),3); PKH_JS_THAYn(dt_ct,'so_ct',b_so_ct);
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_HH_TEST:loi'; end if;
end;
/
create or replace procedure PBH_HD_HH_NH_NH
    (b_ma_dvi varchar2,b_nsd varchar2,dt_ct clob,
    b_so_id_hh number,b_ngay_ht number,b_so_ct varchar2,b_ma_dl varchar2,
    b_pt_tra varchar2,b_ttoan_qd number,b_thue_qd number,
    b_phong varchar2,b_nt_tra varchar2,b_tra number,b_tra_qd number,
    a_so_id pht_type.a_num,a_so_id_tt pht_type.a_num,a_so_hd pht_type.a_var,a_pt pht_type.a_var,a_ma_nt pht_type.a_var,
    a_hhong pht_type.a_num,a_htro pht_type.a_num,a_dvu pht_type.a_num,
    a_hhong_qd pht_type.a_num,a_thue_hh pht_type.a_num,a_thue_hh_qd pht_type.a_num,
    a_htro_qd pht_type.a_num,a_thue_ht pht_type.a_num,a_thue_ht_qd pht_type.a_num,
    a_dvu_qd pht_type.a_num,a_thue_dv pht_type.a_num,a_thue_dv_qd pht_type.a_num,a_ngay_tt pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_tp number; b_kt number; b_tl number; b_pt varchar2(1);
    b_hhong number; b_hhong_c number; b_hhong_t number; b_hhong_m number; b_hhong_i number; b_hhong_qd number; b_hhong_qd_c number;
    b_thue_hh number; b_thue_hh_c number; b_thue_hh_t number; b_thue_hh_m number; b_thue_hh_i number; b_thue_hh_qd number; b_thue_hh_qd_c number;
    b_htro number; b_htro_c number; b_htro_t number; b_htro_m number; b_htro_i number; b_htro_qd number; b_htro_qd_c number;
    b_thue_ht number; b_thue_ht_c number; b_thue_ht_t number; b_thue_ht_m number; b_thue_ht_i number; b_thue_ht_qd number; b_thue_ht_qd_c number;
    b_dvu number; b_dvu_c number; b_dvu_t number; b_dvu_m number; b_dvu_i number; b_dvu_qd number; b_dvu_qd_c number;
    b_thue_dv number; b_thue_dv_c number; b_thue_dv_t number; b_thue_dv_m number; b_thue_dv_i number; b_thue_dv_qd number; b_thue_dv_qd_c number;
    b_ten nvarchar2(500):=FBH_DL_MA_KH_TEN(b_ma_dl);
begin
-- Dan - Nhap duyet hoa hong
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','HH');
if b_loi is not null then return; end if;
insert into bh_hd_goc_hh values(b_ma_dvi,b_so_id_hh,b_ngay_ht,b_so_ct,b_phong,b_ma_dl,b_ten,
    b_pt_tra,b_ttoan_qd,b_thue_qd,b_nt_tra,b_tra,b_tra_qd,b_nsd,0,sysdate);
for b_lp in 1..a_so_id.count loop
    insert into bh_hd_goc_hh_ct values(b_ma_dvi,b_so_id_hh,b_lp,a_so_id(b_lp),a_so_id_tt(b_lp),a_so_hd(b_lp),a_pt(b_lp),b_ma_dvi,
        b_phong,b_ma_dl,a_ngay_tt(b_lp),a_ma_nt(b_lp),a_hhong(b_lp),a_htro(b_lp),a_dvu(b_lp),
        a_hhong_qd(b_lp),a_htro_qd(b_lp),a_dvu_qd(b_lp),a_thue_hh(b_lp)+a_thue_ht(b_lp)+a_thue_dv(b_lp),
        a_thue_hh_qd(b_lp)+a_thue_ht_qd(b_lp)+a_thue_dv_qd(b_lp));
end loop;
b_i1:=0;
if b_pt_tra<>'T' then
    PBH_DL_CN_TU_THOP(b_ma_dvi,'T',b_ngay_ht,b_ma_dl,b_nt_tra,b_tra,b_tra,b_loi);
    if b_loi is not null then return; end if;
    PBH_DL_CN_TU_KTRA(b_ma_dvi,b_loi);
    if b_loi is not null then return; end if;
end if;
for b_lp in 1..a_so_id.count loop
    if a_ma_nt(b_lp)<>'VND' then b_tp:=2; else b_tp:=0; end if;
    b_hhong_c:=a_hhong(b_lp); b_hhong_qd_c:=a_hhong_qd(b_lp);
    b_thue_hh_c:=a_thue_hh(b_lp); b_thue_hh_qd_c:=a_thue_hh_qd(b_lp);
    b_hhong_m:=0; b_hhong_i:=b_kt; b_thue_hh_m:=0; b_thue_hh_i:=b_kt;
    b_htro_c:=a_htro(b_lp); b_htro_qd_c:=a_htro_qd(b_lp);
    b_thue_ht_c:=a_thue_ht(b_lp); b_thue_ht_qd_c:=a_thue_ht_qd(b_lp);
    b_htro_m:=0; b_htro_i:=b_kt; b_thue_ht_m:=0; b_thue_ht_i:=b_kt;
    b_dvu_c:=a_dvu(b_lp); b_dvu_qd_c:=a_dvu_qd(b_lp);
    b_thue_dv_c:=a_thue_dv(b_lp); b_thue_dv_qd_c:=a_thue_dv_qd(b_lp);
    b_dvu_m:=0; b_dvu_i:=b_kt; b_thue_dv_m:=0; b_thue_dv_i:=b_kt;
    select nvl(sum(hhong),0),nvl(sum(htro),0),nvl(sum(dvu),0) into b_hhong_t,b_htro_t,b_dvu_t
        from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp) and so_id_tt=a_so_id_tt(b_lp) and pt<>'C';
    for r_lp in (select lh_nv,sum(hhong) hhong,sum(htro) htro,sum(dvu) dvu from bh_hd_goc_ttpt where
        ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp) and so_id_tt=a_so_id_tt(b_lp) and pt<>'C' group by lh_nv) loop
        if r_lp.hhong=0 and r_lp.htro=0 and r_lp.dvu=0 then continue; end if;
        b_hhong:=0; b_hhong_qd:=0; b_thue_hh:=0; b_thue_hh_qd:=0;
        if r_lp.hhong<>0 and b_hhong_t<>0 then
            b_tl:=r_lp.hhong/b_hhong_t;
            b_hhong:=round(a_hhong(b_lp)*b_tl,b_tp); b_thue_hh:=round(a_thue_hh(b_lp)*b_tl,b_tp);
            if a_ma_nt(b_lp)='VND' then
                b_hhong_qd:=b_hhong; b_thue_hh_qd:=b_thue_hh;
            else
                b_hhong_qd:=round(a_hhong_qd(b_lp)*b_tl,0); b_thue_hh_qd:=round(a_thue_hh_qd(b_lp)*b_tl,0);
            end if;
            b_hhong_c:=b_hhong_c-b_hhong; b_hhong_qd_c:=b_hhong_qd_c-b_hhong_qd;
            b_thue_hh_c:=b_thue_hh_c-b_thue_hh; b_thue_hh_qd_c:=b_thue_hh_qd_c-b_thue_hh_qd;
        end if;
        b_htro:=0; b_htro_qd:=0; b_thue_ht:=0; b_thue_ht_qd:=0;
        if r_lp.htro<>0 and b_htro_t<>0 then
            b_tl:=r_lp.htro/b_htro_t;
            b_htro:=round(a_htro(b_lp)*b_tl,b_tp); b_thue_ht:=round(a_thue_ht(b_lp)*b_tl,b_tp);
            if a_ma_nt(b_lp)='VND' then
                b_htro_qd:=b_htro; b_thue_ht_qd:=b_thue_ht;
            else
                b_htro_qd:=round(a_htro_qd(b_lp)*b_tl,0); b_thue_ht_qd:=round(a_thue_ht_qd(b_lp)*b_tl,0);
            end if;
            b_htro_c:=b_htro_c-b_htro; b_htro_qd_c:=b_htro_qd_c-b_htro_qd;
            b_thue_ht_c:=b_thue_ht_c-b_thue_ht; b_thue_ht_qd_c:=b_thue_ht_qd_c-b_thue_ht_qd;
        end if;
        b_dvu:=0; b_dvu_qd:=0; b_thue_dv:=0; b_thue_dv_qd:=0;
        if r_lp.dvu<>0 and b_dvu_t<>0 then
            b_tl:=r_lp.dvu/b_dvu_t;
            b_dvu:=round(a_dvu(b_lp)*b_tl,b_tp); b_thue_dv:=round(a_thue_dv(b_lp)*b_tl,b_tp);
            if a_ma_nt(b_lp)='VND' then
                b_dvu_qd:=b_dvu; b_thue_dv_qd:=b_thue_dv;
            else
                b_dvu_qd:=round(a_dvu_qd(b_lp)*b_tl,0); b_thue_dv_qd:=round(a_thue_dv_qd(b_lp)*b_tl,0);
            end if;
            b_dvu_c:=b_dvu_c-b_dvu; b_dvu_qd_c:=b_dvu_qd_c-b_dvu_qd;
            b_thue_dv_c:=b_thue_dv_c-b_thue_dv; b_thue_dv_qd_c:=b_thue_dv_qd_c-b_thue_dv_qd;
        end if;
        b_kt:=b_kt+1;
        insert into bh_hd_goc_hh_pt values(b_ma_dvi,b_so_id_hh,b_kt,a_so_id(b_lp),a_so_id_tt(b_lp),a_pt(b_lp),
            a_ma_nt(b_lp),r_lp.lh_nv,b_hhong,b_hhong_qd,b_htro,b_htro_qd,b_dvu,b_dvu_qd,
            b_thue_hh,b_thue_hh_qd,b_thue_ht,b_thue_ht_qd,b_thue_dv,b_thue_dv_qd);
        if b_hhong_m<b_hhong then b_hhong_m:=b_hhong; b_hhong_i:=b_kt; end if;
        if b_thue_hh_m<b_thue_hh then b_thue_hh_m:=b_thue_hh; b_thue_hh_i:=b_kt; end if;
        if b_htro_m<b_htro then b_htro_m:=b_htro; b_htro_i:=b_kt; end if;
        if b_thue_ht_m<b_thue_ht then b_thue_ht_m:=b_thue_ht; b_thue_ht_i:=b_kt; end if;
        if b_dvu_m<b_dvu then b_dvu_m:=b_dvu; b_dvu_i:=b_kt; end if;
        if b_thue_dv_m<b_thue_dv then b_thue_dv_m:=b_thue_dv; b_thue_dv_i:=b_kt; end if;
    end loop;
    if b_hhong_c<>0 or b_hhong_qd_c<>0 then
        update bh_hd_goc_hh_pt set hhong=hhong+b_hhong_c,hhong_qd=hhong_qd+b_hhong_qd_c
            where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh and bt=b_hhong_i;
    end if;
    if b_thue_hh_c<>0 or b_thue_hh_qd_c<>0 then
        update bh_hd_goc_hh_pt set thue_hh=thue_hh+b_thue_hh_c,thue_hh_qd=thue_hh_qd+b_thue_hh_qd_c
            where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh and bt=b_thue_hh_i;
    end if;
    if b_htro_c<>0 or b_htro_qd_c<>0 then
        update bh_hd_goc_hh_pt set htro=htro+b_htro_c,htro_qd=htro_qd+b_htro_qd_c
            where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh and bt=b_htro_i;
    end if;
    if b_thue_ht_c<>0 or b_thue_ht_qd_c<>0 then
        update bh_hd_goc_hh_pt set thue_ht=thue_ht+b_thue_ht_c,thue_ht_qd=thue_ht_qd+b_thue_ht_qd_c
            where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh and bt=b_thue_ht_i;
    end if;
    if b_dvu_c<>0 or b_dvu_qd_c<>0 then
        update bh_hd_goc_hh_pt set dvu=dvu+b_dvu_c,dvu_qd=dvu_qd+b_dvu_qd_c
            where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh and bt=b_dvu_i;
    end if;
    if b_thue_dv_c<>0 or b_thue_dv_qd_c<>0 then
        update bh_hd_goc_hh_pt set thue_dv=thue_dv+b_thue_dv_c,thue_dv_qd=thue_dv_qd+b_thue_dv_qd_c
            where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh and bt=b_thue_dv_i;
    end if;
end loop;
insert into bh_hd_goc_hh_txt values(b_ma_dvi,b_so_id_hh,'dt_ct',dt_ct);
for b_lp in 1..a_so_id.count loop
    PBH_HD_HH_PTDT(b_ma_dvi,a_so_id(b_lp),b_so_id_hh,b_loi);
    if b_loi is not null then return; end if;
end loop;
for b_lp in 1..a_so_id.count loop
    PBH_TH_HH(b_ma_dvi,a_so_id(b_lp),a_so_id_tt(b_lp),b_loi);
    if b_loi is not null then return; end if;
end loop;
for b_lp in 1..a_so_id.count loop
    PBH_TH_DO_HH(b_ma_dvi,b_so_id_hh,a_so_id(b_lp),b_loi);
    if b_loi is not null then return; end if;
end loop;
--PTBH_TH_TA_HH(b_ma_dvi,b_so_id_hh,b_loi);
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_HH_NH_NH:loi'; end if;
end;
/
create or replace procedure PBH_HD_HH_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id_hh number,b_loi out varchar2)
AS
    b_nsdC varchar2(10); b_ngay_ht number; b_ma_dl varchar2(20); b_i1 number; b_kt number;
    b_pt_tra varchar2(1); b_nt_tra varchar2(5); b_tra number; b_tra_qd number;
    a_so_id pht_type.a_num; a_so_id_tt pht_type.a_num;
begin
-- Dan - Xoa thanh toan hoa hong
b_loi:='';
select ma_dl,ngay_ht,nsd,pt_tra,nt_tra,tra,tra_qd,so_id_kt into
    b_ma_dl,b_ngay_ht,b_nsdC,b_pt_tra,b_nt_tra,b_tra,b_tra_qd,b_i1
    from bh_hd_goc_hh where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','HH');
if b_loi is not null then return; end if;
if trim(b_nsdC) is not null and b_nsdC<>b_nsd then b_loi:='loi:Khong sua, xoa chung tu nguoi khac:loi'; return; end if;
if b_i1>0 then b_loi:='loi:Thanh toan hoa hong da hach toan:loi'; return; end if;
b_kt:=0;
for r_lp in (select so_id,so_id_tt from bh_hd_goc_hh_ct where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh) loop
    b_kt:=b_kt+1; a_so_id(b_kt):=r_lp.so_id; a_so_id_tt(b_kt):=r_lp.so_id_tt;
end loop;
if b_pt_tra<>'T' then
    PBH_DL_CN_TU_THOP(b_ma_dvi,'T',b_ngay_ht,b_ma_dl,b_nt_tra,-b_tra,-b_tra_qd,b_loi);
    if b_loi is not null then return; end if;
    PBH_DL_CN_TU_KTRA(b_ma_dvi,b_loi);
    if b_loi is not null then return; end if;
end if;
delete bh_hd_goc_hh_txt where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh;
delete bh_hd_goc_hh_ptdt where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh;
delete bh_hd_goc_hh_pt where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh;
delete bh_hd_goc_hh_ct where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh;
delete bh_hd_goc_hh_dly where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh;
delete bh_hd_goc_hh where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh;
for b_lp in 1..b_kt loop
    PBH_TH_HH(b_ma_dvi,a_so_id(b_lp),a_so_id_tt(b_lp),b_loi);
    if b_loi is not null then return; end if;
end loop;
PBH_TH_DO_XOA_PS(b_ma_dvi,b_so_id_hh,b_loi);
if b_loi is not null then return; end if;
PTBH_TH_TA_XOA(b_so_id_hh,0,0,0,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HD_HH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    a_tien_qd pht_type.a_num; a_ngay_tt pht_type.a_num;
    a_hhong_qd pht_type.a_num; a_thue_hh pht_type.a_num; a_thue_hh_qd pht_type.a_num;
    a_htro_qd pht_type.a_num; a_thue_ht pht_type.a_num; a_thue_ht_qd pht_type.a_num;
    a_dvu_qd pht_type.a_num; a_thue_dv pht_type.a_num; a_thue_dv_qd pht_type.a_num; a_ptG pht_type.a_var;

    b_so_id_hh number; b_ngay_ht number; b_so_ct varchar2(20);
    b_ma_dl varchar2(20); b_phong varchar2(10);
    b_pt_tra varchar2(1); b_ttoan_qd number; b_thue_qd number;
    b_nt_tra varchar2(5); b_tra number; b_tra_qd number;

    a_so_id pht_type.a_num; a_so_id_tt pht_type.a_num; a_so_hd pht_type.a_var;
    a_pt pht_type.a_var; a_ma_nt pht_type.a_var;
    a_hhong pht_type.a_num; a_htro pht_type.a_num; a_dvu pht_type.a_num;
    dt_ct clob; dt_dk clob;
begin
-- Dan - Nhap duyet hoa hong
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HH','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id_hh:=FKH_JS_GTRIn(b_oraIn,'so_id_hh');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk);
if b_so_id_hh>0 then
    PBH_HD_HH_XOA_XOA(b_ma_dvi,b_nsd,b_so_id_hh,b_loi);
else
    PHT_ID_MOI(b_so_id_hh,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_HD_HH_TEST(b_ma_dvi,b_nsd,b_so_id_hh,dt_ct,dt_dk,
    b_ngay_ht,b_so_ct,b_ma_dl,b_pt_tra,b_ttoan_qd,b_thue_qd,b_phong,b_nt_tra,b_tra,b_tra_qd,
    a_so_id,a_so_id_tt,a_so_hd,a_pt,a_ma_nt,a_hhong,a_htro,a_dvu,a_hhong_qd,a_thue_hh,a_thue_hh_qd,
    a_htro_qd,a_thue_ht,a_thue_ht_qd,a_dvu_qd,a_thue_dv,a_thue_dv_qd,a_ngay_tt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_HD_HH_NH_NH(b_ma_dvi,b_nsd,dt_ct,
    b_so_id_hh,b_ngay_ht,b_so_ct,b_ma_dl,b_pt_tra,b_ttoan_qd,b_thue_qd,b_phong,b_nt_tra,b_tra,b_tra_qd,
    a_so_id,a_so_id_tt,a_so_hd,a_pt,a_ma_nt,a_hhong,a_htro,a_dvu,a_hhong_qd,a_thue_hh,a_thue_hh_qd,
    a_htro_qd,a_thue_ht,a_thue_ht_qd,a_dvu_qd,a_thue_dv,a_thue_dv_qd,a_ngay_tt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('so_id' value b_so_id_hh,'so_ct' value b_so_ct) into b_oraOut from dual;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_HH_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_so_id_hh number;
begin
-- Dan - Nhap thanh toan phi
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HH','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id_hh:=FKH_JS_GTRIn(b_oraIn,'so_id_hh');
PBH_HD_HH_XOA_XOA(b_ma_dvi,b_nsd,b_so_id_hh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--duchq update length email
create or replace procedure PBH_HD_HH_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_idD number; b_ma_dl varchar2(20); b_so_hd varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number; b_ten nvarchar2(500); 
begin
-- Dan - Tim duyet hoa hong qua CMT, mobi, email
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HH','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,cmt,mobi,email,so_hd,ten');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_cmt,b_mobi,b_email,b_so_hd,b_ten using b_oraIn;
if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_ten:=nvl(trim(upper(b_ten)), ' ');
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_dl:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_dl is null then b_loi:='loi:Khong tim duoc dai ly:loi'; raise PROGRAM_ERROR; end if; 
    select count(*) into b_dong from bh_hd_goc_hh where ma_dvi=b_ma_dvi and ma_dl=b_ma_dl and ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd;
    select JSON_ARRAYAGG(json_object(a.ngay_ht,'nv' value FBH_HD_NV(b.ma_dvi,b.so_id),
        'so_hd' value FBH_HD_GOC_SO_HD_D(b.ma_dvi,b.so_id),a.ten,a.so_id_hh) order by a.ngay_ht desc returning clob) into cs_lke
        from bh_hd_goc_hh a, bh_hd_goc_hh_ct b where a.ma_dvi=b_ma_dvi and a.ma_dl=b_ma_dl and
            a.ngay_ht between b_ngayD and b_ngayC and a.nsd=b_nsd and b.ma_dvi=a.ma_dvi and b.so_id_hh=a.so_id_hh and 
            (b_so_hd = ' ' OR b.so_hd LIKE '%' || b_so_hd || '%') and (b_ten = ' ' OR upper(a.ten) LIKE '%' || b_ten || '%');
elsif b_ngayD between b_ngay and 30000101 then
    select count(*) into b_dong from bh_hd_goc_hh where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd;
    select JSON_ARRAYAGG(json_object(a.ngay_ht,'nv' value FBH_HD_NV(b.ma_dvi,b.so_id),
        'so_hd' value FBH_HD_GOC_SO_HD_D(b.ma_dvi,b.so_id),a.ten,a.so_id_hh) order by a.ngay_ht desc returning clob) into cs_lke
        from bh_hd_goc_hh a, bh_hd_goc_hh_ct b where a.ma_dvi=b_ma_dvi and
            a.ngay_ht between b_ngayD and b_ngayC and a.nsd=b_nsd and b.ma_dvi=a.ma_dvi and b.so_id_hh=a.so_id_hh and 
            (b_so_hd = ' ' OR b.so_hd LIKE '%' || b_so_hd || '%') and (b_ten = ' ' OR upper(a.ten) LIKE '%' || b_ten || '%');
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
