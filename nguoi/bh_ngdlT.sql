create or replace procedure PBH_NGDLT_MOg(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_ngay number:=PKH_NG_CSO(sysdate);
    cs_kvuc clob; cs_sp clob; cs_cdich clob; cs_goi clob;cs_ttt clob; cs_khd clob; cs_kbt clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ten) into cs_kvuc from bh_ngdl_kvuc where FBH_NGDL_KVUC_HAN(ma)='C';
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten) into cs_sp from
    bh_ngdl_sp a,(select distinct ma_sp from bh_ngdl_phi where nhom='T' and ngay_bd<=b_ngay and ngay_kt>b_ngay) b
    where a.ma=b.ma_sp and FBH_NGDL_SP_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten) into cs_cdich from
    bh_ma_cdich a,(select distinct cdich from bh_ngdl_phi where nhom='T' and ngay_bd<=b_ngay and ngay_kt>b_ngay) b
    where a.ma=b.cdich and FBH_MA_NV_CO(nv,'NG')='C' and FBH_MA_CDICH_HAN(cdich)='C';
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ma) into cs_goi from
    bh_ngdl_goi a,(select distinct goi from bh_ngdl_phi where nhom='T' and FBH_NGDL_SP_HAN(ma_sp)='C' and b_ngay between ngay_bd and ngay_kt) b
    where a.ma=b.goi;
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_ttt
    from bh_kh_ttt where ps='HD' and nv='NG';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt) into cs_khd from bh_kh_ttt where ps='KHD' and FBH_MA_NV_CO(nv,'NG')='C';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt) into cs_kbt from bh_kh_ttt where ps='KBT' and FBH_MA_NV_CO(nv,'NG')='C';
select json_object('cs_kvuc' value cs_kvuc,'cs_sp' value cs_sp,
    'cs_cdich' value cs_cdich,'cs_goi' value cs_goi,'cs_ttt' value cs_ttt,'cs_khd' value cs_khd,'cs_kbt' value cs_kbt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGDLT_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number;
    dt_ct clob; dt_nh clob:=''; dt_giam clob:=''; dt_ds clob:=''; dt_kytt clob:=''; dt_txt clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
select json_object(so_hd,ma_kh returning clob) into dt_ct from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(NHOM,ten,phi,so_dt,phiN,tl_giam,giam,ttoan) order by bt returning clob) into dt_giam from bh_ngdl_nh where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(so_id_dt,gcn,gcn_g,kieu_gcn,cmt) order by bt returning clob) into dt_ds from bh_ngdl_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ngay,tien) order by ngay) into dt_kytt from bh_ngdl_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai<>'dt_nh';
select count(*) into b_i1 from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_nh';
if b_i1=1 then
    select txt into dt_nh from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_nh';
