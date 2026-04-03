create or replace procedure PBH_HD_THAY_PHIg(
    b_nt_tien varchar2,b_nt_phi varchar2,b_tygia number,b_thue number,b_ttoan number,
    dk_lh_nv pht_type.a_var,dk_tien pht_type.a_num,
    dk_phi in out pht_type.a_num,dk_thue in out pht_type.a_num,dk_ttoan out pht_type.a_num,b_loi out varchar2)
AS
    b_tpB number:=0; b_tp number:=0; b_phiT number; b_thueT number;
    b_i1 number; b_tl number; b_iM number; b_phi number:=b_ttoan-b_thue;
begin
-- Dan - Dieu chinh phi
if b_nt_tien<>'VND' then b_tpB:=2; end if;
if b_nt_phi<>'VND' then b_tp:=2; end if;
b_phiT:=0; b_iM:=0;
for b_lp in 1..dk_lh_nv.count loop
    if dk_lh_nv(b_lp)<>' ' then
        b_phiT:=b_phiT+dk_phi(b_lp);
        if b_iM=0 or dk_phi(b_lp)>dk_phi(b_iM) then b_iM:=b_lp; end if;
    end if;
end loop;
if b_phiT=0 and b_phi<>0 then b_loi:='loi:Sai phi:loi'; return; end if;
if b_phiT<>b_phi then
    b_tl:=b_phi/b_phiT; b_phiT:=b_phi;
    b_iM:=FKH_ARR_VTRIx_N(dk_phi);
    for b_lp in 1..dk_phi.count loop
        dk_phi(b_lp):=round(dk_phi(b_lp)*b_tl,b_tp);
        if dk_lh_nv(b_lp)<>' ' then
            b_phiT:=b_phiT-dk_phi(b_lp);
        end if;
    end loop;
    dk_phi(b_iM):=dk_phi(b_iM)+b_phiT;
end if;
b_thueT:=0; b_iM:=0;
for b_lp in 1..dk_lh_nv.count loop
    if dk_lh_nv(b_lp)<>' ' then
        b_thueT:=b_thueT+dk_thue(b_lp);
        if b_iM=0 or dk_thue(b_lp)>dk_thue(b_iM) then b_iM:=b_lp; end if;
    end if;
end loop;
if b_thueT=0 and b_thue<>0 then b_loi:='loi:Sai thue:loi'; return; end if;
if b_thue<>b_thueT then
    b_tl:=b_thue/b_thueT; b_thueT:=b_thue;
    b_iM:=FKH_ARR_VTRIx_N(dk_thue);
    for b_lp in 1..dk_phi.count loop
        dk_thue(b_lp):=round(dk_thue(b_lp)*b_tl,b_tp);
        if dk_lh_nv(b_lp)<>' ' then
            b_thueT:=b_thueT-dk_thue(b_lp);
        end if;
    end loop;
    dk_thue(b_iM):=dk_thue(b_iM)+b_thueT;
end if;
for b_lp in 1..dk_phi.count loop
    dk_ttoan(b_lp):=dk_phi(b_lp)+dk_thue(b_lp);
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_THAY_PHIg:loi'; end if;
end;
/
create or replace procedure PBH_HD_THAY_PHI(
    b_nt_tien varchar2,b_nt_phi varchar2,b_tygia number,b_thue number,b_ttoan number,
    dk_lh_nv pht_type.a_var,dk_tien pht_type.a_num,dk_ptB pht_type.a_num,dk_phiB pht_type.a_num,
    dk_phi in out pht_type.a_num,dk_thue in out pht_type.a_num,dk_ttoan out pht_type.a_num,
    dk_ptG out pht_type.a_num,dk_phiG out pht_type.a_num,b_loi out varchar2)
AS
    b_tpB number:=0; b_tp number:=0; b_phiT number; b_thueT number;
    b_i1 number; b_tl number; b_iM number; b_phi number:=b_ttoan-b_thue;
begin
-- Dan - Dieu chinh phi
if b_nt_tien<>'VND' then b_tpB:=2; end if;
if b_nt_phi<>'VND' then b_tp:=2; end if;
b_phiT:=0; b_iM:=0;
for b_lp in 1..dk_lh_nv.count loop
    if dk_lh_nv(b_lp)<>' ' then
        b_phiT:=b_phiT+dk_phi(b_lp);
        if b_iM=0 or dk_phi(b_lp)>dk_phi(b_iM) then b_iM:=b_lp; end if;
    end if;
end loop;
if b_phiT=0 and b_phi<>0 then b_loi:='loi:Sai phi:loi'; return; end if;
if b_phiT<>b_phi then
    b_tl:=b_phi/b_phiT; b_phiT:=b_phi;
    b_iM:=FKH_ARR_VTRIx_N(dk_phi);
    for b_lp in 1..dk_phi.count loop
        dk_phi(b_lp):=round(dk_phi(b_lp)*b_tl,b_tp);
        if dk_lh_nv(b_lp)<>' ' then
            b_phiT:=b_phiT-dk_phi(b_lp);
        end if;
    end loop;
    dk_phi(b_iM):=dk_phi(b_iM)+b_phiT;
end if;
b_thueT:=0; b_iM:=0;
for b_lp in 1..dk_lh_nv.count loop
    if dk_lh_nv(b_lp)<>' ' then
        b_thueT:=b_thueT+dk_thue(b_lp);
        if b_iM=0 or dk_thue(b_lp)>dk_thue(b_iM) then b_iM:=b_lp; end if;
    end if;
end loop;
if b_thueT=0 and b_thue<>0 then b_loi:='loi:Sai thue:loi'; return; end if;
if b_thue<>b_thueT then
    b_tl:=b_thue/b_thueT; b_thueT:=b_thue;
    b_iM:=FKH_ARR_VTRIx_N(dk_thue);
    for b_lp in 1..dk_phi.count loop
        dk_thue(b_lp):=round(dk_thue(b_lp)*b_tl,b_tp);
        if dk_lh_nv(b_lp)<>' ' then
            b_thueT:=b_thueT-dk_thue(b_lp);
        end if;
    end loop;
    dk_thue(b_iM):=dk_thue(b_iM)+b_thueT;
end if;
for b_lp in 1..dk_phi.count loop
    dk_ttoan(b_lp):=dk_phi(b_lp)+dk_thue(b_lp);
