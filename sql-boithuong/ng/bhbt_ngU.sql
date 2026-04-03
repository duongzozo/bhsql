create or replace procedure PBH_BT_NGu_LKE_NHOM
    (b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_so_hd varchar2(20); b_nhom varchar2(10);
    b_ma_dvi varchar2(10); b_so_id number; b_so_id_nh number;
    cs_phi clob; cs_bth clob;
begin
-- Dan - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Hop dong,nhom da xoa hoac chua duyet:loi';
b_lenh:=FKH_JS_LENH('so_hd,nhom');
FBH_NG_HD_SO_ID_GOI(b_so_hd,b_nhom,30000101,b_ma_dvi,b_so_id,b_so_id_nh);
if b_so_id=0 then raise PROGRAM_ERROR; end if;
FBH_BT_LKE_PHI(b_ma_dvi,b_so_id,cs_phi);
select JSON_ARRAYAGG(json_object(so_hs,ngay_mo,ttrang,tien,ma_dvi,so_id) order by ngay_mo desc)
    into cs_bth from bh_bt_ng where ma_dvi_ql=b_ma_dvi and so_id_hd=b_so_id and so_id_dt=b_so_id_nh;
select json_object('cs_phi' value cs_phi,'cs_bth' value cs_bth) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_NGu_NHOM(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_so_hd varchar2(20); b_nhom varchar2(10); b_ngay_xr number;
    b_ma_dvi varchar2(10); b_so_id number:=0; b_so_id_nh number; b_nv varchar2(10);
    dt_nhom_txt clob:=''; dt_nh_ct pht_type.a_clob; dt_nh_dk pht_type.a_clob; dt_nh_dkbs pht_type.a_clob;
    b_nh_nhom varchar2(10); b_noidi nvarchar2(4000); b_noiden nvarchar2(4000); b_dt_nhom varchar2(10);
    dt_kbt clob:=''; dt_btlke clob:=''; dt_dk clob; dt_dkbs clob; dt_lt clob:=''; dt_txt clob;
begin
-- Dan - Liet ke theo nhom
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Hop dong,nhom da xoa hoac chua duyet:loi';
b_lenh:=FKH_JS_LENH('so_hd,nhom,ngay_xr');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_nhom,b_ngay_xr using b_oraIn;
FBH_NG_HD_SO_ID_GOI(b_so_hd,b_nhom,b_ngay_xr,b_ma_dvi,b_so_id,b_so_id_nh);
if b_so_id=0 then raise PROGRAM_ERROR; end if;
b_nv:=FBH_NG_NV(b_ma_dvi,b_so_id);
select count(*) into b_i1 from bh_ng_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_nh;
if b_i1=1 then
    select dk,lt,kbt into dt_dk,dt_lt,dt_kbt from bh_ng_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_nh;
end if;
if b_nv = 'DLU' then
    select count(*) into b_i1 from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_nh';
if b_i1 > 0 then
 select FKH_JS_BONH(txt) into dt_nhom_txt from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_nh';
 b_lenh:=FKH_JS_LENH('dt_nh_ct');
 EXECUTE IMMEDIATE b_lenh bulk collect into dt_nh_ct using dt_nhom_txt;
 for b_lp in 1..dt_nh_ct.count loop
   b_lenh:=FKH_JS_LENH('nhom,noidi,noiden');
   EXECUTE IMMEDIATE b_lenh into b_nh_nhom,b_noidi,b_noiden using dt_nh_ct(b_lp);
   if b_nhom = b_nh_nhom then exit;
   else b_noidi:='';b_noiden:=''; end if;
 end loop;
end if;
end if;
dt_btlke:=FBH_BT_NG_BTH_LKE(b_so_id_nh);
select json_object('noidi' value b_noidi,'noiden' value b_noiden,'dt_lt' value dt_lt,'dt_kbt' value dt_kbt,
    'dt_btlke' value dt_btlke,'dt_dk' value dt_dk,'dt_dkbs' value dt_dkbs,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_BT_NGu_LIST_NHOM
    (b_ma_dvi varchar2,b_so_id number,dt_nhom out clob)
AS
    b_so_idB number; b_nv varchar2(10);
begin
-- Dan - Liet ke tu so ID
b_so_idB:=FBH_NG_SO_IDb(b_ma_dvi,b_so_id); b_nv:=FBH_NG_NV(b_ma_dvi,b_so_id);
if b_nv='SKU' then
    select JSON_ARRAYAGG(json_object('ma' value nhom,ten) order by nhom) into dt_nhom
        from bh_sk_nh where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    select JSON_ARRAYAGG(json_object('ma' value nhom,ten) order by nhom) into dt_nhom
        from bh_ngdl_nh where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
end;
/
create or replace procedure PBH_BT_NGu_LIST_NHOM
    (b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_hd varchar2(20):=trim(b_oraIn);
    b_ma_dvi varchar2(10); b_so_id number;
begin
-- Dan - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Hop dong da xoa hoac chua duyet 1:loi';
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_ng where so_hd=b_so_hd;
if b_so_id=0 then raise PROGRAM_ERROR; end if;
FBH_BT_NGu_LIST_NHOM(b_ma_dvi,b_so_id,b_oraOut);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_NGu_SO_HD(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000); b_so_hd varchar2(20);
    b_ma_dvi varchar2(10); b_so_id number:=0; b_nv varchar2(10); b_ngay_xr number;
    dt_ct clob; dt_nhom clob;
begin
-- Dan - Liet ke theo GCN
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Hop dong da xoa hoac chua duyet:loi';
b_lenh:=FKH_JS_LENH('so_hd,ngay_xr');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_ngay_xr using b_oraIn;
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_ng where so_hd=b_so_hd;
if b_so_id=0 then raise PROGRAM_ERROR; end if;
select nv into b_nv from bh_ng where so_id=b_so_id;
if b_nv='SKU' then 
  select json_object(ten,ngay_hl,ngay_kt,'ma_dvi_ql' value b_ma_dvi,
    'lhe_ten' value ten,'lhe_mobi' value mobi,'lhe_email' value email,'ma_nt' value nt_tien,'tpa' value FBH_DTAC_MA_TENl(tpa)) into dt_ct
    from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
elsif b_nv='DLU' then 
  select json_object(ten,ngay_hl,ngay_kt,'ma_dvi_ql' value b_ma_dvi,
    'lhe_ten' value ten,'lhe_mobi' value mobi,'lhe_email' value email,'ma_nt' value nt_tien) into dt_ct
    from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;

FBH_BT_NGu_LIST_NHOM(b_ma_dvi,b_so_id,dt_nhom);
select json_object('dt_ct' value dt_ct,'dt_nhom' value dt_nhom returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_NGu_SO_HDg(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_so_hd varchar2(20); b_nhom varchar2(10); b_ngay_xr number;
    b_ma_dvi varchar2(10); b_so_id number:=0; b_so_id_nh number;
begin
-- Nam - Lay dieu khoan theo nhom
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Hop dong,nhom da xoa hoac chua duyet 1:loi';
b_lenh:=FKH_JS_LENH('so_hd,nhom,ngay_xr');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_nhom,b_ngay_xr using b_oraIn;
FBH_NG_HD_SO_ID_GOI(b_so_hd,b_nhom,b_ngay_xr,b_ma_dvi,b_so_id,b_so_id_nh);
if b_so_id=0 then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,'tien_bh' value tien,'tien' value 0,ma_dvi,so_id,so_id_dt,bt,ten,tc,ma_ct,kieu,
    pt,phi,cap,ma_dk,lh_nv,t_suat,thue,ttoan,ptb,ptg,phig,lkep,lkeb,luy,lh_bh) order by bt returning clob) into b_oraOut
    from bh_ng_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_nh;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_NGU_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number; b_ngay_xr number;
    b_ma_dvi_ql varchar2(10); b_so_id_hd number; b_so_id_hdB number; b_so_id_dt number;
    dt_ct clob; dt_dk clob; dt_grv clob:=''; dt_tltt clob:=''; dt_tlpt clob:=''; dt_hk clob:='';
    dt_lt clob:=''; dt_kbt clob:=''; dt_ttt clob:=''; dt_nhom clob:=''; dt_txt clob;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_loi:='loi:Ho so da xoa:loi';
select ma_dvi_ql,so_id_hd,so_id_dt,ngay_xr into b_ma_dvi_ql,b_so_id_hd,b_so_id_dt,b_ngay_xr
    from bh_bt_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_so_id_hdB:=FBH_NG_SO_IDb(b_ma_dvi_ql,b_so_id_hd,b_ngay_xr);
select count(*) into b_i1 from bh_ng_kbt where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB and so_id_dt=b_so_id_dt;
if b_i1=1 then
    select lt,kbt into dt_lt,dt_kbt from bh_ng_kbt where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB and so_id_dt=b_so_id_dt;
end if;
select json_object(so_hs,tien,tienHK,'gcn' value FBH_NG_HD_GOIl(ma_dvi_ql,so_id_hd,gcn),'ma_dtri' value FBH_SK_DTRI_TENl(ma_dtri))
  into dt_ct from bh_bt_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ma,ten) order by bt) into dt_dk from bh_bt_ng_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ten) order by bt) into dt_grv from bh_bt_ng_grv where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object('ma' value ma,'ten' value ten,'muc' value muc) order by bt) into dt_tltt
    from bh_bt_ng_tttl where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ten,tien) order by bt) into dt_hk from bh_bt_ng_hk where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt from
       bh_bt_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai not in('dt_kbt');
