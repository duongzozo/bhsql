/*** DOI CHIEU ***/
create or replace function FTBH_DC_SO_ID(b_so_bk varchar2) return number
AS
    b_kq number:=0;
begin
-- Dan - Tra so Id qua so ct
if trim(b_so_bk) is not null then
    select nvl(min(so_id_dc),0) into b_kq from tbh_dc where so_bk=b_so_bk;
end if;
return b_kq;
end;
/
create or replace function FTBH_DC_SO_CT(b_so_id_dc number) return varchar2
AS
    b_kq varchar2(20):='';
begin
-- Dan - Tra so ct qua so id
if b_so_id_dc<>0 then
    select min(so_bk) into b_kq from tbh_dc where so_id_dc=b_so_id_dc;
end if;
return b_kq;
end;
/
create or replace PROCEDURE PTBH_DC_DP(b_ma_dvi varchar2,b_so_id_dc number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_kieu varchar2(1); b_nha_bh varchar2(20); b_so_bk varchar2(20);
    b_ngay_ht number; b_ngay_dp number; b_ng_dc number; b_nt_tra varchar2(5);
begin
-- Dan - Tong hop du phong
b_loi:='loi:Loi tong hop du phong tai:loi';
b_ngay_dp:=trunc(PKH_NG_CSO(sysdate),-2)+1;
select nvl(min(ng_dc),0),min(ngay_ht) into b_ng_dc,b_ngay_ht from tbh_dc where ma_dvi=b_ma_dvi and so_id_dc=b_so_id_dc;
if b_ng_dc<30000101 then
    if b_ng_dc<>0 then b_ngay_dp:=trunc(b_ng_dc,-2)+1; end if;
else
    b_i2:=trunc(b_ngay_ht,-2)+1;
    select count(*) into b_i1 from (select ngay_dp from tbh_dc_dp where ma_dvi=b_ma_dvi and so_id_dc=b_so_id_dc) where ngay_dp<>b_i2;
    if b_i1=0 then b_ngay_dp:=b_i2; end if;
end if;
delete tbh_dc_dp where ma_dvi=b_ma_dvi and so_id_dc=b_so_id_dc and ngay_dp>=b_ngay_dp;
delete tbh_dc_dp_ct where ma_dvi=b_ma_dvi and so_id_dc=b_so_id_dc and ngay_dp>=b_ngay_dp;
delete tbh_dc_dp_pt where ma_dvi=b_ma_dvi and so_id_dc=b_so_id_dc and ngay_dp>=b_ngay_dp;
if b_ng_dc<30000101 then
    select count(*),min(kieu),min(nha_bh),min(so_bk),min(nt_tra) into b_i1,b_kieu,b_nha_bh,b_so_bk,b_nt_tra
        from tbh_dc_dp where ma_dvi=b_ma_dvi and so_id_dc=b_so_id_dc;
    if b_i1<>0 then
        insert into tbh_dc_dp values(b_ma_dvi,b_so_id_dc,b_ngay_dp,b_kieu,b_nha_bh,b_so_bk,' ',0,0);
    end if;
else
    insert into tbh_dc_dp
        select b_ma_dvi,b_so_id_dc,b_ngay_dp,kieu,nha_bh,so_bk,nt_tra,tra,tra_qd
        from tbh_dc where ma_dvi=b_ma_dvi and so_id_dc=b_so_id_dc;
    insert into tbh_dc_dp_ct
        select b_ma_dvi,b_so_id_dc,b_ngay_dp,so_id_xl
            from tbh_dc_ct where ma_dvi=b_ma_dvi and so_id_dc=b_so_id_dc;
    insert into tbh_dc_dp_pt
        select b_ma_dvi,b_so_id_dc,b_ngay_dp,ma_dvi_ps,so_id_ps,bt_ps,so_id_ta_ps,
        so_id_ta_hd,ps,kieu,nv,loai,goc,ma_ta,nha_bh,pthuc,ma_nt,tien,thue,hhong,tien_qd,thue_qd,hhong_qd
        from tbh_dc_pt where ma_dvi=b_ma_dvi and so_id_dc=b_so_id_dc;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace PROCEDURE PTBH_DC_TONng(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngxlD number; b_ngxlC number;
begin
-- Dan - Liet ke ton ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select nvl(min(a.ngay_ht),0),nvl(max(a.ngay_ht),0) into b_ngxlD,b_ngxlC
    from tbh_xl a,tbh_xl_ton b where b.so_id_xl=a.so_id_xl;
select json_object('ngxld' value b_ngxlD,'ngxlc' value b_ngxlC) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PTBH_DC_TONki(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_ngxlD number; b_ngxlC number;
begin
-- Dan - Liet ke ton ngay => kieu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngxld,ngxlc');
EXECUTE IMMEDIATE b_lenh into b_ngxlD,b_ngxlC using b_oraIn;
if b_ngxlD is null or b_ngxlD in(0,30000101) then
    b_loi:='loi:Nhap ngay bat dau xu ly:loi'; raise PROGRAM_ERROR;
end if;
select JSON_ARRAYAGG(json_object('ma' value ma)) into b_oraOut from
    (select distinct FTBH_XL_KI(a.kieu) ma from tbh_xl a,tbh_xl_ton b
    where a.ngay_ht between b_ngxlD and b_ngxlC and b.so_id_xl=a.so_id_xl);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PTBH_DC_TONnbh(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ngxlD number; b_ngxlC number; b_kieu varchar2(1);
begin
-- Dan - Liet ke ton ngay => kieu => nv
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngxld,ngxlc,kieu');
EXECUTE IMMEDIATE b_lenh into b_ngxlD,b_ngxlC,b_kieu using b_oraIn;
if b_ngxlD is null or b_ngxlD in(0,30000101) then
    b_loi:='loi:Nhap ngay bat dau xu ly:loi'; raise PROGRAM_ERROR;
end if;
if b_ngxlC is null or b_ngxlC=0 then b_ngxlC:=30000101; end if;
if b_kieu is null or b_kieu not in('C','T','N','X') then
    b_loi:='loi:Chon kieu tai:loi'; raise PROGRAM_ERROR;
end if;
select JSON_ARRAYAGG(json_object('ma' value nha_bh,'ten' value FBH_MA_NBH_TEN(nha_bh))) into b_oraOut from
    (select distinct nha_bh from tbh_xl a,tbh_xl_ton b
    where a.ngay_ht between b_ngxlD and b_ngxlC and a.kieu=b_kieu and b.so_id_xl=a.so_id_xl);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PTBH_DC_TONnt(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ngxlD number; b_ngxlC number; b_kieu varchar2(1); b_nha_bh varchar2(20);
begin
-- Dan - Liet ke ton ngay => kieu => nt
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngxld,ngxlc,kieu,nha_bh');
EXECUTE IMMEDIATE b_lenh into b_ngxlD,b_ngxlC,b_kieu,b_nha_bh using b_oraIn;
if b_ngxlD is null or b_ngxlD in(0,30000101) then
    b_loi:='loi:Nhap ngay bat dau xu ly:loi'; raise PROGRAM_ERROR;
end if;
if b_ngxlC is null or b_ngxlC=0 then b_ngxlC:=30000101; end if;
if b_kieu is null or b_kieu not in('C','T','N','X') then
    b_loi:='loi:Chon kieu tai:loi'; raise PROGRAM_ERROR;
end if;
if trim(b_nha_bh) is null then
    b_loi:='loi:Chon nha tai:loi'; raise PROGRAM_ERROR;
end if;
select JSON_ARRAYAGG(json_object('ma' value ma_nt)) into b_oraOut from
    (select distinct ma_nt from tbh_xl a,tbh_xl_ton b
    where a.ngay_ht between b_ngxlD and b_ngxlC and a.kieu=b_kieu and a.nha_bh=b_nha_bh and b.so_id_xl=a.so_id_xl);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PTBH_DC_TON(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(2000); b_txt clob:=b_oraIn;
    b_ngxlD number; b_ngxlC number; b_kieu varchar2(1); b_nha_bh varchar2(20); b_ma_nt varchar2(5);
begin
-- Dan - Liet ke ton
delete tbh_xl_dc_temp; delete tbh_xl_dc_temp1; delete tbh_xl_dc_temp2; delete tbh_xl_dc_temp3; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FKH_JS_NULL(b_txt);
b_lenh:=FKH_JS_LENH('ngxld,ngxlc,kieu,nha_bh,nt_tra');
EXECUTE IMMEDIATE b_lenh into b_ngxlD,b_ngxlC,b_kieu,b_nha_bh,b_ma_nt using b_txt;
if b_ngxlD in(0,30000101) then
    b_loi:='loi:Nhap ngay bat dau xu ly:loi'; raise PROGRAM_ERROR;
end if;
if b_ngxlC=0 then b_ngxlC:=30000101; end if;
if b_kieu not in('C','T','N','X') then b_loi:='loi:Chon kieu tai:loi'; raise PROGRAM_ERROR; end if;
if b_nha_bh=' ' then b_loi:='loi:Chon nha tai:loi'; raise PROGRAM_ERROR; end if;
if b_ma_nt=' ' then b_loi:='loi:Chon loai tien:loi'; raise PROGRAM_ERROR; end if;
insert into tbh_xl_dc_temp select so_id_xl,ngay_ht,so_ct,loai,sum(tra),sum(tien),sum(thue),sum(hhong),0
    from tbh_xl_dc where ma_dvi=b_ma_dvi and ngay_ht between b_ngxlD and b_ngxlC and 
    kieu=b_kieu and nha_bh=b_nha_bh and nt_tra=b_ma_nt and so_id_dc=0 group by so_id_xl,ngay_ht,so_ct,loai;
if sql%rowcount=0 then b_loi:='loi:Da doi chieu het:loi'; raise PROGRAM_ERROR; end if;
for r_lp in (select distinct a.so_id_xl,b.ma_dvi_ps,b.so_id_ps from tbh_xl_dc_temp a,tbh_xl_dc_pbo b
    where b.ma_dvi=b_ma_dvi and b.so_id_xl=a.so_id_xl and goc='BT_HS') loop
    for r_lp1 in (select distinct ma_dvi,so_id from bh_bt_tu where ma_dvi=r_lp.ma_dvi_ps and so_id_hs=r_lp.so_id_ps) loop
        insert into tbh_xl_dc_temp1
            select r_lp.so_id_xl,loai,sum(tien),sum(thue),sum(hhong),sum(tien_qd),sum(thue_qd),sum(hhong_qd) from tbh_dc_pt
            where ma_dvi_ps=r_lp1.ma_dvi and so_id_ps=r_lp1.so_id and nha_bh=b_nha_bh and ma_nt=b_ma_nt group by loai having sum(tien)<>0;
    end loop;
end loop;
insert into tbh_xl_dc_temp2
    select so_id_xl,loai,sum(tien),sum(thue),sum(hhong),sum(tien_qd),sum(thue_qd),sum(hhong_qd)
    from tbh_xl_dc_temp1 group by so_id_xl,loai having sum(tien)<>0;
if sql%rowcount<>0 then
    update tbh_xl_dc_temp a set tung=(select nvl(sum(tien-thue-hhong),0) from tbh_xl_dc_temp2 b where b.so_id_xl=a.so_id_xl and b.loai=a.loai);
end if;
insert into tbh_xl_dc_temp3 select so_id_xl,ngay_ht,so_ct,sum(tra),sum(tien),sum(thue),sum(hhong),sum(tung)
    from tbh_xl_dc_temp group by so_id_xl,ngay_ht,so_ct;
select JSON_ARRAYAGG(json_object(
    'ngay_ht' value ngay_ht,'so_ct' value so_ct,'tien' value tien,'tra' value tra,
    'hhong' value hhong,'thue' value thue,'tung' value tung,'so_id_xl' value so_id_xl,'chon' value '')
    order by ngay_ht,so_ct returning clob) into b_oraOut from tbh_xl_dc_temp3;
delete tbh_xl_dc_temp; delete tbh_xl_dc_temp1; delete tbh_xl_dc_temp2; delete tbh_xl_dc_temp3; commit;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PTBH_DC_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_bk varchar2(20); b_so_id number;
begin
-- Dan - Liet ke ton ngay => kieu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_bk:=FKH_JS_GTRIs(b_oraIn,'so_bk');
b_so_id:=FTBH_DC_SO_ID(b_so_bk);
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_DC_LKE(
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
    select count(*) into b_dong from tbh_dc where ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_bk,kieu,nt_tra,so_id_dc,'nha_bh' value FBH_MA_NBH_TEN(nha_bh)) order by so_id_dc desc returning clob)
            into cs_lke from
            (select so_bk,kieu,nt_tra,nha_bh,so_id_dc,rownum sott from tbh_dc where 
            ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd order by so_id_dc desc)
            where sott between b_tu and b_den;
    end if;
else
    select count(*) into b_dong from tbh_dc where ngay_ht between b_ngayD and b_ngayC;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_bk,kieu,nt_tra,so_id_dc,'nha_bh' value FBH_MA_NBH_TEN(nha_bh)) order by so_id_dc desc returning clob)
            into cs_lke from
            (select so_bk,kieu,nt_tra,nha_bh,so_id_dc,rownum sott from tbh_dc where 
            ngay_ht between b_ngayD and b_ngayC order by so_id_dc desc)
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_DC_LKE_ID(
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
    select count(*) into b_dong from tbh_dc where ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_id_dc,rownum sott from tbh_dc where
        ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd order by so_id_dc desc) where so_id_dc<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_bk,kieu,nt_tra,so_id_dc,'nha_bh' value FBH_MA_NBH_TEN(nha_bh))
        order by so_id_dc desc returning clob) into cs_lke from
        (select so_bk,kieu,nt_tra,nha_bh,so_id_dc,rownum sott from tbh_dc where 
        ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd order by so_id_dc desc)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from tbh_dc where ngay_ht between b_ngayD and b_ngayC;
    select nvl(min(sott),b_dong) into b_tu from (select so_id_dc,rownum sott from tbh_dc where
        ngay_ht between b_ngayD and b_ngayC order by so_id_dc desc) where so_id_dc<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_bk,kieu,nt_tra,so_id_dc,'nha_bh' value FBH_MA_NBH_TEN(nha_bh))
        order by so_id_dc desc returning clob) into cs_lke from
        (select so_bk,kieu,nt_tra,nha_bh,so_id_dc,rownum sott from tbh_dc where 
        ngay_ht between b_ngayD and b_ngayC order by so_id_dc desc)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_DC_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id_dc number;
    dt_ct clob; dt_dk clob; dt_txt clob;
