create or replace function FTBH_XOL_SC_TON(
    b_so_id number,b_ma_ta varchar2,b_tu number,b_ngay number,b_vu number:=0) return number
AS
    b_kq number:=0; b_ngayM number; b_vuT number; b_tienT number;
begin
-- Dan - Tra so ton
select nvl(max(ngay),0) into b_ngayM from tbh_xol_sc where so_id=b_so_id and lh_nv=b_ma_ta and tu=b_tu and ngay<=b_ngay; 
if b_ngayM<>0 then
    select vuT,tienT into b_vuT,b_tienT from tbh_xol_sc where so_id=b_so_id and lh_nv=b_ma_ta and tu=b_tu and ngay=b_ngayM;
    if b_vuT+b_vu>0 then b_kq:=b_tienT; end if;
end if;
return b_kq;
end;
/
create or replace function FTBH_XOL_SC_PH(b_so_id number,b_tu number,b_ngay number) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number;
begin
-- Dan - Tra da phuc hoi va ma_ta=' '
select count(*) into b_i1 from tbh_xol_sc where so_id=b_so_id and lh_nv=' ' and tu=b_tu and ngay<=b_ngay and lan<0; 
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PTBH_TH_TA_XOL_TIEN(
    b_ma_dvi varchar2,b_so_id_bt number,
    bth_ma_ta out pht_type.a_var,bth_tien out pht_type.a_num,bth_tc out pht_type.a_var,b_loi out varchar2)
AS
    b_i1 number; b_ngay_ht number; b_ngay_xr number; b_ngay_qd number; b_ma_nt varchar2(5);
    b_so_id_dt number; b_so_id_hd number; b_nv varchar2(10); b_ma_dvi_ql varchar2(10);
    b_bth number:=0; b_gd number:=0; b_kt number:=0;
    gd_ma_ta pht_type.a_var; gd_ma_nt pht_type.a_var;
    gd_tien pht_type.a_num; gd_tc pht_type.a_var;
    a_tl_ta pht_type.a_num; a_ma_ta pht_type.a_var;
    a_ma_dviX pht_type.a_var; a_so_idX pht_type.a_num; a_so_id_dtX pht_type.a_num;
begin
-- Dan - Tap hop phat sinh boi thuong tai XOL
delete tbh_ghep_nv_temp;
select nv,ma_dvi_ql,so_id_hd,so_id_dt,ngay_ht,ngay_xr,ngay_qd,nt_tien into
    b_nv,b_ma_dvi_ql,b_so_id_hd,b_so_id_dt,b_ngay_ht,b_ngay_xr,b_ngay_qd,b_ma_nt
    from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id_bt;
select ma_ta,sum(tien) BULK COLLECT into bth_ma_ta,bth_tien from
    (select FBH_MA_LHNV_TAI(lh_nv) ma_ta,tien from bh_bt_hs_nv where
    ma_dvi=b_ma_dvi and so_id=b_so_id_bt and lh_nv<>' ') group by ma_ta;
for b_lp in 1..bth_ma_ta.count loop
    select nvl(max(FBH_MA_LHNV_LOAI(lh_nv)),' ') into bth_tc(b_lp) from bh_bt_hs_nv where
        ma_dvi=b_ma_dvi and so_id=b_so_id_bt and lh_nv<>' ' and FBH_MA_LHNV_TAI(lh_nv)=bth_ma_ta(b_lp);
end loop;
if b_ma_nt<>'VND' then
    b_i1:=FBH_TT_TRA_TGTT(b_ngay_qd,b_ma_nt);
    for b_lp in 1..bth_ma_ta.count loop
        bth_tien(b_lp):=round(bth_tien(b_lp)*b_i1,2);
    end loop;
end if;
select ma_ta,ma_nt,sum(tien) BULK COLLECT into gd_ma_ta,gd_ma_nt,gd_tien from
    (select FBH_MA_LHNV_TAI(lh_nv) ma_ta,ma_nt,tien from bh_bt_gd_hs_pt where
    ma_dvi=b_ma_dvi and so_id=b_so_id_bt and lh_nv<>' ' and ngay_qd<=b_ngay_qd) group by ma_ta,ma_nt;
