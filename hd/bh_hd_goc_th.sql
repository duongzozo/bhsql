create or replace function FBH_TH_NO_QD(
    b_ma_dvi varchar2,b_so_id number,b_ma_nt varchar2,b_ngay_ht number,b_l_ct varchar2,b_tien number) return number
AS
    b_i1 number; b_ton number:=0; b_ton_qd number; b_tien_qd number:=b_tien;
begin
-- Dan - Qui doi tien
if b_ma_nt<>'VND' then
    PBH_TH_NO_TON(b_ma_dvi,b_so_id,b_ma_nt,b_ngay_ht,b_ton,b_ton_qd);
    if b_l_ct='N' then b_ton:=-b_ton; b_ton_qd:=-b_ton_qd; end if;
    if b_ton=b_tien then b_tien_qd:=b_ton_qd;
    elsif b_ton>b_tien then b_tien_qd:=round((b_tien*b_ton_qd/b_ton),0);
    else
        b_i1:=FBH_TT_TRA_TGTT(b_ngay_ht,b_ma_nt);
        if b_ton>0 then b_tien_qd:=b_ton_qd+round((b_tien-b_ton)*b_i1,0);
        else b_tien_qd:=round(b_tien*b_i1,0);
        end if;
    end if;
end if;
return b_tien_qd;
end;
/
create or replace procedure PBH_TH_PHI_CL(
    b_ma_dvi varchar2,b_so_id_xl number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_thuP varchar2(1); b_kieu varchar2(1):='D';
    b_kieu_hd varchar2(1); b_phi number; b_thue number; b_ttoan number;
    b_phiT number; b_thueT number; b_phiC number; b_thueC number; b_kieu_do varchar2(1);
    b_so_idD number; b_ma_nt varchar2(5); b_tp number:=0; b_ngay_ht number; b_nbh varchar2(20);
    a_nbh pht_type.a_var; a_pthuc pht_type.a_var;
begin
-- Dan - Tinh so con lai sau dong bao hiem
b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id_xl);
if b_so_idD=0 then b_loi:=''; return; end if;
b_kieu_do:=FBH_DONG(b_ma_dvi,b_so_idD);
PBH_HD_NBH(b_ma_dvi,b_so_idD,a_nbh,a_pthuc);
if a_nbh.count=0 then
    insert into bh_hd_goc_cl select a.*,' ' from bh_hd_goc_pt a where ma_dvi=b_ma_dvi and so_id_xl=b_so_id_xl;
    b_loi:=''; return;
end if;
select ngay_ht,kieu_hd,nt_phi into b_ngay_ht,b_kieu_hd,b_ma_nt
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id_xl;
if b_ma_nt<>'VND' then b_tp:=2; end if;
b_thuP:=FBH_HD_DO_NH_TXT(b_ma_dvi,b_so_idD,'D','ph');
for r_lp1 in (select ma_dt,lh_nv,t_suat,ngay,sum(phi) phi,sum(thue) thue from bh_hd_goc_pt where
    ma_dvi=b_ma_dvi and so_id_xl=b_so_id_xl group by ma_dt,lh_nv,t_suat,ngay having sum(phi)<>0) loop
    b_phiT:=r_lp1.phi; b_phiC:=b_phiT; b_thueT:=r_lp1.thue; b_thueC:=b_thueT; b_ttoan:=0;
    for b_lp in 1..a_nbh.count loop
        if b_thuP='K' and a_pthuc(b_lp)='D' then continue; end if;
        if a_pthuc(b_lp)='T' then
            b_i1:=FBH_HD_NBH_TL(b_ma_dvi,b_so_idD,r_lp1.lh_nv,a_pthuc(b_lp));
        else
            b_i1:=FBH_HD_NBH_TL(b_ma_dvi,b_so_idD,r_lp1.lh_nv,a_pthuc(b_lp),a_nbh(b_lp));
            if b_kieu_do='V' then b_i1:=100-b_i1; end if;
        end if;
        if b_i1=0 then continue; end if;
        b_phi:=round(b_phiT*b_i1/100,b_tp); b_thue:=round(b_thueT*b_i1/100,b_tp);
        if a_pthuc(b_lp)<>'D' then
            b_ttoan:=b_phi+b_thue; 
            insert into bh_hd_goc_cl values(b_ma_dvi,b_so_id_xl,0,b_kieu_hd,b_ngay_ht,b_so_idD,r_lp1.ngay,
                r_lp1.ma_dt,b_ma_nt,r_lp1.lh_nv,r_lp1.t_suat,b_phi,b_thue,b_ttoan,a_nbh(b_lp));
        end if;
        b_phiC:=b_phiC-b_phi; b_thueC:=b_thueC-b_thue;
    end loop;
    if b_ttoan=0 and b_phiC<>0 then
        b_ttoan:=b_phiC+b_thueC;
        insert into bh_hd_goc_cl values(b_ma_dvi,b_so_id_xl,0,b_kieu_hd,b_ngay_ht,b_so_idD,r_lp1.ngay,
            r_lp1.ma_dt,b_ma_nt,r_lp1.lh_nv,r_lp1.t_suat,b_phiC,b_thueC,b_ttoan,' ');
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_PHI_CL:loi'; end if;
end;
/
create or replace procedure PBH_TH_PHI_CLDT(
    b_ma_dvi varchar2,b_so_id_xl number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_thuP varchar2(1);
    b_nv varchar2(10); b_kieu_do varchar2(1);
    b_kieu_hd varchar2(1); b_phi number; b_thue number; b_ttoan number;
    b_phiT number; b_thueT number; b_phiC number; b_thueC number;
    b_so_idD number; b_ma_nt varchar2(5); b_tp number:=0; b_ngay_ht number;
    a_nbh pht_type.a_var; a_pthuc pht_type.a_var;
begin
-- Dan - Tinh so con lai sau dong bao hiem
b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id_xl);
if b_so_idD=0 then b_loi:=''; return; end if;
b_kieu_do:=FBH_DONG(b_ma_dvi,b_so_idD);
PBH_HD_NBH(b_ma_dvi,b_so_idD,a_nbh,a_pthuc);
if a_nbh.count=0 then
    insert into bh_hd_goc_cldt select a.*,' ' from bh_hd_goc_ptdt a where ma_dvi=b_ma_dvi and so_id_xl=b_so_id_xl;
    b_loi:=''; return;
end if;
select nv,ngay_ht,kieu_hd,nt_phi into b_nv,b_ngay_ht,b_kieu_hd,b_ma_nt
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id_xl;
if b_nv not in('PHH','PKT','2B','XE','TAU') then
    insert into bh_hd_goc_cldt select
        ma_dvi,so_id_xl,bt,kieu_hd,ngay_ht,so_id,0,ngay,
        ma_dt,ma_nt,lh_nv,t_suat,phi,thue,ttoan,nha_bh
        from bh_hd_goc_cl where ma_dvi=b_ma_dvi and so_id_xl=b_so_id_xl;
    b_loi:=''; return;
else
    select count(*) into b_i1 from bh_hd_goc_dkdt where
        ma_dvi=b_ma_dvi and so_id=b_so_idD and so_id_dt<>b_so_idD;
    if b_i1=0 then
        insert into bh_hd_goc_cldt select
            ma_dvi,so_id_xl,bt,kieu_hd,ngay_ht,so_id,b_so_idD,ngay,
            ma_dt,ma_nt,lh_nv,t_suat,phi,thue,ttoan,nha_bh
            from bh_hd_goc_cl where ma_dvi=b_ma_dvi and so_id_xl=b_so_id_xl;
        b_loi:=''; return;
    end if;