end loop;
for b_lp in 1..dk_phi.count loop
    if dk_phiB(b_lp)=0 and (dk_tien(b_lp)=0 or dk_ptB(b_lp)=0) then
        dk_ptG(b_lp):=0; dk_phiG(b_lp):=0;
    else
        if dk_phiB(b_lp)<>0 then b_i1:=dk_phiB(b_lp); else b_i1:=round(dk_tien(b_lp)*dk_ptB(b_lp)/100,b_tpB); end if;
        b_i1:=round(b_i1*b_tygia,b_tp);
        dk_phiG(b_lp):=b_i1-dk_phi(b_lp);
        if b_i1=0 then dk_ptG(b_lp):=0;
        else
            dk_ptG(b_lp):=round(dk_phiG(b_lp)*100/b_i1,2);
        end if;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_THAY_PHI:loi'; end if;
end;
/
create or replace procedure PBH_BG_JS_TEST(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_bang varchar2,
    dt_ct in out clob,dt_tt clob,
    b_so_hd out varchar2,b_ngay_ht out number,b_ttrang out varchar2,
    b_kieu_hd out varchar2,b_so_hd_g out varchar2,b_kieu_kt out varchar2,b_ma_kt out varchar2,
    b_loai_kh out varchar2,b_ten out nvarchar2,b_dchi out nvarchar2,
    b_cmt out varchar2,b_mobi out varchar2,b_email out varchar2,
    b_gio_hl out varchar2,b_ngay_hl out number,b_gio_kt out varchar2,b_ngay_kt out number,b_ngay_cap out number,
    b_nt_tien out varchar2,b_nt_phi out varchar2,b_c_thue out varchar2,
    b_phi out number,b_giam out number,b_thue out number,b_ttoan out number,b_hhong out number,
    b_phong out varchar2,b_ma_kh out varchar2,
    tt_ngay out pht_type.a_num,tt_tien out pht_type.a_num,b_loi out varchar2,b_goc varchar2:='')
AS
    b_i1 number; b_i2 number; b_i3 number; b_ma_dviT varchar2(10); b_nsdT varchar2(20); b_txt clob;
    b_lenh varchar2(2000); b_cot varchar2(1000); b_q varchar2(1); b_chenh number:=0; b_tp number:=0; -- Nam:Giu nguyen phi,phan bo lai de tong tien bang tong chi tiet
    b_ng_sinh number; b_gioi varchar2(1); b_ps varchar2(1); b_ma_khC varchar2(20);
    b_cdtC varchar2(1); b_cdtF varchar2(1); b_cdtX varchar2(1); b_cdt varchar2(10);
begin
-- Dan - Test chung
b_cot:='ngay_ht,so_hd,ttrang,kieu_hd,so_hd_g,kieu_kt,ma_kt,loai_kh,ma_kh,ten,dchi,cmt,mobi,email,ng_sinh,gioi,';
b_cot:=b_cot||'gio_hl,ngay_hl,gio_kt,ngay_kt,ngay_cap,nt_tien,nt_phi,c_thue,phi,giam,thue,ttoan,hhong,cdtc,cdtf,cdtx';
b_lenh:=FKH_JS_LENH(b_cot);
EXECUTE IMMEDIATE b_lenh into
    b_ngay_ht,b_so_hd,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,
    b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_ng_sinh,b_gioi,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,
    b_nt_tien,b_nt_phi,b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_cdtC,b_cdtF,b_cdtX using dt_ct;
if b_kieu_hd is null or b_kieu_hd not in('G','T') then
    b_loi:='loi:Nhap sai kieu hop dong:loi'; return;
end if;
if nvl(b_ngay_ht,0) in(0,30000101) then
    b_ngay_ht:=PKH_NG_CSO(sysdate);
end if;
if b_ttrang is null or b_ttrang not in('S','T','D','H') then
    b_loi:='loi:Nhap sai tinh trang:loi'; return;
end if;
b_so_hd_g:=nvl(trim(b_so_hd_g),' ');
if b_kieu_hd='T' and b_so_hd_g=' ' then b_loi:='loi:Nhap hop dong goc:loi'; return; end if;
if (nvl(b_goc,' ')<>'HANG' and (nvl(b_ngay_hl,0) in(0,30000101) or nvl(b_ngay_kt,0) in(0,30000101))) or b_ngay_hl>b_ngay_kt then
    b_loi:='loi:Sai ngay hieu luc, ngay het hieu luc:loi'; return;
end if;
b_loai_kh:=nvl(trim(b_loai_kh),'C');
if b_loai_kh not in ('C','T') then
    b_loi:='loi:Sai loai khach hang '||b_loai_kh||':loi'; return;
end if;
if b_ten=' ' then b_loi:='loi:Nhap ten nguoi mua bao hiem:loi'; return; end if;
if b_kieu_kt not in('D','T','M','N') or (b_kieu_kt<>'T' and b_ma_kt is null) then
    b_loi:='loi:Sai ma khai thac:loi'; return;
end if;
if b_kieu_kt='T' then
    if b_ma_kt=' ' then b_ma_kt:=b_nsd;
    else
        select count(*) into b_i1 from ht_ma_cb where ma_dvi=b_ma_dvi and ma=b_ma_kt;
        if b_i1=0 then b_loi:='loi:Ma nhan vien da xoa:loi'; return; end if;
    end if;
elsif b_kieu_kt='N' then
    if b_ma_kt=' ' then b_loi:='loi:Nhap ma ngan hang:loi'; return; end if;
    select count(*) into b_i1 from bh_ma_nhang where ma=b_ma_kt and ngay_kt<PKH_NG_CSO(sysdate);
    if b_i1<>0 then
        b_loi:='loi:Ngan hang da ket thuc hoat dong:loi'; return;
    end if;
else
    if trim(b_ma_kt) is null then b_loi:='loi:Nhap ma dai ly:loi'; return; end if;
    if FBH_DL_MA_KH_HAN(b_ma_kt)<>'C' then b_loi:='loi:Dai ly da ket thuc hoat dong:loi'; return; end if;
end if;
b_nt_tien:=nvl(trim(b_nt_tien),' '); b_nt_phi:=nvl(trim(b_nt_phi),' ');
if FBH_TT_KTRA(b_nt_tien)<>'C' then b_loi:='loi:Sai loai tien bao hiem:loi'; return; end if;
if FBH_TT_KTRA(b_nt_phi)<>'C' then b_loi:='loi:Sai loai tien phi:loi'; return; end if;
b_c_thue:=nvl(trim(b_c_thue),'C');
b_giam:=nvl(b_giam,0); b_phi:=nvl(b_phi,0); b_thue:=nvl(b_thue,0); b_ttoan:=nvl(b_ttoan,0);
b_chenh:= b_ttoan + b_giam - b_phi - b_thue; -- Nam:Giu nguyen phi,phan bo lai de tong tien bang tong chi tiet
if b_nt_phi<>'VND' then b_tp:=2; end if;
if b_tp=0 and abs(b_chenh)> 1000 then
   b_ttoan:= round(b_phi - b_giam + b_thue, -3);
