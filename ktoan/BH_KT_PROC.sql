create or replace PROCEDURE PBH_KT_HTOAN_DO_D
    (B_MA_DVI VARCHAR2,B_NGAY_HT NUMBER,A_SO_ID PHT_TYPE.A_NUM,B_LOI OUT VARCHAR2)
AS
    B_I1 NUMBER; B_MA_TK VARCHAR2(20); B_TK_THUE VARCHAR2(20);B_MA_TK_TG VARCHAR2(20);
    B_TIEN NUMBER; B_CHENH NUMBER; B_L_CT VARCHAR2(1);
BEGIN

B_CHENH:=0;
FOR B_LP IN 1..A_SO_ID.COUNT LOOP
    SELECT L_CT,TIEN_QD INTO B_L_CT,B_TIEN FROM BH_DO_BH_CN WHERE MA_DVI=B_MA_DVI AND SO_ID=A_SO_ID(B_LP);
    IF B_L_CT<>'D' THEN B_LOI:='loi:Chi hach toan doi phong:loi'; RETURN; END IF;
    B_CHENH:=B_CHENH+B_TIEN;
END LOOP;
IF B_CHENH=0 THEN B_LOI:=''; RETURN; END IF;
B_LOI:='loi:Loi hach toan doi phong:loi';
B_MA_TK:=FBH_KT_TK_TRA(B_MA_DVI,B_NGAY_HT,'D','CN_DO');
IF B_CHENH<0 THEN
    B_CHENH:=-B_CHENH; B_MA_TK_TG:=PKH_MA_LCT_TRA_TK(B_MA_DVI,'TT','D',B_NGAY_HT,'P',' ','C');
    INSERT INTO KET_QUA(C1,C2,N1,C4,N10) VALUES('N',B_MA_TK,B_CHENH,'Dieu chinh chenh lech ty gia doi phong',1);
    INSERT INTO KET_QUA(C1,C2,N1,N10) VALUES('C',B_MA_TK_TG,B_CHENH,2);
ELSIF B_CHENH>0 THEN
    B_MA_TK_TG:=PKH_MA_LCT_TRA_TK(B_MA_DVI,'TT','D',B_NGAY_HT,'P',' ','C');
    INSERT INTO KET_QUA(C1,C2,N1,C4,N10) VALUES('N',B_MA_TK_TG,B_CHENH,'Dieu chinh chenh lech ty gia doi phong',1);
    INSERT INTO KET_QUA(C1,C2,N1,N10) VALUES('C',B_MA_TK,B_CHENH,2);
END IF;
B_LOI:='';
EXCEPTION WHEN OTHERS THEN IF B_LOI IS NULL THEN RAISE PROGRAM_ERROR; ELSE NULL; END IF;
END;
/
CREATE OR REPLACE PROCEDURE PBH_KT_HTOAN_HD_TT_CT
    (b_ma_dvi varchar2,b_ngay_ht number,b_nha varchar2,b_tk_nha varchar2,a_so_id pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_noite varchar2(5); b_so_id number; b_pt varchar2(1); b_ma_nt varchar2(5); b_tien_qd number;
    b_ma_kh varchar2(20); b_gchu nvarchar2(200); b_ma_tk varchar2(20); b_tk_do varchar2(20); b_do_qd number;
    b_phi_g number; b_phi_t number; b_phi_s number; b_thue number; b_chenh number; b_no number; b_co number; b_so_id_hd number;
    b_ma_tk_cnk varchar2(20); b_kieu_do varchar2(1); b_kieu_phv varchar2(1); b_chia_nb number; b_ngay_tt number;
    b_bt number; b_bt_d number; b_ngay_hl number; b_nam_hl number; b_nam_tt number; b_nam_ng number; b_phong varchar2(10);
    b_hhong_qd number; b_htro_qd number; b_tk_hhong varchar2(20); b_tk_htro varchar2(20); b_tk_cndl varchar2(20); b_tke_ph varchar2(1);
begin
-- Dan - Thanh toan phi
b_bt:=0; b_noite:=FTT_TRA_NOITE(b_ma_dvi);
b_tk_hhong:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DC_HH_DL');
b_tk_htro:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DC_HT_DL');
b_tk_cndl:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_HH_DL');
b_tke_ph:=FKH_NV_TSO(b_ma_dvi,'KT','BH','phong');
b_tk_do:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CN_FL_DO');
b_ma_tk_cnk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_PH_KH');
for b_lp in 1..a_so_id.count loop
    b_loi:='loi:Loi xu ly dong '||trim(to_char(b_lp))||':loi';
    b_bt_d:=b_bt+1;
    b_ngay_tt:=FBH_HD_TT_NGAY(b_ma_dvi,a_so_id(b_lp)); b_nam_tt:=PKH_SO_NAM(b_ngay_tt);
    b_phi_t:=0; b_phi_s:=0; b_phi_g:=0; b_thue:=0;
    delete bh_hd_goc_htct_temp1; delete bh_hd_goc_htct_temp;
    insert into bh_hd_goc_htct_temp1(phong,lh_nv,ttoan_qd,phi_qd,hhong_qd,htro_qd,dvu_qd) 
        select FBH_HD_MA_BP(b_ma_dvi,so_id),FBH_TKE_KT_NV(b_ma_dvi,lh_nv),ttoan_qd,phi_qd,hhong_qd,htro_qd,0
            from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp) and pt not in('N','H');
    insert into bh_hd_goc_htct_temp(phong,lh_nv,ttoan_qd,phi_qd,hhong_qd,htro_qd,dvu_qd) 
        select phong,lh_nv,sum(ttoan_qd),sum(phi_qd),sum(hhong_qd),sum(htro_qd),0 from bh_hd_goc_htct_temp1 group by phong,lh_nv;
    for r_lp1 in (select so_id,sum(phi_qd) phi_dt_qd,sum(thue_qd) thue_qd from bh_hd_goc_ttpt
        where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp) and pt not in('N','H') group by so_id) loop
        b_kieu_do:=FBH_DONG(b_ma_dvi,r_lp1.so_id);
        if b_kieu_do='V' then
            b_kieu_phv:=FBH_DONG_PHV(b_ma_dvi,r_lp1.so_id);
        else
            b_kieu_phv:='C';
        end if;
        if b_kieu_phv='C' then
            b_ma_tk_cnk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_PH_KH');
        else
            b_ma_tk_cnk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CN_FL_DO');
        end if;
        b_thue:=b_thue+r_lp1.thue_qd;
        if r_lp1.phi_dt_qd<0 then
            b_phi_g:=b_phi_g+r_lp1.phi_dt_qd;
        else
            b_so_id:=r_lp1.so_id;
            b_ngay_hl:=FBH_HD_NGAY_HL(b_ma_dvi,b_so_id,b_ngay_tt); b_nam_hl:=PKH_SO_NAM(b_ngay_hl);
            for r_lp in (select ngay,sum(phi_qd) phi_dt_qd,sum(thue_qd) thue_qd from bh_hd_goc_ttpt
                where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp) and so_id=b_so_id and pt not in('N','H') group by ngay) loop
                b_nam_ng:=PKH_SO_NAM(r_lp.ngay);
                if (b_nam_tt<b_nam_ng and add_months(PKH_SO_CDT(b_ngay_hl),12)<PKH_SO_CDT(r_lp.ngay)) or (b_nam_hl<3000 and b_nam_hl>b_nam_tt) then
                    b_phi_s:=b_phi_s+r_lp.phi_dt_qd;
                else
                    b_phi_t:=b_phi_t+r_lp.phi_dt_qd;
                end if;
            end loop;
        end if;
    end loop;
    select nvl(sum(phi_qd),0) into b_chia_nb from bh_hd_goc_ttpb where dvi_xl=b_ma_dvi and so_id_tt=a_so_id(b_lp) and ma_dvi<>b_ma_dvi;
    select nvl(sum(tien_qd),0) into b_no from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp) and pt='N';
    select nvl(sum(tien_qd),0) into b_co from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp) and pt='C';
    b_chenh:=b_phi_t+b_phi_s+b_phi_g+b_thue+b_no-b_co;
    select distinct so_id into b_so_id_hd from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp);
    b_ma_kh:=FBH_HD_MA_KH(b_ma_dvi,b_so_id_hd);
    if trim(b_ma_kh) is not null and b_ma_kh<>'VANGLAI' then
        select min(ten) into b_gchu from bh_hd_ma_kh where ma_dvi=b_ma_dvi and ma=b_ma_kh;
    end if;
    if b_phi_g<>0 then
        b_gchu:=substr('Giam phi khach hang: '||trim(b_gchu),1,200);
        b_bt:=b_bt+1;
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_PH_TL');
        insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,-b_phi_g,b_gchu,b_bt); b_gchu:='';
    end if;
    if trim(b_tk_do) is not null then
        select nvl(sum(tien_qd),0) into b_do_qd from bh_hd_do_ps where ma_dvi=b_ma_dvi and so_id_ps=a_so_id(b_lp);
    else
        b_do_qd:=0;
    end if;
    if b_co>0 then
        b_gchu:=substr('Cho no phi: '||b_ma_kh||', '||trim(b_gchu),1,200);
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk_cnk,b_co,b_gchu,b_bt);
        b_gchu:='';
    else
       b_gchu:=substr('Khach hang TT phi: '||trim(b_gchu),1,200);
       select min(pt),min(ma_nt) into b_pt,b_ma_nt from bh_hd_goc_ttct where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp);
       select nvl(sum(tien_qd),0) into b_tien_qd from (select tien_qd from bh_hd_goc_ttct where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp)) where tien_qd>0;
       if b_tien_qd>0 then
            if b_pt='C' then b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_PH_KH');
            elsif b_pt='K' then b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_PH_KD');
            elsif b_pt='H' then b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_PH_DL');
            elsif b_pt='B' then b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CN_FL_DO');
            elsif b_tk_nha is null then
                if b_ma_nt=b_noite then
                    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TMV',b_ngay_ht,'N');
                else
                    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TMN',b_ngay_ht,'N');
                end if;
            else
                if b_ma_nt=b_noite then
                    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TGV',b_ngay_ht,'N');
                else
                    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TGN',b_ngay_ht,'N');
                end if;
            end if;
            if b_pt='T' then
                b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,b_tien_qd,b_gchu,b_bt); b_gchu:='';
                b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk_cnk,b_tien_qd-b_do_qd,b_bt);
                if b_do_qd<>0 then
                    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_do,b_do_qd,b_bt);
                end if;
                b_ma_tk:=b_ma_tk_cnk;
            end if;
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,b_tien_qd,b_gchu,b_bt); b_gchu:='';
            b_chenh:=b_chenh-b_tien_qd;
       end if;
       select nvl(sum(tien_qd),0) into b_tien_qd from (select tien_qd from bh_hd_goc_ttct where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp)) where tien_qd<0;
       if b_tien_qd<0 then
            if b_pt='C' then b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_PH_KH');
            elsif b_pt='K' then b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_PH_KD');
            elsif b_pt='H' then b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_PH_DL');
            elsif b_pt='B' then b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CN_FL_DO');
            elsif b_tk_nha is null then
                if b_ma_nt=b_noite then
                    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','CMV',b_ngay_ht,'C');
                else
                    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','CMN',b_ngay_ht,'C');
                end if;
            else
                if b_ma_nt=b_noite then
                    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','CGV',b_ngay_ht,'C');
                else
                    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','CGN',b_ngay_ht,'C');
                end if;
            end if;
            if b_pt='T' then
                b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk_cnk,-b_tien_qd+b_do_qd,b_gchu,b_bt); b_gchu:='';
                if b_do_qd<>0 then
                    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_tk_do,-b_do_qd,b_bt);
                end if;
                b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,-b_tien_qd,b_bt);
                b_ma_tk:=b_ma_tk_cnk;
            end if;
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('C',b_ma_tk,-b_tien_qd,b_gchu,b_bt);
            b_chenh:=b_chenh-b_tien_qd;
       end if;
    end if;
    if b_chenh>0 then
        b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'P',' ','C');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,b_chenh,b_bt);
    end if;
    if b_co<0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk_cnk,-b_co,b_bt);
    end if;
    if b_phi_t>0 then
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_PH_BH');
        for r_lp_tke in (select * from bh_hd_goc_htct_temp order by phong,lh_nv) loop
            b_bt:=b_bt+1;
            if b_tke_ph='C' then b_gchu:=r_lp_tke.lh_nv||'.'||r_lp_tke.phong; else b_gchu:=r_lp_tke.lh_nv; end if;
            insert into ket_qua(c1,c2,c3,n1,n10) values('C',b_ma_tk,b_gchu,r_lp_tke.phi_qd,b_bt);
        end loop;
        b_gchu:='';
    end if;
    if b_phi_s>0 then
        b_bt:=b_bt+1;
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_PH_TR');
        insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_phi_s,b_bt);
    end if;
    if b_no<>0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk_cnk,b_no,b_bt);
    end if;
    if b_thue<>0 then
        b_bt:=b_bt+1;
        if b_thue>0 then
            select min(don) into b_gchu from bh_hd_goc_vat where ma_dvi=b_ma_dvi and so_id_vat
                in (select distinct so_id_vat from bh_hd_goc_vat_ct where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp));
            b_ma_tk:=FBH_KT_TK_THUE(b_ma_dvi,b_ngay_ht,'G','DT_PH_BH');
            insert into ket_qua(c1,c2,n1,c4,n10) values('C',b_ma_tk,b_thue,b_gchu,b_bt);
        else
            b_ma_tk:=FBH_KT_TK_THUE(b_ma_dvi,b_ngay_ht,'G','CH_PH_TL');
            insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,-b_thue,b_gchu,b_bt);
        end if;
    end if;
    if b_chenh<0 then
        b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'D',' ','C');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,-b_chenh,b_bt);
    end if;
    if b_bt>b_bt_d then
        select count(*) into b_no from ket_qua where c2<>b_ma_tk_cnk and (n10 between b_bt_d and b_bt);
        if b_no=0 then
            delete ket_qua where n10 between b_bt_d and b_bt;
        else
            select nvl(sum(n1),0),max(n10) into b_no,b_i1 from ket_qua where c1='N' and c2=b_ma_tk_cnk and (n10 between b_bt_d and b_bt);
            select nvl(sum(n1),0),max(n10) into b_co,b_i2 from ket_qua where c1='C' and c2=b_ma_tk_cnk and (n10 between b_bt_d and b_bt);
            if b_no<>0 and b_co<>0 and sign(b_no)=sign(b_co) then
                delete ket_qua where c2=b_ma_tk_cnk and (n10 between b_bt_d and b_bt);
                if abs(b_no)>abs(b_co) then
                    b_bt:=b_bt+1; b_no:=b_no-b_co;
                    insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk_cnk,b_no,b_i1);
                elsif abs(b_no)<abs(b_co) then
                    b_bt:=b_bt+1; b_co:=b_co-b_no;
                    insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk_cnk,b_co,b_i2);
                end if;
            end if;
        end if;
    end if;
    if b_chia_nb<>0 then
        if b_chia_nb>0 then
            if b_phi_s<>0 then
                b_phi_s:=round(b_chia_nb*b_phi_s/(b_phi_t+b_phi_s),0);
                b_phi_t:=b_chia_nb-b_phi_s;
            else    b_phi_s:=0; b_phi_t:=b_chia_nb;
            end if;
            b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_PH_BH');
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,b_phi_t,'Phi phan chia dong BH noi bo',b_bt);
            if b_phi_s<>0 then
                b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_PH_TR');
                b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,b_phi_s,b_bt);
            end if;
            b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CN_LE_DV');
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_chia_nb,b_bt);
        else
            b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CN_LE_DV');
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,-b_chia_nb,'Hoan phi phan chia dong BH noi bo',b_bt);
            b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_PH_TL');
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,-b_chia_nb,b_bt);
        end if;
    end if;
    if trim(b_tk_hhong) is not null then
        select nvl(sum(hhong_qd),0),nvl(sum(htro_qd),0) into b_hhong_qd,b_htro_qd from bh_hd_goc_ttpb where
            ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp) and pt not in('N','H');
        if b_hhong_qd<>0 and trim(b_tk_hhong) is not null then
            if b_hhong_qd>0 then
                b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_tk_hhong,b_hhong_qd,'Du chi hoa hong',b_bt);
                b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_cndl,b_hhong_qd,b_bt);
            else
                b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_tk_cndl,-b_hhong_qd,'Du thu doi hoa hong',b_bt);
                b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_hhong,-b_hhong_qd,b_bt);
            end if;
        end if;
        if b_htro_qd<>0 and trim(b_tk_htro) is not null then
            if b_htro_qd>0 then
                b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_tk_htro,b_htro_qd,'Du chi ho tro',b_bt);
                b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_cndl,b_htro_qd,b_bt);
            else
                b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_tk_cndl,-b_htro_qd,'Du thu doi ho tro',b_bt);
                b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_htro,-b_htro_qd,b_bt);
            end if;
        end if;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
