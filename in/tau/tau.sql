create or replace procedure PBH_TAU_IN_B_GCN(
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
    b_i1 number := 0;
    dt_ct clob; dt_bs clob; dt_ds clob; dt_dk clob; dt_lt clob;dt_kbt clob; dt_ttt clob;
    b_kh_ttt clob;
    a_ttt_ma pht_type.a_var; a_ttt_nd pht_type.a_nvar;
    b_ten_dvi nvarchar2(500):= ' ';
    b_quy_tac nvarchar2(500):= ' ';b_ma_qtac varchar2(20);
    b_pt nvarchar2(500):= ' ';b_ma_pt varchar2(20);
    --
    b_dvi clob;
    b_temp NVARCHAR2(500):=' ';
    --bien mang dk
    a_dk_ma pht_type.a_var;a_dk_ten pht_type.a_nvar;a_dk_tien pht_type.a_num; a_dk_ptb pht_type.a_var;
    a_dk_phi pht_type.a_num;a_dk_nv pht_type.a_var;a_dk_cap pht_type.a_num;

    --bien mang kbt
    a_kbt_ma pht_type.a_var;a_kbt pht_type.a_clob;
    kbt_ma pht_type.a_var;kbt_nd pht_type.a_var;
    b_mkt nvarchar2(500):= ' ';b_qtac nvarchar2(500):= ' ';

    b_nt_tien varchar2(10):=' ';
    b_gia number:= 0 ;

    dt_bhtt clob; dt_t_ct clob; dt_t_ld clob; dt_n clob;

begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;

b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);

