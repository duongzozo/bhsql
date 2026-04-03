/*** CONG NO NHA BH ***/
create or replace function FTBH_NHA_BH_CN_SO_ID(b_so_ct varchar2) return number
AS
    b_kq number:=0;
begin
-- Dan - Tra so Id qua so ct
if trim(b_so_ct) is not null then
    select nvl(min(so_id),0) into b_kq from tbh_nha_bh_cn where so_ct=b_so_ct;
end if;
return b_kq;
end;
/
create or replace function FTBH_NHA_BH_CN_SO_CT(b_so_id number) return varchar2
AS
    b_kq varchar2(20):='';
begin
-- Dan - Tra so ct qua so id
if b_so_id<>0 then
    select min(so_ct) into b_kq from tbh_nha_bh_cn where so_id=b_so_id;
end if;
return b_kq;
end;
/
create or replace procedure PTBH_NHA_BH_CN_TON(
	b_ma_dvi varchar2,b_nha_bh varchar2,b_ma_nt varchar2,b_ngay_ht number,b_ton out number,b_ton_qd out number)
AS
	b_i1 number;
begin
-- Dan - Ton va ton_qd
select nvl(max(ngay_ht),0) into b_i1 from tbh_nha_bh_sc where
	nha_bh=b_nha_bh and ma_nt=b_ma_nt and ngay_ht<=b_ngay_ht;
if b_i1=0 then
	b_ton:=0; b_ton_qd:=0;
else
	select ton,ton_qd into b_ton,b_ton_qd from tbh_nha_bh_sc where
		nha_bh=b_nha_bh and ma_nt=b_ma_nt and ngay_ht=b_i1;
end if;
end;
/
create or replace function PTBH_NHA_BH_CN_SODU(
    b_ma_dvi varchar2,b_ngay_ht number,b_nha_bh varchar2,b_ma_nt varchar2) return number
AS
    b_ton number; b_ton_qd number;
begin
-- Dan - Ton tien
PTBH_NHA_BH_CN_TON(b_ma_dvi,b_nha_bh,b_ma_nt,b_ngay_ht,b_ton,b_ton_qd);
return b_ton;
end;
/
create or replace function PTBH_NHA_BH_CN_QD(
	b_ma_dvi varchar2,b_nha_bh varchar2,b_ma_nt varchar2,
	b_ngay_ht number,b_l_ct varchar2,b_tien number) return number
AS
	b_i1 number; b_ton number:=0; b_ton_qd number; b_noite varchar2(5):='VND'; b_tien_qd number:=b_tien;
begin
-- Dan - Qui doi tien
if b_ma_nt<>b_noite then
	PTBH_NHA_BH_CN_TON(b_ma_dvi,b_nha_bh,b_ma_nt,b_ngay_ht,b_ton,b_ton_qd);
	if b_l_ct='T' then b_ton:=-b_ton; b_ton_qd:=-b_ton_qd; end if;
	if b_ton=b_tien then b_tien_qd:=b_ton_qd;
	elsif b_ton>b_tien then b_tien_qd:=round((b_tien*b_ton_qd/b_ton),0);
	else
		b_i1:=FBH_TT_TRA_TGTT(b_ngay_ht,b_ma_nt);
		if b_ton>0 then b_tien_qd:=b_ton_qd+round((b_tien-b_ton)*b_i1,0);
		else b_tien_qd:=round(b_tien*b_i1,0);
		end if;
	end if;
end if;
return b_tien_qd;
end;
/
create or replace procedure PTBH_NHA_BH_CN_KTRA(b_ma_dvi varchar2,b_loi out varchar2)
AS
	b_i1 number;
begin
-- Dan - Kiem tra so du
select nvl(min(ngay_ht),0) into b_i1 from tbh_nha_bh_sc where sign(ton)<>sign(ton_qd);
if b_i1<>0 then b_loi:='loi:Sai so du ngay '||pkh_so_cng(b_i1)||':loi'; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PTBH_NHA_BH_CN_THOP
    (b_ma_dvi varchar2,b_ps varchar2,b_ngay_ht number,b_nha_bh varchar2,b_ma_nt varchar2,
    b_tien number,b_tien_qd number,b_loi out varchar2)