elsif b_tp<>0 and abs(b_chenh)> 1 then
   b_ttoan:= round(b_phi - b_giam + b_thue, 0);
end if;
b_chenh:= b_ttoan + b_giam - b_phi - b_thue;
if b_chenh<>0 then
   b_phi:=b_phi + b_chenh;
end if;
if b_c_thue='K' and b_thue<>0 then
    b_loi:='loi:Khach hang thuoc dien khong chiu thue:loi'; return;
end if;
if b_phi-b_giam+b_thue<>b_ttoan then
    b_loi:='loi:Sai phi, thue, thanh toan:loi'; return;
end if;
b_hhong:=nvl(b_hhong,0);
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
if b_phong is null then b_loi:='loi:Nhap ma phong cho nguoi su dung:loi'; return; end if;
b_so_hd:=substr(to_char(b_so_id),3);
if b_ttrang='D' then b_so_hd:='B.'||b_so_hd;
else b_so_hd:=b_ttrang||'.'||b_so_hd;
end if;
if trim(dt_tt) is not null then
    b_lenh:=FKH_JS_LENH('ngay,tien');
    EXECUTE IMMEDIATE b_lenh bulk collect into tt_ngay,tt_tien using dt_tt;
    for b_lp in 1..tt_ngay.count loop
        if tt_ngay(b_lp) is null or tt_tien(b_lp) is null then
            b_loi:='loi:Loi ky thanh toan dong '||to_char(b_lp)||':loi'; return;
        end if;
        if b_kieu_hd in ('G','T') and (tt_ngay(b_lp)>b_ngay_kt or tt_ngay(b_lp)<b_ngay_cap) then --viet anh: bo truong hop = theo ycau chi Trang
          b_loi:='loi:Ky thanh toan phai truoc ngay het han hieu luc hoac tu ngay cap don dong '||to_char(b_lp)||':loi'; return;
        elsif b_kieu_hd not in ('G','T') and tt_ngay(b_lp)>b_ngay_kt then
          b_loi:='loi:Ky thanh toan phai truoc ngay het han hieu luc don dong '||to_char(b_lp)||':loi'; return;
        end if;
    end loop;
    b_i1:=FKH_ARR_TONG(tt_tien);
    if b_i1<>b_ttoan then b_loi:='loi:Sai ky thanh toan va tong tien:loi'; return; end if;
    for b_lp in 1..tt_ngay.count loop
        b_i1:=b_lp+1;
        if b_i1<=tt_ngay.count then
            for b_lp1 in b_i1..tt_ngay.count loop
                if tt_ngay(b_lp)=tt_ngay(b_lp1) then
                    b_loi:='loi:Trung ky thanh toan '||PKH_SO_CNG(tt_ngay(b_lp))||':loi'; return;
                end if;
            end loop;
        end if;
    end loop;
    if tt_ngay(tt_ngay.count)>b_ngay_kt then
        b_loi:='loi:Ky thanh toan cuoi phai truoc ngay ket thuc:loi'; return;
    end if;
else
    tt_ngay(1):=b_ngay_cap; tt_tien(1):=b_ttoan;
end if;
b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
if trim(b_ma_kh) is null and b_ttrang in('T','D') then
    select json_object('ma' value b_ma_kh,'loai' value b_loai_kh,'ten' value b_ten,'cmt' value b_cmt,
        'dchi' value b_dchi,'mobi' value b_mobi,'email' value b_email,
        'ng_sinh' value b_ng_sinh,'gioi' value b_gioi) into b_txt from dual;
    PBH_DTAC_MA_NH(b_txt,b_ma_kh,b_loi,b_ma_dvi,b_nsd);
    if b_loi is not null then return; end if;
end if;
if trim(b_cdtC) is null then
    b_cdt:=' ';
else
    if b_cdtC='K' then b_cdt:='C'; end if;
    if b_cdtF='K' then PKH_GHEP(b_cdt,'F',''); end if;
    if b_cdtX='K' then PKH_GHEP(b_cdt,'X',''); end if;
    b_cdt:=nvl(trim(b_cdt),'K');
end if;
PKH_JS_THAYa(dt_ct,'ma_kh,so_hd,cdt',b_ma_kh||'|'||b_so_hd||'|'||b_cdt,'|');
if b_ttrang in('T','D') then
    if trim(b_ma_kh) is null then b_loi:='loi:Khong tao duoc ma khach hang:loi'; return; end if;
    b_loi:=FBH_DTAC_MA_NSD(b_ma_dvi,b_nsd,b_ma_kh);
    if b_loi is not null then return; end if;
    if b_ttrang='D' then
        if FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','BH','Q')<>'C' and FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','BH','H')<>'C' then
            b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','KT_'||b_goc||'');
            if b_loi is not null then return; end if;
            b_loi:=PKH_NGAY_LUI_TEST(b_ma_dvi,b_ngay_ht,b_ngay_cap,b_goc);
            if b_loi is not null then return; end if;
        end if;
    end if;
else
    b_ma_kh:=nvl(b_ma_khC,' ');
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BG_JS_TEST:loi'; end if;
end;
/
create or replace procedure PBH_HD_JS_TEST(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_ngay_htC number,b_bang varchar2,
    dt_ct in out clob,dt_tt clob,
    b_so_hd out varchar2,b_ngay_ht out number,b_ttrang out varchar2,
    b_kieu_hd out varchar2,b_so_hd_g out varchar2,b_kieu_kt out varchar2,b_ma_kt out varchar2,
    b_loai_kh out varchar2,b_ten out nvarchar2,b_dchi out nvarchar2,
    b_cmt out varchar2,b_mobi out varchar2,b_email out varchar2,
    b_gio_hl out varchar2,b_ngay_hl out number,b_gio_kt out varchar2,b_ngay_kt out number,b_ngay_cap out number,
    b_nt_tien out varchar2,b_nt_phi out varchar2,b_c_thue out varchar2,
    b_phi out number,b_giam out number,b_thue out number,b_ttoan out number,b_hhong out number,
    b_so_idG out number,b_so_idD out number,b_ngayD out number,b_phong out varchar2,b_ma_cb out varchar2,b_ma_kh out varchar2,
    tt_ngay out pht_type.a_num,tt_tien out pht_type.a_num,b_loi out varchar2,b_goc varchar2:=' ')
