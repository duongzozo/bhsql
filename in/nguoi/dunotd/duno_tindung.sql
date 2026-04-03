
create or replace procedure PBH_DNTD_INGCN(
    dk_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    -- chung
    b_loi varchar2(100); b_lenh varchar2(1000);b_i1 number;
    -- orain
    b_so_hd varchar2(50) :=FKH_JS_GTRIs(b_oraIn,'so_hd');
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');

    dt_ct clob; dt_dk clob;b_dvi clob;dt_bs clob; dt_ttt clob;dt_lt clob;dk_qtac clob;
    b_dl clob;dt_tt clob;
    -- khac
    b_count  NUMBER;
    b_nghed varchar2(20);b_nghed_ten nvarchar2(500):= ' ';
    b_qtac nvarchar2(500):=' ';b_ma_qtac varchar2(20);
    b_ma_goi varchar2(20); b_ten_goi nvarchar2(500):=' ';
    b_ma_sp varchar2(20);b_ten_sp nvarchar2(500):=' ';b_ngay_tt number;
    b_ma_kt varchar2(20);b_logo_path varchar2(500):=' ';
    b_ng_huong nvarchar2(500):=' ';
    b_ma_kh varchar2(20);
    b_dsachh nvarchar2(500):=' ';

    --bien mang
    a_ma pht_type.a_var; a_nd pht_type.a_nvar; a_ten pht_type.a_nvar;
    --thoi gian cho
    b_check number:= 0;b_nd clob;b_idx NUMBER := 0;
    --
    a_dk_ma pht_type.a_var;a_dkbs_ten pht_type.a_nvar;

begin

-- dt_ct
select count(*) into b_i1 from bh_ngtd_txt t where t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_ct';
if b_i1 <> 0 then
    select FKH_JS_BONH(txt) into dt_ct from bh_ngtd_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';

    select json_object('ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
           'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
               from ht_ma_dvi where ma=b_ma_dvi;
    dt_ct:=FKH_JS_BONH(dt_ct);
    b_dvi:=FKH_JS_BONH(b_dvi);
    select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;

    -- thong tin nguoi duoc bh
    select NVL(ng_huong,' ') into b_ng_huong from bh_ngtd_ds where so_id_dt = b_so_id;
    PKH_JS_THAYa(dt_ct,'ng_huong',b_ng_huong);
    -- thong tin dai ly
    select ma_kh into b_ma_kh from bh_ngtd where so_id = b_so_id;
    select count(1) into b_i1 from bh_dl_ma_kh where ma=b_ma_kh;
    if b_i1 <> 0 then
       select json_object('ten_dl' value NVL(ten,' '),'dchi_dl' value NVL(dchi,' '),'mobi_dl' value NVL(mobi,' '),
           'cmt_dl' value NVL(cmt,' ') returning clob) into b_dl
              from bh_dl_ma_kh where ma=b_ma_kh;
    else
      select json_object('ten_dl' value ' ','dchi_dl' value ' ','mobi_dl' value ' ',
           'cmt_dl' value ' ' returning clob) into b_dl
              from dual;
    end if;

    dt_ct:=FKH_JS_BONH(dt_ct);
    b_dl:=FKH_JS_BONH(b_dl);
    select json_mergepatch(dt_ct,b_dl) into dt_ct from dual;
end if;
-- dt_bs

select count(*) into b_i1 from bh_ngtd_txt t where t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_dkbs';
if b_i1 <> 0 then
    select FKH_JS_BONH(txt) into dt_bs from bh_ngtd_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dkbs';
    delete temp_6;
    b_lenh := FKH_JS_LENH('ma_dk,ten');
    EXECUTE IMMEDIATE b_lenh bulk collect INTO a_dk_ma,a_dkbs_ten USING dt_bs;
    for b_lp in 1..a_dk_ma.count loop
      ---lay nd dkbs
        select count(*) into b_i1 from bh_ma_dkbs where ma = a_dk_ma(b_lp);
        if b_i1 <> 0 then
           SELECT FKH_JS_GTRIc(FKH_JS_BONH(t.txt) ,'nd') into b_nd from bh_ma_dkbs t where  t.ma= a_dk_ma(b_lp) and rownum = 1;
        end if;
        insert into temp_6(CL1,C1) values(b_nd,a_dk_ma(b_lp));
    end loop;

    select JSON_ARRAYAGG(json_object('TEN' VALUE CL1 returning clob) returning clob) into dt_bs FROM temp_6;
    delete temp_6;
end if;
-- dt_ttt
select count(*) into b_i1 from bh_ngtd_txt t where t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_ttt';
if b_i1 <> 0 then
    select FKH_JS_BONH(txt) into dt_ttt from bh_ngtd_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
    b_lenh:=FKH_JS_LENHc('ma,nd');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_ma,a_nd using dt_ttt;
    delete temp_3;
    -- for r_lp in (select ma,ten,loai from bh_kh_ttt WHERE nv = 'NG' AND ps = 'HD'  order by bt)
    -- loop
    --   if b_check = 1 then
    --     b_idx:= b_idx +1;
    --     insert into temp_3(c1,c2,c3) values(r_lp.ma,b_idx ||'. ' || r_lp.ten, ' ');
    --   end if;
    --   if r_lp.ma = 'TGC' and r_lp.loai = 'G' THEN
    --     b_check:= 1;
    --   ELSIF r_lp.loai = 'G' then
    --     b_check:= 0;
    --   end if;
    -- end loop;

    -- for ds_lp in 1..a_ma.count loop
    --     select count(*) into b_i1 from temp_3 where c1 = a_ma(ds_lp);
    --     if b_i1 > 0 then
    --       if trim(a_nd(ds_lp)) is null then
    --         delete from temp_3 where  c1 = a_ma(ds_lp);
    --       else
    --         update temp_3 set c3 = a_nd(ds_lp) where c1 = a_ma(ds_lp);
    --       end if;

    --     end if;
    -- end loop;
    for r_lp in (select ma,ten,loai from bh_kh_ttt WHERE nv = 'NG' AND ps = 'HD'  order by bt)
    loop
      if r_lp.ma in('TN', 'BT', 'UT', 'TS')  then
        b_idx:= b_idx +1;
        insert into temp_3(c1,c2,c3) values(r_lp.ma,b_idx ||'. ' || r_lp.ten, ' ');
      end if;
    end loop;

    for ds_lp in 1..a_ma.count loop
        select count(*) into b_i1 from temp_3 where c1 = a_ma(ds_lp);
        if b_i1 > 0 then
          if trim(a_nd(ds_lp)) is null then
            delete from temp_3 where  c1 = a_ma(ds_lp);
          else
            update temp_3 set c3 = a_nd(ds_lp) where c1 = a_ma(ds_lp);
          end if;

        end if;
    end loop;

end if;
select JSON_ARRAYAGG(json_object('TEN' VALUE (C2 || ': ' || C3),'ND' value C3) returning clob) into dt_ttt from TEMP_3;
delete TEMP_3;
-- dt_dk
select count(*) into b_i1 from bh_ngtd_txt t where t.ma_dvi=b_ma_dvi AND t.so_id = b_so_id AND t.loai='dt_dk';
if b_i1 <> 0 then
    select FKH_JS_BONH(txt) into dt_dk from bh_ngtd_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dk';
end if;
-- dt_lt
select count(*) into b_i1 from bh_ng_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then
    select FKH_JS_BONH(lt) into dt_lt from bh_ng_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and rownum = 1;
end if;
-- lay ten goi
b_ma_goi := FKH_JS_GTRIs(dt_ct,'goi');
if trim(b_ma_goi) is not null then
    select ten into b_ten_goi from bh_ngtd_goi where ma = b_ma_goi;
end if;
PKH_JS_THAYa(dt_ct,'ten_goi',b_ten_goi);
if trim(FKH_JS_GTRIs(dt_ct,'dsachh')) is null then
  PKH_JS_THAYa(dt_ct,'dsachh',' ');
end if;

-- lay qtac
b_ma_sp:=FKH_JS_GTRIs(dt_ct,'ma_sp');
SELECT FKH_JS_BONH(t.txt),t.ten into dk_qtac,b_ten_sp FROM bh_ngtd_sp t, bh_ngtd t1 WHERE t.ma = b_ma_sp and t1.ma_dvi=b_ma_dvi and t1.so_id=b_so_id;
b_lenh := FKH_JS_LENH('qtac');
EXECUTE IMMEDIATE b_lenh INTO b_ma_qtac USING dk_qtac;
IF b_ma_qtac IS NOT NULL THEN
  SELECT t.TEN into b_qtac FROM bh_ma_qtac t WHERE t.ma=b_ma_qtac;
END IF;
--ten sp
PKH_JS_THAYa(dt_ct,'qtac',b_qtac);
PKH_JS_THAYa(dt_ct,'ten_sp',b_ten_sp);
-- lay thong tin duong dan file logo tu bang logo
select ma_kt into b_ma_kt from bh_ngtd where so_id = b_so_id;
if trim(b_ma_kt) is not null then
  select count(*) into b_i1 from bh_in_logo_dl where ma_kt = b_ma_kt;
  if b_i1 <> 0 then
     select logo_path into b_logo_path from bh_in_logo_dl where ma_kt = b_ma_kt;
  end if;
end if;
PKH_JS_THAYa(dt_ct,'logo_path',b_logo_path);


select min(ngay) into b_ngay_tt from bh_ngtd_tt where so_id = b_so_id;
PKH_JS_THAYa(dt_ct,'ngay_tt',b_ngay_tt);


-- thong tin thanh toan
delete temp_4;
select count(*) into b_i1 from bh_ngtd_tt  k_tt where so_id = b_so_id;
if  b_i1 = 1 then
  select min(ngay) into b_ngay_tt from bh_ngtd_tt  where so_id = b_so_id;
   insert into temp_4(C1) values(unistr('\0054\0068\0061\006E\0068\0020\0074\006F\00E1\006E\0020\0074\0072\01B0\1EDB\0063\0020\006E\0067\00E0\0079\0020')|| to_char(PKH_SO_CNG_DATE(b_ngay_tt),'DD/MM/YYYY') || unistr('\0020\0074\0068\0065\006F\0020\0068\1EE3\0070\0020\0111\1ED3\006E\0067\0020\0062\1EA3\006F\0020\0068\0069\1EC3\006D\0020\0111\00E3\0020\006B\00FD\0020\006B\1EBF\0074\002E')
   );
elsif b_i1 > 1 then
  b_i1:= 1;
  for r_lp in (select ngay,tien from bh_ngtd_tt  where so_id = b_so_id)
  loop
    insert into temp_4(C1) values(unistr('\002D\0020\004B\1EF3\0020') || b_i1 || ': ' || to_char(PKH_SO_CNG_DATE(r_lp.ngay),'DD/MM/YYYY') || ' - ' || trim(TO_CHAR(r_lp.tien, '999,999,999,999,999,999PR'))|| ' ' || FKH_JS_GTRIs(dt_ct,'nt_tien') );
    b_i1:= b_i1 + 1;
  end loop;
end if;

select JSON_ARRAYAGG(json_object('TEN' VALUE C1) returning clob) into dt_tt from temp_4;
delete temp_4;

select json_object('dt_ct' value dt_ct,'dt_dk' value dt_dk,'dt_bs' value dt_bs,'dt_ttt' value dt_ttt,'dt_lt' value dt_lt,'dt_tt' value dt_tt returning clob) into b_oraOut from dual;

commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
/