for b_lp in 1..gd_ma_ta.count loop
    select nvl(max(FBH_MA_LHNV_LOAI(lh_nv)),' ') into gd_tc(b_lp) from bh_bt_gd_hs_pt where
        ma_dvi=b_ma_dvi and so_id=b_so_id_bt and lh_nv<>' ' and
        ngay_qd<=b_ngay_qd and FBH_MA_LHNV_TAI(lh_nv)=bth_ma_ta(b_lp);
    if gd_ma_nt(b_lp)<>'VND' then
        gd_tien(b_lp):=FBH_TT_VND_QD(b_ngay_qd,gd_ma_nt(b_lp),gd_tien(b_lp));
    end if;
    for b_lp1 in 1..bth_ma_ta.count loop
        if bth_ma_ta(b_lp1)=gd_ma_ta(b_lp) then
            bth_tien(b_lp1):=bth_tien(b_lp1)+gd_tien(b_lp);
        else
            b_i1:=bth_ma_ta.count+1;
            bth_tien(b_i1):=gd_tien(b_lp); bth_tc(b_i1):=gd_tc(b_lp);
        end if;
    end loop;
end loop;
a_ma_dviX(1):=b_ma_dvi_ql; a_so_idX(1):=b_so_id_hd; a_so_id_dtX(1):=b_so_id_dt;
PTBH_GHEP_NV(0,b_ngay_xr,b_ngay_ht,'VND','VND',a_ma_dviX,a_so_idX,a_so_id_dtX,b_loi,'{"nv":"'||b_nv||'"}');
if b_loi is not null then return; end if;
select ma_ta,pt_con bulk collect into a_ma_ta,a_tl_ta from tbh_ghep_nv_temp0;
for b_lp in 1..bth_ma_ta.count loop
    b_i1:=FKH_ARR_VTRI(a_ma_ta,bth_ma_ta(b_lp));
    if b_i1<>0 then
        bth_tien(b_lp):=round(bth_tien(b_lp)*a_tl_ta(b_i1)/100,0);
    end if;
end loop;
delete tbh_ghep_nv_temp; delete tbh_ghep_nv_temp0;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TA_XOL_TIEN:loi'; end if;
end;
/
create or replace procedure PTBH_TH_TA_XOL_BTx(b_ma_dvi_bt varchar2,b_so_id_bt number,b_loi out varchar2)
AS
begin
-- Dan - Xoa tap hop so cai boi thuong tai XOL
for r_lp in (select distinct so_id_ps from tbh_xol_bth_ps_id where ma_dvi_bt=b_ma_dvi_bt and so_id_bt=b_so_id_bt) loop
    PTBH_TH_TA_XOA(r_lp.so_id_ps,b_so_id_bt,0,0,b_loi);
    if b_loi is not null then return; end if;
end loop;
for r_lp in(select * from tbh_xol_bth_ps_ct where ma_dvi_bt=b_ma_dvi_bt and so_id_bt=b_so_id_bt) loop
    PTBH_XOL_THc(r_lp.so_id_ta,r_lp.ngay_ht,r_lp.ma_ta,r_lp.tu,r_lp.den,0,r_lp.vu,r_lp.tien,b_loi);
    if b_loi is not null then return; end if;
