create or replace procedure PBH_NONGVNH_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngay number:=PKH_NG_CSO(sysdate);
    cs_sp clob; cs_cdich clob; cs_goi clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NONG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten) into cs_sp from
    bh_nongvn_sp a,(select distinct ma_sp from bh_nongvn_phi where nhom in('H') and ngay_bd<=b_ngay and ngay_kt>b_ngay) b
    where a.ma=b.ma_sp and FBH_NONGVN_MA_SP_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten) into cs_cdich from
    bh_ma_cdich a,(select distinct cdich from bh_nongvn_phi where nhom in('H') and ngay_bd<=b_ngay and ngay_kt>b_ngay) b
    where a.ma=b.cdich and FBH_MA_CDICH_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten) into cs_goi from
    bh_nongvn_goi a,(select distinct goi from bh_nongvn_phi where nhom in('H') and ngay_bd<=b_ngay and ngay_kt>b_ngay) b
    where a.ma=b.goi and FBH_NONGVN_GOI_HAN(a.ma)='C';
select json_object('cs_sp' value cs_sp,'cs_cdich' value cs_cdich,'cs_goi' value cs_goi returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NONGVNH_MOd(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_ngay number:=PKH_NG_CSO(sysdate);
    cs_khd clob; cs_kbt clob; cs_ttt clob;
begin
-- Nam - Tham so mo form
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NONG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_khd
    from bh_kh_ttt where ps='KHD' and nv='NONG';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_kbt
    from bh_kh_ttt where ps='KBT' and nv='NONG';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_ttt
    from bh_kh_ttt where ps='HD' and nv='NONG';
select json_object('cs_khd' value cs_khd,'cs_kbt' value cs_kbt,'cs_ttt' value cs_ttt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NONGVNH_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number;
    dt_ct clob; ds_ct clob; dt_hk clob; ds_dk clob; ds_dkbs clob:=''; ds_pvi clob;
    ds_lt clob:=''; ds_kbt clob:=''; ds_ttt clob:=''; dt_kytt clob; dt_txt clob;
begin
-- Nam - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','NONG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
select json_object(so_hd,ma_kh,so_dt) into dt_ct from bh_nongvn where ma_dvi=b_ma_dvi and so_id=b_so_id;
select txt into ds_ct from bh_nongvn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ct';
select count(*) into b_i1 from bh_nongvn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
if b_i1=1 then
    select txt into dt_hk from bh_nongvn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
end if;
select txt into ds_dk from bh_nongvn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_dk';
select txt into ds_pvi from bh_nongvn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_pvi';
select count(*) into b_i1 from bh_nongvn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_dkbs';
if b_i1=1 then
    select txt into ds_dkbs from bh_nongvn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_dkbs';
end if;
select count(*) into b_i1 from bh_nongvn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_lt';
if b_i1=1 then
    select txt into ds_lt from bh_nongvn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_lt';
end if;
select count(*) into b_i1 from bh_nongvn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_kbt';
if b_i1=1 then
    select txt into ds_kbt from bh_nongvn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_kbt';
end if;
select count(*) into b_i1 from bh_nongvn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ttt';
if b_i1=1 then
    select txt into ds_ttt from bh_nongvn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ttt';
end if;
select JSON_ARRAYAGG(json_object(ngay,tien) order by ngay) into dt_kytt from bh_nongvn_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_nongvn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'ds_ct' value ds_ct,
    'ds_dk' value ds_dk,'ds_dkbs' value ds_dkbs,'ds_pvi' value ds_pvi,'ds_lt' value ds_lt,
    'ds_kbt' value ds_kbt,'ds_ttt' value ds_ttt,'dt_kytt' value dt_kytt,'dt_hk' value dt_hk,
    'dt_ct' value dt_ct,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NONGVNH_TESTd(
    dt_ctH clob,dt_ct in out clob,dt_dk clob,dt_dkbs clob,dt_pvi clob,
    b_ma_dvi varchar2,b_ttrang varchar2,b_kieu_hd varchar2,
    b_nt_tien varchar2,b_nt_phi varchar2,b_tygia number,
    b_ngay_hlH number,b_ngay_ktH number,b_ngay_capH number,
    b_so_id_dt out number,b_kieu_gcn out varchar2,b_gcn out varchar2,b_gcnG out varchar2,
    b_dvi out nvarchar2,b_ddiem out nvarchar2,b_cdt out varchar2,
    b_tdx out number,b_tdy out number,b_bk out number,

    b_loai out varchar2,b_kvuc out varchar2,b_qmo out varchar2,b_tuoi_t out number,b_tuoi_d out number,

    b_ngay_hl out number,b_ngay_kt out number,b_ngay_cap out number,b_so_idP out number,
    dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,dk_tc out pht_type.a_var,
    dk_ma_ct out pht_type.a_var,dk_kieu out pht_type.a_var,
    dk_lkeM out pht_type.a_var,dk_lkeP out pht_type.a_var,dk_lkeB out pht_type.a_var,dk_luy out pht_type.a_var,
    dk_ktru out pht_type.a_var,
    dk_ma_dk out pht_type.a_var,dk_ma_dkC out pht_type.a_var,dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,
    dk_cap out pht_type.a_num,dk_nv out pht_type.a_var,
    dk_tien out pht_type.a_num,dk_pt out pht_type.a_num,
    dk_phi out pht_type.a_num,dk_thue out pht_type.a_num,dk_ttoan out pht_type.a_num,
    dk_ptB out pht_type.a_num,dk_phiB out pht_type.a_num,
    dk_pvi_ma out pht_type.a_var,dk_pvi_tc out pht_type.a_var,dk_pvi_ktru out pht_type.a_var,b_loi out varchar2)
AS
    b_i1 number; b_lenh varchar2(2000); dt_khd clob; b_txt clob;
    b_nhom varchar2(1); b_ma_sp varchar2(10); b_cdich varchar2(10); b_goi varchar2(10);
    a_thay pht_type.a_num;
begin
-- Nam - Nhap
b_loi:='loi:Loi xu ly PBH_NONGVNH_TESTd:loi';
b_lenh:=FKH_JS_LENH('so_id_dt,gcn,gcn_g,ngay_kt,dvi,ddiem,tuoi_t,tuoi_d,cdt,tdx,tdy');
EXECUTE IMMEDIATE b_lenh into
    b_so_id_dt,b_gcn,b_gcnG,b_ngay_kt,b_dvi,b_ddiem,b_tuoi_t,b_tuoi_d,b_cdt,b_tdx,b_tdy using dt_ct;
PBH_NONGVN_BPHI_TSO(dt_ct,b_nhom,b_ma_sp,b_cdich,b_goi,b_loai,b_kvuc,b_qmo,b_ngay_hl);
PBH_NONGVN_BPHI_TSOt(b_ma_sp,b_cdich,b_goi,b_loai,b_kvuc,b_qmo,b_loi);
if b_loi is not null then return; end if;
b_dvi:=trim(b_dvi); b_ddiem:=trim(b_ddiem); b_cdt:=nvl(trim(b_cdt),' ');
if b_dvi is null or b_ddiem is null then b_loi:='loi:Nhap dia diem, dia chi bao hiem:loi'; return; end if;
if b_tdx=0 or b_tdy=0 then b_loi:='loi:Chua xac dinh toa do dia diem '||b_dvi||':loi'; return; end if;
b_bk:=10;
if b_ngay_kt is null or b_ngay_kt in(0,30000101) or b_ngay_kt<b_ngay_hl or b_ngay_kt>b_ngay_ktH then
    b_ngay_kt:=b_ngay_ktH;
end if;
if b_ngay_hl is null or b_ngay_hl in(0,30000101) or b_ngay_hl<b_ngay_hlH or b_ngay_hl>b_ngay_kt then
    b_ngay_hl:=b_ngay_hlH;
end if;
b_kieu_gcn:='G'; b_ngay_cap:=b_ngay_capH;
b_gcn:=nvl(trim(b_gcn),' '); b_gcnG:=nvl(trim(b_gcnG),' ');
if b_so_id_dt<100000 then
    PHT_ID_MOI(b_so_id_dt,b_loi);
    if b_loi is not null then return; end if;
    b_gcn:=substr(to_char(b_so_id_dt),3); b_gcnG:=' ';
elsif b_kieu_hd in('S','B') and b_gcnG<>' ' then
    select count(*) into b_i1 from bh_nongvn_dvi where ma_dvi=b_ma_dvi and so_id_dt=b_so_id_dt and gcn=b_gcnG;
    if b_i1=0 then b_loi:='loi:GCN '||b_gcnG||' da xoa:loi'; return; end if;
    b_kieu_gcn:=b_kieu_hd;
    if b_gcn=b_gcnG then b_gcn:=' '; end if;
end if;
if b_gcn=' ' or instr(b_gcn,'.')=2 then
    b_gcn:=substr(to_char(b_so_id_dt),3);
    if b_kieu_gcn<>'G' then
        select count(*) into b_i1 from bh_nongvn_dvi where ma_dvi=b_ma_dvi and so_id_dt=b_so_id_dt and kieu_gcn=b_kieu_hd;
        if(b_i1>0) then
           select max(REGEXP_SUBSTR(gcn, 'B([0-9]+)', 1, 1, NULL, 1)) into b_i1 from bh_nongvn_dvi where ma_dvi=b_ma_dvi and so_id_dt=b_so_id_dt and kieu_gcn=b_kieu_hd;
        end if;
        b_gcn:=b_gcn||'/'||b_kieu_hd||to_char(b_i1+1);
    end if;
else
    select nvl(max(ngay_cap),b_ngay_capH) into b_ngay_cap from bh_nongvn_dvi where ma_dvi=b_ma_dvi and so_id_dt=b_so_id_dt and gcn=b_gcn;
end if;
PKH_JS_THAYa(dt_ct,'gcn,gcn_g',b_gcn||','||b_gcnG);
a_thay(1):=b_so_id_dt; a_thay(2):=b_ngay_hl; a_thay(3):=b_ngay_kt; a_thay(4):=b_ngay_cap;
PKH_JS_THAYan(dt_ct,'so_id_dt,ngay_hl,ngay_kt,ngay_cap',a_thay);
b_txt:=dt_ct;
b_lenh:='H,'||b_ma_sp||','||b_nt_tien||','||b_nt_phi;
PKH_JS_THAYa(b_txt,'nhom,ma_sp,nt_tien,nt_phi',b_lenh);
PKH_JS_THAYn(b_txt,'tygia',b_tygia);
FBH_NONGVNH_PHI(b_ma_dvi,b_txt,dt_dk,dt_dkbs,dt_pvi,b_so_idP,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy,dk_ktru,dk_ma_dk,dk_ma_dkC,
    dk_lh_nv,dk_t_suat,dk_cap,dk_nv,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,dk_ptB,dk_phiB,
    dk_pvi_ma,dk_pvi_tc,dk_pvi_ktru,b_loi);
if b_loi is not null then return; end if;
if b_ttrang in('T','D') then
    select count(*) into b_i1 from bh_nongvn_phi_txt where so_id=b_so_idP and loai='dt_khd';
    if b_i1<>0 then
        select txt into dt_khd from bh_nongvn_phi_txt where so_id=b_so_idP and loai='dt_khd';
        b_i1:=length(dt_khd)-2;
        dt_khd:=substr(dt_khd,2,b_i1);
        PBH_NONGVNH_KHD(dt_ctH,dt_ct,dt_dk,dt_dkbs,dt_pvi,dt_khd,b_loi);
        if b_loi is not null then return; end if;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_NONGVNH_TESTr(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_idG number,
    dt_ct in out clob, ds_ct in out clob,ds_dk clob,ds_dkbs clob,ds_pvi clob,ds_lt clob,ds_kbt clob,
    b_ma_sp out varchar2, b_cdich out varchar2, b_goi out varchar2,

    dvi_so_id out pht_type.a_num,dvi_kieu_gcn out pht_type.a_var,dvi_gcn out pht_type.a_var,dvi_gcnG out pht_type.a_var,
    dvi_dvi out pht_type.a_nvar,dvi_ddiem out pht_type.a_nvar,dvi_cdt out pht_type.a_var,
    dvi_tdx out pht_type.a_num,dvi_tdy out pht_type.a_num,dvi_bk out pht_type.a_num,

    dvi_loai out pht_type.a_var,dvi_kvuc out pht_type.a_var,dvi_qmo out pht_type.a_var,
    dvi_tuoi_t out pht_type.a_num,dvi_tuoi_d out pht_type.a_num,

    dvi_gio_hl out pht_type.a_var,dvi_ngay_hl out pht_type.a_num,
    dvi_gio_kt out pht_type.a_var,dvi_ngay_kt out pht_type.a_num,dvi_ngay_cap out pht_type.a_num,
    dvi_phi out pht_type.a_num,dvi_ttoan out pht_type.a_num,
    dvi_giam out pht_type.a_num,dvi_so_idP out pht_type.a_num,

    dk_so_id out pht_type.a_num,dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,dk_tc out pht_type.a_var,
    dk_ma_ct out pht_type.a_var,dk_kieu out pht_type.a_var,
    dk_lkeM out pht_type.a_var,dk_lkeP out pht_type.a_var,dk_lkeB out pht_type.a_var,
    dk_luy out pht_type.a_var, dk_ktru out pht_type.a_var,
    dk_ma_dk out pht_type.a_var,dk_ma_dkC out pht_type.a_var,dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,
    dk_cap out pht_type.a_num,dk_nv out pht_type.a_var,
    dk_tien out pht_type.a_num,dk_pt out pht_type.a_num,dk_phi out pht_type.a_num,
    dk_thue out pht_type.a_num,dk_ttoan out pht_type.a_num,
    dk_ptB out pht_type.a_num,dk_phiB out pht_type.a_num,dk_ptG out pht_type.a_num,dk_phiG out pht_type.a_num,
    dk_pvi_ma out pht_type.a_var,dk_pvi_tc out pht_type.a_var,dk_pvi_ktru out pht_type.a_var,

    lt_so_id out pht_type.a_num,lt_lt out pht_type.a_clob,lt_kbt out pht_type.a_clob,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_txt clob;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5);
    b_phi number; b_ttoan number; b_giam number; b_ttoanH number;

    b_kieu_hd varchar2(1); b_ttrang varchar2(1);  b_tygia number;
    b_gio_hl varchar2(50); b_ngay_hlH number; b_gio_kt varchar2(50); b_ngay_ktH number; b_ngay_capH number;
    b_loai_khH varchar2(1); b_cmtH varchar2(20); b_mobiH varchar2(20); b_emailH varchar2(50);
    b_tenH nvarchar2(500); b_dchiH nvarchar2(500); b_ma_khH varchar2(20);

    b_kt_ds number:=0; b_kt_dk number:=0;

    b_so_id_dt number; b_kieu_gcn varchar2(1); b_gcn varchar2(20); b_gcnG varchar2(20);
    b_dvi nvarchar2(500); b_ddiem nvarchar2(500); b_cdt varchar2(1);
    b_tdx number; b_tdy number; b_bk number;
    b_loai varchar2(500); b_kvuc varchar2(500); b_qmo varchar2(500);
    b_tuoi_t number; b_tuoi_d number;
    b_ngay_hl number; b_ngay_kt number; b_ngay_cap number; b_so_idP number;

    a_ma pht_type.a_var; a_ten pht_type.a_nvar; a_tc pht_type.a_var;
    a_ma_ct pht_type.a_var; a_kieu pht_type.a_var;
    a_lkeM pht_type.a_var; a_lkeP pht_type.a_var; a_lkeB pht_type.a_var; a_luy pht_type.a_var;a_ktru pht_type.a_var;
    a_ma_dk pht_type.a_var; a_ma_dkC pht_type.a_var; a_lh_nv pht_type.a_var; a_t_suat pht_type.a_num;
    a_cap pht_type.a_num; a_nv pht_type.a_var;
    a_tien pht_type.a_num; a_pt pht_type.a_num;
    a_phi pht_type.a_num; a_thue pht_type.a_num; a_ttoan pht_type.a_num;
    a_ptB pht_type.a_num; a_phiB pht_type.a_num;
    a_pvi_ma pht_type.a_var; a_pvi_tc pht_type.a_var; a_pvi_ktru pht_type.a_var;

    a_ds_ct pht_type.a_clob; a_ds_dk pht_type.a_clob; a_ds_dkbs pht_type.a_clob;
    a_ds_pvi pht_type.a_clob; a_ds_lt pht_type.a_clob; a_ds_kbt pht_type.a_clob;
begin
-- Nam - Nhap
b_loi:='loi:Loi xu ly PBH_NONGVNH_TESTr:loi';
b_lenh:=FKH_JS_LENH('ttrang,kieu_hd,ma_sp,cdich,goi,gio_hl,ngay_hl,gio_kt,ngay_kt,ngay_cap,ttoan,nt_tien,nt_phi,tygia,loai_khh,cmth,mobih,emailh,tenh,dchih');
EXECUTE IMMEDIATE b_lenh into b_ttrang,b_kieu_hd,b_ma_sp,b_cdich,b_goi,b_gio_hl,b_ngay_hlH,b_gio_kt,b_ngay_ktH,b_ngay_capH,
    b_ttoanH,b_nt_tien,b_nt_phi,b_tygia,b_loai_khH,b_cmtH,b_mobiH,b_emailH,b_tenH,b_dchiH using dt_ct;
b_lenh:=FKH_JS_LENHc('');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_ct using ds_ct;
if a_ds_ct.count=0 then b_loi:='loi:Nhap danh sach:loi'; return; end if;
b_lenh:=FKH_JS_LENHc('');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_dk using ds_dk;
b_lenh:=FKH_JS_LENHc('');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_dkbs using ds_dkbs;
b_lenh:=FKH_JS_LENHc('');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_pvi using ds_pvi;
b_lenh:=FKH_JS_LENHc('');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_lt using ds_lt;
b_lenh:=FKH_JS_LENHc('');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_kbt using ds_kbt;
b_kt_dk:=0;
for ds_lp in 1..a_ds_ct.count loop
    FKH_JS_NULL(a_ds_ct(ds_lp)); FKH_JSa_NULL(a_ds_dk(ds_lp)); FKH_JSa_NULL(a_ds_dkbs(ds_lp));
    FKH_JSa_NULL(a_ds_pvi(ds_lp)); FKH_JSa_NULL(a_ds_lt(ds_lp)); FKH_JSa_NULL(a_ds_kbt(ds_lp));
    PBH_NONGVNH_TESTd(
    dt_ct,a_ds_ct(ds_lp),a_ds_dk(ds_lp),a_ds_dkbs(ds_lp),a_ds_pvi(ds_lp),
    b_ma_dvi,b_ttrang,b_kieu_hd,b_nt_tien,b_nt_phi,b_tygia,b_ngay_hlH,b_ngay_ktH,b_ngay_capH,
    b_so_id_dt,b_kieu_gcn,b_gcn,b_gcnG,b_dvi,b_ddiem,b_cdt,b_tdx,b_tdy,b_bk,
    b_loai,b_kvuc,b_qmo,b_tuoi_t,b_tuoi_d,b_ngay_hl,b_ngay_kt,b_ngay_cap,b_so_idP,
    a_ma,a_ten,a_tc,a_ma_ct,a_kieu,a_lkeM,a_lkeP,a_lkeB,a_luy,a_ktru,a_ma_dk,a_ma_dkC,a_lh_nv,a_t_suat,
    a_cap,a_nv,a_tien,a_pt,a_phi,a_thue,a_ttoan,a_ptB,a_phiB,a_pvi_ma,a_pvi_tc,a_pvi_ktru,b_loi);
    if b_loi is not null then return; end if;
    b_kt_ds:=b_kt_ds+1;
    dvi_so_id(b_kt_ds):=b_so_id_dt; dvi_kieu_gcn(b_kt_ds):=b_kieu_gcn; dvi_gcn(b_kt_ds):=b_gcn; dvi_gcnG(b_kt_ds):=b_gcnG;
    dvi_dvi(b_kt_ds):=b_dvi; dvi_ddiem(b_kt_ds):=b_ddiem; dvi_cdt(b_kt_ds):=b_cdt;
    dvi_tdx(b_kt_ds):=b_tdx; dvi_tdy(b_kt_ds):=b_tdx; dvi_bk(b_kt_ds):=b_bk;
    
    dvi_loai(b_kt_ds):=b_loai; dvi_kvuc(b_kt_ds):=b_kvuc; dvi_qmo(b_kt_ds):=b_qmo;
    dvi_tuoi_t(b_kt_ds):=b_tuoi_t;  dvi_tuoi_d(b_kt_ds):=b_tuoi_d;

    dvi_gio_hl(b_kt_ds):=b_gio_hl; dvi_ngay_hl(b_kt_ds):=b_ngay_hl;
    dvi_gio_kt(b_kt_ds):=b_gio_kt; dvi_ngay_kt(b_kt_ds):=b_ngay_kt; dvi_ngay_cap(b_kt_ds):=b_ngay_cap;
    dvi_phi(b_kt_ds):=b_phi; dvi_ttoan(b_kt_ds):=b_ttoan; dvi_so_idP(b_kt_ds):=b_so_idP;
    for b_lp in 1..a_ma.count loop
        b_kt_dk:=b_kt_dk+1;
        dk_so_id(b_kt_dk):=b_so_id_dt; dk_ma(b_kt_dk):=a_ma(b_lp); dk_ten(b_kt_dk):=a_ten(b_lp);
        dk_tc(b_kt_dk):=a_tc(b_lp); dk_ma_ct(b_kt_dk):=a_ma_ct(b_lp);  dk_kieu(b_kt_dk):=a_kieu(b_lp);
        dk_lkeM(b_kt_dk):=a_lkeM(b_lp); dk_lkeP(b_kt_dk):=a_lkeP(b_lp);
        dk_lkeB(b_kt_dk):=a_lkeB(b_lp); dk_luy(b_kt_dk):=a_luy(b_lp); dk_ktru(b_kt_dk):=a_ktru(b_lp);
        dk_ma_dk(b_kt_dk):=a_ma_dk(b_lp); dk_ma_dkC(b_kt_dk):=a_ma_dkC(b_lp);
        dk_lh_nv(b_kt_dk):=a_lh_nv(b_lp); dk_t_suat(b_kt_dk):=a_t_suat(b_lp);
        dk_cap(b_kt_dk):=a_cap(b_lp); dk_nv(b_kt_dk):=a_nv(b_lp);
        dk_tien(b_kt_dk):=a_tien(b_lp); dk_pt(b_kt_dk):=a_pt(b_lp); dk_phi(b_kt_dk):=a_phi(b_lp);
        dk_thue(b_kt_dk):=a_thue(b_lp); dk_ttoan(b_kt_dk):=a_ttoan(b_lp);
        dk_ptB(b_kt_dk):=a_ptB(b_lp);  dk_phiB(b_kt_dk):=a_phiB(b_lp);
        dk_pvi_ma(b_kt_dk):=a_pvi_ma(b_lp); dk_pvi_tc(b_kt_dk):=a_pvi_tc(b_lp); dk_pvi_ktru(b_kt_dk):=a_pvi_ktru(b_lp);
    end loop;
end loop;
ds_ct:=FKH_ARRc_JS(a_ds_ct);
if b_kieu_hd in('B','S') and b_so_idG<>0 then
    for r_lp in (select so_id_dt,dvi from bh_nongvn_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idG) loop
        if FKH_ARR_VTRI_N(dvi_so_id,r_lp.so_id_dt)=0 then b_loi:='loi:Khong xoa danh sach cu '||r_lp.dvi||':loi'; return; end if;
    end loop;
end if;
PBH_HD_THAY_PHI(b_nt_tien,b_nt_tien,b_tygia,0,b_ttoanH,
    dk_lh_nv,dk_tien,dk_ptB,dk_phiB,dk_phi,dk_thue,dk_ttoan,dk_ptG,dk_phiG,b_loi);
if b_loi is not null then return; end if;
for b_lp in 1..dk_ma.count loop
    dk_ptG(b_lp):=0; dk_phiG(b_lp):=0;
    if dk_ptB(b_lp)<>0 then
        dk_ptG(b_lp):=dk_ptB(b_lp)-dk_pt(b_lp);
        if dk_ptB(b_lp)>=100 then dk_ptG(b_lp):=round(dk_ptG(b_lp)*100/dk_ptB(b_lp),2); end if;
    elsif dk_phiB(b_lp)<>0 then
        dk_ptG(b_lp):=dk_phiB(b_lp)-dk_phi(b_lp);
        dk_ptG(b_lp):=round(dk_ptG(b_lp)*100/dk_phiB(b_lp),2);
    end if;
end loop;
for b_lp in 1..dvi_so_id.count loop
    b_phi:=0; b_giam:=0;
    for b_lp1 in 1..dk_so_id.count loop
        if dk_lh_nv(b_lp1)<>' ' and dk_so_id(b_lp1)=dvi_so_id(b_lp) then
            b_phi:=b_phi+dk_phi(b_lp1); b_giam:=b_giam+dk_phiG(b_lp1);
        end if;
    end loop;
    dvi_giam(b_lp):=b_giam; dvi_phi(b_lp):=b_phi; dvi_ttoan(b_lp):=b_phi;
    lt_so_id(b_lp):=dvi_so_id(b_lp); lt_lt(b_lp):=a_ds_lt(b_lp); lt_kbt(b_lp):=a_ds_kbt(b_lp);
end loop;
if b_ttrang in('T','D') then
    select json_object('loai' value b_loai_khH,'ten' value b_tenH,'cmt' value b_cmtH,
        'dchi' value b_dchiH,'mobi' value b_mobiH,'email' value b_emailH) into b_txt from dual;
    PBH_DTAC_MA_NH(b_txt,b_ma_khH,b_loi,b_ma_dvi,b_nsd);
    if b_ma_khH not in(' ','VANGLAI') then PKH_JS_THAY(dt_ct,'ma_khH',b_ma_khH); end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_NONGVNH_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    dt_ct in out clob,dt_hk clob,ds_ct clob,ds_dk clob,ds_dkbs clob,ds_pvi clob,ds_lt clob,ds_kbt clob,ds_ttt clob,
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
    b_ma_sp varchar2, b_cdich varchar2, b_goi varchar2,

    dvi_so_id pht_type.a_num,dvi_kieu_gcn pht_type.a_var,dvi_gcn pht_type.a_var,dvi_gcnG pht_type.a_var,
    dvi_dvi pht_type.a_nvar,dvi_ddiem pht_type.a_nvar,dvi_cdt pht_type.a_var,
    dvi_tdx pht_type.a_num,dvi_tdy pht_type.a_num,dvi_bk pht_type.a_num,

    dvi_loai pht_type.a_var,dvi_kvuc pht_type.a_var,dvi_qmo pht_type.a_var,
    dvi_tuoi_t pht_type.a_num,dvi_tuoi_d pht_type.a_num,

    dvi_gio_hl pht_type.a_var,dvi_ngay_hl pht_type.a_num,
    dvi_gio_kt pht_type.a_var,dvi_ngay_kt pht_type.a_num,dvi_ngay_cap pht_type.a_num,
    dvi_phi pht_type.a_num,dvi_ttoan pht_type.a_num,
    dvi_giam pht_type.a_num,dvi_so_idP pht_type.a_num,

    dk_so_id pht_type.a_num,dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tc pht_type.a_var,
    dk_ma_ct pht_type.a_var,dk_kieu pht_type.a_var,
    dk_lkeM pht_type.a_var,dk_lkeP pht_type.a_var,dk_lkeB pht_type.a_var,
    dk_luy pht_type.a_var, dk_ktru pht_type.a_var,
    dk_ma_dk pht_type.a_var,dk_ma_dkC pht_type.a_var,dk_lh_nv pht_type.a_var,dk_t_suat pht_type.a_num,
    dk_cap pht_type.a_num,dk_nv pht_type.a_var,
    dk_tien pht_type.a_num,dk_pt pht_type.a_num,dk_phi pht_type.a_num,
    dk_thue pht_type.a_num,dk_ttoan pht_type.a_num,
    dk_ptB pht_type.a_num,dk_phiB pht_type.a_num,dk_ptG pht_type.a_num,dk_phiG pht_type.a_num,
    dk_pvi_ma pht_type.a_var,dk_pvi_tc pht_type.a_var,dk_pvi_ktru pht_type.a_var,

    lt_so_id pht_type.a_num,lt_lt pht_type.a_clob,lt_kbt pht_type.a_clob,b_loi out varchar2)
AS
    b_i1 number; b_so_dt number; b_so_id_kt number:=-1; b_tien number:=0; b_txt clob; b_ma_ke varchar2(20);
begin
-- Nam - Nhap
b_loi:='loi:Loi Table bh_nongvn:loi';
b_so_dt:=dvi_so_id.count;
if b_ttrang='D' then b_so_id_kt:=0; end if;
for b_lp in 1..dvi_so_id.count loop
    insert into bh_nongvn_dvi values(b_ma_dvi,b_so_id,dvi_so_id(b_lp),b_lp,dvi_kieu_gcn(b_lp),dvi_gcn(b_lp),dvi_gcnG(b_lp),
        dvi_dvi(b_lp),dvi_kvuc(b_lp),dvi_ddiem(b_lp),dvi_cdt(b_lp),dvi_tdx(b_lp),dvi_tdy(b_lp),dvi_bk(b_lp),
        dvi_loai(b_lp),dvi_qmo(b_lp),b_so_dt,
        dvi_gio_hl(b_lp),dvi_ngay_hl(b_lp),dvi_gio_kt(b_lp),dvi_ngay_kt(b_lp),dvi_ngay_cap(b_lp),
        dvi_so_idP(b_lp),dvi_giam(b_lp),dvi_phi(b_lp),0,dvi_ttoan(b_lp));
end loop;
for b_lp in 1..dk_so_id.count loop
    if dk_lh_nv(b_lp)<>' ' and dk_kieu(b_lp)='T' then b_tien:=b_tien+dk_tien(b_lp); end if;
    insert into bh_nongvn_dk values(b_ma_dvi,b_so_id,dk_so_id(b_lp),b_lp,
        dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),dk_kieu(b_lp),dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),dk_cap(b_lp),
        dk_ma_dk(b_lp),dk_ma_dkC(b_lp),dk_lh_nv(b_lp),dk_t_suat(b_lp),dk_thue(b_lp),dk_ttoan(b_lp),
        dk_ptB(b_lp),dk_phiB(b_lp),dk_ptG(b_lp),dk_phiG(b_lp),dk_lkeM(b_lp),dk_lkeP(b_lp),dk_lkeB(b_lp),dk_luy(b_lp),
        dk_nv(b_lp),dk_ktru(b_lp),dk_pvi_ma(b_lp),dk_pvi_tc(b_lp),dk_pvi_ktru(b_lp));
