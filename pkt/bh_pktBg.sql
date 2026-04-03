create or replace procedure PBH_PKTBG_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number;
    dt_ct clob; dt_dk clob; dt_dkbs clob:=''; dt_pvi clob; dt_lt clob:=''; dt_kbt clob:=''; dt_ttt clob:=''; dt_kytt clob:='';
    b_lan number;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','PKT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id,lan');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id,b_lan using b_oraIn;
if b_so_id=0 then b_loi:='loi:Chon GCN:loi'; raise PROGRAM_ERROR; end if;
select nvl(max(lan),0) into b_lan from bh_pktB where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_lan=0 then raise PROGRAM_ERROR; end if;
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
select txt into dt_ct from bh_pktB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct' and lan = b_lan;
select txt into dt_dk from bh_pktB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dk' and lan = b_lan;
select txt into dt_pvi from bh_pktB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_pvi' and lan = b_lan;
select count(*) into b_i1 from bh_pktB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dkbs' and lan = b_lan;
if b_i1<>0 then
    select txt into dt_dkbs from bh_pktB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dkbs' and lan = b_lan;
end if;
select count(*) into b_i1 from bh_pktB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_lt' and lan = b_lan;
if b_i1<>0 then
    select txt into dt_lt from bh_pktB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_lt' and lan = b_lan;
end if;
select count(*) into b_i1 from bh_pktB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_kbt'and lan = b_lan;
if b_i1<>0 then
    select txt into dt_kbt from bh_pktB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_kbt'and lan = b_lan;
end if;
select count(*) into b_i1 from bh_pktB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt'and lan = b_lan;
if b_i1=1 then
    select txt into dt_ttt from bh_pktB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt'and lan = b_lan;
end if;
select count(*) into b_i1 from bh_pktB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_kytt'and lan = b_lan;
if b_i1=1 then
    select txt into dt_kytt from bh_pktB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_kytt'and lan = b_lan;
end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,
    'dt_ct' value dt_ct,'dt_dk' value dt_dk,'dt_dkbs' value dt_dkbs,'dt_pvi' value dt_pvi,
    'dt_lt' value dt_lt,'dt_kbt' value dt_kbt,'dt_ttt' value dt_ttt,'dt_kytt' value dt_kytt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKTBG_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_lan out number,
    dt_ct in out clob,dt_dk clob,dt_dkbs clob,dt_pvi clob,dt_lt clob,dt_kbt clob,dt_ttt clob,dt_kytt clob,
-- Chung
    b_so_hd varchar2,b_ngay_ht number,b_ttrang varchar2,b_kieu_hd varchar2,b_so_hd_g varchar2,
    b_kieu_kt varchar2,b_ma_kt varchar2,b_kieu_gt varchar2,b_ma_gt varchar2,b_ma_cb varchar2,
    b_so_hdL varchar2,b_loai_kh varchar2,b_ma_kh varchar2,b_ten nvarchar2,b_dchi nvarchar2, 
    b_cmt varchar2,b_mobi varchar2,b_email varchar2,
    b_gio_hl varchar2,b_ngay_hl number,b_gio_kt varchar2,b_ngay_kt number,b_ngay_cap number,
    b_nt_tien varchar2,b_nt_phi varchar2,b_c_thue varchar2,
    b_phi number,b_giam number,b_thue number,b_ttoan number,b_hhong number,b_phong varchar2,
    tt_ngay pht_type.a_num,tt_tien pht_type.a_num,
-- Rieng
    b_ng_huong nvarchar2,b_ma_sp varchar2,b_so_idP number,b_dvi nvarchar2,b_ddiem nvarchar2,
    b_kvuc varchar2,b_cdt varchar2,b_tdx number,b_tdy number,b_bk number,b_dk_lut varchar2,b_hs_lut number,
    b_ma_cct varchar2,b_ma_dt varchar2,b_ma_dkdl varchar2,b_ma_dktc varchar2,
    b_rru varchar2,b_tgian number,b_bhanh number,
    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tc pht_type.a_var,
    dk_ma_ct pht_type.a_var,dk_kieu pht_type.a_var,
    dk_lkeM pht_type.a_var,dk_lkeP pht_type.a_var,dk_lkeB pht_type.a_var,
    dk_luy pht_type.a_var,dk_ktru pht_type.a_var,
    dk_ma_dk pht_type.a_var,dk_ma_dkC pht_type.a_var,dk_lh_nv pht_type.a_var,dk_t_suat pht_type.a_num,
    dk_cap pht_type.a_num,dk_lbh pht_type.a_var,dk_nv pht_type.a_var,
    dk_tien pht_type.a_num,dk_pt pht_type.a_num,dk_phi pht_type.a_num,
    dk_thue pht_type.a_num,dk_ttoan pht_type.a_num,
    dk_ptB pht_type.a_num,dk_ptG pht_type.a_num,dk_phiG pht_type.a_num,
    dk_pvi_ma pht_type.a_var,dk_pvi_tc pht_type.a_var,dk_pvi_ktru pht_type.a_var,b_loi out varchar2)
