create or replace procedure PBH_HANG_INHD(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    -- chung
    b_loi varchar2(100); b_lenh varchar2(1000);
    -- orain
    b_so_hd varchar2(50) :=FKH_JS_GTRIs(b_oraIn,'so_hd');
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
    b_bena_ten NVARCHAR2(100);b_bena_dchi NVARCHAR2(100);
    b_so_hd_g NVARCHAR2(500):= ' ';b_ma_hang varchar2(20);b_nhang NVARCHAR2(500) :=' ';
    b_so_hd_g_e NVARCHAR2(500):= ' ';
  --
    b_i1 number := 0;b_i2 number := 0;
    dt_ct clob; dt_bs clob; dt_ds clob; dt_dk clob; dt_lt clob;dt_kbt clob; dt_ttt clob;dt_pt clob;
    dt_vch clob;b_dvi clob;dt_hu clob;dt_tt clob;
    b_kh_ttt clob;dt_lte clob;dt_bse clob;dt_dke clob;dt_dong clob;
    b_ten nvarchar2(500):= ' ';
    b_ten_dvi nvarchar2(500):= ' ';
    b_quy_tac nvarchar2(500):= ' ';b_ma_qtac varchar2(20);
    b_pt nvarchar2(500):= ' ';b_ma_pt varchar2(20);
    b_ngay_tt number;b_ngay_tt_s  varchar2(20) := ' ';
    b_cang_di nvarchar2(500):= ' ';b_cang_den nvarchar2(500):= ' ';b_noi_di nvarchar2(500):= ' ';b_noi_den nvarchar2(500):= ' ';
    b_tlp varchar2(20):=' ';
    b_ma_gd nvarchar2(500):= ' ';b_ten_gd nvarchar2(500):= ' ';b_mobi_gd varchar2(20):=' ';b_dchi_gd nvarchar2(500):= ' ';
    b_ma_kvuc varchar2(20);
    b_ten_kvuc nvarchar2(500):= ' ';
    --bien mang
    a_lt_ma pht_type.a_var;a_lt_ten pht_type.a_nvar;
    b_tene_lt clob:= ' ';
    b_ndungd nvarchar2(500):= ' ';

    a_dk_ma pht_type.a_var; a_dk_lhbh pht_type.a_var;a_dk_ten pht_type.a_nvar;a_dk_tc pht_type.a_var;
    a_kbt_ma pht_type.a_var;a_kbt pht_type.a_clob;
    kbt_ma pht_type.a_var;kbt_nd pht_type.a_var;
    b_mkt nvarchar2(500):= ' ';b_qtac nvarchar2(500):= ' ';

    b_temp_clob clob;a_clob pht_type.a_clob;
    -- vc_da pt
    a_ma_qtac pht_type.a_nvar;a_noi_ct pht_type.a_nvar;a_noi_den pht_type.a_nvar;
    --mang ptvc
    a_ten_pt pht_type.a_nvar;
    b_kieu_hd varchar2(20):= ' ';
    dt_ct_goc clob; b_so_id_g number;
    b_nt_tien varchar2(10):=' '; b_nt_phi varchar2(10):=' ';
    b_hd_kem varchar2(1):= '';
    b_temp nvarchar2(500):=' ';
    b_ngay varchar2(20):='';
    b_temp_var varchar2(100);b_temp_nvar varchar2(500);
    --a_dt_hu
     a_hu_ten pht_type.a_nvar;a_hu_cmt pht_type.a_var; a_hu_mobi pht_type.a_var;a_hu_email pht_type.a_var;
    a_hu_dchi pht_type.a_nvar;a_hu_ng_ddien pht_type.a_nvar;a_hu_chucvu pht_type.a_nvar;
    --a ds
    a_ds_ten pht_type.a_nvar;a_ds_gtri pht_type.a_num;
    a_ttt_ma pht_type.a_var; a_ttt_nd pht_type.a_nvar;

    b_nt_tienin varchar2(10):='K'; b_tygia number:=1;
begin

b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);