CREATE OR REPLACE PROCEDURE PBH_KT_HTOAN_HD_TT_CH
    (b_ma_dvi varchar2,b_ngay_ht number,b_nha varchar2,b_tk_nha varchar2,a_so_id pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_noite varchar2(5); b_so_id number; b_pt varchar2(1); b_ma_nt varchar2(5); b_tien_qd number;
    b_ma_kh varchar2(20); b_gchu nvarchar2(200); b_ma_tk varchar2(20); b_tk_do varchar2(20); b_do_qd number;
    b_phi_g number; b_phi_t number; b_phi_s number; b_thue number; b_chenh number; b_no number; b_co number;
    b_ma_tk_cnk varchar2(20); b_kieu_do varchar2(1); b_kieu_phv varchar2(1); b_chia_nb number;
    b_ngay_tt number; b_bt number; b_bt_d number; b_ngay_hl number; b_nam_hl number; b_nam_tt number; b_nam_ng number;
    b_hhong_qd number; b_htro_qd number; b_tk_hhong varchar2(20); b_tk_htro varchar2(20); b_tk_cndl varchar2(20);
    b_so_id_hd number;b_ma_gt varchar2(20); b_loai_dly varchar2(1);
begin
/*
declare 
    b_ma_dvi varchar2(20):='051';
    b_ngay_ht number;a_so_id pht_type.a_num;b_loi varchar2(200);
begin
delete ket_qua;delete temp_tt1;
-- a_so_id(1) duoc gan voi so_id_tt
a_so_id(1):=20210405000015;
b_ngay_ht:=20210405;
PBH_KT_HTOAN_HD_TT_CH(b_ma_dvi,b_ngay_ht,' ',' ',a_so_id,b_loi);
if b_loi is not null then
    raise_application_error(-20105,b_loi);
end if;
end;

select n20,c1,c2,c3,n1,c4,n10 from ket_qua;

*/
-- Dan - Thanh toan phi
b_bt:=0; b_noite:=FTT_TRA_NOITE(b_ma_dvi);
b_tk_hhong:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DC_HH_DL');
b_tk_htro:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DC_HT_DL');
b_tk_cndl:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_HH_DL');
b_tk_do:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CN_FL_DO');
b_ma_tk_cnk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_PH_KH');
for b_lp in 1..a_so_id.count loop
    b_loi:='loi:Loi xu ly dong '||trim(to_char(b_lp))||':loi';
    b_bt_d:=b_bt+1;
    select min(so_id) into b_so_id_hd from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp);
    b_ngay_tt:=FBH_HD_TT_NGAY(b_ma_dvi,a_so_id(b_lp)); b_nam_tt:=PKH_SO_NAM(b_ngay_tt);
    b_phi_t:=0; b_phi_s:=0; b_phi_g:=0; b_thue:=0;
    for r_lp1 in (select so_id,sum(phi_qd) phi_dt_qd,sum(thue_qd) thue_qd from bh_hd_goc_ttpt
        where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp) and pt not in('N','H') group by so_id) loop
        b_kieu_do:=FBH_DONG(b_ma_dvi,r_lp1.so_id);
        if b_kieu_do='V' then
            b_kieu_phv:=FBH_DONG_PHV(b_ma_dvi,r_lp1.so_id);
        else
            b_kieu_phv:='C';
        end if;
        if b_kieu_phv='C' then
            b_ma_tk_cnk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_PH_KH');
        else
            b_ma_tk_cnk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CN_FL_DO');
        end if;
        b_thue:=b_thue+r_lp1.thue_qd;
        if r_lp1.phi_dt_qd<0 then
            b_phi_g:=b_phi_g+r_lp1.phi_dt_qd;
        else
            b_so_id:=r_lp1.so_id;
            b_ngay_hl:=FBH_HD_NGAY_HL(b_ma_dvi,b_so_id,b_ngay_tt); b_nam_hl:=PKH_SO_NAM(b_ngay_hl);
            for r_lp in (select ngay,sum(phi_qd) phi_dt_qd,sum(thue_qd) thue_qd from bh_hd_goc_ttpt
                where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp) and so_id=b_so_id and pt not in('N','H') group by ngay order by ngay) loop
                b_nam_ng:=PKH_SO_NAM(r_lp.ngay);
                if (b_nam_tt<b_nam_ng and add_months(PKH_SO_CDT(b_ngay_hl),12)<=PKH_SO_CDT(r_lp.ngay)) or (b_nam_hl<3000 and b_nam_hl>b_nam_tt) then
                    b_phi_s:=b_phi_s+r_lp.phi_dt_qd;
                else
                    b_phi_t:=b_phi_t+r_lp.phi_dt_qd;
                end if;
            end loop;
        end if;
    end loop;
    select nvl(sum(phi_qd),0) into b_chia_nb from bh_hd_goc_ttpb where dvi_xl=b_ma_dvi and so_id_tt=a_so_id(b_lp) and ma_dvi<>b_ma_dvi;
    select nvl(sum(tien_qd),0) into b_no from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp) and pt='N';
    select nvl(sum(tien_qd),0) into b_co from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp) and pt='C';
    b_chenh:=b_phi_t+b_phi_s+b_phi_g+b_thue+b_no-b_co;
    select min(ma_kh) into b_ma_kh from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp);
    if trim(b_ma_kh) is not null and b_ma_kh<>'VANGLAI' then
        select min(ten) into b_gchu from bh_hd_ma_kh where ma_dvi=b_ma_dvi and ma=b_ma_kh;
    end if;
    if b_phi_g<>0 then
        b_gchu:=substr('Giam phi khach hang: '||trim(b_gchu),1,200);
        b_bt:=b_bt+1;
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_PH_TL');
        insert into ket_qua(n20,c1,c2,n1,c4,n10) values(1,'N',b_ma_tk,-b_phi_g,b_gchu,b_bt); b_gchu:='';
    end if;
    if trim(b_tk_do) is not null then
        select nvl(sum(tien_qd),0) into b_do_qd from bh_hd_do_ps where ma_dvi=b_ma_dvi and so_id_ps=a_so_id(b_lp);
    else
        b_do_qd:=0;
    end if;
    if b_co>0 then
        b_gchu:=substr('Cho no phi khach hang: '||trim(b_gchu),1,200);
        b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,c4,n10) values(2,'N',b_ma_tk_cnk,b_co,b_gchu,b_bt);
    else
       b_gchu:=substr('Khach hang TT phi: '||trim(b_gchu),1,200);
       select min(pt),min(ma_nt) into b_pt,b_ma_nt from bh_hd_goc_ttct where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp);
       select nvl(sum(tien_qd),0) into b_tien_qd from (select tien_qd from bh_hd_goc_ttct where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp)) where tien_qd>0;
       if b_tien_qd>0 then
            if b_pt='C' then b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_PH_KH');
            elsif b_pt='K' then b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_PH_KD');
            elsif b_pt='H' then b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_PH_DL');
            elsif b_pt='B' then b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CN_FL_DO');
            elsif b_pt='D' then
                b_ma_tk:=b_tk_cndl;
                select max(ma_gt) into b_ma_gt from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id_hd;
                --select max(loai_dly) into b_loai_dly from bh_dl_ma_kh where ma_dvi=b_ma_dvi and ma=b_ma_gt;
                --if b_loai_dly='K' then b_ma_tk:='13118'; end if;
            elsif b_tk_nha is null then
                if b_ma_nt=b_noite then
                    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TMV',b_ngay_ht,'N');
                else
                    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TMN',b_ngay_ht,'N');
                end if;
            else
                if b_ma_nt=b_noite then
                    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TGV',b_ngay_ht,'N');
                else
                    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TGN',b_ngay_ht,'N');
                end if;
            end if;
            if b_pt='T' then
                b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,c4,n10) values(3,'N',b_ma_tk,b_tien_qd,b_gchu,b_bt); b_gchu:='';
                b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,n10) values(4,'C',b_ma_tk_cnk,b_tien_qd-b_do_qd,b_bt);
                if b_do_qd<>0 then
                    b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,n10) values(5,'C',b_tk_do,b_do_qd,b_bt);
                end if;
                b_ma_tk:=b_ma_tk_cnk;
            end if;
            b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,c4,n10) values(6,'N',b_ma_tk,b_tien_qd,b_gchu,b_bt); b_gchu:='';
            b_chenh:=b_chenh-b_tien_qd;
       end if;
       select nvl(sum(tien_qd),0) into b_tien_qd from (select tien_qd from bh_hd_goc_ttct where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp)) where tien_qd<0;
       if b_tien_qd<0 then
            if b_pt='C' then b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_PH_KH');
            elsif b_pt='K' then b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_PH_KD');
            elsif b_pt='H' then b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_PH_DL');
            elsif b_pt='B' then b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CN_FL_DO');
            elsif b_tk_nha is null then
                if b_ma_nt=b_noite then
                    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','CMV',b_ngay_ht,'C');
                else
                    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','CMN',b_ngay_ht,'C');
                end if;
            else
                if b_ma_nt=b_noite then
                    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','CGV',b_ngay_ht,'C');
                else
                    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','CGN',b_ngay_ht,'C');
                end if;
            end if;
            if b_pt='T' then
                b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,c4,n10) values(7,'N',b_ma_tk_cnk,-b_tien_qd+b_do_qd,b_gchu,b_bt); b_gchu:='';
                if b_do_qd<>0 then
                    b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,n10) values(8,'N',b_tk_do,-b_do_qd,b_bt);
                end if;
                b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,n10) values(9,'C',b_ma_tk,-b_tien_qd,b_bt);
                b_ma_tk:=b_ma_tk_cnk;
            end if;
            b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,c4,n10) values(10,'C',b_ma_tk,-b_tien_qd,b_gchu,b_bt);
            b_chenh:=b_chenh-b_tien_qd;
       end if;
    end if;

    if b_chenh>0 then
        b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'P',' ','C');
        b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,n10) values(11,'N',b_ma_tk,b_chenh,b_bt);
    end if;
    if b_co<0 then
        b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,n10) values(12,'C',b_ma_tk_cnk,-b_co,b_bt);
    end if;
    if b_phi_t>0 then
        b_bt:=b_bt+1;
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_PH_BH');
        insert into ket_qua(n20,c1,c2,n1,n10) values(13,'C',b_ma_tk,b_phi_t,b_bt);
    end if;
    if b_phi_s>0 then
        b_bt:=b_bt+1;
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_PH_TR');
        insert into ket_qua(n20,c1,c2,n1,n10) values(14,'C',b_ma_tk,b_phi_s,b_bt);
    end if;
    if b_no<>0 then
        b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,n10) values(15,'C',b_ma_tk_cnk,b_no,b_bt);
    end if;
    if b_thue<>0 then
        b_bt:=b_bt+1;
        if b_thue>0 then
            /*
            select min(don) into b_gchu from bh_hd_goc_vat where ma_dvi=b_ma_dvi and so_id_vat
                in (select distinct so_id_vat from bh_hd_goc_vat_ct where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp));
            */
            select min(mau||'+'||seri||'+'||so_don) into b_gchu from bh_hd_goc_vat where ma_dvi=b_ma_dvi and so_id_vat
                in (select distinct so_id_vat from bh_hd_goc_vat_ct where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp));
            b_ma_tk:=FBH_KT_TK_THUE(b_ma_dvi,b_ngay_ht,'G','DT_PH_BH');
            insert into ket_qua(n20,c1,c2,n1,c4,n10) values(16,'C',b_ma_tk,b_thue,b_gchu,b_bt);
        else    b_ma_tk:=FBH_KT_TK_THUE(b_ma_dvi,b_ngay_ht,'G','CH_PH_TL');
            insert into ket_qua(n20,c1,c2,n1,c4,n10) values(17,'N',b_ma_tk,-b_thue,b_gchu,b_bt);
        end if;
    end if;
    if b_chenh<0 then
        b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'D',' ','C');
        b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,n10) values(18,'C',b_ma_tk,-b_chenh,b_bt);
    end if;
    if b_bt>b_bt_d then
        select count(*) into b_no from ket_qua where c2<>b_ma_tk_cnk and (n10 between b_bt_d and b_bt);
        if b_no=0 then
            delete ket_qua where n10 between b_bt_d and b_bt;
            b_i1:=0;
        else
            select nvl(sum(n1),0),max(n10) into b_no,b_i1 from ket_qua where c1='N' and c2=b_ma_tk_cnk and (n10 between b_bt_d and b_bt);
            select nvl(sum(n1),0),max(n10) into b_co,b_i2 from ket_qua where c1='C' and c2=b_ma_tk_cnk and (n10 between b_bt_d and b_bt);
            if b_no<>0 and b_co<>0 and sign(b_no)=sign(b_co) then
                delete ket_qua where c2=b_ma_tk_cnk and (n10 between b_bt_d and b_bt);
                if abs(b_no)>abs(b_co) then
                    b_bt:=b_bt+1; b_no:=b_no-b_co;
                    insert into ket_qua(n20,c1,c2,n1,n10) values(19,'N',b_ma_tk_cnk,b_no,b_i1);
                elsif abs(b_no)<abs(b_co) then
                    b_bt:=b_bt+1; b_co:=b_co-b_no;
                    insert into ket_qua(n20,c1,c2,n1,n10) values(20,'C',b_ma_tk_cnk,b_co,b_i2);
                end if;
            end if;
        end if;
    end if;
    if b_chia_nb<>0 then
        if b_chia_nb>0 then
            if b_phi_s<>0 then
                b_phi_s:=round(b_chia_nb*b_phi_s/(b_phi_t+b_phi_s),0);
                b_phi_t:=b_chia_nb-b_phi_s;
            else    b_phi_s:=0; b_phi_t:=b_chia_nb;
            end if;
            -- Hung: them b_phi_t>0 and b_phi_s>0 and b_chia_nb>0
            if b_phi_t>0 and b_phi_s>0 and b_chia_nb>0 then
                b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_PH_BH');
                b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,c4,n10) values(21,'N',b_ma_tk,b_phi_t,'Phi phan chia dong BH noi bo',b_bt);
                b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CN_LE_DV');
                b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,n10) values(23,'C',b_ma_tk,b_phi_t,b_bt);
            else
                b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_PH_BH');
                b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,c4,n10) values(21,'N',b_ma_tk,b_phi_t,'Phi phan chia dong BH noi bo',b_bt);
                if b_phi_s<>0 then
                    b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_PH_TR');
                    b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,n10) values(22,'N',b_ma_tk,b_phi_s,b_bt);
                end if;
                b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CN_LE_DV');
                b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,n10) values(23,'C',b_ma_tk,b_chia_nb,b_bt);
            end if;
        else
            b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CN_LE_DV');
            b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,c4,n10) values(24,'N',b_ma_tk,-b_chia_nb,'Hoan phi phan chia dong BH noi bo',b_bt);
            b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_PH_TL');
            b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,n10) values(25,'N',b_ma_tk,-b_chia_nb,b_bt);
        end if;
    end if;
    if trim(b_tk_hhong) is not null then
        select nvl(sum(hhong_qd),0),nvl(sum(htro_qd),0) into b_hhong_qd,b_htro_qd from bh_hd_goc_ttpb where
            ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp) and pt not in('N','H');
        if b_hhong_qd<>0 then
            if b_hhong_qd>0 then
                b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,c4,n10) values(26,'N',b_tk_hhong,b_hhong_qd,'Du chi hoa hong',b_bt);
                b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,n10) values(27,'C',b_tk_cndl,b_hhong_qd,b_bt);
            else
                b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,c4,n10) values(28,'N',b_tk_cndl,-b_hhong_qd,'Du thu doi hoa hong',b_bt);
                b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,n10) values(29,'C',b_tk_hhong,-b_hhong_qd,b_bt);
            end if;
        end if;
        if b_htro_qd<>0 then
            if b_htro_qd>0 then
                b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,c4,n10) values(30,'N',b_tk_htro,b_htro_qd,'Du chi ho tro',b_bt);
                b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,n10) values(31,'C',b_tk_cndl,b_htro_qd,b_bt);
            else
                b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,c4,n10) values(32,'N',b_tk_cndl,-b_htro_qd,'Du thu doi ho tro',b_bt);
                b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,n10) values(33,'C',b_tk_htro,-b_htro_qd,b_bt);
            end if;
        end if;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
