-- Nhan tai mu

drop table tbh_mu_ma;
create table tbh_mu_ma(
    ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
 loai varchar2(5), -- T-Thu,C-Chi,G-Giu lai,H-Hoan
    nsd varchar2(10)
);
create unique index tbh_mu_ma_u0 on tbh_mu_ma(ma_dvi,ma);

-- Phat sinh

drop table tbh_mu_ps;
create table tbh_mu_ps(
    ma_dvi varchar2(20),
    so_id_ps number,
    ngay_ht number,
    so_hd varchar2(20),
    so_bk varchar2(20),
    so_dc varchar2(20),
 ttrang varchar2(1),   --- D-dang doi chieu, X-Da xac nhan
    tien_qd number,    --- tien btr qd
    nd nvarchar2(400),
    nsd varchar2(10),
    so_id_kt number,
    ngay_nh date
);
create unique index tbh_mu_ps_u0 on tbh_mu_ps(ma_dvi,so_id_ps);
CREATE unique INDEX tbh_mu_ps_u on tbh_mu_ps(ma_dvi,so_bk);
CREATE INDEX tbh_mu_ps_i1 on tbh_mu_ps(ma_dvi,ngay_ht);
CREATE INDEX tbh_mu_ps_i2 on tbh_mu_ps(ma_dvi,so_id_kt);
CREATE INDEX tbh_mu_ps_i3 on tbh_mu_ps(ma_dvi,so_hd);

drop table tbh_mu_ps_ct;
create table tbh_mu_ps_ct(
    ma_dvi varchar2(10),
    so_id_ps number,
    bt number,
    nv varchar2(30),
    ma_ps varchar2(10),
    ma_nt varchar2(5),
    tien number,
    tien_qd number,
    nd nvarchar2(400)
);
create unique index tbh_mu_ps_ct_u0 on tbh_mu_ps_ct(ma_dvi,so_id_ps,bt);

drop table tbh_mu_ps_btr;
create table tbh_mu_ps_btr(
    ma_dvi varchar2(10),
    so_id_ps number,
    bt number,
 ngay_ht number,
 so_hd varchar2(50),
    ma_nt varchar2(5),
    tien number,
    tien_qd number,
 so_id_tt number
);
create unique index tbh_mu_ps_btr_u0 on tbh_mu_ps_btr(ma_dvi,so_id_ps,bt);
CREATE INDEX tbh_mu_ps_btr_i1 on tbh_mu_ps_btr(ma_dvi,ngay_ht);
CREATE INDEX tbh_mu_ps_btr_i2 on tbh_mu_ps_btr(ma_dvi,so_id_tt);

drop table tbh_mu_ps_temp1;
create GLOBAL TEMPORARY table tbh_mu_ps_temp1(
 ngay_ht number,
 so_bk varchar2(20),
 so_dc varchar2(20),
 ma_nt varchar2(5),
 con number,
 tien number,
 so_id_ps number,
 bt_ps number)
 ON COMMIT PRESERVE ROWS;

drop table tbh_mu_tt;
create table tbh_mu_tt(
 ma_dvi varchar2(10),
 so_id_tt number,
 ngay_ht number,
 so_hd varchar2(20),
 so_bk varchar2(20),
 so_dc varchar2(20),
 ttrang varchar2(1),
 ma_nt varchar2(5),
 tien number,
 tien_qd number,
 nd nvarchar2(500),
 nsd varchar2(20),
 so_id_kt number,
 ngay_nh date
);
create unique index tbh_mu_tt_u0 on tbh_mu_tt(ma_dvi,so_id_tt);
CREATE INDEX tbh_mu_tt_i1 on tbh_mu_tt(ma_dvi,ngay_ht);
CREATE INDEX tbh_mu_tt_i2 on tbh_mu_tt(ma_dvi,so_id_kt);

drop table tbh_mu_tt_ct;
create table tbh_mu_tt_ct 
 (ma_dvi varchar2(10),
 so_id_tt number,
 bt number,
 so_id_ps number,
 bt_ps number,
 so_bk varchar2(20),
 so_dc varchar2(20),
 ma_nt varchar2(5),
 con number,
 tien number,
 tien_qd number,
 nd nvarchar2(500)
);
create unique index tbh_mu_tt_ct_u0 on tbh_mu_tt_ct(ma_dvi,so_id_tt,bt);