create or replace procedure PBH_XE_TK_BT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngayd number,b_ngayc number,
        b_ma_dvT varchar2,b_ma_sp varchar2,b_ttrang varchar2,b_dp varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);b_i1 number;
begin
-- Dan - Liet ke cac hop dong no phi
delete temp_1;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_dp = 'OS' then
 insert into temp_1(n1,n2,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,n3,n4,c13,c18,c19,c24,c25,n5,c27,c28,c15,c16,c17,c20,c21,c22,c23,c26,n6,n7)
      select a1.so_id,a1.so_id_dt,a.ma_dvi,a6.ten,a2.lh_nv,a1.so_hs,a1.gcn,a1.so_hd,a1.ma_kh,a1.ten,a5.ten,PKH_SO_CNG(a1.ngay_xr),PKH_SO_CNG(a1.ngay_gui),PKH_SO_CNG(a7.ngay_dp),a7.tien,a1.ttoan,
             PKH_SO_CNG(a1.ngay_qd),case when a1.ngay_do not in (0,30000101) then 'Y' else 'N' end,PKH_SO_CNG(a1.ngay_do),
             a.ma_kt,FBH_TK_KT_TEN(a.ma_kt,a.kieu_kt),a4.tien,a.loai_kh,a1.n_duyet,
             a3.bien_xe,a3.so_khung,a3.so_may,PKH_SO_CNG(a3.ngay_cap),PKH_SO_CNG(a3.ngay_hl),PKH_SO_CNG(a3.ngay_kt),a3.loai_xe,a3.nam_sx,a3.so_cn,a3.ttai
             from bh_xe a, bh_bt_xe a1,bh_bt_xe_dk a2, bh_xe_ds a3, bh_xe_dk a4, ht_ma_nsd a5,ht_ma_dvi a6,bh_bt_hs_dp a7
             where a.so_id=a1.so_id_hd and a1.so_id=a2.so_id and a.so_id=a3.so_id and a1.so_id_dt=a3.so_id_dt and a3.so_id=a4.so_id
             and a3.so_id_dt=a4.so_id_dt and a2.ma=a4.ma and a1.nsd=a5.ma and a.ma_dvi=a6.ma and a1.so_id=a7.so_id
             and a.ma_dvi=b_ma_dvT and a2.lh_nv <> ' ' and a2.tien > 0 and b_ma_sp in ('*',a3.ma_sp) and b_ttrang<>'S' and b_ttrang in ('*',a1.ttrang) and a1.ngay_gui between b_ngayd and b_ngayc;
else
   -- danh sach ho so boi thuong theo khoang thoi gian
  insert into temp_1(n1,n2,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,n4,c14,c18,c19,c24,c25,n5,c27,c28,c15,c16,c17,c20,c21,c22,c23,c26,n6,n7)
      select a1.so_id,a1.so_id_dt,a.ma_dvi,a6.ten,a2.lh_nv,a1.so_hs,a1.gcn,a1.so_hd,a1.ma_kh,a1.ten,a5.ten,PKH_SO_CNG(a1.ngay_xr),PKH_SO_CNG(a1.ngay_gui),a1.ttoan,
             PKH_SO_CNG(a1.ngay_qd),case when a1.ngay_do not in (0,30000101) then 'Y' else 'N' end,PKH_SO_CNG(a1.ngay_do),
             a.ma_kt,FBH_TK_KT_TEN(a.ma_kt,a.kieu_kt),a4.tien,a.loai_kh,a1.n_duyet,
             a3.bien_xe,a3.so_khung,a3.so_may,PKH_SO_CNG(a3.ngay_cap),PKH_SO_CNG(a3.ngay_hl),PKH_SO_CNG(a3.ngay_kt),a3.loai_xe,a3.nam_sx,a3.so_cn,a3.ttai
             from bh_xe a, bh_bt_xe a1,bh_bt_xe_dk a2, bh_xe_ds a3, bh_xe_dk a4, ht_ma_nsd a5,ht_ma_dvi a6
             where a.so_id=a1.so_id_hd and a1.so_id=a2.so_id and a.so_id=a3.so_id and a1.so_id_dt=a3.so_id_dt and a3.so_id=a4.so_id
             and a3.so_id_dt=a4.so_id_dt and a2.ma=a4.ma and a1.nsd=a5.ma and a.ma_dvi=a6.ma
             and a.ma_dvi=b_ma_dvT and a2.lh_nv <> ' ' and a2.tien > 0 and b_ma_sp in ('*',a3.ma_sp) and b_ttrang<>'S' and b_ttrang in ('*',a1.ttrang) and a1.ngay_gui between b_ngayd and b_ngayc;
  -- thong tin du phong
  update temp_1 set (c12,n3)=(select PKH_SO_CNG(ngay_dp),tien from (
                                 select so_id,max(ngay_dp) ngay_dp,tien 
                                        from bh_bt_hs_dp where n1=so_id and nv='XE' group by so_id,tien));
