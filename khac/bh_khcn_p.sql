/*** Tien ich ***/
create or replace function FBH_KH_CN_TU_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_txt clob;
begin
-- Dan
select count(*) into b_i1 from bh_kh_cn_tu_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_kh_cn_tu_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    b_kq:=FKH_JS_GTRIu(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace procedure PBH_KH_CN_TU_TON(
	b_ma_dvi varchar2,b_ma_kh varchar2,b_ma_nt varchar2,b_ngay_ht number,
	b_ton out number,b_ton_qd out number,b_phong varchar2:=' ')
AS
	b_i1 number;
begin
-- Dan - Ton va ton_qd
select nvl(max(ngay_ht),0) into b_i1 from bh_kh_cn_sc where
	ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and phong=b_phong and ma_nt=b_ma_nt and ngay_ht<=b_ngay_ht;
if b_i1=0 then
	b_ton:=0; b_ton_qd:=0;
else
	select ton,ton_qd into b_ton,b_ton_qd from bh_kh_cn_sc where
		ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and phong=b_phong and ma_nt=b_ma_nt and ngay_ht=b_i1;
end if;
end;
/
create or replace function PBH_KH_CN_TU_QD(
    b_ma_dvi varchar2,b_ma_kh varchar2,b_ma_nt varchar2,b_ngay_ht number,
	b_l_ct varchar2,b_tien number,b_phong varchar2:=' ') return number
AS
	b_ton number:=0; b_ton_qd number; b_tien_qd number;
begin
-- Dan - Qui doi tien
if b_ma_nt='VND' then
	b_tien_qd:=b_tien;
elsif b_l_ct='T' then
	b_tien_qd:=FBH_TT_VND_QD(b_ngay_ht,b_ma_nt,b_tien);
else
	PBH_KH_CN_TU_TON(b_ma_dvi,b_ma_kh,b_ma_nt,b_ngay_ht,b_ton,b_ton_qd,b_phong);
	if b_ton=b_tien then b_tien_qd:=b_ton_qd;
	elsif b_ton>b_tien then b_tien_qd:=round((b_tien*b_ton_qd/b_ton),0);
    else b_tien_qd:=FBH_TT_VND_QD(b_ngay_ht,b_ma_nt,b_tien);
    end if;
end if;
return b_tien_qd;
end;
/
create or replace procedure PBH_KH_CN_TU_THOP(
    b_ma_dvi varchar2,b_ps varchar2,b_ngay_ht number,b_ma_kh varchar2,
	b_ma_nt varchar2,b_tien number,b_tien_qd number,b_loi out varchar2,b_phong varchar2:=' ')
AS
	b_thu number; b_chi number; b_ton number; b_i1 number; b_i2 number;
	b_thu_qd number; b_chi_qd number; b_ton_qd number;
begin
-- Dan - Tong hop tam ung
if b_ps='T' then b_thu:=b_tien; b_thu_qd:=b_tien_qd; b_chi:=0; b_chi_qd:=0;
else b_thu:=0; b_thu_qd:=0; b_chi:=b_tien; b_chi_qd:=b_tien_qd;
end if;
PBH_KH_CN_TU_TON(b_ma_dvi,b_ma_kh,b_ma_nt,b_ngay_ht-1,b_ton,b_ton_qd,b_phong);
update bh_kh_cn_sc set thu=thu+b_thu,thu_qd=thu_qd+b_thu_qd,chi=chi+b_chi,chi_qd=chi_qd+b_chi_qd
    where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and phong=b_phong and ma_nt=b_ma_nt and ngay_ht=b_ngay_ht;
if sql%rowcount=0 then
    insert into bh_kh_cn_sc values (b_ma_dvi,b_ma_kh,b_phong,b_ma_nt,b_thu,b_thu_qd,b_chi,b_chi_qd,0,0,b_ngay_ht);
end if;
for b_rc in (select * from bh_kh_cn_sc where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and
    phong=b_phong and ma_nt=b_ma_nt and ngay_ht>=b_ngay_ht order by ngay_ht) loop
    b_i1:=b_rc.ngay_ht;
    if b_rc.thu=0 and b_rc.chi=0 and b_rc.thu_qd=0 and b_rc.chi_qd=0 then
        delete bh_kh_cn_sc where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and phong=b_phong and ma_nt=b_ma_nt and ngay_ht=b_i1;
    else    b_ton:=b_ton+b_rc.thu-b_rc.chi; b_ton_qd:=b_ton_qd+b_rc.thu_qd-b_rc.chi_qd;
        update bh_kh_cn_sc set ton=b_ton,ton_qd=b_ton_qd where
            ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and phong=b_phong and ma_nt=b_ma_nt and ngay_ht=b_i1;
    end if;
end loop;
PBH_KH_CN_TU_KTRA(b_ma_dvi,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KH_CN_TU_THOP:loi'; end if;
end;
/
create or replace procedure PBH_KH_CN_TU_KTRA(b_ma_dvi varchar2,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Kiem tra so du
select nvl(min(ngay_ht),0) into b_i1 from bh_kh_cn_sc where ma_dvi=b_ma_dvi and sign(ton)<>sign(ton_qd);
if b_i1=0 then b_loi:=''; else b_loi:='loi:Qua so du ngay '||pkh_so_cng(b_i1)||':loi'; end if;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KH_CN_TU_KTRA:loi'; end if;
end;
/
create or replace PROCEDURE PBH_KH_CN_TU_LKE_TON(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma_kh varchar2(20); cs_ton clob:=''; b_lenh varchar2(1000);
begin
-- Dan - Liet ke ton
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KH','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_kh');
EXECUTE IMMEDIATE b_lenh into b_ma_kh using b_oraIn;
b_ma_kh:=trim(b_ma_kh);
if b_ma_kh is null then b_loi:='loi:Nhap khach hang:loi'; raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(phong,ma_nt,ton) order by phong,ma_nt) into cs_ton
    from bh_kh_cn_sc where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and ton<>0 and
    (phong,ma_nt,ngay_ht) in (select phong,ma_nt,max(ngay_ht) from bh_kh_cn_sc
    where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh group by phong,ma_nt);
select json_object('cs_ton' value cs_ton returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KH_CN_TU_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_so_id number;
    b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number;
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KH','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_kh_cn_tu where ngay_ht=b_ngay_ht and nsd=b_nsd;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(ngay_ht,tien,so_id,'ma_kh' value FBH_HD_MA_KH_TEN(ma_kh)) order by so_id desc returning clob)
            into cs_lke from
            (select ngay_ht,ma_kh,tien,so_id,rownum sott from bh_kh_cn_tu where 
            ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc)
            where sott between b_tu and b_den;
    end if;
else
    select count(*) into b_dong from bh_kh_cn_tu where ngay_ht=b_ngay_ht;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(ngay_ht,tien,so_id,'ma_kh' value FBH_HD_MA_KH_TEN(ma_kh)) order by so_id desc returning clob)
            into cs_lke from
            (select ngay_ht,ma_kh,tien,so_id,rownum sott from bh_kh_cn_tu where ngay_ht=b_ngay_ht order by so_id desc)
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KH_CN_TU_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_tu number; b_den number;
    b_so_id number; b_ngay_ht number; b_klk varchar2(1); b_trangkt number;
    b_trang number; b_dong number; cs_lke clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KH','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_klk,b_trangKt using b_oraIn;
if b_klk ='N' then
    select count(*) into b_dong from bh_kh_cn_tu where ngay_ht=b_ngay_ht and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,rownum sott from bh_kh_cn_tu where
        ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc) where so_id<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ngay_ht,tien,so_id,'ma_kh' value FBH_HD_MA_KH_TEN(ma_kh))
		order by so_id desc returning clob) into cs_lke from
        (select ngay_ht,tien,so_id,ma_kh,rownum sott from bh_kh_cn_tu where 
        ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_kh_cn_tu where ngay_ht=b_ngay_ht;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,rownum sott from bh_kh_cn_tu where
        ngay_ht=b_ngay_ht order by so_id desc) where so_id<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ngay_ht,tien,so_id,'ma_kh' value FBH_HD_MA_KH_TEN(ma_kh))
		order by so_id desc returning clob) into cs_lke from
        (select ngay_ht,tien,so_id,ma_kh,rownum sott from bh_kh_cn_tu where ngay_ht=b_ngay_ht order by so_id desc)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KH_CN_TU_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number; dt_ct clob; dt_txt clob;
