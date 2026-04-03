create or replace procedure PBH_HOPG_TESTr(
    b_ma_dvi varchar2,b_nsd varchar2,dt_ct clob,dt_dk clob,dt_dkbs clob,
    
    b_ng_huong out nvarchar2,
    b_phiH out number,b_thueH out number,b_ttoanH out number,b_so_idP out number,
    b_ma_sp out varchar2,b_cdich out varchar2,b_goi out varchar2,b_dtuong out nvarchar2,

    dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,dk_tc out pht_type.a_var,dk_ma_ct out pht_type.a_var,
    dk_kieu out pht_type.a_var,dk_tien out pht_type.a_num,dk_pt out pht_type.a_num,dk_phi out pht_type.a_num,
    dk_thue out pht_type.a_num,dk_ttoan out pht_type.a_num,
    dk_cap out pht_type.a_num,dk_ma_dk out pht_type.a_var,
    dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,dk_ptB out pht_type.a_num,
    dk_ptG out pht_type.a_num,dk_phiG out pht_type.a_num,
    dk_lkeM out pht_type.a_var,dk_lkeP out pht_type.a_var,dk_lkeB out pht_type.a_var,
    dk_luy out pht_type.a_var,dk_lh_bh out pht_type.a_var,b_loi out varchar2)
AS
    b_i1 number; b_ttrang varchar2(1); b_c_thue varchar2(1); b_tygia number; b_nt_tien varchar2(5);
    b_nt_phi varchar2(5); b_ngay_hl number; b_ngay_kt number; dt_khd clob; b_txt clob;
    b_lenh varchar2(2000); b_kt number;
    b_loai_khH varchar2(1); b_tenH nvarchar2(500); b_ng_sinhH number; b_gioiH varchar2(1);
    b_cmtH varchar2(20); b_mobiH varchar2(20); b_emailH varchar2(20); b_dchiH nvarchar2(400); b_ma_khH varchar2(20);
    
    dk_phiB pht_type.a_num;

    dkB_ma pht_type.a_var; dkB_ten pht_type.a_nvar; dkB_tc pht_type.a_var; dkB_ma_ct pht_type.a_var;
    dkB_tien pht_type.a_num; dkB_pt pht_type.a_num; dkB_phi pht_type.a_num;
    dkB_thue pht_type.a_num;
    dkB_cap pht_type.a_num; dkB_ma_dk pht_type.a_var; dkB_kieu pht_type.a_var;
    dkB_lh_nv pht_type.a_var; dkB_t_suat pht_type.a_num; dkB_ptB pht_type.a_num;
    dkB_phiB pht_type.a_num;
    dkB_lkeM pht_type.a_var; dkB_lkeP pht_type.a_var; dkB_lkeB pht_type.a_var;
    dkB_luy pht_type.a_var;

begin
-- Dan - Nhap
b_lenh:=FKH_JS_LENH('ttrang,c_thue,tygia,nt_tien,nt_phi,ngay_hl,ngay_kt,ma_sp,cdich,goi,dtuong,phi,thue,ttoan');
EXECUTE IMMEDIATE b_lenh into b_ttrang,b_c_thue,b_tygia,b_nt_tien,b_nt_phi,b_ngay_hl,b_ngay_kt,
        b_ma_sp,b_cdich,b_goi,b_dtuong,b_phiH,b_thueH,b_ttoanH using dt_ct;
b_ma_sp:=nvl(trim(b_ma_sp),' '); b_cdich:=nvl(trim(b_cdich),' '); b_goi:=nvl(trim(b_goi),' ');
if b_ma_sp<>' ' and FBH_HOP_SP_HAN(b_ma_sp)<>'C' then
    b_loi:='loi:Ma san pham '||b_ma_sp||'da het su dung:loi'; return;
end if;
if b_cdich<>' ' and FBH_MA_CDICH_HAN(b_cdich)<>'C' then
    b_loi:='loi:Da het chien dich:loi'; return;
end if;
if b_goi<>' ' and FBH_HOP_GOI_HAN(b_goi)<>'C' then
    b_loi:='loi:Ma goi da het su dung:loi'; return;
