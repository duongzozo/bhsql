create or replace procedure PBH_SKC_TESTr(
    b_ma_dvi varchar2,b_nsd varchar2,dt_ct in out clob,dt_dk clob,dt_dkbs clob,dt_lsb clob,dt_bkh clob,dt_hk clob,
    b_so_hd in out varchar2,b_so_hdL out varchar2,b_so_idP number,bkh_tenC pht_type.a_nvar,bkh_mucC pht_type.a_num,

    b_ng_sinhM out number,b_gioiM out varchar2,b_ngheM out varchar2,
    b_ten out nvarchar2,b_dchi out nvarchar2,b_cmt out varchar2,b_mobi out varchar2,b_email out varchar2,
    b_ng_sinh out number,b_gioi out varchar2,b_nghe out varchar2,b_ma_kh out varchar2,b_ng_huong out nvarchar2,
    b_ma_sp out varchar2,b_cdich out varchar2,b_goi out varchar2,b_tpa out varchar2,
    b_phiH out number, b_ttoanH out number,

    dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,dk_tc out pht_type.a_var,dk_ma_ct out pht_type.a_var,
    dk_kieu out pht_type.a_var,dk_tien out pht_type.a_num,dk_pt out pht_type.a_num,dk_phi out pht_type.a_num,
    dk_thue out pht_type.a_num,dk_ttoan out pht_type.a_num,
    dk_cap out pht_type.a_num,dk_ma_dk out pht_type.a_var,
    dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,dk_ptB out pht_type.a_num,
    dk_ptG out pht_type.a_num,dk_phiG out pht_type.a_num,
    dk_lkeP out pht_type.a_var,dk_lkeB out pht_type.a_var,dk_luy out pht_type.a_var,dk_lh_bh out pht_type.a_var,
    hk_nhom out pht_type.a_var,hk_ma out pht_type.a_var,hk_loai out pht_type.a_var,hk_ten out pht_type.a_nvar,hk_cmt out pht_type.a_var,
    hk_mobi out pht_type.a_var,hk_email out pht_type.a_var,hk_qhe out pht_type.a_var,hk_so_tk out pht_type.a_var,hk_ma_nh out pht_type.a_var,hk_ten_tk out pht_type.a_var,
    lsb_ma out pht_type.a_var,lsb_ten out pht_type.a_nvar,lsb_muc out pht_type.a_num,
    bkh_ten out pht_type.a_nvar,bkh_muc out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_loai_ac varchar2(10);b_mau_ac varchar2(20);b_ttrang varchar2(1); b_ngay_hl number; b_ngay_kt number;
    dt_khd clob; b_txt clob; b_lenh varchar2(2000); b_tien number:=0; b_loai_khM varchar2(1); b_kt number;
    dk_phiB pht_type.a_num; lsb_mucS pht_type.a_var; dk_lkeM pht_type.a_var; dkB_lkeM pht_type.a_var;

    dkB_ma pht_type.a_var; dkB_ten pht_type.a_nvar; dkB_tc pht_type.a_var; dkB_ma_ct pht_type.a_var;
    dkB_tien pht_type.a_num; dkB_pt pht_type.a_num; dkB_phi pht_type.a_num;
    dkB_thue pht_type.a_num; dkB_ttoan pht_type.a_num;

    dkB_cap pht_type.a_num; dkB_ma_dk pht_type.a_var; dkB_kieu pht_type.a_var;
    dkB_lh_nv pht_type.a_var; dkB_t_suat pht_type.a_num; dkB_ptB pht_type.a_num;
    dkB_ptG pht_type.a_num; dkB_phiG pht_type.a_num; dkB_phiB pht_type.a_num;
    dkB_lkeP pht_type.a_var; dkB_lkeB pht_type.a_var; dkB_luy pht_type.a_var; dkB_lh_bh pht_type.a_var;
begin
-- Dan - Nhap
b_lenh:=FKH_JS_LENH('loai_ac,mau_ac,ttrang,ngay_hl,b_ngay_kt,loai_kh,ng_sinh,gioi,nghe,tend,dchid,
    cmtd,mobid,emaild,ng_sinhd,gioid,nghed,ma_sp,cdich,goi,tpa,phi,ttoan,so_hdl');
EXECUTE IMMEDIATE b_lenh into b_loai_ac,b_mau_ac,b_ttrang,b_ngay_hl,b_ngay_kt,
    b_loai_khM,b_ng_sinhM,b_gioiM,b_ngheM,
    b_ten,b_dchi,b_cmt,b_mobi,b_email,b_ng_sinh,b_gioi,b_nghe,
    b_ma_sp,b_cdich,b_goi,b_tpa,b_phiH,b_ttoanH,b_so_hdL using dt_ct;
b_cdich:=PKH_MA_TENl(b_cdich); b_goi:=PKH_MA_TENl(b_goi);
if b_ttrang in ('T','D') then
    if trim(b_ma_sp) is null or FBH_SK_SP_HAN(b_ma_sp)<>'C' then b_loi:='loi:Sai ma san pham:loi'; return; end if;
    if b_cdich<>' ' and FBH_MA_CDICH_HAN(b_cdich)<>'C' then b_loi:='loi:Sai ma chien dich:loi'; return; end if;
    if b_goi<>' ' and FBH_SK_GOI_HAN(b_goi)<>'C' then b_loi:='loi:Sai ma goi:loi'; return; end if;
    b_tpa:=nvl(trim(b_tpa),' ');
    if b_tpa<>' ' and FBH_MA_GDINH_HAN(b_tpa)<>'C' then b_loi:='loi:Sai ma TPA:loi'; return; end if;
    if trim(b_ten) is not null then
        if b_ng_sinh is null then b_loi:='loi:Sai ngay sinh:loi'; return; end if;
        b_gioi:=nvl(trim(b_gioi),'M'); b_nghe:=nvl(trim(b_nghe),' ');
        if b_nghe<>' ' and FBH_MA_NGHE_HAN(b_nghe)<>'C' then b_loi:='loi:Sai ma nghe '||b_nghe||':loi'; return; end if;
    else
        if b_ng_sinhM is null then b_loi:='loi:Sai ngay sinh:loi'; return; end if;
        b_gioiM:=nvl(trim(b_gioi),'M'); b_ngheM:=nvl(trim(b_ngheM),' ');
        if b_ngheM<>' ' and FBH_MA_NGHE_HAN(b_ngheM)<>'C' then b_loi:='loi:Sai ma nghe '||b_ngheM||':loi'; end if;
    end if;
end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,kieu,tien,pt,phi,cap,ma_dk,lh_nv,t_suat,ptb,phib,lkem,lkep,lkeb,luy');
EXECUTE IMMEDIATE b_lenh bulk collect into
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_cap,
  dk_ma_dk,dk_lh_nv,dk_t_suat,dk_ptB,dk_phiB,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy using dt_dk;
b_kt:=dk_ma.count;
if b_kt=0 then b_loi:='loi:Nhap dieu khoan:loi'; return; end if;
for b_lp in 1..b_kt loop
    if b_tien<dk_tien(b_lp) then b_tien:=dk_tien(b_lp); end if;
    dk_lh_bh(b_lp):='C';
    if trim(dk_ma(b_lp)) is null then b_loi:='loi:Loi nhap chi tiet nghiep vu dong '||to_char(b_lp)||':loi'; return; end if;
end loop;
if trim(dt_dkbs) is not null then
    EXECUTE IMMEDIATE b_lenh bulk collect into
        dkB_ma,dkB_ten,dkB_tc,dkB_ma_ct,dkB_kieu,dkB_tien,dkB_pt,dkB_phi,dkB_cap,dkB_ma_dk,
        dkB_lh_nv,dkB_t_suat,dkB_ptB,dkB_phiB,dkB_lkeM,dkB_lkeP,dkB_lkeB,dkB_luy using dt_dkbs;
    for b_lp in 1..dkB_ma.count loop
        b_kt:=b_kt+1; dk_ma(b_kt):=nvl(trim(dkB_ma(b_lp)),' '); dk_lh_bh(b_kt):='M';
        if dk_ma(b_kt)=' ' then b_loi:='loi:Nhap dieu khoan mo rong dong '||to_char(b_lp)||':loi'; return; end if;
        dk_ten(b_kt):=dkB_ten(b_lp); dk_tc(b_kt):=dkB_tc(b_lp);
        dk_ma_ct(b_kt):=dkB_ma_ct(b_lp); dk_cap(b_kt):=dkB_cap(b_lp); dk_kieu(b_kt):=dkB_kieu(b_lp);
        dk_tien(b_kt):=dkB_tien(b_lp); dk_pt(b_kt):=dkB_pt(b_lp); dk_phi(b_kt):=dkB_phi(b_lp);
        dk_ma_dk(b_kt):=dkB_ma_dk(b_lp); dk_lh_nv(b_kt):=dkB_lh_nv(b_lp);
        dk_t_suat(b_kt):=dkB_t_suat(b_lp); dk_ptB(b_kt):=nvl(dkB_ptB(b_lp),0); dk_phiB(b_kt):=nvl(dkB_phiB(b_lp),0);
        dk_lkeM(b_kt):=dkB_lkeM(b_lp); dk_lkeP(b_kt):=dkB_lkeP(b_lp); dk_lkeB(b_kt):=dkB_lkeB(b_lp); dk_luy(b_kt):=dkB_luy(b_lp);
    end loop;
end if;
for b_lp in 1..b_kt loop
    dk_kieu(b_lp):=nvl(trim(dk_kieu(b_lp)),' ');dk_lh_nv(b_lp):=nvl(trim(dk_lh_nv(b_lp)),' '); dk_t_suat(b_lp):=0;
    dk_thue(b_lp):=0; dk_phiB(b_lp):=nvl(dk_phiB(b_lp),0);
    if dk_tien(b_lp)=0 and dk_lkeM(b_lp) not in ('T','N','K','B') and dk_kieu(b_lp)='T' then 
      b_loi:='loi:Chua nhap muc trach nhiem dieu khoan '||dk_ma(b_lp)||':loi'; return; 
    end if;
    if dk_tien(b_lp)<>0 then
      b_i1:=round(dk_phiB(b_lp)/dk_tien(b_lp)*100,4); 
      dk_pt(b_lp):= b_i1 - round(((dk_phiB(b_lp)/dk_tien(b_lp))-(dk_phi(b_lp)/dk_tien(b_lp)))*100 ,4);
    elsif dk_lkeP(b_lp)='I' and dk_tien(b_lp)=0 then
      dk_pt(b_lp):=dk_ptB(b_lp);
    end if;
end loop;
PBH_HD_THAY_PHIg('VND','VND',1,0,b_ttoanH,dk_lh_nv,dk_tien,dk_phi,dk_thue,dk_ttoan,b_loi);
if b_loi is not null then return; end if;
for b_lp in 1..dk_ma.count loop
    if dk_phiB(b_lp)>dk_phi(b_lp) and dk_tien(b_lp) > 0 and dk_lh_nv(b_lp)<> ' ' then
        dk_phiG(b_lp):=dk_phiB(b_lp)-dk_phi(b_lp);
        dk_ptG(b_lp):=round(dk_phiG(b_lp)*100/dk_phiB(b_lp),2);
    else
        dk_ptG(b_lp):=0; dk_phiG(b_lp):=0;
    end if;
end loop;
b_lenh:=FKH_JS_LENH('ma,ten,muc');
EXECUTE IMMEDIATE b_lenh bulk collect into lsb_ma,lsb_ten,lsb_mucS using dt_lsb;
for b_lp in 1..lsb_ma.count loop
    lsb_muc(b_lp):=PKH_LOC_CHU_SO(lsb_mucS(b_lp),'F','F');
end loop;
b_lenh:=FKH_JS_LENH('ten');
EXECUTE IMMEDIATE b_lenh bulk collect into bkh_ten using dt_bkh;
for b_lp in 1..bkh_ten.count loop
    bkh_muc(b_lp):=6;
end loop;
if bkh_ten.count<>0 and bkh_tenC.count<>0 then
    for b_lp in 1..bkh_ten.count loop
        b_i1:=FKH_ARR_VTRIu(bkh_tenC,bkh_ten(b_lp));
        if b_i1>0 then bkh_muc(b_lp):=bkh_mucC(b_i1); end if;
    end loop;
end if;
if b_ttrang in ('T','D') then
    b_i1:=0;
    for b_lp in 1..lsb_muc.count loop
        b_i1:=b_i1+lsb_muc(b_lp);
    end loop;
    for b_lp in 1..bkh_ten.count loop
        --if bkh_muc(b_lp)=6 then b_loi:='loi:Cho danh gia benh '||bkh_ten(b_lp)||':loi'; return; end if;
        b_i1:=b_i1+bkh_muc(b_lp);
    end loop;
    --if b_i1>4 then b_loi:='loi:Tu choi cap GCN do nhieu benh:loi'; return; end if;
end if;

if b_so_hdL='P' and b_ttrang='D' then
    PBH_LAY_SOAC(b_ma_dvi,b_loai_ac,b_mau_ac,b_so_hd,b_loi);
    if b_loi is not null then return; end if;
    if trim(b_so_hd) is null then b_loi:='loi:Khong lay duoc so an chi:loi'; return; end if;
    if FBH_SK_SO_ID(b_ma_dvi,b_so_hd) > 0 then b_loi:='loi:So an chi da su dung '||b_so_hd||':loi'; return; end if;
    PKH_JS_THAY(dt_ct,'gcn',b_so_hd);
end if;
b_ng_huong:='';
if b_ttrang not in('T','D') then
    b_ma_kh:=' ';
else
    select json_object('loai' value 'C','ten' value b_ten,'cmt' value b_cmt,
        'dchi' value b_dchi,'mobi' value b_mobi,'email' value b_email,
        'gioi' value b_gioi,'ng_sinh' value b_ng_sinh) into b_txt from dual;
    PBH_DTAC_MA_NH(b_txt,b_ma_kh,b_loi,b_ma_dvi,b_nsd);
    if b_loai_khM='T' and b_ma_kh in(' ','VANGLAI') then
        b_loi:='loi:Thieu thong tin nguoi duoc bao hiem:loi'; return;
    end if;
    if b_ma_kh in(' ','VANGLAI') then b_i1:=b_ng_sinhM; else b_i1:=b_ng_sinh; end if; -- chuclh khong nhap nguoi mua. ma=VL
    if b_so_idP<>FBH_SK_BPHI_SO_IDh('C',b_ma_sp,b_cdich,b_goi,b_i1,0,b_ngay_hl) then
         b_loi:='loi:Sai bieu phi:loi'; return;
    end if;
    b_lenh:=FKH_JS_LENH('nhom,ma,loai,ten,cmt,mobi,email,qhe,so_tk,ma_nh,ten_tk');
    EXECUTE IMMEDIATE b_lenh bulk collect into hk_nhom,hk_ma,hk_loai,hk_ten,hk_cmt,hk_mobi,hk_email,hk_qhe,hk_so_tk,hk_ma_nh,hk_ten_tk using dt_hk;
    for b_lp in 1..hk_ten.count loop
        if trim(hk_ten(b_lp)) is not null then
          select json_object('loai' value hk_loai(b_lp),'ten' value hk_ten(b_lp),'cmt' value hk_cmt(b_lp),
              'mobi' value hk_mobi(b_lp),'email' value hk_email(b_lp)) into b_txt from dual;
          PBH_DTAC_MA_NH(b_txt,hk_ma(b_lp),b_loi,b_ma_dvi,b_nsd);
          b_ng_huong:=hk_ten(b_lp);
          if trim(hk_cmt(b_lp)) is not null then
              if hk_loai(b_lp)='C' then
                  b_ng_huong:=hk_ten(b_lp)||', so CMT/CCCD: '||hk_cmt(b_lp);
              else
                  b_ng_huong:=hk_ten(b_lp)||', ma thue/so GPTL : '||hk_cmt(b_lp);
              end if;
          end if;
          --if trim(b_dchiH) is not null then
          --    b_ng_huong:=hk_ten(b_lp)||', dia chi: '||b_dchiH;
          --end if;
      end if;
    end loop;

    select count(*) into b_i1 from bh_sk_phi_txt where so_id=b_so_idP and loai='dt_khd';
    if b_i1<>0 then
        select txt into dt_khd from bh_sk_phi_txt where so_id=b_so_idP and loai='dt_khd';
        b_i1:=length(dt_khd)-2;
        dt_khd:=substr(dt_khd,2,b_i1);
        PBH_SK_KHD(dt_ct,dt_khd,b_loi);
        if b_loi is not null then return; end if;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_SKC_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    dt_ct in out clob,dt_dk clob,dt_dkbs clob,dt_lsb clob,dt_bkh clob,dt_ttt clob,dt_hk clob,dt_lt clob,
    b_so_hd varchar2,b_ngay_ht number,b_ttrang varchar2,b_kieu_hd varchar2,b_so_hd_g varchar2,
    b_kieu_kt varchar2,b_ma_kt varchar2,b_kieu_gt varchar2,b_ma_gt varchar2,b_ma_cb varchar2,
    b_so_hdL varchar2,b_loai_kh varchar2,b_ma_kh varchar2,b_ten nvarchar2,b_dchi nvarchar2,
    b_cmt varchar2,b_mobi varchar2,b_email varchar2,
    b_gio_hl varchar2,b_ngay_hl number,b_gio_kt varchar2,b_ngay_kt number,b_ngay_cap number,
    b_nt_tien varchar2,b_nt_phi varchar2,b_c_thue varchar2,
    b_phi number,b_giam number,b_thue number,b_ttoan number,b_hhong number,
    b_so_idG number,b_so_idD number,b_ngayD number,b_phong varchar2,
    tt_ngay pht_type.a_num,tt_tien pht_type.a_num,

    b_ng_sinh number,b_gioi varchar2,b_nghe varchar2,
    b_tenD nvarchar2,b_dchiD nvarchar2,b_cmtD varchar2,b_mobiD varchar2,b_emailD varchar2,
    b_ng_sinhD number,b_gioiD varchar2,b_ngheD varchar2,b_ma_khD varchar2,b_ng_huong nvarchar2,
    b_ma_sp varchar2,b_cdich varchar2,b_goi varchar2,b_so_idP number,b_tpa varchar2,

    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tc pht_type.a_var,dk_ma_ct pht_type.a_var,
    dk_kieu pht_type.a_var,dk_tien pht_type.a_num,dk_pt pht_type.a_num,dk_phi pht_type.a_num,
    dk_thue pht_type.a_num,dk_ttoan pht_type.a_num,dk_cap pht_type.a_num,dk_ma_dk pht_type.a_var,
    dk_lh_nv pht_type.a_var,dk_t_suat pht_type.a_num,dk_ptB pht_type.a_num,dk_ptG pht_type.a_num,dk_phiG pht_type.a_num,
    dk_lkeP pht_type.a_var,dk_lkeB pht_type.a_var,dk_luy pht_type.a_var,dk_lh_bh pht_type.a_var,

    lsb_ma pht_type.a_var,lsb_ten pht_type.a_nvar,lsb_muc pht_type.a_num,
    bkh_ten pht_type.a_nvar,bkh_muc pht_type.a_num,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_i1 number; b_ps varchar2(1); b_so_id_kt number:=-1; b_tien number:=0;
    dt_khd clob; dt_kbt clob; dt_cho clob; dt_bvi clob; b_ma_ke varchar2(20):=' '; b_txt clob;
begin
-- Dan - Nhap
b_loi:='loi:Loi Table BH_SK:loi';
if b_ttrang='D' then b_so_id_kt:=0; end if;
if b_ma_khD in(' ','VANGLAI') then
    insert into bh_sk_ds values(b_ma_dvi,b_so_id,b_so_id,0,b_kieu_hd,b_so_hd,b_so_hd_g,
        b_ten,0,b_ng_sinh,b_gioi,b_cmt,b_mobi,b_email,b_dchi,b_nghe,
        b_ng_huong,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_goi,b_so_idP,' ',b_phi,b_giam,b_ttoan,' ',b_ma_kh);
else
    insert into bh_sk_ds values(b_ma_dvi,b_so_id,b_so_id,0,b_kieu_hd,b_so_hd,b_so_hd_g,
        b_tenD,0,b_ng_sinhD,b_gioiD,b_cmtD,b_mobiD,b_emailD,b_dchiD,b_ngheD,
        b_ng_huong,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_goi,b_so_idP,' ',b_phi,b_giam,b_ttoan,' ',b_ma_khD);
end if;
for b_lp in 1..dk_lh_nv.count loop
    if dk_lh_nv(b_lp)<>' ' and dk_kieu(b_lp)='T' then b_tien:=b_tien+dk_tien(b_lp); end if;
    insert into bh_sk_dk values(b_ma_dvi,b_so_id,b_so_id,b_lp,
        dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),dk_kieu(b_lp),
        dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),dk_cap(b_lp),dk_ma_dk(b_lp),
        dk_lh_nv(b_lp),dk_t_suat(b_lp),dk_thue(b_lp),dk_ttoan(b_lp),
        dk_ptB(b_lp),dk_ptG(b_lp),dk_phiG(b_lp),dk_lkeP(b_lp),dk_lkeB(b_lp),dk_luy(b_lp),dk_lh_bh(b_lp));
