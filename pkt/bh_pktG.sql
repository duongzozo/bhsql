create or replace procedure PBH_PKTG_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_ngay number:=PKH_NG_CSO(sysdate);
    cs_sp clob; cs_khd clob; cs_kbt clob; cs_ttt clob;
begin
-- Dan - Tham so mo form
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten) into cs_sp from
    bh_pkt_sp a,(select distinct ma_sp from bh_pkt_phi where nhom in('G') and ngay_bd<=b_ngay and ngay_kt>b_ngay) b
    where a.ma=b.ma_sp and FBH_PKT_SP_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_khd
    from bh_kh_ttt where ps='KHD' and nv='PKT';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_kbt
    from bh_kh_ttt where ps='KBT' and nv='PKT';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_ttt
    from bh_kh_ttt where ps='HD' and nv='PKT';
select json_object('cs_sp' value cs_sp,'cs_khd' value cs_khd,'cs_kbt' value cs_kbt,
       'cs_ttt' value cs_ttt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_PKTG_KHO(
    b_ngay_hl number,b_ngay_kt number,b_kho out number,b_loi out varchar2,b_dk varchar2:='K')
AS
    b_i1 number; b_tltg number;
begin
-- Dan - Tinh he so phi
b_loi:='loi:Loi xu ly FBH_PKTG_KHO:loi';
if substr(to_char(b_ngay_hl), 5)=substr(to_char(b_ngay_kt), 5) then b_kho:=FKH_KHO_NASO(b_ngay_hl,b_ngay_kt);
else
  b_kho:=FKH_KHO_NGSO(b_ngay_hl,b_ngay_kt)+1;
  select count(*) into b_i1 from bh_phh_tltg;
  if b_kho<365 and b_i1<>0 and b_dk<>'C' then
      b_kho:=FKH_KHO_THSO(b_ngay_hl,b_ngay_kt);
      select count(*),nvl(min(tltg),0) into b_i1,b_tltg from bh_phh_tltg
          where tltg>b_kho and b_ngay_hl between ngay_bd and ngay_kt;
      if b_i1=0 then b_kho:=1;
      else
          select tlph into b_kho from bh_phh_tltg where tltg=b_tltg and b_ngay_hl between ngay_bd and ngay_kt;
          b_kho:=b_kho/100;
      end if;
  elsif b_kho<365 or b_kho>366 then
      b_kho:=b_kho/365;
  else b_kho:=1;
  end if;
end if;
b_loi:='';
end;
/
create or replace procedure FBH_PKTG_PHIb(b_tp number,
    dk_ma pht_type.a_var,dk_ma_ct pht_type.a_var,dk_lkeP pht_type.a_var,dk_cap pht_type.a_num,
    dk_phi in out pht_type.a_num,dk_thue in out pht_type.a_num,dk_ttoan out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_cap number:=1; b_phi number; b_thue number;
begin
-- Dan - Tinh bac cao
b_loi:='loi:Loi xu ly FBH_PKTG_PHIb:loi';
for b_lp in 1..dk_ma.count loop
    if dk_cap(b_lp)>b_cap then b_cap:=dk_cap(b_lp); end if;
    if dk_lkeP(b_lp) in('T','N') then dk_phi(b_lp):=0; dk_thue(b_lp):=0; end if;
end loop;
b_cap:=b_cap-1;
while b_cap>0 loop
    for b_lp in 1..dk_ma.count loop
        if dk_cap(b_lp)<>b_cap then continue; end if;
        if dk_lkeP(b_lp)='T' then
            b_phi:=0; b_thue:=0;
            for b_lp1 in 1..dk_ma.count loop
                if dk_ma_ct(b_lp1)=dk_ma(b_lp) then
                    b_phi:=b_phi+dk_phi(b_lp1); b_thue:=b_thue+dk_thue(b_lp1);
                end if;
            end loop;
            dk_phi(b_lp):=b_phi; dk_thue(b_lp):=b_thue; dk_ttoan(b_lp):=b_phi+b_thue;
        elsif dk_lkeP(b_lp)='N' then
            b_i1:=0;
            for b_lp1 in 1..dk_ma.count loop
                if dk_ma_ct(b_lp1)=dk_ma(b_lp) then
                    if b_i1=0 then
                        b_i1:=1; b_phi:=dk_phi(b_lp1); b_thue:=dk_thue(b_lp1);
                    else
                        b_phi:=ROUND(b_phi*dk_phi(b_lp1),b_tp); b_thue:=ROUND(b_thue*dk_thue(b_lp1),b_tp);
                    end if;
                end if;
            end loop;
            dk_phi(b_lp):=b_phi; dk_thue(b_lp):=b_thue;
        end if;
    end loop;
    b_cap:=b_cap-1;
end loop;
for b_lp in 1..dk_ma.count loop
    dk_ttoan(b_lp):=dk_phi(b_lp)+dk_thue(b_lp);
end loop;
b_loi:='';
end;
/
create or replace procedure FBH_PKTG_PHI(
    b_ma_dvi varchar2,dt_ct clob,dt_dk clob,dt_dkbs clob,dt_pvi clob,
    b_so_idP out number,
    a_ma out pht_type.a_var,a_ten out pht_type.a_nvar,a_tc out pht_type.a_var,
    a_ma_ct out pht_type.a_var,a_kieu out pht_type.a_var,
    a_lkeM out pht_type.a_var,a_lkeP out pht_type.a_var,a_lkeB out pht_type.a_var,
    a_luy out pht_type.a_var,a_ktru out pht_type.a_var,
    a_ma_dk out pht_type.a_var,a_ma_dkC out pht_type.a_var,a_lh_nv out pht_type.a_var,a_t_suat out pht_type.a_num,
    a_cap out pht_type.a_num,a_lbh out pht_type.a_var,a_nv out pht_type.a_var,
    a_tien out pht_type.a_num,a_pt out pht_type.a_num,a_phi out pht_type.a_num,
    a_thue out pht_type.a_num,a_ttoan out pht_type.a_num,
    a_ptB out pht_type.a_num,a_phiB out pht_type.a_num,
    a_pvi_ma out pht_type.a_var,a_pvi_tc out pht_type.a_var,a_pvi_ktru out pht_type.a_var,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_i1 number; b_i2 number; b_iX number; b_hs number; b_kt number:=0; b_ktL number:=0;
    b_nhom varchar2(1); b_ma_sp varchar2(10); b_ma_nct varchar2(500); b_tg number:=1;
    b_rru varchar2(1); b_ma_ntb nvarchar2(500);
    b_kieu_hd varchar2(1); b_so_hdG varchar2(20); b_so_idD number; b_so_idG number:=0; b_so_idPn number; 
    b_ngay_hl number; b_ngay_kt number; b_ngay_cap number; b_ktru nvarchar2(500);
    b_capD number; b_capC number; b_kho number; b_c_thue varchar2(1);
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tygia number; b_tp number:=0; b_tien number;
    b_pvi_ptTS number:=0; b_pvi_ptTSb number:=0; b_pvi_ptTSc number:=0;
    b_pvi_ptKH number:=0; b_pvi_ptKHb number:=0; b_pvi_ptKHc number:=0;
    b_ptTS number:=0; b_ptKH number:=0; b_pt number:=0; b_dk varchar2(1);
    
    a_ptC pht_type.a_num; a_phiX pht_type.a_num; a_pp pht_type.a_var;
    a_so_idG pht_type.a_num; dk_maG pht_type.a_var; dk_phiG pht_type.a_num; dk_phiB pht_type.a_num;
    a_ngay_hlG pht_type.a_num; a_ngay_ktG pht_type.a_num; a_ngay_capG pht_type.a_num;
    dk_ma pht_type.a_var; dk_tien pht_type.a_num; dk_pt pht_type.a_num; dk_phi pht_type.a_num;
    pvi_ma pht_type.a_var; pvi_tc pht_type.a_var; pvi_ten pht_type.a_var;
    pvi_ptTS pht_type.a_num; pvi_ptKH pht_type.a_num; pvi_ktru pht_type.a_var;
    pvi_loai pht_type.a_var; pvi_ma_ct pht_type.a_var;
    pvi_ptTSb pht_type.a_num; pvi_ptKHb pht_type.a_num;
    pvi_ppTS pht_type.a_var; pvi_ppKH pht_type.a_var;
    pvi_ptkTS pht_type.a_var; pvi_ptkKH pht_type.a_var;
    pvi_ptTSc pht_type.a_num; pvi_ptKHc pht_type.a_num;

    bs_ma pht_type.a_var; bs_tien pht_type.a_num; bs_ptB pht_type.a_num;
    bs_pp pht_type.a_var; bs_pt pht_type.a_num; bs_ptK pht_type.a_var;

begin
-- Dan - Tinh phi
b_lenh:=FKH_JS_LENH('kieu_hd,so_hd_g,ngay_kt,ngay_cap,nt_tien,nt_phi,tygia,c_thue,so_idp');
EXECUTE IMMEDIATE b_lenh into b_kieu_hd,b_so_hdG,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,b_tygia,b_c_thue,b_so_idPn using dt_ct;
PBH_PKT_BPHI_TSO(dt_ct,b_nhom,b_ma_sp,b_ma_nct,b_rru,b_ma_ntb,b_ngay_hl);
b_so_idP:=FBH_PKT_BPHI_SO_ID(b_nhom,b_ma_sp,b_ma_nct,b_rru,b_ma_ntb,b_ngay_hl);
if b_so_idP=0 then b_loi:='loi:Khong tim duoc bieu phi:loi'; return; end if;
if b_so_idP<>b_so_idPn then
    b_loi:='loi:Thong tin xac dinh bieu phi bi thay doi:loi'; return;
end if;
if b_kieu_hd in('B','S') and b_so_hdG<>' ' and b_ngay_hl<b_ngay_cap then
    b_dk:='C';
    b_so_idG:=FBH_PKT_SO_ID(b_ma_dvi,b_so_hdG);
    if b_so_idG=0 then b_loi:='loi:GCN goc da xoa:loi'; return; end if;
end if;
if b_tygia is null or b_tygia=0 then b_tygia:=1; end if;
if b_nt_phi<>'VND' then b_tp:=2; end if;
b_lenh:=FKH_JS_LENH('ma,tien,pt,phi');
EXECUTE IMMEDIATE b_lenh bulk collect into dk_ma,dk_tien,dk_pt,dk_phi using dt_dk;
if dk_ma.count=0 then b_loi:='loi:Nhap so tien bao hiem:loi'; return; end if;
b_lenh:=FKH_JS_LENH('ma,ten,pttsb,ppts,ptts,ptkhb,ppkh,ptkh,ktru,tc,loai,ma_ct,ptkts,ptkkh');
EXECUTE IMMEDIATE b_lenh bulk collect into pvi_ma,pvi_ten,pvi_ptTSb,pvi_ppTS,pvi_ptTS,
                  pvi_ptKHb,pvi_ppKH,pvi_ptKH,pvi_ktru,pvi_tc,pvi_loai,pvi_ma_ct,pvi_ptkTS,pvi_ptkKH using dt_pvi;
if pvi_ma.count=0 then b_loi:='loi:Nhap pham vi bao hiem:loi'; return; end if;
b_lenh:=FKH_JS_LENH('ma,tien,ptb,pp,pt,ptk');
EXECUTE IMMEDIATE b_lenh bulk collect into bs_ma,bs_tien,bs_ptB,bs_pp,bs_pt,bs_ptK using dt_dkbs;
for b_lp in 1..pvi_ma.count loop
    pvi_tc(b_lp):=nvl(trim(pvi_tc(b_lp)),'C');
    pvi_ppTS(b_lp):=nvl(trim(pvi_ppTS(b_lp)),'GP');
    pvi_ppKH(b_lp):=nvl(trim(pvi_ppKH(b_lp)),'GP');
end loop;
for b_lp in 1..pvi_ma.count loop
    if pvi_tc(b_lp)='C' then
        for b_lp1 in 1..pvi_ma.count loop
            if pvi_ma(b_lp1)=pvi_ma_ct(b_lp) then pvi_ten(b_lp):='- '||pvi_ten(b_lp); exit; end if;
        end loop;
    end if;
end loop;
for b_lp in 1..pvi_ma.count loop
    pvi_ptTSc(b_lp):=0; pvi_ptKHc(b_lp):=0;
end loop;
for b_lp in 1..pvi_ma.count loop
    b_pvi_ptTSc:=b_pvi_ptTSc+pvi_ptTSc(b_lp);
    b_pvi_ptKHc:=b_pvi_ptKHc+pvi_ptKHc(b_lp);
end loop;
if F_KTRA_KTRU(pvi_ktru,b_loi) <> 'C' then b_loi:='loi:Pham vi khau tru sai dinh dang:loi'; end if;
if b_loi is not null then return; end if;
b_ktru:=FBH_BT_KTRUs(pvi_ktru);
if b_nt_tien<>'VND' and b_nt_phi='VND' and b_tygia<>0 then
    b_tg:=b_tg*b_tygia;
elsif b_nt_tien='VND' and b_nt_phi<>'VND' and b_tygia<>0 then
    b_tg:=b_tg/b_tygia;
end if;
--nam: check sua doi bo sung khong tinh theo phi ngan han
FBH_PKTG_KHO(b_ngay_hl,b_ngay_kt,b_kho,b_loi,b_dk);
if b_loi is not null then return; end if;
b_kt:=0;
for b_lp_dk in 1..dk_ma.count loop
    select count(*) into b_i1 from bh_pkt_phi_dk where so_id=b_so_idP and ma=dk_ma(b_lp_dk);
    if b_i1<>1 then b_loi:='loi:Sai bieu phi dieu khoan '||b_so_idP||':'||dk_ma(b_lp_dk)||':loi'; return; end if;
    b_kt:=b_kt+1; b_ktL:=b_kt;
    select ma,ten,tc,ma_ct,'T',lkeM,lkeP,lkeB,luy,ktru,ma_dk,lh_nv,t_suat,cap,lbh,nv into
        a_ma(b_kt),a_ten(b_kt),a_tc(b_kt),a_ma_ct(b_kt),a_kieu(b_kt),
        a_lkeM(b_kt),a_lkeP(b_kt),a_lkeB(b_kt),a_luy(b_kt),a_ktru(b_kt),
        a_ma_dk(b_kt),a_lh_nv(b_kt),a_t_suat(b_kt),a_cap(b_kt),a_lbh(b_kt),a_nv(b_kt)
        from bh_pkt_phi_dk where so_id=b_so_idP and ma=dk_ma(b_lp_dk) and nv='C';
    a_tien(b_kt):=dk_tien(b_lp_dk); a_pt(b_kt):=0; a_phi(b_kt):=0; a_pp(b_kt):=' ';
    a_ma_dkC(b_kt):=' '; a_ptB(b_kt):=0; a_phiB(b_kt):=0; a_pvi_ma(b_kt):=' '; a_pvi_tc(b_kt):=' ';
    if a_ktru(b_kt)<>'P' then a_pvi_ktru(b_kt):=' '; else a_pvi_ktru(b_kt):=b_ktru; end if;
    if a_lkeP(b_kt)='D' then b_kho:=1; end if;
    if a_tc(b_kt)='C' then
        for b_lp_pvi in 1..pvi_ma.count loop
            b_kt:=b_kt+1;
            a_ma(b_kt):=a_ma(b_ktL)||'>'||pvi_ma(b_lp_pvi); a_kieu(b_kt):=a_kieu(b_ktL);
            a_ten(b_kt):='- '||pvi_ten(b_lp_pvi);
            a_tc(b_kt):='C';
            a_ma_ct(b_kt):=a_ma(b_ktL);
            a_lkeM(b_kt):=a_lkeM(b_ktL); a_lkeP(b_kt):=a_lkeP(b_ktL);
            if a_lkeP(b_ktL) not in ('G','T','N') then a_lkeP(b_kt):='K'; else a_lkeP(b_kt):=a_lkeP(b_ktL); end if;
            a_lkeB(b_kt):=a_lkeB(b_ktL); a_luy(b_kt):=a_luy(b_ktL); a_ktru(b_kt):=a_ktru(b_ktL);
            a_tien(b_kt):=0; a_ma_dk(b_kt):=a_ma_dk(b_ktL); a_ma_dkC(b_kt):=a_ma_dk(b_ktL); a_lh_nv(b_kt):=' ';
            a_t_suat(b_kt):=a_t_suat(b_ktL); a_cap(b_kt):=a_cap(b_ktL)+1; a_lbh(b_kt):=a_lbh(b_ktL); a_nv(b_kt):=a_nv(b_ktL);
            b_tien:=a_tien(b_ktL);
            if b_tien=0 and a_lkeM(b_ktL)='B' then
                b_i1:=FKH_ARR_VTRI(a_ma,a_ma_ct(b_ktL));
                if b_i1<>0 then b_tien:=a_tien(b_i1); end if;
            end if;
            if a_lkeP(b_kt)='K' then
                 a_pt(b_kt):=0; a_phi(b_kt):=0; a_ptB(b_kt):=0; a_phiB(b_kt):=0; a_ptC(b_kt):=0; a_pp(b_kt):=' ';
            else
                if a_lbh(b_kt) in('TS','TB') then
                    a_pt(b_kt):=pvi_ptTS(b_lp_pvi); a_ptB(b_kt):=pvi_ptTSb(b_lp_pvi);
                    a_ptC(b_kt):=pvi_ptTSc(b_lp_pvi); a_pp(b_kt):=pvi_ppTS(b_lp_pvi);
                elsif (a_lbh(b_kt)='BI' and pvi_loai(b_lp_pvi)='D') or (a_lbh(b_kt)='KH' and pvi_loai(b_lp_pvi)='M')then
                    a_pt(b_kt):=pvi_ptKH(b_lp_pvi); a_ptB(b_kt):=pvi_ptKHb(b_lp_pvi);
                    a_ptC(b_kt):=pvi_ptKHc(b_lp_pvi); a_pp(b_kt):=pvi_ppKH(b_lp_pvi);
                else
                    a_pt(b_kt):=0; a_ptB(b_kt):=0;
                    a_ptC(b_kt):=0; a_pp(b_kt):=' ';
                end if;
                if a_ptB(b_kt) < 100 then
                    b_pt:=FBH_PKT_PHIPP(a_pp(b_kt), a_pt(b_kt), a_ptB(b_kt), b_tien);
                    a_pt(b_kt):=b_pt;
                    a_phi(b_kt):=ROUND(b_kho*b_tg*b_tien*a_pt(b_kt)/100, b_tp);
                    a_phiB(b_kt):=ROUND(b_kho*b_tg*b_tien*a_ptB(b_kt)/100, b_tp);
                else
                    if a_pp(b_kt) = 'DG' then b_pt:=a_pt(b_kt);
                    elsif a_pp(b_kt) = 'DP' then b_pt:=ROUND(a_pt(b_kt)*b_tien/100,20);
                    elsif a_pp(b_kt) = 'GG' and b_tien<>0 then b_pt:=a_ptB(b_kt)-a_pt(b_kt);
                    elsif a_pp(b_kt) = 'GT' then b_pt:= a_ptB(b_kt);
                    elsif a_pp(b_kt) = 'GP' then b_pt:=a_ptB(b_kt) - ROUND(a_pt(b_kt)*a_ptB(b_kt)/100,20);
                    else b_pt:=a_ptB(b_kt);
                    end if;
                    a_pt(b_kt):=b_pt;
                    a_phiB(b_kt):=a_pt(b_kt);
                    a_phi(b_kt):=ROUND(b_kho*b_tg*a_pt(b_kt), b_tp);
                    a_phiB(b_kt):=ROUND(b_kho*b_tg*a_phiB(b_kt), b_tp);
                end if;
                if a_phi(b_kt)<0 then a_phi(b_kt):=0; end if;
                if a_phiB(b_kt)=0 then a_phiB(b_kt):=a_phi(b_kt); end if;
            end if;
            a_pvi_ma(b_kt):=pvi_ma(b_lp_pvi); a_pvi_tc(b_kt):=pvi_tc(b_lp_pvi); a_pvi_ktru(b_kt):=pvi_ktru(b_lp_pvi);
        end loop;
        a_tc(b_ktL):='T'; a_lkeP(b_ktL):='T'; a_lkeB(b_ktL):='T';
    elsif a_lkeP(b_kt) in ('G','D') and a_tien(b_kt)<>0 then
        b_tien:=a_tien(b_kt);
        for b_lp_pvi in 1..pvi_ma.count loop
          if a_lbh(b_kt) in('TS','TB') then
              a_pp(b_lp_pvi):=pvi_ppTS(b_lp_pvi);
              b_ptTS:=FBH_PKT_PHIPP(a_pp(b_lp_pvi), pvi_ptTS(b_lp_pvi), pvi_ptTSb(b_lp_pvi), b_tien);
              b_pvi_ptTS:=b_pvi_ptTS+b_ptTS;
              b_pvi_ptTSb:=b_pvi_ptTSb+pvi_ptTSb(b_lp_pvi);
              a_pt(b_kt):=b_pvi_ptTS; a_ptB(b_kt):=b_pvi_ptTSb;
          elsif (a_lbh(b_kt)='BI' and pvi_loai(b_lp_pvi)='D') or (a_lbh(b_kt)='KH' and pvi_loai(b_lp_pvi)='M')then
              a_pp(b_lp_pvi):=pvi_ppKH(b_lp_pvi);
              b_ptKH:=FBH_PKT_PHIPP(a_pp(b_lp_pvi), pvi_ptKH(b_lp_pvi), pvi_ptKHb(b_lp_pvi), b_tien);
              b_pvi_ptKH:=b_pvi_ptKH+b_ptKH;
              b_pvi_ptKHb:=b_pvi_ptKHb+pvi_ptKHb(b_lp_pvi);
              a_pt(b_kt):=b_pvi_ptKH; a_ptB(b_kt):=b_pvi_ptKHb;
          else
              a_pp(b_lp_pvi):=' '; a_pt(b_kt):=0; a_ptB(b_kt):=0;
          end if;
          if b_tien<>0 and a_pp(b_kt)='DG' then
            a_phi(b_kt):=ROUND(b_tien*a_pt(b_kt)/ 100, b_tp);
          elsif b_tien<>0 then
             a_phi(b_kt):=ROUND(b_kho*b_tg*b_tien*a_pt(b_kt)/ 100, b_tp);
          else
            a_phi(b_kt):=0;
          end if;
          if a_phi(b_kt)<0 then a_phi(b_kt):=0; end if;
          if a_ptB(b_kt)>100 then a_phiB(b_kt):=ROUND(a_ptB(b_kt)*b_kho*b_tg,b_tp);
          elsif b_tien<>0 and a_ptB(b_kt)<>0 then a_phiB(b_kt):=ROUND(b_kho*b_tg*b_tien*a_ptB(b_kt)/ 100, b_tp);
          else a_phiB(b_kt):=0;
          end if;
          if a_phiB(b_kt)=0 then a_phiB(b_kt):=a_phi(b_kt); end if;
        end loop;
    end if;
end loop;
for b_lp_bs in 1..bs_ma.count loop
    b_kt:=b_kt+1; b_ktL:=b_kt;
    a_nv(b_kt):='M'; a_tien(b_kt):=bs_tien(b_lp_bs);
    select count(*) into b_i1 from bh_pkt_phi_dk where so_id=b_so_idP and ma=bs_ma(b_lp_bs) and nv='M';
    if b_i1=1 then
        select ma,ten,tc,ma_ct,'T',lkeM,lkeP,lkeB,luy,ktru,ma_dk,ma_dkC,lh_nv,t_suat,cap,lbh into
            a_ma(b_kt),a_ten(b_kt),a_tc(b_kt),a_ma_ct(b_kt),a_kieu(b_kt),
            a_lkeM(b_kt),a_lkeP(b_kt),a_lkeB(b_kt),a_luy(b_kt),a_ktru(b_kt),
            a_ma_dk(b_kt),a_ma_dkC(b_kt),a_lh_nv(b_kt),a_t_suat(b_kt),a_cap(b_kt),a_lbh(b_kt)
            from bh_pkt_phi_dk where so_id=b_so_idP and ma=bs_ma(b_lp_bs);
        if a_tien(b_kt)=0 and nvl(a_lkeM(b_kt),' ')='C' then
            b_i1:=FKH_ARR_VTRI(a_ma_dk,a_ma_dkC(b_kt));
            if b_i1>0 then a_tien(b_kt):=a_tien(b_i1); end if;
        end if;
    else
        select count(*) into b_i1 from bh_ma_dkbs where ma=bs_ma(b_lp_bs) and FBH_MA_NV_CO(nv,'PKT')='C';
        if b_i1<>1 then b_loi:='loi:Sai dieu khoan bo sung '||bs_ma(b_lp_bs)||':loi'; return; end if;
        select ma,ten,lh_nv,ma_dk into a_ma(b_kt),a_ten(b_kt),a_lh_nv(b_kt),a_ma_dkC(b_kt) from bh_ma_dkbs where ma=bs_ma(b_lp_bs);
        if trim(a_lh_nv(b_kt)) is not null then
            a_t_suat(b_kt):=FBH_MA_LHNV_THUE(a_lh_nv(b_kt));
        else
            if bs_tien(b_lp_bs)<>0 then
                b_loi:='loi:Dieu khoan bo sung '||bs_ma(b_lp_bs)||' khong co loai hinh nghiep vu:loi'; return;
            end if;
            a_t_suat(b_kt):=0;
        end if;
        a_tc(b_kt):='C'; a_ma_ct(b_kt):=' '; a_kieu(b_kt):='T';
        a_lkeM(b_kt):='K'; a_lkeP(b_kt):='K'; a_lkeB(b_kt):='K'; a_luy(b_kt):='K'; a_ktru(b_kt):=' ';
        a_ma_dk(b_kt):=' '; a_cap(b_kt):=0; a_lbh(b_kt):=' ';
    end if;
    a_pvi_ma(b_kt):=' '; a_pvi_tc(b_kt):=' '; a_pp(b_kt):=bs_pp(b_lp_bs);
    if a_ktru(b_kt)<>'P' then a_pvi_ktru(b_kt):=' '; else a_pvi_ktru(b_kt):=b_ktru; end if;
    if a_pp(b_kt) in('DP','DG') then
       bs_pt(b_lp_bs):=bs_pt(b_lp_bs);
    elsif a_pp(b_kt)='GP' and bs_pt(b_lp_bs)<>0 then
       bs_pt(b_lp_bs):=bs_ptB(b_lp_bs)-ROUND(bs_ptB(b_lp_bs)*bs_pt(b_lp_bs)/100,20);
    elsif a_pp(b_kt)='GT' then
       bs_pt(b_lp_bs):=bs_ptB(b_lp_bs)-bs_pt(b_lp_bs);
    else
       bs_pt(b_lp_bs):=bs_ptB(b_lp_bs);
    end if;
    a_ptB(b_kt):=bs_ptB(b_lp_bs); a_pt(b_kt):=bs_pt(b_lp_bs);
    b_tien:=a_tien(b_kt); a_ptC(b_kt):=0;
    if (a_ptB(b_kt)<100 and abs(a_pt(b_kt))< 100) or (a_ptB(b_kt)>100 and abs(a_pt(b_kt))>100) then
        a_pt(b_kt):=a_ptB(b_kt)-a_pt(b_kt);
    elsif a_ptB(b_kt)>100 then
        a_pt(b_kt):=ROUND(a_ptB(b_kt)*a_pt(b_kt)/100,20);
    else
        a_ptC(b_kt):=a_pt(b_kt); a_pt(b_kt):=a_ptB(b_kt);
    end if;
    if a_pt(b_kt)>100 then a_phi(b_kt):=ROUND(a_pt(b_kt)*b_kho*b_tg,b_tp);
    elsif b_tien<>0 and a_pt(b_kt)<>0 then a_phi(b_kt):=ROUND(b_kho*b_tg*b_tien*a_pt(b_kt)/ 100, b_tp);
    else a_phi(b_kt):=0;
    end if;
    a_phi(b_kt):=a_phi(b_kt)-a_ptC(b_kt);
    if a_phi(b_kt)<0 then a_phi(b_kt):=0; end if;
    if a_ptB(b_kt)>100 then a_phiB(b_kt):=ROUND(a_ptB(b_kt)*b_kho*b_tg,b_tp);
    elsif b_tien<>0 and a_ptB(b_kt)<>0 then a_phiB(b_kt):=ROUND(b_kho*b_tg*b_tien*a_ptB(b_kt)/ 100, b_tp);
    else a_phiB(b_kt):=0;
    end if;
    if a_phiB(b_kt)=0 then a_phiB(b_kt):=a_phi(b_kt); end if;
end loop;
for b_lp in 1..a_ma.count loop
    if a_lkeM(b_lp) not in ('T','N','K') and a_tien(b_lp)=0 and a_kieu(b_lp) ='T' and instr(a_ma(b_lp),'>')=0 then
       b_loi:='loi:Chua nhap muc trach nhiem dieu khoan '||a_ma(b_lp)||':loi'; return; 
    end if;
end loop;
for b_lp in 1..dk_ma.count loop
    if dk_phi(b_lp)=0 then continue; end if;
    b_i1:=0; b_iX:=0;
    for b_lp1 in 1..a_ma.count loop
        if (a_lkeP(b_lp1)='G' and a_ma(b_lp1)=dk_ma(b_lp)) or (a_tc(b_lp1)='C' and instr(a_ma(b_lp1),'>')>0 and instr(a_ma(b_lp1),dk_ma(b_lp))=1) then
            b_i1:=b_i1+a_phi(b_lp1);
            if b_iX=0 or a_phi(b_lp1)>a_phi(b_iX) then b_iX:=b_lp1; end if;
        end if;
    end loop;
    if b_i1 in(0,dk_phi(b_lp)) then continue; end if;
    b_i2:=dk_phi(b_lp)/b_i1; b_i1:=dk_phi(b_lp);
    for b_lp1 in 1..a_ma.count loop
        if (a_lkeP(b_lp1)='G' and a_ma(b_lp1)=dk_ma(b_lp)) or (a_tc(b_lp1)='C' and instr(a_ma(b_lp1),'>')>0 and instr(a_ma(b_lp1),dk_ma(b_lp))=1) then
            a_phi(b_lp1):=round(a_phi(b_lp1)*b_i2,b_tp);
            a_pt(b_lp1):=dk_pt(b_lp); b_i1:=b_i1-a_phi(b_lp1);
        end if;
    end loop;
    if b_i1<>0 then a_phi(b_iX):=a_phi(b_iX)+b_i1; end if;
end loop;
-- Co SDBS
if b_so_idG<>0 then
    b_so_idD:=FBH_PKT_SO_IDd(b_ma_dvi,b_so_idG);
    select so_id,ngay_hl,ngay_kt,ngay_cap bulk collect into a_so_idG,a_ngay_hlG,a_ngay_ktG,a_ngay_capG from bh_pkt where
        ma_dvi=b_ma_dvi and so_id_d=b_so_idD and so_id<=b_so_idG and ngay_hl<b_ngay_cap order by so_id;
    if a_so_idG.count<>0 then
        b_hs:=(1+FKH_KHO_NGSO(b_ngay_cap,b_ngay_kt,'K'))/FKH_KHO_NGSO(b_ngay_hl,b_ngay_kt);
        for b_lp in 1..a_ma.count loop
            a_phi(b_lp):=round(a_phi(b_lp)*b_hs,b_tp); a_phiX(b_lp):=0;
            a_phiB(b_lp):=round(a_phiB(b_lp)*b_hs,b_tp);
        end loop;
        PKH_ARR_XEP_N(a_so_idG);
        for b_lpG in 1..a_so_idG.count loop
            if b_lpG=1 then b_capD:=a_ngay_hlG(b_lpG); else b_capD:=a_ngay_capG(b_lpG); end if;
            if b_lpG=a_so_idG.count then b_capC:=b_ngay_cap; else b_capC:=a_ngay_capG(b_lpG+1); end if;
            b_hs:=FKH_KHO_NGSO(b_capD,b_capC)/FKH_KHO_NGSO(b_capD,a_ngay_ktG(b_lpG));
            select ma,phi,phiB bulk collect into dk_maG,dk_phiG,dk_phiB from bh_pkt_dk where
                --nampb: ma_dvi=b_ma_dvi and so_id=a_so_idG(b_lpG) and tc='C';
                ma_dvi=b_ma_dvi and so_id=a_so_idG(b_lpG);
            for b_lp in 1..dk_maG.count loop
                b_i1:=FKH_ARR_VTRI(a_ma,dk_maG(b_lp));
                if b_i1<>0 then
                    b_i2:=dk_phiG(b_lp)-a_phiX(b_i1);
                    a_phiX(b_i1):=a_phiX(b_i1)+round(b_i2*b_hs,b_tp);
                    b_i2:=dk_phiB(b_lp)-a_phiX(b_i1);
                    a_phiB(b_i1):=a_phiB(b_i1)+round(b_i2*b_hs,b_tp);
                end if;
            end loop;
        end loop;
        for b_lp in 1..a_ma.count loop
            a_phi(b_lp):=a_phi(b_lp)+a_phiX(b_lp);
        end loop;
    end if;
end if;
if b_c_thue<>'C' then
    for b_lp in 1..a_ma.count loop a_thue(b_lp):=0; end loop;
else
    for b_lp in 1..a_ma.count loop a_thue(b_lp):=round(a_phi(b_lp)*a_t_suat(b_lp)/100,b_tp); end loop;
end if;
FBH_PKTG_PHIb(b_tp,a_ma,a_ma_ct,a_lkeP,a_cap,a_phi,a_thue,a_ttoan,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_PKTG_PHI:loi'; end if;
end;
/
create or replace procedure PBH_PKTG_PHI (
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(3000); b_lenh varchar2(2000); b_txt clob;
    dt_ct clob; dt_dk clob; dt_dkbs clob; dt_pvi clob;
    b_so_idP number;
    a_ma pht_type.a_var; a_ten pht_type.a_nvar; a_tc pht_type.a_var;
    a_ma_ct pht_type.a_var; a_kieu pht_type.a_var;
    a_lkeM pht_type.a_var; a_lkeP pht_type.a_var; a_lkeB pht_type.a_var; a_luy pht_type.a_var; a_ktru pht_type.a_var;
    a_ma_dk pht_type.a_var; a_ma_dkC pht_type.a_var; a_lh_nv pht_type.a_var; a_t_suat pht_type.a_num;
    a_cap pht_type.a_num; a_lbh pht_type.a_var; a_nv pht_type.a_var;
    a_tien pht_type.a_num; a_pt pht_type.a_num; a_phi pht_type.a_num;
    a_thue pht_type.a_num; a_ttoan pht_type.a_num;
    a_ptB pht_type.a_num; a_phiB pht_type.a_num;
    a_pvi_ma pht_type.a_var; a_pvi_tc pht_type.a_var; a_pvi_ktru pht_type.a_var;
begin
-- Dan - Tinh phi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_dkbs,dt_pvi');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_dkbs,dt_pvi using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_dkbs); FKH_JSa_NULL(dt_pvi);
FBH_PKTG_PHI(b_ma_dvi,dt_ct,dt_dk,dt_dkbs,dt_pvi,b_so_idP,
    a_ma,a_ten,a_tc,a_ma_ct,a_kieu,a_lkeM,a_lkeP,a_lkeB,a_luy,a_ktru,a_ma_dk,a_ma_dkC,
    a_lh_nv,a_t_suat,a_cap,a_lbh,a_nv,a_tien,a_pt,a_phi,a_thue,a_ttoan,a_ptB,a_phiB,
    a_pvi_ma,a_pvi_tc,a_pvi_ktru,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_oraOut:='';
for b_lp in 1..a_ma.count loop
    select json_object('ma' value a_ma(b_lp),'ten' value a_ten(b_lp),'tc' value a_tc(b_lp),'ma_ct' value a_ma_ct(b_lp),
    'kieu' value a_kieu(b_lp),'lkeM' value a_lkeM(b_lp),'lkeP' value a_lkeP(b_lp),'lkeB' value a_lkeB(b_lp),
    'luy' value a_luy(b_lp),'ktru' value a_ktru(b_lp),'ma_dk' value a_ma_dk(b_lp),'ma_dkC' value a_ma_dkC(b_lp),
    'lh_nv' value a_lh_nv(b_lp),'t_suat' value a_t_suat(b_lp),'cap' value a_cap(b_lp),'lbh' value a_lbh(b_lp),
    'nv' value a_nv(b_lp),'tien' value a_tien(b_lp),'pt' value a_pt(b_lp),
    'phi' value a_phi(b_lp),'thue' value a_thue(b_lp),'ttoan' value a_ttoan(b_lp),
    'ptB' value a_ptB(b_lp),'phiP' value a_phiB(b_lp),
    'pvi_ma'  value a_pvi_ma(b_lp),'pvi_tc' value a_pvi_tc(b_lp),'pvi_ktru' value a_pvi_ktru(b_lp) returning clob) into b_txt from dual;
    if b_lp>1 then b_oraOut:=b_oraOut||','; end if;
    b_oraOut:=b_oraOut||b_txt;
end loop;
if b_oraOut is not null then b_oraOut:='['||b_oraOut||']'; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKTG_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number;
    dt_ct clob; dt_dk clob; dt_dkbs clob:=''; dt_pvi clob;
    dt_lt clob:=''; dt_kbt clob:=''; dt_ttt clob:=''; dt_kytt clob:=''; dt_txt clob;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','PKT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
if b_so_id=0 then b_loi:='loi:GCN da xoa:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
select json_object(so_hd,ma_kh,
    'ma_cct' value FBH_PKT_MA_CCT_TENl(b.ma_cct),
    'ma_dkdl' value FBH_PKT_MA_DKDL_TENl(b.ma_dkdl),
    'ma_dktc' value FBH_PKT_MA_DKTC_TENl(b.ma_dktc) returning clob)
    into dt_ct from bh_pkt a,bh_pkt_dvi b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and b.ma_dvi=b_ma_dvi and b.so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ngay,tien) order by ngay) into dt_kytt from bh_pkt_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select txt into dt_dk from bh_pkt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dk';
select txt into dt_pvi from bh_pkt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_pvi';
select count(*) into b_i1 from bh_pkt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dkbs';
if b_i1=1 then
    select txt into dt_dkbs from bh_pkt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dkbs';
end if;
select count(*) into b_i1 from bh_pkt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_lt';
if b_i1=1 then
    select txt into dt_lt from bh_pkt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_lt';
end if;
select count(*) into b_i1 from bh_pkt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_kbt';
if b_i1=1 then
    select txt into dt_kbt from bh_pkt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_kbt';
end if;
select count(*) into b_i1 from bh_pkt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
if b_i1=1 then
    select txt into dt_ttt from bh_pkt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ttt';
end if;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_pkt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,
    'dt_dk' value dt_dk,'dt_dkbs' value dt_dkbs,'dt_pvi' value dt_pvi,
    'dt_lt' value dt_lt,'dt_kbt' value dt_kbt,'dt_kytt' value dt_kytt,'dt_ttt' value dt_ttt,
    'dt_ct' value dt_ct,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKTG_TESTr(
    b_ma_dvi varchar2,b_nsd varchar2,dt_ct in out clob,dt_dk clob,dt_dkbs clob,dt_pvi clob,
    b_ng_huong out nvarchar2,b_ma_sp out varchar2,b_dvi out nvarchar2,b_ddiem out nvarchar2,b_kvuc out varchar2,
    b_cdt out varchar2,b_tdx out number,b_tdy out number,b_bk out number,b_dk_lut out varchar2,b_hs_lut out number,

    b_ma_cct out varchar2,b_ma_dt out varchar2,b_ma_dkdl out varchar2,
    b_ma_dktc out varchar2,b_rru out varchar2,b_tgian out number,b_bhanh out number,

    b_nt_tien out varchar2,b_nt_phi out varchar2,b_c_thue out varchar2,b_so_idP out number,
    dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,dk_tc out pht_type.a_var,
    dk_ma_ct out pht_type.a_var,dk_kieu out pht_type.a_var,
    dk_lkeM out pht_type.a_var,dk_lkeP out pht_type.a_var,dk_lkeB out pht_type.a_var,
    dk_luy out pht_type.a_var,dk_ktru out pht_type.a_var,
    dk_ma_dk out pht_type.a_var,dk_ma_dkC out pht_type.a_var,dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,
    dk_cap out pht_type.a_num,dk_lbh out pht_type.a_var,dk_nv out pht_type.a_var,
    dk_tien out pht_type.a_num,dk_pt out pht_type.a_num,dk_phi out pht_type.a_num,
    dk_thue out pht_type.a_num,dk_ttoan out pht_type.a_num,
    dk_ptB out pht_type.a_num,dk_phiB out pht_type.a_num,dk_ptG out pht_type.a_num,dk_phiG out pht_type.a_num,
    dk_pvi_ma out pht_type.a_var,dk_pvi_tc out pht_type.a_var,dk_pvi_ktru out pht_type.a_var,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_lenh varchar2(2000); dt_khd clob; b_txt clob;
    b_thueH number; b_ttoanH number; b_tygia number; b_tp number:=0; b_so_idPn number;
    b_ttrang varchar2(1); b_ngay_hl number; b_ngay_kt number; b_ps varchar2(1); b_qdoi number;
    b_loai_khH varchar2(1); b_ma_khH varchar2(20); b_tenH nvarchar2(500); b_nhom varchar2(1);
    b_cmtH varchar2(20); b_mobiH varchar2(20); b_emailH varchar2(20); b_dchiH nvarchar2(400);
    b_ma_nct varchar2(500); b_ma_ntb varchar2(500);
begin
-- Dan - Nhap
b_lenh:='ttrang,ngay_hl,ngay_kt,dvi,ddiem,tdx,tdy,cdt,dk_lut,hs_lut,ma_cct,ma_dkdl,ma_dktc,nt_tien,nt_phi,tygia,c_thue,thue,ttoan,tgian,bhanh,bk,so_idp';
b_lenh:=FKH_JS_LENH(b_lenh);
EXECUTE IMMEDIATE b_lenh into
    b_ttrang,b_ngay_hl,b_ngay_kt,b_dvi,b_ddiem,b_tdx,b_tdy,b_cdt,b_dk_lut,b_hs_lut,b_ma_cct,b_ma_dkdl,b_ma_dktc,
    b_nt_tien,b_nt_phi,b_tygia,b_c_thue,b_thueH,b_ttoanH,b_tgian,b_bhanh,b_bk,b_so_idPn using dt_ct;
if b_dvi=' ' or b_ddiem=' ' then b_loi:='loi:Nhap dia diem, dia chi bao hiem:loi'; return; end if;
if b_tdx=0 then b_loi:='loi:Chua lay duoc toa do:loi'; return; end if;
b_kvuc:=' ';
if b_dk_lut=' ' then b_dk_lut:='K'; end if;
if b_bk=0 then b_bk:=10; end if;
b_ma_cct:=PKH_MA_TENl(b_ma_cct); b_ma_dkdl:=PKH_MA_TENl(b_ma_dkdl); b_ma_dktc:=PKH_MA_TENl(b_ma_dktc);
PBH_PKT_BPHI_TSO(dt_ct,b_nhom,b_ma_sp,b_ma_nct,b_rru,b_ma_ntb,b_ngay_hl);
PBH_PKT_BPHI_TSOt(b_ma_sp,b_ma_cct,b_ma_nct,b_ma_dkdl,b_ma_dktc,b_rru,b_ma_ntb,b_loi);
if b_loi is not null then return; end if;
--lay doi tuong
if b_ma_nct<>' ' then b_ma_dt:=b_ma_nct;
elsif b_ma_ntb<>' ' then b_ma_dt:=b_ma_ntb;
else b_ma_dt:=' ';
end if;
b_nt_tien:=nvl(trim(b_nt_tien),'VND'); b_nt_phi:=nvl(trim(b_nt_phi),'VND');
if b_nt_phi<>'VND' then b_tp:=2; end if;
FBH_PKTG_PHI(b_ma_dvi,dt_ct,dt_dk,dt_dkbs,dt_pvi,b_so_idP,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy,dk_ktru,dk_ma_dk,dk_ma_dkC,
    dk_lh_nv,dk_t_suat,dk_cap,dk_lbh,dk_nv,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,dk_ptB,dk_phiB,
    dk_pvi_ma,dk_pvi_tc,dk_pvi_ktru,b_loi);
if b_loi is not null then return; end if;
if b_so_idP<>b_so_idPn then
    b_loi:='loi:Thong tin xac dinh bieu phi bi thay doi:loi'; return;
end if;
PBH_HD_THAY_PHIg(b_nt_tien,b_nt_tien,b_tygia,b_thueH,b_ttoanH,dk_lh_nv,dk_tien,dk_phi,dk_thue,dk_ttoan,b_loi);
if b_loi is not null then return; end if;
for b_lp in 1..dk_ma.count loop
    if dk_phiB(b_lp)>dk_phi(b_lp) then
        dk_phiG(b_lp):=dk_phiB(b_lp)-dk_phi(b_lp);
        dk_ptG(b_lp):=round(dk_phiG(b_lp)*100/dk_phiB(b_lp),2);
    else
        dk_ptG(b_lp):=0; dk_phiG(b_lp):=0;
    end if;
end loop;
PKH_JS_THAYn(dt_ct,'tdx',b_tdx); PKH_JS_THAYn(dt_ct,'tdy',b_tdy);
PKH_JS_THAYn(dt_ct,'so_idp',b_so_idP); b_ng_huong:=' ';
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
    select count(*) into b_i1 from bh_pkt_phi_txt where so_id=b_so_idP and loai='dt_khd';
    if b_i1<>0 then
        select txt into dt_khd from bh_pkt_phi_txt where so_id=b_so_idP and loai='dt_khd';
        b_i1:=length(dt_khd)-2;
        dt_khd:=substr(dt_khd,2,b_i1);
        PBH_PKTG_KHD(dt_ct,dt_dk,dt_khd,b_loi);
        if b_loi is not null then return; end if;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PKTG_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    dt_ct in out clob,dt_dk clob,dt_dkbs clob,dt_pvi clob,dt_lt clob,dt_kbt clob,dt_ttt clob,
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
    b_ng_huong nvarchar2,b_ma_sp varchar2,b_so_idP number,b_dvi nvarchar2,b_ddiem nvarchar2,
    b_kvuc varchar2,b_cdt varchar2,b_tdx number,b_tdy number,b_bk number,b_dk_lut varchar2,b_hs_lut number,
    b_ma_cct varchar2,b_ma_dt varchar2,b_ma_dkdl varchar2,b_ma_dktc varchar2,
    b_rru varchar2,b_tgian number,b_bhanh number,
    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tc pht_type.a_var,
    dk_ma_ct pht_type.a_var,dk_kieu pht_type.a_var,
    dk_lkeM pht_type.a_var,dk_lkeP pht_type.a_var,dk_lkeB pht_type.a_var,
    dk_luy pht_type.a_var,dk_ktru pht_type.a_var,
    dk_ma_dk pht_type.a_var,dk_ma_dkC pht_type.a_var,dk_lh_nv pht_type.a_var,dk_t_suat pht_type.a_num,
    dk_cap pht_type.a_num,dk_lbh pht_type.a_var,dk_nv pht_type.a_var,
    dk_tien pht_type.a_num,dk_pt pht_type.a_num,dk_phi pht_type.a_num,
    dk_thue pht_type.a_num,dk_ttoan pht_type.a_num,
    dk_ptB pht_type.a_num,dk_phiB pht_type.a_num,
    dk_ptG pht_type.a_num,dk_phiG pht_type.a_num,
    dk_pvi_ma pht_type.a_var,dk_pvi_tc pht_type.a_var,dk_pvi_ktru pht_type.a_var,b_loi out varchar2)
AS
    b_i1 number; b_so_id_kt number:=-1; b_tien number:=0; b_ma_ke varchar2(20):=' '; b_txt clob;
begin
-- Dan - Nhap
b_loi:='loi:Loi Table bh_pkt:loi';
if b_ttrang='D' then b_so_id_kt:=0; end if;
insert into bh_pkt_dvi values(b_ma_dvi,b_so_id,b_so_idD,0,b_kieu_hd,b_so_hd,b_so_hd_g,
    b_dvi,b_kvuc,b_ddiem,b_dk_lut,b_hs_lut,b_cdt,b_tdx,b_tdy,b_bk,
    b_ma_cct,b_ma_dt,b_ma_dkdl,b_ma_dktc,b_rru,b_tgian,b_bhanh,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,
    b_so_idP,b_giam,b_phi,b_thue,b_ttoan);
for b_lp in 1..dk_lh_nv.count loop
    if dk_lh_nv(b_lp)<>' ' and dk_kieu(b_lp)='T' then b_tien:=b_tien+dk_tien(b_lp); end if;
    insert into bh_pkt_dk values(b_ma_dvi,b_so_id,b_so_idD,b_lp,
        dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),dk_kieu(b_lp),dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),dk_cap(b_lp),
        dk_ma_dk(b_lp),dk_ma_dkC(b_lp),dk_lh_nv(b_lp),dk_t_suat(b_lp),dk_thue(b_lp),dk_ttoan(b_lp),
        dk_ptB(b_lp),dk_phiB(b_lp),dk_ptG(b_lp),dk_phiG(b_lp),
        dk_lkeM(b_lp),dk_lkeP(b_lp),dk_lkeB(b_lp),dk_luy(b_lp),dk_lbh(b_lp),dk_nv(b_lp),dk_ktru(b_lp),
        dk_pvi_ma(b_lp),dk_pvi_tc(b_lp),dk_pvi_ktru(b_lp));
end loop;
insert into bh_pkt values(
    b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,'G',b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
    b_phong,b_so_hdL,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,
    b_nt_tien,b_nt_phi,b_c_thue,b_ma_sp,1,b_tien,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,'','',b_so_id_kt,b_nsd,sysdate);
insert into bh_hd_goc_ttdt values(b_ma_dvi,b_so_id,b_so_idD,'PKT',b_dvi,b_ma_kh,b_ngay_kt,b_ddiem);
for b_lp in 1..tt_ngay.count loop
    insert into bh_pkt_tt values(b_ma_dvi,b_so_id,tt_ngay(b_lp),tt_tien(b_lp));
end loop;
PKH_JS_THAYa(dt_ct,'so_hd,ma_kh',b_so_hd||','||b_ma_kh);
insert into bh_pkt_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
insert into bh_pkt_txt values(b_ma_dvi,b_so_id,'dt_dk',dt_dk);
insert into bh_pkt_txt values(b_ma_dvi,b_so_id,'dt_pvi',dt_pvi);
if dt_dkbs is not null then
    insert into bh_pkt_txt values(b_ma_dvi,b_so_id,'dt_dkbs',dt_dkbs);
end if;
if dt_ttt is not null then
    insert into bh_pkt_txt values(b_ma_dvi,b_so_id,'dt_ttt',dt_ttt);
end if;
if b_ttrang in('T','D') then
    select JSON_ARRAYAGG(json_object(
        ma,ten,tc,ma_ct,kieu,tien,pt,phi,cap,ma_dk,ma_dkC,lh_nv,t_suat,thue,ttoan,
        ptB,ptG,phiG,lkeM,lkeP,lkeB,luy,pvi_ma,pvi_tc,pvi_ktru)
        order by bt returning clob) into b_txt
        from bh_pkt_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
    insert into bh_pkt_kbt values(b_ma_dvi,b_so_id,b_so_idD,b_txt,dt_lt,dt_kbt);
    if b_tdx<>0 and b_tdy<>0 and b_bk<>0 then
        insert into bh_pkt_ttu values(b_ma_dvi,b_so_idD,b_so_idD,b_dvi,b_tdx,b_tdy,b_bk,b_ngay_hl,b_ngay_kt);
    end if;
    select json_object('ma_dvi' value b_ma_dvi,'nsd' value b_nsd,'so_id' value b_so_id,'so_hd' value b_so_hd,
        'kieu_hd' value b_kieu_hd,'nv' value 'PKT','ngay_ht' value b_ngay_ht,'ngay_cap' value b_ngay_cap,
        'ngay_hl' value b_ngay_hl,'ngay_kt' value b_ngay_kt,'cb_ql' value b_ma_cb,'phong' value b_phong,
        'kieu_kt' value b_kieu_kt,'ma_kt' value b_ma_kt,'dly_tke' value ' ','hhong' value b_hhong,
        'pt_hhong' value 'D','ma_kh' value b_ma_kh,'ten' value b_ten,'kieu_gt' value b_kieu_gt,
        'ma_gt' value b_ma_gt,'so_id_d' value b_so_idD,'so_id_g' value b_so_idG,'ttrang' value b_ttrang,
        'dvi_ksoat' value b_ma_dvi,'ksoat' value b_nsd,'bangg' value 'bh_pkt',
        'c_thue' value b_c_thue,'nt_tien' value b_nt_tien,'nt_phi' value b_nt_phi,'tien' value b_tien,
        'phi' value b_ttoan-b_thue,'thue' value b_thue returning clob) into b_txt from dual;
    PBH_HD_GOC_NH(b_txt,b_loi);
    if b_loi is not null then return; end if;
end if;
if b_ttrang='D' then
    PBH_KE_CTI_NHOM(b_ma_dvi,b_so_idD,b_so_idD,b_ma_ke,b_loi);
    if b_loi is not null then return; end if;
    insert into bh_hd_goc_ttindt values(b_ma_dvi,b_so_idD,b_so_idD,'PKT',b_dvi,b_ma_kh,b_ngay_kt,b_ddiem,b_ma_ke);
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/   
create or replace procedure PBH_PKTG_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(3000); b_lenh varchar2(2000); b_i1 number; b_so_idP number;
    dt_ct clob; dt_dk clob; dt_dkbs clob; dt_pvi clob; dt_lt clob; dt_kbt clob; dt_ttt clob; dt_kytt clob;
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
    b_ng_huong nvarchar2(500); b_ma_sp varchar2(10); b_dvi nvarchar2(500); b_ddiem nvarchar2(500);
    b_kvuc varchar2(10); b_cdt varchar2(5); b_tdx number; b_tdy number; b_bk number; b_dk_lut varchar2(1); b_hs_lut number;

    b_ma_cct varchar2(10); b_ma_dt varchar2(10); b_ma_dkdl varchar2(10);
    b_ma_dktc varchar2(10); b_rru varchar2(1); b_tgian number; b_bhanh number;

    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var;
    dk_ma_ct pht_type.a_var; dk_kieu pht_type.a_var;
    dk_lkeM pht_type.a_var; dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var;
    dk_luy pht_type.a_var; dk_ktru pht_type.a_var;
    dk_ma_dk pht_type.a_var; dk_ma_dkC pht_type.a_var; dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num;
    dk_cap pht_type.a_num; dk_lbh pht_type.a_var; dk_nv pht_type.a_var;
    dk_tien pht_type.a_num; dk_pt pht_type.a_num; dk_phi pht_type.a_num;
    dk_thue pht_type.a_num; dk_ttoan pht_type.a_num;
    dk_ptB pht_type.a_num; dk_phiB pht_type.a_num; dk_ptG pht_type.a_num; dk_phiG pht_type.a_num;
    dk_pvi_ma pht_type.a_var; dk_pvi_tc pht_type.a_var; dk_pvi_ktru pht_type.a_var;
-- Xu ly
    b_ngay_htC number;
begin
-- Dan - Nhap
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_dkbs,dt_pvi,dt_lt,dt_kbt,dt_ttt,dt_kytt');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_dkbs,dt_pvi,dt_lt,dt_kbt,dt_ttt,dt_kytt using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_dkbs); FKH_JSa_NULL(dt_pvi);
FKH_JSa_NULL(dt_lt); FKH_JSa_NULL(dt_kbt); FKH_JSa_NULL(dt_ttt); FKH_JSa_NULL(dt_kytt); 
if b_so_id<>0 then
    select count(*) into b_i1 from bh_pkt where so_id=b_so_id;
    if b_i1<>0 then
        select ngay_ht,kieu_hd,ttrang into b_ngay_htC,b_kieu_hd,b_ttrang from bh_pkt
            where so_id=b_so_id for update nowait;
        if sql%rowcount=0 then b_loi:='loi:Va cham NSD:loi'; raise PROGRAM_ERROR; end if;
        if b_ttrang not in('T','D') then b_kieu_hd:='X'; else b_kieu_hd:='N'; end if;
        PBH_PKT_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_kieu_hd,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
else
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_HD_JS_TEST(
    b_ma_dvi,b_nsd,b_so_id,b_ngay_htC,'bh_pkt',dt_ct,dt_kytt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_loai_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,
    b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_ngayD,b_phong,b_ma_cb,b_ma_kh,
    tt_ngay,tt_tien,b_loi,'PKT');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_PKTG_TESTr(
  b_ma_dvi,b_nsd,dt_ct,dt_dk,dt_dkbs,dt_pvi,
    b_ng_huong,b_ma_sp,b_dvi,b_ddiem,b_kvuc,b_cdt,b_tdx,b_tdy,b_bk,b_dk_lut,b_hs_lut,
   b_ma_cct,b_ma_dt,b_ma_dkdl,b_ma_dktc,b_rru,b_tgian,b_bhanh,
   b_nt_tien,b_nt_phi,b_c_thue,b_so_idP,
  dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy,dk_ktru,
    dk_ma_dk,dk_ma_dkC,dk_lh_nv,dk_t_suat,
    dk_cap,dk_lbh,dk_nv,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,dk_ptB,dk_phiB,dk_ptG,dk_phiG,dk_pvi_ma,dk_pvi_tc,dk_pvi_ktru,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_PKTG_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,
    dt_ct,dt_dk,dt_dkbs,dt_pvi,dt_lt,dt_kbt,dt_ttt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,b_so_hdL,
    b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,
    b_nt_tien,b_nt_phi,b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_ngayD,b_phong,
    tt_ngay,tt_tien,
-- Rieng
    b_ng_huong,b_ma_sp,b_so_idP,b_dvi,b_ddiem,b_kvuc,b_cdt,b_tdx,b_tdy,b_bk,b_dk_lut,b_hs_lut,
    b_ma_cct,b_ma_dt,b_ma_dkdl,b_ma_dktc,b_rru,b_tgian,b_bhanh,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy,dk_ktru,
    dk_ma_dk,dk_ma_dkC,dk_lh_nv,dk_t_suat,
    dk_cap,dk_lbh,dk_nv,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,dk_ptB,dk_phiB,dk_ptG,dk_phiG,dk_pvi_ma,dk_pvi_tc,dk_pvi_ktru,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hd' value b_so_hd, 'ma_kh' value b_ma_kh) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