begin
-- Dan - Xem chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id_dc:=FKH_JS_GTRIn(b_oraIn,'so_id_dc');
b_loi:='loi:Xu ly da xoa:loi';
select json_object(so_bk,'nha_bh' value FBH_MA_NBH_TENl(nha_bh))
    into dt_ct from tbh_dc where so_id_dc=b_so_id_dc;
select JSON_ARRAYAGG(json_object(so_id_xl,bt) order by bt) into dt_dk from tbh_dc_ct where so_id_dc=b_so_id_dc;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from tbh_dc_txt where so_id_dc=b_so_id_dc;
select json_object('so_id_dc' value b_so_id_dc,'dt_ct' value dt_ct,'dt_dk' value dt_dk,
    'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_DC_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(200); cs_lke clob:='';
    b_kieu varchar2(1); b_nha_bh varchar2(20);
    b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36)); b_ngayD number; b_ngayC number;
begin
-- Dan - Tim thanh toan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,kieu,nha_bh');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_kieu,b_nha_bh using b_oraIn;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if b_ngayD in(0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
b_kieu:=nvl(trim(b_kieu),' '); b_nha_bh:=nvl(trim(b_nha_bh),' ');
select JSON_ARRAYAGG(json_object(ngay_ht,so_bk,kieu,nt_tra,tra,so_id_dc,'nha_bh' value FBH_MA_NBH_TEN(nha_bh))
    order by ngay_ht desc,kieu,nha_bh returning clob) into cs_lke from
    (select ngay_ht,so_bk,kieu,nha_bh,nt_tra,tra,so_id_dc,rownum sott from tbh_dc where
    ngay_ht between b_ngayD and b_ngayC and b_kieu in(' ',kieu) and b_nha_bh in(' ',nha_bh)
    order by ngay_ht desc,kieu,nha_bh)
    where sott<201;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_DC_TEST(
    b_ma_dvi varchar2,b_so_id_dc number,dt_ct clob,dt_dk clob,
    b_ngay_ht out number,b_kieu out varchar2,b_nha_bh out varchar2,b_nt_tra out varchar2,
    b_so_bk out varchar2,b_so_dc out varchar2,b_ng_dc out number,b_tra out number,b_tra_qd out number,
    a_so_id out pht_type.a_num,a_tra out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_lenh varchar2(2000);
begin
-- Dan - Kiem tra so lieu
b_lenh:=FKH_JS_LENH('ngay_ht,kieu,nha_bh,nt_tra,so_bk,so_dc,ng_dc');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_kieu,b_nha_bh,b_nt_tra,b_so_bk,b_so_dc,b_ng_dc using dt_ct;
b_lenh:=FKH_JS_LENH('so_id_xl,tra');
EXECUTE IMMEDIATE b_lenh bulk collect into a_so_id,a_tra using dt_dk;
if b_ngay_ht is null or b_ngay_ht in(0,30000101) or
    b_kieu is null or b_kieu not in('C','T','N','X') or
    b_nha_bh is null or b_nt_tra is null or a_so_id.count=0 then
    b_loi:='loi:Nhap so lieu sai:loi'; return;
end if;
if b_ng_dc is null or b_ng_dc=30000101 then b_ng_dc:=0; end if;
if b_ng_dc=0 then
    b_so_dc:=' ';
elsif trim(b_so_dc) is null then
    b_loi:='loi:Sai so doi chieu:loi'; return;
end if;
b_tra:=0;
for b_lp in 1.. a_so_id.count loop
    b_loi:='loi:Sai so lieu xu ly dong '||trim(to_char(b_lp))||':loi';
    if a_so_id(b_lp) is null or a_tra(b_lp) is null then return; end if;
    select 0 into b_i1 from tbh_xl_ton where so_id_xl=a_so_id(b_lp) for update nowait;
    if sql%rowcount=0 then return; end if;
    select tra into a_tra(b_lp) from tbh_xl where
        so_id_xl=a_so_id(b_lp) and kieu=b_kieu and nha_bh=b_nha_bh and ma_nt=b_nt_tra;
    b_tra:=b_tra+a_tra(b_lp);
end loop;
if b_nt_tra='VND' then b_tra_qd:=b_tra;
else b_tra_qd:=FBH_TT_VND_QD(b_ngay_ht,b_nt_tra,b_tra);
end if;
if trim(b_so_bk) is null then b_so_bk:=substr(trim(to_char(b_so_id_dc)),3); end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_DC_TEST:loi'; end if;
end;
/
create or replace procedure PTBH_DC_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id_dc number,
    b_ngay_ht number,b_kieu varchar2,b_nha_bh varchar2,b_nt_tra varchar2,
    b_so_bk varchar2,b_so_dc varchar2,b_ng_dc number,b_tra number,b_tra_qd number,
    a_so_id pht_type.a_num,a_tra pht_type.a_num,dt_ct clob,dt_dk clob,b_loi out varchar2)
