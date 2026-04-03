create or replace function FBH_PTNVC_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_id number; b_txt clob;
    a_ds_ct pht_type.a_clob;
begin
-- nam - Tra gia tri varchar2 trong txt
select count(*) into b_i1 from bh_ptnvc_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
	select txt into b_txt from bh_ptnvc_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
	PKH_JS_BONH(b_txt); b_kq:=FKH_JS_GTRIs(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_PTNVC_TXTn(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return number
AS
    b_kq number:=0; b_i1 number; b_id number; b_txt clob; b_lenh varchar2(1000);
    a_ds_ct pht_type.a_clob;
begin
-- nam - Tra gia tri num trong txt
select count(*) into b_i1 from bh_ptnvc_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_ptnvc_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    PKH_JS_BONH(b_txt); b_kq:=FKH_JS_GTRIn(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace  function FBH_PTNVC_SO_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Nam - Tra so hop dong
select min(so_hd) into b_kq from bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace  function FBH_PTNVC_SO_IDd(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Nam - Tra so id dau
select nvl(min(so_id_d),0) into b_kq from bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_PTNVC_SO_IDt(
   b_ma_dvi varchar2, b_so_id number,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Nam - Tra so id bo sung den ngay
b_so_idD:=FBH_PTNVC_SO_IDd(b_ma_dvi,b_so_id);
select nvl(max(so_id),0) into b_kq from bh_ptnvc where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang in('T','D') and ngay_ht<=b_ngay;
return b_kq;
end;
/
create or replace function FBH_PTNVC_SO_IDb(
   b_ma_dvi varchar2, b_so_id number,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Nam - Tra so id bo sung den ngay
b_so_idD:=FBH_PTNVC_SO_IDd(b_ma_dvi,b_so_id);
select nvl(max(so_id),0) into b_kq from bh_ptnvc where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D' and ngay_ht<=b_ngay;
return b_kq;
end;
/
create or replace function FBH_PTNVC_SO_IDc(b_ma_dvi varchar2,b_so_id number,b_ttrang varchar2:='K') return number
as
    b_kq number:=0; b_so_idD number:=b_so_id;
begin
-- Nam - Tra so id cuoi
b_so_idD:=FBH_PTNVC_SO_IDd(b_ma_dvi,b_so_id);
if b_ttrang<>'C' then
    select nvl(max(so_id),0) into b_kq from bh_ptnvc where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
else
    select nvl(max(so_id),0) into b_kq from bh_ptnvc where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D';
end if;
return b_kq;
end;
/
create or replace function FBH_PTNVC_KIEU_HDd(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(1); b_so_idD number:=FBH_PTNVC_SO_IDd(b_ma_dvi,b_so_id);
begin
-- Nam - Tra so hop dong
select nvl(min(kieu_hd),' ') into b_kq from bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_idD;
return b_kq;
end;
/
create or replace function FBH_PTNVC_SO_ID(b_ma_dvi varchar2,b_so_hd varchar2) return number
as
    b_kq number;
begin
-- Nam - Tra so id
select nvl(min(so_id),0) into b_kq from bh_ptnvc where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
return b_kq;
end;
/
create or replace procedure PBH_PTNVCG_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number; b_so_hd varchar2(20):=FKH_JS_GTRIs(b_oraIn,'so_hd');
begin
-- Nam - Hoi so ID qua so hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
b_so_id:=FBH_PTNVC_SO_ID(b_ma_dvi,b_so_hd);
if b_so_id=0 then b_loi:='loi:So hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_PTNVC_BPHI_DKm(
    b_so_id number,b_ma varchar2,b_tien number,
    b_lh_bh varchar2,b_tgT number,b_pt out number,b_loi out varchar2)
AS
    b_i1 number; b_tienM number;
begin
-- Nam - Lay %phi theo khoang muc trach nhiem
b_loi:='loi:Loi xu ly FBH_PTNVC_BPHI_DKm:loi';
select count(*),nvl(max(tien),0) into b_i1,b_tienM from bh_ptnvc_phi_dk where
    so_id=b_so_id and ma=b_ma and lh_bh=b_lh_bh and tien<=round(b_tien * b_tgT,2) ;
if b_i1=0 then b_loi:='loi:Khong tim duoc ty le phi theo muc trach nhiem:loi'; return; end if;
select nvl(max(pt),0) into b_pt from bh_ptnvc_phi_dk
    where so_id=b_so_id and ma=b_ma and lh_bh=b_lh_bh and tien=b_tienM;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
-- nam sua
create or replace procedure PBH_PTNVCG_BPHI_DKm(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_ngay number:=PKH_NG_CSO(sysdate);
    b_so_id number; b_ma varchar2(10); b_tien number; b_pt number;
    b_lh_bh varchar2(1); b_ma_sp varchar2(10); b_cdich varchar2(10); b_ngay_hl number;
    b_dvi_ta varchar2(10):=FTBH_DVI_TA(); b_nt_tien varchar2(5); b_nt_phi varchar2(5);
    b_tgT number:=1; b_tgP number:=1;
begin
-- Nam - Lay %phi theo khoang muc trach nhiem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_sp,cdich,ngay_hl,nt_tien,nt_phi');
EXECUTE IMMEDIATE b_lenh into
    b_ma_sp,b_cdich,b_ngay_hl,b_nt_tien,b_nt_phi using b_oraIn;
b_ma_sp:=NVL(trim(b_ma_sp),' '); b_cdich:=NVL(trim(b_cdich),' ');
if b_ngay_hl in(0,30000101) then b_ngay_hl:=PKH_NG_CSO(sysdate); end if;
if b_nt_tien<>'VND' then b_tgT:=FTT_TRA_TGTT(b_dvi_ta,b_ngay,b_nt_tien); end if;
if b_nt_phi<>'VND' then b_tgP:=FTT_TRA_TGTT(b_dvi_ta,b_ngay,b_nt_phi); end if;
b_lenh:=FKH_JS_LENH('lh_bh,ma,tien');
EXECUTE IMMEDIATE b_lenh into b_lh_bh,b_ma,b_tien using b_oraIn;
b_so_id:=FBH_PTNVC_BPHI_SO_IDh(b_ma_sp,b_cdich,b_ngay_hl);
FBH_PTNVC_BPHI_DKm(b_so_id,b_ma,b_tien,b_lh_bh,b_tgT,b_pt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('pt' value case when b_pt<100 then b_pt else round(b_pt/b_tgP,2) end) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNVCG_BPHI_CTm(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_so_id number; b_ma varchar2(10); b_tien number;
    b_ma_sp varchar2(10); b_cdich varchar2(10); b_lvuc varchar2(10);
    b_ngay_hl number; cs_dk clob:=''; cs_txt clob:='';
begin
-- Nam - Lay %phi theo khoang muc trach nhiem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_sp,cdich,lvuc,ngay_hl,loai');
EXECUTE IMMEDIATE b_lenh into b_ma_sp,b_cdich,b_lvuc,b_ngay_hl using b_oraIn;

b_ma_sp:=NVL(trim(b_ma_sp),' '); b_cdich:=NVL(trim(b_cdich),' '); b_lvuc:=NVL(trim(b_lvuc),' ');
if b_ngay_hl in(0,30000101) then b_ngay_hl:=PKH_NG_CSO(sysdate); end if;
b_lenh:=FKH_JS_LENH('ma,tien');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tien using b_oraIn;
b_so_id:=FBH_PTNVC_BPHI_SO_IDh(b_ma_sp,b_cdich,b_ngay_hl);
select JSON_ARRAYAGG(json_object('nv' value 'B',ma,cap,ma_dk,lh_nv,t_suat,'ptB' value pt) order by bt returning clob)
    into cs_dk from bh_ptnvc_phi_dk where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into cs_txt
    from bh_ptnvc_phi_txt where so_id=b_so_id and loai='dt_dk';
select json_object('dt_dk' value cs_dk,'txt' value cs_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--duchq update length email
create or replace procedure PBH_PTNVCG_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(200); cs_lke clob:='';
    b_so_id number; b_so_idC number; b_ma_kh varchar2(20); b_so_hd varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number; b_ttrang varchar2(1);
begin
-- Nam - Tim hop dong qua CMT, mobi, email
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email using b_oraIn;
b_ttrang:=nvl(trim(b_ttrang),' ');
if b_ngayC=0 then b_ngayC:=30000101; end if;
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
    for r_lp in (select distinct so_id_d from bh_ptnvc where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and
        ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd and b_ttrang in (' ',ttrang)) loop
        b_so_idC:=FBH_PTN_SO_IDc(b_ma_dvi,r_lp.so_id_d);
        select max(so_hd) into b_so_hd from bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_idC;
        insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10)
            select b_so_hd,FBH_PTN_TTRANG(b_ma_dvi,b_so_idC),ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_so_idC
            from bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_idC;
    end loop;
elsif b_ngayD between b_ngay and 30000101 then
    for r_lp in (select distinct so_id_d from bh_ptnvc where ma_dvi=b_ma_dvi and
        ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd and b_ttrang in (' ',ttrang)) loop
        b_so_idC:=FBH_PTN_SO_IDc(b_ma_dvi,r_lp.so_id_d);
        select max(so_hd) into b_so_hd from bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_idC;
        insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10)
            select b_so_hd,FBH_PTN_TTRANG(b_ma_dvi,b_so_idC),ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_so_idC
            from bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_idC;
    end loop;
end if;
select count(*) into b_dong from ket_qua;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,
    'ngay_hl' value n1,'ngay_kt' value n2,'ngay_cap' value n3,
    'ma_dvi' value b_ma_dvi,'so_id' value n10)
    order by c1 desc returning clob) into cs_lke from ket_qua;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNVCG_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_ngay number:=PKH_NG_CSO(sysdate);
    cs_sp clob; cs_cdich clob; cs_lvuc clob; cs_khd clob; cs_kbt clob; cs_tltg clob; cs_ttt clob;
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten) into cs_sp from
    bh_ptnvc_sp a,(select distinct ma_sp from bh_ptnvc_phi where ngay_bd<=b_ngay and ngay_kt>b_ngay) b
  where a.ma=b.ma_sp and FBH_PTNVC_SP_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten) into cs_cdich from
    bh_ma_cdich a,(select distinct cdich from bh_ptnvc_phi where ngay_bd<=b_ngay and ngay_kt>b_ngay) b
  where a.ma=b.cdich and FBH_MA_NV_CO(a.nv,'PTN')='C' and FBH_MA_CDICH_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten) into cs_lvuc from
    bh_ma_lvuc a,(select distinct lvuc from bh_ptnvc_phi where ngay_bd<=b_ngay and ngay_kt>b_ngay) b
  where a.ma=b.lvuc and FBH_MA_LVUC_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_khd from bh_kh_ttt where ps='KHD' and nv='PTN';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_kbt from bh_kh_ttt where ps='KBT' and nv='PTN';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_ttt
    from bh_kh_ttt where ps='HD' and nv='PTN';
select JSON_ARRAYAGG(json_object(tltg,tlph) order by tltg returning clob) into cs_tltg
    from bh_ptn_tltg where b_ngay between ngay_bd and ngay_kt;
select json_object('cs_sp' value cs_sp,'cs_cdich' value cs_cdich,'cs_lvuc' value cs_lvuc,'cs_khd' value cs_khd,'cs_kbt' value cs_kbt,
                           'cs_tltg' value cs_tltg,'cs_ttt' value cs_ttt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNVCG_MA_LVUC(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_ngay number:=PKH_NG_CSO(sysdate);cs_lvuc clob;
begin
-- Tra ma lvuc theo bieu phi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten) into cs_lvuc from
    bh_ma_lvuc a,(select distinct lvuc from bh_ptnvc_phi where ngay_bd<=b_ngay and ngay_kt>b_ngay) b
  where a.ma=b.lvuc and FBH_MA_LVUC_HAN(a.ma)='C';
select json_object('cs_lvuc' value cs_lvuc returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;

/
create or replace procedure PBH_PTNVCG_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10);
    b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number;
    b_dong number; cs_lke clob;
begin
-- Nam - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_ptnvc where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ptnvc where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','PTN','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_ptnvc where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and phong=b_phong;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ptnvc  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_hd)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ptnvc where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ptnvc  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;

/
create or replace procedure PBH_PTNVCG_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10); b_so_hd varchar2(20);
    b_so_id number; b_ngay_ht number; b_klk varchar2(1); b_trangKt number; b_tu number; b_den number;
    b_trang number; b_dong number; cs_lke clob;
begin
-- Nam - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_klk,b_trangKt using b_oraIn;
b_so_hd:=FBH_PTNVC_SO_HD(b_ma_dvi,b_so_id);
if b_so_hd is null then b_loi:='loi:GCN, hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
if b_klk ='N' then
    select count(*) into b_dong from bh_ptnvc where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_ptnvc where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ptnvc  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht  and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','PTN','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_ptnvc where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht  and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_ptnvc where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht  and phong=b_phong  order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ptnvc  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht  and phong=b_phong order by so_hd)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ptnvc where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht ;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_ptnvc where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht   order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ptnvc  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht  order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNVCG_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number;
    dt_ct clob; dt_dk clob; dt_dkbs clob; dt_lt clob:=''; dt_khd clob:=''; dt_kbt clob:=''; dt_kytt clob:=''; dt_ttt clob:=''; dt_txt clob;
begin
-- Nam - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','PTN','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
if b_so_id=0 then b_loi:='loi:Chon GCN:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
select json_object(so_hd,ma_kh,'lvuc' value FBH_MA_LVUC_TENl(lvuc)) into dt_ct from bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ngay,tien) order by ngay) into dt_kytt from bh_ptnvc_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ma,ten) order by bt returning clob) into dt_dk
    from bh_ptnvc_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_bh<>'M';
