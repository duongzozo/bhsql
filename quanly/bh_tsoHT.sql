-- Tso he thong
create or replace procedure PBH_TSO_HT_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tu,den');
EXECUTE IMMEDIATE b_lenh into b_tu,b_den using b_oraIn;
select count(*) into b_dong from bh_tso_ht;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(ma,ten,loai) order by ma returning clob) into cs_lke from
    (select ma,ten,loai,row_number() over (order by ma) sott  from bh_tso_ht order by ma)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TSO_HT_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob, b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_hangkt number;
    b_trang number; b_dong number; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_tso_ht;
select nvl(min(sott),b_dong) into b_tu from
    (select ma,row_number() over (order by ma) sott from bh_tso_ht order by ma)
    where ma>=b_ma;
PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
select JSON_ARRAYAGG(json_object(ma,ten,loai) order by ma returning clob) into cs_lke from
    (select ma,ten,loai,row_number() over (order by ma) sott  from bh_tso_ht order by ma)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TSO_HT_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
    cs_ct clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select min(json_object(ma,ten,loai)) into cs_ct from bh_tso_ht where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TSO_HT_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_loai varchar2(10);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,loai');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_loai using b_oraIn;
b_ma:=nvl(trim(b_ma),' '); b_ten:=nvl(trim(b_ten),' '); b_loai:=nvl(trim(b_loai),' ');
if b_ma=' ' or b_ten=' ' then b_loi:='loi:Nhap ma, ten:loi'; raise PROGRAM_ERROR; end if;
if b_loai not in('J') then b_loi:='loi:Nhap sai loai:loi'; raise PROGRAM_ERROR; end if;
delete bh_tso_ht where ma=b_ma;
insert into bh_tso_ht values(b_ma,b_ten,b_loai);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TSO_HT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ma:=nvl(trim(b_ma),' ');
if b_ma=' ' then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_tso_ht where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_TSO_HT_JOB_TGIAN(b_ma varchar2) return number
AS
    b_kq number;
begin
-- Dan
select nvl(min(tgian),0) into b_kq from bh_tso_ht_job where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_TSO_HT_JOB_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,'tgian' value FBH_TSO_HT_JOB_TGIAN(ma)) order by ma returning clob)
    into b_oraOut from bh_tso_ht where loai='J';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TSO_HT_JOB_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    a_ma pht_type.a_var; a_ten pht_type.a_nvar; a_tgian pht_type.a_num;
    b_i1 number := 0;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tgian');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma,a_tgian using b_oraIn;
for b_lp in 1..a_ma.count loop
    a_ma(b_lp):=nvl(trim(a_ma(b_lp)),' ');
    if a_ma(b_lp)=' ' then b_loi:='loi:Nhap ma dong '||to_char(b_lp)||':loi'; raise PROGRAM_ERROR; end if;
   -- b_loi:='loi:Ma '||a_ma(b_lp)||' da xoa:loi';
    select ten into a_ten(b_lp) from bh_tso_ht where ma=a_ma(b_lp);
    a_tgian(b_lp):=nvl(a_tgian(b_lp),0);
end loop;
for b_lp in 1..a_ma.count loop
    --duong sua lai, insert ALL loi constraint
    select count(*) into b_i1 from bh_tso_ht_job where ma = a_ma(b_lp);
    if b_i1 <> 0 then
       update bh_tso_ht_job set ten = a_ten(b_lp), tgian=a_tgian(b_lp) where ma = a_ma(b_lp);
    else
      insert into bh_tso_ht_job values (a_ma(b_lp),a_ten(b_lp),a_tgian(b_lp));
    end if;
    -- duong them, update thoi gian chay job khi sua tham so
    PBH_JOB_SET_ATTRIBUTE(a_ma(b_lp));
end loop;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- duong tao pbh update repeat_interval cho job, lay cau hinh thoi gian tu tso_ht
create or replace procedure pbh_job_set_attribute(b_ma varchar2) as
  b_interval varchar2(100);
  b_tgian    number;
  b_job_name varchar2(200);
  b_cnt      number;
begin
  b_job_name := UPPER(b_ma);

  select count(*)
  into b_cnt
  from all_scheduler_jobs
  where job_name = upper(b_ma);

  if b_cnt = 0 then
    return;
  end if;

  select tgian
  into b_tgian
  from bh_tso_ht_job
  where ma = b_ma;

  if b_tgian = 0 THEN
    DBMS_SCHEDULER.DISABLE(b_job_name, force => TRUE);
  else
    b_interval := 'FREQ=MINUTELY;INTERVAL=' || b_tgian;

    DBMS_SCHEDULER.DISABLE(b_job_name, force => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE(
      name      => b_job_name,
      attribute => 'repeat_interval',
      value     => b_interval
    );
    DBMS_SCHEDULER.ENABLE(b_job_name);
  end if;
end;

