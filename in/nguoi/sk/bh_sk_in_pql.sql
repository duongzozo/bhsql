create or replace procedure PBH_SKC_TNCN(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    -- chung
    b_loi varchar2(100); b_lenh varchar2(1000);
    -- orain
    b_so_hd varchar2(50) :=FKH_JS_GTRIs(b_oraIn,'so_hd');
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
    b_i1 number := 0;
    dt_ct clob; dt_bs clob; dt_ds clob; dt_dk clob; dt_lt clob;dt_kbt clob; dt_ttt clob;
    dk_qtac clob;b_dvi clob;dt_tt clob;dt_tt_b clob;
   --san pham
    b_ma_sp varchar(20);b_ten_sp nvarchar2(500):= ' ';
    b_ma_qtac varchar(20);b_qtac varchar(500):= ' ';
    b_so_dt number:= 1;
    --
    dk_tien pht_type.a_num;dk_phi pht_type.a_num;dk_cap pht_type.a_num;
    b_mtn number:=0;b_phi number:=0;
    b_chinhanh nvarchar2(500) :=' ';
    b_ngay_tt number;
    ma_lt pht_type.a_var;b_nd_lt clob;
begin


b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);

select ten into b_chinhanh from ht_ma_dvi where ma = b_ma_dvi;

select count(*) into b_i1 from bh_sk_nh t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id;
if b_i1 <> 0 then
  select sum(so_dt) into b_so_dt from bh_sk_nh t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id;
end if;

select count(*) into b_i1 from bh_sk_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_ct';
if b_i1 <> 0 then
  begin
  SELECT FKH_JS_BONH(t.txt) INTO dt_ct
       FROM bh_sk_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_ct';

  select ma_sp into b_ma_sp from bh_sk  where so_id = b_so_id and ma_dvi=b_ma_dvi;
  if trim(b_ma_sp) is not null then
     select ten into b_ten_sp from bh_sk_sp where ma = b_ma_sp;
  end if;
  select json_object('ten_dvi' value NVL(UPPER(ten),' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
         'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
             from ht_ma_dvi where ma=b_ma_dvi;
  dt_ct:=FKH_JS_BONH(dt_ct);
  b_dvi:=FKH_JS_BONH(b_dvi);
  select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;
  
  SELECT FKH_JS_BONH(t.txt) into dk_qtac FROM bh_sk_sp t, bh_sk t1 WHERE t.ma = t1.ma_sp and t1.so_id=b_so_id;
   b_lenh := FKH_JS_LENH('qtac');
   EXECUTE IMMEDIATE b_lenh INTO b_ma_qtac USING dk_qtac;

  IF b_ma_qtac IS NOT NULL THEN
    SELECT t.TEN into b_qtac FROM bh_ma_qtac t WHERE t.ma=b_ma_qtac;
  END IF;
   exception
    WHEN others THEN
      dbms_output.put_line('Error!' || SQLERRM);
    end;
  PKH_JS_THAYa(dt_ct,'ten_sp,qtac,so_dt,dvi',UPPER(b_ten_sp) ||','||b_qtac ||','|| b_so_dt ||','|| b_chinhanh);
  select count(*) into b_i1 from bh_sk_tt where so_id = b_so_id;
  if b_i1 <> 0 then
     select min(ngay) into b_ngay_tt from bh_sk_tt where so_id = b_so_id;
  end if;
end if;
--ds
select JSON_ARRAYAGG(json_object(ten,'gioi' value CASE WHEN gioi = 'M' THEN 'Nam' ELSE 'N?' END,cmt,ng_sinh returning clob) returning clob ) into dt_ds
       from bh_sk_ds where  so_id=b_so_id;

select count(*) into b_i1 from bh_sk_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_dk';
if b_i1 <> 0 then
select FKH_JS_BONH(t.txt) INTO dt_dk
       FROM bh_sk_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_dk';

  b_lenh:=FKH_JS_LENH('tien,phi,cap');
  EXECUTE IMMEDIATE b_lenh bulk collect into dk_tien,dk_phi,dk_cap using dt_dk;
  for b_lp in 1..dk_tien.count loop
      if dk_cap(b_lp) = 1 then
         b_mtn:=b_mtn+dk_tien(b_lp);
         --b_phi:=b_phi+dk_phi(b_lp);
       end if;
  end loop;
  b_phi:= FKH_JS_GTRIn(dt_ct ,'phi');
end if;
PKH_JS_THAYa(dt_ct,'mtn,phi_ng',b_mtn ||','||b_phi);
PKH_JS_THAYa(dt_ct,'ngay_tt',b_ngay_tt);

-- dt_lt
select count(*) into b_i1 from bh_ng_kbt t WHERE t.so_id = b_so_id;
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.lt) INTO dt_lt FROM bh_ng_kbt t WHERE  t.so_id = b_so_id;
  b_lenh:=FKH_JS_LENH('ma_lt');
  EXECUTE IMMEDIATE b_lenh bulk collect into ma_lt using dt_lt;
  
  delete temp_6;
  for b_lp in 1..ma_lt.count loop
    select FKH_JS_GTRIc(FKH_JS_BONH(txt) ,'nd') into b_nd_lt from bh_ma_dklt where ma = ma_lt(b_lp);
    insert into temp_6(CL1) values(b_nd_lt);
  end loop;
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE CL1 returning clob) returning clob) into dt_lt from temp_6;
 delete temp_6;