end if;
select count(1) into b_i1 from temp_1;
-- c14 ten nguoi duyet
update temp_1 set c14=(select ten from ht_ma_nsd where ma=c28);
-- lay theo dieu khoan bt
open cs1 for select c1 ma_cn,c2 ten_cn,c3 ma_nv,c4 so_hsbt,c5 so_gcn, c6 so_hd, c7 ma_kh,c8 ten_kh,c9 nguoi_tao,
                    c10 ngay_tainan, c11 ngay_thong_bao,c12 ngay_tao_dp,n3 du_phong,n4 tien,c13 ngay_duyet,c14 nguoi_duyet,
                    c15 bien_ksoat,c16 so_khung,c17 so_may,c18 hsbt_dadong,c19 ngay_dong,c20 ngay_duyetdon,c21 hieu_luc_tu,c22 hieu_luc_den,
                    c23 ma_loai_xe,c24 ma_kenh_pp,c25 ten_kenh_pp,c26 nam_sx,n5 muc_trach_nhiem,c27 ten_loai_kh,n6 so_cho,n7 trong_tai
             from temp_1 order by c4;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_TK_HD
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngayd number,b_ngayc number,
        b_ma_dvT varchar2,b_loai_kh varchar2,b_ma_kh varchar2,b_ma_sp varchar2,
        b_ma_lhnv varchar2,b_phong varchar2,b_ma_cb varchar2,tien_tu number,tien_den number,
        b_ttrang varchar2,b_hieu_luc varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);b_i1 number; b_ngay_ht number:=PKH_NG_CSO(SYSDATE);
begin
-- Dan - Liet ke cac hop dong no phi
delete temp_1;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_hieu_luc = 'E' then
   insert into temp_1(n1,n2,c1,c2,c3,c5,c6,c11,n3,c12,c13,c14,n4,n5,n6,c15,c16,c17,c18,c19,c20,c21,
                      c22,c23,c25,c27,n7,n8,c31,c33,c34,c35,c36,c37,c38,n10)
    select /*+ LEADING(a b) */ b.so_id,b.so_id_dt,a.ma_dvi,a.so_hd,b.gcn,a.ma_kh,a.ten,
       b.loai_xe,b.nam_sx,b.bien_xe,b.so_khung,b.so_may,c.tien,c.phi,c.thue,c.ma_dk,PKH_SO_CNG(a.ngay_ht),PKH_SO_CNG(a.ngay_cap),
       PKH_SO_CNG(b.ngay_hl),PKH_SO_CNG(b.ngay_kt),a.ma_kt,FBH_TK_KT_TEN(a.ma_kt,a.kieu_kt),a.loai_kh,
       b.hang,b.hieu,b.pban,b.so_cn,b.ttai,'NGAY_TAI',c.ma_dk,c.ten,c.ma_ct,
       PKH_TEN_TENl(FBH_HD_TXT('XE',a.ma_dvi,a.so_id,'ma_kenh')),FBH_HD_TXT('XE',a.ma_dvi,a.so_id,'kieu_gt'),FBH_HD_TXT('XE',a.ma_dvi,a.so_id,'ma_gt'),c.bt
      FROM bh_xe a
      JOIN bh_xe_ds b ON a.ma_dvi = b.ma_dvi AND a.so_id  = b.so_id
      JOIN bh_xe_dk c ON b.ma_dvi = c.ma_dvi AND b.so_id  = c.so_id AND b.so_id_dt  = c.so_id_dt
      WHERE a.ma_dvi = b_ma_dvT and c.lh_nv <> ' ' AND a.ngay_kt >= b_ngay_ht AND a.ngay_cap BETWEEN b_ngayd AND b_ngayc
      ORDER BY a.so_hd,b.so_id_dt,c.bt;
