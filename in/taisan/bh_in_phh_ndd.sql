create or replace procedure PBH_PHH_IN_HD_NDD(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    -- chung
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_i1 number := 0;b_i2 number:=0;b_i3 number:=0;
    -- orain
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
    b_so_id_dt number;

    dt_ct clob; dt_dkbs clob; dt_ds clob;dt_lt clob; dt_ttt clob;dt_dong clob;
    b_kh_ttt clob;dt_qt clob;dt_tt clob;b_dvi clob;dt_hk clob;dt_dd clob;

    ds_ct clob;ds_pvi clob;ds_dk clob;ds_dkbs clob;ds_lt clob;ds_dkth clob;ds_kbt clob;ds_ttt clob;

    dt_pvi clob;dt_dt clob;dt_kbt clob;dt_dk clob;
    a_dt_pvi_clob pht_type.a_clob;a_dt_dt_clob pht_type.a_clob;a_dt_kbt_clob pht_type.a_clob;a_dt_dk_clob pht_type.a_clob;
    ds_dd clob;
    
    b_temp_clob clob;a_clob pht_type.a_clob;

    b_temp_var varchar2(100);b_temp_nvar varchar2(500);

    b_ma_kvuc varchar2(20);b_ten_kvuc nvarchar2(500):= ' ';
    b_nt_tien varchar2(50);b_nt_phi varchar2(50);

    b_ma_kt varchar2(50);b_kieu_kt varchar2(1);b_ngay_tt number;
    b_ng_ddb nvarchar2(500):= ' ';
    b_ng_dd nvarchar2(500):= ' ';
    ---kbt
    a_kbt_ma_dk pht_type.a_var; a_kbt_kbt pht_type.a_nvar;
    a_kbt_nd pht_type.a_var; a_kbt_ma pht_type.a_nvar;

    --a dt_dk
    a_dk_ma pht_type.a_var;a_dk_ten pht_type.a_nvar; a_dk_tien pht_type.a_num;a_dk_tienkb pht_type.a_num;
    a_dk_phi pht_type.a_num;a_dk_thue pht_type.a_num;
    a_dk_cap pht_type.a_num;a_dk_gvu pht_type.a_var;a_dk_ma_ct pht_type.a_var;a_dk_kieu pht_type.a_var;
    a_dk_mota pht_type.a_nvar;
    --a dt_hk
    a_hu_ten pht_type.a_nvar;a_hu_cmt pht_type.a_var; a_hu_mobi pht_type.a_var;a_hu_email pht_type.a_var;
    a_hu_dchi pht_type.a_nvar;a_hu_ng_ddien pht_type.a_nvar;a_hu_chucvu pht_type.a_nvar;
    -- a_pvi
    a_pvbh_ma pht_type.a_var; a_pvbh_ten pht_type.a_nvar;a_pvbh_tc pht_type.a_var;a_pvbh_ktru pht_type.a_var;
    a_pvbh_loai pht_type.a_var;a_pvbh_ma_ct pht_type.a_var;
    a_pvbh_ma_dk pht_type.a_var;a_pvbh_ma_dk_ten pht_type.a_nvar;a_pvbh_ma_qtac pht_type.a_var;a_pvbh_ma_qtac_ten pht_type.a_nvar;
    a_pvbh_pttsb pht_type.a_var;a_pvbh_ptts pht_type.a_var;a_pvbh_ptkhb pht_type.a_var;a_pvbh_ppkh pht_type.a_var;a_pvbh_ptkh pht_type.a_var;
    a_pvbh_ppts pht_type.a_var;
    -- a_dkbs
    a_ten pht_type.a_nvar;a_ma pht_type.a_var;a_ma_dkc pht_type.a_var;a_dkp pht_type.a_nvar;
    ---
    dt_bs_chung clob;dt_bs_vc clob;dt_bs_gdkd clob;dt_dk_v clob;dt_dk_g clob;
    ---
    b_tlp_bb number:=0;b_tlp_rr number:=0;b_tlp_g number:=0;
    b_phi_bb number:=0;b_phi_rr number:=0;b_phi_g number:=0;
    b_tong_tien_v number:= 0;b_tong_tien_g number:=0;b_tien_hh number:=0;
    --mkt
    b_mkt_b clob;b_mkt_c clob;b_mkt_p clob;b_mkt_m clob;

    --a dong bh
    dt_dong_bh clob;dt_check_dong clob;
    a_dong_nha_bh pht_type.a_nvar;a_dong_pt pht_type.a_num;a_dong_tien pht_type.a_num;a_dong_phi pht_type.a_num;
    -- bien check
    b_pvi_m boolean := false;b_pvi_kh boolean := false;
begin
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);