AS
    b_thu number; b_chi number; b_ton number; b_i1 number; b_i2 number;
    b_thu_qd number; b_chi_qd number; b_ton_qd number;
begin
-- Dan - Tong hop so cai
if b_ps='T' then b_thu:=b_tien; b_thu_qd:=b_tien_qd; b_chi:=0; b_chi_qd:=0;
else b_thu:=0; b_thu_qd:=0; b_chi:=b_tien; b_chi_qd:=b_tien_qd;
end if;
PTBH_NHA_BH_CN_TON(b_ma_dvi,b_nha_bh,b_ma_nt,b_ngay_ht-1,b_ton,b_ton_qd);
update tbh_nha_bh_sc set thu=thu+b_thu,thu_qd=thu_qd+b_thu_qd,chi=chi+b_chi,chi_qd=chi_qd+b_chi_qd
    where nha_bh=b_nha_bh and ma_nt=b_ma_nt and ngay_ht=b_ngay_ht;
if sql%rowcount=0 then
    insert into tbh_nha_bh_sc values(b_ma_dvi,b_nha_bh,b_ma_nt,b_thu,b_thu_qd,b_chi,b_chi_qd,0,0,b_ngay_ht);
end if;
for b_rc in (select * from tbh_nha_bh_sc where nha_bh=b_nha_bh and
    ma_nt=b_ma_nt and ngay_ht>=b_ngay_ht order by ngay_ht) loop
    b_i1:=b_rc.ngay_ht;
    if b_rc.thu=0 and b_rc.chi=0 and b_rc.thu_qd=0 and b_rc.chi_qd=0 then
        delete tbh_nha_bh_sc where nha_bh=b_nha_bh and ma_nt=b_ma_nt and ngay_ht=b_i1;
    else
        b_ton:=b_ton+b_rc.thu-b_rc.chi; b_ton_qd:=b_ton_qd+b_rc.thu_qd-b_rc.chi_qd;
        update tbh_nha_bh_sc set ton=b_ton,ton_qd=b_ton_qd where
            nha_bh=b_nha_bh and ma_nt=b_ma_nt and ngay_ht=b_i1;
    end if;
end loop;
select nvl(min(ngay_ht),0) into b_i1 from tbh_nha_bh_sc where nha_bh=b_nha_bh and ma_nt=b_ma_nt and sign(ton)<>sign(ton_qd);
if b_i1<>0 then b_loi:='loi:Sai so du ngay '||pkh_so_cng(b_i1)||':loi'; return; end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace PROCEDURE PTBH_NHA_BH_CN_LKE_TON(
	b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_nha_bh varchar2(20); cs_ton clob:='';
begin
-- Dan - Liet ke ton
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_nha_bh:=trim(FKH_JS_GTRIs(b_oraIn,'nha_bh'));
if b_nha_bh is null then b_loi:='loi:Nhap nha tai:loi'; raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma_nt,ton) order by ma_nt) into cs_ton
	from tbh_nha_bh_sc where nha_bh=b_nha_bh and ton<>0 and (ma_nt,ngay_ht) in 
	(select ma_nt,max(ngay_ht) from tbh_nha_bh_sc where nha_bh=b_nha_bh group by ma_nt);
select json_object('cs_ton' value cs_ton) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PTBH_NHA_BH_CN_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_ct varchar2(20); b_so_id number;
begin
-- Dan - Liet ke ton ngay => kieu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_ct:=FKH_JS_GTRIs(b_oraIn,'so_ct');
b_so_id:=FTBH_NHA_BH_CN_SO_ID(b_so_ct);
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_NHA_BH_CN_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_so_id number;
    b_ngayD number; b_ngayC number; b_klk varchar2(1); b_tu number; b_den number;
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from tbh_nha_bh_cn where ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(
			ngay_ht,so_ct,ma_nt,tien,so_id,'nha_bh' value FBH_MA_NBH_TEN(nha_bh))
			order by ngay_ht desc,so_ct returning clob) into cs_lke from
            (select ngay_ht,nha_bh,so_ct,ma_nt,tien,so_id,rownum sott from tbh_nha_bh_cn where 
            ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd order by ngay_ht desc,so_ct)
            where sott between b_tu and b_den;
    end if;
