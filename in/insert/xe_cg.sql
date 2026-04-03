delete from bh_in_gcn_tso where nv = 'XE_CG_GCN'
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA)
values ('XE_CG_GCN', N'Debit note', '~\\mauin\\mauinhd\\thuphi\\Debit_note.docx', 'IN_TBTP', 'XE_CG_GCN_001')
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA)
values ('XE_CG_GCN', N'Thông báo thu phí bảo hiểm', '~\\mauin\\mauinhd\\thuphi\\Mau_Thong_bao_thu_phi.docx', 'IN_TBTP', 'XE_CG_GCN_002')
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA)
values ('XE_CG_GCN', N'BM04a_1 xe_HD', '~\\mauin\\mauinhd\\xe\\xecg\\BM04a_HDBH_250917000238_EB251234560107.docx', 'IN_GCN_XCG', 'XE_CG_GCN_005')
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA)
values ('XE_CG_GCN', N'Mau GCNBH tu nguyen oto A5', '~\\mauin\\mauinhd\\xe\\xecg\\Mau GCNBH tu nguyen oto A5.docx', 'IN_GCN_XCG', 'XE_CG_GCN_006')
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA)
values ('XE_CG_GCN', N'Mau GCNBH tu nguyen oto A4', '~\\mauin\\mauinhd\\xe\\xecg\\Mau GCNBH tu nguyen oto A4.docx', 'IN_GCN_XCG', 'XE_CG_GCN_007')
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA)
values ('XE_CG_GCN', N'Mau GCNBH TNDS BB oto A5', '~\\mauin\\mauinhd\\xe\\xecg\\Mau GCNBH TNDS BB oto A5.docx', 'IN_GCN_XCG', 'XE_CG_GCN_003')
/
delete from bh_in_gcn_tso where nv = 'XE_CG_HD'
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA)
values ('XE_CG_HD', N'Debit note', '~\\mauin\\mauinhd\\thuphi\\Debit_note.docx', 'IN_TBTP', 'XE_CG_HD_001')
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA)
values ('XE_CG_HD', N'Thông báo thu phí bảo hiểm', '~\\mauin\\mauinhd\\thuphi\\Mau_Thong_bao_thu_phi.docx', 'IN_TBTP', 'XE_CG_HD_002')
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA)
values ('XE_CG_HD', N'BM04a_1 xe_HD', '~\\mauin\\mauinhd\\xe\\xecg\\BM04a_HDBH_250917000238_EB251234560107.docx', 'IN_HD_XCG', 'XE_CG_HD_003');
/
delete from bh_in_gcn_tso where nv = 'XE_CG_HD_GCN'
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA)
values ('XE_CG_HD_GCN', N'Mau GCNBH tu nguyen oto A5', '~\\mauin\\mauinhd\\xe\\xecg\\Mau GCNBH tu nguyen oto A5.docx', 'IN_HD_GCN_XCG', 'XE_CG_HD_GCN_001')
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA)
values ('XE_CG_HD_GCN', N'Mau GCNBH tu nguyen oto A4', '~\\mauin\\mauinhd\\xe\\xecg\\Mau GCNBH tu nguyen oto A4.docx', 'IN_HD_GCN_XCG', 'XE_CG_HD_GCN_002')
/
insert into bh_in_gcn_tso (NV, TEN, DUONG_DAN, HAM, MA)
values ('XE_CG_HD_GCN', N'Mau GCNBH TNDS BB oto A5', '~\\mauin\\mauinhd\\xe\\xecg\\Mau GCNBH TNDS BB oto A5.docx', 'IN_HD_GCN_XCG', 'XE_CG_HD_GCN_003')
/
commit
/
