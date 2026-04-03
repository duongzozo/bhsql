-- Nhan tai tam thoi
create or replace function FBH_HD_DO_NH_TXT(
    b_ma_dvi varchar2,b_so_id number,b_nhom varchar2,b_tim varchar2) return varchar2
AS
    b_kq varchar2(100):=' '; b_i1 number; b_txt clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
select count(*) into b_i1 from bh_hd_do_nh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_hd_do_nh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom and loai='dt_ct';
    b_kq:=nvl(trim(FKH_JS_GTRIs(b_txt,b_tim)),' ');
end if;
return b_kq;
end;
/
create or replace function FBH_HD_DO_NH_TXTn(
    b_ma_dvi varchar2,b_so_id number,b_nhom varchar2,b_tim varchar2) return number
AS
    b_kq number:=0; b_i1 number; b_txt clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
select count(*) into b_i1 from bh_hd_do_nh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_hd_do_nh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom and loai='dt_ct';
    b_kq:=nvl(FKH_JS_GTRIn(b_txt,b_tim),0);
end if;
return b_kq;
end;
/
create or replace function FBH_HD_DO_NH_NHOM(b_ma_dvi varchar2,b_so_id number,b_nhom varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number;
begin
-- Dan - Tra co nhom
select count(*) into b_i1 from bh_hd_do_nh where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure FBH_HD_DO_NH_PHId(
    dt_ct clob,dt_bh clob,b_nhom varchar2,
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_nv varchar2,b_kieu varchar2,
    b_nt_tien out varchar2,b_nt_phi out varchar2,
    b_tien out number,b_phi out number,b_tienH out number,b_phiH out number,
    bh_lh_nv out pht_type.a_var,bh_kieu out pht_type.a_var,bh_pthuc out pht_type.a_var,bh_nbh out pht_type.a_var,
    bh_pt out pht_type.a_num,bh_hh out pht_type.a_num,bh_tien out pht_type.a_num,bh_phi out pht_type.a_num,
    bh_hhong out pht_type.a_num,bh_tl_thue out pht_type.a_num,bh_thue out pht_type.a_num,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_i2 number; b_i3 number;
    b_ngay number:=PKH_NG_CSO(sysdate); b_tpT number:=0; b_tpP number:=0;
    dk_lh_nv pht_type.a_var; dk_tien pht_type.a_num; dk_phi pht_type.a_num;
    bh_so_id_dtC pht_type.a_var; bh_so_id_dt pht_type.a_num; bh_phiC pht_type.a_num;
begin
-- Dan - Phi doi tuong
b_lenh:=FKH_JS_LENH('so_id_dt,lh_nv,kieu,pthuc,nha_bh,pt,hh');
EXECUTE IMMEDIATE b_lenh bulk collect into bh_so_id_dtC,bh_lh_nv,bh_kieu,bh_pthuc,bh_nbh,bh_pt,bh_hh using dt_bh;
for b_lp in 1..bh_lh_nv.count loop
    bh_so_id_dtC(b_lp):=PKH_MA_TENl(bh_so_id_dtC(b_lp));
    bh_so_id_dt(b_lp):=PKH_LOC_CHU(bh_so_id_dtC(b_lp),'F','F');
    bh_lh_nv(b_lp):=nvl(PKH_MA_TENl(bh_lh_nv(b_lp)),' '); bh_kieu(b_lp):=nvl(bh_kieu(b_lp),' ');
    bh_pthuc(b_lp):=nvl(bh_pthuc(b_lp),' '); bh_nbh(b_lp):=nvl(PKH_MA_TENl(bh_nbh(b_lp)),' ');
    bh_pt(b_lp):=nvl(bh_pt(b_lp),0); bh_hh(b_lp):=nvl(bh_hh(b_lp),0);
end loop;
if b_nv='PHH' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_phh where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select lh_nv,tien,phi bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_phh_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and lh_nv<>' ';
elsif b_nv='PHHB' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_phhB where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select lh_nv,tien,phi bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_phhB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and lh_nv<>' ';
elsif b_nv='PKT' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_pkt where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select lh_nv,tien,phi bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_pkt_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and lh_nv<>' ';
elsif b_nv='PKTB' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_pktB where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select lh_nv,tien,phi bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_pktB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and lh_nv<>' ';
elsif b_nv='TAU' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select lh_nv,tien,phi bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_tau_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and lh_nv<>' ';
elsif b_nv='TAUB' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_tauB where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select lh_nv,tien,phi bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_tauB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and lh_nv<>' ';
elsif b_nv='XE' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_xe where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select lh_nv,tien,phi bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_xe_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and lh_nv<>' ';
elsif b_nv='XEB' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_xeB where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select lh_nv,tien,phi bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_xeB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and lh_nv<>' ';
elsif b_nv='2B' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select lh_nv,tien,phi bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_2b_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and lh_nv<>' ';
elsif b_nv='2BB' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_2bB where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select lh_nv,tien,phi bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_2bB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and lh_nv<>' ';
elsif b_nv='NG' then
    --nampb: b_so_id_dt in(0,so_id_dt)
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select lh_nv,sum(tien),sum(phi) bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_ng_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and b_so_id_dt in(0,so_id_dt) and lh_nv<>' ' group by lh_nv;
elsif b_nv='NGB' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_ngB where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select lh_nv,sum(tien),sum(phi) bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_ngB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and b_so_id_dt in(0,so_id_dt) and lh_nv<>' ' group by lh_nv;
--Nam: them nv PTN
elsif b_nv='PTN' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select lh_nv,sum(tien),sum(phi) bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_ptn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
elsif b_nv='PTNB' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_ptnB where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select lh_nv,sum(tien),sum(phi) bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_ptnB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
elsif b_nv='HANG' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select lh_nv,sum(tien),sum(phi) bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_hang_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
elsif b_nv='HANGB' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_hangB where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select lh_nv,sum(tien),sum(phi) bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_hangB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
end if;
if b_nt_tien<>'VND' then b_tpT:=2; end if;
if b_nt_phi<>'VND' then b_tpP:=2; end if;
b_tien:=0; b_phi:=0; b_tienH:=0; b_phiH:=0; 
for b_lp in 1..dk_lh_nv.count loop
    b_tienH:=b_tienH+dk_tien(b_lp); b_phiH:=b_phiH+dk_phi(b_lp);
end loop;
for b_lp in 1..bh_lh_nv.count loop
    bh_tien(b_lp):=0; bh_phi(b_lp):=0; bh_phiC(b_lp):=0;
    bh_hhong(b_lp):=0; bh_tl_thue(b_lp):=0; bh_thue(b_lp):=0;
    if bh_pthuc(b_lp) in ('P','D') then continue; end if;
    for b_lp1 in 1..dk_lh_nv.count loop
        if bh_so_id_dt(b_lp) not in(0,b_so_id_dt) or bh_lh_nv(b_lp) not in(' ',dk_lh_nv(b_lp1)) then continue; end if;
        bh_tien(b_lp):=bh_tien(b_lp)+round(dk_tien(b_lp1)*bh_pt(b_lp)/100,b_tpT);
        b_i1:=round(dk_phi(b_lp1)*bh_pt(b_lp)/100,b_tpP);
        if b_kieu='D' or b_nhom='T' then
            b_i2:=round(b_i1*bh_hh(b_lp)/100,b_tpP);
                bh_hhong(b_lp):=bh_hhong(b_lp)+b_i2;
            if b_kieu='D' then
                PTBH_PBO_NOP(dk_lh_nv(b_lp1),bh_nbh(b_lp),b_ngay,b_i1,b_tpP,b_i2,b_i3,b_loi);
                bh_thue(b_lp):=bh_thue(b_lp)+b_i3;
            end if;
        end if;
        bh_phi(b_lp):=bh_phi(b_lp)+b_i1;
    end loop;
    if bh_phi(b_lp)<>0 then bh_tl_thue(b_lp):=round(bh_thue(b_lp)*100/bh_phi(b_lp),2); end if;
    b_tien:=b_tien+bh_tien(b_lp); b_phi:=b_phi+bh_phi(b_lp);
end loop;
if b_kieu='D' or b_nhom='T' then b_loi:=''; return; end if;
for b_lp1 in 1..dk_lh_nv.count loop
    b_i1:=dk_phi(b_lp1);
    for b_lp in 1..bh_lh_nv.count loop
        if bh_so_id_dt(b_lp) in(0,b_so_id_dt) and bh_lh_nv(b_lp) in(' ',dk_lh_nv(b_lp1)) then
            b_i1:=b_i1-bh_phi(b_lp);
        end if;
    end loop;
    if b_i1>0 then
        for b_lp in 1..bh_lh_nv.count loop
            if bh_kieu(b_lp)='D' and bh_so_id_dt(b_lp) in(0,b_so_id_dt) and bh_lh_nv(b_lp) in(' ',dk_lh_nv(b_lp1)) then
                bh_hhong(b_lp):=round(b_i1*bh_hh(b_lp)/100,b_tpP);
            end if;
        end loop;        
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_HD_DO_NH_PHId:loi'; end if;
end;
/
create or replace procedure FBH_HD_DO_NH_PHI(
    dt_ct clob,dt_bh clob,b_nhom varchar2,
    b_ma_dvi varchar2,b_so_id number,b_nv varchar2,b_kieu varchar2,
    b_nt_tien out varchar2,b_nt_phi out varchar2,
    b_tien out number,b_phi out number,b_tienH out number,b_phiH out number,
    bh_so_id_dt out pht_type.a_num,bh_ten_dt out pht_type.a_var,
    bh_lh_nv out pht_type.a_var,bh_kieu out pht_type.a_var,bh_pthuc out pht_type.a_var,bh_nbh out pht_type.a_var,
    bh_pt out pht_type.a_num,bh_hh out pht_type.a_num,bh_tien out pht_type.a_num,bh_phi out pht_type.a_num,
    bh_hhong out pht_type.a_num,bh_tl_thue out pht_type.a_num,bh_thue out pht_type.a_num,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_i2 number; b_i3 number;
    b_ngay number:=PKH_NG_CSO(sysdate); b_tpT number:=0; b_tpP number:=0; b_ch varchar2(10);
    dk_so_id_dt pht_type.a_num; dk_lh_nv pht_type.a_var; dk_tien pht_type.a_num; dk_phi pht_type.a_num;
    dk_phiC pht_type.a_var;
begin
-- Dan - Phi hop dong
b_lenh:=FKH_JS_LENH('so_id_dt,lh_nv,kieu,pthuc,nha_bh,pt,hh');
EXECUTE IMMEDIATE b_lenh bulk collect into bh_so_id_dt,bh_lh_nv,bh_kieu,bh_pthuc,bh_nbh,bh_pt,bh_hh using dt_bh;
for b_lp in 1..bh_lh_nv.count loop
    bh_kieu(b_lp):=nvl(bh_kieu(b_lp),' ');
    if bh_kieu(b_lp)=' ' then b_loi:='loi:Nhap vai tro nha dong:loi'; return; end if;
    bh_lh_nv(b_lp):=nvl(PKH_MA_TENl(bh_lh_nv(b_lp)),' ');
    bh_pthuc(b_lp):=nvl(bh_pthuc(b_lp),' '); bh_nbh(b_lp):=nvl(PKH_MA_TENl(bh_nbh(b_lp)),' ');
    bh_pt(b_lp):=nvl(bh_pt(b_lp),0); bh_hh(b_lp):=nvl(bh_hh(b_lp),0);
end loop;
if b_nv='PHH' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_phh where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select so_id_dt,lh_nv,tien,phi bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
        from bh_phh_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ';
elsif b_nv='PHHB' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_phhB where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select so_id_dt,lh_nv,tien,phi bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
        from bh_phhB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ';
elsif b_nv='PKT' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_pkt where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select so_id_dt,lh_nv,tien,phi bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
        from bh_pkt_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ';
elsif b_nv='PKTB' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_pktB where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select so_id_dt,lh_nv,tien,phi bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
        from bh_pktB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ';
elsif b_nv='TAU' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select so_id_dt,lh_nv,tien,phi bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
        from bh_tau_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ';
elsif b_nv='TAUB' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_tauB where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select so_id_dt,lh_nv,tien,phi bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
        from bh_tauB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ';
elsif b_nv='XE' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_xe where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select so_id_dt,lh_nv,tien,phi bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
        from bh_xe_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ';
elsif b_nv='XEB' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_xeB where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select so_id_dt,lh_nv,tien,phi bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
        from bh_xeB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ';
elsif b_nv='2B' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select so_id_dt,lh_nv,tien,phi bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
        from bh_2b_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ';
elsif b_nv='2BB' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_2bB where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select so_id_dt,lh_nv,tien,phi bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
        from bh_2bB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ';
elsif b_nv='NG' then
    b_ch:=FBH_SOAN_BGHD_NG(b_ma_dvi,b_so_id); -- Nam: check lay don tung line
    if b_ch=' ' then
        select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
        select 0,lh_nv,sum(tien),sum(phi) bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
             from bh_ng_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
     else
        select count(*) into b_i1 from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
        if b_i1<>0 then
           select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
           select 0,lh_nv,sum(tien),sum(phi) bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
               from bh_ng_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
        elsif b_ch='SK' then
           select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
           select 0,lh_nv,sum(tien),sum(phi) bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
               from bh_sk_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
        elsif b_ch='DL' then
           select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_id;
           select 0,lh_nv,sum(tien),sum(phi) bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
               from bh_ngdl_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
        else
           select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_id;
           select 0,lh_nv,sum(tien),sum(phi) bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
               from bh_ngtd_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
        end if;
     end if;
elsif b_nv='NGB' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_ngB where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select 0,lh_nv,sum(tien),sum(phi) bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
        from bh_ngB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
-- Nam: them nv PTN
elsif b_nv='PTN' then
    b_ch:=FBH_SOAN_BGHD_PTN(b_ma_dvi,b_so_id); -- Nam: check lay don tung line
    if b_ch=' ' then
        select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id;
        select 0,lh_nv,sum(tien),sum(phi) bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
             from bh_ptn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
     else
        select count(*) into b_i1 from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id;
        if b_i1<>0 then
           select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id;
           select 0,lh_nv,sum(tien),sum(phi) bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
               from bh_ptn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
        elsif b_ch='CC' then
           select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_ptncc where ma_dvi=b_ma_dvi and so_id=b_so_id;
           select 0,lh_nv,sum(tien),sum(phi) bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
               from bh_ptncc_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
        elsif b_ch='NN' then
           select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_ptnnn where ma_dvi=b_ma_dvi and so_id=b_so_id;
           select 0,lh_nv,sum(tien),sum(phi) bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
               from bh_ptnnn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
        else
           select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_id;
           select 0,lh_nv,sum(tien),sum(phi) bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
               from bh_ptnvc_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
        end if;
     end if;
elsif b_nv='PTNB' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_ptnB where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select 0,lh_nv,sum(tien),sum(phi) bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
        from bh_ptnB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
elsif b_nv='HANG' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select 0,lh_nv,sum(tien),sum(phi) bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
        from bh_hang_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
elsif b_nv='HANGB' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_hangB where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select 0,lh_nv,sum(tien),sum(phi) bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
        from bh_hangB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
elsif b_nv='HOP' then --Nam: them nv HOP
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_hop where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select 0,lh_nv,sum(tien),sum(phi) bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
        from bh_hop_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
elsif b_nv='HOPB' then
    select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_hopB where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select 0,lh_nv,sum(tien),sum(phi) bulk collect into dk_so_id_dt,dk_lh_nv,dk_tien,dk_phi
        from bh_hopB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
end if;
if b_nt_tien<>'VND' then b_tpT:=2; end if;
if b_nt_phi<>'VND' then b_tpP:=2; end if;
b_tien:=0; b_phi:=0; b_tienH:=0; b_phiH:=0; 
for b_lp in 1..dk_lh_nv.count loop
    b_tienH:=b_tienH+dk_tien(b_lp); b_phiH:=b_phiH+dk_phi(b_lp);
end loop;
for b_lp in 1..bh_lh_nv.count loop
    bh_tien(b_lp):=0; bh_phi(b_lp):=0;
    bh_hhong(b_lp):=0; bh_tl_thue(b_lp):=0; bh_thue(b_lp):=0;
    bh_ten_dt(b_lp):=FBH_HD_DTUONG(b_nv,b_ma_dvi,b_so_id,bh_so_id_dt(b_lp));
    for b_lp1 in 1..dk_lh_nv.count loop
        if bh_so_id_dt(b_lp) not in(0,dk_so_id_dt(b_lp1)) or bh_lh_nv(b_lp) not in(' ',dk_lh_nv(b_lp1)) then continue; end if;
        bh_tien(b_lp):=bh_tien(b_lp)+round(dk_tien(b_lp1)*bh_pt(b_lp)/100,b_tpT);
        b_i1:=round(dk_phi(b_lp1)*bh_pt(b_lp)/100,b_tpP);
        if b_kieu='D' or b_nhom='T' then
            b_i2:=round(b_i1*bh_hh(b_lp)/100,b_tpP);
                bh_hhong(b_lp):=bh_hhong(b_lp)+b_i2;
            if b_kieu='D' then
                PTBH_PBO_NOP(dk_lh_nv(b_lp1),bh_nbh(b_lp),b_ngay,b_i1,b_tpP,b_i2,b_i3,b_loi);
                bh_thue(b_lp):=bh_thue(b_lp)+b_i3;
            end if;
        end if;
        bh_phi(b_lp):=bh_phi(b_lp)+b_i1;
    end loop;
    if bh_phi(b_lp)<>0 then bh_tl_thue(b_lp):=round(bh_thue(b_lp)*100/bh_phi(b_lp),2); end if;
    b_tien:=b_tien+bh_tien(b_lp); b_phi:=b_phi+bh_phi(b_lp);
end loop;
if b_kieu='D' or b_nhom='T' then b_loi:=''; return; end if;
for b_lp1 in 1..dk_lh_nv.count loop
    b_i1:=dk_phi(b_lp1);
    for b_lp in 1..bh_lh_nv.count loop
        if bh_so_id_dt(b_lp) in(0,dk_so_id_dt(b_lp1)) and bh_lh_nv(b_lp) in(' ',dk_lh_nv(b_lp1)) then
            b_i1:=b_i1-bh_phi(b_lp);
        end if;
    end loop;
    if b_i1>0 then
        for b_lp in 1..bh_lh_nv.count loop
            if bh_kieu(b_lp)='D' and bh_so_id_dt(b_lp) in(0,dk_so_id_dt(b_lp1)) and bh_lh_nv(b_lp) in(' ',dk_lh_nv(b_lp1)) then
                bh_hhong(b_lp):=round(b_i1*bh_hh(b_lp)/100,b_tpP);
            end if;
        end loop;        
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_HD_DO_NH_PHI:loi'; end if;
end;
/
create or replace procedure PBH_HD_DO_NH_PHI(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000); dt_ct clob; dt_bh clob; b_c clob;
    b_ma_dvi varchar2(10); b_so_id number; b_nv varchar2(10); b_nvQ varchar2(5); b_kt number:=0;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_kieu varchar2(1); b_dl varchar2(1); b_nhom varchar2(1);
    b_tien number; b_phi number; b_tienH number; b_phiH number; b_ngay_ht number;
    bh_so_id_dt pht_type.a_num; bh_ten_dt pht_type.a_var; bh_lh_nv pht_type.a_var;
    bh_kieu pht_type.a_var; bh_pthuc pht_type.a_var; bh_nbh pht_type.a_var;
    bh_pt pht_type.a_num; bh_hh pht_type.a_num; bh_tien pht_type.a_num; bh_phi pht_type.a_num; 
    bh_hhong pht_type.a_num; bh_tl_thue pht_type.a_num; bh_thue pht_type.a_num; 
    a_ma_dvi pht_type.a_var; a_so_id pht_type.a_num;
    
    b_t JSON_OBJECT_T; a_t JSON_ARRAY_T;
begin
-- Dan - Tinh phi
b_lenh:=FKH_JS_LENH('nhom,ma_dvi,so_id,nvg,nvq');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_ma_dvi,b_so_id,b_nv,b_nvQ using b_oraIn;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH',b_nvQ,'X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_bh');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_bh using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_bh);
b_lenh:=FKH_JS_LENH('ngay_hl,kieu,dl');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_kieu,b_dl using dt_ct;
b_nhom:=nvl(trim(b_nhom),'D'); b_dl:=nvl(trim(b_dl),'K'); b_ngay_ht:=nvl(b_ngay_ht,0);
if b_ngay_ht in(0,30000101) then b_ngay_ht:=PKH_NG_CSO(sysdate); end if;
FBH_HD_DO_NH_PHI(dt_ct,dt_bh,b_nhom,
    b_ma_dvi,b_so_id,b_nv,b_kieu,b_nt_tien,b_nt_phi,b_tien,b_phi,b_tienH,b_phiH,
    bh_so_id_dt,bh_ten_dt,bh_lh_nv,bh_kieu,bh_pthuc,bh_nbh,bh_pt,bh_hh,bh_tien,bh_phi,bh_hhong,bh_tl_thue,bh_thue,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if bh_lh_nv.count=0 then b_loi:='loi:Khong du tham so tinh phi:loi'; raise PROGRAM_ERROR; end if;
b_tien:=0; b_phi:=0; a_t:=JSON_ARRAY_T();
for b_lp in 1..bh_lh_nv.count loop
    b_tien:=b_tien+bh_tien(b_lp); b_phi:=b_phi+bh_phi(b_lp);
    select json_object(
        'kieu' value bh_kieu(b_lp),'nha_bh' value FBH_MA_NBH_TENl(bh_nbh(b_lp)),
        'pt' value bh_pt(b_lp),'hh' value bh_hh(b_lp),'tien' value bh_tien(b_lp),'phi' value bh_phi(b_lp),
        'hhong' value bh_hhong(b_lp),'thue' value bh_thue(b_lp),
        'so_id_dt' value bh_so_id_dt(b_lp),'lh_nv' value FBH_MA_LHNV_TENl(bh_lh_nv(b_lp)),
        'tl_thue' value bh_tl_thue(b_lp),'pthuc' value bh_pthuc(b_lp)) into b_c from dual;
    b_t:=JSON_OBJECT_T(b_c); a_t.append(b_t);
end loop;
dt_bh:=a_t.to_clob();
if b_nhom<>'T' then
    b_tien:=b_tienH-b_tien; b_phi:=b_phiH-b_phi;
end if;
select json_object('tien' value b_tien,'phi' value b_phi) into dt_ct from dual;
select json_object('dt_ct' value dt_ct,'dt_bh' value dt_bh) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_DO_NH_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number; b_das varchar2(1):='K';
    b_ma_dvi varchar2(10); b_so_id number; b_nv varchar2(10); b_nhom varchar2(1); b_nvQ varchar2(5);
    dt_ct clob:=''; dt_bh clob:=''; dt_dt clob:=''; dt_nv clob:='';
begin
-- Dan - Xem
b_lenh:=FKH_JS_LENH('ma_dvi,so_id,nvg,nhom,nvq');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id,b_nv,b_nhom,b_nvQ using b_oraIn;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH',b_nvQ,'X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=nvl(b_so_id,0); b_nhom:=nvl(trim(b_nhom),' ');
if b_so_id=0 then b_loi:='loi:Nhap so ID hop dong:loi'; raise PROGRAM_ERROR; end if;
if b_nhom not in('D','F','T') then b_loi:='loi:Sai nhom:loi'; raise PROGRAM_ERROR; end if;
b_i1:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
if b_i1 not in(0,b_so_id) then b_so_id:=b_i1; end if;
select count(*) into b_i1 from bh_hd_do_nh where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom;
if b_i1=1 then
    select txt into dt_ct from bh_hd_do_nh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom and loai='dt_ct';
    select txt into dt_bh from bh_hd_do_nh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom and loai='dt_bh';
    if b_nhom='D' then
        select count(*) into b_i1 from bh_hd_do_nhL where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom;
        if b_i1<>0 then b_das:='C'; end if;
    end if;
end if;
dt_nv:=FBH_HD_NVl(b_nv,b_ma_dvi,b_so_id); dt_dt:=FBH_HD_DTUONGc(b_nv,b_ma_dvi,b_so_id);
select json_object('das' value b_das, 'dt_ct' value dt_ct,'dt_bh' value dt_bh,
    'dt_dt' value dt_dt,'dt_nv' value dt_nv returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_DO_NH_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nhom varchar2,b_loi out varchar2,b_nh varchar2:='C')
As
    b_nsdC varchar2(10); b_i1 number; b_ngay_hl number; b_ttrang varchar2(1); b_so_id_ps number;
begin
select nvl(min(nsd),' '),count(*) into b_nsdC,b_i1 from bh_hd_do_nh where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom;
if b_i1=0 then b_loi:=''; return; end if;
if b_nsdC<>b_nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac nhap:loi'; return; end if;
if FBH_HD_TTRANG(b_ma_dvi,b_so_id) in('D','H') then b_loi:='loi:Hop dong da duyet hoac da huy:loi'; return; end if;
delete bh_hd_do_nh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom;
delete bh_hd_do_nh where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom;
if b_nhom='T' then
    PTBH_TMN_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
else
    PBH_HD_DO_TL_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi,b_nh);
end if;
if b_loi is not null then return; end if;
if b_nh<>'C' then
    select nvl(max(ngay_hl),0) into b_ngay_hl from bh_hd_do_nhL where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom;
    if b_ngay_hl<>0 then
        insert into bh_hd_do_nh select * from bh_hd_do_nhL
            where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom and ngay_hl=b_ngay_hl;
        insert into bh_hd_do_nh_txt select * from bh_hd_do_nhL_txt
            where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom and ngay_hl=b_ngay_hl;
        delete bh_hd_do_nhL_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom and ngay_hl=b_ngay_hl;
        delete bh_hd_do_nhL where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom and ngay_hl=b_ngay_hl;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_DO_NH_XOA_XOA:loi'; end if;
end;
/
create or replace procedure PBH_HD_DO_NH_XOA(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number; b_nhom varchar2(1); b_nvQ varchar2(5);
begin
-- Dan - Xoa
b_lenh:=FKH_JS_LENH('ma_dvi,so_id,nhom,nvq');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id,b_nhom,b_nvQ using b_oraIn;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH',b_nvQ,'N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=nvl(b_so_id,0); b_nhom:=nvl(trim(b_nhom),' ');
if b_so_id=0 then b_loi:='loi:Nhap so ID hop dong:loi'; raise PROGRAM_ERROR; end if;
if b_nhom not in('D','F','T') then b_loi:='loi:Sai nhom:loi'; raise PROGRAM_ERROR; end if;
PBH_HD_DO_NH_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_nhom,b_loi,'K');
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_DO_NH_NH(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(2000);
    b_ma_dvi varchar2(10); b_so_id number; b_nhom varchar2(1); b_ngay_hl number; b_ngay_hlC number;
    b_kieu varchar2(1); b_dk varchar2(1); b_nv varchar2(10); b_nt_tien varchar2(5); b_nt_phi varchar2(5);  b_nvQ varchar2(5);
    dk_so_id_dtC pht_type.a_var; dk_so_id_dt pht_type.a_num;
    dk_nha_bh pht_type.a_var; dk_pthuc pht_type.a_var; 
    dk_lh_nv pht_type.a_var; dk_pt pht_type.a_num; dk_hh pht_type.a_num;
    a_ma_dvi pht_type.a_var; a_so_id pht_type.a_num;
    a_so_id_dt pht_type.a_num; a_so_id_dtK pht_type.a_num;
    dt_ct clob; dt_bh clob; b_ksoat varchar2(20); b_nsdC varchar2(20);
begin
-- Dan - Nhap
b_lenh:=FKH_JS_LENH('ma_dvi,so_id,nhom,nvg,dk,nvq');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id,b_nhom,b_nv,b_dk,b_nvQ using b_oraIn;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH',b_nvQ,'N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_bh');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_bh using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_bh);
b_lenh:=FKH_JS_LENH('ngay_hl,kieu');
EXECUTE IMMEDIATE b_lenh into b_ngay_hl,b_kieu using dt_ct;
b_so_id:=nvl(b_so_id,0); b_dk:=nvl(trim(b_dk),'N');
if b_so_id=0 then b_loi:='loi:Nhap hop dong:loi'; raise PROGRAM_ERROR; end if;
if b_nhom not in('D','F','T') then b_loi:='loi:Sai nhom:loi'; raise PROGRAM_ERROR; end if;
if trim(dt_bh) is null then b_loi:='loi:Nhap ty le:loi'; raise PROGRAM_ERROR; end if;
-- chuclh: kiem soat nsd
select count(1) into b_i1 from bh_hd_goc where so_id=b_so_id;
if b_i1 > 0 then
  select ksoat,nsd into b_ksoat,b_nsdC from bh_hd_goc where so_id=b_so_id;
  if b_nsdC<>b_nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; raise PROGRAM_ERROR; end if;
  if trim(b_ksoat) is not null and b_ksoat<>b_nsd then b_loi:='loi:Khong sua, xoa GCN, hop dong da kiem soat:loi'; raise PROGRAM_ERROR; end if;
end if;

b_lenh:=FKH_JS_LENH('so_id_dt,nha_bh,pthuc,lh_nv,pt,hh');
EXECUTE IMMEDIATE b_lenh bulk collect into 
    dk_so_id_dtC,dk_nha_bh,dk_pthuc,dk_lh_nv,dk_pt,dk_hh using dt_bh;
for b_lp in 1..dk_nha_bh.count loop
    b_loi:='loi:Sai so lieu chi tiet dong '||to_char(b_lp)||':loi';
    dk_so_id_dtC(b_lp):=PKH_MA_TENl(dk_so_id_dtC(b_lp));
    dk_so_id_dt(b_lp):=PKH_LOC_CHU(dk_so_id_dtC(b_lp),'F','F');
    dk_nha_bh(b_lp):=nvl(PKH_MA_TENl(dk_nha_bh(b_lp)),' ');
    dk_lh_nv(b_lp):=nvl(PKH_MA_TENl(dk_lh_nv(b_lp)),' ');
    if dk_nha_bh(b_lp)=' ' then b_loi:='loi:Nhap nha bao hiem:loi'; raise PROGRAM_ERROR; end if;
    if dk_pt(b_lp) not between 0 and 100 or dk_hh(b_lp) not between 0 and 100 then
        b_loi:='loi:Sai ty le, % hoa hong:loi'; raise PROGRAM_ERROR;
    end if;
    if dk_nha_bh(b_lp)=b_ma_dvi then b_loi:='loi:Trung don vi dong BH:loi'; raise PROGRAM_ERROR; end if;
    b_loi:='loi:Chua nhap don vi dong BH '||dk_nha_bh(b_lp)||':loi';
end loop;
if FKH_ARR_TONG(dk_pt)>100 then b_loi:='loi:Tong ty le vuot qua 100%:loi'; raise PROGRAM_ERROR; end if;
b_kieu:=nvl(trim(b_kieu),' ');
if b_kieu not in('D','V') then b_loi:='loi:Sai kieu:loi'; raise PROGRAM_ERROR; end if;
b_ngay_hl:=nvl(b_ngay_hl,0);
if b_ngay_hl in(0,30000101) then b_ngay_hl:=PKH_NG_CSO(sysdate); end if;
b_i1:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
if b_i1 not in(0,b_so_id) then b_so_id:=b_i1; end if;
if b_nhom='D' then
    select nvl(max(ngay_hl),0) into b_ngay_hlC from bh_hd_do_nhL
        where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom;
    if b_ngay_hlC>=b_ngay_hl then
        b_loi:='loi:Da co thay doi ngay '||PKH_SO_CNG(b_ngay_hlC)||':loi'; raise PROGRAM_ERROR; 
    end if;
    if b_dk='S' then
        select nvl(max(ngay_hl),0) into b_ngay_hlC from bh_hd_do_nh
            where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom;
        if b_ngay_hlC<>0 then
            delete bh_hd_do_nhL_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom and ngay_hl=b_ngay_hlC;
            delete bh_hd_do_nhL where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom and ngay_hl=b_ngay_hlC;
            insert into bh_hd_do_nhL select * from bh_hd_do_nh
                where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom;
            insert into bh_hd_do_nhL_txt select * from bh_hd_do_nh_txt
                where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom;
        end if;
    end if;
end if;
PBH_HD_DO_NH_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_nhom,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
insert into bh_hd_do_nh values(b_ma_dvi,b_so_id,b_nhom,b_kieu,b_nv,b_ngay_hl,b_nsd,sysdate);
insert into bh_hd_do_nh_txt values(b_ma_dvi,b_so_id,b_nhom,b_ngay_hl,'dt_ct',dt_ct);
insert into bh_hd_do_nh_txt values(b_ma_dvi,b_so_id,b_nhom,b_ngay_hl,'dt_bh',dt_bh);
if b_nhom='F' then
    PTBH_DO_FR_NH(b_ma_dvi,b_nsd,b_so_id,b_nv,b_oraIn,b_loi);
elsif b_nhom='T' then
    PTBH_TMN_NH(b_ma_dvi,b_nsd,b_so_id,b_nv,b_oraIn,b_loi);
else
    if b_dk='S' then
        PBH_HD_DO_TL_SUA(b_ma_dvi,b_nsd,b_so_id,b_nv,b_oraIn,b_loi);
    else
        PBH_HD_DO_TL_NH(b_ma_dvi,b_nsd,b_so_id,b_nv,b_oraIn,b_loi);
    end if;
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_HD_DO_TL_TXT(
    b_ma_dvi varchar2,b_so_id number,b_ngay_hl number,b_tim varchar2) return varchar2
AS
    b_kq varchar2(100):=' '; b_i1 number; b_txt clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
select count(*) into b_i1 from bh_hd_do_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_hl=b_ngay_hl and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_hd_do_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_hl=b_ngay_hl and loai='dt_ct';
    b_kq:=nvl(trim(FKH_JS_GTRIs(b_txt,b_tim)),' ');
end if;
return b_kq;
end;
/
create or replace procedure PBH_HD_DO_TL_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2,b_nh varchar2:='C')
As
  b_nsdC varchar2(10); b_i1 number; b_ngay_hl number; b_ttrang varchar2(1); b_so_id_ps number;
begin
-- Dan - Xoa
select count(*),nvl(trim(min(nsd)),' ') into b_i1,b_nsdC from bh_hd_do where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
if b_nsdC not in(' ',b_nsd) then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
select nvl(max(ngay_hl),0),count(*) into b_ngay_hl,b_i1 from bh_hd_doL where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then b_so_id_ps:=b_so_id*10+b_i1; end if;
b_ttrang:=FBH_HD_TTRANG(b_ma_dvi,b_so_id);
if b_ttrang in('D','H') then b_loi:='loi:Khong sua, xoa ty le dong cho hop dong da duyet hoac da huy:'; end if;
delete bh_hd_do_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_do_tl where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_do where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_ngay_hl=0 then
    delete bh_hd_goc_phi_nbh where ma_dvi=b_ma_dvi and so_id=b_so_id;
    delete bh_hd_do_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
    delete bh_hd_do_sc_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
elsif b_nh='K' then
    insert into bh_hd_do select * from bh_hd_doL where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_hl=b_ngay_hl;
    insert into bh_hd_do_tl select * from bh_hd_doL_tl where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_hl=b_ngay_hl;
    insert into bh_hd_do_txt select * from bh_hd_doL_txt
        where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_hl=b_ngay_hl;
    delete bh_hd_doL_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_hl=b_ngay_hl;
    delete bh_hd_doL_tl where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_hl=b_ngay_hl;
    delete bh_hd_doL where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_hl=b_ngay_hl;
    delete bh_hd_do_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
    delete bh_hd_do_sc_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_DO_TL_XOA_XOA:loi'; end if;
end;
/
create or replace procedure PBH_HD_DO_TL_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2,b_nh varchar2:='K')
AS
    b_ttrang varchar2(1);
begin
-- Dan - Xoa
PBH_HD_DO_TL_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi,b_nh);
if b_loi is not null then return; end if;
if FBH_HD_TTRANG(b_ma_dvi,b_so_id)='T' and FBH_HD_CO_TAM(b_ma_dvi,b_so_id)='C' then
    PTBH_TMB_CBI_NH(b_ma_dvi,b_so_id,b_loi,'X');
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_DO_TL_XOA:loi'; end if;
end;
/
create or replace procedure PBH_HD_DO_TL_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nv varchar2,b_oraIn clob,b_loi out varchar2)
AS
    b_i1 number; b_lenh varchar2(2000);
    b_ngay_hl number; b_kieu varchar2(1); b_ttrang varchar2(1);
    dk_so_id_dt pht_type.a_num;
    dk_nha_bh pht_type.a_var; dk_kieu pht_type.a_var; 
    dk_lh_nv pht_type.a_var; dk_pt pht_type.a_num; dk_hh pht_type.a_num;
    dt_ct clob; dt_bh clob;
