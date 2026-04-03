create or replace procedure FBH_PHHH_PHI(
    b_ma_dvi varchar2,dt_ct clob,dt_dkH clob,dt_dkbsH clob,
    dt_dk clob,dt_dkbs clob,dt_dkth clob,dt_pvi clob,
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
    a_pvi_ma out pht_type.a_var,a_pvi_tc out pht_type.a_var,a_pvi_ktru out pht_type.a_var,
    a_m out pht_type.a_var,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_i1 number; b_i2 number; b_iX number;
    b_so_id_dt number; b_so_idD number; b_hs number; b_capD number; b_capC number;
    b_kt number:=0; b_ktL number:=0; b_maHH varchar2(5); b_pt_hang number;
    b_nhom varchar2(10); b_ma_sp varchar2(10); b_cdich varchar2(10); b_goi varchar2(10); b_ktru nvarchar2(500);
    b_mrr varchar2(500); b_c_thue varchar2(1); b_kho number; b_tp number:=0; b_tg number:=1;
    b_ngay_hl number; b_ngay_kt number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tien number;
    b_kieu_hd  varchar2(1); b_so_hdG varchar2(20); b_so_idG number:=0; b_ngay_cap number;
    b_tygia number;
    b_pvi_ptTS number:=0; b_pvi_ptTSb number:=0; b_pvi_ptTSc number:=0;
    b_pvi_ptKH number:=0; b_pvi_ptKHb number:=0; b_pvi_ptKHc number:=0;
    b_ptTS number:=0; b_ptKH number:=0; b_pt number:=0; b_dk varchar2(1);
    a_ptC pht_type.a_num; a_phiX pht_type.a_num; a_so_idG pht_type.a_num;
    a_ngay_hlG pht_type.a_num; a_ngay_ktG pht_type.a_num; a_ngay_capG pht_type.a_num; 
    a_pp pht_type.a_var; a_ptk pht_type.a_var;
    
    dk_ma pht_type.a_var; dk_tien pht_type.a_num; dk_phi pht_type.a_num; dk_phiB pht_type.a_num; dk_pt pht_type.a_num; 
    dk_maG pht_type.a_var; dk_phiG pht_type.a_num;
    pvi_ma pht_type.a_var; pvi_tc pht_type.a_var; pvi_ten pht_type.a_var;
    pvi_ptTS pht_type.a_num; pvi_ptKH pht_type.a_num; pvi_ktru pht_type.a_var;
    pvi_loai pht_type.a_var; pvi_ma_ct pht_type.a_var;
    pvi_ptTSb pht_type.a_num; pvi_ptKHb pht_type.a_num;
    pvi_ppTS pht_type.a_var; pvi_ppKH pht_type.a_var;
    pvi_ptkTS pht_type.a_var; pvi_ptkKH pht_type.a_var;
    pvi_ptTSc pht_type.a_num; pvi_ptKHc pht_type.a_num;

    bs_ma pht_type.a_var; bs_tien pht_type.a_num; bs_ptB pht_type.a_num; bs_pt pht_type.a_num;
    bs_pp pht_type.a_var; bs_ptK pht_type.a_var; bs_dkH pht_type.a_var; bs_m pht_type.a_var;

    bs_maH pht_type.a_var; bs_tienH pht_type.a_num; bs_ptBH pht_type.a_num; bs_ptH pht_type.a_num;
    bs_ppH pht_type.a_var; bs_ptKH pht_type.a_var; bs_dkHH pht_type.a_var;

    a_maM pht_type.a_var; a_tenM pht_type.a_nvar; a_tienM pht_type.a_num; a_ptM pht_type.a_num;
    a_phiM pht_type.a_num; a_thueM pht_type.a_num; a_ktruM pht_type.a_var; a_lh_nvM pht_type.a_var;
    a_t_suatM pht_type.a_num; a_luyM pht_type.a_var; a_dkHM pht_type.a_var; a_mM pht_type.a_var;

    a_maMH pht_type.a_var; a_tenMH pht_type.a_nvar; a_tienMH pht_type.a_num; a_ptMH pht_type.a_num;
    a_phiMH pht_type.a_num; a_thueMH pht_type.a_num; a_ktruMH pht_type.a_var; a_lh_nvMH pht_type.a_var; --Nam: ktru a_var
    a_t_suatMH pht_type.a_num; a_luyMH pht_type.a_var; a_dkHMH pht_type.a_var;

begin
-- Dan - Tinh phi
b_lenh:=FKH_JS_LENH('so_id_dt,kieu_hd,so_hd_g,nhom,ma_sp,cdich,goi,mrr,ngay_hl,ngay_kt,ngay_cap,nt_tien,nt_phi,tygia,c_thue,pt_hang');
EXECUTE IMMEDIATE b_lenh into b_so_id_dt,b_kieu_hd,b_so_hdG,b_nhom,b_ma_sp,b_cdich,b_goi,b_mrr,
    b_ngay_hl,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,b_tygia,b_c_thue,b_pt_hang using dt_ct;
b_cdich:=nvl(b_cdich,' '); b_goi:=nvl(b_goi,' '); b_mrr:=PKH_MA_TENl(b_mrr);
b_so_idP:=FBH_PHH_BPHId_SO_ID(b_nhom,b_ma_sp,b_cdich,b_goi,b_mrr,b_ngay_hl);
if b_so_idP=0 then b_loi:='loi:Khong lay duoc bieu phi:loi'; return; end if;
b_kieu_hd:=nvl(trim(b_kieu_hd),'G'); b_so_hdG:=nvl(trim(b_so_hdG),' ');
if b_kieu_hd in('B','S') and b_so_hdG<>' ' and b_ngay_hl<b_ngay_cap then
    b_dk:='C'; -- nam: sdbs khong tinh theo phi ngan han
    b_so_idG:=FBH_PHH_SO_ID(b_ma_dvi,b_so_hdG);
    if b_so_idG=0 then b_loi:='loi:GCN goc da xoa:loi'; return; end if;
end if;
if b_tygia is null or b_tygia=0 then b_tygia:=1; end if;
if b_nt_phi<>'VND' then b_tp:=2; end if;
if b_pt_hang=0 or b_pt_hang>100 then b_pt_hang:=100; end if;
b_lenh:=FKH_JS_LENH('ma,tien,pt,phi');
EXECUTE IMMEDIATE b_lenh bulk collect into dk_ma,dk_tien,dk_pt,dk_phi using dt_dk;
if dk_ma.count=0 then b_loi:='loi:Nhap so tien bao hiem:loi'; return; end if;
b_lenh:=FKH_JS_LENH('ma,ten,pttsb,ppts,ptts,ptkhb,ppkh,ptkh,ktru,tc,loai,ma_ct,ptkts,ptkkh');
EXECUTE IMMEDIATE b_lenh bulk collect into pvi_ma,pvi_ten,pvi_ptTSb,pvi_ppTS,pvi_ptTS,pvi_ptKHb,pvi_ppKH,pvi_ptKH,
                  pvi_ktru,pvi_tc,pvi_loai,pvi_ma_ct,pvi_ptkTS,pvi_ptkKH using dt_pvi;
if pvi_ma.count=0 then b_loi:='loi:Nhap pham vi bao hiem:loi'; return; end if;
b_lenh:=FKH_JS_LENH('ma,tien,ptb,pp,pt,ptk,dkh');
EXECUTE IMMEDIATE b_lenh bulk collect into bs_ma,bs_tien,bs_ptB,bs_pp,bs_pt,bs_ptK,bs_dkH using dt_dkbs;
for b_lp in 1..bs_ma.count loop
    bs_m(b_lp):='K';
end loop;
if trim(dt_dkbsH) is not null then
    if bs_ma.count=0 then
        EXECUTE IMMEDIATE b_lenh bulk collect into bs_ma,bs_tien,bs_ptB,bs_pp,bs_pt,bs_ptK,bs_dkH using dt_dkbsH;
        for b_lp in 1..bs_ma.count loop
            bs_m(b_lp):='C'; bs_pp(b_lp):=nvl(trim(bs_pp(b_lp)),'GP');
            bs_dkH(b_lp):=nvl(trim(bs_dkH(b_lp)),'C');
        end loop;
    else
        EXECUTE IMMEDIATE b_lenh bulk collect into bs_maH,bs_tienH,bs_ptBH,bs_ppH,bs_ptH,bs_ptKH,bs_dkHH using dt_dkbsH;
        for b_lp in 1..bs_maH.count loop
            b_i1:=FKH_ARR_VTRI(bs_ma,bs_maH(b_lp));
            if b_i1=0 or bs_dkH(b_i1)<>'K' then
                if b_i1=0 then b_i1:=bs_ma.count+1; end if;
                bs_m(b_i1):='C';
                bs_ma(b_i1):=bs_maH(b_lp); bs_tien(b_i1):=bs_tienH(b_lp);
                bs_ptB(b_i1):=bs_ptBH(b_lp); bs_pt(b_i1):=bs_ptH(b_lp);
                bs_dkH(b_i1):=bs_dkHH(b_lp); bs_ptK(b_i1):=bs_ptKH(b_lp);
                bs_pp(b_i1):=bs_ppH(b_lp);
            end if;
        end loop;
    end if;
end if;
b_i1:=bs_ma.count;
for b_lp in reverse 1..b_i1 loop
    if bs_dkH(b_lp)='K' then
        bs_ma.delete(b_lp); bs_tien.delete(b_lp); bs_ptB.delete(b_lp); bs_pt.delete(b_lp); bs_dkH.delete(b_lp);
    end if;
end loop;
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
    b_pvi_ptTSc:=b_pvi_ptTSc+pvi_ptTSc(b_lp);
    b_pvi_ptKHc:=b_pvi_ptKHc+pvi_ptKHc(b_lp);
end loop;
if F_KTRA_KTRU(pvi_ktru,b_loi) <> 'C' then b_loi:='loi:Pham vi khau tru sai dinh dang:loi'; end if;
b_ktru:=FBH_BT_KTRUs(pvi_ktru);
if b_nt_tien<>'VND' and b_nt_phi='VND' and b_tygia<>0 then
    b_tg:=b_tg*b_tygia;
elsif b_nt_tien='VND' and b_nt_phi<>'VND' and b_tygia<>0 then
    b_tg:=b_tg/b_tygia;
end if;
--nam: check sua doi bo sung khong tinh theo phi ngan han
FBH_PHHG_KHO(b_ngay_hl,b_ngay_kt,b_kho,b_loi,b_dk);
if b_loi is not null then return; end if;
b_kt:=0;
for b_lp_dk in 1..dk_ma.count loop
    select count(*) into b_i1 from bh_phh_phi_dk where so_id=b_so_idP and ma=dk_ma(b_lp_dk);
    if b_i1<>1 then b_loi:='loi:Sai bieu phi dieu khoan '||b_so_idP||':'||dk_ma(b_lp_dk)||':loi'; return; end if;
    b_kt:=b_kt+1; b_ktL:=b_kt;
    select ma,ten,tc,ma_ct,'T',lkeM,lkeP,lkeB,luy,ktru,ma_dk,lh_nv,t_suat,cap,lbh,nv into
        a_ma(b_kt),a_ten(b_kt),a_tc(b_kt),a_ma_ct(b_kt),a_kieu(b_kt),
        a_lkeM(b_kt),a_lkeP(b_kt),a_lkeB(b_kt),a_luy(b_kt),a_ktru(b_kt),
        a_ma_dk(b_kt),a_lh_nv(b_kt),a_t_suat(b_kt),a_cap(b_kt),a_lbh(b_kt),a_nv(b_kt)
        from bh_phh_phi_dk where so_id=b_so_idP and ma=dk_ma(b_lp_dk) and nv='C';
    a_tien(b_kt):=dk_tien(b_lp_dk); a_pt(b_kt):=0; a_ma_dkC(b_kt):=' '; a_phi(b_kt):=0;
    a_ptB(b_kt):=0; a_phiB(b_kt):=0; a_pvi_ma(b_kt):=' '; a_pvi_tc(b_kt):=' '; a_pp(b_kt):=' ';
    if a_ktru(b_kt)<>'P' then a_pvi_ktru(b_kt):=' '; else a_pvi_ktru(b_kt):=b_ktru; end if;
    b_maHH:=FBH_PHH_LBH_LOAI(dk_ma(b_lp_dk));
    if a_lkeP(b_kt)='D' then b_kho:=1; end if;
    if a_tc(b_kt)='C' then
        for b_lp_pvi in 1..pvi_ma.count loop
            b_kt:=b_kt+1;
            a_ma(b_kt):=a_ma(b_ktL)||'>'||pvi_ma(b_lp_pvi); a_kieu(b_kt):=a_kieu(b_ktL);
            a_ten(b_kt):='- '||pvi_ten(b_lp_pvi);
            a_tc(b_kt):='C'; a_ma_ct(b_kt):=a_ma(b_ktL);
            a_lkeM(b_kt):=a_lkeM(b_ktL); a_lkeP(b_kt):=a_lkeP(b_ktL);
            if a_lkeP(b_ktL) not in ('G','D','T','N') then a_lkeP(b_kt):='K'; else a_lkeP(b_kt):=a_lkeP(b_ktL); end if;
            a_lkeB(b_kt):=a_lkeB(b_ktL); a_luy(b_kt):=a_luy(b_ktL); a_ktru(b_kt):=a_ktru(b_ktL);
            a_ma_dk(b_kt):=a_ma_dk(b_ktL); a_ma_dkC(b_kt):=a_ma_dk(b_ktL); a_lh_nv(b_kt):=' ';
            a_t_suat(b_kt):=a_t_suat(b_ktL); a_cap(b_kt):=a_cap(b_ktL)+1; a_lbh(b_kt):=a_lbh(b_ktL); a_nv(b_kt):=a_nv(b_ktL);
            a_tien(b_kt):=0;
            b_tien:=a_tien(b_ktL); b_pt:=0;
            if b_tien=0 and a_lkeM(b_ktL)='B' then
                b_i1:=FKH_ARR_VTRI(a_ma,a_ma_ct(b_ktL));
                if b_i1<>0 then b_tien:=a_tien(b_i1); end if;
            end if;
            if a_lkeP(b_kt)='K' then
                 a_pt(b_kt):=0; a_phi(b_kt):=0; a_ptB(b_kt):=0; a_phiB(b_kt):=0; a_ptC(b_kt):=0; a_pp(b_kt):=' ';
            else
                if a_lbh(b_kt) in('TS','TB','HH') then
                    a_pt(b_kt):=pvi_ptTS(b_lp_pvi); a_ptB(b_kt):=pvi_ptTSb(b_lp_pvi);
                    a_ptC(b_kt):=pvi_ptTSc(b_lp_pvi); a_pp(b_kt):=pvi_ppTS(b_lp_pvi);
                    a_ptk(b_kt):=pvi_ptkTS(b_lp_pvi);
                else
                    a_pt(b_kt):=pvi_ptKH(b_lp_pvi); a_ptB(b_kt):=pvi_ptKHb(b_lp_pvi);
                    a_ptC(b_kt):=pvi_ptKHc(b_lp_pvi); a_pp(b_kt):=pvi_ppKH(b_lp_pvi);
                    a_ptk(b_kt):=pvi_ptkKH(b_lp_pvi);
                end if;
                if a_ptB(b_kt) < 100 then
                    if a_pp(b_kt) = 'DG' and b_tien<>0 then b_pt:=ROUND(a_pt(b_kt)*100/b_tien,20);
                    elsif a_pp(b_kt) = 'DP' then b_pt:=a_pt(b_kt);
                    elsif a_pp(b_kt) = 'GG' and b_tien<>0 then b_pt:=a_ptB(b_kt) - ROUND((a_pt(b_kt)/b_tien*100),20);
                    elsif a_pp(b_kt) = 'GT' then b_pt:= a_ptB(b_kt) - a_pt(b_kt);
                    elsif a_pp(b_kt) = 'GP' then b_pt:=a_ptB(b_kt) - ROUND(a_pt(b_kt)*a_ptB(b_kt)/100,20);
                    else b_pt:=a_ptB(b_kt);
                    end if;
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
                if b_pt_hang<>0 and b_maHH='HH' then
                    a_pt(b_kt):=round(a_pt(b_kt)*b_pt_hang/100,20);
                    a_phi(b_kt):=round(a_phi(b_kt)*b_pt_hang/100,b_tp);
                    a_ptB(b_kt):=round(a_ptB(b_kt)*b_pt_hang/100,20);
                    a_phiB(b_kt):=round(a_phiB(b_kt)*b_pt_hang/100,b_tp);
                end if;
            end if;
            a_pvi_ma(b_kt):=pvi_ma(b_lp_pvi); a_pvi_tc(b_kt):=pvi_tc(b_lp_pvi); a_pvi_ktru(b_kt):=pvi_ktru(b_lp_pvi);
        end loop;
        a_tc(b_ktL):='T'; a_lkeP(b_ktL):='T';
      elsif a_lkeP(b_kt) in ('G','D') and a_tien(b_kt)<>0 then
        b_tien:=a_tien(b_kt);
        for b_lp_pvi in 1..pvi_ma.count loop
          if a_lbh(b_kt) in('TS','TB','HH') then
              b_ptTS:= 0;
              a_pp(b_lp_pvi):=pvi_ppTS(b_lp_pvi); a_ptk(b_kt):=pvi_ptkTS(b_lp_pvi);
              if a_pp(b_lp_pvi) = 'DG' and b_tien<>0 then b_ptTS:=ROUND(pvi_ptTS(b_lp_pvi)*100/b_tien,20);
              elsif a_pp(b_lp_pvi) = 'DP' then b_ptTS:=pvi_ptTS(b_lp_pvi);
              elsif a_pp(b_lp_pvi) = 'GG' and b_tien<>0 then b_ptTS:=pvi_ptTSb(b_lp_pvi) - ROUND((pvi_ptTS(b_lp_pvi)/b_tien*100),20);
              elsif a_pp(b_lp_pvi) = 'GT' then b_ptTS:= pvi_ptTSb(b_lp_pvi) - pvi_ptTS(b_lp_pvi);
              elsif a_pp(b_lp_pvi) = 'GP' then b_ptTS:=pvi_ptTSb(b_lp_pvi) - ROUND(pvi_ptTS(b_lp_pvi)*pvi_ptTSb(b_lp_pvi)/100,20);
              else b_ptTS:=pvi_ptTSb(b_lp_pvi);
              end if;
              b_pvi_ptTS:=b_pvi_ptTS+b_ptTS;
              b_pvi_ptTSb:=b_pvi_ptTSb+pvi_ptTSb(b_lp_pvi);
              a_pt(b_kt):=b_pvi_ptTS; a_ptB(b_kt):=b_pvi_ptTSb;
          else
              b_ptKH:= 0;
              a_pp(b_lp_pvi):=pvi_ppKH(b_lp_pvi); a_ptk(b_kt):=pvi_ptkKH(b_lp_pvi);
              if a_pp(b_lp_pvi) = 'DG' and b_tien<>0 then b_ptKH:=ROUND(pvi_ptKH(b_lp_pvi)*100/b_tien,20);
                elsif a_pp(b_lp_pvi) = 'DP' then b_ptKH:=pvi_ptKH(b_lp_pvi);
                elsif a_pp(b_lp_pvi) = 'GG' and b_tien<>0 then b_ptKH:=pvi_ptKHb(b_lp_pvi) - ROUND((pvi_ptKH(b_lp_pvi)/b_tien*100),20);
                elsif a_pp(b_lp_pvi) = 'GT' then b_ptKH:= pvi_ptKHb(b_lp_pvi) - pvi_ptKH(b_lp_pvi);
                elsif a_pp(b_lp_pvi) = 'GP' then b_ptKH:=pvi_ptKHb(b_lp_pvi) - ROUND(pvi_ptKH(b_lp_pvi)*pvi_ptKHb(b_lp_pvi)/100,20);
                else b_ptKH:=pvi_ptKHb(b_lp_pvi);
              end if;
              b_pvi_ptKH:=b_pvi_ptKH+b_ptKH;
              b_pvi_ptKHb:=b_pvi_ptKHb+pvi_ptKHb(b_lp_pvi);
              a_pt(b_kt):=b_pvi_ptKH; a_ptB(b_kt):=b_pvi_ptKHb;
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
for b_lp in 1..a_ma.count loop
    a_m(b_lp):='K';
end loop;
for b_lp_bs in 1..bs_ma.count loop
    b_kt:=b_kt+1; b_ktL:=b_kt;
    a_m(b_kt):=bs_m(b_lp_bs); a_nv(b_kt):='M'; a_tien(b_kt):=bs_tien(b_lp_bs);
    select count(*) into b_i1 from bh_phh_phi_dk where so_id=b_so_idP and ma=bs_ma(b_lp_bs) and nv='M';
    if b_i1=1 then
        select ma,ten,tc,ma_ct,'T',lkeM,lkeP,lkeB,luy,ktru,ma_dk,ma_dkC,lh_nv,t_suat,cap,lbh into
            a_ma(b_kt),a_ten(b_kt),a_tc(b_kt),a_ma_ct(b_kt),a_kieu(b_kt),
            a_lkeM(b_kt),a_lkeP(b_kt),a_lkeB(b_kt),a_luy(b_kt),a_ktru(b_kt),
            a_ma_dk(b_kt),a_ma_dkC(b_kt),a_lh_nv(b_kt),a_t_suat(b_kt),a_cap(b_kt),a_lbh(b_kt)
            from bh_phh_phi_dk where so_id=b_so_idP and ma=bs_ma(b_lp_bs);
        if a_tien(b_kt)=0 and nvl(a_lkeM(b_kt),' ')='C' then
            b_i1:=FKH_ARR_VTRI(a_ma_dk,a_ma_dkC(b_kt));
            if b_i1>0 then a_tien(b_kt):=a_tien(b_i1); end if;
        end if;
    else
        select count(*) into b_i1 from bh_ma_dkbs where ma=bs_ma(b_lp_bs) and FBH_MA_NV_CO(nv,'PHH')='C';
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
    b_tien:=a_tien(b_kt);
    if a_pt(b_kt)>100 then a_phi(b_kt):=ROUND(a_pt(b_kt)*b_kho*b_tg,b_tp);
    elsif b_tien<>0 and a_pt(b_kt)<>0 then a_phi(b_kt):=ROUND(b_kho*b_tg*b_tien*a_pt(b_kt)/ 100, b_tp);
    else a_phi(b_kt):=0;
    end if;
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
            if a_phi(b_lp1)=0 then continue; end if;
            a_pt(b_lp1):=dk_pt(b_lp); b_i1:=b_i1-a_phi(b_lp1);
        end if;
    end loop;
    if b_i1<>0 then a_phi(b_iX):=a_phi(b_iX)+b_i1; end if;
end loop;
if b_pt_hang<>0 then
   FBH_PHH_PHI_HH(b_tp,b_pt_hang,a_ma,a_ma_ct,a_kieu,a_tien,a_pt,a_phi,b_loi);
   if b_loi is not null then return; end if;
end if;
if b_c_thue<>'C' then
    for b_lp in 1..a_ma.count loop a_thue(b_lp):=0; end loop;
else
    for b_lp in 1..a_ma.count loop a_thue(b_lp):=round(a_phi(b_lp)*a_t_suat(b_lp)/100,b_tp); end loop;
end if;
-- SDBS
if b_so_idG<>0 then
    b_so_idD:=FBH_PHH_SO_IDd(b_ma_dvi,b_so_idG);
    select so_id,ngay_cap bulk collect into a_so_idG,a_ngay_capG from bh_phh where
        ma_dvi=b_ma_dvi and so_id_d=b_so_idD and so_id<=b_so_idG and ngay_hl<b_ngay_cap order by so_id;
    if a_so_idG.count<>0 then
        b_hs:=(1+FKH_KHO_NGSO(b_ngay_cap,b_ngay_kt,'K'))/FKH_KHO_NGSO(b_ngay_hl,b_ngay_kt);
        for b_lp in 1..a_ma.count loop
            a_phi(b_lp):=round(a_phi(b_lp)*b_hs,b_tp); a_phiX(b_lp):=0;
            a_phiB(b_lp):=round(a_phiB(b_lp)*b_hs,b_tp);
        end loop;
        PKH_ARR_XEP_N(a_so_idG);
        for b_lpG in 1..a_so_idG.count loop
            select nvl(min(ngay_hl),0),nvl(min(ngay_kt),0) bulk collect into a_ngay_hlG,a_ngay_ktG from bh_phh_dvi where 
                ma_dvi=b_ma_dvi and so_id=a_so_idG(b_lpG) and so_id_dt=b_so_id_dt;
        end loop;
        b_capD:=0;
        for b_lpG in 1..a_so_idG.count loop
            if a_ngay_hlG(b_lpG)=0 then continue; end if;
            if b_capD=0 then b_capD:=a_ngay_hlG(b_lpG); else b_capD:=a_ngay_capG(b_lpG); end if;
            if b_lpG=a_so_idG.count then b_capC:=b_ngay_cap; else b_capC:=a_ngay_capG(b_lpG+1); end if;
            b_hs:=FKH_KHO_NGSO(b_capD,b_capC)/FKH_KHO_NGSO(b_capD,a_ngay_ktG(b_lpG));
            select ma,phi,phiB bulk collect into dk_maG,dk_phiG,dk_phiB from bh_phh_dk where
                ma_dvi=b_ma_dvi and so_id=a_so_idG(b_lpG) and so_id_dt=b_so_id_dt and tc='C';
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
--
b_lenh:=FKH_JS_LENH('ma,ten,tien,pt,phi,thue,ktru,lh_nv,t_suat,luy,dkh');
EXECUTE IMMEDIATE b_lenh bulk collect into a_maM,a_tenM,a_tienM,a_ptM,a_phiM,a_thueM,
    a_ktruM,a_lh_nvM,a_t_suatM,a_luyM,a_dkHM using dt_dkth;
for b_lp in 1..a_maM.count loop
    a_mM(b_lp):='K';
end loop;
if trim(dt_dkH) is not null then
    if a_maM.count=0 then
        EXECUTE IMMEDIATE b_lenh bulk collect into
            a_maM,a_tenM,a_tienM,a_ptM,a_phiM,a_thueM,a_ktruM,a_lh_nvM,a_t_suatM,a_luyM,a_dkHM using dt_dkH;
        for b_lp in 1..a_maM.count loop
            a_mM(b_lp):='C'; a_luyM(b_lp):=nvl(trim(a_luyM(b_lp)),'C');
            a_dkHM(b_lp):=nvl(trim(a_dkHM(b_lp)),'C'); a_ktruM(b_lp):=nvl(trim(a_ktruM(b_lp)),'G');
        end loop;
    else
        EXECUTE IMMEDIATE b_lenh bulk collect into
            a_maMH,a_tenMH,a_tienMH,a_ptMH,a_phiMH,a_thueMH,a_ktruMH,a_lh_nvMH,a_t_suatMH,a_luyMH,a_dkHMH using dt_dkH;
        for b_lp in 1..a_maMH.count loop
            b_i1:=FKH_ARR_VTRI(a_maM,a_maMH(b_lp));
            if b_i1=0 or nvl(trim(a_dkHM(b_i1)),'K')<>'K' then
                if b_i1=0 then b_i1:=a_maM.count+1; end if;
                a_mM(b_i1):='C';
                a_maM(b_i1):=a_maMH(b_lp); a_tenM(b_i1):=a_tenMH(b_lp);
                a_tienM(b_i1):=a_tienMH(b_lp); a_ptM(b_i1):=a_ptMH(b_lp);
                a_phiM(b_i1):=a_phiMH(b_lp); a_thueM(b_i1):=a_thueMH(b_lp);
                a_ktruM(b_i1):=nvl(trim(a_ktruMH(b_lp)),'G'); a_luyM(b_i1):=nvl(trim(a_luyMH(b_lp)),'C');
                a_lh_nvM(b_i1):=a_lh_nvMH(b_lp); a_t_suatM(b_i1):=a_t_suatMH(b_lp);
                a_dkHM(b_i1):=nvl(trim(a_dkHMH(b_lp)),'C');
            end if;
        end loop;
    end if;
end if;

b_i1:=a_maM.count;
for b_lp in reverse 1..b_i1 loop
    if a_dkHM(b_lp)='K' then
        a_maM.delete(b_lp); a_tenM.delete(b_lp); a_tienM.delete(b_lp); a_ptM.delete(b_lp);
        a_phiM.delete(b_lp); a_thueM.delete(b_lp); a_ktruM.delete(b_lp); a_lh_nvM.delete(b_lp);
        a_t_suatM.delete(b_lp); a_luyM.delete(b_lp); a_dkHM.delete(b_lp);
    end if;
end loop;
b_kt:=a_ma.count;
for b_lp in 1..a_maM.count loop
    b_kt:=b_kt+1; a_m(b_kt):=a_mM(b_lp);
    a_ma(b_kt):=a_maM(b_lp); a_ten(b_kt):=a_tenM(b_lp);
    a_ktru(b_kt):=nvl(trim(a_ktruM(b_lp)),'G'); a_luy(b_kt):=a_luyM(b_lp);
    a_lh_nv(b_kt):=a_lh_nvM(b_lp); a_t_suat(b_kt):=a_t_suatM(b_lp);
    a_tien(b_kt):=a_tienM(b_lp); a_pt(b_kt):=a_ptM(b_lp);
    a_phi(b_kt):=a_phiM(b_lp); a_thue(b_kt):=a_thueM(b_lp);
    a_ttoan(b_kt):=a_phiM(b_lp)+a_thueM(b_lp);
    a_tc(b_kt):='C'; a_ma_ct(b_kt):=' '; a_kieu(b_kt):='T';
    a_lkeM(b_kt):='G'; a_lkeP(b_kt):='G'; a_lkeB(b_kt):='G';
    a_ma_dk(b_kt):=a_maM(b_lp); a_ma_dkC(b_kt):=' ';
    a_cap(b_kt):=1; a_lbh(b_kt):='KH'; a_nv(b_kt):='T';
    a_ptB(b_kt):=0; a_phiB(b_kt):=0;
    a_pvi_ma(b_kt):=' '; a_pvi_tc(b_kt):='C'; a_pvi_ktru(b_kt):=' ';
end loop;
if b_c_thue<>'C' then
    for b_lp in 1..a_ma.count loop a_thue(b_lp):=0; end loop;
else
    for b_lp in 1..a_ma.count loop a_thue(b_lp):=round(a_phi(b_lp)*a_t_suat(b_lp)/100,b_tp); end loop;
end if;
FBH_PHHG_PHIb(b_tp,a_ma,a_ma_ct,a_lkeP,a_cap,a_phi,a_thue,a_ttoan,b_loi);
if b_loi is not null then return; end if;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_PHHH_PHI:loi'; end if;
end;
/
create or replace procedure PBH_PHHH_PHI(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(3000); b_i1 number; b_lenh varchar2(2000);
    dt_ctH clob; dt_dkH clob; dt_dkbsH clob;
    dt_ct clob; dt_dk clob; dt_dkbs clob; dt_dkth clob; dt_pvi clob;
    
    b_so_idP number; b_kieu_hd varchar2(1); b_so_hd_g varchar2(20);
    b_ma_sp varchar2(10); b_cdich varchar2(10); b_goi varchar2(10); 
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tygia number; b_c_thue varchar2(1);
    b_ngay_hlH number; b_ngay_ktH number; b_so_id_dt number; b_gcnG varchar2(20);
    b_ngay_hl number; b_ngay_kt number; b_ngay_cap number; b_txt clob;
    b_gio_hlH varchar2(10); b_gio_ktH varchar2(10); b_gio_hl varchar2(10); b_gio_kt varchar2(10);

    a_thay pht_type.a_num;
    a_ma pht_type.a_var; a_ten pht_type.a_nvar; a_tc pht_type.a_var;
    a_ma_ct pht_type.a_var; a_kieu pht_type.a_var; 
    a_lkeM pht_type.a_var; a_lkeP pht_type.a_var; a_lkeB pht_type.a_var;
    a_luy pht_type.a_var; a_ktru pht_type.a_var; 
    a_ma_dk pht_type.a_var; a_ma_dkC pht_type.a_var; a_lh_nv pht_type.a_var; a_t_suat pht_type.a_num; 
    a_cap pht_type.a_num; a_lbh pht_type.a_var; a_nv pht_type.a_var; 
    a_tien pht_type.a_num; a_pt pht_type.a_num; a_phi pht_type.a_num;
    a_thue pht_type.a_num; a_ttoan pht_type.a_num;
    a_ptB pht_type.a_num; a_phiB pht_type.a_num;
    a_pvi_ma pht_type.a_var; a_pvi_tc pht_type.a_var; a_pvi_ktru pht_type.a_var; a_m pht_type.a_var;
    
begin
-- Dan - Tinh phi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ctH,dt_dkH,dt_dkbsH,dt_ct,dt_dk,dt_dkbs,dt_dkth,dt_pvi');
EXECUTE IMMEDIATE b_lenh into dt_ctH,dt_dkH,dt_dkbsH,dt_ct,dt_dk,dt_dkbs,dt_dkth,dt_pvi using b_oraIn;
FKH_JS_NULL(dt_ctH); FKH_JSa_NULL(dt_dkH); FKH_JSa_NULL(dt_dkbsH);
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_dkbs); FKH_JSa_NULL(dt_dkth); FKH_JSa_NULL(dt_pvi);
b_lenh:=FKH_JS_LENH('kieu_hd,so_hd_g,ma_sp,cdich,goi,nt_tien,nt_phi,tygia,c_thue,ngay_hl,ngay_kt,ngay_cap,gio_hl,gio_kt');
EXECUTE IMMEDIATE b_lenh into b_kieu_hd,b_so_hd_g,b_ma_sp,b_cdich,b_goi,
    b_nt_tien,b_nt_phi,b_tygia,b_c_thue,b_ngay_hlH,b_ngay_ktH,b_ngay_cap,b_gio_hlH,b_gio_ktH using dt_ctH;
b_lenh:=FKH_JS_LENH('so_id_dt,gcn_g,ngay_hl,ngay_kt,gio_hl,gio_kt');
EXECUTE IMMEDIATE b_lenh into b_so_id_dt,b_gcnG,b_ngay_hl,b_ngay_kt,b_gio_hl,b_gio_kt using dt_ct;
--nam: check thoi han hieu luc cua hop dong so voi GCN
b_gio_hl:=to_number(replace(b_gio_hl,'|','')); b_gio_kt:=to_number(replace(b_gio_kt,'|',''));
b_gio_hlH:=to_number(replace(b_gio_hlH,'|','')); b_gio_ktH:=to_number(replace(b_gio_ktH,'|',''));
b_loi:='loi:Sai ngay hieu luc:loi';
if b_ngay_hl in(0,30000101) or b_ngay_kt in(0,30000101) or
    b_ngay_hl<b_ngay_hlH or b_ngay_hl>b_ngay_kt or b_ngay_kt>b_ngay_ktH then raise PROGRAM_ERROR;
elsif b_ngay_hl=b_ngay_hlH and b_ngay_kt=b_ngay_ktH and (b_gio_hl<b_gio_hlH or b_gio_kt>b_gio_ktH) then raise PROGRAM_ERROR;
elsif b_ngay_hl=b_ngay_kt and b_gio_hl>b_gio_kt then raise PROGRAM_ERROR;
end if;
if b_so_id_dt>100000 and b_kieu_hd in('S','B') and b_gcnG<>' ' then
    select count(*) into b_i1 from bh_phh_dvi where ma_dvi=b_ma_dvi and so_id_dt=b_so_id_dt and gcn=b_gcnG;
    if b_i1=0 then b_loi:='loi:GCN: '||b_gcnG||' da xoa:loi'; raise PROGRAM_ERROR; end if;
end if;
a_thay(1):=b_tygia; a_thay(2):=b_ngay_hl; a_thay(3):=b_ngay_kt; a_thay(4):=b_ngay_cap;
PKH_JS_THAYan(dt_ct,'tygia,ngay_hl,ngay_kt,ngay_cap',a_thay);
b_lenh:='H,'||b_so_hd_g||','||b_ma_sp||','||b_cdich||','||b_goi||','||b_nt_tien||','||b_nt_phi||','||b_c_thue;
PKH_JS_THAYa(dt_ct,'nhom,so_hd_g,ma_sp,cdich,goi,nt_tien,nt_phi,c_thue',b_lenh);
FBH_PHHH_PHI(b_ma_dvi,dt_ct,dt_dkH,dt_dkbsH,dt_dk,dt_dkbs,dt_dkth,dt_pvi,b_so_idP,
    a_ma,a_ten,a_tc,a_ma_ct,a_kieu,a_lkeM,a_lkeP,a_lkeB,a_luy,a_ktru,a_ma_dk,a_ma_dkC,a_lh_nv,a_t_suat,
    a_cap,a_lbh,a_nv,a_tien,a_pt,a_phi,a_thue,a_ttoan,a_ptB,a_phiB,a_pvi_ma,a_pvi_tc,a_pvi_ktru,a_m,b_loi);
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
    'pvi_ma'  value a_pvi_ma(b_lp),'pvi_tc' value a_pvi_tc(b_lp),
    'pvi_ktru' value a_pvi_ktru(b_lp) returning clob) into b_txt from dual;
    if b_lp>1 then b_oraOut:=b_oraOut||','; end if;
    b_oraOut:=b_oraOut||b_txt;