begin
-- Dan - Xem chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KH','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_loi:='loi:Chung tu da xoa:loi';
select txt into dt_txt from bh_kh_cn_tu_txt where so_id=b_so_id and loai='dt_ct';
select json_object(so_ct,'ma_kh' value FBH_HD_MA_KH_TENl(ma_kh),'txt' value dt_txt) into dt_ct from bh_kh_cn_tu where so_id=b_so_id;
select json_object('so_id' value b_so_id,'dt_ct' value dt_ct,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KH_CN_TU_XOA_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2)
AS
	b_l_ct varchar2(1); b_ngay_ht number; b_ma_kh varchar2(20); b_phong varchar2(10); b_phong_m varchar2(10);
	b_ma_nt varchar2(5); b_tien number; b_tien_qd number; b_tien_qd_m number; b_nsd_c varchar2(10); b_so_id_kt number;
begin
select l_ct,ngay_ht,ma_kh,phong,phong_m,ma_nt,tien,tien_qd,tien_qd_m,nsd,so_id_kt into
	b_l_ct,b_ngay_ht,b_ma_kh,b_phong,b_phong_m,b_ma_nt,b_tien,b_tien_qd,b_tien_qd_m,b_nsd_c,b_so_id_kt
	from bh_kh_cn_tu where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nsd<>b_nsd_c then b_loi:='loi:Khong sua, xoa chung tu nguoi khac:loi'; return; end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','TT');