end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'dt_nh' value dt_nh,'dt_ct' value dt_ct,
    'dt_giam' value dt_giam,'dt_ds' value dt_ds,'dt_kytt' value dt_kytt,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGDLT_TESTr(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_idG number,
    nh_so_idC pht_type.a_num,nh_nhomC pht_type.a_var,
    dt_ct clob,dt_giam clob,dt_nh clob,dt_ds in out clob,

    nh_so_id out pht_type.a_num,nh_nhom out pht_type.a_var,nh_ten out pht_type.a_nvar,
    nh_loai out pht_type.a_var,nh_kvuc out pht_type.a_var,nh_ma_sp out pht_type.a_var,nh_cdich out pht_type.a_var,
    nh_goi out pht_type.a_var,nh_so_idP out pht_type.a_num,
    nh_ngay_hl out pht_type.a_num,nh_ngay_kt out pht_type.a_num,nh_ma_chuyen out pht_type.a_var,
    nh_phi out pht_type.a_num,nh_so_dt out pht_type.a_num,nh_phiN out pht_type.a_num,
    nh_tl_giam out pht_type.a_num,nh_giam out pht_type.a_num,nh_ttoan out pht_type.a_num,

    gcn_so_id out pht_type.a_num,gcn_kieu_gcn out pht_type.a_var,
    gcn_gcn out pht_type.a_var,gcn_gcnG out pht_type.a_var,
    gcn_nhom out pht_type.a_var,gcn_ma_sp out pht_type.a_var,gcn_ma_kh out pht_type.a_var,
    gcn_ten out pht_type.a_nvar,gcn_ng_sinh out pht_type.a_num,gcn_gioi out pht_type.a_var,
    gcn_cmt out pht_type.a_var,gcn_mobi out pht_type.a_var,gcn_email out pht_type.a_var,
    gcn_dchi out pht_type.a_nvar,gcn_ng_huong out pht_type.a_nvar,gcn_ngay_hl out pht_type.a_num,
    gcn_ngay_kt out pht_type.a_num,
    gcn_phi out pht_type.a_num,gcn_giam out pht_type.a_num,gcn_ttoan out pht_type.a_num,

    dk_so_id out pht_type.a_num,dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,
    dk_tc out pht_type.a_var,dk_ma_ct out pht_type.a_var,dk_kieu out pht_type.a_var, dk_bt out pht_type.a_num,
    dk_tien out pht_type.a_num,dk_pt out pht_type.a_num,dk_phi out pht_type.a_num,
    dk_thue out pht_type.a_num,dk_ttoan out pht_type.a_num,
    dk_cap out pht_type.a_num,dk_ma_dk out pht_type.a_var,
    dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,
    dk_ptB out pht_type.a_num,dk_ptG out pht_type.a_num,dk_phiG out pht_type.a_num,
    dk_lkeP out pht_type.a_var,dk_lkeB out pht_type.a_var,dk_luy out pht_type.a_var,dk_lh_bh out pht_type.a_var,
    lt_so_id out pht_type.a_num,lt_dk out pht_type.a_clob,lt_lt out pht_type.a_clob,lt_kbt out pht_type.a_clob,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_i2 number; b_ktG number; b_ps varchar2(1);
    b_kieu_hd varchar2(1); b_ttrang varchar2(1);
    b_phiH number; b_ttoanH number; b_phiN number; b_giamN number;

    b_kt_dk number; b_kt_dkB number; b_kt_dkC number; b_kt_lt number;
    b_so_dt number; b_ngay_hl number; b_ngay_kt number; b_txt clob;

    nh_dt_ct pht_type.a_clob; nh_dt_dk pht_type.a_clob; nh_dt_dkbs pht_type.a_clob;
    nh_dt_lt pht_type.a_clob; nh_dt_khd pht_type.a_clob; nh_dt_kbt pht_type.a_clob;

    nh_nhomG pht_type.a_var; nh_tl_giamG pht_type.a_num; nh_giamG pht_type.a_num; nh_ttoanG pht_type.a_num;
    nh_maG pht_type.a_var; nh_tenG pht_type.a_nvar;
    nh_tcG pht_type.a_var; nh_ma_ctG pht_type.a_var; nh_kieuG pht_type.a_var;
    nh_tienG pht_type.a_num; nh_ptG pht_type.a_num; nh_phiG pht_type.a_num;
    nh_capG pht_type.a_num; nh_ma_dkG pht_type.a_var;
    nh_lh_nvG pht_type.a_var; nh_ptBG pht_type.a_var; nh_phiBG pht_type.a_var;
    nh_lkePG pht_type.a_var; nh_lkeBG pht_type.a_var; nh_luyG pht_type.a_var; nh_lh_bhG pht_type.a_var;

    nhB_maG pht_type.a_var; nhB_tenG pht_type.a_nvar;
    nhB_tcG pht_type.a_var; nhB_ma_ctG pht_type.a_var; nhB_kieuG pht_type.a_var;
    nhB_tienG pht_type.a_num; nhB_ptG pht_type.a_num; nhB_phiG pht_type.a_num;
    nhB_capG pht_type.a_num; nhB_ma_dkG pht_type.a_var;
    nhB_lh_nvG pht_type.a_var; nhB_ptBG pht_type.a_var; nhB_phiBG pht_type.a_var;
    nhB_lkePG pht_type.a_var; nhB_lkeBG pht_type.a_var; nhB_luyG pht_type.a_var;
    dk_phiB pht_type.a_num;

begin
-- Dan - Nhap
b_lenh:=FKH_JS_LENH('ttrang,kieu_hd,ngay_hl,ngay_kt,ttoan');
EXECUTE IMMEDIATE b_lenh into b_ttrang,b_kieu_hd,b_ngay_hl,b_ngay_kt,b_ttoanH using dt_ct;
b_lenh:=FKH_JS_LENH('nhom,tl_giam,giam,ttoan');
EXECUTE IMMEDIATE b_lenh bulk collect into nh_nhomG,nh_tl_giamG,nh_giamG,nh_ttoanG using dt_giam;
b_lenh:=FKH_JS_LENHc('dt_nh_ct,dt_nh_dk,dt_nh_dkbs,dt_nh_lt,dt_nh_khd,dt_nh_kbt');
EXECUTE IMMEDIATE b_lenh bulk collect into nh_dt_ct,nh_dt_dk,nh_dt_dkbs,nh_dt_lt,nh_dt_khd,nh_dt_kbt using dt_nh;
if nh_dt_ct.count=0 then b_loi:='loi:Nhap quyen loi nhom:loi'; return; end if;
b_lenh:=FKH_JS_LENH('so_id_dt,kieu_gcn,gcn,gcn_g,nhom,ten,ng_sinh,gioi,cmt,mobi,email,dchi,ng_huong,ngay_hl,ngay_kt');
EXECUTE IMMEDIATE b_lenh bulk collect into
    gcn_so_id,gcn_kieu_gcn,gcn_gcn,gcn_gcnG,gcn_nhom,gcn_ten,gcn_ng_sinh,
    gcn_gioi,gcn_cmt,gcn_mobi,gcn_email,gcn_dchi,gcn_ng_huong,gcn_ngay_hl,gcn_ngay_kt using dt_ds;
b_so_dt:=gcn_ten.count;
if b_so_dt=0 then b_loi:='loi:Nhap danh sach nguoi duoc bao hiem:loi'; return; end if;
b_lenh:=FKH_JS_LENH('nhom,ten,loai,kvuc,ma_sp,cdich,goi,ngay_hl,ngay_kt,ma_chuyen,phi');
for b_lp in 1..nh_dt_ct.count loop
    EXECUTE IMMEDIATE b_lenh into nh_nhom(b_lp),nh_ten(b_lp),
        nh_loai(b_lp),nh_kvuc(b_lp),nh_ma_sp(b_lp),nh_cdich(b_lp),nh_goi(b_lp),
        nh_ngay_hl(b_lp),nh_ngay_kt(b_lp),nh_ma_chuyen(b_lp),nh_phi(b_lp) using nh_dt_ct(b_lp);
    if trim(nh_nhom(b_lp)) is null or trim(nh_ten(b_lp)) is null then
        b_loi:='loi:Nhap nhom va ten nhom dong '||to_char(b_lp)||':loi'; return;
    end if;
    b_i1:=FKH_ARR_VTRI(nh_nhomG, nh_nhom(b_lp));
    if b_i1=0 then b_loi:='loi:Sai nhom '||nh_ten(b_lp)||':loi'; return; end if;
    nh_giam(b_lp):=nh_giamG(b_i1); nh_ttoan(b_lp):=nh_ttoanG(b_i1);
    nh_tl_giam(b_lp):=nh_tl_giamG(b_i1); nh_phiN(b_lp):=nh_giam(b_lp)+nh_ttoan(b_lp);
    b_i1:=FKH_ARR_VTRI(nh_nhomC, nh_nhom(b_lp));
    if b_i1>0 then nh_so_id(b_lp):=nh_so_idC(b_i1); else nh_so_id(b_lp):=b_lp; end if;
    if nh_loai(b_lp) is null or nh_loai(b_lp) not in('N','Q','T','V') then
        b_loi:='loi:Sai loai nhom '||nh_ten(b_lp)||':loi'; return;
    end if;
    nh_kvuc(b_lp):=nvl(trim(nh_kvuc(b_lp)),' ');
    if nh_kvuc(b_lp)<>' ' and FBH_NGDL_KVUC_HAN(nh_kvuc(b_lp))<>'C' then
        b_loi:='loi:Sai ma khu vuc nhom '||nh_ten(b_lp)||':loi'; return;
    end if;
    nh_ma_sp(b_lp):=nvl(trim(nh_ma_sp(b_lp)),' ');
    if nh_ma_sp(b_lp)<>' ' and FBH_NGDL_SP_HAN(nh_ma_sp(b_lp))<>'C' then
        b_loi:='loi:Sai ma san pham nhom '||nh_ten(b_lp)||':loi'; return;
    end if;
    nh_cdich(b_lp):=PKH_MA_TENl(nh_cdich(b_lp));
    if nh_cdich(b_lp)<>' ' and FBH_MA_CDICH_HAN(nh_cdich(b_lp))<>'C' then
        b_loi:='loi:Sai ma chien dich nhom '||nh_ten(b_lp)||':loi'; return;
    end if;
    nh_goi(b_lp):=PKH_MA_TENl(nh_goi(b_lp));
    if nh_goi(b_lp)<>' ' and FBH_NGDL_GOI_HAN(nh_goi(b_lp))<>'C' then
        b_loi:='loi:Sai ma goi nhom '||nh_ten(b_lp)||':loi'; return;
    end if;
    if nh_ngay_kt(b_lp) is null or nh_ngay_kt(b_lp) in(0,30000101) or nh_ngay_kt(b_lp)<b_ngay_hl or nh_ngay_kt(b_lp)>b_ngay_kt then
        nh_ngay_kt(b_lp):=b_ngay_kt;
    end if;
    if nh_ngay_hl(b_lp) is null or nh_ngay_hl(b_lp) in(0,30000101) or
        nh_ngay_hl(b_lp)<b_ngay_hl or nh_ngay_hl(b_lp)>b_ngay_kt or nh_ngay_hl(b_lp)>nh_ngay_kt(b_lp) then
        nh_ngay_hl(b_lp):=b_ngay_hl;
    end if;
    nh_so_idP(b_lp):=FBH_NGDL_BPHI_SO_ID('T',nh_loai(b_lp),nh_kvuc(b_lp),nh_ma_sp(b_lp),nh_cdich(b_lp),nh_goi(b_lp),b_ngay_hl);
    if nh_so_idP(b_lp)=0 then b_loi:='loi:Kong tim duoc bieu khi nhom '||nh_ten(b_lp)||':loi'; return; end if;
    nh_ma_chuyen(b_lp):=nvl(trim(nh_ma_chuyen(b_lp)),' ');
end loop;
for b_lp in 1..gcn_ten.count loop
    if trim(gcn_ten(b_lp)) is null then b_loi:='loi:Nhap ten dong '||to_char(b_lp)||':loi'; return; end if;
    if trim(gcn_nhom(b_lp)) is null or trim(gcn_cmt(b_lp)) is null  then b_loi:='loi:Nhap nhom, CCCD '||gcn_ten(b_lp)||':loi'; return; end if;
    b_i1:=FKH_ARR_VTRI(nh_nhom, gcn_nhom(b_lp));
    if b_i1=0 then b_loi:='loi:Chua xep nhom '||gcn_ten(b_lp)||':loi'; return; end if;
    gcn_ma_kh(b_lp):=' '; gcn_ma_sp(b_lp):=nh_ma_sp(b_i1);
    if gcn_so_id(b_lp) is null or gcn_so_id(b_lp)=0 then gcn_so_id(b_lp):=b_lp; end if;
    gcn_gcn(b_lp):=nvl(trim(gcn_gcn(b_lp)),' '); gcn_gcnG(b_lp):=nvl(trim(gcn_gcnG(b_lp)),' ');
    gcn_mobi(b_lp):=nvl(trim(gcn_mobi(b_lp)),' ');gcn_email(b_lp):=nvl(trim(gcn_email(b_lp)),' ');
    if gcn_gcnG(b_lp)=' ' then gcn_kieu_gcn(b_lp):='B'; else gcn_kieu_gcn(b_lp):='G'; end if;
    if gcn_ngay_kt(b_lp) is null or gcn_ngay_kt(b_lp) in(0,30000101) or gcn_ngay_kt(b_lp)<b_ngay_hl or gcn_ngay_kt(b_lp)>b_ngay_kt then
        gcn_ngay_kt(b_lp):=b_ngay_kt;
    end if;
    if gcn_ngay_hl(b_lp) is null or gcn_ngay_hl(b_lp) in(0,30000101) or
        gcn_ngay_hl(b_lp)<b_ngay_hl or gcn_ngay_hl(b_lp)>b_ngay_kt or gcn_ngay_hl(b_lp)>gcn_ngay_kt(b_lp) then
        gcn_ngay_hl(b_lp):=b_ngay_hl;
    end if;
end loop;
if b_kieu_hd in('B','S') and b_so_idG<>0 then
    for r_lp in (select so_id_dt,cmt,ten from bh_ngdl_ds where ma_dvi=b_ma_dvi and so_id=b_so_idG) loop
        if FKH_ARR_VTRI_N(gcn_so_id,r_lp.so_id_dt)=0 then
        b_loi:='loi:Khong xoa danh sach cu '||r_lp.ten||', CCCD: '||r_lp.cmt||':loi'; return;
    end if;
    end loop;
end if;
b_kt_dk:=0; b_kt_lt:=0; b_phiH:=0;
b_lenh:=FKH_JS_LENH('ma,ten,tien,pt,phi,cap,tc,ma_ct,kieu,ma_dk,lh_nv,ptb,phib,lkep,lkeb,luy');
for b_lp in 1..nh_nhom.count loop
    EXECUTE IMMEDIATE b_lenh bulk collect into
        nh_maG,nh_tenG,nh_tienG,nh_ptG,nh_phiG,nh_capG,nh_tcG,nh_ma_ctG,nh_kieuG,
        nh_ma_dkG,nh_lh_nvG,nh_ptBG,nh_phiBG,nh_lkePG,nh_lkeBG,nh_luyG using nh_dt_dk(b_lp);
    b_ktG:=nh_maG.count;
    if b_ktG=0 then
        b_loi:='loi:Chua nhap dieu khoan bao hiem nhom '||nh_ten(b_lp)||':loi'; return;
    end if;
    for b_lp2 in 1..b_ktG loop
        nh_lh_bhG(b_lp2):='C';
    end loop;
    if trim(nh_dt_dkbs(b_lp)) is not null then
        EXECUTE IMMEDIATE b_lenh bulk collect into
            nhB_maG,nhB_tenG,nhB_tienG,nhB_ptG,nhB_phiG,nhB_capG,nhB_tcG,nhB_ma_ctG,nhB_kieuG,
            nhB_ma_dkG,nhB_lh_nvG,nhB_ptBG,nhB_phiBG,nhB_lkePG,nhB_lkeBG,nhB_luyG using nh_dt_dkbs(b_lp);
        for b_lp2 in 1..nhB_maG.count loop
            b_ktG:=b_ktG+1;
            nh_lh_bhG(b_ktG):='M';
            nh_maG(b_ktG):=nhB_maG(b_lp2); nh_tenG(b_ktG):=nhB_tenG(b_lp2); nh_tienG(b_ktG):=nhB_tienG(b_lp2);
            nh_ptG(b_ktG):=nhB_ptG(b_lp2); nh_phiG(b_ktG):=nhB_phiG(b_lp2); nh_capG(b_ktG):=nhB_capG(b_lp2);
            nh_tcG(b_ktG):=nhB_tcG(b_lp2); nh_ma_ctG(b_ktG):=nhB_ma_ctG(b_lp2); nh_kieuG(b_ktG):=nhB_kieuG(b_lp2);
            nh_ma_dkG(b_ktG):=nhB_ma_dkG(b_lp2); nh_lh_nvG(b_ktG):=nhB_lh_nvG(b_lp2); nh_ptBG(b_ktG):=nhB_ptBG(b_lp2);
            nh_phiBG(b_ktG):=nhB_phiBG(b_lp2);
            nh_lkePG(b_ktG):=nhB_lkePG(b_lp2); nh_lkeBG(b_ktG):=nhB_lkeBG(b_lp2); nh_luyG(b_ktG):=nhB_luyG(b_lp2);
        end loop;
    end if;
    b_so_dt:=0; b_phiN:=0; b_kt_dkB:=b_kt_dk+1;
    for b_lp1 in 1..gcn_ten.count loop
        if gcn_nhom(b_lp1)=nh_nhom(b_lp) then
            for b_lp2 in 1..nh_maG.count loop
                b_kt_dk:=b_kt_dk+1;
                dk_so_id(b_kt_dk):=gcn_so_id(b_lp1);
                dk_ma(b_kt_dk):=nh_maG(b_lp2);dk_ten(b_kt_dk):=nh_tenG(b_lp2); dk_tc(b_kt_dk):=nh_tcG(b_lp2);
                dk_ma_ct(b_kt_dk):=nh_ma_ctG(b_lp2); dk_kieu(b_kt_dk):=nh_kieuG(b_lp2); dk_bt(b_kt_dk):=b_lp2;
                dk_tien(b_kt_dk):=nh_tienG(b_lp2); dk_pt(b_kt_dk):=nh_ptG(b_lp2); dk_phi(b_kt_dk):=nh_phiG(b_lp2);
                dk_cap(b_kt_dk):=nh_capG(b_lp2); dk_ma_dk(b_kt_dk):=nh_ma_dkG(b_lp2);
                dk_lh_nv(b_kt_dk):=nh_lh_nvG(b_lp2); dk_lkeP(b_kt_dk):=nh_lkePG(b_lp2);
                dk_lkeB(b_kt_dk):=nh_lkeBG(b_lp2); dk_luy(b_kt_dk):=nh_luyG(b_lp2);
                dk_lh_bh(b_kt_dk):=nh_lh_bhG(b_lp2);
                dk_t_suat(b_kt_dk):=0; dk_thue(b_kt_dk):=0; dk_ttoan(b_kt_dk):=dk_phi(b_kt_dk);
                if dk_lh_nv(b_kt_dk)<>' ' then b_phiN:=b_phiN+dk_phi(b_kt_dk); end if;
                dk_ptB(b_kt_dk):=nh_ptBG(b_lp2); dk_phiB(b_kt_dk):=nh_phiBG(b_lp2);
            end loop;
            if nh_dt_dkbs(b_lp) is null then
                b_txt:=nh_dt_dk(b_lp);
            else
                b_i1:=length(nh_dt_dk(b_lp))-1;
                b_txt:=substr(nh_dt_dk(b_lp),1,b_i1)||','||substr(nh_dt_dkbs(b_lp),2);
            end if;
            lt_so_id(b_lp1):=gcn_so_id(b_lp1); lt_dk(b_lp1):=b_txt; lt_lt(b_lp1):=nh_dt_lt(b_lp); lt_kbt(b_lp1):=nh_dt_kbt(b_lp);
            b_so_dt:=b_so_dt+1;
        end if;
    end loop;
    for b_lp in 1..b_kt_dk loop
      dk_kieu(b_lp):=nvl(trim(dk_kieu(b_lp)),' '); dk_lh_nv(b_lp):=nvl(trim(dk_lh_nv(b_lp)),' '); dk_t_suat(b_lp):=0;
      dk_thue(b_lp):=0; dk_phiB(b_lp):=nvl(dk_phiB(b_lp),0); dk_tien(b_lp):=nvl(dk_tien(b_lp),0);
      if dk_tien(b_lp)<>0 then
        b_i1:=round(dk_phiB(b_lp)/dk_tien(b_lp)*100,4);
        dk_pt(b_lp):= b_i1 - round(((dk_phiB(b_lp)/dk_tien(b_lp))-(dk_phi(b_lp)/dk_tien(b_lp)))*100 ,4);
      end if;
    end loop;
    nh_so_dt(b_lp):=b_so_dt; b_giamN:=b_phiN-nh_ttoan(b_lp);
    if b_phiN<>0 and b_giamN<>0 then
        b_i1:=b_giamN/b_phiN; b_kt_dkC:=0;
        for b_lp1 in b_kt_dkB..b_kt_dk loop
            if dk_lh_nv(b_lp1)<>' ' then
                b_i2:=round(b_i1*dk_phi(b_lp1),0);
                dk_phiG(b_lp1):=b_i2;
                dk_phi(b_lp1):=dk_phi(b_lp1)-b_i2;
                dk_ttoan(b_lp1):=dk_phi(b_lp1);
                b_giamN:=b_giamN-b_i2; b_kt_dkC:=b_lp1;
            end if;
        end loop;
        if b_giamN<>0 and b_kt_dkC<>0 then
            dk_phiG(b_kt_dkC):=dk_phiG(b_kt_dkC)+b_giamN;
            dk_phi(b_kt_dkC):=dk_phi(b_kt_dkC)-b_giamN;
            dk_ttoan(b_kt_dkC):=dk_phi(b_kt_dkC);
        end if;
    end if;
    b_phiH:=b_phiH+nh_ttoan(b_lp);
end loop;
b_giamN:=b_phiH-b_ttoanH;
if b_phiH<>0 and b_giamN<>0 then
    b_i1:=b_giamN/b_phiH; b_kt_dkC:=0;
    for b_lp1 in 1..b_kt_dk loop
        if dk_lh_nv(b_lp1)<>' ' then
            b_i2:=round(b_i1*dk_phi(b_lp1),0);
            dk_phiG(b_lp1):=b_i2;
            dk_phi(b_lp1):=dk_phi(b_lp1)-b_i2;
            b_giamN:=b_giamN-b_i2; b_kt_dkC:=b_lp1;
            dk_ttoan(b_lp1):=dk_phi(b_lp1);
        end if;
    end loop;
    if b_giamN<>0 and b_kt_dkC<>0 then
        dk_phiG(b_kt_dkC):=dk_phiG(b_kt_dkC)+b_giamN;
        dk_phi(b_kt_dkC):=dk_phi(b_kt_dkC)-b_giamN;
        dk_ttoan(b_kt_dkC):=dk_phi(b_kt_dkC);
    end if;
end if;
for b_lp in 1..dk_ma.count loop
    if dk_phiB(b_lp)>dk_phi(b_lp) and dk_tien(b_lp) > 0 and dk_lh_nv(b_lp)<> ' ' then
        dk_phiG(b_lp):=dk_phiB(b_lp)-dk_phi(b_lp);
        dk_ptG(b_lp):=round(dk_phiG(b_lp)*100/dk_phiB(b_lp),2);
    else
        dk_ptG(b_lp):=0; dk_phiG(b_lp):=0;
    end if;
end loop;
for b_lp in 1..gcn_ten.count loop
    gcn_ttoan(b_lp):=0; gcn_giam(b_lp):=0;
    for b_lp1 in 1..b_kt_dk loop
        if dk_lh_nv(b_lp1)<>' ' and dk_so_id(b_lp1)=gcn_so_id(b_lp) then
            gcn_ttoan(b_lp):=gcn_ttoan(b_lp)+dk_phi(b_lp1);
            gcn_giam(b_lp):=gcn_giam(b_lp)+dk_phiG(b_lp1);
        end if;
    end loop;
    gcn_phi(b_lp):=gcn_ttoan(b_lp)+gcn_giam(b_lp);
end loop;
if b_ttrang in ('T','D') then
    for b_lp in 1..nh_nhom.count loop
        if nh_so_id(b_lp) is null or nh_so_id(b_lp)<100000 then
            PHT_ID_MOI(nh_so_id(b_lp),b_loi);
            if b_loi is not null then return; end if;
        end if;
    end loop;
    for b_lp in 1..gcn_ten.count loop
        b_i1:=gcn_so_id(b_lp);
        if b_i1<100000 then
            PHT_ID_MOI(b_i2,b_loi);
            if b_loi is not null then return; end if;
            for b_lp1 in 1..dk_so_id.count loop
                if dk_so_id(b_lp1)=gcn_so_id(b_lp) then dk_so_id(b_lp1):=b_i2; end if;
            end loop;
            gcn_so_id(b_lp):=b_i2; lt_so_id(b_lp):=b_i2;
            gcn_kieu_gcn(b_lp):='G';
            gcn_gcn(b_lp):=substr(to_char(b_i2),3); gcn_gcnG(b_lp):=' ';
        elsif b_kieu_hd not in('S','B') then
            gcn_kieu_gcn(b_lp):='G'; gcn_gcn(b_lp):=substr(to_char(gcn_so_id(b_lp)),3); gcn_gcnG(b_lp):=' ';
        else
            select count(*) into b_i1 from bh_ngdl_ds where ma_dvi=b_ma_dvi and so_id_dt=gcn_so_id(b_lp);
            if b_i1 > 0 then
                b_i2:=FKH_ARR_VTRI(nh_nhom, gcn_nhom(b_lp));
                select count(*) into b_i1 from bh_ngdl_ds where ma_dvi=b_ma_dvi and so_id_dt=gcn_so_id(b_lp) and so_id=b_so_idG
                and (nhom<>gcn_nhom(b_lp) or ten<>gcn_ten(b_lp) or
                    ng_sinh<>gcn_ng_sinh(b_lp) or gioi<>gcn_gioi(b_lp) or cmt<>gcn_cmt(b_lp) or
                    mobi<>gcn_mobi(b_lp) or email<>gcn_email(b_lp) or
                    ngay_hl<>gcn_ngay_hl(b_lp) or ngay_kt<>gcn_ngay_kt(b_lp) or
                    dchi<>gcn_dchi(b_lp) or ng_huong<>gcn_ng_huong(b_lp));
                if b_i1=0 then
                    select gcn,kieu_gcn,gcn_g into gcn_gcn(b_lp),gcn_kieu_gcn(b_lp),gcn_gcnG(b_lp)
                        from bh_ngdl_ds where ma_dvi=b_ma_dvi and so_id=b_so_idG and so_id_dt=gcn_so_id(b_lp); --chuclh so_id=b_so_idG
                else
                    gcn_kieu_gcn(b_lp):=b_kieu_hd;
                    select gcn into gcn_gcn(b_lp) from bh_ngdl_ds where ma_dvi=b_ma_dvi and so_id=b_so_idG and so_id_dt=gcn_so_id(b_lp);
                    select NVL(TO_NUMBER(REGEXP_SUBSTR(gcn_gcn(b_lp), '/[A-Z]*([0-9]+)$', 1, 1, NULL, 1)),0) into b_i1 from dual;
                    gcn_gcn(b_lp):=substr(to_char(gcn_so_id(b_lp)),3);
                    gcn_gcn(b_lp):=gcn_gcn(b_lp)||'/'||b_kieu_hd||to_char(b_i1+1);
                end if;
            end if;
        end if;
        select json_object('loai' value 'C','ten' value gcn_ten(b_lp),'cmt' value gcn_cmt(b_lp),
            'dchi' value gcn_dchi(b_lp),'mobi' value gcn_mobi(b_lp),'email' value gcn_email(b_lp),
            'gioi' value gcn_gioi(b_lp),'ng_sinh' value gcn_ng_sinh(b_lp),'ngay_hl' value gcn_ngay_hl(b_lp)) into b_txt from dual;
        PBH_DTAC_MA_NH(b_txt,gcn_ma_kh(b_lp),b_loi,b_ma_dvi,b_nsd);
        if gcn_ma_kh(b_lp) in(' ','VANGLAI') then b_loi:='loi:Chua du thong tin '||gcn_ten(b_lp)||':loi'; return; end if;
        if b_loi is not null then return; end if;
        b_i1:=FKH_ARR_VTRI(nh_nhom,gcn_nhom(b_lp));
        PBH_NGDL_KHD(b_txt,nh_dt_khd(b_i1),b_loi);
        if b_loi is not null then return; end if;
    end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_NGDLT_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    dt_ct in out clob,dt_nh clob,dt_ds clob,
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
    nh_so_id pht_type.a_num,nh_nhom pht_type.a_var,nh_ten pht_type.a_nvar,
    nh_loai pht_type.a_var,nh_kvuc pht_type.a_var,nh_ma_sp pht_type.a_var,
    nh_cdich pht_type.a_var,nh_goi pht_type.a_var,nh_so_idP pht_type.a_num,
    nh_ngay_hl pht_type.a_num,nh_ngay_kt pht_type.a_num,nh_ma_chuyen pht_type.a_var,
    nh_phi pht_type.a_num,nh_so_dt pht_type.a_num,nh_phiN pht_type.a_num,
    nh_tl_giam pht_type.a_num,nh_giam pht_type.a_num,nh_ttoan pht_type.a_num,

    gcn_so_id pht_type.a_num,gcn_kieu_gcn pht_type.a_var,gcn_gcn pht_type.a_var,gcn_gcnG pht_type.a_var,
    gcn_nhom pht_type.a_var,gcn_ma_sp pht_type.a_var,gcn_ma_kh pht_type.a_var,
    gcn_ten pht_type.a_nvar,gcn_ng_sinh pht_type.a_num,gcn_gioi pht_type.a_var,
    gcn_cmt pht_type.a_var,gcn_mobi pht_type.a_var,gcn_email pht_type.a_var,
    gcn_dchi pht_type.a_nvar,gcn_ng_huong pht_type.a_nvar,
    gcn_phi pht_type.a_num,gcn_giam pht_type.a_num,gcn_ttoan pht_type.a_num,

    dk_so_id pht_type.a_num,dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tc pht_type.a_var,
    dk_ma_ct pht_type.a_var,dk_kieu pht_type.a_var,dk_bt pht_type.a_num,dk_tien pht_type.a_num,dk_pt pht_type.a_num,
    dk_phi pht_type.a_num,dk_thue pht_type.a_num,dk_ttoan pht_type.a_num,
    dk_cap pht_type.a_num,dk_ma_dk pht_type.a_var,dk_lh_nv pht_type.a_var,dk_t_suat pht_type.a_num,
    dk_ptB pht_type.a_num,dk_ptG pht_type.a_num,dk_phiG pht_type.a_num,dk_lkeP pht_type.a_var,
    dk_lkeB pht_type.a_var,dk_luy pht_type.a_var,dk_lh_bh pht_type.a_var,
    lt_so_id pht_type.a_num,lt_dk pht_type.a_clob,lt_lt pht_type.a_clob,lt_kbt pht_type.a_clob,b_loi out varchar2)