end loop;
insert into bh_nongvn values(
    b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,'H',b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
    b_phong,b_so_hdL,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,
    b_nt_tien,b_nt_phi,b_c_thue,b_ma_sp,b_cdich,b_goi,b_so_dt,b_tien,
    b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,'','',b_so_id_kt,b_nsd,sysdate);
PKH_JS_THAYa(dt_ct,'so_hd,ma_kh',b_so_hd||','||b_ma_kh);
insert into bh_nongvn_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
if dt_hk is not null then
    insert into bh_nongvn_txt values(b_ma_dvi,b_so_id,'dt_hk',dt_hk);
end if;
insert into bh_nongvn_txt values(b_ma_dvi,b_so_id,'ds_ct',ds_ct);
insert into bh_nongvn_txt values(b_ma_dvi,b_so_id,'ds_dk',ds_dk);
insert into bh_nongvn_txt values(b_ma_dvi,b_so_id,'ds_pvi',ds_pvi);
if ds_dkbs is not null then
    insert into bh_nongvn_txt values(b_ma_dvi,b_so_id,'ds_dkbs',ds_dkbs);
end if;
if ds_lt is not null then
    insert into bh_nongvn_txt values(b_ma_dvi,b_so_id,'ds_lt',ds_lt);
end if;
if ds_kbt is not null then
    insert into bh_nongvn_txt values(b_ma_dvi,b_so_id,'ds_kbt',ds_kbt);
