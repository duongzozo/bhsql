create or replace procedure PBH_TAU_IN_BT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    -- chung
    b_loi varchar2(100); b_lenh varchar2(1000);
    -- orain
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');

    b_so_id_hd number;b_so_id_dt number;
    b_nv varchar2(10);

    b_i1 number := 0;b_i2 number := 0;
    ds_ct clob;ds_ttt clob;ds_dk clob;ds_kbt clob;ds_dkbs clob;

    dt_ct clob; dt_dk clob; dt_hk clob; dt_tba clob; dt_kbt clob;dt_ttt clob;
    b_dvi clob;dt_gd clob;dt_dong clob;dt_mmt clob;
    hd_ct clob;hd_ds clob;hd_dk clob;hd_kbt clob;hd_ttt clob;hd_kytt clob;
    b_kh_ttt clob;dt_tai_bh clob;

    a_ds_ct pht_type.a_clob; a_ds_dk pht_type.a_clob; a_ds_dkbs pht_type.a_clob;
    a_ds_ttt pht_type.a_clob; a_ds_kbt pht_type.a_clob;

    b_temp_var varchar2(100):= ' ';b_temp_nvar varchar2(500):= ' ';
    --qtac
    hd_qt clob;b_dk clob;hd_mkt clob;
    b_quy_tac nvarchar2(500):= ' ';b_dk_ten nvarchar2(500):= ' ';b_ma_qtac varchar2(20);

    a_kbt_ma pht_type.a_var;a_kbt pht_type.a_clob;
    kbt_ma pht_type.a_var;kbt_nd pht_type.a_var;
    --
    b_t_that number :=0;b_phigd number := 0;

    b_dong_mtn varchar2(100);b_dong_thudoi varchar2(100);b_mtn number;b_tien_th number;
    b_ten_nha_bh nvarchar2(500):= ' ';
    b_tba_tien number:=0;a_tba_tien pht_type.a_num;
    b_nt_tien varchar2(20);
    -- tai hd
    b_so_id_ghep number;
    a_ttt_ma pht_type.a_var; a_ttt_nd pht_type.a_nvar;

    b_count number:=0; b_tien number :=0; b_tien_bh number:=0;b_tien_bt number:=0;
    dt_phi clob;a_tbh_tm_nbh pht_type.a_var;a_tbh_tm_pt pht_type.a_var;
    ---a_dt_dk
    a_dk_ma pht_type.a_var;a_dk_ten pht_type.a_nvar; a_dk_tien pht_type.a_num;a_dk_phi pht_type.a_num;a_dk_ktru pht_type.a_num;

    -- ty le dong tai
    b_so_idD number;b_tp number:=0; b_bth number; b_bthH number;
    a_so_id_ta pht_type.a_num; a_pthuc pht_type.a_var; a_nbh pht_type.a_var; a_nbhC pht_type.a_var; 
    a_lh_nv pht_type.a_var; a_pt pht_type.a_num; a_tien pht_type.a_num; a_phi pht_type.a_num;
    dk_lh_nv pht_type.a_var; dk_tien pht_type.a_num;
    a_s pht_type.a_var;
begin
-- Dan - Xem

b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
--dt_ct
select count(*) into b_i1 from bh_bt_tau_txt t WHERE ma_dvi = b_ma_dvi and so_id = b_so_id AND loai='dt_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ct FROM bh_bt_tau_txt t WHERE ma_dvi = b_ma_dvi and so_id = b_so_id AND loai='dt_ct';
end if;

SELECT '{' || LISTAGG('"' || ma || '": ""', ',') WITHIN GROUP (ORDER BY ma) || '}' into b_kh_ttt
FROM bh_kh_ttt
WHERE nv = 'TAU' AND ps = 'BT';

dt_ct:=FKH_JS_BONH(dt_ct);
b_kh_ttt:=FKH_JS_BONH(b_kh_ttt);
select json_mergepatch(dt_ct,b_kh_ttt) into dt_ct from dual;

b_nt_tien:= FKH_JS_GTRIs(dt_ct ,'nt_tien');

select sum(t_that) into b_t_that from bh_bt_tau_dk where so_id = b_so_id;
PKH_JS_THAY(dt_ct,'t_that',FBH_CSO_TIEN(b_t_that,b_nt_tien) );

