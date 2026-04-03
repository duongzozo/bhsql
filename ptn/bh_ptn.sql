create or replace function FBH_PTN_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2,b_so_id_dt number:=0) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_id number; b_txt clob:=''; b_lenh varchar2(1000); b_ma nvarchar2(500);
    a_ds_ct pht_type.a_clob;
begin
-- Nam - Tra gia tri varchar2 trong txt
if b_so_id_dt in(0,b_so_id) then
    select count(*) into b_i1 from bh_ptn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    if b_i1=1 then
        select txt into b_txt from bh_ptn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    else
        select nvl(max(lan),0) into b_i1 from bh_ptnB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
        if b_i1<>0 then
            select txt into b_txt from bh_ptnB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_i1 and loai='dt_ct';
        end if;
    end if;
    if length(b_txt)<>0 then
      PKH_JS_BONH(b_txt); b_kq:=FKH_JS_GTRIs(b_txt,b_tim);
    end if;
else
    select count(*) into b_i1 from bh_ptn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ct';
    if b_i1=1 then
        select txt into b_txt from bh_ptn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ct';
    else
        select nvl(max(lan),0) into b_i1 from bh_ptnB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ct';
        if b_i1<>0 then
            select txt into b_txt from bh_ptnB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_i1 and loai='ds_ct';
        end if;
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
create or replace function FBH_PTN_TXTn(b_ma_dvi varchar2,b_so_id number,b_tim varchar2,b_so_id_dt number:=0) return number
AS
    b_kq number:=0; b_i1 number; b_id number; b_txt clob; b_lenh varchar2(1000);
    a_ds_ct pht_type.a_clob;
begin
-- Nam - Tra gia tri num trong txt
if b_so_id_dt in(0,b_so_id) then
    select count(*) into b_i1 from bh_ptn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    if b_i1=1 then
        select txt into b_txt from bh_ptn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
        PKH_JS_BONH(b_txt); b_kq:=FKH_JS_GTRIn(b_txt,b_tim);
    end if;
