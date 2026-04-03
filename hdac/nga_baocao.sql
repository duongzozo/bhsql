create or replace procedure BC_HD_MAT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngayd number,b_ngayc number,
    b_kieu varchar2,b_loai_bp varchar2,b_ma_bp varchar2,b_ma varchar2,b_nhom varchar2,b_ten out nvarchar2,cs_kq out pht_type.cs_type)
AS
    b_loi varchar2(150);b_i1 number;b_c10 varchar2(10);b_c1 varchar2(1);
begin
--Lan--Bang ke hoa don mat,huy,tra lai--
--b_kieu=M-mat,K-huy,T-tra lai,''-mat,hong
--b_loi:=PHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','023');
if b_ma_bp is null then b_loi:='loi:Nhap bo phan:loi'; raise PROGRAM_ERROR; end if;
select min(ma) into b_c10 from ht_ma_dvi where vp='C';
if b_ma_dvi<>b_c10 and b_loai_bp='D' and b_ma_dvi<>b_ma_bp then
   b_loi:='loi:Khong xem so lieu don vi khac:loi'; raise PROGRAM_ERROR;
end if;
---Lay ma dvi---
delete temp_1;
/*temp_1:c1=loai_bp,c2=ma_bp,c3=ma_dl*/
if b_loai_bp='D' then
    insert into temp_1(c1,n1) select a.ma_dvi,a.so_id from hd_1 a,hd_3 b where a.ma_dvi=b_ma_dvi
        and ngay_ht between b_ngayd and b_ngayc and l_ct='X' and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id
        and b.loai_x='D' and a.ma_dvi=b_ma_bp and htoan='H';
    insert into temp_1(c1,n1) select a.ma_dvi,a.so_id from hd_1 a,hd_3 b where a.ma_dvi=b_ma_bp
        and ngay_ht between b_ngayd and b_ngayc and l_ct='X' and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id
        and b.loai_x='B' and a.ma_dvi=b_ma_bp and ma_x in (select ma from ht_ma_phong where ma_dvi=b_ma_bp) and htoan='H';
    insert into temp_1(c1,n1) select a.ma_dvi,a.so_id from hd_1 a,hd_3 b where a.ma_dvi=b_ma_bp
        and ngay_ht between b_ngayd and b_ngayc and l_ct='X' and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id
        and b.loai_x='C' and ma_x in (select ma from ht_ma_nsd where ma_dvi=b_ma_bp) and htoan='H';
    insert into temp_1(c1,n1) select a.ma_dvi,a.so_id from hd_1 a,hd_3 b where a.ma_dvi=b_ma_dvi
        and ngay_ht between b_ngayd and b_ngayc and l_ct='X' and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id
        and b.loai_x='L' and b.ma_x in (select ma from bh_dl_ma_kh where ma_dvi=b_ma_dvi) and htoan='H';
elsif b_loai_bp='B' then
    insert into temp_1(c1,n1) select a.ma_dvi,a.so_id from hd_1 a,hd_3 b where a.ma_dvi=b_ma_dvi
        and ngay_ht between b_ngayd and b_ngayc and l_ct='X' and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id
        and b.loai_x='B' and b.ma_x=b_ma_bp and htoan='H';
    insert into temp_1(c1,n1) select a.ma_dvi,a.so_id from hd_1 a,hd_3 b where a.ma_dvi=b_ma_dvi
        and ngay_ht between b_ngayd and b_ngayc and l_ct='X' and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id
        and b.loai_x='C' and b.ma_x in (select ma from ht_ma_nsd where ma_dvi=b_ma_dvi and phong=b_ma_bp) and htoan='H';
    /*insert into temp_1(c1,n1) select a.ma_dvi,a.so_id from hd_1 a,hd_3 b where a.ma_dvi=b_ma_dvi
        and ngay_ht between b_ngayd and b_ngayc and l_ct='X' and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id
        and b.loai_x='L' and b.ma_x in (select ma from bh_dl_ma_kh where ma_dvi=b_ma_dvi and phong=b_ma_bp) and htoan='H';*/
else
    insert into temp_1(c1,n1) select a.ma_dvi,a.so_id from hd_1 a,hd_3 b where a.ma_dvi=b_ma_dvi
        and ngay_ht between b_ngayd and b_ngayc and l_ct='X' and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id
        and loai_x=b_loai_bp and b.ma_x=b_ma_bp and htoan='H';
end if;
delete ket_qua;
/*ket_qua:c1=ma_dvi,c2=ma,c3=ten,c4=dvt,n1=do_dai,c5=seri,n2=dau,
    n3=cuoi,n4=so_luong,n5=q_dau,n7=so_to,n8=so_quyen,c12=dau_c,c13=cuoi_c
*/
insert into ket_qua(c1,c2,c3,n1,c5,n2,n3,n4,n5,n7,n8,c6)
    select ma_dvi,ma,'',0,seri,dau,cuoi,cuoi-dau+1,0,0,0,ma_tke
    from hd_2 where (ma_dvi,so_id) in (select c1,n1 from temp_1) and (b_ma is null or ma=b_ma) and ma_tke in ('M','H');
update ket_qua set (c3,n7,n1)=(select ten,so_to,do_dai from hd_ma_hd where ma_dvi=c1 and nv||'>'||ma=c2);
update ket_qua set c12=lpad(rtrim(to_char(n2)),n1-length(c5),'0');
update ket_qua set c13=lpad(rtrim(to_char(n3)),n1-length(c5),'0');
if b_loai_bp='D' then select ten into b_ten from ht_ma_dvi where ma=b_ma_bp;
elsif b_loai_bp='B' then select ten into b_ten from ht_ma_phong where ma=b_ma_bp;
elsif b_loai_bp='C' then select ten into b_ten from ht_ma_nsd where ma=b_ma_bp;
end if;
delete ket_qua where c2 not in (select nv||'>'||ma from hd_ma_hd where ma_dvi=b_ma_dvi and (b_nhom is null or ma_nhom=b_nhom));
open cs_kq for select c6 loai,c2 ma,c3 ten,c5 seri,c12 dau,c13 cuoi,n4 so_luong
    from ket_qua order by c6,c2,c5,n2,n3;
exception when others then raise_application_error(-20105,b_loi);
end;
/

create or replace PROCEDURE BC_HD_TH_CK
    (b_ma_dvi varchar2,b_ngayd number,b_ngayc number,b_loai_bp varchar2,b_ma_bp varchar2,b_ma varchar2,b_seri varchar2)
AS
    b_loi varchar2(150);b_thangd number; b_seriN number;
begin
--Lan--Tong hop cuoi ky=so cai thang dau ky + phat sinh
--Sua lai chay nhanh

EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_sl_100';
case b_loai_bp
    when 'D' then
        insert into temp_sl_100 values (b_ma_bp,'D',b_ma_bp);
        insert into temp_sl_100 select ma_dvi,'B',ma from ht_ma_phong where ma_dvi=b_ma_bp;
        insert into temp_sl_100 select ma_dvi,'C',ma from ht_ma_nsd where ma_dvi=b_ma_bp;
        insert into temp_sl_100 select ma_dvi,'L',ma from bh_dl_ma_kh where ma_dvi=b_ma_dvi;
    when 'B' then
        insert into temp_sl_100 values (b_ma_dvi,'B',b_ma_bp);
        insert into temp_sl_100 select ma_dvi,'C',ma from ht_ma_nsd where ma_dvi=b_ma_dvi and phong=b_ma_bp;
        --insert into temp_sl_100 select ma_dvi,'L',ma from bh_dl_ma_kh where ma_dvi=b_ma_dvi and phong=b_ma_bp;
    when 'C' then
        insert into temp_sl_100 values (b_ma_dvi,'C',b_ma_bp);
    when 'L' then
        insert into temp_sl_100 select ma_dvi,'L',ma from bh_dl_ma_kh;
end case;

--delete temp_1;delete hd_sc_bc_so;
--delete temp_2;

EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_1';
--EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_2';
EXECUTE IMMEDIATE 'TRUNCATE TABLE hd_sc_bc_so';

b_thangd:=round(b_ngayd/100,0);
--Ton dau ky--
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_hd_sc_thang';
insert into temp_hd_sc_thang
    select s.ma_dvi,s.loai_bp,s.ma_bp,s.ma,s.seri,max(thang)
        from hd_sc s,temp_sl_100 t
        where s.ma_dvi=t.ma_dvi and s.loai_bp=t.loai_bp and s.ma_bp=t.ma_bp
        and ma=b_ma and (b_seri is null or seri=b_seri) and thang<b_thangd
        group by s.ma_dvi,s.loai_bp,s.ma_bp,ma,seri;

-- delete temp_1;
/*
insert into temp_1(c1,c2,n1,n2,c10) select ma,seri,dau,cuoi,'T'
    from hd_sc where (ma_dvi,loai_bp,ma_bp,ma,seri,thang) in (select c1,c2,c3,c4,c5,n2 from temp_2) and dau<>0;
*/
insert into temp_1(c1,c2,n1,n2,c10) select s.ma,s.seri,dau,cuoi,'T' from hd_sc s, temp_hd_sc_thang t
    where s.ma_dvi=t.ma_dvi and s.thang=t.thang and s.loai_bp=t.loai_bp and s.ma_bp=t.ma_bp
    and s.ma=t.ma and s.seri=t.seri and dau<>0;

--Tong hop
--Ton dau ky
for b_lp in (select distinct c1,c2 from temp_1 where c10='T') loop
    insert into hd_sc_bc_so select n1,n2 from temp_1 where c10='T' and c1=b_lp.c1 and c2=b_lp.c2;
end loop;

