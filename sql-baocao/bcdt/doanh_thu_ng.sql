create or replace procedure PBH_NG_DT_THANG
    (b_ma_dviN varchar2, b_nsd varchar2, b_pas varchar2,b_oraIn clob, b_oraOut out clob)
AS
    b_loi varchar2(100); b_nv varchar2(2):='NG';
    b_thang number:=FKH_JS_GTRIn(b_oraIn,'thang_dt');
    b_thangC number; b_thangD number; b_ngayB date;
    dt_ct clob; dt_ps clob; dt_psnv clob;
begin
--nampb -- bao cao doanh thu phat sinh theo thang line NG
delete temp_1;
b_loi := FHT_MA_NSD_KTRA(b_ma_dviN, b_nsd, b_pas, 'BH', '', '');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ngayB := PKH_SO_CDT(trunc(b_thang, -4) + 101);
--Luoi 1 Chi tiet thong tin theo ma_dvi
-- (3) Doanh thu PS trong ky — chi ma_dvi co phat sinh
insert into temp_1(c1,n2,n3) select d.ma_dvi, nvl(sum(t.phicp), 0),nvl(sum(t.phicb), 0)
       from (select distinct ma_dvi from sli_dt_th_lh where nv = b_nv) d
       left join sli_dt_th_lh t on t.ma_dvi = d.ma_dvi and t.nv=b_nv and t.thang=b_thang group by d.ma_dvi order by d.ma_dvi;
-- (3) Boi thuong PS trong ky
update temp_1 set n12 = ( select sum(nvl(tiengp, 0)) from sli_bt_th_lh where nv=b_nv and ma_dvi=c1 and thang=b_thang);
-- Ten don vi
update temp_1 set c2 = (select ten from ht_ma_dvi where ma=c1);
-- (1) Doanh thu ke hoach
update temp_1 set n5 = (select sum(nvl(goc, 0)) from sli_kh_th_lh where dviK ='K' and dvi=c1 and nv=b_nv and thang=b_thang);
-- (2) Luy ke cung ky nam truoc
b_thangD:=trunc(PKH_NG_CSO(b_ngayB), -4) + 101 - 10000;
b_thangC:=trunc(PKH_NG_CSO(b_ngayB), -2) + 1   - 10000;
update temp_1 set n4 = (select sum(nvl(phicp, 0)) from sli_dt_th_lh where nv=b_nv and ma_dvi=c1 and thang between b_thangD and b_thangC);
-- (4) Doanh thu luy ke
b_thangD := trunc(PKH_NG_CSO(b_ngayB), -4) + 101;
update temp_1 set n6 = (select sum(nvl(phicp, 0)) from sli_dt_th_lh where nv=b_nv and ma_dvi = c1 and thang between b_thangD and b_thang);
-- (8) boi thuong luy ke
update temp_1 set n9 = ( select sum(nvl(tiengp, 0)) from sli_bt_th_lh where nv = b_nv and ma_dvi = c1 and thang between b_thangD and b_thang);
-- (6) % tang truong
b_thangD := b_thang - 10000; 
update temp_1 set n13 = (select nvl(sum(t.phicp), 0) from sli_dt_th_lh t where t.nv = b_nv and t.ma_dvi = c1 and t.thang = b_thangD);
update temp_1 set n8 = (
        case 
            when n13 = 0  and n2 = 0  then 0
            when n13 = 0  and n2 <> 0 then 100
            when n13 <> 0 and n2 = 0  then -100
            else round((n2 - n13) / n13 * 100, 2)
        end
);
-- (9) Ty le BT
update temp_1 set n10 = ROUND(n9 / n6 * 100,2);
    
select JSON_ARRAYAGG(json_object('ma_dvi' value c1,'ten_dvi' value c2,'tiendtp' value nvl(n2,0),'tienb' value nvl(n3,0),'tiendt_kh' value nvl(n5,0),  
               'tiendtl_nt' value nvl(n4,0),'tiendtl' value nvl(n6,0),'ptht' value nvl(n7,0),'pttt' value nvl(n8,0),'btluy' value nvl(n9,0),  
               'tl_bt' value nvl(n10,0),'tienkh' value nvl(n11,0),'tienbt' value nvl(n12,0) returning clob ) returning clob ) into dt_ps from temp_1 order by c1;
delete temp_1;
-- Luoi 2: Chi tiet theo loai hinh nghiep vu   
insert into temp_1(c1, n2, n3) select d.lh_nv,nvl(sum(t.phicp),0),nvl(sum(t.phicb),0)
       from (select distinct lh_nv from sli_dt_th_lh where nv = b_nv) d
       left join sli_dt_th_lh t on t.lh_nv  = d.lh_nv and t.nv = b_nv and t.thang  = b_thang group by d.lh_nv order by d.lh_nv;
