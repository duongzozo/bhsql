create or replace function FTBH_GDTU_TXT(b_ma_dvi varchar2,b_so_id_tt number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_txt clob;
begin
-- Dan
select count(*) into b_i1 from bh_bt_gd_hs_tu_txt where ma_dvi=b_ma_dvi and so_id=b_so_id_tt and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_bt_gd_hs_tu_txt where ma_dvi=b_ma_dvi and so_id=b_so_id_tt and loai='dt_ct';
    b_kq:=FKH_JS_GTRIu(b_txt,b_tim);
end if;
return b_kq;
end;
/
-- Hach toan nghiep vu bao hiem 
create or replace procedure PBH_KT_HTOAN_HD_TTn(
    b_ma_dvi varchar2,b_so_id_tt number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_so_id number; b_gchu nvarchar2(500); b_ten nvarchar2(500);
    b_ngay_ht number; b_bt number:=0; b_ngay_hl number; b_nam_hl number; b_nam_tt number; b_nam_ng number;
    b_ttoan number; b_thue number; b_dt number:=0; b_tr number:=0;
    b_tk_no varchar2(20); b_tk_dt varchar2(20); b_tk_dtV varchar2(20); b_tk_tr varchar2(20);
begin
-- Dan - Cho no phi
select ngay_ht,ttoan_qd,thue_qd,ten into b_ngay_ht,b_ttoan,b_thue,b_ten
    from bh_hd_goc_ttps where so_id_tt=b_so_id_tt;
b_nam_tt:=PKH_SO_NAM(b_ngay_ht);
b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_PH_KH');
PBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_PH_BH',b_tk_dt,b_tk_dtV);
b_tk_tr:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_PH_TR');
--
b_bt:=b_bt+1; b_gchu:=substr('Cho no phi ('||b_ten||')',1,200);
insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_tk_no,b_ttoan,b_gchu,b_bt); b_gchu:=' ';
for r_lp in(select distinct so_id from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt order by so_id) loop
    b_so_id:=r_lp.so_id;
    b_ngay_hl:=FBH_HD_NGAY_HL(b_ma_dvi,b_so_id,b_ngay_ht); b_nam_hl:=PKH_SO_NAM(b_ngay_hl);
    for r_lp1 in (select ngay,sum(phi_qd) phi from bh_hd_goc_ttpt
        where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and so_id=b_so_id group by ngay) loop
        b_nam_ng:=PKH_SO_NAM(r_lp1.ngay);
        if (b_nam_tt<b_nam_ng and add_months(PKH_SO_CDT(b_ngay_hl),12)<PKH_SO_CDT(r_lp1.ngay)) or
            (b_nam_hl<3000 and b_nam_hl>b_nam_tt) then
            b_tr:=b_tr+r_lp1.phi;
        else
            b_dt:=b_dt+r_lp1.phi;
        end if;
    end loop;
end loop;
if b_dt>0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_dt,b_dt,b_bt);
elsif b_dt<0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_tk_dt,-b_dt,b_bt);
end if;
if b_tr>0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_tr,b_tr,b_bt);
elsif b_tr<0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_tk_tr,b_tr,b_bt);
end if;
if b_thue>0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_dtV,b_thue,b_bt);
elsif b_thue<0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_tk_dtV,-b_thue,b_bt);
end if;
b_loi:='';
exception when others then if trim(b_loi) is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_HD_TTn:loi'; end if;
end;
/
create or replace procedure PBH_KT_HTOAN_HD_TTt(
    b_ma_dvi varchar2,b_so_id_tt number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_so_id number;
    b_nt_tra varchar2(5); b_tra number; b_tra_qd number; b_nhang varchar2(500); b_tk_nha varchar2(20);
    b_ngay_ht number; b_bt number:=0; b_ngay_hl number; b_nam_hl number; b_nam_tt number; b_nam_ng number;
    b_ttoan number; b_thue number:=0; b_chenh number; b_phi number; b_dt number:=0; b_tr number:=0; b_cno number:=0;
    b_gchu nvarchar2(500); b_tk_no varchar2(20); b_tk_dt varchar2(20); b_tk_dtV varchar2(20);
    b_tk_tr varchar2(20); b_ma_tk varchar2(20); b_tk_cno varchar2(20);
    b_pt_tra varchar2(1); b_ten nvarchar2(500); b_nv varchar2(1);
begin
-- Dan - Thanh toan phi
select nt_tra,pt_tra,ngay_ht,ttoan_qd,nt_tra,tra,tra_qd,ten into
    b_nt_tra,b_pt_tra,b_ngay_ht,b_ttoan,b_nt_tra,b_tra,b_tra_qd,b_ten from bh_hd_goc_ttps where so_id_tt=b_so_id_tt;
b_tk_nha:=FBH_HD_TT_TXT(b_ma_dvi,b_so_id_tt,'ma_tk'); b_nhang:=FBH_HD_TT_TXT(b_ma_dvi,b_so_id_tt,'nhang');
if b_pt_tra='C' then        -- Cong no khac khach hang
    b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'K','CN_KH_KH');
elsif b_pt_tra='D' then     -- Dai ly thu
    b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_PH_DL');
elsif b_pt_tra ='B' then    -- Leader thu
    b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CN_PHL_BH');
	elsif b_pt_tra ='V' then    -- Tai thu
    b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','CN_PHL_BH');
elsif b_pt_tra='H' then     -- No kho doi
    b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_PH_KHO');
else
    b_tk_no:=FBH_KT_TK_TRAt(b_ma_dvi,b_ngay_ht,b_nt_tra,b_tk_nha);
end if;
PBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_PH_BH',b_tk_dt,b_tk_dtV);
b_tk_tr:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_PH_TR');
b_tk_cno:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_PH_KH');
--
b_chenh:=b_ttoan-b_tra_qd;
b_gchu:=substr('Thanh toan phi ('||b_ten||'). '||'N.te tra:'||b_nt_tra,1,500);
if b_tra_qd>0 then
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,c4,n10) values('N',b_tk_no,b_tra_qd,b_gchu,b_bt); b_gchu:=' ';
end if;
if b_chenh>0 then
    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'P',' ','C');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,b_chenh,b_bt);
end if;
for r_lp in(select distinct so_id from bh_hd_goc_tthd where
    ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt order by so_id) loop
    b_so_id:=r_lp.so_id;
    b_ngay_hl:=FBH_HD_NGAY_HL(b_ma_dvi,b_so_id,b_ngay_ht); b_nam_hl:=PKH_SO_NAM(b_ngay_hl);
    for r_lp1 in (select ngay,pt,sum(phi_qd) phi,sum(thue_qd) thue from bh_hd_goc_ttpt
        where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and so_id=b_so_id and pt not in('C','H')
        group by ngay,pt having sum(phi_qd)<>0) loop
        if r_lp1.pt<>'G' then
            b_cno:=b_cno+r_lp1.phi+r_lp1.thue;
        else
            b_nam_ng:=PKH_SO_NAM(r_lp1.ngay);
            if (b_nam_tt<b_nam_ng and add_months(PKH_SO_CDT(b_ngay_hl),12)<PKH_SO_CDT(r_lp1.ngay)) or
                (b_nam_hl<3000 and b_nam_hl>b_nam_tt) then
                b_tr:=b_tr+r_lp1.phi;
            else
                b_dt:=b_dt+r_lp1.phi;
            end if;
            b_thue:=b_thue+r_lp1.thue;
        end if;
    end loop;
end loop;
b_gchu:=substr('Thanh toan phi ('||b_ten||')',1,500);
if b_cno>0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_cno,b_cno,b_bt);
elsif b_cno<0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_cno,-b_cno,b_bt,b_gchu); b_gchu:=' ';
end if;
if b_dt>0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_dt,b_dt,b_bt);
elsif b_dt<0 then
    PBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_PH_BHl',b_tk_dt,b_tk_dtV); -- HUY: Bo sung TK giam phi trong ky
	b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_dt,-b_dt,b_bt,b_gchu); b_gchu:=' ';
end if;
if b_tr>0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_tr,b_tr,b_bt);
elsif b_tr<0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_tr,b_tr,b_bt,b_gchu); b_gchu:=' ';
end if;
if b_thue>0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_dtV,b_thue,b_bt);
elsif b_thue<0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_tk_dtV,-b_thue,b_bt);
end if;
if b_tra_qd<0 then
    if b_tk_nha<>' ' then b_gchu:='Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_tk_no,-b_tra_qd,b_bt,b_gchu);
end if;
if b_chenh<0 then
    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'D',' ','C');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,-b_chenh,b_bt);
end if;
b_loi:='';
exception when others then
    if trim(b_loi) is null then b_loi:='Loi xu ly:'; end if;
    b_loi:='loi:'||trim(b_loi)||' (PBH_KT_HTOAN_HD_TTn):loi';
end;
/
create or replace procedure PBH_KT_HTOAN_HD_TTd(
    b_ma_dvi varchar2,b_so_id_tt number,b_loi out varchar2)
AS
    b_i1 number; b_bt number; b_ngay_ht number; b_tim varchar2(20); b_nhom varchar2(1);
    b_tl number; b_tk_no varchar2(20); b_tk_co varchar2(20);
    b_tk_hh varchar2(20); b_tk_ht varchar2(20); b_tk_dv varchar2(20);
    b_do number:=0; b_ta number:=0; b_do_hh number:=0; b_ta_hh number:=0; 
    b_loai varchar2(1); b_tien number; b_nv varchar2(1);
begin
-- Dan - Lien quan thanh toan phi
select ngay_ht into b_ngay_ht from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
select nvl(max(n10),0) into b_bt from ket_qua;
for r_lp in(select so_id,so_id_dt,lh_nv,phi_qd
    from bh_hd_goc_ttptdt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and pt<>'N' and lh_nv<>' ') loop
    if FBH_DONG(b_ma_dvi,r_lp.so_id)='D' then
        b_tl:=FBH_DONG_TL_DT(b_ma_dvi,r_lp.so_id,r_lp.so_id_dt,r_lp.lh_nv);
        if b_tl<>0 then
            b_do:=b_do+round(b_tl*r_lp.phi_qd/100,0);
            b_do_hh:=b_do_hh+FBH_DONG_TL_HH(b_ma_dvi,r_lp.so_id,r_lp.so_id_dt,r_lp.lh_nv,r_lp.phi_qd);
        end if;
    end if;
    b_tl:=FTBH_GHEP_TL_DT(b_ma_dvi,r_lp.so_id,r_lp.so_id_dt,r_lp.lh_nv,b_ngay_ht);
    if b_tl<>0 then
        b_ta:=b_ta+round(b_tl*r_lp.phi_qd/100,0);
        b_ta_hh:=b_ta_hh+FTBH_GHEP_HH_DT(b_ma_dvi,r_lp.so_id,r_lp.so_id_dt,r_lp.lh_nv,b_ngay_ht,r_lp.phi_qd);
    end if;
    b_tl:=FTBH_TM_TL_DT(b_ma_dvi,r_lp.so_id,r_lp.so_id_dt,r_lp.lh_nv,b_ngay_ht);
    if b_tl<>0 then
        b_ta:=b_ta+round(b_tl*r_lp.phi_qd/100,0);
        b_ta_hh:=b_ta_hh+FTBH_TM_HH_DT(b_ma_dvi,r_lp.so_id,r_lp.so_id_dt,r_lp.lh_nv,b_ngay_ht,r_lp.phi_qd);
    end if;
end loop;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CH_PHF_BHd');
if b_do<>0 and trim(b_tk_co) is not null then
    b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CH_PHF_BH');
    if b_do>0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,b_do,b_bt,'Dong BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,b_do,b_bt);
    else
		b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_PH_BHl');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,-b_do,b_bt,'Dong BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,-b_do,b_bt);
    end if;
    b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','DT_FLPd');
    if b_do_hh<>0 and trim(b_tk_no) is not null then
        b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','DT_FLP');
        if b_do_hh>0 then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,b_do_hh,b_bt,'Phi quan ly hop dong');
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,b_do_hh,b_bt);
        else
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,-b_do_hh,b_bt,'Phi quan ly hop dong');
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,-b_do_hh,b_bt);
        end if;
    end if;
end if;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','CH_PHF_BHd');
if b_ta<>0 and trim(b_tk_co) is not null then
    b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','CH_PHF_BH');
    if b_ta>0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,b_ta,b_bt,'Tai BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,b_ta,b_bt);
    else
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,-b_ta,b_bt,'Tai BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,-b_ta,b_bt);
    end if;
    b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','DT_FLPd');
    if b_ta_hh<>0 and trim(b_tk_no) is not null then
        b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','DT_FLP');
        if b_ta_hh>0 then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,b_ta_hh,b_bt,'Hoa hong tai');
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,b_ta_hh,b_bt);
        else
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,-b_ta_hh,b_bt,'Hoa hong tai');
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,-b_ta_hh,b_bt);
        end if;
    end if;
end if;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HH_DLd');
if trim(b_tk_co) is not null then
    b_tk_hh:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HH_DL');
    b_tk_ht:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HT_DL');
    b_tk_dv:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_DV_DL');
    b_i1:=0;
    for r_lp in(select loai,sum(hhong_qd) hh,sum(htro_qd) htro,sum(dvu_qd) dvu from
        (select hhong_qd,htro_qd,dvu_qd,FBH_HD_MA_KT_LOAI(ma_dvi,so_id) loai
        from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and lh_nv<>' ' and pt<>'N')
        where loai<>' ' group by loai) loop
        if r_lp.loai='C' then b_loai:='2'; else b_loai:='1'; end if;
		if r_lp.loai='C' then 
			b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HH_DLc');
		else 
			b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HH_DLt');
		end if;
		b_i1:=b_i1+r_lp.hh+r_lp.htro+r_lp.dvu;
        if r_lp.hh>0 then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,r_lp.hh,b_bt,'Hoa hong Dai ly/Moi gioi');
        end if;
		if r_lp.loai='C' then 
			b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HT_DLc');
		else 
			b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HT_DLt');
        end if;
        if r_lp.htro>0 then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,r_lp.htro,b_bt,'Ho tro Dai ly');
        end if;
        b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_DV_DL');
        if r_lp.dvu>0 then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,r_lp.dvu,b_bt,'Dich vu Dai ly');
        end if;
    end loop;
    if b_i1>0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co||b_loai,b_i1,b_bt);
    elsif b_i1<0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_tk_co||b_loai,-b_i1,b_bt);
    end if;
    for r_lp in(select loai,sum(hhong_qd) hh,sum(htro_qd) htro,sum(dvu_qd) dvu from
        (select hhong_qd,htro_qd,dvu_qd,FBH_HD_MA_KT_LOAI(ma_dvi,so_id) loai
        from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and lh_nv<>' ' and pt<>'N')
        where loai<>' ' group by loai) loop
        if r_lp.loai='C' then b_loai:='2'; else b_loai:='1'; end if;
		if r_lp.loai='C' then 
			b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HH_DLc');
		else 
			b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HH_DLt');
		end if;
		b_i1:=b_i1+r_lp.hh+r_lp.htro+r_lp.dvu;
        If r_lp.hh<0 then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,C4) values('C',b_tk_no,-r_lp.hh,b_bt,'Hoa hong Dai ly/Moi gioi');
        end if;
		if r_lp.loai='C' then 
			b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HT_DLc');
		else 
			b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HT_DLt');
        end if;
        if r_lp.htro<0 then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,C4) values('C',b_tk_no,-r_lp.htro,b_bt,'Ho tro Dai ly');
        end if;
        b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_DV_DL');
        if r_lp.dvu<0 then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,C4) values('C',b_tk_no,-r_lp.dvu,b_bt,'Dich vu Dai ly');
        end if;
    end loop;
	b_do:=0;
    for r_lp in(select so_id,so_id_dt,lh_nv,sum(hhong_qd+htro_qd+dvu_qd) hh
        from bh_hd_goc_ttptdt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and pt<>'N' and
        lh_nv<>' ' and FBH_DONG(b_ma_dvi,so_id)='D' group by so_id,so_id_dt,lh_nv) loop
        b_tl:=FBH_DONG_TL_DT(b_ma_dvi,r_lp.so_id,r_lp.so_id_dt,r_lp.lh_nv);
        if b_tl<>0 then b_do:=b_do+round(b_tl*r_lp.hh/100,0); end if;
    end loop;
    b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','DT_HH_DLd');
    if b_do<>0 and trim(b_tk_no) is not null then
        b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','DT_HH_DL');
        if b_do>0 then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,b_do,b_bt,'Chi phi Dai ly nha Dong');
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,b_do,b_bt);
        else
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_tk_co,-b_do,b_bt);
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_tk_no,-b_do,b_bt,'Chi phi Dai ly nha Dong');
        end if;        
    end if;
end if;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_DV_TPAd');
select nvl(sum(tpa_phi_qd),0) into b_tien from bh_tpa_hd where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
if b_tien<>0 and trim(b_tk_co) is not null then
    b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_DV_TPA');
    if b_tien>0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,b_tien,b_bt,'TPA');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,b_tien,b_bt);
    else
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,-b_tien,b_bt,'TPA');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,-b_tien,b_bt);
    end if;
    b_tien:=0;
    for r_lp in(select so_id,so_id_dt,lh_nv,sum(tpa_phi_qd) tpa
        from bh_tpa_hd_pt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and FBH_DONG(b_ma_dvi,so_id)='D' group by so_id,so_id_dt,lh_nv) loop
        b_tl:=FBH_DONG_TL_DT(b_ma_dvi,r_lp.so_id,r_lp.so_id_dt,r_lp.lh_nv);
        if b_tl<>0 then b_tien:=b_tien+round(b_tl*r_lp.tpa/100,0); end if;
    end loop;
    b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','DT_DV_TPAd');
    if b_tien<>0 and trim(b_tk_no) is not null then
        b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','DT_DV_TPA');
        if b_tien>0 then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,b_tien,b_bt,'Chi phi TPA nha Dong');
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,b_tien,b_bt);
        else
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,-b_tien,b_bt,'Chi phi TPA nha Dong');
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,-b_tien,b_bt);
        end if;        
    end if;
end if;
-- AAA Follow
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CH_LEPd');
if trim(b_tk_co) is not null then
    b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CH_LEP');
    for r_lp in (select nv,sum(tien_qd) tien from bh_hd_do_ps where
        ma_dvi=b_ma_dvi and so_id_ps=b_so_id_tt and loai='CH_LEPd' group by nv) loop
        if (r_lp.nv='N' and r_lp.tien>0) or (r_lp.nv<>'N' and r_lp.tien<0) then b_nv:='N'; else b_nv:='C'; end if;
        b_tien:=abs(r_lp.tien);
        if b_nv='N' then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,b_tien,b_bt,'Phi quan ly hop dong');
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,b_tien,b_bt);
        else
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,b_tien,b_bt,'Phi quan ly hop dong');
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,b_tien,b_bt);
        end if;
    end loop;
end if;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','CH_LEPd');
if trim(b_tk_co) is not null then
    b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','CH_LEP');
    for r_lp in (select nv,sum(tien_qd) tien from tbh_ps where
        ma_dvi=b_ma_dvi and so_id_nv=b_so_id_tt and loai='CH_LEPd' group by nv) loop
        if (r_lp.nv='N' and r_lp.tien>0) or (r_lp.nv<>'N' and r_lp.tien<0) then b_nv:='N'; else b_nv:='C'; end if;
        b_tien:=abs(r_lp.tien);
        if b_nv='N' then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,b_tien,b_bt,'Tai BH');
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,b_tien,b_bt);
        else
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_tk_co,b_tien,b_bt);
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,b_tien,b_bt);
        end if;
    end loop;
    --
    for r_lp in (select nv,sum(tien_qd) tien from tbh_tmN_ps where
        ma_dvi=b_ma_dvi and so_id_ps=b_so_id_tt and loai='CH_LEPd' group by nv) loop
        if (r_lp.nv='N' and r_lp.tien>0) or (r_lp.nv<>'N' and r_lp.tien<0) then b_nv:='N'; else b_nv:='C'; end if;
        b_tien:=abs(r_lp.tien);
        if b_nv='N' then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_tk_no,b_tien,b_bt);
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,b_tien,b_bt);
        else
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_tk_co,b_tien,b_bt);
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,b_tien,b_bt);
        end if;
    end loop;
end if;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CH_HH_DLd');                      
-- Chi hoa hong dai ly Lead chi ho
if trim(b_tk_co) is not null then
    b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CH_HH_DL');
    for r_lp in (select nv,sum(tien_qd) tien from bh_hd_do_ps where
        ma_dvi=b_ma_dvi and so_id_ps=b_so_id_tt and loai='CH_HH_DLd' group by nv) loop
        if (r_lp.nv='N' and r_lp.tien>0) or (r_lp.nv<>'N' and r_lp.tien<0) then b_nv:='N'; else b_nv:='C'; end if;
        b_tien:=abs(r_lp.tien);
        if b_nv='N' then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,b_tien,b_bt,'Dong BH');
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,b_tien,b_bt);
        else
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,b_tien,b_bt,'Dong BH');
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,b_tien,b_bt);
        end if;
    end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_HD_TTd:loi'; end if;
end;
/
create or replace procedure PBH_KT_HTOAN_HD_TT(
    b_ma_dvi varchar2,b_so_id_tt number,b_loi out varchar2)
AS
    b_pt_tra varchar2(1);
begin
-- Dan - Thanh toan phi
select pt_tra into b_pt_tra from bh_hd_goc_ttps where so_id_tt=b_so_id_tt;
if b_pt_tra='N' then
    PBH_KT_HTOAN_HD_TTn(b_ma_dvi,b_so_id_tt,b_loi);             -- Cho no phi
else
    PBH_KT_HTOAN_HD_TTt(b_ma_dvi,b_so_id_tt,b_loi);             -- Thanh toan
end if;
if b_loi is not null then return; end if;
PBH_KT_HTOAN_HD_TTd(b_ma_dvi,b_so_id_tt,b_loi);                 -- Hach toan kep
exception when others then
    if trim(b_loi) is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_HD_TT:loi'; end if;
end;
/
-- Huy hop dong
create or replace procedure PBH_KT_HTOAN_HD_HUt(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number;
    b_nhang varchar2(500); b_tk_nha varchar2(20); b_ngay_ht number; b_bt number:=0;
    b_choP number; b_choT number; b_hoanP number; b_hoanT number;
    b_chenh number:=0; b_nt_tra varchar2(5); b_tra number;
    b_gchu nvarchar2(500); b_tk_co varchar2(20); b_tk_dt varchar2(20); b_tk_dtV varchar2(20);
    b_ma_tk varchar2(20); b_pt_tra varchar2(1); b_ten nvarchar2(500);
begin
-- Dan - Huy hop dong
select nt_tra,pt_tra,ngay_ht,choP_qd,choT_qd,hoanP_qd,hoanT_qd,tra_qd,ten||' - '||so_hd into
    b_nt_tra,b_pt_tra,b_ngay_ht,b_choP,b_choT,b_hoanP,b_hoanT,b_tra,b_ten from bh_hd_goc_hu where so_id=b_so_id;
if b_tra<>0 then b_chenh:=b_tra-b_hoanP-b_hoanT; end if;
b_gchu:=substr('Huy hop dong ('||b_ten||')',1,200);
PBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_PH_BHh',b_tk_dt,b_tk_dtV);
if b_choP<>0 then
    b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_PH_KH');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_dt,b_choP+b_hoanP,b_bt,b_gchu);
    if b_choT<>0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_tk_dt,b_choT+b_hoanT,b_bt);
    end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,b_choP+b_choT,b_bt);
elsif b_hoanP<>0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_dt,b_hoanP,b_bt,b_gchu);
    if b_hoanT<>0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_tk_dtV,b_hoanT,b_bt);
    end if;
end if;
if b_tra=0 then b_loi:=''; return; end if;
b_nhang:=nvl(trim(FBH_HD_HU_TXT(b_ma_dvi,b_so_id,'nhang')),' ');
b_tk_nha:=nvl(trim(FBH_HD_HU_TXT(b_ma_dvi,b_so_id,'ma_tk')),' ');
if b_pt_tra='C' then         -- Cong no khac khach hang
    if b_tra<>0 then
        b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'K','CN_KH_KH');
    else
        b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_PH_KH');
    end if;
elsif b_pt_tra ='B' then     -- Leader thu
    b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CN_PHL_BH');
elsif b_pt_tra ='V' then     -- Tai BH thu
    b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','CN_PHT_BH');
else
    b_tk_co:=FBH_KT_TK_TRAt(b_ma_dvi,b_ngay_ht,b_nt_tra,b_tk_nha);
end if;
if b_chenh>0 then
    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'P',' ','N');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,b_chenh,b_bt);
end if;
b_gchu:='N.te tra:'||b_nt_tra;
if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_tk_co,b_tra,b_bt,b_gchu);
if b_chenh<0 then
    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'D',' ','C');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,-b_chenh,b_bt);
end if;
b_loi:='';
exception when others then
    if trim(b_loi) is null then b_loi:='Loi xu ly:'; end if;
    b_loi:='loi:'||trim(b_loi)||' (PBH_KT_HTOAN_HD_HUt):loi';
end;
/
create or replace procedure PBH_KT_HTOAN_HD_HUd(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_bt number; b_ngay_ht number; b_tk_no varchar2(20); b_tk_co varchar2(20); b_loai varchar2(1);
    b_tien number; b_tra number; b_hoanP number; b_con number; b_so_id_tt number;
    b_tk_hh varchar2(20); b_tk_ht varchar2(20); b_tk_dv varchar2(20);

begin
-- Dan - Lien quan huy hop dong
select ngay_ht into b_ngay_ht from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id;
select nvl(max(n10),0) into b_bt from ket_qua;
b_so_id_tt:=b_so_id*10;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CH_PHF_BHd');
select nvl(sum(tien_qd),0) into b_tien from bh_hd_do_ps where
    ma_dvi=b_ma_dvi and so_id_ps=b_so_id_tt and loai='CH_PHF_BHd';
if b_tien<>0 and trim(b_tk_co) is not null then
    b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CH_PHF_BH');
    if b_tien<0 then
        b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_PH_BHh');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,-b_tien,b_bt,'Dong BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,-b_tien,b_bt);
    else
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,b_tien,b_bt,'Dong BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,b_tien,b_bt);
    end if;
end if;
b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','DT_FLPd');
select nvl(sum(tien_qd),0) into b_tien from bh_hd_do_ps where
    ma_dvi=b_ma_dvi and so_id_ps=b_so_id_tt and loai='DT_FLPd';
if b_tien<>0 and trim(b_tk_no) is not null then
    b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','DT_FLP');
    if b_tien<0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,-b_tien,b_bt,'Phi quan ly Hop dong');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,-b_tien,b_bt);
    else
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,b_tien,b_bt,'Phi quan ly Hop dong');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,b_tien,b_bt);
    end if;
end if;
b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','DT_HH_DLd');
select nvl(sum(tien_qd),0) into b_tien from bh_hd_do_ps where
    ma_dvi=b_ma_dvi and so_id_ps=b_so_id_tt and loai='DT_HH_DLd';
if b_tien<>0 and trim(b_tk_no) is not null then
    b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','DT_HH_DL');
    if b_tien<0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,-b_tien,b_bt,'Chi phi Dai ly Dong BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,-b_tien,b_bt);
    else
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,b_tien,b_bt,'Chi phi Dai ly Dong BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,b_tien,b_bt);
    end if;
end if;
select nvl(sum(tien_qd),0) into b_tien from bh_hd_do_ps where
    ma_dvi=b_ma_dvi and so_id_ps=b_so_id_tt and loai='DT_DV_TPAd';
