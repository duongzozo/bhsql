drop TABLE bh_tpa_phi;
CREATE TABLE bh_tpa_phi
    (ma_dvi varchar2(10),
    ma varchar2(20),
    tl_phi number,                 -- % phi
    t_suat number,                -- % thue
    ngay_bd number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_tpa_phi_u0 on bh_tpa_phi(ma);

drop table bh_tpa_hd;
create table bh_tpa_hd
    (ma_dvi varchar2(10),
    so_id_tt number,
    so_id number,               -- So ID dau hop dong
    so_hd varchar2(20),
    ngay_ht number,
    nv varchar2(10),            -- SKC,SKG,SKT
    nt_phi varchar2(5),
    phi number,
    tpa varchar2(20),
    tpa_phi number,
    tpa_thue number,
    tpa_phi_qd number,
    tpa_thue_qd number,
    so_id_tr number,            -- So ID tra
    ngay_tra number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_tpa_hd_0800 values ('0800'),
        PARTITION bh_tpa_hd_defa values (DEFAULT));
CREATE INDEX bh_tpa_hd_i1 on bh_tpa_hd(so_id_tt) local;
CREATE INDEX bh_tpa_hd_i2 on bh_tpa_hd(so_id_tr) local;
CREATE INDEX bh_tpa_hd_i3 on bh_tpa_hd(so_id) local;

drop table bh_tpa_hd_pt;
create table bh_tpa_hd_pt
    (ma_dvi varchar2(10),
    so_id_tt number,
    ngay_ht number,
    so_id number,
    so_id_dt number,
    lh_nv varchar2(10),
    nt_phi varchar2(5),
    tpa_phi number,
    tpa_thue number,
    tpa_phi_qd number,
    tpa_thue_qd number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_tpa_hd_pt_0800 values ('0800'),
        PARTITION bh_tpa_hd_pt_defa values (DEFAULT));
CREATE INDEX bh_tpa_hd_pt_i1 on bh_tpa_hd_pt(so_id_tt) local;
CREATE INDEX bh_tpa_hd_pt_i2 on bh_tpa_hd_pt(so_id) local;

-- Tra

drop TABLE bh_tpa_tra;
CREATE TABLE bh_tpa_tra
    (ma_dvi varchar2(10),
    so_id_tr number,
    ngay_ht number,
    so_ct varchar2(20),
    loai varchar2(1),               -- H-hop dong, B-Boi thuong, c-Ca hai
    pt_tra varchar2(1),             -- T-Tien mat, C- cong no giam dinh
    tpa varchar2(20),
    tien_qd number,
    thue_qd number,
    nt_tra varchar2(5),
    tra number,
    tra_qd number,
    nsd varchar2(20),
    ngay_nh date,
    so_id_kt number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_tpa_tra_0800 values ('0800'),
        PARTITION bh_tpa_tra_defa values (DEFAULT));
CREATE unique INDEX bh_tpa_tra_p on bh_tpa_tra(ma_dvi,so_id_tr);
CREATE INDEX bh_tpa_tra_i1 on bh_tpa_tra(ngay_ht) local;
CREATE INDEX bh_tpa_tra_i2 on bh_tpa_tra(so_id_kt) local;

drop TABLE bh_tpa_tra_txt;
CREATE TABLE bh_tpa_tra_txt
    (ma_dvi varchar2(10), 
    so_id_tr number,
    loai varchar2(10),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_tpa_tra_txt_0800 values ('0800'),
        PARTITION bh_tpa_tra_txt_defa values (DEFAULT));
CREATE INDEX bh_tpa_tra_txt_i1 on bh_tpa_tra_txt(ma_dvi,so_id_tr);

drop table bh_tpa_cn;
CREATE TABLE bh_tpa_cn
    (ma_dvi varchar2(10),
    so_id number,
    ngay_ht number,
    l_ct varchar2(1),
    tpa varchar2(20),
    so_ct varchar2(20),
    nd nvarchar2(200),
    ma_nt varchar2(5),
    tien number,
    tien_qd number,
    phong varchar2(10),
    nsd varchar2(10),
    ngay_nh date,
    so_id_kt number)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_tpa_cn_0800 values ('0800'),
    PARTITION bh_tpa_cn_DEFA values (DEFAULT));
create unique index bh_tpa_cn_u on bh_tpa_cn(ma_dvi,so_id) local;
create index bh_tpa_cn_i1 on bh_tpa_cn(ngay_ht) local;
create index bh_tpa_cn_i2 on bh_tpa_cn(so_id_kt) local;

drop table bh_tpa_cn_txt;
CREATE TABLE bh_tpa_cn_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(10),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_tpa_cn_txt_0800 values ('0800'),
    PARTITION bh_tpa_cn_txt_DEFA values (DEFAULT));
create index bh_tpa_cn_txt_i1 on bh_tpa_cn_txt(so_id) local;

drop table bh_tpa_cn_sc;
create table bh_tpa_cn_sc
    (ma_dvi varchar2(10),
    tpa varchar2(20),
    ma_nt varchar2(5),
    thu number,
    thu_qd number,
    chi number,
    chi_qd number,
    ton number,
    ton_qd number,
    ngay_ht number
);
create unique index bh_tpa_cn_sc_u0 on bh_tpa_cn_sc(ma_dvi,tpa,ma_nt,ngay_ht);

drop table bh_tpa_cn_sc_ps;
create table bh_tpa_cn_sc_ps
    (ma_dvi varchar2(10),
    so_id number,
    so_id_ps number);
CREATE INDEX bh_tpa_cn_sc_ps_i1 on bh_tpa_cn_sc_ps(ma_dvi,so_id);
CREATE INDEX bh_tpa_cn_sc_ps_i2 on bh_tpa_cn_sc_ps(ma_dvi,so_id_ps);