if (b_ngayc>b_ngayd) then
    --Lay phat sinh--
    BC_HD_TH_PS(b_ma_dvi,b_ngayd,b_ngayc,b_loai_bp,b_ma_bp,b_ma,b_seri);
    --Tong hop them so ps tang
    for b_lp_1 in (select n1,n2 from temp_1 where c10='N' order by n1) loop
        BC_HD_TH_BC_SO(b_lp_1.n1,b_lp_1.n2);
    end loop;
    --Tong hop bot so ps giam
    --for b_lp_1 in (select n1,n2 from temp_1 where c10 in ('C','X') order by n1) loop
        --BC_HD_TH_BOT(b_lp_1.n1,b_lp_1.n2,b_loi);
--        if b_loi is not null then return; end if;
    --end loop;
end if;
delete temp_1;
--EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_1';
insert into temp_1(c1,c2,n1,n2) select b_ma,b_seri,dau,cuoi from hd_sc_bc_so;

exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure BC_HD_QTOAN_CN_MOI
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngayd number,b_ngayc number,
    b_loai_nh varchar2,b_ma_nh varchar2,b_ma varchar2,b_nhom varchar2,b_ten out nvarchar2,cs_kq out pht_type.cs_type)
AS
    b_loi varchar2(150);b_i1 number;b_c10 varchar2(10);b_c1 varchar2(1);b_c2 varchar2(1);b_c11 varchar2(10);b_i2 number;
    b_dau number; b_cuoi number; b_cuoi_m number; b_ngayd_m number; b_ngayc_m number; b_thang number; b_thangc number;
begin
--Lan--Bao cao thanh quyet toan hdon,an chi hang nam, co tong hop tu cap duoi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','NX','H');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete temp_sl;
--temp_sl:c1=loai_bp,c2=ma_bp,c3=ma_dvi
if b_ma_nh is null or b_ma_nh='' then
    b_loi:='loi:Nhap ma chi nhanh:loi';
    return;
end if;
insert into temp_sl(c3,c1,c2,n20) values (b_ma_dvi,'D',b_ma_dvi,1);
insert into temp_sl(c3,c1,c2,n20) select ma_dvi,'B',ma,1 from ht_ma_phong where ma_dvi=b_ma_nh;
insert into temp_sl(c3,c1,c2,n20) select ma_dvi,'C',ma,1 from ht_ma_nsd where ma_dvi=b_ma_nh;
insert into temp_sl(c3,c1,c2,n20) select ma_dvi,'L',ma,1 from bh_dl_ma_kh where ma_dvi=b_ma_nh;

--Lay cac ma an chi
if b_ma='' or b_ma is null  then
   insert into temp_sl(c1,n20) select ma,2 from hd_ma_hd where ma_dvi=b_ma_nh and (b_nhom is null or ma_nhom=b_nhom);
else
   insert into temp_sl(c1,n20) values (b_ma,2);
end if;
b_thang:=round(b_ngayd/100,0);

--Ky truoc con lai--
b_ngayd_m:=b_thang*100+1; b_ngayc_m:=b_ngayd-1;
delete temp_2;
insert into temp_2(c1,c2,c3,c4,c5) select distinct ma_dvi,loai_bp,ma_bp,ma,seri
    from hd_sc where thang<=b_thang and (ma_dvi,loai_bp,ma_bp) in (select c3,c1,c2 from temp_sl where n20=1 and c1=b_loai_nh)
    and ma in (select c1 from temp_sl where n20=2);
delete temp_3;

for b_lp in (select c1,c2,c3,c4,c5 from temp_2 order by c1,c2,c3,c4,c5) loop
    BC_HD_TH_CK(b_lp.c1,b_ngayd_m,b_ngayc_m,b_lp.c2,b_lp.c3,b_lp.c4,b_lp.c5);
    insert into temp_3(c2,c3,n1,n2) select c1,c2,n1,n2 from temp_1;
end loop;
delete ket_qua;
for b_lp in (select distinct c2,c3 from temp_3 order by c2,c3) loop
    b_i1:=0;
    for b_lpp in (select n1,n2 from temp_3 where c2=b_lp.c2 and c3=b_lp.c3 order by n1) loop
        b_i1:=b_i1+1;
        insert into ket_qua(c20,c19,n2,n3,n30) values (b_lp.c2,b_lp.c3,b_lpp.n1,b_lpp.n2,b_i1);
    end loop;
end loop;

--Du cuoi ky
b_thangc:=round(b_ngayc/100,0);
b_ngayc_m:=b_thangc*100+1;
delete temp_2;
insert into temp_2(c1,c2,c3,c4,c5) select distinct ma_dvi,loai_bp,ma_bp,ma,seri
    from hd_sc where thang<=b_thangc and (ma_dvi,loai_bp,ma_bp) in (select c3,c1,c2 from temp_sl where n20=1 and c1=b_loai_nh)
    and ma in (select c1 from temp_sl where n20=2);
delete temp_3;
for b_lp in (select c1,c2,c3,c4,c5 from temp_2 order by c1,c2,c3,c4,c5) loop
    BC_HD_TH_CK(b_lp.c1,b_ngayc_m,b_ngayc,b_lp.c2,b_lp.c3,b_lp.c4,b_lp.c5);
    insert into temp_3(c2,c3,n1,n2) select c1,c2,n1,n2 from temp_1 where n1<>0;
end loop;
for b_lp in (select distinct c2,c3 from temp_3 order by c2,c3) loop
    b_i1:=0;
    for b_lpp in (select n1,n2 from temp_3 where c2=b_lp.c2 and c3=b_lp.c3 order by n1) loop
        b_i1:=b_i1+1;
        insert into ket_qua(c20,c19,n11,n12,n30) values (b_lp.c2,b_lp.c3,b_lpp.n1,b_lpp.n2,b_i1);
    end loop;
end loop;


--So nhap--
delete temp_sl where n20=3;
--temp_sl:c1=ma_dvi,n1=so_id
insert into temp_sl(c1,n1,n20) select ma_dvi,so_id,3 from hd_1 where ma_dvi=b_ma_nh
    and ngay_ht between b_ngayd and b_ngayc and l_ct='N' and htoan='H';
delete temp_3;
--temp_3:c1=ma_dvi,c2=ma,c3=dvt,n1=dau,n2=cuoi,n3=so_luong
insert into temp_3(c2,c3,n1,n2) select ma,seri,dau,cuoi
        from hd_2 where (ma_dvi,so_id) in (select c1,n1 from temp_sl where n20=3) and ma in (select c1 from temp_sl where n20=2);
for b_lp in (select distinct c2,c3 from temp_3 order by c2,c3) loop
    b_i1:=0;
    for b_lpp in (select n1,n2 from temp_3 where c2=b_lp.c2 and c3=b_lp.c3 order by n1) loop
        b_i1:=b_i1+1;
        insert into ket_qua(c20,c19,n5,n6,n30) values (b_lp.c2,b_lp.c3,b_lpp.n1,b_lpp.n2,b_i1);
    end loop;
end loop;


--So xuat--
delete temp_sl where n20=3;
--temp_sl:c1=ma_dvi,n1=so_id
insert into temp_sl(c1,n1,n2,n20) select a.ma_dvi,a.so_id,b.so_tt,3 from hd_1 a,hd_3 b where
    ngay_ht between b_ngayd and b_ngayc and l_ct='X' and a.ma_dvi=b_ma_nh and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and htoan='H'
    and (b.ma_dvi,loai_x,ma_x) in (select c3,c1,c2 from temp_sl where n20=1);

delete temp_3;
--temp_3:c1=ma_dvi,c2=ma,n1=so_luong
insert into temp_3(c2,c3,n1,n2,c4) select ma,seri,dau,cuoi,decode(ma_tke,'O','H',ma_tke)
        from hd_2 where (ma_dvi,so_id,so_tt) in (select c1,n1,n2 from temp_sl where n20=3)
        and ma in (select c1 from temp_sl where n20=2);


--So dieu chuyen cho van phong, cac chi nhanh khac
delete temp_sl where n20=3;
insert into temp_sl(c1,n1,n2,n20) select a.ma_dvi,a.so_id,b.so_tt,3 from hd_1 a,hd_3 b where a.ma_dvi=b_ma_nh
    and ngay_ht between b_ngayd and b_ngayc and l_ct='C' and (a.loai_n,a.ma_n) in (select 'D',ma from ht_ma_dvi where ma<>b_ma_nh)
    and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and htoan='H' and (b.ma_dvi,loai_x,ma_x) in (select c3,c1,c2 from temp_sl where n20=1 and c1='D');
insert into temp_3(c2,c3,n1,n2,c4) select ma,seri,dau,cuoi,'T'
        from hd_2 where (ma_dvi,so_id,so_tt) in (select c1,n1,n2 from temp_sl where n20=3)
        and ma in (select c1 from temp_sl where n20=2);
---