if b_tien<>0 and trim(b_tk_no) is not null then
    b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','DT_DV_TPA');
    if b_tien<0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,-b_tien,b_bt,'Chi phi TPA Dong BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,-b_tien,b_bt);
    else
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,b_tien,b_bt,'Chi phi TPA Dong BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,b_tien,b_bt);
    end if;
end if;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','CH_PHF_BHd');
select nvl(sum(tien_qd),0) into b_tien from tbh_ps where
    ma_dvi=b_ma_dvi and so_id_nv=b_so_id_tt and goc='CH_PHF_BHd';
if b_tien<>0 and trim(b_tk_co) is not null then
    b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','CH_PHF_BH');
    if b_tien<0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,-b_tien,b_bt,'Tai BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,-b_tien,b_bt);
    else
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,b_tien,b_bt,'Tai BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,b_tien,b_bt);
    end if;
end if;
b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','DT_FLPd');
select nvl(sum(tien_qd),0) into b_tien from tbh_ps where
    ma_dvi=b_ma_dvi and so_id_nv=b_so_id_tt and loai='DT_FLPd';
if b_tien<>0 and trim(b_tk_no) is not null then
    b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','DT_FLP');
    if b_tien<0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,-b_tien,b_bt,'Tai BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,-b_tien,b_bt);
    else
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,b_tien,b_bt,'Tai BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,b_tien,b_bt);
    end if;
end if;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HH_DLd');
if trim(b_tk_co) is not null then
    b_tk_hh:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HH_DL');
    b_tk_ht:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HT_DL');
    b_tk_dv:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_DV_DL');
    b_i1:=0;
    for r_lp in(select loai,nvl(sum(hhong_qd),0) hh,nvl(sum(htro_qd),0) htro,nvl(sum(dvu_qd),0) dvu from
        (select hhong_qd,htro_qd,dvu_qd,FBH_HD_MA_KT_LOAI(ma_dvi,so_id) loai
        from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and lh_nv<>' ' and pt='H')
        where loai<>' ' group by loai) loop
        if r_lp.loai='C' then b_loai:='2'; else b_loai:='1'; end if;
        if r_lp.loai='C' then 
			b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HH_DLc');
		else 
			b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HH_DLt');
		end if;
		b_i1:=b_i1+r_lp.hh+r_lp.htro+r_lp.dvu;
        if r_lp.hh>0 then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,r_lp.hh,b_bt,'Hoa hong Dai ly/Moi gioi');
        end if;
		if r_lp.loai='C' then 
			b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HT_DLc');
		else 
			b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HT_DLt');
        end if;
        if r_lp.htro>0 then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,r_lp.htro,b_bt,'Ho tro Dai ly');
        end if;
        b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_DV_DL');
        if r_lp.dvu>0 then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,r_lp.dvu,b_bt,'Dich vu Dai ly');
        end if;
    end loop;
    if b_i1>0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co||b_loai,b_i1,b_bt);
    elsif b_i1<0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_tk_co||b_loai,-b_i1,b_bt);
    end if;
	    for r_lp in(select loai,nvl(sum(hhong_qd),0) hh,nvl(sum(htro_qd),0) htro,nvl(sum(dvu_qd),0) dvu from
        (select hhong_qd,htro_qd,dvu_qd,FBH_HD_MA_KT_LOAI(ma_dvi,so_id) loai
        from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and lh_nv<>' ' and pt='H')
        where loai<>' ' group by loai) loop
        if r_lp.loai='C' then b_loai:='2'; else b_loai:='1'; end if;
        if r_lp.loai='C' then 
			b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HH_DLc');
		else 
			b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HH_DLt');
		end if;
		b_i1:=b_i1+r_lp.hh+r_lp.htro+r_lp.dvu;
        if r_lp.hh<0 then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,C4) values('C',b_tk_no,-r_lp.hh,b_bt,'Hoa hong Dai ly/Moi gioi');
        end if;
		if r_lp.loai='C' then 
			b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HT_DLc');
		else 
			b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HT_DLt');
        end if;
        if r_lp.htro<0 then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,C4) values('C',b_tk_no,-r_lp.htro,b_bt,'Ho tro Dai ly');
        end if;
        b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_DV_DL');
        if r_lp.dvu<0 then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,C4) values('C',b_tk_no,-r_lp.dvu,b_bt,'Dich vu Dai ly');
        end if;
    end loop;
end if;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_DV_TPAd');
select nvl(sum(tpa_phi_qd),0) into b_tien from bh_tpa_hd where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
if b_tien<>0 and trim(b_tk_co) is not null then
    b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_DV_TPA');
    if b_tien<0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,-b_tien,b_bt,'TPA');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,-b_tien,b_bt);
    else
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,b_tien,b_bt,'TPA');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,b_tien,b_bt);
    end if;
end if;
-- AAA Follow
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CH_LEPd');
select nvl(sum(tien_qd),0) into b_tien from bh_hd_do_ps where
    ma_dvi=b_ma_dvi and so_id_ps=b_so_id_tt and loai='CH_LEPd';
if b_tien<>0 and trim(b_tk_co) is not null then
    b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CH_LEP');
    if b_tien<0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,-b_tien,b_bt,'Phi quan ly Hop dong');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,-b_tien,b_bt);
    else
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,b_tien,b_bt,'Phi quan ly Hop dong');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,b_tien,b_bt);
    end if;
end if;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','CH_LEPd');
select nvl(sum(tien_qd),0) into b_tien from tbh_ps where ma_dvi=b_ma_dvi and so_id_nv=b_so_id_tt and loai='CH_LEPd';
if b_tien<>0 and trim(b_tk_co) is not null then
    b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','CH_LEP');
    if b_tien<0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,-b_tien,b_bt,'Tai BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,-b_tien,b_bt);
    else
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,b_tien,b_bt,'Tai BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,b_tien,b_bt);
    end if;
end if;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CH_HH_DLd');
select nvl(sum(tien_qd),0) into b_tien from bh_hd_do_ps where
    ma_dvi=b_ma_dvi and so_id_ps=b_so_id_tt and loai='CH_HH_DLd';
if b_tien<>0 and trim(b_tk_co) is not null then
    b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D','CH_HH_DL');
    if b_tien<0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,-b_tien,b_bt,'Chi phi Dai ly Dong BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,-b_tien,b_bt);
    else
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,b_tien,b_bt,'Chi phi Dai ly Dong BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,b_tien,b_bt);
    end if;
end if;
b_loi:='';
exception when others then if trim(b_loi) is null then b_loi:='Loi xu ly PBH_KT_HTOAN_HD_HUd:loi'; end if;
end;
/
create or replace procedure PBH_KT_HTOAN_HD_HU(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
begin
-- Dan - Huy hop dong
PBH_KT_HTOAN_HD_HUt(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
PBH_KT_HTOAN_HD_HUd(b_ma_dvi,b_so_id,b_loi);
exception when others then
    if trim(b_loi) is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_HD_HU:loi'; end if;
end;
/
-- Tra hoa hong
create or replace PROCEDURE PBH_KT_HTOAN_HH_DL(
    b_ma_dvi varchar2,b_so_id_hh number,b_loi out varchar2)
AS
    b_i1 number; b_gchu nvarchar2(200); b_tk_pit varchar2(20);
    b_bt number:=0; b_chenh number; b_loai varchar2(1):='1'; b_tien number; b_tra number;
    b_hhong number; b_htro number; b_dvu number; b_thue number;
    b_tk_hhv varchar2(20);b_tk_hh varchar2(20); b_tk_ht varchar2(20):=' '; b_tk_dv varchar2(20):=' '; b_ma_tk varchar2(20); b_tk_chD varchar2(20);
    b_ngay_ht number; b_nhang varchar2(20); b_tk_nha varchar2(500); b_tk_tien varchar2(20);
    r_hd bh_hd_goc_hh%rowtype;
begin
-- Dan - Tra hoa hong
select * into r_hd from bh_hd_goc_hh where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh;
b_ngay_ht:=r_hd.ngay_ht;
if FBH_DTAC_MA_LOAI(r_hd.ma_dl)='C' then b_loai:='2'; end if;
b_tk_pit:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'K','PIT');
b_tk_hh:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HH_DLd');
b_tk_hh:=b_tk_hh||b_loai;
b_tk_hhV:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HH_DLv');
if trim(b_tk_hh) is null then
	if FBH_DTAC_MA_LOAI(r_hd.ma_dl)='C' then 
		b_tk_hh:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HH_DLc');
		b_tk_ht:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HT_DLc');
	else
		b_tk_hh:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HH_DL');
		b_tk_ht:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_HT_DL');
		b_tk_dv:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_DV_DL');
	end if;
end if;
b_tk_nha:=nvl(trim(FBH_HD_HH_TXT(b_ma_dvi,b_so_id_hh,'ma_tk')),' ');
b_nhang:=nvl(trim(FBH_HD_HH_TXT(b_ma_dvi,b_so_id_hh,'nhang')),' ');
if r_hd.pt_tra='C' then
    b_tk_tien:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'K','CN_KH_DL')||b_loai;
else
    b_tk_tien:=FBH_KT_TK_TRAt(b_ma_dvi,b_ngay_ht,r_hd.nt_tra,b_tk_nha);
end if;
select nvl(sum(hhong_qd),0),nvl(sum(htro_qd),0),nvl(sum(dvu_qd),0),
    nvl(sum(thue_hh_qd+thue_ht_qd+thue_dv_qd),0) into b_hhong,b_htro,b_dvu,b_thue
    from bh_hd_goc_hh_pt where ma_dvi=b_ma_dvi and so_id_hh=b_so_id_hh;
if b_tk_ht in(' ',b_tk_hh) then b_hhong:=b_hhong+b_htro; b_htro:=0; end if;
if b_tk_dv in(' ',b_tk_hh) then b_hhong:=b_hhong+b_dvu; b_dvu:=0; end if;
b_tien:=b_hhong+b_htro+b_dvu;
if b_loai='1' then b_tra:=b_tien+b_thue; else b_tra:=b_tien-b_thue; end if;
b_chenh:=b_tra-r_hd.tra_qd;
b_gchu:=substr('Tra hoa hong: '||trim(r_hd.ten),1,200);
if r_hd.tra_qd<0 then
    b_gchu:=b_gchu||'. N.te tra:'||r_hd.nt_tra;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_tien,-r_hd.tra_qd,b_bt,b_gchu); b_gchu:=' ';
end if;
if b_hhong>0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_hh,b_hhong,b_bt,b_gchu); b_gchu:=' ';
end if;
if b_htro>0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_ht,b_htro,b_bt,b_gchu); b_gchu:=' ';
end if;
if b_dvu>0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_dv,b_dvu,b_bt,b_gchu); b_gchu:=' ';
end if;
if b_loai='2' and b_thue<0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_pit,-b_thue,b_bt,'Thue TNCN giu lai');
end if;
if b_loai='1' and b_thue>0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_hhV,b_thue,b_bt,'VAT');
end if;
if b_chenh<0 then
    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'P',' ','C');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,-b_chenh,b_bt);
end if;
if  r_hd.tra_qd>0 then
    b_gchu:='N.te tra:'||r_hd.nt_tra;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_tk_tien,r_hd.tra_qd,b_bt,b_gchu);
end if;
if b_hhong<0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_hh,-b_hhong,b_bt);
end if;
if b_htro<0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_ht,-b_htro,b_bt);
end if;
if b_dvu<0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_dv,-b_dvu,b_bt);
end if;
if b_loai='1' and b_thue<0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_tk_hhV,-b_thue,b_bt,'VAT');
end if;
if b_loai='2' and b_thue>0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_tk_pit,b_thue,b_bt,'Thue TNCN giu lai');
end if;
if b_chenh>0 then
    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'D',' ','C');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_chenh,b_bt);
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_HH_DL:loi'; end if;
end;
/
-- Tra phi dich vu TPA
create or replace PROCEDURE PBH_KT_HTOAN_DV_TPA(
    b_ma_dvi varchar2,b_so_id_tr number,b_loi out varchar2)
AS
    b_i1 number; b_gchu nvarchar2(200);
    b_bt number:=0; b_chenh number; b_tien number; b_thue number;
    b_ma_tk varchar2(20); b_tk_tpa varchar2(20); b_tk_thue varchar2(20); b_tk_tien varchar2(20);
    b_ngay_ht number; b_nhang varchar2(500); b_tk_nha varchar2(20);
    r_hd bh_tpa_tra%rowtype;
begin
-- Dan - Tra hoa hong
select * into r_hd from bh_tpa_tra where ma_dvi=b_ma_dvi and so_id_tr=b_so_id_tr;
b_ngay_ht:=r_hd.ngay_ht;
b_tk_nha:=nvl(trim(FBH_TPA_TT_TXT(b_ma_dvi,b_so_id_tr,'ma_tk')),' ');
b_nhang:=nvl(trim(FBH_TPA_TT_TXT(b_ma_dvi,b_so_id_tr,'nhang')),' ');
if r_hd.pt_tra='C' then
    b_tk_tien:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'K','CN_KH_TPA');
else
    b_tk_tien:=FBH_KT_TK_TRAt(b_ma_dvi,b_ngay_ht,r_hd.nt_tra,b_tk_nha);
end if;
b_tk_tpa:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_DV_TPAd');
if trim(b_tk_tpa) is null then
    b_tk_tpa:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_DV_TPA');
end if;
b_tk_thue:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_DV_TPAv');
b_tien:=r_hd.tien_qd; b_thue:=r_hd.thue_qd;
b_chenh:=b_tien+b_thue-r_hd.tra_qd;
b_gchu:=substr('Tra phi dich vu TPA: '||FBH_DTAC_MA_TEN(r_hd.tpa),1,200);
if r_hd.tra_qd<0 then
    b_gchu:=trim(b_gchu)||'. N.te tra:'||r_hd.nt_tra;
    if b_tk_nha<>' ' then b_gchu:=substr(b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha,1,200); end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_tk_tien,-r_hd.tra_qd,b_bt,b_gchu); b_gchu:=' ';
end if;
if b_tien>0 then
    PBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_DV_TPA',b_ma_tk,b_tk_thue);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_tpa,b_tien,b_bt,b_gchu);
end if;
if b_thue>0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_tk_thue,b_thue,b_bt);
end if;
if b_chenh<0 then
    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'P',' ','C');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,-b_chenh,b_bt);
end if;
if r_hd.tra_qd>0 then
    b_gchu:='N.te tra:'||r_hd.nt_tra;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_tk_tien,r_hd.tra_qd,b_bt,b_gchu);
end if;
if b_tien<0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_tpa,-b_tien,b_bt,b_gchu);
end if;
if b_thue<0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_tk_thue,-b_thue,b_bt);
end if;
if b_chenh>0 then
    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'D',' ','C');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_chenh,b_bt);
end if;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_DV_TPA:loi'; end if;
end;
/
create or replace procedure PBH_KT_HTOAN_BT_TUt(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_ngay_ht number;  b_gchu nvarchar2(200);
    b_bt number:=0; b_chenh number; b_tien number; b_thue number;
    b_nhang varchar2(500); b_tk_nha varchar2(20); b_loai varchar2(10);
    b_ma_tk varchar2(20); b_ma_tkV varchar2(20); b_tk_tra varchar2(20);
    r_hd bh_bt_tu%rowtype;
begin
-- Dan - Chi tung phan
select * into r_hd from bh_bt_tu where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_ngay_ht:=r_hd.ngay_ht;
b_tk_nha:=nvl(trim(FBH_BT_HK_TXT(b_ma_dvi,b_so_id,'ma_tk')),' ');
b_nhang:=nvl(trim(FBH_BT_HK_TXT(b_ma_dvi,b_so_id,'nhang')),' ');
b_chenh:=r_hd.tien_qd+r_hd.thue_qd-r_hd.tra_qd;
if r_hd.pt_tra='C' then
    b_tk_tra:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'K','CN_KH_BH');
elsif r_hd.pt_tra='B' then
    b_tk_tra:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'K','CN_KH_BH');
else
    b_tk_tra:=FBH_KT_TK_TRAt(b_ma_dvi,b_ngay_ht,r_hd.nt_tra,b_tk_nha);
end if;
if r_hd.l_ct='C' then
    PBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_BT_BHd',b_ma_tk,b_ma_tkV);
    b_gchu:=substr('Boi thuong tung phan'||' ('||r_hd.so_ct||'): '||r_hd.ten,1,200);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_ma_tk,r_hd.tien_qd,b_bt,b_gchu);
    if r_hd.thue<>0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tkV,r_hd.thue_qd,b_bt);
    end if;
else
    b_gchu:='N.te tra:'||r_hd.nt_tra;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_tra,r_hd.tra_qd,b_bt,b_gchu);
end if;
if b_chenh<0 then
    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'P',' ','C');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,-b_chenh,b_bt);
end if;
if r_hd.l_ct='T' then
    PBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_BT_BHd',b_ma_tk,b_ma_tkV);
    b_gchu:=substr('Boi thuong tung phan'||' ('||r_hd.so_ct||'): '||r_hd.ten,1,200);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_ma_tk,r_hd.tien_qd,b_bt,b_gchu);
    if r_hd.thue<>0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tkV,r_hd.thue_qd,b_bt);
    end if;
else
    b_gchu:='N.te tra:'||r_hd.nt_tra;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_tk_tra,r_hd.tra_qd,b_bt,b_gchu);
end if;
if b_chenh>0 then
    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'D',' ','C');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_chenh,b_bt);
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_BT_TUt:loi'; end if;
end;
/
create or replace procedure PBH_KT_HTOAN_BT_TUd(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_bt number; b_tk_no varchar2(20); b_tk_co varchar2(20); b_tien number;
    r_hs bh_bt_tu%rowtype;
begin
-- Dan - Du thu duyet boi thuong
select nvl(max(n10),0) into b_bt from ket_qua;
if b_bt=0 then b_loi:=''; return; end if;
select * into r_hs from bh_bt_tu where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_ht,'D','DT_BTF_BHd');
if trim(b_tk_co) is null then b_loi:=''; return; end if;
b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_ht,'D','DT_BTF_BH');
for r_lp in (select nv,sum(tien_qd) tien from bh_hd_do_ps where
    ma_dvi=b_ma_dvi and so_id_ps=b_so_id and loai='DT_BTF_BHd' group by nv) loop
    if r_lp.nv='T' then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,r_lp.tien,b_bt,'Dong BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,r_lp.tien,b_bt);
    else
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,r_lp.tien,b_bt,'Dong BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,r_lp.tien,b_bt);
    end if;
end loop;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_ht,'T','DT_BTF_BHd');
if trim(b_tk_co) is null then b_loi:=''; return; end if;
b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_ht,'T','DT_BTF_BH');
for r_lp in (select ps,sum(tien_qd) tien from tbh_ps where
    ma_dvi=b_ma_dvi and so_id=b_so_id and goc='DT_BTF_BHd' group by ps) loop
    if r_lp.ps='T' then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,r_lp.tien,b_bt,'Tai BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,r_lp.tien,b_bt);
    else
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,r_lp.tien,b_bt,'Tai BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,r_lp.tien,b_bt);
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_BT_TUd:loi'; end if;
end;
/
create or replace procedure PBH_KT_HTOAN_BT_TU(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
begin
-- Dan - Tam ung boi thuong
PBH_KT_HTOAN_BT_TUt(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
PBH_KT_HTOAN_BT_TUd(b_ma_dvi,b_so_id,b_loi);
exception when others then if trim(b_loi) is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_BT_TU:loi'; end if;
end;
/
-- Duyet boi thuong
create or replace procedure PBH_KT_HTOAN_BT_DU(
    b_ma_dvi varchar2,b_so_id_bt number,b_loi out varchar2)
AS
    b_gchu nvarchar2(200):=' '; b_i1 number; b_i2 number;
    b_tk_no varchar2(20); b_tk_co varchar2(20);
    b_bt number:=0; b_thue number:=0; b_tien number:=0; b_tl number;
    r_hs bh_bt_hs%rowtype;
begin
-- Dan - Duyet boi thuong
select * into r_hs from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id_bt;
b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_qd,'G','CH_BT_BHd');
if trim(b_tk_no) is null then b_loi:=''; return; end if;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_qd,'G','CH_BT_BH');
if FBH_DONG(r_hs.ma_dvi_ql,r_hs.so_id_hd)='V' then
    b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_qd,'G','CN_BTL_BH');
    for r_lp in (select lh_nv,tien_qd,thue_qd from bh_bt_hs_nv where ma_dvi=b_ma_dvi and so_id=b_so_id_bt) loop
        b_tl:=FBH_DONG_TL_DT(r_hs.ma_dvi_ql,r_hs.so_id_hd,r_hs.so_id_dt,r_lp.lh_nv);
        if b_tl<>0 then
            b_tien:=b_tien+round(r_lp.tien_qd*b_tl/100,0); b_thue:=b_thue+round(r_lp.thue_qd*b_tl/100,0);
        end if;
    end loop;
elsif FTBH_TMN(r_hs.ma_dvi_ql,r_hs.so_id_hd)='C' then
    b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_qd,'G','CN_BT_BH');
    b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_qd,'G','CH_BTL_BHd');
    for r_lp in (select lh_nv,tien_qd,thue_qd from bh_bt_hs_nv where ma_dvi=b_ma_dvi and so_id=b_so_id_bt) loop
        b_tl:=FTBH_TMN_TL_DT(r_hs.ma_dvi_ql,r_hs.so_id_hd,r_hs.so_id_dt,r_lp.lh_nv);
        if b_tl<>0 then
            b_tien:=b_tien+round(r_lp.tien_qd*b_tl/100,0); b_thue:=b_thue+round(r_lp.thue_qd*b_tl/100,0);
        end if;
    end loop;
else
    b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_qd,'G','CH_BT_BH');
    select nvl(sum(tien_qd),0),nvl(sum(thue_qd),0) into b_tien,b_thue from bh_bt_hs_nv where ma_dvi=b_ma_dvi and so_id=b_so_id_bt;
    if FBH_BT_TXT_NV(b_ma_dvi,b_so_id_bt,'dbhtra',r_hs.nv)='C' then
        for r_lp in (select lh_nv,tien_qd,thue_qd from bh_bt_hs_nv where ma_dvi=b_ma_dvi and so_id=b_so_id_bt) loop
            b_tl:=FBH_DONG_TL_DT(r_hs.ma_dvi_ql,r_hs.so_id_hd,r_hs.so_id_dt,r_lp.lh_nv);
            if b_tl<>0 then
                b_tien:=b_tien-round(r_lp.tien_qd*b_tl/100,0); b_thue:=b_thue-round(r_lp.thue_qd*b_tl/100,0);
            end if;
        end loop;
    end if;
    select nvl(sum(tien_qd),0),nvl(sum(thue_qd),0) into b_i1,b_i2 from bh_bt_hs_nv where ma_dvi=b_ma_dvi and
        so_id in (select so_id from bh_bt_hs where ma_dvi=b_ma_dvi and so_id_bt=b_so_id_bt and ttrang='D');
    b_tien:=b_tien-b_i1; b_thue:=b_thue-b_i2;
    select nvl(sum(tien_qd),0),nvl(sum(thue_qd),0) into b_i1,b_i2 from bh_bt_tu where ma_dvi=b_ma_dvi and so_id_hs=b_so_id_bt;
    b_tien:=b_tien-b_i1; b_thue:=b_thue-b_i2;
    select nvl(sum(tien_qd),0),nvl(sum(thue_qd),0) into b_i1,b_i2 from bh_bt_tu where ma_dvi=b_ma_dvi and so_id_pa=b_so_id_bt;
    b_tien:=b_tien-b_i1; b_thue:=b_thue-b_i2;
end if;
if b_tien<>0 then
    b_gchu:=substr('Duyet ho so/Pa boi thuong ('||r_hs.so_hs||' - '||r_hs.ten||')',1,200);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,b_tien,b_bt,b_gchu);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,b_tien,b_bt);
end if;
--
b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_ht,'D','DT_BTF_BHd');
if trim(b_tk_no) is null then b_loi:=''; return; end if;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_ht,'D','DT_BTF_BH');
for r_lp in (select nv,sum(tien_qd) tien from bh_hd_do_ps where
    ma_dvi=b_ma_dvi and so_id_ps=b_so_id_bt and loai='DT_BTF_BHd' group by nv) loop
    if r_lp.nv='T' then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,r_lp.tien,b_bt,'Dong BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,r_lp.tien,b_bt);
    else
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,r_lp.tien,b_bt,'Dong BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,r_lp.tien,b_bt);
    end if;
end loop;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_ht,'T','DT_BTF_BHd');
if trim(b_tk_co) is null then b_loi:=''; return; end if;
b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_ht,'T','DT_BTF_BH');
for r_lp in (select ps,sum(tien_qd) tien from tbh_ps where
    ma_dvi=b_ma_dvi and so_id=b_so_id_bt and goc='DT_BTF_BHd' group by ps) loop
    if r_lp.ps='T' then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,r_lp.tien,b_bt,'Tai BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,r_lp.tien,b_bt);
    else
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,r_lp.tien,b_bt,'Tai BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,r_lp.tien,b_bt);
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_BT_DU:loi'; end if;
end;
/
-- Thanh toan boi thuong
create or replace procedure PBH_KT_HTOAN_BT_TT(
    b_ma_dvi varchar2,b_so_id_tt number,b_loi out varchar2)
AS
    b_i1 number; b_ngay_ht number;  b_gchu nvarchar2(200);
    b_bt number:=0; b_chenh number; b_tien number; b_thue number;
    b_nhang varchar2(500); b_tk_nha varchar2(20); b_loai varchar2(10);
    b_ma_tk varchar2(20); b_ma_tkB varchar2(20); b_ma_tkV varchar2(20); b_tk_tra varchar2(20);
    r_hd bh_bt_tt%rowtype;
begin
-- Dan - Thanh toan boi thuong
select * into r_hd from bh_bt_tt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
b_ngay_ht:=r_hd.ngay_ht;
b_tk_nha:=nvl(trim(FBH_BT_TT_TXT(b_ma_dvi,b_so_id_tt,'ma_tk')),' ');
b_nhang:=nvl(trim(FBH_BT_TT_TXT(b_ma_dvi,b_so_id_tt,'nhang')),' ');
b_chenh:=r_hd.tien_qd+r_hd.thue_qd-r_hd.tra_qd;
if r_hd.pt_tra='C' then
    if r_hd.tpa=' ' then
        b_tk_tra:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'K','CN_KH_BH');
    else
        b_tk_tra:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CN_BT_TPA');
    end if;
elsif r_hd.pt_tra='B' then
    b_tk_tra:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'K','CN_KH_BH');
else
    b_tk_tra:=FBH_KT_TK_TRAt(b_ma_dvi,b_ngay_ht,r_hd.nt_tra,b_tk_nha);
end if;
b_ma_tkB:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_BT_BH');
if trim(b_ma_tkB) is null then b_ma_tkB:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_BT_BHd'); end if;
b_ma_tkV:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_BT_BHv');
b_gchu:=substr('Thanh toan boi thuong'||' ('||r_hd.so_ct||'): '||r_hd.ten,1,200);
b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_ma_tkB,r_hd.tien_qd,b_bt,b_gchu);
if r_hd.thue<>0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tkV,r_hd.thue_qd,b_bt);
end if;
if b_chenh<0 then
    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'P',' ','C');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,-b_chenh,b_bt);
