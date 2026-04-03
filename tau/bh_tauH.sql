create or replace procedure PBH_TAUH_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number;
    dt_ct clob; dt_hu clob; ds_ct clob; ds_dk clob; ds_dkbs clob:=''; ds_lt clob:='';
    ds_kbt clob:=''; ds_ttt clob:=''; dt_kytt clob; dt_txt clob;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','TAU','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
select json_object(so_hd,ma_kh,so_dt) into dt_ct from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ngay,tien) order by ngay) into dt_kytt from bh_tau_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
select txt into ds_ct from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ct';
select txt into ds_dk from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_dk';
select count(*) into b_i1 from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hu';
if b_i1=1 then
    select txt into dt_hu from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hu';
end if;
select count(*) into b_i1 from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_dkbs';
if b_i1=1 then
    select txt into ds_dkbs from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_dkbs';
end if;
select count(*) into b_i1 from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_lt';
if b_i1=1 then
    select txt into ds_lt from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_lt';
end if;
select count(*) into b_i1 from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_kbt';
if b_i1=1 then
    select txt into ds_kbt from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_kbt';
end if;
select count(*) into b_i1 from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ttt';
if b_i1=1 then
    select txt into ds_ttt from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ttt';
end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'ds_ct' value ds_ct,
    'ds_dk' value ds_dk,'ds_dkbs' value ds_dkbs,'ds_lt' value ds_lt,
    'ds_kbt' value ds_kbt,'ds_ttt' value ds_ttt,'dt_kytt' value dt_kytt,
    'dt_ct' value dt_ct,'dt_hu' value dt_hu,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAUH_TESTd(
    dt_ctH clob,dt_ct in out clob,dt_dk clob,dt_dkbs clob,
    b_ma_dvi varchar2,b_nsd varchar2,b_ttrang varchar2,b_kieu_hd varchar2,
    b_nt_tien varchar2,b_nt_phi varchar2,b_tygia number,b_c_thue varchar2,
    b_ngay_hlH number,b_ngay_ktH number,b_ngay_capH number,

    b_so_id_dt out number,b_kieu_gcn out varchar2,b_gcn out varchar2,b_gcnG out varchar2,
    b_tenC out nvarchar2,b_cmtC out varchar2,b_mobiC out varchar2,
    b_emailC out varchar2,b_dchiC out nvarchar2,b_ng_huong out nvarchar2,
    b_qtich out varchar2,b_pvi out nvarchar2,b_vtoc out number,b_hcai out varchar2,
    b_tvo out number,b_may out number,b_tbi out number,
    b_nhom out varchar2,b_loai out varchar2,b_cap out varchar2,b_vlieu out varchar2,
    b_ttai out number,b_so_cn out number,b_dtich out number,b_csuat out number,b_gia out number,b_tuoi out number,
    b_ma_sp out varchar2,b_dkien out varchar2,b_md_sd out varchar2,b_nv_bh out varchar2,
    b_so_dk out varchar2,b_ten_tau out nvarchar2,b_nam_sx out number,
    b_hoi out varchar2,b_hoi_tien out number,b_hoi_tyle out number,b_hoi_hh out number,b_tl_mgiu out number,
    b_ngay_hl out number,b_ngay_kt out number,b_ngay_cap out number,b_so_idP out number, b_tau_id out number,

    dk_bt out pht_type.a_num,dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,
    dk_tc out pht_type.a_var,dk_ma_ct out pht_type.a_var,dk_kieu out pht_type.a_var,
    dk_tien out pht_type.a_num,dk_pt out pht_type.a_num,dk_phi out pht_type.a_num,
    dk_thue out pht_type.a_num,dk_ttoan out pht_type.a_num,
    dk_cap out pht_type.a_num,dk_ma_dk out pht_type.a_var,
    dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,
    dk_ptB out pht_type.a_num,dk_phiB out pht_type.a_num,
    dk_lkeP out pht_type.a_var,dk_lkeB out pht_type.a_var,dk_luy out pht_type.a_var,b_loi out varchar2)
AS
    b_i1 number; b_kt number; b_ktG number;
    b_lenh varchar2(2000); b_txt clob;
    b_tp number:=0;
    b_tgT number:=1;
    b_ps varchar2(1); b_qdoi number; b_ma_dk varchar2(10); b_loai_khC varchar2(1);
    b_cdtC varchar2(1); b_cdtF varchar2(1); b_cdtX varchar2(1); b_cdt varchar2(10);
    dk_nv pht_type.a_var; a_nv pht_type.a_var; dk_gvu pht_type.a_var;

    dk_nvX pht_type.a_var; dk_maX pht_type.a_var; dk_tenX pht_type.a_nvar; dk_tcX pht_type.a_var;
    dk_ma_ctX pht_type.a_var; dk_kieuX pht_type.a_var;
    dk_ma_dkX pht_type.a_var; dk_tienX pht_type.a_num; dk_ptX pht_type.a_num;
    dk_phiX pht_type.a_num; dk_thueX pht_type.a_num; dk_lkePX pht_type.a_var; dk_lkeBX pht_type.a_var; dk_luyX pht_type.a_var;
    dk_lh_nvX pht_type.a_var; dk_t_suatX pht_type.a_num; dk_capX pht_type.a_num;
    dk_ptGX pht_type.a_num; dk_phiGX pht_type.a_num; dk_ptBX pht_type.a_num; dk_phiBX pht_type.a_num; a_thay pht_type.a_num;

    dk_lkeM pht_type.a_var; dk_lkeMX pht_type.a_var;
begin
-- Dan - Nhap
b_loi:='loi:Loi xu ly PBH_TAUH_TESTd:loi';
b_lenh:=FKH_JS_LENH('so_id_dt,gcn,gcn_g,loai_khc,tenc,cmtc,mobic,emailc,dchic,nvv,nvt,nvd,nvn,cdtc,cdtf,cdtx');
EXECUTE IMMEDIATE b_lenh into b_so_id_dt,b_gcn,b_gcnG,b_loai_khC,b_tenC,b_cmtC,b_mobiC,b_emailC,b_dchiC,
a_nv(1),a_nv(2),a_nv(3),a_nv(4),b_cdtC,b_cdtF,b_cdtX using dt_ct;
PBH_TAU_TSO(dt_ct,
    b_qtich,b_pvi,b_vtoc,b_hcai,b_tvo,b_may,b_tbi,
    b_nhom,b_loai,b_cap,b_vlieu,b_ttai,b_so_cn,b_dtich,b_csuat,b_gia,b_tuoi,
    b_ma_sp,b_dkien,b_md_sd,b_nv_bh,b_ngay_hl,b_ngay_kt,
    b_so_dk,b_ten_tau,b_nam_sx,b_hoi,b_hoi_tien,b_hoi_tyle,b_hoi_hh,b_tl_mgiu,b_loi);
