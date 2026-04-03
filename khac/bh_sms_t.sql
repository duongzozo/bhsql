drop table bh_sms_nh;
create table bh_sms_nh
 (ma_dvi varchar2(10),
 so_id number,
 ngay number,
 ma varchar2(20),
 seri varchar2(10),
 so number,
 bien varchar2(30),
 tien number,
 phi number,
 ngay_ht varchar2(30),
 phone varchar2(20),
 ttrang varchar2(1),
 ma_dvi_g varchar2(10),
 gcn varchar2(50),
 phong varchar2(10),
 ma_cb varchar2(10),
 ma_dl varchar2(20),
 nsd varchar2(10)
);
create unique index bh_sms_nh_u0 on bh_sms_nh(ma_dvi,so_id);
CREATE UNIQUE INDEX bh_sms_nh_i1 on bh_sms_nh(gcn);
CREATE INDEX bh_sms_nh_i2 on bh_sms_nh(ma_dvi,ngay);

drop table bh_sms_ton;
create table bh_sms_ton
 (ma_dvi varchar2(10),
 so_id number,
 ma_dvi_g varchar2(10),
 gcn varchar2(50),
 phong varchar2(10),
 ma_cb varchar2(10),
 ma_dl varchar2(20)
);
create unique index bh_sms_ton_u0 on bh_sms_ton(ma_dvi,so_id);
CREATE UNIQUE INDEX bh_sms_ton_i1 on bh_sms_ton(gcn);
CREATE INDEX bh_sms_ton_i2 on bh_sms_ton(ma_dvi_g,phong,ma_cb,ma_dl);