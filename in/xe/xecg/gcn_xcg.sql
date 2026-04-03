create or replace procedure PBH_XE_IN_GCN(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    -- chung
    b_loi varchar2(100); b_lenh varchar2(1000);
    -- orain
    b_so_hd varchar2(50) :=FKH_JS_GTRIs(b_oraIn,'so_hd');
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
    b_bena_ten NVARCHAR2(100):=' ';b_bena_dchi NVARCHAR2(100):=' ';
    --
    b_i1 number := 0;b_ngay_tt number;b_i2 number:=0;
    dt_ct clob; dt_bs clob; dt_ds clob; dt_dk clob; dt_lt clob;dt_kbt clob; dt_ttt clob;dt_dong clob;
    b_kh_ttt clob;dt_qt clob;dt_tt clob;b_dvi clob;dt_hu clob;
    b_tnds clob; b_lhbh_khac clob;

    b_ten_dvi nvarchar2(500):= ' ';
    b_temp_var varchar2(100);b_temp_nvar varchar2(500);b_temp_clob clob;
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
    a_dk_ma pht_type.a_var;a_dk_ten pht_type.a_nvar; a_dk_tien pht_type.a_num;a_dk_phi pht_type.a_num;a_dk_thue pht_type.a_num;
    a_dk_cap pht_type.a_num;a_dk_gvu pht_type.a_var;a_dk_ma_ct pht_type.a_var;a_dk_kieu pht_type.a_var;
    --dkbs
    a_bs_ma pht_type.a_var;a_bs_ten pht_type.a_nvar;a_bs_cap pht_type.a_num;a_bs_tien pht_type.a_num;a_bs_phi pht_type.a_num;
    a_bs_thue pht_type.a_num;
    --a dt_hu
    a_hu_ten pht_type.a_nvar;a_hu_cmt pht_type.a_var; a_hu_mobi pht_type.a_var;a_hu_email pht_type.a_var;
    a_hu_dchi pht_type.a_nvar;a_hu_ng_ddien pht_type.a_nvar;a_hu_chucvu pht_type.a_nvar;
     --a dong bh
    dt_dong_bh clob;
    a_dong_nha_bh pht_type.a_nvar;a_dong_pt pht_type.a_num;a_dong_tien pht_type.a_num;a_dong_phi pht_type.a_num;
    --
    a_ttt_ma pht_type.a_var; a_ttt_nd pht_type.a_nvar;

    b_count_banin number := 1;
    b_hu boolean := false;b_dong boolean := false;
    b_vcx_phi number:=0;b_vcx_thue number:=0;
begin
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);

