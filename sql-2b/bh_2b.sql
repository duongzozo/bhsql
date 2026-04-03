create or replace function FBH_2B_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2,b_so_id_dt number:=0) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_id number; b_txt clob:=''; b_lenh varchar2(1000); b_ma nvarchar2(500);
    a_ds_ct pht_type.a_clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
if b_so_id_dt in(0,b_so_id) then
    select count(*) into b_i1 from bh_2b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    if b_i1=1 then
        select txt into b_txt from bh_2b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    else
        select nvl(max(lan),0) into b_i1 from bh_2bB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
        if b_i1<>0 then
            select txt into b_txt from bh_2bB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_i1 and loai='dt_ct';
        end if;
    end if;
    if length(b_txt)<>0 then
      PKH_JS_BONH(b_txt); b_kq:=FKH_JS_GTRIs(b_txt,b_tim);
    end if;
else
  -- viet anh - lay ds_ct trong dt_ds
    select count(*) into b_i1 from bh_2b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
    if b_i1=1 then
        select txt into b_txt from bh_2b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
    else
        select nvl(max(lan),0) into b_i1 from bh_2bB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
        if b_i1<>0 then
            select txt into b_txt from bh_2bB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_i1 and loai='dt_ds';
        end if;
    end if;
    if length(b_txt)<>0 then
        b_lenh:=FKH_JS_LENHc('ds_ct');
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
create or replace function FBH_2B_TXTn(b_ma_dvi varchar2,b_so_id number,b_tim varchar2,b_so_id_dt number:=0) return number
AS
    b_kq number:=0; b_i1 number; b_id number; b_txt clob:=''; b_lenh varchar2(1000); b_ma nvarchar2(500);
    a_ds_ct pht_type.a_clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
if b_so_id_dt in(0,b_so_id) then
    select count(*) into b_i1 from bh_2b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    if b_i1=1 then
        select txt into b_txt from bh_2b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    else
        select nvl(max(lan),0) into b_i1 from bh_2bB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
        if b_i1<>0 then
            select txt into b_txt from bh_2bB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_i1 and loai='dt_ct';
        end if;
    end if;
    if length(b_txt)<>0 then
	    PKH_JS_BONH(b_txt); b_kq:=FKH_JS_GTRIn(b_txt,b_tim);
    end if;
