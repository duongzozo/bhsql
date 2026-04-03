create or replace procedure PBH_VTP_LUU(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2)
AS
    b_loi varchar2(100); b_d date:=sysdate; b_ngay number;
begin
-- Dan - Luu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','VTP','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ngay:=PKH_NG_CSO(b_d-540);            --18 thang
insert into bh_VTP_psLN select * from bh_VTP_psLT where ngay_ht<b_ngay;
delete bh_VTP_psLT where ngay_ht<b_ngay;
insert into bh_VTP_psTLN select * from bh_VTP_psTLT where ngay_ht<b_ngay;
delete bh_VTP_psTLT where ngay_ht<b_ngay;
commit;
insert into bh_VTP_btLN select * from bh_VTP_btLT where ngay_ht<b_ngay;
delete bh_VTP_btLT where ngay_ht<b_ngay;
commit;
b_ngay:=PKH_NG_CSO(b_d-60);             -- 2 thang
insert into bh_VTP_psLT select * from bh_VTP_ps where ngay_ht<b_ngay;
delete bh_VTP_ps where ngay_ht<b_ngay;
insert into bh_VTP_psTLT select * from bh_VTP_psT where ngay_ht<b_ngay;
delete bh_VTP_psT where ngay_ht<b_ngay;
commit;
insert into bh_VTP_btLT select * from bh_VTP_bt where ngay_ht<b_ngay;
delete bh_VTP_bt where ngay_ht<b_ngay;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_VTP_PS(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number,b_txt clob)
AS
    b_loi varchar2(100); b_i1 number; b_so_id number; b_so_hd varchar2(20);
    b_kt number:=0; b_ktL number:=0; b_cuoc number; b_phi number; b_lenh varchar2(2000);

    b_pp_tinh varchar2(10); b_ma_nhom varchar2(10):='VTP'; b_ma_dk varchar2(20):='?'; --lh_nv='HH.8'
    b_kieu_kt varchar2(1):='T'; b_ma_kt varchar2(20):='';
    b_ma_kh varchar2(20):='?'; b_ten nvarchar2(500); b_dchi nvarchar2(500);

    a_bilX pht_type.a_var; a_ngayX pht_type.a_num; a_loaiX pht_type.a_var;
    a_cuocX pht_type.a_num; a_phiX pht_type.a_num; a_txt pht_type.a_nvar;

    a_bil pht_type.a_var; a_ngay pht_type.a_num; a_loai pht_type.a_var;
    a_cuoc pht_type.a_num; a_phi pht_type.a_num; a_txt pht_type.a_nvar;
    a_bilL pht_type.a_var; a_loi pht_type.a_var;

    dk_so_id_dt pht_type.a_num; dk_loai_pt pht_type.a_var; dk_so_dt pht_type.a_num; 
    dk_ten_pt pht_type.a_nvar; dk_ma_hang pht_type.a_var; dk_ten_hang pht_type.a_nvar; 
    dk_dgoi pht_type.a_nvar; dk_dvi_tinh pht_type.a_nvar; dk_luong pht_type.a_num; dk_gia pht_type.a_num; 
    dk_tien pht_type.a_num; dk_hang pht_type.a_num; dk_vchuyen pht_type.a_num; 
    dk_tl_phi pht_type.a_num; dk_phi pht_type.a_num; dk_tl_pphi pht_type.a_num; dk_pphi pht_type.a_num; 
    tt_ngay pht_type.a_num; tt_tien pht_type.a_num; 
    dkbs_so_id_dt pht_type.a_num; dkbs_ma_dk pht_type.a_var; dkbs_ma pht_type.a_var; dkbs_tc pht_type.a_var; 
    dkbs_lh_nv pht_type.a_var; dkbs_nt_tien pht_type.a_var; dkbs_tien pht_type.a_num; 
    dkbs_pt pht_type.a_num; dkbs_k_phi pht_type.a_var; dkbs_phi pht_type.a_num; dkbs_mt_tien pht_type.a_num;
    dkbs_mt_pt pht_type.a_num; dkbs_mt_ktr pht_type.a_var; dkbs_nd pht_type.a_nvar; 
    ttt_so_id_dt pht_type.a_num; a_ttt_ma pht_type.a_var; a_ttt_nd pht_type.a_nvar;
	
