create or replace procedure PBH_PKT_IN_BT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    -- chung
    b_loi varchar2(100); b_lenh varchar2(1000);
    -- orain
    b_ma_dvi varchar2(10);
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
    b_so_hs varchar2(30);
    b_i1 number := 0;b_i2 number := 0;b_count number := 0;
    dt_ct clob; dt_dvi clob; dt_dk clob; dt_hk clob; dt_tba clob; dt_kbt clob;dt_ttt clob;

    dt_tien_kn clob;dt_tien_bt clob;
     --thong tin hd
    b_so_id_hd number;
    hd_pt clob;hd_ds clob;hd_ttt clob;hd_kbt clob;hd_pvi clob;
    hd_tt clob;
    mkt_bb clob;mkt_rr clob;mkt_gdkd clob;
    dt_tai_bh clob;dt_gd clob;dt_mmt clob;dt_dong clob;
    b_dvi clob;
    hd_ct clob;
    b_ma_sp varchar2(10);b_ten_sp nvarchar2(500); b_ma_dt nvarchar2(500);
     ----bien kbt
    a_kbt_ma pht_type.a_var;a_kbt pht_type.a_clob;
    kbt_ma pht_type.a_var;kbt_nd pht_type.a_var;
    --pv
    a_pvbh_ma pht_type.a_var; a_pvbh_ten pht_type.a_nvar;a_pvbh_tc pht_type.a_var;a_pvbh_ktru pht_type.a_var;
    a_pvbh_loai pht_type.a_var;a_pvbh_ma_ct pht_type.a_var;
    a_pvbh_ma_dk pht_type.a_var;a_pvbh_ma_dk_ten pht_type.a_nvar;a_pvbh_ma_qtac pht_type.a_var;a_pvbh_ma_qtac_ten pht_type.a_nvar;
    a_pvbh_pttsb pht_type.a_var;a_pvbh_ptts pht_type.a_var;a_pvbh_ptkhb pht_type.a_var;a_pvbh_ptkh pht_type.a_var;

    b_n_temp nvarchar2(500):=' ';
    b_nt_tien varchar2(20):= ' ';
    b_tien number:=0;
    b_tien_bt number :=0;

    -- dong,tai
    b_ten_gd nvarchar2(500):=' ';b_tba_tien number:=0;
    a_tba_tien pht_type.a_num;
    b_mtn number:= 0;b_ten_nha_bh nvarchar2(500):=' ';
    b_tien_th number:=0;
    b_ten_temp nvarchar2(500):=' ';b_ma_temp varchar2(100);
    
    b_dong_mtn varchar2(100);b_dong_thudoi varchar2(100);
    b_so_id_ghep number;

    dt_phi clob;
    --a_tbh_tm_nbh,a_tbh_tm_pt
    a_tbh_tm_nbh pht_type.a_var;a_tbh_tm_pt pht_type.a_var;

begin
-- Dan - Xem

select so_id_hd,so_hs,ma_dvi into b_so_id_hd,b_so_hs,b_ma_dvi from bh_bt_pkt where so_id = b_so_id;

--dt_ct
select count(*) into b_i1 from bh_bt_pkt_txt t WHERE t.so_id = b_so_id AND t.loai='dt_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ct FROM bh_bt_pkt_txt t WHERE t.so_id = b_so_id AND t.loai='dt_ct';

  PKH_JS_THAYa(dt_ct,'so_hs',b_so_hs);
  PKH_JS_THAYa(dt_ct,'ngay_xr',TO_CHAR(TO_DATE(FKH_JS_GTRIs(dt_ct,'ngay_xr'), 'YYYYMMDD'), 'DD/MM/YYYY'));
  PKH_JS_THAYa(dt_ct,'ngay_hl',TO_CHAR(TO_DATE(FKH_JS_GTRIs(dt_ct,'ngay_hl'), 'YYYYMMDD'), 'DD/MM/YYYY'));
  PKH_JS_THAYa(dt_ct,'ngay_kt',TO_CHAR(TO_DATE(FKH_JS_GTRIs(dt_ct,'ngay_kt'), 'YYYYMMDD'), 'DD/MM/YYYY'));

  --nguyen nhan ton that
  b_n_temp:= FKH_JS_GTRIs(dt_ct,'ma_nn');
  if trim(b_n_temp) is not null then
    select count(1) into b_i1 from bh_pkt_nntt where ma = b_n_temp;
    if b_i1 <> 0 then
        select ten into b_n_temp from bh_pkt_nntt where ma = b_n_temp;
    end if;
  end if;
   PKH_JS_THAYa(dt_ct,'nn_tt',b_n_temp);