end loop;
insert into bh_sk values(
    b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,'C',b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
    b_phong,b_so_hdL,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,
    b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,b_ma_sp,b_cdich,b_tpa,'K',1,'C',b_tien,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,'','',b_so_id_kt,b_nsd,sysdate);
PKH_JS_THAYa(dt_ct,'so_hd,ma_kh',b_so_hd||','||b_ma_kh);
if trim(b_ma_khD) is not null then PKH_JS_THAY(dt_ct,'ma_khD',b_ma_khD); end if;
insert into bh_sk_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
insert into bh_sk_txt values(b_ma_dvi,b_so_id,'dt_dk',dt_dk);
if trim(dt_dkbs) is not null then
    insert into bh_sk_txt values(b_ma_dvi,b_so_id,'dt_dkbs',dt_dkbs);
end if;
if trim(dt_lsb) is not null then
    for b_lp in 1..lsb_ma.count loop
        insert into bh_sk_lsb values(b_ma_dvi,b_so_id,b_so_id,b_lp,lsb_ma(b_lp),lsb_ten(b_lp),lsb_muc(b_lp));
    end loop;
end if;
if trim(dt_bkh) is not null then
    for b_lp in 1..bkh_ten.count loop
        insert into bh_sk_bkh values(b_ma_dvi,b_so_id,b_so_id,b_lp,bkh_ten(b_lp),bkh_muc(b_lp));
    end loop;
    insert into bh_sk_txt values(b_ma_dvi,b_so_id,'dt_bkh',dt_bkh);