if b_loi is not null then return; end if;
if trim(b_tenC) is null then
    b_lenh:=FKH_JS_LENH('ten,cmt,mobi,email,dchi');
    EXECUTE IMMEDIATE b_lenh into b_tenC,b_cmtC,b_mobiC,b_emailC,b_dchiC using dt_ctH;
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
b_tau_id:=nvl(b_tau_id,0);
if b_ngay_kt<b_ngay_hl or b_ngay_kt>b_ngay_ktH then b_ngay_kt:=b_ngay_ktH; end if;
if b_ngay_hl<b_ngay_hlH or b_ngay_hl>b_ngay_kt then b_ngay_hl:=b_ngay_hlH; end if;
b_kieu_gcn:='G'; b_ngay_cap:=b_ngay_capH;
b_gcn:=nvl(trim(b_gcn),' '); b_gcnG:=nvl(trim(b_gcnG),' ');

if b_so_id_dt<100000 then
    PHT_ID_MOI(b_so_id_dt,b_loi);
    if b_loi is not null then return; end if;
    b_gcn:=substr(to_char(b_so_id_dt),3); b_gcnG:=' ';
elsif b_kieu_hd in('S','B') and b_gcnG<>' ' then
    select count(*) into b_i1 from bh_tau_ds where ma_dvi=b_ma_dvi and so_id_dt=b_so_id_dt and gcn=b_gcnG;
    if b_i1=0 then b_loi:='loi:GCN '||b_gcnG||' da xoa:loi'; return; end if;
    b_kieu_gcn:=b_kieu_hd;
    if b_gcn=b_gcnG then b_gcn:=' '; end if;
end if;
if b_gcn=' ' or instr(b_gcn,'.')=2 then
    b_gcn:=substr(to_char(b_so_id_dt),3);
    if b_kieu_gcn<>'G' then
        select count(*) into b_i1 from bh_tau_ds where ma_dvi=b_ma_dvi and so_id_dt=b_so_id_dt and kieu_gcn=b_kieu_hd;
        if(b_i1>0) then
           select max(REGEXP_SUBSTR(gcn, 'B([0-9]+)', 1, 1, NULL, 1)) into b_i1 from bh_tau_ds where ma_dvi=b_ma_dvi and so_id_dt=b_so_id_dt and kieu_gcn=b_kieu_hd;
        end if;
        b_gcn:=b_gcn||'/'||b_kieu_hd||to_char(b_i1+1);
    end if;
else
    select nvl(max(ngay_cap),b_ngay_capH) into b_ngay_cap from bh_tau_ds where ma_dvi=b_ma_dvi and so_id_dt=b_so_id_dt and gcn=b_gcn;
end if;
if trim(b_cdtC) is null then
    b_cdt:=' ';
else
    if b_cdtC='K' then PKH_GHEP(b_cdt,'C',''); end if;
    if b_cdtF='K' then PKH_GHEP(b_cdt,'F',''); end if;
    if b_cdtX='K' then PKH_GHEP(b_cdt,'X',''); end if;
    b_cdt:=nvl(trim(b_cdt),'K');