delete temp_2;
insert into temp_2(c1) values ('D');insert into temp_2(c1) values ('M');
insert into temp_2(c1) values ('H');insert into temp_2(c1) values ('T');
for b_lop in (select c1 from temp_2 order by c1) loop
    b_c1:=b_lop.c1;
    delete temp_1;
    for b_lp_dk in (select distinct c2,c3 from temp_3 where c4=b_c1 order by c2,c3) loop
        delete temp_sl;
        b_i1:=0; b_i2:=0; b_dau:=0; b_cuoi:=0;
        select max(n2) into b_cuoi_m from temp_3 where c4=b_c1 and c2=b_lp_dk.c2 and c3=b_lp_dk.c3;
           for b_lp in (select n1,n2 from temp_3 where c4=b_c1 and c2=b_lp_dk.c2 and +c3=b_lp_dk.c3 order by n1) loop
            b_i1:=b_lp.n1; b_i2:=b_lp.n2;
            if b_dau=0 then b_dau:=b_i1; b_cuoi:=b_i2;
            else
                if b_i1=b_cuoi+1 then b_cuoi:=b_i2;
                else
                    insert into temp_sl(n1,n2) values (b_dau,b_cuoi);
                    b_dau:=b_i1; b_cuoi:=b_i2;

                end if;
            end if;
            if b_cuoi=b_cuoi_m then
                insert into temp_sl(n1,n2) values (b_dau,b_cuoi);
            end if;
        end loop;
   --if b_c1='D' then b_loi:='loi:loi'||b_lp_dk.c3||'loi';raise PROGRAM_ERROR;end if;
        insert into temp_1(c2,c3,n1,n2) select b_lp_dk.c2,b_lp_dk.c3,n1,n2 from temp_sl order by n1;
    end loop;
    for b_lp in (select distinct c2,c3 from temp_1 order by c2,c3) loop
        b_i1:=0;
        for b_lpp in (select n1,n2 from temp_1 where c2=b_lp.c2 and c3=b_lp.c3 order by n1) loop
            b_i1:=b_i1+1;
           -- if b_c1='D' then b_loi:='loi:loi'||b_lpp.n1||'loi';raise PROGRAM_ERROR;end if;
            if b_c1='D' then insert into ket_qua(c20,c19,n8,n9,n30) values (b_lp.c2,b_lp.c3,b_lpp.n1,b_lpp.n2,b_i1);
            elsif b_c1='H' then insert into ket_qua(c20,c19,n13,n14,n30) values (b_lp.c2,b_lp.c3,b_lpp.n1,b_lpp.n2,b_i1);
            elsif b_c1='M' then insert into ket_qua(c20,c19,n15,n16,n30) values (b_lp.c2,b_lp.c3,b_lpp.n1,b_lpp.n2,b_i1);
            else insert into ket_qua(c20,c19,n17,n18,n30) values (b_lp.c2,b_lp.c3,b_lpp.n1,b_lpp.n2,b_i1);
            end if;
        end loop;
    --if b_c1='D' then b_loi:='loi:loi'||b_c1||'loi';raise PROGRAM_ERROR;end if;
    end loop;

end loop;

delete temp_1;
insert into temp_1(c20,c19,n2,n3,n11,n12,n5,n6,n8,n9,n13,n14,n15,n16,n17,n18,n30)
    select c20,c19,sum(nvl(n2,0)),sum(nvl(n3,0)),sum(nvl(n11,0)),sum(nvl(n12,0)),sum(nvl(n5,0)),sum(nvl(n6,0)),
    sum(nvl(n8,0)),sum(nvl(n9,0)),sum(nvl(n13,0)),sum(nvl(n14,0)),sum(nvl(n15,0)),sum(nvl(n16,0)),sum(nvl(n17,0)),sum(nvl(n18,0)),n30
    from ket_qua group by c20,c19,n30;

update temp_1 set n1=decode(n3,0,0,n3-n2+1),n10=decode(n12,0,0,n12-n11+1),n4=decode(n6,0,0,n6-n5+1),
    n7=decode(n9,0,0,n9-n8+1),n21=decode(n14,0,0,n14-n13+1),n22=decode(n16,0,0,n16-n15+1),n19=decode(n18,0,0,n18-n17+1);
update temp_1 set (n25,c1)=(select do_dai,ten from hd_ma_hd where ma_dvi=b_ma_nh and ma=c20);
update temp_1 set n24=0 where c19=' ' or c19 in ('HULL','VCND','IM','EX');
update temp_1 set n24=length(c19) where c19<>' ' and c19 not in ('HULL','VCND','IM','EX');
update temp_1 set c2=decode(n2,0,'',lpad(rtrim(to_char(n2)),n25-n24,'0')),c3=decode(n3,0,'',lpad(rtrim(to_char(n3)),n25-n24,'0')),
    c5=decode(n5,0,'',lpad(rtrim(to_char(n5)),n25-n24,'0')),c6=decode(n6,0,'',lpad(rtrim(to_char(n6)),n25-n24,'0')),
    --c8=decode(n8,0,'',to_char(n8)),c9=decode(n9,0,'',to_char(n9)),
    c8=decode(n8,0,'',lpad(rtrim(to_char(n8)),n25-n24,'0')),c9=decode(n9,0,'',lpad(rtrim(to_char(n9)),n25-n24,'0')),
    c11=decode(n11,0,'',lpad(rtrim(to_char(n11)),n25-n24,'0')),c12=decode(n12,0,'',lpad(rtrim(to_char(n12)),n25-n24,'0')),
    c13=decode(n13,0,'',lpad(rtrim(to_char(n13)),n25-n24,'0')),c14=decode(n14,0,'',lpad(rtrim(to_char(n14)),n25-n24,'0')),
    --c13=decode(n13,0,'',to_char(n13)),c14=decode(n14,0,'',to_char(n14)),
    c15=decode(n15,0,'',lpad(rtrim(to_char(n15)),n25-n24,'0')),c16=decode(n16,0,'',lpad(rtrim(to_char(n16)),n25-n24,'0')),
    c17=decode(n17,0,'',lpad(rtrim(to_char(n17)),n25-n24,'0')),c18=decode(n18,0,'',lpad(rtrim(to_char(n18)),n25-n24,'0'));
--
update temp_1 set c30=(select mau from hd_ma_hd where ma_dvi=b_ma_dvi and ma=c20);
select ten into b_ten from ht_ma_dvi where ma=b_ma_nh;
open cs_kq for select n23 quyen,c1 ten,c30 mau,c19 seri,n1 dk,c2 dau_dk,c3 cuoi_dk,n4 nhap,c5 dau_nhap,c6 cuoi_nhap,n7 xuat,c8 dau_xuat,
     c9 cuoi_xuat,n21 huy,c13 dau_huy,c14 cuoi_huy,n22 mat,c15 dau_mat,c16 cuoi_mat,n19 tlai,c17 dau_tlai,c18 cuoi_tlai,
     n10 ck,c11 dau_ck,c12 cuoi_ck  from temp_1 order by c20,c19,n30;

exception when others then raise_application_error(-20105,b_loi);
end;
 /
 create or replace PROCEDURE BC_HD_QTOAN_BP_MOI
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngayd number,b_ngayc number,
    b_loai_nh varchar2,b_ma_nh varchar2,b_ma varchar2,b_nhom varchar2,b_ten out nvarchar2,cs_kq out pht_type.cs_type)
AS
    b_loi varchar2(150);b_i1 number;b_c10 varchar2(10);b_c1 varchar2(1);b_c2 varchar2(1);b_c11 varchar2(10);b_i2 number;
    b_dau number; b_cuoi number; b_cuoi_m number; b_ngayd_m number; b_ngayc_m number; b_thang number; b_thangc number;
begin
--Lan--Bao cao thanh quyet toan hdon,an chi hang nam, co tong hop tu cap duoi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','NX','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete temp_sl; delete ket_qua;
--temp_sl:c1=loai_bp,c2=ma_bp,cs3=ma_dvi
if b_ma_nh is null or b_ma_nh='' then
    b_loi:='loi:Nhap ma bo phan:loi';
    raise PROGRAM_ERROR;
end if;
select count(*) into b_i1 from ht_ma_dvi where ten like '%MIC%';
if b_i1>0 then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','NX','X');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    select phong into b_c10 from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_nsd;
    if b_ma_nh<>b_c10 then
        b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','NX','Q');
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
end if;
insert into temp_sl(c3,c1,c2,n20) values (b_ma_dvi,'B',b_ma_nh,1);
insert into temp_sl(c3,c1,c2,n20) select ma_dvi,'C',ma,1 from ht_ma_nsd where ma_dvi=b_ma_dvi and phong=b_ma_nh;
--insert into temp_sl(c3,c1,c2,n20) select ma_dvi,'L',ma,1 from bh_dl_ma_kh where ma_dvi=b_ma_dvi and phong=b_ma_nh;
--Lay cac ma an chi
if b_ma='' or b_ma is null  then
   insert into temp_sl(c1,n20) select distinct ma,2 from hd_ma_hd where ma_dvi=b_ma_dvi and (b_nhom is null or ma_nhom=b_nhom);
else
   insert into temp_sl(c1,n20) select ma,2 from hd_ma_hd where ma_dvi=b_ma_dvi and (b_nhom is null or ma_nhom=b_nhom) and ma=b_ma;
end if;
b_thang:=round(b_ngayd/100,0);
--Ky truoc con lai--
b_ngayd_m:=b_thang*100+1;
if (b_ngayd_m=b_ngayd) then b_ngayc_m:=b_ngayd_m;
else b_ngayc_m:=PKH_NG_CSO(PKH_SO_CDT(b_ngayd)-1); end if;
delete temp_sl where n20=1000;
insert into temp_sl(c1,c2,c3,c4,c5,n20) select distinct ma_dvi,loai_bp,ma_bp,ma,seri,1000
    from hd_sc where thang<=b_thang and (ma_dvi,loai_bp,ma_bp) in (select c3,c1,c2 from temp_sl where n20=1 and c1=b_loai_nh)
    and ma in (select c1 from temp_sl where n20=2);
delete temp_3;
for b_lp in (select c1,c2,c3,c4,c5 from temp_sl where n20=1000 order by c1,c2,c3,c4,c5) loop
    BC_HD_TH_CK(b_lp.c1,b_ngayd_m,b_ngayc_m,b_lp.c2,b_lp.c3,b_lp.c4,b_lp.c5);
    insert into temp_3(c2,c3,n1,n2) select c1,c2,n1,n2 from temp_1;