select count(*) into b_i1 from bh_taub_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ct' and lan = b_lan;
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ct FROM bh_taub_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ct' and lan = b_lan;
  --tt dvi
  select json_object('ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
          'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
              from ht_ma_dvi where ma=b_ma_dvi;
  dt_ct:=FKH_JS_BONH(dt_ct);
  b_dvi:=FKH_JS_BONH(b_dvi);
  select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;
  --ttt
  SELECT '{' || LISTAGG('"' || ma || '": ""', ',') WITHIN GROUP (ORDER BY ma) || '}' into b_kh_ttt
  FROM bh_kh_ttt
  WHERE nv = 'TAU' AND ps = 'HD';

  dt_ct:=FKH_JS_BONH(dt_ct);
  b_kh_ttt:=FKH_JS_BONH(b_kh_ttt);
  select json_mergepatch(dt_ct,b_kh_ttt) into dt_ct from dual;
  select count(*) into b_i1 from bh_taub_txt t WHERE t.so_id = b_so_id AND t.loai='dt_ttt' and lan = b_lan;
  if b_i1 <> 0 then
    SELECT FKH_JS_BONH(t.txt) INTO dt_ttt FROM bh_taub_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ttt' and lan = b_lan;
    if dt_ttt <> '""' then
      b_lenh := FKH_JS_LENH('ma,nd');
      EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ttt_ma,a_ttt_nd USING dt_ttt;
      for b_lp in 1..a_ttt_ma.count loop
            PKH_JS_THAYa(dt_ct,a_ttt_ma(b_lp),a_ttt_nd(b_lp));
      end loop;
      
    end if;
  end if;
  --vlieu
  b_temp:=' ';
  b_temp := FKH_JS_GTRIs(dt_ct,'vlieu');
  b_temp:= SUBSTR(b_temp, INSTR(b_temp, '|') + 1);
  PKH_JS_THAYa(dt_ct,'vlieu',b_temp);
  --loai
  b_temp:=' ';
  b_temp := FKH_JS_GTRIs(dt_ct,'loai');
  b_temp:= SUBSTR(b_temp, INSTR(b_temp, '|') + 1);
  PKH_JS_THAYa(dt_ct,'loai',b_temp);

  b_nt_tien := FKH_JS_GTRIs(dt_ct,'nt_tien');

  --loai
  b_gia := FKH_JS_GTRIn(dt_ct,'gia');
  PKH_JS_THAYa(dt_ct,'gia',FBH_CSO_TIEN(b_gia,b_nt_tien));

  PKH_JS_THAYa(dt_ct,'ten_tau',FKH_JS_GTRIs(dt_ct,'ten_tau') || '/' || FKH_JS_GTRIs(dt_ct,'so_dk'));
  PKH_JS_THAYa(dt_ct,'nam_sx',FKH_JS_GTRIs(dt_ct,'nam_sx') || '/' || FKH_JS_GTRIs(dt_ct,'nd'));
  PKH_JS_THAYa(dt_ct,'ttai',FKH_JS_GTRIs(dt_ct,'ttai') || '/' || FKH_JS_GTRIs(dt_ct,'so_cn'));
  PKH_JS_THAYa(dt_ct,'dtich',FKH_JS_GTRIs(dt_ct,'dtich') || '/' || FKH_JS_GTRIs(dt_ct,'csuat'));


end if;



--kbt
select count(*) into b_i1 from bh_taub_txt t WHERE t.so_id = b_so_id AND t.loai='dt_kbt' and lan = b_lan;
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_kbt FROM bh_taub_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_kbt' and lan = b_lan;
  if dt_kbt <> '""' then
     b_lenh := FKH_JS_LENH('ma,kbt');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_kbt_ma,a_kbt USING dt_kbt;
    delete temp_1;
    for b_lp in 1..a_kbt_ma.count loop
       if a_kbt(b_lp) is not null then
         b_lenh:=FKH_JS_LENH('ma,nd');
         EXECUTE IMMEDIATE b_lenh bulk collect into kbt_ma,kbt_nd using a_kbt(b_lp);
         b_mkt:=' ';
         for b_lp1 in 1..kbt_ma.count loop
            if trim(b_mkt) is not null then
              b_mkt:= b_mkt || ', ' || FBH_MKT(kbt_nd(b_lp1),b_nt_tien);
            else
              b_mkt:= FBH_MKT(kbt_nd(b_lp1),b_nt_tien);
            end if;
         end loop;
       end if;
       insert into temp_1(C1,C2) values(a_kbt_ma(b_lp), b_mkt);
    end loop;
  end if;
end if;

-- lay dt_dk
select count(*) into b_i1 from bh_taub_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_dk' and lan = b_lan;
if b_i1 <> 0 then
  select FKH_JS_BONH(t.txt) into dt_dk from bh_taub_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_dk' and lan = b_lan;
   b_lenh := FKH_JS_LENH('ma,ten,tien,ptb,phi,nv,cap');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_dk_ma,a_dk_ten,a_dk_tien,a_dk_ptb,a_dk_phi,a_dk_nv,a_dk_cap USING dt_dk;
  delete temp_2; delete temp_3; delete temp_4; delete temp_5;
  for b_lp in 1..a_dk_ma.count loop
      b_mkt:=' ';
      select count(1) into b_i1 from  temp_1 where C1 = a_dk_ma(b_lp);
      if b_i1 <> 0 then
        select C2 into b_mkt from temp_1 where C1 = a_dk_ma(b_lp);
      end if;

      if FBH_TONUM(a_dk_ptb(b_lp)) < 100 then
        b_temp := FBH_TO_CHAR(FBH_TONUM(a_dk_ptb(b_lp)));
      else
        b_temp:= FBH_CSO_TIEN(FBH_TONUM(a_dk_ptb(b_lp)), b_nt_tien);
      end if;


      if a_dk_cap(b_lp) = 1 and a_dk_nv(b_lp) = 'V' then-- vat chat
        --tien,ten,mkt,tlp,phi
        insert into temp_2(C1,C2,C3,C4,C5) values(FBH_CSO_TIEN(a_dk_tien(b_lp), b_nt_tien), a_dk_ten(b_lp),b_mkt, b_temp,FBH_CSO_TIEN(a_dk_phi(b_lp), b_nt_tien));
      elsif  a_dk_cap(b_lp) = 1 and a_dk_nv(b_lp) = 'T' and a_dk_ma(b_lp) IN('R01_0201','R01_0301') then -- TNDS chu tau
        insert into temp_3(C1,C2,C3,C4,C5) values(FBH_CSO_TIEN(a_dk_tien(b_lp), b_nt_tien), a_dk_ten(b_lp),b_mkt, b_temp,FBH_CSO_TIEN(a_dk_phi(b_lp), b_nt_tien));
      elsif  a_dk_cap(b_lp) = 1 and a_dk_nv(b_lp) = 'T' and a_dk_ma(b_lp) in('R01_0202')  then -- TNDS lai dat
        insert into temp_4(C1,C2,C3,C4,C5) values(FBH_CSO_TIEN(a_dk_tien(b_lp), b_nt_tien), a_dk_ten(b_lp),b_mkt, b_temp,FBH_CSO_TIEN(a_dk_phi(b_lp), b_nt_tien));
      elsif  a_dk_cap(b_lp) = 1 and a_dk_nv(b_lp) = 'N' then
        insert into temp_5(C1,C2,C3,C4,C5) values(FBH_CSO_TIEN(a_dk_tien(b_lp), b_nt_tien), a_dk_ten(b_lp),b_mkt, b_temp,FBH_CSO_TIEN(a_dk_phi(b_lp), b_nt_tien));
      end if;
  end loop;
end if;
--  dt_bhtt clob; dt_t_ct clob; dt_t_ld clob; dt_n clob;

select JSON_ARRAYAGG(json_object('tien' VALUE C1,'TEN' value C2, 'mkt' value C3, 'tlp' value C4,'phi' value C5) returning clob) 
  into dt_bhtt from temp_2;
select JSON_ARRAYAGG(json_object('tien' VALUE C1,'TEN' value C2, 'mkt' value C3, 'tlp' value C4,'phi' value C5) returning clob) 
  into dt_t_ct from temp_3;

select count(1) into b_i1 from temp_4;
if b_i1 <>0 then
  select JSON_ARRAYAGG(json_object('tien' VALUE C1,'TEN' value C2, 'mkt' value C3, 'tlp' value C4,'phi' value C5) returning clob) 
    into dt_t_ld from temp_4;
else
  b_temp := N'Không tham gia';
  select JSON_ARRAYAGG(json_object('tien' VALUE b_temp,'TEN' value b_temp, 'mkt' value b_temp, 'tlp' value b_temp,'phi' value b_temp) returning clob) 
    into dt_t_ld from temp_4;
end if;
select JSON_ARRAYAGG(json_object('tien' VALUE C1,'TEN' value C2, 'mkt' value C3, 'tlp' value C4,'phi' value C5) returning clob) 
  into dt_n from temp_5;
delete temp_2; delete temp_3; delete temp_4; delete temp_5;

select json_object('dt_ct' value dt_ct,'dt_dk' value dt_dk,'dt_bhtt' value dt_bhtt,'dt_t_ct' value dt_t_ct,'dt_t_ld' value dt_t_ld,'dt_n' value dt_n returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;

/
drop procedure PBH_TAU_IN_GCN;
/
create or replace procedure PBH_TAU_IN_GCN(
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
    b_i1 number := 0;b_i2 number:= 0;b_i3 number:= 0;
    dt_ct clob; dt_bs clob; dt_ds clob; dt_dk clob; dt_lt clob;dt_kbt clob; dt_ttt clob;dt_dong clob;dt_tt clob;
    b_dvi clob;dt_hu clob;
    b_ten_dvi nvarchar2(500):= ' ';
    b_quy_tac nvarchar2(500):= ' ';b_ma_qtac varchar2(20);
    b_pt nvarchar2(500):= ' ';b_ma_pt varchar2(20);
    b_dk clob;c_quy_tac clob;
    b_ma_temp varchar2(20);b_nd_temp clob;
    b_loai_tau nvarchar2(500):= ' ';b_vlieu_tau nvarchar2(500):= ' ';
    b_ngay_tt number;b_dkien_ten nvarchar2(500):= ' ';b_qtich_ten nvarchar2(500):= ' ';b_ten_sp nvarchar2(500):= ' ';
    b_cap_tau nvarchar2(500):= ' ';
    b_dk_ten nvarchar2(500):= ' ';
    b_bao_gom nvarchar2(500):= ' ';b_ten_ttt nvarchar2(500):= ' ';
    b_kbt_nd nvarchar2(500):= ' ';b_kh_ttt clob;
    b_tong_mtn number:= 0;
    
    b_ma_kvuc varchar2(20);
    b_ten_kvuc nvarchar2(500):= ' ';
    --bien mang
    a_ttt_ma pht_type.a_var; a_ttt_nd pht_type.a_nvar;
    
    a_dk_ma pht_type.a_var;a_dk_ten pht_type.a_nvar; a_dk_tien pht_type.a_num;a_dk_phi pht_type.a_num;a_dk_thue pht_type.a_num;
    a_dk_cap pht_type.a_num;a_dk_gvu pht_type.a_var;a_dk_ma_ct pht_type.a_var;a_dk_kieu pht_type.a_var;a_dk_nv pht_type.a_var;
    a_dk_lkeb pht_type.a_var;a_dk_lh_nv pht_type.a_var;
    b_ma_dk varchar2(20);b_cap number; b_nd nvarchar2(500):= ' ';
    --bien kbt
    a_kbt_ma_dk pht_type.a_var; a_kbt_kbt pht_type.a_nvar;
    a_kbt_nd pht_type.a_var; a_kbt_ma pht_type.a_nvar;
    b_nt_tien varchar2(50);
    b_temp_var varchar2(100);b_temp_nvar varchar2(500);
    --a_dt_hu
     a_hu_ten pht_type.a_nvar;a_hu_cmt pht_type.a_var; a_hu_mobi pht_type.a_var;a_hu_email pht_type.a_var;
    a_hu_dchi pht_type.a_nvar;a_hu_ng_ddien pht_type.a_nvar;a_hu_chucvu pht_type.a_nvar;
begin

b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
--bs
select count(*) into b_i1 from bh_tau_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_dkbs';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_bs FROM bh_tau_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_dkbs';
end if;

select count(*) into b_i1 from bh_tau_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ct
       FROM bh_tau_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ct';
    b_ma_temp := FKH_JS_GTRIs(dt_ct,'loai');
    select count(*) into b_i1 from bh_tau_loai where ma = b_ma_temp;
    if b_i1 <> 0 then
       select ten into b_loai_tau from bh_tau_loai where ma = b_ma_temp;
    end if;
    b_ma_temp := FKH_JS_GTRIs(dt_ct,'vlieu');
    select count(*) into b_i1 from bh_tau_vlieu where ma = b_ma_temp;
    if b_i1 <> 0 then
       select ten into b_vlieu_tau from bh_tau_vlieu where ma = b_ma_temp;
    end if;

    b_nt_tien:= FKH_JS_GTRIs(dt_ct,'nt_tien');

    --dieu kien
    b_ma_temp := FKH_JS_GTRIs(dt_ct,'dkien');
    select count(*) into b_i1 from bh_tau_dkc where ma = b_ma_temp;
    if b_i1 <> 0 then
       select ten into b_dkien_ten from bh_tau_dkc where ma = b_ma_temp;
    end if;
     --ten sp
    b_ma_temp := FKH_JS_GTRIs(dt_ct,'ma_sp');
    select count(*) into b_i1 from bh_tau_sp where ma = b_ma_temp;
    if b_i1 <> 0 then
       select ten into b_ten_sp from bh_tau_sp where ma = b_ma_temp;
    end if;
     --Quoc tich
    b_ma_temp := FKH_JS_GTRIs(dt_ct,'qtich');
    select count(*) into b_i1 from bh_ma_nuoc where ma = b_ma_temp;
    if b_i1 <> 0 then
       select ten into b_qtich_ten from bh_ma_nuoc where ma = b_ma_temp;
    end if;
      --cap tau
    b_ma_temp := FKH_JS_GTRIs(dt_ct,'cap');
    select count(*) into b_i1 from bh_tau_cap where ma = b_ma_temp;
    if b_i1 <> 0 then
       select ten into b_cap_tau from bh_tau_cap where ma = b_ma_temp;
    end if;
    
    --tt dvi
    select json_object('ten_gon' value  NVL(ten_gon,' '),'ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
           'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
               from ht_ma_dvi where ma=b_ma_dvi;
    dt_ct:=FKH_JS_BONH(dt_ct);
    b_dvi:=FKH_JS_BONH(b_dvi);
    select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;
    
    select kvuc into b_ma_kvuc from ht_ma_dvi where ma=b_ma_dvi;
    if trim(b_ma_kvuc) is not null then
      select count(1) into b_i1 from bh_ma_kvuc where ma = b_ma_kvuc;
      if b_i1 <> 0 then
         select ten into b_ten_kvuc from bh_ma_kvuc where ma = b_ma_kvuc;
      end if;
    end if;

    b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_hl');
    PKH_JS_THAYa(dt_ct,'gio_hl',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00') );
    b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_kt');
    PKH_JS_THAYa(dt_ct,'gio_kt',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00'));

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
    PKH_JS_THAY(dt_ct,'phi',FBH_CSO_TIEN(b_i1,'') );

    b_i1:= FKH_JS_GTRIn(dt_ct ,'gia');
    PKH_JS_THAY(dt_ct,'gia',FBH_CSO_TIEN(b_i1,b_nt_tien) );

    b_i1:= FKH_JS_GTRIn(dt_ct ,'thue');
    PKH_JS_THAY(dt_ct,'thue',FBH_CSO_TIEN(b_i1,'') );

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ttoan');
    PKH_JS_THAY(dt_ct,'ttoan',FBH_CSO_TIEN(b_i1,'') );
    

    PKH_JS_THAYa(dt_ct,'qdoi',b_nt_tien || '/' || FKH_JS_GTRIs(dt_ct ,'nt_phi'));

    if trim(FKH_JS_GTRIs(dt_ct ,'tenc')) is null THEN
        PKH_JS_THAY(dt_ct,'tenc',FKH_JS_GTRIs(dt_ct ,'ten') );
        PKH_JS_THAY(dt_ct,'dchic',FKH_JS_GTRIs(dt_ct ,'dchi') );
        PKH_JS_THAY(dt_ct,'mobic',FKH_JS_GTRIs(dt_ct ,'mobi') );
        PKH_JS_THAY(dt_ct,'cmtc',FKH_JS_GTRIs(dt_ct ,'cmt') );
    end if;

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ttai');
    if b_i1 = 0 then
      PKH_JS_THAY(dt_ct,'ttai',' ' );
    end if;
    b_i1:= FKH_JS_GTRIn(dt_ct ,'csuat');
    if b_i1 = 0 then
      PKH_JS_THAY(dt_ct,'csuat',' ' );
    end if;
    b_i1:= FKH_JS_GTRIn(dt_ct ,'so_cn');
    if b_i1 = 0 then
      PKH_JS_THAY(dt_ct,'so_cn',' ' );
    end if;
    b_i1:= FKH_JS_GTRIn(dt_ct ,'dtich');
    if b_i1 = 0 then
      PKH_JS_THAY(dt_ct,'dtich',' ' );
    end if;

    b_temp_var:= FKH_JS_GTRIs(dt_ct ,'qtich');
    if trim(b_temp_var) is not null then
      select count(*) into b_i1 from bh_ma_nuoc where ma = b_temp_var;
      if b_i1 <> 0 then 
        select ten into b_temp_nvar from bh_ma_nuoc where ma = b_temp_var;
        PKH_JS_THAY(dt_ct,'qtich',b_temp_nvar );
      end if;
    end if;

    b_temp_var:= FKH_JS_GTRIs(dt_ct ,'cap');
    if trim(b_temp_var) is not null then
      select count(*) into b_i1 from bh_tau_cap where ma = b_temp_var;
      if b_i1 <> 0 then 
        select ten into b_temp_nvar from bh_tau_cap where ma = b_temp_var;
        PKH_JS_THAY(dt_ct,'cap',b_temp_nvar );
      end if;
    end if;


end if;
PKH_JS_THAYa(dt_ct,'ngay_tt,qtich_ten,cap_tau',b_ngay_tt || ',' || b_qtich_ten || ',' || b_cap_tau);
PKH_JS_THAYa(dt_ct,'loai_tau,ten_vlieu',b_loai_tau || ',' || b_vlieu_tau);
PKH_JS_THAYa(dt_ct,'ten_sp',b_ten_sp);
PKH_JS_THAYa(dt_ct,'ten_kvuc',b_ten_kvuc);
PKH_JS_THAY(dt_ct,'dkien_ten',b_dkien_ten);

 SELECT '{' || LISTAGG('"' || ma || '": ""', ',') WITHIN GROUP (ORDER BY ma) || '}' into b_kh_ttt
    FROM bh_kh_ttt
    WHERE nv = 'TAU' AND ps = 'HD';

    dt_ct:=FKH_JS_BONH(dt_ct);
    b_kh_ttt:=FKH_JS_BONH(b_kh_ttt);
    select json_mergepatch(dt_ct,b_kh_ttt) into dt_ct from dual;
select tien into b_i1 from bh_tau where so_id = b_so_id and ma_dvi = b_ma_dvi;
PKH_JS_THAYa(dt_ct,'tien',FBH_CSO_TIEN(b_i1,b_nt_tien));


--dt_hu
PKH_JS_THAY_D(dt_ct,'nguoi_hu','X');
select count(*) into b_i1 from bh_tau_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_hu';
if b_i1 <> 0 then
  PKH_JS_THAY_D(dt_ct,'nguoi_hu',N'Người thụ hưởng:');

  SELECT FKH_JS_BONH(t.txt) INTO dt_hu FROM bh_tau_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_hu';
  b_lenh := FKH_JS_LENH('ten,cmt,mobi,email,dchi,ng_ddien,chucvu');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_hu_ten,a_hu_cmt,a_hu_mobi,a_hu_email,a_hu_dchi,a_hu_ng_ddien,a_hu_chucvu USING dt_hu;
  delete temp_2;commit;
  b_i1:= 1;
  for b_lp in 1..a_hu_ten.count loop
    if a_hu_ten.count > 1 then
      b_temp_nvar:= N'Người thụ hưởng thứ ' || Lower(FBH_IN_SO_CHU(b_lp));
    else
      b_temp_nvar:= N'Người thụ hưởng';
    end if;
    insert into temp_2(C1,c2,c3,c4,c5,c6,c7,c8) values(b_temp_nvar,a_hu_cmt(b_lp),a_hu_mobi(b_lp),a_hu_email(b_lp),a_hu_dchi(b_lp),a_hu_ng_ddien(b_lp),a_hu_chucvu(b_lp),a_hu_ten(b_lp));
    b_i1:= b_i1 +1;
  end loop;
  select JSON_ARRAYAGG(json_object('nguoi' VALUE C1,'cmt' VALUE C2,'mobi' VALUE C3,'email' VALUE C4,'dchi' VALUE C5,
  'ng_ddien' VALUE C6,'chucvu' VALUE C7, 'ten' value c8  returning clob) returning clob) into dt_hu from temp_2;

  delete temp_2;commit;
end if;

--ttt
select count(*) into b_i1 from bh_tau_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ttt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ttt FROM bh_tau_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ttt';
  if dt_ttt <> '""' then
    b_lenh := FKH_JS_LENH('ma,nd');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ttt_ma,a_ttt_nd USING dt_ttt;
     for b_lp in 1..a_ttt_ma.count loop
         if a_ttt_ma(b_lp) = 'PVHD' then
            select count(*) into b_i1 FROM bh_kh_ttt WHERE nv = 'TAU' AND ps = 'HD' and ma = a_ttt_ma(b_lp);
            if b_i1 <> 0 then
              select ten into b_ten_ttt FROM bh_kh_ttt WHERE nv = 'TAU' AND ps = 'HD' and ma = a_ttt_ma(b_lp);
              b_bao_gom:= b_bao_gom || ' ' || b_ten_ttt || ': ' || a_ttt_nd(b_lp) || '%;';
            end if;
          else
            PKH_JS_THAYa(dt_ct,a_ttt_ma(b_lp),a_ttt_nd(b_lp));
         end if;
     end loop;
    
  end if;
else
   PKH_JS_THAYa(dt_ct,'NDT',' ');
end if;
 PKH_JS_THAYa(dt_ct,'bao_gom',b_bao_gom);
-- lay dt_dk
select count(*) into b_i1 from bh_tau_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_dk';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_dk FROM bh_tau_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_dk';
  if dt_dk <> '""' then
    b_lenh := FKH_JS_LENH('ma,ten,tien,phi,thue,cap,gvu,ma_ct,kieu,nv,lkeb,lh_nv');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_dk_ma,a_dk_ten,a_dk_tien,a_dk_phi,a_dk_thue,a_dk_cap,a_dk_gvu,a_dk_ma_ct,a_dk_kieu,a_dk_nv,a_dk_lkeb,a_dk_lh_nv USING dt_dk;
    delete TEMP_4;
    b_i1:= 0;b_i2:= 0;b_i3:=0;
    for b_lp in 1..a_dk_ma.count loop
      b_cap:= a_dk_cap(b_lp);
      --kiem tra don co loai BH la vat chat khong b_i3 <> 0
      if a_dk_nv(b_lp) = 'V' then
        b_i3:= b_i3 +1;
        if trim(a_dk_lh_nv(b_lp)) is not null then
          b_tong_mtn:= b_tong_mtn + a_dk_tien(b_lp);
        end if;
      end if;
      --
      if b_cap = 1 then
          b_ma_dk := a_dk_ma(b_lp);
          if a_dk_tien(b_lp) <> 0 then
            if a_dk_nv(b_lp) = 'D' then
              if a_dk_lkeb(b_lp) = 'N' then
                b_nd:= trim(TO_CHAR(a_dk_tien(b_lp), '999,999,999,999,999,999PR'))|| ' ' || b_nt_tien || N'/hành khách';
              else
                b_nd:= trim(TO_CHAR(a_dk_tien(b_lp), '999,999,999,999,999,999PR'))|| ' ' || b_nt_tien || N'/vụ';
              end if;
            elsif a_dk_nv(b_lp) = 'N' then
              b_nd:= trim(TO_CHAR(a_dk_tien(b_lp), '999,999,999,999,999,999PR'))|| ' ' || b_nt_tien || N'/thuyền viên';
            else
              b_nd:= trim(TO_CHAR(a_dk_tien(b_lp), '999,999,999,999,999,999PR'))|| ' ' || b_nt_tien || N'/vụ';
            end if;
          else
            b_nd:=' ';
          end if;
          b_i1:= b_i1 + a_dk_phi(b_lp) ;
          b_i2:= b_i2 + a_dk_thue(b_lp) ;
          insert into TEMP_4(CL1,C1,C2,C3,c4,c5) values(a_dk_ten(b_lp),b_ma_dk,b_nd,FBH_CSO_TIEN(a_dk_tien(b_lp),'' ),FBH_CSO_TIEN(a_dk_phi(b_lp) ,'' ),FBH_CSO_TIEN(a_dk_thue(b_lp),''));
      else
          if trim(a_dk_gvu(b_lp)) is not null then
              b_nd:= b_nd || N', trong đó giới hạn về người: ' || a_dk_gvu(b_lp)|| ' ' || b_nt_tien || N'/người/vụ.';
          end if;
          if  b_nd =' ' and a_dk_tien(b_lp) <> 0 then
              if a_dk_nv(b_lp) = 'N' then
                b_temp_nvar:= N'/thuyền viên';
              elsif a_dk_nv(b_lp) = 'D' then
                b_temp_nvar:= N'/hành khách';
              end if;
              b_nd:= trim(TO_CHAR(a_dk_tien(b_lp), '999,999,999,999,999,999PR'))|| ' ' || b_nt_tien|| b_temp_nvar;
          end if;
          if a_dk_kieu(b_lp) = 'L' then
              if a_dk_nv(b_lp) = 'N' then
                b_nd:= b_nd || N'(' || a_dk_tien(b_lp) || N' thuyền viên).';
              elsif a_dk_nv(b_lp) = 'D' then
                b_nd:= b_nd || N'(' || a_dk_tien(b_lp) || N' hành khách).';
              end if;
              
          end if;

          update TEMP_4 set C2 = b_nd where C1 = b_ma_dk;
      end if;
      
      --khong lay cac dk co ma duoi
      --if SUBSTR(a_dk_ma(b_lp), 1, 3) <> 'KBT' then
        --insert into TEMP_4(CL1,N1,N2,N3) values(a_dk_ten(b_lp),a_dk_tien(b_lp),a_dk_phi(b_lp),a_dk_thue(b_lp));
      --end if;
    end loop;
    PKH_JS_THAY(dt_ct,'tong_phi',FBH_CSO_TIEN(b_i1,'' ));
    PKH_JS_THAY(dt_ct,'tong_thue',FBH_CSO_TIEN(b_i2,'' ));
  end if;
  if b_i3 = 0 then
    PKH_JS_THAY(dt_ct,'dkien_ten','X');
    PKH_JS_THAY(dt_ct,'gia','X');
    PKH_JS_THAY(dt_ct,'may','X');
  end if;

  PKH_JS_THAY_D(dt_ct,'tong_mtn',FBH_CSO_TIEN(b_tong_mtn,''));
  PKH_JS_THAYa(dt_ct,'bangchu',FBH_IN_CSO_CHU(b_tong_mtn,b_nt_tien) );

  select JSON_ARRAYAGG(json_object('ten' VALUE CL1,'nd' value C2, 'tien' value c3,'phi' value c4,'thue' value c5) returning clob) into dt_dk from TEMP_4;
  delete TEMP_4;
end if;
-- lay dt_lt
select count(*) into b_i1 from bh_tau_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_lt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_lt FROM bh_tau_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_lt';
end if;

-- lay dt_kbt
select count(*) into b_i1 from bh_tau_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_kbt';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_kbt FROM bh_tau_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_kbt';
  delete from TEMP_3;
  if dt_kbt <> '""' then
    b_lenh := FKH_JS_LENH('ma,kbt');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_kbt_ma_dk,a_kbt_kbt USING dt_kbt;
    for b_lp in 1..a_kbt_ma_dk.count loop
      select count(*) into b_i1 from bh_tau_dk where so_id = b_so_id and ma = a_kbt_ma_dk(b_lp);
      if b_i1 <> 0 then
         select ten into b_dk_ten from bh_tau_dk where so_id = b_so_id and ma = a_kbt_ma_dk(b_lp);
      end if;
      b_lenh := FKH_JS_LENH('ma,nd');
      EXECUTE IMMEDIATE b_lenh bulk collect INTO a_kbt_ma,a_kbt_nd USING a_kbt_kbt(b_lp);
      for b_lp2 in 1..a_kbt_ma.count loop
        if a_kbt_ma(b_lp2) = 'KVU' then
          b_kbt_nd:=FBH_MKT_TAU(a_kbt_nd(b_lp2),b_nt_tien);
        end if;
      end loop;
      insert into  TEMP_3(C1,C2) values(b_dk_ten,b_kbt_nd);
    end loop;
    select JSON_ARRAYAGG(json_object('TENDK' VALUE C1, 'KBT' value C2) returning clob) into dt_kbt from TEMP_3 group by C1,C2;
    delete from TEMP_3;
  end if;
end if;
-- lay quy tac
b_dk_ten:= ' ';
for r_lp in (select t2.ma,t2.txt from bh_tau_dk t1
left join bh_ma_dk t2 on t1.ma_dk = t2.ma
where t1.so_id = b_so_id and trim(t1.ma_dk) is not null and trim(t2.ma) is not null)
loop
    select txt,ten into b_dk,b_dk_ten from bh_ma_dk where ma = r_lp.ma;
    b_ma_qtac := FKH_JS_GTRIs(b_dk,'qtac');
    select count(*) into b_i1 from bh_ma_qtac WHERE ma=b_ma_qtac;
    if b_i1 <> 0 then
      select ten into b_quy_tac from bh_ma_qtac WHERE ma=b_ma_qtac;
      insert into TEMP_3(C1) values(b_quy_tac);
    end if;
end loop;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1) returning clob) into c_quy_tac from TEMP_3;
delete from TEMP_3;

--lay dt dong
delete temp_2;
PKH_JS_THAY(dt_ct,'dongbh','X');
select count(*) into b_i1 from BH_HD_DO_TL where so_id = b_so_id;
if b_i1 <> 0 then
  PKH_JS_THAY(dt_ct,'dongbh',N'Các nhà đồng bảo hiểm');
  b_i1:= 1;
  for r_lp in (select b.ten,a.pt from BH_HD_DO_TL a, BH_MA_NBH b where a.so_id = b_so_id and a.nha_bh=b.ma)
  loop
      insert into temp_2(C1,C2) values(r_lp.ten || N': Tỷ lệ ' || r_lp.pt || '%',r_lp.ten || N': Percentage ' || r_lp.pt || '%');
  end loop;
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1,'TENE' VALUE C2) returning clob) into dt_dong from temp_2;
delete temp_2;
--end dong
---thong tin thanh toan
delete temp_4;
select count(*) into b_i1 from bh_tau_tt where ma_dvi = b_ma_dvi and so_id = b_so_id;
PKH_JS_THAYa(dt_ct,'so_ky_tt',b_i1);
if  b_i1 = 1 then
    select min(ngay) into b_ngay_tt from bh_tau_tt where ma_dvi = b_ma_dvi and so_id = b_so_id;
    PKH_JS_THAY(dt_ct,'thoi_han_tt',N'Để đảm bảo hiệu lực bảo hiểm, phí bảo hiểm phải được thanh toán đầy đủ trước ngày '|| FBH_IN_CSO_NG(b_ngay_tt,'DD/MM/YYYY'));
elsif b_i1 > 1 then
    PKH_JS_THAY(dt_ct,'thoi_han_tt',N'Thời hạn thanh toán phí bảo hiểm:');
    b_i1:= 1;
    for r_lp in (select ngay,tien from bh_tau_tt where ma_dvi = b_ma_dvi and so_id = b_so_id order by ngay asc)
    loop
    insert into temp_4(C1) values(N'-   Kỳ ' || b_i1 || N': thanh toán ' || FBH_CSO_TIEN(r_lp.tien,FKH_JS_GTRIs(dt_ct,'nt_tien')) || N' trước ngày ' || FBH_IN_CSO_NG(r_lp.ngay,'DD/MM/YYYY'));
    b_i1:= b_i1 + 1;
    end loop;
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_tt from temp_4;
delete temp_4;



select json_object('dt_ct' value dt_ct,'dt_dk' value dt_dk,
'dt_qt' value c_quy_tac,'dt_bs' value dt_bs,'dt_kbt' value dt_kbt,
'dt_ttt' value dt_ttt,'dt_lt' value dt_lt,'dt_dong' value dt_dong,'dt_tt' value dt_tt,'dt_hu' value dt_hu returning clob) into b_oraOut from dual;


commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
---
/
drop procedure PBH_TAU_IN_GCN_HD;
/
create or replace procedure PBH_TAU_IN_GCN_HD(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    -- chung
    b_loi varchar2(100); b_lenh varchar2(1000);
    -- orain
    b_gcn varchar2(50) :=FKH_JS_GTRIs(b_oraIn,'gcn');
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number;b_so_id_dt number;
    b_bena_ten NVARCHAR2(100):=' ';b_bena_dchi NVARCHAR2(100):=' ';
    b_i1 number := 0;
  --ds
  ds_ct clob;ds_dk clob;ds_dkbs clob;ds_lt clob;ds_kbt clob;ds_ttt clob;
  --bien mang
    a_ds_ct pht_type.a_clob;a_ds_dk pht_type.a_clob;a_ds_dkbs pht_type.a_clob;a_ds_lt pht_type.a_clob;a_ds_kbt pht_type.a_clob;a_ds_ttt pht_type.a_clob;

    dt_ct clob;dt_bs clob; dt_ds clob; dt_dk clob; dt_lt clob;dt_kbt clob; dt_ttt clob;
    b_dvi clob;b_dk clob;c_quy_tac clob;

    b_ten_dvi nvarchar2(500):= ' ';
    b_quy_tac nvarchar2(500):= ' ';
    b_ma_qtac varchar2(20);
    b_pt nvarchar2(500):= ' ';
    b_ma_pt varchar2(20);
    b_ma_temp varchar2(20);
    b_loai_tau nvarchar2(500):= ' ';
    b_vlieu_tau nvarchar2(500):= ' ';
    b_ngay_tt number;
    b_dkien_ten nvarchar2(500):= ' ';
    b_qtich_ten nvarchar2(500):= ' ';
    b_ten_sp nvarchar2(500):= ' ';
    b_cap_tau nvarchar2(500):= ' ';
    b_dk_ten nvarchar2(500):= ' ';
    b_bao_gom nvarchar2(500):= ' ';b_ten_ttt nvarchar2(500):= ' ';
    b_kbt_nd nvarchar2(500):= ' ';b_kh_ttt clob;

    b_ma_kvuc varchar2(20);
    b_ten_kvuc nvarchar2(500):= ' ';
    --bien mang
    a_ttt_ma pht_type.a_var; a_ttt_nd pht_type.a_nvar;

    a_dk_ma pht_type.a_var;a_dk_ten pht_type.a_nvar; a_dk_tien pht_type.a_num;a_dk_phi pht_type.a_num;a_dk_thue pht_type.a_num;
    a_dk_cap pht_type.a_num;a_dk_gvu pht_type.a_var;a_dk_ma_ct pht_type.a_var;a_dk_kieu pht_type.a_var;
    b_ma_dk varchar2(20);b_cap number; b_nd nvarchar2(500):= ' ';
    --bien kbt
    a_kbt_ma_dk pht_type.a_var; a_kbt_kbt pht_type.a_nvar;
    a_kbt_nd pht_type.a_var; a_kbt_ma pht_type.a_nvar;

    a_gcn varchar2(50);b_nt_tien varchar2(50);b_nt_phi varchar2(50);
begin
-- tim so_id 
select so_id,so_id_dt into b_so_id,b_so_id_dt from bh_tau_ds where gcn = b_gcn and ma_dvi = b_ma_dvi;
select nt_tien, nt_phi into b_nt_tien,b_nt_phi from bh_tau where so_id = b_so_id and ma_dvi = b_ma_dvi;
-- lay thong tin txt: ds_ct ,ds_dk,ds_dkbs,ds_lt,ds_kbt,ds_ttt,
--ds_dk
select count(*) into b_i1 from bh_tau_txt t WHERE t.so_id = b_so_id AND t.loai='ds_ct' and ma_dvi = b_ma_dvi;
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO ds_ct FROM bh_tau_txt t WHERE t.so_id = b_so_id AND t.loai='ds_ct' and ma_dvi = b_ma_dvi;
  b_lenh:=FKH_JS_LENHc('');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_ct using ds_ct;
end if;
--ds_dk
select count(*) into b_i1 from bh_tau_txt t WHERE t.so_id = b_so_id AND t.loai='ds_dk' and ma_dvi = b_ma_dvi;
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO ds_dk FROM bh_tau_txt t WHERE t.so_id = b_so_id AND t.loai='ds_dk' and ma_dvi = b_ma_dvi;
  b_lenh:=FKH_JS_LENHc('');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_dk using ds_dk;
end if;
--ds_dkbs
select count(*) into b_i1 from bh_tau_txt t WHERE t.so_id = b_so_id AND t.loai='ds_dkbs' and ma_dvi = b_ma_dvi;
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO ds_dkbs FROM bh_tau_txt t WHERE t.so_id = b_so_id AND t.loai='ds_dkbs' and ma_dvi = b_ma_dvi;
  b_lenh:=FKH_JS_LENHc('');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_dkbs using ds_dkbs;
end if;
--ds_lt
select count(*) into b_i1 from bh_tau_txt t WHERE t.so_id = b_so_id AND t.loai='ds_lt' and ma_dvi = b_ma_dvi;
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO ds_lt FROM bh_tau_txt t WHERE t.so_id = b_so_id AND t.loai='ds_lt' and ma_dvi = b_ma_dvi;
  b_lenh:=FKH_JS_LENHc('');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_lt using ds_lt;
end if;
--ds_kbt
select count(*) into b_i1 from bh_tau_txt t WHERE t.so_id = b_so_id AND t.loai='ds_kbt' and ma_dvi = b_ma_dvi;
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO ds_kbt FROM bh_tau_txt t WHERE t.so_id = b_so_id AND t.loai='ds_kbt' and ma_dvi = b_ma_dvi;
  b_lenh:=FKH_JS_LENHc('');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_kbt using ds_kbt;
end if;
--ds_ttt
select count(*) into b_i1 from bh_tau_txt t WHERE t.so_id = b_so_id AND t.loai='ds_ttt' and ma_dvi = b_ma_dvi;
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO ds_ttt FROM bh_tau_txt t WHERE t.so_id = b_so_id AND t.loai='ds_ttt' and ma_dvi = b_ma_dvi;
  b_lenh:=FKH_JS_LENHc('');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_ttt using ds_ttt;
end if;
--------

for ds_lp in 1..a_ds_ct.count loop
  b_lenh:=FKH_JS_LENH('gcn');
  EXECUTE IMMEDIATE b_lenh into a_gcn using a_ds_ct(ds_lp);
  if a_gcn = b_gcn then
   dt_ct := a_ds_ct(ds_lp);
   b_i1:= ds_lp;
  end if;
end loop;
for ds_lp in 1..a_ds_dk.count loop
  if ds_lp = b_i1 then
    dt_dk:=  a_ds_dk(b_i1);
  end if;
end loop;
for ds_lp in 1..a_ds_dkbs.count loop
  if ds_lp = b_i1 then
  dt_bs:=  a_ds_dkbs(b_i1);
  end if;
end loop;
for ds_lp in 1..a_ds_lt.count loop
  if ds_lp = b_i1 then
    dt_lt:=  a_ds_lt(b_i1);
  end if;
end loop;
for ds_lp in 1..a_ds_kbt.count loop
  if ds_lp = b_i1 then
    dt_kbt:=  a_ds_kbt(b_i1);
  end if;
end loop;
for ds_lp in 1..a_ds_ttt.count loop
  if ds_lp = b_i1 then
    ds_ttt:=  a_ds_ttt(b_i1);
  end if;
end loop;

b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
--bs


if dt_ct <> '""' then

    b_ma_temp := FKH_JS_GTRIs(dt_ct,'loai');
    select count(*) into b_i1 from bh_tau_loai where ma = b_ma_temp;
    if b_i1 <> 0 then
       select ten into b_loai_tau from bh_tau_loai where ma = b_ma_temp;
    end if;
    b_ma_temp := FKH_JS_GTRIs(dt_ct,'vlieu');
    select count(*) into b_i1 from bh_tau_vlieu where ma = b_ma_temp;
    if b_i1 <> 0 then
       select ten into b_vlieu_tau from bh_tau_vlieu where ma = b_ma_temp;
    end if;

    --dieu kien
    b_ma_temp := FKH_JS_GTRIs(dt_ct,'dkien');
    select count(*) into b_i1 from bh_tau_dkc where ma = b_ma_temp;
    if b_i1 <> 0 then
       select ten into b_dkien_ten from bh_tau_dkc where ma = b_ma_temp;
    end if;
     --ten sp
    b_ma_temp := FKH_JS_GTRIs(dt_ct,'ma_sp');
    select count(*) into b_i1 from bh_tau_sp where ma = b_ma_temp;
    if b_i1 <> 0 then
       select ten into b_ten_sp from bh_tau_sp where ma = b_ma_temp;
    end if;
     --Quoc tich
    b_ma_temp := FKH_JS_GTRIs(dt_ct,'qtich');
    select count(*) into b_i1 from bh_ma_nuoc where ma = b_ma_temp;
    if b_i1 <> 0 then
       select ten into b_qtich_ten from bh_ma_nuoc where ma = b_ma_temp;
    end if;
      --cap tau
    b_ma_temp := FKH_JS_GTRIs(dt_ct,'cap');
    select count(*) into b_i1 from bh_tau_cap where ma = b_ma_temp;
    if b_i1 <> 0 then
       select ten into b_cap_tau from bh_tau_cap where ma = b_ma_temp;
    end if;
    -- ngay tt
    select ngay into b_ngay_tt from bh_tau_tt where so_id = b_so_id;
    --tt dvi
    select json_object('ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
           'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
               from ht_ma_dvi where ma=b_ma_dvi;
    dt_ct:=FKH_JS_BONH(dt_ct);
    b_dvi:=FKH_JS_BONH(b_dvi);
    select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;

    select kvuc into b_ma_kvuc from ht_ma_dvi where ma=b_ma_dvi;
    if trim(b_ma_kvuc) is not null then
      select ten into b_ten_kvuc from bh_ma_kvuc where ma = b_ma_kvuc;
    end if;

end if;
PKH_JS_THAYa(dt_ct,'ngay_tt,dkien_ten,qtich_ten,cap_tau',b_ngay_tt || ',' || b_dkien_ten || ',' || b_qtich_ten || ',' || b_cap_tau);
PKH_JS_THAYa(dt_ct,'loai_tau,ten_vlieu',b_loai_tau || ',' || b_vlieu_tau);
PKH_JS_THAYa(dt_ct,'ten_sp',b_ten_sp);
PKH_JS_THAYa(dt_ct,'ten_kvuc',b_ten_kvuc);
PKH_JS_THAYa(dt_ct,'nt_tien',b_nt_tien);
PKH_JS_THAYa(dt_ct,'nt_phi',b_nt_phi);


 SELECT '{' || LISTAGG('"' || ma || '": ""', ',') WITHIN GROUP (ORDER BY ma) || '}' into b_kh_ttt
    FROM bh_kh_ttt
    WHERE nv = 'TAU' AND ps = 'HD';

    dt_ct:=FKH_JS_BONH(dt_ct);
    b_kh_ttt:=FKH_JS_BONH(b_kh_ttt);
    select json_mergepatch(dt_ct,b_kh_ttt) into dt_ct from dual;

--ttt
if dt_ttt <> '""' then
    b_lenh := FKH_JS_LENH('ma,nd');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_ttt_ma,a_ttt_nd USING dt_ttt;
     for b_lp in 1..a_ttt_ma.count loop
         if a_ttt_ma(b_lp) = 'NDT' then
           PKH_JS_THAYa(dt_ct,a_ttt_ma(b_lp),a_ttt_nd(b_lp));
         elsif a_ttt_ma(b_lp) <> 'PVHD' then
           select ten into b_ten_ttt FROM bh_kh_ttt WHERE nv = 'TAU' AND ps = 'HD' and ma = a_ttt_ma(b_lp);
           b_bao_gom:= b_bao_gom || ' ' || b_ten_ttt || ': ' || a_ttt_nd(b_lp) || '%;';
         end if;
     end loop;
else
   PKH_JS_THAYa(dt_ct,'NDT',' ');
end if;
 PKH_JS_THAYa(dt_ct,'bao_gom',b_bao_gom);
-- lay dt_dk
  if dt_dk <> '""' then
    b_lenh := FKH_JS_LENH('ma,ten,tien,phi,thue,cap,gvu,ma_ct,kieu');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_dk_ma,a_dk_ten,a_dk_tien,a_dk_phi,a_dk_thue,a_dk_cap,a_dk_gvu,a_dk_ma_ct,a_dk_kieu USING dt_dk;
    delete TEMP_4;
    for b_lp in 1..a_dk_ma.count loop
      b_cap:= a_dk_cap(b_lp);
      if b_cap = 1 then
          b_ma_dk := a_dk_ma(b_lp);
          if a_dk_tien(b_lp) <> 0 then
            b_nd:= trim(TO_CHAR(a_dk_tien(b_lp), '999,999,999,999,999,999PR')) || ' ' || b_nt_tien || N'/vụ';
          else
            b_nd:=' ';
          end if;
          insert into TEMP_4(CL1,C1,C2,N1,N2,N3) values(a_dk_ten(b_lp),b_ma_dk,b_nd,a_dk_tien(b_lp),a_dk_phi(b_lp),a_dk_thue(b_lp));
      else
          if trim(a_dk_gvu(b_lp)) is not null then
              b_nd:= b_nd || N', trong đó giới hạn về người: ' || a_dk_gvu(b_lp)|| ' ' || b_nt_tien || N'/người/vụ.';
          end if;
          if  b_nd =' ' and a_dk_tien(b_lp) <> 0 then
              b_nd:= trim(TO_CHAR(a_dk_tien(b_lp), '999,999,999,999,999,999PR'))|| ' ' || b_nt_tien|| N'/thuyền viên';
          end if;
          if a_dk_kieu(b_lp) = 'L' then
               b_nd:= b_nd || N'(' || a_dk_tien(b_lp) || N' thuyền viên).';
          end if;

          update TEMP_4 set C2 = b_nd where C1 = b_ma_dk;
      end if;

    end loop;
  end if;
  select JSON_ARRAYAGG(json_object('ten' VALUE CL1,'nd' value C2, 'tien' value N1,'phi' value N2,'thue' value N3) returning clob) into dt_dk from TEMP_4;
  delete TEMP_4;

-- lay dt_kbt
  delete from TEMP_3;
  if dt_kbt <> '""' then
    b_lenh := FKH_JS_LENH('ma,kbt');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_kbt_ma_dk,a_kbt_kbt USING dt_kbt;
    for b_lp in 1..a_kbt_ma_dk.count loop
      select count(*) into b_i1 from bh_tau_dk where so_id = b_so_id and so_id_dt = b_so_id_dt and ma = a_kbt_ma_dk(b_lp);
      if b_i1 <> 0 then
         select ten into b_dk_ten from bh_tau_dk where so_id = b_so_id and so_id_dt = b_so_id_dt and ma = a_kbt_ma_dk(b_lp);
      end if;
      b_lenh := FKH_JS_LENH('ma,nd');
      EXECUTE IMMEDIATE b_lenh bulk collect INTO a_kbt_ma,a_kbt_nd USING a_kbt_kbt(b_lp);
      for b_lp2 in 1..a_kbt_ma.count loop
        if a_kbt_ma(b_lp2) = 'KVU' then
          b_kbt_nd:= a_kbt_nd(b_lp2);
          if REGEXP_SUBSTR(b_kbt_nd, '[^|]+', 1, 2) is not null then
            b_kbt_nd:= REGEXP_SUBSTR(b_kbt_nd, '[^|]+', 1, 1) || unistr('\0025\0020\0073\1ED1\0020\0074\0069\1EC1\006E\0020\0062\1ED3\0069\0020\0074\0068\01B0\1EDD\006E\0067\002F\0020\0076\1EE5\0020\0074\1ED5\006E\0020\0074\0068\1EA5\0074\002C\0020\0074\1ED1\0069\0020\0074\0068\0069\1EC3\0075') ||' '|| REGEXP_SUBSTR(b_kbt_nd, '[^|]+', 1, 2) || unistr('\0020\0110\1ED3\006E\0067\002F\0020\0076\1EE5\002E');
          else
            b_kbt_nd:= REGEXP_SUBSTR(b_kbt_nd, '[^|]+', 1, 1) || unistr('\0025\0020\0073\1ED1\0020\0074\0069\1EC1\006E\0020\0062\1ED3\0069\0020\0074\0068\01B0\1EDD\006E\0067\002F\0020\0076\1EE5\0020\0074\1ED5\006E\0020\0074\0068\1EA5\0074');
          end if;
        end if;
      end loop;
      insert into  TEMP_3(C1,C2) values(b_dk_ten,b_kbt_nd);
    end loop;
    select JSON_ARRAYAGG(json_object('TENDK' VALUE C1, 'KBT' value C2) returning clob) into dt_kbt from TEMP_3 group by C1,C2;
    delete from TEMP_3;
  end if;

-- lay quy tac
b_dk_ten:= ' ';
for r_lp in (select t2.ma,t2.txt from bh_tau_dk t1
left join bh_ma_dk t2 on t1.ma_dk = t2.ma
where t1.so_id = b_so_id and t1.so_id_dt = b_so_id_dt and trim(t1.ma_dk) is not null and trim(t2.ma) is not null)
loop
    select txt,ten into b_dk,b_dk_ten from bh_ma_dk where ma = r_lp.ma;
    b_ma_qtac := FKH_JS_GTRIs(b_dk,'qtac');
    select count(*) into b_i1 from bh_ma_qtac WHERE ma=b_ma_qtac;
    if b_i1 <> 0 then
      select ten into b_quy_tac from bh_ma_qtac WHERE ma=b_ma_qtac;
      insert into TEMP_3(C1) values(b_dk_ten || '-' ||b_quy_tac);
    else
      insert into TEMP_3(C1) values(b_dk_ten);
    end if;

end loop;

select JSON_ARRAYAGG(json_object('TEN' VALUE C1) returning clob) into c_quy_tac from TEMP_3;

select json_object('dt_ct' value dt_ct,'dt_dk' value dt_dk,
'dt_qt' value c_quy_tac,'dt_bs' value dt_bs,'dt_kbt' value dt_kbt,
'dt_ttt' value dt_ttt,'dt_lt' value dt_lt returning clob) into b_oraOut from dual;

delete from TEMP_3;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
