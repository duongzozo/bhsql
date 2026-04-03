create or replace procedure BC_BH_CTIEU_KT(
    dk_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000); b_loi varchar2(100); b_i1 number;
    b_ngayd number :=FKH_JS_GTRIn(b_oraIn,'ngayd'); b_ngayc number :=FKH_JS_GTRIn(b_oraIn,'ngayc');
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi'); b_thangD number := trunc(b_ngayd,-2)+01; b_thangC number := trunc(b_ngayc,-2)+01; 
    b_ngay_bc varchar2(100);b_ten_dvi varchar2(500);b_tkvuc varchar2(500);
    dt_ct clob;dt_ds clob;dt_ts clob;
begin
delete temp_1;
b_ma_dvi:=nvl(trim(b_ma_dvi),dk_ma_dviN);
--ASCIISTR(N'Tên doanh nghiệp bảo hiểm')
b_ten_dvi := UNISTR(' - T\00ean doanh nghi\1ec7p b\1ea3o hi\1ec3m: ') || FHT_MA_DVI_TEN(b_ma_dvi);
b_ngay_bc := UNISTR(' - B\00e1o c\00e1o qu\00fd: T\1eeb ') || PKH_SO_CNG(b_ngayd) || UNISTR(' \0111\1ebfn ') || PKH_SO_CNG(b_ngayc);
b_tkvuc := FHT_MA_DVI_TEN_KVUC(b_ma_dvi) || UNISTR(',\004E\0067\00E0\0079 ') || to_char(sysdate,'DD') || UNISTR(' \0074\0068\00E1\006E\0067 ') || to_char(sysdate,'MM') 
    || UNISTR(' \006E\0103\006D ') || to_char(sysdate,'YYYY');
/*temp_1 n1-xep,c1-ma,c2-ten,c3-lvl,c4-ma_ct,
n3-PHIGP_KENH1,n4-TIENGP_KENH1,n5-PHIGP_KENH2,n6-TIENGP_KENH2,n7-PHIGP_KENH8,n8-TIENGP_KENH8 ,n9=n3+n5+n7,n10=n4+n6+n8 
*/
insert into temp_1 (n1,c1,c2,c3,c4,n3,n4,n5,n6,n7,n8,n9,n10)
select row_number() over(order by ord) as stt, lpad(' ',(lvl-1)*2) || case when lvl <= 3 then ma else '-' || ma end, ten, lvl, ma_ct, 0,0,0,0,0,0,0,0
from ( select level lvl, ma, ten, rownum ord, ma_ct
    from bh_ma_lhnv_bo start with ma_ct = ' ' connect by prior ma = ma_ct order siblings by ma);

update temp_1 p set (n3,n5,n7)=(
    select
        sum(case when t.kenh='1' then nvl(t.PHIGP,0) else 0 end),
        sum(case when t.kenh='2' then nvl(t.PHIGP,0) else 0 end),
        sum(case when t.kenh='8' then nvl(t.PHIGP,0) else 0 end)
    from sli_dt_th_lh t where trim(upper(t.lh_bo)) = trim(upper(p.c1)) and t.thang between b_thangD and b_thangC);

update temp_1 p set (n4,n6,n8)=(
    select
        sum(case when t.kenh='1' then nvl(t.TIENGP,0) else 0 end),
        sum(case when t.kenh='2' then nvl(t.TIENGP,0) else 0 end),
        sum(case when t.kenh='8' then nvl(t.TIENGP,0) else 0 end)
    from sli_bt_th_lh t where trim(upper(t.lh_bo)) = trim(upper(p.c1)) and t.thang between b_thangD and b_thangC);

update temp_1 p set n9 = nvl(n3,0) + nvl(n5,0) + nvl(n7,0), n10 = nvl(n4,0) + nvl(n6,0) + nvl(n8,0);

/*tinh tong gia tri ma cap tren*/
update temp_1 p set (n3,n4,n5,n6,n7,n8,n9,n10) = ( 
    select sum(nvl(c.n3,0)), sum(nvl(c.n4,0)), sum(nvl(c.n5,0)), sum(nvl(c.n6,0)), sum(nvl(c.n7,0)), 
        sum(nvl(c.n8,0)), sum(nvl(c.n9,0)), sum(nvl(c.n10,0))
    from temp_1 c start with trim(upper(c.c4)) = trim(upper(p.c1)) connect by nocycle prior trim(upper(c.c1)) = trim(upper(c.c4)))
