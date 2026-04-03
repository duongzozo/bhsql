create or replace function FBH_NONG_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2,b_so_id_dt number:=0) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_id number; b_txt clob:=''; b_lenh varchar2(1000); b_ma nvarchar2(500);
    a_ds_ct pht_type.a_clob;
begin
-- Nam - Tra gia tri varchar2 trong txt
if b_so_id_dt in(0,b_so_id) then
    select count(*) into b_i1 from bh_nong_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    if b_i1=1 then
        select txt into b_txt from bh_nong_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    --else
    --    select nvl(max(lan),0) into b_i1 from bh_nongB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    --    if b_i1<>0 then
    --        select txt into b_txt from bh_nongB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_i1 and loai='dt_ct';
    --    end if;
    end if;
    if length(b_txt)<>0 then
      PKH_JS_BONH(b_txt); b_kq:=FKH_JS_GTRIs(b_txt,b_tim);
    end if;
else
    select count(*) into b_i1 from bh_nong_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ct';
    if b_i1=1 then
        select txt into b_txt from bh_nong_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ct';
    --else
    --   select nvl(max(lan),0) into b_i1 from bh_nongB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ct';
    --    if b_i1<>0 then
    --        select txt into b_txt from bh_nongB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_i1 and loai='ds_ct';
    --    end if;
    end if;
    if length(b_txt)<>0 then
        b_lenh:=FKH_JS_LENHc('');
        EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_ct using b_txt;
        for b_lp in 1..a_ds_ct.count loop
            b_txt:=a_ds_ct(b_lp); PKH_JS_BONH(b_txt); FKH_JS_NULL(b_txt);
            b_lenh:=FKH_JS_LENH('so_id_dt,'||b_tim);
            EXECUTE IMMEDIATE b_lenh into b_id,b_ma using b_txt;
            if b_id=b_so_id_dt then b_kq:=b_ma; exit; end if;
        end loop;
    end if;
end if;
return b_kq;
end;
/
create or replace function FBH_NONG_TXTn(b_ma_dvi varchar2,b_so_id number,b_tim varchar2,b_so_id_dt number:=0) return number
AS
    b_kq number:=0; b_i1 number; b_id number; b_txt clob; b_lenh varchar2(1000);
    a_ds_ct pht_type.a_clob;
begin
-- Nam - Tra gia tri num trong txt
if b_so_id_dt in(0,b_so_id) then
    select count(*) into b_i1 from bh_nong_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    if b_i1=1 then
        select txt into b_txt from bh_nong_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
        PKH_JS_BONH(b_txt); b_kq:=FKH_JS_GTRIn(b_txt,b_tim);
    end if;
else
    select count(*) into b_i1 from bh_nong_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ct';
    if b_i1=1 then
        select txt into b_txt from bh_nong_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ct';
        b_lenh:=FKH_JS_LENHc('');
        EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_ct using b_txt;
        for b_lp in 1..a_ds_ct.count loop
            b_txt:=a_ds_ct(b_lp); PKH_JS_BONH(b_txt); FKH_JS_NULL(b_txt);
            b_lenh:=FKH_JS_LENH('so_id_dt,'||b_tim);
            EXECUTE IMMEDIATE b_lenh into b_id,b_i1 using b_txt;
            if b_id=b_so_id_dt then b_kq:=b_i1; exit; end if;
        end loop;
    end if;
end if;
return b_kq;
end;
/
create or replace function FBH_NONG_DVI(
	b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngayN number:=0) return varchar2
AS
    b_kq varchar2(20); b_so_idB number; b_ngay number:=b_ngayN;
begin
-- Dan - Tra dvi
if b_ngay in (0,30000101) then b_ngay:=PKH_NG_CSO(sysdate); end if;
b_so_idB:=FBH_NONG_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select nvl(min(dvi),' ') into b_kq from
    bh_nong_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace procedure FBH_NONG_DT_NG(
  b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay_hl out number,b_ngay_kt out number,b_ngay number:=30000101)
