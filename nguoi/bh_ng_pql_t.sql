-- ma nguyen nhan ton that sk--

drop table bh_ngsk_nntt;
create table bh_ngsk_nntt
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_ngsk_nntt_u0 on bh_ngsk_nntt(ma);
create index bh_ngsk_nntt_i1 on bh_ngsk_nntt (ma_ct);
-- ma nguyen nhan ton that dl--

drop table bh_ngdl_nntt;
create table bh_ngdl_nntt
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_ngdl_nntt_u0 on bh_ngdl_nntt(ma);
create index bh_ngdl_nntt_i1 on bh_ngdl_nntt (ma_ct);
-- ma nguyen nhan ton that td--

drop table bh_ngtd_nntt;
create table bh_ngtd_nntt
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_ngtd_nntt_u0 on bh_ngtd_nntt(ma);
create index bh_ngtd_nntt_i1 on bh_ngtd_nntt (ma_ct);

-- Ma dieu tri

drop table bh_sk_dtri;
create table bh_sk_dtri
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_sk_dtri_u0 on bh_sk_dtri(ma);