where exists ( select 1 from temp_1 c where trim(upper(c.c4)) = trim(upper(p.c1)));
/*tong cuoi*/
insert into temp_1(n1,c2,c3,c4,c1,n3,n4,n5,n6,n7,n8,n9,n10) 
  select 0, ' ', '0', ' ', 'I.', sum(nvl(c.n3,0)), sum(nvl(c.n4,0)), sum(nvl(c.n5,0)), sum(nvl(c.n6,0)), sum(nvl(c.n7,0)), 
    sum(nvl(c.n8,0)), sum(nvl(c.n9,0)), sum(nvl(c.n10,0))
  from temp_1 c where c.c1 <> 'I.' and c.c3 = '1';
/*thay doi bac de khop voi setup font excel*/
update temp_1 set c3 ='0' where c3 = '1';
update temp_1 set n3 = round(n3 / 1000000), n4 = round(n4 / 1000000),n5 = round(n5 / 1000000),n6 = round(n6 / 1000000),
    n7 = round(n7 / 1000000), n8 = round(n8 / 1000000), n9 = round(n9 / 1000000), n10 = round(n10 / 1000000);
--sort xep theo cap va ma
update temp_1 set c1 = '', c2 =(c1 || '.' || c2) where c3 = 3;
update temp_1 t set c1='', c2 = (select to_nchar(lpad('-', x.c3 - 3, '-') || ' ' || t.c1 || '.' || t.c2)
     from ( select n1, c3 from temp_1 where c3 >= 4) x
   where x.n1 = t.n1) where t.c3 >= 4;

select json_arrayagg(json_object('STT' value c1,'NVU' value c2,'N3' value FBH_CSO_TIEN(nvl(n3,0),''),
    'N4' value FBH_CSO_TIEN(nvl(n4,0),''),'N5' value FBH_CSO_TIEN(nvl(n5,0),''),'N6' value FBH_CSO_TIEN(nvl(n6,0),''),
    'N7' value FBH_CSO_TIEN(nvl(n7,0),''),'N8' value FBH_CSO_TIEN(nvl(n8,0),''),'N9' value FBH_CSO_TIEN(nvl(n9,0),''),
    'N10' value FBH_CSO_TIEN(nvl(n10,0),''), 'BAC' value c3 ) order by n1 returning clob) into dt_ds from temp_1 where nvl(c1,' ') <> 'I.';
select json_arrayagg(json_object('STT' value c1,'NVU' value c2,'N3' value FBH_CSO_TIEN(nvl(n3,0),''),
    'N4' value FBH_CSO_TIEN(nvl(n4,0),''),'N5' value FBH_CSO_TIEN(nvl(n5,0),''),'N6' value FBH_CSO_TIEN(nvl(n6,0),''),
    'N7' value FBH_CSO_TIEN(nvl(n7,0),''),'N8' value FBH_CSO_TIEN(nvl(n8,0),''),'N9' value FBH_CSO_TIEN(nvl(n9,0),''),
    'N10' value FBH_CSO_TIEN(nvl(n10,0),''), 'BAC' value c3 ) order by n1 returning clob) into dt_ts from temp_1 where nvl(c1,' ') = 'I.';
select json_object('ten_dvi' value b_ten_dvi, 'ngaybc' value b_ngay_bc,'ngay_tbc' value b_tkvuc) into dt_ct from dual;
select json_object('dt_ct' value dt_ct,'dt_ds' value dt_ds,'dt_ts' value dt_ts returning clob) into b_oraOut from dual;

delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
/
create or replace procedure BC_BH_TRICH_LDP_TH
    (b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000); b_loi varchar2(100); b_i1 number; b_ngayB_D number; b_ngayB_C number;
    b_ngayD number; b_ngayD_NT number; b_ma_dvi varchar2(10);
    b_ngay_bc varchar2(100); b_ngay_lap varchar2(100); b_ten_dvi varchar2(500); b_ten_nsd nvarchar2(500); b_ngayB date;
    dt_ct clob; dt_ds clob;
