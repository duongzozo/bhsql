create or replace procedure PBH_IN_TTBT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
    b_i1 number := 0;
    dt_ct clob; dt_dk clob; 
    a_tien_tt pht_type.a_num; a_ma_nt_tt pht_type.a_var;a_so_id pht_type.a_num;
    a_so_hs pht_type.a_var;
    b_tong_tien number:=0;b_tien_chu NVARCHAR2(500):= '';b_ma_nt varchar2(10);
    
    b_so_hd varchar2(20);b_so_id_hs number;

    b_bang varchar2(20);hs_dt_ct clob;
    b_sql       VARCHAR2(4000);
    b_nv varchar2(10);

begin
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
delete temp_1;
commit;
--dt_ct
select count(*) into b_i1 from bh_bt_tt_txt t WHERE t.ma_dvi = b_ma_dvi and t.so_id_tt = b_so_id AND t.loai='dt_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ct FROM bh_bt_tt_txt t WHERE t.ma_dvi = b_ma_dvi and t.so_id_tt = b_so_id AND t.loai='dt_ct';
end if;
-- lay dt_dk
select count(*) into b_i1 from bh_bt_tt_txt t WHERE t.ma_dvi = b_ma_dvi and t.so_id_tt = b_so_id AND t.loai='dt_dk';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_dk FROM bh_bt_tt_txt t WHERE t.ma_dvi = b_ma_dvi and t.so_id_tt = b_so_id AND t.loai='dt_dk';

  b_lenh:=FKH_JS_LENH('so_id,ma_nt,tien,so_hs');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_so_id,a_ma_nt_tt,a_tien_tt,a_so_hs using dt_dk;
  b_so_id_hs:= a_so_id(1);
  for b_lp in 1..a_tien_tt.count loop
      b_tong_tien:= b_tong_tien + a_tien_tt(b_lp);
      b_ma_nt:= a_ma_nt_tt(b_lp);
      select so_hd into b_so_hd from bh_bt_hs where ma_dvi = b_ma_dvi and so_id = a_so_id(b_lp);
      insert into temp_1(C1,C2,C3,C4,C5,C6) values(a_so_hs(b_lp),b_so_hd,'',FBH_CSO_TIEN_KNT(a_tien_tt(b_lp)),'' ,b_ma_nt);
  end loop;
  b_tien_chu:= FBH_IN_CSO_CHU(b_tong_tien, b_ma_nt);
end if;
PKH_JS_THAYc(dt_ct,'tong_tien',FBH_CSO_TIEN_KNT(b_tong_tien));
PKH_JS_THAYa(dt_ct,'tien_bangchu',b_tien_chu);
PKH_JS_THAYa(dt_ct,'nt_tien',b_ma_nt);

PKH_JS_THAYa(dt_ct,'ngay_thang',N'Ngày ' || FBH_IN_CSO_NG(PKH_NG_CSO(sysdate),'DD') || N' tháng '|| FBH_IN_CSO_NG(PKH_NG_CSO(sysdate),'MM')
|| N' năm '|| FBH_IN_CSO_NG(PKH_NG_CSO(sysdate),'YYYY'));
-- lay thong tin nh theo so_id_hs dau tien
select bangg,nv into b_bang,b_nv from bh_bt_hs where ma_dvi = b_ma_dvi and so_id = b_so_id_hs;
b_sql:= 'select txt from ' || b_bang || '_txt where ma_dvi =  :1 and  so_id = :2 and loai = ''dt_ct''';
EXECUTE IMMEDIATE b_sql INTO hs_dt_ct USING b_ma_dvi, b_so_id_hs;
if b_nv not IN('TAU') then
  PKH_JS_THAYa(dt_ct,'chu_tk',FKH_JS_GTRIs(hs_dt_ct,'nhg_ten'));
  PKH_JS_THAYa(dt_ct,'so_tk',FKH_JS_GTRIs(hs_dt_ct,'nhg_tk'));
  PKH_JS_THAYa(dt_ct,'ten_nh',FKH_JS_GTRIs(hs_dt_ct,'ngh_nh'));
ELSE
    PKH_JS_THAYa(dt_ct,'chu_tk',' ');
    PKH_JS_THAYa(dt_ct,'so_tk',' ');
    PKH_JS_THAYa(dt_ct,'ten_nh',' ');
end if;
select json_arrayagg(json_object('stt' value rownum,'so_hs' value C1,'so_hd' value C2,
    'so_hdon' value C3,'so_tien' value C4, 'gchu' value C5,'ma_nt' value C6 returning clob))  into dt_dk from temp_1;

select json_object('dt_ct' value dt_ct,'dt_dk' value dt_dk returning clob) into b_oraOut from dual;
delete temp_1;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