end if;
b_so_idP:=FBH_HOP_BPHI_SO_ID('G',b_ma_sp,b_cdich,b_goi,b_ngay_hl);
if b_so_idP=0 then b_loi:='loi:Khong co bieu phi phu hop tham so nhap:loi'; return; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,tien,pt,phi,thue,cap,ma_dk,kieu,lh_nv,t_suat,ptb,phib,lkem,lkep,lkeb,luy');
EXECUTE IMMEDIATE b_lenh bulk collect into
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_tien,dk_pt,dk_phi,dk_thue,dk_cap,dk_ma_dk,dk_kieu,
    dk_lh_nv,dk_t_suat,dk_ptB,dk_phiB,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy using dt_dk;
b_kt:=dk_ma.count;
if b_kt=0 then b_loi:='loi:Nhap dieu khoan:loi'; return; end if;
for b_lp in 1..b_kt loop
    dk_ma(b_lp):=nvl(trim(dk_ma(b_lp)),' '); dk_lh_bh(b_lp):='C'; dk_phiB(b_lp):=nvl(dk_phiB(b_lp),0);
    if dk_ma(b_lp)=' ' then b_loi:='loi:Nhap dieu khoan chinh dong '||to_char(b_lp)||':loi'; return; end if;
    dk_tien(b_lp):=nvl(dk_tien(b_lp),0);
end loop;
if trim(dt_dkbs) is not null then
    EXECUTE IMMEDIATE b_lenh bulk collect into
        dkB_ma,dkB_ten,dkB_tc,dkB_ma_ct,dkB_tien,dkB_pt,dkB_phi,dkB_thue,dkB_cap,dkB_ma_dk,dkB_kieu,
        dkB_lh_nv,dkB_t_suat,dkB_ptB,dkB_phiB,dkB_lkeM,dkB_lkeP,dkB_lkeB,dkB_luy using dt_dkbs;
    for b_lp in 1..dkB_ma.count loop
        b_kt:=b_kt+1; dk_ma(b_kt):=nvl(trim(dkB_ma(b_lp)),' '); dk_lh_bh(b_kt):='M';
        if dk_ma(b_kt)=' ' then b_loi:='loi:Nhap dieu khoan mo rong dong '||to_char(b_lp)||':loi'; return; end if;
        dk_ten(b_kt):=dkB_ten(b_lp); dk_tc(b_kt):=dkB_tc(b_lp);
        dk_ma_ct(b_kt):=dkB_ma_ct(b_lp); dk_cap(b_kt):=dkB_cap(b_lp); dk_kieu(b_kt):=dkB_kieu(b_lp);
        dk_tien(b_kt):=dkB_tien(b_lp); dk_pt(b_kt):=dkB_pt(b_lp); dk_phi(b_kt):=dkB_phi(b_lp); dk_thue(b_kt):=dkB_thue(b_lp);
        dk_ma_dk(b_kt):=dkB_ma_dk(b_lp); dk_lh_nv(b_kt):=dkB_lh_nv(b_lp); dk_t_suat(b_kt):=dkB_t_suat(b_lp);
        dk_lkeM(b_kt):=dkB_lkeM(b_lp); dk_lkeP(b_kt):=dkB_lkeP(b_lp); dk_lkeB(b_kt):=dkB_lkeB(b_lp);
        dk_luy(b_kt):=dkB_luy(b_lp); dk_ptB(b_kt):=dkB_ptB(b_lp); dk_phiB(b_kt):=dkB_phiB(b_lp);
    end loop;
end if;
for b_lp in 1..dk_ma.count loop
    dk_ma(b_lp):=trim(dk_ma(b_lp));
    if dk_ma(b_lp) is null then b_loi:='loi:Loi nhap chi tiet nghiep vu dong '||to_char(b_lp)||':loi'; return; end if;
    dk_lh_nv(b_lp):=nvl(trim(dk_lh_nv(b_lp)),' '); 
    dk_tien(b_lp):=nvl(dk_tien(b_lp),0); dk_phi(b_lp):=nvl(dk_phi(b_lp),0);
    if dk_tien(b_lp)=0 and dk_lkeM(b_lp) not in ('T','N','K') and dk_kieu(b_lp)='T' then 
      b_loi:='loi:Chua nhap muc trach nhiem dieu khoan '||dk_ma(b_lp)||':loi'; return; 
    end if;
    if b_c_thue='K' then dk_thue(b_lp):=0; else dk_thue(b_lp):=nvl(dk_thue(b_lp),0); end if;
    dk_ttoan(b_lp):=dk_phi(b_lp)+dk_thue(b_lp);
    if dk_tien(b_lp)<>0 then
      b_i1:=round(dk_phiB(b_lp)/dk_tien(b_lp)*100,4); 
      dk_pt(b_lp):= b_i1 - round(((dk_phiB(b_lp)/dk_tien(b_lp))-(dk_phi(b_lp)/dk_tien(b_lp)))*100 ,4);
    end if;
