create or replace function FBH_BT_XEp_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return varchar2
AS
    b_kq varchar2(100):=' '; b_i1 number; b_txt clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
select count(*) into b_i1 from bh_bt_xeP_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_bt_xeP_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    b_kq:=FKH_JS_GTRIs(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_BT_XEp_TTRANG(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra tinh trang
select nvl(min(ttrang),'X') into b_kq from bh_bt_xeP where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_XEp_NV(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra nghiep vu
select nvl(min(nv),' ') into b_kq from bh_bt_xeP where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_XEp_SO_HS(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(30);
begin
-- Dan - Tra so_id
select min(so_hs) into b_kq from bh_bt_xeP where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure FBH_BT_XEp_SO_ID(b_so_hs varchar2,b_ma_dvi out varchar2,b_so_id out number)
AS
begin
-- Dan - Tra ma_dvi, so_id
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_bt_xeP where so_hs=b_so_hs;
end;
/
create or replace procedure PBH_BT_XEp_SO_ID(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_hs varchar2(30):=FKH_JS_GTRIs(b_oraIn,'so_hs');
    b_ma_dvi varchar2(10); b_so_id number;
begin
-- Dan - Tra ma_dvi,so_id
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FBH_BT_XEp_SO_ID(b_so_hs,b_ma_dvi,b_so_id);
if b_so_id=0 then b_loi:='loi:Phuong an da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_XEp_GCN(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(4000); b_lenh varchar2(2000);
    b_i1 number; b_i2 number; b_i3 number; b_kt number; b_ma_ct varchar2(20);
    b_so_hs_bt varchar2(20); b_nv varchar2(1); b_ma varchar2(10); b_nv_bh varchar2(5);
    b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_id_dt number;
    dt_btlke clob; dt_dk clob; dt_txt clob;
    a_t json_array_t; b_t json_object_t;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hs_bt,nv');
EXECUTE IMMEDIATE b_lenh into b_so_hs_bt,b_nv using b_oraIn;
b_so_hs_bt:=nvl(trim(b_so_hs_bt),' ');
b_loi:='loi:Ho so boi thuong da xoa:loi';
select ma_dvi_ql,so_id_hd,so_id_dt into b_ma_dvi_hd,b_so_id_hd,b_so_id_dt
     from bh_bt_xe where ma_dvi=b_ma_dvi and so_hs=b_so_hs_bt;
select dk into dt_dk from bh_xe_kbt where ma_dvi=b_ma_dvi_hd and so_id=b_so_id_hd and so_id_dt=b_so_id_dt;
dt_dk:=FKH_JS_BONH(dt_dk);
if b_nv='T' then b_nv:='V'; end if;
a_t:=json_array_t(dt_dk); b_kt:=a_t.get_size()-1;
for b_lp in reverse 0..b_kt loop
    b_t:=treat(a_t.get(b_lp) as json_object_t);
    b_ma:=b_t.get_string('ma');
    if FBH_XE_BPHI_DK_BTH(b_ma,'V')='C' then
        a_t.remove(b_lp);
    else
        b_ma:=nvl(trim(b_t.get_string('lh_nv')),' ');
        if b_ma=' ' then b_nv_bh:=' ';
        else
            b_nv_bh:=FBH_MA_LHNV_LOAI(b_ma);
            if instr(b_nv_bh,b_nv)>0 then b_nv_bh:=b_nv; else b_nv_bh:=' '; end if;
        end if;
        b_i1:=nvl(b_t.get_number('tien'),0);
        b_t.put('tien_bh',b_i1); b_t.put('tien',0);
        b_t.put('nv_bh',b_nv_bh); a_t.put(b_lp,b_t, OVERWRITE => TRUE);
    end if;
end loop;
b_kt:=a_t.get_size()-1;
for b_lp in reverse 0..b_kt loop
    b_t:=treat(a_t.get(b_lp) as json_object_t);
    b_nv_bh:=b_t.get_string('nv_bh');
    if b_nv_bh=' ' then continue; end if;
    b_ma_ct:=nvl(trim(b_t.get_string('ma_ct')),' ');
    if b_lp>0 and b_ma_ct<>' ' then
        b_i1:=b_lp-1;
        for b_lp1 in reverse 0..b_i1 loop
            b_t:=treat(a_t.get(b_lp1) as json_object_t);
            if b_t.get_string('ma')=b_ma_ct then
                b_t.put('nv_bh',b_nv); a_t.put(b_lp1,b_t,OVERWRITE=>TRUE);
                b_i2:=b_lp1+1;
                for b_lp2 in b_i2..b_kt loop
                    if b_lp2=b_lp then continue; end if;
                    b_t:=treat(a_t.get(b_lp2) as json_object_t);
                    b_ma:=nvl(trim(b_t.get_string('ma_ct')),' ');
                    if b_ma<>b_ma_ct then exit; end if;
                    b_t.put('nv_bh',b_nv); a_t.put(b_lp2,b_t,OVERWRITE=>TRUE);
                end loop;
                exit;
            end if;
        end loop;
    end if;
    b_i2:=nvl(b_t.get_number('cap'),-1); b_ma:=nvl(trim(b_t.get_string('lh_nv')),' ');
    if b_i2<>-1 and b_ma<>' ' then
        b_i1:=b_lp+1; b_i2:=b_i2+1;
        for b_lp1 in b_i1..b_kt loop
            b_t:=treat(a_t.get(b_lp1) as json_object_t);
            if nvl(b_t.get_number('cap'),-1)<b_i2 then exit;
            else
                b_t.put('nv_bh',b_nv); a_t.put(b_lp1,b_t,OVERWRITE=>TRUE);
            end if;
        end loop;
    end if;
end loop;
for b_lp in reverse 0..b_kt loop
    b_t:=treat(a_t.get(b_lp) as json_object_t); 
    b_nv_bh:=nvl(trim(b_t.get_string('nv_bh')),' ');
    if b_nv_bh=' ' then a_t.remove(b_lp); end if;
end loop;
if a_t.get_size()=0 then dt_dk:=''; else dt_dk:=a_t.to_string(); end if;
dt_btlke:=FBH_BT_XE_BTH_LKE(b_so_id_dt);
select json_object('dt_btlke' value dt_btlke,'dt_dk' value dt_dk returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_XEp_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_so_hs_bt varchar2(20); b_nv varchar2(1);
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hs_bt,nv');
EXECUTE IMMEDIATE b_lenh into b_so_hs_bt,b_nv using b_oraIn;
select JSON_ARRAYAGG(json_object(so_id,so_hs) order by so_id desc returning clob) into b_oraOut
    from bh_bt_xeP where ma_dvi=b_ma_dvi and so_hs_bt=b_so_hs_bt and nv=b_nv;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
CREATE OR REPLACE PROCEDURE PBH_BT_XEp_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(3000); b_so_id number;
    dt_ct clob; dt_dk clob; dt_hk clob:='';dt_txt clob;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id'); 
b_loi:='loi:Phuong an da xoa:loi';
select json_object(so_hs) into dt_ct from bh_bt_xeP where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ma) order by bt) into dt_dk from bh_bt_xe_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ma,ten,ma_nt,tien,thue) order by bt) into dt_hk
    from bh_bt_xe_hk where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select json_object('so_id' value b_so_id,
    'dt_ct' value dt_ct,'dt_dk' value dt_dk,'dt_hk' value dt_hk,
    'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_XEp_TESTr(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,dt_ct in out clob,dt_dk clob,dt_hk clob,
    b_so_hs out varchar2,b_ttrang out varchar2,
    b_nv out varchar2,b_so_hs_bt out varchar2,b_so_id_bt out number,b_ten out nvarchar2,
    b_n_trinh out varchar2,b_n_duyet out varchar2,b_ngay_qd out number,b_ngay_do out number,
    b_c_thue out varchar2,b_nt_tien out varchar2,b_tien out number,b_thue out number,

    dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,
    dk_tc out pht_type.a_var,dk_ma_ct out pht_type.a_var,
    dk_tien_bh out pht_type.a_num,dk_pt_bt out pht_type.a_num,dk_t_that out pht_type.a_num,
    dk_tien out pht_type.a_num,dk_thue out pht_type.a_num,
    dk_tien_qd out pht_type.a_num,dk_thue_qd out pht_type.a_num,
    dk_cap out pht_type.a_var,dk_ma_dk out pht_type.a_var,dk_ma_bs out pht_type.a_var,
    dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,
    dk_nd out pht_type.a_nvar,dk_lkeB out pht_type.a_var,
    hk_nhom out pht_type.a_var,hk_ma out pht_type.a_var,
    hk_ten out pht_type.a_nvar,hk_ma_nt out pht_type.a_var,
    hk_tien out pht_type.a_num,hk_thue out pht_type.a_num,
    hk_tien_qd out pht_type.a_num,hk_thue_qd out pht_type.a_num,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_i2 number; b_tp number:=0;
    b_tienH number; b_thueH number; b_tienHK number; b_tg number:=1;
    dk_bt_con pht_type.a_num;
    b_oT json_object_t;
begin
-- Dan kiem tra thong tin nhap Phuong an boi thuong
PBH_BTp_TEST(b_ma_dvi,b_nsd,b_so_id,dt_ct,b_oT,b_loi);
if b_loi is not null then return; end if;
b_loi:='loi:Loi xu ly PBH_BT_XEp_TESTr:loi';
b_so_hs:=b_oT.get_string('so_hs'); b_ttrang:=b_oT.get_string('ttrang');
b_nv:=b_oT.get_string('nv'); b_so_hs_bt:=b_oT.get_string('so_hs_bt');
b_n_trinh:=b_oT.get_string('n_trinh'); b_n_duyet:=b_oT.get_string('n_duyet');
b_ten:=b_oT.get_string('ten'); b_nt_tien:=b_oT.get_string('nt_tien');
b_ngay_qd:=b_oT.get_number('ngay_qd'); b_ngay_do:=b_oT.get_number('ngay_do'); b_c_thue:='K';
b_tienH:=b_oT.get_number('tien'); b_thueH:=b_oT.get_number('thue');
b_so_id_bt:=PBH_BT_HS_SOID(b_ma_dvi,b_so_hs_bt);
if b_so_id_bt=0 then b_loi:='loi:Ho so boi thuong da xoa:loi'; return; end if;
if b_nv not in('N','T') then b_loi:='loi:Sai nghiep vu:loi'; return; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,tien_bh,pt_bt,t_that,tien,cap,ma_dk,ma_bs,lh_nv,t_suat,nd,lkeb,bt_con');
EXECUTE IMMEDIATE b_lenh bulk collect into
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_tien_bh,dk_pt_bt,dk_t_that,dk_tien,
    dk_cap,dk_ma_dk,dk_ma_bs,dk_lh_nv,dk_t_suat,dk_nd,dk_lkeB,dk_bt_con using dt_dk;
if dk_ma.count=0 then b_loi:='loi:Nhap dieu khoan:loi'; return; end if;
if b_nt_tien<>'VND' then
    b_tp:=2; b_tg:=FBH_TT_TRA_TGTT(b_ngay_qd,b_nt_tien);
end if;
b_tien:=0; b_thue:=0;
for b_lp in 1..dk_ma.count loop
    dk_t_suat(b_lp):=nvl(dk_t_suat(b_lp),0);
    if b_c_thue <>'C' then dk_thue(b_lp):=0;
    else dk_thue(b_lp):= round(dk_tien(b_lp)*dk_t_suat(b_lp)/100, b_tp);
    end if;
    if trim(dk_lh_nv(b_lp)) is not null then
        b_tien:=b_tien+dk_tien(b_lp); b_thue:=b_thue+dk_thue(b_lp);
    end if;
    if b_nt_tien='VND' then
        dk_tien_qd(b_lp):=dk_tien(b_lp); dk_thue_qd(b_lp):=dk_thue(b_lp);
    else
        dk_tien_qd(b_lp):=round(b_tg*dk_tien(b_lp),0); dk_thue_qd(b_lp):=round(b_tg*dk_thue(b_lp),0);
    end if;
end loop;
if b_tienH<>b_tien or b_thueH<>b_thue then
    b_loi:='loi:Chenh tong tien,thue chi tiet va Phuong an:loi'; return;
end if;
b_tienHK:=0;
if trim(dt_hk) is null then
    PKH_MANG_KD(hk_ma_nt);
else
    b_lenh:=FKH_JS_LENH('nhom,ma,ten,ma_nt,tien,thue');
    EXECUTE IMMEDIATE b_lenh bulk collect into hk_nhom,hk_ma,hk_ten,hk_ma_nt,hk_tien,hk_thue using dt_hk;
    b_i1:=0;
    for b_lp in 1..hk_ma_nt.count loop
        hk_ma_nt(b_lp):=b_nt_tien;
        if b_nt_tien='VND' then
            hk_tien_qd(b_lp):=hk_tien(b_lp); hk_thue_qd(b_lp):=hk_thue(b_lp);
        else
            hk_tien_qd(b_lp):=round(hk_tien(b_lp)*b_tg,0); hk_thue_qd(b_lp):=round(hk_thue(b_lp)*b_tg,0);
        end if;
        b_tienHK:=b_tienHK+hk_tien(b_lp);
        if trim(hk_ma(b_lp)) is not null then
            b_i2:=PKH_LOC_CHU_SO(hk_ma(b_lp),'F','F');
            if b_i2<100000 and b_i2>b_i1 then b_i1:=b_i2; end if;
        else
            b_i1:=b_i1+1; hk_ma(b_lp):=to_char(b_i1);
        end if;
    end loop;
    if b_tien<b_tienHK then b_loi:='loi:Tien Phuong an nho hon tien huong khac:loi'; return; end if;
end if;
dt_ct:=b_oT.to_string();
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
create or replace procedure PBH_BT_XEp_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh boolean,b_loi out varchar2)
AS 
    b_i1 number; b_nsdC varchar2(20); b_so_id_bt number; b_ksoat varchar2(20);
    r_hs bh_bt_xeP%rowtype;
Begin
-- Dan - Xoa boi thuong
select count(*) into b_i1 from bh_bt_xeP where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select * into r_hs from bh_bt_xeP where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sql%rowcount=0 then b_loi:='loi:Phuong an dang xu ly:loi'; return; end if;
if nvl(trim(r_hs.nsd),' ') not in(' ',b_nsd) then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
if instr('D,H,C',FBH_BT_XE_TTRANG(b_ma_dvi,r_hs.so_id_bt))>0 then
    b_loi:='loi:Khong sua, xoa phuong an theo ho so boi thuong da duyet:loi'; return;
end if;
if r_hs.ttrang='D' then
    select count(*) into b_i1 from bh_bt_tt_ps where ma_dvi=b_ma_dvi and so_id_pa=b_so_id;
    if b_i1<>0 then b_loi:='loi:Phuong an da thanh toan:loi'; return; end if;
end if;
PBH_BT_GOC_XOA(b_ma_dvi,b_nsd,b_so_id,b_nh,b_loi);
if b_loi is not null then return; end if;
delete bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_xe_hk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_xe_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_xeP where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_XEp_XOA_XOA:loi'; end if;
end;
/
create or replace procedure PBH_BT_XEp_PT(
    b_ma_dvi varchar2,b_so_id number,b_ngay_ht number,
    b_ma_nt varchar2,b_tien number,b_tien_qd number,b_thue number,b_thue_qd number,
    a_lh_nv out pht_type.a_var,a_tien out pht_type.a_num,
    a_tien_qd out pht_type.a_num,a_thue out pht_type.a_num,a_thue_qd out pht_type.a_num,b_loi out varchar2)
AS
    b_tl number; b_tp number:=0; b_tien_t number;
    b_tien_c number; b_tien_c_qd number; b_thue_c number; b_thue_c_qd number; a_tl pht_type.a_num;
Begin
-- Dan - Phan tich theo ho so boi thuong
select lh_nv,sum(decode(tien,0,t_that,tien)) bulk collect into a_lh_nv,a_tl from bh_bt_xe_dk 
    where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' and (tien<>0 or t_that<>0) group by lh_nv;
if a_lh_nv.count=0 then b_loi:=''; return; end if;
b_tien_t:=FKH_ARR_TONG(a_tl);
if b_ma_nt<>'VND' then b_tp:=2; end if;
b_tien_c:=b_tien; b_tien_c_qd:=b_tien_qd; b_thue_c:=b_thue; b_thue_c_qd:=b_thue_qd;
for b_lp in 1..a_lh_nv.count loop
    if b_lp=a_lh_nv.count then
        a_tien(b_lp):=b_tien_c; a_tien_qd(b_lp):=b_tien_c_qd;
        a_thue(b_lp):=b_thue_c; a_thue_qd(b_lp):=b_thue_c_qd;
    else
        b_tl:=a_tl(b_lp)/b_tien_t;
        a_tien(b_lp):=round(b_tien*b_tl,b_tp); a_tien_qd(b_lp):=round(b_tien_qd*b_tl,0);
        a_thue(b_lp):=round(b_thue*b_tl,b_tp); a_thue_qd(b_lp):=round(b_thue_qd*b_tl,0);
        b_tien_c:=b_tien_c-a_tien(b_lp); b_tien_c_qd:=b_tien_c_qd-a_tien_qd(b_lp);
        b_thue_c:=b_thue_c-a_thue(b_lp); b_thue_c_qd:=b_thue_c_qd-a_thue_qd(b_lp);
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_XEp_PT:loi'; end if;
end;
/
create or replace procedure PBH_BT_XEp_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    dt_ct clob,dt_dk clob,dt_hk clob,
    b_so_hs varchar2,b_ttrang varchar2,b_nv varchar2,b_so_hs_bt varchar2,b_so_id_bt number,
    b_ten nvarchar2,b_n_trinh varchar2,b_n_duyet varchar2,b_ngay_qd number,b_ngay_do number,
    b_c_thue varchar2,b_nt_tien varchar2,b_tien number,b_thue number,
    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tc pht_type.a_var,dk_ma_ct pht_type.a_var,
    dk_tien_bh pht_type.a_num,dk_pt_bt pht_type.a_num,dk_t_that pht_type.a_num,
    dk_tien pht_type.a_num,dk_thue pht_type.a_num,dk_tien_qd pht_type.a_num,dk_thue_qd pht_type.a_num,
    dk_cap pht_type.a_var,dk_ma_dk pht_type.a_var,dk_ma_bs pht_type.a_var,
    dk_lh_nv pht_type.a_var,dk_t_suat pht_type.a_num,dk_nd pht_type.a_nvar,dk_lkeB pht_type.a_var,
    hk_nhom pht_type.a_var,hk_ma pht_type.a_var,hk_ten pht_type.a_nvar,hk_ma_nt pht_type.a_var,
    hk_tien pht_type.a_num,hk_thue pht_type.a_num,
    hk_tien_qd pht_type.a_num,hk_thue_qd pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_dvi_ksoat varchar2(10):=' '; b_ksoat varchar2(10):=' ';
    a_lh_nvC pht_type.a_var; a_tien_bhC pht_type.a_num; a_pt_btC pht_type.a_num; a_t_thatC pht_type.a_num; 
    a_tienC pht_type.a_num; a_tien_qdC pht_type.a_num; a_thueC pht_type.a_num; a_thue_qdC pht_type.a_num;
begin
-- Dan - Nhap uong an boi thuong
if b_ngay_qd<30000101 then b_dvi_ksoat:=b_ma_dvi; b_ksoat:=b_nsd; end if;
insert into bh_bt_xeP values(b_ma_dvi,b_so_id,b_so_hs,b_ttrang,b_nv,
    b_so_hs_bt,b_so_id_bt,b_ten,b_n_trinh,b_n_duyet,b_ngay_qd,b_ngay_do,
    b_c_thue,b_nt_tien,b_tien,b_thue,b_nsd,b_dvi_ksoat,b_ksoat,sysdate);
for b_lp in 1..dk_ma.count loop
    insert into bh_bt_xe_dk values(b_ma_dvi,b_so_id,b_lp,
        dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),dk_cap(b_lp),
        dk_ma_dk(b_lp),dk_ma_bs(b_lp),dk_lh_nv(b_lp),dk_t_suat(b_lp),
        dk_tien(b_lp),dk_pt_bt(b_lp),dk_t_that(b_lp),dk_tien(b_lp),dk_thue(b_lp),
        dk_tien(b_lp)+dk_thue(b_lp),dk_tien_qd(b_lp),dk_thue_qd(b_lp),
        dk_tien_qd(b_lp)+dk_thue_qd(b_lp),dk_nd(b_lp),dk_lkeB(b_lp));
end loop;
if hk_ma_nt.count<>0 then
    for b_lp in 1..hk_ma_nt.count loop
        insert into bh_bt_xe_hk values(
            b_ma_dvi,b_so_id,b_lp,hk_nhom(b_lp),hk_ma(b_lp),hk_ten(b_lp),
            hk_ma_nt(b_lp),hk_tien(b_lp),hk_thue(b_lp),hk_tien(b_lp)+hk_thue(b_lp),
            hk_tien_qd(b_lp),hk_thue_qd(b_lp),hk_tien_qd(b_lp)+hk_thue_qd(b_lp));
    end loop;
    insert into bh_bt_xe_txt values(b_ma_dvi,b_so_id,'dt_hk',dt_hk);
end if;
insert into bh_bt_xe_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
if trim(dt_dk) is not null then
    insert into bh_bt_xe_txt values(b_ma_dvi,b_so_id,'dt_dk',dt_dk);
end if;
if b_ttrang in('T','D') then
    select lh_nv,tien_bh,pt_bt,t_that,tien,tien_qd,thue,thue_qd bulk collect into 
        a_lh_nvC,a_tien_bhC,a_pt_btC,a_t_thatC,a_tienC,a_tien_qdC,a_thueC,a_thue_qdC from 
        (select lh_nv,sum(tien_bh) tien_bh,max(pt_bt) pt_bt,sum(t_that) t_that,
        sum(tien) tien,sum(tien_qd) tien_qd,sum(thue) thue,sum(thue_qd) thue_qd
        from bh_bt_xe_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv);
    b_i1:=PKH_NG_CSO(sysdate);
    PBH_BTp_GOC_NH(b_ma_dvi,b_nsd,b_so_id,b_i1,'XE',b_nv,
        b_so_hs,b_ttrang,b_so_hs_bt,b_so_id_bt,b_ten,b_n_trinh,
        b_n_duyet,b_ngay_qd,b_nt_tien,b_tien,b_thue,
        a_lh_nvC,a_tien_bhC,a_pt_btC,a_t_thatC,a_tienC,a_tien_qdC,a_thueC,a_thue_qdC,
        hk_ma,hk_ten,hk_ma_nt,hk_tien,hk_thue,hk_tien_qd,hk_thue_qd,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_XEp_NH_NH:loi'; end if;
end;
/
create or replace procedure PBH_BT_XEp_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000); b_i1 number; b_ngay_qdC number:=0; b_ma_dviC varchar2(20);
    dt_ct clob; dt_dk clob; dt_hk clob;
    b_so_id number; b_so_hs varchar2(30); b_ttrang varchar2(1); b_ngay_ht number:=PKH_NG_CSO(sysdate);
    b_nv varchar2(1); b_so_hs_bt varchar2(20); b_so_id_bt number; b_ten nvarchar2(500); 
    b_n_trinh varchar2(20); b_n_duyet varchar2(20); b_ngay_qd number; b_ngay_do number; 
    b_c_thue varchar2(1); b_nt_tien varchar2(5); b_tien number; b_thue number;

    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var; dk_ma_ct pht_type.a_var; 
    dk_tien_bh pht_type.a_num; dk_pt_bt pht_type.a_num; dk_t_that pht_type.a_num; 
    dk_tien pht_type.a_num; dk_thue pht_type.a_num; dk_tien_qd pht_type.a_num; dk_thue_qd pht_type.a_num;
    dk_cap pht_type.a_var; dk_ma_dk pht_type.a_var; dk_ma_bs pht_type.a_var; 
    dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num; dk_nd pht_type.a_nvar; dk_lkeB pht_type.a_var; 
    hk_nhom pht_type.a_var; hk_ma pht_type.a_var; hk_ten pht_type.a_nvar; hk_ma_nt pht_type.a_var; 
    hk_tien pht_type.a_num; hk_thue pht_type.a_num; hk_tien_qd pht_type.a_num; hk_thue_qd pht_type.a_num;
begin
-- Dan - Nhap Phuong an boi thuong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id');
EXECUTE IMMEDIATE b_lenh into b_so_id using b_oraIn;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_hk');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_hk using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_hk);
dt_dk:=trim(dt_dk); dt_hk:=trim(dt_hk);
if dt_dk is not null then FKH_JSa_NULL(dt_dk); end if;
if dt_hk is not null then FKH_JSa_NULL(dt_hk); end if;
b_so_id:=nvl(b_so_id,0);
if b_so_id<>0 then
    select count(*) into b_i1 from bh_bt_xeP where so_id=b_so_id;
    if b_i1=0 then b_so_id:=0; end if;
end if;
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
else
    b_loi:='loi:Phuong an dang xu ly:loi';
    -- chuclh: theo don vi hsbt
    select ma_dvi,ngay_qd into b_ma_dviC,b_ngay_qdC from bh_bt_xeP where so_id=b_so_id for update nowait;
    if sql%rowcount=0 then raise PROGRAM_ERROR; end if;
    PBH_BT_XEp_XOA_XOA(b_ma_dviC,b_nsd,b_so_id,true,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_BT_XEp_TESTr(
    b_ma_dvi,b_nsd,b_so_id,dt_ct,dt_dk,dt_hk,
    b_so_hs,b_ttrang,b_nv,b_so_hs_bt,b_so_id_bt,b_ten,
    b_n_trinh,b_n_duyet,b_ngay_qd,b_ngay_do,b_c_thue,b_nt_tien,b_tien,b_thue,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_tien_bh,dk_pt_bt,dk_t_that,
    dk_tien,dk_thue,dk_tien_qd,dk_thue_qd,dk_cap,dk_ma_dk,dk_ma_bs,dk_lh_nv,dk_t_suat,dk_nd,dk_lkeB,
    hk_nhom,hk_ma,hk_ten,hk_ma_nt,hk_tien,hk_thue,hk_tien_qd,hk_thue_qd,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_XEp_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,dt_ct,dt_dk,dt_hk,
    b_so_hs,b_ttrang,b_nv,b_so_hs_bt,b_so_id_bt,b_ten,
    b_n_trinh,b_n_duyet,b_ngay_qd,b_ngay_do,
    b_c_thue,b_nt_tien,b_tien,b_thue,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_tien_bh,dk_pt_bt,dk_t_that,dk_tien,dk_thue,
    dk_tien_qd,dk_thue_qd,dk_cap,dk_ma_dk,dk_ma_bs,dk_lh_nv,dk_t_suat,dk_nd,dk_lkeB,
    hk_nhom,hk_ma,hk_ten,hk_ma_nt,hk_tien,hk_thue,hk_tien_qd,hk_thue_qd,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hs' value b_so_hs) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_XEp_XOA(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Dan - Xoa GCN
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_XEp_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,false,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
