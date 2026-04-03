delete from bh_in_gcn_tso where nv = 'TAU_B_GCN'
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA)
values ('TAU_B_GCN', N'Bản chào phí hợp đồng tàu - trách nhiệm dân sự chủ tàu', '~\\mauin\\mauinhd\\tau\\BM03_BG_TNDS_ChuTau.xml', 'IN_B_TAU', 'TAU_B_GCN_001')
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA)
values ('TAU_B_GCN', N'Bản chào phí hợp đồng tàu - trách nhiệm nhân sự lai dắt', '~\\mauin\\mauinhd\\tau\\BM03_BG_TNDS_LaiDat.xml', 'IN_B_TAU', 'TAU_B_GCN_002')
/
delete from bh_in_gcn_tso where nv = 'TAU_GCN'
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA)
values ('TAU_GCN', N'Thông báo thu phí bảo hiểm', '~\\mauin\\mauinhd\\thuphi\\Mau_Thong_bao_thu_phi.docx', 'IN_TBTP', 'TAU_GCN_001')
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA)
values ('TAU_GCN', N'Debit note', '~\\mauin\\mauinhd\\thuphi\\Debit_note.docx', 'IN_TBTP', 'TAU_GCN_002')
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA)
values ('TAU_GCN', N'Giấy chứng nhận bảo hiểm tàu thủy nội địa', '~\\mauin\\mauinhd\\tau\\BM.13.TT.QT.002.HH-GCNBH_Tau_TND.docx', 'IN_TAU_GCN', 'TAU_GCN_003')
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA)
values ('TAU_GCN', N'Giấy chứng nhận bảo hiểm tàu cá', '~\\mauin\\mauinhd\\tau\\BM.13.TT.QT.002.HH-GCNBH_Tau_Ca.docx', 'IN_TAU_GCN', 'TAU_GCN_004')
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA)
values ('TAU_GCN', N'Giấy chứng nhận bảo hiểm tàu biển VN', '~\\mauin\\mauinhd\\tau\\BM.08.QT.002.HH-GCNBH_Than_tau_bien_VN.docx', 'IN_TAU_GCN', 'TAU_GCN_005')
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA)
values ('TAU_GCN', N'Giấy chứng nhận bảo hiểm TNDS chủ tàu biển VN', '~\\mauin\\mauinhd\\tau\\BM.09.QT.002.HH-GCNBH_TNDS_tau_bien_VN.docx', 'IN_TAU_GCN', 'TAU_GCN_006')
/


delete from bh_in_gcn_tso where nv = 'TAU_H_GCN'
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA)
values ('TAU_H_GCN', N'Giấy chứng nhận bảo hiểm tàu (biển + ven biển)', '~\\mauin\\mauinhd\\tau\\HD_Than_tau_bien_Viet Nam.xml', 'IN_TAU_GCN_HD', 'TAU_H_GCN_001')
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA)
values ('TAU_H_GCN', N'Giấy chứng nhận bảo hiểm tàu (sông + cá)', '~\\mauin\\mauinhd\\tau\\HD_Tau_thuy_noi_dia.xml', 'IN_TAU_GCN_HD', 'TAU_H_GCN_002')
/
COMMIT
/