-------------start new version
create or replace procedure PBH_SK_IN_GCNTN(
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
    b_kh_ttt clob;dt_qt clob;dt_tt clob;b_dvi clob;dt_hu clob;

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

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ng_sinh');
    if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ng_sinh',' '); 
    else PKH_JS_THAYa(dt_ct,'ng_sinh',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ng_sinhd');
    if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ng_sinhd',' '); 
    else PKH_JS_THAYa(dt_ct,'ng_sinhd',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;
    -- nguoi duoc bh
    if trim(FKH_JS_GTRIs(dt_ct ,'tend')) is null THEN
      PKH_JS_THAY(dt_ct,'tend',FKH_JS_GTRIs(dt_ct ,'ten'));
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
    PKH_JS_THAY(dt_ct,'ten_kvuc',b_ten_kvuc);

 
end if;

--tt dvi
    select json_object('ten_gon' value  NVL(ten_gon,' '),'ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
           'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
               from ht_ma_dvi where ma=b_ma_dvi;
    dt_ct:=FKH_JS_BONH(dt_ct);
    b_dvi:=FKH_JS_BONH(b_dvi);
    select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;


--bs
select count(*) into b_i1 from bh_sk_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_dkbs';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_bs FROM bh_sk_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_dkbs';
  b_lenh := FKH_JS_LENH('ma,ten,tien,phi,cap,kieu,lkeb');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_dk_ma,a_dk_ten,a_dk_tien,a_dk_phi,a_dk_cap,a_dk_kieu,a_dk_lkeb USING dt_bs;
  delete temp_1;commit;
  for b_lp in 1..a_dk_ma.count loop
      b_temp_var:= case when a_dk_tien(b_lp) <> 0 then  FBH_CSO_TIEN(a_dk_tien(b_lp),b_nt_tien) else ' ' end;
      insert into temp_1(c1,c2,c3,c4,c5) values(a_dk_ma(b_lp),a_dk_ten(b_lp),b_temp_var,a_dk_kieu(b_lp),a_dk_cap(b_lp));
  end loop;
  select JSON_ARRAYAGG(json_object('ma' VALUE rownum,'ten' value c2, 'tien' value c3,'gioi_han' value c4,'cap' value c5 returning clob) returning clob) into dt_bs from temp_1;
end if;
-- lay dt_dk
select count(*) into b_i1 from bh_sk_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_dk';
if b_i1 <> 0 then
    SELECT FKH_JS_BONH(t.txt) INTO dt_dk FROM bh_sk_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_dk';
     b_lenh := FKH_JS_LENH('ma,ten,tien,phi,cap,kieu,lkeb');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_dk_ma,a_dk_ten,a_dk_tien,a_dk_phi,a_dk_cap,a_dk_kieu,a_dk_lkeb USING dt_dk;
    delete temp_1;delete temp_2;commit;
      b_i2:= 1;
      for b_lp in 1..a_dk_ma.count loop
        if a_dk_cap(b_lp) > 1 then
          if a_dk_cap(b_lp) > 2 then a_dk_ma(b_lp):= ' '; end if;
          if a_dk_kieu(b_lp) = 'N' then
            if  a_dk_tien(b_lp) < 1000 then
              a_dk_kieu(b_lp):= N'Giới hạn/năm'; 
            else
              a_dk_kieu(b_lp):= N'Giới hạn/ngày'; 
            end if;
          elsif a_dk_kieu(b_lp) = 'L' then
            a_dk_kieu(b_lp):= N'Giới hạn/lần'; 
          elsif a_dk_kieu(b_lp) = 'T' then
            a_dk_kieu(b_lp):= N'Giới hạn/năm'; 
          end if;
          b_temp_var:= case when a_dk_tien(b_lp) < 1000 then to_char(a_dk_tien(b_lp)) else FBH_CSO_TIEN(a_dk_tien(b_lp),b_nt_tien) end;
          if a_dk_lkeb(b_lp) = 'B' then b_temp_var:= N'Theo Bảng tỉ lệ thương tật';
          elsif a_dk_lkeb(b_lp) = 'P' then b_temp_var:= N'Theo Bảng tỉ lệ phẫu thuật';end if;
          if  INSTR(a_dk_ma(b_lp), 'BS') <> 0 then
            insert into temp_2(c1,c2,c3,c4,c5) values(a_dk_ma(b_lp),a_dk_ten(b_lp),b_temp_var,a_dk_kieu(b_lp),a_dk_cap(b_lp));
            if a_dk_ma(b_lp) in ('BS1','BS2','BS3') then
                PKH_JS_THAY(dt_ct,a_dk_ma(b_lp),'X');
            end if;
          else
            if a_dk_cap(b_lp) = 2 then
              b_temp_nvar:= to_char(b_i2);
              b_i2:= b_i2 +1;
            elsif a_dk_cap(b_lp) > 2 then b_temp_nvar:= ' ';
            end if;
            insert into temp_1(c1,c2,c3,c4,c5) values(b_temp_nvar,a_dk_ten(b_lp),b_temp_var,a_dk_kieu(b_lp),a_dk_cap(b_lp));
          end if;
        end if;
      end loop;
    select JSON_ARRAYAGG(json_object('ma' VALUE c1,'ten' value c2, 'tien' value c3,'gioi_han' value c4,'cap' value c5 returning clob) returning clob) into dt_dk from temp_1;
    select JSON_ARRAYAGG(json_object('ma' VALUE rownum,'ten' value c2, 'tien' value c3,'gioi_han' value c4,'cap' value c5 returning clob) returning clob) into dt_lt from temp_2;
    delete temp_1;delete temp_2;commit;
end if;

---thong tin thanh toan
delete temp_4;
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
delete temp_4;


--end dong
select json_object('dt_ct' value dt_ct,'dt_dk' value dt_dk,
'dt_qt' value dt_qt,'dt_bs' value dt_bs,'dt_kbt' value dt_kbt,
'dt_ttt' value dt_ttt,'dt_lt' value dt_lt,'dt_dong' value dt_dong,'dt_tt' value dt_tt,'dt_hu' value dt_hu returning clob) into b_oraOut from dual;

commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
/
create or replace procedure PBH_SKC_INHC(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    -- chung
    b_loi varchar2(100); b_lenh varchar2(1000);b_i1 number;b_i2 number;
    b_count_roman number := 0;
    -- orain
    b_so_hd varchar2(50) :=FKH_JS_GTRIs(b_oraIn,'so_hd');
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
    -- truong table to json
	
    b_temp_var varchar2(100);b_temp_nvar varchar2(500);
    b_temp_clob clob;a_clob pht_type.a_clob;
	
    dk_ma pht_type.a_var; dk_kbt pht_type.a_var;
    dk_lt_ma pht_type.a_var; dk_lt_ten pht_type.a_var;
    -- truong out
    dt_ct clob; dt_dk clob;dt_bs clob;dt_kbt clob;dt_lt clob;dt_dong clob;dt_tt clob;dt_hu clob;
    dt_cho clob;
	  dt_tb1 clob;dt_tb2 clob;dt_tb3 clob;dt_tb4 clob; 
	  
    b_ngay_tt number;
    b_nt_tien varchar2(10);
    
    ma_lt pht_type.a_var;b_nd_lt clob;

    --tgian cho
    a_cho_ten pht_type.a_nvar;a_cho_sn pht_type.a_num;
    --a dt_dk
    a_dk_ma pht_type.a_var;a_dk_ten pht_type.a_nvar; a_dk_tien pht_type.a_num;a_dk_phi pht_type.a_num;
    a_dk_cap pht_type.a_num;a_dk_kieu pht_type.a_var;a_dk_lkeb pht_type.a_var;
    a_dk_mota pht_type.a_nvar;
begin
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);

SELECT FKH_JS_BONH(t.txt) into b_temp_clob FROM bh_sk_sp t, bh_sk t1 WHERE t.ma = t1.ma_sp and t1.so_id=b_so_id;
if b_temp_clob <> null or b_temp_clob!= '' then
  b_lenh := FKH_JS_LENH('qtac');
  EXECUTE IMMEDIATE b_lenh INTO b_temp_var USING b_temp_clob;
end if;
IF trim(b_temp_var) IS NOT NULL THEN
  SELECT t.TEN into b_temp_nvar FROM bh_ma_qtac t WHERE t.ma=b_temp_var;
END IF;

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

-- dt_dkbs
select count(*) into b_i1 from bh_sk_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_dkbs';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_bs
       FROM bh_sk_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_dkbs';
end if;

-- lay dk
select count(*) into b_i1 from bh_sk_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_dk';
if b_i1 <> 0 then
  select FKH_JS_BONH(t.txt) into dt_dk from bh_sk_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_dk';

  b_lenh:=FKH_JS_LENH('ma,ten,tien,mota,cap');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_dk_ma,a_dk_ten,a_dk_tien,a_dk_mota,a_dk_cap  using dt_dk;

  delete temp_1;commit;
  b_i1:=1;b_i2 := 1;
  b_temp_var:= 'I';
  b_count_roman := 0;
  for b_lp in 1..a_dk_ma.count loop
      if a_dk_cap(b_lp) = 1 then
        if b_count_roman = 0 then b_temp_var := 'I'; else b_temp_var := FBH_ROMAN_NEXT(b_temp_var); end if;
        insert into temp_1(c1,c2,c3,n1,n2) values(b_temp_var,a_dk_ten(b_lp),FBH_CSO_TIEN(a_dk_tien(b_lp),''),a_dk_cap(b_lp),b_i2);
        b_count_roman := b_count_roman + 1;
      elsif a_dk_cap(b_lp) = 3 then
        insert into temp_1(c1,c2,c3,n1,n2) values(to_char(b_i1),a_dk_ten(b_lp),FBH_CSO_TIEN(a_dk_tien(b_lp),''),a_dk_cap(b_lp),b_i2);
        b_i1 := b_i1 + 1;
      else
        insert into temp_1(c1,c2,c3,n1,n2) values(' ',a_dk_ten(b_lp),FBH_CSO_TIEN(a_dk_tien(b_lp),''),a_dk_cap(b_lp),b_i2);
      end if;

      if a_dk_cap(b_lp) < 3 then b_i1:= 1; end if;
      b_i2 := b_i2 + 1;
  end loop;

  select JSON_ARRAYAGG(json_object('ma' VALUE c1,'ten' value c2,'tien' value c3,'cap' value n1 returning clob) returning clob) into dt_dk 
    from temp_1 order by n2;
  delete temp_1;commit;
end if;

-- lay dt_ct
select count(*) into b_i1 from bh_sk_txt where so_id = b_so_id and ma_dvi = b_ma_dvi and loai = 'dt_ct';
if b_i1 <> 0 then
  select txt into dt_ct from bh_sk_txt where so_id = b_so_id and ma_dvi = b_ma_dvi and loai = 'dt_ct';
   ---
  b_nt_tien:=FKH_JS_GTRIs(dt_ct ,'nt_tien');
  b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_hl');
  PKH_JS_THAYa(dt_ct,'gio_hl',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00') );
  b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_kt');
  PKH_JS_THAYa(dt_ct,'gio_kt',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00'));

  b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_cap');
  if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_cap',' '); 
  else PKH_JS_THAYa(dt_ct,'ngay_cap',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

  PKH_JS_THAYa(dt_ct,'ngay_cap_s',N'Ngày ' || FBH_IN_CSO_NG(b_i1,'DD') || N' tháng ' || FBH_IN_CSO_NG(b_i1,'MM')
  || N' năm ' || FBH_IN_CSO_NG(b_i1,'YYYY'));
  
  b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_hl');
  if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_hl',' '); 
  else PKH_JS_THAYa(dt_ct,'ngay_hl',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

  PKH_JS_THAYa(dt_ct,'ngay_hl_s',N'ngày ' || FBH_IN_CSO_NG(b_i1,'DD') || N' tháng ' || FBH_IN_CSO_NG(b_i1,'MM')
  || N' năm ' || FBH_IN_CSO_NG(b_i1,'YYYY'));

  b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_kt');
  if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_kt',' '); 
  else PKH_JS_THAYa(dt_ct,'ngay_kt',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

  PKH_JS_THAYa(dt_ct,'ngay_kt_s',N'ngày ' || FBH_IN_CSO_NG(b_i1,'DD') || N' tháng ' || FBH_IN_CSO_NG(b_i1,'MM')
  || N' năm ' || FBH_IN_CSO_NG(b_i1,'YYYY'));

  b_i1:= FKH_JS_GTRIn(dt_ct ,'phi');
  PKH_JS_THAY(dt_ct,'phi',FBH_CSO_TIEN(b_i1,N'đồng') );

  b_i1:= FKH_JS_GTRIn(dt_ct ,'gia');
  PKH_JS_THAY(dt_ct,'gia',FBH_CSO_TIEN(b_i1,N'đồng') );

  b_i1:= FKH_JS_GTRIn(dt_ct ,'thue');
  PKH_JS_THAY(dt_ct,'thue',FBH_CSO_TIEN(b_i1,N'đồng') );

  b_i1:= FKH_JS_GTRIn(dt_ct ,'ttoan');
  PKH_JS_THAY(dt_ct,'ttoan',FBH_CSO_TIEN(b_i1,N'đồng') );
  PKH_JS_THAYa(dt_ct,'bangchu',FBH_IN_CSO_CHU(b_i1,b_nt_tien) );

  b_i1:= FKH_JS_GTRIn(dt_ct ,'ng_sinhd');
  if b_i1 = 30000101 then PKH_JS_THAY_D(dt_ct,'ng_sinhd',' '); 
  else PKH_JS_THAYa(dt_ct,'ng_sinhd',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

  b_i1:= FKH_JS_GTRIn(dt_ct ,'ng_sinh');
  if b_i1 = 30000101 then PKH_JS_THAY_D(dt_ct,'ng_sinh',' '); 
  else PKH_JS_THAYa(dt_ct,'ng_sinh',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

  b_temp_var:= FKH_JS_GTRIs(dt_ct ,'gioi');
  if b_temp_var= 'M' and trim(b_temp_var) is not null then PKH_JS_THAY(dt_ct,'gioi', 'Nam');
  else PKH_JS_THAY(dt_ct,'gioi', N'Nữ');end if;
  
     --lay ten nghe
  PKH_JS_THAYa(dt_ct,'nghed_ten',' ');
  b_temp_var:= FKH_JS_GTRIs(dt_ct,'nghed');
  if trim(b_temp_var) is not null then
    select count(*) into b_i1  from bh_ma_nghe where ma=b_temp_var;
    if b_i1 <> 0 then
      select NVL(ten,' ') into b_temp_nvar  from bh_ma_nghe where ma=b_temp_var;
      PKH_JS_THAYa(dt_ct,'nghed_ten',b_temp_nvar);
    end if;
  end if;
   --lay gioi tinh
  b_temp_var:= FKH_JS_GTRIs(dt_ct ,'gioid');
  if b_temp_var= 'M' and trim(b_temp_var) is not null then PKH_JS_THAY(dt_ct,'gioid', 'Nam');
  else PKH_JS_THAY(dt_ct,'gioid', N'Nữ');end if;

  if trim(FKH_JS_GTRIs(dt_ct ,'tend')) is null then
      PKH_JS_THAY_D(dt_ct,'tend', FKH_JS_GTRIs(dt_ct ,'ten'));
      PKH_JS_THAY_D(dt_ct,'cmtd', FKH_JS_GTRIs(dt_ct ,'cmt'));
      PKH_JS_THAY_D(dt_ct,'mobid', FKH_JS_GTRIs(dt_ct ,'mobi'));
      PKH_JS_THAY_D(dt_ct,'emaild', FKH_JS_GTRIs(dt_ct ,'email'));
      PKH_JS_THAY_D(dt_ct,'dchid', FKH_JS_GTRIs(dt_ct ,'dchi'));
      PKH_JS_THAY_D(dt_ct,'gioid', FKH_JS_GTRIs(dt_ct ,'gioi'));
      PKH_JS_THAY_D(dt_ct,'ng_sinhd', FKH_JS_GTRIs(dt_ct ,'ng_sinh'));
  end if;
  --lay thon tin tpa
  b_temp_var:= FKH_JS_GTRIs(dt_ct,'tpa');
  if trim(b_temp_var) is not null then
    select count(*) into b_i1  from bh_ma_gdinh where ma=b_temp_var;
    if b_i1 <> 0 then
        select json_object('dv_ten' value  NVL(ten,' '),'dv_dchi' value NVL(dchi,' '),'dv_email' value NVL(email,' '),'dv_mobi' value NVL(mobi,' ')
         returning clob) into b_temp_clob from bh_ma_gdinh where ma=b_temp_var;

        dt_ct:=FKH_JS_BONH(dt_ct);
        b_temp_clob:=FKH_JS_BONH(b_temp_clob);
        select json_mergepatch(dt_ct,b_temp_clob) into dt_ct from dual;
    end if;
  end if;

--tt dvi
  select json_object('ten_gon' value  NVL(ten_gon,' '),'ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
          'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_temp_clob
              from ht_ma_dvi where ma=b_ma_dvi;
  dt_ct:=FKH_JS_BONH(dt_ct);
  b_temp_clob:=FKH_JS_BONH(b_temp_clob);
  select json_mergepatch(dt_ct,b_temp_clob) into dt_ct from dual;
  --ten goi
  b_temp_nvar:=FKH_JS_GTRIs(dt_ct,'goi');
  if trim(b_temp_nvar) is not null then
    b_temp_nvar:= FBH_IN_SUBSTR(b_temp_nvar,'|','S');
  end if;
  PKH_JS_THAYa(dt_ct,'ten_goi',b_temp_nvar);
end if;

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

-- thon tin thoi gian cho
select count(*) into b_i1 from bh_sk_kbt where so_id = b_so_id and ma_dvi = b_ma_dvi and loai = 'dt_cho';
if b_i1 <> 0 then
  select txt into dt_cho from bh_sk_kbt where so_id = b_so_id and ma_dvi = b_ma_dvi and loai = 'dt_cho';

  b_lenh:=FKH_JS_LENH('ten,so_ngay');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_cho_ten,a_cho_sn  using dt_cho;
  delete temp_1;commit;
  for b_lp in 1..a_cho_ten.count loop
    b_temp_nvar:= case when a_cho_sn(b_lp) > 0 then a_cho_sn(b_lp) || N' ngày'  else ' ' end;
    insert into temp_1(c1) values(a_cho_ten(b_lp) || ': ' || b_temp_nvar );
  end loop;
  select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_tb1 from temp_1;
  delete temp_1;commit;
end if;
--dt_ct,dt_dk,dt_bs,dt_kbt,dt_lt,dt_dong,dt_tt,dt_hu,dt_tb1,dt_tb2,dt_tb3,dt_tb4
select json_object('dt_ct' value dt_ct,
  'dt_dk' value dt_dk,
  'dt_bs' value dt_bs, 
  'dt_kbt' value dt_kbt,'dt_lt' value dt_lt,
  'dt_dong' value dt_dong,'dt_tt' value dt_tt,
  'dt_hu' value dt_hu,'dt_tb1' value dt_tb1,'dt_tb2' value dt_tb2,'dt_tb3' value dt_tb3,'dt_tb4' value dt_tb4  returning clob) into b_oraOut from dual;

COMMIT;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;