-- end dt_lt

select count(*) into b_i1 from bh_sk_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_dkbs';
if b_i1 <> 0 then
select FKH_JS_BONH(t.txt) INTO dt_bs FROM bh_sk_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_dkbs';
end if;

-- thong tin thanh toan
delete temp_4;
delete temp_5;
select count(*) into b_i1 from bh_sk_tt where so_id = b_so_id;
if  b_i1 = 1 then
	select min(ngay) into b_ngay_tt from bh_sk_tt where so_id = b_so_id;
   insert into temp_4(C1) values(N'Thanh toán trước ngày '|| to_char(PKH_SO_CNG_DATE(b_ngay_tt),'DD/MM/YYYY') || N' theo hợp đồng bảo hiểm đã ký kết.'
   );
   insert into temp_5(C1) values(N'Phương thức thanh toán: Bằng tiền mặt hoặc chuyển khoản. Thời hạn thanh toán: Thanh toán trong vòng 30 ngày kể từ ngày bắt đầu hiệu lực bảo hiểm.'
   );
elsif b_i1 > 1 then
	insert into temp_5(C1) values(N'Thời hạn thanh toán: Thanh toán thành ' || b_i1 || N' kỳ, trong đó kỳ 01 được thanh toán trong vòng 30 ngày kể từ ngày bắt đầu hiệu lực bảo hiểm.');
	b_i1:= 1;
	for r_lp in (select ngay,tien from bh_sk_tt where so_id = b_so_id)
	loop
		insert into temp_4(C1) values(N'- Kỳ ' || b_i1 || ': ' || to_char(PKH_SO_CNG_DATE(r_lp.ngay),'DD/MM/YYYY') || ' - ' || trim(TO_CHAR(r_lp.tien, '999,999,999,999,999,999PR'))|| ' ' || FKH_JS_GTRIs(dt_ct,'nt_tien') );
		b_i1:= b_i1 + 1;
	end loop;
end if;

select JSON_ARRAYAGG(json_object('TEN' VALUE C1) returning clob) into dt_tt from temp_4;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1) returning clob) into dt_tt_b from temp_5;
delete temp_4;
delete temp_5;