select JSON_ARRAYAGG(json_object(
    MA,ten,tien,pt,phi,cap,tc,ma_ct,ma_dk,kieu,lh_nv,t_suat,ptB,lkeP,lkeB,luy) order by bt returning clob) into dt_dkbs
    from bh_ptnvc_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_bh='M';
select count(*) into b_i1 from bh_ptnvc_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_lt';
if b_i1<>0 then
    select txt into dt_lt from bh_ptnvc_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_lt';
end if;
select count(*) into b_i1 from bh_ptnvc_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_khd';
if b_i1<>0 then
    select txt into dt_khd from bh_ptnvc_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_khd';
end if;
select count(*) into b_i1 from bh_ptnvc_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_kbt';
if b_i1<>0 then
    select txt into dt_kbt from bh_ptnvc_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_kbt';
end if;
select count(*) into b_i1 from bh_ptnvc_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
if b_i1<>0 then
    select txt into dt_ttt from bh_ptnvc_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
end if;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_ptnvc_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai in('dt_ct','dt_dk','dt_dkbs');
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,
    'dt_lt' value dt_lt,'dt_khd' value dt_khd,'dt_kbt' value dt_kbt,'dt_kytt' value dt_kytt,'dt_ttt' value dt_ttt,
    'dt_ct' value dt_ct,'dt_dk' value dt_dk,'dt_dkbs' value dt_dkbs,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNVCG_GOC_XOA(b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh varchar2,b_loi out varchar2)