AS
    b_bt number:=0; b_bt2 number:=10000; b_tien_qd number; b_thue_qd number; b_hhong_qd number;
    b_loai varchar2(10); b_tg number;
begin
-- Dan - Nhap doi chieu
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','TA');
if b_loi is not null then return; end if;
insert into tbh_dc values(
    b_ma_dvi,b_so_id_dc,b_ngay_ht,b_kieu,b_nha_bh,b_so_bk,
    b_so_dc,b_ng_dc,b_nt_tra,b_tra,b_tra_qd,b_nsd,0,0,sysdate);
for b_lp in 1..a_so_id.count loop
    insert into tbh_dc_ct values(b_ma_dvi,b_so_id_dc,b_lp,a_so_id(b_lp),a_tra(b_lp));
    update tbh_xl_dc set so_id_dc=b_so_id_dc,so_id_kt=0,ngay_nh=sysdate where so_id_xl=a_so_id(b_lp);
    delete tbh_xl_ton where so_id_xl=a_so_id(b_lp);
end loop;
delete tbh_dc_temp1; delete tbh_dc_temp2;
for b_lp in 1..a_so_id.count loop
    for r_lp in (select loai from tbh_xl_dc where so_id_xl=a_so_id(b_lp)) loop
        b_loai:=r_lp.loai;
    for r_lp in (select * from tbh_xl_dc_pbo where so_id_xl=a_so_id(b_lp) and loai=b_loai and nha_bh=b_nha_bh) loop
        b_bt:=b_bt+1;
        if r_lp.ma_nt='VND' then
            b_tien_qd:=r_lp.tien; b_thue_qd:=r_lp.thue; b_hhong_qd:=r_lp.hhong;
        else
            b_tg:=FBH_TT_TRA_TGTT(b_ngay_ht,r_lp.ma_nt);
            b_tien_qd:=round(r_lp.tien*b_tg,0); b_thue_qd:=round(r_lp.thue*b_tg,0); b_hhong_qd:=round(r_lp.hhong*b_tg,0);
            if r_lp.goc='TA_UP' then
                select nvl(sum(ung_qd),b_tien_qd) into b_tien_qd from tbh_ung_ps where ma_dvi=r_lp.ma_dvi_ps and so_id=r_lp.so_id_ps;
            elsif r_lp.goc='TA_HU' then
                select nvl(sum(ung_qd),b_tien_qd) into b_tien_qd from tbh_ung_tra where ma_dvi=r_lp.ma_dvi_ps and so_id=r_lp.so_id_ps;
            end if;
        end if;
        insert into tbh_dc_pt values (b_ma_dvi,b_so_id_dc,r_lp.ma_dvi_ps,r_lp.so_id_ps,r_lp.bt_ps,r_lp.so_id_ta_ps,r_lp.so_id_ta_hd,
            b_ngay_ht,r_lp.ps,r_lp.kieu,r_lp.nv,r_lp.loai,r_lp.goc,r_lp.ma_ta,r_lp.nha_bh,r_lp.pthuc,
            r_lp.ma_nt,r_lp.tien,r_lp.thue,r_lp.hhong,b_tien_qd,b_thue_qd,b_hhong_qd,b_bt);
    end loop;
    end loop;
