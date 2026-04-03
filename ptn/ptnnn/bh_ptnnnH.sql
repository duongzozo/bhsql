create or replace procedure PBH_PTNNNH_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_ngay number:=PKH_NG_CSO(sysdate);
    cs_sp clob; cs_cdich clob; cs_nghe clob;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten returning clob) into cs_sp from
    bh_ptnnn_sp a,(select distinct ma_sp from bh_ptnnn_phi where nhom='H' and ngay_bd<=b_ngay and ngay_kt>b_ngay and nhom='H') b
  where a.ma=b.ma_sp and FBH_PTNNN_SP_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten returning clob) into cs_cdich from
    bh_ma_cdich a,(select distinct cdich from bh_ptnnn_phi where nhom='H' and ngay_bd<=b_ngay and ngay_kt>b_ngay and nhom='H') b
  where a.ma=b.cdich;
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten returning clob) into cs_nghe from
    bh_ma_nghe a,(select distinct nghe from bh_ptnnn_phi where nhom='H' and ngay_bd<=b_ngay and ngay_kt>b_ngay and nhom='H') b
  where a.ma=b.nghe;
select json_object('cs_sp' value cs_sp,'cs_cdich' value cs_cdich,'cs_nghe' value cs_nghe) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNNNH_MOd(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_ngay number:=PKH_NG_CSO(sysdate);
    b_loi varchar2(100); cs_pvi clob; cs_khd clob; cs_kbt clob; cs_ttt clob;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten) into cs_pvi from
    bh_ptnnn_pvi a,(select distinct pvi from bh_ptnnn_phi where ngay_bd<=b_ngay and ngay_kt>b_ngay) b
  where a.ma=b.pvi;
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt) into cs_khd from bh_kh_ttt where ps='KHD' and nv='PTN';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt) into cs_kbt from bh_kh_ttt where ps='KBT' and nv='PTN';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra returning clob) order by bt returning clob) into cs_ttt
    from bh_kh_ttt where ps='HD' and nv='PTN';
select json_object('cs_pvi' value cs_pvi,'cs_khd' value cs_khd,'cs_kbt' value cs_kbt,'cs_ttt' value cs_ttt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNNNH_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number;
    dt_ct clob; dt_hk clob:=''; ds_ct clob; ds_dk clob; ds_dkbs clob:=''; ds_lt clob:='';
    ds_kbt clob:=''; ds_ttt clob:=''; dt_kytt clob; dt_txt clob;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','PTN','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
select json_object(so_hd,ma_kh) into dt_ct from bh_ptnnn where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ngay,tien) order by ngay) into dt_kytt from bh_ptnnn_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select count(*) into b_i1 from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
if b_i1=1 then
    select txt into dt_hk from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
end if;
select txt into ds_ct from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ct';
select txt into ds_dk from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_dk';
select count(*) into b_i1 from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_dkbs';
if b_i1=1 then
    select txt into ds_dkbs from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_dkbs';
end if;
select count(*) into b_i1 from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_lt';
if b_i1=1 then
    select txt into ds_lt from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_lt';
end if;
select count(*) into b_i1 from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_kbt';
if b_i1=1 then
    select txt into ds_kbt from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_kbt';
end if;
select count(*) into b_i1 from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ttt';
if b_i1=1 then
    select txt into ds_ttt from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ttt';
end if;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'ds_ct' value ds_ct,
    'dt_hk' value dt_hk,'ds_dk' value ds_dk,'ds_dkbs' value ds_dkbs,'ds_lt' value ds_lt,
    'ds_kbt' value ds_kbt,'ds_ttt' value ds_ttt,'dt_kytt' value dt_kytt,
    'dt_ct' value dt_ct,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNNNH_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    dt_ct in out clob,ds_ct clob,dt_hk clob,ds_dk clob,ds_dkbs clob,ds_lt clob,ds_kbt clob, dt_ttt clob,
    b_so_hd varchar2,b_ngay_ht number,b_ttrang varchar2,b_kieu_hd varchar2,b_so_hd_g varchar2,
    b_kieu_kt varchar2,b_ma_kt varchar2,b_kieu_gt varchar2,b_ma_gt varchar2,b_ma_cb varchar2,
    b_so_hdL varchar2,b_loai_kh varchar2,b_ma_kh varchar2,b_ten nvarchar2,b_dchi nvarchar2,
    b_cmt varchar2,b_mobi varchar2,b_email varchar2,
    b_gio_hl varchar2,b_ngay_hl number,b_gio_kt varchar2,b_ngay_kt number,b_ngay_cap number,
    b_nt_tien varchar2,b_nt_phi varchar2,b_c_thue varchar2,
    b_phi number,b_giam number,b_thue number,b_ttoan number,b_hhong number,
    b_so_idG number,b_so_idD number,b_phong varchar2,
    tt_ngay pht_type.a_num,tt_tien pht_type.a_num,

    b_ma_sp varchar2,b_cdich varchar2,b_nghe varchar2,
    dvi_so_id pht_type.a_num, dvi_kieu_gcn pht_type.a_var, dvi_gcn pht_type.a_var, dvi_gcnG pht_type.a_var,
    dvi_pvi pht_type.a_var, dvi_dtuong pht_type.a_nvar, dvi_ngay_hoi pht_type.a_num,
    dvi_gio_hl pht_type.a_var, dvi_ngay_hl pht_type.a_num, dvi_gio_kt pht_type.a_var, dvi_ngay_kt pht_type.a_num,
    dvi_ngay_cap pht_type.a_num, dvi_phi pht_type.a_num, dvi_thue pht_type.a_num, dvi_ttoan pht_type.a_num,
    dvi_so_idP pht_type.a_num,

    dk_so_id pht_type.a_num,dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tc pht_type.a_var,dk_ma_ct pht_type.a_var,
    dk_kieu pht_type.a_var,dk_tien pht_type.a_num,dk_pt pht_type.a_num,dk_phi pht_type.a_num,
    dk_thue pht_type.a_num,dk_ttoan pht_type.a_num,dk_cap pht_type.a_num,dk_ma_dk pht_type.a_var,
    dk_lh_nv pht_type.a_var,dk_t_suat pht_type.a_num,dk_ptB pht_type.a_num,dk_phiB pht_type.a_num,
    dk_ptG pht_type.a_num,dk_phiG pht_type.a_num,dk_lkeM pht_type.a_var,dk_lkeP pht_type.a_var,dk_lkeB pht_type.a_var,
    dk_luy pht_type.a_var,dk_lh_bh pht_type.a_var,
    lt_so_id pht_type.a_num,lt_lt pht_type.a_clob,lt_kbt pht_type.a_clob,b_loi out varchar2)

