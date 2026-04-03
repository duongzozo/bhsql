create or replace procedure PBH_GOPH_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number;
    dt_ct clob; dt_hd clob; dt_kytt clob; dt_txt clob;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','GOP','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
select json_object(so_hd,ma_kh) into dt_ct from bh_gop where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(nv,loai,so_kem,ttrang,phi,thue,so_id_kem) order by bt) into dt_hd
    from bh_gop_hd where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ngay,tien) order by ngay) into dt_kytt from bh_gop_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_gop_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,
    'dt_hd' value dt_hd,'dt_kytt' value dt_kytt,'dt_ct' value dt_ct,
    'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_GOPH_TESTr(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_idG number,
    dt_ct in out clob, dt_hd in out clob,
    hd_so_id_kem out pht_type.a_num,hd_nv out pht_type.a_var,hd_loai out pht_type.a_var,
    hd_so_kem out pht_type.a_var,hd_ttrang out pht_type.a_var,
    hd_tien out pht_type.a_num,hd_phi out pht_type.a_num,hd_thue out pht_type.a_num,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_i2 number; b_ps varchar2(1); b_txt clob;
    b_kieu_hd varchar2(1); b_ttrang varchar2(1); b_so_idD number;
    b_loai_khH varchar2(1); b_cmtH varchar2(20); b_mobiH varchar2(20); b_emailH varchar2(50);
    b_tenH nvarchar2(500); b_dchiH nvarchar2(500); b_ma_khH varchar2(20);
begin
-- Dan - Nhap
b_loi:='loi:Loi xu ly PBH_GOP_TESTr:loi';
b_lenh:=FKH_JS_LENH('ttrang,kieu_hd,loai_khh,cmth,mobih,emailh,tenh,dchih');
EXECUTE IMMEDIATE b_lenh into b_ttrang,b_kieu_hd,b_loai_khH,b_cmtH,b_mobiH,b_emailH,b_tenH,b_dchiH using dt_ct;
b_lenh:=FKH_JS_LENH('so_id_kem,nv,loai,so_kem');
EXECUTE IMMEDIATE b_lenh bulk collect into hd_so_id_kem,hd_nv,hd_loai,hd_so_kem using dt_hd;
if hd_so_id_kem.count=0 then b_loi:='loi:Nhap nghiep vu danh sach kem:loi'; return; end if;
for b_lp in 1..hd_so_id_kem.count loop
    hd_nv(b_lp):=nvl(trim(hd_nv(b_lp)),' '); hd_loai(b_lp):=nvl(trim(hd_loai(b_lp)),' ');
    if hd_nv(b_lp) not in('2B','XE','TAU','PHH','NG','PTN') or hd_loai(b_lp) not in('G','H') then
        b_loi:='loi:Sai nghiep vu, loai danh sach kem:loi'; return;
    end if;
    hd_so_id_kem(b_lp):=nvl(hd_so_id_kem(b_lp),0);
	hd_ttrang(b_lp):='C'; hd_tien(b_lp):=0; hd_phi(b_lp):=0; hd_thue(b_lp):=0;
    if hd_so_id_kem(b_lp)=0 then
        PHT_ID_MOI(hd_so_id_kem(b_lp),b_loi);
        if b_loi is not null then return; end if;
        hd_so_kem(b_lp):='C.'||substr(to_char(hd_so_id_kem(b_lp)),3);
    elsif hd_nv(b_lp)='2B' then
        select count(*) into b_i1 from bh_2b where ma_dvi=b_ma_dvi and so_id=hd_so_id_kem(b_lp);
        if b_i1=1 then
            select so_hd,ttrang,tien,phi,thue into hd_so_kem(b_lp),hd_ttrang(b_lp),hd_tien(b_lp),hd_phi(b_lp),hd_thue(b_lp)
                from bh_2b where ma_dvi=b_ma_dvi and so_id=hd_so_id_kem(b_lp);
        end if;
    elsif hd_nv(b_lp)='XE' then
        select count(*) into b_i1 from bh_xe where ma_dvi=b_ma_dvi and so_id=hd_so_id_kem(b_lp);
        if b_i1=1 then
            select so_hd,ttrang,tien,phi,thue into hd_so_kem(b_lp),hd_ttrang(b_lp),hd_tien(b_lp),hd_phi(b_lp),hd_thue(b_lp)
                from bh_xe where ma_dvi=b_ma_dvi and so_id=hd_so_id_kem(b_lp);
        end if;
    elsif hd_nv(b_lp)='TAU' then
        select count(*) into b_i1 from bh_tau where ma_dvi=b_ma_dvi and so_id=hd_so_id_kem(b_lp);
        if b_i1=1 then
            select so_hd,ttrang,tien,phi,thue into hd_so_kem(b_lp),hd_ttrang(b_lp),hd_tien(b_lp),hd_phi(b_lp),hd_thue(b_lp)
                from bh_tau where ma_dvi=b_ma_dvi and so_id=hd_so_id_kem(b_lp);
        end if;
    elsif hd_nv(b_lp)='PHH' then
        select count(*) into b_i1 from bh_phh where ma_dvi=b_ma_dvi and so_id=hd_so_id_kem(b_lp);
        if b_i1=1 then
            select so_hd,ttrang,tien,phi,thue into hd_so_kem(b_lp),hd_ttrang(b_lp),hd_tien(b_lp),hd_phi(b_lp),hd_thue(b_lp)
                from bh_phh where ma_dvi=b_ma_dvi and so_id=hd_so_id_kem(b_lp);
        end if;
    elsif hd_nv(b_lp)='NG' then
        select count(*) into b_i1 from bh_ng where ma_dvi=b_ma_dvi and so_id=hd_so_id_kem(b_lp);
        if b_i1=1 then
            select so_hd,ttrang,tien,phi,thue into hd_so_kem(b_lp),hd_ttrang(b_lp),hd_tien(b_lp),hd_phi(b_lp),hd_thue(b_lp)
                from bh_ng where ma_dvi=b_ma_dvi and so_id=hd_so_id_kem(b_lp);
        end if;
    elsif hd_nv(b_lp)='PTN' then
        select count(*) into b_i1 from bh_ptn where ma_dvi=b_ma_dvi and so_id=hd_so_id_kem(b_lp);
        if b_i1=1 then
            select so_hd,ttrang,tien,phi,thue into hd_so_kem(b_lp),hd_ttrang(b_lp),hd_tien(b_lp),hd_phi(b_lp),hd_thue(b_lp)
                from bh_ptn where ma_dvi=b_ma_dvi and so_id=hd_so_id_kem(b_lp);
        end if;
    end if;