CREATE OR REPLACE PROCEDURE PBH_KT_HTOAN_PB_TT
    (B_MA_DVI VARCHAR2,B_NGAY_HT NUMBER,A_SO_ID PHT_TYPE.A_NUM,B_LOI OUT VARCHAR2)
AS
    B_GCHU NVARCHAR2(200); B_MA_TK VARCHAR2(20); B_TK_THUE VARCHAR2(20);B_BT NUMBER; B_CHIA_NB NUMBER;
    b_dvi_xl varchar2(20);
BEGIN
-- Hung: them b_dvi_xl
B_BT:=0;
FOR B_LP IN 1..A_SO_ID.COUNT LOOP
    B_LOI:='loi:Loi xu ly dong '||TRIM(TO_CHAR(B_LP))||':loi';
    SELECT NVL(SUM(PHI_QD),0),NVL(MIN(DVI_XL),' ') INTO B_CHIA_NB,B_GCHU
        FROM BH_HD_GOC_TTPB WHERE MA_DVI=B_MA_DVI AND SO_ID_TT=A_SO_ID(B_LP) and pt<>'H';
    b_dvi_xl:=B_GCHU;
    IF B_CHIA_NB>0 THEN
        B_GCHU:='Nhan phan chia phi dong BH tu '||B_GCHU;
        B_MA_TK:=FBH_KT_TK_TRA(B_MA_DVI,B_NGAY_HT,'D','CN_FL_DV');
        B_BT:=B_BT+1; INSERT INTO KET_QUA(C1,C2,c3,N1,C4,N10) VALUES('N',B_MA_TK,b_dvi_xl,B_CHIA_NB,B_GCHU,B_BT);
        B_MA_TK:=FBH_KT_TK_TRA(B_MA_DVI,B_NGAY_HT,'G','DT_PH_BH');
        B_BT:=B_BT+1; INSERT INTO KET_QUA(C1,C2,N1,N10) VALUES('C',B_MA_TK,B_CHIA_NB,B_BT);
    ELSIF B_CHIA_NB<0 THEN
        B_GCHU:='Nhan phan chia hoan phi dong BH tu '||B_GCHU;
        B_MA_TK:=FBH_KT_TK_TRA(B_MA_DVI,B_NGAY_HT,'G','CH_PH_TL');
        B_BT:=B_BT+1; INSERT INTO KET_QUA(C1,C2,N1,C4,N10) VALUES('N',B_MA_TK,-B_CHIA_NB,B_GCHU,B_BT);
        B_MA_TK:=FBH_KT_TK_TRA(B_MA_DVI,B_NGAY_HT,'D','CN_FL_DV');
        B_BT:=B_BT+1; INSERT INTO KET_QUA(C1,C2,N1,N10) VALUES('C',B_MA_TK,-B_CHIA_NB,B_BT);
    END IF;