if b_loi is not null then return; end if;
if b_so_id_kt>0 then
    PBH_KT_TD_XOA(b_ma_dvi,b_so_id_kt,b_loi);
    if b_loi is not null then return; end if;
end if;
if b_l_ct='D' then
	PBH_KH_CN_TU_THOP(b_ma_dvi,'C',b_ngay_ht,b_ma_kh,b_ma_nt,-b_tien,-b_tien_qd,b_loi,b_phong);
	if b_loi is not null then return; end if;
	PBH_KH_CN_TU_THOP(b_ma_dvi,'T',b_ngay_ht,b_ma_kh,b_ma_nt,-b_tien,-b_tien_qd_m,b_loi,b_phong_m);
	if b_loi is not null then return; end if;
else
	PBH_KH_CN_TU_THOP(b_ma_dvi,b_l_ct,b_ngay_ht,b_ma_kh,b_ma_nt,-b_tien,-b_tien_qd,b_loi,b_phong);
	if b_loi is not null then return; end if;
end if;
delete bh_kh_cn_tu_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_kh_cn_tu where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_KH_CN_TU_TEST
    (b_ma_dvi varchar2,b_so_id number,dt_ct in out clob,
    b_ngay_ht out number,b_l_ct out varchar2,b_ma_kh out varchar2,b_so_ct out varchar2,
    b_phong out varchar2,b_phong_m out varchar2,b_ma_nt out varchar2,b_loai out varchar2,
    b_tien out number,b_tien_qd out number,b_tien_qd_m out number,b_loi out varchar2)
AS
    b_i1 number; b_lenh varchar2(2000);
begin
b_lenh:=FKH_JS_LENH('ngay_ht,l_ct,ma_kh,so_ct,phong,phong_m,ma_nt,tien,loai');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_l_ct,b_ma_kh,b_so_ct,
    b_phong,b_phong_m,b_ma_nt,b_tien,b_loai using dt_ct;
if b_ngay_ht=0 or b_l_ct not in('T','C','D') or b_ma_kh=' ' or b_ma_nt=' ' or b_tien=0 or b_phong=' ' then
    b_loi:='loi:Sai so lieu nhap:loi'; return;
end if;
b_loi:='loi:Ma khach hang chua dang ky:loi';
select 0 into b_i1 from bh_hd_ma_kh where ma=b_ma_kh;
-- chuclh: hoi lai a dan co can theo ma don vi khong
if b_phong<>' ' then
    b_loi:='loi:Ma phong chua dang ky:loi';
    select 0 into b_i1 from ht_ma_phong where ma=b_phong;
end if;
b_phong_m:=nvl(trim(b_phong_m),' ');
if b_phong_m<>' ' then
    b_loi:='loi:Ma phong moi chua dang ky:loi';
    select 0 into b_i1 from ht_ma_phong where ma=b_phong_m;
end if;
if b_l_ct='D' then
    if b_phong=b_phong_m then b_loi:='loi:Khong chuyen cung phong:loi'; return; end if;
    b_tien_qd:=PBH_KH_CN_TU_QD(b_ma_dvi,b_ma_kh,b_ma_nt,b_ngay_ht,'C',b_tien,b_phong);
    b_tien_qd_m:=b_tien_qd;
else
    b_tien_qd:=PBH_KH_CN_TU_QD(b_ma_dvi,b_ma_kh,b_ma_nt,b_ngay_ht,b_l_ct,b_tien,b_phong);
    b_tien_qd_m:=0;
end if;
if trim(b_so_ct) is null then
	b_so_ct:=substr(to_char(b_so_id),3); PKH_JS_THAY(dt_ct,'so_ct',b_so_ct);
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_KH_CN_TU_NH_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_l_ct varchar2,b_ngay_ht number,b_so_id number,
	b_ma_kh varchar2,b_so_ct varchar2,
	b_phong varchar2,b_phong_m varchar2,b_ma_nt varchar2,b_loai varchar2,
	b_tien number,b_tien_qd number,b_tien_qd_m number,dt_ct clob,b_loi out varchar2)
