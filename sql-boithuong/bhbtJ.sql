create or replace procedure FBH_BT_LKE_PHI
    (b_ma_dvi varchar2,b_so_id number,cs_phi out clob)
AS
begin
-- Dan - Liet ke phi, boi thuong
delete temp_1;
insert into temp_1(c1,n1) select ma_nt,sum(ttoan) from bh_hd_goc_cl where ma_dvi=b_ma_dvi and so_id=b_so_id group by ma_nt;
update temp_1 set (n2,n3)=(select nvl(sum(decode(pt,'C',0,tien)),0),nvl(sum(tien),0)
    from  bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=c1);
update temp_1 set n3=n3-n2,n4=n1-n2;
select JSON_ARRAYAGG(json_object('ma_nt' value c1,'phi' value n1,'ttoan' value n2,'no' value n3,'ton' value n4) order by c1) into cs_phi from temp_1;
delete temp_1; commit;
end;
/
create or replace procedure FBH_BT_LKE_BTH
    (b_ham varchar2,b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,cs_bth out clob)
AS
begin
-- Dan - Liet ke phi, boi thuong
if b_so_id_dt<0 then
    insert into temp_2(n10,c1,n9,c2,n1) select a.so_id,a.so_hs,a.ngay_ht,b.ma_nt,b.tien from bh_bt_hs a,bh_bt_hs_nv b where
        a.ma_dvi=b_ma_dvi and a.so_id_hd=b_so_id and a.n_duyet is not null and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id;
    insert into temp_2(n10,c1,n9,c2,n2) select a.so_id,a.so_hs,a.ngay_ht,b.ma_nt,b.tien from bh_bt_hs a,bh_bt_hs_nv b where
        a.ma_dvi=b_ma_dvi and a.so_id_hd=b_so_id and a.n_duyet is null and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id;
else
    insert into temp_2(n10,c1,n9,c2,n1) select a.so_id,a.so_hs,a.ngay_ht,b.ma_nt,b.tien from bh_bt_hs a,bh_bt_hs_nv b where
        a.ma_dvi=b_ma_dvi and a.so_id_hd=b_so_id and a.n_duyet is not null and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id and b.so_id_dt=b_so_id_dt;
    insert into temp_2(n10,c1,n9,c2,n2) select a.so_id,a.so_hs,a.ngay_ht,b.ma_nt,b.tien from bh_bt_hs a,bh_bt_hs_nv b where
        a.ma_dvi=b_ma_dvi and a.so_id_hd=b_so_id and a.n_duyet is null and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id and b.so_id_dt=b_so_id_dt;
end if;
insert into temp_3(n10,c1,n9,c2,n1,n2) select n10,c1,n9,c2,nvl(sum(n1),0),nvl(sum(n2),0) from temp_2 group by n10,c1,n9,c2;
select JSON_ARRAYAGG(json_object('ma_dvi' value b_ma_dvi,'so_id' value n10,'so_hs' value c1,
	'ngay_ht' value n9,'ma_nt' value c2,'tien' value n1,'ton' value n2) order by c1 returning clob) into cs_bth from temp_3;
