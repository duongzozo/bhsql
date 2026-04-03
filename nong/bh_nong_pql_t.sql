-- Nguyen nhan ton that

drop table bh_nong_nntt;
create table bh_nong_nntt
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_nong_nntt_u0 on bh_nong_nntt(ma);
create index bh_nong_nntt_i1 on bh_nong_nntt (ma_ct);