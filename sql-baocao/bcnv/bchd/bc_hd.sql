create or replace procedure BC_HD_TH_BC_SO(b_dau number,b_cuoi number)
AS
    b_d number;b_c number;b_i1 number;b_i2 number;
begin
--Lan--Tong hop hoa don vao so cai bc--
select count(*) into b_i1 from hd_sc_bc_so;
if b_i1=0 then
    insert into hd_sc_bc_so values (b_dau,b_cuoi);
    return;
end if;
select max(cuoi) into b_c from hd_sc_bc_so where cuoi<=b_dau;
select min(dau) into b_d from hd_sc_bc_so where dau>=b_cuoi;
if b_c=b_dau-1 then
    select dau into b_i1 from hd_sc_bc_so where cuoi=b_c;
    if b_d=b_cuoi-1 then --la doan giua
        select cuoi into b_i2 from hd_sc_bc_so where dau=b_dau;
        delete hd_sc_bc_so where dau=b_d or cuoi=b_c;
        insert into hd_sc_bc_so values (b_i1,b_i2);
    else --la doan sau
        delete hd_sc_bc_so where cuoi=b_c;
        insert into hd_sc_bc_so values (b_i1,b_cuoi);
    end if;
else
    if b_d=b_cuoi-1 then --la doan truoc
        select cuoi into b_i2 from hd_sc_bc_so where dau=b_dau;
        delete hd_sc_bc_so where dau=b_d;
        insert into hd_sc_bc_so values (b_dau,b_i2);
    else
        insert into hd_sc_bc_so values (b_dau,b_cuoi);
    end if;
end if;
end;
/