end if;

--tt dvi
  select json_object('ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
          'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
              from ht_ma_dvi where ma=b_ma_dvi;
  dt_ct:=FKH_JS_BONH(dt_ct);
  b_dvi:=FKH_JS_BONH(b_dvi);
  select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;
-- lay dt_dk
-- select count(*) into b_i1 from bh_bt_pkt t,bh_pkt_dk t1 where t.so_id_dt = t1.so_id_dt and t.so_id = b_so_id;
-- if b_i1 <> 0 then
--   SELECT JSON_ARRAYAGG(JSON_OBJECT(t1.ma_dvi,t1.so_id,t1.so_id_dt,t1.bt,t1.ma,t1.ten,t1.tc,t1.ma_ct,t1.kieu,
--                    t1.tien,t1.pt,t1.phi,t1.cap,t1.ma_dk,t1.ma_dkc,t1.lh_nv,t1.t_suat,t1.thue,
--                    t1.ttoan,t1.ptb,t1.ptg,t1.phig,t1.lkem,t1.lkep,t1.lkeb,t1.luy,t1.pvi_ma,t1.pvi_tc,t1.pvi_ktru) returning clob)
--                    INTO dt_dk from bh_bt_pkt t,bh_pkt_dk t1 where t.so_id_dt = t1.so_id_dt and t.so_id = b_so_id;
select count(*) into b_i1 from bh_bt_pkt_txt t WHERE t.so_id = b_so_id AND t.loai='dt_dk';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_dk FROM bh_bt_pkt_txt t WHERE t.so_id = b_so_id AND t.loai='dt_dk';
end if;
-- lay dt_dvi
select count(*) into b_i1 from bh_bt_pkt t,bh_pkt_dvi t1 where t.so_id_dt = t1.so_id_dt and t.so_id = b_so_id;
if b_i1 <> 0 then
  select JSON_OBJECT(t1.so_id_dt,t1.gcn) into dt_dvi from bh_bt_pkt t,bh_pkt_dvi t1 where t.so_id_dt = t1.so_id_dt and t.so_id = b_so_id and rownum = 1;
end if;
--dt_hk
select count(*) into b_i1 from bh_bt_pkt_txt t WHERE t.so_id = b_so_id AND t.loai='dt_hk';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_hk FROM bh_bt_pkt_txt t WHERE t.so_id = b_so_id AND t.loai='dt_hk';
end if;
-- lay dt_tba
select count(*) into b_i1 from bh_bt_pkt_txt t WHERE t.so_id = b_so_id AND t.loai='dt_tba';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_tba FROM bh_bt_pkt_txt t WHERE t.so_id = b_so_id AND t.loai='dt_tba';
end if;

--dt_kbt
select count(*) into b_i1 from bh_bt_pkt_txt t WHERE t.so_id = b_so_id AND t.loai='dt_kbt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_kbt FROM bh_bt_pkt_txt t WHERE t.so_id = b_so_id AND t.loai='dt_kbt';
end if;
-- lay dt_tba
select count(*) into b_i1 from bh_bt_pkt_txt t WHERE t.so_id = b_so_id AND t.loai='dt_ttt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ttt FROM bh_bt_pkt_txt t WHERE t.so_id = b_so_id AND t.loai='dt_ttt';
end if;
-------------thong tin hop dong
--hd_ct
select FKH_JS_BONH(t1.txt),t3.ma_sp INTO hd_ct,b_ma_sp from bh_pkt_txt t1,bh_bt_pkt t2,bh_pkt t3
    where t1.so_id = t2.so_id_hd and t1.so_id = t3.so_id and t2.so_id = b_so_id and t1.loai = 'dt_ct';
select upper(ten) into b_ten_sp from bh_pkt_sp WHERE ma=b_ma_sp;
b_lenh:=FKH_JS_LENH('ma_dt');
EXECUTE IMMEDIATE b_lenh into b_ma_dt using hd_ct;

b_nt_tien:= FKH_JS_GTRIs(hd_ct,'nt_tien');
b_tien_bt:= FKH_JS_GTRIn(dt_ct,'tien');

-- hl  bao hiem
PKH_JS_THAYa(dt_ct,'thoihan_bh',U'T\1EEB ' ||  FKH_JS_GTRIs(hd_ct,'gio_hl') || U' ng\00E0y ' ||  TO_CHAR(TO_DATE(FKH_JS_GTRIs(hd_ct,'ngay_hl'), 'YYYYMMDD'), 'DD/MM/YYYY') 
  || U' \0111\1EBFn ' ||   FKH_JS_GTRIs(hd_ct,'gio_kt') || U' ng\00E0y ' || TO_CHAR(TO_DATE(FKH_JS_GTRIs(hd_ct,'ngay_kt'), 'YYYYMMDD'), 'DD/MM/YYYY') 
);

PKH_JS_THAYa(hd_ct,'TEN_SP',b_ten_sp);
PKH_JS_THAYa(hd_ct,'MA_DT',PKH_MA_TENl(b_ma_dt));
-- thong tin kvuc
b_n_temp:=' ';
select count(1) into b_i1 from bh_ma_kvuc t1, ht_ma_dvi t2 where t1.ma = t2.kvuc and t2.ma = b_ma_dvi;
if b_i1 <> 0 then
  select NVL(t1.ten,' ') into b_n_temp from bh_ma_kvuc t1, ht_ma_dvi t2 where t1.ma = t2.kvuc and t2.ma = b_ma_dvi;
end if;
PKH_JS_THAYa(dt_ct,'kvuc',b_n_temp);

PKH_JS_THAYa(dt_ct,'ngay',TO_CHAR(SYSDATE, 'DD'));
PKH_JS_THAYa(dt_ct,'thang',TO_CHAR(SYSDATE, 'MM'));
PKH_JS_THAYa(dt_ct,'nam',TO_CHAR(SYSDATE, 'YYYY'));
--hd kbt
select count(*) into b_i1 from bh_pkt_kbt t where t.so_id = b_so_id_hd;
if b_i1 <> 0 then
    select FKH_JS_BONH(kbt) into hd_kbt from bh_pkt_kbt where so_id=b_so_id_hd;
    if DBMS_LOB.GETLENGTH(hd_kbt) < 10 then
      hd_kbt:= null;
     else
     --xu ly kbt
      b_lenh := FKH_JS_LENH('ma,kbt');
      EXECUTE IMMEDIATE b_lenh bulk collect INTO a_kbt_ma,a_kbt USING hd_kbt;
      delete temp_1;
      for b_lp in 1..a_kbt_ma.count loop
        if a_kbt(b_lp) is not null then
          b_lenh:=FKH_JS_LENH('ma,nd');
          EXECUTE IMMEDIATE b_lenh bulk collect into kbt_ma,kbt_nd using a_kbt(b_lp);
          for b_lp1 in 1..kbt_ma.count loop
            insert into temp_1(C1,C2) values(FBH_IN_GBT(kbt_nd(b_lp1),kbt_ma(b_lp1)),a_kbt_ma(b_lp));
          end loop;
        end if;
      end loop; 
    end if;
    select JSON_ARRAYAGG(json_object('ND' VALUE C1,'MA' value C2) returning clob) into hd_kbt from TEMP_1;
    delete TEMP_1;
end if;
---hd_pvi
select count(*) into b_i1 from bh_pkt_txt t where  t.so_id = b_so_id_hd AND t.loai='ds_pvi';
if b_i1 <> 0 then
    select FKH_JS_BONH(txt) into hd_pvi from bh_pkt_txt where  so_id=b_so_id_hd and loai='ds_pvi';
end if;

delete temp_1;
delete temp_2;
delete temp_3;
if hd_pvi='""' then hd_pvi:=''; else hd_pvi:=substr(hd_pvi,3,length(hd_pvi)-4); end if;
if hd_pvi <> '""' then
  hd_pvi:= REPLACE(hd_pvi, '\', '');
  b_lenh := FKH_JS_LENH('ten,ma,pttsb,ptts,ptkhb,ptkh,tc,ktru,loai,ma_ct');
       EXECUTE IMMEDIATE b_lenh bulk collect INTO a_pvbh_ten,a_pvbh_ma,a_pvbh_pttsb,a_pvbh_ptts,a_pvbh_ptkhb,a_pvbh_ptkh,a_pvbh_tc,a_pvbh_ktru,a_pvbh_loai,a_pvbh_ma_ct USING hd_pvi;
       for b_lp in 1..a_pvbh_ma.count loop
          -- neu tc <> M la thiet hai tai san insert vao temp_7
          if a_pvbh_tc(b_lp) <> 'M' then
             --- tinh muc khau tru thiet hai ts
             if a_pvbh_tc(b_lp) = 'B' then
               insert into temp_3(c1,c2) values(a_pvbh_ten(b_lp), '- ' || a_pvbh_ten(b_lp) || ': ' || FBH_MKT(a_pvbh_ktru(b_lp),b_nt_tien));
             else
                if a_pvbh_loai(b_lp) <> 'T' then
                  -- neu ma pvi nay co a_pvbh_ktru thi tinh muc khau tru
                  if trim(a_pvbh_ktru(b_lp)) is not null then
                    insert into temp_2(c1,c2) values('- ' || a_pvbh_ten(b_lp),'- ' || a_pvbh_ten(b_lp) || ': ' ||FBH_MKT(a_pvbh_ktru(b_lp),b_nt_tien));
                  --neu ko thi lay theo ma_ct
                  else
                    for b_lp2 in 1..a_pvbh_ma.count loop
                      if a_pvbh_ma_ct(b_lp) = a_pvbh_ma(b_lp2) and b_i2 = 0 then
                          b_i2:= b_i2 +1;
                          if trim(a_pvbh_ktru(b_lp2)) is not null then
                            insert into temp_2(c1,c2) values(U'- C\00E1c r\1EE7i ro kh\00E1c',U'- C\00E1c r\1EE7i ro kh\00E1c: ' ||FBH_MKT(a_pvbh_ktru(b_lp2),b_nt_tien));
                          else
                            insert into temp_2(c1,c2) values(U'- C\00E1c r\1EE7i ro kh\00E1c',U'- C\00E1c r\1EE7i ro kh\00E1c: kh\00F4ng \00E1p d\1EE5ng m\1EE9c kh\1EA9u tr\1EEB');
                          end if;
                      end if;
                    end loop;
                  end if;
                end if;
             end if;
             -- end tinh muc khau tru thiet hai ts
          else
             --- tinh muc khau tru
            insert into temp_1(c1,c2) values(a_pvbh_ten(b_lp), U'Gi\00E1n \0111o\1EA1n kinh doanh ' || TO_NUMBER(REGEXP_SUBSTR(a_pvbh_ktru(b_lp), '^\d+')) || U' ng\00E0y l\00E0m vi\1EC7c li\00EAn t\1EE5c');
             -- end tinh mkt
          end if;
      end loop;
end if;
-- mkt_bb clob;mkt_rr clob;mkt_gdkd clob;
select JSON_ARRAYAGG(json_object('TEN' VALUE c1,'ND' value c2) returning clob) into mkt_bb FROM TEMP_3;
select JSON_ARRAYAGG(json_object('TEN' VALUE c1,'ND' value c2) returning clob) into mkt_rr FROM TEMP_2;
select JSON_ARRAYAGG(json_object('TEN' VALUE c1,'ND' value c2) returning clob) into mkt_gdkd FROM TEMP_1;
delete temp_1;
delete temp_2;
delete temp_3;
--thong tin thanh toan
select count(1) into b_i1 FROM bh_pkt_tt where so_id = b_so_id_hd;
if b_i1 <> 0 then
select JSON_ARRAYAGG(json_object('TEN' VALUE  (trim(TO_CHAR(tien, '999,999,999,999,999,999PR')) || ' ' || b_nt_tien || U' thanh to\00E1n ng\00E0y ' || TO_CHAR(TO_DATE(ngay, 'YYYYMMDD'), 'DD/MM/YYYY')  ) ) returning clob) 
  into hd_tt FROM bh_pkt_tt where so_id = b_so_id_hd;
end if;

---khieu nai,bt dt_tien_kn clob;dt_tien_bt clob;
select JSON_ARRAYAGG(json_object('TEN' VALUE ten,'TIEN' value trim(TO_CHAR(t_that, '999,999,999,999,999,999PR')) || ' ' || b_nt_tien ) returning clob) into dt_tien_kn from bh_bt_pkt_dk where so_id = b_so_id and tc = 'T' and t_that <> 0;
select JSON_ARRAYAGG(json_object('TEN' VALUE ten,'TIEN' value trim(TO_CHAR(tien_qd, '999,999,999,999,999,999PR')) || ' ' || b_nt_tien ) returning clob) into dt_tien_bt from bh_bt_pkt_dk where so_id = b_so_id and tc = 'T' and t_that <> 0;

select sum(t_that) into b_i1 from bh_bt_pkt_dk where so_id = b_so_id and tc = 'C' and t_that <> 0;
PKH_JS_THAY(dt_ct,'tien_kn',(trim(TO_CHAR(b_i1, '999,999,999,999,999,999PR')) || ' ' || b_nt_tien));
select sum(tien_qd) into b_i1 from bh_bt_pkt_dk where so_id = b_so_id and tc = 'C' and t_that <> 0;
PKH_JS_THAY(dt_ct,'tien_bt',(trim(TO_CHAR(b_i1, '999,999,999,999,999,999PR')) || ' ' || b_nt_tien));

-- lay danh sach don vi giam dinh
delete temp_3;
select count(*) into b_i1 from BH_BT_GD_HS where so_id_bt = b_so_id and ma_gd is not null;
if b_i1 <> 0 then
  b_count:= 1;
  for r_lp in (select ma_gd from BH_BT_GD_HS where so_id_bt = b_so_id group by ma_gd)
  loop
      select ten into b_ten_gd from bh_ma_gdinh where ma =r_lp.ma_gd;
      insert into temp_3(C1) values( U'- Nh\00E0 \0111\1ED3ng ' || b_count || ': ' ||b_ten_gd);
      b_count:= b_count + 1;
  end loop;
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1) returning clob) into dt_gd from TEMP_3;
delete temp_3;
-- thu doi dong bh
delete temp_2;
select tien into b_mtn from bh_pkt where so_id = b_so_id_hd;
select NVL(sum(tien),0) into b_tien_th from BH_HD_DO_PS  where so_id = b_so_id_hd and loai in('DT_LE_BT','DT_LE_GD');
select count(*) into b_i1 from BH_HD_DO_TL where so_id = b_so_id_hd;
if b_i1 <> 0 then
  b_count:= 1;
  for r_lp in (select nha_bh,pt from BH_HD_DO_TL where so_id = b_so_id_hd)
  loop
      b_dong_mtn:= trim(TO_CHAR(r_lp.pt * b_mtn, '999,999,999,999,999,999PR')) || ' ' || b_nt_tien;
      b_dong_thudoi:= trim(TO_CHAR(b_tien_th, '999,999,999,999,999,999PR'))|| ' ' || b_nt_tien;
      select ten into b_ten_nha_bh from BH_MA_NBH where ma =r_lp.nha_bh;
      --insert into temp_2(C1) values(b_ten_nha_bh || ': ' || r_lp.pt || N'% d?ng, MTN: ' || b_dong_mtn || N' s? ti?n thu d�i: ' || b_dong_thudoi );
      insert into temp_2(N1,C1,C2,C3) values(b_count,b_ten_nha_bh, r_lp.pt || U'%',b_dong_thudoi );
      b_count:= b_count +1;
  end loop;
