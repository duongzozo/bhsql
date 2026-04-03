create or replace procedure PBH_2BG_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_ngay number:=PKH_NG_CSO(sysdate);
    b_fm varchar2(30):=FKH_Fm(); b_fm2 varchar2(30):=replace(FKH_Fm(2),',','');
    cs_sp clob; cs_cdich clob; cs_goi clob; cs_khd clob; cs_kbt clob; cs_ttt clob; cs_ktru clob;
begin
-- Dan - Tham so mo form
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','2B','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
-- viet anh -- bo nhom='G'
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten) into cs_sp from
    bh_2b_sp a,(select distinct ma_sp from bh_2b_phi where ngay_bd<=b_ngay and ngay_kt>b_ngay) b
    where a.ma=b.ma_sp and FBH_2B_SP_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten) into cs_cdich from
    bh_ma_cdich a,(select distinct cdich from bh_2b_phi where ngay_bd<=b_ngay and ngay_kt>b_ngay) b
    where a.ma=b.cdich and FBH_MA_NV_CO(a.nv,'2B')='C' and FBH_MA_CDICH_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten returning clob) into cs_goi from
    bh_2b_goi a,(select distinct goi from bh_2b_phi where ngay_bd<=b_ngay and ngay_kt>b_ngay) b
    where a.ma=b.goi and FBH_2B_GOI_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_khd
    from bh_kh_ttt where ps='KHD' and nv='2B';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_kbt
    from bh_kh_ttt where ps='KBT' and nv='2B';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_ttt
    from bh_kh_ttt where ps='HD' and nv='2B';
select JSON_ARRAYAGG(json_object('ma' value FKH_SO_Fm(pt),'ten' value FKH_SO_Fm(muc)) order by muc) into cs_ktru
    from bh_2b_ktru where ngay_kt>b_ngay order by muc;
select json_object('cs_sp' value cs_sp,'cs_cdich' value cs_cdich,'cs_goi' value cs_goi,
    'cs_khd' value cs_khd,'cs_kbt' value cs_kbt,
    'cs_ttt' value cs_ttt,'cs_ktru' value cs_ktru returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_2BG_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number;
    dt_ct clob; dt_dk clob; dt_dkbs clob; dt_lt clob:=''; dt_kbt clob:=''; dt_hu clob:='';
    dt_kytt clob:=''; dt_ttt clob:=''; dt_txt clob;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','2B','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
if b_so_id=0 then b_loi:='loi:Chon GCN:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
select json_object(
    'nhom_xe' value FBH_2B_NHOM_TENl(nhom_xe),'loai_xe' value FBH_2B_LOAI_TENl(loai_xe),
    'hang' value FBH_2B_HANG_TENl(hang), 'hieu' value FBH_2B_HIEU_TENl(hieu),'pban' value FBH_2B_PB_TENl(hang,hieu,pban),
    'dong' value FBH_2B_DONG_TENl(dong),'md_sd' value FBH_2B_MDSD_TENl(md_sd) returning clob)
    into dt_ct from bh_2b_ds where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ngay,tien) order by ngay) into dt_kytt from bh_2b_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ma,ten) order by bt returning clob) into dt_dk from bh_2b_dk
    where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_bh <> 'M';
select JSON_ARRAYAGG(json_object(ma,ten) order by bt returning clob) into dt_dkbs from bh_2b_dk
    where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_bh = 'M';
select count(*) into b_i1 from bh_2b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_lt';
if b_i1<>0 then
    select txt into dt_lt from bh_2b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_lt';
end if;
select count(*) into b_i1 from bh_2b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_kbt';
if b_i1<>0 then
    select txt into dt_kbt from bh_2b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_kbt';
end if;
select count(*) into b_i1 from bh_2b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hu';
if b_i1<>0 then
    select txt into dt_hu from bh_2b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hu';
end if;
select count(*) into b_i1 from bh_2b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
if b_i1<>0 then
    select txt into dt_ttt from bh_2b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
end if;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_2b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai in('dt_ct','dt_dk','dt_dkbs');
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,
    'dt_lt' value dt_lt,'dt_kbt' value dt_kbt,'dt_hu' value dt_hu,'dt_kytt' value dt_kytt,'dt_ttt' value dt_ttt,
    'dt_ct' value dt_ct,'dt_dk' value dt_dk,'dt_dkbs' value dt_dkbs,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_2BG_KBT(
    b_nv_bh varchar2,b_so_idC varchar2,b_ktru number,dt_kbt in out clob,b_loi out varchar2)
AS
    b_i1 number; b_i2 number:=0; b_lenh varchar2(1000);
    b_ktruC varchar2(30):=to_char(b_ktru); b_txt clob;
    b_so_id number; a_so_id pht_type.a_num;
    kma_ma pht_type.a_var; kma_nd pht_type.a_nvar;
    kbt_ma pht_type.a_clob; kbt_kbt pht_type.a_clob;

begin
-- Dan - Update kbt
b_loi:='loi:Loi xu ly PBH_2BG_KBT:loi';
PKH_CH_ARR_N(b_so_idC,a_so_id);
b_i1:=instr(b_nv_bh,'V');
if b_i1=0 or b_i1>a_so_id.count then b_loi:=''; return; end if;
b_so_id:=a_so_id(b_i1);
b_lenh:=FKH_JS_LENH('ma,kbt');
EXECUTE IMMEDIATE b_lenh bulk collect into kbt_ma,kbt_kbt using dt_kbt;
b_lenh:=FKH_JS_LENH('ma,nd');
for b_lp in 1..kbt_ma.count loop
    if trim(kbt_kbt(b_lp)) is not null and FBH_2B_BPHI_DK_LOAI(b_so_id,kbt_ma(b_lp))='TV' and
		FBH_2B_BPHI_DK_LHBH(b_so_id,kbt_ma(b_lp))='C' then
        EXECUTE IMMEDIATE b_lenh bulk collect into kma_ma,kma_nd using kbt_kbt(b_lp);
        b_i1:=0;
        for b_lp1 in 1..kma_ma.count loop
            if kma_ma(b_lp1)='KVU' then kma_nd(b_lp1):=b_ktruC; b_i1:=1; end if;
        end loop;
        if b_i1=1 then
            b_i2:=1; kbt_kbt(b_lp):='';
            for b_lp1 in 1..kma_ma.count loop
                if b_lp1<>1 then kbt_kbt(b_lp):=kbt_kbt(b_lp)||','; end if;
                select json_object('ma' value kma_ma(b_lp1),'nd' value kma_nd(b_lp1)) into b_txt from dual; 
                kbt_kbt(b_lp):=kbt_kbt(b_lp)||b_txt;
            end loop;
			if trim(kbt_kbt(b_lp)) is not null then kbt_kbt(b_lp):='['||kbt_kbt(b_lp)||']'; end if;
        end if;
    end if;
