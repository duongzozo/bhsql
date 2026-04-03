create or replace function FBH_NG_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_id number; b_txt clob:='';
    a_ds_ct pht_type.a_clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
select count(*) into b_i1 from bh_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
else
    select nvl(max(lan),0) into b_i1 from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    if b_i1<>0 then
        select txt into b_txt from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_i1 and loai='dt_ct';
    end if;
end if;
if length(b_txt)<>0 then
	PKH_JS_BONH(b_txt); b_kq:=FKH_JS_GTRIs(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_NG_TXTn(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return number
AS
    b_kq number:=0; b_i1 number; b_id number; b_txt clob:='';
    a_ds_ct pht_type.a_clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
select count(*) into b_i1 from bh_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
else
    select nvl(max(lan),0) into b_i1 from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    if b_i1<>0 then
        select txt into b_txt from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_i1 and loai='dt_ct';
    end if;
end if;
if length(b_txt)<>0 then
	PKH_JS_BONH(b_txt); b_kq:=FKH_JS_GTRIn(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_NG_SDT(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_kq number;
begin
-- Dan - Tra so nguoi
select count(*) into b_kq from bh_ng_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_kq=0 then
    select count(*) into b_kq from bh_sk_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_kq=0 then
        select count(*) into b_kq from bh_ngdl_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
        if b_kq=0 then
            select count(*) into b_kq from bh_ngtd_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
        end if;
    end if;
end if;
return b_kq;
end;
/
create or replace function FBH_NG_TEN(
	b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay number:=30000101) return varchar2
AS
    b_kq varchar2(20); b_so_idB number;
begin
-- Dan - Tra ten
b_so_idB:=FBH_NG_SO_IDt(b_ma_dvi,b_so_id,b_ngay);
select nvl(min(ten),' ') into b_kq from bh_ng_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace function FBH_NG_MA_DT(
	b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay number:=30000101) return varchar2
AS
    b_kq varchar2(20); b_so_idB number;
begin
-- Dan - Tra nghe
b_so_idB:=FBH_NG_SO_IDt(b_ma_dvi,b_so_id,b_ngay);
select nvl(min(nghe),' ') into b_kq from
    bh_ng_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace function FBH_NG_SO_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Dan - Tra so hop dong
select min(so_hd) into b_kq from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_NG_SO_HDd(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50); b_so_idD number;
begin
-- Dan - Tra so hop dong dau
b_so_idD:=FBH_NG_SO_IDd(b_ma_dvi,b_so_id);
b_kq:=FBH_NG_SO_HD(b_ma_dvi,b_so_idD);
return b_kq;
end;
/
create or replace function FBH_NG_TTRANG(b_ma_dvi varchar2,b_so_id number,b_dk varchar2:='K',b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(1); b_i1 number;
begin
-- Dan - Tra ngay cap
select nvl(min(ttrang),'X') into b_kq from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_kq<>'X' and b_dk='C' then
    select count(*) into b_i1 from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay;
    if b_i1<>0 then b_kq:='H'; end if;
end if;
return b_kq;
end;
/
create or replace function FBH_NG_NV(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan - Tra nghiep vu
select min(nv) into b_kq from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_NG_KIEU_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Dan - Tra so hop dong
select nvl(min(kieu_hd),' ') into b_kq from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_NG_HL(b_ma_dvi varchar2,b_so_id number,b_ngay number,b_ngayd number,b_ngayc number) return varchar2
AS
    b_so_idB number; b_ngay_hl number; b_ngay_kt number; b_kq varchar2(1):='K';
begin
-- Dan - Kiem tra hieu luc
b_so_idB:=FBH_NG_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_idB;
if b_ngayd<=b_ngay_kt and b_ngay_hl<=b_ngayc then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_NG_HLd(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay number) return varchar2
AS
    b_so_idB number; b_ngay_hl number; b_ngay_kt number; b_kq varchar2(1):='K';
begin
-- Dan - Kiem tra hieu luc
b_so_idB:=FBH_NG_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from bh_ng_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
if b_ngay between b_ngay_hl and b_ngay_kt then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_NG_SO_ID(b_ma_dvi varchar2,b_so_hd varchar2) return number
as
    b_kq number;
begin
-- Dan - Tra so hop dong
select nvl(min(so_id),0) into b_kq from bh_ng where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
return b_kq;
end;
/
create or replace function FBH_NG_SO_IDd(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Dan - Tra so id dau
select nvl(min(so_id_d),0) into b_kq from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_NG_SO_IDt(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id bo sung den ngay
b_so_idD:=FBH_NG_SO_IDd(b_ma_dvi,b_so_id);
select nvl(max(so_id),0) into b_kq from bh_ng where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang in('T','D') and ngay_ht<=b_ngay;
return b_kq;
end;
/
create or replace function FBH_NG_SO_IDb(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id bo sung den ngay
b_so_idD:=FBH_NG_SO_IDd(b_ma_dvi,b_so_id);
select nvl(max(so_id),0) into b_kq from bh_ng where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D' and ngay_cap<=b_ngay;
return b_kq;
end;
/
create or replace procedure FBH_NG_SO_ID_DT(
    b_so_id_dt number,b_ma_dvi out varchar2,b_so_id out number,b_ngay number:=30000101)
as
begin
-- Dan - Tra so id cuoi qua so_id_dt
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_ng_ds where so_id_dt=b_so_id_dt;
if b_so_id<>0 then b_so_id:=FBH_NG_SO_IDb(b_ma_dvi,b_so_id,b_ngay); end if;
end;
/
create or replace procedure FBH_NG_SO_ID_DTd(
    b_so_id_dt number,b_ma_dvi out varchar2,b_so_id out number)
as
begin
-- Dan - Tra so id dau qua so_id_dt
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_ng_ds where so_id_dt=b_so_id_dt;
if b_so_id<>0 then b_so_id:=FBH_NG_SO_IDd(b_ma_dvi,b_so_id); end if;
end;
/
create or replace procedure FBH_NG_HD_SO_ID_DT(
    b_gcn varchar2,b_ngay number,b_ma_dvi out varchar2,b_so_id out number,b_so_id_dt out number)
as
begin
-- Dan - Tra so id qua GCN
select nvl(min(so_id_dt),0) into b_so_id_dt from bh_ng_ds where gcn=b_gcn;
if b_so_id_dt<>0 then
  FBH_NG_SO_ID_DT(b_so_id_dt,b_ma_dvi,b_so_id,b_ngay);
  -- chuclh_ rao xu ly giong phh
  --select nvl(min(so_id_dt),0) into b_so_id_dt from bh_ng_ds where so_id=b_so_id;
else
  b_so_id:=0; b_ma_dvi:='';
end if;
end;
/
create or replace procedure FBH_NG_HD_SO_ID_GOI(
    b_so_hd varchar2,b_nhom varchar2,b_ngay number,b_ma_dvi out varchar2,b_so_id out number,b_so_id_nh out number)
as
    b_so_idB number; b_nv varchar2(10);
begin
-- Dan - Tra so id qua GCN
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_ng where so_hd=b_so_hd;
if b_so_id<>0 then
    b_so_idB:=FBH_NG_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
	b_nv:=FBH_NG_NV(b_ma_dvi,b_so_idB);
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
create or replace function FBH_NG_HD_GOIl(
    b_ma_dvi varchar2,b_so_id number,b_nhom varchar2) return nvarchar2
as
    b_kq nvarchar2(500); b_so_idB number; b_nv varchar2(10);
begin
-- Dan - Tra so id qua GCN
b_so_idB:=FBH_NG_SO_IDb(b_ma_dvi,b_so_id);
b_nv:=FBH_NG_NV(b_ma_dvi,b_so_idB);
if b_nv='SKU' then
    select min(nhom||'|'||ten) into b_kq from bh_sk_nh where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom;
else
    select min(nhom||'|'||ten) into b_kq from bh_ngdl_nh where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom;
end if;
return b_kq;
end;
/
create or replace function FBH_SKN_MA_SDBS(b_so_id number) return nvarchar2
as
    b_kq nvarchar2(200);
begin
-- Dan - Tra so id dau
select FKH_JS_GTRIs(FKH_JS_BONH(txt),'ma_sdbs') into b_kq from bh_skN_txt where  so_id=b_so_id and loai='dt_ct';
return b_kq;
end;
/
create or replace function Fbh_NGDLN_MA_SDBS(b_so_id number) return nvarchar2
as
    b_kq nvarchar2(200);
begin
-- Dan - Tra so id dau
select FKH_JS_GTRIs(FKH_JS_BONH(txt),'ma_sdbs') into b_kq from bh_ngdlN_txt where  so_id=b_so_id and loai='dt_ct';
return b_kq;
end;
/
create or replace procedure FBH_NG_HD_SO_ID_DTd(
    b_gcn varchar2,b_ma_dvi out varchar2,b_so_id out number,b_so_id_dt out number)
as
begin
-- Dan - Tra so id dau qua GCN
select min(ma_dvi),nvl(min(so_id),0),nvl(min(so_id_dt),0) into b_ma_dvi,b_so_id,b_so_id_dt from bh_ng_ds where gcn=b_gcn;
if b_so_id<>0 then b_so_id:=FBH_NG_SO_IDd(b_ma_dvi,b_so_id); end if;
end;
/
create or replace procedure FBH_NG_HD_SO_ID_DTc(
    b_gcn varchar2,b_ma_dvi out varchar2,b_so_id out number,b_so_id_dt out number)
as
begin
-- Nam - Tra so id cuoi qua GCN
select max(ma_dvi),nvl(max(so_id),0),nvl(max(so_id_dt),0) into b_ma_dvi,b_so_id,b_so_id_dt from bh_ng_ds where gcn=b_gcn;
if b_so_id<>0 then b_so_id:=FBH_NG_SO_IDb(b_ma_dvi,b_so_id); end if;
end;
/
create or replace procedure FBH_NG_SO_ID_GCN(
    b_gcn varchar2,b_ma_dvi out varchar2,b_so_id out number,b_so_id_dt out number,b_ngay number:=30000101)
as
begin
-- Dan - Tra so id cuoi qua so_id_dt
select count(*) into b_so_id from bh_ng_ds where gcn=b_gcn;
if b_so_id<>1 then
    b_ma_dvi:=''; b_so_id:=0; b_so_id_dt:=0;
else
    select ma_dvi,so_id,so_id_dt into b_ma_dvi,b_so_id,b_so_id_dt from bh_ng_ds where gcn=b_gcn;
    b_so_id:=FBH_NG_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
end if;
end;
/
create or replace procedure FBH_NG_SO_ID_GCNd(
    b_gcn varchar2,b_ma_dvi out varchar2,b_so_id out number,b_so_id_dt out number,b_ngay number:=30000101)
as
begin
-- Dan - Tra so id dau qua so_id_dt
select count(*) into b_so_id from bh_ng_ds where gcn=b_gcn;
if b_so_id<>1 then
    b_ma_dvi:=''; b_so_id:=0; b_so_id_dt:=0;
else
    select ma_dvi,so_id,so_id_dt into b_ma_dvi,b_so_id,b_so_id_dt from bh_ng_ds where gcn=b_gcn;
    b_so_id:=FBH_NG_SO_IDd(b_ma_dvi,b_so_id);
end if;
end;
/
create or replace function FBH_NG_SO_IDc(b_ma_dvi varchar2,b_so_id number,b_ttrang varchar2:='K') return number
as
    b_kq number:=0; b_so_idD number:=b_so_id;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_NG_SO_IDd(b_ma_dvi,b_so_id);
if b_ttrang<>'C' then
    select nvl(max(so_id),0) into b_kq from bh_ng where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
else
    select nvl(max(so_id),0) into b_kq from bh_ng where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D';
end if;
return b_kq;
end;
/
create or replace procedure PBH_NG_GHEP_DVI
    (b_ma_dvi varchar2,b_so_id number,b_tdx number,b_tdy number,b_bk number,b_ngay number,b_ngay_hl number,b_ngay_kt number,
    a_ma_dvi_kq out pht_type.a_var,a_so_id_kq out pht_type.a_num,a_so_id_dt out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_so_idD number;
    b_so_id_kh number; b_bt number:=1; b_kt number:=0; b_bd number;
    a_ma_dvi pht_type.a_var; a_so_id pht_type.a_num; a_so_id_bs pht_type.a_num;
    a_dvi pht_type.a_var; a_ngay_hl pht_type.a_date; a_ngay_kt pht_type.a_date;
    a_tdx pht_type.a_num; a_tdy pht_type.a_num; a_bk pht_type.a_num;
begin
-- Dan - Tim doi tuong ghep
b_loi:='loi:Loi tim doi tuong ghep:loi';
b_so_idD:=FBH_NG_SO_IDd(b_ma_dvi,b_so_id);
a_ma_dvi(b_bt):=''; a_so_id(1):=0; a_so_id_bs(1):=0;
a_dvi(1):=''; a_tdx(1):=b_tdx; a_tdy(1):=b_tdy; a_bk(1):=b_bk;
loop
    b_bd:=b_kt+1; b_kt:=b_bt;
    for b_lp in b_bd..b_kt loop
        for r_lp in (select ma_dvi,so_id,dvi,tdx,tdy,bk,ngay_hl,ngay_kt from bh_ng_ttu
            where b_ngay_kt>=ngay_hl and ngay_kt>=b_ngay_hl and
			FBH_KH_AHUONG(a_tdx(b_lp),a_tdy(b_lp),a_bk(b_lp),tdx,tdy,bk)='C') loop
            if FBH_NG_HL(r_lp.ma_dvi,r_lp.so_id,b_ngay,b_ngay_hl,b_ngay_kt)='C' then
                b_so_id_kh:=FBH_NG_SO_IDd(r_lp.ma_dvi,r_lp.so_id);
                if (b_so_idD<>b_so_id_kh) then
                    b_i1:=0;
                    for b_lp1 in 1..b_bt loop
                        if a_so_id(b_lp1)=b_so_id_kh then b_i1:=1; exit; end if;
                    end loop;
                    if b_i1=0 then
                        b_bt:=b_bt+1;
                        a_ma_dvi(b_bt):=r_lp.ma_dvi; a_so_id(b_bt):=b_so_id_kh;
                        a_so_id_bs(b_bt):=FBH_NG_SO_IDb(r_lp.ma_dvi,r_lp.so_id,b_ngay);
                        a_dvi(b_bt):=r_lp.dvi; a_tdx(b_bt):=r_lp.tdx; a_tdy(b_bt):=r_lp.tdy; a_bk(b_bt):=r_lp.bk;
                    end if;
                end if;
            end if;
        end loop;
    end loop;
    exit when b_kt=b_bt;
end loop;
b_i1:=0; PKH_MANG_KD(a_ma_dvi_kq);
for b_lp in 2..b_bt loop
    for r_lp in (select so_id_dt from bh_ng_ds where ma_dvi=a_ma_dvi(b_lp) and so_id=a_so_id_bs(b_lp) and dvi=a_dvi(b_lp)) loop
        b_i1:=b_i1+1;
        a_ma_dvi_kq(b_i1):=a_ma_dvi(b_lp); a_so_id_kq(b_i1):=a_so_id_bs(b_lp); a_so_id_dt(b_i1):=r_lp.so_id_dt;
    end loop;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_NG_GHEP_DT
    (b_ma_dvi varchar2,b_so_id number,b_cmt varchar2,b_ngay number,b_ngay_hl number,b_ngay_kt number,
    a_ma_dvi out pht_type.a_var,a_so_id out pht_type.a_num,a_so_id_dt out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_so_idD number; b_so_id_kh number; b_bt number:=0;
begin
-- Dan - Tim doi tuong ghep
b_loi:='loi:Loi tim doi tuong ghep:loi';
b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
for r_lp in (select ma_dvi,so_id,so_id_dt from bh_ng_ds where
    cmt=b_cmt and FKH_GIAO(b_ngay_hl,b_ngay_kt,ngay_hl,ngay_kt)='C') loop
    if FBH_NG_HL(r_lp.ma_dvi,r_lp.so_id,b_ngay,b_ngay_hl,b_ngay_kt)='C' then
        b_so_id_kh:=FBH_NG_SO_IDd(r_lp.ma_dvi,r_lp.so_id);
        if (b_so_idD<>b_so_id_kh) then
            b_i1:=0;
            for b_lp1 in 1..b_bt loop
                if a_so_id(b_lp1)=b_so_id_kh then b_i1:=1; exit; end if;
            end loop;
            if b_i1=0 then
                b_bt:=b_bt+1;
                a_ma_dvi(b_bt):=r_lp.ma_dvi; a_so_id(b_bt):=b_so_id_kh; a_so_id_dt(b_bt):=r_lp.so_id_dt;
            end if;
        end if;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_SKN_HDBS(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma_dvi varchar2(10); b_so_id number; b_so_idD number;
    b_dong number; cs_lke clob:='';
begin
-- Dan - Liet ke sua doi bo sung
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
select nvl(min(so_id_d),0) into b_so_idD from bh_skN where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_so_idD<>0 then
    select count(*) into b_dong from bh_skN where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hd,ttoan,ttrang,ma_dvi,so_id,
           'ma_sdbs' value PKH_TEN_TENl(FBH_SKN_MA_SDBS(so_id))) order by so_id desc returning clob)
        into cs_lke from bh_skN where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;  
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGDLN_HDBS(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma_dvi varchar2(10); b_so_id number; b_so_idD number;
    b_dong number; cs_lke clob:='';
begin
-- Dan - Liet ke sua doi bo sung
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
select nvl(min(so_id_d),0) into b_so_idD from bh_ngdlN where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_so_idD<>0 then
    select count(*) into b_dong from bh_ngdlN where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hd,ttoan,ttrang,ma_dvi,so_id,
           'ma_sdbs' value PKH_TEN_TENl(Fbh_NGDLN_MA_SDBS(so_id))) order by so_id desc returning clob)
        into cs_lke from bh_ngdlN where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;  
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NG_GOC_NH(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    dt_goc clob;
begin
-- Dan - Nhap goc
select json_object('ma_dvi' value b_ma_dvi,'nsd' value nsd,'so_id' value b_so_id,'so_hd' value so_hd,'kieu_hd' value kieu_hd,'nv' value 'NG',
    'ngay_ht' value ngay_ht,'ngay_cap' value ngay_cap,'ngay_hl' value ngay_hl,'ngay_kt' value ngay_kt,'kieu_kt' value kieu_kt,
    'ma_kt' value ma_kt,'hhong' value hhong,'pt_hhong' value 'D','ma_kh' value ma_kh,'ten' value ten,'kieu_gt' value kieu_gt,'ma_gt' value ma_gt,
    'phong' value phong,'ma_cb' value ma_cb,'so_id_d' value so_id_d,'so_id_g' value so_id_g,'ttrang' value ttrang,'dvi_ksoat' value dvi_ksoat,
    'ksoat' value ksoat,'bangg' value 'bh_ng,bh_sk,bh_ngdl,bh_ngtd',
  'c_thue' value c_thue,'nt_tien' value nt_tien,'nt_phi' value nt_phi,'tien' value tien,
  'phi' value ttoan-thue,'thue' value thue returning clob) into dt_goc from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
insert into bh_hd_goc_ttdt select b_ma_dvi,b_so_id,so_id_dt,'NG',ten,ma_kh,ngay_kt,'' from bh_ng_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
PBH_HD_GOC_NH(dt_goc,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_NG_GOC_XOA(b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh varchar2,b_loi out varchar2)
AS
begin
-- Dan - Xoa goc
PBH_HD_GOC_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi,b_nh);
if b_loi is not null then return; end if;
b_loi:='loi:Loi xoa Table bh_ng:loi';
delete bh_ng_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ng_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ng_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ng_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ng_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ng_ttu_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ng_ttu where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_NG_NV(b_ma_dvi varchar2,b_so_id number,
    a_ma_dt out pht_type.a_var,a_nt_tien out pht_type.a_var,a_nt_phi out pht_type.a_var,
    a_lh_nv out pht_type.a_var,a_t_suat out pht_type.a_num,a_pt out pht_type.a_num,a_ptG out pht_type.a_num,
    a_tien out pht_type.a_num,a_phi out pht_type.a_num,a_thue out pht_type.a_num,a_ttoan out pht_type.a_num,
    a_so_id_dt out pht_type.a_num,a_dt_ma_dt out pht_type.a_var,a_dt_nt_tien out pht_type.a_var,a_dt_nt_phi out pht_type.a_var,
    a_dt_lh_nv out pht_type.a_var,a_dt_t_suat out pht_type.a_num,a_dt_pt out pht_type.a_num,a_dt_ptG out pht_type.a_num,
    a_dt_tien out pht_type.a_num,a_dt_phi out pht_type.a_num,a_dt_thue out pht_type.a_num,a_dt_ttoan out pht_type.a_num,
    tt_ngay out pht_type.a_num,tt_ma_nt out pht_type.a_var,tt_tien out pht_type.a_num,b_loi out varchar2)
AS
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_i1 number;
begin
-- Dan - Lay so lieu goc
select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
select count(*) into b_i1 from bh_ng_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then
    select a.nghe,b.lh_nv,b.t_suat,sum(b.tien),sum(b.phi),sum(b.thue),sum(b.ttoan),min(b.pt),max(b.ptG)
        bulk collect into a_ma_dt,a_lh_nv,a_t_suat,a_tien,a_phi,a_thue,a_ttoan,a_pt,a_ptG
        from bh_ng_ds a,bh_ng_dk b where a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and b.so_id_dt in(0,a.so_id_dt) and
        a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and b.lh_nv<>' ' group by a.nghe,b.lh_nv,b.t_suat; 
        
    select a.so_id_dt,a.nghe,b_nt_tien,b_nt_phi,b.lh_nv,b.t_suat,sum(b.tien),sum(b.phi),sum(b.thue),sum(b.ttoan),min(b.pt),max(b.ptG)
        bulk collect into a_so_id_dt,a_dt_ma_dt,a_dt_nt_tien,a_dt_nt_phi,a_dt_lh_nv,a_dt_t_suat,
        a_dt_tien,a_dt_phi,a_dt_thue,a_dt_ttoan,a_dt_pt,a_dt_ptG
        from bh_ng_ds a,bh_ng_dk b where a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and b.so_id_dt in(0,a.so_id_dt) and
        a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and lh_nv<>' '
        group by a.so_id_dt,a.nghe,b.lh_nv,b.t_suat having sum(b.tien)<>0 or sum(b.ttoan)<>0;
else
    select ' ',lh_nv,max(t_suat),sum(tien),sum(phi),sum(thue),sum(ttoan),min(pt),max(ptG)
        bulk collect into a_ma_dt,a_lh_nv,a_t_suat,a_tien,a_phi,a_thue,a_ttoan,a_pt,a_ptG
        from bh_ng_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
    PKH_MANG_KD_N(a_so_id_dt); PKH_MANG_KD(a_dt_lh_nv);
end if;
for b_lp in 1..a_lh_nv.count loop
    a_nt_tien(b_lp):=b_nt_tien; a_nt_phi(b_lp):=b_nt_phi;
end loop;
select ngay,b_nt_phi,tien bulk collect into tt_ngay,tt_ma_nt,tt_tien from bh_ng_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_NG_NV:loi'; end if;
end;
/
create or replace procedure PBH_NG_BPHI_DKBS (
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,'ma_dk' value ma,lh_nv) order by ma returning clob) into cs_lke
    from bh_ma_dkbs where FBH_MA_NV_CO(nv,'NG')='C' order by ma;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGDD_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(1000); cs_ma_dvi clob;b_ma_ct_goc varchar2(20);
begin
-- DUC - Tham so mo form
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select ma_ct_goc into b_ma_ct_goc from ht_ma_dvi where  ma = b_ma_dvi;
select JSON_ARRAYAGG(json_object(ma,ten,ma_goc,ma_ct_goc)) into cs_ma_dvi from ht_ma_dvi where  ma = b_ma_ct_goc;
select json_object('cs_ma_dvi' value cs_ma_dvi returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_BV_BLANH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(20); b_txt clob;
    b_blanh varchar2(1); b_dct number; b_bth varchar2(1):='C';
begin
-- Dan - Tra blanh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','MN');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ma:=nvl(trim(b_oraIn),' '); b_oraOut:='';
if b_ma<>' ' then
    select count(*) into b_i1 from bh_dtac_ma_txt where ma=b_ma;
    if b_i1<>0 then
        select txt into b_txt from bh_dtac_ma_txt where ma=b_ma;
        b_blanh:=FKH_JS_GTRIs(b_txt,'blanh'); b_dct:=FKH_JS_GTRIn(b_txt,'dct');
        if FKH_JS_GTRIn(b_txt,'dgia')>'3' then b_bth:='K'; end if;
        b_blanh:=nvl(trim(b_blanh),' ');
        if b_blanh<>'C' then b_blanh:='K'; end if;
        select json_object('bth' value b_bth,'dct' value b_dct,'blanh' value b_blanh) into b_oraOut from dual;
    end if;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NG_BPHI_DKLT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object('ma_lt' value ma,ten,'ma_dk' value ma_dk) order by ma returning clob) into cs_lke
    from bh_ma_dklt where FBH_MA_NV_CO(nv,'NG')='C' order by ma;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;