drop TABLE bh_bt_ng_ma_vph;
CREATE TABLE bh_bt_ng_ma_vph
    (ma_bv varchar2(10),
    ma varchar2(20),
    ten nvarchar2(500),
    ma_ct varchar2(10),
    bhxh number,           -- % BHXH tra
    ma_dk varchar2(10));
CREATE unique INDEX bh_bt_ng_ma_vph_u1 on bh_bt_ng_ma_vph(ma_bv,ma);
CREATE INDEX bh_bt_ng_ma_vph_i1 on bh_bt_ng_ma_vph(ma_bv,ma_ct);

drop TABLE bh_bt_ng;
CREATE TABLE bh_bt_ng(
    ma_dvi varchar2(10),
    so_id number,
    ngay_ht number,
	nv  varchar2(10),
    so_hs varchar2(30),
    ttrang varchar2(1),
    kieu_hs varchar2(1),
    so_hs_g varchar2(20),
    loai_hs varchar2(1),            -- T-Truc tiep, B-Bao lanh, A-TPA
	dsach varchar2(1),
    gcn varchar2(20),
    ma_dvi_ql varchar2(10),
    ma_dvi_xl varchar2(10),
    so_id_hd number,
    so_id_dt number,				-- So ID GCN, So ID nhom
    so_hd varchar2(20),
    ma_khH varchar2(20),
    tenH nvarchar2(100),
    ma_kh varchar2(20),
    ten nvarchar2(100),
    ngay_gui number,
    ngay_mo number,
    ngay_do number,
    ngay_xr number,
    ma_nn varchar2(10),
    ma_dtri varchar2(10),
    n_trinh varchar2(10),
    n_duyet varchar2(50),
    ngay_qd number,
    nt_tien varchar2(5),
    c_thue varchar2(1),
    tien number,
    tienHK number,
    thue number,
    ttoan number,
    tpa varchar2(20),
    so_tpa varchar2(20),
    noP varchar2(1),            -- Cho no phi
    bphi varchar2(1),           -- Thanh toan bu phi con no
    dung varchar2(1),           -- Dung hop dong
    traN varchar2(1),           -- Tra tu dong ngay sau khi duyet
    nsd varchar2(10),
    phong varchar2(10),
    so_id_kt number,
    dvi_ksoat varchar2(10),
    ksoat varchar2(10),
	ngay_nh date)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_ng_0800 values ('0800'),
        PARTITION bh_bt_ng_0885 values ('0885'),
        PARTITION bh_bt_ng_DEFA values (DEFAULT));
CREATE UNIQUE INDEX bh_bt_ng_u1 on bh_bt_ng(ma_dvi,so_id) local;
CREATE UNIQUE INDEX bh_bt_ng_u2 on bh_bt_ng(ma_dvi,so_hs) local;
CREATE INDEX bh_bt_ng_i1 on bh_bt_ng(ngay_ht) local;
CREATE INDEX bh_bt_ng_i2 on bh_bt_ng(so_id_kt) local;
CREATE INDEX bh_bt_ng_i3 on bh_bt_ng(so_id_hd) local;
CREATE INDEX bh_bt_ng_i4 on bh_bt_ng(so_id_dt) local;
CREATE INDEX bh_bt_ng_i6 on bh_bt_ng(ma_kh);
CREATE INDEX bh_bt_ng_i7 on bh_bt_ng(ma_khH);

drop TABLE bh_bt_ng_dk;
CREATE TABLE bh_bt_ng_dk
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma varchar2(10),
    ten nvarchar2(500),
    tc varchar2(1),
    ma_ct varchar2(10),
    cap number, 
    ma_dk varchar2(10),
    ma_bs varchar2(10),
    lh_nv varchar2(10),
    t_suat number,
    tien_bh number,
    pt_bt number,
	t_that number,
    tien number,
    thue number,
    ttoan number,
	tien_qd number,
	thue_qd number,
	ttoan_qd number,
    lkeB varchar2(1))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_ng_dk_0800 values ('0800'),
        PARTITION bh_bt_ng_dk_0885 values ('0885'),
        PARTITION bh_bt_ng_dk_DEFA values (DEFAULT));