else
    select count(*) into b_i1 from bh_ptn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ct';
    if b_i1=1 then
        select txt into b_txt from bh_ptn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ct';
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
create or replace function FBH_PTN_NV(
    b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(5);
begin
-- Nam - Tra nghiep vu
select min(nv) into b_kq from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_PTN_NHOM(
    b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Nam - Tra nghiep vu
select min(nhom) into b_kq from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure FBH_PTN_DT_NG(
	b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay_hl out number,b_ngay_kt out number,b_ngay number:=30000101)
AS
	b_so_idB number;
begin
-- Nam - Ngay hieu luc, ngay ket thuc doi tuong
b_so_idB:=FBH_PTN_HD_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select nvl(min(ngay_hl),0),nvl(min(ngay_kt),0) into b_ngay_hl,b_ngay_kt
	from bh_ptn_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
if b_ngay_hl=0 then
	select nvl(min(ngay_hl),0),nvl(min(ngay_kt),0) into b_ngay_hl,b_ngay_kt from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_idB;
end if;
end;
/
create or replace function FBH_PTN_HLd(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay number) return varchar2
AS
    b_so_idB number; b_ngay_hoi number; b_ngay_kt number; b_kq varchar2(1):='K';
begin
-- Nam - Kiem tra hieu luc
b_so_idB:=FBH_PTN_SO_IDbt(b_ma_dvi,b_so_id,b_ngay);
if b_so_idB<>0 then
    select ngay_hoi,ngay_kt into b_ngay_hoi,b_ngay_kt from bh_ptn_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
    if b_ngay between b_ngay_hoi and b_ngay_kt then b_kq:='C'; end if;
end if;
return b_kq;
end;
/
create or replace function FBH_PTN_KIEU_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Nam - Tra so hop dong
select nvl(min(kieu_hd),' ') into b_kq from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_PTN_KIEU_HDd(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(1); b_so_idD number:=FBH_PTN_SO_IDd(b_ma_dvi,b_so_id);
begin
-- Nam - Tra kieu hop dong qua so_id
select nvl(min(kieu_hd),' ') into b_kq from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_idD;
return b_kq;
end;
/
create or replace function FBH_PTN_SO_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Nam - Tra so hop dong
select min(so_hd) into b_kq from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_PTN_SO_HDd(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50); b_so_idD number;
begin
-- Nam - Tra so hop dong dau
b_so_idD:=FBH_PTN_SO_IDd(b_ma_dvi,b_so_id);
b_kq:=FBH_PTN_SO_HD(b_ma_dvi,b_so_idD);
return b_kq;
end;
/
create or replace function FBH_PTN_SO_ID(b_ma_dvi varchar2,b_so_hd varchar2) return number
as
    b_kq number;
begin
-- Nam - Tra so id
select nvl(min(so_id),0) into b_kq from bh_ptn where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
return b_kq;
end;
/
create or replace function FBH_PTN_ID_ID_DT(b_ma_dvi varchar2,b_so_id number,b_gcn varchar2) return number
as
    b_kq number;
begin
-- Nam - Tra so id
select nvl(min(so_id_dt),0) into b_kq from bh_ptn_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id and gcn=b_gcn;
return b_kq;
end;
/
create or replace function FBH_PTN_ID_GCN(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return varchar2
as
    b_kq varchar2(20);
begin
-- Nam - Tra gcn
select min(gcn) into b_kq from bh_ptn_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace function FBH_PTN_HD_ID_DT(b_ma_dvi varchar2,b_so_hd number,b_gcn varchar2) return number
as
    b_kq number:=0; b_so_id number;
begin
-- Nam - Tra so id DT
b_so_id:=FBH_PTN_SO_ID(b_ma_dvi,b_so_hd);
if b_so_id<>0 then b_kq:=FBH_PTN_ID_ID_DT(b_ma_dvi,b_so_id,b_gcn); end if;
return b_kq;
end;
/
create or replace function FBH_PTN_SO_IDd(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Nam - Tra so id dau
select nvl(min(so_id_d),0) into b_kq from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_PTN_HD_SO_IDd(b_ma_dvi varchar2,b_so_hd varchar2) return number
as
    b_kq number;
begin
-- Nam - Tra so id dau
select nvl(min(so_id_d),0) into b_kq from bh_ptn where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
return b_kq;
end;
/
create or replace function FBH_PTN_SO_GCNd(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return number
as
    b_kq number; b_so_idD number;
begin
-- Nam - Tra so GCN dau
b_so_idD:=FBH_PTN_SO_IDd(b_ma_dvi,b_so_id);
select min(gcn) into b_kq from bh_ptn_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idD and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace function FBH_PTN_SO_IDc(b_ma_dvi varchar2,b_so_id number,b_ttrang varchar2:='K') return number
as
    b_kq number:=0; b_so_idD number:=b_so_id;
begin
-- Nam - Tra so id cuoi
b_so_idD:=FBH_PTN_SO_IDd(b_ma_dvi,b_so_id);
if b_ttrang<>'C' then
	select nvl(max(so_id),0) into b_kq from bh_ptn where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
else
	select nvl(max(so_id),0) into b_kq from bh_ptn where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D';
end if;
return b_kq;
end;
/
create or replace function FBH_PTN_HD_SO_IDc(b_ma_dvi varchar2,b_so_hd varchar2,b_ttrang varchar2:='K') return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Nam - Tra so id cuoi
b_so_idD:=FBH_PTN_HD_SO_IDd(b_ma_dvi,b_so_hd);
if b_ttrang<>'C' then
	select nvl(max(so_id),0) into b_kq from bh_ptn where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
else
	select nvl(max(so_id),0) into b_kq from bh_ptn where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D';
end if;
return b_kq;
end;
/
create or replace function FBH_PTN_SO_IDt(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Nam - Tra so id 
b_so_idD:=FBH_PTN_SO_IDd(b_ma_dvi,b_so_id);
select nvl(max(so_id),0) into b_kq from bh_ptn where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang in('T','D') and ngay_ht<=b_ngay;
return b_kq;
end;
/
create or replace function FBH_PTN_SO_IDb(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Nam - Tra so id cuoi
b_so_idD:=FBH_PTN_SO_IDd(b_ma_dvi,b_so_id);
select nvl(max(so_id),0) into b_kq from bh_ptn where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D' and ngay_cap<=b_ngay;
return b_kq;
end;
/
create or replace function FBH_PTN_SO_IDbt(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Nam - Tra so id cuoi trong khoang hoi to
b_so_idD:=FBH_PTN_SO_IDd(b_ma_dvi,b_so_id);
select nvl(max(a.so_id),0) into b_kq from bh_ptn a, bh_ptn_dvi b where 
       a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and a.ma_dvi=b_ma_dvi and a.so_id_d=b_so_idD and a.ttrang='D' and b.ngay_hoi<=b_ngay;
return b_kq;
end;
/
create or replace function FBH_PTN_HD_SO_IDb(
    b_ma_dvi varchar2,b_so_hd varchar2,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Nam - Tra so id cuoi
b_so_idD:=FBH_PTN_HD_SO_IDd(b_ma_dvi,b_so_hd);
select nvl(max(so_id),0) into b_kq from bh_ptn where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D' and ngay_ht<=b_ngay;
return b_kq;
end;
/
create or replace procedure FBH_PTN_SO_ID_DTf(
    b_so_id_dt in out number,b_ma_dvi out varchar2,b_so_id out number,b_ngay number:=30000101)
as
begin
-- Nam - Tra so id cuoi qua so_id_dt
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_ptn_dvi where so_id_dt=b_so_id_dt;
if b_so_id=0 then
    select min(ma_dvi),nvl(min(so_id_d),0) into b_ma_dvi,b_so_id from bh_ptn where so_id=b_so_id_dt;
    if b_so_id<>0 then b_so_id_dt:=b_so_id; end if;
end if;
if b_so_id<>0 then 
  b_so_id:=FBH_PTN_SO_IDbt(b_ma_dvi,b_so_id,b_ngay); end if;
  select nvl(max(so_id_dt),0) into b_so_id_dt from bh_ptn_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id;
end;
/
create or replace procedure FBH_PTN_SO_ID_DTd(
    b_so_id_dt number,b_ma_dvi out varchar2,b_so_id out number)
as
begin
-- Nam - Tra so id dau qua so_id_dt
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_ptn_dvi where so_id_dt=b_so_id_dt;
if b_so_id<>0 then b_so_id:=FBH_PTN_SO_IDd(b_ma_dvi,b_so_id); end if;
end;
/
create or replace function FBH_PTN_CAP(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Nam - Tra ngay cap
select min(ngay_cap) into b_kq from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_PTN_NGAY(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Nam - Tra nhap
select nvl(min(ngay_ht),0) into b_kq from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_PTN_SO_IDp(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return number
as
    b_kq number;
begin
-- Nam - Tra so_idP
select min(so_idP) into b_kq from bh_ptn_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace function FBH_PTN_TTRANG(
	b_ma_dvi varchar2,b_so_id number,b_dk varchar2:='K',b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(1); b_i1 number;
begin
-- Nam - Tra ngay cap
select nvl(min(ttrang),'X') into b_kq from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_kq<>'X' and b_dk='C' then
    select count(*) into b_i1 from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay;
    if b_i1<>0 then b_kq:='H'; end if;
end if;
return b_kq;
end;
/
create or replace procedure PBH_PTN_SO_ID_KTRA(b_ma_dvi varchar2,b_so_id_g number,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Nam - Kiem tra SO_ID moi nhap
if b_so_id_g=0 then b_loi:=''; return; end if;
select count(*) into b_i1 from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id_g and ttrang<>'D';
if b_i1<>0 then b_loi:='loi:Hop dong cu da xoa hoac chua ky:loi'; return; end if;
select count(*) into b_i1 from bh_ptn where ma_dvi=b_ma_dvi and so_id_g=b_so_id_g and kieu_hd<>'K';
if b_i1<>0 then b_loi:='loi:Hop dong cu da co bo sung, sua doi:loi'; return; end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_PTN_SO_ID_KTRA:loi'; end if;
end;
/
create or replace procedure PBH_PTN_GOC_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh varchar2,b_loi out varchar2)
AS
begin
-- Nam - Xoa goc
PBH_HD_GOC_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi,b_nh);
if b_loi is not null then return; end if;
b_loi:='loi:Loi xoa Table bh_ptn:loi';
delete bh_ptn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ptn_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ptn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ptn_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ptn_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PTN_NV(b_ma_dvi varchar2,b_so_id number,
    a_ma_dt out pht_type.a_var,a_nt_tien out pht_type.a_var,a_nt_phi out pht_type.a_var,
    a_lh_nv out pht_type.a_var,a_t_suat out pht_type.a_num,a_pt out pht_type.a_num,a_ptG out pht_type.a_num,
    a_tien out pht_type.a_num,a_phi out pht_type.a_num,a_thue out pht_type.a_num,a_ttoan out pht_type.a_num,
    tt_ngay out pht_type.a_num,tt_ma_nt out pht_type.a_var,tt_tien out pht_type.a_num,b_loi out varchar2)
AS
    b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Dan - Lay so lieu goc
b_loi:='loi:Loi lay so lieu goc:loi';
select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id;
select a.ma_sp,b.lh_nv,b.t_suat,sum(b.tien),sum(b.phi),sum(b.thue),sum(b.ttoan),min(b.pt),max(b.ptG)
    bulk collect into a_ma_dt,a_lh_nv,a_t_suat,a_tien,a_phi,a_thue,a_ttoan,a_pt,a_ptG
    from bh_ptn a,bh_ptn_dk b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and
    b.ma_dvi=b_ma_dvi and b.so_id=b_so_id and b.lh_nv<>' ' group by a.ma_sp,b.lh_nv,b.t_suat;
for b_lp in 1..a_ma_dt.count loop
    a_nt_tien(b_lp):=b_nt_tien; a_nt_phi(b_lp):=b_nt_phi;
end loop;
select ngay,b_nt_phi,tien bulk collect into tt_ngay,tt_ma_nt,tt_tien from bh_ptn_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PTN_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,
  b_ttrang varchar2,b_so_hd out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_nv varchar2(10); b_txt clob;
begin
-- dan - Update sau duyet
b_loi:='loi:Loi xu ly PBH_PTN_DU:loi';
select so_hd,nv into b_so_hd,b_nv from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_i1:=instr(b_so_hd,'.');
if b_ttrang='D' then
    if b_i1=2 then b_so_hd:=substr(b_so_hd,3); end if;
else
    if b_i1<>2 then b_so_hd:=b_ttrang||'.'||b_so_hd; end if;
end if;
if b_nv='TNCC' then
    select txt into b_txt from bh_ptncc_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    b_txt:=FKH_JS_BONH(b_txt); PKH_JS_THAY(b_txt,'so_hd',b_so_hd); b_txt:=b_txt;
    update bh_ptncc_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
else
    select txt into b_txt from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    b_txt:=FKH_JS_BONH(b_txt); PKH_JS_THAY(b_txt,'so_hd',b_so_hd); b_txt:=b_txt;
    update bh_ptnnn_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
end if;
update bh_ptn set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure FBH_PTN_KHO(
   b_ngay_hl number,b_ngay_kt number,b_kho out number,b_loi out varchar2)
AS
    b_i1 number; b_tltg number;
begin
-- Nam - Tinh he so phi
b_loi:='loi:Loi xu ly FBH_PTN_KHO:loi';
if substr(to_char(b_ngay_hl), 5)=substr(to_char(b_ngay_kt), 5) then b_kho:=FKH_KHO_NASO(b_ngay_hl,b_ngay_kt);
else
  b_kho:=FKH_KHO_NGSO(b_ngay_hl,b_ngay_kt)+1;
  select count(*) into b_i1 from bh_ptn_tltg;
  if b_kho<365 and b_i1<>0 then
      b_kho:=FKH_KHO_THSO(b_ngay_hl,b_ngay_kt);
      select count(*),nvl(min(tltg),0) into b_i1,b_tltg from bh_ptn_tltg
          where tltg>b_kho and b_ngay_hl between ngay_bd and ngay_kt;
      if b_i1=0 then b_kho:=1;
      else
          select tlph into b_kho from bh_ptn_tltg where tltg=b_tltg and b_ngay_hl between ngay_bd and ngay_kt;
          b_kho:=b_kho/100;
      end if;
  elsif b_kho<365 or b_kho>366 then
      b_kho:=b_kho/365;
  else b_kho:=1;
  end if;
end if;
b_loi:='';
end;
/
create or replace procedure PBH_PTN_HDBS(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma_dvi varchar2(10); b_so_id number; b_so_idD number;
    b_dong number; cs_lke clob:='';
begin
-- Nam - Liet ke sua doi bo sung
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','PTN','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_so_idD:=FBH_PTN_SO_IDd(b_ma_dvi,b_so_id);
if b_so_idD<>0 then
    select count(*) into b_dong from bh_ptn where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hd,ttoan,ttrang,ma_dvi,so_id,
           'ma_sdbs' value PKH_TEN_TENl(FBH_PTN_TXT(ma_dvi,so_id,'ma_sdbs'))) order by so_id desc returning clob)
        into cs_lke from bh_ptn where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;   
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTN_PHIb(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000); b_loi varchar2(1000); b_i1 number; b_i2 number; dt_ct clob;
    b_ma varchar2(20); b_so_hdG varchar2(20); b_ngay_hl number; b_ngay_kt number; b_ngay_cap number;
    b_ngay_hlC number; b_ngay_ktC number; b_so_idG number:=0; b_so_id_dt number;
    b_tienG number; b_ptG number; b_phiG number;
begin
-- Nam - tinh phi prorata
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct');
EXECUTE IMMEDIATE b_lenh into dt_ct using b_oraIn;
FKH_JS_NULL(dt_ct);
b_lenh:=FKH_JS_LENH('so_id_dt,so_hd_g,ngay_hl,ngay_kt,ngay_cap,ma');
EXECUTE IMMEDIATE b_lenh into b_so_id_dt,b_so_hdG,b_ngay_hl,b_ngay_kt,b_ngay_cap,b_ma using dt_ct;
b_so_id_dt:=nvl(b_so_id_dt,0);
if b_ma is null then b_loi:=''; return; end if;
if b_so_hdG<>' ' then
    b_so_idG:=FBH_PTN_SO_ID(b_ma_dvi,b_so_hdG);
    if b_so_idG=0 then b_loi:='loi:GCN goc da xoa:loi'; return; end if;
end if;
if b_so_idG<>0 and b_ngay_hl<b_ngay_cap then
    select ngay_hl,ngay_kt into b_ngay_hlC,b_ngay_ktC from bh_ptn_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idG and b_so_id_dt in(0,so_id_dt);
    b_i1:=FKH_KHO_NGSO(b_ngay_cap,b_ngay_ktC)/FKH_KHO_NGSO(b_ngay_hlC,b_ngay_ktC);
    b_i2:=FKH_KHO_NGSO(b_ngay_cap,b_ngay_kt)/FKH_KHO_NGSO(b_ngay_hl,b_ngay_kt);
    b_i1:=round(b_i1,2); b_i2:=round(b_i2,2);
    select tien,pt,phi into b_tienG,b_ptG,b_phiG from bh_ptn_dk where ma_dvi=b_ma_dvi and so_id=b_so_idG and ma=b_ma and b_so_id_dt in(0,so_id_dt);
end if;
select json_object('hsc' value b_i1,'hsm' value b_i2 ,'tien' value b_tienG,'pt' value b_ptG,'phi' value b_phiG returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_PTN_PHIb(b_tp number,
    dk_ma pht_type.a_var,dk_ma_ct pht_type.a_var,dk_lkeP pht_type.a_var,dk_cap pht_type.a_num,
    dk_phi in out pht_type.a_num,dk_thue in out pht_type.a_num,dk_ttoan out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_cap number:=1; b_phi number; b_thue number;
begin
-- Nam - Tinh bac cao
b_loi:='loi:Loi xu ly FBH_PTN_PHIb:loi';
for b_lp in 1..dk_ma.count loop
    if dk_cap(b_lp)>b_cap then b_cap:=dk_cap(b_lp); end if;
    if dk_lkeP(b_lp) in('T','N') then dk_phi(b_lp):=0; dk_thue(b_lp):=0; end if;
end loop;
b_cap:=b_cap-1;
while b_cap>0 loop
    for b_lp in 1..dk_ma.count loop
        if dk_cap(b_lp)<>b_cap then continue; end if;
        if dk_lkeP(b_lp)='T' then
            b_phi:=0; b_thue:=0;
            for b_lp1 in 1..dk_ma.count loop
                if dk_ma_ct(b_lp1)=dk_ma(b_lp) then
                    b_phi:=b_phi+dk_phi(b_lp1); b_thue:=b_thue+dk_thue(b_lp1);
                end if;
            end loop;
            dk_phi(b_lp):=b_phi; dk_thue(b_lp):=b_thue; dk_ttoan(b_lp):=b_phi+b_thue;
        elsif dk_lkeP(b_lp)='N' then
            b_i1:=0;
            for b_lp1 in 1..dk_ma.count loop
                if dk_ma_ct(b_lp1)=dk_ma(b_lp) then
                    if b_i1=0 then
                        b_i1:=1; b_phi:=dk_phi(b_lp1); b_thue:=dk_thue(b_lp1);
                    else
                        b_phi:=ROUND(b_phi*dk_phi(b_lp1),b_tp); b_thue:=ROUND(b_thue*dk_thue(b_lp1),b_tp);
                    end if;
                end if;
            end loop;
            dk_phi(b_lp):=b_phi; dk_thue(b_lp):=b_thue;
        end if;
    end loop;
    b_cap:=b_cap-1;
end loop;
for b_lp in 1..dk_ma.count loop
    dk_ttoan(b_lp):=dk_phi(b_lp)+dk_thue(b_lp);
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/



