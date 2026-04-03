create or replace procedure PBH_BCTK_DVI(
    dk_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    dt_dvi clob;b_loi VARCHAR2(100):= ' ';
begin
delete temp_1;
insert into temp_1(c1,c2) 
    select ma,ten from ht_ma_dvi where ma = dk_ma_dviN;
insert into temp_1(c1,c2) 
    select dv.ma,dv.ten from ht_ma_nsd_qly ql
    left join ht_ma_dvi dv on dv.ma = ql.dvi
    where ql.ma_dvi = dk_ma_dviN and ql.ma = b_nsd;


select JSON_ARRAYAGG(json_object('ma' VALUE c1,'ten' value c2 returning clob) returning clob) into dt_dvi from temp_1;
delete temp_1;commit;

select json_object('dt_dvi' value dt_dvi returning clob) into b_oraOut from dual;

exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
/
create or replace procedure PBH_BC_BCTK_DTPS(
    dk_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000);
    b_loi varchar2(100); b_i1 number;
    b_ngayd number :=FKH_JS_GTRIn(b_oraIn,'ngayd');
    b_ngayc number :=FKH_JS_GTRIn(b_oraIn,'ngayc');
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_ma_sp varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_sp');


    dt_ct clob;dt_ds clob;
 
begin
b_ma_dvi:=nvl(trim(b_ma_dvi),dk_ma_dviN);
---dt_ct
select json_object('ngayd' value FBH_IN_CSO_NG(b_ngayd,'DD/MM/YYYY'),'ngayc' value FBH_IN_CSO_NG(b_ngayc,'DD/MM/YYYY'),
'ma_dvi' value b_ma_dvi,'ma_sp' value b_ma_sp,'user' value b_nsd,'ngay_ht' value FBH_IN_CSO_NG(TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDD')),'DD/MM/YYYY') returning clob) into dt_ct from dual;

--------------------bh hang
insert into temp_1(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22)
select 
  a.ma_dvi,
  a.phong,
  a.NHANG as ma_sp,
  case when a.so_id_g <> 0 then SUBSTR(to_char(a.so_id_d), 3) else a.so_hd end as so_hd,
  case when a.so_id_g <> 0 then a.so_hd else '' end as  sdbs,
  FBH_IN_CSO_NG(a.ngay_hl,'DD/MM/YYYY') as ngay_hl,
  FBH_IN_CSO_NG(a.ngay_kt,'DD/MM/YYYY') as ngay_kt,
  a.ma_kt,
  CASE a.kieu_kt
      WHEN 'T' THEN cb.ten
      WHEN 'D' THEN kh.ten
      WHEN 'M' THEN kh.ten
      WHEN 'N' THEN nh.ten
  END AS ten_kt,
  case when a.kieu_kt = 'D' then a.ma_kt else TO_CHAR('') end as ma_dl,
  case when a.kieu_kt = 'D' then kh.ten else CAST('' AS NVARCHAR2(200)) end as ten_dl,
  a.ma_gt,
  case a.kieu_gt
      WHEN 'C' THEN cb.ten
      WHEN 'K' THEN kh.ten
      WHEN 'D' THEN kh.ten
      WHEN 'N' THEN nh.ten
  END AS ten_gt,
  a.ma_kh,
  a.ten,
  FBH_CSO_TIEN(a.phi,'') as phi,
  a.nt_tien,
  FKH_JS_GTRIs(txt.txt ,'tygia') as tygia,
  a.NHANG,
  a.loai_kh,
  case a.loai_kh
      WHEN 'C' THEN N'Cá nhân'
      WHEN 'T' THEN N'Tổ chức'
  END AS ten_loai_kh,
  g.nv
from bh_hang a
left join bh_hd_goc g on g.so_id = a.so_id and g.ma_dvi = a.ma_dvi
LEFT JOIN ht_ma_cb cb ON cb.ma = g.ma_kt
LEFT JOIN bh_dl_ma_kh kh ON kh.ma = g.ma_kt
LEFT JOIN bh_ma_nhang nh ON nh.ma = g.ma_kt
LEFT JOIN BH_hang_txt txt ON a.so_id = txt.so_id and txt.loai = 'dt_ct'
WHERE a.ma_dvi   = b_ma_dvi
  AND a.ngay_cap BETWEEN b_ngayd AND b_ngayc
  AND (b_ma_sp IS NULL OR a.NHANG = b_ma_sp)
ORDER BY a.ma_dvi, a.so_hd;

----tau
insert into temp_1(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22)
select 
  a.ma_dvi,
  a.phong,
  case when a.nv = 'H' then ds.ma_sp else FKH_JS_GTRIs(txt.txt ,'ma_sp') end as ma_sp,
  case when a.so_id_g <> 0 then SUBSTR(to_char(a.so_id_d), 3) else a.so_hd end as so_hd,
  case when a.so_id_g <> 0 then a.so_hd else '' end as  sdbs,
  FBH_IN_CSO_NG(a.ngay_hl,'DD/MM/YYYY') as ngay_hl,
  FBH_IN_CSO_NG(a.ngay_kt,'DD/MM/YYYY') as ngay_kt,
  a.ma_kt,
  CASE a.kieu_kt
      WHEN 'T' THEN cb.ten
      WHEN 'D' THEN kh.ten
      WHEN 'M' THEN kh.ten
      WHEN 'N' THEN nh.ten
  END AS ten_kt,
  case when a.kieu_kt = 'D' then a.ma_kt else TO_CHAR('') end as ma_dl,
  case when a.kieu_kt = 'D' then kh.ten else CAST('' AS NVARCHAR2(200)) end as ten_dl,
  a.ma_gt,
  case a.kieu_gt
      WHEN 'C' THEN cb.ten
      WHEN 'K' THEN kh.ten
      WHEN 'D' THEN kh.ten
      WHEN 'N' THEN nh.ten
  END AS ten_gt,
  a.ma_kh,
  a.ten,
  FBH_CSO_TIEN(a.phi,'') as phi,
  a.nt_tien,
  FKH_JS_GTRIs(txt.txt ,'tygia') as tygia,
  case when a.nv = 'H' then ds.ma_sp else FKH_JS_GTRIs(txt.txt ,'ma_sp') end,
  a.loai_kh,
  case a.loai_kh
      WHEN 'C' THEN N'Cá nhân'
      WHEN 'T' THEN N'Tổ chức'
  END AS ten_loai_kh,
  g.nv
from bh_tau a
left join bh_hd_goc g on g.so_id = a.so_id and g.ma_dvi = a.ma_dvi
left join bh_tau_ds ds on ds.so_id = a.so_id and ds.ma_dvi = a.ma_dvi
LEFT JOIN ht_ma_cb cb ON cb.ma = g.ma_kt
LEFT JOIN bh_dl_ma_kh kh ON kh.ma = g.ma_kt
LEFT JOIN bh_ma_nhang nh ON nh.ma = g.ma_kt
LEFT JOIN BH_tau_txt txt ON a.so_id = txt.so_id and txt.loai = 'dt_ct'
WHERE a.ma_dvi   = b_ma_dvi
  AND a.ngay_cap BETWEEN b_ngayd AND b_ngayc
  AND (b_ma_sp IS NULL OR ds.ma_sp = b_ma_sp)
ORDER BY a.ma_dvi, a.so_hd;
---ptnhang
insert into temp_1(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22)
select 
  a.ma_dvi,
  a.phong,
  a.ma_sp,
  case when a.so_id_g <> 0 then SUBSTR(to_char(a.so_id_d), 3) else a.so_hd end as so_hd,
  case when a.so_id_g <> 0 then a.so_hd else '' end as  sdbs,
  FBH_IN_CSO_NG(a.ngay_hl,'DD/MM/YYYY') as ngay_hl,
  FBH_IN_CSO_NG(a.ngay_kt,'DD/MM/YYYY') as ngay_kt,
  a.ma_kt,
  CASE a.kieu_kt
      WHEN 'T' THEN cb.ten
      WHEN 'D' THEN kh.ten
      WHEN 'M' THEN kh.ten
      WHEN 'N' THEN nh.ten
  END AS ten_kt,
  case when a.kieu_kt = 'D' then a.ma_kt else TO_CHAR('') end as ma_dl,
  case when a.kieu_kt = 'D' then kh.ten else CAST('' AS NVARCHAR2(200)) end as ten_dl,
  a.ma_gt,
  case a.kieu_gt
      WHEN 'C' THEN cb.ten
      WHEN 'K' THEN kh.ten
      WHEN 'D' THEN kh.ten
      WHEN 'N' THEN nh.ten
  END AS ten_gt,
  a.ma_kh,
  a.ten,
  FBH_CSO_TIEN(a.phi,'') as phi,
  a.nt_tien,
  FKH_JS_GTRIs(txt.txt ,'tygia') as tygia,
  a.ma_sp,
  a.loai_kh,
  case a.loai_kh
      WHEN 'C' THEN N'Cá nhân'
      WHEN 'T' THEN N'Tổ chức'
  END AS ten_loai_kh,
  g.nv
from bh_ptnvc a
left join bh_hd_goc g on g.so_id = a.so_id and g.ma_dvi = a.ma_dvi
LEFT JOIN ht_ma_cb cb ON cb.ma = g.ma_kt
LEFT JOIN bh_dl_ma_kh kh ON kh.ma = g.ma_kt
LEFT JOIN bh_ma_nhang nh ON nh.ma = g.ma_kt
LEFT JOIN BH_hang_txt txt ON a.so_id = txt.so_id and txt.loai = 'dt_ct'
WHERE a.ma_dvi   = b_ma_dvi
  AND a.ngay_cap BETWEEN b_ngayd AND b_ngayc
  AND (b_ma_sp IS NULL OR a.ma_sp = b_ma_sp)
ORDER BY a.ma_dvi, a.so_hd;

select JSON_ARRAYAGG(json_object(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22) returning clob) into dt_ds from temp_1;
delete temp_1;commit;

select json_object('dt_ct' value dt_ct,'dt_ds' value dt_ds returning clob) into b_oraOut from dual;

exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;