end if;
if trim(dt_ttt) is not null then
    insert into bh_sk_txt values(b_ma_dvi,b_so_id,'dt_ttt',dt_ttt);
end if;
for b_lp in 1..tt_ngay.count loop
    insert into bh_sk_tt values(b_ma_dvi,b_so_id,tt_ngay(b_lp),tt_tien(b_lp));
end loop;
PBH_SK_BPHI_CTk(b_so_idP,dt_khd,dt_kbt,dt_cho,dt_bvi);
if trim(dt_hk) is not null then
    insert into bh_sk_kbt values(b_ma_dvi,b_so_id,b_so_id,'dt_hk',dt_hk);
end if;
if trim(dt_khd) is not null then
    insert into bh_sk_kbt values(b_ma_dvi,b_so_id,b_so_id,'dt_khd',dt_khd);
end if;
if trim(dt_kbt) is not null then
    insert into bh_sk_kbt values(b_ma_dvi,b_so_id,b_so_id,'dt_kbt',dt_kbt);
end if;
if trim(dt_cho) is not null then
    insert into bh_sk_kbt values(b_ma_dvi,b_so_id,b_so_id,'dt_cho',dt_cho);
end if;
if trim(dt_bvi) is not null then
    insert into bh_sk_kbt values(b_ma_dvi,b_so_id,b_so_id,'dt_bvi',dt_bvi);
