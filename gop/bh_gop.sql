create or replace function FBH_GOP_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_id number; b_txt clob;
    a_ds_ct pht_type.a_clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
select count(*) into b_i1 from bh_gop_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_gop_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
	PKH_JS_BONH(b_txt); b_kq:=FKH_JS_GTRIs(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_GOP_TXTn(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return number
AS
    b_kq number:=0; b_i1 number; b_id number; b_txt clob; b_lenh varchar2(1000);
    a_ds_ct pht_type.a_clob;
begin
-- Dan - Tra gia tri num trong txt
select count(*) into b_i1 from bh_gop_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_gop_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    PKH_JS_BONH(b_txt); b_kq:=FKH_JS_GTRIn(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_GOP_MA_SDBS(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(10):=' '; b_i1 number; b_txt clob;
begin
-- Dan - Tra Ma SDBS
select count(*) into b_i1 from bh_gop_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1<>0 then
    select txt into b_txt from bh_gop_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    b_kq:=FKH_JS_GTRIs(b_txt,'ma_sdbs');
end if;
return b_kq;
end;
/
create or replace function FBH_GOP_SO_KEM_ID(
    b_ma_dvi varchar2,b_so_kem varchar2) return number
AS
    b_kq number;
begin
-- Dan - Tra so_id gop qua so_kem
select nvl(max(so_id),0) into b_kq from bh_gop_hd where ma_dvi=b_ma_dvi and so_kem=b_so_kem;
return b_kq;
end;
/
create or replace function FBH_GOP_ID_KEM_ID(
    b_ma_dvi varchar2,b_so_id_kem number) return number
AS
    b_kq number;
begin
-- Dan - Tra so_id gop qua so_id_kem
select nvl(max(so_id),0) into b_kq from bh_gop_hd where ma_dvi=b_ma_dvi and so_id_kem=b_so_id_kem;
return b_kq;
end;
/
create or replace function FBH_GOP_ID_KEM_NV(
    b_ma_dvi varchar2,b_so_id_kem varchar2) return number
AS
    b_kq varchar2(10);
begin
-- Dan - Tra nv cua so_id_kem: 2B,XE,..
select min(nv) into b_kq from bh_gop_hd where ma_dvi=b_ma_dvi and so_id_kem=b_so_id_kem;
return b_kq;
end;
/
create or replace function FBH_GOP_ID_KEM_LOAI(
    b_ma_dvi varchar2,b_so_id_kem varchar2) return number
AS
    b_kq varchar2(10);
begin
-- Dan - Tra loai cua so_id_kem: G,H
select min(loai) into b_kq from bh_gop_hd where ma_dvi=b_ma_dvi and so_id_kem=b_so_id_kem;
return b_kq;
end;
/
create or replace function FBH_GOP_NV(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra nghiep vu
select min(nv) into b_kq from bh_gop where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_GOP_HL(
    b_ma_dvi varchar2,b_so_id number,b_ngay number,b_ngayd number,b_ngayc number) return varchar2
AS
    b_so_idB number; b_ngay_hl number; b_ngay_kt number; b_kq varchar2(1):='K';
begin
-- Dan - Kiem tra hieu luc
b_so_idB:=FBH_GOP_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from bh_gop where ma_dvi=b_ma_dvi and so_id=b_so_idB;
if b_ngayd<=b_ngay_kt and b_ngay_hl<=b_ngayc then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_GOP_KIEU_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Dan - Tra so hop dong
select nvl(min(kieu_hd),' ') into b_kq from bh_gop where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_GOP_KIEU_HDd(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(1); b_so_idD number:=FBH_GOP_SO_IDd(b_ma_dvi,b_so_id);
begin
-- Dan - Tra kieu hop dong qua so_id
select nvl(min(kieu_hd),' ') into b_kq from bh_gop where ma_dvi=b_ma_dvi and so_id=b_so_idD;
return b_kq;
end;
/
create or replace function FBH_GOP_SO_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Dan - Tra so hop dong
select min(so_hd) into b_kq from bh_gop where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_GOP_SO_HDd(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50); b_so_idD number;
begin
-- Dan - Tra so hop dong dau
b_so_idD:=FBH_GOP_SO_IDd(b_ma_dvi,b_so_id);
b_kq:=FBH_GOP_SO_HD(b_ma_dvi,b_so_idD);
return b_kq;
end;
/
create or replace function FBH_GOP_SO_ID(b_ma_dvi varchar2,b_so_hd varchar2,b_nv varchar2:='') return number
as
    b_kq number;
begin
-- Dan - Tra so id
if nvl(b_nv,' ')=' ' then 
    select nvl(min(so_id),0) into b_kq from bh_gop where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
else 
    select nvl(min(so_id),0) into b_kq from bh_gop where ma_dvi=b_ma_dvi and so_hd=b_so_hd and nv=b_nv;
end if;
return b_kq;
end;
/
create or replace function FBH_GOP_SO_IDd(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Dan - Tra so id dau
select nvl(min(so_id_d),0) into b_kq from bh_gop where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_GOP_HD_SO_IDd(b_ma_dvi varchar2,b_so_hd varchar2) return number
as
    b_kq number;
begin
-- Dan - Tra so id dau
select nvl(min(so_id_d),0) into b_kq from bh_gop where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
return b_kq;
end;
/
create or replace function FBH_GOP_SO_IDc(b_ma_dvi varchar2,b_so_id number,b_ttrang varchar2:='K') return number
as
    b_kq number:=0; b_so_idD number:=b_so_id;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_GOP_SO_IDd(b_ma_dvi,b_so_id);
if b_ttrang<>'C' then
    select nvl(max(so_id),0) into b_kq from bh_gop where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
else
    select nvl(max(so_id),0) into b_kq from bh_gop where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D';
end if;
return b_kq;
end;
/
create or replace function FBH_GOP_HD_SO_IDc(b_ma_dvi varchar2,b_so_hd varchar2,b_ttrang varchar2:='K') return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_GOP_HD_SO_IDd(b_ma_dvi,b_so_hd);
if b_ttrang<>'C' then
    select nvl(max(so_id),0) into b_kq from bh_gop where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
else
    select nvl(max(so_id),0) into b_kq from bh_gop where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D';
end if;
return b_kq;
end;
/
create or replace function FBH_GOP_SO_IDt(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_GOP_SO_IDd(b_ma_dvi,b_so_id);
select nvl(max(so_id),0) into b_kq from bh_gop where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang in('T','D') and ngay_ht<=b_ngay;
return b_kq;
end;
/
create or replace function FBH_GOP_SO_IDb(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_GOP_SO_IDd(b_ma_dvi,b_so_id);
select nvl(max(so_id),0) into b_kq from bh_gop where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D' and ngay_ht<=b_ngay;
return b_kq;
end;
/
create or replace function FBH_GOP_HD_SO_IDb(
    b_ma_dvi varchar2,b_so_hd varchar2,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FBH_GOP_HD_SO_IDd(b_ma_dvi,b_so_hd);
select nvl(max(so_id),0) into b_kq from bh_gop where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D' and ngay_ht<=b_ngay;
return b_kq;
end;
/
create or replace function FBH_GOP_NT_TIEN(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(5); b_so_idB number;
begin
-- Dan - Tra loai tien bao hiem
b_so_idB:=FBH_GOP_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select nvl(min(nt_tien),'VND') into b_kq from bh_gop where ma_dvi=b_ma_dvi and so_id=b_so_idB;
return b_kq;
end;
/
create or replace function FBH_GOP_NT_PHI(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(5); b_so_idB number;
begin
-- Dan - Tra loai tien phi
b_so_idB:=FBH_GOP_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
select nvl(min(nt_phi),'VND') into b_kq from bh_gop where ma_dvi=b_ma_dvi and so_id=b_so_idB;
return b_kq;
end;
/
create or replace function FBH_GOP_CAP(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Dan - Tra ngay cap
select min(ngay_cap) into b_kq from bh_gop where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_GOP_NGAY(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Dan - Tra ngay nhap
select nvl(min(ngay_ht),0) into b_kq from bh_gop where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_GOP_TTRANG(
    b_ma_dvi varchar2,b_so_id number,b_dk varchar2:='K',b_ngay number:=30000101) return varchar2
as
    b_kq varchar2(1); b_i1 number;
begin
-- Dan - Tra ngay cap
select nvl(min(ttrang),'X') into b_kq from bh_gop where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_kq<>'X' and b_dk='C' then
    select count(*) into b_i1 from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay;
    if b_i1<>0 then b_kq:='H'; end if;
end if;
return b_kq;
end;
/
create or replace procedure PBH_GOP_SO_ID_KTRA(b_ma_dvi varchar2,b_so_id_g number,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Kiem tra SO_ID moi nhap
if b_so_id_g=0 then b_loi:=''; return; end if;
select count(*) into b_i1 from bh_gop where ma_dvi=b_ma_dvi and so_id=b_so_id_g and ttrang<>'D';
if b_i1<>0 then b_loi:='loi:Hop dong cu da xoa hoac chua ky:loi'; return; end if;
select count(*) into b_i1 from bh_gop where ma_dvi=b_ma_dvi and so_id_g=b_so_id_g and kieu_hd<>'K';
if b_i1<>0 then b_loi:='loi:Hop dong cu da co bo sung, sua doi:loi'; return; end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_GOP_HDBS(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma_dvi varchar2(10); b_so_id number; b_so_idD number;
    b_dong number; cs_lke clob:='';
begin
-- Dan - Liet ke sua doi bo sung
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','GOP','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_so_idD:=FBH_GOP_SO_IDd(b_ma_dvi,b_so_id);
if b_so_idD<>0 then
    select count(*) into b_dong from bh_gop where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hd,ttoan,ttrang,ma_dvi,so_id,
           'ma_sdbs' value PKH_TEN_TENl(FBH_GOP_MA_SDBS(ma_dvi,so_id))
    ) order by so_id desc returning clob)
        into cs_lke from bh_gop where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;   
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_GOP_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10);
    b_ngay_ht number; b_nv varchar2(1); b_klk varchar2(1); b_tu number; b_den number;
    b_dong number; cs_lke clob;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','GOP','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,nv,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_nv,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_gop where ma_dvi=b_ma_dvi and 
        ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_hd,nsd) order by so_hd desc returning clob) into cs_lke from
        (select  ma_dvi,so_id,so_hd,nsd,rownum sott from bh_gop where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','GOP','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_gop where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_hd,nsd) order by so_hd desc returning clob) into cs_lke from
        (select ma_dvi,so_id,so_hd,nsd,rownum sott from bh_gop  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong order by so_hd)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_gop where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_hd,nsd) order by so_hd desc returning clob) into cs_lke from
        (select ma_dvi,so_id,so_hd,nsd,rownum sott from bh_gop  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_GOP_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10); b_so_hd varchar2(20);
    b_so_id number; b_ngay_ht number; b_nv varchar2(1); b_klk varchar2(1); b_trangKt number; b_tu number; b_den number;
    b_trang number; b_dong number; cs_lke clob;
begin
-- Dan - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','GOP','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,nv,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_nv,b_klk,b_trangKt using b_oraIn;
b_so_hd:=FBH_GOP_SO_HD(b_ma_dvi,b_so_id);
if b_so_hd is null then b_loi:='loi:GCN, hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
if b_klk ='N' then
    select count(*) into b_dong from bh_gop
        where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_gop where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_hd,nsd) order by so_hd desc returning clob) into cs_lke from
        (select ma_dvi,so_id,so_hd,nsd,rownum sott from bh_gop  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','GOP','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_gop where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_gop where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_hd,nsd) order by so_hd desc returning clob) into cs_lke from
        (select ma_dvi,so_id,so_hd,nsd,rownum sott from bh_gop  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong order by so_hd)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_gop where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_gop where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_hd,nsd) order by so_hd desc returning clob) into cs_lke from
        (select ma_dvi,so_id,so_hd,nsd,rownum sott from bh_gop  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_GOP_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_so_id number; b_so_hd varchar2(20);b_nv varchar2(1);
    b_lenh varchar2(2000); b_loi varchar2(100);
begin
-- Dan - Hoi so ID qua so hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','GOP','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hd,nv');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_nv using b_oraIn;
b_so_id:=FBH_GOP_SO_ID(b_ma_dvi,b_so_hd,b_nv);
if b_so_id=0 then b_loi:='loi:So hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_GOP_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(200); b_dong number; cs_lke clob:='';
    b_so_id number; b_so_idC number; b_ma_kh varchar2(20); b_so_hd varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(20);
    b_ngayD number; b_ngayC number; b_ngay_ht number; b_ttrang varchar2(1);
begin
-- Dan - Tim hop dong qua CMT, mobi, email
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','GOP','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email using b_oraIn;
b_ttrang:=nvl(trim(b_ttrang),' ');
if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    for r_lp in (select distinct so_id_d from bh_gop where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and
        ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd and b_ttrang in (' ',ttrang)) loop
        b_so_idC:=FBH_GOP_SO_IDc(b_ma_dvi,r_lp.so_id_d);
        select max(so_hd),max(ngay_ht) into b_so_hd,b_ngay_ht from bh_gop where ma_dvi=b_ma_dvi and so_id=b_so_idC;
        insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n4,n10,c10)
            select b_so_hd,FBH_GOP_TTRANG(b_ma_dvi,b_so_idC),ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_ngay_ht,b_so_idC,nv
            from bh_gop where ma_dvi=b_ma_dvi and so_id=b_so_idC;
    end loop;
else
    for r_lp in (select distinct so_id_d from bh_gop where ma_dvi=b_ma_dvi and
        ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd and b_ttrang in (' ',ttrang)) loop
        b_so_idC:=FBH_GOP_SO_IDc(b_ma_dvi,r_lp.so_id_d);
        select max(so_hd),max(ngay_ht) into b_so_hd,b_ngay_ht from bh_gop where ma_dvi=b_ma_dvi and so_id=b_so_idC;
        insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n4,n10,c10)
            select b_so_hd,FBH_GOP_TTRANG(b_ma_dvi,b_so_idC),ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_ngay_ht,b_so_idC,nv
            from bh_gop where ma_dvi=b_ma_dvi and so_id=b_so_idC;
    end loop;
end if;
select count(*) into b_dong from ket_qua;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,
    'ngay_hl' value n1,'ngay_kt' value n2,'ngay_cap' value n3,
    'ma_dvi' value b_ma_dvi,'so_id' value n10,'nv' value c10 returning clob)
    order by n4 desc,c1 returning clob) into cs_lke from ket_qua;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