end loop;
for r_lp in (select distinct ma_dvi_ps,so_id_ps from tbh_dc_temp1) loop
    insert into tbh_dc_temp2 select * from tbh_dc_pt where ma_dvi_ps=r_lp.ma_dvi_ps and so_id_ps=r_lp.so_id_ps;
end loop;
for r_lp in (select * from tbh_dc_temp2) loop
    b_bt2:=b_bt2+1;
    insert into tbh_dc_pt values (b_ma_dvi,b_so_id_dc,r_lp.ma_dvi_ps,r_lp.so_id_ps,r_lp.bt_ps,r_lp.so_id_ta_ps,r_lp.so_id_ta_hd,
        b_ngay_ht,r_lp.ps,r_lp.kieu,r_lp.nv,r_lp.loai,'BT_HS',r_lp.ma_ta,r_lp.nha_bh,r_lp.pthuc,
        r_lp.ma_nt,-r_lp.tien,-r_lp.thue,-r_lp.hhong,-r_lp.tien_qd,-r_lp.thue_qd,-r_lp.hhong_qd,b_bt2);
end loop;
insert into tbh_dc_txt values(b_ma_dvi,b_so_id_dc,'dt_ct',dt_ct);
insert into tbh_dc_txt values(b_ma_dvi,b_so_id_dc,'dt_dk',dt_dk);
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_DC_NH_NH:loi'; end if;
end;
/
create or replace procedure PTBH_DC_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id_dc number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_nsd_c varchar2(10); b_ngay_ht number;
begin
-- Dan - Xoa doi chieu
select ngay_ht,nsd,so_id_tt,so_id_kt into b_ngay_ht,b_nsd_c,b_i1,b_i2
    from tbh_dc where ma_dvi=b_ma_dvi and so_id_dc=b_so_id_dc;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','TA');