select json_object('dt_ct' value dt_ct,'dt_ds' value dt_ds,
       'dt_dk' value dt_dk,'dt_ttt' value dt_ttt,'dt_lt' value dt_lt,'dt_bs' value dt_bs,'dt_tt' value dt_tt,
		'dt_tt_b' value dt_tt_b returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;

/
create or replace procedure PBH_SKT_INHD(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    -- chung
    b_loi varchar2(100); b_lenh varchar(1000); b_count number;
    -- bien tam
    b_so_id_dt1 number; dk_qtac clob; b_ma_qtac varchar(20);
    -- truong out
    b_so_hd varchar2(50) :=FKH_JS_GTRIs(b_oraIn,'so_hd');
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id'); b_qtac nvarchar2(500):=' ';
    dt_ct clob; dt_dk clob; dt_ds clob; dt_nh clob; dt_lt clob; dt_bs clob; dt_kytt clob; dt_txt clob;
    a_nh clob;
    dt_tt clob;dt_tt_b clob;b_i1 number;b_ngay_tt number;
    ma_lt pht_type.a_var;b_nd_lt clob;b_dvi clob;
begin

select t.so_id_dt into b_so_id_dt1 from bh_sk_ds t where t.so_id=b_so_id and rownum=1 ;
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
--SAO CHEP DIEU KHOAN BO SUNG
SELECT FKH_JS_BONH(t.txt) into dk_qtac FROM bh_sk_sp t, bh_sk t1 WHERE t.ma = t1.ma_sp and t1.so_id=b_so_id;
if dk_qtac is not null then
  b_ma_qtac:=FKH_JS_GTRIs(dk_qtac,'qtac');
end if;
IF b_ma_qtac IS NOT NULL THEN
  SELECT t.TEN into b_qtac FROM bh_ma_qtac t WHERE t.ma=b_ma_qtac;
END IF;

--dt_ds
select count(*) into b_count from bh_sk_txt where  so_id = b_so_id and loai='dt_ds';
if b_count <> 0 then
  SELECT FKH_JS_BONH(txt) into dt_ds from bh_sk_txt where  so_id = b_so_id and loai='dt_ds';
end if;

--bs
select count(*) into b_count from bh_sk_txt where  so_id = b_so_id and loai='dt_bs';
if b_count <> 0 then
  SELECT FKH_JS_BONH(txt) into dt_bs from bh_sk_txt where  so_id = b_so_id and loai='dt_bs';
end if;
--dt_nh
select count(*) into b_count from bh_sk_txt where  so_id = b_so_id and loai='dt_nh';
if b_count <> 0 then
  SELECT FKH_JS_BONH(txt) into a_nh from bh_sk_txt where  so_id = b_so_id and loai='dt_nh';
end if;

--dk
select count(*) into b_count from bh_sk_txt where  so_id = b_so_id and loai='dt_dk';
if b_count <> 0 then
  SELECT FKH_JS_BONH(txt) into dt_dk from bh_sk_txt where  so_id = b_so_id and loai='dt_dk';
end if;

--dt_ct
select count(*) into b_count from bh_sk_txt where  so_id = b_so_id and loai='dt_ct';
if b_count <> 0 then
  SELECT FKH_JS_BONH(txt) into dt_ct from bh_sk_txt where  so_id = b_so_id and loai='dt_ct';
end if;
 --tt dvi
select json_object('ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
       'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
           from ht_ma_dvi where ma=b_ma_dvi;
dt_ct:=FKH_JS_BONH(dt_ct);
b_dvi:=FKH_JS_BONH(b_dvi);
select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;

PKH_JS_THAYa(dt_ct,'qtac',b_qtac);


-- dt_lt
select count(*) into b_i1 from bh_ng_kbt t WHERE t.so_id = b_so_id;
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.lt) INTO dt_lt FROM bh_ng_kbt t WHERE  t.so_id = b_so_id and rownum = 1;
  b_lenh:=FKH_JS_LENH('ma_lt');
  EXECUTE IMMEDIATE b_lenh bulk collect into ma_lt using dt_lt;

  delete temp_6;
  for b_lp in 1..ma_lt.count loop
    select FKH_JS_GTRIc(FKH_JS_BONH(txt) ,'nd') into b_nd_lt from bh_ma_dklt where ma = ma_lt(b_lp);
    insert into temp_6(CL1) values(b_nd_lt);
  end loop;
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE CL1 returning clob) returning clob) into dt_lt from temp_6;
 delete temp_6;
-- end dt_lt
-- thong tin thanh toan
delete temp_4;
delete temp_5;
select count(*) into b_i1 from bh_sk_tt where so_id = b_so_id;
if  b_i1 = 1 then
	select min(ngay) into b_ngay_tt from bh_sk_tt where so_id = b_so_id;
   insert into temp_4(C1) values(N'Thanh toán trước ngày '|| to_char(PKH_SO_CNG_DATE(b_ngay_tt),'DD/MM/YYYY') || N' theo hợp đồng bảo hiểm đã ký kết.'
   );
   insert into temp_5(C1) values(N'Phương thức thanh toán: Bằng tiền mặt hoặc chuyển khoản. Thời hạn thanh toán: Thanh toán trong vòng 30 ngày kể từ ngày bắt đầu hiệu lực bảo hiểm.'
   );
