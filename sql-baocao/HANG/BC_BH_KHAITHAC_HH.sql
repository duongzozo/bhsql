CREATE OR REPLACE PROCEDURE BC_BH_KHAITHAC_HH
    (b_madvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ma_dvi varchar2,b_ma_nv varchar2,b_phong varchar2,b_loai_kh varchar2,
    b_ma_kh varchar2,b_ma_cb varchar2,b_tc varchar2,b_ttrang varchar2,
    b_ngayd number,b_ngayc number,cs_kq out pht_type.cs_type)
AS
    b_loi varchar2(100); b_ngaydn number; b_n1 number; b_n2 number; b_i1 number; b_ttrang1 varchar2(10);
Begin
  IF B_NGAYD IS NULL OR B_NGAYC IS NULL THEN
	B_LOI:='loi:Nhap ngay bao cao:loi'; RAISE PROGRAM_ERROR;
  END IF;
  B_NGAYDN:=ROUND(B_NGAYD,-4)+101;
  DELETE TEMP_1; COMMIT;
  PBC_LAY_DVI(B_MADVI,B_MA_DVI,B_NSD,B_PAS,B_LOI);
  IF B_LOI IS NOT NULL THEN RAISE PROGRAM_ERROR; END IF;
  INSERT INTO temp_1(n1,c1,n2,c2,c3,n3,c4,c5,c6,c7,c8,c9,c10,c11,n4,n5,n6,n7,c12,c13,c29)
  SELECT
    h.so_id, --n1
    h.so_hd, --c1
    h.ngay_cap, --n2
    h.ten as ten_kh, --c2
    ds.ten_hang, --c3
    ds.sluong as sl_hh, -- n3
    ds.dgoi AS pthuc, -- c4
    p.ten_pt AS ptien,-- c5
    h.ngay_hl AS ngay_kh,-- c6
    h.cang_di as tu,-- c7
    h.c_ctai as ctai,-- c8
    h.cang_den as den,-- c9
    h.nt_tien,-- c10
    h.nt_phi as ma_nt,-- c11
    ds.phi,-- n4
    ds.mtn as tien_bh,-- n5
    ds.ttoan as phi_c,-- n6
    ds.ttoan as phi_p,-- n7
    h.qtac as ma_dk, -- c12
    ds.ma_lhang as ma_hang, -- c13
    h.ma_dvi as ma_dvi -- c29
  FROM bh_hang h
  join bh_hang_ptvc p on p.so_id = h.so_id
  JOIN (
    SELECT
      ds.ma_dvi,
      ds.so_id,
      ds.mtn,
      ds.ten_hang,
      ds.sluong,
      dk.phi,
      dk.ttoan,
      ds.ma_lhang,
      ds.dgoi
    FROM bh_hang_ds ds
    JOIN bh_hang_dk dk ON ds.so_id = dk.so_id AND ds.ma_lhang = dk.ma_hang
  ) ds ON ds.so_id = h.so_id AND ds.ma_dvi = h.ma_dvi
  WHERE
    h.ma_dvi =b_madvi
    and h.kieu_hd not in ('V','N')
    and h.ngay_cap BETWEEN b_ngayd AND b_ngayc
    and (b_ma_kh is null or h.ma_kh = b_ma_kh)
    and (b_phong is null or h.phong = b_phong);

  UPDATE temp_1 SET n6=(select NVL(sum(ttoan),0) from bh_hang_dk where so_id = temp_1.n1 and tc='T' and ma_hang like '%'|| temp_1.c13 ||'%');
  UPDATE temp_1 SET n7=(select NVL(sum(ttoan),0) from bh_hang_dk where so_id = temp_1.n1 and tc='C' and ma_hang like '%'|| temp_1.c13 ||'%');
  UPDATE temp_1 SET c4=(select nvl(ten,' ') from bh_hang_dgoi where ma = temp_1.c4);
  UPDATE temp_1 SET c7=(select nvl(ten,' ') from bh_ma_nuoc where ma = temp_1.c7);
  UPDATE temp_1 SET c9=(select nvl(ten,' ') from bh_ma_nuoc where ma = temp_1.c9);
  UPDATE temp_1 SET c20= FBH_HANG_TXT(c29,n1,'ndungd');

  OPEN cs_kq FOR
  SELECT rownum as stt, n1 as so_id,c1 as so_hd,PKH_SO_CNG(n2) as ngay_cap,c2 as ten_kh,c3 as ten_hang,n3 as sl_hh,c4 as pthuc,c5 as ptien,PKH_SO_CNG(c6) as ngay_kh,
  c7 as tu,c8 as ctai,c9 as den ,c10 as nt_tien,c11 as ma_nt,n4 as phi,FBH_CSO_TIEN_KNT(n5) as tien_bh,FBH_CSO_TIEN_KNT(n6) as phi_c,FBH_CSO_TIEN_KNT(n7) as phi_p,
  FBH_CSO_TIEN_KNT(n6+n7) as phi_t  ,c12 as ma_dk,c20 dk_rieng
  FROM temp_1 order by n2;
  delete temp_1;
  commit;
end;
