-- Cong no dai ly

drop table bh_dl_cn_tu;
CREATE TABLE bh_dl_cn_tu
	(ma_dvi varchar2(10),
	so_id number,
	ngay_ht number,
	so_ct varchar2(20),
	l_ct varchar2(1),
	ma_kh varchar2(20),
	nd nvarchar2(500),
	ma_nt varchar2(5),
	tien number,
	tien_qd number,
	phong varchar2(10),
	nsd varchar2(10),
	ngay_nh date,
	so_id_kt number)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_dl_cn_tu_0800 values ('0800'),
    PARTITION bh_dl_cn_tu_DEFA values (DEFAULT));
create unique index bh_dl_cn_tu_u on bh_dl_cn_tu(ma_dvi,so_id) local;
create index bh_dl_cn_tu_i1 on bh_dl_cn_tu(ngay_ht) local;
create index bh_dl_cn_tu_i2 on bh_dl_cn_tu(so_id_kt) local;

drop table bh_dl_cn_tu_txt;
CREATE TABLE bh_dl_cn_tu_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(10),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_dl_cn_tu_txt_0800 values ('0800'),
    PARTITION bh_dl_cn_tu_txt_DEFA values (DEFAULT));
create index bh_dl_cn_tu_txt_i1 on bh_dl_cn_tu_txt(so_id) local;

drop table bh_dl_cn_sc;
create table bh_dl_cn_sc
	(ma_dvi varchar2(10),
	ma_kh varchar2(20),
	ma_nt varchar2(5),
	thu number,
	thu_qd number,
	chi number,
	chi_qd number,
	ton number,
	ton_qd number,
	ngay_ht number)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_dl_cn_sc_0800 values ('0800'),
    PARTITION bh_dl_cn_sc_DEFA values (DEFAULT));
create unique index bh_dl_cn_sc_u on bh_dl_cn_sc(ma_dvi,ma_kh,ma_nt,ngay_ht) local;