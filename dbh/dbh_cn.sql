/*** CONG NO ***/
create or replace function FBH_DO_BH_CN_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_txt clob;
begin
-- Dan
select count(*) into b_i1 from bh_hd_do_cn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_hd_do_cn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    b_kq:=FKH_JS_GTRIu(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace procedure PBH_DO_BH_CN_KTRA(b_ma_dvi varchar2,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Kiem tra so du
select nvl(min(ngay_ht),0) into b_i1 from bh_do_bh_sc where ma_dvi=b_ma_dvi and sign(ton)<>sign(ton_qd);
if b_i1<>0 then b_loi:='loi:Sai so du ngay '||pkh_so_cng(b_i1)||':loi'; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_DO_BH_CN_THOP(
    b_ma_dvi varchar2,b_ps varchar2,b_ngay_ht number,b_nha_bh varchar2,
    b_ma_nt varchar2,b_tien number,b_tien_qd number,b_loi out varchar2)
AS
    b_thu number; b_chi number; b_ton number; b_i1 number; b_i2 number;
    b_thu_qd number; b_chi_qd number; b_ton_qd number;
begin
-- Dan - Tong hop so cai
if b_ps='T' then b_thu:=b_tien; b_thu_qd:=b_tien_qd; b_chi:=0; b_chi_qd:=0;
else b_thu:=0; b_thu_qd:=0; b_chi:=b_tien; b_chi_qd:=b_tien_qd;
end if;
FBH_DO_BH_CN_TON(b_ma_dvi,b_nha_bh,b_ma_nt,b_ngay_ht-1,b_ton,b_ton_qd);
update bh_do_bh_sc set thu=thu+b_thu,thu_qd=thu_qd+b_thu_qd,chi=chi+b_chi,chi_qd=chi_qd+b_chi_qd
    where ma_dvi=b_ma_dvi and nha_bh=b_nha_bh and ma_nt=b_ma_nt and ngay_ht=b_ngay_ht;
if sql%rowcount=0 then
    insert into bh_do_bh_sc values(b_ma_dvi,b_nha_bh,b_ma_nt,b_thu,b_thu_qd,b_chi,b_chi_qd,0,0,b_ngay_ht);
end if;
for b_rc in (select * from bh_do_bh_sc where ma_dvi=b_ma_dvi and nha_bh=b_nha_bh and
    ma_nt=b_ma_nt and ngay_ht>=b_ngay_ht order by ngay_ht) loop
    b_i1:=b_rc.ngay_ht;
    if b_rc.thu=0 and b_rc.chi=0 and b_rc.thu_qd=0 and b_rc.chi_qd=0 then
        delete bh_do_bh_sc where ma_dvi=b_ma_dvi and nha_bh=b_nha_bh and ma_nt=b_ma_nt and ngay_ht=b_i1;
    else
        b_ton:=b_ton+b_rc.thu-b_rc.chi; b_ton_qd:=b_ton_qd+b_rc.thu_qd-b_rc.chi_qd;
        update bh_do_bh_sc set ton=b_ton,ton_qd=b_ton_qd where
            ma_dvi=b_ma_dvi and nha_bh=b_nha_bh and ma_nt=b_ma_nt and ngay_ht=b_i1;
    end if;
end loop;
select nvl(min(ngay_ht),0) into b_i1 from bh_do_bh_sc where ma_dvi=b_ma_dvi and sign(ton)<>sign(ton_qd);
if b_i1<>0 then
    b_loi:='loi:Sai so du ngay '||pkh_so_cng(b_i1)||':loi'; return;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_DO_BH_CN_TON(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_nha_bh varchar2(20); cs_lke clob;
begin
-- Dan - Liet ke chung tu giam dinh theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','DO','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_nha_bh:=FKH_JS_GTRIs(b_oraIn,'nha_bh');
if trim(b_nha_bh) is null then
    b_loi:='loi:Nhap nha bao hiem:loi'; raise PROGRAM_ERROR;
end if;
select JSON_ARRAYAGG(json_object(ma_nt,ton) order by ma_nt) into cs_lke
    from bh_do_bh_sc where ma_dvi=b_ma_dvi and nha_bh=b_nha_bh and ton<>0 and (ma_nt,ngay_ht) in
    (select ma_nt,max(ngay_ht) from bh_do_bh_sc where ma_dvi=b_ma_dvi and nha_bh=b_nha_bh group by ma_nt);
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DO_BH_CN_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number;
    dt_ct clob; dt_txt clob;
begin
-- Dan - Xem chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_loi:='loi:Thanh toan da xoa:loi';
select txt into dt_txt from bh_hd_do_cn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
select json_object(so_ct,'txt' value dt_txt returning clob) into dt_ct
    from bh_hd_do_cn where ma_dvi=b_ma_dvi and so_id=b_so_id;
select json_object('so_id' value b_so_id,'dt_ct' value dt_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DO_BH_CN_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_so_id number;
    b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number; b_phong varchar2(10);
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','DO','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_hd_do_cn where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id,'nha_bh' value FBH_MA_NBH_TEN(nha_bh),nsd) returning clob) into cs_lke from
            (select so_id,nha_bh,nsd,rownum sott from bh_hd_do_cn where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by b_so_id desc)
            where sott between b_tu and b_den;
    end if;
else
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_hd_do_cn where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id,'nha_bh' value FBH_MA_NBH_TEN(nha_bh),nsd) returning clob) into cs_lke from
            (select so_id,nha_bh,nsd,rownum sott from bh_hd_do_cn where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by b_so_id desc) 
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DO_BH_CN_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_phong varchar2(10); b_tu number; b_den number;
    b_so_id number; b_ngay_ht number; b_klk varchar2(1); b_trangkt number;
    b_trang number; b_dong number; cs_lke clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','DO','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_klk,b_trangKt using b_oraIn;