end loop;
if b_i2=1 then
    dt_kbt:='';
    for b_lp in 1..kbt_ma.count loop
        if b_lp<>1 then dt_kbt:=dt_kbt||','; end if;
        select json_object('ma' value kbt_ma(b_lp),'kbt' value kbt_kbt(b_lp) returning clob) into b_txt from dual; 
        dt_kbt:=dt_kbt||b_txt;
    end loop;
	if trim(dt_kbt) is not null then dt_kbt:='['||dt_kbt||']'; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_2BG_TESTr(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_idD number,dt_ct in out clob,dt_dk clob,dt_dkbs clob,
    b_so_hd in out varchar2,b_so_hdL out varchar2,b_ma_sp out varchar2,b_cdich out varchar2,b_goi out varchar2,
    b_tenC out nvarchar2,b_cmtC out varchar2,b_mobiC out varchar2,
    b_emailC out varchar2,b_dchiC out nvarchar2,b_ng_huong out nvarchar2,
    b_bien_xe out varchar2,b_so_khung out varchar2,b_so_may out varchar2,
    b_hang out varchar2,b_hieu out varchar2,b_pban out varchar2,
    b_loai_xe out varchar2,b_nhom_xe out varchar2,b_dong out varchar2,
    b_dco out varchar2,b_ttai out number,b_so_cn out number,b_thang_sx out number,b_nam_sx out number,b_gia out number,
    b_md_sd out varchar2,b_nv_bh out varchar2,b_bh_tbo out varchar2,b_ktru out number,b_so_idPc out varchar2,b_xe_id out number,

    dk_bt out pht_type.a_num,dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,
    dk_tc out pht_type.a_var,dk_ma_ct out pht_type.a_var, dk_kieu out pht_type.a_var,
    dk_tien out pht_type.a_num,dk_pt out pht_type.a_num,dk_phi out pht_type.a_num,
    dk_thue out pht_type.a_num,dk_ttoan out pht_type.a_num,
    dk_cap out pht_type.a_num,dk_ma_dk out pht_type.a_var,dk_ma_dkC out pht_type.a_var,
    dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,dk_ptB out pht_type.a_num,
    dk_ptG out pht_type.a_num,dk_phiG out pht_type.a_num,
    dk_lkeM out pht_type.a_var,
    dk_lkeP out pht_type.a_var,dk_lkeB out pht_type.a_var,dk_lh_bh out pht_type.a_var, b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_lenh varchar2(2000); b_kt number; b_ktG number;
    dt_khd clob; b_txt clob;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_c_thue varchar2(1); b_ktruC varchar2(30);
    b_thueH number; b_ttoanH number; b_tygia number; b_tp number:=0; b_nv_bhC varchar2(10);
    b_loai_ac varchar2(10);b_mau_ac varchar2(20);b_ttrang varchar2(1); b_ngay_hl number; b_ngay_kt number; b_ps varchar2(1); b_qdoi number;
    b_loai_khH varchar2(1); b_ma_khH varchar2(20); b_tenH nvarchar2(500); b_nhom varchar2(10);
    b_cmtH varchar2(20); b_mobiH varchar2(20); b_emailH varchar2(20); b_dchiH nvarchar2(400);
    b_ten nvarchar2(500); b_tuoi number; b_so_idP number; b_ma_dk varchar2(10); b_kieu_hd varchar2(1);
    dk_nv pht_type.a_var; dk_phiB pht_type.a_num; a_nv pht_type.a_var;

    dk_maX pht_type.a_var; dk_tenX pht_type.a_nvar; dk_tcX pht_type.a_var; dk_ma_ctX pht_type.a_var;
    dk_ma_dkX pht_type.a_var; dk_ma_dkCX pht_type.a_var; dk_kieuX pht_type.a_var; dk_tienX pht_type.a_num; dk_ptX pht_type.a_num;
    dk_phiX pht_type.a_num; dk_thueX pht_type.a_num; dk_lkeMX pht_type.a_var; dk_lkePX pht_type.a_var; dk_lkeBX pht_type.a_var;
    dk_lh_nvX pht_type.a_var; dk_t_suatX pht_type.a_num; dk_nvX pht_type.a_var; dk_capX pht_type.a_num;
    dk_ptGX pht_type.a_num; dk_phiGX pht_type.a_num; dk_ptBX pht_type.a_num; dk_phiBX pht_type.a_num;

    a_loaiL pht_type.a_var; a_maL pht_type.a_var; a_loi pht_type.a_var;
    a_bien varchar2(50);
begin
-- Dan - Nhap
b_lenh:='loai_ac,mau_ac,ttrang,ngay_hl,ngay_kt,kieu_hd,so_hdl,ma_sp,cdich,goi,';
b_lenh:=b_lenh||'nt_tien,nt_phi,tygia,c_thue,thue,ttoan,';
b_lenh:=b_lenh||'ten,tenc,cmtc,mobic,emailc,dchic,';
b_lenh:=b_lenh||'bien_xe,so_khung,so_may,hang,hieu,pban,';
b_lenh:=b_lenh||'loai_xe,nhom_xe,dong,dco,ttai,so_cn,thang_sx,nam_sx,gia,';
b_lenh:=b_lenh||'md_sd,bh_tbo,ktru,nvb,nvt,nvv';
b_lenh:=FKH_JS_LENH(b_lenh);
EXECUTE IMMEDIATE b_lenh into
    b_loai_ac,b_mau_ac,b_ttrang,b_ngay_hl,b_ngay_kt,b_kieu_hd,b_so_hdL,b_ma_sp,b_cdich,b_goi,
    b_nt_tien,b_nt_phi,b_tygia,b_c_thue,b_thueH,b_ttoanH,
    b_ten,b_tenC,b_cmtC,b_mobiC,b_emailC,b_dchiC,
    b_bien_xe,b_so_khung,b_so_may,b_hang,b_hieu,b_pban,
    b_loai_xe,b_nhom_xe,b_dong,b_dco,b_ttai,b_so_cn,b_thang_sx,b_nam_sx,b_gia,
    b_md_sd,b_bh_tbo,b_ktruC,a_nv(1),a_nv(2),a_nv(3) using dt_ct;
b_so_hdL:=nvl(trim(b_so_hdL),'T');
if b_so_hdL not in('E','P','T') then b_so_hdL:='T'; end if;
if b_ma_sp<>' ' and FBH_2B_SP_HAN(b_ma_sp)<>'C' then b_loi:='loi:Sai ma san pham:loi'; return; end if;
if b_cdich<>' ' and FBH_MA_CDICH_HAN(b_cdich)<>'C' then b_loi:='loi:Het chien dich:loi'; return; end if;
if b_goi<>' ' and FBH_2B_GOI_HAN(b_goi)<>'C' then b_loi:='loi:Ma goi het han:loi'; return; end if;
if trim(b_tenC) is null then
    b_lenh:=FKH_JS_LENH('ten,cmt,mobi,email,dchi');
    EXECUTE IMMEDIATE b_lenh into b_tenC,b_cmtC,b_mobiC,b_emailC,b_dchiC using dt_ct;
end if;
b_tenC:=nvl(trim(b_tenC),' '); b_tenC:=nvl(trim(b_tenC),' '); b_cmtC:=nvl(trim(b_cmtC),' ');
b_mobiC:=nvl(trim(b_mobiC),' '); b_emailC:=nvl(trim(b_emailC),' '); b_dchiC:=nvl(trim(b_dchiC),' ');
b_bien_xe:=nvl(trim(b_bien_xe),' '); b_so_khung:=nvl(trim(b_so_khung),' '); b_so_may:=nvl(trim(b_so_may),' ');
b_hang:=PKH_MA_TENl(b_hang); b_hieu:=PKH_MA_TENl(b_hieu); b_pban:=PKH_MA_TENl(b_pban); b_nam_sx:=nvl(b_nam_sx,0);

PBH_2B_BPHI_TSO(
    dt_ct,b_nhom,b_nv_bh,b_bh_tbo,b_md_sd,b_ma_sp,b_cdich,b_goi,b_loai_xe,b_nhom_xe,
    b_dong,b_dco,b_ttai,b_so_cn,b_tuoi,b_gia,b_ngay_hl,b_ngay_kt,b_ngay_hl,b_loi);
if b_bien_xe=' ' and b_so_khung=' ' and b_so_may=' ' then
    b_loi:='loi:Nhap bien xe, so khung, so may:loi'; return;
end if;
if b_hang<>' ' and FBH_2B_HANG_HAN(b_hang)<>'C' then b_loi:='loi:Sai hang xe:loi'; return; end if;
if b_hang<>' ' and b_hieu<>' ' and FBH_2B_HIEU_HAN(b_hang,b_hieu)<>'C' then b_loi:='loi:Sai hieu xe:loi'; return; end if;
if b_hang<>' ' and b_hieu<>' ' and b_pban<>' ' and FBH_2B_PB_HAN(b_hang,b_hieu,b_pban)<>'C' then
    b_loi:='loi:Sai phien ban xe:loi'; return;
end if;
if b_dong<>' ' and FBH_2B_DONG_HAN(b_dong)<>'C' then b_loi:='loi:Sai dong xe:loi'; return; end if;
if b_dco not in(' ','X','D','E','H') then b_loi:='loi:Sai loai dong co:loi'; return; end if;
if b_loai_xe<>' ' and FBH_2B_LOAI_HAN(b_loai_xe)<>'C' then b_loi:='loi:Sai loai xe:loi'; return; end if;
if b_nhom_xe<>' ' and FBH_2B_NHOM_HAN(b_nhom_xe)<>'C' then b_loi:='loi:Sai nhom xe:loi'; return; end if;
b_so_idPc:=''; b_ktru:=PKH_LOC_CHU_SO(PKH_TEN_TENl(b_ktruC),'F','T');
b_nt_tien:=nvl(trim(b_nt_tien),'VND'); b_nt_phi:=nvl(trim(b_nt_phi),'VND');
if b_nt_phi<>'VND' then b_tp:=2; end if;
if b_bien_xe<>' ' then
    a_bien:=b_bien_xe;
elsif b_so_khung<>' ' then
    a_bien:=b_so_khung;
elsif b_so_may<>' ' then
    a_bien:=b_so_may;
else b_loi:='loi:Nhap bien xe, so khung:loi'; return;
end if;
b_lenh:=FKH_JS_LENH('nv,ma,ten,tc,ma_ct,kieu,tien,pt,phi,thue,cap,ma_dk,ma_dkc,lh_nv,t_suat,ptb,phib,lkem,lkep,lkeb');
EXECUTE IMMEDIATE b_lenh bulk collect into
    dk_nv,dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_thue,dk_cap,
    dk_ma_dk,dk_ma_dkC,dk_lh_nv,dk_t_suat,dk_ptB,dk_phiB,dk_lkeM,dk_lkeP,dk_lkeB using dt_dk;
b_kt:=dk_ma.count; b_ktG:=b_kt;
if b_kt=0 then b_loi:='loi:Nhap dieu khoan:loi'; return; end if;
for b_lp in 1..dk_ma.count loop
    dk_bt(b_lp):=b_lp; dk_lh_bh(b_lp):='C';
end loop;
EXECUTE IMMEDIATE b_lenh bulk collect into
    dk_nvX,dk_maX,dk_tenX,dk_tcX,dk_ma_ctX,dk_kieuX,dk_tienX,dk_ptX,dk_phiX,dk_thueX,dk_capX,
    dk_ma_dkX,dk_ma_dkCX,dk_lh_nvX,dk_t_suatX,dk_ptBX,dk_phiBX,dk_lkeMX,dk_lkePX,dk_lkeBX using dt_dkbs;
for b_lp in 1..dk_maX.count loop
    b_kt:=b_kt+1;
    dk_bt(b_kt):=b_lp+10000;
    -- chuclh - dieu khoan bo sung dk_kieu, dk_lh_bh
    dk_nv(b_kt):='M'; dk_kieu(b_kt):=''; dk_ma(b_kt):=dk_maX(b_lp); dk_ten(b_kt):=dk_tenX(b_lp);
    dk_tc(b_kt):=dk_tcX(b_lp); dk_ma_ct(b_kt):=dk_ma_ctX(b_lp); dk_tien(b_kt):=dk_tienX(b_lp);
    dk_pt(b_kt):=dk_ptX(b_lp); dk_phi(b_kt):=dk_phiX(b_lp); dk_thue(b_kt):=dk_thueX(b_lp);
    dk_cap(b_kt):=dk_capX(b_lp); dk_ma_dk(b_kt):=dk_ma_dkX(b_lp); dk_ma_dkC(b_kt):=dk_ma_dkCX(b_lp); dk_lh_nv(b_kt):=dk_lh_nvX(b_lp);
    dk_t_suat(b_kt):=dk_t_suatX(b_lp); dk_ptB(b_kt):=dk_ptBX(b_lp); dk_phiB(b_kt):=dk_phiBX(b_lp);
    dk_lkeM(b_kt):=dk_lkeMX(b_lp);
    dk_lkeP(b_kt):=dk_lkePX(b_lp); dk_lkeB(b_kt):=dk_lkeBX(b_lp); dk_lh_bh(b_kt):='M';
end loop;
for b_lp in 1..dk_ma.count loop
    dk_nv(b_lp):=nvl(trim(dk_nv(b_lp)),' '); dk_ma(b_lp):=trim(dk_ma(b_lp));
    if dk_ma(b_lp) is null then b_loi:='loi:Loi nhap chi tiet nghiep vu dong '||to_char(b_lp)||':loi'; return; end if;
    dk_lh_nv(b_lp):=nvl(trim(dk_lh_nv(b_lp)),' '); dk_tien(b_lp):=nvl(dk_tien(b_lp),0);
    dk_phi(b_lp):=nvl(dk_phi(b_lp),0); dk_phiB(b_lp):=nvl(dk_phiB(b_lp),0);
    if b_c_thue='K' then dk_thue(b_lp):=0; else dk_thue(b_lp):=nvl(dk_thue(b_lp),0); end if;
    dk_ttoan(b_lp):=dk_phi(b_lp)+dk_thue(b_lp);
    if dk_tien(b_lp)<>0 then
      b_i1:=round(dk_phiB(b_lp)/dk_tien(b_lp)*100,4);
      dk_pt(b_lp):= b_i1 - round((dk_phiB(b_lp)-dk_phi(b_lp))/dk_tien(b_lp)*100 ,4);
    elsif dk_tien(b_lp)=0 and dk_nv(b_lp)='V' and dk_lh_bh(b_lp)='M' then -- viet anh -- them case tinh lai pt dkbs di theo dk chinh (vcx)
      b_i2:=FKH_ARR_VTRI(dk_ma_dk,dk_ma_dkC(b_lp));
      if b_i2 > 0 and dk_tien(b_i2)<>0 then
         b_i1:=round(dk_phiB(b_lp)/dk_tien(b_i2)*100,4);
         dk_pt(b_lp):= b_i1 - round((dk_phiB(b_lp)-dk_phi(b_lp))/dk_tien(b_i2)*100 ,4);
      end if; 
    end if;
end loop;
for b_lp in 1..dk_maX.count loop
    b_ma_dk:=FBH_MA_DKBS_MA_DK(dk_ma_dkX(b_lp));
    if b_ma_dk<>' ' then
        b_i1:=FKH_ARR_VTRI(dk_ma_dk,b_ma_dk);
        if b_i1 not between 1 and b_ktG then
            b_loi:='loi:Dieu khoan bo sung '||dk_ma_dkX(b_lp)||' phai gan kem dieu khoan chinh '||b_ma_dk||' - ' ||a_bien|| ':loi'; return;
        end if;
    end if;
end loop;
b_nv_bh:='';
for b_lp in 1..3 loop
    a_nv(b_lp):=nvl(trim(a_nv(b_lp)),' ');
    if a_nv(b_lp)='C' then
        a_nv(b_lp):=substr('BTV',b_lp,1);
        PKH_GHEP(b_nv_bh,a_nv(b_lp),'');
    else
        a_nv(b_lp):=' ';
    end if;
end loop;
-- viet anh
b_tuoi:=FBH_2B_TUOIt(b_thang_sx,b_nam_sx);
if b_nv_bh is null then b_loi:='loi:Chua chon loai phi mua:loi'; return; end if;
for b_lp1 in 1..3 loop
    if a_nv(b_lp1)<>' ' then
        FBH_2B_BPHI_SO_ID('G',a_nv(b_lp1),'C',b_md_sd,b_ma_sp,b_cdich,b_goi,b_loai_xe,
            b_nhom_xe,b_dong,b_dco,b_ttai,b_so_cn,b_tuoi,b_gia,b_ngay_hl,b_so_idP,b_loi);
        if b_loi is not null then return; end if;
        if b_so_idP=0 then
            if b_lp1=1 then b_loi:='Bat buoc';
            elsif b_lp1=2 then b_loi:='Tu nguyen';
            else b_loi:='Vat chat';
            end if;
            b_loi:='loi:Khong co bieu phi '||b_loi||':loi'; return;
        end if;
        PKH_GHEP(b_so_idPc,to_char(b_so_idP));
        for b_lp in 1..dk_ma.count loop
            if dk_nv(b_lp)=a_nv(b_lp1) then
                if dk_lkeP(b_lp)= 'M' then
                    if dk_tien(b_lp)=0 then b_loi:='loi:Chua nhap muc trach nhiem '||dk_ma(b_lp)||':loi'; return; end if;
                    FBH_2B_BPHI_DKm(b_so_idP,dk_ma(b_lp),dk_tien(b_lp),dk_lh_bh(b_lp),dk_ptB(b_lp),dk_phiB(b_lp),b_loi);
                    if b_loi is not null then return; end if;
                end if;
            end if;
        end loop;
    end if;
end loop;
PBH_HD_THAY_PHIg(b_nt_tien,b_nt_tien,b_tygia,b_thueH,b_ttoanH,dk_lh_nv,dk_tien,dk_phi,dk_thue,dk_ttoan,b_loi);
if b_loi is not null then return; end if;
for b_lp in 1..dk_ma.count loop
  -- viet anh -- them dieu kien lkeM <> 'C,K' -- dieu chinh logic theo cong
    if dk_tien(b_lp)=0 and dk_lkeM(b_lp) not in('C','K') and b_ttrang in('T','D') then
        b_loi:='loi:Chua nhap muc trach nhiem '||dk_ma(b_lp)||':loi'; return;
    end if;
    if dk_phiB(b_lp)>dk_phi(b_lp) then
        dk_phiG(b_lp):=dk_phiB(b_lp)-dk_phi(b_lp);
        dk_ptG(b_lp):=round(dk_phiG(b_lp)*100/dk_phiB(b_lp),2);
    else
        dk_ptG(b_lp):=0; dk_phiG(b_lp):=0;
    end if;
end loop;
b_xe_id:=FBH_2Btso_SO_ID(b_bien_xe,b_so_khung);
if b_xe_id<>0 then
    for r_lp in(select distinct nv_bh from bh_2b_ds where xe_id=b_xe_id and so_id_dt<>b_so_idD and
        FKH_GIAO(b_ngay_hl,b_ngay_kt,ngay_hl,ngay_kt)='C' and FBH_2B_TTRANG(ma_dvi,so_id,'C')='D') loop
        b_nv_bhC:=r_lp.nv_bh; b_i1:=length(b_nv_bhC);
        for b_lp in 1..b_i1 loop
            if instr(b_nv_bh,substr(b_nv_bhC,b_lp,1))<>0 then b_loi:='loi:Trung thoi gian bao hiem:loi'; return; end if;
        end loop;
    end loop;
else
    PHT_ID_MOI(b_xe_id,b_loi);
    if b_loi is not null then return; end if;
end if;
-- viet anh -- sinh so GCN dien tu
if b_so_hdL='E' and b_kieu_hd<>'S' and instr(b_nv_bh,'B')<>0 and b_ttrang='D' then
    PBH_2B_VACH('2B',b_so_hd,b_loi);
    if b_loi is not null then return; end if;
    if trim(b_so_hd) is null then b_loi:='loi:Khong xin duoc so GCN:loi'; return; end if;
elsif b_so_hdL='P' and b_ttrang='D' then
    PBH_LAY_SOAC(b_ma_dvi,b_loai_ac,b_mau_ac,b_so_hd,b_loi);
    if b_loi is not null then return; end if;
    if trim(b_so_hd) is null then b_loi:='loi:Khong lay duoc so an chi:loi'; return; end if;
    if FBH_2B_SO_ID(b_ma_dvi,b_so_hd) > 0 then b_loi:='loi:So an chi da su dung '||b_so_hd||':loi'; return; end if;
    PKH_JS_THAY(dt_ct,'gcn',b_so_hd);
end if;
b_ng_huong:='';
if b_ttrang in('T','D') then
    b_lenh:=FKH_JS_LENH('loai_khh,tenh,dchih,cmth,mobih,emailh');
    EXECUTE IMMEDIATE b_lenh into b_loai_khH,b_tenH,b_dchiH,b_cmtH,b_mobiH,b_emailH using dt_ct;
    if trim(b_tenH) is not null then
        select json_object('loai' value b_loai_khH,'ten' value b_tenH,'cmt' value b_cmtH,
            'dchi' value b_dchiH,'mobi' value b_mobiH,'email' value b_emailH) into b_txt from dual;
        PBH_DTAC_MA_NH(b_txt,b_ma_khH,b_loi,b_ma_dvi,b_nsd);
        b_ng_huong:=b_tenH;
        if trim(b_cmtH) is not null then
            if b_loai_khH='C' then
                b_ng_huong:=b_tenH||', so CMT/CCCD: '||b_cmtH;
            else
                b_ng_huong:=b_tenH||', ma thue : '||b_cmtH;
            end if;
        end if;
        if trim(b_dchiH) is not null then
            b_ng_huong:=b_tenH||', dia chi: '||b_dchiH;
        end if;
    end if;
    if b_tenC<>' ' and b_tenC<>b_ten and trim(b_cmtC||b_mobiC||b_emailC) is not null then
        select json_object('loai' value 'C','ten' value b_tenC,'cmt' value b_cmtC,
            'dchi' value b_dchiC,'mobi' value b_mobiC,'email' value b_emailC) into b_txt from dual;
        PBH_DTAC_MA_NH(b_txt,b_ma_khH,b_loi,b_ma_dvi,b_nsd);
        if b_ma_khH not in(' ','VANGLAI') then PKH_JS_THAY(dt_ct,'ma_khc',b_ma_khH); end if;
    end if;
    select count(*) into b_i1 from bh_2b_phi_txt where so_id=b_so_idP and loai='dt_khd';
    if b_i1<>0 then
        select txt into dt_khd from bh_2b_phi_txt where so_id=b_so_idP and loai='dt_khd';
        b_i1:=length(dt_khd)-2;
        dt_khd:=substr(dt_khd,2,b_i1);
        PBH_2BG_KHD(dt_ct,dt_dk,dt_khd,b_loi);
        if b_loi is not null then return; end if;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
--duchq luu dt_lt va dt_kbt trong txt
create or replace procedure PBH_2BG_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    dt_ct in out clob,dt_dk clob,dt_dkbs clob,dt_lt clob,dt_kbt in out clob,dt_hu clob,dt_ttt clob,
-- Chung
    b_so_hd in out varchar2,b_ngay_ht number,b_ttrang varchar2,b_kieu_hd varchar2,b_so_hd_g varchar2,
    b_kieu_kt varchar2,b_ma_kt varchar2,b_kieu_gt varchar2,b_ma_gt varchar2,b_ma_cb varchar2,
    b_so_hdL varchar2,b_loai_kh varchar2,b_ma_kh varchar2,b_ten nvarchar2,b_dchi nvarchar2,
    b_cmt varchar2,b_mobi varchar2,b_email varchar2,
    b_gio_hl varchar2,b_ngay_hl number,b_gio_kt varchar2,b_ngay_kt number,b_ngay_cap number,
    b_nt_tien varchar2,b_nt_phi varchar2,b_c_thue varchar2,
    b_phi number,b_giam number,b_thue number,b_ttoan number,b_hhong number,
    b_so_idG number,b_so_idD number,b_ngayD number,b_phong varchar2,
    tt_ngay pht_type.a_num,tt_tien pht_type.a_num,
-- Rieng
    b_ma_sp varchar2,b_cdich varchar2,b_goi varchar2,
    b_tenC nvarchar2,b_cmtC varchar2,b_mobiC varchar2,
    b_emailC varchar2,b_dchiC nvarchar2,b_ng_huong nvarchar2,
    b_bien_xe varchar2,b_so_khung varchar2,b_so_may varchar2,
    b_hang varchar2,b_hieu varchar2,b_pban varchar2,
    b_loai_xe varchar2,b_nhom_xe varchar2,b_dong varchar2,
    b_dco varchar2,b_ttai number,b_so_cn number,b_nam_sx number,b_gia number,
    b_md_sd varchar2,b_nv_bh varchar2,b_bh_tbo varchar2,b_ktru number,b_so_idP varchar2,b_xe_id number,

    dk_bt pht_type.a_num,dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tc pht_type.a_var,
    dk_ma_ct pht_type.a_var,dk_kieu pht_type.a_var,
    dk_tien pht_type.a_num,dk_pt pht_type.a_num,dk_phi pht_type.a_num,
    dk_thue pht_type.a_num,dk_ttoan pht_type.a_num,
    dk_cap pht_type.a_num,dk_ma_dk pht_type.a_var,
    dk_lh_nv pht_type.a_var,dk_t_suat pht_type.a_num,dk_ptB pht_type.a_num,
    dk_ptG pht_type.a_num,dk_phiG pht_type.a_num,dk_lkeP pht_type.a_var,dk_lkeB pht_type.a_var,dk_lh_bh pht_type.a_var,b_loi out varchar2)