AS
    b_i1 number; b_so_dt number; b_tien number:=0; b_so_id_kt number:=-1;
    b_txt clob; b_gtri nvarchar2(2000); b_ma_ke varchar2(20):=' ';
    dkT_ma pht_type.a_var; dkT_ten pht_type.a_nvar; dkT_tien pht_type.a_num; dkT_ptG pht_type.a_num;
begin
-- Dan - Nhap
b_loi:='loi:Loi Table bh_ngdl:loi';
b_so_dt:=gcn_so_id.count;
if b_ttrang='D' then b_so_id_kt:=0; end if;
for b_lp in 1..tt_ngay.count loop
    insert into bh_ngdl_tt values(b_ma_dvi,b_so_id,tt_ngay(b_lp),tt_tien(b_lp));
end loop;
for b_lp in 1..nh_so_id.count loop
    insert into bh_ngdl_nh values(b_ma_dvi,b_so_id,nh_so_id(b_lp),b_lp,nh_nhom(b_lp),nh_ten(b_lp),
        nh_loai(b_lp),nh_ma_sp(b_lp),nh_cdich(b_lp),nh_goi(b_lp),nh_so_idP(b_lp),
        nh_phi(b_lp),nh_so_dt(b_lp),nh_phiN(b_lp),nh_tl_giam(b_lp),nh_giam(b_lp),nh_ttoan(b_lp));
