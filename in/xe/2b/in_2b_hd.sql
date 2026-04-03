create or replace procedure PBH_2B_IN_HD(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    -- chung
    b_loi varchar2(100); b_lenh varchar2(1000);
    -- orain
    b_so_hd varchar2(50) :=FKH_JS_GTRIs(b_oraIn,'so_hd');
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
    b_so_id_dt number :=FKH_JS_GTRIn(b_oraIn,'so_id_dt');
    b_gcn varchar2(20) :=FKH_JS_GTRIs(b_oraIn,'gcn');
    
  --
    b_i1 number := 0;b_ngay_tt number;b_i2 number:=0;
    dt_ct clob; dt_bs clob; dt_ds clob; dt_dk clob; dt_lt clob;dt_kbt clob; dt_ttt clob;dt_dong clob;
    b_kh_ttt clob;dt_qt clob;dt_tt clob;b_dvi clob;dt_hu clob;
    b_tnds clob; b_lhbh_khac clob;

    ds_ct pht_type.a_clob;ds_dk pht_type.a_clob;ds_lt pht_type.a_clob;ds_kbt pht_type.a_clob;
    ds_ttt pht_type.a_clob;ds_dkbs pht_type.a_clob;

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
    a_dk_ma pht_type.a_var;a_dk_ten pht_type.a_nvar; a_dk_tien pht_type.a_num;a_dk_phi pht_type.a_num;a_dk_thue pht_type.a_num;
    a_dk_cap pht_type.a_num;a_dk_gvu pht_type.a_var;a_dk_ma_ct pht_type.a_var;a_dk_kieu pht_type.a_var;
    --a dt_hu
    a_hu_ten pht_type.a_nvar;a_hu_cmt pht_type.a_var; a_hu_mobi pht_type.a_var;a_hu_email pht_type.a_var;
    a_hu_dchi pht_type.a_nvar;a_hu_ng_ddien pht_type.a_nvar;a_hu_chucvu pht_type.a_nvar;

    b_bien_xe  varchar2(100);
begin
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);

if b_so_id = 0 then
    select so_id into b_so_id from bh_2b where ma_dvi = b_ma_dvi and so_hd = b_so_hd;
end if;

select bien_xe,so_id_dt into b_bien_xe,b_so_id_dt from bh_2b_ds where ma_dvi = b_ma_dvi and so_id = b_so_id and gcn = b_gcn;



--dt_hu
select count(*) into b_i1 from bh_2b_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_hu';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_hu FROM bh_2b_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_hu';
  b_lenh := FKH_JS_LENH('ten,cmt,mobi,email,dchi,ng_ddien,chucvu');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_hu_ten,a_hu_cmt,a_hu_mobi,a_hu_email,a_hu_dchi,a_hu_ng_ddien,a_hu_chucvu USING dt_hu;
  delete temp_2;commit;
  b_i1:= 1;
  for b_lp in 1..a_hu_ten.count loop
    b_temp_nvar:= N'NGƯỜI THỤ HƯỞNG: ' || a_hu_ten(b_lp);
    insert into temp_2(C1,c2,c3,c4,c5,c6,c7) values(b_temp_nvar,a_hu_cmt(b_lp),a_hu_mobi(b_lp),a_hu_email(b_lp),a_hu_dchi(b_lp),a_hu_ng_ddien(b_lp),a_hu_chucvu(b_lp));
    b_i1:= b_i1 +1;
  end loop;
  select JSON_ARRAYAGG(json_object('ten' VALUE C1,'cmt' VALUE C2,'mobi' VALUE C3,'email' VALUE C4,'dchi' VALUE C5,
  'ng_ddien' VALUE C6,'chucvu' VALUE C7  returning clob) returning clob) into dt_hu from temp_2;

  delete temp_2;commit;
end if;

---dt_ct
select count(*) into b_i1 from bh_2b_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ct FROM bh_2b_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_ct';
end if;