AS
    b_i1 number; b_so_id_kt number:=-1; b_tien number:=0; b_ma_ke varchar2(20):=' '; b_txt clob;
begin
-- Dan - Nhap
b_loi:='loi:Loi Table bh_xe:loi';
if b_ttrang='D' then b_so_id_kt:=0; end if;
for b_lp in 1..dk_lh_nv.count loop
    if dk_lh_nv(b_lp)<>' ' and dk_kieu(b_lp)='T' then b_tien:=b_tien+dk_tien(b_lp); end if;
    insert into bh_2b_dk values(b_ma_dvi,b_so_id,b_so_idD,dk_bt(b_lp),
        dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),dk_kieu(b_lp),
        dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),dk_cap(b_lp),dk_ma_dk(b_lp),
        dk_lh_nv(b_lp),dk_t_suat(b_lp),dk_thue(b_lp),dk_ttoan(b_lp),
        dk_ptB(b_lp),dk_ptG(b_lp),dk_phiG(b_lp),dk_lkeP(b_lp),dk_lkeB(b_lp),dk_lh_bh(b_lp));
end loop;
insert into bh_2b values(
    b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,'G',b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
    b_phong,b_so_hdL,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,
    b_nt_tien,b_nt_phi,b_c_thue,1,b_tien,
    b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,'','',b_so_id_kt,b_nsd,sysdate);
