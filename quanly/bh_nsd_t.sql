drop table bh_ma_nsd_lhnv;
create table bh_ma_nsd_lhnv
    (ma_dvi varchar2(10),
    ma varchar2(10),
    lhnv varchar2(10),
    nt_kthac varchar2(5),
    kthac number,
    nt_bthuong varchar2(5),
    bthuong number,
    pphi number,
    nsd varchar2(10)
);
create unique index bh_ma_nsd_lhnv_u0 on bh_ma_nsd_lhnv(ma_dvi,ma,lhnv);

drop table bh_ma_nsd_dt;
create table bh_ma_nsd_dt
    (ma_dvi varchar2(10),
    ma varchar2(10),
    nv varchar2(10),    
    dt varchar2(10),
    tl_kthac number,
    tl_bthuong number,
    tl_pphi number,
    nsd varchar2(10)
);
create unique index bh_ma_nsd_dt_u0 on bh_ma_nsd_dt(ma_dvi,ma,nv,dt);

drop table bh_ma_nsd_gia;
create table bh_ma_nsd_gia
 (ma_dvi varchar2(10),
 ma varchar2(10),
 gia number,
 hoan number,
 nsd varchar2(10)
);
create unique index bh_ma_nsd_gia_u0 on bh_ma_nsd_gia(ma_dvi,ma);