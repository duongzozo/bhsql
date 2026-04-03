drop table bh_gcnE;
create table bh_gcnE
    (ma_dvi varchar2(10),
    so_id number,
    md varchar2(5),			-- Modul phat sinh: BH,KT,...
    nv varchar2(10),		-- Nghiep vu: XEL,...
    ma varchar2(10),		-- Ma: GCN,...
    ngay_nh date);
CREATE INDEX bh_gcnE_u on bh_gcnE(ma_dvi,so_id);

drop table bh_gcnE_ky;
create table bh_gcnE_ky
    (ma_dvi varchar2(10),
    so_id number,
    md varchar2(5),			-- Modul phat sinh: BH,KT,...
    nv varchar2(10),		-- Nghiep vu: XEL,...
    ma varchar2(10),		-- Ma: GCN,...
	ky clob,
    ngay_nh date);
CREATE INDEX bh_gcnE_ky_u on bh_gcnE_ky(ma_dvi,so_id);

drop table bh_gcnE_tra;
create table bh_gcnE_tra
    (ma_dvi varchar2(10),
    so_id number,
    nv varchar2(10),
    ma varchar2(10),
	mobi varchar2(30),
	so_hd varchar2(50),
    ngay_hl date,
    ngay_kt date,
	ngay_cap date);
CREATE INDEX bh_gcnE_tra_i1 on bh_gcnE_tra(mobi);

drop table bh_gcnE_l;
create table bh_gcnE_l
    (ma_dvi varchar2(10),
    so_id number,
    md varchar2(5),
    nv varchar2(10),
    ma varchar2(10),
	ky clob,
    ngay_nh date);

drop table bh_gcnE_loi;
create table bh_gcnE_loi(
    md varchar2(5),
    nv varchar2(10),
    ma varchar2(10),
	loi varchar2(1000));