begin
-- Dan - Phat sinh phi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','VTP','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('bil,ngay,loai,cuoc,phi');
EXECUTE IMMEDIATE b_lenh bulk collect into a_bilX,a_ngayX,a_loaiX,a_cuocX,a_phiX using b_txt;
for b_lp in 1..a_bilX.count loop
    if a_bilX(b_lp) is not null then
        if a_ngayX(b_lp) is null or a_ngayX(b_lp)=0 or a_cuocX(b_lp)=0 or a_phiX(b_lp)=0 or
            a_loaiX(b_lp) is null or a_loaiX(b_lp) not in('1','2','3') then
            b_ktL:=b_ktL+1;
            a_bilL(b_ktL):=a_bilX(b_lp); a_loi(b_ktL):='Sai so lieu chi tiet';
        else
            select count(*) into b_i1 from bh_VTP_ps where bil=a_bilX(b_lp);
            if b_i1<>0 then
                b_ktL:=b_ktL+1;
                a_bilL(b_ktL):=a_bilX(b_lp); a_loi(b_ktL):='So bill da co';
            else
                b_kt:=b_kt+1;
                a_bil(b_kt):=a_bilX(b_lp); a_ngay(b_kt):=a_ngayX(b_lp); a_loai(b_kt):=a_loaiX(b_lp);
                a_cuoc(b_kt):=a_cuocX(b_lp); a_phi(b_kt):=a_phiX(b_lp);
                b_cuoc:=b_cuoc+a_cuoc(b_lp); b_phi:=b_phi+a_phi(b_lp);
            end if;
        end if;
    end if;
