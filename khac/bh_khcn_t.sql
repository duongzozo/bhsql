-- Cong no khach hang

drop table bh_kh_cn_sc;
create table bh_kh_cn_sc
	(ma_dvi varchar2(10),
	ma_kh varchar2(20),
	phong varchar2(10),
	ma_nt varchar2(5),
	thu number,
	thu_qd number,
	chi number,
	chi_qd number,
	ton number,
	ton_qd number,
	ngay_ht number)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_kh_cn_sc_0800 values ('0800'),
    PARTITION bh_kh_cn_sc_DEFA values (DEFAULT));
create unique index bh_kh_cn_sc_u on bh_kh_cn_sc (ma_dvi,ma_kh,phong,ma_nt,ngay_ht) local;

drop table bh_kh_cn_tu;
CREATE TABLE bh_kh_cn_tu
	(ma_dvi varchar2(10),
	so_id number,
	ngay_ht number,
	l_ct varchar2(1),
	ma_kh varchar2(20),
	phong varchar2(10),
	phong_m varchar2(10),
	so_ct varchar2(20),
	ma_nt varchar2(5),
	loai varchar2(1),
	tien number,
	tien_qd number,
	tien_qd_m number,
	nsd varchar2(10),
	ngay_nh date,
	so_id_kt number)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_kh_cn_tu_0800 values ('0800'),
    PARTITION bh_kh_cn_tu_DEFA values (DEFAULT));
create unique index bh_kh_cn_tu_u on bh_kh_cn_tu(ma_dvi,so_id) local;
create index bh_kh_cn_tu_i1 on bh_kh_cn_tu(ngay_ht) local;
create index bh_kh_cn_tu_i2 on bh_kh_cn_tu(so_id_kt) local;

drop table bh_kh_cn_tu_txt;
CREATE TABLE bh_kh_cn_tu_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(10),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_kh_cn_tu_txt_0800 values ('0800'),
        PARTITION bh_kh_cn_tu_txt_DEFA values (DEFAULT));
create index bh_kh_cn_tu_txt_i1 on bh_kh_cn_tu_txt(so_id) local;

-- Dieu chinh ty gia cong no

drop table bh_kh_cn_dctg;
CREATE TABLE bh_kh_cn_dctg
	(ma_dvi varchar2(10),
	so_id number,
	bt number,
	ngay_ht number,
	ma_nt varchar2(5),
	ma_kh varchar2(20),
	tien number,
	tien_qd number,
	tien_dc number,
	nsd varchar2(10),
	ngay_nh date)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_kh_cn_dctg_0800 values ('0800'),
    PARTITION bh_kh_cn_dctg_DEFA values (DEFAULT));
create unique index bh_kh_cn_dctg_u on bh_kh_cn_dctg(ma_dvi,so_id,bt) local;
CREATE INDEX bh_kh_cn_dctg_i1 on bh_kh_cn_dctg(ngay_ht) local;