else
    select count(*) into b_i1 from bh_2b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
    if b_i1=1 then
        select txt into b_txt from bh_2b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
    else
        select nvl(max(lan),0) into b_i1 from bh_2bB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
        if b_i1<>0 then
            select txt into b_txt from bh_2bB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_i1 and loai='dt_ds';
        end if;
    end if;
    if length(b_txt)<>0 then
        b_lenh:=FKH_JS_LENHc('ds_ct');
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
create or replace function FBH_2B_SO_IDp(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return varchar2
as
    b_kq varchar2(100);
begin
-- Dan - Tra so_idP
select min(so_idP) into b_kq from bh_2b_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace function FBH_2B_BIEN(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngayN number:=30000101) return varchar2
AS
    b_kq varchar2(20); b_so_idB number; b_ngay number:=b_ngayN;
begin
-- Dan - Tra bien
if b_ngay in (0,30000101) then b_ngay:=PKH_NG_CSO(sysdate); end if;
b_so_idB:=FBH_2B_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select min(nvl(trim(bien_xe),so_khung)) into b_kq from
    bh_2b_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace function FBH_2B_TUOI(b_nam_sx number) return number
AS
    b_kq number:=0; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Tra tuoi theo nam SX
if b_nam_sx is not null and b_nam_sx>1900 then
    b_kq:=b_nam_sx*10000+101;
    b_kq:=FKH_KHO_NASO(b_kq,b_ngay);
    if b_kq>100 then b_kq:=0; end if;
end if;
return b_kq;
end;
/
create or replace function FBH_2B_TUOIt(b_thang_sx number,b_nam_sx number) return number
AS
    b_kq number:=0; b_ngay number:=PKH_NG_CSO(sysdate); b_thang_sx_n number:=1;
begin
-- viet anh - Tra tuoi theo thang SX, nam SX
if b_thang_sx > 0 then b_thang_sx_n:=b_thang_sx;
end if;
if b_nam_sx is null then b_kq:=0;
elsif b_nam_sx>1900 then
    b_kq:=b_nam_sx*10000+(b_thang_sx_n*100)+1;
    b_kq:=FKH_KHO_NASO(b_kq,b_ngay);
end if;
if b_kq not between 0 and 100 then b_kq:=0; end if;
return b_kq;
end;
/
create or replace function FBH_2BTSO_SO_ID(b_bien_xe varchar2,b_so_khung varchar2) return number
AS
    b_kq number:=0;
begin
-- Dan - Tra nghiep vu
if trim(b_so_khung) is not null then
    select nvl(min(xe_id),0) into b_kq from bh_2b_ID where so_khung=b_so_khung;
end if;
if b_kq=0 and trim(b_bien_xe) is not null then
    select nvl(min(xe_id),0) into b_kq from bh_2b_ID where bien_xe=b_bien_xe;
end if;
return b_kq;
end;
/
create or replace procedure PBH_2BTSO_BIEN(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000); cs_ct clob:='';
    b_bien_xe varchar2(20); b_so_khung varchar2(30); b_so_id number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','2B','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('bien_xe,so_khung');
EXECUTE IMMEDIATE b_lenh into b_bien_xe,b_so_khung using b_oraIn;
b_so_id:=FBH_2BTSO_SO_ID(b_bien_xe,b_so_khung);
if b_so_id<>0 then
    select json_object(ten,cmt,mobi,email,dchi,bien_xe,so_khung,so_may,
        'hang' value FBH_2B_HANG_TENl(hang), 'hieu' value FBH_2B_HIEU_TENl(hieu),'pban' value FBH_2B_PB_TENl(hang,hieu,pban),
        'loai_xe' value FBH_2B_LOAI_TENl(loai_xe),'nhom_xe' value FBH_2B_NHOM_TENl(nhom_xe),
        'dong' value FBH_2B_DONG_TENl(dong),dco,ttai,so_cn,nam_sx,gia)
        into cs_ct from bh_2b_ID where xe_id=b_so_id;
end if;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_2B_NV(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra nghiep vu
select min(nv) into b_kq from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure FBH_2B_DT_NG(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay_hl out number,b_ngay_kt out number,b_ngay number:=30000101)
AS
    b_so_idB number;
begin
-- Dan - Ngay hieu luc, ngay ket thuc doi tuong
b_so_idB:=FBH_2B_HD_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select nvl(min(ngay_hl),0),nvl(min(ngay_kt),0) into b_ngay_hl,b_ngay_kt
    from bh_2b_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
if b_ngay_hl=0 then
    select nvl(min(ngay_hl),0),nvl(min(ngay_kt),0) into b_ngay_hl,b_ngay_kt from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_idB;
end if;
end;
/
create or replace function FBH_2B_HL(
    b_ma_dvi varchar2,b_so_id number,b_ngay number,b_ngayd number,b_ngayc number) return varchar2
AS
    b_so_idB number; b_ngay_hl number; b_ngay_kt number; b_kq varchar2(1):='K';
begin
-- Dan - Kiem tra hieu luc
b_so_idB:=FBH_2B_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_idB;
if b_ngayd<=b_ngay_kt and b_ngay_hl<=b_ngayc then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_2B_HLd(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay number) return varchar2
AS
    b_so_idB number; b_ngay_hl number; b_ngay_kt number; b_kq varchar2(1):='K';
begin
-- Dan - Kiem tra hieu luc
b_so_idB:=FBH_2B_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
if b_so_idB<>0 then
    select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from bh_2b_ds  where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
    if b_ngay between b_ngay_hl and b_ngay_kt then b_kq:='C'; end if;
end if;
return b_kq;
end;
/
create or replace function FBH_2B_KIEU_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Dan - Tra so hop dong
select nvl(min(kieu_hd),' ') into b_kq from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_2B_KIEU_HDd(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(1); b_so_idD number:=FBH_2B_SO_IDd(b_ma_dvi,b_so_id);
begin
-- Dan - Tra kieu hop dong qua so_id
select nvl(min(kieu_hd),' ') into b_kq from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_idD;
return b_kq;
end;
/
create or replace function FBH_2B_SO_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Dan - Tra so hop dong
select min(so_hd) into b_kq from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_2B_SO_HDd(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50); b_so_idD number;
begin
-- Dan - Tra so hop dong dau
b_so_idD:=FBH_2B_SO_IDd(b_ma_dvi,b_so_id);
b_kq:=FBH_2B_SO_HD(b_ma_dvi,b_so_idD);
return b_kq;
end;
/
create or replace function FBH_2B_SO_ID(b_ma_dvi varchar2,b_so_hd varchar2,b_nv varchar2:='') return number
as
    b_kq number;
begin
-- Dan - Tra so id
if nvl(b_nv,' ')=' ' then 
    select nvl(min(so_id),0) into b_kq from bh_2b where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
else 
    select nvl(min(so_id),0) into b_kq from bh_2b where ma_dvi=b_ma_dvi and so_hd=b_so_hd and nv=b_nv;
end if;
return b_kq;
end;
/
create or replace function FBH_2B_ID_ID_DT(b_ma_dvi varchar2,b_so_id number,b_gcn varchar2) return number
as
    b_kq number;
begin
-- Dan - Tra so id
select nvl(min(so_id_dt),0) into b_kq from bh_2b_ds where ma_dvi=b_ma_dvi and gcn=b_gcn;
return b_kq;
end;
/
create or replace function FBH_2B_ID_GCN(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return varchar2
as
    b_kq varchar2(20);
begin
-- Dan - Tra gcn
select min(gcn) into b_kq from bh_2b_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace function FBH_2B_HD_ID_DT(b_ma_dvi varchar2,b_so_hd number,b_gcn varchar2) return number
as
    b_kq number:=0; b_so_id number;
begin
-- Dan - Tra so id DT
b_so_id:=FBH_2B_SO_ID(b_ma_dvi,b_so_hd);
if b_so_id<>0 then b_kq:=FBH_2B_ID_ID_DT(b_ma_dvi,b_so_id,b_gcn); end if;
return b_kq;
end;
/
create or replace function FBH_2B_SO_IDd(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Dan - Tra so id dau
select nvl(min(so_id_d),0) into b_kq from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_2B_HD_SO_IDd(b_ma_dvi varchar2,b_so_hd varchar2) return number
as
    b_kq number;
begin
-- Dan - Tra so id dau
select nvl(min(so_id_d),0) into b_kq from bh_2b where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
return b_kq;
end;
/
create or replace function FBH_2B_SO_GCNd(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return number
as
    b_kq number; b_so_idD number;
begin
-- Dan - Tra so GCN dau
b_so_idD:=FBH_2B_SO_IDd(b_ma_dvi,b_so_id);
select min(gcn) into b_kq from bh_2b_ds where ma_dvi=b_ma_dvi and so_id=b_so_idD and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace function FBH_2B_SO_IDc(b_ma_dvi varchar2,b_so_id number,b_ttrang varchar2:='K') return number
as
    b_kq number:=0; b_so_idD number:=b_so_id;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_2B_SO_IDd(b_ma_dvi,b_so_id);
if b_ttrang<>'C' then
    select nvl(max(so_id),0) into b_kq from bh_2b where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
else
    select nvl(max(so_id),0) into b_kq from bh_2b where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D';
end if;
return b_kq;
end;
/
create or replace function FBH_2B_HD_SO_IDc(b_ma_dvi varchar2,b_so_hd varchar2,b_ttrang varchar2:='K') return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_2B_HD_SO_IDd(b_ma_dvi,b_so_hd);
if b_ttrang<>'C' then
    select nvl(max(so_id),0) into b_kq from bh_2b where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
else
    select nvl(max(so_id),0) into b_kq from bh_2b where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D';
end if;
return b_kq;
end;
/
create or replace function FBH_2B_SO_IDt(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_2B_SO_IDd(b_ma_dvi,b_so_id);
select nvl(max(so_id),0) into b_kq from bh_2b where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang in('T','D') and ngay_ht<=b_ngay;
return b_kq;
end;
/
create or replace function FBH_2B_SO_IDb(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_2B_SO_IDd(b_ma_dvi,b_so_id);
select nvl(max(so_id),0) into b_kq from bh_2b where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D' and ngay_cap<=b_ngay;
return b_kq;
end;
/
create or replace function FBH_2B_HD_SO_IDb(
    b_ma_dvi varchar2,b_so_hd varchar2,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_2B_HD_SO_IDd(b_ma_dvi,b_so_hd);
select nvl(max(so_id),0) into b_kq from bh_2b where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D' and ngay_ht<=b_ngay;
return b_kq;
end;
/
create or replace procedure FBH_2B_SO_ID_DT(
    b_so_id_dt number,b_ma_dvi out varchar2,b_so_id out number,b_ngay number:=30000101)
as
begin
-- Dan - Tra so id cuoi qua so_id_dt
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_2b_ds where so_id_dt=b_so_id_dt;
if b_so_id<>0 then b_so_id:=FBH_2B_SO_IDb(b_ma_dvi,b_so_id,b_ngay); end if;
end;
/
create or replace procedure FBH_2B_SO_ID_DTf(
    b_so_id_dt in out number,b_ma_dvi out varchar2,b_so_id out number,b_ngay number:=30000101)
as
    b_so_idD number; b_i1 number;
begin
-- Dan - Tra so id cuoi qua so_id_dt
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_2b_ds where so_id_dt=b_so_id_dt;
if b_so_id=0 then
    select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_2b where so_id=b_so_id_dt;
    if b_so_id<>0 then
        b_so_idD:=FBH_2B_SO_IDd(b_ma_dvi,b_so_id);
        select count(*) into b_i1 from bh_2b_ds where so_id_dt=b_so_idD;
        if b_i1<>0 then b_so_id_dt:=b_so_idD; else b_so_id:=0; end if;
    end if;
end if;
if b_so_id<>0 then b_so_id:=FBH_2B_SO_IDb(b_ma_dvi,b_so_id,b_ngay); end if;
end;
/
create or replace procedure FBH_2B_SO_ID_GCN(
    b_gcn varchar2,b_ma_dvi out varchar2,b_so_id out number,b_so_id_dt out number,b_ngay number:=30000101)
as
begin
-- Dan - Tra so id cuoi qua so_id_dt
select count(*) into b_so_id from bh_2b_ds where gcn=b_gcn;
if b_so_id<>1 then
	b_ma_dvi:=''; b_so_id:=0; b_so_id_dt:=0;
else
	select ma_dvi,so_id,so_id_dt into b_ma_dvi,b_so_id,b_so_id_dt from bh_2b_ds where gcn=b_gcn;
	b_so_id:=FBH_2B_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
end if;
end;
/
create or replace procedure FBH_2B_SO_ID_DTd(
    b_so_id_dt number,b_ma_dvi out varchar2,b_so_id out number)
as
begin
-- Dan - Tra so id dau qua so_id_dt
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_2b_ds where so_id_dt=b_so_id_dt;
if b_so_id<>0 then b_so_id:=FBH_2B_SO_IDd(b_ma_dvi,b_so_id); end if;
end;
/
create or replace procedure FBH_2B_HD_SO_ID_DT(
    b_gcn varchar2,b_ngay number,b_ma_dvi out varchar2,b_so_id out number,b_so_id_dt out number)
as
begin
-- Dan - Tra so id qua GCN
select nvl(min(so_id_dt),0) into b_so_id_dt from bh_2b_ds where gcn=b_gcn;
if b_so_id_dt<>0 then
    FBH_2B_SO_ID_DT(b_so_id_dt,b_ma_dvi,b_so_id,b_ngay);
else
    b_so_id:=0; b_ma_dvi:='';
end if;
end;
/
create or replace procedure FBH_2B_HD_SO_ID_DTd(
    b_gcn varchar2,b_ma_dvi out varchar2,b_so_id out number,b_so_id_dt out number)
as
begin
-- Dan - Tra so id dau qua GCN
select min(ma_dvi),nvl(min(so_id),0),nvl(min(so_id_dt),0) into b_ma_dvi,b_so_id,b_so_id_dt from bh_2b_ds where gcn=b_gcn;
if b_so_id<>0 then b_so_id:=FBH_2B_SO_IDd(b_ma_dvi,b_so_id); end if;
end;
/
create or replace function FBH_2B_NT_TIEN(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(5); b_so_idB number;
begin
-- Dan - Tra loai tien bao hiem
b_so_idB:=FBH_2B_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select nvl(min(nt_tien),'VND') into b_kq from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_idB;
return b_kq;
end;
/
create or replace function FBH_2B_NT_PHI(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(5); b_so_idB number;
begin
-- Dan - Tra loai tien phi
b_so_idB:=FBH_2B_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select nvl(min(nt_phi),'VND') into b_kq from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_idB;
return b_kq;
end;
/
create or replace function FBH_2B_MA_DT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay number:=30000101) return varchar2
AS
    b_kq varchar2(20); b_so_idB number;
begin
-- viet anh -- Tra bien
b_so_idB:=FBH_2B_SO_IDt(b_ma_dvi,b_so_id,b_ngay);
if b_so_idB<>0 then
    select nvl(min(loai_xe),' ') into b_kq from bh_2b_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id=b_so_id_dt;
else
    select nvl(min(loai_xe),' ') into b_kq from bh_2bB_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id=b_so_id_dt;
end if;
return b_kq;
end;
/
create or replace function FBH_2B_CAP(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Dan - Tra ngay cap
select min(ngay_cap) into b_kq from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_2B_NGAY(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Dan - Tra nhap
select nvl(min(ngay_ht),0) into b_kq from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_2B_TTRANG(
    b_ma_dvi varchar2,b_so_id number,b_dk varchar2:='K',b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(1); b_i1 number;
begin
-- Dan - Tra ngay cap
select nvl(min(ttrang),'X') into b_kq from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_kq<>'X' and b_dk='C' then
    select count(*) into b_i1 from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay;
    if b_i1<>0 then b_kq:='H'; end if;
end if;
return b_kq;
end;
/
create or replace procedure PBH_2B_SO_ID_KTRA(b_ma_dvi varchar2,b_so_id_g number,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Kiem tra SO_ID moi nhap
if b_so_id_g=0 then b_loi:=''; return; end if;
select count(*) into b_i1 from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_id_g and ttrang<>'D';
if b_i1<>0 then b_loi:='loi:Hop dong cu da xoa hoac chua ky:loi'; return; end if;
select count(*) into b_i1 from bh_2b where ma_dvi=b_ma_dvi and so_id_g=b_so_id_g and kieu_hd<>'K';
if b_i1<>0 then b_loi:='loi:Hop dong cu da co bo sung, sua doi:loi'; return; end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_2B_BPHI_CTm(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_so_id number;
    b_nhom varchar2(10); b_bh_tbo varchar2(1); b_cdich varchar2(10); b_goi varchar2(10);
    b_ttai number; b_so_cn number; b_loai_xe varchar2(500); b_nhom_xe varchar2(500); b_gia number;b_tuoi number;
    b_ma_sp varchar2(10); b_md_sd varchar2(500); b_nv_bh varchar2(1); b_lh_bh varchar2(5);
    b_dong varchar2(500); b_dco varchar2(10); b_ngay_hl number;
    cs_dk clob:=''; cs_txt clob:='';

begin
-- Dan - Tra dieu khoan mo rong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','2B','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_2B_BPHI_TSOm(
    b_oraIn,b_nhom,b_bh_tbo,b_cdich,b_goi,b_ttai,b_so_cn,b_loai_xe,b_nhom_xe,b_gia,b_tuoi,
    b_ma_sp,b_md_sd,b_nv_bh,b_dong,b_dco,b_ngay_hl,b_lh_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
FBH_2B_BPHI_SO_ID(
    b_nhom,'M',b_bh_tbo,b_md_sd,b_ma_sp,b_cdich,b_goi,b_loai_xe,b_nhom_xe,b_dong,b_dco,b_ttai,b_so_cn,b_tuoi,b_gia,
    b_ngay_hl,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object('nv' value 'M',ma,cap,ma_dk,lh_nv,t_suat,'ptB' value pt) order by bt returning clob)
    into cs_dk from bh_2b_phi_dk where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into cs_txt
    from bh_2b_phi_txt where so_id=b_so_id and loai='dt_dk';
select json_object('dt_dk' value cs_dk,'txt' value cs_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_2B_BPHI_DKm(
    b_so_id number,b_ma varchar2,b_tien number,
    b_lh_bh varchar2,b_pt out number,b_phi out number,b_loi out varchar2)
AS
    b_i1 number; b_tienM number;
begin
-- Dan - Lay %phi theo khoang muc trach nhiem
b_loi:='loi:Loi xu ly FBH_2B_BPHI_DKm:loi';
select count(*),nvl(max(tien),0) into b_i1,b_tienM from bh_2b_phi_dk where
    so_id=b_so_id and ma=b_ma and lh_bh=b_lh_bh and tien<=b_tien;
if b_i1=0 then b_loi:='loi:Khong tim duoc ty le phi theo muc trach nhiem:loi'; return; end if;
select nvl(max(pt),0),nvl(max(phi),0) into b_pt,b_phi from bh_2b_phi_dk
    where so_id=b_so_id and ma=b_ma and lh_bh=b_lh_bh and tien=b_tienM;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
CREATE OR REPLACE procedure PBH_2B_BS(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_so_idD number;
    b_ma_dvi varchar2(10); b_so_id number; b_so_id_dt number; cs_lke clob;
begin
-- Dan - Liet ke sua doi theo doi tuong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','2B','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id,so_id_dt');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id,b_so_id_dt using b_oraIn;
if b_so_id=0 then b_loi:='loi:GCN/Hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
b_so_idD:=FBH_2B_SO_IDd(b_ma_dvi,b_so_id);
select JSON_ARRAYAGG(json_object(ngay_ht,so_hd,gcn) order by ngay_ht desc,so_hd desc,gcn desc returning clob) into cs_lke from
        (select distinct a.ngay_ht,a.so_hd,b.gcn from bh_2b a,bh_2b_ds b
        where a.ma_dvi=b_ma_dvi and a.so_id_d=b_so_idD and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id and b.so_id_dt=b_so_id_dt);
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_2B_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10);
    b_ngay_ht number; b_nv varchar2(1); b_klk varchar2(1); b_tu number; b_den number;
    b_dong number; cs_lke clob;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','2B','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,nv,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_nv,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_2b where ma_dvi=b_ma_dvi and 
        ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_2b where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','2B','X')='C' then
	if b_klk='P' then
		b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
		select count(*) into b_dong from bh_2b where ma_dvi=b_ma_dvi and
			ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong;
		PKH_LKE_TRANG(b_dong,b_tu,b_den);
		select JSON_ARRAYAGG(obj returning clob) into cs_lke from
			(select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_2b  where
				ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong order by so_hd)
			where sott between b_tu and b_den;
	else
		select count(*) into b_dong from bh_2b where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv;
		PKH_LKE_TRANG(b_dong,b_tu,b_den);
		select JSON_ARRAYAGG(obj returning clob) into cs_lke from
			(select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_2b  where
				ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv order by so_hd)
			where sott between b_tu and b_den;
	end if;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_2B_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10); b_so_hd varchar2(20);
    b_so_id number; b_ngay_ht number; b_nv varchar2(1); b_klk varchar2(1); b_trangKt number; b_tu number; b_den number;
    b_trang number; b_dong number; cs_lke clob;
begin
-- Dan - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','2B','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,nv,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_nv,b_klk,b_trangKt using b_oraIn;
b_so_hd:=FBH_2B_SO_HD(b_ma_dvi,b_so_id);
if b_so_hd is null then b_loi:='loi:GCN, hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
if b_klk ='N' then
    select count(*) into b_dong from bh_2b where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_2b where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_2b  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','2B','X')<>'C' then
	if b_klk='P' then
		b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
		select count(*) into b_dong from bh_2b where ma_dvi=b_ma_dvi and
			ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong;
		select nvl(min(sott),b_dong) into b_tu from
			(select so_hd,rownum sott from bh_2b where
				ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong order by so_hd)
			where so_hd>=b_so_hd;
		PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
		select JSON_ARRAYAGG(obj returning clob) into cs_lke from
			(select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_2b  where
				ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong order by so_hd)
			where sott between b_tu and b_den;
	else
		select count(*) into b_dong from bh_2b where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv;
		select nvl(min(sott),b_dong) into b_tu from
			(select so_hd,rownum sott from bh_2b where
				ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv order by so_hd)
			where so_hd>=b_so_hd;
		PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
		select JSON_ARRAYAGG(obj returning clob) into cs_lke from
			(select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_2b  where
				ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv order by so_hd)
			where sott between b_tu and b_den;
	end if;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_2B_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_so_id number; b_so_hd varchar2(20);b_nv varchar2(1);
    b_lenh varchar2(2000); b_loi varchar2(100);
begin
-- Dan - Hoi so ID qua so hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','2B','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hd,nv');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_nv using b_oraIn;
b_so_id:=FBH_2B_SO_ID(b_ma_dvi,b_so_hd,b_nv);
if b_so_id=0 then b_loi:='loi:So hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_2B_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh varchar2,b_loi out varchar2)
AS
    b_i1 number; b_so_hdL varchar(10); b_so_idK number; b_ttrang varchar2(1); b_ksoat varchar2(20); b_nsdC varchar2(20);
begin
-- Dan - Xoa
b_loi:='loi:Loi xu ly PBH_2B_XOA_XOA:loi';
select count(*) into b_i1 from bh_2b where so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select so_hdl,so_id_kt,ttrang,ksoat,nsd into b_so_hdL,b_so_idK,b_ttrang,b_ksoat,b_nsdC
    from bh_2b where so_id=b_so_id;
if b_so_idK>0 then b_loi:='loi:Khong sua, xoa phuc hoi da hach toan ke toan:loi'; return; end if;
if b_nsdC<>b_nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
if trim(b_ksoat) is not null and b_ksoat<>b_nsd then b_loi:='loi:Khong sua, xoa GCN, hop dong da kiem soat:loi'; return; end if;
select count(*) into b_i1 from bh_2b where ma_dvi=b_ma_dvi and so_id_g=b_so_id;
if b_i1<>0 then b_loi:='loi:Khong sua, xoa GCN, hop dong da tao SDBS:loi'; return; end if;
if b_ttrang in('T','D') then
    PBH_HD_GOC_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi,b_nh);
    if b_loi is not null then return; end if;
end if;
b_loi:='loi:Loi xoa Table bh_2b:loi';
delete bh_hd_goc_ttindt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_2b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_2b_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_2b_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_2b_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_2b_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_ttrang='D' and b_so_hdL='P' then
    PBH_2B_DON(b_ma_dvi,b_so_id,'X',b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_2B_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Dan - Xoa GCN
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','2B','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_2B_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'X',b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_2B_HDBS(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma_dvi varchar2(10); b_so_id number; b_so_idD number;
    b_dong number; cs_lke clob:='';
begin
-- Dan - Liet ke sua doi bo sung
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','2B','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_so_idD:=FBH_2B_SO_IDd(b_ma_dvi,b_so_id);
if b_so_idD<>0 then
    select count(*) into b_dong from bh_2b where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hd,ttoan,ttrang,ma_dvi,so_id,
           'ma_sdbs' value PKH_TEN_TENl(FBH_2B_MA_SDBS(so_id))
    ) order by so_id desc returning clob)
        into cs_lke from bh_2b where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_2B_NV(b_ma_dvi varchar2,b_so_id number,
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
select nt_tien,nt_phi,nv into b_nt_tien,b_nt_phi,b_nv from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_id;
select a.loai_xe,b_nt_tien,b_nt_phi,b.lh_nv,b.t_suat,sum(b.tien),sum(b.phi),sum(b.thue),sum(b.ttoan),min(b.pt),max(b.ptG)
    bulk collect into a_ma_dt,a_nt_tien,a_nt_phi,a_lh_nv,a_t_suat,a_tien,a_phi,a_thue,a_ttoan,a_pt,a_ptG
    from bh_2b_ds a,bh_2b_dk b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and
    b.ma_dvi=b_ma_dvi and b.so_id=b_so_id and b.so_id_dt=a.so_id_dt and lh_nv<>' '
    group by a.loai_xe,b.lh_nv,b.t_suat having sum(b.tien)<>0 or sum(b.ttoan)<>0;
    select a.so_id_dt,a.loai_xe,b_nt_tien,b_nt_phi,b.lh_nv,b.t_suat,sum(b.tien),sum(b.phi),sum(b.thue),sum(b.ttoan),min(b.pt),max(b.ptG)
        bulk collect into a_so_id_dt,a_dt_ma_dt,a_dt_nt_tien,a_dt_nt_phi,a_dt_lh_nv,a_dt_t_suat,
        a_dt_tien,a_dt_phi,a_dt_thue,a_dt_ttoan,a_dt_pt,a_dt_ptG
        from bh_2b_ds a,bh_2b_dk b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and
        b.ma_dvi=b_ma_dvi and b.so_id=b_so_id and b.so_id_dt=a.so_id_dt and lh_nv<>' '
        group by a.so_id_dt,a.loai_xe,b.lh_nv,b.t_suat having sum(b.tien)<>0 or sum(b.ttoan)<>0;
select ngay,b_nt_phi,tien bulk collect into tt_ngay,tt_ma_nt,tt_tien from bh_2b_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure pbh_2b_don(b_ma_dvi varchar2,b_so_id number,b_nv varchar2,b_loi out varchar2)
AS
    b_i1 number; b_ma_dl varchar2(20):=' '; b_ks varchar2(1); a_ds_ct pht_type.a_clob;
    b_loai_ac varchar(20);b_mau varchar2(200);b_lenh varchar2(1000);
    dt_ct_txt clob; dt_ds_txt clob;
    a_mau_ac pht_type.a_var;a_loai_ac pht_type.a_var;a_gcn_m pht_type.a_var; a_gcn_c pht_type.a_var; a_gcn pht_type.a_var;  r_hd bh_2b%rowtype;
begin
-- Dan - Kiem soat an chi
b_loi:='loi:So an chi khong hop le:loi';
select count(*) into b_i1 from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select * into r_hd from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_ks:=FBH_HT_THUE_TS(b_ma_dvi,r_hd.ngay_ht,'gcn_xe');
if b_ks is null then b_loi:='loi:Chua khai bao kieu theo doi an chi:loi'; return; end if;
if r_hd.kieu_kt<>'T' then b_ma_dl:=r_hd.ma_kt; end if;
if r_hd.nv='G' then
  select txt into a_ds_ct(1) from bh_2b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
  b_lenh:=FKH_JS_LENH('loai_ac,mau_ac,gcn');

  EXECUTE IMMEDIATE b_lenh into a_loai_ac(1),a_mau_ac(1),a_gcn(1) using a_ds_ct(1);
else
  select count(1) into b_i1 from bh_2b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds_txt';
  if b_i1 > 0 then
     select FKH_JS_BONH(txt) into dt_ds_txt from bh_2b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds_txt';
  end if;
  b_lenh:=FKH_JS_LENH('ds_ct');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_ct using dt_ds_txt;
  if a_ds_ct.count=0 then b_loi:='loi:Nhap danh sach xe:loi'; return; end if;
  for b_i1 in 1..a_ds_ct.count loop
    b_lenh:=FKH_JS_LENH('loai_ac,mau_ac,gcn');
    EXECUTE IMMEDIATE b_lenh into a_loai_ac(b_i1),a_mau_ac(b_i1),a_gcn(b_i1) using a_ds_ct(b_i1);
    --PBH_LAY_SOAC(b_ma_dvi,a_loai_ac(b_i1),a_mau_ac(b_i1),a_gcn(b_i1),b_loi);
  end loop;
end if;
for b_lp in 1..a_loai_ac.count loop
  if a_loai_ac(b_lp) is not null then
    a_gcn_m(b_lp):=a_loai_ac(b_lp)||'>'||a_mau_ac(b_lp);
    a_gcn_c(b_lp):=nvl(substr(a_gcn(b_i1), 1, length(a_gcn(b_i1)) - 7), ' ');
  end if;
end loop;
PHD_PH_DON(b_ma_dvi,b_nv,r_hd.ngay_ht,b_so_id,a_gcn_m,a_gcn_c,a_gcn,r_hd.ma_cb,b_ma_dl,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_2B_VACH(b_nv varchar2,b_gcn out varchar2,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Tra so trong chuoi dang ky
b_loi:='loi:Loi xin so GCN:loi';
b_gcn:=' ';
select count(*) into b_i1 from bh_2b_vach where nv=b_nv;
if b_i1<>0 then
    select stt into b_i1 from bh_2b_vach where nv=b_nv for update wait 10;
    if b_i1<>0 then
        b_i1:=b_i1+1;
        update bh_2b_vach set stt=b_i1 where nv=b_nv;
        b_gcn:='EB'||to_char(sysdate,'yy')||to_char(b_i1);
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_2BG_PHIb(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_i2 number; b_i3 number; b_i4 number; b_iX number; b_lenh varchar2(1000);
    dt_ct clob; dt_dk clob; dt_dkbs clob;
    b_tp number:=0;
    b_so_hdG varchar2(20); b_ngay_hl number; b_ngay_kt number; b_ngay_cap number;
    b_c_thue varchar2(1);
    b_ngay_hlC number; b_ngay_ktC number;
    b_phi number:=0; b_phiB number:=0; b_tien number; b_so_idG number:=0; b_so_id_dt number;
    b_tien_vcx number; b_tienG_vcx number; b_ma_dkc_vcx varchar2(20); -- tien vcx -- tien goc vcx

    dk_ma pht_type.a_var;dk_ten pht_type.a_nvar;dk_tc pht_type.a_var;
    dk_ma_ct pht_type.a_var;dk_kieu pht_type.a_var;
    dk_lkeM pht_type.a_var;dk_lkeP pht_type.a_var;dk_lkeB pht_type.a_var;
    dk_luy pht_type.a_var;
    dk_ma_dk pht_type.a_var;dk_ma_dkC pht_type.a_var;dk_lh_nv pht_type.a_var;dk_t_suat pht_type.a_num;
    dk_cap pht_type.a_num;
    dk_tien pht_type.a_num;dk_pt pht_type.a_num;dk_phi pht_type.a_num;
    dk_thue pht_type.a_num;dk_ttoan pht_type.a_num;dk_nv pht_type.a_var;
    dk_ptB pht_type.a_num;dk_phiB pht_type.a_num;dk_bt pht_type.a_num;
    dk_pp pht_type.a_var;dk_ptk pht_type.a_var;dk_gvu pht_type.a_var;
    dk_maG pht_type.a_var; dk_tienG pht_type.a_num; dk_ptG pht_type.a_num;
    dk_phiG pht_type.a_num;
    
    dkbs_ma pht_type.a_var;dkbs_ten pht_type.a_nvar;dkbs_tc pht_type.a_var;
    dkbs_ma_ct pht_type.a_var;dkbs_kieu pht_type.a_var;
    dkbs_lkeM pht_type.a_var;dkbs_lkeP pht_type.a_var;dkbs_lkeB pht_type.a_var;
    dkbs_luy pht_type.a_var;
    dkbs_ma_dk pht_type.a_var;dkbs_ma_dkC pht_type.a_var;dkbs_lh_nv pht_type.a_var;dkbs_t_suat pht_type.a_num;
    dkbs_cap pht_type.a_num;
    dkbs_tien pht_type.a_num;dkbs_pt pht_type.a_num;dkbs_phi pht_type.a_num;
    dkbs_thue pht_type.a_num;dkbs_ttoan pht_type.a_num;dkbs_nv pht_type.a_var;
    dkbs_ptB pht_type.a_num;dkbs_phiB pht_type.a_num;dkbs_bt pht_type.a_num;
    dkbs_pp pht_type.a_var;dkbs_ptk pht_type.a_var;dkbs_gvu pht_type.a_var;
    dkbs_maG pht_type.a_var; dkbs_tienG pht_type.a_num; dkbs_ptG pht_type.a_num;
    dkbs_phiG pht_type.a_num;
    
    cs_dk clob; cs_dkbs clob; b_dk_txt clob; b_dkbs_txt clob;
begin
-- viet anh - tinh phi prorata
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','2B','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_dkbs');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_dkbs using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_dkbs);
b_lenh:=FKH_JS_LENH('so_id_dt,so_hd_g,ngay_hl,ngay_kt,ngay_cap');
EXECUTE IMMEDIATE b_lenh into b_so_id_dt,b_so_hdG,b_ngay_hl,b_ngay_kt,b_ngay_cap using dt_ct;
b_so_id_dt:=nvl(b_so_id_dt,0);
if b_so_hdG<>' ' then
    b_so_idG:=FBH_2B_SO_ID(b_ma_dvi,b_so_hdG);
    if b_so_idG=0 then b_loi:='loi:Hop dong goc da xoa:loi'; return; end if;
end if;
FBH_2B_PHI(dt_ct,dt_dk,dt_dkbs,
  dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_lkeM,dk_lkeP,dk_lkeB ,
  dk_luy,dk_ma_dk ,dk_ma_dkC ,dk_lh_nv ,dk_t_suat,dk_cap,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,
  dk_nv,dk_ptB,dk_phiB,dk_bt,dk_pp,dk_ptk,dk_gvu,
  dkbs_ma,dkbs_ten,dkbs_tc,dkbs_ma_ct,dkbs_kieu,dkbs_lkeM,dkbs_lkeP,dkbs_lkeB ,
  dkbs_luy,dkbs_ma_dk ,dkbs_ma_dkC ,dkbs_lh_nv ,dkbs_t_suat,dkbs_cap,dkbs_tien,dkbs_pt,dkbs_phi,dkbs_thue,dkbs_ttoan,
  dkbs_nv,dkbs_ptB,dkbs_phiB,dkbs_bt,dkbs_pp,dkbs_ptk,dkbs_gvu,b_tp,b_loi,b_tien_vcx,b_ma_dkc_vcx);
if b_loi is not null then return; end if;
if b_so_idG<>0 and b_ngay_hl<b_ngay_cap then
    select ngay_hl,ngay_kt into b_ngay_hlC,b_ngay_ktC from bh_2b_ds
        where ma_dvi=b_ma_dvi and so_id=b_so_idG and b_so_id_dt in (0,so_id_dt);
    b_i1:=FKH_KHO_NGSO(b_ngay_cap,b_ngay_ktC)/FKH_KHO_NGSO(b_ngay_hlC,b_ngay_ktC);
    b_i2:=FKH_KHO_NGSO(b_ngay_cap,b_ngay_kt)/FKH_KHO_NGSO(b_ngay_hl,b_ngay_kt);
    b_i1:=round(b_i1,2); b_i2:=round(b_i2,2);
    -- viet anh -- tinh phi cho dk cu
    select ma,tien,pt,phi bulk collect into dk_maG,dk_tienG,dk_ptG,dk_phiG from bh_2b_dk
        where ma_dvi=b_ma_dvi and so_id=b_so_idG and b_so_id_dt in (0,so_id_dt) and lh_bh='C' order by bt;
    for b_lp in 1..dk_maG.count loop
        b_iX:=b_lp; b_tien:=0;
        for b_lp1 in reverse 1..b_iX loop
            if dk_tienG(b_lp1)<>0 then b_tien:=dk_tienG(b_lp1); exit; end if;
        end loop;
        b_iX:=FKH_ARR_VTRI(dk_ma,dk_maG(b_lp));
        if b_iX=0 then continue; end if;
        if dk_nv(b_iX)='B' and dk_ma_ct(b_iX)=' ' then 
          b_tien:=dk_phiG(b_iX); 
          dk_ptG(b_iX):=100;
        end if;
        if dk_nv(b_iX) = 'V' then b_tienG_vcx:=b_tien; end if;
        if b_tien=0 then continue; end if;
        b_phi:=b_tien*dk_ptG(b_lp)/100;
        b_phi:=dk_phiG(b_lp)-round(b_phi*b_i1,b_tp);            -- Phi da dung
        dk_phi(b_iX):=b_phi+round(dk_phi(b_iX)*b_i2,b_tp);      -- Phi con lai: round(dk_phi(b_iX)*b_i2,b_tp);
    end loop;
    -- tinh phi cho dk moi them
    for b_i3 in 1..dk_ma.count loop
        select count(*) into b_i4 from bh_2b_dk where ma_dvi=b_ma_dvi and so_id=b_so_idG and b_so_id_dt in (0,so_id_dt) 
                        and lh_bh='C' and ma=dk_ma(b_i3);
        if b_i4=0 then 
            b_phi:=0;                                                 -- Phi da dung
            dk_phi(b_i3):=b_phi+round(dk_phi(b_i3)*b_i2,b_tp);        -- Phi con lai: round(dk_phi(b_i3)*b_i2,b_tp);
        end if;
    end loop;
    -- tinh phi cho dkbs cu
    select ma,tien,pt,phi bulk collect into dkbs_maG,dkbs_tienG,dkbs_ptG,dkbs_phiG from bh_2b_dk
        where ma_dvi=b_ma_dvi and so_id=b_so_idG and b_so_id_dt in (0,so_id_dt) and lh_bh='M' order by bt;
    for b_lp in 1..dkbs_maG.count loop
        b_iX:=b_lp; b_tien:=0;
        for b_lp1 in reverse 1..b_iX loop
          if dkbs_tienG(b_lp1)<>0 then b_tien:=dkbs_tienG(b_lp1); exit; end if;
        end loop;
        b_iX:=FKH_ARR_VTRI(dkbs_ma,dkbs_maG(b_lp));
        if b_iX <> 0 and dkbs_nv(b_iX)='V' and dkbs_lkeM(b_iX)<>'G' and dkbs_ma_dkc(b_iX)=b_ma_dkc_vcx then
            b_phi:=b_tienG_vcx*dkbs_ptG(b_lp)/100;
            b_phi:=dkbs_phiG(b_lp)-round(b_phi *b_i1,b_tp);
            dkbs_phi(b_iX):=b_phi+round(dkbs_phi(b_iX)*b_i2,b_tp);
        else
          if b_iX=0 or b_tien=0 then continue; end if;
          b_phi:=b_tien*dkbs_ptG(b_lp)/100;
          b_phi:=dkbs_phiG(b_lp)-round(b_phi*b_i1,b_tp);             -- Phi da dung
          dkbs_phi(b_iX):=b_phi+round(dkbs_phi(b_iX)*b_i2,b_tp);     -- Phi con lai: round(dkbs_phi(b_iX)*b_i2,b_tp);
        end if;
    end loop;
    -- tinh phi cho dkbs moi them
    for b_i3 in 1..dkbs_ma.count loop
        select count(*) into b_i4 from bh_2b_dk where ma_dvi=b_ma_dvi and so_id=b_so_idG and b_so_id_dt in (0,so_id_dt) 
                        and lh_bh='M' and ma=dkbs_ma(b_i3);
        if b_i4=0 then 
          b_phi:=0;                                                     -- Phi da dung
          dkbs_phi(b_i3):=b_phi+round(dkbs_phi(b_i3)*b_i2,b_tp);        -- Phi con lai: round(dkbs_phi(b_i3)*b_i2,b_tp);
        end if;
    end loop;
end if;
if b_c_thue<>'C' then
    for b_lp in 1..dk_ma.count loop dk_thue(b_lp):=0; end loop;
    for b_lp in 1..dkbs_ma.count loop dkbs_thue(b_lp):=0; end loop;
else
    for b_lp in 1..dk_ma.count loop 
      if dk_pp(b_lp)='DG' and dk_pt(b_lp) > 0 then dk_phi(b_lp):=dk_pt(b_lp);end if;
      dk_thue(b_lp):=round(dk_phi(b_lp)*dk_t_suat(b_lp)/100,b_tp); 
    end loop;
    for b_lp in 1..dkbs_ma.count loop 
      if dkbs_pp(b_lp)='DG' and dkbs_pt(b_lp) > 0 then dkbs_phi(b_lp):=dkbs_pt(b_lp);end if;
      dkbs_thue(b_lp):=round(dkbs_phi(b_lp)*dkbs_t_suat(b_lp)/100,b_tp); 
    end loop;
end if;
FBH_2BG_PHIt(b_tp,dk_ma,dk_ma_ct,dk_lkeP,dk_cap,dk_phi,dk_thue,dk_ttoan,b_loi);
if b_loi is not null then return; end if;
FBH_2BG_PHIt(b_tp,dkbs_ma,dkbs_ma_ct,dkbs_lkeP,dkbs_cap,dkbs_phi,dkbs_thue,dkbs_ttoan,b_loi);
if b_loi is not null then return; end if;
b_oraOut:='';
for b_lp in 1..dk_ma.count loop
    select json_object('ma' value dk_ma(b_lp),'ten' value dk_ten(b_lp),'tc' value dk_tc(b_lp),'ma_ct' value dk_ma_ct(b_lp),
    'kieu' value dk_kieu(b_lp),'lkeM' value dk_lkeM(b_lp),'lkeP' value dk_lkeP(b_lp),'lkeB' value dk_lkeB(b_lp),
    'luy' value dk_luy(b_lp),'ma_dk' value dk_ma_dk(b_lp),'ma_dkC' value dk_ma_dkC(b_lp),
    'lh_nv' value dk_lh_nv(b_lp),'t_suat' value dk_t_suat(b_lp),'cap' value dk_cap(b_lp),
    'pp' value dk_pp(b_lp),'ptK' value dk_ptk(b_lp),'bt' value dk_bt(b_lp),
    'tien' value dk_tien(b_lp),'pt' value dk_pt(b_lp),'nv' value dk_nv(b_lp),
    'phi' value dk_phi(b_lp),'thue' value dk_thue(b_lp),'gvu' value dk_gvu(b_lp),'ttoan' value dk_ttoan(b_lp),
    'ptB' value dk_ptB(b_lp),'phiB' value dk_phiB(b_lp) returning clob) into b_dk_txt from dual;
    if b_lp>1 then cs_dk:=cs_dk||','; end if;
    cs_dk:=cs_dk||b_dk_txt;
end loop;
if cs_dk is not null then cs_dk:='['||cs_dk||']'; end if;
for b_lp in 1..dkbs_ma.count loop
    select json_object('ma' value dkbs_ma(b_lp),'ten' value dkbs_ten(b_lp),'tc' value dkbs_tc(b_lp),'ma_ct' value dkbs_ma_ct(b_lp),
    'kieu' value dkbs_kieu(b_lp),'lkeM' value dkbs_lkeM(b_lp),'lkeP' value dkbs_lkeP(b_lp),'lkeB' value dkbs_lkeB(b_lp),
    'luy' value dkbs_luy(b_lp),'ma_dk' value dkbs_ma_dk(b_lp),'ma_dkC' value dkbs_ma_dkC(b_lp),
    'lh_nv' value dkbs_lh_nv(b_lp),'t_suat' value dkbs_t_suat(b_lp),'cap' value dkbs_cap(b_lp),
    'pp' value dkbs_pp(b_lp),'ptK' value dkbs_ptk(b_lp),'bt' value dkbs_bt(b_lp),
    'tien' value dkbs_tien(b_lp),'pt' value dkbs_pt(b_lp),'nv' value dkbs_nv(b_lp),
    'phi' value dkbs_phi(b_lp),'thue' value dkbs_thue(b_lp),'gvu' value dkbs_gvu(b_lp),'ttoan' value dkbs_ttoan(b_lp),
    'ptB' value dkbs_ptB(b_lp),'phiB' value dkbs_phiB(b_lp) returning clob) into b_dkbs_txt from dual;
    if b_lp>1 then cs_dkbs:=cs_dkbs||','; end if;
    cs_dkbs:=cs_dkbs||b_dkbs_txt;
end loop;
if cs_dkbs is not null then cs_dkbs:='['||cs_dkbs||']'; end if;
select json_object('dt_dk' value cs_dk,'dt_dkbs' value cs_dkbs returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_2B_PHI(
    dt_ct clob,dt_dk clob,dt_dkbs clob,
    dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,dk_tc out pht_type.a_var,
    dk_ma_ct out pht_type.a_var,dk_kieu out pht_type.a_var,
    dk_lkeM out pht_type.a_var,dk_lkeP out pht_type.a_var,dk_lkeB out pht_type.a_var,
    dk_luy out pht_type.a_var,dk_ma_dk out pht_type.a_var,dk_ma_dkC out pht_type.a_var,
    dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,dk_cap out pht_type.a_num,
    dk_tien out pht_type.a_num,dk_pt out pht_type.a_num,dk_phi out pht_type.a_num,
    dk_thue out pht_type.a_num,dk_ttoan out pht_type.a_num,dk_nv out pht_type.a_var,
    dk_ptB out pht_type.a_num,dk_phiB out pht_type.a_num,dk_bt out pht_type.a_num,
    dk_pp out pht_type.a_var,dk_ptk out pht_type.a_var,dk_gvu out pht_type.a_var,
    
    dkbs_ma out pht_type.a_var,dkbs_ten out pht_type.a_nvar,dkbs_tc out pht_type.a_var,
    dkbs_ma_ct out pht_type.a_var,dkbs_kieu out pht_type.a_var,
    dkbs_lkeM out pht_type.a_var,dkbs_lkeP out pht_type.a_var,dkbs_lkeB out pht_type.a_var,
    dkbs_luy out pht_type.a_var,dkbs_ma_dk out pht_type.a_var,dkbs_ma_dkC out pht_type.a_var,
    dkbs_lh_nv out pht_type.a_var,dkbs_t_suat out pht_type.a_num,dkbs_cap out pht_type.a_num,
    dkbs_tien out pht_type.a_num,dkbs_pt out pht_type.a_num,dkbs_phi out pht_type.a_num,
    dkbs_thue out pht_type.a_num,dkbs_ttoan out pht_type.a_num,dkbs_nv out pht_type.a_var,
    dkbs_ptB out pht_type.a_num,dkbs_phiB out pht_type.a_num,dkbs_bt out pht_type.a_num,
    dkbs_pp out pht_type.a_var,dkbs_ptk out pht_type.a_var,dkbs_gvu out pht_type.a_var,
    b_tp out number,b_loi out varchar2,b_tien_vcx out number, b_ma_dkc_vcx out varchar2
    )
AS
    b_lenh varchar2(1000); b_nt_phi varchar2(5); b_nt_tien varchar2(5);
    b_tygia number:=1; b_kho number:=1; b_kt number;
    b_ttai number; b_so_cn number; b_so_ch_bh number;b_ngay_hl number; b_ngay_kt number;
    b_ktruC varchar2(100); b_ktru number;
begin
-- viet anh - Tinh phi
b_loi:='loi:Loi xu ly FBH_2B_PHI:loi';
b_lenh:=FKH_JS_LENH('nt_phi,nt_tien,tygia,ttai_bh,so_cn_bh,ngay_hl,ngay_kt,ktru');
EXECUTE IMMEDIATE b_lenh into b_nt_phi,b_nt_tien,b_tygia,b_ttai,b_so_cn,b_ngay_hl,b_ngay_kt,b_ktruC using dt_ct;
if b_tygia is null or b_tygia=0 then b_tygia:=1; end if;
if b_nt_phi<>'VND' then b_tp:=2; end if;
if b_tp is null then b_tp:=0; end if;
b_ktru:=PKH_LOC_CHU_SO(PKH_MA_TENl(b_ktruC),'F','T');
b_lenh:=FKH_JS_LENH('ma,ten,tien,ptb,pp,pt,phi,thue,gvu,ttoan,cap,tc,ma_ct,ma_dk,ma_dkc,kieu,lh_nv,t_suat,phib,lkem,lkep,lkeb,ptk,luy,nv,bt');
EXECUTE IMMEDIATE b_lenh bulk collect into dk_ma,dk_ten,dk_tien,dk_ptB,dk_pp,dk_pt,dk_phi,dk_thue,dk_gvu,dk_ttoan,dk_cap,dk_tc,dk_ma_ct,
        dk_ma_dk,dk_ma_dkC,dk_kieu,dk_lh_nv,dk_t_suat,dk_phiB,dk_lkeM,dk_lkeP,dk_lkeB,dk_ptk,dk_luy,dk_nv,dk_bt using dt_dk;
if trim(dt_dkbs) is not null then
   EXECUTE IMMEDIATE b_lenh bulk collect into dkbs_ma,dkbs_ten,dkbs_tien,dkbs_ptB,dkbs_pp,dkbs_pt,dkbs_phi,dkbs_thue,dkbs_gvu,dkbs_ttoan,dkbs_cap,dkbs_tc,dkbs_ma_ct,
        dkbs_ma_dk,dkbs_ma_dkC,dkbs_kieu,dkbs_lh_nv,dkbs_t_suat,dkbs_phiB,dkbs_lkeM,dkbs_lkeP,dkbs_lkeB,dkbs_ptk,dkbs_luy,dkbs_nv,dkbs_bt using dt_dkbs;
end if;
b_kt:=0;
FBH_HD_KHO(b_ngay_hl,b_ngay_kt,b_kho,b_loi);
if b_loi is not null then return; end if;
for b_lp_dk in 1..dk_ma.count loop
  b_kt:=b_kt+1;
  dk_pp(b_lp_dk):=nvl(dk_pp(b_lp_dk),' ');
  -- lay ptB
  PBH_2B_BPHI_PRORATA_PT(dt_ct,dk_nv(b_lp_dk),'C',dk_ma(b_lp_dk),dk_tien(b_lp_dk),b_nt_tien,b_nt_phi,dk_ptB(b_lp_dk),b_loi);
  if b_loi is not null then return; end if;
  if dk_lkeP(b_lp_dk) not in ('T','N','K') then
    if dk_lkeP(b_lp_dk) in ('W','S') then
       b_so_ch_bh:=case
           when dk_lkeP(b_lp_dk)='S' then b_so_cn
           else b_ttai
       end; 
       if dk_tien(b_lp_dk)<>0 then
          if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
             dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) * b_so_ch_bh/b_tygia *b_kho,b_tp);
          elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
             dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) * b_so_ch_bh*b_tygia *b_kho,b_tp);
          else
             dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk)* dk_tien(b_lp_dk) * b_so_ch_bh * b_kho/ 100,b_tp);
          end if;
          if dk_pp(b_lp_dk) = 'DG' and dk_pt(b_lp_dk)>0 then dk_phi(b_lp_dk):=ROUND(dk_pt(b_lp_dk),b_tp);
          elsif dk_pp(b_lp_dk) = 'DP' and dk_tien(b_lp_dk)<>0 and dk_pt(b_lp_dk)<>0 then
               dk_phi(b_lp_dk):=ROUND(dk_pt(b_lp_dk) * dk_tien(b_lp_dk) *b_kho/ 100,b_tp);
          elsif dk_phiB(b_lp_dk)<>0 then
               dk_phi(b_lp_dk):=dk_phiB(b_lp_dk);
            if dk_pp(b_lp_dk) = 'GG' then
                 dk_phi(b_lp_dk):=ROUND((dk_phi(b_lp_dk)-dk_pt(b_lp_dk)),b_tp);
            elsif dk_pp(b_lp_dk) = 'GT' and dk_tien(b_lp_dk)<>0 and dk_pt(b_lp_dk)<>0 then
                 dk_phi(b_lp_dk):= dk_phi(b_lp_dk) - ROUND(dk_pt(b_lp_dk) * b_so_ch_bh * dk_tien(b_lp_dk) *b_kho/ 100,b_tp);
            elsif dk_pp(b_lp_dk) = 'GP' and dk_pt(b_lp_dk)<>0 then
                 dk_phi(b_lp_dk):= dk_phi(b_lp_dk) - ROUND(dk_pt(b_lp_dk)*dk_phiB(b_lp_dk)/ 100,b_tp);
            if dk_phi(b_lp_dk)<0 then dk_phi(b_lp_dk):=0; end if;
            end if;
          elsif dk_phiB(b_lp_dk)=0 then dk_phi(b_lp_dk):=0;
          end if;
          if dk_phiB(b_lp_dk)=0 then dk_phiB(b_lp_dk):=dk_phi(b_lp_dk); end if;
       else 
        dk_phiB(b_lp_dk):=0; dk_phi(b_lp_dk):=0;
       end if;
    else
       if dk_tien(b_lp_dk)<>0 then         
         if dk_ptk(b_lp_dk)<>'P' then
            if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
               dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) /b_tygia *b_kho,b_tp);
            elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
               dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) *b_tygia *b_kho,b_tp);
            else
               dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) *b_kho,b_tp);
            end if;
         elsif dk_ptk(b_lp_dk)<>'T' and dk_tien(b_lp_dk)<>0 and dk_ptB(b_lp_dk)<>0 then
            if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
               dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) *dk_tien(b_lp_dk) /b_tygia *b_kho/ 100,b_tp);
            elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
               dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) *dk_tien(b_lp_dk) *b_tygia *b_kho/ 100,b_tp);
            else
               dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk)* dk_tien(b_lp_dk) *b_kho/ 100,b_tp);
            end if;
         else dk_phiB(b_lp_dk):=0;
         end if;
         if dk_nv(b_lp_dk)='V' then
           b_tien_vcx:=dk_tien(b_lp_dk);
           b_ma_dkc_vcx:=dk_ma_dk(b_lp_dk);
           if b_ktru > 0 and b_ktru < 100 then
              dk_phi(b_lp_dk) := ROUND(dk_phi(b_lp_dk) * (100 - b_ktru) / 100, b_tp);
              dk_phiB(b_lp_dk) := ROUND(dk_phiB(b_lp_dk) * (100 - b_ktru) / 100, b_tp);
           end if;
         end if;
         if dk_pp(b_lp_dk) = 'DG' and dk_pt(b_lp_dk)>0 then dk_phi(b_lp_dk):=ROUND(dk_pt(b_lp_dk),b_tp);
         elsif dk_pp(b_lp_dk) = 'DP' and dk_tien(b_lp_dk)<>0 and dk_pt(b_lp_dk)<>0 then
              dk_phi(b_lp_dk):=ROUND(dk_pt(b_lp_dk) * dk_tien(b_lp_dk) *b_kho/ 100,b_tp);
         elsif dk_phiB(b_lp_dk)<>0 then
              dk_phi(b_lp_dk):=dk_phiB(b_lp_dk);
           if dk_pp(b_lp_dk) = 'GG' then
                dk_phi(b_lp_dk):=ROUND((dk_phi(b_lp_dk)-dk_pt(b_lp_dk)),b_tp);
           elsif dk_pp(b_lp_dk) = 'GT' and dk_tien(b_lp_dk)<>0 and dk_pt(b_lp_dk)<>0 then
                dk_phi(b_lp_dk):= dk_phi(b_lp_dk) - ROUND(dk_pt(b_lp_dk) * dk_tien(b_lp_dk) *b_kho/ 100,b_tp);
           elsif dk_pp(b_lp_dk) = 'GP' and dk_pt(b_lp_dk)<>0 then
                dk_phi(b_lp_dk):= dk_phi(b_lp_dk) - ROUND(dk_pt(b_lp_dk)*dk_phiB(b_lp_dk)/ 100,b_tp);
           if dk_phi(b_lp_dk)<0 then dk_phi(b_lp_dk):=0; end if;
           end if;
         elsif dk_phiB(b_lp_dk)=0 then dk_phi(b_lp_dk):=0;
         end if;
         if dk_phiB(b_lp_dk)=0 then dk_phiB(b_lp_dk):=dk_phi(b_lp_dk); end if;
      elsif dk_tien(b_lp_dk)=0 and dk_ptk(b_lp_dk)<>'P' then
         -- TNDS bat buoc
          dk_phiB(b_lp_dk):=dk_ptB(b_lp_dk); 
          dk_phi(b_lp_dk):=dk_ptB(b_lp_dk); 
         if dk_ptk(b_lp_dk)<>'P' then
            if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
               dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) /b_tygia *b_kho,b_tp);
            elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
               dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) *b_tygia *b_kho,b_tp);
            else
               dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) *b_kho,b_tp);
            end if;
         elsif dk_ptk(b_lp_dk)<>'T' and dk_ptB(b_lp_dk)<>0 then
            if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
               dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) /b_tygia *b_kho/ 100,b_tp);
            elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
               dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) *b_tygia *b_kho/ 100,b_tp);
            else
               dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) *b_kho/ 100,b_tp);
            end if;
         else dk_phiB(b_lp_dk):=0;
         end if;
         if dk_pp(b_lp_dk) = 'DG' and dk_pt(b_lp_dk)>0 then dk_phi(b_lp_dk):=ROUND(dk_pt(b_lp_dk),b_tp);
         elsif dk_pp(b_lp_dk) = 'DP' and dk_tien(b_lp_dk)<>0 and dk_pt(b_lp_dk)<>0 then
              dk_phi(b_lp_dk):=ROUND(dk_pt(b_lp_dk) * dk_tien(b_lp_dk) *b_kho/ 100,b_tp);
         elsif dk_phiB(b_lp_dk)<>0 then
              dk_phi(b_lp_dk):=dk_phiB(b_lp_dk);
           if dk_pp(b_lp_dk) = 'GG' then
                dk_phi(b_lp_dk):=ROUND((dk_phi(b_lp_dk)-dk_pt(b_lp_dk)),b_tp);
           elsif dk_pp(b_lp_dk) = 'GT' and dk_tien(b_lp_dk)<>0 and dk_pt(b_lp_dk)<>0 then
                dk_phi(b_lp_dk):= dk_phi(b_lp_dk) - ROUND(dk_pt(b_lp_dk) * dk_tien(b_lp_dk) *b_kho/ 100,b_tp);
           elsif dk_pp(b_lp_dk) = 'GP' and dk_pt(b_lp_dk)<>0 then
                dk_phi(b_lp_dk):= dk_phi(b_lp_dk) - ROUND(dk_pt(b_lp_dk)*dk_phiB(b_lp_dk)/ 100,b_tp);
           if dk_phi(b_lp_dk)<0 then dk_phi(b_lp_dk):=0; end if;
           end if;
         elsif dk_phiB(b_lp_dk)=0 then dk_phi(b_lp_dk):=0;
         end if;
      else
        dk_phiB(b_lp_dk):=0; dk_phi(b_lp_dk):=0;
      end if;
    end if;
  end if; 
