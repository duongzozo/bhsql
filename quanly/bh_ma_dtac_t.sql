drop table bh_dtac_khpl;
create table bh_dtac_khpl
    (nv varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_dtac_khpl_u0 on bh_dtac_khpl(nv,ma);

drop table bh_dtac_ma;
create table bh_dtac_ma
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(500),
    ng_sinh number,
    gioi varchar2(1),
    cmt varchar2(20),           -- cmt,tax
    dchi nvarchar2(500),
    mobi varchar2(20),
    email varchar2(100),--duchq update
    loai varchar2(1),           -- C-Ca nhan, T-To chuc
    nghe varchar2(10),          -- Ca nhan:nghe, To chuc:linh vuc
    c_thue varchar2(1),         -- C - Co thue, K - Khong thue
    nhang varchar2(10),
    ma_tk varchar2(20),
    kvuc varchar2(10),
    ma_ct varchar2(20),
    ngay_kt number,
    nsd varchar2(20));
CREATE unique INDEX bh_dtac_ma_u on bh_dtac_ma(ma);
CREATE INDEX bh_dtac_ma_i1 on bh_dtac_ma(ma_ct);
CREATE INDEX bh_dtac_ma_i2 on bh_dtac_ma(ma_dvi,nsd);

drop table bh_dtac_ma_txt;
create table bh_dtac_ma_txt
    (ma varchar2(20),
    txt clob);
CREATE INDEX bh_dtac_ma_txt_i1 on bh_dtac_ma_txt(ma);

drop table bh_dtac_ma_cmt;
create table bh_dtac_ma_cmt
    (ma varchar2(20),
    cmt varchar2(20),
 tenH varchar2(200));
CREATE INDEX bh_dtac_ma_cmt_i1 on bh_dtac_ma_cmt(cmt);
CREATE INDEX bh_dtac_ma_cmt_i2 on bh_dtac_ma_cmt(ma);

drop table bh_dtac_ma_mobi;
create table bh_dtac_ma_mobi
    (ma varchar2(20),
    mobi varchar2(20),
 tenH varchar2(50));
CREATE INDEX bh_dtac_ma_mobi_i1 on bh_dtac_ma_mobi(mobi);
CREATE INDEX bh_dtac_ma_mobi_i2 on bh_dtac_ma_mobi(ma);

drop table bh_dtac_ma_email;
create table bh_dtac_ma_email
    (ma varchar2(20),
    email varchar2(100),--duchq update
 tenH varchar2(50));
CREATE INDEX bh_dtac_ma_email_i1 on bh_dtac_ma_email(email);
CREATE INDEX bh_dtac_ma_email_i2 on bh_dtac_ma_email(ma);

drop table bh_dtac_ma_ten;
create table bh_dtac_ma_ten
    (ma varchar2(20),
    ten varchar2(100));
CREATE INDEX bh_dtac_ma_ten_i1 on bh_dtac_ma_ten(ma);
CREATE INDEX bh_dtac_ma_ten_i2 on bh_dtac_ma_ten(ten);

drop table bh_dtac_ma_pas;
create table bh_dtac_ma_pas
    (ma varchar2(20),
    pas varchar2(50));
CREATE INDEX bh_dtac_ma_pas_i1 on bh_dtac_ma_pas(ma);

drop table bh_dtac_ma_kthac;
create table bh_dtac_ma_kthac
    (ma varchar2(20),
 ten nvarchar2(500),
    ma_dvi varchar2(10),
    ma_dviX varchar2(10),
    nsdX varchar2(20),
    nvX varchar2(20),
    ngayX date,
    ma_dviC varchar2(10),
    nsdC varchar2(20),
    ngayC date);
CREATE INDEX bh_dtac_ma_kthac_i1 on bh_dtac_ma_kthac(ma,ma_dviX);
CREATE INDEX bh_dtac_ma_kthac_i2 on bh_dtac_ma_kthac(ma_dviC);

drop table bh_dtac_maL;
create table bh_dtac_maL
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(500),
    ng_sinh number,
    gioi varchar2(1),
    cmt varchar2(20),           -- cmt,tax
    dchi nvarchar2(500),
    mobi varchar2(20),
    email varchar2(100),--duchq update
    loai varchar2(1),           -- C-Ca nhan, T-To chuc
    nghe varchar2(10),          -- Ca nhan:nghe, To chuc:linh vuc
    c_thue varchar2(1),         -- C - Co thue, K - Khong thue
    nhang varchar2(10),
    ma_tk varchar2(20),
    kvuc varchar2(10),
    ma_ct varchar2(20),
    ngay_kt number,
    nsd varchar2(20),
    txt clob,
    ngay date);