end if;
PKH_JS_THAYa(dt_ct,'gcn,gcn_g,cdt',b_gcn||'|'||b_gcnG||'|'||b_cdt,'|');
a_thay(1):=b_so_id_dt; a_thay(2):=b_ngay_hl; a_thay(3):=b_ngay_kt; a_thay(4):=b_ngay_cap;
PKH_JS_THAYan(dt_ct,'so_id_dt,ngay_hl,ngay_kt,ngay_cap',a_thay);
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
    dk_tc(b_kt):=dk_tcX(b_lp); dk_ma_ct(b_kt):=dk_ma_ctX(b_lp);
    dk_kieu(b_kt):=dk_kieuX(b_lp); dk_tien(b_kt):=dk_tienX(b_lp);
    dk_pt(b_kt):=dk_ptX(b_lp); dk_phi(b_kt):=dk_phiX(b_lp);
    dk_ptB(b_kt):=dk_ptBX(b_lp); dk_phiB(b_kt):=dk_phiBX(b_lp);
    dk_thue(b_kt):=dk_thueX(b_lp); dk_cap(b_kt):=dk_capX(b_lp);
    dk_ma_dk(b_kt):=dk_ma_dkX(b_lp); dk_lh_nv(b_kt):=dk_lh_nvX(b_lp);
    dk_t_suat(b_kt):=dk_t_suatX(b_lp); dk_lkeM(b_kt):=dk_lkeMX(b_lp); dk_lkeP(b_kt):=dk_lkePX(b_lp); 
    dk_lkeB(b_kt):=dk_lkeB(b_lp); dk_luy(b_kt):=dk_luyX(b_lp);
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
for b_lp in 1..4 loop
    a_nv(b_lp):=nvl(trim(a_nv(b_lp)),' ');
    if a_nv(b_lp)='C' then
        a_nv(b_lp):=substr('VTDN',b_lp,1);
        PKH_GHEP(b_nv_bh,a_nv(b_lp),'');
    else
        a_nv(b_lp):=' ';
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_TAUH_TESTr(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_idG number,
    dt_ct in out clob, ds_ct in out clob,ds_dk clob,ds_dkbs clob,ds_lt clob,ds_kbt clob,

    ds_so_id out pht_type.a_num,ds_kieu_gcn out pht_type.a_var,ds_gcn out pht_type.a_var,ds_gcnG out pht_type.a_var,
    ds_tenC out pht_type.a_nvar,ds_cmtC out pht_type.a_var,ds_mobiC out pht_type.a_var,
    ds_emailC out pht_type.a_var,ds_dchiC out pht_type.a_nvar,ds_ng_huong out pht_type.a_nvar,

    ds_qtich out pht_type.a_var,ds_pvi out pht_type.a_nvar,ds_vtoc out pht_type.a_num,ds_hcai out pht_type.a_var,
    ds_tvo out pht_type.a_num,ds_may out pht_type.a_num,ds_tbi out pht_type.a_num,
    ds_nhom out pht_type.a_var,ds_loai out pht_type.a_var,ds_cap out pht_type.a_var,ds_vlieu out pht_type.a_var,
    ds_ttai out pht_type.a_num,ds_so_cn out pht_type.a_num,ds_dtich out pht_type.a_num,
    ds_csuat out pht_type.a_num,ds_gia out pht_type.a_num,ds_tuoi out pht_type.a_num,
    ds_ma_sp out pht_type.a_var,ds_dkien out pht_type.a_var,ds_md_sd out pht_type.a_var,ds_nv_bh out pht_type.a_var,
    ds_so_dk out pht_type.a_var,ds_ten_tau out pht_type.a_nvar,ds_nam_sx out pht_type.a_num,
    ds_hoi out pht_type.a_var,ds_hoi_tien out pht_type.a_num,ds_hoi_tyle out pht_type.a_num,
    ds_hoi_hh out pht_type.a_num,ds_tl_mgiu out pht_type.a_num,

    ds_gio_hl out pht_type.a_var,ds_ngay_hl out pht_type.a_num,
    ds_gio_kt out pht_type.a_var,ds_ngay_kt out pht_type.a_num,
    ds_ngay_cap out pht_type.a_num,ds_so_idP out pht_type.a_var, ds_tau_id out pht_type.a_num,
    ds_giam out pht_type.a_num,ds_phi out pht_type.a_num,
    ds_thue out pht_type.a_num,ds_ttoan out pht_type.a_num,

    dk_so_id out pht_type.a_num,dk_bt out pht_type.a_num,
    dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,dk_tc out pht_type.a_var,
    dk_ma_ct out pht_type.a_var,dk_kieu out pht_type.a_var,dk_tien out pht_type.a_num,dk_pt out pht_type.a_num,
    dk_phi out pht_type.a_num,dk_thue out pht_type.a_num,dk_ttoan out pht_type.a_num,
    dk_cap out pht_type.a_num,dk_ma_dk out pht_type.a_var,dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,
    dk_ptB out pht_type.a_num,dk_phiB out pht_type.a_num,dk_ptG out pht_type.a_num,dk_phiG out pht_type.a_num,
    dk_lkeP out pht_type.a_var,dk_lkeB out pht_type.a_var,dk_luy out pht_type.a_var,

    lt_so_id out pht_type.a_num,lt_dk out pht_type.a_clob,lt_lt out pht_type.a_clob,
    lt_kbt out pht_type.a_clob,b_tb out varchar2,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_i2 number; b_c varchar2(20); b_kt_dk number:=0;
    b_ps varchar2(1); dt_khd clob; b_txt clob;
    b_c_thue varchar2(1); b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tp number:=0;
    b_phi number; b_thue number; b_ttoan number; b_giam number; b_thueH number; b_ttoanH number;
    b_ten nvarchar2(500); b_dchi nvarchar2(500); b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);

    b_kieu_hd varchar2(1); b_ttrang varchar2(1); b_tygia number; b_so_idP number;
    b_gio_hl varchar2(50); b_ngay_hl number; b_gio_kt varchar2(50); b_ngay_kt number; b_ngay_cap number;
    b_loai_khH varchar2(1); b_cmtH varchar2(20); b_mobiH varchar2(20); b_emailH varchar2(100);
    b_tenH nvarchar2(500); b_dchiH nvarchar2(500); b_ma_khH varchar2(20); b_tuoi number; b_nv_bhC varchar2(10);

    b_ten_tau nvarchar2(500); b_ma_dk varchar2(10);

    a_ds_ct pht_type.a_clob; a_ds_dk pht_type.a_clob; a_ds_dkbs pht_type.a_clob;
    a_ds_lt pht_type.a_clob; a_ds_kbt pht_type.a_clob;

    a_bt pht_type.a_num; a_ma pht_type.a_var; a_ten pht_type.a_nvar;
    a_tc pht_type.a_var; a_ma_ct pht_type.a_var; a_kieu pht_type.a_var;
    a_tien pht_type.a_num; a_pt pht_type.a_num; a_phi pht_type.a_num;
    a_thue pht_type.a_num; a_ttoan pht_type.a_num;
    a_cap pht_type.a_num; a_ma_dk pht_type.a_var;
    a_lh_nv pht_type.a_var; a_t_suat pht_type.a_num;
    a_ptB pht_type.a_num; a_phiB pht_type.a_num;
    a_ptG pht_type.a_num; a_phiG pht_type.a_num;
    a_lkeP pht_type.a_var; a_lkeB pht_type.a_var; a_luy pht_type.a_var;

    a_nv_bh pht_type.a_var;