end loop;
delete ket_qua;
for b_lp in (select distinct c2,c3 from temp_3 order by c2,c3) loop
    b_i1:=0;
    for b_lpp in (select n1,n2 from temp_3 where c2=b_lp.c2 and c3=b_lp.c3 order by n1) loop
        b_i1:=b_i1+1;
        insert into ket_qua(c20,c19,n2,n3,n30) values (b_lp.c2,b_lp.c3,b_lpp.n1,b_lpp.n2,b_i1);
    end loop;
end loop;

--So nhap--
delete temp_sl where nvl(n20,0)=3;
--temp_sl:c1=ma_dvi,n1=so_id
insert into temp_sl(c1,n1,n20) select ma_dvi,so_id,3 from hd_1
    where (ma_dvi,loai_n,ma_n) in (select c3,c1,c2 from temp_sl where n20=1 and c1='B')
    and ngay_ht between b_ngayd and b_ngayc and l_ct='C' and htoan='H';
delete temp_3;
--temp_3:c1=ma_dvi,c2=ma,c3=dvt,n1=dau,n2=cuoi,n3=so_luong
insert into temp_3(c2,c3,n1,n2) select distinct ma,seri,dau,cuoi
        from hd_3 where (ma_dvi,so_id) in (select c1,n1 from temp_sl where n20=3) and ma in (select c1 from temp_sl where n20=2)
        and (ma_dvi,loai_x,ma_x) not in (select c3,c1,c2 from temp_sl where n20=1 and c1 in ('C','L'));
for b_lp in (select distinct c2,c3 from temp_3 order by c2,c3) loop
    b_i1:=0;
    for b_lpp in (select n1,n2 from temp_3 where c2=b_lp.c2 and c3=b_lp.c3 order by n1) loop
        b_i1:=b_i1+1;
        insert into ket_qua(c20,c19,n5,n6,n30) values (b_lp.c2,b_lp.c3,b_lpp.n1,b_lpp.n2,b_i1);
    end loop;
end loop;

--Du cuoi ky
b_thangc:=round(b_ngayc/100,0);
delete temp_2;
insert into temp_2(c1,c2,c3,c4,c5) select distinct ma_dvi,loai_bp,ma_bp,ma,seri
    from hd_sc where thang<=b_thangc and (ma_dvi,loai_bp,ma_bp) in (select c3,c1,c2 from temp_sl where n20=1 and c1=b_loai_nh)
    and ma in (select c1 from temp_sl where n20=2);
delete temp_3;
for b_lp in (select c1,c2,c3,c4,c5 from temp_2 order by c1,c2,c3,c4,c5) loop
    BC_HD_TH_CK(b_lp.c1,b_ngayd_m,b_ngayc,b_lp.c2,b_lp.c3,b_lp.c4,b_lp.c5);
    insert into temp_3(c2,c3,n1,n2) select c1,c2,n1,n2 from temp_1;
end loop;
for b_lp in (select distinct c2,c3 from temp_3 order by c2,c3) loop
    b_i1:=0;
    for b_lpp in (select n1,n2 from temp_3 where c2=b_lp.c2 and c3=b_lp.c3 order by n1) loop
        b_i1:=b_i1+1;
        insert into ket_qua(c20,c19,n11,n12,n30) values (b_lp.c2,b_lp.c3,b_lpp.n1,b_lpp.n2,b_i1);
    end loop;
end loop;

--So xuat--
--So dieu chuyen tra lai cap tren
delete temp_sl where n20=3;
insert into temp_sl(c1,n1,n2,n20) select a.ma_dvi,a.so_id,b.so_tt,3 from hd_1 a,hd_3 b
    where (b.ma_dvi,b.loai_x,b.ma_x) in (select c3,c1,c2 from temp_sl where n20=1)
    and ngay_ht between b_ngayd and b_ngayc and l_ct='C' and a.loai_n='D' and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and htoan='H';
delete temp_3;
insert into temp_3(c2,c3,n1,n2,c4) select ma,seri,dau,cuoi,'T'
        from hd_2 where (ma_dvi,so_id,so_tt) in (select c1,n1,n2 from temp_sl where n20=3)
        and ma in (select c1 from temp_sl where n20=2) and exists(select * from ket_qua where c20=ma and (dau between n2 and n3 or dau between n5 and n6));
--Xuat dung
delete temp_sl where n20=3;
--temp_sl:c1=ma_dvi,n1=so_id
insert into temp_sl(c1,n1,n2,n20) select a.ma_dvi,a.so_id,b.so_tt,3 from hd_1 a,hd_3 b
    where (b.ma_dvi,b.loai_x,b.ma_x) in (select c3,c1,c2 from temp_sl where n20=1 and c1 in ('B','C','L'))
    and ngay_ht between b_ngayd and b_ngayc and l_ct='X' and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and htoan='H';
--temp_3:c1=mas_dvi,c2=ma,n1=so_luong
insert into temp_3(c2,n25,c3,n1,n2,c4) select ma,0,seri,dau,cuoi,decode(ma_tke,'O','H',ma_tke)
        from hd_2 where (ma_dvi,so_id,so_tt) in (select c1,n1,n2 from temp_sl where n20=3)
        and ma in (select c1 from temp_sl where n20=2);
--      and exists(select * from ket_qua where c20=ma and (dau between n2 and n3 or dau between n5 and n6));
--      and not exists(select * from temp_3 where c2=ma and dau between n1 and n2);
delete temp_2;
insert into temp_2(c1) values ('D');
insert into temp_2(c1) values ('M');
insert into temp_2(c1) values ('H');
insert into temp_2(c1) values ('T');
for b_lop in (select c1 from temp_2 order by c1) loop
    b_c1:=b_lop.c1;
    delete temp_1;
    insert into temp_1(c2,c3) select distinct c2,c3 from temp_3 where c4=b_c1 order by c2,c3;
    for b_lp_dk in (select c2,c3 from temp_1 order by c2,c3) loop
        delete temp_sl;
        b_i1:=0; b_i2:=0; b_dau:=0; b_cuoi:=0;
        select max(n2) into b_cuoi_m from temp_3 where c4=b_c1 and c2=b_lp_dk.c2 and c3=b_lp_dk.c3;
        for b_lp in (select n1,n2 from temp_3 where c4=b_c1 and c2=b_lp_dk.c2 and c3=b_lp_dk.c3 order by n1) loop
            b_i1:=b_lp.n1; b_i2:=b_lp.n2;
            if b_dau=0 then b_dau:=b_i1; b_cuoi:=b_i2;
            else
                if b_i1=b_cuoi+1 then b_cuoi:=b_i2;
                else
                    insert into temp_sl(c1,c2,n1,n2) values (b_lp_dk.c2,b_lp_dk.c3,b_dau,b_cuoi);
                    b_dau:=b_i1; b_cuoi:=b_i2;
                end if;
            end if;
            if b_cuoi=b_cuoi_m then
                insert into temp_sl(c1,c2,n1,n2) values (b_lp_dk.c2,b_lp_dk.c3,b_dau,b_cuoi);
            end if;
        end loop;
        insert into temp_1(c2,c3,n1,n2) select b_lp_dk.c2,b_lp_dk.c3,n1,n2 from temp_sl order by n1;
    end loop;
    for b_lp in (select distinct c2,c3 from temp_1 order by c2,c3) loop
        b_i1:=0;
        for b_lpp in (select n1,n2 from temp_1 where c2=b_lp.c2 and c3=b_lp.c3 order by n1) loop
            b_i1:=b_i1+1;
            if b_c1='D' then insert into ket_qua(c20,c19,n8,n9,n30) values (b_lp.c2,b_lp.c3,b_lpp.n1,b_lpp.n2,b_i1);
            elsif b_c1='H' then insert into ket_qua(c20,c19,n13,n14,n30) values (b_lp.c2,b_lp.c3,b_lpp.n1,b_lpp.n2,b_i1);
            elsif b_c1='M' then insert into ket_qua(c20,c19,n15,n16,n30) values (b_lp.c2,b_lp.c3,b_lpp.n1,b_lpp.n2,b_i1);
            else insert into ket_qua(c20,c19,n17,n18,n30) values (b_lp.c2,b_lp.c3,b_lpp.n1,b_lpp.n2,b_i1);
            end if;
        end loop;
    end loop;
end loop;

delete temp_1;
insert into temp_1(c20,c19,n2,n3,n11,n12,n5,n6,n8,n9,n13,n14,n15,n16,n17,n18,n30)
    select c20,c19,sum(nvl(n2,0)),sum(nvl(n3,0)),sum(nvl(n11,0)),sum(nvl(n12,0)),sum(nvl(n5,0)),sum(nvl(n6,0)),
    sum(nvl(n8,0)),sum(nvl(n9,0)),sum(nvl(n13,0)),sum(nvl(n14,0)),sum(nvl(n15,0)),sum(nvl(n16,0)),sum(nvl(n17,0)),sum(nvl(n18,0)),n30
    from ket_qua group by c20,c19,n30;

update temp_1 set n1=decode(n3,0,0,n3-n2+1),n10=decode(n12,0,0,n12-n11+1),n4=decode(n6,0,0,n6-n5+1),
    n7=decode(n9,0,0,n9-n8+1),n21=decode(n14,0,0,n14-n13+1),n22=decode(n16,0,0,n16-n15+1),n19=decode(n18,0,0,n18-n17+1);
