create or replace function FBH_BT_GD_HS_NSD(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_nsd varchar2(10);
begin
-- Dan - Tra NSD ho so
select min(nsd) into b_nsd from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_nsd;
end;
/
create or replace procedure PBH_BT_GD_HS_KTRA(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Kiem tra so du giam dinh
select nvl(max(ngay_ht),0) into b_i1 from bh_bt_gd_hs_sc where ma_dvi=b_ma_dvi and so_id=b_so_id and sign(ton)<>sign(ton_qd);
if b_i1<>0 then b_loi:='Sai so du giam dinh ngay '||PKH_SO_CNG(b_i1)||':loi'; else b_loi:=''; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function FBH_BT_GD_HS_GDINH_KIEU(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra ma giam dinh qua so ID ho so
select min(k_ma_gd) into b_kq from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_GD_HS_GDINH_MA(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(20);
begin
-- Dan - Tra ma giam dinh qua so ID ho so
select min(ma_gd) into b_kq from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_GD_HS_GDINH_TEN(
    b_ma_dvi varchar2,b_so_id number,b_dk varchar2:='K') return nvarchar2
AS
    b_kq nvarchar2(500):=''; b_k_ma_gd varchar2(1); b_ma_gd varchar2(20);
begin
-- Dan - Tra ten giam dinh qua so ID ho so
select min(k_ma_gd),min(ma_gd) into b_k_ma_gd,b_ma_gd from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_ma_gd is not null then
    b_kq:=FBH_MA_GDINH_KTEN(b_ma_dvi,b_k_ma_gd,b_ma_gd);
    if b_dk='C' then b_kq:=b_ma_gd||'|'||b_kq; end if;
end if;
return b_kq;
end;
/
create or replace function FBH_BT_GD_HS_PHONG(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan - Tra phong
select min(phong) into b_kq from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_GD_HS_TSUAT(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_kq number:=0;
begin
-- Dan - Tra thue suat
select nvl(min(t_suat),0) into b_kq from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_GD_HS_THUE(b_ma_dvi varchar2,b_so_id number,b_tien number) return number
AS
    b_kq number:=0; b_ma_nt varchar2(5); b_t_suat number; b_tp number:=0;
begin
-- Dan - Tra thue
select ma_nt,t_suat into b_ma_nt,b_t_suat from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_ma_nt='VND' then b_tp:=2; end if;
b_kq:=round(b_tien*b_t_suat/100,b_tp);
return b_kq;
end;
/
create or replace function FBH_BT_GD_HS_ID_BT(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_kq number;
begin
-- Dan - Tra ID ho so boi thuong
select nvl(min(so_id_bt),0) into b_kq from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_GD_HS_HS_BT(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(20);
begin
-- Dan - Tra ID ho so boi thuong
select nvl(min(so_hs_bt),0) into b_kq from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_GD_SO_ID_HD(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_so_id_bt number; b_so_id_hd number:=0;
begin
-- Dan - Tra so ID hop dong qua ID ho so giam dinh
select nvl(min(so_id_hd),0) into b_so_id_hd from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_so_id_hd;
end;
/
create or replace function FBH_BT_GD_HS_NGAY_XR(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_kq number:=0; b_so_id_bt number;
begin
-- Dan - Tra ngay xay ra
b_so_id_bt:=FBH_BT_GD_HS_ID_BT(b_ma_dvi,b_so_id);
if b_so_id_bt<>0 then b_kq:=FBH_BT_NGAY_XR(b_ma_dvi,b_so_id_bt); end if;
return b_kq;
end;
/
create or replace function FBH_BT_GD_HS_MA_NT(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(20);
begin
-- Dan - Tra ho so qua so ID
select nvl(min(ma_nt),' ') into b_kq from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_GD_HS_SO_ID(b_ma_dvi varchar2,b_so_hs varchar2) return number
AS
    b_kq number;
begin
-- Dan - Hoi SO ID qua so ho so
select nvl(min(so_id),0) into b_kq from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_hs=b_so_hs;
return b_kq;
end;
/
create or replace function FBH_BT_GD_HS_SO_HS(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(20);
begin
-- Dan - Tra ho so qua so ID
select nvl(min(so_hs),' ') into b_kq from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_GD_HS_HTHANH(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Nam - Xac dinh da hoan thanh
select nvl(min(ttrang),' ') into b_kq from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_GD_HS_SC_QD(
    b_ma_dvi varchar2,b_so_id number,b_ma_nt varchar2,b_l_ct varchar2,b_tien number,b_ngay_ht number:=30000101) return number
AS
    b_i1 number; b_ton number:=0; b_ton_qd number; b_tien_qd number;
begin
-- Dan - Qui doi tien
if b_ma_nt='VND' then
    b_tien_qd:=b_tien;
else
    PBH_BT_GD_HS_SC_TON(b_ma_dvi,b_so_id,b_ma_nt,b_ton,b_ton_qd,b_ngay_ht);
    if b_l_ct='T' then b_ton:=-b_ton; b_ton_qd:=-b_ton_qd; end if;
    if b_ton=b_tien then b_tien_qd:=b_ton_qd;
    elsif b_ton>b_tien then b_tien_qd:=round((b_tien*b_ton_qd/b_ton),0);
    else
        b_i1:=FBH_TT_TRA_TGTT(b_ngay_ht,b_ma_nt);
        if b_ton>0 then b_tien_qd:=b_ton_qd+round((b_tien-b_ton)*b_i1,0);
        else b_tien_qd:=round(b_tien*b_i1,0);
        end if;
    end if;
end if;
return b_tien_qd;
end;
/
create or replace function FBH_BT_GD_HS_SC_TON(b_ma_dvi varchar2,b_so_id number,b_tra number:=0) return number
AS
    b_kq number:=0; b_i1 number;
begin
-- Dan - Ton
select nvl(max(ngay_ht),0) into b_i1 from bh_bt_gd_hs_sc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then
    select ton into b_kq from bh_bt_gd_hs_sc where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht=b_i1;
end if;
b_kq:=b_kq+b_tra;
return b_kq;
end;
/
create or replace procedure PBH_BT_GD_HS_SC_TON(
    b_ma_dvi varchar2,b_so_id number,b_ma_nt varchar2,b_ton out number,b_ton_qd out number,b_ngay_ht number:=30000101)
AS
    b_i1 number;
begin
-- Dan - Ton va ton_qd
select nvl(max(ngay_ht),0) into b_i1 from bh_bt_gd_hs_sc where
    ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=b_ma_nt and ngay_ht<=b_ngay_ht;
if b_i1=0 then
    b_ton:=0; b_ton_qd:=0;
else
    select ton,ton_qd into b_ton,b_ton_qd from bh_bt_gd_hs_sc where
        ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=b_ma_nt and ngay_ht=b_i1;
end if;
end;
/
create or replace procedure PBH_BT_GD_HS_THOP(
    b_ma_dvi varchar2,b_ps varchar2,b_ngay_ht number,b_so_id number,
    b_ma_nt varchar2,b_tien number,b_tien_qd number,b_loi out varchar2)
AS
    b_thu number; b_chi number; b_ton number; b_i1 number;
    b_thu_qd number; b_chi_qd number; b_ton_qd number;
begin
-- Dan - Tong hop giam dinh
if b_ps='T' then b_thu:=b_tien; b_thu_qd:=b_tien_qd; b_chi:=0; b_chi_qd:=0;
else b_thu:=0; b_thu_qd:=0; b_chi:=b_tien; b_chi_qd:=b_tien_qd;
end if;
PBH_BT_GD_HS_SC_TON(b_ma_dvi,b_so_id,b_ma_nt,b_ton,b_ton_qd,b_ngay_ht-1);
update bh_bt_gd_hs_sc set thu=thu+b_thu,thu_qd=thu_qd+b_thu_qd,chi=chi+b_chi,chi_qd=chi_qd+b_chi_qd
    where ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=b_ma_nt and ngay_ht=b_ngay_ht;
if sql%rowcount=0 then
    insert into bh_bt_gd_hs_sc values(b_ma_dvi,b_so_id,b_ma_nt,b_thu,b_thu_qd,b_chi,b_chi_qd,0,0,b_ngay_ht);
end if;
for b_rc in (select * from bh_bt_gd_hs_sc where ma_dvi=b_ma_dvi and so_id=b_so_id and
    ma_nt=b_ma_nt and ngay_ht>=b_ngay_ht order by ngay_ht) loop
    b_i1:=b_rc.ngay_ht;
    if b_rc.thu=0 and b_rc.chi=0 then
        delete bh_bt_gd_hs_sc where ma_dvi=b_ma_dvi and ma_dvi=b_ma_dvi and
            so_id=b_so_id and ma_nt=b_ma_nt and ngay_ht=b_i1;
    else    b_ton:=b_ton+b_rc.thu-b_rc.chi; b_ton_qd:=b_ton_qd+b_rc.thu_qd-b_rc.chi_qd;
        update bh_bt_gd_hs_sc set ton=b_ton,ton_qd=b_ton_qd where ma_dvi=b_ma_dvi and
            so_id=b_so_id and ma_nt=b_ma_nt and ngay_ht=b_i1;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BT_GD_HS_PT(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS 
    b_so_id_bt number; b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_id_dt number;
    b_ngay_ht number; b_ma_nt varchar2(5);
    b_tien number; b_tien_qd number; b_thue number; b_thue_qd number;
    a_so_id_dt pht_type.a_num; a_lh_nv pht_type.a_var; a_tien pht_type.a_num;
    a_tien_qd pht_type.a_num; a_thue pht_type.a_num; a_thue_qd pht_type.a_num;
Begin
-- Dan - Phan tich
delete bh_bt_gd_hs_pt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select so_id_bt,ma_dvi_hd,so_id_hd,so_id_dt,ngay_qd,ma_nt,tien,thue,tien_qd,thue_qd
    into b_so_id_bt,b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_ngay_ht,b_ma_nt,b_tien,b_thue,b_tien_qd,b_thue_qd
    from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_so_id_bt=0 then b_loi:=''; return; end if;
PBH_BT_HS_PT(b_ma_dvi,b_so_id_bt,b_ngay_ht,b_ma_nt,b_tien,b_tien_qd,b_thue,b_thue_qd,
    a_so_id_dt,a_lh_nv,a_tien,a_tien_qd,a_thue,a_thue_qd,b_loi);
if b_loi is not null then return; end if;
forall b_lp in 1..a_so_id_dt.count
    insert into bh_bt_gd_hs_pt values(b_ma_dvi,b_so_id,b_so_id_bt,b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_ngay_ht,
        a_lh_nv(b_lp),b_ma_nt,a_tien(b_lp),a_tien_qd(b_lp),a_thue(b_lp),a_thue_qd(b_lp));
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_GD_HS_PT:loi'; end if;
end;
/
create or replace procedure PBH_BT_GD_HS_MA_NT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_hs varchar2(30); b_so_id number;
begin
-- Dan - Hoi so ID ho so qua so ho so
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_hs:=nvl(trim(b_oraIn),' ');
if b_so_hs=' ' then b_loi:='loi:Nhap so ho so giam dinh:loi'; raise PROGRAM_ERROR; end if;
b_so_id:=FBH_BT_GD_HS_SO_ID(b_ma_dvi,b_so_hs);
if b_so_id=0 then b_loi:='loi:Ho so giam dinh da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('ma_nt' value ma_nt,'t_suat' value t_suat) into b_oraOut
    from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_GD_HS_SO_HS(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_hs varchar2(30); b_so_id number;
begin
-- Dan - Hoi so ID ho so qua so ho so
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_hs:=nvl(trim(b_oraIn),' ');
if b_so_hs=' ' then b_loi:='loi:Nhap so ho so giam dinh:loi'; raise PROGRAM_ERROR; end if;
b_so_id:=FBH_BT_GD_HS_SO_ID(b_ma_dvi,b_so_hs);
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_GD_HS_HS_BT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_hs varchar2(30); b_so_id number;
begin
-- Dan - Hoi so ID ho so qua so ho so
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_hs:=nvl(trim(b_oraIn),' ');
if b_so_hs=' ' then b_loi:='loi:Nhap so ho so boi thuong:loi'; raise PROGRAM_ERROR; end if;
select min(ten||'('||nv||')') into b_oraOut from bh_bt_hs where ma_dvi=b_ma_dvi and so_hs=b_so_hs;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_GD_HS_TTRANG(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_i1 number; b_so_id number; b_tt varchar2(1); b_ngayX number;
begin
-- Dan - Trang thai ho so
delete bh_hd_ttrang_temp; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=nvl(FKH_JS_GTRIn(b_oraIn,'so_id'),0);
if b_so_id=0 then b_loi:='loi:Nhap ho so giam dinh:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_bt_gd_hs_tu where ma_dvi=b_ma_dvi and so_id_hs=b_so_id;
if b_i1<>0 then insert into bh_hd_ttrang_temp values('gd_tu','V'); end if;
if FBH_BT_GD_HTHANH(b_ma_dvi,b_so_id)='D' then
    select nvl(max(ngay_ht),0) into b_ngayX from bh_bt_gd_hs_sc where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_ngayX<>0 then
        select count(*) into b_i1 from bh_bt_gd_hs_sc where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht=b_ngayx and ton<>0;
        if b_i1<>0 then
            select count(*) into b_i1 from bh_bt_gd_hs_tt_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
            if b_i1=0 then b_tt:='D'; else b_tt:='V'; end if;
            insert into bh_hd_ttrang_temp values('gd_tt',b_tt);
        end if;
    end if;
end if;
select count(*) into b_i1 from bh_hd_ttrang_temp;
if b_i1<>0 then
    select JSON_ARRAYAGG(json_object(nv,tt) returning clob) into b_oraOut from bh_hd_ttrang_temp;
end if;
delete bh_hd_ttrang_temp; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_GD_HS_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number; b_phong varchar2(10);
    b_dong number:=0; cs_lke clob:='';
begin
-- Nam - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_bt_gd_hs where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_hs,ma_dvi,so_id) returning clob) into cs_lke from
            (select so_hs,ma_dvi,so_id,rownum sott from bh_bt_gd_hs where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc)
            where sott between b_tu and b_den;
    end if;
else
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_bt_gd_hs where ma_dvi=b_ma_dvi and phong=b_phong and ngay_ht=b_ngay_ht;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_hs,ma_dvi,so_id) returning clob) into cs_lke from
            (select so_hs,ma_dvi,so_id,rownum sott from bh_bt_gd_hs where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id desc)
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_GD_HS_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000); b_phong varchar2(10); b_tu number; b_den number;
    b_so_id number; b_ngay_ht number; b_klk varchar2(1); b_trangkt number;
    b_trang number; b_dong number; cs_lke clob:='';
begin
-- Nam - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_klk,b_trangKt using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_bt_gd_hs where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,rownum sott from bh_bt_gd_hs where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc) where so_id<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id,ma_dvi,so_hs) returning clob) into cs_lke from
        (select so_id,ma_dvi,so_hs,rownum sott from bh_bt_gd_hs where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc)
        where sott between b_tu and b_den;
else
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_bt_gd_hs where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,ma_dvi,so_hs,rownum sott from bh_bt_gd_hs where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id desc) where so_id<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id,ma_dvi,so_hs) returning clob) into cs_lke from
        (select so_id,ma_dvi,so_hs,rownum sott from bh_bt_gd_hs where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id desc) 
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_GD_HS_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number; dt_ct clob:=''; dt_txt clob:='';
begin
-- Dan - Liet ke chi tiet giam dinh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
if b_so_id<>0 then
    select json_object(so_hs,
        'ma_gd' value FBH_BT_GD_HS_GDINH_TEN(b_ma_dvi,b_so_id,'C'),
        'ma_chi' value FBH_BT_GD_HS_CHI_TENl(ma_chi)) into dt_ct 
        from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select JSON_ARRAYAGG(json_object(loai,txt returning clob)) into dt_txt from bh_bt_gd_hs_txt
        where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
end if;
select json_object('so_id' value b_so_id,'dt_ct' value dt_ct,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_GD_HS_TEST(
    b_ma_dvi varchar2,b_so_id number,dt_ct in out clob,
    b_ttrang out varchar2,b_ngay_ht out number,
    b_so_hs out varchar2,b_so_hs_bt out varchar2,b_so_id_bt out number,
    b_nv out varchar2,b_ten out nvarchar2,
    b_ma_dvi_hd out varchar2,b_so_id_hd out number,b_so_id_dt out number,
    b_ngay_qd out number,b_k_ma_gd out varchar2,b_ma_gd out varchar2,
    b_ma_chi out varchar2,b_nd out nvarchar2,b_ma_nt out varchar2,b_t_suat out number,
    b_tien out number,b_thue out number,b_tien_qd out number,b_thue_qd out number,
    b_pt_that out number,b_that out number,b_loi out varchar2)
AS
    b_i1 number; b_tg number; b_lenh varchar2(1000);
begin
-- Dan
b_loi:='loi:Loi xu ly PBH_BT_GD_HS_TEST:loi';
b_lenh:=FKH_JS_LENH('ttrang,ngay_ht,b_so_hs,so_hs_bt,ngay_qd,k_ma_gd,ma_gd,ma_chi,nd,ma_nt,t_suat,tien,thue,pt_that,that');
EXECUTE IMMEDIATE b_lenh into 
    b_ttrang,b_ngay_ht,b_so_hs,b_so_hs_bt,b_ngay_qd,b_k_ma_gd,b_ma_gd,
    b_ma_chi,b_nd,b_ma_nt,b_t_suat,b_tien,b_thue,b_pt_that,b_that using dt_ct;
b_so_hs_bt:=nvl(trim(b_so_hs_bt),' ');
if b_so_hs_bt=' ' then b_loi:='loi:Nhap so ho so boi thuong:loi'; return; end if;
b_so_id_bt:=PBH_BT_HS_SOID(b_ma_dvi,b_so_hs_bt);
if b_so_id_bt=0 then b_loi:='loi:Ho so boi thuong da xoa:loi'; end if;
select nv,ten,ma_dvi_ql,so_id_hd,so_id_dt into b_nv,b_ten,b_ma_dvi_hd,b_so_id_hd,b_so_id_dt
    from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id_bt;
b_ttrang:=nvl(trim(b_ttrang),' '); b_ngay_qd:=nvl(b_ngay_qd,0);
if b_ttrang not in('S','T','D','H') then b_loi:='loi:Sai tinh trang:loi'; return; end if;
if b_ttrang='D' and b_ngay_qd in(0,30000101) then b_loi:='loi:Nhap ngay duyet ho so:loi'; return; end if;
b_loi:='loi:Sai ma giam dinh:loi';
b_k_ma_gd:=nvl(trim(b_k_ma_gd),' '); b_ma_gd:=nvl(trim(PKH_MA_TENl(b_ma_gd)),' ');
if b_k_ma_gd not in('C','G','D') or b_ma_gd=' ' then return;
elsif b_k_ma_gd='C' then
    select 0 into b_i1 from ht_ma_cb where ma_dvi=b_ma_dvi and ma=b_ma_gd;
elsif b_k_ma_gd='G' then
    if FBH_MA_GDINH_HAN(b_ma_gd)<>'C' then return; end if;
else
    if FBH_DL_MA_KH_HAN(b_ma_gd)<>'C' then return; end if;
end if;
b_ma_chi:=nvl(trim(b_ma_chi),' ');
if FBH_BT_GD_HS_CHI_HAN(b_ma_chi)<>'C' then
    b_loi:='loi:Ma chi da xoa hoac het su dung:loi'; return;
end if;
b_tien:=nvl(b_tien,0); b_thue:=nvl(b_thue,0); b_t_suat:=nvl(b_t_suat,0);
if b_tien=0 then b_loi:='loi:Nhap tien phi:loi'; return; end if;
if sign(b_thue)<>sign(b_t_suat) then
    b_loi:='loi:Nhap sai %thue va thue:loi'; return;
end if;
if b_ma_nt='VND' then
    b_tien_qd:=b_tien; b_thue_qd:=b_thue;
else
    b_loi:='loi:Ma nguyen te chua dang ky:loi';
    select 0 into b_i1 from tt_ma_nt where ma_dvi=b_ma_dvi and ma=b_ma_nt;
    b_tg:=FBH_TT_TRA_TGTT(b_ngay_ht,b_ma_nt);
    b_tien_qd:=round(b_tien*b_tg,0); b_thue_qd:=round(b_thue*b_tg,0);
end if;
b_so_hs:=nvl(trim(b_so_hs),' ');
if b_so_hs=' ' then
    b_so_hs:=substr(to_char(b_so_id),3);
    PKH_JS_THAY(dt_ct,'so_hs',b_so_hs);
end if;
select count(*) into b_i1 from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_hs=b_so_hs;
if b_i1<>0 then b_loi:='loi:Trung so ho so giam dinh:loi'; return; end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BT_GD_HS_NH_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_ttrang varchar2,b_ngay_ht number,
    b_so_hs varchar2,b_so_hs_bt varchar2,b_so_id_bt number,b_nv varchar2,b_ten nvarchar2,
    b_ma_dvi_hd varchar2,b_so_id_hd number,b_so_id_dt number,b_ngay_qd number,
    b_k_ma_gd varchar2,b_ma_gd varchar2,b_ma_chi varchar2,b_nd nvarchar2,
    b_ma_nt varchar2,b_t_suat number,
    b_tien number,b_thue number,b_tien_qd number,b_thue_qd number,
    b_pt_that number,b_that number,dt_ct clob,b_loi out varchar2)
AS
    b_i1 number; b_phong varchar2(20); b_kieu_do varchar2(1); b_tp number:=0;
    b_tl_do number; b_tien_do number; b_tien_do_qd number; b_ttoan number; b_ttoan_qd number;
begin
-- Dan
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
b_ttoan:=b_tien+b_thue; b_ttoan_qd:=b_tien_qd+b_thue_qd;
if b_ttrang<>'D' then b_i1:=-1; else b_i1:=0; end if;
insert into bh_bt_gd_hs values(b_ma_dvi,b_so_id,b_ngay_ht,b_nv,b_so_hs,b_ttrang,
    b_so_hs_bt,b_so_id_bt,b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_phong,b_ten,b_nd,
    b_ngay_qd,b_pt_that,b_that,b_k_ma_gd,b_ma_gd,b_ma_chi,b_ma_nt,b_t_suat,
    b_tien,b_thue,b_ttoan,b_tien_qd,b_thue_qd,b_ttoan_qd,b_nsd,b_i1,sysdate);
insert into bh_bt_gd_hs_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
if b_ttrang<>'D' then b_loi:=''; return; end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_qd,'BH','BT');
if b_loi is not null then return; end if;
PBH_BT_GD_HS_PT(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
b_kieu_do:=FBH_DONG(b_ma_dvi,b_so_id_hd);
if b_ma_nt<>'VND' then b_tp:=2; end if;
if b_kieu_do='V' or FBH_TMN(b_ma_dvi_hd,b_so_id_hd)='C' then
    if b_kieu_do='V' then
        for r_lp in (select lh_nv,tien+thue tien,tien_qd+thue_qd tien_qd
            from bh_bt_gd_hs_pt where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
            b_tl_do:=100-FBH_DONG_TL_DT(b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,r_lp.lh_nv);
            if b_tl_do<>0 then
                b_tien_do:=round(r_lp.tien*b_tl_do/100,b_tp); b_tien_do_qd:=round(r_lp.tien_qd*b_tl_do/100,0);
                PBH_BT_GD_HS_THOP(b_ma_dvi,'T',b_ngay_qd,b_so_id,b_ma_nt,b_tien_do,b_tien_do_qd,b_loi);
                if b_loi is not null then raise PROGRAM_ERROR; end if;
            end if;
        end loop;
    end if;
    if FTBH_TMN(b_ma_dvi_hd,b_so_id_hd)='C' then
        for r_lp in (select lh_nv,tien+thue tien,tien_qd+thue_qd tien_qd
            from bh_bt_gd_hs_pt where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
            b_tl_do:=100-FTBH_TMN_TL_DT(b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,r_lp.lh_nv);
            if b_tl_do<>0 then
                b_tien_do:=round(r_lp.tien*b_tl_do/100,b_tp); b_tien_do_qd:=round(r_lp.tien_qd*b_tl_do/100,0);
                PBH_BT_GD_HS_THOP(b_ma_dvi,'T',b_ngay_qd,b_so_id,b_ma_nt,b_tien_do,b_tien_do_qd,b_loi);
                if b_loi is not null then raise PROGRAM_ERROR; end if;
            end if;
        end loop;
    end if;
else
    PBH_BT_GD_HS_THOP(b_ma_dvi,'T',b_ngay_qd,b_so_id,b_ma_nt,b_ttoan,b_ttoan_qd,b_loi);
    if b_loi is not null then return; end if;
end if;
if b_kieu_do='D' then
    PBH_TH_DO_GD(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
end if;
PTBH_TH_TA_GD(b_ma_dvi,b_so_id,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_GD_HS_NH_NH:loi'; end if;
end;

/
create or replace procedure PBH_BT_GD_HS_XOA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh varchar2,b_loi out varchar2)
AS 
    b_nsdC varchar2(10); b_i1 number; b_i2 number; b_tp number:=0;
    b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_id_dt number;
    b_ngay_qd number; b_ttrang varchar2(1); b_ma_nt varchar2(5); b_ttoan number; b_ttoan_qd number;
    b_kieu_do varchar2(1); b_tien_do number; b_tien_do_qd number; b_tl_do number;
Begin
-- Dan - Xoa giam dinh
b_loi:='loi:Loi xu ly PBH_BT_GD_HS_XOA_XOA:loi';
select count(*) into b_i1 from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select nsd,ngay_qd,ma_nt,ttoan,ttoan_qd,ma_dvi_hd,so_id_hd,so_id_dt,ttrang,so_id_kt
    into b_nsdC,b_ngay_qd,b_ma_nt,b_ttoan,b_ttoan_qd,b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_ttrang,b_i1
    from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sql%rowcount=0 then b_loi:='loi:Va cham NSD:loi'; return; end if;
if b_nsd<>b_nsdC then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
if b_i1>0 then b_loi:='loi:Khong sua, xoa ho so giam dinh da hach toan ke toan:loi'; return; end if;
if nvl(b_nh,' ')<>'C' then
    select count(*) into b_i1 from bh_bt_gd_hs_tu where ma_dvi=b_ma_dvi and so_id_hs=b_so_id;
    if b_i1<>0 then b_loi:='loi:Khong xoa ho so da phat sinh tam ung:loi'; return; end if;
    select count(*) into b_i1 from bh_bt_gd_hs_tt_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 then b_loi:='loi:Khong xoa ho so da phat sinh thanh toan:loi'; return; end if;
end if;
if b_ttrang='D' then
    b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_qd,'BH','BT');
    if b_loi is not null then return; end if;
    if b_ma_nt<>'VND' then b_tp:=2; end if;
    b_kieu_do:=FBH_DONG(b_ma_dvi_hd,b_so_id_hd);
    if b_kieu_do='V' or FBH_TMN(b_ma_dvi_hd,b_so_id_hd)='C' then
        if b_kieu_do='V' then
            for r_lp in (select lh_nv,tien+thue tien,tien_qd+thue_qd tien_qd
                from bh_bt_gd_hs_pt where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
                b_tl_do:=100-FBH_DONG_TL_DT(b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,r_lp.lh_nv);
                if b_tl_do<>0 then
                    b_tien_do:=round(r_lp.tien*b_tl_do/100,b_tp); b_tien_do_qd:=round(r_lp.tien_qd*b_tl_do/100,0);
                    PBH_BT_GD_HS_THOP(b_ma_dvi,'T',b_ngay_qd,b_so_id,b_ma_nt,-b_tien_do,-b_tien_do_qd,b_loi);
                    if b_loi is not null then raise PROGRAM_ERROR; end if;
                end if;
            end loop;
        end if;
        if FTBH_TMN(b_ma_dvi_hd,b_so_id_hd)='C' then
            for r_lp in (select lh_nv,tien+thue tien,tien_qd+thue_qd tien_qd
                from bh_bt_gd_hs_pt where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
                b_tl_do:=100-FTBH_TMN_TL_DT(b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,r_lp.lh_nv);
                if b_tl_do<>0 then
                    b_tien_do:=round(r_lp.tien*b_tl_do/100,b_tp); b_tien_do_qd:=round(r_lp.tien_qd*b_tl_do/100,0);
                    PBH_BT_GD_HS_THOP(b_ma_dvi,'T',b_ngay_qd,b_so_id,b_ma_nt,-b_tien_do,-b_tien_do_qd,b_loi);
                    if b_loi is not null then raise PROGRAM_ERROR; end if;
                end if;
            end loop;
        end if;
    else
        PBH_BT_GD_HS_THOP(b_ma_dvi,'T',b_ngay_qd,b_so_id,b_ma_nt,-b_ttoan,-b_ttoan_qd,b_loi);
        if b_loi is not null then return; end if;
    end if;
    if FTBH_PS(b_ma_dvi,b_so_id_hd,b_so_id)<>0 then b_loi:='loi:Khong xoa ho so da xu ly tai BH:loi'; return; end if;
    delete bh_bt_gd_hs_pt where ma_dvi=b_ma_dvi and so_id=b_so_id;
    PBH_TH_DO_XOA_PS(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
    PTBH_TH_TA_XOA(b_so_id,0,0,0,b_loi);
    if b_loi is not null then return; end if;
end if;
delete bh_bt_gd_hs_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BT_GD_HS_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_i1 number; b_lenh varchar2(1000);
    b_so_id number; b_ttrang varchar2(1); b_ngay_ht number; 
    b_so_hs varchar2(30); b_so_hs_bt varchar2(20); b_so_id_bt number; 
    b_nv varchar2(10); b_ten nvarchar2(500); 
    b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_id_dt number; 
    b_ngay_qd number; b_k_ma_gd varchar2(1); b_ma_gd varchar2(500); 
    b_ma_chi varchar2(10); b_nd nvarchar2(500); b_ma_nt varchar2(5); 
    b_tien number; b_thue number; b_tien_qd number; b_thue_qd number;
    b_pt_that number; b_that number; b_t_suat number;
    dt_ct clob;
begin
-- Dan - Nhap ho so giam dinh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=nvl(FKH_JS_GTRIn(b_oraIn,'so_id'),0);
b_lenh:=FKH_JS_LENHc('dt_ct');
EXECUTE IMMEDIATE b_lenh into dt_ct using b_oraIn;
if b_so_id<>0 then
    select count(*) into b_i1 from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1=0 then b_so_id:=0; end if;
end if;
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
else
    PBH_BT_GD_HS_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'C',b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_GD_HS_TEST(b_ma_dvi,b_so_id,dt_ct,b_ttrang,b_ngay_ht,b_so_hs,b_so_hs_bt,
    b_so_id_bt,b_nv,b_ten,b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_ngay_qd,b_k_ma_gd,b_ma_gd,
    b_ma_chi,b_nd,b_ma_nt,b_t_suat,b_tien,b_thue,b_tien_qd,b_thue_qd,b_pt_that,b_that,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_GD_HS_NH_NH(b_ma_dvi,b_nsd,b_so_id,b_ttrang,b_ngay_ht,
    b_so_hs,b_so_hs_bt,b_so_id_bt,b_nv,b_ten,
    b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_ngay_qd,
    b_k_ma_gd,b_ma_gd,b_ma_chi,b_nd,b_ma_nt,b_t_suat,
    b_tien,b_thue,b_tien_qd,b_thue_qd,b_pt_that,b_that,dt_ct,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_GD_HS_KTRA(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('so_id' value b_so_id,'so_hs' value b_so_hs) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_GD_HS_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS 
    b_loi nvarchar2(200); b_so_id number;
Begin 
-- Nam - Xoa ho so giam dinh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=nvl(FKH_JS_GTRIn(b_oraIn,'so_id'),0);
if b_so_id=0 then b_loi:='loi:Nhap ho so giam dinh:loi'; raise PROGRAM_ERROR; end if;
PBH_BT_GD_HS_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'K',b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_GD_HS_KTRA(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** Tam ung giam dinh ***/
create or replace function FBH_BT_GD_HS_TU_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_txt clob;
begin
-- Dan
select count(*) into b_i1 from bh_bt_gd_hs_tu_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_bt_gd_hs_tu_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    b_kq:=FKH_JS_GTRIu(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_BT_GD_HS_TU_ID_BT(b_ma_dvi varchar2,b_so_id number) return nvarchar2
AS
    b_kq number:=0; b_so_id_hs number;
begin
-- Dan - Tra so ID ho so boi thuong
select nvl(min(so_id_hs),0) into b_so_id_hs from bh_bt_gd_hs_tu where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_so_id_hs<>0 then
    select nvl(min(so_id_bt),0) into b_kq from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id_hs;
end if;
return b_kq;
end;
/
create or replace procedure PBH_BT_GD_HS_TU_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number; b_phong varchar2(10);
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_bt_gd_hs_tu where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id,so_hs) returning clob) into cs_lke from
            (select so_id,so_hs,rownum sott from bh_bt_gd_hs_tu where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc)
            where sott between b_tu and b_den;
    end if;
else
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_bt_gd_hs_tu where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id,so_hs) returning clob) into cs_lke from
            (select so_id,so_hs,rownum sott from bh_bt_gd_hs_tu where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id desc)
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_GD_HS_TU_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000); b_phong varchar2(10); b_tu number; b_den number;
    b_so_id number; b_ngay_ht number; b_klk varchar2(1); b_trangkt number;
    b_trang number; b_dong number; cs_lke clob:='';
begin
-- Dan - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_klk,b_trangKt using b_oraIn;
if b_klk ='N' then
    select count(*) into b_dong from bh_bt_gd_hs_tu where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,rownum sott from bh_bt_gd_hs_tu where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc) where so_id<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id,so_hs) returning clob) into cs_lke from
        (select so_id,so_hs,rownum sott from bh_bt_gd_hs_tu where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc)
        where sott between b_tu and b_den;
elsif b_klk='P' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_bt_gd_hs_tu where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,rownum sott from bh_bt_gd_hs_tu where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id desc) where so_id<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id,so_hs) returning clob) into cs_lke from
        (select so_id,so_hs,rownum sott from bh_bt_gd_hs_tu where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id desc) 
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_GD_HS_TU_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number; dt_ct clob; dt_txt clob;
begin
-- Dan - Xem chi tiet tam ung
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
if b_so_id=0 then b_loi:='loi:Nhap so tam ung:loi'; raise PROGRAM_ERROR; end if;
select json_object(so_ct) into dt_ct from bh_bt_gd_hs_tu where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob)) into dt_txt
    from bh_bt_gd_hs_tu_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select json_object('so_id' value b_so_id,'dt_ct' value dt_ct,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_GD_HS_TU_PT(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS 
    b_so_id_bt number; b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_id_dt number;
    b_so_id_hs number; b_ngay_ht number; b_ma_nt varchar2(5);
    b_tien number; b_tien_qd number; b_thue number; b_thue_qd number;
    a_so_id_dt pht_type.a_num; a_lh_nv pht_type.a_var; a_tien pht_type.a_num;
    a_tien_qd pht_type.a_num; a_thue pht_type.a_num; a_thue_qd pht_type.a_num;
Begin
-- Dan - Phan tich
delete bh_bt_gd_hs_pt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select so_id_hs,ngay_ht,ma_nt,tien,thue,tien_qd,thue_qd into b_so_id_hs,b_ngay_ht,b_ma_nt,b_tien,b_thue,b_tien_qd,b_thue_qd
    from bh_bt_gd_hs_tu where ma_dvi=b_ma_dvi and so_id=b_so_id;
select so_id_bt,ma_dvi_hd,so_id_hd,so_id_dt into b_so_id_bt,b_ma_dvi_hd,b_so_id_hd,b_so_id_dt
    from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id_hs;
if b_so_id_bt=0 then b_loi:=''; return; end if;
PBH_BT_HS_PT(b_ma_dvi,b_so_id_bt,b_ngay_ht,b_ma_nt,b_tien,b_tien_qd,b_thue,b_thue_qd,
    a_so_id_dt,a_lh_nv,a_tien,a_tien_qd,a_thue,a_thue_qd,b_loi);
if b_loi is not null then return; end if;
forall b_lp in 1..a_so_id_dt.count
    insert into bh_bt_gd_hs_pt values(b_ma_dvi,b_so_id,b_so_id_bt,b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_ngay_ht,
        a_lh_nv(b_lp),b_ma_nt,a_tien(b_lp),a_tien_qd(b_lp),a_thue(b_lp),a_thue_qd(b_lp));
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_GD_HS_TU_PT:loi'; end if;
end;
/
create or replace procedure PBH_BT_GD_HS_TU_XOA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2)
AS
    b_l_ct varchar2(1); b_ngay_ht number; b_so_id_hs number; b_i1 number;
    b_ma_nt varchar2(5); b_ttoan number; b_ttoan_qd number; b_nsdC varchar2(10);
    b_ma_dvi_hd varchar2(10); b_so_id_hd number; 
begin
-- Dan
select count(*) into b_i1 from bh_bt_gd_hs_tu where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then b_loi:=''; end if;
select nsd,so_id_kt,ngay_ht,l_ct,so_id_hs,ma_nt,ttoan,ttoan_qd
    into b_nsdC,b_i1,b_ngay_ht,b_l_ct,b_so_id_hs,b_ma_nt,b_ttoan,b_ttoan_qd
    from bh_bt_gd_hs_tu where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sql%rowcount=0 then return; end if;
if b_nsd<>b_nsdC then b_loi:='loi:Khong sua, xoa chung tu nguoi khac:loi'; return; end if;
if b_i1<>0 then b_loi:='loi:Khong sua, xoa chung tu da hach toan:loi'; return; end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','BT');
if b_loi is not null then return; end if;
PBH_BT_GD_HS_THOP(b_ma_dvi,b_l_ct,b_ngay_ht,b_so_id_hs,b_ma_nt,-b_ttoan,-b_ttoan_qd,b_loi);
if b_loi is not null then return; end if;
PBH_BT_GD_HS_KTRA(b_ma_dvi,b_so_id_hs,b_loi);
if b_loi is not null then return; end if;
delete bh_bt_gd_hs_tu_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_gd_hs_pt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_gd_hs_tu where ma_dvi=b_ma_dvi and so_id=b_so_id;
select ma_dvi_hd,so_id_hd into b_ma_dvi_hd,b_so_id_hd from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id_hs;
PBH_TH_DO_XOA_PS(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
PTBH_TH_TA_XOA(b_so_id,0,0,0,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_GD_HS_TU_XOA_XOA:loi'; end if;
end;
/
create or replace procedure PBH_BT_GD_HS_TU_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_so_id number; b_ngay_ht number; b_l_ct varchar2(20); b_phong varchar2(10);
    b_so_hs varchar2(30); b_so_id_hs number; b_so_ct varchar2(20); b_ma_nt varchar2(20);
    b_tien number; b_thue number; b_tien_qd number; b_thue_qd number; b_tg number;
    b_ttoan number; b_ttoan_qd number; b_k_ma_gd varchar2(1); b_ma_gd varchar2(20);
    b_ma_dvi_hd varchar2(10); b_so_id_hd number; dt_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct');
EXECUTE IMMEDIATE b_lenh into dt_ct using b_oraIn;
b_lenh:=FKH_JS_LENH('ngay_ht,l_ct,so_hs,so_ct,ma_nt,tien,thue');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_l_ct,b_so_hs,b_so_ct,b_ma_nt,b_tien,b_thue using dt_ct;
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
else    
    PBH_BT_GD_HS_TU_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ngay_ht:=nvl(b_ngay_ht,0);
if b_ngay_ht=0 then b_ngay_ht:=PKH_NG_CSO(sysdate); end if;
b_l_ct:=nvl(trim(b_l_ct),' ');
if b_l_ct not in('T','C') then b_loi:='loi:Sai loai ung:loi'; raise PROGRAM_ERROR; end if;
b_so_hs:=nvl(trim(b_so_hs),' ');
if b_so_hs=' ' then b_loi:='loi:Nhap so ho so giam dinh:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Ho so giam dinh da xoa:loi';
select so_id,ma_dvi_hd,so_id_hd,k_ma_gd,ma_gd into b_so_id_hs,b_ma_dvi_hd,b_so_id_hd,b_k_ma_gd,b_ma_gd
    from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_hs=b_so_hs;
if b_l_ct='C' and FBH_BT_GD_HS_HTHANH(b_ma_dvi,b_so_id_hs) in('D','H') then
     b_loi:='loi:Khong tam ung cho ho so giam dinh da ket thuc:loi'; raise PROGRAM_ERROR;
end if;
b_tien:=nvl(b_tien,0); b_thue:=nvl(b_thue,0);
if b_tien=0 then b_loi:='loi:Nhap tien:loi'; raise PROGRAM_ERROR; end if;
b_ma_nt:=nvl(trim(b_ma_nt),' ');
if b_ma_nt<>FBH_BT_GD_HS_MA_NT(b_ma_dvi,b_so_id_hs) then
    b_loi:='loi:Khong ung tien khac ho so giam dinh:loi'; raise PROGRAM_ERROR;
end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','BT');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma_nt='VND' then
    b_tien_qd:=b_tien; b_thue_qd:=b_thue;
else
    b_tg:=FBH_TT_TRA_TGTT(b_ngay_ht,b_ma_nt);
    b_tien_qd:=round(b_tien*b_tg,0); b_thue_qd:=round(b_thue*b_tg,0);
end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
b_so_ct:=nvl(trim(b_so_ct),' ');
if b_so_ct=' ' then
    b_so_ct:=substr(to_char(b_so_id),3);
    PKH_JS_THAY(dt_ct,'so_ct',b_so_ct);
end if;
b_ttoan:=b_tien+b_thue; b_ttoan_qd:=b_tien_qd+b_thue_qd;
insert into bh_bt_gd_hs_tu values(b_ma_dvi,b_so_id,b_ngay_ht,b_l_ct,b_phong,
    b_so_hs,b_so_id_hs,b_k_ma_gd,b_ma_gd,b_so_ct,b_ma_nt,b_tien,b_thue,b_ttoan,
    b_tien_qd,b_thue_qd,b_ttoan_qd,b_nsd,sysdate,0);
insert into bh_bt_gd_hs_tu_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
PBH_BT_GD_HS_TU_PT(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_GD_HS_THOP(b_ma_dvi,b_l_ct,b_ngay_ht,b_so_id_hs,b_ma_nt,b_ttoan,b_ttoan_qd,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_GD_HS_KTRA(b_ma_dvi,b_so_id_hs,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
--if FBH_DONG(b_ma_dvi_hd,b_so_id_hd)='D' then
--    PBH_TH_DO_GDu(b_ma_dvi,b_so_id,b_loi);
--    if b_loi is not null then raise PROGRAM_ERROR; end if;
--end if;
PTBH_TH_TA_GDu(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('so_id' value b_so_id,'so_ct' value b_so_ct) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_GD_HS_TU_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi nvarchar2(200); b_so_id number;
begin
-- Nam - Xoa tam ung
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=NVL(FKH_JS_GTRIn(b_oraIn,'so_id'),0);
if b_so_id=0 then b_loi:='loi:Nhap so tam ung:loi'; raise PROGRAM_ERROR; end if;
PBH_BT_GD_HS_TU_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_GD_HS_TU_TIM(
     b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ngayD number; b_ngayC number; 
    b_so_hs varchar2(30); b_ma_gd varchar2(20); b_k_ma_gd varchar2(1);
    b_tu number; b_den number; b_dong number; cs_lke clob;
Begin
-- Dan
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,so_hs,k_ma_gd,ma_gd,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_so_hs,b_k_ma_gd,b_ma_gd,b_tu,b_den using b_oraIn;
b_ngayD:=nvl(b_ngayd,0); b_ngayC:=nvl(b_ngayC,0);
b_so_hs:=nvl(trim(b_so_hs),' '); b_ma_gd:=nvl(trim(b_ma_gd),' ');
b_k_ma_gd:=nvl(trim(b_k_ma_gd),' ');
b_tu:=nvl(b_tu,0); b_den:=nvl(b_den,0);
if b_ngayC in(0,30000101) then b_ngayC:=PKH_NG_CSO(sysdate); end if;
b_i1:=PKH_NG_CSO(add_months(PKH_SO_CDT(b_ngayC),-36));
if b_ngayD in(0,30000101) or b_ngayD<b_i1 then b_ngayD:=b_i1; end if;
insert into temp_1(n1,n2,n3,c1,c2,c3,c4)
    select so_id,ngay_ht,tien,so_hs,FBH_BT_GD_HS_GDINH_TEN(b_ma_dvi,so_id_hs),ma_nt,so_ct
    from bh_bt_gd_hs_tu where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and
    b_so_hs in(' ',so_hs) and b_ma_gd in(' ',ma_gd) and b_k_ma_gd in(' ',k_ma_gd) and rownum<302
    order by ngay_ht desc,so_id;
select count(*) into b_dong from temp_1;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(so_id,ngay_ht,tien,so_hs,ma_gd,ma_nt,so_ct) returning clob) into cs_lke from
    (select n1 so_id,n2 ngay_ht,n3 tien,c1 so_hs,c2 ma_gd,c3 ma_nt,c4 so_ct,rownum sott from temp_1 order by n1 desc,n1)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
/*** THANH TOAN GIAM DINH ***/
create or replace function FBH_BT_GD_HS_TT_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_txt clob;
begin
-- Dan
select count(*) into b_i1 from bh_bt_gd_hs_tt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_bt_gd_hs_tt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    b_kq:=FKH_JS_GTRIu(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_BT_GD_HS_TT_NGAY(b_ma_dvi varchar2,b_so_id_tt number) return number
AS
    b_ngay number;
begin
-- Dan - Tra so ho so thanh toan
select nvl(min(ngay_ht),0) into b_ngay from bh_bt_gd_hs_tt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
return b_ngay;
end;
/
create or replace procedure PBH_BT_GD_HS_TT_TON(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_so_id number; b_ton number;
    b_so_hs varchar2(30); b_k_ma_gd varchar2(10); 
    --duchq tang them do dai cua truong ma_gd
    b_ma_gd varchar2(200);
begin
-- Dan - Liet ke no
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hs,k_ma_gd,ma_gd');
EXECUTE IMMEDIATE b_lenh into b_so_hs,b_k_ma_gd,b_ma_gd using b_oraIn;
b_so_hs:=nvl(trim(b_so_hs),' '); b_k_ma_gd:=nvl(trim(b_k_ma_gd),' '); 
--duchq them ham lay ma
b_ma_gd:=nvl(trim(PKH_MA_TENl(b_ma_gd)),' ');
if b_so_hs<>' ' then
    b_so_id:=FBH_BT_GD_HS_SO_ID(b_ma_dvi,b_so_hs);
    if b_so_id=0 then b_loi:='loi:So ho so giam dinh da xoa:loi'; raise PROGRAM_ERROR; end if;
    if FBH_BT_GD_HS_HTHANH(b_ma_dvi,b_so_id)<>'D' then
        b_loi:='loi:So ho so giam dinh chua hoan thanh:loi'; raise PROGRAM_ERROR;
    end if;
    b_ton:=FBH_BT_GD_HS_SC_TON(b_ma_dvi,b_so_id);
    select JSON_ARRAYAGG(json_object(ngay_qd,so_hs,so_hs_bt,ma_gd,
        'ma_nt' value ma_nt,'ton' value b_ton,'tien' value b_ton,
        'chon' value '','so_id' value so_id returning clob) order by ngay_qd, so_hs) into b_oraOut
        from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    if b_k_ma_gd not in('G','D','C') or b_ma_gd=' ' then
        b_loi:='loi:Sai ma giam dinh:loi'; raise PROGRAM_ERROR;
    end if;
    select JSON_ARRAYAGG(json_object(ngay_qd,so_hs,so_hs_bt,ma_gd,
        'ma_nt' value ma_nt,'ton' value ton,'tien' value ton, -- viet anh
        'chon' value '','so_id' value so_id returning clob) order by ngay_qd, so_hs) into b_oraOut from
    (select so_id,so_hs,so_hs_bt,ma_gd,ngay_qd,ma_nt,FBH_BT_GD_HS_SC_TON(b_ma_dvi,so_id) ton from bh_bt_gd_hs
        where ma_dvi=b_ma_dvi and k_ma_gd=b_k_ma_gd and ma_gd=b_ma_gd and ttrang='D') where ton<>0;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_BT_GD_HS_TT_TONG(
    b_ma_dvi varchar2,b_nt_tra varchar2,b_tg number,
    b_tien out number,b_thue out number,b_tra out number,
    a_so_id pht_type.a_num,a_ma_nt pht_type.a_var,a_tien pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_ttoan number; b_ma_nt varchar2(5); b_t_suat number; b_tp number:=0;
begin
-- Dan - Liet ke no
b_loi:='loi:loi xu ly FBH_BT_GD_HS_TT_TONG:loi';
b_tien:=0; b_thue:=0; b_tra:=0;
if a_so_id.count=0 then b_loi:=''; return; end if;
b_ma_nt:=a_ma_nt(1);
if b_ma_nt<>'VND' then b_tp:=2; end if;
for b_lp in 1..a_so_id.count loop
    if b_ma_nt<>a_ma_nt(b_lp) then
        b_loi:='loi:Thanh toan cung loai tien:loi'; return;
    end if;
    b_t_suat:=FBH_BT_GD_HS_TSUAT(b_ma_dvi,a_so_id(b_lp));
    b_i1:=round(a_tien(b_lp)*100/(100+b_t_suat),b_tp);
    b_tien:=b_tien+b_i1;
    b_thue:=b_thue+a_tien(b_lp)-b_i1;
end loop;
b_ttoan:=b_tien+b_thue;
if b_nt_tra=b_ma_nt then
    b_tra:=b_ttoan;
elsif b_nt_tra='VND' then
    b_tra:=round(b_ttoan*b_tg,0);
else
    b_tra:=round(b_ttoan/b_tg,2);
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BT_GD_HS_TT_TONG(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_nt_tra varchar2(5); b_tg number; b_tra number:=0;
    b_tien number:=0; b_thue number:=0; b_ttoan number;
    b_ma_nt varchar2(5); b_t_suat number; b_tp number:=0;
    a_so_id pht_type.a_num; a_ma_nt pht_type.a_var; a_tien pht_type.a_num;
    dt_ct clob; dt_dk clob;
begin
-- Dan - Liet ke no
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk using b_oraIn;
FKH_JS_NULL(dt_ct);
b_lenh:=FKH_JS_LENH('nt_tra,tygia');
EXECUTE IMMEDIATE b_lenh into b_nt_tra,b_tg using dt_ct;
b_lenh:=FKH_JS_LENH('so_id,ma_nt,tien');
EXECUTE IMMEDIATE b_lenh bulk collect into a_so_id,a_ma_nt,a_tien using dt_dk;
FBH_BT_GD_HS_TT_TONG(
    b_ma_dvi,b_nt_tra,b_tg,b_tien,b_thue,b_tra,a_so_id,a_ma_nt,a_tien,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('tien' value b_tien,'thue' value b_thue,'tra' value b_tra) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_GD_HS_TT_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number; b_phong varchar2(10);
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_bt_gd_hs_tt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id_tt,so_hs)) into cs_lke from
            (select so_id_tt,so_hs,rownum sott from bh_bt_gd_hs_tt where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id_tt desc)
            where sott between b_tu and b_den;
    end if;
else
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_bt_gd_hs_tt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
            select JSON_ARRAYAGG(json_object(so_id_tt,so_hs)) into cs_lke from
            (select so_id_tt,so_hs,rownum sott from bh_bt_gd_hs_tt where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id_tt desc)
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_GD_HS_TT_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000); b_phong varchar2(10); b_tu number; b_den number;
    b_so_id number; b_ngay_ht number; b_klk varchar2(1); b_trangkt number;
    b_trang number; b_dong number; cs_lke clob:='';
begin
-- Dan - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_klk,b_trangKt using b_oraIn;
if b_klk ='N' then
    select count(*) into b_dong from bh_bt_gd_hs_tt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_id_tt,rownum sott from bh_bt_gd_hs_tt where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id_tt desc) where so_id_tt<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id_tt,so_hs)) into cs_lke from
        (select so_id_tt,so_hs,rownum sott from bh_bt_gd_hs_tt where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id_tt desc)
        where sott between b_tu and b_den;
elsif b_klk='P' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_bt_gd_hs_tt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from (select so_id_tt,rownum sott from bh_bt_gd_hs_tt where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id_tt desc) where so_id_tt<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id_tt,so_hs)) into cs_lke from
        (select so_id_tt,so_hs,rownum sott from bh_bt_gd_hs_tt where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id_tt desc) 
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_GD_HS_TT_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number; dt_ct clob; dt_dk clob; dt_txt clob;
begin
-- Dan - Xem chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
if b_so_id=0 then b_loi:='loi:Nhap so thanh toan:loi'; raise PROGRAM_ERROR; end if;
select json_object(so_ct,'ma_gd' value FBH_MA_GDINH_KTEN(b_ma_dvi,k_ma_gd,ma_gd,'C'))
    into dt_ct from bh_bt_gd_hs_tt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id;
select JSON_ARRAYAGG(json_object(so_id,'ton' value FBH_BT_GD_HS_SC_TON(b_ma_dvi,so_id,tien)) order by bt returning clob)
    into dt_dk from bh_bt_gd_hs_tt_ps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob)) into dt_txt
    from bh_bt_gd_hs_tt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select json_object('so_id' value b_so_id,'dt_ct' value dt_ct,
    'dt_dk' value dt_dk,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_GD_HS_TT_TEST(
    b_ma_dvi varchar2,dt_ct in out clob,dt_dk clob,b_so_id_tt number,
    b_ngay_ht out number,b_so_ct out varchar2,
    b_so_hs out varchar2,b_k_ma_gd out varchar2,b_ma_gd out varchar2,
    b_tien out number,b_tien_qd out number,b_thue out number,b_thue_qd out number,
    b_nt_tra out varchar2,b_tygia out number,b_tra out number,b_tra_qd out number,
    a_so_id out pht_type.a_num,a_ma_nt out pht_type.a_var,
    a_tien out pht_type.a_num,a_tien_qd out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_lenh varchar2(1000);
    b_k_ma_gdT varchar2(1); b_ma_gdT varchar2(20); b_t_suat number; b_ton number;
begin
-- Dan - kiem tra thong tin nhap thanh toan
b_loi:='loi:Loi xu ly PBH_BT_GD_HS_TT_TEST:loi';
b_lenh:=FKH_JS_LENH('ngay_ht,so_ct,so_hs,k_ma_gd,ma_gd,nt_tra,tygia,tra');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_so_ct,b_so_hs,b_k_ma_gd,b_ma_gd,b_nt_tra,b_tygia,b_tra using dt_ct;
b_lenh:=FKH_JS_LENH('so_id,ma_nt,tien');
EXECUTE IMMEDIATE b_lenh bulk collect into a_so_id,a_ma_nt,a_tien using dt_dk;
if a_so_id.count=0 then b_loi:='loi:Nhap danh sach thanh toan:loi'; return; end if;
b_ngay_ht:=nvl(b_ngay_ht,0); b_so_ct:=nvl(trim(b_so_ct),' ');
b_so_hs:=nvl(trim(b_so_hs),' '); b_k_ma_gd:=nvl(trim(b_k_ma_gd),' ');
b_ma_gd:=PKH_MA_TENl(b_ma_gd);
if b_so_hs<>' ' then
    select nvl(min(k_ma_gd),' '),nvl(min(ma_gd),' ') into b_k_ma_gdT,b_ma_gdT
        from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_hs=b_so_hs;
else
    b_k_ma_gdT:=b_k_ma_gd; b_ma_gdT:=b_ma_gd;
end if;
if b_k_ma_gdT=' ' or b_ma_gdT=' ' then
    b_loi:='loi:Nhap so ho so giam dinh, ma giam dinh:loi'; return;
end if;
for b_lp in 1..a_so_id.count loop
    b_loi:='loi:Sai chi tiet dong '||to_char(b_lp)||':loi';
    a_so_id(b_lp):=nvl(a_so_id(b_lp),0); a_ma_nt(b_lp):=nvl(trim(a_ma_nt(b_lp)),' ');
    a_tien(b_lp):=nvl(a_tien(b_lp),0);
    if a_so_id(b_lp)=0 or a_ma_nt(b_lp)=' ' or a_tien(b_lp)=0 then return; end if;
    --nam: chan khong duoc thanh toan vuot ho so giam dinh
    b_ton:=FBH_BT_GD_HS_SC_TON(b_ma_dvi,a_so_id(b_lp));
    if a_tien(b_lp)>b_ton then b_loi:='loi:Tong chi nhieu hon ho so:loi'; return; end if;
    if b_k_ma_gd=' ' or b_ma_gd=' ' then
        select k_ma_gd,ma_gd into b_k_ma_gd,b_ma_gd from bh_bt_gd_hs where 
            ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp) and ttrang='D';
        PKH_JS_THAY(dt_ct,'k_ma_gd',b_k_ma_gd);
        PKH_JS_THAY(dt_ct,'ma_gd',b_ma_gd);
    else
        select count(*) into b_i1 from bh_bt_gd_hs where 
            ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp) and ttrang='D' and k_ma_gd=b_k_ma_gd and ma_gd=b_ma_gd;
        if b_i1=0 then b_loi:='loi:Thanh toan cho mot giam dinh:loi'; return; end if;
    end if;
end loop;
FBH_BT_GD_HS_TT_TONG(b_ma_dvi,b_nt_tra,b_tygia,b_tien,b_thue,b_i1,a_so_id,a_ma_nt,a_tien,b_loi);
if b_loi is not null then return; end if;
--nam: khoi tao gia tri thue va tien
b_tien_qd:=nvl(b_tien_qd,0); b_thue_qd:=nvl(b_thue_qd,0);
for b_lp in 1..a_so_id.count loop
    if a_ma_nt(1)='VND' then
        a_tien_qd(b_lp):=a_tien(b_lp);
    else
        a_tien_qd(b_lp):=FBH_BT_GD_HS_SC_QD(b_ma_dvi,a_so_id(b_lp),a_ma_nt(b_lp),'C',a_tien(b_lp),b_ngay_ht);
    end if;
    b_tien_qd:=b_tien_qd+a_tien_qd(b_lp);
    b_t_suat:=FBH_BT_GD_HS_TSUAT(b_ma_dvi,a_so_id(b_lp));
    b_thue_qd:=b_thue_qd+round(a_tien_qd(b_lp)*b_t_suat/100,0);
end loop;
b_nt_tra:=nvl(trim(b_nt_tra),' '); b_tra:=nvl(b_tra,0);
if b_nt_tra<>'VND' then b_tra_qd:=b_tra;
else
    if FBH_TT_KTRA(b_nt_tra)<>'C' then b_loi:='loi:Sai loai tien tra:loi'; return; end if;
    b_tra_qd:=FBH_TT_VND_QD(b_ngay_ht,b_nt_tra,b_tra);
end if;
if b_so_ct=' ' then
    b_so_ct:=substr(to_char(b_so_id_tt),3);
    PKH_JS_THAY(dt_ct,'so_ct',b_so_ct);
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BT_GD_HS_TT_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,dt_ct clob,dt_dk clob,b_so_id_tt number,
    b_ngay_ht number,b_so_ct varchar2,
    b_so_hs varchar2,b_k_ma_gd varchar2,b_ma_gd varchar2,
    b_tien number,b_tien_qd number,b_thue number,b_thue_qd number,
    b_nt_tra varchar2,b_tygia number,b_tra number,b_tra_qd number,
    a_so_id pht_type.a_num,a_ma_nt pht_type.a_var,
    a_tien pht_type.a_num,a_tien_qd pht_type.a_num,b_loi out varchar2)
AS
    b_phong varchar2(10);
begin
-- Dan - Nhap thanh toan
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','BT');
if b_loi is not null then return; end if;
for b_lp in 1..a_so_id.count loop
    PBH_BT_GD_HS_THOP(b_ma_dvi,'C',b_ngay_ht,a_so_id(b_lp),a_ma_nt(b_lp),a_tien(b_lp),a_tien_qd(b_lp),b_loi);
    if b_loi is not null then return; end if;
    PBH_BT_GD_HS_KTRA(b_ma_dvi,a_so_id(b_lp),b_loi);
    if b_loi is not null then return; end if;
end loop;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
b_loi:='loi:Loi Table bh_bt_gd_hs_tt:loi';
insert into bh_bt_gd_hs_tt values(b_ma_dvi,b_so_id_tt,b_ngay_ht,b_so_hs,
    b_k_ma_gd,b_ma_gd,b_phong,b_so_ct,a_ma_nt(1),
    b_tien,b_thue,b_tien+b_thue,b_tien_qd,b_thue_qd,b_tien_qd+b_thue_qd,
    b_nt_tra,b_tygia,b_tra,b_tra_qd,b_nsd,sysdate,0);
b_loi:='loi:Loi Table bh_bt_gd_hs_tt_PS:loi';
for b_lp in 1..a_so_id.count loop
    insert into bh_bt_gd_hs_tt_ps values(b_ma_dvi,b_so_id_tt,b_lp,a_so_id(b_lp),a_ma_nt(b_lp),a_tien(b_lp),a_tien_qd(b_lp));
end loop;
insert into bh_bt_gd_hs_tt_txt values(b_ma_dvi,b_so_id_tt,'dt_ct',dt_ct);
insert into bh_bt_gd_hs_tt_txt values(b_ma_dvi,b_so_id_tt,'dt_dk',dt_dk);
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BT_GD_HS_TT_XOA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id_tt number,b_loi out varchar2)
AS 
    b_i1 number; b_ngay_ht number; b_so_id number; 
    b_ttoan number; b_ttoan_qd number; b_nsdC varchar2(20);
Begin
-- Dan - Xoa thanh toan boi thuong
b_loi:='loi:Loi xu ly PBH_BT_GD_HS_TT_XOA_XOA:loi';
select count(*) into b_i1 from bh_bt_gd_hs_tt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
if b_i1=0 then b_loi:=''; return; end if;
select ngay_ht,nsd,so_id_kt into b_ngay_ht,b_nsdC,b_i1 from bh_bt_gd_hs_tt
    where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt for update nowait;
if sql%rowcount=0 then b_loi:='loi:Va cham NSD:loi'; return; end if;
if b_nsd<>b_nsdC then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
if b_i1<>0 then b_loi:='loi:Khong sua, xoa chung tu da hach toan:loi'; return; end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','BT');
if b_loi is not null then return; end if;
for r_lp in (select so_id,ma_nt,tien,tien_qd
    from bh_bt_gd_hs_tt_ps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt) loop
    PBH_BT_GD_HS_THOP(b_ma_dvi,'C',b_ngay_ht,r_lp.so_id,r_lp.ma_nt,-r_lp.tien,-r_lp.tien_qd,b_loi);
    if b_loi is not null then return; end if;
    PBH_BT_GD_HS_KTRA(b_ma_dvi,r_lp.so_id,b_loi);
    if b_loi is not null then return; end if;
end loop;
delete bh_bt_gd_hs_tt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id_tt;
delete bh_bt_gd_hs_tt_ps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
delete bh_bt_gd_hs_tt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BT_GD_HS_TT_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_so_id_tt number; b_ngay_ht number; b_so_ct varchar2(20);
    b_so_hs varchar2(30); b_k_ma_gd varchar2(1); b_ma_gd varchar2(200);
    b_tien number; b_tien_qd number; b_thue number; b_thue_qd number;
    b_nt_tra varchar2(5); b_tygia number; b_tra number; b_tra_qd number;
    a_so_id pht_type.a_num; a_ma_nt pht_type.a_var;
    a_tien pht_type.a_num; a_tien_qd pht_type.a_num;
    dt_ct clob; dt_dk clob;
begin
-- Dan - nhap thanh toan
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id_tt:=nvl(FKH_JS_GTRIn(b_oraIn,'so_id'),0);
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk using b_oraIn;
FKH_JS_NULL(dt_ct);
if b_so_id_tt=0 then
    PHT_ID_MOI(b_so_id_tt,b_loi);
else    
    PBH_BT_GD_HS_TT_XOA_XOA(b_ma_dvi,b_nsd,b_so_id_tt,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_GD_HS_TT_TEST(b_ma_dvi,dt_ct,dt_dk,b_so_id_tt,
    b_ngay_ht,b_so_ct,b_so_hs,b_k_ma_gd,b_ma_gd,b_tien,b_tien_qd,
    b_thue,b_thue_qd,b_nt_tra,b_tygia,b_tra,b_tra_qd,
    a_so_id,a_ma_nt,a_tien,a_tien_qd,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_GD_HS_TT_NH_NH(b_ma_dvi,b_nsd,dt_ct,dt_dk,b_so_id_tt,
    b_ngay_ht,b_so_ct,b_so_hs,b_k_ma_gd,b_ma_gd,b_tien,b_tien_qd,
    b_thue,b_thue_qd,b_nt_tra,b_tygia,b_tra,b_tra_qd,
    a_so_id,a_ma_nt,a_tien,a_tien_qd,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('so_id' value b_so_id_tt,'so_ct' value b_so_ct) into b_oraOut from dual;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_GD_HS_TT_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_so_id_tt number;
begin
-- Nam - Xoa thanh toan
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id_tt:=nvl(FKH_JS_GTRIn(b_oraIn,'so_id'),0);
if b_so_id_tt=0 then b_loi:='loi:Nhap so chung tu thanh toan:loi'; raise PROGRAM_ERROR; end if;
PBH_BT_GD_HS_TT_XOA_XOA(b_ma_dvi,b_nsd,b_so_id_tt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_GD_HS_TT_TIM(
     b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ngayD number; b_ngayC number; 
    b_so_hs varchar2(30); b_k_ma_gd varchar2(1); b_ma_gd varchar2(20);
    b_tu number; b_den number; b_dong number; cs_lke clob;
Begin
-- Dan
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,so_hs,k_ma_gd,ma_gd,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_so_hs,b_k_ma_gd,b_ma_gd,b_tu,b_den using b_oraIn;
b_ngayD:=nvl(b_ngayd,0); b_ngayC:=nvl(b_ngayC,0);
b_so_hs:=nvl(trim(b_so_hs),' '); b_ma_gd:=nvl(trim(b_ma_gd),' ');
b_tu:=nvl(b_tu,0); b_den:=nvl(b_den,0);
if b_ngayC in(0,30000101) then b_ngayC:=PKH_NG_CSO(sysdate); end if;
b_i1:=PKH_NG_CSO(add_months(PKH_SO_CDT(b_ngayC),-36));
if b_ngayD in(0,30000101) or b_ngayD<b_i1 then b_ngayD:=b_i1; end if;
insert into temp_1(n1,n2,n3,c1,c2,c3,c4)
    select so_id_tt,ngay_ht,tra,so_hs,FBH_MA_GDINH_KTEN(b_ma_dvi,k_ma_gd,ma_gd),nt_tra,so_ct
    from bh_bt_gd_hs_tt where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and
    b_so_hs in(' ',b_so_hs) and k_ma_gd=b_k_ma_gd and b_ma_gd in(' ',ma_gd) and rownum<302
    order by ngay_ht desc,so_id_tt;
select count(*) into b_dong from temp_1;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(so_id_tt,ngay_ht,tien,so_hs,ma_gd,ma_nt,so_ct) returning clob) into cs_lke from
    (select n1 so_id_tt,n2 ngay_ht,n3 tien,c1 so_hs,c2 ma_gd,c3 ma_nt,c4 so_ct,rownum sott from temp_1 order by n1 desc,n1)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_BT_GD_HTHANH(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
-- chuclh - Xac dinh da hoan thanh
select nvl(min(ttrang),' ') into b_kq from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_TU_NGAY_XR(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_kq number; b_so_id_bt number;
begin
-- Dan - Tra ngay xay ra
select so_id_hs into b_so_id_bt from bh_bt_tu where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_kq:=FBH_BT_NGAY_XR(b_ma_dvi,b_so_id_bt);
return b_kq;
end;
/