select count(*) into b_i1 from bh_xe_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ct FROM bh_xe_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_ct';
    b_nt_tien:=FKH_JS_GTRIs(dt_ct ,'nt_tien');
    b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_hl');
    PKH_JS_THAYa(dt_ct,'gio_hl_s',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00') || N' phút ' );
    PKH_JS_THAYa(dt_ct,'gio_hl',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00') );
    b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_kt');
    PKH_JS_THAYa(dt_ct,'gio_kt',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00'));

    --ma khai thac
    select ma_kt,kieu_kt into b_ma_kt, b_kieu_kt from bh_xe where ma_dvi = b_ma_dvi and so_id = b_so_id;
    if b_kieu_kt = 'T' THEN
         select NVL(ten,' ') into b_temp_nvar from ht_ma_cb where ma = b_ma_kt;
    elsif b_kieu_kt = 'D' THEN
        select NVL(ten,' ') into b_temp_nvar from bh_dl_ma_kh where ma = b_ma_kt;
    elsif b_kieu_kt = 'M' THEN
        select NVL(ten,' ') into b_temp_nvar from bh_dl_ma_kh where ma = b_ma_kt;
    elsif b_kieu_kt = 'N' THEN
        select NVL(ten,' ') into b_temp_nvar from bh_ma_nhang where ma = b_ma_kt;
    end if;
    PKH_JS_THAY(dt_ct,'ma_kt',b_ma_kt || ' - ' ||b_temp_nvar);
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
    if b_i1 = 0 then
        PKH_JS_THAY(dt_ct,'gia', ' ');
    else
        PKH_JS_THAY(dt_ct,'gia', FBH_CSO_TIEN(b_i1,N'đồng') );
    end if;
    
    b_i1:= FKH_JS_GTRIn(dt_ct ,'thue');
    PKH_JS_THAY(dt_ct,'thue',FBH_CSO_TIEN(b_i1,b_nt_tien) );

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ttoan');
    PKH_JS_THAY(dt_ct,'ttoan',FBH_CSO_TIEN(b_i1,b_nt_tien) );
    PKH_JS_THAYa(dt_ct,'bangchu',FBH_IN_CSO_CHU(b_i1,b_nt_tien) );

    if trim(FKH_JS_GTRIs(dt_ct ,'ktru')) is not null then
        b_temp_nvar:= N'Áp dụng mức khấu trừ: '|| FBH_IN_SUBSTR(FKH_JS_GTRIs(dt_ct ,'ktru'),'|','S') ||N' đồng/vụ tổn thất';
        PKH_JS_THAY(dt_ct,'ktru',b_temp_nvar);
    end if;
    b_temp_var:= FKH_JS_GTRIs(dt_ct ,'loai_xe');
    if trim(b_temp_var) is not null THEN
        select ten into b_temp_nvar from bh_xe_loai where ma = b_temp_var;
        PKH_JS_THAY(dt_ct,'loai_xe',b_temp_nvar );
    end if;

    b_temp_var:= FKH_JS_GTRIs(dt_ct ,'pban');
    if trim(b_temp_var) is not null THEN
        select ten into b_temp_nvar from bh_xe_pb where ma = b_temp_var and hieu = FKH_JS_GTRIs(dt_ct ,'hieu') and hang = FKH_JS_GTRIs(dt_ct ,'hang');
        PKH_JS_THAY(dt_ct,'pban',b_temp_nvar );
    end if;

    b_temp_var:= FKH_JS_GTRIs(dt_ct ,'hang');
    if trim(b_temp_var) is not null THEN
        select ten into b_temp_nvar from bh_xe_hang where ma = b_temp_var;
        PKH_JS_THAY(dt_ct,'hang',b_temp_nvar );
    end if;

    b_temp_var:= FKH_JS_GTRIs(dt_ct ,'hieu');
    if trim(b_temp_var) is not null THEN
        select ten into b_temp_nvar from bh_xe_hieu where ma = b_temp_var;
        PKH_JS_THAY(dt_ct,'hieu',b_temp_nvar );
    end if;

    if trim(FKH_JS_GTRIs(dt_ct ,'tenc')) is null THEN
        PKH_JS_THAY(dt_ct,'tenc',FKH_JS_GTRIs(dt_ct ,'ten') );
        PKH_JS_THAY(dt_ct,'dchic',FKH_JS_GTRIs(dt_ct ,'dchi') );
        PKH_JS_THAY(dt_ct,'mobic',FKH_JS_GTRIs(dt_ct ,'mobi') );
        PKH_JS_THAY(dt_ct,'cmtc',FKH_JS_GTRIs(dt_ct ,'cmt') );

        PKH_JS_THAY(dt_ct,'ten','X' );
        PKH_JS_THAY(dt_ct,'dchi','X');
        PKH_JS_THAY(dt_ct,'mobi','X');
        PKH_JS_THAY(dt_ct,'cmt','X');
    else
        b_count_banin:= b_count_banin + 1;
    end if;

    b_i1:= FKH_JS_GTRIn(dt_ct ,'nam_sx');
    b_temp_var:= '';
    if b_i1 <> 0 then 
        b_i2:= FKH_JS_GTRIn(dt_ct ,'thang_sx');
        if b_i2 <> 0 then
           b_temp_var:= b_i2 || '/';
        else
             b_temp_var:= '01/';
        end if;
        b_temp_var:= b_temp_var || b_i1;
        PKH_JS_THAYa(dt_ct,'nam_sx',b_temp_var);

        b_i1:= FBH_TINH_THOI_GIAN_SD(b_temp_var);
        PKH_JS_THAYa(dt_ct,'thoi_gian_sd',to_char(b_i1) || N' năm');
    else 
        PKH_JS_THAYa(dt_ct,'nam_sx',' ');
        PKH_JS_THAYa(dt_ct,'thoi_gian_sd',' ');
    end if;

    if trim(FKH_JS_GTRIs(dt_ct ,'ndungd')) is null then
        PKH_JS_THAY(dt_ct,'ndungd',N'Điều khoản bảo hiểm bổ sung khác');
    end if;
    --md_sd
    b_temp_var:= FKH_JS_GTRIs(dt_ct ,'md_sd');
    if trim(b_temp_var) is not null THEN
        select ten into b_temp_nvar from bh_xe_mdsd where ma = b_temp_var;
        PKH_JS_THAY(dt_ct,'md_sd',b_temp_nvar );
    end if;
    
    b_i1:= FKH_JS_GTRIn(dt_ct ,'ttai');
    if b_i1 <> 0 then PKH_JS_THAY(dt_ct,'ttai', ' ');end if;

end if;
 SELECT '{' || LISTAGG('"' || ma || '": ""', ',') WITHIN GROUP (ORDER BY ma) || '}' into b_kh_ttt
    FROM bh_kh_ttt WHERE nv = 'XE' AND ps = 'HD';
    dt_ct:=FKH_JS_BONH(dt_ct);
    b_kh_ttt:=FKH_JS_BONH(b_kh_ttt);
    select json_mergepatch(dt_ct,b_kh_ttt) into dt_ct from dual;

--bien xoa chi muc
PKH_JS_THAY(dt_ct,'bb_x','X');
PKH_JS_THAY(dt_ct,'tn_x','X');
PKH_JS_THAY(dt_ct,'vcx_x','X');
PKH_JS_THAY(dt_ct,'plx_x','X');
PKH_JS_THAY(dt_ct,'hh_x','X');
PKH_JS_THAY(dt_ct,'chung_x','X');
PKH_JS_THAY(dt_ct,'bs_x','X');
---xoa 5.1.2
PKH_JS_THAY(dt_ct,'tnds_x','X');
--xoa 3.2.4
PKH_JS_THAY(dt_ct,'vcx_lpx_hh','X');
-- bien xoa dkbs
for b_lp in 1..13 loop
    if b_lp < 10 then
        PKH_JS_THAY(dt_ct,'BS-0' || b_lp,'X');
    else
         PKH_JS_THAY(dt_ct,'BS-' || b_lp,'X');
    end if;
end loop;
--dt_hu
PKH_JS_THAY(dt_ct,'hu_x','X');
select count(*) into b_i1 from bh_xe_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_hu';
if b_i1 <> 0 then
  b_hu := true;
  PKH_JS_THAY(dt_ct,'hu_x',' ');
  SELECT FKH_JS_BONH(t.txt) INTO dt_hu FROM bh_xe_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_hu';
  b_lenh := FKH_JS_LENH('ten,cmt,mobi,email,dchi,ng_ddien,chucvu');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_hu_ten,a_hu_cmt,a_hu_mobi,a_hu_email,a_hu_dchi,a_hu_ng_ddien,a_hu_chucvu USING dt_hu;
  delete temp_2;commit;
  b_i1:= 1;
  b_count_banin:= b_count_banin + a_hu_ten.count;
  for b_lp in 1..a_hu_ten.count loop
    b_temp_nvar:= N'NGƯỜI THỤ HƯỞNG: ' || a_hu_ten(b_lp);
    insert into temp_2(C1,c2,c3,c4,c5,c6,c7,c8) 
        values(b_temp_nvar,a_hu_cmt(b_lp),a_hu_mobi(b_lp),a_hu_email(b_lp),a_hu_dchi(b_lp),a_hu_ng_ddien(b_lp),a_hu_chucvu(b_lp), N'NGƯỜI THỤ HƯỞNG' || CHR(10) || a_hu_ten(b_lp));
    b_i1:= b_i1 +1;
  end loop;
  select JSON_ARRAYAGG(json_object('ten' VALUE C1,'cmt' VALUE C2,'mobi' VALUE C3,'email' VALUE C4,'dchi' VALUE C5,
  'ng_ddien' VALUE C6,'chucvu' VALUE C7, 'ten_1' value c8  returning clob) returning clob) into dt_hu from temp_2;

  delete temp_2;commit;
end if;

--tt dvi
    select json_object('ten_gon' value  NVL(ten_gon,' '),'ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
           'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
               from ht_ma_dvi where ma=b_ma_dvi;
    dt_ct:=FKH_JS_BONH(dt_ct);
    b_dvi:=FKH_JS_BONH(b_dvi);
    select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;

--ttt
select count(*) into b_i1 from bh_xe_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ttt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ttt FROM bh_xe_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ttt';
  b_lenh := FKH_JS_LENH('ma,nd');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ttt_ma,a_ttt_nd USING dt_ttt;
  for b_lp in 1..a_ttt_ma.count loop
        PKH_JS_THAY_D(dt_ct,a_ttt_ma(b_lp),a_ttt_nd(b_lp));
  end loop;
else
   PKH_JS_THAYa(dt_ct,'NDT',' ');
end if;
--bs
b_temp_nvar:=' ';
PKH_JS_THAY_D(dt_ct,'dkbs',N'KHÔNG THAM GIA');
PKH_JS_THAYa(dt_ct,'bs_lb','X');
select count(*) into b_i1 from bh_xe_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_dkbs';
if b_i1 <> 0 then
    PKH_JS_THAY(dt_ct,'bs_x',' ');
    SELECT FKH_JS_BONH(t.txt) INTO dt_bs FROM bh_xe_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_dkbs';
    if dt_bs <> '""' then 
        PKH_JS_THAYa(dt_ct,'bs_lb',N'Điều khoản bổ sung:'); 
        b_lenh := FKH_JS_LENH('ma,ten,cap,tien,phi,thue');
        EXECUTE IMMEDIATE b_lenh bulk collect INTO a_bs_ma,a_bs_ten,a_bs_cap,a_bs_tien,a_bs_phi,a_bs_thue USING dt_bs;
        delete temp_1;
        for b_lp in 1..a_bs_ma.count loop
            if a_bs_cap(b_lp) = 1 THEN
                insert into temp_1(c1,c2) values(a_bs_ma(b_lp),a_bs_ten(b_lp));
            end if;
            PKH_JS_THAYa(dt_ct,SUBSTR(a_bs_ma(b_lp), 1, 5),' ');
            if a_bs_ma(b_lp) = 'BS-05' THEN
                PKH_JS_THAY_D(dt_ct,'bs_05', FBH_CSO_TIEN(a_bs_tien(b_lp),N'đồng' ));
                b_vcx_phi:= b_vcx_phi + a_bs_phi(b_lp);
                b_vcx_thue:= b_vcx_thue + a_bs_thue(b_lp);
            end if;
            b_temp_nvar:=b_temp_nvar||', '||a_bs_ma(b_lp);
            b_temp_nvar:=LTRIM(b_temp_nvar,', ');
        end loop;
        select JSON_ARRAYAGG(json_object('ma' value c1, 'ten' value c2 returning clob) returning clob) into dt_bs from temp_1;
    end if;
    PKH_JS_THAY_D(dt_ct,'dkbs',b_temp_nvar);
end if;


-- lay dt_dk
select count(*) into b_i1 from bh_xe_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_dk';
if b_i1 <> 0 then
    SELECT FKH_JS_BONH(t.txt) INTO dt_dk FROM bh_xe_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_dk';
    b_lenh := FKH_JS_LENH('ma,ten,tien,phi,thue,cap,gvu,ma_ct,kieu');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_dk_ma,a_dk_ten,a_dk_tien,a_dk_phi,a_dk_thue,a_dk_cap,a_dk_gvu,a_dk_ma_ct,a_dk_kieu USING dt_dk;
    delete temp_1;delete temp_3;
    b_i2:= 2;
    PKH_JS_THAY(dt_ct,'nguoi_bb_x','X');
    PKH_JS_THAY(dt_ct,'ts_bb_x','X');
    PKH_JS_THAY(dt_ct,'hk_bb_x','X');

    PKH_JS_THAY(dt_ct,'nguoi_bb',N'KHÔNG THAM GIA');
    PKH_JS_THAY(dt_ct,'ts_bb',N'KHÔNG THAM GIA');
    PKH_JS_THAY(dt_ct,'hk_bb',N'KHÔNG THAM GIA');
    PKH_JS_THAY(dt_ct,'phi_bb',N'KHÔNG THAM GIA');
    PKH_JS_THAY(dt_ct,'thue_bb',N'KHÔNG THAM GIA');

    PKH_JS_THAY(dt_ct,'nguoi_tn_x','X');
    PKH_JS_THAY(dt_ct,'ts_tn_x','X');
    PKH_JS_THAY(dt_ct,'hk_tn_x','X');

    PKH_JS_THAY(dt_ct,'nguoi_tn',N'KHÔNG THAM GIA');
    PKH_JS_THAY(dt_ct,'ts_tn',N'KHÔNG THAM GIA');
    PKH_JS_THAY(dt_ct,'hk_tn',N'KHÔNG THAM GIA');
    PKH_JS_THAY(dt_ct,'phi_tn',N'KHÔNG THAM GIA');
    PKH_JS_THAY(dt_ct,'thue_tn',N'KHÔNG THAM GIA');

    PKH_JS_THAY(dt_ct,'lpx_phi',N'KHÔNG THAM GIA');
    PKH_JS_THAY(dt_ct,'lpx_mtn',N'KHÔNG THAM GIA');
    PKH_JS_THAY(dt_ct,'lpx_sn',N'KHÔNG THAM GIA');

    PKH_JS_THAY(dt_ct,'hh_phi',N'KHÔNG THAM GIA');
    PKH_JS_THAY(dt_ct,'hh_mtn',N'KHÔNG THAM GIA');
    PKH_JS_THAY(dt_ct,'hh_ttai',N'KHÔNG THAM GIA');
    PKH_JS_THAY(dt_ct,'hh_thue',N'KHÔNG THAM GIA');

    PKH_JS_THAY(dt_ct,'vcx_mtn','X');
    PKH_JS_THAY(dt_ct,'vcx_phi','X');

    for b_lp in 1..a_dk_ma.count loop
        if a_dk_ma(b_lp) = 'TNDS_BB.1' THEN
            if a_dk_tien(b_lp) > 0 then
                PKH_JS_THAY(dt_ct,'nguoi_bb_x', FBH_CSO_TIEN_KNT(a_dk_tien(b_lp))  || N' đồng/người/vụ');
                PKH_JS_THAY(dt_ct,'nguoi_bb', FBH_CSO_TIEN_KNT(a_dk_tien(b_lp))  || N' đồng/người/vụ');
            end if;
        elsif a_dk_ma(b_lp) = 'TNDS_BB' THEN
                PKH_JS_THAY(dt_ct,'phi_bb', FBH_CSO_TIEN(a_dk_phi(b_lp) ,N'đồng' ));
                PKH_JS_THAY(dt_ct,'thue_bb', FBH_CSO_TIEN(a_dk_thue(b_lp) ,N'đồng' ));
                PKH_JS_THAY(dt_ct,'bb_x',' ');
                PKH_JS_THAY(dt_ct,'tnds_x',' ');
        elsif a_dk_ma(b_lp) = 'TNDS_BB.2' THEN
            if a_dk_tien(b_lp) > 0 then
                PKH_JS_THAY(dt_ct,'ts_bb_x', FBH_CSO_TIEN_KNT(a_dk_tien(b_lp)  ) || N' đồng/vụ');
                PKH_JS_THAY(dt_ct,'ts_bb', FBH_CSO_TIEN_KNT(a_dk_tien(b_lp)  ) || N' đồng/vụ');
            end if;
        elsif a_dk_ma(b_lp) = 'TNDS_BB.3' THEN
            if a_dk_tien(b_lp) > 0 then
                PKH_JS_THAY(dt_ct,'hk_bb_x', FBH_CSO_TIEN_KNT(a_dk_tien(b_lp)  )  || N' đồng/người/vụ');
                PKH_JS_THAY(dt_ct,'hk_bb', FBH_CSO_TIEN_KNT(a_dk_tien(b_lp)  )  || N' đồng/người/vụ');
            end if;
        elsif a_dk_ma(b_lp) = 'TNDS_TN' THEN
                select sum(phi),sum(thue) into b_i1,b_i2 from bh_xe_dk where ma_dvi = b_ma_dvi and so_id = b_so_id and ma_ct = a_dk_ma(b_lp);
                PKH_JS_THAY(dt_ct,'phi_tn', FBH_CSO_TIEN(b_i1 ,N'đồng' ));
                PKH_JS_THAY(dt_ct,'thue_tn', FBH_CSO_TIEN(b_i2 ,N'đồng' ));
                PKH_JS_THAY(dt_ct,'tn_x',' ');
                PKH_JS_THAY(dt_ct,'chung_x',' ');
                PKH_JS_THAY(dt_ct,'tnds_x',' ');
        elsif a_dk_ma(b_lp) = 'TNDS_TN.1' THEN
            if a_dk_tien(b_lp) > 0 then
                PKH_JS_THAY(dt_ct,'nguoi_tn', FBH_CSO_TIEN_KNT(a_dk_tien(b_lp))  || N' đồng/người/vụ');
                PKH_JS_THAY(dt_ct,'nguoi_tn_x', FBH_CSO_TIEN_KNT(a_dk_tien(b_lp))  || N' đồng/người/vụ');
            end if;
        elsif a_dk_ma(b_lp) = 'TNDS_TN.2' THEN
            if a_dk_tien(b_lp) > 0 then
                PKH_JS_THAY(dt_ct,'ts_tn', FBH_CSO_TIEN_KNT(a_dk_tien(b_lp)  ) || N' đồng/vụ');
                PKH_JS_THAY(dt_ct,'ts_tn_x', FBH_CSO_TIEN_KNT(a_dk_tien(b_lp)  ) || N' đồng/vụ');
            end if;
        elsif a_dk_ma(b_lp) = 'TNDS_TN.3' THEN
            if a_dk_tien(b_lp) > 0 then
                PKH_JS_THAY(dt_ct,'hk_tn', FBH_CSO_TIEN_KNT(a_dk_tien(b_lp)  )  || N' đồng/người/vụ');
                PKH_JS_THAY(dt_ct,'hk_tn_x', FBH_CSO_TIEN_KNT(a_dk_tien(b_lp)  )  || N' đồng/người/vụ');
            end if;
        end if;
        
        if a_dk_ma(b_lp) = 'VCX' THEN
            b_vcx_phi:= b_vcx_phi + a_dk_phi(b_lp);
            b_vcx_thue:= b_vcx_thue + a_dk_thue(b_lp);
            PKH_JS_THAY(dt_ct,'vcx_mtn',FBH_CSO_TIEN_KNT(a_dk_tien(b_lp) ) || N' đồng' );
            --PKH_JS_THAY(dt_ct,'vcx_phi',FBH_CSO_TIEN_KNT(a_dk_phi(b_lp) ) || N' đồng' );
            PKH_JS_THAY(dt_ct,'vcx_x',' ');
            PKH_JS_THAY(dt_ct,'chung_x',' ');
            PKH_JS_THAY(dt_ct,'vcx_lpx_hh',' ');
        elsif a_dk_ma(b_lp) = 'HH' THEN
            insert into temp_3(C1,C4) values(a_dk_ma(b_lp), FBH_CSO_TIEN(a_dk_phi(b_lp),N'đồng'  ));
            PKH_JS_THAY(dt_ct,'hh_phi', FBH_CSO_TIEN(a_dk_phi(b_lp),N'đồng'  ));
            PKH_JS_THAY(dt_ct,'hh_thue', FBH_CSO_TIEN(a_dk_thue(b_lp),N'đồng'  ));
            PKH_JS_THAY(dt_ct,'hh_x',' ');
            PKH_JS_THAY(dt_ct,'chung_x',' ');
            PKH_JS_THAY(dt_ct,'vcx_lpx_hh',' ');
        elsif a_dk_ma(b_lp) = 'HH.1' THEN
            if a_dk_tien(b_lp) > 0 then
                update temp_3 set C3 =  FBH_CSO_TIEN_KNT(a_dk_tien(b_lp) ) || N' đồng/tấn' where C1 = 'HH';
                PKH_JS_THAY(dt_ct,'hh_mtn', FBH_CSO_TIEN_KNT(a_dk_tien(b_lp) ) || N' đồng/tấn');
            end if;
        elsif a_dk_ma(b_lp) = 'HH.2' THEN
            PKH_JS_THAY(dt_ct,'hh_ttai', a_dk_tien(b_lp) || N' tấn');
            update temp_3 set c2 = N'Bảo hiểm TNDS của chủ xe đối với hàng hóa vận chuyển trên xe. ', c5=  N'Số tấn: ' || a_dk_tien(b_lp) || N' tấn' where c1 = 'HH';
        elsif a_dk_ma(b_lp) = 'LPX' THEN
                insert into temp_3(C1,C4) values(a_dk_ma(b_lp), FBH_CSO_TIEN(a_dk_phi(b_lp),N'đồng'  ) );
                PKH_JS_THAY(dt_ct,'lpx_phi', FBH_CSO_TIEN(a_dk_phi(b_lp),N'đồng'  ));
                PKH_JS_THAY(dt_ct,'lpx_x',' ');
                PKH_JS_THAY(dt_ct,'chung_x',' ');
                PKH_JS_THAY(dt_ct,'vcx_lpx_hh',' ');
        elsif a_dk_ma(b_lp) = 'LPX.1' THEN
            if a_dk_tien(b_lp) > 0 then
                update temp_3 set C3 = FBH_CSO_TIEN_KNT(a_dk_tien(b_lp) )|| N' đồng/người/vụ'   where C1 = 'LPX';
                PKH_JS_THAY(dt_ct,'lpx_mtn', FBH_CSO_TIEN_KNT(a_dk_tien(b_lp) )|| N' đồng/người/vụ');
            end if;
        elsif a_dk_ma(b_lp) = 'LPX.2' THEN
            update temp_3 set c2 = N'Bảo hiểm Tai nạn lái, phụ xe và người ngồi trên xe. ', c5 = a_dk_ten(b_lp) || ': ' || a_dk_tien(b_lp) || N' người' where c1 = 'LPX';
             PKH_JS_THAY(dt_ct,'lpx_sn', a_dk_tien(b_lp) || N' người');
        end if;
    end loop;
    select JSON_ARRAYAGG(json_object('ten' value C2,'ttt' value c5,'mtn' value C3,'phi' value C4 returning clob) returning clob) into b_lhbh_khac from temp_3;
    delete temp_1;delete temp_3;
end if;
PKH_JS_THAY(dt_ct,'vcx_phi',FBH_CSO_TIEN_KNT(b_vcx_phi ) || N' đồng' );
PKH_JS_THAY(dt_ct,'vcx_thue',FBH_CSO_TIEN_KNT(b_vcx_thue ) || N' đồng' );
-- lay dt_lt
select count(*) into b_i1 from bh_xe_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_lt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_lt FROM bh_xe_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_lt';
end if;

-- lay dt_kbt
select count(*) into b_i1 from bh_xe_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_kbt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_kbt FROM bh_xe_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_kbt';
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
        end if;
       
    end loop;
  end if;
end if;
---thong tin thanh toan
delete temp_4;
select count(*) into b_i1 from bh_xe_tt where ma_dvi = b_ma_dvi and so_id = b_so_id;
PKH_JS_THAYa(dt_ct,'so_ky_tt',b_i1);
if  b_i1 = 1 then
    select min(ngay) into b_ngay_tt from bh_xe_tt where ma_dvi = b_ma_dvi and so_id = b_so_id;
    PKH_JS_THAYa(dt_ct,'thoi_han_tt',N'Thời hạn thanh toán phí bảo hiểm: thanh toán vào ngày '|| FBH_IN_CSO_NG(b_ngay_tt,'DD/MM/YYYY'));
elsif b_i1 > 1 then
    PKH_JS_THAYa(dt_ct,'thoi_han_tt',N'Thời hạn thanh toán phí bảo hiểm:');
    b_i1:= 1;
    for r_lp in (select ngay,tien from bh_xe_tt where ma_dvi = b_ma_dvi and so_id = b_so_id order by ngay asc)
    loop
    insert into temp_4(C1) values(N'-   Kỳ ' || b_i1 || N': thanh toán ' || FBH_CSO_TIEN(r_lp.tien,FKH_JS_GTRIs(dt_ct,'nt_tien')) || N' vào ngày ' || FBH_IN_CSO_NG(r_lp.ngay,'DD/MM/YYYY'));
    b_i1:= b_i1 + 1;
    end loop;
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_tt from temp_4;
delete temp_4;
--- lich su boi thuong
PKH_JS_THAY(dt_ct,'so_lan_kn','X');
PKH_JS_THAY(dt_ct,'tien_bt','X');
PKH_JS_THAY(dt_ct,'tl_bt','X');

select count(*) into b_i1 from bh_xe_ds where ma_dvi = b_ma_dvi and so_id = b_so_id;
if b_i1 > 1 then 
    b_loi := N'loi:Sai mẫu in HĐ 1 xe:loi';
    raise PROGRAM_ERROR; 
end if;
select xe_id into b_xe_id from bh_xe_ds where ma_dvi = b_ma_dvi and so_id = b_so_id;

select count(*) into b_so_lan_kn from bh_bt_xe bt
left join bh_xe x on  bt.so_id_hd = x.so_id
left join bh_xe_ds ds on ds.so_id = x.so_id
where bt.ma_dvi = b_ma_dvi and ds.xe_id = b_xe_id and bt.ttrang IN ('D','T');

select sum(bt.ttoan) into b_i1 from bh_bt_xe bt
left join bh_xe x on  bt.so_id_hd = x.so_id
left join bh_xe_ds ds on ds.so_id = x.so_id
where bt.ma_dvi = b_ma_dvi and ds.xe_id = b_xe_id and bt.ttrang IN ('D')
and bt.ngay_ht BETWEEN TO_NUMBER(TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE), -12), 'YYYYMMDD'))
                  AND TO_NUMBER(TO_CHAR(TRUNC(SYSDATE), 'YYYYMMDD'));

b_tien_bt:= b_tien_bt + b_i1;

select sum(dp.tien_qd) into b_i1 from bh_bt_hs_dp dp
left join bh_bt_xe bt on bt.so_id = dp.so_id
left join bh_xe x on  bt.so_id_hd = x.so_id
left join bh_xe_ds ds on ds.so_id = x.so_id
where ds.xe_id = b_xe_id and bt.ttrang IN ('T') 
and bt.ngay_ht BETWEEN TO_NUMBER(TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE), -12), 'YYYYMMDD'))
                  AND TO_NUMBER(TO_CHAR(TRUNC(SYSDATE), 'YYYYMMDD'));