end if;
b_gchu:='N.te tra:'||r_hd.nt_tra;
if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_tk_tra,r_hd.tra_qd,b_bt,b_gchu);
if b_chenh>0 then
    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'D',' ','C');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_chenh,b_bt);
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
create or replace procedure PBH_KT_HTOAN_BT_HK(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_ngay_ht number;  b_gchu nvarchar2(200);
    b_bt number:=0; b_chenh number; b_tien number; b_thue number;
    b_nhang varchar2(500); b_tk_nha varchar2(20); b_loai varchar2(10);
    b_ma_tk varchar2(20); b_ma_tkB varchar2(20); b_ma_tkV varchar2(20); b_tk_tra varchar2(20);
    r_hd bh_bt_hk%rowtype;
begin
-- Dan - Thanh toan nguoi huong khac
select * into r_hd from bh_bt_hk where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_ngay_ht:=r_hd.ngay_ht;
b_tk_nha:=nvl(trim(FBH_BT_HK_TXT(b_ma_dvi,b_so_id,'ma_tk')),' ');
b_nhang:=nvl(trim(FBH_BT_HK_TXT(b_ma_dvi,b_so_id,'nhang')),' ');
b_chenh:=r_hd.tien_qd+r_hd.thue_qd-r_hd.tra_qd;
b_tk_tra:=FBH_KT_TK_TRAt(b_ma_dvi,b_ngay_ht,r_hd.nt_tra,b_tk_nha);
b_ma_tkB:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_BT_BHd');
if trim(b_ma_tkB) is null then b_ma_tkB:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_BT_BH'); end if;
b_ma_tkV:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_BT_BHv');
if r_hd.l_ct='C' then
    b_gchu:=substr('Tra huong khac'||' ('||r_hd.so_ct||'): '||r_hd.ten,1,200);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_ma_tkB,r_hd.tien_qd,b_bt,b_gchu);
    if r_hd.thue<>0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tkV,r_hd.thue_qd,b_bt);
    end if;
else
    b_gchu:='N.te tra:'||r_hd.nt_tra;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_tra,r_hd.tra_qd,b_bt,b_gchu);
end if;
if b_chenh<0 then
    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'P',' ','C');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,-b_chenh,b_bt);
end if;
if r_hd.l_ct='T' then
    b_gchu:=substr('Tra huong khac'||' ('||r_hd.so_ct||'): '||r_hd.ten,1,200);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_ma_tkB,r_hd.tien_qd,b_bt,b_gchu);
    if r_hd.thue<>0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tkV,r_hd.thue_qd,b_bt);
    end if;
else
    b_gchu:='N.te tra:'||r_hd.nt_tra;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_tk_tra,r_hd.tra_qd,b_bt,b_gchu);
end if;
if b_chenh>0 then
    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'D',' ','C');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_chenh,b_bt);
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
-- Thu doi TBA
create or replace procedure PBH_KT_HTOAN_BT_TBAt(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_ngay_ht number;  b_gchu nvarchar2(200);
    b_bt number:=0; b_chenh number; b_tien number; b_thue number;
    b_nhang varchar2(500); b_tk_nha varchar2(20); b_loai varchar2(10);
    b_ma_tk varchar2(20); b_ma_tkV varchar2(20); b_tk_tra varchar2(20);
    r_hd bh_bt_tba%rowtype;
begin
-- Dan - Thu doi TBA
select * into r_hd from bh_bt_tba where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_ngay_ht:=r_hd.ngay_ht;
b_tk_nha:=nvl(trim(FBH_BT_TBA_TXT(b_ma_dvi,b_so_id,'ma_tk')),' ');
b_nhang:=nvl(trim(FBH_BT_TBA_TXT(b_ma_dvi,b_so_id,'nhang')),' ');
b_chenh:=r_hd.tra_qd-r_hd.tien_qd-r_hd.thue_qd;
b_tk_tra:=FBH_KT_TK_TRAt(b_ma_dvi,b_ngay_ht,r_hd.nt_tra,b_tk_nha);
b_gchu:='N.te tra:'||r_hd.nt_tra;
if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_tra,r_hd.tra_qd,b_bt,b_gchu);
if b_chenh<0 then
    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'P',' ','C');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,-b_chenh,b_bt);
end if;
PBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_BT_TB',b_ma_tk,b_ma_tkV);
b_gchu:=substr('Thu doi nguoi thu ba'||' ('||r_hd.so_ct||'): '||r_hd.ten,1,200);
b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_ma_tk,r_hd.tien_qd,b_bt,b_gchu);
if r_hd.thue<>0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tkV,r_hd.thue_qd,b_bt);
end if;
if b_chenh>0 then
    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'D',' ','C');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_chenh,b_bt);
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_BT_TBAt:loi'; end if;
end;
/
create or replace procedure PBH_KT_HTOAN_BT_TBAd(
    b_ma_dvi varchar2,b_so_id_bt number,b_loi out varchar2)
AS
    b_bt number; b_tk_no varchar2(20); b_tk_co varchar2(20); b_tien number;
    r_hs bh_bt_tba%rowtype;
begin
-- Dan - Du chi TBA
select * into r_hs from bh_bt_tba where ma_dvi=b_ma_dvi and so_id=b_so_id_bt;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_ht,'D','CH_BTF_TBd');
if trim(b_tk_co) is null then b_loi:=''; return; end if;
b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_ht,'D','CH_BTF_TB');
select nvl(max(n10),0) into b_bt from ket_qua;
for r_lp in (select nv,sum(tien_qd) tien from bh_hd_do_ps where
    ma_dvi=b_ma_dvi and so_id_ps=b_so_id_bt and loai='CH_BTF_TBd' group by nv) loop
    if r_lp.nv='T' then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,r_lp.tien,b_bt,'Dong BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,r_lp.tien,b_bt);
    else
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,r_lp.tien,b_bt,'Dong BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,r_lp.tien,b_bt);
    end if;
end loop;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_ht,'T','CH_BTF_TBd');
if trim(b_tk_co) is null then b_loi:=''; return; end if;
b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_ht,'T','CH_BTF_TB');
for r_lp in (select ps,sum(tien_qd) tien from tbh_ps where
    ma_dvi=b_ma_dvi and so_id=b_so_id_bt and goc='CH_BTF_TBd' group by ps) loop
    if r_lp.ps='T' then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,r_lp.tien,b_bt,'Tai BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,r_lp.tien,b_bt);
    else
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,r_lp.tien,b_bt,'Tai BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,r_lp.tien,b_bt);
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_BT_DUd:loi'; end if;
end;
/
create or replace procedure PBH_KT_HTOAN_BT_TBA(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
begin
-- Dan - Duyet boi thuong
PBH_KT_HTOAN_BT_TBAt(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
PBH_KT_HTOAN_BT_TBAd(b_ma_dvi,b_so_id,b_loi);
exception when others then if trim(b_loi) is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_BT_TBA:loi'; end if;
end;
/
-- Thu hoi
create or replace procedure PBH_KT_HTOAN_BT_THOIt(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_ngay_ht number;  b_gchu nvarchar2(200);
    b_bt number:=0; b_tien number; b_thue number;
    b_nhang varchar2(500); b_tk_nha varchar2(20); b_loai varchar2(10);
    b_ma_tk varchar2(20); b_ma_tkV varchar2(20); b_tk_tra varchar2(20);
    r_hd bh_bt_thoi%rowtype;
begin
-- Dan - Thu hoi
select * into r_hd from bh_bt_thoi where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_ngay_ht:=r_hd.ngay_ht;
b_tk_nha:=nvl(trim(FBH_BT_THOI_TXT(b_ma_dvi,b_so_id,'ma_tk')),' ');
b_nhang:=nvl(trim(FBH_BT_THOI_TXT(b_ma_dvi,b_so_id,'nhang')),' ');
b_tk_tra:=FBH_KT_TK_TRAt(b_ma_dvi,b_ngay_ht,r_hd.ma_nt,b_tk_nha);
b_gchu:='N.te tra:'||r_hd.ma_nt;
if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_tra,r_hd.tien_qd+r_hd.thue_qd,b_bt,b_gchu);
PBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','DT_BT_TH',b_ma_tk,b_ma_tkV);
b_gchu:=substr('Thu doi nguoi thu ba'||' ('||r_hd.so_ct||'): '||r_hd.ten,1,200);
b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_ma_tk,r_hd.tien_qd,b_bt,b_gchu);
if r_hd.thue<>0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tkV,r_hd.thue_qd,b_bt);
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_BT_THOIt:loi'; end if;
end;
/
create or replace procedure PBH_KT_HTOAN_BT_THOId(
    b_ma_dvi varchar2,b_so_id_bt number,b_loi out varchar2)
AS
    b_bt number; b_tk_no varchar2(20); b_tk_co varchar2(20); b_tien number;
    r_hs bh_bt_thoi%rowtype;
begin
-- Dan - Du chi thu hoi
select * into r_hs from bh_bt_thoi where ma_dvi=b_ma_dvi and so_id=b_so_id_bt;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_ht,'D','CH_BTF_THd');
if trim(b_tk_co) is null then b_loi:=''; return; end if;
b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_ht,'D','CH_BTF_TH');
select nvl(max(n10),0) into b_bt from ket_qua;
for r_lp in (select nv,sum(tien_qd) tien from bh_hd_do_ps where
    ma_dvi=b_ma_dvi and so_id_ps=b_so_id_bt and loai='CH_BTF_THd' group by nv) loop
    if r_lp.nv='T' then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,r_lp.tien,b_bt,'Dong BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,r_lp.tien,b_bt);
    else
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,r_lp.tien,b_bt,'Dong BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,r_lp.tien,b_bt);
    end if;
end loop;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_ht,'T','CH_BTF_THd');
if trim(b_tk_co) is null then b_loi:=''; return; end if;
b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_ht,'T','CH_BTF_TH');
for r_lp in (select ps,sum(tien_qd) tien from tbh_ps where
    ma_dvi=b_ma_dvi and so_id=b_so_id_bt and goc='CH_BTF_THd' group by ps) loop
    if r_lp.ps='T' then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,r_lp.tien,b_bt,'Tai BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,r_lp.tien,b_bt);
    else
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,r_lp.tien,b_bt,'Tai BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,r_lp.tien,b_bt);
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_BT_DUd:loi'; end if;
end;
/
create or replace procedure PBH_KT_HTOAN_BT_THOI(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
begin
-- Dan - Thu hoi
PBH_KT_HTOAN_BT_THOIt(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
PBH_KT_HTOAN_BT_THOId(b_ma_dvi,b_so_id,b_loi);
exception when others then if trim(b_loi) is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_BT_THOI:loi'; end if;
end;
/
-- Giam dinh boi thuong
create or replace procedure PBH_KT_HTOAN_GD_DU(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_gchu nvarchar2(200):=' '; b_i1 number; b_i2 number;
    b_tk_no varchar2(20); b_tk_co varchar2(20);
    b_bt number:=0; b_tien number:=0; b_tl number;
    r_hs bh_bt_gd_hs%rowtype;
begin
-- Dan - Hoan thanh giam dinh
select * into r_hs from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_qd,'G','CH_BT_GDd');
if trim(b_tk_no) is null then b_loi:=''; return; end if;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_qd,'G','CH_BT_GD');
if FBH_DONG(r_hs.ma_dvi_hd,r_hs.so_id_hd)='V' then
    for r_lp in (select lh_nv,tien_qd from bh_bt_gd_hs_pt where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
        b_tl:=FBH_DONG_TL_DT(r_hs.ma_dvi_hd,r_hs.so_id_hd,r_hs.so_id_dt,r_lp.lh_nv);
        if b_tl<>0 then
            b_tien:=b_tien+round(r_lp.tien_qd*b_tl/100,0);
        end if;
    end loop;
elsif FTBH_TMN(r_hs.ma_dvi_hd,r_hs.so_id_hd)='C' then
    for r_lp in (select lh_nv,tien_qd,thue_qd from bh_bt_gd_hs_pt where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
        b_tl:=FTBH_TMN_TL_DT(r_hs.ma_dvi_hd,r_hs.so_id_hd,r_hs.so_id_dt,r_lp.lh_nv);
        if b_tl<>0 then
            b_tien:=b_tien+round(r_lp.tien_qd*b_tl/100,0);
        end if;
    end loop;
else
    select nvl(sum(tien_qd),0) into b_tien from bh_bt_gd_hs_pt where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if FBH_BT_TXT_NV(b_ma_dvi,r_hs.so_id_bt,'dbhtra',r_hs.nv)='C' then
        for r_lp in (select lh_nv,tien_qd from bh_bt_gd_hs_pt where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
            b_tl:=FBH_DONG_TL_DT(r_hs.ma_dvi_hd,r_hs.so_id_hd,r_hs.so_id_dt,r_lp.lh_nv);
            if b_tl<>0 then
                b_tien:=b_tien-round(r_lp.tien_qd*b_tl/100,0);
            end if;
        end loop;
    end if;
    select nvl(sum(tien_qd),0) into b_i1 from bh_bt_gd_hs_tu where ma_dvi=b_ma_dvi and so_id_hs=b_so_id;
    b_tien:=b_tien-b_i1;
end if;
if b_tien<>0 then
    b_gchu:=substr('Hoan thanh giam dinh ('||r_hs.so_hs||' - '||r_hs.ten||')',1,200);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,b_tien,b_bt,b_gchu);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,b_tien,b_bt);
end if;
b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_ht,'D','DT_BTF_GDd');
if trim(b_tk_no) is null then b_loi:=''; return; end if;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_ht,'D','DT_BTF_GD');
for r_lp in (select nv,sum(tien_qd) tien from bh_hd_do_ps where
    ma_dvi=b_ma_dvi and so_id_ps=b_so_id and loai='DT_BTF_GDd' group by nv) loop
    if r_lp.nv='T' then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,r_lp.tien,b_bt,'Dong BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,r_lp.tien,b_bt);
    else
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,r_lp.tien,b_bt,'Dong BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,r_lp.tien,b_bt);
    end if;
end loop;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_ht,'T','DT_BTF_GDd');
if trim(b_tk_co) is null then b_loi:=''; return; end if;
b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_ht,'T','DT_BTF_GD');
for r_lp in (select ps,sum(tien_qd) tien from tbh_ps where
    ma_dvi=b_ma_dvi and so_id=b_so_id and goc='DT_BTF_GDd' group by ps) loop
    if r_lp.ps='T' then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,r_lp.tien,b_bt,'Tai BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,r_lp.tien,b_bt);
    else
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,r_lp.tien,b_bt,'Tai BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,r_lp.tien,b_bt);
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_GD_DU:loi'; end if;
end;
/
create or replace procedure PBH_KT_HTOAN_GD_TUt(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ngay_ht number; b_gchu nvarchar2(200); b_bt number:=0;
    b_nhang varchar2(500); b_tk_nha varchar2(20);
    b_ma_tk varchar2(20); b_ma_tkV varchar2(20); b_tk_tra varchar2(20);
    r_hd bh_bt_gd_hs_tu%rowtype;
begin
-- Dan - Tam ung giam dinh
select * into r_hd from bh_bt_gd_hs_tu where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_ngay_ht:=r_hd.ngay_ht;
b_tk_nha:=nvl(trim(FTBH_GDTU_TXT(b_ma_dvi,b_so_id,'ma_tk')),' ');
b_nhang:=nvl(trim(FTBH_GDTU_TXT(b_ma_dvi,b_so_id,'nhang')),' ');
b_tk_tra:=FBH_KT_TK_TRAt(b_ma_dvi,b_ngay_ht,r_hd.ma_nt,b_tk_nha);
PBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_BT_GD',b_ma_tk,b_ma_tkV);
if r_hd.l_ct='C' then
    b_gchu:=substr('Chi giam dinh'||' ('||r_hd.so_ct||'): '||FBH_DTAC_MA_TEN(r_hd.ma_gd),1,200);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_ma_tk,r_hd.tien_qd,b_bt,b_gchu);
    if r_hd.thue_qd<>0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tkV,r_hd.thue_qd,b_bt);
    end if;
    b_gchu:='N.te tra:'||r_hd.ma_nt;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_tk_tra,r_hd.ttoan_qd,b_bt,b_gchu);
else
    b_gchu:='N.te tra:'||r_hd.ma_nt;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_tra,r_hd.ttoan_qd,b_bt,b_gchu);
    b_gchu:=substr('Chi giam dinh'||' ('||r_hd.so_ct||'): '||FBH_DTAC_MA_TEN(r_hd.ma_gd),1,200);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_ma_tk,r_hd.tien_qd,b_bt,b_gchu);
    if r_hd.thue_qd<>0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tkV,r_hd.thue_qd,b_bt);
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_GD_TUt:loi'; end if;
end;
/
create or replace procedure PBH_KT_HTOAN_GD_TUd(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_bt number; b_tk_no varchar2(20); b_tk_co varchar2(20); b_tien number;
    r_hs bh_bt_gd_hs_tu%rowtype;
begin
-- Dan - Tam ung giam dinh
select nvl(max(n10),0) into b_bt from ket_qua;
if b_bt=0 then b_loi:=''; return; end if;
select * into r_hs from bh_bt_gd_hs_tu where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_ht,'D','DT_BTF_GDd');
if trim(b_tk_co) is null then b_loi:=''; return; end if;
b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_ht,'D','DT_BTF_GD');
for r_lp in (select nv,sum(tien_qd) tien from bh_hd_do_ps where
    ma_dvi=b_ma_dvi and so_id_ps=b_so_id and loai='DT_BTF_GDd' group by nv) loop
    if r_lp.nv='T' then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,r_lp.tien,b_bt,'Dong BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,r_lp.tien,b_bt);
    else
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,r_lp.tien,b_bt,'Dong BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,r_lp.tien,b_bt);
    end if;
end loop;
b_tk_co:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_ht,'T','DT_BTF_GDd');
if trim(b_tk_co) is null then b_loi:=''; return; end if;
b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,r_hs.ngay_ht,'T','DT_BTF_GD');
for r_lp in (select ps,sum(tien_qd) tien from tbh_ps where
    ma_dvi=b_ma_dvi and so_id=b_so_id and goc='DT_BTF_GDd' group by ps) loop
    if r_lp.ps='T' then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,r_lp.tien,b_bt,'Tai BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_co,r_lp.tien,b_bt);
    else
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,r_lp.tien,b_bt,'Tai BH');
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_no,r_lp.tien,b_bt);
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_GD_TUd:loi'; end if;
end;
/
create or replace procedure PBH_KT_HTOAN_GD_TU(
    b_ma_dvi varchar2,b_so_id_bt number,b_loi out varchar2)
AS
begin
-- Dan - Hoan thanh giam dinh
PBH_KT_HTOAN_GD_TUt(b_ma_dvi,b_so_id_bt,b_loi);
if b_loi is not null then return; end if;
PBH_KT_HTOAN_GD_TUd(b_ma_dvi,b_so_id_bt,b_loi);
exception when others then if trim(b_loi) is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_GD_TU:loi'; end if;
end;
/
create or replace procedure PBH_KT_HTOAN_GD_TT(
    b_ma_dvi varchar2,b_so_id_tt number,b_loi out varchar2)
AS
    b_i1 number; b_ngay_ht number; b_gchu nvarchar2(200);
    b_bt number:=0; b_tien number; b_chenh number;
    b_nhang varchar2(500); b_tk_nha varchar2(20);
    b_tk_no varchar2(20); b_tk_co varchar2(20);
    b_ma_tk varchar2(20); b_ma_tkG varchar2(20); b_ma_tkV varchar2(20); 
    r_hd bh_bt_gd_hs_tt%rowtype;
begin
-- Dan - Thanh toan giam dinh
select * into r_hd from bh_bt_gd_hs_tt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
b_chenh:=r_hd.ttoan_qd-r_hd.tra_qd-r_hd.thue_qd; b_ngay_ht:=r_hd.ngay_ht;
b_tk_nha:=nvl(trim(FTBH_GD_TXT(b_ma_dvi,b_so_id_tt,'ma_tk')),' ');
b_nhang:=nvl(trim(FTBH_GD_TXT(b_ma_dvi,b_so_id_tt,'nhang')),' ');
b_tk_co:=FBH_KT_TK_TRAt(b_ma_dvi,b_ngay_ht,r_hd.nt_tra,b_tk_nha);
b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_BT_GD');
b_ma_tkV:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_BT_GDv');
if trim(b_tk_no) is null then b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'G','CH_BT_GDd'); end if;
if r_hd.ttoan_qd>0 then
    b_gchu:=substr('Thanh toan giam dinh'||' ('||r_hd.so_ct||'): '||FBH_DTAC_MA_TEN(r_hd.ma_gd),1,200);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,r_hd.ttoan_qd,b_bt,b_gchu);
else
    b_gchu:='N.te tra:'||r_hd.nt_tra;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,-r_hd.tra_qd,b_bt,b_gchu);
    if r_hd.thue_qd<0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tkV,-r_hd.thue_qd,b_bt);
    end if;
end if;
if b_chenh<0 then
    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'P',' ','C');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,-b_chenh,b_bt);
end if;
if r_hd.ttoan_qd>0 then
    b_gchu:='N.te tra:'||r_hd.nt_tra;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_tk_co,r_hd.tra_qd,b_bt,b_gchu);
    	if r_hd.thue_qd>0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tkV,r_hd.thue_qd,b_bt);
    end if;
else
    b_gchu:=substr('Thanh toan giam dinh'||' ('||r_hd.so_ct||'): '||FBH_DTAC_MA_TEN(r_hd.ma_gd),1,200);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_tk_no,-r_hd.ttoan_qd,b_bt,b_gchu);
end if;
if b_chenh>0 then
    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'D',' ','C');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_chenh,b_bt);
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_GD_TT:loi'; end if;
end;
/
-- Thanh toan dong
create or replace procedure PBH_KT_HTOAN_DO_TT(
    b_ma_dvi varchar2,b_so_id_tt number,b_loi out varchar2)
AS
    b_i1 number; b_ngay_ht number; b_nhom varchar2(10);
    b_bt number:=0; b_chenh number; b_tien number; b_thue number;
    b_nhang varchar2(500); b_tk_nha varchar2(20); b_loai varchar2(10);
    b_ma_tk varchar2(20); b_ma_tkV varchar2(20);
    b_tk_no varchar2(20); b_tk_co varchar2(20);
    b_tk_tra varchar2(20); b_tk_cit varchar2(20); b_gchu nvarchar2(200);
    r_hd bh_hd_do_tt%rowtype;
begin
-- Dan - Thanh toan dong
select * into r_hd from bh_hd_do_tt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
b_ngay_ht:=r_hd.ngay_ht;
b_tk_nha:=nvl(trim(FBH_HD_DO_TT_TXT(b_ma_dvi,b_so_id_tt,'ma_tk')),' ');
b_nhang:=nvl(trim(FBH_HD_DO_TT_TXT(b_ma_dvi,b_so_id_tt,'nhang')),' ');
b_chenh:=r_hd.chi_qd+r_hd.thue_v_qd-r_hd.thu_qd-r_hd.thue_r_qd-r_hd.cit_qd-r_hd.tra_qd;
if r_hd.pt_tra='C' then
    b_tk_tra:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'K','CN_KH_BH');
else
    b_tk_tra:=FBH_KT_TK_TRAt(b_ma_dvi,b_ngay_ht,r_hd.nt_tra,b_tk_nha);
	if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
end if;
if FBH_DTAC_MA_TXT(r_hd.nha_bh,'nhom')='1' then b_nhom:='CIT'; else b_nhom:='PIT'; end if;
b_tk_cit:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'K',b_nhom);
b_gchu:=substr('Thanh toan dong'||' ('||r_hd.so_ct||'): '||FBH_DTAC_MA_TEN(r_hd.nha_bh),1,200);
if r_hd.tra_qd<0 then
    b_gchu:=trim(b_gchu)||'. N.te tra:'||r_hd.nt_tra;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_gchu:=substr(b_gchu,1,200);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_tra,-r_hd.tra_qd,b_bt,b_gchu); b_gchu:=' ';
end if;
for r_lp in (select loai,sum(tien_qd) tien,sum(thue_qd) thue from bh_hd_do_ct where
    ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and ((nv='C' and tien_qd>0) or (nv<>'C' and tien_qd<0)) group by loai) loop
    b_loai:=replace(r_lp.loai,'d','');
    PBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D',b_loai||'d',b_ma_tk,b_ma_tkV);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_ma_tk,abs(r_lp.tien),b_bt,b_gchu); b_gchu:=' ';
    if r_lp.thue<>0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tkV,abs(r_lp.thue),b_bt);
    end if;
end loop;
if r_hd.cit_qd<0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_tk_cit,-r_hd.cit_qd,b_bt);
end if;
if b_chenh<0 then
    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'P',' ','C');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,-b_chenh,b_bt);
end if;
for r_lp in (select loai,sum(tien_qd) tien,sum(thue_qd) thue from bh_hd_do_ct where
    ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and ((nv='C' and tien_qd<0) or (nv<>'C' and tien_qd>0)) group by loai) loop
    b_loai:=replace(r_lp.loai,'d','');
    b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D',b_loai||'d');
    if trim(b_ma_tk) is null then b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D',b_loai); end if;
    b_ma_tkV:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'D',b_loai||'v');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_ma_tk,abs(r_lp.tien),b_bt,b_gchu); b_gchu:=' ';
    if r_lp.thue<>0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tkV,abs(r_lp.thue),b_bt);
    end if;
end loop;
if r_hd.cit_qd>0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_cit,r_hd.cit_qd,b_bt);
end if;
if r_hd.tra_qd>0 then
    b_gchu:='N.te tra:'||r_hd.nt_tra;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_tk_tra,r_hd.tra_qd,b_bt,b_gchu);
end if;
if b_chenh>0 then
    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'D',' ','C');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_chenh,b_bt);
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_DO_TT:loi'; end if;
end;
/
-- Tai
create or replace procedure PBH_KT_HTOAN_TA_DC(
    b_ma_dvi varchar2,b_so_id_dc number,b_loi out varchar2)
AS
    b_i1 number; b_ngay_ht number; b_co number:=0; b_bt number:=0; b_gchu nvarchar2(200); b_loai varchar2(10);
    b_ma_tk varchar2(20); b_tk_lep varchar2(20); b_tk_flp varchar2(20); b_tk_cit varchar2(20); b_tk_cn varchar2(20);    
    r_hd tbh_dc%rowtype;