END LOOP;
B_LOI:='';
EXCEPTION WHEN OTHERS THEN IF B_LOI IS NULL THEN RAISE PROGRAM_ERROR; ELSE NULL; END IF;
END;
/
CREATE OR REPLACE procedure PBH_KT_HTOAN_PB_HU
    (B_MA_DVI VARCHAR2,B_NGAY_HT NUMBER,A_SO_ID PHT_TYPE.A_NUM,B_LOI OUT VARCHAR2)
AS
    B_GCHU NVARCHAR2(200); B_MA_TK VARCHAR2(20); B_TK_THUE VARCHAR2(20); B_CHIA_NB NUMBER; B_BT NUMBER;
    A_SO_ID_N PHT_TYPE.A_NUM; b_i number; b_kt_trung number;b_phi_ct number;
BEGIN
/*
    Hung: viet lai lay theo lh_nv va dvi_xl
*/
/*
B_BT:=0;
FOR B_LP IN 1..A_SO_ID.COUNT LOOP
    B_LOI:='loi:Loi xu ly dong '||TRIM(TO_CHAR(B_LP))||':loi';
    SELECT NVL(SUM(PHI_DT_QD),0),NVL(MIN(DVI_XL),' ') INTO B_CHIA_NB,B_GCHU
        FROM BH_HD_GOC_TTPB WHERE MA_DVI=B_MA_DVI AND SO_ID_TT=A_SO_ID(B_LP);
    IF (B_CHIA_NB<>0) THEN
        B_GCHU:='Tra chia doanh thu dong BH do huy HD tu '||B_GCHU;
        B_MA_TK:=FBH_KT_TK_TRA(B_MA_DVI,B_NGAY_HT,'G','CH_PH_HU');
        B_BT:=B_BT+1; INSERT INTO KET_QUA(C1,C2,N1,C4,N10) VALUES('N',B_MA_TK,-B_CHIA_NB,B_GCHU,B_BT);
        B_MA_TK:=FBH_KT_TK_TRA(B_MA_DVI,B_NGAY_HT,'D','CN_FL_DV');
        B_BT:=B_BT+1; INSERT INTO KET_QUA(C1,C2,N1,N10) VALUES('C',B_MA_TK,-B_CHIA_NB,B_BT);
    END IF;
END LOOP;
*/
delete ket_qua;
b_loi:='loi:PBH_KT_HTOAN_PB_HU dvi:'||b_ma_dvi||':loi';
b_bt:=1;
for b_lp in 1..a_so_id.count loop
    if b_lp=1 then a_so_id_n(1):=a_so_id(b_lp);
    else
        b_kt_trung:=0;
        for b_i in 1..a_so_id.count loop
            if a_so_id_n(b_i)=a_so_id(b_lp) then b_kt_trung:=1; exit; end if;
        end loop;
        if b_kt_trung=0 then a_so_id_n(a_so_id.count+1):=a_so_id(b_lp); end if;
    end if;
end loop;
for b_lp in 1..a_so_id_n.count loop
    for r_pt in (select dvi_xl,lh_nv,nvl(sum(phi_qd),0) phi from bh_hd_goc_ttpb 
        where ma_dvi=b_ma_dvi and dvi_xl<>ma_dvi and so_id_tt=a_so_id(b_lp) and pt='H' group by dvi_xl,lh_nv order by dvi_xl,lh_nv) loop
        b_phi_ct:=-r_pt.phi;b_gchu:='Phai tra noi bo - '||r_pt.dvi_xl;
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_PH_HU');
        b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,c3,n1,c4,n10) values(15,'N',b_ma_tk,r_pt.lh_nv,b_phi_ct,b_gchu,b_bt);
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CN_LE_DV');
        b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,c3,n1,c4,n10) values(15,'C',b_ma_tk,r_pt.dvi_xl,b_phi_ct,' ',b_bt);
    end loop;
end loop;
B_LOI:='';
EXCEPTION WHEN OTHERS THEN IF B_LOI IS NULL THEN RAISE PROGRAM_ERROR; ELSE NULL; END IF;
END;
/
CREATE OR REPLACE PROCEDURE PBH_KT_HTOAN_DL_HH
    (b_ma_dvi varchar2,b_ngay_ht number,b_nha varchar2,b_tk_nha varchar2,a_so_id_n pht_type.a_num,a_so_hd pht_type.a_var,b_loi out varchar2)