begin
-- Dan - Nhap
b_lenh:=FKH_JS_LENHc('dt_ct,dt_bh');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_bh using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_bh);
b_lenh:=FKH_JS_LENH('ngay_hl,kieu');
EXECUTE IMMEDIATE b_lenh into b_ngay_hl,b_kieu using dt_ct;
b_lenh:=FKH_JS_LENH('so_id_dt,nha_bh,kieu,lh_nv,pt,hh');
EXECUTE IMMEDIATE b_lenh bulk collect into dk_so_id_dt,dk_nha_bh,dk_kieu,dk_lh_nv,dk_pt,dk_hh using dt_bh;
for b_lp in 1..dk_nha_bh.count loop
    dk_kieu(b_lp):=nvl(trim(dk_kieu(b_lp)),' ');
    if dk_kieu(b_lp)=' ' then b_loi:='loi:Nhap vai tro nha dong:loi'; return; end if;
    dk_nha_bh(b_lp):=nvl(PKH_MA_TENl(dk_nha_bh(b_lp)),' ');
    dk_pt(b_lp):=nvl(dk_pt(b_lp),0); dk_hh(b_lp):=nvl(dk_hh(b_lp),0);
    dk_lh_nv(b_lp):=nvl(PKH_MA_TENl(dk_lh_nv(b_lp)),' ');
