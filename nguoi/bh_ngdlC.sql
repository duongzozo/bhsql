--duchq update length email
create or replace procedure PBH_NGDLC_TESTr(
    b_ma_dvi varchar2,b_nsd varchar2,dt_ct clob,dt_dk clob,dt_dkbs clob,dt_hk clob,

    b_ng_sinhM out number,b_gioiM out varchar2,b_ten out nvarchar2,b_dchi out nvarchar2,
    b_cmt out varchar2,b_mobi out varchar2,b_email out varchar2,
    b_ng_sinh out number,b_gioi out varchar2,b_ma_kh out varchar2,b_ng_huong out nvarchar2,

    b_loai out varchar2,b_kvuc out varchar2,b_ma_sp out varchar2,
    b_cdich out varchar2,b_goi out varchar2,b_ma_chuyen out varchar2,
    b_phiH out number, b_ttoanH out number,b_so_idP out number,

    dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,dk_tc out pht_type.a_var,dk_ma_ct out pht_type.a_var,
    dk_kieu out pht_type.a_var,dk_tien out pht_type.a_num,dk_pt out pht_type.a_num,dk_phi out pht_type.a_num,
    dk_thue out pht_type.a_num,dk_ttoan out pht_type.a_num,
    dk_cap out pht_type.a_num,dk_ma_dk out pht_type.a_var,
    dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,dk_ptB out pht_type.a_num,
    dk_ptG out pht_type.a_num,dk_phiG out pht_type.a_num,
    dk_lkeP out pht_type.a_var,dk_lkeB out pht_type.a_var,dk_luy out pht_type.a_var,dk_lh_bh out pht_type.a_var,b_loi out varchar2)
AS
    b_i1 number; b_ttrang varchar2(1); b_ngay_hl number;b_ngay_kt number; dt_khd clob; b_txt clob;
    b_lenh varchar2(2000); b_kt number; b_loai_khM varchar2(1);
    dk_phiB pht_type.a_num; dk_lkeM pht_type.a_var; dkB_lkeM pht_type.a_var;

    dkB_ma pht_type.a_var; dkB_ten pht_type.a_nvar; dkB_tc pht_type.a_var; dkB_ma_ct pht_type.a_var;
    dkB_tien pht_type.a_num; dkB_pt pht_type.a_num; dkB_phi pht_type.a_num;
    dkB_cap pht_type.a_num; dkB_ma_dk pht_type.a_var; dkB_kieu pht_type.a_var;
    dkB_lh_nv pht_type.a_var; dkB_t_suat pht_type.a_num; dkB_ptB pht_type.a_num;
    dkB_phiB pht_type.a_num;
    dkB_lkeP pht_type.a_var; dkB_lkeB pht_type.a_var; dkB_luy pht_type.a_var;

    hk_nhom pht_type.a_var;hk_maH pht_type.a_var;hk_loaiH pht_type.a_var;hk_tenH pht_type.a_nvar;hk_cmtH pht_type.a_var;
    hk_mobiH pht_type.a_var;hk_emailH pht_type.a_var;hk_qheH pht_type.a_var;hk_so_tkH pht_type.a_var;hk_ma_nhH pht_type.a_var;hk_ten_tkH pht_type.a_var;
begin
-- Dan - Nhap
b_lenh:=FKH_JS_LENH('ttrang,ngay_hl,ngay_kt,loai_kh,ng_sinh,gioi,tend,dchid,cmtd,mobid,emaild,ng_sinhd,gioid,loai,kvuc,ma_sp,cdich,goi,ma_chuyen,ttoan');
EXECUTE IMMEDIATE b_lenh into b_ttrang,b_ngay_hl,b_ngay_kt,b_loai_khM,b_ng_sinhM,b_gioiM,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_ng_sinh,b_gioi,b_loai,b_kvuc,b_ma_sp,b_cdich,b_goi,b_ma_chuyen,b_ttoanH using dt_ct;

if b_loai is null or b_loai not in('N','Q','T','V') then b_loi:='loi:Sai loai:loi'; return; end if;
b_kvuc:=nvl(trim(b_kvuc),' ');
if b_kvuc<>' ' and FBH_NGDL_KVUC_HAN(b_kvuc)<>'C' then
    b_loi:='loi:Ma khu vuc '||b_kvuc||'da het su dung:loi'; raise PROGRAM_ERROR;