insert into bh_2b_ds values(b_ma_dvi,b_so_id,b_so_idD,0,b_kieu_hd,b_so_hd,b_so_hd_g,
    b_tenC,b_cmtC,b_mobiC,b_emailC,b_dchiC,b_ng_huong,
    b_bien_xe,b_so_khung,b_so_may,b_hang,b_hieu,b_pban,
    b_loai_xe,b_nhom_xe,b_dong,b_dco,b_ttai,b_so_cn,b_nam_sx,b_gia,
    b_md_sd,b_nv_bh,b_bh_tbo,b_ma_sp,b_cdich,b_goi,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_giam,b_phi,b_thue,b_ttoan,b_so_idP,b_xe_id);
delete bh_2b_ID where xe_id=b_xe_id;
insert into bh_2b_ID values(b_xe_id,b_tenC,b_cmtC,b_mobiC,b_emailC,b_dchiC,
    b_bien_xe,b_so_khung,b_so_may,b_hang,b_hieu,b_pban,
    b_loai_xe,b_nhom_xe,b_dong,b_dco,b_ttai,b_so_cn,b_nam_sx,b_gia);
for b_lp in 1..tt_ngay.count loop
    insert into bh_2b_tt values(b_ma_dvi,b_so_id,tt_ngay(b_lp),tt_tien(b_lp));