AS
    b_i1 number; b_i2 number; b_i3 number; b_ma_dviT varchar2(10); b_nsdT varchar2(20); b_txt clob;
    b_ttrangC varchar2(1); b_lenh varchar2(2000); b_cot varchar2(1000); b_so_hdL varchar2(1);
    b_ma_dvi_ql varchar2(10); b_phong_ql varchar2(10):='';
    b_ng_sinh number; b_gioi varchar2(1); b_ps varchar2(1); b_ma_khC varchar2(20);
    b_cdtC varchar2(1); b_cdtF varchar2(1); b_cdtX varchar2(1); b_cdt varchar2(10);
    tt_ngayC pht_type.a_num; tt_tienC pht_type.a_num; b_chenh number; b_tp number:=0;
begin
-- Dan - Test chung
FKH_JS_NULL(dt_ct);
b_cot:='ngay_ht,so_hd,ttrang,kieu_hd,so_hd_g,kieu_kt,ma_kt,loai_kh,ma_kh,ten,dchi,cmt,mobi,email,ng_sinh,gioi,';
b_cot:=b_cot||'gio_hl,ngay_hl,gio_kt,ngay_kt,ngay_cap,nt_tien,nt_phi,c_thue,phi,giam,thue,ttoan,hhong,cb_ql,so_hdl,cdtc,cdtf,cdtx';
b_lenh:=FKH_JS_LENH(b_cot);
EXECUTE IMMEDIATE b_lenh into
    b_ngay_ht,b_so_hd,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,
    b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_ng_sinh,b_gioi,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,
    b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_ma_cb,b_so_hdL,b_cdtC,b_cdtF,b_cdtX using dt_ct;
if b_kieu_hd is null or b_kieu_hd not in('G','B','S','T','V','N','U','K','C') then
    b_loi:='loi:Nhap sai kieu hop dong:loi'; return;
end if;
if nvl(b_ngay_ht,0) in(0,30000101) then
    if nvl(b_ngay_htC,0) in(0,30000101) then b_ngay_ht:=PKH_NG_CSO(sysdate); else b_ngay_ht:=b_ngay_htC; end if;
end if;
if b_ttrang not in('S','T','D','H') then
    b_loi:='loi:Nhap sai tinh trang:loi'; return;
end if;
b_so_hdL:=nvl(trim(b_so_hdL),'T');
if b_goc<>'HANG' and (b_ngay_hl in(0,30000101) or b_ngay_kt in(0,30000101) or b_ngay_hl>b_ngay_kt) then
    b_loi:='loi:Sai ngay hieu luc, ngay het hieu luc:loi'; return;
end if;
if b_ngay_cap in(0,30000101) then b_ngay_cap:=PKH_NG_CSO(sysdate); end if;
if b_loai_kh not in ('C','T') then
    b_loi:='loi:Sai loai khach hang '||b_loai_kh||':loi'; return;
end if;
if b_ten=' ' then b_loi:='loi:Nhap ten nguoi mua bao hiem:loi'; return; end if;
if b_kieu_kt not in('D','T','M','N') or (b_kieu_kt<>'T' and b_ma_kt=' ') then
    b_loi:='loi:Sai ma khai thac:loi'; return;
end if;
if b_kieu_kt='T' then
    if b_ma_kt not in(' ',b_nsd) then
        select 0 into b_i1 from ht_ma_cb where ma_dvi=b_ma_dvi and ma=b_ma_kt;
        b_ma_cb:=b_ma_kt;
    else
        b_ma_kt:=b_nsd;
    end if;
    if b_ma_cb=' ' then b_ma_cb:=b_ma_kt; end if;
elsif b_kieu_kt='N' then
    if b_ma_kt=' ' then b_loi:='loi:Nhap ma ngan hang:loi'; return; end if;
    select count(*) into b_i1 from bh_ma_nhang where ma=b_ma_kt and ngay_kt<PKH_NG_CSO(sysdate);
    if b_i1<>0 then
        b_loi:='loi:Ngan hang da ket thuc hoat dong:loi'; return;
    end if;
else
    if b_ma_kt=' ' then b_loi:='loi:Nhap ma dai ly:loi'; return; end if;
    if FBH_DL_MA_KH_HAN(b_ma_kt)<>'C' then b_loi:='loi:Dai ly da ket thuc hoat dong:loi'; return; end if;
