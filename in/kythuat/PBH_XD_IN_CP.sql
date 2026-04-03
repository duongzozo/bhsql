create or replace procedure PBH_XD_IN_CP(
       b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
as
    -- chung
    b_loi varchar2(100); b_lenh varchar2(1000);
    -- orain
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
    --
    b_i1 number := 0;b_ngay_tt number;b_tien_tt number;b_i2 number:=0;b_i3 number:=0;
    dt_dd clob; dt_ct clob; dt_dong clob; dt_dk clob;dt_dkbs clob;ds_dkbs clob;dt_lt clob;
    b_dvi clob;dt_bs clob;ds_ct clob;ds_pvi clob;dt_kytt clob;dt_hk clob;
    b_tnds clob; b_lhbh_khac clob;b_pvi_list clob;
    
    b_ten_dd nvarchar2(500):= ' ';
    b_diachi_dd nvarchar2(500):= ' ';
    b_mobi_dd nvarchar2(500):= ' ';
    b_fax_dd nvarchar2(500):= ' ';
    b_cmt_dd nvarchar2(500):= ' ';
    b_matk_dd nvarchar2(500):= ' ';
    b_nganhang_dd nvarchar2(500):= ' ';
    b_tendb_dd nvarchar2(500):= ' ';
    b_so_uyquyen_dd nvarchar2(500):= ' ';
    b_ngay_uyquyen_dd nvarchar2(500):= ' ';
    b_lan number;
    b_idx number;
    ngay_thoi_han_bh number := 0;
    
    b_ten_co_so nvarchar2(500):= ' ';
    --a dt_hk
    a_hu_ten pht_type.a_nvar;a_hu_cmt pht_type.a_var; a_hu_mobi pht_type.a_var;a_hu_email pht_type.a_var;
    a_hu_dchi pht_type.a_nvar;a_hu_ng_ddien pht_type.a_nvar;a_hu_chucvu pht_type.a_nvar;
    --dt_dkbs
    b_co_chung number;b_co_thvc number;b_co_gdkd number;b_co_tntb number;
    b_dk_chung clob;b_dk_thvc clob; b_dk_gdkd clob;b_dk_tntb clob;
    ---kbt
    dt_kbt clob;ds_kbt clob;
    a_kbt_ma_dk pht_type.a_var; a_kbt_kbt pht_type.a_nvar;
    a_kbt_nd pht_type.a_var; a_kbt_ma pht_type.a_nvar; 
    
    b_so_hd varchar2(50);
    b_ngay_cap number;
    b_ten_dvi nvarchar2(500):= ' ';
    b_dia_chi varchar2(500):= ' ';
    b_temp_var varchar2(100);b_temp_nvar varchar2(500);
    b_ma_kvuc varchar2(20);
    b_ten_kvuc nvarchar2(500):= ' ';
    b_nt_tien varchar2(50);b_nt_phi varchar2(50);
    b_ma_kt varchar2(50);b_kieu_kt varchar2(1);
    b_ngay_kt number := 0;
    ngay_kytt number := 0;
    han_ngay_tt number := 0;
    b_ng_ddb nvarchar2(500):= ' ';
    b_ng_dd nvarchar2(500):= ' ';
    -- nha Bh
    a_nha_bh pht_type.a_var;b_nha_bh varchar2(100);
    
    b_temp_clob clob;a_clob pht_type.a_clob;
    dt_pvi clob;
    --a dt_dk
    dt_dkthvc clob;dt_dkgdkd clob;
    a_dk_ma pht_type.a_var;a_dk_ma_dk pht_type.a_var;a_dk_ten pht_type.a_nvar; a_dk_tien pht_type.a_num;a_dk_tienkb pht_type.a_num;
    a_dk_phi pht_type.a_num;a_dk_thue pht_type.a_num;
    a_dk_cap pht_type.a_num;a_dk_gvu pht_type.a_var;a_dk_ma_ct pht_type.a_var;a_dk_kieu pht_type.a_var;
    a_dk_mota pht_type.a_nvar;
    
    b_tong_tien_thvc number; b_tong_tienkb_thvc number;
    b_tong_tien_gdkd number; b_tong_tienkb_gdkd number;
    --
    b_tlp_bb number:=0;b_tlp_rr number:=0;b_tlp_g number:=0;b_tlp_m number:=0;
    b_phi_bb number:=0;b_phi_rr number:=0;b_phi_g number:=0;b_phi_m number:=0;
    b_tong_tien_v number:= 0;b_tong_tien_g number:=0;b_tong_tien_m number:=0;b_tien_hh number:=0;
    
    b_tong_tlp number:=0;b_tong_phi number:=0;b_tong_phi_vat number:=0;
    --mkt
    b_mkt_b clob;b_mkt_c clob;b_mkt_p clob;b_mkt_m clob;b_mkt_d clob;
    ---
    dt_bs_chung clob;dt_bs_vc clob;dt_bs_gdkd clob;dt_bs_tntb clob;
    dt_dk_v clob;dt_dk_g clob;dt_dk_m clob;
    -- a_pvi
    
    a_pvbh_ma pht_type.a_var; a_pvbh_ten pht_type.a_nvar;a_pvbh_tc pht_type.a_var;a_pvbh_ktru pht_type.a_var;
    a_pvbh_loai pht_type.a_var;a_pvbh_ma_ct pht_type.a_var;
    a_pvbh_ma_dk pht_type.a_var;a_pvbh_ma_dk_ten pht_type.a_nvar;a_pvbh_ma_qtac pht_type.a_var;a_pvbh_ma_qtac_ten pht_type.a_nvar;
    a_pvbh_pttsb pht_type.a_var;a_pvbh_ptts pht_type.a_var;a_pvbh_ptkhb pht_type.a_var;a_pvbh_ppkh pht_type.a_var;a_pvbh_ptkh pht_type.a_var;
    a_pvbh_ppts pht_type.a_var;
    -- a_dkbs
    a_ten pht_type.a_nvar;a_ma pht_type.a_var;a_ma_dkc pht_type.a_var;a_dkp pht_type.a_nvar;
    -- dt_kytt 
    b_ky_tt clob;
    b_tt_ngay pht_type.a_num; b_tt_tien pht_type.a_num;
    --a dong bh
    dt_dong_bh clob; dt_dong_bh_ct clob;
    a_dong_nha_bh pht_type.a_nvar;a_dong_pt pht_type.a_num;a_dong_tien pht_type.a_num;a_dong_phi pht_type.a_num;
    
begin
 b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
     --Lay nguoi duoc BH
select count(*) into b_i1 from bh_pktb t WHERE ma_dvi = b_ma_dvi and t.so_id = b_so_id;
if b_i1 <> 0 then
SELECT MAX(lan) INTO b_lan FROM bh_pktb t WHERE ma_dvi = b_ma_dvi and t.so_id = b_so_id ;
end if;
        
--dt-ct  --Lay ben mua BH
select count(*) into b_i1 from bh_pktb_txt t WHERE t.ma_dvi = b_ma_dvi and t.so_id = b_so_id AND t.loai='dt_ct' AND t.lan = b_lan;
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ct FROM bh_pktb_txt t WHERE t.ma_dvi = b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_ct' AND t.lan = b_lan;
    b_nt_tien:=FKH_JS_GTRIs(dt_ct ,'nt_tien');
    if b_nt_tien= 'VND' then PKH_JS_THAYa(dt_ct,'nt_tien', N'Đồng');b_nt_tien:=N'đồng'; end if;
    
    b_nt_phi:=FKH_JS_GTRIs(dt_ct ,'nt_phi');
    if b_nt_phi= 'VND' then PKH_JS_THAYa(dt_ct,'nt_phi', N'Đồng');b_nt_phi:=N'đồng'; end if;
    
    b_i1:= FKH_JS_GTRIn(dt_ct ,'phi');
    PKH_JS_THAY(dt_ct,'phi',FBH_CSO_TIEN(b_i1,b_nt_tien) );
    
    b_i1:= FKH_JS_GTRIn(dt_ct ,'thue');
    PKH_JS_THAY(dt_ct,'thue',FBH_CSO_TIEN(b_i1,b_nt_tien) );

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ttoan');
    PKH_JS_THAY(dt_ct,'ttoan',FBH_CSO_TIEN(b_i1,b_nt_tien) );
    PKH_JS_THAYa(dt_ct,'bangchu',FBH_IN_CSO_CHU(b_i1,b_nt_tien) );
    
    b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_hl');
    PKH_JS_THAYa(dt_ct,'gio_hl',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00') );
    b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_kt');
    PKH_JS_THAYa(dt_ct,'gio_kt',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00'));
    
    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_hl');
    if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_hl',' '); 
    else PKH_JS_THAYa(dt_ct,'ngay_hl',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_kt');
    if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_kt',' '); 
    else PKH_JS_THAYa(dt_ct,'ngay_kt',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;
    
    b_i1:= FKH_JS_GTRIn(dt_ct ,'ng_uq');
    if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ng_uq',' '); 
    else PKH_JS_THAYa(dt_ct,'ng_uq',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;
    
    ngay_thoi_han_bh := FKH_JS_GTRIn(dt_ct ,'ngay_kt') - FKH_JS_GTRIn(dt_ct ,'ngay_hl');
    if ngay_thoi_han_bh > 0 then PKH_JS_THAY(dt_ct,'ngay_thbh',ngay_thoi_han_bh); end if;
    
    b_ngay_kt:= FKH_JS_GTRIn(dt_ct ,'ngay_kt');
    b_ng_dd := FKH_JS_GTRIs(dt_ct,'ng_dd');
  
    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_cap');
    if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_cap',' '); 
    else PKH_JS_THAYa(dt_ct,'ngay_cap',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;
    
  PKH_JS_THAYa(dt_ct,'ngay_cap_s',N'Ngày ' || FBH_IN_CSO_NG(b_i1,'DD') || N' tháng ' || FBH_IN_CSO_NG(b_i1,'MM')
    || N' năm ' || FBH_IN_CSO_NG(b_i1,'YYYY'));
    
  b_temp_var := FKH_JS_GTRIs(dt_ct,'ng_ddb');
    if b_temp_var is not null AND TRIM(b_temp_var) IS NOT NULL AND INSTR(b_temp_var,'|') > 0 THEN
      b_ng_ddb := FBH_IN_SUBSTR(b_temp_var,'|','T');
      PKH_JS_THAY(dt_ct,'ng_ddb',b_ng_ddb);
    else 
      PKH_JS_THAY(dt_ct,'ng_ddb',' ');
    end if;
  
  PKH_JS_THAYa(dt_ct,'ng_dbh',N'NGƯỜI ĐƯỢC BẢO HIỂM');
  
  if trim(FKH_JS_GTRIs(dt_ct ,'tend')) is null THEN
    PKH_JS_THAY_D(dt_ct,'tend','X' );
    PKH_JS_THAY_D(dt_ct,'dchid','X');
    PKH_JS_THAY_D(dt_ct,'mobid','X' );
    PKH_JS_THAY_D(dt_ct,'emaild','X' );
    PKH_JS_THAY_D(dt_ct,'cmtd','X' );
    PKH_JS_THAY_D(dt_ct,'ma_nhd','X' );
    PKH_JS_THAY_D(dt_ct,'ma_tkd','X' );
    PKH_JS_THAY_D(dt_ct,'ng_ddbdd','X' ); 
  else
    PKH_JS_THAY_D(dt_ct,'ng_ddbdd',b_ng_dd);
    PKH_JS_THAY(dt_ct,'ng_dbh',N'BÊN MUA BẢO HIỂM');
  end if;
end if;
    -- nguoi dai dien
select count(*) into b_i1 from ht_ma_dvi_txt t WHERE t.ma = b_ma_dvi;
if b_i1 <> 0 then
SELECT FKH_JS_BONH(t.txt) INTO dt_dd FROM ht_ma_dvi_txt t WHERE t.ma = b_ma_dvi;
    
    b_ten_dd := FKH_JS_GTRIs(dt_dd,'ten');
    PKH_JS_THAY(dt_ct, 'tendd', b_ten_dd);
    
    b_diachi_dd := FKH_JS_GTRIs(dt_dd,'dchi');
    PKH_JS_THAY(dt_ct, 'dchidd', b_diachi_dd);
    
    b_mobi_dd := FKH_JS_GTRIs(dt_dd,'sdt');
    PKH_JS_THAY(dt_ct, 'mobidd', b_mobi_dd);
    
    b_fax_dd := FKH_JS_GTRIs(dt_dd,'fax');
    PKH_JS_THAY(dt_ct, 'faxdd', b_fax_dd);
    
    b_cmt_dd := FKH_JS_GTRIs(dt_dd,'ma_thue');
    PKH_JS_THAY(dt_ct, 'cmtdd', b_cmt_dd);
    
    b_matk_dd := FKH_JS_GTRIs(dt_dd,'ma_tk');
    PKH_JS_THAY(dt_ct, 'ma_tkdd', b_matk_dd);
    
    b_nganhang_dd := FKH_JS_GTRIs(dt_dd,'nhang');
    PKH_JS_THAY(dt_ct, 'nhangdd', b_nganhang_dd);
end if;
--lay dt dong
    --a dong bh
   -- dt_dong_bh clob;
   -- a_dong_nha_bh pht_type.a_nvar;a_dong_pt pht_type.a_num;a_dong_tien pht_type.a_num;a_dong_phi pht_type.a_num;
delete temp_2;commit;
PKH_JS_THAY(dt_ct,'nbh',N'NGƯỜI BẢO HIỂM');
PKH_JS_THAY(dt_ct,'dbh','K');
select count(*) into b_i1 from BH_HD_DO_TL where ma_dvi = b_ma_dvi and so_id = b_so_id;
if b_i1 <> 0 then
  PKH_JS_THAY(dt_ct,'dbh','C');
  PKH_JS_THAY(dt_ct,'nbh',N'NGƯỜI BẢO HIỂM ĐỨNG ĐẦU');
  b_i1:= 0;b_i2:= 1;
  select count(*) into b_i3 from BH_HD_DO_TL where ma_dvi = b_ma_dvi and so_id = b_so_id;
  for r_lp in (select b.ten,a.pt,b.dchi,b.mobi,b.cmt,b.ma_tk,b.nhang,b.ma from BH_HD_DO_TL a, BH_MA_NBH b where a.so_id = b_so_id and a.nha_bh = b.ma)
  loop
--       if b_i3 = 1 then
--           b_temp_nvar:= u'NG\01af\1edcI B\1ea2O HI\1ec2M TH\1ee8 ' || FBH_IN_SO_CHU(b_i2) || ': ' || r_lp.ten;
--       else
--           b_temp_nvar:= u'NG\01af\1edcI B\1ea2O HI\1ec2M \0110\1ee8NG \0110\1ea6U: ' || r_lp.ten;
--       end if;
      b_temp_nvar:= N'NGƯỜI BẢO HIỂM THỨ ' || FBH_IN_SO_CHU(b_i2) || ': ' || r_lp.ten;
      insert into temp_2(C1,C2,c3,c4,c5,c6,c7,c8,c9) values(r_lp.ten,r_lp.pt,r_lp.dchi,r_lp.mobi,r_lp.cmt,r_lp.ma_tk,r_lp.nhang,b_temp_nvar,r_lp.ma);
      b_i1:= b_i1 + r_lp.pt;
      b_i2:=b_i2 +1;
  end loop;
  PKH_JS_THAY(dt_ct,'pt_dong',100 - b_i1);
  PKH_JS_THAY(dt_ct,'co_dong',' ');
else
  PKH_JS_THAY(dt_ct,'co_dong','X');
end if;
select count(*) into b_i1 from  bh_hd_DO_NH_txt where ma_dvi = b_ma_dvi and so_id = b_so_id and loai = 'dt_bh';
b_i2:= 0;
if b_i1 <> 0 then
  select FKH_JS_BONH(txt) into dt_dong_bh from bh_hd_DO_NH_txt where ma_dvi = b_ma_dvi and so_id = b_so_id and loai = 'dt_bh';
  b_lenh := FKH_JS_LENH('nha_bh,pt,tien,phi');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_dong_nha_bh,a_dong_pt,a_dong_tien,a_dong_phi USING dt_dong_bh;

  for b_lp in 1..a_dong_nha_bh.count loop
    
      dt_dong_bh := replace(dt_dong_bh,'"tien":'||to_char(a_dong_tien(b_lp)),
          '"tien":"'|| FBH_CSO_TIEN(a_dong_tien(b_lp),'') ||'"' );
          
      b_nha_bh:= FBH_IN_SUBSTR(a_dong_nha_bh(b_lp), '|', 'S');
      dt_dong_bh := replace(dt_dong_bh,'"nha_bh":"' || a_dong_nha_bh(b_lp) || '"',
      '"nha_bh":"' || b_nha_bh || '"');
  
      b_temp_var:= FBH_IN_SUBSTR(a_dong_nha_bh(b_lp), '|', 'T');
      update temp_2 set c10 = FBH_CSO_TIEN(a_dong_tien(b_lp),'') where c9 = b_temp_var;
      b_i2:= b_i2 + a_dong_tien(b_lp);
  end loop;
end if;

select count(*) into b_i1 from bh_hd_DO_NH_txt where ma_dvi = b_ma_dvi and so_id = b_so_id and loai = 'dt_ct';
if b_i1 <> 0 then
  select FKH_JS_BONH(txt) into dt_dong_bh_ct from bh_hd_DO_NH_txt where ma_dvi = b_ma_dvi and so_id = b_so_id and loai = 'dt_ct';
  b_i1:= FKH_JS_GTRIn(dt_dong_bh_ct ,'tien');
  b_i2:= b_i2 + b_i1;
  PKH_JS_THAY(dt_ct,'tien_dong',FBH_CSO_TIEN(b_i1,''));
  PKH_JS_THAY(dt_ct,'tong_tien_dong',FBH_CSO_TIEN(b_i2,''));
end if;

select JSON_ARRAYAGG(json_object('ten' VALUE C1,'pt' VALUE C2, 'stt' value rownum + 1,'dchi' value C3,'mobi' value C4,'cmt' value c5,
  'ma_tk' value c6, 'nhang' value c7, 'tend' value c8 ) returning clob) into dt_dong from temp_2;
delete temp_2;commit;
--end dong
--dt_hk
select count(*) into b_i1 from bh_pktb_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_hk';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_hk FROM bh_pktb_txt t WHERE t.ma_dvi = b_ma_dvi and t.so_id = b_so_id AND t.loai='dt_hk' and t.lan = b_lan;
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
---ds_ct
select count(*) into b_i1 from bh_pktb_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO b_temp_clob FROM bh_pktb_txt t WHERE t.ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_ct' and t.lan = b_lan;
  if b_temp_clob <> '[""]' then
    b_lenh:=FKH_JS_LENHc('');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_clob using b_temp_clob;
    ds_ct:= a_clob(1);
    PKH_JS_THAY(dt_ct,'dvi',FKH_JS_GTRIs(ds_ct ,'dvi') );
    PKH_JS_THAY(dt_ct,'ddiemc',FKH_JS_GTRIs(ds_ct ,'ddiemc') );
    PKH_JS_THAY(dt_ct,'lvuc',FKH_JS_GTRIs(ds_ct ,'lvuc') );
    PKH_JS_THAY(dt_ct,'ten_nct',FKH_JS_GTRIs(ds_ct ,'ten_nct') );
    PKH_JS_THAY(dt_ct,'mo_ta',FKH_JS_GTRIs(ds_ct ,'mo_ta') );
    PKH_JS_THAY(dt_ct,'gia_nct',FBH_CSO_TIEN(FKH_JS_GTRIn(ds_ct ,'gia_nct'),''));
    
    b_temp_nvar:= FBH_IN_SUBSTR(FKH_JS_GTRIs(ds_ct ,'ma_dt'),'|','T');   
    select count(*) into b_i2 from bh_phh_dtuong where ma = b_temp_nvar;
    if b_i2 <> 0 then
        select ten into b_ten_co_so from bh_phh_dtuong where ma = b_temp_nvar;
        PKH_JS_THAY(dt_ct, 'ten_coso', b_ten_co_so);
    end if;
  end if;
end if;
---ds_pvi
select count(*) into b_i1 from bh_pktb_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_pvi';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO b_temp_clob FROM bh_pktb_txt t WHERE t.ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_pvi' AND t.lan = b_lan;
  if b_temp_clob <> '[""]' then
    b_lenh:=FKH_JS_LENHc('');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_clob using b_temp_clob;
    ds_pvi:= a_clob(1);
    if ds_pvi <> '"[]"' then
      b_lenh := FKH_JS_LENH('ten,ma,tc,loai,pttsb,ptts,ptkhb,ptkh,ktru,ppts,ppkh');
      EXECUTE IMMEDIATE b_lenh bulk collect INTO a_pvbh_ten,a_pvbh_ma,a_pvbh_tc,a_pvbh_loai,
      a_pvbh_pttsb,a_pvbh_ptts,a_pvbh_ptkhb,a_pvbh_ptkh,a_pvbh_ktru,a_pvbh_ppts,a_pvbh_ppkh USING ds_pvi;
      delete temp_1;delete temp_2;commit;
      
      b_idx := 0;
      b_pvi_list := null;
      for b_lp in 1..a_pvbh_ma.count loop
          --- lay pvi bao hiem
          if a_pvbh_tc(b_lp) = 'C' and a_pvbh_loai(b_lp) = 'C' then
            insert into temp_1(C1) values( a_pvbh_ten(b_lp));
          --- list pvi A. B. C. ...
          b_idx := b_idx + 1;
          if b_pvi_list is null then
             b_pvi_list := chr(64 + b_idx) || '. ' || a_pvbh_ten(b_lp);
          else
             b_pvi_list := b_pvi_list || chr(10) || chr(64 + b_idx) || '. ' || a_pvbh_ten(b_lp);end if;
          end if;
          -- lay quy tac
          select count(*) into b_i1 from bh_pkt_pvi p, bh_ma_qtac q where p.ma_qtac = q.ma and p.ma = a_pvbh_ma(b_lp);
          if b_i1 <> 0 then
              select NVL(q.ten,' ') into b_temp_nvar from bh_pkt_pvi p, bh_ma_qtac q where p.ma_qtac = q.ma and p.ma = a_pvbh_ma(b_lp);
              insert into temp_2(C1,C2) values(b_temp_nvar,a_pvbh_loai(b_lp));
          end if;
      end loop;
        -- lay list pham vi
        if b_pvi_list is not null then PKH_JS_THAY(dt_ct, 'pvi_list', b_pvi_list);
        else PKH_JS_THAY(dt_ct, 'pvi_list', ' '); end if;
      
      select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_pvi from temp_1;
      delete temp_1;commit;
      SELECT LISTAGG('' || c1 || ',') WITHIN GROUP (ORDER BY c1) into b_temp_clob from (select c1 from temp_2 where c2 = 'B' group by c1);
      PKH_JS_THAYc(dt_ct,'qt_xdbb',RTRIM(b_temp_clob,','));
      SELECT LISTAGG('' || c1 || ',') WITHIN GROUP (ORDER BY c1) into b_temp_clob from (select c1 from temp_2 where c2 = 'C' group by c1);
      PKH_JS_THAYc(dt_ct,'qt_rrxd',RTRIM(b_temp_clob,','));
      SELECT LISTAGG('' || c1 || ',') WITHIN GROUP (ORDER BY c1) into b_temp_clob from (select c1 from temp_2 where c2 = 'M' group by c1);
      PKH_JS_THAYc(dt_ct,'qt_rrxd_tn',RTRIM(b_temp_clob,','));
      SELECT LISTAGG('' || c1 || ',') WITHIN GROUP (ORDER BY c1) into b_temp_clob from (select c1 from temp_2 where c2 = 'D' group by c1);
      PKH_JS_THAYc(dt_ct,'qt_mln',RTRIM(b_temp_clob,','));
    end if;
  end if;
end if;
-------------------- lay ds_dk
delete temp_1;delete temp_4;commit;

select count(*) into b_i1 from bh_pktb_txt t WHERE  t.so_id = b_so_id AND t.loai='ds_dk';
if b_i1 <> 0 then
    SELECT FKH_JS_BONH(t.txt) INTO b_temp_clob FROM bh_pktb_txt t WHERE  t.so_id = b_so_id AND t.loai='ds_dk' AND t.lan = b_lan;
    b_lenh:=FKH_JS_LENHc('');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_clob using b_temp_clob;
    dt_dk:= a_clob(1);
    b_lenh:= FKH_JS_LENH('ma,ma_dk,ten,tien,tienkb,cap,mota');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_dk_ma,a_dk_ma_dk,a_dk_ten,a_dk_tien,a_dk_tienkb,a_dk_cap,a_dk_mota USING dt_dk;
    insert into temp_1(c1,c2,c3,n1,n2) select dk.ma,dk.ten,lh.loai,dk.cap,dk.tien           
      from json_table(dt_dk,'$[*]'columns (
                  ma      varchar2(50)  path '$.ma',
                  ten     varchar2(500) path '$.ten',
                  tien    number        path '$.tien',
                  cap     number        path '$.cap')) dk
      join bh_pkt_lbh lh on dk.ma = lh.ma;
     
    for b_lp in 1..a_dk_ma.count loop     
        if trim(a_dk_mota(b_lp)) is not null then
          b_temp_nvar := a_dk_ten(b_lp) || ' (' || a_dk_mota(b_lp) || ')';
        else
          b_temp_nvar := a_dk_ten(b_lp);
        end if;
        
        update temp_1 set n3 = a_dk_tienkb(b_lp),c2 = b_temp_nvar where c1 = a_dk_ma(b_lp);
    end loop;
    
-- tinh toan
    select count(*) into b_i2 from temp_1 where n1 = 1 and c3 <> 'KH' and c3 <> 'BI';
    if b_i2 <> 0 then
      select n2,n3 into b_tong_tien_v,b_i2 from temp_1 where n1 = 1 and c3 <> 'KH' and c3 <> 'BI';
      PKH_JS_THAY(dt_ct,'tong_tien_v',FBH_CSO_TIEN(b_tong_tien_v,''));
      PKH_JS_THAY(dt_ct,'tong_tienkb_v',FBH_CSO_TIEN(b_i2,''));
    end if;
    select count(*) into b_i2 from temp_1 where n1 = 1 and c3 = 'KH' and c3 <> 'BI';
    if b_i2 <> 0 then
      select n2,n3 into b_tong_tien_g,b_i2 from temp_1 where n1 = 1 and c3 = 'KH' and c3 <> 'BI';
      PKH_JS_THAY(dt_ct,'tong_tien_g',FBH_CSO_TIEN(b_tong_tien_g,''));
      PKH_JS_THAY(dt_ct,'tong_tienkb_g',FBH_CSO_TIEN(b_i2,''));
    end if;
    select count(*) into b_i2 from temp_1 where n1 = 1 and c3 = 'BI';
    if b_i2 <> 0 then
      select n2,n3 into b_tong_tien_m,b_i2 from temp_1 where n1 = 1 and c3 = 'BI';
      PKH_JS_THAY(dt_ct,'tong_tien_m',FBH_CSO_TIEN(b_tong_tien_m,''));
      PKH_JS_THAY(dt_ct,'tong_tienkb_m',FBH_CSO_TIEN(b_i2,''));
    end if;
--- tinh tong tien v+ g
    PKH_JS_THAY(dt_ct,'tong_tien',FBH_CSO_TIEN(b_tong_tien_g + b_tong_tien_v + b_tong_tien_m,b_nt_tien));
    PKH_JS_THAYa(dt_ct,'tong_tien_chu',FBH_IN_CSO_CHU(b_tong_tien_g + b_tong_tien_v + b_tong_tien_m,b_nt_tien) );
    
    select count(*) into b_i2 from temp_1 where n1 = 1 and c3 = 'HH';
    if b_i2 <> 0 then
      select sum(n2) into b_tien_hh from temp_1 where c3 = 'HH';
    end if;
    select JSON_ARRAYAGG(json_object('ma' VALUE C1,'ten' value c2, 'tien' value FBH_CSO_TIEN(n2,''),'tienkb' value FBH_CSO_TIEN(n3,'') returning clob) returning clob) 
        into dt_dk_v from temp_1 where c3 <> 'KH' and c3 <> 'BI' and n1 <> 1;
    select JSON_ARRAYAGG(json_object('ma' VALUE C1,'ten' value c2, 'tien' value FBH_CSO_TIEN(n2,''),'tienkb' value FBH_CSO_TIEN(n3,'') returning clob) returning clob) 
        into dt_dk_g from temp_1 where c3 = 'KH' and n1 <> 1;
    select JSON_ARRAYAGG(json_object('ma' VALUE C1,'ten' value c2, 'tien' value FBH_CSO_TIEN(n2,''),'tienkb' value FBH_CSO_TIEN(n3,'') returning clob) returning clob) 
        into dt_dk_m from temp_1 where c3 = 'BI' and n1 <> 1;
        
    --GP giam %, GG giam tien, GT giam ty le,DP Giam % phi,DG Phi
    for b_lp in 1..a_pvbh_ma.count loop
     -- tinh lai ty le phi
--       if a_pvbh_loai(b_lp) = 'B' then
--         b_tlp_bb:= b_tlp_bb + fbh_in_tinh_tlp(a_pvbh_pttsb(b_lp),a_pvbh_ptts(b_lp),a_pvbh_ppts(b_lp),b_tong_tien_v);
--       elsif a_pvbh_loai(b_lp) = 'C' then
--         b_tlp_rr:= b_tlp_rr + fbh_in_tinh_tlp(a_pvbh_pttsb(b_lp),a_pvbh_ptts(b_lp),a_pvbh_ppts(b_lp),b_tong_tien_v);
--       elsif a_pvbh_loai(b_lp) = 'M' then
--         b_tlp_g:= b_tlp_g + fbh_in_tinh_tlp(a_pvbh_ptkhb(b_lp),a_pvbh_ptkh(b_lp),a_pvbh_ppkh(b_lp),b_tong_tien_g);
--       end if;

      b_i1:= case when a_pvbh_pttsb(b_lp) <> 0 then a_pvbh_pttsb(b_lp) else a_pvbh_ptts(b_lp) end;
      b_i2:= case when a_pvbh_ptkhb(b_lp) <> 0 then a_pvbh_ptkhb(b_lp) else a_pvbh_ptkh(b_lp) end;
      if a_pvbh_loai(b_lp) = 'B' then b_tlp_bb:= b_tlp_bb + b_i1;end if;
      if a_pvbh_loai(b_lp) = 'C' then b_tlp_rr:= b_tlp_rr + b_i1;end if;
      if a_pvbh_loai(b_lp) = 'M' then b_tlp_g:= b_tlp_g + b_i2;end if;
      if a_pvbh_loai(b_lp) = 'D' then b_tlp_m:= b_tlp_m + b_i2;end if;
    end loop;
    
    if b_tlp_bb <> 0 then 
--       if b_tlp_bb > 100 then 
--         b_phi_bb:= b_tlp_bb;
--         b_tlp_bb:=0;
--       else
--         b_i1:= (b_tlp_bb/100) * b_tien_hh * FKH_JS_GTRIn(dt_ct ,'pt_hang')/100;
--         b_phi_bb:= b_tlp_bb * b_tong_tien_v/100 - b_i1;
--       end if;
         b_phi_bb:= b_tlp_bb * b_tong_tien_v/100;
    end if;
    if b_tlp_rr <> 0 then 
--       if b_tlp_rr > 100  then 
--         b_phi_rr:= b_tlp_rr;
--         b_tlp_rr:=0;
--       else
--         b_i1:= (b_tlp_rr/100) * b_tien_hh * FKH_JS_GTRIn(dt_ct ,'pt_hang')/100;
--         b_phi_rr:= b_tlp_rr * b_tong_tien_v/100 - b_i1;
--       end if;
         b_phi_rr:= b_tlp_rr * b_tong_tien_v/100;
    end if;
    if b_tlp_g <> 0 then
--       if b_tlp_g > 100 then 
--         b_phi_g:= b_tlp_g;
--         b_tlp_g:=0;
--       else
--         b_i1:= (b_tlp_g/100) * b_tien_hh * FKH_JS_GTRIn(dt_ct ,'pt_hang')/100;
--         b_phi_g:= b_tlp_g * b_tong_tien_g/100 - b_i1;
--         end if;
        b_phi_g:= b_tlp_g * b_tong_tien_g/100;
    end if;
    if b_tlp_m <> 0 then
--       if b_tlp_m > 100 then 
--         b_phi_m:= b_tlp_m;
--         b_tlp_m:=0;
--       else
--         b_i1:= (b_tlp_m/100) * b_tien_hh * FKH_JS_GTRIn(dt_ct ,'pt_hang')/100;
--         b_phi_m:= b_tlp_m * b_tong_tien_m/100 - b_i1;
--       end if;
         b_phi_m:= b_tlp_m * b_tong_tien_m/100;
    end if;
    
    PKH_JS_THAY(dt_ct,'tlp_v',FBH_TO_CHAR(b_tlp_bb + b_tlp_rr));
    PKH_JS_THAY(dt_ct,'tlp_bb',FBH_TO_CHAR(b_tlp_bb));
    PKH_JS_THAY(dt_ct,'tlp_rr',FBH_TO_CHAR(b_tlp_rr));
    PKH_JS_THAY(dt_ct,'tlp_g',FBH_TO_CHAR(b_tlp_g));
    PKH_JS_THAY(dt_ct,'tlp_m',FBH_TO_CHAR(b_tlp_m));
    PKH_JS_THAY(dt_ct,'phi_v',FBH_CSO_TIEN(b_phi_bb + b_phi_rr,''));
    PKH_JS_THAY(dt_ct,'phi_bb',FBH_CSO_TIEN(b_phi_bb,''));
    PKH_JS_THAY(dt_ct,'phi_rr',FBH_CSO_TIEN(b_phi_rr,''));
    PKH_JS_THAY(dt_ct,'phi_g',FBH_CSO_TIEN(b_phi_g,''));
    PKH_JS_THAY(dt_ct,'phi_m',FBH_CSO_TIEN(b_phi_m,''));                                                               

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
  if a_pvbh_loai(b_lp) = 'D' then 
      if trim(a_pvbh_ktru(b_lp)) is not null then
          b_mkt_d:= b_mkt_d || N'+ Thiên tai: ' || ',' || FBH_MKT(a_pvbh_ktru(b_lp),b_nt_tien);
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
  if b_mkt_d is not null then
     PKH_JS_THAY(dt_ct,'mkt_d',LTRIM(b_mkt_d,','));
  else 
    PKH_JS_THAY(dt_ct,'mkt_d','X');
    end if;
PKH_JS_THAY(dt_ct,'mkt_m',NVL(b_mkt_m,'0'));
delete temp_1;delete temp_2;delete temp_4;commit;
-- lay dt_kbt
select count(*) into b_i1 from bh_pktb_txt t WHERE  t.so_id = b_so_id AND t.loai='ds_kbt';
if b_i1 <> 0 then
    SELECT FKH_JS_BONH(t.txt) INTO b_temp_clob FROM bh_pktb_txt t WHERE  t.so_id = b_so_id AND t.loai='ds_kbt' and t.lan = b_lan;
    b_lenh:=FKH_JS_LENHc('');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_clob using b_temp_clob;
    dt_kbt:= a_clob(1);
  if dt_kbt <> '""' then
    b_lenh := FKH_JS_LENH('ma,kbt');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_kbt_ma_dk,a_kbt_kbt USING dt_kbt;
    for b_lp in 1..a_kbt_ma_dk.count loop
        if a_kbt_ma_dk(b_lp) = 'VCX' then
            b_lenh := FKH_JS_LENH('ma,nd');
            EXECUTE IMMEDIATE b_lenh bulk collect INTO a_kbt_ma,a_kbt_nd USING a_kbt_kbt(b_lp);
            for b_lp2 in 1..a_kbt_ma.count loop
            if a_kbt_ma(b_lp2) = 'KVU' then
                if trim(FKH_JS_GTRIs(dt_ct ,'ktru')) is null then
                    b_temp_nvar:= N'Áp dụng mức khấu trừ: '|| a_kbt_nd(b_lp2) ||N' đồng/vụ tổn thất';
                    PKH_JS_THAY(dt_ct,'ktru',b_temp_nvar);
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
                        insert into temp_1(c1) values(N'Đối với Tài sản: ' || FBH_MKT(a_kbt_nd(b_lp2),b_nt_tien));
                      elsif INSTR(UPPER(b_temp_nvar), N'NGƯỜI') <> 0 then
                        b_i2:= 1;
                        if trim(a_kbt_nd(b_lp2)) is null then
                          insert into temp_1(c1) values(N'Đối với Người: Khônɡ áp dụng');
                        else
                          insert into temp_1(c1) values(N'Đối với Người: ' || FBH_MKT(a_kbt_nd(b_lp2),b_nt_tien));
                        end if; 
                      else
                        insert into temp_1(c1) values(b_temp_nvar || ': ' || FBH_MKT(a_kbt_nd(b_lp2),b_nt_tien));
                      end if;
                  end if;
                end loop;
                if b_i2 <> 1 then
                  insert into temp_1(c1) values(N'Đối với Người: Khônɡ áp dụng');
                end if;
            end if;
          end if;
        end if;
    end loop;
  end if;
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into b_mkt_m from temp_1;
delete temp_1; commit;
--dt_dkbs
b_co_chung:=0;b_co_thvc:=0;b_co_gdkd:=0;
b_dk_chung:=null;b_dk_thvc:=null;b_dk_gdkd:=null;
  PKH_JS_THAY(dt_ct,'dkbs_chung','X' );
  PKH_JS_THAY(dt_ct,'dkbs_thvc','X' );
  PKH_JS_THAY(dt_ct,'dkbs_gdkd','X' );
  PKH_JS_THAY(dt_ct,'dkbs_tntb','X' );
  PKH_JS_THAY(dt_ct,'dk_chung','X' );
  PKH_JS_THAY(dt_ct,'dk_thvc','X' );
  PKH_JS_THAY(dt_ct,'dk_gdkd','X' );
  PKH_JS_THAY(dt_ct,'dk_tntb','X' );
select count(*) into b_i1 from bh_pktb_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_dkbs';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_dkbs FROM bh_pktb_txt t WHERE t.ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_dkbs' AND t.lan = b_lan;
  b_lenh := FKH_JS_LENH('ten,ma,ma_dkc,dkp');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ten,a_ma,a_ma_dkc,a_dkp USING dt_dkbs;
  
  for b_lp in 1..a_ten.count loop
      b_temp_nvar:= a_ten(b_lp);
      if trim(a_dkp(b_lp)) is not null then 
        b_temp_nvar:= b_temp_nvar || ' (' || a_dkp(b_lp) || ')';
        end if;
      insert into temp_1(c1,c2,c3) values(b_temp_nvar,a_ma_dkc(b_lp),a_ma(b_lp));
      -- THVC
      if a_ma_dkc(b_lp) = 'THVC' then
        b_co_thvc := 1;
      -- GDKD
      elsif a_ma_dkc(b_lp) = 'GDKD' then
        b_co_gdkd := 1;
      -- TNTB
      elsif a_ma_dkc(b_lp) = 'TNTB' then
        b_co_tntb := 1;   
      --nhom chung--
      else
        b_co_chung := 1;
        end if;
         
      --
      select count(*) into b_i1 from bh_ma_dkbs where ma = a_ma(b_lp);
      if b_i1 <> 0 then
          SELECT FKH_JS_GTRIc(FKH_JS_BONH(t.txt) ,'nd') into b_temp_clob from bh_ma_dkbs t where  t.ma= a_ma(b_lp) and rownum = 1;
      end if;
      insert into temp_4(c1,c2,cl1) values(a_ma(b_lp),a_ten(b_lp),b_temp_clob);

  end loop;
  
end if;
---ds_dkbs
delete temp_4;commit;
select count(*) into b_i1 from bh_pktb_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_dkbs';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO b_temp_clob FROM bh_pktb_txt t WHERE t.ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_dkbs' and t.lan = b_lan;
  if b_temp_clob <> '[""]' then
    b_lenh:=FKH_JS_LENHc('');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_clob using b_temp_clob;
    ds_dkbs:= a_clob(1);
    b_lenh := FKH_JS_LENH('ten,ma,ma_dkc,dkp');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ten,a_ma,a_ma_dkc,a_dkp USING ds_dkbs;
    for b_lp in 1..a_ten.count loop
        b_temp_nvar:= a_ten(b_lp);
        if trim(a_dkp(b_lp)) is not null then b_temp_nvar:= b_temp_nvar || ' (' || a_dkp(b_lp) || ')';end if;
        insert into temp_1(c1,c2,c3) values(b_temp_nvar,a_ma_dkc(b_lp),a_ma(b_lp));  
          -- THVC
          if a_ma_dkc(b_lp)='THVC' then
              b_co_thvc:=1;
          -- GDKD
          elsif a_ma_dkc(b_lp)='GDKD' then
              b_co_gdkd:=1;
          -- TNTB
          elsif a_ma_dkc(b_lp) = 'TNTB' then
              b_co_tntb := 1;
          else
              b_co_chung := 1;
          end if;
          
        ---
        select count(*) into b_i1 from bh_ma_dkbs where ma = a_ma(b_lp);
        if b_i1 <> 0 then
           SELECT FKH_JS_GTRIc(FKH_JS_BONH(t.txt) ,'nd') into b_temp_clob from bh_ma_dkbs t where  t.ma= a_ma(b_lp) and rownum = 1;
        end if;
        insert into temp_4(c1,c2,cl1) values(a_ma(b_lp),a_ten(b_lp),b_temp_clob);   
    end loop;
    
  end if;
end if;
      if b_co_chung=1 then
         PKH_JS_THAY(dt_ct,'dkbs_chung',N'Điều khoản bổ sung chung:');
      end if;

      if b_co_thvc=1 then
         PKH_JS_THAY(dt_ct,'dkbs_thvc',
         N'Điều khoản bổ sung áp dụng đối với Thiệt hại vật chất:');
      end if;
      if b_co_gdkd=1 then
         PKH_JS_THAYa(dt_ct,'dkbs_gdkd',
         N'Điều khoản bổ sung áp dụng đối với Mất lợi nhuận:');
      end if;
      if b_co_tntb=1 then
         PKH_JS_THAYa(dt_ct,'dkbs_tntb',
         N'Điều khoản bổ sung áp dụng đối với Trách nhiệm bên thứ ba:');
      end if;
      
select JSON_ARRAYAGG(json_object('ma' VALUE C1,'ten' value c2, 'nd' value cl1 returning clob) returning clob) into dt_dkbs from temp_4;

-----------------dt_lt
select count(*) into b_i1 from bh_pktb_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_lt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO b_temp_clob FROM bh_pktb_txt t WHERE t.ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_lt' and t.lan = b_lan;
  if b_temp_clob <> '[""]' then
    b_lenh:=FKH_JS_LENHc('');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_clob using b_temp_clob;
    dt_lt:= a_clob(1);
    b_lenh := FKH_JS_LENH('ten,ma_lt');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ten,a_ma USING dt_lt;
    for b_lp in 1..a_ten.count loop
        select count(*) into b_i1 from bh_ma_dklt where ma = a_ma(b_lp);
        if b_i1 <> 0 then
          select ma_dk into b_temp_nvar from bh_ma_dklt where ma = a_ma(b_lp);
          SELECT FKH_JS_GTRIc(FKH_JS_BONH(t.txt) ,'nd') into b_temp_clob from bh_ma_dklt t where  t.ma= a_ma(b_lp) and rownum = 1;
        end if;
        insert into temp_4(c1,c2,cl1) values(a_ma(b_lp),a_ten(b_lp),b_temp_clob);
        insert into temp_1(c1,c2,c3) values(a_ten(b_lp),b_temp_nvar,a_ma(b_lp));
    end loop;
  end if;
end if;
--dt_lt
select count(*) into b_i1 from bh_pktb_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_lt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_lt FROM bh_pktb_txt t WHERE t.ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_lt' and t.lan = b_lan;
  b_lenh := FKH_JS_LENH('ten,ma_lt');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ten,a_ma USING dt_lt;
  for b_lp in 1..a_ten.count loop
      select count(*) into b_i1 from bh_ma_dklt where ma = a_ma(b_lp);
      if b_i1 <> 0 then
          select ma_dk into b_temp_nvar from bh_ma_dklt where ma = a_ma(b_lp);
          SELECT FKH_JS_GTRIc(FKH_JS_BONH(t.txt) ,'nd') into b_temp_clob from bh_ma_dklt t where  t.ma= a_ma(b_lp) and rownum = 1;
      end if;
      insert into temp_4(c1,c2,cl1) values(a_ma(b_lp),a_ten(b_lp),b_temp_clob);
      insert into temp_1(c1,c2,c3) values(a_ten(b_lp),b_temp_nvar,a_ma(b_lp));
  end loop;
end if;
select JSON_ARRAYAGG(json_object('ma' VALUE C1,'ten' value c2, 'nd' value cl1 returning clob) returning clob) into dt_lt from temp_4;


select JSON_ARRAYAGG(json_object('TEN' VALUE c3 || ' - ' || C1 returning clob) returning clob) into dt_bs_vc from temp_1 where c2  = 'THVC';
select JSON_ARRAYAGG(json_object('TEN' VALUE c3 || ' - ' || C1 returning clob) returning clob) into dt_bs_gdkd from temp_1 where c2 = 'GDKD';
select JSON_ARRAYAGG(json_object('TEN' VALUE c3 || ' - ' || C1 returning clob) returning clob) into dt_bs_tntb from temp_1 where c2 = 'TNTB';
select JSON_ARRAYAGG(json_object('TEN' VALUE c3 || ' - ' || C1 returning clob) returning clob) into dt_bs_chung from temp_1 where NVL(TRIM(c2),'#') NOT IN ('THVC','GDKD','TNTB');

delete temp_4;delete temp_1;commit;

--lay dt_kytt
select count(*) into b_i1 from bh_pktb_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_kytt';
  if b_i1 <> 0 then
    SELECT FKH_JS_BONH(t.txt) INTO dt_kytt FROM bh_pktb_txt t WHERE t.ma_dvi = b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_kytt' AND t.lan = b_lan;
    b_lenh := FKH_JS_LENH('ngay,tien');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO b_tt_ngay,b_tt_tien USING dt_kytt;
    
    -- 1 ky
    if b_tt_ngay.count = 1 then 
        han_ngay_tt := b_tt_ngay(1) - b_ngay_kt;
        PKH_JS_THAY(dt_ct,'han_ngay_tt', han_ngay_tt);
        PKH_JS_THAY(dt_ct,'ky_tt_n','X');
    else
    b_ky_tt := null;
    for i in 1 .. b_tt_ngay.count loop

    if b_ky_tt is not null then
        b_ky_tt := b_ky_tt || chr(10);
    end if;

    b_ky_tt := b_ky_tt ||
        N'- Kỳ ' || i || '/' || b_tt_ngay.count || N': Ngày thanh toán ' ||
        FBH_IN_CSO_NG(b_tt_ngay(i),'DD/MM/YYYY') || 
        N', số tiền thanh toán ' || FBH_CSO_TIEN(b_tt_tien(i),N'đồng');

        end loop;
    PKH_JS_THAY(dt_ct,'ky_tt', b_ky_tt);
    PKH_JS_THAY(dt_ct,'ky_tt_n',' ');
    PKH_JS_THAY(dt_ct,'han_ngay_tt', 'X');
    
    end if;
end if;
--
select json_object('dt_ct' value dt_ct,'dt_dong' value dt_dong,'dt_pvi' value dt_pvi,'dt_hk' value dt_hk,
'dt_dkbs' value dt_dkbs,'dt_kytt' value dt_kytt,'dt_dk_v'  value dt_dk_v,'dt_dk_g' value dt_dk_g,'dt_dk_m' value dt_dk_m,
'dt_lt' value dt_lt,'dt_dong_bh' value dt_dong_bh,'dt_bs_chung' value dt_bs_chung,'dt_bs_vc' value dt_bs_vc,
'dt_bs_gdkd' value dt_bs_gdkd,'dt_bs_tntb' value dt_bs_tntb,'b_mkt_p' value b_mkt_p,'b_mkt_m' value b_mkt_m  returning clob) into b_oraOut from dual;

commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
/