end loop;
if b_kieu_hd in('B','S') and b_so_idG<>0 then
    b_so_idD:=FBH_GOP_SO_IDd(b_ma_dvi,b_so_idG);
    for r_lp in (select so_id,so_hd from bh_hd_goc where ma_dvi=b_ma_dvi and so_id_g=b_so_idD) loop
        if FKH_ARR_VTRI_N(hd_so_id_kem,r_lp.so_id)=0 then b_loi:='loi:Khong xoa danh sach cu '||r_lp.so_hd||':loi'; return; end if;
    end loop;
end if;
if b_ttrang in('T','D') then
	for b_lp in 1..hd_so_id_kem.count loop
		if hd_ttrang(b_lp)<>'T' then
			b_loi:='loi:Hop dong/Gcn kem phai tinh trang dang trinh: '||hd_so_kem(b_lp)||':loi'; return;
		end if;
	end loop;
    select json_object('loai' value b_loai_khH,'ten' value b_tenH,'cmt' value b_cmtH,
        'dchi' value b_dchiH,'mobi' value b_mobiH,'email' value b_emailH) into b_txt from dual;
    PBH_DTAC_MA_NH(b_txt,b_ma_khH,b_loi,b_ma_dvi,b_nsd);
    if b_ma_khH not in(' ','VANGLAI') then PKH_JS_THAY(dt_ct,'ma_khH',b_ma_khH); end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_GOPH_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    dt_ct in out clob,dt_hd clob,
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
    hd_so_id_kem pht_type.a_num,hd_nv pht_type.a_var,hd_loai pht_type.a_var,
    hd_so_kem pht_type.a_var,hd_ttrang pht_type.a_var,
    hd_tien pht_type.a_num,hd_phi pht_type.a_num,hd_thue pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_so_id_kt number:=-1; b_tien number:=0; b_txt clob;