AS
    b_i1 number; b_ma_kh varchar2(20); b_gchu nvarchar2(200); b_ma_tk varchar2(20); b_tk_thue varchar2(20);
    b_noite varchar2(5); b_pt_thue varchar2(1); b_bt number; b_hhong number; b_htro number; b_chenh number;
    b_tien number; b_tien_qd number; b_thue_hh number; b_thue_ht number; b_thue number; b_btD number;
    b_tk_Dhhong varchar2(20); b_tk_Dhtro varchar2(20); b_tk_hhong varchar2(20); b_tk_htro varchar2(20); b_tk_cndl varchar2(20);

    b_so_id_hd number;

    a_so_id pht_type.a_num; a_tk_thue pht_type.a_var;
    
/*
declare
    a_so_id pht_type.a_num;a_so_hd pht_type.a_var;b_loi varchar2(200);
begin
delete ket_qua;
a_so_id(1):=20210930083895;
a_so_hd(1):='79/H�2021/EVNGENCO1-PJICO-BIC-MIC';
PBH_KT_HTOAN_DL_HH('000',20210923,'','',a_so_id,a_so_hd,b_loi);
end;
select n20,c1,c2,n1,c4,n10 from ket_qua;
*/    
begin
-- Dan - Duyet hoa hong
b_tk_Dhhong:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DC_HH_DL');
b_tk_Dhtro:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DC_HT_DL');
b_tk_hhong:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HH_DL');
b_tk_htro:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HT_DL');
b_tk_cndl:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_HH_DL');

b_bt:=0; b_noite:=FTT_TRA_NOITE(b_ma_dvi);
a_so_id(1):=a_so_id_n(1);
for b_lp in 2..a_so_id_n.count loop
    b_i1:=0;
    for b_lp1 in 1..a_so_id.count loop
        if a_so_id(b_lp1)=a_so_id_n(b_lp) then b_i1:=1; exit; end if;
    end loop;
    if b_i1=0 then
        b_i1:=a_so_id.count+1;
        a_so_id(b_i1):=a_so_id_n(b_lp);
    end if;
end loop;
for b_lp in 1..a_so_id.count loop
    b_loi:='loi:Loi xu ly dong '||trim(to_char(b_lp))||' so_id: '||a_so_id(b_lp)||':loi';
    --b_so_id_hd:=FBH_HD_GOC_SO_ID(b_ma_dvi,a_so_hd(b_lp));
    if a_so_hd.count>0 and a_so_hd(b_lp) in ('PFM/01609128/KT','PFM/01609128/TS') then
        select nvl(sum(hhong_qd+thue_hh_qd),0),nvl(sum(htro_qd),0),nvl(sum(thue_hh_qd),0),nvl(sum(thue_ht_qd),0)
            into b_hhong,b_htro,b_thue_hh,b_thue_ht from bh_hd_goc_hh_pt where ma_dvi=b_ma_dvi and so_id_hh=a_so_id(b_lp);
    else
        select nvl(sum(hhong_qd),0),nvl(sum(htro_qd),0),nvl(sum(thue_hh_qd),0),nvl(sum(thue_ht_qd),0)
            into b_hhong,b_htro,b_thue_hh,b_thue_ht from bh_hd_goc_hh_pt where ma_dvi=b_ma_dvi and so_id_hh=a_so_id(b_lp);
    end if;
    select ma_dl into b_ma_kh from bh_hd_goc_hh where ma_dvi=b_ma_dvi and so_id_hh=a_so_id(b_lp);
    
    --select min(pt_thue) into b_pt_thue from bh_dl_ma_kh where ma_dvi=b_ma_dvi and ma=b_ma_kh;
    select min(c_thue) into b_pt_thue from bh_dl_ma_kh where ma_dvi=b_ma_dvi and ma=b_ma_kh;
    
    select substr('Duyet hoa hong: '||trim(ten),1,200) into b_gchu from bh_dl_ma_kh where ma_dvi=b_ma_dvi and ma=b_ma_kh;
    if a_so_hd.count>0 then
        for b_lp1 in 1..a_so_id_n.count loop
            if a_so_id_n(b_lp1)=a_so_id(b_lp) then
                b_gchu:=substr(b_gchu||', '||a_so_hd(b_lp1),1,200); b_gchu:=ltrim(b_gchu,',');
            end if;
        end loop;
    end if;
    b_chenh:=b_hhong+b_htro;
    if trim(b_tk_Dhhong) is not null then
        if b_tk_hhong<>b_tk_Dhhong then
            b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,c4,n10) values(1,'N',b_tk_hhong,b_chenh,b_gchu,b_bt);
            b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,n10) values(2,'C',b_tk_Dhhong,b_chenh,b_bt);
            b_gchu:='';
        end if;
        b_ma_tk:=b_tk_cndl;
    else
        b_ma_tk:=b_tk_hhong;
    end if;
    b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,c4,n10) values(3,'N',b_ma_tk,b_chenh,b_gchu,b_bt);
    b_bt:=b_bt+1; b_btD:=b_bt;
    for r_lp in (select pt,ma_nt,tien,tien_qd from bh_hd_goc_hh_tt where ma_dvi=b_ma_dvi and so_id_hh=a_so_id(b_lp)) loop
        b_tien:=r_lp.tien; b_tien_qd:=r_lp.tien_qd;
        if r_lp.pt='C' then b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_HH_DL');
        elsif r_lp.pt='H' then b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_PH_DL');
        elsif b_tk_nha is null then
            if r_lp.ma_nt=b_noite then
                b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TMV',b_ngay_ht,'N');
            else
                b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TMN',b_ngay_ht,'N');
                b_tien_qd:=FTT_SC_QD(b_ma_dvi,r_lp.ma_nt,b_nha,b_tk_nha,b_ngay_ht,b_tien);
            end if;
        else
            if r_lp.ma_nt=b_noite then
                b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TGV',b_ngay_ht,'N');
            else
                b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TGN',b_ngay_ht,'N');
                b_tien_qd:=FTT_SC_QD(b_ma_dvi,r_lp.ma_nt,b_nha,b_tk_nha,b_ngay_ht,b_tien);
            end if;
        end if;
        b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,n10) values(4,'C',b_ma_tk,b_tien_qd,b_bt);
        b_chenh:=b_chenh-b_tien_qd;
    end loop;
    b_thue:=b_thue_hh+b_thue_ht;
    if b_thue<>0 then
        --select min(pt_thue) into b_pt_thue from bh_dl_ma_kh where ma_dvi=b_ma_dvi and ma=b_ma_kh;
        select min(c_thue) into b_pt_thue from bh_dl_ma_kh where ma_dvi=b_ma_dvi and ma=b_ma_kh;
        if b_pt_thue='C' then
            b_ma_tk:=FBH_KT_TK_THUE(b_ma_dvi,b_ngay_ht,'G','CH_HH_DL');
            PKH_CH_ARR(b_ma_tk,a_tk_thue);
            b_chenh:=b_chenh-b_thue;
            if a_tk_thue.count=0 then b_ma_tk:='';
            else b_ma_tk:=a_tk_thue(1);
            end if;
            b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,n10) values(5,'C',b_ma_tk,b_thue,b_bt);
        end if;
    end if;
    if b_chenh<0 then
        b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'P',' ','C');
        insert into ket_qua(n20,c1,c2,n1,n10) values(6,'N',b_ma_tk,-b_chenh,b_btD);
    elsif b_chenh>0 then
        b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'D',' ','C');
        b_bt:=b_bt+1; insert into ket_qua(n20,c1,c2,n1,n10) values(7,'C',b_ma_tk,b_chenh,b_bt);
    end if;