end loop;
for b_lp_dkbs in 1..dkbs_ma.count loop
  b_kt:=b_kt+1;
  dkbs_pp(b_lp_dkbs):=nvl(dkbs_pp(b_lp_dkbs),' ');

  if dkbs_lkeP(b_lp_dkbs) not in ('T','N','K') then
    if dkbs_tien(b_lp_dkbs)<>0 or dkbs_nv(b_lp_dkbs)='V' then
      if dkbs_ptk(b_lp_dkbs)<>'P' then
        if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
           dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs) / b_tygia *b_kho,b_tp);
        elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
           dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs) * b_tygia *b_kho,b_tp);
        else
           dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs) *b_kho,b_tp);
        end if;
     elsif dkbs_ptk(b_lp_dkbs)<>'T' and dkbs_tien(b_lp_dkbs)<>0 and dkbs_ptB(b_lp_dkbs)<>0 then
        if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
           dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs)* dkbs_tien(b_lp_dkbs) / b_tygia *b_kho/ 100,b_tp);
        elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
           dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs)* dkbs_tien(b_lp_dkbs) * b_tygia *b_kho/ 100,b_tp);
        else
           dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs)* dkbs_tien(b_lp_dkbs) *b_kho/ 100,b_tp);          
        end if;
     elsif dkbs_nv(b_lp_dkbs)='V' and dkbs_tien(b_lp_dkbs)=0 and dkbs_ptB(b_lp_dkbs)<>0 then
        if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
           dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs)* dkbs_tien(b_lp_dkbs) / b_tygia *b_kho/ 100,b_tp);
        elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
           dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs)* dkbs_tien(b_lp_dkbs) * b_tygia *b_kho/ 100,b_tp);
        elsif dkbs_ma_dkc(b_lp_dkbs)=b_ma_dkc_vcx then
          -- b_tien_vcx -- tien theo dk cha
           dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs)* b_tien_vcx *b_kho/ 100,b_tp);
        else
           dkbs_phiB(b_lp_dkbs):=ROUND(dkbs_ptB(b_lp_dkbs)* dkbs_tien(b_lp_dkbs) *b_kho/ 100,b_tp);          
        end if;
     else dkbs_phiB(b_lp_dkbs):=0;
     end if;
     if dkbs_ma_dkc(b_lp_dkbs)=b_ma_dkc_vcx then
       if dkbs_pp(b_lp_dkbs) = 'DG' and dkbs_pt(b_lp_dkbs)>0 then
          dkbs_phi(b_lp_dkbs):=ROUND(dkbs_pt(b_lp_dkbs),b_tp);
       elsif dkbs_pp(b_lp_dkbs) = 'DP' and b_tien_vcx<>0 and dkbs_pt(b_lp_dkbs)<>0 then
          dkbs_phi(b_lp_dkbs):=ROUND(dkbs_pt(b_lp_dkbs)*b_tien_vcx *b_kho/ 100,b_tp);
       elsif dkbs_phiB(b_lp_dkbs)<>0 then
          dkbs_phi(b_lp_dkbs):=dkbs_phiB(b_lp_dkbs);
        if dkbs_pp(b_lp_dkbs) = 'GG' then
          dkbs_phi(b_lp_dkbs):=ROUND((dkbs_phi(b_lp_dkbs)-dkbs_pt(b_lp_dkbs)),b_tp);
        elsif dkbs_pp(b_lp_dkbs) = 'GT' and b_tien_vcx<>0 and dkbs_pt(b_lp_dkbs)<>0 then
          dkbs_phi(b_lp_dkbs):= dkbs_phi(b_lp_dkbs) - ROUND(dkbs_pt(b_lp_dkbs)*b_tien_vcx *b_kho/ 100,b_tp);
        elsif dkbs_pp(b_lp_dkbs) = 'GP' and dkbs_pt(b_lp_dkbs)<>0 then
          dkbs_phi(b_lp_dkbs):= dkbs_phi(b_lp_dkbs) - ROUND(dkbs_pt(b_lp_dkbs)*dkbs_phiB(b_lp_dkbs)/ 100,b_tp);
          if dkbs_phi(b_lp_dkbs)<0 then dkbs_phi(b_lp_dkbs):=0; end if;
        end if;
       elsif dkbs_phiB(b_lp_dkbs)=0 then dkbs_phi(b_lp_dkbs):=0;
       end if;
     else
       if dkbs_pp(b_lp_dkbs) = 'DG' and dkbs_pt(b_lp_dkbs)>0 then
          dkbs_phi(b_lp_dkbs):=ROUND(dkbs_pt(b_lp_dkbs),b_tp);
       elsif dkbs_pp(b_lp_dkbs) = 'DP' and dkbs_tien(b_lp_dkbs)<>0 and dkbs_pt(b_lp_dkbs)<>0 then
          dkbs_phi(b_lp_dkbs):=ROUND(dkbs_pt(b_lp_dkbs)*dkbs_tien(b_lp_dkbs) *b_kho/ 100,b_tp);
       elsif dkbs_phiB(b_lp_dkbs)<>0 then
          dkbs_phi(b_lp_dkbs):=dkbs_phiB(b_lp_dkbs);
        if dkbs_pp(b_lp_dkbs) = 'GG' then
          dkbs_phi(b_lp_dkbs):=ROUND((dkbs_phi(b_lp_dkbs)-dkbs_pt(b_lp_dkbs)),b_tp);
        elsif dkbs_pp(b_lp_dkbs) = 'GT' and dkbs_tien(b_lp_dkbs)<>0 and dkbs_pt(b_lp_dkbs)<>0 then
          dkbs_phi(b_lp_dkbs):= dkbs_phi(b_lp_dkbs) - ROUND(dkbs_pt(b_lp_dkbs)*dkbs_tien(b_lp_dkbs) *b_kho/ 100,b_tp);
        elsif dkbs_pp(b_lp_dkbs) = 'GP' and dkbs_pt(b_lp_dkbs)<>0 then
          dkbs_phi(b_lp_dkbs):= dkbs_phi(b_lp_dkbs) - ROUND(dkbs_pt(b_lp_dkbs)*dkbs_phiB(b_lp_dkbs)/ 100,b_tp);
          if dkbs_phi(b_lp_dkbs)<0 then dkbs_phi(b_lp_dkbs):=0; end if;
        end if;
       elsif dkbs_phiB(b_lp_dkbs)=0 then dkbs_phi(b_lp_dkbs):=0;
       end if;
     end if;
     if dkbs_phiB(b_lp_dkbs)=0 then dkbs_phiB(b_lp_dkbs):=dkbs_phi(b_lp_dkbs); end if;
    else dkbs_phiB(b_lp_dkbs):=0; dkbs_phi(b_lp_dkbs):=0;
    end if;
  end if;