AS
  b_so_idB number;
begin
-- Nam - Ngay hieu luc, ngay ket thuc doi tuong
b_so_idB:=FBH_NONG_HD_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select nvl(min(ngay_hl),0),nvl(min(ngay_kt),0) into b_ngay_hl,b_ngay_kt
  from bh_nong_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
if b_ngay_hl=0 then
  select nvl(min(ngay_hl),0),nvl(min(ngay_kt),0) into b_ngay_hl,b_ngay_kt from bh_nong where ma_dvi=b_ma_dvi and so_id=b_so_idB;
end if;
end;
/
create or replace function FBH_NONG_PVI_TEN(b_ma varchar2,b_nv varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Nam
if b_nv='CT' then
  select min(ten) into b_kq from bh_nongct_pvi where ma=b_ma;
elsif b_nv='TS' then
  select min(ten) into b_kq from bh_nongts_pvi where ma=b_ma;
else
  select min(ten) into b_kq from bh_nongvn_pvi where ma=b_ma;
end if;
return b_kq;
end;
/
create or replace procedure FBH_NONG_SO_ID_DTf(
    b_so_id_dt in out number,b_ma_dvi out varchar2,b_so_id out number,b_ngay number:=30000101)
as
    b_so_idD number; b_i1 number;
begin
-- Nam - Tra so id cuoi qua so_id_dt
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_nong_dvi where so_id_dt=b_so_id_dt;
if b_so_id=0 then
    select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_nong where so_id=b_so_id_dt;
    if b_so_id<>0 then
        b_so_idD:=FBH_NONG_SO_IDd(b_ma_dvi,b_so_id);
        select count(*) into b_i1 from bh_nong_dvi where so_id_dt=b_so_idD;
        if b_i1<>0 then b_so_id_dt:=b_so_idD; else b_so_id:=0; end if;
    end if;
end if;
if b_so_id<>0 then b_so_id:=FBH_NONG_SO_IDb(b_ma_dvi,b_so_id,b_ngay); end if;
end;
/
create or replace function FBH_NONG_SO_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Dan - Tra so hop dong
select min(so_hd) into b_kq from bh_nong where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_NONG_SO_HDd(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50); b_so_idD number;
begin
-- Dan - Tra so hop dong dau
b_so_idD:=FBH_NONG_SO_IDd(b_ma_dvi,b_so_id);
b_kq:=FBH_NONG_SO_HD(b_ma_dvi,b_so_idD);
return b_kq;
end;
/
create or replace function FBH_NONG_HD_SO_IDd(b_ma_dvi varchar2,b_so_hd varchar2) return number
as
    b_kq number;
begin
-- Nam - Tra so id dau
select nvl(min(so_id_d),0) into b_kq from bh_nong where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
return b_kq;
end;
/
create or replace function FBH_NONG_HD_SO_IDc(b_ma_dvi varchar2,b_so_hd varchar2,b_ttrang varchar2:='K') return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Nam - Tra so id cuoi
b_so_idD:=FBH_NONG_HD_SO_IDd(b_ma_dvi,b_so_hd);
if b_ttrang<>'C' then
    select nvl(max(so_id),0) into b_kq from bh_nong where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
else
    select nvl(max(so_id),0) into b_kq from bh_nong where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D';
end if;
return b_kq;
end;
/
create or replace function FBH_NONG_SO_IDb(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id bo sung den ngay
b_so_idD:=FBH_NONG_SO_IDd(b_ma_dvi,b_so_id);
select nvl(max(so_id),0) into b_kq from bh_nong where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D' and ngay_cap<=b_ngay;
return b_kq;
end;
/
create or replace function FBH_NONG_HD_SO_IDb(
    b_ma_dvi varchar2,b_so_hd varchar2,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Nam - Tra so id cuoi
b_so_idD:=FBH_NONG_HD_SO_IDd(b_ma_dvi,b_so_hd);
select nvl(max(so_id),0) into b_kq from bh_nong where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D' and ngay_ht<=b_ngay;
return b_kq;
end;
/
create or replace function FBH_NONG_TTRANG(b_ma_dvi varchar2,b_so_id number,b_dk varchar2:='K',b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(1); b_i1 number;
begin
-- Dan - Tra ngay cap
select nvl(min(ttrang),'X') into b_kq from bh_nong where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_kq<>'X' and b_dk='C' then
    select count(*) into b_i1 from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay;
    if b_i1<>0 then b_kq:='H'; end if;
end if;
return b_kq;
end;
/
create or replace function FBH_NONG_NV(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan - Tra nghiep vu
select min(nv) into b_kq from bh_nong where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_NONG_KIEU_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Dan - Tra so hop dong
select nvl(min(kieu_hd),' ') into b_kq from bh_nong where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_NONG_HL(b_ma_dvi varchar2,b_so_id number,b_ngay number,b_ngayd number,b_ngayc number) return varchar2
AS
    b_so_idB number; b_ngay_hl number; b_ngay_kt number; b_kq varchar2(1):='K';
begin
-- Dan - Kiem tra hieu luc
b_so_idB:=FBH_NONG_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from bh_nong where ma_dvi=b_ma_dvi and so_id=b_so_idB;
if b_ngayd<=b_ngay_kt and b_ngay_hl<=b_ngayc then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_NONG_HLd(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay number) return varchar2
AS
    b_so_idB number; b_ngay_hl number; b_ngay_kt number; b_kq varchar2(1):='K';
begin
-- Dan - Kiem tra hieu luc
b_so_idB:=FBH_NONG_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from bh_nong_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
if b_ngay between b_ngay_hl and b_ngay_kt then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_NONG_SO_ID(b_ma_dvi varchar2,b_so_hd varchar2) return number
as
    b_kq number;
begin
-- Dan - Tra so hop dong
select nvl(min(so_id),0) into b_kq from bh_nong where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
return b_kq;
end;
/
create or replace function FBH_NONG_SO_IDd(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Dan - Tra so id dau
select nvl(min(so_id_d),0) into b_kq from bh_nong where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure FBH_NONG_SO_ID_DT(
    b_so_id_dt number,b_ma_dvi out varchar2,b_so_id out number,b_ngay number:=30000101)
as
begin
-- Dan - Tra so id cuoi qua so_id_dt
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_nong_dvi where so_id_dt=b_so_id_dt;
if b_so_id<>0 then b_so_id:=FBH_NONG_SO_IDb(b_ma_dvi,b_so_id,b_ngay); end if;
end;
/
create or replace procedure FBH_NONG_SO_ID_DTd(
    b_so_id_dt number,b_ma_dvi out varchar2,b_so_id out number)
as
begin
-- Dan - Tra so id dau qua so_id_dt
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_nong_dvi where so_id_dt=b_so_id_dt;
if b_so_id<>0 then b_so_id:=FBH_NONG_SO_IDd(b_ma_dvi,b_so_id); end if;
end;
/
create or replace procedure FBH_NONG_HD_SO_ID_DT(
    b_gcn varchar2,b_ngay number,b_ma_dvi out varchar2,b_so_id out number,b_so_id_dt out number)
as
begin
-- Dan - Tra so id qua GCN
select nvl(min(so_id_dt),0) into b_so_id_dt from bh_nong_dvi where gcn=b_gcn;
if b_so_id_dt<>0 then
	FBH_NONG_SO_ID_DT(b_so_id_dt,b_ma_dvi,b_so_id,b_ngay);
else
	b_so_id:=0; b_ma_dvi:='';
end if;
end;
/
create or replace procedure FBH_NONG_HD_SO_ID_GOI(
    b_so_hd varchar2,b_nhom varchar2,b_ngay number,b_ma_dvi out varchar2,b_so_id out number,b_so_id_nh out number)
as
    b_so_idB number; b_nv varchar2(10);
begin
-- Dan - Tra so id qua GCN
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_nong where so_hd=b_so_hd;
if b_so_id<>0 then
    b_so_idB:=FBH_NONG_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
	b_nv:=FBH_NONG_NV(b_ma_dvi,b_so_idB);
	if b_nv='SKU' then
		b_so_id_nh:=FBH_SK_SO_ID_NHOM(b_ma_dvi,b_so_id,b_nhom);
	else
		b_so_id_nh:=FBH_DL_SO_ID_NHOM(b_ma_dvi,b_so_id,b_nhom);
	end if;
else
    b_so_id_nh:=0;
end if;
end;
/
create or replace function FBH_NONG_HD_GOIl(
    b_ma_dvi varchar2,b_so_id number,b_nhom varchar2) return nvarchar2
as
    b_kq nvarchar2(500); b_so_idB number; b_nv varchar2(10);
begin
-- Dan - Tra so id qua GCN
b_so_idB:=FBH_NONG_SO_IDb(b_ma_dvi,b_so_id);
b_nv:=FBH_NONG_NV(b_ma_dvi,b_so_idB);
if b_nv='SKU' then
    select min(nhom||'|'||ten) into b_kq from bh_sk_nh where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom;
else
    select min(nhom||'|'||ten) into b_kq from bh_ngdl_nh where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom;
end if;
return b_kq;
end;
/
create or replace procedure FBH_NONG_HD_SO_ID_DTd(
    b_gcn varchar2,b_ma_dvi out varchar2,b_so_id out number,b_so_id_dt out number)
as
begin
-- Dan - Tra so id dau qua GCN
select min(ma_dvi),nvl(min(so_id),0),nvl(min(so_id_dt),0) into b_ma_dvi,b_so_id,b_so_id_dt from bh_nong_dvi where gcn=b_gcn;
if b_so_id<>0 then b_so_id:=FBH_NONG_SO_IDd(b_ma_dvi,b_so_id); end if;
end;
/
create or replace procedure FBH_NONG_SO_ID_GCN(
    b_gcn varchar2,b_ma_dvi out varchar2,b_so_id out number,b_so_id_dt out number,b_ngay number:=30000101)
as
begin
-- Dan - Tra so id cuoi qua so_id_dt
select count(*) into b_so_id from bh_nong_dvi where gcn=b_gcn;
if b_so_id<>1 then
    b_ma_dvi:=''; b_so_id:=0; b_so_id_dt:=0;
else
    select ma_dvi,so_id,so_id_dt into b_ma_dvi,b_so_id,b_so_id_dt from bh_nong_dvi where gcn=b_gcn;
    b_so_id:=FBH_NONG_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
end if;
end;
/
create or replace procedure FBH_NONG_SO_ID_GCNd(
    b_gcn varchar2,b_ma_dvi out varchar2,b_so_id out number,b_so_id_dt out number,b_ngay number:=30000101)
as
begin
-- Dan - Tra so id dau qua so_id_dt
select count(*) into b_so_id from bh_nong_dvi where gcn=b_gcn;
if b_so_id<>1 then
    b_ma_dvi:=''; b_so_id:=0; b_so_id_dt:=0;
else
    select ma_dvi,so_id,so_id_dt into b_ma_dvi,b_so_id,b_so_id_dt from bh_nong_dvi where gcn=b_gcn;
    b_so_id:=FBH_NONG_SO_IDd(b_ma_dvi,b_so_id);
end if;
end;
/
create or replace function FBH_NONG_SO_IDc(b_ma_dvi varchar2,b_so_id number,b_ttrang varchar2:='K') return number
as
    b_kq number:=0; b_so_idD number:=b_so_id;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_NONG_SO_IDd(b_ma_dvi,b_so_id);
if b_ttrang<>'C' then
    select nvl(max(so_id),0) into b_kq from bh_nong where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
else
    select nvl(max(so_id),0) into b_kq from bh_nong where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D';
end if;
return b_kq;
end;
/
create or replace procedure PBH_NONG_GOC_XOA(b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh varchar2,b_loi out varchar2)
AS
begin
-- Nam - Xoa goc
PBH_HD_GOC_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi,b_nh);
if b_loi is not null then return; end if;
b_loi:='loi:Loi xoa Table bh_nong:loi';
delete bh_nong_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_nong_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_nong_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_nong_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_nong where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_NONG_NV(b_ma_dvi varchar2,b_so_id number,
    a_ma_dt out pht_type.a_var,a_nt_tien out pht_type.a_var,a_nt_phi out pht_type.a_var,
    a_lh_nv out pht_type.a_var,a_t_suat out pht_type.a_num,a_pt out pht_type.a_num,a_ptG out pht_type.a_num,
    a_tien out pht_type.a_num,a_phi out pht_type.a_num,a_thue out pht_type.a_num,a_ttoan out pht_type.a_num,
    a_so_id_dt out pht_type.a_num,a_dt_ma_dt out pht_type.a_var,a_dt_nt_tien out pht_type.a_var,a_dt_nt_phi out pht_type.a_var,
    a_dt_lh_nv out pht_type.a_var,a_dt_t_suat out pht_type.a_num,a_dt_pt out pht_type.a_num,a_dt_ptG out pht_type.a_num,
    a_dt_tien out pht_type.a_num,a_dt_phi out pht_type.a_num,a_dt_thue out pht_type.a_num,a_dt_ttoan out pht_type.a_num,
    tt_ngay out pht_type.a_num,tt_ma_nt out pht_type.a_var,tt_tien out pht_type.a_num,b_loi out varchar2)
AS
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_nv varchar2(10);
begin
-- Nam - Lay so lieu goc
b_loi:='loi:Loi lay so lieu goc:loi';
select nt_tien,nt_phi,nv into b_nt_tien,b_nt_phi,b_nv from bh_nong where ma_dvi=b_ma_dvi and so_id=b_so_id;
select a.loai,b_nt_tien,b_nt_phi,b.lh_nv,b.t_suat,sum(b.tien),sum(b.phi),sum(b.thue),sum(b.ttoan),min(b.pt),max(b.ptG)
    bulk collect into a_ma_dt,a_nt_tien,a_nt_phi,a_lh_nv,a_t_suat,a_tien,a_phi,a_thue,a_ttoan,a_pt,a_ptG
    from bh_nong_dvi a,bh_nong_dk b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and
    b.ma_dvi=b_ma_dvi and b.so_id=b_so_id and b.so_id_dt=a.so_id_dt and lh_nv<>' '
    group by a.loai,b.lh_nv,b.t_suat having sum(b.tien)<>0 or sum(b.ttoan)<>0;
    select a.so_id_dt,a.loai,b_nt_tien,b_nt_phi,b.lh_nv,b.t_suat,sum(b.tien),sum(b.phi),sum(b.thue),sum(b.ttoan),min(b.pt),max(b.ptG)
        bulk collect into a_so_id_dt,a_dt_ma_dt,a_dt_nt_tien,a_dt_nt_phi,a_dt_lh_nv,a_dt_t_suat,
        a_dt_tien,a_dt_phi,a_dt_thue,a_dt_ttoan,a_dt_pt,a_dt_ptG
        from bh_nong_dvi a,bh_nong_dk b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and
        b.ma_dvi=b_ma_dvi and b.so_id=b_so_id and b.so_id_dt=a.so_id_dt and lh_nv<>' '
        group by a.so_id_dt,a.loai,b.lh_nv,b.t_suat having sum(b.tien)<>0 or sum(b.ttoan)<>0;
select ngay,b_nt_phi,tien bulk collect into tt_ngay,tt_ma_nt,tt_tien from bh_nong_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_NONG_BPHI_DKBS (
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,'ma_dk' value ma,lh_nv) order by ma returning clob) into cs_lke
    from bh_ma_dkbs where FBH_MA_NV_CO(nv,'NONG')='C' order by ma;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
