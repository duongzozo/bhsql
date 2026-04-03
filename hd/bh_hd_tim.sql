drop table bh_hd_tim_temp0;
create GLOBAL TEMPORARY table bh_hd_tim_temp0
    (ma_dvi varchar2(10),
    so_id number,
	so_id_dt number,
    nv varchar2(1))
    ON COMMIT PRESERVE ROWS;

drop table bh_hd_tim_temp1;
create GLOBAL TEMPORARY table bh_hd_tim_temp1
    (ma_dvi varchar2(10),
    so_id number,
	so_id_dt number,
    nv varchar2(1))
    ON COMMIT PRESERVE ROWS;

drop table bh_hd_tim_temp2;
create GLOBAL TEMPORARY table bh_hd_tim_temp2
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
	goc varchar2(10),
    nv varchar2(1),
    gcn varchar2(20),
    ten nvarchar2(200),
    dchi varchar2(10),
    ngay_hl date,
    ngay_kt date)
ON COMMIT PRESERVE ROWS;

/