end if;
if ds_ttt is not null then
    insert into bh_nongvn_txt values(b_ma_dvi,b_so_id,'ds_ttt',ds_ttt);
end if;
for b_lp in 1..tt_ngay.count loop
    insert into bh_nongvn_tt values(b_ma_dvi,b_so_id,tt_ngay(b_lp),tt_tien(b_lp));
end loop;
if b_ttrang in('T','D') then
    insert into bh_nong values(
        b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,'VN',b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
        b_phong,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_ma_sp,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,
        b_nt_tien,b_nt_phi,b_c_thue,b_tien,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,'','',b_so_id_kt,b_nsd);
    for b_lp in 1..dvi_so_id.count loop
        insert into bh_nong_dvi values(b_ma_dvi,b_so_id,dvi_so_id(b_lp),b_lp,dvi_kieu_gcn(b_lp),dvi_gcn(b_lp),dvi_gcnG(b_lp),
            dvi_dvi(b_lp),dvi_kvuc(b_lp),dvi_ddiem(b_lp),dvi_cdt(b_lp),dvi_tdx(b_lp),dvi_tdy(b_lp),dvi_bk(b_lp),
            dvi_loai(b_lp),dvi_gio_hl(b_lp),dvi_ngay_hl(b_lp),dvi_gio_kt(b_lp),dvi_ngay_kt(b_lp),dvi_ngay_cap(b_lp),
            dvi_so_idP(b_lp),dvi_phi(b_lp),dvi_giam(b_lp),dvi_ttoan(b_lp));
        select json_object('ddiem' value dvi_ddiem(b_lp)) into b_txt from dual;
        insert into bh_hd_goc_ttdt values(b_ma_dvi,b_so_id,dvi_so_id(b_lp),'NONG',dvi_dvi(b_lp),b_ma_kh,dvi_ngay_kt(b_lp),b_txt);
    end loop;
    for b_lp in 1..dk_so_id.count loop
    insert into bh_nong_dk values(b_ma_dvi,b_so_id,dk_so_id(b_lp),b_lp,
        dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),dk_kieu(b_lp),dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),dk_cap(b_lp),
        dk_ma_dk(b_lp),dk_ma_dkC(b_lp),dk_lh_nv(b_lp),dk_t_suat(b_lp),dk_thue(b_lp),dk_ttoan(b_lp),
        dk_ptB(b_lp),dk_phiB(b_lp),dk_ptG(b_lp),dk_phiG(b_lp),dk_lkeM(b_lp),dk_lkeP(b_lp),dk_lkeB(b_lp),dk_luy(b_lp),
        dk_nv(b_lp),dk_ktru(b_lp),dk_pvi_ma(b_lp),dk_pvi_tc(b_lp),dk_pvi_ktru(b_lp));
    end loop;
    for b_lp in 1..lt_so_id.count loop
        select JSON_ARRAYAGG(json_object(
            ma,ten,tc,ma_ct,tien,pt,phi,cap,ma_dk,ma_dkC,lh_nv,t_suat,thue,ttoan,ptB,ptG,phiG,lkeM,lkeP,lkeB,luy,pvi_ma,pvi_tc,pvi_ktru)
            order by bt returning clob) into b_txt
            from bh_nongvn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=lt_so_id(b_lp);
        insert into bh_nongvn_kbt values(b_ma_dvi,b_so_id,lt_so_id(b_lp),b_txt,lt_lt(b_lp),lt_kbt(b_lp));
        insert into bh_nong_kbt values(b_ma_dvi,b_so_id,lt_so_id(b_lp),b_txt,lt_lt(b_lp),lt_kbt(b_lp));
    end loop;
    for b_lp in 1..tt_ngay.count loop
        insert into bh_nong_tt values(b_ma_dvi,b_so_id,tt_ngay(b_lp),tt_tien(b_lp));
    end loop;
    insert into bh_nong_txt values(b_ma_dvi,b_so_id,'ds_ct',ds_ct);
    insert into bh_nong_txt values(b_ma_dvi,b_so_id,'dt_hk',dt_hk);
    select json_object('ma_dvi' value b_ma_dvi,'nsd' value b_nsd,'so_id' value b_so_id,'so_hd' value b_so_hd,
        'kieu_hd' value b_kieu_hd,'nv' value 'NONG','ngay_ht' value b_ngay_ht,'ngay_cap' value b_ngay_cap,
        'ngay_hl' value b_ngay_hl,'ngay_kt' value b_ngay_kt,'cb_ql' value b_ma_cb,'phong' value b_phong,
        'kieu_kt' value b_kieu_kt,'ma_kt' value b_ma_kt,'dly_tke' value ' ','hhong' value b_hhong,'pt_hhong' value 'D',
        'ma_kh' value b_ma_kh,'ten' value b_ten,'kieu_gt' value b_kieu_gt,'ma_gt' value b_ma_gt,'so_id_d' value b_so_idD,'so_id_g' value b_so_idG,
        'ttrang' value b_ttrang,'dvi_ksoat' value b_ma_dvi,'ksoat' value b_nsd,'bangg' value 'bh_nong,bh_nongct,bh_nongvn,bh_nongts',
    'c_thue' value b_c_thue,'nt_tien' value b_nt_tien,'nt_phi' value b_nt_phi,'tien' value b_tien,
    'phi' value b_ttoan-b_thue,'thue' value b_thue returning clob) into b_txt from dual;
    PBH_HD_GOC_NH(b_txt,b_loi);
    if b_loi is not null then return; end if;
