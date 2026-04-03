-- Nam
create or replace procedure PBH_BT_XEv_TEST(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,dt_ct in out clob,dt_hk clob,
    b_so_hs out varchar2,b_ttrang out varchar2,
    b_nv out varchar2,b_so_hs_bt out varchar2,b_so_id_bt out number,b_ten out nvarchar2,
    b_n_trinh out varchar2,b_n_duyet out varchar2,b_ngay_qd out number,b_ngay_do out number,
    b_c_thue out varchar2,b_nt_tien out varchar2,b_tien out number,b_thue out number,

    dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,
    dk_tc out pht_type.a_var,dk_ma_ct out pht_type.a_var,
    dk_tien_bh out pht_type.a_num,dk_pt_bt out pht_type.a_num,dk_t_that out pht_type.a_num,
    dk_tien out pht_type.a_num,dk_thue out pht_type.a_num,
    dk_tien_qd out pht_type.a_num,dk_thue_qd out pht_type.a_num,
    dk_cap out pht_type.a_var,dk_ma_dk out pht_type.a_var,dk_ma_bs out pht_type.a_var,
    dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,
    dk_nd out pht_type.a_nvar,dk_lkeB out pht_type.a_var,
    hk_nhom out pht_type.a_var,hk_ma out pht_type.a_var,
    hk_ten out pht_type.a_nvar,hk_ma_nt out pht_type.a_var,
    hk_tien out pht_type.a_num,hk_thue out pht_type.a_num,
    hk_tien_qd out pht_type.a_num,hk_thue_qd out pht_type.a_num,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_i2 number; b_tp number:=0; b_tg number:=1;
    b_ma_dvi_ql varchar2(10); b_so_id_hd number; b_so_id_dt number; b_tienHK number;
    b_nvX varchar2(5); b_bb varchar2(1); b_loai varchar2(5); b_t_that number;
    b_ma varchar2(10); b_ma_ct varchar2(10);
    dk_bt_con pht_type.a_num;
    b_oT json_object_t;
begin
-- Dan kiem tra thong tin nhap Phuong an boi thuong
PBH_BTp_TEST(b_ma_dvi,b_nsd,b_so_id,dt_ct,b_oT,b_loi);
if b_loi is not null then return; end if;
b_loi:='loi:Loi xu ly PBH_BT_XEv_TEST:loi';
b_so_hs:=b_oT.get_string('so_hs'); b_ttrang:=b_oT.get_string('ttrang'); b_nv:='V'; 
b_nvX:=b_oT.get_string('nv'); b_so_hs_bt:=b_oT.get_string('so_hs_bt');
if b_nvX not in('TV','BT','TT') then b_loi:='loi:Sai nghiep vu:loi'; return; end if;
b_n_trinh:=b_oT.get_string('n_trinh'); b_n_duyet:=b_oT.get_string('n_duyet');
b_ten:=b_oT.get_string('ten'); b_nt_tien:=b_oT.get_string('nt_tien');
b_ngay_qd:=b_oT.get_number('ngay_qd'); b_ngay_do:=b_oT.get_number('ngay_do'); b_c_thue:='K';
b_tien:=b_oT.get_number('t_cty'); b_thue:=b_oT.get_number('thue_ct'); b_t_that:=b_oT.get_number('tt_cty');
b_bb:=substr(b_nvX,1,1);
if b_nvX='TV' then b_loai:='V'; else b_loai:='TV'; end if;
select count(*) into b_i1 from bh_bt_xe where ma_dvi=b_ma_dvi and so_hs=b_so_hs_bt;
if b_i1=0 then b_loi:='loi:Ho so boi thuong da xoa:loi'; return; end if;
select so_id,ma_dvi_ql,so_id_hd,so_id_dt into b_so_id_bt,b_ma_dvi_ql,b_so_id_hd,b_so_id_dt
    from bh_bt_xe where ma_dvi=b_ma_dvi and so_hs=b_so_hs_bt;
select nvl(min(bt),-1) into b_i1 from bh_xe_dk where
    ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hd and so_id_dt=b_so_id_dt and FBH_MA_LHNV_LHNV(lh_nv,b_bb,b_loai)='C';
if b_i1<0 then
    if b_loai='V' then b_loi:='vat chat xe'; else b_loi:='TNDS ve tai san'; end if;
    b_loi:='loi:Hop dong khong co quyen loi BH '||b_loi||':loi'; return;
end if;
select ma,ten,tc,ma_ct,tien,0,b_t_that,b_tien,b_thue,cap,ma_dk,' ',lh_nv,t_suat,' ',lkeb,0
    into dk_ma(1),dk_ten(1),dk_tc(1),dk_ma_ct(1),dk_tien_bh(1),dk_pt_bt(1),dk_t_that(1),dk_tien(1),dk_thue(1),
    dk_cap(1),dk_ma_dk(1),dk_ma_bs(1),dk_lh_nv(1),dk_t_suat(1),dk_nd(1),dk_lkeB(1),dk_bt_con(1)
    from bh_xe_dk where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hd and so_id_dt=b_so_id_dt and bt=b_i1;
if b_nt_tien<>'VND' then
    b_tp:=2; b_tg:=FBH_TT_TRA_TGTT(b_ngay_qd,b_nt_tien);
end if;
dk_t_suat(1):=nvl(dk_t_suat(1),0);
if b_c_thue <>'C' then dk_thue(1):=0;
else dk_thue(1):= round(dk_tien(1)*dk_t_suat(1)/100, b_tp);
end if;
if b_nt_tien='VND' then
    dk_tien_qd(1):=dk_tien(1); dk_thue_qd(1):=dk_thue(1);
else
    dk_tien_qd(1):=round(b_tg*dk_tien(1),0); dk_thue_qd(1):=round(b_tg*dk_thue(1),0);
end if;
b_ma:=nvl(trim(dk_ma(1)),' ');
while b_ma<>' ' loop
    select nvl(min(ma_ct),' ') into b_ma_ct from bh_xe_dk where
        ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hd and so_id_dt=b_so_id_dt and ma=b_ma;
    b_ma:=b_ma_ct;
    if b_ma<>' ' then
        select count(*) into b_i1 from bh_xe_dk where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hd and so_id_dt=b_so_id_dt and ma=b_ma;
        if b_i1<>1 then b_ma:=' ';
        else
            b_i1:=dk_ma.count+1;
            select ma,ten,tc,ma_ct,tien,0,b_t_that,b_tien,b_thue,cap,ma_dk,' ',lh_nv,t_suat,' ',lkeb,0,0,0
                into dk_ma(b_i1),dk_ten(b_i1),dk_tc(b_i1),dk_ma_ct(b_i1),dk_tien_bh(b_i1),
                dk_pt_bt(b_i1),dk_t_that(b_i1),dk_tien(b_i1),dk_thue(b_i1),dk_cap(b_i1),
                dk_ma_dk(b_i1),dk_ma_bs(b_i1),dk_lh_nv(b_i1),dk_t_suat(b_i1),dk_nd(b_i1),
                dk_lkeB(b_i1),dk_bt_con(b_i1),dk_tien_qd(b_i1),dk_thue_qd(b_i1)
                from bh_xe_dk where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hd and so_id_dt=b_so_id_dt and ma=b_ma;
        end if;
    end if;
end loop;
b_tienHK:=0;
if trim(dt_hk) is null then
    PKH_MANG_KD(hk_ma_nt);
else
    b_lenh:=FKH_JS_LENH('nhom,ma,ten,ma_nt,tien,thue');
    EXECUTE IMMEDIATE b_lenh bulk collect into hk_nhom,hk_ma,hk_ten,hk_ma_nt,hk_tien,hk_thue using dt_hk;
    b_i1:=0;
    for b_lp in 1..hk_ma.count loop
        hk_ma_nt(b_lp):=b_nt_tien;
        if b_nt_tien='VND' then
            hk_tien_qd(b_lp):=hk_tien(b_lp); hk_thue_qd(b_lp):=hk_thue(b_lp);
        else
            hk_tien_qd(b_lp):=round(hk_tien(b_lp)*b_tg,0); hk_thue_qd(b_lp):=round(hk_thue(b_lp)*b_tg,0);
        end if;
        b_tienHK:=b_tienHK+hk_tien(b_lp);
        if trim(hk_ma(b_lp)) is not null then
            b_i2:=PKH_LOC_CHU_SO(hk_ma(b_lp),'F','F');
            if b_i2<100000 and b_i2>b_i1 then b_i1:=b_i2; end if;
        else
            b_i1:=b_i1+1; hk_ma(b_lp):=to_char(b_i1);
        end if;
    end loop;
    if b_tien<b_tienHK then b_loi:='loi:Tien phuong an nho hon tien huong khac:loi'; return; end if;
end if;
dt_ct:=b_oT.to_string();
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BT_XEv_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000); b_i1 number; b_ma_dviC varchar2(20);
    dt_ct clob; dt_t clob; dt_s clob; dt_k clob; dt_hk clob;
    b_so_id number; b_so_hs varchar2(30); b_ttrang varchar2(1); b_ngay_ht number:=PKH_NG_CSO(sysdate);
    b_nv varchar2(1); b_so_hs_bt varchar2(20); b_so_id_bt number; b_ten nvarchar2(500); 
    b_n_trinh varchar2(20); b_n_duyet varchar2(20); b_ngay_qd number; b_ngay_do number; 
    b_c_thue varchar2(1); b_nt_tien varchar2(5); b_tien number; b_thue number;

    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var; dk_ma_ct pht_type.a_var; 
    dk_tien_bh pht_type.a_num; dk_pt_bt pht_type.a_num; dk_t_that pht_type.a_num; 
    dk_tien pht_type.a_num; dk_thue pht_type.a_num; dk_tien_qd pht_type.a_num; dk_thue_qd pht_type.a_num;
    dk_cap pht_type.a_var; dk_ma_dk pht_type.a_var; dk_ma_bs pht_type.a_var; 
    dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num; dk_nd pht_type.a_nvar; dk_lkeB pht_type.a_var; 
    hk_nhom pht_type.a_var; hk_ma pht_type.a_var; hk_ten pht_type.a_nvar; hk_ma_nt pht_type.a_var; 
    hk_tien pht_type.a_num; hk_thue pht_type.a_num; hk_tien_qd pht_type.a_num; hk_thue_qd pht_type.a_num;