end loop;
PBH_HD_THAY_PHIg(b_nt_tien,b_nt_tien,b_tygia,b_thueH,b_ttoanH,dk_lh_nv,dk_tien,dk_phi,dk_thue,dk_ttoan,b_loi);
if b_loi is not null then return; end if;
for b_lp in 1..dk_ma.count loop
    if dk_phiB(b_lp)>dk_phi(b_lp) then
        dk_phiG(b_lp):=dk_phiB(b_lp)-dk_phi(b_lp);
        dk_ptG(b_lp):=round(dk_phiG(b_lp)*100/dk_phiB(b_lp),2);
    else
        dk_ptG(b_lp):=0; dk_phiG(b_lp):=0;
    end if;
end loop;
b_phiH:=b_ttoanH-b_thueH; b_ng_huong:='';
if b_ttrang in('T','D') then
    b_lenh:=FKH_JS_LENH('ma_khh,loai_khh,tenh,dchih,cmth,mobih,emailh,ng_sinhh,gioih');
    EXECUTE IMMEDIATE b_lenh into b_ma_khH,b_loai_khH,b_tenH,b_dchiH,b_cmtH,b_mobiH,b_emailH,b_ng_sinhH,b_gioiH using dt_ct;
    if trim(b_tenH) is not null then
        select json_object('ma' value b_ma_khH,'loai' value b_loai_khH,'ten' value b_tenH,'cmt' value b_cmtH,
            'dchi' value b_dchiH,'mobi' value b_mobiH,'email' value b_emailH,
            'gioi' value b_gioiH,'ng_sinh' value b_ng_sinhH) into b_txt from dual;
        PBH_DTAC_MA_NH(b_txt,b_ma_khH,b_loi,b_ma_dvi,b_nsd);
        b_ng_huong:=b_tenH;
        if trim(b_cmtH) is not null then
            if b_loai_khH='C' then
                b_ng_huong:=b_tenH||', so CMT/CCCD: '||b_cmtH||', ngay sinh: '||b_ng_sinhH||', Gioi tinh: '||b_gioiH;
            else
                b_ng_huong:=b_tenH||', ma thue/so GPTL : '||b_cmtH;
            end if;
        end if;
        if trim(b_dchiH) is not null then
            b_ng_huong:=b_tenH||', dia chi: '||b_dchiH;
        end if;
    end if;
    select count(*) into b_i1 from bh_hop_phi_txt where so_id=b_so_idP and loai='dt_khd';
    if b_i1<>0 then
        select txt into dt_khd from bh_hop_phi_txt where so_id=b_so_idP and loai='dt_khd';
        b_i1:=length(dt_khd)-2;
        dt_khd:=substr(dt_khd,2,b_i1);
        PBH_HOPG_KHD('HOP',dt_ct,dt_khd,b_loi);
        if b_loi is not null then return; end if;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HOPG_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    dt_ct in out clob,dt_dk clob,dt_dkbs clob,dt_lt clob,dt_kbt clob,dt_ttt clob,dt_hk clob,

    b_so_hd varchar2,b_ngay_ht number,b_ttrang varchar2,b_kieu_hd varchar2,b_so_hd_g varchar2,
    b_kieu_kt varchar2,b_ma_kt varchar2,b_kieu_gt varchar2,b_ma_gt varchar2,b_ma_cb varchar2,
    b_so_hdL varchar2,b_loai_kh varchar2,b_ma_kh varchar2,b_ten nvarchar2,b_dchi nvarchar2,
    b_cmt varchar2,b_mobi varchar2,b_email varchar2,
    b_gio_hl varchar2,b_ngay_hl number,b_gio_kt varchar2,b_ngay_kt number,b_ngay_cap number,
    b_nt_tien varchar2,b_nt_phi varchar2,b_c_thue varchar2,
    b_phi number,b_giam number,b_thue number,b_ttoan number,b_hhong number,
    b_so_idG number,b_so_idD number,b_ngayD number,b_phong varchar2,
    tt_ngay pht_type.a_num,tt_tien pht_type.a_num,
    
    b_so_idP number,b_ma_sp varchar2,b_cdich varchar2,b_goi varchar2,b_dtuong nvarchar2,

    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tc pht_type.a_var,dk_ma_ct pht_type.a_var,
    dk_kieu pht_type.a_var,dk_tien pht_type.a_num,dk_pt pht_type.a_num,dk_phi pht_type.a_num,
    dk_thue pht_type.a_num,dk_ttoan pht_type.a_num,dk_cap pht_type.a_num,dk_ma_dk pht_type.a_var,
    dk_lh_nv pht_type.a_var,dk_t_suat pht_type.a_num,dk_ptB pht_type.a_num,dk_ptG pht_type.a_num,dk_phiG pht_type.a_num,
    dk_lkeM pht_type.a_var,dk_lkeP pht_type.a_var,dk_lkeB pht_type.a_var,
    dk_luy pht_type.a_var,dk_lh_bh pht_type.a_var,b_loi out varchar2)