else
    select count(*) into b_dong from tbh_nha_bh_cn where ngay_ht between b_ngayD and b_ngayC;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(
			ngay_ht,so_ct,ma_nt,tien,so_id,'nha_bh' value FBH_MA_NBH_TEN(nha_bh))
			order by ngay_ht desc,so_ct returning clob) into cs_lke from
            (select ngay_ht,nha_bh,so_ct,ma_nt,tien,so_id,rownum sott from tbh_nha_bh_cn where 
            ngay_ht between b_ngayD and b_ngayC order by ngay_ht desc,so_ct)
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_NHA_BH_CN_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_tu number; b_den number;
    b_so_id number; b_ngayD number; b_ngayC number; b_klk varchar2(1); b_trangkt number;
    b_trang number; b_dong number; cs_lke clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngayd,ngayc,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngayD,b_ngayC,b_klk,b_trangKt using b_oraIn;
if b_klk ='N' then
    select count(*) into b_dong from tbh_nha_bh_cn where ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,rownum sott from tbh_nha_bh_cn where
        ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd order by so_id desc) where so_id<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(
		ngay_ht,so_ct,ma_nt,tien,so_id,'nha_bh' value FBH_MA_NBH_TEN(nha_bh))
		order by so_id desc returning clob) into cs_lke from
        (select ngay_ht,so_ct,nha_bh,ma_nt,tien,so_id,rownum sott from tbh_nha_bh_cn where 
        ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd order by so_id desc)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from tbh_nha_bh_cn where ngay_ht between b_ngayD and b_ngayC;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,rownum sott from tbh_nha_bh_cn where
        ngay_ht between b_ngayD and b_ngayC order by so_id desc) where so_id<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(
		ngay_ht,so_ct,ma_nt,tien,so_id,'nha_bh' value FBH_MA_NBH_TEN(nha_bh))
		order by so_id desc returning clob) into cs_lke from
        (select ngay_ht,so_ct,nha_bh,ma_nt,tien,so_id,rownum sott from tbh_nha_bh_cn where 
        ngay_ht between b_ngayD and b_ngayC order by so_id desc)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_NHA_BH_CN_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number; dt_ct clob;
begin
-- Dan - Xem chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_loi:='loi:Xu ly da xoa:loi';
select json_object(so_ct,txt,'nha_bh' value FBH_MA_NBH_TENl(nha_bh)) into dt_ct from tbh_nha_bh_cn where so_id=b_so_id;
select json_object('so_id' value b_so_id,'dt_ct' value dt_ct returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_NHA_BH_CN_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(200); cs_lke clob:=''; b_nha_bh varchar2(20);
    b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36)); b_ngayD number; b_ngayC number;
begin
-- Dan - Tim thanh toan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,nha_bh');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_nha_bh using b_oraIn;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if b_ngayD in(0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
b_nha_bh:=nvl(trim(b_nha_bh),' ');
select JSON_ARRAYAGG(json_object(ngay_ht,so_ct,ma_nt,tien,so_id,'nha_bh' value FBH_MA_NBH_TEN(nha_bh))
    order by ngay_ht desc,so_ct returning clob) into cs_lke from
    (select ngay_ht,so_ct,ma_nt,tien,nha_bh,so_id from tbh_nha_bh_cn where
    ngay_ht between b_ngayD and b_ngayC and b_nha_bh in(' ',nha_bh) order by ngay_ht desc,so_ct)
    where rownum<201;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_NHA_BH_CN_NH_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    b_ngay_ht number,b_so_ct varchar2,b_l_ct varchar2,b_nha_bh varchar2,
    b_ma_nt varchar2,b_tien number,b_tien_qd number,dt_ct clob,b_loi out varchar2)
AS
begin
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','TA');
if b_loi is not null then return; end if;
PTBH_NHA_BH_CN_THOP(b_ma_dvi,b_l_ct,b_ngay_ht,b_nha_bh,b_ma_nt,b_tien,b_tien_qd,b_loi);
if b_loi is not null then return; end if;
b_loi:='loi:Loi Table tbh_nha_bh_cn:loi';
insert into tbh_nha_bh_cn values(b_ma_dvi,b_so_id,b_ngay_ht,b_l_ct,b_so_ct,b_nha_bh,
    b_ma_nt,b_tien,b_tien_qd,b_nsd,dt_ct,sysdate,0);
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PTBH_NHA_BH_CN_TEST
	(b_ma_dvi varchar2,dt_ct clob,
	b_ngay_ht out number,b_so_ct out varchar2,b_l_ct out varchar2,b_nha_bh out varchar2,
	b_ma_nt out varchar2,b_tien out number,b_tien_qd out number,b_loi out varchar2)
