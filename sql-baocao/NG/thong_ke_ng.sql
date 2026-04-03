create or replace procedure PBH_NG_TK_BT_DUYET
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngayd number,b_ngayc number,
        b_ma_dvT varchar2,b_ttrang varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);b_i1 number; b_nv varchar2(2):='NG';
begin
-- Dan - Liet ke cac hop dong no phi
delete temp_1;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
-- danh sach ho so boi thuong theo khoang thoi gian
insert into temp_1(n1,n2,n3,c1,c3,c4,c5,c6,c7,c8,c9,c10,n5,c12,c13,c14,c15,c16)
    select t.so_id,t.so_id_dt,t.so_id_hd,t.ma_dvi,FBH_HD_TXT('NG',t.ma_dvi,t.so_id_hd,'ma_sp'),t.so_hs,t.so_hd,t.ma_khh,t.tenh,
       PKH_SO_CNG(t.ngay_mo),PKH_SO_CNG(t.ngay_xr),PKH_SO_CNG(t.ngay_gui),t.tien,PKH_SO_CNG(t.ngay_qd),t.n_duyet,
       FBH_BT_NG_TXT(t.ma_dvi,t.so_id,'nhg_tk'),case when t.ngay_do not in (0,30000101) then 'Y' else 'N' end,PKH_SO_CNG(t.ngay_do)
       from bh_bt_ng t where b_ma_dvT in ('*',t.ma_dvi) and ttrang='D' and t.ngay_gui between b_ngayd and b_ngayc;
-- C2 ten don vi
update temp_1 set c2 = (select ten from ht_ma_dvi where ma=c1);
-- C11 N4 thong tin du phong
update temp_1 set (c11,n4)=(select PKH_SO_CNG(ngay_dp),tien from bh_bt_hs_dp where n1=so_id and nv='NG');

-- lay theo dieu khoan bt
open cs1 for select c1 ma_cn, c2 ten_cn, c3 ma_sp, c4 so_hsbt, c5 so_hd, c6 ma_kh, c7 ten_kh, c8 ngay_mo, c9 ngay_xay_ra, c10 ngay_thong_bao,
                    c11 ngay_dp,n4 tien_dp, n5 tien, c12 ngay_duyet, c13 nguoi_duyet, c14 so_tk, c15 dong, c16 ngay_dong
             from temp_1 order by c1,c5;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NG_TK_BT_CHO
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngayd number,b_ngayc number,
        b_ma_dvT varchar2,b_ttrang varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);b_i1 number; b_nv varchar2(2):='NG';
begin
-- Dan - Liet ke cac hop dong no phi
delete temp_1;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
-- danh sach ho so boi thuong theo khoang thoi gian
insert into temp_1(n1,n2,n3,c1,c3,c4,c5,c6,c7,c8,c9,c10,n5,c14)
    select t.so_id,t.so_id_dt,t.so_id_hd,t.ma_dvi,FBH_HD_TXT('NG',t.ma_dvi,t.so_id_hd,'ma_sp'),t.so_hs,t.so_hd,t.ma_khh,t.tenh,
       PKH_SO_CNG(t.ngay_mo),PKH_SO_CNG(t.ngay_xr),PKH_SO_CNG(t.ngay_gui),t.tien,FBH_BT_NG_TXT(t.ma_dvi,t.so_id,'nhg_tk')
       from bh_bt_ng t where b_ma_dvT in ('*',t.ma_dvi) and ttrang<>'D' and t.ngay_gui between b_ngayd and b_ngayc;
-- C2 ten don vi
update temp_1 set c2 = (select ten from ht_ma_dvi where ma=c1);
-- C11 N4 thong tin du phong
update temp_1 set (n4)=(select tien from bh_bt_hs_dp where n1=so_id and nv='NG');

-- lay theo dieu khoan bt
open cs1 for select c1 ma_cn, c2 ten_cn, c3 ma_sp, c4 so_hsbt, c5 so_hd, c6 ma_kh, c7 ten_kh, c8 ngay_mo, c9 ngay_xay_ra, c10 ngay_thong_bao,
                    n4 tien_dp, 0 tien, ROUND(n4-n5,2) tien_dp_con_lai, c14 nhg_tk
             from temp_1 order by c1,c5;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NG_TK_HDNT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngayd number,b_ngayc number,
        b_ma_dvT varchar2,b_ttrang varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);b_i1 number; b_nv varchar2(2):='NG';