begin
-- Dan - Nhap
b_loi:='loi:Loi xu ly PBH_TAUH_TESTr:loi';
b_lenh:=FKH_JS_LENH('ttrang,kieu_hd,gio_hl,ngay_hl,gio_kt,ngay_kt,ngay_cap,
    thue,ttoan,nt_tien,nt_phi,tygia,c_thue,ten,cmt,mobi,email,dchi');
EXECUTE IMMEDIATE b_lenh into b_ttrang,b_kieu_hd,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,
    b_thueH,b_ttoanH,b_nt_tien,b_nt_phi,b_tygia,b_c_thue,b_ten,b_cmt,b_mobi,b_email,b_dchi using dt_ct;
b_c_thue:=nvl(trim(b_c_thue),'C');
if nvl(trim(b_nt_phi),'VND')<>'VND' then b_tp:=2; end if;
b_ten:=nvl(trim(b_ten),' '); b_dchi:=nvl(trim(b_dchi),' ');
b_cmt:=nvl(trim(b_cmt),' '); b_mobi:=nvl(trim(b_mobi),' '); b_email:=nvl(trim(b_email),' ');
b_lenh:=FKH_JS_LENHc('');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_ct using ds_ct;
if a_ds_ct.count=0 then b_loi:='loi:Nhap danh sach:loi'; return; end if;
b_lenh:=FKH_JS_LENHc('');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_dk using ds_dk;
EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_dkbs using ds_dkbs;
EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_lt using ds_lt;
EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_kbt using ds_kbt;
if a_ds_dkbs.count=0 then
    for b_lp in 1..a_ds_ct.count loop a_ds_dkbs(b_lp):=''; end loop;
end if;
if a_ds_lt.count=0 then
    for b_lp in 1..a_ds_ct.count loop a_ds_lt(b_lp):=''; end loop;
end if;
if a_ds_kbt.count=0 then
    for b_lp in 1..a_ds_ct.count loop a_ds_kbt(b_lp):=''; end loop;
end if;
for ds_lp in 1..a_ds_ct.count loop
    FKH_JS_NULL(a_ds_ct(ds_lp)); FKH_JSa_NULL(a_ds_dk(ds_lp)); FKH_JSa_NULL(a_ds_dkbs(ds_lp));  
    FKH_JSa_NULL(a_ds_lt(ds_lp));FKH_JSa_NULL(a_ds_kbt(ds_lp));
    PBH_TAUH_TESTd(dt_ct,a_ds_ct(ds_lp),a_ds_dk(ds_lp),a_ds_dkbs(ds_lp),
    b_ma_dvi,b_nsd,b_ttrang,b_kieu_hd,b_nt_tien,b_nt_phi,b_tygia,b_c_thue,b_ngay_hl,b_ngay_kt,b_ngay_cap,
    ds_so_id(ds_lp),ds_kieu_gcn(ds_lp),ds_gcn(ds_lp),ds_gcnG(ds_lp),
    ds_tenC(ds_lp),ds_cmtC(ds_lp),ds_mobiC(ds_lp),
    ds_emailC(ds_lp),ds_dchiC(ds_lp),ds_ng_huong(ds_lp),
    ds_qtich(ds_lp),ds_pvi (ds_lp),ds_vtoc (ds_lp),ds_hcai (ds_lp),ds_tvo (ds_lp),ds_may (ds_lp),ds_tbi (ds_lp),
    ds_nhom(ds_lp),ds_loai(ds_lp),ds_cap(ds_lp),ds_vlieu(ds_lp),
    ds_ttai(ds_lp),ds_so_cn(ds_lp),ds_dtich(ds_lp),ds_csuat(ds_lp),ds_gia(ds_lp),ds_tuoi(ds_lp),
    ds_ma_sp(ds_lp),ds_dkien(ds_lp),ds_md_sd(ds_lp),ds_nv_bh(ds_lp),
    ds_so_dk(ds_lp),ds_ten_tau(ds_lp),ds_nam_sx(ds_lp),
    ds_hoi(ds_lp),ds_hoi_tien(ds_lp),ds_hoi_tyle(ds_lp),ds_hoi_hh(ds_lp),ds_tl_mgiu(ds_lp),
    ds_ngay_hl(ds_lp),ds_ngay_kt(ds_lp),ds_ngay_cap(ds_lp),ds_so_idP(ds_lp),ds_tau_id(ds_lp),
    a_bt,a_ma,a_ten,a_tc,a_ma_ct,a_kieu,a_tien,a_pt,a_phi,a_thue,a_ttoan,a_cap,a_ma_dk,
    a_lh_nv,a_t_suat,a_ptB,a_phiB,a_lkeP,a_lkeB,a_luy,b_loi);
    if b_loi is not null then return; end if;
    ds_gio_hl(ds_lp):=b_gio_hl; ds_gio_kt(ds_lp):=b_gio_kt;
    for b_lp in 1..a_ma.count loop
        b_kt_dk:=b_kt_dk+1;
        dk_so_id(b_kt_dk):=ds_so_id(ds_lp); dk_bt(b_kt_dk):=a_bt(b_lp);
        dk_ma(b_kt_dk):=a_ma(b_lp); dk_ten(b_kt_dk):=a_ten(b_lp);
        dk_tc(b_kt_dk):=a_tc(b_lp); dk_ma_ct(b_kt_dk):=a_ma_ct(b_lp); dk_kieu(b_kt_dk):=a_kieu(b_lp);
        dk_tien(b_kt_dk):=a_tien(b_lp); dk_pt(b_kt_dk):=a_pt(b_lp); dk_phi(b_kt_dk):=a_phi(b_lp);
        dk_thue(b_kt_dk):=a_thue(b_lp); dk_ttoan(b_kt_dk):=a_ttoan(b_lp);
        dk_cap(b_kt_dk):=a_cap(b_lp); dk_ma_dk(b_kt_dk):=a_ma_dk(b_lp);
        dk_lh_nv(b_kt_dk):=a_lh_nv(b_lp); dk_t_suat(b_kt_dk):=a_t_suat(b_lp);
        dk_ptB(b_kt_dk):=a_ptB(b_lp); dk_phiB(b_kt_dk):=a_phiB(b_lp);
        dk_lkeP(b_kt_dk):=a_lkeP(b_lp); dk_lkeB(b_kt_dk):=a_lkeB(b_lp); dk_luy(b_kt_dk):=a_luy(b_lp);
    end loop;
end loop;
ds_ct:=FKH_ARRc_JS(a_ds_ct);
if b_kieu_hd in('B','S') and b_so_idG<>0 then
    for r_lp in (select so_id_dt,gcn from bh_tau_ds where ma_dvi=b_ma_dvi and so_id=b_so_idG) loop
        if FKH_ARR_VTRI_N(ds_so_id,r_lp.so_id_dt)=0 then b_loi:='loi:Khong xoa GCN cu '||r_lp.gcn||':loi'; return; end if;
    end loop;
end if;
PBH_HD_THAY_PHIg(b_nt_tien,b_nt_phi,b_tygia,b_thueH,b_ttoanH,dk_lh_nv,dk_tien,dk_phi,dk_thue,dk_ttoan,b_loi); -- nam
if b_loi is not null then return; end if;
for b_lp in 1..dk_ma.count loop
    if dk_phiB(b_lp)>dk_phi(b_lp) then
        dk_phiG(b_lp):=dk_phiB(b_lp)-dk_phi(b_lp);
        dk_ptG(b_lp):=round(dk_phiG(b_lp)*100/dk_phiB(b_lp),4);
    else
        dk_ptG(b_lp):=0; dk_phiG(b_lp):=0;
    end if;
end loop;
for b_lp in 1..ds_so_id.count loop
    b_phi:=0; b_thue:=0; b_giam:=0;
    for b_lp1 in 1..dk_so_id.count loop
        if dk_lh_nv(b_lp1)<>' ' and dk_so_id(b_lp1)=ds_so_id(b_lp) then
            b_phi:=b_phi+dk_phi(b_lp1); b_thue:=b_thue+dk_thue(b_lp1); b_giam:=b_giam+dk_phiG(b_lp1);
        end if;
    end loop;
    ds_giam(b_lp):=b_giam; ds_phi(b_lp):=b_phi; ds_thue(b_lp):=b_thue; ds_ttoan(b_lp):=b_phi+b_thue;
    lt_so_id(b_lp):=ds_so_id(b_lp); lt_lt(b_lp):=a_ds_lt(b_lp); lt_kbt(b_lp):=a_ds_kbt(b_lp);
end loop;
for b_lp in 1..ds_so_id.count loop
    ds_tau_id(b_lp):=FBH_TAUTSO_SO_ID(ds_so_dk(b_lp));

    if ds_tau_id(b_lp)<>0 then
          for r_lp in(select distinct nv_bh from bh_tau_ds where tau_id=ds_tau_id(b_lp) and so_id_dt<>ds_so_id(b_lp) and
              FKH_GIAO(ds_ngay_hl(b_lp),ds_ngay_kt(b_lp),ngay_hl,ngay_kt)='C' and FBH_TAU_TTRANG(ma_dvi,so_id,'C')='D') loop
              b_nv_bhC:=r_lp.nv_bh;
              b_i1:=length(b_nv_bhC);
              for b_lp1 in 1..b_i1 loop
                  if instr(ds_nv_bh(b_lp),substr(b_nv_bhC,b_lp1,1))<>0 then
                     b_tb:='Trung thoi gian bao hiem'; exit;
                  end if;
              end loop;
          end loop;
      else
          PHT_ID_MOI(ds_tau_id(b_lp),b_loi);
          if b_loi is not null then return; end if;
      end if;
end loop;
if b_ttrang in('T','D') then
    for b_lp in 1..ds_so_id.count loop
        b_lenh:=FKH_JS_LENH('loai_khh,tenh,dchih,cmth,mobih,emailh');
        EXECUTE IMMEDIATE b_lenh into b_loai_khH,b_tenH,b_dchiH,b_cmtH,b_mobiH,b_emailH using a_ds_ct(b_lp);
        if trim(b_tenH) is not null then
            ds_ng_huong(b_lp):=b_tenH;
            if trim(b_cmtH) is not null then
                if b_loai_khH='C' then
                    ds_ng_huong(b_lp):=b_tenH||', so CMT/CCCD: '||b_cmtH;
                else
                    ds_ng_huong(b_lp):=b_tenH||', ma thue : '||b_cmtH;
                end if;
            end if;
            if trim(b_dchiH) is not null then
                ds_ng_huong(b_lp):=b_tenH||', dia chi: '||b_dchiH;
            end if;
            select json_object('loai' value b_loai_khH,'ten' value b_tenH,'cmt' value b_cmtH,
                'dchi' value b_dchiH,'mobi' value b_mobiH,'email' value b_emailH) into b_txt from dual;
            PBH_DTAC_MA_NH(b_txt,b_ma_khH,b_loi,b_ma_dvi,b_nsd);
            if b_ma_khH not in(' ','VANGLAI') then PKH_JS_THAY(a_ds_ct(b_lp),'ma_khH',b_ma_khH); end if;
        end if;
        if ds_tenC(b_lp)<>' ' and ds_tenC(b_lp)<>b_ten and trim(ds_cmtC(b_lp)||ds_mobiC(b_lp)||ds_emailC(b_lp)) is not null then
            select json_object('loai' value 'C','ten' value ds_tenC(b_lp),'cmt' value ds_cmtC(b_lp),
                'dchi' value ds_dchiC(b_lp),'mobi' value ds_mobiC(b_lp),'email' value ds_emailC(b_lp)) into b_txt from dual;
            PBH_DTAC_MA_NH(b_txt,b_ma_khH,b_loi,b_ma_dvi,b_nsd);
            if b_ma_khH not in(' ','VANGLAI') then PKH_JS_THAY(a_ds_ct(b_lp),'ma_khC',b_ma_khH); end if;
        end if;
    end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_TAUH_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    dt_ct in out clob,dt_hu clob,ds_ct clob,ds_dk clob,ds_dkbs clob,ds_lt clob,ds_kbt clob,ds_ttt clob,
-- Chung
    b_so_hd varchar2,b_ngay_ht number,b_ttrang varchar2,b_kieu_hd varchar2,b_so_hd_g varchar2,
    b_kieu_kt varchar2,b_ma_kt varchar2,b_kieu_gt varchar2,b_ma_gt varchar2,b_ma_cb varchar2,
    b_loai_kh varchar2,b_ma_kh varchar2,b_ten nvarchar2,b_dchi nvarchar2,
    b_cmt varchar2,b_mobi varchar2,b_email varchar2,
    b_gio_hl varchar2,b_ngay_hl number,b_gio_kt varchar2,b_ngay_kt number,b_ngay_cap number,
    b_nt_tien varchar2,b_nt_phi varchar2,b_c_thue varchar2,
    b_phi number,b_giam number,b_thue number,b_ttoan number,b_hhong number,
    b_so_idG number,b_so_idD number,b_ngayD number,b_phong varchar2,
    tt_ngay pht_type.a_num,tt_tien pht_type.a_num,
-- Rieng
    ds_so_id pht_type.a_num,ds_kieu_gcn pht_type.a_var,ds_gcn pht_type.a_var,ds_gcnG pht_type.a_var,
    ds_tenC pht_type.a_nvar,ds_cmtC pht_type.a_var,ds_mobiC pht_type.a_var,
    ds_emailC pht_type.a_var,ds_dchiC pht_type.a_nvar,ds_ng_huong pht_type.a_nvar,
    
    ds_qtich pht_type.a_var,ds_pvi pht_type.a_nvar,ds_vtoc pht_type.a_num,ds_hcai pht_type.a_var,
    ds_tvo pht_type.a_num,ds_may pht_type.a_num,ds_tbi pht_type.a_num,
    ds_nhom pht_type.a_var,ds_loai pht_type.a_var,ds_cap pht_type.a_var,ds_vlieu pht_type.a_var,
    ds_ttai pht_type.a_num,ds_so_cn pht_type.a_num,ds_dtich pht_type.a_num,
    ds_csuat pht_type.a_num,ds_gia pht_type.a_num,ds_tuoi pht_type.a_num,
    ds_ma_sp pht_type.a_var,ds_dkien pht_type.a_var,ds_md_sd pht_type.a_var,ds_nv_bh pht_type.a_var,
    ds_so_dk pht_type.a_var,ds_ten_tau pht_type.a_nvar,ds_nam_sx pht_type.a_num,
    ds_hoi pht_type.a_var,ds_hoi_tien pht_type.a_num,ds_hoi_tyle pht_type.a_num,
    ds_hoi_hh pht_type.a_num,ds_tl_mgiu pht_type.a_num,

    ds_gio_hl pht_type.a_var,ds_ngay_hl pht_type.a_num,
    ds_gio_kt pht_type.a_var,ds_ngay_kt pht_type.a_num,
    ds_ngay_cap pht_type.a_num,ds_so_idP pht_type.a_var, ds_tau_id pht_type.a_num,
    ds_giam pht_type.a_num,ds_phi pht_type.a_num,
    ds_thue pht_type.a_num,ds_ttoan pht_type.a_num,

    dk_so_id pht_type.a_num,dk_bt pht_type.a_num,
    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tc pht_type.a_var,
    dk_ma_ct pht_type.a_var,dk_kieu pht_type.a_var,dk_tien pht_type.a_num,dk_pt pht_type.a_num,
    dk_phi pht_type.a_num,dk_thue pht_type.a_num,dk_ttoan pht_type.a_num,
    dk_cap pht_type.a_num,dk_ma_dk pht_type.a_var,
    dk_lh_nv pht_type.a_var,dk_t_suat pht_type.a_num,
    dk_ptB pht_type.a_num,dk_phiB pht_type.a_num,
    dk_ptG pht_type.a_num,dk_phiG pht_type.a_num,
    dk_lkeP pht_type.a_var,dk_lkeB pht_type.a_var,dk_luy pht_type.a_var,

    lt_so_id pht_type.a_num,lt_dk pht_type.a_clob,lt_lt pht_type.a_clob,lt_kbt pht_type.a_clob,b_loi out varchar2)
