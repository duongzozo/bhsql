create or replace procedure PBH_XEH_DK(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_so_hd_g varchar2(20); b_so_id number; b_so_id_dt number;
    dt_dk clob:=''; dt_dkbs clob:='';
begin
-- Dan - Tra thue
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hd_h,so_id_dt');
EXECUTE IMMEDIATE b_lenh into b_so_hd_g,b_so_id_dt using b_oraIn;
b_so_id:=FBH_XE_SO_ID(b_ma_dvi,b_so_hd_g);
if b_so_id<>0 then
    select JSON_ARRAYAGG(json_object(ma,thue) returning clob) into dt_dk from bh_xe_dk
        where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and lh_bh='C';
    select JSON_ARRAYAGG(json_object(ma,thue) returning clob) into dt_dkbs from bh_xe_dk
        where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and lh_bh='M';
end if;
select json_object('dt_dk' value dt_dk,'dt_dkbs' value dt_dkbs returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XEH_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number; b_nv varchar2(1);
    dt_ct clob; dt_hu clob; dt_ds clob; dt_kytt clob; dt_txt clob;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','XE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
select json_object(so_hd,ma_kh,so_dt,kieu_hd),nv into dt_ct,b_nv from bh_xe where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nv <> 'H' then
  b_loi:='loi:Sai kieu hop dong:loi'; raise PROGRAM_ERROR;
end if;
select txt into dt_ds from bh_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
select count(*) into b_i1 from bh_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hu';
if b_i1=1 then
    select txt into dt_hu from bh_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hu';
end if;
select JSON_ARRAYAGG(json_object(ngay,tien) order by ngay) into dt_kytt from bh_xe_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
  from bh_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'dt_ds' value dt_ds,'dt_hu' value dt_hu,'dt_kytt' value dt_kytt,
    'dt_ct' value dt_ct,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XEH_TESTr(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_idG number,
    dt_ct in out clob,dt_ds in out clob,
    b_so_hdL out varchar2,b_ngay_capH number,b_bao_gia varchar2, -- viet anh - them b_bao_gia='BG'
    ds_so_id out pht_type.a_num,ds_kieu_gcn out pht_type.a_var,
    ds_loai_ac out pht_type.a_var,ds_mau_ac out pht_type.a_var,ds_gcn out pht_type.a_var,ds_gcnG out pht_type.a_var,
    ds_ma_sp out pht_type.a_var,ds_cdich out pht_type.a_var,ds_goi out pht_type.a_var,
    ds_tenC out pht_type.a_nvar,ds_cmtC out pht_type.a_var,ds_mobiC out pht_type.a_var,
    ds_emailC out pht_type.a_var,ds_dchiC out pht_type.a_nvar,ds_ng_huong out pht_type.a_nvar,
    ds_bien_xe out pht_type.a_var,ds_so_khung out pht_type.a_var,ds_so_may out pht_type.a_var,
    ds_hang out pht_type.a_var,ds_hieu out pht_type.a_var,ds_pban out pht_type.a_var,
    ds_loai_xe out pht_type.a_var,ds_nhom_xe out pht_type.a_var,ds_dong out pht_type.a_var,
    ds_dco out pht_type.a_var,ds_ttai out pht_type.a_num,ds_so_cn out pht_type.a_num,
    ds_thang_sx out pht_type.a_num,ds_nam_sx out pht_type.a_num,ds_gia out pht_type.a_num,
    ds_md_sd out pht_type.a_var,ds_nv_bh out pht_type.a_var,ds_bh_tbo out pht_type.a_var,
    ds_ngay_hl out pht_type.a_num,ds_ngay_kt out pht_type.a_num,ds_ngay_cap out pht_type.a_num,
    ds_so_idP out pht_type.a_var,ds_xe_id out pht_type.a_num,
    ds_giam out pht_type.a_num,ds_phi out pht_type.a_num,
    ds_thue out pht_type.a_num,ds_ttoan out pht_type.a_num,

    dk_so_id out pht_type.a_num,dk_bt out pht_type.a_num,dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,dk_tc out pht_type.a_var,
    dk_ma_ct out pht_type.a_var,dk_kieu out pht_type.a_var,dk_tien out pht_type.a_num,dk_pt out pht_type.a_num,
    dk_phi out pht_type.a_num,dk_thue out pht_type.a_num,dk_ttoan out pht_type.a_num,
    dk_cap out pht_type.a_num,dk_ma_dk out pht_type.a_var,dk_ma_dkC out pht_type.a_var, dk_nv out pht_type.a_var, -- viet anh -- them ma_dkC and nv
    dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,
    dk_ptB out pht_type.a_num,dk_phiB out pht_type.a_num,
    dk_ptG out pht_type.a_num,dk_phiG out pht_type.a_num,
    dk_lkeM out pht_type.a_var, -- viet anh
    dk_lkeP out pht_type.a_var,dk_lkeB out pht_type.a_var,dk_lh_bh out pht_type.a_var,

    lt_so_id out pht_type.a_num,lt_dk out pht_type.a_clob,lt_lt out pht_type.a_clob,
    lt_kbt out pht_type.a_clob,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_i2 number; b_kt number; b_ktG number; b_ps varchar2(1); dt_khd clob; b_txt clob;
    b_c_thue varchar2(1); b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tp number:=0; b_ktruC varchar2(30);
    b_phi number; b_thue number; b_ttoan number; b_giam number; b_thueH number; b_ttoanH number;
    b_ten nvarchar2(500); b_dchi nvarchar2(500); b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);

    b_kieu_hd varchar2(1); b_ttrang varchar2(1); b_tygia number; b_so_idP number; b_ma_dk varchar2(10); b_ma_dkC varchar2(10);
    b_gio_hl varchar2(50); b_ngay_hl number; b_gio_kt varchar2(50); b_ngay_kt number; b_ngay_cap number;
    b_loai_khH varchar2(1); b_cmtH varchar2(20); b_mobiH varchar2(20); b_emailH varchar2(100);
    b_tenH nvarchar2(500); b_dchiH nvarchar2(500); b_ma_khH varchar2(20); b_tuoi number; b_nv_bhC varchar2(10);

    a_ds_ct pht_type.a_clob; a_ds_dk pht_type.a_clob; a_ds_lt pht_type.a_clob; a_ds_ttt pht_type.a_clob;
    a_ds_kbt pht_type.a_clob; a_ds_dkbs pht_type.a_clob; a_dsM pht_type.a_clob;
    a_nv pht_type.a_var; a_bien pht_type.a_var; ds_so_idS pht_type.a_var; ds_ktru pht_type.a_num;

    dk_maX pht_type.a_var; dk_tenX pht_type.a_nvar; dk_tcX pht_type.a_var; dk_ma_ctX pht_type.a_var;
    dk_ma_dkX pht_type.a_var; dk_ma_dkCX pht_type.a_var; dk_kieuX pht_type.a_var; dk_tienX pht_type.a_num; dk_ptX pht_type.a_num;
    dk_phiX pht_type.a_num; dk_thueX pht_type.a_num;
    dk_lkeMX pht_type.a_var;
    dk_lkePX pht_type.a_var; dk_lkeBX pht_type.a_var;
    dk_lh_nvX pht_type.a_var; dk_t_suatX pht_type.a_num; dk_nvX pht_type.a_var; dk_capX pht_type.a_num;
    dk_ptGX pht_type.a_num; dk_phiGX pht_type.a_num; dk_ptBX pht_type.a_num; dk_phiBX pht_type.a_num;

    a_loaiL pht_type.a_var; a_maL pht_type.a_var; a_loi pht_type.a_var;
    ds_cdtC pht_type.a_var; ds_cdtF pht_type.a_var; ds_cdtX pht_type.a_var; b_cdt varchar2(10);
begin
-- Dan - Nhap
b_lenh:=FKH_JS_LENH('ttrang,kieu_hd,gio_hl,ngay_hl,gio_kt,ngay_kt,ngay_cap,
    thue,ttoan,nt_tien,nt_phi,tygia,c_thue,ten,cmt,mobi,email,dchi,so_hdl');
EXECUTE IMMEDIATE b_lenh into b_ttrang,b_kieu_hd,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,
    b_thueH,b_ttoanH,b_nt_tien,b_nt_phi,b_tygia,b_c_thue,b_ten,b_cmt,b_mobi,b_email,b_dchi,b_so_hdL using dt_ct;
b_c_thue:=nvl(trim(b_c_thue),'C');
if nvl(trim(b_nt_phi),'VND')<>'VND' then b_tp:=2; end if;
b_ten:=nvl(trim(b_ten),' '); b_dchi:=nvl(trim(b_dchi),' ');
b_cmt:=nvl(trim(b_cmt),' '); b_mobi:=nvl(trim(b_mobi),' '); b_email:=nvl(trim(b_email),' ');
if b_so_hdL not in('E','P','T') then b_so_hdL:='T'; end if;
b_lenh:=FKH_JS_LENHc('ds_ct,ds_dk,ds_lt,ds_kbt,ds_ttt,ds_dkbs');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_ct,a_ds_dk,a_ds_lt,a_ds_kbt,a_ds_ttt,a_ds_dkbs using dt_ds;
if a_ds_ct.count=0 then b_loi:='loi:Nhap danh sach xe:loi'; return; end if;
a_loaiL(1):='MDSD'; a_loi(1):='muc dich su dung';
a_loaiL(2):='LOAI'; a_loi(2):='loai xe';
b_kt:=0;
for ds_lp in 1..a_ds_ct.count loop
    b_lenh:='so_id_dt,so_ids,loai_ac,mau_ac,gcn,gcn_g,ngay_hl,ngay_kt,ngay_cap,ma_sp,cdich,goi,';
    b_lenh:=b_lenh||'tenc,cmtc,mobic,emailc,dchic,';
    b_lenh:=b_lenh||'bien_xe,so_khung,so_may,hang,hieu,pban,';
    b_lenh:=b_lenh||'loai_xe,nhom_xe,dong,dco,ttai,so_cn,thang_sx,nam_sx,gia,';
    b_lenh:=b_lenh||'md_sd,bh_tbo,ktru,nvb,nvt,nvv,nvm,cdtc,cdtf,cdtx';
    b_lenh:=FKH_JS_LENH(b_lenh);
    EXECUTE IMMEDIATE b_lenh into
        ds_so_id(ds_lp),ds_so_idS(ds_lp),ds_loai_ac(ds_lp),ds_mau_ac(ds_lp),ds_gcn(ds_lp),ds_gcnG(ds_lp),
        ds_ngay_hl(ds_lp),ds_ngay_kt(ds_lp),ds_ngay_cap(ds_lp),ds_ma_sp(ds_lp),ds_cdich(ds_lp),ds_goi(ds_lp),
        ds_tenC(ds_lp),ds_cmtC(ds_lp),ds_mobiC(ds_lp),ds_emailC(ds_lp),ds_dchiC(ds_lp),
        ds_bien_xe(ds_lp),ds_so_khung(ds_lp),ds_so_may(ds_lp),ds_hang(ds_lp),ds_hieu(ds_lp),ds_pban(ds_lp),
        ds_loai_xe(ds_lp),ds_nhom_xe(ds_lp),ds_dong(ds_lp),ds_dco(ds_lp),ds_ttai(ds_lp),ds_so_cn(ds_lp),ds_thang_sx(ds_lp),ds_nam_sx(ds_lp),ds_gia(ds_lp),
        ds_md_sd(ds_lp),ds_bh_tbo(ds_lp),b_ktruC,a_nv(1),a_nv(2),a_nv(3),a_nv(4),ds_cdtC(ds_lp),ds_cdtF(ds_lp),ds_cdtX(ds_lp) using a_ds_ct(ds_lp);
    -- chuclh - fix kieu gcn
    ds_ktru(ds_lp):=PKH_LOC_CHU_SO(PKH_TEN_TENl(b_ktruC),'F','T');
    ds_kieu_gcn(ds_lp):='G'; ds_bien_xe(ds_lp):=nvl(trim(ds_bien_xe(ds_lp)),' ');
    ds_so_khung(ds_lp):=nvl(trim(ds_so_khung(ds_lp)),' '); ds_so_may(ds_lp):=nvl(trim(ds_so_may(ds_lp)),' ');
    if ds_bien_xe(ds_lp)<>' ' then
        a_bien(ds_lp):=ds_bien_xe(ds_lp);
    elsif ds_so_khung(ds_lp)<>' ' then
        a_bien(ds_lp):=ds_so_khung(ds_lp);
    else
        b_loi:='loi:Nhap bien xe, so khung '||to_char(ds_lp)||':loi'; return;
    end if;
     -- viet anh - check ngay hl, ngay kt
    if b_ngay_hl>b_ngay_kt or b_ngay_hl > ds_ngay_hl(ds_lp) or b_ngay_kt < ds_ngay_kt(ds_lp) or ds_ngay_hl(ds_lp) > ds_ngay_kt(ds_lp) then
        b_loi:='loi:Sai Ngay hieu luc - '||a_bien(ds_lp)||':loi'; return;
    end if;
    --
    ds_ma_sp(ds_lp):=nvl(trim(ds_ma_sp(ds_lp)),' '); ds_cdich(ds_lp):=nvl(trim(ds_cdich(ds_lp)),' '); ds_goi(ds_lp):=nvl(trim(ds_goi(ds_lp)),' ');
    if ds_ma_sp(ds_lp)<>' ' and FBH_XE_SP_HAN(ds_ma_sp(ds_lp))<>'C' then b_loi:='loi:Sai ma san pham xe '||a_bien(ds_lp)||':loi'; return; end if;
    if ds_cdich(ds_lp)<>' ' and FBH_MA_CDICH_HAN(ds_cdich(ds_lp))<>'C' then b_loi:='loi:Het chien dich xe '||a_bien(ds_lp)||':loi'; return; end if;
    if ds_goi(ds_lp)<>' ' and FBH_XE_GOI_HAN(ds_goi(ds_lp))<>'C' then b_loi:='loi:Ma goi het han xe '||a_bien(ds_lp)||':loi'; return; end if;
    if trim(ds_tenC(ds_lp)) is null then
        ds_tenC(ds_lp):=b_ten; ds_dchiC(ds_lp):=b_dchi; ds_cmtC(ds_lp):=b_cmt; ds_mobiC(ds_lp):=b_mobi; ds_emailC(ds_lp):=b_email;
    end if;
    ds_hang(ds_lp):=PKH_MA_TENl(ds_hang(ds_lp)); ds_hieu(ds_lp):=PKH_MA_TENl(ds_hieu(ds_lp)); ds_pban(ds_lp):=PKH_MA_TENl(ds_pban(ds_lp));
    ds_loai_xe(ds_lp):=PKH_MA_TENl(ds_loai_xe(ds_lp)); ds_nhom_xe(ds_lp):=PKH_MA_TENl(ds_nhom_xe(ds_lp));
    ds_dong(ds_lp):=PKH_MA_TENl(ds_dong(ds_lp)); ds_dco(ds_lp):=PKH_MA_TENl(ds_dco(ds_lp));
    ds_ttai(ds_lp):=nvl(ds_ttai(ds_lp),0); ds_so_cn(ds_lp):=nvl(ds_so_cn(ds_lp),0);
    ds_nam_sx(ds_lp):=nvl(ds_nam_sx(ds_lp),0); ds_gia(ds_lp):=nvl(ds_gia(ds_lp),0);
    ds_md_sd(ds_lp):=PKH_MA_TENl(ds_md_sd(ds_lp)); ds_bh_tbo(ds_lp):=nvl(trim(ds_bh_tbo(ds_lp)),'C');
    if ds_hang(ds_lp)<>' ' and FBH_XE_HANG_HAN(ds_hang(ds_lp))<>'C' then b_loi:='loi:Sai hang xe xe '||a_bien(ds_lp)||':loi'; return; end if;
    if ds_hang(ds_lp)<>' ' and ds_hieu(ds_lp)<>' ' and FBH_XE_HIEU_HAN(ds_hang(ds_lp),ds_hieu(ds_lp))<>'C' then
        b_loi:='loi:Sai hieu xe '||a_bien(ds_lp)||':loi'; return;
    end if;
    if ds_hang(ds_lp)<>' ' and ds_hieu(ds_lp)<>' ' and ds_pban(ds_lp)<>' ' and FBH_XE_PB_HAN(ds_hang(ds_lp),ds_hieu(ds_lp),ds_pban(ds_lp))<>'C' then
        b_loi:='loi:Sai phien ban xe '||a_bien(ds_lp)||':loi'; return;
    end if;
    if ds_dong(ds_lp)<>' ' and FBH_XE_DONG_HAN(ds_dong(ds_lp))<>'C' then b_loi:='loi:Sai dong xe '||a_bien(ds_lp)||':loi'; return; end if;
    if ds_dco(ds_lp) not in(' ','X','D','E','H') then b_loi:='loi:Sai loai dong co:loi'; return; end if;
    if ds_loai_xe(ds_lp)<>' ' and FBH_XE_LOAI_HAN(ds_loai_xe(ds_lp))<>'C' then b_loi:='loi:Sai loai xe '||a_bien(ds_lp)||':loi'; return; end if;
    if ds_nhom_xe(ds_lp)<>' ' and FBH_XE_NHOM_HAN(ds_nhom_xe(ds_lp))<>'C' then b_loi:='loi:Sai nhom xe '||a_bien(ds_lp)||':loi'; return; end if;
    if ds_md_sd(ds_lp)<>' ' and FBH_XE_MDSD_HAN(ds_md_sd(ds_lp))<>'C' then b_loi:='loi:Sai muc dich su dung xe '||a_bien(ds_lp)||':loi'; return; end if;
    ds_nv_bh(ds_lp):=''; ds_so_idP(ds_lp):=''; ds_ng_huong(ds_lp):=''; ds_xe_id(ds_lp):=0;
    for b_lp in 1..3 loop
        a_nv(b_lp):=nvl(trim(a_nv(b_lp)),' ');
        if a_nv(b_lp)='C' then
            a_nv(b_lp):=substr('BTV',b_lp,1);
            PKH_GHEP(ds_nv_bh(ds_lp),a_nv(b_lp));
        else
            a_nv(b_lp):=' ';
        end if;
    end loop;
    b_tuoi:=FBH_XE_TUOIt(ds_thang_sx(ds_lp),ds_nam_sx(ds_lp));
    if ds_nv_bh(ds_lp) is null then b_loi:='loi:Chua chon loai phi mua xe '||a_bien(ds_lp)||':loi'; return; end if;
    --
    for b_lp1 in 1..3 loop
        if a_nv(b_lp1)<>' ' then
            FBH_XE_BPHI_SO_ID('H',a_nv(b_lp1),ds_bh_tbo(ds_lp),ds_md_sd(ds_lp),
                ds_ma_sp(ds_lp),ds_cdich(ds_lp),ds_goi(ds_lp),ds_loai_xe(ds_lp),ds_nhom_xe(ds_lp),
                ds_dong(ds_lp),ds_dco(ds_lp),ds_ttai(ds_lp),ds_so_cn(ds_lp),
                b_tuoi,ds_gia(ds_lp),ds_ngay_hl(ds_lp),b_so_idP,b_loi);
            if b_loi is not null then return; end if;
            if b_so_idP=0 then b_loi:='loi:Khong co bieu phi ' || a_nv(b_lp1) ||' xe '|| a_bien(ds_lp) ||':loi'; return; end if;
            PKH_GHEP(ds_so_idP(ds_lp),to_char(b_so_idP));
        end if;
    end loop;
    if ds_so_idS(ds_lp)<>ds_so_idP(ds_lp) then
        b_loi:='loi:Khac bieu phi xe '||a_bien(ds_lp)||':loi'; return;
    end if;
    ds_gcn(ds_lp):=nvl(trim(ds_gcn(ds_lp)),' '); ds_gcnG(ds_lp):=nvl(trim(ds_gcnG(ds_lp)),' ');

    if ds_so_id(ds_lp)<100000 then
        PHT_ID_MOI(ds_so_id(ds_lp),b_loi);
        if b_loi is not null then return; end if;
    ds_kieu_gcn(ds_lp):='G'; ds_gcnG(ds_lp):=' ';
    elsif b_kieu_hd in('S','B') and ds_gcnG(ds_lp)<>' ' then
        select count(*) into b_i1 from bh_xe_ds where ma_dvi=b_ma_dvi and so_id_dt=ds_so_id(ds_lp) and gcn=ds_gcnG(ds_lp);
        if b_i1=0 then b_loi:='loi:GCN '||ds_gcnG(ds_lp)||' da xoa:loi'; return; end if;
        ds_kieu_gcn(ds_lp):=b_kieu_hd;
    if ds_gcn(ds_lp)=ds_gcnG(ds_lp) then ds_gcn(ds_lp):=' '; end if;
    end if;
    -- sinh so GCN
    -- viet anh -- them b_bao_gia -- BG thi ko sinh so gcn
    if b_bao_gia<>'BG' then
      if ds_gcn(ds_lp)=' ' or instr(ds_gcn(ds_lp),'.')=2 then
          --if b_so_hdL='P' then b_loi:='loi:Nhap so GCN xe '||a_bien(ds_lp)||':loi'; return;
          if b_so_hdL='E' and b_kieu_hd<>'S' and instr(ds_nv_bh(ds_lp),'B')<>0 then
            if b_ttrang<>'D' then ds_gcn(ds_lp):=nvl(trim(ds_gcn(ds_lp)),' '); -- nam -- khi ttrang ='D' thi moi sinh so gcn cho ds xe moi
            else
              PBH_XE_VACH('XE',ds_gcn(ds_lp),b_loi);
              if b_loi is not null then return; end if;
            end if;
          else
              ds_gcn(ds_lp):=substr(to_char(ds_so_id(ds_lp)),3);
              if ds_kieu_gcn(ds_lp)<>'G' then
                  select count(*) into b_i1 from bh_xe_ds where ma_dvi=b_ma_dvi and so_id_dt=ds_so_id(ds_lp) and kieu_gcn=b_kieu_hd;
                  if(b_i1>0) then
                     select max(REGEXP_SUBSTR(gcn, 'B([0-9]+)', 1, 1, NULL, 1)) into b_i1 from bh_xe_ds where ma_dvi=b_ma_dvi and so_id_dt=ds_so_id(ds_lp) and kieu_gcn=b_kieu_hd;
                  end if;
                  ds_gcn(ds_lp):=ds_gcn(ds_lp)||'/'||b_kieu_hd||to_char(b_i1+1);
              end if;
          end if;
      elsif b_so_hdL='P' and b_ttrang='D' then
            PBH_LAY_SOAC(b_ma_dvi,ds_loai_ac(ds_lp),ds_mau_ac(ds_lp),ds_gcn(ds_lp),b_loi);
            if b_loi is not null then return; end if;
            if trim(ds_gcn(ds_lp)) is null then b_loi:='loi:Khong lay duoc so an chi:loi'; return; end if;
            if FBH_XE_SO_ID(b_ma_dvi,ds_gcn(ds_lp)) > 0 then b_loi:='loi:So an chi da su dung '||ds_gcn(ds_lp)||':loi'; return; end if;
            --PKH_JS_THAY(dt_ct,'gcn',ds_gcn(ds_lp));
      else 
         select nvl(max(ngay_cap),b_ngay_capH) into b_ngay_cap from bh_xe_ds where ma_dvi=b_ma_dvi and so_id_dt=ds_so_id(ds_lp) and gcn=ds_gcn(ds_lp);
      end if;
    end if;
    b_lenh:=FKH_JS_LENH('nv,ma,ten,tc,ma_ct,kieu,tien,pt,phi,thue,cap,ma_dk,ma_dkc,lh_nv,t_suat,ptb,phib,lkem,lkep,lkeb');
    EXECUTE IMMEDIATE b_lenh bulk collect into
        dk_nvX,dk_maX,dk_tenX,dk_tcX,dk_ma_ctX,dk_kieuX,dk_tienX,dk_ptX,dk_phiX,dk_thueX,dk_capX,
        dk_ma_dkX,dk_ma_dkCX,dk_lh_nvX,dk_t_suatX,dk_ptBX,dk_phiBX,dk_lkeMX,dk_lkePX,dk_lkeBX using a_ds_dk(ds_lp);
    for b_lp in 1..dk_maX.count loop
        b_kt:=b_kt+1;
        dk_bt(b_kt):=b_lp; dk_so_id(b_kt):=ds_so_id(ds_lp);
        -- chuclh - dieu khoan bo sung dk_kieu, dk_lh_bh
        dk_nv(b_kt):=dk_nvX(b_lp); dk_kieu(b_kt):=dk_kieuX(b_lp); dk_ma(b_kt):=dk_maX(b_lp); dk_ten(b_kt):=dk_tenX(b_lp);
        dk_tc(b_kt):=dk_tcX(b_lp); dk_ma_ct(b_kt):=dk_ma_ctX(b_lp); dk_tien(b_kt):=dk_tienX(b_lp);
        dk_pt(b_kt):=dk_ptX(b_lp); dk_phi(b_kt):=dk_phiX(b_lp); dk_thue(b_kt):=dk_thueX(b_lp);
        dk_cap(b_kt):=dk_capX(b_lp); dk_ma_dk(b_kt):=dk_ma_dkX(b_lp); dk_ma_dkC(b_kt):=dk_ma_dkCX(b_lp); dk_lh_nv(b_kt):=dk_lh_nvX(b_lp);
        dk_t_suat(b_kt):=dk_t_suatX(b_lp); dk_ptB(b_kt):=dk_ptBX(b_lp); dk_phiB(b_kt):=dk_phiBX(b_lp);
        dk_lkeM(b_kt):=dk_lkeMX(b_lp);
        dk_lkeP(b_kt):=dk_lkePX(b_lp); dk_lkeB(b_kt):=dk_lkeBX(b_lp); dk_lh_bh(b_kt):='C';
    end loop;
    b_ktG:=b_kt;
    if b_kt=0 then b_loi:='loi:Nhap dieu khoan xe '||a_bien(ds_lp)||':loi'; return; end if;
    if a_ds_dkbs(ds_lp) is not null then
      EXECUTE IMMEDIATE b_lenh bulk collect into
      dk_nvX,dk_maX,dk_tenX,dk_tcX,dk_ma_ctX,dk_kieuX,dk_tienX,dk_ptX,dk_phiX,dk_thueX,dk_capX,
      dk_ma_dkX,dk_ma_dkCX,dk_lh_nvX,dk_t_suatX,dk_ptBX,dk_phiBX,dk_lkeMX,dk_lkePX,dk_lkeBX using a_ds_dkbs(ds_lp);
      for b_lp in 1..dk_maX.count loop
          b_kt:=b_kt+1;
          dk_bt(b_kt):=b_lp+10000; dk_so_id(b_kt):=ds_so_id(ds_lp);
          -- chuclh - dieu khoan bo sung dk_kieu, dk_lh_bh
          dk_nv(b_kt):=dk_nvX(b_lp); dk_kieu(b_kt):=dk_kieuX(b_lp); dk_ma(b_kt):=dk_maX(b_lp); dk_ten(b_kt):=dk_tenX(b_lp);
          dk_tc(b_kt):=dk_tcX(b_lp); dk_ma_ct(b_kt):=dk_ma_ctX(b_lp); dk_tien(b_kt):=dk_tienX(b_lp);
          dk_pt(b_kt):=dk_ptX(b_lp); dk_phi(b_kt):=dk_phiX(b_lp); dk_thue(b_kt):=dk_thueX(b_lp);
          dk_cap(b_kt):=dk_capX(b_lp); dk_ma_dk(b_kt):=dk_ma_dkX(b_lp); dk_ma_dkC(b_kt):=dk_ma_dkCX(b_lp); dk_lh_nv(b_kt):=dk_lh_nvX(b_lp);
          dk_t_suat(b_kt):=dk_t_suatX(b_lp); dk_ptB(b_kt):=dk_ptBX(b_lp); dk_phiB(b_kt):=dk_phiBX(b_lp);
          -- viet anh -- thieu dk_lkeM
          dk_lkeM(b_kt):=dk_lkeMX(b_lp);
          dk_lkeP(b_kt):=dk_lkePX(b_lp); dk_lkeB(b_kt):=dk_lkeBX(b_lp); dk_lh_bh(b_kt):='M';
      end loop;
      for b_lp in 1..dk_maX.count loop
          b_ma_dk:=FBH_MA_DKBS_MA_DK(dk_ma_dkX(b_lp));
          if b_ma_dk<>' ' then
              b_i1:=FKH_ARR_VTRI(dk_ma_dk,b_ma_dk);
              if b_i1 not between 1 and b_ktG then
                  b_loi:='loi:Dieu khoan bo sung '||dk_ma_dkX(b_lp)||' phai gan kem dieu khoan chinh '||b_ma_dk||' - '||a_bien(ds_lp)||':loi'; return;
              end if;
          end if;
      end loop;
      if b_loi is not null then return; end if;
    end if;

    for b_lp in 1..dk_ma.count loop
        dk_nv(b_lp):=nvl(trim(dk_nv(b_lp)),' '); dk_ma(b_lp):=trim(dk_ma(b_lp));
        if dk_ma(b_lp) is null then b_loi:='loi:Loi nhap chi tiet nghiep vu xe '||a_bien(ds_lp)||':loi'; return; end if;
        dk_lh_nv(b_lp):=nvl(trim(dk_lh_nv(b_lp)),' '); dk_tien(b_lp):=nvl(dk_tien(b_lp),0);
        dk_phi(b_lp):=nvl(dk_phi(b_lp),0); dk_phiB(b_lp):=nvl(dk_phiB(b_lp),0);
        if b_c_thue='K' then dk_thue(b_lp):=0; else dk_thue(b_lp):=nvl(dk_thue(b_lp),0); end if;
        dk_ttoan(b_lp):=dk_phi(b_lp)+dk_thue(b_lp);
        if dk_tien(b_lp)<>0 then
          b_i1:=round(dk_phiB(b_lp)/dk_tien(b_lp)*100,4);
          dk_pt(b_lp):= b_i1 - round((dk_phiB(b_lp)-dk_phi(b_lp))/dk_tien(b_lp)*100 ,4);
        elsif dk_tien(b_lp)=0 and dk_nv(b_lp)='V' and dk_lh_bh(b_lp)='M' then -- viet anh -- them case tinh lai pt dkbs di theo dk chinh (vcx)
          b_i2:=FKH_ARR_VTRI(dk_ma_dk,dk_ma_dkC(b_lp));
          if b_i2 > 0 and dk_tien(b_i2)<>0 then
             b_i1:=round(dk_phiB(b_lp)/dk_tien(b_i2)*100,4);
             dk_pt(b_lp):= b_i1 - round((dk_phiB(b_lp)-dk_phi(b_lp))/dk_tien(b_i2)*100 ,4);
          end if;
        end if;
    end loop;
    --
    lt_so_id(ds_lp):=ds_so_id(ds_lp);
    if a_ds_dkbs(ds_lp) is null then
        lt_dk(ds_lp):=a_ds_dk(ds_lp);
    else
        b_i1:=length(a_ds_dk(ds_lp))-1;
        lt_dk(ds_lp):=substr(a_ds_dk(ds_lp),1,b_i1)||','||substr(a_ds_dkbs(ds_lp),2);
    end if;
    --lt_dk(ds_lp):=a_ds_dk(ds_lp);
    lt_lt(ds_lp):=a_ds_lt(ds_lp); lt_kbt(ds_lp):=a_ds_kbt(ds_lp);
    PKH_JS_THAYn(a_ds_ct(ds_lp),'so_id_dt',ds_so_id(ds_lp));
    b_cdt:=' ';
    if trim(ds_cdtC(ds_lp)) is null then
        b_cdt:=' ';
    else
        if ds_cdtC(ds_lp)='K' then PKH_GHEP(b_cdt,'C',''); end if;
        if ds_cdtF(ds_lp)='K' then PKH_GHEP(b_cdt,'F',''); end if;
        if ds_cdtX(ds_lp)='K' then PKH_GHEP(b_cdt,'X',''); end if;
        b_cdt:=nvl(trim(b_cdt),'K');
    end if;
    PKH_JS_THAYa(dt_ct,'gcn,gcn_g,cdt',ds_gcn(ds_lp)||'|'||ds_gcnG(ds_lp)||'|'||b_cdt,'|');
    -- viet anh -- update lai so gcn de luu vao txt
    PKH_JS_THAYa(a_ds_ct(ds_lp),'gcn,gcn_g,cdt',ds_gcn(ds_lp)||'|'||ds_gcnG(ds_lp)||'|'||b_cdt,'|');
end loop;
if b_kieu_hd in('B','S') and b_so_idG<>0 then
    for r_lp in (select so_id_dt,gcn from bh_xe_ds where ma_dvi=b_ma_dvi and so_id=b_so_idG) loop
        if FKH_ARR_VTRI_N(ds_so_id,r_lp.so_id_dt)=0 then b_loi:='loi:Khong xoa GCN cu '||r_lp.gcn||':loi'; return; end if;
    end loop;
end if;
if b_c_thue<>'C' then
    for b_lp in 1..dk_so_id.count loop dk_thue(b_lp):=0; end loop;
else
    for b_lp in 1..dk_so_id.count loop
        dk_thue(b_lp):=round(dk_phi(b_lp)*dk_t_suat(b_lp)/100, b_tp);
    end loop;
end if;
for b_lp in 1..dk_so_id.count loop
    dk_ttoan(b_lp):=dk_phi(b_lp)+dk_thue(b_lp);
end loop;
PBH_HD_THAY_PHIg(b_nt_tien,b_nt_tien,b_tygia,b_thueH,b_ttoanH,dk_lh_nv,dk_tien,dk_phi,dk_thue,dk_ttoan,b_loi);
if b_loi is not null then return; end if;
for b_lp in 1..dk_ma.count loop
    -- viet anh -- them dieu kien lkeM <> 'C,K' -- dieu chinh logic theo cong
    if dk_tien(b_lp)=0 and dk_lkeM(b_lp) not in('C','K') and b_ttrang in('T','D') then
        b_loi:='loi:Chua nhap muc trach nhiem '||dk_ma(b_lp)||':loi'; return;
    end if;
    if dk_phiB(b_lp)>dk_phi(b_lp) then
        dk_phiG(b_lp):=dk_phiB(b_lp)-dk_phi(b_lp);
        dk_ptG(b_lp):=round(dk_phiG(b_lp)*100/dk_phiB(b_lp),2);
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
end loop;
for b_lp in 1..ds_so_id.count loop
    ds_xe_id(b_lp):=FBH_XEtso_SO_ID(ds_bien_xe(b_lp),ds_so_khung(b_lp));
    if ds_xe_id(b_lp)<>0 then
        for r_lp in(select distinct nv_bh from bh_xe_ds where xe_id=ds_xe_id(b_lp) and so_id_dt<>ds_so_id(b_lp) and
            FKH_GIAO(ds_ngay_hl(b_lp),ds_ngay_kt(b_lp),ngay_hl,ngay_kt)='C' and FBH_XE_TTRANG(ma_dvi,so_id,'C')='D') loop
            b_nv_bhC:=r_lp.nv_bh; b_i1:=length(b_nv_bhC);
            for b_lp in 1..b_i1 loop
                if instr(ds_nv_bh(b_lp),substr(b_nv_bhC,b_lp,1))<>0 then
                    b_loi:='loi:Trung thoi gian bao hiem xe '||a_bien(b_lp)||':loi'; return;
                end if;
            end loop;
        end loop;
    else
        PHT_ID_MOI(ds_xe_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end if;
end loop;
if b_ttrang in('T','D') then
    for b_lp in 1..ds_so_id.count loop
        b_lenh:=FKH_JS_LENHc('loai_khh,tenh,dchih,cmth,mobih,emailh');
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
            if b_ma_khH not in(' ','VANGLAI') then PKH_JS_THAY(a_ds_ct(b_lp),'ma_khc',b_ma_khH); end if;
        end if;
    end loop;
end if;
for b_lp in 1..ds_so_id.count loop
    if ds_ktru(b_lp)<>0 then
        PBH_XEG_KBT(ds_nv_bh(b_lp),ds_so_idP(b_lp),ds_ktru(b_lp),a_ds_kbt(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end if;
    select json_object('ds_ct' value a_ds_ct(b_lp),'ds_dk' value a_ds_dk(b_lp),
        'ds_lt' value a_ds_lt(b_lp),'ds_kbt' value a_ds_kbt(b_lp),'ds_ttt' value a_ds_ttt(b_lp),
        'ds_dkbs' value a_ds_dkbs(b_lp) returning clob) into a_dsM(b_lp) from dual;
end loop;
dt_ds:=FKH_ARRo_JS(a_dsM);
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_XEH_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    dt_ct in out clob,dt_hu clob,dt_ds clob, dt_ds_txt clob,
-- Chung
    b_so_hd varchar2,b_ngay_ht number,b_ttrang varchar2,b_kieu_hd varchar2,b_so_hd_g varchar2,
    b_kieu_kt varchar2,b_ma_kt varchar2,b_kieu_gt varchar2,b_ma_gt varchar2,b_ma_cb varchar2,
    b_so_hdL varchar2,b_loai_kh varchar2,b_ma_kh varchar2,b_ten nvarchar2,b_dchi nvarchar2,
    b_cmt varchar2,b_mobi varchar2,b_email varchar2,
    b_gio_hl varchar2,b_ngay_hl number,b_gio_kt varchar2,b_ngay_kt number,b_ngay_cap number,
    b_nt_tien varchar2,b_nt_phi varchar2,b_c_thue varchar2,
    b_phi number,b_giam number,b_thue number,b_ttoan number,b_hhong number,
    b_so_idG number,b_so_idD number,b_ngayD number,b_phong varchar2,
    tt_ngay pht_type.a_num,tt_tien pht_type.a_num,
-- Rieng
    ds_so_id pht_type.a_num,ds_kieu_gcn pht_type.a_var,ds_gcn pht_type.a_var,ds_gcnG pht_type.a_var,
    ds_ma_sp pht_type.a_var,ds_cdich pht_type.a_var,ds_goi pht_type.a_var,
    ds_tenC pht_type.a_nvar,ds_cmtC pht_type.a_var,ds_mobiC pht_type.a_var,
    ds_emailC pht_type.a_var,ds_dchiC pht_type.a_nvar,ds_ng_huong pht_type.a_nvar,
    ds_bien_xe pht_type.a_var,ds_so_khung pht_type.a_var,ds_so_may pht_type.a_var,
    ds_hang pht_type.a_var,ds_hieu pht_type.a_var,ds_pban pht_type.a_var,
    ds_loai_xe pht_type.a_var,ds_nhom_xe pht_type.a_var,ds_dong pht_type.a_var,
    ds_dco pht_type.a_var,ds_ttai pht_type.a_num,ds_so_cn pht_type.a_num,
    ds_nam_sx pht_type.a_num,ds_gia pht_type.a_num,
    ds_md_sd pht_type.a_var,ds_nv_bh pht_type.a_var,ds_bh_tbo pht_type.a_var,
    ds_ngay_hl pht_type.a_num,ds_ngay_kt pht_type.a_num,
    ds_so_idP pht_type.a_var,ds_xe_id pht_type.a_num,
    ds_giam pht_type.a_num,ds_phi pht_type.a_num,
    ds_thue pht_type.a_num,ds_ttoan pht_type.a_num,

    dk_so_id pht_type.a_num,dk_bt pht_type.a_num,dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tc pht_type.a_var,
    dk_ma_ct pht_type.a_var,dk_kieu pht_type.a_var,dk_tien pht_type.a_num,dk_pt pht_type.a_num,
    dk_phi pht_type.a_num,dk_thue pht_type.a_num,dk_ttoan pht_type.a_num,
    dk_cap pht_type.a_num,dk_ma_dk pht_type.a_var,
    dk_lh_nv pht_type.a_var,dk_t_suat pht_type.a_num,
    dk_ptB pht_type.a_num,dk_phiB pht_type.a_num,
    dk_ptG pht_type.a_num,dk_phiG pht_type.a_num,
    dk_lkeP pht_type.a_var,dk_lkeB pht_type.a_var,dk_lh_bh pht_type.a_var,

    lt_so_id pht_type.a_num,lt_dk pht_type.a_clob,lt_lt pht_type.a_clob,lt_kbt pht_type.a_clob,b_loi out varchar2)
AS
    b_i1 number; b_so_dt number; b_so_id_kt number:=-1; b_tien number:=0; b_ma_ke varchar2(20); b_txt clob;
    dkT_ma pht_type.a_var; dkT_ten pht_type.a_nvar; dkT_tien pht_type.a_num; dkT_ptG pht_type.a_num;
begin
-- Dan - Nhap
b_loi:='loi:Loi nhap Table BH_XE:loi';
b_so_dt:=ds_so_id.count;
if b_ttrang='D' then b_so_id_kt:=0; end if;
for b_lp in 1..ds_so_id.count loop
    insert into bh_xe_ds values(b_ma_dvi,b_so_id,
        ds_so_id(b_lp),b_lp,ds_kieu_gcn(b_lp),ds_gcn(b_lp),ds_gcnG(b_lp),
        ds_tenC(b_lp),ds_cmtC(b_lp),ds_mobiC(b_lp),
        ds_emailC(b_lp),ds_dchiC(b_lp),ds_ng_huong(b_lp),
        ds_bien_xe(b_lp),ds_so_khung(b_lp),ds_so_may(b_lp),
        ds_hang(b_lp),ds_hieu(b_lp),ds_pban(b_lp),ds_loai_xe(b_lp),ds_nhom_xe(b_lp),
        ds_dong(b_lp),ds_dco(b_lp),ds_ttai(b_lp),ds_so_cn(b_lp),ds_nam_sx(b_lp),ds_gia(b_lp),
        ds_md_sd(b_lp),ds_nv_bh(b_lp),ds_bh_tbo(b_lp),ds_ma_sp(b_lp),ds_cdich(b_lp),ds_goi(b_lp),
        b_gio_hl,ds_ngay_hl(b_lp),b_gio_kt,ds_ngay_kt(b_lp),b_ngay_cap,
        ds_giam(b_lp),ds_phi(b_lp),ds_thue(b_lp),ds_ttoan(b_lp),ds_so_idP(b_lp),ds_xe_id(b_lp));
end loop;
for b_lp in 1..dk_so_id.count loop
    if dk_lh_nv(b_lp)<>' ' and dk_kieu(b_lp)='T' then b_tien:=b_tien+dk_tien(b_lp); end if;
    insert into bh_xe_dk values(b_ma_dvi,b_so_id,dk_so_id(b_lp),dk_bt(b_lp),dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),
        dk_ma_ct(b_lp),dk_kieu(b_lp),dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),dk_cap(b_lp),dk_ma_dk(b_lp),dk_lh_nv(b_lp),
        dk_t_suat(b_lp),dk_thue(b_lp),dk_ttoan(b_lp),dk_ptB(b_lp),
        dk_ptG(b_lp),dk_phiG(b_lp),dk_lkeP(b_lp),dk_lkeB(b_lp),dk_lh_bh(b_lp));
end loop;
insert into bh_xe values(
    b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,'H',b_ttrang,b_kieu_hd,b_so_hd_g,
    b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,b_phong,b_so_hdL,b_loai_kh,
    b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,
    b_nt_tien,b_nt_phi,b_c_thue,b_so_dt,b_tien,b_phi,b_giam,b_thue,b_ttoan,b_hhong,
    b_so_idG,b_so_idD,'','',b_so_id_kt,b_nsd,sysdate);
for b_lp in 1..ds_so_id.count loop
    delete bh_xe_ID where xe_id=ds_xe_id(b_lp);
    insert into bh_xe_ID values(ds_xe_id(b_lp),ds_tenC(b_lp),ds_cmtC(b_lp),ds_mobiC(b_lp),ds_emailC(b_lp),ds_dchiC(b_lp),
        ds_bien_xe(b_lp),ds_so_khung(b_lp),ds_so_may(b_lp),ds_hang(b_lp),ds_hieu(b_lp),ds_pban(b_lp),
        ds_loai_xe(b_lp),ds_nhom_xe(b_lp),ds_dong(b_lp),ds_dco(b_lp),ds_ttai(b_lp),ds_so_cn(b_lp),ds_nam_sx(b_lp),ds_gia(b_lp));
end loop;
for b_lp in 1..tt_ngay.count loop
    insert into bh_xe_tt values(b_ma_dvi,b_so_id,tt_ngay(b_lp),tt_tien(b_lp));
end loop;
PKH_JS_THAYa(dt_ct,'so_hd,ma_kh',b_so_hd||','||b_ma_kh);
insert into bh_xe_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
if trim(dt_hu) is not null then
    insert into bh_xe_txt values(b_ma_dvi,b_so_id,'dt_hu',dt_hu);
end if;
insert into bh_xe_txt values(b_ma_dvi,b_so_id,'dt_ds',dt_ds);
insert into bh_xe_txt values(b_ma_dvi,b_so_id,'dt_ds_txt',dt_ds_txt);
if b_ttrang in('T','D') then
    for b_lp in 1..lt_so_id.count loop
        insert into bh_xe_kbt values(b_ma_dvi,b_so_id,lt_so_id(b_lp),lt_dk(b_lp),lt_lt(b_lp),lt_kbt(b_lp));
    end loop;
    select json_object('ma_dvi' value b_ma_dvi,'nsd' value b_nsd,'so_id' value b_so_id,'so_hd' value b_so_hd,
        'kieu_hd' value b_kieu_hd,'nv' value 'XE','ngay_ht' value b_ngay_ht,'ngay_cap' value b_ngay_cap,
        'ngay_hl' value b_ngay_hl,'ngay_kt' value b_ngay_kt,'cb_ql' value b_ma_cb,'phong' value b_phong,
        'kieu_kt' value b_kieu_kt,'ma_kt' value b_ma_kt,'dly_tke' value ' ','hhong' value b_hhong,'pt_hhong' value 'D',
        'ma_kh' value b_ma_kh,'ten' value b_ten,'kieu_gt' value b_kieu_gt,'ma_gt' value b_ma_gt,
        'so_id_d' value b_so_idD,'so_id_g' value b_so_idG,'ttrang' value b_ttrang,
        'dvi_ksoat' value b_ma_dvi,'ksoat' value b_nsd,'bangg' value 'bh_xe',
    'c_thue' value b_c_thue,'nt_tien' value b_nt_tien,'nt_phi' value b_nt_phi,'tien' value b_tien,
    'phi' value b_ttoan-b_thue,'thue' value b_thue returning clob) into b_txt from dual;
    PBH_HD_GOC_NH(b_txt,b_loi);
    if b_loi is not null then return; end if;
end if;
if b_ttrang='D' then
    if b_so_hdL='P' then
        PBH_XE_DON(b_ma_dvi,b_so_id,'N',b_loi);
        if b_loi is not null then return; end if;
    end if;
    for b_lp in 1..ds_so_id.count loop
        PBH_KE_CTI_NHOM(b_ma_dvi,b_so_idD,ds_so_id(b_lp),b_ma_ke,b_loi);
        if b_loi is not null then return; end if;
        insert into bh_hd_goc_ttindt values(b_ma_dvi,b_so_idD,ds_xe_id(b_lp),'XE',
            ds_bien_xe(b_lp)||' -- '||ds_so_khung(b_lp),b_ma_kh,ds_ngay_kt(b_lp),' ',b_ma_ke);
    end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_XEH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(1000); b_lenh varchar2(2000); b_i1 number;
    dt_ct clob; dt_hu clob; dt_ds clob; dt_ds_txt clob; dt_kytt clob;
-- Chung
    b_so_id number; b_so_hd varchar2(20); b_ngay_ht number; b_ttrang varchar2(1); b_kieu_hd varchar2(1); b_so_hd_g varchar2(20);
    b_kieu_kt varchar2(1); b_ma_kt varchar2(20); b_kieu_gt varchar2(1); b_ma_gt varchar2(20); b_ma_cb varchar2(20);
    b_so_hdL varchar2(20); b_loai_kh varchar2(1); b_ma_kh varchar2(20); b_ten nvarchar2(500); b_dchi nvarchar2(500);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_gio_hl varchar2(20); b_ngay_hl number; b_gio_kt varchar2(20); b_ngay_kt number; b_ngay_cap number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_c_thue varchar2(1);
    b_tl_giam number; b_phi number; b_giam number; b_thue number; b_ttoan number; b_hhong number;
    b_so_idG number; b_so_idD number; b_ngayD number; b_phong varchar2(10);
    tt_ngay pht_type.a_num; tt_tien pht_type.a_num;
-- Rieng
    ds_so_id pht_type.a_num; ds_kieu_gcn pht_type.a_var; ds_loai_ac pht_type.a_var;ds_mau_ac pht_type.a_var;ds_gcn pht_type.a_var; ds_gcnG pht_type.a_var;
    ds_ma_sp pht_type.a_var; ds_cdich pht_type.a_var; ds_goi pht_type.a_var;
    ds_tenC pht_type.a_nvar; ds_cmtC pht_type.a_var; ds_mobiC pht_type.a_var;
    ds_emailC pht_type.a_var; ds_dchiC pht_type.a_nvar; ds_ng_huong pht_type.a_nvar;
    ds_bien_xe pht_type.a_var; ds_so_khung pht_type.a_var; ds_so_may pht_type.a_var;
    ds_hang pht_type.a_var; ds_hieu pht_type.a_var; ds_pban pht_type.a_var;
    ds_loai_xe pht_type.a_var; ds_nhom_xe pht_type.a_var; ds_dong pht_type.a_var;
    ds_dco pht_type.a_var; ds_ttai pht_type.a_num; ds_so_cn pht_type.a_num;
    ds_thang_sx pht_type.a_num; ds_nam_sx pht_type.a_num; ds_gia pht_type.a_num;
    ds_md_sd pht_type.a_var; ds_nv_bh pht_type.a_var; ds_bh_tbo pht_type.a_var;
    ds_ngay_hl pht_type.a_num; ds_ngay_kt pht_type.a_num; ds_ngay_cap pht_type.a_num;
    ds_so_idP pht_type.a_var; ds_xe_id pht_type.a_num;
    ds_giam pht_type.a_num; ds_phi pht_type.a_num;
    ds_thue pht_type.a_num; ds_ttoan pht_type.a_num;

    dk_so_id pht_type.a_num;dk_bt pht_type.a_num; dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var;
    dk_ma_ct pht_type.a_var; dk_kieu pht_type.a_var; dk_tien pht_type.a_num; dk_pt pht_type.a_num;
    dk_phi pht_type.a_num; dk_thue pht_type.a_num; dk_ttoan pht_type.a_num;
    dk_cap pht_type.a_num; dk_ma_dk pht_type.a_var; dk_ma_dkC pht_type.a_var; dk_nv pht_type.a_var;
    dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num;
    dk_ptB pht_type.a_num; dk_phiB pht_type.a_num;
    dk_ptG pht_type.a_num; dk_phiG pht_type.a_num;
    dk_lkeM pht_type.a_var;dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var; dk_lh_bh pht_type.a_var; -- viet anh -- them dk_lkeM

    lt_so_id pht_type.a_num; lt_dk pht_type.a_clob; lt_lt pht_type.a_clob; lt_kbt pht_type.a_clob;
-- Xu ly
    b_ngay_htC number;
begin
-- Dan - Nhap
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_hu,dt_ds,dt_kytt');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_hu,dt_ds,dt_kytt using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_hu); FKH_JSa_NULL(dt_kytt);
dt_ds_txt:=dt_ds;
if b_so_id<>0 then
    select count(*) into b_i1 from bh_xe where so_id=b_so_id;
    if b_i1<>0 then
        select ngay_ht,kieu_hd,ttrang into b_ngay_htC,b_kieu_hd,b_ttrang from bh_xe where so_id=b_so_id for update nowait;
        if sql%rowcount=0 then b_loi:='loi:Va cham NSD:loi'; raise PROGRAM_ERROR; end if;
        if b_ttrang not in('T','D') then b_kieu_hd:='X'; else b_kieu_hd:='N'; end if;
        PBH_XE_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_kieu_hd,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
else
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_HD_JS_TEST(
    b_ma_dvi,b_nsd,b_so_id,b_ngay_htC,'bh_xe',dt_ct,dt_kytt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_loai_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,
    b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_ngayD,b_phong,b_ma_cb,b_ma_kh,
    tt_ngay,tt_tien,b_loi,'XE');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_XEH_TESTr(
    b_ma_dvi,b_nsd,b_so_idG,
    dt_ct,dt_ds,b_so_hdL,b_ngay_cap,'H', -- viet anh - them b_bao_gia
    ds_so_id,ds_kieu_gcn,ds_loai_ac,ds_mau_ac,ds_gcn,ds_gcnG,ds_ma_sp,ds_cdich,ds_goi,
    ds_tenC,ds_cmtC,ds_mobiC,ds_emailC,ds_dchiC,ds_ng_huong,
    ds_bien_xe,ds_so_khung,ds_so_may,ds_hang,ds_hieu,ds_pban,
    ds_loai_xe,ds_nhom_xe,ds_dong,ds_dco,ds_ttai,ds_so_cn,ds_thang_sx,ds_nam_sx,ds_gia,
    ds_md_sd,ds_nv_bh,ds_bh_tbo,ds_ngay_hl,ds_ngay_kt,ds_ngay_cap,ds_so_idP,ds_xe_id,
    ds_giam,ds_phi,ds_thue,ds_ttoan,
    dk_so_id,dk_bt,dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,
    dk_cap,dk_ma_dk,dk_ma_dkC,dk_nv,dk_lh_nv,dk_t_suat,dk_ptB,dk_phiB,dk_ptG,dk_phiG,dk_lkeM,dk_lkeP,dk_lkeB,dk_lh_bh,
    lt_so_id,lt_dk,lt_lt,lt_kbt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_XEH_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,
    dt_ct,dt_hu,dt_ds,dt_ds_txt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,b_so_hdL,
    b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,
    b_so_idG,b_so_idD,b_ngayD,b_phong,
    tt_ngay,tt_tien,
    ds_so_id,ds_kieu_gcn,ds_gcn,ds_gcnG,ds_ma_sp,ds_cdich,ds_goi,
    ds_tenC,ds_cmtC,ds_mobiC,ds_emailC,ds_dchiC,ds_ng_huong,
    ds_bien_xe,ds_so_khung,ds_so_may,ds_hang,ds_hieu,ds_pban,
    ds_loai_xe,ds_nhom_xe,ds_dong,ds_dco,ds_ttai,ds_so_cn,ds_nam_sx,ds_gia,
    ds_md_sd,ds_nv_bh,ds_bh_tbo,ds_ngay_hl,ds_ngay_kt,ds_so_idP,ds_xe_id,ds_giam,ds_phi,ds_thue,ds_ttoan,
    dk_so_id,dk_bt,dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,
    dk_cap,dk_ma_dk,dk_lh_nv,dk_t_suat,dk_ptB,dk_phiB,dk_ptG,dk_phiG,dk_lkeP,dk_lkeB,dk_lh_bh,
    lt_so_id,lt_dk,lt_lt,lt_kbt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hd' value b_so_hd, 'ma_kh' value b_ma_kh) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
