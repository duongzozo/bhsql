create or replace function FBH_BTp_HS_ID(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_kq number;
begin
-- Dan - Tra so_id_bt
select nvl(min(so_id_bt),0) into b_kq from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure PBH_BTp_TEST(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    dt_ct clob,b_oT out json_object_t,b_loi out varchar2)
AS
    b_i1 number; b_so_hs_bt varchar2(20); b_ttrang varchar2(1); b_ngay_qd number;
begin
-- Dan kiem tra thong tin nhap ho so boi thuong
b_loi:='loi:Loi xu ly PBH_BTp_TEST:loi';
b_oT:=json_object_t(dt_ct);
FKH_JSt_NULL(b_oT);
b_so_hs_bt:=b_oT.get_string('so_hs_bt');
if b_so_hs_bt=' ' then b_loi:='loi:Nhap so ho so boi thuong:loi'; return; end if;
select nvl(min(ttrang),' ') into b_ttrang from bh_bt_hs where ma_dvi=b_ma_dvi and so_hs=b_so_hs_bt;
if b_ttrang=' ' then b_loi:='loi:Ho so boi thuong da xoa:loi'; return; end if;
if b_ttrang<>'T' then b_loi:='loi:Ho so boi thuong phai o trang thai trinh:loi'; return; end if;
b_ttrang:=b_oT.get_string('ttrang'); b_ngay_qd:=b_oT.get_number('ngay_qd');
if b_ttrang not in('S','T','D','H','C') then b_loi:='loi:Sai tinh trang:loi'; return; end if;
if b_ttrang<>'D' then
    b_oT.put('n_duyet',' '); b_oT.put('ngay_qd',0);
elsif b_ngay_qd in(0,3000101) or b_oT.get_string('n_duyet')=' ' then
    b_loi:='loi:Nhap ngay duyet, nguoi duyet:loi'; return;
end if;
if b_oT.get_string('so_hs')=' ' then
    b_oT.put('so_hs',substr(to_char(b_so_id),3));
end if;
if b_oT.get_string('nt_tien')=' ' then b_oT.put('nt_tien','VND'); end if;
if b_ttrang not in('T','D') then
    select count(*) into b_i1 from bh_btP_tu where ma_dvi=b_ma_dvi and so_id_hs=b_so_id;
    if b_i1<>0 then
        b_loi:='loi:Ho so da co tam ung phai de tinh trang dang trinh hoac da duyet:loi'; return;
    end if;
end if;
if b_ttrang='D' then
    b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_qd,'BH','BT');
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BTp_TTRANG(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_i2 number; b_i3 number;
    b_tt varchar2(1); b_so_id number; b_ttrang varchar2(1);
begin
-- Dan - Trang thai ho so
delete bh_hd_ttrang_temp; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id'); b_oraOut:='';
select count(*),min(ttrang) into b_i1,b_ttrang from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then return; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_bt_tu where ma_dvi=b_ma_dvi and so_id_pa=b_so_id;
if b_i1<>0 then
    insert into bh_hd_ttrang_temp values('bt_tu','V');
end if;
if b_ttrang='D' then
    select nvl(sum(thu),0),nvl(sum(chi),0) into b_i1,b_i2 from bh_bt_hs_sc where ma_dvi=b_ma_dvi and so_id=b_so_id;
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
select JSON_ARRAYAGG(json_object(nv,tt)) into b_oraOut from bh_hd_ttrang_temp;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BTp_GOC_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    b_ngay_ht number,b_nv varchar2,b_nvP varchar2,b_so_hs varchar2,b_ttrang varchar2,
    b_so_hs_bt varchar2,b_so_id_bt number,b_ten nvarchar2,
    b_n_trinh varchar2,b_n_duyet varchar2,b_ngay_qd number,
    b_nt_tien varchar2,b_tien number,b_thue number,
    a_lh_nv pht_type.a_var,a_tien_bh pht_type.a_num,a_pt_bt pht_type.a_num,a_t_that pht_type.a_num,
    a_tien pht_type.a_num,a_tien_qd pht_type.a_num,a_thue pht_type.a_num,a_thue_qd pht_type.a_num,
    hk_ma pht_type.a_var,hk_ten pht_type.a_nvar,hk_ma_nt pht_type.a_var,
    hk_tien pht_type.a_num,hk_thue pht_type.a_num,hk_tien_qd pht_type.a_num,
    hk_thue_qd pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_dvi_ksoat varchar2(10):=' '; b_ksoat varchar2(10):=' ';
    b_tien_ps number; b_tien_ps_qd number; b_ma_kh varchar2(20):=' '; r_hs bh_bt_hs%rowtype;
begin
PBH_BT_GOC_XOA(b_ma_dvi,b_nsd,b_so_id,true,b_loi);
if b_loi is not null then return; end if;
if b_ttrang='D' then
    b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_qd,'BH','BT');
    if b_loi is not null then b_loi:='loi:Khong xoa lui ngay:loi'; return; end if;
    b_dvi_ksoat:=b_ma_dvi; b_ksoat:=b_nsd;