end loop;
PKH_JS_THAYa(dt_ct,'so_hd,ma_kh',b_so_hd||','||b_ma_kh);
insert into bh_2b_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
insert into bh_2b_txt values(b_ma_dvi,b_so_id,'dt_dk',dt_dk);
if trim(dt_lt) is not null then
    insert into bh_2b_txt values(b_ma_dvi,b_so_id,'dt_lt',dt_lt);
end if;
if trim(dt_kbt) is not null then
    insert into bh_2b_txt values(b_ma_dvi,b_so_id,'dt_kbt',dt_kbt);
end if;
if trim(dt_dkbs) is not null then
    insert into bh_2b_txt values(b_ma_dvi,b_so_id,'dt_dkbs',dt_dkbs);
end if;
if trim(dt_hu) is not null and dt_hu<>'[""]' then
    insert into bh_2b_txt values(b_ma_dvi,b_so_id,'dt_hu',dt_hu);
end if;
if dt_ttt is not null then
    insert into bh_2b_txt values(b_ma_dvi,b_so_id,'dt_ttt',dt_ttt);
end if;
if b_ttrang in('T','D') then
  if b_ktru<>0 then
    PBH_2BG_KBT(b_nv_bh,b_so_idP,b_ktru,dt_kbt,b_loi);
      if b_loi is not null then return; end if;
  end if;
    if dt_dkbs is null then
        b_txt:=dt_dk;
    else
        b_i1:=length(dt_dk)-1;
        b_txt:=substr(dt_dk,1,b_i1)||','||substr(dt_dkbs,2);
    end if;
    insert into bh_2b_kbt values(b_ma_dvi,b_so_id,b_so_idD,b_txt,dt_lt,dt_kbt);
    select json_object('ma_dvi' value b_ma_dvi,'nsd' value b_nsd,'so_id' value b_so_id,'so_hd' value b_so_hd,
        'kieu_hd' value b_kieu_hd,'nv' value '2B','ngay_ht' value b_ngay_ht,'ngay_cap' value b_ngay_cap,
        'ngay_hl' value b_ngay_hl,'ngay_kt' value b_ngay_kt,'cb_ql' value b_ma_cb,'phong' value b_phong,
        'kieu_kt' value b_kieu_kt,'ma_kt' value b_ma_kt,'dly_tke' value ' ','hhong' value b_hhong,
        'pt_hhong' value 'D','ma_kh' value b_ma_kh,'ten' value b_ten,'kieu_gt' value b_kieu_gt,
        'ma_gt' value b_ma_gt,'so_id_d' value b_so_idD,'so_id_g' value b_so_idG,'ttrang' value b_ttrang,
        'dvi_ksoat' value b_ma_dvi,'ksoat' value b_nsd,'bangg' value 'bh_2b',
        'c_thue' value b_c_thue,'nt_tien' value b_nt_tien,'nt_phi' value b_nt_phi,'tien' value b_tien,
        'phi' value b_ttoan-b_thue,'thue' value b_thue returning clob) into b_txt from dual;
    PBH_HD_GOC_NH(b_txt,b_loi);
    if b_loi is not null then return; end if;