b_tien_bt:= b_tien_bt + b_i1;
select phi into b_i1 from bh_xe where ma_dvi = b_ma_dvi and so_id = b_so_id;
b_temp_var:= FBH_TO_CHAR(b_tien_bt*100/b_i1);

if b_so_lan_kn <> 0 then PKH_JS_THAY(dt_ct,'so_lan_kn',b_so_lan_kn);end if;
if b_tien_bt <>0 then PKH_JS_THAY(dt_ct,'tien_bt',FBH_CSO_TIEN(b_tien_bt,'đồng'));end if;
if trim(b_temp_var) is not null then PKH_JS_THAY(dt_ct,'tl_bt',b_temp_var);end if;
--xu ly xoa 3.3 neu ko co ktru
if trim(FKH_JS_GTRIs(dt_ct ,'ktru')) is null then
    PKH_JS_THAY(dt_ct,'ktru','X');
end if;

---dong bh
PKH_JS_THAY(dt_ct,'dbh_x','X');
delete temp_2;commit;
select count(*) into b_i1 from BH_HD_DO_TL where ma_dvi = b_ma_dvi and so_id = b_so_id;
if b_i1 <> 0 then
  b_count_banin:= b_count_banin + b_i1;b_dong := true;
  PKH_JS_THAY(dt_ct,'dbh_x',' ');
  b_i1:= 0;b_i2:= 1;
  for r_lp in (select b.ten,a.pt,b.dchi,b.mobi,b.cmt,b.ma_tk,b.nhang,b.ma from BH_HD_DO_TL a, BH_MA_NBH b where a.so_id = b_so_id and a.nha_bh=b.ma)
  loop
      b_temp_nvar:= N'NHÀ ĐỒNG BẢO HIỂM' || CHR(10) || r_lp.ten;
      insert into temp_2(C1,C2,c3,c4,c5,c6,c7,c8,c9,c11) values(r_lp.ten,r_lp.pt,r_lp.dchi,r_lp.mobi,r_lp.cmt,r_lp.ma_tk,
        r_lp.nhang,N'NHÀ ĐỒNG BẢO HIỂM: ' || r_lp.ten,r_lp.ma,b_temp_nvar);
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
  'ma_tk' value c6, 'nhang' value c7, 'tend' value c8,'tien' value c10,'ten_1' value c11 returning clob) returning clob) into dt_dong from temp_2;