AS
    b_i1 number; b_so_dt number; b_so_id_kt number:=-1;
    b_tien number:=0; b_ma_ke varchar2(20):=' '; b_txt clob;
begin
-- Dan - Nhap
b_loi:='loi:Loi nhap Table bh_tau:loi';
b_so_dt:=ds_so_id.count;
if b_ttrang='D' then b_so_id_kt:=0; end if;
for b_lp in 1..ds_so_id.count loop
    insert into bh_tau_ds values(b_ma_dvi,b_so_id,
        ds_so_id(b_lp),b_lp,ds_kieu_gcn(b_lp),ds_gcn(b_lp),ds_gcnG(b_lp),
        ds_tenC(b_lp),ds_cmtC(b_lp),ds_mobiC(b_lp),ds_emailC(b_lp),ds_dchiC(b_lp),ds_ng_huong(b_lp),
        ds_nhom(b_lp),ds_loai(b_lp),ds_cap(b_lp),ds_vlieu(b_lp),ds_ttai(b_lp),ds_so_cn(b_lp),ds_dtich(b_lp),
        ds_csuat(b_lp),ds_gia(b_lp),ds_tuoi(b_lp),ds_ma_sp(b_lp),ds_dkien(b_lp),ds_md_sd(b_lp),ds_nv_bh(b_lp),ds_so_dk(b_lp),
        ds_ten_tau(b_lp),ds_nam_sx(b_lp),ds_hoi(b_lp),ds_hoi_tien(b_lp),ds_hoi_tyle(b_lp),ds_hoi_hh(b_lp),ds_tl_mgiu(b_lp),
        ds_gio_hl(b_lp),ds_ngay_hl(b_lp),ds_gio_kt(b_lp),ds_ngay_kt(b_lp),ds_ngay_cap(b_lp),
        ds_giam(b_lp),ds_phi(b_lp),ds_thue(b_lp),ds_ttoan(b_lp),ds_tau_id(b_lp));
