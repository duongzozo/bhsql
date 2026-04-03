create or replace procedure PBH_2B_BT_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,b_ttrang varchar2,b_ngay_qd number,b_loi out varchar2)
AS
    b_i1 number; b_nv varchar2(10); b_txt clob;
begin
-- dan - Update sau duyet
b_loi:='loi:Loi xu ly PBH_2B_BT_DU:loi';
update bh_bt_2b set ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks,ngay_qd=b_ngay_qd,n_duyet=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
select txt into b_txt from bh_bt_2b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
PKH_JS_THAYa(b_txt,'n_duyet,ksoat,dvi_ksoat,ttrang',b_nsd_ks||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
PKH_JS_THAYn(b_txt,'ngay_qd',b_ngay_qd); b_txt:=b_txt;
update bh_bt_2b_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_NG_BT_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,b_ttrang varchar2,b_ngay_qd number,b_loi out varchar2)
AS
    b_i1 number; b_nv varchar2(10); b_txt clob;
begin
-- dan - Update sau duyet
b_loi:='loi:Loi xu ly PBH_NG_BT_DU:loi';
update bh_bt_ng set ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks,ngay_qd=b_ngay_qd,n_duyet=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
select txt into b_txt from bh_bt_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
PKH_JS_THAYa(b_txt,'n_duyet,ksoat,dvi_ksoat,ttrang',b_nsd_ks||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
PKH_JS_THAYn(b_txt,'ngay_qd',b_ngay_qd); b_txt:=b_txt;
update bh_bt_ng_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PHH_BT_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,b_ttrang varchar2,b_ngay_qd number,b_loi out varchar2)
AS
    b_i1 number; b_txt clob;
begin
-- dan - Update sau duyet
b_loi:='loi:Loi xu ly PBH_PHH_BT_DU:loi';
update bh_bt_phh set ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks,ngay_qd=b_ngay_qd,n_duyet=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
select txt into b_txt from bh_bt_phh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
PKH_JS_THAYa(b_txt,'n_duyet,ksoat,dvi_ksoat,ttrang',b_nsd_ks||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
PKH_JS_THAYn(b_txt,'ngay_qd',b_ngay_qd); b_txt:=b_txt;
update bh_bt_phh_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PKT_BT_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,b_ttrang varchar2,b_ngay_qd number,b_loi out varchar2)
AS
    b_i1 number; b_txt clob;
begin
-- dan - Update sau duyet
b_loi:='loi:Loi xu ly PBH_PKT_BT_DU:loi';
update bh_bt_pkt set ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks,ngay_qd=b_ngay_qd,n_duyet=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
select txt into b_txt from bh_bt_pkt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
PKH_JS_THAYa(b_txt,'n_duyet,ksoat,dvi_ksoat,ttrang',b_nsd_ks||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
PKH_JS_THAYn(b_txt,'ngay_qd',b_ngay_qd); b_txt:=b_txt;
update bh_bt_pkt_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_TAU_BT_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,b_ttrang varchar2,b_ngay_qd number,b_loi out varchar2)
AS
    b_i1 number; b_txt clob;
begin
-- dan - Update sau duyet
b_loi:='loi:Loi xu ly PBH_TAU_BT_DU:loi';
update bh_bt_tau set ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks,ngay_qd=b_ngay_qd,n_duyet=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
select txt into b_txt from bh_bt_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
PKH_JS_THAYa(b_txt,'n_duyet,ksoat,dvi_ksoat,ttrang',b_nsd_ks||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
PKH_JS_THAYn(b_txt,'ngay_qd',b_ngay_qd); b_txt:=b_txt;
update bh_bt_tau_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_XE_BT_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,
    b_ttrang varchar2,b_ngay_qd number,b_loi out varchar2)
AS
    b_i1 number; b_nv varchar2(10); b_so_id_kt number:=-1; b_txt clob;
begin
-- dan - Update sau duyet
b_loi:='loi:Loi xu ly PBH_XE_BT_DU:loi';
if b_ttrang='D' then b_so_id_kt:=0; end if;
update bh_bt_xe set ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks,ngay_qd=b_ngay_qd,n_duyet=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
if sql%rowcount=0 then
    update bh_bt_xeP set ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks,ngay_qd=b_ngay_qd,n_duyet=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if sql%rowcount=0 then
        b_loi:='loi:Ho so, phuong an boi thuong da xoa:loi'; return;
    end if;
