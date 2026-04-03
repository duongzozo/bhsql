/*** Cong no dai ly ***/
create or replace function FBH_DL_CN_TU_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_txt clob;
begin
-- Dan
select count(*) into b_i1 from bh_dl_cn_tu_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_dl_cn_tu_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    b_kq:=FKH_JS_GTRIu(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_DL_CN_TU_SO_ID(b_ma_dvi varchar2,b_so_ct varchar2) return number
AS
    b_kq number;
begin
-- Dan - Tra so ID tu so CT
select nvl(min(so_id),0) into b_kq from bh_dl_cn_tu where ma_dvi=b_ma_dvi and so_ct=b_so_ct;
return b_kq;
end;
/
create or replace procedure PBH_DL_CN_TU_TON(
	b_ma_dvi varchar2,b_ma_kh varchar2,b_ma_nt varchar2,b_ngay_ht number,
	b_ton out number,b_ton_qd out number)
AS
	b_i1 number;
begin
-- Dan - Ton va ton_qd
select nvl(max(ngay_ht),0) into b_i1 from bh_dl_cn_sc where
	ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and ma_nt=b_ma_nt and ngay_ht<=b_ngay_ht;
if b_i1=0 then
    b_ton:=0; b_ton_qd:=0;
else
	select ton,ton_qd into b_ton,b_ton_qd from bh_dl_cn_sc where
		ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and ma_nt=b_ma_nt and ngay_ht=b_i1;
end if;
end;
/
create or replace function PBH_DL_CN_TU_QD(
    b_ma_dvi varchar2,b_ma_kh varchar2,b_l_ct varchar2,b_ma_nt varchar2,b_ngay_ht number,b_tien number) return number
AS
	b_ton number:=0; b_ton_qd number; b_tien_qd number;
begin
-- Dan - Qui doi tien
if b_ma_nt='VND' then
	b_tien_qd:=b_tien;
elsif b_l_ct='T' then
	b_tien_qd:=FBH_TT_VND_QD(b_ngay_ht,b_ma_nt,b_tien);
else
	PBH_DL_CN_TU_TON(b_ma_dvi,b_ma_kh,b_ma_nt,b_ngay_ht,b_ton,b_ton_qd);
	if b_ton=b_tien then b_tien_qd:=b_ton_qd;
	elsif b_ton>b_tien then b_tien_qd:=round((b_tien*b_ton_qd/b_ton),0);
    else b_tien_qd:=FBH_TT_VND_QD(b_ngay_ht,b_ma_nt,b_tien);
    end if;
end if;
return b_tien_qd;
end;
/
create or replace procedure PBH_DL_CN_TU_THOP(
    b_ma_dvi varchar2,b_ps varchar2,b_ngay_ht number,b_ma_kh varchar2,
	b_ma_nt varchar2,b_tien number,b_tien_qd number,b_loi out varchar2)
AS
	b_thu number; b_chi number; b_ton number; b_i1 number; b_i2 number;
	b_thu_qd number; b_chi_qd number; b_ton_qd number;
begin
-- Dan - Tong hop tam ung
if b_ps='T' then b_thu:=b_tien; b_thu_qd:=b_tien_qd; b_chi:=0; b_chi_qd:=0;
else b_thu:=0; b_thu_qd:=0; b_chi:=b_tien; b_chi_qd:=b_tien_qd;
end if;
PBH_DL_CN_TU_TON(b_ma_dvi,b_ma_kh,b_ma_nt,b_ngay_ht-1,b_ton,b_ton_qd);
update bh_dl_cn_sc set thu=thu+b_thu,thu_qd=thu_qd+b_thu_qd,chi=chi+b_chi,chi_qd=chi_qd+b_chi_qd
    where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and ma_nt=b_ma_nt and ngay_ht=b_ngay_ht;
if sql%rowcount=0 then
    insert into bh_dl_cn_sc values (b_ma_dvi,b_ma_kh,b_ma_nt,b_thu,b_thu_qd,b_chi,b_chi_qd,0,0,b_ngay_ht);
end if;
for b_rc in (select * from bh_dl_cn_sc where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and
    ma_nt=b_ma_nt and ngay_ht>=b_ngay_ht order by ngay_ht) loop
    b_i1:=b_rc.ngay_ht;
    if b_rc.thu=0 and b_rc.chi=0 and b_rc.thu_qd=0 and b_rc.chi_qd=0 then
        delete bh_dl_cn_sc where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and ma_nt=b_ma_nt and ngay_ht=b_i1;
    else    b_ton:=b_ton+b_rc.thu-b_rc.chi; b_ton_qd:=b_ton_qd+b_rc.thu_qd-b_rc.chi_qd;
        update bh_dl_cn_sc set ton=b_ton,ton_qd=b_ton_qd where
            ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and ma_nt=b_ma_nt and ngay_ht=b_i1;
    end if;
end loop;
PBH_DL_CN_TU_KTRA(b_ma_dvi,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_DL_CN_TU_THOP:loi'; end if;
end;
/
create or replace procedure PBH_DL_CN_TU_KTRA(b_ma_dvi varchar2,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Kiem tra so du
select nvl(min(ngay_ht),0) into b_i1 from bh_dl_cn_sc where ma_dvi=b_ma_dvi and sign(ton)<>sign(ton_qd);
if b_i1=0 then b_loi:=''; else b_loi:='loi:Qua so du ngay '||pkh_so_cng(b_i1)||':loi'; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace PROCEDURE PBH_DL_CN_TU_LKE_TON(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma_kh varchar2(20);
begin
-- Dan - Liet ke ton
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ma_kh:=trim(b_oraIn);
if b_ma_kh is null then b_loi:='loi:Nhap dai ly:loi'; raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma_nt,ton) order by ma_nt) into b_oraOut
    from bh_dl_cn_sc where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and ton<>0 and
    (ma_nt,ngay_ht) in (select ma_nt,max(ngay_ht) from bh_dl_cn_sc
    where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh group by ma_nt);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DL_CN_TU_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number; b_so_ct varchar2(20):=trim(b_oraIn);
begin
-- Dan - Hoi so ID qua so chung tu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FBH_DL_CN_TU_SO_ID(b_ma_dvi,b_so_ct);
if b_so_id=0 then b_loi:='loi:So chung tu da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DL_CN_TU_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
    dt_ct clob; dt_txt clob;
begin
-- Dan - Xem chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Chung tu da xoa:loi';
select txt into dt_txt from bh_dl_cn_tu_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
select json_object(so_ct,'ma_kh' value FBH_DTAC_MA_TENl(ma_kh),'txt' value dt_txt) into dt_ct
    from bh_dl_cn_tu where ma_dvi=b_ma_dvi and so_id=b_so_id;
select json_object('so_id' value b_so_id,'dt_ct' value dt_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DL_CN_TU_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10);
    b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number;
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
b_lenh:=FKH_JS_LENH('ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_dl_cn_tu where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_ct,'ten' value FBH_DTAC_MA_TEN(ma_kh)) order by so_id desc) into cs_lke from
        (select ma_dvi,so_id,so_ct,ma_kh,rownum sott from bh_dl_cn_tu where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc)
        where sott between b_tu and b_den;
elsif b_klk='P' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_dl_cn_tu where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_ct,'ten' value FBH_DTAC_MA_TEN(ma_kh)) order by so_id desc) into cs_lke from
        (select ma_dvi,so_id,so_ct,ma_kh,rownum sott from bh_dl_cn_tu where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id desc)
        where sott between b_tu and b_den;
elsif FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','TT','X')='C' then
    select count(*) into b_dong from bh_dl_cn_tu where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_ct,'ten' value FBH_DTAC_MA_TEN(ma_kh)) order by so_id desc) into cs_lke from
        (select ma_dvi,so_id,so_ct,ma_kh,rownum sott from bh_dl_cn_tu where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id desc)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
