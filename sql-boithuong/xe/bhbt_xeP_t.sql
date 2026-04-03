drop TABLE bh_bt_xeP_dk;
CREATE TABLE bh_bt_xeP_dk
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma varchar2(20),
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
    nd nvarchar2(500),
    lkeB varchar2(1))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_xeP_dk_0800 values ('0800'),
        PARTITION bh_bt_xeP_dk_DEFA values (DEFAULT));
CREATE INDEX bh_bt_xeP_dk_i1 on bh_bt_xeP_dk(so_id) local;

drop TABLE bh_bt_xeP_hk;
CREATE TABLE bh_bt_xeP_hk
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    nhom varchar2(10),
    ma varchar2(20),
    ten nvarchar2(500),
    ma_nt varchar2(5),
    tien number,
    thue number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_xeP_hk_0800 values ('0800'),
        PARTITION bh_bt_xeP_hk_DEFA values (DEFAULT));
CREATE INDEX bh_bt_xeP_hk_i1 on bh_bt_xeP_hk(so_id) local;

drop table bh_bt_xeP_txt;
create table bh_bt_xeP_txt(
	ma_dvi varchar2(10),
    so_id number,
    loai varchar2(10),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_xeP_txt_0800 values ('0800'),
        PARTITION bh_bt_xeP_txt_DEFA values (DEFAULT));
CREATE INDEX bh_bt_xeP_txt_i1 on bh_bt_xeP_txt(so_id) local;