begin
-- Dan - Liet ke cac hop dong no phi
delete temp_1;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
-- danh sach ho so boi thuong theo khoang thoi gian
insert into temp_1(n1,n2,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,n3)
    select t2.so_id,t2.so_id_dt,to_char(t.ngay_nh,'dd/mm/yyyy'),PKH_SO_CNG(t.ngay_cap),t1.so_hd,t.so_hd,
       t.kieu_kt,FBH_TK_KT_TEN(t.ma_kt,t.kieu_kt),t.ten,FBH_HD_TXT('NG',t.ma_dvi,t.so_id,'ma_sp'),t2.gcn,t2.ten,PKH_SO_CNG(t2.ng_sinh),t2.gioi,t3.goi,
       PKH_SO_CNG(t2.ngay_hl),PKH_SO_CNG(t2.ngay_kt),t5.ten ten_cb,t4.ten ten_dvi,t2.phi
       from bh_sk t,bh_skN t1,bh_sk_ds t2,bh_sk_nh t3,ht_ma_dvi t4,ht_ma_nsd t5 where b_ma_dvT in ('*',t.ma_dvi) and t.ma_dvi=t1.ma_dvi and t.so_hd_g=t1.so_hd
       and t.ma_dvi=t2.ma_dvi and t.so_id=t2.so_id and t2.so_id=t3.so_id and t2.nhom=t3.nhom and t.ma_dvi=t4.ma and t.nsd=t5.ma and t.ngay_cap between b_ngayd and b_ngayc;
update temp_1 set c18 = (select ten from bh_sk_goi where ma=c13);
insert into temp_1(n1,n2,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,n3)
    select t2.so_id,t2.so_id_dt,to_char(t.ngay_nh,'dd/mm/yyyy'),PKH_SO_CNG(t.ngay_cap),t1.so_hd,t.so_hd,
       t.kieu_kt,FBH_TK_KT_TEN(t.ma_kt,t.kieu_kt),t.ten,FBH_HD_TXT('NG',t.ma_dvi,t.so_id,'ma_sp'),t2.gcn,t2.ten,PKH_SO_CNG(t2.ng_sinh),t2.gioi,t3.goi,
       PKH_SO_CNG(t2.ngay_hl),PKH_SO_CNG(t2.ngay_kt),t5.ten ten_cb,t4.ten ten_dvi,t2.phi
       from bh_ngdl t,bh_ngdlN t1,bh_ngdl_ds t2,bh_ngdl_nh t3,ht_ma_dvi t4,ht_ma_nsd t5 where b_ma_dvT in ('*',t.ma_dvi) and t.ma_dvi=t1.ma_dvi and t.so_hd_g=t1.so_hd
       and t.ma_dvi=t2.ma_dvi and t.so_id=t2.so_id and t2.so_id=t3.so_id and t2.nhom=t3.nhom and t.ma_dvi=t4.ma and t.nsd=t5.ma and t.ngay_cap between b_ngayd and b_ngayc;
update temp_1 set c18 = (select ten from bh_ngdl_goi where ma=c13);
       
-- lay theo dieu khoan bt
open cs1 for select c1 ngay_tao, c2 ngay_cap, c3 so_hdnt, c4 so_hd, c5 kieu_khai_thac, c6 ten_khai_thac, c7 ten_kh, c8 ma_sp, c9 so_gcn,
                    c10 ten_nguoi_duoc_bh, c11 ngay_sinh_nguoi_duoc_bh, c12 gioi_tinh_nguoi_duoc_bh, c14 ngay_hl, c15 ngay_kt,
                    c16 can_bo_ql, c17 don_vi_ql,c18 ma_goi,n3 phi
             from temp_1 order by c3,c4;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NG_TK_BT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngayd number,b_ngayc number,
        b_ma_dvT varchar2,b_ttrang varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_i1 number; b_nv varchar2(2):='NG'; a_id_bt pht_type.a_num;
    a_grv pht_type.a_clob; a_grv_ma pht_type.a_var;a_grv_nd pht_type.a_nvar;
    a_dk pht_type.a_clob; a_dk_id pht_type.a_num; a_dk_ma pht_type.a_var; a_dk_btcon pht_type.a_num; a_dk_nd pht_type.a_clob;
begin
-- Dan - Liet ke cac hop dong no phi
delete temp_1;delete temp_2;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
-- danh sach ho so boi thuong theo khoang thoi gian
-- c20 luu ma --> lay ra cac cap con
insert into temp_1(n1,n2,n3,c1,c3,c4,c5,c6,c7,c9,c10,c11,c20,c21,n9)
    select t.so_id,t1.so_id_d,t.so_id_hd,t.ma_dvi,t1.ten,t.so_hd,t2.ten,PKH_SO_CNG(t1.ngay_hl),PKH_SO_CNG(t1.ngay_kt),
       PKH_SO_CNG(t2.ng_sinh),PKH_SO_CNG(t.ngay_gui),t3.ten,t3.ma,t.so_hs,t.so_id_dt
       from bh_bt_ng t, bh_ng t1,bh_ng_ds t2,bh_bt_ng_dk t3
       where b_ma_dvT in ('*',t.ma_dvi) and t.ma_dvi=t1.ma_dvi and t.so_id_hd=t1.so_id
       and t.so_id_hd=t2.so_id and t.so_id_dt=t2.so_id_dt and t.so_id=t3.so_id and t3.lh_nv <> ' ' and t3.tien > 0
       and t.ngay_gui between b_ngayd and b_ngayc
       order by t.so_id,t2.so_id_dt;