end loop;
PBH_HD_DO_TL_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi,'C');
if b_loi is not null then return; end if;
if b_kieu='V' then
    for b_lp in 1..dk_lh_nv.count loop
        if dk_kieu(b_lp)<>'V' then continue; end if;
        for b_lp1 in 1..dk_lh_nv.count loop
            if dk_kieu(b_lp1)='D' and dk_so_id_dt(b_lp1)=dk_so_id_dt(b_lp) and dk_lh_nv(b_lp1)=dk_lh_nv(b_lp) then
                dk_pt(b_lp1):=dk_pt(b_lp1)+dk_pt(b_lp); exit;
            end if;
        end loop;
    end loop;
end if;
insert into bh_hd_do values(b_ma_dvi,b_so_id,b_kieu,b_nv,b_ngay_hl,b_nsd);
b_i1:=0;
for b_lp in 1..dk_nha_bh.count loop
    if b_kieu='D' or dk_kieu(b_lp)='D' then
        b_i1:=b_i1+1;
        if b_kieu='V' then dk_pt(b_lp):=100-dk_pt(b_lp); end if;
        insert into bh_hd_do_tl values(b_ma_dvi,b_so_id,dk_so_id_dt(b_lp),dk_nha_bh(b_lp),
            'C',dk_lh_nv(b_lp),dk_pt(b_lp),dk_hh(b_lp),b_ngay_hl);
    end if;
