create or replace function FBH_PTNNN_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_id number; b_txt clob;
    a_ds_ct pht_type.a_clob;
begin
-- nam - Tra gia tri varchar2 trong txt
select count(*) into b_i1 from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
	select txt into b_txt from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
	PKH_JS_BONH(b_txt); b_kq:=FKH_JS_GTRIs(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_PTNNN_TXTn(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return number
AS
    b_kq number:=0; b_i1 number; b_id number; b_txt clob; b_lenh varchar2(1000);
    a_ds_ct pht_type.a_clob;
begin
-- nam - Tra gia tri num trong txt
select count(*) into b_i1 from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    PKH_JS_BONH(b_txt); b_kq:=FKH_JS_GTRIn(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace  function FBH_PTNNN_SO_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Nam - Tra so hop dong
select min(so_hd) into b_kq from bh_ptnnn where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace  function FBH_PTNNN_SO_IDd(b_ma_dvi varchar2,b_so_id number) return number
as
    b_kq number;
begin
-- Nam - Tra so id dau
select nvl(min(so_id_d),0) into b_kq from bh_ptnnn where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_PTNNN_SO_IDc(b_ma_dvi varchar2,b_so_id number,b_ttrang varchar2:='K') return number
as
    b_kq number:=0; b_so_idD number:=b_so_id;
begin
-- Nam - Tra so id cuoi
b_so_idD:=FBH_PTNNN_SO_IDd(b_ma_dvi,b_so_id);
if b_ttrang<>'C' then
    select nvl(max(so_id),0) into b_kq from bh_ptnnn where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
else
    select nvl(max(so_id),0) into b_kq from bh_ptnnn where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D';
end if;
return b_kq;
end;
/
create or replace function FBH_PTNNN_KIEU_HDd(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(1); b_so_idD number:=FBH_PTNNN_SO_IDd(b_ma_dvi,b_so_id);
begin
-- Nam - Tra so hop dong
select nvl(min(kieu_hd),' ') into b_kq from bh_ptnnn where ma_dvi=b_ma_dvi and so_id=b_so_idD;
return b_kq;
end;
/
create or replace function FBH_PTNNN_SO_ID(b_ma_dvi varchar2,b_so_hd varchar2,b_nv varchar2:='') return number
as
    b_kq number;
begin
-- Nam - Tra so id
if nvl(b_nv,' ')=' ' then 
    select nvl(min(so_id),0) into b_kq from bh_ptnnn where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
else 
    select nvl(min(so_id),0) into b_kq from bh_ptnnn where ma_dvi=b_ma_dvi and so_hd=b_so_hd and nv=b_nv;
end if;
return b_kq;
end;
/
create or replace function FBH_PTNNN_SO_IDt(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Nam - Tra so id 
b_so_idD:=FBH_PTNNN_SO_ID(b_ma_dvi,b_so_id);
select nvl(max(so_id),0) into b_kq from bh_ptnnn where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang in('T','D') and ngay_ht<=b_ngay;
return b_kq;
end;
/
create or replace function FBH_PTNNN_SO_IDb(
    b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Nam - Tra so id 
b_so_idD:=FBH_PTNNN_SO_ID(b_ma_dvi,b_so_id);
select nvl(max(so_id),0) into b_kq from bh_ptnnn where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D' and ngay_ht<=b_ngay;
return b_kq;
end;
/
create or replace procedure PBH_PTNNN_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_so_id number; b_so_hd varchar2(20);b_nv varchar2(10);
    b_lenh varchar2(2000); b_loi varchar2(100);
begin
-- Nam - Hoi so ID qua so hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
b_lenh:=FKH_JS_LENH('so_hd,nv');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_nv using b_oraIn;
b_so_id:=FBH_PTNNN_SO_ID(b_ma_dvi,b_so_hd,b_nv);
if b_so_id=0 then b_loi:='loi:So hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_PTNNN_BPHI_DKm(
    b_so_id number,b_ma varchar2,b_tien number,b_nv varchar2,b_bt out number,b_loi out varchar2)
AS
    b_i1 number; b_tienM number;
begin
-- Nam - Lay %phi theo khoang muc trach nhiem
b_loi:='loi:Loi xu ly FBH_PTNNN_BPHI_DKm:loi';
select count(*),nvl(max(tien),0) into b_i1,b_tienM from bh_ptnnn_phi_dk where
    so_id=b_so_id and ma=b_ma and lh_bh=b_nv and tien<=b_tien;
if b_i1=0 then b_loi:='loi:Khong tim duoc ty le phi theo muc trach nhiem:loi'; return; end if;
select nvl(min(bt),0) into b_bt from bh_ptnnn_phi_dk
    where so_id=b_so_id and ma=b_ma and lh_bh=b_nv and tien=b_tienM;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PTNNN_BPHI_DKm(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_so_id number; b_ma varchar2(10); b_tien number; b_bt number; b_pt number; b_phi number;
    b_nv varchar2(1); b_nhom varchar2(1); b_ma_sp varchar2(10); b_cdich varchar2(10); b_nghe varchar2(10); 
    b_pvi varchar2(10); b_ghan varchar2(1); b_gct number; b_gtv number; b_ngay_hl number;
begin
-- Nam - Lay %phi theo khoang muc trach nhiem
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nhom,ma_sp,cdich,nghe,pvi,ghan_m,gct,gtv,ngay_hl,nv,ma,tien');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_ma_sp,b_cdich,b_nghe,b_pvi,b_ghan,b_gct,b_gtv,b_ngay_hl,b_nv,b_ma,b_tien using b_oraIn;
b_ma_sp:=NVL(trim(b_ma_sp),' '); b_cdich:=NVL(trim(b_cdich),' '); b_nghe:=NVL(trim(b_nghe),' '); b_pvi:=NVL(trim(b_pvi),' ');
if b_ngay_hl in(0,30000101) then b_ngay_hl:=PKH_NG_CSO(sysdate); end if;
b_so_id:=FBH_PTNNN_BPHI_SO_IDh(b_nhom,b_ma_sp,b_cdich,b_nghe,b_pvi,b_ghan,b_gct,b_gtv,b_ngay_hl);
FBH_PTNNN_BPHI_DKm(b_so_id,b_ma,b_tien,b_nv,b_bt,b_loi);
for r_lp in (select * from bh_ptnnn_phi_dk where so_id=b_so_id and bt>=b_bt order by bt) loop
    if b_i1<>0 and r_lp.ma=b_ma then exit; end if;
    b_pt:=r_lp.pt; b_phi:=r_lp.phi;
    insert into temp_1(c1,n1,n2,n3) values(r_lp.ma,b_pt,b_phi,r_lp.bt);
    b_i1:=1;
end loop;
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object('ma' value c1,'ptb' value n1,'phi' value n2) order by n3 returning clob) into b_oraOut from temp_1;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNNN_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10);
    b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number; b_nv varchar2(1);
    b_dong number; cs_lke clob;
begin
-- Nam - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,klk,tu,den,nv');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_klk,b_tu,b_den,b_nv using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_ptnnn where ma_dvi=b_ma_dvi and nv=b_nv and
        ngay_ht=b_ngay_ht and nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ptnnn where
            ma_dvi=b_ma_dvi and nv=b_nv and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','PTN','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_ptnnn where ma_dvi=b_ma_dvi and nv=b_nv and
        ngay_ht=b_ngay_ht and phong=b_phong;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ptnnn  where
            ma_dvi=b_ma_dvi and nv=b_nv and ngay_ht=b_ngay_ht and phong=b_phong  order by so_hd)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ptnnn where ma_dvi=b_ma_dvi and nv=b_nv and ngay_ht=b_ngay_ht;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ptnnn  where
            ma_dvi=b_ma_dvi and nv=b_nv and ngay_ht=b_ngay_ht order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNNN_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10); b_so_hd varchar2(20);
    b_so_id number; b_ngay_ht number; b_klk varchar2(1); b_nv varchar2(1);
    b_trangKt number; b_tu number; b_den number;
    b_trang number; b_dong number; cs_lke clob;
begin
-- Nam - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,klk,trangkt,nv');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_klk,b_trangKt,b_nv using b_oraIn;
b_so_hd:=FBH_PTNNN_SO_HD(b_ma_dvi,b_so_id);
if b_so_hd is null then b_loi:='loi:GCN, hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
if b_klk ='N' then
    select count(*) into b_dong from bh_ptnnn where ma_dvi=b_ma_dvi and nv=b_nv and
        ngay_ht=b_ngay_ht and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_ptnnn where
            ma_dvi=b_ma_dvi and nv=b_nv and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ptnnn  where
            ma_dvi=b_ma_dvi and nv=b_nv and ngay_ht=b_ngay_ht  and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','PTN','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_ptnnn where ma_dvi=b_ma_dvi and nv=b_nv and
        ngay_ht=b_ngay_ht  and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_ptnnn where
            ma_dvi=b_ma_dvi and nv=b_nv and ngay_ht=b_ngay_ht  and phong=b_phong  order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ptnnn  where
            ma_dvi=b_ma_dvi and nv=b_nv and ngay_ht=b_ngay_ht  and phong=b_phong order by so_hd)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ptnnn where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht ;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_ptnnn where
            ma_dvi=b_ma_dvi and nv=b_nv and ngay_ht=b_ngay_ht   order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,nsd) obj,rownum sott from bh_ptnnn  where
            ma_dvi=b_ma_dvi and nv=b_nv and ngay_ht=b_ngay_ht  order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNNN_GOC_XOA(b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh varchar2,b_loi out varchar2)
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
create or replace procedure PBH_PTNNN_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh varchar2,b_loi out varchar2)
AS
    b_i1 number; b_so_idK number;  b_ttrang varchar2(1); b_ksoat varchar2(20); b_nsdC varchar2(20);