end if;
b_ma_sp:=nvl(trim(b_ma_sp),' ');
if b_ma_sp<>' ' and FBH_NGDL_SP_HAN(b_ma_sp)<>'C' then
    b_loi:='loi:Ma san pham '||b_ma_sp||'da het su dung:loi'; raise PROGRAM_ERROR;
end if;
b_cdich:=PKH_MA_TENl(b_cdich); 
if b_cdich<>' ' and FBH_MA_CDICH_HAN(b_cdich)<>'C' then
    b_loi:='loi:Da het chien dich:loi'; raise PROGRAM_ERROR;
end if;
b_goi:=PKH_MA_TENl(b_goi);
if b_goi<>' ' and FBH_NGDL_GOI_HAN(b_goi)<>'C' then
    b_loi:='loi:Ma goi da het su dung:loi'; raise PROGRAM_ERROR;
end if;
b_so_idP:=FBH_NGDL_BPHI_SO_ID('C',b_loai,b_kvuc,b_ma_sp,b_cdich,b_goi,b_ngay_hl);
if b_so_idP=0 then b_loi:='loi:Khong co bieu phi phu hop tham so nhap:loi'; return; end if;

b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,tien,pt,phi,cap,ma_dk,kieu,lh_nv,t_suat,ptb,phib,lkem,lkep,lkeb,luy');
EXECUTE IMMEDIATE b_lenh bulk collect into
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_tien,dk_pt,dk_phi,dk_cap,dk_ma_dk,dk_kieu,
    dk_lh_nv,dk_t_suat,dk_ptB,dk_phiB,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy using dt_dk;
b_kt:=dk_ma.count;
if b_kt=0 then b_loi:='loi:Nhap dieu khoan:loi'; return; end if;
for b_lp in 1..b_kt loop
    dk_ma(b_lp):=nvl(trim(dk_ma(b_lp)),' '); dk_lh_bh(b_lp):='C';
    if dk_ma(b_lp)=' ' then b_loi:='loi:Nhap dieu khoan chinh dong '||to_char(b_lp)||':loi'; return; end if;
