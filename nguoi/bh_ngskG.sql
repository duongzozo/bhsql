/*** Suc khoe gia dinh ***/
create or replace procedure PBH_SKG_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_ngay number:=PKH_NG_CSO(sysdate);
    cs_sp clob; cs_cdich clob; cs_tpa clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten) into cs_sp from
    bh_sk_sp a,(select distinct ma_sp from bh_sk_phi where nhom='G' and ngay_bd<=b_ngay and ngay_kt>b_ngay) b
    where a.ma=b.ma_sp and FBH_SK_SP_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten) into cs_cdich from
    bh_ma_cdich a,(select distinct cdich from bh_sk_phi where nhom='G' and ngay_bd<=b_ngay and ngay_kt>b_ngay) b
    where a.ma=b.cdich and FBH_MA_NV_CO(a.nv,'NG')='C' and FBH_MA_CDICH_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(ma,ten) order by ten returning clob) into cs_tpa
	from bh_ma_gdinh where FBH_MA_GDINH_NV(ma,'NG')='C' and FBH_MA_GDINH_HAN(ma)='C';
select json_object('cs_sp' value cs_sp,'cs_cdich' value cs_cdich,'cs_tpa' value cs_tpa returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SKG_MOd(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_ngay number:=PKH_NG_CSO(sysdate);
    b_ma_sp varchar2(10); b_cdich varchar2(10);
    cs_goi clob; cs_khd clob; cs_kbt clob; cs_tltg clob;cs_ttt clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_sp,cdich');
EXECUTE IMMEDIATE b_lenh into b_ma_sp,b_cdich using b_oraIn;
if trim(b_ma_sp) is null then b_loi:='loi:Chua chon ma san pham:loi'; raise PROGRAM_ERROR; end if;
b_cdich:=PKH_MA_TENl(b_cdich);
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ma) into cs_goi from
    bh_sk_goi a,(select distinct goi from bh_sk_phi where nhom='G' and ma_sp=b_ma_sp and cdich=b_cdich and b_ngay between ngay_bd and ngay_kt) b
    where a.ma=b.goi and FBH_SK_GOI_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_khd from bh_kh_ttt where ps='KHD' and FBH_MA_NV_CO(nv,'NG')='C';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_kbt from bh_kh_ttt where ps='KBT' and FBH_MA_NV_CO(nv,'NG')='C';
select JSON_ARRAYAGG(json_object(tltg,tlph) order by tltg returning clob) into cs_tltg
    from bh_sk_tltg where b_ngay between ngay_bd and ngay_kt;
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_ttt
    from bh_kh_ttt where ps='HD' and FBH_MA_NV_CO(nv,'NG')='C';
select json_object('cs_goi' value cs_goi,'cs_khd' value cs_khd,
    'cs_kbt' value cs_kbt,'cs_tltg' value cs_tltg,'cs_ttt' value cs_ttt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SKG_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma_dvi varchar2(10); b_so_id number; dt_ds clob; dt_kytt clob; dt_ct clob; dt_txt clob;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
-- viet anh
select json_object(so_hd,ma_kh,'tpa' value FBH_DTAC_MA_TENl(tpa)) into dt_ct 
       from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
select txt into dt_ds from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
	from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
select JSON_ARRAYAGG(json_object(ngay,tien) order by ngay) into dt_kytt from bh_sk_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'dt_ds' value dt_ds,
	'dt_kytt' value dt_kytt,'dt_ct' value dt_ct,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SKG_TESTr(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_idG number,
    dt_ct clob,dt_ds in out clob,
    b_so_hdL out varchar2,b_ma_sp out varchar2,b_cdich out varchar2,b_tpaH out varchar2,

    gcn_so_id out pht_type.a_num,gcn_kieu_gcn out pht_type.a_var,gcn_mau_ac out pht_type.a_var,
    gcn_gcn out pht_type.a_var,gcn_gcnG out pht_type.a_var,
    gcn_goi out pht_type.a_var,gcn_so_idP out pht_type.a_num,gcn_ma_kh out pht_type.a_var,
    gcn_ten out pht_type.a_nvar,gcn_ng_sinh out pht_type.a_num,gcn_gioi out pht_type.a_var,
    gcn_cmt out pht_type.a_var,gcn_mobi out pht_type.a_var,gcn_email out pht_type.a_var,
    gcn_dchi out pht_type.a_nvar,gcn_nghe out pht_type.a_var,gcn_ng_huong out pht_type.a_nvar,
    gcn_gio_hl out pht_type.a_var,gcn_ngay_hl out pht_type.a_num,gcn_gio_kt out pht_type.a_var,
    gcn_ngay_kt out pht_type.a_num,gcn_ngay_cap out pht_type.a_num,
    gcn_phi out pht_type.a_num,gcn_giam out pht_type.a_num,gcn_ttoan out pht_type.a_num,

    dk_so_id out pht_type.a_num,dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,
    dk_tc out pht_type.a_var,dk_ma_ct out pht_type.a_var,dk_kieu out pht_type.a_var,dk_bt out pht_type.a_num,
    dk_tien out pht_type.a_num,dk_pt out pht_type.a_num,dk_phi out pht_type.a_num,
    dk_thue out pht_type.a_num,dk_ttoan out pht_type.a_num,
    dk_cap out pht_type.a_num,dk_ma_dk out pht_type.a_var,
    dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,
    dk_ptB out pht_type.a_num,dk_ptG out pht_type.a_num,dk_phiG out pht_type.a_num,
    dk_lkeP out pht_type.a_var,dk_lkeB out pht_type.a_var,dk_luy out pht_type.a_var,dk_lh_bh out pht_type.a_var,

    lsb_so_id out pht_type.a_num,lsb_ma out pht_type.a_var,lsb_ten out pht_type.a_nvar,lsb_muc out pht_type.a_num,
    bkh_so_id out pht_type.a_num,bkh_ten out pht_type.a_nvar,bkh_muc out pht_type.a_num,
    lt_so_id out pht_type.a_num,lt_dk out pht_type.a_clob,lt_lt out pht_type.a_clob,lt_hk out pht_type.a_clob,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_i2 number; b_so_dt number;
    b_kieu_hd varchar2(1); b_ttrang varchar2(1); dt_khd clob; b_txt clob; b_ktG number;
    b_kt_dk number; b_kt_lsb number; b_kt_bkh number; b_ttoanH number;
    b_gio_hl nvarchar2(50); b_ngay_hl number; b_gio_kt nvarchar2(50); b_ngay_kt number; b_ngay_cap number;

    dt_ds_ct pht_type.a_clob; dt_ds_dk pht_type.a_clob; dt_ds_dkbs pht_type.a_clob; dt_ds_hk pht_type.a_clob; dt_ds_lt pht_type.a_clob;
    dt_ds_lsb pht_type.a_clob; dt_ds_bkh pht_type.a_clob; dt_ds_ttt pht_type.a_clob;
    dt_ds_khd pht_type.a_clob; dt_ds_kbt pht_type.a_clob;dt_ds_cho pht_type.a_clob; dt_ds_bvi pht_type.a_clob;

    nh_maG pht_type.a_var; nh_tenG pht_type.a_nvar;
    nh_tcG pht_type.a_var; nh_ma_ctG pht_type.a_var; nh_kieuG pht_type.a_var;
    nh_tienG pht_type.a_num; nh_ptG pht_type.a_num; nh_phiG pht_type.a_num; nh_t_suatG pht_type.a_num;
    nh_capG pht_type.a_num; nh_ma_dkG pht_type.a_var;
    nh_lh_nvG pht_type.a_var; nh_ptBG pht_type.a_var; nh_phiBG pht_type.a_var; nh_lkeMG pht_type.a_var;
    nh_lkePG pht_type.a_var; nh_lkeBG pht_type.a_var; nh_luyG pht_type.a_var; nh_lh_bhG pht_type.a_var;

    nhB_maG pht_type.a_var; nhB_tenG pht_type.a_nvar;
    nhB_tcG pht_type.a_var; nhB_ma_ctG pht_type.a_var; nhB_kieuG pht_type.a_var;
    nhB_tienG pht_type.a_num; nhB_ptG pht_type.a_num; nhB_phiG pht_type.a_num; nhB_t_suatG pht_type.a_num;
    nhB_capG pht_type.a_num; nhB_ma_dkG pht_type.a_var;
    nhB_lh_nvG pht_type.a_var; nhB_ptBG pht_type.a_var; nhB_phiBG pht_type.a_var; nhB_lkeMG pht_type.a_var;
    nhB_lkePG pht_type.a_var; nhB_lkeBG pht_type.a_var; nhB_luyG pht_type.a_var;

    dk_phiB pht_type.a_num; dk_lkeM pht_type.a_var; a_ds pht_type.a_clob;
    lsb_maG pht_type.a_var; lsb_tenG pht_type.a_nvar; lsb_mucG pht_type.a_var;
    bkh_tenG pht_type.a_nvar;
begin
-- Dan - Nhap
b_lenh:=FKH_JS_LENH('ttrang,kieu_hd,gio_hl,ngay_hl,gio_kt,ngay_kt,ngay_cap,ma_sp,cdich,tpa,ttoan,so_hdl');
EXECUTE IMMEDIATE b_lenh into b_ttrang,b_kieu_hd,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_ma_sp,b_cdich,b_tpaH,b_ttoanH,b_so_hdL using dt_ct;
b_ma_sp:=nvl(trim(b_ma_sp),' '); b_cdich:=PKH_MA_TENl(b_cdich);
if b_ma_sp<>' ' and FBH_SK_SP_HAN(b_ma_sp)<>'C' then b_loi:='loi:Sai ma san pham:loi'; return; end if;
if b_cdich<>' ' and FBH_MA_CDICH_HAN(b_cdich)<>'C' then b_loi:='loi:Sai ma chien dich:loi'; return; end if;
b_tpaH:=NVL(trim(b_tpaH),' ');
if b_tpaH<>' ' and FBH_MA_GDINH_HAN(b_tpaH)<>'C' then b_loi:='loi:Sai ma TPA '||b_tpaH||':loi'; return; end if;
b_lenh:=FKH_JS_LENHc('dt_ds_ct,dt_ds_dk,dt_ds_dkbs,dt_ds_hk,dt_ds_lt,dt_ds_lsb,dt_ds_bkh,dt_ds_ttt,dt_ds_khd,dt_ds_kbt,dt_ds_cho,dt_ds_bvi');
EXECUTE IMMEDIATE b_lenh bulk collect into dt_ds_ct,dt_ds_dk,dt_ds_dkbs,dt_ds_hk,dt_ds_lt,dt_ds_lsb,dt_ds_bkh,dt_ds_ttt,dt_ds_khd,dt_ds_kbt,dt_ds_cho,dt_ds_bvi using dt_ds;
b_so_dt:=dt_ds_ct.count;
if b_so_dt=0 then b_loi:='loi:Nhap danh sach nguoi duoc bao hiem:loi'; return; end if;
b_lenh:=FKH_JS_LENH('so_id_dt,kieu_gcn,mau_ac,gcn,gcn_g,ten,ng_sinh,gioi,cmt,mobi,email,nghe,dchi,ng_huong,gio_hl,ngay_hl,gio_kt,ngay_kt,goi,so_idp');
for b_lp in 1..dt_ds_ct.count loop
    EXECUTE IMMEDIATE b_lenh into
        gcn_so_id(b_lp),gcn_kieu_gcn(b_lp),gcn_mau_ac(b_lp),gcn_gcn(b_lp),gcn_gcnG(b_lp),gcn_ten(b_lp),
        gcn_ng_sinh(b_lp),gcn_gioi(b_lp),gcn_cmt(b_lp),gcn_mobi(b_lp),gcn_email(b_lp),
        gcn_nghe(b_lp),gcn_dchi(b_lp),gcn_ng_huong(b_lp),gcn_gio_hl(b_lp),gcn_ngay_hl(b_lp),
        gcn_gio_kt(b_lp),gcn_ngay_kt(b_lp),gcn_goi(b_lp),gcn_so_idP(b_lp) using dt_ds_ct(b_lp);
    if trim(gcn_ten(b_lp)) is null then b_loi:='loi:Nhap ten dong '||to_char(b_lp)||':loi'; return; end if;
    if gcn_so_id(b_lp) is null then b_loi:='loi:mat so_id_dt '||gcn_ten(b_lp)||':loi'; return; end if;
    if trim(gcn_gioi(b_lp)) is null then b_loi:='loi:Nhap gioi '||gcn_ten(b_lp)||':loi'; return; end if;
    if gcn_ng_sinh(b_lp) is null or gcn_ng_sinh(b_lp) in(0,30000101) then b_loi:='loi:Nhap ngay sinh '||gcn_ten(b_lp)||':loi'; return; end if;
    gcn_nghe(b_lp):=PKH_MA_TENl(gcn_nghe(b_lp),' ');
    gcn_ma_kh(b_lp):=' '; gcn_goi(b_lp):=nvl(trim(gcn_goi(b_lp)),' ');
    if gcn_nghe(b_lp)<>' ' and FBH_MA_NGHE_HAN(gcn_nghe(b_lp))<>'C' then b_loi:='loi:Sai ma nghe '||gcn_ten(b_lp)||':loi'; return; end if;
    if gcn_so_id(b_lp)=0 then gcn_so_id(b_lp):=b_lp; end if;
    gcn_ngay_cap(b_lp):=b_ngay_cap;

    gcn_gcn(b_lp):=nvl(trim(gcn_gcn(b_lp)),' '); gcn_gcnG(b_lp):=nvl(trim(gcn_gcnG(b_lp)),' ');

    --nam: check thoi han hieu luc cua hop dong so voi GCN
    gcn_gio_hl(b_lp):=to_number(replace(gcn_gio_hl(b_lp),'|','')); gcn_gio_kt(b_lp):=to_number(replace(gcn_gio_kt(b_lp),'|',''));
    b_gio_hl:=to_number(replace(b_gio_hl,'|','')); b_gio_kt:=to_number(replace(b_gio_kt,'|',''));
    b_loi:='loi:Sai ngay hieu luc : '||gcn_ten(b_lp)||':loi';
    if gcn_ngay_hl(b_lp) in(0,30000101) or gcn_ngay_kt(b_lp) in(0,30000101) or
        gcn_ngay_hl(b_lp)<b_ngay_hl or gcn_ngay_hl(b_lp)>gcn_ngay_kt(b_lp) or gcn_ngay_kt(b_lp)>b_ngay_kt then return; end if;
    if gcn_ngay_hl(b_lp)=b_ngay_hl or gcn_ngay_kt(b_lp)=b_ngay_kt then
     if gcn_gio_hl(b_lp)<b_gio_hl or gcn_gio_kt(b_lp)>b_gio_kt then return; end if;
    elsif gcn_ngay_hl(b_lp)=gcn_ngay_kt(b_lp) and gcn_gio_hl(b_lp)>gcn_gio_kt(b_lp) then return;
    end if;
end loop;
if b_kieu_hd in('B','S') and b_so_idG<>0 then
    for r_lp in (select so_id_dt,ten from bh_sk_ds where ma_dvi=b_ma_dvi and so_id=b_so_idG) loop
        if FKH_ARR_VTRI_N(gcn_so_id,r_lp.so_id_dt)=0 then b_loi:='loi:Khong xoa danh sach cu '||r_lp.ten||':loi'; return; end if;
    end loop;
end if;
b_kt_dk:=0;
b_lenh:=FKH_JS_LENH('ma,ten,tien,pt,phi,t_suat,cap,tc,ma_ct,kieu,ma_dk,lh_nv,ptb,phib,lkem,lkep,lkeb,luy');
for b_lp in 1..gcn_ten.count loop
    EXECUTE IMMEDIATE b_lenh bulk collect into
        nh_maG,nh_tenG,nh_tienG,nh_ptG,nh_phiG,nh_t_suatG,nh_capG,nh_tcG,nh_ma_ctG,nh_kieuG,
        nh_ma_dkG,nh_lh_nvG,nh_ptBG,nh_phiBG,nh_lkeMG,nh_lkePG,nh_lkeBG,nh_luyG using dt_ds_dk(b_lp);
    b_ktG:=nh_maG.count;
    if b_ktG=0 then
        b_loi:='loi:Chua nhap dieu khoan bao hiem '||gcn_ten(b_lp)||':loi'; return;
    end if;
    for b_lp2 in 1..b_ktG loop
        nh_lh_bhG(b_lp2):='C';
    end loop;

    if trim(dt_ds_dkbs(b_lp)) is not null then
        EXECUTE IMMEDIATE b_lenh bulk collect into
            nhB_maG,nhB_tenG,nhB_tienG,nhB_ptG,nhB_phiG,nhB_t_suatG,nhB_capG,nhB_tcG,nhB_ma_ctG,nhB_kieuG,
            nhB_ma_dkG,nhB_lh_nvG,nhB_ptBG,nhB_phiBG,nhB_lkeMG,nhB_lkePG,nhB_lkeBG,nhB_luyG using dt_ds_dkbs(b_lp);
        for b_lp2 in 1..nhB_maG.count loop
            b_ktG:=b_ktG+1;
            nh_lh_bhG(b_ktG):='M';
            nh_maG(b_ktG):=nhB_maG(b_lp2); nh_tenG(b_ktG):=nhB_tenG(b_lp2); nh_tienG(b_ktG):=nhB_tienG(b_lp2);
            nh_ptG(b_ktG):=nhB_ptG(b_lp2); nh_phiG(b_ktG):=nhB_phiG(b_lp2); nh_t_suatG(b_ktG):=nhB_t_suatG(b_lp2);nh_capG(b_ktG):=nhB_capG(b_lp2);
            nh_tcG(b_ktG):=nhB_tcG(b_lp2); nh_ma_ctG(b_ktG):=nhB_ma_ctG(b_lp2); nh_kieuG(b_ktG):=nhB_kieuG(b_lp2);
            nh_ma_dkG(b_ktG):=nhB_ma_dkG(b_lp2); nh_lh_nvG(b_ktG):=nhB_lh_nvG(b_lp2); nh_ptBG(b_ktG):=nhB_ptBG(b_lp2); nh_phiBG(b_ktG):=nhB_phiBG(b_lp2);
            nh_lkeMG(b_ktG):=nhB_lkeMG(b_lp2); nh_lkePG(b_ktG):=nhB_lkePG(b_lp2); nh_lkeBG(b_ktG):=nhB_lkeBG(b_lp2); nh_luyG(b_ktG):=nhB_luyG(b_lp2);
        end loop;
    end if;
    for b_lp2 in 1..nh_maG.count loop
        b_kt_dk:=b_kt_dk+1;
        dk_so_id(b_kt_dk):=gcn_so_id(b_lp);
        dk_ma(b_kt_dk):=nh_maG(b_lp2);dk_ten(b_kt_dk):=nh_tenG(b_lp2); dk_tc(b_kt_dk):=nh_tcG(b_lp2);
        dk_ma_ct(b_kt_dk):=nh_ma_ctG(b_lp2); dk_kieu(b_kt_dk):=nh_kieuG(b_lp2); dk_bt(b_kt_dk):=b_lp2;
        dk_tien(b_kt_dk):=nh_tienG(b_lp2); dk_ptB(b_kt_dk):=nh_ptBG(b_lp2); dk_pt(b_kt_dk):=nh_ptG(b_lp2);
        dk_phi(b_kt_dk):=nh_phiG(b_lp2);
        dk_cap(b_kt_dk):=nh_capG(b_lp2); dk_ma_dk(b_kt_dk):=nh_ma_dkG(b_lp2);
        dk_lh_nv(b_kt_dk):=nh_lh_nvG(b_lp2);
        dk_lkeM(b_kt_dk):=nh_lkeMG(b_lp2); dk_lkeP(b_kt_dk):=nh_lkePG(b_lp2);
        dk_lkeB(b_kt_dk):=nh_lkeBG(b_lp2);  dk_phiB(b_kt_dk):=nh_phiBG(b_lp2);
        dk_luy(b_kt_dk):=nh_luyG(b_lp2); dk_lh_bh(b_kt_dk):=nh_lh_bhG(b_lp2);
        dk_t_suat(b_kt_dk):=0; dk_thue(b_kt_dk):=0; dk_ttoan(b_kt_dk):=dk_phi(b_kt_dk);
    end loop;
    if dt_ds_dkbs(b_lp) is null then
        b_txt:=dt_ds_dk(b_lp);
    else
        b_i1:=length(dt_ds_dk(b_lp))-1;
        b_txt:=substr(dt_ds_dk(b_lp),1,b_i1)||','||substr(dt_ds_dkbs(b_lp),2);
    end if;
    lt_so_id(b_lp):=gcn_so_id(b_lp); lt_dk(b_lp):=b_txt; lt_lt(b_lp):=dt_ds_lt(b_lp);lt_hk(b_lp):=dt_ds_hk(b_lp);
    b_i1:=FBH_SK_BPHI_SO_IDh('G',b_ma_sp,b_cdich,gcn_goi(b_lp),gcn_ng_sinh(b_lp),gcn_ngay_hl(b_lp));
    if gcn_so_idP(b_lp)<>b_i1 then
        b_loi:='loi:'||gcn_ten(b_lp)||' Sai bieu phi:loi'; return;
    end if;
end loop;
for b_lp in 1..dk_ma.count loop
    dk_tien(b_lp):=nvl(dk_tien(b_lp),0);
    if dk_tien(b_lp)=0 and dk_lkeM(b_lp) not in ('T','N','K','B') and dk_kieu(b_lp)='T' then
      b_loi:='loi:Chua nhap muc trach nhiem dieu khoan '||dk_ma(b_lp)||':loi'; return;
    end if;
    if dk_tien(b_lp)<>0 then
      b_i1:=round(dk_phiB(b_lp)/dk_tien(b_lp)*100,4);
      dk_pt(b_lp):= b_i1 - round(((dk_phiB(b_lp)/dk_tien(b_lp))-(dk_phi(b_lp)/dk_tien(b_lp)))*100 ,4);
    elsif dk_lkeP(b_lp)='I' and dk_tien(b_lp)=0 then
      dk_pt(b_lp):=dk_ptB(b_lp);
    end if;
end loop;
PBH_HD_THAY_PHIg('VND','VND',1,0,b_ttoanH,dk_lh_nv,dk_tien,dk_phi,dk_thue,dk_ttoan,b_loi);
if b_loi is not null then return; end if;
for b_lp in 1..dk_ma.count loop
    if dk_phiB(b_lp)>dk_phi(b_lp) and dk_tien(b_lp) > 0 and dk_lh_nv(b_lp)<> ' ' then
        dk_phiG(b_lp):=dk_phiB(b_lp)-dk_phi(b_lp);
        dk_ptG(b_lp):=round(dk_phiG(b_lp)*100/dk_phiB(b_lp),2);
    else
        dk_ptG(b_lp):=0; dk_phiG(b_lp):=0;
    end if;
end loop;
for b_lp in 1..gcn_ten.count loop
    gcn_phi(b_lp):=0; gcn_giam(b_lp):=0;
    for b_lp1 in 1..b_kt_dk loop
        if dk_lh_nv(b_lp1)<>' ' and dk_so_id(b_lp1)=gcn_so_id(b_lp) then
            gcn_phi(b_lp):=gcn_phi(b_lp)+dk_phi(b_lp1);
            gcn_giam(b_lp):=gcn_giam(b_lp)+dk_phiG(b_lp1);
        end if;
    end loop;
    gcn_ttoan(b_lp):=gcn_phi(b_lp)-gcn_giam(b_lp);
end loop;
b_kt_lsb:=0; b_lenh:=FKH_JS_LENH('ma,ten,muc');
for b_lp in 1..gcn_ten.count loop
    EXECUTE IMMEDIATE b_lenh bulk collect into lsb_maG,lsb_tenG,lsb_mucG using dt_ds_lsb(b_lp);
    for b_lp2 in 1..lsb_maG.count loop
        b_kt_lsb:=b_kt_lsb+1;
        lsb_so_id(b_kt_lsb):=gcn_so_id(b_lp); lsb_ma(b_kt_lsb):=lsb_maG(b_lp2);
        lsb_ten(b_kt_lsb):=lsb_tenG(b_lp2); lsb_muc(b_kt_lsb):=PKH_LOC_CHU_SO(lsb_mucG(b_lp2),'F','F');
    end loop;
end loop;
b_kt_bkh:=0; b_lenh:=FKH_JS_LENH('ten');
for b_lp in 1..gcn_ten.count loop
    EXECUTE IMMEDIATE b_lenh bulk collect into bkh_tenG using dt_ds_bkh(b_lp);
    for b_lp2 in 1..bkh_tenG.count loop
        b_kt_bkh:=b_kt_bkh+1;
        bkh_so_id(b_kt_bkh):=gcn_so_id(b_lp);
        bkh_ten(b_kt_bkh):=bkh_tenG(b_lp2); bkh_muc(b_kt_bkh):=6;
    end loop;
end loop;
if b_ttrang in('T','D') then
    for b_lp in 1..gcn_ten.count loop
        b_i1:=gcn_so_id(b_lp);
        if b_so_hdL='P' and b_ttrang='D' then
            PBH_LAY_SOAC(b_ma_dvi,'CN',gcn_mau_ac(b_lp),gcn_gcn(b_lp),b_loi);
            if b_loi is not null then return; end if;
            if trim(gcn_gcn(b_lp)) is null then b_loi:='loi:Khong lay duoc so an chi:loi'; return; end if;
            if FBH_SK_SO_ID(b_ma_dvi,gcn_gcn(b_lp)) > 0 then b_loi:='loi:So an chi da su dung '||gcn_gcn(b_lp)||':loi'; return; end if;
        elsif b_i1<100000 then
            PHT_ID_MOI(b_i2,b_loi);
            if b_loi is not null then return; end if;
            for b_lp1 in 1..dk_so_id.count loop
                if dk_so_id(b_lp1)=gcn_so_id(b_lp) then dk_so_id(b_lp1):=b_i2; end if;
            end loop;
            for b_lp1 in 1..lsb_so_id.count loop
                if lsb_so_id(b_lp1)=gcn_so_id(b_lp) then lsb_so_id(b_lp1):=b_i2; end if;
            end loop;
            for b_lp1 in 1..bkh_so_id.count loop
                if bkh_so_id(b_lp1)=gcn_so_id(b_lp) then bkh_so_id(b_lp1):=b_i2; end if;
            end loop;
            gcn_so_id(b_lp):=b_i2; lt_so_id(b_lp):=b_i2;
            gcn_kieu_gcn(b_lp):='G';
            if b_so_hdL <> 'P' then gcn_gcn(b_lp):=substr(to_char(b_i2),3); end if;
            gcn_gcnG(b_lp):=' ';
        elsif b_kieu_hd not in('S','B') then
            gcn_kieu_gcn(b_lp):='G';
            if b_so_hdL <> 'P' then gcn_gcn(b_lp):=substr(to_char(gcn_so_id(b_lp)),3); end if;
            gcn_gcnG(b_lp):=' ';
        else
            if b_kieu_hd in('S','B') and gcn_gcnG(b_lp)<>' ' then
                select count(*) into b_i1 from bh_sk_ds where ma_dvi=b_ma_dvi and so_id_dt=gcn_so_id(b_lp) and gcn=gcn_gcnG(b_lp);
                if b_i1=0 then b_loi:='loi:GCN '||gcn_gcnG(b_lp)||' da xoa:loi'; return; end if;
                select count(*) into b_i1 from bh_sk_ds where ma_dvi=b_ma_dvi and so_id_dt=gcn_so_id(b_lp) and gcn_g=gcn_gcnG(b_lp);
                gcn_kieu_gcn(b_lp):=b_kieu_hd;
                if b_i1=0 then  gcn_gcn(b_lp):=' '; end if;
            end if;
            if gcn_gcn(b_lp)=' ' or instr(gcn_gcn(b_lp),'.')=2 then
                gcn_gcn(b_lp):=substr(to_char(gcn_so_id(b_lp)),3);
                if gcn_kieu_gcn(b_lp)<>'G' then
                    select count(*) into b_i1 from bh_sk_ds where ma_dvi=b_ma_dvi and so_id_dt=gcn_so_id(b_lp) and kieu_gcn=b_kieu_hd;
                    if(b_i1>0) then
                       select max(REGEXP_SUBSTR(gcn, 'B([0-9]+)', 1, 1, NULL, 1)) into b_i1 from bh_sk_ds where ma_dvi=b_ma_dvi and so_id_dt=gcn_so_id(b_lp) and kieu_gcn=b_kieu_hd;
                    end if;
                    gcn_gcn(b_lp):=gcn_gcn(b_lp)||'/'||b_kieu_hd||to_char(b_i1+1);
                end if;
            else
                select nvl(max(ngay_cap),b_ngay_cap) into b_ngay_cap from bh_sk_ds where ma_dvi=b_ma_dvi and so_id_dt=gcn_so_id(b_lp) and gcn=gcn_gcn(b_lp);
            end if;
        end if;

        PKH_JS_THAYn(dt_ds_ct(b_lp),'so_id_dt',gcn_so_id(b_lp));
        PKH_JS_THAYa(dt_ds_ct(b_lp),'kieu_gcn,gcn,gcn_g',gcn_kieu_gcn(b_lp)||','||gcn_gcn(b_lp)||','||gcn_gcnG(b_lp));
        select json_object('loai' value 'C','ten' value gcn_ten(b_lp),'cmt' value gcn_cmt(b_lp),
            'dchi' value gcn_dchi(b_lp),'mobi' value gcn_mobi(b_lp),'email' value gcn_email(b_lp),
            'gioi' value gcn_gioi(b_lp),'ng_sinh' value gcn_ng_sinh(b_lp)) into b_txt from dual;
        PBH_DTAC_MA_NH(b_txt,gcn_ma_kh(b_lp),b_loi,b_ma_dvi,b_nsd);
        if gcn_ma_kh(b_lp) in(' ','VANGLAI') then b_loi:='loi:Chua du thong tin '||gcn_ten(b_lp)||':loi'; return; end if;
        select count(*) into b_i1 from bh_sk_phi_txt where so_id=gcn_so_idP(b_lp) and loai='dt_khd';
        if b_i1<>0 then
            select txt into dt_khd from bh_sk_phi_txt where so_id=gcn_so_idP(b_lp) and loai='dt_khd';
            b_i1:=length(dt_khd)-2;
            dt_khd:=substr(dt_khd,2,b_i1); b_txt:=dt_ds_ct(b_lp);
            PKH_JS_THAYn(b_txt,'ngay_hl',gcn_ngay_hl(b_lp));
            PBH_SK_KHD(b_txt,dt_khd,b_loi);
            if b_loi is not null then b_loi:='loi:'||gcn_ten(b_lp)||' '||b_loi||':loi'; return; end if;
        end if;
    end loop;
    for b_lp in 1..gcn_ten.count loop
        select json_object('dt_ds_ct' value dt_ds_ct(b_lp),'dt_ds_dk' value dt_ds_dk(b_lp),'dt_ds_dkbs' value dt_ds_dkbs(b_lp),
        'dt_ds_khd' value dt_ds_khd(b_lp), 'dt_ds_kbt' value dt_ds_kbt(b_lp),
        'dt_ds_hk' value dt_ds_hk(b_lp), 'dt_ds_cho' value dt_ds_cho(b_lp), 'dt_ds_bvi' value dt_ds_bvi(b_lp),
        'dt_ds_lt' value dt_ds_lt(b_lp),'dt_ds_lsb' value dt_ds_lsb(b_lp),'dt_ds_bkh' value dt_ds_bkh(b_lp),'dt_ds_ttt' value dt_ds_ttt(b_lp)
         returning clob) into a_ds(b_lp) from dual;
    end loop;
    dt_ds:=FBH_KH_ARRc_JS(a_ds);
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_SKG_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    dt_ct in out clob,dt_ds clob, dt_ds_txt clob,
-- Chung
    b_so_hd varchar2,b_ngay_ht number,b_ttrang varchar2,b_kieu_hd varchar2,b_so_hd_g varchar2,
    b_kieu_kt varchar2,b_ma_kt varchar2,b_kieu_gt varchar2,b_ma_gt varchar2,b_ma_cb varchar2,
    b_so_hdL varchar2,b_loai_kh varchar2,b_ma_kh varchar2,b_ten nvarchar2,b_dchi nvarchar2,
    b_cmt varchar2,b_mobi varchar2,b_email varchar2,
    b_gio_hl varchar2,b_ngay_hl number,b_gio_kt varchar2,b_ngay_kt number,b_ngay_cap number,
    b_nt_tien varchar2,b_nt_phi varchar2,b_c_thue varchar2,
    b_phi number,b_giam number,b_thue number,b_ttoan number,b_hhong number,
    b_so_idG number,b_so_idD number,b_ngayD number,b_phong varchar2,
    tt_ngay pht_type.a_num,tt_tien pht_type.a_num,
-- Rieng
    b_ma_sp varchar2,b_cdich varchar2,b_tpaH varchar2,

    gcn_so_id pht_type.a_num,gcn_kieu_gcn pht_type.a_var,gcn_gcn pht_type.a_var,gcn_gcnG pht_type.a_var,
    gcn_goi pht_type.a_var,gcn_so_idP pht_type.a_num,gcn_ma_kh pht_type.a_var,
    gcn_ten pht_type.a_nvar,gcn_ng_sinh pht_type.a_num,gcn_gioi pht_type.a_var,
    gcn_cmt pht_type.a_var,gcn_mobi pht_type.a_var,gcn_email pht_type.a_var,
    gcn_dchi pht_type.a_nvar,gcn_nghe pht_type.a_var,gcn_ng_huong pht_type.a_nvar,
    gcn_gio_hl pht_type.a_var,gcn_ngay_hl pht_type.a_num,gcn_gio_kt pht_type.a_var,gcn_ngay_kt pht_type.a_num,gcn_ngay_cap pht_type.a_num,
    gcn_phi pht_type.a_num,gcn_giam pht_type.a_num,gcn_ttoan pht_type.a_num,

    dk_so_id pht_type.a_num,dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tc pht_type.a_var,
    dk_ma_ct pht_type.a_var,dk_kieu pht_type.a_var,dk_bt pht_type.a_num,dk_tien pht_type.a_num,dk_pt pht_type.a_num,
    dk_phi pht_type.a_num,dk_thue pht_type.a_num,dk_ttoan pht_type.a_num,
    dk_cap pht_type.a_num,dk_ma_dk pht_type.a_var,dk_lh_nv pht_type.a_var,dk_t_suat pht_type.a_num,
    dk_ptB pht_type.a_num,dk_ptG pht_type.a_num,dk_phiG pht_type.a_num,dk_lkeP pht_type.a_var,
    dk_lkeB pht_type.a_var,dk_luy pht_type.a_var,dk_lh_bh pht_type.a_var,

    lsb_so_id pht_type.a_num,lsb_ma pht_type.a_var,lsb_ten pht_type.a_nvar,lsb_muc pht_type.a_num,
    bkh_so_id pht_type.a_num,bkh_ten pht_type.a_nvar,bkh_muc pht_type.a_num,
    lt_so_id pht_type.a_num,lt_dk pht_type.a_clob,lt_lt pht_type.a_clob,lt_hk pht_type.a_clob,b_loi out varchar2)
AS
    b_so_dt number;  b_so_id_kt number:=-1; b_tien number:=0; b_ma_ke varchar2(20):=' ';
    dt_lt clob; dt_khd clob; dt_kbt clob; dt_cho clob; dt_bvi clob;
begin
-- Dan - Nhap
b_loi:='loi:Loi Table bh_sk:loi';
b_so_dt:=gcn_so_id.count;
if b_ttrang='D' then b_so_id_kt:=0; end if;
for b_lp in 1..tt_ngay.count loop
    insert into bh_sk_tt values(b_ma_dvi,b_so_id,tt_ngay(b_lp),tt_tien(b_lp));
end loop;
for b_lp in 1..gcn_so_id.count loop
    insert into bh_sk_ds values(b_ma_dvi,b_so_id,gcn_so_id(b_lp),b_lp,
        gcn_kieu_gcn(b_lp),gcn_gcn(b_lp),gcn_gcnG(b_lp),gcn_ten(b_lp),0,
        gcn_ng_sinh(b_lp),gcn_gioi(b_lp),gcn_cmt(b_lp),gcn_mobi(b_lp),gcn_email(b_lp),gcn_dchi(b_lp),gcn_nghe(b_lp),
        gcn_ng_huong(b_lp),gcn_gio_hl(b_lp),gcn_ngay_hl(b_lp),gcn_gio_kt(b_lp),gcn_ngay_kt(b_lp),gcn_ngay_cap(b_lp),
        gcn_goi(b_lp),gcn_so_idP(b_lp),' ',gcn_phi(b_lp),gcn_giam(b_lp),gcn_ttoan(b_lp),' ',gcn_ma_kh(b_lp));
end loop;
for b_lp in 1..dk_so_id.count loop
    if dk_lh_nv(b_lp)<>' ' and dk_kieu(b_lp)='T' then b_tien:=b_tien+dk_tien(b_lp); end if;
    insert into bh_sk_dk values(b_ma_dvi,b_so_id,dk_so_id(b_lp),dk_bt(b_lp),dk_ma(b_lp),dk_ten(b_lp),
        dk_tc(b_lp),dk_ma_ct(b_lp),dk_kieu(b_lp),
        dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),dk_cap(b_lp),dk_ma_dk(b_lp),dk_lh_nv(b_lp),
        dk_t_suat(b_lp),dk_thue(b_lp),dk_ttoan(b_lp),dk_ptB(b_lp),dk_ptG(b_lp),dk_phiG(b_lp),dk_lkeP(b_lp),
        dk_lkeB(b_lp),dk_luy(b_lp),dk_lh_bh(b_lp));
end loop;
for b_lp in 1..lsb_ma.count loop
    insert into bh_sk_lsb values(b_ma_dvi,b_so_id,lsb_so_id(b_lp),b_lp,lsb_ma(b_lp),lsb_ten(b_lp),lsb_muc(b_lp));
end loop;
for b_lp in 1..bkh_ten.count loop
    insert into bh_sk_bkh values(b_ma_dvi,b_so_id,bkh_so_id(b_lp),b_lp,bkh_ten(b_lp),bkh_muc(b_lp));
end loop;
insert into bh_sk values(
    b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,'G',b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
    b_phong,b_so_hdL,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,
    b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,b_ma_sp,b_cdich,b_tpaH,'K',b_so_dt,'C',
    b_tien,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,'','',b_so_id_kt,b_nsd,sysdate);
PKH_JS_THAY(dt_ct,'so_hd,ma_kh',b_so_hd||','||b_ma_kh);
insert into bh_sk_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
insert into bh_sk_txt values(b_ma_dvi,b_so_id,'dt_ds',dt_ds);
insert into bh_sk_txt values(b_ma_dvi,b_so_id,'dt_ds_txt',dt_ds_txt);
for b_lp in 1..lt_so_id.count loop
    PBH_SK_BPHI_CTk(gcn_so_idP(b_lp),dt_khd,dt_kbt,dt_cho,dt_bvi);
    if trim(dt_khd) is not null then
      insert into bh_sk_kbt values(b_ma_dvi,b_so_id,lt_so_id(b_lp),'dt_khd',dt_khd);
    end if;
    if trim(dt_kbt) is not null then
        insert into bh_sk_kbt values(b_ma_dvi,b_so_id,lt_so_id(b_lp),'dt_kbt',dt_kbt);
    end if;
    if trim(lt_hk(b_lp)) is not null then
        insert into bh_sk_kbt values(b_ma_dvi,b_so_id,lt_so_id(b_lp),'dt_hk',lt_hk(b_lp));
    end if;
    if trim(dt_cho) is not null then
        insert into bh_sk_kbt values(b_ma_dvi,b_so_id,lt_so_id(b_lp),'dt_cho',dt_cho);
    end if;
    if trim(dt_bvi) is not null then
        insert into bh_sk_kbt values(b_ma_dvi,b_so_id,lt_so_id(b_lp),'dt_bvi',dt_bvi);
    end if;
end loop;
if b_ttrang in('T','D') then
    for b_lp in 1..lt_so_id.count loop
        insert into bh_ng_kbt values(b_ma_dvi,b_so_id,lt_so_id(b_lp),lt_dk(b_lp),lt_lt(b_lp),dt_kbt);
        insert into bh_sk_kbt values(b_ma_dvi,b_so_id,lt_so_id(b_lp),'dt_dk',lt_dk(b_lp));
        if trim(lt_lt(b_lp)) is not null then
            insert into bh_sk_kbt values(b_ma_dvi,b_so_id,lt_so_id(b_lp),'dt_lt',lt_lt(b_lp));
        end if;
    end loop;
    insert into bh_ng values(
        b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,'SKG',b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
        b_phong,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,
        b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,'K',b_so_dt,b_tien,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,0,'','',b_nsd);
    for b_lp in 1..tt_ngay.count loop
        insert into bh_ng_tt values(b_ma_dvi,b_so_id,tt_ngay(b_lp),tt_tien(b_lp));
    end loop;
    for b_lp in 1..dk_so_id.count loop
        insert into bh_ng_dk values(b_ma_dvi,b_so_id,dk_so_id(b_lp),dk_bt(b_lp),dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),dk_kieu(b_lp),
        dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),dk_cap(b_lp),dk_ma_dk(b_lp),dk_lh_nv(b_lp),
        dk_t_suat(b_lp),dk_thue(b_lp),dk_ttoan(b_lp),dk_ptB(b_lp),dk_ptG(b_lp),dk_phiG(b_lp),dk_lkeP(b_lp),
        dk_lkeB(b_lp),dk_luy(b_lp),dk_lh_bh(b_lp));
    end loop;
    for b_lp in 1..gcn_so_id.count loop
        insert into bh_ng_ds values(b_ma_dvi,b_so_id,gcn_so_id(b_lp),gcn_kieu_gcn(b_lp),gcn_gcn(b_lp),gcn_gcnG(b_lp),gcn_ten(b_lp),
            gcn_ng_sinh(b_lp),gcn_gioi(b_lp),gcn_cmt(b_lp),gcn_mobi(b_lp),gcn_email(b_lp),gcn_dchi(b_lp),gcn_nghe(b_lp),
            gcn_ng_huong(b_lp),b_ma_sp,gcn_gio_hl(b_lp),gcn_ngay_hl(b_lp),gcn_gio_kt(b_lp),gcn_ngay_kt(b_lp),gcn_ngay_cap(b_lp),
            gcn_so_idP(b_lp),gcn_phi(b_lp),gcn_giam(b_lp),gcn_ttoan(b_lp),' ',gcn_ma_kh(b_lp));
    end loop;
    insert into bh_ng_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
    PBH_NG_GOC_NH(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
end if;
if b_ttrang='D' then
    if b_so_hdL='P' then
        PBH_SK_DON(b_ma_dvi,b_so_id,'N',b_loi);
        if b_loi is not null then return; end if;
    end if;
    PBH_KE_CTI_NHOM(b_ma_dvi,b_so_idD,b_so_idD,b_ma_ke,b_loi);
    if b_loi is not null then return; end if;
    insert into bh_hd_goc_ttindt values(b_ma_dvi,b_so_idD,b_so_idD,'NG',b_ten,b_ma_kh,b_ngay_kt,' ',b_ma_ke);
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_SKG_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(3000); b_lenh varchar2(2000); b_i1 number;
    dt_ct clob; dt_ds clob; dt_kytt clob; dt_ds_txt clob;
-- Chung
    b_so_id number; b_so_hd varchar2(20); b_ngay_ht number; b_ttrang varchar2(1); b_kieu_hd varchar2(1); b_so_hd_g varchar2(20);
    b_kieu_kt varchar2(1); b_ma_kt varchar2(20); b_kieu_gt varchar2(1); b_ma_gt varchar2(20); b_ma_cb varchar2(20);
    b_so_hdL varchar2(20); b_loai_kh varchar2(1); b_ma_kh varchar2(20); b_ten nvarchar2(500); b_dchi nvarchar2(500);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_gio_hl varchar2(20); b_ngay_hl number; b_gio_kt varchar2(20); b_ngay_kt number; b_ngay_cap number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_c_thue varchar2(1);
    b_phi number; b_giam number; b_thue number; b_ttoan number; b_hhong number;
    b_so_idG number; b_so_idD number; b_ngayD number; b_phong varchar2(10);
    tt_ngay pht_type.a_num; tt_tien pht_type.a_num;
-- Rieng
    b_ma_sp varchar2(10); b_cdich varchar2(200); b_tpaH varchar2(20);

    gcn_so_id pht_type.a_num; gcn_kieu_gcn pht_type.a_var; gcn_mau_ac pht_type.a_var;
    gcn_gcn pht_type.a_var; gcn_gcnG pht_type.a_var;
    gcn_goi pht_type.a_var; gcn_so_idP pht_type.a_num; gcn_ma_kh pht_type.a_var;
    gcn_ten pht_type.a_nvar; gcn_ng_sinh pht_type.a_num; gcn_gioi pht_type.a_var;
    gcn_cmt pht_type.a_var; gcn_mobi pht_type.a_var; gcn_email pht_type.a_var;
    gcn_dchi pht_type.a_nvar; gcn_nghe pht_type.a_var; gcn_ng_huong pht_type.a_nvar;
    gcn_gio_hl pht_type.a_var; gcn_ngay_hl pht_type.a_num; gcn_gio_kt pht_type.a_var; gcn_ngay_kt pht_type.a_num; gcn_ngay_cap pht_type.a_num;
    gcn_phi pht_type.a_num; gcn_giam pht_type.a_num; gcn_ttoan pht_type.a_num;

    dk_so_id pht_type.a_num; dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var;
    dk_ma_ct pht_type.a_var; dk_kieu pht_type.a_var;dk_bt pht_type.a_num; dk_tien pht_type.a_num;
    dk_pt pht_type.a_num; dk_phi pht_type.a_num; dk_thue pht_type.a_num; dk_ttoan pht_type.a_num;
    dk_cap pht_type.a_num; dk_ma_dk pht_type.a_var; dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num;
    dk_ptB pht_type.a_num; dk_ptG pht_type.a_num; dk_phiG pht_type.a_num;
    dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var; dk_luy pht_type.a_var; dk_lh_bh pht_type.a_var;

    lsb_so_id pht_type.a_num; lsb_ma pht_type.a_var; lsb_ten pht_type.a_nvar; lsb_muc pht_type.a_num;
    bkh_so_id pht_type.a_num; bkh_ten pht_type.a_nvar; bkh_muc pht_type.a_num;
    lt_so_id pht_type.a_num; lt_dk pht_type.a_clob; lt_lt pht_type.a_clob;lt_hk pht_type.a_clob;
-- Xu ly
    b_ngay_htC number;
begin
-- Dan - Nhap
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_ds,dt_kytt');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_ds,dt_kytt using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_kytt);
dt_ds_txt:=dt_ds;
if b_so_id<>0 then
    select count(*) into b_i1 from bh_sk where so_id=b_so_id;
    if b_i1<>0 then
        select ngay_ht,kieu_hd,ttrang into b_ngay_htC,b_kieu_hd,b_ttrang from bh_sk
            where so_id=b_so_id for update nowait;
        if sql%rowcount=0 then b_loi:='loi:Va cham NSD:loi'; raise PROGRAM_ERROR; end if;
        if b_ttrang not in('T','D') then b_kieu_hd:='X'; else b_kieu_hd:='N'; end if;
        PBH_SK_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_kieu_hd,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
else
    PHT_ID_MOI(b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_HD_JS_TEST(
    b_ma_dvi,b_nsd,b_so_id,b_ngay_htC,'bh_sk',dt_ct,dt_kytt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_loai_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,
    b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_ngayD,b_phong,b_ma_cb,b_ma_kh,
    tt_ngay,tt_tien,b_loi,'NG');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_SKG_TESTr(
    b_ma_dvi,b_nsd,b_so_idG,
    dt_ct,dt_ds,
    b_so_hdL,b_ma_sp,b_cdich,b_tpaH,
    gcn_so_id,gcn_kieu_gcn,gcn_mau_ac,
    gcn_gcn,gcn_gcnG,gcn_goi,gcn_so_idP,gcn_ma_kh,
    gcn_ten,gcn_ng_sinh,gcn_gioi,gcn_cmt,gcn_mobi,gcn_email,gcn_dchi,gcn_nghe,gcn_ng_huong,
    gcn_gio_hl,gcn_ngay_hl,gcn_gio_kt,gcn_ngay_kt,gcn_ngay_cap,gcn_phi,gcn_giam,gcn_ttoan,
    dk_so_id,dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_bt,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,dk_cap,dk_ma_dk,
    dk_lh_nv,dk_t_suat,dk_ptB,dk_ptG,dk_phiG,dk_lkeP,dk_lkeB,dk_luy,dk_lh_bh,
    lsb_so_id,lsb_ma,lsb_ten,lsb_muc,
    bkh_so_id,bkh_ten,bkh_muc,lt_so_id,lt_dk,lt_lt,lt_hk,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_SKG_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,
    dt_ct,dt_ds,dt_ds_txt,
    -- Chung
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,b_so_hdL,
    b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,
    b_so_idG,b_so_idD,b_ngayD,b_phong,
    tt_ngay,tt_tien,
    -- Rieng
    b_ma_sp,b_cdich,b_tpAH,
    gcn_so_id,gcn_kieu_gcn,gcn_gcn,gcn_gcnG,gcn_goi,gcn_so_idP,gcn_ma_kh,gcn_ten,gcn_ng_sinh,gcn_gioi,
    gcn_cmt,gcn_mobi,gcn_email,gcn_dchi,gcn_nghe,gcn_ng_huong,gcn_gio_hl,gcn_ngay_hl,gcn_gio_kt,gcn_ngay_kt,gcn_ngay_cap,
    gcn_phi,gcn_giam,gcn_ttoan,
    dk_so_id,dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_bt,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,dk_cap,dk_ma_dk,
    dk_lh_nv,dk_t_suat,dk_ptB,dk_ptG,dk_phiG,dk_lkeP,dk_lkeB,dk_luy,dk_lh_bh,
    lsb_so_id,lsb_ma,lsb_ten,lsb_muc,
    bkh_so_id,bkh_ten,bkh_muc,lt_so_id,lt_dk,lt_lt,lt_hk,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hd' value b_so_hd, 'ma_kh' value b_ma_kh) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