AS
    b_so_dt number; b_so_id_kt number:=-1; b_tien number:=0; b_ma_ke varchar2(20);
    b_txt clob; b_txt_lt clob;
begin
-- Nam - Nhap
b_loi:='loi:Loi Table bh_ptnnn:loi';
if b_ttrang='D' then b_so_id_kt:=0; end if;
b_so_dt:=dvi_so_id.count;
for b_lp in 1..dk_lh_nv.count loop
    if dk_lh_nv(b_lp)<>' ' and dk_kieu(b_lp)='T' then b_tien:=b_tien+dk_tien(b_lp); end if;
    insert into bh_ptnnn_dk values(b_ma_dvi,b_so_id,dk_so_id(b_lp),b_lp,
        dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),dk_kieu(b_lp),
        dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),dk_cap(b_lp),dk_ma_dk(b_lp),
        dk_lh_nv(b_lp),dk_t_suat(b_lp),dk_thue(b_lp),dk_ttoan(b_lp),
        dk_ptB(b_lp),dk_ptG(b_lp),dk_phiG(b_lp),dk_lkeM(b_lp),dk_lkeP(b_lp),dk_lkeB(b_lp),dk_luy(b_lp),dk_lh_bh(b_lp));
end loop;
insert into bh_ptnnn values(
        b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,'H',b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,
        b_ma_gt,b_ma_cb,b_phong,b_so_hdL,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,
        b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,b_ma_sp,b_cdich,b_nghe,b_so_dt,b_tien,b_phi,
        b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,'','',b_so_id_kt,b_nsd,sysdate);
for b_lp in 1..dvi_so_id.count loop
  insert into bh_ptnnn_dvi values(
        b_ma_dvi,b_so_id,dvi_so_id(b_lp),b_lp,dvi_kieu_gcn(b_lp),dvi_gcn(b_lp),dvi_gcnG(b_lp),dvi_pvi(b_lp),
        dvi_dtuong(b_lp),dvi_gio_hl(b_lp),dvi_ngay_hl(b_lp),
        dvi_gio_kt(b_lp),dvi_ngay_kt(b_lp),dvi_ngay_cap(b_lp),dvi_ngay_hoi(b_lp),dvi_so_idP(b_lp),
        dvi_phi(b_lp),dvi_thue(b_lp),dvi_ttoan(b_lp));
end loop;
PKH_JS_THAYa(dt_ct,'so_hd,ma_kh',b_so_hd||','||b_ma_kh);
insert into bh_ptnnn_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
insert into bh_ptnnn_txt values(b_ma_dvi,b_so_id,'ds_ct',ds_ct);
insert into bh_ptnnn_txt values(b_ma_dvi,b_so_id,'ds_dk',ds_dk);
if ds_dkbs is not null then
    insert into bh_ptnnn_txt values(b_ma_dvi,b_so_id,'ds_dkbs',ds_dkbs);
end if;
if dt_hk is not null then
    insert into bh_ptnnn_txt values(b_ma_dvi,b_so_id,'dt_hk',dt_hk);
end if;
if dt_ttt is not null then
    insert into bh_ptnnn_txt values(b_ma_dvi,b_so_id,'dt_ttt',dt_ttt);
end if;
if ds_lt is not null then
    insert into bh_ptnnn_txt values(b_ma_dvi,b_so_id,'ds_lt',ds_lt);
end if;
if ds_kbt is not null then
    insert into bh_ptnnn_txt values(b_ma_dvi,b_so_id,'ds_kbt',ds_kbt);
end if;
for b_lp in 1..tt_ngay.count loop
    insert into bh_ptnnn_tt values(b_ma_dvi,b_so_id,tt_ngay(b_lp),tt_tien(b_lp));
