create or replace procedure PBH_IN_TSO_LKE(b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
b_lenh clob;
b_loi varchar2(100);
b_nv varchar2(20);
b_tu number;
b_den number;
b_dong number;
cs_lke clob:='';
begin
  b_lenh:=FKH_JS_LENH('nv,tu,den');
  EXECUTE IMMEDIATE b_lenh into b_nv,b_tu,b_den using b_oraIn;

  select count(*) into b_dong from BH_IN_GCN_TSO where nv = b_nv;
  if b_dong <> 0 then
    select JSON_ARRAYAGG(json_object(nv,ten,duong_dan,ham,ma,'kyso' value kyso,pbh returning clob)  returning clob)
        into cs_lke from (select nv,ten,duong_dan,ham,ma,kyso,pbh,ROW_NUMBER() over(ORDER BY ten) as sott from BH_IN_GCN_TSO where nv = b_nv)
        where sott between b_tu and b_den;
  end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then rollback; raise PROGRAM_ERROR;
end;
/
create or replace procedure PBH_BH_IN_TSO_MA(b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
b_lenh clob; b_loi varchar2(100);b_ma varchar2(50);
b_i1 number;a_bt clob;
begin
  b_lenh:=FKH_JS_LENH('ma');
  EXECUTE IMMEDIATE b_lenh into b_ma using b_oraIn;

  select json_object('nv' value nv,'duong_dan' value duong_dan,'ham' value ham,'ma' value ma)
                into b_oraOut from bh_in_tso where ma = b_ma;
exception when others then rollback; raise PROGRAM_ERROR;
end;

/