end loop;
if b_oraOut is not null then b_oraOut:='['||b_oraOut||']'; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHHH_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngay number:=PKH_NG_CSO(sysdate);
    cs_sp clob; cs_cdich clob; cs_goi clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten returning clob) into cs_sp from
    bh_phh_sp a,(select distinct ma_sp from bh_phh_phi where nhom in('H','T') and ngay_bd<=b_ngay and ngay_kt>b_ngay) b
    where a.ma=b.ma_sp and FBH_PHH_SP_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten returning clob) into cs_cdich from
    bh_ma_cdich a,(select distinct cdich from bh_phh_phi where nhom in('H','T') and ngay_bd<=b_ngay and ngay_kt>b_ngay) b
    where a.ma=b.cdich and FBH_MA_NV_CO(a.nv,'PHH')='C' and FBH_MA_CDICH_HAN(a.ma)='C';
select JSON_ARRAYAGG(json_object(a.ma,a.ten) order by a.ten returning clob) into cs_goi from
    bh_phh_goi a,(select distinct goi from bh_phh_phi where nhom in('H','T') and ngay_bd<=b_ngay and ngay_kt>b_ngay) b
    where a.ma=b.goi and FBH_PHH_GOI_HAN(a.ma)='C';
select json_object('cs_sp' value cs_sp,'cs_cdich' value cs_cdich,'cs_goi' value cs_goi returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHHH_MOd(
     b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_ngay number:=PKH_NG_CSO(sysdate);
    cs_khd clob; cs_kbt clob; cs_ttt clob;
begin
-- Dan - Tham so mo form
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_khd
    from bh_kh_ttt where ps='KHD' and nv='PHH';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_kbt
    from bh_kh_ttt where ps='KBT' and nv='PHH';
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into cs_ttt
    from bh_kh_ttt where ps='HD' and nv='PHH';
select json_object('cs_khd' value cs_khd,'cs_kbt' value cs_kbt, 'cs_ttt' value cs_ttt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHHH_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number;
    dt_ct clob; dt_dk clob:=''; dt_dkbs clob:=''; dt_lt clob:=''; dt_hk clob:=''; dt_them clob:='';
    ds_ct clob; ds_dk clob; ds_dkbs clob:=''; ds_pvi clob; ds_lt clob:='';
    ds_dkth clob:=''; ds_kbt clob:=''; ds_ttt clob:=''; dt_kytt clob; dt_txt clob;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','PHH','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
select json_object(so_hd,ma_kh,so_dt) into dt_ct from bh_phh where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ngay,tien) order by ngay) into dt_kytt from bh_phh_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select count(*) into b_i1 from bh_phh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dk';
if b_i1=1 then
    select txt into dt_dk from bh_phh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dk';
end if;
select count(*) into b_i1 from bh_phh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dkbs';
if b_i1=1 then
    select txt into dt_dkbs from bh_phh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dkbs';
end if;
select count(*) into b_i1 from bh_phh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_lt';
if b_i1=1 then
    select txt into dt_lt from bh_phh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_lt';
end if;
select count(*) into b_i1 from bh_phh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
if b_i1=1 then
    select txt into dt_hk from bh_phh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
end if;
select txt into ds_ct from bh_phh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ct';
select txt into ds_dk from bh_phh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_dk';
select txt into ds_pvi from bh_phh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_pvi';
select count(*) into b_i1 from bh_phh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_dkbs';
if b_i1=1 then
    select txt into ds_dkbs from bh_phh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_dkbs';
end if;
select count(*) into b_i1 from bh_phh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_lt';
if b_i1=1 then
    select txt into ds_lt from bh_phh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_lt';
end if;
select count(*) into b_i1 from bh_phh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_dkth';
if b_i1=1 then
    select txt into ds_dkth from bh_phh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_dkth';
end if;
select count(*) into b_i1 from bh_phh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_kbt';
if b_i1=1 then
    select txt into ds_kbt from bh_phh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_kbt';
end if;
select count(*) into b_i1 from bh_phh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ttt';
if b_i1=1 then
    select txt into ds_ttt from bh_phh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='ds_ttt';
end if;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_phh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'ds_ct' value ds_ct,
    'dt_dk' value dt_dk,'dt_dkbs' value dt_dkbs,'dt_lt' value dt_lt,'dt_hk' value dt_hk,
    'ds_dk' value ds_dk,'ds_pvi' value ds_pvi,'ds_dkbs' value ds_dkbs,
    'ds_lt' value ds_lt,'ds_dkth' value ds_dkth,
    'ds_kbt' value ds_kbt,'ds_ttt' value ds_ttt,'dt_kytt' value dt_kytt,
    'dt_ct' value dt_ct,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHHH_TESTd(
    dt_ctH clob,dt_dkH clob,dt_dkbsH clob,
    dt_ct in out clob,dt_dk clob,dt_dkbs clob,dt_dkth clob,dt_pvi clob,
    b_ma_dvi varchar2,b_nsd varchar2,b_ttrang varchar2,b_kieu_hd varchar2,b_ma_sp varchar2,b_cdich varchar2,b_goi varchar2,
    b_nt_tien varchar2,b_nt_phi varchar2,b_tygia number,b_c_thue varchar2,b_ngay_capH number,
    b_so_id_dt out number,b_kieu_gcn out varchar2,b_gcn out varchar2,b_gcnG out varchar2,
    b_dvi out nvarchar2,b_ddiem out nvarchar2,b_kvuc out varchar2,b_tdx out number,b_tdy out number,b_bk out number,
    b_ma_dt out varchar2,b_lvuc out nvarchar2,b_mrr out varchar2,b_cdt out varchar2,b_dk_lut out varchar2,b_hs_lut out number,
    b_ngay_hl out number,b_ngay_kt out number,b_ngay_cap out number,b_tlbt out number,b_so_idP out number,
    dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,dk_tc out pht_type.a_var,
    dk_ma_ct out pht_type.a_var,dk_kieu out pht_type.a_var,
    dk_lkeM out pht_type.a_var,dk_lkeP out pht_type.a_var,dk_lkeB out pht_type.a_var,
    dk_luy out pht_type.a_var,dk_ktru out pht_type.a_var,
    dk_ma_dk out pht_type.a_var,dk_ma_dkC out pht_type.a_var,dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,
    dk_cap out pht_type.a_num,dk_lbh out pht_type.a_var,dk_nv out pht_type.a_var,
    dk_tien out pht_type.a_num,dk_pt out pht_type.a_num,dk_phi out pht_type.a_num,
    dk_thue out pht_type.a_num,dk_ttoan out pht_type.a_num,
    dk_ptB out pht_type.a_num,dk_phiB out pht_type.a_num,
    dk_pvi_ma out pht_type.a_var,dk_pvi_tc out pht_type.a_var,dk_pvi_ktru out pht_type.a_var,
    dk_m out pht_type.a_var,b_loi out varchar2)
AS
    b_i1 number; b_lenh varchar2(2000); b_so_idPn number; b_gio_hl varchar2(50); b_gio_kt varchar2(50);
    b_cdtC varchar2(1); b_cdtF varchar2(1); b_cdtX varchar2(1); b_so_hdG varchar2(20);
    b_txt clob; a_thay pht_type.a_num;
begin
-- Dan - Nhap
b_lenh:=FKH_JS_LENH('so_id_dt,gcn,gcn_g,ngay_hl,ngay_kt,dvi,ddiem,tdx,tdy,bk,ma_dt,lvuc,mrr,dk_lut,hs_lut,tlbt,so_idp,gio_hl,gio_kt,cdtc,cdtf,cdtx');
EXECUTE IMMEDIATE b_lenh into
    b_so_id_dt,b_gcn,b_gcnG,b_ngay_hl,b_ngay_kt,b_dvi,b_ddiem,b_tdx,b_tdy,b_bk,
    b_ma_dt,b_lvuc,b_mrr,b_dk_lut,b_hs_lut,b_tlbt,b_so_idPn,b_gio_hl,b_gio_kt,b_cdtC,b_cdtF,b_cdtX using dt_ct;
if b_dvi=' ' or b_ddiem=' ' then b_loi:='loi:Nhap dia diem, dia chi bao hiem:loi'; return; end if;
if nvl(b_tdx,0)=0 then b_loi:='loi:Chua xac dinh toa do dia diem '||b_dvi||':loi'; return; end if;
b_kvuc:=' ';
if b_dk_lut=' ' then b_dk_lut:='K'; end if;
if b_bk=0 then b_bk:=25; end if;
--nam check han ma doi tuong
b_loi:='loi:Sai ma doi tuong '||b_ma_dt||':loi';
b_ma_dt:=PKH_MA_TENl(b_ma_dt);
if FBH_PHH_DTUONG_HAN(b_ma_dt,'T')<>'C' then return; end if;
b_loi:='loi:Sai muc rui ro '||b_mrr||':loi';
b_mrr:=PKH_MA_TENl(b_mrr);
if FBH_PHH_MRR_HAN(b_mrr)<>'C' then return; end if;
b_kieu_gcn:='G'; b_ngay_cap:=b_ngay_capH;
if b_so_id_dt<100000 then
    PHT_ID_MOI(b_so_id_dt,b_loi);
    if b_loi is not null then return; end if;
    b_gcn:=substr(to_char(b_so_id_dt),3); b_gcnG:=' ';
elsif b_kieu_hd in('S','B') and b_gcnG<>' ' then
    select count(*) into b_i1 from bh_phh_dvi where ma_dvi=b_ma_dvi and so_id_dt=b_so_id_dt and gcn=b_gcnG;
    if b_i1=0 then b_loi:='loi:GCN '||b_gcnG||' da xoa:loi'; return; end if;
    b_kieu_gcn:=b_kieu_hd;
    if b_gcn=b_gcnG then b_gcn:=' '; end if;
end if;
if b_gcn=' ' or instr(b_gcn,'.')=2 then
    b_gcn:=substr(to_char(b_so_id_dt),3);
    if b_kieu_gcn<>'G' then
        select count(*) into b_i1 from bh_phh_dvi where ma_dvi=b_ma_dvi and so_id_dt=b_so_id_dt and kieu_gcn=b_kieu_hd;
        if(b_i1>0) then
           select max(REGEXP_SUBSTR(gcn, 'B([0-9]+)', 1, 1, NULL, 1)) into b_i1 from bh_phh_dvi where ma_dvi=b_ma_dvi and so_id_dt=b_so_id_dt and kieu_gcn=b_kieu_hd;
        end if;
        b_gcn:=b_gcn||'/'||b_kieu_hd||to_char(b_i1+1);
    end if;
else
    select nvl(max(ngay_cap),b_ngay_capH) into b_ngay_cap from bh_phh_dvi where ma_dvi=b_ma_dvi and so_id_dt=b_so_id_dt and gcn=b_gcn;
end if;
if trim(b_cdtC) is null then
    b_cdt:=' ';
else
    if b_cdtC='K' then PKH_GHEP(b_cdt,'C',''); end if;
    if b_cdtF='K' then PKH_GHEP(b_cdt,'F',''); end if;
    if b_cdtX='K' then PKH_GHEP(b_cdt,'X',''); end if;
    b_cdt:=nvl(trim(b_cdt),'K');
end if;
PKH_JS_THAYa(dt_ct,'gcn,gcn_g,cdt',b_gcn||'|'||b_gcnG||'|'||b_cdt,'|');
a_thay(1):=b_so_id_dt; a_thay(2):=b_ngay_hl; a_thay(3):=b_ngay_kt; a_thay(4):=b_ngay_cap; a_thay(5):=b_tygia; 
PKH_JS_THAYan(dt_ct,'so_id_dt,ngay_hl,ngay_kt,ngay_cap,tygia',a_thay);
b_txt:=dt_ct; b_so_hdG:=FKH_JS_GTRIs(dt_ctH,'so_hd_g');
b_lenh:='H,'||b_so_hdG||','||b_ma_sp||','||b_cdich||','||b_goi||','||b_nt_tien||','||b_nt_phi||','||b_c_thue;
PKH_JS_THAYa(b_txt,'nhom,so_hd_g,ma_sp,cdich,goi,nt_tien,nt_phi,c_thue',b_lenh);
PKH_JS_THAYn(b_txt,'tygia',b_tygia); 
FBH_PHHH_PHI(b_ma_dvi,b_txt,dt_dkH,dt_dkbsH,dt_dk,dt_dkbs,dt_dkth,dt_pvi,b_so_idP,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy,dk_ktru,dk_ma_dk,dk_ma_dkC,
    dk_lh_nv,dk_t_suat,dk_cap,dk_lbh,dk_nv,dk_tien,dk_pt,dk_phi,dk_thue,dk_ttoan,dk_ptB,dk_phiB,
    dk_pvi_ma,dk_pvi_tc,dk_pvi_ktru,dk_m,b_loi);
if b_loi is not null then return; end if;
if b_so_idP<>b_so_idPn then
    b_loi:='loi:Thong tin xac dinh bieu phi '||b_dvi||' bi thay doi:loi'; return;
end if;
PKH_JS_THAYn(dt_ct,'tdx',b_tdx); PKH_JS_THAYn(dt_ct,'tdy',b_tdy);
PKH_JS_THAYn(dt_ct,'so_idp',b_so_idP);
if b_ttrang in('T','D') then
    select count(*) into b_i1 from bh_phh_phi_txt where so_id=b_so_idP and loai='dt_khd';
    if b_i1=1 then
        select txt into b_txt from bh_phh_phi_txt where so_id=b_so_idP and loai='dt_khd';
        b_txt:=FKH_JS_BONH(b_txt);
        PBH_PHHH_KHD(dt_ctH,dt_ct,dt_dk,dt_dkbs,dt_pvi,b_txt,b_loi);
        if b_loi is not null then return; end if;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_PHHH_TESTd:loi'; end if;
end;
/
create or replace procedure PBH_PHHH_TESTr(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_idG number,
    dt_ct in out clob,dt_dkH clob,dt_dkbsH clob,
    ds_ct in out clob,ds_dk in out clob,ds_dkbs in out clob,ds_pvi in out clob,
    ds_lt in out clob,ds_dkth in out clob,ds_kbt clob,
    b_ma_sp out varchar2,b_cdich out varchar2,b_goi out varchar2,

    dvi_so_id out pht_type.a_num,dvi_kieu_gcn out pht_type.a_var,dvi_gcn out pht_type.a_var,dvi_gcnG out pht_type.a_var,
    dvi_dvi out pht_type.a_nvar,dvi_ma_dt out pht_type.a_var,dvi_kvuc out pht_type.a_var,
    dvi_lvuc out pht_type.a_nvar,dvi_ddiem out pht_type.a_nvar,
    dvi_dk_lut out pht_type.a_var,dvi_hs_lut out pht_type.a_num,
    dvi_mrr out pht_type.a_var,dvi_cdt out pht_type.a_var,
    dvi_tdx out pht_type.a_num,dvi_tdy out pht_type.a_num,dvi_bk out pht_type.a_num,
    dvi_gio_hl out pht_type.a_var,dvi_ngay_hl out pht_type.a_num,
    dvi_gio_kt out pht_type.a_var,dvi_ngay_kt out pht_type.a_num,dvi_ngay_cap out pht_type.a_num,
    dvi_phi out pht_type.a_num,dvi_thue out pht_type.a_num,dvi_ttoan out pht_type.a_num,
    dvi_giam out pht_type.a_num,dvi_tlbt out pht_type.a_num,dvi_so_idP out pht_type.a_num,

    dk_so_id out pht_type.a_num,dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,dk_tc out pht_type.a_var,
    dk_ma_ct out pht_type.a_var,dk_kieu out pht_type.a_var,
    dk_lkeM out pht_type.a_var,dk_lkeP out pht_type.a_var,dk_lkeB out pht_type.a_var,
    dk_luy out pht_type.a_var,dk_ktru out pht_type.a_var,
    dk_ma_dk out pht_type.a_var,dk_ma_dkC out pht_type.a_var,dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,
    dk_cap out pht_type.a_num,dk_lbh out pht_type.a_var,dk_nv out pht_type.a_var,
    dk_tien out pht_type.a_num,dk_pt out pht_type.a_num,dk_phi out pht_type.a_num,
    dk_thue out pht_type.a_num,dk_ttoan out pht_type.a_num,
    dk_ptB out pht_type.a_num,dk_phiB out pht_type.a_num,dk_ptG out pht_type.a_num,dk_phiG out pht_type.a_num,
    dk_pvi_ma out pht_type.a_var,dk_pvi_tc out pht_type.a_var,dk_pvi_ktru out pht_type.a_var,
    lt_so_id out pht_type.a_num,lt_lt out pht_type.a_clob,lt_kbt out pht_type.a_clob,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_txt clob;
    b_c_thue varchar2(1); b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tp number:=0;
    b_phi number; b_thue number; b_ttoan number; b_giam number;
    b_thueH number; b_ttoanH number; b_tlbt number;

    b_kieu_hd varchar2(1); b_ttrang varchar2(1); b_tygia number;
    b_gio_hl varchar2(50); b_ngay_hlH number; b_gio_kt varchar2(50); b_ngay_ktH number; b_ngay_capH number;
    b_loai_khH varchar2(1); b_cmtH varchar2(20); b_mobiH varchar2(20); b_emailH varchar2(100);
    b_tenH nvarchar2(500); b_dchiH nvarchar2(500); b_ma_khH varchar2(20);

    b_kt_dk number:=0;

    b_so_id_dt number; b_kieu_gcn varchar2(1); b_gcn varchar2(20); b_gcnG varchar2(20);
    b_dvi nvarchar2(500); b_ddiem nvarchar2(500); b_kvuc varchar2(500); b_tdx number; b_tdy number; b_bk number; 
    b_ma_dt varchar2(500); b_lvuc nvarchar2(500); b_mrr varchar2(500);
    b_cdt varchar2(10); b_dk_lut varchar2(1); b_hs_lut number;
    b_ngay_hl number; b_ngay_kt number; b_ngay_cap number; b_so_idP number;

    a_ma pht_type.a_var; a_ten pht_type.a_nvar; a_tc pht_type.a_var;
    a_ma_ct pht_type.a_var; a_kieu pht_type.a_var; 
    a_lkeM pht_type.a_var; a_lkeP pht_type.a_var; a_lkeB pht_type.a_var;
    a_luy pht_type.a_var; a_ktru pht_type.a_var; 
    a_ma_dk pht_type.a_var; a_ma_dkC pht_type.a_var; a_lh_nv pht_type.a_var; a_t_suat pht_type.a_num; 
    a_cap pht_type.a_num; a_lbh pht_type.a_var; a_nv pht_type.a_var; 
    a_tien pht_type.a_num; a_pt pht_type.a_num; a_phi pht_type.a_num; 
    a_thue pht_type.a_num; a_ttoan pht_type.a_num; 
    a_ptB pht_type.a_num; a_phiB pht_type.a_num;
    a_pvi_ma pht_type.a_var; a_pvi_tc pht_type.a_var; a_pvi_ktru pht_type.a_var;
    a_m pht_type.a_var; dk_m pht_type.a_var;
    a_maM pht_type.a_var; a_phiM pht_type.a_num; a_thueM pht_type.a_num;
    
    a_ds_ct pht_type.a_clob; a_ds_dk pht_type.a_clob;
    a_ds_dkbs pht_type.a_clob; a_ds_dkth pht_type.a_clob;
    a_ds_pvi pht_type.a_clob; a_ds_lt pht_type.a_clob; a_ds_kbt pht_type.a_clob;
begin
-- Dan - Nhap
b_lenh:=FKH_JS_LENH('ttrang,kieu_hd,gio_hl,ngay_hl,gio_kt,ngay_kt,ngay_cap,
    ma_sp,cdich,goi,thue,ttoan,nt_tien,nt_phi,tygia,c_thue,loai_khh,cmth,mobih,emailh,tenh,dchih');
EXECUTE IMMEDIATE b_lenh into b_ttrang,b_kieu_hd,b_gio_hl,b_ngay_hlH,b_gio_kt,b_ngay_ktH,b_ngay_capH,b_ma_sp,b_cdich,b_goi,
    b_thueH,b_ttoanH,b_nt_tien,b_nt_phi,b_tygia,b_c_thue,b_loai_khH,b_cmtH,b_mobiH,b_emailH,b_tenH,b_dchiH using dt_ct;
if b_ma_sp<>' ' and FBH_PHH_SP_HAN(b_ma_sp)<>'C' then b_loi:='loi:Het han ma san pham:loi'; return; end if;
if b_cdich<>' ' and FBH_MA_CDICH_HAN(b_cdich)<>'C' then b_loi:='loi:Het han ma chien dich:loi'; return; end if;
if b_goi<>' ' and FBH_PHH_GOI_HAN(b_GOI)<>'C' then b_loi:='loi:Het han ma goi:loi'; return; end if;
b_c_thue:=nvl(trim(b_c_thue),'C');
if nvl(trim(b_nt_phi),'VND')<>'VND' then b_tp:=2; end if;
b_lenh:=FKH_JS_LENHc('');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_ct using ds_ct;
if a_ds_ct.count=0 then b_loi:='loi:Nhap danh sach:loi'; return; end if;
b_lenh:=FKH_JS_LENHc('');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_dk using ds_dk;
EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_dkbs using ds_dkbs;
EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_dkth using ds_dkth;
EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_pvi using ds_pvi;
EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_lt using ds_lt;
EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_kbt using ds_kbt;
   for ds_lp in 1..a_ds_ct.count loop
    FKH_JS_NULL(a_ds_ct(ds_lp)); FKH_JSa_NULL(a_ds_dk(ds_lp)); 
    if length(ds_dkbs)<>0 then FKH_JSa_NULL(a_ds_dkbs(ds_lp)); else a_ds_dkbs(ds_lp):=' '; end if;
    if length(ds_dkth)<>0 then FKH_JSa_NULL(a_ds_dkth(ds_lp)); else a_ds_dkth(ds_lp):=' '; end if;
    if length(ds_pvi)<>0 then FKH_JSa_NULL(a_ds_pvi(ds_lp)); else a_ds_pvi(ds_lp):=' '; end if;
    if length(a_ds_lt(ds_lp))<>0 then FKH_JSa_NULL(a_ds_lt(ds_lp)); else a_ds_lt(ds_lp):=' '; end if;
    if length(a_ds_kbt(ds_lp))<>0 then FKH_JSa_NULL(a_ds_kbt(ds_lp)); else a_ds_kbt(ds_lp):=' '; end if;
    PBH_PHHH_TESTd(dt_ct,dt_dkH,dt_dkbsH,
        a_ds_ct(ds_lp),a_ds_dk(ds_lp),a_ds_dkbs(ds_lp),a_ds_dkth(ds_lp),a_ds_pvi(ds_lp),
        b_ma_dvi,b_nsd,b_ttrang,b_kieu_hd,b_ma_sp,b_cdich,b_goi,b_nt_tien,
        b_nt_phi,b_tygia,b_c_thue,b_ngay_capH,
        b_so_id_dt,b_kieu_gcn,b_gcn,b_gcnG,b_dvi,b_ddiem,b_kvuc,b_tdx,b_tdy,b_bk,
        b_ma_dt,b_lvuc,b_mrr,b_cdt,b_dk_lut,b_hs_lut,b_ngay_hl,b_ngay_kt,b_ngay_cap,b_tlbt,b_so_idP,
        a_ma,a_ten,a_tc,a_ma_ct,a_kieu,a_lkeM,a_lkeP,a_lkeB,a_luy,a_ktru,a_ma_dk,a_ma_dkC,a_lh_nv,a_t_suat,
        a_cap,a_lbh,a_nv,a_tien,a_pt,a_phi,a_thue,a_ttoan,a_ptB,a_phiB,a_pvi_ma,a_pvi_tc,a_pvi_ktru,a_m,b_loi);
    if b_loi is not null then return; end if;
    dvi_so_id(ds_lp):=b_so_id_dt; dvi_kieu_gcn(ds_lp):=b_kieu_gcn; dvi_gcn(ds_lp):=b_gcn; dvi_gcnG(ds_lp):=b_gcnG; 
    dvi_dvi(ds_lp):=b_dvi; dvi_ddiem(ds_lp):=b_ddiem; dvi_ma_dt(ds_lp):=b_ma_dt; dvi_kvuc(ds_lp):=' '; 
    dvi_lvuc(ds_lp):=b_lvuc; dvi_dk_lut(ds_lp):=b_dk_lut; dvi_hs_lut(ds_lp):=b_hs_lut;
    dvi_mrr(ds_lp):=b_mrr; dvi_cdt(ds_lp):=b_cdt;
    dvi_tdx(ds_lp):=b_tdx; dvi_tdy(ds_lp):=b_tdy; dvi_bk(ds_lp):=b_bk; 
    dvi_gio_hl(ds_lp):=b_gio_hl; dvi_ngay_hl(ds_lp):=b_ngay_hl; dvi_tlbt(ds_lp):=b_tlbt; 
    dvi_gio_kt(ds_lp):=b_gio_kt; dvi_ngay_kt(ds_lp):=b_ngay_kt; dvi_ngay_cap(ds_lp):=b_ngay_cap; 
    dvi_phi(ds_lp):=b_phi; dvi_thue(ds_lp):=b_thue; dvi_ttoan(ds_lp):=b_ttoan; dvi_so_idP(ds_lp):=b_so_idP; 
    for b_lp in 1..a_ma.count loop
        b_kt_dk:=b_kt_dk+1;
        dk_so_id(b_kt_dk):=b_so_id_dt; dk_ma(b_kt_dk):=a_ma(b_lp); dk_ten(b_kt_dk):=a_ten(b_lp);
        dk_tc(b_kt_dk):=a_tc(b_lp); dk_ma_ct(b_kt_dk):=a_ma_ct(b_lp);  dk_kieu(b_kt_dk):=a_kieu(b_lp); 
        dk_lkeM(b_kt_dk):=a_lkeM(b_lp); dk_lkeP(b_kt_dk):=a_lkeP(b_lp);
        dk_lkeB(b_kt_dk):=a_lkeB(b_lp); dk_luy(b_kt_dk):=a_luy(b_lp); dk_ktru(b_kt_dk):=a_ktru(b_lp); 
        dk_ma_dk(b_kt_dk):=a_ma_dk(b_lp); dk_ma_dkC(b_kt_dk):=a_ma_dkC(b_lp);
        dk_lh_nv(b_kt_dk):=a_lh_nv(b_lp); dk_t_suat(b_kt_dk):=a_t_suat(b_lp); 
        dk_cap(b_kt_dk):=a_cap(b_lp); dk_lbh(b_kt_dk):=a_lbh(b_lp); dk_nv(b_kt_dk):=a_nv(b_lp); 
        dk_tien(b_kt_dk):=a_tien(b_lp); dk_pt(b_kt_dk):=a_pt(b_lp); dk_phi(b_kt_dk):=a_phi(b_lp); 
        dk_thue(b_kt_dk):=a_thue(b_lp); dk_ttoan(b_kt_dk):=a_ttoan(b_lp); 
        dk_ptB(b_kt_dk):=a_ptB(b_lp);  dk_phiB(b_kt_dk):=a_phiB(b_lp); 
        dk_pvi_ma(b_kt_dk):=a_pvi_ma(b_lp); dk_pvi_tc(b_kt_dk):=a_pvi_tc(b_lp);
        dk_pvi_ktru(b_kt_dk):=a_pvi_ktru(b_lp); dk_m(b_kt_dk):=a_m(b_lp); 
    end loop;
end loop;
ds_ct:=FKH_ARRc_JS(a_ds_ct);
if b_kieu_hd in('B','S') and b_so_idG<>0 then
    for r_lp in (select so_id_dt,dvi from bh_phh_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idG) loop
        if FKH_ARR_VTRI_N(dvi_so_id,r_lp.so_id_dt)=0 then b_loi:='loi:Khong xoa danh sach cu '||r_lp.dvi||':loi'; return; end if;
    end loop;
end if;
b_kt_dk:=dk_ma.count;
b_lenh:=FKH_JS_LENH('ma,phi,thue');
if trim(dt_dkH) is not null then
    EXECUTE IMMEDIATE b_lenh bulk collect into a_maM,a_phiM,a_thueM using dt_dkH;
    for b_lp in 1..a_maM.count loop
        b_i1:=0;
        for b_lp1 in 1..b_kt_dk loop
            if dk_ma(b_lp1)=a_maM(b_lp) and dk_m(b_lp1)='C' and dk_nv(b_lp1)='T' then
                b_i1:=b_i1+1;
            end if;
        end loop;
        if b_i1=0 then b_loi:='loi:Khong nhap dieu khoan them chung cho hop dong:loi'; return; end if;
        b_phi:=round(a_phiM(b_lp)/b_i1,b_tp); b_thue:=round(a_thueM(b_lp)/b_i1,b_tp);
        a_phiM(b_lp):=a_phiM(b_lp)-b_phi*(b_i1-1); a_thueM(b_lp):=a_thueM(b_lp)-b_thue*(b_i1-1);
        for b_lp1 in 1..b_kt_dk loop
            if dk_ma(b_lp1)=a_maM(b_lp) and dk_m(b_lp1)='C' and dk_nv(b_lp1)='T' then
                if b_i1<>1 then
                    dk_phi(b_lp1):=b_phi; dk_thue(b_lp1):=b_thue; b_i1:=b_i1-1;
                else
                    dk_phi(b_lp1):=a_phiM(b_lp); dk_thue(b_lp1):=a_thueM(b_lp); exit;
                end if;
            end if;
        end loop;
    end loop;
end if;
if trim(dt_dkbsH) is not null then
    EXECUTE IMMEDIATE b_lenh bulk collect into a_maM,a_phiM,a_thueM using dt_dkbsH;
    for b_lp in 1..a_maM.count loop
        b_i1:=0;
        for b_lp1 in 1..b_kt_dk loop
            if dk_ma(b_lp1)=a_maM(b_lp) and dk_m(b_lp1)='C' and dk_nv(b_lp1)='M' then b_i1:=b_i1+1; end if;
        end loop;
        if b_i1=0 then b_loi:='loi:Khong nhap dieu khoan bo sung chung cho hop dong:loi'; return; end if;
        b_phi:=round(a_phiM(b_lp)/b_i1,b_tp); b_thue:=round(a_thueM(b_lp)/b_i1,b_tp);
        a_phiM(b_lp):=a_phiM(b_lp)-b_phi*(b_i1-1); a_thueM(b_lp):=a_thueM(b_lp)-b_thue*(b_i1-1);
        for b_lp1 in 1..b_kt_dk loop
            if dk_ma(b_lp1)=a_maM(b_lp) and dk_m(b_lp1)='C' and dk_nv(b_lp1)='M' then
                if b_i1<>1 then
                    dk_phi(b_lp1):=b_phi; dk_thue(b_lp1):=b_thue; b_i1:=b_i1-1;
                else
                    dk_phi(b_lp1):=a_phiM(b_lp); dk_thue(b_lp1):=a_thueM(b_lp); exit;
                end if;
            end if;
        end loop;
    end loop;
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
for b_lp in 1..dvi_so_id.count loop
    b_phi:=0; b_thue:=0; b_giam:=0;
    for b_lp1 in 1..dk_so_id.count loop
        if dk_lh_nv(b_lp1)<>' ' and dk_so_id(b_lp1)=dvi_so_id(b_lp) then
            b_phi:=b_phi+dk_phi(b_lp1); b_thue:=b_thue+dk_thue(b_lp1); b_giam:=b_giam+dk_phiG(b_lp1);
        end if;
    end loop;
    dvi_giam(b_lp):=b_giam; dvi_phi(b_lp):=b_phi; dvi_thue(b_lp):=b_thue; dvi_ttoan(b_lp):=b_phi+b_thue;
    lt_so_id(b_lp):=dvi_so_id(b_lp); lt_lt(b_lp):=a_ds_lt(b_lp); lt_kbt(b_lp):=a_ds_kbt(b_lp);
end loop;
if b_ttrang in('T','D') then
    select json_object('loai' value b_loai_khH,'ten' value b_tenH,'cmt' value b_cmtH,
        'dchi' value b_dchiH,'mobi' value b_mobiH,'email' value b_emailH) into b_txt from dual;
    PBH_DTAC_MA_NH(b_txt,b_ma_khH,b_loi,b_ma_dvi,b_nsd);
    if b_ma_khH not in(' ','VANGLAI') then PKH_JS_THAY(dt_ct,'ma_khH',b_ma_khH); end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_PHHH_TESTr:loi'; end if;
end;
/
create or replace procedure PBH_PHHH_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    dt_ct in out clob,dt_dk clob,dt_dkbs clob,dt_lt clob,dt_hk clob,
    ds_ct clob,ds_dk clob,ds_dkbs clob,ds_pvi clob,ds_lt clob,ds_dkth clob,ds_kbt clob,ds_ttt clob,
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
    b_ma_sp varchar2,b_cdich varchar2,b_goi varchar2,

    dvi_so_id pht_type.a_num,dvi_kieu_gcn pht_type.a_var,dvi_gcn pht_type.a_var,dvi_gcnG pht_type.a_var,
    dvi_dvi pht_type.a_nvar,dvi_ma_dt pht_type.a_var,dvi_kvuc pht_type.a_var,
    dvi_lvuc pht_type.a_nvar,dvi_ddiem pht_type.a_nvar,
    dvi_dk_lut pht_type.a_var,dvi_hs_lut pht_type.a_num,
	dvi_mrr pht_type.a_var,dvi_cdt pht_type.a_var,
    dvi_tdx pht_type.a_num,dvi_tdy pht_type.a_num,dvi_bk pht_type.a_num,
    dvi_gio_hl pht_type.a_var,dvi_ngay_hl pht_type.a_num,
    dvi_gio_kt pht_type.a_var,dvi_ngay_kt pht_type.a_num,dvi_ngay_cap pht_type.a_num,
    dvi_phi pht_type.a_num,dvi_thue pht_type.a_num,dvi_ttoan pht_type.a_num,
    dvi_giam pht_type.a_num,dvi_tlbt pht_type.a_num,dvi_so_idP pht_type.a_num,

    dk_so_id pht_type.a_num,dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tc pht_type.a_var,
    dk_ma_ct pht_type.a_var,dk_kieu pht_type.a_var,
    dk_lkeM pht_type.a_var,dk_lkeP pht_type.a_var,dk_lkeB pht_type.a_var,
    dk_luy pht_type.a_var,dk_ktru pht_type.a_var,
    dk_ma_dk pht_type.a_var,dk_ma_dkC pht_type.a_var,dk_lh_nv pht_type.a_var,dk_t_suat pht_type.a_num,
    dk_cap pht_type.a_num,dk_lbh pht_type.a_var,dk_nv pht_type.a_var,
    dk_tien pht_type.a_num,dk_pt pht_type.a_num,dk_phi pht_type.a_num,
    dk_thue pht_type.a_num,dk_ttoan pht_type.a_num,
    dk_ptB pht_type.a_num,dk_phiB pht_type.a_num,dk_ptG pht_type.a_num,dk_phiG pht_type.a_num,
    dk_pvi_ma pht_type.a_var,dk_pvi_tc pht_type.a_var,dk_pvi_ktru pht_type.a_var,
    lt_so_id pht_type.a_num,lt_lt pht_type.a_clob,lt_kbt pht_type.a_clob,b_loi out varchar2)
AS
    b_i1 number; b_so_dt number; b_so_id_kt number:=-1; b_tien number:=0; b_ma_ke varchar2(20);
    b_txt clob; b_txt_lt clob;
begin
-- Dan - Nhap
b_so_dt:=dvi_so_id.count;
if b_ttrang='D' then b_so_id_kt:=0; end if;
for b_lp in 1..dvi_so_id.count loop
    insert into bh_phh_dvi values(b_ma_dvi,b_so_id,dvi_so_id(b_lp),b_lp,dvi_kieu_gcn(b_lp),dvi_gcn(b_lp),dvi_gcnG(b_lp),
        dvi_dvi(b_lp),dvi_ma_dt(b_lp),dvi_kvuc(b_lp),dvi_lvuc(b_lp),dvi_ddiem(b_lp),dvi_dk_lut(b_lp),dvi_hs_lut(b_lp),
        dvi_mrr(b_lp),dvi_cdt(b_lp),dvi_tdx(b_lp),dvi_tdy(b_lp),dvi_bk(b_lp),
        dvi_gio_hl(b_lp),dvi_ngay_hl(b_lp),dvi_gio_kt(b_lp),dvi_ngay_kt(b_lp),dvi_ngay_cap(b_lp),
        dvi_so_idP(b_lp),dvi_giam(b_lp),dvi_phi(b_lp),dvi_thue(b_lp),dvi_ttoan(b_lp),dvi_tlbt(b_lp));
end loop;
for b_lp in 1..dk_so_id.count loop
    if dk_lh_nv(b_lp)<>' ' and dk_kieu(b_lp)='T' then b_tien:=b_tien+dk_tien(b_lp); end if;
    insert into bh_phh_dk values(b_ma_dvi,b_so_id,dk_so_id(b_lp),b_lp,
        dk_ma(b_lp),dk_ten(b_lp),dk_tc(b_lp),dk_ma_ct(b_lp),dk_kieu(b_lp),dk_tien(b_lp),dk_pt(b_lp),dk_phi(b_lp),dk_cap(b_lp),
        dk_ma_dk(b_lp),dk_ma_dkC(b_lp),dk_lh_nv(b_lp),dk_t_suat(b_lp),dk_thue(b_lp),dk_ttoan(b_lp),
        dk_ptB(b_lp),dk_phiB(b_lp),dk_ptG(b_lp),dk_phiG(b_lp),dk_lkeM(b_lp),dk_lkeP(b_lp),dk_lkeB(b_lp),
        dk_luy(b_lp),dk_lbh(b_lp),dk_nv(b_lp),dk_ktru(b_lp),dk_pvi_ma(b_lp),dk_pvi_tc(b_lp),dk_pvi_ktru(b_lp));
end loop;
insert into bh_phh values(
    b_ma_dvi,b_so_id,b_so_hd,b_ngay_ht,'H',b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,
    b_phong,b_so_hdL,b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,
    b_nt_tien,b_nt_phi,b_c_thue,b_ma_sp,b_cdich,b_goi,b_so_dt,b_tien,
    b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,'','',b_so_id_kt,b_nsd,sysdate);
if b_kieu_hd<>'U' then
    for b_lp in 1..tt_ngay.count loop
        insert into bh_phh_tt values(b_ma_dvi,b_so_id,tt_ngay(b_lp),tt_tien(b_lp));
    end loop;
end if;
PKH_JS_THAYa(dt_ct,'so_hd,ma_kh',b_so_hd||','||b_ma_kh);
insert into bh_phh_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
if dt_dk is not null then
    insert into bh_phh_txt values(b_ma_dvi,b_so_id,'dt_dk',dt_dk);
end if;
if dt_dkbs is not null then
    insert into bh_phh_txt values(b_ma_dvi,b_so_id,'dt_dkbs',dt_dkbs);
end if;
if dt_lt is not null then
    insert into bh_phh_txt values(b_ma_dvi,b_so_id,'dt_lt',dt_lt);
end if;
if dt_hk is not null then
    insert into bh_phh_txt values(b_ma_dvi,b_so_id,'dt_hk',dt_hk);
end if;
insert into bh_phh_txt values(b_ma_dvi,b_so_id,'ds_ct',ds_ct);
insert into bh_phh_txt values(b_ma_dvi,b_so_id,'ds_dk',ds_dk);
insert into bh_phh_txt values(b_ma_dvi,b_so_id,'ds_pvi',ds_pvi);
if length(ds_dkbs)<>0 then
    insert into bh_phh_txt values(b_ma_dvi,b_so_id,'ds_dkbs',ds_dkbs);
end if;
if length(ds_lt)<>0 then
    insert into bh_phh_txt values(b_ma_dvi,b_so_id,'ds_lt',ds_lt);
end if;
if length(ds_dkth)<>0 then
    insert into bh_phh_txt values(b_ma_dvi,b_so_id,'ds_dkth',ds_dkth);
end if;
if length(ds_kbt)<>0 then
    insert into bh_phh_txt values(b_ma_dvi,b_so_id,'ds_kbt',ds_kbt);
end if;
if length(ds_ttt)<>0 then
    insert into bh_phh_txt values(b_ma_dvi,b_so_id,'ds_ttt',ds_ttt);
end if;
for b_lp in 1..dvi_dvi.count loop
    if dvi_tdx(b_lp)<>0 and dvi_tdy(b_lp)<>0 and REGEXP_COUNT(dvi_ddiem(b_lp),',')>2 then
        insert into bh_phh_ttu values(b_ma_dvi,b_so_idD,dvi_so_id(b_lp),dvi_dvi(b_lp),
            dvi_tdx(b_lp),dvi_tdy(b_lp),dvi_bk(b_lp),dvi_ngay_hl(b_lp),dvi_ngay_kt(b_lp));
    end if;
end loop;
if b_kieu_hd<>'U' and b_ttrang in('T','D') then
    for b_lp in 1..lt_so_id.count loop
        select JSON_ARRAYAGG(json_object(
            ma,ten,tc,ma_ct,kieu,tien,pt,phi,cap,ma_dk,ma_dkC,lh_nv,t_suat,
            thue,ttoan,ptB,ptG,phiG,lkeM,lkeP,lkeB,luy,ktru,pvi_ma,pvi_tc,pvi_ktru)
            order by bt returning clob) into b_txt
            from bh_phh_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=lt_so_id(b_lp);
        if trim(lt_lt(b_lp)) is not null then b_txt_lt:=lt_lt(b_lp); else b_txt_lt:=dt_lt; end if;
        insert into bh_phh_kbt values(b_ma_dvi,b_so_id,lt_so_id(b_lp),b_txt,b_txt_lt,lt_kbt(b_lp));
    end loop;
    for b_lp in 1..dvi_dvi.count loop
        insert into bh_hd_goc_ttindt values(b_ma_dvi,b_so_idD,dvi_so_id(b_lp),'PHH',
            dvi_dvi(b_lp),b_ma_kh,dvi_ngay_kt(b_lp),' ',' ');
    end loop;
    PBH_PHH_TTU(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
    select json_object('ma_dvi' value b_ma_dvi,'nsd' value b_nsd,'so_id' value b_so_id,'so_hd' value b_so_hd,
        'kieu_hd' value b_kieu_hd,'nv' value 'PHH','ngay_ht' value b_ngay_ht,'ngay_cap' value b_ngay_cap,
        'ngay_hl' value b_ngay_hl,'ngay_kt' value b_ngay_kt,'cb_ql' value b_ma_cb,'phong' value b_phong,
        'kieu_kt' value b_kieu_kt,'ma_kt' value b_ma_kt,'dly_tke' value ' ','hhong' value b_hhong,
        'pt_hhong' value 'D','ma_kh' value b_ma_kh,'ten' value b_ten,'kieu_gt' value b_kieu_gt,
        'ma_gt' value b_ma_gt,'so_id_d' value b_so_idD,'so_id_g' value b_so_idG,
        'ttrang' value b_ttrang,'dvi_ksoat' value b_ma_dvi,'ksoat' value b_nsd,'bangg' value 'bh_phh',
        'c_thue' value b_c_thue,'nt_tien' value b_nt_tien,'nt_phi' value b_nt_phi,'tien' value b_tien,
        'phi' value b_ttoan-b_thue,'thue' value b_thue returning clob) into b_txt from dual;
    PBH_HD_GOC_NH(b_txt,b_loi);
    if b_loi is not null then return; end if;
end if;
if b_ttrang='D' and b_kieu_hd<>'U' then
    for b_lp in 1..dvi_so_id.count loop
        PBH_KE_CTI_NHOM(b_ma_dvi,b_so_idD,dvi_so_id(b_lp),b_ma_ke,b_loi);
        if b_loi is not null then return; end if;
        insert into bh_hd_goc_ttindt values(
            b_ma_dvi,b_so_id,dvi_so_id(b_lp),'PHH',dvi_dvi(b_lp),b_ma_kh,dvi_ngay_kt(b_lp),dvi_ddiem(b_lp),b_ma_ke);
    end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_PHHH_NH_NH:loi'; end if;
end;
/
create or replace procedure PBH_PHHH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(3000); b_lenh varchar2(2000); b_i1 number;
    dt_ct clob; dt_dk clob; dt_dkbs clob; dt_lt clob; dt_hk clob;
    ds_ct clob; ds_dk clob; ds_dkbs clob; ds_pvi clob; ds_lt clob; ds_dkth clob; ds_kbt clob; ds_ttt clob; dt_kytt clob;
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
    b_ma_sp varchar2(10); b_cdich varchar2(10); b_goi varchar2(10);

    dvi_so_id pht_type.a_num; dvi_kieu_gcn pht_type.a_var; dvi_gcn pht_type.a_var; dvi_gcnG pht_type.a_var; 
    dvi_dvi pht_type.a_nvar; dvi_ma_dt pht_type.a_var; dvi_kvuc pht_type.a_var; 
    dvi_lvuc pht_type.a_nvar; dvi_ddiem pht_type.a_nvar; 
    dvi_dk_lut pht_type.a_var; dvi_hs_lut pht_type.a_num;
    dvi_mrr pht_type.a_var; dvi_cdt pht_type.a_var; 
    dvi_tdx pht_type.a_num; dvi_tdy pht_type.a_num; dvi_bk pht_type.a_num; 
    dvi_gio_hl pht_type.a_var; dvi_ngay_hl pht_type.a_num; 
    dvi_gio_kt pht_type.a_var; dvi_ngay_kt pht_type.a_num; dvi_ngay_cap pht_type.a_num; 
    dvi_phi pht_type.a_num; dvi_thue pht_type.a_num; dvi_ttoan pht_type.a_num; 
    dvi_giam pht_type.a_num; dvi_tlbt pht_type.a_num; dvi_so_idP pht_type.a_num; 

    dk_so_id pht_type.a_num; dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var;
    dk_ma_ct pht_type.a_var; dk_kieu pht_type.a_var; 
    dk_lkeM pht_type.a_var; dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var;
    dk_luy pht_type.a_var; dk_ktru pht_type.a_var; 
    dk_ma_dk pht_type.a_var; dk_ma_dkC pht_type.a_var; dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num; 
    dk_cap pht_type.a_num; dk_lbh pht_type.a_var; dk_nv pht_type.a_var; 
    dk_tien pht_type.a_num; dk_pt pht_type.a_num; dk_phi pht_type.a_num; 
    dk_thue pht_type.a_num; dk_ttoan pht_type.a_num; 
    dk_ptB pht_type.a_num; dk_phiB pht_type.a_num; dk_ptG pht_type.a_num; dk_phiG pht_type.a_num; 
    dk_pvi_ma pht_type.a_var; dk_pvi_tc pht_type.a_var; dk_pvi_ktru pht_type.a_var;
    lt_so_id pht_type.a_num; lt_lt pht_type.a_clob; lt_kbt pht_type.a_clob;
-- Xu ly
    b_ngay_htC number;
begin
-- Dan - Nhap
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_dkbs,dt_lt,dt_hk,ds_ct,ds_dk,ds_dkbs,ds_pvi,ds_lt,ds_dkth,ds_kbt,ds_ttt,dt_kytt');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_dkbs,dt_lt,dt_hk,ds_ct,ds_dk,ds_dkbs,ds_pvi,ds_lt,ds_dkth,ds_kbt,ds_ttt,dt_kytt using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_dkbs); 
FKH_JSa_NULL(dt_lt);FKH_JSa_NULL(dt_hk); FKH_JSa_NULL(dt_kytt);
if b_so_id<>0 then
    select count(*) into b_i1 from bh_phh where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 then
        select ngay_ht,kieu_hd,ttrang into b_ngay_htC,b_kieu_hd,b_ttrang
            from bh_phh where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
        if sql%rowcount=0 then b_loi:='loi:Va cham NSD:loi'; raise PROGRAM_ERROR; end if;
        if b_ttrang not in('T','D') then b_kieu_hd:='X'; else b_kieu_hd:='N'; end if;
        PBH_PHH_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_kieu_hd,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
else
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_HD_JS_TEST(
    b_ma_dvi,b_nsd,b_so_id,b_ngay_htC,'bh_phh',dt_ct,dt_kytt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_loai_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,
    b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_ngayD,b_phong,b_ma_cb,b_ma_kh,
    tt_ngay,tt_tien,b_loi,'PHH');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_PHHH_TESTr(
    b_ma_dvi,b_nsd,b_so_idG,
    dt_ct,dt_dk,dt_dkbs,
    ds_ct,ds_dk,ds_dkbs,ds_pvi,ds_lt,ds_dkth,ds_kbt,
    b_ma_sp,b_cdich,b_goi,
    dvi_so_id,dvi_kieu_gcn,dvi_gcn,dvi_gcnG,dvi_dvi,dvi_ma_dt,dvi_kvuc,dvi_lvuc,dvi_ddiem,
    dvi_dk_lut,dvi_hs_lut,dvi_mrr,dvi_cdt,dvi_tdx,dvi_tdy,dvi_bk,dvi_gio_hl,dvi_ngay_hl,
    dvi_gio_kt,dvi_ngay_kt,dvi_ngay_cap,dvi_phi,dvi_thue,dvi_ttoan,dvi_giam,dvi_tlbt,dvi_so_idP,
    dk_so_id,dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy,dk_ktru,
    dk_ma_dk,dk_ma_dkC,dk_lh_nv,dk_t_suat,dk_cap,dk_lbh,dk_nv,dk_tien,dk_pt,dk_phi,
    dk_thue,dk_ttoan,dk_ptB,dk_phiB,dk_ptG,dk_phiG,dk_pvi_ma,dk_pvi_tc,dk_pvi_ktru,
    lt_so_id,lt_lt,lt_kbt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_PHHH_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,
    dt_ct,dt_dk,dt_dkbs,dt_lt,dt_hk,ds_ct,ds_dk,ds_dkbs,ds_pvi,ds_lt,ds_dkth,ds_kbt,ds_ttt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,b_so_hdL,
    b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,
    b_so_idG,b_so_idD,b_ngayD,b_phong,
    tt_ngay,tt_tien,
    b_ma_sp,b_cdich,b_goi,
    dvi_so_id,dvi_kieu_gcn,dvi_gcn,dvi_gcnG,dvi_dvi,dvi_ma_dt,dvi_kvuc,dvi_lvuc,dvi_ddiem,
    dvi_dk_lut,dvi_hs_lut,dvi_mrr,dvi_cdt,dvi_tdx,dvi_tdy,dvi_bk,dvi_gio_hl,dvi_ngay_hl,
    dvi_gio_kt,dvi_ngay_kt,dvi_ngay_cap,dvi_phi,dvi_thue,dvi_ttoan,dvi_giam,dvi_tlbt,dvi_so_idP,
    dk_so_id,dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_kieu,dk_lkeM,dk_lkeP,dk_lkeB,dk_luy,dk_ktru,
    dk_ma_dk,dk_ma_dkC,dk_lh_nv,dk_t_suat,dk_cap,dk_lbh,dk_nv,dk_tien,dk_pt,dk_phi,
    dk_thue,dk_ttoan,dk_ptB,dk_phiB,dk_ptG,dk_phiG,dk_pvi_ma,dk_pvi_tc,dk_pvi_ktru,
    lt_so_id,lt_lt,lt_kbt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,
    'so_hd' value b_so_hd, 'ma_kh' value b_ma_kh) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