AS
    b_i1 number; b_so_id_kt number:=-1; b_tien number:=0; b_txt clob; b_ma_ke varchar2(20);
begin
-- Dan - Nhap
b_loi:='loi:Loi Table bh_hop:loi';
if b_ttrang='D' then b_so_id_kt:=0; end if;
insert into bh_hop_ds values(b_ma_dvi,b_so_id,b_so_id,0,b_kieu_hd,b_so_hd,b_so_hd_g,
        b_dtuong,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,
        b_so_idP,b_phi,b_giam,b_ttoan);
for b_lp in 1..dk_lh_nv.count loop
    if dk_lh_nv(b_lp)<>' ' and dk_kieu(b_lp)='T' then b_tien:=b_tien+dk_tien(b_lp); end if;
    insert into bh_hop_dk values(b_ma_dvi,b_so_id,b_so_id,b_lp,
        dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),dk_kieu(b_lp),
        dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),dk_cap(b_lp),dk_ma_dk(b_lp),
        dk_lh_nv(b_lp),dk_t_suat(b_lp),dk_thue(b_lp),dk_ttoan(b_lp),
        dk_ptB(b_lp),dk_ptG(b_lp),dk_phiG(b_lp),
        dk_lkeM(b_lp),dk_lkeP(b_lp),dk_lkeB(b_lp),dk_luy(b_lp),dk_lh_bh(b_lp));
end loop;
insert into bh_hop values(
    b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,'HOP','G',b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
    b_phong,b_so_hdL,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,
    b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,1,b_ma_sp,b_cdich,b_goi,b_tien,b_phi,b_giam,b_thue,b_ttoan,b_hhong,
    b_so_idG,b_so_idD,'','',b_so_id_kt,b_nsd,sysdate);
PKH_JS_THAYa(dt_ct,'so_hd,ma_kh',b_so_hd||','||b_ma_kh);
insert into bh_hop_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
insert into bh_hop_txt values(b_ma_dvi,b_so_id,'dt_dk',dt_dk);
if trim(dt_ttt) is not null then
    insert into bh_hop_txt values(b_ma_dvi,b_so_id,'dt_ttt',dt_ttt);
end if;
if trim(dt_hk) is not null then
    insert into bh_hop_txt values(b_ma_dvi,b_so_id,'dt_hk',dt_hk);
end if;
if trim(dt_dkbs) is not null and dt_dkbs<>'[""]'  then
    insert into bh_hop_txt values(b_ma_dvi,b_so_id,'dt_dkbs',dt_dkbs);
end if;
if trim(dt_lt) is not null and dt_lt<>'[""]' then
    insert into bh_hop_txt values(b_ma_dvi,b_so_id,'dt_lt',dt_lt);
end if;
if trim(dt_kbt) is not null and dt_kbt<>'[""]' then
    insert into bh_hop_txt values(b_ma_dvi,b_so_id,'dt_kbt',dt_kbt);
end if;
for b_lp in 1..tt_ngay.count loop
    insert into bh_hop_tt values(b_ma_dvi,b_so_id,tt_ngay(b_lp),tt_tien(b_lp));