end if;
if b_ttrang='D' and b_kieu_hd<>'U' then
    for b_lp in 1..dvi_so_id.count loop
        PBH_KE_CTI_NHOM(b_ma_dvi,b_so_idD,dvi_so_id(b_lp),b_ma_ke,b_loi);
        if b_loi is not null then return; end if;
        insert into bh_hd_goc_ttindt values(
            b_ma_dvi,b_so_id,dvi_so_id(b_lp),'NONG',dvi_dvi(b_lp),b_ma_kh,dvi_ngay_kt(b_lp),dvi_ddiem(b_lp),b_ma_ke);
    end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_NONGVNH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(3000); b_lenh varchar2(2000); b_i1 number;
    dt_ct clob; dt_hk clob; ds_ct clob; ds_dk clob; ds_dkbs clob; ds_pvi clob; ds_lt clob; ds_kbt clob; ds_ttt clob; dt_kytt clob;
-- Chung
    b_so_id number; b_so_hd varchar2(20); b_ngay_ht number; b_ttrang varchar2(1); b_kieu_hd varchar2(1); b_so_hd_g varchar2(20);
    b_kieu_kt varchar2(1); b_ma_kt varchar2(20); b_kieu_gt varchar2(1); b_ma_gt varchar2(20); b_ma_cb varchar2(20);
    b_so_hdL varchar2(20); b_loai_kh varchar2(1); b_ma_kh varchar2(20); b_ten nvarchar2(500); b_dchi nvarchar2(500);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(50);
    b_gio_hl varchar2(20); b_ngay_hl number; b_gio_kt varchar2(20); b_ngay_kt number; b_ngay_cap number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_c_thue varchar2(1);
    b_tl_giam number; b_phi number; b_giam number; b_thue number; b_ttoan number; b_hhong number;
    b_so_idG number; b_so_idD number; b_ngayD number; b_phong varchar2(10);
    tt_ngay pht_type.a_num; tt_tien pht_type.a_num;
