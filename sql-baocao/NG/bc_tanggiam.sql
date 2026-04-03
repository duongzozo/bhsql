CREATE OR REPLACE FUNCTION BC_TANG_GIAM_TD(so_id_t varchar2, so_id_s varchar2) return varchar2
AS
    b_kq varchar2(1):=''; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
if so_id_s is null then
  return '';
end if;
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_sk where so_id=so_id_t;
if b_i1<>0 then b_kq:='X'; end if;
return b_kq;
end;
/
CREATE OR REPLACE FUNCTION BC_TANG_GIAM_DLTD(so_id_t varchar2, so_id_s varchar2) return varchar2
AS
    b_kq varchar2(1):=''; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
if so_id_s is null then
  return '';
end if;
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_ngdl where so_id=so_id_t;
if b_i1<>0 then b_kq:='X'; end if;
return b_kq;
end;
/
create or replace procedure BC_TANG_GIAM_CUOI_KY
    (b_ma_dvin varchar2,b_nsd varchar2,b_pas varchar2,b_orain clob,b_oraout out clob)
as
    b_loi varchar2(100);
    b_ma_dvi varchar2(20):=fkh_js_gtris(b_orain,'ma_dvi'); b_so_hd varchar2(20):=fkh_js_gtris(b_orain,'so_hd');
    b_so_id_d varchar2(20); b_phi_bd number; b_ten nvarchar2(500);
    dt_ct clob; dt_ds clob;
begin
--nampb
delete temp_1;
b_loi:=fht_ma_nsd_ktra(b_ma_dvin,b_nsd,b_pas,'bh','','');
if b_loi is not null then raise program_error; end if;
select so_id_d,ten into b_so_id_d,b_ten from bh_sk where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
insert into temp_1 (n1,c1,n2,n3,n4,c2,n5,n6)
    select so_id,so_hd,ttoan,
        case
            when cnt - nvl(lag(cnt) over (order by so_id), 0) > 0
            then cnt - nvl(lag(cnt) over (order by so_id), 0)
            else 0
        end as sl_tang,
        case
            when cnt - nvl(lag(cnt) over (order by so_id), 0) < 0
            then abs(cnt - nvl(lag(cnt) over (order by so_id), 0))
            else 0
        end as sl_giam,
        bc_tang_giam_td(so_id, lag(so_id) over (order by so_id)) as td,
        case
            when ttoan - lag(ttoan) over (order by so_id) < 0
            then abs(ttoan - lag(ttoan) over (order by so_id))
            else 0
        end as phi_giam,
        case
            when ttoan - lag(ttoan) over (order by so_id) > 0
            then ttoan - lag(ttoan) over (order by so_id)
            else 0
        end as phi_tang
    from (
        select
            a.so_id,a.so_hd,a.ttoan,
            count(
                case when trunc(b.ngay_kt) > trunc(pkh_ng_cso(sysdate)) then 1 end
            ) as cnt
        from bh_sk a
        join bh_sk_ds b on a.so_id = b.so_id
        where a.so_id_d = b_so_id_d
        group by a.so_id, a.so_hd, a.ttoan
    )
    order by so_id;
select n2 into b_phi_bd from temp_1 order by n1 fetch first 1 row only;
select json_object('ten' value b_ten,'phi_bd' value b_phi_bd) into dt_ct from dual;
select json_arrayagg(json_object('so_hd' value c1,'ttoan' value n2,'sl_tang' value n3,'sl_giam' value n4,'td' value c2,'phi_giam' value n5,'phi_tang' value n6 returning clob) returning clob) into dt_ds from temp_1;
select json_object('dt_ct' value dt_ct,'dt_ds' value dt_ds returning clob) into b_oraout from dual;
delete temp_1; commit;
exception when others then raise_application_error(-20105,b_loi);
end;
/
CREATE OR REPLACE PROCEDURE BC_TANG_GIAM_CUOI_KYU
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_dvi varchar2,b_so_hd varchar2,cs_kq out pht_type.cs_type, cs_tong out pht_type.cs_type)
AS
    b_loi varchar2(100); b_so_id_d varchar2(20); b_phi_cuoi number; b_phi_bd number; b_ten nvarchar2(500);
Begin
--Nam: tang giam cuoi ky BAO
delete temp_1; commit;
select so_id_d,ten into b_so_id_d,b_ten from bh_sk where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
insert into temp_1(N1,C1,N2,N3,C2,N4,N5) select a.so_id,a.so_hd,a.ttoan,
   a.so_dt - NVL(LAG(a.so_dt) OVER (ORDER BY a.so_id),0) AS sl,
    BC_TANG_GIAM_TD(a.so_id,LAG(a.so_id) OVER (ORDER BY a.so_id)) td,
   CASE
    WHEN a.ttoan - LAG(a.ttoan) OVER (ORDER BY a.so_id) < 0 THEN
        ABS(a.ttoan - LAG(a.ttoan) OVER (ORDER BY a.so_id))
    ELSE 0
   END AS phi_giam,
    CASE
        WHEN a.ttoan - LAG(a.ttoan) OVER (ORDER BY a.so_id) > 0 THEN
            a.ttoan - LAG(a.ttoan) OVER (ORDER BY a.so_id)
        ELSE 0
   END AS phi_tang from bh_sk a
   where so_id_d = b_so_id_d group by so_id,so_dt,so_hd,ttoan order by so_id;

