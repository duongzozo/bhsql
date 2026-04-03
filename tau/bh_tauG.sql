create or replace procedure PBH_TAUG_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_ngay number:=PKH_NG_CSO(sysdate);
    cs_sp clob; cs_khd clob; cs_kbt clob; cs_tltg clob; cs_ttt clob;
begin
-- Dan - Tham so mo form
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten) into cs_sp from
    bh_tau_sp a,(select distinct ma_sp from bh_tau_phi where ngay_bd<=b_ngay and ngay_kt>b_ngay) b
    where a.ma=b.ma_sp and FBH_TAU_SP_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_khd
    from bh_kh_ttt where ps='KHD' and nv='TAU';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_kbt
    from bh_kh_ttt where ps='KBT' and nv='TAU';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_ttt
    from bh_kh_ttt where ps='HD' and nv='TAU';
select JSON_ARRAYAGG(json_object('tltg' value tltg,'tlph' value tlph) order by tltg desc returning clob) into cs_tltg
    from bh_tau_tltg where b_ngay between ngay_bd and ngay_kt;
select json_object('cs_sp' value cs_sp,'cs_khd' value cs_khd,
    'cs_kbt' value cs_kbt,'cs_tltg' value cs_tltg,'cs_ttt' value cs_ttt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAUG_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number;
    dt_ct clob; dt_dk clob; dt_dkbs clob:=''; dt_lt clob:=''; dt_kbt clob:=''; dt_hu clob:=''; dt_kytt clob:=''; dt_ttt clob:=''; dt_txt clob;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','TAU','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
if b_so_id=0 then b_loi:='loi:Chon GCN:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
select json_object(
    'nhom' value FBH_TAU_NHOM_TENl(nhom),'loai' value FBH_TAU_LOAI_TENl(loai),
    'cap' value FBH_TAU_CAP_TENl(cap),'vlieu' value FBH_TAU_VLIEU_TENl(vlieu),
    'hoi' value FBH_TAU_HOI_TENl(hoi),'dkien' value FBH_TAU_DKC_TENl(dkien) returning clob)
    into dt_ct from bh_tau_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ngay,tien) order by ngay) into dt_kytt from bh_tau_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ma,so_id) order by bt returning clob) into dt_dk from bh_tau_dk
    where ma_dvi=b_ma_dvi and so_id=b_so_id and bt<10000;
select JSON_ARRAYAGG(json_object(ma,so_id) order by bt returning clob) into dt_dkbs from bh_tau_dk
    where ma_dvi=b_ma_dvi and so_id=b_so_id and bt>10000;
select count(*) into b_i1 from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_lt';
if b_i1<>0 then
    select txt into dt_lt from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_lt';
end if;
select count(*) into b_i1 from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_kbt';
if b_i1<>0 then
    select txt into dt_kbt from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_kbt';
end if;
select count(*) into b_i1 from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hu';
if b_i1<>0 then
    select txt into dt_hu from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hu';
end if;
select count(*) into b_i1 from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
if b_i1<>0 then
    select txt into dt_ttt from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
end if;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai in('dt_ct','dt_dk','dt_dkbs');
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,
    'dt_lt' value dt_lt,'dt_kbt' value dt_kbt,'dt_hu' value dt_hu,'dt_kytt' value dt_kytt,'dt_ttt' value dt_ttt,
    'dt_ct' value dt_ct,'dt_dk' value dt_dk,'dt_dkbs' value dt_dkbs,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAUG_TESTr(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_idD number,dt_ct clob,dt_dk clob,dt_dkbs clob,
    b_so_hd in out varchar2,
    b_tenC out nvarchar2,b_cmtC out varchar2,b_mobiC out varchar2,
    b_emailC out varchar2,b_dchiC out nvarchar2,b_ng_huong out nvarchar2,

    b_so_dk out varchar2, b_ten_tau out nvarchar2, b_qtich out varchar2,
    b_pvi out nvarchar2,
    b_nhom out varchar2, b_loai out varchar2, b_cap out varchar2, b_vlieu out varchar2,
    b_csuat out number, b_so_cn out number, b_ttai out number, b_dtich out number, b_vtoc out number,
    b_nam_sx out number, b_hcai out varchar2, b_gia out number, b_tvo out number, b_may out number, b_tbi out number, b_tuoi out number,
    b_ma_sp out varchar2, b_dkien out varchar2, b_md_sd out varchar2, b_nv_bh out varchar2,
    b_hoi out varchar2, b_hoi_tien out number, b_hoi_tyle out number, b_hoi_hh out number, b_tl_mgiu out number, b_tau_id out number,
    b_tb out varchar2,

    dk_bt out pht_type.a_num,dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,
    dk_tc out pht_type.a_var,dk_ma_ct out pht_type.a_var,dk_kieu out pht_type.a_var,
    dk_tien out pht_type.a_num,dk_pt out pht_type.a_num,dk_phi out pht_type.a_num,
    dk_thue out pht_type.a_num,dk_ttoan out pht_type.a_num,
    dk_cap out pht_type.a_num,dk_ma_dk out pht_type.a_var,
    dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,dk_ptB out pht_type.a_num,
    dk_ptG out pht_type.a_num,dk_phiG out pht_type.a_num,
    dk_lkeP out pht_type.a_var,dk_lkeB out pht_type.a_var,dk_luy out pht_type.a_var,b_loi out varchar2)
AS
    b_i1 number; b_kt number; b_ktG number;
    b_lenh varchar2(2000); dt_khd clob; b_txt clob;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_c_thue varchar2(1);
    b_thueH number; b_ttoanH number; b_tygia number; b_tp number:=0;
    b_ttrang varchar2(1); b_ngay_hl number; b_ngay_kt number;
    b_loai_khH varchar2(1); b_ma_khH varchar2(20); b_tenH nvarchar2(500);
    b_cmtH varchar2(20); b_mobiH varchar2(20); b_emailH varchar2(20); b_dchiH nvarchar2(400);
    b_ten nvarchar2(500); b_so_idP number; b_ma_dk varchar2(10); b_loai_khC varchar2(1);
    dk_nv pht_type.a_var; dk_phiB pht_type.a_num;
    b_nv_bhC varchar2(10); a_nv pht_type.a_var;

    dk_maX pht_type.a_var; dk_tenX pht_type.a_nvar; dk_tcX pht_type.a_var;
    dk_ma_ctX pht_type.a_var; dk_kieuX pht_type.a_var;
    dk_ma_dkX pht_type.a_var; dk_tienX pht_type.a_num; dk_ptX pht_type.a_num;
    dk_phiX pht_type.a_num; dk_thueX pht_type.a_num; dk_lkePX pht_type.a_var; dk_lkeBX pht_type.a_var; dk_luyX pht_type.a_var;
    dk_lh_nvX pht_type.a_var; dk_t_suatX pht_type.a_num; dk_nvX pht_type.a_var; dk_capX pht_type.a_num;
    dk_ptBX pht_type.a_num; dk_phiBX pht_type.a_num;
    
    dk_lkeM pht_type.a_var; dk_lkeMX pht_type.a_var;
begin
-- Dan - Nhap
b_lenh:='so_dk,ten_tau,qtich,pvi,vtoc,nam_sx,hcai,tvo,may,tbi,';
b_lenh:=b_lenh||'hoi,hoi_tien,hoi_tyle,hoi_hh,tl_mgiu,';
b_lenh:=b_lenh||'ttrang,nt_tien,nt_phi,tygia,c_thue,thue,ttoan,';
b_lenh:=b_lenh||'ten,loai_khc,tenc,cmtc,mobic,emailc,dchic,';
b_lenh:=b_lenh||'nvv,nvt,nvd,nvn';
b_lenh:=FKH_JS_LENH(b_lenh);
EXECUTE IMMEDIATE b_lenh into
    b_so_dk,b_ten_tau,b_qtich,b_pvi,b_vtoc,b_nam_sx,b_hcai,b_tvo,b_may,b_tbi,
    b_hoi,b_hoi_tien,b_hoi_tyle,b_hoi_hh,b_tl_mgiu,
    b_ttrang,b_nt_tien,b_nt_phi,b_tygia,b_c_thue,b_thueH,b_ttoanH,
    b_ten,b_loai_khC,b_tenC,b_cmtC,b_mobiC,b_emailC,b_dchiC,
    a_nv(1),a_nv(2),a_nv(3),a_nv(4) using dt_ct;
PBH_TAU_BPHI_TSO(
    dt_ct,b_nhom,b_loai,b_cap,b_vlieu,b_ttai,b_so_cn,b_dtich,b_csuat,b_gia,b_tuoi,
    b_ma_sp,b_dkien,b_md_sd,b_nv_bh,b_ngay_hl,b_ngay_kt,b_ngay_hl,b_loi);
if b_loi is not null then return; end if;
if trim(b_tenC) is null then
    b_lenh:=FKH_JS_LENH('ten,cmt,mobi,email,dchi');
    EXECUTE IMMEDIATE b_lenh into b_tenC,b_cmtC,b_mobiC,b_emailC,b_dchiC using dt_ct;
end if;
b_loai_khC:=nvl(trim(b_loai_khC),'C'); b_tenC:=nvl(trim(b_tenC),' '); b_tenC:=nvl(trim(b_tenC),' '); b_cmtC:=nvl(trim(b_cmtC),' ');
b_mobiC:=nvl(trim(b_mobiC),' '); b_emailC:=nvl(trim(b_emailC),' '); b_dchiC:=nvl(trim(b_dchiC),' ');
if b_so_dk=' ' and b_ten_tau=' ' then
    b_loi:='loi:Nhap so dang ky, ten tau:loi'; return;
end if;
if b_nam_sx=0 then
    b_loi:='loi:Nhap nam dong tau:loi'; return;
end if;
if b_nhom<>' ' and FBH_TAU_NHOM_HAN(b_nhom)<>'C' then
    b_loi:='loi:Sai nhom tau:loi'; return;
end if;
if b_loai<>' ' and FBH_TAU_LOAI_HAN(b_loai)<>'C' then
    b_loi:='loi:Sai loai tau:loi'; return;
end if;
if b_cap<>' ' and FBH_TAU_CAP_HAN(b_cap)<>'C' then
    b_loi:='loi:Sai cap tau:loi'; return;
end if;
if b_vlieu<>' ' and FBH_TAU_VLIEU_HAN(b_vlieu)<>'C' then
    b_loi:='loi:Sai vat lieu dong tau:loi'; return;