begin
-- Dan - Nhap
b_loi:='loi:Loi Table bh_gop:loi';
if b_ttrang='D' then b_so_id_kt:=0; end if;
for b_lp in 1..hd_so_id_kem.count loop
    insert into bh_gop_hd values(b_ma_dvi,b_so_id,hd_so_id_kem(b_lp),hd_nv(b_lp),hd_loai(b_lp),
        hd_so_kem(b_lp),hd_ttrang(b_lp),hd_tien(b_lp),hd_phi(b_lp),hd_thue(b_lp),b_lp);
    b_tien:=b_tien+hd_tien(b_lp);
end loop;
for b_lp in 1..tt_ngay.count loop
    insert into bh_gop_tt values(b_ma_dvi,b_so_id,tt_ngay(b_lp),tt_tien(b_lp));
end loop;
insert into bh_gop values(
    b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,'H',b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
    b_phong,b_so_hdL,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,
    b_nt_tien,b_nt_phi,b_c_thue,b_tien,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,'','',b_so_id_kt,b_nsd,sysdate);
PKH_JS_THAYa(dt_ct,'so_hd,ma_kh',b_so_hd||','||b_ma_kh);
insert into bh_gop_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
insert into bh_gop_txt values(b_ma_dvi,b_so_id,'dt_hd',dt_hd);
if b_ttrang in('T','D') then
    select json_object('ma_dvi' value b_ma_dvi,'nsd' value b_nsd,'so_id' value b_so_id,'so_hd' value b_so_hd,
        'kieu_hd' value b_kieu_hd,'nv' value 'GOP','ngay_ht' value b_ngay_ht,'ngay_cap' value b_ngay_cap,
        'ngay_hl' value b_ngay_hl,'ngay_kt' value b_ngay_kt,'cb_ql' value b_ma_cb,'phong' value b_phong,
        'kieu_kt' value b_kieu_kt,'ma_kt' value b_ma_kt,'dly_tke' value ' ','hhong' value b_hhong,'pt_hhong' value 'D',
        'ma_kh' value b_ma_kh,'ten' value b_ten,'kieu_gt' value b_kieu_gt,'ma_gt' value b_ma_gt,'so_id_d' value b_so_idD,'so_id_g' value b_so_idG,
        'ttrang' value b_ttrang,'dvi_ksoat' value b_ma_dvi,'ksoat' value b_nsd,'bangg' value 'bh_gop',
        'c_thue' value b_c_thue,'nt_tien' value b_nt_tien,'nt_phi' value b_nt_phi,'tien' value b_tien,
        'phi' value b_ttoan-b_thue,'thue' value b_thue returning clob) into b_txt from dual;
    PBH_HD_GOC_NH(b_txt,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_GOPH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(3000); b_lenh varchar2(2000); b_i1 number;
    dt_ct clob; dt_hd clob; dt_kytt clob;
-- Chung
    b_so_id number; b_so_hd varchar2(20); b_ngay_ht number; b_ttrang varchar2(1); b_kieu_hd varchar2(1); b_so_hd_g varchar2(20); 
    b_kieu_kt varchar2(1); b_ma_kt varchar2(20); b_kieu_gt varchar2(1); b_ma_gt varchar2(20); b_ma_cb varchar2(20); 
    b_so_hdL varchar2(20); b_loai_kh varchar2(1); b_ma_kh varchar2(20); b_ten nvarchar2(500); b_dchi nvarchar2(500); 
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(50); 
    b_gio_hl varchar2(20); b_ngay_hl number; b_gio_kt varchar2(20); b_ngay_kt number; b_ngay_cap number; 
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_c_thue varchar2(1); 
    b_tl_giam number; b_phi number; b_giam number; b_thue number; b_ttoan number; b_hhong number;
    b_so_idG number; b_so_idD number; b_ngayD number; b_phong varchar2(10); 
    tt_ngay pht_type.a_num; tt_tien pht_type.a_num; 
-- Rieng
    hd_so_id_kem pht_type.a_num; hd_nv pht_type.a_var; hd_loai pht_type.a_var;
    hd_so_kem pht_type.a_var; hd_ttrang pht_type.a_var;
    hd_tien pht_type.a_num; hd_phi pht_type.a_num; hd_thue pht_type.a_num;
-- Xu ly
    b_ngay_htC number;
begin
-- Dan - Nhap
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','GOP','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_hd,dt_kytt');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_hd,dt_kytt using b_oraIn;
if b_so_id<>0 then
    select count(*) into b_i1 from bh_gop where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 then
        select ngay_ht,kieu_hd,ttrang into b_ngay_htC,b_kieu_hd,b_ttrang from bh_gop where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
        if sql%rowcount=0 then b_loi:='loi:Va cham NSD:loi'; raise PROGRAM_ERROR; end if;
        if b_ttrang not in('T','D') then b_kieu_hd:='X'; else b_kieu_hd:='N'; end if;
        PBH_GOP_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_kieu_hd,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
else
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_HD_JS_TEST(
    b_ma_dvi,b_nsd,b_so_id,b_ngay_htC,'bh_gop',dt_ct,dt_kytt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_loai_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,
    b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_ngayD,b_phong,b_ma_cb,b_ma_kh,
    tt_ngay,tt_tien,b_loi,'GOP');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_GOPH_TESTr(
    b_ma_dvi,b_nsd,b_so_idG,dt_ct,dt_hd,
    hd_so_id_kem,hd_nv,hd_loai,hd_so_kem,hd_ttrang,hd_tien,hd_phi,hd_thue,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_GOPH_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,
    dt_ct,dt_hd,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,b_so_hdL,
    b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,
    b_so_idG,b_so_idD,b_ngayD,b_phong,
    tt_ngay,tt_tien,
    hd_so_id_kem,hd_nv,hd_loai,hd_so_kem,hd_ttrang,hd_tien,hd_phi,hd_thue,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hd' value b_so_hd, 'ma_kh' value b_ma_kh) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_GOPH_HD(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(3000); b_lenh varchar2(2000); b_i1 number;
    hd_so_id_kem pht_type.a_num; hd_nv pht_type.a_var; hd_loai pht_type.a_var;
    hd_so_kem pht_type.a_var; hd_ttrang pht_type.a_var;
    hd_tien pht_type.a_num; hd_phi pht_type.a_num; hd_thue pht_type.a_num;
begin
-- Dan - Lay ttin cac hop dong kem
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','GOP','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id_kem,nv,loai');
EXECUTE IMMEDIATE b_lenh bulk collect into hd_so_id_kem,hd_nv,hd_loai using b_oraIn;
if hd_so_id_kem.count=0 then b_loi:='loi:Nhap nghiep vu danh sach kem:loi'; raise PROGRAM_ERROR; end if;
for b_lp in 1..hd_so_id_kem.count loop
    hd_nv(b_lp):=nvl(trim(hd_nv(b_lp)),' '); hd_loai(b_lp):=nvl(trim(hd_loai(b_lp)),' ');
    if hd_nv(b_lp) not in('2B','XE','TAU','PHH','NG','PTN') or hd_loai(b_lp) not in('G','H') then
        b_loi:='loi:Sai nghiep vu, loai danh sach kem:loi'; raise PROGRAM_ERROR;
    end if;
    hd_so_id_kem(b_lp):=nvl(hd_so_id_kem(b_lp),0); hd_so_kem(b_lp):=' ';
    hd_ttrang(b_lp):='C'; hd_tien(b_lp):=0; hd_phi(b_lp):=0; hd_thue(b_lp):=0;
    if hd_so_id_kem(b_lp)=0 then
        PHT_ID_MOI(hd_so_id_kem(b_lp),b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
        hd_so_kem(b_lp):='C.'||substr(to_char(hd_so_id_kem(b_lp)),3);
    elsif hd_nv(b_lp)='2B' then
        select count(*) into b_i1 from bh_2b where ma_dvi=b_ma_dvi and so_id=hd_so_id_kem(b_lp);
        if b_i1=1 then
            select so_hd,ttrang,tien,phi,thue into hd_so_kem(b_lp),hd_ttrang(b_lp),hd_tien(b_lp),hd_phi(b_lp),hd_thue(b_lp)
                from bh_2b where ma_dvi=b_ma_dvi and so_id=hd_so_id_kem(b_lp);
        end if;
    elsif hd_nv(b_lp)='XE' then
        select count(*) into b_i1 from bh_xe where ma_dvi=b_ma_dvi and so_id=hd_so_id_kem(b_lp);
        if b_i1=1 then
            select so_hd,ttrang,tien,phi,thue into hd_so_kem(b_lp),hd_ttrang(b_lp),hd_tien(b_lp),hd_phi(b_lp),hd_thue(b_lp)
                from bh_xe where ma_dvi=b_ma_dvi and so_id=hd_so_id_kem(b_lp);
        end if;
    elsif hd_nv(b_lp)='TAU' then
        select count(*) into b_i1 from bh_tau where ma_dvi=b_ma_dvi and so_id=hd_so_id_kem(b_lp);
        if b_i1=1 then
            select so_hd,ttrang,tien,phi,thue into hd_so_kem(b_lp),hd_ttrang(b_lp),hd_tien(b_lp),hd_phi(b_lp),hd_thue(b_lp)
                from bh_tau where ma_dvi=b_ma_dvi and so_id=hd_so_id_kem(b_lp);
        end if;
    elsif hd_nv(b_lp)='PHH' then
        select count(*) into b_i1 from bh_phh where ma_dvi=b_ma_dvi and so_id=hd_so_id_kem(b_lp);
        if b_i1=1 then
            select so_hd,ttrang,tien,phi,thue into hd_so_kem(b_lp),hd_ttrang(b_lp),hd_tien(b_lp),hd_phi(b_lp),hd_thue(b_lp)
                from bh_phh where ma_dvi=b_ma_dvi and so_id=hd_so_id_kem(b_lp);
        end if;
    elsif hd_nv(b_lp)='NG' then
        select count(*) into b_i1 from bh_ng where ma_dvi=b_ma_dvi and so_id=hd_so_id_kem(b_lp);
        if b_i1=1 then
            select so_hd,ttrang,tien,phi,thue into hd_so_kem(b_lp),hd_ttrang(b_lp),hd_tien(b_lp),hd_phi(b_lp),hd_thue(b_lp)
                from bh_ng where ma_dvi=b_ma_dvi and so_id=hd_so_id_kem(b_lp);
        end if;
    elsif hd_nv(b_lp)='PTN' then
        select count(*) into b_i1 from bh_ptn where ma_dvi=b_ma_dvi and so_id=hd_so_id_kem(b_lp);
        if b_i1=1 then
            select so_hd,ttrang,tien,phi,thue into hd_so_kem(b_lp),hd_ttrang(b_lp),hd_tien(b_lp),hd_phi(b_lp),hd_thue(b_lp)
                from bh_ptn where ma_dvi=b_ma_dvi and so_id=hd_so_id_kem(b_lp);
        end if;
    end if;
end loop;
for b_lp in 1..hd_so_id_kem.count loop
    insert into temp_1(n1,c1,c2,c3,c4,n2,n3,n4,n11) values(hd_so_id_kem(b_lp),hd_nv(b_lp),
        hd_loai(b_lp),hd_so_kem(b_lp),hd_ttrang(b_lp),hd_tien(b_lp),hd_phi(b_lp),hd_thue(b_lp),b_lp);
end loop;
select JSON_ARRAYAGG(json_object('nv' value c1,'loai' value c2,'so_kem' value c3,'ttrang' value c4,
    'tien' value n2,'phi' value n3,'thue' value n4,'so_id_kem' value n1) order by n11 returning clob)
    into b_oraOut from temp_1;
delete temp_1; commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