else
  insert into temp_1(n1,n2,c1,c2,c3,c5,c6,c11,n3,c12,c13,c14,n4,n5,n6,c15,c16,c17,c18,c19,c20,c21,
                     c22,c23,c25,c27,n7,n8,c31,c33,c34,c35,c36,c37,c38,n10)
    select /*+ LEADING(a b) */ b.so_id,b.so_id_dt,a.ma_dvi,a.so_hd,b.gcn,a.ma_kh,a.ten,
       b.loai_xe,b.nam_sx,b.bien_xe,b.so_khung,b.so_may,a.ttoan,a.phi,c.thue,c.ma_dk,PKH_SO_CNG(a.ngay_ht),PKH_SO_CNG(a.ngay_cap),
       PKH_SO_CNG(b.ngay_hl),PKH_SO_CNG(b.ngay_kt),a.ma_kt,FBH_TK_KT_TEN(a.ma_kt,a.kieu_kt),a.loai_kh,
       b.hang,b.hieu,b.pban,b.so_cn,b.ttai,'NGAY_TAI',c.ma_dk,c.ten,c.ma_ct,
       PKH_TEN_TENl(FBH_HD_TXT('XE',a.ma_dvi,a.so_id,'ma_kenh')),FBH_HD_TXT('XE',a.ma_dvi,a.so_id,'kieu_gt'),FBH_HD_TXT('XE',a.ma_dvi,a.so_id,'ma_gt'),c.bt
      FROM bh_xe a
      JOIN bh_xe_ds b ON a.ma_dvi = b.ma_dvi AND a.so_id  = b.so_id
      JOIN bh_xe_dk c ON b.ma_dvi = c.ma_dvi AND b.so_id  = c.so_id AND b.so_id_dt  = c.so_id_dt
      WHERE a.ma_dvi = b_ma_dvT and c.lh_nv <> ' ' AND a.ngay_cap BETWEEN b_ngayd AND b_ngayc
      ORDER BY a.so_hd,b.so_id_dt,c.bt;
end if;
-- thong tin sdbs
UPDATE temp_1 set (c4,c7,c8,c9,c10,c29,c30) = (select a.so_hd,PKH_MA_TENl(FBH_HD_TXT('XE',a.ma_dvi,a.so_id,'ma_sdbs')),
              PKH_TEN_TENl(FBH_HD_TXT('XE',a.ma_dvi,a.so_id,'ma_sdbs')),PKH_MA_TENl(FBH_HD_TXT('XE',a.ma_dvi,a.so_id,'ndung')),
              a.ttrang,PKH_SO_CNG(a.ngay_hl),PKH_SO_CNG(a.ngay_kt) from bh_xe a where a.so_id_g = n1 AND ROWNUM=1);
             
-- thong tin so gcn    
UPDATE temp_1 set (c32) = (select decode(c3,b.gcn,' ',b.gcn) from bh_xe a, bh_xe_ds b where 
                                  a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and 
                                  b.so_id_dt=n2 and a.so_id_g = n1);          
-- ten xe hang xe/ hieu/pb
UPDATE temp_1 a
   SET c24 = (SELECT t.ten FROM bh_xe_hang t WHERE t.ma = a.c23),
       c26 = (SELECT t.ten FROM bh_xe_hieu t WHERE t.ma = a.c25),
       c28 = (SELECT t.ten FROM bh_xe_pb t   WHERE t.ma = a.c27);
-- ngay tai
update temp_1 set c31 = (SELECT CASE WHEN MAX(ngay_cap) IS NULL THEN ' ' ELSE PKH_SO_CNG(MAX(ngay_cap)) END AS ngay_cap_fmt
                            FROM bh_xe a WHERE a.so_hd_g = c2 AND a.kieu_hd = 'T' AND a.ttrang = 'D');
-- thay doi mtn + phi theo ty le dong
update temp_1 set (n4,n5,n6,n9) = (select n4*giu, n5*giu, n6*giu, giu from (
                                    select nvl(FBH_HD_DO_NH_TXT(b.ma_dvi,b.so_id,a.nhom,'giu'),1) giu from bh_hd_do_nh a,bh_hd_do_nh_txt b 
                                           where a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and
                                                 a.ma_dvi=c1 and a.so_id=n1 and loai='dt_ct')); -- dong theo don

open cs1 for select c1 ma_cn,c2 so_hd,c3 so_gcn,c4 so_sdbs,c5 ma_kh,c6 ten_kh,c7 ma_loai_sdbs,c8 ten_loai_sdbs,c9 noi_dung_sdbs,
                    c10 ttrang_sdbs, c11 ma_loai_xe,n3 nam_sx,c12 bien_ksoat,c13 so_khung,c14 so_may,
                    c15 ma_lhnv,n4 muc_trach_nhiem,n5 phi_truoc_thue,n6 thue,c16 ngay_nhap,c17 ngay_duyet,c18 hieu_luct,c19 hieu_lucd,
                    c20 ma_kt,c21 ten_kt,c22 ten_loai_kh,c23 ma_hang_xe,c24 ten_hang_xe,c25 ma_hieu_xe, c26 ten_hieu_xe,
                    c27 ma_pb_xe,c28 ten_pb_xe,n7 so_cho,n8 trong_tai,c29 hieu_luct_sdbs,c30 hieu_lucd_sdbs,c31 ngay_ky_tai,c32 so_gcn_sdbs,
                    c33 ma_dk,c34 ten_dk,c35 ma_dk_ct,c36 kenh_ban,c37 ma_kenh_pp,c38 ten_kenh_pp,n9 ty_le_dong
             from temp_1 order by c2,n1,n2,n10;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_TK_SDBS
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngayd number,b_ngayc number,
        b_ma_dvT varchar2,b_loai_kh varchar2,b_ma_kh varchar2,b_ma_sp varchar2,
        b_ma_lhnv varchar2,b_phong varchar2,b_ma_cb varchar2,tien_tu number,tien_den number,
        b_ttrang varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);b_i1 number; b_ngay_ht number:=PKH_NG_CSO(SYSDATE);