end loop;
-- Di tiep
if b_kieu_hd<>'U' and b_ttrang in('T','D') then
    for b_lp in 1..lt_so_id.count loop
        select JSON_ARRAYAGG(json_object(
            ma,ten,tc,ma_ct,kieu,tien,pt,phi,cap,ma_dk,lh_nv,t_suat,thue,ttoan,ptB,ptG,phiG,lkeM,lkeP,lkeB,luy)
            order by bt returning clob) into b_txt
            from bh_ptn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=lt_so_id(b_lp);
        if trim(lt_lt(b_lp)) is not null then b_txt_lt:=lt_lt(b_lp); else b_txt_lt:=ds_lt; end if;
        insert into bh_ptn_kbt values(b_ma_dvi,b_so_id,lt_so_id(b_lp),b_txt,b_txt_lt,lt_kbt(b_lp));
    end loop;
    for b_lp in 1..dvi_dtuong.count loop
        insert into bh_hd_goc_ttindt values(b_ma_dvi,b_so_idD,dvi_so_id(b_lp),'PTN',
            dvi_dtuong(b_lp),b_ma_kh,dvi_ngay_kt(b_lp),' ',' ');
    end loop;
  insert into bh_ptn values(
        b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,'TNNN','H',b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
        b_phong,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,
        b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,b_ma_sp,b_cdich,b_so_dt,b_phi,b_tien,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,'','',b_so_id_kt,b_nsd);
  for b_lp in 1..tt_ngay.count loop
      insert into bh_ptn_tt values(b_ma_dvi,b_so_id,tt_ngay(b_lp),tt_tien(b_lp));
  end loop;
  for b_lp in 1..dvi_so_id.count loop
    insert into bh_ptn_dvi values(
          b_ma_dvi,b_so_id,dvi_so_id(b_lp),b_lp,dvi_kieu_gcn(b_lp),dvi_gcn(b_lp),dvi_gcnG(b_lp),dvi_dtuong(b_lp),
          dvi_gio_hl(b_lp),dvi_ngay_hl(b_lp),dvi_gio_kt(b_lp),dvi_ngay_kt(b_lp),dvi_ngay_cap(b_lp),
          dvi_ngay_hoi(b_lp),dvi_so_idP(b_lp),dvi_phi(b_lp),dvi_thue(b_lp),dvi_ttoan(b_lp));
  end loop;
  for b_lp in 1..dk_lh_nv.count loop
    insert into bh_ptn_dk values(b_ma_dvi,b_so_id,dk_so_id(b_lp),b_lp,
      dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),dk_kieu(b_lp),dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),
      dk_cap(b_lp),dk_ma_dk(b_lp),dk_lh_nv(b_lp),dk_t_suat(b_lp),dk_thue(b_lp),dk_ttoan(b_lp),
      dk_ptB(b_lp),dk_ptG(b_lp),dk_phiG(b_lp),dk_lkeM(b_lp),dk_lkeP(b_lp),dk_lkeB(b_lp),dk_luy(b_lp),dk_lh_bh(b_lp));
  end loop;
  insert into bh_ptn_txt values(b_ma_dvi,b_so_id,'dt_hk',dt_hk);
  insert into bh_ptn_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
    select json_object('ma_dvi' value b_ma_dvi,'nsd' value b_nsd,'so_id' value b_so_id,'so_hd' value b_so_hd,
        'kieu_hd' value b_kieu_hd,'nv' value 'PTN','ngay_ht' value b_ngay_ht,'ngay_cap' value b_ngay_cap,
        'ngay_hl' value b_ngay_hl,'ngay_kt' value b_ngay_kt,'cb_ql' value b_ma_cb,'phong' value b_phong,
        'kieu_kt' value b_kieu_kt,'ma_kt' value b_ma_kt,'dly_tke' value ' ','hhong' value b_hhong,
        'pt_hhong' value 'D','ma_kh' value b_ma_kh,'ten' value b_ten,'kieu_gt' value b_kieu_gt,
        'ma_gt' value b_ma_gt,'so_id_d' value b_so_idD,'so_id_g' value b_so_idG,'ttrang' value b_ttrang,
        'dvi_ksoat' value b_ma_dvi,'ksoat' value b_nsd,'bangg' value 'bh_ptnnn,bh_ptnnn,bh_ptnvc',
        'c_thue' value b_c_thue,'nt_tien' value b_nt_tien,'nt_phi' value b_nt_phi,'tien' value b_tien,
        'phi' value b_ttoan-b_thue,'thue' value b_thue returning clob) into b_txt from dual;
    PBH_HD_GOC_NH(b_txt,b_loi);
    if b_loi is not null then return; end if;
end if;
if b_ttrang='D' and b_kieu_hd<>'U' then
    for b_lp in 1..dvi_so_id.count loop
        PBH_KE_CTI_NHOM(b_ma_dvi,b_so_idD,dvi_so_id(b_lp),b_ma_ke,b_loi);
        if b_loi is null then return; end if;
        insert into bh_hd_goc_ttindt values(
            b_ma_dvi,b_so_id,dvi_so_id(b_lp),'PTN',dvi_dtuong(b_lp),b_ma_kh,dvi_ngay_kt(b_lp),'',b_ma_ke);
    end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PTNNNH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(1000); b_lenh varchar2(2000); b_i1 number;
    dt_ct clob; dt_hk clob; dt_kytt clob;
    ds_ct clob; ds_dk clob; ds_dkbs clob; ds_lt clob; ds_kbt clob; ds_ttt clob;