end if;
if b_ma_sp<>' ' and FBH_TAU_SP_HAN(b_ma_sp)<>'C' then
    b_loi:='loi:Sai ma san pham:loi'; return;
end if;
if b_md_sd not in(' ','H','N','C') then
    b_loi:='loi:Sai muc dich su dung:loi'; return;
end if;
if b_hoi<>' ' and FBH_TAU_HOI_HAN(b_hoi)<>'C' then
    b_loi:='loi:Sai ma hoi:loi'; return;
end if;
b_nt_tien:=nvl(trim(b_nt_tien),'VND'); b_nt_phi:=nvl(trim(b_nt_phi),'VND');
if b_nt_phi<>'VND' then b_tp:=2; end if;
b_lenh:=FKH_JS_LENH('nv,ma,ten,tc,ma_ct,kieu,tien,pt,phi,thue,cap,ma_dk,lh_nv,t_suat,ptb,phib,lkem,lkep,lkeb,luy');
EXECUTE IMMEDIATE b_lenh bulk collect into
    dk_nv,dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_thue,dk_cap,
    dk_ma_dk,dk_lh_nv,dk_t_suat,dk_ptB,dk_phiB,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy using dt_dk;
b_kt:=dk_ma.count; b_ktG:=b_kt;
if b_kt=0 then b_loi:='loi:Nhap dieu khoan:loi'; return; end if;
for b_lp in 1..dk_ma.count loop
    dk_bt(b_lp):=b_lp;
end loop;
EXECUTE IMMEDIATE b_lenh bulk collect into
    dk_nvX,dk_maX,dk_tenX,dk_tcX,dk_ma_ctX,dk_kieuX,dk_tienX,dk_ptX,dk_phiX,dk_thueX,dk_capX,
    dk_ma_dkX,dk_lh_nvX,dk_t_suatX,dk_ptBX,dk_phiBX,dk_lkeMX,dk_lkePX,dk_lkeBX,dk_luyX using dt_dkbs;
for b_lp in 1..dk_maX.count loop
    b_kt:=b_kt+1;
    dk_bt(b_kt):=b_lp+10000;
    dk_nv(b_kt):='M'; dk_ma(b_kt):=dk_maX(b_lp); dk_ten(b_kt):=dk_tenX(b_lp);
    dk_tc(b_kt):=dk_tcX(b_lp); dk_ma_ct(b_kt):=dk_ma_ctX(b_lp); dk_kieu(b_kt):=dk_kieuX(b_lp);
    dk_tien(b_kt):=dk_tienX(b_lp); dk_pt(b_kt):=dk_ptX(b_lp);
    dk_phi(b_kt):=dk_phiX(b_lp); dk_thue(b_kt):=dk_thueX(b_lp);
    dk_cap(b_kt):=dk_capX(b_lp); dk_ma_dk(b_kt):=dk_ma_dkX(b_lp); dk_lh_nv(b_kt):=dk_lh_nvX(b_lp);
    dk_t_suat(b_kt):=dk_t_suatX(b_lp); dk_ptB(b_kt):=dk_ptBX(b_lp); dk_phiB(b_kt):=dk_phiBX(b_lp);
    dk_lkeM(b_kt):=dk_lkeMX(b_lp); dk_lkeP(b_kt):=dk_lkePX(b_lp); dk_lkeB(b_kt):=dk_lkeBX(b_lp); dk_luy(b_kt):=dk_luyX(b_lp);
end loop;
for b_lp in 1..dk_ma.count loop
    dk_nv(b_lp):=nvl(trim(dk_nv(b_lp)),' '); dk_ma(b_lp):=trim(dk_ma(b_lp));
    if dk_ma(b_lp) is null then b_loi:='loi:Loi nhap chi tiet nghiep vu dong '||to_char(b_lp)||':loi'; return; end if;
    dk_lh_nv(b_lp):=nvl(trim(dk_lh_nv(b_lp)),' '); dk_tien(b_lp):=nvl(dk_tien(b_lp),0);
    dk_phi(b_lp):=nvl(dk_phi(b_lp),0); dk_phiB(b_lp):=nvl(dk_phiB(b_lp),0);
    if dk_tien(b_lp)=0 and dk_lkeM(b_lp) not in ('T','N','K') and dk_kieu(b_lp)='T' then 
      b_loi:='loi:Chua nhap muc trach nhiem dieu khoan '||dk_ma(b_lp)||':loi'; return; 
    end if;
    if dk_phi(b_lp)<0 then dk_phi(b_lp):=0; end if;
    if b_c_thue='K' then dk_thue(b_lp):=0; else dk_thue(b_lp):=nvl(dk_thue(b_lp),0); end if;
    dk_ttoan(b_lp):=dk_phi(b_lp)+dk_thue(b_lp);
    if dk_tien(b_lp)<>0 then
      b_i1:=round(dk_phiB(b_lp)/dk_tien(b_lp)*100,20); 
      dk_pt(b_lp):= b_i1 - round(((dk_phiB(b_lp)/dk_tien(b_lp))-(dk_phi(b_lp)/dk_tien(b_lp)))*100 ,20);
    end if; 
end loop;
for b_lp in 1..dk_maX.count loop
    b_ma_dk:=FBH_MA_DKBS_MA_DK(dk_maX(b_lp));
    if b_ma_dk<>' ' then
        b_i1:=FKH_ARR_VTRI(dk_ma_dk,b_ma_dk);
        if b_i1 not between 1 and b_ktG then
            b_loi:='loi:Dieu khoan bo sung '||dk_ma_dkX(b_lp)||' phai gan kem dieu khoan chinh '||b_ma_dk||':loi'; return;
        end if;
    end if;
end loop;
b_nv_bh:='';
for b_lp in 1..4 loop
    a_nv(b_lp):=nvl(trim(a_nv(b_lp)),' ');
    if a_nv(b_lp)='C' then
        a_nv(b_lp):=substr('VTDN',b_lp,1);
        PKH_GHEP(b_nv_bh,a_nv(b_lp),'');
    else
        a_nv(b_lp):=' ';
    end if;
end loop;
b_tau_id:=FBH_TAUTSO_SO_ID(b_so_dk);
if b_nv_bh is null then b_loi:='loi:Chua chon loai phi mua:loi'; return; end if;
if b_tau_id<>0 then
    for r_lp in(select distinct nv_bh from bh_tau_ds where tau_id=b_tau_id and so_id_dt<>b_so_idD and
        FKH_GIAO(b_ngay_hl,b_ngay_kt,ngay_hl,ngay_kt)='C' and FBH_TAU_TTRANG(ma_dvi,so_id,'C')='D') loop
        b_nv_bhC:=r_lp.nv_bh; b_i1:=length(b_nv_bhC);
        for b_lp in 1..b_i1 loop
            if instr(b_nv_bh,substr(b_nv_bhC,b_lp,1))<>0 then
               b_tb:='Trung thoi gian bao hiem'; exit;
            end if;
        end loop;
    end loop;
else
    PHT_ID_MOI(b_tau_id,b_loi);
    if b_loi is not null then return; end if;
end if;
PBH_HD_THAY_PHIg(b_nt_tien,b_nt_phi,b_tygia,b_thueH,b_ttoanH,dk_lh_nv,dk_tien,dk_phi,dk_thue,dk_ttoan,b_loi);
if b_loi is not null then return; end if;
for b_lp in 1..dk_ma.count loop
    if dk_phiB(b_lp)>dk_phi(b_lp) then
        dk_phiG(b_lp):=dk_phiB(b_lp)-dk_phi(b_lp);
        dk_ptG(b_lp):=round(dk_phiG(b_lp)*100/dk_phiB(b_lp),2);
    else
        dk_ptG(b_lp):=0; dk_phiG(b_lp):=0;
    end if;
end loop;
b_ng_huong:='';
if b_ttrang in('T','D') then
    b_lenh:=FKH_JS_LENH('loai_khh,tenh,dchih,cmth,mobih,emailh');
    EXECUTE IMMEDIATE b_lenh into b_loai_khH,b_tenH,b_dchiH,b_cmtH,b_mobiH,b_emailH using dt_ct;
    if trim(b_tenH) is not null then
        select json_object('loai' value b_loai_khH,'ten' value b_tenH,'cmt' value b_cmtH,
            'dchi' value b_dchiH,'mobi' value b_mobiH,'email' value b_emailH) into b_txt from dual;
        PBH_DTAC_MA_NH(b_txt,b_ma_khH,b_loi,b_ma_dvi,b_nsd);
        b_ng_huong:=b_tenH;
        if trim(b_cmtH) is not null then
            if b_loai_khH='C' then
                b_ng_huong:=b_tenH||', so CMT/CCCD: '||b_cmtH;
            else
                b_ng_huong:=b_tenH||', ma thue : '||b_cmtH;
            end if;
        end if;
        if trim(b_dchiH) is not null then
            b_ng_huong:=b_tenH||', dia chi: '||b_dchiH;
        end if;
    end if;
    if b_ten<>b_tenC then
        select json_object('loai' value b_loai_khC,'ten' value b_tenC,'cmt' value b_cmtC,
            'dchi' value b_dchiH,'mobi' value b_mobiC,'email' value b_emailC) into b_txt from dual;
        PBH_DTAC_MA_NH(b_txt,b_ma_khH,b_loi,b_ma_dvi,b_nsd);
    end if;
    select count(*) into b_i1 from bh_tau_phi_txt where so_id=b_so_idP and loai='dt_khd';
    if b_i1<>0 then
        select txt into dt_khd from bh_tau_phi_txt where so_id=b_so_idP and loai='dt_khd';
        b_i1:=length(dt_khd)-2;
        dt_khd:=substr(dt_khd,2,b_i1);
        PBH_TAUG_KHD(dt_ct,dt_dk,dt_khd,b_loi);
        if b_loi is not null then return; end if;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_TAUG_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    dt_ct in out clob,dt_dk clob,dt_dkbs clob,dt_lt clob,dt_kbt clob,dt_hu clob,dt_kytt clob,dt_ttt clob,
