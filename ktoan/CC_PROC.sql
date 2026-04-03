CREATE OR REPLACE procedure PCC_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id in out number,
    b_so_the varchar2,b_so_ct_ht varchar2,b_ngay_ht date,b_nhom varchar2,
    b_ma_vt varchar2,b_ten nvarchar2,b_dac_ta nvarchar2,b_ma_tk varchar2,b_luong number,
    b_ma_nt varchar2,b_gia number,b_von number,b_so_ct_kt varchar2,
    b_ngay_kt date,b_ma_nt_thu varchar2,b_thu number,b_nd nvarchar2,
    a_ngay in out pht_type.a_date,a_tien pht_type.a_num,a_nd pht_type.a_nvar,
    a_du_ngayd in out pht_type.a_date,a_du_ngayc pht_type.a_date,a_du_nd pht_type.a_nvar,
    a_bd_ngay in out pht_type.a_date,a_bd_tien pht_type.a_num,a_bd_nd pht_type.a_nvar)
AS
    b_loi varchar2(100); b_i1 number; b_i2 number; b_so_id_vt number:=0; b_pb varchar2(1); b_idvung number;
begin
-- Dan - Nhap cong cu
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','CC','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then b_loi:='loi:Nhap so ID:loi'; raise PROGRAM_ERROR; end if;
if b_so_the is null or trim(b_so_the) is null then
    b_loi:='loi:Nhap so the:loi'; raise PROGRAM_ERROR;
end if;
if b_nhom is null then b_loi:='loi:Nhap ma nhom:loi'; raise PROGRAM_ERROR; end if;
if b_ma_vt is null then b_loi:='loi:Nhap ma cong cu:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ma_tk) is null then
    b_loi:='loi:Ma tai khoan chua dang ky:loi';
    select 0 into b_i1 from kt_ma_tk where ma_dvi=b_ma_dvi and ma=b_ma_tk;
end if;
if b_luong is null or b_luong=0 then b_loi:='loi:Nhap so luong:loi'; raise PROGRAM_ERROR; end if;
select nvl(max(pb),' ') into b_pb from vt_ma_vt where ma_dvi=b_ma_dvi and nhom=b_nhom and ma=b_ma_vt;
if b_pb not in('C','T') then b_loi:='loi:sai loai cong cu:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma loai tien mua:loi';
if b_ma_nt is null then raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from tt_ma_nt where ma_dvi=b_ma_dvi and ma=b_ma_nt;
if b_i1=0 then b_loi:='loi:Sai ma loai tien:loi'; raise PROGRAM_ERROR; end if;
if b_ma_nt_thu is not null then
    b_loi:='loi:Sai ma loai tien thu hoi:loi';
    select 0 into b_i1 from tt_ma_nt where ma_dvi=b_ma_dvi and ma=b_ma_nt_thu;
end if;
PKH_MANG_D(a_ngay); PKH_MANG_D(a_du_ngayd); PKH_MANG_D(a_bd_ngay);
if a_ngay.count<>0 then
    b_i2:=0;
    for b_lp in 1..a_ngay.count loop
        b_loi:='loi:Nhap sai phan bo dong#'||to_char(b_lp)||':loi';
        if a_ngay(b_lp) is null or a_tien(b_lp) is null then raise PROGRAM_ERROR; end if;
        b_i1:=b_lp-1;
        for b_lp1 in 1..b_i1 loop
            if a_ngay(b_lp)=a_ngay(b_lp1) then raise PROGRAM_ERROR; end if;
        end loop;
        b_i2:=b_i2+a_tien(b_lp);
    end loop;
    if b_von<>b_i2 then b_loi:='b_loi:Tong tien phan bo phai bang gia von:loi'; raise PROGRAM_ERROR; end if;