update temp_1 set (n25,c1)=(select do_dai,ten from hd_ma_hd where ma_dvi=b_ma_dvi and ma=c20);
update temp_1 set n24=decode(c19,null,0,' ',0,length(trim(c19)));
update temp_1 set c2=decode(n2,0,'',lpad(rtrim(to_char(n2)),n25-n24,'0')),c3=decode(n3,0,'',lpad(rtrim(to_char(n3)),n25-n24,'0')),
    c5=decode(n5,0,'',lpad(rtrim(to_char(n5)),n25-n24,'0')),c6=decode(n6,0,'',lpad(rtrim(to_char(n6)),n25-n24,'0')),
    c8=decode(n8,0,'',lpad(rtrim(to_char(n8)),n25-n24,'0')),c9=decode(n9,0,'',lpad(rtrim(to_char(n9)),n25-n24,'0')),
    c11=decode(n11,0,'',lpad(rtrim(to_char(n11)),n25-n24,'0')),c12=decode(n12,0,'',lpad(rtrim(to_char(n12)),n25-n24,'0')),
    c13=decode(n13,0,'',lpad(rtrim(to_char(n13)),n25-n24,'0')),c14=decode(n14,0,'',lpad(rtrim(to_char(n14)),n25-n24,'0')),
    c15=decode(n15,0,'',lpad(rtrim(to_char(n15)),n25-n24,'0')),c16=decode(n16,0,'',lpad(rtrim(to_char(n16)),n25-n24,'0')),
    c17=decode(n17,0,'',lpad(rtrim(to_char(n17)),n25-n24,'0')),c18=decode(n18,0,'',lpad(rtrim(to_char(n18)),n25-n24,'0'));
--
update temp_1 set c30=(select mau from hd_ma_hd where ma_dvi=b_ma_dvi and ma=c20);
select ten into b_ten from ht_ma_phong where ma_dvi=b_ma_dvi and ma=b_ma_nh;
open cs_kq for select n23 quyen,c1 ten,c30 mau,c19 seri,n1 dk,c2 dau_dk,c3 cuoi_dk,n4 nhap,c5 dau_nhap,c6 cuoi_nhap,n7 xuat,c8 dau_xuat,
     c9 cuoi_xuat,n21 huy,c13 dau_huy,c14 cuoi_huy,n22 mat,c15 dau_mat,c16 cuoi_mat,n19 tlai,c17 dau_tlai,c18 cuoi_tlai,
     n10 ck,c11 dau_ck,c12 cuoi_ck  from temp_1 order by c20,c19,n30;
exception when others then raise_application_error(-20105,b_loi);
end;
/
 
 create or replace procedure BC_HD_QTOAN_CB_MOI
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngayd number,b_ngayc number,
    b_ma_nh varchar2,b_ma varchar2,b_nhom varchar2,b_ten out nvarchar2,cs_kq out pht_type.cs_type)
AS
    b_loi varchar2(150);b_i1 number;b_c10 varchar2(10);b_c1 varchar2(1);b_c2 varchar2(1);b_c11 varchar2(10);b_i2 number;
    b_dau number; b_cuoi number; b_cuoi_m number; b_ngayd_m number; b_ngayc_m number; b_thang number; b_thangc number;
begin
--Lan--Bao cao thanh quyet toan hdon,an chi hang nam tung can bo, co tong hop tu cap duoi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','NX','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete ket_qua;delete temp_sl;
--temp_sl:c1=loai_bp,c2=ma_bp,cs3=ma_dvi
if b_ma_nh is null or b_ma_nh='' then
    b_loi:='loi:Nhap ma can bo:loi';
    raise PROGRAM_ERROR;
end if;
if b_ma_nh<>b_nsd then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','NX','X');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
insert into temp_sl(c3,c1,c2,n20) values (b_ma_dvi,'C',b_ma_nh,1);
--Lay cac ma an chi
if b_ma='' or b_ma is null  then
   insert into temp_sl(c1,n20) select ma,2 from hd_ma_hd where ma_dvi=b_ma_dvi;
else
   insert into temp_sl(c1,n20) values (b_ma,2);
end if;
b_thang:=round(b_ngayd/100,0);
--Ky truoc con lai--
b_ngayd_m:=b_thang*100+1; b_ngayc_m:=b_ngayd-1;
delete temp_2;
insert into temp_2(c1,c2,c3,c4,c5) select distinct ma_dvi,loai_bp,ma_bp,ma,seri
    from hd_sc where thang<=b_thang and (ma_dvi,loai_bp,ma_bp) in (select c3,c1,c2 from temp_sl where n20=1)
    and ma in (select c1 from temp_sl where n20=2);
delete temp_3;
for b_lp in (select c1,c2,c3,c4,c5 from temp_2 order by c1,c2,c3,c4,c5) loop
    BC_HD_TH_CK(b_lp.c1,b_ngayd_m,b_ngayc_m,b_lp.c2,b_lp.c3,b_lp.c4,b_lp.c5);
    insert into temp_3(c2,c3,n1,n2) select c1,c2,n1,n2 from temp_1;
end loop;
delete ket_qua;
for b_lp in (select distinct c2,c3 from temp_3 order by c2,c3) loop
    b_i1:=0;
    for b_lpp in (select n1,n2 from temp_3 where c2=b_lp.c2 and c3=b_lp.c3 order by n1) loop
        b_i1:=b_i1+1;
        insert into ket_qua(c20,c19,n2,n3,n30) values (b_lp.c2,b_lp.c3,b_lpp.n1,b_lpp.n2,b_i1);
    end loop;
end loop;

--Du cuoi ky
b_thangc:=round(b_ngayc/100,0);
delete temp_2;
insert into temp_2(c1,c2,c3,c4,c5) select distinct ma_dvi,loai_bp,ma_bp,ma,seri
    from hd_sc where thang<=b_thangc and (ma_dvi,loai_bp,ma_bp) in (select c3,c1,c2 from temp_sl where n20=1)
    and ma in (select c1 from temp_sl where n20=2);
delete temp_3;
for b_lp in (select c1,c2,c3,c4,c5 from temp_2 order by c1,c2,c3,c4,c5) loop
    BC_HD_TH_CK(b_lp.c1,b_ngayd_m,b_ngayc,b_lp.c2,b_lp.c3,b_lp.c4,b_lp.c5);
    insert into temp_3(c2,c3,n1,n2) select c1,c2,n1,n2 from temp_1;
end loop;
for b_lp in (select distinct c2,c3 from temp_3 order by c2,c3) loop
    b_i1:=0;
    for b_lpp in (select n1,n2 from temp_3 where c2=b_lp.c2 and c3=b_lp.c3 order by n1) loop
        b_i1:=b_i1+1;
        insert into ket_qua(c20,c19,n11,n12,n30) values (b_lp.c2,b_lp.c3,b_lpp.n1,b_lpp.n2,b_i1);
    end loop;
end loop;

--So nhap--
delete temp_sl where nvl(n20,0)=3;
--temp_sl:c1=ma_dvi,n1=so_id
insert into temp_sl(c1,n1,n20) select ma_dvi,so_id,3 from hd_1
    where (ma_dvi,loai_n,ma_n) in (select c3,c1,c2 from temp_sl where n20=1 and c1='C')
    and ngay_ht between b_ngayd and b_ngayc and l_ct='C' and htoan='H';
delete temp_3;
--temp_3:c1=ma_dvi,c2=ma,c3=dvt,n1=dau,n2=cuoi,n3=so_luong
insert into temp_3(c2,c3,n1,n2) select distinct ma,seri,dau,cuoi
        from hd_2 where (ma_dvi,so_id) in (select c1,n1 from temp_sl where n20=3) and ma in (select c1 from temp_sl where n20=2);
for b_lp in (select distinct c2,c3 from temp_3 order by c2,c3) loop
    b_i1:=0;
    for b_lpp in (select n1,n2 from temp_3 where c2=b_lp.c2 and c3=b_lp.c3 order by n1) loop
        b_i1:=b_i1+1;
        insert into ket_qua(c20,c19,n5,n6,n30) values (b_lp.c2,b_lp.c3,b_lpp.n1,b_lpp.n2,b_i1);
    end loop;
end loop;

--So xuat--
delete temp_sl where n20=3;
--temp_sl:c1=ma_dvi,n1=so_id
insert into temp_sl(c1,n1,n2,n20) select a.ma_dvi,a.so_id,b.so_tt,3 from hd_1 a,hd_3 b
    where (b.ma_dvi,b.loai_x,b.ma_x) in (select c3,c1,c2 from temp_sl where n20=1)
    and ngay_ht between b_ngayd and b_ngayc and l_ct='X' and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and htoan='H';
delete temp_3;
--temp_3:c1=mas_dvi,c2=ma,n1=so_luong
insert into temp_3(c2,n25,c3,n1,n2,c4) select ma,0,seri,dau,cuoi,decode(ma_tke,'O','H',ma_tke)
        from hd_2 where (ma_dvi,so_id,so_tt) in (select c1,n1,n2 from temp_sl where n20=3)
        and ma in (select c1 from temp_sl where n20=2);
--So dieu chuyen tra lai cap tren
delete temp_sl where n20=3;
insert into temp_sl(c1,n1,n2,n20) select a.ma_dvi,a.so_id,b.so_tt,3 from hd_1 a,hd_3 b
    where (b.ma_dvi,b.loai_x,b.ma_x) in (select c3,c1,c2 from temp_sl where n20=1)
    and ngay_ht between b_ngayd and b_ngayc and l_ct='C' and a.loai_n in ('D','B') and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and htoan='H';
insert into temp_3(c2,c3,n1,n2,c4) select ma,seri,dau,cuoi,'T'
        from hd_2 where (ma_dvi,so_id,so_tt) in (select c1,n1,n2 from temp_sl where n20=3)
        and ma in (select c1 from temp_sl where n20=2);
