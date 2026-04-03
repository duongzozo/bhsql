create or replace procedure PTBH_TMB_CBI_PHHs(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_kt number; b_so_id_cbi number:=0; b_dvi_ta varchar2(10):=FTBH_DVI_TA();
    b_nv varchar2(10):='PHH'; b_nt_tien varchar2(5); b_ttrang varchar2(1);
    b_ngay_ht number; b_ngay_hl number; b_ngay_kt number; b_tso varchar2(100);
    b_so_ct varchar2(20); b_so_ctG varchar2(20); b_so_id_gh number; b_kieu varchar2(1);
    b_nt_phi varchar2(5); b_so_hd varchar2(20); b_ten nvarchar2(500);
    b_so_idD number; b_so_idB number; b_so_id_taD number;
    a_so_id_dt pht_type.a_num;
    a_ma_dviT pht_type.a_var; a_so_hdT pht_type.a_var; a_tenT pht_type.a_nvar;
    a_so_idT pht_type.a_num; a_so_id_dtT pht_type.a_num;
begin
-- Dan - Chuan bi chao tai tam thoi PHH cua SDBS
b_so_idB:=FBH_HD_SO_ID_BSt(b_ma_dvi,b_so_id);
select ttrang,ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi,so_id_d into
    b_ttrang,b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_so_idD
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_idB;
if b_ttrang not in('T','D') or FTBH_TM_FR(b_ma_dvi,b_so_idD)='C' then b_loi:=''; return; end if;
PBH_HD_DS_DT_ARR(b_ma_dvi,b_so_idD,a_so_id_dt,b_nv);
for b_lp in 1..a_so_id_dt.count loop
    PTBH_TMB_CBI_PHH(b_ma_dvi,b_so_idD,a_so_id_dt(b_lp),a_ma_dviT,a_so_hdT,a_tenT,a_so_idT,a_so_id_dtT,b_loi);
    if b_loi is not null then return; end if;
    for b_lp1 in 1..a_ma_dviT.count loop
        select nvl(max(so_id),0) into b_so_id_gh from tbh_tm_hd where
            ma_dvi_hd=a_ma_dviT(b_lp1) and so_id_hd=a_so_idT(b_lp1) and so_id_dt=a_so_id_dtT(b_lp1);
        if b_so_id_gh<>0 then exit; end if;
    end loop;
    if b_so_id_gh<>0 then
        b_so_id_taD:=FTBH_TM_SO_ID_DAU(b_so_id_gh);        
        select nvl(max(so_idC),0) into b_i1 from tbh_tmB_cbi_hd where FTBH_TM_SO_ID_DAU(so_id,'C')=b_so_id_taD and so_id_hd=b_so_idD;
        if b_i1=b_so_idB then continue; end if;
        PHT_ID_MOI(b_so_id_cbi,b_loi);
        if b_loi is not null then return; end if;
        select so_ct into b_so_ctG from tbh_tm where so_id=b_so_id_gh;
        b_so_ct:=FTBH_TM_SO_BS(b_so_id_gh);
        insert into tbh_tmB_cbi values(
            b_so_id_cbi,b_nv,b_so_ct,'B',b_so_ctG,b_ngay_ht,'T','C',b_ma_dvi,b_so_idB,a_so_id_dt(b_lp),b_nt_tien,b_nt_phi,
            'Bo sung, sua doi, ghep them','',sysdate);
        insert into tbh_tmB_cbi_nbh select b_so_id_cbi,nbh,pt,hh,kieu,nbhC,bt from tbh_tm_nbh where so_id=b_so_id_gh order by bt;
        b_i1:=0;
        for r_lp in (select * from tbh_tm_hd where so_id=b_so_id_gh order by bt) loop
            b_ten:=FBH_PHH_DVI(r_lp.ma_dvi_hd,r_lp.so_id_hd,r_lp.so_id_dt);
            insert into tbh_tmB_cbi_hd values(b_so_id_cbi,'H',r_lp.ma_dvi_hd,r_lp.so_hd,r_lp.so_id_hd,r_lp.so_id_dt,b_ten,b_so_idB,r_lp.bt);
            if b_i1<r_lp.bt then b_i1:=r_lp.bt; end if;                
            for b_lp1 in 1..a_ma_dviT.count loop
                if a_ma_dviT(b_lp1)=r_lp.ma_dvi_hd and a_so_idT(b_lp1)=r_lp.so_id_hd and a_so_id_dtT(b_lp1)=r_lp.so_id_dt then
                    a_ma_dviT(b_lp1):=' '; exit;
                end if;
            end loop;
        end loop;
        for b_lp1 in 1..a_ma_dviT.count loop
            if a_ma_dviT(b_lp1)<>' ' then
                b_i1:=b_i1+1;
                b_so_hd:=FBH_PHH_SO_HD(a_ma_dviT(b_lp1),a_so_idT(b_lp1));
                b_ten:=FBH_PHH_DVI(a_ma_dviT(b_lp1),a_so_idT(b_lp1),a_so_id_dtT(b_lp1));
                if a_ma_dviT(b_lp1)=b_ma_dvi and a_so_idT(b_lp1)=b_so_idD then b_kieu:='T'; else b_kieu:='H'; end if;
                insert into tbh_tmB_cbi_hd values(b_so_id_cbi,b_kieu,a_ma_dviT(b_lp1),b_so_hd,a_so_idT(b_lp1),a_so_id_dtT(b_lp1),b_ten,b_so_idB,b_i1);
            end if;
        end loop;
    elsif FBH_HD_CDT(b_ma_dvi,b_so_idB,a_so_id_dt(b_lp),'F','{"nv":"PHH","kieu_ps":"H"}')='C' then
        b_tso:='{"ttrang":"T","xly":"F"}';
        PTBH_GHEP_TL(0,b_ngay_ht,b_ngay_hl,b_nv,b_nt_tien,b_nt_phi,a_ma_dviT,a_so_idT,a_so_id_dtT,b_loi,b_tso);
        if b_loi is not null then return; end if;
        select count(*) into b_i1 from tbh_ghep_tl_temp where pthuc='O';
        if b_i1=0 then continue; end if;
        PHT_ID_MOI(b_so_id_cbi,b_loi);
        if b_loi is not null then return; end if;
        b_so_ct:=substr(to_char(b_so_id_cbi),3);
        insert into tbh_tmB_cbi values(
            b_so_id_cbi,b_nv,b_so_ct,'G',' ',b_ngay_ht,'T','C',b_ma_dvi,b_so_idB,a_so_id_dt(b_lp),b_nt_tien,b_nt_phi,'Phat sinh moi',' ',sysdate);
        for b_lp1 in 1..a_ma_dviT.count loop
            b_so_hd:=FBH_PHH_SO_HD(a_ma_dviT(b_lp1),a_so_idT(b_lp1));
            b_ten:=FBH_PHH_DVI(a_ma_dviT(b_lp1),a_so_idT(b_lp1),a_so_id_dtT(b_lp1));
            if a_ma_dviT(b_lp1)=b_ma_dvi and a_so_idT(b_lp1)=b_so_idD then b_kieu:='T'; else b_kieu:='H'; end if;
            insert into tbh_tmB_cbi_hd values(
                b_so_id_cbi,b_kieu,a_ma_dviT(b_lp1),b_so_hd,a_so_idT(b_lp1),a_so_id_dtT(b_lp1),b_ten,b_so_idB,b_lp1);
        end loop;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TMB_CBI_NH_PHHs:loi'; end if;
end;
/
create or replace procedure PTBH_TMB_CBI_PHHb(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_so_id_cbi number;
    b_nv varchar2(10):='PHH'; b_ngay_ht number; b_nt_tien varchar2(5);
    b_so_ct varchar2(20); b_nt_phi varchar2(5); b_kieu varchar2(1);
    a_so_id_dt pht_type.a_num;
    a_ma_dviT pht_type.a_var; a_kieuT pht_type.a_var;
    a_so_hdT pht_type.a_var; a_tenT pht_type.a_nvar;
    a_so_idT pht_type.a_num; a_so_id_dtT pht_type.a_num;
begin
-- Dan - Nhap chuan bi chao tai tam thoi PHH
select ngay_ht,nt_tien,nt_phi into b_ngay_ht,b_nt_tien,b_nt_phi from bh_phhB where ma_dvi=b_ma_dvi and so_id=b_so_id;
PBH_BAO_DS_DT_ARR(b_ma_dvi,b_so_id,a_so_id_dt);
for b_lp in 1..a_so_id_dt.count loop
    if FBH_HD_CDT(b_ma_dvi,b_so_id,a_so_id_dt(b_lp),'F','{"nv":"PHH","kieu_ps":"B"}')<>'C' then continue; end if;
    PTBH_BAO_TAO_PHHt(b_ma_dvi,b_so_id,a_so_id_dt(b_lp),a_ma_dviT,a_kieuT,a_so_hdT,a_tenT,a_so_idT,a_so_id_dtT,b_loi);
    if b_loi is not null then return; end if;
    PTBH_BAO_TLc(b_ma_dvi,b_so_id,a_so_id_dt(b_lp),a_ma_dviT,a_kieuT,a_so_idT,a_so_id_dtT,b_loi);
    if b_loi is not null then return; end if;
    select count(*) into b_i1 from tbh_ghep_tl_temp where pthuc='O';
    if b_i1<>0 then
        PHT_ID_MOI(b_so_id_cbi,b_loi);
        if b_loi is not null then return; end if;
        b_so_ct:=substr(to_char(b_so_id_cbi),3);
        insert into tbh_tmB_cbi values(
            b_so_id_cbi,b_nv,b_so_ct,'G',' ',b_ngay_ht,'B','C',b_ma_dvi,b_so_id,a_so_id_dt(b_lp),b_nt_tien,b_nt_phi,'Phat sinh moi',' ',sysdate);
        for b_lp1 in 1..a_ma_dviT.count loop
            if a_ma_dviT(b_lp1)=b_ma_dvi and a_so_idT(b_lp1)=b_so_id then b_kieu:='B'; else b_kieu:='H'; end if;
            insert into tbh_tmB_cbi_hd values(
                b_so_id_cbi,b_kieu,a_ma_dviT(b_lp1),a_so_hdT(b_lp1),a_so_idT(b_lp1),a_so_id_dtT(b_lp1),a_tenT(b_lp1),b_so_id,b_lp1);
        end loop;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TMB_CBI_PHHb:loi'; end if;
end;
/
create or replace procedure PTBH_TMB_CBI_PKTs(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_kt number; b_so_id_cbi number:=0; b_dvi_ta varchar2(10):=FTBH_DVI_TA();
    b_nv varchar2(10):='PKT'; b_nt_tien varchar2(5); b_ttrang varchar2(1);
    b_ngay_ht number; b_ngay_hl number; b_ngay_kt number; b_tso varchar2(100);
    b_so_ct varchar2(20); b_so_ctG varchar2(20); b_so_id_gh number; b_kieu varchar2(1);
    b_nt_phi varchar2(5); b_so_hd varchar2(20); b_so_id_taD number;
    b_so_idD number; b_so_idB number; b_ten nvarchar2(500);
    a_so_id_dt pht_type.a_num;
    a_ma_dviT pht_type.a_var; a_so_hdT pht_type.a_var; a_tenT pht_type.a_nvar;
    a_so_idT pht_type.a_num; a_so_id_dtT pht_type.a_num;
begin
-- Dan - Nhap chuan bi chao tai tam thoi PKT
b_so_idB:=FBH_HD_SO_ID_BSt(b_ma_dvi,b_so_id);
select ttrang,ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi,so_id_d into
    b_ttrang,b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_so_idD
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_idB;
if b_ttrang not in('T','D') or FTBH_TM_FR(b_ma_dvi,b_so_idD)='C' then b_loi:=''; return; end if;
PBH_HD_DS_DT_ARR(b_ma_dvi,b_so_idD,a_so_id_dt,b_nv);
for b_lp in 1..a_so_id_dt.count loop
    PTBH_TMB_CBI_PKT(b_ma_dvi,b_so_idD,a_so_id_dt(b_lp),a_ma_dviT,a_so_hdT,a_tenT,a_so_idT,a_so_id_dtT,b_loi);
    if b_loi is not null then return; end if;
    for b_lp1 in 1..a_ma_dviT.count loop
        select nvl(max(so_id),0) into b_so_id_gh from tbh_tm_hd where
            ma_dvi_hd=a_ma_dviT(b_lp1) and so_id_hd=a_so_idT(b_lp1) and so_id_dt=a_so_id_dtT(b_lp1);
        if b_so_id_gh<>0 then exit; end if;
    end loop;
    if b_so_id_gh<>0 then
        b_so_id_taD:=FTBH_TM_SO_ID_DAU(b_so_id_gh);        
        select nvl(max(so_idC),0) into b_i1 from tbh_tmB_cbi_hd where FTBH_TM_SO_ID_DAU(so_id,'C')=b_so_id_taD and so_id_hd=b_so_idD;
        if b_i1=b_so_idB then continue; end if;
        PHT_ID_MOI(b_so_id_cbi,b_loi);
        if b_loi is not null then return; end if;
        select so_ct into b_so_ctG from tbh_tm where so_id=b_so_id_gh;
        b_so_ct:=FTBH_TM_SO_BS(b_so_id_gh);
        insert into tbh_tmB_cbi values(
            b_so_id_cbi,b_nv,b_so_ct,'B',b_so_ctG,b_ngay_ht,'T','C',b_ma_dvi,b_so_idB,a_so_id_dt(b_lp),b_nt_tien,b_nt_phi,
            'Bo sung, sua doi, ghep them','',sysdate);
        insert into tbh_tmB_cbi_nbh select b_so_id_cbi,nbh,pt,hh,kieu,nbhC,bt from tbh_tm_nbh where so_id=b_so_id_gh order by bt;
        b_i1:=0;
        for r_lp in (select * from tbh_tm_hd where so_id=b_so_id_gh order by bt) loop
            b_ten:=FBH_PKT_DVI(r_lp.ma_dvi_hd,r_lp.so_id_hd,r_lp.so_id_dt);
            insert into tbh_tmB_cbi_hd values(b_so_id_cbi,'H',r_lp.ma_dvi_hd,r_lp.so_hd,r_lp.so_id_hd,r_lp.so_id_dt,b_ten,b_so_idB,r_lp.bt);
            if b_i1<r_lp.bt then b_i1:=r_lp.bt; end if;                
            for b_lp1 in 1..a_ma_dviT.count loop
                if a_ma_dviT(b_lp1)=r_lp.ma_dvi_hd and a_so_idT(b_lp1)=r_lp.so_id_hd and a_so_id_dtT(b_lp1)=r_lp.so_id_dt then
                    a_ma_dviT(b_lp1):=' '; exit;
                end if;
            end loop;
        end loop;
        for b_lp1 in 1..a_ma_dviT.count loop
            if a_ma_dviT(b_lp1)<>' ' then
                b_i1:=b_i1+1;
                b_so_hd:=FBH_PKT_SO_HD(a_ma_dviT(b_lp1),a_so_idT(b_lp1));
                b_ten:=FBH_PKT_DVI(a_ma_dviT(b_lp1),a_so_idT(b_lp1),a_so_id_dtT(b_lp1));
                if a_ma_dviT(b_lp1)=b_ma_dvi and a_so_idT(b_lp1)=b_so_idD then b_kieu:='T'; else b_kieu:='H'; end if;
                insert into tbh_tmB_cbi_hd values(b_so_id_cbi,b_kieu,a_ma_dviT(b_lp1),b_so_hd,a_so_idT(b_lp1),a_so_id_dtT(b_lp1),b_ten,b_so_idB,b_i1);
            end if;
        end loop;
    elsif FBH_HD_CDT(b_ma_dvi,b_so_idB,a_so_id_dt(b_lp),'F','{"nv":"PKT","kieu_ps":"H"}')='C' then
        b_tso:='{"ttrang":"T","xly":"F"}';
        PTBH_GHEP_TL(0,b_ngay_ht,b_ngay_hl,b_nv,b_nt_tien,b_nt_phi,a_ma_dviT,a_so_idT,a_so_id_dtT,b_loi,b_tso);
        if b_loi is not null then return; end if;
        select count(*) into b_i1 from tbh_ghep_tl_temp where pthuc='O';
        if b_i1=0 then continue; end if;
        PHT_ID_MOI(b_so_id_cbi,b_loi);
        if b_loi is not null then return; end if;
        b_so_ct:=substr(to_char(b_so_id_cbi),3);
        insert into tbh_tmB_cbi values(
            b_so_id_cbi,b_nv,b_so_ct,'G',' ',b_ngay_ht,'T','C',b_ma_dvi,b_so_idB,a_so_id_dt(b_lp),
            b_nt_tien,b_nt_phi,'Phat sinh moi',' ',sysdate);
        for b_lp1 in 1..a_ma_dviT.count loop
          --nam
            b_so_hd:=FBH_PKT_SO_HD(a_ma_dviT(b_lp1),a_so_idT(b_lp1));
            b_ten:=FBH_PKT_DVI(a_ma_dviT(b_lp1),a_so_idT(b_lp1),a_so_id_dtT(b_lp1));
            if a_ma_dviT(b_lp1)=b_ma_dvi and a_so_idT(b_lp1)=b_so_idD then b_kieu:='T'; else b_kieu:='H'; end if;
            insert into tbh_tmB_cbi_hd values(
                b_so_id_cbi,b_kieu,a_ma_dviT(b_lp1),b_so_hd,a_so_idT(b_lp1),a_so_id_dtT(b_lp1),b_ten,b_so_idB,b_lp1);
        end loop;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TMB_CBI_NH_PKTs:loi'; end if;
end;
/
create or replace procedure PTBH_TMB_CBI_PKTb(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_so_id_cbi number;
    b_nv varchar2(10):='PKT'; b_ngay_ht number; b_nt_tien varchar2(5);
    b_so_ct varchar2(20); b_nt_phi varchar2(5); b_kieu varchar2(1);
    a_so_id_dt pht_type.a_num;
    a_ma_dviT pht_type.a_var; a_kieuT pht_type.a_var;
    a_so_hdT pht_type.a_var; a_tenT pht_type.a_nvar;
    a_so_idT pht_type.a_num; a_so_id_dtT pht_type.a_num;
begin
-- Dan - Nhap chuan bi chao tai tam thoi PKT
select ngay_ht,nt_tien,nt_phi into b_ngay_ht,b_nt_tien,b_nt_phi
    from bh_pktB where ma_dvi=b_ma_dvi and so_id=b_so_id;
PBH_BAO_DS_DT_ARR(b_ma_dvi,b_so_id,a_so_id_dt);
for b_lp in 1..a_so_id_dt.count loop
    if FBH_HD_CDT(b_ma_dvi,b_so_id,a_so_id_dt(b_lp),'F','{"nv":"PKT","kieu_ps":"B"}')<>'C' then continue; end if;
    PTBH_BAO_TAO_PKTt(b_ma_dvi,b_so_id,a_so_id_dt(b_lp),a_ma_dviT,a_kieuT,a_so_hdT,a_tenT,a_so_idT,a_so_id_dtT,b_loi);
    if b_loi is not null then return; end if;
    PTBH_BAO_TLc(b_ma_dvi,b_so_id,a_so_id_dt(b_lp),a_ma_dviT,a_kieuT,a_so_idT,a_so_id_dtT,b_loi);
    if b_loi is not null then return; end if;
    select count(*) into b_i1 from tbh_ghep_tl_temp where pthuc='O';
    if b_i1<>0 then
        PHT_ID_MOI(b_so_id_cbi,b_loi);
        if b_loi is not null then return; end if;
        b_so_ct:=substr(to_char(b_so_id_cbi),3);
        insert into tbh_tmB_cbi values(
            b_so_id_cbi,b_nv,b_so_ct,'G',' ',b_ngay_ht,'B','C',b_ma_dvi,b_so_id,a_so_id_dt(b_lp),
            b_nt_tien,b_nt_phi,'Phat sinh moi',' ',sysdate);
        for b_lp1 in 1..a_ma_dviT.count loop
            if a_ma_dviT(b_lp1)=b_ma_dvi and a_so_idT(b_lp1)=b_so_id then b_kieu:='B'; else b_kieu:='H'; end if;
            insert into tbh_tmB_cbi_hd values(
                b_so_id_cbi,b_kieu,a_ma_dviT(b_lp1),a_so_hdT(b_lp1),a_so_idT(b_lp1),a_so_id_dtT(b_lp1),a_tenT(b_lp1),b_so_id,b_lp1);
        end loop;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TMB_CBI_PKTb:loi'; end if;
end;
/
create or replace procedure PTBH_TMB_CBI_HANGs(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_kt number; b_so_id_cbi number:=0;
    b_nv varchar2(10):='HANG'; b_nt_tien varchar2(5);
    b_ngay_ht number; b_ngay_hl number; b_ngay_kt number; b_tso varchar2(100);
    b_so_ct varchar2(20); b_so_ctG varchar2(20); b_so_id_gh number; b_dvi_ta varchar2(10):=FTBH_DVI_TA();
    b_nt_phi varchar2(5); b_so_hd varchar2(20); b_ttrang varchar2(1);
    b_so_idD number; b_so_idB number; b_so_id_taD number;
    b_hd_kem varchar2(1); b_kieu_hd varchar2(1); b_kieu varchar2(1);
    a_ma_dviT pht_type.a_var; a_so_hdT pht_type.a_var; a_so_idT pht_type.a_num; a_so_id_dtT pht_type.a_num;
begin
-- Dan - Nhap chuan bi ghep tai HANG
b_so_idB:=FBH_HD_SO_ID_BSt(b_ma_dvi,b_so_id);
select count(*) into b_i1 from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_idB and hd_kem='C';
if b_i1<>0 then b_loi:=''; return; end if;
select ttrang,ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi,so_id_d,kieu_hd into
    b_ttrang,b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_so_idD,b_kieu_hd
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_idB;
if b_ttrang not in('T','D') or FTBH_TM_FR(b_ma_dvi,b_so_idD)='C' then b_loi:=''; return; end if;
PTBH_TMB_CBI_HANG(b_ma_dvi,b_so_idD,a_ma_dviT,a_so_hdT,a_so_idT,b_loi);
if b_loi is not null then return; end if;
for b_lp1 in 1..a_ma_dviT.count loop
    a_so_id_dtT(b_lp1):=0;
end loop;
for b_lp1 in 1..a_ma_dviT.count loop
    select nvl(max(so_id),0) into b_so_id_gh from tbh_tm_hd where
        ma_dvi_hd=a_ma_dviT(b_lp1) and so_id_hd=a_so_idT(b_lp1);
    if b_so_id_gh<>0 then exit; end if;
end loop;
if b_so_id_gh<>0 then
    b_so_id_taD:=FTBH_TM_SO_ID_DAU(b_so_id_gh);        
    select nvl(max(so_idC),0) into b_i1 from tbh_tmB_cbi_hd where FTBH_TM_SO_ID_DAU(so_id,'C')=b_so_id_taD and so_id_hd=b_so_idD;
    if b_i1<>b_so_idB then
        PHT_ID_MOI(b_so_id_cbi,b_loi);
        if b_loi is not null then return; end if;
        select so_ct into b_so_ctG from tbh_tm where so_id=b_so_id_gh;
        b_so_ct:=FTBH_TM_SO_BS(b_so_id_gh);
        insert into tbh_tmB_cbi values(
            b_so_id_cbi,b_nv,b_so_ct,'B',b_so_ctG,b_ngay_ht,'T','C',b_ma_dvi,b_so_idB,0,b_nt_tien,b_nt_phi,
            'Bo sung, sua doi, ghep them','',sysdate);
        insert into tbh_tmB_cbi_nbh select b_so_id_cbi,nbh,pt,hh,kieu,nbhC,bt from tbh_tm_nbh where so_id=b_so_id_gh order by bt;
        b_i1:=0;
        for r_lp in (select * from tbh_tm_hd where so_id=b_so_id_gh order by bt) loop
            insert into tbh_tmB_cbi_hd values(b_so_id_cbi,'H',r_lp.ma_dvi_hd,r_lp.so_hd,r_lp.so_id_hd,0,' ',b_so_idB,r_lp.bt);
            if b_i1<r_lp.bt then b_i1:=r_lp.bt; end if;                
            for b_lp1 in 1..a_ma_dviT.count loop
                if a_ma_dviT(b_lp1)=r_lp.ma_dvi_hd and a_so_idT(b_lp1)=r_lp.so_id_hd then
                    a_ma_dviT(b_lp1):=' '; exit;
                end if;
            end loop;
        end loop;
        for b_lp1 in 1..a_ma_dviT.count loop
            if a_ma_dviT(b_lp1)<>' ' then
                b_i1:=b_i1+1;
                b_so_hd:=FBH_HANG_SO_HD(a_ma_dviT(b_lp1),a_so_idT(b_lp1));
                if a_ma_dviT(b_lp1)=b_ma_dvi and a_so_idT(b_lp1)=b_so_idD then b_kieu:='T'; else b_kieu:='H'; end if;
                insert into tbh_tmB_cbi_hd values(b_so_id_cbi,b_kieu,a_ma_dviT(b_lp1),b_so_hd,a_so_idT(b_lp1),0,' ',b_so_idB,b_i1);
            end if;
        end loop;
    end if;
    -- nam: bo hd kem
elsif b_kieu_hd in('G','K') and FBH_HD_CDT(b_ma_dvi,b_so_idB,0,'F','{"nv":"HANG","kieu_ps":"H"}')='C' then
    b_tso:='{"ttrang":"T","xly":"F"}';
    PTBH_GHEP_TL(0,b_ngay_ht,b_ngay_hl,b_nv,b_nt_tien,b_nt_phi,a_ma_dviT,a_so_idT,a_so_id_dtT,b_loi,b_tso);
    if b_loi is not null then return; end if;
    select count(*) into b_i1 from tbh_ghep_tl_temp where pthuc='O';
    --nam
    if b_i1=0 then b_loi:=''; return; end if;
    PHT_ID_MOI(b_so_id_cbi,b_loi);
    if b_loi is not null then return; end if;
    b_so_ct:=substr(to_char(b_so_id_cbi),3);
    --nam
    insert into tbh_tmB_cbi values(
        b_so_id_cbi,b_nv,b_so_ct,'G',' ',b_ngay_ht,'T','C',b_ma_dvi,b_so_idB,0,b_nt_tien,b_nt_phi,'Phat sinh moi','',sysdate);
    for b_lp1 in 1..a_ma_dviT.count loop
        b_so_hd:=FBH_HANG_SO_HD(a_ma_dviT(b_lp1),a_so_idT(b_lp1));
        if a_ma_dviT(b_lp1)=b_ma_dvi and a_so_idT(b_lp1)=b_so_idD then b_kieu:='T'; else b_kieu:='H'; end if;
        insert into tbh_tmB_cbi_hd values(b_so_id_cbi,b_kieu,a_ma_dviT(b_lp1),b_so_hd,a_so_idT(b_lp1),0,' ',b_so_idB,b_i1);
    end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TMB_CBI_HANGs:loi'; end if;
end;
/
create or replace procedure PTBH_TMB_CBI_HANGb(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_kt number; b_so_id_cbi number:=0;
    b_nv varchar2(10):='HANG'; b_ngay_ht number; b_nt_tien varchar2(5);
    b_so_ct varchar2(20); b_so_id_gh number; b_kieu varchar2(1); b_kieu_hd varchar2(1);
    b_nt_phi varchar2(5); b_so_hd varchar2(20); b_hd_kem varchar2(1);
    a_ma_dviT pht_type.a_var; a_kieuT pht_type.a_var; 
    a_so_hdT pht_type.a_var; a_so_idT pht_type.a_num; a_so_id_dtT pht_type.a_num;
begin
-- Dan - Nhap chuan bi ghep tai HANG
if FBH_HD_CDT(b_ma_dvi,b_so_id,0,'F','{"nv":"HANG","kieu_ps":"B"}')<>'C' then
    b_loi:=''; return;
end if;
select ngay_ht,so_hd,nt_tien,nt_phi,hd_kem,kieu_hd into
    b_ngay_ht,b_so_hd,b_nt_tien,b_nt_phi,b_hd_kem,b_kieu_hd
    from bh_hangB where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_kieu_hd not in('G','K') or b_hd_kem='C' then b_loi:=''; return; end if;
PTBH_BAO_TAO_HANG(b_ma_dvi,b_so_id,a_ma_dviT,a_kieuT,a_so_hdT,a_so_idT,b_loi);
if b_loi is not null then return; end if;
for b_lp in 1..a_ma_dviT.count loop
    a_so_id_dtT(b_lp):=0;
end loop;
PTBH_BAO_TLc(b_ma_dvi,b_so_id,0,a_ma_dviT,a_kieuT,a_so_idT,a_so_id_dtT,b_loi);
if b_loi is not null then return; end if;
select count(*) into b_i1 from tbh_ghep_tl_temp where pthuc='O';
if b_i1<>0 then
    PHT_ID_MOI(b_so_id_cbi,b_loi);
    if b_loi is not null then return; end if;
    b_so_ct:=substr(to_char(b_so_id_cbi),3);
    insert into tbh_tmB_cbi values(
        b_so_id_cbi,b_nv,b_so_ct,'G',' ',b_ngay_ht,'B','C',b_ma_dvi,b_so_id,0,b_nt_tien,b_nt_phi,'Phat sinh moi',' ',sysdate);
    for b_lp1 in 1..a_ma_dviT.count loop
        if a_ma_dviT(b_lp1)=b_ma_dvi and a_so_idT(b_lp1)=b_so_id then b_kieu:='B'; else b_kieu:='H'; end if;
        insert into tbh_tmB_cbi_hd values(b_so_id_cbi,b_kieu,a_ma_dviT(b_lp1),a_so_hdT(b_lp1),a_so_idT(b_lp1),0,' ',b_so_id,b_lp1);
    end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TMB_CBI_HANGb:loi'; end if;
end;
/
create or replace procedure PTBH_TMB_CBI_NGb(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_so_id_cbi number;
    b_nv varchar2(10):='NG'; b_ngay_ht number; b_nt_tien varchar2(5);
    b_so_ct varchar2(20); b_nt_phi varchar2(5); b_so_hd varchar2(20);
    a_ma_dviT pht_type.a_var; a_kieuT pht_type.a_var;
    a_so_idT pht_type.a_num; a_so_id_dtT pht_type.a_num;
begin
-- Dan - Chuan bi tai Fac bao gia
a_so_id_dtT(1):=FTBH_BAO_NV_NGd(b_ma_dvi,b_so_id,'B');
if a_so_id_dtT(1)=0 then b_loi:=''; end if;
if FBH_HD_CDT(b_ma_dvi,b_so_id,0,'F','{"nv":"NG","kieu_ps":"B"}')<>'C' then
    b_loi:=''; return;
end if;
select nv,ngay_ht,so_hd,nt_tien,nt_phi into b_nv,b_ngay_ht,b_so_hd,b_nt_tien,b_nt_phi
    from bh_bao where ma_dvi=b_ma_dvi and so_id=b_so_id;
a_ma_dviT(1):=b_ma_dvi; a_so_idT(1):=b_so_id;
PTBH_BAO_TLc(b_ma_dvi,b_so_id,a_so_id_dtT(1),a_ma_dviT,a_kieuT,a_so_idT,a_so_id_dtT,b_loi);
if b_loi is not null then return; end if;
select count(*) into b_i1 from tbh_ghep_tl_temp where pthuc='O';
if b_i1<>0 then
    PHT_ID_MOI(b_so_id_cbi,b_loi);
    if b_loi is not null then return; end if;
    b_so_ct:=substr(to_char(b_so_id_cbi),3);
    insert into tbh_tmB_cbi values(
        b_so_id_cbi,b_nv,b_so_ct,'G',' ',b_ngay_ht,'B','C',b_ma_dvi,b_so_id,0,b_nt_tien,b_nt_phi,'Phat sinh moi',' ',sysdate);
    insert into tbh_tmB_cbi_hd values(b_so_id_cbi,'B',b_ma_dvi,b_so_hd,b_so_id,0,' ',b_so_id,0);
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TMB_CBI_NGb:loi'; end if;
end;
/
create or replace procedure PTBH_TMB_CBI_NGs(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_so_id_cbi number; b_dvi_ta varchar2(10):=FTBH_DVI_TA();
    b_nv varchar2(10):='NG'; b_nt_tien varchar2(5); b_ttrang varchar2(1);
    b_ngay_ht number; b_ngay_hl number; b_ngay_kt number; b_tso varchar2(100);
    b_so_ct varchar2(20); b_so_ctG varchar2(20); b_so_id_gh number;
    b_nt_phi varchar2(5); b_so_hd varchar2(20); b_kieu varchar2(1);
    b_so_idD number; b_so_idB number; b_so_id_taD number;
    a_ma_dviT pht_type.a_var; a_so_hdT pht_type.a_var; a_so_idT pht_type.a_num; a_so_id_dtT pht_type.a_num;
begin
-- Dan - Chuan bi tai Fac soan
b_so_idB:=FBH_HD_SO_ID_BSt(b_ma_dvi,b_so_id);
if b_so_idB=0 then b_loi:=''; end if;
select ttrang,so_hd,ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi,so_id_d into
    b_ttrang,b_so_hd,b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_so_idD
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_idB;
if b_ttrang not in('T','D') or FTBH_TM_FR(b_ma_dvi,b_so_idD)='C' then b_loi:=''; return; end if;
a_ma_dviT(1):=b_ma_dvi; a_so_idT(1):=b_so_idD; a_so_id_dtT(1):=FTBH_BAO_NV_NGd(b_ma_dvi,b_so_idB);
select nvl(max(so_id),0) into b_so_id_gh from tbh_tm_hd where
    ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_idD;
if b_so_id_gh<>0 then
    b_so_id_taD:=FTBH_TM_SO_ID_DAU(b_so_id_gh);        
    select nvl(max(so_idC),0) into b_i1 from tbh_tmB_cbi_hd where FTBH_TM_SO_ID_DAU(so_id,'C')=b_so_id_taD and so_id_hd=b_so_idD;
    if b_i1=b_so_idB then b_loi:=''; return; end if;
    PHT_ID_MOI(b_so_id_cbi,b_loi);
    if b_loi is not null then return; end if;
    select so_ct into b_so_ctG from tbh_tm where so_id=b_so_id_gh;
    b_so_ct:=FTBH_TM_SO_BS(b_so_id_gh);
    insert into tbh_tmB_cbi values(
        b_so_id_cbi,b_nv,b_so_ct,'B',b_so_ctG,b_ngay_ht,'T','C',b_ma_dvi,b_so_idB,0,
        b_nt_tien,b_nt_phi,'Bo sung, sua doi',' ',sysdate);
    insert into tbh_tmB_cbi_nbh select b_so_id_cbi,nbh,pt,hh,kieu,nbhC,bt from tbh_tm_nbh where so_id=b_so_id_gh order by bt;
    insert into tbh_tmB_cbi_hd values(b_so_id_cbi,'H',b_ma_dvi,b_so_hd,b_so_idD,0,' ',b_so_idB,1);
elsif FBH_HD_CDT(b_ma_dvi,b_so_idB,0,'F','{"nv":"NG","kieu_ps":"H"}')='C' then
    b_tso:='{"ttrang":"T","xly":"F"}';
    PTBH_GHEP_TL(0,b_ngay_ht,b_ngay_hl,b_nv,b_nt_tien,b_nt_phi,a_ma_dviT,a_so_idT,a_so_id_dtT,b_loi,b_tso);
    if b_loi is not null then return; end if;
    select count(*) into b_i1 from tbh_ghep_tl_temp where pthuc='O';
    if b_i1<>0 then
        PHT_ID_MOI(b_so_id_cbi,b_loi);
        if b_loi is not null then return; end if;
        b_so_ct:=substr(to_char(b_so_id_cbi),3);
        insert into tbh_tmB_cbi values(
            b_so_id_cbi,b_nv,b_so_ct,'G',' ',b_ngay_ht,'T','C',b_ma_dvi,b_so_idB,0,b_nt_tien,b_nt_phi,'Phat sinh moi',' ',sysdate);
        insert into tbh_tmB_cbi_hd values(b_so_id_cbi,'T',b_ma_dvi,b_so_hd,b_so_idD,0,' ',b_so_idB,0);
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TMB_CBI_NGs:loi'; end if;
end;
/
create or replace procedure PTBH_TMB_CBI_NHds(
    b_ma_dvi varchar2,b_so_id number,b_nv varchar2,b_loi out varchar2)
AS
    b_i1 number; b_so_id_cbi number; b_dvi_ta varchar2(10):=FTBH_DVI_TA();
    b_nt_tien varchar2(5); b_ttrang varchar2(1);
    b_ngay_ht number; b_ngay_hl number; b_ngay_kt number; b_tso varchar2(100);
    b_so_ct varchar2(20); b_so_ctG varchar2(20); b_so_id_gh number;
    b_nt_phi varchar2(5); b_so_hd varchar2(20); b_kieu varchar2(1);
    b_so_idD number; b_so_idB number; b_so_id_taD number;
    a_so_id_dt pht_type.a_num; a_ten pht_type.a_nvar;
    a_ma_dviT pht_type.a_var; a_so_hdT pht_type.a_var; a_so_idT pht_type.a_num; a_so_id_dtT pht_type.a_num;
begin
-- Dan - Nhap chuan bi ghep tai co doi tuong, khong tich tu
b_so_idB:=FBH_HD_SO_ID_BSt(b_ma_dvi,b_so_id);
--nam : lay b_so_hd
select ttrang,ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi,so_id_d,so_hd into
    b_ttrang,b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_so_idD,b_so_hd
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_idB;
if b_ttrang not in('T','D') or FTBH_TM_FR(b_ma_dvi,b_so_idD)='C' then b_loi:=''; return; end if;
PBH_HD_DS_DT_ARRt(b_ma_dvi,b_so_idD,a_so_id_dt,a_ten);
a_ma_dviT(1):=b_ma_dvi; a_so_idT(1):=b_so_idD;
for b_lp in 1..a_so_id_dt.count loop
    select nvl(max(so_id),0) into b_so_id_gh from tbh_tm_hd where
        ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_idD and so_id_dt=a_so_id_dt(b_lp);
    if b_so_id_gh<>0 then
        b_so_id_taD:=FTBH_TM_SO_ID_DAU(b_so_id_gh);
        select nvl(max(so_idC),0) into b_i1 from tbh_tmB_cbi_hd where FTBH_TM_SO_ID_DAU(so_id,'C')=b_so_id_taD and so_id_hd=b_so_idD;
        if b_i1=b_so_idB then continue; end if;
        PHT_ID_MOI(b_so_id_cbi,b_loi);
        if b_loi is not null then return; end if;
        select so_ct into b_so_ctG from tbh_tm where so_id=b_so_id_gh;
        b_so_ct:=FTBH_TM_SO_BS(b_so_id_gh);
        insert into tbh_tmB_cbi values(
            b_so_id_cbi,b_nv,b_so_ct,'B',b_so_ctG,b_ngay_ht,'T','C',b_ma_dvi,b_so_idB,0,
            b_nt_tien,b_nt_phi,'Bo sung, sua doi',' ',sysdate);
        insert into tbh_tmB_cbi_nbh select b_so_id_cbi,nbh,pt,hh,kieu,nbhC,bt from tbh_tm_nbh where so_id=b_so_id_gh order by bt;
        insert into tbh_tmB_cbi_hd values(b_so_id_cbi,'H',b_ma_dvi,b_so_hd,b_so_idD,a_so_id_dt(b_lp),' ',b_so_idB,1);
    --nam
    elsif FBH_HD_CDT(b_ma_dvi,b_so_idB,a_so_id_dt(b_lp),'F','{"nv":"'||b_nv||'","kieu_ps":"H"}')='C' then
        a_so_id_dtT(1):=a_so_id_dt(b_lp);
        b_tso:='{"ttrang":"T","xly":"F"}';
        PTBH_GHEP_TL(0,b_ngay_ht,b_ngay_hl,b_nv,b_nt_tien,b_nt_phi,a_ma_dviT,a_so_idT,a_so_id_dtT,b_loi,b_tso);
        if b_loi is not null then return; end if;
        select count(*) into b_i1 from tbh_ghep_tl_temp where pthuc='O';
        if b_i1=0 then continue; end if;
        PHT_ID_MOI(b_so_id_cbi,b_loi);
        if b_loi is not null then return; end if;
        --nam
        b_so_ct:=substr(to_char(b_so_id_cbi),3);
        insert into tbh_tmB_cbi values(
            b_so_id_cbi,b_nv,b_so_ct,'G',' ',b_ngay_ht,'T','C',b_ma_dvi,b_so_idB,a_so_id_dt(b_lp),b_nt_tien,b_nt_phi,'Phat sinh moi',' ',sysdate);
        for b_lp1 in 1..a_ma_dviT.count loop
          insert into tbh_tmB_cbi_hd values(
                b_so_id_cbi,'T',a_ma_dviT(b_lp1),b_so_hd,a_so_idT(b_lp1),a_so_id_dtT(b_lp1),'',b_so_idB,b_lp1);
        end loop;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TMB_CBI_NHds:loi'; end if;
end;
/
create or replace procedure PTBH_TMB_CBI_NHd(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_kt number; b_so_id_cbi number:=0;
    b_nv varchar2(10); b_nt_tien varchar2(5); b_fr varchar2(1);
    b_ngay_ht number; b_ngay_hl number; b_ngay_kt number; b_tso varchar2(100);
    b_so_ct varchar2(20); b_ttrang varchar2(1);
    b_nt_phi varchar2(5); b_so_hd varchar2(20); b_so_idD number;
    a_so_id_dt pht_type.a_num; a_ten pht_type.a_nvar;
    a_ma_dviT pht_type.a_var; a_so_hdT pht_type.a_var; a_so_idT pht_type.a_num; a_so_id_dtT pht_type.a_num;
begin
-- Dan - Nhap chuan bi ghep tai co doi tuong, khong tich tu
select ttrang,ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi,so_id_d,nv into
    b_ttrang,b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_so_idD,b_nv
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_ttrang not in('T','D') or b_fr not in(' ','F') or FTBH_TM_FR(b_ma_dvi,b_so_id)='C' then b_loi:=''; return; end if;
PBH_HD_DS_DT_ARRt(b_ma_dvi,b_so_id,a_so_id_dt,a_ten);
a_ma_dviT(1):=b_ma_dvi; a_so_idT(1):=b_so_id;
for b_lp in 1..a_so_id_dt.count loop
    if FBH_HD_CDT(b_ma_dvi,b_so_id,a_so_id_dt(b_lp),'F','{"nv":"'||b_nv||'"}')<>'C' then continue; end if;
    a_so_id_dtT(1):=a_so_id_dt(b_lp);
    b_tso:='{"ttrang":"T","xly":"F"}';
    PTBH_GHEP_TL(0,b_ngay_ht,b_ngay_hl,b_nv,b_nt_tien,b_nt_phi,a_ma_dviT,a_so_idT,a_so_id_dtT,b_loi,b_tso);
    if b_loi is not null then return; end if;
    select count(*) into b_i1 from tbh_ghep_tl_temp where pthuc='O';
    if b_i1<>0 then
        PHT_ID_MOI(b_so_id_cbi,b_loi);
        if b_loi is not null then return; end if;
        b_so_ct:=substr(to_char(b_so_id_cbi),3);
        insert into tbh_tmB_cbi values(
            b_so_id_cbi,b_nv,b_so_ct,'G',' ',b_ngay_ht,'T','C',b_ma_dvi,b_so_id,a_so_id_dt(b_lp),
            b_nt_tien,b_nt_phi,'Phat sinh moi',' ',sysdate);
        insert into tbh_tmB_cbi_hd values(b_so_id_cbi,'T',b_ma_dvi,b_so_hd,b_so_id,a_so_id_dt(b_lp),a_ten(b_lp),b_so_id,1);
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TMB_CBI_NHd:loi'; end if;
end;
/
create or replace procedure PTBH_TMB_CBI_NHdb(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_so_id_cbi number;
    b_nv varchar2(10); b_ngay_ht number; b_nt_tien varchar2(5);
    b_so_ct varchar2(20); b_nt_phi varchar2(5); b_so_hd varchar2(20);
    a_so_id_dt pht_type.a_num; a_ten pht_type.a_nvar;
    a_ma_dviT pht_type.a_var; a_kieuT pht_type.a_var;
    a_so_hdT pht_type.a_var; a_so_idT pht_type.a_num; a_so_id_dtT pht_type.a_num;
begin
-- Dan - Nhap chuan bi ghep tai, co doi tuong khong tich tu
select nv,ngay_ht,so_hd,nt_tien,nt_phi into
    b_nv,b_ngay_ht,b_so_hd,b_nt_tien,b_nt_phi
    from bh_bao where ma_dvi=b_ma_dvi and so_id=b_so_id;
PBH_BAO_DS_DT_ARRt(b_ma_dvi,b_so_id,a_so_id_dt,a_ten);
a_ma_dviT(1):=b_ma_dvi; a_so_idT(1):=b_so_id;
for b_lp in 1..a_so_id_dt.count loop
    if FBH_HD_CDT(b_ma_dvi,b_so_id,a_so_id_dt(b_lp),'F','{"nv":"'||b_nv||'","kieu_ps":"B"}')<>'C' then continue; end if;
    a_so_id_dtT(1):=a_so_id_dt(b_lp);
    PTBH_BAO_TLc(b_ma_dvi,b_so_id,a_so_id_dt(b_lp),a_ma_dviT,a_kieuT,a_so_idT,a_so_id_dtT,b_loi);
    if b_loi is not null then return; end if;
    select count(*) into b_i1 from tbh_ghep_tl_temp where pthuc='O';
    if b_i1<>0 then
        PHT_ID_MOI(b_so_id_cbi,b_loi);
        if b_loi is not null then return; end if;
        b_so_ct:=substr(to_char(b_so_id_cbi),3);
        insert into tbh_tmB_cbi values(
            b_so_id_cbi,b_nv,b_so_ct,'G',' ',b_ngay_ht,'B','C',b_ma_dvi,b_so_id,a_so_id_dt(b_lp),
            b_nt_tien,b_nt_phi,'Phat sinh moi',' ',sysdate);
        insert into tbh_tmB_cbi_hd values(b_so_id_cbi,'B',b_ma_dvi,b_so_hd,b_so_id,a_so_id_dt(b_lp),a_ten(b_lp),b_so_id,1);
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TMB_CBI_NHdb:loi'; end if;
end;
/
create or replace procedure PTBH_TMB_CBI_NHhs(
    b_ma_dvi varchar2,b_so_id number,b_nv varchar2,b_loi out varchar2)
AS
    b_i1 number; b_so_id_cbi number; b_dvi_ta varchar2(10):=FTBH_DVI_TA();
    b_nt_tien varchar2(5); b_ttrang varchar2(1);
    b_ngay_ht number; b_ngay_hl number; b_ngay_kt number; b_tso varchar2(100);
    b_so_ct varchar2(20); b_so_ctG varchar2(20); b_so_id_gh number;
    b_nt_phi varchar2(5); b_so_hd varchar2(20); b_kieu varchar2(1);
    b_so_idD number; b_so_idB number; b_so_id_taD number;
    a_ma_dviT pht_type.a_var; a_so_hdT pht_type.a_var; a_so_idT pht_type.a_num; a_so_id_dtT pht_type.a_num;
begin
-- Dan - Nhap chuan bi ghep tai, khong co doi tuong, khong tich tu
b_so_idB:=FBH_HD_SO_ID_BSt(b_ma_dvi,b_so_id);
--nam : lay b_so_hd
select ttrang,ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi,so_id_d,so_hd into
    b_ttrang,b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_so_idD,b_so_hd
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_idB;
if b_ttrang not in('T','D') or FTBH_TM_FR(b_ma_dvi,b_so_idD)='C' then b_loi:=''; return; end if;
a_ma_dviT(1):=b_ma_dvi; a_so_idT(1):=b_so_id; a_so_id_dtT(1):=0;
select nvl(max(so_id),0) into b_so_id_gh from tbh_tm_hd where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_idD;
if b_so_id_gh<>0 then
    b_so_id_taD:=FTBH_TM_SO_ID_DAU(b_so_id_gh);        
    select nvl(max(so_idC),0) into b_i1 from tbh_tmB_cbi_hd where FTBH_TM_SO_ID_DAU(so_id,'C')=b_so_id_taD and so_id_hd=b_so_idD;
    if b_i1<>b_so_idB then
        select so_ct into b_so_ctG from tbh_tm where so_id=b_so_id_gh;
        PHT_ID_MOI(b_so_id_cbi,b_loi);
        if b_loi is not null then return; end if;
        b_so_ct:=FTBH_TM_SO_BS(b_so_id_gh);
        insert into tbh_tmB_cbi values(
            b_so_id_cbi,b_nv,b_so_ct,'B',b_so_ctG,b_ngay_ht,'T','C',b_ma_dvi,b_so_idB,0,
            b_nt_tien,b_nt_phi,'Bo sung, sua doi',' ',sysdate);
        insert into tbh_tmB_cbi_nbh select b_so_id_cbi,nbh,pt,hh,kieu,nbhC,bt from tbh_tm_nbh where so_id=b_so_id_gh order by bt;
        insert into tbh_tmB_cbi_hd values(b_so_id_cbi,'H',b_ma_dvi,b_so_hd,b_so_id,0,' ',b_so_idB,1);
    end if;
elsif FBH_HD_CDT(b_ma_dvi,b_so_idB,0,'F','{"nv":"'||b_nv||'","kieu_ps":"H"}')='C' then
    b_tso:='{"ttrang":"T","xly":"F"}';
    PTBH_GHEP_TL(0,b_ngay_ht,b_ngay_hl,b_nv,b_nt_tien,b_nt_phi,a_ma_dviT,a_so_idT,a_so_id_dtT,b_loi,b_tso);
    if b_loi is not null then return; end if;
    select count(*) into b_i1 from tbh_ghep_tl_temp where pthuc='O';
    if b_i1<>0 then
        PHT_ID_MOI(b_so_id_cbi,b_loi);
        if b_loi is not null then return; end if;
        b_so_ct:=substr(to_char(b_so_id_cbi),3);
        insert into tbh_tmB_cbi values(
            b_so_id_cbi,b_nv,b_so_ct,'G',' ',b_ngay_ht,'T','C',b_ma_dvi,b_so_idB,0,b_nt_tien,b_nt_phi,'Phat sinh moi',' ',sysdate);
        insert into tbh_tmB_cbi_hd values(b_so_id_cbi,'T',b_ma_dvi,b_so_hd,b_so_id,0,' ',b_so_idB,0);
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TMB_CBI_NHhs:loi'; end if;
end;
/
create or replace procedure PTBH_TMB_CBI_NHhb(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_so_id_cbi number;
    b_nv varchar2(10); b_ngay_ht number; b_nt_tien varchar2(5);
    b_so_ct varchar2(20); b_so_id_gh number;
    b_nt_phi varchar2(5); b_so_hd varchar2(20);
    a_ma_dviT pht_type.a_var; a_kieuT pht_type.a_var;
    a_so_hdT pht_type.a_var; a_so_idT pht_type.a_num; a_so_id_dtT pht_type.a_num;
begin
-- Dan - Nhap chuan bi ghep tai doi tuong khong tich tu
select nv,ngay_ht,so_hd,nt_tien,nt_phi into b_nv,b_ngay_ht,b_so_hd,b_nt_tien,b_nt_phi
    from bh_bao where ma_dvi=b_ma_dvi and so_id=b_so_id;
if FBH_HD_CDT(b_ma_dvi,b_so_id,0,'F','{"nv":"'||b_nv||'","kieu_ps":"B"}')<>'C' then b_loi:=''; return; end if;
a_ma_dviT(1):=b_ma_dvi; a_so_idT(1):=b_so_id; a_so_id_dtT(1):=0;
PTBH_BAO_TLc(b_ma_dvi,b_so_id,0,a_ma_dviT,a_kieuT,a_so_idT,a_so_id_dtT,b_loi);
if b_loi is not null then return; end if;
select count(*) into b_i1 from tbh_ghep_tl_temp where pthuc='O';
if b_i1<>0 then
    PHT_ID_MOI(b_so_id_cbi,b_loi);
    if b_loi is not null then return; end if;
    b_so_ct:=substr(to_char(b_so_id_cbi),3);
    insert into tbh_tmB_cbi values(
        b_so_id_cbi,b_nv,b_so_ct,'G',' ',b_ngay_ht,'B','C',b_ma_dvi,b_so_id,0,b_nt_tien,b_nt_phi,'Phat sinh moi',' ',sysdate);
    insert into tbh_tmB_cbi_hd values(b_so_id_cbi,'B',b_ma_dvi,b_so_hd,b_so_id,0,' ',b_so_id,0);
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TMB_CBI_NHhb:loi'; end if;
end;
/
create or replace procedure PTBH_TMB_CBI_XOA(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2,b_nh varchar2:='X')
AS
    b_i1 number; b_ttrang varchar2(1);
    a_so_id pht_type.a_num;
begin
-- Dan - Xoa chuan bi chao tai tam thoi
select count(*) into b_i1 from tbh_tmB_cbi where ma_dviP=b_ma_dvi and so_idP=b_so_id and kieu_xl='D';
if b_i1<>0 and b_nh='X' then b_loi:='loi:Da xu ly chao tai tam thoi:loi'; return; end if;
select distinct so_id bulk collect into a_so_id from tbh_tmB_cbi where ma_dviP=b_ma_dvi and so_idP=b_so_id;
forall b_lp in 1..a_so_id.count
    delete tbh_tmB_cbi_hd where so_id=a_so_id(b_lp);
forall b_lp in 1..a_so_id.count
    delete tbh_tmB_cbi where so_id=a_so_id(b_lp);
select nvl(min(ttrang),' ') into b_ttrang from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_ttrang='D' then
    select distinct so_id bulk collect into a_so_id from tbh_cbi where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id;
    forall b_lp in 1..a_so_id.count
        delete tbh_cbi_nbh where so_id=a_so_id(b_lp);
    forall b_lp in 1..a_so_id.count
        delete tbh_cbi_hd where so_id=a_so_id(b_lp);
    forall b_lp in 1..a_so_id.count
        delete tbh_cbi where so_id=a_so_id(b_lp);
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
create or replace procedure PTBH_TMB_CBI_NH(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2,b_dk varchar2:='N')
AS
    b_i1 number; b_nv varchar2(10); b_kieu varchar2(1):='H'; b_kieu_hd varchar2(1):='H';
begin
-- Dan - Nhap chuan bi ghep tai
PTBH_TMB_CBI_XOA(b_ma_dvi,b_so_id,b_loi,b_dk);
if b_loi is not null then return; end if;
select nvl(min(nv),' '),nvl(min(kieu_hd),'G') into b_nv,b_kieu_hd from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nv=' ' then
    select nvl(min(nv),' ') into b_nv from bh_bao where ma_dvi=b_ma_dvi and so_id=b_so_id;
    b_kieu:='B';
end if;
if b_nv=' ' then b_loi:=''; return; end if;
select count(*) into b_i1 from tbh_tmB_cbi where ma_dviP=b_ma_dvi and so_idP=b_so_id;
if b_i1<>0 then b_loi:=''; return; end if;
if b_nv='PHH' then
    if b_kieu='B' then
        PTBH_TMB_CBI_PHHb(b_ma_dvi,b_so_id,b_loi);
    else
        PTBH_TMB_CBI_PHHs(b_ma_dvi,b_so_id,b_loi);        
    end if;
elsif b_nv='PKT' then
    if b_kieu='B' then
        PTBH_TMB_CBI_PKTb(b_ma_dvi,b_so_id,b_loi);
    else
        PTBH_TMB_CBI_PKTs(b_ma_dvi,b_so_id,b_loi);        
    end if;
elsif b_nv='HANG' then
    if b_kieu='B' then
        PTBH_TMB_CBI_HANGb(b_ma_dvi,b_so_id,b_loi);
    else
        PTBH_TMB_CBI_HANGs(b_ma_dvi,b_so_id,b_loi);        
    end if;
elsif b_nv='NG' then
    if b_kieu='B' then
        PTBH_TMB_CBI_NGb(b_ma_dvi,b_so_id,b_loi);
    else
        PTBH_TMB_CBI_NGs(b_ma_dvi,b_so_id,b_loi);   
    end if;
elsif b_nv in('XE','TAU','2B') then
    if b_kieu='B' then
        PTBH_TMB_CBI_NHdb(b_ma_dvi,b_so_id,b_loi);
    else
        PTBH_TMB_CBI_NHds(b_ma_dvi,b_so_id,b_nv,b_loi);        
    end if;
else
    if b_kieu='B' then
        PTBH_TMB_CBI_NHhb(b_ma_dvi,b_so_id,b_loi);
    else
        PTBH_TMB_CBI_NHhs(b_ma_dvi,b_so_id,b_nv,b_loi);        
    end if;
end if;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TMB_CBI_NH:loi'; end if;
end;
/