--nntt
b_temp_var:= FKH_JS_GTRIs(dt_ct,'ma_nn');
select count(*) into b_i1 from bh_tau_nntt where ma = b_temp_var;
if b_i1 <> 0 then
  select ten into b_temp_nvar from bh_tau_nntt where ma = b_temp_var;
end if;
PKH_JS_THAY_D(dt_ct,'ma_nn',b_temp_nvar);
b_temp_nvar:=' ';

b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_xr');
if b_i1 = 30000101  or b_i1 = 0 then PKH_JS_THAY_D(dt_ct,'ngay_xr',' '); 
else PKH_JS_THAY_D(dt_ct,'ngay_xr',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_gui');
if b_i1 = 30000101 or b_i1 = 0 then PKH_JS_THAY_D(dt_ct,'ngay_gui',' '); 
else PKH_JS_THAY_D(dt_ct,'ngay_gui',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

PKH_JS_THAY_D(dt_ct,'ngay_cap_s',N'Ngày ' || FBH_IN_CSO_NG(b_i1,'DD') || N' tháng ' || FBH_IN_CSO_NG(b_i1,'MM')
|| N' năm ' || FBH_IN_CSO_NG(b_i1,'YYYY'));

b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_hl');
if b_i1 = 30000101 or b_i1 = 0 then PKH_JS_THAY_D(dt_ct,'ngay_hl',' '); 
else PKH_JS_THAY_D(dt_ct,'ngay_hl',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_kt');
if b_i1 = 30000101 or b_i1 = 0 then PKH_JS_THAY_D(dt_ct,'ngay_kt',' '); 
else PKH_JS_THAY_D(dt_ct,'ngay_kt',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

-- lay phi giam dinh
select count(*) into b_i1 from BH_BT_GD_HS where ma_dvi = b_ma_dvi and so_id_bt = b_so_id;
if  b_i1 <> 0 then
  select sum(ttoan) into b_phigd from BH_BT_GD_HS where ma_dvi = b_ma_dvi and so_id_bt = b_so_id;
end if;

if b_phigd <> 0 then
  PKH_JS_THAY(dt_ct,'phigd',FBH_CSO_TIEN(b_phigd,b_nt_tien) );
else
  PKH_JS_THAY_D(dt_ct,'phigd', ' ');
end if;

PKH_JS_THAY(dt_ct,'ngay_tao',FBH_IN_CSO_NG(PKH_NG_CSO(sysdate),'dd/mm/yyyy') );
--lay so tien ban thanh ly
select count(*) into b_i1 from bh_bt_thoi where so_id_hs = b_so_id and ma_dvi = b_ma_dvi;
if b_i1 <> 0 then
  select sum(tien_qd) into b_i1 from bh_bt_thoi where so_id_hs = b_so_id and ma_dvi = b_ma_dvi;
  PKH_JS_THAY(dt_ct,'stban',FBH_CSO_TIEN(b_i1,b_nt_tien) );
end if;


-- lay dt_dk
select count(*) into b_i1 from bh_bt_tau_txt t WHERE ma_dvi = b_ma_dvi and so_id = b_so_id AND loai='dt_dk';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_dk FROM bh_bt_tau_txt t WHERE ma_dvi = b_ma_dvi and so_id = b_so_id AND loai='dt_dk';
  b_lenh := FKH_JS_LENH('ma,ten,tien,phi,ktru');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_dk_ma,a_dk_ten,a_dk_tien,a_dk_phi,a_dk_ktru USING dt_dk;
  b_i1:= 0;
  for b_lp in 1..a_dk_ma.count loop
      b_i1:= b_i1 + a_dk_ktru(b_lp);
  end loop;
  PKH_JS_THAY_D(dt_ct,'mkt', FBH_CSO_TIEN(b_i1,b_nt_tien));
end if;

--dt_hk
select count(*) into b_i1 from bh_bt_tau_txt t WHERE ma_dvi = b_ma_dvi and t.so_id = b_so_id AND t.loai='dt_hk';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_hk FROM bh_bt_tau_txt t WHERE ma_dvi = b_ma_dvi and t.so_id = b_so_id AND t.loai='dt_hk';
end if;
-- lay dt_tba
select count(*) into b_i1 from bh_bt_tau_txt t WHERE ma_dvi = b_ma_dvi and t.so_id = b_so_id AND t.loai='dt_tba';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_tba FROM bh_bt_tau_txt t WHERE ma_dvi = b_ma_dvi and t.so_id = b_so_id AND t.loai='dt_tba';
  b_lenh:=FKH_JS_LENH('tien');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_tba_tien using dt_tba;
  for ds_lp in 1..a_tba_tien.count loop
    b_tba_tien:= b_tba_tien + a_tba_tien(ds_lp);
  end loop;
end if;
PKH_JS_THAY_D(dt_ct,'tba_tien',b_tba_tien);
--dt_kbt
select count(*) into b_i1 from bh_bt_tau_txt t WHERE ma_dvi = b_ma_dvi and t.so_id = b_so_id AND t.loai='dt_kbt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_kbt FROM bh_bt_tau_txt t WHERE ma_dvi = b_ma_dvi and t.so_id = b_so_id AND t.loai='dt_kbt';
end if;
-- lay dt_ttt
select count(*) into b_i1 from bh_bt_tau_txt t WHERE ma_dvi = b_ma_dvi and t.so_id = b_so_id AND t.loai='dt_ttt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ttt FROM bh_bt_tau_txt t WHERE ma_dvi = b_ma_dvi and t.so_id = b_so_id AND t.loai='dt_ttt';
  if dt_ttt <> '""' then
    b_lenh := FKH_JS_LENH('ma,nd');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ttt_ma,a_ttt_nd USING dt_ttt;
    for b_lp in 1..a_ttt_ma.count loop
      PKH_JS_THAY_D(dt_ct,a_ttt_ma(b_lp),trim(a_ttt_nd(b_lp)));
    end loop;
  end if;
end if;
--------------hd_ct
select so_id_hd,so_id_dt into b_so_id_hd,b_so_id_dt from bh_bt_tau where ma_dvi = b_ma_dvi and so_id = b_so_id;

select nv into b_nv from bh_tau where ma_dvi = b_ma_dvi and so_id = b_so_id_hd;
if b_nv = 'H' then
  select FKH_JS_BONH(txt) INTO ds_ct from bh_tau_txt where ma_dvi = b_ma_dvi and so_id = b_so_id_hd and loai = 'ds_ct';
  select FKH_JS_BONH(txt) INTO ds_ttt from bh_tau_txt where ma_dvi = b_ma_dvi and so_id = b_so_id_hd and loai = 'ds_ttt';
  select FKH_JS_BONH(txt) INTO ds_kbt from bh_tau_txt where ma_dvi = b_ma_dvi and so_id = b_so_id_hd and loai = 'ds_kbt';

  b_lenh:=FKH_JS_LENHc('');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_ct using ds_ct;
  EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_kbt using ds_kbt;
  EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_ttt using ds_ttt;

  for b_lp in 1..a_ds_ct.count loop
      b_i1:= FKH_JS_GTRIn(a_ds_ct(b_lp),'so_id_dt');
      if b_i1 = b_so_id_dt then
            hd_ct:= a_ds_ct(b_lp);
            hd_ttt:= a_ds_ttt(b_lp);
            hd_kbt:= a_ds_kbt(b_lp);
      end if;
  end loop;
else
  select FKH_JS_BONH(txt) INTO hd_ct from bh_tau_txt where ma_dvi = b_ma_dvi and so_id = b_so_id_hd and loai = 'dt_ct';
  select count(*) into b_i1 from bh_tau_txt where ma_dvi = b_ma_dvi and so_id = b_so_id_hd and loai = 'dt_ttt';
  if b_i1 <> 0 then
    select FKH_JS_BONH(txt) INTO hd_ttt from bh_tau_txt where ma_dvi = b_ma_dvi and so_id = b_so_id_hd and loai = 'dt_ttt';
  end if;
  select count(*) into b_i1 from bh_tau_txt where ma_dvi = b_ma_dvi and so_id = b_so_id_hd and loai = 'dt_kbt';
  if b_i1 <> 0 then
    select FKH_JS_BONH(txt) INTO hd_kbt from bh_tau_txt where ma_dvi = b_ma_dvi and so_id = b_so_id_hd and loai = 'dt_kbt';
  end if;
end if;

---hd_ct
if trim(FKH_JS_GTRIs(hd_ct ,'tenc')) is null THEN
        PKH_JS_THAY(hd_ct,'tenc',FKH_JS_GTRIs(hd_ct ,'ten') );
        PKH_JS_THAY(hd_ct,'dchic',FKH_JS_GTRIs(hd_ct ,'dchi') );
        PKH_JS_THAY(hd_ct,'mobic',FKH_JS_GTRIs(hd_ct ,'mobi') );
        PKH_JS_THAY(hd_ct,'cmtc',FKH_JS_GTRIs(hd_ct ,'cmt') );
    end if;
select count(*) into b_i1 from bh_tau_tt where ma_dvi = b_ma_dvi and so_id = b_so_id_hd;
if b_i1 <> 0 then
  select min(ngay) into b_i1 from bh_tau_tt where ma_dvi = b_ma_dvi and so_id = b_so_id_hd;
  PKH_JS_THAY_D(hd_ct,'ngay_xm',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );
end if;
-- lay so_hd dau
select so_id_d into b_i1 from bh_tau where ma_dvi = b_ma_dvi and so_id = b_so_id_hd;
if b_i1  <> 0 then
  select so_hd into b_temp_nvar from bh_tau where ma_dvi = b_ma_dvi and so_id = b_i1;
  PKH_JS_THAY_D(hd_ct,'so_hd',b_temp_nvar);
end if;

--lay gcn dau
select count(*) into b_i1 from bh_tau_ds where ma_dvi = b_ma_dvi and so_id_dt = b_so_id_dt and kieu_gcn = 'G';
if b_i1 <> 0 then
  select gcn into b_temp_nvar from bh_tau_ds where ma_dvi = b_ma_dvi and so_id_dt = b_so_id_dt and kieu_gcn = 'G';
  PKH_JS_THAY_D(hd_ct,'gcn_g',b_temp_nvar);
end if;
--end hd_ct

--hd_ds
SELECT JSON_OBJECT( 'ma_dvi' VALUE ma_dvi,'so_id' VALUE so_id,'so_id_dt' VALUE so_id_dt,'bt' VALUE bt,'kieu_gcn' VALUE kieu_gcn,
'gcn' VALUE gcn,'gcn_g' VALUE gcn_g,'tenc' VALUE tenc,'cmtc' VALUE cmtc,'mobic' VALUE mobic,'emailc' VALUE emailc,'dchic' VALUE dchic,
'ng_huong' VALUE ng_huong,'nhom' VALUE nhom,'loai' VALUE loai,'cap' VALUE cap,'vlieu' VALUE vlieu,'ttai' VALUE ttai,'so_cn' VALUE so_cn,
'dtich' VALUE dtich,'csuat' VALUE csuat,'gia' VALUE gia,'tuoi' VALUE tuoi,'ma_sp' VALUE ma_sp,'dkien' VALUE dkien,'md_sd' VALUE md_sd,'nv_bh' VALUE nv_bh,
'so_dk' VALUE so_dk,'ten_tau' VALUE ten_tau,'nam_sx' VALUE nam_sx,'hoi' VALUE hoi,'hoi_tien' VALUE hoi_tien,'hoi_tyle' VALUE hoi_tyle,'hoi_hh' VALUE hoi_hh,
'tl_mgiu' VALUE tl_mgiu,'gio_hl' VALUE gio_hl,'ngay_hl' VALUE ngay_hl,'gio_kt' VALUE gio_kt,'ngay_kt' VALUE ngay_kt,'ngay_cap' VALUE ngay_cap,'giam' VALUE giam,
'phi' VALUE phi,'thue' VALUE thue,'ttoan' VALUE ttoan  RETURNING CLOB) INTO hd_ds FROM bh_tau_ds WHERE so_id = b_so_id_hd and so_id_dt = b_so_id_dt and ma_dvi = b_ma_dvi;

b_temp_var:=FKH_JS_GTRIs(hd_ds ,'gio_hl');
PKH_JS_THAY_D(hd_ds,'gio_hl',NVL(FBH_IN_SUBSTR(trim(b_temp_var), '|', 'T') ,'00') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(trim(b_temp_var), '|', 'S') ,'00') );
b_temp_var:=FKH_JS_GTRIs(hd_ds ,'gio_kt');
PKH_JS_THAY_D(hd_ds,'gio_kt',NVL(FBH_IN_SUBSTR(trim(b_temp_var), '|', 'T') ,'00') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(trim(b_temp_var), '|', 'S') ,'00'));

b_i1:= FKH_JS_GTRIn(hd_ds ,'ngay_hl');
if b_i1 = 30000101 or b_i1 = 0  then PKH_JS_THAY_D(hd_ds,'ngay_hl',' '); 
else PKH_JS_THAY_D(hd_ds,'ngay_hl',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

PKH_JS_THAY_D(hd_ds,'ngay_hl_s',N'ngày ' || FBH_IN_CSO_NG(b_i1,'DD') || N' tháng ' || FBH_IN_CSO_NG(b_i1,'MM')
|| N' năm ' || FBH_IN_CSO_NG(b_i1,'YYYY'));

b_i1:= FKH_JS_GTRIn(hd_ds ,'ngay_kt');
if b_i1 = 30000101 or b_i1 = 0 then PKH_JS_THAY_D(hd_ds,'ngay_kt',' '); 
else PKH_JS_THAY_D(hd_ds,'ngay_kt',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

PKH_JS_THAY_D(hd_ds,'ngay_kt_s',N'ngày ' || FBH_IN_CSO_NG(b_i1,'DD') || N' tháng ' || FBH_IN_CSO_NG(b_i1,'MM')
|| N' năm ' || FBH_IN_CSO_NG(b_i1,'YYYY'));


b_i1:= FKH_JS_GTRIn(hd_ds ,'gia');
PKH_JS_THAY(hd_ds,'gia',FBH_CSO_TIEN(b_i1, b_nt_tien) );
-- lay ten loai tau
b_temp_var:=FKH_JS_GTRIs(hd_ds ,'loai');
select count(*) into b_i1 from bh_tau_loai where ma = b_temp_var;
if b_i1 <> 0 then
  select ten into b_temp_nvar from bh_tau_loai where ma = b_temp_var;
  PKH_JS_THAY_D(hd_ds,'loai',b_temp_nvar);
end if;

-- lay ten vlieu tau
b_temp_var:=FKH_JS_GTRIs(hd_ds ,'vlieu');
select count(*) into b_i1 from bh_tau_vlieu where ma = b_temp_var;
if b_i1 <> 0 then
  select ten into b_temp_nvar from bh_tau_vlieu where ma = b_temp_var;
  PKH_JS_THAY_D(hd_ds,'vlieu',b_temp_nvar);
end if;

--hd_dk
select JSON_ARRAYAGG(json_object(ma,ten,'tien' value FBH_CSO_TIEN(tien,b_nt_tien),pt,'phi' value FBH_CSO_TIEN(phi,b_nt_tien),'thue' value FBH_CSO_TIEN(thue,b_nt_tien), 
'ttoan' value  FBH_CSO_TIEN(ttoan,b_nt_tien)) returning clob) into hd_dk 
  from bh_tau_dk where ma_dvi = b_ma_dvi and so_id = b_so_id_hd and so_id_dt = b_so_id_dt;
--hd_kbt
b_lenh := FKH_JS_LENH('ma,kbt');
EXECUTE IMMEDIATE b_lenh bulk collect INTO a_kbt_ma,a_kbt USING hd_kbt;
delete TEMP_6;

for b_lp in 1..a_kbt_ma.count loop
    select count(*) into b_i1 from bh_tau_dk where ma_dvi = b_ma_dvi  and so_id = b_so_id_hd and so_id_dt = b_so_id_dt and ma = a_kbt_ma(b_lp);
    if b_i1 <> 0 then
      select ten into b_temp_nvar from bh_tau_dk where ma_dvi = b_ma_dvi and so_id = b_so_id_hd and so_id_dt = b_so_id_dt and ma = a_kbt_ma(b_lp);
    end if;
    if a_kbt(b_lp) is not null then
      b_lenh:=FKH_JS_LENH('ma,nd');
      EXECUTE IMMEDIATE b_lenh bulk collect into kbt_ma,kbt_nd using a_kbt(b_lp);
      for b_lp1 in 1..kbt_ma.count loop
        insert into TEMP_6(CL1) values(b_temp_nvar ||': '||FBH_IN_GBT(kbt_nd(b_lp1),kbt_ma(b_lp1)));
      end loop;
    end if;
end loop;
select JSON_ARRAYAGG(json_object('TEN' VALUE CL1) returning clob) into hd_mkt from TEMP_6;
delete TEMP_6;
--hd_ttt
if dt_ttt <> '""' then
  b_lenh := FKH_JS_LENH('ma,nd');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ttt_ma,a_ttt_nd USING dt_ttt;
  for b_lp in 1..a_ttt_ma.count loop
    PKH_JS_THAY_D(dt_ct,a_ttt_ma(b_lp),trim(a_ttt_nd(b_lp)));
  end loop;
end if;

--hd_kytt
select count(*) INTO b_i1 from bh_tau_txt where ma_dvi = b_ma_dvi and so_id = b_so_id_hd and loai = 'dt_kytt';
if b_i1 <> 0 then
  select FKH_JS_BONH(txt) INTO hd_kytt from bh_tau_txt where ma_dvi = b_ma_dvi and so_id = b_so_id_hd and loai = 'dt_kytt';
end if;

--hd_qtac
delete TEMP_4;
b_dk_ten:= ' ';
for r_lp in (select t2.ma,t2.txt from bh_tau_dk t1
left join bh_ma_dk t2 on t1.ma_dk = t2.ma
where t1.so_id_dt = b_so_id_dt and t1.so_id = b_so_id_hd and trim(t1.ma_dk) is not null and trim(t2.ma) is not null)
loop
    select txt,ten into b_dk,b_dk_ten from bh_ma_dk where ma = r_lp.ma;
    dbms_output.put_line('b_dk_ten ' || b_dk_ten);
    b_ma_qtac := FKH_JS_GTRIs(b_dk,'qtac');
    select count(*) into b_i1 from bh_ma_qtac WHERE ma=b_ma_qtac;
    if b_i1 <> 0 then
      select ten into b_quy_tac from bh_ma_qtac WHERE ma=b_ma_qtac;
      dbms_output.put_line('b_quy_tac ' || b_quy_tac);
      insert into TEMP_4(CL1) values(b_dk_ten || ': ' ||b_quy_tac);
    else
      insert into TEMP_4(CL1) values(b_dk_ten);
    end if;
end loop;
select JSON_ARRAYAGG(json_object('TEN' VALUE CL1) returning clob) into hd_qt from TEMP_4;
delete TEMP_4;

-- lay danh sach don vi giam dinh
delete temp_3;
select count(*) into b_i1 from BH_BT_GD_HS where ma_dvi = b_ma_dvi and so_id_bt = b_so_id and ma_gd is not null;
if b_i1 <> 0 then
  for r_lp in (select ma_gd,sum(ttoan) ttoan from BH_BT_GD_HS where ma_dvi = b_ma_dvi and so_id_bt = b_so_id group by ma_gd)
  loop
      select ten into b_temp_nvar from bh_ma_gdinh where ma =r_lp.ma_gd;
      insert into temp_3(C1) values(b_temp_nvar || unistr('\003A\0020\0050\0068\00ED\0020') || trim(TO_CHAR(r_lp.ttoan, '999,999,999,999,999,999PR')));
  end loop;
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1) returning clob) into dt_gd from TEMP_3;
delete temp_3;

-- dong, tai
PKH_JS_THAY(dt_ct,'dong_thudoi',' ');
PKH_JS_THAY(dt_ct,'tai_thudoi',' ');
begin
  select lh_nv,sum(tien) bulk collect into dk_lh_nv,dk_tien from bh_bt_hs_nv
    where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv having sum(tien)<>0;
  b_bthH:=FKH_ARR_TONG(dk_tien);

  b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id_dt);
  FBH_BT_DOTA_PT(b_ma_dvi,b_so_idD,b_so_id_dt,
      a_so_id_ta,a_pthuc,a_nbh,a_nbhC,a_lh_nv,a_pt,a_tien,a_phi,b_loi);
  if b_loi is not null then raise PROGRAM_ERROR; end if;
  if b_nt_tien<>'VND' then b_tp:=2; end if;
  for b_lp in 1..a_pthuc.count loop
      for b_lp1 in 1..dk_lh_nv.count loop
          if a_lh_nv(b_lp) in(' ',dk_lh_nv(b_lp1)) then
              b_i1:=round(dk_tien(b_lp1)*a_pt(b_lp)/100,b_tp);
              insert into bh_bt_dota_temp_2 values(a_pthuc(b_lp),a_nbhC(b_lp),a_tien(b_lp),b_i1);
          end if;
      end loop;
  end loop;
  insert into bh_bt_dota_temp_3 select pthuc,nbh,0,sum(tien),sum(bth) from bh_bt_dota_temp_2 group by pthuc,nbh;
  select nvl(sum(bth),0) into b_bth from bh_bt_dota_temp_3 where pthuc='DV';
  if b_bth<>0 then b_bth:=b_bthH-b_bth; end if;
  select nvl(sum(bth),0) into b_i1 from bh_bt_dota_temp_3 where pthuc='T';
  b_bth:=b_bth+b_i1;
  if b_bth=0 then b_bth:=b_bthH; end if;
  select nvl(sum(bth),0) into b_i1 from bh_bt_dota_temp_3 where pthuc not in('DV','T');
  b_bth:=b_bth-b_i1;
  insert into bh_bt_dota_temp_3 values(' ','..0',0,0,b_bth);
  PKH_CH_ARR('DD,DV,F,T,C,Q,S',a_s);
  for b_lp in 1..a_s.count loop
      select sum(bth) into b_bth from bh_bt_dota_temp_3 where pthuc=a_s(b_lp);
      if b_bth<>0 then
          insert into bh_bt_dota_temp_3 values(to_char(b_lp)||a_s(b_lp),'..'||to_char(b_lp)||a_s(b_lp),0,0,b_bth);
      end if;
  end loop;
  for b_lp in 1..a_s.count loop
      update bh_bt_dota_temp_3 set pthuc=to_char(b_lp)||a_s(b_lp) where pthuc=a_s(b_lp);
  end loop;
  update bh_bt_dota_temp_3 set pt=round(bth*100/b_bthH,2);

  insert into temp_1(c1,n1,n2,n3,c2,n5) 
    select nbh,pt,bth,tien,pthuc,row_number() over (order by pthuc,nbh) sott from bh_bt_dota_temp_3 where nbh is not null order by pthuc,nbh;

  select JSON_ARRAYAGG(json_object('ten' value FBH_DTAC_MA_TEN(c1) || ': ' || n1 || N'%, Tổng số tiền thu đòi: ' ||  FBH_CSO_TIEN(n2,''))
      order by n4 returning clob) into dt_dong from temp_1 where c1 not in ('..0','..1DD','..2DV') and c2 in ('0','1DD','2DV');
  select JSON_ARRAYAGG(json_object('ten' value FBH_DTAC_MA_TEN(c1) || ': ' || n1 || N'%, Tổng số tiền thu đòi: ' ||  FBH_CSO_TIEN(n2,''))
      order by n4 returning clob) into dt_tai_bh from temp_1 where c1 not in ('..3F', '..4T', '..5C', '..6Q', '..7S') and c2 in ('3F','4T','5C','6Q','7S');

  select count(*) into b_i1 from temp_1 where  c1 in ('..1DD','..2DV');
  if b_i1 <> 0 then
    select n2 into b_dong_thudoi from temp_1 where  c1 in ('..1DD','..2DV');
    PKH_JS_THAY(dt_ct,'dong_thudoi',FBH_CSO_TIEN(b_dong_thudoi,''));
  end if;

  select count(*) into b_i1 from temp_1 where  c1 in ('..3F', '..4T', '..5C', '..6Q', '..7S');
  if b_i1 <> 0 then
    select n2 into b_dong_thudoi from temp_1 where  c1 in ('..3F', '..4T', '..5C', '..6Q', '..7S');
    PKH_JS_THAY(dt_ct,'tai_thudoi',FBH_CSO_TIEN(b_dong_thudoi, ''));
  end if;
exception when others then
    dbms_output.put_line('Lỗi khi lấy dữ liệu: ' || sqlerrm);
end;
delete bh_bt_dota_temp_2;
delete bh_bt_dota_temp_3;
delete temp_1;
commit;
-- end dong, tai

b_i1:= FKH_JS_GTRIn(dt_ct ,'CPK_TT');
PKH_JS_THAY(dt_ct,'CPK_TT',FBH_CSO_TIEN(b_i1, b_nt_tien) );

b_i1:= FKH_JS_GTRIn(dt_ct ,'tba_tien');
PKH_JS_THAY(dt_ct,'tba_tien',FBH_CSO_TIEN(b_i1, b_nt_tien) );

select json_object('dt_ct' value dt_ct,'dt_dk' value dt_dk,'dt_hk' value dt_hk,
    'dt_tba' value dt_tba,'dt_kbt' value dt_kbt,'dt_ttt' value dt_ttt,'hd_ct' value hd_ct,
    'hd_ds' value hd_ds,'hd_dk' value hd_dk,'hd_qt' value hd_qt,'hd_mkt' value hd_mkt,'dt_gd' value dt_gd,
    'dt_dong' value dt_dong,'dt_tai_bh' value dt_tai_bh returning clob) into b_oraOut from dual;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
