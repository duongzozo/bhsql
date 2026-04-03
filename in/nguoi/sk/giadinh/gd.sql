create or replace procedure PBH_SKGD_INGCN(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    -- chung
    b_loi varchar2(100); b_lenh varchar2(1000);b_i1 number;
    -- orain
    b_gcn varchar2(50) :=FKH_JS_GTRIs(b_oraIn,'gcn');
    b_so_hd varchar2(50) :=FKH_JS_GTRIs(b_oraIn,'so_hd');
    b_ma_dvi varchar2(10):= FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number;b_so_id_dt number;
    dt_ct clob;dt_bs clob; dt_dk clob; dt_lt clob;dt_kbt clob; dt_ttt clob;dt_dong clob;dt_tt clob;
    dt_hu clob;dt_qt clob;
    dt_ds clob; dt_dt_ds clob;dk_qtac clob;b_dvi clob;b_gd clob;
    -- khac
    b_count  NUMBER;
    b_nghe varchar2(20);b_nghe_ten nvarchar2(500):= ' ';
    b_qtac nvarchar2(500):=' ';b_ma_qtac varchar2(20);
    b_ten_goi nvarchar2(500):=' ';
    b_tpa_ma varchar2(20);
    --bien mang
    dt_ds_dk pht_type.a_clob;dt_ds_dkbs pht_type.a_clob;dt_ds_lt pht_type.a_clob;dt_ds_ct pht_type.a_clob;
    ds_dk clob;ds_dkbs clob;ds_lt clob;ds_ct clob;

    a_so_id_dt pht_type.a_num;a_gcn varchar2(50);
    b_index number;
    --ten sp
    b_ma_sp varchar(20);b_ten_sp nvarchar2(500):= ' ';
    b_mtn number:=0;dk_tien pht_type.a_num;dk_cap pht_type.a_num;dk_ma_dk pht_type.a_var;
    -- ngay tt
    b_ngay_tt number;
    --
    ma_lt pht_type.a_var;b_nd_lt clob;

    b_temp_var varchar2(100);b_temp_nvar varchar2(500);
    b_nt_tien varchar2(50);
    ---kbt
    a_kbt_ma_dk pht_type.a_var; a_kbt_kbt pht_type.a_nvar;
    a_kbt_nd pht_type.a_var; a_kbt_ma pht_type.a_nvar;

    --a dt_dk
    a_dk_ma pht_type.a_var;a_dk_ten pht_type.a_nvar; a_dk_tien pht_type.a_num;a_dk_phi pht_type.a_num;
    a_dk_cap pht_type.a_num;a_dk_kieu pht_type.a_var;a_dk_lkeb pht_type.a_var;

begin

select so_id into b_so_id from bh_sk where so_hd = b_so_hd and ma_dvi = b_ma_dvi;
-- dt_ds
select count(*) into b_i1 from bh_sk_txt t where t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_ds';
if b_i1 <> 0 then
    select FKH_JS_BONH(txt) into dt_ds from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';

    b_lenh:=FKH_JS_LENHc('dt_ds_ct');
    EXECUTE IMMEDIATE b_lenh bulk collect into dt_ds_ct using dt_ds;

    b_lenh:=FKH_JS_LENHc('dt_ds_dk');
    EXECUTE IMMEDIATE b_lenh bulk collect into dt_ds_dk using dt_ds;

    b_lenh:=FKH_JS_LENHc('dt_ds_dkbs');
    EXECUTE IMMEDIATE b_lenh bulk collect into dt_ds_dkbs using dt_ds;

    b_lenh:=FKH_JS_LENHc('dt_ds_lt');
    EXECUTE IMMEDIATE b_lenh bulk collect into dt_ds_lt using dt_ds;

    for ds_lp in 1..dt_ds_ct.count loop
      b_lenh:=FKH_JS_LENH('gcn');
      EXECUTE IMMEDIATE b_lenh into a_gcn using dt_ds_ct(ds_lp);
      if a_gcn = b_gcn then
         dt_dk := dt_ds_dk(ds_lp);
         dt_bs := dt_ds_dkbs(ds_lp);
         dt_lt := dt_ds_lt(ds_lp);
         ds_ct := dt_ds_ct(ds_lp);
         
      end if;
    end loop;

end if;
b_so_id_dt:= FKH_JS_GTRIn(ds_ct,'so_id_dt');
-- dt_ct
select count(*) into b_i1 from bh_sk_txt t where t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_ct';
if b_i1 <> 0 then
    select FKH_JS_BONH(txt) into dt_ct from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    b_nt_tien:=FKH_JS_GTRIs(dt_ct ,'nt_tien');

    b_temp_var:=FKH_JS_GTRIs(ds_ct ,'gio_hl');
    PKH_JS_THAYa(dt_ct,'gio_hl',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00') );
    b_temp_var:=FKH_JS_GTRIs(ds_ct ,'gio_kt');
    PKH_JS_THAYa(dt_ct,'gio_kt',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || N' giờ ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00'));
    ---
    b_i1:= FKH_JS_GTRIn(ds_ct ,'ngay_cap');
    if b_i1 = 30000101 or b_i1 = 0 then PKH_JS_THAYa(dt_ct,'ngay_cap',' '); 
    else 
      PKH_JS_THAYa(dt_ct,'ngay_cap',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );
      PKH_JS_THAYa(dt_ct,'ngay_cap_s',N'Ngày ' || FBH_IN_CSO_NG(b_i1,'DD') || N' tháng ' || FBH_IN_CSO_NG(b_i1,'MM')
    || N' năm ' || FBH_IN_CSO_NG(b_i1,'YYYY'));
    end if;

    
    
    b_i1:= FKH_JS_GTRIn(ds_ct ,'ngay_hl');
    if b_i1 = 30000101 or b_i1 = 0 then PKH_JS_THAYa(dt_ct,'ngay_hl',' '); 
    else PKH_JS_THAYa(dt_ct,'ngay_hl',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    b_i1:= FKH_JS_GTRIn(ds_ct ,'ngay_kt');
    if b_i1 = 30000101 or b_i1 = 0 then PKH_JS_THAYa(dt_ct,'ngay_kt',' '); 
    else PKH_JS_THAYa(dt_ct,'ngay_kt',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    b_i1:= FKH_JS_GTRIn(ds_ct ,'phi');
    PKH_JS_THAY(dt_ct,'ttoan',FBH_CSO_TIEN(b_i1,b_nt_tien) );
    PKH_JS_THAYa(dt_ct,'bangchu',FBH_IN_CSO_CHU(b_i1,b_nt_tien) );

    b_temp_var:= FKH_JS_GTRIs(ds_ct ,'gioi');
    if b_temp_var= 'M' and trim(b_temp_var) is not null then PKH_JS_THAY(dt_ct,'gioi', 'Nam');
    else PKH_JS_THAY(dt_ct,'gioi', N'Nữ');end if;

    b_temp_var:= FKH_JS_GTRIs(ds_ct ,'gioid');
    if b_temp_var= 'M' and trim(b_temp_var) is not null then PKH_JS_THAY(dt_ct,'gioid', 'Nam');
    else PKH_JS_THAY(dt_ct,'gioid', N'Nữ');end if;

    b_i1:= FKH_JS_GTRIn(ds_ct ,'ng_sinh');
    if b_i1 = 30000101 or b_i1 = 0 then PKH_JS_THAYa(dt_ct,'ng_sinh',' '); 
    else PKH_JS_THAYa(dt_ct,'ng_sinh',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    b_i1:= FKH_JS_GTRIn(ds_ct ,'ng_sinhd');
    if b_i1 = 30000101 or b_i1 = 0 then PKH_JS_THAYa(dt_ct,'ng_sinhd',' '); 
    else PKH_JS_THAYa(dt_ct,'ng_sinhd',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;
end if;
--ten sp
select ma_sp into b_ma_sp from bh_sk  where so_id = b_so_id and ma_dvi=b_ma_dvi;
if trim(b_ma_sp) is not null then
  select count(*) into b_i1 from bh_sk_sp where ma_dvi=b_ma_dvi and ma = b_ma_sp;
  if b_i1 <> 0 then
     select UPPER(ten) into b_ten_sp from bh_sk_sp where ma_dvi=b_ma_dvi and ma = b_ma_sp;
  end if;
end if;
PKH_JS_THAYa(dt_ct,'ten_sp',b_ten_sp);
-- lay qtac
SELECT FKH_JS_BONH(t.txt) into dk_qtac FROM bh_sk_sp t, bh_sk t1 WHERE t.ma = t1.ma_sp and t1.so_id=b_so_id;
if dk_qtac is not null or dk_qtac!= '' then
  b_lenh := FKH_JS_LENH('qtac');
  EXECUTE IMMEDIATE b_lenh INTO b_ma_qtac USING dk_qtac;
end if;
IF b_ma_qtac IS NOT NULL THEN
  SELECT t.TEN into b_qtac FROM bh_ma_qtac t WHERE t.ma=b_ma_qtac;
END IF;

PKH_JS_THAYa(dt_ct,'qtac',b_qtac);
--ten goi
select count(1) into b_i1 from bh_sk_ds t
inner join bh_sk_goi t1 on t.goi = t1.ma
where t.so_id = b_so_id and t.so_id_dt = b_so_id_dt;

if b_i1 <> 0 then
  select t1.ten into b_ten_goi from bh_sk_ds t
  inner join bh_sk_goi t1 on t.goi = t1.ma
  where t.so_id = b_so_id and t.so_id_dt = b_so_id_dt;
end if;
PKH_JS_THAYa(dt_ct,'ten_goi',b_ten_goi);
-- thong tin dvi
select json_object('ten_dvi' value NVL(UPPER(ten),' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
           'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
               from ht_ma_dvi where ma=b_ma_dvi;
    dt_ct:=FKH_JS_BONH(dt_ct);
    b_dvi:=FKH_JS_BONH(b_dvi);
    select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;
-- thong tin gd
b_tpa_ma:= FKH_JS_GTRIs(dt_ct,'tpa');
  if trim(b_tpa_ma) is not null then
    select count(*) into b_count  from bh_ma_gdinh where ma=b_tpa_ma;
    if b_count <> 0 then
      select json_object('dv_ten' value NVL(UPPER(ten),' '),'dv_dchi' value NVL(dchi,' '),'dv_mobi' value NVL(mobi,' '),
           'dv_email' value NVL(email,' ') returning clob) into b_gd
               from bh_ma_gdinh where ma=b_tpa_ma;
      dt_ct:=FKH_JS_BONH(dt_ct);
      b_gd:=FKH_JS_BONH(b_gd);
      select json_mergepatch(dt_ct,b_gd) into dt_ct from dual;
    end if;
  end if;

select json_object(ma_dvi,so_id,so_id_dt,bt,kieu_gcn,gcn,gcn_g,ten,ng_sinh,gioi,cmt,
  mobi,email,dchi,nghe,ng_huong,gio_hl,ngay_hl,gio_kt,ngay_kt,ngay_cap,goi,so_idp,nhom,phi,giam,ttoan,dvi,ma_kh returning clob)
  into dt_dt_ds FROM bh_sk_ds where so_id = b_so_id and so_id_dt = b_so_id_dt;

b_nghe:= FKH_JS_GTRIs(dt_dt_ds,'nghe');
if trim(b_nghe) is not null then
  select count(*) into b_count  from bh_ma_nghe where ma=b_nghe;
  if b_count <> 0 then
    select NVL(ten,' ') into b_nghe_ten  from bh_ma_nghe where ma=b_nghe;

  end if;
end if;
PKH_JS_THAY(dt_dt_ds,'nghe_ten',b_nghe_ten);

--tinh mtn, quy tac
b_lenh:=FKH_JS_LENH('tien,cap,ma_dk');
EXECUTE IMMEDIATE b_lenh bulk collect into dk_tien,dk_cap,dk_ma_dk using dt_dk;
for b_lp in 1..dk_tien.count loop
   if dk_cap(b_lp) = 1 then
     b_mtn:=b_mtn+dk_tien(b_lp);
   end if;
end loop;
PKH_JS_THAY(dt_dt_ds,'mtn',b_mtn);
--dt_bs
if dt_bs <> '""' then
  b_lenh := FKH_JS_LENH('ma,ten,tien,phi,cap,kieu,lkeb');
  EXECUTE IMMEDIATE b_lenh bulk collect INTO a_dk_ma,a_dk_ten,a_dk_tien,a_dk_phi,a_dk_cap,a_dk_kieu,a_dk_lkeb USING dt_bs;
  delete temp_1;commit;
  for b_lp in 1..a_dk_ma.count loop
      b_temp_var:= case when a_dk_tien(b_lp) <> 0 then  FBH_CSO_TIEN(a_dk_tien(b_lp),b_nt_tien) else ' ' end;
      insert into temp_1(c1,c2,c3,c4,c5) values(a_dk_ma(b_lp),a_dk_ten(b_lp),b_temp_var,a_dk_kieu(b_lp),a_dk_cap(b_lp));
  end loop;
  select JSON_ARRAYAGG(json_object('ma' VALUE rownum,'ten' value c2, 'tien' value c3,'gioi_han' value c4,'cap' value c5 returning clob) returning clob) into dt_bs from temp_1;
end if;
-- lay dt_dk
if dt_dk <> '""' then
    b_lenh := FKH_JS_LENH('ma,ten,tien,phi,cap,kieu,lkeb');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_dk_ma,a_dk_ten,a_dk_tien,a_dk_phi,a_dk_cap,a_dk_kieu,a_dk_lkeb USING dt_dk;
    delete temp_1;delete temp_2;commit;
    for b_lp in 1..a_dk_ma.count loop
        if a_dk_cap(b_lp) > 1 then
          if a_dk_cap(b_lp) > 2 then a_dk_ma(b_lp):= ' '; end if;
          if a_dk_kieu(b_lp) = 'N' then
            if  a_dk_tien(b_lp) < 1000 then
              a_dk_kieu(b_lp):= N'Giới hạn/năm'; 
            else
              a_dk_kieu(b_lp):= N'Giới hạn/ngày'; 
            end if;
          elsif a_dk_kieu(b_lp) = 'L' then
            a_dk_kieu(b_lp):= N'Giới hạn/lần'; 
          elsif a_dk_kieu(b_lp) = 'T' then
            a_dk_kieu(b_lp):= N'Giới hạn/năm'; 
          end if;
          b_temp_var:= case when a_dk_tien(b_lp) < 1000 then to_char(a_dk_tien(b_lp)) else FBH_CSO_TIEN(a_dk_tien(b_lp),b_nt_tien) end;
          if a_dk_lkeb(b_lp) = 'B' then b_temp_var:= N'Theo Bảng tỉ lệ thương tật';
          elsif a_dk_lkeb(b_lp) = 'P' then b_temp_var:= N'Theo Bảng tỉ lệ phẫu thuật';end if;
          if  INSTR(a_dk_ma(b_lp), 'BS') <> 0 then
            insert into temp_2(c1,c2,c3,c4,c5) values(a_dk_ma(b_lp),a_dk_ten(b_lp),b_temp_var,a_dk_kieu(b_lp),a_dk_cap(b_lp));
            if a_dk_ma(b_lp) in ('BS1','BS2','BS3') then
                PKH_JS_THAY(dt_ct,a_dk_ma(b_lp),'X');
            end if;
          else
            insert into temp_1(c1,c2,c3,c4,c5) values(a_dk_ma(b_lp),a_dk_ten(b_lp),b_temp_var,a_dk_kieu(b_lp),a_dk_cap(b_lp));
          end if;
        end if;
    end loop;
    select JSON_ARRAYAGG(json_object('ma' VALUE rownum,'ten' value c2, 'tien' value c3,'gioi_han' value c4,'cap' value c5 returning clob) returning clob) into dt_dk from temp_1;
    select JSON_ARRAYAGG(json_object('ma' VALUE rownum,'ten' value c2, 'tien' value c3,'gioi_han' value c4,'cap' value c5 returning clob) returning clob) into dt_lt from temp_2;
    delete temp_1;delete temp_2;commit;
end if;

---thong tin thanh toan
delete temp_4;
select count(*) into b_i1 from bh_sk_tt where ma_dvi = b_ma_dvi and so_id = b_so_id;
PKH_JS_THAYa(dt_ct,'so_ky_tt',b_i1);
if  b_i1 = 1 then
    select min(ngay) into b_ngay_tt from bh_sk_tt where ma_dvi = b_ma_dvi and so_id = b_so_id;
    PKH_JS_THAYa(dt_ct,'thoi_han_tt',N'Thời hạn thanh toán phí bảo hiểm: thanh toán trước ngày '|| FBH_IN_CSO_NG(b_ngay_tt,'DD/MM/YYYY'));
elsif b_i1 > 1 then
    PKH_JS_THAYa(dt_ct,'thoi_han_tt',N'Thời hạn thanh toán phí bảo hiểm:');
    b_i1:= 1;
    for r_lp in (select ngay,tien from bh_sk_tt where ma_dvi = b_ma_dvi and so_id = b_so_id order by ngay asc)
    loop
    insert into temp_4(C1) values(N'-   Kỳ ' || b_i1 || N': thanh toán ' || FBH_CSO_TIEN(r_lp.tien,FKH_JS_GTRIs(dt_ct,'nt_tien')) || N' trước ngày ' || FBH_IN_CSO_NG(r_lp.ngay,'DD/MM/YYYY'));
    b_i1:= b_i1 + 1;
    end loop;
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_tt from temp_4;
delete temp_4;commit;


select json_object('dt_ct' value dt_ct,'dt_dk' value dt_dk,
'dt_qt' value dt_qt,'dt_bs' value dt_bs,'dt_kbt' value dt_kbt,
'dt_ttt' value dt_ttt,'dt_lt' value dt_lt,'dt_dong' value dt_dong,'dt_tt' value dt_tt,'dt_hu' value dt_hu returning clob) into b_oraOut from dual;

exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
/

create or replace procedure PBH_SKGD_HC(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    -- chung
    b_loi varchar2(100); b_lenh varchar2(1000);
    -- orain
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
  --
    b_i1 number := 0;b_ngay_tt number;b_i2 number:=0;
    dt_ct clob; dt_bs clob; dt_ds clob; dt_dk clob; dt_lt clob;dt_kbt clob; dt_ttt clob;dt_dong clob;
    b_kh_ttt clob;dt_qt clob;dt_tt clob;b_dvi clob;dt_hu clob;dt_dkbs clob;
    dt_cho clob;
    dt_ds_ct pht_type.a_clob;dt_ds_dk pht_type.a_clob;dt_ds_dkbs pht_type.a_clob;dt_ds_lt pht_type.a_clob;
    dt_ds_khd pht_type.a_clob;dt_ds_kbt pht_type.a_clob;dt_ds_cho pht_type.a_clob;dt_ds_bvi pht_type.a_clob;dt_ds_ttt pht_type.a_clob;
    dt_nhom clob;

    b_temp_clob clob;a_clob pht_type.a_clob;
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
    a_dk_ma pht_type.a_var;a_dk_ten pht_type.a_nvar; a_dk_tien pht_type.a_num;a_dk_phi pht_type.a_num;
    a_dk_cap pht_type.a_num;a_dk_kieu pht_type.a_var;a_dk_lkeb pht_type.a_var;
    a_dk_mota pht_type.a_nvar;a_dk_pt pht_type.a_num;a_dk_ptb pht_type.a_num;
    --dt_ds
    a_ds_ten pht_type.a_nvar;a_ds_phong pht_type.a_nvar;a_ds_ng_sinh pht_type.a_num;
    --tgian cho
    a_cho_ten pht_type.a_nvar;a_cho_sn pht_type.a_num;
begin
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);

select count(*) into b_i1 from bh_sk_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ct FROM bh_sk_txt t WHERE ma_dvi = b_ma_dvi and  t.so_id = b_so_id AND t.loai='dt_ct';
    b_nt_tien:=FKH_JS_GTRIs(dt_ct ,'nt_tien');
    b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_hl');
    PKH_JS_THAYa(dt_ct,'gio_hl',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || U' gi\1EDD ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00') );
    b_temp_var:=FKH_JS_GTRIs(dt_ct ,'gio_kt');
    PKH_JS_THAYa(dt_ct,'gio_kt',NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'T') ,'00') || U' gi\1EDD ' ||  NVL(FBH_IN_SUBSTR(b_temp_var, '|', 'S') ,'00'));
    ---
    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_cap');
    if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_cap',' '); 
    else PKH_JS_THAYa(dt_ct,'ngay_cap',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    PKH_JS_THAYa(dt_ct,'ngay_cap_s',U'Ng\00E0y ' || FBH_IN_CSO_NG(b_i1,'DD') || U' th\00E1ng ' || FBH_IN_CSO_NG(b_i1,'MM')
    || U' n\0103m ' || FBH_IN_CSO_NG(b_i1,'YYYY'));
    
    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_hl');
    if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_hl',' '); 
    else PKH_JS_THAYa(dt_ct,'ngay_hl',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_kt');
    if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_kt',' '); 
    else PKH_JS_THAYa(dt_ct,'ngay_kt',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

    b_i1:= FKH_JS_GTRIn(dt_ct ,'phi');
    PKH_JS_THAY(dt_ct,'phi',FBH_CSO_TIEN(b_i1,b_nt_tien) );


    b_i1:= FKH_JS_GTRIn(dt_ct ,'thue');
    PKH_JS_THAY(dt_ct,'thue',FBH_CSO_TIEN(b_i1,b_nt_tien) );

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ttoan');
    PKH_JS_THAY(dt_ct,'ttoan',FBH_CSO_TIEN(b_i1,b_nt_tien) );
    PKH_JS_THAYa(dt_ct,'bangchu',FBH_IN_CSO_CHU(b_i1,b_nt_tien) );

    b_temp_var:= FKH_JS_GTRIs(dt_ct ,'gioi');
    if b_temp_var= 'M' and trim(b_temp_var) is not null then PKH_JS_THAY(dt_ct,'gioi', 'Nam');
    else PKH_JS_THAY(dt_ct,'gioi', U'N\1EEF');end if;

     b_temp_var:= FKH_JS_GTRIs(dt_ct ,'gioid');
    if b_temp_var= 'M' and trim(b_temp_var) is not null then PKH_JS_THAY(dt_ct,'gioid', 'Nam');
    else PKH_JS_THAY(dt_ct,'gioid', U'N\1EEF');end if;

    -- nguoi duoc bh
    if trim(FKH_JS_GTRIs(dt_ct ,'ng_dd')) is null THEN
      PKH_JS_THAY(dt_ct,'ng_dd',FKH_JS_GTRIs(dt_ct ,'ten'));
      PKH_JS_THAY(dt_ct,'cmtd',FKH_JS_GTRIs(dt_ct ,'cmt'));
      PKH_JS_THAY(dt_ct,'mobid',FKH_JS_GTRIs(dt_ct ,'mobi'));
      PKH_JS_THAY(dt_ct,'emaild',FKH_JS_GTRIs(dt_ct ,'email'));
      PKH_JS_THAY(dt_ct,'dchid',FKH_JS_GTRIs(dt_ct ,'dchi'));
      PKH_JS_THAY(dt_ct,'gioid',FKH_JS_GTRIs(dt_ct ,'gioi'));
      PKH_JS_THAY(dt_ct,'dchid',FKH_JS_GTRIs(dt_ct ,'dchi'));
      PKH_JS_THAY(dt_ct,'ng_sinhd',FKH_JS_GTRIs(dt_ct ,'ng_sinh'));
    end if;
    --goi
    b_temp_var:= FKH_JS_GTRIs(dt_ct ,'goi');
    if trim(b_temp_var) is not null then
      select count(*) into b_i1 from bh_sk_goi where ma  = b_temp_var;
      if b_i1 <> 0 then select ten into b_temp_nvar from bh_sk_goi where ma  = b_temp_var;end if;
      PKH_JS_THAY(dt_ct,'goi',b_temp_nvar);
    end if;
	 -- lay ten dvi
    select count(*) into b_i1 from  ht_ma_dvi where ma = b_ma_dvi;
    if b_i1 <> 0 then
       select ten,kvuc into b_ten_dvi,b_ma_kvuc from ht_ma_dvi where ma = b_ma_dvi;
    end if;
    if trim(b_ma_kvuc) is not null then
      select count(*) into b_i1 from  bh_ma_kvuc where ma = b_ma_kvuc;
      if b_i1 <> 0 then
        select ten into b_ten_kvuc from bh_ma_kvuc where ma = b_ma_kvuc;
      end if;
    end if;
    PKH_JS_THAYa(dt_ct,'ten_kvuc',b_ten_kvuc);
end if;

--tt dvi
    select json_object('ten_gon' value  NVL(ten_gon,' '),'ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
           'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
               from ht_ma_dvi where ma=b_ma_dvi;
    dt_ct:=FKH_JS_BONH(dt_ct);
    b_dvi:=FKH_JS_BONH(b_dvi);
    select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;
--tpa
  b_temp_var:= FKH_JS_GTRIs(dt_ct,'tpa');
  if trim(b_temp_var) is not null then
  select count(*) into b_i1 from bh_ma_gdinh where ma=b_temp_var;
  if b_i1 <> 0 then
  select json_object('ten_tpa' value  NVL(ten,' '),'dchi_tpa' value NVL(dchi,' '),'mobi_tpa' value NVL(mobi,' '),'email_tpa' value NVL(email,' ')
    returning clob) into b_temp_clob from bh_ma_gdinh where ma=b_temp_var;
  else
    select json_object('ten_tpa' value ' ','dchi_tpa' value ' ','mobi_tpa' value ' ','email_tpa' value ' '
    returning clob) into b_temp_clob from dual;
  end if;
  select json_mergepatch(dt_ct,b_temp_clob) into dt_ct from dual;
  end if;

---thong tin thanh toan
delete temp_4;commit;
select count(*) into b_i1 from bh_sk_tt where ma_dvi = b_ma_dvi and so_id = b_so_id;
PKH_JS_THAYa(dt_ct,'so_ky_tt',b_i1);
if  b_i1 = 1 then
    select min(ngay) into b_ngay_tt from bh_sk_tt where ma_dvi = b_ma_dvi and so_id = b_so_id;
    PKH_JS_THAYa(dt_ct,'thoi_han_tt',U'Th\1EDDi h\1EA1n thanh to\00E1n ph\00ED b\1EA3o hi\1EC3m: thanh to\00E1n tr\01B0\1EDBc ng\00E0y '|| FBH_IN_CSO_NG(b_ngay_tt,'DD/MM/YYYY'));
elsif b_i1 > 1 then
    PKH_JS_THAYa(dt_ct,'thoi_han_tt',U'Th\1EDDi h\1EA1n thanh to\00E1n ph\00ED b\1EA3o hi\1EC3m:');
    b_i1:= 1;
    for r_lp in (select ngay,tien from bh_sk_tt where ma_dvi = b_ma_dvi and so_id = b_so_id order by ngay asc)
    loop
    insert into temp_4(C1) values(U'-   K\1EF3 ' || b_i1 || U': thanh to\00E1n ' || FBH_CSO_TIEN(r_lp.tien,FKH_JS_GTRIs(dt_ct,'nt_tien')) || U' tr\01B0\1EDBc ng\00E0y ' || FBH_IN_CSO_NG(r_lp.ngay,'DD/MM/YYYY'));
    b_i1:= b_i1 + 1;
    end loop;
end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_tt from temp_4;
delete temp_4;commit;
--end dong

-----dt_ds
select count(*) into b_i1 from bh_sk_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ds';
if b_i1 <> 0 then
  delete temp_1;delete temp_2;delete temp_3;commit;
  SELECT FKH_JS_BONH(t.txt) INTO dt_ds FROM bh_sk_txt t WHERE  t.so_id = b_so_id AND t.loai='dt_ds';
  b_lenh:=FKH_JS_LENHc('dt_ds_ct,dt_ds_dk,dt_ds_dkbs,dt_ds_lt,dt_ds_khd,dt_ds_kbt,dt_ds_cho,dt_ds_bvi,dt_ds_ttt');
  EXECUTE IMMEDIATE b_lenh bulk collect into dt_ds_ct,dt_ds_dk,dt_ds_dkbs,dt_ds_lt,dt_ds_khd,dt_ds_kbt,dt_ds_cho,dt_ds_bvi,dt_ds_ttt using dt_ds;
  
  --lay ra so nhom > dt_ct
  PKH_JS_THAY(dt_ct,'so_nhom',dt_ds_ct.count);
  -- dieu khoan bo sung
  dt_dkbs:= dt_ds_dkbs(1);
  --
  dt_dk:= dt_ds_dk(1);
  b_lenh:=FKH_JS_LENH('ma,ten,tien,cap,pt,ptb');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_dk_ma,a_dk_ten,a_dk_tien,a_dk_cap,a_dk_pt,a_dk_ptb  using dt_dk;
  for b_lp in 1..a_dk_ma.count loop
    insert into temp_1(c1,c2,c3,c4) values(a_dk_ten(b_lp),FBH_CSO_TIEN(a_dk_tien(b_lp),b_nt_tien),FBH_TO_CHAR(a_dk_pt(b_lp)),FBH_CSO_TIEN(a_dk_tien(b_lp),b_nt_tien) );
  end loop;
end if;
-- thong tin thoi gian cho
b_lenh:=FKH_JS_LENH('ten,so_ngay');
EXECUTE IMMEDIATE b_lenh bulk collect into a_cho_ten,a_cho_sn  using dt_ds_cho(1);
delete temp_1;commit;
for b_lp in 1..a_cho_ten.count loop
  b_temp_nvar:= case when a_cho_sn(b_lp) > 0 then a_cho_sn(b_lp) || U' ng\00E0y'  else ' ' end;
  insert into temp_1(c1) values(a_cho_ten(b_lp) || ': ' || b_temp_nvar );
end loop;
select JSON_ARRAYAGG(json_object('TEN' VALUE C1 returning clob) returning clob) into dt_cho from temp_1;
delete temp_1;commit;

select json_object('dt_ct' value dt_ct,'dt_dk' value dt_dk,
'dt_qt' value dt_qt,'dt_bs' value dt_bs,'dt_kbt' value dt_kbt,
'dt_ttt' value dt_ttt,'dt_lt' value dt_lt,'dt_dong' value dt_dong,'dt_tt' value dt_tt,'dt_hu' value dt_hu,'dt_nhom' value dt_nhom,
'dt_ds' value dt_ds,'dt_cho' value dt_cho,'dt_dkbs' value dt_dkbs returning clob) into b_oraOut from dual;

commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;