-- Khach hang bao hiem

drop table bh_hd_ma_kh;
create table bh_hd_ma_kh
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    ng_sinh number,
    gioi varchar2(1),
    cmt varchar2(20),           -- cmt,tax
    dchi nvarchar2(500),
    mobi varchar2(20),
    email varchar2(100),--duchq update
    loai varchar2(1),           -- C-Ca nhan, T-To chuc
    nghe varchar2(10),          -- Ca nhan:nghe, To chuc:linh vuc
    c_thue varchar2(1),         -- C - Co thue, K - Khong thue
    nhang varchar2(10),
    ma_tk varchar2(20),
    kvuc varchar2(10),
    ma_ct varchar2(20),
    ngay_kt number,
    nsd varchar2(20))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_ma_kh_0800 values ('0800'),
        PARTITION bh_hd_ma_kh_DEFA values (DEFAULT));
CREATE unique INDEX bh_hd_ma_kh_u on bh_hd_ma_kh(ma_dvi,ma) local;
CREATE INDEX bh_hd_ma_kh_i2 on bh_hd_ma_kh(nsd) local;

-- Dai ly

drop table bh_dl_ma_kh;
create table bh_dl_ma_kh
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(500),
    ng_sinh number,
    gioi varchar2(1),
    cmt varchar2(20),           -- cmt,tax
    dchi nvarchar2(500),
    mobi varchar2(20),
    email varchar2(100),--duchq update
    loai varchar2(1),           -- C-Ca nhan, T-To chuc
    nghe varchar2(10),          -- Ca nhan:nghe, To chuc:linh vuc
    c_thue varchar2(1),         -- C - Co thue, K - Khong thue
    nhang varchar2(10),
    ma_tk varchar2(20),
    kvuc varchar2(10),
    ma_ct varchar2(20),
    ngay_kt number,
    nsd varchar2(20)
);
create unique index bh_dl_ma_kh_u0 on bh_dl_ma_kh(ma);
CREATE INDEX bh_dl_ma_kh_i1 on bh_dl_ma_kh(ma_ct);
CREATE INDEX bh_dl_ma_kh_i2 on bh_dl_ma_kh(ma_dvi,nsd);

drop table bh_dl_ma_kh_ct;
create table bh_dl_ma_kh_ct
    (ma varchar2(20),
    ma_dvi_ql varchar2(10),
    phong varchar2(10),
    ma_cb varchar2(20));
CREATE INDEX bh_dl_ma_kh_ct_i1 on bh_dl_ma_kh_ct(ma);

-- Hoa hong dai ly

drop table bh_dl_ma_kh_lhnv;
create table bh_dl_ma_kh_lhnv
    (ma_dvi  VARCHAR2(10),
    ma varchar2(20),
    nv varchar2(10),
    lh_nv varchar2(10),
    ten nvarchar2(500),
    kthac number,
    bthuong number,
    hhong number,
    hh_q number,
    hh_f number,
    htro number,
    ht_q number,
    ht_f number,
    dvu number,
    dv_q number,
    dv_f number,
    ngay number,
    nsd     VARCHAR2(10)
    );
CREATE INDEX bh_dl_ma_kh_lhnv_i1 on bh_dl_ma_kh_lhnv(ma,nv,ngay,lh_nv);

-- Ma benh vien

drop table bh_ma_bv;
create table bh_ma_bv
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(500),
    ng_sinh number,
    gioi varchar2(1),
    cmt varchar2(20),           -- cmt,tax
    dchi nvarchar2(500),
    mobi varchar2(20),
    email varchar2(100),--duchq update
    loai varchar2(1),           -- C-Ca nhan, T-To chuc
    nghe varchar2(10),          -- Ca nhan:nghe, To chuc:linh vuc
    c_thue varchar2(1),         -- C - Co thue, K - Khong thue
    nhang varchar2(10),
    ma_tk varchar2(20),
    kvuc varchar2(10),
    ma_ct varchar2(20),
    ngay_kt number,
    nsd varchar2(20)
);
create unique index bh_ma_bv_u0 on bh_ma_bv(ma);
CREATE INDEX bh_ma_bv_i1 on bh_ma_bv(ma_ct);
CREATE INDEX bh_ma_bv_i2 on bh_ma_bv(ma_dvi,nsd);