select count(*) into b_i1 from bh_bt_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_tltt';
if b_i1=1 then
    select txt into dt_tltt from bh_bt_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_tltt';
end if;
select count(*) into b_i1 from bh_bt_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_tlpt';
if b_i1=1 then
    select txt into dt_tlpt from bh_bt_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_tlpt';
end if;
select count(*) into b_i1 from bh_bt_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
if b_i1=1 then
    select txt into dt_ttt from bh_bt_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
end if;
FBH_BT_NGu_LIST_NHOM(b_ma_dvi_ql,b_so_id_hd,dt_nhom);
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,
    'dt_nhom' value dt_nhom,'dt_ttt' value dt_ttt,'dt_lt' value dt_lt,'dt_kbt' value dt_kbt,'dt_tltt' value dt_tltt,
    'dt_tlpt' value dt_tlpt,'dt_ct' value dt_ct,'dt_dk' value dt_dk,'dt_grv' value dt_grv,
    'dt_hk' value dt_hk,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_NGu_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(2000); b_lenh varchar2(2000); b_i1 number; b_ngay_htC number;
    dt_ct clob; dt_dk clob; dt_grv clob; dt_hk clob; dt_tba clob; dt_kbt clob; dt_tltt clob; 
    dt_tlpt clob; dt_ttt clob; dt_bvi clob;

    b_so_id number; b_ngay_ht number; b_nv varchar2(10); b_so_hs varchar2(30); b_ttrang varchar2(1);
    b_kieu_hs varchar2(1); b_so_hs_g varchar2(20); b_phong varchar2(10);
    b_ngay_gui number; b_ngay_mo number; b_ngay_do number; b_ngay_xr number;
    b_n_trinh varchar2(200); b_n_duyet varchar2(200); b_ngay_qd number;
    b_nt_tien varchar2(5); b_c_thue varchar2(1); b_tien number; b_thue number;
    b_noP varchar2(1); b_bphi varchar2(1); b_dung varchar2(1); b_traN varchar2(1);
    b_gcn varchar2(20); b_ma_dvi_ql varchar2(10); b_so_hd varchar2(20); b_so_id_hd number; b_so_id_nh number; b_so_id_dt number;
    b_ma_khH varchar2(20); b_tenH nvarchar2(500); b_ma_kh varchar2(20); b_ten nvarchar2(500); 
    b_tienHK number; b_ma_nn varchar2(10); b_ma_dtri varchar2(10); b_loai_hs varchar2(1); b_tpa varchar2(500); b_so_tpa varchar2(20);

    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var; dk_ma_ct pht_type.a_var;
    dk_tien_bh pht_type.a_num; dk_pt_bt pht_type.a_num; dk_t_that pht_type.a_num;
    dk_tien pht_type.a_num; dk_thue pht_type.a_num; dk_tien_qd pht_type.a_num; dk_thue_qd pht_type.a_num;
    dk_cap pht_type.a_var; dk_ma_dk pht_type.a_var; dk_ma_bs pht_type.a_var;
    dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num; dk_lkeB pht_type.a_var;

    grv_ma pht_type.a_var; grv_ten pht_type.a_nvar; grv_so pht_type.a_var; grv_ng_cap pht_type.a_num; grv_tien pht_type.a_num;
    hk_ma pht_type.a_var; hk_ten pht_type.a_nvar; hk_ma_nt pht_type.a_var;
    hk_tien pht_type.a_num; hk_thue pht_type.a_num; hk_tien_qd pht_type.a_num; hk_thue_qd pht_type.a_num;
    tba_ten pht_type.a_nvar; tba_ma_nt pht_type.a_var; tba_tien pht_type.a_num;
    r_hs bh_bt_ng%rowtype;