end loop;
for b_lp in 1..gcn_so_id.count loop
    b_i1:=FKH_ARR_VTRI(nh_nhom, gcn_nhom(b_lp));
    insert into bh_ngdl_ds values(b_ma_dvi,b_so_id,gcn_so_id(b_lp),b_lp,gcn_kieu_gcn(b_lp),gcn_gcn(b_lp),gcn_gcnG(b_lp),gcn_ten(b_lp),
        gcn_ng_sinh(b_lp),gcn_gioi(b_lp),gcn_cmt(b_lp),gcn_mobi(b_lp),gcn_email(b_lp),gcn_dchi(b_lp),
        gcn_ng_huong(b_lp),b_gio_hl,nh_ngay_hl(b_i1),b_gio_kt,nh_ngay_kt(b_i1),b_ngay_cap,
        nh_loai(b_i1),nh_kvuc(b_i1),nh_ma_sp(b_i1),nh_cdich(b_i1),nh_goi(b_i1),nh_so_idP(b_i1),
        gcn_nhom(b_lp),nh_ma_chuyen(b_i1),gcn_phi(b_lp),gcn_giam(b_lp),gcn_ttoan(b_lp),gcn_ma_kh(b_lp));
end loop;
for b_lp in 1..dk_so_id.count loop
    if dk_lh_nv(b_lp)<>' ' and dk_kieu(b_lp)='T' then b_tien:=b_tien+dk_tien(b_lp); end if;
    insert into bh_ngdl_dk values(b_ma_dvi,b_so_id,dk_so_id(b_lp),dk_bt(b_lp),dk_ma(b_lp),dk_ten(b_lp),
        dk_tc(b_lp),dk_ma_ct(b_lp),dk_kieu(b_lp),
        dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),dk_cap(b_lp),dk_ma_dk(b_lp),dk_lh_nv(b_lp),
        dk_t_suat(b_lp),dk_thue(b_lp),dk_ttoan(b_lp),dk_ptB(b_lp),dk_ptG(b_lp),dk_phiG(b_lp),dk_lkeP(b_lp),
        dk_lkeB(b_lp),dk_luy(b_lp),dk_lh_bh(b_lp));
