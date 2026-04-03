create or replace procedure PBH_PTNNNG_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_ngay number:=PKH_NG_CSO(sysdate);
    cs_sp clob; cs_cdich clob;cs_nghe clob;cs_pvi clob;cs_lvuc clob;cs_khd clob; cs_kbt clob; cs_tltg clob; cs_ttt clob;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(a.ma,a.ten returning clob) order by a.ten returning clob) into cs_sp from
    bh_ptnnn_sp a,(select distinct ma_sp from bh_ptnnn_phi where nhom='G' and ngay_bd<=b_ngay and ngay_kt>b_ngay and nhom='G') b
  where a.ma=b.ma_sp and FBH_PTNNN_SP_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(a.ma,a.ten returning clob) order by a.ten returning clob) into cs_cdich from
    bh_ma_cdich a,(select distinct cdich from bh_ptnnn_phi where nhom='G' and ngay_bd<=b_ngay and ngay_kt>b_ngay and nhom='G') b
  where a.ma=b.cdich and FBH_MA_CDICH_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(a.ma,a.ten returning clob) order by a.ten returning clob) into cs_nghe from
    bh_ma_nghe a,(select distinct nghe from bh_ptnnn_phi where nhom='G' and ngay_bd<=b_ngay and ngay_kt>b_ngay and nhom='G') b
  where a.ma=b.nghe;
select JSON_ARRAYAGG(json_object(a.ma,a.ten returning clob) order by a.ten returning clob) into cs_pvi from
    bh_ptnnn_pvi a,(select distinct pvi from bh_ptnnn_phi where nhom='G' and ngay_bd<=b_ngay and ngay_kt>b_ngay) b
  where a.ma=b.pvi;
select JSON_ARRAYAGG(json_object(ma,ten returning clob) order by ten returning clob) into cs_lvuc from bh_ma_lvuc where FBH_MA_LVUC_HAN(ma)='C';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_khd from bh_kh_ttt where ps='KHD' and nv='PTN';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_kbt from bh_kh_ttt where ps='KBT' and nv='PTN';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra returning clob) order by bt returning clob) into cs_ttt
    from bh_kh_ttt where ps='HD' and nv='PTN';
select JSON_ARRAYAGG(json_object(tltg,tlph returning clob) order by tltg returning clob) into cs_tltg
    from bh_ptn_tltg where b_ngay between ngay_bd and ngay_kt;
select json_object('cs_sp' value cs_sp,'cs_cdich' value cs_cdich,'cs_nghe' value cs_nghe,'cs_pvi' value cs_pvi,
'cs_lvuc' value cs_lvuc,'cs_khd' value cs_khd,'cs_kbt' value cs_kbt,'cs_tltg' value cs_tltg,'cs_ttt' value cs_ttt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNNNG_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    dt_ct in out clob,dt_dk clob,dt_dkbs clob,dt_lt clob,dt_kbt clob,dt_ttt clob,

    b_so_hd varchar2,b_ngay_ht number,b_ttrang varchar2,b_kieu_hd varchar2,b_so_hd_g varchar2,
    b_kieu_kt varchar2,b_ma_kt varchar2, b_kieu_gt varchar2,b_ma_gt varchar2,b_ma_cb varchar2,b_so_hdL varchar2,
    b_loai_kh varchar2,b_ma_kh varchar2,b_ten nvarchar2,b_dchi nvarchar2,b_cmt varchar2,b_mobi varchar2,b_email varchar2,
    b_gio_hl varchar2,b_ngay_hl number,b_gio_kt varchar2,b_ngay_kt number,b_ngay_cap number,
    b_nt_tien varchar2,b_nt_phi varchar2, b_c_thue varchar2,
    b_phi number,b_giam number,b_thue number,b_ttoan number,b_hhong number,
    b_so_idG number,b_so_idD number,b_ngayD number,b_phong varchar2,b_so_dt number,
    tt_ngay pht_type.a_num,tt_tien pht_type.a_num,

    b_so_idP number,b_ma_sp varchar2,b_cdich varchar2,b_nghe varchar2,
    b_pvi varchar2,b_dtuong nvarchar2, b_ngay_hoi number,

    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tc pht_type.a_var,dk_ma_ct pht_type.a_var,
    dk_kieu pht_type.a_var,dk_tien pht_type.a_num,dk_pt pht_type.a_num,dk_phi pht_type.a_num,
    dk_thue pht_type.a_num,dk_ttoan pht_type.a_num,dk_cap pht_type.a_num,dk_ma_dk pht_type.a_var,
    dk_lh_nv pht_type.a_var,dk_t_suat pht_type.a_num,dk_ptB pht_type.a_num,dk_ptG pht_type.a_num,dk_phiG pht_type.a_num,
    dk_lkeM pht_type.a_var,dk_lkeP pht_type.a_var,dk_lkeB pht_type.a_var,dk_luy pht_type.a_var,dk_lh_bh pht_type.a_var,b_loi out varchar2)