AS
    b_i1 number; b_tien number:=0;
begin
-- Dan - Nhap
b_loi:='loi:Loi Table bh_pktB:loi';
b_lan:=FKH_JS_GTRIn(dt_ct,'lan');
select nvl(max(lan),0) into b_i1 from bh_pktB where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 or b_lan<>b_i1 then
    if b_i1<>0 then
        insert into bh_pktB_ls select * from bh_pktB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
    end if;
    b_lan:=b_i1+1;
    PKH_JS_THAYn(dt_ct,'lan',b_lan);
end if; 
PBH_PKTB_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'N',b_lan,b_loi);
if b_loi is not null then return; end if;
insert into bh_pktB_dvi values(b_ma_dvi,b_so_id,b_so_id,b_dvi,b_ma_dt,
    b_ddiem,b_dk_lut,b_hs_lut,b_rru,b_cdt,b_tdx,b_tdy,b_bk,b_ngay_hl,b_ngay_kt);
for b_lp in 1..dk_lh_nv.count loop
    if dk_lh_nv(b_lp)<>' ' then
        if dk_kieu(b_lp)='T' then b_tien:=b_tien+dk_tien(b_lp); end if;
        insert into bh_pktB_dk values(b_ma_dvi,b_so_id,b_so_id,dk_ma(b_lp),dk_ten(b_lp),dk_lh_nv(b_lp),dk_tien(b_lp),dk_phi(b_lp),dk_ptG(b_lp));
    end if;
end loop;
insert into bh_pktB values(
    b_ma_dvi,b_so_id,b_lan,b_so_hd,b_ngay_ht,'G',b_ttrang,b_kieu_hd,b_so_hd_g,
    b_phong,b_ma_kh,b_ten,b_ngay_hl,b_ngay_kt,b_ma_sp,b_nt_tien,b_tien,b_nt_phi,b_phi,' ',' ',b_nsd,sysdate);
PKH_JS_THAYa(dt_ct,'so_hd,ma_kh',b_so_hd||','||b_ma_kh);
insert into bh_pktB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_ct',dt_ct);
insert into bh_pktB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_dk',dt_dk);
insert into bh_pktB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_pvi',dt_pvi);
if length(dt_dkbs)<>0 then
    insert into bh_pktB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_dkbs',dt_dkbs);
end if;
if length(dt_lt)<>0 then
    insert into bh_pktB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_lt',dt_lt);
end if;
if length(dt_kbt)<>0 then
    insert into bh_pktB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_kbt',dt_kbt);
end if;
if length(dt_ttt)<>0 then
    insert into bh_pktB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_ttt',dt_ttt);
end if;
if length(dt_kytt)<>0 then
    insert into bh_pktB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_kytt',dt_kytt);
