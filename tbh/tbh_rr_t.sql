drop table tbh_rr;
create table tbh_rr
 (ma_dvi varchar2(10),
 so_id number,
 so_rr varchar2(50),
 kieu varchar2(1),
 nv varchar2(10),
 ngay_ht number,
 ngay_hl number,
 ngay_kt number,
 ma_dt varchar2(20),
 nam_hd number,
 so_id_g number,
 so_id_d number,
 nsd varchar2(20)
);
create unique index tbh_rr_u0 on tbh_rr(ma_dvi,so_id);
CREATE INDEX tbh_rr_i1 on tbh_rr (ma_dvi,so_rr);

drop table tbh_rr_dt;
create table tbh_rr_dt
 (ma_dvi varchar2(10),
 so_id number,
 bt number,
 ma_dvi_g varchar2(10),
 so_id_g number,
 so_id_dt_g number,
 so_id_d number,
 ngay_hl number,
 ngay_kt number
);
create unique index tbh_rr_dt_u0 on tbh_rr_dt(ma_dvi,so_id,bt);
CREATE INDEX tbh_rr_dt_i1 on tbh_rr_dt (ma_dvi_g,so_id_g,so_id_dt_g);

drop table tbh_rr_dt_ct;
create table tbh_rr_dt_ct
 (ma_dvi varchar2(10),
 so_id number,
 bt number,
 lh_nv varchar2(20),
 ma_ta varchar2(20),
 nt_tien varchar2(5),
 tien number,
 nt_phi varchar2(5),
 phi number,
 kieu_hd varchar2(1),
 pt number
);
create unique index tbh_rr_dt_ct_u0 on tbh_rr_dt_ct(ma_dvi,so_id,bt);
CREATE INDEX tbh_rr_dt_ct_i1 on tbh_rr_dt_ct (ma_dvi,so_id,ma_ta);

drop table tbh_rr_tl;
create table tbh_rr_tl
 (ma_dvi varchar2(10),
 so_id number,
 bt number,
 ma_ta varchar2(20),
 pthuc varchar2(1),
 nha_bh varchar2(20),
 pt number,
 nt_tien varchar2(5),
 tien number,
 nt_phi varchar2(5),
 phi number,
 hh number,
 hhong number,
 tn number,
 tnop number
);
create unique index tbh_rr_tl_u0 on tbh_rr_tl(ma_dvi,so_id,bt);
CREATE INDEX tbh_rr_tl_i1 on tbh_rr_tl (ma_dvi,so_id,ma_ta,pthuc,nha_bh);

drop table tbh_rr_temp;
create GLOBAL TEMPORARY table tbh_rr_temp
 (ma_ta varchar2(20),
 nha_bh varchar2(20),
 pthuc varchar2(1),
 pt number,
 hh number,
 nt_tien varchar2(5),
 tien number,
 nt_phi varchar2(5),
 phi number,
 hhong number,
 tn number,
 tnop number)
ON COMMIT PRESERVE ROWS;

drop table tbh_rr_tt;
create table tbh_rr_tt
 (ma_dvi varchar2(10),
 so_id number,
 ngay number,
 ma_nt varchar2(5),
 tien number
);
create unique index tbh_rr_tt_u0 on tbh_rr_tt(ma_dvi,so_id,ngay);