end loop;
for b_lp in 1..ds_so_id.count loop
    delete bh_tau_ID where tau_id=ds_tau_id(b_lp);
    insert into bh_tau_ID values(ds_tau_id(b_lp),ds_ten_tau(b_lp),' ',ds_so_dk(b_lp),ds_loai(b_lp),ds_cap(b_lp),ds_qtich(b_lp),
    ds_vlieu(b_lp),ds_vtoc(b_lp),ds_ttai(b_lp),ds_csuat(b_lp),ds_dtich(b_lp),ds_so_cn(b_lp),
        ds_gia(b_lp),ds_tvo(b_lp),ds_may(b_lp),ds_tbi(b_lp),ds_nam_sx(b_lp),ds_hcai(b_lp),ds_pvi(b_lp));
end loop;
for b_lp in 1..dk_so_id.count loop
    if dk_lh_nv(b_lp)<>' ' and dk_kieu(b_lp)='T' then b_tien:=b_tien+dk_tien(b_lp); end if;
    insert into bh_tau_dk values(b_ma_dvi,b_so_id,dk_so_id(b_lp),dk_bt(b_lp),
        dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),dk_kieu(b_lp),
        dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),dk_cap(b_lp),dk_ma_dk(b_lp),dk_lh_nv(b_lp),
        dk_t_suat(b_lp),dk_thue(b_lp),dk_ttoan(b_lp),dk_ptB(b_lp),dk_ptG(b_lp),dk_phiG(b_lp),
        dk_lkeP(b_lp),dk_lkeB(b_lp),dk_luy(b_lp));
