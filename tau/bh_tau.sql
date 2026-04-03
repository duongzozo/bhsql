create or replace function FBH_TAU_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2,b_so_id_dt number:=0) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_id number; b_txt clob:=''; b_lenh varchar2(1000); b_ma nvarchar2(500);
    a_ds_ct pht_type.a_clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
if b_so_id_dt in(0,b_so_id) then
    select count(*) into b_i1 from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    if b_i1=1 then
        select txt into b_txt from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    else
        select nvl(max(lan),0) into b_i1 from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
        if b_i1<>0 then
            select txt into b_txt from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_i1 and loai='dt_ct';
        end if;
    end if;
    if length(b_txt)<>0 then
	    PKH_JS_BONH(b_txt); b_kq:=FKH_JS_GTRIs(b_txt,b_tim,' ');
    end if;
else
    select count(*) into b_i1 from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ct';
    if b_i1=1 then
        select txt into b_txt from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ct';
    else
        select nvl(max(lan),0) into b_i1 from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ct';
        if b_i1<>0 then
            select txt into b_txt from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_i1 and loai='ds_ct';
        end if;
    end if;
    if length(b_txt)<>0 then
        b_lenh:=FKH_JS_LENHc('');
        EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_ct using b_txt;
        for b_lp in 1..a_ds_ct.count loop
            b_txt:=a_ds_ct(b_lp); PKH_JS_BONH(b_txt); FKH_JS_NULL(b_txt);
            b_lenh:=FKH_JS_LENH('so_id_dt,'||b_tim);
            EXECUTE IMMEDIATE b_lenh into b_id,b_ma using b_txt;
            if b_id=b_so_id_dt then b_kq:=nvl(trim(b_ma),' '); exit; end if;
        end loop;
    end if;    
end if;
return b_kq;
end;
/
create or replace function FBH_TAU_TXTn(b_ma_dvi varchar2,b_so_id number,b_tim varchar2,b_so_id_dt number:=0) return number
AS
    b_kq number:=0; b_i1 number; b_id number; b_txt clob:=''; b_lenh varchar2(1000); b_ma nvarchar2(500);
    a_ds_ct pht_type.a_clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
if b_so_id_dt in(0,b_so_id) then
    select count(*) into b_i1 from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    if b_i1=1 then
        select txt into b_txt from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    else
        select nvl(max(lan),0) into b_i1 from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
        if b_i1<>0 then
            select txt into b_txt from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_i1 and loai='dt_ct';
        end if;
    end if;
    if length(b_txt)<>0 then
	    PKH_JS_BONH(b_txt); b_kq:=FKH_JS_GTRIn(b_txt,b_tim,' ');
    end if;
else
    select count(*) into b_i1 from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ct';
    if b_i1=1 then
        select txt into b_txt from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ct';
    else
        select nvl(max(lan),0) into b_i1 from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ct';
        if b_i1<>0 then
            select txt into b_txt from bh_tauB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_i1 and loai='ds_ct';
        end if;
    end if;
    if length(b_txt)<>0 then
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
create or replace procedure PBH_TAU_TSO(
    b_oraIn clob,
    b_qtich out varchar2,b_pvi out nvarchar2,b_vtoc out number,b_hcai out varchar2,b_tvo out number,b_may out number,b_tbi out number,
    b_nhom out varchar2,b_loai out varchar2,b_cap out varchar2,b_vlieu out varchar2,
    b_ttai out number,b_so_cn out number,b_dtich out number,b_csuat out number,b_gia out number,b_tuoi out number,
    b_ma_sp out varchar2,b_dkien out varchar2,b_md_sd out varchar2,b_nv_bh out varchar2,
    b_ngay_hl out number,b_ngay_kt out number,
    b_so_dk out varchar2,b_ten_tau out nvarchar2,b_nam_sx out number,
    b_hoi out varchar2,b_hoi_tien out number,b_hoi_tyle out number,b_hoi_hh out number,b_tl_mgiu out number,b_loi out varchar2)