--dt_hk
select count(*) into b_i1 from bh_phh_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_hk';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_hk FROM bh_phh_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_hk';
  b_lenh := FKH_JS_LENH('ten,cmt,mobi,email,dchi,ng_ddien,chucvu');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_hu_ten,a_hu_cmt,a_hu_mobi,a_hu_email,a_hu_dchi,a_hu_ng_ddien,a_hu_chucvu USING dt_hk;
  delete temp_2;commit;
  b_i1:= 1;
  for b_lp in 1..a_hu_ten.count loop
    if a_hu_ten.count = 1 then
      b_temp_nvar := N'NGƯỜI THỤ HƯỞNG ' || ': ' || a_hu_ten(b_lp);
    else
      b_temp_nvar:= N'NGƯỜI THỤ HƯỞNG THỨ ' || FBH_IN_SO_CHU(b_i1) || ': ' || a_hu_ten(b_lp);
    end if;
    insert into temp_2(C1,c2,c3,c4,c5,c6,c7) values(b_temp_nvar,a_hu_cmt(b_lp),a_hu_mobi(b_lp),a_hu_email(b_lp),a_hu_dchi(b_lp),a_hu_ng_ddien(b_lp),a_hu_chucvu(b_lp));
    b_i1:= b_i1 +1;
  end loop;
  select JSON_ARRAYAGG(json_object('ten' VALUE C1,'cmt' VALUE C2,'mobi' VALUE C3,'email' VALUE C4,'dchi' VALUE C5,
  'ng_ddien' VALUE C6,'chucvu' VALUE C7  returning clob) returning clob) into dt_hk from temp_2;

  delete temp_2;commit;