end loop;
if b_i1=0 or (b_kieu='V' and b_i1<>1) then b_loi:='loi:Sai phuong thuc nha dong:loi'; return; end if;
insert into bh_hd_do_txt values(b_ma_dvi,b_so_id,b_ngay_hl,'dt_ct',dt_ct);
insert into bh_hd_do_txt values(b_ma_dvi,b_so_id,b_ngay_hl,'dt_bh',dt_bh);
b_ttrang:=FBH_HD_TTRANG(b_ma_dvi,b_so_id);
if b_ttrang='D' then
    PBH_HD_GOC_THL_CT(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
    if b_kieu='V' then
        PBH_THL_PHI_NBH(b_ma_dvi,b_so_id,b_loi);
        if b_loi is not null then return; end if;
    end if;
    PBH_TH_DOps(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
    PTBH_CBI_NH(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
elsif b_ttrang='T' and FBH_HD_CO_TAM(b_ma_dvi,b_so_id)='C' then
    PTBH_TMB_CBI_NH(b_ma_dvi,b_so_id,b_loi,'X');
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_DO_TL_NH:loi'; end if;
end;
/
create or replace procedure PBH_HD_DO_TL_SUA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nv varchar2,b_oraIn clob,b_loi out varchar2)
AS
    b_i1 number; b_lenh varchar2(2000);
    b_ngay_hl number; b_kieu varchar2(1); b_so_id_ps number:=0;
    dk_so_id_dt pht_type.a_num;
    dk_nha_bh pht_type.a_var; dk_kieu pht_type.a_var; 
    dk_lh_nv pht_type.a_var; dk_pt pht_type.a_num; dk_hh pht_type.a_num;
    dt_ct clob; dt_bh clob;
begin
-- Dan - Nhap
b_lenh:=FKH_JS_LENHc('dt_ct,dt_bh');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_bh using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_bh);
b_lenh:=FKH_JS_LENH('ngay_hl,kieu');
EXECUTE IMMEDIATE b_lenh into b_ngay_hl,b_kieu using dt_ct;
b_lenh:=FKH_JS_LENH('so_id_dt,nha_bh,kieu,lh_nv,pt,hh');
EXECUTE IMMEDIATE b_lenh bulk collect into 
    dk_so_id_dt,dk_nha_bh,dk_kieu,dk_lh_nv,dk_pt,dk_hh using dt_bh;
for b_lp in 1..dk_nha_bh.count loop
    dk_kieu(b_lp):=nvl(trim(dk_kieu(b_lp)),' ');
    if dk_kieu(b_lp)=' ' then b_loi:='loi:Nhap vai tro nha dong:loi'; return; end if;
    dk_nha_bh(b_lp):=nvl(PKH_MA_TENl(dk_nha_bh(b_lp)),' ');
    dk_pt(b_lp):=nvl(dk_pt(b_lp),0); dk_hh(b_lp):=nvl(dk_hh(b_lp),0);
    dk_lh_nv(b_lp):=nvl(PKH_MA_TENl(dk_lh_nv(b_lp)),' ');
end loop;
if FBH_HD_TTRANG(b_ma_dvi,b_so_id)<>'D' then b_loi:='loi:Hop dong chua duyet:loi'; return; end if;
select count(*) into b_i1 from bh_hd_doL where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then
    b_so_id_ps:=b_so_id*10+b_i1;
    insert into bh_hd_do_ps_temp1 select * from bh_hd_do_ps where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_ps<>b_so_id_ps;
end if;
delete bh_hd_doL_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_hl=b_ngay_hl;
delete bh_hd_doL_tl where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_hl=b_ngay_hl;
delete bh_hd_doL where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_hl=b_ngay_hl;
insert into bh_hd_doL select * from bh_hd_do where ma_dvi=b_ma_dvi and so_id=b_so_id;
insert into bh_hd_doL_tl select * from bh_hd_do_tl where ma_dvi=b_ma_dvi and so_id=b_so_id;
insert into bh_hd_doL_txt select * from bh_hd_do_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
PBH_HD_DO_TL_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi,'C');
if b_loi is not null then return; end if;
if b_kieu='V' then
    for b_lp in 1..dk_lh_nv.count loop
        if dk_kieu(b_lp)='V' then
            for b_lp1 in 1..dk_lh_nv.count loop
                if dk_kieu(b_lp1)='D' and dk_so_id_dt(b_lp1)=dk_so_id_dt(b_lp) and dk_lh_nv(b_lp1)=dk_lh_nv(b_lp) then
                    dk_pt(b_lp1):=dk_pt(b_lp1)+dk_pt(b_lp); exit;
                end if;
            end loop;
        end if;
    end loop;