begin
-- Dan - Nhap ho so boi thuong
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_lenh:=FKH_JS_LENH('so_id');
EXECUTE IMMEDIATE b_lenh into b_so_id using b_oraIn;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_grv,dt_tltt,dt_tlpt,dt_hk,dt_tba,dt_ttt,dt_bvi');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_grv,dt_tltt,dt_tlpt,dt_hk,dt_tba,dt_ttt,dt_bvi using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_grv); FKH_JSa_NULL(dt_tltt);
FKH_JSa_NULL(dt_tlpt); FKH_JSa_NULL(dt_hk); FKH_JSa_NULL(dt_ttt); FKH_JSa_NULL(dt_bvi);

if b_so_id<>0 then
    select count(*) into b_i1 from bh_bt_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1=0 then b_so_id:=0; end if;
end if;
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
else
    b_loi:='loi:Ho so dang xu ly:loi';
    select ngay_ht into b_ngay_htC from bh_bt_ng where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
    if sql%rowcount=0 then raise PROGRAM_ERROR; end if;
    PBH_BT_NG_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,true,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_BT_TEST(b_ma_dvi,b_nsd,b_so_id,b_ngay_htC,dt_ct,
    b_ngay_ht,b_so_hs,b_ttrang,b_kieu_hs,b_so_hs_g,b_phong,b_ngay_gui,b_ngay_mo,b_ngay_do,b_ngay_xr,
    b_n_trinh,b_n_duyet,b_ngay_qd,b_nt_tien,b_c_thue,b_tien,b_thue,b_noP,b_bphi,b_dung,b_traN,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_NGu_TEST(
    b_ma_dvi,b_nsd,b_so_id,dt_ct,dt_dk,dt_grv,dt_hk,dt_kbt,
    b_nv,b_gcn,b_loai_hs,b_ma_dvi_ql,b_so_hd,b_so_id_hd,b_so_id_nh,b_so_id_dt,
    b_ma_kh,b_ten,b_tienHK,b_ma_nn,b_ma_dtri,b_tpa,b_so_tpa,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_tien_bh,dk_pt_bt,dk_t_that,
    dk_tien,dk_thue,dk_tien_qd,dk_thue_qd,dk_cap,dk_ma_dk,dk_ma_bs,dk_lh_nv,dk_t_suat,dk_lkeB,
    grv_ma,grv_ten,grv_so,grv_ng_cap,grv_tien,
    hk_ma,hk_ten,hk_ma_nt,hk_tien,hk_thue,hk_tien_qd,hk_thue_qd,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_NG_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,dt_ct,dt_dk,dt_grv,dt_hk,dt_tba,dt_kbt,dt_tltt,dt_tlpt,dt_ttt,dt_bvi,
    b_ngay_ht,b_nv,b_so_hs,b_ttrang,b_kieu_hs,b_so_hs_g,b_loai_hs,'C',b_phong,
    b_ngay_gui,b_ngay_mo,b_ngay_do,b_ngay_xr,b_n_trinh,b_n_duyet,b_ngay_qd,
    b_nt_tien,b_c_thue,b_tien,b_thue,b_noP,b_bphi,b_dung,b_traN,
    b_gcn,b_ma_dvi_ql,b_so_hd,b_so_id_hd,b_so_id_dt,
    b_ma_khH,b_tenH,b_ma_kh,b_ten,b_tienHK,b_ma_nn,b_ma_dtri,b_tpa,b_so_tpa,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_tien_bh,dk_pt_bt,dk_t_that,
    dk_tien,dk_thue,dk_tien_qd,dk_thue_qd,dk_cap,dk_ma_dk,dk_ma_bs,dk_lh_nv,dk_t_suat,dk_lkeB,
    grv_ma,grv_ten,grv_so,grv_ng_cap,grv_tien,
    hk_ma,hk_ten,hk_ma_nt,hk_tien,hk_thue,hk_tien_qd,hk_thue_qd,
    tba_ten,tba_ma_nt,tba_tien,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hs' value b_so_hs) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_NGu_TEST(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    dt_ct clob,dt_dk clob,dt_grv clob,dt_hk clob,dt_kbt out clob,
    b_nv out varchar2,b_nhom out varchar2,b_loai_hs out varchar2,
    b_ma_dvi_ql out varchar2,b_so_hd out varchar2,b_so_id_hd out number,b_so_id_nh out number,b_so_id_dt out number,
    b_ma_kh out varchar2,b_ten out nvarchar2,b_tienHK out number,b_ma_nn out varchar2,
    b_ma_dtri out varchar2,b_tpa out varchar2,b_so_tpa out varchar2,

    dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,dk_tc out pht_type.a_var,dk_ma_ct out pht_type.a_var,
    dk_tien_bh out pht_type.a_num,dk_pt_bt out pht_type.a_num,dk_t_that out pht_type.a_num,
    dk_tien out pht_type.a_num,dk_thue out pht_type.a_num,dk_tien_qd out pht_type.a_num,dk_thue_qd out pht_type.a_num,
    dk_cap out pht_type.a_var,dk_ma_dk out pht_type.a_var,dk_ma_bs out pht_type.a_var,
    dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,dk_lkeB out pht_type.a_var,

    grv_ma out pht_type.a_var,grv_ten out pht_type.a_nvar,grv_so out pht_type.a_var,grv_ng_cap out pht_type.a_num,grv_tien out pht_type.a_num,
    hk_ma out pht_type.a_var,hk_ten out pht_type.a_nvar,hk_ma_nt out pht_type.a_var,
    hk_tien out pht_type.a_num,hk_thue out pht_type.a_num,
    hk_tien_qd out pht_type.a_num,hk_thue_qd out pht_type.a_num,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_ktraHL varchar2(1):='K'; b_nhomN nvarchar2(500);
    b_so_id_hdB number; b_tg number; b_nt_tien varchar2(5);
    b_ttrang varchar2(1); b_ngay_xr number; b_ngay_gr number; b_noP varchar2(1); b_tien number;
    dk_bt_con pht_type.a_num;
begin
-- Dan kiem tra thong tin nhap ho so boi thuong
b_lenh:=FKH_JS_LENH('ttrang,so_hd,gcn,ngay_xr,ngay_gr,nop,ma_nn,ma_dtri,loai_hs,tpa,so_tpa');
EXECUTE IMMEDIATE b_lenh into b_ttrang,b_so_hd,b_nhom,b_ngay_xr,b_ngay_gr,b_noP,b_ma_nn,b_ma_dtri,b_loai_hs,b_tpa,b_so_tpa  using dt_ct;
b_nhom:=nvl(trim(b_nhom),' '); b_so_id_dt:=nvl(b_so_id_dt,0);
if b_nhom=' ' then b_loi:='loi:Nhap nhom:loi'; return; end if;
if b_loai_hs not in('T','B','A') then b_loi:='loi:Sai loai ho so:loi'; return; end if;
if b_loai_hs='A' then
    if b_tpa=' ' then
        b_loi:='loi:Nhap TPA:loi'; return;
    elsif FBH_MA_GDINH_NV(b_tpa,'NG')<>'C' or FBH_DTAC_MA_HAN(b_tpa)='K' then
        b_loi:='loi:Sai ma TPA:loi'; return;
    end if;
end if;
FBH_NG_HD_SO_ID_GOI(b_so_hd,b_nhom,b_ngay_xr,b_ma_dvi_ql,b_so_id_hd,b_so_id_nh);
if b_so_id=0 then b_loi:='loi:Hop dong da xoa hoac chua duyet:loi'; return; end if;
b_so_id_hdB:=FBH_NG_SO_IDb(b_ma_dvi_ql,b_so_id_hd,b_ngay_xr);
select nv,so_hd,ma_kh,ten,nt_tien into b_nv,b_so_hd,b_ma_kh,b_ten,b_nt_tien
    from bh_ng where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,tien_bh,pt_bt,t_that,tien,cap,ma_dk,ma_bs,lh_nv,t_suat,lkeb,bt_con');
EXECUTE IMMEDIATE b_lenh bulk collect into
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_tien_bh,dk_pt_bt,dk_t_that,
    dk_tien,dk_cap,dk_ma_dk,dk_ma_bs,dk_lh_nv,dk_t_suat,dk_lkeB,dk_bt_con using dt_dk;
if dk_ma.count=0 then b_loi:='loi:Nhap dieu khoan:loi'; return; end if;
b_tg:=FTT_TRA_TGTT(b_ma_dvi,b_ngay_xr,b_nt_tien);
b_tien:=0;
for b_lp in 1..dk_ma.count loop
    dk_thue(b_lp):=0; dk_thue_qd(b_lp):=0;
    if b_nt_tien='VND' then
        dk_tien_qd(b_lp):=dk_tien(b_lp);
    else
        dk_tien_qd(b_lp):=round(b_tg*dk_tien(b_lp),0);
    end if;
    if trim(dk_lh_nv(b_lp)) is not null then
        b_tien:=b_tien+dk_tien(b_lp);
    end if;
end loop;
b_lenh:=FKH_JS_LENH('ma,ten,so_grv,ng_cap,tien');
EXECUTE IMMEDIATE b_lenh bulk collect into grv_ma,grv_ten,grv_so,grv_ng_cap,grv_tien using dt_grv;
for b_lp in 1..grv_ma.count loop
    if grv_ma(b_lp)=' ' or grv_so(b_lp)=' ' or grv_ng_cap(b_lp)=0 then
        b_loi:='loi:Giay ra vien can nhap du: ma benh vien, so CT, ngay cap:loi'; return;
    end if;
    select count(*) into b_i1 from bh_bt_ng_grv where ma=grv_ma(b_lp) and so=grv_so(b_lp) and ng_cap=grv_ng_cap(b_lp);
    grv_ma(b_lp):=nvl(trim(grv_ma(b_lp)),' '); grv_so(b_lp):=nvl(trim(grv_so(b_lp)),' '); grv_ng_cap(b_lp):=nvl(grv_ng_cap(b_lp),0);
    if b_i1<>0 then b_loi:='loi:Trung giay ra vien: '||grv_so(b_lp)||':loi'; return; end if;
end loop;
b_tienHK:=0;
if trim(dt_hk) is null then
    PKH_MANG_KD(hk_ma_nt);
else
    b_lenh:=FKH_JS_LENH('ma,ten,tien');
    EXECUTE IMMEDIATE b_lenh bulk collect into hk_ma,hk_ten,hk_tien using dt_hk;
    for b_lp in 1..hk_ten.count loop
        hk_ma(b_lp):=nvl(trim(hk_ma(b_lp)),to_char(b_lp));
        hk_ma_nt(b_lp):=b_nt_tien; hk_thue(b_lp):=0; hk_thue_qd(b_lp):=0;
        b_tienHK:=b_tienHK+hk_tien(b_lp);
        if b_nt_tien='VND' then
            hk_tien_qd(b_lp):=hk_tien(b_lp);
        else
            hk_tien_qd(b_lp):=round(b_tg*hk_tien(b_lp),0);
        end if;
    end loop;
end if;
dt_kbt:='';
if b_ttrang in('T','D') then
    if b_tien<b_tienHK then b_loi:='loi:Tien ho so nho hon tien huong khac:loi'; return; end if;
    if FBH_HD_HU(b_ma_dvi_ql,b_so_id_hd,b_ngay_xr)='C' then b_loi:='loi:Da cham dut hop dong:loi'; return; end if;
    for b_lp in 1..dk_ma.count loop
        if dk_bt_con(b_lp)<0 then
            b_loi:='loi:Dieu khoan '||dk_ma(b_lp)||' boi thuong vuot muc trach nhiem :loi'; return;
        end if;
    end loop;
    --if b_noP='K' and FBH_HD_HOI_NOPHI(b_ma_dvi_ql,b_so_id_hd)='C' then
    --    b_loi:='loi:Khach hang con no phi:loi'; return;
    --end if;
    select count(*) into b_i1 from bh_ng_kbt where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB and so_id_dt=b_so_id_nh;
    if b_i1<>0 then
        select kbt into dt_kbt from bh_ng_kbt where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB and so_id_dt=b_so_id_nh;
    end if;
    dt_kbt:=FKH_JS_BONH(dt_kbt);
    PBH_BT_NG_KBT(b_ma_dvi_ql,b_so_id_hd,b_so_id_nh,b_ktraHL,dt_ct,dt_dk,dt_kbt,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