begin
-- Dan - Doi chieu tai
select * into r_hd from tbh_dc where ma_dvi=b_ma_dvi and so_id_dc=b_so_id_dc;
b_ngay_ht:=r_hd.ngay_ht;
b_tk_cn:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'K','CN_KH_BH');
b_tk_lep:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','CH_LEP');
b_tk_flp:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','DT_FLP');
b_tk_cit:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'K','CIT');
b_gchu:=substr('Doi chieu tai'||' ('||r_hd.so_bk||'): '||FBH_DTAC_MA_TEN(r_hd.nha_bh),1,200);
for r_lp in (select goc,ps,sum(tien_qd) tien,sum(hhong_qd) hhong,sum(thue_qd) thue
    from tbh_dc_pt where ma_dvi=b_ma_dvi and so_id_dc=b_so_id_dc group by goc,ps) loop
    b_loai:=replace(r_lp.goc,'d','');
    b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T',b_loai||'d');
    if trim(b_ma_tk) is null then b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T',b_loai); end if;
    if r_lp.ps='T' then
        b_co:=b_co+r_lp.tien-r_lp.hhong+r_lp.thue;
        if r_lp.tien>0 then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_ma_tk,r_lp.tien,b_bt,b_gchu); b_gchu:=' ';
            if r_lp.hhong<>0 then
                b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_lep,r_lp.hhong,b_bt);
            end if;
            if r_lp.thue<>0 then
                b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_tk_cit,r_lp.thue,b_bt);
            end if;
        else
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_ma_tk,-r_lp.tien,b_bt,b_gchu); b_gchu:=' ';
            if r_lp.hhong<>0 then
                b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_tk_lep,-r_lp.hhong,b_bt);
            end if;
            if r_lp.thue<>0 then
                b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_cit,-r_lp.thue,b_bt);
            end if;
        end if;
    else
        b_co:=b_co-r_lp.tien+r_lp.hhong-r_lp.thue;
        if r_lp.tien>0 then
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_ma_tk,r_lp.tien,b_bt,b_gchu); b_gchu:=' ';
            if r_lp.hhong<>0 then
                b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_tk_flp,r_lp.hhong,b_bt);
            end if;
            if r_lp.thue<>0 then
                b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_cit,r_lp.thue,b_bt);
            end if;
        else
            b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_ma_tk,-r_lp.tien,b_bt,b_gchu); b_gchu:=' ';
            if r_lp.hhong<>0 then
                b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_flp,-r_lp.hhong,b_bt);
            end if;
            if r_lp.thue<>0 then
                b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_tk_cit,-r_lp.thue,b_bt);
            end if;
        end if;
    end if;
end loop;
if b_co<0 then
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_tk_cn,-b_co,b_bt);
else
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_tk_cn,b_co,b_bt);
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_TA_DC:loi'; end if;
end;
/
create or replace procedure PBH_KT_HTOAN_TA_TT(
    b_ma_dvi varchar2,b_so_id_tt number,b_loi out varchar2)
AS
    b_i1 number; b_ngay_ht number; b_gchu nvarchar2(200);
    b_bt number:=0; b_tien number; b_chenh number;
    b_nhang varchar2(500); b_tk_nha varchar2(20);
    b_ma_tk varchar2(20); b_tk_no varchar2(20); b_tk_co varchar2(20);
    r_hd tbh_tt%rowtype;
begin
-- Dan - Thanh toan tai
select * into r_hd from tbh_tt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
b_chenh:=r_hd.ttoan_qd-r_hd.tra_qd; b_ngay_ht:=r_hd.ngay_ht;
b_tk_nha:=nvl(trim(FTBH_TT_TXT(b_ma_dvi,b_so_id_tt,'ma_tk')),' ');
b_nhang:=nvl(trim(FTBH_TT_TXT(b_ma_dvi,b_so_id_tt,'nhang')),' ');
b_tk_no:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'K','CN_KH_BH');
b_tk_co:=FBH_KT_TK_TRAt(b_ma_dvi,b_ngay_ht,r_hd.nt_tt,b_tk_nha);
if r_hd.ttoan_qd>0 then
    b_gchu:=substr('Thanh toan tai'||' ('||r_hd.so_ct||'): '||FBH_DTAC_MA_TEN(r_hd.nha_bh),1,200);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_no,r_hd.ttoan_qd,b_bt,b_gchu);
else
    b_gchu:='N.te tra:'||r_hd.nt_tt;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_co,-r_hd.tra_qd,b_bt,b_gchu);
end if;
if b_chenh<0 then
    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'P',' ','C');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tk,-b_chenh,b_bt);
end if;
if r_hd.ttoan_qd>0 then
    b_gchu:='N.te tra:'||r_hd.nt_tt;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_tk_co,r_hd.tra_qd,b_bt,b_gchu);
else
    b_gchu:=substr('Thanh toan tai'||' ('||r_hd.so_ct||'): '||FBH_DTAC_MA_TEN(r_hd.nha_bh),1,200);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_tk_no,-r_hd.ttoan_qd,b_bt,b_gchu);
end if;
if b_chenh>0 then
    b_ma_tk:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','D',b_ngay_ht,'D',' ','C');
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tk,b_chenh,b_bt);
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_TA_TT:loi'; end if;
end;
/
-- Cong no
create or replace procedure PBH_KT_HTOAN_CN_KH(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ngay_ht number; b_gchu nvarchar2(200); b_bt number:=0;
    b_nhang varchar2(500); b_tk_nha varchar2(20);
    b_ma_tk varchar2(20); b_tk_tra varchar2(20);
    r_hd bh_kh_cn_tu%rowtype;
begin
-- Dan - Cong no khac khach hang
select * into r_hd from bh_kh_cn_tu where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_ngay_ht:=r_hd.ngay_ht;
b_tk_nha:=nvl(trim(FBH_KH_CN_TU_TXT(b_ma_dvi,b_so_id,'ma_tk')),' ');
b_nhang:=nvl(trim(FBH_KH_CN_TU_TXT(b_ma_dvi,b_so_id,'nhang')),' ');
b_tk_tra:=FBH_KT_TK_TRAt(b_ma_dvi,b_ngay_ht,r_hd.ma_nt,b_tk_nha);
b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'K','CN_KH_KH');
if r_hd.l_ct='C' then
    b_gchu:=substr('Cong no khac khach hang'||' ('||r_hd.so_ct||'): '||FBH_DTAC_MA_TEN(r_hd.ma_kh),1,200);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_ma_tk,r_hd.tien_qd,b_bt,b_gchu);
    b_gchu:='N.te tra:'||r_hd.ma_nt;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_tk_tra,r_hd.tien_qd,b_bt,b_gchu);
else
    b_gchu:='N.te tra:'||r_hd.ma_nt;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_tra,r_hd.tien_qd,b_bt,b_gchu);
    b_gchu:=substr('Cong no khac khach hang'||' ('||r_hd.so_ct||'): '||FBH_DTAC_MA_TEN(r_hd.ma_kh),1,200);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_ma_tk,r_hd.tien_qd,b_bt,b_gchu);
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_BT_THOIt:loi'; end if;
end;
/
create or replace procedure PBH_KT_HTOAN_CN_DL(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ngay_ht number; b_gchu nvarchar2(200); b_bt number:=0;
    b_nhang varchar2(500); b_tk_nha varchar2(20);
    b_ma_tk varchar2(20); b_tk_tra varchar2(20);
    r_hd bh_dl_cn_tu%rowtype;
begin
-- Dan - Cong no khac nha bao hiem
select * into r_hd from bh_dl_cn_tu where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_ngay_ht:=r_hd.ngay_ht;
b_tk_nha:=nvl(trim(FBH_DL_CN_TU_TXT(b_ma_dvi,b_so_id,'ma_tk')),' ');
b_nhang:=nvl(trim(FBH_DL_CN_TU_TXT(b_ma_dvi,b_so_id,'nhang')),' ');
b_tk_tra:=FBH_KT_TK_TRAt(b_ma_dvi,b_ngay_ht,r_hd.ma_nt,b_tk_nha);
b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'K','CN_KH_DL');
if r_hd.l_ct='C' then
    b_gchu:=substr('Cong no khac dai ly'||' ('||r_hd.so_ct||'): '||FBH_DTAC_MA_TEN(r_hd.ma_kh),1,200);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_ma_tk,r_hd.tien_qd,b_bt,b_gchu);
    b_gchu:='N.te tra:'||r_hd.ma_nt;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_tk_tra,r_hd.tien_qd,b_bt,b_gchu);
else
    b_gchu:='N.te tra:'||r_hd.ma_nt;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_tra,r_hd.tien_qd,b_bt,b_gchu);
    b_gchu:=substr('Cong no khac dai ly'||' ('||r_hd.so_ct||'): '||FBH_DTAC_MA_TEN(r_hd.ma_kh),1,200);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_ma_tk,r_hd.tien_qd,b_bt,b_gchu);
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_CN_BH:loi'; end if;
end;
/
create or replace procedure PBH_KT_HTOAN_CN_BH(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ngay_ht number; b_gchu nvarchar2(200); b_bt number:=0;
    b_nhang varchar2(500); b_tk_nha varchar2(20);
    b_ma_tk varchar2(20); b_tk_tra varchar2(20);
    r_hd bh_hd_do_cn%rowtype;
begin
-- Dan - Cong no khac nha bao hiem
select * into r_hd from bh_hd_do_cn where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_ngay_ht:=r_hd.ngay_ht;
b_tk_nha:=nvl(trim(FBH_DO_BH_CN_TXT(b_ma_dvi,b_so_id,'ma_tk')),' ');
b_nhang:=nvl(trim(FBH_DO_BH_CN_TXT(b_ma_dvi,b_so_id,'nhang')),' ');
b_tk_tra:=FBH_KT_TK_TRAt(b_ma_dvi,b_ngay_ht,r_hd.ma_nt,b_tk_nha);
b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'K','CN_KH_BH');
if r_hd.l_ct='C' then
    b_gchu:=substr('Cong no khac nha bao hiem'||' ('||r_hd.so_ct||'): '||FBH_DTAC_MA_TEN(r_hd.nha_bh),1,200);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_ma_tk,r_hd.tien_qd,b_bt,b_gchu);
    b_gchu:='N.te tra:'||r_hd.ma_nt;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_tk_tra,r_hd.tien_qd,b_bt,b_gchu);
else
    b_gchu:='N.te tra:'||r_hd.ma_nt;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_tra,r_hd.tien_qd,b_bt,b_gchu);
    b_gchu:=substr('Cong no khac nha bao hiem'||' ('||r_hd.so_ct||'): '||FBH_DTAC_MA_TEN(r_hd.nha_bh),1,200);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_ma_tk,r_hd.tien_qd,b_bt,b_gchu);
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_CN_BH:loi'; end if;
end;
/
create or replace procedure PBH_KT_HTOAN_CN_TPA(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ngay_ht number; b_gchu nvarchar2(200); b_bt number:=0;
    b_nhang varchar2(500); b_tk_nha varchar2(20);
    b_ma_tk varchar2(20); b_tk_tra varchar2(20);
    r_hd bh_tpa_cn%rowtype;
begin
-- Dan - Cong no khac nha bao hiem
select * into r_hd from bh_tpa_cn where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_ngay_ht:=r_hd.ngay_ht;
b_tk_nha:=nvl(trim(FBH_TPA_CN_TXT(b_ma_dvi,b_so_id,'ma_tk')),' ');
b_nhang:=nvl(trim(FBH_TPA_CN_TXT(b_ma_dvi,b_so_id,'nhang')),' ');
b_tk_tra:=FBH_KT_TK_TRAt(b_ma_dvi,b_ngay_ht,r_hd.ma_nt,b_tk_nha);
b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'K','CN_KH_TPA');
if r_hd.l_ct='C' then
    b_gchu:=substr('Cong no TPA'||' ('||r_hd.so_ct||'): '||FBH_DTAC_MA_TEN(r_hd.tpa),1,200);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_ma_tk,r_hd.tien_qd,b_bt,b_gchu);
    b_gchu:='N.te tra:'||r_hd.ma_nt;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_tk_tra,r_hd.tien_qd,b_bt,b_gchu);
else
    b_gchu:='N.te tra:'||r_hd.ma_nt;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_tra,r_hd.tien_qd,b_bt,b_gchu);
    b_gchu:=substr('Cong no TPA'||' ('||r_hd.so_ct||'): '||FBH_DTAC_MA_TEN(r_hd.tpa),1,200);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_ma_tk,r_hd.tien_qd,b_bt,b_gchu);
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_CN_TPA:loi'; end if;
end;
/
-- Thu, chi khac
create or replace procedure PBH_KT_HTOAN_KH_HD(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ngay_ht number; b_gchu nvarchar2(200); b_bt number:=0;
    b_nhang varchar2(500); b_tk_nha varchar2(20);
    b_ma_tk varchar2(20); b_ma_tkV varchar2(20); b_tk_tra varchar2(20);
    r_hd bh_cp%rowtype;
begin
-- Dan - Thu, chi khac ve hop dong
select * into r_hd from bh_cp where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_ngay_ht:=r_hd.ngay_ht;
b_tk_nha:=nvl(trim(FTBH_CP_TXT(b_ma_dvi,b_so_id,'ma_tk')),' ');
b_nhang:=nvl(trim(FTBH_CP_TXT(b_ma_dvi,b_so_id,'nhang')),' ');
b_tk_tra:=FBH_KT_TK_TRAt(b_ma_dvi,b_ngay_ht,r_hd.ma_nt,b_tk_nha);
PBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','KH_TA_CP',b_ma_tk,b_ma_tkV);
if r_hd.l_ct='C' then
    b_gchu:=substr('Thu, chi khac hop dong'||' ('||r_hd.so_ct||'): '||r_hd.so_hd||' - '||r_hd.ten,1,200);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_ma_tk,r_hd.tien_qd,b_bt,b_gchu);
    if r_hd.thue_qd<>0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tkV,r_hd.thue_qd,b_bt);
    end if;
    b_gchu:='N.te tra:'||r_hd.ma_nt;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_tk_tra,r_hd.ttoan_qd,b_bt,b_gchu);
else
    b_gchu:='N.te tra:'||r_hd.ma_nt;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_tra,r_hd.ttoan_qd,b_bt,b_gchu);
    b_gchu:=substr('Thu, chi khac hop dong'||' ('||r_hd.so_ct||'): '||r_hd.so_hd||' - '||r_hd.ten,1,200);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_ma_tk,r_hd.tien_qd,b_bt,b_gchu);
    if r_hd.thue_qd<>0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tkV,r_hd.thue_qd,b_bt);
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_KH_HD:loi'; end if;
end;
/
create or replace procedure PBH_KT_HTOAN_KH_TA(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ngay_ht number; b_gchu nvarchar2(200); b_bt number:=0;
    b_nhang varchar2(500); b_tk_nha varchar2(20);
    b_ma_tk varchar2(20); b_ma_tkV varchar2(20); b_tk_tra varchar2(20);
    r_hd tbh_cp%rowtype;
begin
-- Dan - Thu, chi khac ve tai
select * into r_hd from tbh_cp where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_ngay_ht:=r_hd.ngay_ht;
b_tk_nha:=nvl(trim(FTBH_CP_TXT(b_ma_dvi,b_so_id,'ma_tk')),' ');
b_nhang:=nvl(trim(FTBH_CP_TXT(b_ma_dvi,b_so_id,'nhang')),' ');
b_tk_tra:=FBH_KT_TK_TRAt(b_ma_dvi,b_ngay_ht,r_hd.ma_nt,b_tk_nha);
PBH_KT_TK_TRA(b_ma_dvi,b_ngay_ht,'T','KH_TA_CP',b_ma_tk,b_ma_tkV);
if r_hd.l_ct='C' then
    b_gchu:=substr('Thu, chi khac ve tai'||' ('||r_hd.so_ct||'): '||FBH_DTAC_MA_TEN(r_hd.nha_bh),1,200);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_ma_tk,r_hd.tien_qd,b_bt,b_gchu);
    if r_hd.thue_qd<>0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('N',b_ma_tkV,r_hd.thue_qd,b_bt);
    end if;
    b_gchu:='N.te tra:'||r_hd.ma_nt;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_tk_tra,r_hd.ttoan_qd,b_bt,b_gchu);
else
    b_gchu:='N.te tra:'||r_hd.ma_nt;
    if b_tk_nha<>' ' then b_gchu:=b_gchu||', Ngan hang:'||b_nhang||', Tai khoan:'||b_tk_nha; end if;
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('N',b_tk_tra,r_hd.ttoan_qd,b_bt,b_gchu);
    b_gchu:=substr('Thu, chi khac ve tai'||' ('||r_hd.so_ct||'): '||FBH_DTAC_MA_TEN(r_hd.nha_bh),1,200);
    b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10,c4) values('C',b_ma_tk,r_hd.tien_qd,b_bt,b_gchu);
    if r_hd.thue_qd<>0 then
        b_bt:=b_bt+1; insert into ket_qua(c1,c2,n1,n10) values('C',b_ma_tkV,r_hd.thue_qd,b_bt);
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KT_HTOAN_KH_TA:loi'; end if;
end;
/
create or replace procedure PBH_KT_LKE_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number,b_klk varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_klk ='T' then
    select count(*) into b_dong from bh_kt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select so_id,l_ct,so_ct,row_number() over (order by l_ct,so_id) sott
        from bh_kt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by l_ct,so_id) where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_kt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd);
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select so_id,l_ct,so_ct,row_number() over (order by l_ct,so_id) sott
        from bh_kt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd) order by l_ct,so_id) where sott between b_tu and b_den;
end if;
end;
/
create or replace procedure PBH_KT_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,b_ngay_ht number,b_klk varchar2,
    b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number; b_den number;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_klk ='T' then
    select count(*) into b_dong from bh_kt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    select nvl(min(sott),b_dong) into b_tu from (select l_ct,so_id,row_number() over (order by l_ct,so_id) sott
        from bh_kt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by l_ct,so_id) where so_id=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    open cs_lke for select * from (select so_id,l_ct,so_ct,row_number() over (order by l_ct,so_id) sott
        from bh_kt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by l_ct,so_id) where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_kt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd);
    select nvl(min(sott),b_dong) into b_tu from (select l_ct,so_id,row_number() over (order by l_ct,so_id) sott
        from bh_kt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd) order by l_ct,so_id) where so_id=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    open cs_lke for select * from (select so_id,l_ct,so_ct,row_number() over (order by l_ct,so_id) sott
        from bh_kt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd) order by l_ct,so_id) where sott between b_tu and b_den;
end if;
end;
/
create or replace procedure PBH_KT_CT
    (b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,cs_bh out pht_type.cs_type,
    cs_kt out pht_type.cs_type,cs_hd out pht_type.cs_type,cs_ht out pht_type.cs_type,b_dvi varchar2:='')
AS
    b_loi varchar2(100); b_i1 number; b_l_ct varchar2(5); b_ngay_ht number; b_tien_nb number:=0; b_ma_dvi varchar2(10);