end if;
if b_ma_cb=' ' then FBH_DL_MA_KH_DVI_QLf(b_ma_kt,b_ma_dvi_ql,b_phong_ql,b_ma_cb); end if;
if b_nt_tien<>'VND' and FBH_TT_KTRA(b_nt_tien)<>'C' then b_loi:='loi:Sai loai tien bao hiem:loi'; return; end if;
if b_nt_phi<>'VND' and FBH_TT_KTRA(b_nt_phi)<>'C' then b_loi:='loi:Sai loai tien phi:loi'; return; end if;
b_i1:=instr(b_so_hd,'.');
if b_i1=2 and substr(b_so_hd,1,2) in('S','T','D','H','B') then b_so_hd:=substr(b_so_hd,3); end if;
--if b_so_hdL='P' and b_so_hd = ' ' then b_loi:='loi:Nhap so hop dong/GCN:loi'; return; end if;
if b_kieu_hd in('B','S','T','K','C') and b_so_hd_g=' ' then b_loi:='loi:Nhap hop dong goc:loi'; return; end if;
if b_kieu_hd<>'U' then
    b_giam:=nvl(b_giam,0); b_phi:=nvl(b_phi,0); b_thue:=nvl(b_thue,0); b_ttoan:=nvl(b_ttoan,0);
    b_chenh:= b_ttoan + b_giam - b_phi - b_thue; -- Nam:Giu nguyen phi,phan bo lai de tong tien bang tong chi tiet
    if b_nt_phi<>'VND' then b_tp:=2; end if;
    if b_tp=0 and abs(b_chenh)> 1000 then
       b_ttoan:= round(b_phi - b_giam + b_thue, -3);
    elsif b_tp<>0 and abs(b_chenh)> 1 then
       b_ttoan:= round(b_phi - b_giam + b_thue, 0);
    end if;
    b_chenh:= b_ttoan + b_giam - b_phi - b_thue;
    if b_chenh<>0 then
       b_phi:=b_phi + b_chenh;
    end if;
    if b_c_thue='K' and b_thue<>0 then
        b_loi:='loi:Khach hang thuoc dien khong chiu thue:loi'; return;
    end if;
    if b_phi-b_giam+b_thue<>b_ttoan then -- Nam: giam phi giu nguyen phi
        b_loi:='loi:Sai phi, thue, thanh toan:loi'; return;
    end if;
    b_hhong:=nvl(b_hhong,0);
    if trim(dt_tt) is null then
        tt_ngay(1):=b_ngay_cap; tt_tien(1):=b_ttoan;
    else
        b_lenh:=FKH_JS_LENH('ngay,tien');
        EXECUTE IMMEDIATE b_lenh bulk collect into tt_ngay,tt_tien using dt_tt;
        for b_lp in 1..tt_ngay.count loop
            if tt_ngay(b_lp) is null or tt_tien(b_lp) is null then
                b_loi:='loi:Loi ky thanh toan dong '||to_char(b_lp)||':loi'; return;
            end if;
            if b_kieu_hd in ('G','T') and (tt_ngay(b_lp)>b_ngay_kt or tt_ngay(b_lp)<b_ngay_cap) then --Nam: theo ycau chi Trang
              b_loi:='loi:Ky thanh toan phai truoc ngay het han hieu luc hoac tu ngay cap don dong '||to_char(b_lp)||':loi'; return;
            elsif b_kieu_hd not in ('G','T') and tt_ngay(b_lp)>b_ngay_kt then
              b_loi:='loi:Ky thanh toan phai truoc ngay het han hieu luc don dong '||to_char(b_lp)||':loi'; return;
            end if;
        end loop;
        b_i1:=FKH_ARR_TONG(tt_tien);
        if b_i1<>b_ttoan then b_loi:='loi:Sai ky thanh toan va tong tien:loi'; return; end if;
        for b_lp in 1..tt_ngay.count loop
            b_i1:=b_lp+1;
            if b_i1<=tt_ngay.count then
                for b_lp1 in b_i1..tt_ngay.count loop
                    if tt_ngay(b_lp)=tt_ngay(b_lp1) then
                        b_loi:='loi:Trung ky thanh toan '||PKH_SO_CNG(tt_ngay(b_lp))||':loi'; return;
                    end if;
                end loop;
            end if;
        end loop;
        if b_ttrang in ('T','D') then
            b_i1:=FKH_ARR_MINn(tt_ngay); b_i2:=FKH_KHO_NGSO(b_ngay_hl,b_i1);
            if b_i2>30 and b_kieu_hd<>'B' then b_loi:='loi:Thoi han thanh toan vuot qua 30 ngay:loi'; return; end if;
        end if;
    end if;
end if;
b_so_idD:=b_so_id;
if b_kieu_hd in('B','S') then
    b_lenh:='select so_id,so_id_d,phong,ngay_ht,ttrang,ma_kh from '||b_bang||' where ma_dvi= :ma_dvi and so_hd= :so_hd';
    execute immediate b_lenh into b_so_idG,b_so_idD,b_phong,b_i1,b_ttrangC,b_ma_khC using b_ma_dvi,b_so_hd_g;
    if b_i1>b_ngay_ht then b_loi:='loi:Ngay nhap sua doi phai sau ngay goc:loi'; return; end if;
    if b_ttrangC<>'D' then b_loi:='loi:So cu chua duyet:loi'; return; end if;
    b_lenh:='select count(*) from '||b_bang||' where ma_dvi= :ma_dvi and so_id_g= :so_id and kieu_hd in(''B'',''S'')';
    execute immediate b_lenh into b_i1 using b_ma_dvi,b_so_idG;
    if b_i1>0 then b_loi:='loi:Da tao bo sung, sua doi:loi'; return; end if;
    b_lenh:='select ngay_ht from '||b_bang||' where ma_dvi= :ma_dvi and so_id= :so_id';
    execute immediate b_lenh into b_ngayD using b_ma_dvi,b_so_idD;
    if NVL(b_so_hd,' ')=' ' or b_kieu_hd='S' then
        b_lenh:='select nvl(max(so_id),0) from '||b_bang||' where ma_dvi= :ma_dvi and so_id_d= :so_id';
        execute immediate b_lenh into b_i1 using b_ma_dvi,b_so_idD;
        if b_i1<>0 then
            b_lenh:='select so_hd from '||b_bang||' where ma_dvi= :ma_dvi and so_id= :so_id';
            execute immediate b_lenh into b_so_hd using b_ma_dvi,b_i1;
            b_i1:=instr(b_so_hd,'/');
            if b_i1<>0 then
                b_i2:=b_i1-1;
                b_i1:=PKH_LOC_CHU_SO(substr(b_so_hd,b_i1),'F','F');
                b_so_hd:=substr(b_so_hd,1,b_i2);
            end if;
        end if;
        b_so_hd:=b_so_hd||'/'||b_kieu_hd||to_char(b_i1+1);
    end if;
    select ngay,tien bulk collect into tt_ngayC,tt_tienC from bh_hd_goc_tt where ma_dvi=b_ma_dvi and so_id=b_so_idG;
    for b_lp in 1..tt_ngayC.count loop
        select count(*) into b_i1 from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_idD and ngay=tt_ngayC(b_lp);
        if b_i1<>0 then
            b_i1:=FKH_ARR_VTRI_N(tt_ngay,tt_ngayC(b_lp));
            if b_i1<>b_lp or tt_tien(b_i1)<>tt_tienC(b_lp) then
                b_loi:='loi:Khong sua tien ky phi '||PKH_SO_CNG(tt_ngayC(b_lp))||' da thanh toan phi:loi'; return;
            end if;
        end if;
    end loop;
    if b_ttrang in('T','D') and b_kieu_hd not in('U','K') then
        select nvl(max(ngay_ht),0) into b_i1 from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_idD;
        if b_i1>b_ngay_ht  then b_loi:='loi:Da co thanh toan phi ngay '||PKH_SO_CNG(b_i1)||':loi'; return; end if;
    end if;
