-- ma nguyen nhan ton that--

drop table bh_ptn_nntt;
create table bh_ptn_nntt
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_ptn_nntt_u0 on bh_ptn_nntt(ma);
create index bh_ptn_nntt_i1 on bh_ptn_nntt (ma_ct);
-- Ty le phi / tgian BH

drop table bh_ptn_tltg;
create table bh_ptn_tltg
    (ma_dvi varchar2(10),
    tltg number,
    tlph number,
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10));
create unique index bh_ptn_tltg_i1 on bh_ptn_tltg(tltg);