end if;
if b_ma_nt<>'VND' then b_tp:=2; end if;
b_thuP:=FBH_HD_DO_NH_TXT(b_ma_dvi,b_so_idD,'D','ph');
for r_lp1 in (select so_id_dt,ma_dt,lh_nv,t_suat,ngay,sum(phi) phi,sum(thue) thue from bh_hd_goc_ptdt where
    ma_dvi=b_ma_dvi and so_id_xl=b_so_id_xl group by so_id_dt,ma_dt,lh_nv,t_suat,ngay having sum(phi)<>0) loop
    b_phiT:=r_lp1.phi; b_phiC:=b_phiT; b_thueT:=r_lp1.thue; b_thueC:=b_thueT; b_ttoan:=0;
    for b_lp in 1..a_nbh.count loop
        if b_thuP='K' and a_pthuc(b_lp)='D' then continue; end if;
        if a_pthuc(b_lp)='T' then
            b_i1:=FBH_HD_NBH_TL_DT(b_ma_dvi,b_so_idD,r_lp1.so_id_dt,r_lp1.lh_nv,a_pthuc(b_lp));
        else
            b_i1:=FBH_HD_NBH_TL_DT(b_ma_dvi,b_so_idD,r_lp1.so_id_dt,r_lp1.lh_nv,a_pthuc(b_lp),a_nbh(b_lp));
            if b_kieu_do='V' then b_i1:=100-b_i1; end if;
        end if;
        if b_i1=0 then continue; end if;
        b_phi:=round(b_phiT*b_i1/100,b_tp); b_thue:=round(b_thueT*b_i1/100,b_tp);
        if a_pthuc(b_lp)='D' then
            b_ttoan:=b_phi+b_thue; 
            insert into bh_hd_goc_cldt values(b_ma_dvi,b_so_id_xl,0,b_kieu_hd,b_ngay_ht,b_so_idD,r_lp1.so_id_dt,
                r_lp1.ngay,r_lp1.ma_dt,b_ma_nt,r_lp1.lh_nv,r_lp1.t_suat,b_phi,b_thue,b_ttoan,a_nbh(b_lp));
        end if;
        b_phiC:=b_phiC-b_phi; b_thueC:=b_thueC-b_thue;
    end loop;
    if b_ttoan=0 and b_phiC<>0 then
        b_ttoan:=b_phiC+b_thueC;
        insert into bh_hd_goc_cldt values(b_ma_dvi,b_so_id_xl,0,b_kieu_hd,b_ngay_ht,b_so_idD,r_lp1.so_id_dt,
            r_lp1.ngay,r_lp1.ma_dt,b_ma_nt,r_lp1.lh_nv,r_lp1.t_suat,b_phiC,b_thueC,b_ttoan,' ');
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_PHI_CLDT:loi'; end if;
end;
/
create or replace procedure PBH_HD_GOC_THL_KEM(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; a_so_id pht_type.a_num;
begin
-- Dan - Tong hop lai 1 hop dong
delete bh_hd_goc_cl where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_goc_sc_phi where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_goc_sc_no where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_goc_sc_phi_ton where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_goc_sc_no_ton where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_i2:=0;
for r_lp in(select ngay_ht,so_id_xl from bh_hd_goc_pt where ma_dvi=b_ma_dvi and so_id=b_so_id order by ngay_ht,so_id_xl) loop
    b_i1:=r_lp.so_id_xl;
    if b_i2=0 or FKH_ARR_TIM_N(a_so_id,b_i1)='K' then
        b_i2:=b_i2+1; a_so_id(b_i2):=b_i1;
    end if;
end loop;
for b_lp in 1..a_so_id.count loop
    PBH_TH_PHI_CL(b_ma_dvi,a_so_id(b_lp),b_loi);
    if b_loi is not null then return; end if;
    PBH_TH_PHI_CLDT(b_ma_dvi,a_so_id(b_lp),b_loi);
    if b_loi is not null then return; end if;
end loop;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_GOC_THL_KEM:loi'; end if;
end;
/
create or replace procedure PBH_TH_PHI_TON_CT
    (b_ma_dvi varchar2,b_so_id number,b_pt varchar2,b_ma_nt varchar2,b_ngay_ht number,
    a_ngay out pht_type.a_num,a_ma_dt out pht_type.a_var,a_lh_nv out pht_type.a_var,
    a_t_suat out pht_type.a_num,a_phi out pht_type.a_num,a_thue out pht_type.a_num,
    a_ttoan out pht_type.a_num,a_phi_qd out pht_type.a_num,a_thue_qd out pht_type.a_num,
    a_ttoan_qd out pht_type.a_num,a_uu out pht_type.a_var,b_loi out varchar2)
AS
    b_i1 number:=0;
begin
-- Dan - Ton chi tiet theo loai:no,cho no
delete temp_1; delete temp_2; PKH_MANG_KD(a_lh_nv);
if b_pt<>'N' then
    insert into temp_1(n10,c1,c2,n1,n2,n3,n4,n5,n6,n7,n8,n9)
        select ngay,lh_nv,ma_dt,t_suat,sum(phi),sum(thue),sum(ttoan),sum(phi),0,0,0,0
        from bh_hd_goc_cl where ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=b_ma_nt and ngay_ht<=b_ngay_ht
        group by ngay,lh_nv,ma_dt,t_suat;
    insert into temp_1(n10,c1,c2,n1,n2,n3,n4,n5,n6,n7,n8,n9)
        select ngay,lh_nv,ma_dt,t_suat,-sum(phi),-sum(thue),-sum(ttoan),-sum(phi),0,0,0,0
        from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id=b_so_id and
        pt<>'N' and ma_nt=b_ma_nt group by ngay,lh_nv,ma_dt,t_suat;
else    insert into temp_1(n10,c1,c2,n1,n2,n3,n4,n5,n6,n7,n8,n9)
        select ngay,lh_nv,ma_dt,t_suat,sum(phi),sum(thue),sum(ttoan),sum(phi),sum(phi_qd),sum(thue_qd),sum(ttoan_qd),sum(phi_qd)
        from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id=b_so_id and
        pt='C' and ma_nt=b_ma_nt group by ngay,lh_nv,ma_dt,t_suat;
    insert into temp_1(n10,c1,c2,n1,n2,n3,n4,n5,n6,n7,n8,n9)
        select ngay,lh_nv,ma_dt,t_suat,-sum(phi),-sum(thue),-sum(ttoan),-sum(phi),-sum(phi_qd),-sum(thue_qd),-sum(ttoan_qd),-sum(phi_qd)
        from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id=b_so_id and
        pt='N' and ma_nt=b_ma_nt group by ngay,lh_nv,ma_dt,t_suat;
end if;
insert into temp_2(n10,c1,c2,n1,n2,n3,n4,n5,n6,n7,n8,n9) select n10,c1,c2,n1,sum(n2),sum(n3),sum(n4),sum(n5),sum(n6),sum(n7),sum(n8),sum(n9)
    from temp_1 group by n10,c1,c2,n1 having sum(n4)<>0;
select n10,c1,c2,n1,n2,n3,n4,n5,n6,n7,n8,n9 BULK COLLECT into
    a_ngay,a_lh_nv,a_ma_dt,a_t_suat,a_phi,a_thue,a_ttoan,a_phi,
    a_phi_qd,a_thue_qd,a_ttoan_qd,a_phi_qd from temp_2 order by n10,c10;
for b_lp in 1..a_lh_nv.count loop
    a_uu(b_lp):=FBH_MA_LHNV_UU(a_lh_nv(b_lp));
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_PHI_TON_CT:loi'; end if;
end;
/
create or replace PROCEDURE PBH_TH_TTPT(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
begin
-- Dan - Phan tich thanh toan
for r_lp in(select distinct so_id_tt from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    PBH_TH_TTPT_ID(b_ma_dvi,b_so_id,r_lp.so_id_tt,b_loi);
    if b_loi is not null then return; end if;
    PBH_TH_TTPTDT_ID(b_ma_dvi,b_so_id,r_lp.so_id_tt,b_loi);
    if b_loi is not null then return; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_TTPT:loi'; end if;
end;
/
create or replace procedure PBH_TH_NO_THOP(
    b_ma_dvi varchar2,b_ps varchar2,b_so_id number,b_ma_nt varchar2,
    b_ngay_ht number,b_tien number,b_tien_qd number,b_loi out varchar2)
AS
    b_no number; b_co number; b_ton number; b_i1 number; b_i2 number;
    b_no_qd number; b_co_qd number; b_ton_qd number;
begin
-- Dan - Tong hop cho no
if b_ps='C' then b_no:=b_tien; b_no_qd:=b_tien_qd; b_co:=0; b_co_qd:=0;
else b_no:=0; b_no_qd:=0; b_co:=b_tien; b_co_qd:=b_tien_qd;
end if;
update bh_hd_goc_sc_no set no=no+b_no,no_qd=no_qd+b_no_qd,co=co+b_co,co_qd=co_qd+b_co_qd
    where ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=b_ma_nt and ngay_ht=b_ngay_ht;
if sql%rowcount=0 then
    insert into bh_hd_goc_sc_no values (b_ma_dvi,b_so_id,b_ma_nt,b_ngay_ht,b_no,b_no_qd,b_co,b_co_qd,0,0);
end if;
PBH_TH_NO_TON(b_ma_dvi,b_so_id,b_ma_nt,b_ngay_ht-1,b_ton,b_ton_qd);
for b_rc in (select * from bh_hd_goc_sc_no where ma_dvi=b_ma_dvi and so_id=b_so_id and
    ma_nt=b_ma_nt and ngay_ht>=b_ngay_ht order by ngay_ht) loop
    b_i1:=b_rc.ngay_ht;
    if b_rc.no=0 and b_rc.co=0 and b_rc.no_qd=0 and b_rc.co_qd=0 then
        delete bh_hd_goc_sc_no where ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=b_ma_nt and ngay_ht=b_i1;
    else
        b_ton:=b_ton+b_rc.no-b_rc.co; b_ton_qd:=b_ton_qd+b_rc.no_qd-b_rc.co_qd;
        update bh_hd_goc_sc_no set ton=b_ton,ton_qd=b_ton_qd where
            ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=b_ma_nt and ngay_ht=b_i1;
    end if;
end loop;
PBH_TH_SC_NO_TON(b_ma_dvi,b_so_id,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_NO_THOP:loi'; end if;
end;
/
create or replace procedure PBH_TH_HH(
    b_ma_dvi varchar2,b_so_id number,b_so_id_tt number,b_loi out varchar2)
AS
    b_i1 number:=0; b_i2 number; b_kieu_hd varchar2(1);
    b_pt varchar2(1):=' '; b_pt_tra varchar2(1); b_ma_dl varchar2(20);
begin
-- Dan - Tong hop so cai hoa hong
delete bh_hd_goc_sc_hh where dvi_xl=b_ma_dvi and so_id=b_so_id and so_id_tt=b_so_id_tt;
select kieu_hd,ma_kt into b_kieu_hd,b_ma_dl from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_ma_dl=' ' or b_kieu_hd in('U','K','V','N') then b_loi:=''; return; end if;
if b_so_id*10=b_so_id_tt and FBH_HD_HU(b_ma_dvi,b_so_id)='C' then
    b_pt:='H';
    select tra,con into b_i1,b_i2 from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1=0 or b_i2=0 then b_loi:=''; return; end if;
else
    select nvl(min(pt_tra),'N') into b_pt_tra from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
    if b_pt_tra='N' then b_loi:=''; return; end if;
end if;
select nvl(sum(hhong+htro+dvu),0) into b_i1 from bh_hd_goc_ttpt where
    ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_tt=b_so_id_tt and pt<>'C';
select nvl(sum(hhong+htro+dvu),0) into b_i2 from bh_hd_goc_hh_ct where
    dvi_xl=b_ma_dvi and so_id=b_so_id and so_id_tt=b_so_id_tt;
if b_i1<>b_i2 then
    insert into bh_hd_goc_sc_hh values(b_ma_dvi,b_so_id,b_so_id_tt,1,b_ma_dvi,' ',b_ma_dl,0);
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_HH:loi'; end if;
end;
/
create or replace procedure PBH_HD_DO_TH_PS(
    b_ma_dvi varchar2,b_so_id number,b_so_id_ps number,b_loi out varchar2)
AS
    b_i1 number:=0; b_i2 number;
begin
-- Dan - Tong hop so cai phat sinh bh_hd_do_sc_ps
if FBH_DONG(b_ma_dvi,b_so_id)='G' then
    delete bh_hd_do_sc_ps where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_ps=b_so_id_ps;
    b_loi:=''; return;
end if;
delete temp_1;
insert into temp_1(c1,c2,c3,c4,n1,n2)
    select nhom,loai,nha_bh,ma_nt,tien,thue from bh_hd_do_ps where 
        ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_ps=b_so_id_ps union
    select a.nhom,a.loai,b.nha_bh,a.ma_nt,-a.tien,-a.thue
        from bh_hd_do_pt a,bh_hd_do_tt b where
        a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and a.so_id_ps=b_so_id_ps and
        b.ma_dvi=b_ma_dvi and b.so_id_tt=a.so_id_tt;
select count(*) into b_i1 from (select c1,c2,c3,c4,sum(n1),sum(n2) from temp_1
    group by c1,c2,c3,c4 having sum(n1)<>0 or sum(n2)<>0) a;
select count(*) into b_i2 from bh_hd_do_sc_ps where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_ps=b_so_id_ps;
if b_i1=0 then
    if b_i2<>0 then delete bh_hd_do_sc_ps where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_ps=b_so_id_ps; end if;
elsif
    b_i2=0 then insert into bh_hd_do_sc_ps values(b_ma_dvi,b_so_id,b_so_id_ps);
end if;
delete temp_1;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_DO_TH_PS:loi'; end if;
end;
/
create or replace procedure PBH_HD_DO_TH_VAT(b_ma_dvi varchar2,b_so_id_tt number,b_loi out varchar2)
AS
    b_i1 number:=0; b_ngay_ht number; b_nha_bh varchar2(20);
begin
-- Dan - Tong hop so cai thue VAT
delete temp_1;
delete bh_hd_do_sc_vat where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
select count(*) into b_i1 from bh_hd_do_ct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
if b_i1=0 then b_loi:=''; return; end if;
select nvl(min(ngay_ht),0) into b_ngay_ht from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
if b_ngay_ht<>0 then
    insert into temp_1(c1,c2,n5) select 'R',ma_nt,phi
        from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and
        pt<>'C' and FBH_HD_DO_NH_TXT(b_ma_dvi,so_id,'D','ph')='K';
else
    select nvl(min(ngay_ht),0) into b_ngay_ht from bh_hd_do_tt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
    if b_ngay_ht<>0 then
        insert into temp_1(c1,c2,n5) select decode(nv,'T','R','V'),ma_nt,tien from
        (select nv,ma_nt,sum(tien) tien from bh_hd_do_pt where ma_dvi=b_ma_dvi and
        so_id_tt=b_so_id_tt group by nv,ma_nt having sum(tien)<>0);
    end if;
end if;
insert into temp_1(c1,c2,n5)
    select FBH_HD_DO_VAT_LOAI(b_ma_dvi,so_id_vat),ma_nt,-tien
    from bh_hd_do_vat_ct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
select count(*) into b_i1 from (select c1,c2,sum(n5) from temp_1 group by c1,c2 having sum(n5)<>0);
if b_i1<>0 then
    select max(nha_bh),max(ngay_ht) into b_nha_bh,b_ngay_ht from bh_hd_do_tt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
    insert into bh_hd_do_sc_vat values(b_ma_dvi,b_so_id_tt,' ',b_nha_bh,b_ngay_ht);
end if;
b_loi:='';
delete temp_1;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_DO_TH_PS:loi'; end if;
end;
/
create or replace procedure PBH_TH_VAT
    (b_ma_dvi varchar2,b_so_id number,b_so_id_tt number,b_loi out varchar2)
AS
    b_i1 number:=0; b_i2 number;
    a_ma_nt pht_type.a_var; a_t_suat pht_type.a_num; a_ttoan pht_type.a_num;
    a_ma_ntT pht_type.a_var; a_t_suatT pht_type.a_num; a_ttoanT pht_type.a_num;
begin
-- Dan - Tong hop so cai thue VAT
select count(*) into b_i2 from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
if b_i2<>0 then
    select count(*) into b_i1 from (select ma_nt,t_suat,sum(ttoan) from
        (select ma_nt,t_suat,ttoan from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_tt=b_so_id_tt and pt not in('N','H') union
        select ma_nt,t_suat,-ttoan from bh_hd_goc_vat_ct where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_tt=b_so_id_tt)
        group by ma_nt,t_suat having sum(ttoan)<>0);
    select count(*) into b_i2 from bh_hd_goc_sc_vat where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_tt=b_so_id_tt;
end if;
if b_i1=0 then
    if b_i2<>0 then delete bh_hd_goc_sc_vat where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_tt=b_so_id_tt; end if;
elsif b_i2=0 then
    insert into bh_hd_goc_sc_vat values(b_ma_dvi,b_so_id,b_so_id_tt);
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_VAT:loi'; end if;
end;
/
create or replace procedure PBH_TH_TH(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_so_idD number; b_kieu_do varchar2(1); b_kieu_phv varchar2(1); b_kieu_hd varchar2(1);
    pbo_ma_dvi pht_type.a_var; pbo_so_id_tt pht_type.a_num; pbo_phi pht_type.a_num;
    
begin
-- Dan - Phan tich thuc hien thanh toan
select nvl(min(so_id_d),0),min(kieu_hd) into b_so_idD,b_kieu_hd from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_so_idD=0 then b_loi:=''; return; end if;
delete bh_hd_goc_sc_hh where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_goc_sc_vat where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_goc_ttptdt where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_kieu_hd in('U','K') then return; end if;
select count(*) into b_i1 from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
PBH_TH_TTPT(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
for r_lp in (select distinct so_id_tt from bh_hd_goc_ttpt where
    ma_dvi=b_ma_dvi and so_id=b_so_id and (hhong+htro+dvu<>0)) loop
    PBH_TH_HH(b_ma_dvi,b_so_id,r_lp.so_id_tt,b_loi);
end loop;
b_kieu_do:=FBH_DONG(b_ma_dvi,b_so_id); b_kieu_phv:=FBH_HD_DO_NH_TXT(b_ma_dvi,b_so_id,'D','ph');
for r_lp in (select distinct so_id_tt from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_id and pt<>'N') loop
    if b_kieu_do<>'V' then
        PBH_TH_VAT(b_ma_dvi,b_so_id,r_lp.so_id_tt,b_loi);
        if b_loi is not null then return; end if;
    elsif b_kieu_phv='K' then
        PBH_TH_DO_PHI(b_ma_dvi,r_lp.so_id_tt,b_so_id,b_loi);
        if b_loi is not null then return; end if;
        PBH_HD_DO_TH_VAT(b_ma_dvi,r_lp.so_id_tt,b_loi);
        if b_loi is not null then return; end if;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_TH:loi'; end if;
end;
/
create or replace procedure PBH_HD_HU_THL(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; dt_ct clob;
    b_nsd varchar2(20); b_so_id_kt number; b_so_ct varchar2(20):=' ';
    b_so_hd varchar2(20); b_ngay_ht number; b_con number; b_nt_phi varchar2(5); 
    b_choP number; b_choT number; b_choP_qd number; b_choT_qd number;
    b_hoanP number; b_hoanT number; b_hoanP_qd number; b_hoanT_qd number; 
    b_nt_tra varchar2(5); b_pt_tra varchar2(1); b_tra number; b_tra_qd number; 
    b_hthue varchar2(1); b_ma_kh varchar2(20); b_ma_dl varchar2(20); b_phong varchar2(10); 
    b_kvat varchar2(1); b_so_don varchar2(20); b_ma_ldo nvarchar2(500);
    b_mau varchar2(20); b_seri varchar2(10);    
    a_ma_nt_no pht_type.a_var; a_tra pht_type.a_num;
    a_pt pht_type.a_var; a_ma_nt pht_type.a_var; a_tien pht_type.a_num;
    a_ma_nt_xl pht_type.a_var; a_ton pht_type.a_num; a_no pht_type.a_num;
    a_no_qd pht_type.a_num; a_tra_xl pht_type.a_num; a_tien_qd pht_type.a_num;
begin
-- Dan - Nhap huy hop dong da thanh toan phi
select count(*),min(nsd),min(so_id_kt) into b_i1,b_nsd,b_so_id_kt from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
if b_so_id_kt>0 then
    PBH_KT_TD_XOA(b_ma_dvi,b_so_id_kt,b_loi);
    if b_loi is not null then return; end if;
end if;
select txt into dt_ct from bh_hd_goc_hu_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
PKH_MANG_KD(a_ma_nt_no); PKH_MANG_KD(a_pt);
select ma_nt,tra BULK COLLECT into a_ma_nt_no,a_tra from bh_hd_goc_hups where ma_dvi=b_ma_dvi and so_id=b_so_id;
select pt,ma_nt,tien BULK COLLECT into a_pt,a_ma_nt,a_tien from bh_hd_goc_hutt where ma_dvi=b_ma_dvi and so_id=b_so_id;
PBH_HD_HU_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
if b_loi is not null then return; end if;
PBH_HD_HU_TEST(b_ma_dvi,b_nsd,b_so_id,dt_ct,
    b_ngay_ht,b_con,b_nt_phi,
    b_choP,b_choT,b_choP_qd,b_choT_qd,b_hoanP,b_hoanT,b_hoanP_qd,b_hoanT_qd,
    b_nt_tra,b_pt_tra,b_tra,b_tra_qd,b_hthue,b_ma_kh,b_ma_dl,b_phong,b_kvat,b_so_don,b_ma_ldo,
    a_ma_nt_no,a_tra,a_ma_nt_xl,a_ton,a_no,a_no_qd,a_tra_xl,a_pt,a_ma_nt,a_tien,a_tien_qd,b_loi);
if b_loi is not null then return; end if;
b_so_hd:=FKH_JS_GTRIs(dt_ct,'so_hd');
PBH_HD_HU_NH_NH(b_ma_dvi,b_nsd,b_so_id,b_so_hd,b_ngay_ht,b_so_ct,b_ma_kh,b_ma_dl,b_con,b_nt_phi,
    b_choP,b_choT,b_choP_qd,b_choT_qd,b_hoanP,b_hoanT,b_hoanP_qd,b_hoanT_qd,b_nt_tra,b_pt_tra,b_tra,b_tra_qd,
    b_hthue,b_phong,b_kvat,b_mau,b_seri,b_so_don,b_ma_ldo,
    a_ma_nt_no,a_ton,a_no,a_no_qd,a_tra_xl,a_pt,a_ma_nt,a_tien,a_tien_qd,dt_ct,b_loi);
if b_loi is not null then return; end if;
PBH_HD_HU_PT(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_HU_THL:loi'; end if;
end;
/
create or replace PROCEDURE PBH_TH_TTPT_ID(
    b_ma_dvi varchar2,b_so_id number,b_so_id_tt number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_ngcap number; b_so_id_c number; b_dau number;
    b_kieu_do varchar2(1); b_kieu_hhv varchar2(1); b_kieu_phv varchar2(1);
    b_le number; b_tg number; b_bt number; b_dvi_xl varchar2(10);
    b_tl_uu number;  b_tl_ku number; b_ngay_bs number; b_tien number; b_tien_qd number;
    b_hhong number; b_htro number; b_hhong_tl number; b_htro_tl number; b_dvu_tl number; b_hhong_qd number; b_htro_qd number;
    b_thue_m number; b_thue_i number; b_thue_c number; b_thue_nt varchar2(5);
    b_phi_qd number; b_thue_qd number; b_ttoan_qd number; b_phi_dt_qd number;
    b_phi_nh number; b_thue_nh number; b_ttoan_nh number; b_phi_dt_nh number;
    b_k_tl_hh varchar2(1); b_k_tl_ht varchar2(1); b_pt_tra varchar2(1);
    a_ngay pht_type.a_num; a_tien pht_type.a_num; a_tien_uu pht_type.a_num; a_tien_ku pht_type.a_num;
    tt_ma_nt pht_type.a_var; tt_pt pht_type.a_var; tt_tien pht_type.a_num;
    tt_tien_qd pht_type.a_num; tt_thue_qd pht_type.a_num; tt_loai pht_type.a_var;
    dk_lh_nv pht_type.a_var; dk_ma_dt pht_type.a_var; dk_phi pht_type.a_num; dk_t_suat pht_type.a_num;
    dk_thue pht_type.a_num; dk_ttoan pht_type.a_num; dk_phi_dt pht_type.a_num;
    dk_phi_qd pht_type.a_num; dk_thue_qd pht_type.a_num; dk_ttoan_qd pht_type.a_num;
    dk_phi_dt_qd pht_type.a_num; dk_uu pht_type.a_var;
    xl_ngay pht_type.a_num; xl_lh_nv pht_type.a_var; xl_ma_dt pht_type.a_var; xl_phi pht_type.a_num;
    xl_t_suat pht_type.a_num; xl_thue pht_type.a_num; xl_ttoan pht_type.a_num;
    xl_phi_dt pht_type.a_num; xl_uu pht_type.a_var;
    xl_phi_qd pht_type.a_num; xl_thue_qd pht_type.a_num; xl_ttoan_qd pht_type.a_num; xl_phi_dt_qd pht_type.a_num;
    b_kieu_kt varchar2(1); b_ma_kt varchar2(20); b_tl_mg number; b_k_phi varchar2(1); b_dvu number; b_dvu_qd number;
    b_nv varchar2(10); b_sp varchar2(10):='*'; b_nsd varchar2(20); b_hhong_tlV number; b_ma_ktG varchar2(20);
begin
-- Dan - Phan tich thanh toan
delete bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and so_id=b_so_id;
select count(*) into b_i1 from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
if b_i1=0 then b_loi:=''; return; end if;
select ngay_ht,pt_tra into b_ngay_bs,b_pt_tra from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
select nv,kieu_kt,ma_kt,hhong,nsd,ngay_cap into b_nv,b_kieu_kt,b_ma_kt,b_tl_mg,b_nsd,b_ngcap
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_kieu_do:=FBH_DONG(b_ma_dvi,b_so_id);
b_kieu_phv:=FBH_HD_DO_NH_TXT(b_ma_dvi,b_so_id,'D','ph');
b_kieu_hhv:=FBH_HD_DO_NH_TXT(b_ma_dvi,b_so_id,'D','dl');
b_hhong_tlV:=FBH_HD_DO_NH_TXTn(b_ma_dvi,b_so_id,'D','pt_dl');
PKH_MANG_KD(dk_lh_nv); PKH_MANG_KD_N(a_ngay); PKH_MANG_KD_N(a_tien);
select pt,ma_nt,tien,tien_qd,thue_qd BULK COLLECT into tt_pt,tt_ma_nt,tt_tien,tt_tien_qd,tt_thue_qd from
    (select pt,ma_nt,sum(tien) tien,sum(tien_qd) tien_qd,sum(thue_qd) thue_qd from bh_hd_goc_tthd
    where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and so_id=b_so_id group by pt,ma_nt order by pt);
for b_lp in 1..tt_tien.count loop
    b_dau:=sign(tt_tien(b_lp));
    if b_lp=1 then
        select nvl(max(bt),0) into b_bt from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
        b_k_tl_hh:=FBH_HT_THUE_TS(b_ma_dvi,b_ngay_bs,'tl_hh');
        b_k_tl_ht:=FBH_HT_THUE_TS(b_ma_dvi,b_ngay_bs,'tl_ht');
        if b_k_tl_hh is null then b_k_tl_hh:='C'; end if;
        if b_k_tl_ht is null then b_k_tl_ht:='C'; end if;
    end if;
    if tt_ma_nt(b_lp)='VND' then b_le:=0; b_tg:=1; else b_le:=2; b_tg:=tt_tien_qd(b_lp)/tt_tien(b_lp); end if;
    PKH_MANG_XOA(xl_lh_nv);
    PBH_TH_PHI_TON_CT(b_ma_dvi,b_so_id,tt_pt(b_lp),tt_ma_nt(b_lp),b_ngay_bs,xl_ngay,xl_ma_dt,xl_lh_nv,
        xl_t_suat,xl_phi,xl_thue,xl_ttoan,xl_phi_qd,xl_thue_qd,xl_ttoan_qd,xl_uu,b_loi);
    if b_loi is not null then return; end if;
    if xl_lh_nv.count=0 then
        PBH_PHI_CL(b_ma_dvi,b_so_id,tt_ma_nt(b_lp),b_ngay_bs,xl_ngay,xl_ma_dt,xl_lh_nv,
            xl_t_suat,xl_phi,xl_thue,xl_ttoan,xl_uu,b_loi);
        if b_loi is not null then return; end if;
        for b_lp1 in 1..xl_lh_nv.count loop
            if tt_ma_nt(b_lp)='VND' then
                xl_phi_qd(b_lp1):=xl_phi(b_lp1); xl_thue_qd(b_lp1):=xl_thue(b_lp1);
                xl_ttoan_qd(b_lp1):=xl_ttoan(b_lp1); xl_phi_dt_qd(b_lp1):=xl_phi_dt(b_lp1);
            else
                xl_ttoan_qd(b_lp1):=round(xl_ttoan(b_lp1)*b_tg,0); xl_thue_qd(b_lp1):=round(xl_thue(b_lp1)*b_tg,0);
                xl_phi_dt_qd(b_lp1):=xl_ttoan_qd(b_lp1)-xl_thue_qd(b_lp1);
                if xl_phi(b_lp1)=xl_ttoan(b_lp1) then
                    xl_phi_qd(b_lp1):=xl_ttoan(b_lp1);
                else
                    xl_phi_qd(b_lp1):=xl_phi_dt_qd(b_lp1);
                end if;
            end if;
        end loop;
    end if;
    b_i1:=0;
    for b_lp1 in 1..xl_lh_nv.count loop
        if b_i1=0 or xl_ngay(b_lp1)<>a_ngay(b_i1) then
            b_i1:=b_i1+1; a_ngay(b_i1):=xl_ngay(b_lp1);
            a_tien(b_i1):=0; a_tien_uu(b_i1):=0; a_tien_ku(b_i1):=0;
        end if;
        a_tien(b_i1):=a_tien(b_i1)+xl_ttoan(b_lp1);
        if xl_uu(b_lp1)='C' then
            a_tien_uu(b_i1):=a_tien_uu(b_i1)+xl_ttoan(b_lp1);
        else
            a_tien_ku(b_i1):=a_tien_ku(b_i1)+xl_ttoan(b_lp1);
        end if;
    end loop;
    for b_lp2 in 1..a_ngay.count loop
        b_i1:=0; PKH_MANG_XOA(dk_lh_nv);
        for b_lp1 in 1..xl_lh_nv.count loop
            if xl_ngay(b_lp1)=a_ngay(b_lp2) then
                b_i1:=b_i1+1;
                dk_lh_nv(b_i1):=xl_lh_nv(b_lp1); dk_ma_dt(b_i1):=xl_ma_dt(b_lp1);
                dk_t_suat(b_i1):=xl_t_suat(b_lp1); dk_phi(b_i1):=xl_phi(b_lp1);
                dk_thue(b_i1):=xl_thue(b_lp1); dk_ttoan(b_i1):=xl_ttoan(b_lp1);
                dk_ttoan_qd(b_i1):=xl_ttoan_qd(b_lp1); dk_thue_qd(b_i1):=xl_thue_qd(b_lp1);
                dk_phi_dt(b_i1):=dk_ttoan(b_i1)-dk_thue(b_i1);
                dk_phi_dt_qd(b_i1):=dk_ttoan_qd(b_i1)-dk_thue_qd(b_i1);
                if (dk_phi(b_i1)=dk_ttoan(b_i1)) then
                    dk_phi_qd(b_i1):=dk_ttoan_qd(b_i1);
                else
                    dk_phi_qd(b_i1):=dk_phi_dt_qd(b_i1);
                end if;
                dk_uu(b_i1):=xl_uu(b_lp1);
            end if;
        end loop;
        if b_lp2=a_ngay.count or a_tien(b_lp2)>tt_tien(b_lp) then
            b_tien:=tt_tien(b_lp); b_tien_qd:=tt_tien_qd(b_lp); b_thue_qd:=tt_thue_qd(b_lp);
        else
            b_tien:=a_tien(b_lp2); b_i2:=b_tien/tt_tien(b_lp);
            b_tien_qd:=round(tt_tien_qd(b_lp)*b_i2,0); b_thue_qd:=round(tt_thue_qd(b_lp)*b_i2,0);
        end if;
        if sign(a_tien(b_lp2))=sign(tt_tien(b_lp)) and abs(a_tien(b_lp2))>abs(tt_tien(b_lp)) then
            if a_tien_uu(b_lp2)=0 then
                b_tl_uu:=0; b_tl_ku:=b_tien/a_tien(b_lp2);
            elsif a_tien_ku(b_lp2)=0 then
                b_tl_uu:=b_tien/a_tien(b_lp2); b_tl_ku:=0;
            elsif b_tien=a_tien_uu(b_lp2) then
                b_tl_uu:=1; b_tl_ku:=0;
            elsif sign(b_tien)=sign(a_tien_uu(b_lp2)) and abs(b_tien)<abs(a_tien_uu(b_lp2)) then
                b_tl_uu:=b_tien/a_tien_uu(b_lp2); b_tl_ku:=0;
            else
                b_tl_uu:=1; b_tl_ku:=(b_tien-a_tien_uu(b_lp2))/a_tien_ku(b_lp2);
            end if;
        else
            b_tl_uu:=1; b_tl_ku:=1;
        end if;
        tt_tien(b_lp):=tt_tien(b_lp)-b_tien;
        tt_tien_qd(b_lp):=tt_tien_qd(b_lp)-b_tien_qd;
        tt_thue_qd(b_lp):=tt_thue_qd(b_lp)-b_thue_qd;
        b_thue_m:=0; b_thue_i:=0; b_thue_c:=b_thue_qd;
        for b_lp1 in 1..dk_lh_nv.count loop
            if b_lp1=dk_lh_nv.count then
                b_i1:=b_tien/dk_ttoan(b_lp1);
            elsif dk_uu(b_lp1)='C' then
                b_i1:=b_tl_uu;
            else
                b_i1:=b_tl_ku;
            end if;
            if b_lp1<>dk_lh_nv.count then
                b_ttoan_nh:=round(dk_ttoan(b_lp1)*b_i1,b_le);
            else 
               b_ttoan_nh:=b_tien;
            end if;
            if tt_ma_nt(b_lp)<>'VND' or b_lp1<>dk_lh_nv.count then
                b_thue_nh:=round(dk_thue(b_lp1)*b_i1,b_le);
            else 
                b_thue_nh:=b_thue_c;
            end if;
            if sign(b_ttoan_nh)<>sign(b_dau) then b_ttoan_nh:=-b_ttoan_nh; end if;
            if sign(b_thue_nh)<>sign(b_dau) then b_thue_nh:=-b_thue_nh; end if;
            if tt_ma_nt(b_lp)='VND' then
                b_ttoan_qd:=b_ttoan_nh; b_thue_qd:=b_thue_nh;
            elsif tt_pt(b_lp)<>'N' and b_lp1<>dk_lh_nv.count then
                b_ttoan_qd:=round(b_ttoan_nh*b_tg,0); b_thue_qd:=round(b_thue_nh*b_tg,0);
            else
                b_ttoan_qd:=round(dk_ttoan_qd(b_lp1)*b_i1,0); b_thue_qd:=round(dk_thue_qd(b_lp1)*b_i1,0);
            end if;
            if dk_phi(b_lp1)=dk_ttoan(b_lp1) then b_phi_nh:=b_ttoan_nh; b_phi_qd:=b_ttoan_qd;
            else b_phi_nh:=b_ttoan_nh-b_thue_nh; b_phi_qd:=b_ttoan_qd-b_thue_qd;
            end if;
            b_phi_dt_nh:=b_ttoan_nh-b_thue_nh; b_phi_dt_qd:=b_ttoan_qd-b_thue_qd;
            if b_ttoan_nh<>0  then
                b_tien:=b_tien-b_ttoan_nh; b_tien_qd:=b_tien_qd-b_ttoan_qd;
                b_hhong:=0; b_htro:=0; b_dvu:=0; b_hhong_tl:=0; b_htro_tl:=0; b_dvu_tl:=0; b_hhong_qd:=0; b_htro_qd:=0; b_dvu_qd:=0;
                if b_kieu_kt<>'T' and trim(b_ma_kt) is not null and (b_kieu_do<>'V' or b_kieu_hhv<>'K') then
                    if b_kieu_kt='M' then
                        b_hhong_tl:=b_tl_mg;
                    elsif b_kieu_do<>'D' and b_kieu_hhv='C' then
                        b_hhong_tl:=b_hhong_tlV; b_htro_tl:=0; b_dvu_tl:=0;
                    else
                        FBH_DL_MA_KH_LHNV_HH(b_ma_kt,b_nv,b_ngcap,dk_lh_nv(b_lp1),b_hhong_tl,b_htro_tl,b_dvu_tl);
                    end if;
                    b_hhong:=round(b_phi_dt_nh*b_hhong_tl/100,b_le);
                    b_htro:=round(b_phi_dt_nh*b_htro_tl/100,b_le);
                    b_dvu:=round(b_phi_dt_nh*b_dvu_tl/100,b_le);
                    if b_le=0 then
                        b_hhong_qd:=b_hhong; b_htro_qd:=b_htro; b_dvu_qd:=b_dvu;
                    else
                        b_hhong_qd:=round(b_phi_dt_qd*b_hhong_tl/100,0);
                        b_htro_qd:=round(b_phi_dt_qd*b_htro_tl/100,0);
                        b_dvu_qd:=round(b_phi_dt_qd*b_dvu_tl/100,0);
                    end if;
                end if;
                b_bt:=b_bt+1;
                if tt_pt(b_lp)<>'N' then
                    if abs(b_thue_qd)>abs(b_thue_m) then b_thue_i:=b_bt; b_thue_m:=b_thue_qd; b_thue_nt:=tt_ma_nt(b_lp); end if;
                end if;
                b_thue_c:=b_thue_c-b_thue_qd;
                insert into bh_hd_goc_ttpt values(b_ma_dvi,b_so_id_tt,b_bt,b_so_id,b_nv,b_ngay_bs,b_ngay_bs,a_ngay(b_lp2),
                    tt_pt(b_lp),dk_ma_dt(b_lp1),tt_ma_nt(b_lp),dk_lh_nv(b_lp1),dk_t_suat(b_lp1),
                    b_phi_nh,b_thue_nh,b_ttoan_nh,b_hhong,b_htro,b_dvu,b_phi_qd,b_thue_qd,b_ttoan_qd,
                    b_hhong_qd,b_htro_qd,b_dvu_qd,b_hhong_tl,b_htro_tl,b_dvu_tl);
            end if;
        end loop;
        if b_thue_c<>0 and b_thue_i<>0 then
            select thue_qd into b_i1 from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
            if b_thue_nt<>'VND' then
                if b_i1=0 then
                    update bh_hd_goc_ttpt set thue_qd=thue_qd+b_thue_c where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and bt=b_thue_i;
                else
                    select nvl(sum(thue),0) into b_i2 from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and ma_nt='VND';
                    b_i1:=b_i1-b_i2;
                    select nvl(sum(thue),0),max(bt) into b_i2,b_thue_i from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi
                        and so_id_tt=b_so_id_tt and ma_nt<>'VND' and thue<>0;
                    if b_i2<>0 then
                        b_i2:=b_i1/b_i2;
                        update bh_hd_goc_ttpt set thue_qd=round(thue*b_i2,-2) where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and ma_nt<>'VND';
                        select nvl(sum(thue_qd),0) into b_i2 from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and ma_nt<>'VND';
                        if b_i1<>b_i2 then
                            update bh_hd_goc_ttpt set thue_qd=thue_qd+b_i1-b_i2 where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and bt=b_thue_i;
                        end if;
                    end if;
                end if;
                update bh_hd_goc_ttpt set phi_qd=ttoan_qd-thue_qd where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
            else
                if b_i1<>0 then
                    update bh_hd_goc_ttpt set thue_qd=thue_qd+b_thue_c
                        where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and bt=b_thue_i;
                    update bh_hd_goc_ttpt set phi=ttoan-thue,phi_qd=ttoan_qd-thue_qd where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and bt=b_thue_i;
                else
                    select nvl(max(bt),0),max(thue_qd) into b_i1,b_i2 from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and so_id=b_so_id;
                    update bh_hd_goc_tthd set thue_qd=thue_qd-b_thue_c where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and bt=b_i1;
                end if;
            end if;
        end if;
        if tt_tien(b_lp)=0 then exit; end if;
    end loop;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_TTPT_ID:loi'; end if;
end;
/
create or replace PROCEDURE PBH_TH_TTPTDT_ID(
    b_ma_dvi varchar2,b_so_id number,b_so_id_tt number,b_loi out varchar2,b_dk varchar2:='C')
AS
    b_i1 number; b_tp number:=0; b_hs number; b_bt number;
    b_nv varchar2(5); b_so_idD number; b_so_idB number; b_nt_phi varchar2(5);
    b_phi number; b_thue number; b_hhong number; b_htro number; b_dvu number; 
    b_phi_qd number; b_thue_qd number; b_hhong_qd number; b_htro_qd number; b_dvu_qd number;
    b_phiX number; b_thueX number; b_hhongX number; b_htroX number; b_dvuX number; 
    b_phi_qdX number; b_thue_qdX number; b_hhong_qdX number; b_htro_qdX number; b_dvu_qdX number;
    b_phiC number; b_thueC number; b_hhongC number; b_htroC number; b_dvuC number; 
    b_phi_qdC number; b_thue_qdC number; b_hhong_qdC number; b_htro_qdC number; b_dvu_qdC number;
    a_so_id_dt pht_type.a_num; a_ma_dt pht_type.a_var; a_phi pht_type.a_num; a_idD pht_type.a_num;
begin
-- Dan - Phan tich thanh toan cho doi tuong
if b_dk='C' then
    delete bh_hd_goc_ttptdt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and so_id=b_so_id;
end if;
select count(*) into b_i1 from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select nv,so_id_d,nt_phi into b_nv,b_so_idD,b_nt_phi from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nv not in('PHH','PKT','2B','XE','TAU','NG') then
    insert into bh_hd_goc_ttptdt select
        ma_dvi,so_id_tt,bt,so_id,0,b_nv,ngay_ht,ngay_tt,ngay,pt,ma_dt,ma_nt,
        lh_nv,t_suat,phi,thue,ttoan,hhong,htro,dvu,phi_qd,thue_qd,
        ttoan_qd,hhong_qd,htro_qd,dvu_qd,hhong_tl,htro_tl,dvu_tl
        from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and so_id=b_so_id;
    b_loi:=''; return;
else
    select count(*) into b_i1 from bh_hd_goc_dkdt where
        ma_dvi=b_ma_dvi and so_id=b_so_idD and so_id_dt<>b_so_idD;
    if b_i1=0 then
        insert into bh_hd_goc_ttptdt select
            ma_dvi,so_id_tt,bt,so_id,b_so_idD,b_nv,ngay_ht,ngay_tt,ngay,pt,ma_dt,ma_nt,
            lh_nv,t_suat,phi,thue,ttoan,hhong,htro,dvu,phi_qd,thue_qd,
            ttoan_qd,hhong_qd,htro_qd,dvu_qd,hhong_tl,htro_tl,dvu_tl
            from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and so_id=b_so_id;
        b_loi:=''; return;
    end if;
end if;
if b_nt_phi<>'VND' then b_tp:=2; end if;
b_so_idB:=FBH_HD_SO_ID_BSd(b_ma_dvi,b_so_id); b_bt:=0;
for r_lp in(select * from bh_hd_goc_ttpt where
    ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and so_id=b_so_idD and phi<>0) loop
    select so_id_dt,ma_dt,phi bulk collect into a_so_id_dt,a_ma_dt,a_phi from bh_hd_goc_ptdt
        where ma_dvi=b_ma_dvi and so_id_xl=b_so_idB and ngay=r_lp.ngay and lh_nv=r_lp.lh_nv;
    PKH_MANG_DUYn(a_so_id_dt,a_idD);
    if a_idD.count=1 then
        b_bt:=b_bt+1;
        insert into bh_hd_goc_ttptdt values(
            b_ma_dvi,b_so_id_tt,b_bt,r_lp.so_id,a_idD(1),b_nv,r_lp.ngay_ht,r_lp.ngay_tt,
            r_lp.ngay,r_lp.pt,a_ma_dt(1),r_lp.ma_nt,r_lp.lh_nv,r_lp.t_suat,
            r_lp.phi,r_lp.thue,r_lp.ttoan,r_lp.hhong,r_lp.htro,r_lp.dvu,r_lp.phi_qd,r_lp.thue_qd,
            r_lp.ttoan_qd,r_lp.hhong_qd,r_lp.htro_qd,r_lp.dvu_qd,r_lp.hhong_tl,r_lp.htro_tl,r_lp.dvu_tl);
        continue;
    end if;
    b_phi:=r_lp.phi; b_thue:=r_lp.thue; b_hhong:=r_lp.hhong; b_htro:=r_lp.htro; b_dvu:=r_lp.dvu;
    b_phi_qd:=r_lp.phi_qd; b_thue_qd:=r_lp.thue_qd; b_hhong_qd:=r_lp.hhong_qd;
    b_htro_qd:=r_lp.htro_qd; b_dvu_qd:=r_lp.dvu_qd;
    b_i1:=FKH_ARR_TONG(a_phi); b_hs:=round(abs(b_i1/b_phi),5);
    for b_lp in 1..a_so_id_dt.count loop
        if b_lp=a_so_id_dt.count then
            b_hhongX:=b_hhongC; b_htroX:=b_htroC;
            b_dvuX:=b_dvuC; b_phi_qdX:=b_phi_qdC;
            b_thue_qdX:=b_thue_qdC; b_hhong_qdX:=b_hhong_qdC;
            b_htro_qdX:=b_htro_qdC; b_dvu_qdX:=b_dvu_qdC;
        else
            b_phiX:=round(b_phi*b_hs,b_tp); b_thueX:=round(b_thue*b_hs,b_tp);
            b_hhongX:=round(b_hhong*b_hs,b_tp); b_htroX:=round(b_htro*b_hs,b_tp);
            b_dvuX:=round(b_dvu*b_hs,b_tp); b_phi_qd:=round(b_phi_qd*b_hs,0);
            b_thue_qdX:=round(b_thue_qd*b_hs,0); b_hhong_qdX:=round(b_hhong_qd*b_hs,0);
            b_htro_qdX:=round(b_htro_qd*b_hs,0); b_dvu_qdX:=round(b_dvu_qd*b_hs,0);
            b_phiC:=b_phi-b_phiX; b_thueC:=b_thue-b_thueX;
            b_hhongC:=b_hhong-b_hhongX; b_htroC:=b_htro-b_htroX;
            b_dvuC:=b_dvu-b_dvuX; b_phi_qdC:=b_phi_qd-b_phi_qdX;
            b_thue_qdC:=b_thue_qd-b_thue_qdX; b_hhong_qdC:=b_hhong_qd-b_hhong_qdX;
            b_htro_qdC:=b_htro_qd-b_htro_qdX; b_dvu_qdC:=b_dvu_qd-b_dvu_qdX;
        end if;
        b_bt:=b_bt+1;
        insert into bh_hd_goc_ttptdt values(
            b_ma_dvi,b_so_id_tt,b_bt,r_lp.so_id,a_so_id_dt(b_lp),b_nv,r_lp.ngay_ht,r_lp.ngay_tt,
            r_lp.ngay,r_lp.pt,a_ma_dt(b_lp),r_lp.ma_nt,r_lp.lh_nv,r_lp.t_suat,
            b_phiX,b_thueX,b_phiX+b_thueX,b_hhongX,b_htroX,b_dvuX,b_phi_qdX,b_thue_qdX,
            b_phi_qdX+b_thue_qdX,b_hhong_qdX,b_htro_qdX,b_dvu_qdX,r_lp.hhong_tl,r_lp.htro_tl,r_lp.dvu_tl);
    end loop;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_TTPTDT_ID:loi'; end if;
end;
/
create or replace PROCEDURE PBH_TH_TTPT_IDb(b_ma_dvi varchar2,b_so_id_bs number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_ngcap number; b_so_id number; b_so_id_tt number; b_so_id_c number;
    b_kieu_do varchar2(1); b_kieu_hhv varchar2(1); b_kieu_phv varchar2(1); b_dau number;
    b_le number; b_tg number; b_bt number; b_dvi_xl varchar2(10); b_nv varchar2(10);
    b_tl_uu number;  b_tl_ku number; b_ngay_bs number; b_tien number; b_tien_qd number;
    b_hhong number; b_htro number; b_hhong_tl number; b_htro_tl number;
    b_dvu number; b_dvu_qd number; b_dvu_tl number; b_hhong_qd number; b_htro_qd number;
    b_thue_m number; b_thue_i number; b_thue_c number; b_thue_nt varchar2(5);
    b_phi_qd number; b_thue_qd number; b_ttoan_qd number; b_phi_dt_qd number;
    b_phi_nh number; b_thue_nh number; b_ttoan_nh number; b_phi_dt_nh number;
    b_k_tl_hh varchar2(1); b_k_tl_ht varchar2(1); b_pt_tra varchar2(1);
    b_kieu_kt varchar2(1); b_ma_kt varchar2(20); b_tl_mg number; b_k_phi varchar2(1);
    
    tt_ngay pht_type.a_num; tt_so_id pht_type.a_num; a_ngay pht_type.a_num;
    a_tien pht_type.a_num; a_tien_uu pht_type.a_num; a_tien_ku pht_type.a_num;
    tt_ma_nt pht_type.a_var; tt_pt pht_type.a_var; tt_tien pht_type.a_num;
    tt_tien_qd pht_type.a_num; tt_thue_qd pht_type.a_num; tt_loai pht_type.a_var;
    dk_ma_dt pht_type.a_var; dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num;
    dk_phi pht_type.a_num; dk_thue pht_type.a_num; dk_ttoan pht_type.a_num;
    dk_phi_qd pht_type.a_num; dk_thue_qd pht_type.a_num; dk_ttoan_qd pht_type.a_num; dk_uu pht_type.a_var;
    xl_ngay pht_type.a_num; xl_ma_dt pht_type.a_var; xl_lh_nv pht_type.a_var; xl_t_suat pht_type.a_num;
    xl_phi pht_type.a_num; xl_thue pht_type.a_num; xl_ttoan pht_type.a_num; xl_uu pht_type.a_var;
    xl_phi_qd pht_type.a_num; xl_thue_qd pht_type.a_num; xl_ttoan_qd pht_type.a_num;
begin
-- Dan - Phan tich thanh toan cho bo sung hop dong
delete bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_bs;
select min(nv),nvl(min(so_id_d),0),min(ngay_ht),min(kieu_kt),min(ma_kt),min(hhong) into
    b_nv,b_so_id,b_ngay_bs,b_kieu_kt,b_ma_kt,b_tl_mg
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id_bs;
if b_so_id=0 then b_loi:=''; return; end if;
select ngay_ht,so_id_tt,pt,ma_nt,sum(tien) tien,sum(tien_qd) tien_qd,sum(thue_qd) thue_qd
    BULK COLLECT into tt_ngay,tt_so_id,tt_pt,tt_ma_nt,tt_tien,tt_tien_qd,tt_thue_qd
    from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_id
    group by ngay_ht,so_id_tt,pt,ma_nt order by ngay_ht,so_id_tt,pt,ma_nt;
if tt_ngay.count=0 then return; end if;
b_kieu_do:=FBH_DONG(b_ma_dvi,b_so_id);
b_kieu_hhv:=FBH_HD_DO_NH_TXT(b_ma_dvi,b_so_id,'D','dl');
b_kieu_phv:=FBH_HD_DO_NH_TXT(b_ma_dvi,b_so_id,'D','ph');
insert into bh_hd_goc_ttpt select
    b_ma_dvi,b_so_id_bs,rownum+1000000,b_so_id,b_nv,b_ngay_bs,ngay_tt,ngay,pt,ma_dt,ma_nt,lh_nv,t_suat,
    -phi,-thue,-ttoan,-hhong,-htro,-dvu,-phi_qd,-thue_qd,-ttoan_qd,-hhong_qd,-htro_qd,-dvu_qd,0,0,0 from 
    (select ngay_tt,ngay,pt,ma_dt,ma_nt,lh_nv,t_suat,
    sum(phi) phi,sum(thue) thue,sum(ttoan) ttoan,sum(hhong) hhong,sum(htro) htro,sum(dvu) dvu,
    sum(phi_qd) phi_qd,sum(thue_qd) thue_qd,sum(ttoan_qd) ttoan_qd,
    sum(hhong_qd) hhong_qd,sum(htro_qd) htro_qd,sum(dvu_qd) dvu_qd
    from bh_hd_goc_ttptdt where ma_dvi=b_ma_dvi and so_id=b_so_id
    group by ngay_tt,ngay,pt,ma_dt,ma_nt,lh_nv,t_suat);
PKH_MANG_KD(xl_lh_nv); PKH_MANG_KD(dk_lh_nv); PKH_MANG_KD_N(a_ngay); PKH_MANG_KD_N(a_tien);
b_so_id_tt:=0; b_bt:=0;
for b_lp in 1..tt_so_id.count loop
    b_dau:=sign(tt_tien(b_lp));
    if b_so_id_tt<>tt_so_id(b_lp) then
        b_so_id_tt:=tt_so_id(b_lp);
        b_k_tl_hh:=FBH_HT_THUE_TS(b_ma_dvi,tt_ngay(b_lp),'tl_hh');
        b_k_tl_ht:=FBH_HT_THUE_TS(b_ma_dvi,tt_ngay(b_lp),'tl_ht');
        if b_k_tl_hh is null then b_k_tl_hh:='C'; end if;
        if b_k_tl_ht is null then b_k_tl_ht:='C'; end if;
    end if;
    if tt_ma_nt(b_lp)='VND' then b_le:=0; b_tg:=1; else b_le:=2; b_tg:=tt_tien_qd(b_lp)/tt_tien(b_lp); end if;
    PKH_MANG_XOA(xl_lh_nv);
    PBH_TH_PHI_TON_CT(b_ma_dvi,b_so_id,tt_pt(b_lp),tt_ma_nt(b_lp),b_ngay_bs,xl_ngay,xl_ma_dt,xl_lh_nv,xl_t_suat,
        xl_phi,xl_thue,xl_ttoan,xl_phi_qd,xl_thue_qd,xl_ttoan_qd,xl_uu,b_loi);
    if b_loi is not null then return; end if;
    if xl_lh_nv.count=0 then
        PBH_PHI_CL(b_ma_dvi,b_so_id,tt_ma_nt(b_lp),b_ngay_bs,xl_ngay,xl_ma_dt,
            xl_lh_nv,xl_t_suat,xl_phi,xl_thue,xl_ttoan,xl_uu,b_loi);
        if b_loi is not null then return; end if;
        for b_lp1 in 1..xl_lh_nv.count loop
            if tt_ma_nt(b_lp)='VND' then
                xl_phi_qd(b_lp1):=xl_phi(b_lp1); xl_thue_qd(b_lp1):=xl_thue(b_lp1); xl_ttoan_qd(b_lp1):=xl_ttoan(b_lp1);
            else
                xl_ttoan_qd(b_lp1):=round(xl_ttoan(b_lp1)*b_tg,0); xl_thue_qd(b_lp1):=round(xl_thue(b_lp1)*b_tg,0);
                xl_phi_qd(b_lp1):=xl_ttoan_qd(b_lp1)-xl_thue_qd(b_lp1);
            end if;
        end loop;
    end if;
    b_i1:=0;
    for b_lp1 in 1..xl_lh_nv.count loop
        if b_i1=0 or xl_ngay(b_lp1)<>a_ngay(b_i1) then
            b_i1:=b_i1+1; a_ngay(b_i1):=xl_ngay(b_lp1);
            a_tien(b_i1):=0; a_tien_uu(b_i1):=0; a_tien_ku(b_i1):=0;
        end if;
        a_tien(b_i1):=a_tien(b_i1)+xl_ttoan(b_lp1);
        if xl_uu(b_lp1)='C' then
            a_tien_uu(b_i1):=a_tien_uu(b_i1)+xl_ttoan(b_lp1);
        else
            a_tien_ku(b_i1):=a_tien_ku(b_i1)+xl_ttoan(b_lp1);
        end if;
    end loop;
    for b_lp2 in 1..a_ngay.count loop
        b_i1:=0; PKH_MANG_XOA(dk_lh_nv);
        for b_lp1 in 1..xl_lh_nv.count loop
            if xl_ngay(b_lp1)=a_ngay(b_lp2) then
                b_i1:=b_i1+1;
                dk_ma_dt(b_i1):=xl_ma_dt(b_lp1); dk_lh_nv(b_i1):=xl_lh_nv(b_lp1); dk_t_suat(b_i1):=xl_t_suat(b_lp1);
                dk_thue(b_i1):=xl_thue(b_lp1); dk_ttoan(b_i1):=xl_ttoan(b_lp1);
                dk_ttoan_qd(b_i1):=xl_ttoan_qd(b_lp1); dk_thue_qd(b_i1):=xl_thue_qd(b_lp1);
                dk_phi(b_i1):=dk_ttoan(b_i1)-dk_thue(b_i1); dk_phi_qd(b_i1):=dk_ttoan_qd(b_i1)-dk_thue_qd(b_i1);
                dk_uu(b_i1):=xl_uu(b_lp1);
            end if;
        end loop;
        if b_lp2=a_ngay.count or a_tien(b_lp2)>tt_tien(b_lp) then
            b_tien:=tt_tien(b_lp); b_tien_qd:=tt_tien_qd(b_lp); b_thue_qd:=tt_thue_qd(b_lp);
        else
            b_tien:=a_tien(b_lp2); b_i2:=b_tien/tt_tien(b_lp);
            b_tien_qd:=round(tt_tien_qd(b_lp)*b_i2,0); b_thue_qd:=round(tt_thue_qd(b_lp)*b_i2,0);
        end if;
        if sign(a_tien(b_lp2))=sign(tt_tien(b_lp)) and abs(a_tien(b_lp2))>abs(tt_tien(b_lp)) then
            if a_tien_uu(b_lp2)=0 then
                b_tl_uu:=0; b_tl_ku:=b_tien/a_tien(b_lp2);
            elsif a_tien_ku(b_lp2)=0 then
                b_tl_uu:=b_tien/a_tien(b_lp2); b_tl_ku:=0;
            elsif b_tien=a_tien_uu(b_lp2) then
                b_tl_uu:=1; b_tl_ku:=0;
            elsif sign(b_tien)=sign(a_tien_uu(b_lp2)) and  abs(b_tien)<abs(a_tien_uu(b_lp2)) then
                b_tl_uu:=b_tien/a_tien_uu(b_lp2); b_tl_ku:=0;
            else
                b_tl_uu:=1; b_tl_ku:=(b_tien-a_tien_uu(b_lp2))/a_tien_ku(b_lp2);
            end if;
            b_tl_uu:=1; b_tl_ku:=1;
        end if;
        tt_tien(b_lp):=tt_tien(b_lp)-b_tien;
        tt_tien_qd(b_lp):=tt_tien_qd(b_lp)-b_tien_qd;
        tt_thue_qd(b_lp):=tt_thue_qd(b_lp)-b_thue_qd;
        b_thue_m:=0; b_thue_i:=0; b_thue_c:=b_thue_qd;
        for b_lp1 in 1..dk_lh_nv.count loop
            if b_lp1=dk_lh_nv.count then
                b_i1:=b_tien/dk_ttoan(b_lp1);
            elsif dk_uu(b_lp1)='C' then
                b_i1:=b_tl_uu;
            else
                b_i1:=b_tl_ku;
            end if;
            if b_lp1<>dk_lh_nv.count then
                b_ttoan_nh:=round(dk_ttoan(b_lp1)*b_i1,b_le);
            else 
               b_ttoan_nh:=b_tien;
            end if;
            if tt_ma_nt(b_lp)<>'VND' or b_lp1<>dk_lh_nv.count then
                b_thue_nh:=round(dk_thue(b_lp1)*b_i1,b_le);
            else 
                b_thue_nh:=b_thue_c;
            end if;
            if sign(b_ttoan_nh)<>sign(b_dau) then b_ttoan_nh:=-b_ttoan_nh; end if;
            if sign(b_thue_nh)<>sign(b_dau) then b_thue_nh:=-b_thue_nh; end if;
            if tt_ma_nt(b_lp)='VND' then
                b_ttoan_qd:=b_ttoan_nh; b_thue_qd:=b_thue_nh;
            elsif tt_pt(b_lp)<>'N' and b_lp1<>dk_lh_nv.count then
                b_ttoan_qd:=round(b_ttoan_nh*b_tg,0); b_thue_qd:=round(b_thue_nh*b_tg,0);
            else
                b_ttoan_qd:=round(dk_ttoan_qd(b_lp1)*b_i1,0); b_thue_qd:=round(dk_thue_qd(b_lp1)*b_i1,0);
            end if;
            b_phi_nh:=b_ttoan_nh-b_thue_nh; b_phi_qd:=b_ttoan_qd-b_thue_qd;
            if b_ttoan_nh<>0  then
                b_tien:=b_tien-b_ttoan_nh; b_tien_qd:=b_tien_qd-b_ttoan_qd;
                b_hhong:=0; b_htro:=0; b_dvu:=0; b_hhong_tl:=0; b_htro_tl:=0; b_dvu_tl:=0; b_hhong_qd:=0; b_htro_qd:=0; b_dvu_qd:=0;
                if b_kieu_kt<>'T' and trim(b_ma_kt) is not null and (b_kieu_do<>'V' or b_kieu_hhv<>'K') then
                    if b_kieu_kt<>'M' then
                        b_hhong_tl:=b_tl_mg;
                    else
                        FBH_DL_MA_KH_LHNV_HH(b_ma_kt,b_nv,b_ngcap,dk_lh_nv(b_lp1),b_hhong_tl,b_htro_tl,b_dvu_tl);
                    end if;
                    if b_kieu_do='D' and b_kieu_hhv='C' then
                        b_i2:=FBH_HD_DO_NH_TXTn(b_ma_dvi,b_so_id,'D','pt_dl');
                        if b_i2>0 and b_i2<100 then
                            b_i2:=100-b_i2;
                            b_hhong_tl:=round(b_hhong_tl*b_i2/100,3);
                            b_htro_tl:=round(b_htro_tl*b_i2/100,3);
                            b_dvu_tl:=round(b_dvu_tl*b_i2/100,3);
                        end if;
                    end if;
                    b_hhong:=round(b_phi_dt_nh*b_hhong_tl/100,b_le);
                    b_htro:=round(b_phi_dt_nh*b_htro_tl/100,b_le);
                    b_dvu:=round(b_phi_dt_nh*b_dvu_tl/100,b_le);
                    if b_le=0 then
                        b_hhong_qd:=b_hhong; b_htro_qd:=b_htro; b_dvu_qd:=b_dvu;
                    else
                        b_hhong_qd:=round(b_phi_dt_qd*b_hhong_tl/100,0);
                        b_htro_qd:=round(b_phi_dt_qd*b_htro_tl/100,0);
                        b_dvu_qd:=round(b_phi_dt_qd*b_dvu_tl/100,0);
                    end if;
                end if;
                b_bt:=b_bt+1;
                if tt_pt(b_lp)<>'N' then
                    b_thue_c:=b_thue_c-b_thue_qd;
                    if abs(b_thue_qd)>abs(b_thue_m) then b_thue_i:=b_bt; b_thue_m:=b_thue_qd; b_thue_nt:=tt_ma_nt(b_lp); end if;
                end if;
                insert into bh_hd_goc_ttpt values(b_ma_dvi,b_so_id_bs,b_bt,b_so_id,b_nv,b_ngay_bs,tt_ngay(b_lp),a_ngay(b_lp2),
                    tt_pt(b_lp),dk_ma_dt(b_lp1),tt_ma_nt(b_lp),dk_lh_nv(b_lp1),dk_t_suat(b_lp1),
                    b_phi_nh,b_thue_nh,b_ttoan_nh,b_hhong,b_htro,b_dvu,
                    b_phi_qd,b_thue_qd,b_ttoan_qd,b_hhong_qd,b_htro_qd,b_dvu_qd,b_hhong_tl,b_htro_tl,b_dvu_tl);
            end if;
        end loop;
        if b_thue_c<>0 and b_thue_i<>0 then
            select thue_qd into b_i1 from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=tt_so_id(b_lp);
            if b_thue_nt<>'VND' then
                if b_i1=0 then
                    update bh_hd_goc_ttpt set thue_qd=thue_qd+b_thue_c where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_bs and bt=b_thue_i;
                else
                    select nvl(sum(thue),0) into b_i2 from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_bs and ma_nt='VND';
                    b_i1:=b_i1-b_i2;
                    select nvl(sum(thue),0),max(bt) into b_i2,b_thue_i from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi
                        and so_id_tt=b_so_id_bs and ma_nt<>'VND' and thue<>0;
                    if b_i2<>0 then
                        b_i2:=b_i1/b_i2;
                        update bh_hd_goc_ttpt set thue_qd=round(thue*b_i2,-2) where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_bs and ma_nt<>'VND';
                        select nvl(sum(thue_qd),0) into b_i2 from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_bs and ma_nt<>'VND';
                        if b_i1<>b_i2 then
                            update bh_hd_goc_ttpt set thue_qd=thue_qd+b_i1-b_i2 where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_bs and bt=b_thue_i;
                        end if;
                    end if;
                end if;
                update bh_hd_goc_ttpt set phi_qd=ttoan_qd-thue_qd where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_bs;
            else
                if b_i1<>0 then
                    update bh_hd_goc_ttpt set thue=thue+b_thue_c,thue_qd=thue_qd+b_thue_c
                        where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_bs and bt=b_thue_i;
                    update bh_hd_goc_ttpt set phi=ttoan-thue,phi_qd=ttoan_qd-thue_qd
                        where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_bs and bt=b_thue_i;
                end if;
            end if;
        end if;
        if tt_tien(b_lp)=0 then exit; end if;
    end loop;
end loop;
select count(*) into b_i1 from (select lh_nv,sum(phi),sum(thue) from bh_hd_goc_ttpt
    where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_bs group by lh_nv having sum(phi)<>0 or sum(thue)<>0);
if b_i1=0 then
    delete bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_bs;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_TTPT_IDb:loi'; end if;
end;
/
create or replace PROCEDURE PBH_TH_TTPTDT_IDb(
    b_ma_dvi varchar2,b_so_idB number,b_loi out varchar2)
AS
    b_i1 number; b_so_id number; b_ngayB number; b_nv varchar2(10);
begin
-- Dan - Phan tich thanh toan cho doi tuong bo sung hop dong
delete bh_hd_goc_ttptdt where ma_dvi=b_ma_dvi and so_id_tt=b_so_idB;
select count(*) into b_i1 from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_idB;
if b_i1=0 then b_loi:=''; return; end if;
select so_id_d,ngay_ht,nv into b_so_id,b_ngayB,b_nv from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_idB;
insert into bh_hd_goc_ttptdt select
    b_ma_dvi,b_so_idB,rownum+1000000,b_so_id,so_id_dt,b_nv,b_ngayB,ngay_tt,ngay,pt,ma_dt,ma_nt,lh_nv,t_suat,
    -phi,-thue,-ttoan,-hhong,-htro,-dvu,-phi_qd,-thue_qd,-ttoan_qd,-hhong_qd,-htro_qd,-dvu_qd,0,0,0 from 
    (select so_id_dt,ngay_tt,ngay,pt,ma_dt,ma_nt,lh_nv,t_suat,
    sum(phi) phi,sum(thue) thue,sum(ttoan) ttoan,sum(hhong) hhong,sum(htro) htro,sum(dvu) dvu,
    sum(phi_qd) phi_qd,sum(thue_qd) thue_qd,sum(ttoan_qd) ttoan_qd,
    sum(hhong_qd) hhong_qd,sum(htro_qd) htro_qd,sum(dvu_qd) dvu_qd
    from bh_hd_goc_ttptdt where ma_dvi=b_ma_dvi and so_id=b_so_id
    group by so_id_dt,ngay_tt,ngay,pt,ma_dt,ma_nt,lh_nv,t_suat);
PBH_TH_TTPTDT_ID(b_ma_dvi,b_so_id,b_so_idB,b_loi,'K');
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_TTPTDT_IDb:loi'; end if;
end;
/
create or replace procedure PBH_TH_TH_ID(
    b_ma_dvi varchar2,b_dk varchar2,b_so_id number,b_so_id_tt number,b_loi out varchar2)
AS
    b_i1 number; b_so_idD number;
    b_kieu_do varchar2(1); b_kieu_phv varchar2(1); b_kieu_hd varchar2(1);
    pbo_ma_dvi  pht_type.a_var; pbo_so_id_tt pht_type.a_num; pbo_phi_dt pht_type.a_num;
begin
-- Dan - Phan tich thuc hien thanh toan cho 1 ID thanh toan
b_loi:='';
select nvl(min(so_id_d),0),min(kieu_hd) into b_so_idD,b_kieu_hd
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_so_idD=0 then return; end if;
delete bh_hd_goc_sc_hh where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_tt=b_so_id_tt;
delete bh_hd_goc_sc_vat where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_tt=b_so_id_tt;
delete bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_tt=b_so_id_tt;
delete bh_hd_goc_ttptdt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_tt=b_so_id_tt;
if b_kieu_hd in('U','K') then return; end if;
b_kieu_do:=FBH_DONG(b_ma_dvi,b_so_id); b_kieu_phv:=FBH_HD_DO_NH_TXT(b_ma_dvi,b_so_id,'D','ph');
if b_dk='T' then
    PBH_TH_TTPT_ID(b_ma_dvi,b_so_id,b_so_id_tt,b_loi);
    if b_loi is not null then return; end if;
    PBH_TH_TTPTDT_ID(b_ma_dvi,b_so_id,b_so_id_tt,b_loi);
    if b_loi is not null then return; end if;
    if b_kieu_do<>'D' and b_kieu_phv='K' then
        PBH_HD_DO_TH_VAT(b_ma_dvi,b_so_id_tt,b_loi);
    else
        PBH_TH_VAT(b_ma_dvi,b_so_id,b_so_id_tt,b_loi);
    end if;
    if b_loi is not null then return; end if;
    PBH_TH_HH(b_ma_dvi,b_so_id,b_so_id_tt,b_loi);
    if b_loi is not null then return; end if;
    PBH_TH_DO_PHI(b_ma_dvi,b_so_id_tt,b_so_id,b_loi);
    if b_loi is not null then return; end if;
    PTBH_TH_TMN_PHI(b_ma_dvi,b_so_id_tt,b_so_id,b_loi);
    if b_loi is not null then return; end if;
elsif FBH_HD_HOI_NOPHI(b_ma_dvi,b_so_id)='K' then
    PBH_TH_TTPT_IDb(b_ma_dvi,b_so_id_tt,b_loi);
    if b_loi is not null then return; end if;
    PBH_TH_TTPTDT_IDb(b_ma_dvi,b_so_id_tt,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_TH_ID:loi'; end if;
end;
/
create or replace procedure PBH_THL_PHI_NBH(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
As
    b_so_idD number;
begin
-- Dan - Tong hop lai phi nha lead, nhan tai tam thoi
b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
if b_so_idD=0 or FBH_HD_TTRANG(b_ma_dvi,b_so_idD)<>'D' then b_loi:=''; return; end if;
delete bh_hd_goc_phi_nbh where ma_dvi=b_ma_dvi and so_id=b_so_idD;
for r_lp in (select nha_bh,ngay_ht,ma_nt,ttoan
    from bh_hd_goc_cl where ma_dvi=b_ma_dvi and so_id=b_so_idD and nha_bh<>' ' order by nha_bh,ma_nt,ngay_ht) loop
    PBH_TH_PHI_NBH(b_ma_dvi,'N',b_so_idD,r_lp.nha_bh,r_lp.ma_nt,r_lp.ttoan,r_lp.ngay_ht,b_loi);
    if b_loi is not null then return; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_THL_PHI_NBH:loi'; end if;
end;
/
create or replace procedure PBH_HD_GOC_THL_CT(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2,b_so_id_ps number:=0)
AS
    b_i1 number; b_i2 number; b_kieu_hd varchar2(1); b_nv varchar2(10);
    b_nha_bh varchar2(20); b_ttrang varchar2(1);
    a_ngay pht_type.a_num; a_so_id pht_type.a_num;
begin
-- Dan - Tong hop lai 1 hop dong
delete bh_hd_goc_phi_nbh where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_goc_cl where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_goc_cldt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_goc_sc_phi where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_goc_sc_phi_ton where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_goc_sc_no_ton where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_goc_sc_no where ma_dvi=b_ma_dvi and so_id=b_so_id;
select kieu_hd,ttrang into b_kieu_hd,b_ttrang from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_kieu_hd='U' or b_ttrang<>'D' then b_loi:=''; return; end if;
select distinct ngay_ht,so_id_xl bulk collect into a_ngay,a_so_id from bh_hd_goc_pt
    where ma_dvi=b_ma_dvi and so_id=b_so_id order by ngay_ht,so_id_xl;
for b_lp in 1..a_so_id.count loop
    PBH_TH_PHI_CL(b_ma_dvi,a_so_id(b_lp),b_loi);
    if b_loi is not null then return; end if;
    PBH_TH_PHI_CLDT(b_ma_dvi,a_so_id(b_lp),b_loi);
    if b_loi is not null then return; end if;
end loop;
if b_kieu_hd='K' then b_loi:=''; return; end if;
PBH_THL_PHI_NBH(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
for r_lp in (select ngay_ht,ma_nt,sum(ttoan) tien from bh_hd_goc_cl where
    ma_dvi=b_ma_dvi and so_id=b_so_id group by ngay_ht,ma_nt order by ngay_ht,ma_nt) loop
    PBH_TH_PHI(b_ma_dvi,'N',b_so_id,r_lp.ma_nt,r_lp.ngay_ht,r_lp.tien,b_loi);
    if b_loi is not null then return; end if;
end loop;
for r_lp in (select ngay_ht,pt,ma_nt,tien,tien_qd from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    if r_lp.pt<>'N' then
        PBH_TH_PHI(b_ma_dvi,'C',b_so_id,r_lp.ma_nt,r_lp.ngay_ht,r_lp.tien,b_loi);
        if b_loi is not null then return; end if;
    end if;
    if r_lp.pt='C' then
        PBH_TH_NO_THOP(b_ma_dvi,'N',b_so_id,r_lp.ma_nt,r_lp.ngay_ht,r_lp.tien,r_lp.tien_qd,b_loi);
        if b_loi is not null then return; end if;
    elsif r_lp.pt='N' then
        PBH_TH_NO_THOP(b_ma_dvi,'C',b_so_id,r_lp.ma_nt,r_lp.ngay_ht,r_lp.tien,r_lp.tien_qd,b_loi);
        if b_loi is not null then return; end if;
    end if;
    b_nha_bh:=FBH_HD_TT_TXT(b_ma_dvi,b_so_id,'nha_bh');
    if b_nha_bh<>' ' then
        PBH_TH_PHI_NBH(b_ma_dvi,'C',b_so_id,b_nha_bh,r_lp.ma_nt,r_lp.tien,r_lp.ngay_ht,b_loi);
        if b_loi is not null then return; end if;
    end if;
end loop;
if b_so_id_ps in(0,b_so_id) then
    PBH_TH_TH(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
    PBH_HD_HU_THL(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
    for r_lp in (select so_id from bh_bt_hs where ma_dvi=b_ma_dvi and so_id_hd=b_so_id) loop
        PBH_BT_HS_PBO(b_ma_dvi,r_lp.so_id,b_loi);
        if b_loi is not null then return; end if;
    end loop;
else
    PBH_TH_TH_ID(b_ma_dvi,'B',b_so_id,b_so_id_ps,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_GOC_THL_CT:loi'; end if;
end;
/
create or replace PROCEDURE PBH_TH_DO(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2,b_dk varchar2:='C')
AS
begin
-- Dan
PBH_TH_DOps(b_ma_dvi,b_so_id,b_loi,b_dk);
if b_loi is not null then return; end if;
PTBH_TH_TMN(b_ma_dvi,b_so_id,b_loi,b_dk);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_DO:loi'; end if;
end;
/
create or replace PROCEDURE PBH_TH_DO_XOA_PS(b_ma_dvi varchar2,b_so_id_ps number,b_loi out varchar2)
AS
begin
-- Dan
delete bh_hd_do_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
delete bh_hd_do_sc_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
delete tbh_tmN_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
delete tbh_tmN_sc_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_DO:loi'; end if;
end;
/
create or replace PROCEDURE PBH_TH_DOps(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2,b_dk varchar2:='C')
AS
begin
-- Dan - Tong hop phat sinh dong bao hiem
delete bh_hd_do_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_do_sc_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
-- Phi
for r_lp in(select so_id_tt from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    PBH_TH_DO_PHI(b_ma_dvi,r_lp.so_id_tt,b_so_id,b_loi);
    if b_loi is not null then return; end if;
end loop;
PBH_TH_DO_HU(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
if FBH_DONG(b_ma_dvi,b_so_id)<>'D' then b_loi:=''; return; end if;
for r_lp in(select distinct so_id_hh from bh_hd_goc_hh_ct where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    PBH_TH_DO_HH(b_ma_dvi,r_lp.so_id_hh,b_so_id,b_loi);
    if b_loi is not null then return; end if;
end loop;
for r_lp in(select distinct b.so_id_tr from bh_tpa_hd a,bh_tpa_tra b where
    a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and b.ma_dvi=b_ma_dvi and b.so_id_tr=a.so_id_tr) loop
    PBH_TH_DO_TPA(b_ma_dvi,r_lp.so_id_tr,b_so_id,b_loi);
    if b_loi is not null then return; end if;
end loop;
-- BTH
for r_lp in(select distinct ma_dvi,so_id from bh_bt_tu where
    ma_dvi_ql=b_ma_dvi and so_id_hd=b_so_id) loop
    PBH_TH_DO_BTHu(r_lp.ma_dvi,r_lp.so_id,b_loi);
    if b_loi is not null then return; end if;
end loop;
for r_lp in(select distinct ma_dvi,so_id from bh_bt_hs where
    ma_dvi_ql=b_ma_dvi and so_id_hd=b_so_id and ttrang='D') loop
    PBH_TH_DO_BTH(r_lp.ma_dvi,r_lp.so_id,b_loi);
    if b_loi is not null then return; end if;
end loop;
for r_lp in(select distinct b.ma_dvi,b.so_id from bh_bt_gd_hs a,bh_bt_gd_hs_tu b where
    a.ma_dvi_hd=b_ma_dvi and a.so_id_hd=b_so_id and b.ma_dvi=a.ma_dvi and b.so_id=a.so_id) loop
    PBH_TH_DO_GDu(r_lp.ma_dvi,r_lp.so_id,b_loi);
    if b_loi is not null then return; end if;
end loop;
for r_lp in(select distinct ma_dvi,so_id from bh_bt_gd_hs where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id) loop
    PBH_TH_DO_GD(r_lp.ma_dvi,r_lp.so_id,b_loi);
    if b_loi is not null then return; end if;
end loop;
for r_lp in(select distinct ma_dvi,so_id from bh_bt_tba where ma_dvi_ql=b_ma_dvi and so_id_hd=b_so_id) loop
    PBH_TH_DO_TBA(r_lp.ma_dvi,r_lp.so_id,b_loi);
    if b_loi is not null then return; end if;
end loop;
for r_lp in(select distinct ma_dvi,so_id from bh_bt_thoi where ma_dvi_ql=b_ma_dvi and so_id_hd=b_so_id) loop
    PBH_TH_DO_THOI(r_lp.ma_dvi,r_lp.so_id,b_loi);
    if b_loi is not null then return; end if;
end loop;
-- CP
for r_lp in(select distinct so_id from bh_cp where ma_dvi=b_ma_dvi and so_id_hd=b_so_id) loop
    PBH_TH_DO_CP(b_ma_dvi,r_lp.so_id,b_loi);
    if b_loi is not null then return; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_DOps:loi'; end if;
end;
/
create or replace PROCEDURE PBH_TH_DOth(
    b_ma_dvi varchar2,b_so_id number,
    a_so_id_ps pht_type.a_num,a_so_ct pht_type.a_var,a_ngay pht_type.a_num,a_nhom pht_type.a_var,
    a_loai pht_type.a_var,a_nv pht_type.a_var,a_so_id_dt pht_type.a_num,a_lh_nv pht_type.a_var,
    a_ma_nt pht_type.a_var,a_tien pht_type.a_num,a_thue pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_tpP number:=0; b_bt number:=0;
    b_kieu_do varchar2(1); b_kieu_ph varchar2(1); b_kieu_vat varchar2(1);
    b_loai varchar2(20); b_nvT varchar2(1); b_ma_dt varchar2(10);
    b_hhong number; b_pt_dl number:=0; b_hh_dl number; 
    b_tien number; b_thue number; b_tien_qd number; b_thue_qd number; 
    do_so_id_dtT pht_type.a_num; do_lh_nvT pht_type.a_var; do_ptT pht_type.a_num;
    do_so_id_dt pht_type.a_num; do_lh_nv pht_type.a_var; do_nbh pht_type.a_var;
    do_pt pht_type.a_num; do_hh pht_type.a_num; do_ptG pht_type.a_num;
begin
-- Dan - Tong hop phat sinh dong bao hiem
delete bh_hd_do_ps_temp;
select distinct so_id_dt,lh_nv,nha_bh,pt,hh BULK COLLECT into do_so_id_dt,do_lh_nv,do_nbh,do_pt,do_hh
    from bh_hd_do_tl where ma_dvi=b_ma_dvi and so_id=b_so_id and pthuc='C';
if do_so_id_dt.count=0 then b_loi:=''; return; end if;
if a_ma_nt(1)<>'VND' then b_tpP:=2; end if;
b_kieu_do:=FBH_DONG(b_ma_dvi,b_so_id);
b_kieu_ph:=FBH_HD_DO_NH_TXT(b_ma_dvi,b_so_id,'D','ph');
b_kieu_vat:=FBH_HD_DO_NH_TXT(b_ma_dvi,b_so_id,'D','vat');
if b_kieu_do='D' then
    if b_kieu_ph='C' then
        select distinct so_id_dt,lh_nv,sum(pt) BULK COLLECT into do_so_id_dtT,do_lh_nvT,do_ptT
            from bh_hd_do_tl where ma_dvi=b_ma_dvi and so_id=b_so_id and pthuc='C' group by so_id_dt,lh_nv;
        for b_lp in 1..do_lh_nv.count loop
            do_ptG(b_lp):=100;
            for b_lp1 in 1..do_lh_nvT.count loop
                if do_so_id_dtT(b_lp1)=do_so_id_dt(b_lp) and do_lh_nvT(b_lp1)=do_lh_nv(b_lp) then
                    do_ptG(b_lp):=100-do_ptT(b_lp1); exit;
                end if;
            end loop;
        end loop;
    end if;
elsif FBH_HD_DO_NH_TXT(b_ma_dvi,b_so_id,'D','dl')='K' then
    b_pt_dl:=FBH_HD_DO_NH_TXTn(b_ma_dvi,b_so_id,'D','pt_dl')/100;
end if;
for b_lp in 1..a_lh_nv.count loop
    for b_lp1 in 1..do_lh_nv.count loop
        if do_so_id_dt(b_lp1) not in(0,a_so_id_dt(b_lp)) or do_lh_nv(b_lp1) not in(' ',a_lh_nv(b_lp)) then continue; end if;
        if b_kieu_do='V' then
            b_tien:=a_tien(b_lp); b_thue:=a_thue(b_lp);
        else
            b_tien:=round(a_tien(b_lp)*do_pt(b_lp1)/100,b_tpP);
            if b_kieu_vat<>'C' then b_thue:=0;
            else b_thue:=round(a_thue(b_lp)*do_pt(b_lp1)/100,b_tpP);
            end if;
        end if;
        if a_loai(b_lp) in('CH_PHF_BHd','DT_PHL_BH') then
            if b_kieu_ph='C' then
                b_tien:=round(a_tien(b_lp)*do_pt(b_lp1)/do_ptG(b_lp1),b_tpP);
            elsif a_loai(b_lp)<>'DT_PHL_BH' then
                insert into bh_hd_do_ps_temp values(a_so_id_ps(b_lp),a_so_ct(b_lp),a_so_id_dt(b_lp),a_ngay(b_lp),
                    a_nhom(b_lp),a_loai(b_lp),a_nv(b_lp),do_nbh(b_lp1),a_ma_nt(b_lp),a_lh_nv(b_lp),b_tien,b_thue);
            end if;
            b_hhong:=round(b_tien*do_hh(b_lp1)/100,b_tpP);
            if b_hhong<>0 then
                if b_kieu_do='D' then
                    b_loai:='DT_FLPd'; b_nvT:='T';
                else
                    b_loai:='CH_LEPd'; b_nvT:='C';
                end if;
                b_thue:=round(b_hhong*.1,b_tpP);
                insert into bh_hd_do_ps_temp values(a_so_id_ps(b_lp),a_so_ct(b_lp),a_so_id_dt(b_lp),a_ngay(b_lp),
                    a_nhom(b_lp),b_loai,b_nvT,do_nbh(b_lp1),a_ma_nt(b_lp),a_lh_nv(b_lp),b_hhong,b_thue);
            end if;
            if a_loai(b_lp)='DT_PHL_BH' and b_pt_dl<>0 then
                b_hh_dl:=round(b_pt_dl*b_tien,b_tpP);
                insert into bh_hd_do_ps_temp values(a_so_id_ps(b_lp),a_so_ct(b_lp),a_so_id_dt(b_lp),a_ngay(b_lp),
                    'D','CH_HH_DLd','C',do_nbh(b_lp1),a_ma_nt(b_lp),a_lh_nv(b_lp),b_hh_dl,0);
            end if;
        elsif b_kieu_do='D' then
            insert into bh_hd_do_ps_temp values(a_so_id_ps(b_lp),a_so_ct(b_lp),a_so_id_dt(b_lp),a_ngay(b_lp),
                a_nhom(b_lp),a_loai(b_lp),a_nv(b_lp),do_nbh(b_lp1),a_ma_nt(b_lp),a_lh_nv(b_lp),b_tien,b_thue);
        end if;
    end loop;
end loop;
for r_lp in (select so_id_ps,so_ct,so_id_dt,ngay_ht,nhom,loai,nv,nha_bh,ma_nt,lh_nv,sum(tien) tien,sum(thue) thue
    from bh_hd_do_ps_temp group by so_id_ps,so_ct,so_id_dt,ngay_ht,nhom,loai,nv,nha_bh,ma_nt,lh_nv) loop
    b_bt:=b_bt+1;
    if r_lp.ma_nt='VND' then
        b_tien_qd:=r_lp.tien; b_thue_qd:=r_lp.thue;
    else
        b_i1:=FBH_TT_TRA_TGTT(r_lp.ngay_ht,r_lp.ma_nt);
        b_tien_qd:=round(r_lp.tien*b_i1,0); b_thue_qd:=round(r_lp.thue*b_i1,0);
    end if;
    b_ma_dt:=FBH_HD_MA_DT(b_ma_dvi,b_so_id,r_lp.so_id_dt,r_lp.ngay_ht);
    insert into bh_hd_do_ps values(b_ma_dvi,r_lp.so_id_ps,b_bt,r_lp.so_ct,r_lp.ngay_ht,b_so_id,r_lp.so_id_dt,
        r_lp.nhom,r_lp.loai,r_lp.nv,'C',r_lp.nha_bh,r_lp.ma_nt,r_lp.lh_nv,b_ma_dt,
        r_lp.tien,r_lp.thue,b_tien_qd,b_thue_qd);
end loop;
for r_lp in (select distinct so_id_ps from bh_hd_do_ps where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    PBH_HD_DO_TH_PS(b_ma_dvi,b_so_id,r_lp.so_id_ps,b_loi);
    if b_loi is not null then return; end if;
end loop;
delete bh_hd_do_ps_temp;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_DOth:loi'; end if;
end;
/
create or replace PROCEDURE PBH_TH_DO_PHI(
    b_ma_dvi varchar2,b_so_id_tt number,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_bt number:=0; b_kieu_do varchar2(1); b_so_ct varchar2(20); b_ngay_ht number;
    a_so_id_ps pht_type.a_num; a_so_ct pht_type.a_var; a_ngay pht_type.a_num; a_nhom pht_type.a_var; 
    a_loai pht_type.a_var; a_nv pht_type.a_var; a_so_id_dt pht_type.a_num; a_lh_nv pht_type.a_var;
    a_ma_nt pht_type.a_var; a_tien pht_type.a_num; a_thue pht_type.a_num;
begin
-- Dan - Tong hop phi
delete bh_hd_do_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_tt;
delete bh_hd_do_sc_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_tt;
select min(so_ct),nvl(min(ngay_ht),0) into b_so_ct,b_ngay_ht from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
if b_ngay_ht=0 then b_loi:=''; return; end if;
b_kieu_do:=FBH_DONG(b_ma_dvi,b_so_id);
for r_lp in(select so_id_dt,ma_nt,lh_nv,sum(phi) tien,sum(thue) thue from bh_hd_goc_ttptdt 
    where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and so_id=b_so_id and pt<>'N' and lh_nv<>' '
    group by so_id_dt,ma_nt,lh_nv) loop
    b_bt:=b_bt+1;
    if b_kieu_do='D' then
        a_loai(b_bt):='CH_PHF_BHd';
        a_tien(b_bt):=r_lp.tien; a_thue(b_bt):=r_lp.thue; a_nv(b_bt):='C';
    else
        a_loai(b_bt):='DT_PHL_BH';
        a_tien(b_bt):=r_lp.tien; a_thue(b_bt):=r_lp.thue; a_nv(b_bt):='T';
    end if;
    a_nhom(b_bt):='D'; a_so_id_ps(b_bt):=b_so_id_tt; a_so_id_dt(b_bt):=r_lp.so_id_dt;
    a_ngay(b_bt):=b_ngay_ht; a_ma_nt(b_bt):=r_lp.ma_nt; a_lh_nv(b_bt):=r_lp.lh_nv;
    a_so_ct(b_bt):=b_so_ct;
end loop;
if b_bt=0 then b_loi:=''; return; end if;
PBH_TH_DOth(b_ma_dvi,b_so_id,a_so_id_ps,a_so_ct,a_ngay,a_nhom,a_loai,a_nv,a_so_id_dt,a_lh_nv,a_ma_nt,a_tien,a_thue,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_DO_PHI:loi'; end if;
end;
/
create or replace PROCEDURE PBH_TH_DO_HU(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_so_id_tt number:=b_so_id*10; b_i1 number; b_bt number:=0; 
    b_kieu_do varchar2(1); b_so_ct varchar2(20); b_ngay_ht number;
    a_so_id_ps pht_type.a_num; a_so_ct pht_type.a_var; a_ngay pht_type.a_num; a_nhom pht_type.a_var; 
    a_loai pht_type.a_var; a_nv pht_type.a_var; a_so_id_dt pht_type.a_num; a_lh_nv pht_type.a_var;
    a_ma_nt pht_type.a_var; a_tien pht_type.a_num; a_thue pht_type.a_num;
begin
-- Dan - Tong hop Huy
delete bh_hd_do_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_tt;
delete bh_hd_do_sc_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_tt;
select min(so_ct),nvl(min(ngay_ht),0) into b_so_ct,b_ngay_ht from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_ngay_ht=0 then b_loi:=''; return; end if;
b_kieu_do:=FBH_DONG(b_ma_dvi,b_so_id);
for r_lp in(select so_id_dt,ma_nt,lh_nv,sum(phi) tien,sum(thue) thue from bh_hd_goc_ttptdt where
    ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and lh_nv<>' ' group by so_id_dt,ma_nt,lh_nv) loop
    b_bt:=b_bt+1;
    a_so_id_ps(b_bt):=b_so_id_tt; a_ngay(b_bt):=b_ngay_ht;
    a_ma_nt(b_bt):=r_lp.ma_nt; a_nhom(b_bt):='D'; a_so_ct(b_bt):=b_so_ct;
    a_so_id_dt(b_bt):=r_lp.so_id_dt; a_lh_nv(b_bt):=r_lp.lh_nv;
    a_tien(b_bt):=r_lp.tien; a_thue(b_bt):=r_lp.thue;
    -- chuclh: tien (-) nv la C - thu tien nha dong 
    if b_kieu_do='D' then
        a_loai(b_bt):='CH_PHF_BHd'; a_nv(b_bt):='C';
    else
        a_loai(b_bt):='DT_PHL_BH'; a_nv(b_bt):='T';
    end if;
end loop;
if b_bt=0 then b_loi:=''; return; end if;
PBH_TH_DOth(b_ma_dvi,b_so_id,a_so_id_ps,a_so_ct,a_ngay,a_nhom,a_loai,a_nv,a_so_id_dt,a_lh_nv,a_ma_nt,a_tien,a_thue,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_DO_HU:loi'; end if;
end;
/
create or replace PROCEDURE PBH_TH_DO_HH(
    b_ma_dvi varchar2,b_so_id_hh number,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_bt number:=0; b_kieu_do varchar2(1); b_so_ct varchar2(20); b_ngay_ht number;
    a_so_id_ps pht_type.a_num; a_so_ct pht_type.a_var; a_ngay pht_type.a_num; a_nhom pht_type.a_var; 
    a_loai pht_type.a_var; a_nv pht_type.a_var; a_so_id_dt pht_type.a_num; a_lh_nv pht_type.a_var;
    a_ma_nt pht_type.a_var; a_tien pht_type.a_num; a_thue pht_type.a_num;
begin
-- Dan - Tong hop Hoa hong dai ly
delete bh_hd_do_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_hh;
delete bh_hd_do_sc_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_hh;
if FBH_DONG(b_ma_dvi,b_so_id)<>'D' or FBH_HD_DO_NH_TXT(b_ma_dvi,b_so_id,'D','dl')='C' then b_loi:=''; return; end if;
select ngay_ht,so_ct into b_ngay_ht,b_so_ct from bh_hd_goc_hh
    where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh;
for r_lp in(select so_id_dt,ma_nt,lh_nv,sum(hhong+htro+dvu) tien from bh_hd_goc_hh_ptdt where
    ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh and so_id=b_so_id group by so_id_dt,ma_nt,lh_nv) loop
    b_bt:=b_bt+1; a_so_id_ps(b_bt):=b_so_id_hh;
    a_ma_nt(b_bt):=r_lp.ma_nt; a_nhom(b_bt):='D'; a_loai(b_bt):='DT_HH_DLd';
    a_so_id_dt(b_bt):=r_lp.so_id_dt; a_lh_nv(b_bt):=r_lp.lh_nv;    
    a_tien(b_bt):=r_lp.tien; a_thue(b_bt):=0; a_nv(b_bt):='T';
    a_so_ct(b_bt):=b_so_ct; a_ngay(b_bt):=b_ngay_ht;
end loop;
if b_bt=0 then b_loi:=''; return; end if;
PBH_TH_DOth(b_ma_dvi,b_so_id,a_so_id_ps,a_so_ct,a_ngay,a_nhom,a_loai,a_nv,a_so_id_dt,a_lh_nv,a_ma_nt,a_tien,a_thue,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_DO_HH:loi'; end if;
end;
/
create or replace PROCEDURE PBH_TH_DO_TPA(
    b_ma_dvi varchar2,b_so_id_tr number,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_bt number:=0; b_so_ct varchar2(20); b_ngay_ht number;
    a_so_id_ps pht_type.a_num; a_so_ct pht_type.a_var; a_ngay pht_type.a_num; a_nhom pht_type.a_var; 
    a_loai pht_type.a_var; a_nv pht_type.a_var; a_so_id_dt pht_type.a_num; a_lh_nv pht_type.a_var;
    a_ma_nt pht_type.a_var; a_tien pht_type.a_num; a_thue pht_type.a_num;
begin
-- Dan - Tong hop TPA
delete bh_hd_do_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_tr;
delete bh_hd_do_sc_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_tr;
if FBH_DONG(b_ma_dvi,b_so_id)<>'D' then b_loi:=''; return; end if;
select ngay_ht,so_ct into b_ngay_ht,b_so_ct from bh_tpa_tra where ma_dvi=b_ma_dvi and so_id_tr=b_so_id_tr;
for r_lp in(select b.so_id_dt,b.nt_phi,b.lh_nv,sum(b.tpa_phi) tien,sum(b.tpa_thue) thue
    from bh_tpa_hd a,bh_tpa_hd_pt b where a.ma_dvi=b_ma_dvi and a.so_id_tr=b_so_id_tr and
    b.ma_dvi=b_ma_dvi and b.so_id_tt=a.so_id_tt and b.so_id=b_so_id group by b.so_id_dt,b.nt_phi,b.lh_nv) loop
    b_bt:=b_bt+1; a_so_id_ps(b_bt):=b_so_id_tr;
    a_ma_nt(b_bt):=r_lp.nt_phi; a_nhom(b_bt):='D'; a_loai(b_bt):='DT_DV_TPAd';
    a_so_id_dt(b_bt):=r_lp.so_id_dt; a_lh_nv(b_bt):=r_lp.lh_nv;    
    a_tien(b_bt):=r_lp.tien; a_thue(b_bt):=r_lp.thue; a_nv(b_bt):='T';
    a_so_ct(b_bt):=b_so_ct; a_ngay(b_bt):=b_ngay_ht;
end loop;
if b_bt=0 then b_loi:=''; return; end if;
PBH_TH_DOth(b_ma_dvi,b_so_id,a_so_id_ps,a_so_ct,a_ngay,a_nhom,a_loai,a_nv,a_so_id_dt,a_lh_nv,a_ma_nt,a_tien,a_thue,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_DO_TPA:loi'; end if;
end;
/
create or replace PROCEDURE PBH_TH_DO_CP(
    b_ma_dvi varchar2,b_so_id_cp number,b_loi out varchar2)
AS
    b_i1 number; b_bt number:=0; b_so_id number; r_hd bh_cp%rowtype;
    a_so_id_ps pht_type.a_num; a_so_ct pht_type.a_var; a_ngay pht_type.a_num; a_nhom pht_type.a_var; 
    a_loai pht_type.a_var; a_nv pht_type.a_var; a_so_id_dt pht_type.a_num; a_lh_nv pht_type.a_var;
    a_ma_nt pht_type.a_var; a_tien pht_type.a_num; a_thue pht_type.a_num;
begin
-- Dan - Tong hop thu, chi khac
delete bh_hd_do_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_cp;
delete bh_hd_do_sc_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_cp;
select * into r_hd from bh_cp where ma_dvi=b_ma_dvi and so_id=b_so_id_cp;
if r_hd.so_id_hd=0 or FBH_DONG(b_ma_dvi,r_hd.so_id_hd)<>'D' then b_loi:=''; return; end if;
b_so_id:=r_hd.so_id_hd;
for r_lp in(select so_id_dt,lh_nv,sum(tien) tien,sum(thue) thue from bh_cp_pt where
    ma_dvi=b_ma_dvi and so_id=b_so_id_cp and lh_nv<>' ' group by so_id_dt,lh_nv) loop
    b_bt:=b_bt+1;
    if r_hd.so_id_hs=0 then a_loai(b_bt):='KH_HD_CPd'; else a_loai(b_bt):='KH_BT_CPd'; end if;
    a_so_id_ps(b_bt):=b_so_id_cp; a_ngay(b_bt):=r_hd.ngay_ht;
    a_so_id_dt(b_bt):=r_lp.so_id_dt; a_lh_nv(b_bt):=r_lp.lh_nv; a_nhom(b_bt):='D';
    if r_hd.l_ct='T' then a_nv(b_bt):='C'; else a_nv(b_bt):='T'; end if;
    a_tien(b_bt):=r_lp.tien; a_thue(b_bt):=r_lp.thue;
    a_ma_nt(b_bt):=r_hd.ma_nt; a_so_ct(b_bt):=r_hd.so_ct;
end loop;
if b_bt=0 then b_loi:=''; return; end if;
PBH_TH_DOth(b_ma_dvi,b_so_id,a_so_id_ps,a_so_ct,a_ngay,a_nhom,a_loai,a_nv,a_so_id_dt,a_lh_nv,a_ma_nt,a_tien,a_thue,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_DO_KH:loi'; end if;
end;
/
create or replace PROCEDURE PBH_TH_DO_BTH(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_bt number:=0; b_con number; b_hs number; b_tp number:=0;
    a_so_id_ps pht_type.a_num; a_so_ct pht_type.a_var; a_ngay pht_type.a_num; a_nhom pht_type.a_var; 
    a_loai pht_type.a_var; a_nv pht_type.a_var; a_so_id_dt pht_type.a_num; a_lh_nv pht_type.a_var;
    a_ma_nt pht_type.a_var; a_tien pht_type.a_num; a_thue pht_type.a_num;
    r_hs bh_bt_hs%rowtype;
begin
-- Dan - Tong hop BTH
delete bh_hd_do_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id;
delete bh_hd_do_sc_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id;
select count(*) into b_i1 from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select * into r_hs from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
if r_hs.ttrang<>'D' or FBH_BT_TXT_NV(b_ma_dvi,b_so_id,'dbhtra',r_hs.nv)='C' then b_loi:=''; return; end if;
select nvl(sum(tien),0) into b_i1 from bh_bt_tu_pt where ma_dvi=b_ma_dvi and so_id_bt=b_so_id and lh_nv<>' ';
select nvl(sum(tien),0) into b_i2 from bh_bt_hs_nv where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ';
if b_i2 in(0,b_i1) then b_loi:=''; return; end if;
b_con:=b_i2-b_i1; b_hs:=b_con/b_i2;
if r_hs.nt_tien<>'VND' then b_tp:=2; end if;
for r_lp in(select lh_nv,sum(tien) tien,sum(thue) thue from bh_bt_hs_nv where
    ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv) loop
    b_bt:=b_bt+1;
    a_so_id_ps(b_bt):=b_so_id; a_ngay(b_bt):=r_hs.ngay_qd; a_so_ct(b_bt):=r_hs.so_hs; 
    a_so_id_dt(b_bt):=r_hs.so_id_dt; a_lh_nv(b_bt):=r_lp.lh_nv; a_nhom(b_bt):='D';
    a_loai(b_bt):='DT_BTF_BHd'; a_nv(b_bt):='T'; a_ma_nt(b_bt):=r_hs.nt_tien;
    a_tien(b_bt):=round(r_lp.tien*b_hs,b_tp); a_thue(b_bt):=round(r_lp.thue*b_hs,b_tp);
    b_con:=b_con-a_tien(b_bt);
end loop;
if b_bt=0 then b_loi:=''; return; end if;
a_tien(b_bt):=a_tien(b_bt)+b_con;
PBH_TH_DOth(r_hs.ma_dvi_ql,r_hs.so_id_hd,a_so_id_ps,a_so_ct,a_ngay,a_nhom,a_loai,a_nv,a_so_id_dt,a_lh_nv,a_ma_nt,a_tien,a_thue,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_DO_BTH:loi'; end if;
end;
/
create or replace PROCEDURE PBH_TH_DO_BTHu(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_bt number:=0; b_con number; b_hs number; b_tp number:=0;
    a_so_id_ps pht_type.a_num; a_so_ct pht_type.a_var; a_ngay pht_type.a_num; a_nhom pht_type.a_var; 
    a_loai pht_type.a_var; a_nv pht_type.a_var; a_so_id_dt pht_type.a_num; a_lh_nv pht_type.a_var;
    a_ma_nt pht_type.a_var; a_tien pht_type.a_num; a_thue pht_type.a_num;
    r_hs bh_bt_tu%rowtype;
begin
-- Dan - Tong hop chi tung phan BTH
delete bh_hd_do_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id;
delete bh_hd_do_sc_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id;
select * into r_hs from bh_bt_tu where ma_dvi=b_ma_dvi and so_id=b_so_id;
if r_hs.nbh<>' ' or FBH_BT_TXT_NV(b_ma_dvi,r_hs.so_id_hs,'dbhtra',r_hs.nv)='C' then b_loi:=''; return; end if;
for r_lp in(select so_id_dt,lh_nv,sum(tien) tien,sum(thue) thue from bh_bt_tu_pt where
    ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by so_id_dt,lh_nv) loop
    b_bt:=b_bt+1;
    a_so_id_ps(b_bt):=b_so_id; a_ngay(b_bt):=r_hs.ngay_ht; a_so_ct(b_bt):=r_hs.so_ct; 
    a_so_id_dt(b_bt):=r_lp.so_id_dt; a_lh_nv(b_bt):=r_lp.lh_nv; a_nhom(b_bt):='D';
    a_loai(b_bt):='DT_BTF_BHd'; a_nv(b_bt):='T'; a_ma_nt(b_bt):=r_hs.ma_nt;
    a_tien(b_bt):=r_lp.tien; a_thue(b_bt):=r_lp.thue;
end loop;
if b_bt=0 then b_loi:=''; return; end if;
PBH_TH_DOth(r_hs.ma_dvi_ql,r_hs.so_id_hd,a_so_id_ps,a_so_ct,a_ngay,a_nhom,a_loai,a_nv,a_so_id_dt,a_lh_nv,a_ma_nt,a_tien,a_thue,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_DO_BTHu:loi'; end if;
end;
/
create or replace PROCEDURE PBH_TH_DO_GDu(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_bt number:=0; b_con number; b_hs number; b_tp number:=0;
    a_so_id_ps pht_type.a_num; a_so_ct pht_type.a_var; a_ngay pht_type.a_num; a_nhom pht_type.a_var; 
    a_loai pht_type.a_var; a_nv pht_type.a_var; a_so_id_dt pht_type.a_num; a_lh_nv pht_type.a_var;
    a_ma_nt pht_type.a_var; a_tien pht_type.a_num; a_thue pht_type.a_num;
    r_hs bh_bt_gd_hs_tu%rowtype; r_hsG bh_bt_gd_hs%rowtype;
begin
-- Dan - Tong hop tam ung chi Gdinh
delete bh_hd_do_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id;
delete bh_hd_do_sc_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id;
select * into r_hs from bh_bt_gd_hs_tu where ma_dvi=b_ma_dvi and so_id=b_so_id;
select * into r_hsG from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=r_hs.so_id_hs;
for r_lp in(select so_id_dt,lh_nv,sum(tien) tien,sum(thue) thue from bh_bt_gd_hs_pt where
    ma_dvi_hd=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by so_id_dt,lh_nv) loop
    b_bt:=b_bt+1;
    a_so_id_ps(b_bt):=b_so_id; a_ngay(b_bt):=r_hs.ngay_ht;
    a_so_id_dt(b_bt):=r_lp.so_id_dt; a_lh_nv(b_bt):=r_lp.lh_nv; a_nhom(b_bt):='D';
    a_loai(b_bt):='DT_BTF_GDd'; a_nv(b_bt):='T'; a_ma_nt(b_bt):=r_hs.ma_nt;
    a_tien(b_bt):=r_lp.tien; a_thue(b_bt):=r_lp.thue; a_so_ct(b_bt):=r_hs.so_ct;
end loop;
if b_bt=0 then b_loi:=''; return; end if;
PBH_TH_DOth(r_hsG.ma_dvi_hd,r_hsG.so_id_hd,a_so_id_ps,a_so_ct,a_ngay,a_nhom,a_loai,a_nv,a_so_id_dt,a_lh_nv,a_ma_nt,a_tien,a_thue,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_DO_GDu:loi'; end if;
end;
/
create or replace PROCEDURE PBH_TH_DO_GD(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_bt number:=0; b_con number; b_hs number; b_tp number:=0;
    a_so_id_ps pht_type.a_num; a_so_ct pht_type.a_var; a_ngay pht_type.a_num; a_nhom pht_type.a_var; 
    a_loai pht_type.a_var; a_nv pht_type.a_var; a_so_id_dt pht_type.a_num; a_lh_nv pht_type.a_var;
    a_ma_nt pht_type.a_var; a_tien pht_type.a_num; a_thue pht_type.a_num;
    r_hs bh_bt_gd_hs%rowtype;
begin
-- Dan - Tong hop hoan thanh gdinh
delete bh_hd_do_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id;
delete bh_hd_do_sc_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id;
select * into r_hs from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
if r_hs.ttrang<>'D' then b_loi:=''; return; end if;
if FBH_DONG(r_hs.ma_dvi_hd,r_hs.so_id_hd)<>'D' then b_loi:=''; return; end if;
for r_lp in(select so_id_dt,lh_nv,sum(tien) tien,sum(thue) thue from bh_bt_gd_hs_pt where
    ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by so_id_dt,lh_nv) loop
    b_bt:=b_bt+1;
    a_so_id_ps(b_bt):=b_so_id; a_ngay(b_bt):=r_hs.ngay_ht; a_so_ct(b_bt):=r_hs.so_hs; 
    a_so_id_dt(b_bt):=r_lp.so_id_dt; a_lh_nv(b_bt):=r_lp.lh_nv; a_nhom(b_bt):='D';
    a_loai(b_bt):='DT_BTF_GDd'; a_nv(b_bt):='T'; a_ma_nt(b_bt):=r_hs.ma_nt;
    a_tien(b_bt):=r_lp.tien; a_thue(b_bt):=r_lp.thue;
end loop;
if b_bt=0 then b_loi:=''; return; end if;
PBH_TH_DOth(r_hs.ma_dvi_hd,r_hs.so_id_hd,a_so_id_ps,a_so_ct,a_ngay,a_nhom,a_loai,a_nv,a_so_id_dt,a_lh_nv,a_ma_nt,a_tien,a_thue,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_DO_GD:loi'; end if;
end;
/
create or replace PROCEDURE PBH_TH_DO_TBA(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_bt number:=0; b_con number; b_hs number; b_tp number:=0;
    a_so_id_ps pht_type.a_num; a_so_ct pht_type.a_var; a_ngay pht_type.a_num; a_nhom pht_type.a_var; 
    a_loai pht_type.a_var; a_nv pht_type.a_var; a_so_id_dt pht_type.a_num; a_lh_nv pht_type.a_var;
    a_ma_nt pht_type.a_var; a_tien pht_type.a_num; a_thue pht_type.a_num;
    r_hs bh_bt_tba%rowtype;
begin
-- Dan - Tong hop thu doi NTBA
delete bh_hd_do_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id;
delete bh_hd_do_sc_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id;
select * into r_hs from bh_bt_tba where ma_dvi=b_ma_dvi and so_id=b_so_id;
if FBH_DONG(r_hs.ma_dvi_ql,r_hs.so_id_hd)<>'D' then b_loi:=''; return; end if;
for r_lp in(select so_id_dt,ma_nt,lh_nv,sum(tien) tien from bh_bt_tba_pt where
    ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by so_id_dt,ma_nt,lh_nv) loop
    b_bt:=b_bt+1;
    a_so_id_ps(b_bt):=b_so_id; a_ngay(b_bt):=r_hs.ngay_ht;
    a_so_id_dt(b_bt):=r_lp.so_id_dt; a_lh_nv(b_bt):=r_lp.lh_nv;
    a_nhom(b_bt):='D'; a_loai(b_bt):='CH_BTF_TBd'; a_nv(b_bt):='C';
    a_ma_nt(b_bt):=r_lp.ma_nt; a_tien(b_bt):=r_lp.tien; a_thue(b_bt):=0;
    a_so_ct(b_bt):=r_hs.so_ct;
end loop;
if b_bt=0 then b_loi:=''; return; end if;
PBH_TH_DOth(r_hs.ma_dvi_ql,r_hs.so_id_hd,a_so_id_ps,a_so_ct,a_ngay,a_nhom,a_loai,a_nv,a_so_id_dt,a_lh_nv,a_ma_nt,a_tien,a_thue,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_DO_TBA:loi'; end if;
end;
/
create or replace PROCEDURE PBH_TH_DO_THOI(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_bt number:=0; b_con number; b_hs number; b_tp number:=0;
    a_so_id_ps pht_type.a_num; a_so_ct pht_type.a_var; a_ngay pht_type.a_num; a_nhom pht_type.a_var; 
    a_loai pht_type.a_var; a_nv pht_type.a_var; a_so_id_dt pht_type.a_num; a_lh_nv pht_type.a_var;
    a_ma_nt pht_type.a_var; a_tien pht_type.a_num; a_thue pht_type.a_num;
    r_hs bh_bt_thoi%rowtype;
begin
-- Dan - Tong hop thu hoi
delete bh_hd_do_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id;
delete bh_hd_do_sc_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id;
select * into r_hs from bh_bt_thoi where ma_dvi=b_ma_dvi and so_id=b_so_id;
if FBH_DONG(r_hs.ma_dvi_ql,r_hs.so_id_hd)<>'D' then b_loi:=''; return; end if;
for r_lp in(select so_id_dt,lh_nv,sum(tien) tien from bh_bt_thoi_pt where
    ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by so_id_dt,lh_nv) loop
    b_bt:=b_bt+1;
    a_so_id_ps(b_bt):=b_so_id; a_ngay(b_bt):=r_hs.ngay_ht;
    a_so_id_dt(b_bt):=r_lp.so_id_dt; a_lh_nv(b_bt):=r_lp.lh_nv;
    a_nhom(b_bt):='D'; a_loai(b_bt):='CH_BTF_THd'; a_nv(b_bt):='C';
    a_ma_nt(b_bt):=r_hs.ma_nt; a_tien(b_bt):=r_lp.tien; a_thue(b_bt):=0;
    a_so_ct(b_bt):=r_hs.so_ct;
end loop;
if b_bt=0 then b_loi:=''; return; end if;
PBH_TH_DOth(r_hs.ma_dvi_ql,r_hs.so_id_hd,a_so_id_ps,a_so_ct,a_ngay,a_nhom,a_loai,a_nv,a_so_id_dt,a_lh_nv,a_ma_nt,a_tien,a_thue,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_DO_THOI:loi'; end if;
end;
/
-- chuclh: db sach
create or replace procedure PBH_TH_NO_TON
    (b_ma_dvi varchar2,b_so_id number,b_ma_nt varchar2,b_ngay_ht number,b_ton out number,b_ton_qd out number)
AS
    b_i1 number;
begin
-- Dan - Ton va ton_qd
select nvl(max(ngay_ht),0) into b_i1 from bh_hd_goc_sc_no where
    ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=b_ma_nt and ngay_ht<=b_ngay_ht;
if b_i1<>0 then
    select ton,ton_qd into b_ton,b_ton_qd from bh_hd_goc_sc_no where
        ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=b_ma_nt and ngay_ht=b_i1;
else
    b_ton:=0; b_ton_qd:=0;
end if;
end;
/