else
    b_lenh:='select min(phong),nvl(min(ngay_ht),0) from '||b_bang||' where ma_dvi= :ma_dvi and so_id= :so_id';
    execute immediate b_lenh into b_phong,b_i1 using b_ma_dvi,b_so_id;
    if b_i1<>0 then b_ngay_ht:=b_i1; end if;
    b_so_idD:=b_so_id; b_so_idG:=0; b_ngayD:=b_ngay_ht;
    if b_so_hdL<>'P' or nvl(b_so_hd,' ')=' ' then
    b_so_hd:=substr(to_char(b_so_id),3);
    end if;
    if b_kieu_hd in('T','K') then
        b_loi:='loi:So cu da xoa:loi';
        b_lenh:='select so_id_d,ttrang,ngay_kt from '||b_bang||' where ma_dvi= :ma_dvi and so_hd= :so_hd';
        execute immediate b_lenh into b_so_idG,b_ttrangC,b_i1 using b_ma_dvi,b_so_hd_g;
        if b_ttrangC<>'D' then b_loi:='loi:So hop dong/GCN goc chua duyet:loi'; return; end if;
        if b_kieu_hd='T' and b_i1>b_ngay_hl then b_loi:='loi:Trung khoang hieu luc:loi'; return; end if;
    end if;
end if;
if FBH_HD_HU(b_ma_dvi,b_so_idD)='C' then b_loi:='loi:Hop dong da huy:loi'; return; end if;
if instr(b_so_hd,'.')=2 then b_so_hd:=substr(b_so_hd,3); end if;
if b_ttrang<>'D' then b_so_hd:=b_ttrang||'.'||b_so_hd; end if;
if b_phong is null then
    if b_phong_ql is not null then
        b_phong:=b_phong_ql;
    else
        b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
        if b_phong=' ' then b_loi:='loi:Khong tim duoc ma phong:loi'; return; end if;
    end if;
end if;
-- chuclh: PKH_JS_THAYa(dt_ct,'so_hd,ma_kh',b_so_hd||','||b_ma_kh) loi neu b_ma_kh = null
b_ma_kh:=nvl(FBH_DTAC_MAt(b_cmt,b_mobi,b_email),' ');
if trim(b_ma_kh) is null and b_ttrang in('T','D') then
    select json_object('ma' value b_ma_kh,'loai' value b_loai_kh,'ten' value b_ten,'cmt' value b_cmt,
        'dchi' value b_dchi,'mobi' value b_mobi,'email' value b_email,
        'ng_sinh' value b_ng_sinh,'gioi' value b_gioi) into b_txt from dual;
    PBH_DTAC_MA_NH(b_txt,b_ma_kh,b_loi,b_ma_dvi,b_nsd);
    if b_loi is not null then return; end if;
end if;
if trim(b_cdtC) is null then
    b_cdt:=' ';
else
    if b_cdtC='K' then b_cdt:='C'; end if;
    if b_cdtF='K' then PKH_GHEP(b_cdt,'F',''); end if;
    if b_cdtX='K' then PKH_GHEP(b_cdt,'X',''); end if;
    b_cdt:=nvl(trim(b_cdt),'K'); -- viet anh -- cdt khi tich ca 3
