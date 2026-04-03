create or replace procedure PBH_BAO_DS_DT_ARR
    (b_ma_dvi varchar2,b_so_id number,a_so_id_dt out pht_type.a_num)
AS
    b_i1 number:=0; b_nv varchar2(10);
    b_kieu_ps varchar2(1); b_so_hd varchar2(20); b_loi varchar2(100);
begin
-- Dan - Liet ke doi tuong theo hop dong
PKH_MANG_KD_N(a_so_id_dt,1);
PTBH_TM_TTIN(b_ma_dvi,b_so_id,b_kieu_ps,b_nv,b_so_hd,b_loi);
if b_loi is not null then return; end if;
if b_kieu_ps='B' then
    if b_nv='PHH' then
        select so_id_dt BULK COLLECT into a_so_id_dt from bh_phhB_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_nv='PKT' then
        select so_id_dt BULK COLLECT into a_so_id_dt from bh_pktB_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_nv='XE' then
        select so_id_dt BULK COLLECT into a_so_id_dt from bh_xeB_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_nv='2B' then
        select so_id_dt BULK COLLECT into a_so_id_dt from bh_2bB_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_nv='TAU' then
        select so_id_dt BULK COLLECT into a_so_id_dt from bh_tauB_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
    end if;
else
    if b_nv='PHH' then
        select so_id_dt BULK COLLECT into a_so_id_dt from bh_phh_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_nv='PKT' then
        select so_id_dt BULK COLLECT into a_so_id_dt from bh_pkt_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_nv='XE' then
        select so_id_dt BULK COLLECT into a_so_id_dt from bh_xe_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_nv='2B' then
        select so_id_dt BULK COLLECT into a_so_id_dt from bh_2b_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_nv='TAU' then
        select so_id_dt BULK COLLECT into a_so_id_dt from bh_tau_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
    end if;
end if;
end;
/
create or replace procedure PBH_BAO_DS_DT_ARRt
    (b_ma_dvi varchar2,b_so_id number,a_so_id_dt out pht_type.a_num,a_ten out pht_type.a_nvar)
AS
    b_i1 number:=0; b_nv varchar2(10);
    b_kieu_ps varchar2(1); b_so_hd varchar2(20); b_loi varchar2(100);
begin
-- Dan - Liet ke doi tuong theo hop dong
PKH_MANG_KD_N(a_so_id_dt,1); PKH_MANG_KD_U(a_ten,1);
PTBH_TM_TTIN(b_ma_dvi,b_so_id,b_kieu_ps,b_nv,b_so_hd,b_loi);
if b_loi is not null then return; end if;
if b_kieu_ps='B' then
    if b_nv='PHH' then
        select so_id_dt,ten BULK COLLECT into a_so_id_dt,a_ten from bh_phhB_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_nv='PKT' then
        select so_id_dt,ten BULK COLLECT into a_so_id_dt,a_ten from bh_pktB_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_nv='XE' then
        select so_id_dt,ten BULK COLLECT into
            a_so_id_dt,a_ten from bh_xeB_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_nv='2B' then
        select so_id_dt,ten BULK COLLECT into
            a_so_id_dt,a_ten from bh_2bB_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_nv='TAU' then
        select so_id_dt,ten BULK COLLECT into
            a_so_id_dt,a_ten from bh_tauB_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
    end if;
else
    if b_nv='PHH' then
        select so_id_dt,dvi BULK COLLECT into a_so_id_dt,a_ten from bh_phh_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_nv='PKT' then
        select so_id_dt,dvi BULK COLLECT into a_so_id_dt,a_ten from bh_pkt_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_nv='XE' then
        select so_id_dt,nvl(trim(bien_xe),so_khung) BULK COLLECT into
            a_so_id_dt,a_ten from bh_xe_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_nv='2B' then
        select so_id_dt,nvl(trim(bien_xe),so_khung) BULK COLLECT into
            a_so_id_dt,a_ten from bh_2b_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_nv='TAU' then
        select so_id_dt,nvl(trim(so_dk),ten_tau) BULK COLLECT into
            a_so_id_dt,a_ten from bh_tau_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
    end if;
end if;
end;
/
create or replace function FBH_BAO_BANG(b_nv varchar2) return varchar2
AS
    b_kq varchar2(50);
begin
-- Dan - Tra ten bang hop dong qua nghiep vu
if b_nv='XE' then b_kq:='bh_xeB';
elsif b_nv='2B' then b_kq:='bh_2bB';
elsif b_nv='TAU' then b_kq:='bh_tauB';
elsif b_nv='PHH' then b_kq:='bh_phhB';
elsif b_nv='PKT' then b_kq:='bh_pktB';
elsif b_nv='NG' then b_kq:='bh_ngB';
elsif b_nv='HANG' then b_kq:='bh_hangB';
elsif b_nv='PTN' then b_kq:='bh_ptnB';
elsif b_nv='HOP' then b_kq:='bh_hopB';
end if;
return b_kq;
end;
/
create or replace function FBH_BAO_BGHD(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(10):=' '; b_nv varchar2(10);
begin
b_nv:=FBH_BAO_NV(b_ma_dvi,b_so_id);
if b_nv is not null then
    if b_nv='PHH' then b_kq:=FBH_BAO_BGHD_PHH(b_ma_dvi,b_so_id);
    elsif b_nv='PKT' then b_kq:=FBH_BAO_BGHD_PKT(b_ma_dvi,b_so_id);
    elsif b_nv='XE' then b_kq:=FBH_BAO_BGHD_XE(b_ma_dvi,b_so_id);
    elsif b_nv='2B' then b_kq:=FBH_BAO_BGHD_2B(b_ma_dvi,b_so_id);
    elsif b_nv='TAU' then b_kq:=FBH_BAO_BGHD_TAU(b_ma_dvi,b_so_id);
    elsif b_nv='NG' then b_kq:=FBH_BAO_BGHD_NG(b_ma_dvi,b_so_id);
    elsif b_nv='HANG' then b_kq:=FBH_BAO_BGHD_HANG(b_ma_dvi,b_so_id);
    elsif b_nv='PTN' then b_kq:=FBH_BAO_BGHD_PTN(b_ma_dvi,b_so_id);
    elsif b_nv='HOP' then b_kq:=FBH_BAO_BGHD_HOP(b_ma_dvi,b_so_id);
    end if;
end if;
return b_kq;
end;
/
create or replace procedure PBH_BAO_NV_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_so_hd varchar2,b_nv varchar2,b_ttrang varchar2,
    b_phong varchar2,b_ma_kh varchar2,b_ten nvarchar2,b_ngay_ht number,b_ngay_hl number,b_ngay_kt number,
    b_nt_tien varchar2,b_tien number,b_nt_phi varchar2,b_phi number,b_loi out varchar2)