end loop;
FBH_2BG_PHIb(b_tp,dk_ma,dk_ma_ct,dk_lkeP,dk_lkeM,dk_cap,dk_kieu,dk_tien,dk_phi,b_loi);
if b_loi is not null then return; end if;
FBH_2BG_PHIb(b_tp,dkbs_ma,dkbs_ma_ct,dkbs_lkeP,dkbs_lkeM,dkbs_cap,dkbs_kieu,dkbs_tien,dkbs_phi,b_loi);
if b_loi is not null then return; end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_2B_BPHI_PRORATA_PT(
    dt_ct clob, b_nv varchar2, b_lh_bh varchar2, b_ma varchar2,
    b_tien number, b_nt_tien varchar2, b_nt_phi varchar2,
    b_pt out number,b_loi out varchar2)
AS
    b_lenh varchar2(2000); 
    b_so_id number;  b_phi number;
    b_bh_tbo varchar2(10); b_cdich varchar2(10); b_goi varchar2(10);
    b_ttai number; b_so_cn number; b_loai_xe varchar2(500); b_nhom_xe varchar2(500); b_gia number; b_tuoi number;
    b_ma_sp varchar2(10); b_md_sd varchar2(500); b_nv_bh varchar2(10); 
    b_dong varchar2(500); b_dco varchar2(1); b_ngay_hl number;
    b_dvi_ta varchar2(10):=FTBH_DVI_TA(); b_ngay number:=PKH_NG_CSO(sysdate);
    b_nam_sx number; b_thang_sx number;