end;
/
create or replace procedure PBH_DL_CN_TU_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10);
    b_so_id number; b_ngay_ht number; b_klk varchar2(1); b_trangKt number; b_tu number; b_den number;
    b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,klk,trangkt,tu,den');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_klk,b_trangKt,b_tu,b_den using b_oraIn;
if b_klk ='N' then
    select count(*) into b_dong from bh_dl_cn_tu where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_id,rownum sott from bh_dl_cn_tu where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc)
        where so_id<=b_so_id;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_ct,'ten' value FBH_DTAC_MA_TEN(ma_kh)) order by so_id desc) into cs_lke from
        (select ma_dvi,so_id,so_ct,ma_kh,rownum sott from bh_dl_cn_tu
		where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc)
        where sott between b_tu and b_den;
elsif b_klk='P' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_dl_cn_tu where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_id,rownum sott from bh_dl_cn_tu where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id desc)
        where so_id<=b_so_id;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_ct,'ten' value FBH_DTAC_MA_TEN(ma_kh)) order by so_id desc) into cs_lke from
        (select ma_dvi,so_id,so_ct,ma_kh,rownum sott from bh_dl_cn_tu
		where ma_dvi=b_ma_dvi and phong=b_phong and ngay_ht=b_ngay_ht order by so_id desc)
        where sott between b_tu and b_den;
