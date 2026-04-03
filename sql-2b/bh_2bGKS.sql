create or replace procedure PBH_2BG_KHD(dt_ct clob,dt_dk clob,dt_khd clob,b_loi out varchar2)
as
    b_lenh varchar2(2000); b_i1 number; b_s varchar2(200);
    kma_ma pht_type.a_var; kma_nd pht_type.a_var;
begin
-- Dan - Kiem soat dieu kien rieng
b_lenh:=FKH_JS_LENH('ma,nd');
EXECUTE IMMEDIATE b_lenh bulk collect into kma_ma,kma_nd using dt_khd;
for b_lp in 1..kma_ma.count loop
    b_s:='PBH_P2BG_KHD_'||kma_ma(b_lp);
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