end loop;
insert into bh_ngdl values(
    b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,'T',b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
    b_phong,b_so_hdL,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,
    b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,'K',b_so_dt,'C',b_tien,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,'','',b_so_id_kt,b_nsd,sysdate);
PKH_JS_THAYa(dt_ct,'so_hd,ma_kh',b_so_hd||','||b_ma_kh);
insert into bh_ngdl_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
insert into bh_ngdl_txt values(b_ma_dvi,b_so_id,'dt_nh',dt_nh);
insert into bh_ngdl_txt values(b_ma_dvi,b_so_id,'dt_ds',dt_ds);
if b_ttrang in('T','D') then
    for b_lp in 1..lt_so_id.count loop
        insert into bh_ng_kbt values(b_ma_dvi,b_so_id,lt_so_id(b_lp),lt_dk(b_lp),lt_lt(b_lp),lt_kbt(b_lp));
    end loop;
    insert into bh_ng values(
        b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,'DLT',b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
        b_phong,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,
        b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,'K',b_so_dt,b_tien,b_phi,b_giam,b_thue,
        b_ttoan,b_hhong,b_so_idG,b_so_idD,0,'','',b_nsd);
    for b_lp in 1..tt_ngay.count loop
        insert into bh_ng_tt values(b_ma_dvi,b_so_id,tt_ngay(b_lp),tt_tien(b_lp));
    end loop;
    for b_lp in 1..dk_so_id.count loop
        insert into bh_ng_dk values(b_ma_dvi,b_so_id,dk_so_id(b_lp),dk_bt(b_lp),dk_ma(b_lp),dk_ten(b_lp),
            dk_tc(b_lp),dk_ma_ct(b_lp),dk_kieu(b_lp),dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),
            dk_cap(b_lp),dk_ma_dk(b_lp),dk_lh_nv(b_lp),dk_t_suat(b_lp),dk_thue(b_lp),dk_ttoan(b_lp),
            dk_ptB(b_lp),dk_ptG(b_lp),dk_phiG(b_lp),dk_lkeP(b_lp),dk_lkeB(b_lp),dk_luy(b_lp),dk_lh_bh(b_lp));
    end loop;
    for b_lp in 1..gcn_so_id.count loop
        insert into bh_ng_ds values(b_ma_dvi,b_so_id,gcn_so_id(b_lp),gcn_kieu_gcn(b_lp),
            gcn_gcn(b_lp),gcn_gcnG(b_lp),gcn_ten(b_lp),
            gcn_ng_sinh(b_lp),gcn_gioi(b_lp),gcn_cmt(b_lp),gcn_mobi(b_lp),gcn_email(b_lp),gcn_dchi(b_lp),' ',
            gcn_ng_huong(b_lp),gcn_ma_sp(b_lp),' ',b_ngay_hl,' ',b_ngay_kt,b_ngay_cap,nh_so_idP(b_i1),
            gcn_phi(b_lp),gcn_giam(b_lp),gcn_ttoan(b_lp),' ',gcn_ma_kh(b_lp));
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
create or replace procedure PBH_NGDLT_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(3000); b_lenh varchar2(2000); b_i1 number;
    dt_ct clob; dt_giam clob; dt_nh clob; dt_ds clob; dt_kytt clob;