drop table bh_ma_gara;
create table bh_ma_gara
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(500),
    ng_sinh number,
    gioi varchar2(1),
    cmt varchar2(20),           -- cmt,tax
    dchi nvarchar2(500),
    mobi varchar2(20),
    email varchar2(100),--duchq update
    loai varchar2(1),           -- C-Ca nhan, T-To chuc
    nghe varchar2(10),          -- Ca nhan:nghe, To chuc:linh vuc
    c_thue varchar2(1),         -- C - Co thue, K - Khong thue
    nhang varchar2(10),
    ma_tk varchar2(20),
    kvuc varchar2(10),
    ma_ct varchar2(20),
    ngay_kt number,
    nsd varchar2(20)
);
create unique index bh_ma_gara_u0 on bh_ma_gara(ma);
CREATE INDEX bh_ma_gara_i1 on bh_ma_gara(ma_ct);
CREATE INDEX bh_ma_gara_i2 on bh_ma_gara(ma_dvi,nsd);

drop table bh_ma_gara_ct;
create table bh_ma_gara_ct
    (ma_dvi varchar2(10),
    ma varchar2(20),
    lket varchar2(1),           -- Lien ket
    hang varchar2(20));          -- Chinh hang
CREATE INDEX bh_ma_gara_ct_i1 on bh_ma_gara_ct(ma);

-- Giam dinh

drop table bh_ma_gdinh;
create table bh_ma_gdinh
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(500),
    ng_sinh number,
    gioi varchar2(1),
    cmt varchar2(20),           -- cmt,tax
    dchi nvarchar2(500),
    mobi varchar2(20),
    email varchar2(100),--duchq update
    loai varchar2(1),           -- C-Ca nhan, T-To chuc
    nghe varchar2(10),          -- Ca nhan:nghe, To chuc:linh vuc
    c_thue varchar2(1),         -- C - Co thue, K - Khong thue
    nhang varchar2(10),
    ma_tk varchar2(20),
    kvuc varchar2(10),
    ma_ct varchar2(20),
    ngay_kt number,
    nsd varchar2(20),
    txt clob -- viet anh -- them txt de lam % phi line con nguoi
);
create unique index bh_ma_gdinh_u0 on bh_ma_gdinh(ma);
CREATE INDEX bh_ma_gdinh_i1 on bh_ma_gdinh(ma_ct);
CREATE INDEX bh_ma_gdinh_i2 on bh_ma_gdinh(ma_dvi,nsd);

-- Ma doanh nghiep bao hiem

drop table bh_ma_nbh;
create table bh_ma_nbh
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(500),
    ng_sinh number,
    gioi varchar2(1),
    cmt varchar2(20),           -- cmt,tax
    dchi nvarchar2(500),
    mobi varchar2(20),
    email varchar2(100),--duchq update
    loai varchar2(1),           -- C-Ca nhan, T-To chuc
    nghe varchar2(10),          -- Ca nhan:nghe, To chuc:linh vuc
    c_thue varchar2(1),         -- C - Co thue, K - Khong thue
    nhang varchar2(10),
    ma_tk varchar2(20),
    kvuc varchar2(10),
    ma_ct varchar2(20),
    ngay_kt number,
    nsd varchar2(20)
);
create unique index bh_ma_nbh_u0 on bh_ma_nbh(ma);
CREATE INDEX bh_ma_nbh_i1 on bh_ma_nbh(ma_ct);
CREATE INDEX bh_ma_nbh_i2 on bh_ma_nbh(ma_dvi,nsd);

-- Ma ngan hang

drop table bh_ma_nhang;
create table bh_ma_nhang
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
    cmt varchar2(20),           -- tax
    dchi nvarchar2(500),
    ma_ct varchar2(10),
    ngay_kt varchar2(20),
    nsd varchar2(10),
    txt clob
);
create unique index bh_ma_nhang_u0 on bh_ma_nhang(ma);
CREATE INDEX bh_ma_nhang_i1 on bh_ma_nhang(ma_ct);
CREATE INDEX bh_ma_nhang_i2 on bh_ma_nhang(ma_dvi,nsd);

-- viet anh - them bang txt cho nha bh

drop table bh_ma_nbh_txt;
create table bh_ma_nbh_txt
    (ma varchar2(20),
    txt clob);