begin
-- Dan - Liet ke cac hop dong no phi
delete temp_1;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;

insert into temp_1(n1,n2,c1,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,n3,c16,c17,c18,c19,c20,c21,c22,n4,n5,c24,c2,n6,n7,n8,n9,n10)
    SELECT t.so_id,t.so_id_dt,a.ma_dvi,a.so_hd,NVL(REGEXP_SUBSTR(a.so_hd, '/B([0-9]+)', 1, 1, NULL, 1), '0'),a.so_hd_g,
         PKH_MA_TENl(FBH_HD_TXT('XE',a.ma_dvi,a.so_id,'ma_sdbs')),PKH_TEN_TENl(FBH_HD_TXT('XE',a.ma_dvi,a.so_id,'ma_sdbs')),PKH_MA_TENl(FBH_HD_TXT('XE',a.ma_dvi,a.so_id,'ndung')),
         PKH_MA_TENl(FBH_HD_TXT('XE',a.ma_dvi,a.so_id,'ma_khh')),PKH_TEN_TENl(FBH_HD_TXT('XE',a.ma_dvi,a.so_id,'tenh')),
         PKH_SO_CNG(a.ngay_ht),PKH_SO_CNG(a.ngay_cap),PKH_SO_CNG(t.ngay_hl),PKH_SO_CNG(t.ngay_kt),t.loai_xe,t.nam_sx,t.bien_xe,t.so_khung,t.so_may,
         a.ma_kt,FBH_TK_KT_TEN(a.ma_kt,a.kieu_kt),a.loai_kh,nvl(ksoat,nsd),t.so_cn,t.ttai,a.ttrang,
         t1.lh_nv,t1.tien,t1.phi,t1.t_suat,t1.thue,t1.phi+t1.thue
    FROM bh_xe a,bh_xe_ds t,bh_xe_dk t1
    WHERE a.ma_dvi = b_ma_dvT and a.ma_dvi = t.ma_dvi AND a.so_id = t.so_id AND a.kieu_hd='B'
    AND t.so_id=t1.so_id and t.so_id_dt=t1.so_id_dt AND b_ma_sp in ('*',t.ma_sp) AND b_ttrang in ('*',a.ttrang) AND a.ngay_ht BETWEEN b_ngayd AND b_ngayc;

-- c22 ten nguoi duyet
update temp_1 set c23=(select ten from ht_ma_nsd where ma=c22);
--update temp_2
open cs1 for select c1 ma_cn,c2 ma_nv,c3 so_hd,c4 lan_sdbs,c5 so_sdbs,c6 ma_loai_sdbs,c7 ten_loai_sdbs,c8 noi_dung_sdbs,c9 ma_nguoid,c10 ten_nguoid,
                    c11 ngay_nhap, c12 ngay_duyet,c13 hieu_luct,c14 hieu_lucd,c15 ma_loai_xe,n3 nam_sx,c16 bien_ksoat,c17 so_khung,c18 so_may,
                    n6 muc_trach_nhiem,n7 phi_truoc_thue,n8 thue_suat,n9 thue,n10 phi_sau_thue,c19 ma_kenh_pp,c20 ten_kenh_pp,c21 ten_loai_kh,
                    c22 ma_nguoi_duyet,c23 ten_nguoi_duyet,n4 so_cho,n5 trong_tai,c24 ttrang
             from temp_1 order by c3,c5;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_TK_KT_TEN(b_ma varchar2, b_kieu_kt varchar2) return varchar2
AS
    b_kq varchar2(500);
begin
-- Dan - Tra ten
if b_kieu_kt = 'T' then
    select min(ten) into b_kq from ht_ma_cb where ma=b_ma;
else
    select FBH_DTAC_MA_TEN(b_ma) into b_kq from dual;
end if;
return b_kq;
end;