end if;

select JSON_ARRAYAGG(json_object('STT' VALUE N1,'TEN' value C1, 'TYLE' value C2, 'TIEN' value C3) returning clob) into dt_dong from temp_2;
delete temp_2;
--
delete temp_1;
delete temp_2;
for r_lp in(select ps.so_id,ps.so_id_ta_ps,ps.so_id_ta_hd,ps.goc,ps.pthuc,ps.tien,ps.nha_bh from tbh_ps ps,bh_bt_tu tu
    where ps.so_id = tu.so_id and tu.so_id_hs = b_so_id
    union
    select ps.so_id,ps.so_id_ta_ps,ps.so_id_ta_hd,ps.goc,ps.pthuc,ps.tien,ps.nha_bh from tbh_ps ps,bh_bt_pkt bt
    where ps.so_id = bt.so_id and bt.so_id = b_so_id
    union
    select ps.so_id,ps.so_id_ta_ps,ps.so_id_ta_hd,ps.goc,ps.pthuc,ps.tien,ps.nha_bh from tbh_ps ps,bh_bt_gd_hs gd
    where ps.so_id = gd.so_id and gd.so_id_bt = b_so_id
    union
--     select ps.so_id,ps.so_id_ta_ps,ps.so_id_ta_hd,ps.goc,ps.pthuc,ps.tien,ps.nha_bh from tbh_ps ps,bh_bt_tba tba
--     where ps.so_id = tba.so_id and tba.so_id_hs = b_so_id
--     union
    select ps.so_id,ps.so_id_ta_ps,ps.so_id_ta_hd,ps.goc,ps.pthuc,ps.tien,ps.nha_bh from tbh_ps ps,bh_bt_thoi thoi
    where ps.so_id = thoi.so_id and thoi.so_id_hs = b_so_id
    union
    select ps.so_id,ps.so_id_ta_ps,ps.so_id_ta_hd,ps.goc,ps.pthuc,ps.tien,ps.nha_bh from tbh_ps ps
    where ps.so_id_ta_ps = b_so_id)
