create or replace procedure PBH_NG_IN_BT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    -- chung
    b_loi varchar2(100); b_lenh varchar2(1000);
    -- orain
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');

    b_i1 number := 0;
    dt_ct clob; dt_dk clob; dt_hk clob; dt_tba clob; dt_kbt clob;dt_ttt clob;
    dt_grv clob;dt_bvi clob;
    b_dvi clob;
    hd_ct clob;b_ls_bt clob;
    dt_tltt clob;dt_tlpt clob;
    bt_tltt clob;bt_tlpt clob;bt_dk clob; 
    
    b_kh_ttt clob;
    b_so_id_hd number;b_nv_ng varchar2(20);
    b_tenh nvarchar2(500):= ' ';
    b_cb clob;b_ma_cb varchar2(20);
    b_ma_temp varchar2(20);b_ten_temp nvarchar2(500):= ' ';
    b_nt_tien varchar2(50);
    --bien mang
    b_ma_vien varchar2(20);b_ng_vao number; b_ng_ra number;
    b_so_ngay number:=0; b_co_so nvarchar2(500) :=' ';
    b_so_hs varchar2(20):=' ';
    b_kieu_hd varchar2(20);
    --tt
    b_ttrang_tt nvarchar2(500):= ' ';b_ngay_nop varchar2(20):=' ';b_pthu varchar2(20):= ' ';
    b_tien_tt number;b_tien_da_tt number; b_ngay_tt number;b_ngay_da_tt number;
    --a_ttt
    a_ttt_ma pht_type.a_var; a_ttt_nd pht_type.a_nvar;
    -- a_grv
    a_grv_ma pht_type.a_var;a_grv_ten pht_type.a_nvar; a_grv_so_grv pht_type.a_var;
    a_grv_ng_cap pht_type.a_num;a_grv_ng_vao pht_type.a_num;a_grv_ng_ra pht_type.a_num;a_grv_tien pht_type.a_num;
    a_grv_gio_vao pht_type.a_var;a_grv_gio_ra pht_type.a_var;a_grv_ngay_nv pht_type.a_num;
    --a_dk
    a_dk_ma pht_type.a_var;a_dk_ten pht_type.a_nvar; a_dk_tien pht_type.a_num;a_dk_tien_bh pht_type.a_num;
    a_dk_pt_bt pht_type.a_num;a_dk_t_that pht_type.a_num;a_dk_bt_con pht_type.a_num;a_dk_giam pht_type.a_num;
    a_dk_cap pht_type.a_num;a_dk_ma_ct pht_type.a_var;a_dk_tc pht_type.a_var;
    a_dk_lkeb pht_type.a_nvar;a_dk_ma_dk  pht_type.a_var;a_dk_nd pht_type.a_nvar;
    --tltt,tlpt
    a_ten pht_type.a_nvar;a_muc pht_type.a_var;

    b_tong_tthat number:=0;b_tong_giam number:=0;b_tong_tt number:=0;
begin
-- Dan - Xem