-- Rieng
    b_ma_sp varchar2(10); b_cdich varchar2(10); b_goi varchar2(10);

    dvi_so_id pht_type.a_num; dvi_kieu_gcn pht_type.a_var; dvi_gcn pht_type.a_var; dvi_gcnG pht_type.a_var; 
    dvi_dvi pht_type.a_nvar; dvi_ddiem pht_type.a_nvar; dvi_cdt pht_type.a_var; 
    dvi_tdx pht_type.a_num; dvi_tdy pht_type.a_num; dvi_bk pht_type.a_num; 

    dvi_loai pht_type.a_var; dvi_kvuc pht_type.a_var; dvi_qmo pht_type.a_var; 
    dvi_tuoi_t pht_type.a_num; dvi_tuoi_d pht_type.a_num; 

    dvi_gio_hl pht_type.a_var; dvi_ngay_hl pht_type.a_num; 
    dvi_gio_kt pht_type.a_var; dvi_ngay_kt pht_type.a_num; dvi_ngay_cap pht_type.a_num; 
    dvi_phi pht_type.a_num; dvi_ttoan pht_type.a_num; 
    dvi_giam pht_type.a_num; dvi_so_idP pht_type.a_num; 

    dk_so_id pht_type.a_num; dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var;
    dk_ma_ct pht_type.a_var; dk_kieu pht_type.a_var;
    dk_lkeM pht_type.a_var; dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var; dk_luy pht_type.a_var; dk_ktru pht_type.a_var;
    dk_ma_dk pht_type.a_var; dk_ma_dkC pht_type.a_var; dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num;
    dk_cap pht_type.a_num; dk_nv pht_type.a_var;
    dk_tien pht_type.a_num; dk_pt pht_type.a_num; dk_phi pht_type.a_num;
    dk_thue pht_type.a_num; dk_ttoan pht_type.a_num;
    dk_ptB pht_type.a_num; dk_phiB pht_type.a_num; dk_ptG pht_type.a_num; dk_phiG pht_type.a_num;
    dk_pvi_ma pht_type.a_var; dk_pvi_tc pht_type.a_var; dk_pvi_ktru pht_type.a_var;

    lt_so_id pht_type.a_num; lt_lt pht_type.a_clob; lt_kbt pht_type.a_clob;
-- Xu ly
    b_ngay_htC number;
begin
-- Nam - Nhap
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NONG','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_hk,ds_ct,ds_dk,ds_dkbs,ds_pvi,ds_lt,ds_kbt,ds_ttt,dt_kytt');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_hk,ds_ct,ds_dk,ds_dkbs,ds_pvi,ds_lt,ds_kbt,ds_ttt,dt_kytt using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_hk); FKH_JSa_NULL(dt_kytt);
if b_so_id<>0 then
    select count(*) into b_i1 from bh_nongvn where so_id=b_so_id;
    if b_i1<>0 then
        select ngay_ht,kieu_hd,ttrang into b_ngay_htC,b_kieu_hd,b_ttrang from bh_nongvn where so_id=b_so_id for update nowait;
        if sql%rowcount=0 then b_loi:='loi:Va cham NSD:loi'; raise PROGRAM_ERROR; end if;
        if b_ttrang not in('T','D') then b_kieu_hd:='X'; else b_kieu_hd:='N'; end if;
        PBH_NONGVN_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_kieu_hd,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
