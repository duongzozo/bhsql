create or replace procedure PBH_HOP_IN_GCN(
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
    b_kh_ttt clob;dt_qt clob;dt_tt clob;b_dvi clob;dt_hu clob;dt_dkbs clob;dt_dd clob;dt_hk clob;

    b_temp_clob clob;a_clob pht_type.a_clob;
    b_temp_var varchar2(100);b_temp_nvar varchar2(500);
    b_ma_kvuc varchar2(20);
    b_ten_kvuc nvarchar2(500):= ' ';b_ktru nvarchar2(4000);
    b_nt_tien varchar2(50);
    b_ten_dd nvarchar2(500):= ' ';
    b_diachi_dd nvarchar2(500):= ' ';
    b_mobi_dd nvarchar2(500):= ' ';
    b_fax_dd nvarchar2(500):= ' ';
    b_cmt_dd nvarchar2(500):= ' ';
    b_matk_dd nvarchar2(500):= ' ';
    b_nganhang_dd nvarchar2(500):= ' ';
    b_ng_ddb nvarchar2(500):= ' ';
    b_ng_dd nvarchar2(500):= ' ';
    ---kbt
    a_kbt_ma_dk pht_type.a_var; a_kbt_kbt pht_type.a_nvar;
    a_kbt_nd pht_type.a_var; a_kbt_ma pht_type.a_nvar;
    
    --a dt_dk
    a_dk_ma pht_type.a_var;a_dk_ten pht_type.a_nvar; a_dk_tien pht_type.a_num;a_dk_phi pht_type.a_num;
    a_dk_cap pht_type.a_num;a_dk_kieu pht_type.a_var;a_dk_lkeb pht_type.a_var;
    a_dk_mota pht_type.a_nvar;a_dk_ma_dk pht_type.a_var;
    --dt_ds
    a_ds_ten pht_type.a_nvar;a_ds_cmt pht_type.a_var;a_ds_ng_sinh pht_type.a_num;a_ds_mobi pht_type.a_var;
    a_ds_email pht_type.a_var;a_ds_nhom pht_type.a_var;
    --a dt_bs
    a_bs_ma pht_type.a_var;a_bs_ten pht_type.a_nvar; a_bs_tien pht_type.a_num;a_bs_phi pht_type.a_num;
    a_bs_cap pht_type.a_num;a_bs_dkp pht_type.a_nvar;
    --a_ttt
    a_ttt_ma pht_type.a_var; a_ttt_nd pht_type.a_nvar;
     --a dong bh
    dt_dong_bh clob;
    a_dong_nha_bh pht_type.a_nvar;a_dong_pt pht_type.a_num;a_dong_tien pht_type.a_num;a_dong_phi pht_type.a_num;
    --a dt_hu
    a_hu_ten pht_type.a_nvar;a_hu_cmt pht_type.a_var; a_hu_mobi pht_type.a_var;a_hu_email pht_type.a_var;
    a_hu_dchi pht_type.a_nvar;a_hu_ng_ddien pht_type.a_nvar;a_hu_chucvu pht_type.a_nvar;

begin

select count(*) into b_i1 from bh_hop_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ct FROM bh_hop_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_ct';
    b_nt_tien:=FKH_JS_GTRIs(dt_ct ,'nt_tien');
    if b_nt_tien = 'VND' then 
      b_nt_tien:= N'đồng';
      PKH_JS_THAYa(dt_ct,'nt_tien',N'đồng');
    end if;

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

    b_i1:= FKH_JS_GTRIn(dt_ct ,'dthu');
    PKH_JS_THAY(dt_ct,'dthu',FBH_CSO_TIEN(b_i1,b_nt_tien) );

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

    select sum(pt) into b_i1 from bh_hop_dk where ma_dvi = b_ma_dvi and so_id = b_so_id and lh_nv is not null and lh_bh = 'C';
    PKH_JS_THAY(dt_ct,'tlp', b_i1);

    -- nguoi duoc bh
--     if trim(FKH_JS_GTRIs(dt_ct ,'ng_dd')) is null THEN
--       PKH_JS_THAY(dt_ct,'ng_dd',FKH_JS_GTRIs(dt_ct ,'ten'));
--       PKH_JS_THAY(dt_ct,'cmtd',FKH_JS_GTRIs(dt_ct ,'cmt'));
--       PKH_JS_THAY(dt_ct,'mobid',FKH_JS_GTRIs(dt_ct ,'mobi'));
--       PKH_JS_THAY(dt_ct,'emaild',FKH_JS_GTRIs(dt_ct ,'email'));
--       PKH_JS_THAY(dt_ct,'dchid',FKH_JS_GTRIs(dt_ct ,'dchi'));
--       PKH_JS_THAY(dt_ct,'gioid',FKH_JS_GTRIs(dt_ct ,'gioi'));
--       PKH_JS_THAY(dt_ct,'dchid',FKH_JS_GTRIs(dt_ct ,'dchi'));
--       PKH_JS_THAY(dt_ct,'ng_sinhd',FKH_JS_GTRIs(dt_ct ,'ng_sinh'));
--     else
--       PKH_JS_THAY(dt_ct,'cmtd','');
--       PKH_JS_THAY(dt_ct,'mobid','');
--       PKH_JS_THAY(dt_ct,'dchid','');
--       PKH_JS_THAY(dt_ct,'dchid','');
--     end if;

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
	 -- lay ten dvi
    select count(*) into b_i1 from  ht_ma_dvi where ma = b_ma_dvi;
    if b_i1 <> 0 then
       select kvuc into b_temp_var from ht_ma_dvi where ma = b_ma_dvi;
    end if;
    if trim(b_temp_var) is not null then
      select count(*) into b_i1 from  bh_ma_kvuc where ma = b_temp_var;
      if b_i1 <> 0 then
        select ten into b_temp_nvar from bh_ma_kvuc where ma = b_temp_var;
      end if;
    end if;
    PKH_JS_THAYa(dt_ct,'ten_kvuc',b_ten_kvuc);

    select sum(tien) into b_i1 from bh_hop_dk where ma_dvi = b_ma_dvi and so_id = b_so_id and ma_dk is not null;
    PKH_JS_THAY(dt_ct,'tong_tien_bh',FBH_CSO_TIEN(b_i1,b_nt_tien));
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
--ttt
select count(*) into b_i1 from bh_hop_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ttt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ttt FROM bh_hop_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ttt';
  if dt_ttt <> '""' then
    b_lenh := FKH_JS_LENH('ma,nd');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ttt_ma,a_ttt_nd USING dt_ttt;
     for b_lp in 1..a_ttt_ma.count loop
           PKH_JS_THAYa(dt_ct,a_ttt_ma(b_lp),a_ttt_nd(b_lp));
     end loop;
  end if;
end if;

--tt dvi
    select json_object('ten_gon' value  NVL(ten_gon,' '),'ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
           'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
               from ht_ma_dvi where ma=b_ma_dvi;
    dt_ct:=FKH_JS_BONH(dt_ct);
    b_dvi:=FKH_JS_BONH(b_dvi);
    select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;
---thong tin thanh toan
delete temp_4;delete temp_1; commit;
select count(*) into b_i1 from bh_hop_tt where ma_dvi = b_ma_dvi and so_id = b_so_id;

if  b_i1 <> 0 then
    b_i2 := 1;
    for r_lp in (select ngay,tien from bh_hop_tt where ma_dvi = b_ma_dvi and so_id = b_so_id order by ngay asc)
    loop
      insert into temp_4(C1) values(N'-   Kỳ ' || b_i2 || '/' || b_i1 || N': Ngày thanh toán ' || FBH_IN_CSO_NG(r_lp.ngay,'DD/MM/YYYY') || N', số tiền thanh toán ' || FBH_CSO_TIEN(r_lp.tien,b_nt_tien) );
    b_i2:= b_i2 + 1;
    end loop;
    ---
    if b_i1 = 1 then
      b_temp_var:= FKH_JS_GTRIs(dt_ct ,'ngay_hl');
      select min(ngay) into b_i2 from bh_hop_tt where ma_dvi = b_ma_dvi and so_id = b_so_id;
      SELECT  TRUNC(TO_DATE(TO_CHAR(b_i2),'YYYYMMDD')) - TRUNC(TO_DATE(b_temp_var,'DD/MM/YYYY')) into b_i1 FROM dual;
      PKH_JS_THAY(dt_ct,'tttt', N'Phí bảo hiểm được Bên mua bảo hiểm/ Người được bảo hiểm thanh toán bằng tiền mặt hoặc chuyển khoản, trong vòng '||b_i1 ||   N' ngày kể từ ngày hợp đồng bảo hiểm có hiệu lực.');
    else
      PKH_JS_THAY(dt_ct,'tttt', N'Phí bảo hiểm được Bên mua bảo hiểm/ Người được bảo hiểm thanh toán bằng tiền mặt hoặc chuyển khoản theo các kỳ thanh toán được liệt kê bên dưới.');
    end if;
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_tt from temp_4;
delete temp_4;commit;

--lay dt dong
delete temp_2;commit;
select count(*) into b_i1 from BH_HD_DO_TL where ma_dvi = b_ma_dvi and so_id = b_so_id;
if b_i1 <> 0 then
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
--dt_hk
select count(*) into b_i1 from bh_hop_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_hk';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_hk FROM bh_hop_txt t WHERE t.ma_dvi = b_ma_dvi and t.so_id = b_so_id AND t.loai='dt_hk';
  b_lenh := FKH_JS_LENH('ten,cmt,mobi,email,dchi,ng_ddien,chucvu');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_hu_ten,a_hu_cmt,a_hu_mobi,a_hu_email,a_hu_dchi,a_hu_ng_ddien,a_hu_chucvu USING dt_hk;
  delete temp_2;commit;
  b_i1:= 1;
  for b_lp in 1..a_hu_ten.count loop
    if a_hu_ten.count = 1 then
     b_temp_nvar := N'NGƯỜI THỤ HƯỞNG ' || ': ' || a_hu_ten(b_lp);
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

-- lay dt_dk
select count(*) into b_i1 from bh_hop_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_dk';
if b_i1 <> 0 then
    delete temp_1;delete temp_4;commit;
    SELECT FKH_JS_BONH(t.txt) INTO dt_dk FROM bh_hop_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_dk';
    if dt_dk <> '""' then
      b_lenh := FKH_JS_LENH('ma,ten,tien,phi,cap,kieu,ma_dk,mota');
      EXECUTE IMMEDIATE b_lenh bulk collect INTO a_dk_ma,a_dk_ten,a_dk_tien,a_dk_phi,a_dk_cap,a_dk_kieu,a_dk_ma_dk,a_dk_mota USING dt_dk;
      for b_lp in 1..a_dk_ma.count loop
          --------lay quy tac
          if trim(a_dk_ma_dk(b_lp)) is not null then
            select count(*) into b_i1 from bh_ma_dk where  ma=a_dk_ma_dk(b_lp);
            if b_i1>0 then
                SELECT nvl(FKH_JS_GTRIs(FKH_JS_BONH(t.txt) ,'qtac'),'') into b_temp_var from BH_MA_DK t where ma=a_dk_ma_dk(b_lp);
                select count(*) into b_i1 from bh_ma_qtac where  ma=b_temp_var;
                if b_i1 > 0 then
                    select ten into b_temp_nvar from bh_ma_qtac where ma=b_temp_var;
                    insert into temp_1(c1,c2) values(b_temp_var,b_temp_nvar);
                end if;
            end if;
          end if;
          ----end lay quy tac
          --dt_dk
          b_temp_nvar:= a_dk_ten(b_lp);
          if trim(a_dk_mota(b_lp)) is not null then
            b_temp_nvar:= b_temp_nvar || ' (' || a_dk_mota(b_lp) ||')';
          end if;
          if a_dk_cap(b_lp) = 1 or a_dk_cap(b_lp) = 2 then 
            b_temp_nvar := '- ' || b_temp_nvar;
          elsif a_dk_cap(b_lp) > 2 then
            b_temp_nvar := CHR(32)||CHR(32)||CHR(32)||CHR(32)||CHR(32)||CHR(32)||'+ ' || b_temp_nvar;
          end if;
          insert into temp_4(cl1,c2) values(b_temp_nvar,FBH_CSO_TIEN(a_dk_tien(b_lp),b_nt_tien));
      end loop;
      select JSON_ARRAYAGG(json_object('ten' VALUE cl1,'tien' value c2) returning clob) into dt_dk from temp_4;
    end if;
end if;

-- lay dt_dkbs
delete temp_1;delete temp_4;commit;
select count(*) into b_i1 from bh_hop_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_dkbs';
if b_i1 <> 0 then
    SELECT FKH_JS_BONH(t.txt) INTO dt_bs FROM bh_hop_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_dkbs';
    b_lenh := FKH_JS_LENH('ma,ten,dkp,phi,cap');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_bs_ma,a_bs_ten,a_bs_dkp,a_bs_phi,a_bs_cap USING dt_bs;
    for b_lp in 1..a_bs_ma.count loop
      b_temp_nvar:= a_bs_ten(b_lp);
      if trim(a_bs_dkp(b_lp)) is not null then b_temp_nvar:= b_temp_nvar || ' (' || a_bs_dkp(b_lp) || ')'; end if;
      insert into temp_1(c1,c2) values(a_bs_ma(b_lp),b_temp_nvar);
    end loop;
end if;


-- lay dt_lt
select count(*) into b_i1 from bh_hop_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_lt';
if b_i1 <> 0 then
    SELECT FKH_JS_BONH(t.txt) INTO dt_lt FROM bh_hop_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_lt';
    b_lenh := FKH_JS_LENH('ma_lt,ten');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_bs_ma,a_bs_ten USING dt_lt;
    for b_lp in 1..a_bs_ma.count loop
      insert into temp_1(c1,c2) values(a_bs_ma(b_lp),a_bs_ten(b_lp));
    end loop;
end if;
select JSON_ARRAYAGG(json_object('ten' VALUE c1 ||' - ' ||c2) returning clob) into dt_bs from temp_1;
delete temp_1;commit;
--dt_kbt
select count(*) into b_i1 from bh_hop_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_kbt';
if b_i1 <> 0 then
  b_temp_nvar:= '';
  SELECT FKH_JS_BONH(t.txt) INTO dt_kbt FROM bh_hop_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_kbt';
  if dt_kbt <> '""' then
    b_lenh := FKH_JS_LENH('ma,kbt');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_kbt_ma_dk,a_kbt_kbt USING dt_kbt;
    for b_lp in 1..a_kbt_ma_dk.count loop
              b_lenh := FKH_JS_LENH('ma,nd');
              EXECUTE IMMEDIATE b_lenh bulk collect INTO a_kbt_ma,a_kbt_nd USING a_kbt_kbt(b_lp);
              select ten into b_temp_nvar from bh_hop_dk where so_id = b_so_id and ma = a_kbt_ma_dk(b_lp);
                   
              b_i2:= 0;
              for b_lp2 in 1..a_kbt_ma.count loop
                if a_kbt_ma(b_lp2) = 'KVU' then
                    if INSTR(UPPER(b_temp_nvar), N'TÀI SẢN') <> 0 then
                      b_temp_nvar:= N'Đối với tài sản: ' || FBH_MKT(a_kbt_nd(b_lp2),b_nt_tien);
                    elsif INSTR(UPPER(b_temp_nvar), N'NGƯỜI') <> 0 then
                      b_i2:= 1;
                      if trim(a_kbt_nd(b_lp2)) is null then
                        b_temp_nvar := N'Đối với người: Khônɡ áp dụng';
                      else
                        b_temp_nvar :=N'Đối với người: ' || FBH_MKT(a_kbt_nd(b_lp2),b_nt_tien);
                      end if; 
                    else
                      b_temp_nvar := b_temp_nvar || ': ' || FBH_MKT(a_kbt_nd(b_lp2),b_nt_tien);
                    end if;
                end if;
              end loop;
              if b_lp > 1 then
                b_ktru:= b_ktru || CHR(10) || b_temp_nvar;
              else
                b_ktru:= b_ktru || b_temp_nvar;
              end if;
      end loop;
      PKH_JS_THAY(dt_ct,'ktru',LTRIM(b_ktru,',') ); 
  end if;
end if;
----
select json_object('dt_ct' value dt_ct,'dt_dk' value dt_dk,'dt_hk' value dt_hk,
'dt_qt' value dt_qt,'dt_bs' value dt_bs,'dt_kbt' value dt_kbt,
'dt_ttt' value dt_ttt,'dt_lt' value dt_lt,'dt_dong' value dt_dong,'dt_tt' value dt_tt,'dt_hu' value dt_hu returning clob) into b_oraOut from dual;


exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
/
create or replace procedure PBH_HOP_IN_HD(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    -- chung
    b_loi varchar2(100); b_lenh varchar2(1000);
    -- orain
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
  --
    b_i1 number := 0;b_ngay_tt number;b_i2 number:=0;
    dt_ct clob; dt_bs clob;dt_dk clob; dt_lt clob;dt_kbt clob; dt_ttt clob;dt_dong clob;dt_hk clob;
    b_kh_ttt clob;dt_qt clob;dt_tt clob;b_dvi clob;dt_hu clob;dt_dkbs clob;dt_ds clob;

    --txt hop dong
    ds_ct clob;ds_dk clob;ds_dkbs clob;ds_lt clob;ds_kbt clob;dt_dd clob;

    b_temp_clob clob;a_clob pht_type.a_clob;
    b_temp_var varchar2(100);b_temp_nvar varchar2(500);
    b_ma_kvuc varchar2(20);
    b_ten_kvuc nvarchar2(500):= ' ';b_ktru nvarchar2(4000);
    b_nt_tien varchar2(50);
    b_ten_dd nvarchar2(500):= ' ';
    b_diachi_dd nvarchar2(500):= ' ';
    b_mobi_dd nvarchar2(500):= ' ';
    b_fax_dd nvarchar2(500):= ' ';
    b_cmt_dd nvarchar2(500):= ' ';
    b_matk_dd nvarchar2(500):= ' ';
    b_nganhang_dd nvarchar2(500):= ' ';
    b_ng_ddb nvarchar2(500):= ' ';
    b_ng_dd nvarchar2(500):= ' ';
    ---kbt
    a_kbt_ma_dk pht_type.a_var; a_kbt_kbt pht_type.a_nvar;
    a_kbt_nd pht_type.a_var; a_kbt_ma pht_type.a_nvar;

    --a dt_dk
    a_dk_ma pht_type.a_var;a_dk_ten pht_type.a_nvar; a_dk_tien pht_type.a_num;a_dk_phi pht_type.a_num;
    a_dk_cap pht_type.a_num;a_dk_kieu pht_type.a_var;a_dk_lkeb pht_type.a_var;
    a_dk_mota pht_type.a_nvar;a_dk_ma_dk pht_type.a_var;
    --dt_ds
    a_ds_ten pht_type.a_nvar;a_ds_cmt pht_type.a_var;a_ds_ng_sinh pht_type.a_num;a_ds_mobi pht_type.a_var;
    a_ds_email pht_type.a_var;a_ds_nhom pht_type.a_var;
    --a dt_bs
    a_bs_ma pht_type.a_var;a_bs_ten pht_type.a_nvar; a_bs_tien pht_type.a_num;a_bs_phi pht_type.a_num;
    a_bs_cap pht_type.a_num;a_bs_dkp pht_type.a_nvar;
    --a_ttt
    a_ttt_ma pht_type.a_var; a_ttt_nd pht_type.a_nvar;
     --a dong bh
    dt_dong_bh clob;
    a_dong_nha_bh pht_type.a_nvar;a_dong_pt pht_type.a_num;a_dong_tien pht_type.a_num;a_dong_phi pht_type.a_num;
    --a dt_hu
    a_hu_ten pht_type.a_nvar;a_hu_cmt pht_type.a_var; a_hu_mobi pht_type.a_var;a_hu_email pht_type.a_var;
    a_hu_dchi pht_type.a_nvar;a_hu_ng_ddien pht_type.a_nvar;a_hu_chucvu pht_type.a_nvar;

begin


--ds_ct
select count(*) into b_i1 from bh_hop_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO ds_ct FROM bh_hop_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_ct';
end if;
--ds_dk
select count(*) into b_i1 from bh_hop_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_dk';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO ds_dk FROM bh_hop_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_dk';
end if;
--ds_dkbs
select count(*) into b_i1 from bh_hop_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_dkbs';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO ds_dkbs FROM bh_hop_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_dkbs';
end if;
--ds_lt
select count(*) into b_i1 from bh_hop_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_lt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO ds_lt FROM bh_hop_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_lt';
end if;
--ds-kbt
select count(*) into b_i1 from bh_hop_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_kbt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO ds_kbt FROM bh_hop_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='ds_kbt';
end if;


----dt_ct-----
select count(*) into b_i1 from bh_hop_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ct FROM bh_hop_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_ct';
    b_nt_tien:=FKH_JS_GTRIs(dt_ct ,'nt_tien');
    if b_nt_tien = 'VND' then 
      b_nt_tien:= N'đồng';
      PKH_JS_THAYa(dt_ct,'nt_tien',N'đồng');
    end if;

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

    b_i1:= FKH_JS_GTRIn(dt_ct ,'dthu');
    PKH_JS_THAY(dt_ct,'dthu',FBH_CSO_TIEN(b_i1,b_nt_tien) );

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

    select sum(pt) into b_i1 from bh_hop_dk where ma_dvi = b_ma_dvi and so_id = b_so_id and lh_nv is not null and lh_bh = 'C';
    PKH_JS_THAY(dt_ct,'tlp', b_i1);
    
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
	 -- lay ten dvi
    select count(*) into b_i1 from  ht_ma_dvi where ma = b_ma_dvi;
    if b_i1 <> 0 then
       select kvuc into b_temp_var from ht_ma_dvi where ma = b_ma_dvi;
    end if;
    if trim(b_temp_var) is not null then
      select count(*) into b_i1 from  bh_ma_kvuc where ma = b_temp_var;
      if b_i1 <> 0 then
        select ten into b_temp_nvar from bh_ma_kvuc where ma = b_temp_var;
      end if;
    end if;
    PKH_JS_THAYa(dt_ct,'ten_kvuc',b_ten_kvuc);

    select sum(tien) into b_i1 from bh_hop_dk where ma_dvi = b_ma_dvi and so_id = b_so_id and ma_dk is not null;
    PKH_JS_THAY(dt_ct,'tong_tien_bh',FBH_CSO_TIEN(b_i1,b_nt_tien));
end if;

if ds_ct <> '[""]' then
    b_lenh:=FKH_JS_LENHc('');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_clob using ds_ct;
    dt_ds:= a_clob(1);
    PKH_JS_THAY_D(dt_ct,'dtuong',FKH_JS_GTRIs(dt_ds ,'dtuong') );
    PKH_JS_THAY_D(dt_ct,'dchib',FKH_JS_GTRIs(dt_ds ,'dchib') );
    PKH_JS_THAY_D(dt_ct,'nganh',FKH_JS_GTRIs(dt_ds ,'nganh') );
    PKH_JS_THAY_D(dt_ct,'ttink',FKH_JS_GTRIs(dt_ds ,'ttink') );
    PKH_JS_THAY_D(dt_ct,'mota',FKH_JS_GTRIs(dt_ds ,'mota') );
    PKH_JS_THAY_D(dt_ct,'so_dt',FKH_JS_GTRIs(dt_ds ,'so_dt') );
    PKH_JS_THAY_D(dt_ct,'dthu',FBH_CSO_TIEN(FKH_JS_GTRIn(dt_ds ,'dthu') ,b_nt_tien) );

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

-----Thong tin them----------
select count(*) into b_i1 from bh_hop_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ttt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ttt FROM bh_hop_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ttt';
  if dt_ttt <> '""' then
    b_lenh := FKH_JS_LENH('ma,nd');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ttt_ma,a_ttt_nd USING dt_ttt;
     for b_lp in 1..a_ttt_ma.count loop
           PKH_JS_THAYa(dt_ct,a_ttt_ma(b_lp),a_ttt_nd(b_lp));
     end loop;
  end if;
end if;

-------thong tin don vi---------------
    select json_object('ten_gon' value  NVL(ten_gon,' '),'ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
           'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
               from ht_ma_dvi where ma=b_ma_dvi;
    dt_ct:=FKH_JS_BONH(dt_ct);
    b_dvi:=FKH_JS_BONH(b_dvi);
    select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;
---thong tin thanh toan
delete temp_4;delete temp_1; commit;
select count(*) into b_i1 from bh_hop_tt where ma_dvi = b_ma_dvi and so_id = b_so_id;

if  b_i1 <> 0 then
    b_i2 := 1;
    for r_lp in (select ngay,tien from bh_hop_tt where ma_dvi = b_ma_dvi and so_id = b_so_id order by ngay asc)
    loop
      insert into temp_4(C1) values(N'-   Kỳ ' || b_i2 || '/' || b_i1 || N': Ngày thanh toán ' || FBH_IN_CSO_NG(r_lp.ngay,'DD/MM/YYYY') || N', số tiền thanh toán ' || FBH_CSO_TIEN(r_lp.tien,b_nt_tien) );
    b_i2:= b_i2 + 1;
    end loop;
    ---
    if b_i1 = 1 then
      b_temp_var:= FKH_JS_GTRIs(dt_ct ,'ngay_hl');
      select min(ngay) into b_i2 from bh_hop_tt where ma_dvi = b_ma_dvi and so_id = b_so_id;
      SELECT  TRUNC(TO_DATE(TO_CHAR(b_i2),'YYYYMMDD')) - TRUNC(TO_DATE(b_temp_var,'DD/MM/YYYY')) into b_i1 FROM dual;
      PKH_JS_THAY(dt_ct,'tttt', N'Phí bảo hiểm được Bên mua bảo hiểm/ Người được bảo hiểm thanh toán bằng tiền mặt hoặc chuyển khoản, trong vòng '||b_i1 ||   N' ngày kể từ ngày hợp đồng bảo hiểm có hiệu lực.');
    else
      PKH_JS_THAY(dt_ct,'tttt', N'Phí bảo hiểm được Bên mua bảo hiểm/ Người được bảo hiểm thanh toán bằng tiền mặt hoặc chuyển khoản theo các kỳ thanh toán được liệt kê bên dưới.');
    end if;
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_tt from temp_4;
delete temp_4;commit;

--------thong tin dong bh--------
delete temp_2;commit;
select count(*) into b_i1 from BH_HD_DO_TL where ma_dvi = b_ma_dvi and so_id = b_so_id;
if b_i1 <> 0 then
  b_i1:= 0;b_i2:= 1;
  for r_lp in (select b.ten,a.pt,b.dchi,b.mobi,b.cmt,b.ma_tk,b.nhang,b.ma from BH_HD_DO_TL a, BH_MA_NBH b where a.so_id = b_so_id and a.nha_bh=b.ma)
  loop
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
--dt_hk
select count(*) into b_i1 from bh_hop_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_hk';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_hk FROM bh_hop_txt t WHERE t.ma_dvi = b_ma_dvi and t.so_id = b_so_id AND t.loai='dt_hk';
  b_lenh := FKH_JS_LENH('ten,cmt,mobi,email,dchi,ng_ddien,chucvu');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_hu_ten,a_hu_cmt,a_hu_mobi,a_hu_email,a_hu_dchi,a_hu_ng_ddien,a_hu_chucvu USING dt_hk;
  delete temp_2;commit;
  b_i1:= 1;
  for b_lp in 1..a_hu_ten.count loop
    if a_hu_ten.count = 1 then
     b_temp_nvar := N'NGƯỜI THỤ HƯỞNG ' || ': ' || a_hu_ten(b_lp);
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

-- lay dt_dk
if ds_dk <> '[""]' then
    b_lenh:=FKH_JS_LENHc('');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_clob using ds_dk;
    dt_dk:= a_clob(1);

    delete temp_1;delete temp_4;commit;
    if dt_dk <> '""' then
      b_lenh := FKH_JS_LENH('ma,ten,tien,phi,cap,kieu,ma_dk,mota');
      EXECUTE IMMEDIATE b_lenh bulk collect INTO a_dk_ma,a_dk_ten,a_dk_tien,a_dk_phi,a_dk_cap,a_dk_kieu,a_dk_ma_dk,a_dk_mota USING dt_dk;
      for b_lp in 1..a_dk_ma.count loop
          --------lay quy tac
          if trim(a_dk_ma_dk(b_lp)) is not null then
            select count(*) into b_i1 from bh_ma_dk where  ma=a_dk_ma_dk(b_lp);
            if b_i1>0 then
                SELECT nvl(FKH_JS_GTRIs(FKH_JS_BONH(t.txt) ,'qtac'),'') into b_temp_var from BH_MA_DK t where ma=a_dk_ma_dk(b_lp);
                select count(*) into b_i1 from bh_ma_qtac where  ma=b_temp_var;
                if b_i1 > 0 then
                    select ten into b_temp_nvar from bh_ma_qtac where ma=b_temp_var;
                    insert into temp_1(c1,c2) values(b_temp_var,b_temp_nvar);
                end if;
            end if;
          end if;
          ----end lay quy tac
          --dt_dk
          b_temp_nvar:= a_dk_ten(b_lp);
          if trim(a_dk_mota(b_lp)) is not null then
            b_temp_nvar:= b_temp_nvar || ' (' || a_dk_mota(b_lp) ||')';
          end if;
          if a_dk_cap(b_lp) = 1 or a_dk_cap(b_lp) = 2 then 
            b_temp_nvar := '- ' || b_temp_nvar;
          elsif a_dk_cap(b_lp) > 2 then
            b_temp_nvar := CHR(32)||CHR(32)||CHR(32)||CHR(32)||CHR(32)||CHR(32)||'+ ' || b_temp_nvar;
          end if;
          insert into temp_4(cl1,c2) values(b_temp_nvar,FBH_CSO_TIEN(a_dk_tien(b_lp),b_nt_tien));
      end loop;
      select JSON_ARRAYAGG(json_object('ten' VALUE cl1,'tien' value c2) returning clob) into dt_dk from temp_4;
    end if;
end if;

-- lay dt_dkbs
delete temp_1;delete temp_4;commit;
select count(*) into b_i1 from bh_hop_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_dkbs';
if b_i1 <> 0 then
    SELECT FKH_JS_BONH(t.txt) INTO dt_bs FROM bh_hop_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_dkbs';
    b_lenh := FKH_JS_LENH('ma,ten,dkp,phi,cap');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_bs_ma,a_bs_ten,a_bs_dkp,a_bs_phi,a_bs_cap USING dt_bs;
    for b_lp in 1..a_bs_ma.count loop
      b_temp_nvar:= a_bs_ten(b_lp);
      if trim(a_bs_dkp(b_lp)) is not null then b_temp_nvar:= b_temp_nvar || ' (' || a_bs_dkp(b_lp) || ')'; end if;
      insert into temp_1(c1,c2) values(a_bs_ma(b_lp),b_temp_nvar);
    end loop;
end if;


-- lay dt_lt
if ds_lt <> '""' then
    b_lenh:=FKH_JS_LENHc('');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_clob using ds_lt;
    dt_lt:= a_clob(1);
    delete temp_1;
    b_lenh := FKH_JS_LENH('ma_lt,ten');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_bs_ma,a_bs_ten USING dt_lt;
    for b_lp in 1..a_bs_ma.count loop
      insert into temp_1(c1,c2) values(a_bs_ma(b_lp),a_bs_ten(b_lp));
    end loop;
end if;
select JSON_ARRAYAGG(json_object('ten' VALUE c1 ||' - ' ||c2) returning clob) into dt_bs from temp_1;
delete temp_1;commit;
--dt_kbt
if ds_kbt <> '""' then
    b_lenh:=FKH_JS_LENHc('');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_clob using ds_kbt;
    dt_kbt:= a_clob(1);
    b_temp_nvar:= '';
    if dt_kbt <> '""' then
      b_lenh := FKH_JS_LENH('ma,kbt');
      EXECUTE IMMEDIATE b_lenh bulk collect INTO a_kbt_ma_dk,a_kbt_kbt USING dt_kbt;
      for b_lp in 1..a_kbt_ma_dk.count loop
              b_lenh := FKH_JS_LENH('ma,nd');
              EXECUTE IMMEDIATE b_lenh bulk collect INTO a_kbt_ma,a_kbt_nd USING a_kbt_kbt(b_lp);
              select ten into b_temp_nvar from bh_hop_dk where so_id = b_so_id and ma = a_kbt_ma_dk(b_lp);
                   
              b_i2:= 0;
              for b_lp2 in 1..a_kbt_ma.count loop
                if a_kbt_ma(b_lp2) = 'KVU' then
                    if INSTR(UPPER(b_temp_nvar), N'TÀI SẢN') <> 0 then
                      b_temp_nvar:= N'Đối với Tài sản: ' || FBH_MKT(a_kbt_nd(b_lp2),b_nt_tien);
                    elsif INSTR(UPPER(b_temp_nvar), N'NGƯỜI') <> 0 then
                      b_i2:= 1;
                      if trim(a_kbt_nd(b_lp2)) is null then
                        b_temp_nvar := N'Đối với Người: Khônɡ áp dụng';
                      else
                        b_temp_nvar :=N'Đối với Người: ' || FBH_MKT(a_kbt_nd(b_lp2),b_nt_tien);
                      end if; 
                    else
                      b_temp_nvar := b_temp_nvar || ': ' || FBH_MKT(a_kbt_nd(b_lp2),b_nt_tien);
                    end if;
                end if;
              end loop;
              if b_lp > 1 then
                b_ktru:= b_ktru || CHR(10) || b_temp_nvar;
              else
                b_ktru:= b_ktru || b_temp_nvar;
              end if;
      end loop;
      PKH_JS_THAY(dt_ct,'ktru',LTRIM(b_ktru,',') ); 
    end if;
end if;
----
select json_object('dt_ct' value dt_ct,'dt_dk' value dt_dk,'dt_hk' value dt_hk,
'dt_qt' value dt_qt,'dt_bs' value dt_bs,'dt_kbt' value dt_kbt,
'dt_ttt' value dt_ttt,'dt_lt' value dt_lt,'dt_dong' value dt_dong,'dt_tt' value dt_tt,'dt_hu' value dt_hu returning clob) into b_oraOut from dual;

exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
/