create or replace procedure PTBH_CBI_NH_PHH(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_kt number; b_so_id_cbi number:=0; b_kieu_xl varchar2(1);
    b_nv varchar2(10):='PHH'; b_ngay_ht number; b_nt_ta varchar2(5);
    b_so_ct varchar2(20); b_so_ctG varchar2(20); b_so_id_gh number;
    b_nt_phi varchar2(5); b_dvi_ta varchar2(10); b_so_hd varchar2(20);
    b_ten nvarchar2(500); b_kieu varchar2(1); b_tso varchar2(200);
    b_so_idD number; b_so_idB number; b_ngay_kt number; b_ngay_hl number;
    a_so_id_dt pht_type.a_num; a_so_idC pht_type.a_num; a_tenT pht_type.a_nvar;
    a_ma_dviT pht_type.a_var; a_so_hdT pht_type.a_var; a_so_idT pht_type.a_num; a_so_id_dtT pht_type.a_num;
begin
-- Dan - Nhap chuan bi ghep tai PHH
b_dvi_ta:=FTBH_DVI_TA();
if b_dvi_ta is null then b_loi:=''; return; end if;
b_so_idB:=FBH_HD_SO_ID_BSd(b_ma_dvi,b_so_id);
if b_so_idB=0 then b_loi:=''; return; end if;
select ngay_ht,ngay_hl,so_hd,nt_tien,nt_phi,so_id_d into
    b_ngay_ht,b_ngay_hl,b_so_hd,b_nt_ta,b_nt_phi,b_so_idD
    from bh_phh where ma_dvi=b_ma_dvi and so_id=b_so_idB;
PBH_HD_DS_DT_ARR(b_ma_dvi,b_so_idB,a_so_id_dt,b_nv);
for b_lp in 1..a_so_id_dt.count loop
    PTBH_TMB_CBI_PHH(b_ma_dvi,b_so_idD,a_so_id_dt(b_lp),a_ma_dviT,a_so_hdT,a_tenT,a_so_idT,a_so_id_dtT,b_loi,'D');
    if b_loi is not null then return; end if;
    for b_lp in 1..a_ma_dviT.count loop
        for r_lp in(select distinct so_id from tbh_cbi_hd where ma_dvi_hd=a_ma_dviT(b_lp) and
            so_id_hd=a_so_idT(b_lp) and so_id_dt=a_so_id_dtT(b_lp)) loop
            b_i1:=FKH_ARR_VTRI_N(a_so_idC,r_lp.so_id);
            if b_i1=0 then
                b_i1:=a_so_idC.count+1; a_so_idC(b_i1):=r_lp.so_id;
            end if;
        end loop;
    end loop;
    for b_lp in 1..a_so_idC.count loop
        delete tbh_cbi_hd where so_id=a_so_idC(b_lp);
        delete tbh_cbi where so_id=a_so_idC(b_lp);
    end loop;
    b_tso:='{"xly":"C","ttrang":"D"}';
    PTBH_GHEP_TL(0,b_ngay_ht,b_ngay_hl,b_nv,b_nt_ta,b_nt_phi,a_ma_dviT,a_so_idT,a_so_id_dtT,b_loi,b_tso);
    if b_loi is not null then return; end if;
    for b_lp1 in 1..a_ma_dviT.count loop
        select nvl(max(so_id),0) into b_so_id_gh from tbh_ghep_hd where
            ma_dvi_hd=a_ma_dviT(b_lp1) and so_id_hd=a_so_idT(b_lp1) and so_id_dt=a_so_id_dtT(b_lp1);
        if b_so_id_gh<>0 then exit; end if;
    end loop;
    if b_so_id_gh<>0 then
        select nvl(max(so_idC),0) into b_i1 from tbh_ghep_hd where so_id=b_so_id_gh and so_id_hd=b_so_idD;
        if b_i1=b_so_idB then continue; end if;
        select so_ct into b_so_ctG from tbh_ghep where so_id=b_so_id_gh;
        PHT_ID_MOI(b_so_id_cbi,b_loi);
        if b_loi is not null then return; end if;
        b_so_ct:=FTBH_SO_BS(b_so_id_gh);
        insert into tbh_cbi values(b_dvi_ta,b_so_id_cbi,b_nv,b_so_ct,'B',b_so_ctG,b_ngay_ht,
            'B','C','K',b_ma_dvi,b_so_id,b_nt_ta,b_nt_phi,0,'Bo sung, sua doi, ghep them','',sysdate);
        b_i1:=0;
        for r_lp in (select * from tbh_ghep_hd where so_id=b_so_id_gh order by bt) loop
            insert into tbh_cbi_hd values(b_dvi_ta,b_so_id_cbi,r_lp.ma_dvi_hd,r_lp.so_hd,r_lp.so_id_hd,r_lp.so_id_dt,r_lp.bt);
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
                insert into tbh_cbi_hd values(b_dvi_ta,b_so_id_cbi,a_ma_dviT(b_lp1),a_so_hdT(b_lp1),a_so_idT(b_lp1),a_so_id_dtT(b_lp1),b_i1);
            end if;
        end loop;
    else
        select count(*) into b_i1 from tbh_ghep_tl_temp where pthuc in('Q','S');
        if b_i1<>0 AND FBH_HD_CDT(b_ma_dvi,b_so_idB,0,'C','{"nv":"'||b_nv||'"}')='C' then
            PHT_ID_MOI(b_so_id_cbi,b_loi);
            if b_loi is not null then return; end if;
            b_so_ct:=substr(to_char(b_so_id_cbi),3);
            insert into tbh_cbi values(b_dvi_ta,b_so_id_cbi,b_nv,b_so_ct,'G',' ',
                b_ngay_ht,'G','C','K',b_ma_dvi,b_so_id,b_nt_ta,b_nt_phi,0,'Phat sinh moi','',sysdate);
            for b_lp1 in 1..a_ma_dviT.count loop
                insert into tbh_cbi_hd values(b_dvi_ta,b_so_id_cbi,a_ma_dviT(b_lp1),a_so_hdT(b_lp1),a_so_idT(b_lp1),a_so_id_dtT(b_lp1),b_lp1);
            end loop;
        end if;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_CBI_NH_PHH:loi'; else null; end if;
end;
/
create or replace procedure PTBH_CBI_NH_PKT(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_kt number; b_so_id_cbi number:=0; b_kieu_xl varchar2(1);
    b_nv varchar2(10):='PKT'; b_ngay_ht number; b_nt_ta varchar2(5);
    b_so_ct varchar2(20); b_so_ctG varchar2(20); b_so_id_gh number;
    b_nt_phi varchar2(5); b_dvi_ta varchar2(10); b_so_hd varchar2(20);
    b_ten nvarchar2(500); b_kieu varchar2(1); b_tso varchar2(200);
    b_so_idD number; b_so_idB number; b_ngay_kt number; b_ngay_hl number;
    a_so_id_dt pht_type.a_num; a_so_idC pht_type.a_num; a_tenT pht_type.a_nvar;
    a_ma_dviT pht_type.a_var; a_so_hdT pht_type.a_var; a_so_idT pht_type.a_num; a_so_id_dtT pht_type.a_num;
begin
-- Dan - Nhap chuan bi ghep tai PKT
b_dvi_ta:=FTBH_DVI_TA();
if b_dvi_ta is null then b_loi:=''; return; end if;
b_so_idB:=FBH_HD_SO_ID_BSd(b_ma_dvi,b_so_id);
if b_so_idB=0 then b_loi:=''; return; end if;
select ngay_ht,ngay_hl,so_hd,nt_tien,nt_phi,so_id_d into
    b_ngay_ht,b_ngay_hl,b_so_hd,b_nt_ta,b_nt_phi,b_so_idD
    from bh_pkt where ma_dvi=b_ma_dvi and so_id=b_so_idB;
PBH_HD_DS_DT_ARR(b_ma_dvi,b_so_idB,a_so_id_dt,b_nv);
for b_lp in 1..a_so_id_dt.count loop
    PTBH_TMB_CBI_PKT(b_ma_dvi,b_so_idD,a_so_id_dt(b_lp),a_ma_dviT,a_so_hdT,a_tenT,a_so_idT,a_so_id_dtT,b_loi,'D');
    if b_loi is not null then return; end if;
    for b_lp in 1..a_ma_dviT.count loop
        for r_lp in(select distinct so_id from tbh_cbi_hd where ma_dvi_hd=a_ma_dviT(b_lp) and
            so_id_hd=a_so_idT(b_lp) and so_id_dt=a_so_id_dtT(b_lp)) loop
            b_i1:=FKH_ARR_VTRI_N(a_so_idC,r_lp.so_id);
            if b_i1=0 then
                b_i1:=a_so_idC.count+1; a_so_idC(b_i1):=r_lp.so_id;
            end if;
        end loop;
    end loop;
    for b_lp in 1..a_so_idC.count loop
        delete tbh_cbi_hd where so_id=a_so_idC(b_lp);
        delete tbh_cbi where so_id=a_so_idC(b_lp);
    end loop;
    b_tso:='{"xly":"C","ttrang":"D"}';
    PTBH_GHEP_TL(0,b_ngay_ht,b_ngay_hl,b_nv,b_nt_ta,b_nt_phi,a_ma_dviT,a_so_idT,a_so_id_dtT,b_loi,b_tso);
    if b_loi is not null then return; end if;
    for b_lp1 in 1..a_ma_dviT.count loop
        select nvl(max(so_id),0) into b_so_id_gh from tbh_ghep_hd where
            ma_dvi_hd=a_ma_dviT(b_lp1) and so_id_hd=a_so_idT(b_lp1) and so_id_dt=a_so_id_dtT(b_lp1);
        if b_so_id_gh<>0 then exit; end if;
    end loop;
    if b_so_id_gh<>0 then
        select nvl(max(so_idC),0) into b_i1 from tbh_ghep_hd where so_id=b_so_id_gh and so_id_hd=b_so_idD;
        if b_i1=b_so_idB then continue; end if;
        select so_ct into b_so_ctG from tbh_ghep where so_id=b_so_id_gh;
        PHT_ID_MOI(b_so_id_cbi,b_loi);
        if b_loi is not null then return; end if;
        b_so_ct:=FTBH_SO_BS(b_so_id_gh);
        insert into tbh_cbi values(b_dvi_ta,b_so_id_cbi,b_nv,b_so_ct,'B',b_so_ctG,b_ngay_ht,
            'B','C','K',b_ma_dvi,b_so_id,b_nt_ta,b_nt_phi,0,'Bo sung, sua doi, ghep them','',sysdate);
        b_i1:=0;
        for r_lp in (select * from tbh_ghep_hd where so_id=b_so_id_gh order by bt) loop
            insert into tbh_cbi_hd values(b_dvi_ta,b_so_id_cbi,r_lp.ma_dvi_hd,r_lp.so_hd,r_lp.so_id_hd,r_lp.so_id_dt,r_lp.bt);
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
                insert into tbh_cbi_hd values(b_dvi_ta,b_so_id_cbi,a_ma_dviT(b_lp1),a_so_hdT(b_lp1),a_so_idT(b_lp1),a_so_id_dtT(b_lp1),b_i1);
            end if;
        end loop;
    else
        select count(*) into b_i1 from tbh_ghep_tl_temp where pthuc in('Q','S');
        if b_i1<>0 AND FBH_HD_CDT(b_ma_dvi,b_so_idB,0,'C','{"nv":"'||b_nv||'"}')='C' then
            PHT_ID_MOI(b_so_id_cbi,b_loi);
            if b_loi is not null then return; end if;
            b_so_ct:=substr(to_char(b_so_id_cbi),3);
            insert into tbh_cbi values(b_dvi_ta,b_so_id_cbi,b_nv,b_so_ct,'G',' ',
                b_ngay_ht,'G','C','K',b_ma_dvi,b_so_id,b_nt_ta,b_nt_phi,0,'Phat sinh moi','',sysdate);
            for b_lp1 in 1..a_ma_dviT.count loop
                insert into tbh_cbi_hd values(b_dvi_ta,b_so_id_cbi,a_ma_dviT(b_lp1),a_so_hdT(b_lp1),a_so_idT(b_lp1),a_so_id_dtT(b_lp1),b_lp1);
            end loop;
        end if;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_CBI_NH_PKT:loi'; else null; end if;
end;
/
create or replace procedure PTBH_CBI_NH_HANG(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_kt number; b_so_id_cbi number:=0; b_kieu_xl varchar2(1);
    b_nv varchar2(10):='HANG'; b_ngay_ht number; b_nt_ta varchar2(5);
    b_so_ct varchar2(20); b_so_ctG varchar2(20); b_so_id_gh number;
    b_nt_phi varchar2(5); b_dvi_ta varchar2(10); b_so_hd varchar2(20); b_tso varchar2(200);
    b_so_idD number; b_so_idB number; b_ngay_kt number; b_ngay_hl number;
    b_hd_kem varchar2(1); b_kieu_hd varchar2(1);
    a_ma_dviT pht_type.a_var; a_so_hdT pht_type.a_var; a_so_idT pht_type.a_num; a_so_id_dtT pht_type.a_num;
    a_so_idC pht_type.a_num;
begin
-- Dan - Nhap chuan bi ghep tai HANG
b_dvi_ta:=FTBH_DVI_TA();
if b_dvi_ta is null then b_loi:=''; return; end if;
b_so_idB:=FBH_HD_SO_ID_BSd(b_ma_dvi,b_so_id);
if b_so_idB=0 then b_loi:=''; return; end if;
select ngay_ht,ngay_cap,so_hd,nt_tien,nt_phi,hd_kem,kieu_hd,so_id_d into
    b_ngay_ht,b_ngay_hl,b_so_hd,b_nt_ta,b_nt_phi,b_hd_kem,b_kieu_hd,b_so_idD
    from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_idB;
if b_kieu_hd not in('G','K') or b_hd_kem<>'K' then b_loi:=''; return; end if;
PTBH_TMB_CBI_HANG(b_ma_dvi,b_so_idD,a_ma_dviT,a_so_hdT,a_so_idT,b_loi,'D');
if b_loi is not null then return; end if;
if a_ma_dviT.count=0 then b_loi:=''; return; end if;
PKH_MANG_KD_N(a_so_idC);
for b_lp in 1..a_ma_dviT.count loop
    for r_lp in(select distinct so_id from tbh_cbi_hd where ma_dvi_hd=a_ma_dviT(b_lp) and so_id_hd=a_so_idT(b_lp)) loop
        b_i1:=FKH_ARR_VTRI_N(a_so_idC,r_lp.so_id);
        if b_i1=0 then
            b_i1:=a_so_idC.count+1; a_so_idC(b_i1):=r_lp.so_id;
        end if;
    end loop;
    a_so_id_dtT(b_lp):=0;
end loop;
for b_lp in 1..a_so_idC.count loop
    delete tbh_cbi_hd where so_id=a_so_idC(b_lp);
    delete tbh_cbi where so_id=a_so_idC(b_lp);
end loop;
b_tso:='{"xly":"C","ttrang":"D"}';
PTBH_GHEP_TL(0,b_ngay_ht,b_ngay_hl,b_nv,b_nt_ta,b_nt_phi,a_ma_dviT,a_so_idT,a_so_id_dtT,b_loi,b_tso);
if b_loi is not null then return; end if;
for b_lp1 in 1..a_ma_dviT.count loop
    select nvl(max(so_id),0) into b_so_id_gh from tbh_ghep_hd where
        ma_dvi_hd=a_ma_dviT(b_lp1) and so_id_hd=a_so_idT(b_lp1) and FTBH_GHEP_NGAYk(so_id,b_ngay_ht)='C';
    if b_so_id_gh<>0 then exit; end if;
end loop;
if b_so_id_gh<>0 then
    select nvl(max(so_idC),0) into b_i1 from tbh_ghep_hd where so_id=b_so_id_gh and so_id_hd=b_so_idD;
    if b_i1<>b_so_idB then
        select so_ct into b_so_ctG from tbh_ghep where so_id=b_so_id_gh;
        PHT_ID_MOI(b_so_id_cbi,b_loi);
        if b_loi is not null then return; end if;
        b_so_ct:=FTBH_SO_BS(b_so_id_gh);
        insert into tbh_cbi values(b_dvi_ta,b_so_id_cbi,b_nv,b_so_ct,'B',b_so_ctG,b_ngay_ht,
            'B','C','K',b_ma_dvi,b_so_id,b_nt_ta,b_nt_phi,0,'Bo sung, sua doi, ghep them','',sysdate);
        b_i1:=0;
        for r_lp in (select * from tbh_ghep_hd where so_id=b_so_id_gh order by bt) loop
            insert into tbh_cbi_hd values(b_dvi_ta,b_so_id_cbi,r_lp.ma_dvi_hd,r_lp.so_hd,r_lp.so_id_hd,0,r_lp.bt);
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
                insert into tbh_cbi_hd values(b_dvi_ta,b_so_id_cbi,a_ma_dviT(b_lp1),a_so_hdT(b_lp1),a_so_idT(b_lp1),0,b_i1);
            end if;
        end loop;

    end if;
else
    select count(*) into b_i1 from tbh_ghep_tl_temp where pthuc in('Q','S');
    if b_i1<>0 AND FBH_HD_CDT(b_ma_dvi,b_so_idB,0,'C','{"nv":"'||b_nv||'"}')='C' then
        PHT_ID_MOI(b_so_id_cbi,b_loi);
        if b_loi is not null then return; end if;
        b_so_ct:=substr(to_char(b_so_id_cbi),3);
        insert into tbh_cbi values(b_dvi_ta,b_so_id_cbi,b_nv,b_so_ct,'G',' ',
            b_ngay_ht,'G','C','K',b_ma_dvi,b_so_id,b_nt_ta,b_nt_phi,0,'Phat sinh moi','',sysdate);
        for b_lp1 in 1..a_ma_dviT.count loop
            insert into tbh_cbi_hd values(b_dvi_ta,b_so_id_cbi,a_ma_dviT(b_lp1),a_so_hdT(b_lp1),a_so_idT(b_lp1),0,b_lp1);
        end loop;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_CBI_NH_HANG:loi'; else null; end if;
end;
/
create or replace procedure PTBH_CBI_NH_NHd(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_kt number; b_so_id_cbi number:=0; b_kieu_xl varchar2(1);
    b_nv varchar2(10); b_ngay_ht number; b_nt_ta varchar2(5);
    b_so_ct varchar2(20); b_so_ctG varchar2(20); b_so_id_gh number;
    b_nt_phi varchar2(5); b_dvi_ta varchar2(10); b_so_hd varchar2(20); b_tso varchar2(200);
    b_so_idD number; b_so_idB number; b_ngay_kt number; b_ngay_hl number;
    a_so_id_dt pht_type.a_num;
    a_ma_dviT pht_type.a_var; a_so_idT pht_type.a_num; a_so_id_dtT pht_type.a_num;
begin
-- Dan - Nhap chuan bi ghep tai doi tuong khong tich tu
b_dvi_ta:=FTBH_DVI_TA();
if b_dvi_ta is null then b_loi:=''; return; end if;
b_so_idB:=FBH_HD_SO_ID_BSd(b_ma_dvi,b_so_id);
if b_so_idB=0 then b_loi:=''; return; end if;
select nv,ngay_ht,ngay_hl,so_hd,nt_tien,nt_phi,so_id_d into
    b_nv,b_ngay_ht,b_ngay_hl,b_so_hd,b_nt_ta,b_nt_phi,b_so_idD
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_idB;
PBH_HD_DS_DTt_ARR(b_ma_dvi,b_so_idB,a_so_id_dt);
a_ma_dviT(1):=b_ma_dvi; a_so_idT(1):=b_so_id;
b_tso:='{"xly":"C","ttrang":"D"}';
for b_lp in 1..a_so_id_dt.count loop
    a_so_id_dtT(1):=a_so_id_dt(b_lp);
    PTBH_GHEP_TL(0,b_ngay_ht,b_ngay_hl,b_nv,b_nt_ta,b_nt_phi,a_ma_dviT,a_so_idT,a_so_id_dtT,b_loi,b_tso);
    if b_loi is not null then return; end if;
    for b_lp1 in 1..a_ma_dviT.count loop
        select nvl(max(so_id),0) into b_so_id_gh from tbh_ghep_hd where
            ma_dvi_hd=a_ma_dviT(b_lp1) and so_id_hd=a_so_idT(b_lp1) and 
            so_id_dt=a_so_id_dtT(b_lp1) and FTBH_GHEP_NGAYk(so_id,b_ngay_ht)='C';
        if b_so_id_gh<>0 then exit; end if;
    end loop;
    if b_so_id_gh<>0 then
        select nvl(max(so_idC),0) into b_i1 from tbh_ghep_hd where so_id=b_so_id_gh and so_id_hd=b_so_idD;
        if b_i1<>b_so_idB then
            select so_ct into b_so_ctG from tbh_ghep where so_id=b_so_id_gh;
            PHT_ID_MOI(b_so_id_cbi,b_loi);
            if b_loi is not null then return; end if;
            b_so_ct:=FTBH_SO_BS(b_so_id_gh);
            insert into tbh_cbi values(b_dvi_ta,b_so_id_cbi,b_nv,b_so_ct,'B',b_so_ctG,b_ngay_ht,
                'B','C','K',b_ma_dvi,b_so_id,b_nt_ta,b_nt_phi,0,'Bo sung, sua doi','',sysdate);
            insert into tbh_cbi_hd select b_dvi_ta,b_so_id_cbi,ma_dvi_hd,so_hd,so_id_hd,so_id_dt,bt
                from tbh_ghep_hd where so_id=b_so_id_gh;
        end if;
    else
        select count(*) into b_i1 from tbh_ghep_tl_temp where pthuc in('Q','S');
        if b_i1<>0 AND FBH_HD_CDT(b_ma_dvi,b_so_idB,0,'C','{"nv":"'||b_nv||'"}')='C' then
            PHT_ID_MOI(b_so_id_cbi,b_loi);
            if b_loi is not null then return; end if;
            b_so_ct:=substr(to_char(b_so_id_cbi),3);
            insert into tbh_cbi values(b_dvi_ta,b_so_id_cbi,b_nv,b_so_ct,'G',' ',
                b_ngay_ht,'G','C','K',b_ma_dvi,b_so_id,b_nt_ta,b_nt_phi,0,'Phat sinh moi','',sysdate);
            insert into tbh_cbi_hd values(b_dvi_ta,b_so_id_cbi,b_ma_dvi,b_so_hd,b_so_idD,a_so_id_dt(b_lp),0);
        end if;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_CBI_NH_NHd:loi'; else null; end if;
end;
/
create or replace procedure PTBH_CBI_NH_NHh(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_kt number; b_so_id_cbi number:=0; b_kieu_xl varchar2(1);
    b_nv varchar2(10); b_ngay_ht number; b_nt_ta varchar2(5);
    b_so_ct varchar2(20); b_so_ctG varchar2(20); b_so_id_gh number;
    b_nt_phi varchar2(5); b_dvi_ta varchar2(10); b_so_hd varchar2(20); b_tso varchar2(200);
    b_so_idD number; b_so_idB number; b_ngay_kt number; b_ngay_hl number;
    a_ma_dviT pht_type.a_var; a_so_idT pht_type.a_num; a_so_id_dtT pht_type.a_num;
begin
-- Dan - Nhap chuan bi ghep tai hop dong khong tich tu
b_dvi_ta:=FTBH_DVI_TA();
if b_dvi_ta is null then b_loi:=''; return; end if;
b_so_idB:=FBH_HD_SO_ID_BSd(b_ma_dvi,b_so_id);
if b_so_idB=0 then b_loi:=''; return; end if;
select nv,ngay_ht,ngay_hl,so_hd,nt_tien,nt_phi,so_id_d into
    b_nv,b_ngay_ht,b_ngay_hl,b_so_hd,b_nt_ta,b_nt_phi,b_so_idD
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_idB;
a_ma_dviT(1):=b_ma_dvi; a_so_idT(1):=b_so_id; a_so_id_dtT(1):=0;
b_tso:='{"xly":"C","ttrang":"D"}';
PTBH_GHEP_TL(0,b_ngay_ht,b_ngay_hl,b_nv,b_nt_ta,b_nt_phi,a_ma_dviT,a_so_idT,a_so_id_dtT,b_loi,b_tso);
if b_loi is not null then return; end if;
select nvl(max(so_id),0) into b_so_id_gh from tbh_ghep_hd where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_idD;
for b_lp1 in 1..a_ma_dviT.count loop
    select nvl(max(so_id),0) into b_so_id_gh from tbh_ghep_hd where
        ma_dvi_hd=a_ma_dviT(b_lp1) and so_id_hd=a_so_idT(b_lp1);
    if b_so_id_gh<>0 then exit; end if;
end loop;
if b_so_id_gh<>0 then
    select nvl(max(so_idC),0) into b_i1 from tbh_ghep_hd where so_id=b_so_id_gh and so_id_hd=b_so_idD;
    if b_i1<>b_so_idB then
        select so_ct into b_so_ctG from tbh_ghep where so_id=b_so_id_gh;
        PHT_ID_MOI(b_so_id_cbi,b_loi);
        if b_loi is not null then return; end if;
        b_so_ct:=FTBH_SO_BS(b_so_id_gh);
        insert into tbh_cbi values(b_dvi_ta,b_so_id_cbi,b_nv,b_so_ct,'B',b_so_ctG,b_ngay_ht,
            'B','C','K',b_ma_dvi,b_so_id,b_nt_ta,b_nt_phi,0,'Bo sung, sua doi','',sysdate);
        insert into tbh_cbi_hd select b_dvi_ta,b_so_id_cbi,ma_dvi_hd,so_hd,so_id_hd,0,0
            from tbh_ghep_hd where so_id=b_so_id_gh;
    end if;
else
    select count(*) into b_i1 from tbh_ghep_tl_temp where pthuc in('Q','S');
    if b_i1<>0 AND FBH_HD_CDT(b_ma_dvi,b_so_idB,0,'C','{"nv":"'||b_nv||'"}')='C' then
        PHT_ID_MOI(b_so_id_cbi,b_loi);
        if b_loi is not null then return; end if;
        b_so_ct:=substr(to_char(b_so_id_cbi),3);
        insert into tbh_cbi values(b_dvi_ta,b_so_id_cbi,b_nv,b_so_ct,'G',' ',
            b_ngay_ht,'G','C','K',b_ma_dvi,b_so_id,b_nt_ta,b_nt_phi,0,'Phat sinh moi','',sysdate);
        insert into tbh_cbi_hd values(b_dvi_ta,b_so_id_cbi,b_ma_dvi,b_so_hd,b_so_idD,0,0);
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_CBI_NH_NHh:loi'; else null; end if;
end;
/
