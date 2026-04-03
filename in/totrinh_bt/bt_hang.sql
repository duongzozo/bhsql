create or replace  procedure PBH_HANG_IN_BT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    -- chung
    b_loi varchar2(100); b_lenh varchar2(1000);
    -- orain
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
    b_so_id_hd number;

    b_i1 number := 0;b_i2 number := 0;b_count number;b_tien number:=0;
    dt_ct clob; dt_dk clob; dt_hk clob; dt_tba clob; dt_kbt clob;dt_ttt clob;b_dvi clob;dt_pt clob;
    hd_ct clob;hd_pt clob;hd_ds clob;hd_ttt clob;hd_kbt clob;

    dt_gd clob;dt_dong clob;dt_mmt clob;
    dt_tai_bh clob;
    --
    b_pt nvarchar2(500):=' ';b_qtac nvarchar2(500):=' ';
    b_temp_var varchar2(100);b_temp_nvar varchar2(500);

    b_kh_ttt clob;
    a_ttt_ma pht_type.a_var; a_ttt_nd pht_type.a_nvar;

    b_n_temp nvarchar2(500):=' ';b_nt_tien varchar2(20):= ' ';b_tien_bt number :=0;
    a_kbt_ma pht_type.a_var;a_kbt pht_type.a_clob;
    kbt_ma pht_type.a_var;kbt_nd pht_type.a_var;
    b_phigd number:= 0;
    -- tai hd
    b_so_id_ghep number;b_ma_nt varchar2(20);
     -- dong,tai
    b_ten_gd nvarchar2(500):=' ';b_tba_tien number:=0;
    a_tba_tien pht_type.a_num;
    b_mtn number:= 0;b_ten_nha_bh nvarchar2(500):=' ';
    b_tien_th number:=0;
    b_ten_temp nvarchar2(500):=' ';b_ma_temp varchar2(100);
    b_dong_mtn varchar2(100);b_dong_thudoi varchar2(100);
    dt_phi clob;
    --a_tbh_tm_nbh,a_tbh_tm_pt
    a_tbh_tm_nbh pht_type.a_var;a_tbh_tm_pt pht_type.a_var;
    --a_dt_dk
    a_dk_ma pht_type.a_var;a_dk_ten pht_type.a_nvar; a_dk_sluong pht_type.a_num;a_dk_gia_tri pht_type.a_num;
    a_dk_tthat_luong pht_type.a_num;a_dk_tthat_hang pht_type.a_num;a_dk_tien pht_type.a_num;
    -- ty le dong tai
    b_so_idD number;b_tp number:=0; b_bth number; b_bthH number;
    a_so_id_ta pht_type.a_num; a_pthuc pht_type.a_var; a_nbh pht_type.a_var; a_nbhC pht_type.a_var; 
    a_lh_nv pht_type.a_var; a_pt pht_type.a_num; a_tien pht_type.a_num; a_phi pht_type.a_num;
    dk_lh_nv pht_type.a_var; dk_tien pht_type.a_num;
    a_s pht_type.a_var;
    --a_dt_pt
    a_pt_ma pht_type.a_nvar;a_pt_ten pht_type.a_nvar; a_pt_soimo pht_type.a_var;

begin
-- Dan - Xem

