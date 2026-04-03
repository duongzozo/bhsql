drop table bh_in_logo_dl;
create table bh_in_logo_dl(
    ma_kt varchar2(20), 
    logo_path varchar2(500));
create unique index bh_in_logo_dl_u0 on bh_in_logo_dl(ma_kt);