-- (3) Boi thuong PS trong ky
update temp_1 set n12 = (select sum(nvl(tiengp, 0)) from sli_bt_th_lh where nv = b_nv and lh_nv = c1 and thang = b_thang);
-- Ten nghiep vu
update temp_1 set c2 = FBH_MA_LHNV_TEN(c1);
-- (1) Doanh thu ke hoach
update temp_1 set n5 = ( select sum(nvl(goc, 0)) from sli_kh_th_lh where dviK  = 'K' and lh_nv = c1 and nv = b_nv and thang = b_thang);
-- (2) Luy ke cung ky nam truoc
b_thangD := trunc(PKH_NG_CSO(b_ngayB), -4) + 101 - 10000;
b_thangC := trunc(PKH_NG_CSO(b_ngayB), -2) + 1 - 10000;
update temp_1 set n4 = (select sum(nvl(phicp, 0)) from sli_dt_th_lh where nv = b_nv and lh_nv = c1 and thang between b_thangD and b_thangC);
-- (4) Doanh thu luy ke
b_thangD := trunc(PKH_NG_CSO(b_ngayB), -4) + 101;
update temp_1 set n6 = ( select sum(nvl(phicp, 0)) from sli_dt_th_lh where nv = b_nv and lh_nv = c1 and thang between b_thangD and b_thang);
-- (8) boi thuong luy ke
update temp_1 set n9 = (select sum(nvl(tiengp, 0)) from sli_bt_th_lh where nv = b_nv and lh_nv = c1 and thang between b_thangD and b_thang);
-- (6) % tang truong
b_thangD := b_thang - 10000;
update temp_1 set n13 = (select nvl(sum(t.phicp), 0) from sli_dt_th_lh t where t.nv = b_nv and t.lh_nv = c1 and t.thang = b_thangD);
update temp_1 set n8 = (
        case 
            when n13 = 0  and n2 = 0  then 0
            when n13 = 0  and n2 <> 0 then 100
            when n13 <> 0 and n2 = 0  then -100
            else round((n2 - n13) / n13 * 100, 2)
        end
);
-- (9) Ty le BT
update temp_1 set n10 = decode(n6,0,0,ROUND(n9 / n6 * 100,2));

select JSON_ARRAYAGG(
           json_object('ma_nv' value c1,'ten_nv' value c2,'thang' value nvl(n1,0),'tiendtp' value nvl(n2,0),'tienb' value nvl(n3,0),'tiendt_kh' value nvl(n5,0),
               'tiendtl_nt' value nvl(n4,0),'tiendtl' value nvl(n6,0),'ptht' value nvl(n7, 0),'pttt' value nvl(n8,0),'btluy' value nvl(n9,0),
               'tl_bt' value nvl(n10,0),'tienkh' value nvl(n11,0),'tienbt' value nvl(n12,0) returning clob) returning clob) into dt_psnv from temp_1 order by c1;
    
select json_object( 'nam' value substr(to_char(b_thang), 1, 4), 'thang' value substr(to_char(b_thang), 5, 2)) into dt_ct from dual;
select json_object('dt_ct' value dt_ct,'dt_ps' value dt_ps,'dt_psnv' value dt_psnv returning clob) into b_oraOut from dual;
delete temp_1;commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105, b_loi); end if;
end;
/
create or replace procedure PBH_NG_DT_CN
    (b_ma_dviN varchar2, b_nsd varchar2, b_pas varchar2,b_oraIn clob, b_oraOut out clob)
AS
    b_loi varchar2(100); b_nv varchar2(2):='NG'; b_ten_dvi nvarchar2(500);
    b_thang number:=FKH_JS_GTRIn(b_oraIn,'thang_dt'); b_ma_dvi varchar2(20):=FKH_JS_GTRI(b_oraIn,'ma_dvi');
    b_thangC number; b_thangD number; b_ngayB date; dt_ct clob; dt_ps clob;
begin
--nampb -- bao cao doanh thu phat sinh theo thang line NG
delete temp_1;
b_loi := FHT_MA_NSD_KTRA(b_ma_dviN, b_nsd, b_pas, 'BH', '', '');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma_dvi is null then b_ma_dvi:= ' '; end if;
if b_ma_dvi = ' ' then b_loi:='loi:Phai chon don vi:loi'; return; end if;
select ten into b_ten_dvi from ht_ma_dvi where ma=b_ma_dvi;
-- (3) Doanh thu PS trong ky
insert into temp_1(c1,c3,n3,n4) select t.ma_dvi,t.lh_nv,nvl(sum(t.phicp), 0),nvl(sum(t.phicb), 0)
       from sli_dt_th_lh t where t.ma_dvi = b_ma_dvi and t.thang=b_thang and nv=b_nv group by t.ma_dvi,t.lh_nv;
