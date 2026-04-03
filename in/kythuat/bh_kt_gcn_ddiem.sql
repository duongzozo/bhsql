create or replace procedure PBH_PKT_HD_GCN(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    -- chung
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_i1 number := 0;b_i2 number:=0;
    -- orain
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id_dt number :=FKH_JS_GTRIn(b_oraIn,'so_id_dt');
    b_gcn varchar2(20) :=FKH_JS_GTRIs(b_oraIn,'gcn');
    b_so_hd varchar2(50) :=FKH_JS_GTRIs(b_oraIn,'so_hd');
    b_so_id number:=0;

    dt_ct clob; dt_dkbs clob; dt_ds clob; dt_dk clob; dt_lt clob;dt_kbt clob; dt_ttt clob;dt_dong clob;
    b_kh_ttt clob;dt_qt clob;dt_tt clob;b_dvi clob;dt_hu clob;
    ds_ct clob;ds_pvi clob;ds_dk clob;ds_dkbs clob;ds_lt clob;ds_dkth clob;ds_kbt clob;ds_ttt clob;

    b_temp_clob clob;a_clob pht_type.a_clob;

    b_ten_dvi nvarchar2(500):= ' ';
    b_temp_var varchar2(100);b_temp_nvar varchar2(500);
    b_ma_kvuc varchar2(20);
    b_ten_kvuc nvarchar2(500):= ' ';
    b_nt_tien varchar2(50);
    b_ma_kt varchar2(50);b_kieu_kt varchar2(1);b_ngay_tt number;
    ---kbt
    a_kbt_ma_dk pht_type.a_var; a_kbt_kbt pht_type.a_nvar;
    a_kbt_nd pht_type.a_var; a_kbt_ma pht_type.a_nvar;

    --a dt_dk
    a_dk_ma pht_type.a_var;a_dk_ten pht_type.a_nvar; a_dk_tien pht_type.a_num;a_dk_tienkb pht_type.a_num;
    a_dk_phi pht_type.a_num;a_dk_thue pht_type.a_num;
    a_dk_cap pht_type.a_num;a_dk_gvu pht_type.a_var;a_dk_ma_ct pht_type.a_var;a_dk_kieu pht_type.a_var;
    a_dk_mota pht_type.a_nvar;
    --a dt_hu
    a_hu_ten pht_type.a_nvar;a_hu_cmt pht_type.a_var; a_hu_mobi pht_type.a_var;a_hu_email pht_type.a_var;
    a_hu_dchi pht_type.a_nvar;a_hu_ng_ddien pht_type.a_nvar;a_hu_chucvu pht_type.a_nvar;
    -- a_pvi
    a_pvbh_ma pht_type.a_var; a_pvbh_ten pht_type.a_nvar;a_pvbh_tc pht_type.a_var;a_pvbh_ktru pht_type.a_var;
    a_pvbh_loai pht_type.a_var;a_pvbh_ma_ct pht_type.a_var;
    a_pvbh_ma_dk pht_type.a_var;a_pvbh_ma_dk_ten pht_type.a_nvar;a_pvbh_ma_qtac pht_type.a_var;a_pvbh_ma_qtac_ten pht_type.a_nvar;
    a_pvbh_pttsb pht_type.a_var;a_pvbh_ptts pht_type.a_var;a_pvbh_ptkhb pht_type.a_var;a_pvbh_ptkh pht_type.a_var;
    -- a_dkbs
    a_ten pht_type.a_nvar;a_ma pht_type.a_var;a_ma_dkc pht_type.a_var;a_dkp pht_type.a_nvar;
    ---
    dt_pvi clob;
    dt_bs_chung clob;dt_bs_vc clob;dt_bs_gdkd clob;dt_bs_t3 clob;
    dt_dk_v clob;dt_dk_g clob;dt_dk_bi clob;
    ---
    b_tlp_v number:=0;b_tlp_bb number:=0;b_tlp_rr number:=0;b_tlp_g number:=0;b_tlp_bi number:=0;
    b_phi_v number:=0;b_phi_bb number:=0;b_phi_rr number:=0;b_phi_g number:=0;b_phi_bi number:=0;
    b_tong_tien_v number:= 0;b_tong_tien_g number:=0;b_tong_tien_bi number:= 0;b_tien_hh number;
    --mkt
    b_mkt_b clob;b_mkt_c clob;b_mkt_d clob;b_mkt_m clob;b_mkt_p clob;
    --quy tac
    qt_bc clob;qt_m clob; qt_p clob;qt_d clob;
     --a dong bh
    dt_dong_bh clob;
    a_dong_nha_bh pht_type.a_nvar;a_dong_pt pht_type.a_num;a_dong_tien pht_type.a_num;a_dong_phi pht_type.a_num;

    b_index number:=1;
begin
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
b_so_id:= FBH_HD_GOC_SO_ID(b_ma_dvi,b_so_hd);
--dt_hu
select count(*) into b_i1 from bh_pkt_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_hu';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_hu FROM bh_pkt_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_hu';
  b_lenh := FKH_JS_LENH('ten,cmt,mobi,email,dchi,ng_ddien,chucvu');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_hu_ten,a_hu_cmt,a_hu_mobi,a_hu_email,a_hu_dchi,a_hu_ng_ddien,a_hu_chucvu USING dt_hu;
  delete temp_2;commit;
  b_i1:= 1;
  for b_lp in 1..a_hu_ten.count loop
    b_temp_nvar:= N'NGƯỜI THỤ HƯỞNG THỨ ' || FBH_IN_SO_CHU(b_i1) || ': ' || a_hu_ten(b_lp);
    insert into temp_2(C1,c2,c3,c4,c5,c6,c7) values(b_temp_nvar,a_hu_cmt(b_lp),a_hu_mobi(b_lp),a_hu_email(b_lp),a_hu_dchi(b_lp),a_hu_ng_ddien(b_lp),a_hu_chucvu(b_lp));
    b_i1:= b_i1 +1;
  end loop;
  select JSON_ARRAYAGG(json_object('ten' VALUE C1,'cmt' VALUE C2,'mobi' VALUE C3,'email' VALUE C4,'dchi' VALUE C5,
  'ng_ddien' VALUE C6,'chucvu' VALUE C7  returning clob) returning clob) into dt_hu from temp_2;

  delete temp_2;commit;
end if;
--dt-ct
select count(*) into b_i1 from bh_pkt_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ct FROM bh_pkt_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_ct';
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

    b_i1:= FKH_JS_GTRIn(dt_ct ,'gia');
    PKH_JS_THAY(dt_ct,'gia',FBH_CSO_TIEN(b_i1,b_nt_tien) );

    b_i1:= FKH_JS_GTRIn(dt_ct ,'thue');
    PKH_JS_THAY(dt_ct,'thue',FBH_CSO_TIEN(b_i1,b_nt_tien) );

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ttoan');
    PKH_JS_THAY(dt_ct,'ttoan',FBH_CSO_TIEN(b_i1,b_nt_tien) );
    PKH_JS_THAYa(dt_ct,'bangchu',FBH_IN_CSO_CHU(b_i1,b_nt_tien) );

    
end if;
 SELECT '{' || LISTAGG('"' || ma || '": ""', ',') WITHIN GROUP (ORDER BY ma) || '}' into b_kh_ttt
    FROM bh_kh_ttt WHERE nv = 'PKT' AND ps = 'HD';
    dt_ct:=FKH_JS_BONH(dt_ct);
    b_kh_ttt:=FKH_JS_BONH(b_kh_ttt);
    select json_mergepatch(dt_ct,b_kh_ttt) into dt_ct from dual;
---ds_ct
select count(*) into b_i1 from bh_pkt_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO b_temp_clob FROM bh_pkt_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_ct';
  if b_temp_clob <> '[""]' then
    b_lenh:=FKH_JS_LENHc('');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_clob using b_temp_clob;
    for b_lp in 1..a_clob.count loop
      if FKH_JS_GTRIn(a_clob(b_lp) ,'so_id_dt') = b_so_id_dt then
        b_index:= b_lp;
      end if;
    end loop;

    ds_ct:= a_clob(b_index);
    PKH_JS_THAY(dt_ct,'dvi',FKH_JS_GTRIs(ds_ct ,'dvi') );
    PKH_JS_THAY(dt_ct,'ddiemc',FKH_JS_GTRIs(ds_ct ,'ddiemc') );
    PKH_JS_THAY(dt_ct,'lvuc',FKH_JS_GTRIs(ds_ct ,'lvuc') );
    b_temp_nvar:= FBH_IN_SUBSTR(FKH_JS_GTRIs(ds_ct ,'ma_nct'),'|','S');
    PKH_JS_THAY(dt_ct,'ma_nct',b_temp_nvar);

    if trim(FKH_JS_GTRIs(ds_ct ,'mo_ta')) is not null then
         PKH_JS_THAY(dt_ct,'mota',FKH_JS_GTRIs(ds_ct ,'mo_ta'));
    else
      b_temp_nvar:= N'Kể từ ngày khởi công công trình (ngày '|| FKH_JS_GTRIs(dt_ct ,'ngay_hl') || N') đến khi công trình hoàn thành đưa vào sử dụng (ngày '|| FKH_JS_GTRIs(dt_ct ,'ngay_kt')  ||')';
      PKH_JS_THAY(dt_ct,'mota',b_temp_nvar);
    end if;

    select json_object('tt_ctrinh' VALUE FKH_JS_GTRIs(ds_ct ,'tt_ctrinh'),'tt_tbi' value FKH_JS_GTRIs(ds_ct ,'tt_tbi') returning clob) into b_temp_clob from dual;
    select json_mergepatch(dt_ct,b_temp_clob) into dt_ct from dual;

  end if;
end if;

-------------ds_dkbs
delete temp_1;delete temp_4;commit;
select count(*) into b_i1 from bh_pkt_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_dkbs';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO b_temp_clob FROM bh_pkt_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_dkbs';
  if b_temp_clob <> '[""]' then
    b_lenh:=FKH_JS_LENHc('');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_clob using b_temp_clob;
    ds_dkbs:= a_clob(b_index);
    b_lenh := FKH_JS_LENH('ten,ma,ma_dkc,dkp');
    b_temp_clob:= ' ';
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ten,a_ma,a_ma_dkc,a_dkp USING ds_dkbs;
    for b_lp in 1..a_ten.count loop
        b_temp_nvar:= a_ten(b_lp);
        if trim(a_dkp(b_lp)) is not null then b_temp_nvar:= b_temp_nvar || '(' || a_dkp(b_lp) || ')';end if;
        insert into temp_1(c1,c2) values(b_temp_nvar,a_ma_dkc(b_lp));
        ---
        select count(*) into b_i1 from bh_ma_dkbs where ma = a_ma(b_lp);
        if b_i1 <> 0 then
           SELECT FKH_JS_GTRIc(FKH_JS_BONH(t.txt) ,'nd') into b_temp_clob from bh_ma_dkbs t where  t.ma= a_ma(b_lp) and rownum = 1;
        end if;
        insert into temp_4(c1,c2,cl1) values(a_ma(b_lp),a_ten(b_lp),b_temp_clob);
    end loop;
  end if;
end if;
--dt_dkbs
select count(*) into b_i1 from bh_pkt_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_dkbs';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_dkbs FROM bh_pkt_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_dkbs';
  b_lenh := FKH_JS_LENH('ten,ma,ma_dkc,dkp');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ten,a_ma,a_ma_dkc,a_dkp USING dt_dkbs;
  b_temp_clob:= ' ';
  for b_lp in 1..a_ten.count loop
      b_temp_nvar:= a_ten(b_lp);
      if trim(a_dkp(b_lp)) is not null then b_temp_nvar:= b_temp_nvar || '(' || a_dkp(b_lp) || ')';end if;
      insert into temp_1(c1,c2) values(b_temp_nvar,a_ma_dkc(b_lp));
      --
      select count(*) into b_i1 from bh_ma_dkbs where ma = a_ma(b_lp);
      if b_i1 <> 0 then
          SELECT FKH_JS_GTRIc(FKH_JS_BONH(t.txt) ,'nd') into b_temp_clob from bh_ma_dkbs t where  t.ma= a_ma(b_lp) and rownum = 1;
      end if;
      insert into temp_4(c1,c2,cl1) values(a_ma(b_lp),a_ten(b_lp),b_temp_clob);
  end loop;
end if;



select JSON_ARRAYAGG(json_object('ma' VALUE C1,'ten' value c2, 'nd' value cl1 returning clob) returning clob) into dt_dkbs from temp_4;
delete temp_4;commit;
-----------------dt_lt
select count(*) into b_i1 from bh_pkt_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_lt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO b_temp_clob FROM bh_pkt_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_lt';
  if b_temp_clob <> '[""]' then
    b_lenh:=FKH_JS_LENHc('');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_clob using b_temp_clob;
    dt_lt:= a_clob(b_index);
    b_lenh := FKH_JS_LENH('ten,ma_lt');
    b_temp_clob:= ' ';
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ten,a_ma USING dt_lt;
    for b_lp in 1..a_ten.count loop
        select count(*) into b_i1 from bh_ma_dklt where ma = a_ma(b_lp);
        if b_i1 <> 0 then
          select ma_dk into b_temp_nvar from bh_ma_dklt where ma = a_ma(b_lp);
          SELECT FKH_JS_GTRIc(FKH_JS_BONH(t.txt) ,'nd') into b_temp_clob from bh_ma_dklt t where  t.ma= a_ma(b_lp) and rownum = 1;
        end if;
        insert into temp_4(c1,c2,cl1) values(a_ma(b_lp),a_ten(b_lp),b_temp_clob);
        insert into temp_1(c1,c2) values(a_ten(b_lp),b_temp_nvar);
    end loop;
  end if;
end if;
--dt_lt
select count(*) into b_i1 from bh_pkt_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_lt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_lt FROM bh_pkt_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_lt';
  b_lenh := FKH_JS_LENH('ten,ma_lt');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ten,a_ma USING dt_lt;
  for b_lp in 1..a_ten.count loop
      select count(*) into b_i1 from bh_ma_dklt where ma = a_ma(b_lp);
      if b_i1 <> 0 then
          select ma_dk into b_temp_nvar from bh_ma_dklt where ma = a_ma(b_lp);
          SELECT FKH_JS_GTRIc(FKH_JS_BONH(t.txt) ,'nd') into b_temp_clob from bh_ma_dklt t where  t.ma= a_ma(b_lp) and rownum = 1;
      end if;
      insert into temp_4(c1,c2,cl1) values(a_ma(b_lp),a_ten(b_lp),b_temp_clob);
      insert into temp_1(c1,c2) values(a_ten(b_lp),b_temp_nvar);
  end loop;
end if;
select JSON_ARRAYAGG(json_object('ma' VALUE C1,'ten' value c2, 'nd' value cl1 returning clob) returning clob) into dt_lt from temp_4;

select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_bs_chung from temp_1 where trim(c2) is null;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_bs_vc from temp_1 where c2  = 'KT_THVC';
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_bs_gdkd from temp_1 where c2 = 'KT_GDKD';
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_bs_t3 from temp_1 where c2 = 'KT_TNTB';

delete temp_4;delete temp_1;commit;
---ds_pvi
select count(*) into b_i1 from bh_pkt_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_pvi';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO b_temp_clob FROM bh_pkt_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_pvi';
  if b_temp_clob <> '[""]' then
    b_lenh:=FKH_JS_LENHc('');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_clob using b_temp_clob;
    ds_pvi:= a_clob(b_index);
    if ds_pvi <> '"[]"' then
        b_lenh := FKH_JS_LENH('ten,ma,pttsb,ptts,ptkhb,ptkh,tc,ktru,loai,ma_ct');
        EXECUTE IMMEDIATE b_lenh bulk collect INTO a_pvbh_ten,a_pvbh_ma,a_pvbh_pttsb,a_pvbh_ptts,a_pvbh_ptkhb,a_pvbh_ptkh,a_pvbh_tc,a_pvbh_ktru,a_pvbh_loai,a_pvbh_ma_ct USING ds_pvi;
        delete temp_1;delete temp_2;commit;
        for b_lp in 1..a_pvbh_ma.count loop
            select loai into b_temp_var from bh_pkt_pvi where ma = a_pvbh_ma(b_lp);
            --- lay pvi bao hiem
            if a_pvbh_tc(b_lp) = 'C' and b_temp_var = 'C' then
            insert into temp_1(C1) values( a_pvbh_ten(b_lp));
            end if;
            -- lay quy tac
            select count(*) into b_i1 from bh_pkt_pvi p, bh_ma_qtac q where p.ma_qtac = q.ma and p.ma = a_pvbh_ma(b_lp);
            if b_i1 <> 0 then
                select NVL(q.ten,' ') into b_temp_nvar from bh_pkt_pvi p, bh_ma_qtac q where p.ma_qtac = q.ma and p.ma = a_pvbh_ma(b_lp);
                insert into temp_2(C1,C2) values(b_temp_nvar,b_temp_var);
            end if;

        end loop;
        select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_pvi from temp_1;
        delete temp_1;commit;
        --qt_bc clob;qt_m clob; qt_p clob;
        select count(*) into b_i1 from  temp_2 where c2 in ('B','C','P');
        if b_i1 <> 0 then
            select JSON_ARRAYAGG(json_object('ten' VALUE C1 returning clob) returning clob) into qt_bc from temp_2 where c2 in ('B','C') ;
        end if;
        select count(*) into b_i1 from  temp_2 where c2  = 'M';
        if b_i1 <> 0 then
            select JSON_ARRAYAGG(json_object('ten' VALUE C1 returning clob) returning clob) into qt_m from temp_2 where c2  = 'M' ;
        end if;
        select count(*) into b_i1 from  temp_2 where c2 = 'D';
        if b_i1 <> 0 then
            select JSON_ARRAYAGG(json_object('ten' VALUE C1 returning clob) returning clob) into qt_d from temp_2 where c2 = 'D' ;
        end if;
    end if;
  end if;
end if;
--tt dvi
    select json_object('ten_gon' value  NVL(ten_gon,' '),'ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
           'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
               from ht_ma_dvi where ma=b_ma_dvi;
    dt_ct:=FKH_JS_BONH(dt_ct);
    b_dvi:=FKH_JS_BONH(b_dvi);
    select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;

--ttt
select count(*) into b_i1 from bh_pkt_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ttt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ttt FROM bh_pkt_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ttt';
end if;

-------------------- lay ds_dk
delete temp_1;delete temp_4;commit;
insert into temp_1(c1,c2,c3,n1,n2) 
  select dk.ma,dk.ten,lh.loai,dk.cap,dk.tien from bh_pkt_dk dk, bh_pkt_lbh lh where 
    dk.ma = lh.ma and dk.ma_dvi = b_ma_dvi and dk.so_id = b_so_id and dk.nv = 'C' and trim(dk.PVI_MA) is null and dk.tien <> 0;

select count(*) into b_i1 from bh_pkt_txt t WHERE  t.so_id = b_so_id AND t.loai='ds_dk';
if b_i1 <> 0 then
    SELECT FKH_JS_BONH(t.txt) INTO b_temp_clob FROM bh_pkt_txt t WHERE  t.so_id = b_so_id AND t.loai='ds_dk';
    b_lenh:=FKH_JS_LENHc('');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_clob using b_temp_clob;
    dt_dk:= a_clob(b_index);
    b_lenh := FKH_JS_LENH('ma,ten,tien,tienkb,cap,mota');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_dk_ma,a_dk_ten,a_dk_tien,a_dk_tienkb,a_dk_cap,a_dk_mota USING dt_dk;
    for b_lp in 1..a_dk_ma.count loop
      if trim(a_dk_mota(b_lp)) is not null then
        b_temp_var := a_dk_ten(b_lp) || '(' || a_dk_mota(b_lp) || ')';
      else
        b_temp_var := a_dk_ten(b_lp);
      end if;
      update temp_1 set n3 = a_dk_tienkb(b_lp),c2 = b_temp_var where c1 = a_dk_ma(b_lp);
    end loop;
    select count(*) into b_i2  from temp_1 where n1 = 1 and c3 = 'TS';
    if b_i2 <> 0 then
      select n2 into b_tong_tien_v from temp_1 where n1 = 1 and c3 = 'TS';
      PKH_JS_THAY(dt_ct,'tong_tien_v',FBH_CSO_TIEN(b_tong_tien_v,b_nt_tien));
    end if;

    select count(*) into b_i2 from temp_1 where n1 = 1 and c3 = 'KH';
    if b_i2 <> 0 then
      select n2 into b_tong_tien_g from temp_1 where n1 = 1 and c3 = 'KH';
      PKH_JS_THAY(dt_ct,'tong_tien_g',FBH_CSO_TIEN(b_tong_tien_g,b_nt_tien));
    end if;
    select count(*) into b_i2 from temp_1 where n1 = 1 and c3 = 'BI';
      if b_i2 <> 0 then
      select n2 into b_tong_tien_bi from temp_1 where n1 = 1 and c3 = 'BI';
      PKH_JS_THAY(dt_ct,'tong_tien_bi',FBH_CSO_TIEN(b_tong_tien_bi,b_nt_tien));
    end if;


    select JSON_ARRAYAGG(json_object('ma' VALUE C1,'ten' value c2, 'tien' value FBH_CSO_TIEN(n2,b_nt_tien),'tienkb' value FBH_CSO_TIEN(n3,b_nt_tien) returning clob) returning clob) 
        into dt_dk_v from temp_1 where c3 = 'TS' and n1 <> 1;
    select JSON_ARRAYAGG(json_object('ma' VALUE C1,'ten' value c2, 'tien' value FBH_CSO_TIEN(n2,b_nt_tien),'tienkb' value FBH_CSO_TIEN(n3,b_nt_tien) returning clob) returning clob) 
        into dt_dk_g from temp_1 where c3 = 'KH' and n1 <> 1;
     select JSON_ARRAYAGG(json_object('ma' VALUE C1,'ten' value c2, 'tien' value FBH_CSO_TIEN(n2,b_nt_tien),'tienkb' value FBH_CSO_TIEN(n3,b_nt_tien) returning clob) returning clob) 
        into dt_dk_bi from temp_1 where c3 = 'BI' and n1 <> 1;
    delete temp_1;commit;
    for b_lp in 1..a_pvbh_ma.count loop
      select loai into b_temp_var from bh_pkt_pvi where ma = a_pvbh_ma(b_lp);
      b_i1:= case when a_pvbh_pttsb(b_lp) <> 0 then a_pvbh_pttsb(b_lp) else a_pvbh_ptts(b_lp) end;
      b_i2:= case when a_pvbh_ptkhb(b_lp) <> 0 then a_pvbh_ptkhb(b_lp) else a_pvbh_ptkh(b_lp) end;

      if b_temp_var = 'B' then 
        b_tlp_bb:= b_tlp_bb + b_i1;

        if trim(a_pvbh_ktru(b_lp)) is not null then
            b_mkt_b:= b_mkt_b || ',' || FBH_MKT(a_pvbh_ktru(b_lp),b_nt_tien);
        end if;
      end if;
      if b_temp_var= 'C' then 
        b_tlp_rr:= b_tlp_rr + b_i1;
        if trim(a_pvbh_ktru(b_lp)) is not null then
          b_mkt_c:= b_mkt_c || ',' || FBH_MKT(a_pvbh_ktru(b_lp),b_nt_tien);
        end if;
      end if;
      -- if b_temp_var = 'M' then 
      --   b_tlp_g:= b_tlp_g + b_i2;
      --   if trim(a_pvbh_ktru(b_lp)) is not null then
      --      b_mkt_m:= b_mkt_m || ',' || a_pvbh_ktru(b_lp);
      --   end if;
      -- end if;
      if b_temp_var = 'D' then 
        b_tlp_bi:= b_tlp_bi + b_i2;
        if trim(a_pvbh_ktru(b_lp)) is not null then
            b_mkt_d:= TO_CHAR(TO_NUMBER(REGEXP_SUBSTR(a_pvbh_ktru(b_lp), '^\d+')));
        end if;
      end if;
       if b_temp_var = 'P' then 
        if trim(a_pvbh_ktru(b_lp)) is not null then
           insert into temp_1(c1) values(a_pvbh_ten(b_lp) || ': ' || FBH_MKT(a_pvbh_ktru(b_lp),b_nt_tien));
        end if;
      end if;
    end loop;
    select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into b_mkt_p from temp_1;

    -- phi + ylp
    if b_tlp_bb <> 0 then 
      if b_tlp_bb > 100 then 
        b_phi_bb:= b_tlp_bb;
        b_tlp_bb:=0;
      else
        b_phi_bb:= b_tlp_bb * b_tong_tien_v/100;
      end if;
    end if;
    if b_tlp_rr <> 0 then 
      if b_tlp_rr > 100 then 
        b_phi_rr:= b_tlp_rr;
        b_tlp_rr:= 0;
      else
        b_phi_rr:= b_tlp_rr * b_tong_tien_v/100;
      end if;
    end if;
    if b_tlp_g <> 0 then
      if b_tlp_g > 100 then 
        b_phi_g := b_tlp_g;
        b_tlp_g:= 0;
      else
        b_phi_g:= b_tlp_g * b_tong_tien_g/100;
      end if;
    end if;
    if b_tlp_bi <> 0 then
      if b_tlp_bi > 100 then 
        b_phi_bi:= b_tlp_bi;
        b_tlp_bi:=0;
      else
        b_phi_bi:= b_tlp_bi * b_tong_tien_bi/100;
      end if;
    end if;
    b_tlp_v:= b_tlp_bb + b_tlp_rr;
    b_phi_v := b_phi_bb + b_phi_rr;

    PKH_JS_THAY(dt_ct,'tlp_v',FBH_TO_CHAR(b_tlp_v));
    PKH_JS_THAY(dt_ct,'tlp_bb',FBH_TO_CHAR(b_tlp_bb));
    PKH_JS_THAY(dt_ct,'tlp_rr',FBH_TO_CHAR(b_tlp_rr));
    PKH_JS_THAY(dt_ct,'tlp_g',FBH_TO_CHAR(b_tlp_g));
    PKH_JS_THAY(dt_ct,'tlp_bi',FBH_TO_CHAR(b_tlp_bi));


    PKH_JS_THAY(dt_ct,'phi_v',FBH_CSO_TIEN(b_phi_v,b_nt_tien));
    PKH_JS_THAY(dt_ct,'phi_bb',FBH_CSO_TIEN(b_phi_bb,b_nt_tien));
    PKH_JS_THAY(dt_ct,'phi_rr',FBH_CSO_TIEN(b_phi_rr,b_nt_tien));
    PKH_JS_THAY(dt_ct,'phi_g',FBH_CSO_TIEN(b_phi_g,b_nt_tien));
    PKH_JS_THAY(dt_ct,'phi_bi',FBH_CSO_TIEN(b_phi_bi,b_nt_tien));
    ------------muc khau tru

    PKH_JS_THAY(dt_ct,'mkt_b',LTRIM(b_mkt_b,','));
    PKH_JS_THAY(dt_ct,'mkt_c',LTRIM(b_mkt_c,','));
    --PKH_JS_THAY(dt_ct,'mkt_m',LTRIM(b_mkt_m,','));
    PKH_JS_THAY(dt_ct,'mkt_d',LTRIM(b_mkt_d,','));
  
end if;
delete temp_1;commit;

-- lay dt_kbt
select count(*) into b_i1 from bh_pkt_txt t WHERE  t.so_id = b_so_id AND t.loai='ds_kbt';
if b_i1 <> 0 then
    SELECT FKH_JS_BONH(t.txt) INTO b_temp_clob FROM bh_pkt_txt t WHERE  t.so_id = b_so_id AND t.loai='ds_kbt';
    b_lenh:=FKH_JS_LENHc('');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_clob using b_temp_clob;
    dt_kbt:= a_clob(b_index);
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
                    b_temp_nvar:= N'Áp dụng mức khấu trừ: '|| a_kbt_nd(b_lp2) ||N' đồng/vụ tổn thất';
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
                for b_lp2 in 1..a_kbt_ma.count loop
                  if a_kbt_ma(b_lp2) = 'KVU' then
                      if INSTR(UPPER(b_temp_nvar), N'TÀI SẢN') <> 0 then
                        insert into temp_1(c1) values(N'Đối với Tài sản: ' || FBH_MKT(a_kbt_nd(b_lp2),b_nt_tien));
                      elsif INSTR(UPPER(b_temp_nvar), N'NGƯỜI') <> 0 then
                        insert into temp_1(c1) values(N'Đối với Người: ' || FBH_MKT(a_kbt_nd(b_lp2),b_nt_tien));
                      else
                        insert into temp_1(c1) values(b_temp_nvar || ': ' || FBH_MKT(a_kbt_nd(b_lp2),b_nt_tien));
                      end if;
                  end if;
                end loop;
            end if;
          end if;
        end if;
    end loop;
  end if;
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into b_mkt_m from temp_1;
---thong tin thanh toan
delete temp_4;delete temp_1; commit;
select count(*) into b_i1 from bh_pkt_tt where ma_dvi = b_ma_dvi and so_id = b_so_id;
b_i2 := 1;
if  b_i1 <> 0 then
    for r_lp in (select ngay,tien from bh_pkt_tt where ma_dvi = b_ma_dvi and so_id = b_so_id order by ngay asc)
    loop
      insert into temp_4(C1) values(N'-   Kỳ ' || b_i2 || '/' || b_i1 || N': Ngày thanh toán ' || FBH_IN_CSO_NG(r_lp.ngay,'DD/MM/YYYY') || N', số tiền thanh toán ' || FBH_CSO_TIEN(r_lp.tien,b_nt_tien) );
    b_i2:= b_i2 + 1;
    end loop;
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_tt from temp_4;
delete temp_4;

--lay dt dong
delete temp_2;commit;
PKH_JS_THAY(dt_ct,'nbh',N'NGƯỜI BẢO HIỂM');
select count(*) into b_i1 from BH_HD_DO_TL where ma_dvi = b_ma_dvi and so_id = b_so_id;
if b_i1 <> 0 then
  PKH_JS_THAY(dt_ct,'nbh',N'NGƯỜI BẢO HIỂM ĐỨNG ĐẦU');
  b_i1:= 0;b_i2:= 1;
  for r_lp in (select b.ten,a.pt,b.dchi,b.mobi,b.cmt,b.ma_tk,b.nhang,b.ma from BH_HD_DO_TL a, BH_MA_NBH b where a.so_id = b_so_id and a.nha_bh=b.ma)
  loop
      b_temp_nvar:= N'NGƯỜI ĐỒNG BẢO HIỂM THỨ ' || FBH_IN_SO_CHU(b_i2) || ': ' || r_lp.ten;
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
--qt_bc,qt_m,qt_p;
select json_object('dt_ct' value dt_ct,'dt_dk' value dt_dk,'dt_dkbs' value dt_dkbs,
'dt_qt' value dt_qt,'dt_kbt' value dt_kbt,
'dt_ttt' value dt_ttt,'dt_lt' value dt_lt,'dt_dong' value dt_dong,'dt_tt' value dt_tt,'dt_hu' value dt_hu,
'ds_ct' value ds_ct,'dt_pvi' value dt_pvi,
'dt_bs_chung' value dt_bs_chung,'dt_bs_vc' value dt_bs_vc,'dt_bs_gdkd' value dt_bs_gdkd,'dt_bs_t3' value dt_bs_t3,
'dt_dk_v'  value dt_dk_v,'dt_dk_g' value dt_dk_g,'dt_dk_bi' value dt_dk_bi,'mkt_p' value b_mkt_p,
'qt_bc' value qt_bc,'qt_m' value qt_m,'qt_d' value qt_d,'mkt_m' value b_mkt_m returning clob) into b_oraOut from dual;

exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;