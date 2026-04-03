create or replace function FTBH_PS(b_ma_dvi varchar2,b_so_id number,b_so_id_ps number:=0) return number
AS
    b_kq number;
begin
-- Dan - So da phat sinh xu ly
if b_so_id_ps<>0 then
    select count(*) into b_kq from tbh_xl_ct where ma_dvi_ps=b_ma_dvi and so_id_xl=b_so_id and so_id_ps=b_so_id_ps;
else
    select count(*) into b_kq from tbh_xl_ct where ma_dvi_ps=b_ma_dvi and so_id_xl=b_so_id;
end if;
return b_kq;
end;
/
create or replace procedure PTBH_TH_TA_TEMP
    (a_ma_ta out pht_type.a_var,a_ma_nt out pht_type.a_var,a_tien out pht_type.a_num,a_tp out pht_type.a_num)
AS
begin
-- Dan - Chuyen Table tbh_ps_temp thanh mang
select ma_ta,ma_nt,sum(tien) bulk collect into a_ma_ta,a_ma_nt,a_tien from tbh_ps_temp group by ma_ta,ma_nt;
for b_lp in 1..a_ma_ta.count loop
    if a_ma_nt(b_lp)='VND' then a_tp(b_lp):=0; else a_tp(b_lp):=2; end if;