if b_klk ='N' then
    select count(*) into b_dong from bh_hd_do_cn where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,rownum sott from bh_hd_do_cn where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc) where so_id<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id,'nha_bh' value FBH_MA_NBH_TEN(nha_bh),nsd) returning clob) into cs_lke from
        (select so_id,nha_bh,nsd,rownum sott from bh_hd_do_cn where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc)
        where sott between b_tu and b_den;
else
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_hd_do_cn where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,rownum sott from bh_hd_do_cn where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id desc) where so_id<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id,'nha_bh' value FBH_MA_NBH_TEN(nha_bh),nsd) returning clob) into cs_lke from
        (select so_id,nha_bh,nsd,rownum sott from bh_hd_do_cn where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id desc)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DO_BH_CN_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(200); cs_lke clob:='';
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number; b_nha_bh varchar2(20);
begin
-- Dan - Tim thanh toan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','DO','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,nha_bh');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_nha_bh using b_oraIn;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
b_nha_bh:=nvl(trim(b_nha_bh),' ');
select JSON_ARRAYAGG(json_object(ngay_ht,so_ct,nd,so_id)
    order by ngay_ht desc,so_id returning clob) into cs_lke from bh_hd_do_cn
    where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and b_nha_bh in(' ',nha_bh) and rownum<201;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DO_BH_CN_TEST
    (b_ma_dvi varchar2,b_nsd varchar2,b_ngay_ht number,b_l_ct varchar2,
    b_nha_bh varchar2,b_ma_nt varchar2,b_tien number,b_tien_qd out number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number;
begin
if b_ngay_ht is null or b_l_ct is null or b_l_ct not in('T','C') or b_nha_bh is null or
    b_ma_nt is null or b_tien is null or b_tien=0 then
    b_loi:='loi:Sai so lieu nhap:loi'; return;
end if;
b_loi:='loi:Ma khach hang chua dang ky:loi';
select 0 into b_i1 from bh_ma_nbh where ma=b_nha_bh;
if b_l_ct='C' then
    FBH_DO_BH_CN_TON(b_ma_dvi,b_nha_bh,b_ma_nt,b_ngay_ht,b_i1,b_i2);
    if b_i1<b_tien then b_loi:='loi:Qua so du tien:loi'; return; end if;
end if;
b_tien_qd:=PBH_DO_BH_CN_QD(b_ma_dvi,b_nha_bh,b_ma_nt,b_ngay_ht,b_l_ct,b_tien);
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_DO_BH_CN_NH_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_l_ct varchar2,b_ngay_ht number,b_so_id number,
    b_nha_bh varchar2,b_so_ct varchar2,b_nd nvarchar2,
    b_ma_nt varchar2,b_tien number,b_tien_qd number,dt_ct clob,b_loi out varchar2)
AS
    b_phong varchar2(10):=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