end loop;
if trim(dt_dkbs) is not null then
    EXECUTE IMMEDIATE b_lenh bulk collect into
        dkB_ma,dkB_ten,dkB_tc,dkB_ma_ct,dkB_tien,dkB_pt,dkB_phi,dkB_cap,dkB_ma_dk,dkB_kieu,
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
    dk_thue(b_lp):=0; dk_phiB(b_lp):=nvl(dk_phiB(b_lp),0); dk_tien(b_lp):=nvl(dk_tien(b_lp),0);
    if dk_tien(b_lp)=0 and dk_lkeM(b_lp) not in ('T','N','K') and dk_kieu(b_lp)='T' then 
      b_loi:='loi:Chua nhap muc trach nhiem dieu khoan '||dk_ma(b_lp)||':loi'; return; 
    end if;
    if dk_tien(b_lp)<>0 then
      b_i1:=round(dk_phiB(b_lp)/dk_tien(b_lp)*100,4); 
      dk_pt(b_lp):= b_i1 - round(((dk_phiB(b_lp)/dk_tien(b_lp))-(dk_phi(b_lp)/dk_tien(b_lp)))*100 ,4);
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
b_phiH:=b_ttoanH; b_ng_huong:=''; b_ma_kh:=' ';
if b_ttrang in('T','D') then
    select json_object('loai' value 'C','ten' value b_ten,'cmt' value b_cmt,
        'dchi' value b_dchi,'mobi' value b_mobi,'email' value b_email,
        'gioi' value b_gioi,'ng_sinh' value b_ng_sinh) into b_txt from dual;
    PBH_DTAC_MA_NH(b_txt,b_ma_kh,b_loi,b_ma_dvi,b_nsd);
    if b_loai_khM='T' and b_ma_kh in(' ','VANGLAI') then
        b_loi:='loi:Thieu thong tin nguoi duoc bao hiem:loi'; return;
    end if;
    b_lenh:=FKH_JS_LENH('nhom,maH,loaiH,tenH,cmtH,mobiH,emailH,qheH,so_tkH,ma_nhH,ten_tkH');
    EXECUTE IMMEDIATE b_lenh bulk collect into hk_nhom,hk_maH,hk_loaiH,hk_tenH,hk_cmtH,hk_mobiH,hk_emailH,hk_qheH,hk_so_tkH,hk_ma_nhH,hk_ten_tkH using dt_hk;
    for b_lp in 1..hk_tenH.count loop
        if trim(hk_tenH(b_lp)) is not null then
          select json_object('loai' value hk_loaiH(b_lp),'ten' value hk_tenH(b_lp),'cmt' value hk_cmtH(b_lp),
              'mobi' value hk_mobiH(b_lp),'email' value hk_emailH(b_lp)) into b_txt from dual;
          PBH_DTAC_MA_NH(b_txt,hk_maH(b_lp),b_loi,b_ma_dvi,b_nsd);
          b_ng_huong:=hk_tenH(b_lp);
          if trim(hk_cmtH(b_lp)) is not null then
              if hk_loaiH(b_lp)='C' then
                  b_ng_huong:=hk_tenH(b_lp)||', so CMT/CCCD: '||hk_cmtH(b_lp);
              else
                  b_ng_huong:=hk_tenH(b_lp)||', ma thue/so GPTL : '||hk_cmtH(b_lp);
              end if;
          end if;
          --if trim(b_dchiH) is not null then
          --    b_ng_huong:=hk_tenH(b_lp)||', dia chi: '||b_dchiH;
          --end if;
      end if;
    end loop;

    select count(*) into b_i1 from bh_ngdl_phi_txt where so_id=b_so_idP and loai='dt_khd';
    if b_i1<>0 then
        select txt into dt_khd from bh_ngdl_phi_txt where so_id=b_so_idP and loai='dt_khd';
        b_i1:=length(dt_khd)-2;
        dt_khd:=substr(dt_khd,2,b_i1);
        PBH_NGDL_KHD(dt_ct,dt_khd,b_loi);
        if b_loi is not null then return; end if;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_NGDLC_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    dt_ct in out clob,dt_dk clob,dt_dkbs clob, dt_hk clob, dt_ttt clob, dt_gchu clob,

    b_so_hd varchar2,b_ngay_ht number,b_ttrang varchar2,b_kieu_hd varchar2,b_so_hd_g varchar2,
    b_kieu_kt varchar2,b_ma_kt varchar2,b_kieu_gt varchar2,b_ma_gt varchar2,b_ma_cb varchar2,
    b_so_hdL varchar2,b_loai_kh varchar2,b_ma_kh varchar2,b_ten nvarchar2,b_dchi nvarchar2,
    b_cmt varchar2,b_mobi varchar2,b_email varchar2,
    b_gio_hl varchar2,b_ngay_hl number,b_gio_kt varchar2,b_ngay_kt number,b_ngay_cap number,
    b_nt_tien varchar2,b_nt_phi varchar2,b_c_thue varchar2,
    b_phi number,b_giam number,b_thue number,b_ttoan number,b_hhong number,
    b_so_idG number,b_so_idD number,b_ngayD number,b_phong varchar2,
    tt_ngay pht_type.a_num,tt_tien pht_type.a_num,

    b_ng_sinh number,b_gioi varchar2,
    b_tenD nvarchar2,b_dchiD nvarchar2,b_cmtD varchar2,b_mobiD varchar2,b_emailD varchar2,
    b_ng_sinhD number,b_gioiD varchar2,b_ma_khD varchar2,b_ng_huong nvarchar2,
    b_loai varchar2,b_kvuc varchar2,b_ma_sp varchar2,b_cdich varchar2,b_goi varchar2,b_ma_chuyen varchar2,b_so_idP number,

    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tc pht_type.a_var,dk_ma_ct pht_type.a_var,
    dk_kieu pht_type.a_var,dk_tien pht_type.a_num,dk_pt pht_type.a_num,dk_phi pht_type.a_num,
    dk_thue pht_type.a_num,dk_ttoan pht_type.a_num,dk_cap pht_type.a_num,dk_ma_dk pht_type.a_var,
    dk_lh_nv pht_type.a_var,dk_t_suat pht_type.a_num,dk_ptB pht_type.a_num,dk_ptG pht_type.a_num,dk_phiG pht_type.a_num,
    dk_lkeP pht_type.a_var,dk_lkeB pht_type.a_var,dk_luy pht_type.a_var,dk_lh_bh pht_type.a_var,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_i1 number; b_tien number;
    b_ps varchar2(1); b_so_id_kt number:=-1; b_ma_ke varchar2(20):=' ';
    dt_lt clob; dt_khd clob; dt_kbt clob; dt_cho clob; dt_bvi clob; b_txt clob;
