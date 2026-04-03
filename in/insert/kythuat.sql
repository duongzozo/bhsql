---PKT
delete from bh_in_gcn_tso where nv = 'PKT_B_HD'
/
COMMIT
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA)
values ('PKT_B_HD', N'Bản chào phí HĐ Bảo hiểm xây dựng lắp đặt', '~\\mauin\\mauinhd\\kythuat\\Hopdong\\B_HOP DONG BAO HIEM XAY DUNG LAP DAT.xml', 'IN_B_HD_XDLD', 'B_HDXDLD')
/
COMMIT
/
delete from bh_in_gcn_tso where nv = 'PKT_HD'
/
COMMIT
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'Thông báo thu phí bảo hiểm', '~\\mauin\\mauinhd\\thuphi\\Mau_Thong_bao_thu_phi.docx', 'IN_TBTP', 'PKT_HD_001', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'Debit note', '~\\mauin\\mauinhd\\thuphi\\Debit_note.docx', 'IN_TBTP', 'PKT_HD_002', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'BH xây dựng bắt buộc', '~\\mauin\\mauinhd\\kythuat\\Hopdong\\01.HDBH_XDBB.docx', 'IN_HD_XDLD', 'PKT_HD_003', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'BH Công trình dân dụng hoàn thành', '~\\mauin\\mauinhd\\kythuat\\Hopdong\\01.HDBH_Cong_trinh_dan_dung_hoan_thanh.docx', 'IN_HD_XDLD', 'PKT_HD_004', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'BH Mọi rủi ro lắp đặt', '~\\mauin\\mauinhd\\kythuat\\Hopdong\\01.HDBH_Moi_rui_ro_lap_dat.docx', 'IN_HD_XDLD', 'PKT_HD_005', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'BH Mọi rủi ro xây dựng', '~\\mauin\\mauinhd\\kythuat\\Hopdong\\01.HDBH_Moi_rui_ro_xay_dung.docx', 'IN_HD_XDLD', 'PKT_HD_006', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'BH Lắp đặt bắt buộc', '~\\mauin\\mauinhd\\kythuat\\Hopdong\\01.HDBH_LDBB.docx', 'IN_HD_XDLD', 'PKT_HD_007', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'BH Đổ vỡ máy móc', '~\\mauin\\mauinhd\\kythuat\\Hopdong\\06.HDBH_do_vo_may_moc.docx', 'IN_HD_XDLD', 'PKT_HD_008', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'BH Máy móc thiết bị chủ thầu', '~\\mauin\\mauinhd\\kythuat\\Hopdong\\06.HDBH_may_moc_tbi_chu_thau.docx', 'IN_HD_XDLD', 'PKT_HD_009', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'BH Lắp đặt bắt buộc phần thiệt hại vật chất', '~\\mauin\\mauinhd\\kythuat\\Hopdong\\01.HDBH_LDBB_thiet_hai_vat_chat.docx', 'IN_HD_XDLD', 'PKT_HD_010', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'BH Mọi rủi ro lắp đặt phần thiệt hại vật chất', '~\\mauin\\mauinhd\\kythuat\\Hopdong\\01.HDBH_Moi_rui_ro_lap_dat_thiet_hai_vat_chat.docx', 'IN_HD_XDLD', 'PKT_HD_011', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'BH Mọi rủi ro xây dựng mở rộng mất lợi nhuận', '~\\mauin\\mauinhd\\kythuat\\Hopdong\\01.HDBH_Moi_rui_ro_xay_dung_mo_rong_mat_loi_nhuan.docx', 'IN_HD_XDLD', 'PKT_HD_012', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'BH Mọi rủi ro xây dựng mở rộng trách nhiệm bên thứ ba', '~\\mauin\\mauinhd\\kythuat\\Hopdong\\01.HDBH_Moi_rui_ro_xay_dung_mo_rong_trach_nhiem.docx', 'IN_HD_XDLD', 'PKT_HD_013', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'BH Mọi rủi ro xây dựng phần thiệt hại vật chất', '~\\mauin\\mauinhd\\kythuat\\Hopdong\\01.HDBH_Moi_rui_ro_xay_dung_thiet_hai_vat_chat.docx', 'IN_HD_XDLD', 'PKT_HD_014', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'BH Xây dựng bắt buộc mở rộng mất lợi nhuận', '~\\mauin\\mauinhd\\kythuat\\Hopdong\\01.HDBH_XDBB_mo_rong_mat_loi_nhuan.docx', 'IN_HD_XDLD', 'PKT_HD_015', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'BH Xây dựng bắt buộc mở rộng trách nhiệm bên thứ ba', '~\\mauin\\mauinhd\\kythuat\\Hopdong\\01.HDBH_XDBB_mo_rong_trach_nhiem.docx', 'IN_HD_XDLD', 'PKT_HD_016', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'BH Xây dựng bắt buộc phần thiệt hại vật chất', '~\\mauin\\mauinhd\\kythuat\\Hopdong\\01.HDBH_XDBB_thiet_hai_vat_chat.docx', 'IN_HD_XDLD', 'PKT_HD_017', null)
/
--
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'BH hàng hóa trong kho lạnh', '~\\mauin\\mauinhd\\kythuat\\Hopdong\\06.HDBH_hang_hoa_trong_kho_lanh.docx', 'IN_HD_XDLD', 'PKT_HD_018', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'BH máy móc thiết bị cho thuê', '~\\mauin\\mauinhd\\kythuat\\Hopdong\\06.HDBH_may_moc_thiet_bi_cho_thue.docx', 'IN_HD_XDLD', 'PKT_HD_019', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'BH thiết bị điện tử', '~\\mauin\\mauinhd\\kythuat\\Hopdong\\06.HDBH_thiet_bi_dien_tu.docx', 'IN_HD_XDLD', 'PKT_HD_020', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'BH máy móc toàn diện mở rộng Gián đoạn kinh doanh', '~\\mauin\\mauinhd\\kythuat\\Hopdong\\06.HDBH_may_moc_toan_dien_GDKD.docx', 'IN_HD_XDLD', 'PKT_HD_021', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'BH máy móc toàn diện phần Thiệt hại vật chất', '~\\mauin\\mauinhd\\kythuat\\Hopdong\\06.HDBH_may_moc_toan_dien_THVC.docx', 'IN_HD_XDLD', 'PKT_HD_022', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'BH nồi hơi', '~\\mauin\\mauinhd\\kythuat\\Hopdong\\01.HDBH_Noi_hoi.docx', 'IN_HD_XDLD', 'PKT_HD_023', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'GCNBH Xây dựng bắt buộc mở rộng TN bên thứ ba và mất lợi nhuận', '~\\mauin\\mauinhd\\kythuat\\GCN\\GCN_BH_XDBB.docx', 'IN_HD_XDLD', 'PKT_HD_024', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'GCNBH Xây dựng bắt buộc mở rộng TN bên thứ ba', '~\\mauin\\mauinhd\\kythuat\\GCN\\GCN_BH_XDBB_TN_ben_thu_3.docx', 'IN_HD_XDLD', 'PKT_HD_025', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'GCNBH Xây dựng bắt buộc mở rộng mất lợi nhuận', '~\\mauin\\mauinhd\\kythuat\\GCN\\GCN_BH_XDBB_mat_loi_nhuan.docx', 'IN_HD_XDLD', 'PKT_HD_026', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'GCNBH Xây dựng bắt buộc phần thiệt hại vật chất', '~\\mauin\\mauinhd\\kythuat\\GCN\\GCN_BH_XDBB_thiet_hai_vat_chat.docx', 'IN_HD_XDLD', 'PKT_HD_027', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'GCNBH Lắp đặt bắt buộc mở rộng TN bên thứ ba', '~\\mauin\\mauinhd\\kythuat\\GCN\\GCN_BH_LDBB_TN_ben_thu_3.docx', 'IN_HD_XDLD', 'PKT_HD_028', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'GCNBH Lắp đặt bắt buộc phần thiệt hại vật chất', '~\\mauin\\mauinhd\\kythuat\\GCN\\GCN_BH_LDBB_thiet_hai_vat_chat.docx', 'IN_HD_XDLD', 'PKT_HD_029', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'GCNBH mọi rủi ro xây dựng mở rộng TN bên thứ ba và mất lợi nhuận', '~\\mauin\\mauinhd\\kythuat\\GCN\\GCN_BH_MRR.docx', 'IN_HD_XDLD', 'PKT_HD_030', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'GCNBH mọi rủi ro xây dựng mở rộng TN bên thứ ba', '~\\mauin\\mauinhd\\kythuat\\GCN\\GCN_BH_MRR_TN_ben_thu_3.docx', 'IN_HD_XDLD', 'PKT_HD_031', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'GCNBH mọi rủi ro xây dựng mở rộng mất lợi nhuận', '~\\mauin\\mauinhd\\kythuat\\GCN\\GCN_BH_MRR_mat_loi_nhuan.docx', 'IN_HD_XDLD', 'PKT_HD_032', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'GCNBH mọi rủi ro xây dựng phần thiệt hại vật chất', '~\\mauin\\mauinhd\\kythuat\\GCN\\GCN_BH_MRR_thiet_hai_vat_chat.docx', 'IN_HD_XDLD', 'PKT_HD_033', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'GCNBH Công trình dân dụng hoàn thành', '~\\mauin\\mauinhd\\kythuat\\GCN\\GCN_BH_CONG_TRINH_DAN_DUNG.docx', 'IN_HD_XDLD', 'PKT_HD_034', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'GCNBH đổ vỡ máy móc mở rộng gián đoạn kinh doanh', '~\\mauin\\mauinhd\\kythuat\\GCN\\GCN_BH_do_vo_may_moc.docx', 'IN_HD_XDLD', 'PKT_HD_035', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'GCNBH nồi hơi', '~\\mauin\\mauinhd\\kythuat\\GCN\\GCN_BH_noi_hoi.docx', 'IN_HD_XDLD', 'PKT_HD_036', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'GCNBH máy móc thiết bị chủ thầu', '~\\mauin\\mauinhd\\kythuat\\GCN\\GCN_BH_may_moc_thiet_bi_chu_thau.docx', 'IN_HD_XDLD', 'PKT_HD_037', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'GCNBH máy móc thiết bị cho thuê', '~\\mauin\\mauinhd\\kythuat\\GCN\\GCN_BH_may_moc_thiet_bi_cho_thue.docx', 'IN_HD_XDLD', 'PKT_HD_038', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'GCNBH hàng hóa trong kho lạnh', '~\\mauin\\mauinhd\\kythuat\\GCN\\GCN_BH_hang_hoa_trong_kho_lanh.docx', 'IN_HD_XDLD', 'PKT_HD_039', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'GCNBH thiết bị điện tử', '~\\mauin\\mauinhd\\kythuat\\GCN\\GCN_BH_thiet_bi_dien_tu.docx', 'IN_HD_XDLD', 'PKT_HD_040', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'GCNBH máy móc toàn diện mở rộng Gián đoạn kinh doanh', '~\\mauin\\mauinhd\\kythuat\\GCN\\GCN_BH_may_moc_toan_dien_GDKD.docx', 'IN_HD_XDLD', 'PKT_HD_041', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO)
values ('PKT_HD', N'GCNBH máy móc toàn diện phần thiệt hại vật chất', '~\\mauin\\mauinhd\\kythuat\\GCN\\GCN_BH_may_moc_toan_dien_THVC.docx', 'IN_HD_XDLD', 'PKT_HD_042', null)
/
INSERT INTO BH_IN_GCN_TSO (nv, ten, duong_dan, ham, ma, kyso) VALUES ('PKT_B_HD',N'Chào phí hợp đồng xây dựng bắt buộc',
'~\\mauin\\mauinhd\\kythuat\\ChaoPhi\\01.CP_HDBH_XDBB.docx','PBH_XD_IN_CP','TS_XD_CP_001','C');
/
COMMIT
/