-- Chung
    b_so_hd in out varchar2,b_ngay_ht number,b_ttrang varchar2,b_kieu_hd varchar2,b_so_hd_g varchar2,
    b_kieu_kt varchar2,b_ma_kt varchar2,b_kieu_gt varchar2,b_ma_gt varchar2,b_ma_cb varchar2,
    b_so_hdL varchar2,b_loai_kh varchar2,b_ma_kh varchar2,b_ten nvarchar2,b_dchi nvarchar2, 
    b_cmt varchar2,b_mobi varchar2,b_email varchar2,
    b_gio_hl varchar2,b_ngay_hl number,b_gio_kt varchar2,b_ngay_kt number,b_ngay_cap number,
    b_nt_tien varchar2,b_nt_phi varchar2,b_c_thue varchar2,
    b_phi number,b_giam number,b_thue number,b_ttoan number,b_hhong number,
    b_so_idG number,b_so_idD number,b_ngayD number,b_phong varchar2,
    tt_ngay pht_type.a_num,tt_tien pht_type.a_num,
-- Rieng
    b_tenC nvarchar2,b_cmtC varchar2,b_mobiC varchar2,
    b_emailC varchar2,b_dchiC nvarchar2,b_ng_huong nvarchar2,
    
    b_so_dk varchar2, b_ten_tau nvarchar2, b_qtich varchar2,
    b_pvi nvarchar2, 
    b_nhom varchar2, b_loai varchar2, b_cap varchar2, b_vlieu varchar2,
    b_csuat number, b_so_cn number, b_ttai number, b_dtich number, b_vtoc number, 
    b_nam_sx number, b_hcai varchar2, b_gia number, b_tvo number, b_may number, b_tbi number, b_tuoi number,
    b_ma_sp varchar2, b_dkien varchar2, b_md_sd varchar2, b_nv_bh varchar2,
    b_hoi varchar2, b_hoi_tien number, b_hoi_tyle number, b_hoi_hh number, b_tl_mgiu number, b_tau_id number,
    dk_bt pht_type.a_num,dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tc pht_type.a_var,
    dk_ma_ct pht_type.a_var,dk_kieu pht_type.a_var,
    dk_tien pht_type.a_num,dk_pt pht_type.a_num,dk_phi pht_type.a_num,
    dk_thue pht_type.a_num,dk_ttoan pht_type.a_num,dk_cap pht_type.a_num,dk_ma_dk pht_type.a_var,
    dk_lh_nv pht_type.a_var,dk_t_suat pht_type.a_num,dk_ptB pht_type.a_num,
    dk_ptG pht_type.a_num,dk_phiG pht_type.a_num,
    dk_lkeP pht_type.a_var,dk_lkeB pht_type.a_var,dk_luy pht_type.a_var,b_loi out varchar2)
AS
    b_i1 number; b_so_id_kt number:=-1; b_tien number:=0; b_ma_ke varchar2(20):=' '; b_txt clob;
begin
-- Dan - Nhap
b_loi:='loi:Loi Table bh_tau:loi';
if b_ttrang='D' then b_so_id_kt:=0; end if;
for b_lp in 1..dk_lh_nv.count loop
    if dk_lh_nv(b_lp)<>' ' and dk_kieu(b_lp)='T' then b_tien:=b_tien+dk_tien(b_lp); end if;
    insert into bh_tau_dk values(b_ma_dvi,b_so_id,b_so_idD,dk_bt(b_lp),
        dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),dk_kieu(b_lp),dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),
        dk_cap(b_lp),dk_ma_dk(b_lp),dk_lh_nv(b_lp),dk_t_suat(b_lp),dk_thue(b_lp),dk_ttoan(b_lp),
        dk_ptB(b_lp),dk_ptG(b_lp),dk_phiG(b_lp),dk_lkeP(b_lp),dk_lkeB(b_lp),dk_luy(b_lp));
end loop;
insert into bh_tau values(
    b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,'G',b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
    b_phong,b_so_hdL,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,
    b_nt_tien,b_nt_phi,b_c_thue,1,b_tien,
    b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,'','',b_so_id_kt,b_nsd,sysdate);
insert into bh_tau_ds values(b_ma_dvi,b_so_id,b_so_idD,0,b_kieu_hd,b_so_hd,b_so_hd_g,
    b_tenC,b_cmtC,b_mobiC,b_emailC,b_dchiC,b_ng_huong,
    b_nhom,b_loai,b_cap,b_vlieu,b_ttai,b_so_cn,b_dtich,b_csuat,b_gia,b_tuoi,b_ma_sp,b_dkien,b_md_sd,b_nv_bh,
    b_so_dk,b_ten_tau,b_nam_sx,b_hoi,b_hoi_tien,b_hoi_tyle,b_hoi_hh,b_tl_mgiu,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_giam,b_phi,b_thue,b_ttoan,b_tau_id);
delete bh_tau_ID where tau_id=b_tau_id;
insert into bh_tau_ID values(b_tau_id,b_ten_tau,' ',b_so_dk,b_loai,b_cap,b_qtich,b_vlieu,b_vtoc,
            b_ttai,b_csuat,b_dtich,b_so_cn,b_gia,b_tvo,b_may,b_tbi,b_nam_sx,b_hcai,b_pvi);
for b_lp in 1..tt_ngay.count loop
    insert into bh_tau_tt values(b_ma_dvi,b_so_id,tt_ngay(b_lp),tt_tien(b_lp));
end loop;
PKH_JS_THAYa(dt_ct,'so_hd,ma_kh',b_so_hd||','||b_ma_kh);
insert into bh_tau_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
insert into bh_tau_txt values(b_ma_dvi,b_so_id,'dt_dk',dt_dk);
if trim(dt_dkbs) is not null then
    insert into bh_tau_txt values(b_ma_dvi,b_so_id,'dt_dkbs',dt_dkbs);
end if;
if trim(dt_lt) is not null then
    insert into bh_tau_txt values(b_ma_dvi,b_so_id,'dt_lt',dt_lt);
end if;
if trim(dt_kbt) is not null then
    insert into bh_tau_txt values(b_ma_dvi,b_so_id,'dt_kbt',dt_kbt);
end if;
if trim(dt_hu) is not null then
    insert into bh_tau_txt values(b_ma_dvi,b_so_id,'dt_hu',dt_hu);
end if;
if trim(dt_kytt) is not null then
    insert into bh_tau_txt values(b_ma_dvi,b_so_id,'dt_kytt',dt_kytt);
end if;
if trim(dt_ttt) is not null then
    insert into bh_tau_txt values(b_ma_dvi,b_so_id,'dt_ttt',dt_ttt);
end if;
if b_ttrang in('T','D') then
    if dt_dkbs is null then
        b_txt:=dt_dk;
    else
        b_i1:=length(dt_dk)-1;
        b_txt:=substr(dt_dk,1,b_i1)||','||substr(dt_dkbs,2);
    end if;
    insert into bh_tau_kbt values(b_ma_dvi,b_so_id,b_so_idD,b_txt,dt_lt,dt_kbt);
    select json_object('ma_dvi' value b_ma_dvi,'nsd' value b_nsd,'so_id' value b_so_id,'so_hd' value b_so_hd,
        'kieu_hd' value b_kieu_hd,'nv' value 'TAU','ngay_ht' value b_ngay_ht,'ngay_cap' value b_ngay_cap,
        'ngay_hl' value b_ngay_hl,'ngay_kt' value b_ngay_kt,'cb_ql' value b_ma_cb,'phong' value b_phong,
        'kieu_kt' value b_kieu_kt,'ma_kt' value b_ma_kt,'dly_tke' value ' ','hhong' value b_hhong,
        'pt_hhong' value 'D','ma_kh' value b_ma_kh,'ten' value b_ten,'kieu_gt' value b_kieu_gt,
        'ma_gt' value b_ma_gt,'so_id_d' value b_so_idD,'so_id_g' value b_so_idG,'ttrang' value b_ttrang,
        'dvi_ksoat' value b_ma_dvi,'ksoat' value b_nsd,'bangg' value 'bh_tau',
        'c_thue' value b_c_thue,'nt_tien' value b_nt_tien,'nt_phi' value b_nt_phi,'tien' value b_tien,
        'phi' value b_ttoan-b_thue,'thue' value b_thue returning clob) into b_txt from dual;
    PBH_HD_GOC_NH(b_txt,b_loi);
    if b_loi is not null then return; end if;
end if;
if b_ttrang='D' then
    PBH_KE_CTI_NHOM(b_ma_dvi,b_so_idD,b_so_idD,b_ma_ke,b_loi);
    if b_loi is not null then return; end if;
    insert into bh_hd_goc_ttindt values(
        b_ma_dvi,b_so_idD,b_so_idD,'TAU',b_so_dk||' -- '||b_ten_tau,b_ma_kh,b_ngay_kt,' ',b_ma_ke);
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_TAUG_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(3000); b_lenh varchar2(2000); b_i1 number;
    dt_ct clob; dt_dk clob; dt_dkbs clob; dt_lt clob; dt_kbt clob; dt_hu clob; dt_kytt clob; dt_ttt clob;
-- Chung
    b_so_id number; b_so_hd varchar2(20); b_ngay_ht number; b_ttrang varchar2(1); b_kieu_hd varchar2(1); b_so_hd_g varchar2(20);
    b_kieu_kt varchar2(1); b_ma_kt varchar2(20); b_kieu_gt varchar2(1); b_ma_gt varchar2(20); b_ma_cb varchar2(20);
    b_loai_kh varchar2(1); b_ma_kh varchar2(20); b_ten nvarchar2(500); b_dchi nvarchar2(500);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_gio_hl varchar2(20); b_ngay_hl number; b_gio_kt varchar2(20); b_ngay_kt number; b_ngay_cap number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_c_thue varchar2(1);
    b_tl_giam number; b_phi number; b_giam number; b_thue number; b_ttoan number; b_hhong number;
    b_so_idG number; b_so_idD number; b_ngayD number; b_phong varchar2(10);
    tt_ngay pht_type.a_num; tt_tien pht_type.a_num;
-- Rieng
    b_so_hdL varchar2(1):='T'; b_tenC nvarchar2(500); b_cmtC varchar2(20); b_mobiC varchar2(20);
    b_emailC varchar2(100); b_dchiC nvarchar2(500); b_ng_huong nvarchar2(500);
    
    b_so_dk varchar2(20); b_ten_tau nvarchar2(500); b_qtich varchar2(10);
    b_pvi nvarchar2(500); 
    b_nhom varchar2(10); b_loai varchar2(10); b_cap varchar2(10); b_vlieu varchar2(10);
    b_csuat number; b_so_cn number; b_ttai number; b_dtich number; b_vtoc number; 
    b_nam_sx number; b_hcai varchar2(1); b_gia number; b_tvo number; b_may number; b_tbi number; b_tuoi number;
    b_ma_sp varchar2(10); b_dkien varchar2(10); b_md_sd varchar2(10); b_nv_bh varchar2(10);
    b_hoi varchar2(20); b_hoi_tien number; b_hoi_tyle number; b_hoi_hh number; b_tl_mgiu number; b_tau_id number;
    b_tb varchar2(200);

    dk_bt pht_type.a_num; dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var;
    dk_ma_ct pht_type.a_var; dk_kieu pht_type.a_var;
    dk_tien pht_type.a_num; dk_pt pht_type.a_num; dk_phi pht_type.a_num;
    dk_thue pht_type.a_num; dk_ttoan pht_type.a_num; dk_cap pht_type.a_num; dk_ma_dk pht_type.a_var;
    dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num; dk_ptB pht_type.a_num;
    dk_ptG pht_type.a_num; dk_phiG pht_type.a_num; dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var; dk_luy pht_type.a_var;