begin
--nampb: bao cao trich yeu du phong tong hop
b_loi := FHT_MA_NSD_KTRA(b_ma_dviN, b_nsd, b_pas, 'BH', '', '');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,ngayd,ngayc');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_ngayB_D,b_ngayB_C using b_oraIn;
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
b_ten_dvi := UNISTR(' - T\00ean doanh nghi\1ec7p b\1ea3o hi\1ec3m: ') || FHT_MA_DVI_TEN(b_ma_dvi);
b_ngay_bc := UNISTR(' - B\00e1o c\00e1o qu\00fd: T\1eeb ') || PKH_SO_CNG(b_ngayB_D) || UNISTR(' \0111\1ebfn ') || PKH_SO_CNG(b_ngayB_C);
b_ngay_lap := UNISTR('T.p H\1ED3 Ch\00ED Minh, ng\00E0y ') || FBH_IN_CSO_NG(b_ngayB_D,'DD') || UNISTR(' th\00E1ng ')
             || FBH_IN_CSO_NG(b_ngayB_D,'MM') ||  UNISTR(' n\0103m ') || FBH_IN_CSO_NG(b_ngayB_D,'YYYY');
b_ten_nsd:= FHT_MA_NSD_TEN(b_ma_dvi,b_nsd);
b_ngayD := trunc(b_ngayB_D,-2)+01;
delete temp_1;
if b_ngayD is null or b_ngayB_C is null or b_ngayD > b_ngayB_C then
      b_loi:='loi:Nhap ngay bao cao:loi'; raise PROGRAM_ERROR;
end if;
insert into temp_1 (c1,c2,c3,c4,c5,n1,n2,n3) select ma,ma_nv,ten_nv,lvl,ma_ct,0,0,0
    from (
    select 
        level as lvl,ma,ten,rownum as ord,ma_ct,
        to_nchar(lpad('', (level-1)*2)) || case when level < 3 then to_nchar(ma) else to_nchar('') end as ma_nv,
        to_nchar(lpad('', (level-1)*2)) || 
        case 
            when level < 3 then to_nchar(ten)
            when level = 3 then to_nchar(ma) || to_nchar('. ') || to_nchar(ten)
            else to_nchar('- ') || to_nchar(ten)
        end as ten_nv
    from bh_ma_lhnv_bo start with ma_ct = ' ' connect by prior ma = ma_ct order siblings by ma);
-- du phong phi chua duoc huong

-- du phong boi thuong
update temp_1 set n4=(select nvl(sum(tiengd),0) from sli_bt_ng_lh where lh_bo=c1 and ngay=b_ngayB_D);
update temp_1 set n6=(select nvl(sum(tiengd),0) from sli_bt_ng_lh where lh_bo=c1 and ngay=b_ngayB_C);
update temp_1 set n5=nvl(n6 - n4,0);
-- du phong boi thuong cho cac dao dong lon ve ton that
update temp_1 set n7=(select nvl(sum(phicp) / 100,0) from sli_dt_ng_lh where lh_bo=c1 and ngay=b_ngayB_D);
update temp_1 set n8=(select nvl(sum(phicp) / 100,0) from sli_dt_ng_lh where lh_bo=c1 and ngay=b_ngayB_C);
update temp_1 set n9=nvl(n8 - n7,0);
--tong du phong
update temp_1 set n10 = NVL(n1 + n4 + n7, 0), n11 = NVL(n2 + n5 + n9, 0),  n12 = NVL(n3 + n6 + n8, 0);

select json_arrayagg(json_object('STT' value c2,'TENNV' value c3,'CAP' value c4,'BT_TIENGD_D' value n4,'BT_TIENGD_TG' value n5,'BT_TIENGD_C' value n6,
       'DT_PHICP_D' value n7,'DT_PHICP_TG' value n9,'DT_PHICP_C' value n8,'TONG_D' value n10,'TONG_TG' value n11,'TONG_C' value n12,'CHI_TK' value 0) returning clob) into dt_ds from temp_1;