AS
begin
-- Dan - Nhap
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','TT');
if b_loi is not null then return; end if;
if b_l_ct='D' then
	PBH_KH_CN_TU_THOP(b_ma_dvi,'C',b_ngay_ht,b_ma_kh,b_ma_nt,b_tien,b_tien_qd,b_loi,b_phong);
	if b_loi is not null then return; end if;
	PBH_KH_CN_TU_THOP(b_ma_dvi,'T',b_ngay_ht,b_ma_kh,b_ma_nt,b_tien,b_tien_qd_m,b_loi,b_phong_m);
	if b_loi is not null then return; end if;
else
	PBH_KH_CN_TU_THOP(b_ma_dvi,b_l_ct,b_ngay_ht,b_ma_kh,b_ma_nt,b_tien,b_tien_qd,b_loi,b_phong);
	if b_loi is not null then return; end if;
end if;
b_loi:='loi:Loi Table bh_kh_cn_tu:loi';
insert into bh_kh_cn_tu values(b_ma_dvi,b_so_id,b_ngay_ht,b_l_ct,b_ma_kh,b_phong,b_phong_m,
	b_so_ct,b_ma_nt,b_loai,b_tien,b_tien_qd,b_tien_qd_m,b_nsd,sysdate,0);
insert into bh_kh_cn_tu_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_KH_CN_TU_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); dt_ct clob;
    b_so_id number; b_ngay_ht number; b_l_ct varchar2(1); b_ma_kh varchar2(20);
    b_phong varchar2(10); b_phong_m varchar2(10); b_so_ct varchar2(20);
    b_ma_nt varchar2(5); b_loai varchar2(1); b_tien number; b_tien_qd number; b_tien_qd_m number;
begin
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KH','N');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
else
    PBH_KH_CN_TU_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
dt_ct:=FKH_JS_GTRIc(b_oraIn,'dt_ct'); FKH_JS_NULL(dt_ct);
PBH_KH_CN_TU_TEST(b_ma_dvi,b_so_id,dt_ct,b_ngay_ht,b_l_ct,b_ma_kh,b_so_ct,
    b_phong,b_phong_m,b_ma_nt,b_loai,b_tien,b_tien_qd,b_tien_qd_m,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_KH_CN_TU_NH_NH(b_ma_dvi,b_nsd,b_l_ct,b_ngay_ht,b_so_id,b_ma_kh,b_so_ct,
    b_phong,b_phong_m,b_ma_nt,b_loai,b_tien,b_tien_qd,b_tien_qd_m,dt_ct,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('so_id' value b_so_id,'so_ct' value b_so_ct) into b_oraOut from dual;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KH_CN_TU_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
	b_loi varchar2(100); b_so_id number;
begin
-- Dan - Xoa tam ung
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KH','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
if b_so_id is null then b_loi:='loi:Nhap SO ID:loi'; raise PROGRAM_ERROR; end if;
PBH_KH_CN_TU_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_KH_CN_TU_KTRA(b_ma_dvi,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KH_CN_TU_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(200); cs_lke clob:='';
    b_so_idD number; b_ma_kh varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(20);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number;
begin
-- Dan - Tim thanh toan qua CMT, mobi, email
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KH','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,cmt,mobi,email');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_cmt,b_mobi,b_email using b_oraIn;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
    select JSON_ARRAYAGG(json_object(ngay_ht,so_ct,ma_nt,tien,'ma_kh' value FBH_HD_MA_KH_TEN(ma_kh))
        order by ngay_ht desc,so_ct returning clob) into cs_lke from
        (select ngay_ht,so_ct,ma_nt,tien,ma_kh,rownum sott from bh_kh_cn_tu where
        ngay_ht between b_ngayD and b_ngayC and ma_kh=b_ma_kh order by ngay_ht desc,so_ct)
        where sott<201;
elsif b_ngayD between b_ngay and 30000101 then
    select JSON_ARRAYAGG(json_object(ngay_ht,so_ct,ma_nt,tien,'ma_kh' value FBH_HD_MA_KH_TEN(ma_kh))
        order by ngay_ht desc,so_ct returning clob) into cs_lke from
        (select ngay_ht,so_ct,ma_nt,tien,ma_kh,rownum sott from bh_kh_cn_tu where
        ngay_ht between b_ngayD and b_ngayC order by ngay_ht desc,so_ct)
        where sott<201;
end if;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