begin
-- Dan - Nhap
b_loi:='loi:Loi Table BH_NGDL:loi';
if b_ttrang='D' then b_so_id_kt:=0; end if;
if b_ma_khD in(' ','VANGLAI') then
    insert into bh_ngdl_ds values(b_ma_dvi,b_so_id,b_so_id,0,b_kieu_hd,b_so_hd,b_so_hd_g,
        b_ten,b_ng_sinh,b_gioi,b_cmt,b_mobi,b_email,b_dchi,
        b_ng_huong,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_loai,b_kvuc,
        b_ma_sp,b_cdich,b_goi,b_so_idP,' ',b_ma_chuyen,b_phi,b_giam,b_ttoan,b_ma_kh);
else
    insert into bh_ngdl_ds values(b_ma_dvi,b_so_id,b_so_id,0,b_kieu_hd,b_so_hd,b_so_hd_g,
        b_tenD,b_ng_sinhD,b_gioiD,b_cmtD,b_mobiD,b_emailD,b_dchiD,
        b_ng_huong,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_loai,b_kvuc,b_ma_sp,b_cdich,b_goi
        ,b_so_idP,' ',b_ma_chuyen,b_phi,b_giam,b_ttoan,b_ma_khD);
end if;
for b_lp in 1..dk_lh_nv.count loop
    if dk_kieu(b_lp)='T' and dk_lh_nv(b_lp)<>' ' then b_tien:=b_tien+dk_tien(b_lp); end if;
    insert into bh_ngdl_dk values(b_ma_dvi,b_so_id,b_so_id,b_lp,
        dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),dk_kieu(b_lp),
        dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),dk_cap(b_lp),dk_ma_dk(b_lp),
        dk_lh_nv(b_lp),dk_t_suat(b_lp),dk_thue(b_lp),dk_ttoan(b_lp),
        dk_ptB(b_lp),dk_ptG(b_lp),dk_phiG(b_lp),dk_lkeP(b_lp),dk_lkeB(b_lp),dk_luy(b_lp),dk_lh_bh(b_lp));
end loop;
insert into bh_ngdl values(
    b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,'C',b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
    b_phong,b_so_hdL,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,
    b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,'K',1,'C',b_tien,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,'','',b_so_id_kt,b_nsd,sysdate);
PKH_JS_THAYa(dt_ct,'so_hd,ma_kh',b_so_hd||','||b_ma_kh);
if trim(b_ma_khD) is not null then PKH_JS_THAY(dt_ct,'ma_khD',b_ma_khD); end if;
insert into bh_ngdl_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
insert into bh_ngdl_txt values(b_ma_dvi,b_so_id,'dt_dk',dt_dk);
if trim(dt_hk) is not null then
    insert into bh_ngdl_txt values(b_ma_dvi,b_so_id,'dt_hk',dt_hk);
end if;
if trim(dt_dkbs) is not null then
    insert into bh_ngdl_txt values(b_ma_dvi,b_so_id,'dt_dkbs',dt_dkbs);
end if;
if trim(dt_ttt) is not null then
    insert into bh_ngdl_txt values(b_ma_dvi,b_so_id,'dt_ttt',dt_ttt);
end if;
if trim(dt_gchu) is not null then
    insert into bh_ngdl_txt values(b_ma_dvi,b_so_id,'dt_gchu',dt_gchu);
end if;
for b_lp in 1..tt_ngay.count loop
    insert into bh_ngdl_tt values(b_ma_dvi,b_so_id,tt_ngay(b_lp),tt_tien(b_lp));
