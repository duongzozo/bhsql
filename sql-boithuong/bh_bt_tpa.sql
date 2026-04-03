/*** Thanh toan boi thuong TPA***/
create or replace procedure PBH_BT_TPA_TPA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(2000);
begin
-- Dan - Tra TPA
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,'ten' value FBH_DTAC_MA_TEN(ma)) returning clob) into b_oraOut from 
    (select distinct FBH_BT_NG_TPA(a.ma_dvi,a.so_id) ma from bh_bt_hs a,bh_bt_ng b where a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and
    a.nv='NG' and a.ttrang='D' and FBH_BT_HS_TON(a.ma_dvi,a.so_id)<>0 and b.loai_hs='A') where ma<>' ';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TPA_TPAl(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(2000);
begin
-- Dan - Tra TPA
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ten returning clob) into b_oraOut from
    bh_ma_gdinh where FBH_MA_GDINH_NV(ma,'NG')='C' and FBH_MA_GDINH_HAN(ma)='C';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TPA_TON(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_tpa varchar2(20):=nvl(trim(b_oraIn),' ');
begin
-- Dan - Tra ton TPA
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_tpa=' ' then b_loi:='loi:Nhap TPA:loi'; raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(
    'so_hs' value so_hs,'so_tpa' value so_tpa,'ma_nt' value ma_nt,'ton' value ton,'tien' value ton,'chon' value '','so_id' value so_id)
    order by so_hs returning clob) into b_oraOut from
    (select so_hs,FBH_BT_NG_SO_TPA(ma_dvi,so_id) so_tpa,nt_tien ma_nt,FBH_BT_HS_TON(b_ma_dvi,so_id) ton,so_id
    from bh_bt_hs where nv='NG' and ttrang='D' and FBH_BT_NG_TPA(ma_dvi,so_id)=b_tpa and 
                  FBH_BT_HS_TON(ma_dvi,so_id)<>0 and FBH_BT_NG_LOAI(ma_dvi,so_id)='A');
                  --nam: them dieu kien chi lay loai_hs=A
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TPA_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id_tt number;
    dt_ct clob; dt_dk clob; dt_txt clob;
begin
-- Dan - Xem chi tiet thanh toan phi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Thanh toan da xoa:loi';
b_so_id_tt:=FKH_JS_GTRIn(b_oraIn,'so_id_tt');
select json_object(so_ct,'tpa' value FBH_DTAC_MA_TENl(tpa)) into dt_ct
    from bh_bt_tt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
select JSON_ARRAYAGG(json_object(so_id) order by bt returning clob) into dt_dk
    from bh_bt_tt_ps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_bt_tt_txt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and loai in ('dt_ct','dt_dk');
select json_object('so_id_tt' value b_so_id_tt,'dt_ct' value dt_ct,
    'dt_dk' value dt_dk,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TPA_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number;
    b_dong number:=0; cs_lke clob:='';    
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_bt_tt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and tpa<>' ' and nsd=b_nsd;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id_tt,ten) returning clob) into cs_lke from
            (select so_id_tt,FBH_DTAC_MA_TEN(tpa) ten,rownum sott from bh_bt_tt where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and tpa<>' ' and nsd=b_nsd order by so_id_tt desc)
            where sott between b_tu and b_den;
    end if;
else
    select count(*) into b_dong from bh_bt_tt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and tpa<>' ';
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id_tt,ten) returning clob) into cs_lke from
            (select so_id_tt,FBH_DTAC_MA_TEN(tpa) ten,rownum sott from bh_bt_tt where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and tpa<>' ' order by so_id_tt desc)
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TPA_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_tu number; b_den number;
    b_so_id number; b_ngay_ht number; b_klk varchar2(1); b_trangkt number;
    b_trang number; b_dong number; cs_lke clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_klk,b_trangKt using b_oraIn;
if b_klk ='N' then
    select count(*) into b_dong from bh_bt_tt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and tpa<>' ' and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_id_tt,rownum sott from bh_bt_tt where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and tpa<>' ' and nsd=b_nsd order by so_id_tt desc) where so_id_tt<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id_tt,ten) returning clob) into cs_lke from
        (select so_id_tt,FBH_DTAC_MA_TEN(tpa) ten,rownum sott from bh_bt_tt where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and tpa<>' ' and nsd=b_nsd order by so_id_tt desc)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_bt_tt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and tpa<>' ';
    select nvl(min(sott),b_dong) into b_tu from (select so_id_tt,rownum sott from bh_bt_tt where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and tpa<>' ' order by so_id_tt desc) where so_id_tt<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id_tt,ten) returning clob) into cs_lke from
        (select so_id_tt,FBH_DTAC_MA_TEN(tpa) ten,rownum sott from bh_bt_tt where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and tpa<>' ' order by so_id_tt desc) 
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TPA_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(200);
    b_ngayD number; b_ngayC number; b_tpa varchar2(20);
    cs_lke clob:=''; b_dong number;
begin
-- Dan - Tim thanh toan TPA
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,tpa');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_tpa using b_oraIn;
if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if; 
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_tpa:=nvl(trim(b_tpa),' ');
if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
select count(*) into b_dong from bh_bt_tt where
    ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and tpa<>' ' and b_tpa in(' ',tpa);
select JSON_ARRAYAGG(json_object(
    'ten' value FBH_DTAC_MA_TEN(tpa),ngay_ht,so_ct,so_id_tt,tpa) order by tpa,ngay_ht desc returning clob) into cs_lke
    from bh_bt_tt where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and tpa<>' ' and b_tpa in(' ',tpa);
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
