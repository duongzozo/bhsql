----Duc update--
drop procedure PBH_GDHS_MO;
create or replace procedure PBH_GDHS_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
     b_loi varchar2(100); b_lenh varchar2(1000);
     b_ma_dvi_bt varchar2(20):= FKH_JS_GTRIs(b_oraIn,'ma_dvi_bt');
     cs_ma_dvi clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ten returning clob) into cs_ma_dvi from ht_ma_dvi;
select json_object('cs_ma_dvi' value cs_ma_dvi returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--Duc sua ham nay ơ Hồ sơ giám định-
drop function PBH_BT_HS_SOHS;
create or replace function PBH_BT_HS_SOHS(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_so_hs_bt varchar2(20);
begin
-- Dan - Tra so ID qua so ho so
select nvl(min(so_hs),0) into b_so_hs_bt from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_so_id;
end;

/
create or replace procedure PBH_BT_LSGD_LKE(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_ma_dvi varchar2(10); b_so_id number;
begin
-- Dan - Liet sua doi ho so
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
select JSON_ARRAYAGG(json_object(so_hs,ma_dvi_ql,so_hd,gio,tien,ngay) order by ngay desc returning clob) into cs_lke
    from bh_bt_gd_hsL where so_id=b_so_id;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_GD_TTRANG_HS_MAU
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    cs_ttr clob:='';b_so_id number;
begin
-- Dan - Trang thai ho so
delete temp_1; delete bh_hd_ttrang_temp; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id');
EXECUTE IMMEDIATE b_lenh into b_so_id using b_oraIn;
select count(*) into b_i1 from bh_bt_gd_tu where ma_dvi=b_ma_dvi and so_id_hs=b_so_id;
if b_i1<>0 then insert into bh_hd_ttrang_temp values('gd_tu','V'); end if;
if FBH_BT_GD_HTHANH(b_ma_dvi,b_so_id)='H' then
    insert into temp_1(c3,n5) select ma_nt,max(ngay_ht) from bh_bt_gd_sc where ma_dvi=b_ma_dvi and so_id=b_so_id group by ma_nt;
    update temp_1 set n2=(select ton from bh_bt_gd_sc where ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=c3 and ngay_ht=n5);
    select count(*) into b_i1 from temp_1 where n2<>0;
    if b_i1<>0 then insert into bh_hd_ttrang_temp values('gd_tt','D'); end if;
end if;
select count(*) into b_i1 from bh_hd_ttrang_temp;
if b_i1<>0 then
    select JSON_ARRAYAGG(json_object(nv,tt) returning clob) into cs_ttr from bh_hd_ttrang_temp;
end if;
select json_object('cs_ttr' value cs_ttr) into b_oraOut from dual;
end;
