create or replace function FBH_HANGB_SO_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Dan - Tra so bao gia
select min(so_hd) into b_kq from bh_hangB where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_HANGB_SO_ID(b_ma_dvi varchar2,b_so_hd varchar2) return number
as
    b_kq number;
begin
-- Dan - Tra so id
select nvl(min(so_id),0) into b_kq from bh_hangB where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
return b_kq;
end;
/
create or replace procedure PBH_HANGB_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10);
    b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number;
    b_dong number; cs_lke clob;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_hangB where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,lan,nsd) obj,rownum sott from bh_hangB where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' then
        b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
        select count(*) into b_dong from bh_hangB where ma_dvi=b_ma_dvi and
            ngay_ht=b_ngay_ht and phong=b_phong;
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(obj returning clob) into cs_lke from
            (select json_object(ma_dvi,so_id,so_hd,lan,nsd) obj,rownum sott from bh_hangB  where
                ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_hd)
            where sott between b_tu and b_den;
elsif FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','HANG','X')='C' then
    select count(*) into b_dong from bh_hangB where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,lan,nsd) obj,rownum sott from bh_hangB  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANGB_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10); b_so_hd varchar2(20);
    b_so_id number; b_ngay_ht number; b_klk varchar2(1); b_trangKt number; b_tu number; b_den number;
    b_trang number; b_dong number; cs_lke clob;
begin
-- Dan - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_klk,b_trangKt using b_oraIn;
b_so_hd:=FBH_HANGB_SO_HD(b_ma_dvi,b_so_id);
if b_so_hd is null then b_loi:='loi:GCN, bao gia da xoa:loi'; raise PROGRAM_ERROR; end if;
if b_klk ='N' then
    select count(*) into b_dong from bh_hangB where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_hangB where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,lan,nsd) obj,rownum sott from bh_hangB  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_hangB where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_hangB where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,lan,nsd) obj,rownum sott from bh_hangB  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_hd)
        where sott between b_tu and b_den;
elsif FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','HANG','X')='C' then
    select count(*) into b_dong from bh_hangB where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_hangB where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,lan,nsd) obj,rownum sott from bh_hangB  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANGB_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number; b_so_hd varchar2(20):=FKH_JS_GTRIs(b_oraIn,'so_hd');
begin
-- Dan - Hoi so ID qua so bao gia
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FBH_HANGB_SO_ID(b_ma_dvi,b_so_hd);
if b_so_id=0 then b_loi:='loi:So bao gia da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANGB_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh varchar2,b_lan number,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Xoa
b_loi:='loi:Loi xu ly PBH_HANGB_XOA_XOA:loi';
select count(*) into b_i1 from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then b_loi:='loi:Khong sua, xoa bao gia da chuyen sang hop dong:loi'; return; end if;
b_loi:='loi:Loi xoa Table bh_hangB:loi';
if b_lan = 0 then
    delete bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    delete bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan;
end if;
delete bh_hangB_ptvc where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hangB_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hangB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hangB where ma_dvi=b_ma_dvi and so_id=b_so_id;
PBH_BAO_NV_XOA(b_ma_dvi,b_nsd,b_so_id,b_nh,b_loi);
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HANGB_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Dan - Xoa GCN
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','N',b_comm);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_HANGB_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'X',0,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANGB_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number; b_lan number;
    b_ma_noi_di nvarchar2(500);b_ma_noi_den nvarchar2(500);
    dt_ct clob; dt_dk clob; dt_ds clob; dt_pt clob; dt_lt clob:=''; dt_kbt clob:=''; dt_ttt clob:='';
    dt_vch clob:=''; dt_kytt clob:=''; dt_txt clob;dt_hk clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','HANG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
if b_so_id=0 then b_loi:='loi:Chon bao gia:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
select nvl(max(lan),0) into b_lan from bh_hangB where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_lan=0 then b_loi:='loi:Bao gia da xoa:loi'; raise PROGRAM_ERROR; end if;
select FKH_JS_GTRIs(FKH_JS_BONH(txt),'ma_noi_di') into b_ma_noi_di from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ct';
select FKH_JS_GTRIs(FKH_JS_BONH(txt),'ma_noi_den') into b_ma_noi_den from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ct';
select json_object('ma_qtac' value FBH_HANG_QTAC_MA(qtac),'ma_nhang' value FBH_HANG_NHANG_MA(nhang),
    'vchuyen' value FBH_HANG_PT_MA(vchuyen),'cang_di' value FBH_MA_NUOC_TENl(cang_di),'cang_den' value FBH_MA_NUOC_TENl(cang_den),
    'ma_noi_di' value FBH_MA_NOI_TENl(b_ma_noi_di),'ma_noi_den' value FBH_MA_NOI_TENl(b_ma_noi_den)
    returning clob) into dt_ct from bh_hangB where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan;
