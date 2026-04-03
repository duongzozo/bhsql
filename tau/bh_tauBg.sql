create or replace procedure PBH_TAUBG_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number; b_lan number;
    dt_ct clob; dt_dk clob; dt_dkbs clob:=''; dt_lt clob:=''; dt_kbt clob:=''; dt_hu clob:=''; dt_ttt clob:=''; dt_kytt clob:=''; dt_txt clob;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','TAU','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
if b_so_id=0 then b_loi:='loi:Chon bao gia:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
select nvl(max(lan),0) into b_lan from bh_tauB where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_lan=0 then b_loi:='loi:Bao gia da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object(
    'nhom' value FBH_TAU_NHOM_TENl(FKH_JS_GTRIs(txt,'nhom')),'loai' value FBH_TAU_LOAI_TENl(FKH_JS_GTRIs(txt,'loai')),
    'cap' value FBH_TAU_CAP_TENl(FKH_JS_GTRIs(txt,'cap')),'vlieu' value FBH_TAU_VLIEU_TENl(FKH_JS_GTRIs(txt,'vlieu')),
    'hoi' value FBH_TAU_HOI_TENl(FKH_JS_GTRIs(txt,'hoi')),'dkien' value FBH_TAU_DKC_TENl(FKH_JS_GTRIs(txt,'dkien')) returning clob)
    into dt_ct from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ct';
select txt into dt_dk from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_dk';
select count(*) into b_i1 from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_dkbs';
if b_i1<>0 then
    select txt into dt_dkbs from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_dkbs';
end if;
select count(*) into b_i1 from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_lt';
if b_i1<>0 then
    select txt into dt_lt from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_lt';
end if;
select count(*) into b_i1 from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_kbt';
if b_i1<>0 then
    select txt into dt_kbt from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_kbt';
end if;
select count(*) into b_i1 from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_hu';
if b_i1<>0 then
    select txt into dt_hu from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_hu';
end if;
select count(*) into b_i1 from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_ttt';
if b_i1=1 then
    select txt into dt_ttt from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_ttt';
end if;
if b_i1<>0 then
    select txt into dt_kytt from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_kytt';
end if;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ct';
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,
    'dt_ct' value dt_ct,'dt_dk' value dt_dk,'dt_dkbs' value dt_dkbs,'dt_lt' value dt_lt,
    'dt_kbt' value dt_kbt,'dt_hu' value dt_hu,'dt_ttt' value dt_ttt,'dt_kytt' value dt_kytt,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAUBG_CTbg(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number; b_lan number;
    dt_ct clob; dt_dk clob; dt_dkbs clob:=''; dt_lt clob:=''; dt_kbt clob:=''; dt_hu clob:=''; dt_ttt clob:=''; dt_kytt clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','TAU','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id,lan');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id,b_lan using b_oraIn;
if b_so_id=0 then b_loi:='loi:Chon bao gia:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
select txt into dt_ct from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ct';
select txt into dt_dk from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_dk';
select count(*) into b_i1 from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_dkbs';
if b_i1<>0 then
    select txt into dt_dkbs from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_dkbs';
end if;
select count(*) into b_i1 from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_lt';
if b_i1<>0 then
    select txt into dt_lt from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_lt';
end if;
select count(*) into b_i1 from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_kbt';
if b_i1<>0 then
    select txt into dt_kbt from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_kbt';
end if;
select count(*) into b_i1 from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_hu';
if b_i1<>0 then
    select txt into dt_hu from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_hu';
end if;
select count(*) into b_i1 from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_ttt';
if b_i1=1 then
    select txt into dt_ttt from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_ttt';
end if;
if b_i1<>0 then
    select txt into dt_kytt from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_kytt';
end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,
    'dt_ct' value dt_ct,'dt_dk' value dt_dk,'dt_dkbs' value dt_dkbs,'dt_lt' value dt_lt,
    'dt_kbt' value dt_kbt,'dt_hu' value dt_hu,'dt_ttt' value dt_ttt,'dt_kytt' value dt_kytt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAUBG_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_lan out number,
    dt_ct in out clob,dt_dk clob,dt_dkbs clob,dt_lt clob,dt_kbt clob,dt_hu clob,dt_kytt clob,dt_ttt clob,
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
    b_tenC nvarchar2,b_cmtC varchar2,b_mobiC varchar2,
    b_emailC varchar2,b_dchiC nvarchar2,b_ng_huong nvarchar2,
    b_nhom varchar2,b_loai varchar2,b_cap varchar2,b_vlieu varchar2,
    b_ttai number,b_so_cn number,b_dtich number,b_csuat number,b_gia number,b_tuoi number,
    b_ma_sp varchar2,b_dkien varchar2,b_md_sd varchar2,b_nv_bh varchar2,
    b_so_dk varchar2,b_ten_tau nvarchar2,b_nam_sx number,
    b_hoi varchar2,b_hoi_tien number,b_hoi_tyle number,b_hoi_hh number,b_tl_mgiu number,

    dk_bt pht_type.a_num,dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tc pht_type.a_var,
    dk_ma_ct pht_type.a_var,dk_kieu pht_type.a_var,
    dk_tien pht_type.a_num,dk_pt pht_type.a_num,dk_phi pht_type.a_num,
    dk_thue pht_type.a_num,dk_ttoan pht_type.a_num,dk_cap pht_type.a_num,dk_ma_dk pht_type.a_var,
    dk_lh_nv pht_type.a_var,dk_t_suat pht_type.a_num,dk_ptB pht_type.a_num,
    dk_ptG pht_type.a_num,dk_phiG pht_type.a_num,dk_lkeP pht_type.a_var,dk_lkeB pht_type.a_var,dk_luy pht_type.a_var,b_loi out varchar2)