begin
-- Dan - Liet ke hach toan nghiep vu bao hiem
delete temp_1; commit;
PBH_CT_XEM_KTRA(b_ma_dviN,b_nsd,b_pas,'KT','bh_kt',b_so_id,b_dvi,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_dvi is null then b_ma_dvi:=b_ma_dviN; else b_ma_dvi:=b_dvi; end if;
b_loi:='loi:Chung tu hach toan da xoa:loi';
select l_ct,ngay_ht into b_l_ct,b_ngay_ht from bh_kt where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_l_ct='HD_TT' then
    insert into temp_1(n1,n2,c1,c4,n3,c5,c2)
        select so_id_tt,ngay_ht,so_ct,nt_tra,tra,ma_kh,ten
        from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='HD_HU' then
    insert into temp_1(n1,n2,c1,c4,n3,c5,c2)
        select so_id,ngay_ht,so_hd,nt_tra,tra,ma_kh,ten
        from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='HH_DL' then
    insert into temp_1(n1,n2,c1,c4,n3,c5,c2)
        select so_id_hh,ngay_ht,so_ct,nt_tra,tra,ma_dl,ten
        from bh_hd_goc_hh where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='DV_TPA' then
    insert into temp_1(n1,n2,c1,c4,n3,c5,c2)
        select so_id_tr,ngay_ht,so_ct,nt_tra,tra,tpa,FBH_DTAC_MA_TEN(tpa)
        from bh_tpa_tra where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='BT_TU' then
    insert into temp_1(n1,n2,c1,c4,n3,c5,c2)
        select so_id,ngay_ht,so_hs,ma_nt,tien,ma_kh,ten
        from bh_bt_tu where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='BT_DU' then
    insert into temp_1(n1,n2,c1,c4,n3,c5)
        select a.so_id,a.ngay_qd,a.so_hs,a.nt_tien,sum(b.tien+b.thue),a.ma_kh from bh_bt_hs a,bh_bt_hs_nv b where
        a.ma_dvi=b_ma_dvi and a.so_id_kt=b_so_id and
        b.ma_dvi=b_ma_dvi and b.so_id=a.so_id group by a.so_id,a.ngay_qd,a.so_hs,a.nt_tien,a.ma_kh;
    update temp_1 set c2=FBH_DTAC_MA_TEN(c5);
elsif b_l_ct='BT_TT' then
    insert into temp_1(n1,n2,c1,c4,n3,c5,c2)
        select so_id_tt,ngay_ht,so_ct,nt_tra,tra,ma_kh,ten
        from bh_bt_tt where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='BT_HK' then
    insert into temp_1(n1,n2,c1,c4,n3,c5,c2)
        select so_id,ngay_ht,so_ct,nt_tra,tra,' ',ten
        from bh_bt_hk where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='BT_TBA' then
    insert into temp_1(n1,n2,c1,c4,n3,c5,c2)
        select so_id,ngay_ht,so_ct,nt_tra,tra,' ',ten
        from bh_bt_tba where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='BT_THOI' then
    insert into temp_1(n1,n2,c1,c4,n3,c5,c2)
        select so_id,ngay_ht,so_ct,ma_nt,ttoan,' ',ten
        from bh_bt_thoi where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='GD_DU' then
    insert into temp_1(n1,n2,c1,c4,n3,c5,c2)
        select so_id,ngay_ht,so_hs,ma_nt,tien,ma_gd,ten
        from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='GD_TU' then
    insert into temp_1(n1,n2,c1,c4,n3,c5,c2)
        select so_id,ngay_ht,so_ct,ma_nt,ttoan,ma_gd,FBH_DTAC_MA_TEN(ma_gd)
        from bh_bt_gd_hs_tu where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='GD_TT' then
    insert into temp_1(n1,n2,c1,c4,n3,c5,c2)
        select so_id_tt,ngay_ht,so_ct,nt_tra,tra,ma_gd,FBH_DTAC_MA_TEN(ma_gd)
        from bh_bt_gd_hs_tt where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='DO_TT' then
    insert into temp_1(n1,n2,c1,c4,n3,c5,c2)
        select so_id_tt,ngay_ht,so_ct,nt_tra,tra,nha_bh,FBH_DTAC_MA_TEN(nha_bh)
        from bh_hd_do_tt where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='TA_DC' then
    insert into temp_1(n1,n2,c1,c4,n3,c5,c2)
        select so_id_dc,ngay_ht,so_dc,nt_tra,tra,nha_bh,FBH_DTAC_MA_TEN(nha_bh)
        from tbh_dc where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='TA_TT' then
    insert into temp_1(n1,n2,c1,c4,n3,c5,c2)
        select so_id_tt,ngay_ht,so_ct,nt_tra,tra,nha_bh,FBH_DTAC_MA_TEN(nha_bh)
        from tbh_tt where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='CN_KH' then
    insert into temp_1(n1,n2,c1,c4,n3,c5,c2)
        select so_id,ngay_ht,so_ct,ma_nt,tien,ma_kh,FBH_DTAC_MA_TEN(ma_kh)
        from bh_kh_cn_tu where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='CN_DL' then
    insert into temp_1(n1,n2,c1,c4,n3,c5,c2)
        select so_id,ngay_ht,so_ct,ma_nt,tien,ma_kh,FBH_DTAC_MA_TEN(ma_kh)
        from bh_dl_cn_tu where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='CN_BH' then
    insert into temp_1(n1,n2,c1,c4,n3,c5,c2)
        select so_id,ngay_ht,so_ct,ma_nt,tien,nha_bh,FBH_DTAC_MA_TEN(nha_bh)
        from bh_hd_do_cn where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='KH_HD' then
    insert into temp_1(n1,n2,c1,c4,n3,c5,c2)
        select so_id,ngay_ht,so_ct,ma_nt,ttoan,' ',ten
        from bh_cp where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='KH_TA' then
    insert into temp_1(n1,n2,c1,c4,n3,c5,c2)
        select so_id,ngay_ht,so_ct,ma_nt,ttoan,nha_bh,FBH_DTAC_MA_TEN(nha_bh)
        from tbh_cp where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
end if;
open cs_bh for select a.*,b_tien_nb tien_nb from bh_kt a where ma_dvi=b_ma_dvi and so_id=b_so_id;
open cs_kt for select htoan,lk,so_ct,ngay_ct,nd from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
open cs_hd for select n1 so_id,n2 ngay,c1 so_hd,c2 ten,c3 pt,c4 ma_nt,n3 tien,'' tt from temp_1 order by n2,c1,c4;
open cs_ht for select * from kt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KT_TON(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_phong varchar2,b_l_ct varchar2,
    b_ngayd number,b_ngayc number,b_so_hd varchar2,b_ten nvarchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_i1 number; b_ngayd_d date:=PKH_SO_CDT(b_ngayd); b_ngayc_d date:=PKH_SO_CDT(b_ngayc);
    b_dvi_ta varchar2(10);
begin
-- Dan - Liet ke ton chua hach toan nghiep vu bao hiem
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_dvi_ta:=FTBH_DVI_TA();
if b_l_ct='HD_TT' then
    insert into temp_1(c10,n1,n2,c1,c4,n3,c5,c2)
        select phong,so_id_tt,ngay_ht,so_ct,nt_tra,tra,ma_kh,ten
        from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngayd and b_ngayc;
        update temp_1 set c3=(select min(pt) from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=n1);
elsif b_l_ct='HD_HU' then
    insert into temp_1(c10,n1,n2,c1,c4,n3,c5,c2)
        select phong,so_id,ngay_ht,so_hd,nt_tra,tra,ma_kh,ten
        from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngayd and b_ngayc;
        update temp_1 set c3=(select min(pt_tra) from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=n1);
elsif b_l_ct='HH_DL' then
    insert into temp_1(c10,n1,n2,c1,c4,n3,c5,c2)
        select phong,so_id_hh,ngay_ht,so_ct,nt_tra,tra,ma_dl,ten
        from bh_hd_goc_hh where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngayd and b_ngayc;
        update temp_1 set c3=(select min(pt_tra) from bh_hd_goc_hh where ma_dvi=b_ma_dvi and so_id_hh=n1);
elsif b_l_ct='DV_TPA' then
    insert into temp_1(c10,n1,n2,c1,c4,n3,c5,c2)
        select FHT_MA_NSD_PHONG(b_ma_dvi,nsd),so_id_tr,ngay_ht,so_ct,nt_tra,tra,tpa,FBH_DTAC_MA_TEN(tpa)
        from bh_tpa_tra where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngayd and b_ngayc;
        update temp_1 set c3=(select min(pt_tra) from bh_tpa_tra where ma_dvi=b_ma_dvi and so_id_tr=n1);
elsif b_l_ct='BT_TU' then
    insert into temp_1(c10,n1,n2,c1,c4,n3,c5,c2)
        select phong,so_id,ngay_ht,so_hs,ma_nt,tien,ma_kh,ten
        from bh_bt_tu where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngayd and b_ngayc;
        update temp_1 set c3=(select min(pt_tra) from bh_bt_tu where ma_dvi=b_ma_dvi and so_hs=n1);
elsif b_l_ct='BT_DU' then
    insert into temp_1(c10,n1,n2,c1,c4,n3,c5)
        select a.phong,a.so_id,a.ngay_qd,a.so_hs,a.nt_tien,sum(b.tien+b.thue),a.ma_kh
        from bh_bt_hs a,bh_bt_hs_nv b where a.ma_dvi=b_ma_dvi and a.so_id_kt=0 and a.ngay_ht between b_ngayd and b_ngayc and
        b.ma_dvi=b_ma_dvi and b.so_id=a.so_id group by a.phong,a.so_id,a.ngay_qd,a.so_hs,a.nt_tien,a.ma_kh;
    update temp_1 set c2=FBH_DTAC_MA_TEN(c5);
elsif b_l_ct='BT_TT' then
    insert into temp_1(c10,n1,n2,c1,c4,n3,c5,c2)
        select phong,so_id_tt,ngay_ht,so_ct,nt_tra,tra,ma_kh,ten
        from bh_bt_tt where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngayd and b_ngayc;
        update temp_1 set c3=(select min(pt_tra) from bh_bt_tt where ma_dvi=b_ma_dvi and so_id_tt=n1);
elsif b_l_ct='BT_HK' then
    insert into temp_1(c10,n1,n2,c1,c4,n3,c5,c2)
        select phong,so_id,ngay_ht,so_ct,nt_tra,tra,' ',ten
        from bh_bt_hk where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngayd and b_ngayc;
elsif b_l_ct='BT_TBA' then
    insert into temp_1(c10,n1,n2,c1,c4,n3,c5,c2)
        select phong,so_id,ngay_ht,so_ct,nt_tra,tra,' ',ten
        from bh_bt_tba where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngayd and b_ngayc;
elsif b_l_ct='BT_THOI' then
    insert into temp_1(c10,n1,n2,c1,c4,n3,c5,c2)
        select phong,so_id,ngay_ht,so_ct,ma_nt,ttoan,' ',ten
        from bh_bt_thoi where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngayd and b_ngayc;
elsif b_l_ct='GD_DU' then
    insert into temp_1(c10,n1,n2,c1,c4,n3,c5,c2)
        select phong,so_id,ngay_ht,so_hs,ma_nt,tien,ma_gd,ten
        from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngayd and b_ngayc;
elsif b_l_ct='GD_TU' then
    insert into temp_1(c10,n1,n2,c1,c4,n3,c5,c2)
        select phong,so_id,ngay_ht,so_ct,ma_nt,ttoan,ma_gd,FBH_DTAC_MA_TEN(ma_gd)
        from bh_bt_gd_hs_tu where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngayd and b_ngayc;
elsif b_l_ct='GD_TT' then
    insert into temp_1(c10,n1,n2,c1,c4,n3,c5,c2)
        select phong,so_id_tt,ngay_ht,so_ct,nt_tra,tra,ma_gd,FBH_DTAC_MA_TEN(ma_gd)
        from bh_bt_gd_hs_tt where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngayd and b_ngayc;
elsif b_l_ct='DO_TT' then
    insert into temp_1(c10,n1,n2,c1,c4,n3,c5,c2)
        select phong,so_id_tt,ngay_ht,so_ct,nt_tra,tra,nha_bh,FBH_DTAC_MA_TEN(nha_bh)
        from bh_hd_do_tt where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngayd and b_ngayc;
        update temp_1 set c3=(select min(pt_tra) from bh_hd_do_tt where ma_dvi=b_ma_dvi and so_id_tt=n1);
elsif b_l_ct='TA_DC' then
    insert into temp_1(c10,n1,n2,c1,c4,n3,c5,c2)
        select FHT_MA_NSD_PHONG(b_ma_dvi,nsd),so_id_dc,ngay_ht,so_dc,nt_tra,tra,nha_bh,FBH_DTAC_MA_TEN(nha_bh)
        from tbh_dc where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngayd and b_ngayc;
elsif b_l_ct='TA_TT' then
    insert into temp_1(c10,n1,n2,c1,c4,n3,c5,c2)
        select FHT_MA_NSD_PHONG(b_ma_dvi,nsd),so_id_tt,ngay_ht,so_ct,nt_tra,tra,nha_bh,FBH_DTAC_MA_TEN(nha_bh)
        from tbh_tt where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngayd and b_ngayc;
elsif b_l_ct='CN_KH' then
    insert into temp_1(c10,n1,n2,c1,c4,n3,c5,c2,c3)
        select phong,so_id,ngay_ht,so_ct,ma_nt,tien,ma_kh,FBH_DTAC_MA_TEN(ma_kh),l_ct
        from bh_kh_cn_tu where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngayd and b_ngayc;
elsif b_l_ct='CN_DL' then
    insert into temp_1(c10,n1,n2,c1,c4,n3,c5,c2,c3)
        select phong,so_id,ngay_ht,so_ct,ma_nt,tien,ma_kh,FBH_DTAC_MA_TEN(ma_kh),l_ct
        from bh_dl_cn_tu where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngayd and b_ngayc;
elsif b_l_ct='CN_BH' then
    insert into temp_1(c10,n1,n2,c1,c4,n3,c5,c2,c3)
        select phong,so_id,ngay_ht,so_ct,ma_nt,tien,nha_bh,FBH_DTAC_MA_TEN(nha_bh),l_ct
        from bh_hd_do_cn where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngayd and b_ngayc;
elsif b_l_ct='KH_HD' then
    insert into temp_1(c10,n1,n2,c1,c4,n3,c5,c2,c3)
        select phong,so_id,ngay_ht,so_ct,ma_nt,ttoan,' ',ten,l_ct
        from bh_cp where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngayd and b_ngayc;
elsif b_l_ct='KH_TA' then
    insert into temp_1(c10,n1,n2,c1,c4,n3,c5,c2,c3)
        select FHT_MA_NSD_PHONG(b_ma_dvi,nsd),so_id,ngay_ht,so_ct,ma_nt,ttoan,nha_bh,FBH_DTAC_MA_TEN(nha_bh),l_ct
        from tbh_cp where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngayd and b_ngayc;
end if;
if b_phong is not null then delete temp_1 where c10<>b_phong; end if;
if b_ten is not null then delete temp_1 where c2 is null or upper(c2) not like b_ten; end if;
if b_so_hd is not null then delete temp_1 where c1 is null or upper(c1) not like b_so_hd; end if;
open cs1 for select n1 so_id,n2 ngay,c1 so_hd,c2 ten,c5 nha_bh,c3 pt,c4 ma_nt,n3 tien from temp_1 order by n2,n1,c1,c4;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PBH_KT_HTOAN(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_l_ct varchar2,b_ngay_ht number,
    b_nha varchar2,b_tk_nha varchar2,a_so_id pht_type.a_num,a_so_hd pht_type.a_var,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke hach toan
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_l_ct is null or a_so_id.count=0 then b_loi:='loi:Nhap so lieu nghiep vu:loi'; raise PROGRAM_ERROR; end if;
FBH_KT_HTOAN(b_ma_dvi,b_l_ct,a_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs1 for select c1 nv,c2 ma_tk,c3 ma_tke,n1 tien,c4 note,0 bt from ket_qua order by n10;
exception when others then raise_application_error(-20105,b_loi);
end;
/
create or replace procedure PBH_KT_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_l_ct varchar2,b_so_id number,b_ngay_ht number,
    b_so_ct varchar2,b_nha varchar2,b_tk_nha varchar2,a_so_id pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_ngayg number; b_ngayc number; b_ma_tk varchar2(20); b_ttrang varchar2(1);
    b_nv varchar2(1); a_ma_tk pht_type.a_var; a_ma_tke pht_type.a_var; a_tien pht_type.a_num;
begin
-- Dan - Nhap hach toan nghiep vu bao hiem
b_ngayc:=trunc(b_ngay_ht,-2);
if b_l_ct='HD_TT' then
    for b_lp in 1..a_so_id.count loop
        select so_id_kt,ngay_ht into b_i1,b_ngayg from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp);
        if b_i1<>0 then b_loi:='loi:Da hach toan chung tu dong '||to_char(b_lp)||':loi'; return; end if;
        if b_ngayg not between b_ngayc and b_ngay_ht then b_loi:='loi:Sai ngay hach toan dong '||to_char(b_lp)||':loi'; return; end if;
        update bh_hd_goc_ttps set so_id_kt=b_so_id where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp);
    end loop;
elsif b_l_ct='HD_HU' then
    for b_lp in 1..a_so_id.count loop
        select so_id_kt,ngay_ht into b_i1,b_ngayg from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
        if b_i1<>0 then b_loi:='loi:Da hach toan chung tu dong '||to_char(b_lp)||':loi'; return; end if;
        if b_ngayg not between b_ngayc and b_ngay_ht then b_loi:='loi:Sai ngay hach toan dong '||to_char(b_lp)||':loi'; return; end if;
        update bh_hd_goc_hu set so_id_kt=b_so_id where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
    end loop;
elsif b_l_ct='HH_DL' then
    for b_lp in 1..a_so_id.count loop
        select so_id_kt,ngay_ht into b_i1,b_ngayg from bh_hd_goc_hh where ma_dvi=b_ma_dvi and so_id_hh=a_so_id(b_lp);
        if b_i1<>0 then b_loi:='loi:Da hach toan chung tu dong '||to_char(b_lp)||':loi'; return; end if;
        if b_ngayg not between b_ngayc and b_ngay_ht then b_loi:='loi:Sai ngay hach toan dong '||to_char(b_lp)||':loi'; return; end if;
        update bh_hd_goc_hh set so_id_kt=b_so_id where ma_dvi=b_ma_dvi and so_id_hh=a_so_id(b_lp);
    end loop;
elsif b_l_ct='DV_TPA' then
    for b_lp in 1..a_so_id.count loop
        select so_id_kt,ngay_ht into b_i1,b_ngayg from bh_tpa_tra where ma_dvi=b_ma_dvi and so_id_tr=a_so_id(b_lp);
        if b_i1<>0 then b_loi:='loi:Da hach toan chung tu dong '||to_char(b_lp)||':loi'; return; end if;
        if b_ngayg not between b_ngayc and b_ngay_ht then b_loi:='loi:Sai ngay hach toan dong '||to_char(b_lp)||':loi'; return; end if;
        update bh_tpa_tra set so_id_kt=b_so_id where ma_dvi=b_ma_dvi and so_id_tr=a_so_id(b_lp);
    end loop;
elsif b_l_ct='BT_TU' then
    for b_lp in 1..a_so_id.count loop
        select so_id_kt,ngay_ht into b_i1,b_ngayg from bh_bt_tu where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
        if b_i1<>0 then b_loi:='loi:Da hach toan chung tu dong '||to_char(b_lp)||':loi'; return; end if;
        if b_ngayg not between b_ngayc and b_ngay_ht then b_loi:='loi:Sai ngay hach toan dong '||to_char(b_lp)||':loi'; return; end if;
        update bh_bt_tu set so_id_kt=b_so_id where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
    end loop;
elsif b_l_ct='BT_DU' then
    for b_lp in 1..a_so_id.count loop
        select so_id_kt,ngay_qd into b_i1,b_ngayg from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
        if b_i1<>0 then b_loi:='loi:Da hach toan chung tu dong '||to_char(b_lp)||':loi'; return; end if;
        if b_ngayg not between b_ngayc and b_ngay_ht then b_loi:='loi:Sai ngay hach toan dong '||to_char(b_lp)||':loi'; return; end if;
        update bh_bt_hs set so_id_kt=b_so_id where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
    end loop;
elsif b_l_ct='BT_TT' then
    for b_lp in 1..a_so_id.count loop
        select so_id_kt,ngay_ht into b_i1,b_ngayg from bh_bt_tt where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp);
        if b_i1<>0 then b_loi:='loi:Da hach toan chung tu dong '||to_char(b_lp)||':loi'; return; end if;
        if b_ngayg not between b_ngayc and b_ngay_ht then b_loi:='loi:Sai ngay hach toan dong '||to_char(b_lp)||':loi'; return; end if;
        update bh_bt_tt set so_id_kt=b_so_id where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp);
    end loop;
elsif b_l_ct='BT_HK' then
    for b_lp in 1..a_so_id.count loop
        select so_id_kt,ngay_ht into b_i1,b_ngayg from bh_bt_hk where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
        if b_i1<>0 then b_loi:='loi:Da hach toan chung tu dong '||to_char(b_lp)||':loi'; return; end if;
        if b_ngayg not between b_ngayc and b_ngay_ht then b_loi:='loi:Sai ngay hach toan dong '||to_char(b_lp)||':loi'; return; end if;
        update bh_bt_hk set so_id_kt=b_so_id where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
    end loop;
elsif b_l_ct='BT_TBA' then
    for b_lp in 1..a_so_id.count loop
        select so_id_kt,ngay_ht into b_i1,b_ngayg from bh_bt_tba where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
        if b_i1<>0 then b_loi:='loi:Da hach toan chung tu dong '||to_char(b_lp)||':loi'; return; end if;
        if b_ngayg not between b_ngayc and b_ngay_ht then b_loi:='loi:Sai ngay hach toan dong '||to_char(b_lp)||':loi'; return; end if;
        update bh_bt_tba set so_id_kt=b_so_id where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
    end loop;
elsif b_l_ct='BT_THOI' then
    for b_lp in 1..a_so_id.count loop
        select so_id_kt,ngay_ht into b_i1,b_ngayg from bh_bt_thoi where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
        if b_i1<>0 then b_loi:='loi:Da hach toan chung tu dong '||to_char(b_lp)||':loi'; return; end if;
        if b_ngayg not between b_ngayc and b_ngay_ht then b_loi:='loi:Sai ngay hach toan dong '||to_char(b_lp)||':loi'; return; end if;
        update bh_bt_thoi set so_id_kt=b_so_id where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
    end loop;
elsif b_l_ct='GD_DU' then
    for b_lp in 1..a_so_id.count loop
        select so_id_kt,ngay_ht into b_i1,b_ngayg from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
        if b_i1<>0 then b_loi:='loi:Da hach toan chung tu dong '||to_char(b_lp)||':loi'; return; end if;
        if b_ngayg not between b_ngayc and b_ngay_ht then b_loi:='loi:Sai ngay hach toan dong '||to_char(b_lp)||':loi'; return; end if;
        update bh_bt_gd_hs set so_id_kt=b_so_id where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
    end loop;
elsif b_l_ct='GD_TU' then
    for b_lp in 1..a_so_id.count loop
        select so_id_kt,ngay_ht into b_i1,b_ngayg from bh_bt_gd_hs_tu where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
        if b_i1<>0 then b_loi:='loi:Da hach toan chung tu dong '||to_char(b_lp)||':loi'; return; end if;
        if b_ngayg not between b_ngayc and b_ngay_ht then b_loi:='loi:Sai ngay hach toan dong '||to_char(b_lp)||':loi'; return; end if;
        update bh_bt_gd_hs_tu set so_id_kt=b_so_id where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
    end loop;
elsif b_l_ct='GD_TT' then
    for b_lp in 1..a_so_id.count loop
        select so_id_kt,ngay_ht into b_i1,b_ngayg from bh_bt_gd_hs_tt where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp);
        if b_i1<>0 then b_loi:='loi:Da hach toan chung tu dong '||to_char(b_lp)||':loi'; return; end if;
        if b_ngayg not between b_ngayc and b_ngay_ht then b_loi:='loi:Sai ngay hach toan dong '||to_char(b_lp)||':loi'; return; end if;
        update bh_bt_gd_tt set so_id_kt=b_so_id where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp);
    end loop;
elsif b_l_ct='DO_TT' then
    for b_lp in 1..a_so_id.count loop
        select so_id_kt,ngay_ht into b_i1,b_ngayg from bh_hd_do_tt where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp);
        if b_i1<>0 then b_loi:='loi:Da hach toan chung tu dong '||to_char(b_lp)||':loi'; return; end if;
        if b_ngayg not between b_ngayc and b_ngay_ht then b_loi:='loi:Sai ngay hach toan dong '||to_char(b_lp)||':loi'; return; end if;
        update bh_hd_do_tt set so_id_kt=b_so_id where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp);
    end loop;
elsif b_l_ct='TA_DC' then
    for b_lp in 1..a_so_id.count loop
        select so_id_kt,ngay_ht,ng_dc into b_i1,b_ngayg,b_i2 from tbh_dc where ma_dvi=b_ma_dvi and so_id_dc=a_so_id(b_lp);
        if b_i1<>0 then b_loi:='loi:Da hach toan chung tu dong '||to_char(b_lp)||':loi'; return; end if;
        if b_ngayg not between b_ngayc and b_ngay_ht then b_loi:='loi:Sai ngay hach toan dong '||to_char(b_lp)||':loi'; return; end if;
        if b_i2>30000000 then b_loi:='loi:Chua xac nhan doi chieu dong '||to_char(b_lp)||':loi'; return; end if;
        update tbh_dc set so_id_kt=b_so_id where ma_dvi=b_ma_dvi and so_id_dc=a_so_id(b_lp);
    end loop;
elsif b_l_ct='TA_TT' then
    for b_lp in 1..a_so_id.count loop
        select so_id_kt,ngay_ht into b_i1,b_ngayg from tbh_tt where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp);
        if b_i1<>0 then b_loi:='loi:Da hach toan chung tu dong '||to_char(b_lp)||':loi'; return; end if;
        if b_ngayg not between b_ngayc and b_ngay_ht then b_loi:='loi:Sai ngay hach toan dong '||to_char(b_lp)||':loi'; return; end if;
        update tbh_tt set so_id_kt=b_so_id where ma_dvi=b_ma_dvi and so_id_tt=a_so_id(b_lp);
    end loop;
elsif b_l_ct='KH_CN' then
    for b_lp in 1..a_so_id.count loop
        select so_id_kt,ngay_ht into b_i1,b_ngayg from bh_kh_cn_tu where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
        if b_i1<>0 then b_loi:='loi:Da hach toan chung tu dong '||to_char(b_lp)||':loi'; return; end if;
        if b_ngayg not between b_ngayc and b_ngay_ht then b_loi:='loi:Sai ngay hach toan dong '||to_char(b_lp)||':loi'; return; end if;
        update bh_kh_cn_tu set so_id_kt=b_so_id where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
    end loop;
elsif b_l_ct='CN_DL' then
    for b_lp in 1..a_so_id.count loop
        select so_id_kt,ngay_ht into b_i1,b_ngayg from bh_dl_cn_tu where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
        if b_i1<>0 then b_loi:='loi:Da hach toan chung tu dong '||to_char(b_lp)||':loi'; return; end if;
        if b_ngayg not between b_ngayc and b_ngay_ht then b_loi:='loi:Sai ngay hach toan dong '||to_char(b_lp)||':loi'; return; end if;
        update bh_dl_cn_tu set so_id_kt=b_so_id where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
    end loop;
elsif b_l_ct='CN_BH' then
    for b_lp in 1..a_so_id.count loop
        select so_id_kt,ngay_ht into b_i1,b_ngayg from bh_hd_do_cn where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
        if b_i1<>0 then b_loi:='loi:Da hach toan chung tu dong '||to_char(b_lp)||':loi'; return; end if;
        if b_ngayg not between b_ngayc and b_ngay_ht then b_loi:='loi:Sai ngay hach toan dong '||to_char(b_lp)||':loi'; return; end if;
        update bh_hd_do_cn set so_id_kt=b_so_id where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
    end loop;
elsif b_l_ct='KH_HD' then
    for b_lp in 1..a_so_id.count loop
        select so_id_kt,ngay_ht into b_i1,b_ngayg from bh_cp where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
        if b_i1<>0 then b_loi:='loi:Da hach toan chung tu dong '||to_char(b_lp)||':loi'; return; end if;
        if b_ngayg not between b_ngayc and b_ngay_ht then b_loi:='loi:Sai ngay hach toan dong '||to_char(b_lp)||':loi'; return; end if;
        update bh_cp set so_id_kt=b_so_id where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
    end loop;
elsif b_l_ct='KH_TA' then
    for b_lp in 1..a_so_id.count loop
        select so_id_kt,ngay_ht into b_i1,b_ngayg from tbh_cp where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
        if b_i1<>0 then b_loi:='loi:Da hach toan chung tu dong '||to_char(b_lp)||':loi'; return; end if;
        if b_ngayg not between b_ngayc and b_ngay_ht then b_loi:='loi:Sai ngay hach toan dong '||to_char(b_lp)||':loi'; return; end if;
        update tbh_cp set so_id_kt=b_so_id where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
    end loop;
end if;
b_loi:='loi:Loi Table BH_KT:loi';
insert into bh_kt values(b_ma_dvi,b_so_id,b_ngay_ht,b_l_ct,b_so_ct,b_nha,b_tk_nha,b_nsd);
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
create or replace procedure PBH_KT_XOA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_l_ct varchar2(5); b_nsd_c varchar2(10);
begin
-- Dan - Xoa hach toan nghiep vu bao hiem
select count(*) into b_i1 from bh_kt where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
b_loi:='loi:Chung tu dang xu ly:loi';
select l_ct,nsd into b_l_ct,b_nsd_c from bh_kt where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sql%rowcount=0 then return; end if;
if b_nsd_c<>b_nsd then b_loi:='loi:Khong sua,xoa chung tu nguoi khac:loi'; return; end if;
if b_l_ct='HD_TT' then
    update bh_hd_goc_ttps set so_id_kt=0 where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='HD_HU' then
    update bh_hd_goc_hu set so_id_kt=0 where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='HH_DL' then
    update bh_hd_goc_hh set so_id_kt=0 where ma_dvi=b_ma_dvi  and so_id_kt=b_so_id;
elsif b_l_ct='DV_TPA' then
    update bh_tpa_tra set so_id_kt=0 where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='BT_TU' then
    update bh_bt_tu set so_id_kt=0 where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='BT_DU' then
    update bh_bt_hs set so_id_kt=0 where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='BT_TT' then
    update bh_bt_tt set so_id_kt=0 where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='BT_HK' then
    update bh_bt_hk set so_id_kt=0 where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='BT_TBA' then
    update bh_bt_tba set so_id_kt=0 where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='BT_THOI' then
    update bh_bt_thoi set so_id_kt=0 where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='GD_DU' then
    update bh_bt_gd_hs set so_id_kt=0 where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='GD_TU' then
    update bh_bt_gd_hs_tu set so_id_kt=0 where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='GD_TT' then
    update bh_bt_gd_hs_tt set so_id_kt=0 where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='DO_TT' then
    update bh_hd_do_tt set so_id_kt=0 where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='TA_DC' then
    update tbh_dc set so_id_kt=0 where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='TA_TT' then
    update tbh_tt set so_id_kt=0 where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='CN_KH' then
    update bh_kh_cn_tu set so_id_kt=0 where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='CN_DL' then
    update bh_dl_cn_tu set so_id_kt=0 where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='CN_BH' then
    update bh_hd_do_cn set so_id_kt=0 where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='KH_HD' then
    update bh_cp set so_id_kt=0 where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
elsif b_l_ct='KH_TA' then
    update tbh_cp set so_id_kt=0 where ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
end if;
delete bh_kt where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
create or replace procedure PBH_KT_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id in out number,
    b_l_ct varchar2,b_ngay_ht number,b_htoan varchar2,b_so_ctN varchar2,
    b_ngay_ct varchar2,b_nd nvarchar2,b_nha varchar2,b_tk_nha varchar2,
    a_so_id pht_type.a_num, a_nv in out pht_type.a_var,a_ma_tk pht_type.a_var,
    a_ma_tke pht_type.a_var,a_tien pht_type.a_num,a_note pht_type.a_nvar,a_bt pht_type.a_num,b_lk out varchar2)
AS
    b_so_id_c number; b_loi varchar2(100); b_so_tt number; b_kt_1 number;
    b_i1 number; b_i2 number; b_so_ct varchar2(30):=b_so_ctN;
begin
-- Dan - Nhap chung tu ke toan nghiep vu bao hiem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKH_MANG(a_nv);
b_so_id_c:=b_so_id; b_lk:='';
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
else
    select count(*) into b_kt_1 from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
    PBH_KT_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_KH_SO_KT(b_ma_dvi,b_l_ct,b_ngay_ht,b_so_tt,b_so_ct);
if trim(b_so_ctN) is not null then b_so_ct:=b_so_ctN; end if;
PBH_KT_NH_NH(b_ma_dvi,b_nsd,b_l_ct,b_so_id,b_ngay_ht,b_so_ct,b_nha,b_tk_nha,a_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id_c<>0 then
    if a_nv.count<>0 then
        if b_kt_1<>0 then
            PKT_KT_SUA(b_ma_dvi,b_nsd,'BH',b_htoan,b_ngay_ht,b_l_ct,b_so_tt,b_so_ct,b_ngay_ct,
                b_nd,' ',a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt,b_so_id,b_lk,b_loi);
        else
            PKT_KT_NH(b_ma_dvi,b_nsd,b_htoan,b_ngay_ht,b_l_ct,b_so_tt,b_so_ct,b_ngay_ct,b_nd,' ',
                a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt,b_so_id,'BH',b_lk,b_loi,'C');
        end if;
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    elsif b_kt_1<>0 then
        PKT_KT_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi,'BH');
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
elsif a_nv.count<>0 then
    PKT_KT_NH(b_ma_dvi,b_nsd,b_htoan,b_ngay_ht,b_l_ct,b_so_tt,b_so_ct,b_ngay_ct,b_nd,' ',
        a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt,b_so_id,'BH',b_lk,b_loi,'C');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number)
AS
    b_loi varchar2(100); b_kt_1 number; b_md varchar2(5); b_lk varchar2(100);
begin
-- Dan - Xoa chung tu hach toan nghiep vu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then b_loi:='loi:Nhap so ID chung tu:loi'; raise PROGRAM_ERROR; end if;
PBH_KT_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*),min(md) into b_kt_1,b_md from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_kt_1<>0 then
    if b_md='BH' then
        PKT_CT_NV_XOA(b_ma_dvi,b_nsd,b_so_id,b_md,'BH',b_lk,b_loi);
    else
        PKT_KT_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi,'BH');
    end if;
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE FBH_KT_HTOAN(
    b_ma_dvi varchar2,b_l_ct varchar2,a_so_id pht_type.a_num,b_loi out varchar2)