--Luoi 1 Chi tiet thong tin theo ma_dvi
-- (2) doanh thu luy ke cung ky nam truoc
b_ngayB := PKH_SO_CDT(trunc(b_thang, -4) + 101);
b_thangD:=trunc(PKH_NG_CSO(b_ngayB), -4) + 101 - 10000;
b_thangC:=trunc(PKH_NG_CSO(b_ngayB), -2) + 1   - 10000;
update temp_1 set n2 = ( select sum(nvl(phicp, 0)) from sli_dt_th_lh where ma_dvi=b_ma_dvi and nv=b_nv and thang between b_thangD and b_thangC and lh_nv=c3 and ma_dvi=c1); 
-- Boi thuong PS trong ky
update temp_1 set n13 = ( select sum(nvl(tiengp, 0)) from sli_bt_th_lh where ma_dvi=b_ma_dvi and nv=b_nv and thang=b_thang);
-- Ten don vi
update temp_1 set c2 = (select ten from ht_ma_dvi where ma=c1);
-- Ten nghiep vu
update temp_1 set c4 = (select ten from bh_ma_lhnv where ma=c3 and nv=b_nv);
-- (1) Doanh thu ke hoach
update temp_1 set n6 = (select sum(nvl(goc, 0)) from sli_kh_th_lh where dviK ='K' and dvi=c1 and nv=b_nv and thang=b_thang);
-- (2) Luy ke cung ky nam truoc
update temp_1 set n5 = (select sum(nvl(phicp, 0)) from sli_dt_th_lh where nv=b_nv and ma_dvi=c1 and thang between b_thangD and b_thangC);
-- (4) Doanh thu luy ke
b_thangD := trunc(PKH_NG_CSO(b_ngayB), -4) + 101;
update temp_1 set n7 = (select sum(nvl(phicp, 0)) from sli_dt_th_lh where nv=b_nv and ma_dvi = c1 and thang between b_thangD and b_thang);
-- (8) boi thuong luy ke
update temp_1 set n10 = ( select sum(nvl(tiengp, 0)) from sli_bt_th_lh where nv = b_nv and ma_dvi = c1 and thang between b_thangD and b_thang);
-- (9) ty le boi thuong: 8/4
update temp_1 set n11 = DECODE(n7, 0, 0, n10 / n7);
-- (6) % tang truong
b_thangD := b_thang - 10000;
update temp_1 set n13 = (select nvl(sum(t.phicp), 0) from sli_dt_th_lh t where t.nv = b_nv and t.ma_dvi = c1 and t.thang = b_thangD);
update temp_1 set n9 = (
        case
            when n13 = 0  and n3 = 0  then 0
            when n13 = 0  and n3 <> 0 then 100
            when n13 <> 0 and n3 = 0  then -100
            else round((n3 - n13) / n13 * 100, 2)
        end
);
-- bt trong ky
update temp_1 set n14 = ( select sum(nvl(tienCP, 0)) from sli_bt_th_lh where nv = b_nv and ma_dvi = c1 and thang between b_thangD and b_thang);

select JSON_ARRAYAGG(json_object('ma_dvi' value c1,'ten_dvi' value c2,'ma_nv' value c3,'ten_nv' value c4,
               'tiendtp_lke' value nvl(n2,0),'tiendtp' value nvl(n3,0),'tienb' value nvl(n4,0),'tiendt_kh' value nvl(n6,0),
               'tiendtl_nt' value nvl(n5,0),'tiendtl' value nvl(n7,0),'ptht' value nvl(n8,0),'pttt' value nvl(n9,0),'btluy' value nvl(n10,0),
               'tl_bt' value nvl(n11,0),'tienkh' value nvl(n12,0),'tienbt' value nvl(n13,0),'bt_tk' value nvl(n14,0) returning clob ) returning clob ) into dt_ps from temp_1 order by c1;
delete temp_1;
select json_object( 'nam' value substr(to_char(b_thang), 1, 4), 'thang' value substr(to_char(b_thang), 5, 2),'dvi' value b_ten_dvi) into dt_ct from dual;
select json_object('dt_ct' value dt_ct,'dt_ps' value nvl(dt_ps,' ') returning clob) into b_oraOut from dual;
delete temp_1;commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105, b_loi); end if;
end;
/
create or replace procedure PBH_NG_DT_PS(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100);b_i1 number; b_nam number; b_nv varchar2(2):='NG';
    b_thangC number; b_thangD number; b_ngayB date; dt_ct clob; dt_ds clob; dt_ds1 clob;