-----dt_ds
select count(*) into b_i1 from bh_2b_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_ds_txt';
if b_i1 <> 0 then
    SELECT FKH_JS_BONH(t.txt) INTO dt_ds FROM bh_2b_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ds_txt';
    b_lenh:=FKH_JS_LENHc('ds_ct,ds_dk,ds_lt,ds_kbt,ds_ttt,ds_dkbs');
    EXECUTE IMMEDIATE b_lenh bulk collect into ds_ct,ds_dk,ds_lt,ds_kbt,ds_ttt,ds_dkbs using dt_ds;
    if trim(b_gcn) is not null then
        for b_lp in 1..ds_ct.count loop
            b_temp_var:= FKH_JS_GTRIs(ds_ct(b_lp),'bien_xe');
            if b_bien_xe =  b_temp_var then
                  dt_ct:= ds_ct(b_lp);
                  dt_lt:= ds_lt(b_lp);
                  dt_ttt:= ds_ttt(b_lp);
                  dt_bs:= ds_dkbs(b_lp);
                  dt_dk:= ds_dk(b_lp);
            end if;
        end loop;
    else
        if ds_lt.count <> 0 then
            dt_lt:= ds_lt(1);
        end if;
        --ttt
        if ds_ttt.count <> 0 then
            dt_ttt:= ds_ttt(1);
        end if;
        if ds_dkbs.count <> 0 then
            dt_bs:= ds_dkbs(1);
        end if;
        if ds_dk.count <> 0 then
            dt_dk:= ds_dk(1);
        end if;
    end if; 