AS
begin
-- Nam - Xoa goc
PBH_HD_GOC_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi,b_nh);
if b_loi is not null then return; end if;
b_loi:='loi:Loi xoa Table bh_ng:loi';
delete bh_ptn_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ptn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PTNVC_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh varchar2,b_loi out varchar2)
AS
    b_i1 number; b_so_idK number; b_ttrang varchar2(1); b_ksoat varchar2(20); b_nsdC varchar2(20);
begin
-- Nam - Xoa
b_loi:='loi:Loi xu ly PBH_PTNVC_XOA_XOA:loi';
select count(*) into b_i1 from bh_ptnvc where so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select so_id_kt,ttrang,ksoat,nsd into b_so_idK,b_ttrang,b_ksoat,b_nsdC
    from bh_ptnvc where so_id=b_so_id;
if b_so_idK>0 then b_loi:='loi:Khong sua, xoa phuc hoi da hach toan ke toan:loi'; return; end if;
if b_nsdC<>b_nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
if trim(b_ksoat) is not null and b_ksoat<>b_nsd then b_loi:='loi:Khong sua, xoa GCN, hop dong da kiem soat:loi'; return; end if;
b_loi:='loi:Loi xoa Table bh_ptnvc:loi';
delete bh_hd_goc_ttindt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ptnvc_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ptnvc_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ptnvc_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ptnvc_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ptnvc_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_ttrang in('T','D') then
    PBH_PTN_GOC_XOA(b_ma_dvi,b_nsd,b_so_id,b_nh,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PTNVC_XOA(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Nam - Xoa GCN
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TNVC','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_PTNVC_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'X',b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNVCG_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,dt_ct in out clob,dt_dk clob,dt_dkbs clob,dt_lt clob,dt_kbt clob, dt_ttt clob,
    b_so_hd varchar2,b_ngay_ht number,b_ttrang varchar2,b_kieu_hd varchar2,b_so_hd_g varchar2,
    b_kieu_kt varchar2,b_ma_kt varchar2,b_kieu_gt varchar2,b_ma_gt varchar2,b_ma_cb varchar2,
    b_so_hdL varchar2,b_loai_kh varchar2,b_ma_kh varchar2,b_ten nvarchar2,b_dchi nvarchar2,
    b_cmt varchar2,b_mobi varchar2,b_email varchar2,
    b_gio_hl varchar2,b_ngay_hl number,b_gio_kt varchar2,b_ngay_kt number,b_ngay_cap number,
    b_nt_tien varchar2,b_nt_phi varchar2,b_c_thue varchar2,
    b_phi number,b_giam number,b_thue number,b_ttoan number,b_hhong number,
    b_so_idG number,b_so_idD number,b_phong varchar2,
    tt_ngay pht_type.a_num,tt_tien pht_type.a_num,

    b_so_idP number,b_ma_sp varchar2,b_cdich varchar2,b_lvuc varchar2,b_dtuong nvarchar2,b_dthu number, b_ngay_hoi number,

    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tc pht_type.a_var,dk_ma_ct pht_type.a_var,
    dk_kieu pht_type.a_var,dk_tien pht_type.a_num,dk_pt pht_type.a_num,dk_pphi pht_type.a_num,dk_phi pht_type.a_num,
    dk_thue pht_type.a_num,dk_ttoan pht_type.a_num,dk_cap pht_type.a_num,dk_ma_dk pht_type.a_var,
    dk_lh_nv pht_type.a_var,dk_t_suat pht_type.a_num,dk_ptB pht_type.a_num,dk_ptG pht_type.a_num,dk_phiG pht_type.a_num,
    dk_lkeM pht_type.a_var,dk_lkeP pht_type.a_var,dk_lkeB pht_type.a_var,dk_luy pht_type.a_var,dk_ktru pht_type.a_var,dk_lh_bh pht_type.a_var,
    b_loi out varchar2)

AS
    b_so_id_kt number:=-1; b_txt clob; b_tien number:=0; b_ma_ke varchar2(20):=' ';
begin
-- Nam - Nhap
b_loi:='loi:Loi Table bh_ptnvc:loi';
if b_ttrang='D' then b_so_id_kt:=0; end if;
for b_lp in 1..dk_lh_nv.count loop
    if dk_lh_nv(b_lp)<>' ' and dk_kieu(b_lp)='T' then b_tien:=b_tien+dk_tien(b_lp); end if;
    insert into bh_ptnvc_dk values(b_ma_dvi,b_so_id,b_so_id,b_lp,
        dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),dk_kieu(b_lp),
        dk_tien(b_lp),dk_pt(b_lp),dk_pphi(b_lp),dk_phi(b_lp),dk_cap(b_lp),dk_ma_dk(b_lp),
        dk_lh_nv(b_lp),dk_t_suat(b_lp),dk_thue(b_lp),dk_ttoan(b_lp),
        dk_ptB(b_lp),dk_ptG(b_lp),dk_phiG(b_lp),dk_lkeP(b_lp),dk_lkeB(b_lp),dk_luy(b_lp),dk_ktru(b_lp),dk_lh_bh(b_lp));
end loop;
insert into bh_ptnvc values(
        b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,
        b_ma_gt,b_ma_cb,b_phong,b_so_hdL,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,
        b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,b_ma_sp,b_cdich,b_lvuc,b_dtuong,b_dthu,b_tien,b_phi,
        b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,'','',b_so_id_kt,b_nsd,sysdate);       
PKH_JS_THAYa(dt_ct,'so_hd,ma_kh',b_so_hd||','||b_ma_kh);
if trim(b_ma_kh) is not null then PKH_JS_THAY(dt_ct,'ma_kh',b_ma_kh); end if;
insert into bh_ptnvc_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
insert into bh_ptnvc_txt values(b_ma_dvi,b_so_id,'dt_dk',dt_dk);
if dt_dkbs is not null then
  insert into bh_ptnvc_txt values(b_ma_dvi,b_so_id,'dt_dkbs',dt_dkbs);
end if;
if dt_ttt is not null then
  insert into bh_ptnvc_txt values(b_ma_dvi,b_so_id,'dt_ttt',dt_ttt);
end if;
if dt_lt is not null then
    insert into bh_ptnvc_txt values(b_ma_dvi,b_so_id,'dt_lt',dt_lt);
end if;
if dt_kbt is not null then
    insert into bh_ptnvc_txt values(b_ma_dvi,b_so_id,'dt_kbt',dt_kbt);