SELECT N2 INTO b_phi_bd FROM temp_1 ORDER BY N1 FETCH FIRST 1 ROW ONLY;
open cs_kq for select C1 so_hd,N2 ttoan,N3 sl,C2 td,N4 phi_giam,N5 phi_tang from temp_1;
open cs_tong for select b_ten b_ten,b_phi_bd b_phi_bd from dual;
delete temp_1; commit;
exception when others then raise_application_error(-20105,b_loi);
end;
/
CREATE OR REPLACE PROCEDURE BC_TANG_GIAM_CUOI_KYDL
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_dvi varchar2,b_so_hd varchar2,cs_kq out pht_type.cs_type, cs_tong out pht_type.cs_type)
AS
    b_loi varchar2(100); b_so_id_d varchar2(20); b_phi_cuoi number; b_phi_bd number; b_ten nvarchar2(500);
Begin
delete temp_1; commit;
select so_id_d,ten into b_so_id_d,b_ten from bh_ngdl where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
insert into temp_1(N1,C1,N2,N3,C2,N4,N5) select a.so_id,a.so_hd,a.ttoan,
                   count(b.so_id) - NVL(LAG(count(b.so_id)) OVER (ORDER BY a.so_id),0) AS sl,
                    BC_TANG_GIAM_DLTD(a.so_id,LAG(a.so_id) OVER (ORDER BY a.so_id)) td,
                   CASE
                    WHEN a.ttoan - LAG(a.ttoan) OVER (ORDER BY a.so_id) < 0 THEN
                        ABS(a.ttoan - LAG(a.ttoan) OVER (ORDER BY a.so_id))
                    ELSE 0
                   END AS phi_giam,
                    CASE
                        WHEN a.ttoan - LAG(a.ttoan) OVER (ORDER BY a.so_id) > 0 THEN
                            a.ttoan - LAG(a.ttoan) OVER (ORDER BY a.so_id)
                        ELSE 0
                   END AS phi_tang from bh_ngdl a, bh_ngdl_ds b
                   where a.so_id = b.so_id and a.so_id_d = b_so_id_d group by a.so_id,a.so_hd,a.ttoan order by a.so_id;

SELECT N2 INTO b_phi_bd FROM temp_1 ORDER BY N1 FETCH FIRST 1 ROW ONLY;
open cs_kq for select C1 so_hd,N2 ttoan,N3 sl,C2 td,N4 phi_giam,N5 phi_tang from temp_1;
open cs_tong for select b_ten b_ten,b_phi_bd b_phi_bd from dual;
delete temp_1; commit;
exception when others then raise_application_error(-20105,b_loi);
end;
/
CREATE OR REPLACE PROCEDURE BC_TANG_GIAM_CUOI_KYDLU
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_dvi varchar2,b_so_hd varchar2,cs_kq out pht_type.cs_type, cs_tong out pht_type.cs_type)
AS
    b_loi varchar2(100); b_so_id_d varchar2(20); b_phi_cuoi number; b_phi_bd number; b_ten nvarchar2(500);
Begin
--Nam: tang giam cuoi ky BAO
delete temp_1; commit;
select so_id_d,ten into b_so_id_d,b_ten from bh_ngdl where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
insert into temp_1(N1,C1,N2,N3,C2,N4,N5) select a.so_id,a.so_hd,a.ttoan,
   a.so_dt - NVL(LAG(a.so_dt) OVER (ORDER BY a.so_id),0) AS sl,
    BC_TANG_GIAM_DLTD(a.so_id,LAG(a.so_id) OVER (ORDER BY a.so_id)) td,
   CASE
    WHEN a.ttoan - LAG(a.ttoan) OVER (ORDER BY a.so_id) < 0 THEN
        ABS(a.ttoan - LAG(a.ttoan) OVER (ORDER BY a.so_id))
    ELSE 0
   END AS phi_giam,
    CASE
        WHEN a.ttoan - LAG(a.ttoan) OVER (ORDER BY a.so_id) > 0 THEN
            a.ttoan - LAG(a.ttoan) OVER (ORDER BY a.so_id)
        ELSE 0
   END AS phi_tang from bh_ngdl a
   where so_id_d = b_so_id_d group by so_id,so_dt,so_hd,ttoan order by so_id;

SELECT N2 INTO b_phi_bd FROM temp_1 ORDER BY N1 FETCH FIRST 1 ROW ONLY;
open cs_kq for select C1 so_hd,N2 ttoan,N3 sl,C2 td,N4 phi_giam,N5 phi_tang from temp_1;
open cs_tong for select b_ten b_ten,b_phi_bd b_phi_bd from dual;
delete temp_1; commit;
exception when others then raise_application_error(-20105,b_loi);
end;