end if;
b_loi:='loi:Ho so dang xu ly:loi';
select * into r_hs from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id_bt for update nowait;
if sql%rowcount=0 then return; end if;
if b_nvP='V' then b_ma_kh:=r_hs.ma_kh; end if;
b_loi:='loi:Loi Table BH_BT_HS:loi';
insert into bh_bt_hs values(b_ma_dvi,b_so_id,b_ngay_ht,b_nv,b_so_hs,b_ttrang,
    'G',' ',r_hs.ma_dvi_ql,b_ma_dvi,r_hs.so_id_hd,r_hs.so_id_dt,r_hs.so_hd,
    b_so_hs_bt,b_so_id_bt,r_hs.ma_khH,r_hs.tenH,b_ma_kh,b_ten,
    r_hs.phong,' ',r_hs.ngay_gui,r_hs.ngay_xr,0,b_n_trinh,b_n_duyet,b_ngay_qd,b_nt_tien,
    'K',' ','K',b_nvP,b_nsd,-1,b_dvi_ksoat,b_ksoat,' ',sysdate);
b_loi:='loi:Loi Table BH_BT_HS_NV:loi';
forall b_lp in 1..a_lh_nv.count
    insert into bh_bt_hs_nv values(b_ma_dvi,b_so_id,0,' ',
        b_nt_tien,a_lh_nv(b_lp),a_tien_bh(b_lp),a_pt_bt(b_lp),a_t_that(b_lp),
        a_tien(b_lp),a_thue(b_lp),a_tien(b_lp)+a_thue(b_lp),a_tien_qd(b_lp),
        a_thue_qd(b_lp),a_tien_qd(b_lp)+a_thue_qd(b_lp));
if hk_ma_nt.count<>0 then
    b_loi:='loi:Loi Table BH_BT_HK_PS:loi';
    for b_lp in 1..hk_ma_nt.count loop
        insert into bh_bt_hk_ps values(b_ma_dvi,b_so_id,b_lp,hk_ma(b_lp),hk_ten(b_lp),hk_ma_nt(b_lp),
            hk_tien(b_lp),hk_thue(b_lp),hk_tien(b_lp)+hk_thue(b_lp),
            hk_tien_qd(b_lp),hk_thue_qd(b_lp),hk_tien_qd(b_lp)+hk_thue_qd(b_lp));
    end loop;
end if;
b_tien_ps:=FKH_ARR_TONG(a_tien)+FKH_ARR_TONG(a_thue);
b_tien_ps_qd:=FKH_ARR_TONG(a_tien_qd)+FKH_ARR_TONG(a_thue_qd);
b_loi:='loi:Loi Table BH_BT_HS_PS:loi';
-- viet anh -- tru tien khi co nguoi HK
for b_lp in 1..hk_ma.count loop
    b_tien_ps:=b_tien_ps-hk_tien(b_lp);
    b_tien_ps_qd:=b_tien_ps_qd-hk_tien_qd(b_lp);
end loop;
insert into bh_bt_hs_ps values(b_ma_dvi,b_so_id,b_nt_tien,b_tien_ps,b_tien_ps);
if b_ttrang='D' then
    PBH_BT_HS_UP_NH(b_ma_dvi,b_so_id,b_ma_dvi,b_nsd,b_loi);
    if b_loi is not null then return; end if;
end if;
PBH_BT_HS_KTRA(b_ma_dvi,b_so_id,b_loi);
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