end loop;
delete tbh_xol_bth_ps_id where ma_dvi_bt=b_ma_dvi_bt and so_id_bt=b_so_id_bt;
delete tbh_xol_bth_ps_ct where ma_dvi_bt=b_ma_dvi_bt and so_id_bt=b_so_id_bt;
delete tbh_xol_bth_ps_pt where ma_dvi_bt=b_ma_dvi_bt and so_id_bt=b_so_id_bt;
delete tbh_xol_bth_ps where ma_dvi_bt=b_ma_dvi_bt and so_id_bt=b_so_id_bt;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TA_XOL_BTx:loi'; end if;
end;
/
create or replace procedure PTBH_TH_TA_XOL_BT(
    b_ma_dvi_bt varchar2,b_so_id_bt number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_dvi_ta varchar2(10):=FTBH_DVI_TA;
    b_so_id number; b_so_idB number; b_bt number:=1; b_btt number; b_ma_ta varchar2(10);
    b_so_ct varchar2(20); b_so_id_ta number; b_tp number:=0; b_pt number; b_vu number;
    b_skien varchar2(20); b_nt_tien varchar2(5); b_tc varchar2(5); b_hs number;
    b_tien number; b_tien_qd number; b_tienB number; b_tienB_qd number;
    b_tienT number; b_tienC number; b_tienC_qd number; 
    b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_id_dt number;
    b_nv varchar2(10); b_ngay_qd number; b_ngay_xr number; b_ph varchar2(1);
    b_ma_dvi_btT varchar2(10):=' '; b_so_id_btT number:=0; b_skienD number; b_skienC number;

    a_so_idD pht_type.a_num; a_so_idB pht_type.a_num; a_tl_ta pht_type.a_num;
    a_ma_ta pht_type.a_var; a_ma_nt pht_type.a_var;
    a_tu pht_type.a_num; a_den pht_type.a_num; a_tien pht_type.a_num;

    a_ma_dvi_bt pht_type.a_var; a_so_id_bt pht_type.a_num; a_nv pht_type.a_var;
    a_ma_dvi_hd pht_type.a_var; a_so_hd pht_type.a_var;
    a_so_id_hd pht_type.a_num; a_so_id_dt pht_type.a_num;
    a_ma_dvi_hdT pht_type.a_var; a_so_hdT pht_type.a_var; a_tenT pht_type.a_nvar;
    a_so_id_hdT pht_type.a_num; a_so_id_dtT pht_type.a_num;
    bth_ma_dvi_bt pht_type.a_var; bth_so_id_bt pht_type.a_num; bth_so_id_dt pht_type.a_num;
    bth_ma_ta pht_type.a_var; bth_tien pht_type.a_num; bth_tienX pht_type.a_num; bth_tc pht_type.a_var;
    a_ma_taB pht_type.a_var; a_tienB pht_type.a_num; a_tienX pht_type.a_num; a_tcB pht_type.a_var; 
    bth_ma_taX pht_type.a_var;

    ta_ma_dvi_bt pht_type.a_var; ta_so_id_bt pht_type.a_num;
    ta_so_id_ta pht_type.a_num; ta_ma_ta pht_type.a_var;
    ta_tu pht_type.a_num; ta_tien pht_type.a_num;
    ct_lh_nv pht_type.a_var; ct_tien pht_type.a_num; ct_tien_qd pht_type.a_num;
begin
-- Dan - Tap hop phat sinh boi thuong tai XOL - Hon hop
delete tbh_xol_bth_temp0; delete tbh_xol_bth_temp1; delete tbh_xol_bth_temp2;
PKH_MANG_KD(a_ma_dvi_bt); PKH_MANG_KD_N(a_so_id_bt); PKH_MANG_KD(a_nv);
PKH_MANG_KD(a_ma_ta); PKH_MANG_KD_N(a_so_idD);
select nv,ngay_qd,ngay_xr,ma_dvi_ql,so_id_hd,so_id_dt,skien,nt_tien into
    b_nv,b_ngay_qd,b_ngay_xr,b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_skien,b_nt_tien
    from bh_bt_hs where ma_dvi=b_ma_dvi_bt and so_id=b_so_id_bt;
PTBH_TMB_CBI_DT(b_nv,b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,a_ma_dvi_hdT,a_so_hdT,a_tenT,a_so_id_hdT,a_so_id_dtT,b_loi,'D');
if b_loi is not null then return; end if;
if b_skien=' ' and a_ma_dvi_hdT.count=1 and
    FBH_HD_CDT(b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,'X','{"nv":"'||b_nv||'"}')<>'C' then
    b_loi:=''; return;
end if;
for b_lp in 1..a_ma_dvi_hdT.count loop
    for r_lp in(select ma_dvi,so_id from bh_bt_hs where 
        ma_dvi_ql=a_ma_dvi_hdT(b_lp) and so_id_hd=a_so_id_hdT(b_lp) and
        so_id_dt=a_so_id_dtT(b_lp) and ttrang='D' and ngay_xr=b_ngay_xr ) loop
        b_i1:=0;
        for b_lp1 in 1..a_so_id_bt.count loop
            if a_ma_dvi_bt(b_lp1)=r_lp.ma_dvi and a_so_id_bt(b_lp1)=r_lp.so_id then b_i1:=1; exit; end if;
        end loop;
        if b_i1=0 then
            b_i1:=a_so_id_bt.count+1;
            a_ma_dvi_bt(b_i1):=r_lp.ma_dvi; a_so_id_bt(b_i1):=r_lp.so_id;
            a_so_id_dt(b_i1):=a_so_id_dtT(b_lp); a_nv(b_i1):=b_nv;
        end if;
    end loop;
end loop;
if b_skien<>' ' then
    select nvl(min(ngay_bd),0),nvl(min(ngay_kt),0) into b_skienD,b_skienC from bh_ma_skien where ma=b_skien;
    for r_lp in(select ma_dvi,so_id,nv,ma_dvi_ql,so_id_hd,so_id_dt from bh_bt_hs where 
        skien=b_skien and ttrang='D' and ngay_xr between b_skienD and b_skienC) loop
        b_i1:=0;
        for b_lp1 in 1..a_so_id_bt.count loop
            if a_ma_dvi_bt(b_lp1)=r_lp.ma_dvi and a_so_id_bt(b_lp1)=r_lp.so_id then b_i1:=1; exit; end if;
        end loop;
        if b_i1=0 then
            b_i1:=a_so_id_bt.count+1;
            a_ma_dvi_bt(b_i1):=r_lp.ma_dvi; a_so_id_bt(b_i1):=r_lp.so_id;
            a_so_id_dt(b_i1):=r_lp.so_id_dt; a_nv(b_i1):=r_lp.nv;
        end if;
    end loop;
end if;
PKH_MANG_KD(bth_ma_ta); PKH_MANG_KD_N(bth_tien); PKH_MANG_KD_N(bth_tienX); PKH_MANG_KD(bth_tc);
for b_lp in 1..a_so_id_bt.count loop
    PTBH_TH_TA_XOL_TIEN(a_ma_dvi_bt(b_lp),a_so_id_bt(b_lp),a_ma_taB,a_tienB,a_tcB,b_loi);
    if b_loi is not null then return; end if;
    for b_lp1 in 1..a_ma_taB.count loop
        b_i1:=bth_ma_ta.count+1;
        bth_ma_dvi_bt(b_i1):=a_ma_dvi_bt(b_lp); bth_so_id_bt(b_i1):=a_so_id_bt(b_lp); bth_so_id_dt(b_i1):=a_so_id_dt(b_lp);
        bth_ma_ta(b_i1):=a_ma_taB(b_lp1); bth_tien(b_i1):=a_tienB(b_lp1); bth_tc(b_i1):=a_tcB(b_lp1);
    end loop;
    select a_ma_dvi_bt(b_lp),a_so_id_bt(b_lp),so_id_ta,ma_ta,tu,nvl(sum(tien),0) bulk collect 
        into ta_ma_dvi_bt,ta_so_id_bt,ta_so_id_ta,ta_ma_ta,ta_tu,ta_tien from tbh_xol_bth_ps_pt where
        ma_dvi_btT=a_ma_dvi_bt(b_lp) and so_id_btT=a_so_id_bt(b_lp) group by so_id_ta,ma_ta,tu;
end loop;
PKH_MANG_DUY(bth_ma_ta,bth_ma_taX);
for b_lp in 1..bth_ma_taX.count loop
    b_tienT:=0;
    for b_lp1 in 1..bth_ma_ta.count loop
        if bth_ma_ta(b_lp1)=bth_ma_taX(b_lp) then
            b_tienT:=b_tienT+bth_tien(b_lp1); b_tc:=bth_tc(b_lp1);
        end if;
    end loop;
    if b_tienT<=0 then continue; end if;
    for r_lp1 in(select min(a.so_id) so_id,a.nv,a.ma_nt,b.lh_nv,b.tu,b.den from tbh_xol a,tbh_xol_nv b
        where b_ngay_xr between a.ngay_bd and a.ngay_kt and b.so_id=a.so_id and
        b.lh_nv in(' ',bth_ma_taX(b_lp)) group by a.nv,a.ma_nt,b.lh_nv,b.tu,b.den) loop
        if (b_tc<>'V' and FTBH_XOL_SC_PH(r_lp1.so_id,r_lp1.tu,b_ngay_xr)='C') or
            (b_skien=' ' and FBH_MA_NV_CO(r_lp1.nv,b_nv,'C')<>'C') then continue;
        end if;
        b_tienB:=b_tienT;
        if r_lp1.ma_nt<>'VND' then
            b_tienB:=FBH_TT_TUNG_QD(b_ngay_qd,b_nt_tien,b_tienB,r_lp1.ma_nt);
        end if;
        if b_tienB<=r_lp1.tu then continue; end if;
        if b_tienB>r_lp1.den then
            b_tienB:=r_lp1.den-r_lp1.tu;
        else
            b_tienB:=b_tienB-r_lp1.tu;
        end if;
        for b_lp1 in 1..ta_so_id_bt.count loop
            if ta_so_id_ta(b_lp1)=r_lp1.so_id and ta_ma_ta(b_lp1)=r_lp1.lh_nv and ta_tu(b_lp1)=r_lp1.tu then
                b_tienB:=b_tienB-ta_tien(b_lp1);
            end if;
        end loop;
        if b_tienB>0 then
            if ta_so_id_bt.count=0 then b_vu:=1; else b_vu:=0; end if;
            insert into tbh_xol_bth_temp0 values(b_nv,r_lp1.so_id,r_lp1.lh_nv,r_lp1.ma_nt,r_lp1.tu,r_lp1.den,b_tienB,b_vu);
        end if;
    end loop;
end loop;
--
insert into tbh_xol_bth_temp1 select nv,so_id_ta,ma_ta,ma_nt,tu,den,sum(tien) tien,max(vu) vu
    from tbh_xol_bth_temp0 group by nv,so_id_ta,ma_ta,ma_nt,tu,den having sum(tien)>0;
for r_lp in (select nv,so_id_ta,ma_nt,sum(tien) tien from tbh_xol_bth_temp1 group by nv,so_id_ta,ma_nt) loop
    select nvl(max(so_id),0) into b_so_idB from tbh_xol where so_id_d=r_lp.so_id_ta and ngay_bd<=b_ngay_xr;
    b_pt:=0; b_tienT:=r_lp.tien; b_tienC:=b_tienT;
    if r_lp.ma_nt<>'VND' then b_tp:=2; else b_tp:=0; end if;
    for r_lp1 in(select nbhC,sum(pt) pt from tbh_xol_nbh where so_id=b_so_idB group by nbhC) loop
        b_pt:=b_pt+r_lp1.pt;
        if b_pt>=100 then b_i1:=b_tienC; else b_i1:=round(b_tienT*r_lp1.pt/100,b_tp); end if;
        b_tienC:=b_tienC-b_i1;
        insert into tbh_xol_bth_temp2 values(r_lp.nv,r_lp.so_id_ta,r_lp1.nbhC,r_lp.ma_nt,b_i1);
    end loop;
end loop;
insert into tbh_xol_bth_ps values(b_ma_dvi_bt,b_so_id_bt,b_so_id_dt,b_nv,b_ngay_qd,b_ngay_xr,b_skien);
for r_lp in(select so_id_ta,ma_ta,tu,den,ma_nt,sum(tien) tien,max(vu) vu
    from tbh_xol_bth_temp1 group by so_id_ta,ma_ta,tu,den,ma_nt) loop
    b_tien:=r_lp.tien; b_vu:=r_lp.vu;
    PTBH_XOL_THc(r_lp.so_id_ta,b_ngay_xr,r_lp.ma_ta,r_lp.tu,r_lp.den,0,-b_vu,-b_tien,b_loi);
    if b_loi is not null then return; end if;
    insert into tbh_xol_bth_ps_ct values(b_ma_dvi_bt,b_so_id_bt,b_ngay_qd,
        r_lp.so_id_ta,r_lp.ma_ta,r_lp.tu,r_lp.den,b_vu,b_tien);
    for b_lp in 1..bth_ma_dvi_bt.count loop
        if bth_ma_ta(b_lp)<>r_lp.ma_ta then continue; end if;
        b_i1:=0;
        for b_lp1 in 1..ta_ma_dvi_bt.count loop
            if ta_ma_dvi_bt(b_lp1)=bth_ma_dvi_bt(b_lp) and ta_so_id_bt(b_lp1)=bth_so_id_bt(b_lp) and
                ta_ma_ta(b_lp1)=bth_ma_ta(b_lp) and ta_so_id_ta(b_lp1)=r_lp.so_id_ta and ta_tu(b_lp1)=r_lp.tu then
                b_i1:=b_i1; exit;
            end if;
        end loop;
        if b_i1<>0 then continue; end if;
        b_tienB:=bth_tien(b_lp);
        if r_lp.ma_nt<>'VND' then b_tienB:=FBH_TT_TUNG_QD(b_ngay_qd,b_nt_tien,b_tienB,r_lp.ma_nt); end if;
        if b_tienB>b_tien then b_tienB:=b_tien; end if;
        if r_lp.ma_nt='VND' then b_tienB_qd:=b_tienB; else b_tienB_qd:=FBH_TT_VND_QD(b_ngay_qd,r_lp.ma_nt,b_tienB); end if;
        select lh_nv,sum(tien),sum(tien_qd) bulk collect into ct_lh_nv,ct_tien,ct_tien_qd from bh_bt_hs_nv where
            ma_dvi=bth_ma_dvi_bt(b_lp) and so_id=bth_so_id_bt(b_lp) and lh_nv<>' ' and
            (r_lp.ma_ta=' ' or FBH_MA_LHNV_LOAI(lh_nv)=r_lp.ma_ta) group by lh_nv;
        b_i1:=FKH_ARR_TONG(ct_tien);
        if b_i1=0 then continue; end if;
        b_hs:=b_tienB/b_i1; b_tienC:=b_tienB;
        for b_lp1 in 1..ct_lh_nv.count loop
            if b_lp1=ct_lh_nv.count then b_i1:=b_tienC; b_i2:=b_tienC_qd;
            else b_i1:=round(ct_tien(b_lp1)*b_hs,0); b_i2:=round(ct_tien_qd(b_lp1)*b_hs,0);
            end if;
            insert into tbh_xol_bth_ps_pt values(
                b_ma_dvi_bt,b_so_id_bt,bth_ma_dvi_bt(b_lp),bth_so_id_bt(b_lp),bth_so_id_dt(b_lp),
                r_lp.so_id_ta,r_lp.tu,r_lp.den,r_lp.ma_ta,ct_lh_nv(b_lp1),b_i1,b_i2);
            b_tienC:=b_tienC-b_i1; b_tienC_qd:=b_tienC_qd-b_i2;
        end loop;
        if b_tien=b_tienB then exit; end if;
        b_tien:=b_tien-b_tienB;
    end loop;
end loop;
for r_lp in (select nv,so_id_ta,nbhC,ma_nt,sum(tien) tien from tbh_xol_bth_temp2 group by nv,so_id_ta,nbhC,ma_nt) loop
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then return; end if;
    if r_lp.ma_nt='VND' then
        b_tien_qd:=r_lp.tien;
    else
        b_tien_qd:=FBH_TT_VND_QD(b_ngay_qd,r_lp.ma_nt,r_lp.tien);
    end if;
    insert into tbh_ps values(b_dvi_ta,b_so_id,b_so_id_bt,r_lp.so_id_ta,r_lp.so_id_ta,b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,
        b_ngay_qd,'T','X',r_lp.nv,'X','DT_BT_XOLd',r_lp.nbhC,'X',r_lp.ma_nt,r_lp.tien,0,0,b_tien_qd,0,0,b_bt,0);        
    b_btt:=0;
    for r_lp1 in (select ma_ta,sum(tien) tien from tbh_xol_bth_temp0 where
        so_id_ta=r_lp.so_id_ta and ma_nt=r_lp.ma_nt group by ma_ta) loop
        b_btt:=b_btt+1;
        insert into tbh_ps_pbo values(b_dvi_ta,b_so_id,b_so_id_bt,r_lp.so_id_ta,r_lp.so_id_ta,b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,
            b_ngay_qd,'T','X',r_lp.nv,'X','BT_HS',r_lp1.ma_ta,r_lp.nbhC,'X',r_lp.ma_nt,r_lp1.tien,0,0,b_bt,b_btt);
    end loop;
    PTBH_TH_TA_PS_TON(b_dvi_ta,b_so_id,b_so_id_bt,0,0,b_loi);
    if b_loi is not null then return; end if;
    insert into tbh_xol_bth_ps_id values(b_ma_dvi_bt,b_so_id_bt,b_so_id);
end loop;
delete tbh_xol_bth_temp0; delete tbh_xol_bth_temp1; delete tbh_xol_bth_temp2;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TA_XOL_BT:loi';end if;
end;
/