AS
	b_i1 number; b_lenh varchar2(2000);
begin
b_lenh:=FKH_JS_LENH('ngay_ht,so_ct,l_ct,nha_bh,ma_nt,tien');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_so_ct,b_l_ct,b_nha_bh,b_ma_nt,b_tien using dt_ct;
if b_ngay_ht is null or b_ngay_ht in(0,30000101) or b_l_ct is null or b_l_ct not in('T','C') or 
	b_nha_bh is null or b_ma_nt is null or b_tien is null or b_tien=0 then
	b_loi:='loi:Sai so lieu nhap:loi'; return;
end if;
b_loi:='loi:Sai ma nha tai:loi';
select 0 into b_i1 from bh_ma_nbh where ma=b_nha_bh;
b_tien_qd:=PTBH_NHA_BH_CN_QD(b_ma_dvi,b_nha_bh,b_ma_nt,b_ngay_ht,b_l_ct,b_tien);
if trim(b_so_ct) is null then b_so_ct:=FTBH_SO_TA(b_ma_dvi,'CN',b_ngay_ht); end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PTBH_NHA_BH_CN_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2)
AS
    b_l_ct varchar2(1); b_ngay_ht number; b_nha_bh varchar2(10);
    b_ma_nt varchar2(5); b_tien number; b_tien_qd number; b_nsd_c varchar2(10); b_so_id_kt number;
begin
select l_ct,ngay_ht,nha_bh,ma_nt,tien,tien_qd,nsd,so_id_kt into
    b_l_ct,b_ngay_ht,b_nha_bh,b_ma_nt,b_tien,b_tien_qd,b_nsd_c,b_so_id_kt
    from tbh_nha_bh_cn where so_id=b_so_id;
if b_nsd<>b_nsd_c then b_loi:='loi:Khong xoa chung tu nguoi khac:loi'; return; end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','TA');
if b_loi is not null then return; end if;
if b_so_id_kt>0 then
    PBH_KT_TD_XOA(b_ma_dvi,b_so_id_kt,b_loi);
    if b_loi is not null then return; end if;
end if;
PTBH_NHA_BH_CN_THOP(b_ma_dvi,b_l_ct,b_ngay_ht,b_nha_bh,b_ma_nt,-b_tien,-b_tien_qd,b_loi);
if b_loi is not null then return; end if;
delete tbh_nha_bh_cn where so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PTBH_NHA_BH_CN_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_lenh varchar2(2000); dt_ct clob;
    b_so_id number; b_ngay_ht number; b_so_ct varchar2(20); b_l_ct varchar2(1);
    b_nha_bh varchar2(20); b_ma_nt varchar2(5); b_tien_qd number; b_tien number;
begin
if b_comm='C' then
	b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N');
	if b_loi is not null then raise_application_error(-20105,b_loi); end if;
end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
else
    PTBH_NHA_BH_CN_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
dt_ct:=FKH_JS_GTRIc(b_oraIn,'dt_ct');
PTBH_NHA_BH_CN_TEST(b_ma_dvi,dt_ct,b_ngay_ht,b_so_ct,b_l_ct,b_nha_bh,b_ma_nt,b_tien,b_tien_qd,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTBH_NHA_BH_CN_NH_NH(b_ma_dvi,b_nsd,b_so_id,b_ngay_ht,b_so_ct,b_l_ct,b_nha_bh,b_ma_nt,b_tien,b_tien_qd,dt_ct,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('so_id' value b_so_id,'so_ct' value b_so_ct) into b_oraOut from dual;
if b_comm='C' then commit; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_NHA_BH_CN_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
	b_loi varchar2(100); b_so_id number;
begin
-- Dan - Xoa tam ung
if b_comm='C' then
	b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N');
	if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
if b_so_id is null then b_loi:='loi:Nhap SO ID:loi'; raise PROGRAM_ERROR; end if;
PTBH_NHA_BH_CN_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