end if;
if dt_ct <> '""' then
    b_nt_tien:=FKH_JS_GTRIs(dt_ct ,'nt_tien');
    b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_hl');
    PKH_JS_THAYa(dt_ct,'gio_hl',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00') );
    b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_kt');
    PKH_JS_THAYa(dt_ct,'gio_kt',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00'));

     --ma khai thac
    select ma_kt,kieu_kt into b_ma_kt, b_kieu_kt from bh_2b where ma_dvi = b_ma_dvi and so_id = b_so_id;
    if b_kieu_kt = 'T' THEN
         select count(*) into b_i1 from ht_ma_cb where ma = b_ma_kt;
         if b_i1 <> 0 then select NVL(ten,' ') into b_temp_nvar from ht_ma_cb where ma = b_ma_kt;end if;
    elsif b_kieu_kt = 'D' THEN
      select count(*) into b_i1 from bh_dl_ma_kh where ma = b_ma_kt;
      if b_i1 <> 0 then select NVL(ten,' ') into b_temp_nvar from bh_dl_ma_kh where ma = b_ma_kt;end if;
    elsif b_kieu_kt = 'M' THEN
      select count(*) into b_i1 from bh_dl_ma_kh where ma = b_ma_kt;
      if b_i1 <> 0 then select NVL(ten,' ') into b_temp_nvar from bh_dl_ma_kh where ma = b_ma_kt;end if;
    elsif b_kieu_kt = 'N' THEN
      select count(*) into b_i1 from bh_ma_nhang where ma = b_ma_kt;
      if b_i1 <> 0 then select NVL(ten,' ') into b_temp_nvar from bh_ma_nhang where ma = b_ma_kt;end if;
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

    if trim(FKH_JS_GTRIs(dt_ct ,'ktru')) is not null then
        b_temp_nvar:= N'Áp dụng mức khấu trừ: '|| FBH_IN_SUBSTR(FKH_JS_GTRIs(dt_ct ,'ktru'),'|','T') ||N' đồng/vụ tổn thất';
        PKH_JS_THAY(dt_ct,'ktru',b_temp_nvar);
    end if;
    b_temp_var:= FKH_JS_GTRIs(dt_ct ,'loai_xe');
    if trim(b_temp_var) is not null THEN
        b_temp_var:= FBH_IN_SUBSTR(b_temp_var,'|','T');
        select ten into b_temp_nvar from bh_2b_loai where ma = b_temp_var;
        PKH_JS_THAY(dt_ct,'loai_xe',b_temp_nvar );
    end if;

    b_temp_var:= FKH_JS_GTRIs(dt_ct ,'hang');
    if trim(b_temp_var) is not null THEN
        b_temp_var:= FBH_IN_SUBSTR(b_temp_var,'|','T');
        select ten into b_temp_nvar from bh_2b_hang where ma = b_temp_var;
        PKH_JS_THAY(dt_ct,'hang',b_temp_nvar );
    end if;

    b_temp_var:= FKH_JS_GTRIs(dt_ct ,'hieu');
    if trim(b_temp_var) is not null THEN
        b_temp_var:= FBH_IN_SUBSTR(b_temp_var,'|','T');
        select ten into b_temp_nvar from bh_2b_hieu where ma = b_temp_var;
        PKH_JS_THAY(dt_ct,'hieu',b_temp_nvar );
    end if;

    b_temp_var:= FKH_JS_GTRIs(dt_ct ,'pban');
    if trim(b_temp_var) is not null THEN
        b_temp_var:= FBH_IN_SUBSTR(b_temp_var,'|','T');
        select ten into b_temp_nvar from bh_2b_pb where ma = b_temp_var;
        PKH_JS_THAY(dt_ct,'pban',b_temp_nvar );
    end if;
    --xoa nguoi mua neu nguoi mua != nguoi c
    if  FKH_JS_GTRIs(dt_ct ,'ten') <>  FKH_JS_GTRIs(dt_ct ,'tenc') and trim( FKH_JS_GTRIs(dt_ct ,'tenc')) is not null THEN
        PKH_JS_THAYx(dt_ct,'ten,dchi,mobi,email');
    end if;

    if trim(FKH_JS_GTRIs(dt_ct ,'tenc')) is null THEN
        PKH_JS_THAY(dt_ct,'tenc',FKH_JS_GTRIs(dt_ct ,'ten') );
        PKH_JS_THAY(dt_ct,'dchic',FKH_JS_GTRIs(dt_ct ,'dchi') );
        PKH_JS_THAY(dt_ct,'mobic',FKH_JS_GTRIs(dt_ct ,'mobi') );
        PKH_JS_THAY(dt_ct,'cmtc',FKH_JS_GTRIs(dt_ct ,'cmt') );
    end if;
    if trim(b_gcn) is not null then
        PKH_JS_THAY(dt_ct,'so_hd',b_gcn);
    end if;
end if;
--tt dvi
    select json_object('ten_gon' value  NVL(ten_gon,' '),'ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
           'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
               from ht_ma_dvi where ma=b_ma_dvi;
    dt_ct:=FKH_JS_BONH(dt_ct);
    b_dvi:=FKH_JS_BONH(b_dvi);
    select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;
--b_kh_ttt
SELECT '{' || LISTAGG('"' || ma || '": ""', ',') WITHIN GROUP (ORDER BY ma) || '}' into b_kh_ttt
    FROM bh_kh_ttt WHERE nv = 'XE' AND ps = 'HD';
    dt_ct:=FKH_JS_BONH(dt_ct);
    b_kh_ttt:=FKH_JS_BONH(b_kh_ttt);
    select json_mergepatch(dt_ct,b_kh_ttt) into dt_ct from dual;

--ttt
select count(*) into b_i1 from bh_2b_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ttt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ttt FROM bh_2b_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ttt';
else
   PKH_JS_THAYa(dt_ct,'NDT',' ');
end if;
--bs
PKH_JS_THAYa(dt_ct,'bs_lb','X');
if dt_bs <> '""' then PKH_JS_THAYa(dt_ct,'bs_lb',N'Điều khoản bổ sung:'); end if;
-- lay dt_dk
if dt_dk <> '""' then
    b_lenh := FKH_JS_LENH('ma,ten,tien,phi,thue,cap,gvu,ma_ct,kieu');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_dk_ma,a_dk_ten,a_dk_tien,a_dk_phi,a_dk_thue,a_dk_cap,a_dk_gvu,a_dk_ma_ct,a_dk_kieu USING dt_dk;
    delete temp_1;delete temp_3;
    b_i2:= 2;
    PKH_JS_THAY(dt_ct,'nguoi_bb_x','X');
    PKH_JS_THAY(dt_ct,'ts_bb_x','X');
    PKH_JS_THAY(dt_ct,'hk_bb_x','X');

    PKH_JS_THAY(dt_ct,'nguoi_bb',N'KHÔNG THAM GIA');
    PKH_JS_THAY(dt_ct,'ts_bb',N'KHÔNG THAM GIA');
    PKH_JS_THAY(dt_ct,'phi_bb',' ');

    PKH_JS_THAY(dt_ct,'nguoi_tn',N'KHÔNG THAM GIA');
    PKH_JS_THAY(dt_ct,'ts_tn',N'KHÔNG THAM GIA');
    PKH_JS_THAY(dt_ct,'phi_tn',' ');

    PKH_JS_THAY(dt_ct,'nntx_mtn',N'KHÔNG THAM GIA');
    PKH_JS_THAY(dt_ct,'nntx_so_nguoi',N'KHÔNG THAM GIA');
    PKH_JS_THAY(dt_ct,'nntx_phi',N'KHÔNG THAM GIA');

    for b_lp in 1..a_dk_ma.count loop
        if a_dk_ma(b_lp) = 'TNDS_BB.1' THEN
            if a_dk_tien(b_lp) > 0 then
                PKH_JS_THAY(dt_ct,'nguoi_bb_x', FBH_CSO_TIEN_KNT(a_dk_tien(b_lp))  || N' đồng/người/vụ');
                PKH_JS_THAY(dt_ct,'nguoi_bb', FBH_CSO_TIEN_KNT(a_dk_tien(b_lp))  || N' đồng/người/vụ');
            end if;
        elsif a_dk_ma(b_lp) = 'TNDS_BB' THEN
                PKH_JS_THAY(dt_ct,'phi_bb', FBH_CSO_TIEN(a_dk_phi(b_lp) ,b_nt_tien ));
        elsif a_dk_ma(b_lp) = 'TNDS_BB.2' THEN
            if a_dk_tien(b_lp) > 0 then
                PKH_JS_THAY(dt_ct,'ts_bb_x', FBH_CSO_TIEN_KNT(a_dk_tien(b_lp)  ) || N' đồng/vụ');
                PKH_JS_THAY(dt_ct,'ts_bb', FBH_CSO_TIEN_KNT(a_dk_tien(b_lp)  ) || N' đồng/vụ');
            end if;
        elsif a_dk_ma(b_lp) = 'TNDS_TN' THEN
            select sum(phi) into b_i1 from bh_2b_dk where ma_dvi = b_ma_dvi and so_id = b_so_id and ma_ct = a_dk_ma(b_lp);
            PKH_JS_THAY(dt_ct,'phi_tn', FBH_CSO_TIEN(b_i1 ,N'đồng' ));
        elsif a_dk_ma(b_lp) = 'TNDS_TN.1' THEN
            if a_dk_tien(b_lp) > 0 then
                PKH_JS_THAY(dt_ct,'nguoi_tn', FBH_CSO_TIEN_KNT(a_dk_tien(b_lp))  || N' đồng/người/vụ');
            end if;
        elsif a_dk_ma(b_lp) = 'TNDS_TN.2' THEN
            if a_dk_tien(b_lp) > 0 then
                PKH_JS_THAY(dt_ct,'ts_tn', FBH_CSO_TIEN_KNT(a_dk_tien(b_lp)  ) || N' đồng/vụ');
            end if;
        elsif a_dk_ma(b_lp) = 'NNTX' THEN
                PKH_JS_THAY(dt_ct,'nntx_phi', FBH_CSO_TIEN(a_dk_phi(b_lp) ,N'đồng' ));
        elsif a_dk_ma(b_lp) = 'NNTX.1' THEN
            if a_dk_tien(b_lp) > 0 then
                PKH_JS_THAY(dt_ct,'nntx_mtn', FBH_CSO_TIEN_KNT(a_dk_tien(b_lp))  || N' đồng/người/vụ');
            end if;
        elsif a_dk_ma(b_lp) = 'NNTX.2' THEN
            PKH_JS_THAY(dt_ct,'nntx_so_nguoi', a_dk_tien(b_lp));
        end if;
        
        if a_dk_ma(b_lp) = 'VCX.1' THEN
            insert into temp_3(C1,C2,C3,C4) values(a_dk_ma(b_lp),N'Bảo hiểm Thiệt hại vật chất xe ', FBH_CSO_TIEN_KNT(a_dk_tien(b_lp) ) || N' đồng' , FBH_CSO_TIEN_KNT(a_dk_phi(b_lp) ) || N' đồng');
        elsif a_dk_ma(b_lp) = 'VCX.2' THEN
            insert into temp_3(C1,C2,C3,C4) values(a_dk_ma(b_lp),N'Bảo hiểm Thiệt hại vật chất xe ', FBH_CSO_TIEN_KNT(a_dk_tien(b_lp) ) || N' đồng' , FBH_CSO_TIEN_KNT(a_dk_phi(b_lp) ) || N' đồng');
        elsif a_dk_ma(b_lp) = 'NNTX' THEN
                insert into temp_3(C1,C4) values(a_dk_ma(b_lp), FBH_CSO_TIEN(a_dk_phi(b_lp),b_nt_tien ));
        elsif a_dk_ma(b_lp) = 'NNTX.1' THEN
            if a_dk_tien(b_lp) > 0 then
                update temp_3 set C3 =  FBH_CSO_TIEN_KNT(a_dk_tien(b_lp) ) || N' đồng/người/vụ' where C1 = 'NNTX';
            end if;
        elsif a_dk_ma(b_lp) = 'NNTX.2' THEN
            update temp_3 set c2 = N'Bảo hiểm Tai nạn lái xe và người ngồi trên xe. '|| a_dk_ten(b_lp) || ': ' || a_dk_tien(b_lp) || N' người' where c1 = 'NNTX';
        end if;
    end loop;
    select JSON_ARRAYAGG(json_object('ten' VALUE (rownum + 1) || '. ' || C2,'mtn' value C3,'phi' value C4 returning clob) returning clob) into b_lhbh_khac from temp_3;
    delete temp_1;delete temp_3;
end if;
-- lay dt_kbt
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
                b_temp_nvar:= a_kbt_nd(b_lp2) ||N' đồng/vụ';
                PKH_JS_THAY(dt_ct,'ktru',b_temp_nvar);
            end if;
        end if;
        end loop;
    end if;
    
end loop;
end if;

---thong tin thanh toan
delete temp_4;
select count(*) into b_i1 from bh_2b_tt where ma_dvi = b_ma_dvi and so_id = b_so_id;
PKH_JS_THAYa(dt_ct,'so_ky_tt',b_i1);
if  b_i1 = 1 then
    select min(ngay) into b_ngay_tt from bh_2b_tt where ma_dvi = b_ma_dvi and so_id = b_so_id;
    PKH_JS_THAYa(dt_ct,'thoi_han_tt',N'Thời hạn thanh toán phí bảo hiểm: thanh toán trước ngày '|| FBH_IN_CSO_NG(b_ngay_tt,'DD/MM/YYYY'));
elsif b_i1 > 1 then
    PKH_JS_THAYa(dt_ct,'thoi_han_tt',N'Thời hạn thanh toán phí bảo hiểm:');
    b_i1:= 1;
    for r_lp in (select ngay,tien from bh_2b_tt where ma_dvi = b_ma_dvi and so_id = b_so_id order by ngay asc)
    loop
    insert into temp_4(C1) values(N'-   Kỳ ' || b_i1 || N': thanh toán ' || FBH_CSO_TIEN(r_lp.tien,FKH_JS_GTRIs(dt_ct,'nt_tien')) || N' trước ngày ' || FBH_IN_CSO_NG(r_lp.ngay,'DD/MM/YYYY'));
    b_i1:= b_i1 + 1;
    end loop;
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_tt from temp_4;
delete temp_4;
--- lich su boi thuong
PKH_JS_THAY(dt_ct,'so_lan_kn','X');
PKH_JS_THAY(dt_ct,'tien_bt','X');
PKH_JS_THAY(dt_ct,'tl_bt','X');
select xe_id into b_xe_id from bh_2b_ds where ma_dvi = b_ma_dvi and so_id = b_so_id and so_id_dt = b_so_id_dt;

select count(*) into b_so_lan_kn from bh_bt_xe bt
left join bh_2b x on  bt.so_id_hd = x.so_id
left join bh_2b_ds ds on ds.so_id = x.so_id
where bt.ma_dvi = b_ma_dvi and ds.xe_id = b_xe_id and bt.ttrang IN ('D','T');

select sum(bt.ttoan) into b_i1 from bh_bt_xe bt
left join bh_2b x on  bt.so_id_hd = x.so_id
left join bh_2b_ds ds on ds.so_id = x.so_id
where bt.ma_dvi = b_ma_dvi and ds.xe_id = b_xe_id and bt.ttrang IN ('D')
and bt.ngay_ht BETWEEN TO_NUMBER(TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE), -12), 'YYYYMMDD'))
                  AND TO_NUMBER(TO_CHAR(TRUNC(SYSDATE), 'YYYYMMDD'));