select json_object('ten_dvi' value b_ten_dvi, 'ngay_bc' value b_ngay_bc, 'ng_lap' value b_ten_nsd, 'ngay_lap' value b_ngay_lap) into dt_ct from dual;
select json_object('dt_ct' value dt_ct,'dt_ds' value dt_ds returning clob) into b_oraOut from dual;

delete temp_1; commit;

exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
CREATE OR REPLACE PROCEDURE BC_BH_TRICH_LDP_CT
    (dk_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000); b_loi varchar2(100); b_i1 number; b_ngayd number :=FKH_JS_GTRIn(b_oraIn,'ngayd'); b_ngayc number :=FKH_JS_GTRIn(b_oraIn,'ngayc');
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');b_ma_nv varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_nv');b_tkvuc varchar2(500);
    b_ngay_bc varchar2(100);b_ten_dvi varchar2(500); b_ngayB date;
    dt_ct clob;dt_ts clob;dt_ds clob;
begin
b_ma_dvi:=nvl(trim(b_ma_dvi),dk_ma_dviN);
--ASCIISTR(N'Tên doanh nghiệp bảo hiểm')
b_ten_dvi := UNISTR(' - T\00ean doanh nghi\1ec7p b\1ea3o hi\1ec3m: ') || FHT_MA_DVI_TEN(b_ma_dvi);
b_ngay_bc := UNISTR(' - B\00e1o c\00e1o qu\00fd: T\1eeb ') || PKH_SO_CNG(b_ngayd) || UNISTR(' \0111\1ebfn ') || PKH_SO_CNG(b_ngayc);
b_tkvuc := FHT_MA_DVI_TEN_KVUC(b_ma_dvi) || UNISTR(',\004E\0067\00E0\0079 ') || to_char(sysdate,'DD') || UNISTR(' \0074\0068\00E1\006E\0067 ') || to_char(sysdate,'MM') 
    || UNISTR(' \006E\0103\006D ') || to_char(sysdate,'YYYY');
delete temp_1;
if b_ngayd is null or b_ngayc is null or b_ngayd > b_ngayc then
      b_loi:='loi:Nhap ngay bao cao:loi'; raise PROGRAM_ERROR;
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ngayB:=PKH_SO_CDT(trunc(b_ngayd,-4)+101);
/*temp_1 n1-xep,c1-ma,c2-ten,c3-lvl,c4-ma_ct,c5-xep_ktu,
n3-tienCP,n4-ta_diTP,n5-ta_diNP,n6-ta_veTP,n7-ta_veNP,n8-tienGK ,n9=n3-n4-n5+n6+n7-n8,n10- 
*/
insert into temp_1 (n1,c1,c2,c3,c4,n3,n4,n5,n6,n7,n8,n9)
select row_number() over(order by ord) as stt, lpad(' ',(lvl-1)*2) || case when lvl <= 3 then ma else '-' || ma end, ten, lvl, ma_ct, 0,0,0,0,0,0,0
from ( select level lvl, ma, ten, rownum ord, ma_ct
    from bh_ma_lhnv_bo start with ma_ct = ' ' connect by prior ma = ma_ct order siblings by ma);

-- boi thuong ps trong ky (1)
update temp_1 p set (n3,n6)=(
    select sum(nvl(t.phiCP,0)), sum(nvl(t.phiCP, 0)) * 0.03
    from sli_dt_ng_lh t where trim(upper(t.lh_bo)) = trim(upper(p.c1)) and t.ngay between b_ngayd and b_ngayc);
    
update temp_1 p set n8=(
    select sum(nvl(t.phiCP,0))/100
    from sli_dt_th_lh t where trim(upper(t.lh_bo)) = trim(upper(p.c1)) and t.thang between b_ngayd and b_ngayc);
    
update temp_1 p set n4 = (select
        nvl(sum(case when t.ngay = b_ngayc then t.dpp end),0) - nvl(sum(case when t.ngay = b_ngayd then t.dpp end),0) from bh_dpp t
    where trim(upper(t.NV)) = trim(upper(p.c1)));