else
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_HD_JS_TEST(
    b_ma_dvi,b_nsd,b_so_id,b_ngay_htC,'bh_nongvn',dt_ct,dt_kytt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_loai_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,
    b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_ngayD,b_phong,b_ma_cb,b_ma_kh,
    tt_ngay,tt_tien,b_loi,'NONG');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_NONGVNH_TESTr(
    b_ma_dvi,b_nsd,b_so_idG,
    dt_ct,ds_ct,ds_dk,ds_dkbs,ds_pvi,ds_lt,ds_kbt,
    b_ma_sp,b_cdich,b_goi,
    dvi_so_id,dvi_kieu_gcn,dvi_gcn,dvi_gcnG,
    dvi_dvi,dvi_ddiem,dvi_cdt,dvi_tdx,dvi_tdy,dvi_bk,
    dvi_loai,dvi_kvuc,dvi_qmo,dvi_tuoi_t,dvi_tuoi_d,
    dvi_gio_hl,dvi_ngay_hl,dvi_gio_kt,dvi_ngay_kt,dvi_ngay_cap,
    dvi_phi,dvi_ttoan,dvi_giam,dvi_so_idP,
    dk_so_id,dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy, dk_ktru,
    dk_ma_dk,dk_ma_dkC,dk_lh_nv,dk_t_suat,dk_cap,dk_nv,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,
    dk_ptB,dk_phiB,dk_ptG,dk_phiG,dk_pvi_ma,dk_pvi_tc,dk_pvi_ktru,lt_so_id,lt_lt,lt_kbt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_NONGVNH_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,
    dt_ct,dt_hk,ds_ct,ds_dk,ds_dkbs,ds_pvi,ds_lt,ds_kbt,ds_ttt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,b_so_hdL,
    b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,
    b_so_idG,b_so_idD,b_ngayD,b_phong,
    tt_ngay,tt_tien,
    b_ma_sp,b_cdich,b_goi,
    dvi_so_id,dvi_kieu_gcn,dvi_gcn,dvi_gcnG,
    dvi_dvi,dvi_ddiem,dvi_cdt,dvi_tdx,dvi_tdy,dvi_bk,
    dvi_loai,dvi_kvuc,dvi_qmo,dvi_tuoi_t,dvi_tuoi_d,
    dvi_gio_hl,dvi_ngay_hl,dvi_gio_kt,dvi_ngay_kt,dvi_ngay_cap,
    dvi_phi,dvi_ttoan,dvi_giam,dvi_so_idP,
    dk_so_id,dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy,dk_ktru,
    dk_ma_dk,dk_ma_dkC,dk_lh_nv,dk_t_suat,dk_cap,dk_nv,dk_tien,dk_pt,dk_phi,
    dk_thue,dk_ttoan,dk_ptB,dk_phiB,dk_ptG,dk_phiG,dk_pvi_ma,dk_pvi_tc,dk_pvi_ktru,
    lt_so_id,lt_lt,lt_kbt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hd' value b_so_hd, 'ma_kh' value b_ma_kh) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_NONGVNH_PHIb(b_tp number,
    dk_ma pht_type.a_var,dk_ma_ct pht_type.a_var,dk_lkeP pht_type.a_var,dk_cap pht_type.a_num,
    dk_phi in out pht_type.a_num,dk_ttoan out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_cap number:=1; b_phi number;
begin
-- Dan - Tinh bac cao
b_loi:='loi:Loi xu ly FBH_PHHG_PHIb:loi';
for b_lp in 1..dk_ma.count loop
    if dk_cap(b_lp)>b_cap then b_cap:=dk_cap(b_lp); end if;
    if dk_lkeP(b_lp) in('T','N') then dk_phi(b_lp):=0; end if;
end loop;
b_cap:=b_cap-1;
while b_cap>0 loop
    for b_lp in 1..dk_ma.count loop
        if b_cap=dk_cap(b_lp) then
            if dk_lkeP(b_lp)='T' then
                b_phi:=0;
                for b_lp1 in 1..dk_ma.count loop
                    if dk_ma_ct(b_lp1)=dk_ma(b_lp) then
                        b_phi:=b_phi+dk_phi(b_lp1);
                    end if;
                end loop;
                dk_phi(b_lp):=b_phi; dk_ttoan(b_lp):=b_phi;
            elsif dk_lkeP(b_lp)='N' then
                b_i1:=0;
                for b_lp1 in 1..dk_ma.count loop
                    if dk_ma_ct(b_lp1)=dk_ma(b_lp) then
                        if b_i1=0 then
                            b_i1:=1; b_phi:=dk_phi(b_lp1);
                        else
                            b_phi:=ROUND(b_phi*dk_phi(b_lp1),b_tp);
                        end if;
                    end if;
                end loop;
                dk_phi(b_lp):=b_phi;
            end if;
        end if;
    end loop;
    b_cap:=b_cap-1;
end loop;
for b_lp in 1..dk_ma.count loop
    dk_ttoan(b_lp):=dk_phi(b_lp);
end loop;
b_loi:='';
end;
/
create or replace procedure PBH_NONGVNH_PHI (
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(3000); b_lenh varchar2(2000); b_txt clob;
    dt_ct clob; dt_dk clob; dt_dkbs clob; dt_pvi clob;
    b_so_idP number;
    a_ma pht_type.a_var; a_ten pht_type.a_nvar; a_tc pht_type.a_var;
    a_ma_ct pht_type.a_var; a_kieu pht_type.a_var;
    a_lkeM pht_type.a_var; a_lkeP pht_type.a_var; a_lkeB pht_type.a_var; a_luy pht_type.a_var; a_ktru pht_type.a_var;
    a_ma_dk pht_type.a_var; a_ma_dkC pht_type.a_var; a_lh_nv pht_type.a_var; a_t_suat pht_type.a_num;
    a_cap pht_type.a_num; a_nv pht_type.a_var;
    a_tien pht_type.a_num; a_pt pht_type.a_num;
    a_phi pht_type.a_num; a_thue pht_type.a_num; a_ttoan pht_type.a_num;
    a_ptB pht_type.a_num; a_phiB pht_type.a_num;
    a_pvi_ma pht_type.a_var; a_pvi_tc pht_type.a_var; a_pvi_ktru pht_type.a_var;
begin
-- Nam - Tinh phi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NONG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_dkbs,dt_pvi');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_dkbs,dt_pvi using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_dkbs); FKH_JSa_NULL(dt_pvi);
FBH_NONGVNH_PHI(b_ma_dvi,dt_ct,dt_dk,dt_dkbs,dt_pvi,b_so_idP,
    a_ma,a_ten,a_tc,a_ma_ct,a_kieu,a_lkeM,a_lkeP,a_lkeB,a_luy,a_ktru,a_ma_dk,a_ma_dkC,
    a_lh_nv,a_t_suat,a_cap,a_nv,a_tien,a_pt,a_phi,a_thue,a_ttoan,a_ptB,a_phiB,
    a_pvi_ma,a_pvi_tc,a_pvi_ktru,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_oraOut:='';
for b_lp in 1..a_ma.count loop
    select json_object('ma' value a_ma(b_lp),'ten' value a_ten(b_lp),'tc' value a_tc(b_lp),
    'ma_ct' value a_ma_ct(b_lp),'kieu' value a_kieu(b_lp),'lkeM' value a_lkeM(b_lp),'lkeP' value a_lkeP(b_lp),'lkeB' value a_lkeB(b_lp),
    'luy' value a_luy(b_lp),'ma_dk' value a_ma_dk(b_lp),'ma_dkC' value a_ma_dkC(b_lp),
    'lh_nv' value a_lh_nv(b_lp),'t_suat' value a_t_suat(b_lp),'cap' value a_cap(b_lp),
    'nv' value a_nv(b_lp),'tien' value a_tien(b_lp),'pt' value a_pt(b_lp),
    'phi' value a_phi(b_lp),'ttoan' value a_ttoan(b_lp),
    'ptB' value a_ptB(b_lp),'phiP' value a_phiB(b_lp),
    'pvi_ma'  value a_pvi_ma(b_lp),'pvi_tc' value a_pvi_tc(b_lp),'pvi_ktru' value a_pvi_ktru(b_lp) returning clob) into b_txt from dual;
    if b_lp>1 then b_oraOut:=b_oraOut||','; end if;
    b_oraOut:=b_oraOut||b_txt;
end loop;
if b_oraOut is not null then b_oraOut:='['||b_oraOut||']'; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_NONGVNH_PHI(
    b_ma_dvi varchar2,dt_ct clob,dt_dk clob,dt_dkbs clob,dt_pvi clob,
    b_so_idP out number,
    a_ma out pht_type.a_var,a_ten out pht_type.a_nvar,a_tc out pht_type.a_var,
    a_ma_ct out pht_type.a_var,a_kieu out pht_type.a_var,
    a_lkeM out pht_type.a_var,a_lkeP out pht_type.a_var,a_lkeB out pht_type.a_var,
    a_luy out pht_type.a_var,a_ktru out pht_type.a_var,
    a_ma_dk out pht_type.a_var,a_ma_dkC out pht_type.a_var,a_lh_nv out pht_type.a_var,a_t_suat out pht_type.a_num,
    a_cap out pht_type.a_num,a_nv out pht_type.a_var,
    a_tien out pht_type.a_num,a_pt out pht_type.a_num,
    a_phi out pht_type.a_num,a_thue out pht_type.a_num,a_ttoan out pht_type.a_num,
    a_ptB out pht_type.a_num,a_phiB out pht_type.a_num,
    a_pvi_ma out pht_type.a_var,a_pvi_tc out pht_type.a_var,a_pvi_ktru out pht_type.a_var,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_i1 number; b_i2 number; b_iX number; b_kt number:=0; b_ktL number:=0; b_ktru varchar2(500);
    b_nhom varchar2(1); b_ma_sp varchar2(10); b_cdich varchar2(10); b_goi varchar2(10); 
    b_loai varchar2(500); b_kvuc varchar2(500); b_qmo varchar2(500);
    b_kieu_hd  varchar2(1); b_so_hdG varchar2(20); b_so_idG number:=0;
    b_ngay_hlC number; b_ngay_ktC number; b_ngay_cap number; b_phi number;
    b_ngay_hl number; b_ngay_kt number; b_kho number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tygia number; b_tp number:=0; b_tien number;
    b_pvi_pt number:=0; b_pvi_ptb number:=0; b_dk varchar2(1);

    a_ptk pht_type.a_var; a_pp pht_type.a_var;
    dk_ma pht_type.a_var; dk_tien pht_type.a_num;
    dk_maG pht_type.a_var; dk_tienG pht_type.a_num; dk_ptG pht_type.a_num;
    dk_phiG pht_type.a_num; dk_tcG pht_type.a_var;

    pvi_ma pht_type.a_var; pvi_tc pht_type.a_var; pvi_ten pht_type.a_var;
    pvi_pt pht_type.a_num; pvi_ktru pht_type.a_var;
    pvi_loai pht_type.a_var; pvi_ma_ct pht_type.a_var;
    pvi_ptB pht_type.a_num; pvi_pp pht_type.a_var;
    pvi_ptk pht_type.a_var;

    bs_ma pht_type.a_var; bs_tien pht_type.a_num; bs_ptB pht_type.a_num;
    bs_pp pht_type.a_var; bs_pt pht_type.a_num; bs_ptK pht_type.a_var;
begin
-- Nam - Tinh phi
b_loi:='loi:Loi xu ly FBH_NONGVNH_PHI:loi';
b_lenh:=FKH_JS_LENH('kieu_hdh,so_hd_gh,ngay_kt,ngay_caph,nt_tien,nt_phi,tygia');
EXECUTE IMMEDIATE b_lenh into b_kieu_hd,b_so_hdG,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,b_tygia using dt_ct;
PBH_NONGVN_BPHI_TSO(dt_ct,b_nhom,b_ma_sp,b_cdich,b_goi,b_loai,b_kvuc,b_qmo,b_ngay_hl);
b_so_idP:=FBH_NONGVN_BPHI_SO_ID(b_nhom,b_ma_sp,b_cdich,b_goi,b_loai,b_kvuc,b_qmo,b_ngay_hl);
if b_so_idP=0 then b_loi:='loi:Khong tim duoc bieu phi:loi'; return; end if;
if b_kieu_hd in('B','S') and b_so_hdG<>' ' then
    b_dk:='C';
    b_so_idG:=FBH_NONG_SO_ID(b_ma_dvi,b_so_hdG);
    if b_so_idG=0 then b_loi:='loi:GCN goc da xoa:loi'; return; end if;  
end if;
if b_tygia is null or b_tygia=0 then b_tygia:=1; end if;
if b_nt_phi<>'VND' then b_tp:=2; end if;
b_lenh:=FKH_JS_LENH('ma,tien');
EXECUTE IMMEDIATE b_lenh bulk collect into dk_ma,dk_tien using dt_dk;
if dk_ma.count=0 then b_loi:='loi:Nhap so tien bao hiem:loi'; return; end if;
b_lenh:=FKH_JS_LENH('ma,ten,ptb,pp,pt,ktru,tc,loai,ma_ct,ptk');
EXECUTE IMMEDIATE b_lenh bulk collect into pvi_ma,pvi_ten,pvi_ptB,pvi_pp,pvi_pt,
                  pvi_ktru,pvi_tc,pvi_loai,pvi_ma_ct,pvi_ptk using dt_pvi;
if pvi_ma.count=0 then b_loi:='loi:Nhap pham vi bao hiem:loi'; return; end if;
b_lenh:=FKH_JS_LENH('ma,tien,ptb,pp,pt,ptk');
EXECUTE IMMEDIATE b_lenh bulk collect into bs_ma,bs_tien,bs_ptB,bs_pp,bs_pt,bs_ptK using dt_dkbs;
for b_lp in 1..pvi_ma.count loop
    pvi_tc(b_lp):=nvl(trim(pvi_tc(b_lp)),'C'); pvi_pp(b_lp):=nvl(trim(pvi_pp(b_lp)),'GP');
end loop;
if F_KTRA_KTRU(pvi_ktru,b_loi) <> 'C' then b_loi:='loi:Pham vi khau tru sai dinh dang:loi'; end if;
b_ktru:=FBH_BT_KTRUs(pvi_ktru);
for b_lp in 1..pvi_ma.count loop
    if pvi_tc(b_lp)='C' then
        for b_lp1 in 1..pvi_ma.count loop
            if pvi_ma(b_lp1)=pvi_ma_ct(b_lp) then pvi_ten(b_lp):='- '||pvi_ten(b_lp); exit; end if;
        end loop;
    end if;
end loop;
for b_lp in 1..pvi_ma.count loop
    b_pvi_pt:=b_pvi_pt+pvi_pt(b_lp);
    b_pvi_ptB:=b_pvi_ptB+pvi_ptB(b_lp);
end loop;
FBH_NONGVNH_KHO(b_ngay_hl,b_ngay_kt,b_kho,b_loi,b_dk);
if b_loi is not null then return; end if;
b_kt:=0;
for b_lp_dk in 1..dk_ma.count loop
    select count(*) into b_i1 from bh_nongvn_phi_dk where so_id=b_so_idP and ma=dk_ma(b_lp_dk);
    if b_i1<>1 then b_loi:='loi:Sai bieu phi dieu khoan '||b_so_idP||':'||dk_ma(b_lp_dk)||':loi'; return; end if;
    b_kt:=b_kt+1; b_ktL:=b_kt;
    select ma,ten,tc,ma_ct,'T',lkeM,lkeP,lkeB,luy,ktru,ma_dk,lh_nv,t_suat,cap,nv into
        a_ma(b_kt),a_ten(b_kt),a_tc(b_kt),a_ma_ct(b_kt),a_kieu(b_kt),a_lkeM(b_kt),a_lkeP(b_kt),a_lkeB(b_kt),a_luy(b_kt),a_ktru(b_kt),
        a_ma_dk(b_kt),a_lh_nv(b_kt),a_t_suat(b_kt),a_cap(b_kt),a_nv(b_kt)
        from bh_nongvn_phi_dk where so_id=b_so_idP and ma=dk_ma(b_lp_dk);
    if a_lkeP(b_kt)='D' then b_kho:=1; end if;
    a_tien(b_kt):=dk_tien(b_lp_dk);
    a_ma_dkC(b_kt):=' '; a_pvi_ma(b_kt):=' '; a_pvi_tc(b_kt):=' ';
    if a_ktru(b_kt)<>'P' then a_pvi_ktru(b_kt):=' '; else a_pvi_ktru(b_kt):=b_ktru; end if;
    a_pt(b_kt):=0; a_phi(b_kt):=0; a_ptB(b_kt):=0; a_phiB(b_kt):=0;
    if a_tc(b_kt)='C' then
        for b_lp_pvi in 1..pvi_ma.count loop
            b_kt:=b_kt+1;
            a_ma(b_kt):=a_ma(b_ktL)||'>'||pvi_ma(b_lp_pvi); a_kieu(b_kt):=a_kieu(b_ktL);
            a_ten(b_kt):='- '||pvi_ten(b_lp_pvi);
            a_tc(b_kt):='C';
            a_ma_ct(b_kt):=a_ma(b_ktL);
            a_lkeM(b_kt):=a_lkeM(b_ktL); a_lkeP(b_kt):=a_lkeP(b_ktL);
            if a_lkeP(b_ktL) not in ('G','T','N','D') then a_lkeP(b_kt):='K'; else a_lkeP(b_kt):=a_lkeP(b_ktL); end if;
            a_lkeB(b_kt):=a_lkeB(b_ktL); a_luy(b_kt):=a_luy(b_ktL); a_ktru(b_kt):=a_ktru(b_ktL);
            a_tien(b_kt):=0; a_ma_dk(b_kt):=a_ma_dk(b_ktL); a_ma_dkC(b_kt):=a_ma_dk(b_ktL); a_lh_nv(b_kt):=' ';
            a_t_suat(b_kt):=a_t_suat(b_ktL); a_cap(b_kt):=a_cap(b_ktL)+1; a_nv(b_kt):=a_nv(b_ktL);
            b_tien:=a_tien(b_ktL);
            if b_tien=0 and a_lkeM(b_ktL)='B' then
                b_i1:=FKH_ARR_VTRI(a_ma,a_ma_ct(b_ktL));
                if b_i1<>0 then b_tien:=a_tien(b_i1); end if;
            end if;
            if a_lkeP(b_kt)='K' then
                a_pt(b_kt):=0; a_ptB(b_kt):=0; a_phi(b_kt):=0; a_phiB(b_kt):=0;
            else
                a_pt(b_kt):=pvi_pt(b_lp_pvi); a_ptB(b_kt):=pvi_ptB(b_lp_pvi);
                a_ptk(b_kt):=pvi_ptk(b_lp_pvi); a_pp(b_kt):=pvi_pp(b_lp_pvi);
                if a_ptk(b_kt)<>'P' then
                  if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
                     a_phiB(b_kt):=ROUND(a_ptB(b_kt) / b_tygia *b_kho,b_tp);
                  elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
                     a_phiB(b_kt):=ROUND(a_ptB(b_kt) * b_tygia *b_kho,b_tp);
                  else
                     a_phiB(b_kt):=ROUND(a_ptB(b_kt) *b_kho,b_tp);
                  end if;
                elsif a_ptk(b_kt)<>'T' and b_tien<>0 and a_ptB(b_kt)<>0 then
                  if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
                     a_phiB(b_kt):=ROUND(a_ptB(b_kt)* b_tien / b_tygia *b_kho/ 100,b_tp);
                  elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
                     a_phiB(b_kt):=ROUND(a_ptB(b_kt)* b_tien * b_tygia *b_kho/ 100,b_tp);
                  else
                     a_phiB(b_kt):=ROUND(a_ptB(b_kt)* b_tien *b_kho/ 100,b_tp);
                  end if;
                else a_phiB(b_kt):=0;
                end if;
                if a_pp(b_kt) = 'DG' and a_pt(b_kt)>0 then a_phi(b_kt):=ROUND(a_pt(b_kt),b_tp);
                  elsif a_pp(b_kt) = 'DP' and b_tien<>0 and a_pt(b_kt)<>0 then a_phi(b_kt):=ROUND(a_pt(b_kt)*b_tien *b_kho/ 100,b_tp);
                  elsif a_phiB(b_kt)<>0 then
                  a_phi(b_kt):=a_phiB(b_kt);
                  if a_pp(b_kt) = 'GG' then a_phi(b_kt):=ROUND((a_phi(b_kt)-a_pt(b_kt)),b_tp);
                  elsif a_pp(b_kt) = 'GT' and b_tien<>0 and a_pt(b_kt)<>0 then a_phi(b_kt):= a_phi(b_kt) - ROUND(a_pt(b_kt)*b_tien *b_kho/ 100,b_tp);
                  elsif a_pp(b_kt) = 'GP' and a_pt(b_kt)<>0 then a_phi(b_kt):= a_phi(b_kt) - ROUND(a_pt(b_kt)*a_phiB(b_kt)/ 100,b_tp);
                  if a_phi(b_kt)<0 then a_phi(b_kt):=0; end if;
                  end if;
                  elsif a_phiB(b_kt)=0 then a_phi(b_kt):=0;
                end if;
                if a_phi(b_kt)<0 then a_phi(b_kt):=0; end if;
                if a_phiB(b_kt)=0 then a_phiB(b_kt):=a_phi(b_kt); end if;
            end if;
            a_pvi_ma(b_kt):=pvi_ma(b_lp_pvi);
            a_pvi_tc(b_kt):=pvi_tc(b_lp_pvi);
            a_pvi_ktru(b_kt):=pvi_ktru(b_lp_pvi);
        end loop;
        a_tc(b_ktL):='T'; a_lkeP(b_ktL):='T';
    elsif a_lkeP(b_kt) in ('G','D') and a_tien(b_kt)<>0 then
        for b_lp_pvi in 1..pvi_ma.count loop
          a_pt(b_kt):=b_pvi_pt; a_ptB(b_kt):=b_pvi_ptB;
          a_pp(b_kt):=pvi_pp(b_lp_pvi);
        end loop;
        b_tien:=a_tien(b_kt);
        if a_ptB(b_kt)<100 then a_ptk(b_kt):='P'; else a_ptk(b_kt):='T'; end if;
        if a_ptk(b_kt)<>'P' then
          if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
             a_phiB(b_kt):=ROUND(a_ptB(b_kt) / b_tygia *b_kho,b_tp);
          elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
             a_phiB(b_kt):=ROUND(a_ptB(b_kt) * b_tygia *b_kho,b_tp);
          else
             a_phiB(b_kt):=ROUND(a_ptB(b_kt) *b_kho,b_tp);
          end if;
        elsif a_ptk(b_kt)<>'T' and b_tien<>0 and a_ptB(b_kt)<>0 then
          if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
             a_phiB(b_kt):=ROUND(a_ptB(b_kt)* b_tien / b_tygia *b_kho/ 100,b_tp);
          elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
             a_phiB(b_kt):=ROUND(a_ptB(b_kt)* b_tien * b_tygia *b_kho/ 100,b_tp);
          else
             a_phiB(b_kt):=ROUND(a_ptB(b_kt)* b_tien *b_kho/ 100,b_tp);
          end if;
        else a_phiB(b_kt):=0;
        end if;
        if a_pp(b_kt) = 'DG' and a_pt(b_kt)>0 then a_phi(b_kt):=ROUND(a_pt(b_kt),b_tp);
          elsif a_pp(b_kt) = 'DP' and b_tien<>0 and a_pt(b_kt)<>0 then a_phi(b_kt):=ROUND(a_pt(b_kt)*b_tien *b_kho/ 100,b_tp);
          elsif a_phiB(b_kt)<>0 then
          a_phi(b_kt):=a_phiB(b_kt);
          if a_pp(b_kt) = 'GG' then a_phi(b_kt):=ROUND((a_phi(b_kt)-a_pt(b_kt)),b_tp);
          elsif a_pp(b_kt) = 'GT' and b_tien<>0 and a_pt(b_kt)<>0 then a_phi(b_kt):= a_phi(b_kt) - ROUND(a_pt(b_kt)*b_tien *b_kho/ 100,b_tp);
          elsif a_pp(b_kt) = 'GP' and a_pt(b_kt)<>0 then a_phi(b_kt):= a_phi(b_kt) - ROUND(a_pt(b_kt)*a_phiB(b_kt)/ 100,b_tp);
          if a_phi(b_kt)<0 then a_phi(b_kt):=0; end if;
          end if;
          elsif a_phiB(b_kt)=0 then a_phi(b_kt):=0;
        end if;
        if a_phi(b_kt)<0 then a_phi(b_kt):=0; end if;
        if a_phiB(b_kt)=0 then a_phiB(b_kt):=a_phi(b_kt); end if;
    end if;
end loop;
for b_lp_bs in 1..bs_ma.count loop
    b_kt:=b_kt+1; b_ktL:=b_kt;
    select count(*) into b_i1 from bh_nongvn_phi_dk where so_id=b_so_idP and ma=bs_ma(b_lp_bs);
    if b_i1=1 then
    select ma,ten,tc,ma_ct,'T',lkeM,lkeP,lkeB,luy,ktru,ma_dk,ma_dkC,lh_nv,t_suat,cap,nv into
        a_ma(b_kt),a_ten(b_kt),a_tc(b_kt),a_ma_ct(b_kt),a_kieu(b_kt),a_lkeM(b_kt),a_lkeP(b_kt),a_lkeB(b_kt),a_luy(b_kt),a_ktru(b_kt),
        a_ma_dk(b_kt),a_ma_dkC(b_kt),a_lh_nv(b_kt),a_t_suat(b_kt),a_cap(b_kt),a_nv(b_kt)
        from bh_nongvn_phi_dk where so_id=b_so_idP and ma=bs_ma(b_lp_bs);
    else
        select count(*) into b_i1 from bh_ma_dkbs where ma=bs_ma(b_lp_bs) and FBH_MA_NV_CO(nv,'NONG')='C';
        if b_i1<>1 then b_loi:='loi:Sai dieu khoan bo sung '||bs_ma(b_lp_bs)||':loi'; return; end if;
        select ma,ten,lh_nv into a_ma(b_kt),a_ten(b_kt),a_lh_nv(b_kt) from bh_ma_dkbs where ma=bs_ma(b_lp_bs);
        if trim(a_lh_nv(b_kt)) is not null then
            a_t_suat(b_kt):=FBH_MA_LHNV_THUE(a_lh_nv(b_kt));
        else
            if bs_tien(b_lp_bs)<>0 then
                b_loi:='loi:Dieu khoan bo sung '||bs_ma(b_lp_bs)||' khong co loai hinh nghiep vu:loi'; return;
            end if;
            a_t_suat(b_kt):=0;
        end if;
    end if;
    a_tc(b_kt):='C'; a_ma_ct(b_kt):=' '; a_kieu(b_kt):='T'; a_nv(b_kt):='M';
    a_lkeM(b_kt):='G'; a_lkeP(b_kt):='G'; a_lkeB(b_kt):='G'; a_luy(b_kt):=' '; a_ktru(b_kt):='K';
    a_ma_dk(b_kt):=' '; a_ma_dkC(b_kt):=' '; a_cap(b_kt):=0;
    a_pvi_ma(b_kt):=' '; a_pvi_tc(b_kt):=' ';
    if a_ktru(b_kt)<>'P' then a_pvi_ktru(b_kt):=' '; else a_pvi_ktru(b_kt):=b_ktru; end if;
    a_tien(b_kt):=bs_tien(b_lp_bs); a_ptK(b_kt):=bs_ptK(b_lp_bs); a_pp(b_kt):=bs_pp(b_lp_bs);
    if a_tien(b_kt)=0 and nvl(a_lkeM(b_kt),' ')='C' then
        b_i1:=FKH_ARR_VTRI(a_ma_dk,a_ma_dkC(b_kt));
        if b_i1>0 then a_tien(b_kt):=a_tien(b_i1); end if;
    end if;
    a_ptB(b_kt):=bs_ptB(b_lp_bs); a_pt(b_kt):=bs_pt(b_lp_bs);
    b_tien:=a_tien(b_kt);
    if a_ptk(b_kt)<>'P' then
      if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
         a_phiB(b_kt):=ROUND(a_ptB(b_kt) / b_tygia *b_kho,b_tp);
      elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
         a_phiB(b_kt):=ROUND(a_ptB(b_kt) * b_tygia *b_kho,b_tp);
      else
         a_phiB(b_kt):=ROUND(a_ptB(b_kt) *b_kho,b_tp);
      end if;
    elsif a_ptk(b_kt)<>'T' and b_tien<>0 and a_ptB(b_kt)<>0 then
      if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
         a_phiB(b_kt):=ROUND(a_ptB(b_kt)* b_tien / b_tygia *b_kho/ 100,b_tp);
      elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
         a_phiB(b_kt):=ROUND(a_ptB(b_kt)* b_tien * b_tygia *b_kho/ 100,b_tp);
      else
         a_phiB(b_kt):=ROUND(a_ptB(b_kt)* b_tien *b_kho/ 100,b_tp);
      end if;
    else a_phiB(b_kt):=0;
    end if;
    if a_pp(b_kt) = 'DG' and a_pt(b_kt)>0 then a_phi(b_kt):=ROUND(a_pt(b_kt) *b_kho,b_tp);
      elsif a_pp(b_kt) = 'DP' and b_tien<>0 and a_pt(b_kt)<>0 then a_phi(b_kt):=ROUND(a_pt(b_kt)*b_tien *b_kho/ 100,b_tp);
      elsif a_phiB(b_kt)<>0 then
      a_phi(b_kt):=a_phiB(b_kt);
      if a_pp(b_kt) = 'GG' then a_phi(b_kt):=ROUND((a_phi(b_kt)-a_pt(b_kt)) *b_kho,b_tp);
      elsif a_pp(b_kt) = 'GT' and b_tien<>0 and a_pt(b_kt)<>0 then a_phi(b_kt):= a_phi(b_kt) - ROUND(a_pt(b_kt)*b_tien *b_kho/ 100,b_tp);
      elsif a_pp(b_kt) = 'GP' and a_pt(b_kt)<>0 then a_phi(b_kt):= a_phi(b_kt) - ROUND(a_pt(b_kt)*a_phiB(b_kt) *b_kho/ 100,b_tp);
      if a_phi(b_kt)<0 then a_phi(b_kt):=0; end if;
      end if;
      elsif a_phiB(b_kt)=0 then a_phi(b_kt):=0;
    end if;
    if a_phi(b_kt)<0 then a_phi(b_kt):=0; end if;
    if a_phiB(b_kt)=0 then a_phiB(b_kt):=a_phi(b_kt); end if;
end loop;
for b_lp in 1..a_ma.count loop a_thue(b_lp):=0; end loop;
if b_so_idG<>0 and b_ngay_hl<b_ngay_cap then
    select ngay_hl,ngay_kt into b_ngay_hlC,b_ngay_ktC from bh_nong where ma_dvi=b_ma_dvi and so_id=b_so_idG;
    b_i1:=FKH_KHO_NGSO(b_ngay_cap,b_ngay_ktC)/FKH_KHO_NGSO(b_ngay_hlC,b_ngay_ktC); --- He so con cu
    b_i2:=FKH_KHO_NGSO(b_ngay_cap,b_ngay_kt)/FKH_KHO_NGSO(b_ngay_hl,b_ngay_kt);    --- He so con moi
    b_i1:=round(b_i1,2); b_i2:=round(b_i2,2);
    select ma,tien,pt,phi,tc bulk collect into dk_maG,dk_tienG,dk_ptG,dk_phiG,dk_tcG from bh_nong_dk
        where ma_dvi=b_ma_dvi and so_id=b_so_idG order by bt;
    for b_lp in 1..dk_maG.count loop
        b_iX:=b_lp; b_tien:=0;
        for b_lp1 in reverse 1..b_iX loop
            if dk_tienG(b_lp1)<>0 then b_tien:=dk_tienG(b_lp1); exit; end if;
        end loop;
        b_iX:=FKH_ARR_VTRI(a_ma,dk_maG(b_lp));
        if b_iX=0 or b_tien=0 then continue; end if;
        b_phi:=b_tien*dk_ptG(b_lp)/100;
        b_phi:=dk_phiG(b_lp)-round(b_phi*b_i1,b_tp);            -- Phi da dung
        if a_pp(b_iX)<>'DG' then
           a_phi(b_iX):=b_phi+round(a_phi(b_iX)*b_i2,b_tp);     -- Phi con lai: round(a_phi(b_iX)*b_i2,b_tp);
           a_phiB(b_iX):=b_phi+round(a_phiB(b_iX)*b_i2,b_tp);   -- Dieu chinh phi tinh theo bieu phi;
        end if;
    end loop;
end if;
FBH_NONGVNH_PHIb(b_tp,a_ma,a_ma_ct,a_lkeP,a_cap,a_phi,a_ttoan,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