-- Chung
    b_so_id number; b_so_hd varchar2(20); b_ngay_ht number; b_ttrang varchar2(1); b_kieu_hd varchar2(1); b_so_hd_g varchar2(20); 
    b_kieu_kt varchar2(1); b_ma_kt varchar2(20); b_kieu_gt varchar2(1); b_ma_gt varchar2(20); b_ma_cb varchar2(20); 
    b_so_hdL varchar2(20); b_loai_kh varchar2(1); b_ma_kh varchar2(20); b_ten nvarchar2(500); b_dchi nvarchar2(500); 
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100); 
    b_gio_hl varchar2(20); b_ngay_hl number; b_gio_kt varchar2(20); b_ngay_kt number; b_ngay_cap number; 
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_c_thue varchar2(1); 
    b_tl_giam number; b_phi number; b_giam number; b_thue number; b_ttoan number; b_hhong number; 
    b_so_idG number; b_so_idD number; b_ngayD number; b_phong varchar2(10); 
    tt_ngay pht_type.a_num; tt_tien pht_type.a_num; 
-- Rieng
    nh_so_id pht_type.a_num; nh_nhom pht_type.a_var; nh_ten pht_type.a_nvar;
    nh_loai pht_type.a_var; nh_kvuc pht_type.a_var; nh_ma_sp pht_type.a_var; nh_cdich pht_type.a_var;
    nh_goi pht_type.a_var; nh_so_idP pht_type.a_num;
    nh_ngay_hl pht_type.a_num; nh_ngay_kt pht_type.a_num; nh_ma_chuyen pht_type.a_var;

    nh_phi pht_type.a_num; nh_so_dt pht_type.a_num; nh_phiN pht_type.a_num; 
    nh_tl_giam pht_type.a_num; nh_giam pht_type.a_num; nh_ttoan pht_type.a_num; nh_dt_ct pht_type.a_clob; 

    gcn_so_id pht_type.a_num; gcn_kieu_gcn pht_type.a_var; gcn_gcn pht_type.a_var; gcn_gcnG pht_type.a_var; 
    gcn_nhom pht_type.a_var; gcn_ma_sp pht_type.a_var; gcn_ma_kh pht_type.a_var;
    gcn_ten pht_type.a_nvar; gcn_ng_sinh pht_type.a_num; gcn_gioi pht_type.a_var; 
    gcn_cmt pht_type.a_var; gcn_mobi pht_type.a_var; gcn_email pht_type.a_var; 
    gcn_dchi pht_type.a_nvar; gcn_ng_huong pht_type.a_nvar; gcn_ngay_hl pht_type.a_num; gcn_ngay_kt pht_type.a_num;
    gcn_phi pht_type.a_num; gcn_giam pht_type.a_num; gcn_ttoan pht_type.a_num;

    dk_so_id pht_type.a_num; dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var;
    dk_ma_ct pht_type.a_var; dk_kieu pht_type.a_var; dk_bt pht_type.a_num; dk_tien pht_type.a_num;
    dk_pt pht_type.a_num; dk_phi pht_type.a_num; dk_thue pht_type.a_num; dk_ttoan pht_type.a_num; 
    dk_cap pht_type.a_num; dk_ma_dk pht_type.a_var; dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num; 
    dk_ptB pht_type.a_num; dk_ptG pht_type.a_num; dk_phiG pht_type.a_num; 
    dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var; dk_luy pht_type.a_var; dk_lh_bh pht_type.a_var;
    lt_so_id pht_type.a_num; lt_dk pht_type.a_clob; lt_lt pht_type.a_clob; lt_kbt pht_type.a_clob;
