create or replace procedure PBH_HOPBH_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number; b_lan number;
    dt_ct clob; dt_hk clob; ds_ct clob; ds_dk clob; ds_dkbs clob:='';
    ds_lt clob:=''; ds_kbt clob:=''; ds_ttt clob:=''; dt_kytt clob;

begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','HOP','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
select nvl(max(lan),0) into b_lan from bh_hopB where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_lan=0 then b_loi:='loi:Bao gia da xoa:loi'; raise PROGRAM_ERROR; end if;
select txt into dt_ct from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ct';
select count(*) into b_i1 from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_hk';
if b_i1=1 then
    select txt into dt_hk from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_hk';
end if;
select txt into ds_ct from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_ct';
select txt into ds_dk from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_dk';
select count(*) into b_i1 from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_dkbs';
if b_i1=1 then
    select txt into ds_dkbs from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_dkbs';
end if;
select count(*) into b_i1 from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_lt';
if b_i1=1 then
    select txt into ds_lt from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_lt';
end if;
select count(*) into b_i1 from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_kbt';
if b_i1=1 then
    select txt into ds_kbt from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_kbt';
end if;
select count(*) into b_i1 from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_ttt';
if b_i1=1 then
    select txt into ds_ttt from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_ttt';
end if;
select count(*) into b_i1 from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_kytt';
if b_i1<>0 then
    select txt into dt_kytt from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_kytt';
end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,
    'dt_ct' value dt_ct,'dt_hk' value dt_hk,
    'ds_ct' value ds_ct,'ds_dk' value ds_dk,'ds_dkbs' value ds_dkbs,'ds_lt' value ds_lt,
    'ds_kbt' value ds_kbt,'ds_ttt' value ds_ttt,'dt_kytt' value dt_kytt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HOPBH_CTbg(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number; b_lan number;
    dt_ct clob; dt_hk clob; ds_ct clob; ds_dk clob; ds_dkbs clob:='';
    ds_lt clob:=''; ds_kbt clob:=''; ds_ttt clob:=''; dt_kytt clob;
begin
-- Nam - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','HOP','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id,lan');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id,b_lan using b_oraIn;
select txt into dt_ct from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ct';
select count(*) into b_i1 from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_hk';
if b_i1=1 then
    select txt into dt_hk from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_hk';
end if;
select txt into ds_ct from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_ct';
select txt into ds_dk from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_dk';
select count(*) into b_i1 from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_dkbs';
if b_i1=1 then
    select txt into ds_dkbs from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_dkbs';
end if;
select count(*) into b_i1 from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_lt';
if b_i1=1 then
    select txt into ds_lt from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_lt';
end if;
select count(*) into b_i1 from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_kbt';
if b_i1=1 then
    select txt into ds_kbt from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_kbt';
end if;
select count(*) into b_i1 from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_ttt';
if b_i1=1 then
    select txt into ds_ttt from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_ttt';
end if;
select count(*) into b_i1 from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_kytt';
if b_i1<>0 then
    select txt into dt_kytt from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_kytt';
end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,
    'dt_ct' value dt_ct,'dt_hk' value dt_hk,
    'ds_ct' value ds_ct,'ds_dk' value ds_dk,'ds_dkbs' value ds_dkbs,'ds_lt' value ds_lt,
    'ds_kbt' value ds_kbt,'ds_ttt' value ds_ttt,'dt_kytt' value dt_kytt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HOPBH_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    dt_ct in out clob,dt_hk clob,ds_ct clob,ds_dk clob,ds_dkbs clob,ds_lt clob,ds_kbt clob,dt_kytt clob, ds_ttt clob,
    b_so_hd varchar2,b_ngay_ht number,b_ttrang varchar2,b_kieu_hd varchar2,b_so_hd_g varchar2,
    b_ma_kh varchar2,b_ten nvarchar2,b_ngay_hl number,b_ngay_kt number,
    b_nt_tien varchar2,b_nt_phi varchar2,b_phong varchar2,b_lan out number,b_ma_sp varchar2,
    dvi_so_id pht_type.a_num,dvi_dtuong pht_type.a_nvar,dvi_ngay_hl pht_type.a_num,dvi_ngay_kt pht_type.a_num,
    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_kieu pht_type.a_var,dk_ptG pht_type.a_num,dk_tien pht_type.a_num,dk_phi pht_type.a_num,
    dk_lh_nv pht_type.a_var,b_loi out varchar2)
AS
    b_i1 number; b_ttrang_bg varchar2(1); b_tien number:=0; b_phi number:=0;