end if;
insert into bh_hd_do values(b_ma_dvi,b_so_id,b_kieu,b_nv,b_ngay_hl,b_nsd);
b_i1:=0;
for b_lp in 1..dk_nha_bh.count loop
    if b_kieu='D' or dk_kieu(b_lp)='D' then
        b_i1:=b_i1+1;
        if b_kieu='V' then dk_pt(b_lp):=100-dk_pt(b_lp); end if;
        insert into bh_hd_do_tl values(b_ma_dvi,b_so_id,dk_so_id_dt(b_lp),dk_nha_bh(b_lp),
            'C',dk_lh_nv(b_lp),dk_pt(b_lp),dk_hh(b_lp),b_ngay_hl);
    end if;
end loop;
if b_i1=0 or (b_kieu='V' and b_i1<>1) then b_loi:='loi:Sai phuong thuc nha dong:loi'; return; end if;
insert into bh_hd_do_txt values(b_ma_dvi,b_so_id,b_ngay_hl,'dt_ct',dt_ct);
insert into bh_hd_do_txt values(b_ma_dvi,b_so_id,b_ngay_hl,'dt_bh',dt_bh);
PBH_HD_GOC_THL_CT(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
if b_kieu='V' then
    PBH_THL_PHI_NBH(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
end if;
PBH_TH_DOps(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
insert into bh_hd_do_ps_temp2 select * from bh_hd_do_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_do_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
insert into bh_hd_do_ps select * from bh_hd_do_ps_temp1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
update bh_hd_do_ps_temp1 set ngay_ht=b_ngay_hl,bt=0,tien=-tien,tien_qd=-tien_qd,thue=-thue,thue_qd=-thue_qd;
insert into bh_hd_do_ps_temp1 select * from bh_hd_do_ps_temp2;
delete bh_hd_do_ps_temp2;
insert into bh_hd_do_ps_temp2 select b_ma_dvi,0,0,so_ct,b_ngay_hl,so_id,so_id_dt,nhom,loai,nv,pthuc,nha_bh,ma_nt,lh_nv,ma_dt,
    sum(tien),sum(thue),sum(tien_qd),sum(thue_qd) from bh_hd_do_ps_temp1
    group by so_ct,so_id,so_id_dt,nhom,loai,nv,pthuc,nha_bh,ma_nt,lh_nv,ma_dt having sum(tien)<>0;
select count(*) into b_i1 from bh_hd_doL where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_so_id_ps:=b_so_id*10+b_i1+1;
update bh_hd_do_ps_temp2 set so_id_ps=b_i1,bt=rownum;
insert into bh_hd_do_ps select * from bh_hd_do_ps_temp2;
PTBH_CBI_NH(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_DO_TL_SUA:loi'; end if;
end;
/



create or replace procedure PTBH_DO_FR_TEST(
    b_ma_dvi varchar2,b_so_id number,b_nv varchar2,dt_ct clob,dt_bh clob,
    b_ngay_ht out number,b_ngay_hl out number,b_ngay_kt out number,
    b_nt_tien out varchar2,b_nt_phi out varchar2,b_so_hd out varchar2,
    nbh_ma out pht_type.a_var,nbh_pt out pht_type.a_num,nbh_hh out pht_type.a_num,
    nbh_kieu out pht_type.a_var,nbh_maC out pht_type.a_var,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_i2 number;
begin
-- Dan - Kiem tra so lieu
b_lenh:=FKH_JS_LENH('ngay_hl');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht using dt_ct;
b_ngay_ht:=nvl(b_ngay_ht,PKH_NG_CSO(sysdate));
b_loi:='loi:Hop dong phai dang trinh, da duyet:loi';
select so_hd,ngay_hl,ngay_kt into b_so_hd,b_ngay_hl,b_ngay_kt
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_lenh:=FKH_JS_LENH('nha_bh,pt,hh,kieu');
EXECUTE IMMEDIATE b_lenh bulk collect into nbh_ma,nbh_pt,nbh_hh,nbh_kieu using dt_bh;
for b_lp in 1..nbh_ma.count loop
    nbh_ma(b_lp):=nvl(PKH_MA_TENl(nbh_ma(b_lp)),' ');
    nbh_kieu(b_lp):=nvl(trim(nbh_kieu(b_lp)),' ');
    if nbh_kieu(b_lp)='V' then nbh_kieu(b_lp):='P'; else nbh_kieu(b_lp):='C'; end if;
    nbh_pt(b_lp):=nvl(nbh_pt(b_lp),0); nbh_hh(b_lp):=nvl(nbh_hh(b_lp),0);
    if nbh_kieu(b_lp)='C' then
        nbh_maC(b_lp):=nbh_ma(b_lp);
    else
        b_i1:=b_lp-1; b_i2:=0;
        for b_lp1 in REVERSE 1..b_i1 loop
            if nbh_kieu(b_lp1)='C' then b_i2:=b_lp1; exit; end if;
        end loop;
        if b_i2=0 then b_loi:='loi:Sai kieu nha bao hiem '||nbh_ma(b_lp)||':loi'; return; end if;
        nbh_maC(b_lp):=nbh_ma(b_i2);
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_DO_FR_TEST:loi'; end if;
end;
/
create or replace procedure PTBH_DO_FR_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nv varchar2,b_oraIn clob,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_kt number; b_so_hd varchar2(20);
    b_ngay_ht number; b_ngay_hl number; b_ngay_kt number; b_so_id_ta number; b_so_idB number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_ma_ta varchar2(10); b_hhong number:=0;
    b_ma_dviH varchar2(10):=FTBH_DVI_TA(); b_tien number; b_phi number; b_tienH number; b_phiH number; 
    
    a_ma_dvi pht_type.a_var; a_so_hd pht_type.a_var;
    a_so_id pht_type.a_num; a_so_id_dt pht_type.a_num; a_so_id_dtX pht_type.a_num; 
    nbh_ma pht_type.a_var; nbh_pt pht_type.a_num; nbh_hh pht_type.a_num;
    nbh_kieu pht_type.a_var; nbh_maC pht_type.a_var; 
    phi_so_id_ta pht_type.a_num; phi_nbh pht_type.a_var; phi_nbhC pht_type.a_var;
    phi_ngay_hl pht_type.a_num; phi_ma_ta pht_type.a_var; phi_pt pht_type.a_num;
    phi_tien pht_type.a_num; phi_phi pht_type.a_num; phi_tl_thue pht_type.a_num;
    phi_thue pht_type.a_num; phi_pt_hh pht_type.a_num; phi_hhong pht_type.a_num;
    phi_pthuc pht_type.a_var; phi_kieu pht_type.a_var;
    
    bh_lh_nv pht_type.a_var; bh_kieu pht_type.a_var; bh_pthuc pht_type.a_var; bh_nbh pht_type.a_var;
    bh_pt pht_type.a_num; bh_hh pht_type.a_num; bh_tien pht_type.a_num; bh_phi pht_type.a_num;
    bh_hhong pht_type.a_num; bh_tl_thue pht_type.a_num; bh_thue pht_type.a_num;

    a_so_id_ta pht_type.a_num; a_so_id_dtC pht_type.a_num;
    dt_ct clob; dt_bh clob;
begin
-- Dan - Nhap
if FBH_HD_TTRANG(b_ma_dvi,b_so_id) in('D','H') then
    b_loi:='loi:Hop dong da duyet hoac da huy:loi'; return;
end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_bh');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_bh using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_bh);
select distinct so_id,so_id_dt BULK COLLECT into a_so_id_ta,a_so_id_dtC
    from tbh_tm_hd where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id;
for b_lp in 1..a_so_id_ta.count loop
    PTBH_TM_NH_XOA_XOA(b_ma_dvi,b_nsd,a_so_id_ta(b_lp),'N',b_loi);
    if b_loi is not null then return; end if;
end loop;
PTBH_DO_FR_TEST(
    b_ma_dvi,b_so_id,b_nv,dt_ct,dt_bh,
    b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_so_hd,
    nbh_ma,nbh_pt,nbh_hh,nbh_kieu,nbh_maC,b_loi);
if b_loi is not null then return; end if;
FBH_HD_DTUONGa(b_nv,b_ma_dvi,b_so_id,a_so_id_dt);
PKH_MANG_KD(phi_nbh);
a_ma_dvi(1):=b_ma_dvi; a_so_id(1):=b_so_id; b_so_idB:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id);
for b_lp in 1..a_so_id_dt.count loop
    FBH_HD_DO_NH_PHId(dt_ct,dt_bh,'F',
        b_ma_dvi,b_so_id,a_so_id_dt(b_lp),b_nv,'D',b_nt_tien,b_nt_phi,b_tien,b_phi,b_tienH,b_phiH,
        bh_lh_nv,bh_kieu,bh_pthuc,bh_nbh,bh_pt,bh_hh,bh_tien,bh_phi,bh_hhong,bh_tl_thue,bh_thue,b_loi);
    if b_loi is not null then return; end if;
    PKH_MANG_XOA(phi_nbh); b_kt:=0;
    for b_lp1 in 1..bh_lh_nv.count loop
        b_i1:=0; b_ma_ta:=nvl(trim(FBH_MA_LHNV_TAI(bh_lh_nv(b_lp1))),' ');
        for b_lp2 in 1..phi_nbh.count loop
            if phi_nbh(b_lp2)=bh_nbh(b_lp1) and phi_ma_ta(b_lp2)=b_ma_ta then
                b_i1:=b_lp2; exit;
            end if;
        end loop;
        if b_i1=0 then
            b_i1:=phi_nbh.count+1;
            phi_nbh(b_i1):=bh_nbh(b_lp1); phi_ma_ta(b_i1):=b_ma_ta;
            phi_tien(b_i1):=0; phi_phi(b_i1):=0; phi_hhong(b_i1):=0; phi_thue(b_i1):=0;
        end if;
        phi_tien(b_i1):=phi_tien(b_i1)+bh_tien(b_lp1); phi_phi(b_i1):=phi_phi(b_i1)+bh_phi(b_lp1);
        phi_hhong(b_i1):=phi_hhong(b_i1)+bh_hhong(b_lp1); phi_thue(b_i1):=phi_thue(b_i1)+bh_thue(b_lp1);
    end loop;
    b_i1:=FKH_ARR_VTRI_N(a_so_id_dtC,a_so_id_dt(b_lp));
    if b_i1<>0 then b_so_id_ta:=a_so_id_ta(b_i1);
    else
        PHT_ID_MOI(b_so_id_ta,b_loi);
        if b_loi is not null then return; end if;
    end if;
    insert into tbh_tm values(b_ma_dviH,b_so_id_ta,b_ngay_ht,b_nv,substr(to_char(b_so_id_ta),3),
        'G',' ',b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,'T','F',b_so_id_ta,0,b_nsd,sysdate);
    b_loi:='loi:Loi Table tbh_tm_hd:loi';
    insert into tbh_tm_hd values(b_ma_dviH,b_so_id_ta,b_ma_dvi,b_so_hd,b_so_id,a_so_id_dt(b_lp),b_so_idB,1);
    b_loi:='loi:Loi Table tbh_tm_nbh:loi';
    for b_lp in 1..nbh_ma.count loop
        insert into tbh_tm_nbh values(b_so_id_ta,nbh_ma(b_lp),nbh_pt(b_lp),nbh_hh(b_lp),nbh_kieu(b_lp),nbh_maC(b_lp),b_lp);  
    end loop;
    b_loi:='loi:Loi Table tbh_tm_phi:loi';
    for b_lp in 1..phi_ma_ta.count loop
        b_i1:=FKH_ARR_VTRI(nbh_ma,phi_nbh(b_lp));
        if b_i1=0 then phi_nbhC(b_lp):='C'; else phi_nbhC(b_lp):=nbh_maC(b_i1); end if;
        phi_so_id_ta(b_lp):=b_so_id; phi_pthuc(b_lp):='F'; phi_kieu(b_lp):='D';
        phi_pt(b_lp):=round(phi_tien(b_lp)*100/b_tienH,2);
        phi_pt_hh(b_lp):=round(phi_hhong(b_lp)*100/phi_phi(b_lp),2);
        if phi_hhong(b_lp)>0 then
            phi_tl_thue(b_lp):=round(phi_thue(b_lp)*100/phi_hhong(b_lp),2);
        else
            phi_tl_thue(b_lp):=0;
        end if;
	-- chuclh: cu ngay_ht
        insert into tbh_tm_phi values(
            b_so_id_ta,b_ngay_hl,phi_nbh(b_lp),phi_nbhC(b_lp),phi_ma_ta(b_lp),phi_pt(b_lp),phi_tien(b_lp),phi_phi(b_lp),
            phi_tl_thue(b_lp),phi_thue(b_lp),phi_pt_hh(b_lp),phi_hhong(b_lp),b_lp);            
        b_hhong:=b_hhong+phi_hhong(b_lp);
        phi_ngay_hl(b_lp):=b_ngay_ht;
    end loop;
    delete tbh_ghep_pbo_temp;
    a_so_id_dtX(1):=a_so_id_dt(b_lp);
    PTBH_GHEP_PBO(b_so_id_ta,b_ngay_ht,b_nt_tien,b_nt_phi,a_ma_dvi,a_so_id,a_so_id_dtX,
        phi_so_id_ta,phi_pthuc,phi_ngay_hl,phi_ma_ta,phi_pt,phi_tien,phi_phi,
        phi_tl_thue,phi_thue,phi_pt_hh,phi_hhong,phi_nbh,phi_kieu,phi_nbhC,b_loi);
    if b_loi is not null then return; end if;
    b_loi:='loi:Loi Table tbh_tm_PBO:loi';
    select count(*) into b_i1 from tbh_ghep_pbo_temp;
    insert into tbh_tm_pbo
        select b_so_id_ta,b_ngay_hl,b_so_id,ma_dvi_hd,so_id_hd,so_id_dt,nha_bh,kieu,nha_bhC,ma_ta,lh_nv,
        b_so_id,pt,nt_tien,tien,nt_phi,phi,hhong,thue,rownum from tbh_ghep_pbo_temp;
    delete tbh_ghep_pbo_temp;
    PTBH_TH_TA_NH(b_ma_dvi,'T',b_so_id_ta,b_loi);
    if b_loi is not null then return; end if;
end loop;
if FKH_JS_GTRIs(dt_ct,'tiep')='C' then
    PTBH_CBI(a_ma_dvi,a_so_id,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_DO_FR_NH:loi'; end if;
end;
/
create or replace procedure FBH_HD_DO_NH_PHIt(
    b_nv varchar2,b_nt_tien varchar2,b_nt_phi varchar2,
    dk_lh_nv pht_type.a_var,dk_tien pht_type.a_num,dk_phi pht_type.a_num,
    bh_lh_nv pht_type.a_var,bh_kieu pht_type.a_var,
    bh_nbh pht_type.a_var,bh_pt pht_type.a_num,bh_hh pht_type.a_num,
    bh_tien out pht_type.a_num,bh_phi out pht_type.a_num,bh_hhong out pht_type.a_num,
    bh_tl_thue out pht_type.a_num,bh_thue out pht_type.a_num,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_i2 number; b_i3 number;
    b_ngay number:=PKH_NG_CSO(sysdate); b_tpT number:=0; b_tpP number:=0;
begin
-- Dan - Tra ghep nghiep vu BH => nghiep vu tai
b_loi:='loi:Loi xu ly FBH_HD_DO_NH_PHIt:loi';
if b_nt_tien<>'VND' then b_tpT:=2; end if;
if b_nt_phi<>'VND' then b_tpP:=2; end if;
for b_lp in 1..bh_lh_nv.count loop
    bh_tien(b_lp):=0; bh_phi(b_lp):=0; bh_hhong(b_lp):=0; bh_tl_thue(b_lp):=0; bh_thue(b_lp):=0;
    for b_lp1 in 1..dk_lh_nv.count loop
        if bh_lh_nv(b_lp) in(' ',dk_lh_nv(b_lp1)) then
            bh_tien(b_lp):=bh_tien(b_lp)+round(dk_tien(b_lp1)*bh_pt(b_lp)/100,b_tpT);
            b_i1:=round(dk_phi(b_lp1)*bh_pt(b_lp)/100,b_tpP);
            b_i2:=round(b_i1*bh_hh(b_lp)/100,b_tpP);
            bh_phi(b_lp):=bh_phi(b_lp)+b_i1;
            bh_hhong(b_lp):=bh_hhong(b_lp)+b_i2;
            b_i1:=b_i1; --Nam: b_i1:=b_i1-b_i2 => khong tru hhong;
            PTBH_PBO_NOP(dk_lh_nv(b_lp1),bh_nbh(b_lp),b_ngay,b_i1,b_tpP,b_i2,b_i3,b_loi,'G'); --Nam: truyen b_dk='G';
            bh_thue(b_lp):=bh_thue(b_lp)+b_i3;
        end if;
    end loop;
    b_i1:=bh_phi(b_lp)-bh_hhong(b_lp);
    if b_i1<>0 and bh_thue(b_lp)<>0 then bh_tl_thue(b_lp):=round(bh_thue(b_lp)*100/b_i1,2); end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_HD_DO_NH_PHIt:loi'; end if;
end;
/
