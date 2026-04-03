create or replace procedure PBH_SK_TC_HC(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    -- chung
    b_loi varchar2(100); b_lenh varchar2(1000);
    -- orain
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
  --
    b_i1 number := 0;b_ngay_tt number;b_i2 number:=0;
    dt_ct clob; dt_bs clob; dt_ds clob; dt_dk clob; dt_lt clob;dt_kbt clob; dt_ttt clob;dt_dong clob;
    b_kh_ttt clob;dt_qt clob;dt_tt clob;b_dvi clob;dt_hu clob;dt_dkbs clob;
    dt_cho clob;

    dt_nh clob;
    dt_nh_ct pht_type.a_clob;dt_nh_dk pht_type.a_clob;dt_nh_dkbs pht_type.a_clob;dt_nh_lt pht_type.a_clob;
    dt_nh_khd pht_type.a_clob;dt_nh_kbt pht_type.a_clob;dt_nh_cho pht_type.a_clob;dt_nh_bvi pht_type.a_clob;dt_nh_ttt pht_type.a_clob;
    dt_nhom clob;

    b_temp_clob clob;a_clob pht_type.a_clob;
    b_ten_dvi nvarchar2(500):= ' ';
    b_temp_var varchar2(100);b_temp_nvar varchar2(500);
    b_ma_kvuc varchar2(20);
    b_ten_kvuc nvarchar2(500):= ' ';
    b_nt_tien varchar2(50);
    b_ma_kt varchar2(50);b_kieu_kt varchar2(1);
    -- ls ton that
    b_so_lan_kn number:=0;
    b_tien_bt number:=0;b_tl_bt varchar2(100);
    b_xe_id number;

    ---kbt
    a_kbt_ma_dk pht_type.a_var; a_kbt_kbt pht_type.a_nvar;
    a_kbt_nd pht_type.a_var; a_kbt_ma pht_type.a_nvar;

    --a dt_dk
    a_dk_ma pht_type.a_var;a_dk_ten pht_type.a_nvar; a_dk_tien pht_type.a_num;a_dk_phi pht_type.a_num;
    a_dk_cap pht_type.a_num;a_dk_kieu pht_type.a_var;a_dk_lkeb pht_type.a_var;
    a_dk_mota pht_type.a_nvar;
    --dt_ds
    a_ds_ten pht_type.a_nvar;a_ds_phong pht_type.a_nvar;a_ds_ng_sinh pht_type.a_num;
    --tgian cho
    a_cho_ten pht_type.a_nvar;a_cho_sn pht_type.a_num;
begin
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);