end if;
for b_lp in 1..tt_ngay.count loop
    insert into bh_ptnvc_tt values(b_ma_dvi,b_so_id,tt_ngay(b_lp),tt_tien(b_lp));
end loop;
-- Di tiep

if b_ttrang in('T','D') then
    select JSON_ARRAYAGG(json_object(
        ma,ten,tc,ma_ct,tien,pt,phi,cap,ma_dk,lh_nv,t_suat,thue,ttoan,ptB,ptG,phiG,lkeM,lkeP,lkeB,luy)
        order by bt returning clob) into b_txt
        from bh_ptn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
    insert into bh_ptn_kbt values(b_ma_dvi,b_so_id,b_so_id,b_txt,dt_lt,dt_kbt);
    insert into bh_ptnvc_kbt values(b_ma_dvi,b_so_id,b_so_id,b_txt,dt_lt,dt_kbt);
    insert into bh_ptn values(
          b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,'TNVC','G',b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
          b_phong,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,
          b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,b_ma_sp,b_cdich,1,b_phi,b_tien,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,'','',b_so_id_kt,b_nsd);
    insert into bh_ptn_dvi values(
        b_ma_dvi,b_so_id,b_so_id,0,b_kieu_hd,b_so_hd,b_so_hd_g,b_dtuong,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_ngay_hoi,b_so_idP,b_phi,b_thue,b_ttoan);
    for b_lp in 1..tt_ngay.count loop
        insert into bh_ptn_tt values(b_ma_dvi,b_so_id,tt_ngay(b_lp),tt_tien(b_lp));
    end loop;
    for b_lp in 1..dk_lh_nv.count loop
      insert into bh_ptn_dk values(b_ma_dvi,b_so_id,b_so_id,b_lp,
        dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),dk_kieu(b_lp),dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),
        dk_cap(b_lp),dk_ma_dk(b_lp),dk_lh_nv(b_lp),dk_t_suat(b_lp),dk_thue(b_lp),dk_ttoan(b_lp),
        dk_ptB(b_lp),dk_ptG(b_lp),dk_phiG(b_lp),dk_lkeM(b_lp),dk_lkeP(b_lp),dk_lkeB(b_lp),dk_luy(b_lp),dk_lh_bh(b_lp));
    end loop;
  insert into bh_ptn_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
    select json_object('ma_dvi' value b_ma_dvi,'nsd' value b_nsd,'so_id' value b_so_id,'so_hd' value b_so_hd,
        'kieu_hd' value b_kieu_hd,'nv' value 'PTN','ngay_ht' value b_ngay_ht,'ngay_cap' value b_ngay_cap,
        'ngay_hl' value b_ngay_hl,'ngay_kt' value b_ngay_kt,'cb_ql' value b_ma_cb,'phong' value b_phong,
        'kieu_kt' value b_kieu_kt,'ma_kt' value b_ma_kt,'dly_tke' value ' ','hhong' value b_hhong,
        'pt_hhong' value 'D','ma_kh' value b_ma_kh,'ten' value b_ten,'kieu_gt' value b_kieu_gt,
        'ma_gt' value b_ma_gt,'so_id_d' value b_so_idD,'so_id_g' value b_so_idG,'ttrang' value b_ttrang,
        'dvi_ksoat' value b_ma_dvi,'ksoat' value b_nsd,'bangg' value 'bh_ptncc,bh_ptnnn,bh_ptnvc,bh_ptnch',
        'c_thue' value b_c_thue,'nt_tien' value b_nt_tien,'nt_phi' value b_nt_phi,'tien' value b_tien,
        'phi' value b_ttoan-b_thue,'thue' value b_thue returning clob) into b_txt from dual;
    PBH_HD_GOC_NH(b_txt,b_loi);
    if b_loi is not null then return; end if;
end if;
if b_ttrang='D' then
    PBH_KE_CTI_NHOM(b_ma_dvi,b_so_idD,b_so_idD,b_ma_ke,b_loi);
    if b_loi is null then return; end if;
    insert into bh_hd_goc_ttindt values(b_ma_dvi,b_so_idD,b_so_idD,'PTN',b_dtuong,b_ma_kh,b_ngay_kt,'',b_ma_ke);
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PTNVCG_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(1000); b_lenh varchar2(2000); b_i1 number;
    dt_ct clob; dt_dk clob; dt_dkbs clob; dt_lt clob; dt_kbt clob; dt_kytt clob; dt_ttt clob;
--  Chung
    b_so_id number; b_so_hd varchar2(20); b_ngay_ht number; b_ttrang varchar2(1); b_kieu_hd varchar2(1); b_so_hd_g varchar2(20);
    b_kieu_kt varchar2(1); b_ma_kt varchar2(20); b_kieu_gt varchar2(1); b_ma_gt varchar2(20); b_ma_cb varchar2(20);
    b_so_hdL varchar2(20); b_loai_kh varchar2(1); b_ma_kh varchar2(20); b_ten nvarchar2(500); b_dchi nvarchar2(500);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_gio_hl varchar2(20); b_ngay_hl number; b_gio_kt varchar2(20); b_ngay_kt number; b_ngay_cap number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_c_thue varchar2(1);
    b_phi number; b_giam number; b_thue number; b_ttoan number; b_hhong number;
    b_so_idG number; b_so_idD number; b_ngayD number; b_phong varchar2(10);
    -- thanh toan phi
    tt_ngay pht_type.a_num; tt_tien pht_type.a_num;

--  Rieng
    b_ma_sp varchar2(10); b_cdich varchar2(10); b_lvuc varchar2(500); b_dtuong nvarchar2(200);
    b_dthu number; b_ngay_hoi number; b_so_idP number;
    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var; dk_ma_ct pht_type.a_var;
    dk_kieu pht_type.a_var; dk_tien pht_type.a_num; dk_pt pht_type.a_num; dk_ppt pht_type.a_num; dk_phi pht_type.a_num;
    dk_thue pht_type.a_num; dk_ttoan pht_type.a_num; dk_cap pht_type.a_num; dk_ma_dk pht_type.a_var;
    dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num; dk_ptB pht_type.a_num;
    dk_ptG pht_type.a_num; dk_phiG pht_type.a_num; dk_lkeM pht_type.a_var; dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var;
    dk_luy pht_type.a_var; dk_ktru pht_type.a_var; dk_lh_bh pht_type.a_var;
-- xu ly
    b_ngay_htC number;
begin
-- Nam - Nhap
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_dkbs,dt_lt,dt_kbt,dt_ttt,dt_kytt');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_dkbs,dt_lt,dt_kbt,dt_ttt,dt_kytt using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_dkbs);
FKH_JSa_NULL(dt_lt); FKH_JSa_NULL(dt_kbt); FKH_JSa_NULL(dt_ttt); FKH_JSa_NULL(dt_kytt);
if b_so_id<>0 then
    select count(*) into b_i1 from bh_ptnvc where so_id=b_so_id;
    if b_i1<>0 then
        select ngay_ht,kieu_hd,ttrang into b_ngay_htC,b_kieu_hd,b_ttrang from bh_ptnvc
            where so_id=b_so_id for update nowait;
        if sql%rowcount=0 then b_loi:='loi:Va cham NSD:loi'; raise PROGRAM_ERROR; end if;
        if b_ttrang not in('T','D') then b_kieu_hd:='X'; else b_kieu_hd:='N'; end if;
        PBH_PTNVC_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_kieu_hd,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