b_tien_bt:= b_tien_bt + b_i1;

select sum(dp.tien_qd) into b_i1 from bh_bt_hs_dp dp
left join bh_bt_xe bt on bt.so_id = dp.so_id
left join bh_2b x on  bt.so_id_hd = x.so_id
left join bh_2b_ds ds on ds.so_id = x.so_id
where ds.xe_id = b_xe_id and bt.ttrang IN ('T') 
and bt.ngay_ht BETWEEN TO_NUMBER(TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE), -12), 'YYYYMMDD'))
                  AND TO_NUMBER(TO_CHAR(TRUNC(SYSDATE), 'YYYYMMDD'));

b_tien_bt:= b_tien_bt + b_i1;
select phi into b_i1 from bh_2b where ma_dvi = b_ma_dvi and so_id = b_so_id;
b_temp_var:= FBH_TO_CHAR(b_tien_bt*100/b_i1);

if b_so_lan_kn <> 0 then PKH_JS_THAY(dt_ct,'so_lan_kn',b_so_lan_kn);end if;
if b_tien_bt <>0 then PKH_JS_THAY(dt_ct,'tien_bt',FBH_CSO_TIEN(b_tien_bt,b_nt_tien));end if;
if trim(b_temp_var) is not null then PKH_JS_THAY(dt_ct,'tl_bt',b_temp_var);end if;