--  Chung
    b_so_id number; b_so_hd varchar2(20); b_ngay_ht number; b_ttrang varchar2(1); b_kieu_hd varchar2(1); b_so_hd_g varchar2(20);
    b_kieu_kt varchar2(1); b_ma_kt varchar2(20); b_kieu_gt varchar2(1); b_ma_gt varchar2(20); b_ma_cb varchar2(20);
    b_so_hdL varchar2(20); b_loai_kh varchar2(1); b_ma_kh varchar2(20); b_ten nvarchar2(500); b_dchi nvarchar2(500);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_gio_hl varchar2(20); b_ngay_hl number; b_gio_kt varchar2(20); b_ngay_kt number; b_ngay_cap number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_c_thue varchar2(1);
    b_phi number; b_giam number; b_thue number; b_ttoan number; b_hhong number;
    b_so_idG number; b_so_idD number; b_ngayD number; b_phong varchar2(10);
    -- thanh toan phi
    tt_ngay pht_type.a_num; tt_tien pht_type.a_num;
--  Rieng
    b_ma_sp varchar2(10); b_cdich varchar2(10); b_nghe varchar2(10);

    dvi_so_id pht_type.a_num; dvi_kieu_gcn pht_type.a_var; dvi_gcn pht_type.a_var; dvi_gcnG pht_type.a_var;
    dvi_pvi pht_type.a_var; dvi_dtuong pht_type.a_nvar; dvi_ngay_hoi pht_type.a_num;
    dvi_gio_hl pht_type.a_var; dvi_ngay_hl pht_type.a_num; dvi_gio_kt pht_type.a_var; dvi_ngay_kt pht_type.a_num;
    dvi_ngay_cap pht_type.a_num; dvi_phi pht_type.a_num; dvi_thue pht_type.a_num; dvi_ttoan pht_type.a_num;
    dvi_so_idP pht_type.a_num;

    dk_so_id pht_type.a_num; dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var; dk_ma_ct pht_type.a_var;
    dk_kieu pht_type.a_var; dk_tien pht_type.a_num; dk_pt pht_type.a_num; dk_phi pht_type.a_num;
    dk_thue pht_type.a_num; dk_ttoan pht_type.a_num; dk_cap pht_type.a_num; dk_ma_dk pht_type.a_var;
    dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num; dk_ptB pht_type.a_num; dk_phiB pht_type.a_num;
    dk_ptG pht_type.a_num; dk_phiG pht_type.a_num;dk_lkeM  pht_type.a_var; dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var;
    dk_luy pht_type.a_var; dk_lh_bh pht_type.a_var;
    lt_so_id pht_type.a_num; lt_lt pht_type.a_clob; lt_kbt pht_type.a_clob;
-- xu ly
    b_ngay_htC number;