end if;
if b_ttrang='D' then
   if b_so_hdL='P' then
        PBH_2B_DON(b_ma_dvi,b_so_id,'N',b_loi);
        if b_loi is not null then return; end if;
    end if;
    PBH_KE_CTI_NHOM(b_ma_dvi,b_so_idD,b_so_idD,b_ma_ke,b_loi);
    if b_loi is null then return; end if;
    insert into bh_hd_goc_ttindt values(
        b_ma_dvi,b_so_idD,b_so_idD,'2B',b_bien_xe||' -- '||b_so_khung,b_ma_kh,b_ngay_kt,' ',b_ma_ke);
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_2BG_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(3000); b_lenh varchar2(2000); b_i1 number;
    dt_ct clob; dt_dk clob; dt_lt clob; dt_kbt clob; dt_hu clob; dt_kytt clob; dt_dkbs clob; dt_ttt clob;
-- Chung
    b_so_id number; b_so_hd varchar2(20); b_ngay_ht number; b_ttrang varchar2(1); b_kieu_hd varchar2(1); b_so_hd_g varchar2(20);
    b_kieu_kt varchar2(1); b_ma_kt varchar2(20); b_kieu_gt varchar2(1); b_ma_gt varchar2(20); b_ma_cb varchar2(20);
    b_loai_kh varchar2(1); b_ma_kh varchar2(20); b_ten nvarchar2(500); b_dchi nvarchar2(500);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_gio_hl varchar2(20); b_ngay_hl number; b_gio_kt varchar2(20); b_ngay_kt number; b_ngay_cap number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_c_thue varchar2(1);
    b_tl_giam number; b_phi number; b_giam number; b_thue number; b_ttoan number; b_hhong number;
    b_so_idG number; b_so_idD number; b_ngayD number; b_phong varchar2(10);
    tt_ngay pht_type.a_num; tt_tien pht_type.a_num;