begin
-- viet anh - tra ra pt khi tinh prorata
b_loi:='loi:Loi xu ly PBH_2B_BPHI_PRORATA_PT:loi';
b_lenh:=FKH_JS_LENH('md_sd,ma_sp,cdich,goi,loai_xe,nhom_xe,dong,dco,ttai,so_cn,thang_sx,nam_sx,gia,ngay_hl');
EXECUTE IMMEDIATE b_lenh into b_md_sd,b_ma_sp,b_cdich,b_goi,b_loai_xe,b_nhom_xe,b_dong,b_dco,b_ttai,
                  b_so_cn,b_thang_sx,b_nam_sx,b_gia,b_ngay_hl using dt_ct;
b_thang_sx:=nvl(b_thang_sx,0); b_nam_sx:=nvl(b_nam_sx,0);
b_tuoi:=FBH_2B_TUOIt(b_thang_sx,b_nam_sx);
b_bh_tbo:=NVL(trim(b_bh_tbo),' ');
b_cdich:=NVL(trim(b_cdich),' '); b_goi:=NVL(trim(b_goi),' ');
b_ttai:=nvl(b_ttai,0); b_so_cn:=nvl(b_so_cn,0); b_loai_xe:=PKH_MA_TENl(b_loai_xe); 
b_nhom_xe:=PKH_MA_TENl(b_nhom_xe); b_gia:=nvl(b_gia,0); b_tuoi:=nvl(b_tuoi,0);b_md_sd:=PKH_MA_TENl(b_md_sd);
b_ma_sp:=NVL(trim(b_ma_sp),' ');b_dong:=PKH_MA_TENl(b_dong); b_dco:=NVL(trim(b_dco),' ');
FBH_2B_BPHI_SO_ID('T',b_nv,'C',b_md_sd,b_ma_sp,b_cdich,b_goi,b_loai_xe,b_nhom_xe,b_dong,b_dco,b_ttai,b_so_cn,b_tuoi,b_gia,
    b_ngay_hl,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
FBH_2B_BPHI_DKm(b_so_id,b_ma,b_tien,b_lh_bh,b_pt,b_phi,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_nt_phi<>'VND' then
  if b_pt>100 then b_pt:=FTT_TUNG_QD(b_dvi_ta,b_ngay,'VND',b_pt,b_nt_phi); end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_2BG_PHIt(b_tp number,
    dk_ma pht_type.a_var,dk_ma_ct pht_type.a_var,dk_lkeP pht_type.a_var,dk_cap pht_type.a_num,
    dk_phi pht_type.a_num,dk_thue in out pht_type.a_num,dk_ttoan out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_cap number:=1; b_phi number; b_thue number;
begin
-- viet anh - Tinh bac cao
b_loi:='loi:Loi xu ly FBH_2BG_PHIt:loi';
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
            dk_thue(b_lp):=b_thue; dk_ttoan(b_lp):=b_phi+b_thue;
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
            dk_thue(b_lp):=b_thue;
        end if;
    end loop;
    b_cap:=b_cap-1;
end loop;
for b_lp in 1..dk_ma.count loop
    dk_ttoan(b_lp):=dk_phi(b_lp)+dk_thue(b_lp);
end loop;
b_loi:='';
end;
/
create or replace procedure FBH_2BG_PHIb(b_tp number,
    dk_ma pht_type.a_var,dk_ma_ct pht_type.a_var,dk_lkeP pht_type.a_var,dk_lkeM pht_type.a_var,dk_cap pht_type.a_num,dk_kieu pht_type.a_var,
    dk_tien in out pht_type.a_num,dk_phi in out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_cap number:=1; b_phi number; b_tien number;
begin
-- viet anh - Tinh bac cao
b_loi:='loi:Loi xu ly FBH_2BG_PHIb:loi';
for b_lp in 1..dk_ma.count loop
    if dk_cap(b_lp)>b_cap then b_cap:=dk_cap(b_lp); end if;
    if dk_lkeP(b_lp) in('T','N') then dk_phi(b_lp):=0; end if;
end loop;
b_cap:=b_cap-1;
while b_cap>0 loop
    for b_lp in 1..dk_ma.count loop
        if dk_cap(b_lp)<>b_cap then continue; end if;
        if dk_lkeP(b_lp)='T' then
            b_phi:=0;
            for b_lp1 in 1..dk_ma.count loop
                if dk_ma_ct(b_lp1)=dk_ma(b_lp) then
                    b_phi:=b_phi+dk_phi(b_lp1);
                end if;
            end loop;
            dk_phi(b_lp):=b_phi;
        elsif dk_lkeP(b_lp)='N' then
            b_i1:=0; b_phi:=0;
            for b_lp1 in 1..dk_ma.count loop
                if dk_ma_ct(b_lp1)=dk_ma(b_lp) and (dk_kieu(b_lp1)='T' or dk_phi(b_lp1)<>0) then
                    if b_i1=0 then
                        b_phi:=dk_phi(b_lp1);
                    else
                        b_phi:=ROUND(b_phi* dk_phi(b_lp1),b_tp);
                    end if;
                    b_i1:=1;
                end if;
            end loop;
            if b_i1<>0 then
               for b_lp1 in 1..dk_ma.count loop
                  if dk_ma_ct(b_lp1)=dk_ma(b_lp) and dk_kieu(b_lp1)<>' ' and dk_kieu(b_lp1)<>'T' and dk_tien(b_lp1)<>0 and dk_phi(b_lp1)=0 then
                        b_phi:=ROUND(b_phi* dk_tien(b_lp1),b_tp);
                  end if;
                end loop;
            end if;
            dk_phi(b_lp):=b_phi;
        end if;
        -- lkeM
        if dk_lkeM(b_lp)='T' then
          b_tien:=0;
          for b_lp1 in 1..dk_ma.count loop
              if dk_ma_ct(b_lp1)=dk_ma(b_lp) then
                  b_tien:=b_tien+dk_tien(b_lp1);
              end if;
          end loop;
          dk_tien(b_lp):=b_tien;
        elsif dk_lkeP(b_lp)='N' then
          b_i1:=0; b_tien:=0;
          for b_lp1 in 1..dk_ma.count loop
              if dk_ma_ct(b_lp1)=dk_ma(b_lp) and (dk_kieu(b_lp1)='T' or dk_tien(b_lp1)<>0) then
                  if b_i1=0 then
                      b_tien:=dk_tien(b_lp1);
                  else
                      b_tien:=ROUND(b_tien* dk_tien(b_lp1),b_tp);
                  end if;
                  b_i1:=1;
              end if;
          end loop;
          dk_tien(b_lp):=b_tien;
        end if;
    end loop;
    b_cap:=b_cap-1;
end loop;
b_loi:='';
end;
