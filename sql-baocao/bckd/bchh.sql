create or replace procedure BBH_HH_TH(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
as
    b_lenh varchar2(1000);b_loi varchar2(100);b_i1 number;
    b_ma_dviB varchar2(20); b_ma_dl varchar2(20);b_ma_cb varchar2(20);b_ma_kh varchar2(20);
    b_phong varchar2(20);b_nguon varchar2(20); b_ngayd number;b_ngayc number; b_ngay_bc varchar2(100); b_ngay_tao varchar2(100);
    dt_ct clob; dt_ds clob;
begin
--bao cao chi tra dai ly tong hop
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise program_error; end if;
PBC_LAY_DVI(b_ma_dvi,b_ma_dviB,b_nsd,b_pas,b_loi);
if b_loi is not null then raise program_error; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,ma_dl,ma_cb,ma_kh,phong,nguon,ngayd,ngayc');
EXECUTE IMMEDIATE b_lenh into b_ma_dviB,b_ma_dl,b_ma_cb,b_ma_kh,b_phong,b_nguon,b_ngayd,b_ngayc using b_oraIn;
b_loi:='loi:lay so lieu hoa hong da duyet:loi';
delete temp_1;delete temp_2;delete temp_3;
delete temp_bc_ts;
insert into temp_bc_ts values (b_ma_dviB||'%',b_ngayd,b_ngayc);
/*
insert into temp_1(c29,c10,c11,c12,n10,n11,c1,n2,n3,n4,n5,n6,n7,n20)
        select ma_dvi,so_hd,ma_kh,ma_kt,so_id,so_id_tt,ma_nt,sum(hhong),sum(hhong_qd),sum(htro),sum(htro_qd),
        sum(thue_hh+thue_ht),sum(thue_hh_qd+thue_ht_qd),ngay_ht
    from v_hh_dduyet
    where (b_ma_dviB is null or b_ma_dviB=ma_dvi) and ngay_ht between b_ngayd and b_ngayc
    and (b_phong is null or b_phong=phong) and (b_ma_cb is null or b_ma_cb=cb_ql)
    and (b_ma_kh is null or b_ma_kh=ma_kh) and (b_ma_dl is null or b_ma_dl=ma_kt)
    group by ma_dvi,so_hd,ma_kh,ma_kt,so_id,so_id_tt,ma_nt,ngay_ht;
*/
insert into temp_1(c29,c10,c11,c12,n10,n11,c1,n2,n3,n4,n5,n6,n7,n20)
        select ma_dvi,so_hd,ma_kh,ma_kt,so_id,so_id_tt,ma_nt,sum(hhong),sum(hhong_qd),sum(htro),sum(htro_qd),
        sum(thue_hh+thue_ht),sum(thue_hh_qd+thue_ht_qd),ngay_ht
    from v_hh_dduyet_ts
    where (b_ma_dviB is null or b_ma_dviB=ma_dvi)
    and (b_phong is null or b_phong=phong) and (b_ma_cb is null or b_ma_cb=cb_ql)
    and (b_ma_kh is null or b_ma_kh=ma_kh) and (b_ma_dl is null or b_ma_dl=ma_kt)
    group by ma_dvi,so_hd,ma_kh,ma_kt,so_id,so_id_tt,ma_nt,ngay_ht;
/*
update temp_1 set (n14)=(select sum(phi)
    from v_bc_bh_dttt_mm where ma_dvi=c29 and so_id_tt=n11 and so_id=n10);
*/
execute immediate 'truncate table temp_bc_bh_dttt_ma_dt';
bc_bh_lay_bc_bh_dttt_ma_dt(b_ma_dviB, b_ngayd, b_ngayc);-- danh thu thuc thu
--update temp_1 set (n14)=(select sum(phi) from temp_bc_bh_dttt_ma_dt where ma_dvi=c29 and so_id_tt=n11 and so_id=n10);
merge into temp_1
    using (select ma_dvi,so_id_tt,so_id,sum(phi) phi from temp_bc_bh_dttt_ma_dt group by ma_dvi,so_id_tt,so_id) a
        on (a.ma_dvi=temp_1.c29 and a.so_id_tt=temp_1.n11 and a.so_id=temp_1.n10)
        when matched then
        update set temp_1.n14 = a.phi;
b_loi:='loi:lay so lieu chi phi khac:loi';
insert into temp_1(c29,n10,n12,n15,n16) select ma_dvi,so_id,ngay_ht,tien_qd,thue_qd from bh_cp
    where (b_ma_dviB is null or b_ma_dviB=ma_dvi) and ngay_ht between b_ngayd and b_ngayc
    and (b_ma_dl is null);
delete temp_2;commit;
select count(*) into b_i1 from temp_bc_dvi;
if b_i1=0 then
    insert into temp_2(c29,c11,c12,n14,n3,n5,n7,n15,n16)
            select c29,c11,c12,sum(nvl(n14,0)),sum(nvl(n3,0)),sum(nvl(n5,0)),sum(nvl(n7,0)),sum(nvl(n15,0)),sum(nvl(n16,0))
        from temp_1 group by c29,c12,c11;
else
    insert into temp_2(c29,c11,c12,n14,n3,n5,n7,n15,n16)
            select c29,c11,c12,sum(nvl(n14,0)),sum(nvl(n3,0)),sum(nvl(n5,0)),sum(nvl(n7,0)),sum(nvl(n15,0)),sum(nvl(n16,0))
        from temp_1,temp_bc_dvi where c29=dvi group by c29,c12,c11;
end if;
b_loi:='loi:cap nhat ten khach hang, dai ly:loi';
--update temp_2 set (c14,c15)=(select ten,tax from bh_dl_ma_kh where ma_dvi=c29 and ma=c12);
update
    (select temp_2.c14 temp_c14, temp_2.c15 temp_c15, bh_dl_ma_kh.ten bh_dl_ma_kh_ten, bh_dl_ma_kh.cmt bh_dl_ma_kh_tax
        from temp_2, bh_dl_ma_kh
        where temp_2.c29 = bh_dl_ma_kh.ma_dvi and temp_2.c12 = bh_dl_ma_kh.ma)
    set temp_c14 = bh_dl_ma_kh_ten, temp_c15 = bh_dl_ma_kh_tax;

--update temp_2 set (c13)=(select ten from bh_hd_ma_kh where ma_dvi=c29 and ma=c11);
update
    (select temp_2.c13 temp_c13, bh_hd_ma_kh.ten bh_hd_ma_kh_ten
        from temp_2, bh_hd_ma_kh
        where temp_2.c29 = bh_hd_ma_kh.ma_dvi and temp_2.c11 = bh_hd_ma_kh.ma)
    set temp_c13 = bh_hd_ma_kh_ten;

update temp_2 set n17=nvl(n3,0)+nvl(n5,0)+nvl(n15,0)-nvl(n7,0)-nvl(n16,0) where c15 is null;
update temp_2 set n17=nvl(n3,0)+nvl(n5,0)+nvl(n15,0)+nvl(n7,0)+nvl(n16,0) where c15 is not null;
-- dt_ct
insert into temp_3(c1,c2) select ma,ten from ht_ma_dvi where ma=b_ma_dviB;
select count(*) into b_i1 from temp_3;
if b_i1=0 and b_phong is not null then
    update temp_3 set (c3,c4) = (select ma,ten from ht_ma_phong where ma=b_phong);
end if;
b_ngay_bc := UNISTR(' - T\1eeb ng\00e0y') || PKH_SO_CNG(b_ngayd) || UNISTR(' \0111\1ebfn ng\00e0y') || PKH_SO_CNG(b_ngayc);
b_ngay_tao := UNISTR('\004E\0067\00E0\0079 ') || to_char(sysdate,'DD') || UNISTR(' \0074\0068\00E1\006E\0067 ') || to_char(sysdate,'MM')
    || UNISTR(' \006E\0103\006D ') || to_char(sysdate,'YYYY');
select json_object('ma_dvi' value c1, 'ten_dvi' value c2, 'ma_phong' value c3, 'ten_phong' value c4, 'ngay_bc' value b_ngay_bc, 'ngay_tao' value b_ngay_tao) into dt_ct from temp_3;
select JSON_ARRAYAGG(json_object('ma_dvi' value c29, 'ten_dvi' value c30, 'ma_phong' value nvl(c12,' '), 'ten_phong' value nvl(c14,' '),
        'ma_dl' value nvl(c12,' '), 'ten_dl' value nvl(c14,' '), 'ma_kh' value nvl(c11,' '), 'ten_kh' value nvl(c13,' '), 'so_hd' value nvl(c10,' '),
        'ngay_tt' value pkh_so_cng(n12), 'phi_dt' value nvl(n14,0), 'hhong' value nvl(n3,0), 'htro' value nvl(n5,0), 'cp' value nvl(n15,0),
        'thue' value nvl(n7,0)+nvl(n16,0), 'ttoan' value nvl(n17,0), 'ngay_duyet' value bcnam_so_ngay_f(n20),
        'tongd' value nvl(n3,0) + nvl(n5,0) + nvl(n15,0), 'tl' value nvl(n3,0) + nvl(n5,0) + nvl(n15,0) + nvl(n7,0)+nvl(n16,0)) returning clob)
         into dt_ds
         from temp_2 where c12 is not null order by c29,c12;
select json_object('dt_ct' value dt_ct, 'dt_ds' value dt_ds returning clob) into b_oraOut from dual;
delete temp_1;delete temp_2;delete temp_3; commit;
exception when others then rollback; raise_application_error(-20105,b_loi);
end;
/
create or replace procedure BBH_HH_CT(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000);b_loi varchar2(100);b_i1 number;
    b_ma_dviB varchar2(20); b_ma_dl varchar2(20);b_ma_cb varchar2(20);b_ma_kh varchar2(20);
    b_phong varchar2(20);b_nguon varchar2(20); b_ngayd number;b_ngayc number; b_ngay_bc varchar2(100); b_ngay_tao varchar2(100);
    dt_ct clob; dt_ds clob;
Begin
-- Bao cao chi tra dai ly chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
--if b_nsd <> 'BCNam' then raise PROGRAM_ERROR; end if;
PBC_LAY_DVI(b_ma_dvi,b_ma_dviB,b_nsd,b_pas,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,ma_dl,ma_cb,ma_kh,phong,nguon,ngayd,ngayc');
EXECUTE IMMEDIATE b_lenh into b_ma_dviB,b_ma_dl,b_ma_cb,b_ma_kh,b_phong,b_nguon,b_ngayd,b_ngayc using b_oraIn;
b_loi:='loi:Lay so lieu hoa hong da duyet:loi';
execute immediate 'truncate table temp_1';
execute immediate 'truncate table temp_2';
execute immediate 'truncate table temp_bc_ts';
--delete temp_1;delete temp_2;commit;
--delete temp_bc_ts;
insert into temp_bc_ts values (b_ma_dviB||'%',b_ngayd,b_ngayc);
/*
insert into temp_1(c29,c10,c11,c12,n10,n11,c1,c2,n2,n3,n4,n5,n6,n7,n20)
        select ma_dvi,so_hd,ma_kh,ma_kt,so_id,so_id_tt,ma_nt,phong,sum(hhong),sum(hhong_qd),sum(htro),
        sum(htro_qd),sum(thue_hh+thue_ht),sum(thue_hh_qd+thue_ht_qd),ngay_ht from V_HH_DDUYET
    where (b_ma_dviB is null or b_ma_dviB=ma_dvi) and ngay_ht between b_ngayd and b_ngayc
    and (b_ma_cb is null or b_ma_cb=cb_ql)
    and (b_ma_kh is null or b_ma_kh=ma_kh) and (b_ma_dl is null or b_ma_dl=ma_kt)
    group by  ma_dvi,so_hd,ma_kh,ma_kt,so_id,so_id_tt,ma_nt,phong,ngay_ht;
*/
execute immediate 'truncate table T_HH_DDUYET_TS_NV_CT';--delete T_HH_DDUYET_TS_NV;
insert into T_HH_DDUYET_TS_NV_CT SELECT p.ma_dvi,
           h.so_id_hh,--h.so_ct,
           lh_nv,
           h.ma_dl,
           h.phong,
           so_hd,
           ma_kh,
           cb_ql,
           g.so_id,
           h.so_id_hh,
           p.so_id_tt,
           h.so_id_kt,
           ma_nt,
           p.hhong,
           p.hhong_qd,
           DECODE (kieu_kt, 'D', thue_hh, 0),
           DECODE (kieu_kt, 'D', thue_hh_qd, 0),
           p.htro,
           p.htro_qd,
           DECODE (kieu_kt, 'D', thue_ht, 0),
           DECODE (kieu_kt, 'D', thue_ht_qd, 0),
           h.ngay_ht,'*',
           g.nsd
      FROM bh_hd_goc g,
           bh_hd_goc_hh_pt p,
           bh_hd_goc_hh h,
           temp_bc_ts ts
     WHERE     h.ma_dvi LIKE ts.ma_dvi
           AND h.ngay_ht BETWEEN ts.ngayd AND ts.ngayc
           AND h.ma_dvi = p.ma_dvi
           AND p.so_id_hh = h.so_id_hh
          -- AND g.ma_dvi = p.ma_dvi
        AND g.so_id = p.so_id /*and p.hhong>0*/;

--huy hop dong
/*insert into T_HH_DDUYET_TS_NV_CT
SELECT p.ma_dvi,h.so_ct,lh_nv, h.ma_dl,h.phong,so_hd,ma_kh,cb_ql,g.so_id,h.so_id_hh, p.so_id_tt,h.so_id_kt,C.ma_nt,
           C.hhong,C.hhong_qd,0,0,c.htro,
           c.htro_qd,0,0, h.ngay_ht, 'H', g.nsd
      FROM bh_hd_goc g, bh_hd_goc_ttpt p,bh_hd_goc_hh h, temp_bc_ts ts, bh_hd_goc_hh_ct c
     WHERE     h.ma_dvi LIKE ts.ma_dvi
           AND h.ngay_ht BETWEEN ts.ngayd AND ts.ngayc
           AND h.ma_dvi = p.ma_dvi
             AND c.so_id_tt = p.so_id_tt
           AND c.so_id_hh = h.so_id_hh PBH_HD_HH_NH_NHPBH_HD_HH_NH_NH
           AND c.so_id = p.so_id
           AND g.so_id = p.so_id and p.pt='H' and c.hhong_qd<0;*/

/*if a_so_id(b_lp)=a_so_id_tt(b_lp) and FBH_HD_HU(b_ma_dviB,a_so_id(b_lp))='C' then
        b_pthuc:='H';
    else
        b_pthuc:='*';
    end if;*/

update T_HH_DDUYET_TS_NV_CT set pt='H' where  so_id=so_id_tt and FBH_HD_HU(ma_dvi,so_id)='C' and hhong<0;
--sua xong dau nhap thi rao lai cau update duoi
update T_HH_DDUYET_TS_NV_CT a set a.pt=(select max(pt) from bh_hd_goc_ttpt where so_id_tt=a.so_id_tt and ma_dvi=a.ma_dvi and so_id=a.so_id and lh_nv=a.lh_nv and pt<>'H') where a.pt<> 'H'; 
insert into temp_1(c29,c10,c11,c12,n10,n11,c1,c2,n2,n3,n4,n5,n6,n7,n20,c30,c31,c32)
        select ma_dvi,so_hd,ma_kh,ma_kt,so_id,so_id_tt,ma_nt,phong,sum(hhong),sum(hhong_qd),sum(htro),
        sum(htro_qd),sum(thue_hh+thue_ht),sum(thue_hh_qd+thue_ht_qd),ngay_ht,lh_nv,nsd,pt from T_HH_DDUYET_TS_NV_CT--V_HH_DDUYET_TS_NV
    where (b_ma_dviB is null or b_ma_dviB=ma_dvi)
    and (b_ma_cb is null or b_ma_cb=cb_ql)
    and (b_ma_kh is null or b_ma_kh=ma_kh) and (b_ma_dl is null or b_ma_dl=ma_kt)
    group by ma_dvi,so_hd,ma_kh,ma_kt,so_id,so_id_tt,so_id_hh,ma_nt,phong,ngay_ht,lh_nv,nsd,pt;

if b_phong is not null then delete temp_1 where c2<>b_phong; end if;

update temp_1 set n13=(Select min(ngay_ht) from bh_hd_goc_ttpt where ma_dvi=c29 and so_id_tt=n11 and so_id=n10);

--update temp_1 set (n14)=(select sum(nvl(phi,0))
--    from V_BC_BH_DTTT_MM where ma_dvi=c29 and so_id_tt=n11 and so_id=n10 and lh_nv=c30 group by ma_dvi,so_id,so_id_tt,pt);
--update V_BC_BH_DTTT_MM set pt = 'G' where pt='*';

--update temp_1 set (n14)=(select sum(nvl(phi,0)) from V_BC_BH_DTTT_MM where ma_dvi=c29 and so_id_tt=n11 and so_id=n10 and c32=pt and lh_nv=c30 group by ma_dvi,so_id,so_id_tt,pt); --and c32=pt
update temp_1 set (n14)=(select sum(nvl(phi_qd,0)) from bh_hd_goc_ttpt where ma_dvi=c29 and so_id_tt=n11 and so_id=n10 and c32=pt and lh_nv=c30 group by ma_dvi,so_id,so_id_tt,pt); --and c32=pt
--update temp_1 set n14 = n14*(-1) where c32='H';

--update temp_1 set (c10,c11,c12)=(select min(so_hd),min(ma_kh),min(ma_kt) from bh_hd_goc where ma_dvi=c29 and so_id=n10);
b_loi:='loi:Lay so lieu chi phi khac:loi';
insert into temp_1(c29,n10,n12,n15,n16) select ma_dvi,so_id,ngay_ht,tien_qd,thue_qd from bh_cp
    where (b_ma_dviB is null or b_ma_dviB=ma_dvi) and ngay_ht between b_ngayd and b_ngayc
    and (b_ma_dl is null);
b_loi:='loi:Cap nhat ten khach hang, dai ly:loi';
--update temp_1 set c13=(select ten from bh_hd_ma_kh where ma_dvi=c29 and ma=c11);
update
    (select temp_2.c13 temp_c13, bh_hd_ma_kh.ten bh_hd_ma_kh_ten
        from temp_2, bh_hd_ma_kh
        where temp_2.c29 = bh_hd_ma_kh.ma_dvi and temp_2.c11 = bh_hd_ma_kh.ma)
    set temp_c13 = bh_hd_ma_kh_ten;
/*
update temp_1 set (c14,c15,c16,c17,c18,c19)=(select ten,tax,hd_dly,gcn_hd,to_char(ngay_d,'dd/mm/yyyy'),to_char(ngay_c,'dd/mm/yyyy')
    from bh_dl_ma_kh where ma_dvi=c29 and ma=c12);
*/
merge into temp_1
    using bh_dl_ma_kh
    on (temp_1.c29 = bh_dl_ma_kh.ma_dvi and temp_1.c12 = bh_dl_ma_kh.ma)
    when matched then
    update set temp_1.c14 = bh_dl_ma_kh.ten, temp_1.c15 = bh_dl_ma_kh.cmt,-- temp_1.c16 = bh_dl_ma_kh.nhom,
        temp_1.c17 = bh_dl_ma_kh.ma,-- temp_1.c18 = PKH_SO_CNG(bh_dl_ma_kh.ngay_bd),
         temp_1.c19 = PKH_SO_CNG(bh_dl_ma_kh.ngay_kt);

update temp_1 set n17=nvl(n3,0)+nvl(n5,0)+nvl(n15,0)-nvl(n7,0)-nvl(n16,0) where c15 is null;
update temp_1 set n17=nvl(n3,0)+nvl(n5,0)+nvl(n15,0)+nvl(n7,0)+nvl(n16,0) where c15 is not null;
update temp_1 set n19=(select ngay_cap from bh_hd_goc where ma_dvi=c29 and so_id=n10);
update temp_1 set n21 = (select nvl(hhong_tl,0) from bh_hd_goc_ttpb where rownum=1 and n10=so_id and n11=so_id_tt and lh_nv = c30 and ma_dvi = c29);
--delete temp_1 where PKH_SO_CNG(n13)='//';
select count(*) into b_i1 from temp_bc_dvi;
commit;
-- dt_ct
insert into temp_3(c1,c2) select ma,ten from ht_ma_dvi where ma=b_ma_dviB;
select count(*) into b_i1 from temp_3;
if b_i1=0 and b_phong is not null then 
    update temp_3 set (c3,c4) = (select ma,ten from ht_ma_phong where ma=b_phong);
end if;
b_ngay_bc := UNISTR(' - T\1eeb ng\00e0y') || PKH_SO_CNG(b_ngayd) || UNISTR(' \0111\1ebfn ng\00e0y') || PKH_SO_CNG(b_ngayc);
b_ngay_tao := UNISTR('\004E\0067\00E0\0079 ') || to_char(sysdate,'DD') || UNISTR(' \0074\0068\00E1\006E\0067 ') || to_char(sysdate,'MM')
    || UNISTR(' \006E\0103\006D ') || to_char(sysdate,'YYYY');
select json_object('ma_dvi' value c1, 'ten_dvi' value c2, 'ma_phong' value c3, 'ten_phong' value c4, 'ngay_bc' value b_ngay_bc, 'ngay_tao' value b_ngay_tao) into dt_ct from temp_3;
if b_i1=0 then
 select JSON_ARRAYAGG(json_object('ma_dvi' value c29,'ma_dl' value nvl(c12,' '), 'ten_dl' value nvl(c14,' '),'hd_dly' value c16,
        'ngay_bd' value c18, 'ngay_kt' value c19, 'ten_kh' value nvl(c13,' '), 'so_hd' value nvl(c10,' '), 'ngay_cap' value bcnam_so_ngay_f(n19),
        'ngay_tt' value pkh_so_cng(n13), 'phi_dt' value nvl(n14,0), 'hhong' value nvl(n3,0), 'htro' value nvl(n5,0), 'cp' value nvl(n15,0),
        'thue' value nvl(n7,0)+nvl(n16,0), 'ttoan' value nvl(n17,0), 'ngay_duyet' value bcnam_so_ngay_f(n20), 'lhnv' value c30, 'nsd' value c31,
         'tlhh' value n21) returning clob)
         into dt_ds
         from temp_1 where c12 is not null order by c29,c12,c11,n12,c10;
else
select JSON_ARRAYAGG(json_object('ma_dvi' value c29,'ma_dl' value nvl(c12,' '), 'ten_dl' value nvl(c14,' '),'hd_dly' value c16,
        'ngay_bd' value c18, 'ngay_kt' value c19, 'ten_kh' value nvl(c13,' '), 'so_hd' value nvl(c10,' '), 'ngay_cap' value bcnam_so_ngay_f(n19),
        'ngay_tt' value pkh_so_cng(n13), 'phi_dt' value nvl(n14,0), 'hhong' value nvl(n3,0), 'htro' value nvl(n5,0), 'cp' value nvl(n15,0),
        'thue' value nvl(n7,0)+nvl(n16,0), 'ttoan' value nvl(n17,0), 'ngay_duyet' value bcnam_so_ngay_f(n20), 'lhnv' value c30, 'nsd' value c31,
         'tlhh' value n21) returning clob)
         into dt_ds
         from temp_1,temp_bc_dvi where c29=dvi and c12 is not null order by c29,c12,c11,n12,c10;
end if;
select json_object('dt_ct' value dt_ct, 'dt_ds' value dt_ds returning clob) into b_oraOut from dual;
exception when others then rollback; raise_application_error(-20105,b_loi);
end;
/
create or replace procedure BBH_HH_PS(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000);b_loi varchar2(100);b_i1 number;
    b_ma_dviB varchar2(20); b_ma_dl varchar2(20);b_ma_cb varchar2(20);b_ma_kh varchar2(20);
    b_phong varchar2(20);b_nguon varchar2(20); b_ngayd number;b_ngayc number; b_ngay_bc varchar2(100); b_ngay_tao varchar2(100);
    dt_ct clob; dt_ds clob;
begin
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete ket_qua;delete temp_1;delete temp_2;delete temp_3;delete temp_4; delete temp_5;
PBC_LAY_DVI(b_ma_dvi,b_ma_dviB,b_nsd,b_pas,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,ma_dl,ma_cb,ma_kh,phong,nguon,ngayd,ngayc');
EXECUTE IMMEDIATE b_lenh into b_ma_dviB,b_ma_dl,b_ma_cb,b_ma_kh,b_phong,b_nguon,b_ngayd,b_ngayc using b_oraIn;
b_loi:='loi:Lay so lieu hoa hong da duyet:loi';
PBC_LAY_DVI(b_ma_dvi,b_ma_dviB,b_nsd,b_pas,b_loi);
if b_loi is not null then raise program_error; end if;
b_loi:='loi:Lay so lieu hoa hong phat sinh:loi';
--  chuyen view v_hh_dduyet_ts
/*
insert into temp_3(c29,c10,c11,c12,n10,n11,n2,n3,n4,n5,n6,n7,n8,n9) select
    ma_dvi,so_hd,ma_kh,ma_kt,so_id,so_id_tt,sum(hhong),sum(hhong_qd),sum(htro),sum(htro_qd),0,0,0,0 from v_hh_dduyet
    where (b_ma_dvi is null or b_ma_dvi=ma_dvi)
    and ngay_ht between b_ngayd and b_ngayc
    and (b_phong is null or b_phong=phong)
    and (b_ma_cb is null or b_ma_cb=cb_ql)
    and (b_ma_kh is null or b_ma_kh=ma_kh) group by ma_dvi,so_hd,ma_kh,ma_kt,so_id,so_id_tt;
*/

delete temp_bc_ts;
insert into temp_bc_ts values (b_ma_dvi||'%',b_ngayd,b_ngayc);
insert into temp_3(c29,c10,c11,c12,n10,n11,n2,n3,n4,n5,n6,n7,n8,n9) select
    ma_dvi,so_hd,ma_kh,ma_kt,so_id,so_id_tt,sum(hhong),sum(hhong_qd),sum(htro),sum(htro_qd),0,0,0,0 from v_hh_dduyet_ts
    where (b_ma_dvi is null or b_ma_dvi=ma_dvi)
    and ngay_ht between b_ngayd and b_ngayc
    and (b_phong is null or b_phong=phong)
    and (b_ma_cb is null or b_ma_cb=cb_ql)
    and (b_ma_kh is null or b_ma_kh=ma_kh) group by ma_dvi,so_hd,ma_kh,ma_kt,so_id,so_id_tt;

insert into temp_3(c29,c10,c11,c12,n10,n11,n2,n3,n4,n5,n6,n7,n8,n9)
    select ma_dvi,so_hd,ma_kh,ma_kt,so_id,so_id_tt,0,0,0,0,sum(hhong),sum(hhong_qd),sum(htro),sum(htro_qd) from v_hh_cduyet_md
    where (b_ma_dvi is null or b_ma_dvi=ma_dvi)
    and ngay_ht between b_ngayd and b_ngayc
    and (b_phong is null or b_phong=phong)
    and (b_ma_cb is null or b_ma_cb=cb_ql)
    and (b_ma_kh is null or b_ma_kh=ma_kh)  group by ma_dvi,so_hd,ma_kh,ma_kt,so_id,so_id_tt;

insert into temp_4(c29,c10,c11,c12,n10,n11,n2,n3,n4,n5,n6,n7,n8,n9)
    select c29,c10,c11,c12,n10,n11,sum(nvl(n2,0)),sum(nvl(n3,0)),sum(nvl(n4,0)),sum(nvl(n5,0)),
        sum(nvl(n6,0)),sum(nvl(n7,0)),sum(nvl(n8,0)),sum(nvl(n9,0))
    from temp_3 group by c29,c10,c11,c12,n10,n11;

delete temp_bc_ts;
insert into temp_bc_ts values (b_ma_dvi||'%',b_ngayd,b_ngayc);
--update temp_4 set (n14)=(select sum(phi)
    --from v_bc_bh_dttt_mm where ma_dvi=c29 and so_id_tt=n11 and so_id=n10);

select count(*) into b_i1 from temp_bc_dvi;
if b_i1=0 then
    insert into ket_qua(c29,c11,c12,n14,n2,n3,n4,n5,n6,n7,n8,n9)
        select c29,c11,c12,sum(nvl(n14,0)),sum(nvl(n2,0)),sum(nvl(n3,0)),sum(nvl(n4,0)),sum(nvl(n5,0)),
        sum(nvl(n6,0)),sum(nvl(n7,0)),sum(nvl(n8,0)),sum(nvl(n9,0))
        from temp_4 group by c29,c11,c12;
else
    insert into ket_qua(c29,c11,c12,n14,n2,n3,n4,n5,n6,n7,n8,n9)
        select c29,c11,c12,sum(nvl(n14,0)),sum(nvl(n2,0)),sum(nvl(n3,0)),sum(nvl(n4,0)),sum(nvl(n5,0)),
        sum(nvl(n6,0)),sum(nvl(n7,0)),sum(nvl(n8,0)),sum(nvl(n9,0))
        from temp_4,temp_bc_dvi where c29=dvi group by c29,c11,c12;

end if;
update ket_qua set n3=0 where n2=0;
update ket_qua set n5=0 where n4=0;
update ket_qua set n7=0 where n6=0;
update ket_qua set n9=0 where n8=0;
b_loi:='loi:Cap nhat ten khach hang, dai ly:loi';
update ket_qua set c14=(select ten from bh_dl_ma_kh where ma_dvi=c29 and ma=c12);
--update ket_qua set c13=(select ten from bh_hd_ma_kh where ma_dvi=c29 and ma=c11);
update
    (select ket_qua.c13 ket_qua_c13, bh_hd_ma_kh.ten bh_hd_ma_kh_ten
              from ket_qua, bh_hd_ma_kh
             where ket_qua.c29 = bh_hd_ma_kh.ma_dvi and ket_qua.c11 = bh_hd_ma_kh.ma)
       set ket_qua_c13 = bh_hd_ma_kh_ten;
commit;
insert into temp_5(c1,c2) select ma,ten from ht_ma_dvi where ma=b_ma_dviB;
select count(*) into b_i1 from temp_5;
if b_i1=0 and b_phong is not null then
    update temp_5 set (c3,c4) = (select ma,ten from ht_ma_phong where ma=b_phong);
end if;
b_ngay_bc := UNISTR(' - T\1eeb ng\00e0y') || PKH_SO_CNG(b_ngayd) || UNISTR(' \0111\1ebfn ng\00e0y') || PKH_SO_CNG(b_ngayc);
b_ngay_tao := UNISTR('\004E\0067\00E0\0079 ') || to_char(sysdate,'DD') || UNISTR(' \0074\0068\00E1\006E\0067 ') || to_char(sysdate,'MM')
    || UNISTR(' \006E\0103\006D ') || to_char(sysdate,'YYYY');
select json_object('ma_dvi' value c1, 'ten_dvi' value c2, 'ma_phong' value nvl(c3,' '), 'ten_phong' value nvl(c4,' '), 'ngay_bc' value b_ngay_bc, 'ngay_tao' value b_ngay_tao) into dt_ct from temp_5;
select JSON_ARRAYAGG(json_object('ma_dvi' value c29,'ma_dl' value nvl(c12,' '), 'ten_dl' value nvl(c14,' '),
        'ma_kh' value nvl(c11,' '),'ten_kh' value nvl(c13,' '),'phi_dt' value nvl(n14,0), 'hhong_dd' value nvl(n3,0), 'htro_dd' value nvl(n5,0), 'cp_dd' value nvl(n15,0),
        'hhong_cd' value nvl(n7,0), 'htro_cd' value nvl(n9,0), 'cp_cd' value 0,'tongd' value nvl(n3,0) + nvl(n5,0) + nvl(n15,0) + nvl(n7,0) + nvl(n9,0)) returning clob)
         into dt_ds
         from ket_qua where c11 is not null or c12 is not null order by c29,c12,c13;
select json_object('dt_ct' value dt_ct, 'dt_ds' value dt_ds returning clob) into b_oraOut from dual;
delete ket_qua;delete temp_1;delete temp_2;delete temp_3;delete temp_4; delete temp_5;
commit;
exception when others then rollback; raise_application_error(-20105,b_loi);
end;
/
create or replace procedure BC_BH_LAY_BC_BH_DTTT_MM
    (b_ma_dvi varchar2, b_ngayd number, b_ngayc number)
AS
begin
if b_ma_dvi is not null then 
    insert into TEMP_BC_BH_DTTT_MM 
        select goc.ma_dvi, goc.so_hd, goc.nv, goc.kieu_hd, goc.ma_kh, goc.ma_gt, goc.cb_ql, goc.phong, goc.kieu_kt, goc.ma_kt,
            PKH_SO_DATE(goc.ngay_hl), PKH_SO_DATE(goc.ngay_kt), nv.ma_nt, nv.lh_nv, nv.so_id_tt, goc.so_id, goc.ngay_ht, nv.ngay_tt,
            nv.phi_qd, nv.thue_qd, FTT_VND_QD(goc.ma_dvi,nv.ngay_ht,nv.ma_nt,nv.hhong_qd), nv.hhong_qd,
            FTT_VND_QD(goc.ma_dvi,nv.ngay_ht,nv.ma_nt,nv.htro), nv.htro, nv.pt, 0, goc.ma_dvi
            from bh_hd_goc goc, bh_hd_goc_ttpt nv
            where nv.ma_dvi like b_ma_dvi||'%' and nv.ngay_ht between b_ngayd and b_ngayc
            and goc.kieu_hd <> 'V' and nv.pt <> 'C'
            and goc.ma_dvi = nv.ma_dvi and goc.so_id = nv.so_id;
    insert into TEMP_BC_BH_DTTT_MM 
        select goc.ma_dvi, goc.so_hd, goc.nv, goc.kieu_hd, goc.ma_kh, goc.ma_gt, goc.cb_ql, goc.phong, goc.kieu_kt, goc.ma_kt,
            PKH_SO_DATE(goc.ngay_hl), PKH_SO_DATE(goc.ngay_hl), nv.ma_nt, nv.lh_nv, nv.so_id_tt, goc.so_id, goc.ngay_ht, nv.ngay_tt,
            -nv.phi_qd, -nv.thue_qd, -FTT_VND_QD(goc.ma_dvi,nv.ngay_ht,nv.ma_nt,nv.hhong_qd), -nv.hhong_qd,
            -FTT_VND_QD(goc.ma_dvi,nv.ngay_ht,nv.ma_nt,nv.htro), -nv.htro, nv.pt, 0, goc.ma_dvi
            from bh_hd_goc goc, bh_hd_goc_ttpt nv, bh_hd_goc_hups c
            where nv.ma_dvi like b_ma_dvi||'%' and nv.ngay_ht between b_ngayd and b_ngayc
            and nv.pt <> 'C' and nv.phi < 0
            and goc.ma_dvi = nv.ma_dvi and goc.so_id = nv.so_id
            and goc.ma_dvi = c.ma_dvi and goc.so_id = c.so_id and nv.ma_nt = c.ma_nt
            and c.no <> 0 and c.tra = 0 and goc.kieu_hd not in ('V', 'N') and nv.so_id = nv.so_id_tt;
    insert into TEMP_BC_BH_DTTT_MM 
        select goc.ma_dvi, goc.so_hd, goc.nv, goc.kieu_hd, goc.ma_kh, goc.ma_gt, goc.cb_ql, goc.phong, goc.kieu_kt, goc.ma_kt,
            PKH_SO_DATE(goc.ngay_hl), PKH_SO_DATE(goc.ngay_kt), nv.ma_nt, nv.lh_nv, nv.so_id_tt, goc.so_id, goc.ngay_ht, nv.ngay_tt,
            -nv.phi_qd * c.pt / 100, -nv.thue_qd * c.pt / 100, 0, 0, 0, 0, '', 0, goc.ma_dvi
            from bh_hd_goc goc, bh_hd_goc_ttpt nv,
                (select * from bh_hd_do_tl
                    where pthuc = 'C' ) c -- viet anh -- bo kieu = 'D' and ph = 'K'
            where nv.ma_dvi like b_ma_dvi and nv.ngay_ht between b_ngayd and b_ngayc and nv.pt <> 'C'
            and goc.ma_dvi = nv.ma_dvi and goc.so_id = nv.so_id
            and goc.ma_dvi = c.ma_dvi and goc.so_id = c.so_id and nv.so_id = c.so_id
            and (nv.lh_nv = c.lh_nv or c.lh_nv = '*');
    insert into TEMP_BC_BH_DTTT_MM 
        select nv.ma_dvi, goc.so_hd, goc.nv, goc.kieu_hd, goc.ma_kh, goc.ma_gt, goc.cb_ql, nv.phong, goc.kieu_kt, goc.ma_kt,
            PKH_SO_DATE(goc.ngay_hl), PKH_SO_DATE(goc.ngay_kt), nv.ma_nt, nv.lh_nv, nv.so_id_tt, goc.so_id, goc.ngay_ht, nv.ngay_ht,
            nv.phi_qd, 0, 0, 0, 0, 0, 'G', 1, goc.ma_dvi
            from bh_hd_goc goc, bh_hd_goc_ttpb nv
            where nv.ma_dvi like b_ma_dvi and nv.ngay_ht between b_ngayd and b_ngayc
            and nv.pthuc in ('D', 'P') and nv.pt <> 'C' and nv.pt <> 'C'
            and goc.ma_dvi = nv.dvi_xl and goc.so_id = nv.so_id;
    insert into TEMP_BC_BH_DTTT_MM 
        select nv.ma_dvi, goc.so_hd, goc.nv, goc.kieu_hd, goc.ma_kh, goc.ma_gt, goc.cb_ql, nv.phong, goc.kieu_kt, goc.ma_kt,
            PKH_SO_DATE(goc.ngay_hl), PKH_SO_DATE(goc.ngay_kt), nv.ma_nt, nv.lh_nv, nv.so_id_tt, goc.so_id, goc.ngay_ht, nv.ngay_ht,
            -nv.phi_qd, 0, 0, 0, 0, 0, 'G', 1, goc.ma_dvi
            from bh_hd_goc goc, bh_hd_goc_ttpb nv, bh_hd_goc_hups c
            where nv.ma_dvi like b_ma_dvi and nv.ngay_ht between b_ngayd and b_ngayc
            and nv.pthuc in ('D', 'P') and nv.pt <> 'C'
            and goc.ma_dvi = nv.dvi_xl and goc.so_id = nv.so_id
            and goc.so_id = c.so_id and goc.ma_dvi = c.ma_dvi and c.tra <> 0;
            
    insert into TEMP_BC_BH_DTTT_MM 
        select goc.ma_dvi, goc.so_hd, goc.nv, goc.kieu_hd, goc.ma_kh, goc.ma_gt, goc.cb_ql, goc.phong, goc.kieu_kt, goc.ma_kt,
            PKH_SO_DATE(goc.ngay_hl), PKH_SO_DATE(goc.ngay_kt), nv.ma_nt, nv.lh_nv, nv.so_id_tt, goc.so_id, goc.ngay_ht,
            nv.ngay_ht, -nv.phi_qd, 0, 0, 0, 0, 0, 'G', 0, goc.ma_dvi
            from bh_hd_goc goc, bh_hd_goc_ttpb nv
            where goc.ma_dvi like b_ma_dvi||'%'
              and nv.ngay_ht between b_ngayd and b_ngayc
              and nv.pthuc in ('D', 'P') and nv.pt <> 'C' and nv.pt <> 'C'
              and goc.ma_dvi = nv.dvi_xl and nv.ma_dvi <> nv.dvi_xl
              and goc.so_id = nv.so_id  and nv.so_id <> 20130105040243;
else
    insert into TEMP_BC_BH_DTTT_MM 
        select goc.ma_dvi, goc.so_hd, goc.nv, goc.kieu_hd, goc.ma_kh, goc.ma_gt, goc.cb_ql, goc.phong, goc.kieu_kt, goc.ma_kt,
            PKH_SO_DATE(goc.ngay_hl), PKH_SO_DATE(goc.ngay_kt), nv.ma_nt, nv.lh_nv, nv.so_id_tt, goc.so_id, goc.ngay_ht, nv.ngay_tt,
            nv.phi_qd, nv.thue_qd, FTT_VND_QD(goc.ma_dvi,nv.ngay_ht,nv.ma_nt,nv.hhong_qd), nv.hhong_qd,
            FTT_VND_QD(goc.ma_dvi,nv.ngay_ht,nv.ma_nt,nv.htro), nv.htro, nv.pt, 0, goc.ma_dvi
            from bh_hd_goc goc, bh_hd_goc_ttpt nv
            where (b_ma_dvi is null or nv.ma_dvi like b_ma_dvi||'%') and nv.ngay_ht between b_ngayd and b_ngayc
            and goc.kieu_hd <> 'V' and nv.pt <> 'C'
            and goc.ma_dvi = nv.ma_dvi and goc.so_id = nv.so_id;
    insert into TEMP_BC_BH_DTTT_MM 
        select goc.ma_dvi, goc.so_hd, goc.nv, goc.kieu_hd, goc.ma_kh, goc.ma_gt, goc.cb_ql, goc.phong, goc.kieu_kt, goc.ma_kt,
            PKH_SO_DATE(goc.ngay_hl), PKH_SO_DATE(goc.ngay_hl), nv.ma_nt, nv.lh_nv, nv.so_id_tt, goc.so_id, goc.ngay_ht, nv.ngay_tt,
            -nv.phi_qd, -nv.thue_qd, -FTT_VND_QD(goc.ma_dvi,nv.ngay_ht,nv.ma_nt,nv.hhong_qd), -nv.hhong_qd,
            -FTT_VND_QD(goc.ma_dvi,nv.ngay_ht,nv.ma_nt,nv.htro), -nv.htro, nv.pt, 0, goc.ma_dvi
            from bh_hd_goc goc, bh_hd_goc_ttpt nv, bh_hd_goc_hups c
            where (b_ma_dvi is null or nv.ma_dvi like b_ma_dvi||'%') and nv.ngay_ht between b_ngayd and b_ngayc
            and nv.pt <> 'C' and nv.phi < 0
            and goc.ma_dvi = nv.ma_dvi and goc.so_id = nv.so_id
            and goc.ma_dvi = c.ma_dvi and goc.so_id = c.so_id and nv.ma_nt = c.ma_nt
            and c.no <> 0 and c.tra = 0 and goc.kieu_hd not in ('V', 'N') and nv.so_id = nv.so_id_tt;
    insert into TEMP_BC_BH_DTTT_MM 
        select goc.ma_dvi, goc.so_hd, goc.nv, goc.kieu_hd, goc.ma_kh, goc.ma_gt, goc.cb_ql, goc.phong, goc.kieu_kt, goc.ma_kt,
            PKH_SO_DATE(goc.ngay_hl), PKH_SO_DATE(goc.ngay_kt), nv.ma_nt, nv.lh_nv, nv.so_id_tt, goc.so_id, goc.ngay_ht, nv.ngay_tt,
            -nv.phi_qd * c.pt / 100, -nv.thue_qd * c.pt / 100, 0, 0, 0, 0, '', 0, goc.ma_dvi
            from bh_hd_goc goc, bh_hd_goc_ttpt nv,
                (select * from bh_hd_do_tl
                    where pthuc = 'C') c -- viet anh -- bo kieu = 'D' and ph = 'K'
            where (b_ma_dvi is null or nv.ma_dvi like b_ma_dvi||'%') and nv.ngay_ht between b_ngayd and b_ngayc and nv.pt <> 'C'
            and goc.ma_dvi = nv.ma_dvi and goc.so_id = nv.so_id
            and goc.ma_dvi = c.ma_dvi and goc.so_id = c.so_id and nv.so_id = c.so_id
            and (nv.lh_nv = c.lh_nv or c.lh_nv = '*');
    insert into TEMP_BC_BH_DTTT_MM 
        select nv.ma_dvi, goc.so_hd, goc.nv, goc.kieu_hd, goc.ma_kh, goc.ma_gt, goc.cb_ql, nv.phong, goc.kieu_kt, goc.ma_kt,
            PKH_SO_DATE(goc.ngay_hl), PKH_SO_DATE(goc.ngay_kt), nv.ma_nt, nv.lh_nv, nv.so_id_tt, goc.so_id, goc.ngay_ht, nv.ngay_ht,
            nv.phi_qd, 0, 0, 0, 0, 0, 'G', 1, goc.ma_dvi
            from bh_hd_goc goc, bh_hd_goc_ttpb nv
            where (b_ma_dvi is null or nv.ma_dvi like b_ma_dvi||'%') and nv.ngay_ht between b_ngayd and b_ngayc
            and nv.pthuc in ('D', 'P') and nv.pt <> 'C' and nv.pt <> 'C';
  --LAM SACH
--     insert into TEMP_BC_BH_DTTT_MM 
--         select nv.ma_dvi, goc.so_hd, goc.nv, goc.kieu_hd, goc.ma_kh, goc.ma_gt, goc.cb_ql, nv.phong, goc.kieu_kt, goc.ma_kt,
--             PKH_SO_DATE(goc.ngay_hl), PKH_SO_DATE(goc.ngay_kt), nv.ma_nt, nv.lh_nv, nv.so_id_tt, goc.so_id, goc.ngay_ht, nv.ngay_ht,
--             -nv.phi_qd, 0, 0, 0, 0, 0, 'G', 1, goc.ma_dvi
--             from bh_hd_goc goc, bh_hd_goc_ttpb nv, bh_hd_goc_hups c
--             where (b_ma_dvi is null or nv.ma_dvi like b_ma_dvi||'%') and nv.ngay_ht between b_ngayd and b_ngayc
--             and nv.pthuc in ('D', 'P') and nv.pt <> 'C'
--             and goc.ma_dvi = nv.dvi_xl and goc.so_id = nv.so_id
--             and goc.so_id = c.so_id and goc.ma_dvi = c.ma_dvi and c.tra <> 0;
            
--     insert into TEMP_BC_BH_DTTT_MM 
--         select goc.ma_dvi, goc.so_hd, goc.nv, goc.kieu_hd, goc.ma_kh, goc.ma_gt, goc.cb_ql, goc.phong, goc.kieu_kt, goc.ma_kt,
--             PKH_SO_DATE(goc.ngay_hl), PKH_SO_DATE(goc.ngay_kt), nv.ma_nt, nv.lh_nv, nv.so_id_tt, goc.so_id, goc.ngay_ht,
--             nv.ngay_ht, -nv.phi_qd, 0, 0, 0, 0, 0, 'G', 0, goc.ma_dvi
--             from bh_hd_goc goc, bh_hd_goc_ttpb nv
--             where (b_ma_dvi is null or goc.ma_dvi like b_ma_dvi||'%')
--               and nv.ngay_ht between b_ngayd and b_ngayc
--               and nv.pthuc in ('D', 'P') and nv.pt <> 'C' and nv.pt <> 'C'
--               and goc.ma_dvi = nv.dvi_xl and nv.ma_dvi <> nv.dvi_xl
--               and goc.so_id = nv.so_id  and nv.so_id <> 20130105040243;
end if;
end;
/

CREATE OR REPLACE PROCEDURE BC_BH_CHI_HHPS
    (b_madvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000); b_loi varchar2(100); b_i1 number; b_tennv varchar2(500); b_ten_dly varchar2(500); 
    b_ten_phong varchar2(500); b_ten_kh varchar2(500); b_ngayd number; b_ngayc number;b_ngaydn number;
    b_ma_nv varchar2(10);b_dly varchar2(10);b_phong varchar2(10);b_loai varchar2(10);b_ma_kh varchar2(10);b_nguon varchar2(10);
    b_ngay_bc varchar2(100); b_ngay_tao varchar2(100);
    b_ma_dvi varchar2(10);b_chon_bc varchar2(10);dt_ts clob;dt_ct clob;dt_ds clob;
Begin
-- Bao cao hoa hong theo nghiep vu phat sinh sau khi thanh toan phi
b_loi:=FHT_MA_NSD_KTRA(b_madvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,ma_nv,ma_dl,phong,loai,ma_kh,ma_gt,ngayd,ngayc,chon_bc');
EXECUTE IMMEDIATE b_lenh 
into b_ma_dvi,b_ma_nv,b_dly,b_phong,b_loai,b_ma_kh,b_nguon,b_ngayd,b_ngayc,b_chon_bc using b_oraIn;
b_ma_dvi:= nvl(trim(b_ma_dvi),null); b_ma_nv:= nvl(trim(b_ma_nv),null); b_dly:= nvl(trim(b_dly),null); b_phong:= nvl(trim(b_phong),null);
b_loai:= nvl(trim(b_loai),null); b_ma_kh:= nvl(trim(b_ma_kh),null); b_nguon:= nvl(trim(b_nguon),null); b_chon_bc:= nvl(trim(b_chon_bc),null);
--if b_nsd <> 'BCNam' then raise PROGRAM_ERROR; end if;
if b_ngayd is null or b_ngayc is null then
    b_loi:='loi:Nhap ngay bao cao:loi'; raise PROGRAM_ERROR;
end if;
-- Hung them kiem tra chay trong nam do lay luy ke b_ngaydn
if round(b_ngayd,-4)<>round(b_ngayc,-4) then
    b_loi:='loi:Bao cao phai cung nam:loi'; raise PROGRAM_ERROR;
end if;

b_ngaydn:=round(b_ngayc,-4)+101;b_loi:='loi:Ma chua dang ky:loi';
if b_ma_nv is not null then
    select ten into b_tennv from bh_ma_lhnv where ma_dvi=b_ma_dvi and ma=b_ma_nv;
else b_tennv:=' ';
end if;
if b_dly is not null then
    select ten into b_ten_dly from bh_dl_ma_kh where ma_dvi=b_ma_dvi and ma=b_dly;
else b_ten_dly:=' ';
end if;
if b_ma_kh is not null then
    select ten into b_ten_kh from bh_hd_ma_kh where ma_dvi=b_ma_dvi and ma=b_ma_kh;
else b_ten_kh:=' ';
end if;
if b_phong is not null then
    select ten into b_ten_phong from ht_ma_phong where ma_dvi=b_ma_dvi and ma=b_phong;
else b_ten_phong:=' ';
end if;
delete ket_qua;delete temp_1;delete temp_2;delete temp_3;delete temp_4; delete temp_5;commit;
PBC_LAY_DVI(b_madvi,b_ma_dvi,b_nsd,b_pas,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_loai='TT' then
    --Hoa hong Thuc thu trong ky
    EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_BC_BH_DTTT_MM';
    BC_BH_LAY_BC_BH_DTTT_MM(b_ma_dvi,b_ngayd,b_ngayc);
    insert into temp_2 (c29,c1,c3,c4,c5,c10,n1,n2,n5,n10,n7,n8,c14,n11)
        select  ma_dvi,lh_nv,ma_kt,phong,so_hd,ma_kh,phi,hhong,htro,ngay_htnv,BC_TL_HHONG(ma_dvi,ma_kt,lh_nv,ngay_htnv),
            BC_TL_HTRO(ma_dvi,ma_kt,lh_nv,ngay_htnv),kieu_kt,so_id
        from TEMP_BC_BH_DTTT_MM where (b_phong is null or phong=b_phong) and (b_ma_kh is null or ma_kh=b_ma_kh)
        and (b_dly is null or ma_kt=b_dly) and (b_ma_nv is null or lh_nv like b_ma_nv||'%');
    --luy ke
    EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_BC_BH_DTTT_MM';
    BC_BH_LAY_BC_BH_DTTT_MM(b_ma_dvi,b_ngaydn,b_ngayc);
    insert into temp_2 (c29,c1,c3,c4,c5,c10,n3,n4,n6,n10,n7,n8,c14,n11)
        select  ma_dvi,lh_nv,ma_kt,phong,so_hd,ma_kh,phi,hhong,htro,ngay_htnv,BC_TL_HHONG(ma_dvi,ma_kt,lh_nv,ngay_htnv),
            BC_TL_HTRO(ma_dvi,ma_kt,lh_nv,ngay_htnv),kieu_kt,so_id
        from TEMP_BC_BH_DTTT_MM where (b_phong is null or phong=b_phong) and (b_ma_kh is null or ma_kh=b_ma_kh)
        and (b_dly is null or ma_kt=b_dly) and (b_ma_nv is null or lh_nv like b_ma_nv||'%');
elsif b_loai='BH' then
    --Hoa hong Ban hang trong ky
    EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_BC_BH_DTBH_MM';
    BC_BH_LAY_BC_BH_DTBH_MM(b_ma_dvi,b_ngayd,b_ngayc);
    insert into temp_2(c29,c1,c3,c4,c5,c10,n1,n2,n5,n10,n7,n8,c14,n11)
        select  ma_dvi,lh_nv,ma_kt,phong,so_hd,ma_kh,phi,0,0,ngay_htnv,BC_TL_HHONG(ma_dvi,ma_kt,lh_nv,ngay_htnv),
            BC_TL_HTRO(ma_dvi,ma_kt,lh_nv,ngay_htnv),kieu_kt,so_id
        from TEMP_BC_BH_DTBH_MM where (b_phong is null or phong=b_phong) and (b_ma_kh is null or ma_kh=b_ma_kh)
        and (b_dly is null or ma_kt=b_dly) and (b_ma_nv is null or lh_nv like b_ma_nv||'%');
    --luy ke
    EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_BC_BH_DTBH_MM';
    BC_BH_LAY_BC_BH_DTBH_MM(b_ma_dvi,b_ngaydn,b_ngayc);
    insert into temp_2 (c29,c1,c3,c4,c5,c10,n3,n4,n6,n10,n7,n8,c14,n11)
        select  ma_dvi,lh_nv,ma_kt,phong,so_hd,ma_kh,phi,0,0,ngay_htnv,BC_TL_HHONG(ma_dvi,ma_kt,lh_nv,ngay_htnv),
            BC_TL_HTRO(ma_dvi,ma_kt,lh_nv,ngay_htnv),kieu_kt,so_id
        from TEMP_BC_BH_DTBH_MM where (b_phong is null or phong=b_phong) and (b_ma_kh is null or ma_kh=b_ma_kh)
        and (b_dly is null or ma_kt=b_dly) and (b_ma_nv is null or lh_nv like b_ma_nv||'%');
elsif b_loai='PS' then
    --Hoa hong Phat sinh trong ky
    EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_BC_BH_DTPS_MM';
    BC_BH_LAY_BC_BH_DTPS_MM(b_ma_dvi,b_ngayd,b_ngayc);
    insert into temp_2 (c29,c1,c3,c4,c5,c10,n1,n2,n5,n10,n7,n8,c14,n11)
        select  ma_dvi,lh_nv,ma_kt,phong,so_hd,ma_kh,phi,0,0,ngay_htnv,BC_TL_HHONG(ma_dvi,ma_kt,lh_nv,ngay_htnv),
            BC_TL_HTRO(ma_dvi,ma_kt,lh_nv,ngay_htnv),kieu_kt,so_id
        from TEMP_BC_BH_DTPS_MM where (b_phong is null or phong=b_phong) and (b_ma_kh is null or ma_kh=b_ma_kh)
        and (b_dly is null or ma_kt=b_dly) and (b_ma_nv is null or lh_nv like b_ma_nv||'%');
    --luy ke
    EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_BC_BH_DTPS_MM';
    BC_BH_LAY_BC_BH_DTPS_MM(b_ma_dvi,b_ngaydn,b_ngayc);
    insert into temp_2 (c29,c1,c3,c4,c5,c10,n3,n4,n6,n10,n7,n8,c14,n11)
        select  ma_dvi,lh_nv,ma_kt,phong,so_hd,ma_kh,phi,0,0,ngay_htnv,BC_TL_HHONG(ma_dvi,ma_kt,lh_nv,ngay_htnv),
            BC_TL_HTRO(ma_dvi,ma_kt,lh_nv,ngay_htnv),kieu_kt,so_id
        from TEMP_BC_BH_DTPS_MM where (b_phong is null or phong=b_phong) and (b_ma_kh is null or ma_kh=b_ma_kh)
        and (b_dly is null or ma_kt=b_dly) and (b_ma_nv is null or lh_nv like b_ma_nv||'%');
end if;

select count(*) into b_i1 from temp_bc_dvi;
if b_i1=0 then
    insert into ket_qua(c29,c1,c3,c4,c5,c10,n1,n2,n3,n4,n5,n6,n10,n7,n8,c14,n11)
        select c29,c1,c3,c4,c5,c10,sum(n1),sum(n2),sum(n3),sum(n4),sum(n5),sum(n6),n10,n7,n8,c14,n11
        from temp_2 group by c29,c1,c3,c4,c5,c10,n10,n7,n8,c14,n11;
else
    insert into ket_qua(c29,c1,c3,c4,c5,c10,n1,n2,n3,n4,n5,n6,n10,n7,n8,c14,n11)
        select c29,c1,c3,c4,c5,c10,sum(n1),sum(n2),sum(n3),sum(n4),sum(n5),sum(n6),n10,n7,n8,c14,n11
        from temp_2,temp_bc_dvi where c29=dvi
        group by c29,c1,c3,c4,c5,c10,n10,n7,n8,c14,n11;
end if;

update ket_qua set c2=(select ten from bh_ma_lhnv where ma_dvi=ket_qua.c29 and ma=ket_qua.c1);

update ket_qua set (c7,c15,c16) = (select ten,'',PKH_SO_CNG(ngay_kt) from bh_dl_ma_kh where ma_dvi=ket_qua.c29 and ma=ket_qua.c3);

 update ket_qua set c6=(select ten from ht_ma_phong where ma_dvi=ket_qua.c29 and ma=ket_qua.c4);

 update ket_qua set (c11,c12)=(select ten,loai from bh_hd_ma_kh where ma_dvi=ket_qua.c29 and ma=ket_qua.c10);

 update ket_qua set (c13)=(select ten from kh_ma_loai_dn where ma_dvi=ket_qua.c29 and ma=ket_qua.c12);

delete temp_1; commit;

b_chon_bc := nvl(trim(b_chon_bc),'');
case b_chon_bc
    when '1' then
        insert into temp_1 (c1,c2,c3,c4,c5,c6,n1,n2,n3,n4,c10,c11)
            select c3,c4,' ',' ',row_number() over(order by c3),c6,n1,n2,n3,n4,c3,c4
            from (select nvl(c4,' ') c3, nvl(c6,' ') c4, 'CHA' c6, sum(nvl(n1,0)) n1, sum(nvl(n2,0)) n2, sum(nvl(n3,0)) n3, sum(nvl(n4,0)) n4
        from ket_qua group by nvl(c4,' '), nvl(c6,' ')) t order by t.c3;

        insert into temp_1 (c1,c2,c3,c4,c5,c6,n1,n2,n3,n4,c10,c11)
        select q.c1, q.c2, q.c3, q.c4, row_number() over(partition by p.c5 order by q.c1) rn, q.c6, q.n1, q.n2, q.n3, q.n4, q.c1, q.c2
        from (select nvl(c3,' ') c1, nvl(c7,' ') c2, nvl(c4,' ') c3, nvl(c6,' ') c4, 'CON' c6, 
              sum(nvl(n1,0)) n1, sum(nvl(n2,0)) n2, sum(nvl(n3,0)) n3, sum(nvl(n4,0)) n4
            from ket_qua group by nvl(c3,' '), nvl(c7,' '), nvl(c4,' '), nvl(c6,' ')
        ) q join temp_1 p on p.c1 = q.c3 and p.c6 = 'CHA';

    when '2' then
        insert into temp_1 (c1,c2,c3,c4,c5,c6,n1,n2,n3,n4,c10,c11)
            select c3,c4,' ',' ',row_number() over(order by c3),c6,n1,n2,n3,n4,c3,c4
            from (select nvl(c4,' ') c3, nvl(c6,' ') c4, 'CHA' c6, sum(nvl(n1,0)) n1, sum(nvl(n2,0)) n2, sum(nvl(n3,0)) n3, sum(nvl(n4,0)) n4
        from ket_qua group by nvl(c4,' '), nvl(c6,' ')) t order by t.c3;
        
        insert into temp_1 (c1,c2,c3,c4,c5,c6,n1,n2,n3,n4,c10,c11)
        select q.c1, q.c2, q.c3, q.c4, row_number() over(partition by p.c5 order by q.c1) rn, q.c6, q.n1, q.n2, q.n3, q.n4, q.c1, q.c2
        from (select nvl(c1,' ') c1, nvl(c2,' ') c2, nvl(c4,' ') c3, nvl(c6,' ') c4, 'CON' c6, 
              sum(nvl(n1,0)) n1, sum(nvl(n2,0)) n2, sum(nvl(n3,0)) n3, sum(nvl(n4,0)) n4
            from ket_qua group by nvl(c1,' '), nvl(c2,' '), nvl(c4,' '), nvl(c6,' ')
        ) q join temp_1 p on p.c1 = q.c3 and p.c6 = 'CHA';
    
    when '3' then
        insert into temp_1 (c1,c2,c3,c4,c5,c6,n1,n2,n3,n4,c10,c11)
            select c3,c4,' ',' ',row_number() over(order by c3),c6,n1,n2,n3,n4,c3,c4
            from (select nvl(c3,' ') c3, nvl(c7,' ') c4, 'CHA' c6, sum(nvl(n1,0)) n1, sum(nvl(n2,0)) n2, sum(nvl(n3,0)) n3, sum(nvl(n4,0)) n4
        from ket_qua group by nvl(c3,' '), nvl(c7,' ')) t order by t.c3;
        
        insert into temp_1 (c1,c2,c3,c4,c5,c6,n1,n2,n3,n4,c10,c11)
        select q.c1, q.c2, q.c3, q.c4, row_number() over(partition by p.c5 order by q.c1) rn, q.c6, q.n1, q.n2, q.n3, q.n4, q.c1, q.c2
        from (select nvl(c1,' ') c1, nvl(c2,' ') c2, nvl(c3,' ') c3, nvl(c7,' ') c4, 'NVU' c6, 
              sum(nvl(n1,0)) n1, sum(nvl(n2,0)) n2, sum(nvl(n3,0)) n3, sum(nvl(n4,0)) n4
            from ket_qua group by nvl(c1,' '), nvl(c2,' '), nvl(c3,' '), nvl(c7,' ')
        ) q join temp_1 p on p.c1 = q.c3 and p.c6 = 'CHA';
    
    when '4' then
        insert into temp_1 (c1,c2,c3,c4,c5,c6,n1,n2,n3,n4,c10,c11)
            select c3,c4,' ',' ',row_number() over(order by c3),c6,n1,n2,n3,n4,c3,c4
            from (select nvl(c1,' ') c3, nvl(c2,' ') c4, 'CON' c6, sum(nvl(n1,0)) n1, sum(nvl(n2,0)) n2, sum(nvl(n3,0)) n3, sum(nvl(n4,0)) n4
        from ket_qua group by nvl(c1,' '), nvl(c2,' ')) t order by t.c3;

    when '5' then
        insert into temp_1 (c1,c2,c3,c4,c5,c6,n1,n2,n3,n4,c10,c11)
            select c3,c3,' ',' ',row_number() over(order by c3),c6,n1,n2,n3,n4,c3,c3
            from (select nvl(c5,' ') c3, 'CON' c6, sum(nvl(n1,0)) n1, sum(nvl(n2,0)) n2, sum(nvl(n3,0)) n3, sum(nvl(n4,0)) n4
        from ket_qua group by nvl(c5,' ')) t order by t.c3;

    when '6' then
        insert into temp_1 (c1,c2,c3,c4,c5,c6,n1,n2,n3,n4,c10,c11)
            select c3,c4,' ',' ',row_number() over(order by c3),c6,n1,n2,n3,n4,c3,c4
            from (select nvl(c3,' ') c3, nvl(c7,' ') c4, 'CON' c6, sum(nvl(n1,0)) n1, sum(nvl(n2,0)) n2, sum(nvl(n3,0)) n3, sum(nvl(n4,0)) n4
        from ket_qua group by nvl(c3,' '), nvl(c7,' ')) t order by t.c3;

    when '7' then
        insert into temp_1 (c1,c2,c3,c4,c5,c6,n1,n2,n3,n4,c10,c11)
            select c3,c4,' ',' ',row_number() over(order by c3),c6,n1,n2,n3,n4,c3,c4
            from (select nvl(c3,' ') c3, nvl(c7,' ') c4, 'CHA' c6, sum(nvl(n1,0)) n1, sum(nvl(n2,0)) n2, sum(nvl(n3,0)) n3, sum(nvl(n4,0)) n4
        from ket_qua group by nvl(c3,' '), nvl(c7,' ')) t order by t.c3;
        
        insert into temp_1 (c1,c2,c3,c4,c5,c6,n1,n2,n3,n4,c10,c11)
        select q.c1, q.c2, q.c3, q.c4, row_number() over(partition by p.c5 order by q.c1) rn, q.c6, q.n1, q.n2, q.n3, q.n4, q.c1, q.c2
        from (select nvl(c10,' ') c1, nvl(c11,' ') c2, nvl(c3,' ') c3, nvl(c7,' ') c4, 'CON' c6, 
              sum(nvl(n1,0)) n1, sum(nvl(n2,0)) n2, sum(nvl(n3,0)) n3, sum(nvl(n4,0)) n4
            from ket_qua group by nvl(c10,' '), nvl(c11,' '), nvl(c3,' '), nvl(c7,' ')
        ) q join temp_1 p on p.c1 = q.c3 and p.c6 = 'CHA';
    
    when '8' then
        insert into temp_1 (c1,c2,c3,c4,c5,c6,n1,n2,n3,n4,c10,c11)
            select c3,c4,' ',' ',row_number() over(order by c3),c6,n1,n2,n3,n4,c3,c4
            from (select nvl(c10,' ') c3, nvl(c11,' ') c4, 'CON' c6, sum(nvl(n1,0)) n1, sum(nvl(n2,0)) n2, sum(nvl(n3,0)) n3, sum(nvl(n4,0)) n4
        from ket_qua group by nvl(c10,' '), nvl(c11,' ')) t order by t.c3;
end case;
update temp_1 p set p.n10 = to_number(p.c5) * 1000 where p.c6 = 'CHA';
update temp_1 t set t.n10 = (select to_number(p.c5) * 1000 + to_number(t.c5) from temp_1 p where p.c6 = 'CHA' and p.c1 = t.c3) where t.c6 = 'CON';
update temp_1 t set t.c5 = (select max(p.c5) || '.' || t.c5 from temp_1 p where p.c6 = 'CHA' and p.c1 = t.c3)where t.c6 = 'CON' and nvl(t.c3,' ') <> ' ' ;
insert into temp_1 (c6,n1,n2,n3,n4) select 'TONG', sum(nvl(n1,0)), sum(nvl(n2,0)), sum(nvl(n3,0)), sum(nvl(n4,0)) from temp_1 where c6 = 'CON';

insert into temp_5(c1,c2) select ma,ten from ht_ma_dvi where ma=b_ma_dvi;
select count(*) into b_i1 from temp_5;
if b_i1=0 and b_phong is not null then
    update temp_5 set (c3,c4) = (select ma,ten from ht_ma_phong where ma=b_phong);
end if;
b_ngay_bc := UNISTR(' - T\1eeb ng\00e0y') || PKH_SO_CNG(b_ngayd) || UNISTR(' \0111\1ebfn ng\00e0y') || PKH_SO_CNG(b_ngayc);
b_ngay_tao := UNISTR('\004E\0067\00E0\0079 ') || to_char(sysdate,'DD') || UNISTR(' \0074\0068\00E1\006E\0067 ') || to_char(sysdate,'MM')
    || UNISTR(' \006E\0103\006D ') || to_char(sysdate,'YYYY');
select json_object('ma_dvi' value c1, 'ten_dvi' value c2, 'ma_phong' value nvl(c3,' '), 'ten_phong' value nvl(c4,' '), 'ngay_bc' value b_ngay_bc, 'ngay_tao' value b_ngay_tao) into dt_ct from temp_5;
select json_arrayagg(json_object('STT' value c5,'TEN' value c11,'MA' value c10,
    'N1' value FBH_CSO_TIEN(nvl(n1,0),' '),'N2' value FBH_CSO_TIEN(nvl(n2,0),' '),'N3' value FBH_CSO_TIEN(nvl(n3,0),' '),
    'N4' value FBH_CSO_TIEN(nvl(n4,0),' '), 'BAC' value c6) order by n10 returning clob) into dt_ds from temp_1 where nvl(c6,' ') <> 'TONG';
select json_arrayagg(json_object( 'N1' value FBH_CSO_TIEN(nvl(n1,0),' '),'N2' value FBH_CSO_TIEN(nvl(n2,0),' '),
    'N3' value FBH_CSO_TIEN(nvl(n3,0),' '), 'N4' value FBH_CSO_TIEN(nvl(n4,0),' ')) order by n10 returning clob) 
    into dt_ts from temp_1 where nvl(c6,' ') = 'TONG';
select json_object('dt_ds' value dt_ds,'dt_ts' value dt_ts,'dt_ct' value dt_ct returning clob) into b_oraOut from dual;
delete ket_qua;delete temp_1;delete temp_2;delete temp_3;delete temp_4; delete temp_5; commit;
--exception when others then raise_application_error(-20105,b_loi);
end;
/

CREATE OR REPLACE procedure bc_bh_chi_hhdd
    (b_madvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
as
    b_lenh varchar2(1000);b_loi varchar2(100);b_i1 number;b_ngaydn number;
    b_ma_dvi varchar2(20); b_dly varchar2(20);b_ma_cb varchar2(20);b_ma_kh varchar2(20);b_ma_nv varchar2(20);
    b_phong varchar2(20); b_ngayd number;b_ngayc number; b_ngay_bc varchar2(100); b_ngay_tao varchar2(100);
    b_ten_phong varchar2(500);b_ten_dly varchar2(500);b_tennv varchar2(500);b_chon_bc varchar2(10);
    dt_ct clob; dt_ds clob;dt_ts clob;
begin
--if b_nsd='ADMIN' then b_loi:='loi:-'||b_ma_dvi||':loi';raise PROGRAM_ERROR; end if;
b_loi:=FHT_MA_NSD_KTRA(b_madvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,ma_nv,ma_dl,ma_cb,ma_kh,phong,chon_bc,ngayd,ngayc');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_ma_nv,b_dly,b_ma_cb,b_ma_kh,b_phong,b_chon_bc,b_ngayd,b_ngayc using b_oraIn;
b_ma_dvi:= nvl(trim(b_ma_dvi),null); b_ma_nv:= nvl(trim(b_ma_nv),null); b_dly:= nvl(trim(b_dly),null); b_ma_cb:= nvl(trim(b_ma_cb),null);
b_ma_kh:= nvl(trim(b_ma_kh),null); b_phong:= nvl(trim(b_phong),null);
if b_ngayd is null or b_ngayc is null then
    b_loi:='loi:Nhap ngay bao cao:loi'; raise program_error;
end if;
b_ngaydn:=round(b_ngayc,-4)+101;b_loi:='loi:Ma chua dang ky:loi';
if b_ma_nv is not null then
    select ten into b_tennv from bh_ma_lhnv where ma_dvi=b_ma_dvi and ma=b_ma_nv;
else b_tennv:=' ';
end if;
if b_dly is not null then
    select ten into b_ten_dly from bh_dl_ma_kh where ma_dvi=b_ma_dvi and ma=b_dly;
else b_ten_dly:=' ';
end if;
if b_phong is not null then
    select ten into b_ten_phong from ht_ma_phong where ma_dvi=b_ma_dvi and ma=b_phong;
else b_ten_phong:=' ';
end if;
delete temp_5;delete temp_1;delete temp_2;delete ket_qua;commit;
PBC_LAY_DVI(b_madvi,b_ma_dvi,b_nsd,b_pas,b_loi);
if b_loi is not null then raise program_error; end if;

delete temp_bc_ts;
insert into temp_bc_ts values (b_ma_dvi||'%',b_ngayd,b_ngayc);
insert into temp_2(c29,c1,c3,c4,c5,n1,n2)
        select ma_dvi,lh_nv,ma_kt,phong,so_hd,hhong_qd,thue_hh_qd
        from v_hh_dduyet_ts where (b_ma_dvi is null or b_ma_dvi=ma_dvi)
        and ngay_ht between b_ngayd and b_ngayc
        and (b_phong is null or phong=b_phong) and (b_dly is null or ma_kt=b_dly)
        and (b_ma_nv is null or lh_nv like b_ma_nv||'%');
    
delete temp_bc_ts;
insert into temp_bc_ts values (b_ma_dvi||'%',b_ngaydn,b_ngayc);
insert into temp_2(c29,c1,c3,c4,c5,n3,n4)
        select ma_dvi,lh_nv,ma_kt,phong,so_hd,hhong_qd,thue_hh_qd
        from v_hh_dduyet_ts where (b_ma_dvi is null or b_ma_dvi=ma_dvi)
        and ngay_ht between b_ngaydn and b_ngayc
        and (b_phong is null or phong=b_phong) and (b_dly is null or ma_kt=b_dly)
        and (b_ma_nv is null or lh_nv like b_ma_nv||'%');

select count(*) into b_i1 from temp_bc_dvi;
if b_i1=0 then
    insert into ket_qua(c29,c1,c3,c4,c5,n1,n2,n3,n4)
        select c29,c1,c3,c4,c5,sum(n1),sum(n2),sum(n3),sum(n4) from temp_2 group by c29,c1,c3,c4,c5;
else
    insert into ket_qua(c29,c1,c3,c4,c5,n1,n2,n3,n4)
        select c29,c1,c3,c4,c5,sum(n1),sum(n2),sum(n3),sum(n4) from temp_2,temp_bc_dvi where c29=dvi group by c29,c1,c3,c4,c5;
end if;
delete ket_qua where nvl(n2,0)=0 and nvl(n3,0)=0;

update ket_qua set n5=0 where nvl(n2,0)=0 ;
update ket_qua set c2=(select ten from bh_ma_lhnv where ma_dvi=ket_qua.c29
    and ma=ket_qua.c1);
update ket_qua set (c7,c8)=(select ten,'' from bh_dl_ma_kh where ma_dvi=ket_qua.c29
    and ma=ket_qua.c3);
update ket_qua set c6=(select ten from ht_ma_phong where ma_dvi=ket_qua.c29
    and ma=ket_qua.c4);
commit;
b_chon_bc := nvl(trim(b_chon_bc),'');
case b_chon_bc
    when '1' then
        insert into temp_1 (c1,c2,c3,c4,c5,c6,n1,n2,n3,n4,n5,c10,c11)
            select c3,c4,' ',' ',row_number() over(order by c3),c6,n1,n2,n3,n4,n5,c3,c4
            from (select nvl(c4,' ') c3, nvl(c6,' ') c4, 'CHA' c6, sum(nvl(n1,0)) n1, sum(nvl(n2,0)) n2, 
            sum(nvl(n3,0)) n3, sum(nvl(n4,0)) n4, sum(nvl(n5,0)) n5
        from ket_qua group by nvl(c4,' '), nvl(c6,' ')) t order by t.c3;

        insert into temp_1 (c1,c2,c3,c4,c5,c6,n1,n2,n3,n4,n5,c10,c11)
        select q.c1, q.c2, q.c3, q.c4, row_number() over(partition by p.c5 order by q.c1) rn, q.c6, q.n1, q.n2, q.n3, q.n4, q.n5, q.c1, q.c2
        from (select nvl(c3,' ') c1, nvl(c7,' ') c2, nvl(c4,' ') c3, nvl(c6,' ') c4, 'CON' c6, 
              sum(nvl(n1,0)) n1, sum(nvl(n2,0)) n2, sum(nvl(n3,0)) n3, sum(nvl(n4,0)) n4, sum(nvl(n5,0)) n5
            from ket_qua group by nvl(c3,' '), nvl(c7,' '), nvl(c4,' '), nvl(c6,' ')
        ) q join temp_1 p on p.c1 = q.c3 and p.c6 = 'CHA';

    when '2' then
        insert into temp_1 (c1,c2,c3,c4,c5,c6,n1,n2,n3,n4,n5,c10,c11)
            select c3,c4,' ',' ',row_number() over(order by c3),c6,n1,n2,n3,n4,n5,c3,c4
            from (select nvl(c4,' ') c3, nvl(c6,' ') c4, 'CHA' c6, sum(nvl(n1,0)) n1, sum(nvl(n2,0)) n2,
            sum(nvl(n3,0)) n3, sum(nvl(n4,0)) n4, sum(nvl(n5,0)) n5
        from ket_qua group by nvl(c4,' '), nvl(c6,' ')) t order by t.c3;
        
        insert into temp_1 (c1,c2,c3,c4,c5,c6,n1,n2,n3,n4,n5,c10,c11)
        select q.c1, q.c2, q.c3, q.c4, row_number() over(partition by p.c5 order by q.c1) rn, q.c6, q.n1, q.n2, q.n3, q.n4, q.n5, q.c1, q.c2
        from (select nvl(c1,' ') c1, nvl(c2,' ') c2, nvl(c4,' ') c3, nvl(c6,' ') c4, 'CON' c6, 
              sum(nvl(n1,0)) n1, sum(nvl(n2,0)) n2, sum(nvl(n3,0)) n3, sum(nvl(n4,0)) n4, sum(nvl(n5,0)) n5
            from ket_qua group by nvl(c1,' '), nvl(c2,' '), nvl(c4,' '), nvl(c6,' ')
        ) q join temp_1 p on p.c1 = q.c3 and p.c6 = 'CHA';
    
    when '3' then
        insert into temp_1 (c1,c2,c3,c4,c5,c6,n1,n2,n3,n4,n5,c10,c11)
            select c3,c4,' ',' ',row_number() over(order by c3),c6,n1,n2,n3,n4,n5,c3,c4
            from (select nvl(c3,' ') c3, nvl(c7,' ') c4, 'CHA' c6, sum(nvl(n1,0)) n1, sum(nvl(n2,0)) n2, 
            sum(nvl(n3,0)) n3, sum(nvl(n4,0)) n4, sum(nvl(n5,0)) n5
        from ket_qua group by nvl(c3,' '), nvl(c7,' ')) t order by t.c3;
        
        insert into temp_1 (c1,c2,c3,c4,c5,c6,n1,n2,n3,n4,n5,c10,c11)
        select q.c1, q.c2, q.c3, q.c4, row_number() over(partition by p.c5 order by q.c1) rn, q.c6, q.n1, q.n2, q.n3, q.n4, q.n5, q.c1, q.c2
        from (select nvl(c1,' ') c1, nvl(c2,' ') c2, nvl(c3,' ') c3, nvl(c7,' ') c4, 'CON' c6, 
              sum(nvl(n1,0)) n1, sum(nvl(n2,0)) n2, sum(nvl(n3,0)) n3, sum(nvl(n4,0)) n4, sum(nvl(n5,0)) n5
            from ket_qua group by nvl(c1,' '), nvl(c2,' '), nvl(c3,' '), nvl(c7,' ')
        ) q join temp_1 p on p.c1 = q.c3 and p.c6 = 'CHA';
end case;
update temp_1 p set p.n10 = to_number(p.c5) * 1000 where p.c6 = 'CHA';
update temp_1 t set t.n10 = (select to_number(p.c5) * 1000 + to_number(t.c5) from temp_1 p where p.c6 = 'CHA' and p.c1 = t.c3) where t.c6 = 'CON';
update temp_1 t set t.c5 = (select max(p.c5) || '.' || t.c5 from temp_1 p where p.c6 = 'CHA' and p.c1 = t.c3)where t.c6 = 'CON' and nvl(t.c3,' ') <> ' ' ;
insert into temp_1 (c6,n1,n2,n3,n4) select 'TONG', sum(nvl(n1,0)), sum(nvl(n2,0)), sum(nvl(n3,0)), sum(nvl(n4,0)) from temp_1 where c6 = 'CON';

insert into temp_5(c1,c2) select ma,ten from ht_ma_dvi where ma=b_ma_dvi;
select count(*) into b_i1 from temp_5;
if b_i1=0 and b_phong is not null then
    update temp_5 set (c3,c4) = (select ma,ten from ht_ma_phong where ma=b_phong);
end if;
b_ngay_bc := UNISTR(' - T\1eeb ng\00e0y') || PKH_SO_CNG(b_ngayd) || UNISTR(' \0111\1ebfn ng\00e0y') || PKH_SO_CNG(b_ngayc);
b_ngay_tao := UNISTR('\004E\0067\00E0\0079 ') || to_char(sysdate,'DD') || UNISTR(' \0074\0068\00E1\006E\0067 ') || to_char(sysdate,'MM')
    || UNISTR(' \006E\0103\006D ') || to_char(sysdate,'YYYY');
select json_object('ma_dvi' value c1, 'ten_dvi' value c2, 'ma_phong' value nvl(c3,' '), 'ten_phong' value nvl(c4,' '), 'ngay_bc' value b_ngay_bc, 'ngay_tao' value b_ngay_tao) into dt_ct from temp_5;
select json_arrayagg(json_object('STT' value c5,'TEN' value c11,'MA' value c10,
    'N1' value FBH_CSO_TIEN(nvl(n1,0),' '),'N2' value FBH_CSO_TIEN(nvl(n2,0),' '),'N3' value FBH_CSO_TIEN(nvl(n3,0),' '),
    'N4' value FBH_CSO_TIEN(nvl(n4,0),' '),'N5' value (to_char(nvl(n5,0)) || '%')) order by n10 returning clob) into dt_ds from temp_1 where nvl(c6,' ') <> 'TONG';
select json_arrayagg(json_object( 'N1' value FBH_CSO_TIEN(nvl(n1,0),' '),'N2' value FBH_CSO_TIEN(nvl(n2,0),' '),
    'N3' value FBH_CSO_TIEN(nvl(n3,0),' '), 'N4' value FBH_CSO_TIEN(nvl(n4,0),' '),'N5' value (to_char(nvl(n5,0)) || '%')) order by n10 returning clob) 
    into dt_ts from temp_1 where nvl(c6,' ') = 'TONG';
select json_object('dt_ds' value dt_ds,'dt_ts' value dt_ts,'dt_ct' value dt_ct returning clob) into b_oraOut from dual;
delete ket_qua;delete temp_1;delete temp_2;delete ket_qua;delete temp_bc_ts; delete temp_5; commit;

exception when others then raise_application_error(-20105,b_loi);
end;
/
create or replace PROCEDURE BC_BH_CHI_HTDD
    (b_madvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
as
    b_lenh varchar2(1000);b_loi varchar2(100);b_i1 number;b_ngaydn number;
    b_ma_dvi varchar2(20); b_dly varchar2(20);b_ma_cb varchar2(20);b_ma_kh varchar2(20);b_ma_nv varchar2(20);
    b_phong varchar2(20); b_ngayd number;b_ngayc number; b_ngay_bc varchar2(100); b_ngay_tao varchar2(100);
    b_ten_phong varchar2(500);b_ten_dly varchar2(500);b_tennv varchar2(500);b_chon_bc varchar2(10);
    dt_ct clob; dt_ds clob;dt_ts clob;
Begin
-- Giang bao cao hoa hong da duyet
b_loi:=FHT_MA_NSD_KTRA(b_madvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,ma_nv,ma_dl,ma_cb,ma_kh,phong,chon_bc,ngayd,ngayc');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_ma_nv,b_dly,b_ma_cb,b_ma_kh,b_phong,b_chon_bc,b_ngayd,b_ngayc using b_oraIn;
b_ma_dvi:= nvl(trim(b_ma_dvi),null); b_ma_nv:= nvl(trim(b_ma_nv),null); b_dly:= nvl(trim(b_dly),null); b_ma_cb:= nvl(trim(b_ma_cb),null);
b_ma_kh:= nvl(trim(b_ma_kh),null); b_phong:= nvl(trim(b_phong),null);
if b_ngayd is null or b_ngayc is null then
    b_loi:='loi:Nhap ngay bao cao:loi'; raise PROGRAM_ERROR;
end if;
b_ngaydn:=round(b_ngayc,-4)+101;b_loi:='loi:Ma chua dang ky:loi';
if b_ma_nv is not null then
    select ten into b_tennv from bh_ma_lhnv where ma_dvi=b_ma_dvi and ma=b_ma_nv;
else b_tennv:=' ';
end if;
if b_dly is not null then
    select ten into b_ten_dly from bh_dl_ma_kh where ma_dvi=b_ma_dvi and ma=b_dly;
else b_ten_dly:=' ';
end if;
if b_phong is not null then
    select ten into b_ten_phong from ht_ma_phong where ma_dvi=b_ma_dvi and ma=b_phong;
else b_ten_phong:=' ';
end if;
delete temp_2;delete ket_qua;commit;
PBC_LAY_DVI(b_madvi,b_ma_dvi,b_nsd,b_pas,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
--Chi hoa hong dai ly
insert into temp_2(c29,c1,c3,c4,c5,n1,n2)
    select ma_dvi,lh_nv,ma_kt,phong,so_hd,htro_qd,thue_ht_qd
        from V_HH_DDUYET where (b_ma_dvi is null or b_ma_dvi=ma_dvi)
        and ngay_ht between b_ngayd and b_ngayc
        and (b_phong is null or phong=b_phong) and (b_dly is null or ma_kt=b_dly)
        and (b_ma_nv is null or lh_nv like b_ma_nv||'%');
-- Luy ke
insert into temp_2(c29,c1,c3,c4,c5,n3,n4)
    select ma_dvi,lh_nv,ma_kt,phong,so_hd,htro_qd,thue_ht_qd
        from V_HH_DDUYET where (b_ma_dvi is null or b_ma_dvi=ma_dvi)
        and ngay_ht between b_ngayd and b_ngayc
        and (b_phong is null or phong=b_phong) and (b_dly is null or ma_kt=b_dly)
        and (b_ma_nv is null or lh_nv like b_ma_nv||'%');
select count(*) into b_i1 from temp_bc_dvi;
if b_i1=0 then
    insert into ket_qua(c1,c3,c4,c5,n1,n2,n3,n4)
        select c1,c3,c4,c5,sum(n1),sum(n2),sum(n3),sum(n4) from temp_2 group by c1,c3,c4,c5;
else
    insert into ket_qua(c1,c3,c4,c5,n1,n2,n3,n4)
        select c1,c3,c4,c5,sum(n1),sum(n2),sum(n3),sum(n4) from temp_2,temp_bc_dvi where c29=dvi  group by c1,c3,c4,c5;
end if;
delete ket_qua where NVL(n2,0)=0 and NVL(n3,0)=0;
update ket_qua set n5=5 where nvl(n2,0)<>0 ;
update ket_qua set n5=0 where nvl(n2,0)=0 ;
--ty le khau tru ho tro
update ket_qua set c2=(select ten from bh_ma_lhnv where ma_dvi=b_ma_dvi
    and ma=ket_qua.c1);
update ket_qua set c7=(select ten from bh_dl_ma_kh where ma_dvi=b_ma_dvi
    and ma=ket_qua.c3);
update ket_qua set c6=(select ten from ht_ma_phong where ma_dvi=b_ma_dvi
    and ma=ket_qua.c4);

b_chon_bc := nvl(trim(b_chon_bc),'');
case b_chon_bc
    when '1' then
        insert into temp_1 (c1,c2,c3,c4,c5,c6,n1,n2,n3,n4,n5,c10,c11)
            select c3,c4,' ',' ',row_number() over(order by c3),c6,n1,n2,n3,n4,n5,c3,c4
            from (select nvl(c4,' ') c3, nvl(c6,' ') c4, 'CHA' c6, sum(nvl(n1,0)) n1, sum(nvl(n2,0)) n2, 
            sum(nvl(n3,0)) n3, sum(nvl(n4,0)) n4, sum(nvl(n5,0)) n5
        from ket_qua group by nvl(c4,' '), nvl(c6,' ')) t order by t.c3;

        insert into temp_1 (c1,c2,c3,c4,c5,c6,n1,n2,n3,n4,n5,c10,c11)
        select q.c1, q.c2, q.c3, q.c4, row_number() over(partition by p.c5 order by q.c1) rn, q.c6, q.n1, q.n2, q.n3, q.n4, q.n5, q.c1, q.c2
        from (select nvl(c3,' ') c1, nvl(c7,' ') c2, nvl(c4,' ') c3, nvl(c6,' ') c4, 'CON' c6, 
              sum(nvl(n1,0)) n1, sum(nvl(n2,0)) n2, sum(nvl(n3,0)) n3, sum(nvl(n4,0)) n4, sum(nvl(n5,0)) n5
            from ket_qua group by nvl(c3,' '), nvl(c7,' '), nvl(c4,' '), nvl(c6,' ')
        ) q join temp_1 p on p.c1 = q.c3 and p.c6 = 'CHA';

    when '2' then
        insert into temp_1 (c1,c2,c3,c4,c5,c6,n1,n2,n3,n4,n5,c10,c11)
            select c3,c4,' ',' ',row_number() over(order by c3),c6,n1,n2,n3,n4,n5,c3,c4
            from (select nvl(c4,' ') c3, nvl(c6,' ') c4, 'CHA' c6, sum(nvl(n1,0)) n1, sum(nvl(n2,0)) n2,
            sum(nvl(n3,0)) n3, sum(nvl(n4,0)) n4, sum(nvl(n5,0)) n5
        from ket_qua group by nvl(c4,' '), nvl(c6,' ')) t order by t.c3;
        
        insert into temp_1 (c1,c2,c3,c4,c5,c6,n1,n2,n3,n4,n5,c10,c11)
        select q.c1, q.c2, q.c3, q.c4, row_number() over(partition by p.c5 order by q.c1) rn, q.c6, q.n1, q.n2, q.n3, q.n4, q.n5, q.c1, q.c2
        from (select nvl(c1,' ') c1, nvl(c2,' ') c2, nvl(c4,' ') c3, nvl(c6,' ') c4, 'CON' c6, 
              sum(nvl(n1,0)) n1, sum(nvl(n2,0)) n2, sum(nvl(n3,0)) n3, sum(nvl(n4,0)) n4, sum(nvl(n5,0)) n5
            from ket_qua group by nvl(c1,' '), nvl(c2,' '), nvl(c4,' '), nvl(c6,' ')
        ) q join temp_1 p on p.c1 = q.c3 and p.c6 = 'CHA';
    
    when '3' then
        insert into temp_1 (c1,c2,c3,c4,c5,c6,n1,n2,n3,n4,n5,c10,c11)
            select c3,c4,' ',' ',row_number() over(order by c3),c6,n1,n2,n3,n4,n5,c3,c4
            from (select nvl(c3,' ') c3, nvl(c7,' ') c4, 'CHA' c6, sum(nvl(n1,0)) n1, sum(nvl(n2,0)) n2, 
            sum(nvl(n3,0)) n3, sum(nvl(n4,0)) n4, sum(nvl(n5,0)) n5
        from ket_qua group by nvl(c3,' '), nvl(c7,' ')) t order by t.c3;
        
        insert into temp_1 (c1,c2,c3,c4,c5,c6,n1,n2,n3,n4,n5,c10,c11)
        select q.c1, q.c2, q.c3, q.c4, row_number() over(partition by p.c5 order by q.c1) rn, q.c6, q.n1, q.n2, q.n3, q.n4, q.n5, q.c1, q.c2
        from (select nvl(c1,' ') c1, nvl(c2,' ') c2, nvl(c3,' ') c3, nvl(c7,' ') c4, 'CON' c6, 
              sum(nvl(n1,0)) n1, sum(nvl(n2,0)) n2, sum(nvl(n3,0)) n3, sum(nvl(n4,0)) n4, sum(nvl(n5,0)) n5
            from ket_qua group by nvl(c1,' '), nvl(c2,' '), nvl(c3,' '), nvl(c7,' ')
        ) q join temp_1 p on p.c1 = q.c3 and p.c6 = 'CHA';
end case;
update temp_1 p set p.n10 = to_number(p.c5) * 1000 where p.c6 = 'CHA';
update temp_1 t set t.n10 = (select to_number(p.c5) * 1000 + to_number(t.c5) from temp_1 p where p.c6 = 'CHA' and p.c1 = t.c3) where t.c6 = 'CON';
update temp_1 t set t.c5 = (select max(p.c5) || '.' || t.c5 from temp_1 p where p.c6 = 'CHA' and p.c1 = t.c3)where t.c6 = 'CON' and nvl(t.c3,' ') <> ' ' ;
insert into temp_1 (c6,n1,n2,n3,n4) select 'TONG', sum(nvl(n1,0)), sum(nvl(n2,0)), sum(nvl(n3,0)), sum(nvl(n4,0)) from temp_1 where c6 = 'CON';

insert into temp_5(c1,c2) select ma,ten from ht_ma_dvi where ma=b_ma_dvi;
select count(*) into b_i1 from temp_5;
if b_i1=0 and b_phong is not null then
    update temp_5 set (c3,c4) = (select ma,ten from ht_ma_phong where ma=b_phong);
end if;
b_ngay_bc := UNISTR(' - T\1eeb ng\00e0y') || PKH_SO_CNG(b_ngayd) || UNISTR(' \0111\1ebfn ng\00e0y') || PKH_SO_CNG(b_ngayc);
b_ngay_tao := UNISTR('\004E\0067\00E0\0079 ') || to_char(sysdate,'DD') || UNISTR(' \0074\0068\00E1\006E\0067 ') || to_char(sysdate,'MM')
    || UNISTR(' \006E\0103\006D ') || to_char(sysdate,'YYYY');
select json_object('ma_dvi' value c1, 'ten_dvi' value c2, 'ma_phong' value nvl(c3,' '), 'ten_phong' value nvl(c4,' '), 'ngay_bc' value b_ngay_bc, 'ngay_tao' value b_ngay_tao) into dt_ct from temp_5;
select json_arrayagg(json_object('STT' value c5,'TEN' value c11,'MA' value c10,
    'N1' value FBH_CSO_TIEN(nvl(n1,0),' '),'N2' value FBH_CSO_TIEN(nvl(n2,0),' '),'N3' value FBH_CSO_TIEN(nvl(n3,0),' '),
    'N4' value FBH_CSO_TIEN(nvl(n4,0),' '),'N5' value (to_char(nvl(n5,0)) || '%')) order by n10 returning clob) into dt_ds from temp_1 where nvl(c6,' ') <> 'TONG';
select json_arrayagg(json_object( 'N1' value FBH_CSO_TIEN(nvl(n1,0),' '),'N2' value FBH_CSO_TIEN(nvl(n2,0),' '),
    'N3' value FBH_CSO_TIEN(nvl(n3,0),' '), 'N4' value FBH_CSO_TIEN(nvl(n4,0),' '),'N5' value (to_char(nvl(n5,0)) || '%')) order by n10 returning clob) 
    into dt_ts from temp_1 where nvl(c6,' ') = 'TONG';
select json_object('dt_ds' value dt_ds,'dt_ts' value dt_ts,'dt_ct' value dt_ct returning clob) into b_oraOut from dual;
    exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;