else
    PHT_ID_MOI(b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_HD_JS_TEST(
    b_ma_dvi,b_nsd,b_so_id,b_ngay_htC,'bh_ptnvc',dt_ct,dt_kytt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_loai_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,
    b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_ngayD,b_phong,b_ma_cb,b_ma_kh,
    tt_ngay,tt_tien,b_loi,'PTN');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_PTNVCG_TESTr(
    dt_ct,dt_dk,dt_dkbs,b_so_idP,
    b_ma_sp,b_cdich,b_lvuc,b_dtuong,b_dthu,b_ngay_hoi,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_ppt,dk_phi,dk_thue,dk_ttoan,dk_cap,dk_ma_dk,
    dk_lh_nv,dk_t_suat,dk_ptB,dk_ptG,dk_phiG,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy,dk_ktru,dk_lh_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_PTNVCG_NH_NH(
    -- chung
    b_ma_dvi,b_nsd,b_so_id,dt_ct,dt_dk,dt_dkbs,dt_lt,dt_kbt,dt_ttt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,
    b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
    b_so_hdL,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,
    b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_phong,
    tt_ngay,tt_tien,
    -- rieng
    b_so_idP,b_ma_sp,b_cdich,b_lvuc,b_dtuong,b_dthu,b_ngay_hoi,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_ppt,dk_phi,dk_thue,dk_ttoan,dk_cap,dk_ma_dk,
    dk_lh_nv,dk_t_suat,dk_ptB,dk_ptG,dk_phiG,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy,dk_ktru,dk_lh_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hd' value b_so_hd, 'ma_kh' value b_ma_kh) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNVCG_TESTr(
    dt_ct clob,dt_dk clob,dt_dkbs clob, b_so_idP out number,
    b_ma_sp out varchar2,b_cdich out varchar2,b_lvuc out varchar2,b_dtuong out nvarchar2,
    b_dthu out number, b_ngay_hoi out number,

    dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,dk_tc out pht_type.a_var,dk_ma_ct out pht_type.a_var,
    dk_kieu out pht_type.a_var,dk_tien out pht_type.a_num,dk_pt out pht_type.a_num,dk_pphi out pht_type.a_num,dk_phi out pht_type.a_num,
    dk_thue out pht_type.a_num,dk_ttoan out pht_type.a_num, dk_cap out pht_type.a_num,dk_ma_dk out pht_type.a_var,
    dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,dk_ptB out pht_type.a_num,
    dk_ptG out pht_type.a_num,dk_phiG out pht_type.a_num,dk_lkeM out pht_type.a_var,dk_lkeP out pht_type.a_var,dk_lkeB out pht_type.a_var,
    dk_luy out pht_type.a_var,dk_ktru out pht_type.a_var,dk_lh_bh out pht_type.a_var,

    b_loi out varchar2)
AS
    b_ttrang varchar2(1); b_i1 number; b_kt number; b_lenh varchar2(2000);
    b_ngay_hl number; b_ngay_kt number; b_loai_khM varchar2(1);
    b_tygia number; b_c_thue varchar2(1); b_nt_tien varchar2(5);
    b_nt_phi varchar2(5); b_tp number:=0;b_thueH number;b_ttoanH number;
    dk_phiB pht_type.a_num;

    dkB_ma pht_type.a_var; dkB_ten pht_type.a_nvar; dkB_tc pht_type.a_var; dkB_ma_ct pht_type.a_var;
    dkB_tien pht_type.a_num; dkB_pt pht_type.a_num; dkB_phi pht_type.a_num;
    dkB_pphi pht_type.a_num; dkB_thue pht_type.a_num; dkB_ttoan pht_type.a_num;

    dkB_cap pht_type.a_num; dkB_ma_dk pht_type.a_var; dkB_kieu pht_type.a_var;
    dkB_lh_nv pht_type.a_var; dkB_t_suat pht_type.a_num; dkB_ptB pht_type.a_num;
    dkB_ptG pht_type.a_num; dkB_phiG pht_type.a_num; dkB_phiB pht_type.a_num;
    dkB_lkeM pht_type.a_var; dkB_lkeP pht_type.a_var; dkB_lkeB pht_type.a_var; dkB_luy pht_type.a_var;
    dkB_ktru pht_type.a_var;dkB_lh_bh pht_type.a_var;

begin
-- Nam - Nhap
b_lenh:=FKH_JS_LENH('ttrang,loai_kh,ma_sp,lvuc,dtuong,dthu,thue,ttoan,nt_tien,nt_phi,tygia,c_thue,ngay_hl,ngay_kt,ngay_hoi');
EXECUTE IMMEDIATE b_lenh into b_ttrang,b_loai_khM,b_ma_sp,b_lvuc,b_dtuong,b_dthu,
                              b_thueH,b_ttoanH,b_nt_tien,b_nt_phi,b_tygia,b_c_thue,b_ngay_hl,b_ngay_kt,b_ngay_hoi using dt_ct;
b_ma_sp:=nvl(trim(b_ma_sp),' ');
if b_ma_sp<>' ' and FBH_PTNVC_SP_HAN(b_ma_sp)<>'C' then b_loi:='loi:Sai ma san pham:loi'; return; end if;
b_lvuc:=PKH_MA_TENl(b_lvuc);
if b_lvuc<>' ' and FBH_MA_LVUC_HAN(b_lvuc)<>'C' then b_loi:='loi:Sai ma linh vuc:loi'; return; end if;
b_c_thue:=nvl(trim(b_c_thue),'C');
if nvl(trim(b_nt_phi),'VND')<>'VND' then b_tp:=2; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,tien,pt,pphi,phi,thue,cap,ma_dk,kieu,lh_nv,t_suat,ptb,phib,lkem,lkep,lkeb,luy,ktru');
EXECUTE IMMEDIATE b_lenh bulk collect into
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_tien,dk_pt,dk_pphi,dk_phi,dk_thue,dk_cap,dk_ma_dk,dk_kieu,
    dk_lh_nv,dk_t_suat,dk_ptB,dk_phiB,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy,dk_ktru using dt_dk;
b_kt:=dk_ma.count;
if b_kt=0 then b_loi:='loi:Nhap dieu khoan:loi'; return; end if;
for b_lp in 1..b_kt loop
    dk_ma(b_lp):=nvl(trim(dk_ma(b_lp)),' '); dk_lh_bh(b_lp):='C'; dk_phiB(b_lp):=nvl(dk_phiB(b_lp),0);
    if dk_ma(b_lp)=' ' then b_loi:='loi:Nhap dieu khoan chinh dong '||to_char(b_lp)||':loi'; return; end if;
end loop;
if trim(dt_dkbs) is not null then
    EXECUTE IMMEDIATE b_lenh bulk collect into
        dkB_ma,dkB_ten,dkB_tc,dkB_ma_ct,dkB_tien,dkB_pt,dkB_pphi,dkB_phi,dkB_thue,dkB_cap,dkB_ma_dk,dkB_kieu,
        dkB_lh_nv,dkB_t_suat,dkB_ptB,dkB_phiB,dkB_lkeM,dkB_lkeP,dkB_lkeB,dkB_luy,dkB_ktru using dt_dkbs;
    for b_lp in 1..dkB_ma.count loop
        b_kt:=b_kt+1; dk_ma(b_kt):=nvl(trim(dkB_ma(b_lp)),' '); dk_lh_bh(b_kt):='M';
        if dk_ma(b_kt)=' ' then b_loi:='loi:Nhap dieu khoan mo rong dong '||to_char(b_lp)||':loi'; return; end if;
        dk_ten(b_kt):=dkB_ten(b_lp); dk_tc(b_kt):=dkB_tc(b_lp);
        dk_ma_ct(b_kt):=dkB_ma_ct(b_lp); dk_cap(b_kt):=dkB_cap(b_lp); dk_kieu(b_kt):=dkB_kieu(b_lp);
        dk_tien(b_kt):=dkB_tien(b_lp); dk_pt(b_kt):=dkB_pt(b_lp);dk_pphi(b_kt):=dkB_pphi(b_lp);
        dk_phi(b_kt):=dkB_phi(b_lp);dk_thue(b_kt):=dkB_thue(b_lp);
        dk_ma_dk(b_kt):=dkB_ma_dk(b_lp); dk_lh_nv(b_kt):=dkB_lh_nv(b_lp);
        dk_t_suat(b_kt):=dkB_t_suat(b_lp); dk_ptB(b_kt):=dkB_ptB(b_lp); dk_phiB(b_kt):=nvl(dkB_phiB(b_lp),0); dk_lkeM(b_kt):=dkB_lkeM(b_lp);
        dk_lkeP(b_kt):=dkB_lkeP(b_lp); dk_lkeB(b_kt):=dkB_lkeB(b_lp); dk_luy(b_kt):=dkB_luy(b_lp); dk_ktru(b_kt):=dkB_ktru(b_lp);
    end loop;
end if;
for b_lp in 1..dk_ma.count loop
    dk_ma(b_lp):=trim(dk_ma(b_lp));
    if dk_ma(b_lp) is null then b_loi:='loi:Loi nhap chi tiet nghiep vu dong '||to_char(b_lp)||':loi'; return; end if;
    dk_lh_nv(b_lp):=nvl(trim(dk_lh_nv(b_lp)),' '); dk_ktru(b_lp):=nvl(trim(dk_ktru(b_lp)),'K');
    dk_tien(b_lp):=nvl(dk_tien(b_lp),0); dk_phi(b_lp):=nvl(dk_phi(b_lp),0);
    if dk_tien(b_lp)=0 and dk_lkeM(b_lp) not in ('T','N','K') then
      b_loi:='loi:Chua nhap muc trach nhiem dieu khoan '||dk_ma(b_lp)||':loi'; return;
    end if;
    if b_c_thue='K' then dk_thue(b_lp):=0; else dk_thue(b_lp):=nvl(dk_thue(b_lp),0); end if;
    dk_ttoan(b_lp):=dk_phi(b_lp)+dk_thue(b_lp);
    if dk_tien(b_lp)<>0 then
      b_i1:=round(dk_phiB(b_lp)/dk_tien(b_lp)*100,20);
      dk_pt(b_lp):= b_i1 - round(((dk_phiB(b_lp)/dk_tien(b_lp))-(dk_phi(b_lp)/dk_tien(b_lp)))*100 ,20);
    end if;
end loop;
b_so_idP:=FBH_PTNVC_BPHI_SO_IDh(b_ma_sp,b_lvuc,b_ngay_hl);
if b_so_idP=0 then b_loi:='loi:Sai bieu phi:loi'; return;
end if;
PBH_HD_THAY_PHIg(b_nt_tien,b_nt_tien,b_tygia,b_thueH,b_ttoanH,dk_lh_nv,dk_tien,dk_phi,dk_thue,dk_ttoan,b_loi);
if b_loi is not null then return; end if;
for b_lp in 1..dk_ma.count loop
    if dk_phiB(b_lp)>dk_phi(b_lp) then
        dk_phiG(b_lp):=dk_phiB(b_lp)-dk_phi(b_lp);
        dk_ptG(b_lp):=round(dk_phiG(b_lp)*100/dk_phiB(b_lp),2);
    else
        dk_ptG(b_lp):=0; dk_phiG(b_lp):=0;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PTNVC_PHIGr(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_i2 number; b_iX number; b_lenh varchar2(1000);
    dt_ct clob; dt_dk clob; dt_dkbs clob;
    b_tp number:=0; b_nt_phi varchar2(5); b_nt_tien varchar2(5);
    b_so_hdG varchar2(20); b_ngay_hl number; b_ngay_kt number; b_ngay_cap number;
    b_tygia number:=1; b_kho number:=1; b_c_thue varchar2(1);
    b_ngay_hlC number; b_ngay_ktC number; b_kt number;
    b_phi number:=0; b_tien number; b_so_idG number:=0;

    dk_ma pht_type.a_var;dk_ten pht_type.a_nvar;dk_tc pht_type.a_var;
    dk_ma_ct pht_type.a_var;dk_kieu pht_type.a_var;
    dk_lkeM pht_type.a_var;dk_lkeP pht_type.a_var;dk_lkeB pht_type.a_var;
    dk_luy pht_type.a_var;
    dk_ma_dk pht_type.a_var;dk_ma_dkC pht_type.a_var;dk_lh_nv pht_type.a_var;dk_t_suat pht_type.a_num;
    dk_cap pht_type.a_num;dk_pphi pht_type.a_num;
    dk_tien pht_type.a_num;dk_pt pht_type.a_num;dk_phi pht_type.a_num;
    dk_thue pht_type.a_num;dk_ttoan pht_type.a_num; dk_tientt pht_type.a_var;
    dk_ptB pht_type.a_num;dk_phiB pht_type.a_num;dk_bt pht_type.a_num;
    dk_pp pht_type.a_var;dk_ptk pht_type.a_var;
    dk_maG pht_type.a_var;dk_tienG pht_type.a_num;dk_ptG pht_type.a_num;
    dk_phiG pht_type.a_num;

    dkbs_ma pht_type.a_var;dkbs_ten pht_type.a_nvar;dkbs_tc pht_type.a_var;
    dkbs_ma_ct pht_type.a_var;dkbs_kieu pht_type.a_var;
    dkbs_lkeM pht_type.a_var;dkbs_lkeP pht_type.a_var;dkbs_lkeB pht_type.a_var;
    dkbs_luy pht_type.a_var;
    dkbs_ma_dk pht_type.a_var;dkbs_ma_dkC pht_type.a_var;dkbs_lh_nv pht_type.a_var;dkbs_t_suat pht_type.a_num;
    dkbs_cap pht_type.a_num;dkbs_pphi pht_type.a_num;
    dkbs_tien pht_type.a_num;dkbs_pt pht_type.a_num;dkbs_phi pht_type.a_num;
    dkbs_thue pht_type.a_num;dkbs_ttoan pht_type.a_num;dkbs_tientt pht_type.a_var;
    dkbs_ptB pht_type.a_num;dkbs_phiB pht_type.a_num;
    dkbs_pp pht_type.a_var;dkbs_ptk pht_type.a_var;dkbs_bt pht_type.a_num;
    dkbs_maG pht_type.a_var; dkbs_tienG pht_type.a_num; dkbs_ptG pht_type.a_num;
    dkbs_phiG pht_type.a_num;
    a_ma pht_type.a_var;
    cs_dk clob; cs_dkbs clob; b_dk_txt clob; b_dkbs_txt clob;

begin
-- Nam - tinh phi prorata
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_dkbs');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_dkbs using b_oraIn;
b_lenh:=FKH_JS_LENH('so_hd_g,ngay_hl,ngay_kt,ngay_cap,nt_phi,nt_tien,tygia,c_thue');
EXECUTE IMMEDIATE b_lenh into b_so_hdG,b_ngay_hl,b_ngay_kt,b_ngay_cap,b_nt_phi,b_nt_tien,b_tygia,b_c_thue using dt_ct;
if b_so_hdG<>' ' then
    b_so_idG:=FBH_PTNVC_SO_ID(b_ma_dvi,b_so_hdG);
    if b_so_idG=0 then b_loi:='loi:GCN goc da xoa:loi'; return; end if;
end if;
if b_tygia is null or b_tygia=0 then b_tygia:=1; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tien,ptb,pphi,pp,pt,phi,cap,tc,ma_ct,ma_dk,ma_dkc,kieu,lh_nv,t_suat,phib,lkem,lkep,lkeb,ptk,luy,tientt,bt');
EXECUTE IMMEDIATE b_lenh bulk collect into dk_ma,dk_ten,dk_tien,dk_ptB,dk_pphi,dk_pp,dk_pt,dk_phi,dk_cap,dk_tc,dk_ma_ct,
        dk_ma_dk,dk_ma_dkC,dk_kieu,dk_lh_nv,dk_t_suat,dk_phiB,dk_lkeM,dk_lkeP,dk_lkeB,dk_ptk,dk_luy,dk_tientt,dk_bt using dt_dk;
if dk_ma.count=0 then b_loi:='loi:Nhap so tien bao hiem:loi'; return; end if;
if trim(dt_dkbs) is not null then
  EXECUTE IMMEDIATE b_lenh bulk collect into dkbs_ma,dkbs_ten,dkbs_tien,dkbs_ptB,dkbs_pphi,dkbs_pp,dkbs_pt,dkbs_phi,dkbs_cap,dkbs_tc,dkbs_ma_ct,
        dkbs_ma_dk,dkbs_ma_dkC,dkbs_kieu,dkbs_lh_nv,dkbs_t_suat,dkbs_phiB,dkbs_lkeM,dkbs_lkeP,dkbs_lkeB,dkbs_ptk,dkbs_luy,dkbs_tientt,dkbs_bt using dt_dkbs;
end if;
FBH_HD_KHO(b_ngay_hl,b_ngay_kt,b_kho,b_loi);
if b_loi is not null then return; end if;
b_kt:=0;
if b_nt_phi<>'VND' then b_tp:=2; end if;
for b_lp_dk in 1..dk_ma.count loop
  b_kt:=b_kt+1;
  a_ma(b_kt):=dk_ma(b_lp_dk); dk_pp(b_lp_dk):=nvl(dk_pp(b_lp_dk),' ');
  if dk_lkeP(b_lp_dk) not in ('T','N','K') then
    if dk_tien(b_lp_dk)<>0 then
       if dk_ptk(b_lp_dk)<>'P' then
          if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
             dk_phiB(b_lp_dk):=ROUND((dk_ptB(b_lp_dk) + dk_pphi(b_lp_dk)) / b_tygia *b_kho,b_tp);
          elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
             dk_phiB(b_lp_dk):=ROUND((dk_ptB(b_lp_dk) + dk_pphi(b_lp_dk)) * b_tygia *b_kho,b_tp);
          else
             dk_phiB(b_lp_dk):=ROUND((dk_ptB(b_lp_dk) + dk_pphi(b_lp_dk)) *b_kho,b_tp);
          end if;
       elsif dk_ptk(b_lp_dk)<>'T' and dk_tien(b_lp_dk)<>0 and dk_ptB(b_lp_dk)<>0 then
          if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
             dk_phiB(b_lp_dk):=ROUND(((dk_ptB(b_lp_dk) * dk_tien(b_lp_dk)) + dk_pphi(b_lp_dk)) / b_tygia *b_kho/ 100,b_tp);
          elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
             dk_phiB(b_lp_dk):=ROUND(((dk_ptB(b_lp_dk) * dk_tien(b_lp_dk)) + dk_pphi(b_lp_dk)) * b_tygia *b_kho/ 100,b_tp);
          else
             dk_phiB(b_lp_dk):=ROUND(((dk_ptB(b_lp_dk) * dk_tien(b_lp_dk)) + dk_pphi(b_lp_dk)) *b_kho/ 100,b_tp);
          end if;
       else dk_phiB(b_lp_dk):=0;
       end if;
      end if;
      if dk_pp(b_lp_dk) = 'DG' and dk_pt(b_lp_dk)>0 then dk_phi(b_lp_dk):=ROUND(dk_pt(b_lp_dk),b_tp);
      elsif dk_pp(b_lp_dk) = 'DP' and dk_tien(b_lp_dk)<>0 and dk_pt(b_lp_dk)<>0 then
           dk_phi(b_lp_dk):=ROUND((dk_pt(b_lp_dk)*dk_tien(b_lp_dk) + dk_pphi(b_lp_dk)) *b_kho/ 100,b_tp);
      elsif dk_phiB(b_lp_dk)<>0 then
           dk_phi(b_lp_dk):=dk_phiB(b_lp_dk);
        if dk_pp(b_lp_dk) = 'GG' then
             dk_phi(b_lp_dk):=ROUND((dk_phi(b_lp_dk)-dk_pt(b_lp_dk)),b_tp);
        elsif dk_pp(b_lp_dk) = 'GT' and dk_tien(b_lp_dk)<>0 and dk_pt(b_lp_dk)<>0 then
             dk_phi(b_lp_dk):= dk_phi(b_lp_dk) - ROUND((dk_pt(b_lp_dk)*dk_tien(b_lp_dk) + dk_pphi(b_lp_dk)) *b_kho/ 100,b_tp);
        elsif dk_pp(b_lp_dk) = 'GP' and dk_pt(b_lp_dk)<>0 then
             dk_phi(b_lp_dk):= dk_phi(b_lp_dk) - ROUND(dk_pt(b_lp_dk)*dk_phiB(b_lp_dk)/ 100,b_tp);
        if dk_phi(b_lp_dk)<0 then dk_phi(b_lp_dk):=0; end if;
        end if;
      elsif dk_phiB(b_lp_dk)=0 then dk_phi(b_lp_dk):=0;
      end if;
      if dk_phiB(b_lp_dk)=0 then dk_phiB(b_lp_dk):=dk_phi(b_lp_dk); end if;
  end if;
end loop;

for b_lp_dkbs in 1..dkbs_ma.count loop
  b_kt:=b_kt+1;
  a_ma(b_kt):=dkbs_ma(b_lp_dkbs); dkbs_pp(b_lp_dkbs):=nvl(dkbs_pp(b_lp_dkbs),' ');
  if dkbs_lkeP(b_lp_dkbs) not in ('T','N','K') then
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
     else dkbs_phiB(b_lp_dkbs):=0;
     end if;
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
    if dkbs_phiB(b_lp_dkbs)=0 then dkbs_phiB(b_lp_dkbs):=dkbs_phi(b_lp_dkbs); end if;
  end if;
end loop;
if b_so_idG<>0 and b_ngay_hl<b_ngay_cap then
    select ngay_hl,ngay_kt into b_ngay_hlC,b_ngay_ktC from bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_idG;
    b_i1:=FKH_KHO_NGSO(b_ngay_cap,b_ngay_ktC)/FKH_KHO_NGSO(b_ngay_hlC,b_ngay_ktC);
    b_i2:=FKH_KHO_NGSO(b_ngay_cap,b_ngay_kt)/FKH_KHO_NGSO(b_ngay_hl,b_ngay_kt);
    b_i1:=round(b_i1,2); b_i2:=round(b_i2,2);
    select ma,tien,pt,phi bulk collect into dk_maG,dk_tienG,dk_ptG,dk_phiG from bh_ptnvc_dk
        where ma_dvi=b_ma_dvi and so_id=b_so_idG and lh_bh<>'M' order by bt;
    select ma,tien,pt,phi bulk collect into dkbs_maG,dkbs_tienG,dkbs_ptG,dkbs_phiG from bh_ptnvc_dk
        where ma_dvi=b_ma_dvi and so_id=b_so_idG and lh_bh<>'C' order by bt;
    for b_lp in 1..dk_maG.count loop
        b_iX:=b_lp; b_tien:=0;
        for b_lp1 in reverse 1..b_iX loop
            if dk_tienG(b_lp1)<>0 then b_tien:=dk_tienG(b_lp1); exit; end if;
        end loop;
        b_iX:=FKH_ARR_VTRI(dk_ma,dk_maG(b_lp));
        if b_iX=0 or b_tien=0 then continue; end if;
        b_phi:=b_tien*dk_ptG(b_lp)/100;
        b_phi:=dk_phiG(b_lp)-round(b_phi*b_i1,b_tp);            -- Phi da dung
        if dk_pp(b_iX)<>'DG' then
           dk_phi(b_iX):=b_phi+round(dk_phi(b_iX)*b_i2,b_tp);      -- Phi con lai: round(dk_phi(b_iX)*b_i2,b_tp);
        end if;
    end loop;
    for b_lp in 1..dkbs_maG.count loop
        b_iX:=b_lp; b_tien:=0;
        for b_lp1 in reverse 1..b_iX loop
            if dkbs_tienG(b_lp1)<>0 then b_tien:=dkbs_tienG(b_lp1); exit; end if;
        end loop;
        b_iX:=FKH_ARR_VTRI(dkbs_ma,dkbs_maG(b_lp));
        if b_iX=0 or b_tien=0 then continue; end if;
        b_phi:=b_tien*dkbs_ptG(b_lp)/100;
        b_phi:=dkbs_phiG(b_lp)-round(b_phi*b_i1,b_tp);             -- Phi da dung
        if dkbs_pp(b_iX)<>'DG' then
           dkbs_phi(b_iX):=b_phi+round(dkbs_phi(b_iX)*b_i2,b_tp);      -- Phi con lai: round(dk_phi(b_iX)*b_i2,b_tp);
        end if;
    end loop;
end if;
if b_c_thue<>'C' then
    for b_lp in 1..dk_ma.count loop dk_thue(b_lp):=0; end loop;
    for b_lp in 1..dkbs_ma.count loop dkbs_thue(b_lp):=0; end loop;
else
    for b_lp in 1..dk_ma.count loop dk_thue(b_lp):=round(dk_phi(b_lp)*dk_t_suat(b_lp)/100,b_tp); end loop;
    for b_lp in 1..dkbs_ma.count loop dkbs_thue(b_lp):=round(dkbs_phi(b_lp)*dkbs_t_suat(b_lp)/100,b_tp); end loop;
end if;
FBH_PTN_PHIb(b_tp,dk_ma,dk_ma_ct,dk_lkeP,dk_cap,dk_phi,dk_thue,dk_ttoan,b_loi);
if b_loi is not null then return; end if;
FBH_PTN_PHIb(b_tp,dkbs_ma,dkbs_ma_ct,dkbs_lkeP,dkbs_cap,dkbs_phi,dkbs_thue,dkbs_ttoan,b_loi);
if b_loi is not null then return; end if;
b_oraOut:='';
for b_lp in 1..dk_ma.count loop
    select json_object('ma' value dk_ma(b_lp),'ten' value dk_ten(b_lp),'tc' value dk_tc(b_lp),'ma_ct' value dk_ma_ct(b_lp),
    'kieu' value dk_kieu(b_lp),'lkeM' value dk_lkeM(b_lp),'lkeP' value dk_lkeP(b_lp),'lkeB' value dk_lkeB(b_lp),
    'luy' value dk_luy(b_lp),'ma_dk' value dk_ma_dk(b_lp),'ma_dkC' value dk_ma_dkC(b_lp),
    'lh_nv' value dk_lh_nv(b_lp),'t_suat' value dk_t_suat(b_lp),'cap' value dk_cap(b_lp),
    'pp' value dk_pp(b_lp),'pphi' value dk_pphi(b_lp),'ptK' value dk_ptk(b_lp),'bt' value dk_bt(b_lp),
    'tien' value dk_tien(b_lp),'pt' value dk_pt(b_lp),
    'phi' value dk_phi(b_lp),'thue' value dk_thue(b_lp),'ttoan' value dk_ttoan(b_lp),'tientt' value dk_tientt(b_lp),
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
    'tien' value dkbs_tien(b_lp),'pt' value dkbs_pt(b_lp),
    'phi' value dkbs_phi(b_lp),'thue' value dkbs_thue(b_lp),'ttoan' value dkbs_ttoan(b_lp),'tientt' value dkbs_tientt(b_lp),
    'ptB' value dkbs_ptB(b_lp),'phiB' value dkbs_phiB(b_lp) returning clob) into b_dkbs_txt from dual;
    if b_lp>1 then cs_dkbs:=cs_dkbs||','; end if;
    cs_dkbs:=cs_dkbs||b_dkbs_txt;
end loop;
if cs_dkbs is not null then cs_dkbs:='['||cs_dkbs||']'; end if;
select json_object('dt_dk' value cs_dk,'dt_dkbs' value cs_dkbs returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNVC_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10);
    b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number;
    b_dong number; cs_lke clob;
begin
-- Nam - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_ptnvc where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ptnvc where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','PTN','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_ptnvc where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and phong=b_phong;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ptnvc  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_hd)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ptnvc where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ptnvc  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNVC_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number; b_so_hd varchar2(20):=FKH_JS_GTRIs(b_oraIn,'so_hd');
begin
-- Nam - Hoi so ID qua so hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
b_so_id:=FBH_PTNVC_SO_ID(b_ma_dvi,b_so_hd);
if b_so_id=0 then b_loi:='loi:So hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNVC_HDBS(
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
select nvl(min(so_id_d),0) into b_so_idD from bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_so_idD<>0 then
    select count(*) into b_dong from bh_ptnvc where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hd,ttoan,ttrang,ma_dvi,so_id,
           'ma_sdbs' value PKH_TEN_TENl(FBH_PTNVC_TXT(ma_dvi,so_id,'ma_sdbs'))
    ) order by so_id desc returning clob)
        into cs_lke from bh_ptnvc where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;