loop
  insert into temp_1(N1,N2,N3,C1,C2,N4,C3) values(r_lp.so_id,r_lp.so_id_ta_ps,r_lp.so_id_ta_hd,r_lp.goc,r_lp.pthuc,r_lp.tien,r_lp.nha_bh);
end loop;
b_tien_th:= 0;
b_count:= 2;
for r_lp in(
  select ma,ten,nha_bh from(select ps.C3 ma,nbh.ten ten,ps.C3 nha_bh from temp_1 ps, BH_MA_NBH nbh
  where ps.C3 = nbh.ma)
  group by ma,ten,nha_bh)
loop
  
  select NVL(sum(N4),0) into b_i1 from temp_1 where C1 IN('BT_HS','BT_GD') and C3 = r_lp.ma; 
  select NVL(sum(N4),0) into b_i2 from temp_1 where C1 IN('BT_TB','BT_TH') and C3 = r_lp.ma; 
  b_i1:= b_i1 - b_i2;
  b_tien_th:= b_tien_th + b_i1;
  insert into temp_2(N1,C1,N2,N3,C4) values(b_count,r_lp.ten,0,b_i1,r_lp.nha_bh);
  b_count:= b_count + 1;
end loop;
-- tinh tong tien
select NVL(sum(tien),0) into b_i1 from (select tien from bh_bt_pkt where so_id = b_so_id
union select tien from bh_bt_gd_hs where so_id_bt = b_so_id);