end loop;
PHT_ID_MOI(b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_hd:=substr(to_char(b_so_id),3);
forall b_lp in 1..b_kt
    insert into bh_VTP_ps values(a_bil(b_lp),b_so_id,b_so_hd,b_ngay_ht,a_ngay(b_lp),a_loai(b_lp),a_cuoc(b_lp),a_phi(b_lp),'',0);
forall b_lp in 1..b_ktL
    insert into bh_VTP_loi values('P',a_bilL(b_lp),a_loi(b_lp));
insert into bh_VTPpt values(b_so_id,b_so_hd,b_ngay_ht,b_kt,b_cuoc,b_phi);
PKH_MANG_KD(dkbs_lh_nv); PKH_MANG_KD(a_ttt_ma);
select min(ma) into b_pp_tinh from bh_hh_ma_pp where ma_dvi=b_ma_dvi and ma=b_pp_tinh;
select min(ma) into dk_ma_hang(1) from bh_hh_ma_hang where ma_dvi=b_ma_dvi;
dk_so_id_dt(1):=b_so_id; dk_loai_pt(1):=''; dk_so_dt(1):=1;
dk_ten_pt(1):=' '; dk_ten_hang(1):=' ';
dk_dgoi(1):=' '; dk_dvi_tinh(1):=' '; dk_luong(1):=0; dk_gia(1):=0;
dk_tien(1):=b_cuoc; dk_hang(1):=b_cuoc; dk_vchuyen(1):=0;
dk_tl_phi(1):=0; dk_phi(1):=b_phi; dk_tl_pphi(1):=0; dk_pphi(1):=0;
tt_ngay(1):=b_ngay_ht; tt_tien(1):=b_phi;

/*b_ma_kh,b_ten,b_dchi; b_ma_kt:='?'; b_ma_dk:='?';*/

/*PBH_HHGCN_NH(
    b_ma_dvi,b_nsd,'',b_so_id,b_so_hd,'','D',b_ngay_ht,b_kieu_kt,b_ma_kt,' ',' ',0,b_nsd,b_nsd,'G',' ',
    b_ma_kh,b_ten,b_dchi,' ',' ',' ',' ',' ',' ',' ',' ',
    ' ',b_ma_nhom,sysdate,'01-Jan-3000',' ',' ',' ',' ',' ','K',b_ma_dk,0,0,' ',' ','VND','VND',
    'D',b_pp_tinh,'',1,0,0,sysdate,' ','T',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',
    dk_so_id_dt,dk_loai_pt,dk_so_dt,dk_ten_pt,dk_ma_hang,dk_ten_hang,dk_dgoi,dk_dvi_tinh,
    dk_luong,dk_gia,dk_tien,dk_hang,dk_vchuyen,dk_tl_phi,dk_phi,dk_tl_pphi,dk_pphi,
    tt_ngay,tt_tien,
    dkbs_so_id_dt,dkbs_ma_dk,dkbs_ma,dkbs_tc,dkbs_lh_nv,dkbs_nt_tien,dkbs_tien,
    dkbs_pt,dkbs_k_phi,dkbs_phi,dkbs_mt_tien,dkbs_mt_pt,dkbs_mt_ktr,dkbs_nd,
    ttt_so_id_dt,a_ttt_ma,a_ttt_nd,'K');*/
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_VTP_BT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number,b_txt clob)
AS
    b_loi varchar2(100); b_i1 number; b_so_id number; b_kt number:=0; b_ktL number:=0; b_ktH number:=1;
    b_loai varchar2(1); b_cuoc number; b_cuocT number:=0; b_so_id_hd number; b_so_hd varchar2(20);
    b_d date:=sysdate; b_thue number:=0; b_lenh varchar2(2000);

    a_bilX pht_type.a_var; a_ngayX pht_type.a_num; a_loaiX pht_type.a_var; a_ma_nnX pht_type.a_var; a_cuocX pht_type.a_num;
    a_bil pht_type.a_var; a_ngay pht_type.a_num; a_loai pht_type.a_var; a_cuoc pht_type.a_num;
    a_txt pht_type.a_nvar; a_ma_nn pht_type.a_var; a_so_id_hd pht_type.a_num; a_so_hd pht_type.a_var;
    a_bilL pht_type.a_var; a_loi pht_type.a_var;

    a_so_id_dt pht_type.a_num; a_tenTT pht_type.a_nvar; a_ddiem pht_type.a_nvar; a_lh_nv pht_type.a_var; a_ma_dt pht_type.a_var;
    a_ma_nt pht_type.a_var; a_tien_bh pht_type.a_num; a_pt_bt pht_type.a_num; a_t_that pht_type.a_num; a_k_tru pht_type.a_num;
    a_tien pht_type.a_num; a_tien_qd pht_type.a_num; a_thue pht_type.a_num; a_thue_qd pht_type.a_num; a_dxuat pht_type.a_nvar;

    a_hk_ma pht_type.a_var; a_hk_ma_nt pht_type.a_var; a_hk_tien pht_type.a_num;
    a_tb_ten pht_type.a_nvar; a_tb_ma_nt pht_type.a_var; a_tb_tien pht_type.a_num;
    a_ttt_so_id_dt pht_type.a_num; a_ttt_ma pht_type.a_var; a_ttt_nd pht_type.a_nvar;

    a_so_id_hs pht_type.a_num; a_so_hs pht_type.a_var;
    a_so_id_hsH pht_type.a_num; a_so_hsH pht_type.a_var; a_cuocH pht_type.a_num;
    a_so_id_hdH pht_type.a_num; a_so_hdH pht_type.a_var;