begin
-- Nam - Nhap
b_loi:='loi:Loi Table bh_hopB:loi';
b_lan:=FKH_JS_GTRIn(dt_ct,'lan');
select nvl(max(lan),0) into b_i1 from bh_hopB where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_lan <> 0 and b_lan < b_i1 then b_loi:='loi:Khong duoc sua bao gia cu:loi'; return; end if;
if b_lan <> b_i1 then
  select nvl(ttrang,' ') into b_ttrang_bg from bh_hopB where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_i1;
  if b_ttrang_bg <> ' ' and b_ttrang_bg <> 'D' then b_loi:='loi:Phai duyet bao gia lan '||b_i1||':loi'; return; end if;
end if;
if b_lan = 0 then b_lan:=b_i1+1; end if;
PKH_JS_THAYn(dt_ct,'lan',b_lan);
PBH_HOPB_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'N',b_lan,b_loi);
if b_loi is not null then return; end if;
for b_lp in 1..dk_ma.count loop
    if dk_lh_nv(b_lp)<>' ' then
        b_tien:=b_tien+dk_tien(b_lp); b_phi:=b_phi+dk_phi(b_lp);
        insert into bh_hopB_dk values(b_ma_dvi,b_so_id,b_so_id,dk_ma(b_lp),dk_ten(b_lp),dk_kieu(b_lp),dk_lh_nv(b_lp),dk_tien(b_lp),dk_phi(b_lp),dk_ptG(b_lp));
    end if;
end loop;
insert into bh_hopB values(
    b_ma_dvi,b_so_id,b_lan,b_so_hd,b_ngay_ht,'HOP','H',b_ttrang,b_kieu_hd,b_so_hd_g,
    b_phong,b_ma_kh,b_ten,b_ngay_hl,b_ngay_kt,b_ma_sp,b_nt_tien,b_tien,b_nt_phi,b_phi,' ',' ',b_nsd,sysdate);
for b_lp in 1..dvi_so_id.count loop
    insert into bh_hopB_ds values(b_ma_dvi,b_so_id,dvi_so_id(b_lp),b_ten,b_ma_sp,dvi_ngay_hl(b_lp),dvi_ngay_kt(b_lp));
end loop;
PKH_JS_THAYa(dt_ct,'so_hd,ma_kh',b_so_hd||','||b_ma_kh);
insert into bh_hopB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_ct',dt_ct);
if dt_hk is not null then
  insert into bh_hopB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_hk',dt_hk);
end if;
insert into bh_hopB_txt values(b_ma_dvi,b_so_id,b_lan,'ds_ct',ds_ct);
insert into bh_hopB_txt values(b_ma_dvi,b_so_id,b_lan,'ds_dk',ds_dk);
insert into bh_hopB_txt values(b_ma_dvi,b_so_id,b_lan,'ds_dkbs',ds_dkbs);
if ds_ttt is not null then
  insert into bh_hopB_txt values(b_ma_dvi,b_so_id,b_lan,'ds_ttt',ds_ttt);
end if;
if ds_lt is not null then
    insert into bh_hopB_txt values(b_ma_dvi,b_so_id,b_lan,'ds_lt',ds_lt);
end if;
if ds_kbt is not null then
    insert into bh_hopB_txt values(b_ma_dvi,b_so_id,b_lan,'ds_kbt',ds_kbt);
end if;
if trim(dt_kytt) is not null then
    insert into bh_hopB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_kytt',dt_kytt);