select txt into dt_dk from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_dk';
select txt into dt_ds from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ds';
select txt into dt_pt from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_pt';
select count(*) into b_i1 from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
if b_i1=1 then
    select txt into dt_hk from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
end if;
select count(*) into b_i1 from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_lt';
if b_i1<>0 then
    select txt into dt_lt from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_lt';
end if;

select count(*) into b_i1 from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_kbt';
if b_i1<>0 then
    select txt into dt_kbt from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_kbt';
end if;
select count(*) into b_i1 from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_ttt';
if b_i1=1 then
    select txt into dt_ttt from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_ttt';
end if;
select count(*) into b_i1 from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_kytt';
if b_i1<>0 then
    select txt into dt_kytt from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_kytt';
end if;
select count(*) into b_i1 from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_vch';
if b_i1<>0 then
    select txt into dt_vch from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_vch';
end if;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai in('dt_ct');
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,
    'dt_ct' value dt_ct,'dt_hk' value dt_hk,'dt_ds' value dt_ds,'dt_dk' value dt_dk,'dt_lt' value dt_lt,
    'dt_kbt' value dt_kbt,'dt_pt' value dt_pt,'dt_kytt' value dt_kytt,'dt_ttt' value dt_ttt,'dt_vch' value dt_vch,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANGB_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_lan out number,
    dt_ct in out clob,dt_hk clob,dt_ds clob,dt_dk clob,dt_kytt clob,dt_lt clob,dt_kbt clob,dt_pt clob,dt_ttt clob,dt_vch clob,
-- Chung
    b_so_hd varchar2, b_ngay_ht number, b_ttrang varchar2,
    b_kieu_hd varchar2, b_so_hd_g varchar2, b_so_id_g number, b_so_id_d number,
    b_kieu_kt varchar2, b_ma_kt varchar2, b_kieu_gt varchar2, b_ma_gt varchar2, b_ma_cb varchar2,
    b_phong varchar2,b_so_hdL varchar2, b_loai_kh varchar2, b_ma_kh varchar2, b_ten nvarchar2, b_dchi nvarchar2,
    b_cmt varchar2, b_mobi varchar2, b_email varchar2, b_gio_hl varchar2, b_ngay_hl number, b_gio_kt varchar2,
    b_ngay_kt number, b_ma_qtac varchar2, b_ma_nhang varchar2, b_hd_kem varchar2, b_c_ctai varchar2,
    b_ma_vchuyen varchar2, b_khoang_cach number, b_thoi_gian number, b_cang_di varchar2,
    b_cang_den varchar2, b_ngay_cap number,b_c_thue varchar2, b_tong_mtn number,b_phi number,b_giam number, b_thue number,
    b_ttoan number, b_nt_tien varchar2, b_nt_phi varchar2, b_hhong number,
    tt_ngay pht_type.a_num,tt_tien pht_type.a_num,
-- Rieng
    ---- Danh sach hang
    ds_ma_lhang pht_type.a_var,ds_ten_hang pht_type.a_var,ds_dvi_tinh pht_type.a_var,ds_ma_dgoi pht_type.a_var,ds_cphi pht_type.a_num,
    ds_sluong pht_type.a_num,ds_gia pht_type.a_num,ds_gia_tri pht_type.a_num,ds_mtn pht_type.a_num,ds_pt pht_type.a_num,
    ds_lh_nv pht_type.a_var,ds_lkeB pht_type.a_var,
    ---- Phuong tien
    ds_ma_ptien pht_type.a_var, ds_ten_ptien pht_type.a_var, ds_so_imo pht_type.a_var, ds_so_vdon pht_type.a_var,
    ---- Dieu khoan
    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tc pht_type.a_var,
    dk_ma_ct pht_type.a_var,dk_kieu pht_type.a_var,dk_tien pht_type.a_num,dk_pt pht_type.a_num,
    dk_phi pht_type.a_num,dk_thue pht_type.a_num,dk_ttoan pht_type.a_num,dk_cap pht_type.a_num,
    dk_ma_dk pht_type.a_var,dk_ma_dkC pht_type.a_var,dk_lh_nv pht_type.a_var,dk_t_suat pht_type.a_num,
    dk_ptB pht_type.a_num,dk_ptG pht_type.a_num,dk_phiG pht_type.a_num,dk_lkeP pht_type.a_var,
    dk_lkeB pht_type.a_var,dk_luy pht_type.a_var,dk_lh_bh pht_type.a_var,b_loi out varchar2)