end if;
PBH_BAO_NV_NH(b_ma_dvi,b_nsd,b_so_id,b_so_hd,'PKT',b_ttrang,b_phong,b_ma_kh,b_ten,
    b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_tien,b_nt_phi,b_phi,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PKTBG_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(3000); b_lenh varchar2(2000); b_i1 number; b_lan number;
    dt_ct clob; dt_dk clob; dt_dkbs clob; dt_pvi clob; dt_lt clob; dt_kbt clob; dt_ttt clob; dt_kytt clob;
-- Chung
    b_so_id number; b_so_hd varchar2(20); b_ngay_ht number; b_ttrang varchar2(1); b_kieu_hd varchar2(1); b_so_hd_g varchar2(20);
    b_kieu_kt varchar2(1); b_ma_kt varchar2(20); b_kieu_gt varchar2(1); b_ma_gt varchar2(20); b_ma_cb varchar2(20);
    b_so_hdL varchar2(20); b_loai_kh varchar2(1); b_ma_kh varchar2(20); b_ten nvarchar2(500); b_dchi nvarchar2(500);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_gio_hl varchar2(20); b_ngay_hl number; b_gio_kt varchar2(20); b_ngay_kt number; b_ngay_cap number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_c_thue varchar2(1);
    b_tl_giam number; b_phi number; b_giam number; b_thue number; b_ttoan number; b_hhong number; b_phong varchar2(10);
    tt_ngay pht_type.a_num; tt_tien pht_type.a_num;
-- Rieng
    b_ng_huong nvarchar2(500); b_ma_sp varchar2(10); b_dvi nvarchar2(500); b_ddiem nvarchar2(500);
    b_kvuc varchar2(10); b_cdt varchar2(5); b_tdx number; b_tdy number; b_bk number; b_dk_lut varchar2(1); b_hs_lut number;
    b_ma_cct varchar2(10); b_ma_dt varchar2(10); b_ma_dkdl varchar2(10); b_so_idP number;
    b_ma_dktc varchar2(10); b_rru varchar2(1); b_tgian number; b_bhanh number;
    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var;
    dk_ma_ct pht_type.a_var; dk_kieu pht_type.a_var;
    dk_lkeM pht_type.a_var; dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var; 
    dk_luy pht_type.a_var; dk_ktru pht_type.a_var;
    dk_ma_dk pht_type.a_var; dk_ma_dkC pht_type.a_var; dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num;
    dk_cap pht_type.a_num; dk_lbh pht_type.a_var; dk_nv pht_type.a_var;
    dk_tien pht_type.a_num; dk_pt pht_type.a_num; dk_phi pht_type.a_num;
    dk_thue pht_type.a_num; dk_ttoan pht_type.a_num;
    dk_ptB pht_type.a_num; dk_phiB pht_type.a_num;dk_ptG pht_type.a_num; dk_phiG pht_type.a_num;
    dk_pvi_ma pht_type.a_var; dk_pvi_tc pht_type.a_var; dk_pvi_ktru pht_type.a_var;
-- Xu ly
    b_ngay_htC number;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_dkbs,dt_pvi,dt_lt,dt_kbt,dt_ttt,dt_kytt');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_dkbs,dt_pvi,dt_lt,dt_kbt,dt_ttt,dt_kytt using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_dkbs); FKH_JSa_NULL(dt_pvi);
FKH_JSa_NULL(dt_lt); FKH_JSa_NULL(dt_kbt); FKH_JSa_NULL(dt_ttt); FKH_JSa_NULL(dt_kytt);
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_BG_JS_TEST(
    b_ma_dvi,b_nsd,b_so_id,'bh_pkt',dt_ct,dt_kytt,
    b_so_hd,b_ngay_ht,b_ttrang,
    b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_loai_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,
    b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_phong,b_ma_kh,
    tt_ngay,tt_tien,b_loi,'PKT');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_PKTG_TESTr(
    b_ma_dvi,b_nsd,dt_ct,dt_dk,dt_dkbs,dt_pvi,
    b_ng_huong,b_ma_sp,b_dvi,b_ddiem,b_kvuc,b_cdt,b_tdx,b_tdy,b_bk,b_dk_lut,b_hs_lut,
    b_ma_cct,b_ma_dt,b_ma_dkdl,b_ma_dktc,b_rru,b_tgian,b_bhanh,
    b_nt_tien,b_nt_phi,b_c_thue,b_so_idP,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy,dk_ktru,
    dk_ma_dk,dk_ma_dkC,dk_lh_nv,dk_t_suat,
    dk_cap,dk_lbh,dk_nv,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,dk_ptB,dk_phiB,dk_ptG,dk_phiG,dk_pvi_ma,dk_pvi_tc,dk_pvi_ktru,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_PKTBG_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,b_lan,
    dt_ct,dt_dk,dt_dkbs,dt_pvi,dt_lt,dt_kbt,dt_ttt,dt_kytt,
-- Chung
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,
    b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
    b_so_hdL,b_loai_kh,b_ma_kh,b_ten,b_dchi,
    b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,
    b_nt_tien,b_nt_phi,b_c_thue,
    b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_phong,
    tt_ngay,tt_tien,
-- Rieng
    b_ng_huong,b_ma_sp,b_so_idP,b_dvi,b_ddiem,b_kvuc,b_cdt,b_tdx,b_tdy,b_bk,b_dk_lut,b_hs_lut,
    b_ma_cct,b_ma_dt,b_ma_dkdl,b_ma_dktc,b_rru,b_tgian,b_bhanh,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy,dk_ktru,dk_ma_dk,dk_ma_dkC,dk_lh_nv,dk_t_suat, 
    dk_cap,dk_lbh,dk_nv,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,dk_ptB,dk_ptG,dk_phiG,dk_pvi_ma,dk_pvi_tc,dk_pvi_ktru,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
FBH_BAO_TTRANGn(b_ma_dvi,b_so_id,b_ttrang,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hd' value b_so_hd,
    'ma_kh' value b_ma_kh,'lan' value b_lan) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
