drop table bh_sv_kh_temp1;
create GLOBAL TEMPORARY table bh_sv_kh_temp1
	(ma_dvi varchar2(10),
	so_hd varchar2(50),
	nv varchar2(10),
	ma_kh varchar2(20))
	ON COMMIT PRESERVE ROWS;

drop table bh_sv_kh_temp2;
create GLOBAL TEMPORARY table bh_sv_kh_temp2
	(ma_dvi varchar2(10),
	ma_kh varchar2(20))
	ON COMMIT PRESERVE ROWS;

drop table bh_sv_xe_temp1;
create GLOBAL TEMPORARY table bh_sv_xe_temp1
	(ma_dvi varchar2(10),
	so_id number,
	so_id_dt number)
	ON COMMIT PRESERVE ROWS;

drop table bh_sv_xe_temp2;
create GLOBAL TEMPORARY table bh_sv_xe_temp2
	(ma_dvi varchar2(10),
	so_id number,
	so_id_dt number,
	so_hd varchar2(50),
	ma_kh varchar2(20),
	ten nvarchar2(200),
	loai_xe varchar2(20),
	bien_xe varchar2(30),
	hang_xe varchar2(20),
	hieu_xe varchar2(50),
	ttai number,
	so_cn number,
	gia_xe number,
	ngay_hl date,
	ngay_kt date)
	ON COMMIT PRESERVE ROWS;

drop table bh_sv_xe_temp3;
create GLOBAL TEMPORARY table bh_sv_xe_temp3
	(ma_dvi varchar2(10),
	so_id number,
	so_id_dt number,
	lh_nv varchar2(10))
	ON COMMIT PRESERVE ROWS;