end loop;
if b_ttrang in('T','D') then
    if dt_dkbs is null then
        b_txt:=dt_dk;
    else
        b_i1:=length(dt_dk)-1;
        b_txt:=substr(dt_dk,1,b_i1)||','||substr(dt_dkbs,2);
    end if;
    PBH_NGDL_BPHI_CTk(b_so_idP,dt_lt,dt_khd,dt_kbt,dt_cho,dt_bvi);
    insert into bh_ng_kbt values(b_ma_dvi,b_so_id,b_so_idD,b_txt,dt_lt,dt_kbt);
    insert into bh_ng values(
        b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,'DLC',b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
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
            b_ten,b_ng_sinh,b_gioi,b_cmt,b_mobi,b_email,b_dchi,' ',
            b_ng_huong,b_ma_sp,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_so_idP,b_phi,b_giam,b_ttoan,' ',b_ma_kh);
    else
        insert into bh_ng_ds values(b_ma_dvi,b_so_id,b_so_id,b_kieu_hd,b_so_hd,b_so_hd_g,
            b_tenD,b_ng_sinhD,b_gioiD,b_cmtD,b_mobiD,b_emailD,b_dchiD,' ',
            b_ng_huong,b_ma_sp,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_so_idP,b_phi,b_giam,b_ttoan,' ',b_ma_khD);
    end if;
    insert into bh_ng_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
    PBH_NG_GOC_NH(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
end if;
if b_ttrang='D' then
    PBH_KE_CTI_NHOM(b_ma_dvi,b_so_idD,b_so_idD,b_ma_ke,b_loi);
    if b_loi is not null then return; end if;
    insert into bh_hd_goc_ttindt values(b_ma_dvi,b_so_idD,b_so_idD,'NG',b_ten,b_ma_kh,b_ngay_kt,' ',b_ma_ke);
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
--duchq update length email
create or replace procedure PBH_NGDLC_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_i1 number;
    dt_ct clob; dt_dk clob; dt_dkbs clob; dt_kytt clob; dt_ttt clob; dt_hk clob; dt_gchu clob;
    dt_cho clob; dt_bvi clob;
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
    b_ng_sinh number; b_gioi varchar2(1);
    b_tenD nvarchar2(50); b_dchiD nvarchar2(500); b_cmtD varchar2(20); b_mobiD varchar2(20); b_emailD varchar2(100);
    b_ng_sinhD number; b_gioiD varchar2(1); b_ma_khD varchar2(20); b_ng_huong nvarchar2(500);
    b_loai varchar2(10); b_kvuc varchar2(10); b_ma_sp varchar2(10);
    b_cdich varchar2(200); b_goi varchar2(200); b_ma_chuyen varchar2(20);

    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var; dk_ma_ct pht_type.a_var;
    dk_kieu pht_type.a_var; dk_tien pht_type.a_num; dk_pt pht_type.a_num; dk_phi pht_type.a_num;
    dk_thue pht_type.a_num; dk_ttoan pht_type.a_num;
    dk_cap pht_type.a_num; dk_ma_dk pht_type.a_var; dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num;
    dk_ptB pht_type.a_num; dk_ptG pht_type.a_num; dk_phiG pht_type.a_num;
    dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var; dk_luy pht_type.a_var; dk_lh_bh pht_type.a_var;
-- xu ly
    b_ngay_htC number; b_so_idP number;
begin
-- Dan - Nhap
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_dkbs,dt_kytt,dt_ttt,dt_hk,dt_cho,dt_bvi');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_dkbs,dt_kytt,dt_ttt,dt_hk,dt_cho,dt_bvi using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_kytt); FKH_JSa_NULL(dt_ttt); FKH_JSa_NULL(dt_hk);
FKH_JSa_NULL(dt_cho); FKH_JSa_NULL(dt_bvi);
if b_so_id<>0 then
    select count(*) into b_i1 from bh_ngdl where so_id=b_so_id;
    if b_i1<>0 then
        select ngay_ht,kieu_hd,ttrang into b_ngay_htC,b_kieu_hd,b_ttrang from bh_ngdl
            where so_id=b_so_id for update nowait;
        if sql%rowcount=0 then b_loi:='loi:Va cham NSD:loi'; raise PROGRAM_ERROR; end if;
        if b_ttrang not in('T','D') then b_kieu_hd:='X'; else b_kieu_hd:='N'; end if;
        PBH_NGDL_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_kieu_hd,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
else
    PHT_ID_MOI(b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_HD_JS_TEST(
    b_ma_dvi,b_nsd,b_so_id,b_ngay_htC,'bh_ngdl',dt_ct,dt_kytt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_loai_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,
    b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_ngayD,b_phong,b_ma_cb,b_ma_kh,
    tt_ngay,tt_tien,b_loi,'NG');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_NGDLC_TESTr(
    b_ma_dvi,b_nsd,dt_ct,dt_dk,dt_dkbs,dt_hk,b_ng_sinh,b_gioi,b_tenD,b_dchiD,
    b_cmtD,b_mobiD,b_emailD,b_ng_sinhD,b_gioiD,b_ma_khD,b_ng_huong,
    b_loai,b_kvuc,b_ma_sp,b_cdich,b_goi,b_ma_chuyen,b_phi,b_ttoan,b_so_idP,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,
    dk_cap,dk_ma_dk,dk_lh_nv,dk_t_suat,dk_ptB,dk_ptG,dk_phiG,
    dk_lkeP,dk_lkeB,dk_luy,dk_lh_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_NGDLC_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,dt_ct,dt_dk,dt_dkbs,dt_hk,dt_ttt,dt_gchu,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,b_so_hdL,
    b_loai_kh,b_ma_kh,b_ten,b_dchi, b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,
    b_nt_tien,b_nt_phi,b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_ngayD,b_phong,
    tt_ngay,tt_tien,
    b_ng_sinh,b_gioi,b_tenD,b_dchiD,b_cmtD,b_mobiD,b_emailD,b_ng_sinhD,b_gioiD,b_ma_khD,b_ng_huong,
    b_loai,b_kvuc,b_ma_sp,b_cdich,b_goi,b_ma_chuyen,b_so_idP,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,dk_cap,dk_ma_dk,
    dk_lh_nv,dk_t_suat,dk_ptB,dk_ptG,dk_phiG,dk_lkeP,dk_lkeB,dk_luy,dk_lh_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hd' value b_so_hd, 'ma_kh' value b_ma_kh) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGDLC_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_ngay number:=PKH_NG_CSO(sysdate);
    cs_kvuc clob; cs_sp clob; cs_cdich clob; cs_goi clob; cs_ttt clob; cs_khd clob; cs_kbt clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ten) into cs_kvuc from bh_ngdl_kvuc where FBH_NGDL_KVUC_HAN(ma)='C';
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten) into cs_sp from
    bh_ngdl_sp a,(select distinct ma_sp from bh_ngdl_phi where nhom='C' and ngay_bd<=b_ngay and ngay_kt>b_ngay) b
    where a.ma=b.ma_sp and FBH_NGDL_SP_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten) into cs_cdich from
    bh_ma_cdich a,(select distinct cdich from bh_ngdl_phi where nhom='C' and ngay_bd<=b_ngay and ngay_kt>b_ngay) b
    where a.ma=b.cdich and FBH_MA_NV_CO(nv,'NG')='C' and FBH_MA_CDICH_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ma) into cs_goi from
    bh_ngdl_goi a,(select distinct goi from bh_ngdl_phi where nhom='C' and FBH_NGDL_SP_HAN(ma_sp)='C' and b_ngay between ngay_bd and ngay_kt) b
    where a.ma=b.goi;
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_ttt
    from bh_kh_ttt where ps='HD' and nv='NG';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt) into cs_khd from bh_kh_ttt where ps='KHD' and FBH_MA_NV_CO(nv,'NG')='C';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt) into cs_kbt from bh_kh_ttt where ps='KBT' and FBH_MA_NV_CO(nv,'NG')='C';