-- c12,c13,n4,n5,n6,n7 thong tin tien bt
insert into temp_2(n1,n2,n3,c1,c3,c4,c5,c6,c7,c9,c10,c11,c20,c21,c12,c13,n4,n5,n6,n7)
 select t.n1,t.n2,t.n3,t.c1,t.c3,t.c4,t.c5,t.c6,t.c7,t.c9,t.c10,t.c11,t.c20,t.c21,t1.ten,t1.ma,t1.t_that,t1.tien,t1.t_that-t1.tien,t2.tien
       from temp_1 t,bh_bt_ng_dk t1,bh_ng_dk t2 where t.n1=t1.so_id and t.c20=t1.ma_ct and t.n3=t2.so_id and t.n9=t2.so_id_dt and t1.ma=t2.ma and t1.tien > 0;
-- C2 ten don vi
update temp_2 set c2 = (select ten from ht_ma_dvi where ma=c1);
-- c8 ngay dau
update temp_2 set c8=(select PKH_SO_CNG(ngay_hl) from bh_ng where so_id=n2);
-- c14,c15,c16 giay ra vien
update temp_2 set (c14,c15,c16)=(select FBH_BT_NG_GRV_TXT(b_ma_dvT,n1,'ten'),PKH_SO_CNG(FBH_BT_NG_GRV_TXT(b_ma_dvT,n1,'ng_vao')),
                  PKH_SO_CNG(FBH_BT_NG_GRV_TXT(b_ma_dvT,n1,'ng_ra')) from bh_bt_ng_txt where so_id=n1 and loai='dt_grv');
-- c17 chuan doan
update temp_2 set c17=(select txt from bh_bt_ng_txt where so_id=n1 and loai='dt_ttt');
select n1,FKH_JS_BONH(c17) bulk collect into a_id_bt,a_grv from temp_2;
for b_lp in 1..a_grv.count loop
    if a_grv(b_lp)= '' then continue; end if;
    b_lenh:=FKH_JS_LENH('ma,nd');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_grv_ma,a_grv_nd using a_grv(b_lp);
    for b_lp1 in 1..a_grv_ma.count loop
        if a_grv_ma(b_lp1) <> 'CDOAN' then continue; end if;
        update temp_2 set c17=a_grv_nd(b_lp1) where n1=a_id_bt(b_lp);
    end loop;
end loop;
-- n8,c19 bt con, mo ta ton that
select t1.so_id,FKH_JS_BONH(t1.txt) bulk collect into a_dk_id,a_dk from temp_2 t,bh_bt_ng_txt t1 where t.n1=t1.so_id and loai='dt_dk';
for b_lp in 1..a_dk_id.count loop
  b_lenh:=FKH_JS_LENH('ma,bt_con,nd');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_dk_ma,a_dk_btcon,a_dk_nd using a_dk(b_lp);
  for b_lp1 in 1..a_dk_ma.count loop
      update temp_2 set n8=a_dk_btcon(b_lp1),c19=a_dk_nd(b_lp1) where n1=a_dk_id(b_lp) and c13=a_dk_ma(b_lp1);
  end loop;
end loop;
-- C18 NGAY THANH TOAN
update temp_2 set c18=(select to_char(ngay_nh,'dd/mm/yyyy') from bh_bt_tt where so_hs=c21);
-- C20 ngay thanh toan dau tien
update temp_2 set (c20)=(select PKH_SO_CNG(min(ngay)) from bh_hd_goc_tt where ma_dvi=c1 and so_id=n3);

-- lay theo dieu khoan bt
open cs1 for select c2 ten_cn, c3 ten_nguoim, c4 so_hd, c5 ten_nguoid, c6 ngay_hl, c7 ngay_kt, c8 ngay_hd_dau, c9 ngay_sinh_nguoid, c10 ngay_bao,
                    c11 ten_dk_chinh,c12 ten_dk_phu,c13 ma_dk_phu,c14 ten_benh_vien,c15 ngay_vao_vien,c16 ngay_xuat_vien,c17 chuan_doan,n4 ton_that,
                     n5 tien, n6 tien_loai_tru, n7 muc_trach_nhiem, n8 bt_con, c18 ngay_thanh_toan, c19 mo_ta_ton_that,c20 ngay_nop_phi
             from temp_2 order by c1,c4,c13;
delete temp_1; delete temp_2; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/