end if;
-- Di tiep
if b_ttrang in('T','D') then
    insert into bh_ng_kbt values(b_ma_dvi,b_so_id,b_so_id,dt_dk,dt_lt,dt_kbt);
    insert into bh_sk_kbt values(b_ma_dvi,b_so_id,b_so_id,'dt_dk',dt_dk);
    if trim(dt_lt) is not null then
        insert into bh_sk_kbt values(b_ma_dvi,b_so_id,b_so_id,'dt_lt',dt_lt);
    end if;
    insert into bh_ng values(
        b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,'SKC',b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
        b_phong,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,
        b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,'K',1,b_tien,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,0,'','',b_nsd);
    for b_lp in 1..tt_ngay.count loop
        insert into bh_ng_tt values(b_ma_dvi,b_so_id,tt_ngay(b_lp),tt_tien(b_lp));
    end loop;
    for b_lp in 1..dk_lh_nv.count loop
        insert into bh_ng_dk values(b_ma_dvi,b_so_id,b_so_id,b_lp,
            dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),dk_kieu(b_lp),dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),
            dk_cap(b_lp),dk_ma_dk(b_lp),dk_lh_nv(b_lp),dk_t_suat(b_lp),dk_thue(b_lp),dk_ttoan(b_lp),
            dk_ptB(b_lp),dk_ptG(b_lp),dk_phiG(b_lp),dk_lkeP(b_lp),dk_lkeB(b_lp),dk_luy(b_lp),dk_lh_bh(b_lp));
    end loop;
    if b_ma_khD in(' ','VANGLAI') then
        insert into bh_ng_ds values(b_ma_dvi,b_so_id,b_so_id,b_kieu_hd,b_so_hd,b_so_hd_g,
            b_ten,b_ng_sinh,b_gioi,b_cmt,b_mobi,b_email,b_dchi,b_nghe,
            b_ng_huong,b_ma_sp,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_so_idP,b_phi,b_giam,b_ttoan,' ',b_ma_kh);
    else
        insert into bh_ng_ds values(b_ma_dvi,b_so_id,b_so_id,b_kieu_hd,b_so_hd,b_so_hd_g,
            b_tenD,b_ng_sinhD,b_gioiD,b_cmtD,b_mobiD,b_emailD,b_dchiD,b_ngheD,
            b_ng_huong,b_ma_sp,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_so_idP,b_phi,b_giam,b_ttoan,' ',b_ma_khD);
    end if;
    insert into bh_ng_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
    PBH_NG_GOC_NH(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
end if;
-- CNGA AN CHI
if b_ttrang='D' then
    if b_so_hdL='P' then
        PBH_SK_DON(b_ma_dvi,b_so_id,'N',b_loi);
        if b_loi is not null then return; end if;
    end if;
    PBH_KE_CTI_NHOM(b_ma_dvi,b_so_idD,b_so_idD,b_ma_ke,b_loi);
    if b_loi is not null then return; end if;
    insert into bh_hd_goc_ttindt values(b_ma_dvi,b_so_idD,b_so_idD,'NG',b_ten,b_ma_kh,b_ngay_kt,' ',b_ma_ke);
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_SKC_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_i1 number;
    dt_ct clob; dt_dk clob; dt_lsb clob; dt_bkh clob; dt_dkbs clob; dt_ttt clob;
    dt_kytt clob; dt_hk clob; dt_lt clob; dt_cho clob; dt_bvi clob;
-- Ra chung
    b_so_id number; b_so_hd varchar2(20); b_ngay_ht number; b_ttrang varchar2(1); b_kieu_hd varchar2(1); b_so_hd_g varchar2(20);
    b_kieu_kt varchar2(1); b_ma_kt varchar2(20); b_kieu_gt varchar2(1); b_ma_gt varchar2(20); b_ma_cb varchar2(20);
    b_so_hdL varchar2(20); b_loai_kh varchar2(1); b_ma_kh varchar2(20); b_ten nvarchar2(500); b_dchi nvarchar2(500);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_gio_hl varchar2(20); b_ngay_hl number; b_gio_kt varchar2(20); b_ngay_kt number; b_ngay_cap number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_c_thue varchar2(1);
    b_tl_giam number; b_phi number; b_giam number; b_thue number; b_ttoan number; b_hhong number;
    b_so_idG number; b_so_idD number; b_ngayD number; b_phong varchar2(10);
    tt_ngay pht_type.a_num; tt_tien pht_type.a_num;
-- Ra rieng
    b_ng_sinh number; b_gioi varchar2(1); b_nghe varchar2(10);
    b_tenD nvarchar2(50); b_dchiD nvarchar2(500); b_cmtD varchar2(20); b_mobiD varchar2(20); b_emailD varchar2(100);
    b_ng_sinhD number; b_gioiD varchar2(1); b_ngheD varchar2(10); b_ma_khD varchar2(20); b_ng_huong nvarchar2(500);
    b_ma_sp varchar2(10); b_cdich varchar2(200); b_goi varchar2(200); b_tpa varchar2(20);

    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var; dk_ma_ct pht_type.a_var;
    dk_kieu pht_type.a_var; dk_tien pht_type.a_num; dk_pt pht_type.a_num; dk_phi pht_type.a_num;
    dk_thue pht_type.a_num; dk_ttoan pht_type.a_num;
    dk_cap pht_type.a_num; dk_ma_dk pht_type.a_var; dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num;
    dk_ptB pht_type.a_num; dk_ptG pht_type.a_num; dk_phiG pht_type.a_num;
    dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var; dk_luy pht_type.a_var; dk_lh_bh pht_type.a_var;
    hk_nhom pht_type.a_var;hk_ma pht_type.a_var;hk_loai pht_type.a_var;hk_ten pht_type.a_nvar;hk_cmt pht_type.a_var;
    hk_mobi pht_type.a_var;hk_email pht_type.a_var;hk_qhe pht_type.a_var;hk_so_tk pht_type.a_var;hk_ma_nh pht_type.a_var;hk_ten_tk pht_type.a_var;
    lsb_ma pht_type.a_var; lsb_ten pht_type.a_nvar; lsb_muc pht_type.a_num;
    bkh_ten pht_type.a_nvar; bkh_muc pht_type.a_num;
-- xu ly
    b_ngay_htC number; b_so_idP number;
    bkh_tenC pht_type.a_nvar; bkh_mucC pht_type.a_num;
begin
-- Dan - Nhap
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_lenh:=FKH_JS_LENH('so_id,so_idP');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_so_idP using b_oraIn;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_dkbs,dt_lsb,dt_bkh,dt_ttt,dt_kytt,dt_hk,dt_lt,dt_cho,dt_bvi');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_dkbs,dt_lsb,dt_bkh,dt_ttt,dt_kytt,dt_hk,dt_lt,dt_cho,dt_bvi using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_dkbs); FKH_JSa_NULL(dt_lsb);
FKH_JSa_NULL(dt_bkh); FKH_JSa_NULL(dt_ttt); FKH_JSa_NULL(dt_kytt); FKH_JSa_NULL(dt_hk);
FKH_JSa_NULL(dt_lt); FKH_JSa_NULL(dt_cho); FKH_JSa_NULL(dt_bvi);
if b_so_id<>0 then
    select count(*) into b_i1 from bh_sk where so_id=b_so_id;
    if b_i1<>0 then
        select ngay_ht,kieu_hd,ttrang into b_ngay_htC,b_kieu_hd,b_ttrang from bh_sk
            where so_id=b_so_id for update nowait;
        if sql%rowcount=0 then b_loi:='loi:Va cham NSD:loi'; raise PROGRAM_ERROR; end if;
        select ten,muc bulk collect into bkh_tenC,bkh_mucC from bh_sk_bkh where ma_dvi=b_ma_dvi and so_id=b_so_id and muc<>6;
        if b_ttrang not in('T','D') then b_kieu_hd:='X'; else b_kieu_hd:='N'; end if;
        PBH_SK_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_kieu_hd,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
else
    PKH_MANG_KD_U(bkh_tenC); PKH_MANG_KD_N(bkh_mucC);
    PHT_ID_MOI(b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_HD_JS_TEST(
    b_ma_dvi,b_nsd,b_so_id,b_ngay_htC,'bh_sk',dt_ct,dt_kytt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_loai_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,
    b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_ngayD,b_phong,b_ma_cb,b_ma_kh,
    tt_ngay,tt_tien,b_loi,'NG');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_SKC_TESTr(
    b_ma_dvi,b_nsd,dt_ct,dt_dk,dt_dkbs,dt_lsb,dt_bkh,dt_hk,
    b_so_hd,b_so_hdL,b_so_idP,bkh_tenC,bkh_mucC,
    b_ng_sinh,b_gioi,b_nghe,b_tenD,b_dchiD,b_cmtD,b_mobiD,b_emailD,b_ng_sinhD,b_gioiD,
    b_ngheD,b_ma_khD,b_ng_huong,b_ma_sp,b_cdich,b_goi,b_tpa,b_phi,b_ttoan,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,
    dk_cap,dk_ma_dk,dk_lh_nv,dk_t_suat,dk_ptB,dk_ptG,dk_phiG,
    dk_lkeP,dk_lkeB,dk_luy,dk_lh_bh,
    hk_nhom,hk_ma,hk_loai,hk_ten,hk_cmt,
    hk_mobi,hk_email,hk_qhe,hk_so_tk,hk_ma_nh,hk_ten_tk,
    lsb_ma,lsb_ten,lsb_muc,bkh_ten,bkh_muc,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_SKC_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,
    dt_ct,dt_dk,dt_dkbs,dt_lsb,dt_bkh,dt_ttt,dt_hk,dt_lt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
    b_so_hdL,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,
    b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_ngayD,b_phong,
    tt_ngay,tt_tien,
    b_ng_sinh,b_gioi,b_nghe,b_tenD,b_dchiD,b_cmtD,b_mobiD,b_emailD,
    b_ng_sinhD,b_gioiD,b_ngheD,b_ma_khD,b_ng_huong,b_ma_sp,b_cdich,b_goi,b_so_idP,b_tpa,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,
    dk_cap,dk_ma_dk,dk_lh_nv,dk_t_suat,dk_ptB,dk_ptG,dk_phiG,
    dk_lkeP,dk_lkeB,dk_luy,dk_lh_bh,
    lsb_ma,lsb_ten,lsb_muc,bkh_ten,bkh_muc,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hd' value b_so_hd, 'ma_kh' value b_ma_kh) into b_oraOut from dual;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SKC_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_ngay number:=PKH_NG_CSO(sysdate);
    cs_sp clob; cs_cdich clob; cs_goi clob; cs_tpa clob;
    cs_khd clob; cs_kbt clob; cs_tltg clob; cs_ttt clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten) into cs_sp from
    bh_sk_sp a,(select distinct ma_sp from bh_sk_phi where nhom='C' and ngay_bd<=b_ngay and ngay_kt>b_ngay) b
    where a.ma=b.ma_sp and FBH_SK_SP_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten returning clob) into cs_cdich from
    bh_ma_cdich a,(select distinct cdich from bh_sk_phi where nhom='C' and ngay_bd<=b_ngay and ngay_kt>b_ngay) b
    where a.ma=b.cdich and FBH_MA_NV_CO(a.nv,'NG')='C' and FBH_MA_CDICH_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ma) into cs_goi from
    bh_sk_goi a,(select distinct goi from bh_sk_phi where nhom='C' and ngay_bd<=b_ngay and ngay_kt>b_ngay) b
    where a.ma=b.goi and FBH_SK_GOI_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(ma,ten) order by ten returning clob) into cs_tpa from
    bh_ma_gdinh where FBH_MA_GDINH_NV(ma,'NG')='C' and FBH_MA_GDINH_HAN(ma)='C';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_khd from bh_kh_ttt where ps='KHD' and FBH_MA_NV_CO(nv,'NG')='C';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_kbt from bh_kh_ttt where ps='KBT' and FBH_MA_NV_CO(nv,'NG')='C';