elsif b_i1 > 1 then
	insert into temp_5(C1) values(N'Thời hạn thanh toán: Thanh toán thành ' || b_i1 || N' kỳ, trong đó kỳ 01 được thanh toán trong vòng 30 ngày kể từ ngày bắt đầu hiệu lực bảo hiểm.');
	b_i1:= 1;
	for r_lp in (select ngay,tien from bh_sk_tt where so_id = b_so_id)
	loop
		insert into temp_4(C1) values(N'- Kỳ ' || b_i1 || ': ' || to_char(PKH_SO_CNG_DATE(r_lp.ngay),'DD/MM/YYYY') || ' - ' || trim(TO_CHAR(r_lp.tien, '999,999,999,999,999,999PR'))|| ' ' || FKH_JS_GTRIs(dt_ct,'nt_tien') );
		b_i1:= b_i1 + 1;
	end loop;
end if;

select JSON_ARRAYAGG(json_object('TEN' VALUE C1) returning clob) into dt_tt from temp_4;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1) returning clob) into dt_tt_b from temp_5;
delete temp_4;
delete temp_5;


select JSON_ARRAYAGG(json_object('nhom' value t.nhom, 'ten' value t.ten, 'goi' value t.goi, 'tpa' value t.tpa, 'phi' value t.phi,
 'so_dt' value t.so_dt, 'phin' value t.phin, 'tl_giam' value t.tl_giam, 'giam' value t.giam, 'ttoan' value t.ttoan,
  'phing' value t.phin/t.so_dt) order by bt returning clob)
  into dt_nh from bh_sk_nh t  where t.so_id=b_so_id;

select JSON_ARRAYAGG(json_object(ngay,tien) order by ngay) into dt_kytt from bh_sk_tt where  so_id=b_so_id;

select json_object('dt_ct' value dt_ct,'dt_dk' value dt_dk,'dt_ds' value dt_ds, 'dt_nh' value dt_nh,
                    'dt_lt' VALUE dt_lt,'dt_bs' value dt_bs,'dt_kytt' value dt_kytt,'a_nh'value a_nh,'dt_tt' value dt_tt returning clob) into b_oraOut from dual;

exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi);  end if; rollback;
end;
/
drop procedure PBH_IN_HC_TC;
/
--duchq update length email
create or replace  procedure PBH_IN_HC_TC(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number;b_lenh varchar2(1000);
    b_so_hd varchar2(50) :=FKH_JS_GTRIs(b_oraIn,'so_hd');
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
    dt_ct clob; dt_nh clob; dt_ds clob;dt_dk clob;dt_lt clob;dt_bs clob;dt_tttk clob;dk_qtac clob;
    b_ma_kh varchar2(20);b_nghed varchar2(20);b_nghed_ten nvarchar2(500):= ' ';
    b_ma_sp varchar2(20);b_ten_sp nvarchar2(500):= ' ';
    b_ten_dvi nvarchar2(500):= ' ';
    b_quy_tac nvarchar2(500):= ' ';b_ma_qtac varchar2(20);
    b_count number:=0;
    dt_tt clob;dt_tt_b clob;b_ngay_tt number;
    b_dvi clob;
    b_tpa nvarchar2(500);
    b_tpa_ma varchar2(20);b_tpa_ten nvarchar2(500):= ' ';b_tpa_dchi nvarchar2(500):= ' ';b_tpa_mobi varchar2(20):=' ';b_tpa_email varchar2(100):=' ';
begin


b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
-- quy tac
begin
  SELECT FKH_JS_BONH(t.txt) into dk_qtac FROM bh_sk_sp t, bh_sk t1 WHERE t.ma = t1.ma_sp and t1.so_id=b_so_id;
    b_lenh := FKH_JS_LENH('qtac');
    EXECUTE IMMEDIATE b_lenh INTO b_ma_qtac USING dk_qtac;

  IF b_ma_qtac IS NOT NULL THEN
    SELECT t.TEN into b_quy_tac FROM bh_ma_qtac t WHERE t.ma=b_ma_qtac;
  END IF;
exception
WHEN others THEN
  dbms_output.put_line('Error!' || SQLERRM);
end;
--bs
select count(*) into b_i1 from bh_sk_txt where  so_id = b_so_id and loai='dt_bs';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(txt) into dt_bs from bh_sk_txt where  so_id = b_so_id and loai='dt_bs';
end if;

-- lay dt_ct
select count(*) into b_i1 from bh_sk_txt where  so_id = b_so_id and loai='dt_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(txt) into dt_ct from bh_sk_txt where  so_id = b_so_id and loai='dt_ct';
  b_ma_kh := FKH_JS_GTRIs(dt_ct,'ma_kh');
  select nghe into b_nghed from bh_dtac_ma where ma = b_ma_kh;
  if trim(b_nghed) is not null then
    select count(*) into b_count  from bh_ma_nghe where ma=b_nghed;
    if b_count <> 0 then
      select NVL(ten,' ') into b_nghed_ten  from bh_ma_nghe where ma=b_nghed;
    end if;
  end if;
  PKH_JS_THAYa(dt_ct,'nghed_ten',b_nghed_ten);

  select count(*) into b_count from bh_ng_ds where so_id=b_so_id;
  PKH_JS_THAYa(dt_ct,'so_nguoi',b_count);
--thong tin tpa
  b_tpa:=FKH_JS_GTRIs(dt_ct,'tpa');
  if trim(b_tpa) is not null then
    b_tpa:= FBH_IN_SUBSTR(b_tpa,'|','T');
    select count(*) into b_count  from bh_ma_gdinh where ma=b_tpa;
    if b_count <> 0 then
      select NVL(ten,' '),NVL(dchi,' '),NVL(mobi,' '),NVL(email,' ') into b_tpa_ten,b_tpa_dchi,b_tpa_mobi,b_tpa_email from bh_ma_gdinh where ma=b_tpa;
    end if;
  end if;
  PKH_JS_THAYa(dt_ct,'dv_ten,dv_dchi,dv_email,dv_mobi',b_tpa_ten||','||b_tpa_dchi||','||b_tpa_mobi||','||b_tpa_email);

  --ten sp
  b_ma_sp := FKH_JS_GTRIs(dt_ct,'ma_sp');
  if trim(b_ma_sp) is not null then
    select count(*) into b_count  from bh_sk_sp where ma=b_ma_sp;
    if b_count <> 0 then
      select NVL(ten,' ') into b_ten_sp  from bh_sk_sp where ma=b_ma_sp;
    end if;
  end if;
  PKH_JS_THAYa(dt_ct,'ten_sp',b_ten_sp);
  -- lay ten dvi
  --tt dvi
    select json_object('ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
           'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
               from ht_ma_dvi where ma=b_ma_dvi;
    dt_ct:=FKH_JS_BONH(dt_ct);
    b_dvi:=FKH_JS_BONH(b_dvi);
    select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;

  PKH_JS_THAYa(dt_ct,'qtac',b_quy_tac);
end if;
-- lay dt_nh
select count(*) into b_i1 from bh_sk_txt where  so_id = b_so_id and loai='dt_nh';
if b_i1 <> 0 then
SELECT FKH_JS_BONH(txt) into dt_nh from bh_sk_txt where  so_id = b_so_id and loai='dt_nh';
end if;

select count(*) into b_i1 from bh_sk_txt where  so_id = b_so_id and loai='dt_ds';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(txt) into dt_ds from bh_sk_txt where  so_id = b_so_id and loai='dt_ds';
end if;
-- thon tin thong ke
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into dt_tttk
    from bh_kh_ttt where ps='HD' and nv='NG' order by bt asc;
-- thong tin thanh toan
delete temp_4;
select count(*) into b_i1 from bh_sk_tt where so_id = b_so_id;
if  b_i1 = 1 then
	select min(ngay) into b_ngay_tt from bh_sk_tt where so_id = b_so_id;
   insert into temp_4(C1) values(N'Thanh toán trước ngày '|| to_char(PKH_SO_CNG_DATE(b_ngay_tt),'DD/MM/YYYY') || N' theo hợp đồng bảo hiểm đã ký kết.'
   );
elsif b_i1 > 1 then
	b_i1:= 1;
	for r_lp in (select ngay,tien from bh_sk_tt where so_id = b_so_id)
	loop
		insert into temp_4(C1) values(N'- Kỳ ' || b_i1 || ': ' || to_char(PKH_SO_CNG_DATE(r_lp.ngay),'DD/MM/YYYY') || ' - ' || trim(TO_CHAR(r_lp.tien, '999,999,999,999,999,999PR'))|| ' ' || FKH_JS_GTRIs(dt_ct,'nt_tien') );
		b_i1:= b_i1 + 1;
	end loop;
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1) returning clob) into dt_tt from temp_4;
delete temp_4;


select json_object('dt_ct' value dt_ct,'dt_nh' value dt_nh, 'dt_ds' value dt_ds,'dt_dk' value dt_dk,
  'dt_lt' value dt_lt,'dt_bs' value dt_bs,'dt_tttk' value dt_tttk,'dt_tt' value dt_tt returning clob) into b_oraOut from dual;

exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
