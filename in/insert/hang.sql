delete from bh_in_gcn_tso where nv IN ('HANG_B','HANG')
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO, PBH)
values ('HANG', N'Mẫu sửa đổi bổ sung_E', '~\\mauin\\mauinhd\\hang\\SDBS_hang_E.docx', 'IN_HANG_SDBS', 'H11', 'C', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO, PBH)
values ('HANG', N'Bảo hiểm hàng hóa vận chuyển_chephi', '~\mauin\mauinhd\hang\BM.09.HH.QT.001.HH-GCNBH XNK_V_CHE_PHI.docx', 'IN_HANG', 'H03', null, null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO, PBH)
values ('HANG', N'Bảo hiểm hàng hóa vận chuyển_E', '~\\mauin\\mauinhd\\hang\\BM.09.HH.QT.001.HH-GCNBH XNK_E.docx', 'IN_HANG', 'HANG_005', null, null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO, PBH)
values ('HANG', N'Bảo hiểm hàng hóa vận chuyển_E_chephi', '~\mauin\mauinhd\hang\BM.09.HH.QT.001.HH-GCNBH XNK_E_CHEPHI.docx', 'IN_HANG', 'H04', null, null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO, PBH)
values ('HANG', N'Debit note', '~\\mauin\\mauinhd\\thuphi\\Debit_note.docx', 'IN_TBTP', 'TBTP_HANG_E', 'C', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO, PBH)
values ('HANG', N'Thông báo thu phí bảo hiểm', '~\\mauin\\mauinhd\\thuphi\\Mau_Thong_bao_thu_phi.docx', 'IN_TBTP', 'TBTP_HANG', 'C', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO, PBH)
values ('HANG', N'Bảo hiểm hàng hóa vận chuyển', '~\\mauin\\mauinhd\\hang\\BM.09.HH.QT.001.HH-GCNBH XNK_V.docx', 'IN_HANG', 'H01', 'C', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO, PBH)
values ('HANG', N'Bảo hiểm hàng hóa vận chuyển nội địa', '~\\mauin\\mauinhd\\hang\\BM.09.HH.QT.001.HH-GCNBH_VCND_V.docx', 'IN_HANG', 'H02', 'C', null)
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA, KYSO, PBH)
values ('HANG', N'Mẫu sửa đổi bổ sung', '~\\mauin\\mauinhd\\hang\\SDBS_hang.docx', 'IN_HANG_SDBS', 'H10', 'C', null)
/
COMMIT
/