end loop;
end;
/
create or replace function FTBH_TH_TA_XLY(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_i1 number;
begin
-- Dan - Da xu ly phat sinh tai
select count(*) into b_i1 from tbh_xl_ct where ma_dvi_ps=b_ma_dvi and so_id_ps=b_so_id;
if b_i1=0 then
    select count(*) into b_i1 from tbh_ung_ps_ct where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id;
end if;
return b_i1;
end;
/
create or replace procedure PTBH_TH_TA_PS_TON(
    b_ma_dvi varchar2,b_so_id number,b_so_id_nv number,b_so_id_hd number,b_so_id_dt number,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Tong hop ton phat sinh
delete tbh_ps_ton_temp;
delete tbh_ps_ton where so_id=b_so_id and so_id_nv=b_so_id_nv and b_so_id_hd in(0,so_id_hd) and b_so_id_dt in(0,b_so_id_dt);
insert into tbh_ps_ton_temp
    select tien,thue,hhong,bt from tbh_ps where
        so_id=b_so_id and so_id_nv=b_so_id_nv and b_so_id_hd in(0,so_id_hd) and b_so_id_dt in(0,b_so_id_dt) union all
    select -tien_tra,-thue_tra,-hhong_tra,bt_ps from tbh_xl_ct where 
        ma_dvi_ps=b_ma_dvi and so_id_ps=b_so_id and so_id_nv=b_so_id_nv and so_id_hd=b_so_id_hd and so_id_dt=b_so_id_dt;
insert into tbh_ps_ton select b_ma_dvi,b_so_id,b_so_id_nv,b_so_id_hd,b_so_id_dt,sum(tien),sum(thue),sum(hhong),bt
    from tbh_ps_ton_temp group by bt having sum(tien)<>0;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TA_PS_TON:loi'; end if;
end;
/
create or replace procedure PTBH_TH_PS_PBO(
    b_ma_dvi varchar2,b_so_id number,b_so_id_nv number,
    b_so_id_hd number,b_so_id_dt number,b_loi out varchar2,b_xoa varchar2:='C')
AS
    b_i1 number; b_bt number:=0; b_btt number:=0; b_tien number; b_tien_qd number;
    b_thue number; b_thue_qd number; b_hhong number; b_hhong_qd number;
begin
-- Dan
if b_xoa='C' then
    delete tbh_ps where so_id=b_so_id and so_id_nv=b_so_id_nv and b_so_id_hd in(0,so_id_hd) and b_so_id_dt in(0,b_so_id_dt);
    delete tbh_ps_pbo where so_id=b_so_id and so_id_nv=b_so_id_nv and b_so_id_hd in(0,so_id_hd) and b_so_id_dt in(0,b_so_id_dt);
else
    select nvl(max(bt),0) into b_bt from tbh_ps where so_id=b_so_id and so_id_nv=b_so_id_nv and
        b_so_id_hd in(0,so_id_hd) and b_so_id_dt in(0,b_so_id_dt);
    select nvl(max(btt),0) into b_btt from tbh_ps_pbo where
        so_id=b_so_id and so_id_nv=b_so_id_nv and b_so_id_hd in(0,so_id_hd) and b_so_id_dt in(0,b_so_id_dt);
end if;
for r_lp in(select distinct so_id_ta_ps,so_id_ta_hd,ma_dvi_hd,so_id_hd,so_id_dt,
        ngay_ht,ps,kieu,nv,loai,goc,nha_bh,pthuc,ma_nt from tbh_ps_pbo_temp) loop
    select sum(tien),sum(thue),sum(hhong) into b_tien,b_thue,b_hhong from tbh_ps_pbo_temp where
        so_id_ta_ps=r_lp.so_id_ta_ps and so_id_ta_hd=r_lp.so_id_ta_hd and
        ma_dvi_hd=r_lp.ma_dvi_hd and so_id_hd=r_lp.so_id_hd and so_id_dt=r_lp.so_id_dt and
        ngay_ht=r_lp.ngay_ht and ps=r_lp.ps and kieu=r_lp.kieu and nv=r_lp.nv and loai=r_lp.loai and goc=r_lp.goc and
        nha_bh=r_lp.nha_bh and pthuc=r_lp.pthuc and ma_nt=r_lp.ma_nt;
    if b_tien=0 then continue; end if;
    b_bt:=b_bt+1;
    if r_lp.ma_nt<>'VND' then
        b_tien_qd:=b_tien; b_thue_qd:=b_thue; b_hhong_qd:=b_hhong;
    else
        b_i1:=FBH_TT_TRA_TGTT(r_lp.ngay_ht,r_lp.ma_nt);
        b_tien_qd:=round(b_i1*b_tien,0); b_thue_qd:=round(b_i1*b_thue,0); b_hhong_qd:=round(b_i1*b_hhong,0);
    end if;
    insert into tbh_ps values(b_ma_dvi,b_so_id,b_so_id_nv,r_lp.so_id_ta_ps,r_lp.so_id_ta_hd,
        r_lp.ma_dvi_hd,r_lp.so_id_hd,r_lp.so_id_dt,r_lp.ngay_ht,
        r_lp.ps,r_lp.kieu,r_lp.nv,r_lp.loai,r_lp.goc,r_lp.nha_bh,r_lp.pthuc,r_lp.ma_nt,
        b_tien,b_thue,b_hhong,b_tien_qd,b_thue_qd,b_hhong_qd,b_bt,0);
    for r_lp1 in(select ma_ta,tien,thue,hhong from tbh_ps_pbo_temp where
        so_id_ta_ps=r_lp.so_id_ta_ps and so_id_ta_hd=r_lp.so_id_ta_hd and
        ma_dvi_hd=r_lp.ma_dvi_hd and so_id_hd=r_lp.so_id_hd and so_id_dt=r_lp.so_id_dt and
        ngay_ht=r_lp.ngay_ht and ps=r_lp.ps and kieu=r_lp.kieu and nv=r_lp.nv and loai=r_lp.loai and goc=r_lp.goc and
        nha_bh=r_lp.nha_bh and pthuc=r_lp.pthuc and ma_nt=r_lp.ma_nt) loop
        if r_lp1.tien<>0 or r_lp1.thue<>0 or r_lp1.hhong<>0 then
            b_btt:=b_btt+1;
            insert into tbh_ps_pbo values(b_ma_dvi,b_so_id,b_so_id_nv,r_lp.so_id_ta_ps,r_lp.so_id_ta_hd,
                r_lp.ma_dvi_hd,r_lp.so_id_hd,r_lp.so_id_dt,r_lp.ngay_ht,r_lp.ps,r_lp.kieu,
                r_lp.nv,r_lp.loai,r_lp.goc,r_lp1.ma_ta,r_lp.nha_bh,r_lp.pthuc,
                r_lp.ma_nt,r_lp1.tien,r_lp1.thue,r_lp1.hhong,b_bt,b_btt);
        end if;
    end loop;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_PS_PBO:loi'; end if;
end;
/
create or replace procedure PTBH_TH_TA_NH_PS(
    b_ma_dvi varchar2,b_kieu varchar2,b_so_id number,b_so_id_nv number,b_ngay number,b_nv varchar2,b_loai varchar2,
    b_goc varchar2,b_ma_dvi_hd varchar2,b_so_id_hd number,b_so_id_dt number,b_so_hd varchar2,
    b_so_ps varchar2,b_so_id_ta number,
    a_pthuc pht_type.a_var,a_ma_ta pht_type.a_var,a_nha_bh pht_type.a_var,a_pt pht_type.a_num,
    a_ma_ta_n pht_type.a_var,a_tien pht_type.a_num, a_tp pht_type.a_num,a_phi pht_type.a_num,
    b_loi out varchar2,b_dk varchar2:='C')
AS
    b_tien number; b_so_id_ta_ps number; b_so_id_ta_hd number;
    b_dvi_ta varchar2(10); b_ps varchar2(1):='C'; b_nt_ta varchar2(5); b_ngay_hd number:=b_ngay;
begin
-- Dan - Nhap phat sinh so lieu tai
b_dvi_ta:=FTBH_DVI_TA();
if b_goc in('BT_HS','BT_GD','BT_TU','CP_C','CPT_T') then b_ps:='T'; end if;
if b_kieu in('V','N') then
    if b_ps='T' then b_ps:='C'; else b_ps:='T'; end if;
end if;
if b_goc='BT_HS' then
    b_ngay_hd:=FBH_BT_NGAY_XR(b_ma_dvi,b_so_id);
elsif b_goc='BT_GD' then
    b_ngay_hd:=FBH_BT_GD_HS_NGAY_XR(b_ma_dvi,b_so_id);
elsif b_goc='BT_TU' then
    b_ngay_hd:=FBH_BT_TU_NGAY_XR(b_ma_dvi,b_so_id);
end if;
for b_lp_ta in 1..a_pthuc.count loop
    b_so_id_ta_hd:=0;
    if b_kieu in('C','D') then
        b_so_id_ta_ps:=FTBH_GHEP_SO_ID_DAU(b_so_id_ta);
        b_so_id_ta_hd:=FTBH_HD_SO_ID_TA(b_ngay_hd,b_so_id_ta_ps,a_pthuc(b_lp_ta),a_ma_ta(b_lp_ta));
        b_nt_ta:=FTBH_GHEP_NT_TA(b_dvi_ta,b_so_id_ta_ps);
    else
        b_so_id_ta_ps:=FTBH_TM_SO_ID_DAU(b_so_id_ta);
        b_nt_ta:=FTBH_TM_NT_TA(b_so_id_ta_ps);
    end if;
    if a_ma_ta_n.count<>0 then
        for b_lp_ps in 1..a_ma_ta_n.count loop
            if a_ma_ta(b_lp_ta) in(' ',a_ma_ta_n(b_lp_ps)) then
                b_tien:=round(a_tien(b_lp_ps)*a_pt(b_lp_ta)/100,a_tp(b_lp_ps));
                insert into tbh_ps_pbo_temp values(
                    b_so_id_ta_ps,b_so_id_ta_hd,b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_ngay,b_ps,b_kieu,b_nv,b_loai,b_goc,
                    a_ma_ta(b_lp_ta),a_nha_bh(b_lp_ta),a_pthuc(b_lp_ta),b_nt_ta,b_tien,0,0);
            end if;
        end loop;
    else
        insert into tbh_ps_pbo_temp values(
            b_so_id_ta_ps,b_so_id_ta_hd,b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_ngay,b_ps,b_kieu,b_nv,b_loai,b_goc,
            a_ma_ta(b_lp_ta),a_nha_bh(b_lp_ta),a_pthuc(b_lp_ta),b_nt_ta,a_phi(b_lp_ta),0,0);
    end if;
end loop;
PTBH_TH_PS_PBO(b_ma_dvi,b_so_id,b_so_id_nv,0,0,b_loi,b_dk);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TA_NH_PS:loi'; end if;
end;
/
create or replace procedure PTBH_TH_TA_GHEP(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_so_id_ta_ps number; b_so_id_g number;
    b_ngay_ht number; b_bt number:=0; b_nv varchar2(10); b_loai varchar2(1):='G';
    b_ps varchar2(1); b_nt_phi varchar2(5); b_kieu varchar2(1); b_ngay_hl number;
    b_tp number; b_phi number; b_thue number; b_hhong number; b_phic number; b_thuec number; b_hhongc number;
begin
-- Dan - Tong hop phat sinh ghep tai tra ngay
delete tbh_ghep_ps_temp1; delete tbh_ghep_ps_temp2;
select ngay_ht,ngay_hl,so_id_d,so_id_g,nv,nt_phi,kieu into
    b_ngay_ht,b_ngay_hl,b_so_id_ta_ps,b_so_id_g,b_nv,b_nt_phi,b_kieu from tbh_ghep where so_id=b_so_id;
PTBH_TH_TA_XOA(b_so_id,0,0,0,b_loi);
if b_loi is not null then return; end if;
insert into tbh_ghep_ps_temp1
    select so_id_ta_ps,so_id_ta_hd,ma_dvi_hd,so_id_hd,so_id_dt,pthuc,ma_ta,nha_bh,
    sum(phi),sum(thue),sum(hhong) from tbh_ghep_pbo
    where so_id=b_so_id and tien>0 group by so_id_ta_ps,so_id_ta_hd,ma_dvi_hd,so_id_hd,so_id_dt,pthuc,ma_ta,nha_bh;
if b_so_id_g<>0 then
    insert into tbh_ghep_ps_temp1
        select so_id_ta_ps,so_id_ta_hd,ma_dvi_hd,so_id_hd,so_id_dt,pthuc,ma_ta,nha_bh,
        -sum(phi),-sum(thue),-sum(hhong) from tbh_ghep_pbo
        where so_id=b_so_id_g and tien>0 group by so_id_ta_ps,so_id_ta_hd,ma_dvi_hd,so_id_hd,so_id_dt,pthuc,ma_ta,nha_bh;
end if;
insert into tbh_ghep_ps_temp2
    select so_id_ta_ps,so_id_ta_hd,ma_dvi_hd,so_id_hd,so_id_dt,pthuc,ma_ta,nha_bh,
    sum(phi),sum(thue),sum(hhong) from tbh_ghep_ps_temp1
    group by so_id_ta_ps,so_id_ta_hd,ma_dvi_hd,so_id_hd,so_id_dt,pthuc,ma_ta,nha_bh
    having sum(phi)<>0 or sum(thue)<>0 or sum(hhong)<>0;
if b_so_id_ta_ps<>b_so_id then
    b_loai:='S'; b_ngay_hl:=FTBH_GHEP_NGAY_DAU(b_so_id_ta_ps);
end if;
if b_kieu='G' then b_kieu:='C'; else b_kieu:='D'; end if;
for r_lp in (select * from tbh_ghep_ps_temp2 order by pthuc,ma_ta,nha_bh) loop
    b_bt:=b_bt+1;
    insert into tbh_ps_pbo_temp values(r_lp.so_id_ta_ps,r_lp.so_id_ta_hd,
        r_lp.ma_dvi_hd,r_lp.so_id_hd,r_lp.so_id_dt,b_ngay_ht,'C',b_kieu,b_nv,b_loai,'HD_PS',
        r_lp.ma_ta,r_lp.nha_bh,r_lp.pthuc,b_nt_phi,r_lp.phi,r_lp.thue,r_lp.hhong);
end loop;
PTBH_TH_PS_PBO(b_ma_dvi,b_so_id,b_so_id,0,0,b_loi);
if b_loi is not null then return; end if;
PTBH_TH_TA_PS_TON(b_ma_dvi,b_so_id,b_so_id,0,0,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TA_GHEP:loi'; end if;
end;
/
create or replace procedure PTBH_TH_TA_TM(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_so_id_ta_ps number; b_so_id_g number; b_ngay_ht number;
    b_bt number:=0; b_nv varchar2(10); b_loai varchar2(1):='G';
    b_nt_phi varchar2(5); b_kieu varchar2(1);
    b_tp number; b_phi number; b_thue number; b_hhong number;
    b_phic number; b_thuec number; b_hhongc number;
begin
-- Dan - Tong hop phat sinh tam thoi
PTBH_TH_TA_XOA(b_so_id,0,0,0,b_loi);
if b_loi is not null then return; end if;
b_loi:='loi:So chung tu tai da xoa:loi';
select ngay_ht,so_id_d,so_id_g,nv,nt_phi,kieu into
    b_ngay_ht,b_so_id_ta_ps,b_so_id_g,b_nv,b_nt_phi,b_kieu from tbh_tm where so_id=b_so_id;
delete tbh_ghep_ps_temp1; delete tbh_ghep_ps_temp2;
insert into tbh_ghep_ps_temp1
    select so_id_ta_ps,0,ma_dvi_hd,so_id_hd,so_id_dt,'F',ma_ta,nha_bhC,sum(phi),sum(thue),sum(hhong)
    from tbh_tm_pbo where so_id=b_so_id and tien>0 group by so_id_ta_ps,ma_dvi_hd,so_id_hd,so_id_dt,ma_ta,nha_bhC;
if b_so_id_g<>0 then
    insert into tbh_ghep_ps_temp1
        select so_id_ta_ps,0,ma_dvi_hd,so_id_hd,so_id_dt,'F',ma_ta,nha_bhC,-sum(phi),-sum(thue),-sum(hhong)
        from tbh_tm_pbo where so_id=b_so_id_g and tien>0 group by so_id_ta_ps,ma_dvi_hd,so_id_hd,so_id_dt,ma_ta,nha_bhC;
end if;
insert into tbh_ghep_ps_temp2
    select so_id_ta_ps,0,ma_dvi_hd,so_id_hd,so_id_dt,'F',ma_ta,nha_bh,sum(phi),sum(thue),sum(hhong) from tbh_ghep_ps_temp1
    group by so_id_ta_ps,ma_dvi_hd,so_id_hd,so_id_dt,ma_ta,nha_bh having sum(phi)<>0 or sum(thue)<>0 or sum(hhong)<>0;
if b_so_id_ta_ps<>b_so_id then b_loai:='S'; end if;
if b_kieu='G' then b_kieu:='T'; else b_kieu:='B'; end if;
for r_lp in (select * from tbh_ghep_ps_temp2 order by ma_ta,nha_bh) loop
    b_bt:=b_bt+1;
    insert into tbh_ps_pbo_temp values(r_lp.so_id_ta_ps,0,r_lp.ma_dvi_hd,r_lp.so_id_hd,r_lp.so_id_dt,b_ngay_ht,'C',
        b_kieu,b_nv,b_loai,'HD_PS',r_lp.ma_ta,r_lp.nha_bh,r_lp.pthuc,b_nt_phi,r_lp.phi,r_lp.thue,r_lp.hhong);
end loop;
PTBH_TH_PS_PBO(b_ma_dvi,b_so_id,b_so_id,0,0,b_loi);
if b_loi is not null then return; end if;
PTBH_TH_TA_PS_TON(b_ma_dvi,b_so_id,b_so_id,0,0,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TA_GHEP:loi'; end if;
end;
/
create or replace procedure PTBH_TH_TA_PHI_GHEP(
    b_ma_dvi varchar2,b_so_id_tt number,b_loi out varchar2)
AS
    b_log boolean; b_i1 number; b_hthanh number; b_bd number; b_kt number:=0;
    b_ngay_ht number; b_so_id_hd number; b_so_id_hdB number; b_nt_phi varchar2(5); b_nguon varchar2(1);
    b_nv varchar2(10); b_pt varchar2(1); b_so_id_taB number; b_tg number:=1; b_tp number:=0;
    a_so_id_taB pht_type.a_num; a_so_id_taD pht_type.a_num;
    a_so_idK pht_type.a_num; a_so_idH pht_type.a_num; a_so_idX pht_type.a_num;
begin
-- Dan - Tong hop phat sinh tai thanh toan phi
delete tbh_ghep_ps_temp; delete tbh_ps_pbo_temp;
PKH_MANG_KD_N(a_so_id_taD);
for r_lp in (select distinct so_id from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt) loop
    for r_lp1 in (select distinct a.so_id_d from tbh_ghep_hd b,tbh_ghep a 
        where b.ma_dvi_hd=b_ma_dvi and b.so_id_hd=r_lp.so_id and a.so_id=b.so_id) loop
        if FKH_ARR_VTRI_N(a_so_id_taD,r_lp1.so_id_d)=0 then
            b_i1:=a_so_id_taD.count+1; a_so_id_taD(b_i1):=r_lp1.so_id_d;
        end if;
    end loop;
end loop;
for b_lp in 1..a_so_id_taD.count loop
    b_so_id_taB:=FTBH_GHEP_SO_ID_BS(a_so_id_taD(b_lp));
    PTBH_TH_TA_XOA(b_so_id_tt,b_so_id_taB,0,0,b_loi);
    if b_loi is not null then return; end if;
end loop;
select ngay_ht into b_ngay_ht from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
for r_lp in (select distinct so_id from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt) loop
    b_so_id_hd:=r_lp.so_id;
    select distinct so_id_d bulk collect into a_so_idX from bh_hd_goc where
        ma_dvi=b_ma_dvi and so_id_g=b_so_id_hd and kieu_hd='K' and ttrang='D';
    if a_so_idX.count=0 then
        b_kt:=b_kt+1; a_so_idH(b_kt):=b_so_id_hd; a_so_idK(b_kt):=b_so_id_hd;
    else
        for b_lp in 1..a_so_idX.count loop
            b_kt:=b_kt+1; a_so_idH(b_kt):=b_so_id_hd; a_so_idK(b_kt):=a_so_idX(b_lp);
        end loop;
    end if;
end loop;
for b_lpK in 1..a_so_idK.count loop
    select distinct a.so_id_d BULK COLLECT into a_so_id_taD from tbh_ghep_pbo b,tbh_ghep a where 
        b.ma_dvi_hd=b_ma_dvi and b.so_id_hd=a_so_idK(b_lpK) and
        a.so_id=b.so_id and b_ngay_ht between a.ngay_hl and a.ngay_kt;
    if a_so_id_taD.count=0 then continue; end if;
    b_so_id_hdB:=FBH_HD_SO_ID_BSd(b_ma_dvi,a_so_idK(b_lpK),b_ngay_ht);
    for b_lp in 1..a_so_id_taD.count loop
        select nvl(min(so_id_ta_hd),0) into b_i1 from tbh_ghep_pbo where so_id_ta_ps=a_so_id_taD(b_lp);
        if b_i1=0 then b_nguon:='B';
        else b_nguon:=FTBH_HD_DI_TXT(b_i1,'nguon','B');
        end if;
        b_hthanh:=FBH_HD_TT_HTHANH(b_ma_dvi,a_so_idH(b_lpK),b_nguon,b_ngay_ht);
        if b_hthanh=0 then continue; end if;
        b_so_id_taB:=FTBH_GHEP_SO_ID_BS(a_so_id_taD(b_lp));
        select nv,nt_phi into b_nv,b_nt_phi from tbh_ghep where so_id=b_so_id_taB;
        if b_nt_phi='VND' then b_tp:=0; b_tg:=1;
        else b_tp:=2; b_tg:=FBH_TT_TRA_TGTT(b_ngay_ht,b_nt_phi);
        end if;
        if b_hthanh=100 then
            insert into tbh_ghep_ps_temp
                select 'PHI',b_so_id_taB,a_so_id_taD(b_lp),so_id_ta_hd,b_ma_dvi,a_so_idK(b_lpK),
                so_id_dt,'C',ma_ta,nha_bhC,phi,thue,hhong
                from tbh_ghep_pbo where so_id=b_so_id_taB and ma_dvi_hd=b_ma_dvi and so_id_hd=a_so_idK(b_lpK) and phi>0;
            insert into tbh_ghep_ps_temp
                select 'PHI',b_so_id_taB,a_so_id_taD(b_lp),so_id_ta_hd,b_ma_dvi,a_so_idK(b_lpK),
                so_id_dt,'C',ma_ta,nha_bh,-tien,-thue,-hhong
                from tbh_ps_pbo where so_id_ta_ps=a_so_id_taD(b_lp) and ma_dvi_hd=b_ma_dvi and so_id_hd=a_so_idK(b_lpK);
        else
            for r_lp1 in(select distinct so_id_dt,lh_nv from bh_hd_goc_dkdt where ma_dvi=b_ma_dvi and so_id=b_so_id_hdB) loop
                insert into tbh_ghep_ps_temp
                    select 'PHI',b_so_id_taB,a_so_id_taD(b_lp),so_id_ta_hd,b_ma_dvi,a_so_idK(b_lpK),
                    so_id_dt,'C',ma_ta,nha_bhC,round(phi*b_hthanh,0),round(thue*b_hthanh,0),round(hhong*b_hthanh,0)
                    from tbh_ghep_pbo where so_id=b_so_id_taB and ma_dvi_hd=b_ma_dvi and so_id_hd=a_so_idK(b_lpK) and phi>0 and
                    so_id_dt in(0,r_lp1.so_id_dt) and lh_nv in(' ',r_lp1.lh_nv);
            end loop;
        end if;
    end loop;
end loop;
select distinct so_id_taB bulk collect into a_so_id_taB from tbh_ghep_ps_temp;
for b_lp in 1..a_so_id_taB.count loop
    delete tbh_ps_pbo_temp;
    insert into tbh_ps_pbo_temp
        select so_id_ta_ps,so_id_ta_hd,b_ma_dvi,so_id_hd,so_id_dt,b_ngay_ht,'T','C',b_nv,'T','CH_PHF_BHd',
        ma_ta,nha_bh,pthuc,b_nt_phi,sum(phi),sum(thue),sum(hhong)
        from tbh_ghep_ps_temp where ps='PHI' and so_id_taB=a_so_id_taB(b_lp)
        group by so_id_ta_ps,so_id_ta_hd,so_id_hd,so_id_dt,ma_ta,nha_bh,pthuc having sum(phi)<>0;
    PTBH_TH_PS_PBO(b_ma_dvi,b_so_id_tt,a_so_id_taB(b_lp),0,0,b_loi);
    if b_loi is not null then return; end if;
    PTBH_TH_TA_PS_TON(b_ma_dvi,b_so_id_tt,a_so_id_taB(b_lp),0,0,b_loi);
    if b_loi is not null then return; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TA_PHI_GHEP:loi'; end if;
end;
/
create or replace procedure PTBH_TH_TA_PHI_GHEPk(
    b_ma_dvi varchar2,b_so_id_hdK number,b_so_id_dtK number,b_loi out varchar2)
AS
    b_log boolean; b_i1 number; b_hthanh number; b_bd number; b_kt number:=0;
    b_ngay_ht number; b_so_id_hdG number; b_so_id_hdB number; b_nt_phi varchar2(5); b_nguon varchar2(1);
    b_nv varchar2(10); b_pt varchar2(1); b_so_id_taB number; b_tg number:=1; b_tp number:=0;
    a_so_id_taD pht_type.a_num; a_so_id_taB pht_type.a_num; a_so_id_tt pht_type.a_num;
begin
-- Dan - Tong hop phat sinh tai thanh toan phi hop dong kem
delete tbh_ghep_ps_temp; delete tbh_ps_pbo_temp;
select so_id_g into b_so_id_hdG from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id_hdK;
select distinct so_id_tt bulk collect into a_so_id_tt from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_id_hdG;
if a_so_id_tt.count=0 then b_loi:=''; return; end if;
select distinct a.so_id_d bulk collect into a_so_id_taD from tbh_ghep_hd b,tbh_ghep a where
    b.ma_dvi_hd=b_ma_dvi and b.so_id_hd=b_so_id_hdK and b.so_id_dt=b_so_id_dtK and a.so_id=b.so_id;
if a_so_id_taD.count=0 then b_loi:=''; return; end if;
for b_lp in 1..a_so_id_taD.count loop
    a_so_id_taB(b_lp):=FTBH_GHEP_SO_ID_BS(a_so_id_taD(b_lp));
    for b_lpT in 1..a_so_id_tt.count loop
        PTBH_TH_TA_XOA(a_so_id_tt(b_lpT),a_so_id_taB(b_lp),b_so_id_hdK,b_so_id_dtK,b_loi);
        if b_loi is not null then return; end if;
    end loop;
end loop;
b_so_id_hdB:=FBH_HD_SO_ID_BSd(b_ma_dvi,b_so_id_hdK,b_ngay_ht);
for b_lpT in 1..a_so_id_tt.count loop
    select ngay_ht into b_ngay_ht from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=a_so_id_tt(b_lpT);
    for b_lp in 1..a_so_id_taD.count loop
        select nvl(min(so_id_ta_hd),0) into b_i1 from tbh_ghep_pbo where so_id_ta_ps=a_so_id_taD(b_lp);
        if b_i1=0 then b_nguon:='B';
        else b_nguon:=FTBH_HD_DI_TXT(b_i1,'nguon','B');
        end if;
        b_hthanh:=FBH_HD_TT_HTHANH(b_ma_dvi,b_so_id_hdG,b_nguon,b_ngay_ht);
        if b_hthanh=0 then continue; end if;
        select nv,nt_phi into b_nv,b_nt_phi from tbh_ghep where so_id=a_so_id_taB(b_lp);
        if b_nt_phi='VND' then b_tp:=0; b_tg:=1;
        else b_tp:=2; b_tg:=FBH_TT_TRA_TGTT(b_ngay_ht,b_nt_phi);
        end if;
        if b_hthanh=100 then
            insert into tbh_ghep_ps_temp
                select 'PHI',a_so_id_taB(b_lp),a_so_id_taD(b_lp),so_id_ta_hd,
                b_ma_dvi,b_so_id_hdK,b_so_id_dtK,'C',ma_ta,nha_bhC,phi,thue,hhong
                from tbh_ghep_pbo where so_id=a_so_id_taB(b_lp) and ma_dvi_hd=b_ma_dvi and
                so_id_hd=b_so_id_hdK and so_id_dt=b_so_id_dtK and phi>0;
            insert into tbh_ghep_ps_temp
                select 'PHI',a_so_id_taB(b_lp),a_so_id_taD(b_lp),so_id_ta_hd,
                b_ma_dvi,b_so_id_hdK,b_so_id_dtK,'C',ma_ta,nha_bh,-tien,-thue,-hhong
                from tbh_ps_pbo where so_id_ta_ps=a_so_id_taD(b_lp) and
                ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id_hdK and so_id_dt=b_so_id_dtK;
        else
            for r_lp1 in(select distinct lh_nv from bh_hd_goc_dkdt
                where ma_dvi=b_ma_dvi and so_id=b_so_id_hdB and so_id_dt=b_so_id_dtK) loop
                insert into tbh_ghep_ps_temp
                    select 'PHI',b_so_id_taB,a_so_id_taD(b_lp),so_id_ta_hd,b_ma_dvi,b_so_id_hdK,b_so_id_dtK,
                    'C',ma_ta,nha_bhC,round(phi*b_hthanh,0),round(thue*b_hthanh,0),round(hhong*b_hthanh,0)
                    from tbh_ghep_pbo where so_id=b_so_id_taB and ma_dvi_hd=b_ma_dvi and
                    so_id_hd=b_so_id_hdK and so_id_dt=b_so_id_dTK and phi>0 and lh_nv in(' ',r_lp1.lh_nv);
            end loop;
        end if;
    end loop;
    for b_lp in 1..a_so_id_taD.count loop
        delete tbh_ps_pbo_temp;
        insert into tbh_ps_pbo_temp
            select so_id_ta_ps,so_id_ta_hd,b_ma_dvi,b_so_id_hdK,b_so_id_dtK,b_ngay_ht,'T','C',b_nv,'T','CH_PHF_BHd',
            ma_ta,nha_bh,pthuc,b_nt_phi,sum(phi),sum(thue),sum(hhong)
            from tbh_ghep_ps_temp where ps='PHI'
            group by so_id_ta_ps,so_id_ta_hd,ma_ta,nha_bh,pthuc having sum(phi)<>0;
        PTBH_TH_PS_PBO(b_ma_dvi,a_so_id_tt(b_lpT),a_so_id_taB(b_lp),b_so_id_hdK,b_so_id_dtK,b_loi);
        if b_loi is not null then return; end if;
        PTBH_TH_TA_PS_TON(b_ma_dvi,a_so_id_tt(b_lpT),a_so_id_taB(b_lp),b_so_id_hdK,b_so_id_dtK,b_loi);
        if b_loi is not null then return; end if;
    end loop;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TA_PHI_GHEPk:loi'; end if;
end;
/
create or replace procedure PTBH_TH_TA_PHI_TM(
    b_ma_dvi varchar2,b_so_id_tt number,b_loi out varchar2)
AS
    b_log boolean; b_i1 number; b_hthanh number; b_bd number; b_kt number:=0;
    b_ngay_ht number; b_so_id_hd number; b_so_id_hdB number; b_nt_phi varchar2(5); b_nguon varchar2(1);
    b_nv varchar2(10); b_pt varchar2(1); b_so_id_taB number; b_tg number:=1; b_tp number:=0;
    a_so_id_taB pht_type.a_num; a_so_id_taD pht_type.a_num;
    a_so_idK pht_type.a_num; a_so_idH pht_type.a_num; a_so_idX pht_type.a_num;
begin
-- Dan - Tong hop phat sinh tai phi
delete tbh_ghep_ps_temp; delete tbh_ps_pbo_temp;
PKH_MANG_KD_N(a_so_id_taD);
for r_lp in (select distinct so_id from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt) loop
    for r_lp1 in (select distinct a.so_id_d from tbh_tm_hd b,tbh_tm a
        where b.ma_dvi_hd=b_ma_dvi and b.so_id_hd=r_lp.so_id and a.so_id=b.so_id) loop
        if FKH_ARR_VTRI_N(a_so_id_taD,r_lp1.so_id_d)=0 then
            b_i1:=a_so_id_taD.count+1; a_so_id_taD(b_i1):=r_lp1.so_id_d;
        end if;
    end loop;
end loop;
for b_lp in 1..a_so_id_taD.count loop
    b_so_id_taB:=FTBH_TM_SO_ID_BS(a_so_id_taD(b_lp));
    PTBH_TH_TA_XOA(b_so_id_tt,b_so_id_taB,0,0,b_loi);
    if b_loi is not null then return; end if;
end loop;
select ngay_ht into b_ngay_ht from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
for r_lp in (select distinct so_id from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt) loop
    b_so_id_hd:=r_lp.so_id;
    select distinct so_id_d bulk collect into a_so_idX from bh_hd_goc where
        ma_dvi=b_ma_dvi and so_id_g=b_so_id_hd and kieu_hd='K' and ttrang='D';
    if a_so_idX.count=0 then
        b_kt:=b_kt+1; a_so_idH(b_kt):=b_so_id_hd; a_so_idK(b_kt):=b_so_id_hd;
    else
        for b_lp in 1..a_so_idX.count loop
            b_kt:=b_kt+1; a_so_idH(b_kt):=b_so_id_hd; a_so_idK(b_kt):=a_so_idX(b_lp);
        end loop;
    end if;
end loop;
for b_lpK in 1..a_so_idK.count loop
    select distinct a.so_id_d BULK COLLECT into a_so_id_taD from tbh_tm_pbo b,tbh_tm a where 
        b.ma_dvi_hd=b_ma_dvi and b.so_id_hd=a_so_idK(b_lpK) and
        a.so_id=b.so_id and b_ngay_ht between a.ngay_hl and a.ngay_kt;
    if a_so_id_taD.count=0 then continue; end if;
    for b_lp in 1..a_so_id_taD.count loop
        b_hthanh:=FBH_HD_TT_HTHANH(b_ma_dvi,a_so_idH(b_lpK),'T',b_ngay_ht);
        b_so_id_taB:=FTBH_TM_SO_ID_BS(a_so_id_taD(b_lp));
        select nv,nt_phi into b_nv,b_nt_phi from tbh_tm where so_id=b_so_id_taB;
        if b_nt_phi='VND' then b_tp:=0; b_tg:=1;
        else b_tp:=2; b_tg:=FBH_TT_TRA_TGTT(b_ngay_ht,b_nt_phi);
        end if;
        if b_hthanh=100 then
            insert into tbh_ghep_ps_temp
                select 'PHI',b_so_id_taB,a_so_id_taD(b_lp),0,b_ma_dvi,a_so_idK(b_lpK),
                so_id_dt,'F',ma_ta,nha_bhC,phi,thue,hhong
                from tbh_tm_pbo where so_id=b_so_id_taB and ma_dvi_hd=b_ma_dvi and so_id_hd=a_so_idK(b_lpK) and phi>0;
            insert into tbh_ghep_ps_temp
                select 'PHI',b_so_id_taB,a_so_id_taD(b_lp),0,b_ma_dvi,a_so_idK(b_lpK),
                so_id_dt,'F',ma_ta,nha_bh,-tien,-thue,-hhong
                from tbh_ps_pbo where so_id_ta_ps=a_so_id_taD(b_lp) and ma_dvi_hd=b_ma_dvi and so_id_hd=a_so_idK(b_lpK);
        elsif b_hthanh<>0 then
            b_so_id_hdB:=FBH_HD_SO_ID_BSd(b_ma_dvi,a_so_idK(b_lpK),b_ngay_ht);
            for r_lp1 in(select distinct so_id_dt,lh_nv from bh_hd_goc_dkdt where ma_dvi=b_ma_dvi and so_id=b_so_id_hdB) loop
                insert into tbh_ghep_ps_temp
                    select 'PHI',b_so_id_taB,a_so_id_taD(b_lp),0,b_ma_dvi,a_so_idK(b_lpK),
                    so_id_dt,'F',ma_ta,nha_bhC,round(phi*b_hthanh,0),round(thue*b_hthanh,0),round(hhong*b_hthanh,0)
                    from tbh_tm_pbo where so_id=b_so_id_taB and ma_dvi_hd=b_ma_dvi and so_id_hd=a_so_idK(b_lpK) and phi>0 and
                    so_id_dt in(0,r_lp1.so_id_dt) and lh_nv in(' ',r_lp1.lh_nv);
            end loop;
        end if;
    end loop;
end loop;
select distinct so_id_taB bulk collect into a_so_id_taB from tbh_ghep_ps_temp;
for b_lp in 1..a_so_id_taB.count loop
    delete tbh_ps_pbo_temp;
    insert into tbh_ps_pbo_temp
        select so_id_ta_ps,0,b_ma_dvi,so_id_hd,so_id_dt,b_ngay_ht,'T','T',b_nv,'T','CH_PHF_BHd',
        ma_ta,nha_bh,pthuc,b_nt_phi,sum(phi),sum(thue),sum(hhong)
        from tbh_ghep_ps_temp where ps='PHI' and so_id_taB=a_so_id_taB(b_lp)
        group by so_id_ta_ps,so_id_hd,so_id_dt,ma_ta,nha_bh,pthuc having sum(phi)<>0;
    PTBH_TH_PS_PBO(b_ma_dvi,b_so_id_tt,a_so_id_taB(b_lp),0,0,b_loi);
    if b_loi is not null then return; end if;
    PTBH_TH_TA_PS_TON(b_ma_dvi,b_so_id_tt,a_so_id_taB(b_lp),0,0,b_loi);
    if b_loi is not null then return; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TA_PHI_TM:loi'; end if;
end;
/
create or replace procedure PTBH_TH_TA_PHI_TMk(
    b_ma_dvi varchar2,b_so_id_hdK number,b_so_id_dtK number,b_loi out varchar2)
AS
    b_log boolean; b_i1 number; b_hthanh number; b_bd number; b_kt number:=0;
    b_ngay_ht number; b_so_id_hdG number; b_so_id_hdB number; b_nt_phi varchar2(5);
    b_nv varchar2(10); b_pt varchar2(1); b_so_id_taB number; b_tg number:=1; b_tp number:=0;
    a_so_id_taD pht_type.a_num; a_so_id_taB pht_type.a_num; a_so_id_tt pht_type.a_num;
begin
-- Dan - Tong hop phat sinh tai thanh toan phi hop dong kem
delete tbh_ghep_ps_temp; delete tbh_ps_pbo_temp;
select so_id_g into b_so_id_hdG from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id_hdK;
select distinct so_id_tt bulk collect into a_so_id_tt from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_id_hdG;
if a_so_id_tt.count=0 then b_loi:=''; return; end if;
select distinct a.so_id_d bulk collect into a_so_id_taD from tbh_tm_hd b,tbh_tm a where
    b.ma_dvi_hd=b_ma_dvi and b.so_id_hd=b_so_id_hdK and b.so_id_dt=b_so_id_dtK and a.so_id=b.so_id;
if a_so_id_taD.count=0 then b_loi:=''; return; end if;
for b_lp in 1..a_so_id_taD.count loop
    a_so_id_taB(b_lp):=FTBH_TM_SO_ID_BS(a_so_id_taD(b_lp));
    for b_lpT in 1..a_so_id_tt.count loop
        PTBH_TH_TA_XOA(a_so_id_tt(b_lpT),a_so_id_taB(b_lp),b_so_id_hdK,b_so_id_dtK,b_loi);
        if b_loi is not null then return; end if;
    end loop;
end loop;
b_so_id_hdB:=FBH_HD_SO_ID_BSd(b_ma_dvi,b_so_id_hdK,b_ngay_ht);
for b_lpT in 1..a_so_id_tt.count loop
    select ngay_ht into b_ngay_ht from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=a_so_id_tt(b_lpT);
    for b_lp in 1..a_so_id_taD.count loop
        b_hthanh:=FBH_HD_TT_HTHANH(b_ma_dvi,b_so_id_hdG,'T',b_ngay_ht);
        if b_hthanh=0 then continue; end if;
        select nv,nt_phi into b_nv,b_nt_phi from tbh_tm where so_id=a_so_id_taB(b_lp);
        if b_nt_phi='VND' then b_tp:=0; b_tg:=1;
        else b_tp:=2; b_tg:=FBH_TT_TRA_TGTT(b_ngay_ht,b_nt_phi);
        end if;
        if b_hthanh=100 then
            insert into tbh_ghep_ps_temp
                select 'PHI',a_so_id_taB(b_lp),a_so_id_taD(b_lp),0,
                b_ma_dvi,b_so_id_hdK,b_so_id_dtK,'F',ma_ta,nha_bhC,phi,thue,hhong
                from tbh_tm_pbo where so_id=a_so_id_taB(b_lp) and ma_dvi_hd=b_ma_dvi and
                so_id_hd=b_so_id_hdK and so_id_dt=b_so_id_dtK and phi>0;
            insert into tbh_ghep_ps_temp
                select 'PHI',a_so_id_taB(b_lp),a_so_id_taD(b_lp),so_id_ta_hd,
                b_ma_dvi,b_so_id_hdK,b_so_id_dtK,'F',ma_ta,nha_bh,-tien,-thue,-hhong
                from tbh_ps_pbo where so_id_ta_ps=a_so_id_taD(b_lp) and
                ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id_hdK and so_id_dt=b_so_id_dtK;
        else
            for r_lp1 in(select distinct lh_nv from bh_hd_goc_dkdt
                where ma_dvi=b_ma_dvi and so_id=b_so_id_hdB and so_id_dt=b_so_id_dtK) loop
                insert into tbh_ghep_ps_temp
                    select 'PHI',b_so_id_taB,a_so_id_taD(b_lp),0,b_ma_dvi,b_so_id_hdK,b_so_id_dtK,
                    'F',ma_ta,nha_bhC,round(phi*b_hthanh,0),round(thue*b_hthanh,0),round(hhong*b_hthanh,0)
                    from tbh_tm_pbo where so_id=b_so_id_taB and ma_dvi_hd=b_ma_dvi and
                    so_id_hd=b_so_id_hdK and so_id_dt=b_so_id_dTK and phi>0 and lh_nv in(' ',r_lp1.lh_nv);
            end loop;
        end if;
    end loop;
    for b_lp in 1..a_so_id_taD.count loop
        delete tbh_ps_pbo_temp;
        insert into tbh_ps_pbo_temp
            select so_id_ta_ps,so_id_ta_hd,b_ma_dvi,b_so_id_hdK,b_so_id_dtK,b_ngay_ht,'T','T',b_nv,'T','CH_PHF_BHd',
            ma_ta,nha_bh,pthuc,b_nt_phi,sum(phi),sum(thue),sum(hhong)
            from tbh_ghep_ps_temp where ps='PHI'
            group by so_id_ta_ps,so_id_ta_hd,ma_ta,nha_bh,pthuc having sum(phi)<>0;
        PTBH_TH_PS_PBO(b_ma_dvi,a_so_id_tt(b_lpT),a_so_id_taB(b_lp),b_so_id_hdK,b_so_id_dtK,b_loi);
        if b_loi is not null then return; end if;
        PTBH_TH_TA_PS_TON(b_ma_dvi,a_so_id_tt(b_lpT),a_so_id_taB(b_lp),b_so_id_hdK,b_so_id_dtK,b_loi);
        if b_loi is not null then return; end if;
    end loop;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TA_PHI_TMk:loi'; end if;
end;
/
create or replace procedure PTBH_TH_TA_HH(b_ma_dvi varchar2,b_so_id_hh number,b_loi out varchar2)
AS
    b_ngay_ht number; b_tp number:=0; b_tienH number; b_phiH number;
    b_nv varchar2(10); b_so_hd varchar2(20); b_so_idB number;
    dk_lh_nv pht_type.a_var; dk_tien pht_type.a_num; dk_tp pht_type.a_num; 
    a_so_id_ta pht_type.a_num; a_pthuc pht_type.a_var; a_nbh pht_type.a_var;
    a_ma_ta pht_type.a_var; a_pt pht_type.a_num; a_tien pht_type.a_num;
begin
-- Dan - Thu phi hoa hong dai ly
select ngay_ht into b_ngay_ht from bh_hd_goc_hh where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh;
for r_lpT in (select distinct so_id,so_id_dt from bh_hd_goc_hh_ptdt where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh) loop
    delete bh_bt_dota_temp_1;
    select lh_nv,sum(hhong+htro+dvu) bulk collect into dk_lh_nv,dk_tien from
        bh_hd_goc_hh_ptdt where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh and
        so_id=r_lpT.so_id and so_id_dt=r_lpT.so_id_dt and lh_nv<>' '
        group by lh_nv having sum(hhong+htro+dvu)<>0;
    if dk_lh_nv.count=0 then continue; end if;
    for b_lp in 1..dk_lh_nv.count loop dk_tp(b_lp):=b_tp; end loop;
    b_so_idB:=FBH_HD_SO_ID_BS(b_ma_dvi,r_lpT.so_id,b_ngay_ht);
    FBH_HD_DOTA_PT(b_ma_dvi,b_so_idB,r_lpT.so_id_dt,b_loi);
    if b_loi is not null then return; end if;
    FBH_HD_NV_TIEN(b_ma_dvi,r_lpT.so_id,r_lpT.so_id_dt,b_tienH,b_phiH,b_loi);
    if b_loi is not null then return; end if;
    update bh_bt_dota_temp_1 set lh_nv=FBH_MA_LHNV_TAI(lh_nv);
    select nv,so_hd into b_nv,b_so_hd from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=r_lpT.so_id;
    -- Ghep
    select distinct so_id_ta bulk collect into a_so_id_ta from bh_bt_dota_temp_1 where pthuc in('Q','S');
    for b_lp1 in 1..a_so_id_ta.count loop
        delete tbh_ps_pbo_temp;
        select pthuc,nbhC,lh_nv,sum(tien) bulk collect into a_pthuc,a_nbh,a_ma_ta,a_tien
            from bh_bt_dota_temp_1 where so_id_ta=a_so_id_ta(b_lp1) group by pthuc,nbhC,lh_nv having sum(tien)<>0;
        for b_lp in 1..a_pthuc.count loop
            a_pt(b_lp):=round(a_tien(b_lp)*100/b_tienH,4);
        end loop;
        PTBH_TH_TA_NH_PS(b_ma_dvi,'C',b_so_id_hh,r_lpT.so_id,b_ngay_ht,b_nv,'T','DT_HH_DLd',
            b_ma_dvi,r_lpT.so_id,r_lpT.so_id_dt,b_so_hd,' ',
            a_so_id_ta(b_lp1),a_pthuc,a_ma_ta,a_nbh,a_pt,dk_lh_nv,dk_tien,dk_tp,a_tien,b_loi);
        if b_loi is not null then return; end if;
    end loop;
    -- Tam
    select distinct so_id_ta bulk collect into a_so_id_ta from bh_bt_dota_temp_1 where pthuc in('C','F');
    for b_lp1 in 1..a_so_id_ta.count loop
        delete tbh_ps_pbo_temp;
        select pthuc,nbhC,lh_nv,sum(tien) bulk collect into a_pthuc,a_nbh,a_ma_ta,a_tien
            from bh_bt_dota_temp_1 where so_id_ta=a_so_id_ta(b_lp1) group by pthuc,nbhC,lh_nv having sum(tien)<>0;
        for b_lp in 1..a_pthuc.count loop
            a_pt(b_lp):=round(a_tien(b_lp)*100/b_tienH,4);
        end loop;
        PTBH_TH_TA_NH_PS(b_ma_dvi,'T',b_so_id_hh,r_lpT.so_id,b_ngay_ht,b_nv,'T','DT_HH_DLd',
            b_ma_dvi,r_lpT.so_id,r_lpT.so_id_dt,b_so_hd,' ',
            a_so_id_ta(b_lp1),a_pthuc,a_ma_ta,a_nbh,a_pt,dk_lh_nv,dk_tien,dk_tp,a_tien,b_loi);
        if b_loi is not null then return; end if;
    end loop;
    --
    delete bh_bt_dota_temp_1;
    PTBH_TH_TA_PS_TON(b_ma_dvi,b_so_id_hh,r_lpT.so_id,0,0,b_loi);
    if b_loi is not null then return; end if;
end loop;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TA_HH:loi'; end if;
end;
/
create or replace procedure PTBH_TH_TA_TPA(b_ma_dvi varchar2,b_so_id_tr number,b_loi out varchar2)
AS
    b_ngay_ht number; b_tp number:=0; b_tienH number; b_phiH number; b_so_idB number;
    dk_lh_nv pht_type.a_var; dk_tien pht_type.a_num; dk_tp pht_type.a_num; 
    a_so_id_ta pht_type.a_num; a_pthuc pht_type.a_var; a_nbh pht_type.a_var;
    a_ma_ta pht_type.a_var; a_pt pht_type.a_num; a_tien pht_type.a_num;
begin
-- Dan - Thu phi dich vu TPA
select ngay_ht into b_ngay_ht
    from bh_tpa_tra where ma_dvi=b_ma_dvi and so_id_tr=b_so_id_tr;
for r_lpT in (select distinct a.so_id_tt,a.so_hd,a.nv,b.so_id,b.so_id_dt
    from bh_tpa_hd a,bh_tpa_hd_pt b where a.ma_dvi=b_ma_dvi and a.so_id_tr=b_so_id_tr and
        b.ma_dvi=b_ma_dvi and b.so_id_tt=a.so_id_tt) loop
    delete bh_bt_dota_temp_1;
    select lh_nv,sum(tpa_phi) bulk collect into dk_lh_nv,dk_tien from
        bh_tpa_hd_pt where ma_dvi=b_ma_dvi and so_id_tt=r_lpT.so_id_tt and
        so_id=r_lpT.so_id and so_id_dt=r_lpT.so_id_dt and lh_nv<>' '
        group by lh_nv having sum(tpa_phi)<>0;
    if dk_lh_nv.count=0 then continue; end if;
    for b_lp in 1..dk_lh_nv.count loop dk_tp(b_lp):=b_tp; end loop;
    b_so_idB:=FBH_HD_SO_ID_BS(b_ma_dvi,r_lpT.so_id,b_ngay_ht);
    FBH_HD_DOTA_PT(b_ma_dvi,r_lpT.so_id,r_lpT.so_id_dt,b_loi);
    if b_loi is not null then return; end if;
    FBH_HD_NV_TIEN(b_ma_dvi,r_lpT.so_id,r_lpT.so_id_dt,b_tienH,b_phiH,b_loi);
    if b_loi is not null then return; end if;
    update bh_bt_dota_temp_1 set lh_nv=FBH_MA_LHNV_TAI(lh_nv);
    -- Ghep
    select distinct so_id_ta bulk collect into a_so_id_ta from bh_bt_dota_temp_1 where pthuc in('Q','S');
    for b_lp1 in 1..a_so_id_ta.count loop
        delete tbh_ps_pbo_temp;
        select pthuc,nbhC,lh_nv,sum(tien) bulk collect into a_pthuc,a_nbh,a_ma_ta,a_tien
            from bh_bt_dota_temp_1 where so_id_ta=a_so_id_ta(b_lp1) group by pthuc,nbhC,lh_nv having sum(tien)<>0;
        for b_lp in 1..a_pthuc.count loop
            a_pt(b_lp):=round(a_tien(b_lp)*100/b_tienH,4);
        end loop;
        PTBH_TH_TA_NH_PS(b_ma_dvi,'C',b_so_id_tr,r_lpT.so_id,b_ngay_ht,r_lpT.nv,'T','DT_DV_TPAd',
            b_ma_dvi,r_lpT.so_id,r_lpT.so_id_dt,r_lpT.so_hd,' ',
            a_so_id_ta(b_lp1),a_pthuc,a_ma_ta,a_nbh,a_pt,dk_lh_nv,dk_tien,dk_tp,a_tien,b_loi);
        if b_loi is not null then return; end if;
    end loop;
    -- Tam
    select distinct so_id_ta bulk collect into a_so_id_ta from bh_bt_dota_temp_1 where pthuc in('C','F');
    for b_lp1 in 1..a_so_id_ta.count loop
        delete tbh_ps_pbo_temp;
        select pthuc,nbhC,lh_nv,sum(tien) bulk collect into a_pthuc,a_nbh,a_ma_ta,a_tien
            from bh_bt_dota_temp_1 where so_id_ta=a_so_id_ta(b_lp1) group by pthuc,nbhC,lh_nv having sum(tien)<>0;
        for b_lp in 1..a_pthuc.count loop
            a_pt(b_lp):=round(a_tien(b_lp)*100/b_tienH,4);
        end loop;
        PTBH_TH_TA_NH_PS(b_ma_dvi,'T',b_so_id_tr,r_lpT.so_id,b_ngay_ht,r_lpT.nv,'T','DT_DV_TPAd',
            b_ma_dvi,r_lpT.so_id,r_lpT.so_id_dt,r_lpT.so_hd,' ',
            a_so_id_ta(b_lp1),a_pthuc,a_ma_ta,a_nbh,a_pt,dk_lh_nv,dk_tien,dk_tp,a_tien,b_loi);
        if b_loi is not null then return; end if;
    end loop;
    --
    delete bh_bt_dota_temp_1;
    PTBH_TH_TA_PS_TON(b_ma_dvi,b_so_id_tr,r_lpT.so_id,0,0,b_loi);
    if b_loi is not null then return; end if;
end loop;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TA_TPA:loi'; end if;
end;
/
create or replace procedure PTBH_TH_TA_HU(b_ma_dvi varchar2,b_so_id_hd number,b_loi out varchar2)
AS
    b_i1 number; b_so_id_tt number:=b_so_id_hd*10; b_bt number:=0;
    b_nt_phi varchar2(5); b_con number;
    b_ngay_ht number; b_nv varchar2(10); b_kghep varchar2(1);
begin
-- Dan - Tong hop phat sinh huy hop dong
select count(*) into b_i1 from tbh_ps where so_id=b_so_id_tt;
if b_i1<>0 then b_loi:=''; return; end if;
delete tbh_ps_pbo_temp; delete tbh_ghep_ps_temp1;
select ngay_ht,con into b_ngay_ht,b_con from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id_hd;
if b_con=0 then b_loi:=''; return; end if;
b_nv:=FBH_HD_NV(b_ma_dvi,b_so_id_hd);
insert into tbh_ghep_ps_temp1
    select so_id_ta_ps,so_id_ta_hd,ma_dvi_hd,so_id_hd,so_id_dt,pthuc,ma_ta,nha_bh,
    round(phi*b_con/100,0),round(thue*b_con/100,0),round(hhong*b_con/100,0) from
    (select so_id_ta_ps,so_id_ta_hd,ma_dvi_hd,so_id_hd,so_id_dt,pthuc,ma_ta,nha_bh,
    sum(tien) phi,sum(thue) thue,sum(hhong) hhong
    from tbh_ps_pbo where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id_hd and goc='CH_PHF_BHd'
    group by so_id_ta_ps,so_id_ta_hd,ma_dvi_hd,so_id_hd,so_id_dt,pthuc,ma_ta,nha_bh);
if sql%rowcount<>0 then
    for r_lp in (select * from tbh_ghep_ps_temp1) loop
        b_bt:=b_bt+1;
        if r_lp.pthuc='F' then
            b_kghep:='T'; b_nt_phi:=FTBH_TM_NT_PHI(r_lp.so_id_ta_ps);
        else
            b_kghep:='C'; b_nt_phi:=FTBH_GHEP_NT_PHI(r_lp.so_id_ta_ps); 
        end if;
        insert into tbh_ps_pbo_temp values(
            r_lp.so_id_ta_ps,r_lp.so_id_ta_hd,r_lp.ma_dvi_hd,r_lp.so_id_hd,r_lp.so_id_dt,
            b_ngay_ht,'C',b_kghep,b_nv,'C','DT_PH_BHh',
            r_lp.ma_ta,r_lp.nha_bh,r_lp.pthuc,b_nt_phi,r_lp.phi,r_lp.thue,r_lp.hhong);
    end loop;
end if;
PTBH_TH_PS_PBO(b_ma_dvi,b_so_id_tt,b_so_id_tt,0,0,b_loi);
if b_loi is not null then return; end if;
PTBH_TH_TA_PS_TON(b_ma_dvi,b_so_id_tt,b_so_id_tt,0,0,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TA_HU:loi'; end if;
end;
/
create or replace procedure PTBH_TH_TA_BT(b_ma_dvi varchar2,b_so_id_bt number,b_loi out varchar2)
AS
    b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_id_dt number;
    b_nv varchar2(10); b_ttrang varchar2(1); b_ngay_qd number; b_ngay_xr number;
    b_so_hs varchar2(20); b_so_hd varchar2(20); b_so_id_hdB number;
    b_nt_tien varchar2(5); b_tp number:=0; b_tienH number; b_phiH number;
    dk_lh_nv pht_type.a_var; dk_bth pht_type.a_num; dk_tp pht_type.a_num; 
    a_so_id_ta pht_type.a_num; a_pthuc pht_type.a_var; a_nbh pht_type.a_var;
    a_ma_ta pht_type.a_var; a_pt pht_type.a_num; a_tien pht_type.a_num;
begin
-- Dan - Boi thuong
delete bh_bt_dota_temp_1;
select nt_tien,nv,ma_dvi_ql,so_id_hd,so_id_dt,ttrang,ngay_qd,ngay_xr,so_hs,so_hd into
    b_nt_tien,b_nv,b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_ttrang,b_ngay_qd,b_ngay_xr,b_so_hs,b_so_hd
    from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id_bt;
if b_ttrang<>'D' then b_loi:='loi:Ho so boi thuong chua duyet:loi'; return; end if;
if b_nt_tien<>'VND' then b_tp:=2; end if;
select lh_nv,sum(tien) bulk collect into dk_lh_nv,dk_bth from
    (select FBH_MA_LHNV_TAI(lh_nv) lh_nv,tien from bh_bt_hs_nv
    where ma_dvi=b_ma_dvi and so_id=b_so_id_bt and lh_nv<>' ' union
    select FBH_MA_LHNV_TAI(lh_nv) lh_nv,-tien from bh_bt_tu_pt
    where ma_dvi=b_ma_dvi and so_id_bt=b_so_id_bt and lh_nv<>' ')
    group by lh_nv having sum(tien)<>0;
for b_lp in 1..dk_lh_nv.count loop dk_tp(b_lp):=b_tp; end loop;
b_so_id_hdB:=FBH_HD_SO_ID_BS(b_ma_dvi_hd,b_so_id_hd,b_ngay_xr);
FBH_HD_DOTA_PT(b_ma_dvi_hd,b_so_id_hdB,b_so_id_dt,b_loi);
if b_loi is not null then return; end if;
FBH_HD_NV_TIEN(b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_tienH,b_phiH,b_loi);
if b_loi is not null then return; end if;
update bh_bt_dota_temp_1 set lh_nv=FBH_MA_LHNV_TAI(lh_nv);
-- Ghep
select distinct so_id_ta bulk collect into a_so_id_ta from bh_bt_dota_temp_1 where pthuc in('Q','S');
for b_lp1 in 1..a_so_id_ta.count loop
    delete tbh_ps_pbo_temp;
    select pthuc,nbhC,lh_nv,sum(tien) bulk collect into a_pthuc,a_nbh,a_ma_ta,a_tien
        from bh_bt_dota_temp_1 where so_id_ta=a_so_id_ta(b_lp1) group by pthuc,nbhC,lh_nv having sum(tien)<>0;
    for b_lp in 1..a_pthuc.count loop
        a_pt(b_lp):=round(a_tien(b_lp)*100/b_tienH,4);
    end loop;
    PTBH_TH_TA_NH_PS(b_ma_dvi,'C',b_so_id_bt,0,b_ngay_qd,b_nv,'T','DT_BTF_BHd',
        b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_so_hd,b_so_hs,
        a_so_id_ta(b_lp1),a_pthuc,a_ma_ta,a_nbh,a_pt,dk_lh_nv,dk_bth,dk_tp,a_tien,b_loi);
    if b_loi is not null then return; end if;
end loop;
-- Tam
select distinct so_id_ta bulk collect into a_so_id_ta from bh_bt_dota_temp_1 where pthuc in('C','F');
for b_lp1 in 1..a_so_id_ta.count loop
    delete tbh_ps_pbo_temp;
    select pthuc,nbhC,lh_nv,sum(tien) bulk collect into a_pthuc,a_nbh,a_ma_ta,a_tien
        from bh_bt_dota_temp_1 where so_id_ta=a_so_id_ta(b_lp1) group by pthuc,nbhC,lh_nv having sum(tien)<>0;
    for b_lp in 1..a_pthuc.count loop
        a_pt(b_lp):=round(a_tien(b_lp)*100/b_tienH,4);
    end loop;
    PTBH_TH_TA_NH_PS(b_ma_dvi,'T',b_so_id_bt,0,b_ngay_qd,b_nv,'T','DT_BTF_BHd',
        b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_so_hd,b_so_hs,
        a_so_id_ta(b_lp1),a_pthuc,a_ma_ta,a_nbh,a_pt,dk_lh_nv,dk_bth,dk_tp,a_tien,b_loi,'K');
    if b_loi is not null then return; end if;
end loop;
--
delete bh_bt_dota_temp_1;
PTBH_TH_TA_PS_TON(b_ma_dvi,b_so_id_bt,0,0,0,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TA_BT:loi'; end if;
end;
/
create or replace procedure PTBH_TH_TA_BTu(b_ma_dvi varchar2,b_so_idU number,b_loi out varchar2)
AS
    b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_id_dt number;
    b_nv varchar2(10); b_ttrang varchar2(1); b_ngay_qd number; b_ngay_xr number; b_tien number;
    b_l_ctU varchar2(1); b_ma_ntU varchar2(5); b_tlU number; b_tienU number;
    b_so_hs varchar2(20); b_so_hd varchar2(20); b_so_id_bt number; b_so_id_hdB number;
    b_nt_tien varchar2(5); b_tp number:=0; b_tienH number; b_phiH number;
    dk_lh_nv pht_type.a_var; dk_bth pht_type.a_num; dk_tp pht_type.a_num; 
    a_so_id_ta pht_type.a_num; a_pthuc pht_type.a_var; a_nbh pht_type.a_var;
    a_ma_ta pht_type.a_var; a_pt pht_type.a_num; a_tien pht_type.a_num;
begin
-- Dan - Tam ung boi thuong
delete bh_bt_dota_temp_1;
select so_id_hs,ngay_ht,l_ct,ma_nt,tien into b_so_id_bt,b_ngay_qd,b_l_ctU,b_ma_ntU,b_tienu
    from bh_bt_tu where ma_dvi=b_ma_dvi and so_id=b_so_idU;
PTBH_TH_TA_XOA(b_so_idU,b_so_id_bt,0,0,b_loi);
if b_loi is not null then return; end if;
select nv,nt_tien,ma_dvi_ql,so_id_hd,so_id_dt,so_hs,so_hd,ngay_xr into
    b_nv,b_nt_tien,b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_so_hs,b_so_hd,b_ngay_xr
    from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id_bt;
select lh_nv,sum(tien) bulk collect into dk_lh_nv,dk_bth from
    (select FBH_MA_LHNV_TAI(lh_nv) lh_nv,tien from bh_bt_hs_nv
    where ma_dvi=b_ma_dvi and so_id=b_so_id_bt and lh_nv<>' ')
    group by lh_nv having sum(tien)<>0;
if b_nt_tien<>'VND' then b_tp:=2; end if;
if b_ma_ntU<>b_nt_tien then b_tienU:=FBH_TT_TUNG_QD(b_ngay_qd,b_ma_ntU,b_tienU,b_nt_tien); end if;
b_tlU:=b_tienU/b_tien; 
if b_l_ctU='T' then b_tlU:=-b_tlU; end if;
for b_lp in 1..dk_lh_nv.count loop
    dk_tp(b_lp):=b_tp; 
    --nampb: rao vi b_tlU = null => dk_bth = null => khong phan bo duoc tai
    --dk_bth(b_lp):=round(dk_bth(b_lp)*b_tlU,b_tp);
end loop;
b_so_id_hdB:=FBH_HD_SO_ID_BS(b_ma_dvi_hd,b_so_id_hd,b_ngay_xr);
FBH_HD_DOTA_PT(b_ma_dvi_hd,b_so_id_hdB,b_so_id_dt,b_loi);
if b_loi is not null then return; end if;
FBH_HD_NV_TIEN(b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_tienH,b_phiH,b_loi);
if b_loi is not null then return; end if;
--nampb: update lh_nv
update bh_bt_dota_temp_1 set lh_nv=FBH_MA_LHNV_TAI(lh_nv);
-- Ghep
select distinct so_id_ta bulk collect into a_so_id_ta from bh_bt_dota_temp_1 where pthuc in('Q','S');
for b_lp1 in 1..a_so_id_ta.count loop
    delete tbh_ps_pbo_temp;
    select pthuc,nbhC,lh_nv,sum(tien) bulk collect into a_pthuc,a_nbh,a_ma_ta,a_tien
        from bh_bt_dota_temp_1 where so_id_ta=a_so_id_ta(b_lp1) group by pthuc,nbhC,lh_nv having sum(tien)<>0;
    for b_lp in 1..a_pthuc.count loop
        a_pt(b_lp):=round(a_tien(b_lp)*100/b_tienH,4);
    end loop;
    PTBH_TH_TA_NH_PS(b_ma_dvi,'C',b_so_idU,b_so_id_bt,b_ngay_qd,b_nv,'T','DT_BTF_BHd',
        b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_so_hd,b_so_hs,
        a_so_id_ta(b_lp1),a_pthuc,a_ma_ta,a_nbh,a_pt,dk_lh_nv,dk_bth,dk_tp,a_tien,b_loi);
    if b_loi is not null then return; end if;
end loop;
-- Tam
select distinct so_id_ta bulk collect into a_so_id_ta from bh_bt_dota_temp_1 where pthuc in('C','F');
for b_lp1 in 1..a_so_id_ta.count loop
    delete tbh_ps_pbo_temp;
    select pthuc,nbhC,lh_nv,sum(tien) bulk collect into a_pthuc,a_nbh,a_ma_ta,a_tien
        from bh_bt_dota_temp_1 where so_id_ta=a_so_id_ta(b_lp1) group by pthuc,nbhC,lh_nv having sum(tien)<>0;
    for b_lp in 1..a_pthuc.count loop
        a_pt(b_lp):=round(a_tien(b_lp)*100/b_tienH,4);
    end loop;
    PTBH_TH_TA_NH_PS(b_ma_dvi,'T',b_so_idU,b_so_id_bt,b_ngay_qd,b_nv,'T','DT_BTF_BHd',
        b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_so_hd,b_so_hs,
        a_so_id_ta(b_lp1),a_pthuc,a_ma_ta,a_nbh,a_pt,dk_lh_nv,dk_bth,dk_tp,a_tien,b_loi,'K');
    if b_loi is not null then return; end if;
end loop;
--
delete bh_bt_dota_temp_1;
PTBH_TH_TA_PS_TON(b_ma_dvi,b_so_idU,b_so_id_bt,0,0,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TA_BTu:loi'; end if;
end;
/
create or replace procedure PTBH_TH_TA_GD(b_ma_dvi varchar2,b_so_idP number,b_loi out varchar2)
AS
    b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_id_dt number;
    b_nv varchar2(10); b_ttrang varchar2(1); b_ngay_qd number; b_ngay_xr number;
    b_so_hs varchar2(20); b_so_hd varchar2(20); b_so_id_bt number; b_so_id_hdB number;
    b_nt_tien varchar2(5); b_tp number:=0; b_tienH number; b_phiH number;
    dk_lh_nv pht_type.a_var; dk_bth pht_type.a_num; dk_tp pht_type.a_num; 
    a_so_id_ta pht_type.a_num; a_pthuc pht_type.a_var; a_nbh pht_type.a_var;
    a_ma_ta pht_type.a_var; a_pt pht_type.a_num; a_tien pht_type.a_num;
begin
-- Dan - Giam dinh
delete bh_bt_dota_temp_1;
select ma_nt,nv,ma_dvi_hd,so_id_hd,so_id_dt,ttrang,ngay_qd,so_hs,so_hs_bt,so_id_bt into
    b_nt_tien,b_nv,b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_ttrang,b_ngay_qd,b_so_hd,b_so_hs,b_so_id_bt
    from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_idP;
select ngay_xr into b_ngay_xr from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id_bt;
if b_ttrang<>'D' then b_loi:='loi:Ho so giam dinh chua duyet:loi'; return; end if;
if b_nt_tien<>'VND' then b_tp:=2; end if;
select lh_nv,sum(tien) bulk collect into dk_lh_nv,dk_bth from
    (select FBH_MA_LHNV_TAI(lh_nv) lh_nv,tien from bh_bt_gd_hs_pt
    where ma_dvi=b_ma_dvi and so_id=b_so_idP and lh_nv<>' ')
    group by lh_nv having sum(tien)<>0;
for b_lp in 1..dk_lh_nv.count loop dk_tp(b_lp):=b_tp; end loop;
b_so_id_hdB:=FBH_HD_SO_ID_BS(b_ma_dvi_hd,b_so_id_hd,b_ngay_xr);
--nam
FBH_HD_DOTA_PT(b_ma_dvi_hd,b_so_id_hdB,b_so_id_dt,b_loi);
if b_loi is not null then return; end if;
FBH_HD_NV_TIEN(b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_tienH,b_phiH,b_loi);
if b_loi is not null then return; end if;
update bh_bt_dota_temp_1 set lh_nv=FBH_MA_LHNV_TAI(lh_nv);
-- Ghep
select distinct so_id_ta bulk collect into a_so_id_ta from bh_bt_dota_temp_1 where pthuc in('Q','S');
for b_lp1 in 1..a_so_id_ta.count loop
    delete tbh_ps_pbo_temp;
    select pthuc,nbhC,lh_nv,sum(tien) bulk collect into a_pthuc,a_nbh,a_ma_ta,a_tien
        from bh_bt_dota_temp_1 where so_id_ta=a_so_id_ta(b_lp1) group by pthuc,nbhC,lh_nv having sum(tien)<>0;
    for b_lp in 1..a_pthuc.count loop
        a_pt(b_lp):=round(a_tien(b_lp)*100/b_tienH,4);
    end loop;
    PTBH_TH_TA_NH_PS(b_ma_dvi,'C',b_so_idP,b_so_id_bt,b_ngay_qd,b_nv,'T','DT_BTF_GDd',
        b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_so_hd,b_so_hs,
        a_so_id_ta(b_lp1),a_pthuc,a_ma_ta,a_nbh,a_pt,dk_lh_nv,dk_bth,dk_tp,a_tien,b_loi);
    if b_loi is not null then return; end if;
end loop;
-- Tam
select distinct so_id_ta bulk collect into a_so_id_ta from bh_bt_dota_temp_1 where pthuc in('C','F');
for b_lp1 in 1..a_so_id_ta.count loop
    delete tbh_ps_pbo_temp;
    select pthuc,nbhC,lh_nv,sum(tien) bulk collect into a_pthuc,a_nbh,a_ma_ta,a_tien
        from bh_bt_dota_temp_1 where so_id_ta=a_so_id_ta(b_lp1) group by pthuc,nbhC,lh_nv having sum(tien)<>0;
    for b_lp in 1..a_pthuc.count loop
        a_pt(b_lp):=round(a_tien(b_lp)*100/b_tienH,4);
    end loop;
    PTBH_TH_TA_NH_PS(b_ma_dvi,'T',b_so_idP,b_so_id_bt,b_ngay_qd,b_nv,'T','DT_BTF_GDd',
        b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_so_hd,b_so_hs,
        a_so_id_ta(b_lp1),a_pthuc,a_ma_ta,a_nbh,a_pt,dk_lh_nv,dk_bth,dk_tp,a_tien,b_loi,'K');
    if b_loi is not null then return; end if;
end loop;
--
delete bh_bt_dota_temp_1;
PTBH_TH_TA_PS_TON(b_ma_dvi,b_so_idP,b_so_id_bt,0,0,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TA_GD:loi'; end if;
end;
/
create or replace procedure PTBH_TH_TA_GDu(b_ma_dvi varchar2,b_so_idU number,b_loi out varchar2)
AS
    b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_id_dt number;
    b_nv varchar2(10); b_ttrang varchar2(1); b_ngay_qd number; b_tien number;
    b_l_ctU varchar2(1); b_ma_ntU varchar2(5); b_tlU number; b_tienU number;
    b_so_hs varchar2(20); b_so_hd varchar2(20); b_so_id_hs number;
    b_nt_tien varchar2(5); b_tp number:=0; b_tienH number; b_phiH number;
    b_ngay_xr number; b_so_id_hdB number; b_so_id_bt number;
    dk_lh_nv pht_type.a_var; dk_bth pht_type.a_num; dk_tp pht_type.a_num; 
    a_so_id_ta pht_type.a_num; a_pthuc pht_type.a_var; a_nbh pht_type.a_var;
    a_ma_ta pht_type.a_var; a_pt pht_type.a_num; a_tien pht_type.a_num;
begin
-- Dan - Tam ung boi thuong
delete bh_bt_dota_temp_1;
select so_id_hs,ngay_ht,l_ct,ma_nt,tien into b_so_id_hs,b_ngay_qd,b_l_ctU,b_ma_ntU,b_tienU
    from bh_bt_gd_hs_tu where ma_dvi=b_ma_dvi and so_id=b_so_idU;
PTBH_TH_TA_XOA(b_so_idU,b_so_id_hs,0,0,b_loi);
if b_loi is not null then return; end if;
select nv,ma_nt,ma_dvi_hd,so_id_hd,so_id_dt,so_hs,so_hs_bt,so_id_bt into
    b_nv,b_nt_tien,b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_so_hd,b_so_hs,b_so_id_bt
    from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id_hs;
select ngay_xr into b_ngay_xr from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id_bt;
select lh_nv,sum(tien) bulk collect into dk_lh_nv,dk_bth from
    (select FBH_MA_LHNV_TAI(lh_nv) lh_nv,tien from bh_bt_gd_hs_pt
    where ma_dvi=b_ma_dvi and so_id=b_so_idU and lh_nv<>' ')
    group by lh_nv having sum(tien)<>0;
if b_nt_tien<>'VND' then b_tp:=2; end if;
if b_ma_ntU<>b_nt_tien then b_tienU:=FBH_TT_TUNG_QD(b_ngay_qd,b_ma_ntU,b_tienU,b_nt_tien); end if;
b_tlU:=b_tienU/b_tien; 
if b_l_ctU='T' then b_tlU:=-b_tlU; end if;
for b_lp in 1..dk_lh_nv.count loop
    dk_tp(b_lp):=b_tp; 
    --nampb: rao vi b_tlU = null => dk_bth = null => khong phan bo duoc tai
    --dk_bth(b_lp):=round(dk_bth(b_lp)*b_tlU,b_tp);
end loop;
b_so_id_hdB:=FBH_HD_SO_ID_BS(b_ma_dvi_hd,b_so_id_hd,b_ngay_xr);
FBH_HD_DOTA_PT(b_ma_dvi_hd,b_so_id_hdB,b_so_id_dt,b_loi);
if b_loi is not null then return; end if;
FBH_HD_NV_TIEN(b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_tienH,b_phiH,b_loi);
if b_loi is not null then return; end if;
--nampb: update lh_nv
update bh_bt_dota_temp_1 set lh_nv=FBH_MA_LHNV_TAI(lh_nv);
-- Ghep
select distinct so_id_ta bulk collect into a_so_id_ta from bh_bt_dota_temp_1 where pthuc in('Q','S');
for b_lp1 in 1..a_so_id_ta.count loop
    delete tbh_ps_pbo_temp;
    select pthuc,nbhC,lh_nv,sum(tien) bulk collect into a_pthuc,a_nbh,a_ma_ta,a_tien
        from bh_bt_dota_temp_1 where so_id_ta=a_so_id_ta(b_lp1) group by pthuc,nbhC,lh_nv having sum(tien)<>0;
    for b_lp in 1..a_pthuc.count loop
        a_pt(b_lp):=round(a_tien(b_lp)*100/b_tienH,4);
    end loop;
    PTBH_TH_TA_NH_PS(b_ma_dvi,'C',b_so_idU,b_so_id_hs,b_ngay_qd,b_nv,'T','DT_BTF_GDd',
        b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_so_hd,b_so_hs,
        a_so_id_ta(b_lp1),a_pthuc,a_ma_ta,a_nbh,a_pt,dk_lh_nv,dk_bth,dk_tp,a_tien,b_loi);
    if b_loi is not null then return; end if;
end loop;
-- Tam
select distinct so_id_ta bulk collect into a_so_id_ta from bh_bt_dota_temp_1 where pthuc in('C','F');
for b_lp1 in 1..a_so_id_ta.count loop
    delete tbh_ps_pbo_temp;
    select pthuc,nbhC,lh_nv,sum(tien) bulk collect into a_pthuc,a_nbh,a_ma_ta,a_tien
        from bh_bt_dota_temp_1 where so_id_ta=a_so_id_ta(b_lp1) group by pthuc,nbhC,lh_nv having sum(tien)<>0;
    for b_lp in 1..a_pthuc.count loop
        a_pt(b_lp):=round(a_tien(b_lp)*100/b_tienH,4);
    end loop;
    PTBH_TH_TA_NH_PS(b_ma_dvi,'T',b_so_idU,b_so_id_hs,b_ngay_qd,b_nv,'T','DT_BTF_GDd',
        b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_so_hd,b_so_hs,
        a_so_id_ta(b_lp1),a_pthuc,a_ma_ta,a_nbh,a_pt,dk_lh_nv,dk_bth,dk_tp,a_tien,b_loi,'K');
    if b_loi is not null then return; end if;
end loop;
--
delete bh_bt_dota_temp_1;
PTBH_TH_TA_PS_TON(b_ma_dvi,b_so_id_hs,b_so_id_hs,0,0,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TA_GDu:loi'; end if;
end;
/
create or replace procedure PTBH_TH_TA_TBA(b_ma_dvi varchar2,b_so_idP number,b_loi out varchar2)
AS
    b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_id_dt number;
    b_nv varchar2(10); b_ttrang varchar2(1); b_ngay_qd number; b_ngay_xr number;
    b_so_hs varchar2(20); b_so_hd varchar2(20); b_so_id_bt number; b_so_id_hdB number;
    b_nt_tien varchar2(5); b_tp number:=0; b_tienH number; b_phiH number;
    dk_lh_nv pht_type.a_var; dk_bth pht_type.a_num; dk_tp pht_type.a_num; 
    a_so_id_ta pht_type.a_num; a_pthuc pht_type.a_var; a_nbh pht_type.a_var;
    a_ma_ta pht_type.a_var; a_pt pht_type.a_num; a_tien pht_type.a_num;
begin
-- Dan - Doi TBA
delete bh_bt_dota_temp_1;
select nt_tra,nv,ma_dvi_ql,so_id_hd,so_id_dt,ngay_ht,so_hs,so_ct,so_id_bt into
    b_nt_tien,b_nv,b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_ngay_qd,b_so_hs,b_so_hd,b_so_id_bt
    from bh_bt_tba where ma_dvi=b_ma_dvi and so_id=b_so_idP;
select ngay_xr into b_ngay_xr from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id_bt;
if b_nt_tien<>'VND' then b_tp:=2; end if;
--nam select FBH_MA_LHNV_TAI(lh_nv) lh_nv,tien
select lh_nv,sum(tien) bulk collect into dk_lh_nv,dk_bth from
    (select FBH_MA_LHNV_TAI(lh_nv) lh_nv,tien from 
    bh_bt_tba_pt where ma_dvi=b_ma_dvi and so_id=b_so_idP and lh_nv<>' ')
    group by lh_nv having sum(tien)<>0;
for b_lp in 1..dk_lh_nv.count loop dk_tp(b_lp):=b_tp; end loop;
b_so_id_hdB:=FBH_HD_SO_ID_BS(b_ma_dvi_hd,b_so_id_hd,b_ngay_xr);
--nam
FBH_HD_DOTA_PT(b_ma_dvi_hd,b_so_id_hdB,b_so_id_dt,b_loi);
if b_loi is not null then return; end if;
FBH_HD_NV_TIEN(b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_tienH,b_phiH,b_loi);
if b_loi is not null then return; end if;
update bh_bt_dota_temp_1 set lh_nv=FBH_MA_LHNV_TAI(lh_nv);
-- Ghep
select distinct so_id_ta bulk collect into a_so_id_ta from bh_bt_dota_temp_1 where pthuc in('Q','S');
for b_lp1 in 1..a_so_id_ta.count loop
    delete tbh_ps_pbo_temp;
    select pthuc,nbhC,lh_nv,sum(tien) bulk collect into a_pthuc,a_nbh,a_ma_ta,a_tien
        from bh_bt_dota_temp_1 where so_id_ta=a_so_id_ta(b_lp1) group by pthuc,nbhC,lh_nv having sum(tien)<>0;
    for b_lp in 1..a_pthuc.count loop
        a_pt(b_lp):=round(a_tien(b_lp)*100/b_tienH,4);
    end loop;
    PTBH_TH_TA_NH_PS(b_ma_dvi,'C',b_so_idP,b_so_id_bt,b_ngay_qd,b_nv,'T','CH_BTF_TBd',
        b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_so_hd,b_so_hs,
        a_so_id_ta(b_lp1),a_pthuc,a_ma_ta,a_nbh,a_pt,dk_lh_nv,dk_bth,dk_tp,a_tien,b_loi);
    if b_loi is not null then return; end if;
end loop;
-- Tam
select distinct so_id_ta bulk collect into a_so_id_ta from bh_bt_dota_temp_1 where pthuc in('C','F');
for b_lp1 in 1..a_so_id_ta.count loop
    delete tbh_ps_pbo_temp;
    select pthuc,nbhC,lh_nv,sum(tien) bulk collect into a_pthuc,a_nbh,a_ma_ta,a_tien
        from bh_bt_dota_temp_1 where so_id_ta=a_so_id_ta(b_lp1) group by pthuc,nbhC,lh_nv having sum(tien)<>0;
    for b_lp in 1..a_pthuc.count loop
        a_pt(b_lp):=round(a_tien(b_lp)*100/b_tienH,4);
    end loop;
    PTBH_TH_TA_NH_PS(b_ma_dvi,'T',b_so_idP,b_so_id_bt,b_ngay_qd,b_nv,'T','CH_BTF_TBd',
        b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_so_hd,b_so_hs,
        a_so_id_ta(b_lp1),a_pthuc,a_ma_ta,a_nbh,a_pt,dk_lh_nv,dk_bth,dk_tp,a_tien,b_loi,'K');
    if b_loi is not null then return; end if;
end loop;
--
delete bh_bt_dota_temp_1;
PTBH_TH_TA_PS_TON(b_ma_dvi,b_so_idP,b_so_id_bt,0,0,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TA_TBA:loi'; end if;
end;
/
create or replace procedure PTBH_TH_TA_THOI(b_ma_dvi varchar2,b_so_idP number,b_loi out varchar2)
AS
    b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_id_dt number;
    b_nv varchar2(10); b_ttrang varchar2(1); b_ngay_qd number; b_ngay_xr number;
    b_so_hs varchar2(20); b_so_hd varchar2(20); b_so_id_bt number; b_so_id_hdB number;
    b_nt_tien varchar2(5); b_tp number:=0; b_tienH number; b_phiH number;
    dk_lh_nv pht_type.a_var; dk_bth pht_type.a_num; dk_tp pht_type.a_num; 
    a_so_id_ta pht_type.a_num; a_pthuc pht_type.a_var; a_nbh pht_type.a_var;
    a_ma_ta pht_type.a_var; a_pt pht_type.a_num; a_tien pht_type.a_num;
begin
-- Dan - Thu hoi
delete bh_bt_dota_temp_1;
select ma_nt,nv,ma_dvi_ql,so_id_hd,so_id_dt,ngay_ht,so_hs,so_ct,so_id_hs into
    b_nt_tien,b_nv,b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_ngay_qd,b_so_hs,b_so_hd,b_so_id_bt
    from bh_bt_thoi where ma_dvi=b_ma_dvi and so_id=b_so_idP;
select ngay_xr into b_ngay_xr from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id_bt;
if b_nt_tien<>'VND' then b_tp:=2; end if;
--nam select FBH_MA_LHNV_TAI(lh_nv) lh_nv,tien
select lh_nv,sum(tien) bulk collect into dk_lh_nv,dk_bth from
    (select FBH_MA_LHNV_TAI(lh_nv) lh_nv,tien from 
    bh_bt_thoi_pt where ma_dvi=b_ma_dvi and so_id=b_so_idP and lh_nv<>' ')
    group by lh_nv having sum(tien)<>0;
for b_lp in 1..dk_lh_nv.count loop dk_tp(b_lp):=b_tp; end loop;
b_so_id_hdB:=FBH_HD_SO_ID_BS(b_ma_dvi_hd,b_so_id_hd,b_ngay_xr);
--nam
FBH_HD_DOTA_PT(b_ma_dvi_hd,b_so_id_hdB,b_so_id_dt,b_loi);
if b_loi is not null then return; end if;
FBH_HD_NV_TIEN(b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_tienH,b_phiH,b_loi);
if b_loi is not null then return; end if;
update bh_bt_dota_temp_1 set lh_nv=FBH_MA_LHNV_TAI(lh_nv);
-- Ghep
select distinct so_id_ta bulk collect into a_so_id_ta from bh_bt_dota_temp_1 where pthuc in('Q','S');
for b_lp1 in 1..a_so_id_ta.count loop
    delete tbh_ps_pbo_temp;
    select pthuc,nbhC,lh_nv,sum(tien) bulk collect into a_pthuc,a_nbh,a_ma_ta,a_tien
        from bh_bt_dota_temp_1 where so_id_ta=a_so_id_ta(b_lp1) group by pthuc,nbhC,lh_nv having sum(tien)<>0;
    for b_lp in 1..a_pthuc.count loop
        a_pt(b_lp):=round(a_tien(b_lp)*100/b_tienH,4);
    end loop;
    PTBH_TH_TA_NH_PS(b_ma_dvi,'C',b_so_idP,b_so_id_bt,b_ngay_qd,b_nv,'T','CH_BTF_THd',
        b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_so_hd,b_so_hs,
        a_so_id_ta(b_lp1),a_pthuc,a_ma_ta,a_nbh,a_pt,dk_lh_nv,dk_bth,dk_tp,a_tien,b_loi);
    if b_loi is not null then return; end if;
end loop;
-- Tam
select distinct so_id_ta bulk collect into a_so_id_ta from bh_bt_dota_temp_1 where pthuc in('C','F');
for b_lp1 in 1..a_so_id_ta.count loop
    delete tbh_ps_pbo_temp;
    select pthuc,nbhC,lh_nv,sum(tien) bulk collect into a_pthuc,a_nbh,a_ma_ta,a_tien
        from bh_bt_dota_temp_1 where so_id_ta=a_so_id_ta(b_lp1) group by pthuc,nbhC,lh_nv having sum(tien)<>0;
    for b_lp in 1..a_pthuc.count loop
        a_pt(b_lp):=round(a_tien(b_lp)*100/b_tienH,4);
    end loop;
    PTBH_TH_TA_NH_PS(b_ma_dvi,'T',b_so_idP,b_so_id_bt,b_ngay_qd,b_nv,'T','CH_BTF_THd',
        b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_so_hd,b_so_hs,
        a_so_id_ta(b_lp1),a_pthuc,a_ma_ta,a_nbh,a_pt,dk_lh_nv,dk_bth,dk_tp,a_tien,b_loi,'K');
    if b_loi is not null then return; end if;
end loop;
--
delete bh_bt_dota_temp_1;
PTBH_TH_TA_PS_TON(b_ma_dvi,b_so_idP,b_so_id_bt,0,0,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TA_THOI:loi'; end if;
end;
/
create or replace procedure PTBH_TH_TA_CP(b_ma_dvi varchar2,b_so_id_tt number,b_loi out varchar2)
AS
    b_i1 number; b_dvi_ta varchar2(10); b_ma_dvi_hd varchar2(10); b_so_id_hd number:=0;  b_so_id_dt number:=0;
    b_nv varchar2(10); b_tien number; b_ngay_ht number; b_so_hd varchar2(50); b_so_ps varchar2(50);
    b_kieu varchar2(1); b_kghep varchar2(1); b_ktam varchar2(1); b_nha_bh varchar2(20); 
    a_so_id_ta pht_type.a_num; a_pthuc pht_type.a_var; a_ma_ta pht_type.a_var;
    a_nha_bh pht_type.a_var; a_pt pht_type.a_num; a_tien pht_type.a_num; a_phi pht_type.a_num;
    a_so_id_dt pht_type.a_num; a_ma_ta_n pht_type.a_var; a_ma_nt pht_type.a_var; a_tp pht_type.a_num;
begin
-- Dan - Tap hop phat sinh thu, chi khac ve goc
b_dvi_ta:=FTBH_DVI_TA;
if b_dvi_ta is null then return; end if;
PTBH_TH_TA_XOA(b_so_id_tt,0,0,0,b_loi);
if b_loi is not null then return; end if;
b_loi:='loi:Loi xu ly tai chi khac:loi';
select ngay_ht,so_hd,so_id_hd,so_ct into b_ngay_ht,b_so_hd,b_so_id_hd,b_so_ps
    from bh_cp where ma_dvi=b_ma_dvi and so_id=b_so_id_tt;
if b_so_id_hd=0 then b_loi:=''; return; end if;
select ma_dvi,nv into b_ma_dvi_hd,b_nv from bh_hd_goc where so_id=b_so_id_hd;
b_nv:=FBH_HD_NV(b_ma_dvi,b_so_id_hd);
if b_kieu in ('V','N') then b_kghep:='D'; b_ktam:='B'; else b_kghep:='C'; b_ktam:='T'; end if;
select distinct so_id_dt bulk collect into a_so_id_dt from bh_cp_pt where ma_dvi=b_ma_dvi and so_id=b_so_id_tt;
for b_lp in 1..a_so_id_dt.count loop
    delete tbh_ps_temp;
    insert into tbh_ps_temp select FBH_MA_LHNV_TAI(lh_nv),lh_nv,ma_nt,sum(tien) from bh_cp_pt where
        ma_dvi=b_ma_dvi and so_id=b_so_id_tt and so_id_dt=a_so_id_dt(b_lp) group by lh_nv,ma_nt;
    PTBH_TH_TA_TEMP(a_ma_ta_n,a_ma_nt,a_tien,a_tp);
    -- GHEP
    PTBH_GHEP_SO_ID_TA_DT(b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,a_so_id_ta,b_ngay_ht);
    for b_lp1 in 1..a_so_id_ta.count loop
        delete tbh_ps_pbo_temp;
        PTBH_GHEP_SO_ID_TA_TL(b_dvi_ta,a_so_id_ta(b_lp1),a_pthuc,a_ma_ta,a_nha_bh,a_pt,a_phi,b_ngay_ht);
        PTBH_TH_TA_NH_PS(b_ma_dvi,b_kghep,b_so_id_tt,b_so_id_tt,b_ngay_ht,b_nv,'T','KH_HD_CPd',
            b_ma_dvi_hd,b_so_id_hd,a_so_id_dt(b_lp),b_so_hd,b_so_ps,
            a_so_id_ta(b_lp1),a_pthuc,a_ma_ta,a_nha_bh,a_pt,a_ma_ta_n,a_tien,a_tp,a_phi,b_loi);
        if b_loi is not null then return; end if;
    end loop;
    -- TAM
    PTBH_TM_SO_ID_TA_DT(b_ma_dvi_hd,b_so_id_hd,a_so_id_dt(b_lp),b_ngay_ht,a_so_id_ta);
    for b_lp1 in 1..a_so_id_ta.count loop
        delete tbh_ps_pbo_temp;
        PTBH_TM_SO_ID_TA_TL(a_so_id_ta(b_lp1),a_pthuc,a_ma_ta,a_nha_bh,a_pt,a_phi,b_ngay_ht);
        PTBH_TH_TA_NH_PS(b_ma_dvi,b_ktam,b_so_id_tt,b_so_id_tt,b_ngay_ht,b_nv,'T','KH_HD_CPd',
            b_ma_dvi_hd,b_so_id_hd,a_so_id_dt(b_lp),b_so_hd,b_so_ps,
            a_so_id_ta(b_lp1),a_pthuc,a_ma_ta,a_nha_bh,a_pt,a_ma_ta_n,a_tien,a_tp,a_phi,b_loi,'K');
        if b_loi is not null then return; end if;
    end loop;
end loop;
PTBH_TH_TA_PS_TON(b_ma_dvi,b_so_id_tt,b_so_id_tt,0,0,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TA_CP:loi'; end if;
end;
/
create or replace procedure PTBH_TH_TA_CPT(b_ma_dvi varchar2,b_so_id_tt number,b_loi out varchar2)
AS
    b_i1 number; b_dvi_ta varchar2(10); b_ma_dvi_hd varchar2(10); b_so_id_hd number:=0;
    b_so_id_ta_d number; b_l_ct varchar2(10); b_nv varchar2(10); b_tien number;
    b_ngay_ht number; b_so_hd varchar2(50); b_dvi varchar2(20); b_so_ps varchar2(50);
    b_kieu varchar2(1); b_kghep varchar2(1); b_ktam varchar2(1); b_nha_bh varchar2(20);
    a_so_id_ta pht_type.a_num; a_pthuc pht_type.a_var; a_ma_ta pht_type.a_var;
    a_nha_bh pht_type.a_var; a_pt pht_type.a_num; a_tien pht_type.a_num; a_phi pht_type.a_num;
    a_so_id_dt pht_type.a_num; a_ma_ta_n pht_type.a_var; a_ma_nt pht_type.a_var; a_tp pht_type.a_num;
begin
-- Dan - Tap hop phat sinh thu, chi khac ve tai
b_dvi_ta:=FTBH_DVI_TA;
if b_dvi_ta is null then return; end if;
PTBH_TH_TA_XOA(b_so_id_tt,0,0,0,b_loi);
if b_loi is not null then return; end if;
b_loi:='loi:Loi xu ly tai chi khac:loi';
select ngay_ht,dvi,so_hd,so_ct,l_ct into b_ngay_ht,b_dvi,b_so_hd,b_so_ps,b_l_ct
    from tbh_cp where ma_dvi=b_ma_dvi and so_id=b_so_id_tt;
if trim(b_so_hd) is not null then
    select nvl(min(so_id_hd),0) into b_so_id_hd from tbh_cp_pt where ma_dvi=b_ma_dvi and so_id=b_so_id_tt;
end if;
if b_so_id_hd=0 then b_loi:=''; return; end if;
select ma_dvi,nv into b_ma_dvi_hd,b_nv from bh_hd_goc where so_id=b_so_id_hd;
b_l_ct:='CPT_'||substr(b_l_ct,0,1); b_kieu:=FBH_HD_KIEU_HD(b_dvi,b_so_id_hd,'D');
if b_kieu in ('V','N') then b_kghep:='D'; b_ktam:='B'; else b_kghep:='C'; b_ktam:='T'; end if;
select distinct so_id_dt bulk collect into a_so_id_dt from tbh_cp_pt where ma_dvi=b_ma_dvi and so_id=b_so_id_tt;
for b_lp in 1..a_so_id_dt.count loop
    delete tbh_ps_temp;
    insert into tbh_ps_temp select '',lh_nv,ma_nt,sum(tien) from tbh_cp_pt where
        ma_dvi=b_ma_dvi and so_id=b_so_id_tt and so_id_dt=a_so_id_dt(b_lp) group by lh_nv,ma_nt;
    update tbh_ps_temp set ma_ta=FBH_MA_LHNV_TAI(lh_nv);
    PTBH_TH_TA_TEMP(a_ma_ta_n,a_ma_nt,a_tien,a_tp);
    -- Ghep
    PTBH_GHEP_SO_ID_TA_DT(b_ma_dvi_hd,b_so_id_hd,a_so_id_dt(b_lp),a_so_id_ta);
    for b_lp1 in 1..a_so_id_ta.count loop
        delete tbh_ps_pbo_temp;
        PTBH_GHEP_SO_ID_TA_TL(b_dvi_ta,a_so_id_ta(b_lp1),a_pthuc,a_ma_ta,a_nha_bh,a_pt,a_phi,b_ngay_ht);
        PTBH_TH_TA_NH_PS(b_ma_dvi,b_kghep,b_so_id_tt,b_so_id_tt,b_ngay_ht,b_nv,'G',b_l_ct,
            b_ma_dvi_hd,b_so_id_hd,a_so_id_dt(b_lp),b_so_hd,b_so_ps,
            a_so_id_ta(b_lp1),a_pthuc,a_ma_ta,a_nha_bh,a_pt,a_ma_ta_n,a_tien,a_tp,a_phi,b_loi);
        if b_loi is not null then return; end if;
    end loop;
    -- TAM
    PTBH_TM_SO_ID_TA_DT(b_ma_dvi_hd,b_so_id_hd,a_so_id_dt(b_lp),0,a_so_id_ta);
    for b_lp1 in 1..a_so_id_ta.count loop
        delete tbh_ps_pbo_temp;
        PTBH_TM_SO_ID_TA_TL(a_so_id_ta(b_lp1),a_pthuc,a_ma_ta,a_nha_bh,a_pt,a_phi);
        PTBH_TH_TA_NH_PS(b_ma_dvi,b_ktam,b_so_id_tt,b_so_id_tt,b_ngay_ht,b_nv,'G',b_l_ct,
            b_ma_dvi_hd,b_so_id_hd,a_so_id_dt(b_lp),b_so_hd,b_so_ps,
            a_so_id_ta(b_lp1),a_pthuc,a_ma_ta,a_nha_bh,a_pt,a_ma_ta_n,a_tien,a_tp,a_phi,b_loi,'K');
        if b_loi is not null then return; end if;
    end loop;
end loop;
PTBH_TH_TA_PS_TON(b_ma_dvi,b_so_id_tt,b_so_id_tt,0,0,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TA_CPT:loi'; end if;
end;
/
create or replace procedure PTBH_TH_TA_NH(
    b_ma_dvi varchar2,b_kieu varchar2,b_so_id number,b_loi out varchar2)
AS
    b_kieu_hd varchar2(1);
begin
-- Dan - Tap hop phat sinh tai bao hiem
delete tbh_ps_tt_temp; delete tbh_ps_tt_temp1;
if b_kieu='C' then
    for r_lp in (select distinct ma_dvi,so_id from tbh_ps_tt_temp) loop
        insert into tbh_ps_tt_temp1
            select distinct ma_dvi,so_id_tt from bh_hd_goc_tthd where ma_dvi=r_lp.ma_dvi and so_id=r_lp.so_id;
    end loop;
    for r_lp in (select distinct ma_dvi,so_id from tbh_ps_tt_temp1) loop
        PTBH_TH_TA_PHI_GHEP(r_lp.ma_dvi,r_lp.so_id,b_loi);
        if b_loi is not null then return; end if;
    end loop;
else
    for r_lp in (select distinct ma_dvi,so_id from tbh_ps_tt_temp) loop
        insert into tbh_ps_tt_temp1
            select distinct ma_dvi,so_id_tt from bh_hd_goc_tthd where ma_dvi=r_lp.ma_dvi and so_id=r_lp.so_id;
    end loop;
    for r_lp in (select distinct ma_dvi,so_id from tbh_ps_tt_temp1) loop
        PTBH_TH_TA_PHI_TM(r_lp.ma_dvi,r_lp.so_id,b_loi);
        if b_loi is not null then return; end if;
    end loop;
end if;
/* Tam che
delete tbh_ps_tt_temp1;
for r_lp in (select distinct ma_dvi,so_id from tbh_ps_tt_temp) loop
    insert into tbh_ps_tt_temp1
        select distinct ma_dvi,so_id_hh from bh_hd_goc_hh_ct where ma_dvi=r_lp.ma_dvi and so_id=r_lp.so_id;
end loop;
for r_lp in (select distinct ma_dvi,so_id from tbh_ps_tt_temp1) loop
    if FTBH_TH_TA_XLY(r_lp.ma_dvi,r_lp.so_id)=0 then
        PTBH_TH_TA_HH(r_lp.ma_dvi,r_lp.so_id,b_loi);
    end if;
end loop;
delete tbh_ps_tt_temp1;
for r_lp in (select distinct ma_dvi,so_id from tbh_ps_tt_temp) loop
    insert into tbh_ps_tt_temp1
        select distinct ma_dvi,so_id_tr from bh_tpa_hd where ma_dvi=r_lp.ma_dvi and so_id=r_lp.so_id;
end loop;
for r_lp in (select distinct ma_dvi,so_id from tbh_ps_tt_temp1) loop
    if FTBH_TH_TA_XLY(r_lp.ma_dvi,r_lp.so_id)=0 then
        PTBH_TH_TA_TPA(r_lp.ma_dvi,r_lp.so_id,b_loi);
    end if;
end loop;
*/
delete tbh_ps_tt_temp1;
for r_lp in (select distinct ma_dvi,so_id from tbh_ps_tt_temp) loop
    insert into tbh_ps_tt_temp1
        select distinct ma_dvi,so_id from bh_hd_goc_hu where ma_dvi=r_lp.ma_dvi and so_id=r_lp.so_id;
end loop;
for r_lp in(select distinct ma_dvi,so_id from tbh_ps_tt_temp1) loop
    if FTBH_TH_TA_XLY(r_lp.ma_dvi,r_lp.so_id)=0 then
        PTBH_TH_TA_HU(r_lp.ma_dvi,r_lp.so_id,b_loi);
        if b_loi is not null then return; end if;
    end if;
end loop;
delete tbh_ps_tt_temp1;
for r_lp in (select distinct ma_dvi,so_id from tbh_ps_tt_temp) loop
    insert into tbh_ps_tt_temp1
        select distinct ma_dvi,so_id from bh_bt_hs where ma_dvi_ql=r_lp.ma_dvi and so_id_hd=r_lp.so_id and ttrang='D';
end loop;
for r_lp in(select distinct ma_dvi,so_id from tbh_ps_tt_temp1) loop
    for r_lp1 in(select distinct so_id from bh_bt_gd_hs_tu where ma_dvi=r_lp.ma_dvi and FBH_BT_GD_HS_TU_ID_BT(ma_dvi,so_id)=r_lp.so_id) loop
        if FTBH_TH_TA_XLY(r_lp.ma_dvi,r_lp1.so_id)=0 then
            PTBH_TH_TA_GDu(r_lp.ma_dvi,r_lp1.so_id,b_loi);
            if b_loi is not null then return; end if;
        end if;
    end loop;
    for r_lp1 in(select distinct so_id from bh_bt_gd_hs where ma_dvi=r_lp.ma_dvi and so_id_bt=r_lp.so_id) loop
        if FTBH_TH_TA_XLY(r_lp.ma_dvi,r_lp1.so_id)=0 then
            PTBH_TH_TA_GD(r_lp.ma_dvi,r_lp1.so_id,b_loi);
            if b_loi is not null then return; end if;
        end if;
    end loop;
    for r_lp1 in(select distinct so_id from bh_bt_tu where ma_dvi=r_lp.ma_dvi and so_id_hs=r_lp.so_id) loop
        if FTBH_TH_TA_XLY(r_lp.ma_dvi,r_lp1.so_id)=0 then
            PTBH_TH_TA_BTU(r_lp.ma_dvi,r_lp1.so_id,b_loi);
            if b_loi is not null then return; end if;
        end if;
    end loop;
    if FTBH_TH_TA_XLY(r_lp.ma_dvi,r_lp.so_id)=0 then
        PTBH_TH_TA_BT(r_lp.ma_dvi,r_lp.so_id,b_loi);
        if b_loi is not null then return; end if;
        if FBH_BT_TXT_NV(r_lp.ma_dvi,r_lp.so_id,'xol')='C' then
            PTBH_TH_TA_XOL_BT(r_lp.ma_dvi,r_lp.so_id,b_loi);
            if b_loi is not null then return; end if;
        end if;
    end if;
    for r_lp1 in(select distinct so_id from bh_bt_thoi where ma_dvi=r_lp.ma_dvi and so_id_hs=r_lp.so_id) loop
        if FTBH_TH_TA_XLY(r_lp.ma_dvi,r_lp1.so_id)=0 then
            PTBH_TH_TA_THOI(r_lp.ma_dvi,r_lp1.so_id,b_loi);
            if b_loi is not null then return; end if;
        end if;
    end loop;
    for r_lp1 in(select distinct so_id from bh_bt_ntba_tt where ma_dvi=r_lp.ma_dvi and so_id_hs=r_lp.so_id) loop
        if FTBH_TH_TA_XLY(r_lp.ma_dvi,r_lp1.so_id)=0 then
            PTBH_TH_TA_TBA(r_lp.ma_dvi,r_lp1.so_id,b_loi);
            if b_loi is not null then return; end if;
        end if;
    end loop;
end loop;
delete tbh_ps_tt_temp1;
for r_lp in (select distinct ma_dvi,so_id from tbh_ps_tt_temp) loop
    insert into tbh_ps_tt_temp1
        select distinct ma_dvi,so_id from bh_cp where ma_dvi=r_lp.ma_dvi and so_id_hd=r_lp.so_id;
end loop;
for r_lp in(select distinct ma_dvi,so_id from tbh_ps_tt_temp1) loop
    if FTBH_TH_TA_XLY(r_lp.ma_dvi,r_lp.so_id)=0 then
        PTBH_TH_TA_CP(r_lp.ma_dvi,r_lp.so_id,b_loi);
        if b_loi is not null then return; end if;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TA_NH:loi'; end if;
end;
/
create or replace procedure PTBH_TH_TA_XOA(
    b_so_id number,b_so_id_nv number,b_so_id_hd number,b_so_id_dt number,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Xoa phat sinh tai
select nvl(max(so_id_xl),0) into b_i1 from tbh_ps where
    so_id=b_so_id and b_so_id_nv in(0,so_id_nv) and b_so_id_hd in(0,so_id_hd) and b_so_id_dt in(0,so_id_dt);
if b_i1<>0 then b_loi:='loi:Khong sua, xoa so lieu da xu ly phat sinh tai:loi'; return; end if;
delete tbh_ps_ton where so_id=b_so_id and b_so_id_nv in(0,so_id_nv) and
    b_so_id_hd in(0,so_id_hd) and b_so_id_dt in(0,so_id_dt);
delete tbh_ps_pbo where so_id=b_so_id and b_so_id_nv in(0,so_id_nv) and
    b_so_id_hd in(0,so_id_hd) and b_so_id_dt in(0,so_id_dt);
delete tbh_ps where so_id=b_so_id and b_so_id_nv in(0,so_id_nv) and
    b_so_id_hd in(0,so_id_hd) and b_so_id_dt in(0,so_id_dt);
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TA_XOA:loi'; end if;
end;
/