update temp_1 p set n5 = (select
        nvl(sum(case when t.ngay = b_ngayc then t.tienGD end),0) - nvl(sum(case when t.ngay = b_ngayd then t.tienGD end),0) 
        from sli_bt_ng_lh t where trim(upper(t.NV)) = trim(upper(p.c1)));

update temp_1 set n9 = nvl(n4,0) + nvl(n5,0) + nvl(n8,0);

update temp_1 p set (n3,n4,n5,n6,n7,n8,n9) = ( 
    select sum(nvl(c.n3,0)), sum(nvl(c.n4,0)), sum(nvl(c.n5,0)), sum(nvl(c.n6,0)), sum(nvl(c.n7,0)), 
        sum(nvl(c.n8,0)), sum(nvl(c.n9,0))
    from temp_1 c start with trim(upper(c.c4)) = trim(upper(p.c1)) connect by nocycle prior trim(upper(c.c1)) = trim(upper(c.c4)))
where exists ( select 1 from temp_1 c where trim(upper(c.c4)) = trim(upper(p.c1)));

insert into temp_1(n1,c5,c2,c3,c4,c1,n3,n4,n5,n6,n7,n8,n9) 
  select 0, ' ','', '0', ' ', 'I.', sum(nvl(c.n3,0)), sum(nvl(c.n4,0)), sum(nvl(c.n5,0)), sum(nvl(c.n6,0)), sum(nvl(c.n7,0)), 
    sum(nvl(c.n8,0)), sum(nvl(c.n9,0))
  from temp_1 c where c.c1 <> 'I.' and c.c3 = '1';

update temp_1 set c3 ='0' where c3 = '1';
update temp_1 set n3 = round(n3 / 1000000), n4 = round(n4 / 1000000),n5 = round(n5 / 1000000),n6 = round(n6 / 1000000),
    n7 = round(n7 / 1000000), n8 = round(n8 / 1000000), n9 = round(n9 / 1000000);
--sort xep theo cap va ma
update temp_1 set c1 = ' ', c2 =(c1 || '.' || c2) where c3 = 3;
update temp_1 t set c1='', c2 = (select to_nchar(lpad('-', x.c3 - 3, '-') || ' ' || t.c1 || '.' || t.c2)
     from ( select n1, c3 from temp_1 where c3 >= 4) x
   where x.n1 = t.n1) where t.c3 >= 4;
select json_arrayagg(json_object('STT' value c1,'NVU' value c2,'N3' value FBH_CSO_TIEN(nvl(n3,0),''),
    'N4' value FBH_CSO_TIEN(nvl(n4,0),''),'N5' value FBH_CSO_TIEN(nvl(n5,0),''),'N6' value FBH_CSO_TIEN(nvl(n6,0),''),
    'N7' value FBH_CSO_TIEN(nvl(n7,0),''),'N8' value FBH_CSO_TIEN(nvl(n8,0),''),'N9' value FBH_CSO_TIEN(nvl(n9,0),''),
    'BAC' value c3 ) order by n1 returning clob) into dt_ds from temp_1 where nvl(c1,' ') <> 'I.';
select json_arrayagg(json_object('STT' value c1,'NVU' value c2,'N3' value FBH_CSO_TIEN(nvl(n3,0),''),
    'N4' value FBH_CSO_TIEN(nvl(n4,0),''),'N5' value FBH_CSO_TIEN(nvl(n5,0),''),'N6' value FBH_CSO_TIEN(nvl(n6,0),''),
    'N7' value FBH_CSO_TIEN(nvl(n7,0),''),'N8' value FBH_CSO_TIEN(nvl(n8,0),''),'N9' value FBH_CSO_TIEN(nvl(n9,0),''),
    'BAC' value c3 ) order by n1 returning clob) into dt_ts from temp_1 where nvl(c1,' ') = 'I.';