end loop;
if b_ttrang in('T','D') then
    if dt_dkbs is null then
        b_txt:=dt_dk;
    else
        b_i1:=length(dt_dk)-1;
        b_txt:=substr(dt_dk,1,b_i1)||','||substr(dt_dkbs,2);
    end if;
    insert into bh_hop_kbt values(b_ma_dvi,b_so_id,b_so_id,b_txt,dt_lt,dt_kbt);
    select json_object('ma_dvi' value b_ma_dvi,'nsd' value b_nsd,'so_id' value b_so_id,'so_hd' value b_so_hd,
        'kieu_hd' value b_kieu_hd,'nv' value 'HOP','ngay_ht' value b_ngay_ht,'ngay_cap' value b_ngay_cap,
        'ngay_hl' value b_ngay_hl,'ngay_kt' value b_ngay_kt,'cb_ql' value b_ma_cb,'b_phong' value b_ma_cb,
        'kieu_kt' value b_kieu_kt,'ma_kt' value b_ma_kt,'dly_tke' value ' ','hhong' value b_hhong,
        'pt_hhong' value 'D','ma_kh' value b_ma_kh,'ten' value b_ten,'kieu_gt' value b_kieu_gt,
        'ma_gt' value b_ma_gt,'so_id_d' value b_so_idD,'so_id_g' value b_so_idG,'ttrang' value b_ttrang,
        'dvi_ksoat' value b_ma_dvi,'ksoat' value b_nsd,'bangg' value 'bh_hop',
        'c_thue' value b_c_thue,'nt_tien' value b_nt_tien,'nt_tien' value b_nt_phi,'tien' value b_tien,
        'phi' value b_ttoan-b_thue,'thue' value b_thue returning clob) into b_txt from dual;
    PBH_HD_GOC_NH(b_txt,b_loi);
    if b_loi is not null then return; end if;
end if;
if b_ttrang='D' and b_kieu_hd<>'U' then
    PBH_KE_CTI_NHOM(b_ma_dvi,b_so_idD,b_so_idD,b_ma_ke,b_loi);
    if b_loi is null then return; end if;
    insert into bh_hd_goc_ttindt values(
        b_ma_dvi,b_so_id,b_so_id,'HOP',b_dtuong,b_ma_kh,b_ngay_kt,'',b_ma_ke);
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HOPG_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_i1 number;
    dt_ct clob; dt_dk clob; dt_dkbs clob; dt_lt clob; dt_kbt clob; dt_ttt clob; dt_hk clob; dt_kytt clob;
-- Ra chung
    b_so_id number; b_so_hd varchar2(20); b_ngay_ht number; b_ttrang varchar2(1); b_kieu_hd varchar2(1); b_so_hd_g varchar2(20);
    b_kieu_kt varchar2(1); b_ma_kt varchar2(20); b_kieu_gt varchar2(1); b_ma_gt varchar2(20); b_ma_cb varchar2(20);
    b_so_hdL varchar2(20); b_loai_kh varchar2(1); b_ma_kh varchar2(20); b_ten nvarchar2(500); b_dchi nvarchar2(500);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(50);
    b_gio_hl varchar2(20); b_ngay_hl number; b_gio_kt varchar2(20); b_ngay_kt number; b_ngay_cap number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_c_thue varchar2(1);
    b_phi number; b_giam number; b_thue number; b_ttoan number; b_hhong number;
    b_so_idG number; b_so_idD number; b_ngayD number; b_phong varchar2(10);
    tt_ngay pht_type.a_num; tt_tien pht_type.a_num;
-- Ra rieng
    b_ng_huong nvarchar2(500); b_ma_sp varchar2(10); b_cdich varchar2(10); b_goi varchar2(10); b_dtuong nvarchar2(500);

    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var; dk_ma_ct pht_type.a_var;
    dk_kieu pht_type.a_var; dk_tien pht_type.a_num; dk_pt pht_type.a_num; dk_phi pht_type.a_num;
    dk_thue pht_type.a_num; dk_ttoan pht_type.a_num;
    dk_cap pht_type.a_num; dk_ma_dk pht_type.a_var; dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num;
    dk_ptB pht_type.a_num; dk_ptG pht_type.a_num; dk_phiG pht_type.a_num;
    dk_lkeM pht_type.a_var; dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var;
    dk_luy pht_type.a_var; dk_lh_bh pht_type.a_var;
-- xu ly
    b_ngay_htC number; b_so_idP number;