-- Xu ly
    b_ngay_htC number; nh_so_idC pht_type.a_num; nh_nhomC pht_type.a_var;
begin
-- Dan - Nhap
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_giam,dt_nh,dt_ds,dt_kytt');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_giam,dt_nh,dt_ds,dt_kytt using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_giam); FKH_JSa_NULL(dt_ds); FKH_JSa_NULL(dt_kytt);
if b_so_id<>0 then
    select count(*) into b_i1 from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 then
        select ngay_ht,ttrang into b_ngay_htC,b_ttrang from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_id;
        if b_ttrang='D' then
            select so_id_nh,nhom bulk collect into nh_so_idC,nh_nhomC from bh_ngdl_nh where ma_dvi=b_ma_dvi and so_id=b_so_id;
        else
            PKH_MANG_KD(nh_nhomC);
        end if;
        if b_ttrang not in('T','D')  then b_kieu_hd:='X'; else b_kieu_hd:='N'; end if;
        PBH_NGDL_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_kieu_hd,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
else
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_HD_JS_TEST(
    b_ma_dvi,b_nsd,b_so_id,b_ngay_htC,'bh_ngdl',dt_ct,dt_kytt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_loai_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,
    b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_ngayD,b_phong,b_ma_cb,b_ma_kh,
    tt_ngay,tt_tien,b_loi,'NG');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_NGDLT_TESTr(
    b_ma_dvi,b_nsd,b_so_idG,nh_so_idC,nh_nhomC,
    dt_ct,dt_giam,dt_nh,dt_ds,
    nh_so_id,nh_nhom,nh_ten,nh_loai,nh_kvuc,nh_ma_sp,nh_cdich,nh_goi,nh_so_idP,
    nh_ngay_hl,nh_ngay_kt,nh_ma_chuyen,
    nh_phi,nh_so_dt,nh_phiN,nh_tl_giam,nh_giam,nh_ttoan,
    gcn_so_id,gcn_kieu_gcn,gcn_gcn,gcn_gcnG,gcn_nhom,gcn_ma_sp,gcn_ma_kh,gcn_ten,gcn_ng_sinh,gcn_gioi,
    gcn_cmt,gcn_mobi,gcn_email,gcn_dchi,gcn_ng_huong,gcn_ngay_hl,gcn_ngay_kt,gcn_phi,gcn_giam,gcn_ttoan,
    dk_so_id,dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_bt,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,dk_cap,dk_ma_dk,
    dk_lh_nv,dk_t_suat,dk_ptB,dk_ptG,dk_phiG,dk_lkeP,dk_lkeB,dk_luy,dk_lh_bh,lt_so_id,lt_dk,lt_lt,lt_kbt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_NGDLT_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,
    dt_ct,dt_nh,dt_ds,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,b_so_hdL,
    b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,
    b_so_idG,b_so_idD,b_ngayD,b_phong,
    tt_ngay,tt_tien,
    nh_so_id,nh_nhom,nh_ten,nh_loai,nh_kvuc,nh_ma_sp,nh_cdich,nh_goi,nh_so_idP,
    nh_ngay_hl,nh_ngay_kt,nh_ma_chuyen,nh_phi,nh_so_dt,nh_phiN,nh_tl_giam,nh_giam,nh_ttoan,
    gcn_so_id,gcn_kieu_gcn,gcn_gcn,gcn_gcnG,gcn_nhom,gcn_ma_sp,gcn_ma_kh,gcn_ten,gcn_ng_sinh,gcn_gioi,
    gcn_cmt,gcn_mobi,gcn_email,gcn_dchi,gcn_ng_huong,gcn_phi,gcn_giam,gcn_ttoan,
    dk_so_id,dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_bt,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,dk_cap,dk_ma_dk,
    dk_lh_nv,dk_t_suat,dk_ptB,dk_ptG,dk_phiG,dk_lkeP,dk_lkeB,dk_luy,dk_lh_bh,lt_so_id,lt_dk,lt_lt,lt_kbt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hd' value b_so_hd, 'ma_kh' value b_ma_kh) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