b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
--dt_ct
select count(*) into b_i1 from bh_bt_ng_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ct FROM bh_bt_ng_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_ct';
  b_ma_temp:= FKH_JS_GTRIs(dt_ct,'ma_nn');
  if trim(b_ma_temp) is not null then
    select count(*) into b_i1 from bh_ma_nntt  where tc='C' and  FBH_MA_NV_CO(nv,'NG')='C' and ma = b_ma_temp;
    if b_i1 <> 0 then
      select ten into b_ten_temp from bh_ma_nntt  where tc='C' and  FBH_MA_NV_CO(nv,'NG')='C' and ma = b_ma_temp;
      PKH_JS_THAYa(dt_ct,'ma_nn',b_ten_temp);
    end if;
  end if;
  b_nt_tien:=FKH_JS_GTRIs(dt_ct ,'ma_nt');

  b_i1:= FKH_JS_GTRIn(dt_ct ,'tien');
  PKH_JS_THAY(dt_ct,'tien',FBH_CSO_TIEN(b_i1,b_nt_tien) );
  PKH_JS_THAYa(dt_ct,'bangchu',FBH_IN_CSO_CHU(b_i1,b_nt_tien) );

  b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_xr');
  if b_i1 = 30000101 or b_i1 = 0 then PKH_JS_THAYa(dt_ct,'ngay_xr',' '); 
  else PKH_JS_THAYa(dt_ct,'ngay_xr',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

  b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_hl');
  if b_i1 = 30000101 or b_i1 = 0 then PKH_JS_THAYa(dt_ct,'ngay_hl',' '); 
  else PKH_JS_THAYa(dt_ct,'ngay_hl',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_kt');
  if b_i1 = 30000101 or b_i1 = 0 then PKH_JS_THAYa(dt_ct,'ngay_kt',' '); 
  else PKH_JS_THAYa(dt_ct,'ngay_kt',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

  b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_gr');
  if b_i1 = 30000101 or b_i1 = 0 then PKH_JS_THAYa(dt_ct,'ngay_gr',' '); 
  else PKH_JS_THAYa(dt_ct,'ngay_gr',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

  b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_gui');
  if b_i1 = 30000101 or b_i1 = 0 then PKH_JS_THAYa(dt_ct,'ngay_gui',' '); 
  else 
    PKH_JS_THAYa(dt_ct,'ngay_gui',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );
     PKH_JS_THAYa(dt_ct,'ngay_gui_s',N'Ngày ' || FBH_IN_CSO_NG(b_i1,'DD') || N' tháng ' || FBH_IN_CSO_NG(b_i1,'MM')
    || N' năm ' || FBH_IN_CSO_NG(b_i1,'YYYY'));
  end if;

end if;
select so_hs into b_so_hs from bh_bt_ng where so_id = b_so_id;

select json_object('ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
       'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob)
       into b_dvi  from ht_ma_dvi where ma=b_ma_dvi;
dt_ct:=FKH_JS_BONH(dt_ct);
b_dvi:=FKH_JS_BONH(b_dvi);
select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;


--ttt
SELECT '{' || LISTAGG('"' || ma || '": ""', ',') WITHIN GROUP (ORDER BY ma) || '}' into b_kh_ttt
FROM bh_kh_ttt
WHERE nv = 'NG' AND ps = 'BT';
dt_ct:=FKH_JS_BONH(dt_ct);
b_kh_ttt:=FKH_JS_BONH(b_kh_ttt);
select json_mergepatch(dt_ct,b_kh_ttt) into dt_ct from dual;

-- lay dt_ttt
select count(*) into b_i1 from bh_bt_ng_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_ttt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ttt FROM bh_bt_ng_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_ttt';
  if dt_ttt <> '""' then
    b_lenh := FKH_JS_LENH('ma,nd');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ttt_ma,a_ttt_nd USING dt_ttt;
    for b_lp in 1..a_ttt_ma.count loop
          PKH_JS_THAYa(dt_ct,a_ttt_ma(b_lp),a_ttt_nd(b_lp));
    end loop;
  end if;
end if;

-- thong tin can bo
  b_ten_temp:= FKH_JS_GTRIs(dt_ct,'n_trinh');
  b_ma_cb:= FBH_IN_SUBSTR(b_ten_temp,'|','T');
  select count(*) into b_i1 from ht_ma_cb where ma=b_ma_cb;
  if b_i1 <> 0 then
      select json_object('ten_cb' value NVL(ten,' '),'mobi_cb' value NVL(mobi,' '),'email_cb' value NVL(mail,' ') returning clob) into b_cb
                  from ht_ma_cb where ma=b_ma_cb;
  else
    select json_object('ten_cb' value ' ','mobi_cb' value ' ','email_cb' value ' ' returning clob) into b_cb
                  from dual;
  end if;
  dt_ct:=FKH_JS_BONH(dt_ct);
  b_cb:=FKH_JS_BONH(b_cb);
  select json_mergepatch(dt_ct,b_cb) into dt_ct from dual;
--dt_grv
select count(*) into b_i1 from bh_bt_ng_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_grv';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_grv FROM bh_bt_ng_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_grv';
  if dt_grv <> '""' then
    b_lenh := FKH_JS_LENH('ma,ten,so_grv,ng_cap,gio_vao,ng_vao,gio_ra,ng_ra,ng_nv,tien');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_grv_ma,a_grv_ten,a_grv_so_grv,a_grv_ng_cap,a_grv_gio_vao,a_grv_ng_vao,a_grv_gio_ra,a_grv_ng_ra,a_grv_ngay_nv,a_grv_tien USING dt_grv;

    b_ma_vien :=  a_grv_ma(1);
    b_ng_vao :=  a_grv_ng_vao(1);
    b_ng_ra :=  a_grv_ng_ra(1);
    b_so_ngay:=a_grv_ngay_nv(1);
    --lay ten co so y te
    select count(*) into b_i1 from bh_ma_bv where ma = b_ma_vien;
    if b_i1 <> 0 then
      select ten into b_co_so from bh_ma_bv where ma = b_ma_vien;
    end if;
  end if;
end if;
PKH_JS_THAY(dt_ct,'so_ngay', FBH_TO_CHAR(b_so_ngay));
PKH_JS_THAY(dt_ct,'co_so', b_co_so);
PKH_JS_THAY(dt_ct,'so_hs', b_so_hs);

-- lay dt_dk
select count(*) into b_i1 from bh_bt_ng_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_dk';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_dk FROM bh_bt_ng_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_dk';
  b_lenh := FKH_JS_LENH('ma,ten,tien,tien_bh,pt_bt,t_that,bt_con,giam,cap,ma_ct,tc,lkeb,ma_dk,nd');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_dk_ma,a_dk_ten,a_dk_tien,a_dk_tien_bh,a_dk_pt_bt,a_dk_t_that,a_dk_bt_con,
    a_dk_giam,a_dk_cap,a_dk_ma_ct,a_dk_tc,a_dk_lkeb,a_dk_ma_dk,a_dk_nd USING dt_dk;
  delete temp_1;delete temp_2;
  --b_tong_tthat number:=0;b_tong_giam number:=0;b_tong_tt number:=0;
  for b_lp in 1..a_dk_ma.count loop
      if a_dk_t_that(b_lp) <> 0 and a_dk_cap(b_lp) > 1 then
        insert into temp_1(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13) 
            values(a_dk_ma(b_lp),a_dk_ten(b_lp),FBH_CSO_TIEN(a_dk_tien(b_lp),''),FBH_CSO_TIEN(a_dk_tien_bh(b_lp),''),a_dk_pt_bt(b_lp),FBH_CSO_TIEN(a_dk_t_that(b_lp),''),FBH_CSO_TIEN(a_dk_bt_con(b_lp),''),
              a_dk_giam(b_lp),a_dk_cap(b_lp),a_dk_ma_ct(b_lp),a_dk_tc(b_lp),a_dk_lkeb(b_lp),a_dk_nd(b_lp));
        if trim(a_dk_ma_dk(b_lp)) is not null then
            b_tong_tthat:= b_tong_tthat + a_dk_t_that(b_lp);
            b_tong_giam:= b_tong_giam + a_dk_giam(b_lp);
            b_tong_tt:= b_tong_tt + a_dk_tien(b_lp);
        end if;
      end if;
      if a_dk_pt_bt(b_lp) > 0 and a_dk_tien_bh(b_lp) >0  then
        b_ten_temp:= a_dk_pt_bt(b_lp) || '% x ' || FBH_CSO_TIEN(a_dk_tien_bh(b_lp),'') || N' Tr.đ= '||  FBH_CSO_TIEN(a_dk_t_that(b_lp),'');
        b_i1:= a_dk_pt_bt(b_lp) * a_dk_tien_bh(b_lp)/100;
        if a_dk_lkeb(b_lp) = 'B' then
          insert into temp_2(c1,c2,c3) values(b_ten_temp,FBH_CSO_TIEN(b_i1,''),'B');
        elsif a_dk_lkeb(b_lp) = 'P' then
          insert into temp_2(c1,c2,c3) values(b_ten_temp,FBH_CSO_TIEN(b_i1,''),'P');
        else
          insert into temp_3(c1,c2,c4) values(a_dk_ten(b_lp),FBH_CSO_TIEN(a_dk_t_that(b_lp),''),FBH_CSO_TIEN(a_dk_tien(b_lp),''));
        end if;
      end if;
  end loop;
  PKH_JS_THAY(dt_ct,'tong_tthat', FBH_CSO_TIEN(b_tong_tthat,''));
  PKH_JS_THAY(dt_ct,'tong_giam', FBH_CSO_TIEN(b_tong_giam,''));
  PKH_JS_THAY(dt_ct,'tong_tt', FBH_CSO_TIEN(b_tong_tt,''));

  select JSON_ARRAYAGG(json_object('ct' value c1,'duyet' value c2 returning clob) returning clob) into bt_tltt 
  FROM temp_2 where c3 = 'B';
  select JSON_ARRAYAGG(json_object('ct' value c1,'duyet' value c2 returning clob) returning clob) into bt_tlpt 
  FROM temp_2 where c3 = 'P';
  select JSON_ARRAYAGG(json_object('ten' value c1,'t_that' value c2,'tien' value c3 returning clob) returning clob) into bt_dk 
  FROM temp_3;


  select JSON_ARRAYAGG(json_object('stt' value rownum,'ma' value c1,'ten' value c2,'tien' value c3,'tien_bh' value c4,
  't_that' value c6,'giam' value c8,'bt_con' value c7,'nd' value c13,'so_ngay' value b_so_ngay,
   'co_so' value b_co_so returning clob) returning clob) into dt_dk FROM temp_1;
  delete temp_1;delete temp_2;
  commit;
end if;

--dt_hk
select count(*) into b_i1 from bh_bt_ng_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_hk';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_hk FROM bh_bt_ng_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_hk';
end if;
-- lay dt_tba
select count(*) into b_i1 from bh_bt_ng_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_tba';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_tba FROM bh_bt_ng_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_tba';
end if;
--dt_kbt
select count(*) into b_i1 from bh_bt_ng_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_kbt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_kbt FROM bh_bt_ng_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_kbt';
end if;
--dt_tltt
select count(*) into b_i1 from bh_bt_ng_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_tltt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_tltt FROM bh_bt_ng_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_tltt';
  b_lenh := FKH_JS_LENH('ten,muc');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ten,a_muc USING dt_tltt;
  delete temp_1;
  b_ten_temp:= '';
  for b_lp in 1..a_ten.count loop
    b_ten_temp:= N'Từ ' || FBH_IN_SUBSTR(a_muc(b_lp), '-', 'T') || N'% đến ' || FBH_IN_SUBSTR(a_muc(b_lp), '-', 'S') || '%'; 
    insert into temp_1(c1,c2) values(a_ten(b_lp), b_ten_temp);
  end loop;
  select JSON_ARRAYAGG(json_object('ten' value c1,'muc' value c2 returning clob) returning clob) into dt_tltt from temp_1;

  delete temp_1;commit;
end if;
--dt_tlpt
select count(*) into b_i1 from bh_bt_ng_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_tlpt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_tlpt FROM bh_bt_ng_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_tlpt';
  b_lenh := FKH_JS_LENH('ten,muc');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ten,a_muc USING dt_tlpt;
  delete temp_1;
  b_ten_temp:= '';
  for b_lp in 1..a_ten.count loop
    b_ten_temp:= N'Từ ' || FBH_IN_SUBSTR(a_muc(b_lp), '-', 'T') || N'% đến ' || FBH_IN_SUBSTR(a_muc(b_lp), '-', 'S') || '%'; 
    insert into temp_1(c1,c2) values(a_ten(b_lp), b_ten_temp);
  end loop;
  select JSON_ARRAYAGG(json_object('ten' value c1,'muc' value c2 returning clob) returning clob) into dt_tlpt from temp_1;

  delete temp_1;commit;
end if;

--dt_bvi
select count(*) into b_i1 from bh_bt_ng_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_tlpdt_bvit';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_bvi FROM bh_bt_ng_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_bvi';
end if;

--hd_ct
select so_id_hd into b_so_id_hd from bh_bt_ng where so_id = b_so_id;

select count(*) into b_i1 from bh_ng where ma_dvi =b_ma_dvi and so_id = b_so_id_hd;
if b_i1> 0  then
  select nv into b_nv_ng from bh_ng where ma_dvi =b_ma_dvi and so_id = b_so_id_hd;
  if b_nv_ng in ('SKG','SKT','SKC') then
    -- nguoi sk
    select count(*) into b_i1 from bh_sk_txt where so_id=b_so_id_hd and loai='dt_ct';
    if b_i1 <> 0 then
      select txt into hd_ct from bh_sk_txt where so_id = b_so_id_hd and loai='dt_ct';
    end if;
  elsif b_nv_ng in ('DLG','DLC','DLT') then
    -- nguoi DL
    select count(*) into b_i1 from bh_ngdl_txt where so_id=b_so_id_hd and loai='dt_ct';
    if b_i1 <> 0 then
      select txt into hd_ct from bh_ngdl_txt where so_id = b_so_id_hd and loai='dt_ct';
    end if;
  end if;
end if;

select kieu_hd into b_kieu_hd from bh_hd_goc where so_id = b_so_id_hd;
PKH_JS_THAYa(dt_ct,'kieu_hd', (case when b_kieu_hd = 'T' then unistr('\0054\00E1\0069') else unistr('\004D\1EDB\0069') end) );
b_tenh:= FKH_JS_GTRIs(hd_ct,'tenh');
if trim(b_tenh) is null then
  PKH_JS_THAYa(hd_ct,'tenh',FKH_JS_GTRIs(hd_ct,'ten'));
end if;

b_i1:= FKH_JS_GTRIn(hd_ct ,'ng_sinh');
if b_i1 = 30000101 or b_i1= 0 then PKH_JS_THAYa(hd_ct,'ng_sinh',' '); 
else PKH_JS_THAYa(hd_ct,'ng_sinh',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

b_i1:= FKH_JS_GTRIn(hd_ct ,'ngay_hl');
if b_i1 = 30000101 or b_i1= 0 then PKH_JS_THAYa(hd_ct,'ngay_hl',' '); 
else PKH_JS_THAYa(hd_ct,'ngay_hl',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

b_i1:= FKH_JS_GTRIn(hd_ct ,'ngay_kt');
if b_i1 = 30000101 or b_i1= 0 then PKH_JS_THAYa(hd_ct,'ngay_kt',' '); 
else PKH_JS_THAYa(hd_ct,'ngay_kt',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

--ls boi thuong
select JSON_ARRAYAGG(json_object(so_hs,'ngay_xr' value (case when nvl(ngay_xr,0)<>0 then TO_CHAR(pkh_so_cng_date(ngay_xr),'DD/MM/YYYY')else ' ' end),'ttrang' value (case when ttrang = 'D' then unistr('\0110\00E3\0020\0064\0075\0079\1EC7\0074') else unistr('\0110\0061\006E\0067\0020\0074\0072\00EC\006E\0068\0020\0070\0068\01B0\01A1\006E\0067\0020\00E1\006E') end),
  'tien' value FBH_CSO_TIEN(tien,b_nt_tien)) returning clob)
       into b_ls_bt FROM bh_bt_ng where so_id_hd = b_so_id_hd;
--thong tin thanh toan
select count(*) into b_i1 from bh_hd_goc_tthd where so_id = b_so_id_hd;
if b_i1 = 0 then
  b_ttrang_tt:= N'Chưa thanh toán';
else
  select sum(tien),max(ngay),max(so_id_tt) into b_tien_da_tt,b_ngay_da_tt,b_pthu from bh_hd_goc_tthd where so_id = b_so_id_hd;
  select sum(tien),max(ngay) into b_tien_tt,b_ngay_tt from bh_ng_tt where so_id = b_so_id_hd;
  IF TO_DATE(TO_CHAR(b_ngay_tt), 'YYYYMMDD') < TO_DATE(TO_CHAR(b_ngay_da_tt), 'YYYYMMDD') THEN
       b_ttrang_tt:= N'Đã thanh toán trước hạn';
  ELSE
      b_ttrang_tt:= N'Thanh toán trễ hạn';
  END IF;
  b_ngay_nop:= TO_CHAR(pkh_so_cng_date(b_ngay_da_tt),'DD/MM/YYYY');
end if;
PKH_JS_THAYa(dt_ct,'ttrang_tt,ngay_nop,pthu',b_ttrang_tt ||','||b_ngay_nop ||','|| b_pthu);
select json_object('dt_ct' value dt_ct,'dt_dk' value dt_dk,'hd_ct' value hd_ct,'ls_bt' value b_ls_bt,
  'dt_tlpt' value dt_tlpt,'dt_tltt' value dt_tltt,'bt_tltt' value bt_tltt,'bt_tlpt' value bt_tlpt,'bt_dk' value bt_dk returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;