end if;
select txt into b_txt from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
PKH_JS_THAYa(b_txt,'n_duyet,ksoat,dvi_ksoat,ttrang',b_nsd_ks||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
PKH_JS_THAYn(b_txt,'ngay_qd',b_ngay_qd); PKH_JS_THAYn(b_txt,'so_id_kt',b_so_id_kt);
--b_txt:='"'||b_txt||'"';
update bh_bt_xe_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HANG_BT_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,b_ttrang varchar2,b_ngay_qd number,b_loi out varchar2)
AS
    b_i1 number; b_nv varchar2(10); b_txt clob;
begin
-- Nam - Update sau duyet
b_loi:='loi:Loi xu ly PBH_HANG_BT_DU:loi';
update bh_bt_hang set ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks,ngay_qd=b_ngay_qd,n_duyet=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
select txt into b_txt from bh_bt_hang_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
b_txt:=FKH_JS_BONH(b_txt);
PKH_JS_THAYa(b_txt,'n_duyet,ksoat,dvi_ksoat,ttrang',b_nsd_ks||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
PKH_JS_THAYn(b_txt,'ngay_qd',b_ngay_qd); 
--b_txt:='"'||b_txt||'"';
update bh_bt_hang_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PTN_BT_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,b_ttrang varchar2,b_ngay_qd number,b_loi out varchar2)
AS
    b_i1 number; b_nv varchar2(10); b_txt clob;
begin
-- dan - Update sau duyet
b_loi:='loi:Loi xu ly PBH_PTN_BT_DU:loi';
update bh_bt_ptn set ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks,ngay_qd=b_ngay_qd,n_duyet=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
select txt into b_txt from bh_bt_ptn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
b_txt:=FKH_JS_BONH(b_txt);
PKH_JS_THAYa(b_txt,'n_duyet,ksoat,dvi_ksoat,ttrang',b_nsd_ks||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
PKH_JS_THAYn(b_txt,'ngay_qd',b_ngay_qd); 
--b_txt:='"'||b_txt||'"';
update bh_bt_ptn_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BT_DU_NV(
    b_nv varchar2,b_ma_dvi varchar2,b_so_id number,
    b_ma_dvi_ks varchar2,b_nsd_ks varchar2,b_ttrang varchar2,b_ngay_qd number,b_loi out varchar2)
AS
begin
-- Dan - Update NV sau duyet
if b_nv='PHH' then
    PBH_PHH_BT_DU(b_ma_dvi,b_so_id,b_ma_dvi_ks,b_nsd_ks,b_ttrang,b_ngay_qd,b_loi);
elsif b_nv='PKT' then
    PBH_PKT_BT_DU(b_ma_dvi,b_so_id,b_ma_dvi_ks,b_nsd_ks,b_ttrang,b_ngay_qd,b_loi);
elsif b_nv='XE' then
    PBH_XE_BT_DU(b_ma_dvi,b_so_id,b_ma_dvi_ks,b_nsd_ks,b_ttrang,b_ngay_qd,b_loi);
elsif b_nv='2B' then
    PBH_2B_BT_DU(b_ma_dvi,b_so_id,b_ma_dvi_ks,b_nsd_ks,b_ttrang,b_ngay_qd,b_loi);
elsif b_nv='TAU' then
    PBH_TAU_BT_DU(b_ma_dvi,b_so_id,b_ma_dvi_ks,b_nsd_ks,b_ttrang,b_ngay_qd,b_loi);
elsif b_nv='NG' then
    PBH_NG_BT_DU(b_ma_dvi,b_so_id,b_ma_dvi_ks,b_nsd_ks,b_ttrang,b_ngay_qd,b_loi);
elsif b_nv='HANG' then
    PBH_HANG_BT_DU(b_ma_dvi,b_so_id,b_ma_dvi_ks,b_nsd_ks,b_ttrang,b_ngay_qd,b_loi);
elsif b_nv='PTN' then
    PBH_PTN_BT_DU(b_ma_dvi,b_so_id,b_ma_dvi_ks,b_nsd_ks,b_ttrang,b_ngay_qd,b_loi);
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/