end loop;
b_loi:='';
exception when others then null;
end;
/
CREATE OR REPLACE procedure PBH_KT_HTOAN_DO_TH
    (b_ma_dvi varchar2,b_ngay_ht number,b_nha varchar2,b_tk_nha varchar2,a_so_id pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_nha_bh varchar2(20); b_gchu nvarchar2(200); b_ma_tk varchar2(20); b_tk_thue varchar2(20);b_noite varchar2(5);
    b_bt number; b_tien number; b_tien_qd number; b_thuc number; b_chenh number; b_ma_nt varchar2(5); b_l_ct varchar2(1);
begin
-- Dan - Thu cong no nha dong BH
b_bt:=0; b_noite:=FTT_TRA_NOITE(b_ma_dvi);
for b_lp in 1..a_so_id.count loop
    b_loi:='loi:Loi xu ly dong '||trim(to_char(b_lp))||':loi';
    select l_ct,ma_nt,tien,tien_qd,nha_bh into b_l_ct,b_ma_nt,b_tien,b_tien_qd,b_nha_bh
        from bh_do_bh_cn where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
    if b_l_ct<>'T' then b_loi:='loi:Chi hach toan thu hoac chi:loi'; return; end if;
    --select substr('Thu tien nha bao hiem khac: '||trim(min(ten)),1,200) into b_gchu from tbh_ma_nbh where ma_dvi=b_ma_dvi and ma=b_nha_bh;
    b_gchu:='Thu tien nha bao hiem khac: '||b_nha_bh;
    if b_ma_nt=b_noite then
        b_thuc:=b_tien;
    else
        b_i1:=FTT_TRA_TGTT(b_ma_dvi,b_ngay_ht,b_ma_nt);
        b_thuc:=round(b_i1*b_tien,0);
    end if;
    b_chenh:=b_thuc-b_tien_qd;
    if b_tk_nha is null then
        if b_ma_nt=b_noite then
            b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TMV',b_ngay_ht,'N');
        else
            b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TMN',b_ngay_ht,'N');
        end if;
    else
        if b_ma_nt=b_noite then
            b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TGV',b_ngay_ht,'N');
        else
            b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TGN',b_ngay_ht,'N');
        end if;
    end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,b_thuc,b_gchu,b_bt);
    if b_chenh<0 then
        b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'P',' ','C');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,-b_chenh,b_bt);
    end if;
    b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CN_KH');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_tien_qd,b_bt);
    if b_chenh>0 then
        b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'D',' ','C');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_chenh,b_bt);
    end if; 
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_KT_HTOAN_DO_CH
    (b_ma_dvi varchar2,b_ngay_ht number,b_nha varchar2,b_tk_nha varchar2,a_so_id pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_nha_bh varchar2(10); b_gchu nvarchar2(200); b_ma_tk varchar2(20); b_tk_thue varchar2(20);
    b_bt number; b_tien number; b_tien_qd number; b_thuc number; b_chenh number; b_ma_nt varchar2(5); b_l_ct varchar2(1);
begin
-- Dan - Chi tra cong no nha BH [N:NDO; Co:111]
b_bt:=0;
for b_lp in 1..a_so_id.count loop
    b_loi:='loi:Loi xu ly dong '||trim(to_char(b_lp))||':loi';
    select l_ct,ma_nt,tien,tien_qd,nha_bh into b_l_ct,b_ma_nt,b_tien,b_tien_qd,b_nha_bh
        from bh_hd_do_cn where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
    if b_l_ct<>'C' then b_loi:='loi:Chi hach toan thu hoac chi:loi'; return; end if;
    select substr('Chi tien khach hang: '||trim(min(ten)),1,200) into b_gchu from bh_ma_nbh where ma=b_nha_bh;
    if b_ma_nt='VND' then
        b_thuc:=b_tien;
    else
        b_thuc:=FTT_SC_QD(b_ma_dvi,b_ma_nt,b_nha,b_tk_nha,b_ngay_ht,b_tien);
    end if;
    b_chenh:=b_tien_qd-b_thuc;
    b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CN_KH');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,b_tien_qd,b_gchu,b_bt);
    if b_chenh<0 then
        b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'P',' ','C');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,-b_chenh,b_bt);
    end if;
    if b_tk_nha is null then
        if b_ma_nt='VND' then
            b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TMV',b_ngay_ht,'N');
        else    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TMN',b_ngay_ht,'N');
        end if;
    else
        if b_ma_nt='VND' then
            b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TGV',b_ngay_ht,'N');
        else    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TGN',b_ngay_ht,'N');
        end if;
    end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_thuc,b_bt);
    if b_chenh>0 then
        b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'D',' ','C');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_chenh,b_bt);
    end if; 
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
CREATE OR REPLACE procedure PBH_KT_HTOAN_TA_TH
    (b_ma_dvi varchar2,b_ngay_ht number,b_nha varchar2,b_tk_nha varchar2,a_so_id pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_nha_bh varchar2(20); b_gchu nvarchar2(200); b_ma_tk varchar2(20); b_tk_thue varchar2(20);b_noite varchar2(5);
    b_bt number; b_tien number; b_tien_qd number; b_thuc number; b_chenh number; b_ma_nt varchar2(5); b_l_ct varchar2(1);
begin
-- Dan - Thu nha tai
b_bt:=0; b_noite:=FTT_TRA_NOITE(b_ma_dvi);
for b_lp in 1..a_so_id.count loop
    b_loi:='loi:Loi xu ly dong '||trim(to_char(b_lp))||':loi';
    select l_ct,ma_nt,tien,tien_qd,nha_bh into b_l_ct,b_ma_nt,b_tien,b_tien_qd,b_nha_bh
        from tbh_nha_bh_cn where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
    if b_l_ct<>'T' then b_loi:='loi:Chi hach toan thu hoac chi:loi'; return; end if;
    
    --select substr('Thu tien nha bao hiem khac: '||trim(min(ten)),1,200) into b_gchu from tbh_ma_nbh where ma_dvi=b_ma_dvi and ma=b_nha_bh;
    b_gchu:='Thu tien nha bao hiem khac: '||b_nha_bh;
    if b_ma_nt=b_noite then
        b_thuc:=b_tien;
    else
        b_i1:=FTT_TRA_TGTT(b_ma_dvi,b_ngay_ht,b_ma_nt);
        b_thuc:=round(b_i1*b_tien,0);
    end if;
    b_chenh:=b_thuc-b_tien_qd;
    if b_tk_nha is null then
        if b_ma_nt=b_noite then
            b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TMV',b_ngay_ht,'N');
        else
            b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TMN',b_ngay_ht,'N');
        end if;
    else
        if b_ma_nt=b_noite then
            b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TGV',b_ngay_ht,'N');
        else
            b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TGN',b_ngay_ht,'N');
        end if;
    end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,b_thuc,b_gchu,b_bt);
    if b_chenh<0 then
        b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'P',' ','C');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,-b_chenh,b_bt);
    end if;
    b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','CN_KH');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_tien_qd,b_bt);
    if b_chenh>0 then
        b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'D',' ','C');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_chenh,b_bt);
    end if; 
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_KT_HTOAN_TA_CH
    (b_ma_dvi varchar2,b_ngay_ht number,b_nha varchar2,b_tk_nha varchar2,a_so_id pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_nha_bh varchar2(10); b_gchu nvarchar2(200); b_ma_tk varchar2(20); b_tk_thue varchar2(20);
    b_bt number; b_tien number; b_tien_qd number; b_thuc number; b_chenh number; b_ma_nt varchar2(5); b_l_ct varchar2(1);
begin
-- Dan - Chi nha BH [N:NTA; Co:111]
b_bt:=0;
for b_lp in 1..a_so_id.count loop
    b_loi:='loi:Loi xu ly dong '||trim(to_char(b_lp))||':loi';
    select l_ct,ma_nt,tien,tien_qd,nha_bh into b_l_ct,b_ma_nt,b_tien,b_tien_qd,b_nha_bh
        from tbh_nha_bh_cn where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
    if b_l_ct<>'C' then b_loi:='loi:Chi hach toan thu hoac chi:loi'; return; end if;
    select substr('Chi tien khach hang: '||trim(min(ten)),1,200) into b_gchu from bh_ma_nbh where ma=b_nha_bh;
    if b_ma_nt='VND' then
        b_thuc:=b_tien;
    else
        b_thuc:=FTT_SC_QD(b_ma_dvi,b_ma_nt,b_nha,b_tk_nha,b_ngay_ht,b_tien);
    end if;
    b_chenh:=b_tien_qd-b_thuc;
    b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','CN_KH');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,b_tien_qd,b_gchu,b_bt);
    if b_chenh<0 then
        b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'P',' ','C');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,-b_chenh,b_bt);
    end if;
    if b_tk_nha is null then
        if b_ma_nt='VND' then
            b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TMV',b_ngay_ht,'N');
        else    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TMN',b_ngay_ht,'N');
        end if;
    else
        if b_ma_nt='VND' then
            b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TGV',b_ngay_ht,'N');
        else    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TGN',b_ngay_ht,'N');
        end if;
    end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_thuc,b_bt);
    if b_chenh>0 then
        b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'D',' ','C');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_chenh,b_bt);
    end if; 
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
create or replace procedure PBH_KT_HTOAN_TA_XL
    (b_ma_dvi varchar2,b_ngay_ht number,a_so_id pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_bt number; b_tien number; b_nn varchar2(1);
    b_dtd number; b_btd number; b_gdd number; b_hud number; b_hhd number; b_thd number;
    b_dtv number; b_btv number; b_gdv number; b_huv number; b_hhv number; b_thv number; b_tup number;
    b_kieu varchar2(1); b_nha_bh varchar2(10); b_gchu nvarchar2(200); b_ma_tk varchar2(20);
    b_ma_tk_di varchar2(20); b_ma_tk_ve varchar2(20); b_ma_tk_vd varchar2(20); b_ma_tk_du varchar2(20);
begin
-- Dan - Doi chieu tai
b_bt:=0;
b_ma_tk_di:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','CN_LE_U');
b_ma_tk_ve:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','CN_FL_U');
b_ma_tk_vd:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','CN_LF_U');
for b_lp in 1..a_so_id.count loop
    b_loi:='loi:Loi xu ly dong '||trim(to_char(b_lp))||':loi';
    b_dtd:=0; b_btd:=0; b_hud:=0; b_hhd:=0; b_thd:=0;
    b_dtv:=0; b_btv:=0; b_huv:=0; b_hhv:=0; b_thv:=0;
    select kieu,nha_bh into b_kieu,b_nha_bh from tbh_xl_dc where ma_dvi=b_ma_dvi and so_id_xl=a_so_id(b_lp);
    select nvl(min(ten),'Ma da xoa'),nvl(min(loai),'T') into b_gchu,b_nn from bh_ma_nbh where ma=b_nha_bh;
    b_gchu:=substr('Doi chieu tai bao hiem: '||trim(b_gchu),1,200);
    if b_kieu in('C','T') then b_ma_tk_du:=b_ma_tk_di;
    elsif b_kieu in('V','N') then b_ma_tk_du:=b_ma_tk_ve;
    else b_ma_tk_du:=b_ma_tk_vd;
    end if;
    for r_lp in (select ma_dvi_ps,so_id_ps,goc,sum(tien_qd) tien,sum(hhong_qd) hhong,sum(thue_qd) thue from
        tbh_xl_dc_pbo where ma_dvi=b_ma_dvi and so_id_xl=a_so_id(b_lp) group by ma_dvi_ps,so_id_ps,loai) loop
        if r_lp.tien<>0 or r_lp.hhong<>0 or r_lp.thue<>0 then
            if b_kieu in('C','T') then
                b_hhd:=b_hhd+r_lp.hhong; b_thd:=b_thd+r_lp.thue;
                if r_lp.goc in('BT_HS','BT_GD') then b_btd:=b_btd+r_lp.tien;
                elsif r_lp.goc in('BT_TB','BT_TH') then b_btd:=b_btd-r_lp.tien;
                elsif r_lp.goc='HD_HU' then b_hud:=b_hud-r_lp.tien;
                elsif r_lp.goc='TA_UP' then b_tup:=b_tup+r_lp.tien;
                elsif r_lp.goc='TA_HU' then b_tup:=b_tup-r_lp.tien;
                else b_dtd:=b_dtd+r_lp.tien;
                end if;
            else
                b_hhv:=b_hhv+r_lp.hhong; b_thv:=b_thv+r_lp.thue;
                if r_lp.goc in('BT_HS','BT_GD') then b_btv:=b_btv+r_lp.tien;
                elsif r_lp.goc in('BT_TB','BT_TH') then b_btv:=b_btv-r_lp.tien;
                elsif r_lp.goc='HD_HU' then b_huv:=b_huv-r_lp.tien;
                else b_dtv:=b_dtv+r_lp.tien;
                end if;
            end if;
        end if;
    end loop;
    if b_dtd>0 then
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','CH_LE_PH'||b_nn);
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,b_dtd,b_gchu,b_bt); b_gchu:=' ';
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk_du,b_dtd,b_bt);
    end if;
    if b_dtv<0 then
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','CH_FL_PH'||b_nn);
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,-b_dtv,b_gchu,b_bt); b_gchu:=' ';
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk_du,-b_dtv,b_bt);
    end if;
    if b_huv<>0 then
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','CH_FL_PH'||b_nn);
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,b_huv,b_gchu,b_bt); b_gchu:=' ';
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk_du,b_huv,b_bt);
    end if;
    if b_btd<0 then
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','DT_LE_BT'||b_nn);
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,-b_btd,b_gchu,b_bt); b_gchu:=' ';
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk_du,-b_btd,b_bt);
    end if;
    if b_btv>0 then
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','CH_FL_BT'||b_nn);
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,b_btv,b_gchu,b_bt); b_gchu:=' ';
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk_du,b_btv,b_bt);
    end if;
    if b_gdd<0 then
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','DT_LE_GD'||b_nn);
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,-b_gdd,b_gchu,b_bt); b_gchu:=' ';
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk_du,-b_gdd,b_bt);
    end if;
    if b_gdv>0 then
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','CH_FL_GD'||b_nn);
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,b_gdv,b_gchu,b_bt); b_gchu:=' ';
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk_du,b_gdv,b_bt);
    end if;
    if b_hhd<0 then
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','CH_LE_HH'||b_nn);
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,-b_hhd,b_gchu,b_bt); b_gchu:=' ';
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk_du,-b_hhd,b_bt);
    end if;
    if b_thd<0 then
        b_ma_tk:=FBH_KT_TK_THUE(b_ma_dvi,b_ngay_ht,'T','DT_LE_PH'||b_nn);
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,-b_thd,b_gchu,b_bt); b_gchu:=' ';
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk_du,-b_thd,b_bt);
    end if;
    if b_hhv>0 then
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','CH_FL_HH'||b_nn);
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,b_hhv,b_gchu,b_bt); b_gchu:=' ';
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk_du,b_hhv,b_bt);
    end if;
    if b_tup<0 then
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','TA_UP');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,-b_tup,b_gchu,b_bt); b_gchu:=' ';
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk_du,-b_tup,b_bt);
    end if;
    if b_dtd<0 then
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','DT_LE_PH'||b_nn);
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk_du,-b_dtd,b_gchu,b_bt); b_gchu:=' ';
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,-b_dtd,b_bt);
    end if;
    if b_dtv>0 then
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','DT_FL_PH'||b_nn);
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk_du,b_dtv,b_gchu,b_bt); b_gchu:=' ';
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_dtv,b_bt);
    end if;
    if b_hud<>0 then
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','DT_LE_PH'||b_nn);
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk_du,b_hud,b_gchu,b_bt); b_gchu:=' ';
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_hud,b_bt);
    end if;
    if b_btd>0 then
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','DT_LE_BT'||b_nn);
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk_du,b_btd,b_gchu,b_bt); b_gchu:=' ';
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_btd,b_bt);
    end if;
    if b_btv<0 then
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','CH_FL_BT'||b_nn);
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk_du,-b_btv,b_gchu,b_bt); b_gchu:=' ';
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,-b_btv,b_bt);
    end if;
    if b_gdd>0 then
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','DT_LE_GD'||b_nn);
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk_du,b_gdd,b_gchu,b_bt); b_gchu:=' ';
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_gdd,b_bt);
    end if;
    if b_gdv<0 then
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','CH_FL_GD'||b_nn);
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk_du,-b_gdv,b_gchu,b_bt); b_gchu:=' ';
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,-b_gdv,b_bt);
    end if;
    if b_hhd>0 then
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','DT_LE_HH'||b_nn);
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk_du,b_hhd,b_gchu,b_bt); b_gchu:=' ';
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_hhd,b_bt);
    end if;
    if b_thd>0 then
        b_ma_tk:=FBH_KT_TK_THUE(b_ma_dvi,b_ngay_ht,'T','CH_LE_PH'||b_nn);
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk_du,b_thd,b_gchu,b_bt); b_gchu:=' ';
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_thd,b_bt);
    end if;
    if b_hhv<0 then
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','DT_FL_HH'||b_nn);
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk_du,-b_hhv,b_gchu,b_bt); b_gchu:=' ';
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,-b_hhv,b_bt);
    end if;
    if b_tup>0 then
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','TA_UP');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk_du,b_tup,b_gchu,b_bt); b_gchu:=' ';
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_tup,b_bt);
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
CREATE OR REPLACE function FTBH_HD_DI_NBH_HUNG(b_ma_dvi varchar2,b_so_hd varchar2) return varchar2
AS
    b_kq varchar2(20); b_so_id number:=FTBH_DI_HD_SO_ID(b_ma_dvi,b_so_hd);