b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
select so_id_hd into b_so_id_hd from bh_bt_hang where so_id = b_so_id;
--dt_ct
select count(*) into b_i1 from bh_bt_hang_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ct FROM bh_bt_hang_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_ct';

  b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_hl');
    PKH_JS_THAY_D(dt_ct,'gio_hl',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || N':' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00') );
    b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_kt');
    PKH_JS_THAY_D(dt_ct,'gio_kt',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || N':' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00'));
    ---
    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_gui');
    if b_i1 = 30000101 then PKH_JS_THAY_D(dt_ct,'ngay_gui',' '); 
    else PKH_JS_THAY_D(dt_ct,'ngay_gui',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    PKH_JS_THAY_D(dt_ct,'ngay_cap_s',N'Ngày ' || FBH_IN_CSO_NG(b_i1,'DD') || N' tháng ' || FBH_IN_CSO_NG(b_i1,'MM')
    || N' năm ' || FBH_IN_CSO_NG(b_i1,'YYYY'));

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_xr');
    if b_i1 = 30000101 then PKH_JS_THAY_D(dt_ct,'ngay_xr',' '); 
    else PKH_JS_THAY_D(dt_ct,'ngay_xr',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;
    
    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_hl');
    if b_i1 = 30000101 then PKH_JS_THAY_D(dt_ct,'ngay_hl',' '); 
    else PKH_JS_THAY_D(dt_ct,'ngay_hl',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_kt');
    if b_i1 = 30000101 then PKH_JS_THAY_D(dt_ct,'ngay_kt',' '); 
    else PKH_JS_THAY_D(dt_ct,'ngay_kt',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    b_i1:= FKH_JS_GTRIn(dt_ct ,'tba_tien');
    PKH_JS_THAY(dt_ct,'tba_tien',FBH_CSO_TIEN(b_i1,b_nt_tien) );

    b_i1:= FKH_JS_GTRIn(dt_ct ,'tien');
    PKH_JS_THAY(dt_ct,'tien',FBH_CSO_TIEN(b_i1,b_nt_tien) );

    PKH_JS_THAY(dt_ct,'dx_bt',FBH_CSO_TIEN(b_i1,b_nt_tien) || N' cho ' || FKH_JS_GTRIs(dt_ct ,'ten'));

    PKH_JS_THAY(dt_ct,'ct_gdtt_a',FKH_JS_GTRIs(dt_ct ,'ct_gdtt') || N' ngày ' || FKH_JS_GTRIs(dt_ct ,'ct_gdtt_n') || N' của ' || 
    FKH_JS_GTRIs(dt_ct ,'ct_gdtt_dv') );

end if;
--nntt
b_ma_temp:= FKH_JS_GTRIs(dt_ct,'ma_nn');
select count(*) into b_i1 from bh_ma_nntt where ma = b_ma_temp;
if b_i1 <> 0 then
  select ten into b_ten_temp from bh_ma_nntt where ma = b_ma_temp;
end if;
PKH_JS_THAY_D(dt_ct,'ma_nn',b_ten_temp);
b_ten_temp:=' ';
b_ma_nt:= FKH_JS_GTRIs(dt_ct,'nt_tien');
b_tien_bt:= FKH_JS_GTRIn(dt_ct,'tien');
--dt_pt
select count(*) into b_i1 from bh_bt_hang_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_pt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_pt FROM bh_bt_hang_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_pt';
  b_lenh:=FKH_JS_LENH('ma_pt,ten_pt,so_imo');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_pt_ma,a_pt_ten,a_pt_soimo using dt_pt;
  b_temp_nvar:='';
  for b_lp in 1..a_pt_ma.count loop
      b_temp_nvar:=b_temp_nvar || a_pt_ten(b_lp) || '; ';
  end loop;
  PKH_JS_THAY_D(dt_ct,'ten_ptien',b_temp_nvar);
end if;


--
SELECT '{' || LISTAGG('"' || ma || '": ""', ',') WITHIN GROUP (ORDER BY ma) || '}' into b_kh_ttt
FROM bh_kh_ttt
WHERE nv = 'HANG' AND ps = 'BT';
dt_ct:=FKH_JS_BONH(dt_ct);
b_kh_ttt:=FKH_JS_BONH(b_kh_ttt);
select json_mergepatch(dt_ct,b_kh_ttt) into dt_ct from dual;
-- lay phi giam dinh
select count(*) into b_i1 from BH_BT_GD_HS where so_id_bt = b_so_id;
if  b_i1 <> 0 then
  select sum(ttoan) into b_phigd from BH_BT_GD_HS where so_id_bt = b_so_id;
end if;
PKH_JS_THAY_D(dt_ct,'phigd',trim(TO_CHAR(b_phigd, '999,999,999,999,999,999PR')));


-- lay dt_dk
select count(*) into b_i1 from bh_bt_hang_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_dk';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_dk FROM bh_bt_hang_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_dk';
  b_lenh:=FKH_JS_LENH('ma_hang,ten,luong,gia_tri,tthat_luong,tthat_hang,tien');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_dk_ma,a_dk_ten,a_dk_sluong,a_dk_gia_tri,a_dk_tthat_luong,a_dk_tthat_hang,a_dk_tien using dt_dk;
  for b_lp in 1..a_dk_ma.count loop
      b_i1:= a_dk_tthat_hang(b_lp)/a_dk_gia_tri(b_lp);
  end loop;
  PKH_JS_THAY_D(dt_ct,'mdtt',FBH_TO_CHAR(b_i1*100));

end if;

--dt_hk
select count(*) into b_i1 from bh_bt_hang_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_hk';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_hk FROM bh_bt_hang_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_hk';
end if;
-- lay dt_tba
select count(*) into b_i1 from bh_bt_hang_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_tba';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_tba FROM bh_bt_hang_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_tba';
  b_lenh:=FKH_JS_LENH('tien');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_tba_tien using dt_tba;
  for ds_lp in 1..a_tba_tien.count loop
    b_tba_tien:= b_tba_tien + a_tba_tien(ds_lp);
  end loop;
end if;
PKH_JS_THAY_D(dt_ct,'tba_tien',FBH_CSO_TIEN(b_tba_tien,b_nt_tien));

--dt_kbt
select count(*) into b_i1 from bh_bt_hang_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_kbt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_kbt FROM bh_bt_hang_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_kbt';
  b_lenh := FKH_JS_LENH('ma,kbt');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_kbt_ma,a_kbt USING dt_kbt;
    delete temp_1;
    for b_lp in 1..a_kbt_ma.count loop
       if a_kbt(b_lp) is not null then
         b_lenh:=FKH_JS_LENH('ma,nd');
         EXECUTE IMMEDIATE b_lenh bulk collect into kbt_ma,kbt_nd using a_kbt(b_lp);
         for b_lp1 in 1..kbt_ma.count loop
           insert into temp_1(C1) values(FBH_IN_GBT(kbt_nd(b_lp1),kbt_ma(b_lp1)));
         end loop;
       end if;
    end loop; 
end if;
-- lay dt_ttt
select count(*) into b_i1 from bh_bt_hang_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_ttt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ttt FROM bh_bt_hang_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_ttt';
  b_lenh:=FKH_JS_LENH('ma,nd');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ttt_ma,a_ttt_nd USING dt_ttt;
  for b_lp in 1..a_ttt_ma.count loop
        PKH_JS_THAY_D(dt_ct,a_ttt_ma(b_lp),trim(a_ttt_nd(b_lp)));
  end loop;
end if;
-------thong tin hop dong
--hd_ct
select FKH_JS_BONH(t1.txt) INTO hd_ct from bh_hang_txt t1,bh_bt_hang t2
    where t1.so_id = t2.so_id_hd and t2.so_id = b_so_id and t1.loai = 'dt_ct';

b_ten_temp:= SUBSTR(FKH_JS_GTRIs(hd_ct,'cang_di'), INSTR(FKH_JS_GTRIs(hd_ct,'cang_di'), '|') + 1) ;
PKH_JS_THAY_D(hd_ct,'cang_di',b_ten_temp);
b_ten_temp:= SUBSTR(FKH_JS_GTRIs(hd_ct,'cang_den'), INSTR(FKH_JS_GTRIs(hd_ct,'cang_den'), '|') + 1) ;
PKH_JS_THAY_D(hd_ct,'cang_den',b_ten_temp);

b_qtac := SUBSTR(FKH_JS_GTRIs(hd_ct,'ma_qtac'), INSTR(FKH_JS_GTRIs(hd_ct,'ma_qtac'), '|') + 1) ;
PKH_JS_THAY_D(hd_ct,'qtac',b_qtac);

--
SELECT '{' || LISTAGG('"' || ma || '": ""', ',') WITHIN GROUP (ORDER BY ma) || '}' into b_kh_ttt
FROM bh_kh_ttt
WHERE nv = 'HANG' AND ps = 'HD';

hd_ct:=FKH_JS_BONH(hd_ct);
b_kh_ttt:=FKH_JS_BONH(b_kh_ttt);
select json_mergepatch(hd_ct,b_kh_ttt) into hd_ct from dual;
--hd_pt
select count(*) INTO b_i1 from bh_hang_txt t1,bh_bt_hang t2
    where t1.so_id = t2.so_id_hd and t2.so_id = b_so_id and t1.loai = 'dt_pt';
if b_i1 <> 0 then
  select FKH_JS_BONH(t1.txt) INTO hd_pt from bh_hang_txt t1,bh_bt_hang t2
      where t1.so_id = t2.so_id_hd and t2.so_id = b_so_id and t1.loai = 'dt_pt';
end if;
--hd_ds
select count(*) INTO b_i1 from bh_hang_txt t1,bh_bt_hang t2
    where t1.so_id = t2.so_id_hd and t2.so_id = b_so_id and t1.loai = 'dt_ds';
if b_i1 <> 0 then
  select FKH_JS_BONH(t1.txt) INTO hd_ds from bh_hang_txt t1,bh_bt_hang t2
      where t1.so_id = t2.so_id_hd and t2.so_id = b_so_id and t1.loai = 'dt_ds';
end if;
if hd_ds <> '""' then
  hd_ds:= REPLACE(hd_ds, '[', '');
  hd_ds:= REPLACE(hd_ds, ']', '');
  b_ten_temp := FKH_JS_GTRIs(hd_ds,'dgoi');
  b_ten_temp:= FBH_IN_SUBSTR(b_ten_temp, '|', 'S');
  PKH_JS_THAY_D(hd_ds,'dgoi',b_ten_temp);
  b_i1:= FKH_JS_GTRIn(hd_ds ,'mtn');
  PKH_JS_THAY(hd_ds,'mtn',FBH_CSO_TIEN(b_i1,b_nt_tien) );

end if;

----hd_ttt
select count(*) INTO b_i1 from bh_hang_txt t1,bh_bt_hang t2
    where t1.so_id = t2.so_id_hd and t2.so_id = b_so_id and t1.loai = 'dt_ttt';
if b_i1 <> 0 then
  select FKH_JS_BONH(t1.txt) INTO hd_ttt from bh_hang_txt t1,bh_bt_hang t2
      where t1.so_id = t2.so_id_hd and t2.so_id = b_so_id and t1.loai = 'dt_ttt';
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ttt_ma,a_ttt_nd USING hd_ttt;
  for b_lp in 1..a_ttt_ma.count loop
        PKH_JS_THAY_D(hd_ct,a_ttt_ma(b_lp),trim(a_ttt_nd(b_lp)));
  end loop;
end if;
--hd_kbt
select count(*) INTO b_i1 from bh_hang_txt t1,bh_bt_hang t2
    where t1.so_id = t2.so_id_hd and t2.so_id = b_so_id and t1.loai = 'dt_kbt';
if b_i1 <> 0 then
  select FKH_JS_BONH(t1.txt) INTO hd_kbt from bh_hang_txt t1,bh_bt_hang t2
      where t1.so_id = t2.so_id_hd and t2.so_id = b_so_id and t1.loai = 'dt_kbt';

  b_lenh := FKH_JS_LENH('ma,kbt');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_kbt_ma,a_kbt USING hd_kbt;
    delete temp_1;commit;
    for b_lp in 1..a_kbt_ma.count loop
      if a_kbt(b_lp) is not null then
        b_lenh:=FKH_JS_LENH('ma,nd');
        EXECUTE IMMEDIATE b_lenh bulk collect into kbt_ma,kbt_nd using a_kbt(b_lp);
        for b_lp1 in 1..kbt_ma.count loop
          insert into temp_1(C1) values(FBH_IN_GBT(kbt_nd(b_lp1),kbt_ma(b_lp1)));
        end loop;
      end if;
    end loop; 
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1) returning clob) into dt_mmt from TEMP_1;

-- lay danh sach don vi giam dinh
select count(*) into b_i1 from BH_BT_GD_HS where so_id_bt = b_so_id and ma_gd is not null;
if b_i1 <> 0 then
  b_i1:= 1;
  for r_lp in (select ma_gd from BH_BT_GD_HS where so_id_bt = b_so_id group by ma_gd)
  loop
      select ten into b_ten_gd from bh_ma_gdinh where ma =r_lp.ma_gd;
      insert into temp_3(C1) values(unistr('\002D\0020\0110\01A1\006E\0020\0076\1ECB\0020\0067\0069\00E1\006D\0020\0111\1ECB\006E\0068\0020') || b_i1 || ': ' ||b_ten_gd);
      b_i1:= b_i1 + 1;
  end loop;
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1) returning clob) into dt_gd from TEMP_3;

-- dong, tai
select lh_nv,sum(tien) bulk collect into dk_lh_nv,dk_tien from bh_bt_hs_nv
    where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv having sum(tien)<>0;
b_bthH:=FKH_ARR_TONG(dk_tien);

b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id_hd);
FBH_BT_DOTA_PT(b_ma_dvi,b_so_idD,b_so_id_hd,
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
  PKH_JS_THAY(dt_ct,'dong_thudoi',FBH_CSO_TIEN(b_dong_thudoi, ''));
end if;

select count(*) into b_i1 from temp_1 where  c1 in ('..3F', '..4T', '..5C', '..6Q', '..7S');
if b_i1 <> 0 then
  select n2 into b_dong_thudoi from temp_1 where  c1 in ('..3F', '..4T', '..5C', '..6Q', '..7S');
  PKH_JS_THAY(dt_ct,'tai_thudoi',FBH_CSO_TIEN(b_dong_thudoi, ''));
end if;
delete bh_bt_dota_temp_2;
delete bh_bt_dota_temp_3;
delete temp_1;
commit;

-- end dong, tai


select json_object('dt_ct' value dt_ct,'dt_dk' value dt_dk,'dt_hk' value dt_hk,
    'dt_tba' value dt_tba,'dt_kbt' value dt_kbt,'dt_ttt' value dt_ttt,'hd_ct' value hd_ct,'hd_pt' value hd_pt,
    'hd_ds' value hd_ds,'hd_ttt' value hd_ttt,'dt_gd' value dt_gd,'dt_dong' value dt_dong,'dt_mmt' value dt_mmt,'dt_tai_bh' value dt_tai_bh returning clob) into b_oraOut from dual;
delete TEMP_3;
delete TEMP_2;
delete temp_1;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
/