select NVL(sum(tien),0) into b_i2 from (
select tien from bh_bt_thoi where so_id_hs = b_so_id
union
select tien from bh_bt_tba where so_id_bt = b_so_id
);
b_tien := b_i1 - b_i2;
--insert into temp_2(N1,C1,N2,C3,C4) values(1,N'B?o hi?m AAA',0,(trim(TO_CHAR(b_tien - b_tien_th, '999,999,999,999,999,999PR'))|| ' ' || b_nt_tien ),'AAA');
insert into temp_2(N1,C1,N2,N3,C4) values(1,U'B\1EA3o hi\1EC3m AAA',0,(b_tien - b_tien_th),'AAA');
--- tinh tyle
b_i1:= 0;
b_count:=0;
for r_lp in(
  select t1.so_id_ta_ps, t1.pthuc,t1.nha_bh from (select ps.* from tbh_ps ps,bh_bt_tu tu
  where ps.so_id = tu.so_id and tu.so_id_hs = b_so_id
  union
  select ps.* from tbh_ps ps,bh_bt_pkt bt
  where ps.so_id = bt.so_id and bt.so_id = b_so_id
  union
  select ps.* from tbh_ps ps,bh_bt_gd_hs gd
  where ps.so_id = gd.so_id and gd.so_id_bt = b_so_id
  union
  select ps.* from tbh_ps ps,bh_bt_tba tba
  where ps.so_id = tba.so_id and tba.so_id_bt = b_so_id
  union
  select ps.* from tbh_ps ps,bh_bt_thoi thoi
  where ps.so_id = thoi.so_id and thoi.so_id_hs = b_so_id
  union
  select ps.* from tbh_ps ps
  where ps.so_id_ta_ps = b_so_id) t1 group by so_id_ta_ps,pthuc,nha_bh
)
loop
  if r_lp.pthuc in('Q','S') then
      select sum(pt) into b_i1 from TBH_GHEP_KY where so_id = r_lp.so_id_ta_ps and r_lp.nha_bh = r_lp.nha_bh and pthuc = r_lp.pthuc;
      
  elsif r_lp.pthuc = 'F' then
    select FKH_JS_BONH(txt) into dt_phi  from TBH_TM_TXT where so_id = r_lp.so_id_ta_ps and loai = 'dt_phi';
    --a_tbh_tm_nbh,a_tbh_tm_pt
    b_lenh:=FKH_JS_LENH('nbh,pt');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_tbh_tm_nbh,a_tbh_tm_pt using dt_phi;
    for b_lp in 1..a_tbh_tm_nbh.count loop
      if a_tbh_tm_nbh(b_lp) = r_lp.nha_bh then
        b_i1:= FBH_TONUM(a_tbh_tm_pt(b_lp));
      end if;
    end loop;
  elsif r_lp.pthuc = 'X' then
    ---lay ra so tien cua nha bh
    SELECT N3 into b_tien FROM temp_2 where C4 = r_lp.nha_bh;
    b_i1:= ROUND(b_tien * 100 / b_tien_bt, 2);
  end if;
  b_count:= b_count + b_i1;
  --neu nha_bh tai nhieu pt thi cong lai
  select N2 into b_i2 from temp_2 where  C4 = r_lp.nha_bh;
  b_i1:= b_i1 + b_i2;
  update temp_2 set N2 = b_i1 where C4 = r_lp.nha_bh;