select JSON_ARRAYAGG(json_object(tltg,tlph) order by tltg returning clob) into cs_tltg
    from bh_sk_tltg where b_ngay between ngay_bd and ngay_kt;
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_ttt
    from bh_kh_ttt where ps='HD' and nv='NG';
select json_object('cs_sp' value cs_sp,'cs_cdich' value cs_cdich,'cs_goi' value cs_goi,
    'cs_tpa' value cs_tpa,'cs_khd' value cs_khd,'cs_kbt' value cs_kbt,
    'cs_tltg' value cs_tltg,'cs_ttt' value cs_ttt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SKC_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number; b_so_idP number;
    dt_ct clob; dt_dk clob; dt_dkbs clob; dt_lsb clob; dt_bkh clob;
    dt_ttt clob; dt_kytt clob; dt_hk clob; dt_lt clob:=''; dt_khd clob:='';
    dt_kbt clob:=''; dt_cho clob:=''; dt_bvi clob:=''; dt_txt clob;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
if b_so_id=0 then b_loi:='loi:GCN:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
b_so_idP:=FBH_SK_SO_IDp(b_ma_dvi,b_so_id,b_so_id);
select json_object(so_hd,ma_kh,'tpa' value FBH_DTAC_MA_TENl(tpa)) into dt_ct 
       from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ma,ten) order by bt returning clob) into dt_dk
    from bh_sk_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_bh<>'M';