begin
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
-- Dan - Liet ke cac hop dong no phi
delete temp_1; delete temp_2;
b_nam:=FKH_JS_GTRIn(b_oraIn,'nam_dt');
if b_loi is not null then raise PROGRAM_ERROR; end if;
insert into temp_1(c1,n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11,n12,n13)
    select lh_nv,th_1, th_2, th_3, th_4, th_5, th_6,th_7, th_8, th_9, th_10, th_11, th_12,
    nvl(th_1,0) + nvl(th_2,0) + nvl(th_3,0) + nvl(th_4,0) + nvl(th_5,0) + nvl(th_6,0) +
    nvl(th_7,0) + nvl(th_8,0) + nvl(th_9,0) + nvl(th_10,0) + nvl(th_11,0) + nvl(th_12,0) as th_dtps from (
      select lh_nv,to_char(to_date(thang, 'yyyymmdd'), 'MM') as thang,sum(phicp) tienp
      from sli_dt_th_lh where nv='NG' and extract(year from to_date(thang, 'yyyymmdd')) = b_nam group by lh_nv,thang
    )
    pivot
    (
        sum(tienp) for thang in ('01' as th_1,'02' as th_2,'03' as th_3,'04' as th_4,'05' as th_5, '06' as th_6,
                                 '07' as th_7,'08' as th_8,'09' as th_9,'10' as th_10,'11' as th_11,'12' as th_12));
-- ten lhnv
update temp_1 set c2=(select nvl(ten,' ') from bh_ma_lhnv where ma=c1);

insert into temp_2(c1,n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11,n12,n13)
    select ma_dvi,th_1, th_2, th_3, th_4, th_5, th_6,th_7, th_8, th_9, th_10, th_11, th_12,
    nvl(th_1,0) + nvl(th_2,0) + nvl(th_3,0) + nvl(th_4,0) + nvl(th_5,0) + nvl(th_6,0) +
    nvl(th_7,0) + nvl(th_8,0) + nvl(th_9,0) + nvl(th_10,0) + nvl(th_11,0) + nvl(th_12,0) as th_dtps from (
      select ma_dvi,to_char(to_date(thang, 'yyyymmdd'), 'MM') as thang,sum(phicp) tienp
      from sli_dt_th_lh where nv='NG' and extract(year from to_date(thang, 'yyyymmdd')) = b_nam group by ma_dvi,thang
    )
    pivot
    (
        sum(tienp) for thang in ('01' as th_1,'02' as th_2,'03' as th_3,'04' as th_4,'05' as th_5, '06' as th_6,
                                 '07' as th_7,'08' as th_8,'09' as th_9,'10' as th_10,'11' as th_11,'12' as th_12));
-- ten dvi
update temp_2 set c2=(select nvl(ten,' ') from ht_ma_dvi where ma=c1);
select json_object('nam' value b_nam) into dt_ct from dual;
select JSON_ARRAYAGG(json_object(
    'ma_lhnv' value nvl(c1,' '),'ten_lhnv' value nvl(c2,' '),'th_1' value nvl(n1,0),'th_2' value nvl(n2,0),'th_3' value nvl(n3,0),'th_4' value nvl(n4,0),
    'th_5' value nvl(n5,0),'th_6' value nvl(n6,0),'th_7' value nvl(n7,0),'th_8' value nvl(n8,0),'th_9' value nvl(n9,0),'th_10' value nvl(n10,0),
    'th_11' value nvl(n11,0),'th_12' value nvl(n12,0),'th_dtps' value nvl(n13,0))) into dt_ds from temp_1;
select JSON_ARRAYAGG(json_object(
    'ma_dvi' value nvl(c1,' '),'ten_dvi' value nvl(c2,' '),'th_1' value nvl(n1,0),'th_2' value nvl(n2,0),'th_3' value nvl(n3,0),'th_4' value nvl(n4,0),
    'th_5' value nvl(n5,0),'th_6' value nvl(n6,0),'th_7' value nvl(n7,0),'th_8' value nvl(n8,0),'th_9' value nvl(n9,0),'th_10' value nvl(n10,0),
    'th_11' value nvl(n11,0),'th_12' value nvl(n12,0),'th_dtps' value nvl(n13,0))) into dt_ds1 from temp_2;
select json_object('dt_ct' value dt_ct, 'dt_ds' value dt_ds, 'dt_ds1' value dt_ds1 returning clob) into b_oraOut from dual;
delete temp_1; delete temp_2; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/