AS
    b_lenh varchar2(2000);
begin
-- Dan - Dat gia tri
b_loi:='loi:Loi xu ly PBH_TAU_TSO:loi';
b_lenh:='qtich,pvi,vtoc,hcai,tvo,may,tbi,';
b_lenh:=b_lenh||'nhom,loai,cap,vlieu,ttai,so_cn,dtich,csuat,gia,ma_sp,dkien,md_sd,nv_bh,ngay_hl,ngay_kt,';
b_lenh:=b_lenh||'so_dk,ten_tau,nam_sx,hoi,hoi_tien,hoi_tyle,hoi_hh,tl_mgiu';
b_lenh:=FKH_JS_LENH(b_lenh);
EXECUTE IMMEDIATE b_lenh into
    b_qtich,b_pvi,b_vtoc,b_hcai,b_tvo,b_may,b_tbi,
    b_nhom,b_loai,b_cap,b_vlieu,b_ttai,b_so_cn,b_dtich,b_csuat,b_gia,
    b_ma_sp,b_dkien,b_md_sd,b_nv_bh,b_ngay_hl,b_ngay_kt,
    b_so_dk,b_ten_tau,b_nam_sx,b_hoi,b_hoi_tien,b_hoi_tyle,b_hoi_hh,b_tl_mgiu using b_oraIn;