--So dieu chuyen cho dai ly
delete temp_sl where n20=3;
insert into temp_sl(c1,n1,n2,n20) select a.ma_dvi,a.so_id,b.so_tt,3 from hd_1 a,hd_3 b
    where (b.ma_dvi,b.loai_x,b.ma_x) in (select c3,c1,c2 from temp_sl where n20=1)
    and ngay_ht between b_ngayd and b_ngayc and l_ct='C' and a.loai_n='L' and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and htoan='H';
insert into temp_3(c2,c3,n1,n2,c4) select ma,seri,dau,cuoi,'D'
        from hd_2 where (ma_dvi,so_id,so_tt) in (select c1,n1,n2 from temp_sl where n20=3)
        and ma in (select c1 from temp_sl where n20=2);
---
delete temp_2;
insert into temp_2(c1) values ('D');
insert into temp_2(c1) values ('M');
insert into temp_2(c1) values ('H');
insert into temp_2(c1) values ('T');
for b_lop in (select c1 from temp_2 order by c1) loop
    b_c1:=b_lop.c1;
    delete temp_1;
    insert into temp_1(c2,c3) select distinct c2,c3 from temp_3 where c4=b_c1 order by c2,c3;
    for b_lp_dk in (select c2,c3 from temp_1 order by c2,c3) loop
        delete temp_sl;
        b_i1:=0; b_i2:=0; b_dau:=0; b_cuoi:=0;
        select max(n2) into b_cuoi_m from temp_3 where c4=b_c1 and c2=b_lp_dk.c2 and c3=b_lp_dk.c3;
        for b_lp in (select n1,n2 from temp_3 where c4=b_c1 and c2=b_lp_dk.c2 and c3=b_lp_dk.c3 order by n1) loop
            b_i1:=b_lp.n1; b_i2:=b_lp.n2;
            if b_dau=0 then b_dau:=b_i1; b_cuoi:=b_i2;
            else
                if b_i1=b_cuoi+1 then b_cuoi:=b_i2;
                else
                    insert into temp_sl(n1,n2) values (b_dau,b_cuoi);
                    b_dau:=b_i1; b_cuoi:=b_i2;
                end if;
            end if;
            if b_cuoi=b_cuoi_m then
                insert into temp_sl(n1,n2) values (b_dau,b_cuoi);
            end if;
        end loop;
        insert into temp_1(c2,c3,n1,n2) select b_lp_dk.c2,b_lp_dk.c3,n1,n2 from temp_sl order by n1;    end loop;
    for b_lp in (select distinct c2,c3 from temp_1 order by c2,c3) loop
        b_i1:=0;
        for b_lpp in (select n1,n2 from temp_1 where c2=b_lp.c2 and c3=b_lp.c3 order by n1) loop
            b_i1:=b_i1+1;
            if b_c1='D' then insert into ket_qua(c20,c19,n8,n9,n30) values (b_lp.c2,b_lp.c3,b_lpp.n1,b_lpp.n2,b_i1);
            elsif b_c1='H' then insert into ket_qua(c20,c19,n13,n14,n30) values (b_lp.c2,b_lp.c3,b_lpp.n1,b_lpp.n2,b_i1);
            elsif b_c1='M' then insert into ket_qua(c20,c19,n15,n16,n30) values (b_lp.c2,b_lp.c3,b_lpp.n1,b_lpp.n2,b_i1);
            else insert into ket_qua(c20,c19,n17,n18,n30) values (b_lp.c2,b_lp.c3,b_lpp.n1,b_lpp.n2,b_i1);
            end if;
        end loop;
    end loop;
end loop;

delete temp_1;
insert into temp_1(c20,c19,n2,n3,n11,n12,n5,n6,n8,n9,n13,n14,n15,n16,n17,n18,n30)
    select c20,c19,sum(nvl(n2,0)),sum(nvl(n3,0)),sum(nvl(n11,0)),sum(nvl(n12,0)),sum(nvl(n5,0)),sum(nvl(n6,0)),
    sum(nvl(n8,0)),sum(nvl(n9,0)),sum(nvl(n13,0)),sum(nvl(n14,0)),sum(nvl(n15,0)),sum(nvl(n16,0)),sum(nvl(n17,0)),sum(nvl(n18,0)),n30
    from ket_qua group by c20,c19,n30;

update temp_1 set n1=decode(n3,0,0,n3-n2+1),n10=decode(n12,0,0,n12-n11+1),n4=decode(n6,0,0,n6-n5+1),
    n7=decode(n9,0,0,n9-n8+1),n21=decode(n14,0,0,n14-n13+1),n22=decode(n16,0,0,n16-n15+1),n19=decode(n18,0,0,n18-n17+1);
update temp_1 set (n25,c1)=(select do_dai,ten from hd_ma_hd where ma_dvi=b_ma_dvi and ma=c20);
update temp_1 set n24=decode(c19,null,0,' ',0,length(trim(c19)));
update temp_1 set c2=decode(n2,0,'',lpad(rtrim(to_char(n2)),n25-n24,'0')),c3=decode(n3,0,'',lpad(rtrim(to_char(n3)),n25-n24,'0')),
    c5=decode(n5,0,'',lpad(rtrim(to_char(n5)),n25-n24,'0')),c6=decode(n6,0,'',lpad(rtrim(to_char(n6)),n25-n24,'0')),
    c8=decode(n8,0,'',lpad(rtrim(to_char(n8)),n25-n24,'0')),c9=decode(n9,0,'',lpad(rtrim(to_char(n9)),n25-n24,'0')),
    c11=decode(n11,0,'',lpad(rtrim(to_char(n11)),n25-n24,'0')),c12=decode(n12,0,'',lpad(rtrim(to_char(n12)),n25-n24,'0')),
    c13=decode(n13,0,'',lpad(rtrim(to_char(n13)),n25-n24,'0')),c14=decode(n14,0,'',lpad(rtrim(to_char(n14)),n25-n24,'0')),
    c15=decode(n15,0,'',lpad(rtrim(to_char(n15)),n25-n24,'0')),c16=decode(n16,0,'',lpad(rtrim(to_char(n16)),n25-n24,'0')),
    c17=decode(n17,0,'',lpad(rtrim(to_char(n17)),n25-n24,'0')),c18=decode(n18,0,'',lpad(rtrim(to_char(n18)),n25-n24,'0'));
--
update temp_1 set c30=(select mau from hd_ma_hd where ma_dvi=b_ma_dvi and ma=c20);
select ten into b_ten from ht_ma_cb where ma_dvi=b_ma_dvi and ma=b_ma_nh;
open cs_kq for select n23 quyen,c1 ten,c30 mau,c19 seri,n1 dk,c2 dau_dk,c3 cuoi_dk,n4 nhap,c5 dau_nhap,c6 cuoi_nhap,n7 xuat,c8 dau_xuat,
     c9 cuoi_xuat,n21 huy,c13 dau_huy,c14 cuoi_huy,n22 mat,c15 dau_mat,c16 cuoi_mat,n19 tlai,c17 dau_tlai,c18 cuoi_tlai,
     n10 ck,c11 dau_ck,c12 cuoi_ck  from temp_1 order by c20,c19,n30;
exception when others then raise_application_error(-20105,b_loi);
end;
 /
create or replace procedure BC_HD_THEKHO_NGAY
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngayd number,b_ngayc number,
    b_loai_bp varchar2,b_ma_bp varchar2,b_ma varchar2,b_nhom varchar2,b_th varchar2,b_ten out nvarchar2,cs_kq out pht_type.cs_type)
AS
    b_loi varchar2(150); b_i1 number;b_c10 varchar2(10);b_c2 varchar2(1);b_c11 varchar2(10);b_c20 varchar2(20);
    b_ngayd_m number; b_ngayc_m number;
begin
delete temp_sl; commit;
--Lan--The kho, khong tong hop tu cap duoi tu ngay ... den ngay
--b_loi:=PHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','023');
if b_ma_bp is null then b_loi:='loi:Nhap bo phan:loi'; raise PROGRAM_ERROR; end if;
if b_th is null or b_th=' ' then
    case b_loai_bp
        when 'D' then
            insert into temp_sl(c3,c1,c2) values (b_ma_bp,'D',b_ma_bp);
            insert into temp_sl(c3,c1,c2) select ma_dvi,'B',ma from ht_ma_phong where ma_dvi=b_ma_bp;
            insert into temp_sl(c3,c1,c2) select ma_dvi,'C',ma from ht_ma_nsd where ma_dvi=b_ma_bp;
        when 'B' then
            insert into temp_sl(c3,c1,c2) values (b_ma_dvi,'B',b_ma_bp);
            insert into temp_sl(c3,c1,c2) select ma_dvi,'C',ma from ht_ma_nsd where ma_dvi=b_ma_dvi and phong=b_ma_bp;
           -- insert into temp_sl(c3,c1,c2) select ma_dvi,'L',ma from bh_dl_ma_kh where ma_dvi=b_ma_dvi and phong=b_ma_bp;
        when 'C' then
            insert into temp_sl(c3,c1,c2) values (b_ma_dvi,'C',b_ma_bp);
        when 'L' then
            insert into temp_sl(c3,c1,c2) select ma_dvi,'L',ma from bh_dl_ma_kh;
    end case;
else
    insert into temp_sl(c3,c1,c2) values (b_ma_dvi,b_loai_bp,b_ma_bp);
end if;