begin
-- Dan - Nhap
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HOP','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_dkbs,dt_lt,dt_kbt,dt_ttt,dt_hk,dt_kytt');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_dkbs,dt_lt,dt_kbt,dt_ttt,dt_hk,dt_kytt using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_kytt); FKH_JSa_NULL(dt_ttt); FKH_JSa_NULL(dt_hk); 
FKH_JSa_NULL(dt_dkbs); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_lt); FKH_JSa_NULL(dt_kbt);
if b_so_id<>0 then
    select count(*) into b_i1 from bh_hop where so_id=b_so_id;
    if b_i1<>0 then
        select ngay_ht,kieu_hd,ttrang into b_ngay_htC,b_kieu_hd,b_ttrang from bh_hop
            where so_id=b_so_id for update nowait;
        if sql%rowcount=0 then b_loi:='loi:Va cham NSD:loi'; raise PROGRAM_ERROR; end if;
        if b_ttrang not in('T','D') then b_kieu_hd:='X'; else b_kieu_hd:='N'; end if;
        PBH_HOP_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_kieu_hd,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
else
    PHT_ID_MOI(b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_HD_JS_TEST(
    b_ma_dvi,b_nsd,b_so_id,b_ngay_htC,'bh_hop',dt_ct,dt_kytt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_loai_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,
    b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_ngayD,b_phong,b_ma_cb,b_ma_kh,
    tt_ngay,tt_tien,b_loi,'HOP');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_HOPG_TESTr(
    b_ma_dvi,b_nsd,dt_ct,dt_dk,dt_dkbs,
    b_ng_huong,b_phi,b_thue,b_ttoan,b_so_idP,b_ma_sp,b_cdich,b_goi,b_dtuong,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,
    dk_cap,dk_ma_dk,dk_lh_nv,dk_t_suat,dk_ptB,dk_ptG,dk_phiG,
    dk_lkeM,dk_lkeP,dk_lkeB,dk_luy,dk_lh_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_HOPG_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,dt_ct,dt_dk,dt_dkbs,dt_lt,dt_kbt,dt_ttt,dt_hk,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,b_so_hdL,
    b_loai_kh,b_ma_kh,b_ten,b_dchi, b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,
    b_nt_tien,b_nt_phi,b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_ngayD,b_phong,
    tt_ngay,tt_tien,
    b_so_idP,b_ma_sp,b_cdich,b_goi,b_dtuong,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,dk_cap,dk_ma_dk,
    dk_lh_nv,dk_t_suat,dk_ptB,dk_ptG,dk_phiG,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy,dk_lh_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hd' value b_so_hd, 'ma_kh' value b_ma_kh) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HOPG_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number; b_so_idP number;
    dt_ct clob; dt_dk clob; dt_dkbs clob; dt_lt clob; dt_khd clob; dt_kbt clob;
    dt_ttt clob; dt_hk clob; dt_kytt clob; dt_txt clob;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','HOP','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
if b_so_id=0 then b_loi:='loi:GCN/Hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
b_so_idP:=FBH_HOP_SO_IDp(b_ma_dvi,b_so_id);
select json_object(so_hd,ma_kh) into dt_ct from bh_hop where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ma,phi) order by bt returning clob) into dt_dk
    from bh_hop_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_bh<>'M';
select JSON_ARRAYAGG(json_object(ma,phi) order by bt returning clob) into dt_dkbs
    from bh_hop_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_bh='M';
select JSON_ARRAYAGG(json_object(ngay,tien) order by ngay) into dt_kytt from bh_hop_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select count(*) into b_i1 from bh_hop_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_lt';
if b_i1=1 then
    select txt into dt_lt from bh_hop_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_lt';
end if;
select count(*) into b_i1 from bh_hop_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_kbt';
if b_i1=1 then
    select txt into dt_kbt from bh_hop_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_kbt';
end if;
select count(*) into b_i1 from bh_hop_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
if b_i1<>0 then
    select txt into dt_ttt from bh_hop_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
end if;
select count(*) into b_i1 from bh_hop_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
if b_i1<>0 then
    select txt into dt_hk from bh_hop_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
end if;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_hop_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai in('dt_ct','dt_dk','dt_dkbs');

select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_idP' value b_so_idP,
    'dt_dk' value dt_dk,'dt_dkbs' value dt_dkbs,'dt_lt' value dt_lt,'dt_khd' value dt_khd,
    'dt_kbt' value dt_kbt,'dt_ttt' value dt_ttt,'dt_hk' value dt_hk,'dt_kytt' value dt_kytt,
  'dt_ct' value dt_ct,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;