end if;
PKH_JS_THAYa(dt_ct,'ma_kh,so_hd,cdt',b_ma_kh||'|'||b_so_hd||'|'||b_cdt,'|');
if b_ttrang in('T','D') then
    if trim(b_ma_kh) is null then b_loi:='loi:Khong tao duoc ma khach hang:loi'; return; end if;
    b_loi:=FBH_DTAC_MA_NSD(b_ma_dvi,b_nsd,b_ma_kh);
    if b_loi is not null then return; end if;
    if b_ttrang='D' then
        --Nam: han so lieu va nhap lui ngay
        if FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH',b_goc,'Q')<>'C' and FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH',b_goc,'H')<>'C' then
            b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','KT_'||b_goc||'');
            if b_loi is not null then return; end if;
            b_loi:=PKH_NGAY_LUI_TEST(b_ma_dvi,b_ngay_ht,b_ngay_cap,b_goc);
            if b_loi is not null then return; end if;
        end if;
    end if;
    /*if b_kieu_hd in('B','S') and b_ma_khC not in('VANGLAI',b_ma_kh) then
        b_loi:='loi:Khong thay doi ma khach hang:loi'; return;
    end if;*/
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_JS_TEST:loi'; end if;
end;
/
create or replace procedure PBH_HD_JS_TTRANG(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_ma_dvi varchar2(10);
    b_i1 number; b_tt varchar2(1); b_m varchar2(1); b_nv varchar2(10);
    b_so_id number;  b_so_idD number; b_ttrang varchar2(1); b_vuot varchar2(1):=' ';
    b_kieu_xl varchar2(1); b_phai_xl varchar2(1);
    b_ta_tle varchar2(1):=' '; cs_ttr clob:='';
begin
-- Dan - Trang thai hop dong
delete bh_hd_ttrang_temp; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id,nv');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id,b_nv using b_oraIn;
b_so_idD:=FTBH_SOAN_SO_IDd(b_ma_dvi,b_so_id,b_nv);
if b_so_idD=0 then b_loi:='loi:Hop dong/GCN da xoa:loi'; raise PROGRAM_ERROR; end if;
b_ttrang:=nvl(trim(FBH_HD_TTRANG(b_ma_dvi,b_so_id)),'S');
select count(*) into b_i1 from bh_hd_do_nh where ma_dvi=b_ma_dvi and so_id=b_so_idD and nhom='D';
if b_i1<>0 then insert into bh_hd_ttrang_temp values('do_tle','V'); end if;
select count(*) into b_i1 from bh_hd_do_nh where ma_dvi=b_ma_dvi and so_id=b_so_idD and nhom='F';
if b_i1<>0 then insert into bh_hd_ttrang_temp values('do_fr','V'); end if;
select count(*) into b_i1 from tbh_tmN where ma_dvi=b_ma_dvi and so_id=b_so_idD;
if b_i1<>0 then insert into bh_hd_ttrang_temp values('do_ta','V'); end if;
select count(*) into b_i1 from bh_hd_ttrang_temp where nv in('do_tle','do_fr','do_ta');
if b_i1<>0 then b_ta_tle:='V'; end if;
if b_ttrang='H' then
    insert into bh_hd_ttrang_temp values('hd_huy','D');
elsif b_ttrang='S' then
    PBH_HD_VUOTs(b_ma_dvi,b_so_id,b_nv,b_vuot,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    if b_vuot='C' then b_ta_tle:='D'; end if;
else
    select count(*) into b_i1 from tbh_tmB_cbi where ma_dviP=b_ma_dvi and so_idP=b_so_id and kieu_xl='C';
    if b_i1<>0 then b_ta_tle:='D';
    else
        select nvl(min(kieu_xl),' '),nvl(min(phai_xl),' ') into b_kieu_xl,b_phai_xl
            from tbh_cbi where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id;
        if b_kieu_xl='C' then
            if b_phai_xl='C' then b_ta_tle:='D'; else b_ta_tle:='V'; end if;
        end if;
    end if;
end if;
if b_ttrang in('H','D') then
    select count(*) into b_i1 from bh_hd_goc_sc_hh where ma_dvi=b_ma_dvi and so_id=b_so_idD;
    if b_i1<>0 then insert into bh_hd_ttrang_temp values('tt_hhong','D'); end if;
end if;
if b_ttrang='D' then
    b_tt:='X';
    select count(*) into b_i1 from bh_hd_goc_sc_phi_ton where ma_dvi=b_ma_dvi and so_id=b_so_idD;
    if b_i1<>0 then
        select count(*) into b_i1 from bh_hd_goc_sc_phi where ma_dvi=b_ma_dvi and so_id=b_so_idD and co<>0;
        if b_i1=0 then b_tt:='D'; else b_tt:='V'; end if;
    else
        select count(*) into b_i1 from bh_hd_goc_sc_no_ton where ma_dvi=b_ma_dvi and so_id=b_so_idD;
        if b_i1<>0 then b_tt:='V'; end if;
    end if;
    if b_tt<>'X' then insert into bh_hd_ttrang_temp values('tt_phi',b_tt); end if;
    select count(*) into b_i1 from bh_hd_goc_sc_hh where ma_dvi=b_ma_dvi and so_id=b_so_idD;
end if;
if b_ttrang in('D','H') then
    if b_i1<>0 then insert into bh_hd_ttrang_temp values('tt_hhong','D'); end if;
    select count(*) into b_i1 from bh_hd_goc_sc_vat where ma_dvi=b_ma_dvi and so_id=b_so_idD;
    if b_i1<>0 then insert into bh_hd_ttrang_temp values('tt_thue','D'); end if;
    if FTBH_TMN(b_ma_dvi,b_so_id)='C' then
        select count(*) into b_i1 from tbh_tmN_sc_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
        if b_i1<>0 then insert into bh_hd_ttrang_temp values('tmN_tt','D'); end if;
    end if;
    select count(*) into b_i1 from bh_bt_hs where ma_dvi=b_ma_dvi and so_id_hd=b_so_id;
    if b_i1<>0 then insert into bh_hd_ttrang_temp values('bt_hs','V'); end if;
    -- Tai
    if b_ta_tle=' ' then
        select count(*) into b_i1 from tbh_ghep_hd where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_idD;
        if b_i1=0 then 
            select count(*) into b_i1 from tbh_tm_hd where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_idD;
        end if;
        if b_i1<>0 then b_ta_tle:='V'; end if;
    end if;
    -- Dong
    if FBH_DONG(b_ma_dvi,b_so_idD)<>'G' then
        select count(*) into b_i1 from bh_hd_do_sc_ps where ma_dvi=b_ma_dvi and so_id=b_so_idD;
        if b_i1<>0 then insert into bh_hd_ttrang_temp values('do_tt','D'); end if;
        if FBH_HD_DO_VAT_TONh(b_ma_dvi,b_so_id)='C' then
            insert into bh_hd_ttrang_temp values('do_vat','D');
        end if;
    end if;
end if;
if b_ttrang in('T','D') and b_ta_tle<>'D' then
    PBH_HD_QUA(b_ma_dvi,b_so_id,b_vuot,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    if b_vuot='C' then b_ta_tle:='D'; end if;
end if;
if b_ta_tle<>' ' then
    insert into bh_hd_ttrang_temp values('ta_tle',b_ta_tle);
end if;
select count(*) into b_i1 from bh_hd_ttrang_temp;
if b_i1<>0 then
    select JSON_ARRAYAGG(json_object(nv,tt) returning clob) into cs_ttr from bh_hd_ttrang_temp;
end if;
select json_object('cs_ttr' value cs_ttr) into b_oraOut from dual;
delete bh_hd_ttrang_temp; commit;
exception when others then
    if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_JS_TTRANG:loi'; end if;
    raise_application_error(-20105,b_loi);
end;
/
create or replace procedure FBH_HD_LKE_PHI(b_ma_dvi varchar2,b_so_id number,cs_phi out clob)
AS
begin
-- Dan - Liet ke phi theo hop dong
delete temp_1; commit;
insert into temp_1(c1,n1) select ma_nt,sum(ttoan) from bh_hd_goc_cl where ma_dvi=b_ma_dvi and so_id=b_so_id group by ma_nt;
update temp_1 set (n2,n3)=(select nvl(sum(decode(pt,'C',0,tien)),0),nvl(sum(decode(pt,'C',tien,'N',-tien,0)),0)
    from  bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=c1);
update temp_1 set n4=n1-n2;
/*update temp_1 set (n2,n3)=(select nvl(sum(decode(pt,'C',0,tien)),0),nvl(sum(tien),0)
    from  bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=c1);
update temp_1 set n3=n3-n2,n4=n1-n2;*/
select JSON_ARRAYAGG(json_object('ma_nt' value c1,'phi' value n1,
    'ttoan' value n2,'no' value n3,'ton' value n4) order by c1) into cs_phi from temp_1;
delete temp_1; commit;
end;
/
create or replace procedure FBH_HD_LKE_BTH(b_ma_dvi varchar2,b_so_id number,cs_bth out clob)
AS
begin
-- Dan - Liet ke boi thuong hop dong
delete temp_1; delete temp_2; commit;
insert into temp_1(n10,c1,n9,c2,n1) select a.so_id,a.so_hs,a.ngay_ht,b.ma_nt,b.tien from bh_bt_hs a,bh_bt_hs_nv b where
    a.ma_dvi_ql=b_ma_dvi and a.so_id_hd=b_so_id and a.n_duyet is not null and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id;
insert into temp_1(n10,c1,n9,c2,n2) select a.so_id,a.so_hs,a.ngay_ht,b.ma_nt,b.tien from bh_bt_hs a,bh_bt_hs_nv b where
    a.ma_dvi_ql=b_ma_dvi and a.so_id_hd=b_so_id and a.n_duyet is null and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id;
insert into temp_2(n10,c1,n9,c2,n1,n2) select n10,c1,n9,c2,nvl(sum(n1),0),nvl(sum(n2),0) from temp_1 group by n10,c1,n9,c2;
if sql%rowcount=0 then cs_bth:='';
else
    select JSON_ARRAYAGG(json_object('ma_dvi' value b_ma_dvi,'so_id' value n10,'so_hs' value c1,'ngay_ht' value n9,'ma_nt' value c2,'tien' value n1,'ton' value n2) order by c1 returning clob) into cs_bth from temp_2;
end if;
delete temp_1; delete temp_2; commit;
end;
/
create or replace procedure FBH_HD_LKE_BTHd(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,cs_bth out clob)
AS
begin
-- Dan - Liet ke boi thuong doi tuong
delete temp_1; delete temp_2; commit;
insert into temp_1(n10,c1,n9,c2,n1) select a.so_id,a.so_hs,a.ngay_ht,b.ma_nt,b.tien from bh_bt_hs a,bh_bt_hs_nv b where
    a.ma_dvi_ql=b_ma_dvi and a.so_id_hd=b_so_id and a.n_duyet is not null and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id and b.so_id_dt=b_so_id_dt;
insert into temp_1(n10,c1,n9,c2,n2) select a.so_id,a.so_hs,a.ngay_ht,b.ma_nt,b.tien from bh_bt_hs a,bh_bt_hs_nv b where
    a.ma_dvi_ql=b_ma_dvi and a.so_id_hd=b_so_id and a.n_duyet is null and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id and b.so_id_dt=b_so_id_dt;
insert into temp_2(n10,c1,n9,c2,n1,n2) select n10,c1,n9,c2,nvl(sum(n1),0),nvl(sum(n2),0) from temp_1 group by n10,c1,n9,c2;
if sql%rowcount=0 then cs_bth:='';
else
	select JSON_ARRAYAGG(json_object('ma_dvi' value b_ma_dvi,'so_id' value n10,
    'so_hs' value c1,'ngay_ht' value n9,'ma_nt' value c2,'tien' value n1,
    'ton' value n2) order by c1 returning clob) into cs_bth from temp_2;
end if;
delete temp_1; delete temp_2; commit;
end;
/
create or replace procedure PBH_HD_LKE_TTBTj(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_ma_dvi varchar2(10); b_so_id number; b_so_idD number;
    cs_phi clob; cs_bth clob; cs_ng clob;
begin
-- Dan - Liet phi phi, boi thuong theo hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
FBH_HD_LKE_PHI(b_ma_dvi,b_so_idD,cs_phi);
FBH_HD_LKE_BTH(b_ma_dvi,b_so_idD,cs_bth);
select JSON_ARRAYAGG(json_object('ten' value FBH_KE_CHI_MA_TEN(ma),tien,ma) order by ma returning clob) into cs_ng from
    (select nv,ma,sum(tien) tien from bh_hd_goc_ttke where ma_dvi=b_ma_dvi and so_id=b_so_idD group by nv,ma);
select json_object('cs_phi' value cs_phi,'cs_bth' value cs_bth,'cs_ng' value cs_ng returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_LKE_LKEHD(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_ma_kh varchar2(20):=FKH_JS_GTRIs(b_oraIn,'ma_kh');
    b_ma_dvi varchar2(10); b_so_id number; b_so_idD number; b_so_idC number;
    b_so_hd varchar2(20); b_nv varchar2(10); b_ngay_hl number; b_ngay_kt number; b_phi number; b_bth number;
    cs_lke clob;
begin
-- Dan - Liet ke hop dong theo khach hang
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
for r_lp in (select distinct ma_dvi,so_id_d from bh_hd_goc where ma_kh=b_ma_kh and ttrang='D') loop
    b_ma_dvi:=r_lp.ma_dvi; b_so_idD:=r_lp.so_id_d; b_so_idC:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_idD);
    select so_hd,nv into b_so_hd,b_nv from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_idD;
    if substr(b_nv,1,2)='NG' then b_nv:='NG'; end if;
    select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_idC;
    select nvl(sum(tien_qd),0) into b_phi from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_idD and pt<>'C';
    select nvl(sum(b.tien_qd),0) into b_bth from bh_bt_hs a,bh_bt_hs_nv b where
        a.ma_dvi_ql=b_ma_dvi and a.so_id_hd=b_so_idD and a.ttrang='D' and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id;
    insert into temp_1(c1,c2,c3,n1,n2,n3,n4) values (b_ma_dvi,b_so_hd,b_nv,b_ngay_hl,b_ngay_kt,b_phi,b_bth);
end loop;
select JSON_ARRAYAGG(json_object('ma_dvi' value c1,'so_hd' value c2,'nv'  value c3,'ngay_hl' value n1,
    'ngay_kt' value n2,'phi' value n3,'bth' value n4 returning clob) order by c2 desc returning clob) into cs_lke from temp_1;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_LKE_TTTA(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
	b_ma_dvi varchar2(10); b_so_id number; b_so_idD number;
    cs_lke clob:='';
begin
-- Dan - Ty le tai
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
insert into temp_1(c1,c2,n1,n2,n3,n4) select 'C',lh_nv,max(pt),sum(tien),sum(phi),sum(hhong)
	from tbh_ghep_pbo where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_idD group by lh_nv;
insert into temp_1(c1,c2,n1,n2,n3,n4) select 'T',lh_nv,max(pt),sum(tien),sum(phi),sum(hhong)
	from tbh_tm_pbo where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_idD group by lh_nv;
select JSON_ARRAYAGG(json_object('kieu' value c1,'lh_nv' value c2,'pt' value n1,
	'ta_tien' value n2,'ta_phi' value n3,'hhong' value n4) order by c1,c2 returning clob)
	into cs_lke from temp_1;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_HD_KHO(
   b_ngay_hl number,b_ngay_kt number,b_kho out number,b_loi out varchar2)
AS
begin
-- Nam - Tinh he so phi
b_loi:='loi:Loi xu ly FBH_HD_KHO:loi';
if substr(to_char(b_ngay_hl), 5)=substr(to_char(b_ngay_kt), 5) then b_kho:=FKH_KHO_NASO(b_ngay_hl,b_ngay_kt);
else
  b_kho:=FKH_KHO_NGSO(b_ngay_hl,b_ngay_kt)+1;
  if b_kho<365 or b_kho>366 then
      b_kho:=b_kho/365;
  else b_kho:=1;
  end if;
end if;
b_loi:='';
end;