--Dau ky
delete ket_qua;
b_ngayd_m:=round(b_ngayd/100,0)*100+1; b_ngayc_m:=b_ngayd-1;
for b_lp in (select nv||'>'||ma ma from hd_ma_hd where ma_dvi=b_ma_dvi and (b_nhom is null or b_nhom='' or ma_nhom=b_nhom) and (b_ma is null or b_ma='' or ma=b_ma)) loop
    for b_lp1 in (select distinct seri from hd_2 where ma_dvi=b_ma_dvi and ma=b_lp.ma) loop
        BC_HD_TH_CK(b_ma_dvi,b_ngayd_m,b_ngayc_m,b_loai_bp,b_ma_bp,b_lp.ma,b_lp1.seri);
        insert into ket_qua(c1,n1) select c1,n2-n1+1 from temp_1 where n1<>0;
    end loop;
end loop;
delete temp_1;
--temp_1:c1=ma_dvi,n1=so_id,n2=so_tt
insert into temp_1(c1,n1) select ma_dvi,so_id from hd_1 where l_ct in ('N','C') and
       (ma_dvi,loai_n,ma_n) in (select c3,c1,c2 from temp_sl) and htoan='H'
       and ngay_ht between b_ngayd and b_ngayc and so_id in (select so_id from hd_2 where ma_dvi=b_ma_dvi and (b_ma is null or ma=b_ma));
delete temp_3;
insert into temp_3(c1,n1,n2) select a.ma_dvi,a.so_id,b.so_tt from hd_1 a,hd_3 b where l_ct in ('X','C') and htoan='H'
       and ngay_ht between b_ngayd and b_ngayc and a.so_id in (select so_id from hd_2 where ma_dvi=b_ma_dvi and (b_ma is null or ma=b_ma))
       and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and (b.ma_dvi,b.loai_x,b.ma_x) in (select c3,c1,c2 from temp_sl);
--
delete temp_2;
insert into temp_2(n5,n3,c1,n1,n2) select a.ngay_ht,a.so_id,ma,decode(l_ct,'N',cuoi-dau+1,'C',cuoi-dau+1,0),0 from hd_1 a, hd_2 b
       where (a.ma_dvi,a.so_id) in (select c1,n1 from temp_1) and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and (b_ma is null or ma=b_ma);
insert into temp_2(n5,n3,c1,n1,n2) select a.ngay_ht,a.so_id,ma,0,decode(l_ct,'X',cuoi-dau+1,'C',cuoi-dau+1,0) from hd_1 a, hd_2 b
       where (b.ma_dvi,b.so_id,b.so_tt) in (select c1,n1,n2 from temp_3) and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and (b_ma is null or ma=b_ma);

delete temp_3;
insert into temp_3(n5,n3,c1,n1,n2) select b_ngayd,0,c1,sum(nvl(n1,0)),0 from ket_qua group by c1; --du dk
insert into temp_3(n5,n3,c1,n1,n2) select n5,n3,c1,sum(n1),sum(n2) from temp_2 group by n5,n3,c1;
delete temp_1;
insert into temp_1(n5,n3,c1,n1,n2,n4) select b_ngayd,0,c1,0,0,sum(nvl(n1,0)) from ket_qua group by c1; --du dk
insert into temp_1(n5,n3,c1,n1,n2) select n5,n3,c1,n1,n2 from temp_3 where n3>0;
delete temp_2;
insert into temp_2(c1) select distinct c1 from temp_3;
for b_lop in (select c1 from temp_2 order by c1) loop
    b_i1:=0; b_c20:=b_lop.c1;
    for b_lp in (select n5,n3,n1,n2 from temp_3 where c1=b_c20 order by n5,n3) loop
        b_i1:=b_i1+b_lp.n1-b_lp.n2;
        update temp_1 set n4=b_i1 where n5=b_lp.n5 and n3=b_lp.n3 and c1=b_c20 and n3>0;
    end loop;
end loop;
--
delete ket_qua;
insert into ket_qua(n5,n3,c1,n1,n2,n4) select n5,n3,c1,n1,n2,n4 from temp_1;
update ket_qua set (c10,c2)=(select so_ct,nd from hd_1 where ma_dvi=b_ma_dvi and so_id=n3);
update ket_qua set c11=(select ten from hd_ma_hd where ma_dvi=b_ma_dvi and ma=c1);
if b_loai_bp='D' then select ten into b_ten from ht_ma_dvi where ma=b_ma_bp;
elsif b_loai_bp='B' then select ten into b_ten from ht_ma_phong where ma_dvi=b_ma_dvi and ma=b_ma_bp;
elsif b_loai_bp='C' then select ten into b_ten from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_ma_bp;
elsif b_loai_bp='L' then select ten into b_ten from bh_dl_ma_kh where ma_dvi=b_ma_dvi and ma=b_ma_bp;
end if;
for rec in (select * from ket_qua) loop
 dbms_output.put_line(rec.c1);
end loop;
delete ket_qua where c1 not in (select nv||'>'||ma from hd_ma_hd where ma_dvi=b_ma_dvi and (b_nhom is null or ma_nhom=b_nhom));
open cs_kq for select c1 ma,c11 ten,PKH_SO_CNG(n5) ngay_ct,c10 so_ct,c2 nd,n1 nhap,n2 xuat,n4 ton from ket_qua order by c1,n5,n3;
exception when others then raise_application_error(-20105,b_loi);
end;
 /
create or replace procedure BC_HD_CAP_NHAT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngayd number,b_ngayc number,
    b_loai_bp varchar2,b_ma_bp varchar2,b_ma varchar2,b_nhom varchar2,b_chenh number,cs_kq out pht_type.cs_type)
AS
    b_loi varchar2(150); b_dau number; b_cuoi number;b_c1 varchar2(1);b_c10 varchar2(10);
begin
--Lan--Bao cao tinh hinh cap nhat an chi
delete temp_sl;
--temp_sl:c1=loai_bp,c2=ma_bp,c3=ma_dvi
select vp into b_c1 from ht_ma_dvi where ma=b_ma_dvi;
select phong into b_c10 from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_nsd;
if b_loai_bp='B' then
    if b_ma_bp='' or b_ma_bp is null then
        b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','NX','H');
        if b_loi is not null then raise PROGRAM_ERROR; end if;
        insert into temp_sl(c1,c2,n20) values ('D',b_ma_dvi,1);
        insert into temp_sl(c1,c2,n20) select 'B',ma,1 from ht_ma_phong;
        insert into temp_sl(c1,c2,n20) select 'C',ma,1 from ht_ma_nsd where ma_dvi=b_ma_dvi;
    else
        b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','NX','X');
        if b_loi is not null then raise PROGRAM_ERROR; end if;
        insert into temp_sl(c1,c2,n20) values ('B',b_ma_bp,1);
        insert into temp_sl(c1,c2,n20) select 'C',ma,1 from ht_ma_nsd where ma_dvi=b_ma_dvi and phong=b_c10;
    end if;
else if b_loai_bp='C' then
    if b_ma_bp='' or b_ma_bp is null then
        b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','NX','X');
        if b_loi is not null then raise PROGRAM_ERROR; end if;
        insert into temp_sl(c1,c2,n20) select 'C',ma,1 from ht_ma_nsd where ma_dvi=b_ma_dvi and phong=b_c10;
    else
        insert into temp_sl(c1,c2,n20) values ('C',b_ma_bp,1);
    end if;
else
    if b_ma_bp='' or b_ma_bp is null then
        insert into temp_sl(c1,c2,n20) select 'L',ma,1 from bh_dl_ma_kh where ma_dvi=b_ma_dvi;-- and phong=b_c10;
    else
        insert into temp_sl(c1,c2,n20) select 'L',ma,1 from bh_dl_ma_kh;
    end if;
end if;
end if;
--Lay cac ma hoa don
if b_ma='' or b_ma is null  then
    insert into temp_sl(c1,n20) select ma,2 from hd_ma_hd where ma_dvi=b_ma_dvi;
else
    insert into temp_sl(c1,n20) values (b_ma,2);
end if;
--cac an chi da cap trong ky bao cao--
delete temp_1;
insert into temp_1(n1,n2) select distinct a.so_id,ngay_ht from hd_1 a, hd_3 b where a.ma_dvi=b_ma_dvi
    and l_ct='X' and ngay_ht between b_ngayd and b_ngayc and a.ma_dvi=b.ma_dvi
    and a.so_id=b.so_id and (loai_x,ma_x) in (select c1,c2 from temp_sl where n20=1);
delete temp_2;
insert into temp_2(c1,c2,n3,n1,n2) select ma,seri,b.n2,dau,cuoi from hd_2 a, temp_1 b where a.ma_dvi=b_ma_dvi and a.ma_dvi=b_ma_dvi
    and a.so_id=b.n1 and ma in (select c1 from temp_sl where n20=2) and ma_tke='D';
delete temp_1;delete temp_3;
insert into temp_1(c1,c2) select distinct c1,c2 from temp_2;
for b_lop_1 in (select c1,c2 from temp_1 order by c1,c2) loop
    for b_lop in (select n3,n1,n2 from temp_2 where c1=b_lop_1.c1 and c2=b_lop_1.c2 order by n3,n1) loop
        b_dau:=b_lop.n1; b_cuoi:=b_lop.n2;
        for b_lp in b_dau..b_cuoi loop
            insert into temp_3(c1,c2,n3,n1) values (b_lop_1.c1,b_lop_1.c2,b_lop.n3,b_lp);
        end loop;
    end loop;
end loop;
update temp_3 set (d1,d2,d3,n10,d5)=(select PKH_SO_CNG_DATE(a.ngay_hl),PKH_SO_CNG_DATE(a.ngay_kt),PKH_SO_CNG_DATE(a.ngay_cap),a.ngay_ht,a.ngay_nh
    from bh_xe a ,bh_xe_ds b where a.ma_dvi=b_ma_dvi
    and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id --and gcn_m=c1
    and gcn=c2 and to_number(trim(gcn))=n1 and a.so_id in (select so_id from bh_hd_goc where ma_dvi=b_ma_dvi
    and ngay_ht between b_ngayd and b_ngayc and kieu_hd='G')); --where c1 in ('XG.2','XG.3','XG.4','XG.5') or c1 like 'OTO%';