select json_object('ten_dvi' value b_ten_dvi, 'ngaybc' value b_ngay_bc, 'ngay_tbc' value b_tkvuc) into dt_ct from dual;
select json_object('dt_ct' value dt_ct,'dt_ds' value dt_ds,'dt_ts' value dt_ts returning clob) into b_oraOut from dual;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure BC_BH_KQKD_VCXE
    (dk_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000); b_loi varchar2(100); b_i1 number; b_ngayd number :=FKH_JS_GTRIn(b_oraIn,'ngayd');
    b_ngayc number :=FKH_JS_GTRIn(b_oraIn,'ngayc'); b_thangNT number;
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_ngay_bc varchar2(100);b_ten_dvi varchar2(500);b_ten_nsd varchar2(500);b_tkvuc varchar2(500);
    dt_ct clob;dt_ts clob;dt_ds clob;
begin
b_ma_dvi:=nvl(trim(b_ma_dvi),dk_ma_dviN);
--ASCIISTR(N'T?n doanh nghi?p b?o hi?m')
b_ten_dvi := UNISTR(' - T\00ean doanh nghi\1ec7p b\1ea3o hi\1ec3m: ') || FHT_MA_DVI_TEN(b_ma_dvi);
b_ngay_bc := UNISTR(' - B\00e1o c\00e1o qu\00fd: T\1eeb ') || PKH_SO_CNG(b_ngayd) || UNISTR(' \0111\1ebfn ') || PKH_SO_CNG(b_ngayc);
b_tkvuc := FHT_MA_DVI_TEN_KVUC(b_ma_dvi) || UNISTR(',\004E\0067\00E0\0079 ') || to_char(sysdate,'DD') || UNISTR(' \0074\0068\00E1\006E\0067 ') || to_char(sysdate,'MM')

    || UNISTR(' \006E\0103\006D ') || to_char(sysdate,'YYYY');
b_ten_nsd:= FHT_MA_NSD_TEN(b_ma_dvi,b_nsd);
delete temp_1; delete temp_2;
if b_ngayd is null or b_ngayc is null or b_ngayd > b_ngayc then
      b_loi:='loi:Nhap ngay bao cao:loi'; raise PROGRAM_ERROR;
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
insert into temp_2 (c1) select ma from BH_MA_LHNV where loai = 'V';

insert into temp_1 (n1, c1, c2, c3, c4, c5, n2, n3, n4, n10)
select  (row_number() over (order by ma) - 1) * 5 + 1 as n1, 'c' as c1, trim(to_char(row_number() over (order by ma), 'RN')) as c2,
    ten, loai_xe, lh_nv, so_xe, tieng, phigp, phicp / 100
from (select  l.ma, l.ten, s.loai_xe, s.lh_nv, sum(nvl(s.so_xe, 0)) as so_xe, sum(nvl(s.tieng, 0)) as tieng,
    sum(nvl(s.phigp, 0)) as phigp, sum(nvl(s.phicp, 0)) as phicp
    from bh_xe_loai l join sli_xe_th_lh s on l.ma = s.loai_xe
where s.thang between b_ngayd and b_ngayc group by l.ma, l.ten, s.loai_xe, s.lh_nv) t;

update temp_1 p
set (n8, n9) = ( select
        nvl(sum(case when t.ngay = b_ngayc then t.dpp end), 0)
      - nvl(sum(case when t.ngay = b_ngayd then t.dpp end), 0),
        nvl(sum(case when t.ngay = b_ngayc then t.dpb end), 0)
      - nvl(sum(case when t.ngay = b_ngayd then t.dpb end), 0)
    from bh_dpp_xe t where t.lh_nv = p.c4 and t.loai_xe = p.c3);

insert into temp_1 (n1, c1, c2, c3, c4, c5, n2, n3, n4, n10)
select p.n1 + row_number() over (partition by p.n1 order by g.grp) as n1, 'n' as c1, row_number() over (partition by p.n1 order by g.grp) as c2,
    case
        when g.grp = 1 then 'Dưới 3 năm'
        when g.grp = 2 then 'Từ 3 đến dưới 6 năm'
        when g.grp = 3 then 'Từ 6 đến dưới 10 năm'
        when g.grp = 4 then 'Trên 10 năm'
    end as c3, p.c4, p.c5, nvl(sum(s.so_xe), 0) as n2, nvl(sum(s.tieng), 0) as n3, nvl(sum(s.phigp), 0) as n4, nvl(sum(s.phicp), 0) / 100 as n10
