drop table bh_bc_tbh_ve_bh;
create table bh_bc_tbh_ve_bh(
    ma_dvi varchar2(10),
    so_id number,--so id xu ly ty le tai
    ngay_ht number,
    so_id_ta_ps number,-- so id phat sinh tai
    nv varchar2(5),
    loai varchar2(10),
    goc varchar2(10),
    ma_nt varchar2(10),
    ma_dvi_hd varchar2(10),
    so_id_hd number,
    so_id_dt number,
    pthuc varchar2(1),
    ma_ta varchar2(20),
    nha_bh varchar2(20),
    lh_nv varchar2(20),
    pt number,
    nt_tien varchar2(5),
    tien number,
    nt_phi varchar2(5),
    phi number,
    tl_thue number,
    thue number,
    pt_hh number,
    hhong number,
    so_id_dc number,-- so_id ban hang
    kieu_hd varchar2(1));

drop table bh_ptngcn_dk;
create table bh_ptngcn_dk
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    bt number,
    dvi nvarchar2(100),
    loai varchar2(10),
    ten nvarchar2(400),
    lh_nv varchar2(20),
    nt_tien varchar2(5),
    tien number,
    nt_phi varchar2(5),
    k_phi varchar2(1),
    pt number,
    pt_tt number, --phan tram phi toi thieu
    phi number,
    kphi varchar2(10),
    k_thue varchar2(1),
    c_thue varchar2(1),
    t_suat number,
    thue number,
    ttoan number,
    phi_dt number,
    mt_tien number,
    mt_pt number,
    mt_ktr varchar2(1),
    mt_chu nvarchar2(400),
    ngay_ht number
);
create unique index bh_ptngcn_dk_u0 on bh_ptngcn_dk(ma_dvi,so_id,so_id_dt,bt);