select count(*) into b_i1 from bh_hang_txt t WHERE  t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ct
       FROM bh_hang_txt t WHERE  t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_ct';
    --lay so hd g
    select so_hd_g into b_so_hd_g from bh_hang where so_id = b_so_id;
    PKH_JS_THAY_D(dt_ct,'so_hd_g','X');
    if trim(b_so_hd_g) is not null then
      select kieu_hd,so_id into b_kieu_hd,b_so_id_g from bh_hang where so_hd = b_so_hd_g;
      ---
      select count(*) into b_i1 from bh_hang_txt t WHERE  t.so_id = b_so_id_g AND t.loai='dt_ct';
      if b_i1 <> 0 then
          SELECT FKH_JS_BONH(t.txt) INTO dt_ct_goc  FROM bh_hang_txt t WHERE  t.so_id = b_so_id_g AND t.loai='dt_ct';
          b_hd_kem:=FKH_JS_GTRIs(dt_ct_goc ,'hd_kem');
      end if;
      if trim(b_kieu_hd) is not null and b_kieu_hd = 'U' then
          b_so_hd_g_e:= 'Under Principle No: ' || b_so_hd_g;
          b_temp_var:= unistr('\0043\00E1\0063\0020\0111\0069\1EC1\0075\0020\006B\0069\1EC7\006E\002C\0020\0111\0069\1EC1\0075\0020\006B\0068\006F\1EA3\006E\0020\006B\0068\00E1\0063\0020\0074\0068\0065\006F\0020\0048\0110\004E\0054\0020\0073\1ED1\003A\0020')|| b_so_hd_g;
      elsif trim(b_kieu_hd) is not null and b_kieu_hd = 'G' and b_hd_kem = 'C' then
          b_temp_var:= unistr('\0054\0068\0065\006F\0020\0068\1EE3\0070\0020\0111\1ED3\006E\0067\0020\0062\0061\006F\003A\0020')|| b_so_hd_g || '/';
      end if;

      PKH_JS_THAY_D(dt_ct,'so_hd_g_e',b_so_hd_g_e);
      PKH_JS_THAY_D(dt_ct,'so_hd_g',b_temp_var);
    end if;
    -- check ten nguoi huong
    if trim(FKH_JS_GTRIs(dt_ct,'tend')) is null then
        PKH_JS_THAY_D(dt_ct,'tend',FKH_JS_GTRIs(dt_ct,'ten'));
    end if;
    -- lay ma hang
    b_nhang:= SUBSTR(FKH_JS_GTRIs(dt_ct,'ma_nhang'), INSTR(FKH_JS_GTRIs(dt_ct,'ma_nhang'), '|') + 1) ;
     --lay qtac
    b_ndungd:= FKH_JS_GTRIs(dt_ct ,'ndungd');
    b_qtac:= FKH_JS_GTRIs(dt_ct,'ma_qtac');
    b_qtac:= SUBSTR(b_qtac, INSTR(b_qtac, '|') + 1);
    b_nt_tien := FKH_JS_GTRIs(dt_ct ,'nt_tien');
    b_nt_phi := FKH_JS_GTRIs(dt_ct ,'nt_phi');

    select NVL(kvuc, ' ') into b_ma_kvuc from ht_ma_dvi where ma = b_ma_dvi;
    if trim(b_ma_kvuc) is not null then
      select count(*) into b_i1 from  bh_ma_kvuc where ma = b_ma_kvuc;
      if b_i1 <> 0 then
        select ten into b_ten_kvuc from bh_ma_kvuc where ma = b_ma_kvuc;
      end if;
    end if;

    --
    SELECT '{' || LISTAGG('"' || ma || unistr('\0022\003A\0020\0022\0054\0068\00F4\006E\0067\0020\0062\00E1\006F\0020\0073\0061\0075\0022'), ',') WITHIN GROUP (ORDER BY ma) || '}' into b_kh_ttt
    FROM bh_kh_ttt
    WHERE nv = 'HANG' AND ps = 'HD';

    dt_ct:=FKH_JS_BONH(dt_ct);
    b_kh_ttt:=FKH_JS_BONH(b_kh_ttt);
    select json_mergepatch(dt_ct,b_kh_ttt) into dt_ct from dual;

     --thong tin nuoc di
    b_temp:= ' ';--FKH_JS_GTRIs(dt_ct ,'cang_di');
    select count(*) into b_i1 from bh_ma_nuoc where ma = b_temp;
    if b_i1 <> 0 then
      select ten into b_temp from bh_ma_nuoc where ma = b_temp;
      if trim(FKH_JS_GTRIs(dt_ct ,'noi_di')) is not null then
        b_temp:= FKH_JS_GTRIs(dt_ct ,'noi_di');
      end if;
      PKH_JS_THAY_D(dt_ct,'noi_di',b_temp);
    end if;
    --nuoc den
    b_temp:= ' ';
    --b_temp:= FKH_JS_GTRIs(dt_ct ,'cang_den');
    select count(*) into b_i1 from bh_ma_nuoc where ma = b_temp;
    if b_i1 <> 0 then
      select ten into b_temp from bh_ma_nuoc where ma = b_temp;
      if trim(FKH_JS_GTRIs(dt_ct ,'noi_den')) is not null then
        b_temp:= FKH_JS_GTRIs(dt_ct ,'noi_den');
      end if;
      PKH_JS_THAY_D(dt_ct,'noi_den',b_temp);
    end if;
    --tlp
    select FBH_TO_CHAR(pt) into b_tlp from bh_hang_dk t1
      left join bh_ma_dk t2 on t1.ma_dk = t2.ma
      where t1.so_id = b_so_id and trim(t1.ma_dk) is not null and trim(t2.ma) is not null;

    -- pp tinh
    b_ma_pt:= FKH_JS_GTRIs(dt_ct,'ma_pptinh');
    if trim(b_ma_pt) is not null then
      select count(*) into b_i1 from bh_hang_pp where ma = b_ma_pt;
      if b_i1 <> 0 then
         select ten into b_pt from bh_hang_pp where ma = b_ma_pt;
         PKH_JS_THAY_D(dt_ct,'ma_pptinh',b_pt);
      end if;
    end if;
    -- pt van chuyen
    b_pt := SUBSTR(FKH_JS_GTRIs(dt_ct,'ma_pt'), INSTR(FKH_JS_GTRIs(dt_ct,'ma_pt'), '|') + 1) ;
    --giam dinh
    b_ma_gd:= FKH_JS_GTRIs(dt_ct,'gdinh');
    b_ma_gd:= FBH_IN_SUBSTR(b_ma_gd,'|','T');
    select count(*) into b_i1 from bh_ma_gdinh where ma = b_ma_gd;
    PKH_JS_THAY_D(dt_ct,'ten_gd',' ');
    PKH_JS_THAY_D(dt_ct,'ten_gde',' ');
    PKH_JS_THAY_D(dt_ct,'mobi_gd',' ');
    PKH_JS_THAY_D(dt_ct,'dchi_gd',' ');
    PKH_JS_THAY_D(dt_ct,'fax_gd',' ');
    if b_i1 <> 0 then
      select txt into b_temp_clob from bh_ma_gdinh where ma = b_ma_gd;
      PKH_JS_THAY_D(dt_ct,'ten_gd',FKH_JS_GTRIs(b_temp_clob,'ten'));
      PKH_JS_THAY_D(dt_ct,'ten_gde',FKH_JS_GTRIs(b_temp_clob,'tene'));
      PKH_JS_THAY_D(dt_ct,'dchi_gd',FKH_JS_GTRIs(b_temp_clob,'dchi'));
      PKH_JS_THAY_D(dt_ct,'fax_gd',FKH_JS_GTRIs(b_temp_clob,'fax'));
      PKH_JS_THAY_D(dt_ct,'mobi_gd',FKH_JS_GTRIs(b_temp_clob,'mobi'));
    end if;
    
    -- ngay hl, ngay kt
    b_i2:= FKH_JS_GTRIn(dt_ct,'ngay_hl');
    if b_i2 <> 30000101 then PKH_JS_THAY_D(dt_ct,'ngay_hl',FBH_IN_CSO_NG(b_i2,'DD/MM/YYYY')); else PKH_JS_THAY_D(dt_ct,'ngay_hl',unistr('\0054\0068\00F4\006E\0067\0020\0062\00E1\006F\0020\0073\0061\0075')); end if;
    b_i1:= FKH_JS_GTRIn(dt_ct,'ngay_kt');
    if b_i1 <> 30000101 then PKH_JS_THAY_D(dt_ct,'ngay_kt',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY')); else PKH_JS_THAY_D(dt_ct,'ngay_kt',unistr('\0054\0068\00F4\006E\0067\0020\0062\00E1\006F\0020\0073\0061\0075')); end if;
    b_i1:= FKH_JS_GTRIn(dt_ct,'ngay_cap');
    if b_i1 <> 30000101 then PKH_JS_THAY_D(dt_ct,'ngay_cap',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY')); else PKH_JS_THAY_D(dt_ct,'ngay_cap',unistr('\0054\0068\00F4\006E\0067\0020\0062\00E1\006F\0020\0073\0061\0075')); end if;
    if b_i2 < b_i1 then
        PKH_JS_THAY_D(dt_ct,'canh_bao',unistr('\0042\1EA3\006F\0020\0068\0069\1EC3\006D\0020\0041\0041\0041\0020\0073\1EBD\0020\006B\0068\00F4\006E\0067\0020\0063\0068\1ECB\0075\0020\0074\0072\00E1\0063\0068\0020\006E\0068\0069\1EC7\006D\0020\0111\1ED1\0069\0020\0076\1EDB\0069\0020\0062\1EA5\0074\0020\006B\1EF3\0020\0074\1ED5\006E\0020\0074\0068\1EA5\0074\002C\0020\006B\0068\0069\1EBF\0075\0020\006E\1EA1\0069\0020\006E\00E0\006F\0020\0078\1EA3\0079\0020\0072\0061\0020\0074\0072\01B0\1EDB\0063\0020\0030\0030\003A\0030\0030\0020\006E\0067\00E0\0079\0020') || FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY'));
    end if;

    --tt dvi
    select json_object('ten_gon' value  NVL(ten_gon,' '),'ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
           'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
               from ht_ma_dvi where ma=b_ma_dvi;
    dt_ct:=FKH_JS_BONH(dt_ct);
    b_dvi:=FKH_JS_BONH(b_dvi);
    select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;

    b_nt_tienin:= FKH_JS_GTRIs(dt_ct ,'nt_tienin');
    b_tygia:= FKH_JS_GTRIn(dt_ct ,'tygia');

    b_i1:= FKH_JS_GTRIn(dt_ct ,'tygia');
    PKH_JS_THAY_D(dt_ct,'tygia',FBH_CSO_TIEN(b_i1,'') );

    b_i1:= FKH_JS_GTRIn(dt_ct ,'phi');
    PKH_JS_THAY_D(dt_ct,'phi',FBH_CSO_TIEN(b_i1,b_nt_phi) );

    b_i1:= FKH_JS_GTRIn(dt_ct ,'gia');
    PKH_JS_THAY_D(dt_ct,'gia',FBH_CSO_TIEN(b_i1,b_nt_tien) );

    b_i1:= FKH_JS_GTRIn(dt_ct ,'thue');
    PKH_JS_THAY_D(dt_ct,'thue',FBH_CSO_TIEN(b_i1,b_nt_phi) );

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ttoan');
    PKH_JS_THAY_D(dt_ct,'ttoan',FBH_CSO_TIEN(b_i1,b_nt_phi) );


    b_i1:= FKH_JS_GTRIn(dt_ct ,'tong_mtnh');
    PKH_JS_THAY_D(dt_ct,'tong_mtnh',FBH_CSO_TIEN(b_i1,'') );
    if b_nt_tienin = 'C' then
      b_i1:= b_i1* b_tygia;
      b_temp_var:= b_nt_phi;
      PKH_JS_THAY_D(dt_ct,'tong_mtnh_tgia',FBH_CSO_TIEN(b_i1,b_temp_var) );
    else
      b_temp_var:= b_nt_tien;
      PKH_JS_THAY_D(dt_ct,'tong_mtnh_tgia',' ');
    end if;

    PKH_JS_THAY_D(dt_ct,'bangchu',FBH_IN_CSO_CHU(b_i1,b_temp_var) );
    PKH_JS_THAY_D(dt_ct,'bangchu_e',FBH_IN_CSO_CHU_EN(b_i1,b_temp_var) );

    if b_nt_tien <> 'VND' or FKH_JS_GTRIs(dt_ct ,'nt_phi') <> 'VND' then
       if b_nt_tien <> 'VND' then b_temp_var:= b_nt_tien; else b_temp_var:= FKH_JS_GTRIs(dt_ct ,'nt_phi'); end if;
      PKH_JS_THAY_D(dt_ct,'qdoi','VND/' || b_temp_var);
    else
      PKH_JS_THAY_D(dt_ct,'qdoi', b_nt_tien);
    end if;
    PKH_JS_THAY_D(dt_ct,'qdoi','VND/' || b_nt_tien);
    b_temp_var:= FKH_JS_GTRIs(dt_ct ,'c_ctai');
    if trim(b_temp_var) is not null then
      if b_temp_var = 'K' then
          PKH_JS_THAY_D(dt_ct,'c_ctai', unistr('\004B\0068\00F4\006E\0067') );
          PKH_JS_THAY_D(dt_ct,'c_ctai_e', unistr('\004E\006F') );
      else
          PKH_JS_THAY_D(dt_ct,'c_ctai', unistr('\0043\00F3') );
          PKH_JS_THAY_D(dt_ct,'c_ctai_e', unistr('\0059\0065\0073') );
      end if;
    end if;

    if trim(FKH_JS_GTRIs(dt_ct ,'so_hd_g')) is not null then
      PKH_JS_THAY_D(dt_ct,'so_hd_g2', unistr('\0054\0068\0065\006F\0020\0068\1EE3\0070\0020\0111\1ED3\006E\0067\0020\006E\0067\0075\0079\00EA\006E\0020\0074\1EAF\0063\0020') ||  FKH_JS_GTRIs(dt_ct ,'so_hd_g'));
    end if;

end if;
-- lay ttt
select count(*) into b_i1 from bh_hang_txt t WHERE  t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_ttt';
if b_i1 <> 0 then
  select FKH_JS_BONH(t.txt) into dt_ttt from bh_hang_txt t WHERE  t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_ttt';
  b_lenh := FKH_JS_LENH('ma,nd');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ttt_ma,a_ttt_nd USING dt_ttt;
  for b_lp in 1..a_ttt_ma.count loop
    SELECT json_mergepatch(dt_ct, json_object(a_ttt_ma(b_lp) VALUE a_ttt_nd(b_lp) RETURNING CLOB))INTO dt_ct FROM dual;
    SELECT json_mergepatch(dt_ct, json_object(a_ttt_ma(b_lp) || '_E' VALUE a_ttt_nd(b_lp) RETURNING CLOB))INTO dt_ct FROM dual;
  end loop;
end if;

PKH_JS_THAY_D(dt_ct,'ngay_tt_str',b_ngay_tt_s);
PKH_JS_THAY_D(dt_ct,'nhang', UPPER(b_nhang) );

if b_tlp is not null then
   PKH_JS_THAY_D(dt_ct,'tlp',b_tlp);
else
  PKH_JS_THAY_D(dt_ct,'tlp',' ');
end if;
PKH_JS_THAY_D(dt_ct,'ten_kvuc',b_ten_kvuc);
----check LC
if trim(FKH_JS_GTRIs(dt_ct ,'MTLC')) is null or  FKH_JS_GTRIs(dt_ct ,'MTLC')= unistr('\0054\0068\00F4\006E\0067\0020\0062\00E1\006F\0020\0073\0061\0075') then
  PKH_JS_THAY_D(dt_ct,'MTLC','X');
else
  PKH_JS_THAY_D(dt_ct,'MTLC', FKH_JS_GTRIs(dt_ct ,'MTLC'));
end if;
--dt_hu
PKH_JS_THAY_D(dt_ct,'nguoi_hu','X');
PKH_JS_THAY_D(dt_ct,'nguoi_hu_e','X');
select count(*) into b_i1 from bh_hang_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_hk';
if b_i1 <> 0 then
  PKH_JS_THAY_D(dt_ct,'nguoi_hu',unistr('\004E\0067\01B0\1EDD\0069\0020\0074\0068\1EE5\0020\0068\01B0\1EDF\006E\0067\003A'));
  PKH_JS_THAY_D(dt_ct,'nguoi_hu_e',unistr('\0042\0065\006E\0065\0066\0069\0063\0069\0061\0072\0079'));

  SELECT FKH_JS_BONH(t.txt) INTO dt_hu FROM bh_hang_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_hk';
  b_lenh := FKH_JS_LENH('ten,cmt,mobi,email,dchi,ng_ddien,chucvu');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_hu_ten,a_hu_cmt,a_hu_mobi,a_hu_email,a_hu_dchi,a_hu_ng_ddien,a_hu_chucvu USING dt_hu;
  delete temp_2;commit;
  b_i1:= 1;
  for b_lp in 1..a_hu_ten.count loop
    if a_hu_ten.count > 1 then
      b_temp_nvar:= unistr('\004E\0067\01B0\1EDD\0069\0020\0074\0068\1EE5\0020\0068\01B0\1EDF\006E\0067\0020\0074\0068\1EE9\0020') || Lower(FBH_IN_SO_CHU(b_i1)) || ': ' || a_hu_ten(b_lp);
    else
      b_temp_nvar:=  a_hu_ten(b_lp);
    end if;
    insert into temp_2(C1,c2,c3,c4,c5,c6,c7) values(b_temp_nvar,a_hu_cmt(b_lp),a_hu_mobi(b_lp),a_hu_email(b_lp),a_hu_dchi(b_lp),a_hu_ng_ddien(b_lp),a_hu_chucvu(b_lp));
    b_i1:= b_i1 +1;
  end loop;
  select JSON_ARRAYAGG(json_object('ten' VALUE C1,'cmt' VALUE C2,'mobi' VALUE C3,'email' VALUE C4,'dchi' VALUE C5,
  'ng_ddien' VALUE C6,'chucvu' VALUE C7  returning clob) returning clob) into dt_hu from temp_2;

  delete temp_2;commit;
end if;
-- dt_vch
select count(*) into b_i1 from bh_hang_txt t WHERE  t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_vch';
if b_i1 <> 0 then
  select FKH_JS_BONH(t.txt) into dt_vch from bh_hang_txt t WHERE  t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_vch';
  --a_ma_qtac;a_noi_ct;a_noi_den;
  b_lenh := FKH_JS_LENH('ma_qtac,noi_ct,noi_den');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ma_qtac,a_noi_ct,a_noi_den USING dt_vch;
  for b_lp in 1..a_ma_qtac.count loop
    b_qtac:= b_qtac || '; ' || FBH_IN_SUBSTR(a_ma_qtac(b_lp),'|','S');
    if trim(a_noi_ct(b_lp)) is not null then
      b_qtac:= b_qtac || ' - ' || a_noi_ct(b_lp);
    end if;
    if trim(a_noi_den(b_lp)) is not null then
      b_qtac:= b_qtac || ' - ' || a_noi_den(b_lp);
    end if;
  end loop;
end if;
PKH_JS_THAY_D(dt_ct,'qtac',b_qtac || ' - ' || b_ndungd);
-- lay dt_pt
select count(*) into b_i1 from bh_hang_txt t WHERE  t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_pt';
if b_i1 <> 0 then
  select FKH_JS_BONH(t.txt) into dt_pt from bh_hang_txt t WHERE  t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_pt';
  b_lenh := FKH_JS_LENH('ten_pt');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ten_pt USING dt_pt;
  if a_ten_pt.count <> 0 then
     PKH_JS_THAY_D(dt_ct,'pt_vc',a_ten_pt(1));
  else
    PKH_JS_THAY_D(dt_ct,'pt_vc',unistr('\0054\0068\00F4\006E\0067\0020\0062\00E1\006F\0020\0073\0061\0075'));
  end if;

end if;
-- lay ds
select count(*) into b_i1 from bh_hang_txt t WHERE  t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_ds';
if b_i1 <> 0 then
  select FKH_JS_BONH(t.txt) into dt_ds from bh_hang_txt t WHERE  t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_ds';
  b_lenh := FKH_JS_LENH('ten,gia_tri');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ds_ten,a_ds_gtri USING dt_ds;
  PKH_JS_THAY_D(dt_ct,'ten_hang', a_ds_ten(1));
  b_i1:= a_ds_gtri(1);
  if b_nt_tienin = 'C' then
    b_i1:= b_i1* b_tygia;
    PKH_JS_THAY_D(dt_ct,'gtri', FBH_CSO_TIEN(b_i1,b_nt_phi));
  else
    PKH_JS_THAY_D(dt_ct,'gtri', FBH_CSO_TIEN(b_i1,b_nt_tien));
  end if;
end if;

-- dk_lt
b_temp_clob:=''; b_tene_lt:='';
select count(*) into b_i1 from bh_hang_txt t WHERE  t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_lt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_lt
       FROM bh_hang_txt t WHERE  t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_lt';

  delete temp_4;
  b_lenh := FKH_JS_LENH('ma_lt,ten');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_lt_ma,a_lt_ten USING dt_lt;
  for b_lp in 1..a_lt_ma.count loop
    ---
    b_temp_clob:= b_temp_clob || '; ' || a_lt_ten(b_lp);
    ---
    select count(*) into b_i1 from bh_ma_dklt where ma = a_lt_ma(b_lp);
    if b_i1 <> 0 then
       SELECT FKH_JS_GTRIs(FKH_JS_BONH(t.txt) ,'tene') into b_temp_nvar from bh_ma_dklt t where  t.ma= a_lt_ma(b_lp) and rownum = 1;
       if trim(b_temp_nvar) is not null then
          b_tene_lt:= b_tene_lt || ';' || b_temp_nvar;
       end if;
    end if;
  end loop;
  insert into temp_4(cl1,cl2) values( LTRIM(b_temp_clob, ';'), LTRIM(b_tene_lt, ';'));
  select JSON_ARRAYAGG(json_object('ten' VALUE cl1 returning clob) returning clob) into dt_lt from temp_4;
  select JSON_ARRAYAGG(json_object('ten' VALUE cl2 returning clob) returning clob) into dt_lte from temp_4;
  delete temp_4;
end if;
-- lay dt_dk
select count(*) into b_i1 from bh_hang_txt t WHERE  t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_dk';
if b_i1 <> 0 then
  select FKH_JS_BONH(t.txt) into dt_dk from bh_hang_txt t WHERE  t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_dk';

  delete temp_6;
  -- 202051106 thi Chang said: lh_bh # C > dkbs, = C > dkc
  b_lenh := FKH_JS_LENH('ma,lh_bh,ten,lh_bh');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_dk_ma,a_dk_lhbh,a_dk_ten,a_dk_tc USING dt_dk;
  for b_lp in 1..a_dk_ma.count loop
      select count(*) into b_i1 from bh_ma_dkbs where ma = a_dk_ma(b_lp);
      if b_i1 <> 0 then
         SELECT FKH_JS_GTRIs(FKH_JS_BONH(t.txt) ,'tene') into b_temp_var from bh_ma_dkbs t where  t.ma= a_dk_ma(b_lp) and rownum = 1;
      end if;
      insert into temp_6(CL1,Cl2,C1) values(b_temp_var,a_dk_ten(b_lp),a_dk_tc(b_lp));
  end loop;
end if;
-- dt_dkbs
select JSON_ARRAYAGG(json_object('TEN' VALUE CL1) returning clob) into dt_lte FROM TEMP_4;
select JSON_ARRAYAGG(json_object('TEN' VALUE CL1) returning clob) into dt_bse FROM temp_6 where trim(C1) is null or C1 <> 'C' and CL1 is not null;
select JSON_ARRAYAGG(json_object('TEN' VALUE CL2) returning clob) into dt_bs FROM temp_6 where  trim(C1) is null or C1 <> 'C' and CL2 is not null;
select JSON_ARRAYAGG(json_object('TEN' VALUE CL1 ||' ' || b_ndungd) returning clob) into dt_dke FROM temp_6 where C1 = 'C' and CL2 is not null;
select JSON_ARRAYAGG(json_object('TEN' VALUE CL2 ||' ' || b_ndungd) returning clob) into dt_dk FROM temp_6 where C1 = 'C' and CL2 is not null;
delete temp_4;
delete temp_6;
--kbt
select count(*) into b_i1 from bh_hang_txt t WHERE  t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_kbt';
PKH_JS_THAY_D(dt_ct,'mkt','X');
if b_i1 <> 0 then
  select FKH_JS_BONH(t.txt) into dt_kbt from bh_hang_txt t WHERE  t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_kbt';
   b_lenh := FKH_JS_LENH('ma,kbt');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_kbt_ma,a_kbt USING dt_kbt;

    for b_lp in 1..a_kbt_ma.count loop
       if a_kbt(b_lp) is not null then
         b_lenh:=FKH_JS_LENH('ma,nd');
         EXECUTE IMMEDIATE b_lenh bulk collect into kbt_ma,kbt_nd using a_kbt(b_lp);
         for b_lp1 in 1..kbt_ma.count loop
           -- neu ma  = KVU
           if kbt_ma(b_lp1) = 'KVU' then
              b_mkt:= FBH_MKT(kbt_nd(b_lp1),b_nt_tien);
              PKH_JS_THAY_D(dt_ct,'mkt',unistr('\004D\1EE9\0063\0020\006B\0068\1EA5\0075\0020\0074\0072\1EEB\003A\0020') || b_mkt);
           end if;
         end loop;
       end if;
    end loop;
end if;
--lay dt dong
delete temp_2;commit;
select count(*) into b_i1 from BH_HD_DO_TL where ma_dvi = b_ma_dvi and so_id = b_so_id;
if b_i1 <> 0 then
  PKH_JS_THAY_D(dt_ct,'nhadong',unistr('\004E\0068\00E0\0020\0042\1EA3\006F\0020\0068\0069\1EC3\006D\0020\0074\0068\0065\006F\0020\0073\0061\0075\003A'));
  b_i1:= 0;b_i2:= 1;
  for r_lp in (select b.ten,a.pt,b.dchi,b.mobi,b.cmt,b.ma_tk,b.nhang from BH_HD_DO_TL a, BH_MA_NBH b where a.so_id = b_so_id and a.nha_bh=b.ma)
  loop
      b_temp_nvar:= unistr('\004E\0047\01AF\1EDC\0049\0020\0110\1ED2\004E\0047\0020\0042\1EA2\004F\0020\0048\0049\1EC2\004D\0020\0054\0048\1EE8\0020') || FBH_IN_SO_CHU(b_i2) || ': ' || r_lp.ten;
      insert into temp_2(C1,C2,c3,c4,c5,c6,c7,c8) values(r_lp.ten || unistr('\003A\0020\0054\1EF7\0020\006C\1EC7\0020') || r_lp.pt || '%',r_lp.pt,r_lp.dchi,r_lp.mobi,r_lp.cmt,r_lp.ma_tk,r_lp.nhang,b_temp_nvar);
      b_i1:= b_i1 + r_lp.pt;
      b_i2:=b_i2 +1;
  end loop;
  PKH_JS_THAY_D(dt_ct,'pt_dong',100 - b_i1);
end if;
select JSON_ARRAYAGG(json_object('ten' VALUE C1,'pt' VALUE C2, 'stt' value rownum + 1,'dchi' value C3,'mobi' value C4,'cmt' value c5,
  'ma_tk' value c6, 'nhang' value c7, 'tend' value c8) returning clob) into dt_dong from temp_2;
delete temp_2;commit;
--end dong
---thong tin thanh toan
delete temp_4;
select count(*) into b_i1 from bh_hang_tt where ma_dvi = b_ma_dvi and so_id = b_so_id;
PKH_JS_THAY_D(dt_ct,'so_ky_tt',b_i1);
if  b_i1 = 1 then
    select min(ngay) into b_ngay_tt from bh_hang_tt where ma_dvi = b_ma_dvi and so_id = b_so_id;
    PKH_JS_THAY_D(dt_ct,'thoi_han_tt', case when trim(b_so_hd_g) is null then '' else unistr('\0020\0054\0068\0065\006F\0020\0074\0068\1ECF\0061\0020\0074\0068\0075\1EAD\006E\0020') || b_so_hd_g || '/ ' end  || unistr('\0054\0072\01B0\1EDB\0063\0020\006E\0067\00E0\0079\0020\0020')|| FBH_IN_CSO_NG(b_ngay_tt,'DD/MM/YYYY') || unistr('\0020\006E\0068\01B0\006E\0067\0020\006B\0068\00F4\006E\0067\0020\0074\0072\1EC5\0020\0068\01A1\006E\0020\0074\0068\1EDD\0069\0020\0111\0069\1EC3\006D\0020\0070\0068\01B0\01A1\006E\0067\0020\0074\0069\1EC7\006E\0020\0063\1EAD\0070\0020\0063\1EA3\006E\0067\0020\0064\1EE1\0020\0068\00E0\006E\0067\0020\0074\1EA1\0069\0020\006E\01A1\0069\0020\0111\1EBF\006E\0020\0074\00F9\0079\0020\0074\0068\1EDD\0069\0020\0067\0069\0061\006E\0020\006E\00E0\006F\0020\0111\1EBF\006E\0020\0074\0072\01B0\1EDB\0063'));
elsif b_i1 > 1 then
    PKH_JS_THAY_D(dt_ct,'thoi_han_tt',unistr('\0054\0068\1EDD\0069\0020\0068\1EA1\006E\0020\0074\0068\0061\006E\0068\0020\0074\006F\00E1\006E\0020\0070\0068\00ED\0020\0062\1EA3\006F\0020\0068\0069\1EC3\006D\003A'));
    b_i1:= 1;
    for r_lp in (select ngay,tien from bh_hang_tt where ma_dvi = b_ma_dvi and so_id = b_so_id order by ngay asc)
    loop
    insert into temp_4(C1) values(unistr('\002D\0020\0020\0020\004B\1EF3\0020') || b_i1 || unistr('\003A\0020\0074\0068\0061\006E\0068\0020\0074\006F\00E1\006E\0020') || FBH_CSO_TIEN(r_lp.tien,FKH_JS_GTRIs(dt_ct,'nt_tien')) || unistr('\0020\0074\0072\01B0\1EDB\0063\0020\006E\0067\00E0\0079\0020') || FBH_IN_CSO_NG(r_lp.ngay,'DD/MM/YYYY'));
    b_i1:= b_i1 + 1;
    end loop;
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_tt from temp_4;
delete temp_4;
if trim(FKH_JS_GTRIs(dt_ct ,'plyd')) is null then
  PKH_JS_THAY_D(dt_ct,'plyd', 'X');
end if;

commit;
select json_object('dt_ct' value dt_ct,'dt_ds' value dt_ds,'dt_ttt' value dt_ttt,'dt_lt' value dt_lt,
       'dt_bs' value dt_bs,'dt_lte' value dt_lte,'dt_bse' value dt_bse,'dt_dk' value dt_dk,'dt_dke' value dt_dke,
       'dt_dong' value dt_dong, 'dt_hu' value dt_hu,'dt_tt' value dt_tt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
/
create or replace  procedure PBH_HANG_IN_B(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    -- chung
    b_loi varchar2(100); b_lenh varchar2(1000);
    -- orain
    b_so_hd varchar2(50) :=FKH_JS_GTRIs(b_oraIn,'so_hd');
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
    b_lan number:= TO_NUMBER(FKH_JS_GTRIs(b_oraIn,'lan_in'));
    b_bena_ten NVARCHAR2(100);b_bena_dchi NVARCHAR2(100);
    b_so_hd_g varchar2(50):= ' ';b_ma_hang varchar2(20);b_nhang NVARCHAR2(500) :=' ';
  --
    b_i1 number := 0;
    dt_ct clob; dt_bs clob; dt_ds clob; dt_dk clob; dt_lt clob;dt_kbt clob; dt_ttt clob;
    b_kh_ttt clob;dt_lte clob;dt_bse clob;dt_dke clob;

    b_ten_dvi nvarchar2(500):= ' ';
    b_quy_tac nvarchar2(500):= ' ';b_ma_qtac varchar2(20);
    b_pt nvarchar2(500):= ' ';b_ma_pt varchar2(20);
    b_ngay_tt number;b_ngay_tt_s  varchar2(20) := ' ';
    b_cang_di nvarchar2(500):= ' ';b_cang_den nvarchar2(500):= ' ';b_noi_di nvarchar2(500):= ' ';b_noi_den nvarchar2(500):= ' ';
    b_tlp varchar2(20):=' ';
    b_ma_gd nvarchar2(500):= ' ';b_ten_gd nvarchar2(500):= ' ';b_mobi_gd varchar2(20):=' ';
    b_ma_kvuc varchar2(20);
    b_ten_kvuc nvarchar2(500):= ' ';b_qtac nvarchar2(500):= ' ';
    --bien mang
    a_lt_ma pht_type.a_var;a_lt_ten pht_type.a_nvar;
    b_tene_lt  nvarchar2(500):= ' ';
    a_dk_ma pht_type.a_var; a_dk_lhbh pht_type.a_var;a_dk_ten pht_type.a_nvar;
    --kh
    b_ma_kh varchar2(20):=' ';
begin


b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);

select count(*) into b_i1 from bh_hangb_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ct
       FROM bh_hangb_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_ct' and lan = b_lan;
    -- lay ma hang
    b_nhang:= SUBSTR(FKH_JS_GTRIs(dt_ct,'ma_nhang'), INSTR(FKH_JS_GTRIs(dt_ct,'ma_nhang'), '|') + 1) ;
    --qtac
    --lay qtac
    b_qtac:= FKH_JS_GTRIs(dt_ct,'ma_qtac');
    b_qtac:= SUBSTR(b_qtac, INSTR(b_qtac, '|') + 1);
    -- lay ten dvi
    select count(*) into b_i1 from  ht_ma_dvi where ma = b_ma_dvi;
    if b_i1 <> 0 then
       select ten,kvuc into b_ten_dvi,b_ma_kvuc from ht_ma_dvi where ma = b_ma_dvi;
    end if;
    if trim(b_ma_kvuc) is not null then
      select count(*) into b_i1 from bh_ma_kvuc where ma = b_ma_kvuc;
      if b_i1 <> 0 then
         select NVL(ten,' ') into b_ten_kvuc from bh_ma_kvuc where ma = b_ma_kvuc;
      end if;
    end if;
    --
    SELECT '{' || LISTAGG('"' || ma || '": ""', ',') WITHIN GROUP (ORDER BY ma) || '}' into b_kh_ttt 
    FROM bh_kh_ttt
    WHERE nv = 'HANG' AND ps = 'HD';
    dt_ct:=FKH_JS_BONH(dt_ct);
    b_kh_ttt:=FKH_JS_BONH(b_kh_ttt);
    select json_mergepatch(dt_ct,b_kh_ttt) into dt_ct from dual;

    -- noi di, noi den
    b_cang_di:=SUBSTR(FKH_JS_GTRIs(dt_ct,'cang_di'), INSTR(FKH_JS_GTRIs(dt_ct,'cang_di'), '|') + 1) ;
    b_noi_di:=SUBSTR(FKH_JS_GTRIs(dt_ct,'noi_di'), INSTR(FKH_JS_GTRIs(dt_ct,'noi_di'), '|') + 1) ;
    b_cang_den:=SUBSTR(FKH_JS_GTRIs(dt_ct,'cang_den'), INSTR(FKH_JS_GTRIs(dt_ct,'cang_den'), '|') + 1) ;
    b_noi_den:=SUBSTR(FKH_JS_GTRIs(dt_ct,'noi_den'), INSTR(FKH_JS_GTRIs(dt_ct,'noi_den'), '|') + 1) ;
    if trim(b_noi_di) is not null then
      b_cang_di := b_cang_di || ', ' || b_noi_di; end if;
    if trim(b_noi_den) is not null then b_cang_den := b_cang_den || ', ' || b_noi_den; end if;
    --tlp
    -- pp tinh
    b_ma_pt:= FKH_JS_GTRIs(dt_ct,'ma_pptinh');
    if trim(b_ma_pt) is not null then
      select count(*) into b_i1 from bh_hang_pp where ma = b_ma_pt;
      if b_i1 <> 0 then
         select ten into b_pt from bh_hang_pp where ma = b_ma_pt;
         PKH_JS_THAY_D(dt_ct,'ma_pptinh',b_pt);
      end if;
    end if;
     -- pt van chuyen
    b_pt := SUBSTR(FKH_JS_GTRIs(dt_ct,'ma_pt'), INSTR(FKH_JS_GTRIs(dt_ct,'ma_pt'), '|') + 1) ;
    --giam dinh
    b_ma_gd:= FKH_JS_GTRIs(dt_ct,'gdinh');
    b_ma_gd:= SUBSTR(b_ma_gd, 1, INSTR(b_ma_gd, '|') - 1);
    select count(*) into b_i1 from bh_ma_gdinh where ma = b_ma_gd;
    if b_i1 <> 0 then
      select nvl(ten,' '),nvl(mobi,' ') into b_ten_gd,b_mobi_gd from bh_ma_gdinh where ma=b_ma_gd;
    end if;
    PKH_JS_THAY_D(dt_ct,'ten_gd,mobi_gd',b_ten_gd|| ',' ||b_mobi_gd);
end if;
PKH_JS_THAY_D(dt_ct,'ten_dvi,pt_vc,ngay_tt_str',b_ten_dvi || ',' || b_pt || ',' || b_ngay_tt_s);
PKH_JS_THAY_D(dt_ct,'so_hd_g,nhang',b_so_hd_g || ',' || UPPER(b_nhang) );
PKH_JS_THAY_D(dt_ct,'noi_di,noi_den',b_cang_di || ',' || b_cang_den );
PKH_JS_THAY_D(dt_ct,'tlp',b_tlp);
PKH_JS_THAY_D(dt_ct,'kvuc',b_ten_kvuc);
PKH_JS_THAY_D(dt_ct,'ngay',TO_CHAR(SYSDATE, 'DD'));
PKH_JS_THAY_D(dt_ct,'thang',TO_CHAR(SYSDATE, 'MM'));
PKH_JS_THAY_D(dt_ct,'nam',TO_CHAR(SYSDATE, 'YYYY'));
PKH_JS_THAY_D(dt_ct,'qtac',b_qtac);
-- linh vu theo thong tin kh
b_pt:= ' ';
b_ma_kh:=FKH_JS_GTRIs(dt_ct,'ma_kh');
select count(1) into b_i1 from bh_dtac_ma_txt where ma = b_ma_kh;
if b_i1 <> 0 then
  select NVL(FKH_JS_GTRIs(FKH_JS_BONH(txt),'nghe'),' ') into b_pt from bh_dtac_ma_txt where ma = b_ma_kh;
  if trim(b_pt) is not null then
     select count(1) into b_i1 from bh_ma_lvuc where ma = b_pt;
     if b_i1 <> 0 then
         select NVL(ten,' ') into b_pt from bh_ma_lvuc where ma = b_pt;
     end if;
  end if;
end if;
PKH_JS_THAY_D(dt_ct,'lvuc',b_pt);

-- lay ds
select count(*) into b_i1 from bh_hangb_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_ds';
if b_i1 <> 0 then
  select FKH_JS_BONH(t.txt) into dt_ds from bh_hangb_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_ds' and lan = b_lan;
end if;
-- lay ttt
select count(*) into b_i1 from bh_hangb_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_ttt';
if b_i1 <> 0 then
  select FKH_JS_BONH(t.txt) into dt_ttt from bh_hangb_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_ttt' and lan = b_lan;
end if;
-- dk_lt
select count(*) into b_i1 from bh_hangb_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_lt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_lt
       FROM bh_hangb_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_lt' and lan = b_lan;

  delete temp_4;
  b_lenh := FKH_JS_LENH('ma_lt,ten');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_lt_ma,a_lt_ten USING dt_lt;
  for b_lp in 1..a_lt_ma.count loop
    select count(*) into b_i1 from bh_ma_dklt where ma = a_lt_ma(b_lp);
    if b_i1 <> 0 then
       SELECT NVL(FKH_JS_GTRIs(FKH_JS_BONH(t.txt) ,'tene'),' ') into b_tene_lt from bh_ma_dklt t where  t.ma= a_lt_ma(b_lp) and rownum = 1;
       insert into temp_4(CL1,CL2) values(b_tene_lt,a_lt_ten(b_lp));
       --if trim(b_tene_lt) is not null then
          --insert into temp_4(CL1) values(b_tene_lt);
       --end if;
    end if;
  end loop;
end if;
-- lay dt_dk
select count(*) into b_i1 from bh_hangb_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_dk';
if b_i1 <> 0 then
  select FKH_JS_BONH(t.txt) into dt_dk from bh_hangb_txt t WHERE t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  AND t.loai='dt_dk' and lan = b_lan;

  delete temp_6;
  b_lenh := FKH_JS_LENH('ma_dk,lh_bh,ten');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_dk_ma,a_dk_lhbh,a_dk_ten USING dt_dk;
  for b_lp in 1..a_dk_ma.count loop
      select count(*) into b_i1 from bh_ma_dkbs where ma = a_dk_ma(b_lp);
      if b_i1 <> 0 then
         SELECT FKH_JS_GTRIs(FKH_JS_BONH(t.txt) ,'tene') into b_tene_lt from bh_ma_dkbs t where  t.ma= a_dk_ma(b_lp) and rownum = 1;
      end if;
      insert into temp_6(CL1,Cl2,C1) values(b_tene_lt,a_dk_ten(b_lp),a_dk_lhbh(b_lp));
  end loop;
end if;
-- dt_dkbs
select JSON_ARRAYAGG(json_object('TENE' VALUE CL1,'TEN' value CL2) returning clob) into dt_lte FROM TEMP_4;
select JSON_ARRAYAGG(json_object('TEN' VALUE CL1) returning clob) into dt_bse FROM temp_6 where C1 = 'B' and CL1 is not null;
select JSON_ARRAYAGG(json_object('TEN' VALUE CL2, 'TENE' value CL1) returning clob) into dt_bs FROM temp_6 where C1 = 'B';
select JSON_ARRAYAGG(json_object('TEN' VALUE CL1) returning clob) into dt_dke FROM temp_6 where C1 <> 'B' and CL2 is not null;
select JSON_ARRAYAGG(json_object('TEN' VALUE CL2) returning clob) into dt_dk FROM temp_6 where C1 <> 'B' and CL2 is not null;

delete temp_4;
delete temp_6;
commit;
select json_object('dt_ct' value dt_ct,'dt_ds' value dt_ds,'dt_ttt' value dt_ttt,'dt_lt' value dt_lt,
       'dt_bs' value dt_bs,'dt_lte' value dt_lte,'dt_bse' value dt_bse,'dt_dk' value dt_dk,'dt_dke' value dt_dke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;

/
create or replace procedure PBH_HANG_IN_SDBS(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    -- chung
    b_loi varchar2(100); b_lenh varchar2(1000);
	  b_i1 number := 0;
    -- orain
    b_so_hd varchar2(50) :=FKH_JS_GTRIs(b_oraIn,'so_hd');
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
    b_so_hd_g NVARCHAR2(500):= ' ';b_ma_hang varchar2(20);b_nhang NVARCHAR2(500) :=' ';
    b_so_hd_g_e NVARCHAR2(500):= ' ';a_ten_pt pht_type.a_nvar;
    b_ma_pt varchar2(20);b_pt nvarchar2(500):= ' ';
	
    b_kh_ttt clob;b_kh_ttt_e clob;
    dt_ct clob; dt_ttt clob;dt_pt clob;dt_kbt clob;
    dt_ct_goc clob;dt_ttt_goc clob;
    b_nt_tien varchar2(10):=' ';b_so_id_g number;
    b_nt_phi varchar2(10):=' ';
	  b_kieu_hd varchar2(20):= ' ';b_hd_kem varchar2(1):= '';
	--- merge thong tin them
    a_ttt_nd pht_type.a_var; a_ttt_ma pht_type.a_var;
    b_tien_bh nvarchar2(500):= ' ';
    b_dvi clob;
    --kbt
    a_kbt_ma pht_type.a_var;a_kbt pht_type.a_clob;
    kbt_ma pht_type.a_var;kbt_nd pht_type.a_var;
    b_mkt nvarchar2(500):= ' ';
    b_temp nvarchar2(500):=' ';
begin
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
select so_id_g into b_so_id_g from bh_hang where so_id = b_so_id and ma_dvi = b_ma_dvi;
if b_so_id_g = 0 then
   raise_application_error(-20105,N'loi:Không phải hợp đồng sửa đổi bổ sung:loi');
end if;
--lay so hd g
select kieu_hd into b_kieu_hd from bh_hang where so_id = b_so_id_g and ma_dvi = b_ma_dvi;
---
select count(*) into b_i1 from bh_hang_txt t WHERE  t.so_id = b_so_id_g and ma_dvi = b_ma_dvi AND t.loai='dt_ct';
if b_i1 <> 0 then
    SELECT FKH_JS_BONH(t.txt) INTO dt_ct_goc  FROM bh_hang_txt t WHERE  t.so_id = b_so_id_g AND t.loai='dt_ct';
    b_hd_kem:=FKH_JS_GTRIs(dt_ct_goc ,'hd_kem');
end if;
if trim(b_kieu_hd) is not null and b_kieu_hd = 'U' then
    b_so_hd_g:= N'(Theo hợp đồng nguyên tắc: '|| b_so_hd_g || ')';
    b_so_hd_g_e:= '(This Endorsement will be incorporated to and forming part of Policy No' || b_so_hd_g || ')';
else
    b_so_hd_g:=' ';b_so_hd_g_e:= ' ';
end if;
select count(*) into b_i1 from bh_hang_txt t WHERE  t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  and t.ma_dvi = b_ma_dvi AND t.loai='dt_ct';
if b_i1 <> 0 then
	SELECT FKH_JS_BONH(t.txt) INTO dt_ct FROM bh_hang_txt t WHERE  t.so_id = b_so_id and t.ma_dvi = b_ma_dvi   and t.ma_dvi = b_ma_dvi AND t.loai='dt_ct';
	--ttt
	SELECT '{' || LISTAGG('"' || ma || N'": "Thông báo sau"', ',') WITHIN GROUP (ORDER BY ma) || '}' into b_kh_ttt
    FROM bh_kh_ttt
    WHERE nv = 'HANG' AND ps = 'HD';
    dt_ct:=FKH_JS_BONH(dt_ct);
    b_kh_ttt:=FKH_JS_BONH(b_kh_ttt);
    select json_mergepatch(dt_ct,b_kh_ttt) into dt_ct from dual;


  --ttt_e
  SELECT '{' || LISTAGG('"' || ma || '_E' || N'": "To Be Advised"', ',') WITHIN GROUP (ORDER BY ma) || '}' into b_kh_ttt_e
      FROM bh_kh_ttt WHERE nv = 'HANG' AND ps = 'HD';
  dt_ct:=FKH_JS_BONH(dt_ct);
  b_kh_ttt_e:=FKH_JS_BONH(b_kh_ttt_e);
  select json_mergepatch(dt_ct,b_kh_ttt_e) into dt_ct from dual;
    -- pp tinh
    b_ma_pt:= FKH_JS_GTRIs(dt_ct,'ma_pptinh');
    if trim(b_ma_pt) is not null then
      select count(*) into b_i1 from bh_hang_pp where ma = b_ma_pt;
      if b_i1 <> 0 then
         select ten into b_pt from bh_hang_pp where ma = b_ma_pt;
         PKH_JS_THAY_D(dt_ct,'ma_pptinh',b_pt);
      end if;
    end if;
    --nt_tien
    b_nt_tien := FKH_JS_GTRIs(dt_ct ,'nt_tien');
    b_nt_phi := FKH_JS_GTRIs(dt_ct ,'nt_phi');
    -- tien bh
    b_i1 := FKH_JS_GTRIn(dt_ct,'tong_mtnh');
    b_tien_bh:= b_pt  || ' - ' || FBH_CSO_TIEN(b_i1,b_nt_tien);
    PKH_JS_THAY_D(dt_ct,'so_tien_bh',b_tien_bh);
    PKH_JS_THAY_D(dt_ct,'phi',FBH_CSO_TIEN(FKH_JS_GTRIn(dt_ct,'phi'),b_nt_phi));
    PKH_JS_THAY_D(dt_ct,'thue',FBH_CSO_TIEN(FKH_JS_GTRIn(dt_ct,'thue'),b_nt_tien));
    PKH_JS_THAY_D(dt_ct,'ttoan',FBH_CSO_TIEN(FKH_JS_GTRIn(dt_ct,'ttoan'),b_nt_tien));
    PKH_JS_THAY_D(dt_ct,'so_hd_g',b_so_hd_g);
    PKH_JS_THAY_D(dt_ct,'so_hd_g_e',b_so_hd_g_e);

    b_i1:= FKH_JS_GTRIn(dt_ct,'ngay_hl');
    if b_i1 = 0 or b_i1 = 30000101 then
        PKH_JS_THAY_D(dt_ct,'ngay_hl',N'Thông báo sau');
        PKH_JS_THAY_D(dt_ct,'ngay_hl_e','To Be Advised');
    else
        PKH_JS_THAY_D(dt_ct,'ngay_hl',FBH_IN_CSO_NG(b_i1,'dd/MM/yyyy'));
        PKH_JS_THAY_D(dt_ct,'ngay_hl_e',FBH_IN_CSO_NG(b_i1,'dd/MM/yyyy'));
    end if;

    b_i1:= FKH_JS_GTRIn(dt_ct,'ngay_cap');
    if b_i1 = 0 or b_i1 = 30000101 then
        PKH_JS_THAY_D(dt_ct,'ngay_cap',N' ');
    else
      PKH_JS_THAY_D(dt_ct,'ngay_cap',FBH_IN_CSO_NG(b_i1,'dd/MM/yyyy'));
    end if;
    --thong tin nuoc di
    b_temp:= FKH_JS_GTRIs(dt_ct ,'cang_di');
    select count(*) into b_i1 from bh_ma_nuoc where ma = b_temp;
    if b_i1 <> 0 then
      select ten into b_temp from bh_ma_nuoc where ma = b_temp;
      if trim(FKH_JS_GTRIs(dt_ct ,'noi_di')) is not null then
        b_temp:= FKH_JS_GTRIs(dt_ct ,'noi_di') || ', ' || b_temp;
      end if;
      PKH_JS_THAY_D(dt_ct,'noi_di',b_temp);
    end if;
    --nuoc den
    b_temp:= ' ';
    b_temp:= FKH_JS_GTRIs(dt_ct ,'cang_den');
    select count(*) into b_i1 from bh_ma_nuoc where ma = b_temp;
    if b_i1 <> 0 then
      select ten into b_temp from bh_ma_nuoc where ma = b_temp;
      if trim(FKH_JS_GTRIs(dt_ct ,'noi_den')) is not null then
        b_temp:= FKH_JS_GTRIs(dt_ct ,'noi_den') || ', ' || b_temp;
      end if;
      PKH_JS_THAY_D(dt_ct,'noi_den',b_temp);
    end if;
      --tt dvi
    select json_object('ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
            'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
                from ht_ma_dvi where ma=b_ma_dvi;
    dt_ct:=FKH_JS_BONH(dt_ct);
    b_dvi:=FKH_JS_BONH(b_dvi);
    select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;
end if;
-- lay ttt
select count(*) into b_i1 from bh_hang_txt t WHERE  t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  and t.ma_dvi = b_ma_dvi AND t.loai='dt_ttt';
if b_i1 <> 0 then
  select FKH_JS_BONH(t.txt) into dt_ttt from bh_hang_txt t 
		WHERE  t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  and t.ma_dvi = b_ma_dvi AND t.loai='dt_ttt';
	b_lenh := FKH_JS_LENH('ma,nd');
	EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ttt_ma,a_ttt_nd USING dt_ttt;
	for b_lp in 1..a_ttt_ma.count loop
		select json_mergepatch(dt_ct, json_object(a_ttt_ma(b_lp) value a_ttt_nd(b_lp) returning clob)) into dt_ct from dual;
    select json_mergepatch(dt_ct, json_object(a_ttt_ma(b_lp)|| '_E' value a_ttt_nd(b_lp) returning clob)) into dt_ct from dual;
	end loop;
end if;

-- lay dt_pt
select count(*) into b_i1 from bh_hang_txt t WHERE  t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  and t.ma_dvi = b_ma_dvi AND t.loai='dt_pt';
if b_i1 <> 0 then
  select FKH_JS_BONH(t.txt) into dt_pt from bh_hang_txt t WHERE  t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  and t.ma_dvi = b_ma_dvi AND t.loai='dt_pt';
  b_lenh := FKH_JS_LENH('ten_pt');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ten_pt USING dt_pt;
  if a_ten_pt.count <> 0 then
     PKH_JS_THAY_D(dt_ct,'pt_vc',a_ten_pt(1));
  else
    PKH_JS_THAY_D(dt_ct,'pt_vc',N'Thông báo sau');
  end if;
end if;
--kbt
select count(*) into b_i1 from bh_hang_txt t WHERE  t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  and t.ma_dvi = b_ma_dvi AND t.loai='dt_kbt';
if b_i1 <> 0 then
  select FKH_JS_BONH(t.txt) into dt_kbt from bh_hang_txt t WHERE  t.so_id = b_so_id and t.ma_dvi = b_ma_dvi  and t.ma_dvi = b_ma_dvi AND t.loai='dt_kbt';
  b_lenh := FKH_JS_LENH('ma,kbt');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_kbt_ma,a_kbt USING dt_kbt;

  for b_lp in 1..a_kbt_ma.count loop
      if a_kbt(b_lp) is not null then
        b_lenh:=FKH_JS_LENH('ma,nd');
        EXECUTE IMMEDIATE b_lenh bulk collect into kbt_ma,kbt_nd using a_kbt(b_lp);
        for b_lp1 in 1..kbt_ma.count loop
          -- neu ma  = KVU
          if kbt_ma(b_lp1) = 'KVU' then
            b_mkt:= FBH_MKT(kbt_nd(b_lp1),b_nt_tien);            
          end if;
        end loop;
      end if;
  end loop;
end if;
PKH_JS_THAY_D(dt_ct,'mkt',b_mkt);

------------------------------ dt_ct_goc
select count(*) into b_i1 from bh_hang_txt t WHERE  t.so_id = b_so_id_g and t.ma_dvi = b_ma_dvi AND t.loai='dt_ct';
if b_i1 <> 0 then
	SELECT FKH_JS_BONH(t.txt) INTO dt_ct_goc FROM bh_hang_txt t WHERE  t.so_id = b_so_id_g  and t.ma_dvi = b_ma_dvi AND t.loai='dt_ct';
  -- pp tinh
    b_pt := ' ';
    b_ma_pt:= FKH_JS_GTRIs(dt_ct_goc,'ma_pptinh');
    if trim(b_ma_pt) is not null then
      select count(*) into b_i1 from bh_hang_pp where ma = b_ma_pt;
      if b_i1 <> 0 then
         select ten into b_pt from bh_hang_pp where ma = b_ma_pt;
      end if;
    end if;
    --nt_tien
    b_nt_tien := FKH_JS_GTRIs(dt_ct_goc ,'nt_tien');
    b_nt_phi := FKH_JS_GTRIs(dt_ct_goc ,'nt_phi');
    -- tien bh
    b_i1 := FKH_JS_GTRIn(dt_ct_goc,'tong_mtnh');
    b_tien_bh:= b_pt  || ' - ' || FBH_CSO_TIEN(b_i1,b_nt_tien);
    PKH_JS_THAY_D(dt_ct_goc,'so_tien_bh',b_tien_bh);

    PKH_JS_THAY_D(dt_ct_goc,'phi',FBH_CSO_TIEN(FKH_JS_GTRIn(dt_ct_goc,'phi'),b_nt_phi));
    PKH_JS_THAY_D(dt_ct_goc,'thue',FBH_CSO_TIEN(FKH_JS_GTRIn(dt_ct_goc,'thue'),b_nt_tien));
    PKH_JS_THAY_D(dt_ct_goc,'ttoan',FBH_CSO_TIEN(FKH_JS_GTRIn(dt_ct_goc,'ttoan'),b_nt_tien));
    select json_mergepatch(dt_ct_goc,b_kh_ttt) into dt_ct_goc from dual;
    select json_mergepatch(dt_ct_goc,b_kh_ttt_e) into dt_ct_goc from dual;
end if;

--kbt
b_mkt:= ' ';
select count(*) into b_i1 from bh_hang_txt t WHERE  t.so_id = b_so_id_g and t.ma_dvi = b_ma_dvi AND t.loai='dt_kbt';
if b_i1 <> 0 then
  select FKH_JS_BONH(t.txt) into dt_kbt from bh_hang_txt t WHERE  t.so_id = b_so_id_g and t.ma_dvi = b_ma_dvi AND t.loai='dt_kbt';
  b_lenh := FKH_JS_LENH('ma,kbt');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_kbt_ma,a_kbt USING dt_kbt;

  for b_lp in 1..a_kbt_ma.count loop
      if a_kbt(b_lp) is not null then
        b_lenh:=FKH_JS_LENH('ma,nd');
        EXECUTE IMMEDIATE b_lenh bulk collect into kbt_ma,kbt_nd using a_kbt(b_lp);
        for b_lp1 in 1..kbt_ma.count loop
          -- neu ma  = KVU
          if kbt_ma(b_lp1) = 'KVU' then
            b_mkt:= FBH_MKT(kbt_nd(b_lp1),b_nt_tien);            
          end if;
        end loop;
      end if;
  end loop;
end if;
PKH_JS_THAY_D(dt_ct_goc,'mkt',b_mkt);

-- lay ttt
select count(*) into b_i1 from bh_hang_txt t WHERE  t.so_id = b_so_id_g and t.ma_dvi = b_ma_dvi AND t.loai='dt_ttt';
if b_i1 <> 0 then
  select FKH_JS_BONH(t.txt) into dt_ttt from bh_hang_txt t 
		WHERE  t.so_id = b_so_id_g and t.ma_dvi = b_ma_dvi AND t.loai='dt_ttt';
	b_lenh := FKH_JS_LENH('ma,nd');
	EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ttt_ma,a_ttt_nd USING dt_ttt;
	for b_lp in 1..a_ttt_ma.count loop
		select json_mergepatch(dt_ct_goc, json_object(a_ttt_ma(b_lp) value a_ttt_nd(b_lp) returning clob)) into dt_ct_goc from dual;
    select json_mergepatch(dt_ct_goc, json_object(a_ttt_ma(b_lp)|| '_E' value a_ttt_nd(b_lp) returning clob)) into dt_ct_goc from dual;
	end loop;
end if;

select json_object('dt_ct' value dt_ct,'dt_ct_goc' value dt_ct_goc returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
/