end;
/
create or replace procedure PBH_BT_TEST(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_ngay_htC number,
    dt_ct clob,
-- Test chung
    b_ngay_ht out number,b_so_hs out varchar2,b_ttrang out varchar2,
    b_kieu_hs out varchar2,b_so_hs_g out varchar2,b_phong out varchar2,
    b_ngay_gui out number,b_ngay_mo out number,b_ngay_do out number,b_ngay_xr out number,
    b_n_trinh out varchar2,b_n_duyet out varchar2,b_ngay_qd out number,
    b_nt_tien out varchar2,b_c_thue out varchar2,b_tien out number,b_thue out number,
    b_noP out varchar2,b_bphi out varchar2,b_dung out varchar2,b_traN out varchar2,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_duph varchar2(1); b_dbhTra varchar2(1);
    b_ma_dvi_hd varchar2(10); b_so_hd varchar2(20); b_so_id_hd number;
begin
-- Dan kiem tra thong tin nhap ho so boi thuong
b_lenh:=FKH_JS_LENH('ngay_ht,so_hs,ttrang,kieu_hs,so_hs_g,ngay_gui,ngay_mo,ngay_do,ngay_xr,
    n_trinh,n_duyet,ngay_qd,nt_tien,c_thue,tien,thue,nop,bphi,dung,traN,duph,dbhtra,ma_dvi_ql,so_hd');
EXECUTE IMMEDIATE b_lenh into 
    b_ngay_ht,b_so_hs,b_ttrang,b_kieu_hs,b_so_hs_g,
    b_ngay_gui,b_ngay_mo,b_ngay_do,b_ngay_xr,b_n_trinh,b_n_duyet,b_ngay_qd,b_nt_tien,
    b_c_thue,b_tien,b_thue,b_noP,b_bphi,b_dung,b_traN,b_duph,b_dbhTra,b_ma_dvi_hd,b_so_hd using dt_ct;
if b_ttrang is null or b_ttrang not in('S','T','D','H','C') then b_loi:='loi:Sai tinh trang:loi'; return; end if;
--nam: cat lay ma b_n_duyet, b_n_trinh
b_duph:=nvl(trim(b_duph),'K'); b_n_duyet:=PKH_MA_TENl(b_n_duyet); b_n_trinh:=PKH_MA_TENl(b_n_trinh);
if b_duph='C' and b_ttrang<>'T' then
    b_loi:='loi:Chi tao du phong cho ho so dang trinh:loi'; return;
end if;
if b_ngay_mo is null or b_ngay_mo in(0,3000101) then b_loi:='loi:Nhap ngay mo ho so:loi'; return; end if;
if b_ngay_gui is null or b_ngay_gui in(0,3000101) then b_loi:='loi:Nhap ngay gui khieu nai:loi'; return; end if;
if b_ngay_xr is null or b_ngay_xr in(0,3000101) then b_loi:='loi:Nhap ngay xay ra:loi'; return; end if;
if b_ttrang='D' and (b_ngay_qd is null or b_ngay_qd in(0,3000101)) then b_ngay_qd:=PKH_NG_CSO(sysdate);
elsif b_ngay_qd is null then b_ngay_qd:=30000101;
end if;
if b_ngay_mo<b_ngay_xr then b_loi:='loi:Ngay mo ho so phai sau ngay xay ra:loi'; return; end if;
if b_ngay_qd<b_ngay_mo then b_loi:='loi:Ngay duyet ho so phai sau ngay mo ho so:loi'; return; end if;
if b_ngay_ht=0 then
    b_ngay_ht:=PKH_NG_CSO(sysdate);
elsif b_ngay_htC not in(0,b_ngay_ht) and FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','BH','Q')<>'C' then
    b_ngay_ht:=b_ngay_htC;
end if;
if b_ma_dvi_hd=' ' or b_so_hd=' ' then b_loi:='loi:Chon hop dong bao hiem:loi'; return; end if;
b_so_id_hd:=FBH_HD_GOC_SO_IDd(b_ma_dvi_hd,b_so_hd);
if b_so_id_hd=0 then b_loi:='loi:Hop dong chua duyet hoac da xoa:loi'; return; end if;
--nampb: anh Huy : FBH_DONG(b_ma_dvi_hd,b_so_id_hd)<>'V' => ='V'
if b_dbhTra='C' and FBH_DONG(b_ma_dvi_hd,b_so_id_hd)='V' and FTBH_TMN(b_ma_dvi_hd,b_so_id_hd)<>'C' then
    b_loi:='loi:Sai kieu Follow tra:loi'; return;
end if;
b_kieu_hs:=nvl(trim(b_kieu_hs),'G');
if b_kieu_hs='G' then
    b_so_hs_g:=' ';
    b_so_hs:=substr(to_char(b_so_id),3);
else
    b_so_hs:=nvl(trim(b_so_hs),' '); b_so_hs_g:=nvl(trim(b_so_hs_g),' ');
    if b_so_hs_g=' ' then b_loi:='loi:Nhap so ho so goc:loi'; return; end if;
    select count(*) into b_i1 from bh_bt_hs where ma_dvi=b_ma_dvi and so_hs=b_so_hs_g;
    if b_i1=0 then b_loi:='loi:Ho so goc da xoa:loi'; return; end if;
    if b_so_hs=' ' then
        select nvl(max(so_hs),' ') into b_so_hs from bh_bt_hs where ma_dvi=b_ma_dvi and so_hs_g=b_so_hs_g;
        b_i1:=instr(b_so_hs,'/B');
        if b_i1<>0 then b_i1:=PKH_LOC_CHU_SO(substr(b_so_hs,b_i1+1),'F','F'); end if;
        b_so_hs:=b_so_hs_g||'/B'||to_char(b_i1+1);
    end if;
end if;
b_noP:=nvl(trim(b_noP),'K'); b_traN:=nvl(trim(b_traN),'K');
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
if b_phong is null then b_loi:='loi:Nhap ma phong cho nguoi su dung:loi'; return; end if;
b_nt_tien:=nvl(trim(b_nt_tien),'VND');
if b_ttrang not in('T','D') then
    select count(*) into b_i1 from bh_bt_tu where ma_dvi=b_ma_dvi and so_id_hs=b_so_id;
    if b_i1<>0 then
        b_loi:='loi:Ho so da co tam ung phai de tinh trang dang trinh hoac da duyet:loi'; return;
    end if;
end if;
if b_ttrang='D' then
    if b_ngay_qd>30000000 or trim(b_n_duyet) is null then b_loi:='loi:Nhap ngay duyet, nguoi duyet:loi'; return; end if;
    if FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','BH','Q')<>'C' and FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','BH','H')<>'C' then
        b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','BT');
        if b_loi is not null then return; end if;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BT_JS_TTRANG(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number; b_i2 number; b_i3 number; b_tt varchar2(1);
    b_ma_dvi varchar2(10); b_so_id number; b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_id_dt number;
    b_dachi number:=0; b_dphong number:=0; b_nv varchar2(10); b_ttrang varchar2(1); cs_ttr clob:='';
begin
-- Dan - Trang thai ho so
delete temp_1; delete temp_2; delete bh_hd_ttrang_temp; delete tbh_ghep_nv_temp; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
select count(*) into b_i1 from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_oraOut:=''; return; end if;
select ma_dvi_ql,so_id_hd,so_id_dt,nv,ttrang into b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_nv,b_ttrang
    from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nv='XE' then
    for r_lp in(select nv,max(ttrang) ttrang from bh_bt_xeP where ma_dvi=b_ma_dvi and so_id_bt=b_so_id and ttrang in('T','D') group by nv) loop
        if r_lp.ttrang='T' then b_tt:='D'; else b_tt:='V'; end if;
        insert into bh_hd_ttrang_temp values('pa'||r_lp.nv,b_tt);
    end loop;
end if;
--nam: so_id_dt = b_so_id_dt => so_id_dt in(0,b_so_id_dt);
select count(*) into b_i1 from bh_hd_do_tl where ma_dvi=b_ma_dvi_hd and so_id=b_so_id_hd and so_id_dt in(0,b_so_id_dt);
if b_i1=0 then 
    select count(*) into b_i1 from tbh_ghep_hd where ma_dvi_hd=b_ma_dvi_hd and so_id_hd=b_so_id_hd and so_id_dt in(0,b_so_id_dt);
    if b_i1=0 then  
        select count(*) into b_i1 from tbh_tm_hd where ma_dvi_hd=b_ma_dvi_hd and so_id_hd=b_so_id_hd and so_id_dt in(0,b_so_id_dt);
        if b_i1=0 then 
            select count(*) into b_i1 from tbh_tmN_tl where ma_dvi=b_ma_dvi_hd and so_id=b_so_id_hd and so_id_dt in(0,b_so_id_dt);
        end if;
    end if;
end if;
if b_i1<>0 then insert into bh_hd_ttrang_temp values('ta_tle','V'); end if;
if b_ttrang='T' then
    b_dphong:=FBH_BT_HS_DPHONG(b_ma_dvi,b_so_id);
    --if b_dphong=0 then b_tt:='V'; else b_tt:='D'; end if;
    --insert into bh_hd_ttrang_temp values('duph',b_tt);
end if;
select nvl(sum(tien),0) into b_dachi from bh_bt_tu where ma_dvi=b_ma_dvi and so_id_hs=b_so_id;
select count(*) into b_i1 from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id_bt=b_so_id;
if b_i1<>0 then insert into bh_hd_ttrang_temp values('bt_gdhs','V'); end if;
if b_ttrang='D' then
    select nvl(sum(thu),0),nvl(sum(chi),0) into b_i1,b_i2 from bh_bt_hs_sc where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1=b_i2 then
        select nvl(sum(thu),0),nvl(sum(chi),0) into b_i1,b_i2 from bh_bt_hs_nbh where ma_dvi=b_ma_dvi and so_id=b_so_id;
    end if;
    if b_i1<>b_i2 then
        if b_i2<>0 then b_tt:='V'; else b_tt:='D'; end if;
        insert into bh_hd_ttrang_temp values('bt_tt',b_tt);
    end if;
    select nvl(sum(thu),0),nvl(sum(chi),0) into b_i1,b_i2 from bh_bt_hk_sc where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>b_i2 then
        if b_i2<>0 then b_tt:='V'; else b_tt:='D'; end if;
        insert into bh_hd_ttrang_temp values('bt_hk',b_tt);
    end if;
end if;
select nvl(sum(thu),0),nvl(sum(chi),0) into b_i1,b_i2 from bh_bt_tba_sc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>b_i2 then
    if b_i2<>0 then b_tt:='V'; else b_tt:='D'; end if;
    insert into bh_hd_ttrang_temp values('bt_tba',b_tt);
end if;
select count(*) into b_i1 from bh_hd_ttrang_temp;
if b_i1<>0 then
    select JSON_ARRAYAGG(json_object(nv,tt) returning clob) into cs_ttr from bh_hd_ttrang_temp;
end if;
select json_object('dphong' value b_dphong,'dachi' value b_dachi,'cs_ttr' value cs_ttr returning clob) into b_oraOut from dual;
delete temp_1; delete temp_2; delete bh_hd_ttrang_temp; delete tbh_ghep_nv_temp; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_LKE_TTTA(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma_dvi varchar2(10); b_so_hd varchar2(20); b_so_idD number;
    cs_do clob:=''; cs_ta clob:='';
begin
-- Dan - Ty le tai
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_hd');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_hd using b_oraIn;
b_so_idD:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi,b_so_hd);
--LAM SACH
-- select JSON_ARRAYAGG(json_object(
--     'kieu' value decode(kieu,'D','Leader','Follower'),'lh_nv' value FBH_MA_LHNV_TEN(lh_nv),pt) order by kieu,lh_nv returning clob) into cs_do
--     from (select kieu,lh_nv,max(pt) pt from bh_hd_do_tl where ma_dvi=b_ma_dvi and so_id=b_so_idD and pthuc in('C','T') group by kieu,lh_nv);
select JSON_ARRAYAGG(json_object(
    'kieu' value decode(kieu,'C','Co dinh','Tam thoi'),'lh_nv' value FBH_MA_LHNV_TEN(lh_nv),pt) order by kieu,lh_nv returning clob) into cs_ta
    from (select 'C' kieu ,lh_nv,max(pt) pt from tbh_ghep_pbo where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_idD group by lh_nv union
    select 'T' kieu,lh_nv,max(pt) pt from tbh_tm_pbo where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_idD group by lh_nv);
select json_object('cs_do' value cs_do,'cs_ta' value cs_ta returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_HSBS_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number; b_so_id_dt number; b_ngay varchar2(20);
    dt_ct clob:=''; dt_dk clob:=''; dt_hk clob:=''; dt_tba clob:=''; dt_lt clob:=''; dt_kbt clob:='';
begin
-- Dan - Liet sua doi ho so
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id,so_id_dt,ngay');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id,b_so_id_dt,b_ngay using b_oraIn;
select count(*) into b_i1 from bh_btL_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay=b_ngay;
if b_i1<>0 then
	select txt into dt_ct from bh_btL_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay=b_ngay and loai='dt_ct';
	select txt into dt_dk from bh_btL_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay=b_ngay and loai='dt_dk';
	select count(*) into b_i1 from bh_btL_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay=b_ngay and loai='dt_hk';
	if b_i1<>0 then
		select txt into dt_hk from bh_btL_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay=b_ngay and loai='dt_hk';
	end if;
	select count(*) into b_i1 from bh_btL_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay=b_ngay and loai='dt_tba';
	if b_i1<>0 then
		select txt into dt_tba from bh_btL_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay=b_ngay and loai='dt_tba';
	end if;
	select count(*) into b_i1 from bh_btL_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay=b_ngay and loai='dt_kbt';
	if b_i1<>0 then
		select txt into dt_kbt from bh_btL_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay=b_ngay and loai='dt_kbt';
    end if;
    select count(*) into b_i1 from bh_btL_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay=b_ngay and loai='dt_lt';
    if b_i1<>0 then
        select txt into dt_lt from bh_btL_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay=b_ngay and loai='dt_lt';
    end if;
end if;
dt_ct:=FKH_JS_BONH(dt_ct); dt_dk:=FKH_JS_BONH(dt_dk); dt_lt:=FKH_JS_BONH(dt_lt); 
dt_kbt:=FKH_JS_BONH(dt_kbt); dt_hk:=FKH_JS_BONH(dt_hk); dt_tba:=FKH_JS_BONH(dt_tba); 
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_id_dt' value b_so_id_dt,
    'dt_lt' value dt_lt,'dt_kbt' value dt_kbt,'dt_ct' value dt_ct,'dt_dk' value dt_dk,
    'dt_hk' value dt_hk,'dt_tba' value dt_tba returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_HSBS_LKE(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_ma_dvi varchar2(10); b_so_id number;
begin
-- viet anh - Liet sua doi ho so
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
select JSON_ARRAYAGG(json_object(so_hs,ma_dvi_ql,so_hd,gio,tien,ngay,so_id) order by ngay desc returning clob) into cs_lke
    from bh_btL where ma_dvi=b_ma_dvi and so_id=b_so_id;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_HSBS_NH(
    b_ma_dvi varchar2,b_so_id number,b_so_hs varchar2,b_ma_dvi_ql varchar2,b_so_hd varchar2,b_tien number,
    dt_ct clob,dt_dk clob,dt_hk clob,dt_tba clob,dt_lt clob,dt_kbt clob,b_loi out varchar2)
AS
    b_gio varchar2(20); b_ngayN varchar2(20);
begin
-- Dan - Nhap luu
b_loi:='loi:Loi xu ly PBH_BT_HSBS_NH:loi';
b_gio:=to_char(sysdate,'dd/mm/yyyy hh:mi:ss');
b_ngayN:=to_char(sysdate,'yymmddhhmiss');
insert into bh_btL_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct,b_ngayN);
insert into bh_btL_txt values(b_ma_dvi,b_so_id,'dt_dk',dt_dk,b_ngayN);
if dt_hk is not null then
    insert into bh_btL_txt values(b_ma_dvi,b_so_id,'dt_hk',dt_hk,b_ngayN);
end if;
if dt_tba is not null then
    insert into bh_btL_txt values(b_ma_dvi,b_so_id,'dt_tba',dt_tba,b_ngayN);
end if;
if dt_kbt is not null then
    insert into bh_btL_txt values(b_ma_dvi,b_so_id,'dt_kbt',dt_kbt,b_ngayN);
end if;
insert into bh_btL values(b_ma_dvi,b_so_id,b_so_hs,b_ma_dvi_ql,b_so_hd,b_tien,b_gio,b_ngayN);
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
-- Boi thuong phai tra nha dong: lead, nhan tai tam thoi
create or replace function FBH_BT_HS_NBH_KTRA(
    b_ma_dvi varchar2,b_so_id number,b_nbh varchar2:='') return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ton number:=0;
begin
-- Dan - Kiem tra ton phi lead
if trim(b_nbh) is null then
    select count(*) into b_i1 from bh_bt_hs_nbh where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 then b_kq:='C'; end if;
else
    for r_lp in(select distinct ma_nt from bh_bt_hs_nbh where ma_dvi=b_ma_dvi and so_id=b_so_id and nbh=b_nbh) loop
        if FBH_BT_HS_NBH_TON(b_ma_dvi,b_so_id,b_nbh,r_lp.ma_nt)<>0 then
            b_kq:='C'; exit;
        end if;
    end loop;
end if;
return b_kq;
end;
/
create or replace function FBH_BT_HS_NBH_TONh(
    b_ma_dvi varchar2,b_so_id number,b_ngay_ht number:=30000101) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number;
begin
-- Dan - Ton ho so
select nvl(max(ton),0) into b_i1 from bh_bt_hs_nbh where (so_id,nbh,ma_nt,ngay_ht) in
    (select so_id,nbh,ma_nt,max(ngay_ht) ngay_ht from bh_bt_hs_nbh where
    ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay_ht group by so_id,nbh,ma_nt);
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_BT_HS_NBH_TONn(
    b_ma_dvi varchar2,b_so_id number,b_ngay_ht number:=30000101) return varchar2
AS
    b_kq varchar2(20):=' '; a_nbh pht_type.a_var;
begin
-- Dan - Ton nbh duy nhat
select distinct nbh bulk collect into a_nbh from bh_bt_hs_nbh where (so_id,nbh,ma_nt,ngay_ht) in
    (select so_id,nbh,ma_nt,max(ngay_ht) ngay_ht from bh_bt_hs_nbh where
    ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay_ht group by so_id,nbh,ma_nt)
    and ton<>0;
if a_nbh.count=1 then b_kq:=a_nbh(1); end if;
return b_kq;
end;
/
create or replace procedure PBH_BT_HS_NBH_TON(
    b_ma_dvi varchar2,b_so_id number,b_nbh varchar2,b_ma_nt varchar2,
    b_ngay_ht number,b_ton out number,b_ton_qd out number)
AS
    b_i1 number;
begin
-- Dan - Ton va ton_qd
select nvl(max(ngay_ht),0) into b_i1 from bh_bt_hs_nbh where
    ma_dvi=b_ma_dvi and so_id=b_so_id and nbh=b_nbh and ma_nt=b_ma_nt and ngay_ht<=b_ngay_ht;
if b_i1<>0 then
    select ton,ton_qd into b_ton,b_ton_qd from bh_bt_hs_nbh where
        ma_dvi=b_ma_dvi and so_id=b_so_id and nbh=b_nbh and ma_nt=b_ma_nt and ngay_ht=b_i1;
else
    b_ton:=0; b_ton_qd:=0;
end if;
end;
/
create or replace procedure PBH_BT_HS_NBH_TH(
    b_ma_dvi varchar2,b_so_id number,b_ps varchar2,b_ngay_ht number,
    b_nbh varchar2,b_ma_nt varchar2,b_tien number,b_tien_qd number,b_loi out varchar2)
AS
    b_i1 number; b_thu number; b_chi number; b_ton number;
    b_thu_qd number; b_chi_qd number; b_ton_qd number;
begin
-- Dan - Tong hop boi thuong NBH
if b_ps='T' then b_thu:=b_tien; b_thu_qd:=b_tien_qd; b_chi:=0; b_chi_qd:=0;
else b_thu:=0; b_thu_qd:=0; b_chi:=b_tien; b_chi_qd:=b_tien_qd;
end if;
PBH_BT_HS_NBH_TON(b_ma_dvi,b_so_id,b_nbh,b_ma_nt,b_ngay_ht-1,b_ton,b_ton_qd);
update bh_bt_hs_nbh set thu=thu+b_thu,thu_qd=thu_qd+b_thu_qd,chi=chi+b_chi,chi_qd=chi_qd+b_chi_qd
    where ma_dvi=b_ma_dvi and so_id=b_so_id and nbh=b_nbh and ma_nt=b_ma_nt and ngay_ht=b_ngay_ht;
if sql%rowcount=0 then
    insert into bh_bt_hs_nbh values(b_ma_dvi,b_so_id,b_nbh,b_ma_nt,b_thu,b_thu_qd,b_chi,b_chi_qd,0,0,b_ngay_ht);
end if;
for b_rc in (select * from bh_bt_hs_nbh where ma_dvi=b_ma_dvi and so_id=b_so_id and
    nbh=b_nbh and ma_nt=b_ma_nt and ngay_ht>=b_ngay_ht order by ngay_ht) loop
    b_i1:=b_rc.ngay_ht;
    if b_rc.thu=0 and b_rc.chi=0 then
        delete bh_bt_hs_nbh where ma_dvi=b_ma_dvi and ma_dvi=b_ma_dvi and
            so_id=b_so_id and nbh=b_nbh and ma_nt=b_ma_nt and ngay_ht=b_i1;
    else
        b_ton:=b_ton+b_rc.thu-b_rc.chi; b_ton_qd:=b_ton_qd+b_rc.thu_qd-b_rc.chi_qd;
        update bh_bt_hs_nbh set ton=b_ton,ton_qd=b_ton_qd where ma_dvi=b_ma_dvi and
            so_id=b_so_id and nbh=b_nbh and ma_nt=b_ma_nt and ngay_ht=b_i1;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_HS_NBH_TH:loi'; end if;
end;
/
create or replace procedure PBH_BH_HS_NBH_TH(
    b_ma_dvi varchar2,b_so_id number,b_ps varchar2,b_ngay_ht number,
    b_nbh varchar2,b_ma_nt varchar2,b_tien number,b_tien_qd number,b_loi out varchar2)
AS
    b_i1 number; b_thu number; b_chi number; b_ton number;
    b_thu_qd number; b_chi_qd number; b_ton_qd number;
begin
-- Dan - Tong hop boi thuong NBH
b_loi:='loi:Loi xu ly PBH_BH_HS_NBH_TH:loi';
if b_ps='T' then b_thu:=b_tien; b_thu_qd:=b_tien_qd; b_chi:=0; b_chi_qd:=0;
else b_thu:=0; b_thu_qd:=0; b_chi:=b_tien; b_chi_qd:=b_tien_qd;
end if;
PBH_BH_HS_NBH_TON(b_ma_dvi,b_so_id,b_nbh,b_ma_nt,b_ngay_ht-1,b_ton,b_ton_qd);
update bh_bt_hs_nbh set thu=thu+b_thu,thu_qd=thu_qd+b_thu_qd,chi=chi+b_chi,chi_qd=chi_qd+b_chi_qd
    where ma_dvi=b_ma_dvi and so_id=b_so_id and nbh=b_nbh and ma_nt=b_ma_nt and ngay_ht=b_ngay_ht;
if sql%rowcount=0 then
    insert into bh_bt_hs_nbh values(b_ma_dvi,b_so_id,b_nbh,b_ma_nt,b_thu,b_thu_qd,b_chi,b_chi_qd,0,0,b_ngay_ht);
end if;
for b_rc in (select * from bh_bt_hs_nbh where ma_dvi=b_ma_dvi and so_id=b_so_id and
    nbh=b_nbh and ma_nt=b_ma_nt and ngay_ht>=b_ngay_ht order by ngay_ht) loop
    b_i1:=b_rc.ngay_ht;
    if b_rc.thu=0 and b_rc.chi=0 then
        delete bh_bt_hs_nbh where ma_dvi=b_ma_dvi and ma_dvi=b_ma_dvi and
            so_id=b_so_id and nbh=b_nbh and ma_nt=b_ma_nt and ngay_ht=b_i1;
    else
        b_ton:=b_ton+b_rc.thu-b_rc.chi; b_ton_qd:=b_ton_qd+b_rc.thu_qd-b_rc.chi_qd;
        update bh_bt_hs_nbh set ton=b_ton,ton_qd=b_ton_qd where ma_dvi=b_ma_dvi and
            so_id=b_so_id and nbh=b_nbh and ma_nt=b_ma_nt and ngay_ht=b_i1;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BH_HS_NBH_TON
    (b_ma_dvi varchar2,b_so_id number,b_nbh varchar2,b_ma_nt varchar2,
  b_ngay_ht number,b_ton out number,b_ton_qd out number)
AS
    b_i1 number;
begin
-- Dan - Ton va ton_qd
select nvl(max(ngay_ht),0) into b_i1 from bh_bt_hs_nbh where
    ma_dvi=b_ma_dvi and so_id=b_so_id and nbh=b_nbh and ma_nt=b_ma_nt and ngay_ht<=b_ngay_ht;
if b_i1<>0 then
    select ton,ton_qd into b_ton,b_ton_qd from bh_bt_hs_nbh where
        ma_dvi=b_ma_dvi and so_id=b_so_id and nbh=b_nbh and ma_nt=b_ma_nt and ngay_ht=b_i1;
else
    b_ton:=0; b_ton_qd:=0;
end if;
end;