-- Rieng
    b_so_hdL varchar2(1); b_so_hdN varchar2(20); b_ng_huong nvarchar2(500);
    b_ma_sp varchar2(10); b_cdich varchar2(10); b_goi varchar2(10);
    b_tenC nvarchar2(500); b_cmtC varchar2(100); b_mobiC varchar2(20); b_emailC varchar2(100); b_dchiC nvarchar2(500);
    b_bien_xe varchar2(30); b_so_khung varchar2(30); b_so_may varchar2(30);
    b_hang varchar2(20); b_hieu varchar2(20); b_pban varchar2(20);
    b_loai_xe varchar2(500); b_nhom_xe varchar2(500); b_dong varchar2(500);
    b_dco varchar2(1); b_ttai number; b_so_cn number; b_thang_sx number; b_nam_sx number; b_gia number;
    b_md_sd varchar2(500); b_nv_bh varchar2(10); b_bh_tbo varchar2(1); b_ktru number; b_so_idP varchar2(100); b_xe_id number;

    dk_bt pht_type.a_num; dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var;
    dk_ma_ct pht_type.a_var; dk_kieu pht_type.a_var;
    dk_tien pht_type.a_num; dk_pt pht_type.a_num; dk_phi pht_type.a_num;
    dk_thue pht_type.a_num; dk_ttoan pht_type.a_num;
    dk_cap pht_type.a_num; dk_ma_dk pht_type.a_var; dk_ma_dkC pht_type.a_var;
    dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num; dk_ptB pht_type.a_num;
    dk_ptG pht_type.a_num; dk_phiG pht_type.a_num; dk_lkeM pht_type.a_var; dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var; dk_lh_bh pht_type.a_var;
-- Xu ly
    b_ngay_htC number;