--update temp_3 set (d1,d2,d3,n10,d5)=(select a.ngay_hl,a.ngay_kt,a.ngay_cap,b.ngay_ht,b.ngay_nh
--    from bh_xegcn a ,bh_xehdgoc b where a.ma_dvi=b_ma_dvi
--    and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and gcn_m_t=c1
--    and gcn_c_t=c2 and to_number(trim(gcn_s_t))=n1 and a.so_id in (select so_id from bh_hd_goc where ma_dvi=b_ma_dvi
--    and ngay_ht between b_ngayd and b_ngayc and kieu_hd='G')) where c1 in ('XG.2','XG.3','XG.4','XG.5') or c1 like 'OTO%' and d1 is null;

update temp_3 set (d1,d2,d3,n10,d5)=(select PKH_SO_CNG_DATE(a.ngay_hl),PKH_SO_CNG_DATE(a.ngay_kt),PKH_SO_CNG_DATE(a.ngay_cap),b.ngay_ht,b.ngay_nh
    from bh_2b_ds a, bh_2b b where a.ma_dvi=b_ma_dvi
    and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id --and a.gcn_m=c1
     and to_number(trim(a.gcn))=n1 and a.so_id in (select so_id from bh_hd_goc where ma_dvi=b_ma_dvi --and a.gcn_c=c2
    and ngay_ht between b_ngayd and b_ngayc and kieu_hd='G'));-- where c1='XG.1' or c1 like 'XM%' and d1 is null;
--LAM SACH
-- update temp_3 set (d1,d2,d3,n10,d5)=(select a.ngay_hl,a.ngay_kt,a.ngay_cap,b.ngay_ht,b.ngay_nh
--     from bh_nguoihd_ds a, bh_nguoihd b where a.ma_dvi=b_ma_dvi
--     and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and a.gcn_m=c1
--     and a.gcn_c=c2 and to_number(trim(a.gcn_s))=n1 and a.so_id in (select so_id from bh_hd_goc where ma_dvi=b_ma_dvi
--     and ngay_ht between b_ngayd and b_ngayc and kieu_hd='G')) where c1 like 'CN%' and d1 is null;

update temp_3 set n2=(select do_dai from hd_ma_hd where ma_dvi=b_ma_dvi and ma=c1);
update temp_3 set n4=0 where c2=' ';
update temp_3 set n4=length(c2) where c2<>' ';
update temp_3 set c3=decode(n1,0,'',lpad(rtrim(to_char(n1)),n2-n4,'0'));
open cs_kq for select '' quyen,c3 so_seri,c1 ma,to_char(d1,'dd/mm/yyyy') ngay_bd,
    to_char(d2,'dd/mm/yyyy') ngay_kt,to_char(PKH_SO_CDT(n10),'dd/mm/yyyy') ngay_ht,
    to_char(d5,'dd/mm/yyyy') ngay_cn,PKH_SO_CDT(n10)-d1 as chenh1,PKH_SO_CDT(PKH_NG_CSO(d5))-d1 as chenh2,
    to_char(d3,'dd/mm/yyyy') ngay_cd,PKH_SO_CDT(n10)-d3 as chenh3,PKH_SO_CDT(PKH_NG_CSO(d5))-d3 as chenh4
    from temp_3 where PKH_SO_CDT(n3)-d1>=b_chenh order by c1,c2,n1;
exception when others then raise_application_error(-20105,b_loi);
end;

/
create or replace procedure BC_HD_TH_PS
    (b_ma_dvi varchar2,b_ngayd number,b_ngayc number, b_loai_bp varchar2,b_ma_bp varchar2,b_ma varchar2,b_seri varchar2)
AS
    b_loi varchar2(150);
begin
--Lan--Tong hop phat sinh
delete temp_sl where n20=10;
case b_loai_bp
    when 'D' then
        insert into temp_sl(c10,c1,c2,n20) values (b_ma_bp,'D',b_ma_bp,10);
        insert into temp_sl(c10,c1,c2,n20) select ma_dvi,'B',ma,10 from ht_ma_phong where ma_dvi=b_ma_bp;
        insert into temp_sl(c10,c1,c2,n20) select ma_dvi,'C',ma,10 from ht_ma_nsd where ma_dvi=b_ma_bp;
        insert into temp_sl(c3,c1,c2,n20) select ma_dvi,'L',ma,10 from bh_dl_ma_kh where ma_dvi=b_ma_dvi;
    when 'B' then
        insert into temp_sl(c10,c1,c2,n20) values (b_ma_dvi,'B',b_ma_bp,10);
        insert into temp_sl(c10,c1,c2,n20) select ma_dvi,'C',ma,10 from ht_ma_nsd where ma_dvi=b_ma_dvi and phong=b_ma_bp;
        --insert into temp_sl(c3,c1,c2,n20) select ma_dvi,'L',ma,10 from bh_dl_ma_kh where ma_dvi=b_ma_dvi and phong=b_ma_bp;
    when 'C' then
        insert into temp_sl(c10,c1,c2,n20) values (b_ma_dvi,'C',b_ma_bp,10);
    when 'L' then
        insert into temp_sl(c10,c1,c2,n20) select ma_dvi,'L',ma,10 from bh_dl_ma_kh;
end case;
delete temp_1;
--So nhap--
delete temp_2;
insert into temp_2(c1,n1,n2) select ma_dvi,so_id,1 from hd_1 where ma_dvi=b_ma_dvi and loai_n=b_loai_bp and ma_n=b_ma_bp
    and ngay_ht between b_ngayd and b_ngayc and l_ct='N' and htoan='H';
insert into temp_2(c1,n1,n2) select ma_dvi,so_id,2 from hd_1 where ma_dvi=b_ma_dvi and loai_n=b_loai_bp and ma_n=b_ma_bp
    and ngay_ht between b_ngayd and b_ngayc and l_ct='C' and htoan='H';
if (b_loai_bp='D') then
    insert into temp_1(n1,n2,c10) select distinct dau,cuoi,'N'
        from hd_3 where (ma_dvi,so_id) in (select c1,n1 from temp_2 where n2=1) and ma=b_ma and seri=b_seri;
else if (b_loai_bp='B') then
    insert into temp_1(n1,n2,c10) select distinct dau,cuoi,'N'
        from hd_3 where (ma_dvi,so_id) in (select c1,n1 from temp_2 where n2=2) and ma=b_ma and seri=b_seri and loai_x='D';
else if (b_loai_bp='C') then
    insert into temp_1(n1,n2,c10) select distinct dau,cuoi,'N'
        from hd_3 where (ma_dvi,so_id) in (select c1,n1 from temp_2 where n2=2) and ma=b_ma and seri=b_seri and loai_x='B';
else insert into temp_1(n1,n2,c10) select distinct dau,cuoi,'N'
    from hd_3 where (ma_dvi,so_id) in (select c1,n1 from temp_2 where n2=2) and ma=b_ma and seri=b_seri and loai_x in ('B','C');
end if; end if; end if;
--So dieu chuyen xuong cap duoi hoac dieu chuyen tra lai cap tren
delete temp_2;
insert into temp_2(c1,n1,n2) select a.ma_dvi,a.so_id,b.so_tt from hd_1 a,hd_3 b
    where b.ma_dvi=b_ma_dvi and b.loai_x=b_loai_bp and b.ma_x=b_ma_bp
    and ngay_ht between b_ngayd and b_ngayc and l_ct='C' and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and htoan='H';
 if (b_loai_bp='D') then
     insert into temp_1(n1,n2,c10) select distinct dau,cuoi,'C'
         from hd_3 where (ma_dvi,so_id,so_tt) in (select c1,n1,n2 from temp_2) and ma=b_ma and seri=b_seri and loai_n='D';
 else if (b_loai_bp='B') then
     insert into temp_1(n1,n2,c10) select distinct dau,cuoi,'C'
         from hd_3 where (ma_dvi,so_id,so_tt) in (select c1,n1,n2 from temp_2) and ma=b_ma and seri=b_seri and loai_n='D';
 else if (b_loai_bp='C') then
     insert into temp_1(n1,n2,c10) select distinct dau,cuoi,'C'
         from hd_3 where (ma_dvi,so_id,so_tt) in (select c1,n1,n2 from temp_2) and ma=b_ma and seri=b_seri and loai_n='B';
 else insert into temp_1(n1,n2,c10) select distinct dau,cuoi,'C'
     from hd_3 where (ma_dvi,so_id,so_tt) in (select c1,n1,n2 from temp_2) and ma=b_ma and seri=b_seri and loai_n in ('B','C');
 end if; end if; end if;
--Xuat dung
delete temp_2;
insert into temp_2(c1,n1,n2) select a.ma_dvi,a.so_id,b.so_tt from hd_1 a,hd_3 b
    where (b.ma_dvi,b.loai_x,b.ma_x) in (select c10,c1,c2 from temp_sl where n20=10 and c1 in ('B','C','L'))
    and ngay_ht between b_ngayd and b_ngayc and l_ct='X' and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and htoan='H';
insert into temp_1(n1,n2,c10) select distinct dau,cuoi,'X'
    from hd_3 where (ma_dvi,so_id,so_tt) in (select c1,n1,n2 from temp_2) and ma=b_ma and seri=b_seri;
delete temp_sl where n20=10;
end;
/ 
 
 