--lay dt dong
delete temp_2;
select count(*) into b_i1 from BH_HD_DO_TL where ma_dvi = b_ma_dvi and so_id = b_so_id;
if b_i1 <> 0 then
  b_i1:= 0;
  for r_lp in (select b.ten,a.pt from BH_HD_DO_TL a, BH_MA_NBH b where a.so_id = b_so_id and a.nha_bh=b.ma)
  loop
      insert into temp_2(C1,C2) values(r_lp.ten,r_lp.pt);
      b_i1:= b_i1 + r_lp.pt;
  end loop;
  PKH_JS_THAY(dt_ct,'pt_dong',b_i1);
end if;
select JSON_ARRAYAGG(json_object('ten' VALUE C1,'pt' VALUE C2, 'stt' value rownum) returning clob) into dt_dong from temp_2;
delete temp_2;
--end dong
select json_object('dt_ct' value dt_ct,'dt_dk' value dt_dk,
'dt_qt' value dt_qt,'dt_bs' value dt_bs,'dt_kbt' value dt_kbt,
'dt_ttt' value dt_ttt,'dt_lt' value dt_lt,'dt_dong' value dt_dong,'dt_tt' value dt_tt,'dt_hu' value dt_hu,
'dt_lhbh' value b_lhbh_khac returning clob) into b_oraOut from dual;

commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;