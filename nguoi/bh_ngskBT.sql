create or replace procedure PBH_SKBT_CTbg(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number; b_lan number;
    dt_ct clob; dt_ds clob; dt_nh clob:=''; dt_giam clob:=''; dt_kytt clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id,lan');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id,b_lan using b_oraIn;
select count(*) into b_i1 from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct' and lan = b_lan;
if b_i1<>1 then b_loi:='loi:Bao gia da xoa:loi'; raise PROGRAM_ERROR; end if;
select txt into dt_ct from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct' and lan = b_lan;
select count(*) into b_i1 from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds' and lan = b_lan;
if b_i1=1 then
    select txt into dt_ds from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds' and lan = b_lan;
end if;
select count(*) into b_i1 from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_nh' and lan = b_lan;
if b_i1=1 then
    select txt into dt_nh from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_nh' and lan = b_lan;
end if;
select count(*) into b_i1 from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_giam' and lan = b_lan;
if b_i1=1 then
    select txt into dt_giam from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_giam' and lan = b_lan;
end if;
select count(*) into b_i1 from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_kytt' and lan = b_lan;
if b_i1=1 then
    select txt into dt_kytt from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_kytt' and lan = b_lan;
end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'dt_ct' value dt_ct,'dt_ds' value dt_ds,
    'dt_nh' value dt_nh,'dt_giam' value dt_giam,'dt_kytt' value dt_kytt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SKBT_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number; b_lan number;
    dt_ct clob; dt_ds clob; dt_nh clob:=''; dt_giam clob:=''; dt_kytt clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
select nvl(max(lan),0) into b_lan from bh_ngB where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_lan=0 then b_loi:='loi:Bao gia da xoa:loi'; raise PROGRAM_ERROR; end if;
select txt into dt_ct from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ct';
select count(*) into b_i1 from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds' and lan = b_lan;
if b_i1=1 then
    select txt into dt_ds from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds' and lan = b_lan;
end if;
select count(*) into b_i1 from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_nh';
if b_i1=1 then
    select txt into dt_nh from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_nh';
end if;
select count(*) into b_i1 from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_giam';
if b_i1=1 then
    select txt into dt_giam from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_giam';
end if;
select count(*) into b_i1 from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_kytt';
if b_i1=1 then
    select txt into dt_kytt from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_kytt';
end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'dt_ct' value dt_ct,'dt_ds' value dt_ds,
    'dt_nh' value dt_nh,'dt_giam' value dt_giam,'dt_kytt' value dt_kytt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SKB_TESTr(
    b_ma_dvi varchar2,dt_ct clob,dt_giam clob,dt_nh clob,dt_ds clob,
    b_ma_sp out varchar2,
    
    gcn_so_id out pht_type.a_num, gcn_ten out pht_type.a_var, gcn_so_idP out pht_type.a_num,
    gcn_ngay_hl out pht_type.a_num, gcn_ngay_kt out pht_type.a_num, gcn_ngay_cap out pht_type.a_num,
    gcn_ma_kh out pht_type.a_var, gcn_cdt out pht_type.a_var,
    
    dk_so_id out pht_type.a_num,dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,dk_kieu out pht_type.a_var,
    dk_lh_nv out pht_type.a_var,dk_tien out pht_type.a_num,dk_phi out pht_type.a_num,
    dk_ptG out pht_type.a_num,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_i2 number; b_so_idN number:=0;
    b_kieu_hd varchar2(1); b_ttrang varchar2(1);
    b_kt_dk number; b_kt_dkB number; b_kt_dkC number; b_so_dt number; b_txt clob;
    b_gio_hl nvarchar2(50); b_ngay_hl number; b_gio_kt nvarchar2(50); b_ngay_kt number; b_ngay_cap number;
    b_phiH number; b_ttoanH number; b_phiN number; b_giamN number; b_ktG number;
    b_so_hdL varchar2(1); b_cdich varchar2(10); b_tpaH varchar2(500); b_so_idP number;

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

    nh_so_idP pht_type.a_num;
    nh_so_id pht_type.a_num; nh_nhom pht_type.a_var; nh_ten pht_type.a_nvar;
    nh_goi pht_type.a_var; nh_tpa pht_type.a_var;
    nh_phi pht_type.a_num; nh_so_dt pht_type.a_num; nh_phiN pht_type.a_num;
    nh_tl_giam pht_type.a_num; nh_giam pht_type.a_num; nh_ttoan pht_type.a_num;
    nh_cdt pht_type.a_var;

    dk_tc pht_type.a_var; dk_ma_ct pht_type.a_var;
    dk_pt pht_type.a_num; dk_thue pht_type.a_num; dk_ttoan pht_type.a_num;
    dk_cap pht_type.a_num; dk_ma_dk pht_type.a_var; dk_t_suat pht_type.a_num;
    dk_ptB pht_type.a_num; dk_phiG pht_type.a_num;
    dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var; dk_luy pht_type.a_var; dk_lh_bh pht_type.a_var;
    gcn_nhom pht_type.a_var; gcn_cmt pht_type.a_var;
begin
-- Dan - Nhap
b_lenh:=FKH_JS_LENH('ttrang,kieu_hd,gio_hl,ngay_hl,gio_kt,ngay_kt,ngay_cap,ma_sp,cdich,tpa,ttoan,so_hdl,so_dt');
EXECUTE IMMEDIATE b_lenh into b_ttrang,b_kieu_hd,b_gio_hl,b_ngay_hl,
    b_gio_kt,b_ngay_kt,b_ngay_cap,b_ma_sp,b_cdich,b_tpaH,b_ttoanH,b_so_hdL,b_so_dt using dt_ct;
b_ma_sp:=nvl(trim(b_ma_sp),' '); b_cdich:=nvl(trim(b_cdich),' ');
if b_ma_sp=' ' or FBH_SK_SP_HAN(b_ma_sp)<>'C' then b_loi:='loi:Sai ma san pham:loi'; return; end if;
if b_cdich<>' ' and FBH_MA_CDICH_HAN(b_cdich)<>'C' then b_loi:='loi:Sai ma chien dich:loi'; return; end if;
b_tpaH:=PKH_MA_TENl(b_tpaH);
if b_tpaH<>' ' and FBH_MA_GDINH_HAN(b_tpaH)<>'C' then b_loi:='loi:Sai ma TPA '||b_tpaH||':loi'; return; end if;
b_lenh:=FKH_JS_LENH('nhom,tl_giam,giam,ttoan');
EXECUTE IMMEDIATE b_lenh bulk collect into nh_nhomG,nh_tl_giamG,nh_giamG,nh_ttoanG using dt_giam;
b_lenh:=FKH_JS_LENHc('dt_nh_ct,dt_nh_dk,dt_nh_dkbs,dt_nh_lt,dt_nh_khd,dt_nh_kbt');
EXECUTE IMMEDIATE b_lenh bulk collect into nh_dt_ct,nh_dt_dk,nh_dt_dkbs,nh_dt_lt,nh_dt_khd,nh_dt_kbt using dt_nh;
if nh_dt_ct.count=0 then b_loi:='loi:Nhap quyen loi nhom:loi'; return; end if;
b_lenh:=FKH_JS_LENH('so_id_nh,nhom,ten,goi,so_idp,tpa,phi,cdt');
for b_lp in 1..nh_dt_ct.count loop
    EXECUTE IMMEDIATE b_lenh into nh_so_id(b_lp),nh_nhom(b_lp),nh_ten(b_lp),nh_goi(b_lp),
        nh_so_idP(b_lp),nh_tpa(b_lp),nh_phi(b_lp),nh_cdt(b_lp) using nh_dt_ct(b_lp);
    if trim(nh_nhom(b_lp)) is null or trim(nh_ten(b_lp)) is null then
        b_loi:='loi:Nhap nhom va ten nhom dong '||to_char(b_lp)||':loi'; return;
    end if;
    if trim(nh_tpa(b_lp)) is null then nh_tpa(b_lp):=b_tpaH;
    else nh_tpa(b_lp):=PKH_MA_TENl(nh_tpa(b_lp));
    end if;
    if trim(nh_tpa(b_lp)) is not null and FBH_MA_GDINH_HAN(nh_tpa(b_lp))<>'C' then
        b_loi:='loi:Sai ma TPA '||nh_tpa(b_lp)||':loi'; return;
    end if;
    nh_goi(b_lp):=nvl(trim(nh_goi(b_lp)),' ');
    if nh_goi(b_lp)<>' ' and FBH_SK_GOI_HAN(nh_goi(b_lp))<>'C' then b_loi:='loi:Sai ma goi '||nh_goi(b_lp)||':loi'; return; end if;
    b_i1:=FKH_ARR_VTRI(nh_nhomG, nh_nhom(b_lp));
    if b_i1=0 then b_loi:='loi:Sai nhom '||nh_ten(b_lp)||':loi'; return; end if;
    -- chuclh kiem tra bp neu thay doi sp-chien dich
    b_so_idP:=FBH_SK_BPHI_SO_IDh('T',b_ma_sp,b_cdich,nh_goi(b_lp),0,0,b_ngay_hl);
    if b_so_idP=0 then b_loi:='loi:Khong tim duoc bieu phi nhom '||nh_ten(b_lp)||':loi'; return; end if;
    if b_so_idP <> nh_so_idP(b_lp) then
        b_loi:='loi:Da thay doi tham so xac dinh phi:loi'; return;
    end if;
    --
    nh_giam(b_lp):=nh_giamG(b_i1); nh_ttoan(b_lp):=nh_ttoanG(b_i1);
    nh_tl_giam(b_lp):=nh_tl_giamG(b_i1); nh_phiN(b_lp):=nh_giam(b_lp)+nh_ttoan(b_lp);
    nh_so_id(b_lp):=nvl(nh_so_id(b_lp),b_lp);
end loop;

b_lenh:=FKH_JS_LENH('so_id_dt,nhom,ten,cmt,ngay_hl,ngay_kt,ngay_cap');
EXECUTE IMMEDIATE b_lenh bulk collect into
    gcn_so_id,gcn_nhom,gcn_ten,gcn_cmt,gcn_ngay_hl,gcn_ngay_kt,gcn_ngay_cap using dt_ds;
for b_lp in 1..gcn_ten.count loop
    if trim(gcn_ten(b_lp)) is null then b_loi:='loi:Nhap ten dong '||to_char(b_lp)||':loi'; return; end if;
    if trim(gcn_nhom(b_lp)) is null or trim(gcn_cmt(b_lp)) is null  then b_loi:='loi:Nhap nhom, CCCD '||gcn_ten(b_lp)||':loi'; return; end if;
    b_i1:=FKH_ARR_VTRI(nh_nhom, gcn_nhom(b_lp));
    if b_i1=0 then b_loi:='loi:Chua xep nhom '||gcn_ten(b_lp)||':loi'; return; end if;
    gcn_so_idP(b_lp):=nh_so_idP(b_i1);
    gcn_ngay_cap(b_lp):=b_ngay_cap;
    gcn_cdt(b_lp):=nvl(trim(nh_cdt(b_i1)),' ');
end loop;
b_kt_dk:=0; b_phiH:=0;
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
    b_phiN:=0; b_kt_dkB:=b_kt_dk+1;
    --Nam: khong co danh sach loop qua so_dt
    if gcn_ten.count=0 then 
        for b_lp1 in 1..b_so_dt loop
          for b_lp2 in 1..nh_maG.count loop
              b_kt_dk:=b_kt_dk+1;
              dk_so_id(b_kt_dk):=b_lp1; 
              dk_ma(b_kt_dk):=nh_maG(b_lp2); dk_ten(b_kt_dk):=nh_tenG(b_lp2);
              dk_kieu(b_kt_dk):=nh_kieuG(b_lp2); dk_tien(b_kt_dk):=nh_tienG(b_lp2); 
              dk_phi(b_kt_dk):=nh_phiG(b_lp2); dk_lh_nv(b_kt_dk):=nh_lh_nvG(b_lp2); 
              dk_phiB(b_kt_dk):=nh_phiBG(b_lp2);
              if dk_lh_nv(b_kt_dk)<>' ' then b_phiN:=b_phiN+dk_phi(b_kt_dk); end if;
            if nh_dt_dkbs(b_lp) is null then
                b_txt:=nh_dt_dk(b_lp);
            else
                b_i1:=length(nh_dt_dk(b_lp))-1;
                b_txt:=substr(nh_dt_dk(b_lp),1,b_i1)||','||substr(nh_dt_dkbs(b_lp),2);
            end if;
          end loop;
        end loop;
    else 
        b_so_dt:=0;
        for b_lp1 in 1..gcn_ten.count loop
            if gcn_nhom(b_lp1)=nh_nhom(b_lp) then
                for b_lp2 in 1..nh_maG.count loop
                  b_kt_dk:=b_kt_dk+1;
                  dk_so_id(b_kt_dk):=gcn_so_id(b_lp1); 
                  dk_ma(b_kt_dk):=nh_maG(b_lp2); dk_ten(b_kt_dk):=nh_tenG(b_lp2);
                  dk_kieu(b_kt_dk):=nh_kieuG(b_lp2); dk_tien(b_kt_dk):=nh_tienG(b_lp2); 
                  dk_phi(b_kt_dk):=nh_phiG(b_lp2); dk_lh_nv(b_kt_dk):=nh_lh_nvG(b_lp2); 
                  dk_phiB(b_kt_dk):=nh_phiBG(b_lp2);
                  if dk_lh_nv(b_kt_dk)<>' ' then b_phiN:=b_phiN+dk_phi(b_kt_dk); end if;
                if nh_dt_dkbs(b_lp) is null then
                    b_txt:=nh_dt_dk(b_lp);
                else
                    b_i1:=length(nh_dt_dk(b_lp))-1;
                    b_txt:=substr(nh_dt_dk(b_lp),1,b_i1)||','||substr(nh_dt_dkbs(b_lp),2);
                end if;
                b_so_dt:=b_so_dt+1;
                end loop;
            end if;
         end loop;
    end if;
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
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_SKBT_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_ma_sp varchar2,b_lan out number,
    dt_ct in out clob,dt_nh clob,dt_ds clob,dt_giam clob,dt_kytt clob,
    b_so_hd varchar2,b_ngay_ht number,b_ttrang varchar2,b_kieu_hd varchar2,b_so_hd_g varchar2,
    b_phong varchar2,b_ma_kh varchar2,b_ten nvarchar2,
    b_ngay_hl number,b_ngay_kt number,b_nt_tien varchar2,b_nt_phi varchar2,b_phi number,
    
    gcn_so_id pht_type.a_num, gcn_ten pht_type.a_var,gcn_so_idP pht_type.a_num,
    gcn_ngay_hl pht_type.a_num,gcn_ngay_kt pht_type.a_num,gcn_ngay_cap pht_type.a_num,
    gcn_ma_kh pht_type.a_var,gcn_cdt pht_type.a_var,
    
    dk_so_id pht_type.a_num,dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_kieu pht_type.a_var,dk_lh_nv pht_type.a_var,
    dk_tien pht_type.a_num,dk_phi pht_type.a_num,dk_ptG pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_ttrang_bg varchar2(1); b_so_dt number; b_so_id_kt number:=-1; a_bt pht_type.a_num ;
    b_tien number:=0; b_dsach varchar2(1):=FBH_SK_SP_DSACH(b_ma_sp);
begin
-- Dan - Nhap
b_loi:='loi:Loi Table bh_ngB:loi';
b_lan:=FKH_JS_GTRIn(dt_ct,'lan');
select nvl(max(lan),0) into b_i1 from bh_ngB where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_lan <> 0 and b_lan < b_i1 then b_loi:='loi:Khong duoc sua bao gia cu:loi'; return; end if;
if b_lan <> b_i1 then
  select nvl(ttrang,' ') into b_ttrang_bg from bh_ngB where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_i1;
  if b_ttrang_bg <> ' ' and b_ttrang_bg <> 'D' then b_loi:='loi:Phai duyet bao gia lan '||b_i1||':loi'; return; end if;
end if;
if b_lan = 0 then b_lan:=b_i1+1; end if;
PKH_JS_THAYn(dt_ct,'lan',b_lan);
PBH_NGB_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'N',b_lan,b_loi);
if b_loi is not null then return; end if;
forall b_lp in 1..gcn_so_id.count
    insert into bh_ngB_ds values(b_ma_dvi,b_so_id,gcn_so_id(b_lp),gcn_ten(b_lp),gcn_so_idP(b_lp),b_ma_sp,gcn_ngay_hl(b_lp),
        gcn_ngay_kt(b_lp),gcn_ngay_cap(b_lp),b_ma_kh);
for b_lp in 1..dk_so_id.count loop
    if dk_lh_nv(b_lp)<>' ' and dk_kieu(b_lp)='T' then b_tien:=b_tien+dk_tien(b_lp); end if;
    insert into bh_ngB_dk values(b_ma_dvi,b_so_id,dk_so_id(b_lp),dk_ma(b_lp),dk_ten(b_lp),dk_lh_nv(b_lp),dk_tien(b_lp),dk_phi(b_lp),dk_ptG(b_lp));
end loop;
insert into bh_ngB values(
    b_ma_dvi,b_so_id,b_lan,b_so_hd,b_ngay_ht,'SKT',b_ttrang,b_kieu_hd,b_so_hd_g,
    b_phong,b_ma_kh,b_ten,b_ngay_hl,b_ngay_kt,b_dsach,b_nt_tien,b_tien,b_nt_phi,b_phi,' ',' ',b_nsd,sysdate);
PKH_JS_THAYa(dt_ct,'so_hd,ma_kh',b_so_hd||','||b_ma_kh);
insert into bh_ngB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_ct',dt_ct);
if trim(dt_nh) is not null then
    insert into bh_ngB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_nh',dt_nh);
end if;
if trim(dt_ds) is not null then
    insert into bh_ngB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_ds',dt_ds);
end if;
if trim(dt_giam) is not null then
    insert into bh_ngB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_giam',dt_giam);
end if;
if trim(dt_kytt) is not null then
    insert into bh_ngB_txt values(b_ma_dvi,b_so_id,b_lan,'dt_kytt',dt_kytt);
end if;
delete from bh_ngB_ls where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan;
insert into bh_ngB_ls (ma_dvi,so_id,lan,loai,txt) select ma_dvi,so_id,lan,loai,txt
    from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan;
PBH_BAO_NV_NH(b_ma_dvi,b_nsd,b_so_id,b_so_hd,'NG',b_ttrang,b_phong,b_ma_kh,b_ten,
    b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_tien,b_nt_phi,b_phi,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_SKBT_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(3000); b_lenh varchar2(2000); b_lan number;
    dt_ct clob; dt_giam clob; dt_nh clob; dt_ds clob; dt_kytt clob;
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
    b_ma_sp varchar2(10); b_cdich varchar2(200); b_tpaH varchar2(500);
    nh_so_id pht_type.a_num; nh_nhom pht_type.a_var; nh_ten pht_type.a_nvar; 
    nh_goi pht_type.a_var; nh_tpa pht_type.a_var; 
    nh_phi pht_type.a_num; nh_so_dt pht_type.a_num; nh_phiN pht_type.a_num; 
    nh_tl_giam pht_type.a_num; nh_giam pht_type.a_num; nh_ttoan pht_type.a_num; nh_dt_ct pht_type.a_clob; 
    
    gcn_so_id pht_type.a_num; gcn_ten pht_type.a_var; gcn_so_idP pht_type.a_num;
    gcn_ngay_hl pht_type.a_num; gcn_ngay_kt pht_type.a_num; gcn_ngay_cap pht_type.a_num;
    gcn_ma_kh pht_type.a_var; gcn_cdt pht_type.a_var;

    dk_so_id pht_type.a_num; dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var;
    dk_ma_ct pht_type.a_var; dk_kieu pht_type.a_var; dk_tien pht_type.a_num; dk_pt pht_type.a_num; dk_phi pht_type.a_num; 
    dk_thue pht_type.a_num; dk_ttoan pht_type.a_num; 
    dk_cap pht_type.a_num; dk_ma_dk pht_type.a_var;
    dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num; 
    dk_ptB pht_type.a_num; dk_ptG pht_type.a_num; dk_phiG pht_type.a_num; 
    dk_lkeP pht_type.a_var; dk_lkeB pht_type.a_var; dk_luy pht_type.a_var; dk_lh_bh pht_type.a_var;

    lt_so_id pht_type.a_num; lt_dk pht_type.a_clob; lt_lt pht_type.a_clob; lt_kbt pht_type.a_clob;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_giam,dt_nh,dt_ds,dt_kytt');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_giam,dt_nh,dt_ds,dt_kytt using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_giam); FKH_JSa_NULL(dt_ds); FKH_JSa_NULL(dt_kytt);
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_BG_JS_TEST(
    b_ma_dvi,b_nsd,b_so_id,'bh_sk',dt_ct,dt_kytt,
    b_so_hd,b_ngay_ht,b_ttrang,
    b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_loai_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,
    b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_phong,b_ma_kh,
    tt_ngay,tt_tien,b_loi,'NG');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_SKB_TESTr(
    b_ma_dvi,dt_ct,dt_giam,dt_nh,dt_ds,b_ma_sp,
    gcn_so_id,gcn_ten,gcn_so_idP,
    gcn_ngay_hl,gcn_ngay_kt,gcn_ngay_cap,
    gcn_ma_kh,gcn_cdt,
    dk_so_id,dk_ma,dk_ten,dk_kieu,dk_lh_nv,dk_tien,dk_phi,dk_ptG,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_SKBT_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,b_ma_sp,b_lan,
    dt_ct,dt_nh,dt_ds,dt_giam,dt_kytt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_phong,b_ma_kh,b_ten,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_phi,
    gcn_so_id,gcn_ten,gcn_so_idP,
    gcn_ngay_hl,gcn_ngay_kt,gcn_ngay_cap,
    gcn_ma_kh,gcn_cdt,
    dk_so_id,dk_ma,dk_ten,dk_kieu,dk_lh_nv,dk_tien,dk_phi,dk_ptG,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
FBH_BAO_TTRANGn(b_ma_dvi,b_so_id,b_ttrang,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hd' value b_so_hd, 'ma_kh' value b_ma_kh,'lan' value b_lan) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