select json_object('cs_kvuc' value cs_kvuc,'cs_sp' value cs_sp,'cs_cdich' value cs_cdich,'cs_goi' value cs_goi,'cs_ttt' value cs_ttt,
                   'cs_khd' value cs_khd,'cs_kbt' value cs_kbt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGDLC_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number; b_so_idP number;
    dt_ct clob; dt_dk clob; dt_dkbs clob; dt_lt clob; dt_khd clob; dt_kbt clob; dt_kytt clob; dt_ttt clob; dt_gchu clob; 
    dt_hk clob; dt_txt clob; dt_cho clob; dt_bvi clob;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
if b_so_id=0 then b_loi:='loi:GCN/Hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
b_so_idP:=FBH_NGDL_SO_IDp(b_ma_dvi,b_so_id);
select json_object(so_hd,ma_kh) into dt_ct from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_id;
select txt into dt_dk from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dk';
select count(*) into b_i1 from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dkbs';
if b_i1=1 then
    select txt into dt_dkbs from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dkbs';
end if;
PBH_NGDL_BPHI_CTk(b_so_idP,dt_lt,dt_khd,dt_kbt,dt_cho,dt_bvi);
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai not in('dt_lt','dt_khd','dt_kbt');
select JSON_ARRAYAGG(json_object(ngay,tien) order by ngay) into dt_kytt from bh_ngdl_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select count(*) into b_i1 from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
if b_i1<>0 then
    select txt into dt_ttt from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
end if;
select count(*) into b_i1 from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_gchu';
if b_i1<>0 then
    select txt into dt_gchu from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_gchu';
end if;
select count(*) into b_i1 from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
if b_i1<>0 then
    select txt into dt_hk from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_idP' value b_so_idP,
    'dt_dk' value dt_dk,'dt_dkbs' value dt_dkbs,'dt_lt' value dt_lt,'dt_khd' value dt_khd,'dt_hk' value dt_hk,
    'dt_kbt' value dt_kbt,'dt_ct' value dt_ct,'dt_kytt' value dt_kytt, 'dt_ttt' value dt_ttt, 'dt_gchu' value dt_gchu,
    'dt_cho' value dt_cho,'dt_bvi' value dt_bvi,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
