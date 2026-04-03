create or replace procedure PBH_2B_BG_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,
    b_ttrang varchar2,b_so_hd out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_lan number; b_txt clob;
begin
-- dan - Update sau duyet
b_loi:='loi:Loi xu ly PBH_2B_BG_DU:loi';
select so_hd,max(lan) into b_so_hd,b_lan from bh_2bB where ma_dvi=b_ma_dvi and so_id=b_so_id group by so_hd;
b_i1:=instr(b_so_hd,'.');
if b_i1=2 then b_so_hd:=substr(b_so_hd,3); end if;
if b_ttrang='D' then b_so_hd:='B.'||b_so_hd; else b_so_hd:=b_ttrang||'.'||b_so_hd; end if;
select txt into b_txt from bh_2bB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ct';
PKH_JS_THAYa(b_txt,'so_hd,ksoat,dvi_ksoat,ttrang',b_so_hd||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
update bh_2bB_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ct';
update bh_2bB set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_NG_BG_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,
    b_ttrang varchar2,b_so_hd out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_nv varchar2(10); b_lan number; b_txt clob;
begin
-- dan - Update sau duyet
b_loi:='loi:Loi xu ly PBH_NG_DU:loi';
select so_hd,nv,max(lan) into b_so_hd,b_nv,b_lan from bh_ngB where ma_dvi=b_ma_dvi and so_id=b_so_id group by so_hd,nv;
b_i1:=instr(b_so_hd,'.');
if b_i1=2 then b_so_hd:=substr(b_so_hd,3); end if;
if b_ttrang='D' then b_so_hd:='B.'||b_so_hd; else b_so_hd:=b_ttrang||'.'||b_so_hd; end if;
select txt into b_txt from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ct';
PKH_JS_THAYa(b_txt,'so_hd,ksoat,dvi_ksoat,ttrang',b_so_hd||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
update bh_ngB_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ct';
update bh_ngB set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PHH_BG_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,
  b_ttrang varchar2,b_so_hd out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_txt clob; b_lan number;
begin
-- dan - Update sau duyet
b_loi:='loi:Loi xu ly PBH_PHH_BG_DU:loi';
select so_hd,max(lan) into b_so_hd,b_lan from bh_phhB where ma_dvi=b_ma_dvi and so_id=b_so_id group by so_hd;
b_i1:=instr(b_so_hd,'.');
if b_i1=2 then b_so_hd:=substr(b_so_hd,3); end if;
if b_ttrang='D' then b_so_hd:='B.'||b_so_hd; else b_so_hd:=b_ttrang||'.'||b_so_hd; end if;
select txt into b_txt from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct' and lan=b_lan;
PKH_JS_THAYa(b_txt,'so_hd,ksoat,dvi_ksoat,ttrang',b_so_hd||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
update bh_phhB_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ct';
update bh_phhB set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PKT_BG_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,
	b_ttrang varchar2,b_so_hd out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_lan number; b_txt clob;
begin
-- dan - Update sau duyet
b_loi:='loi:Loi xu ly PBH_PKT_DU:loi';
select so_hd,max(lan) into b_so_hd,b_lan from bh_pktB where ma_dvi=b_ma_dvi and so_id=b_so_id group by so_hd;
b_i1:=instr(b_so_hd,'.');
if b_i1=2 then b_so_hd:=substr(b_so_hd,3); end if;
if b_ttrang='D' then b_so_hd:='B.'||b_so_hd; else b_so_hd:=b_ttrang||'.'||b_so_hd; end if;
select txt into b_txt from bh_pktB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ct';
PKH_JS_THAYa(b_txt,'so_hd,ksoat,dvi_ksoat,ttrang',b_so_hd||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
update bh_pktB_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ct';
update bh_pktB set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_TAU_BG_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,
	b_ttrang varchar2,b_so_hd out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_lan number; b_txt clob;
begin
-- dan - Update sau duyet
b_loi:='loi:Loi xu ly PBH_TAU_DU:loi';
select so_hd,max(lan) into b_so_hd,b_lan from bh_tauB where ma_dvi=b_ma_dvi and so_id=b_so_id group by so_hd;
b_i1:=instr(b_so_hd,'.');
if b_i1=2 then b_so_hd:=substr(b_so_hd,3); end if;
if b_ttrang='D' then b_so_hd:='B.'||b_so_hd; else b_so_hd:=b_ttrang||'.'||b_so_hd; end if;
select txt into b_txt from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ct';
PKH_JS_THAYa(b_txt,'so_hd,ksoat,dvi_ksoat,ttrang',b_so_hd||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
update bh_tauB_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ct';
update bh_tauB set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_XE_BG_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,
    b_ttrang varchar2,b_so_hd out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_lan number; b_txt clob;
begin
-- dan - Update sau duyet
b_loi:='loi:Loi xu ly PBH_XE_BG_DU:loi';
select so_hd,max(lan) into b_so_hd,b_lan from bh_xeB where ma_dvi=b_ma_dvi and so_id=b_so_id group by so_hd;
b_i1:=instr(b_so_hd,'.');
if b_i1=2 then b_so_hd:=substr(b_so_hd,3); end if;
if b_ttrang='D' then b_so_hd:='B.'||b_so_hd; else b_so_hd:=b_ttrang||'.'||b_so_hd; end if;
select txt into b_txt from bh_xeB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ct';
PKH_JS_THAYa(b_txt,'so_hd,ksoat,dvi_ksoat,ttrang',b_so_hd||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
update bh_xeB_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ct';
update bh_xeB set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HANG_BG_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,
    b_ttrang varchar2,b_so_hd out varchar2,b_loi out varchar2)
AS
     b_i1 number; b_txt clob; b_lan number;
begin
-- dan - Update sau duyet
b_loi:='loi:Loi xu ly PBH_HANG_DU:loi';
select so_hd,max(lan) into b_so_hd,b_lan from bh_hangB where ma_dvi=b_ma_dvi and so_id=b_so_id group by so_hd;
b_i1:=instr(b_so_hd,'.');
if b_i1=2 then b_so_hd:=substr(b_so_hd,3); end if;
if b_ttrang='D' then b_so_hd:='B.'||b_so_hd; else b_so_hd:=b_ttrang||'.'||b_so_hd; end if;
select txt into b_txt from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct' and lan=b_lan;
PKH_JS_THAYa(b_txt,'so_hd,ksoat,dvi_ksoat,ttrang',b_so_hd||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
update bh_hangB_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
update bh_hangB set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PTN_BG_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,
    b_ttrang varchar2,b_so_hd out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_nv varchar2(10); b_lan number; b_txt clob;
begin
-- Nam - Update sau duyet
b_loi:='loi:Loi xu ly PBH_PTN_BG_DU:loi';
select so_hd,nv,max(lan) into b_so_hd,b_nv,b_lan from bh_ptnB where ma_dvi=b_ma_dvi and so_id=b_so_id group by so_hd,nv;
b_i1:=instr(b_so_hd,'.');
if b_i1=2 then b_so_hd:=substr(b_so_hd,3); end if;
if b_ttrang='D' then b_so_hd:='B.'||b_so_hd; else b_so_hd:=b_ttrang||'.'||b_so_hd; end if;
select txt into b_txt from bh_ptnB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ct';
PKH_JS_THAYa(b_txt,'so_hd,ksoat,dvi_ksoat,ttrang',b_so_hd||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
update bh_ptnB_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ct';
update bh_ptnB set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
-- NAM: tham so dau vao sap xep sai
create or replace procedure PBH_BG_DU_NV(
    b_nv varchar2,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,b_ma_dvi varchar2,b_so_id number,
	  b_ttrang varchar2,b_so_hd out varchar2,b_loi out varchar2)
AS
begin
-- Dan - Update NV sau duyet
if b_nv='PHH' then
    PBH_PHH_BG_DU(b_ma_dvi,b_so_id,b_ma_dvi_ks,b_nsd_ks,b_ttrang,b_so_hd,b_loi);
elsif b_nv='PKT' then
    PBH_PKT_BG_DU(b_ma_dvi,b_so_id,b_ma_dvi_ks,b_nsd_ks,b_ttrang,b_so_hd,b_loi);
elsif b_nv='XE' then
    PBH_XE_BG_DU(b_ma_dvi,b_so_id,b_ma_dvi_ks,b_nsd_ks,b_ttrang,b_so_hd,b_loi);
elsif b_nv='2B' then
    PBH_2B_BG_DU(b_ma_dvi,b_so_id,b_ma_dvi_ks,b_nsd_ks,b_ttrang,b_so_hd,b_loi);
elsif b_nv='TAU' then
    PBH_TAU_BG_DU(b_ma_dvi,b_so_id,b_ma_dvi_ks,b_nsd_ks,b_ttrang,b_so_hd,b_loi);
elsif b_nv='NG' then
    PBH_NG_BG_DU(b_ma_dvi,b_so_id,b_ma_dvi_ks,b_nsd_ks,b_ttrang,b_so_hd,b_loi);
elsif b_nv='HANG' then
    PBH_HANG_BG_DU(b_ma_dvi,b_so_id,b_ma_dvi_ks,b_nsd_ks,b_ttrang,b_so_hd,b_loi);
elsif b_nv='PTN' then
    PBH_PTN_BG_DU(b_ma_dvi,b_so_id,b_ma_dvi_ks,b_nsd_ks,b_ttrang,b_so_hd,b_loi);
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BG_DUx_NV(
    b_nv varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
	b_i1 number;
begin
-- Dan - Update NV sau duyet
if b_nv='PHH' then
	select count(*) into b_i1 from bh_phh where ma_dvi=b_ma_dvi and so_id=b_so_id;
elsif b_nv='PKT' then
	select count(*) into b_i1 from bh_pkt where ma_dvi=b_ma_dvi and so_id=b_so_id;
elsif b_nv='XE' then
	select count(*) into b_i1 from bh_xe where ma_dvi=b_ma_dvi and so_id=b_so_id;
elsif b_nv='2B' then
	select count(*) into b_i1 from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_id;
elsif b_nv='TAU' then
	select count(*) into b_i1 from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_id;
elsif b_nv='NG' then
	select count(*) into b_i1 from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
elsif b_nv='HANG' then
	select count(*) into b_i1 from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_id;
elsif b_nv='PTN' then
	select count(*) into b_i1 from bh_pkt where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
if b_i1<>0 then b_loi:='loi:Khong thay doi bao gia da chuyen hop dong/GCN:loi'; else b_loi:=''; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
