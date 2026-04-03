create or replace procedure PBH_NGTD_KHD(dt_ct clob,dt_khd clob,b_loi out varchar2)
as
    b_lenh varchar2(2000); b_i1 number; b_s varchar2(200);
    kma_ma pht_type.a_var; kma_nd pht_type.a_var;
begin
-- Dan - Kiem soat dieu kien rieng
b_lenh:=FKH_JS_LENH('ma,nd');
EXECUTE IMMEDIATE b_lenh bulk collect into kma_ma,kma_nd using dt_khd;
for b_lp in 1..kma_ma.count loop
    b_s:='PBH_NGTD_KHD_'||kma_ma(b_lp);
    select count(*) into b_i1 from USER_PROCEDURES where OBJECT_NAME=b_s;
    if b_i1=0 then b_loi:='loi:Chua tao ham '||b_s||':loi'; return; end if;
    b_lenh:='begin '||b_s||'(:nd,:dt_ct,:loi); end;';
    b_s:=trim(kma_nd(b_lp));
    execute immediate b_lenh using b_s,dt_ct,out b_loi;
    if b_loi is not null then b_loi:='loi:'||b_loi||':loi'; return; end if;
end loop;
b_loi:='';
end;
/
create or replace procedure PBH_NGTD_KHD_GIOI(b_nd varchar2,dt_ct clob,b_loi out varchar2)
as
	b_gioi varchar2(1);
begin
-- Dan - Kiem soat GIOI
b_loi:='Sai gioi';
if trim(FKH_JS_GTRIs(dt_ct,'tend')) is null then
	b_gioi:=FKH_JS_GTRIs(dt_ct,'gioi');
else
	b_gioi:=FKH_JS_GTRIs(dt_ct,'gioid');
end if;
if b_nd=b_gioi then b_loi:=''; end if;
exception when others then null;
end;
/
create or replace procedure PBH_NGTD_KHD_KTUOI(b_nd varchar2,dt_ct clob,b_loi out varchar2)
as
    b_ng_sinh number; b_ngay_hl number; b_tuoi number; b_tu number; b_den number:=200;
    a_ch pht_type.a_var;
begin
-- Dan - Kiem soat TUOI
b_loi:='Sai khoang tuoi';
if instr(b_nd,'-')=0 then return; end if;
if trim(FKH_JS_GTRIs(dt_ct,'tend')) is null then
	b_ng_sinh:=FKH_JS_GTRIn(dt_ct,'ng_sinh');
else
	b_ng_sinh:=FKH_JS_GTRIn(dt_ct,'ng_sinhd');
end if;
b_ngay_hl:=FKH_JS_GTRIs(dt_ct,'ngay_hl'); b_tuoi:=FKH_KHO_NASO(b_ng_sinh,b_ngay_hl);
PKH_CH_ARR(b_nd,a_ch,'-');
b_tu:=PKH_LOC_CHU_SO(a_ch(1),'F','F');
if a_ch.count>1 then b_den:=PKH_LOC_CHU_SO(a_ch(2),'F','F'); end if;
if b_tuoi between b_tu and b_den then b_loi:=''; end if;
exception when others then null;
end;
/
create or replace procedure PBH_NGTD_KHD_TGT(b_nd varchar2,dt_ct clob,b_loi out varchar2)
as
  b_ngay_hl number; b_ngay_kt number; b_kho number;
begin
-- Nam - Kiem soat hieu luc toi thieu
b_loi:='So ngay hieu luc toi thieu '||b_nd||' ngay';
b_ngay_hl:=FKH_JS_GTRIn(dt_ct,'ngay_hl'); b_ngay_kt:=FKH_JS_GTRIn(dt_ct,'ngay_kt');
b_kho:=FKH_KHO_NGSO(b_ngay_hl,b_ngay_kt);
if b_nd<=b_kho then b_loi:=''; end if;
exception when others then null;
end;
/
create or replace procedure PBH_NGTD_KHD_TGD(b_nd varchar2,dt_ct clob,b_loi out varchar2)
as
  b_ngay_hl number; b_ngay_kt number; b_kho number;
begin
-- Nam - Kiem soat hieu luc toi da
b_loi:='So ngay hieu luc toi da '||b_nd||' ngay';
b_ngay_hl:=FKH_JS_GTRIn(dt_ct,'ngay_hl'); b_ngay_kt:=FKH_JS_GTRIn(dt_ct,'ngay_kt');
b_kho:=FKH_KHO_NGSO(b_ngay_hl,b_ngay_kt);
if b_nd>=b_kho then b_loi:=''; end if;
exception when others then null;
end;
/
create or replace procedure PBH_NGTD_KHD_SNT(b_nd varchar2,dt_ct clob,b_loi out varchar2)
as
  b_so_dt  number;
begin
-- Nam - Kiem soat so nguoi toi thieu
b_loi:='So nguoi toi thieu '||b_nd||' nguoi';
b_so_dt:=nvl(FKH_JS_GTRIn(dt_ct,'so_dt'),1);
if b_nd<=b_so_dt then b_loi:=''; end if;
exception when others then null;
end;
/
create or replace procedure PBH_NGTD_KHD_SND(b_nd varchar2,dt_ct clob,b_loi out varchar2)
as
  b_so_dt  number;
begin
-- Nam - Kiem soat so nguoi toi da
b_loi:='So nguoi toi da '||b_nd||' nguoi';
b_so_dt:=nvl(FKH_JS_GTRIn(dt_ct,'so_dt'),1);
if b_nd>=b_so_dt then b_loi:=''; end if;
exception when others then null;
end;