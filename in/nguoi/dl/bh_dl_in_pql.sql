drop procedure PBH_NGDLT_IN_B;
/
create or replace procedure PBH_NGDLT_IN_B(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000);
    b_loi varchar2(100); b_i1 number;
    b_so_hd varchar2(50) :=FKH_JS_GTRIs(b_oraIn,'so_hd');
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_lan number:= TO_NUMBER(FKH_JS_GTRIs(b_oraIn,'lan_in'));
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
    dt_ct clob; dt_nh clob; dt_ds clob;dt_dk clob;dt_lt clob;dt_bs clob;
    dt_tt clob;dt_tt_b clob;dt_kytt clob;

    b_qtac nvarchar2(500):=' ';b_ma_qtac varchar2(20);
    b_ma_sp varchar2(20);
    dk_qtac clob;b_dvi clob;
    b_ngay_tt number:= 20250101;a_ngay_tt pht_type.a_num;
    ma_lt pht_type.a_var;b_nd_lt clob;
    --bien mang
    dt_nh_dk pht_type.a_clob;dt_nh_dkbs pht_type.a_clob;dt_nh_lt pht_type.a_clob;dt_nh_ct pht_type.a_clob;
begin

b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);


--dk
select count(*) into b_i1 from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id = b_so_id and loai='dt_dk' and lan = b_lan;
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(txt) into dt_dk from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id = b_so_id and loai='dt_dk' and lan = b_lan;
end if;
--ct
select count(*) into b_i1 from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id = b_so_id and loai='dt_ct' and lan = b_lan;
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(txt) into dt_ct from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id = b_so_id and loai='dt_ct' and lan = b_lan;
end if;
--dt_nh
select count(*) into b_i1 from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id = b_so_id and loai='dt_nh' and lan = b_lan;
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(txt) into dt_nh from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id = b_so_id and loai='dt_nh' and lan = b_lan;

   b_lenh:=FKH_JS_LENHc('dt_nh_ct');
  EXECUTE IMMEDIATE b_lenh bulk collect into dt_nh_ct using dt_nh;

  b_lenh:=FKH_JS_LENHc('dt_nh_dk');
  EXECUTE IMMEDIATE b_lenh bulk collect into dt_nh_dk using dt_nh;

  b_lenh:=FKH_JS_LENHc('dt_nh_dkbs');
  EXECUTE IMMEDIATE b_lenh bulk collect into dt_nh_dkbs using dt_nh;

  b_lenh:=FKH_JS_LENHc('dt_nh_lt');
  EXECUTE IMMEDIATE b_lenh bulk collect into dt_nh_lt using dt_nh;

  -- dt_lt
  if dt_nh_lt.count <> 0 then
    delete temp_6;
    for ds_lp in 1..dt_nh_lt.count loop
      b_lenh:=FKH_JS_LENH('ma_lt');
      EXECUTE IMMEDIATE b_lenh bulk collect into ma_lt using dt_nh_lt(ds_lp);
      for b_lp in 1..ma_lt.count loop
        select count(*) into b_i1 from temp_6 where C1 = ma_lt(b_lp);
        if b_i1 = 0 then
          select FKH_JS_GTRIc(FKH_JS_BONH(txt) ,'nd') into b_nd_lt from bh_ma_dklt where ma = ma_lt(b_lp);
          insert into temp_6(C1,CL1) values(ma_lt(b_lp),b_nd_lt);
        end if;
      end loop;
    end loop;
    select JSON_ARRAYAGG(json_object('TEN' VALUE CL1 returning clob) returning clob) into dt_lt from temp_6;
    delete temp_6;
  end if;
end if;
--dt_ds
select count(*) into b_i1 from bh_ngB_txt where so_id=b_so_id  and loai='dt_ds' and lan = b_lan;
if b_i1<>0 then
  SELECT FKH_JS_BONH(txt) into dt_ds from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id = b_so_id and loai='dt_ds' and lan = b_lan;
end if;


select count(*) into b_i1 from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dkbs' and lan = b_lan;
if b_i1<>0 then
    select FKH_JS_BONH(txt) into dt_bs from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dkbs' and lan = b_lan;
end if;

-- lay qtac
b_ma_sp:=FKH_JS_GTRIs(dt_ct,'ma_sp');
if trim(b_ma_sp) is not null then
  SELECT FKH_JS_BONH(t.txt) into dk_qtac FROM bh_ngdl_sp t, bh_ngdl t1 WHERE t.ma = b_ma_sp and t1.ma_dvi=b_ma_dvi and t1.so_id=b_so_id;
  if dk_qtac <> null or dk_qtac!= '' then
    b_lenh := FKH_JS_LENH('qtac');
    EXECUTE IMMEDIATE b_lenh INTO b_ma_qtac USING dk_qtac;
  end if;
  IF b_ma_qtac IS NOT NULL THEN
    SELECT t.TEN into b_qtac FROM bh_ma_qtac t WHERE t.ma=b_ma_qtac;
  END IF;