b_qtich:=PKH_MA_TENl(b_qtich);    
b_pvi:=nvl(trim(b_pvi),' '); b_vtoc:=nvl(b_vtoc,0); b_hcai:=nvl(trim(b_hcai),' '); b_tvo:=nvl(b_tvo,0); b_may:=nvl(b_may,0); b_tbi:=nvl(b_tbi,0);
b_nhom:=PKH_MA_TENl(b_nhom); b_loai:=PKH_MA_TENl(b_loai); b_cap:=PKH_MA_TENl(b_cap); b_vlieu:=PKH_MA_TENl(b_vlieu);
b_ttai:=nvl(b_ttai,0); b_so_cn:=nvl(b_so_cn,0); b_dtich:=nvl(b_dtich,0); b_csuat:=nvl(b_csuat,0); b_gia:=nvl(b_gia,0); b_tuoi:=nvl(b_tuoi,0);
b_ma_sp:=nvl(trim(b_ma_sp),' '); b_dkien:=PKH_MA_TENl(b_dkien); b_md_sd:=nvl(trim(b_md_sd),' '); b_nv_bh:=nvl(trim(b_nv_bh),' ');
b_ngay_hl:=nvl(b_ngay_hl,0); b_ngay_kt:=nvl(b_ngay_kt,30000101);
if b_ngay_hl in(0,30000101) then b_ngay_hl:=PKH_NG_CSO(sysdate); end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_so_dk:=nvl(trim(b_so_dk),' '); b_ten_tau:=nvl(trim(b_ten_tau),' '); b_nam_sx:=nvl(b_nam_sx,0);
b_hoi:=PKH_MA_TENl(b_hoi); b_hoi_tien:=nvl(b_hoi_tien,0); b_hoi_tyle:=nvl(b_hoi_tyle,0);
b_hoi_hh:=nvl(b_hoi_hh,0); b_tl_mgiu:=nvl(b_tl_mgiu,0);
if b_nam_sx<>0 then b_tuoi:=FBH_TAU_TUOI(b_nam_sx); end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function FBH_TAU_NV(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra nghiep vu
select min(nv) into b_kq from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_TAU_BIEN(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngayN number:=30000101) return nvarchar2
AS
    b_kq nvarchar2(500); b_so_idB number; b_ngay number:=b_ngayN;
begin
-- Dan - Tra bien
if b_ngay in (0,30000101) then b_ngay:=PKH_NG_CSO(sysdate); end if;
b_so_idB:=FBH_TAU_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select min(trim(so_dk||'/'||ten_tau)) into b_kq from
    bh_tau_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace procedure FBH_TAU_DT_NG(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay_hl out number,b_ngay_kt out number,b_ngay number:=30000101)
AS
    b_so_idB number;
begin
-- Dan - Ngay hieu luc, ngay ket thuc doi tuong
b_so_idB:=FBH_TAU_HD_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select nvl(min(ngay_hl),0),nvl(min(ngay_kt),0) into b_ngay_hl,b_ngay_kt
    from bh_tau_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
if b_ngay_hl=0 then
    select nvl(min(ngay_hl),0),nvl(min(ngay_kt),0) into b_ngay_hl,b_ngay_kt from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_idB;
end if;
end;
/
create or replace function FBH_TAU_HL(
    b_ma_dvi varchar2,b_so_id number,b_ngay number,b_ngayd number,b_ngayc number) return varchar2
AS
    b_so_idB number; b_ngay_hl number; b_ngay_kt number; b_kq varchar2(1):='K';
begin
-- Dan - Kiem tra hieu luc
b_so_idB:=FBH_TAU_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_idB;
if b_ngayd<=b_ngay_kt and b_ngay_hl<=b_ngayc then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_TAU_HLd(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay number) return varchar2
AS
    b_so_idB number; b_ngay_hl number; b_ngay_kt number; b_kq varchar2(1):='K';
begin
-- Dan - Kiem tra hieu luc
b_so_idB:=FBH_TAU_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
if b_so_idB<>0 then
    select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from bh_tau_ds  where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
    if b_ngay between b_ngay_hl and b_ngay_kt then b_kq:='C'; end if;
end if;
return b_kq;
end;
/
create or replace function FBH_TAU_KIEU_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Dan - Tra so hop dong
select nvl(min(kieu_hd),' ') into b_kq from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_TAU_KIEU_HDd(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(1); b_so_idD number:=FBH_TAU_SO_IDd(b_ma_dvi,b_so_id);
begin
-- Dan - Tra kieu hop dong qua so_id
select nvl(min(kieu_hd),' ') into b_kq from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_idD;
return b_kq;
end;
/
create or replace function FBH_TAU_SO_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Dan - Tra so hop dong
select min(so_hd) into b_kq from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_TAU_SO_HDd(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50); b_so_idD number;
begin
-- Dan - Tra so hop dong dau
b_so_idD:=FBH_TAU_SO_IDd(b_ma_dvi,b_so_id);
b_kq:=FBH_TAU_SO_HD(b_ma_dvi,b_so_idD);
return b_kq;
end;
/
create or replace function FBH_TAU_SO_ID(b_ma_dvi varchar2,b_so_hd varchar2,b_nv varchar2:='') return number
as
    b_kq number;
begin
-- Dan - Tra so id
if nvl(b_nv,' ')=' ' then 
    select nvl(min(so_id),0) into b_kq from bh_tau where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
else 
    select nvl(min(so_id),0) into b_kq from bh_tau where ma_dvi=b_ma_dvi and so_hd=b_so_hd and nv=b_nv;
end if;
return b_kq;
end;
/
create or replace function FBH_TAU_ID_ID_DT(b_ma_dvi varchar2,b_so_id number,b_gcn varchar2) return number
as
    b_kq number;
begin
-- Dan - Tra so id
select nvl(min(so_id_dt),0) into b_kq from bh_tau_ds where ma_dvi=b_ma_dvi and gcn=b_gcn;
return b_kq;
end;
/
create or replace function FBH_TAU_ID_GCN(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return varchar2
as
    b_kq varchar2(20);
begin
-- Dan - Tra gcn
select min(gcn) into b_kq from bh_tau_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace function FBH_TAU_HD_ID_DT(b_ma_dvi varchar2,b_so_hd number,b_gcn varchar2) return number
as
    b_kq number:=0; b_so_id number;
begin
-- Dan - Tra so id DT
b_so_id:=FBH_TAU_SO_ID(b_ma_dvi,b_so_hd);
if b_so_id<>0 then b_kq:=FBH_TAU_ID_ID_DT(b_ma_dvi,b_so_id,b_gcn); end if;
return b_kq;
end;
/
create or replace function FBH_TAU_SO_IDd(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Dan - Tra so id dau
select nvl(min(so_id_d),0) into b_kq from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_TAU_HD_SO_IDd(b_ma_dvi varchar2,b_so_hd varchar2) return number
as
    b_kq number;
begin
-- Dan - Tra so id dau
select nvl(min(so_id_d),0) into b_kq from bh_tau where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
return b_kq;
end;
/
create or replace function FBH_TAU_SO_GCNd(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return number
as
    b_kq number; b_so_idD number;
begin
-- Dan - Tra so GCN dau
b_so_idD:=FBH_TAU_SO_IDd(b_ma_dvi,b_so_id);
select min(gcn) into b_kq from bh_tau_ds where ma_dvi=b_ma_dvi and so_id=b_so_idD and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace function FBH_TAU_SO_IDc(b_ma_dvi varchar2,b_so_id number,b_ttrang varchar2:='K') return number
as
    b_kq number:=0; b_so_idD number:=b_so_id;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_TAU_SO_IDd(b_ma_dvi,b_so_id);
if b_ttrang<>'C' then
    select nvl(max(so_id),0) into b_kq from bh_tau where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
else
    select nvl(max(so_id),0) into b_kq from bh_tau where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D';
end if;
return b_kq;
end;
/
create or replace function FBH_TAU_HD_SO_IDc(b_ma_dvi varchar2,b_so_hd varchar2,b_ttrang varchar2:='K') return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_TAU_HD_SO_IDd(b_ma_dvi,b_so_hd);
if b_ttrang<>'C' then
    select nvl(max(so_id),0) into b_kq from bh_tau where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
else
    select nvl(max(so_id),0) into b_kq from bh_tau where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D';
end if;
return b_kq;
end;
/
create or replace function FBH_TAU_SO_IDt(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_TAU_SO_IDd(b_ma_dvi,b_so_id);
select nvl(max(so_id),0) into b_kq from bh_tau where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang in('T','D') and ngay_ht<=b_ngay;
return b_kq;
end;
/
create or replace function FBH_TAU_SO_IDb(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_TAU_SO_IDd(b_ma_dvi,b_so_id);
select nvl(max(so_id),0) into b_kq from bh_tau where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D' and ngay_cap<=b_ngay;
return b_kq;
end;
/
create or replace function FBH_TAU_HD_SO_IDb(
    b_ma_dvi varchar2,b_so_hd varchar2,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_TAU_HD_SO_IDd(b_ma_dvi,b_so_hd);
select nvl(max(so_id),0) into b_kq from bh_tau where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D' and ngay_ht<=b_ngay;
return b_kq;
end;
/
create or replace procedure FBH_TAU_SO_ID_DT(
    b_so_id_dt number,b_ma_dvi out varchar2,b_so_id out number,b_ngay number:=30000101)
as
begin
-- Dan - Tra so id cuoi qua so_id_dt
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_tau_ds where so_id_dt=b_so_id_dt;
if b_so_id<>0 then b_so_id:=FBH_TAU_SO_IDb(b_ma_dvi,b_so_id,b_ngay); end if;
end;
/
create or replace procedure FBH_TAU_SO_ID_DTf(
    b_so_id_dt in out number,b_ma_dvi out varchar2,b_so_id out number,b_ngay number:=30000101)
as
	b_so_idD number; b_i1 number;
begin
-- Dan - Tra so id cuoi qua so_id_dt
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_tau_ds where so_id_dt=b_so_id_dt;
if b_so_id=0 then
	select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_tau where so_id=b_so_id_dt;
	if b_so_id<>0 then
		b_so_idD:=FBH_TAU_SO_IDd(b_ma_dvi,b_so_id);
		select count(*) into b_i1 from bh_tau_ds where so_id_dt=b_so_idD;
		if b_i1<>0 then b_so_id_dt:=b_so_idD; else b_so_id:=0; end if;
	end if;
end if;
if b_so_id<>0 then b_so_id:=FBH_TAU_SO_IDb(b_ma_dvi,b_so_id,b_ngay); end if;
end;
/
create or replace procedure FBH_TAU_SO_ID_GCN(
    b_gcn varchar2,b_ma_dvi out varchar2,b_so_id out number,b_so_id_dt out number,b_ngay number:=30000101)
as
begin
-- Dan - Tra so id cuoi qua so_id_dt
select count(*) into b_so_id from bh_tau_ds where gcn=b_gcn;
if b_so_id<>1 then
    b_ma_dvi:=''; b_so_id:=0; b_so_id_dt:=0;
else
    select ma_dvi,so_id,so_id_dt into b_ma_dvi,b_so_id,b_so_id_dt from bh_tau_ds where gcn=b_gcn;
    b_so_id:=FBH_TAU_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
end if;
end;
/
create or replace procedure FBH_TAU_SO_ID_DTd(
    b_so_id_dt number,b_ma_dvi out varchar2,b_so_id out number)
as
begin
-- Dan - Tra so id dau qua so_id_dt
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_tau_ds where so_id_dt=b_so_id_dt;
if b_so_id<>0 then b_so_id:=FBH_TAU_SO_IDd(b_ma_dvi,b_so_id); end if;
end;
/
create or replace procedure FBH_TAU_HD_SO_ID_DT(
    b_gcn varchar2,b_ngay number,b_ma_dvi out varchar2,b_so_id out number,b_so_id_dt out number)
as
begin
-- Dan - Tra so id qua GCN
select nvl(min(so_id_dt),0) into b_so_id_dt from bh_tau_ds where gcn=b_gcn;
if b_so_id_dt<>0 then
    FBH_TAU_SO_ID_DT(b_so_id_dt,b_ma_dvi,b_so_id,b_ngay);
else
    b_so_id:=0; b_ma_dvi:='';
end if;
end;
/
create or replace procedure FBH_TAU_HD_SO_ID_DTd(
    b_gcn varchar2,b_ma_dvi out varchar2,b_so_id out number,b_so_id_dt out number)
as
begin
-- Dan - Tra so id dau qua GCN
select min(ma_dvi),nvl(min(so_id),0),nvl(min(so_id_dt),0) into b_ma_dvi,b_so_id,b_so_id_dt from bh_tau_ds where gcn=b_gcn;
if b_so_id<>0 then b_so_id:=FBH_TAU_SO_IDd(b_ma_dvi,b_so_id); end if;
end;
/
create or replace function FBH_TAU_NT_TIEN(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(5); b_so_idB number;
begin
-- Dan - Tra loai tien bao hiem
b_so_idB:=FBH_TAU_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select nvl(min(nt_tien),'VND') into b_kq from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_idB;
return b_kq;
end;
/
create or replace function FBH_TAU_NT_PHI(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(5); b_so_idB number;
begin
-- Dan - Tra loai tien phi
b_so_idB:=FBH_TAU_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select nvl(min(nt_phi),'VND') into b_kq from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_idB;
return b_kq;
end;
/
create or replace function FBH_TAU_MA_DT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay number:=30000101) return varchar2
AS
    b_kq varchar2(20); b_ma_dt varchar(500); b_so_idB number;
begin
-- Dan - Tra bien
b_so_idB:=FBH_TAU_SO_IDt(b_ma_dvi,b_so_id,b_ngay);
if b_so_idB<>0 then
    select nvl(min(loai),' ') into b_kq from bh_tau_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
else
    --Nam: lay tu txt
    b_ma_dt:=FBH_TAU_TXT(b_ma_dvi,b_so_id,'loai',b_so_id_dt);
    b_kq:=PKH_MA_TENl(b_ma_dt);
end if;
return b_kq;
end;
/
create or replace function FBH_TAU_CAP(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Dan - Tra ngay cap
select min(ngay_cap) into b_kq from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_TAU_NGAY(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Dan - Tra nhap
select nvl(min(ngay_ht),0) into b_kq from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_TAU_TTRANG(
    b_ma_dvi varchar2,b_so_id number,b_dk varchar2:='K',b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(1); b_i1 number;
begin
-- Dan - Tra ngay cap
select nvl(min(ttrang),'X') into b_kq from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_kq<>'X' and b_dk='C' then
    select count(*) into b_i1 from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay;
    if b_i1<>0 then b_kq:='H'; end if;
end if;
return b_kq;
end;
/
create or replace function FBH_TAUTSO_SO_ID(
    b_so_dk varchar2) return number
AS
    b_kq number:=0;
begin
-- Nam - Tra nghiep vu
if trim(b_so_dk) is not null then
    select nvl(min(tau_id),0) into b_kq from bh_tau_ID where so_dk=b_so_dk;
end if;
return b_kq;
end;
/
create or replace procedure PBH_TAU_MA_SP(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma_sp varchar2(20); cs_lke clob:='';
begin
-- tra dieu kien chinh theo ma_sp
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ma_sp:=trim(b_oraIn);
if b_ma_sp is not null then
    select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into cs_lke from bh_tau_dkc where ma_sp=b_ma_sp;
end if;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_SO_ID_KTRA(b_ma_dvi varchar2,b_so_id_g number,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Kiem tra SO_ID moi nhap
if b_so_id_g=0 then b_loi:=''; return; end if;
select count(*) into b_i1 from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_id_g and ttrang<>'D';
if b_i1<>0 then b_loi:='loi:Hop dong cu da xoa hoac chua ky:loi'; return; end if;
select count(*) into b_i1 from bh_tau where ma_dvi=b_ma_dvi and so_id_g=b_so_id_g and kieu_hd<>'K';
if b_i1<>0 then b_loi:='loi:Hop dong cu da co bo sung, sua doi:loi'; return; end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
CREATE OR REPLACE procedure PBH_TAU_BS(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_so_idD number;
    b_ma_dvi varchar2(10); b_so_id number; b_so_id_dt number; cs_lke clob;
begin
-- Dan - Liet ke sua doi theo doi tuong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','TAU','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id,so_id_dt');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id,b_so_id_dt using b_oraIn;
if b_so_id=0 then b_loi:='loi:GCN/Hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
b_so_idD:=FBH_TAU_SO_IDd(b_ma_dvi,b_so_id);
select JSON_ARRAYAGG(json_object(ngay_ht,so_hd,gcn) order by ngay_ht desc,so_hd desc,gcn desc returning clob) into cs_lke from
        (select distinct a.ngay_ht,a.so_hd,b.gcn from bh_tau a,bh_tau_ds b
        where a.ma_dvi=b_ma_dvi and a.so_id_d=b_so_idD and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id and b.so_id_dt=b_so_id_dt);
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10);
    b_ngay_ht number; b_nv varchar2(1); b_klk varchar2(1); b_tu number; b_den number;
    b_dong number; cs_lke clob;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,nv,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_nv,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_tau where ma_dvi=b_ma_dvi and 
        ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_tau where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','TAU','X')<>'C' then
    if b_klk='P' then
        b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
        select count(*) into b_dong from bh_tau where ma_dvi=b_ma_dvi and
            ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong;
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(obj returning clob) into cs_lke from
            (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_tau  where
                ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong order by so_hd)
            where sott between b_tu and b_den;
    else
        select count(*) into b_dong from bh_tau where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv;
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(obj returning clob) into cs_lke from
            (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_tau  where
                ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv order by so_hd)
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10); b_so_hd varchar2(20);
    b_so_id number; b_ngay_ht number; b_nv varchar2(1); b_klk varchar2(1); b_trangKt number; b_tu number; b_den number;
    b_trang number; b_dong number; cs_lke clob;
begin
-- Dan - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,nv,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_nv,b_klk,b_trangKt using b_oraIn;
b_so_hd:=FBH_TAU_SO_HD(b_ma_dvi,b_so_id);
if b_so_hd is null then b_loi:='loi:GCN, hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
if b_klk ='N' then
    select count(*) into b_dong from bh_tau where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_tau where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_tau  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','TAU','X')<>'C' then
    if b_klk='P' then
        b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
        select count(*) into b_dong from bh_tau where ma_dvi=b_ma_dvi and
            ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong;
        select nvl(min(sott),b_dong) into b_tu from
            (select so_hd,rownum sott from bh_tau where
                ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong order by so_hd)
            where so_hd>=b_so_hd;
        PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
        select JSON_ARRAYAGG(obj returning clob) into cs_lke from
            (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_tau  where
                ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong order by so_hd)
            where sott between b_tu and b_den;
    else
        select count(*) into b_dong from bh_tau where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv;
        select nvl(min(sott),b_dong) into b_tu from
            (select so_hd,rownum sott from bh_tau where
                ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv order by so_hd)
            where so_hd>=b_so_hd;
        PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
        select JSON_ARRAYAGG(obj returning clob) into cs_lke from
            (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_tau  where
                ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv order by so_hd)
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
CREATE OR REPLACE procedure PBH_TAU_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_so_id number; b_so_hd varchar2(20);b_nv varchar2(10);
    b_lenh varchar2(2000); b_loi varchar2(100);
begin
-- Dan - Hoi so ID qua so hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hd,nv');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_nv using b_oraIn;
b_so_id:=FBH_TAU_SO_ID(b_ma_dvi,b_so_hd,b_nv);
if b_so_id=0 then b_loi:='loi:So hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh varchar2,b_loi out varchar2)
AS
    b_i1 number; b_so_idK number; b_ttrang varchar2(1); b_ksoat varchar2(20); b_nsdC varchar2(20);
begin
-- Dan - Xoa
b_loi:='loi:Loi xu ly PBH_TAU_XOA_XOA:loi';
select count(*) into b_i1 from bh_tau where so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select so_id_kt,ttrang,ksoat,nsd into b_so_idK,b_ttrang,b_ksoat,b_nsdC
    from bh_tau where so_id=b_so_id;
if b_so_idK>0 then b_loi:='loi:Khong sua, xoa phuc hoi da hach toan ke toan:loi'; return; end if;
if b_nsdC<>b_nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
if trim(b_ksoat) is not null and b_ksoat<>b_nsd then b_loi:='loi:Khong sua, xoa GCN, hop dong da kiem soat:loi'; return; end if;
b_loi:='loi:Loi xoa Table bh_tau:loi';
select count(*) into b_i1 from bh_tau where ma_dvi=b_ma_dvi and so_id_g=b_so_id;
if b_i1<>0 then b_loi:='loi:Khong sua, xoa GCN, hop dong da tao SDBS:loi'; return; end if;
if b_ttrang in('T','D') then
    PBH_HD_GOC_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi,b_nh);
    if b_loi is not null then return; end if;
end if;
delete bh_hd_goc_ttindt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_tau_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_tau_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_tau_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_tau_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_TAU_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Dan - Xoa GCN
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_TAU_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'X',b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_HDBS(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma_dvi varchar2(10); b_so_id number; b_so_idD number;
    b_dong number; cs_lke clob:='';
begin
-- Dan - Liet ke sua doi bo sung
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','TAU','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_so_idD:=FBH_TAU_SO_IDd(b_ma_dvi,b_so_id);
if b_so_idD<>0 then
    select count(*) into b_dong from bh_tau where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hd,ttoan,ttrang,ma_dvi,so_id,
           'ma_sdbs' value PKH_TEN_TENl(FBH_TAU_TXT(ma_dvi,so_id,'ma_sdbs'))
    ) order by so_id desc returning clob)
        into cs_lke from bh_tau where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;  
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_NV(b_ma_dvi varchar2,b_so_id number,
    a_ma_dt out pht_type.a_var,a_nt_tien out pht_type.a_var,a_nt_phi out pht_type.a_var,
    a_lh_nv out pht_type.a_var,a_t_suat out pht_type.a_num,a_pt out pht_type.a_num,a_ptG out pht_type.a_num,
    a_tien out pht_type.a_num,a_phi out pht_type.a_num,a_thue out pht_type.a_num,a_ttoan out pht_type.a_num,
    a_so_id_dt out pht_type.a_num,a_dt_ma_dt out pht_type.a_var,a_dt_nt_tien out pht_type.a_var,a_dt_nt_phi out pht_type.a_var,
    a_dt_lh_nv out pht_type.a_var,a_dt_t_suat out pht_type.a_num,a_dt_pt out pht_type.a_num,a_dt_ptG out pht_type.a_num,
    a_dt_tien out pht_type.a_num,a_dt_phi out pht_type.a_num,a_dt_thue out pht_type.a_num,a_dt_ttoan out pht_type.a_num,
    tt_ngay out pht_type.a_num,tt_ma_nt out pht_type.a_var,tt_tien out pht_type.a_num,b_loi out varchar2)
AS
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_nv varchar2(1); 
begin
-- Dan - Lay so lieu goc
b_loi:='loi:Loi lay so lieu goc:loi';
select nt_tien,nt_phi,nv into b_nt_tien,b_nt_phi,b_nv from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_id;
select a.loai,b_nt_tien,b_nt_phi,b.lh_nv,b.t_suat,sum(b.tien),sum(b.phi),sum(b.thue),sum(b.ttoan),min(b.pt),max(b.ptG)
    bulk collect into a_ma_dt,a_nt_tien,a_nt_phi,a_lh_nv,a_t_suat,a_tien,a_phi,a_thue,a_ttoan,a_pt,a_ptG
    from bh_tau_ds a,bh_tau_dk b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and
    b.ma_dvi=b_ma_dvi and b.so_id=b_so_id and b.so_id_dt=a.so_id_dt and lh_nv<>' '
    group by a.loai,b.lh_nv,b.t_suat having sum(b.tien)<>0 or sum(b.ttoan)<>0;
select a.so_id_dt,a.loai,b_nt_tien,b_nt_phi,b.lh_nv,b.t_suat,sum(b.tien),sum(b.phi),sum(b.thue),sum(b.ttoan),min(b.pt),max(b.ptG)
    bulk collect into a_so_id_dt,a_dt_ma_dt,a_dt_nt_tien,a_dt_nt_phi,a_dt_lh_nv,a_dt_t_suat,
    a_dt_tien,a_dt_phi,a_dt_thue,a_dt_ttoan,a_dt_pt,a_dt_ptG
    from bh_tau_ds a,bh_tau_dk b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and
    b.ma_dvi=b_ma_dvi and b.so_id=b_so_id and b.so_id_dt=a.so_id_dt and lh_nv<>' '
    group by a.so_id_dt,a.loai,b.lh_nv,b.t_suat having sum(b.tien)<>0 or sum(b.ttoan)<>0;
select ngay,b_nt_phi,tien bulk collect into tt_ngay,tt_ma_nt,tt_tien from bh_tau_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_TAU_SO_DK(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_dk varchar2(20):=FKH_JS_GTRIn(b_oraIn,'so_dk'); b_tau_id number; 
    cs_ct clob:='';
begin
-- Nam: lay thong tin tau tu so dang ky
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_tau_id:=FBH_TAUTSO_SO_ID(b_so_dk);
if b_tau_id<>0 then
   select json_object('ten_tau' value ten,tenc,'loai' value FBH_TAU_LOAI_TENl(loai),'cap' value FBH_TAU_CAP_TENl(cap),
   'qtich' value FBH_MA_NUOC_TENl(qtich),'vlieu' value FBH_TAU_VLIEU_TENl(vlieu),vtoc,
   ttai,csuat,dtich,so_cn,gia,tvo,may,tbi,nam_sx,hcai,pvi)
   into cs_ct from bh_tau_ID where tau_id=b_tau_id;
end if;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