begin
-- Dan - Boi thuong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','VTP','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('bil,ngay,loai,cuoc,ma_nn');
EXECUTE IMMEDIATE b_lenh bulk collect into a_bilX,a_ngayX,a_loaiX,a_cuocX,a_ma_nnX using b_txt;
for b_lp in 1..a_bilX.count loop
    if a_bilX(b_lp) is not null then
        if a_ngayX(b_lp) is null or a_ngayX(b_lp)=0 or a_loaiX(b_lp) is null or
            a_loaiX(b_lp) not in('1','2','3') or a_ma_nnX(b_lp) is null or a_cuocX(b_lp)=0 then
            b_ktL:=b_ktL+1; a_bilL(b_ktL):=a_bilX(b_lp); a_loi(b_ktL):='Sai so lieu chi tiet';
        else
            select nvl(min(ngayB),-1),min(cuoc),min(loai),min(so_id),min(so_hd)
                into b_i1,b_cuoc,b_loai,b_so_id_hd,b_so_hd from bh_VTP_ps where bil=a_bilX(b_lp);
            if b_i1<>0 then
                b_ktL:=b_ktL+1; a_bilL(b_ktL):=a_bilX(b_lp);
                if b_i1<0 then a_loi(b_ktL):='So bill khong co'; else a_loi(b_ktL):='Da boi thuong'; end if;
            else
                if b_loai not in(a_loaiX(b_lp),'3') then
                    b_loi:='Sai loai';
                elsif a_cuocX(b_lp)<>b_cuoc then
                    b_loi:='Sai cuoc';
                else
                    b_loi:='';
                end if;
                if b_loi is not null then
                    b_ktL:=b_ktL+1; a_bilL(b_ktL):=a_bilX(b_lp); a_loi(b_ktL):=b_loi;
                else
                    b_kt:=b_kt+1; b_cuocT:=b_cuocT+b_cuoc;
                    a_bil(b_kt):=a_bilX(b_lp); a_ngay(b_kt):=a_ngayX(b_lp);
                    a_so_id_hd(b_kt):=b_so_id_hd; a_so_hd(b_kt):=b_so_hd;
                    a_loai(b_kt):=a_loaiX(b_lp); a_ma_nn(b_kt):=a_ma_nnX(b_lp); a_cuoc(b_kt):=b_cuoc;
                end if;
            end if;
        end if;
    end if;
end loop;
PKH_MANG_KD(a_hk_ma); PKH_MANG_KD(a_ttt_ma); PKH_MANG_KD_U(a_tb_ten);
a_so_id_hdH(1):=a_so_id_hd(1); a_so_hdH(1):=a_so_hd(1); a_so_hsH(1):=' ';
for b_lp in 2..b_kt loop
    if FKH_ARR_TIM_N(a_so_id_hdH,a_so_id_hd(b_lp))<>'C' then
        b_ktH:=b_ktH+1;
         a_so_hsH(b_ktH):=' '; a_so_id_hdH(b_ktH):=a_so_id_hd(b_lp); a_so_hdH(b_ktH):=a_so_hd(b_lp);
    end if;