-- Xu ly
    b_ngay_htC number;
begin
-- Dan - Nhap
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_dkbs,dt_lt,dt_kbt,dt_hu,dt_kytt,dt_ttt');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_dkbs,dt_lt,dt_kbt,dt_hu,dt_kytt,dt_ttt using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_dkbs); FKH_JSa_NULL(dt_lt);
FKH_JSa_NULL(dt_kbt); FKH_JSa_NULL(dt_hu); FKH_JSa_NULL(dt_kytt);  FKH_JSa_NULL(dt_ttt); 
if b_so_id<>0 then
    select count(*) into b_i1 from bh_tau where so_id=b_so_id;
    if b_i1<>0 then
        select ngay_ht,kieu_hd,ttrang into b_ngay_htC,b_kieu_hd,b_ttrang from bh_tau
            where so_id=b_so_id for update nowait;
        if sql%rowcount=0 then b_loi:='loi:Va cham NSD:loi'; raise PROGRAM_ERROR; end if;
        if b_ttrang not in('T','D') then b_kieu_hd:='X'; else b_kieu_hd:='N'; end if;
        PBH_TAU_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_kieu_hd,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
else
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_HD_JS_TEST(
    b_ma_dvi,b_nsd,b_so_id,b_ngay_htC,'bh_tau',dt_ct,dt_kytt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_loai_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,
    b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_ngayD,b_phong,b_ma_cb,b_ma_kh,
    tt_ngay,tt_tien,b_loi,'TAU');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAUG_TESTr(
    b_ma_dvi,b_nsd,b_so_idD,dt_ct,dt_dk,dt_dkbs,
    b_so_hd,b_tenC,b_cmtC,b_mobiC,b_emailC,b_dchiC,b_ng_huong,
    b_so_dk,b_ten_tau,b_qtich,b_pvi,
    b_nhom,b_loai,b_cap,b_vlieu,
    b_csuat,b_so_cn,b_ttai,b_dtich,b_vtoc,
    b_nam_sx,b_hcai,b_gia,b_tvo,b_may,b_tbi,b_tuoi,
    b_ma_sp,b_dkien,b_md_sd,b_nv_bh,
    b_hoi,b_hoi_tien,b_hoi_tyle,b_hoi_hh,b_tl_mgiu,b_tau_id,
    b_tb,
    dk_bt,dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,
    dk_cap,dk_ma_dk,dk_lh_nv,dk_t_suat,dk_ptB,dk_ptG,dk_phiG,dk_lkeP,dk_lkeB,dk_luy,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAUG_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,
    dt_ct,dt_dk,dt_dkbs,dt_lt,dt_kbt,dt_hu,dt_kytt,dt_ttt,
-- Chung
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
    b_so_hdL,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,
    b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_ngayD,b_phong,
    tt_ngay,tt_tien,
-- Rieng
    b_tenC,b_cmtC,b_mobiC,b_emailC,b_dchiC,b_ng_huong,
    b_so_dk,b_ten_tau,b_qtich,b_pvi,
    b_nhom,b_loai,b_cap,b_vlieu,
    b_csuat,b_so_cn,b_ttai,b_dtich,b_vtoc,
    b_nam_sx,b_hcai,b_gia,b_tvo,b_may,b_tbi,b_tuoi,
    b_ma_sp,b_dkien,b_md_sd,b_nv_bh,
    b_hoi,b_hoi_tien,b_hoi_tyle,b_hoi_hh,b_tl_mgiu,b_tau_id,
    dk_bt,dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,
    dk_cap,dk_ma_dk,dk_lh_nv,dk_t_suat,dk_ptB,dk_ptG,dk_phiG,dk_lkeP,dk_lkeB,dk_luy,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hd' value b_so_hd, 'ma_kh' value b_ma_kh, 'tb' value b_tb) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAUG_PHIb(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000); b_loi varchar2(1000); b_i1 number; b_i2 number; dt_ct clob;
    b_ma varchar2(20); b_so_hdG varchar2(20); b_ngay_hl number; b_ngay_kt number; b_ngay_cap number;
    b_ngay_hlC number; b_ngay_ktC number; b_so_idG number:=0; b_so_id_dt number;
    b_tienG number; b_ptG number; b_phiG number;
begin
-- Nam - tinh phi prorata
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct');
EXECUTE IMMEDIATE b_lenh into dt_ct using b_oraIn;
FKH_JS_NULL(dt_ct);
b_lenh:=FKH_JS_LENH('so_id_dt,so_hd_g,ngay_hl,ngay_kt,ngay_cap,ma');
EXECUTE IMMEDIATE b_lenh into b_so_id_dt,b_so_hdG,b_ngay_hl,b_ngay_kt,b_ngay_cap,b_ma using dt_ct;
b_so_id_dt:=nvl(b_so_id_dt,0);
if b_ma is null then b_loi:=''; return; end if;
if b_so_hdG<>' ' then
    b_so_idG:=FBH_TAU_SO_ID(b_ma_dvi,b_so_hdG);
    if b_so_idG=0 then b_loi:='loi:GCN goc da xoa:loi'; return; end if;
end if;
if b_so_idG<>0 and b_ngay_hl<b_ngay_cap then
    select ngay_hl,ngay_kt into b_ngay_hlC,b_ngay_ktC from bh_tau_ds where ma_dvi=b_ma_dvi and so_id=b_so_idG and b_so_id_dt in(0,so_id_dt);
    b_i1:=FKH_KHO_NGSO(b_ngay_cap,b_ngay_ktC)/FKH_KHO_NGSO(b_ngay_hlC,b_ngay_ktC);
    b_i2:=FKH_KHO_NGSO(b_ngay_cap,b_ngay_kt)/FKH_KHO_NGSO(b_ngay_hl,b_ngay_kt);
    b_i1:=round(b_i1,2); b_i2:=round(b_i2,2);
    select tien,pt,phi into b_tienG,b_ptG,b_phiG from bh_tau_dk where ma_dvi=b_ma_dvi and so_id=b_so_idG and ma=b_ma and b_so_id_dt in(0,so_id_dt);
end if;
select json_object('hsc' value b_i1,'hsm' value b_i2 ,'tien' value b_tienG,'pt' value b_ptG,'phi' value b_phiG returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAUG_PHIGr(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_i2 number; b_iX number; b_lenh varchar2(1000);
    dt_ct clob; dt_dk clob; dt_dkbs clob;
    b_tp number:=0;
    b_so_hdG varchar2(20); b_ngay_hl number; b_ngay_kt number; b_ngay_cap number;
    b_c_thue varchar2(1);
    b_ngay_hlC number; b_ngay_ktC number;
    b_phi number:=0; b_tien number; b_so_idG number:=0;

    dk_ma pht_type.a_var;dk_ten pht_type.a_nvar;dk_tc pht_type.a_var;
    dk_ma_ct pht_type.a_var;dk_kieu pht_type.a_var;
    dk_lkeM pht_type.a_var;dk_lkeP pht_type.a_var;dk_lkeB pht_type.a_var;
    dk_luy pht_type.a_var;
    dk_ma_dk pht_type.a_var;dk_ma_dkC pht_type.a_var;dk_lh_nv pht_type.a_var;dk_t_suat pht_type.a_num;
    dk_cap pht_type.a_num;
    dk_tien pht_type.a_num;dk_pt pht_type.a_num;dk_phi pht_type.a_num;
    dk_thue pht_type.a_num;dk_ttoan pht_type.a_num;dk_nv pht_type.a_var;
    dk_ptB pht_type.a_num;dk_phiB pht_type.a_num;dk_bt pht_type.a_num;
    dk_pp pht_type.a_var;dk_ptk pht_type.a_var;dk_gvu pht_type.a_var;
    dk_maG pht_type.a_var; dk_tienG pht_type.a_num; dk_ptG pht_type.a_num;
    dk_phiG pht_type.a_num;

    dkbs_ma pht_type.a_var;dkbs_ten pht_type.a_nvar;dkbs_tc pht_type.a_var;
    dkbs_ma_ct pht_type.a_var;dkbs_kieu pht_type.a_var;
    dkbs_lkeM pht_type.a_var;dkbs_lkeP pht_type.a_var;dkbs_lkeB pht_type.a_var;
    dkbs_luy pht_type.a_var;
    dkbs_ma_dk pht_type.a_var;dkbs_ma_dkC pht_type.a_var;dkbs_lh_nv pht_type.a_var;dkbs_t_suat pht_type.a_num;
    dkbs_cap pht_type.a_num;
    dkbs_tien pht_type.a_num;dkbs_pt pht_type.a_num;dkbs_phi pht_type.a_num;
    dkbs_thue pht_type.a_num;dkbs_ttoan pht_type.a_num;dkbs_nv pht_type.a_var;
    dkbs_ptB pht_type.a_num;dkbs_phiB pht_type.a_num;dkbs_bt pht_type.a_num;
    dkbs_pp pht_type.a_var;dkbs_ptk pht_type.a_var;dkbs_gvu pht_type.a_var;
    dkbs_maG pht_type.a_var; dkbs_tienG pht_type.a_num; dkbs_ptG pht_type.a_num;
    dkbs_phiG pht_type.a_num;

    cs_dk clob; cs_dkbs clob; b_dk_txt clob; b_dkbs_txt clob;

begin
-- Nam - tinh phi prorata
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_dkbs');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_dkbs using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_dkbs);
b_lenh:=FKH_JS_LENH('so_hd_g,ngay_hl,ngay_kt,ngay_cap');
EXECUTE IMMEDIATE b_lenh into b_so_hdG,b_ngay_hl,b_ngay_kt,b_ngay_cap using dt_ct;
if b_so_hdG<>' ' then
    b_so_idG:=FBH_TAU_SO_ID(b_ma_dvi,b_so_hdG);
    if b_so_idG=0 then b_loi:='loi:Hop dong goc da xoa:loi'; return; end if;
end if;
FBH_TAU_PHI(dt_ct,dt_dk,dt_dkbs,
  dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_lkeM,dk_lkeP,dk_lkeB ,
  dk_luy,dk_ma_dk ,dk_ma_dkC ,dk_lh_nv ,dk_t_suat,dk_cap,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,
  dk_nv,dk_ptB,dk_phiB,dk_bt,dk_pp,dk_ptk,dk_gvu,
  dkbs_ma,dkbs_ten,dkbs_tc,dkbs_ma_ct,dkbs_kieu,dkbs_lkeM,dkbs_lkeP,dkbs_lkeB ,
  dkbs_luy,dkbs_ma_dk ,dkbs_ma_dkC ,dkbs_lh_nv ,dkbs_t_suat,dkbs_cap,dkbs_tien,dkbs_pt,dkbs_phi,dkbs_thue,dkbs_ttoan,
  dkbs_nv,dkbs_ptB,dkbs_phiB,dkbs_bt,dkbs_pp,dkbs_ptk,dkbs_gvu,b_tp,b_loi);
if b_loi is not null then return; end if;
if b_so_idG<>0 and b_ngay_hl<b_ngay_cap then
    select ngay_hl,ngay_kt into b_ngay_hlC,b_ngay_ktC from bh_tau_ds
        where ma_dvi=b_ma_dvi and so_id=b_so_idG;
    b_i1:=FKH_KHO_NGSO(b_ngay_cap,b_ngay_ktC)/FKH_KHO_NGSO(b_ngay_hlC,b_ngay_ktC);
    b_i2:=FKH_KHO_NGSO(b_ngay_cap,b_ngay_kt)/FKH_KHO_NGSO(b_ngay_hl,b_ngay_kt);
    b_i1:=round(b_i1,2); b_i2:=round(b_i2,2);
    select ma,tien,pt,phi bulk collect into dk_maG,dk_tienG,dk_ptG,dk_phiG from bh_tau_dk
        where ma_dvi=b_ma_dvi and so_id=b_so_idG and bt<10000 order by bt;
    select ma,tien,pt,phi bulk collect into dkbs_maG,dkbs_tienG,dkbs_ptG,dkbs_phiG from bh_tau_dk
        where ma_dvi=b_ma_dvi and so_id=b_so_idG and bt>10000 order by bt;
    for b_lp in 1..dk_maG.count loop
        b_iX:=b_lp; b_tien:=0;
        for b_lp1 in reverse 1..b_iX loop
            if dk_tienG(b_lp1)<>0 then b_tien:=dk_tienG(b_lp1); exit; end if;
        end loop;
        b_iX:=FKH_ARR_VTRI(dk_ma,dk_maG(b_lp));
        if b_iX=0 or b_tien=0 then continue; end if;
        b_phi:=b_tien*dk_ptG(b_lp)/100;
        b_phi:=dk_phiG(b_lp)-round(b_phi*b_i1,b_tp);               -- Phi da dung
        if dk_pp(b_iX)<>'DG' then
           dk_phi(b_iX):=b_phi+round(dk_phi(b_iX)*b_i2,b_tp);      -- Phi con lai: round(dk_phi(b_iX)*b_i2,b_tp);
           dk_phiB(b_iX):=b_phi+round(dk_phiB(b_iX)*b_i2,b_tp);
        end if;
    end loop;
    for b_lp in 1..dkbs_maG.count loop
        b_iX:=b_lp; b_tien:=0;
        for b_lp1 in reverse 1..b_iX loop
            if dkbs_tienG(b_lp1)<>0 then b_tien:=dkbs_tienG(b_lp1); exit; end if;
        end loop;
        b_iX:=FKH_ARR_VTRI(dkbs_ma,dkbs_maG(b_lp));
        if b_iX=0 or b_tien=0 then continue; end if;
        b_phi:=b_tien*dkbs_ptG(b_lp)/100;
        b_phi:=dkbs_phiG(b_lp)-round(b_phi*b_i1,b_tp);                 -- Phi da dung
        if dkbs_pp(b_iX)<>'DG' then
           dkbs_phi(b_iX):=b_phi+round(dkbs_phi(b_iX)*b_i2,b_tp);      -- Phi con lai: round(dk_phi(b_iX)*b_i2,b_tp);
           dkbs_phiB(b_iX):=b_phi+round(dkbs_phiB(b_iX)*b_i2,b_tp);
        end if;
    end loop;
end if;
if b_c_thue<>'C' then
    for b_lp in 1..dk_ma.count loop dk_thue(b_lp):=0; end loop;
    for b_lp in 1..dkbs_ma.count loop dkbs_thue(b_lp):=0; end loop;
else
    for b_lp in 1..dk_ma.count loop dk_thue(b_lp):=round(dk_phi(b_lp)*dk_t_suat(b_lp)/100,b_tp); end loop;
    for b_lp in 1..dkbs_ma.count loop dkbs_thue(b_lp):=round(dkbs_phi(b_lp)*dkbs_t_suat(b_lp)/100,b_tp); end loop;
end if;
FBH_TAUG_PHIt(b_tp,dk_ma,dk_ma_ct,dk_lkeP,dk_cap,dk_phi,dk_thue,dk_ttoan,b_loi);
if b_loi is not null then return; end if;
FBH_TAUG_PHIt(b_tp,dkbs_ma,dkbs_ma_ct,dkbs_lkeP,dkbs_cap,dkbs_phi,dkbs_thue,dkbs_ttoan,b_loi);
if b_loi is not null then return; end if;
b_oraOut:='';
for b_lp in 1..dk_ma.count loop
    select json_object('ma' value dk_ma(b_lp),'ten' value dk_ten(b_lp),'tc' value dk_tc(b_lp),'ma_ct' value dk_ma_ct(b_lp),
    'kieu' value dk_kieu(b_lp),'lkeM' value dk_lkeM(b_lp),'lkeP' value dk_lkeP(b_lp),'lkeB' value dk_lkeB(b_lp),
    'luy' value dk_luy(b_lp),'ma_dk' value dk_ma_dk(b_lp),'ma_dkC' value dk_ma_dkC(b_lp),
    'lh_nv' value dk_lh_nv(b_lp),'t_suat' value dk_t_suat(b_lp),'cap' value dk_cap(b_lp),
    'pp' value dk_pp(b_lp),'ptK' value dk_ptk(b_lp),'bt' value dk_bt(b_lp),
    'tien' value dk_tien(b_lp),'pt' value dk_pt(b_lp),'nv' value dk_nv(b_lp),
    'phi' value dk_phi(b_lp),'thue' value dk_thue(b_lp),'gvu' value dk_gvu(b_lp),'ttoan' value dk_ttoan(b_lp),
    'ptB' value dk_ptB(b_lp),'phiB' value dk_phiB(b_lp) returning clob) into b_dk_txt from dual;
    if b_lp>1 then cs_dk:=cs_dk||','; end if;
    cs_dk:=cs_dk||b_dk_txt;
end loop;
if cs_dk is not null then cs_dk:='['||cs_dk||']'; end if;
for b_lp in 1..dkbs_ma.count loop
    select json_object('ma' value dkbs_ma(b_lp),'ten' value dkbs_ten(b_lp),'tc' value dkbs_tc(b_lp),'ma_ct' value dkbs_ma_ct(b_lp),
    'kieu' value dkbs_kieu(b_lp),'lkeM' value dkbs_lkeM(b_lp),'lkeP' value dkbs_lkeP(b_lp),'lkeB' value dkbs_lkeB(b_lp),
    'luy' value dkbs_luy(b_lp),'ma_dk' value dkbs_ma_dk(b_lp),'ma_dkC' value dkbs_ma_dkC(b_lp),
    'lh_nv' value dkbs_lh_nv(b_lp),'t_suat' value dkbs_t_suat(b_lp),'cap' value dkbs_cap(b_lp),
    'pp' value dkbs_pp(b_lp),'ptK' value dkbs_ptk(b_lp),'bt' value dkbs_bt(b_lp),
    'tien' value dkbs_tien(b_lp),'pt' value dkbs_pt(b_lp),'nv' value dkbs_nv(b_lp),
    'phi' value dkbs_phi(b_lp),'thue' value dkbs_thue(b_lp),'gvu' value dkbs_gvu(b_lp),'ttoan' value dkbs_ttoan(b_lp),
    'ptB' value dkbs_ptB(b_lp),'phiB' value dkbs_phiB(b_lp) returning clob) into b_dkbs_txt from dual;
    if b_lp>1 then cs_dkbs:=cs_dkbs||','; end if;
    cs_dkbs:=cs_dkbs||b_dkbs_txt;
end loop;
if cs_dkbs is not null then cs_dkbs:='['||cs_dkbs||']'; end if;
select json_object('dt_dk' value cs_dk,'dt_dkbs' value cs_dkbs returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAUH_PHI(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_i2 number; b_iX number; b_lenh varchar2(1000);
    dt_ctH clob; dt_ct clob; dt_dk clob; dt_dkbs clob;
    b_tp number:=0;
    b_so_hdG varchar2(20); b_ngay_hl number; b_ngay_kt number; b_ngay_cap number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tygia number; b_c_thue varchar2(1);
    b_ngay_hlC number; b_ngay_ktC number; b_kieu_hd varchar2(20);
    b_phi number:=0; b_tien number; b_so_idG number:=0; b_so_id_dt number;
    b_ngay_hlH number; b_ngay_ktH number; b_gcnG varchar2(20);
    b_gio_hlH varchar2(10); b_gio_ktH varchar2(10); b_gio_hl varchar2(10); b_gio_kt varchar2(10);

    dk_ma pht_type.a_var;dk_ten pht_type.a_nvar;dk_tc pht_type.a_var;
    dk_ma_ct pht_type.a_var;dk_kieu pht_type.a_var;
    dk_lkeM pht_type.a_var;dk_lkeP pht_type.a_var;dk_lkeB pht_type.a_var;
    dk_luy pht_type.a_var;
    dk_ma_dk pht_type.a_var;dk_ma_dkC pht_type.a_var;dk_lh_nv pht_type.a_var;dk_t_suat pht_type.a_num;
    dk_cap pht_type.a_num;
    dk_tien pht_type.a_num;dk_pt pht_type.a_num;dk_phi pht_type.a_num;
    dk_thue pht_type.a_num;dk_ttoan pht_type.a_num;dk_nv pht_type.a_var;
    dk_ptB pht_type.a_num;dk_phiB pht_type.a_num;dk_bt pht_type.a_num;
    dk_pp pht_type.a_var;dk_ptk pht_type.a_var;dk_gvu pht_type.a_var;
    dk_maG pht_type.a_var; dk_tienG pht_type.a_num; dk_ptG pht_type.a_num;
    dk_phiG pht_type.a_num;

    dkbs_ma pht_type.a_var;dkbs_ten pht_type.a_nvar;dkbs_tc pht_type.a_var;
    dkbs_ma_ct pht_type.a_var;dkbs_kieu pht_type.a_var;
    dkbs_lkeM pht_type.a_var;dkbs_lkeP pht_type.a_var;dkbs_lkeB pht_type.a_var;
    dkbs_luy pht_type.a_var;
    dkbs_ma_dk pht_type.a_var;dkbs_ma_dkC pht_type.a_var;dkbs_lh_nv pht_type.a_var;dkbs_t_suat pht_type.a_num;
    dkbs_cap pht_type.a_num;
    dkbs_tien pht_type.a_num;dkbs_pt pht_type.a_num;dkbs_phi pht_type.a_num;
    dkbs_thue pht_type.a_num;dkbs_ttoan pht_type.a_num;dkbs_nv pht_type.a_var;
    dkbs_ptB pht_type.a_num;dkbs_phiB pht_type.a_num;dkbs_bt pht_type.a_num;
    dkbs_pp pht_type.a_var;dkbs_ptk pht_type.a_var;dkbs_gvu pht_type.a_var;
    dkbs_maG pht_type.a_var;dkbs_tienG pht_type.a_num;dkbs_ptG pht_type.a_num;
    dkbs_phiG pht_type.a_num;

    cs_dk clob; cs_dkbs clob; b_dk_txt clob; b_dkbs_txt clob;

begin
-- Nam - tinh phi prorata
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ctH,dt_ct,dt_dk,dt_dkbs');
EXECUTE IMMEDIATE b_lenh into dt_ctH,dt_ct,dt_dk,dt_dkbs using b_oraIn;
FKH_JS_NULL(dt_ctH); FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_dkbs);
b_lenh:=FKH_JS_LENH('kieu_hd,so_hd_g,nt_tien,nt_phi,tygia,c_thue,ngay_hl,ngay_kt,ngay_cap,gio_hl,gio_kt');
EXECUTE IMMEDIATE b_lenh into b_kieu_hd,b_so_hdG,b_nt_tien,b_nt_phi,b_tygia,b_c_thue,b_ngay_hlH,b_ngay_ktH,
        b_ngay_cap,b_gio_hlH,b_gio_ktH using dt_ctH;
b_lenh:=FKH_JS_LENH('so_id_dt,gcn_g,ngay_hl,ngay_kt,gio_hl,gio_kt');
EXECUTE IMMEDIATE b_lenh into b_so_id_dt,b_gcnG,b_ngay_hl,b_ngay_kt,b_gio_hl,b_gio_kt using dt_ct;
--nam: check thoi han hieu luc cua hop dong so voi GCN
b_gio_hl:=to_number(replace(b_gio_hl,'|','')); b_gio_kt:=to_number(replace(b_gio_kt,'|',''));
b_gio_hlH:=to_number(replace(b_gio_hlH,'|','')); b_gio_ktH:=to_number(replace(b_gio_ktH,'|',''));
b_loi:='loi:Sai ngay hieu luc:loi';
if b_ngay_hl in(0,30000101) or b_ngay_kt in(0,30000101) or
    b_ngay_hl<b_ngay_hlH or b_ngay_hl>b_ngay_kt or b_ngay_kt>b_ngay_ktH then raise PROGRAM_ERROR;
elsif b_ngay_hl=b_ngay_hlH and b_ngay_kt=b_ngay_ktH and (b_gio_hl<b_gio_hlH or b_gio_kt>b_gio_ktH) then raise PROGRAM_ERROR;
elsif b_ngay_hl=b_ngay_kt and b_gio_hl>b_gio_kt then raise PROGRAM_ERROR;
end if;
if b_so_id_dt>100000 and b_kieu_hd in('S','B') and b_gcnG<>' ' then
    select count(*) into b_i1 from bh_tau_ds where ma_dvi=b_ma_dvi and so_id_dt=b_so_id_dt and gcn=b_gcnG;
    if b_i1=0 then b_loi:='loi:GCN: '||b_gcnG||' da xoa:loi'; raise PROGRAM_ERROR; end if;
end if;
if b_kieu_hd in('S','B') and b_so_hdG<>' ' and b_ngay_hl<b_ngay_cap then
    b_so_idG:=FBH_TAU_SO_ID(b_ma_dvi,b_so_hdG);
    if b_so_idG=0 then b_loi:='loi:Hop dong goc da xoa:loi'; return; end if;
end if;
FBH_TAU_PHI(dt_ct,dt_dk,dt_dkbs,
  dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_lkeM,dk_lkeP,dk_lkeB ,
  dk_luy,dk_ma_dk ,dk_ma_dkC ,dk_lh_nv ,dk_t_suat,dk_cap,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,
  dk_nv,dk_ptB,dk_phiB,dk_bt,dk_pp,dk_ptk,dk_gvu,
  dkbs_ma,dkbs_ten,dkbs_tc,dkbs_ma_ct,dkbs_kieu,dkbs_lkeM,dkbs_lkeP,dkbs_lkeB ,
  dkbs_luy,dkbs_ma_dk ,dkbs_ma_dkC ,dkbs_lh_nv ,dkbs_t_suat,dkbs_cap,dkbs_tien,dkbs_pt,dkbs_phi,dkbs_thue,dkbs_ttoan,
  dkbs_nv,dkbs_ptB,dkbs_phiB,dkbs_bt,dkbs_pp,dkbs_ptk,dkbs_gvu,b_tp,b_loi);
if b_loi is not null then return; end if;
if b_so_idG<>0 then
    select ngay_hl,ngay_kt into b_ngay_hlC,b_ngay_ktC from bh_tau_ds
        where ma_dvi=b_ma_dvi and so_id=b_so_idG and so_id_dt=b_so_id_dt;
    b_i1:=FKH_KHO_NGSO(b_ngay_cap,b_ngay_ktC)/FKH_KHO_NGSO(b_ngay_hlC,b_ngay_ktC);
    b_i2:=FKH_KHO_NGSO(b_ngay_cap,b_ngay_kt)/FKH_KHO_NGSO(b_ngay_hl,b_ngay_kt);
    b_i1:=round(b_i1,2); b_i2:=round(b_i2,2);
    select ma,tien,pt,phi bulk collect into dk_maG,dk_tienG,dk_ptG,dk_phiG from bh_tau_dk
        where ma_dvi=b_ma_dvi and so_id=b_so_idG and bt<10000 order by bt;
    select ma,tien,pt,phi bulk collect into dkbs_maG,dkbs_tienG,dkbs_ptG,dkbs_phiG from bh_tau_dk
        where ma_dvi=b_ma_dvi and so_id=b_so_idG and bt>10000 order by bt;
    for b_lp in 1..dk_maG.count loop
        b_iX:=b_lp; b_tien:=0;
        for b_lp1 in reverse 1..b_iX loop
            if dk_tienG(b_lp1)<>0 then b_tien:=dk_tienG(b_lp1); exit; end if;
        end loop;
        b_iX:=FKH_ARR_VTRI(dk_ma,dk_maG(b_lp));
        if b_iX=0 or b_tien=0 then continue; end if;
        b_phi:=b_tien*dk_ptG(b_lp)/100;
        b_phi:=dk_phiG(b_lp)-round(b_phi*b_i1,b_tp);               -- Phi da dung
        if dk_pp(b_iX)<>'DG' then
           dk_phi(b_iX):=b_phi+round(dk_phi(b_iX)*b_i2,b_tp);      -- Phi con lai: round(dk_phi(b_iX)*b_i2,b_tp);
           dk_phiB(b_iX):=b_phi+round(dk_phiB(b_iX)*b_i2,b_tp);
        end if;
    end loop;
    for b_lp in 1..dkbs_maG.count loop
        b_iX:=b_lp; b_tien:=0;
        for b_lp1 in reverse 1..b_iX loop
            if dkbs_tienG(b_lp1)<>0 then b_tien:=dkbs_tienG(b_lp1); exit; end if;
        end loop;
        b_iX:=FKH_ARR_VTRI(dkbs_ma,dkbs_maG(b_lp));
        if b_iX=0 or b_tien=0 then continue; end if;
        b_phi:=b_tien*dkbs_ptG(b_lp)/100;
        b_phi:=dkbs_phiG(b_lp)-round(b_phi*b_i1,b_tp);                 -- Phi da dung
        if dkbs_pp(b_iX)<>'DG' then
           dkbs_phi(b_iX):=b_phi+round(dkbs_phi(b_iX)*b_i2,b_tp);      -- Phi con lai: round(dk_phi(b_iX)*b_i2,b_tp);
           dkbs_phiB(b_iX):=b_phi+round(dkbs_phiB(b_iX)*b_i2,b_tp);
        end if;
    end loop;
end if;
if b_c_thue<>'C' then
    for b_lp in 1..dk_ma.count loop dk_thue(b_lp):=0; end loop;
    for b_lp in 1..dkbs_ma.count loop dkbs_thue(b_lp):=0; end loop;
else
    for b_lp in 1..dk_ma.count loop dk_thue(b_lp):=round(dk_phi(b_lp)*dk_t_suat(b_lp)/100,b_tp); end loop;
    for b_lp in 1..dkbs_ma.count loop dkbs_thue(b_lp):=round(dkbs_phi(b_lp)*dkbs_t_suat(b_lp)/100,b_tp); end loop;
end if;
FBH_TAUG_PHIt(b_tp,dk_ma,dk_ma_ct,dk_lkeP,dk_cap,dk_phi,dk_thue,dk_ttoan,b_loi);
if b_loi is not null then return; end if;
FBH_TAUG_PHIt(b_tp,dkbs_ma,dkbs_ma_ct,dkbs_lkeP,dkbs_cap,dkbs_phi,dkbs_thue,dkbs_ttoan,b_loi);
if b_loi is not null then return; end if;
b_oraOut:='';
for b_lp in 1..dk_ma.count loop
    select json_object('ma' value dk_ma(b_lp),'ten' value dk_ten(b_lp),'tc' value dk_tc(b_lp),'ma_ct' value dk_ma_ct(b_lp),
    'kieu' value dk_kieu(b_lp),'lkeM' value dk_lkeM(b_lp),'lkeP' value dk_lkeP(b_lp),'lkeB' value dk_lkeB(b_lp),
    'luy' value dk_luy(b_lp),'ma_dk' value dk_ma_dk(b_lp),'ma_dkC' value dk_ma_dkC(b_lp),
    'lh_nv' value dk_lh_nv(b_lp),'t_suat' value dk_t_suat(b_lp),'cap' value dk_cap(b_lp),
    'pp' value dk_pp(b_lp),'ptK' value dk_ptk(b_lp),'bt' value dk_bt(b_lp),
    'tien' value dk_tien(b_lp),'pt' value dk_pt(b_lp),'nv' value dk_nv(b_lp),
    'phi' value dk_phi(b_lp),'thue' value dk_thue(b_lp),'gvu' value dk_gvu(b_lp),'ttoan' value dk_ttoan(b_lp),
    'ptB' value dk_ptB(b_lp),'phiB' value dk_phiB(b_lp) returning clob) into b_dk_txt from dual;
    if b_lp>1 then cs_dk:=cs_dk||','; end if;
    cs_dk:=cs_dk||b_dk_txt;
end loop;
if cs_dk is not null then cs_dk:='['||cs_dk||']'; end if;
for b_lp in 1..dkbs_ma.count loop
    select json_object('ma' value dkbs_ma(b_lp),'ten' value dkbs_ten(b_lp),'tc' value dkbs_tc(b_lp),'ma_ct' value dkbs_ma_ct(b_lp),
    'kieu' value dkbs_kieu(b_lp),'lkeM' value dkbs_lkeM(b_lp),'lkeP' value dkbs_lkeP(b_lp),'lkeB' value dkbs_lkeB(b_lp),
    'luy' value dkbs_luy(b_lp),'ma_dk' value dkbs_ma_dk(b_lp),'ma_dkC' value dkbs_ma_dkC(b_lp),
    'lh_nv' value dkbs_lh_nv(b_lp),'t_suat' value dkbs_t_suat(b_lp),'cap' value dkbs_cap(b_lp),
    'pp' value dkbs_pp(b_lp),'ptK' value dkbs_ptk(b_lp),'bt' value dkbs_bt(b_lp),
    'tien' value dkbs_tien(b_lp),'pt' value dkbs_pt(b_lp),'nv' value dkbs_nv(b_lp),
    'phi' value dkbs_phi(b_lp),'thue' value dkbs_thue(b_lp),'gvu' value dkbs_gvu(b_lp),'ttoan' value dkbs_ttoan(b_lp),
    'ptB' value dkbs_ptB(b_lp),'phiB' value dkbs_phiB(b_lp) returning clob) into b_dkbs_txt from dual;
    if b_lp>1 then cs_dkbs:=cs_dkbs||','; end if;
    cs_dkbs:=cs_dkbs||b_dkbs_txt;
end loop;
if cs_dkbs is not null then cs_dkbs:='['||cs_dkbs||']'; end if;
select json_object('dt_dk' value cs_dk,'dt_dkbs' value cs_dkbs returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_TAU_PHI(
    dt_ct clob,dt_dk clob,dt_dkbs clob,
    dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,dk_tc out pht_type.a_var,
    dk_ma_ct out pht_type.a_var,dk_kieu out pht_type.a_var,
    dk_lkeM out pht_type.a_var,dk_lkeP out pht_type.a_var,dk_lkeB out pht_type.a_var,
    dk_luy out pht_type.a_var,dk_ma_dk out pht_type.a_var,dk_ma_dkC out pht_type.a_var,
    dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,dk_cap out pht_type.a_num,
    dk_tien out pht_type.a_num,dk_pt out pht_type.a_num,dk_phi out pht_type.a_num,
    dk_thue out pht_type.a_num,dk_ttoan out pht_type.a_num,dk_nv out pht_type.a_var,
    dk_ptB out pht_type.a_num,dk_phiB out pht_type.a_num,dk_bt out pht_type.a_num,
    dk_pp out pht_type.a_var,dk_ptk out pht_type.a_var,dk_gvu out pht_type.a_var,
    
    dkbs_ma out pht_type.a_var,dkbs_ten out pht_type.a_nvar,dkbs_tc out pht_type.a_var,
    dkbs_ma_ct out pht_type.a_var,dkbs_kieu out pht_type.a_var,
    dkbs_lkeM out pht_type.a_var,dkbs_lkeP out pht_type.a_var,dkbs_lkeB out pht_type.a_var,
    dkbs_luy out pht_type.a_var,dkbs_ma_dk out pht_type.a_var,dkbs_ma_dkC out pht_type.a_var,
    dkbs_lh_nv out pht_type.a_var,dkbs_t_suat out pht_type.a_num,dkbs_cap out pht_type.a_num,
    dkbs_tien out pht_type.a_num,dkbs_pt out pht_type.a_num,dkbs_phi out pht_type.a_num,
    dkbs_thue out pht_type.a_num,dkbs_ttoan out pht_type.a_num,dkbs_nv out pht_type.a_var,
    dkbs_ptB out pht_type.a_num,dkbs_phiB out pht_type.a_num,dkbs_bt out pht_type.a_num,
    dkbs_pp out pht_type.a_var,dkbs_ptk out pht_type.a_var,dkbs_gvu out pht_type.a_var,
    b_tp out number,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_nt_phi varchar2(5); b_nt_tien varchar2(5);
    b_tygia number:=1; b_kho number:=1;
    b_ttai number; b_dtich number; b_so_cn number; b_csuat number; b_so_ch_bh number:=1; b_ngay_hl number; b_ngay_kt number;
begin
-- Nam - Tinh phi
b_loi:='loi:Loi xu ly FBH_TAU_PHI:loi';
b_lenh:=FKH_JS_LENH('nt_phi,nt_tien,tygia,ttai,dtich,so_cn,csuat,ngay_hl,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_nt_phi,b_nt_tien,b_tygia,b_ttai,b_dtich,b_so_cn,b_csuat,b_ngay_hl,b_ngay_kt using dt_ct;
if b_tygia is null or b_tygia=0 then b_tygia:=1; end if;
if b_nt_phi<>'VND' then b_tp:=2; end if;
if b_tp is null then b_tp:=0; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tien,ptb,pp,pt,phi,thue,gvu,cap,tc,ma_ct,ma_dk,ma_dkc,kieu,lh_nv,t_suat,phib,lkem,lkep,lkeb,ptk,luy,nv,bt');
EXECUTE IMMEDIATE b_lenh bulk collect into dk_ma,dk_ten,dk_tien,dk_ptB,dk_pp,dk_pt,dk_phi,dk_thue,dk_gvu,dk_cap,dk_tc,dk_ma_ct,
        dk_ma_dk,dk_ma_dkC,dk_kieu,dk_lh_nv,dk_t_suat,dk_phiB,dk_lkeM,dk_lkeP,dk_lkeB,dk_ptk,dk_luy,dk_nv,dk_bt using dt_dk;
if trim(dt_dkbs) is not null then
   EXECUTE IMMEDIATE b_lenh bulk collect into dkbs_ma,dkbs_ten,dkbs_tien,dkbs_ptB,dkbs_pp,dkbs_pt,dkbs_phi,dkbs_thue,dkbs_gvu,dkbs_cap,dkbs_tc,dkbs_ma_ct,
        dkbs_ma_dk,dkbs_ma_dkC,dkbs_kieu,dkbs_lh_nv,dkbs_t_suat,dkbs_phiB,dkbs_lkeM,dkbs_lkeP,dkbs_lkeB,dkbs_ptk,dkbs_luy,dkbs_nv,dkbs_bt using dt_dkbs;
end if;
FBH_HD_KHO(b_ngay_hl,b_ngay_kt,b_kho,b_loi);
if b_loi is not null then return; end if;
for b_lp_dk in 1..dk_ma.count loop
   dk_pp(b_lp_dk):=nvl(dk_pp(b_lp_dk),' ');
    if dk_lkeP(b_lp_dk) not in ('T','N','K') then
      if dk_lkeP(b_lp_dk) in ('D','W','C','S') then
         b_so_ch_bh:=case 
             when dk_lkeP(b_lp_dk)='D' then b_dtich
             when dk_lkeP(b_lp_dk)='S' then b_so_cn
             when dk_lkeP(b_lp_dk)='C' then b_csuat
             else b_ttai
         end;
         if dk_ptk(b_lp_dk)<>'P' then
            if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
               dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) / b_tygia * b_so_ch_bh *b_kho,b_tp);
            elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
               dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) * b_tygia * b_so_ch_bh *b_kho,b_tp);
            else
               dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) * b_so_ch_bh *b_kho,b_tp);
            end if;
         else dk_phiB(b_lp_dk):=0;
         end if;
         if dk_pp(b_lp_dk) = 'DG' then dk_phi(b_lp_dk):=ROUND(dk_pt(b_lp_dk),b_tp);
        elsif dk_pp(b_lp_dk) = 'DP' then
             dk_phi(b_lp_dk):=ROUND(dk_pt(b_lp_dk) * b_so_ch_bh *b_kho/ 100,b_tp);
        elsif dk_phiB(b_lp_dk)<>0 then
             dk_phi(b_lp_dk):=dk_phiB(b_lp_dk);
          if dk_pp(b_lp_dk) = 'GG' then
               dk_phi(b_lp_dk):=ROUND((dk_phi(b_lp_dk)-dk_pt(b_lp_dk)),b_tp);
          elsif dk_pp(b_lp_dk) = 'GT' then
               dk_phi(b_lp_dk):= dk_phi(b_lp_dk) - ROUND(dk_pt(b_lp_dk) * b_so_ch_bh *b_kho/ 100,b_tp);
          elsif dk_pp(b_lp_dk) = 'GP' then
               dk_phi(b_lp_dk):= dk_phi(b_lp_dk) - ROUND(dk_pt(b_lp_dk)*dk_phiB(b_lp_dk)/ 100,b_tp);
          if dk_phi(b_lp_dk)<0 then dk_phi(b_lp_dk):=0; end if;
          end if;
        elsif dk_phiB(b_lp_dk)=0 then dk_phi(b_lp_dk):=0;
        end if;
        if dk_phiB(b_lp_dk)=0 then dk_phiB(b_lp_dk):=dk_phi(b_lp_dk); end if;
      else 
        if dk_ptk(b_lp_dk)<>'P' then
            if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
               dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) / b_tygia *b_kho,b_tp);
            elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
               dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) * b_tygia *b_kho,b_tp);
            else
               dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) *b_kho,b_tp);
            end if;
         elsif dk_ptk(b_lp_dk)<>'T' then
            if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
               dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk)* dk_tien(b_lp_dk) / b_tygia *b_kho/ 100,b_tp);
            elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
               dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk)* dk_tien(b_lp_dk) * b_tygia *b_kho/ 100,b_tp);
            else
               dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk)* dk_tien(b_lp_dk) *b_kho/ 100,b_tp);
            end if;
         else dk_phiB(b_lp_dk):=0;
         end if;
        if dk_pp(b_lp_dk) = 'DG' then dk_phi(b_lp_dk):=ROUND(dk_pt(b_lp_dk),b_tp);
        elsif dk_pp(b_lp_dk) = 'DP' then
             dk_phi(b_lp_dk):=ROUND(dk_pt(b_lp_dk) * dk_tien(b_lp_dk) *b_kho/ 100,b_tp);
        elsif dk_phiB(b_lp_dk)<>0 then
             dk_phi(b_lp_dk):=dk_phiB(b_lp_dk);
          if dk_pp(b_lp_dk) = 'GG' then
               dk_phi(b_lp_dk):=ROUND((dk_phi(b_lp_dk)-dk_pt(b_lp_dk)),b_tp);
          elsif dk_pp(b_lp_dk) = 'GT' then
               dk_phi(b_lp_dk):= dk_phi(b_lp_dk) - ROUND(dk_pt(b_lp_dk) * dk_tien(b_lp_dk) *b_kho/ 100,b_tp);
          elsif dk_pp(b_lp_dk) = 'GP' then
               dk_phi(b_lp_dk):= dk_phi(b_lp_dk) - ROUND(dk_pt(b_lp_dk)*dk_phiB(b_lp_dk)/ 100,b_tp);
          if dk_phi(b_lp_dk)<0 then dk_phi(b_lp_dk):=0; end if;
          end if;
        elsif dk_phiB(b_lp_dk)=0 then dk_phi(b_lp_dk):=0;
        end if;
        if dk_phiB(b_lp_dk)=0 then dk_phiB(b_lp_dk):=dk_phi(b_lp_dk); end if;
      end if;
    end if;   