AS
begin
-- Dan - Liet ke hach toan
if b_l_ct='HD_TT' then
    for b_lp in 1..a_so_id.count loop
        PBH_KT_HTOAN_HD_TT(b_ma_dvi,a_so_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
elsif b_l_ct='HD_HU' then
    for b_lp in 1..a_so_id.count loop
        PBH_KT_HTOAN_HD_HU(b_ma_dvi,a_so_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
elsif b_l_ct='HH_DL' then
    for b_lp in 1..a_so_id.count loop
        PBH_KT_HTOAN_HH_DL(b_ma_dvi,a_so_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
elsif b_l_ct='DV_TPA' then
    for b_lp in 1..a_so_id.count loop
        PBH_KT_HTOAN_DV_TPA(b_ma_dvi,a_so_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
elsif b_l_ct='BT_DU' then
    for b_lp in 1..a_so_id.count loop
        PBH_KT_HTOAN_BT_DU(b_ma_dvi,a_so_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
elsif b_l_ct='BT_TU' then
    for b_lp in 1..a_so_id.count loop
        PBH_KT_HTOAN_BT_TU(b_ma_dvi,a_so_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
elsif b_l_ct='BT_TT' then
    for b_lp in 1..a_so_id.count loop
        PBH_KT_HTOAN_BT_TT(b_ma_dvi,a_so_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
elsif b_l_ct='BT_HK' then
    for b_lp in 1..a_so_id.count loop
        PBH_KT_HTOAN_BT_HK(b_ma_dvi,a_so_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
elsif b_l_ct='BT_TBA' then
    for b_lp in 1..a_so_id.count loop
        PBH_KT_HTOAN_BT_TBA(b_ma_dvi,a_so_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
elsif b_l_ct='BT_THOI' then
    for b_lp in 1..a_so_id.count loop
        PBH_KT_HTOAN_BT_THOI(b_ma_dvi,a_so_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
elsif b_l_ct='GD_DU' then
    for b_lp in 1..a_so_id.count loop
        PBH_KT_HTOAN_GD_DU(b_ma_dvi,a_so_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
elsif b_l_ct='GD_TU' then
    for b_lp in 1..a_so_id.count loop
        PBH_KT_HTOAN_GD_TU(b_ma_dvi,a_so_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
elsif b_l_ct='GD_TT' then
    for b_lp in 1..a_so_id.count loop
        PBH_KT_HTOAN_GD_TT(b_ma_dvi,a_so_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
elsif b_l_ct='DO_TT' then
    for b_lp in 1..a_so_id.count loop
        PBH_KT_HTOAN_DO_TT(b_ma_dvi,a_so_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
elsif b_l_ct='TA_DC' then
    for b_lp in 1..a_so_id.count loop
        PBH_KT_HTOAN_TA_DC(b_ma_dvi,a_so_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
elsif b_l_ct='TA_TT' then
    for b_lp in 1..a_so_id.count loop
        PBH_KT_HTOAN_TA_TT(b_ma_dvi,a_so_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
elsif b_l_ct='CN_KH' then
    for b_lp in 1..a_so_id.count loop
        PBH_KT_HTOAN_CN_KH(b_ma_dvi,a_so_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
elsif b_l_ct='CN_DL' then
    for b_lp in 1..a_so_id.count loop
        PBH_KT_HTOAN_CN_DL(b_ma_dvi,a_so_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
elsif b_l_ct='CN_BH' then
    for b_lp in 1..a_so_id.count loop
        PBH_KT_HTOAN_CN_BH(b_ma_dvi,a_so_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
elsif b_l_ct='CN_TPA' then
    for b_lp in 1..a_so_id.count loop
        PBH_KT_HTOAN_CN_TPA(b_ma_dvi,a_so_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
elsif b_l_ct='KH_TA' then
    for b_lp in 1..a_so_id.count loop
        PBH_KT_HTOAN_KH_TA(b_ma_dvi,a_so_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
elsif b_l_ct='KH_HD' then
    for b_lp in 1..a_so_id.count loop
        PBH_KT_HTOAN_KH_TA(b_ma_dvi,a_so_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
end if;
end;
/
create or replace PROCEDURE PBH_KT_HTOAN
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_l_ct varchar2,
    a_so_id pht_type.a_num,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke hach toan
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FBH_KT_HTOAN(b_ma_dvi,b_l_ct,a_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs1 for select c1 nv,c2 ma_tk,c3 ma_tke,n1 tien,c4 note,0 bt from ket_qua order by n10;
exception when others then raise_application_error(-20105,b_loi);
end;
/
create or replace PROCEDURE PBH_KT_DCHIEU
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngayd number,b_ngayc number,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_l_ct varchar2(10); b_so_id number;
    a_so_id pht_type.a_num; a_so_hd pht_type.a_var;
begin
-- Dan - Doi chieu hach toan tu dong
delete ket_qua; delete temp_1; delete temp_2; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
for r_lp in (select * from bh_kt where ma_dvi=b_ma_dvi and ngay_ht between b_ngayd and b_ngayc) loop
    delete ket_qua; delete temp_1;
    b_l_ct:=r_lp.l_ct; b_so_id:=r_lp.so_id;
    if b_l_ct='HD_TT' then
        select distinct so_id_tt bulk collect into a_so_id from bh_hd_goc_ttps where
            ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
    elsif b_l_ct='HD_HU' then
        select distinct so_id bulk collect into a_so_id from bh_hd_goc_hu where
            ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
    elsif b_l_ct='HH_DL' then
        select distinct so_id_hh bulk collect into a_so_id from bh_hd_goc_hh where
            ma_dvi=b_ma_dvi  and so_id_kt=b_so_id;
    elsif b_l_ct='DV_TPA' then
        select distinct so_id_tr bulk collect into a_so_id from bh_tpa_tra where
            ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
    elsif b_l_ct='BT_TU' then
        select distinct so_id bulk collect into a_so_id from bh_bt_tu where 
            ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
    elsif b_l_ct='BT_DU' then
        select distinct so_id bulk collect into a_so_id from bh_bt_hs where
            ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
    elsif b_l_ct='BT_TT' then
        select distinct  so_id_tt bulk collect into a_so_id from bh_bt_tt where
            ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
    elsif b_l_ct='BT_HK' then
        select distinct so_id bulk collect into a_so_id from bh_bt_hk where
            ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
    elsif b_l_ct='BT_TBA' then
        select distinct so_id bulk collect into a_so_id from bh_bt_tba where
            ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
    elsif b_l_ct='BT_THOI' then
        select distinct so_id bulk collect into a_so_id from bh_bt_thoi where
            ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
    elsif b_l_ct='GD_DU' then
        select distinct so_id bulk collect into a_so_id from bh_bt_gd_hs where
            ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
    elsif b_l_ct='GD_TU' then
        select distinct so_id bulk collect into a_so_id from bh_bt_gd_hs_tu where
            ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
    elsif b_l_ct='GD_TT' then
        select distinct  so_id_tt bulk collect into a_so_id from bh_bt_gd_hs_tt where
            ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
    elsif b_l_ct='DO_TT' then
        select distinct so_id_tt bulk collect into a_so_id from bh_hd_do_tt where
            ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
    elsif b_l_ct='TA_DC' then
        select distinct so_id_dc bulk collect into a_so_id from tbh_dc where
            ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
    elsif b_l_ct='TA_TT' then
        select distinct so_id_tt bulk collect into a_so_id from tbh_tt where
            ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
    elsif b_l_ct='CN_KH' then
        select distinct so_id bulk collect into a_so_id from bh_kh_cn_tu where
            ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
    elsif b_l_ct='CN_DL' then
        select distinct so_id bulk collect into a_so_id from bh_dl_cn_tu where
            ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
    elsif b_l_ct='CN_BH' then
        select distinct so_id bulk collect into a_so_id from bh_hd_do_cn where
            ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
    elsif b_l_ct='CN_TPA' then
        select distinct so_id bulk collect into a_so_id from bh_tpa_cn where
            ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
    elsif b_l_ct='KH_HD' then
        select distinct so_id bulk collect into a_so_id from bh_cp where
            ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
    elsif b_l_ct='KH_TA' then
        select distinct so_id bulk collect into a_so_id from tbh_cp where
            ma_dvi=b_ma_dvi and so_id_kt=b_so_id;
    end if;
    if b_l_ct is not null and a_so_id.count>0 then
        FBH_KT_HTOAN(b_ma_dvi,b_l_ct,a_so_id,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
    update ket_qua set c3=' ' where c3 is null;
    insert into ket_qua(c1,c2,c3,n1) (select nv,ma_tk,ma_tke,sum(-tien) from kt_2 where
        ma_dvi=b_ma_dvi and so_id=b_so_id group by nv,ma_tk,ma_tke);
    insert into temp_1(c1,c2,c3,n1) (select c1,c2,c3,sum(n1) from ket_qua group by c1,c2,c3 having sum(n1)<>0);
    insert into temp_2(c10,n10,c1,c2,c3,n1) select b_l_ct,b_so_id,c1,c2,c3,n1 from temp_1;
end loop;
open cs1 for select c10 l_ct,n10 so_id, c1 nv,c2 ma_tk,c3 ma_tke,n1 tien from temp_2 order by c10,n10;
exception when others then raise_application_error(-20105,b_loi);
end;
/
create or replace procedure PBH_KT_TON_NG(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay out number)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke ton chua hach toan nghiep vu bao hiem
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'HD_TT' from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_kt=0;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'HD_HU' from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id_kt=0;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'HH_DL' from bh_hd_goc_hh where ma_dvi=b_ma_dvi and so_id_kt=0;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'DV_TPA' from bh_tpa_tra where ma_dvi=b_ma_dvi and so_id_kt=0;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'BT_TU' from bh_bt_tu where ma_dvi=b_ma_dvi and so_id_kt=0;
insert into temp_1(n1,c1) select nvl(min(ngay_qd),0),'BT_DU' from bh_bt_hs where ma_dvi=b_ma_dvi and so_id_kt=0;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'BT_TT' from bh_bt_tt where ma_dvi=b_ma_dvi and so_id_kt=0;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'BT_HK' from bh_bt_hk where ma_dvi=b_ma_dvi and so_id_kt=0;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'BT_TBA' from bh_bt_tba where ma_dvi=b_ma_dvi and so_id_kt=0;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'BT_THOI' from bh_bt_thoi where ma_dvi=b_ma_dvi and so_id_kt=0;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'GD_DU' from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id_kt=0;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'GD_TU' from bh_bt_gd_hs_tu where ma_dvi=b_ma_dvi and so_id_kt=0;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'GD_TT' from bh_bt_gd_hs_tt where ma_dvi=b_ma_dvi and so_id_kt=0;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'DO_TT' from bh_hd_do_tt where ma_dvi=b_ma_dvi and so_id_kt=0;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'TA_DC' from tbh_dc where ma_dvi=b_ma_dvi and so_id_kt=0;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'TA_TT' from tbh_tt where ma_dvi=b_ma_dvi and so_id_kt=0;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'CN_KH' from bh_kh_cn_tu where ma_dvi=b_ma_dvi and so_id_kt=0;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'CN_DL' from bh_dl_cn_tu where ma_dvi=b_ma_dvi and so_id_kt=0;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'CN_BH' from bh_hd_do_cn where ma_dvi=b_ma_dvi and so_id_kt=0;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'CN_BH' from bh_tpa_cn where ma_dvi=b_ma_dvi and so_id_kt=0;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'KH_HD' from bh_cp where ma_dvi=b_ma_dvi and so_id_kt=0;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'KH_TA' from tbh_cp where ma_dvi=b_ma_dvi and so_id_kt=0;
select nvl(min(n1),0) into b_ngay from temp_1 where n1<>0;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KT_TON_NV(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngD number,b_ngC number,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_ngD_d date:=PKH_SO_CDT(b_ngD); b_ngC_d date:=PKH_SO_CDT(b_ngC);
begin
-- Dan - Liet ke ton chua hach toan nghiep vu bao hiem
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'HD_TT' from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngD and b_ngC;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'HD_HU' from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngD and b_ngC;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'HH_DL' from bh_hd_goc_hh where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngD and b_ngC;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'DV_TPA' from bh_tpa_tra where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngD and b_ngC;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'BT_TU' from bh_bt_tu where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngD and b_ngC;
insert into temp_1(n1,c1) select nvl(min(ngay_qd),0),'BT_DU' from bh_bt_hs where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_qd between b_ngD and b_ngC;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'BT_TT' from bh_bt_tt where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngD and b_ngC;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'BT_HK' from bh_bt_hk where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngD and b_ngC;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'BT_TBA' from bh_bt_tba where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngD and b_ngC;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'BT_THOI' from bh_bt_thoi where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngD and b_ngC;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'GD_DU' from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngD and b_ngC;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'GD_TU' from bh_bt_gd_hs_tu where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngD and b_ngC;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'GD_TT' from bh_bt_gd_hs_tt where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngD and b_ngC;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'DO_TT' from bh_hd_do_tt where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngD and b_ngC;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'TA_DC' from tbh_dc where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngD and b_ngC and ng_dc<30000101;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'TA_TT' from tbh_tt where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngD and b_ngC;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'CN_KH' from bh_kh_cn_tu where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngD and b_ngC;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'CN_DL' from bh_dl_cn_tu where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngD and b_ngC;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'CN_BH' from bh_hd_do_cn where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngD and b_ngC;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'CN_TPA' from bh_tpa_cn where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngD and b_ngC;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'KH_HD' from bh_cp where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngD and b_ngC;
insert into temp_1(n1,c1) select nvl(min(ngay_ht),0),'KH_TA' from tbh_cp where ma_dvi=b_ma_dvi and so_id_kt=0 and ngay_ht between b_ngD and b_ngC;
open cs1 for select c1 ma from temp_1 where n1<>0;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_KT_TONc(
    b_ma_dvi varchar2,b_l_ct varchar2,b_so_id number,a_so_id out pht_type.a_num,b_loi out varchar2)
AS
begin
-- Dan - Liet ke ton chua hach toan theo so_id phat sinh
if b_l_ct='HD_TT' then
    select so_id_tt bulk collect into a_so_id from bh_hd_goc_ttps where
        ma_dvi=b_ma_dvi and so_id_tt=b_so_id and so_id_kt=0;
elsif b_l_ct='HD_HU' then
    select so_id bulk collect into a_so_id from bh_hd_goc_hu where
        ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_kt=0;
elsif b_l_ct='HH_DL' then
    select so_id_hh bulk collect into a_so_id from bh_hd_goc_hh where
        ma_dvi=b_ma_dvi and so_id_hh=b_so_id and so_id_kt=0;
elsif b_l_ct='DV_TPA' then
    select so_id_tr bulk collect into a_so_id from bh_tpa_tra where
        ma_dvi=b_ma_dvi and so_id_tr=b_so_id and so_id_kt=0;
elsif b_l_ct='BT_TU' then
    select so_id bulk collect into a_so_id from bh_bt_tu where 
        ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_kt=0;
elsif b_l_ct='BT_DU' then
    select so_id bulk collect into a_so_id from bh_bt_hs where
        ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_kt=0;
elsif b_l_ct='BT_TT' then
    select distinct so_id_tt bulk collect into a_so_id from bh_bt_tt where
        ma_dvi=b_ma_dvi and so_id_tt=b_so_id and so_id_kt=0;
elsif b_l_ct='BT_HK' then
    select so_id bulk collect into a_so_id from bh_bt_hk where
        ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_kt=0;
elsif b_l_ct='BT_TBA' then
    select so_id bulk collect into a_so_id from bh_bt_tba where
        ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_kt=0;
elsif b_l_ct='BT_THOI' then
    select so_id bulk collect into a_so_id from bh_bt_thoi where
        ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_kt=0;
elsif b_l_ct='GD_DU' then
    select so_id bulk collect into a_so_id from bh_bt_gd_hs where
        ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_kt=0;
elsif b_l_ct='GD_TU' then
    select so_id bulk collect into a_so_id from bh_bt_gd_hs_tu where
        ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_kt=0;
elsif b_l_ct='GD_TT' then
    select distinct so_id_tt bulk collect into a_so_id from bh_bt_gd_hs_tt where
        ma_dvi=b_ma_dvi and so_id_tt=b_so_id and so_id_kt=0;
elsif b_l_ct='DO_TT' then
    select so_id_tt bulk collect into a_so_id from bh_hd_do_tt where
        ma_dvi=b_ma_dvi and so_id_tt=b_so_id and so_id_kt=0;
elsif b_l_ct='TA_DC' then
    select so_id_dc bulk collect into a_so_id from tbh_dc where
        ma_dvi=b_ma_dvi and so_id_dc=b_so_id and so_id_kt=0;
elsif b_l_ct='TA_TT' then
    select so_id_tt bulk collect into a_so_id from tbh_tt where
        ma_dvi=b_ma_dvi and so_id_tt=b_so_id and so_id_kt=0;
elsif b_l_ct='CN_KH' then
    select so_id bulk collect into a_so_id from bh_kh_cn_tu where
        ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_kt=0;
elsif b_l_ct='CN_DL' then
    select so_id bulk collect into a_so_id from bh_dl_cn_tu where
        ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_kt=0;
elsif b_l_ct='CN_BH' then
    select so_id bulk collect into a_so_id from bh_hd_do_cn where
        ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_kt=0;
elsif b_l_ct='CN_TPA' then
    select so_id bulk collect into a_so_id from bh_tpa_cn where
        ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_kt=0;
elsif b_l_ct='KH_HD' then
    select so_id bulk collect into a_so_id
        from bh_cp where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_kt=0;
elsif b_l_ct='KH_TA' then
    select so_id bulk collect into a_so_id
        from tbh_cp where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_kt=0;
end if;
delete temp_1;
b_loi:='';
exception when others then if b_loi is not null then b_loi:='b_loi:Loi xu ly FBH_KT_TONc:loi'; end if;
end;
/
create or replace procedure FBH_KT_TONl(
    a_ma_dvi out pht_type.a_var,a_l_ct out pht_type.a_var,a_so_id out pht_type.a_num,b_loi out varchar2)
AS
    b_d date; b_tso number:=5; -- 5p
begin
-- Dan - Liet ke ton chua hach toan theo so_id phat sinh
b_loi:='Loi xu ly FBH_KT_TONl';
delete temp_1; delete ket_qua;
b_d:=sysdate+b_tso/24/60;
insert into ket_qua(c1,c2,n1)
    select 'HD_TT',ma_dvi,so_id_tt from bh_hd_goc_ttps where so_id_kt=0 and ngay_nh<b_d;
insert into ket_qua(c1,c2,n1)
    select 'HD_HU',ma_dvi,so_id from bh_hd_goc_hu where so_id_kt=0 and ngay_nh<b_d;
insert into ket_qua(c1,c2,n1)
    select 'HH_DL',ma_dvi,so_id_hh from bh_hd_goc_hh where so_id_kt=0 and ngay_nh<b_d;
insert into ket_qua(c1,c2,n1)
    select 'DV_TPA',ma_dvi,so_id_tr from bh_tpa_tra where so_id_kt=0 and ngay_nh<b_d;
insert into ket_qua(c1,c2,n1)
    select 'BT_TU',ma_dvi,so_id from bh_bt_tu where so_id_kt=0 and ngay_nh<b_d;
insert into ket_qua(c1,c2,n1)
    select 'BT_DU',ma_dvi,so_id from bh_bt_hs where so_id_kt=0 and ngay_nh<b_d;
insert into ket_qua(c1,c2,n1)
    select 'BT_TT',ma_dvi,so_id_tt from bh_bt_tt where so_id_kt=0 and ngay_nh<b_d;
insert into ket_qua(c1,c2,n1)
    select 'BT_HK',ma_dvi,so_id from bh_bt_hk where so_id_kt=0 and ngay_nh<b_d;
insert into ket_qua(c1,c2,n1)
    select 'BT_TBA',ma_dvi,so_id from bh_bt_tba where so_id_kt=0 and ngay_nh<b_d;
insert into ket_qua(c1,c2,n1)
    select 'BT_THOI',ma_dvi,so_id from bh_bt_thoi where so_id_kt=0 and ngay_nh<b_d;
insert into ket_qua(c1,c2,n1)
    select 'GD_DU',ma_dvi,so_id from bh_bt_gd_hs where so_id_kt=0 and ngay_nh<b_d;
insert into ket_qua(c1,c2,n1)
    select 'GD_TU',ma_dvi,so_id from bh_bt_gd_hs_tu where so_id_kt=0 and ngay_nh<b_d;
insert into ket_qua(c1,c2,n1)
    select 'GD_TT',ma_dvi,so_id_tt from bh_bt_gd_hs_tt where so_id_kt=0 and ngay_nh<b_d;
insert into ket_qua(c1,c2,n1)
    select 'DO_TT',ma_dvi,so_id_tt from bh_hd_do_tt where so_id_kt=0 ;
insert into ket_qua(c1,c2,n1)
    select 'TA_DC',ma_dvi,so_id_dc from tbh_dc where so_id_kt=0 and ngay_nh<b_d;
insert into ket_qua(c1,c2,n1)
    select 'TA_TT',ma_dvi,so_id_tt from tbh_tt where so_id_kt=0 and ngay_nh<b_d;
insert into ket_qua(c1,c2,n1)
    select 'CN_KH',ma_dvi,so_id from bh_kh_cn_tu where so_id_kt=0 and ngay_nh<b_d;
insert into ket_qua(c1,c2,n1)
    select 'CN_DL',ma_dvi,so_id from bh_dl_cn_tu where so_id_kt=0 and ngay_nh<b_d;
insert into ket_qua(c1,c2,n1)
    select 'CN_BH',ma_dvi,so_id from bh_hd_do_cn where so_id_kt=0 and ngay_nh<b_d;
insert into ket_qua(c1,c2,n1)
    select 'CN_TPA',ma_dvi,so_id from bh_tpa_cn where so_id_kt=0 and ngay_nh<b_d;
insert into ket_qua(c1,c2,n1)
    select 'KH_HD',ma_dvi,so_id from bh_cp where so_id_kt=0 and ngay_nh<b_d;
insert into ket_qua(c1,c2,n1)
    select 'KH_TA',ma_dvi,so_id from tbh_cp where so_id_kt=0 and ngay_nh<b_d;
select c1,c2,n1 bulk collect into a_l_ct,a_ma_dvi,a_so_id from ket_qua where rownum<300;
delete temp_1; delete ket_qua;
b_loi:='';
exception when others then if b_loi is not null then b_loi:='loi:Loi xu ly FBH_KT_TONl:loi'; end if;
end;
/
create or replace procedure PBH_KT_TD_NH(
    b_ma_dvi varchar2,b_l_ct varchar2,b_so_id_bh number,b_loi out varchar2)
AS
    b_nha varchar2(20):=' '; b_tk_nha varchar2(20):=' '; b_nd nvarchar2(500):=' ';
    b_so_id_kt number; b_ngay_ht number:=PKH_NG_CSO(sysdate);
    b_so_tt number; b_lk varchar2(100); b_so_ct varchar2(20); b_ngay_ct varchar2(10);
    a_so_id pht_type.a_num; a_so_hd pht_type.a_var;
    a_nv pht_type.a_var; a_ma_tk pht_type.a_var; a_ma_tke pht_type.a_var;
    a_tien pht_type.a_num; a_note pht_type.a_nvar; a_bt pht_type.a_num;
begin
-- Dan - Nhap chung tu ke toan nghiep vu bao hiem
FBH_KT_TONc(b_ma_dvi,b_l_ct,b_so_id_bh,a_so_id,b_loi);
if b_loi is not null then return; end if;
delete ket_qua;
FBH_KT_HTOAN(b_ma_dvi,b_l_ct,a_so_id,b_loi);
if b_loi is not null then return; end if;
select c1 nv,c2 ma_tk,c3 ma_tke,n1 tien,c4 note,rownum bt bulk collect
    into a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt from ket_qua order by n10;
PHT_ID_MOI(b_so_id_kt,b_loi);
if b_loi is not null then return; end if;
b_ngay_ct:=PKH_SO_CNG(b_ngay_ht);
PBH_KH_SO_KT(b_ma_dvi,b_l_ct,b_ngay_ht,b_so_tt,b_so_ct);
PBH_KT_NH_NH(b_ma_dvi,' ',b_l_ct,b_so_id_kt,b_ngay_ht,b_so_ct,b_nha,b_tk_nha,a_so_id,b_loi);
if b_loi is not null then return; end if;
if a_nv.count<>0 then
    PKT_KT_NH(b_ma_dvi,' ','H',b_ngay_ht,b_l_ct,b_so_tt,b_so_ct,b_ngay_ct,b_nd,' ',
        a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt,b_so_id_kt,'BH',b_lk,b_loi,'C');
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_KT_TD:loi'; end if;
end;
/
create or replace procedure PBH_KT_TD
AS
    b_loi varchar2(500); b_i1 number;
    a_ma_dvi pht_type.a_var; a_l_ct pht_type.a_var; a_so_id pht_type.a_num;
begin
FBH_KT_TONl(a_ma_dvi,a_l_ct,a_so_id,b_loi);
if b_loi is not null then
    insert into kh_job_loi values(0,'FBH_KT_TONl',sysdate,b_loi);
    commit; return;
end if;
for b_lp in 1..a_ma_dvi.count loop
    select count(*) into b_i1 from kh_job_loi where so_id=a_so_id(b_lp);
    if b_i1=0 then
        PBH_KT_TD_NH(a_ma_dvi(b_lp),a_l_ct(b_lp),a_so_id(b_lp),b_loi);
        if b_loi is not null then insert into kh_job_loi values(a_so_id(b_lp),'PBH_KT_TD',sysdate,b_loi); end if;
        commit;
    end if;
end loop;
end;
/
create or replace procedure PBH_KT_TD_XOA(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_md varchar2(5); b_nsd varchar2(20);
begin
-- Dan - Xoa chung tu hach toan tu dong
select count(*) into b_i1 from bh_kt where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select nsd into b_nsd from bh_kt where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sql%rowcount=0 then b_loi:='loi:Hach toan dang xu ly:loi'; return; end if;
if nvl(trim(b_nsd),' ')<>' ' then b_loi:='loi:Khong sua,xoa da kiem soat hach toan:loi'; return; end if;
select count(*),min(md) into b_i1,b_md from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then
    if nvl(trim(b_md),' ')<>'BH' then b_loi:='loi:Sai phat sinh hach toan tu bao hiem:loi'; return; end if;
    PKT_KT_XOA(b_ma_dvi,' ',b_so_id,b_loi,'BH');
    if b_loi is not null then return; end if;
end if;
delete bh_kt where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KT_TD_XOA:loi'; end if;
end;
/
create or replace procedure PKT_KT_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2,b_md_x varchar2)
AS
    b_i1 number; b_htoan varchar2(1); b_ngay_ht number; b_kt number; b_idvung number;
    b_nsd_c varchar2(10); b_lk varchar2(100); b_md varchar2(2);
    a_nv pht_type.a_var; a_ma_tk pht_type.a_var; a_ma_tke pht_type.a_var; a_tien pht_type.a_num; a_tc pht_type.a_var;
begin
-- Dan - Xoa hach toan ke toan
b_loi:='';
select idvung into b_idvung from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
select md,htoan,ngay_ht,lk,nsd into b_md,b_htoan,b_ngay_ht,b_lk,b_nsd_c from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sqlcode<>0 or sql%rowcount<>1 then
    b_loi:='loi:Chung tu hach toan dang xu ly:loi'; return;
end if;
if trim(b_nsd_c) is not null and b_nsd_c<>b_nsd and (b_htoan='H' or b_md='KT') then
    b_loi:='loi:Khong sua, xoa chung tu nguoi khac:loi'; return;
end if;
if b_htoan='H' then
    b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'KT','KT');
    if b_loi is not null then return; end if;
    b_kt:=0;
    for b_rc in (select nv,ma_tk,ma_tke,tien from kt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
        b_kt:=b_kt+1; a_nv(b_kt):=b_rc.nv; a_ma_tk(b_kt):=b_rc.ma_tk;
        a_ma_tke(b_kt):=b_rc.ma_tke; a_tien(b_kt):=-b_rc.tien;
    end loop;
    PKT_THOP_CT(b_idvung,b_ma_dvi,b_ngay_ht,a_nv,a_ma_tk,a_ma_tke,a_tien,b_loi);
    if b_loi is not null then return; end if;
    PKT_TCHAT(b_ma_dvi,a_ma_tk,a_tc,b_loi);
    if b_loi is not null then return; end if;
    PKT_KTRA_SODU(b_ma_dvi,b_ngay_ht,a_ma_tk,a_ma_tke,a_tc,b_loi);
    if b_loi is not null then return; end if;
    b_i1:=instr(b_lk,b_md_x);
    if b_md_x<>'KT' and b_i1>0 then
        b_lk:=substr(b_lk,1,b_i1-1)||substr(b_lk,b_i1+4);
    end if;
    PKT_LKET_XOA(b_ma_dvi,b_md,b_nsd,b_so_id,b_lk,b_loi);
    if b_loi is not null then return; end if;
    PKT_KT3_XOA(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
    PKH_NGAY_TD(b_ma_dvi,'KT',b_ngay_ht,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='loi:Loi Table KT_2:loi';
delete kt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='loi:Loi Table KT_1:loi';
if b_md=b_md_x then
    delete kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    update kt_1 set nsd='',htoan='T',tien=0,lk=b_md||':1' where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PKT_KT_XOA:loi'; end if;
end;
/
create or replace procedure PTV_CT_TEST
    (b_ma_dvi varchar2,b_nsd varchar2,b_md varchar2,b_ngay_ht number,b_ngay_bc number,b_htoan varchar2,
    b_l_ct varchar2,b_ma_nt varchar2,b_tg_ht number,b_tg_tt number,b_thue_qd number,b_t_toan_qd number,
    a_bt_hd pht_type.a_num,a_mau pht_type.a_var,a_seri pht_type.a_var,a_so_hd pht_type.a_var,
    a_so_phu pht_type.a_var,a_kieu pht_type.a_var,a_lay pht_type.a_var,a_hoan pht_type.a_var,
    a_ma_hd pht_type.a_var,a_nhom pht_type.a_var,a_ngay_ct pht_type.a_var,
    a_k_ma_kh pht_type.a_var,a_ma_kh pht_type.a_var,a_tien pht_type.a_num,a_loai pht_type.a_var,
    a_pp pht_type.a_var,a_t_suat pht_type.a_num,a_thue pht_type.a_num,a_t_toan pht_type.a_num,
    a_ma_tk pht_type.a_var,a_ma_tke pht_type.a_var,a_ma_ctr pht_type.a_var,b_thue out number,b_t_toan out number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_c1 varchar2(1); b_c10 varchar2(10); b_tt varchar2(1); b_idvung number:=FHT_MA_NSD_VUNG(b_ma_dvi,b_nsd);
    a_nv_t pht_type.a_var; a_ma_tk_t pht_type.a_var; a_tien_t pht_type.a_num; b_ma_tk varchar2(20);
begin
-- Dan - Kiem tra so lieu nhap thue GTGT
if b_ngay_ht is null or b_ngay_bc is null or b_htoan is null or b_htoan not in ('H','T') or
    b_l_ct is null or b_l_ct not in('V','R','N','T') and b_ma_nt is null or
    a_bt_hd.count=0 or b_thue_qd is null or b_t_toan_qd is null then
    b_loi:='loi:So lieu nhap sai:loi'; return;
end if;
b_i1:=null;
select max(ngay) into b_i1 from kh_ma_lct where ma_dvi=b_ma_dvi and md='TV' and ma=b_l_ct and ngay<=b_ngay_ht;
if b_i1 is null then b_loi:='loi:Ma loai chung tu chua dang ky:loi'; return; end if;
b_loi:='loi:Sai ma loai tien:loi';
select 0 into b_i1 from tt_ma_nt where ma_dvi=b_ma_dvi and ma=b_ma_nt;
b_thue:=0; b_t_toan:=0;
for b_lp in 1..a_bt_hd.count loop
    if a_mau(b_lp) is null or a_seri(b_lp) is null or trim(a_so_hd(b_lp)) is null or a_so_phu(b_lp) is null or
        --a_kieu(b_lp) is null or a_kieu(b_lp) not in('G','D') or
        --a_lay(b_lp) is null or a_lay(b_lp) not in('C','K') or
        a_hoan(b_lp) is null or a_hoan(b_lp) not in('C','K') or a_tien(b_lp) is null or
        a_loai(b_lp) is null or a_loai(b_lp) not in('K','C','L') or
        a_pp(b_lp) is null or a_pp(b_lp) not in('K','T','B') or
        a_t_suat(b_lp) is null or a_t_suat(b_lp)<0 or
        a_thue(b_lp) is null or a_t_toan(b_lp) is null then
        b_loi:='loi:So lieu thue nhap sai dong#'||to_char(b_lp)||':loi'; return;
    end if;
    if a_ma_hd(b_lp) is not null then
        b_loi:='loi:Ma hoa don thue#'||a_ma_hd(b_lp)||'#chua dang ky:loi';
        select 0 into b_i1 from tv_ma_hd where ma_dvi=b_ma_dvi and ma=a_ma_hd(b_lp);
    end if;
    if a_nhom(b_lp) is not null then
        b_loi:='loi:Ma nhom thue#'||a_nhom(b_lp)||'#chua dang ky:loi';
        select 0 into b_i1 from tv_ma_nhom where ma_dvi=b_ma_dvi and ma=a_nhom(b_lp);
    end if;
    if a_k_ma_kh(b_lp) is not null and a_ma_kh(b_lp) is not null then
        b_loi:='loi:Sai ma khach hang:loi';
        if a_k_ma_kh(b_lp) in('K','U') then
            select 0 into b_i1 from cn_ma_kh where ma_dvi=b_ma_dvi and ma=a_ma_kh(b_lp);
        elsif a_k_ma_kh(b_lp)='D' then
            select 0 into b_i1 from cn_ma_dl where ma_dvi=b_ma_dvi and ma=a_ma_kh(b_lp);
        elsif a_k_ma_kh(b_lp)='C' then
            select 0 into b_i1 from ht_ma_cb where ma_dvi=b_ma_dvi and ma=a_ma_kh(b_lp);
        elsif a_k_ma_kh(b_lp)='B' then
            select 0 into b_i1 from ht_ma_phong where ma_dvi=b_ma_dvi and ma=a_ma_kh(b_lp);
        elsif a_k_ma_kh(b_lp)='N' then
            select 0 into b_i1 from ht_ma_dvi where idvung=b_idvung and ma_goc=a_ma_kh(b_lp);
        else return;
        end if;
    end if;
    if a_ma_tk(b_lp) is not null then
        b_loi:='loi:Sai ma tai khoan:loi';
        select 0 into b_i1 from kt_ma_tk where ma_dvi=b_ma_dvi and ma=a_ma_tk(b_lp);
        if a_ma_tke(b_lp) is not null then
            b_loi:='loi:Sai ma thong ke:loi';
            select 0 into b_i1 from kt_ma_tktke where ma_dvi=b_ma_dvi and ma_tk=a_ma_tk(b_lp) and ma_tke=a_ma_tke(b_lp);
        end if;
    end if;
    if a_ma_ctr(b_lp) is null then
        b_loi:='loi:Nhap ma cong trinh:loi'; return;
    elsif a_ma_ctr(b_lp)<>' ' then
        b_loi:='loi:Ma#'||trim(a_ma_ctr(b_lp))||'#chua dang ky:loi';
        select 0 into b_i1 from xd_ma_ctr where ma_dvi=b_ma_dvi and ma=a_ma_ctr(b_lp);
    end if;
    select count(*) into b_i1 from tv_rom where ma_dvi=b_ma_dvi and mau=a_mau(b_lp) and
        seri=a_seri(b_lp) and (to_number(a_so_hd(b_lp)) between to_number(so_hdd) and to_number(so_hdc));
    if b_i1<>0 then
        b_loi:='loi:Hoa don rom#'||a_mau(b_lp)||' '||a_seri(b_lp)||' '||a_so_hd(b_lp)||':loi'; return;
    end if;
    select count(*) into b_i1 from tv_2 where ma_dvi=b_ma_dvi and mau=a_mau(b_lp) and
        seri=a_seri(b_lp) and so_phu=a_so_phu(b_lp) and so_hd=a_so_hd(b_lp);
    if b_i1<>0 then
        b_loi:='loi:Trung so hoa don#'||a_mau(b_lp)||' '||a_seri(b_lp)||' '||a_so_hd(b_lp)||':loi'; return;
    end if;
    if b_l_ct in('R','T') and a_ngay_ct(b_lp) is null then
        b_loi:='loi:Nhap ngay hoa don dong#'||to_char(b_lp)||':loi'; return;
    end if;
    b_thue:=b_thue+a_thue(b_lp); b_t_toan:=b_t_toan+a_t_toan(b_lp);
end loop;
for b_lp in 1..a_bt_hd.count loop
    b_i1:=b_lp+1;
    for b_lp1 in b_i1..a_so_hd.count loop
    if a_mau(b_lp)=a_mau(b_lp1) and a_seri(b_lp)=a_seri(b_lp1) and
        a_so_hd(b_lp)=a_so_hd(b_lp1) and a_so_phu(b_lp)=a_so_phu(b_lp1) then
        b_loi:='loi:Trung so hoa don#'||a_mau(b_lp)||' '||a_seri(b_lp)||' '||a_so_hd(b_lp)||' '||a_so_phu(b_lp)||':loi'; return;
    end if;
    end loop;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_KTRA_SODU
    (b_ma_dvi varchar2,b_ngay_ht number,a_ma_tk pht_type.a_var,a_ma_tke pht_type.a_var,a_tc pht_type.a_var,b_loi out varchar2)
AS
    b_i1 number; b_ma_tke varchar2(20);
begin
-- Dan - Kiem tra so du tai khoan
for b_lp in 1..a_ma_tk.count loop
if instr(a_tc(b_lp),'T2:T')=0 then
    if instr(a_tc(b_lp),'TK:H')=0 then b_ma_tke:=' '; else b_ma_tke:=a_ma_tke(b_lp); end if;
    if instr(a_tc(b_lp),'T2:N')<>0 then
        select min(ngay_ht) into b_i1 from kt_sc where ma_dvi=b_ma_dvi and ma_tk=a_ma_tk(b_lp) and
            ma_tke=b_ma_tke and ngay_ht>=b_ngay_ht and co_ck<>0;
    else    select min(ngay_ht) into b_i1 from kt_sc where ma_dvi=b_ma_dvi and ma_tk=a_ma_tk(b_lp) and
            ma_tke=b_ma_tke and ngay_ht>=b_ngay_ht and no_ck<>0;
    end if;
    if b_i1<>0 then
        b_loi:='loi:Qua so du tai khoan#'||rtrim(a_ma_tk(b_lp))||'#'||rtrim(b_ma_tke)||'#ngay#'||PKH_SO_CNG(b_i1)||':loi';
        return;
    end if;
end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
 /
 create or replace procedure PKT_THOP_CT
    (b_idvung number,b_ma_dvi varchar2,b_ngay_ht number,a_nv pht_type.a_var,
    a_ma_tk pht_type.a_var,a_ma_tke pht_type.a_var,
    a_tien pht_type.a_num,b_loi out varchar2)
AS
    b_ma_tke varchar2(20); b_i1 number; b_no_ps number; b_co_ps number;
    b_no_ck number; b_co_ck number; a_tc pht_type.a_var;
begin
for b_lp in 1..a_nv.count loop
    b_loi:='loi:Chung tu dang xu ly:loi';
    select tc into a_tc(b_lp) from kt_ma_tk where ma_dvi=b_ma_dvi and ma=a_ma_tk(b_lp) for update nowait;
    if sqlcode<>0 or sql%rowcount<>1 then raise PROGRAM_ERROR; end if;
end loop;
b_loi:='loi:Loi Table SC_TK:loi';
for b_lp in 1..a_nv.count loop
    --duong kiem tra neu ma_tke null thi  b_ma_tke:=' '
    if instr(a_tc(b_lp),'TK:H')=0 then b_ma_tke:=' ';
    else b_ma_tke:=a_ma_tke(b_lp); end if;
    if a_ma_tke(b_lp) is not null then b_ma_tke:=a_ma_tke(b_lp);
    else b_ma_tke:=' '; end if;
    
    if a_nv(b_lp)='N' then b_no_ps:=a_tien(b_lp); b_co_ps:=0;
    else b_no_ps:=0; b_co_ps:=a_tien(b_lp); end if;
    b_i1:=null;
    select nvl(max(ngay_ht),-1) into b_i1 from kt_sc where
        ma_dvi=b_ma_dvi and ma_tk=a_ma_tk(b_lp) and ma_tke=b_ma_tke and ngay_ht<b_ngay_ht;
    if b_i1<0 then b_no_ck:=0; b_co_ck:=0;
    else select no_ck,co_ck into b_no_ck,b_co_ck from kt_sc where
        ma_dvi=b_ma_dvi and ma_tk=a_ma_tk(b_lp) and ma_tke=b_ma_tke and ngay_ht=b_i1;
    end if;
    select count(*) into b_i1 from kt_sc where
        ma_dvi=b_ma_dvi and ma_tk=a_ma_tk(b_lp) and ma_tke=b_ma_tke and ngay_ht=b_ngay_ht;
    if b_i1=0 then
        insert into kt_sc values(b_ma_dvi,a_ma_tk(b_lp),b_ma_tke,b_no_ps,b_co_ps,0,0,b_ngay_ht,b_idvung);
    else
        update kt_sc set no_ps=no_ps+b_no_ps,co_ps=co_ps+b_co_ps where ma_dvi=b_ma_dvi and ma_tk=a_ma_tk(b_lp) and ma_tke=b_ma_tke and ngay_ht=b_ngay_ht;
    end if;
    for b_rc in (select no_ps,co_ps,ngay_ht from kt_sc where
        ma_dvi=b_ma_dvi and ma_tk=a_ma_tk(b_lp) and ma_tke=b_ma_tke and
        ngay_ht>=b_ngay_ht order by ngay_ht) loop
        b_no_ck:=b_no_ck+b_rc.no_ps-b_rc.co_ps-b_co_ck; b_i1:=b_rc.ngay_ht;
        if b_no_ck=0 and b_rc.no_ps=0 and b_rc.co_ps=0 then
            delete kt_sc where ma_dvi=b_ma_dvi and ma_tk=a_ma_tk(b_lp) and ma_tke=b_ma_tke and ngay_ht=b_i1;
        else
            if b_no_ck<0 then b_co_ck:=-b_no_ck; b_no_ck:=0; else b_co_ck:=0; end if;
            update kt_sc set no_ck=b_no_ck,co_ck=b_co_ck where ma_dvi=b_ma_dvi and
                ma_tk=a_ma_tk(b_lp) and ma_tke=b_ma_tke and ngay_ht=b_i1;
        end if;
    end loop;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_KT3_NH
    (b_idvung number,b_ma_dvi varchar2,b_so_id number,b_ngay_ht number,b_l_ct varchar2,a_nv pht_type.a_var,
    a_ma_tk pht_type.a_var,a_ma_tke pht_type.a_var,a_tien pht_type.a_num,a_note pht_type.a_nvar,b_loi out varchar2)
AS
    b_bno number; b_bco number; b_i1 number; b_t1 number; b_t2 number;
begin
-- Dan - Nhap KT3
b_loi:='loi:Loi Table KT_3:loi'; b_bno:=0; b_bco:=0;
for b_lp in 1..a_nv.count loop
    if a_nv(b_lp)='N' then b_bno:=b_bno+1; else b_bco:=b_bco+1; end if;
end loop;
if b_bno=1 then
    b_i1:=0;
    for b_lp in 1..a_nv.count loop if a_nv(b_lp)='N' and a_tien(b_lp)<>0 then b_i1:=b_lp; exit; end if; end loop;
    for b_lp in 1..a_nv.count loop
        if b_lp<>b_i1 and a_tien(b_lp)<>0 then
            insert into kt_3 values(b_ma_dvi,b_so_id,b_lp,b_ngay_ht,a_ma_tk(b_i1),a_ma_tke(b_i1),
            a_note(b_i1),a_ma_tk(b_lp),a_ma_tke(b_lp),a_note(b_lp),a_tien(b_lp),b_l_ct,0,b_idvung);
        end if;
    end loop;
elsif b_bco=1 then
    b_i1:=0;
    for b_lp in 1..a_nv.count loop if a_nv(b_lp)='C'and a_tien(b_lp)<>0 then b_i1:=b_lp; exit; end if; end loop;
    for b_lp in 1..a_nv.count loop
        if b_lp<>b_i1 and a_tien(b_lp)<>0 then
            insert into kt_3 values(b_ma_dvi,b_so_id,b_lp,b_ngay_ht,a_ma_tk(b_lp),a_ma_tke(b_lp),
            a_note(b_lp),a_ma_tk(b_i1),a_ma_tke(b_i1),a_note(b_i1),a_tien(b_lp),b_l_ct,0,b_idvung);
        end if;
    end loop;
else    b_i1:=0; b_t1:=0; b_t2:=0; b_bno:=0; b_bco:=0;
    loop
        b_i1:=b_i1+1;
        if b_t1=0 then
            b_bno:=b_bno+1;
            while b_t1=0 and b_bno<=a_nv.count loop
                if a_nv(b_bno)='N' and a_tien(b_bno)<>0 then b_t1:=a_tien(b_bno);
                else b_bno:=b_bno+1; end if;
            end loop;
        end if;
        if b_t2=0 then
            b_bco:=b_bco+1;
            while b_t2=0 and b_bco<=a_nv.count loop
                if a_nv(b_bco)='C' and a_tien(b_bco)<>0 then b_t2:=a_tien(b_bco);
                else b_bco:=b_bco+1; end if;
            end loop;
        end if;
        exit when b_t1=0 and b_t2=0;
        if b_t1=0 then
            insert into kt_3 values(b_ma_dvi,b_so_id,b_i1,b_ngay_ht,' ',' ',' ',
                a_ma_tk(b_bco),a_ma_tke(b_bco),a_note(b_bco),b_t2,b_l_ct,0,b_idvung);
            b_t2:=0;
        elsif b_t2=0 then
            insert into kt_3 values(b_ma_dvi,b_so_id,b_i1,b_ngay_ht,a_ma_tk(b_bno),
                a_ma_tke(b_bno),a_note(b_bno),' ',' ',' ',b_t1,b_l_ct,0,b_idvung);
            b_t1:=0;
        elsif abs(b_t1)>abs(b_t2) then
            insert into kt_3 values(b_ma_dvi,b_so_id,b_i1,b_ngay_ht,a_ma_tk(b_bno),a_ma_tke(b_bno),
                a_note(b_bno),a_ma_tk(b_bco),a_ma_tke(b_bco),a_note(b_bco),b_t2,b_l_ct,0,b_idvung);
            b_t1:=b_t1-b_t2; b_t2:=0;
        else
            insert into kt_3 values(b_ma_dvi,b_so_id,b_i1,b_ngay_ht,a_ma_tk(b_bno),a_ma_tke(b_bno),
                a_note(b_bno),a_ma_tk(b_bco),a_ma_tke(b_bco),a_note(b_bco),b_t1,b_l_ct,0,b_idvung);
            b_t2:=b_t2-b_t1; b_t1:=0;
        end if;
    end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
 /
 create or replace procedure PKT_LKET_MOI
    (b_ma_dvi varchar2,b_so_id number,b_l_ct_n varchar2,b_ngay_ht number,
    a_nv_n pht_type.a_var,a_ma_tk_n pht_type.a_var,a_ma_tke_n pht_type.a_var,
    a_tc_n pht_type.a_var,b_md varchar2,b_lk out varchar2,b_loi out varchar2)
AS
    b_c1 varchar2(1); b_c5 varchar2(5); b_l_ct varchar2(10);
     a_tien_n pht_type.a_num; a_nv pht_type.a_var; a_ma_tk pht_type.a_var; a_ma_tke pht_type.a_var; a_tc pht_type.a_var; a_tien pht_type.a_num;
begin
-- Dan - Xac dinh lien ket cua chung tu
b_l_ct:=nvl(b_l_ct_n,' '); b_lk:='';
if b_l_ct<>'KC' then
    PKH_MANG_KD_N(a_tien_n,a_nv_n.count);
    PKT_LOC_LCT(b_l_ct,a_nv_n,a_ma_tk_n,a_ma_tke_n,a_tc_n,a_tien_n,a_nv,a_ma_tk,a_ma_tke,a_tc,a_tien);
    if a_nv.count<>0 then
        for r_lp in(select distinct md from kh_ma_lct_tk where ma_dvi=b_ma_dvi and md not in('KT','BP','LC',b_md) and length(trim(md))=2) loop
            PKH_MA_LCT_TKNV(b_ma_dvi,r_lp.md,b_ngay_ht,a_nv,a_ma_tk,b_c5); 
            if trim(b_c5) is not null then
                b_loi:='loi:Loi Table KH_MA_LCT:loi';
                select nvl(tc,' ')  into b_c1 from kh_ma_lct where ma_dvi=b_ma_dvi and md=r_lp.md and ma=b_c5 and ngay in
                    (select max(ngay) from kh_ma_lct where ma_dvi=b_ma_dvi and md=r_lp.md and ma=b_c5);
                if b_c1<>'K' then b_lk:=trim(b_lk)||trim(r_lp.md)||':0'; end if;
            end if;
        end loop;
    end if;
end if;
if b_md in('BH','HD','HO','KP') then b_lk:=trim(b_lk)||b_md||':2';
elsif b_md<>'KT' then
    PKT_LKET_KTRA(b_ma_dvi,b_md,b_so_id,b_c1,b_loi);
    if b_loi is not null then return; end if;
    b_lk:=trim(b_lk)||b_md||':'||b_c1;
end if;
b_c1:=FKT_LKET_BP(b_ma_dvi,b_so_id,b_l_ct,b_ngay_ht);
if b_c1<>'K' then b_lk:=trim(b_lk)||'BP:0'; end if;
b_c1:=FKT_LKET_TKE(a_ma_tke,a_tc,b_l_ct);
if b_c1<>' ' then b_lk:=trim(b_lk)||'TK:'||b_c1;  end if;
b_c1:=FKT_LKET_LC(b_ma_dvi,b_so_id,b_l_ct,b_ngay_ht);
if b_c1<>' ' then b_lk:=trim(b_lk)||'LC:'||b_c1;  end if;
b_loi:='';
end;
 /
 create or replace procedure PKH_NGAY_TD
	(b_ma_dvi varchar2,b_md varchar2,b_ngay number,b_loi out varchar2)
AS
begin
-- Dan - Dat lai ngay thay doi so lieu
b_loi:='loi: Loi dat lai ngay bien dong#'||b_md||':loi';
update kh_sl_day set ngayb=b_ngay where ma_dvi=b_ma_dvi and ma=b_md and loai='D' and ngayb>b_ngay;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_LKET_DAY
    (b_ma_dvi varchar2,b_md varchar2,b_so_id number,b_lk in out varchar2,b_loi out varchar2)
AS
    b_lenh varchar2(200); b_i1 number; b_i2 number; b_c1 varchar2(1); b_c2 varchar2(2);
begin
-- Dan - Day chung tu nghiep vu lien quan
b_i1:=1; b_i2:=length(rtrim(b_lk));
while b_i1<b_i2 loop
    b_c2:=substr(b_lk,b_i1,2);
    b_loi:='loi:Loi day nghiep vu #'||b_c2||':loi';
    if b_c2 not in('TK','LC','BH','HD','HO','KP',b_md) then
        if b_c2 in ('CN','TT','TV','DP','BP') then
        b_loi:='';
            if b_c2='CN' then
                PCN_NV_NH(b_ma_dvi,b_so_id,b_c1,b_loi);
            else
                b_lenh:='begin P'||b_c2||'_NV_NH(:ma_dvi,:so_id,:tt,:loi); end;';
                execute immediate b_lenh using b_ma_dvi,b_so_id,out b_c1,out b_loi;
            end if;
        else
            b_c1:='0';
            b_lenh:='begin P'||b_c2||'_NV_NH(:ma_dvi,:so_id,:loi); end;';
            execute immediate b_lenh using b_ma_dvi,b_so_id,out b_loi;
        end if;
        if b_loi is not null then return; end if;
        if b_c1<>'0' then b_lk:=replace(b_lk,substr(b_lk,b_i1,4),b_c2||':'||b_c1); end if;
    end if;
    b_i1:=b_i1+4;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_KT_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_htoan varchar2,b_ngay_ht number,b_l_ct varchar2,
    b_so_tt in out number,b_so_ct in out varchar2,b_ngay_ct varchar2,b_nd nvarchar2,b_ndp nvarchar2,
    a_nv pht_type.a_var,a_ma_tk pht_type.a_var,a_ma_tke pht_type.a_var,a_tien pht_type.a_num,
    a_note pht_type.a_nvar,a_bt pht_type.a_num,b_so_id number,b_md varchar2,
    b_lk out varchar2,b_loi out varchar2,b_day varchar2,b_datso varchar2:='C')
AS
    b_tien number:=0; b_i1 number; b_ngd number; b_ngc number; b_nsd_n varchar2(10):=b_nsd; b_idvung number;
    a_tc pht_type.a_var; 
begin
-- Dan - Nhap KT
b_idvung:=FHT_MA_NSD_VUNG(b_ma_dvi,b_nsd);
b_loi:='loi:Chung tu dang xu ly:loi';
if b_htoan not in ('H','T') then b_loi:='loi:Hach toan:H,T:loi'; return; end if;
if b_htoan='H' then
    PKT_CT_TEST(b_ma_dvi,b_ngay_ht,b_l_ct,a_nv,a_ma_tk,a_ma_tke,a_tien,a_tc,b_tien,b_loi);
    if b_loi is not null then return; end if;
else
    for b_lp in 1..a_nv.count loop a_tc(b_lp):=''; end loop;
    b_nsd_n:='';
end if;

if b_so_tt is null or b_so_tt=0 then b_so_tt:=FKT_SOTT(b_ma_dvi,b_ngay_ht,b_l_ct);
else
    b_ngd:=round(b_ngay_ht,-2); b_ngc:=b_ngd+100;
    select count(*) into b_i1 from kt_1 where ma_dvi=b_ma_dvi and 
    (ngay_ht between b_ngd and b_ngc) and nvl(l_ct,' ')=nvl(b_l_ct,' ') and so_tt=b_so_tt;
    if b_i1>0 then
        if b_md='KT' then b_loi:='loi:Trung so thu tu chung tu hach toan:loi'; return; end if;
        b_so_tt:=FKT_SOTT(b_ma_dvi,b_ngay_ht,b_l_ct);
    end if;
end if;
if trim(b_so_ct) is null then b_so_ct:=FKT_SOCT(b_ma_dvi,b_ngay_ht,b_l_ct); end if;
b_loi:='loi:Va cham nguoi su dung:loi'; b_lk:='';
insert into kt_1 values(b_ma_dvi,b_so_id,b_ngay_ht,b_l_ct,b_so_tt,b_so_ct,
    b_ngay_ct,b_tien,b_nd,b_ndp,b_nsd_n,'',b_lk,b_htoan,b_md,sysdate,b_idvung);
PKT_KT2_NH(b_idvung,b_ma_dvi,b_so_id,b_ngay_ht,a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_tc,a_bt,b_loi);
if b_loi is not null then return; end if;

if b_htoan='H' then
    b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'KT','KT');
    if b_loi is not null then return; end if;
    PKT_THOP_CT(b_idvung,b_ma_dvi,b_ngay_ht,a_nv,a_ma_tk,a_ma_tke,a_tien,b_loi);
    if b_loi is not null then return; end if;
    PKT_KTRA_SODU(b_ma_dvi,b_ngay_ht,a_ma_tk,a_ma_tke,a_tc,b_loi);
    if b_loi is not null then return; end if;
    PKT_KT3_NH(b_idvung,b_ma_dvi,b_so_id,b_ngay_ht,b_l_ct,a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,b_loi);
    if b_loi is not null then return; end if;   
    PKT_LKET_MOI(b_ma_dvi,b_so_id,b_l_ct,b_ngay_ht,a_nv,a_ma_tk,a_ma_tke,a_tc,b_md,b_lk,b_loi);
    if b_loi is not null then return; end if;
    PKH_NGAY_TD(b_ma_dvi,'KT',b_ngay_ht,b_loi);
    if b_loi is not null then return; end if;
    update kt_bp set ngay_ht=b_ngay_ht where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select count(*) into b_i1 from bh_kt where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 and instr(b_lk,'BH')<1 then b_lk:=b_lk||'BH:2'; end if;
elsif b_md<>'KT' then
    b_lk:=b_md||':0';
else
    b_lk:='';
end if;
if b_htoan='H' and b_day='C' and b_lk is not null then
    PKT_LKET_DAY(b_ma_dvi,b_md,b_so_id,b_lk,b_loi);
    if b_loi is not null then return; end if;
end if;
if b_lk is not null then
    update kt_1 set lk=b_lk where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_LKET_KTRA(b_ma_dvi varchar2,b_md varchar2,b_so_id number,b_tt out varchar2,b_loi out varchar2)
AS
    b_lenh varchar2(200);
begin
-- Dan - Kiem tra lien ket mot nghiep vu b_md
if b_md in('BH','HD','HO','KP') then b_loi:=''; return; end if;
b_loi:='loi:Loi goi kiem tra lien ket nghiep vu#'||trim(b_md)||':loi';
b_lenh:='begin P'||b_md||'_KTRA_LKET(:ma_dvi,:so_id,:tt,:loi); end;';
execute immediate b_lenh using b_ma_dvi,b_so_id,out b_tt,out b_loi;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function FKT_LKET_BP
    (b_ma_dvi varchar2,b_so_id number,b_l_ct_n varchar2,b_ngay_ht number) return varchar2
AS
    b_tt varchar2(1):='K'; b_nv varchar2(1); b_ma_tk varchar2(20); b_l_ct varchar2(10);
    b_bt number; b_i1 number;
begin
-- Dan - Xac dinh phan bo bo phan cua chung tu
b_l_ct:=nvl(b_l_ct_n,' ');
if b_l_ct='KC' then
    delete kt_bp where ma_dvi=b_ma_dvi and so_id=b_so_id; return b_tt;
end if;
b_i1:=0;
for r_lp in(select nv,ma_tk,tien,bt from kt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id order by bt) loop
    b_nv:=r_lp.nv; b_ma_tk:=r_lp.ma_tk; b_bt:=r_lp.bt;
    if PKH_MA_LCT_TRA_LQ(b_ma_dvi,'BP','BP',b_ngay_ht,b_nv,b_ma_tk) and ((b_nv='N' and b_l_ct<>'KC/N') or (b_nv='C' and b_l_ct<>'KC/C')) then
        b_i1:=b_i1+1;
    else
        delete kt_bp where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=b_bt;
    end if;
end loop;
if b_i1<>0 then b_tt:='C'; end if;
return b_tt;
end;
/
create or replace function FKT_LKET_TKE
    (a_ma_tke pht_type.a_var,a_tc pht_type.a_var,b_l_ct varchar2:=' ') return varchar2
AS
    b_tt varchar2(1):=' ';
begin
-- Dan - Xac dinh thong ke cua chung tu
if b_l_ct is not null and b_l_ct='KC' then return ' '; end if;
for b_lp in 1..a_tc.count loop
    if (instr(a_tc(b_lp),'TK:H')>0 or instr(a_tc(b_lp),'TK:C')>0) then
        if a_ma_tke(b_lp)=' ' then
            if b_tt in(' ','0') then b_tt:='0'; else b_tt:='1'; end if;
        else
            if b_tt in('0','1') then b_tt:='1'; else b_tt:='2'; end if;
        end if;
    end if;
end loop;
return b_tt;
end;
/
create or replace function FKT_LKET_LC
    (b_ma_dvi varchar2,b_so_id number,b_l_ct_n varchar2,b_ngay_ht number) return varchar2
AS
    b_tk number:=0; b_kt number:=0; b_lc number; b_bt number; b_l_ct varchar2(10);
begin
-- Dan - Xac dinh luu chuyen tien te cua chung tu
b_l_ct:=nvl(b_l_ct_n,' ');
if b_l_ct='KC' then
    delete kt_lc where ma_dvi=b_ma_dvi and so_id=b_so_id;
    return ' ';
end if;
for r_lp in (select nv,ma_tk,tien from kt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    if PKH_MA_LCT_TRA_LQ(b_ma_dvi,'LC','LC',b_ngay_ht,r_lp.nv,r_lp.ma_tk) and
        ((r_lp.nv='N' and b_l_ct<>'KC/N') or (r_lp.nv='C' and b_l_ct<>'KC/C')) then
        b_kt:=b_kt+1;
        if r_lp.nv='N' then b_tk:=b_tk+r_lp.tien; else b_tk:=b_tk-r_lp.tien; end if;
    end if;
end loop;
select nvl(sum(decode(nv,'N',tien,-tien)),0),count(*) into b_lc,b_bt from kt_lc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_kt=0 then return ' ';
elsif b_tk=b_lc then return '2';
elsif b_bt=0 then return '0';
else return '1';
end if;
end;
/
create or replace function FKT_KH_CBAO
    (b_ma_dvi varchar2,b_ngay number,a_ma_tk pht_type.a_var) return varchar2
AS
    b_kq varchar2(100):=''; b_i1 number; b_i2 number; b_ma_tkC varchar2(20); b_ma_tkL varchar2(20);
    b_tien number; b_n number; b_ngM number;
    r_cb kt_kh_cbao%rowtype;
begin
-- Dan - Tra canh bao
for b_lp in 1..a_ma_tk.count loop
     b_i2:=0;
    if b_lp>1 then
        b_i1:=b_lp-1;
        for b_lp1 in 1..b_i1 loop
            if a_ma_tk(b_lp)=a_ma_tk(b_lp1) then b_i2:=1; exit; end if;
        end loop;
    end if;
    if b_i2=0 then
        select nvl(max(ngay),0) into b_ngM from kt_kh_cbao where ma_dvi=b_ma_dvi and ngay<=b_ngay and instr(a_ma_tk(b_lp),ma_tk)=1;
        if b_ngM>0 then
            select max(ma_tk) into b_ma_tkC from kt_kh_cbao where ma_dvi=b_ma_dvi and ngay=b_ngM and instr(a_ma_tk(b_lp),ma_tk)=1;
            b_ma_tkL:=b_ma_tkC||'%'; b_tien:=0;
            for r_lp in (select ma_tk,ma_tke,max(ngay_ht) ngay_ht from kt_sc where
                ma_dvi=b_ma_dvi and ma_tk like b_ma_tkL and ngay_ht between b_ngM and b_ngay group by ma_tk,ma_tke) loop
                select no_ck-co_ck into b_n from kt_sc where ma_dvi=b_ma_dvi and ma_tk=r_lp.ma_tk and ma_tke=r_lp.ma_tke and ngay_ht=r_lp.ngay_ht;
                b_tien:=b_tien+b_n;
            end loop;
            if b_tien<>0 then 
                select * into r_cb from kt_kh_cbao where ma_dvi=b_ma_dvi and ngay=b_ngM and ma_tk=b_ma_tkC;
                if r_cb.nv<>'N' then b_tien:=-b_tien; end if;
                if b_tien>r_cb.bao then
                    if b_tien>r_cb.chan then
                        return 'loi:So du tai khoan '||a_ma_tk(b_lp)||' vuot qua muc cho phep:loi';
                    elsif b_kq is null then b_kq:=a_ma_tk(b_lp);
                    else b_kq:=b_kq||','||a_ma_tk(b_lp);
                    end if;
                end if;
            end if;
        end if;
    end if;
end loop;
if b_kq is not null then return 'bao:So du tai khoan '||b_kq||' vuot qua muc cho phep:bao'; end if;
b_kq:=FKT_KH_CBAO_TT(b_ma_dvi,b_ngay);
return b_kq;
end;
/
create or replace procedure PKT_CT_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_htoan varchar2,
    b_ngay_ht number,b_l_ct varchar2,b_so_tt in out number,b_so_ct in out varchar2,
    b_ngay_ct varchar2,b_nd nvarchar2,b_ndp nvarchar2,a_nv pht_type.a_var,a_ma_tk pht_type.a_var,
    a_ma_tke pht_type.a_var,a_tien pht_type.a_num,a_note pht_type.a_nvar,
    a_bt pht_type.a_num,b_so_id out number,b_lk out varchar2,b_cbao out varchar2)
AS
    b_i1 number; b_loi varchar2(100);
begin
-- Dan - Nhap chung tu ke toan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PHT_ID_MOI(b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKT_KT_NH(b_ma_dvi,b_nsd,b_htoan,b_ngay_ht,b_l_ct,b_so_tt,b_so_ct,b_ngay_ct,b_nd,b_ndp,
    a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt,b_so_id,'KT',b_lk,b_loi,'C');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_htoan='H' then
    b_cbao:=FKT_KH_CBAO(b_ma_dvi,b_ngay_ht,a_ma_tk);
    if instr(b_cbao,'loi:')=1 then b_loi:=b_cbao; raise PROGRAM_ERROR; end if;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PCD_CT_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id in out number,b_so_ct in out varchar2,
    b_ngay_ht number,b_htoan varchar2,b_l_ct varchar2,b_dvi varchar2,b_ngay_ct varchar2,b_nd nvarchar2,
    a_dvi in out pht_type.a_var,a_ma_nt pht_type.a_var,a_tygia pht_type.a_num,a_tien pht_type.a_num,a_tien_qd pht_type.a_num,a_nd pht_type.a_nvar,
    a_nv in out pht_type.a_var,a_ma_tk in out pht_type.a_var,a_ma_tke in out pht_type.a_var,
    a_tien_kt in out pht_type.a_num,a_note pht_type.a_nvar,a_bt pht_type.a_num,b_lk out varchar2,b_cbao out varchar2,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_i1 number; b_md varchar2(2); b_tien number; b_idvung number; b_htoanC varchar2(1); b_l_ctC varchar2(2);
    a_dviC pht_type.a_var;
begin
-- Dan - Nhap
if b_comm='C' then
    PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','CD','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
else
    b_idvung:=FHT_MA_NSD_VUNG(b_ma_dvi,b_nsd);
end if;
if b_so_id is null then b_loi:='loi:Nhap so ID chung tu:loi'; raise PROGRAM_ERROR; end if;
PCD_CT_TEST(b_ma_dvi,b_so_id,b_ngay_ht,b_htoan,b_l_ct,b_so_ct,b_dvi,a_dvi,a_ma_nt,a_tygia,a_tien,a_tien_qd,a_nd,b_tien,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKH_MANG_KD(a_dviC);
if b_so_id=0 then
    b_md:='CD';
    PHT_ID_MOI(b_so_id,b_loi);
else
    b_loi:='loi:Chung tu dang xu ly:loi';
    select md,htoan,l_ct into b_md,b_htoanC,b_l_ctC from cd_ch where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
    if sql%rowcount=0 then raise PROGRAM_ERROR; end if;
    if b_htoanC='H' and b_htoan='H' and b_l_ct=b_l_ctC then
        PCD_CT_GOC_GIU(b_ma_dvi,b_so_id,a_dvi,a_ma_nt,a_tien,a_tien_qd,a_nd,a_dviC);
    end if;
    PCD_CD_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,a_dviC,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PCD_CD_NH(b_idvung,b_ma_dvi,b_nsd,b_so_id,b_md,b_ngay_ht,b_htoan,b_l_ct,b_dvi,b_so_ct,b_ngay_ct,b_tien,b_nd,
    a_dvi,a_ma_nt,a_tygia,a_tien,a_tien_qd,a_nd,a_dviC,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKT_CT_NV_XL(b_ma_dvi,b_nsd,b_htoan,b_ngay_ht,b_so_id,b_l_ct,b_so_ct,b_ngay_ct,b_nd,
    a_nv,a_ma_tk,a_ma_tke,a_tien_kt,a_note,a_bt,b_md,'CD',b_lk,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then
    if b_htoan='H' then
        b_cbao:=FKT_KH_CBAO(b_ma_dvi,b_ngay_ht,a_ma_tk);
        if instr(b_cbao,'loi:')=1 then b_loi:=b_cbao; raise PROGRAM_ERROR; end if;
    end if;
    commit;
end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PCD_CT_TEST
    (b_ma_dvi varchar2,b_so_id number,b_ngay_ht number,b_htoan varchar2,b_l_ct varchar2,b_so_ct in out varchar2,
    b_dvi varchar2,a_dvi pht_type.a_var,a_ma_nt pht_type.a_var,a_tygia pht_type.a_num,a_tien pht_type.a_num,
    a_tien_qd pht_type.a_num,a_nd pht_type.a_nvar,b_tien out number,b_loi out varchar2)
AS
    b_i1 number; b_noite varchar2(5);
begin
-- Dan - Kiem tra so lieu phat sinh
if b_htoan is null or b_htoan not in ('H','T') or b_ngay_ht is null or 
    b_l_ct is null or b_l_ct not in('TD','CD','PT','PC') or b_dvi is null or a_ma_nt.count=0 then
    b_loi:='loi:So lieu nhap sai:loi'; return;
end if;
if b_l_ct in('TD','CD') then
    b_loi:='loi:Sai ma don vi:loi';
    if b_dvi=b_ma_dvi then return; end if;
    select 0 into b_i1 from ht_ma_dvi where ma=b_dvi;
end if;
if trim(b_so_ct) is null then
    b_so_ct:=FCD_SO_TT(b_ma_dvi,b_ngay_ht,b_l_ct);
else
    select nvl(min(so_id),0) into b_i1 from cd_ch where ma_dvi=b_ma_dvi and l_ct=b_l_ct and so_ct=b_so_ct;
    if b_i1 not in(0,b_so_id) then b_loi:='loi:Trung so chung tu phan bo phat sinh:loi'; return; end if;    
end if;
b_noite:=FTT_TRA_NOITE(b_ma_dvi); b_tien:=0;
for b_lp in 1..a_ma_nt.count loop
    b_loi:='loi:Sai chi tiet dong#'||to_char(b_lp)||':loi';
    if (b_l_ct in ('PT','PC') and a_dvi(b_lp) is null) or a_ma_nt(b_lp) is null or a_tien(b_lp) is null or a_tien(b_lp)=0
        or a_tien_qd(b_lp) is null or a_tien_qd(b_lp)=0 then return;
    end if;
    if b_l_ct in ('PT','PC') then
        b_loi:='loi:Sai ma don vi#'||a_dvi(b_lp)||':loi';
        if a_dvi(b_lp)=b_ma_dvi then return; end if;
        select 0 into b_i1 from ht_ma_dvi where ma=a_dvi(b_lp);
    end if;
    if trim(a_nd(b_lp)) is null and a_ma_nt.count<>1 then b_loi:='loi:Nhap noi dung chi tiet dong#'||to_char(b_lp)||':loi'; return; end if;
    if a_ma_nt(b_lp)<> b_noite then
        b_loi:='loi:Ma ngoai te#'||a_ma_nt(b_lp)||'#chua dang ky:loi';
        select 0 into b_i1 from tt_ma_nt where ma_dvi=b_ma_dvi and ma=a_ma_nt(b_lp);
    elsif a_tien(b_lp)<>a_tien_qd(b_lp) then return;
    end if;
    b_tien:=b_tien+a_tien_qd(b_lp);
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function FCD_SO_TT
    (b_ma_dvi varchar2,b_ngay_ht number,b_l_ct varchar2) return varchar2
AS
    b_d1 number; b_d2 number; b_i1 number;
begin
-- Dan - Cho so thu tu tiep theo
b_d1:=round(b_ngay_ht,-2);b_d2:=b_d1+100;   --Theo thang
select nvl(max(PKH_LOC_CHU_SO(so_ct)),0) into b_i1 from cd_ch where
    ma_dvi=b_ma_dvi and (ngay_ht between b_d1 and b_d2) and l_ct=b_l_ct;
if b_i1<10000 then b_i1:=1; else b_i1:=round(b_i1/10000,0)+1; end if;
return trim(to_char(b_i1))||'/'||substr(to_char(b_ngay_ht),5,2)||'_'||substr(to_char(b_ngay_ht),3,2);
end;
/
create or replace procedure PCD_CT_GOC_GIU
    (b_ma_dvi varchar2,b_so_id_du number,a_dvi pht_type.a_var,a_ma_nt pht_type.a_var,a_tien pht_type.a_num,
    a_tien_qd pht_type.a_num,a_nd pht_type.a_nvar,a_dviC out pht_type.a_var)
AS
    b_kt number:=0; b_i1 number; b_i2 number;
    a_ma_dvi pht_type.a_var; a_so_id pht_type.a_num; a_ma_ntC pht_type.a_var;
    a_tienC pht_type.a_num; a_tien_qdC pht_type.a_num; a_ndC pht_type.a_nvar;
begin
PKH_MANG_KD(a_dviC);
select ma_dvi,so_id BULK COLLECT into a_ma_dvi,a_so_id from
    (select ma_dvi,so_id,htoan from cd_ch where ma_dvi=b_ma_dvi and so_id_du=b_so_id_du) where htoan='H';
for b_lp in 1..a_ma_dvi.count loop
    b_i1:=1;
    for b_lp1 in 1..a_dvi.count loop
        if a_dvi(b_lp1)=a_ma_dvi(b_lp) then b_i1:=0; exit; end if;
    end loop;
    if b_i1=0 then
        select ma_nt,tien,tien_qd,nd BULK COLLECT into a_ma_ntC,a_tienC,a_tien_qdC,a_ndC
            from cd_ct where ma_dvi=a_ma_dvi(b_lp) and so_id=a_so_id(b_lp);
        b_i2:=0;
        for b_lp1 in 1..a_dvi.count loop
            if a_dvi(b_lp1)=a_ma_dvi(b_lp) then
                b_i2:=b_i2+1;
                for b_lp2 in 1..a_ma_ntC.count loop
                    if a_ma_ntC(b_lp2)=a_ma_nt(b_lp1) and a_tienC(b_lp2)=a_tien(b_lp1) and
                        a_tien_qdC(b_lp2)=a_tien_qd(b_lp1) and a_ndC(b_lp2)=a_nd(b_lp1) then
                        b_i1:=b_i1+1; exit;
                    end if;
                end loop;
            end if;
            if b_i1=b_i2 and b_i1=a_ma_ntC.count then
                b_kt:=b_kt+1; a_dviC(b_kt):=a_ma_dvi(b_lp);
            end if;
        end loop;
    end if;
end loop;
end;
/
-- chuclh: lay tu tb 
create or replace procedure PBH_KT_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_lct varchar2,
    b_ngayd number,b_ngayc number,b_tiend number,b_tienc number,b_so_hd varchar2,
    b_ma_kh varchar2,b_ten_kh nvarchar2,b_so_ct varchar2,b_lechsl varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_tim out pht_type.cs_type)
as
     b_tu number:=b_tu_n; b_den number:=b_den_n; b_loi varchar2(100);
     b_ngay_ht number; b_nha varchar2(20); b_tk_nha varchar2(20); b_i1 number; a_so_id pht_type.a_num; a_so_hd pht_type.a_var;
begin
b_loi:=fht_ma_nsd_ktra(b_ma_dvi,b_nsd,b_pas,'KT','BH','NX');
if b_loi is not null then raise program_error; end if;
delete temp_1;delete temp_2;delete temp_3;delete temp_4;commit;
insert into temp_3 (n1,n2,c1) select distinct a.so_id,a.ngay_ht,a.so_ct from bh_kt a where a.ma_dvi=b_ma_dvi
    and a.l_ct=b_lct and a.ngay_ht between b_ngayd and b_ngayc
    and (b_so_ct is null  or upper(a.so_ct) like '%'||upper(b_so_ct)||'%');
if b_lct='HD_NB' then
    insert into temp_2(c1,c2,n1,n2,n3,n4,n5) select distinct c1,' ',n1,n2,tien,so_id,so_id from bh_hd_goc,temp_3
        where ma_dvi=b_ma_dvi and (b_so_hd is null  or upper(so_hd) like '%'||upper(b_so_hd)||'%') and so_id_kt=n1;
    update temp_2 set c2=(select ma_kh from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=n4);
elsif b_lct='HD_TT' then
    insert into temp_2(c1,c2,n1,n2,n3,n4,n5) select c1,a.ma_kh,n1,n2,sum(b.ttoan),a.so_id_tt,b.so_id
        from bh_hd_goc_ttps a,bh_hd_goc_ttpt b,temp_3
        where a.ma_dvi=b_ma_dvi and (b_ma_kh is null or a.ma_kh=b_ma_kh) and a.so_id_kt=n1
        and b.ma_dvi=b_ma_dvi and a.so_id_tt=b.so_id_tt
        group by c1,a.ma_kh,n1,n2,a.so_id_tt,b.so_id;
    if b_so_hd is not null then
        delete temp_2 where not exists (select so_id from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=n5 and upper(so_hd) like '%'||upper(b_so_hd)||'%');
    end if;
elsif b_lct='KH_CN' then
    insert into temp_2(c1,c2,n1,n2,n3,n4) select distinct c1,ma_kh,n1,n2,tien_qd,so_id from bh_kh_cn_tu,temp_3
        where ma_dvi=b_ma_dvi
        and (b_so_hd is null or upper(c2) like '%'||upper(b_so_hd)||'%')
        and (b_ma_kh is null or upper(ma_kh) like '%'||upper(b_ma_kh)||'%') and so_id_kt=n1;
elsif b_lct='BT_DU' then
    insert into temp_2(c1,c2,n1,n2,n3,n4,n5)
        select distinct c1,' ',n1,n2,b.tien_qd,a.so_id,a.so_id_hd from bh_bt_hs a,bh_bt_hs_ps b,temp_3 c
        where a.ma_dvi=b_ma_dvi and b.ma_dvi=b_ma_dvi and a.so_id=b.so_id and a.so_id_kt=c.n1
        and (b_so_hd is null or upper(a.so_hs) like '%'||b_so_hd||'%');
    update temp_2 set (c2)=(select ma_kh from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=n5);
elsif b_lct='BT_CH' then
    insert into temp_2(c1,c2,n1,n2,n3,n4) select distinct c1,a.ma_kh,c.n1,c.n2,b.tien_qd,b.so_id_tt
        from bh_bt_tt a,bh_bt_tt_ct b,temp_3 c
        where a.ma_dvi=b_ma_dvi and b.ma_dvi=b_ma_dvi and a.so_id_tt=b.so_id_tt and a.so_id_kt=c.n1
        and (b_ma_kh is null or a.ma_kh=b_ma_kh);
    if b_so_hd is not null then
        update temp_2 set n6=(select so_id from bh_bt_tt_ps where ma_dvi=b_ma_dvi and so_id_tt=n4);
        delete temp_2 where not exists (select * from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=n6 and upper(so_hs) like '%'||upper(b_so_hd)||'%');
    end if;
elsif b_lct='DL_HH' then
    insert into temp_2(c1,c2,n1,n2,n5,n4) select distinct c.c1,a.ma_dl,n1,n2,b.so_id,a.so_id_hh
        from bh_hd_goc_hh a,bh_hd_goc_hh_pt b,temp_3 c
        where a.ma_dvi=b_ma_dvi and b.ma_dvi=b_ma_dvi and (b_ma_kh is null or a.ma_dl=b_ma_kh) and a.so_id_hh=b.so_id_hh and a.so_id_kt=c.n1;
    update temp_2 set n3=(select sum(tien_qd) from bh_hd_goc_hh_tt where ma_dvi=b_ma_dvi and so_id_hh=n4);
    if b_so_hd is not null then
        delete temp_2 where not exists (select so_id from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=n5 and upper(so_hd) like '%'||upper(b_so_hd)||'%');
    end if;
elsif b_lct='DL_CN' then
    insert into temp_2(c1,c2,n1,n2,n3,n4) select distinct c1,ma_kh,n1,n2,tien_qd,so_id from bh_dl_cn_tu,temp_3
        where ma_dvi=b_ma_dvi
        and (b_ma_kh is null or upper(ma_kh) like '%'||upper(b_ma_kh)||'%') and so_id_kt=n1;
elsif b_lct='HD_HU' then
    insert into temp_2(c1,c2,n1,n2,n3,n4) select distinct c1,' ',n1,n2,0 tien,so_id from bh_hd_goc_hu,temp_3
        where ma_dvi=b_ma_dvi and so_id_kt=n1;
    update temp_2 set c2=(select ma_kh from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=n5);
    if b_so_hd is not null then
        delete temp_2 where not exists(select * from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=n5 and upper(so_hd) like '%'||upper(b_so_hd)||'%');
    end if;
elsif b_lct='DV_TPA' then
    insert into temp_2(c1,c2,n1,n2,n3,n4) select distinct c1,tpa,n1,n2,0 tien,so_id_tr from bh_tpa_tra,temp_3
        where ma_dvi=b_ma_dvi
        and (b_ma_kh is null or upper(tpa) like '%'||upper(b_ma_kh)||'%') and so_id_kt=n1;
else
    insert into temp_2(c1,c2,n1,n2,n3,n4) select distinct c1,' ',n1,n2,0,0 from temp_3;
end if;
if b_ma_kh is not null then delete temp_2 where upper(nvl(c2,' ')) not like '%'||b_ma_kh||'%' ;end if;
update temp_2 set c3=KH_HOI_TEN(b_ma_dvi,'bh_hd_ma_kh','ma',c2,'ten');
update temp_2 set c3=(select ten from bh_dl_ma_kh where ma=c2) where c3 is null;
if b_ten_kh is not null then delete temp_2 where upper(nvl(c3,' ')) not like '%'||b_ten_kh||'%' ;end if;
delete temp_2 where (b_tiend>0 and n3<b_tiend) or (b_tienc>0 and n3>b_tienc);
if b_lechsl='C' then
    for lp in (select distinct n1 from temp_2) loop
        select ngay_ht,nha,tk_nha into b_ngay_ht,b_nha,b_tk_nha from bh_kt where ma_dvi=b_ma_dvi and so_id=lp.n1;
        b_i1:=0; PKH_MANG_XOA_N(a_so_id); PKH_MANG_XOA(a_so_hd);
        for lp1 in (select distinct n4 from temp_2 where n1=lp.n1) loop
            b_i1:=b_i1+1; a_so_id(b_i1):=lp1.n4;
        end loop;
        delete ket_qua;
        --nam: lech tham so
        FBH_KT_HTOAN(b_ma_dvi,b_lct,a_so_id,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
        delete temp_1;
        insert into temp_1(n1,c1,c2,n2) select lp.n1,c1,c2,sum(n1) from ket_qua group by c1,c2;
        insert into temp_1(n1,c1,c2,n2) select lp.n1,nv,ma_tk,-sum(tien) from kt_2 where ma_dvi=b_ma_dvi and so_id=lp.n1 group by nv,ma_tk;
        select count(*) into b_i1 from (select c1,c2,sum(n2) from temp_1 group by c1,c2 having sum(n2)<>0);
        if b_i1<>0 then insert into temp_4(n1) values(lp.n1); end if;
    end loop;
    delete temp_2 where n1 not in (select n1 from temp_4);
end if;
insert into temp_2(c1,c2,c3,n1,n2,n20) select distinct c1,c2,c3,n1,n2,2 from temp_2;
delete temp_2 where nvl(n20,0)<>2;

select count(*) into b_dong from temp_2;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
open cs_tim for select * from (select n1 so_id,PKH_SO_CNG(n2) ngay_ht, c3 ten_kh,c1 so_ct,row_number() over (order by n2,n1) sott
    from temp_2 order by n2,n1) where sott between b_tu and b_den;
exception when others then raise_application_error(-20105,b_loi);
end;
/
create or replace procedure PTV_MA_NHOM_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type,b_loai varchar2:='')
AS
    b_loi varchar2(100);
begin
--- Dan - Xem ma nhom thue VAT
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TV','MNX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_loai is null then
    open cs1 for select * from tv_ma_nhom where ma_dvi=b_ma_dvi order by ma;
else
    open cs1 for select * from tv_ma_nhom where ma_dvi=b_ma_dvi and loai=b_loai order by ma;
end if;
end;
/
create or replace procedure PTV_MA_HD_LKE
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
--- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TV','MNX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs1 for select * from tv_ma_hd where ma_dvi=b_ma_dvi order by ma;
end;