end if;
PKH_JS_THAYa(dt_ct,'qtac',b_qtac);
PKH_JS_THAYa(dt_ct,'ngay_tt',b_ngay_tt);

--tt dvi
select json_object('ten_dvi' value NVL(UPPER(ten),' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
         'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
             from ht_ma_dvi where ma=b_ma_dvi;
  dt_ct:=FKH_JS_BONH(dt_ct);
  b_dvi:=FKH_JS_BONH(b_dvi);
  select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;

  --kytt
select count(*) into b_i1 from bh_ngB_txt where so_id=b_so_id and loai='dt_kytt' and lan = b_lan;
if b_i1<>0 then
    select FKH_JS_BONH(txt) into dt_kytt from bh_ngB_txt where so_id=b_so_id and loai='dt_kytt' and lan = b_lan;
    b_lenh:=FKH_JS_LENH('ngay');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_ngay_tt using dt_kytt;
end if;
-- thong tin thanh toan
delete temp_5;
b_i1 := a_ngay_tt.count;
if  b_i1 = 1 then
   insert into temp_5(C1) values(N'Phương thức thanh toán: Bằng tiền mặt hoặc chuyển khoản. Thời hạn thanh toán: Thanh toán trong vòng 30 ngày kể từ ngày bắt đầu hiệu lực bảo hiểm.'
   );
elsif b_i1 > 1 then
	insert into temp_5(C1) values(N'Thời hạn thanh toán: Thanh toán thành ' || b_i1 || N' kỳ, trong đó kỳ 01 được thanh toán trong vòng 30 ngày kể từ ngày bắt đầu hiệu lực bảo hiểm.');
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_tt_b from temp_5;
delete temp_5;
--


select json_object('dt_ct' value dt_ct,
'dt_nh' value dt_nh, 'dt_ds' value dt_ds,'dt_dk' value dt_dk,'dt_lt' value dt_lt,'dt_bs' value dt_bs,'dt_tt' value dt_tt_b returning clob) into b_oraOut from dual;

exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;

/
drop procedure PBH_NGDLT_INHD;
/
create or replace  procedure PBH_NGDLT_INHD(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000);
    b_loi varchar2(100); b_i1 number;
    b_so_hd varchar2(50) :=FKH_JS_GTRIs(b_oraIn,'so_hd');
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
    dt_ct clob; dt_nh clob; dt_ds clob;dt_dk clob;dt_lt clob;dt_bs clob;
    
    b_qtac nvarchar2(500):=' ';b_ma_qtac varchar2(20);
    b_ma_sp varchar2(20);
    dk_qtac clob;b_dvi clob;
    b_ngay_tt number:= 0;
    dt_tt clob;dt_tt_b clob;
     --
    ma_lt pht_type.a_var;b_nd_lt clob;
begin

b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);



select count(*) into b_i1 from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id = b_so_id and loai='dt_dk';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(txt) into dt_dk from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id = b_so_id and loai='dt_dk';
end if;
select count(*) into b_i1 from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id = b_so_id and loai='dt_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(txt) into dt_ct from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id = b_so_id and loai='dt_ct';
end if;
select count(*) into b_i1 from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id = b_so_id and loai='dt_nh';
if b_i1 <> 0 then
SELECT FKH_JS_BONH(txt) into dt_nh from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id = b_so_id and loai='dt_nh';
end if;
select count(*) into b_i1 from bh_ngdl_ds where so_id=b_so_id;
if b_i1<>0 then
    select JSON_ARRAYAGG(json_object(ten,'tuoi' value FBH_INHD_TINH_TUOI(ng_sinh),ng_sinh,gioi,cmt,ttoan,'mobi' value nvl(mobi,' ')) returning clob) into dt_ds from bh_ngdl_ds where so_id=b_so_id;
end if;
select count(*) into b_i1 from bh_ng_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then
    select FKH_JS_BONH(lt) into dt_lt from bh_ng_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and rownum = 1;
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

select count(*) into b_i1 from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dkbs';
if b_i1<>0 then
    select FKH_JS_BONH(txt) into dt_bs from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dkbs' and rownum = 1;
end if;

-- lay qtac
b_ma_sp:=FKH_JS_GTRIs(dt_ct,'ma_sp');
if trim(b_ma_sp) is not null then
  SELECT FKH_JS_BONH(t.txt) into dk_qtac FROM bh_ngdl_sp t, bh_ngdl t1 WHERE t.ma = b_ma_sp and t1.ma_dvi=b_ma_dvi and t1.so_id=b_so_id;
  if dk_qtac <> null or dk_qtac!= '' then
    b_lenh := FKH_JS_LENH('qtac');
    EXECUTE IMMEDIATE b_lenh INTO b_ma_qtac USING dk_qtac;
  end if;
  IF b_ma_qtac IS NOT NULL THEN
    SELECT t.TEN into b_qtac FROM bh_ma_qtac t WHERE t.ma=b_ma_qtac;
  END IF;
end if;
PKH_JS_THAYa(dt_ct,'qtac',b_qtac);

--tt dvi
select json_object('ten_dvi' value NVL(UPPER(ten),' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
         'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
             from ht_ma_dvi where ma=b_ma_dvi;
  dt_ct:=FKH_JS_BONH(dt_ct);
  b_dvi:=FKH_JS_BONH(b_dvi);
  select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;
--ngay tt
select count(*) into b_i1 from bh_ngdl_tt where so_id = b_so_id;
if b_i1 <> 0 then
   select min(ngay) into b_ngay_tt from bh_ngdl_tt where so_id = b_so_id;
end if;
PKH_JS_THAYa(dt_ct,'ngay_tt',b_ngay_tt);

-- thong tin thanh toan
delete temp_4;
delete temp_5;
select count(*) into b_i1 from bh_ngdl_tt where so_id = b_so_id;
if  b_i1 = 1 then
  select min(ngay) into b_ngay_tt from bh_ngdl_tt where so_id = b_so_id;
   insert into temp_4(C1) values(N'Thanh toán trước ngày '|| to_char(PKH_SO_CNG_DATE(b_ngay_tt),'DD/MM/YYYY') || N' theo hợp đồng bảo hiểm đã ký kết.'
   );
   insert into temp_5(C1) values(N'Phương thức thanh toán: Bằng tiền mặt hoặc chuyển khoản. Thời hạn thanh toán: Thanh toán trong vòng 30 ngày kể từ ngày bắt đầu hiệu lực bảo hiểm.'
   );
elsif b_i1 > 1 then
  insert into temp_5(C1) values(N'Thời hạn thanh toán: Thanh toán thành ' || b_i1 || N' kỳ, trong đó kỳ 01 được thanh toán trong vòng 30 ngày kể từ ngày bắt đầu hiệu lực bảo hiểm.');
  b_i1:= 1;
  for r_lp in (select ngay,tien from bh_ngdl_tt where so_id = b_so_id)
  loop
    insert into temp_4(C1) values(N'- Kỳ ' || b_i1 || ': ' || to_char(PKH_SO_CNG_DATE(r_lp.ngay),'DD/MM/YYYY') || ' - ' || trim(TO_CHAR(r_lp.tien, '999,999,999,999,999,999PR'))|| ' ' || FKH_JS_GTRIs(dt_ct,'nt_tien') );
    b_i1:= b_i1 + 1;
  end loop;
end if;

select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_tt from temp_4;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_tt_b from temp_5;
delete temp_4;
delete temp_5;

select json_object('dt_ct' value dt_ct,'dt_nh' value dt_nh, 'dt_ds' value dt_ds,'dt_dk' value dt_dk,
'dt_lt' value dt_lt,'dt_bs' value dt_bs,'dt_tt' value dt_tt,'dt_tt_b' value dt_tt_b returning clob) into b_oraOut from dual;

exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;

/
drop procedure PBH_NGDLCN_INHD;
/
---V2
create or replace  procedure PBH_NGDLCN_INHD(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);b_i1 number;b_i2 number;
    b_so_hd varchar2(50) :=FKH_JS_GTRIs(b_oraIn,'so_hd');
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
    b_j_kbt clob; b_j_lt clob;
    b_so_id_dt1 number;
    dk_ma pht_type.a_var; dk_kbt pht_type.a_var;
    dk_lt_ma pht_type.a_var; dk_lt_ten pht_type.a_var;

    dt_ct clob; dt_dk clob; dt_ds clob; dt_lsb clob; dt_bkh clob; dt_lt clob; dt_bs clob; dt_txt clob;
    dt_tt clob;dt_tt_b clob;b_ngay_tt number;
    
    temp_bt NUMBER; temp_ma pht_type.a_var; temp_nd pht_type.a_var;
    b_count  NUMBER; b_tong_muc_tn NUMBER :=0;
    b_dk_ma varchar2(20);b_dk_nd varchar2(200);
    b_dvi clob;ma_lt pht_type.a_var;b_nd_lt clob;
    b_temp_var varchar2(100);b_temp_nvar varchar2(500);
    b_nt_tien varchar2(10);
    --a dt_dk
    a_dk_ma pht_type.a_var;a_dk_ten pht_type.a_nvar; a_dk_tien pht_type.a_num;
    a_dk_phi pht_type.a_num;a_dk_thue pht_type.a_num;
    a_dk_cap pht_type.a_num;a_dk_tc pht_type.a_var;a_dk_ma_ct pht_type.a_var;
    a_dk_mota pht_type.a_nvar;
begin

b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);

-- dong dau tien
SELECT NVL(TIEN,0) INTO b_tong_muc_tn FROM bh_ngdl_dk where ma_dvi=b_ma_dvi and so_id = b_so_id  AND cap = 1 and rownum = 1;

--dt_ct
select count(*) into b_i1 from bh_ngdl_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_ct';
if b_i1 <> 0 then
  select FKH_JS_BONH(t.txt) into dt_ct from bh_ngdl_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_ct';
  
  
  select json_object('ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
           'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
               from ht_ma_dvi where ma=b_ma_dvi;
    dt_ct:=FKH_JS_BONH(dt_ct);
    b_dvi:=FKH_JS_BONH(b_dvi);
    select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;

    b_nt_tien:=FKH_JS_GTRIs(dt_ct ,'nt_tien');

    PKH_JS_THAY(dt_ct,'tong_muc_tn',FBH_CSO_TIEN(b_tong_muc_tn,b_nt_tien));

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_cap');
    if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_cap',' '); 
    else PKH_JS_THAYa(dt_ct,'ngay_cap',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    PKH_JS_THAYa(dt_ct,'ngay_cap_s',N'Ngày ' || FBH_IN_CSO_NG(b_i1,'DD') || N' tháng ' || FBH_IN_CSO_NG(b_i1,'MM')
    || N' năm ' || FBH_IN_CSO_NG(b_i1,'YYYY'));

    b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gioid');
    PKH_JS_THAYa(dt_ct,'gioid',case when b_temp_var = 'M' then N'Nam' else N'Nữ' end);

    b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_hl');
    PKH_JS_THAYa(dt_ct,'gio_hl',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,' ') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,' ') || N' phút');
    b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_kt');
    PKH_JS_THAYa(dt_ct,'gio_kt',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,' ') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,' ') || N' phút');

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_hl');
    if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_hl',' '); 
    else PKH_JS_THAYa(dt_ct,'ngay_hl',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_kt');
    if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_kt',' '); 
    else PKH_JS_THAYa(dt_ct,'ngay_kt',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    b_i1:= FKH_JS_GTRIn(dt_ct ,'phi');
    PKH_JS_THAY(dt_ct,'phi',FBH_CSO_TIEN(b_i1,b_nt_tien) );
    

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ttoan');
    PKH_JS_THAYa(dt_ct,'bangchu',FBH_IN_CSO_CHU(b_i1,b_nt_tien) );
    PKH_JS_THAY(dt_ct,'ttoan',FBH_CSO_TIEN(b_i1,b_nt_tien) );

    --ten kvuc
    b_temp_nvar:=' ';
    select kvuc into b_temp_var from ht_ma_dvi where ma = b_ma_dvi;
    select count(*) into b_i1 from  bh_ma_kvuc where ma = b_temp_var;
    if b_i1 <> 0 then
      select ten into b_temp_nvar from bh_ma_kvuc where ma = b_temp_var;
    end if;
    PKH_JS_THAYa(dt_ct,'ten_kvuc',b_temp_nvar);

    b_temp_var:= FKH_JS_GTRIs(dt_ct ,'gioi');
    if b_temp_var= 'M' and trim(b_temp_var) is not null then PKH_JS_THAY(dt_ct,'gioi', 'Nam');
    else PKH_JS_THAY(dt_ct,'gioi', N'Nữ');end if;

     b_temp_var:= FKH_JS_GTRIs(dt_ct ,'gioid');
    if b_temp_var= 'M' and trim(b_temp_var) is not null then PKH_JS_THAY(dt_ct,'gioid', 'Nam');
    else PKH_JS_THAY(dt_ct,'gioid', N'Nữ');end if;

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ng_sinh');
    if b_i1 = 30000101 or b_i1 = 0 then PKH_JS_THAYa(dt_ct,'ng_sinh',' '); 
    else 
      PKH_JS_THAYa(dt_ct,'ng_sinh',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );
      b_i2:= FBH_INHD_TINH_TUOI(b_i1);
      PKH_JS_THAY(dt_ct,'tuoi', b_i2);
    end if;

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ng_sinhd');
    if b_i1 = 30000101 or b_i1 = 0 then PKH_JS_THAYa(dt_ct,'ng_sinhd',' '); 
    else 
      PKH_JS_THAYa(dt_ct,'ng_sinhd',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );
      b_i2:= FBH_INHD_TINH_TUOI(b_i1);
      PKH_JS_THAY(dt_ct,'tuoid', b_i2);
    end if;

   if trim(FKH_JS_GTRIs(dt_ct ,'tend')) is null then
      PKH_JS_THAY(dt_ct,'tend',FKH_JS_GTRIs(dt_ct ,'ten'));
      PKH_JS_THAY(dt_ct,'mobid',FKH_JS_GTRIs(dt_ct ,'mobi'));
      PKH_JS_THAY(dt_ct,'cmtd',FKH_JS_GTRIs(dt_ct ,'cmt'));
      PKH_JS_THAY(dt_ct,'ng_sinhd',FKH_JS_GTRIs(dt_ct ,'ng_sinh'));
      PKH_JS_THAY(dt_ct,'gioid',FKH_JS_GTRIs(dt_ct ,'gioi'));
      PKH_JS_THAY(dt_ct,'emaild',FKH_JS_GTRIs(dt_ct ,'email'));
      PKH_JS_THAY(dt_ct,'tuoid',FKH_JS_GTRIs(dt_ct ,'tuoi'));
    end if;

    b_temp_var:= FKH_JS_GTRIs(dt_ct ,'goi');
    if trim(b_temp_var) is not null then
      select count(*) into b_i1 from bh_sk_goi where ma  = b_temp_var;
      if b_i1 <> 0 then select ten into b_temp_nvar from bh_sk_goi where ma  = b_temp_var;end if;
      PKH_JS_THAY(dt_ct,'goi',b_temp_nvar);
    end if;

end if;
-- lay dk
select count(*) into b_i1 from bh_ngdl_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_dk';
if b_i1 <> 0 then
  select FKH_JS_BONH(t.txt) into dt_dk from bh_ngdl_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_dk';
  b_lenh := FKH_JS_LENH('ma,ten,tien,tc,cap,ma_ct,mota');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_dk_ma,a_dk_ten,a_dk_tien,a_dk_tc,a_dk_cap,a_dk_ma_ct,a_dk_mota USING dt_dk;
  delete temp_1;commit;
  for b_lp in 1..a_dk_ma.count loop
    b_temp_var := ' ';
    if a_dk_tien(b_lp) <> 0 then 
      b_temp_var:= FBH_CSO_TIEN(a_dk_tien(b_lp),'');
    else
      b_temp_var:=a_dk_mota(b_lp);
    end if;
    insert into temp_1(c1,c2,c3,c4,c5,c6,c7) 
    values(a_dk_ma(b_lp), a_dk_ten(b_lp),b_temp_var,a_dk_tc(b_lp),a_dk_cap(b_lp),a_dk_ma_ct(b_lp),a_dk_mota(b_lp));
  end loop;
  select JSON_ARRAYAGG(json_object('ma' VALUE c1,'ten' value c2,'tien' value c3,'tc' value c4,'cap' value c5,'ma_ct' value c6,
  'mota' value c7 returning clob) returning clob) into dt_dk from temp_1;
  delete temp_1;commit;
end if;
-- lay ds
select count(*) into b_i1 from bh_ngdl_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_ds';
if b_i1 <> 0 then
  select FKH_JS_BONH(t.txt) into dt_ds from bh_ngdl_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_ds';
end if;
-- dk_lt
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
-- dt_dkbs
select count(*) into b_i1 from bh_ngdl_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_dkbs';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_bs FROM bh_ngdl_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_dkbs';
  b_lenh := FKH_JS_LENH('ma,ten,tien,mota');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_dk_ma,a_dk_ten,a_dk_tien,a_dk_mota USING dt_bs;
  delete temp_1;commit;
  for b_lp in 1..a_dk_ma.count loop
    b_temp_var := ' ';
    if a_dk_tien(b_lp) <> 0 then 
      b_temp_var:= FBH_CSO_TIEN(a_dk_tien(b_lp),'');
    else
      b_temp_var:=a_dk_mota(b_lp);
    end if;
    insert into temp_1(c1,c2,c3,c7) 
    values(a_dk_ma(b_lp), a_dk_ten(b_lp),b_temp_var,a_dk_mota(b_lp));
  end loop;
  select JSON_ARRAYAGG(json_object('ma' VALUE c1,'ten' value c2,'tien' value c3,'mota' value c7 returning clob) returning clob) 
  into dt_bs from temp_1;
  delete temp_1;commit;
end if;

-- thong tin thanh toan
delete temp_4;
delete temp_5;
select count(*) into b_i1 from bh_ngdl_tt where so_id = b_so_id;
if  b_i1 = 1 then
  select min(ngay) into b_ngay_tt from bh_ngdl_tt where so_id = b_so_id;
   insert into temp_4(C1) values(N'Thanh toán trước ngày '|| to_char(PKH_SO_CNG_DATE(b_ngay_tt),'DD/MM/YYYY') || N' theo hợp đồng bảo hiểm đã ký kết.'
   );
   insert into temp_5(C1) values(N'Phương thức thanh toán: Bằng tiền mặt hoặc chuyển khoản. Thời hạn thanh toán: Thanh toán trong vòng 30 ngày kể từ ngày bắt đầu hiệu lực bảo hiểm.'
   );
elsif b_i1 > 1 then
  insert into temp_5(C1) values(N'Thời hạn thanh toán: Thanh toán thành ' || b_i1 || N' kỳ, trong đó kỳ 01 được thanh toán trong vòng 30 ngày kể từ ngày bắt đầu hiệu lực bảo hiểm.');
  b_i1:= 1;
  for r_lp in (select ngay,tien from bh_ngdl_tt where so_id = b_so_id)
  loop
    insert into temp_4(C1) values(N'- Kỳ ' || b_i1 || ': ' || to_char(PKH_SO_CNG_DATE(r_lp.ngay),'DD/MM/YYYY') || ' - ' || trim(TO_CHAR(r_lp.tien, '999,999,999,999,999,999PR'))|| ' ' || FKH_JS_GTRIs(dt_ct,'nt_tien') );
    b_i1:= b_i1 + 1;
  end loop;
end if;

select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_tt from temp_4;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_tt_b from temp_5;
delete temp_4;
delete temp_5;
commit;
select json_object('dt_ct' value dt_ct,'dt_dk' value dt_dk, 'dt_ds' value dt_ds, 'dt_lsb' value dt_lsb,'dt_lt' value dt_lt,
'dt_bs' value dt_bs,'dt_bkh' value dt_bkh,'dt_tt' value dt_tt,'dt_tt_b' value dt_tt_b returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
/


create or replace  procedure PBH_NGDL_IN_GDTC(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
b_loi varchar2(100); b_lenh varchar2(1000);b_i1 number;b_i2 number;
    b_so_hd varchar2(50) :=FKH_JS_GTRIs(b_oraIn,'so_hd');
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
    b_j_kbt clob; b_j_lt clob;
    b_so_id_dt1 number;
    dk_ma pht_type.a_var; dk_kbt pht_type.a_var;
    dk_lt_ma pht_type.a_var; dk_lt_ten pht_type.a_var;

    dt_ct clob; dt_dk clob; dt_ds clob; dt_lt clob; dt_bs clob;
    dt_tt clob;b_ngay_tt number;dt_nh clob;
    dt_nh_ct pht_type.a_clob;dt_nh_dk pht_type.a_clob;dt_nh_dkbs pht_type.a_clob;dt_nh_lt pht_type.a_clob;
    dt_nh_khd pht_type.a_clob;dt_nh_kbt pht_type.a_clob;dt_nh_ttt pht_type.a_clob;


    b_dvi clob;ma_lt pht_type.a_var;b_nd_lt clob;
    b_temp_var varchar2(100);b_temp_nvar varchar2(500);
    b_nt_tien varchar2(10);
    --mang
    a_ten  pht_type.a_nvar;a_ng_sinh  pht_type.a_num;a_gioi pht_type.a_var;
    a_cmt pht_type.a_var;a_mobi pht_type.a_var;a_email pht_type.a_var;a_nhom pht_type.a_var;
    -- 
    a_ct_nhom pht_type.a_var;a_ct_phi pht_type.a_num;
    --a_dk
    --a dt_dk
    a_dk_ma pht_type.a_var;a_dk_ten pht_type.a_nvar; a_dk_tien pht_type.a_num;a_dk_phi pht_type.a_num;
    a_dk_cap pht_type.a_num;a_dk_kieu pht_type.a_var;a_dk_lkeb pht_type.a_var;
    a_dk_mota pht_type.a_nvar;
    --tinh phi tung nguoi trong dl gia dinh
    b_phi_gd number:=0;
begin
--dt_ct
select count(*) into b_i1 from bh_ngdl_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_ct';
if b_i1 <> 0 then
  select FKH_JS_BONH(t.txt) into dt_ct from bh_ngdl_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_ct';
  
  
  select json_object('ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
           'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
               from ht_ma_dvi where ma=b_ma_dvi;
    dt_ct:=FKH_JS_BONH(dt_ct);
    b_dvi:=FKH_JS_BONH(b_dvi);
    select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;

    b_nt_tien:=FKH_JS_GTRIs(dt_ct ,'nt_tien');

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_cap');
    if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_cap',' '); 
    else PKH_JS_THAYa(dt_ct,'ngay_cap',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    PKH_JS_THAYa(dt_ct,'ngay_cap_s',N'Ngày ' || FBH_IN_CSO_NG(b_i1,'DD') || N' tháng ' || FBH_IN_CSO_NG(b_i1,'MM')
    || N' năm ' || FBH_IN_CSO_NG(b_i1,'YYYY'));

    b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gioid');
    PKH_JS_THAYa(dt_ct,'gioid',case when b_temp_var = 'M' then N'Nam' else N'Nữ' end);

    b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_hl');
    PKH_JS_THAYa(dt_ct,'gio_hl',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,' ') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,' ') || N' phút');
    b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_kt');
    PKH_JS_THAYa(dt_ct,'gio_kt',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,' ') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,' ') || N' phút');

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_hl');
    if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_hl',' '); 
    else PKH_JS_THAYa(dt_ct,'ngay_hl',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_kt');
    if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_kt',' '); 
    else PKH_JS_THAYa(dt_ct,'ngay_kt',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    b_i1:= FKH_JS_GTRIn(dt_ct ,'phi');
    PKH_JS_THAY(dt_ct,'phi',FBH_CSO_TIEN(b_i1,b_nt_tien) );
    PKH_JS_THAYa(dt_ct,'bangchu',FBH_IN_CSO_CHU(b_i1,b_nt_tien) );
    if FKH_JS_GTRIn(dt_ct ,'so_dt') <> 0 then
      b_i1:= b_i1/FKH_JS_GTRIn(dt_ct ,'so_dt');
    end if;
    PKH_JS_THAY(dt_ct,'phi_ng',FBH_CSO_TIEN(b_i1,b_nt_tien) );

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ttoan');
    PKH_JS_THAY(dt_ct,'ttoan',FBH_CSO_TIEN(b_i1,b_nt_tien) );

    --ten kvuc
    b_temp_nvar:=' ';
    select kvuc into b_temp_var from ht_ma_dvi where ma = b_ma_dvi;
    select count(*) into b_i1 from  bh_ma_kvuc where ma = b_temp_var;
    if b_i1 <> 0 then
      select ten into b_temp_nvar from bh_ma_kvuc where ma = b_temp_var;
    end if;
    PKH_JS_THAYa(dt_ct,'ten_kvuc',b_temp_nvar);

    b_temp_var:= FKH_JS_GTRIs(dt_ct ,'gioi');
    if b_temp_var= 'M' and trim(b_temp_var) is not null then PKH_JS_THAY(dt_ct,'gioi', 'Nam');
    else PKH_JS_THAY(dt_ct,'gioi', N'Nữ');end if;

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ng_sinh');
    if b_i1 = 30000101 or b_i1 = 0 then PKH_JS_THAYa(dt_ct,'ng_sinh',' '); 
    else PKH_JS_THAYa(dt_ct,'ng_sinh',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    b_temp_var:= FKH_JS_GTRIs(dt_ct ,'goi');
    if trim(b_temp_var) is not null then
      select count(*) into b_i1 from bh_sk_goi where ma  = b_temp_var;
      if b_i1 <> 0 then select ten into b_temp_nvar from bh_sk_goi where ma  = b_temp_var;end if;
      PKH_JS_THAY(dt_ct,'goi',b_temp_nvar);
    end if;

    
   if trim(FKH_JS_GTRIs(dt_ct ,'tend')) is null then
      PKH_JS_THAY(dt_ct,'tend',FKH_JS_GTRIs(dt_ct ,'ten'));
      PKH_JS_THAY(dt_ct,'mobid',FKH_JS_GTRIs(dt_ct ,'mobi'));
      PKH_JS_THAY(dt_ct,'cmtd',FKH_JS_GTRIs(dt_ct ,'cmt'));
      PKH_JS_THAY(dt_ct,'ng_sinhd',FKH_JS_GTRIs(dt_ct ,'ng_sinh'));
      PKH_JS_THAY(dt_ct,'gioid',FKH_JS_GTRIs(dt_ct ,'gioi'));
      PKH_JS_THAY(dt_ct,'emaild',FKH_JS_GTRIs(dt_ct ,'email'));
    end if;

end if;

-- thong tin thanh toan
delete temp_4;
select count(*) into b_i1 from bh_ngdl_tt where so_id = b_so_id;
if  b_i1 = 1 then
  select min(ngay) into b_ngay_tt from bh_ngdl_tt where so_id = b_so_id;
   insert into temp_4(C1) values(N'Thanh toán trước ngày '|| to_char(PKH_SO_CNG_DATE(b_ngay_tt),'DD/MM/YYYY') || N' theo hợp đồng bảo hiểm đã ký kết.'
   );
elsif b_i1 > 1 then
  b_i1:= 1;
  for r_lp in (select ngay,tien from bh_ngdl_tt where so_id = b_so_id)
  loop
    insert into temp_4(C1) values(N'- Kỳ ' || b_i1 || ': ' || to_char(PKH_SO_CNG_DATE(r_lp.ngay),'DD/MM/YYYY') || ' - ' || trim(TO_CHAR(r_lp.tien, '999,999,999,999,999,999PR'))|| ' ' || FKH_JS_GTRIs(dt_ct,'nt_tien') );
    b_i1:= b_i1 + 1;
  end loop;
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_tt from temp_4;
delete temp_4;
-- dt_dkbs
select count(*) into b_i1 from bh_ngdl_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_dkbs';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_bs FROM bh_ngdl_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_dkbs';
end if;
-- lay dk
select count(*) into b_i1 from bh_ngdl_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_dk';
if b_i1 <> 0 then
  select FKH_JS_BONH(t.txt) into dt_dk from bh_ngdl_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_dk';
end if;
-- dt_nh
select count(*) into b_i1 from bh_ngdl_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_nh';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_nh  FROM bh_ngdl_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_nh';
  if trim(dt_nh) is not null and dt_nh <> '"[]"' then
    b_lenh:=FKH_JS_LENHc('dt_nh_ct,dt_nh_dk,dt_nh_dkbs,dt_nh_lt,dt_nh_khd,dt_nh_kbt,dt_nh_ttt');
    EXECUTE IMMEDIATE b_lenh bulk collect into dt_nh_ct,dt_nh_dk,dt_nh_dkbs,dt_nh_lt,dt_nh_khd,dt_nh_kbt,dt_nh_ttt using dt_nh;
    dt_dk:= dt_nh_dk(1);dt_bs:= dt_nh_dkbs(1);
  end if;
end if;
if dt_dk <> '""' then
  b_lenh:=FKH_JS_LENH('ma,ten,tien,mota,cap');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_dk_ma,a_dk_ten,a_dk_tien,a_dk_mota,a_dk_cap  using dt_dk;
  delete temp_1;commit;
  for b_lp in 1..a_dk_ma.count loop
    if a_dk_cap(b_lp) > 1 then
      insert into temp_1(c1,c2,c3) values(a_dk_ma(b_lp),a_dk_ten(b_lp),FBH_CSO_TIEN(a_dk_tien(b_lp),b_nt_tien));
    end if;
  end loop;
  select JSON_ARRAYAGG(json_object('stt' value rownum,'ten' VALUE C2,'tien' value c3  returning clob) returning clob) into dt_dk from temp_1;
  delete temp_1;commit;
end if;

-- lay ds
delete temp_1;commit;
select count(*) into b_i1 from bh_ngdl_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_ds';
if b_i1 <> 0 then
  select FKH_JS_BONH(t.txt) into dt_ds from bh_ngdl_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_ds';
  if dt_ds <> '"[]"' then
    b_lenh:=FKH_JS_LENH('ten,ng_sinh,gioi,cmt,mobi,email,nhom');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_ten,a_ng_sinh,a_gioi,a_cmt,a_mobi,a_email,a_nhom  using dt_ds;
    for b_lp in 1..a_ten.count loop
      b_i2:= 0;
      if a_ng_sinh(b_lp) = 30000101 or a_ng_sinh(b_lp) = 0 then
          b_temp_var:= ' ';
      else 
        b_temp_var:= FBH_IN_CSO_NG( a_ng_sinh(b_lp),'DD/MM/YYYY'); 
        b_i2:= FBH_INHD_TINH_TUOI(a_ng_sinh(b_lp));
      end if;
      --- tinh phi cho tung nguoi dlgia dinh
      insert into temp_1(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10) values(a_nhom(b_lp),a_ten(b_lp),b_temp_var,case when a_gioi(b_lp) = 'M' then N'Nam' else N'Nữ' end
      ,a_cmt(b_lp),a_mobi(b_lp),FKH_JS_GTRIs(dt_ct ,'goi'),FKH_JS_GTRIs(dt_ct ,'phi'),b_i2, FKH_JS_GTRIs(dt_ct ,'so_hd'));
    end loop;
    if dt_nh_ct.count > 0 then        
        for b_lp in 1..dt_nh_ct.count loop
            b_i1:= FKH_JS_GTRIn(dt_nh_ct(b_lp) ,'phi');
            b_temp_var := FKH_JS_GTRIs(dt_nh_ct(b_lp) ,'nhom');
            update temp_1 set c7 = FBH_IN_TEN_GOI(FKH_JS_GTRIs(dt_nh_ct(b_lp) ,'goi')), c8 = FBH_CSO_TIEN(b_i1,b_nt_tien) where c1 = b_temp_var;
        end loop;
    end if;
    select JSON_ARRAYAGG(json_object('stt' value rownum,'ten' VALUE C2,'ng_sinh' value c3,'gioi' value c4,'cmt' value c5,'mobi' value c6,
      'goi' value c7,'phi' value c8,'tuoi' value c9,'so_hd' value c10 returning clob) returning clob) into dt_ds from temp_1;
  end if;
end if;
delete temp_1;commit;


select json_object('dt_ct' value dt_ct,'dt_dk' value dt_dk, 'dt_ds' value dt_ds, 'dt_lt' value dt_lt,
'dt_bs' value dt_bs,'dt_tt' value dt_tt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