begin
-- Nam - Nhap
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_hk,ds_ct,ds_dk,ds_dkbs,ds_lt,ds_kbt,ds_ttt,dt_kytt');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_hk,ds_ct,ds_dk,ds_dkbs,ds_lt,ds_kbt,ds_ttt,dt_kytt using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_hk); FKH_JSa_NULL(dt_kytt);
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
PBH_PTNNNH_TESTr(
    b_ma_dvi,b_nsd,b_so_idG,
    dt_ct,ds_ct,ds_dk,ds_dkbs,ds_lt,ds_kbt,
    b_ma_sp,b_cdich,b_nghe,
    dvi_so_id,dvi_kieu_gcn,dvi_gcn,dvi_gcnG,dvi_pvi,dvi_dtuong,dvi_ngay_hoi,
    dvi_gio_hl,dvi_ngay_hl,dvi_gio_kt,dvi_ngay_kt,dvi_ngay_cap,dvi_phi,dvi_thue,dvi_ttoan,dvi_so_idP,
    dk_so_id,dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,dk_cap,dk_ma_dk,
    dk_lh_nv,dk_t_suat,dk_ptB,dk_phiB,dk_ptG,dk_phiG,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy,dk_lh_bh,
    lt_so_id,lt_lt,lt_kbt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_PTNNNH_NH_NH(
    -- chung
    b_ma_dvi,b_nsd,b_so_id,
    dt_ct,ds_ct,dt_hk,ds_dk,ds_dkbs,ds_lt,ds_kbt,ds_ttt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,
    b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
    b_so_hdL,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,
    b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_phong,
    tt_ngay,tt_tien,
    -- rieng
    b_ma_sp,b_cdich,b_nghe,
    dvi_so_id,dvi_kieu_gcn,dvi_gcn,dvi_gcnG,dvi_pvi,dvi_dtuong,dvi_ngay_hoi,
    dvi_gio_hl,dvi_ngay_hl,dvi_gio_kt,dvi_ngay_kt,dvi_ngay_cap,dvi_phi,dvi_thue,dvi_ttoan,dvi_so_idP,
    dk_so_id,dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,dk_cap,dk_ma_dk,
    dk_lh_nv,dk_t_suat,dk_ptB,dk_phiB,dk_ptG,dk_phiG,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy,dk_lh_bh,
    lt_so_id,lt_lt,lt_kbt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hd' value b_so_hd, 'ma_kh' value b_ma_kh) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNNNH_TESTr(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_idG number,
    dt_ct clob,ds_ct in out clob,ds_dk in out clob,ds_dkbs in out clob,ds_lt in out clob,ds_kbt clob,
    b_ma_sp out varchar2,b_cdich out varchar2,b_nghe out varchar2,

    dvi_so_id out pht_type.a_num, dvi_kieu_gcn out pht_type.a_var, dvi_gcn out pht_type.a_var, dvi_gcnG out pht_type.a_var,
    dvi_pvi out pht_type.a_var, dvi_dtuong out pht_type.a_nvar, dvi_ngay_hoi out pht_type.a_num,
    dvi_gio_hl out pht_type.a_var, dvi_ngay_hl out pht_type.a_num, dvi_gio_kt out pht_type.a_var, dvi_ngay_kt out pht_type.a_num,
    dvi_ngay_cap out pht_type.a_num, dvi_phi out pht_type.a_num, dvi_thue out pht_type.a_num, dvi_ttoan out pht_type.a_num,
    dvi_so_idP out pht_type.a_num,

    dk_so_id out pht_type.a_num,dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,dk_tc out pht_type.a_var,dk_ma_ct out pht_type.a_var,
    dk_kieu out pht_type.a_var,dk_tien out pht_type.a_num,dk_pt out pht_type.a_num,dk_phi out pht_type.a_num,
    dk_thue out pht_type.a_num,dk_ttoan out pht_type.a_num,dk_cap out pht_type.a_num,dk_ma_dk out pht_type.a_var,
    dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,dk_ptB out pht_type.a_num,dk_phiB out pht_type.a_num,
    dk_ptG out pht_type.a_num,dk_phiG out pht_type.a_num,dk_lkeM out pht_type.a_var,dk_lkeP out pht_type.a_var,dk_lkeB out pht_type.a_var,
    dk_luy out pht_type.a_var,dk_lh_bh out pht_type.a_var,
    lt_so_id out pht_type.a_num,lt_lt out pht_type.a_clob,lt_kbt out pht_type.a_clob,
    b_loi out varchar2)
AS
    b_lenh varchar2(2000);
    b_c_thue varchar2(1); b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tp number:=0;
    b_phi number; b_thue number;
    b_thueH number; b_ttoanH number;
    b_kieu_hd varchar2(1); b_ttrang varchar2(1); b_tygia number;
    b_gio_hlH varchar2(50); b_ngay_hlH number; b_gio_ktH varchar2(50); b_ngay_ktH number; b_ngay_capH number;
    b_loai_khH varchar2(1); b_cmtH varchar2(20); b_mobiH varchar2(20); b_emailH varchar2(100);
    b_tenH nvarchar2(500); b_dchiH nvarchar2(500);

    b_kt_dk number:=0;
    
    b_so_id_dt number; b_kieu_gcn varchar2(1); b_gcn varchar2(20); b_gcnG varchar2(20);
    b_pvi varchar2(10); b_dtuong nvarchar2(500); b_ngay_hoi number; b_gio_hl varchar2(50); 
    b_ngay_hl number; b_gio_kt varchar2(50); b_ngay_kt number; b_ngay_cap number; b_so_idP number;

    a_ma pht_type.a_var; a_ten pht_type.a_nvar; a_tc pht_type.a_var;
    a_ma_ct pht_type.a_var; a_kieu pht_type.a_var;
    a_lkeM pht_type.a_var; a_lkeP pht_type.a_var;
    a_lkeB pht_type.a_var; a_luy pht_type.a_var;
    a_ma_dk pht_type.a_var; a_lh_nv pht_type.a_var; a_t_suat pht_type.a_num;
    a_cap pht_type.a_num; a_lh_bh pht_type.a_var;
    a_tien pht_type.a_num; a_pt pht_type.a_num; a_phi pht_type.a_num;
    a_thue pht_type.a_num; a_ttoan pht_type.a_num;
    a_ptB pht_type.a_num; a_phiB pht_type.a_num;

    a_ds_ct pht_type.a_clob; a_ds_dk pht_type.a_clob;
    a_ds_dkbs pht_type.a_clob; a_ds_lt pht_type.a_clob; a_ds_kbt pht_type.a_clob;

begin
-- Nam - Nhap
b_lenh:=FKH_JS_LENH('ttrang,kieu_hd,gio_hl,ngay_hl,gio_kt,ngay_kt,ngay_cap,
    ma_sp,cdich,nghe,thue,ttoan,nt_tien,nt_phi,tygia,c_thue,loai_khh,cmth,mobih,emailh,tenh,dchih');
EXECUTE IMMEDIATE b_lenh into b_ttrang,b_kieu_hd,b_gio_hlH,b_ngay_hlH,b_gio_ktH,b_ngay_ktH,b_ngay_capH,b_ma_sp,b_cdich,b_nghe,
    b_thueH,b_ttoanH,b_nt_tien,b_nt_phi,b_tygia,b_c_thue,b_loai_khH,b_cmtH,b_mobiH,b_emailH,b_tenH,b_dchiH using dt_ct;
if b_ma_sp<>' ' and FBH_PTNNN_SP_HAN(b_ma_sp)<>'C' then b_loi:='loi:Sai ma san pham:loi'; return; end if;
if b_cdich<>' ' and FBH_MA_CDICH_HAN(b_cdich)<>'C' then b_loi:='loi:Sai ma chien dich:loi'; return; end if;
b_c_thue:=nvl(trim(b_c_thue),'C');
if nvl(trim(b_nt_phi),'VND')<>'VND' then b_tp:=2; end if;
b_lenh:=FKH_JS_LENHc('');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_ct using ds_ct;
if a_ds_ct.count=0 then b_loi:='loi:Nhap danh sach:loi'; return; end if;
b_lenh:=FKH_JS_LENHc('');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_dk using ds_dk;
EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_dkbs using ds_dkbs;
EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_lt using ds_lt;
EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_kbt using ds_kbt;
for ds_lp in 1..a_ds_ct.count loop
    FKH_JS_NULL(a_ds_ct(ds_lp)); FKH_JSa_NULL(a_ds_dk(ds_lp)); FKH_JSa_NULL(a_ds_dkbs(ds_lp));
    FKH_JSa_NULL(a_ds_lt(ds_lp)); FKH_JSa_NULL(a_ds_kbt(ds_lp));
    PBH_PTNNNH_TESTd(
    dt_ct,a_ds_ct(ds_lp),a_ds_dk(ds_lp),a_ds_dkbs(ds_lp),
        b_ma_dvi,b_nsd,b_ttrang,b_kieu_hd,b_ma_sp,b_cdich,b_nghe,b_nt_tien,
        b_nt_phi,b_tygia,b_c_thue,b_gio_hlH,b_ngay_hlH,b_gio_ktH,b_ngay_ktH,b_ngay_capH,
        b_so_id_dt,b_kieu_gcn,b_gcn,b_gcnG,b_pvi,b_dtuong,
        b_ngay_hoi,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_so_idP,
        a_ma,a_ten,a_tc,a_ma_ct,a_kieu,a_lkeM,a_lkeP,a_lkeB,a_luy,a_ma_dk,a_lh_nv,a_t_suat,
        a_cap,a_lh_bh,a_tien,a_pt,a_phi,a_thue,a_ttoan,a_ptB,a_phiB,b_loi);
    if b_loi is not null then return; end if;
    dvi_so_id(ds_lp):=b_so_id_dt; dvi_kieu_gcn(ds_lp):=b_kieu_gcn; dvi_gcn(ds_lp):=b_gcn; dvi_gcnG(ds_lp):=b_gcnG;
    dvi_pvi(ds_lp):=b_pvi; dvi_dtuong(ds_lp):=b_dtuong; dvi_ngay_hoi(ds_lp):=b_ngay_hoi; dvi_ngay_hl(ds_lp):=b_ngay_hl;
    dvi_ngay_kt(ds_lp):=b_ngay_kt; dvi_ngay_cap(ds_lp):=b_ngay_cap; dvi_so_idP(ds_lp):=b_so_idP;
    dvi_gio_hl(ds_lp):=b_gio_hl; dvi_gio_kt(ds_lp):=b_gio_kt;
    for b_lp in 1..a_ma.count loop
        b_kt_dk:=b_kt_dk+1;
        dk_so_id(b_kt_dk):=b_so_id_dt; dk_ma(b_kt_dk):=a_ma(b_lp); dk_ten(b_kt_dk):=a_ten(b_lp);
        dk_tc(b_kt_dk):=a_tc(b_lp); dk_ma_ct(b_kt_dk):=a_ma_ct(b_lp);  dk_kieu(b_kt_dk):=a_kieu(b_lp); 
        dk_lkeM(b_kt_dk):=a_lkeM(b_lp); dk_lkeP(b_kt_dk):=a_lkeP(b_lp);
        dk_lkeB(b_kt_dk):=a_lkeB(b_lp); dk_luy(b_kt_dk):=a_luy(b_lp);
        dk_ma_dk(b_kt_dk):=a_ma_dk(b_lp);
        dk_lh_nv(b_kt_dk):=a_lh_nv(b_lp); dk_t_suat(b_kt_dk):=a_t_suat(b_lp); 
        dk_cap(b_kt_dk):=a_cap(b_lp); dk_lh_bh(b_kt_dk):=a_lh_bh(b_lp); 
        dk_tien(b_kt_dk):=a_tien(b_lp); dk_pt(b_kt_dk):=a_pt(b_lp); dk_phi(b_kt_dk):=a_phi(b_lp); 
        dk_thue(b_kt_dk):=a_thue(b_lp); dk_ttoan(b_kt_dk):=a_ttoan(b_lp); 
        dk_ptB(b_kt_dk):=a_ptB(b_lp); dk_phiB(b_kt_dk):=a_phiB(b_lp); 
    end loop;
end loop;
ds_ct:=FKH_ARRc_JS(a_ds_ct);
if b_kieu_hd in('B','S') and b_so_idG<>0 then
    for r_lp in (select so_id_dt,dtuong from bh_ptnnn_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idG) loop
        if FKH_ARR_VTRI_N(dvi_so_id,r_lp.so_id_dt)=0 then b_loi:='loi:Khong xoa danh sach cu '||r_lp.dtuong||':loi'; return; end if;
    end loop;
end if;
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
for b_lp in 1..dvi_so_id.count loop
    b_phi:=0; b_thue:=0;
    for b_lp1 in 1..dk_so_id.count loop
        if dk_lh_nv(b_lp1)<>' ' and dk_so_id(b_lp1)=dvi_so_id(b_lp) then
            b_phi:=b_phi+dk_phi(b_lp1); b_thue:=b_thue+dk_thue(b_lp1);
        end if;
    end loop;
    dvi_phi(b_lp):=b_phi; dvi_thue(b_lp):=b_thue; dvi_ttoan(b_lp):=b_phi+b_thue;
    lt_so_id(b_lp):=dvi_so_id(b_lp); lt_lt(b_lp):=a_ds_lt(b_lp); lt_kbt(b_lp):=a_ds_kbt(b_lp);
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PTNNNH_TESTd(
    dt_ctH clob,dt_ct in out clob,dt_dk clob,dt_dkbs clob,
    b_ma_dvi varchar2,b_nsd varchar2,b_ttrang varchar2,b_kieu_hd varchar2,
    b_ma_sp varchar2,b_cdich varchar2,b_nghe varchar2,b_nt_tien varchar2, b_nt_phi varchar2,b_tygia number,b_c_thue varchar2,
    b_gio_hlH varchar2,b_ngay_hlH number,b_gio_ktH varchar2,b_ngay_ktH number,b_ngay_capH number,

    b_so_id_dt out number,b_kieu_gcn out varchar2,b_gcn out varchar2,b_gcnG out varchar2,
    b_pvi out varchar2,b_dtuong out nvarchar2,
    b_ngay_hoi out number,b_gio_hl out varchar2,b_ngay_hl out number,b_gio_kt out varchar2,b_ngay_kt out varchar2,
    b_ngay_cap out number,b_so_idP out number,

    dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,
    dk_tc out pht_type.a_var,dk_ma_ct out pht_type.a_var,dk_kieu out pht_type.a_var,
    dk_lkeM out pht_type.a_var,dk_lkeP out pht_type.a_var,dk_lkeB out pht_type.a_var,
    dk_luy out pht_type.a_var,dk_ma_dk out pht_type.a_var,
    dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,dk_cap out pht_type.a_num,
    dk_lh_bh out pht_type.a_var,dk_tien out pht_type.a_num,dk_pt out pht_type.a_num,dk_phi out pht_type.a_num,
    dk_thue out pht_type.a_num,dk_ttoan out pht_type.a_num,
    dk_ptB out pht_type.a_num,dk_phiB out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_kt number;
    b_lenh varchar2(2000); b_txt clob; b_ghan_m varchar2(1); b_tp number:=0;
    dkB_ma pht_type.a_var; dkB_ten pht_type.a_nvar; dkB_tc pht_type.a_var; dkB_ma_ct pht_type.a_var;
    dkB_tien pht_type.a_num; dkB_pt pht_type.a_num; dkB_phi pht_type.a_num;
    dkB_ppt pht_type.a_num; dkB_thue pht_type.a_num;

    dkB_cap pht_type.a_num; dkB_ma_dk pht_type.a_var; dkB_kieu pht_type.a_var;
    dkB_lh_nv pht_type.a_var; dkB_t_suat pht_type.a_num; dkB_ptB pht_type.a_num;
    dkB_phiB pht_type.a_num; dkB_lkeM pht_type.a_var;
    dkB_lkeP pht_type.a_var; dkB_lkeB pht_type.a_var; dkB_luy pht_type.a_var;

    b_so_idPn number; b_gct number; b_gtv number;
    a_thay pht_type.a_num;
begin
-- Nam - Nhap
b_loi:='loi:Loi xu ly PBH_PTNNNH_TESTd:loi';
b_lenh:=FKH_JS_LENH('so_id_dt,gcn,gcn_g,ngay_hl,ngay_kt,ngay_hoi,ghan_m,gio_hl,gio_kt,pvi,dtuong,gct,gtv,so_idp');
EXECUTE IMMEDIATE b_lenh into
    b_so_id_dt,b_gcn,b_gcnG,b_ngay_hl,b_ngay_kt,b_ngay_hoi,b_ghan_m,b_gio_hl,b_gio_kt,b_pvi,b_dtuong,b_gct,b_gtv,b_so_idPn using dt_ct;
if b_dtuong=' ' then b_loi:='loi:Nhap doi tuong bao hiem:loi'; return; end if;
b_ghan_m:=nvl(b_ghan_m,' '); b_pvi:=nvl(b_pvi,' '); b_gct:=nvl(b_gct,0); b_gtv:=nvl(b_gtv,0);
if b_pvi<>' ' and FBH_PTNNN_PVI_HAN(b_pvi)<>'C' then b_loi:='loi:Sai ma pham vi:loi'; return; end if;
b_gio_hl:=to_number(replace(b_gio_hl,'|','')); b_gio_kt:=to_number(replace(b_gio_kt,'|',''));
b_loi:='loi:Sai ngay hieu luc doi tuong rui ro: '||b_dtuong||':loi';
if b_ngay_hl in(0,30000101) or b_ngay_kt in(0,30000101) or
    b_ngay_hl<b_ngay_hlH or b_ngay_hl>b_ngay_kt or b_ngay_kt>b_ngay_ktH then return;
elsif b_ngay_hl=b_ngay_hlH or b_ngay_kt=b_ngay_ktH then
    if b_gio_hl<to_number(replace(b_gio_hlH,'|','')) or b_gio_kt>to_number(replace(b_gio_ktH,'|','')) then return; end if;
elsif b_ngay_hl=b_ngay_kt and b_gio_hl>b_gio_kt then return;
end if;
b_kieu_gcn:='G'; b_ngay_cap:=b_ngay_capH;
if b_so_id_dt<100000 then
    PHT_ID_MOI(b_so_id_dt,b_loi);
    if b_loi is not null then return; end if;
    b_gcn:=substr(to_char(b_so_id_dt),3); b_gcnG:=' ';
elsif b_kieu_hd in('S','B') and b_gcnG<>' ' then
    select count(*) into b_i1 from bh_ptnnn_dvi where ma_dvi=b_ma_dvi and so_id_dt=b_so_id_dt and gcn=b_gcnG;
    if b_i1=0 then b_loi:='loi:GCN '||b_gcnG||' da xoa:loi'; return; end if;
    b_kieu_gcn:=b_kieu_hd;
    if b_gcn=b_gcnG then b_gcn:=' '; end if;
end if;
if b_gcn=' ' or instr(b_gcn,'.')=2 then
    b_gcn:=substr(to_char(b_so_id_dt),3);
    if b_kieu_gcn<>'G' then
        select count(*) into b_i1 from bh_ptnnn_dvi where ma_dvi=b_ma_dvi and so_id_dt=b_so_id_dt and kieu_gcn=b_kieu_hd;
        if(b_i1>0) then
           select max(REGEXP_SUBSTR(gcn, 'B([0-9]+)', 1, 1, NULL, 1)) into b_i1 from bh_ptnnn_dvi where ma_dvi=b_ma_dvi and so_id_dt=b_so_id_dt and kieu_gcn=b_kieu_hd;
        end if;
        b_gcn:=b_gcn||'/'||b_kieu_hd||to_char(b_i1+1);
    end if;
else
    select nvl(max(ngay_cap),b_ngay_capH) into b_ngay_cap from bh_ptnnn_dvi where ma_dvi=b_ma_dvi and so_id_dt=b_so_id_dt and gcn=b_gcn;
end if;
PKH_JS_THAYa(dt_ct,'gcn,gcn_g',b_gcn||'|'||b_gcnG,'|');
a_thay(1):=b_so_id_dt; a_thay(2):=b_ngay_hoi; a_thay(3):=b_ngay_hl; a_thay(4):=b_ngay_kt; a_thay(5):=b_ngay_cap;
PKH_JS_THAYan(dt_ct,'so_id_dt,ngay_hoi,ngay_hl,ngay_kt,ngay_cap',a_thay);
b_txt:=dt_ct;
b_lenh:='H,'||b_ma_sp||','||b_cdich||','||b_nghe||','||b_nt_tien||','||b_nt_phi||','||b_c_thue;
PKH_JS_THAYa(b_txt,'nhom,ma_sp,cdich,nghe,nt_tien,nt_phi,c_thue',b_lenh);
PKH_JS_THAYn(b_txt,'tygia',b_tygia);
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
    if dk_tien(b_lp)=0 and dk_lkeM(b_lp) not in ('T','N','K') then
      b_loi:='loi:Chua nhap muc trach nhiem dieu khoan '||dk_ma(b_lp)||':loi'; return;
    end if;
    if b_c_thue='K' then dk_thue(b_lp):=0; else dk_thue(b_lp):=nvl(dk_thue(b_lp),0); end if;
    dk_ttoan(b_lp):=dk_phi(b_lp)+dk_thue(b_lp);
    if dk_tien(b_lp)<>0 then
      b_i1:=round(dk_phiB(b_lp)/dk_tien(b_lp)*100,20);
      dk_pt(b_lp):= b_i1 - round(((dk_phiB(b_lp)/dk_tien(b_lp))-(dk_phi(b_lp)/dk_tien(b_lp)))*100 ,20);
    end if;
end loop;
b_so_idP:=FBH_PTNNN_BPHI_SO_IDh('H',b_ma_sp,b_cdich,b_nghe,b_pvi,b_ghan_m,b_gct,b_gtv,b_ngay_hl);
if b_so_idP=0 then b_loi:='loi:Sai bieu phi:loi'; return; end if;
if b_so_idP<>b_so_idPn then
    b_loi:='loi:Thong tin xac dinh bieu phi '||b_dtuong||' bi thay doi:loi'; return;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;