AS
    b_so_id_kt number:=-1; b_txt clob; b_tien number:=0; b_ma_ke varchar2(20):=' ';
begin
-- Nam - Nhap
b_loi:='loi:Loi Table bh_ptnnn:loi';
if b_ttrang='D' then b_so_id_kt:=0; end if;
for b_lp in 1..dk_lh_nv.count loop
     if dk_lh_nv(b_lp)<>' ' and dk_kieu(b_lp)='T' then b_tien:=b_tien+dk_tien(b_lp); end if;
     insert into bh_ptnnn_dk values(b_ma_dvi,b_so_id,b_so_id,b_lp,
        dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),dk_kieu(b_lp),
        dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),dk_cap(b_lp),dk_ma_dk(b_lp),
        dk_lh_nv(b_lp),dk_t_suat(b_lp),dk_thue(b_lp),dk_ttoan(b_lp),
        dk_ptB(b_lp),dk_ptG(b_lp),dk_phiG(b_lp),dk_lkeM(b_lp),dk_lkeP(b_lp),dk_lkeB(b_lp),dk_luy(b_lp),dk_lh_bh(b_lp));
end loop;
insert into bh_ptnnn values(
      b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,'G',b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,b_phong,b_so_hdL,b_loai_kh,b_ma_kh,
      b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,b_ma_sp,b_cdich,b_nghe,
      b_so_dt,b_tien,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,' ',' ',b_so_id_kt,b_nsd,sysdate);
insert into bh_ptnnn_dvi values(
        b_ma_dvi,b_so_id,b_so_id,0,b_kieu_hd,b_so_hd,b_so_hd_g,b_pvi,b_dtuong,b_gio_hl,
        b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_ngay_hoi,b_so_idP,b_phi,b_thue,b_ttoan);
PKH_JS_THAYa(dt_ct,'so_hd,ma_kh',b_so_hd||','||b_ma_kh);
if trim(b_ma_kh) is not null then PKH_JS_THAY(dt_ct,'ma_kh',b_ma_kh); end if;
insert into bh_ptnnn_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
insert into bh_ptnnn_txt values(b_ma_dvi,b_so_id,'dt_dk',dt_dk);
if dt_dkbs is not null then 
   insert into bh_ptnnn_txt values(b_ma_dvi,b_so_id,'dt_dkbs',dt_dkbs);
end if;
if dt_ttt is not null then
  insert into bh_ptnnn_txt values(b_ma_dvi,b_so_id,'dt_ttt',dt_ttt);
end if;
if trim(dt_lt) is not null then
    insert into bh_ptnnn_txt values(b_ma_dvi,b_so_id,'dt_lt',dt_lt);
end if;
if trim(dt_kbt) is not null then
    insert into bh_ptnnn_txt values(b_ma_dvi,b_so_id,'dt_kbt',dt_kbt);
end if;
for b_lp in 1..tt_ngay.count loop
    insert into bh_ptnnn_tt values(b_ma_dvi,b_so_id,tt_ngay(b_lp),tt_tien(b_lp));