AS
    b_i1 number; b_so_id_kt number:=-1; b_ttrang_bg varchar2(1); b_tien number:=0; b_txt clob;
begin
-- Dan - Nhap
b_lan:=FKH_JS_GTRIn(dt_ct,'lan');
select nvl(max(lan),0) into b_i1 from bh_tauB where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_lan <> 0 and b_lan < b_i1 then b_loi:='loi:Khong duoc sua bao gia cu:loi'; return; end if;
if b_lan <> b_i1 then
  select nvl(ttrang,' ') into b_ttrang_bg from bh_tauB where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_i1;
  if b_ttrang_bg <> ' ' and b_ttrang_bg <> 'D' then b_loi:='loi:Phai duyet bao gia lan '||b_i1||':loi'; return; end if;
end if;
if b_lan = 0 then b_lan:=b_i1+1; end if;
PKH_JS_THAYn(dt_ct,'lan',b_lan); 
PBH_TAUB_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'N',b_lan,b_loi);
if b_loi is not null then return; end if;
insert into bh_tauB_ds values(b_ma_dvi,b_so_id,b_so_id,b_so_dk||'/'||b_ten_tau,b_nam_sx,b_nhom,b_ma_sp,b_ma_sp);
for b_lp in 1..dk_lh_nv.count loop
    if dk_lh_nv(b_lp)<>' ' then
        if dk_kieu(b_lp)='T' then b_tien:=b_tien+dk_tien(b_lp); end if;
        insert into bh_tauB_dk values(b_ma_dvi,b_so_id,b_so_id,dk_ma(b_lp),dk_ten(b_lp),dk_lh_nv(b_lp),dk_tien(b_lp),dk_phi(b_lp),dk_ptG(b_lp));
    end if;
end loop;
insert into bh_tauB values(
    b_ma_dvi,b_so_id,b_lan,b_so_hd,b_ngay_ht,'G',b_ttrang,b_kieu_hd,b_so_hd_g,
    b_phong,b_ma_kh,b_ten,b_ngay_hl,b_ngay_kt,b_nt_tien,b_tien,b_nt_phi,b_phi,' ',' ',b_nsd,sysdate);