end loop;
update temp_2 set N2 = (100 - b_count) where C4 = 'AAA';

---end tyle

select JSON_ARRAYAGG(json_object('STT' VALUE N1,'TEN' value C1, 'TYLE' value (trim(TO_CHAR(ROUND(N2, 2), '9990D99', 'NLS_NUMERIC_CHARACTERS=''.,''')) || '%'), 'TIEN' value FBH_CSO_TIEN(N3,b_nt_tien)) order by N1 returning clob) into dt_tai_bh from temp_2;
delete temp_2;
delete temp_1;

--end tai bh
select count(*) into b_i1 from bh_pkt_txt t where  t.so_id = b_so_id_hd AND t.loai='ds_ct';
if b_i1 <> 0 then
    select FKH_JS_BONH(txt) into hd_ds from bh_pkt_txt where  so_id=b_so_id_hd and loai='ds_ct';
end if;



select json_object('dt_ct' value dt_ct,'dt_dvi' value dt_dvi,'dt_dk' value dt_dk,'dt_hk' value dt_hk,
    'dt_tba' value dt_tba,'dt_kbt' value dt_kbt,'dt_ttt' value dt_ttt,'hd_ct' value hd_ct,
    'mkt_bb' value mkt_bb,'mkt_rr' value mkt_rr,'mkt_gdkd' value mkt_gdkd, 'hd_tt' value hd_tt,
    'dt_tien_kn' value dt_tien_kn, 'dt_tien_bt' value dt_tien_bt,'dt_gd' value dt_gd,'dt_dong' value dt_dong,'dt_tai_bh' value dt_tai_bh,
    'hd_ds' value hd_ds
     returning clob) into b_oraOut from dual;

exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
