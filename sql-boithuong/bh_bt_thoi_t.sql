-- Thu hoi boi thuong --

drop TABLE bh_bt_thoi;
CREATE TABLE bh_bt_thoi
	(ma_dvi varchar2(10),
	so_id number,
	ngay_ht number,
	nv varchar2(10),
	so_hs varchar2(30),
	so_id_hs number,
	ma_dvi_xl varchar2(10),
	ma_dvi_ql varchar2(10),
	so_id_hd number,
	so_id_dt number,
	so_ct varchar2(20),
	ma_nt varchar2(5),
	tien number,
	thue number,
	ttoan number,
	tien_qd number,
	thue_qd number,
	ttoan_qd number,
	t_suat number,
	kh_thu varchar2(1),            -- Khach thu: C,K
	ma_thue varchar2(20),        -- Ma thue nguoi mua
	tenM nvarchar2(500),        -- Ten nguoi mua
	dchiM nvarchar2(500),        -- Dia chi nguoi mua
	mau varchar2(20),
	seri varchar2(10),
	so_don varchar2(20),
	don varchar2(50),
	ma_kh varchar2(20),
	ten nvarchar2(500),
	phong varchar2(10),
	nsd varchar2(10),
	ngay_nh date,
	so_id_kt number)
	PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_thoi_0800 values ('0800'),
        PARTITION bh_bt_thoi_DEFA values (DEFAULT));
CREATE unique INDEX bh_bt_thoi_u on bh_bt_thoi(ma_dvi,so_id) local;
CREATE INDEX bh_bt_thoi_i1 on bh_bt_thoi(ngay_ht) local;
CREATE INDEX bh_bt_thoi_i2 on bh_bt_thoi(so_id_hs) local;
CREATE INDEX bh_bt_thoi_i3 on bh_bt_thoi(so_id_kt) local;

drop table bh_bt_thoi_ct;
create table bh_bt_thoi_ct
    (ma_dvi varchar2(10),
    so_id number,
    so_id_hs number,
    ma varchar2(20),
    ten nvarchar2(50),
    tien number,
    tien_qd number,
    bt number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_thoi_ct_0800 values ('0800'),
        PARTITION bh_bt_thoi_ct_DEFA values (DEFAULT));
CREATE INDEX bh_bt_thoi_ct_i1 on bh_bt_thoi_ct(so_id) local;

drop table bh_bt_thoi_pt;
create table bh_bt_thoi_pt
	(ma_dvi varchar2(10),
	so_id number,
	so_id_bt number,
    	ma_dvi_hd varchar2(10),
	so_id_hd number,
	so_id_dt number,
	ngay_ht number,
	lh_nv varchar2(20),
	ma_nt varchar2(5),
	tien number,
	tien_qd number,
	thue number,
	thue_qd number,
	bt number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_thoi_pt_0800 values ('0800'),
        PARTITION bh_bt_thoi_pt_DEFA values (DEFAULT));
CREATE INDEX bh_bt_thoi_pt_i1 on bh_bt_thoi_pt(so_id) local;

drop table bh_bt_thoi_txt;
CREATE TABLE bh_bt_thoi_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(10),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_thoi_txt_0800 values ('0800'),
        PARTITION bh_bt_thoi_txt_DEFA values (DEFAULT));
create index bh_bt_thoi_txt_i1 on bh_bt_thoi_txt(so_id) local;