create or replace procedure BC_BH_BOITHUONG_TK_HH
    (b_madvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ma_dvi varchar2,b_ma_nv varchar2,b_phong varchar2,b_so_hd varchar2,b_loai_kh varchar2,
    b_ma_kh varchar2,b_ttrang varchar2,b_tiend number,b_tienc number,
    b_ngayd number,b_ngayc number,cs_kq out pht_type.cs_type)
as
    b_loi varchar2(100);b_ngaydn number; b_i1 number;b_ttrang1 varchar2(10);
begin
b_loi:=fht_ma_nsd_ktra(b_madvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise program_error; end if;
delete temp_1;delete temp_2;commit;
pbc_lay_dvi(b_madvi,b_ma_dvi,b_nsd,b_pas,b_loi);
if b_loi is not null then raise program_error; end if;
if fht_ma_nsd_phong(b_ma_dvi,b_nsd)='TBH' then
    b_loi:='loi:ban khong co quyen xem bao cao:loi';
    raise program_error;
end if;

if b_ngayd is null or b_ngayc is null then
    b_loi:='loi:nhap ngay bao cao:loi'; raise program_error;
end if;
b_ngaydn:=round(b_ngayd,-4)+101;b_loi:='loi:ma chua dang ky:loi';
insert into temp_1(n8,n1,c1,c2,n9,c4,c5,n2,n3,n4,n5,n6,n7)
select
  bt.so_id, --n8
  bt.ngay_gui, --n1
  bt.so_hs, -- c1
  bt.ten, -- c2
  bt.so_id_hd, --n9
  '' ten_hang, -- c4
  p.ten_pt ptvc, --c5
  dk.t_that, --n2
  0 stgd_kn, -- n3
  0 tong_kn,   --n4
  dk.tien, --n5
  0 stgd_bt, --n6
  0 tong_bt -- n7
  from bh_bt_hs bt
  join bh_hang_ptvc p on p.so_id = bt.so_id_hd
  join bh_bt_hang bth on bth.so_id_hd = bt.so_id_hd
  join bh_bt_hang_dk dk on dk.so_id = bt.so_id
  where bt.nv = 'HANG'
  and bt.ngay_ht BETWEEN b_ngayd AND b_ngayc
  and bt.ma_dvi=bt.ma_dvi
  and (b_ma_dvi is null or bt.ma_dvi = b_ma_dvi) and (b_ma_kh is null or bt.ma_kh = b_ma_kh)
  and (b_phong is null or bt.phong = b_phong) order by bt.ngay_ht,bt.so_hd;

update temp_1 set c4 = (SELECT LISTAGG(ten_hang, ';') WITHIN GROUP (ORDER BY ten_hang)
                FROM (select * from bh_hang_ds where so_id = temp_1.n9 and ma_dvi = b_ma_dvi));
update temp_1 set n3 = (select sum(ttoan) from bh_bt_gd_hs where so_id_bt = temp_1.n8 and ma_dvi = b_ma_dvi and ttrang in ('D', 'S'));
update temp_1 set n6 = (select sum(ttoan) from bh_bt_gd_hs where so_id_bt = temp_1.n8 and ma_dvi = b_ma_dvi and ttrang='D');

OPEN CS_KQ FOR SELECT rownum as stt, PKH_SO_CNG(n1) ngay_nhan, c1 as so_hs_bt, c2 as ten_kh, c4 as ten_hang, c5 as ptvc, FBH_CSO_TIEN_KNT(n2) as sttt_kn,
    FBH_CSO_TIEN_KNT(n3) as stgd_kn, FBH_CSO_TIEN_KNT(n2+n3) as tong_kn,FBH_CSO_TIEN_KNT(n5) as sttt_bt,FBH_CSO_TIEN_KNT(n6) as stgd_bt,FBH_CSO_TIEN_KNT(n5+n6) as tong_bt from temp_1;

exception when others then raise_application_error(-20105,b_loi);
end;