if b_loi is not null then return; end if;
if trim(b_nsd_c) is not null and b_nsd_c<>b_nsd then b_loi:='loi:Khong sua, xoa chung tu nguoi khac:loi'; return; end if;
if b_i1>0 then b_loi:='loi:Doi chieu da thanh toan:loi'; return; end if;
if b_i2<>0 then b_loi:='loi:Doi chieu da hach toan:loi'; return; end if;
update tbh_xl_dc set so_id_dc=0,so_id_kt=-1 where so_id_dc=b_so_id_dc;
insert into tbh_xl_ton select ma_dvi,so_id_xl from tbh_dc_ct where so_id_dc=b_so_id_dc;
delete tbh_dc_txt where so_id_dc=b_so_id_dc;
delete tbh_dc_pt where so_id_dc=b_so_id_dc;
delete tbh_dc_ct where so_id_dc=b_so_id_dc;
delete tbh_dc where so_id_dc=b_so_id_dc;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_DC_XOA_XOA:loi'; end if;
end;
/
create or replace procedure PTBH_DC_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_lenh varchar2(2000); dt_ct clob; dt_dk clob;
    b_so_id_dc number; b_ngay_ht number; b_kieu varchar2(1); b_nha_bh varchar2(20); b_nt_tra varchar2(5);
    b_so_bk varchar2(20); b_so_dc varchar2(20); b_ng_dc number; b_tra number; b_tra_qd number;
    a_so_id pht_type.a_num; a_tra pht_type.a_num;
