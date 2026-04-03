create or replace procedure PBH_PQU_BT_XOL(
    b_ma_dviN varchar2,b_nsdN varchar2,b_nv varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_lenh varchar2(1000); b_xol varchar2(1); b_txt clob;
begin
-- dan - Kiem tra phan quyen
b_loi:='loi:Loi xu ly PBH_PQU_BT_XOL:loi';
b_lenh:='select count(*) from bh_bt_'||b_nv||'_txt where ma_dvi= :ma_dvi and so_id= :so_id and loai= :loai';
EXECUTE IMMEDIATE b_lenh into b_i1 using b_ma_dvi,b_so_id,'dt_ct';
if b_i1=1 then
    b_lenh:='select txt from bh_bt_'||b_nv||'_txt where ma_dvi= :ma_dvi and so_id= :so_id and loai= :loai';
    EXECUTE IMMEDIATE b_lenh into b_txt using b_ma_dvi,b_so_id,'dt_ct';
    b_xol:=nvl(trim(FKH_JS_GTRIs(b_txt,'xol')),'C');
    if b_xol<>'C' and FBH_PQU_KTRA_KHs(b_ma_dviN,b_nsdN,'BT_XOL','C','B')='K' then
        b_loi:='loi:Khong dat bo xu ly XOL:loi'; return;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PQU_BT_CSYT(
    b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_dgia varchar2(1); b_dgiaX varchar2(1):='1';
    a_dgia pht_type.a_var;
begin
-- dan - Duyet CSYT
b_loi:='loi:Loi xu ly PBH_PQU_BT_CSYT:loi';
for r_lp in (select distinct ma from bh_bt_ng_grv where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    b_dgia:=nvl(trim(FBH_DTAC_MA_TXT(r_lp.ma,'dgia')),'1');
    if b_dgiaX<b_dgia then b_dgiaX:=b_dgia; end if;
end loop;
if b_dgiaX<>'1' and  FBH_PQU_KTRA_KHs(b_ma_dviN,b_nsdN,'BT_CSYT',b_dgiaX,'NB')='K' then
    b_i1:=PKH_LOC_CHU_SO(b_dgiaX,'F','F');
    PKH_CH_ARR('Tot,Kha,Trung binh,Xau,Rat xau',a_dgia);
    b_loi:='loi:Khong duyet boi thuong CSYT bi danh gia '||a_dgia(b_i1)||':loi'; return;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure FBH_HANG_PQU_BT(
    b_ma_dvi_ks varchar2,b_nsd_ks varchar2,
    a_dgoi pht_type.a_var,a_loai pht_type.a_var,
    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tien pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number;
    a_loaiL pht_type.a_var; a_maL pht_type.a_var; a_loi pht_type.a_var;
begin
-- Nam - Kiem tra phan quyen
PBH_PQU_NHOM_BTHa(b_ma_dvi_ks,b_nsd_ks,'HANG',' ',dk_ma,dk_ten,dk_tien,b_loi);
if b_loi is not null then return; end if;
b_i1:=FKH_ARR_TONG(dk_tien);
if a_dgoi.count<>0 then
    a_loaiL(1):='DGOI';  a_loi(1):='Phuong thuc dong goi';
    for b_lp in 1..a_dgoi.count loop
        a_maL(1):=a_dgoi(b_lp);
        PBH_PQU_KTRA_BTMA(b_ma_dvi_ks,b_nsd_ks,'HANG',b_i1,a_loaiL,a_maL,a_loi,b_loi);
        if b_loi is not null then return; end if;
    end loop;
end if;
if a_loai.count<>0 then
    a_loaiL(1):='LOAI';  a_loi(1):='Loai hang';
    for b_lp in 1..a_loai.count loop
        a_maL(1):=a_loai(b_lp);
        PBH_PQU_KTRA_BTMA(b_ma_dvi_ks,b_nsd_ks,'HANG',b_i1,a_loaiL,a_maL,a_loi,b_loi);
        if b_loi is not null then return; end if;
    end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_HANG_PQU_BT:loi'; end if;
end;
/
create or replace procedure PBH_HANG_PQU_BT(
    b_ma_dvi_ks varchar2,b_nsd_ks varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ma_dvi_ql varchar2(10); b_so_id_hd number; b_so_id_hdB number;
    b_ngay_xr number;
    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tien pht_type.a_num;
    a_dgoi pht_type.a_var; a_loai pht_type.a_var;
begin
-- dan - Kiem tra phan quyen
b_loi:='loi:Ho so da xoa:loi';
select ma_dvi_ql,so_id_hd,ngay_xr into b_ma_dvi_ql,b_so_id_hd,b_ngay_xr
    from bh_bt_hang where ma_dvi=b_ma_dvi and so_id=b_so_id;
select ma,ten,tien bulk collect into dk_ma,dk_ten,dk_tien
    from bh_bt_hang_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_so_id_hdB:=FBH_HANG_SO_IDb(b_ma_dvi_ql,b_so_id_hd,b_ngay_xr);
select dgoi bulk collect into a_dgoi
    from bh_hang_ds where ma_dvi=b_ma_dvi and so_id=b_so_id_hdB group by dgoi having sum(mtn)<>0;
select ma_lhang bulk collect into a_loai
    from bh_hang_ds where ma_dvi=b_ma_dvi and so_id=b_so_id_hdB group by ma_lhang having sum(mtn)<>0;
FBH_HANG_PQU_BT(b_ma_dvi_ks,b_nsd_ks,a_dgoi,a_loai,dk_ma,dk_ten,dk_tien,b_loi);
if b_loi is not null then return; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_2B_PQU_BT(
    b_ma_dvi_ks varchar2,b_nsd_ks varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ma_dvi_ql varchar2(10); b_so_id_hd number; b_so_id_dt number;
    b_ngay_xr number; b_so_id_hdB number; b_ma_sp varchar2(10);
    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tien pht_type.a_num;
begin
-- dan - Kiem tra phan quyen
b_loi:='loi:Ho so da xoa:loi';
select ma_dvi_ql,so_id_hd,so_id_dt,ngay_xr into b_ma_dvi_ql,b_so_id_hd,b_so_id_dt,b_ngay_xr
    from bh_bt_2b where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_so_id_hdB:=FBH_2B_SO_IDb(b_ma_dvi_ql,b_so_id_hd,b_ngay_xr);
select ma_sp into b_ma_sp from bh_2b_ds where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB and so_id_dt=b_so_id_dt;
select ma,ten,tien bulk collect into dk_ma,dk_ten,dk_tien
    from bh_bt_2b_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
PBH_PQU_NHOM_BTHa(b_ma_dvi_ks,b_nsd_ks,'2B',b_ma_sp,dk_ma,dk_ten,dk_tien,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure FBH_XE_PQU_BT(
    b_ma_dvi_ks varchar2,b_nsd_ks varchar2,b_md_sd varchar2,b_loai_xe varchar2,b_ma_sp varchar2,
    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tien pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number;
    a_loaiL pht_type.a_var; a_maL pht_type.a_var; a_loi pht_type.a_var;
begin
-- Nam - Kiem tra phan quyen
PBH_PQU_NHOM_BTHa(b_ma_dvi_ks,b_nsd_ks,'XE',b_ma_sp,dk_ma,dk_ten,dk_tien,b_loi);
if b_loi is not null then return; end if;
a_loaiL(1):='MDSD'; a_maL(1):=b_md_sd; a_loi(1):='muc dich su dung';
a_loaiL(2):='LOAI'; a_maL(2):=b_loai_xe; a_loi(2):='loai xe';
b_i1:=FKH_ARR_TONG(dk_tien);
PBH_PQU_KTRA_BTMA(b_ma_dvi_ks,b_nsd_ks,'XE',b_i1,a_loaiL,a_maL,a_loi,b_loi);
if b_loi is not null then return; end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_XE_PQU_BT:loi'; end if;
end;
/
create or replace procedure PBH_XE_PQU_BT(
    b_ma_dvi_ks varchar2,b_nsd_ks varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_so_id_bt number;
    b_ma_dvi_ql varchar2(10); b_so_id_hd number; b_so_id_dt number;
    b_ngay_xr number; b_so_id_hdB number; b_ma_sp varchar2(10);
    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tien pht_type.a_num;
begin
-- dan - Kiem tra phan quyen
b_loi:='loi:Loi xu ly PBH_XE_PQU_BT:loi';
select nvl(min(so_id_bt),0) into b_so_id_bt from bh_bt_xeP where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_so_id_bt=0 then
    select count(*) into b_i1 from bh_bt_xe where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1=0 then b_loi:='loi:Ho so, phuong an boi thuong da xoa:loi'; return; end if;
    b_so_id_bt:=b_so_id;
end if;
select ma_dvi_ql,so_id_hd,so_id_dt,ngay_xr into b_ma_dvi_ql,b_so_id_hd,b_so_id_dt,b_ngay_xr
    from bh_bt_xe where ma_dvi=b_ma_dvi and so_id=b_so_id_bt;
b_so_id_hdB:=FBH_XE_SO_IDb(b_ma_dvi_ql,b_so_id_hd,b_ngay_xr);
select ma_sp into b_ma_sp from bh_xe_ds where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB and so_id_dt=b_so_id_dt;
select ma,ten,tien bulk collect into dk_ma,dk_ten,dk_tien
    from bh_bt_xe_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
for r_lp in (select * from bh_xe_ds where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB) loop
    FBH_XE_PQU_BT(b_ma_dvi_ks,b_nsd_ks,r_lp.md_sd,r_lp.loai_xe,b_ma_sp,dk_ma,dk_ten,dk_tien,b_loi);
    if b_loi is not null then return; end if;
end loop;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_TAU_PQU_BT(
    b_ma_dvi_ks varchar2,b_nsd_ks varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ma_dvi_ql varchar2(10); b_so_id_hd number; b_so_id_dt number;
    b_ngay_xr number; b_so_id_hdB number;
    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tien pht_type.a_num;
begin
-- Nam - Kiem tra phan quyen
b_loi:='loi:Ho so da xoa:loi';
select ma_dvi_ql,so_id_hd,so_id_dt,ngay_xr into 
       b_ma_dvi_ql,b_so_id_hd,b_so_id_dt,b_ngay_xr
    from bh_bt_tau where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_so_id_hdB:=FBH_TAU_SO_IDb(b_ma_dvi_ql,b_so_id_hd,b_ngay_xr);
select ma,ten,tien bulk collect into dk_ma,dk_ten,dk_tien
    from bh_bt_tau_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
for r_lp in (select * from bh_tau_ds where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB) loop
    FBH_TAU_PQU_BT(b_ma_dvi_ks,b_nsd_ks,r_lp.nhom,r_lp.ma_sp,dk_ma,dk_ten,dk_tien,b_loi);
    if b_loi is not null then return; end if;
end loop;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure FBH_TAU_PQU_BT(
    b_ma_dvi_ks varchar2,b_nsd_ks varchar2,b_nhom varchar2,b_ma_sp varchar2,
    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tien pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number;
    a_loaiL pht_type.a_var; a_maL pht_type.a_var; a_loi pht_type.a_var;
begin
-- Nam - Kiem tra phan quyen
PBH_PQU_NHOM_BTHa(b_ma_dvi_ks,b_nsd_ks,'TAU',b_ma_sp,dk_ma,dk_ten,dk_tien,b_loi);
if b_loi is not null then return; end if;
a_loaiL(1):='NHOM'; a_maL(1):=b_nhom; a_loi(1):='Nhom';
b_i1:=FKH_ARR_TONG(dk_tien);
PBH_PQU_KTRA_BTMA(b_ma_dvi_ks,b_nsd_ks,'TAU',b_i1,a_loaiL,a_maL,a_loi,b_loi);
if b_loi is not null then return; end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_TAU_PQU_BT:loi'; end if;
end;
/
create or replace procedure FBH_NG_PQU_BT(
    b_ma_dvi_ks varchar2,b_nsd_ks varchar2,b_ma_dvi varchar2,b_so_id number,b_ma_sp varchar2,
    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tien pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number;
    a_loaiL pht_type.a_var; a_maL pht_type.a_var; a_loi pht_type.a_var;
begin
-- Nam - Kiem tra phan quyen
PBH_PQU_NHOM_BTHa(b_ma_dvi_ks,b_nsd_ks,'NG',b_ma_sp,dk_ma,dk_ten,dk_tien,b_loi);
if b_loi is not null then return; end if;
PBH_PQU_BT_CSYT(b_ma_dvi_ks,b_nsd_ks,b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
a_loaiL(1):='MA_SP'; a_maL(1):=b_ma_sp; a_loi(1):='San pham';
b_i1:=FKH_ARR_TONG(dk_tien);
PBH_PQU_KTRA_BTMA(b_ma_dvi_ks,b_nsd_ks,'NG',b_i1,a_loaiL,a_maL,a_loi,b_loi);
if b_loi is not null then return; end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_NG_PQU_BT:loi'; end if;
end;
/
create or replace procedure PBH_NG_PQU_BT(
    b_ma_dvi_ks varchar2,b_nsd_ks varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_ma_dvi_ql varchar2(10);b_so_id_hd number; b_so_id_dt number;
    b_ngay_xr number; b_so_id_hdB number; b_ma_sp varchar2(10):=' ';
    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tien pht_type.a_num;
begin
-- dan - Kiem tra phan quyen
b_loi:='loi:Ho so da xoa:loi';
select ma_dvi_ql,so_id_hd,so_id_dt,ngay_xr into b_ma_dvi_ql,b_so_id_hd,b_so_id_dt,b_ngay_xr
    from bh_bt_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_so_id_hdB:=FBH_NG_SO_IDb(b_ma_dvi_ql,b_so_id_hd,b_ngay_xr);
-- chuclh kiem tra hdb khong co ds
select count(*) into b_i1 from bh_ng_ds where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB;
-- chuclh kiem tra hdb khong co ds
select count(*) into b_i1 from bh_ng_ds where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB;
select ma,ten,tien bulk collect into dk_ma,dk_ten,dk_tien
    from bh_bt_ng_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1 > 0 then 
  select ma_sp into b_ma_sp from bh_ng_ds where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB and so_id_dt = b_so_id_dt;
end if;
FBH_NG_PQU_BT(b_ma_dvi_ks,b_nsd_ks,b_ma_dvi,b_so_id,b_ma_sp,dk_ma,dk_ten,dk_tien,b_loi);
if b_loi is not null then return; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure FBH_PHH_PQU_BT(
    b_ma_dvi_ks varchar2,b_nsd_ks varchar2,b_mrr varchar2,b_ma_dt varchar2,b_ma_sp varchar2,
    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tien pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number;
    b_nhom varchar2(10):=FBH_PHH_DTUONG_NHOM(b_ma_dt);
    a_loaiL pht_type.a_var; a_maL pht_type.a_var; a_loi pht_type.a_var;
begin
-- Nam - Kiem tra phan quyen
PBH_PQU_NHOM_BTHa(b_ma_dvi_ks,b_nsd_ks,'PHH',b_ma_sp,dk_ma,dk_ten,dk_tien,b_loi);
if b_loi is not null then return; end if;
b_i1:=FKH_ARR_TONG(dk_tien);
a_loaiL(1):='MRR'; a_maL(1):=b_mrr; a_loi(1):='muc rui ro';
a_loaiL(2):='NHOM'; a_maL(2):=b_nhom; a_loi(2):='Nhom doi tuong';
PBH_PQU_KTRA_BTMA(b_ma_dvi_ks,b_nsd_ks,'PHH',b_i1,a_loaiL,a_maL,a_loi,b_loi);
if b_loi is not null then return; end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_PHH_PQU_BT:loi'; end if;
end;
/
create or replace procedure PBH_PHH_PQU_BT(
    b_ma_dvi_ks varchar2,b_nsd_ks varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ma_dvi_ql varchar2(10); b_so_id_hd number; b_so_id_dt number;
    b_ngay_xr number; b_so_id_hdB number; b_ma_sp varchar2(10);
    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tien pht_type.a_num;
begin
-- dan - Kiem tra phan quyen
b_loi:='loi:Ho so da xoa:loi';
select ma_dvi_ql,so_id_hd,so_id_dt,ngay_xr into b_ma_dvi_ql,b_so_id_hd,b_so_id_dt,b_ngay_xr
    from bh_bt_phh where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_so_id_hdB:=FBH_PHH_SO_IDb(b_ma_dvi_ql,b_so_id_hd,b_ngay_xr);
select ma_sp into b_ma_sp from bh_phh where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB;
select ma,ten,tien bulk collect into dk_ma,dk_ten,dk_tien
    from bh_bt_phh_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
for r_lp in (select * from bh_phh_dvi where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB) loop
    FBH_PHH_PQU_BT(b_ma_dvi_ks,b_nsd_ks,r_lp.mrr,r_lp.ma_dt,b_ma_sp,dk_ma,dk_ten,dk_tien,b_loi);
    if b_loi is not null then return; end if;
end loop;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure FBH_PKT_PQU_BT(
    b_ma_dvi_ks varchar2,b_nsd_ks varchar2,b_dtuong varchar2,b_ma_sp varchar2,
    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tien pht_type.a_num,
    pvi_ma pht_type.a_var,pvi_ten pht_type.a_nvar,pvi_tien pht_type.a_num,b_loi out varchar2)
AS
begin
-- Nam - Kiem tra phan quyen
PBH_PQU_NHOM_BTHa(b_ma_dvi_ks,b_nsd_ks,'PKT',b_ma_sp,dk_ma,dk_ten,dk_tien,b_loi);
if b_loi is not null then return; end if;
PBH_PQU_KTRA_BTMAa(b_ma_dvi_ks,b_nsd_ks,b_dtuong,'PKT','PVI',pvi_ma,pvi_ten,pvi_tien,b_loi);
if b_loi is not null then return; end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_PKT_PQU_BT:loi'; end if;
end;
/
create or replace procedure PBH_PKT_PQU_BT(
    b_ma_dvi_ks varchar2,b_nsd_ks varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ma_dvi_ql varchar2(10); b_so_id_hd number; b_so_id_dt number;
    b_ngay_xr number; b_so_id_hdB number; b_ma_sp varchar2(10);
    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tien pht_type.a_num; dk_lh_nv pht_type.a_var;
    pvi_ma pht_type.a_var; pvi_ten pht_type.a_nvar; pvi_tien pht_type.a_num;
begin
-- dan - Kiem tra phan quyen
b_loi:='loi:Ho so da xoa:loi';
select ma_dvi_ql,so_id_hd,so_id_dt,ngay_xr into b_ma_dvi_ql,b_so_id_hd,b_so_id_dt,b_ngay_xr
    from bh_bt_pkt where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_so_id_hdB:=FBH_PKT_SO_IDb(b_ma_dvi_ql,b_so_id_hd,b_ngay_xr);
select ma_sp into b_ma_sp from bh_pkt where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB;
select ma,ten,tien bulk collect into dk_ma,dk_ten,dk_tien
    from bh_bt_pkt_dk where ma_dvi=b_ma_dvi and so_id=b_so_id_hdB;
for r_lp in (select * from bh_pkt_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id_hdB) loop 
    select pvi_ma,lh_nv,FBH_PKT_PVI_TEN(pvi_ma),tien bulk collect into pvi_ma,dk_lh_nv,pvi_ten,pvi_tien
        from bh_pkt_dk where ma_dvi=b_ma_dvi and so_id=b_so_id_hdB and so_id_dt=r_lp.so_id_dt;
    for b_lp in 1..pvi_ma.count loop
        pvi_tien(b_lp):=pvi_tien(b_lp)-FBH_DONG_TL_TIEN(b_ma_dvi,b_so_id_hdB,r_lp.so_id_dt,dk_lh_nv(b_lp),pvi_tien(b_lp));
    end loop;
end loop;
for r_lp in (select * from bh_pkt_dvi where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB) loop
    FBH_PKT_PQU_BT(b_ma_dvi_ks,b_nsd_ks,r_lp.dvi,b_ma_sp,dk_ma,dk_ten,dk_tien,pvi_ma,pvi_ten,pvi_tien,b_loi);
    if b_loi is not null then return; end if;
end loop;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PTN_PQU_BT(
    b_ma_dvi_ks varchar2,b_nsd_ks varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ma_dvi_ql varchar2(10); b_so_id_hd number;
    b_ngay_xr number; b_so_id_hdB number; b_ma_sp varchar2(10);
    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tien pht_type.a_num;
begin
-- Nam - Kiem tra phan quyen
b_loi:='loi:Ho so da xoa:loi';
select ma_dvi_ql,so_id_hd,ngay_xr into b_ma_dvi_ql,b_so_id_hd,b_ngay_xr
    from bh_bt_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_so_id_hdB:=FBH_PTN_SO_IDbt(b_ma_dvi_ql,b_so_id_hd,b_ngay_xr);
select ma_sp into b_ma_sp from bh_ptn where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB;
select ma,ten,tien bulk collect into dk_ma,dk_ten,dk_tien
    from bh_bt_ptn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
PBH_PQU_NHOM_BTHa(b_ma_dvi_ks,b_nsd_ks,'PTN',b_ma_sp,dk_ma,dk_ten,dk_tien,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HOP_PQU_BT(
    b_ma_dvi_ks varchar2,b_nsd_ks varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ma_dvi_ql varchar2(10); b_so_id_hd number;
    b_ngay_xr number; b_so_id_hdB number; b_ma_sp varchar2(10);
    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tien pht_type.a_num;
begin
-- Nam - Kiem tra phan quyen
b_loi:='loi:Ho so da xoa:loi';
select ma_dvi_ql,so_id_hd,ngay_xr into b_ma_dvi_ql,b_so_id_hd,b_ngay_xr
    from bh_bt_hop where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_so_id_hdB:=FBH_HOP_SO_IDb(b_ma_dvi_ql,b_so_id_hd,b_ngay_xr);
select ma_sp into b_ma_sp from bh_hop where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB;
select ma,ten,tien bulk collect into dk_ma,dk_ten,dk_tien
    from bh_bt_hop_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
PBH_PQU_NHOM_BTHa(b_ma_dvi_ks,b_nsd_ks,'HOP',b_ma_sp,dk_ma,dk_ten,dk_tien,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_NONG_PQU_BT(
    b_ma_dvi_ks varchar2,b_nsd_ks varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ma_dvi_ql varchar2(10); b_so_id_hd number;
    b_ngay_xr number; b_so_id_hdB number; b_ma_sp varchar2(10);
    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tien pht_type.a_num;
begin
-- Nam - Kiem tra phan quyen
b_loi:='loi:Ho so da xoa:loi';
select ma_dvi_ql,so_id_hd,ngay_xr into b_ma_dvi_ql,b_so_id_hd,b_ngay_xr
    from bh_bt_nong where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_so_id_hdB:=FBH_NONG_SO_IDb(b_ma_dvi_ql,b_so_id_hd,b_ngay_xr);
select ma_sp into b_ma_sp from bh_nong where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB;
select ma,ten,tien bulk collect into dk_ma,dk_ten,dk_tien
    from bh_bt_nong_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
PBH_PQU_NHOM_BTHa(b_ma_dvi_ks,b_nsd_ks,'NONG',b_ma_sp,dk_ma,dk_ten,dk_tien,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PQU_BT(
    b_nv varchar2,b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
begin
-- Dan - Ktra phan quyen
PBH_PQU_BT_XOL(b_ma_dviN,b_nsdN,b_nv,b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
if b_nv='PHH' then
    PBH_PHH_PQU_BT(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
elsif b_nv='PKT' then
    PBH_PKT_PQU_BT(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
elsif b_nv='XE' then
    PBH_XE_PQU_BT(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
elsif b_nv='2B' then
    PBH_2B_PQU_BT(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
elsif b_nv='TAU' then
    PBH_TAU_PQU_BT(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
elsif b_nv='NG' then
    PBH_NG_PQU_BT(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
elsif b_nv='HANG' then
    PBH_HANG_PQU_BT(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
-- nam them nghiep vu
elsif b_nv='PTN' then
    PBH_PTN_PQU_BT(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
elsif b_nv='HOP' then
    PBH_HOP_PQU_BT(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
elsif b_nv='NONG' then
    PBH_NONG_PQU_BT(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function FBH_PQU_BT(
    b_nv varchar2,b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number) return varchar2
AS
	b_loi varchar2(100); b_kq varchar2(1):='K';
begin
PBH_PQU_BT(b_nv,b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
if b_loi is null then b_kq:='C'; end if;
return b_kq;
end;
/
-- viet anh -- them prod thieu chua luu
create or replace function FBH_MA_BV_TXT(b_ma varchar2,b_tim varchar2) return varchar2
as
    b_kq varchar2(1):=''; b_i1 number; b_txt clob;
begin
-- Dan - Tra nhom: B-Benh vien, P-Phong kham
if trim(b_ma) is not null then
    select count(*) into b_i1 from bh_dtac_ma_txt where ma=b_ma;
    if b_i1<>0 then
        select txt into b_txt from bh_dtac_ma_txt where ma=b_ma;
        b_kq:=FKH_JS_GTRIs(b_txt,b_tim);
    end if;
end if;
return b_kq;
end;
/