begin
-- Dan - Nhap
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','2B','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_lt,dt_kbt,dt_hu,dt_kytt,dt_dkbs,dt_ttt');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_lt,dt_kbt,dt_hu,dt_kytt,dt_dkbs,dt_ttt using b_oraIn;
--duchq them check null
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_lt); FKH_JSa_NULL(dt_kbt);
FKH_JSa_NULL(dt_hu); FKH_JSa_NULL(dt_kytt); FKH_JSa_NULL(dt_dkbs); FKH_JSa_NULL(dt_ttt);
if b_so_id<>0 then
    select count(*) into b_i1 from bh_2b where so_id=b_so_id;
    if b_i1<>0 then
        select ngay_ht,kieu_hd,ttrang into b_ngay_htC,b_kieu_hd,b_ttrang from bh_2b
            where so_id=b_so_id for update nowait;
        if sql%rowcount=0 then b_loi:='loi:Va cham NSD:loi'; raise PROGRAM_ERROR; end if;
        if b_ttrang not in('T','D') then b_kieu_hd:='X'; else b_kieu_hd:='N'; end if;
        PBH_2B_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_kieu_hd,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
else
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_HD_JS_TEST(
    b_ma_dvi,b_nsd,b_so_id,b_ngay_htC,'bh_2b',dt_ct,dt_kytt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_loai_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,
    b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_ngayD,b_phong,b_ma_cb,b_ma_kh,
    tt_ngay,tt_tien,b_loi,'2B');
if b_loi is not null then raise PROGRAM_ERROR; end if;
-- viet anh
PBH_2BG_TESTr(
    b_ma_dvi,b_nsd,b_so_idD,dt_ct,dt_dk,dt_dkbs,
    b_so_hd,b_so_hdL,b_ma_sp,b_cdich,b_goi,b_tenC,b_cmtC,b_mobiC,b_emailC,b_dchiC,b_ng_huong,
    b_bien_xe,b_so_khung,b_so_may,b_hang,b_hieu,b_pban,b_loai_xe,b_nhom_xe,b_dong,
    b_dco,b_ttai,b_so_cn,b_thang_sx,b_nam_sx,b_gia,b_md_sd,b_nv_bh,b_bh_tbo,b_ktru,b_so_idP,b_xe_id,
    dk_bt,dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,
    dk_cap,dk_ma_dk,dk_ma_dkC,dk_lh_nv,dk_t_suat,dk_ptB,dk_ptG,dk_phiG,dk_lkeM,dk_lkeP,dk_lkeB,dk_lh_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_2BG_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,dt_ct,dt_dk,dt_dkbs,dt_lt,dt_kbt,dt_hu,dt_ttt,
-- Chung
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,b_so_hdL,
    b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,
    b_nt_tien,b_nt_phi,b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_ngayD,b_phong,
    tt_ngay,tt_tien,
-- Rieng
    b_ma_sp,b_cdich,b_goi,b_tenC,b_cmtC,b_mobiC,b_emailC,b_dchiC,b_ng_huong,
    b_bien_xe,b_so_khung,b_so_may,b_hang,b_hieu,b_pban,b_loai_xe,b_nhom_xe,
    b_dong,b_dco,b_ttai,b_so_cn,b_nam_sx,b_gia,b_md_sd,b_nv_bh,b_bh_tbo,b_ktru,b_so_idP,b_xe_id,
    dk_bt,dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,
    dk_cap,dk_ma_dk,dk_lh_nv,dk_t_suat,dk_ptB,dk_ptG,dk_phiG,dk_lkeP,dk_lkeB,dk_lh_bh,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hd' value b_so_hd, 'ma_kh' value b_ma_kh) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_2B_BPHI_CTs(
    dt_ct clob,b_nv out varchar2,b_so_idS out varchar2,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_so_id number;
    b_nhom varchar2(1); b_nv_bh varchar2(10); b_bh_tbo varchar2(1); b_md_sd varchar2(500);
    b_ma_sp varchar2(10); b_cdich varchar2(10); b_goi varchar2(10);
    b_loai_xe varchar2(500); b_nhom_xe varchar2(500); b_dong varchar2(500); b_dco varchar2(500);
    b_ttai number; b_so_cn number; b_tuoi number; b_gia number; b_thang_sx number; b_nam_sx number;
    b_ngay_bd number; b_ngay_kt number; b_ngay_hl number;
    a_nv pht_type.a_var;
begin
  -- Dan - Tra so ID
b_nv:=''; b_so_idS:='';
PBH_2B_BPHI_TSO(
    dt_ct,b_nhom,b_nv_bh,b_bh_tbo,b_md_sd,b_ma_sp,b_cdich,b_goi,b_loai_xe,b_nhom_xe,
    b_dong,b_dco,b_ttai,b_so_cn,b_tuoi,b_gia,b_ngay_bd,b_ngay_kt,b_ngay_hl,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi xu ly FBH_2B_BPHI_CTs:loi';
b_lenh:=FKH_JS_LENH('nvb,nvt,nvv,nam_sx,thang_sx');
EXECUTE IMMEDIATE b_lenh into a_nv(1),a_nv(2),a_nv(3),b_nam_sx,b_thang_sx using dt_ct;
b_tuoi:=FBH_2B_TUOIt(b_thang_sx,b_nam_sx);
for b_lp in 1..3 loop
    if nvl(trim(a_nv(b_lp)),' ')='C' then
        if b_lp=1 then a_nv(b_lp):='B';
        elsif b_lp=2 then a_nv(b_lp):='T';
        elsif b_lp=3 then a_nv(b_lp):='V';
        end if;
        FBH_2B_BPHI_SO_ID(
            b_nhom,a_nv(b_lp),b_bh_tbo,b_md_sd,b_ma_sp,b_cdich,b_goi,b_loai_xe,
            b_nhom_xe,b_dong,b_dco,b_ttai,b_so_cn,b_tuoi,b_gia,b_ngay_bd,b_so_id,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
        if b_so_id=0 then
      b_nv:=a_nv(b_lp); b_so_idS:='0'; exit;
    else
      if b_nv is not null then b_nv:=b_nv||','; b_so_idS:=b_so_idS||','; end if;
      b_nv:=b_nv||a_nv(b_lp); b_so_idS:=b_so_idS||to_char(b_so_id);
    end if;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