AS
    b_i1 number; b_ttrang_bg varchar2(1); b_tien number:=0; b_so_id_kt number:=-1; b_nsdC varchar2(20);
begin
-- Dan - Nhap
if b_ttrang='D' then b_so_id_kt:=0; end if;
b_lan:=FKH_JS_GTRIn(dt_ct,'lan');
select count(*) into b_i1 from bh_hangB where so_id=b_so_id;
if b_i1>0 then
  select nsd into b_nsdC from bh_hangB where so_id=b_so_id;
  if b_nsdC<>b_nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
end if;
select nvl(max(lan),0) into b_i1 from bh_hangB where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_lan <> 0 and b_lan < b_i1 then b_loi:='loi:Khong duoc sua bao gia cu:loi'; return; end if;
if b_lan <> b_i1 then
  select nvl(ttrang,' ') into b_ttrang_bg from bh_hangB where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_i1;
  if b_ttrang_bg <> ' ' and b_ttrang_bg <> 'D' then b_loi:='loi:Phai duyet bao gia lan '||b_i1||':loi'; return; end if;
end if;
if b_lan = 0 then b_lan:=b_i1+1; end if;
PKH_JS_THAYn(dt_ct,'lan',b_lan);
PBH_HANGB_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'N',b_lan,b_loi);
if b_loi is not null then return; end if;
for b_lp in 1..ds_ma_lhang.count loop
    insert into bh_hangB_ds values (b_ma_dvi,b_so_id,b_lp,ds_ma_lhang(b_lp),ds_ten_hang(b_lp),ds_dvi_tinh(b_lp),PKH_MA_TENl(ds_ma_dgoi(b_lp)),
           ds_cphi(b_lp),ds_sluong(b_lp),ds_gia(b_lp),ds_gia_tri(b_lp),ds_mtn(b_lp),ds_pt(b_lp),ds_lkeB(b_lp),ds_lh_nv(b_lp));
end loop;
for b_lp in 1..dk_lh_nv.count loop
    if dk_lh_nv(b_lp)<>' ' then
        if dk_kieu(b_lp)='T' then b_tien:=b_tien+dk_tien(b_lp); end if;
        insert into bh_hangB_dk values(b_ma_dvi,b_so_id,dk_ma(b_lp),dk_ten(b_lp),dk_ma_dk(b_lp),dk_lh_nv(b_lp),dk_tien(b_lp),dk_phi(b_lp),dk_ptG(b_lp));
    end if;
end loop;
for b_lp in 1..ds_ma_ptien.count loop
    insert into bh_hangB_ptvc values (b_ma_dvi,b_so_id,b_so_id_d,b_lp,ds_ma_ptien(b_lp),ds_ten_ptien(b_lp),ds_so_imo(b_lp),ds_so_vdon(b_lp));
end loop;
insert into bh_hangB values(
            b_ma_dvi,b_so_id,b_lan,b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,
            b_ma_gt,b_ma_cb,b_phong,b_so_hdL,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,
            b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,b_ma_qtac,b_ma_nhang,b_hd_kem,b_c_ctai,b_ma_vchuyen,
            b_cang_di,b_cang_den,b_khoang_cach,b_thoi_gian,b_tong_mtn,b_tien,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_id_g,
            b_so_id_d,'','',b_so_id_kt,b_nsd,sysdate);
PKH_JS_THAYa(dt_ct,'so_hd,ma_kh',b_so_hd||','||b_ma_kh);
insert into bh_hangB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_ct',dt_ct);
insert into bh_hangB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_dk',dt_dk);
insert into bh_hangB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_pt',dt_pt);
insert into bh_hangB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_ds',dt_ds);
if dt_hk is not null then
    insert into bh_hangB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_hk',dt_hk);
end if;
if trim(dt_lt) is not null then
    insert into bh_hangB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_lt',dt_lt);
end if;
if trim(dt_kbt) is not null then
    insert into bh_hangB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_kbt',dt_kbt);
end if;
if trim(dt_kytt) is not null then
    insert into bh_hangB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_kytt',dt_kytt);
end if;
if trim(dt_ttt) is not null then
    insert into bh_hangB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_ttt',dt_ttt);