select count(*) into b_i1 from bh_sk_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ct FROM bh_sk_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_ct';
    b_nt_tien:=FKH_JS_GTRIs(dt_ct ,'nt_tien');
    b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_hl');
    PKH_JS_THAYa(dt_ct,'gio_hl',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00') );
    b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_kt');
    PKH_JS_THAYa(dt_ct,'gio_kt',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00'));
    ---
    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_cap');
    if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_cap',' '); 
    else PKH_JS_THAYa(dt_ct,'ngay_cap',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    PKH_JS_THAYa(dt_ct,'ngay_cap_s',N'Ngày ' || FBH_IN_CSO_NG(b_i1,'DD') || N' tháng ' || FBH_IN_CSO_NG(b_i1,'MM')
    || N' năm ' || FBH_IN_CSO_NG(b_i1,'YYYY'));
    
    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_hl');
    if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_hl',' '); 
    else PKH_JS_THAYa(dt_ct,'ngay_hl',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_kt');
    if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_kt',' '); 
    else PKH_JS_THAYa(dt_ct,'ngay_kt',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    b_i1:= FKH_JS_GTRIn(dt_ct ,'phi');
    PKH_JS_THAY(dt_ct,'phi',FBH_CSO_TIEN(b_i1,b_nt_tien) );


    b_i1:= FKH_JS_GTRIn(dt_ct ,'thue');
    PKH_JS_THAY(dt_ct,'thue',FBH_CSO_TIEN(b_i1,b_nt_tien) );

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ttoan');
    PKH_JS_THAY(dt_ct,'ttoan',FBH_CSO_TIEN(b_i1,b_nt_tien) );
    PKH_JS_THAYa(dt_ct,'bangchu',FBH_IN_CSO_CHU(b_i1,b_nt_tien) );

    b_temp_var:= FKH_JS_GTRIs(dt_ct ,'gioi');
    if b_temp_var= 'M' and trim(b_temp_var) is not null then PKH_JS_THAY(dt_ct,'gioi', 'Nam');
    else PKH_JS_THAY(dt_ct,'gioi', N'Nữ');end if;

     b_temp_var:= FKH_JS_GTRIs(dt_ct ,'gioid');
    if b_temp_var= 'M' and trim(b_temp_var) is not null then PKH_JS_THAY(dt_ct,'gioid', 'Nam');
    else PKH_JS_THAY(dt_ct,'gioid', N'Nữ');end if;

    -- nguoi duoc bh
    if trim(FKH_JS_GTRIs(dt_ct ,'ng_dd')) is null THEN
      PKH_JS_THAY(dt_ct,'ng_dd',FKH_JS_GTRIs(dt_ct ,'ten'));
      PKH_JS_THAY(dt_ct,'cmtd',FKH_JS_GTRIs(dt_ct ,'cmt'));
      PKH_JS_THAY(dt_ct,'mobid',FKH_JS_GTRIs(dt_ct ,'mobi'));
      PKH_JS_THAY(dt_ct,'emaild',FKH_JS_GTRIs(dt_ct ,'email'));
      PKH_JS_THAY(dt_ct,'dchid',FKH_JS_GTRIs(dt_ct ,'dchi'));
      PKH_JS_THAY(dt_ct,'gioid',FKH_JS_GTRIs(dt_ct ,'gioi'));
      PKH_JS_THAY(dt_ct,'dchid',FKH_JS_GTRIs(dt_ct ,'dchi'));
      PKH_JS_THAY(dt_ct,'ng_sinhd',FKH_JS_GTRIs(dt_ct ,'ng_sinh'));
    end if;
    --goi
    b_temp_var:= FKH_JS_GTRIs(dt_ct ,'goi');
    if trim(b_temp_var) is not null then
      select count(*) into b_i1 from bh_sk_goi where ma  = b_temp_var;
      if b_i1 <> 0 then select ten into b_temp_nvar from bh_sk_goi where ma  = b_temp_var;end if;
      PKH_JS_THAY(dt_ct,'goi',b_temp_nvar);
    end if;
	 -- lay ten dvi
    select count(*) into b_i1 from  ht_ma_dvi where ma = b_ma_dvi;
    if b_i1 <> 0 then
       select ten,kvuc into b_ten_dvi,b_ma_kvuc from ht_ma_dvi where ma = b_ma_dvi;
    end if;
    if trim(b_ma_kvuc) is not null then
      select count(*) into b_i1 from  bh_ma_kvuc where ma = b_ma_kvuc;
      if b_i1 <> 0 then
        select ten into b_ten_kvuc from bh_ma_kvuc where ma = b_ma_kvuc;
      end if;
    end if;
    PKH_JS_THAYa(dt_ct,'ten_kvuc',b_ten_kvuc);
end if;

--tt dvi
    select json_object('ten_gon' value  NVL(ten_gon,' '),'ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
           'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
               from ht_ma_dvi where ma=b_ma_dvi;
    dt_ct:=FKH_JS_BONH(dt_ct);
    b_dvi:=FKH_JS_BONH(b_dvi);
    select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;
--tpa
  b_temp_var:= FKH_JS_GTRIs(dt_ct,'tpa');
  if trim(b_temp_var) is not null then
  select count(*) into b_i1 from bh_ma_gdinh where ma=b_temp_var;
  if b_i1 <> 0 then
  select json_object('ten_tpa' value  NVL(ten,' '),'dchi_tpa' value NVL(dchi,' '),'mobi_tpa' value NVL(mobi,' '),'email_tpa' value NVL(email,' ')
    returning clob) into b_temp_clob from bh_ma_gdinh where ma=b_temp_var;
  else
    select json_object('ten_tpa' value ' ','dchi_tpa' value ' ','mobi_tpa' value ' ','email_tpa' value ' '
    returning clob) into b_temp_clob from dual;
  end if;
  select json_mergepatch(dt_ct,b_temp_clob) into dt_ct from dual;
  end if;
-----dt_ds
select count(*) into b_i1 from bh_sk_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ds';
if b_i1 <> 0 then
  delete temp_1;commit;
  SELECT FKH_JS_BONH(t.txt) INTO dt_ds FROM bh_sk_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ds';
  b_lenh:=FKH_JS_LENH('ten,phong,ng_sinh');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_ten,a_ds_phong,a_ds_ng_sinh  using dt_ds;
  for b_lp in 1..a_ds_ten.count loop
    insert into temp_1(c1,c2,c3) values(a_ds_ten(b_lp),a_ds_phong(b_lp),FBH_IN_CSO_NG(a_ds_ng_sinh(b_lp),'DD/MM/YYYY'));
  end loop;
  select JSON_ARRAYAGG(json_object('STT' VALUE rownum, 'ten' value c1,'phong' value c2,'ng_sinh' value c3,'dchi' value ' ' returning clob) returning clob) into dt_ds from temp_1;

  delete temp_1;commit;
end if;
---thong tin thanh toan
delete temp_4;commit;
select count(*) into b_i1 from bh_sk_tt where ma_dvi = b_ma_dvi and so_id = b_so_id;
PKH_JS_THAYa(dt_ct,'so_ky_tt',b_i1);
if  b_i1 = 1 then
    select min(ngay) into b_ngay_tt from bh_sk_tt where ma_dvi = b_ma_dvi and so_id = b_so_id;
    PKH_JS_THAYa(dt_ct,'thoi_han_tt',N'Thời hạn thanh toán phí bảo hiểm: thanh toán trước ngày '|| FBH_IN_CSO_NG(b_ngay_tt,'DD/MM/YYYY'));
elsif b_i1 > 1 then
    PKH_JS_THAYa(dt_ct,'thoi_han_tt',N'Thời hạn thanh toán phí bảo hiểm:');
    b_i1:= 1;
    for r_lp in (select ngay,tien from bh_sk_tt where ma_dvi = b_ma_dvi and so_id = b_so_id order by ngay asc)
    loop
    insert into temp_4(C1) values(N'-   Kỳ ' || b_i1 || N': thanh toán ' || FBH_CSO_TIEN(r_lp.tien,FKH_JS_GTRIs(dt_ct,'nt_tien')) || N' trước ngày ' || FBH_IN_CSO_NG(r_lp.ngay,'DD/MM/YYYY'));
    b_i1:= b_i1 + 1;
    end loop;
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_tt from temp_4;
delete temp_4;commit;
--end dong

-----dt_nh
select count(*) into b_i1 from bh_sk_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_nh';
if b_i1 <> 0 then
  delete temp_1;delete temp_2;delete temp_3;commit;
  SELECT FKH_JS_BONH(t.txt) INTO dt_nh FROM bh_sk_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_nh';
  b_lenh:=FKH_JS_LENHc('dt_nh_ct,dt_nh_dk,dt_nh_dkbs,dt_nh_lt,dt_nh_khd,dt_nh_kbt,dt_nh_cho,dt_nh_bvi,dt_nh_ttt');
  EXECUTE IMMEDIATE b_lenh bulk collect into dt_nh_ct,dt_nh_dk,dt_nh_dkbs,dt_nh_lt,dt_nh_khd,dt_nh_kbt,dt_nh_cho,dt_nh_bvi,dt_nh_ttt using dt_nh;
  
  --lay ra so nhom > dt_ct
  PKH_JS_THAY(dt_ct,'so_nhom',dt_nh_ct.count);
  -- dieu khoan bo sung
  dt_dkbs:= dt_nh_dkbs(1);
  --
  dt_dk:= dt_nh_dk(1);
  b_lenh:=FKH_JS_LENH('ma,ten,tien,mota,cap');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_dk_ma,a_dk_ten,a_dk_tien,a_dk_mota,a_dk_cap  using dt_dk;
  --tao table 1 voi gia tri ma + ten chung
  b_i1:= 1;b_i2:=0;
  for b_lp in 1..a_dk_ma.count loop
    if a_dk_cap(b_lp) > 1 then
      if a_dk_cap(b_lp) = 3 then 
        b_temp_nvar:= to_char(b_i1);
        b_i1:=b_i1 +1;
      else b_temp_nvar:= ' ';
      end if;
      insert into temp_1(c1,c2,c30,n10) values(a_dk_ma(b_lp),a_dk_ten(b_lp),b_temp_nvar,a_dk_cap(b_lp));
    end if;
    if UPPER(a_dk_ma(b_lp)) LIKE '%BS%' then
      if b_i2 = 0 then b_i1:= 1; end if;
      b_i2:= 1;
    end if;
  end loop;
  b_i1:= 1;
  b_i2:= 3;
  insert into temp_2(n1) values (b_so_id);
  for b_lp in 1..dt_nh_ct.count loop
    -- tao 1 header voi gia tri la ten cac nhom
    b_lenh:= 'update temp_2 set C'|| b_i1 ||' =:1 where N1 = :2';
    EXECUTE IMMEDIATE b_lenh USING FKH_JS_GTRIs(dt_nh_ct(b_lp) ,'ten'),b_so_id;
    b_i1:= b_i1 +1;
    -- update gia tri tien vao bang temp_1 theo tung nhom
    b_lenh:=FKH_JS_LENH('ma,ten,tien,mota,cap');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_dk_ma,a_dk_ten,a_dk_tien,a_dk_mota,a_dk_cap  using dt_nh_dk(b_lp);
    for b_lp2 in 1..a_dk_ma.count loop
      if a_dk_cap(b_lp2) > 1 then
        b_lenh:= 'update temp_1 set C'|| b_i2 ||' =:1 where c1 = :2';
        if a_dk_tien(b_lp2) <> 0 then
          b_temp_nvar:= FBH_CSO_TIEN(a_dk_tien(b_lp2),b_nt_tien);
        else
          b_temp_nvar:= a_dk_mota(b_lp2);
        end if;
        EXECUTE IMMEDIATE b_lenh USING b_temp_nvar,a_dk_ma(b_lp2);
      end if;
    end loop;
    b_i2:= b_i2 + 1;
  end loop;
  select JSON_ARRAYAGG(json_object('ma' VALUE ' ','ten' value ' ','nhom1' value c1,'nhom2' value c2,'nhom3' value c3,'nhom4' value c4  returning clob) returning clob) into dt_nhom from temp_2;
  select JSON_ARRAYAGG(json_object('cap' value n10,'ma' VALUE c30,'ten' value c2,'nhom1' value c3,'nhom2' value c4,'nhom3' value c5,'nhom4' value c6  returning clob) returning clob) into dt_dk 
    from temp_1 where UPPER(c1) NOT LIKE '%BS%' order by c1;
  select JSON_ARRAYAGG(json_object('cap' value n10,'ma' VALUE c30,'ten' value c2,'nhom1' value c3,'nhom2' value c4,'nhom3' value c5,'nhom4' value c6  returning clob) returning clob) into dt_bs 
    from temp_1 where UPPER(c1) LIKE '%BS%' order by c1;
delete temp_1; delete temp_2;commit;
end if;
-- thon tin thoi gian cho
b_lenh:=FKH_JS_LENH('ten,so_ngay');
EXECUTE IMMEDIATE b_lenh bulk collect into a_cho_ten,a_cho_sn  using dt_nh_cho(1);
delete temp_1;commit;
for b_lp in 1..a_cho_ten.count loop
  b_temp_nvar:= case when a_cho_sn(b_lp) > 0 then a_cho_sn(b_lp) || N' ngày'  else ' ' end;
  insert into temp_1(c1) values(a_cho_ten(b_lp) || ': ' || b_temp_nvar );
end loop;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_cho from temp_1;
delete temp_1;commit;

select json_object('dt_ct' value dt_ct,'dt_dk' value dt_dk,
'dt_qt' value dt_qt,'dt_bs' value dt_bs,'dt_kbt' value dt_kbt,
'dt_ttt' value dt_ttt,'dt_lt' value dt_lt,'dt_dong' value dt_dong,'dt_tt' value dt_tt,'dt_hu' value dt_hu,'dt_nhom' value dt_nhom,
'dt_ds' value dt_ds,'dt_cho' value dt_cho,'dt_dkbs' value dt_dkbs returning clob) into b_oraOut from dual;

commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
/

create or replace procedure PBH_SK_TC_TD(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    -- chung
    b_loi varchar2(100); b_lenh varchar2(1000);
    -- orain
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
  --
    b_i1 number := 0;b_ngay_tt number;b_i2 number:=0;
    dt_ct clob; dt_bs clob; dt_ds clob; dt_dk clob; dt_lt clob;dt_kbt clob; dt_ttt clob;dt_dong clob;
    b_kh_ttt clob;dt_qt clob;dt_tt clob;b_dvi clob;dt_hu clob;dt_dkbs clob;
    dt_cho clob;

    dt_nh clob;
    dt_nh_ct pht_type.a_clob;dt_nh_dk pht_type.a_clob;dt_nh_dkbs pht_type.a_clob;dt_nh_lt pht_type.a_clob;
    dt_nh_khd pht_type.a_clob;dt_nh_kbt pht_type.a_clob;dt_nh_cho pht_type.a_clob;dt_nh_bvi pht_type.a_clob;dt_nh_ttt pht_type.a_clob;
    dt_nhom clob;

    b_temp_clob clob;a_clob pht_type.a_clob;
    b_ten_dvi nvarchar2(500):= ' ';
    b_temp_var varchar2(100);b_temp_nvar varchar2(500);
    b_ma_kvuc varchar2(20);
    b_ten_kvuc nvarchar2(500):= ' ';
    b_nt_tien varchar2(50);
    b_ma_kt varchar2(50);b_kieu_kt varchar2(1);
    -- ls ton that
    b_so_lan_kn number:=0;
    b_tien_bt number:=0;b_tl_bt varchar2(100);
    b_xe_id number;

    ---kbt
    a_kbt_ma_dk pht_type.a_var; a_kbt_kbt pht_type.a_nvar;
    a_kbt_nd pht_type.a_var; a_kbt_ma pht_type.a_nvar;

    --a dt_dk
    a_dk_ma pht_type.a_var;a_dk_ten pht_type.a_nvar; a_dk_tien pht_type.a_num;a_dk_phi pht_type.a_num;
    a_dk_cap pht_type.a_num;a_dk_kieu pht_type.a_var;a_dk_lkeb pht_type.a_var;
    a_dk_mota pht_type.a_nvar;
    --dt_ds
    a_ds_ten pht_type.a_nvar;a_ds_cmt pht_type.a_var;a_ds_ng_sinh pht_type.a_num;a_ds_mobi pht_type.a_var;
    a_ds_email pht_type.a_var;a_ds_nhom pht_type.a_var;
    --tgian cho
    a_cho_ten pht_type.a_nvar;a_cho_sn pht_type.a_num;

    --a dt_bs
    a_bs_ma pht_type.a_var;a_bs_ten pht_type.a_nvar; a_bs_tien pht_type.a_num;a_bs_phi pht_type.a_num;
    a_bs_cap pht_type.a_num;a_bs_mota pht_type.a_nvar;
begin
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);

select count(*) into b_i1 from bh_sk_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ct FROM bh_sk_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_ct';
    b_nt_tien:=FKH_JS_GTRIs(dt_ct ,'nt_tien');
    b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_hl');
    PKH_JS_THAYa(dt_ct,'gio_hl',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00') );
    b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_kt');
    PKH_JS_THAYa(dt_ct,'gio_kt',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00'));
    ---
    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_cap');
    if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_cap',' '); 
    else PKH_JS_THAYa(dt_ct,'ngay_cap',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    PKH_JS_THAYa(dt_ct,'ngay_cap_s',N'Ngày ' || FBH_IN_CSO_NG(b_i1,'DD') || N' tháng ' || FBH_IN_CSO_NG(b_i1,'MM')
    || N' năm ' || FBH_IN_CSO_NG(b_i1,'YYYY'));
    
    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_hl');
    if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_hl',' '); 
    else PKH_JS_THAYa(dt_ct,'ngay_hl',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_kt');
    if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_kt',' '); 
    else PKH_JS_THAYa(dt_ct,'ngay_kt',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    b_i1:= FKH_JS_GTRIn(dt_ct ,'phi');
    PKH_JS_THAY(dt_ct,'phi',FBH_CSO_TIEN(b_i1,b_nt_tien) );


    b_i1:= FKH_JS_GTRIn(dt_ct ,'thue');
    PKH_JS_THAY(dt_ct,'thue',FBH_CSO_TIEN(b_i1,b_nt_tien) );

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ttoan');
    PKH_JS_THAY(dt_ct,'ttoan',FBH_CSO_TIEN(b_i1,b_nt_tien) );
    PKH_JS_THAYa(dt_ct,'bangchu',FBH_IN_CSO_CHU(b_i1,b_nt_tien) );

    b_temp_var:= FKH_JS_GTRIs(dt_ct ,'gioi');
    if b_temp_var= 'M' and trim(b_temp_var) is not null then PKH_JS_THAY(dt_ct,'gioi', 'Nam');
    else PKH_JS_THAY(dt_ct,'gioi', N'Nữ');end if;

     b_temp_var:= FKH_JS_GTRIs(dt_ct ,'gioid');
    if b_temp_var= 'M' and trim(b_temp_var) is not null then PKH_JS_THAY(dt_ct,'gioid', 'Nam');
    else PKH_JS_THAY(dt_ct,'gioid', N'Nữ');end if;

    -- nguoi duoc bh
    if trim(FKH_JS_GTRIs(dt_ct ,'ng_dd')) is null THEN
      PKH_JS_THAY(dt_ct,'ng_dd',FKH_JS_GTRIs(dt_ct ,'ten'));
      PKH_JS_THAY(dt_ct,'cmtd',FKH_JS_GTRIs(dt_ct ,'cmt'));
      PKH_JS_THAY(dt_ct,'mobid',FKH_JS_GTRIs(dt_ct ,'mobi'));
      PKH_JS_THAY(dt_ct,'emaild',FKH_JS_GTRIs(dt_ct ,'email'));
      PKH_JS_THAY(dt_ct,'dchid',FKH_JS_GTRIs(dt_ct ,'dchi'));
      PKH_JS_THAY(dt_ct,'gioid',FKH_JS_GTRIs(dt_ct ,'gioi'));
      PKH_JS_THAY(dt_ct,'dchid',FKH_JS_GTRIs(dt_ct ,'dchi'));
      PKH_JS_THAY(dt_ct,'ng_sinhd',FKH_JS_GTRIs(dt_ct ,'ng_sinh'));
    end if;
    --goi
    b_temp_var:= FKH_JS_GTRIs(dt_ct ,'goi');
    if trim(b_temp_var) is not null then
      select count(*) into b_i1 from bh_sk_goi where ma  = b_temp_var;
      if b_i1 <> 0 then select ten into b_temp_nvar from bh_sk_goi where ma  = b_temp_var;end if;
      PKH_JS_THAY(dt_ct,'goi',b_temp_nvar);
    end if;
	 -- lay ten dvi
    select count(*) into b_i1 from  ht_ma_dvi where ma = b_ma_dvi;
    if b_i1 <> 0 then
       select ten,kvuc into b_ten_dvi,b_ma_kvuc from ht_ma_dvi where ma = b_ma_dvi;
    end if;
    if trim(b_ma_kvuc) is not null then
      select count(*) into b_i1 from  bh_ma_kvuc where ma = b_ma_kvuc;
      if b_i1 <> 0 then
        select ten into b_ten_kvuc from bh_ma_kvuc where ma = b_ma_kvuc;
      end if;
    end if;
    PKH_JS_THAYa(dt_ct,'ten_kvuc',b_ten_kvuc);
end if;

--tt dvi
    select json_object('ten_gon' value  NVL(ten_gon,' '),'ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
           'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
               from ht_ma_dvi where ma=b_ma_dvi;
    dt_ct:=FKH_JS_BONH(dt_ct);
    b_dvi:=FKH_JS_BONH(b_dvi);
    select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;
--tpa
  b_temp_var:= FKH_JS_GTRIs(dt_ct,'tpa');
  if trim(b_temp_var) is not null then
  select count(*) into b_i1 from bh_ma_gdinh where ma=b_temp_var;
  if b_i1 <> 0 then
  select json_object('ten_tpa' value  NVL(ten,' '),'dchi_tpa' value NVL(dchi,' '),'mobi_tpa' value NVL(mobi,' '),'email_tpa' value NVL(email,' ')
    returning clob) into b_temp_clob from bh_ma_gdinh where ma=b_temp_var;
  else
    select json_object('ten_tpa' value ' ','dchi_tpa' value ' ','mobi_tpa' value ' ','email_tpa' value ' '
    returning clob) into b_temp_clob from dual;
  end if;
  select json_mergepatch(dt_ct,b_temp_clob) into dt_ct from dual;
  end if;
-----dt_ds
select count(*) into b_i1 from bh_sk_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ds';
if b_i1 <> 0 then
  delete temp_1;commit;
  SELECT FKH_JS_BONH(t.txt) INTO dt_ds FROM bh_sk_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ds';
  b_lenh:=FKH_JS_LENH('ten,ten_nh,ng_sinh,cmt,email,mobi');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_ten,a_ds_nhom,a_ds_ng_sinh,a_ds_cmt,a_ds_email,a_ds_mobi  using dt_ds;
  for b_lp in 1..a_ds_ten.count loop
    insert into temp_1(c1,c2,c3,c4,c5,c6) values(a_ds_ten(b_lp),a_ds_nhom(b_lp),FBH_IN_CSO_NG(a_ds_ng_sinh(b_lp),'DD/MM/YYYY'),a_ds_cmt(b_lp),a_ds_email(b_lp),a_ds_mobi(b_lp));
  end loop;
  select JSON_ARRAYAGG(json_object('STT' VALUE rownum, 'ten' value c1,'ten_nh' value c2,'ng_sinh' value c3,'cmt' value c4,'email' value c5,'mobi' value c6 returning clob) returning clob) into dt_ds from temp_1;

  delete temp_1;commit;
end if;
---thong tin thanh toan
delete temp_4;commit;
select count(*) into b_i1 from bh_sk_tt where ma_dvi = b_ma_dvi and so_id = b_so_id;
PKH_JS_THAYa(dt_ct,'so_ky_tt',b_i1);
if  b_i1 = 1 then
    select min(ngay) into b_ngay_tt from bh_sk_tt where ma_dvi = b_ma_dvi and so_id = b_so_id;
    PKH_JS_THAYa(dt_ct,'thoi_han_tt',N'Thời hạn thanh toán phí bảo hiểm: thanh toán trước ngày '|| FBH_IN_CSO_NG(b_ngay_tt,'DD/MM/YYYY'));
elsif b_i1 > 1 then
    PKH_JS_THAYa(dt_ct,'thoi_han_tt',N'Thời hạn thanh toán phí bảo hiểm:');
    b_i1:= 1;
    for r_lp in (select ngay,tien from bh_sk_tt where ma_dvi = b_ma_dvi and so_id = b_so_id order by ngay asc)
    loop
    insert into temp_4(C1) values(N'-   Kỳ ' || b_i1 || N': thanh toán ' || FBH_CSO_TIEN(r_lp.tien,FKH_JS_GTRIs(dt_ct,'nt_tien')) || N' trước ngày ' || FBH_IN_CSO_NG(r_lp.ngay,'DD/MM/YYYY'));
    b_i1:= b_i1 + 1;
    end loop;
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_tt from temp_4;
delete temp_4;commit;
--end dong

-----dt_nh
select count(*) into b_i1 from bh_sk_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_nh';
if b_i1 <> 0 then
    delete temp_1;delete temp_2;delete temp_3;commit;
    SELECT FKH_JS_BONH(t.txt) INTO dt_nh FROM bh_sk_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_nh';
    b_lenh:=FKH_JS_LENHc('dt_nh_ct,dt_nh_dk,dt_nh_dkbs,dt_nh_lt,dt_nh_khd,dt_nh_kbt,dt_nh_cho,dt_nh_bvi,dt_nh_ttt');
    EXECUTE IMMEDIATE b_lenh bulk collect into dt_nh_ct,dt_nh_dk,dt_nh_dkbs,dt_nh_lt,dt_nh_khd,dt_nh_kbt,dt_nh_cho,dt_nh_bvi,dt_nh_ttt using dt_nh;

    --lay ra so nhom > dt_ct
    PKH_JS_THAY(dt_ct,'so_nhom',dt_nh_ct.count);
    for b_lp in 1..dt_nh_ct.count loop
        insert into temp_1(c1,c2,c3,c4) values(FKH_JS_GTRIs(dt_nh_ct(b_lp) ,'ten'),FBH_CSO_TIEN_KNT(FKH_JS_GTRIn(dt_nh_ct(b_lp) ,'phi')), FKH_JS_GTRIn(dt_nh_ct(b_lp) ,'so_dt'),
            FBH_CSO_TIEN_KNT(FKH_JS_GTRIn(dt_nh_ct(b_lp) ,'phi')*FKH_JS_GTRIn(dt_nh_ct(b_lp) ,'so_dt')));
    end loop;
 
    for b_lp in 1..dt_nh_ct.count loop
        insert into temp_2(c1,c2) values(FKH_JS_GTRIs(dt_nh_ct(b_lp) ,'nhom'),FKH_JS_GTRIs(dt_nh_ct(b_lp) ,'ten'));

        b_lenh:=FKH_JS_LENH('ma,ten,tien,mota,cap');
        EXECUTE IMMEDIATE b_lenh bulk collect into a_dk_ma,a_dk_ten,a_dk_tien,a_dk_mota,a_dk_cap  using dt_nh_dk(b_lp);
        b_temp_var:='';
        for b_lp1 in 1..a_dk_ma.count loop
            if a_dk_ma(b_lp1) = '1.a' then 
              b_temp_var := 'c3';
            elsif a_dk_ma(b_lp1) = '1.b' then
              b_temp_var := 'c4';
            elsif a_dk_ma(b_lp1) = '2' then
              b_temp_var := 'c5';
            elsif a_dk_ma(b_lp1) = '3.a' then
              b_temp_var := 'c6';
            elsif a_dk_ma(b_lp1) = '3.b' then
              b_temp_var := 'c7';
            elsif a_dk_ma(b_lp1) = '4' then
              b_temp_var := 'c8';
            elsif a_dk_ma(b_lp1) = '5' then
              b_temp_var := 'c9';
            elsif a_dk_ma(b_lp1) = '6' then
              b_temp_var := 'c10';
            end if;
            if trim(b_temp_var) is not null then
              b_lenh:= 'update temp_2 set '|| b_temp_var ||' =:1 where c1 = :2';
              EXECUTE IMMEDIATE b_lenh USING FBH_CSO_TIEN(a_dk_tien(b_lp1),''),FKH_JS_GTRIs(dt_nh_ct(b_lp) ,'nhom');
            end if;
        end loop;
    end loop;
       -- dieu khoan bo sung
    if dt_nh_dkbs.count <> 0 then
      dt_dkbs:= dt_nh_dkbs(1);
      b_lenh:=FKH_JS_LENH('ma,ten,tien,mota,cap');
      EXECUTE IMMEDIATE b_lenh bulk collect into a_bs_ma,a_bs_ten,a_bs_tien,a_bs_mota,a_bs_cap  using dt_dkbs;
      for b_lp in 1..a_bs_ma.count loop
        select count(*) into b_i1 from bh_ma_dkbs where ma = a_bs_ma(b_lp);
        if b_i1 <> 0 then
          SELECT FKH_JS_GTRIc(FKH_JS_BONH(t.txt) ,'nd') into b_temp_clob from bh_ma_dkbs t where  t.ma= a_bs_ma(b_lp) and rownum = 1;
        end if;
        insert into temp_4(c1,c2,cl1) values(a_bs_ma(b_lp),a_bs_ten(b_lp),b_temp_clob);
      end loop;
    end if;


    select JSON_ARRAYAGG(json_object(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10 returning clob) returning clob) into dt_dk from temp_2;
    select JSON_ARRAYAGG(json_object('TEN' VALUE C1,'phi' value c2,'so_dt' value c3, 'ttoan' value c4 returning clob) returning clob) into dt_nhom from temp_1;
    select JSON_ARRAYAGG(json_object('ma' VALUE c1,'ten' value rownum || '. ' ||c2,'nd' value cl1 returning clob) returning clob) into dt_bs from temp_4;

    delete temp_1; delete temp_2;delete temp_4;commit;
end if;
-- thon tin thoi gian cho
b_lenh:=FKH_JS_LENH('ten,so_ngay');
EXECUTE IMMEDIATE b_lenh bulk collect into a_cho_ten,a_cho_sn  using dt_nh_cho(1);
delete temp_1;commit;
for b_lp in 1..a_cho_ten.count loop
  b_temp_nvar:= case when a_cho_sn(b_lp) > 0 then a_cho_sn(b_lp) || N' ngày'  else ' ' end;
  insert into temp_1(c1) values(a_cho_ten(b_lp) || ': ' || b_temp_nvar );
end loop;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_cho from temp_1;
delete temp_1;commit;

select json_object('dt_ct' value dt_ct,'dt_dk' value dt_dk,
'dt_qt' value dt_qt,'dt_bs' value dt_bs,'dt_kbt' value dt_kbt,
'dt_ttt' value dt_ttt,'dt_lt' value dt_lt,'dt_dong' value dt_dong,'dt_tt' value dt_tt,'dt_hu' value dt_hu,'dt_nhom' value dt_nhom,
'dt_ds' value dt_ds,'dt_cho' value dt_cho,'dt_dkbs' value dt_dkbs returning clob) into b_oraOut from dual;


exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
/
--bao gia to chuc
create or replace procedure PBH_IN_B_TC(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number;b_lenh varchar2(1000);
    b_so_hd varchar2(50) :=FKH_JS_GTRIs(b_oraIn,'so_hd');
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_lan number:= TO_NUMBER(FKH_JS_GTRIs(b_oraIn,'lan_in'));
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
    dt_ct clob; dt_nh clob; dt_ds clob;dt_dk clob;dt_lt clob;dt_bs clob;dt_tttk clob;dk_qtac clob;dt_tt_b clob;
    dt_kytt clob;
    dt_nhom clob;dt_cho clob;
    a_ngay_tt pht_type.a_num;

    b_temp_nvar varchar2(500);b_temp_var varchar2(100);
    b_nt_tien varchar2(50);
	
    b_ma_kh varchar2(20);b_nghed varchar2(20);b_nghed_ten nvarchar2(500):= ' ';
    b_ma_sp varchar2(20);b_ten_sp nvarchar2(500):= ' ';
    b_ten_dvi nvarchar2(500):= ' ';
    b_quy_tac nvarchar2(500):= ' ';b_ma_qtac varchar2(20);
    b_count number:=0;b_ngay_tt number;
   --bien mang
    dt_nh_dk pht_type.a_clob;dt_nh_dkbs pht_type.a_clob;dt_nh_lt pht_type.a_clob;dt_nh_ct pht_type.a_clob;
    dt_nh_cho pht_type.a_clob;

    --tgian cho
    a_cho_ten pht_type.a_nvar;a_cho_sn pht_type.a_num;


    dk_ten pht_type.a_nvar;dk_ma pht_type.a_var;dk_tien pht_type.a_num;dk_phi pht_type.a_num;dk_cap pht_type.a_num;dk_mota pht_type.a_nvar;
    ds_ten pht_type.a_nvar;ds_cmt pht_type.a_var;ds_ng_sinh pht_type.a_num;ds_mobi pht_type.a_var;ds_email pht_type.a_var;ds_nhom pht_type.a_var;

    ma_lt pht_type.a_var;b_nd_lt clob;

begin
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
-- lay dt_ct
select count(*) into b_i1 from bh_ngB_txt where  so_id = b_so_id and loai='dt_ct' and lan = b_lan;
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(txt) into dt_ct from bh_ngB_txt where  so_id = b_so_id and loai='dt_ct' and lan = b_lan;
  b_ma_kh := FKH_JS_GTRIs(dt_ct,'ma_kh');
  select nghe into b_nghed from bh_dtac_ma where ma = b_ma_kh;
  if trim(b_nghed) is not null then
    select count(*) into b_count  from bh_ma_nghe where ma=b_nghed;
    if b_count <> 0 then
      select NVL(ten,' ') into b_nghed_ten  from bh_ma_nghe where ma=b_nghed;
    end if;
  end if;
  PKH_JS_THAYa(dt_ct,'nghed_ten',b_nghed_ten);

  select count(*) into b_count from bh_ngb_ds where so_id=b_so_id;
  PKH_JS_THAYa(dt_ct,'so_nguoi',b_count);
  --ma sp
  b_ma_sp := FKH_JS_GTRIs(dt_ct,'ma_sp');
  if trim(b_ma_sp) is not null then
    select count(*) into b_count  from bh_sk_sp where ma=b_ma_sp;
    if b_count <> 0 then
      select NVL(ten,' ') into b_ten_sp  from bh_sk_sp where ma=b_ma_sp;
    end if;
  end if;
  PKH_JS_THAYa(dt_ct,'ten_sp',UPPER(b_ten_sp));
  -- quy tac
  begin
    SELECT FKH_JS_BONH(txt) into dk_qtac FROM bh_sk_sp WHERE ma = b_ma_sp;
      b_lenh := FKH_JS_LENH('qtac');
      EXECUTE IMMEDIATE b_lenh INTO b_ma_qtac USING dk_qtac;

    IF b_ma_qtac IS NOT NULL THEN
      SELECT t.TEN into b_quy_tac FROM bh_ma_qtac t WHERE t.ma=b_ma_qtac;
    END IF;
  exception
  WHEN others THEN
    dbms_output.put_line('Error!' || SQLERRM);
  end;
  -- lay ten dvi
  select count(*) into b_count from  ht_ma_dvi where ma = b_ma_dvi;
  if b_count <> 0 then
     select ten into b_ten_dvi from ht_ma_dvi where ma = b_ma_dvi;
  end if;
  PKH_JS_THAYa(dt_ct,'ten_dvi',b_ten_dvi);
  PKH_JS_THAYa(dt_ct,'quy_tac',b_quy_tac);
  
	b_nt_tien:=FKH_JS_GTRIs(dt_ct ,'nt_tien');
	if b_nt_tien= 'VND' then PKH_JS_THAYa(dt_ct,'nt_tien', N'Đồng');b_nt_tien:=N'đồng'; end if;

	b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_hl');
	PKH_JS_THAYa(dt_ct,'gio_hl',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00') );
	b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_kt');
	PKH_JS_THAYa(dt_ct,'gio_kt',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00'));
	---
	b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_cap');
	if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_cap',' '); 
	else PKH_JS_THAYa(dt_ct,'ngay_cap',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

	PKH_JS_THAYa(dt_ct,'ngay_cap_s',N'Ngày ' || FBH_IN_CSO_NG(b_i1,'DD') || N' tháng ' || FBH_IN_CSO_NG(b_i1,'MM')
	|| N' năm ' || FBH_IN_CSO_NG(b_i1,'YYYY'));

	b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_hl');
	if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_hl',' '); 
	else PKH_JS_THAYa(dt_ct,'ngay_hl',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

	b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_kt');
	if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_kt',' '); 
	else PKH_JS_THAYa(dt_ct,'ngay_kt',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

	b_i1:= FKH_JS_GTRIn(dt_ct ,'phi');
	PKH_JS_THAY(dt_ct,'phi',FBH_CSO_TIEN(b_i1,b_nt_tien) );


	b_i1:= FKH_JS_GTRIn(dt_ct ,'thue');
	PKH_JS_THAY(dt_ct,'thue',FBH_CSO_TIEN(b_i1,b_nt_tien) );

	b_i1:= FKH_JS_GTRIn(dt_ct ,'ttoan');
	PKH_JS_THAY(dt_ct,'ttoan',FBH_CSO_TIEN(b_i1,b_nt_tien) );
	PKH_JS_THAYa(dt_ct,'bangchu',FBH_IN_CSO_CHU(b_i1,b_nt_tien) );

  PKH_JS_THAY_D(dt_ct,'tu_ngay',N'Từ '|| FKH_JS_GTRIs(dt_ct ,'gio_hl') || N' ngày ' || FKH_JS_GTRIn(dt_ct ,'ngay_hl'));
  PKH_JS_THAY_D(dt_ct,'den_ngay',N'Đến '|| FKH_JS_GTRIs(dt_ct ,'gio_kt') || N' ngày ' || FKH_JS_GTRIn(dt_ct ,'ngay_kt')); 

  
  
end if;
-- lay dt_nh
select count(*) into b_i1 from bh_ngB_txt where  so_id = b_so_id and loai='dt_nh';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(txt) into dt_nh from bh_ngB_txt where  so_id = b_so_id and loai='dt_nh' and lan = b_lan;

  b_lenh:=FKH_JS_LENHc('dt_nh_ct');
  EXECUTE IMMEDIATE b_lenh bulk collect into dt_nh_ct using dt_nh;

  b_lenh:=FKH_JS_LENHc('dt_nh_dk');
  EXECUTE IMMEDIATE b_lenh bulk collect into dt_nh_dk using dt_nh;

  b_lenh:=FKH_JS_LENHc('dt_nh_dkbs');
  EXECUTE IMMEDIATE b_lenh bulk collect into dt_nh_dkbs using dt_nh;

  b_lenh:=FKH_JS_LENHc('dt_nh_lt');
  EXECUTE IMMEDIATE b_lenh bulk collect into dt_nh_lt using dt_nh;

  b_lenh:=FKH_JS_LENHc('dt_nh_cho');
  EXECUTE IMMEDIATE b_lenh bulk collect into dt_nh_cho using dt_nh;

  delete temp_6;delete temp_1;delete temp_2; commit;
  
  for ds_lp in 1..dt_nh_lt.count loop
    b_lenh := FKH_JS_LENH('ma_lt');
    EXECUTE IMMEDIATE b_lenh bulk collect into ma_lt using dt_nh_lt(ds_lp);
    for b_lp in 1..ma_lt.count loop
      select count(*) into b_i1 from temp_6 where C1 = ma_lt(b_lp);
      if b_i1 = 0 then
        select FKH_JS_GTRIc(FKH_JS_BONH(txt) ,'nd') into b_nd_lt 
          from bh_ma_dklt where ma = ma_lt(b_lp);
        insert into temp_6(C1,CL1) values(ma_lt(b_lp),b_nd_lt);
      end if;
    end loop;
  end loop;

  b_lenh := FKH_JS_LENH('ma,ten,tien,phi,cap');
  for b_lp in 1..dt_nh_ct.count loop
      EXECUTE IMMEDIATE b_lenh bulk collect into dk_ma,dk_ten,dk_tien,dk_phi,dk_cap using dt_nh_dk(b_lp);
      b_i1 := 0;
      for b_lp1 in 1..dk_ma.count loop
        if dk_cap(b_lp1) = 1 and dk_tien(b_lp1) > b_i1 then 
          b_i1 := dk_tien(b_lp1); 
        end if;
      end loop;

      insert into temp_1(c1,c2,c3,c4,c5) values(
        FKH_JS_GTRIs(dt_nh_ct(b_lp),'ten'),
        FKH_JS_GTRIn(dt_nh_ct(b_lp),'so_dt'),
        FBH_CSO_TIEN(FKH_JS_GTRIn(dt_nh_ct(b_lp),'phi'),''),
        FBH_CSO_TIEN(FKH_JS_GTRIn(dt_nh_ct(b_lp),'phi') * FKH_JS_GTRIn(dt_nh_ct(b_lp),'so_dt'),''),
        FBH_CSO_TIEN(b_i1,'')
      );
    end loop;

  b_lenh := FKH_JS_LENH('ma,ten,tien,mota,cap');
  EXECUTE IMMEDIATE b_lenh bulk collect into dk_ma,dk_ten,dk_tien,dk_mota,dk_cap using dt_nh_dk(1);
  for b_lp in 1..dk_ma.count loop
    if dk_cap(b_lp) <> 1 then
    insert into temp_2(c1,c2,c3) values(dk_ma(b_lp),dk_ten(b_lp),FBH_CSO_TIEN(dk_tien(b_lp),''));
    end if;
  end loop;

  if dt_nh_dkbs.count > 0 then 
    dt_bs := dt_nh_dkbs(1);
  end if;


  select JSON_ARRAYAGG(json_object('nhom' value c1,'so_dt' value c2,'phi' value c3,'phi_nhom' value c4,'mtn' value c5 returning clob) 
  returning clob) into dt_nhom from temp_1;
  select JSON_ARRAYAGG(json_object('TEN' VALUE CL1 returning clob) returning clob) into dt_lt from temp_6;
  select JSON_ARRAYAGG(json_object('ma' VALUE c1,'ten' value c2,'tien' value c3 returning clob) returning clob) into dt_dk from temp_2;
  delete temp_6;delete temp_1;delete temp_2; commit;
end if;

select count(*) into b_i1 from bh_ngB_txt where  so_id = b_so_id and loai='dt_ds' and lan = b_lan;
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(txt) into dt_ds from bh_ngB_txt where  so_id = b_so_id and loai='dt_ds' and lan = b_lan;
  b_lenh:=FKH_JS_LENH('ten,ten_nh,ng_sinh,cmt,email,mobi');
  EXECUTE IMMEDIATE b_lenh bulk collect into ds_ten,ds_nhom,ds_ng_sinh,ds_cmt,ds_email,ds_mobi  using dt_ds;
  delete temp_5;commit;
  for b_lp in 1..ds_ten.count loop
    for b_lp1 in 1..dt_nh_ct.count loop
      if ds_nhom(b_lp) = FKH_JS_GTRIs(dt_nh_ct(b_lp1) ,'nhom') then
        b_i1 := FKH_JS_GTRIn(dt_nh_ct(b_lp1) ,'phi');
        exit;
      end if;
    end loop;
    insert into temp_5(c1,c2,c3,c4,c5,c6,c7,c8) values(ds_ten(b_lp),ds_nhom(b_lp),FBH_IN_CSO_NG(ds_ng_sinh(b_lp),'DD/MM/YYYY'),ds_cmt(b_lp),ds_email(b_lp),ds_mobi(b_lp),b_lp + 1,FBH_CSO_TIEN(b_i1,''));
  end loop;
  select JSON_ARRAYAGG(json_object('STT' VALUE c7,'ten' value c1,'ten_nh' value c2,'ng_sinh' value c3,'cmt' value c4,'email' value c5,'mobi' value c6,'phi' value c8 returning clob) returning clob) into dt_ds from temp_5;
end if;
-- thon tin thong ke
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into dt_tttk
    from bh_kh_ttt where ps='HD' and nv='NG' order by bt asc;
--kytt
select count(*) into b_i1 from bh_ngB_txt where so_id = b_so_id and loai='dt_kytt' and lan = b_lan;
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(txt) into dt_kytt from bh_ngB_txt where  so_id = b_so_id and loai='dt_kytt' and lan = b_lan;
  b_lenh:=FKH_JS_LENH('ngay');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_ngay_tt using dt_kytt;
end if;
-- thong tin thanh toan
delete temp_5;commit;
b_i1 := a_ngay_tt.count;
if  b_i1 = 1 then
   insert into temp_5(C1) values(N'Phương thức thanh toán: Bằng tiền mặt hoặc chuyển khoản. Thời hạn thanh toán: Thanh toán trong vòng 30 ngày kể từ ngày bắt đầu hiệu lực bảo hiểm.'
   );
elsif b_i1 > 1 then
	insert into temp_5(C1) values(N'Thời hạn thanh toán: Thanh toán thành ' || b_i1 || N' kỳ, trong đó kỳ 01 được thanh toán trong vòng 30 ngày kể từ ngày bắt đầu hiệu lực bảo hiểm.');
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1) returning clob) into dt_tt_b from temp_5;
delete temp_5;
--
-- thon tin thoi gian cho
b_lenh:=FKH_JS_LENH('ten,so_ngay');
EXECUTE IMMEDIATE b_lenh bulk collect into a_cho_ten,a_cho_sn  using dt_nh_cho(1);
delete temp_1;commit;
for b_lp in 1..a_cho_ten.count loop
  b_temp_nvar:= case when a_cho_sn(b_lp) > 0 then a_cho_sn(b_lp) || N' ngày'  else ' ' end;
  insert into temp_1(c1) values(a_cho_ten(b_lp) || ': ' || b_temp_nvar );
end loop;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_cho from temp_1;
delete temp_1;commit;


select json_object('dt_ct' value dt_ct,'dt_nh' value dt_nh, 'dt_ds' value dt_ds,'dt_dk' value dt_dk,
  'dt_lt' value dt_lt,'dt_bs' value dt_bs,'dt_tttk' value dt_tttk,'dt_tt' value dt_tt_b,'dt_nhom' value dt_nhom,'dt_cho' value dt_cho returning clob) into b_oraOut from dual;

exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;

/
create or replace procedure PBH_SK_TC_KH(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    -- chung
    b_loi varchar2(100); b_lenh varchar2(1000);
    -- orain
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
  --
    b_i1 number := 0;b_ngay_tt number;b_i2 number:=0;b_i3 number:=0;
    dt_ct clob; dt_bs clob; dt_ds clob; dt_dk clob; dt_lt clob;dt_kbt clob; dt_ttt clob;dt_dong clob;
    b_kh_ttt clob;dt_qt clob;dt_tt clob;b_dvi clob;dt_hu clob;dt_dkbs clob;
    dt_cho clob;

    dt_nh clob;
    dt_nh_ct pht_type.a_clob;dt_nh_dk pht_type.a_clob;dt_nh_dkbs pht_type.a_clob;dt_nh_lt pht_type.a_clob;
    dt_nh_khd pht_type.a_clob;dt_nh_kbt pht_type.a_clob;dt_nh_cho pht_type.a_clob;dt_nh_bvi pht_type.a_clob;dt_nh_ttt pht_type.a_clob;
    dt_nhom clob;

    b_temp_clob clob;a_clob pht_type.a_clob;
    b_ten_dvi nvarchar2(500):= ' ';
    b_temp_var varchar2(100);b_temp_nvar varchar2(500);
    b_ma_kvuc varchar2(20);
    b_ten_kvuc nvarchar2(500):= ' ';
    b_nt_tien varchar2(50);
    b_ma_kt varchar2(50);b_kieu_kt varchar2(1);
    -- ls ton that
    b_so_lan_kn number:=0;
    b_tien_bt number:=0;b_tl_bt varchar2(100);
    b_xe_id number;

    ---kbt
    a_kbt_ma_dk pht_type.a_var; a_kbt_kbt pht_type.a_nvar;
    a_kbt_nd pht_type.a_var; a_kbt_ma pht_type.a_nvar;

    --a dt_dk
    a_dk_ma pht_type.a_var;a_dk_ten pht_type.a_nvar; a_dk_tien pht_type.a_num;a_dk_phi pht_type.a_num;
    a_dk_cap pht_type.a_num;a_dk_kieu pht_type.a_var;a_dk_lkeb pht_type.a_var;
    a_dk_mota pht_type.a_nvar;
    a_dk_ptb pht_type.a_num;a_dk_ma_dk pht_type.a_var;
    --dt_ds
    a_ds_ten pht_type.a_nvar;a_ds_cmt pht_type.a_var;a_ds_ng_sinh pht_type.a_num;a_ds_mobi pht_type.a_var;
    a_ds_email pht_type.a_var;a_ds_nhom pht_type.a_var;a_ds_dchi pht_type.a_nvar;
    --tgian cho
    a_cho_ten pht_type.a_nvar;a_cho_sn pht_type.a_num;

    --a dt_bs
    a_bs_ma pht_type.a_var;a_bs_ten pht_type.a_nvar; a_bs_tien pht_type.a_num;a_bs_phi pht_type.a_num;
    a_bs_cap pht_type.a_num;a_bs_mota pht_type.a_nvar;
begin
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);

select count(*) into b_i1 from bh_sk_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ct FROM bh_sk_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_ct';
    b_nt_tien:=FKH_JS_GTRIs(dt_ct ,'nt_tien');
    b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_hl');
    PKH_JS_THAYa(dt_ct,'gio_hl',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00') );
    b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_kt');
    PKH_JS_THAYa(dt_ct,'gio_kt',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00'));
    ---
    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_cap');
    if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_cap',' '); 
    else PKH_JS_THAYa(dt_ct,'ngay_cap',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    PKH_JS_THAYa(dt_ct,'ngay_cap_s',N'Ngày ' || FBH_IN_CSO_NG(b_i1,'DD') || N' tháng ' || FBH_IN_CSO_NG(b_i1,'MM')
    || N' năm ' || FBH_IN_CSO_NG(b_i1,'YYYY'));
    
    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_hl');
    if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_hl',' '); 
    else PKH_JS_THAYa(dt_ct,'ngay_hl',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_kt');
    if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_kt',' '); 
    else PKH_JS_THAYa(dt_ct,'ngay_kt',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    b_i1:= FKH_JS_GTRIn(dt_ct ,'phi');
    PKH_JS_THAY(dt_ct,'phi',FBH_CSO_TIEN(b_i1,b_nt_tien) );


    b_i1:= FKH_JS_GTRIn(dt_ct ,'thue');
    PKH_JS_THAY(dt_ct,'thue',FBH_CSO_TIEN(b_i1,b_nt_tien) );

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ttoan');
    PKH_JS_THAY(dt_ct,'ttoan',FBH_CSO_TIEN(b_i1,b_nt_tien) );
    PKH_JS_THAYa(dt_ct,'bangchu',FBH_IN_CSO_CHU(b_i1,b_nt_tien) );

    b_temp_var:= FKH_JS_GTRIs(dt_ct ,'gioi');
    if b_temp_var= 'M' and trim(b_temp_var) is not null then PKH_JS_THAY(dt_ct,'gioi', 'Nam');
    else PKH_JS_THAY(dt_ct,'gioi', N'Nữ');end if;

     b_temp_var:= FKH_JS_GTRIs(dt_ct ,'gioid');
    if b_temp_var= 'M' and trim(b_temp_var) is not null then PKH_JS_THAY(dt_ct,'gioid', 'Nam');
    else PKH_JS_THAY(dt_ct,'gioid', N'Nữ');end if;

    -- nguoi duoc bh
    if trim(FKH_JS_GTRIs(dt_ct ,'ng_dd')) is null THEN
      PKH_JS_THAY(dt_ct,'ng_dd',FKH_JS_GTRIs(dt_ct ,'ten'));
      PKH_JS_THAY(dt_ct,'cmtd',FKH_JS_GTRIs(dt_ct ,'cmt'));
      PKH_JS_THAY(dt_ct,'mobid',FKH_JS_GTRIs(dt_ct ,'mobi'));
      PKH_JS_THAY(dt_ct,'emaild',FKH_JS_GTRIs(dt_ct ,'email'));
      PKH_JS_THAY(dt_ct,'dchid',FKH_JS_GTRIs(dt_ct ,'dchi'));
      PKH_JS_THAY(dt_ct,'gioid',FKH_JS_GTRIs(dt_ct ,'gioi'));
      PKH_JS_THAY(dt_ct,'dchid',FKH_JS_GTRIs(dt_ct ,'dchi'));
      PKH_JS_THAY(dt_ct,'ng_sinhd',FKH_JS_GTRIs(dt_ct ,'ng_sinh'));
    end if;
    --goi
    b_temp_var:= FKH_JS_GTRIs(dt_ct ,'goi');
    if trim(b_temp_var) is not null then
      select count(*) into b_i1 from bh_sk_goi where ma  = b_temp_var;
      if b_i1 <> 0 then select ten into b_temp_nvar from bh_sk_goi where ma  = b_temp_var;end if;
      PKH_JS_THAY(dt_ct,'goi',b_temp_nvar);
    end if;
	 -- lay ten dvi
    select count(*) into b_i1 from  ht_ma_dvi where ma = b_ma_dvi;
    if b_i1 <> 0 then
       select ten,kvuc into b_ten_dvi,b_ma_kvuc from ht_ma_dvi where ma = b_ma_dvi;
    end if;
    if trim(b_ma_kvuc) is not null then
      select count(*) into b_i1 from  bh_ma_kvuc where ma = b_ma_kvuc;
      if b_i1 <> 0 then
        select ten into b_ten_kvuc from bh_ma_kvuc where ma = b_ma_kvuc;
      end if;
    end if;
    PKH_JS_THAYa(dt_ct,'ten_kvuc',b_ten_kvuc);
end if;

--tt dvi
    select json_object('ten_gon' value  NVL(ten_gon,' '),'ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
           'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
               from ht_ma_dvi where ma=b_ma_dvi;
    dt_ct:=FKH_JS_BONH(dt_ct);
    b_dvi:=FKH_JS_BONH(b_dvi);
    select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;
--tpa
  b_temp_var:= FKH_JS_GTRIs(dt_ct,'tpa');
  if trim(b_temp_var) is not null then
  select count(*) into b_i1 from bh_ma_gdinh where ma=b_temp_var;
  if b_i1 <> 0 then
  select json_object('ten_tpa' value  NVL(ten,' '),'dchi_tpa' value NVL(dchi,' '),'mobi_tpa' value NVL(mobi,' '),'email_tpa' value NVL(email,' ')
    returning clob) into b_temp_clob from bh_ma_gdinh where ma=b_temp_var;
  else
    select json_object('ten_tpa' value ' ','dchi_tpa' value ' ','mobi_tpa' value ' ','email_tpa' value ' '
    returning clob) into b_temp_clob from dual;
  end if;
  select json_mergepatch(dt_ct,b_temp_clob) into dt_ct from dual;
  end if;
-----dt_ds
select count(*) into b_i1 from bh_sk_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ds';
if b_i1 <> 0 then
  delete temp_1;commit;
  SELECT FKH_JS_BONH(t.txt) INTO dt_ds FROM bh_sk_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ds';
  b_lenh:=FKH_JS_LENH('ten,ten_nh,ng_sinh,cmt,email,mobi,dchi');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_ten,a_ds_nhom,a_ds_ng_sinh,a_ds_cmt,a_ds_email,a_ds_mobi,a_ds_dchi  using dt_ds;
  for b_lp in 1..a_ds_ten.count loop
    insert into temp_1(c1,c2,c3,c4,c5,c6,c7) values(a_ds_ten(b_lp),a_ds_nhom(b_lp),FBH_IN_CSO_NG(a_ds_ng_sinh(b_lp),'DD/MM/YYYY'),a_ds_cmt(b_lp),a_ds_email(b_lp),a_ds_mobi(b_lp),a_ds_dchi(b_lp));
  end loop;
  select JSON_ARRAYAGG(json_object('STT' VALUE rownum, 'ten' value c1,'ten_nh' value c2,'ng_sinh' value c3,'cmt' value c4,'email' value c5,'mobi' value c6,'dchi' value c7 returning clob) returning clob) into dt_ds from temp_1;

  delete temp_1;commit;
end if;
---thong tin thanh toan
delete temp_4;commit;
select count(*) into b_i1 from bh_sk_tt where ma_dvi = b_ma_dvi and so_id = b_so_id;
PKH_JS_THAYa(dt_ct,'so_ky_tt',b_i1);
if  b_i1 = 1 then
    select min(ngay) into b_ngay_tt from bh_sk_tt where ma_dvi = b_ma_dvi and so_id = b_so_id;
    PKH_JS_THAYa(dt_ct,'thoi_han_tt',N'Thời hạn thanh toán phí bảo hiểm: thanh toán trước ngày '|| FBH_IN_CSO_NG(b_ngay_tt,'DD/MM/YYYY'));
elsif b_i1 > 1 then
    PKH_JS_THAYa(dt_ct,'thoi_han_tt',N'Thời hạn thanh toán phí bảo hiểm:');
    b_i1:= 1;
    for r_lp in (select ngay,tien from bh_sk_tt where ma_dvi = b_ma_dvi and so_id = b_so_id order by ngay asc)
    loop
    insert into temp_4(C1) values(N'-   Kỳ ' || b_i1 || N': thanh toán ' || FBH_CSO_TIEN(r_lp.tien,FKH_JS_GTRIs(dt_ct,'nt_tien')) || N' trước ngày ' || FBH_IN_CSO_NG(r_lp.ngay,'DD/MM/YYYY'));
    b_i1:= b_i1 + 1;
    end loop;
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_tt from temp_4;
delete temp_4;commit;
--end dong

-----dt_nh
select count(*) into b_i1 from bh_sk_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_nh';
if b_i1 <> 0 then
    delete temp_1;delete temp_2;delete temp_3;commit;
    SELECT FKH_JS_BONH(t.txt) INTO dt_nh FROM bh_sk_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_nh';
    b_lenh:=FKH_JS_LENHc('dt_nh_ct,dt_nh_dk,dt_nh_dkbs,dt_nh_lt,dt_nh_khd,dt_nh_kbt,dt_nh_cho,dt_nh_bvi,dt_nh_ttt');
    EXECUTE IMMEDIATE b_lenh bulk collect into dt_nh_ct,dt_nh_dk,dt_nh_dkbs,dt_nh_lt,dt_nh_khd,dt_nh_kbt,dt_nh_cho,dt_nh_bvi,dt_nh_ttt using dt_nh;

    --lay ra so nhom > dt_ct
    PKH_JS_THAY(dt_ct,'so_nhom',dt_nh_ct.count);
    for b_lp in 1..dt_nh_ct.count loop
      b_lenh:=FKH_JS_LENH('ma,ten,tien,ptb,phi,ma_dk');
      EXECUTE IMMEDIATE b_lenh bulk collect into a_dk_ma,a_dk_ten,a_dk_tien,a_dk_ptb,a_dk_phi,a_dk_ma_dk  using dt_nh_dk(b_lp);
      b_i1:=0;b_i2:=0;b_i3:= 0;
      for b_lp1 in 1..a_dk_ma.count loop
          if trim(a_dk_ma_dk(b_lp1)) is not null then
            insert into temp_1(c1,c2,c3,c4,c5) values(FKH_JS_GTRIs(dt_nh_ct(b_lp) ,'ten'), a_dk_ten(b_lp1),FBH_CSO_TIEN_KNT(a_dk_tien(b_lp1)),
            FBH_TO_CHAR(a_dk_ptb(b_lp1)),FBH_CSO_TIEN_KNT(a_dk_phi(b_lp1))
            );
          b_i1:=b_i1 + a_dk_tien(b_lp1);
          b_i2:=b_i2 + a_dk_ptb(b_lp1);
          b_i3:=b_i3 + a_dk_phi(b_lp1);
          end if;
      end loop;
      insert into temp_2(c1,c2) values(FKH_JS_GTRIs(dt_nh_ct(b_lp) ,'ten'),FKH_JS_GTRIn(dt_nh_ct(b_lp) ,'so_dt'));
      insert into temp_1(c1,c2,c3,c4,c5) values('',N'Tổng cộng',FBH_CSO_TIEN_KNT(b_i1),FBH_TO_CHAR(b_i2),FBH_CSO_TIEN_KNT(b_i3));
    end loop;
    select JSON_ARRAYAGG(json_object('nhom' value c1, 'ten' value c2,'tien' value c3,'pt' value c4,'phi' value c5 returning clob) returning clob) into dt_nhom from temp_1;
    select JSON_ARRAYAGG(json_object('nhom' value c1, 'so_dt' value c2 returning clob) returning clob) into dt_lt from temp_2;
    delete temp_2;commit;
    --dk
    if dt_nh_dk.count <> 0 then
      b_lenh:=FKH_JS_LENH('ma,ten,tien,mota,cap');
      EXECUTE IMMEDIATE b_lenh bulk collect into a_dk_ma,a_dk_ten,a_dk_tien,a_dk_mota,a_dk_cap  using dt_nh_dk(1);
      delete temp_4;commit;
       b_i2:=0;
      for b_lp in 1..a_dk_ma.count loop
        if a_dk_cap(b_lp) > 1 then
            if  INSTR(a_dk_ma(b_lp), 'BS') <> 0 then
              insert into temp_3(c1,c2) values(a_dk_ma(b_lp), a_dk_ten(b_lp));
            else
              if a_dk_cap(b_lp) = 2 then
              ---update cho ma có cap 2 truoc do
                select count(*) into b_i1 from temp_4 where c1 = b_temp_var;
                if b_i1 <> 0 then 
                  update temp_4 set cl1 = b_temp_clob where c1 = b_temp_var;
                end if;
              ---insert cap = 2
                insert into temp_4(c1,c2) values(a_dk_ma(b_lp), a_dk_ten(b_lp));
                b_temp_var:= a_dk_ma(b_lp);b_temp_clob:= ' ';b_i2:= 0;
              else
                if b_i2 <> 0 then b_temp_clob:= b_temp_clob || CHR(10);end if;
                b_temp_clob:= b_temp_clob ||  a_dk_ten(b_lp);
                b_i2:= b_i2 + 1;
              end if;
            end if;
        end if;
      end loop;
       ---update cho ma có cap 2 sau cùng
        select count(*) into b_i1 from temp_4 where c1 = b_temp_var;
        if b_i1 <> 0 then 
          update temp_4 set cl1 = b_temp_clob where c1 = b_temp_var;
        end if;
      select JSON_ARRAYAGG(json_object('ten' value c2, 'dk' value cl1 returning clob) returning clob) into dt_dk from temp_4;
    end if;
       -- dieu khoan bo sung
    delete temp_4;commit;
    if dt_nh_dkbs.count <> 0 then
      dt_dkbs:= dt_nh_dkbs(1);
    end if;
    select JSON_ARRAYAGG(json_object('ma' VALUE c1,'ten' value c2 returning clob) returning clob) into dt_bs from temp_3;

    delete temp_1; delete temp_2;delete temp_3;delete temp_4;commit;
end if;
-- thon tin thoi gian cho
b_lenh:=FKH_JS_LENH('ten,so_ngay');
EXECUTE IMMEDIATE b_lenh bulk collect into a_cho_ten,a_cho_sn  using dt_nh_cho(1);
delete temp_1;commit;
for b_lp in 1..a_cho_ten.count loop
  b_temp_nvar:= case when a_cho_sn(b_lp) > 0 then a_cho_sn(b_lp) || N' ngày'  else ' ' end;
  insert into temp_1(c1) values(a_cho_ten(b_lp) || ': ' || b_temp_nvar );
end loop;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_cho from temp_1;
delete temp_1;commit;

select json_object('dt_ct' value dt_ct,'dt_dk' value dt_dk,
'dt_qt' value dt_qt,'dt_bs' value dt_bs,'dt_kbt' value dt_kbt,
'dt_ttt' value dt_ttt,'dt_lt' value dt_lt,'dt_dong' value dt_dong,'dt_tt' value dt_tt,'dt_hu' value dt_hu,'dt_nhom' value dt_nhom,
'dt_ds' value dt_ds,'dt_cho' value dt_cho,'dt_dkbs' value dt_dkbs returning clob) into b_oraOut from dual;


exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;