end loop;
insert into bh_tau values(
    b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,'H',b_ttrang,b_kieu_hd,b_so_hd_g,
    b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,b_phong,'T',b_loai_kh,
    b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,
    b_nt_tien,b_nt_phi,b_c_thue,b_so_dt,b_tien,b_phi,b_giam,b_thue,b_ttoan,b_hhong,
    b_so_idG,b_so_idD,'','',b_so_id_kt,b_nsd,sysdate);
for b_lp in 1..tt_ngay.count loop
    insert into bh_tau_tt values(b_ma_dvi,b_so_id,tt_ngay(b_lp),tt_tien(b_lp));
end loop;
PKH_JS_THAYa(dt_ct,'so_hd,ma_kh',b_so_hd||','||b_ma_kh);
insert into bh_tau_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
insert into bh_tau_txt values(b_ma_dvi,b_so_id,'ds_ct',ds_ct);
insert into bh_tau_txt values(b_ma_dvi,b_so_id,'ds_dk',ds_dk);
if trim(dt_hu) is not null then
    insert into bh_tau_txt values(b_ma_dvi,b_so_id,'dt_hu',dt_hu);
end if;
if trim(ds_dkbs) is not null then
    insert into bh_tau_txt values(b_ma_dvi,b_so_id,'ds_dkbs',ds_dkbs);
end if;
if trim(ds_lt) is not null then
    insert into bh_tau_txt values(b_ma_dvi,b_so_id,'ds_lt',ds_lt);
end if;
if trim(ds_kbt) is not null  then
    insert into bh_tau_txt values(b_ma_dvi,b_so_id,'ds_kbt',ds_kbt);
end if;
if trim(ds_ttt) is not null then
    insert into bh_tau_txt values(b_ma_dvi,b_so_id,'ds_ttt',ds_ttt);
end if;
if b_ttrang in ('D','T') then
    for b_lp in 1..lt_so_id.count loop
        select JSON_ARRAYAGG(json_object(
            ma,ten,tc,ma_ct,kieu,tien,pt,phi,cap,ma_dk,lh_nv,t_suat,thue,ttoan,ptB,ptG,phiG,lkeP,lkeB,luy)
            order by bt returning clob) into b_txt
            from bh_tau_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=lt_so_id(b_lp);
        insert into bh_tau_kbt values(b_ma_dvi,b_so_id,lt_so_id(b_lp),b_txt,lt_lt(b_lp),lt_kbt(b_lp));
    end loop;
    select json_object('ma_dvi' value b_ma_dvi,'nsd' value b_nsd,'so_id' value b_so_id,'so_hd' value b_so_hd,
        'kieu_hd' value b_kieu_hd,'nv' value 'TAU','ngay_ht' value b_ngay_ht,'ngay_cap' value b_ngay_cap,
        'ngay_hl' value b_ngay_hl,'ngay_kt' value b_ngay_kt,'cb_ql' value b_ma_cb,'phong' value b_phong,
        'kieu_kt' value b_kieu_kt,'ma_kt' value b_ma_kt,'dly_tke' value ' ','hhong' value b_hhong,'pt_hhong' value 'D',
        'ma_kh' value b_ma_kh,'ten' value b_ten,'kieu_gt' value b_kieu_gt,'ma_gt' value b_ma_gt,
        'so_id_d' value b_so_idD,'so_id_g' value b_so_idG,'ttrang' value b_ttrang,
        'dvi_ksoat' value b_ma_dvi,'ksoat' value b_nsd,'bangg' value 'bh_tau',
        'c_thue' value b_c_thue,'nt_tien' value b_nt_tien,'nt_phi' value b_nt_phi,'tien' value b_tien,
        'phi' value b_ttoan-b_thue,'thue' value b_thue returning clob) into b_txt from dual;
    PBH_HD_GOC_NH(b_txt,b_loi);
    if b_loi is not null then return; end if;
end if;
if b_ttrang='D' then
    for b_lp in 1..ds_so_id.count loop
        PBH_KE_CTI_NHOM(b_ma_dvi,b_so_idD,ds_so_id(b_lp),b_ma_ke,b_loi);
        if b_loi is null then return; end if;
        insert into bh_hd_goc_ttindt values(b_ma_dvi,b_so_idD,ds_so_id(b_lp),'TAU',
            ds_so_dk(b_lp)||' -- '||ds_ten_tau(b_lp),b_ma_kh,ds_ngay_kt(b_lp),' ',b_ma_ke);
    end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_TAUH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(1000); b_lenh varchar2(2000); b_i1 number;
    dt_ct clob; dt_hu clob; ds_ct clob; ds_dk clob; ds_dkbs clob; ds_lt clob; ds_kbt clob; ds_ttt clob; dt_kytt clob;
-- Chung
    b_so_id number; b_so_hd varchar2(20); b_ngay_ht number; b_ttrang varchar2(1); b_kieu_hd varchar2(1); b_so_hd_g varchar2(20);
    b_kieu_kt varchar2(1); b_ma_kt varchar2(20); b_kieu_gt varchar2(1); b_ma_gt varchar2(20); b_ma_cb varchar2(20);
    b_loai_kh varchar2(1); b_ma_kh varchar2(20); b_ten nvarchar2(500); b_dchi nvarchar2(500);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_gio_hl varchar2(20); b_ngay_hl number; b_gio_kt varchar2(20); b_ngay_kt number; b_ngay_cap number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_c_thue varchar2(1);
    b_phi number; b_giam number; b_thue number; b_ttoan number; b_hhong number;
    b_so_idG number; b_so_idD number; b_ngayD number; b_phong varchar2(10); b_tb varchar2(200);
    tt_ngay pht_type.a_num; tt_tien pht_type.a_num; 