end loop;
-- Di tiep
if b_ttrang in('T','D') then
    select JSON_ARRAYAGG(json_object(
        ma,ten,tc,ma_ct,tien,pt,phi,cap,ma_dk,lh_nv,t_suat,thue,ttoan,ptB,ptG,phiG,lkeM,lkeP,lkeB,luy)
        order by bt returning clob) into b_txt
        from bh_ptn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
    insert into bh_ptn_kbt values(b_ma_dvi,b_so_id,b_so_id,b_txt,dt_lt,dt_kbt);
    insert into bh_ptnnn_kbt values(b_ma_dvi,b_so_id,b_so_id,b_txt,dt_lt,dt_kbt);
    insert into bh_ptn values(
          b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,'TNNN','G',b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
          b_phong,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,
          b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,b_ma_sp,b_cdich,1,b_phi,b_tien,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,'','',b_so_id_kt,b_nsd);
    insert into bh_ptn_dvi values(
        b_ma_dvi,b_so_id,b_so_id,0,b_kieu_hd,b_so_hd,b_so_hd_g,b_dtuong,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_ngay_hoi,b_so_idP,b_phi,b_thue,b_ttoan);
    for b_lp in 1..tt_ngay.count loop
        insert into bh_ptn_tt values(b_ma_dvi,b_so_id,tt_ngay(b_lp),tt_tien(b_lp));
    end loop;
    for b_lp in 1..dk_lh_nv.count loop
      insert into bh_ptn_dk values(b_ma_dvi,b_so_id,b_so_id,b_lp,
        dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),dk_kieu(b_lp),dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),
        dk_cap(b_lp),dk_ma_dk(b_lp),dk_lh_nv(b_lp),dk_t_suat(b_lp),dk_thue(b_lp),dk_ttoan(b_lp),
        dk_ptB(b_lp),dk_ptG(b_lp),dk_phiG(b_lp),dk_lkeM(b_lp),dk_lkeP(b_lp),dk_lkeB(b_lp),dk_luy(b_lp),dk_lh_bh(b_lp));
    end loop;
  insert into bh_ptn_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
    select json_object('ma_dvi' value b_ma_dvi,'nsd' value b_nsd,'so_id' value b_so_id,'so_hd' value b_so_hd,
        'kieu_hd' value b_kieu_hd,'nv' value 'PTN','ngay_ht' value b_ngay_ht,'ngay_cap' value b_ngay_cap,
        'ngay_hl' value b_ngay_hl,'ngay_kt' value b_ngay_kt,'cb_ql' value b_ma_cb,'phong' value b_phong,
        'kieu_kt' value b_kieu_kt,'ma_kt' value b_ma_kt,'dly_tke' value ' ','hhong' value b_hhong,
        'pt_hhong' value 'D','ma_kh' value b_ma_kh,'ten' value b_ten,'kieu_gt' value b_kieu_gt,
        'ma_gt' value b_ma_gt,'so_id_d' value b_so_idD,'so_id_g' value b_so_idG,'ttrang' value b_ttrang,
        'dvi_ksoat' value b_ma_dvi,'ksoat' value b_nsd,'bangg' value 'bh_ptncc,bh_ptnnn,bh_ptnvc,bh_ptnch',
        'c_thue' value b_c_thue,'nt_tien' value b_nt_tien,'nt_phi' value b_nt_phi,'tien' value b_tien,
        'phi' value b_ttoan-b_thue,'thue' value b_thue returning clob) into b_txt from dual;
    PBH_HD_GOC_NH(b_txt,b_loi);
    if b_loi is not null then return; end if;