begin
-- Dan - Hop dong tai ve
select min(nha_bh) into b_kq from tbh_hd_di_nha_bh where so_id=b_so_id and kieu in('C','M');
return b_kq;
end;
/
CREATE OR REPLACE procedure PBH_KT_HTOAN_HD_BS_CT
    (b_ma_dvi varchar2,b_ngay_ht number,a_so_id pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_noite varchar2(5); b_so_id number; b_pt varchar2(1); b_ma_nt varchar2(5); b_tien_qd number;
    b_ma_kh varchar2(20); b_gchu nvarchar2(200); b_ma_tk varchar2(20); b_tk_do varchar2(20); b_do_qd number;
    b_phi_g number; b_phi_t number; b_phi_s number; b_thue number; b_chenh number; b_no number; b_co number; b_so_id_hd number;
    b_kieu_do varchar2(1); b_kieu_phv varchar2(1); b_chia_nb number; b_ngay_tt number;
    b_bt number; b_bt_d number; b_ngay_hl number; b_nam_hl number; b_nam_tt number; b_nam_ng number; b_phong varchar2(10);
    b_hhong_qd number; b_htro_qd number; b_tk_hhong varchar2(20); b_tk_htro varchar2(20); b_tk_cndl varchar2(20); b_tke_ph varchar2(1);
begin
-- Dan - Thanh toan phi
b_bt:=0; b_noite:=FTT_TRA_NOITE(b_ma_dvi);
b_tk_hhong:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DC_HH_DL');
b_tk_htro:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DC_HT_DL');
b_tk_cndl:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_HH_DL');
b_tke_ph:=FKH_NV_TSO(b_ma_dvi,'KT','BH','phong');
b_tk_do:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CN_FL_DO');
for b_lp in 1..a_so_id.count loop
    b_loi:='loi:Loi xu ly dong '||trim(to_char(b_lp))||':loi';
    b_bt_d:=b_bt+1;
    b_ngay_tt:=FBH_HD_NGAY(b_ma_dvi,a_so_id(b_lp)); b_nam_tt:=PKH_SO_NAM(b_ngay_tt);
    b_phi_t:=0; b_phi_s:=0; b_phi_g:=0; b_thue:=0;
    delete bh_hd_goc_htct_temp1; delete bh_hd_goc_htct_temp;
    insert into bh_hd_goc_htct_temp1(phong,lh_nv,ttoan_qd,phi_qd,hhong_qd,htro_qd,dvu_qd)
        select FBH_HD_MA_BP(b_ma_dvi,so_id),FBH_TKE_KT_NV(b_ma_dvi,lh_nv),ttoan_qd,phi_qd,hhong_qd,htro_qd,0
            from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp) and pt not in('N','H');
    insert into bh_hd_goc_htct_temp(phong,lh_nv,ttoan_qd,phi_qd,hhong_qd,htro_qd,dvu_qd) 
        select phong,lh_nv,sum(ttoan_qd),sum(phi_qd),sum(hhong_qd),sum(htro_qd),0 dvu_qd from bh_hd_goc_htct_temp1 group by phong,lh_nv;
    for r_lp1 in (select so_id,sum(phi_qd) phi_dt_qd,sum(thue_qd) thue_qd from bh_hd_goc_ttpt
        where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp) and pt not in('N','H') group by so_id) loop
        b_thue:=b_thue+r_lp1.thue_qd;
        if r_lp1.phi_dt_qd<0 then
            b_phi_g:=b_phi_g+r_lp1.phi_dt_qd;
        else
            b_so_id:=r_lp1.so_id;
            b_ngay_hl:=FBH_HD_NGAY_HL(b_ma_dvi,b_so_id,b_ngay_tt); b_nam_hl:=PKH_SO_NAM(b_ngay_hl);
            for r_lp in (select ngay,sum(phi_qd) phi_dt_qd,sum(thue_qd) thue_qd from bh_hd_goc_ttpt
                where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp) and so_id=b_so_id and pt not in('N','H') group by ngay) loop
                b_nam_ng:=PKH_SO_NAM(r_lp.ngay);
                if (b_nam_tt<b_nam_ng and add_months(PKH_SO_CDT(b_ngay_hl),12)<PKH_SO_CDT(r_lp.ngay)) or (b_nam_hl<3000 and b_nam_hl>b_nam_tt) then
                    b_phi_s:=b_phi_s+r_lp.phi_dt_qd;
                else
                    b_phi_t:=b_phi_t+r_lp.phi_dt_qd;
                end if;
            end loop;
        end if;
    end loop;
    select nvl(sum(phi_qd),0) into b_chia_nb from bh_hd_goc_ttpb where dvi_xl=b_ma_dvi and so_id_tt=a_so_id(b_lp) and ma_dvi<>b_ma_dvi;
    b_chenh:=b_phi_t+b_phi_s+b_phi_g+b_thue;
    select min(ma_kh) into b_ma_kh from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
    if trim(b_ma_kh) is not null and b_ma_kh<>'VANGLAI' then
        select min(ten) into b_gchu from bh_hd_ma_kh where ma_dvi=b_ma_dvi and ma=b_ma_kh;
    end if;
    if b_phi_g<>0 then
        b_gchu:=substr('Giam phi khach hang: '||trim(b_gchu),1,200);
        b_bt:=b_bt+1;
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_PH_TL');
        insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,-b_phi_g,b_gchu,b_bt); b_gchu:='';
    end if;
    if b_chenh>0 then
        b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'P',' ','C');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,b_chenh,b_bt);
    end if;
    if b_phi_t>0 then
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_PH_BH');
        for r_lp_tke in (select * from bh_hd_goc_htct_temp order by phong,lh_nv) loop
            b_bt:=b_bt+1;
            if b_tke_ph='C' then b_gchu:=r_lp_tke.lh_nv||'.'||r_lp_tke.phong; else b_gchu:=r_lp_tke.lh_nv; end if;
            insert into ket_qua(c1,c2,c3,n1,n10) values('C',b_ma_tk,b_gchu,r_lp_tke.phi_qd,b_bt);
        end loop;
        b_gchu:='';
    end if;
    if b_phi_s>0 then
        b_bt:=b_bt+1;
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_PH_TR');
        insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_phi_s,b_bt);
    end if;
    if b_thue<>0 then
        b_bt:=b_bt+1;
        if b_thue>0 then
            b_ma_tk:=FBH_KT_TK_THUE(b_ma_dvi,b_ngay_ht,'G','DT_PH_BH');
            insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_thue,b_bt);
        else
            b_ma_tk:=FBH_KT_TK_THUE(b_ma_dvi,b_ngay_ht,'G','CH_PH_TL');
            insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,-b_thue,b_bt);
        end if;
    end if;
    if b_chenh<0 then
        b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'D',' ','C');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,-b_chenh,b_bt);
    end if;
    if b_chia_nb<>0 then
        if b_chia_nb>0 then
            if b_phi_s<>0 then
                b_phi_s:=round(b_chia_nb*b_phi_s/(b_phi_t+b_phi_s),0);
                b_phi_t:=b_chia_nb-b_phi_s;
            else
                b_phi_s:=0; b_phi_t:=b_chia_nb;
            end if;
            b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_PH_BH');
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,b_phi_t,'Phi phan chia dong BH noi bo',b_bt);
            if b_phi_s<>0 then
                b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_PH_TR');
                b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,b_phi_s,b_bt);
            end if;
            b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CN_LE_DV');
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_chia_nb,b_bt);
        else
            b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CN_LE_DV');
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,-b_chia_nb,'Hoan phi phan chia dong BH noi bo',b_bt);
            b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_PH_TL');
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,-b_chia_nb,b_bt);
        end if;
    end if;
    select nvl(sum(hhong_qd),0),nvl(sum(htro_qd),0) into b_hhong_qd,b_htro_qd from bh_hd_goc_ttpb where
        ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp) and pt not in('N','H');
    if b_hhong_qd<>0 and trim(b_tk_hhong) is not null then
        if b_hhong_qd>0 then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_tk_hhong,b_hhong_qd,'Du chi hoa hong',b_bt);
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_cndl,b_hhong_qd,b_bt);
        else
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_tk_cndl,-b_hhong_qd,'Du thu doi hoa hong',b_bt);
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_hhong,-b_hhong_qd,b_bt);
        end if;
    end if;
    if b_htro_qd<>0 and trim(b_tk_htro) is not null then
        if b_htro_qd>0 then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_tk_htro,b_htro_qd,'Du chi ho tro',b_bt);
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_cndl,b_htro_qd,b_bt);
        else
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_tk_cndl,-b_htro_qd,'Du thu doi ho tro',b_bt);
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_htro,-b_htro_qd,b_bt);
        end if;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_KT_HTOAN_HD_BS_CH
    (b_ma_dvi varchar2,b_ngay_ht number,a_so_id pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_noite varchar2(5); b_so_id number; b_pt varchar2(1); b_ma_nt varchar2(5); b_tien_qd number;
    b_ma_kh varchar2(20); b_gchu nvarchar2(200); b_ma_tk varchar2(20);
    b_phi_g number; b_phi_t number; b_phi_s number; b_thue number; b_chenh number; b_no number; b_co number;
    b_kieu_do varchar2(1); b_kieu_phv varchar2(1); b_chia_nb number;
    b_ngay_tt number; b_bt number; b_bt_d number; b_ngay_hl number; b_nam_hl number; b_nam_tt number; b_nam_ng number;
    b_hhong_qd number; b_htro_qd number; b_tk_hhong varchar2(20); b_tk_htro varchar2(20); b_tk_cndl varchar2(20);
begin
-- Dan - sua doi
b_bt:=0; b_noite:=FTT_TRA_NOITE(b_ma_dvi);
b_tk_hhong:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DC_HH_DL');
b_tk_htro:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DC_HT_DL');
b_tk_cndl:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_HH_DL');
for b_lp in 1..a_so_id.count loop
    b_loi:='loi:Loi xu ly dong '||trim(to_char(b_lp))||':loi';
    b_bt_d:=b_bt+1;
    b_ngay_tt:=FBH_HD_NGAY(b_ma_dvi,a_so_id(b_lp)); b_nam_tt:=PKH_SO_NAM(b_ngay_tt);
    b_phi_t:=0; b_phi_s:=0; b_phi_g:=0; b_thue:=0;
    for r_lp1 in (select so_id,sum(phi_qd) phi_dt_qd,sum(thue_qd) thue_qd from bh_hd_goc_ttpt where
        ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp) and pt not in('N','H') group by so_id) loop
        b_so_id:=r_lp1.so_id;
        b_thue:=b_thue+r_lp1.thue_qd;
        if r_lp1.phi_dt_qd<0 then
            b_phi_g:=b_phi_g+r_lp1.phi_dt_qd;
        else
            b_ngay_hl:=FBH_HD_NGAY_HL(b_ma_dvi,b_so_id,b_ngay_tt); b_nam_hl:=PKH_SO_NAM(b_ngay_hl);
            for r_lp in (select ngay,sum(phi_qd) phi_dt_qd,sum(thue_qd) thue_qd from bh_hd_goc_ttpt
                where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp) and so_id=b_so_id and pt not in('N','H') group by ngay) loop
                b_nam_ng:=PKH_SO_NAM(r_lp.ngay);
                if (b_nam_tt<b_nam_ng and add_months(PKH_SO_CDT(b_ngay_hl),12)<PKH_SO_CDT(r_lp.ngay)) or (b_nam_hl<3000 and b_nam_hl>b_nam_tt) then
                    b_phi_s:=b_phi_s+r_lp.phi_dt_qd;
                else
                    b_phi_t:=b_phi_t+r_lp.phi_dt_qd;
                end if;
            end loop;
        end if;
    end loop;
    b_chenh:=b_phi_t+b_phi_s+b_phi_g+b_thue;
    select min(ma_kh) into b_ma_kh from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
    if trim(b_ma_kh) is not null and b_ma_kh<>'VANGLAI' then
        select min(ten) into b_gchu from bh_hd_ma_kh where ma_dvi=b_ma_dvi and ma=b_ma_kh;
    end if;
    if b_phi_g<>0 then
        b_gchu:=substr('Giam phi khach hang: '||trim(b_gchu),1,200);
        b_bt:=b_bt+1;
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_PH_TL');
        insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,-b_phi_g,b_gchu,b_bt); b_gchu:='';
    end if;
    if b_chenh>0 then
        b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'P',' ','C');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,b_chenh,b_bt);
    end if;
    if b_phi_t>0 then
        b_bt:=b_bt+1;
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_PH_BH');
        insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_phi_t,b_bt);
    end if;
    if b_phi_s>0 then
        b_bt:=b_bt+1;
        b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_PH_TR');
        insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_phi_s,b_bt);
    end if;
    if b_thue<>0 then
        b_bt:=b_bt+1;
        if b_thue>0 then
            b_ma_tk:=FBH_KT_TK_THUE(b_ma_dvi,b_ngay_ht,'G','DT_PH_BH');
            insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_thue,b_bt);
        else
            b_ma_tk:=FBH_KT_TK_THUE(b_ma_dvi,b_ngay_ht,'G','CH_PH_TL');
            insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,-b_thue,b_bt);
        end if;
    end if;
    if b_chenh<0 then
        b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'D',' ','C');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,-b_chenh,b_bt);
    end if;
    select nvl(sum(phi_qd),0) into b_chia_nb from bh_hd_goc_ttpb where dvi_xl=b_ma_dvi and so_id_tt=a_so_id(b_lp) and ma_dvi<>b_ma_dvi;
    if b_chia_nb<>0 then
        if b_chia_nb>0 then
            if b_phi_s<>0 then
                b_phi_s:=round(b_chia_nb*b_phi_s/(b_phi_t+b_phi_s),0);
                b_phi_t:=b_chia_nb-b_phi_s;
            else
                b_phi_s:=0; b_phi_t:=b_chia_nb;
            end if;
            b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_PH_BH');
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,b_phi_t,'Phi phan chia dong BH noi bo',b_bt);
            if b_phi_s<>0 then
                b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_PH_TR');
                b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,b_phi_s,b_bt);
            end if;
            b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CN_LE_DV');
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_chia_nb,b_bt);
        else
            b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CN_LE_DV');
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_ma_tk,-b_chia_nb,'Hoan phi phan chia dong BH noi bo',b_bt);
            b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_PH_TL');
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,-b_chia_nb,b_bt);
        end if;
    end if;
    select nvl(sum(hhong_qd),0),nvl(sum(htro_qd),0) into b_hhong_qd,b_htro_qd from bh_hd_goc_ttpb where
        ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp) and pt not in('N','H');
    if b_hhong_qd<>0 and trim(b_tk_hhong) is not null then
        if b_hhong_qd>0 then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_tk_hhong,b_hhong_qd,'Du chi hoa hong',b_bt);
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_cndl,b_hhong_qd,b_bt);
        else
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_tk_cndl,-b_hhong_qd,'Du thu doi hoa hong',b_bt);
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_hhong,-b_hhong_qd,b_bt);
        end if;
    end if;
    if b_htro_qd<>0 and trim(b_tk_htro) is not null then
        if b_htro_qd>0 then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_tk_htro,b_htro_qd,'Du chi ho tro',b_bt);
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_cndl,b_htro_qd,b_bt);
        else
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_tk_cndl,-b_htro_qd,'Du thu doi ho tro',b_bt);
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_htro,-b_htro_qd,b_bt);
        end if;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function FTBH_DI_HD_SO_ID(b_ma_dvi varchar2,b_so_hd varchar2) return number
AS
    b_kq number;
begin
-- Dan - Hop dong tai di
select nvl(max(so_id),0) into b_kq from tbh_hd_di where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
return b_kq;
end;