begin
-- Dan - Nhap
delete tbh_dc_temp1; delete tbh_dc_temp2;
if b_comm='C' then
	commit;
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id_dc:=FKH_JS_GTRIn(b_oraIn,'so_id_dc');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk using b_oraIn;
if b_so_id_dc>0 then
    PTBH_DC_XOA_XOA(b_ma_dvi,b_nsd,b_so_id_dc,b_loi);
else
    PHT_ID_MOI(b_so_id_dc,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTBH_DC_TEST(b_ma_dvi,b_so_id_dc,dt_ct,dt_dk,
	b_ngay_ht,b_kieu,b_nha_bh,b_nt_tra,b_so_bk,b_so_dc,b_ng_dc,b_tra,b_tra_qd,
    a_so_id,a_tra,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTBH_DC_NH_NH(b_ma_dvi,b_nsd,b_so_id_dc,b_ngay_ht,b_kieu,
    b_nha_bh,b_nt_tra,b_so_bk,b_so_dc,b_ng_dc,b_tra,b_tra_qd,
    a_so_id,a_tra,dt_ct,dt_dk,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTBH_DC_DP(b_ma_dvi,b_so_id_dc,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('so_id_dc' value b_so_id_dc,'so_bk' value b_so_bk) into b_oraOut from dual;
delete tbh_dc_temp1; delete tbh_dc_temp2;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_DC_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_so_id_dc number;
begin
-- Dan - Xoa doi chieu
if b_comm='C' then
	b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N');
	if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id_dc:=FKH_JS_GTRIn(b_oraIn,'so_id_dc');
if b_so_id_dc is null or b_so_id_dc=0 then
    b_loi:='loi:Nhap doi chieu xoa:loi'; raise PROGRAM_ERROR;
end if;
PTBH_DC_XOA_XOA(b_ma_dvi,b_nsd,b_so_id_dc,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTBH_DC_DP(b_ma_dvi,b_so_id_dc,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