end if;
if b_ttrang='D' then
    PBH_KE_CTI_NHOM(b_ma_dvi,b_so_idD,b_so_idD,b_ma_ke,b_loi);
    if b_loi is null then return; end if;
    insert into bh_hd_goc_ttindt values(b_ma_dvi,b_so_idD,b_so_idD,'PTN',b_dtuong,b_ma_kh,b_ngay_kt,'',b_ma_ke);
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PTNNNG_TESTr(
    dt_ct in out clob,dt_dk in out clob,dt_dkbs clob,
    --dt_ct
    b_so_idP out number,b_phi out number,b_ttoan out number,
    b_ma_sp out varchar2,b_cdich out varchar2,b_nghe out varchar2,b_pvi out varchar2,
    b_ghan out varchar2, b_gia_ctrinh out number,b_gia_hdtv out number,b_mo_ta out nvarchar2,b_ddiem_bh out nvarchar2,
    b_cso_knai out varchar2,b_ngay_hoi out number,b_gh_dly out varchar2,b_luat_ad out varchar2,b_dtuong out varchar2,
    b_so_dt out number,b_giam out number, b_thue out number,b_ma_cb out varchar2,b_tygia out number,
    --dieu khoan
    dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,dk_tc out pht_type.a_var,dk_ma_ct out pht_type.a_var,
    dk_kieu out pht_type.a_var,dk_tien out pht_type.a_num,dk_pt out pht_type.a_num,dk_phi out pht_type.a_num,
    dk_thue out pht_type.a_num,dk_ttoan out pht_type.a_num, dk_cap out pht_type.a_num,dk_ma_dk out pht_type.a_var,
    dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,dk_ptB out pht_type.a_num,
    dk_ptG out pht_type.a_num,dk_phiG out pht_type.a_num,dk_lkeM out pht_type.a_var,dk_lkeP out pht_type.a_var,dk_lkeB out pht_type.a_var,
    dk_luy out pht_type.a_var,dk_lh_bh out pht_type.a_var,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_kt number;
    b_ttrang varchar2(1);b_ngay_hl number; b_ngay_kt number; b_c_thue varchar2(1); b_nt_tien varchar2(5);
    b_nt_phi varchar2(5); b_tp number:=0;
    dk_phiB pht_type.a_num; dkB_lkeM pht_type.a_var;

    dkB_ma pht_type.a_var; dkB_ten pht_type.a_nvar; dkB_tc pht_type.a_var; dkB_ma_ct pht_type.a_var;
    dkB_tien pht_type.a_num; dkB_pt pht_type.a_num; dkB_phi pht_type.a_num;
    dkB_thue pht_type.a_num;
    dkB_cap pht_type.a_num; dkB_ma_dk pht_type.a_var; dkB_kieu pht_type.a_var;
    dkB_lh_nv pht_type.a_var; dkB_t_suat pht_type.a_num; dkB_ptB pht_type.a_num;
    dkB_phiB pht_type.a_num; dkB_lkeP pht_type.a_var; dkB_lkeB pht_type.a_var; dkB_luy pht_type.a_var; 

begin
-- Nam - Nhap
b_lenh:=FKH_JS_LENH('ttrang,ngay_hl,ngay_kt,ma_sp,cdich,nghe,pvi,ghan_m,gct,gtv,mo_ta,dchiB,cs_knai,ngay_hoi,
                                gh_dly,luat_ad,dtuong,so_dt,giam,phi,thue,ttoan,ma_cb,tygia,c_thue,nt_tien,nt_phi');
EXECUTE IMMEDIATE b_lenh
        into b_ttrang,b_ngay_hl,b_ngay_kt,b_ma_sp,b_cdich,b_nghe,b_pvi,b_ghan,b_gia_ctrinh,b_gia_hdtv,b_mo_ta,
        b_ddiem_bh,b_cso_knai,b_ngay_hoi,b_gh_dly,b_luat_ad,b_dtuong,b_so_dt,b_giam,b_phi,b_thue,b_ttoan,b_ma_cb,b_tygia,
        b_c_thue,b_nt_tien,b_nt_phi using dt_ct;
if trim(b_ma_sp) is null or FBH_PTNNN_SP_HAN(b_ma_sp)<>'C' then b_loi:='loi:Sai ma san pham:loi'; return; end if;
b_cdich:=nvl(trim(b_cdich),' ');
if b_cdich<>' ' and FBH_MA_CDICH_HAN(b_cdich)<>'C' then b_loi:='loi:Sai ma chien dich:loi'; return; end if;
b_nghe:=nvl(trim(b_nghe),' ');
if b_nghe<>' ' and FBH_MA_NGHE_HAN(b_nghe)<>'C' then b_loi:='loi:Sai ma nghe:loi'; return; end if;
if b_pvi<>' ' and FBH_PTNNN_PVI_HAN(b_pvi)<>'C' then b_loi:='loi:Sai ma pham vi:loi'; return; end if;
b_dtuong:=nvl(trim(b_dtuong),' ');
if b_dtuong is null then b_dtuong:= ' '; end if;
b_c_thue:=nvl(trim(b_c_thue),'C');
if nvl(trim(b_nt_phi),'VND')<>'VND' then b_tp:=2; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,tien,pt,phi,thue,cap,ma_dk,kieu,lh_nv,t_suat,ptb,phib,lkem,lkep,lkeb,luy');
EXECUTE IMMEDIATE b_lenh bulk collect into
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_tien,dk_pt,dk_phi,dk_thue,dk_cap,dk_ma_dk,dk_kieu,
    dk_lh_nv,dk_t_suat,dk_ptB,dk_phiB,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy using dt_dk;
b_kt:=dk_ma.count;
if b_kt=0 then b_loi:='loi:Nhap dieu khoan:loi'; return; end if;
for b_lp in 1..b_kt loop
    dk_ma(b_lp):=nvl(trim(dk_ma(b_lp)),' '); dk_lh_bh(b_lp):='C'; dk_phiB(b_lp):=nvl(dk_phiB(b_lp),0);
    if dk_ma(b_lp)=' ' then b_loi:='loi:Nhap dieu khoan chinh dong '||to_char(b_lp)||':loi'; return; end if;
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
        dk_tien(b_kt):=dkB_tien(b_lp); dk_pt(b_kt):=dkB_pt(b_lp);
        dk_phi(b_kt):=dkB_phi(b_lp);dk_thue(b_kt):=dkB_thue(b_lp);
        dk_ma_dk(b_kt):=dkB_ma_dk(b_lp); dk_lh_nv(b_kt):=dkB_lh_nv(b_lp);
        dk_t_suat(b_kt):=dkB_t_suat(b_lp); dk_ptB(b_kt):=dkB_ptB(b_lp); dk_phiB(b_kt):=nvl(dkB_phiB(b_lp),0); dk_lkeM(b_kt):=dkB_lkeM(b_lp);
        dk_lkeP(b_kt):=dkB_lkeP(b_lp); dk_lkeB(b_kt):=dkB_lkeB(b_lp); dk_luy(b_kt):=dkB_luy(b_lp);
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
      b_i1:=round(dk_phiB(b_lp)/dk_tien(b_lp)*100,20);
      dk_pt(b_lp):= b_i1 - round(((dk_phiB(b_lp)/dk_tien(b_lp))-(dk_phi(b_lp)/dk_tien(b_lp)))*100 ,20);
    end if;
end loop;
b_so_idP:=FBH_PTNNN_BPHI_SO_IDh('G',b_ma_sp,b_cdich,b_nghe,b_pvi,b_ghan,b_gia_ctrinh,b_gia_hdtv,b_ngay_hl);
if b_so_idP=0 then b_loi:='loi:Sai bieu phi:loi'; return;
end if;
PBH_HD_THAY_PHIg(b_nt_tien,b_nt_tien,b_tygia,b_thue,b_ttoan,dk_lh_nv,dk_tien,dk_phi,dk_thue,dk_ttoan,b_loi);
if b_loi is not null then return; end if;
for b_lp in 1..dk_ma.count loop
    if dk_phiB(b_lp)>dk_phi(b_lp) then
        dk_phiG(b_lp):=dk_phiB(b_lp)-dk_phi(b_lp);
        dk_ptG(b_lp):=round(dk_phiG(b_lp)*100/dk_phiB(b_lp),2);
    else
        dk_ptG(b_lp):=0; dk_phiG(b_lp):=0;
    end if;
end loop;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PTNNNG_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(3000); b_lenh varchar2(2000); b_i1 number;
    dt_ct clob; dt_dk clob; dt_dkbs clob; dt_lt clob; dt_kbt clob; dt_kytt clob; dt_ttt clob;
-- Chung
    b_so_id number; b_so_hd varchar2(20); b_ngay_ht number; b_ttrang varchar2(1); b_kieu_hd varchar2(1); b_so_hd_g varchar2(20);
    b_kieu_kt varchar2(1); b_ma_kt varchar2(20); b_kieu_gt varchar2(1); b_ma_gt varchar2(20); b_ma_cb varchar2(20);
    b_so_hdL varchar2(20); b_loai_kh varchar2(1); b_ma_kh varchar2(20); b_ten nvarchar2(500); b_dchi nvarchar2(500);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_gio_hl varchar2(20); b_ngay_hl number; b_gio_kt varchar2(20); b_ngay_kt number; b_ngay_cap number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_c_thue varchar2(1);
    b_phi number; b_giam number; b_thue number; b_ttoan number; b_hhong number;
    b_so_idG number; b_so_idD number; b_ngayD number; b_phong varchar2(10); b_so_dt number;

-- Rieng
   --dt_ct
    b_ma_sp varchar2(10); b_cdich varchar2(10); b_nghe varchar2(10); b_pvi varchar2(10);
    b_ghan varchar2(1); b_gia_ctrinh number; b_gia_hdtv number;
    b_mo_ta nvarchar2(500); b_ddiem_bh nvarchar2(500); b_cso_knai varchar2(1); b_ngay_hoi number;
    b_gh_dly varchar2(20); b_luat_ad varchar2(20); b_tygia number; b_dtuong nvarchar2(500);
    b_so_idP number;
    --dieu khoan
    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var; dk_ma_ct pht_type.a_var;
    dk_kieu pht_type.a_var; dk_tien pht_type.a_num; dk_pt pht_type.a_num; dk_phi pht_type.a_num;
    dk_thue pht_type.a_num; dk_ttoan pht_type.a_num; dk_cap pht_type.a_num; dk_ma_dk pht_type.a_var;
    dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num; dk_ptB pht_type.a_num;
    dk_ptG pht_type.a_num; dk_phiG pht_type.a_num; dk_lkeM pht_type.a_var; dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var;
    dk_luy pht_type.a_var; dk_lh_bh pht_type.a_var;
    -- ky thanh toan
    tt_ngay pht_type.a_num; tt_tien pht_type.a_num;
-- Xu ly
    b_ngay_htC number;
begin
-- Nam - Nhap
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_dkbs,dt_lt,dt_kbt,dt_ttt,dt_kytt');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_dkbs,dt_lt,dt_kbt,dt_ttt,dt_kytt using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_dkbs);
FKH_JSa_NULL(dt_lt); FKH_JSa_NULL(dt_kbt); FKH_JSa_NULL(dt_ttt); FKH_JSa_NULL(dt_kytt);
if b_so_id<>0 then
    select count(*) into b_i1 from bh_ptnnn where so_id=b_so_id;
    if b_i1<>0 then
        select ngay_ht,kieu_hd,ttrang into b_ngay_htC,b_kieu_hd,b_ttrang from bh_ptnnn
            where so_id=b_so_id for update nowait;
        if sql%rowcount=0 then b_loi:='loi:Va cham NSD:loi'; raise PROGRAM_ERROR; end if;
        if b_ttrang not in('T','D') then b_kieu_hd:='X'; else b_kieu_hd:='N'; end if;
        PBH_PTNNN_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_kieu_hd,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
else
    PHT_ID_MOI(b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_HD_JS_TEST(
    b_ma_dvi,b_nsd,b_so_id,b_ngay_htC,'bh_ptnnn',dt_ct,dt_kytt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_loai_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,
    b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_ngayD,b_phong,b_ma_cb,b_ma_kh,
    tt_ngay,tt_tien,b_loi,'PTN');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_PTNNNG_TESTr(
   dt_ct,dt_dk,dt_dkbs,
   b_so_idP,b_phi,b_ttoan,
   b_ma_sp,b_cdich,b_nghe,b_pvi,b_ghan,b_gia_ctrinh,
   b_gia_hdtv,b_mo_ta ,b_ddiem_bh,b_cso_knai,b_ngay_hoi,b_gh_dly ,
   b_luat_ad ,b_dtuong ,b_so_dt,b_giam,b_thue,b_ma_cb,b_tygia,
   dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,dk_cap,dk_ma_dk,
   dk_lh_nv,dk_t_suat,dk_ptB,dk_ptG,dk_phiG,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy,dk_lh_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_PTNNNG_NH_NH(
   b_ma_dvi,b_nsd,b_so_id,dt_ct,dt_dk,dt_dkbs,dt_lt,dt_kbt,dt_ttt,
   b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
   b_so_hdL,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
   b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,
   b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_ngayD,b_phong,b_so_dt,
   tt_ngay,tt_tien,
   b_so_idP,b_ma_sp,b_cdich,b_nghe,b_pvi,b_dtuong,b_ngay_hoi,
   dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,dk_cap,dk_ma_dk,
   dk_lh_nv,dk_t_suat,dk_ptB,dk_ptG,dk_phiG,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy,dk_lh_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hd' value b_so_hd, 'ma_kh' value b_ma_kh) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNNNG_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number;
    dt_ct clob; dt_dk clob; dt_dkbs clob; dt_lt clob:=''; dt_khd clob:=''; dt_kbt clob:=''; dt_kytt clob:=''; dt_ttt clob:=''; dt_txt clob;
begin
-- Nam - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','PTN','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
if b_so_id=0 then b_loi:='loi:Chon GCN:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
select json_object(so_hd,ma_kh) into dt_ct from bh_ptnnn where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ngay,tien) order by ngay) into dt_kytt from bh_ptnnn_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ma,ten) order by bt returning clob) into dt_dk
    from bh_ptnnn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_bh<>'M';
select JSON_ARRAYAGG(json_object(ma,ten) order by bt returning clob) into dt_dkbs
    from bh_ptnnn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_bh='M';
select count(*) into b_i1 from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_lt';
if b_i1<>0 then
    select txt into dt_lt from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_lt';
end if;
select count(*) into b_i1 from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_khd';
if b_i1<>0 then
    select txt into dt_khd from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_khd';
end if;
select count(*) into b_i1 from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_kbt';
if b_i1<>0 then
    select txt into dt_kbt from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_kbt';
end if;
select count(*) into b_i1 from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
if b_i1<>0 then
    select txt into dt_ttt from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
end if;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai in('dt_ct','dt_dk','dt_dkbs');
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,
    'dt_lt' value dt_lt,'dt_khd' value dt_khd,'dt_kbt' value dt_kbt,'dt_kytt' value dt_kytt,'dt_ttt' value dt_ttt,
    'dt_ct' value dt_ct,'dt_dk' value dt_dk,'dt_dkbs' value dt_dkbs,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNNNG_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_so_id number; b_so_hd varchar2(20);b_nv varchar2(10);
    b_lenh varchar2(2000); b_loi varchar2(100);
begin
-- Nam - Hoi so ID qua so hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
b_lenh:=FKH_JS_LENH('so_hd,nv');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_nv using b_oraIn;
b_so_id:=FBH_PTNNNG_SO_ID(b_ma_dvi,b_so_hd,b_nv);
if b_so_id=0 then b_loi:='loi:So hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_PTNNNG_SO_ID(b_ma_dvi varchar2,b_so_hd varchar2,b_nv varchar2:='') return number
as
    b_kq number;
begin
-- Nam - Tra so id
if nvl(b_nv,' ')=' ' then 
    select nvl(min(so_id),0) into b_kq from bh_ptnnn where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
else 
    select nvl(min(so_id),0) into b_kq from bh_ptnnn where ma_dvi=b_ma_dvi and so_hd=b_so_hd and nv=b_nv;
end if;
return b_kq;
end;
/
create or replace procedure PBH_PTNNNG_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh varchar2,b_loi out varchar2)
AS
    b_i1 number; b_so_idK number; b_ttrang varchar2(1); b_ksoat varchar2(20); b_nsdC varchar2(20);
begin
-- Nam - Xoa
b_loi:='loi:Loi xu ly PBH_PTNNNG_XOA_XOA:loi';
select count(*) into b_i1 from bh_ptnnn where so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select so_id_kt,ttrang,ksoat,nsd into b_so_idK,b_ttrang,b_ksoat,b_nsdC
    from bh_ptnnn where so_id=b_so_id;
if b_so_idK>0 then b_loi:='loi:Khong sua, xoa phuc hoi da hach toan ke toan:loi'; return; end if;
if b_nsdC<>b_nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
if trim(b_ksoat) is not null and b_ksoat<>b_nsd then b_loi:='loi:Khong sua, xoa GCN, hop dong da kiem soat:loi'; return; end if;
b_loi:='loi:Loi xoa Table bh_ptnnn:loi';
delete bh_hd_goc_ttdt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ptnnn_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ptnnn_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ptnnn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ptnnn where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_ttrang in('T','D') then
    PBH_PTN_GOC_XOA(b_ma_dvi,b_nsd,b_so_id,b_nh,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