-- Rieng
    ds_so_id pht_type.a_num; ds_kieu_gcn pht_type.a_var; ds_gcn pht_type.a_var; ds_gcnG pht_type.a_var;
    ds_tenC pht_type.a_nvar; ds_cmtC pht_type.a_var; ds_mobiC pht_type.a_var;
    ds_emailC pht_type.a_var; ds_dchiC pht_type.a_nvar; ds_ng_huong pht_type.a_nvar;

    ds_so_dk pht_type.a_var; ds_ten_tau pht_type.a_nvar; ds_qtich pht_type.a_var;
    ds_pvi pht_type.a_nvar;
    ds_nhom pht_type.a_var; ds_loai pht_type.a_var; ds_cap pht_type.a_var; ds_vlieu pht_type.a_var;
    ds_csuat pht_type.a_num; ds_so_cn pht_type.a_num; ds_ttai pht_type.a_num; ds_dtich pht_type.a_num;
    ds_vtoc pht_type.a_num; ds_nam_sx pht_type.a_num; ds_hcai pht_type.a_var; ds_gia pht_type.a_num;
    ds_tvo pht_type.a_num; ds_may pht_type.a_num; ds_tbi pht_type.a_num; ds_tuoi pht_type.a_num;
    ds_ma_sp pht_type.a_var; ds_dkien pht_type.a_var; ds_md_sd pht_type.a_var; ds_nv_bh pht_type.a_var;
    ds_hoi pht_type.a_var; ds_hoi_tien pht_type.a_num; ds_hoi_tyle pht_type.a_num;
    ds_hoi_hh pht_type.a_num; ds_tl_mgiu pht_type.a_num;
    ds_tau_id pht_type.a_num;
    ds_gio_hl pht_type.a_var; ds_ngay_hl pht_type.a_num;
    ds_gio_kt pht_type.a_var; ds_ngay_kt pht_type.a_num;
    ds_ngay_cap pht_type.a_num; ds_so_idP pht_type.a_var; 
    ds_giam pht_type.a_num; ds_phi pht_type.a_num;
    ds_thue pht_type.a_num; ds_ttoan pht_type.a_num;

    dk_so_id pht_type.a_num; dk_bt pht_type.a_num;
    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var;
    dk_ma_ct pht_type.a_var; dk_kieu pht_type.a_var; dk_tien pht_type.a_num; dk_pt pht_type.a_num;
    dk_phi pht_type.a_num; dk_thue pht_type.a_num; dk_ttoan pht_type.a_num;
    dk_cap pht_type.a_num; dk_ma_dk pht_type.a_var;
    dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num;
    dk_ptB pht_type.a_num; dk_phiB pht_type.a_num;
    dk_ptG pht_type.a_num; dk_phiG pht_type.a_num;
    dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var; dk_luy pht_type.a_var;

    lt_so_id pht_type.a_num; lt_dk pht_type.a_clob; lt_lt pht_type.a_clob; lt_kbt pht_type.a_clob;
-- Xu ly
    b_ngay_htC number;
begin
-- Dan - Nhap
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_hu,ds_ct,ds_dk,ds_dkbs,ds_lt,ds_kbt,ds_ttt,dt_kytt');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_hu,ds_ct,ds_dk,ds_dkbs,ds_lt,ds_kbt,ds_ttt,dt_kytt using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_hu); FKH_JSa_NULL(dt_kytt);
if b_so_id<>0 then
    select count(*) into b_i1 from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 then
        select ngay_ht,kieu_hd,ttrang into b_ngay_htC,b_kieu_hd,b_ttrang from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
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
PBH_TAUH_TESTr(
    b_ma_dvi,b_nsd,b_so_idG,
    dt_ct, ds_ct,ds_dk,ds_dkbs,ds_lt,ds_kbt,
    ds_so_id,ds_kieu_gcn,ds_gcn,ds_gcnG,ds_tenC,ds_cmtC,ds_mobiC,ds_emailC,ds_dchiC,ds_ng_huong,
    ds_qtich,ds_pvi,ds_vtoc,ds_hcai,ds_tvo,ds_may,ds_tbi,
    ds_nhom,ds_loai,ds_cap,ds_vlieu,ds_ttai,ds_so_cn,ds_dtich,ds_csuat,ds_gia,ds_tuoi,
    ds_ma_sp,ds_dkien,ds_md_sd,ds_nv_bh,ds_so_dk,ds_ten_tau,ds_nam_sx,ds_hoi,ds_hoi_tien,
    ds_hoi_tyle,ds_hoi_hh,ds_tl_mgiu,ds_gio_hl,ds_ngay_hl,ds_gio_kt,ds_ngay_kt,
    ds_ngay_cap,ds_so_idP,ds_tau_id,ds_giam,ds_phi,ds_thue,ds_ttoan,
    dk_so_id,dk_bt,dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,
    dk_cap,dk_ma_dk,dk_lh_nv,dk_t_suat,dk_ptB,dk_phiB,dk_ptG,dk_phiG,dk_lkeP,dk_lkeB,dk_luy,
    lt_so_id,lt_dk,lt_lt,lt_kbt,b_tb,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TAUH_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,
    dt_ct,dt_hu,ds_ct,ds_dk,ds_dkbs,ds_lt,ds_kbt,ds_ttt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
    b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,
    b_so_idG,b_so_idD,b_ngayD,b_phong,
    tt_ngay,tt_tien,
    ds_so_id,ds_kieu_gcn,ds_gcn,ds_gcnG,ds_tenC,ds_cmtC,ds_mobiC,ds_emailC,ds_dchiC,ds_ng_huong,
    ds_qtich,ds_pvi,ds_vtoc,ds_hcai,ds_tvo,ds_may,ds_tbi,
    ds_nhom,ds_loai,ds_cap,ds_vlieu,ds_ttai,ds_so_cn,ds_dtich,ds_csuat,ds_gia,ds_tuoi,
    ds_ma_sp,ds_dkien,ds_md_sd,ds_nv_bh,ds_so_dk,ds_ten_tau,ds_nam_sx,ds_hoi,ds_hoi_tien,ds_hoi_tyle,ds_hoi_hh,ds_tl_mgiu,
    ds_gio_hl,ds_ngay_hl,ds_gio_kt,ds_ngay_kt,ds_ngay_cap,ds_so_idP,ds_tau_id,ds_giam,ds_phi,ds_thue,ds_ttoan,
    dk_so_id,dk_bt,dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,
    dk_cap,dk_ma_dk,dk_lh_nv,dk_t_suat,dk_ptB,dk_phiB,dk_ptG,dk_phiG,dk_lkeP,dk_lkeB,dk_luy,
    lt_so_id,lt_dk,lt_lt,lt_kbt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hd' value b_so_hd, 'ma_kh' value b_ma_kh,'tb' value b_tb) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