end loop;
for b_lp_dkbs in 1..dkbs_ma.count loop
  dkbs_pp(b_lp_dkbs):=nvl(dkbs_pp(b_lp_dkbs),' ');
  if dkbs_lkeP(b_lp_dkbs) not in ('T','N','K') then
    if dkbs_tien(b_lp_dkbs)<>0 then
      if dkbs_ptk(b_lp_dkbs)<>'P' then
        if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
           dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs) / b_tygia *b_kho,b_tp);
        elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
           dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs) * b_tygia *b_kho,b_tp);
        else
           dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs) *b_kho,b_tp);
        end if;
     elsif dkbs_ptk(b_lp_dkbs)<>'T' then
        if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
           dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs)* dkbs_tien(b_lp_dkbs) / b_tygia *b_kho/ 100,b_tp);
        elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
           dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs)* dkbs_tien(b_lp_dkbs) * b_tygia *b_kho/ 100,b_tp);
        else
           dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs)* dkbs_tien(b_lp_dkbs) *b_kho/ 100,b_tp);
        end if;
     else dkbs_phiB(b_lp_dkbs):=0;
     end if;
    if dkbs_pp(b_lp_dkbs) = 'DG' then
        dkbs_phi(b_lp_dkbs):=ROUND(dkbs_pt(b_lp_dkbs),b_tp);
    elsif dkbs_pp(b_lp_dkbs) = 'DP' then
        dkbs_phi(b_lp_dkbs):=ROUND(dkbs_pt(b_lp_dkbs)*dkbs_tien(b_lp_dkbs) *b_kho/ 100,b_tp);
    elsif dkbs_phiB(b_lp_dkbs)<>0 then
        dkbs_phi(b_lp_dkbs):=dkbs_phiB(b_lp_dkbs);
      if dkbs_pp(b_lp_dkbs) = 'GG' then
        dkbs_phi(b_lp_dkbs):=ROUND((dkbs_phi(b_lp_dkbs)-dkbs_pt(b_lp_dkbs)),b_tp);
      elsif dkbs_pp(b_lp_dkbs) = 'GT' then
        dkbs_phi(b_lp_dkbs):= dkbs_phi(b_lp_dkbs) - ROUND(dkbs_pt(b_lp_dkbs)*dkbs_tien(b_lp_dkbs) *b_kho/ 100,b_tp);
      elsif dkbs_pp(b_lp_dkbs) = 'GP' then
        dkbs_phi(b_lp_dkbs):= dkbs_phi(b_lp_dkbs) - ROUND(dkbs_pt(b_lp_dkbs)*dkbs_phiB(b_lp_dkbs)/ 100,b_tp);
      if dkbs_phi(b_lp_dkbs)<0 then dkbs_phi(b_lp_dkbs):=0; end if;
      end if;
    elsif dkbs_phiB(b_lp_dkbs)=0 then dkbs_phi(b_lp_dkbs):=0;
    end if;
    if dkbs_phiB(b_lp_dkbs)=0 then dkbs_phiB(b_lp_dkbs):=dkbs_phi(b_lp_dkbs); end if;
    else dkbs_phiB(b_lp_dkbs):=0; dkbs_phi(b_lp_dkbs):=0;
    end if;
  end if;