begin
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','DO');
if b_loi is not null then return; end if;
b_loi:='loi:Loi Table bh_do_bh_cn:loi';
insert into bh_hd_do_cn values(b_ma_dvi,b_so_id,b_ngay_ht,b_l_ct,b_nha_bh,
    b_so_ct,b_nd,b_ma_nt,b_tien,b_tien_qd,b_phong,b_nsd,sysdate,0);
insert into bh_hd_do_cn_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
PBH_DO_BH_CN_THOP(b_ma_dvi,b_l_ct,b_ngay_ht,b_nha_bh,b_ma_nt,b_tien,b_tien_qd,b_loi);
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_DO_BH_CN_XOA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh varchar2,b_loi out varchar2)
AS
    b_l_ct varchar2(1); b_ngay_ht number; b_nha_bh varchar2(20);
    b_ma_nt varchar2(5); b_tien number; b_tien_qd number; b_nsd_c varchar2(10); b_so_id_kt number;
begin
select l_ct,ngay_ht,nha_bh,ma_nt,tien,tien_qd,nsd,so_id_kt into
    b_l_ct,b_ngay_ht,b_nha_bh,b_ma_nt,b_tien,b_tien_qd,b_nsd_c,b_so_id_kt
    from bh_hd_do_cn where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nsd<>b_nsd_c then b_loi:='loi:Khong sua, xoa chung tu nguoi khac:loi'; return; end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','DO');
if b_loi is not null then return; end if;
if b_so_id_kt>0 then
    PBH_KT_TD_XOA(b_ma_dvi,b_so_id_kt,b_loi);
    if b_loi is not null then return; end if;
end if;
PBH_DO_BH_CN_THOP(b_ma_dvi,b_l_ct,b_ngay_ht,b_nha_bh,b_ma_nt,-b_tien,-b_tien_qd,b_loi);
if b_loi is not null then return; end if;
delete bh_hd_do_cn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_do_cn where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_DO_BH_CN_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_lenh varchar2(2000); dt_ct clob;
    b_so_id number; b_ngay_ht number; b_l_ct varchar2(1); b_nha_bh varchar2(20);
    b_so_ct varchar2(20); b_nd nvarchar2(500); b_ma_nt varchar2(5); b_tien number; b_tien_qd number;
begin
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','DO','N');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id'); dt_ct:=FKH_JS_GTRIc(b_oraIn,'dt_ct');
b_lenh:=FKH_JS_LENH('l_ct,nha_bh,ma_nt,tien,so_ct,nd,ngay_ht');
EXECUTE IMMEDIATE b_lenh into b_l_ct,b_nha_bh,b_ma_nt,b_tien,b_so_ct,b_nd,b_ngay_ht using dt_ct;
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
else
    PBH_DO_BH_CN_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'C',b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_DO_BH_CN_TEST(b_ma_dvi,b_nsd,b_ngay_ht,b_l_ct,b_nha_bh,b_ma_nt,b_tien,b_tien_qd,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_so_ct) is null then
    b_so_ct:=substr(to_char(b_so_id),3); PKH_JS_THAY(dt_ct,'so_ct',b_so_ct);
end if;
PBH_DO_BH_CN_NH_NH(b_ma_dvi,b_nsd,b_l_ct,b_ngay_ht,b_so_id,b_nha_bh,b_so_ct,b_nd,b_ma_nt,b_tien,b_tien_qd,dt_ct,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
select json_object('so_id' value b_so_id,'so_ct' value b_so_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DO_BH_CN_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_so_id number;
begin
-- Dan - Xoa tam ung
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','DO','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
if b_so_id is null or b_so_id=0 then
    b_loi:='loi:Chon xoa thanh toan:loi'; raise PROGRAM_ERROR;
end if;
PBH_DO_BH_CN_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'K',b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DO_BH_CN_LKE_TON(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_nbh varchar2(20):=nvl(trim(b_oraIn),' ');
begin
-- Dan - Liet ke ton
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_nbh=' ' then b_loi:='loi:Nhap ma nha bao hiem:loi'; raise PROGRAM_ERROR; end if;
insert into temp_1 value(c1,n1)
    select ma_nt,ton from bh_do_bh_sc where ma_dvi=b_ma_dvi and nha_bh=b_nbh and ton<>0 and (ma_nt,ngay_ht) in
    (select ma_nt,max(ngay_ht) from bh_do_bh_sc where ma_dvi=b_ma_dvi and nha_bh=b_nbh group by ma_nt);
select JSON_ARRAYAGG(json_object('ma_nt' value c1,'ton' value n1) order by c1,c2) into b_oraOut from temp_1;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