end if;
delete from bh_hopB_ls where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan;
insert into bh_hopB_ls (ma_dvi,so_id,lan,loai,txt) select ma_dvi,so_id,lan,loai,txt from bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id  and lan=b_lan;
PBH_BAO_NV_NH(b_ma_dvi,b_nsd,b_so_id,b_so_hd,'HOP',b_ttrang,b_phong,b_ma_kh,b_ten,
    b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_tien,b_nt_phi,b_phi,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HOPBH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_lan number;
    dt_ct clob; dt_hk clob; dt_kytt clob;
    ds_ct clob; ds_dk clob; ds_dkbs clob; ds_lt clob; ds_kbt clob; ds_ttt clob;
--  Chung
    b_so_id number; b_so_hd varchar2(20); b_ngay_ht number; b_ttrang varchar2(1); b_kieu_hd varchar2(1); b_so_hd_g varchar2(20);
    b_kieu_kt varchar2(1); b_ma_kt varchar2(20); 
    b_loai_kh varchar2(1); b_ma_kh varchar2(20); b_ten nvarchar2(500); b_dchi nvarchar2(500);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_gio_hl varchar2(20); b_ngay_hl number; b_gio_kt varchar2(20); b_ngay_kt number; b_ngay_cap number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_c_thue varchar2(1);
    b_phi number; b_giam number; b_thue number; b_ttoan number; b_hhong number;
    b_so_idG number; b_phong varchar2(10);
    tt_ngay pht_type.a_num; tt_tien pht_type.a_num;
--  Rieng
    b_ma_sp varchar2(10); b_cdich varchar2(10); b_goi varchar2(10);

    dvi_so_id pht_type.a_num; dvi_kieu_gcn pht_type.a_var; dvi_gcn pht_type.a_var; dvi_gcnG pht_type.a_var;
    dvi_dtuong pht_type.a_nvar;
    dvi_gio_hl pht_type.a_var; dvi_ngay_hl pht_type.a_num; dvi_gio_kt pht_type.a_var; dvi_ngay_kt pht_type.a_num;
    dvi_ngay_cap pht_type.a_num; dvi_phi pht_type.a_num; dvi_thue pht_type.a_num; dvi_ttoan pht_type.a_num;
    dvi_so_idP pht_type.a_num;

    dk_so_id pht_type.a_num; dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var; dk_ma_ct pht_type.a_var;
    dk_kieu pht_type.a_var; dk_tien pht_type.a_num; dk_pt pht_type.a_num; dk_ppt pht_type.a_num; dk_phi pht_type.a_num;
    dk_thue pht_type.a_num; dk_ttoan pht_type.a_num; dk_cap pht_type.a_num; dk_ma_dk pht_type.a_var;
    dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num; dk_ptB pht_type.a_num; dk_phiB pht_type.a_num;
    dk_ptG pht_type.a_num; dk_phiG pht_type.a_num;dk_lkeM  pht_type.a_var; dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var;
    dk_luy pht_type.a_var; dk_lh_bh pht_type.a_var;
    lt_so_id pht_type.a_num; lt_lt pht_type.a_clob; lt_kbt pht_type.a_clob;
-- xu ly

begin
-- Nam - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HOP','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_hk,ds_ct,ds_dk,ds_dkbs,ds_lt,ds_kbt,ds_ttt,dt_kytt');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_hk,ds_ct,ds_dk,ds_dkbs,ds_lt,ds_kbt,ds_ttt,dt_kytt using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_hk); FKH_JSa_NULL(dt_kytt);
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BG_JS_TEST(
    b_ma_dvi,b_nsd,b_so_id,'bh_hopB',dt_ct,dt_kytt,
    b_so_hd,b_ngay_ht,b_ttrang,
    b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_loai_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,
    b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_phong,b_ma_kh,
    tt_ngay,tt_tien,b_loi,'HOP');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_HOPH_TESTr(
    b_ma_dvi,b_nsd,b_so_idG,
    dt_ct,ds_ct,ds_dk,ds_dkbs,ds_lt,ds_kbt,
    b_ma_sp,b_cdich,b_goi,
    dvi_so_id,dvi_kieu_gcn,dvi_gcn,dvi_gcnG,dvi_dtuong,
    dvi_gio_hl,dvi_ngay_hl,dvi_gio_kt,dvi_ngay_kt,dvi_ngay_cap,dvi_phi,dvi_thue,dvi_ttoan,dvi_so_idP,
    dk_so_id,dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_ppt,dk_phi,dk_thue,dk_ttoan,dk_cap,dk_ma_dk,
    dk_lh_nv,dk_t_suat,dk_ptB,dk_phiB,dk_ptG,dk_phiG,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy,dk_lh_bh,
    lt_so_id,lt_lt,lt_kbt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_HOPBH_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,
    dt_ct,dt_hk,ds_ct,ds_dk,ds_dkbs,ds_lt,ds_kbt,dt_kytt,ds_ttt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,
    b_ma_kh,b_ten,b_ngay_hl,b_ngay_kt,
    b_nt_tien,b_nt_phi,b_phong,b_lan,b_ma_sp,
    dvi_so_id,dvi_dtuong,dvi_ngay_hl,dvi_ngay_kt,
    dk_ma,dk_ten,dk_kieu,dk_ptG,dk_tien,dk_phi,dk_lh_nv,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
FBH_BAO_TTRANGn(b_ma_dvi,b_so_id,b_ttrang,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hd' value b_so_hd, 'ma_kh' value b_ma_kh,'lan' value b_lan) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/