end loop;
FBH_TAUG_PHIb(b_tp,dk_ma,dk_ma_ct,dk_lkeP,dk_cap,dk_kieu,dk_tien,dk_phi,b_loi);
if b_loi is not null then return; end if;
FBH_TAUG_PHIb(b_tp,dkbs_ma,dkbs_ma_ct,dkbs_lkeP,dkbs_cap,dkbs_kieu,dkbs_tien,dkbs_phi,b_loi);
if b_loi is not null then return; end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_TAUG_PHIb(b_tp number,
    dk_ma pht_type.a_var,dk_ma_ct pht_type.a_var,dk_lkeP pht_type.a_var,dk_cap pht_type.a_num,dk_kieu pht_type.a_var,
    dk_tien in out pht_type.a_num,dk_phi in out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_cap number:=1; b_phi number;
begin
-- Nam - Tinh bac cao
b_loi:='loi:Loi xu ly FBH_TAUG_PHIb:loi';
for b_lp in 1..dk_ma.count loop
    if dk_cap(b_lp)>b_cap then b_cap:=dk_cap(b_lp); end if;
    if dk_lkeP(b_lp) in('T','N') then dk_phi(b_lp):=0; end if;
end loop;
b_cap:=b_cap-1;
while b_cap>0 loop
    for b_lp in 1..dk_ma.count loop
        if dk_cap(b_lp)<>b_cap then continue; end if;
        if dk_lkeP(b_lp)='T' then
            b_phi:=0;
            for b_lp1 in 1..dk_ma.count loop
                if dk_ma_ct(b_lp1)=dk_ma(b_lp) then
                    b_phi:=b_phi+dk_phi(b_lp1);
                end if;
            end loop;
            dk_phi(b_lp):=b_phi;
        elsif dk_lkeP(b_lp)='N' then
            b_i1:=0; b_phi:=0;
            for b_lp1 in 1..dk_ma.count loop
                if dk_ma_ct(b_lp1)=dk_ma(b_lp) and (dk_kieu(b_lp1)='T' or dk_phi(b_lp1)<>0) then
                    if b_i1=0 then
                        b_phi:=dk_phi(b_lp1);
                    else
                        b_phi:=ROUND(b_phi* dk_phi(b_lp1),b_tp);
                    end if;
                    b_i1:=1;
                end if;
            end loop;
            if b_i1<>0 then
               for b_lp1 in 1..dk_ma.count loop
                  if dk_ma_ct(b_lp1)=dk_ma(b_lp) and dk_kieu(b_lp1)<>' ' and dk_kieu(b_lp1)<>'T' and dk_tien(b_lp1)<>0 and dk_phi(b_lp1)=0 then
                        b_phi:=ROUND(b_phi* dk_tien(b_lp1),b_tp);
                  end if;
                end loop;
            end if;
            dk_phi(b_lp):=b_phi;
        end if;
    end loop;
    b_cap:=b_cap-1;
end loop;
b_loi:='';
end;
/
create or replace procedure FBH_TAUG_PHIt(b_tp number,
    dk_ma pht_type.a_var,dk_ma_ct pht_type.a_var,dk_lkeP pht_type.a_var,dk_cap pht_type.a_num,
    dk_phi pht_type.a_num,dk_thue in out pht_type.a_num,dk_ttoan out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_cap number:=1; b_phi number; b_thue number;
begin
-- Nam - Tinh bac cao
b_loi:='loi:Loi xu ly FBH_TAUG_PHIt:loi';
b_cap:=b_cap-1;
while b_cap>0 loop
    for b_lp in 1..dk_ma.count loop
        if dk_cap(b_lp)<>b_cap then continue; end if;
        if dk_lkeP(b_lp)='T' then
            b_phi:=0; b_thue:=0;
            for b_lp1 in 1..dk_ma.count loop
                if dk_ma_ct(b_lp1)=dk_ma(b_lp) then
                    b_phi:=b_phi+dk_phi(b_lp1); b_thue:=b_thue+dk_thue(b_lp1);
                end if;
            end loop;
            dk_thue(b_lp):=b_thue; dk_ttoan(b_lp):=b_phi+b_thue;
        elsif dk_lkeP(b_lp)='N' then
            b_i1:=0;
            for b_lp1 in 1..dk_ma.count loop
                if dk_ma_ct(b_lp1)=dk_ma(b_lp) then
                    if b_i1=0 then
                        b_i1:=1; b_phi:=dk_phi(b_lp1); b_thue:=dk_thue(b_lp1);
                    else
                        b_phi:=ROUND(b_phi*dk_phi(b_lp1),b_tp); b_thue:=ROUND(b_thue*dk_thue(b_lp1),b_tp);
                    end if;
                end if;
            end loop;
            dk_thue(b_lp):=b_thue;
        end if;
    end loop;
    b_cap:=b_cap-1;
end loop;
for b_lp in 1..dk_ma.count loop
    dk_ttoan(b_lp):=dk_phi(b_lp)+dk_thue(b_lp);
end loop;
b_loi:='';
end;