end loop;
a_ddiem(1):=' '; a_lh_nv(1):='HH.8';
a_ma_dt(1):=' '; a_ma_nt(1):='VND'; a_pt_bt(1):=100; a_k_tru(1):=0; a_dxuat(1):='';
for b_lp in 1.. b_ktH loop
    PHT_ID_MOI(a_so_id_hsH(b_lp),b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    a_so_hsH(b_lp):=substr(to_char(a_so_id_hsH(b_lp)),3);
    a_cuocH(b_lp):=0;
    for b_lp1 in 1..b_kt loop
        if a_so_id_hdH(b_lp)=a_so_id_hd(b_lp1) then
            a_cuocH(b_lp):=a_cuocH(b_lp)+a_cuoc(b_lp1);
            a_so_id_hs(b_lp1):=a_so_id_hsH(b_lp); a_so_hs(b_lp1):=a_so_hsH(b_lp);
        end if;
    end loop;
    select nvl(min(cuoc),0) into b_i1 from bh_VTP_psT where so_id=a_so_id_hdH(b_lp);
    if b_i1=0 then
        select nvl(min(cuoc),0) into b_i1 from bh_VTP_psTLT where so_id=a_so_id_hdH(b_lp);
    end if;
    if b_i1=0 then
        b_ktL:=b_ktL+1;
        a_loi(b_ktL):='Qua han boi thuong GCN '||a_so_hdH(b_lp);
    else
		a_so_id_dt(1):=a_so_id_hdH(b_lp); a_tenTT(1):=a_so_hdH(b_lp);
        a_tien_bh(1):=b_i1; a_t_that(1):=a_cuocH(b_lp);
        a_tien(1):=a_cuocH(b_lp); a_tien_qd(1):=a_cuocH(b_lp);
		a_thue(1):=0;		--a_thue(1):=round(a_tien(1)*0.1,0);
		a_thue_qd(1):=a_thue(1); b_thue:=b_thue+a_thue(1);
        /*PBH_BT_HS_NH(b_ma_dvi,b_nsd,b_pas,a_so_id_hsH(b_lp),a_so_hsH(b_lp),b_ngay_ht,'G',' ',b_ma_dvi,
            a_so_hdH(b_lp),' ',b_d,b_d,b_d,' ',' ',' ',' ',b_nsd,b_nsd,b_d,' ',' ',' ',' ',' ',' ',' ','K','K',' ',0,0,
        a_so_id_dt,a_tenTT,a_ddiem,a_lh_nv,a_ma_dt,a_ma_nt,a_tien_bh,a_pt_bt,a_t_that,a_k_tru,a_tien,a_tien_qd,a_thue,a_thue_qd,
        a_hk_ma,a_hk_ma_nt,a_hk_tien,a_tb_ten,a_tb_ma_nt,a_tb_tien,a_ttt_so_id_dt,a_ttt_ma,a_ttt_nd,'K');*/
    end if;
end loop;
PHT_ID_MOI(b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
forall b_lp in 1..b_kt
    insert into bh_VTP_bt values(a_bil(b_lp),b_so_id,a_so_id_hd(b_lp),a_so_hd(b_lp),
        a_so_id_hs(b_lp),a_so_hs(b_lp),b_ngay_ht,a_ngay(b_lp),a_loai(b_lp),a_cuoc(b_lp),a_ma_nn(b_lp),'');
forall b_lp in 1..b_ktL
	insert into bh_VTP_loi values('B',a_bilL(b_lp),a_loi(b_lp));
insert into bh_VTP_btT values(b_so_id,b_ngay_ht,b_kt,b_ktH,b_cuocT,b_thue);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_VTP_GIAM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_thang number)
AS
    b_loi varchar2(100); b_i1 number; b_so_id number; b_kt number:=0; b_ktL number:=0; b_ktH number:=1;
    b_loai varchar2(1); b_cuoc number; b_cuocT number:=0; b_so_id_hd number; b_so_hd varchar2(20);
    b_d date:=sysdate; b_thue number:=0; b_lenh varchar2(2000);

    a_bilX pht_type.a_var; a_ngayX pht_type.a_num; a_loaiX pht_type.a_var; a_ma_nnX pht_type.a_var; a_cuocX pht_type.a_num;
    a_bil pht_type.a_var; a_ngay pht_type.a_num; a_loai pht_type.a_var; a_cuoc pht_type.a_num;
    a_txt pht_type.a_nvar; a_ma_nn pht_type.a_var; a_so_id_hd pht_type.a_num; a_so_hd pht_type.a_var;
    a_bilL pht_type.a_var; a_loi pht_type.a_var;

    a_so_id_dt pht_type.a_num; a_tenTT pht_type.a_nvar; a_ddiem pht_type.a_nvar; a_lh_nv pht_type.a_var; a_ma_dt pht_type.a_var;
    a_ma_nt pht_type.a_var; a_tien_bh pht_type.a_num; a_pt_bt pht_type.a_num; a_t_that pht_type.a_num; a_k_tru pht_type.a_num;
    a_tien pht_type.a_num; a_tien_qd pht_type.a_num; a_thue pht_type.a_num; a_thue_qd pht_type.a_num; a_dxuat pht_type.a_nvar;

    a_hk_ma pht_type.a_var; a_hk_ma_nt pht_type.a_var; a_hk_tien pht_type.a_num;
    a_tb_ten pht_type.a_nvar; a_tb_ma_nt pht_type.a_var; a_tb_tien pht_type.a_num;
    a_ttt_so_id_dt pht_type.a_num; a_ttt_ma pht_type.a_var; a_ttt_nd pht_type.a_nvar;

    a_so_id_hs pht_type.a_num; a_so_hs pht_type.a_var;
    a_so_id_hsH pht_type.a_num; a_so_hsH pht_type.a_var; a_cuocH pht_type.a_num;
    a_so_id_hdH pht_type.a_num; a_so_hdH pht_type.a_var;
begin
-- Dan -
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','VTP','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