elsif FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','TT','X')='C' then
    select count(*) into b_dong from bh_dl_cn_tu where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_id,rownum sott from bh_dl_cn_tu where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id desc)
        where so_id<=b_so_id;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_ct,'ten' value FBH_DTAC_MA_TEN(ma_kh)) order by so_id desc) into cs_lke from
        (select ma_dvi,so_id,so_ct,ma_kh,rownum sott from bh_dl_cn_tu where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id desc)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
end;
/
create or replace procedure PBH_DL_CN_TU_TEST
    (b_ma_dvi varchar2,b_so_id number,dt_ct in out clob,
    b_ngay_ht out number,b_so_ct out varchar2,b_l_ct out varchar2,b_ma_kh out varchar2,
    b_nd out nvarchar2,b_ma_nt out varchar2,b_tien out number,b_tien_qd out number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_lenh varchar2(1000);
begin
b_lenh:=FKH_JS_LENH('ngay_ht,so_ct,l_ct,ma_kh,nd,ma_nt,tien');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_so_ct,b_l_ct,b_ma_kh,b_nd,b_ma_nt,b_tien using dt_ct;
if b_ngay_ht=0 or b_l_ct not in('T','C') or b_ma_kh=' ' or b_ma_nt=' ' or b_tien=0 then
    b_loi:='loi:Sai so lieu nhap:loi'; return;
end if;
if FBH_DL_MA_KH_HAN(b_ma_kh,b_ngay_ht)<>'C' then
	b_loi:='loi:Ma dai ly chua dang ky hoac het han hop tac:loi'; return;
end if;
if b_l_ct='C' then
    PBH_DL_CN_TU_TON(b_ma_dvi,b_ma_kh,b_ma_nt,b_ngay_ht,b_i1,b_i2);
    if b_i1<b_tien then b_loi:='loi:Qua so du tien:loi'; return; end if;
end if;
b_tien_qd:=PBH_DL_CN_TU_QD(b_ma_dvi,b_ma_kh,b_l_ct,b_ma_nt,b_ngay_ht,b_tien);
if trim(b_so_ct) is null then
    b_so_ct:=substr(to_char(b_so_id),3); PKH_JS_THAY(dt_ct,'so_ct',b_so_ct);
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_DL_CN_TU_XOA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2)
AS
    b_l_ct varchar2(1); b_ngay_ht number; b_ma_kh varchar2(20);
    b_ma_nt varchar2(5); b_tien number; b_tien_qd number; b_nsd_c varchar2(10); b_so_id_kt number;
begin
select ngay_ht,l_ct,ma_kh,ma_nt,tien,tien_qd,nsd,so_id_kt into
    b_ngay_ht,b_l_ct,b_ma_kh,b_ma_nt,b_tien,b_tien_qd,b_nsd_c,b_so_id_kt
    from bh_dl_cn_tu where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nsd<>b_nsd_c then b_loi:='loi:Khong sua, xoa chung tu nguoi khac:loi'; return; end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','TT');
if b_loi is not null then return; end if;
if b_so_id_kt>0 then
    PBH_KT_TD_XOA(b_ma_dvi,b_so_id_kt,b_loi);
    if b_loi is not null then return; end if;