PKH_JS_THAYa(dt_ct,'so_hd,ma_kh',b_so_hd||','||b_ma_kh);
insert into bh_tauB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_ct',dt_ct);
insert into bh_tauB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_dk',dt_dk);
if trim(dt_dkbs) is not null then
    insert into bh_tauB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_dkbs',dt_dkbs);
end if;
if trim(dt_lt) is not null then
    insert into bh_tauB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_lt',dt_lt);
end if;
if trim(dt_kbt) is not null then
    insert into bh_tauB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_kbt',dt_kbt);
end if;
if trim(dt_hu) is not null then
    insert into bh_tauB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_hu',dt_hu);
end if;
if trim(dt_kytt) is not null then
    insert into bh_tauB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_kytt',dt_kytt);
end if;
if dt_ttt is not null then
    insert into bh_tauB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_ttt',dt_ttt);
end if;
delete from bh_tauB_ls where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan;
insert into bh_tauB_ls (ma_dvi,so_id,lan,loai,txt) select ma_dvi,so_id,lan,loai,txt from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id  and lan=b_lan;
PBH_BAO_NV_NH(b_ma_dvi,b_nsd,b_so_id,b_so_hd,'TAU',b_ttrang,b_phong,b_ma_kh,b_ten,
    b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_tien,b_nt_phi,b_phi,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_TAUBG_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(3000); b_lenh varchar2(2000); b_lan number;
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
    b_tb varchar2(200); b_cdt varchar2(1);

    dk_bt pht_type.a_num; dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var;
    dk_ma_ct pht_type.a_var; dk_kieu pht_type.a_var;
    dk_tien pht_type.a_num; dk_pt pht_type.a_num; dk_phi pht_type.a_num;
    dk_thue pht_type.a_num; dk_ttoan pht_type.a_num; dk_cap pht_type.a_num; dk_ma_dk pht_type.a_var;
    dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num; dk_ptB pht_type.a_num;
    dk_ptG pht_type.a_num; dk_phiG pht_type.a_num; dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var; dk_luy pht_type.a_var;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_dkbs,dt_lt,dt_kbt,dt_hu,dt_kytt,dt_ttt');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_dkbs,dt_lt,dt_kbt,dt_hu,dt_kytt,dt_ttt using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_dkbs); FKH_JSa_NULL(dt_lt);
FKH_JSa_NULL(dt_kbt); FKH_JSa_NULL(dt_hu); FKH_JSa_NULL(dt_kytt);  FKH_JSa_NULL(dt_ttt); 
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_BG_JS_TEST(
    b_ma_dvi,b_nsd,b_so_id,'bh_tau',dt_ct,dt_kytt,
    b_so_hd,b_ngay_ht,b_ttrang,
    b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_loai_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,
    b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_phong,b_ma_kh,
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
PBH_TAUBG_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,b_lan,
    dt_ct,dt_dk,dt_dkbs,dt_lt,dt_kbt,dt_hu,dt_kytt,dt_ttt,
-- Chung
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
    b_so_hdL,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,
    b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_ngayD,b_phong,
    tt_ngay,tt_tien,
-- Rieng
    b_tenC,b_cmtC,b_mobiC,b_emailC,b_dchiC,b_ng_huong,
    b_nhom,b_loai,b_cap,b_vlieu,b_ttai,b_so_cn,b_dtich,b_csuat,b_gia,b_tuoi,
    b_ma_sp,b_dkien,b_md_sd,b_nv_bh,b_so_dk,b_ten_tau,b_nam_sx,
    b_hoi,b_hoi_tien,b_hoi_tyle,b_hoi_hh,b_tl_mgiu,
    dk_bt,dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,
    dk_cap,dk_ma_dk,dk_lh_nv,dk_t_suat,dk_ptB,dk_ptG,dk_phiG,dk_lkeP,dk_lkeB,dk_luy,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
FBH_BAO_TTRANGn(b_ma_dvi,b_so_id,b_ttrang,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hd' value b_so_hd,
    'ma_kh' value b_ma_kh,'lan' value b_lan) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