select JSON_ARRAYAGG(json_object(ma,ten) order by bt returning clob) into dt_dkbs
    from bh_sk_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_bh='M';
select JSON_ARRAYAGG(json_object(ma,ten,muc) order by bt) into dt_lsb from bh_sk_lsb where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ten,muc) order by bt) into dt_bkh from bh_sk_bkh where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ngay,tien) order by ngay) into dt_kytt from bh_sk_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select count(*) into b_i1 from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
if b_i1<>0 then
    select txt into dt_ttt from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
end if;
select count(*) into b_i1 from bh_sk_phi_txt where so_id=b_so_idP and loai='dt_lt';
if b_i1=1 then
    select txt into dt_lt from bh_sk_phi_txt where so_id=b_so_idP and loai='dt_lt';
end if;
select count(*) into b_i1 from bh_sk_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_khd';
if b_i1<>0 then
    select txt into dt_khd from bh_sk_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_khd';
end if;
select count(*) into b_i1 from bh_sk_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_kbt';
if b_i1<>0 then
    select txt into dt_kbt from bh_sk_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_kbt';
end if;
select count(*) into b_i1 from bh_sk_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
if b_i1<>0 then
    select txt into dt_hk from bh_sk_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
end if;
select count(*) into b_i1 from bh_sk_kbt where so_id=b_so_id and loai='dt_cho';
if b_i1=1 then
    select txt into dt_cho from bh_sk_kbt where so_id=b_so_id and loai='dt_cho';
end if;
select count(*) into b_i1 from bh_sk_kbt where so_id=b_so_id and loai='dt_bvi';
if b_i1=1 then
    select txt into dt_bvi from bh_sk_kbt where so_id=b_so_id and loai='dt_bvi';
end if;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai not in('dt_lt');
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_idP' value b_so_idP,
    'dt_hk' value dt_hk,'dt_lt' value dt_lt,'dt_khd' value dt_khd,'dt_kbt' value dt_kbt,'dt_cho' value dt_cho,
    'dt_bvi' value dt_bvi,'dt_ttt' value dt_ttt,'dt_kytt' value dt_kytt,
    'dt_ct' value dt_ct,'dt_dk' value dt_dk,'dt_dkbs' value dt_dkbs,'dt_lsb' value dt_lsb,'dt_bkh' value dt_bkh,
    'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