end if;
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
else
    select so_id_vt into b_so_id_vt from cc_sc where ma_dvi=b_ma_dvi and so_id=b_so_id;
    delete cc_ch where ma_dvi=b_ma_dvi and so_id=b_so_id;
    delete cc_du where ma_dvi=b_ma_dvi and so_id=b_so_id;
    delete cc_bd where ma_dvi=b_ma_dvi and so_id=b_so_id;
    delete cc_sc where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
select count(*) into b_i1 from cc_sc where ma_dvi=b_ma_dvi and so_the=b_so_the;
if b_i1<>0 then b_loi:='loi:So the da co:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table CC_SC:loi';
insert into cc_sc values(b_ma_dvi,b_so_id,b_so_the,b_so_ct_ht,b_ngay_ht,b_nhom,b_ma_vt,b_ten,b_dac_ta,
    b_ma_tk,b_luong,b_ma_nt,b_gia,b_von,b_so_ct_kt,b_ngay_kt,b_ma_nt_thu,b_thu,b_nd,b_nsd,b_so_id_vt,b_idvung);
b_loi:='loi:Loi Table CC_CH:loi';
for b_lp in 1..a_ngay.count loop
    insert into cc_ch values(b_ma_dvi,b_so_id,a_ngay(b_lp),a_tien(b_lp),a_nd(b_lp),b_idvung);
end loop;
b_loi:='loi:Loi Table CC_DU:loi';
for b_lp in 1..a_du_ngayd.count loop
    insert into cc_du values(b_ma_dvi,b_so_id,a_du_ngayd(b_lp),a_du_ngayc(b_lp),a_du_nd(b_lp),b_idvung);
end loop;
b_loi:='loi:Loi Table CC_BD:loi';
for b_lp in 1..a_bd_ngay.count loop
    insert into cc_bd values(b_ma_dvi,b_so_id,a_bd_ngay(b_lp),a_bd_tien(b_lp),a_bd_nd(b_lp),b_idvung);
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PCC_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nhom varchar2,b_ma_ts varchar2,b_phong varchar2,b_ma_cb varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tc varchar2(1); b_cap number; b_i1 number;
begin
-- Dan - Liet ke theo so the va ten
delete ts_sots_temp; delete ts_sots_temp_1; delete ts_sots_temp_2; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CC','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_nhom=' ' then
    insert into ts_sots_temp select nhom,count(*) from cc_sc where ma_dvi=b_ma_dvi group by nhom;
    open cs_lke for select b.ma nhom,' ' ma_ts,a.sots so_ts,0 so_id,'' so_the,b.ten,' ' ma_ct,0 cap,'T' tc
        from ts_sots_temp a,vt_ma_nhom b where b.ma_dvi=b_ma_dvi and b.ma=a.ma_ts order by b.ma;
else
    if b_ma_ts=' ' then
        b_cap:=1; b_tc:='G';
    else
        b_cap:=FVT_MA_CAP(b_ma_dvi,b_nhom,b_ma_ts)+1;
        select nvl(min(pb),'G') into b_tc from vt_ma_vt where ma_dvi=b_ma_dvi and nhom=b_nhom and ma=b_ma_ts;
    end if;
    if b_tc='G' then
        if b_phong!=' ' or b_ma_cb!=' ' then
            insert into ts_sots_temp_1 select FVT_MA_QLY(b_ma_dvi,b_nhom,b_ma_ts,ma_vt),sots from
                (select ma_vt,count(*) sots from cc_sc where
                ma_dvi=b_ma_dvi and nhom=b_nhom and FCC_DUNG(b_ma_dvi,so_id,b_phong,b_ma_cb)='C' group by ma_vt);
        else
            insert into ts_sots_temp_1 select FVT_MA_QLY(b_ma_dvi,b_nhom,b_ma_ts,ma_vt),sots from
                (select ma_vt,count(*) sots from cc_sc where ma_dvi=b_ma_dvi and nhom=b_nhom group by ma_vt);
        end if;
        insert into ts_sots_temp_2 select ma_ts,sum(sots) from ts_sots_temp_1 where ma_ts<>' ' group by ma_ts;
        open cs_lke for select b_nhom nhom,a.ma_ts,a.sots so_ts,0 so_id,'' so_the,b.ten,b_ma_ts ma_ct,b_cap cap,'T' tc
            from ts_sots_temp_2 a,vt_ma_vt b where b.ma_dvi=b_ma_dvi and b.nhom=b_nhom and b.ma=a.ma_ts order by a.ma_ts;
    elsif b_phong!=' ' or b_ma_cb!=' ' then
        open cs_lke for select b_nhom nhom,' ' ma_ts,1 so_ts,so_id,so_the,ten,b_ma_ts ma_ct,b_cap cap,'C' tc from cc_sc where
            ma_dvi=b_ma_dvi and nhom=b_nhom and ma_vt=b_ma_ts and FCC_DUNG(b_ma_dvi,so_id,b_phong,b_ma_cb)='C' order by so_the;
    else
        open cs_lke for select b_nhom nhom,' ' ma_ts,1 so_ts,so_id,so_the,ten,b_ma_ts ma_ct,b_cap cap,'C' tc from cc_sc where
            ma_dvi=b_ma_dvi and nhom=b_nhom and ma_vt=b_ma_ts order by so_the;
    end if;