delete temp_2;commit;
--end dong
--kiem tra thong tin them co in thu huong hay ko
b_temp_var:= FKH_JS_GTRIs(dt_ct ,'HUONGK');
if b_temp_var = 'K' then
    PKH_JS_THAY(dt_ct,'hu_x','X');
    dt_hu:= null;
end if;
b_hu:= b_hu and (b_temp_var = 'C' or trim(b_temp_var) is null);
if trim(FKH_JS_GTRIs(dt_ct ,'LE')) is not null then
    b_i1:= TO_NUMBER(FKH_JS_GTRIs(dt_ct ,'LE'));
    b_count_banin:= b_i1;
end if;
--ban in
b_temp_clob := N'được lập thành ' || b_count_banin || N' (' || LOWER(FBH_IN_CSO_CHU(b_count_banin,'')) || N') bản, Bên mua bảo hiểm/ Người được bảo hiểm giữ 1 bản (một)';
if b_hu = true then
    b_temp_clob := b_temp_clob || N', Người thụ hưởng giữ 1(một) bản';
end if;
b_temp_clob := b_temp_clob || N', Bảo Hiểm AAA giữ 1 (một) bản';
if b_dong = true then
    b_temp_clob := b_temp_clob || N', mỗi Nhà đồng bảo hiểm giữ 1(một) bản';
end if;
b_temp_clob := b_temp_clob || N' có gia trị pháp lý như nhau.';
PKH_JS_THAY(dt_ct,'banin',b_temp_clob);
--end ban in


select json_object('dt_ct' value dt_ct,'dt_dk' value dt_dk,
'dt_qt' value dt_qt,'dt_bs' value dt_bs,'dt_kbt' value dt_kbt,
'dt_ttt' value dt_ttt,'dt_lt' value dt_lt,'dt_dong' value dt_dong,'dt_tt' value dt_tt,'dt_hu' value dt_hu,
'dt_lhbh' value b_lhbh_khac returning clob) into b_oraOut from dual;

commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;