end if;
--dt-ct
select count(*) into b_i1 from bh_phh_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ct FROM bh_phh_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_ct';
    b_nt_tien:=FKH_JS_GTRIs(dt_ct ,'nt_tien');
    if b_nt_tien= 'VND' then PKH_JS_THAYa(dt_ct,'nt_tien', N'Đồng');b_nt_tien:=N'đồng'; end if;

    b_nt_phi:=FKH_JS_GTRIs(dt_ct ,'nt_phi');
    if b_nt_phi= 'VND' then PKH_JS_THAYa(dt_ct,'nt_phi', N'Đồng');b_nt_phi:=N'đồng'; end if;

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
    
    b_i1:= FKH_JS_GTRIn(dt_ct ,'ng_uq');
    if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ng_uq',' '); 
    else PKH_JS_THAYa(dt_ct,'ng_uq',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;
    
    b_ng_dd := FKH_JS_GTRIs(dt_ct,'ng_dd');

    b_i1:= FKH_JS_GTRIn(dt_ct ,'phi');
    PKH_JS_THAY(dt_ct,'phi',FBH_CSO_TIEN(b_i1,b_nt_tien) );

    b_i1:= FKH_JS_GTRIn(dt_ct ,'gia');
    PKH_JS_THAY(dt_ct,'gia',FBH_CSO_TIEN(b_i1,b_nt_tien) );

    b_i1:= FKH_JS_GTRIn(dt_ct ,'thue');
    PKH_JS_THAY(dt_ct,'thue',FBH_CSO_TIEN(b_i1,b_nt_tien) );

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ttoan');
    PKH_JS_THAY(dt_ct,'ttoan',FBH_CSO_TIEN(b_i1,b_nt_tien) );
    PKH_JS_THAYa(dt_ct,'bangchu',FBH_IN_CSO_CHU(b_i1,b_nt_tien) );
 
  if trim(FKH_JS_GTRIs(dt_ct ,'tend')) is not null THEN
    if trim(FKH_JS_GTRIs(dt_ct ,'tend'))  = trim(FKH_JS_GTRIs(dt_ct ,'ten')) then
      PKH_JS_THAY_D(dt_ct,'ten','X' );
      PKH_JS_THAY_D(dt_ct,'dchi','X');
      PKH_JS_THAY_D(dt_ct,'mobi','X' );
      PKH_JS_THAY_D(dt_ct,'email','X' );
      PKH_JS_THAY_D(dt_ct,'cmt','X' );
      PKH_JS_THAY_D(dt_ct,'ma_nh','X' );
      PKH_JS_THAY_D(dt_ct,'ma_tk','X' );
    end if;
  else
      PKH_JS_THAY_D(dt_ct,'tend',FKH_JS_GTRIs(dt_ct ,'ten') );
      PKH_JS_THAY_D(dt_ct,'dchid',FKH_JS_GTRIs(dt_ct ,'dchi') );
      PKH_JS_THAY_D(dt_ct,'mobid',FKH_JS_GTRIs(dt_ct ,'mobi') );
      PKH_JS_THAY_D(dt_ct,'emaild',FKH_JS_GTRIs(dt_ct ,'email') );
      PKH_JS_THAY_D(dt_ct,'cmtd',FKH_JS_GTRIs(dt_ct ,'cmt') );
      PKH_JS_THAY_D(dt_ct,'ma_nhd',FKH_JS_GTRIs(dt_ct ,'ma_nh') );
      PKH_JS_THAY_D(dt_ct,'ma_tkd',FKH_JS_GTRIs(dt_ct ,'ma_tk') );

      PKH_JS_THAY_D(dt_ct,'ten','X' );
      PKH_JS_THAY_D(dt_ct,'dchi','X');
      PKH_JS_THAY_D(dt_ct,'mobi','X' );
      PKH_JS_THAY_D(dt_ct,'email','X' );
      PKH_JS_THAY_D(dt_ct,'cmt','X' );
      PKH_JS_THAY_D(dt_ct,'ma_nh','X' );
      PKH_JS_THAY_D(dt_ct,'ma_tk','X' );
  end if;
end if;
--lay thong tin thong ke tu khai
SELECT '{' || LISTAGG('"' || ma || '": ""', ',') WITHIN GROUP (ORDER BY ma) || '}' into b_kh_ttt 
                                                    FROM bh_kh_ttt WHERE nv = 'PHH' AND ps = 'HD';
dt_ct:=FKH_JS_BONH(dt_ct);
b_kh_ttt:=FKH_JS_BONH(b_kh_ttt);
select json_mergepatch(dt_ct,b_kh_ttt) into dt_ct from dual;
--tt dvi
select json_object('ten_gon' value  NVL(ten_gon,' '),'ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
        'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
            from ht_ma_dvi where ma=b_ma_dvi;
dt_ct:=FKH_JS_BONH(dt_ct);
b_dvi:=FKH_JS_BONH(b_dvi);
select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;
-- lay ten dvi
select count(*) into b_i1 from  ht_ma_dvi where ma = b_ma_dvi;
if b_i1 <> 0 then
    select kvuc into b_ma_kvuc from ht_ma_dvi where ma = b_ma_dvi;
end if;
if trim(b_ma_kvuc) is not null then
  select count(*) into b_i1 from bh_ma_kvuc where ma = b_ma_kvuc;
  if b_i1 <> 0 then
      select NVL(ten,' ') into b_ten_kvuc from bh_ma_kvuc where ma = b_ma_kvuc;
  end if;
end if;
PKH_JS_THAYa(dt_ct,'kvuc',b_ten_kvuc);

 PKH_JS_THAY_D(dt_ct,'pvi_m', 'X');
if b_pvi_m = true then
  PKH_JS_THAY_D(dt_ct,'pvi_m', ' ');
end if;

--ttt
select count(*) into b_i1 from bh_phh_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ttt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ttt FROM bh_phh_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ttt';
end if;
---dieu khoan bo sung
select count(*) into b_i1 from BH_PHH_DK t WHERE  t.so_id = b_so_id AND t.ma_dvi = b_ma_dvi and t.nv = 'M';
if b_i1 <> 0 then
  delete temp_1;commit;
  insert into temp_1(c1,c2,c3,c4)
    select distinct ten,ma,nv,ma_dkc from BH_PHH_DK where so_id = b_so_id and ma_dvi = b_ma_dvi and nv = 'M';
  PKH_JS_THAY_D(dt_ct,'bs_chung', 'X');
  PKH_JS_THAY_D(dt_ct,'bs_vc', 'X');
  PKH_JS_THAY_D(dt_ct,'bs_gdkd', 'X');
  select count(*) into b_i1 from temp_1 where trim(c4) is null;
  if b_i1 <> 0 then  PKH_JS_THAY_D(dt_ct,'bs_chung', ' '); end if;
  select count(*) into b_i1 from temp_1 where trim(c4) = 'THVC';
  if b_i1 <> 0 then  PKH_JS_THAY_D(dt_ct,'bs_vc', ' '); end if;
  select count(*) into b_i1 from temp_1 where trim(c4) = 'GDKD';
  if b_i1 <> 0 then  PKH_JS_THAY_D(dt_ct,'bs_gdkd', ' '); end if;

  select JSON_ARRAYAGG(json_object('TEN' VALUE c1,'MA' VALUE c2 returning clob) returning clob) into dt_bs_chung from temp_1 where trim(c4) is null;
  select JSON_ARRAYAGG(json_object('TEN' VALUE c1,'MA' VALUE c2 returning clob) returning clob) into dt_bs_vc from temp_1 where trim(c4) = 'THVC';
  select JSON_ARRAYAGG(json_object('TEN' VALUE c1,'MA' VALUE c2 returning clob) returning clob) into dt_bs_gdkd from temp_1 where trim(c4) = 'GDKD';

  for rp in (select c1,c2 from temp_1) loop
     select count(*) into b_i1 from bh_ma_dkbs where ma = rp.c2;
      if b_i1 <> 0 then
          SELECT FKH_JS_GTRIc(FKH_JS_BONH(t.txt) ,'nd') into b_temp_clob from bh_ma_dkbs t where  t.ma= rp.c2 and rownum = 1;
      end if;
      insert into temp_4(c1,c2,cl1) values(rp.c2,rp.c1,b_temp_clob);
  end loop;
  select JSON_ARRAYAGG(json_object('ma' VALUE C1,'ten' value c2, 'nd' value cl1 returning clob) returning clob) into dt_dkbs from temp_4;
end if;


---ds_pvi
select count(*) into b_i1 from bh_phh_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_pvi';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO ds_pvi FROM bh_phh_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_pvi';
  b_lenh:=FKH_JS_LENHc('');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_dt_pvi_clob using ds_pvi;
end if;
-- lay ds_kbt
select count(*) into b_i1 from bh_phh_txt t WHERE  t.so_id = b_so_id AND t.loai='ds_kbt';
if b_i1 <> 0 then
    SELECT FKH_JS_BONH(t.txt) INTO ds_kbt FROM bh_phh_txt t WHERE  t.so_id = b_so_id AND t.loai='ds_kbt';
    b_lenh:=FKH_JS_LENHc('');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_dt_kbt_clob using ds_kbt;  
end if;
-- lay ds_dk
select count(*) into b_i1 from bh_phh_txt t WHERE  t.so_id = b_so_id AND t.loai='ds_dk';
if b_i1 <> 0 then
    SELECT FKH_JS_BONH(t.txt) INTO ds_dk FROM bh_phh_txt t WHERE  t.so_id = b_so_id AND t.loai='ds_dk';
    b_lenh:=FKH_JS_LENHc('');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_dt_dk_clob using ds_dk;  
end if;


---ds_ct
select count(*) into b_i1 from bh_phh_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO ds_ct FROM bh_phh_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_ct';
  b_lenh:=FKH_JS_LENHc('');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_dt_dt_clob using ds_ct;
  delete temp_4;commit;
  b_i3 := 1;
  for b_lp1 in 1..a_dt_dt_clob.count loop
    b_tlp_bb :=0;b_tlp_rr :=0;b_tlp_g :=0;
    b_phi_bb :=0;b_phi_rr :=0;b_phi_g :=0;
    b_tong_tien_v := 0;b_tong_tien_g :=0;b_tien_hh :=0;
    ---thong tin chung
    dt_dt:= a_dt_dt_clob(b_lp1);
    PKH_JS_THAY_D(dt_dt,'count', b_i3 || N'. Địa điểm ' || b_i3);
    b_so_id_dt:= FKH_JS_GTRIn(dt_dt,'so_id_dt');

    b_temp_nvar := FKH_JS_GTRIs(dt_dt,'ma_dt');
    b_temp_nvar:= FBH_IN_SUBSTR(b_temp_nvar,'|','S');
    PKH_JS_THAY_D(dt_dt,'ma_dt',b_temp_nvar);

    b_temp_var:=FKH_JS_GTRIs(dt_dt ,'gio_hl');
    PKH_JS_THAY_D(dt_dt,'gio_hl',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00') );
    b_temp_var:=FKH_JS_GTRIs(dt_dt ,'gio_kt');
    PKH_JS_THAY_D(dt_dt,'gio_kt',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00'));
    ---
    b_i1:= FKH_JS_GTRIn(dt_dt ,'ngay_cap');
    if b_i1 = 30000101 then PKH_JS_THAY_D(dt_dt,'ngay_cap',' '); 
    else PKH_JS_THAY_D(dt_dt,'ngay_cap',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    PKH_JS_THAY_D(dt_dt,'ngay_cap_s',N'Ngày ' || FBH_IN_CSO_NG(b_i1,'DD') || N' tháng ' || FBH_IN_CSO_NG(b_i1,'MM')
    || N' năm ' || FBH_IN_CSO_NG(b_i1,'YYYY'));
    
    b_i1:= FKH_JS_GTRIn(dt_dt ,'ngay_hl');
    if b_i1 = 30000101 then PKH_JS_THAY_D(dt_dt,'ngay_hl',' '); 
    else PKH_JS_THAY_D(dt_dt,'ngay_hl',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    b_i1:= FKH_JS_GTRIn(dt_dt ,'ngay_kt');
    if b_i1 = 30000101 then PKH_JS_THAY_D(dt_dt,'ngay_kt',' '); 
    else PKH_JS_THAY_D(dt_dt,'ngay_kt',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;


    ---pvi
    dt_pvi:= a_dt_pvi_clob(b_lp1);
    if dt_pvi <> '"[]"' then
      b_lenh := FKH_JS_LENH('ten,ma,pttsb,ptts,ptkhb,ptkh,tc,ktru,loai,ma_ct,ppts,ppkh');
      EXECUTE IMMEDIATE b_lenh bulk collect INTO a_pvbh_ten,a_pvbh_ma,a_pvbh_pttsb,a_pvbh_ptts,
        a_pvbh_ptkhb,a_pvbh_ptkh,a_pvbh_tc,a_pvbh_ktru,a_pvbh_loai,a_pvbh_ma_ct,a_pvbh_ppts,a_pvbh_ppkh USING dt_pvi;
      delete temp_1;delete temp_2;delete temp_3;commit;
      
      for b_lp in 1..a_pvbh_ma.count loop
          if a_pvbh_loai(b_lp) = 'M' then
              b_pvi_m := true;
          end if;
          --- lay pvi bao hiem
          if a_pvbh_tc(b_lp) = 'C' and a_pvbh_loai(b_lp) = 'C' then
            insert into temp_1(C1) values( a_pvbh_ten(b_lp));
          end if;
          -- lay quy tac
          select count(*) into b_i1 from bh_phh_pvi p, bh_ma_qtac q where p.ma_qtac = q.ma and p.ma = a_pvbh_ma(b_lp);
          if b_i1 <> 0 then
              select NVL(q.ten,' ') into b_temp_nvar from bh_phh_pvi p, bh_ma_qtac q where p.ma_qtac = q.ma and p.ma = a_pvbh_ma(b_lp);
              insert into temp_2(C1,C2,c3) values(b_temp_nvar,a_pvbh_loai(b_lp),a_pvbh_ma_ct(b_lp));
          end if;

          --lay mkt
          if a_pvbh_loai(b_lp) = 'B' then 
              if trim(a_pvbh_ktru(b_lp)) is not null then
                  b_mkt_b:= b_mkt_b || ',' || FBH_MKT(a_pvbh_ktru(b_lp),b_nt_tien);
              end if;
          end if;
          if a_pvbh_loai(b_lp) = 'C' then 
              if trim(a_pvbh_ktru(b_lp)) is not null then
                  b_mkt_c:= b_mkt_c || ',' || FBH_MKT(a_pvbh_ktru(b_lp),b_nt_tien);
              end if;
          end if;
          if a_pvbh_loai(b_lp) = 'P' then 
              if trim(a_pvbh_ktru(b_lp)) is not null then
                  insert into temp_3(c1) values(a_pvbh_ten(b_lp) || ': ' || FBH_MKT(a_pvbh_ktru(b_lp),b_nt_tien));
              end if;
          end if;
          if a_pvbh_loai(b_lp) = 'M' then 
            if trim(a_pvbh_ktru(b_lp)) is not null then
                b_mkt_m:= TO_CHAR(TO_NUMBER(REGEXP_SUBSTR(a_pvbh_ktru(b_lp), '^\d+')));
            end if;
          end if;
      end loop;

      select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into b_mkt_p from temp_3;
      PKH_JS_THAY(dt_dt,'mkt_b',LTRIM(b_mkt_b,','));
      PKH_JS_THAY(dt_dt,'mkt_c',LTRIM(b_mkt_c,','));
      PKH_JS_THAY(dt_dt,'mkt_m',b_mkt_m);
      PKH_JS_THAY_D(dt_dt,'mkt_p',b_mkt_p);
      delete temp_1;delete temp_2;delete temp_3;commit;
    end if;
    --dt_kbt
    if a_dt_kbt_clob.count > 0 then
      dt_kbt:= a_dt_kbt_clob(b_lp1);
      if dt_kbt <> '""' then
        b_lenh := FKH_JS_LENH('ma,kbt');
        EXECUTE IMMEDIATE b_lenh bulk collect INTO a_kbt_ma_dk,a_kbt_kbt USING dt_kbt;
        for b_lp in 1..a_kbt_ma_dk.count loop
            if a_kbt_ma_dk(b_lp) = 'VCX' then
                b_lenh := FKH_JS_LENH('ma,nd');
                EXECUTE IMMEDIATE b_lenh bulk collect INTO a_kbt_ma,a_kbt_nd USING a_kbt_kbt(b_lp);
                for b_lp2 in 1..a_kbt_ma.count loop
                if a_kbt_ma(b_lp2) = 'KVU' then
                    if trim(FKH_JS_GTRIs(dt_dt ,'ktru')) is null then
                        b_temp_nvar:= N'Áp dụng mức khấu trừ: '|| a_kbt_nd(b_lp2) ||N' đồng/vụ tổn thất';
                        PKH_JS_THAY(dt_dt,'ktru',b_temp_nvar);
                    end if;
                end if;
                end loop;
            else
              select count(*) into b_i1 from bh_pkt_lbh where ma = a_kbt_ma_dk(b_lp);
              if b_i1 <> 0 then
                select loai,ten into b_temp_var,b_temp_nvar from bh_pkt_lbh where ma = a_kbt_ma_dk(b_lp);
                if b_temp_var = 'KH' then
                    b_lenh := FKH_JS_LENH('ma,nd');
                    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_kbt_ma,a_kbt_nd USING a_kbt_kbt(b_lp);
                    b_i2:= 0;
                    for b_lp2 in 1..a_kbt_ma.count loop
                      if a_kbt_ma(b_lp2) = 'KVU' then
                          if INSTR(UPPER(b_temp_nvar), N'TÀI SẢN') <> 0 then
                            insert into temp_1(c1) values(N'Đối với Tài sản:: ' || FBH_MKT(a_kbt_nd(b_lp2),b_nt_tien));
                          elsif INSTR(UPPER(b_temp_nvar), N'NGƯỜI') <> 0 then
                            b_i2:= 1;
                            if trim(a_kbt_nd(b_lp2)) is null then
                              insert into temp_1(c1) values(N'Đối với Người: Không áp dụng');
                            else
                              insert into temp_1(c1) values(N'Đối với Người: ' || FBH_MKT(a_kbt_nd(b_lp2),b_nt_tien));
                            end if; 
                          else
                            insert into temp_1(c1) values(b_temp_nvar || ': ' || FBH_MKT(a_kbt_nd(b_lp2),b_nt_tien));
                          end if;
                      end if;
                    end loop;
                    if b_i2 <> 1 then
                      insert into temp_1(c1) values(N'Đối với Người: Không áp dụng');
                    end if;
                end if;
              end if;
            end if;
        end loop;
        delete temp_1;commit;
        select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into b_mkt_m from temp_1;
        PKH_JS_THAY_D(dt_dt,'mkt_m',b_mkt_m);
      end if;
    end if;

    --dk
    delete temp_1;commit;
    insert into temp_1(c1,c2,c3,n1,n2) 
      select dk.ma,dk.ten,lh.loai,dk.cap,dk.tien from BH_PHH_DK dk, bh_phh_lbh lh where 
        dk.ma = lh.ma and dk.ma_dvi = b_ma_dvi and dk.so_id = b_so_id and dk.so_id_dt = b_so_id_dt and dk.nv = 'C' and trim(dk.PVI_MA) is null;

    dt_dk:= a_dt_dk_clob(b_lp1);
    b_lenh := FKH_JS_LENH('ma,ten,tien,tienkb,cap,mota');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_dk_ma,a_dk_ten,a_dk_tien,a_dk_tienkb,a_dk_cap,a_dk_mota USING dt_dk;
    for b_lp in 1..a_dk_ma.count loop
        if trim(a_dk_mota(b_lp)) is not null then
          b_temp_nvar := a_dk_ten(b_lp) || ' (' || a_dk_mota(b_lp) || ')';
        else
          b_temp_nvar := a_dk_ten(b_lp);
        end if;
        update temp_1 set n3 = a_dk_tienkb(b_lp),c2 = b_temp_nvar where c1 = a_dk_ma(b_lp);
    end loop;
    select count(*) into b_i2 from temp_1 where n1 = 1 and c3 <> 'KH';
    if b_i2 <> 0 then
      if b_i2 > 1 then
        raise_application_error(-20001,N'loi:Có nhiều hơn 1 điều khoản <> KH cấp bằng 1:loi');
      end if;
      select n2,n3 into b_tong_tien_v,b_i2 from temp_1 where n1 = 1 and c3 <> 'KH';
      PKH_JS_THAY(dt_dt,'tong_tien_v',FBH_CSO_TIEN(b_tong_tien_v,''));
      PKH_JS_THAY(dt_dt,'tong_tienkb_v',FBH_CSO_TIEN(b_i2,''));
    end if;
    select count(*) into b_i2 from temp_1 where n1 = 1 and c3 = 'KH';
    if b_i2 <> 0 then
      if b_i2 > 1 then
        raise_application_error(-20001,N'loi:Có nhiều hơn 1 điều khoản KH cấp bằng 1:loi');
      end if;
      select n2,n3 into b_tong_tien_g,b_i2 from temp_1 where n1 = 1 and c3 = 'KH';
      PKH_JS_THAY(dt_dt,'tong_tien_g',FBH_CSO_TIEN(b_tong_tien_g,''));
      PKH_JS_THAY(dt_dt,'tong_tienkb_g',FBH_CSO_TIEN(b_i2,''));
    end if;
    --- tinh tong tien v+ g
    PKH_JS_THAY(dt_dt,'tong_tien',FBH_CSO_TIEN(b_tong_tien_g + b_tong_tien_v,b_nt_tien));
    PKH_JS_THAYa(dt_dt,'tong_tien_chu',FBH_IN_CSO_CHU(b_tong_tien_g + b_tong_tien_v,b_nt_tien) );

    select count(*) into b_i2 from temp_1 where n1 = 1 and c3 = 'HH';
    if b_i2 <> 0 then
      select sum(n2) into b_tien_hh from temp_1 where c3 = 'HH';
    end if;
    select JSON_ARRAYAGG(json_object('ma' VALUE C1,'ten' value c2, 'tien' value FBH_CSO_TIEN(n2,''),'tienkb' value FBH_CSO_TIEN(n3,'') returning clob) returning clob) 
        into dt_dk_v from temp_1 where c3 <> 'KH' and n1 <> 1;
    select JSON_ARRAYAGG(json_object('ma' VALUE C1,'ten' value c2, 'tien' value FBH_CSO_TIEN(n2,''),'tienkb' value FBH_CSO_TIEN(n3,'') returning clob) returning clob) 
        into dt_dk_g from temp_1 where c3 = 'KH' and n1 <> 1;

    --GP giam %, GG giam tien, GT giam ty le,DP Giam % phi,DG Phi
    for b_lp in 1..a_pvbh_ma.count loop
    -- tinh lai ty le phi
      if a_pvbh_loai(b_lp) = 'B' then
        b_tlp_bb:= b_tlp_bb + fbh_in_tinh_tlp(a_pvbh_pttsb(b_lp),a_pvbh_ptts(b_lp),a_pvbh_ppts(b_lp),b_tong_tien_v);
      elsif a_pvbh_loai(b_lp) = 'C' then
        b_tlp_rr:= b_tlp_rr + fbh_in_tinh_tlp(a_pvbh_pttsb(b_lp),a_pvbh_ptts(b_lp),a_pvbh_ppts(b_lp),b_tong_tien_v);
      elsif a_pvbh_loai(b_lp) = 'M' then
        b_tlp_g:= b_tlp_g + fbh_in_tinh_tlp(a_pvbh_ptkhb(b_lp),a_pvbh_ptkh(b_lp),a_pvbh_ppkh(b_lp),b_tong_tien_g);
      end if;

    end loop;
    
    if b_tlp_bb <> 0 then 
      if b_tlp_bb > 100 then 
        b_phi_bb:= b_tlp_bb;
        b_tlp_bb:=0;
      else
        b_i1:= (b_tlp_bb/100) * b_tien_hh * FKH_JS_GTRIn(dt_dt ,'pt_hang')/100;
        b_phi_bb:= b_tlp_bb * b_tong_tien_v/100 - b_i1;
      end if;
    end if;
    if b_tlp_rr <> 0 then 
      if b_tlp_rr > 100  then 
        b_phi_rr:= b_tlp_rr;
        b_tlp_rr:=0;
      else
        b_i1:= (b_tlp_rr/100) * b_tien_hh * FKH_JS_GTRIn(dt_dt ,'pt_hang')/100;
        b_phi_rr:= b_tlp_rr * b_tong_tien_v/100 - b_i1;
      end if;
    end if;
    if b_tlp_g <> 0 then
      if b_tlp_g > 100 then 
        b_phi_g:= b_tlp_g;
        b_tlp_g:=0;
      else
        b_i1:= (b_tlp_g/100) * b_tien_hh * FKH_JS_GTRIn(dt_dt ,'pt_hang')/100;
        b_phi_g:= b_tlp_g * b_tong_tien_g/100 - b_i1;

        --b_phi_g:= b_tlp_g * b_tong_tien_g/100;
      end if;
    end if;

    PKH_JS_THAY(dt_dt,'tlp_bb',FBH_TO_CHAR(b_tlp_bb));
    PKH_JS_THAY(dt_dt,'tlp_rr',FBH_TO_CHAR(b_tlp_rr));
    PKH_JS_THAY(dt_dt,'tlp_g',FBH_TO_CHAR(b_tlp_g));
    PKH_JS_THAY(dt_dt,'phi_bb',FBH_CSO_TIEN(b_phi_bb,''));
    PKH_JS_THAY(dt_dt,'phi_rr',FBH_CSO_TIEN(b_phi_rr,''));
    PKH_JS_THAY(dt_dt,'phi_g',FBH_CSO_TIEN(b_phi_g,''));

    PKH_JS_THAY_D(dt_dt,'dt_dk_v',dt_dk_v);
    PKH_JS_THAY_D(dt_dt,'dt_dk_g',dt_dk_g);

    insert into temp_4(cl1) values(dt_dt);
    delete temp_1;commit;
    b_i3 := b_i3 + 1;
  end loop;
  SELECT JSON_QUERY( JSON_ARRAYAGG(cl1 FORMAT JSON  RETURNING CLOB),'$') INTO ds_dd FROM temp_4;
  ---quy tac
  b_temp_clob:= ' ';
  select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_pvi from (select distinct c1 from temp_1 );
  delete temp_1;commit;
  SELECT LISTAGG('' || c1 || ',') WITHIN GROUP (ORDER BY c1) into b_temp_clob from (select c1 from temp_2 where c2 = 'B' group by c1);
  PKH_JS_THAYc(dt_ct,'qt_rrcn',RTRIM(b_temp_clob,','));
  SELECT LISTAGG('' || c1 || ',') WITHIN GROUP (ORDER BY c1) into b_temp_clob from (select c1 from temp_2 where c2 = 'C' group by c1);
  PKH_JS_THAYc(dt_ct,'qt_rrkh',RTRIM(b_temp_clob,','));
  SELECT LISTAGG('' || c1 || ',') WITHIN GROUP (ORDER BY c1) into b_temp_clob from (select c1 from temp_2 where c2 = 'M' group by c1);
  PKH_JS_THAYc(dt_ct,'qt_gdkd',RTRIM(b_temp_clob,','));
end if;


-------------------- lay ds_dk
delete temp_1;delete temp_4;commit;
insert into temp_1(c1,c2,c3,n1,n2) 
  select dk.ma,dk.ten,lh.loai,dk.cap,dk.tien from BH_PHH_DK dk, bh_phh_lbh lh where 
    dk.ma = lh.ma and dk.ma_dvi = b_ma_dvi and dk.so_id = b_so_id and dk.nv = 'C' and trim(dk.PVI_MA) is null;
select count(*) into b_i1 from temp_1 where c3 = 'KH';
PKH_JS_THAY_D(dt_ct,'pvi_kh_2', 'X');
PKH_JS_THAY_D(dt_ct,'pvi_kh_1', 'X');
if b_i1 <> 0 then
    PKH_JS_THAY_D(dt_ct,'pvi_kh_1', ' ');
else
    PKH_JS_THAY_D(dt_ct,'pvi_kh_2', ' ');
end if;

select count(*) into b_i1 from bh_phh_txt t WHERE  t.so_id = b_so_id AND t.loai='ds_dk';
if b_i1 <> 0 then
    SELECT FKH_JS_BONH(t.txt) INTO b_temp_clob FROM bh_phh_txt t WHERE  t.so_id = b_so_id AND t.loai='ds_dk';
    b_lenh:=FKH_JS_LENHc('');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_clob using b_temp_clob;
    
end if;
delete temp_1;commit;
------------muc khau tru
for b_lp in 1..a_pvbh_ma.count loop
  if a_pvbh_loai(b_lp) = 'B' then 
      if trim(a_pvbh_ktru(b_lp)) is not null then
          b_mkt_b:= b_mkt_b || ',' || FBH_MKT(a_pvbh_ktru(b_lp),b_nt_tien);
      end if;
  end if;
  if a_pvbh_loai(b_lp) = 'C' then 
      if trim(a_pvbh_ktru(b_lp)) is not null then
          b_mkt_c:= b_mkt_c || ',' || FBH_MKT(a_pvbh_ktru(b_lp),b_nt_tien);
      end if;
  end if;
  if a_pvbh_loai(b_lp) = 'P' then 
      if trim(a_pvbh_ktru(b_lp)) is not null then
          insert into temp_1(c1) values(a_pvbh_ten(b_lp) || ': ' || FBH_MKT(a_pvbh_ktru(b_lp),b_nt_tien));
      end if;
  end if;
  if a_pvbh_loai(b_lp) = 'M' then 
    if trim(a_pvbh_ktru(b_lp)) is not null then
        b_mkt_m:= TO_CHAR(TO_NUMBER(REGEXP_SUBSTR(a_pvbh_ktru(b_lp), '^\d+')));
    end if;
  end if;
end loop;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into b_mkt_p from temp_1;
PKH_JS_THAY(dt_ct,'mkt_b',LTRIM(b_mkt_b,','));
PKH_JS_THAY(dt_ct,'mkt_c',LTRIM(b_mkt_c,','));
PKH_JS_THAY(dt_ct,'mkt_m',b_mkt_m);
delete temp_1;commit;

---thong tin thanh toan
delete temp_4;delete temp_1; commit;
select count(*) into b_i1 from bh_phh_tt where ma_dvi = b_ma_dvi and so_id = b_so_id;
if  b_i1 <> 0 then
    b_i2 := 1;
    for r_lp in (select ngay,tien from bh_phh_tt where ma_dvi = b_ma_dvi and so_id = b_so_id order by ngay asc)
    loop
      insert into temp_4(C1) values(N'-   Ký ' || b_i2 || '/' || b_i1 || N': Ngày thanh toán ' || FBH_IN_CSO_NG(r_lp.ngay,'DD/MM/YYYY') || N', số tiền thanh toán ' || FBH_CSO_TIEN(r_lp.tien,b_nt_tien) );
    b_i2:= b_i2 + 1;
    end loop;
    ---
    if b_i1 = 1 then
      b_temp_var:= FKH_JS_GTRIs(dt_ct ,'ngay_hl');
      select min(ngay) into b_i2 from bh_phh_tt where ma_dvi = b_ma_dvi and so_id = b_so_id;
      SELECT  TRUNC(TO_DATE(TO_CHAR(b_i2),'YYYYMMDD')) - TRUNC(TO_DATE(b_temp_var,'DD/MM/YYYY')) into b_i1 FROM dual;
      PKH_JS_THAY(dt_ct,'tttt',N'Phí bảo hiểm được Bên mua bảo hiểm/ Người được bảo hiểm thanh toán bằng tiền mặt hoặc chuyển khoản, trong vòng '||b_i1 || N' ngày kể từ ngày hợp đồng bảo hiểm có hiệu lực.');
    else
      PKH_JS_THAY(dt_ct,'tttt',N'Phí bảo hiểm được Bên mua bảo hiểm/ Người được bảo hiểm thanh toán bằng tiền mặt hoặc chuyển khoản theo các kỳ thanh toán được liệt kê bên dưới.');
    end if;
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_tt from temp_4;
delete temp_4;

--lay dt dong
delete temp_2;commit;
PKH_JS_THAY(dt_ct,'nbh',N'NGƯỜI BẢO HIỂM');
PKH_JS_THAY(dt_ct,'dbh','X');
select count(*) into b_i1 from BH_HD_DO_TL where ma_dvi = b_ma_dvi and so_id = b_so_id;
if b_i1 <> 0 then
  PKH_JS_THAY(dt_ct,'dbh',' ');
  PKH_JS_THAY(dt_ct,'nbh',N'NGƯỜI BẢO HIỂM ĐỨNG ĐẦU');
  b_i1:= 0;b_i2:= 1;
  select count(*) into b_i3 from BH_HD_DO_TL where ma_dvi = b_ma_dvi and so_id = b_so_id;
  for r_lp in (select b.ten,a.pt,b.dchi,b.mobi,b.cmt,b.ma_tk,b.nhang,b.ma from BH_HD_DO_TL a, BH_MA_NBH b where a.so_id = b_so_id and a.nha_bh=b.ma)
  loop
      b_temp_nvar:= N'NGƯỜI BẢO HIỂM THỨ ' || FBH_IN_SO_CHU(b_i2) || ': ' || r_lp.ten;
      insert into temp_2(C1,C2,c3,c4,c5,c6,c7,c8,c9) values(r_lp.ten,r_lp.pt,r_lp.dchi,r_lp.mobi,r_lp.cmt,r_lp.ma_tk,r_lp.nhang,b_temp_nvar,r_lp.ma);
      b_i1:= b_i1 + r_lp.pt;
      b_i2:=b_i2 +1;
  end loop;
  PKH_JS_THAY(dt_ct,'pt_dong',100 - b_i1);
end if;
select count(*) into b_i1 from  bh_hd_DO_NH_txt where ma_dvi = b_ma_dvi and so_id = b_so_id and loai = 'dt_bh';
b_i2:= 0;
if b_i1 <> 0 then
  select FKH_JS_BONH(txt) into dt_dong_bh from bh_hd_DO_NH_txt where ma_dvi = b_ma_dvi and so_id = b_so_id and loai = 'dt_bh';
  b_lenh := FKH_JS_LENH('nha_bh,pt,tien,phi');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_dong_nha_bh,a_dong_pt,a_dong_tien,a_dong_phi USING dt_dong_bh;

  for b_lp in 1..a_dong_nha_bh.count loop
      b_temp_var:= FBH_IN_SUBSTR(a_dong_nha_bh(b_lp), '|', 'T');
      update temp_2 set c10 = FBH_CSO_TIEN(a_dong_tien(b_lp),'') where c9 = b_temp_var;
      b_i2:= b_i2 + a_dong_tien(b_lp);
  end loop;
end if;

select count(*) into b_i1 from  bh_hd_DO_NH_txt where ma_dvi = b_ma_dvi and so_id = b_so_id and loai = 'dt_ct';
if b_i1 <> 0 then
  select FKH_JS_BONH(txt) into dt_dong_bh from bh_hd_DO_NH_txt where ma_dvi = b_ma_dvi and so_id = b_so_id and loai = 'dt_ct';
  b_i1:= FKH_JS_GTRIn(dt_dong_bh ,'tien');
  b_i2:= b_i2 + b_i1;
  PKH_JS_THAY(dt_ct,'tien_dong',FBH_CSO_TIEN(b_i1,''));
  PKH_JS_THAY(dt_ct,'tong_tien_dong',FBH_CSO_TIEN(b_i2,''));
end if;

select JSON_ARRAYAGG(json_object('ten' VALUE C1,'pt' VALUE C2, 'stt' value rownum + 1,'dchi' value C3,'mobi' value C4,'cmt' value c5,
  'ma_tk' value c6, 'nhang' value c7, 'tend' value c8,'tien' value c10) returning clob) into dt_dong from temp_2;
delete temp_2;commit;
--end dong
select json_object('dt_ct' value dt_ct,'dt_dong' value dt_dong,'dt_tt' value dt_tt,'dt_hk' value dt_hk,'dt_bs_chung' value dt_bs_chung,
  'dt_bs_vc' value dt_bs_vc,'dt_bs_gdkd' value dt_bs_gdkd,'dt_dkbs' value dt_dkbs,'ds_dd' value ds_dd returning clob) into b_oraOut from dual;

commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