end if;
delete ts_sots_temp; delete ts_sots_temp_1; delete ts_sots_temp_2; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTS_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_ts varchar2,b_phong varchar2,b_ma_cb varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tc varchar2(1):='T'; b_cap number:=0; b_i1 number;
begin
-- Dan - Liet ke theo so the va ten
delete ts_sots_temp; delete ts_sots_temp_1; delete ts_sots_temp_2; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TS','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma_ts<>' ' then
    b_cap:=FTS_MA_TS_CAP(b_ma_dvi,b_ma_ts);
    select nvl(min(tc),'T') into b_tc from ts_ma_ts where ma_dvi=b_ma_dvi and ma=b_ma_ts;
end if;
if b_tc='T' then
    if b_phong!=' ' or b_ma_cb!=' ' then
        insert into ts_sots_temp_1 select FTS_MA_TS_QLY(b_ma_dvi,b_ma_ts,ma_ts),sots from
            (select ma_ts,count(*) sots from ts_sc_1 where ma_dvi=b_ma_dvi and FTS_DUNG(b_ma_dvi,so_id,b_phong,b_ma_cb)='C' group by ma_ts);
    else
        insert into ts_sots_temp_1 select FTS_MA_TS_QLY(b_ma_dvi,b_ma_ts,ma_ts),sots from
            (select ma_ts,count(*) sots from ts_sc_1 where ma_dvi=b_ma_dvi group by ma_ts);
    end if;
    insert into ts_sots_temp_2 select ma_ts,sum(sots) from ts_sots_temp_1 where ma_ts<>' ' group by ma_ts;
    open cs_lke for select a.ma_ts,a.sots so_ts,0 so_id,'' so_the,b.ten,b_ma_ts ma_ct,b_cap cap,'T' tc
        from ts_sots_temp_2 a,ts_ma_ts b where b.ma_dvi=b_ma_dvi and b.ma=a.ma_ts order by a.ma_ts;
elsif b_phong!=' ' or b_ma_cb!=' ' then
    open cs_lke for select ' ' ma_ts,1 so_ts,so_id,so_the,ten,b_ma_ts ma_ct,b_cap cap,'C' tc from ts_sc_1 where
        ma_dvi=b_ma_dvi and ma_ts=b_ma_ts and FTS_DUNG(b_ma_dvi,so_id,b_phong,b_ma_cb)='C' order by so_the;
else
    open cs_lke for select ' ' ma_ts,1 so_ts,so_id,so_the,ten,b_ma_ts ma_ct,b_cap cap,'C' tc from ts_sc_1 where
        ma_dvi=b_ma_dvi and ma_ts=b_ma_ts order by so_the;
end if;
delete ts_sots_temp; delete ts_sots_temp_1; delete ts_sots_temp_2; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;