from temp_1 p
cross join (
    select 1 as grp from dual union all select 2 from dual union all select 3 from dual union all select 4 from dual) g
left join sli_xe_th_lh s on s.loai_xe = p.c4 and s.lh_nv = p.c5
  and ((g.grp = 1 and s.tuoi < 3) or (g.grp = 2 and s.tuoi >= 3 and s.tuoi < 6) or 
  (g.grp = 3 and s.tuoi >= 6 and s.tuoi < 10) or (g.grp = 4 and s.tuoi >= 10))
where p.c1 = 'c' group by p.n1, p.c4, p.c5, g.grp;

update temp_1 p set (n8, n9) = ( select
  nvl(sum(case when t.ngay = b_ngayc then t.dpp end), 0) - nvl(sum(case when t.ngay = b_ngayd then t.dpp end), 0),
  nvl(sum(case when t.ngay = b_ngayc then t.dpb end), 0) - nvl(sum(case when t.ngay = b_ngayd then t.dpb end), 0)
  from bh_dpp_xe t where t.lh_nv = p.c5 and t.loai_xe = p.c4 and (
    (p.c3 = '<3 nam' and t.tuoi < 3) or (p.c3 = '3-6 nam' and t.tuoi >= 3 and t.tuoi < 6) or 
    (p.c3 = '6-10 nam' and t.tuoi >= 6 and t.tuoi < 10) or (p.c3 = '>=10 nam' and t.tuoi >= 10))) where p.c1 = 'n';

insert into temp_1 (c1, n2, n3, n4, n5, n6, n7, n8, n9, n10) select UNISTR('t'),
 nvl(sum(n2),0), nvl(sum(n3),0), nvl(sum(n4),0), nvl(sum(n5),0), 
 nvl(sum(n6),0), nvl(sum(n7),0), nvl(sum(n8),0), nvl(sum(n9),0), nvl(sum(n10),0) from temp_1;

update temp_1 set n3 = round(n3 / 1000000), n4 = round(n4 / 1000000),n5 = round(n5 / 1000000),
n6 = round(n6 / 1000000), n7 = round(n7 / 1000000), n8 = round(n8 / 1000000), n9 = round(n9 / 1000000), n10 = round(n10 / 1000000);

select json_arrayagg(json_object('STT' value c2,'C1' value c3,'C2' value n2,'C3' value FBH_CSO_TIEN(nvl(n3,0),''),'C4' value FBH_CSO_TIEN(nvl(n4,0),''),
  'C5' value FBH_CSO_TIEN(nvl(n5,0),''),'C6' value FBH_CSO_TIEN(nvl(n6,0),''),'C7' value FBH_CSO_TIEN(nvl(n7,0),''),
  'C8' value FBH_CSO_TIEN(nvl(n8,0),''),'C9' value FBH_CSO_TIEN(nvl(n9,0),''),'C10' value FBH_CSO_TIEN(nvl(n10,0),''), 'BAC' value c1 ) order by n1 returning clob)
  into dt_ds from temp_1 where nvl(c1,' ') <> 't';
select json_arrayagg(json_object('C2' value n2,'C3' value FBH_CSO_TIEN(nvl(n3,0),''),'C4' value FBH_CSO_TIEN(nvl(n4,0),''),
  'C5' value FBH_CSO_TIEN(nvl(n5,0),''),'C6' value FBH_CSO_TIEN(nvl(n6,0),''),'C7' value FBH_CSO_TIEN(nvl(n7,0),''),
  'C8' value FBH_CSO_TIEN(nvl(n8,0),''),'C9' value FBH_CSO_TIEN(nvl(n9,0),''),'C10' value FBH_CSO_TIEN(nvl(n10,0),''), 'BAC' value c1 ) returning clob)
  into dt_ts from temp_1 where nvl(c1,' ') = 't';
select json_object('ten_dvi' value b_ten_dvi, 'bc' value b_ngay_bc,'nbc' value b_tkvuc,'nsd' value b_ten_nsd) into dt_ct from dual;
select json_object('ct' value dt_ct,'ds' value dt_ds,'ts' value dt_ts returning clob) into b_oraOut from dual;

delete temp_1; delete temp_2; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/