begin
-- Nam - Xoa
b_loi:='loi:Loi xu ly PBH_PTNNN_XOA_XOA:loi';
select count(*) into b_i1 from bh_ptnnn where so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select so_id_kt,ttrang,ksoat,nsd into b_so_idK,b_ttrang,b_ksoat,b_nsdC
    from bh_ptnnn where so_id=b_so_id;
if b_so_idK>0 then b_loi:='loi:Khong sua, xoa phuc hoi da hach toan ke toan:loi'; return; end if;
if b_nsdC<>b_nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
if trim(b_ksoat) is not null and b_ksoat<>b_nsd then b_loi:='loi:Khong sua, xoa GCN, hop dong da kiem soat:loi'; return; end if;
b_loi:='loi:Loi xoa Table bh_ptnnn:loi';
delete bh_hd_goc_ttindt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ptnnn_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ptnnn_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ptnnn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ptnnn_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_ptnnn where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_ttrang in('T','D') then
    PBH_PTN_GOC_XOA(b_ma_dvi,b_nsd,b_so_id,b_nh,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PTNNN_XOA(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Nam - Xoa GCN
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TNCC','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_PTNNN_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'X',b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNNN_PHIGr(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_i2 number; b_iX number; b_lenh varchar2(1000);
    dt_ct clob; dt_dk clob; dt_dkbs clob;
    b_so_dt number:=1; b_tp number:=0; b_nt_phi varchar2(5); b_nt_tien varchar2(5);
    b_so_hdG varchar2(20); b_ngay_hl number; b_ngay_kt number; b_ngay_cap number;
    b_tygia number:=1; b_kho number:=1; b_c_thue varchar2(1);
    b_ngay_hlC number; b_ngay_ktC number; b_kt number;
    b_phi number:=0; b_tien number; b_so_idG number:=0; b_so_id_dt number;

    dk_ma pht_type.a_var;dk_ten pht_type.a_nvar;dk_tc pht_type.a_var;
    dk_ma_ct pht_type.a_var;dk_kieu pht_type.a_var;
    dk_lkeM pht_type.a_var;dk_lkeP pht_type.a_var;dk_lkeB pht_type.a_var;
    dk_luy pht_type.a_var;
    dk_ma_dk pht_type.a_var;dk_ma_dkC pht_type.a_var;dk_lh_nv pht_type.a_var;dk_t_suat pht_type.a_num;
    dk_cap pht_type.a_num;
    dk_tien pht_type.a_num;dk_pt pht_type.a_num;dk_phi pht_type.a_num;
    dk_thue pht_type.a_num;dk_ttoan pht_type.a_num;
    dk_ptB pht_type.a_num;dk_phiB pht_type.a_num;dk_bt pht_type.a_num;
    dk_pp pht_type.a_var;dk_ptk pht_type.a_var;
    dk_maG pht_type.a_var;dk_tienG pht_type.a_num;dk_ptG pht_type.a_num;
    dk_phiG pht_type.a_num;

    dkbs_ma pht_type.a_var;dkbs_ten pht_type.a_nvar;dkbs_tc pht_type.a_var;
    dkbs_ma_ct pht_type.a_var;dkbs_kieu pht_type.a_var;
    dkbs_lkeM pht_type.a_var;dkbs_lkeP pht_type.a_var;dkbs_lkeB pht_type.a_var;
    dkbs_luy pht_type.a_var;
    dkbs_ma_dk pht_type.a_var;dkbs_ma_dkC pht_type.a_var;dkbs_lh_nv pht_type.a_var;dkbs_t_suat pht_type.a_num;
    dkbs_cap pht_type.a_num;
    dkbs_tien pht_type.a_num;dkbs_pt pht_type.a_num;dkbs_phi pht_type.a_num;
    dkbs_thue pht_type.a_num;dkbs_ttoan pht_type.a_num;
    dkbs_ptB pht_type.a_num;dkbs_phiB pht_type.a_num;
    dkbs_pp pht_type.a_var;dkbs_ptk pht_type.a_var;dkbs_bt pht_type.a_num;
    dkbs_maG pht_type.a_var; dkbs_tienG pht_type.a_num; dkbs_ptG pht_type.a_num;
    dkbs_phiG pht_type.a_num;
    a_ma pht_type.a_var;
    cs_dk clob; cs_dkbs clob; b_dk_txt clob; b_dkbs_txt clob;

begin
-- Nam - tinh phi prorata theo gr
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_dkbs');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_dkbs using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_dkbs);
b_lenh:=FKH_JS_LENH('so_id_dt,so_hd_g,so_dt,ngay_hl,ngay_kt,ngay_cap,nt_phi,nt_tien,tygia,c_thue');
EXECUTE IMMEDIATE b_lenh into b_so_id_dt,b_so_hdG,b_so_dt,b_ngay_hl,b_ngay_kt,b_ngay_cap,b_nt_phi,b_nt_tien,b_tygia,b_c_thue using dt_ct;
b_so_id_dt:=nvl(b_so_id_dt,0);
if b_so_hdG<>' ' then
    b_so_idG:=FBH_PTNNNG_SO_ID(b_ma_dvi,b_so_hdG);
    if b_so_idG=0 then b_loi:='loi:GCN goc da xoa:loi'; return; end if;
end if;
if b_tygia is null or b_tygia=0 then b_tygia:=1; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tien,ptb,pp,pt,phi,cap,tc,ma_ct,ma_dk,ma_dkc,kieu,lh_nv,t_suat,phib,lkem,lkep,lkeb,ptk,luy,bt');
EXECUTE IMMEDIATE b_lenh bulk collect into dk_ma,dk_ten,dk_tien,dk_ptB,dk_pp,dk_pt,dk_phi,dk_cap,dk_tc,dk_ma_ct,
        dk_ma_dk,dk_ma_dkC,dk_kieu,dk_lh_nv,dk_t_suat,dk_phiB,dk_lkeM,dk_lkeP,dk_lkeB,dk_ptk,dk_luy,dk_bt using dt_dk;
if dk_ma.count=0 then b_loi:='loi:Nhap so tien bao hiem:loi'; return; end if;
if trim(dt_dkbs) is not null then
  EXECUTE IMMEDIATE b_lenh bulk collect into dkbs_ma,dkbs_ten,dkbs_tien,dkbs_ptB,dkbs_pp,dkbs_pt,dkbs_phi,dkbs_cap,dkbs_tc,dkbs_ma_ct,
        dkbs_ma_dk,dkbs_ma_dkC,dkbs_kieu,dkbs_lh_nv,dkbs_t_suat,dkbs_phiB,dkbs_lkeM,dkbs_lkeP,dkbs_lkeB,dkbs_ptk,dkbs_luy,dkbs_bt using dt_dkbs;
end if;
if b_nt_phi<>'VND' then b_tp:=2; end if;
FBH_HD_KHO(b_ngay_hl,b_ngay_kt,b_kho,b_loi);
if b_loi is not null then return; end if;
b_kt:=0;
for b_lp_dk in 1..dk_ma.count loop
  b_kt:=b_kt+1;
  a_ma(b_kt):=dk_ma(b_lp_dk); dk_pp(b_lp_dk):=nvl(dk_pp(b_lp_dk),' ');
  if dk_lkeP(b_lp_dk) not in ('T','N','K') then
    if dk_lkeP(b_lp_dk)='S' then
      if dk_tien(b_lp_dk)<>0 then
       if dk_ptk(b_lp_dk)<>'P' then
          if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
             dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) * b_so_dt / b_tygia *b_kho,b_tp);
          elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
             dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) * b_so_dt * b_tygia *b_kho,b_tp);
          else
             dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) * b_so_dt *b_kho,b_tp);
          end if;
       elsif dk_ptk(b_lp_dk)<>'T' and dk_tien(b_lp_dk)<>0 and dk_ptB(b_lp_dk)<>0 then
          if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
             dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk)* dk_tien(b_lp_dk) * b_so_dt / b_tygia *b_kho/ 100,b_tp);
          elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
             dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk)* dk_tien(b_lp_dk) * b_so_dt * b_tygia *b_kho/ 100,b_tp);
          else
             dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk)* dk_tien(b_lp_dk) * b_so_dt *b_kho/ 100,b_tp);
          end if;
       else dk_phiB(b_lp_dk):=0;
       end if;
      end if;
      if dk_pp(b_lp_dk) = 'DG' and dk_pt(b_lp_dk)>0 then dk_phi(b_lp_dk):=ROUND(dk_pt(b_lp_dk),b_tp);
      elsif dk_pp(b_lp_dk) = 'DP' and dk_tien(b_lp_dk)<>0 and dk_pt(b_lp_dk)<>0 then
           dk_phi(b_lp_dk):=ROUND(dk_pt(b_lp_dk)*b_so_dt*dk_tien(b_lp_dk) *b_kho/ 100,b_tp);
      elsif dk_phiB(b_lp_dk)<>0 then
           dk_phi(b_lp_dk):=dk_phiB(b_lp_dk);
        if dk_pp(b_lp_dk) = 'GG' then
             dk_phi(b_lp_dk):=ROUND((dk_phi(b_lp_dk)-dk_pt(b_lp_dk)),b_tp);
        elsif dk_pp(b_lp_dk) = 'GT' and dk_tien(b_lp_dk)<>0 and dk_pt(b_lp_dk)<>0 then
             dk_phi(b_lp_dk):= dk_phi(b_lp_dk) - ROUND(dk_pt(b_lp_dk)*b_so_dt*dk_tien(b_lp_dk) *b_kho/ 100,b_tp);
        elsif dk_pp(b_lp_dk) = 'GP' and dk_pt(b_lp_dk)<>0 then
             dk_phi(b_lp_dk):= dk_phi(b_lp_dk) - ROUND(dk_pt(b_lp_dk)*dk_phiB(b_lp_dk)/ 100,b_tp);
        if dk_phi(b_lp_dk)<0 then dk_phi(b_lp_dk):=0; end if;
        end if;
      elsif dk_phiB(b_lp_dk)=0 then dk_phi(b_lp_dk):=0;
      end if;
      if dk_phiB(b_lp_dk)=0 then dk_phiB(b_lp_dk):=dk_phi(b_lp_dk); end if;
    end if;
    if dk_tien(b_lp_dk)<>0 then
       if dk_ptk(b_lp_dk)<>'P' then
          if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
             dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) / b_tygia *b_kho,b_tp);
          elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
             dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) * b_tygia *b_kho,b_tp);
          else
             dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk) *b_kho,b_tp);
          end if;
       elsif dk_ptk(b_lp_dk)<>'T' and dk_tien(b_lp_dk)<>0 and dk_ptB(b_lp_dk)<>0 then
          if b_nt_phi<>'VND' and b_nt_phi<>b_nt_tien then
             dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk)* dk_tien(b_lp_dk) / b_tygia *b_kho/ 100,b_tp);
          elsif b_nt_tien<>'VND' and b_nt_phi<>b_nt_tien then
             dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk)* dk_tien(b_lp_dk) * b_tygia *b_kho/ 100,b_tp);
          else
             dk_phiB(b_lp_dk):=ROUND(dk_ptB(b_lp_dk)* dk_tien(b_lp_dk) *b_kho/ 100,b_tp);
          end if;
       else dk_phiB(b_lp_dk):=0;
       end if;
      end if;
      if dk_pp(b_lp_dk) = 'DG' and dk_pt(b_lp_dk)>0 then dk_phi(b_lp_dk):=ROUND(dk_pt(b_lp_dk),b_tp);
      elsif dk_pp(b_lp_dk) = 'DP' and dk_tien(b_lp_dk)<>0 and dk_pt(b_lp_dk)<>0 then
           dk_phi(b_lp_dk):=ROUND(dk_pt(b_lp_dk)*dk_tien(b_lp_dk) *b_kho/ 100,b_tp);
      elsif dk_phiB(b_lp_dk)<>0 then
           dk_phi(b_lp_dk):=dk_phiB(b_lp_dk);
        if dk_pp(b_lp_dk) = 'GG' then
             dk_phi(b_lp_dk):=ROUND((dk_phi(b_lp_dk)-dk_pt(b_lp_dk)),b_tp);
        elsif dk_pp(b_lp_dk) = 'GT' and dk_tien(b_lp_dk)<>0 and dk_pt(b_lp_dk)<>0 then
             dk_phi(b_lp_dk):= dk_phi(b_lp_dk) - ROUND(dk_pt(b_lp_dk)*dk_tien(b_lp_dk) *b_kho/ 100,b_tp);
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
    select ngay_hl,ngay_kt into b_ngay_hlC,b_ngay_ktC from bh_ptnnn_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idG and b_so_id_dt in(0,so_id_dt);
    b_i1:=FKH_KHO_NGSO(b_ngay_cap,b_ngay_ktC)/FKH_KHO_NGSO(b_ngay_hlC,b_ngay_ktC);
    b_i2:=FKH_KHO_NGSO(b_ngay_cap,b_ngay_kt)/FKH_KHO_NGSO(b_ngay_hl,b_ngay_kt);
    b_i1:=round(b_i1,2); b_i2:=round(b_i2,2);
    select ma,tien,pt,phi bulk collect into dk_maG,dk_tienG,dk_ptG,dk_phiG from bh_ptnnn_dk
        where ma_dvi=b_ma_dvi and so_id=b_so_idG and b_so_id_dt in(0,so_id_dt) and lh_bh<>'M' order by bt;
    select ma,tien,pt,phi bulk collect into dkbs_maG,dkbs_tienG,dkbs_ptG,dkbs_phiG from bh_ptnnn_dk
        where ma_dvi=b_ma_dvi and so_id=b_so_idG and b_so_id_dt in(0,so_id_dt) and lh_bh<>'C' order by bt;
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
    'pp' value dk_pp(b_lp),'ptK' value dk_ptk(b_lp),'bt' value dk_bt(b_lp),
    'tien' value dk_tien(b_lp),'pt' value dk_pt(b_lp),
    'phi' value dk_phi(b_lp),'thue' value dk_thue(b_lp),'ttoan' value dk_ttoan(b_lp),
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
    'phi' value dkbs_phi(b_lp),'thue' value dkbs_thue(b_lp),'ttoan' value dkbs_ttoan(b_lp),
    'ptB' value dkbs_ptB(b_lp),'phiB' value dkbs_phiB(b_lp) returning clob) into b_dkbs_txt from dual;
    if b_lp>1 then cs_dkbs:=cs_dkbs||','; end if;
    cs_dkbs:=cs_dkbs||b_dkbs_txt;
end loop;
if cs_dkbs is not null then cs_dkbs:='['||cs_dkbs||']'; end if;
select json_object('dt_dk' value cs_dk,'dt_dkbs' value cs_dkbs returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNNN_HDBS(
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
select nvl(min(so_id_d),0) into b_so_idD from bh_ptnnn where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_so_idD<>0 then
    select count(*) into b_dong from bh_ptnnn where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hd,ttoan,ttrang,ma_dvi,so_id,
           'ma_sdbs' value PKH_TEN_TENl(FBH_PTNNN_TXT(ma_dvi,so_id,'ma_sdbs'))
    ) order by so_id desc returning clob)
        into cs_lke from bh_ptn where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