end if;
PBH_DL_CN_TU_THOP(b_ma_dvi,b_l_ct,b_ngay_ht,b_ma_kh,b_ma_nt,-b_tien,-b_tien_qd,b_loi);
if b_loi is not null then return; end if;
delete bh_dl_cn_tu_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_dl_cn_tu where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_DL_CN_TU_NH_NH
    (b_ma_dvi varchar2,b_so_id number,b_nsd varchar2,b_ngay_ht number,
    b_so_ct varchar2,b_l_ct varchar2,b_ma_kh varchar2,b_nd nvarchar2,
    b_ma_nt varchar2,b_tien number,b_tien_qd number,dt_ct clob,b_loi out varchar2)
AS
    b_phong varchar2(10);
begin
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','TT');
if b_loi is not null then return; end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
PBH_DL_CN_TU_THOP(b_ma_dvi,b_l_ct,b_ngay_ht,b_ma_kh,b_ma_nt,b_tien,b_tien_qd,b_loi);
if b_loi is not null then return; end if;
insert into bh_dl_cn_tu values(b_ma_dvi,b_so_id,b_ngay_ht,b_so_ct,b_l_ct,b_ma_kh,b_nd,b_ma_nt,b_tien,b_tien_qd,b_phong,b_nsd,sysdate,0);
insert into bh_dl_cn_tu_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_DL_CN_TU_NH_NH:loi'; end if;
end;
/
create or replace procedure PBH_DL_CN_TU_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000);
    b_so_id number; b_ngay_ht number; b_so_ct varchar2(20); b_l_ct varchar2(10);
    b_ma_kh varchar2(20); b_nd nvarchar2(500); b_ma_nt varchar2(5); b_tien number; b_tien_qd number;
    dt_ct clob;
begin
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
else
    PBH_DL_CN_TU_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
dt_ct:=FKH_JS_GTRIc(b_oraIn,'dt_ct'); FKH_JS_NULL(dt_ct);
PBH_DL_CN_TU_TEST(b_ma_dvi,b_so_id,dt_ct,b_ngay_ht,b_so_ct,b_l_ct,b_ma_kh,b_nd,b_ma_nt,b_tien,b_tien_qd,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_DL_CN_TU_NH_NH(b_ma_dvi,b_so_id,b_nsd,b_ngay_ht,b_so_ct,b_l_ct,b_ma_kh,b_nd,b_ma_nt,b_tien,b_tien_qd,dt_ct,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('so_id' value b_so_id,'so_ct' value b_so_ct) into b_oraOut from dual;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DL_CN_TU_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Dan - Xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then b_loi:='loi:Chua chon chung tu:loi'; raise PROGRAM_ERROR; end if;
PBH_DL_CN_TU_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_DL_CN_TU_KTRA(b_ma_dvi,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PBH_DL_CN_TU_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    cs_lke clob:=''; b_dong number;
    b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_so_ct varchar2(20); b_ma_kh varchar2(20);
    b_ngayD number; b_ngayC number; b_tu number; b_den number; 
Begin
-- Tim cong no dai ly
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
b_lenh:=FKH_JS_LENH('so_ct,ma_kh,ngayd,ngayc,tu,den');
EXECUTE IMMEDIATE b_lenh into b_so_ct,b_ma_kh,b_ngayD,b_ngayC,b_tu,b_den using b_oraIn;
if b_ngayD in (0,30000101) or b_ngayD<b_ngay then b_ngayD:=b_ngay; end if; 
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_so_ct:=nvl(trim(b_so_ct),' '); b_ma_kh:=nvl(trim(b_ma_kh),' ');
if b_so_ct<>' ' then b_so_ct:='%'||b_so_ct||'%'; end if;
insert into temp_1(n1,n2,c1,c2,c3,n3)
    select distinct so_id,ngay_ht,so_ct,ma_kh,ma_nt,tien
    from bh_dl_cn_tu where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and
    b_ma_kh in(' ',ma_kh) and (b_so_ct=' ' or so_ct like b_so_ct);
update temp_1 set c4=FBH_DTAC_MA_TEN(c2);
select count(*) into b_dong from temp_1;
if b_dong<>0 then
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(so_id,ngay_ht,so_ct,ten,ma_nt,tien) order by ngay_ht desc,so_ct returning clob) into cs_lke
        from (select n1 so_id,n2 ngay_ht,c1 so_ct,c4 ten,c3 ma_nt,n3 tien,rownum sott from temp_1 order by n2,c1)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete temp_1; commit;
end;
/