end if;
if trim(dt_vch) is not null then
    insert into bh_hangB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_vch',dt_vch);
end if;
delete from bh_hangB_ls where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan;
insert into bh_hangB_ls (ma_dvi,so_id,lan,loai,txt) select ma_dvi,so_id,lan,loai,txt from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id  and lan=b_lan;
PBH_BAO_NV_NH(b_ma_dvi,b_nsd,b_so_id,b_so_hd,'HANG',b_ttrang,b_phong,b_ma_kh,b_ten,
    b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_tien,b_nt_phi,b_phi,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HANGB_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(3000); b_lenh varchar2(2000); b_i1 number; b_lan number;
    dt_ct clob; dt_ds clob; dt_pt clob; dt_dk clob; dt_lt clob; dt_kbt clob; dt_kytt clob; dt_ttt clob; dt_vch clob;dt_hk clob;
    -- Chung
    b_so_id number; b_so_hd varchar2(20); b_ngay_ht number; b_ttrang varchar2(1); b_kieu_hd varchar2(1); b_so_hd_g varchar2(20);
    b_kieu_kt varchar2(1); b_ma_kt varchar2(20); b_kieu_gt varchar2(1); b_ma_gt varchar2(20); b_ma_cb varchar2(20);
    b_so_hdL varchar2(1); b_loai_kh varchar2(1); b_ma_kh varchar2(20); b_ten nvarchar2(500); b_dchi nvarchar2(500);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_gio_hl varchar2(20); b_ngay_hl number; b_gio_kt varchar2(20); b_ngay_kt number; b_ngay_cap number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_c_thue varchar2(1);
    b_phi number; b_giam number; b_thue number; b_ttoan number; b_hhong number;
    b_so_idG number; b_so_idD number; b_ngayD number; b_phong varchar2(10);
    tt_ngay pht_type.a_num; tt_tien pht_type.a_num;
    -- Rieng
    b_so_idP number;
    b_ma_qtac varchar2(500); b_ma_nhang varchar2(500); b_hd_kem varchar2(1); b_c_ctai varchar2(1); b_ma_vchuyen varchar2(500);
    b_khoang_cach number; b_thoi_gian number; b_gdinh varchar2(500); b_cang_di varchar2(500); b_cang_den varchar2(500); b_noi_di varchar2(500);
    b_noi_den varchar2(500); b_ma_dkgh varchar2(500); b_ma_pptinh varchar2(500); b_tong_mtn number; b_tp number; b_pphi number;
    b_cmtH varchar2(20); b_mobiH varchar2(20); b_emailH varchar2(100); b_loai_khH varchar2(1); b_tenH nvarchar2(400); b_dchiH nvarchar2(1000);
    b_ch varchar2(1):='K';
    -- danh sach hang hoa
    ds_ma_lhang pht_type.a_var; ds_ten_hang pht_type.a_var; ds_dvi_tinh pht_type.a_var;
    ds_ma_dgoi pht_type.a_var; ds_cphi pht_type.a_num; ds_sluong pht_type.a_num; ds_gia pht_type.a_num;
    ds_gia_tri pht_type.a_num; ds_mtn pht_type.a_num; ds_pt pht_type.a_num;
    ds_lh_nv pht_type.a_var;ds_lkeB pht_type.a_var;
    -- thong tin phuong tien
    ds_ma_ptien pht_type.a_var; ds_ten_ptien pht_type.a_var; ds_so_imo pht_type.a_var; ds_so_vdon pht_type.a_var;
    ---- dieu khoan
    dk_ma pht_type.a_var; dk_ma_hang pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var;
    dk_ma_ct pht_type.a_var; dk_kieu pht_type.a_var; dk_tien pht_type.a_num;
    dk_pt pht_type.a_num; dk_phi pht_type.a_num; dk_thue pht_type.a_num; dk_ttoan pht_type.a_num;
    dk_cap pht_type.a_num; dk_ma_dk pht_type.a_var; dk_ma_dkC pht_type.a_var; dk_lh_nv pht_type.a_var;
    dk_t_suat pht_type.a_num; dk_ptB pht_type.a_num; dk_ptG pht_type.a_num; dk_phiG pht_type.a_num;
    dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var; dk_luy pht_type.a_var; dk_lh_bh pht_type.a_var;
    dk_ptK pht_type.a_var;dk_pp pht_type.a_var;dk_phiB pht_type.a_num;
    -- Xu ly
    b_ngay_htC number;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_hk,dt_ds,dt_pt,dt_dk,dt_lt,dt_kbt,dt_kytt,dt_ttt,dt_vch');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_hk,dt_ds,dt_pt,dt_dk,dt_lt,dt_kbt,dt_kytt,dt_ttt,dt_vch using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_hk); FKH_JSa_NULL(dt_ds); FKH_JSa_NULL(dt_pt); FKH_JSa_NULL(dt_dk);
FKH_JSa_NULL(dt_lt); FKH_JSa_NULL(dt_kbt); FKH_JSa_NULL(dt_kytt); FKH_JSa_NULL(dt_ttt); FKH_JSa_NULL(dt_vch);      
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BG_JS_TEST(
    b_ma_dvi,b_nsd,b_so_id,'bh_hang',dt_ct,dt_kytt,
    b_so_hd,b_ngay_ht,b_ttrang,
    b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_loai_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,
    b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_phong,b_ma_kh,
    tt_ngay,tt_tien,b_loi,'HANG');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay_hl in(0,30000101) then b_ngay_hl:=b_ngay_cap; end if;
if b_ngay_kt in(0,30000101) then b_ngay_kt:=PKH_NG_CSO(add_months(PKH_SO_CDT(b_ngay_hl),12)); end if;
if(b_kieu_hd = 'U') then
    PBH_HANGH_NH_U(
      b_ma_dvi,b_nsd,b_so_id,dt_ct,
      b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
      b_so_hdL,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
      b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,
      b_so_idG,b_so_idD,b_ngayD,b_phong,b_hhong,tt_ngay,tt_tien,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
else
    PBH_HANGH_TESTr(
      b_ma_dvi,b_nsd,
      dt_ct,dt_ds,dt_dk,dt_pt,b_so_idP,b_so_idG,b_so_idD,b_so_hd,
      b_ma_qtac,b_ma_nhang,b_hd_kem,b_c_ctai,b_ma_vchuyen,b_ngay_hl,b_ngay_kt,b_ngay_cap,
      b_khoang_cach,b_thoi_gian,b_gdinh,b_cang_di,b_cang_den,b_noi_di,
      b_noi_den,b_ma_dkgh,b_ma_pptinh,b_tong_mtn,b_tp,b_pphi,
      b_cmtH,b_mobiH,b_emailH,b_loai_khH,b_tenH,b_dchiH,b_ch,
      -- thong tin thanh toan
      tt_ngay,tt_tien,
      -- danh sach hang
      ds_ma_lhang,ds_ten_hang,ds_dvi_tinh,ds_ma_dgoi,ds_cphi,ds_sluong,ds_gia,ds_gia_tri,ds_mtn,ds_pt,
      ds_lh_nv,ds_lkeB,
      -- thong tin phuong tien
      ds_ma_ptien, ds_ten_ptien, ds_so_imo, ds_so_vdon,
      -- dieu khoan bao hiem
      dk_ma,dk_ma_hang,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,dk_cap,dk_ma_dk,dk_ma_dkC,
      dk_lh_nv,dk_t_suat,dk_ptB,dk_ptG,dk_phiG,dk_lkeP,dk_lkeB,dk_luy,dk_lh_bh,dk_ptK,dk_pp,dk_phiB,b_loi);
   if b_loi is not null then raise PROGRAM_ERROR; end if;
   PBH_HANGB_NH_NH(
      b_ma_dvi,b_nsd,b_so_id,b_lan,
      dt_ct,dt_hk,dt_ds,dt_dk,dt_kytt,dt_lt,dt_kbt,dt_pt,dt_ttt,dt_vch,
      b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_so_idG,b_so_idD,
      b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,b_phong,b_so_hdL,b_loai_kh,b_ma_kh,
      b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,
      b_ma_qtac,b_ma_nhang,b_hd_kem,b_c_ctai,b_ma_vchuyen,b_khoang_cach,b_thoi_gian,b_cang_di,
      b_cang_den,b_ngay_cap,b_c_thue,b_tong_mtn,b_phi,b_giam,b_thue,b_ttoan,b_nt_tien,b_nt_phi,b_hhong,
      tt_ngay,tt_tien,
      -- danh sach hang
      ds_ma_lhang,ds_ten_hang,ds_dvi_tinh,ds_ma_dgoi,ds_cphi,ds_sluong,ds_gia,ds_gia_tri,ds_mtn,ds_pt,
      ds_lh_nv,ds_lkeB,
      -- thong tin phuong tien
      ds_ma_ptien, ds_ten_ptien, ds_so_imo, ds_so_vdon,
      -- dieu khoan bao hiem
      dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,dk_cap,dk_ma_dk,dk_ma_dkC,
      dk_lh_nv,dk_t_suat,dk_ptB,dk_ptG,dk_phiG,dk_lkeP,dk_lkeB,dk_luy,dk_lh_bh,b_loi);
   if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
FBH_BAO_TTRANGn(b_ma_dvi,b_so_id,b_ttrang,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hd' value b_so_hd, 'ma_kh' value b_ma_kh,'lan' value b_lan,'ch' value b_ch) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANGB_HDBS(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_ma_dvi varchar2(10); b_so_id number;
    b_dong number; cs_lke clob:='';
begin
-- Dan - Liet ke sua doi bo sung
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','HANG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
if b_so_id<>0 then
    select JSON_ARRAYAGG(json_object( ma_dvi,so_id,lan,'ngay_ht' value FKH_JS_GTRIn(txt,'ngay_ht') , 'ttoan' value FKH_JS_GTRIn(txt,'ttoan'),
                                'so_hd' value FKH_JS_GTRIs(txt,'so_hd') ,'ttrang' value FKH_JS_GTRIs(txt,'ttrang') ) order by lan returning clob) into cs_lke
                              from bh_hangB_ls where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANGB_CTbg(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number; b_lan number;
    dt_ct clob; dt_dk clob; dt_ds clob; dt_pt clob; dt_lt clob:=''; dt_kbt clob:=''; dt_ttt clob:=''; dt_vch clob:=''; dt_kytt clob:=''; dt_txt clob;
    dt_hk clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','HANG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id,lan');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id,b_lan using b_oraIn;
select count(1) into b_i1 from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ct';
if b_i1 > 0 then
  select json_object('ma_qtac' value FBH_HANG_QTAC_MA(qtac),'ma_nhang' value FBH_HANG_NHANG_MA(nhang),
    'vchuyen' value FBH_HANG_PT_MA(vchuyen) returning clob) into dt_ct from bh_hangB where ma_dvi=b_ma_dvi and so_id=b_so_id;
  select txt into dt_dk from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_dk';
  select txt into dt_ds from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ds';
  select txt into dt_pt from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_pt';
  select count(*) into b_i1 from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
  if b_i1=1 then
      select txt into dt_hk from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
  end if;
  select count(*) into b_i1 from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_lt';
  if b_i1<>0 then
      select txt into dt_lt from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_lt';
  end if;
  select count(*) into b_i1 from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_kbt';
  if b_i1<>0 then
      select txt into dt_kbt from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_kbt';
  end if;
  select count(*) into b_i1 from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_ttt';
  if b_i1=1 then
      select txt into dt_ttt from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_ttt';
  end if;
  select count(*) into b_i1 from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_kytt';
  if b_i1<>0 then
      select txt into dt_kytt from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_kytt';
  end if;
  select count(*) into b_i1 from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_vch';
  if b_i1<>0 then
      select txt into dt_vch from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_vch';
  end if;
  select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt from bh_hangB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai in('dt_ct');
end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,
    'dt_ct' value dt_ct,'dt_hk' value dt_hk,'dt_ds' value dt_ds,'dt_dk' value dt_dk,'dt_lt' value dt_lt,
    'dt_kbt' value dt_kbt,'dt_pt' value dt_pt,'dt_kytt' value dt_kytt,'dt_ttt' value dt_ttt,'dt_vch' value dt_vch,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANGB_CHUYEN_HD(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_ma_dvi varchar2(10); b_so_id number; b_lan number;
    b_i1 number; b_ttrang varchar2(1);
begin
-- Dan - Liet ke sua doi bo sung
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','HANG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id,lan');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id,b_lan using b_oraIn;
if b_so_id<>0 and b_lan>0 then
    select so_id,max(lan),ttrang into b_so_id,b_i1,b_ttrang from bh_hangB where ma_dvi=b_ma_dvi and so_id=b_so_id group by so_id,ttrang;
    if b_lan < b_i1 then b_loi:='loi:Bao gia cu khong duoc tao hop dong:loi'; raise PROGRAM_ERROR; end if; 
    if b_ttrang <> 'D'  then b_loi:='loi:Bao gia chua duoc duyet:loi'; raise PROGRAM_ERROR; end if;
end if;
select json_object('lan' value b_lan) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_MA_NOI_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Duc
select min(ma||'|'||ten) into b_kq from bh_hang_cang where ma=b_ma;
return b_kq;
end;