CREATE INDEX bh_bt_ng_dk_i1 on bh_bt_ng_dk(so_id) local;

drop TABLE bh_bt_ng_hk;
CREATE TABLE bh_bt_ng_hk
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma varchar2(20),
    ten nvarchar2(500),
    ma_nt varchar2(5),
    tien number,
    thue number,
    ttoan number,
    tien_qd number,
    thue_qd number,
    ttoan_qd number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_ng_hk_0800 values ('0800'),
        PARTITION bh_bt_ng_hk_0885 values ('0885'),
        PARTITION bh_bt_ng_hk_DEFA values (DEFAULT));
CREATE INDEX bh_bt_ng_hk_i1 on bh_bt_ng_hk(so_id) local;

drop table bh_bt_ng_grv;
create table bh_bt_ng_grv
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma varchar2(20),
    ten nvarchar2(500),
    so varchar2(20),
    ng_cap number,
    tien number,
    thue number,
    ttoan number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_ng_grv_0800 values ('0800'),
        PARTITION bh_bt_ng_grv_0885 values ('0885'),
        PARTITION bh_bt_ng_grv_DEFA values (DEFAULT));
CREATE INDEX bh_bt_ng_grv_i1 on bh_bt_ng_grv(so_id) local;
CREATE INDEX bh_bt_ng_grv_i2 on bh_bt_ng_grv(ma,so,ng_cap);

drop table bh_bt_ng_txt;
create table bh_bt_ng_txt(
	ma_dvi varchar2(10),
    so_id number,
    loai varchar2(10),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_ng_txt_0800 values ('0800'),
        PARTITION bh_bt_ng_txt_0885 values ('0885'),
        PARTITION bh_bt_ng_txt_DEFA values (DEFAULT));
CREATE INDEX bh_bt_ng_txt_i1 on bh_bt_ng_txt(so_id) local;

drop TABLE bh_bt_ng_xl;
CREATE TABLE bh_bt_ng_xl
    (ma_dvi varchar2(10),
    so_id number,
    lh_nv varchar2(10),
    t_suat number,
    tien_bh number,
    pt_bt number,
	t_that number,
    tien number,
    thue number,
    ttoan number,
	tien_qd number,
	thue_qd number,
	ttoan_qd number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_ng_xl_0800 values ('0800'),
        PARTITION bh_bt_ng_xl_0885 values ('0885'),
        PARTITION bh_bt_ng_xl_DEFA values (DEFAULT));
CREATE INDEX bh_bt_ng_xl_i1 on bh_bt_ng_xl(so_id) local;

drop table bh_bt_ng_duph;
create table bh_bt_ng_duph(
    ma_dvi varchar2(10),
    so_id number,
    loai varchar2(10),
    txt clob,
    ngay number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_ng_duph_0800 values ('0800'),
        PARTITION bh_bt_ng_duph_0885 values ('0885'),
        PARTITION bh_bt_ng_duph_DEFA values (DEFAULT));
CREATE INDEX bh_bt_ng_duph_i1 on bh_bt_ng_duph(so_id,ngay) local;

drop table bh_bt_ng_tttl;
create table bh_bt_ng_tttl
  (ma_dvi varchar2(10),
  so_id  number,
  bt     number,
  ma     varchar2(10),
  ten    nvarchar2(1000),
  muc    number)
  PARTITION BY list (ma_dvi)(
    PARTITION bh_bt_ng_tttl_0800 values ('0800'),
    PARTITION bh_bt_ng_tttl_0885 values ('0885'),
    PARTITION bh_bt_ng_tttl_DEFA values (default));
CREATE INDEX bh_bt_ng_tttl_i1 on bh_bt_ng_tttl (so_id);