begin
-- Dan - Nhap Phuong an boi thuong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id');
EXECUTE IMMEDIATE b_lenh into b_so_id using b_oraIn;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_t,dt_s,dt_k,dt_hk');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_t,dt_s,dt_k,dt_hk using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_t); FKH_JSa_NULL(dt_s); FKH_JSa_NULL(dt_k); FKH_JSa_NULL(dt_hk);
b_so_id:=nvl(b_so_id,0);
if b_so_id<>0 then
    select count(*) into b_i1 from bh_bt_xeP where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1=0 then b_so_id:=0; end if;
end if;
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
else
    -- chuclh: theo don vi hsbt
    select ma_dvi into b_ma_dviC from bh_bt_xeP where so_id=b_so_id;
    PBH_BT_XEp_XOA_XOA(b_ma_dviC,b_nsd,b_so_id,true,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_XEv_TEST(
    b_ma_dvi,b_nsd,b_so_id,dt_ct,dt_hk,
    b_so_hs,b_ttrang,b_nv,b_so_hs_bt,b_so_id_bt,b_ten,
    b_n_trinh,b_n_duyet,b_ngay_qd,b_ngay_do,b_c_thue,b_nt_tien,b_tien,b_thue,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_tien_bh,dk_pt_bt,dk_t_that,
    dk_tien,dk_thue,dk_tien_qd,dk_thue_qd,dk_cap,dk_ma_dk,dk_ma_bs,dk_lh_nv,dk_t_suat,dk_nd,dk_lkeB,
    hk_nhom,hk_ma,hk_ten,hk_ma_nt,hk_tien,hk_thue,hk_tien_qd,hk_thue_qd,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_XEp_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,dt_ct,'',dt_hk,
    b_so_hs,b_ttrang,b_nv,b_so_hs_bt,b_so_id_bt,b_ten,
    b_n_trinh,b_n_duyet,b_ngay_qd,b_ngay_do,
    b_c_thue,b_nt_tien,b_tien,b_thue,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_tien_bh,dk_pt_bt,dk_t_that,dk_tien,dk_thue,
    dk_tien_qd,dk_thue_qd,dk_cap,dk_ma_dk,dk_ma_bs,dk_lh_nv,dk_t_suat,dk_nd,dk_lkeB,
    hk_nhom,hk_ma,hk_ten,hk_ma_nt,hk_tien,hk_thue,hk_tien_qd,hk_thue_qd,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if dt_t is not null then
    insert into bh_bt_xe_txt values(b_ma_dvi,b_so_id,'dt_t',dt_t);
end if;
if dt_s is not null then
    insert into bh_bt_xe_txt values(b_ma_dvi,b_so_id,'dt_s',dt_s);
end if;
if dt_k is not null then
    insert into bh_bt_xe_txt values(b_ma_dvi,b_so_id,'dt_k',dt_k);
end if;
commit;
select json_object('so_id' value b_so_id,'so_hs' value b_so_hs) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--chuclh: khong thay ham - them return clob
create or replace procedure PBH_BT_XEv_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(3000); b_i1 number; b_so_id number;
    dt_ct clob; dt_t clob:=''; dt_s clob:=''; dt_k clob:=''; dt_hk clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id'); 
select count(*) into b_i1 from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=0 then b_oraOut:=''; return; end if;
select txt into dt_ct from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
select count(*) into b_i1 from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_t';
if b_i1<>0 then
    select txt into dt_t from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_t';
end if;
select count(*) into b_i1 from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_s';
if b_i1<>0 then
    select txt into dt_s from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_s';
end if;
select count(*) into b_i1 from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_k';
if b_i1<>0 then
    select txt into dt_k from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_k';
end if;
select count(*) into b_i1 from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
if b_i1<>0 then
    select txt into dt_hk from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
end if;
select json_object('so_id' value b_so_id,
    'dt_t' value dt_t,'dt_s' value dt_s,'dt_k' value dt_k,'dt_hk' value dt_hk,'dt_ct' value dt_ct returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_XEv_TTIN_XE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_so_hs varchar2(20); b_so_idB number; b_ngay_xr number;
    b_ma_dvi_ql varchar2(10); b_so_id_hd number; b_so_id_dt number;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_hs:=nvl(trim(b_oraIn),' ');
if b_so_hs=' ' then b_loi:='loi:Nhap so ho so boi thuong:loi'; raise PROGRAM_ERROR; end if;
select ma_dvi_ql,so_id_hd,so_id_dt,ngay_xr into b_ma_dvi_ql,b_so_id_hd,b_so_id_dt,b_ngay_xr
    from bh_bt_xe where ma_dvi=b_ma_dvi and so_hs=b_so_hs;
b_so_idB:=FBH_XE_SO_IDb(b_ma_dvi_ql,b_so_id_hd,b_ngay_xr);
select json_object(bien_xe,nam_sx,'hang' value FBH_XE_HANG_TENl(hang),
    hieu,'pban' value FBH_XE_PB_TENl(hang,hieu,pban),'ten' value tenc) into b_oraOut
    from bh_xe_ds where ma_dvi=b_ma_dvi_ql and so_id=b_so_idB and so_id_dt=b_so_id_dt;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