AS
begin
-- Dan - Nhap
insert into bh_bao values(b_ma_dvi,b_so_id,b_so_hd,b_nv,b_ttrang,b_phong,b_ma_kh,
    b_ten,b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_tien,b_nt_phi,b_phi,b_nsd,' ',' ');
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi nhap Table bh_bao:loi'; end if;
end;
/
create or replace procedure PBH_BAO_NV_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh varchar2,b_loi out varchar2)
AS
begin
-- Dan - Xoa
if b_nh='X' then
    PBH_HD_DO_TL_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
    if b_loi is not null then return; end if;
    PTBH_TMB_CBI_XOA(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
end if;
delete bh_bao where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xoa Table bh_bao:loi'; end if;
end;
/
create or replace function FBH_BAO_SO_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(20);
begin
-- Dan - Tra so_hd
select min(so_hd) into b_kq from bh_bao where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BAO_NV(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan - Tra nghiep vu
select nvl(min(nv),' ') into b_kq from bh_bao where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BAO_TTRANG(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan - Tra ttrang
select nvl(min(ttrang),' ') into b_kq from bh_bao where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
-- chuclh: tạm - db khac
create or replace procedure FBH_BAO_TTRANGn(
    b_ma_dvi varchar2,b_so_id number,b_ttrang varchar2,b_loi out varchar2)
AS
    b_i1 number; b_vuot varchar2(1);
begin-- Dan - Tra tinh trang sau khi nhap
if b_ttrang in('D','T') then
    select count(*) into b_i1 from tbh_tmB_hd where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id;
    if b_i1=0 then
        FTBH_BAO_TLv(b_ma_dvi,b_so_id,b_vuot,b_loi);
        if b_loi is not null then return; end if;
        if b_vuot='C' then
            if b_ttrang='T' then
                PTBH_TMB_CBI_NH(b_ma_dvi,b_so_id,b_loi);
                if b_loi is not null then return; end if;
            else 
                b_loi:='loi:Chua xu ly chao tai tam thoi:loi'; return;
            end if;
        end if;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_BAO_TTRANGn:loi'; end if;
end;
/
create or replace PROCEDURE FTBH_BAO_NV(
    b_ma_dvi varchar2,b_so_id number,
    a_so_id_dtB out pht_type.a_num,a_ghepB out pht_type.a_var,
    a_so_id_dtBG out pht_type.a_num,a_ma_dviG out pht_type.a_var,
    a_so_idG out pht_type.a_num,a_so_id_dtG out pht_type.a_num,b_loi out varchar2)
AS
    b_nv varchar2(10);
begin
-- Dan - Tim doi tuong trong bao gia va cac doi tuong ghep
b_nv:=FBH_BAO_NV(b_ma_dvi,b_so_id);
if b_nv is null then b_loi:=''; return; end if;
PKH_MANG_KD_N(a_so_id_dtB); PKH_MANG_KD(a_ghepB);
PKH_MANG_KD_N(a_so_id_dtBG); PKH_MANG_KD(a_ma_dviG); PKH_MANG_KD_N(a_so_idG); PKH_MANG_KD_N(a_so_id_dtG);
if b_nv='PHH' then
    PTBH_BAO_GHDT_PHH(b_ma_dvi,b_so_id,
        a_so_id_dtB,a_ghepB,a_so_id_dtBG,a_ma_dviG,a_so_idG,a_so_id_dtG,b_loi);
    if b_loi is not null then return; end if;
elsif b_nv='PKT' then
    PTBH_BAO_GHDT_PKT(b_ma_dvi,b_so_id,
        a_so_id_dtB,a_ghepB,a_so_id_dtBG,a_ma_dviG,a_so_idG,a_so_id_dtG,b_loi);
    if b_loi is not null then return; end if;
elsif b_nv='XE' then
    PTBH_BAO_GHDT_XE(b_ma_dvi,b_so_id,a_so_id_dtB,b_loi);
    if b_loi is not null then return; end if;
elsif b_nv='2B' then
    PTBH_BAO_GHDT_2B(b_ma_dvi,b_so_id,a_so_id_dtB,b_loi);
    if b_loi is not null then return; end if;
elsif b_nv='TAU' then
    PTBH_BAO_GHDT_TAU(b_ma_dvi,b_so_id,a_so_id_dtB,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FTBH_BAO_NV:loi'; end if;
end;
/
create or replace procedure FTBH_BAO_NVc(
    b_nv varchar2,b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,
    a_ma_dvi pht_type.a_var,a_kieu pht_type.a_var,a_so_id pht_type.a_num,a_so_id_dt pht_type.a_num,
    b_ma_dt out varchar2,b_loi out varchar2)
as
begin
-- Dan
b_ma_dt:=' ';
if b_nv='PHH' then
    PTBH_BAO_NV_PHHc(b_ma_dvi,b_so_id,b_so_id_dt,a_ma_dvi,a_kieu,a_so_id,a_so_id_dt,b_ma_dt,b_loi);
elsif b_nv='PKT' then
    PTBH_BAO_NV_PKTc(b_ma_dvi,b_so_id,b_so_id_dt,a_ma_dvi,a_kieu,a_so_id,a_so_id_dt,b_ma_dt,b_loi);
elsif b_nv='HANG' then
    PTBH_BAO_NV_HANGc(b_ma_dvi,b_so_id,a_ma_dvi,a_kieu,a_so_id,b_ma_dt,b_loi);
    if b_loi is not null then return; end if;
elsif b_nv='TAU' then
    PTBH_BAO_NV_TAUc(b_ma_dvi,b_so_id,b_so_id_dt,b_ma_dt,b_loi);
    if b_loi is not null then return; end if;
elsif b_nv='XE' then
    PTBH_BAO_NV_XEc(b_ma_dvi,b_so_id,b_so_id_dt,b_ma_dt,b_loi);
    if b_loi is not null then return; end if;
elsif b_nv='2B' then
    PTBH_BAO_NV_2Bc(b_ma_dvi,b_so_id,b_so_id_dt,b_ma_dt,b_loi);
    if b_loi is not null then return; end if;
elsif b_nv='NG' then
    PTBH_BAO_NV_NGc(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
elsif b_nv='PTN' then
    PTBH_BAO_NV_PTNc(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
end if;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FTBH_BAO_NVc:loi'; end if;
end;
/
create or replace procedure PTBH_BAO_TLc(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,
    a_ma_dvi pht_type.a_var,a_kieu pht_type.a_var,
    a_so_id pht_type.a_num,a_so_id_dt pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_nv varchar2(10); b_nt_tien varchar2(5); b_nt_phi varchar2(5);
    b_ngay_ht number; b_ngay_hl number; b_ngay_kt number; b_kieu varchar2(1);
    b_so_id_ta number; b_tp number:=0; b_pt number; b_ma_dt varchar2(10);
    b_tien number; b_nguong number; b_glai number; b_ghan number; b_tlp number;
    b_so_hd varchar2(20); b_cdt varchar2(10):=' '; b_kieu_ps varchar2(1); b_uot varchar2(1):='K';
    a_so_id_ta pht_type.a_num; a_pthuc pht_type.a_var; a_pp pht_type.a_var;
    a_ma_ta pht_type.a_var; a_pt_c pht_type.a_num; a_tlp pht_type.a_num;
    a_tien_c pht_type.a_num; a_tien_xl pht_type.a_num; a_tien_g pht_type.a_num;
    a_do_tl pht_type.a_num; a_ta_tl pht_type.a_num;
    a_do_tien pht_type.a_num; a_ta_tien pht_type.a_num;
begin
-- Dan - Tinh phan bo ty le tai cho 1 doi tuong
delete tbh_ghep_tl_temp;
PTBH_TM_TTINf(a_ma_dvi(1),a_so_id(1),b_kieu_ps,b_nv,b_so_hd,b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_loi);
if b_loi is not null then return; end if;
if b_nt_tien<>'VND' then b_tp:=2; end if;
FTBH_BAO_NVc(b_nv,b_ma_dvi,b_so_id,b_so_id_dt,a_ma_dvi,a_kieu,a_so_id,a_so_id_dt,b_ma_dt,b_loi);
if b_loi is not null then return; end if;
select ma_ta,tien,phi,do_tien+ve_tien,do_tl+ve_tl,ta_tien,ta_tl BULK COLLECT into
    a_ma_ta,a_tien_g,a_tlp,a_do_tien,a_do_tl,a_ta_tien,a_ta_tl from tbh_ghep_nv_temp order by ma_ta;
for b_lp in 1..a_ma_ta.count loop
    a_pt_c(b_lp):=100-a_ta_tl(b_lp)-a_do_tl(b_lp); a_tien_c(b_lp):=a_tien_g(b_lp)-a_ta_tien(b_lp)-a_do_tien(b_lp);
    a_tien_xl(b_lp):=a_tien_c(b_lp);
    if a_tien_g(b_lp)=0 then a_tlp(b_lp):=0;
    else a_tlp(b_lp):=a_tlp(b_lp)*100/a_tien_g(b_lp);
    end if;
end loop;
--nam
if a_ma_dvi.count=1 then
    b_cdt:=FTBH_SOANd_TXT(a_ma_dvi(1),a_so_id(1),a_so_id_dt(1),'cdt');
end if;
if b_nv='PKT' then b_uot:=FBH_PKT_DK_UOTn(a_ma_dvi,a_so_id,a_so_id_dt); end if;
--nam
if b_cdt=' ' or instr(b_cdt,'C')<>0 then
   for b_lp in 1..a_ma_ta.count loop
        FTBH_HD_DI_NV_SO_ID(b_nv,a_ma_ta(b_lp),b_ma_dt,b_ngay_hl,a_so_id_ta,a_pthuc,a_pp,b_loi);
        if b_loi is not null then return; end if;
        for b_ta in 1..a_so_id_ta.count loop
            if a_pt_c(b_lp)>.01 then
                FTBH_HD_DI_GLAI(b_ma_dvi,a_so_id_ta(b_ta),a_ma_ta(b_lp),b_ma_dt,1,
                    b_nt_tien,a_do_tl(b_lp),0,b_ngay_hl,b_nguong,b_glai,b_ghan,b_tlp,b_loi,'K',b_uot);
                if b_loi is not null then return; end if;
                if b_nguong<0 or a_tien_c(b_lp)<b_nguong or (b_glai>100 and a_tien_c(b_lp)<=b_glai) or
                    (b_glai<>0 and b_glai<=100 and a_pt_c(b_lp)<b_glai) then
                    a_pt_c(b_lp):=0; a_tien_c(b_lp):=0;
                else
                    if a_pp(b_ta)='Q' then
                        if b_glai<>0 and b_glai<=100 then b_pt:=100-b_glai;
                        else
                            b_pt:=100-round(b_glai*100/a_tien_g(b_lp),2);
                        end if;
                        if a_pt_c(b_lp)<>100 then b_pt:=ROUND(b_pt*a_pt_c(b_lp)/100,2); end if;
                    elsif b_glai<>0 and b_glai<=100 then
                        b_pt:=100-b_glai;
                        if a_pt_c(b_lp)<>100 then b_pt:=ROUND(b_pt*a_pt_c(b_lp)/100,2); end if;
                    else
                        b_tien:=a_tien_c(b_lp)-b_glai; b_pt:=round(b_tien*100/a_tien_g(b_lp),2);
                    end if;
                    if b_ghan<>0 and b_ghan<=100 and b_ghan<b_pt then b_pt:=b_glai; end if;
                    b_tien:=round(a_tien_g(b_lp)*b_pt/100,b_tp);
                    if b_ghan<>0 and b_ghan<b_tien then
                        b_tien:=b_ghan; b_pt:=round(b_tien*100/a_tien_g(b_lp),2);
                    end if;
                    if b_pt>a_pt_c(b_lp) then b_pt:=a_pt_c(b_lp); b_tien:=a_tien_c(b_lp); end if;
                    if b_pt>0 then
                        a_pt_c(b_lp):=a_pt_c(b_lp)-b_pt; a_tien_c(b_lp):=a_tien_c(b_lp)-b_tien;
                        insert into tbh_ghep_tl_temp values(a_so_id_ta(b_ta),a_pp(b_ta),a_ma_ta(b_lp),b_pt,b_tien,b_tlp,0,0);
                    end if;
                end if;
            end if;
        end loop;
    end loop;
end if;
--nam
if b_cdt=' ' or instr(b_cdt,'F')<>0 then
    b_so_id_ta:=FTBH_MGIU_SO_ID(b_nv,b_ngay_hl);
    if b_so_id_ta=0 then b_loi:=''; return; end if;
    for b_lp in 1..a_ma_ta.count loop
        b_glai:=FTBH_MGIU_GLAI(b_ma_dvi,b_so_id_ta,a_ma_ta(b_lp),b_ma_dt,b_nt_tien,a_do_tl(b_lp),0,b_ngay_hl);
        if b_glai<>0 and ((b_glai>100 and a_tien_c(b_lp)>b_glai) or (b_glai<100 and a_pt_c(b_lp)>b_glai)) then
            if b_glai<=100 then
                b_pt:=b_glai;
                b_tien:=round(a_tien_g(b_lp)*b_glai/100,b_tp);
            else
                b_tien:=b_glai; b_pt:=round(b_tien*100/a_tien_g(b_lp),2);
                if b_pt>a_pt_c(b_lp) then b_pt:=a_pt_c(b_lp); b_tien:=a_tien_c(b_lp); end if;
            end if;
            a_pt_c(b_lp):=a_pt_c(b_lp)-b_pt; a_tien_c(b_lp):=a_tien_c(b_lp)-b_tien;
            if a_pt_c(b_lp)>.01 then
                insert into tbh_ghep_tl_temp values(0,'O',a_ma_ta(b_lp),a_pt_c(b_lp),a_tien_c(b_lp),0,0,0);
            end if;
        end if;
    end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_BAO_TLc:loi'; end if;
end;
/
create or replace procedure PTBH_BAO_TLv(
    b_ma_dvi varchar2,b_so_id number,a_so_id_dtV out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_kt number; b_so_id_dtB number; b_nv varchar2(10);
    a_so_id_dtB pht_type.a_num; a_ghepB pht_type.a_var;
    a_so_id_dtBG pht_type.a_num; a_ma_dviG pht_type.a_var;
    a_so_idG pht_type.a_num; a_so_id_dtG pht_type.a_num;

    a_ma_dvi pht_type.a_var; a_so_id pht_type.a_num; a_so_id_dt pht_type.a_num;
begin
-- Dan - Kiem tra bao gia vuot nguong
b_loi:='loi:Loi xu ly PTBH_BAO_TLv:loi';
PKH_MANG_KD_N(a_so_id_dtV);
select nvl(min(nv),' ') into b_nv from bh_bao where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nv=' ' then b_loi:=''; return; end if;
FTBH_BAO_NV(b_ma_dvi,b_so_id,a_so_id_dtB,a_ghepB,
    a_so_id_dtBG,a_ma_dviG,a_so_idG,a_so_id_dtG,b_loi);
if b_loi is not null then return; end if;
PKH_MANG_KD(a_ma_dvi); PKH_MANG_KD_N(a_so_id); PKH_MANG_KD_N(a_so_id_dt);
if a_so_id_dtB.count=0 then
    a_ma_dvi(1):=b_ma_dvi; a_so_id(1):=b_so_id; a_so_id_dt(1):=0;
    PTBH_BAO_TLd(b_ma_dvi,b_so_id,0,b_nv,a_ma_dvi,a_so_id,a_so_id_dt,b_loi);
    if b_loi is not null then return; end if;
    select count(*) into b_i1 from tbh_ghep_tl_temp where pthuc='O';
    if b_i1<>0 then
        b_i1:=a_so_id_dtV.count+1;
        a_so_id_dtV(1):=0;
    end if;
else
    for b_lp in 1..a_so_id_dtB.count loop
        PKH_MANG_XOA(a_ma_dvi); PKH_MANG_XOA_N(a_so_id); PKH_MANG_XOA_N(a_so_id_dt);
        b_so_id_dtB:=a_so_id_dtB(b_lp); b_kt:=1;
        a_ma_dvi(1):=b_ma_dvi; a_so_id(1):=b_so_id; a_so_id_dt(1):=b_so_id_dtB;
        for b_lp1 in 1..a_so_id_dtBG.count loop
            if a_so_id_dtBG(b_lp1)=b_so_id_dtB then
                b_kt:=b_kt+1;
                a_ma_dvi(b_kt):=a_ma_dviG(b_lp1); a_so_id(b_kt):=a_so_idG(b_lp1); a_so_id_dt(b_kt):=a_so_id_dtG(b_lp1); 
            end if;
        end loop;
        PTBH_BAO_TLd(b_ma_dvi,b_so_id,b_so_id_dtB,b_nv,a_ma_dvi,a_so_id,a_so_id_dt,b_loi);
        if b_loi is not null then return; end if;
        select count(*) into b_i1 from tbh_ghep_tl_temp where pthuc='O';
        if b_i1<>0 then
            b_i1:=a_so_id_dtV.count+1;
            a_so_id_dtV(b_i1):=b_so_id_dtB;
        end if;
    end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_BAO_TLv:loi'; end if;
end;
/
create or replace procedure FTBH_BAO_TLv(
    b_ma_dvi varchar2,b_so_id number,b_vuot out varchar2,b_loi out varchar2)
AS
    a_so_id_dtV pht_type.a_num;
begin
-- Dan - Kiem tra bao gia vuot nguong
PTBH_BAO_TLv(b_ma_dvi,b_so_id,a_so_id_dtV,b_loi);
if b_loi is not null then return; end if;
if a_so_id_dtV.count<>0 then b_vuot:='C'; else b_vuot:='K'; end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FTBH_BAO_TLv:loi'; end if;
end;
/
create or replace procedure PTBH_BAO_PHIc(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,
    a_ma_dvi pht_type.a_var,a_kieu pht_type.a_var,a_so_id pht_type.a_num,a_so_id_dt pht_type.a_num,
    a_ma_ta pht_type.a_var,a_pt pht_type.a_num,a_phi out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_nv varchar2(10); b_nt_phi varchar2(5); b_tp number:=0; b_ma_dt varchar2(10);
    a_ma_taT pht_type.a_var; a_phiT pht_type.a_num;
begin
-- Dan - Tinh phi cho 1 doi tuong
delete tbh_ghep_tl_temp;
select count(*) into b_i1 from bh_bao where ma_dvi=a_ma_dvi(1) and so_id=a_so_id(1);
if b_i1<>0 then
    select nv,nt_phi into b_nv,b_nt_phi from bh_bao where ma_dvi=a_ma_dvi(1) and so_id=a_so_id(1);
else
    select nv,nt_phi into b_nv,b_nt_phi from bh_hd_goc where ma_dvi=a_ma_dvi(1) and so_id=a_so_id(1);
end if;
if b_nt_phi<>'VND' then b_tp:=2; end if;
FTBH_BAO_NVc(b_nv,b_ma_dvi,b_so_id,b_so_id_dt,a_ma_dvi,a_kieu,a_so_id,a_so_id_dt,b_ma_dt,b_loi);
if b_loi is not null then return; end if;
select ma_ta,sum(phi) BULK COLLECT into a_ma_taT,a_phiT from tbh_ghep_nv_temp group by ma_ta;
for b_lp in 1..a_ma_ta.count loop
    b_i1:=FKH_ARR_VTRI(a_ma_taT,a_ma_ta(b_lp));
    if b_i1=0 then a_phi(b_lp):=0;
    else
        a_phi(b_lp):=round(a_phiT(b_i1)*a_pt(b_lp)/100,b_tp);
    end if;
end loop;
delete tbh_ghep_nv_temp;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_BAO_PHIc:loi'; end if;

end;
/
create or replace procedure PBH_BAO_TTRANG(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number; b_vuot varchar2(10);
    cs_ttr clob:='';
begin
-- Dan - Kiem tra vuot
delete bh_hd_ttrang_temp; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_vuot:=FBH_BAO_TTRANG(b_ma_dvi,b_so_id);
if b_vuot in ('T','D') then
    b_vuot:=FBH_BAO_BGHD(b_ma_dvi,b_so_id);
    if b_vuot<>' ' then
        insert into bh_hd_ttrang_temp values('bg_hd','V');
    end if;
    select count(*) into b_i1 from tbh_tmB where ma_dviP=b_ma_dvi and so_idP=b_so_id;
    if b_i1<>0 then
        insert into bh_hd_ttrang_temp values('ta_tle','V');
    else
        FTBH_BAO_TLv(b_ma_dvi,b_so_id,b_vuot,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
        if b_vuot='C' then
            insert into bh_hd_ttrang_temp values('ta_tle','D');
        end if;
    end if;
    select count(*) into b_i1 from bh_hd_do_tl where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 then insert into bh_hd_ttrang_temp values('do_tle','V'); end if;
    select count(*) into b_i1 from bh_hd_ttrang_temp;
    if b_i1<>0 then
        select JSON_ARRAYAGG(json_object(nv,tt) returning clob) into cs_ttr from bh_hd_ttrang_temp;
    end if;
end if;
select json_object('cs_ttr' value cs_ttr) into b_oraOut from dual;
delete bh_hd_ttrang_temp; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BAO_DTVU(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); cs_vu clob:='';
    b_ma_dvi varchar2(10); b_so_id number; b_nv varchar2(10); b_txt nvarchar2(1000);
    a_so_id_dtV pht_type.a_num; a_tenV pht_type.a_num;
begin
-- Dan - Danh sach doi tuong vuot
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_nv:=FBH_BAO_NV(b_ma_dvi,b_so_id);
if b_nv is null then b_loi:='loi:Bao gia da xoa:loi'; raise PROGRAM_ERROR; end if;
PTBH_BAO_TLv(b_ma_dvi,b_so_id,a_so_id_dtV,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if a_so_id_dtV.count<>0 then
    if b_nv='PHH' then
        for b_lp in 1..a_so_id_dtV.count loop
            select ten into a_tenV(b_lp) from bh_phhB_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=a_so_id_dtV(b_lp);
        end loop;
    elsif b_nv='PKT' then
        for b_lp in 1..a_so_id_dtV.count loop
            select ten into a_tenV(b_lp) from bh_pktB_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=a_so_id_dtV(b_lp);
        end loop;
    elsif b_nv='XE' then
        for b_lp in 1..a_so_id_dtV.count loop
            select ten into a_tenV(b_lp) from bh_xeB_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=a_so_id_dtV(b_lp);
        end loop;
    elsif b_nv='2B' then
        for b_lp in 1..a_so_id_dtV.count loop
            select ten into a_tenV(b_lp) from bh_2bB_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=a_so_id_dtV(b_lp);
        end loop;
    elsif b_nv='TAU' then
        for b_lp in 1..a_so_id_dtV.count loop
            select ten into a_tenV(b_lp) from bh_tauB_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=a_so_id_dtV(b_lp);
        end loop;
    end if;
    cs_vu:='[';
    for b_lp in 1..a_so_id_dtV.count loop
        if b_lp>1 then cs_vu:=cs_vu||','; end if;
        select json_object('ma' value to_char(a_so_id_dtV(b_lp)),'ten' value a_tenV(b_lp)) into b_txt from dual;
        cs_vu:=cs_vu||b_txt;
    end loop;
    cs_vu:=cs_vu||']';
end if;
select json_object('cs_vu' value cs_vu) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BAO_HDVU(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); cs_vu clob:='';
    b_ma_dvi varchar2(10); b_so_id number; b_nv varchar2(10); b_txt nvarchar2(1000);
    a_so_id_dtV pht_type.a_num; a_tenV pht_type.a_num;
begin
-- Dan - Ktra Hdong vuot
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','TA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_nv:=FBH_BAO_NV(b_ma_dvi,b_so_id);
if b_nv is null then b_loi:='loi:Bao gia da xoa:loi'; raise PROGRAM_ERROR; end if;
PTBH_BAO_TLv(b_ma_dvi,b_so_id,a_so_id_dtV,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if a_so_id_dtV.count<>0 then b_oraOut:='C'; else b_oraOut:='K'; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_BAO_PHI(
    b_ma_dvi varchar2,b_oraIn clob,cs_phi out clob,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_i2 number; b_kt number; b_tso varchar2(200);
    b_ngD number; b_ngC number; b_so_id number; b_nv varchar2(10); b_so_ctG varchar2(20);
    b_ngay_ht number; b_ngay_hl number; b_ngay_kt number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);

    a_ma_dvi pht_type.a_var; a_so_hd pht_type.a_var; a_so_id pht_type.a_num;
    a_so_id_dt pht_type.a_num; a_ng_hl pht_type.a_num;
    a_so_id_ta pht_type.a_num; a_pthuc pht_type.a_var; a_ma_ta pht_type.a_var;
    a_pt pht_type.a_num; a_tien pht_type.a_num; a_tlp pht_type.a_num;
    a_ma_dviQ pht_type.a_var; a_so_idQ pht_type.a_num; a_so_id_dtQ pht_type.a_num;
    a_so_id_taQ pht_type.a_num; a_pthucQ pht_type.a_var; a_ma_taQ pht_type.a_var;
    a_ptQ pht_type.a_num; a_tienQ pht_type.a_num; a_phiQ pht_type.a_num;
    dt_ct clob; dt_hd clob;
begin
-- Tinh phi
delete tbh_ghep_ky_phi_temp; delete tbh_ghep_phi_temp2;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_hd');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_hd using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JS_NULL(dt_hd);
b_lenh:=FKH_JS_LENH('nv,ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi,so_ctg');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_so_ctG using dt_ct;
b_lenh:=FKH_JS_LENH('ma_dvi_hd,so_hd,so_id_dt');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma_dvi,a_so_hd,a_so_id_dt using dt_hd;
b_so_ctG:=trim(b_so_ctG);
if b_so_ctG is not null then
    b_so_id:=FTBH_GHEP_SO_CTd(b_so_ctG);
    if b_so_id=0 then
        b_so_id:=FTBH_TM_SO_CTd(b_so_ctG);
    end if;
end if;
for b_lp in 1..a_ma_dvi.count loop
    a_so_id(b_lp):=FBH_HD_GOC_SO_ID_DAU(a_ma_dvi(b_lp),a_so_hd(b_lp));
end loop;
FBH_HD_NGAYh_ARR(a_ma_dvi,a_so_id,b_ngD,b_ngC);
if b_ngay_hl in(0,30000101) then b_ngay_hl:=b_ngD; end if;
if b_ngay_kt in(0,30000101) then b_ngay_kt:=b_ngC; end if;
PTBH_GHEP_DOAN(b_ma_dvi,b_nv,b_so_ctG,b_ngay_ht,b_ngay_hl,b_ngay_kt,a_ma_dvi,a_so_id,a_so_id_dt,a_ng_hl,b_loi);
if b_loi is not null then return; end if;
b_kt:=a_ng_hl.count;
for b_lp in 1..b_kt loop
    if a_ng_hl(b_lp)<b_ngay_hl or a_ng_hl(b_lp)>=b_ngay_kt then a_ng_hl(b_lp):=0; end if;
end loop;
PKH_MANG_N(a_ng_hl);
b_kt:=a_ng_hl.count;
PKH_MANG_KD(a_ma_dviQ);
b_tso:='{"ttrang":"T","xly":"F"}';
for b_lp in 1..b_kt loop
	delete tbh_ghep_tl_temp;
    PTBH_GHEP_TL(b_so_id,a_ng_hl(b_lp),b_ngay_hl,b_nv,b_nt_tien,b_nt_phi,a_ma_dvi,a_so_id,a_so_id_dt,b_loi,b_tso);
    if b_loi is not null then return; end if;
    select so_id_ta,pthuc,ma_ta,pt,tien,tlp bulk collect into a_so_id_ta,a_pthuc,a_ma_ta,a_pt,a_tien,a_tlp
        from tbh_ghep_tl_temp where so_id_ta<>0;
    if a_pthuc.count<>0 then
        b_i1:=a_ma_dviQ.count;
        for b_lp3 in 1..a_pthuc.count loop
            for b_lp1 in 1..a_ma_dvi.count loop
                b_i2:=0;
                for b_lp2 in 1..b_i1 loop
                    if a_so_id_taQ(b_lp2)=a_so_id_ta(b_lp3) and a_pthucQ(b_lp2)=a_pthuc(b_lp3) and
                        a_ma_taQ(b_lp2)=a_ma_ta(b_lp3) and a_ma_dviQ(b_lp2)=a_ma_dvi(b_lp1) and
                        a_so_idQ(b_lp2)=a_so_id(b_lp1) and a_so_id_dtQ(b_lp2)=a_so_id_dt(b_lp1) then
                        b_i2:=1; exit;
                    end if;
                end loop;
                if b_i2=0 then
                    b_i1:=b_i1+1;
                    a_ma_dviQ(b_i1):=a_ma_dvi(b_lp1); a_so_idQ(b_i1):=a_so_id(b_lp1); a_so_id_dtQ(b_i1):=a_so_id_dt(b_lp1);
                    a_so_id_taQ(b_i1):=a_so_id_ta(b_lp3); a_pthucQ(b_i1):=a_pthuc(b_lp3);
                    a_ma_taQ(b_i1):=a_ma_ta(b_lp3); a_phiQ(b_i1):=0;
                end if;
            end loop;
        end loop;
        if b_lp=b_kt then b_i1:=b_ngay_kt;
        else
            b_i1:=PKH_NG_CSO(PKH_SO_CDT(a_ng_hl(b_lp+1))-1);
            if b_i1>b_ngay_kt then b_i1:=b_ngay_kt; end if;
        end if;
        PTBH_GHEP_TINH_PHI_D(b_ma_dvi,b_so_id,b_nv,a_ng_hl(b_lp),b_ngay_hl,b_i1,b_nt_tien,b_nt_phi,
            a_ma_dvi,a_so_id,a_so_id_dt,
            a_so_id_ta,a_pthuc,a_ma_ta,a_pt,a_tien,a_tlp,
            a_ma_dviQ,a_so_idQ,a_so_id_dtQ,a_so_id_taQ,a_pthucQ,a_ma_taQ,a_phiQ,b_loi,'C');
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
end loop;
select JSON_ARRAYAGG(json_object(ngay_hl,ma_ta,pt,tien,phi,
    tl_thue,thue,pt_hh,hhong,'so_id_ta' value FTBH_HD_DI_SO_HDl(so_id_ta))
    order by ngay_hl,ma_ta returning clob) into cs_phi from tbh_ghep_ky_phi_temp;
delete tbh_ghep_tl_temp; delete tbh_ghep_ky_phi_temp; delete tbh_ghep_phi_temp2;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
create or replace procedure PTBH_BAO_TEMP2(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay_ht number,
    b_nt_tien varchar2,b_nt_phi varchar2,b_loi out varchar2)
as
    b_tpT number:=0; b_tpP number:=0; b_tg number:=1;
begin
-- Dan - Tap hop tbh_ghep_nv_temp2
delete tbh_ghep_nv_temp1; delete tbh_ghep_nv_temp2; delete tbh_ghep_nv_temp3;
insert into tbh_ghep_nv_temp1 select 0,'',a.lh_nv,a.nt_tien,0,a.nt_phi,0,0,
    sum(FBH_DONG_TL_TIEN(b_ma_dvi,b_so_id,b_so_id_dt,a.lh_nv,a.tien)),0,0,0,0,0,0
    from bh_hd_nv_temp a group by a.lh_nv,a.nt_tien,a.nt_phi;
delete tbh_ghep_nv_temp1 where do_tien=0 and ve_tien=0;
insert into tbh_ghep_nv_temp1 select 0,'',lh_nv,nt_tien,tien,nt_phi,phi,0,0,0,0,0,0,0,0 from bh_hd_nv_temp;
update tbh_ghep_nv_temp1 set ma_ta=FBH_MA_LHNV_TAI(lh_nv);
delete tbh_ghep_nv_temp1 where trim(ma_ta) is null;
if b_nt_tien<>'VND' then b_tpT:=2; end if;
if b_nt_phi<>'VND' then b_tpP:=2; end if;
for r_lp in (select distinct nt_tien from tbh_ghep_nv_temp1 where nt_tien<>b_nt_tien) loop
    b_tg:=FBH_TT_TGTT_TUNG(b_ngay_ht,r_lp.nt_tien,b_nt_tien);
    update tbh_ghep_nv_temp1 set
        tien=round(tien*b_tg,b_tpT),
        do_tien=round(do_tien*b_tg,b_tpT),
        ta_tien=round(ta_tien*b_tg,b_tpT),
        ve_tien=round(ve_tien*b_tg,b_tpT) where nt_tien=r_lp.nt_tien;
end loop;
update tbh_ghep_nv_temp1 set phi=FBH_TT_TUNG_QD(b_ngay_ht,nt_phi,phi,b_nt_phi) where nt_phi<>b_nt_phi;
insert into tbh_ghep_nv_temp3
    select so_id,ma_ta,b_nt_tien,sum(tien),b_nt_phi,sum(phi),0,sum(do_tien),0,sum(ta_tien),0,sum(tm_tien),0,sum(ve_tien)
    from tbh_ghep_nv_temp1 group by so_id,ma_ta;
insert into tbh_ghep_nv_temp2
    select ma_ta,b_nt_tien,sum(tien),b_nt_phi,sum(phi),0,sum(do_tien),0,sum(ta_tien),0,sum(tm_tien),0,sum(ve_tien)
    from tbh_ghep_nv_temp3 group by ma_ta having sum(tien)<>0;
delete tbh_ghep_nv_temp1; delete tbh_ghep_nv_temp3;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_BAO_TEMP2:loi'; end if;
end;
/
create or replace procedure PTBH_BAO_TEMP(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,
    b_nt_tien varchar2,b_nt_phi varchar2,b_loi out varchar2)
as
    b_tp number:=0;
    a_ma_taT pht_type.a_var; a_ptT pht_type.a_num;
begin
-- Dan - Tap hop tbh_ghep_nv_temp
delete tbh_ghep_nv_temp;
if b_nt_tien<>'VND' then b_tp:=2; end if;
insert into tbh_ghep_nv_temp
    select ma_ta,b_nt_tien,sum(tien),b_nt_phi,sum(phi),0,sum(do_tien),0,sum(ta_tien),0,sum(tm_tien),0,sum(ve_tien)
    from tbh_ghep_nv_temp2 group by ma_ta having sum(tien)<>0 or sum(phi)<>0;
select b.ma_ta,sum(b.pt) bulk collect into a_ma_taT,a_ptT from tbh_tmB a,tbh_tmB_phi b where
    a.ma_dviP=b_ma_dvi and a.so_idP=b_so_id and a.so_id_dtP in(0,b_so_id_dt) and b.so_id=a.so_id
    group by b.ma_ta;
for b_lp in 1..a_ma_taT.count loop
    update tbh_ghep_nv_temp set ta_tien=ta_tien+round(tien*a_ptT(b_lp)/100,b_tp) where ma_ta=a_ma_taT(b_lp);
end loop;
update tbh_ghep_nv_temp set do_tl=round(do_tien*100/tien,2),ta_tl=round(ta_tien*100/tien,2),
    tm_tl=round(tm_tien*100/tien,2),ve_tl=round(ve_tien*100/tien,2) where tien<>0;
delete tbh_ghep_nv_temp2;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_BAO_TEMP:loi'; end if;
end;
/
create or replace procedure PTBH_BAO_TEMPc(
    b_nt_tien varchar2,b_nt_phi varchar2,b_loi out varchar2)
as
    b_tp number:=0;
    a_ma_taT pht_type.a_var; a_ptT pht_type.a_num;
begin
-- Dan - Tap hop tbh_ghep_nv_temp
delete tbh_ghep_nv_temp;
if b_nt_tien<>'VND' then b_tp:=2; end if;
delete tbh_ghep_nv_temp;
insert into tbh_ghep_nv_temp
    select ma_ta,b_nt_tien,sum(tien),b_nt_phi,sum(phi),0,sum(do_tien),0,sum(ta_tien),0,sum(tm_tien),0,sum(ve_tien)
    from tbh_ghep_nv_temp2 group by ma_ta having sum(tien)<>0 or sum(phi)<>0;
update tbh_ghep_nv_temp set do_tl=round(do_tien*100/tien,2),ta_tl=round(ta_tien*100/tien,2),
    tm_tl=round(tm_tien*100/tien,2),ve_tl=round(ve_tien*100/tien,2) where tien<>0;
delete tbh_ghep_nv_temp2;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_BAO_TEMPc:loi'; end if;
end;
/
create or replace procedure PTBH_BAO_TLd(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_nv varchar2,
    a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num,a_so_id_dt pht_type.a_num,b_loi out varchar2,b_so_id_ta number:=0)
AS
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tso varchar2(200); b_so_idB number;
    b_ngay_ht number; b_ngay_hl number; b_ngay_kt number; b_so_hd varchar2(20);
begin
-- Dan - Tinh phan bo ty le tai cho 1 doi tuong
delete tbh_ghep_tl_temp;
select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
    from bh_bao where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_tso:='{"xly":"F","kieu_ps":"B","nv":"'||b_nv||'"}';
PTBH_GHEP_TL(b_so_id_ta,b_ngay_ht,b_ngay_hl,b_nv,b_nt_tien,b_nt_phi,a_ma_dvi,a_so_id,a_so_id_dt,b_loi,b_tso);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_BAO_TLd:loi'; end if;
end;
/
create or replace procedure PTBH_BAO_TLm(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_nv varchar2,
    a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num,a_so_id_dt pht_type.a_num,
    b_ngay_hl out number,b_ngay_kt out number,b_vuot out number,b_loi out varchar2,b_so_id_ta number:=0)
AS
    b_ngay_hlD number; b_ngay_ktD number;
begin
-- Dan - Tra % vuot nguong
PTBH_BAO_TLd(b_ma_dvi,b_so_id,b_so_id_dt,b_nv,a_ma_dvi,a_so_id,a_so_id_dt,b_loi,b_so_id_ta);
if b_loi is not null then return; end if;
select nvl(max(pt),0) into b_vuot from tbh_ghep_tl_temp where pthuc='O';
b_ngay_hl:=30000101; b_ngay_kt:=0;
for b_lp in 1..a_ma_dvi.count loop
    select nvl(min(ngay_hl),0),nvl(min(ngay_kt),0) into b_ngay_hlD,b_ngay_ktD
        from bh_hd_goc where ma_dvi=a_ma_dvi(b_lp) and so_id=a_so_id(b_lp);
    if b_ngay_hlD=0 then
        select nvl(min(ngay_hl),0),nvl(min(ngay_kt),0) into b_ngay_hlD,b_ngay_ktD
            from bh_bao where ma_dvi=a_ma_dvi(b_lp) and so_id=a_so_id(b_lp);
    end if;
    if b_ngay_hlD<>0 then
        if b_ngay_hl>b_ngay_hlD then b_ngay_hl:=b_ngay_hlD; end if;
        if b_ngay_kt<b_ngay_ktD then b_ngay_kt:=b_ngay_ktD; end if;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_BAO_TLm:loi'; end if;
end;
/
