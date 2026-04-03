/*** Thanh toan ***/
create or replace function FTBH_TMN_TT_TXT(b_ma_dvi varchar2,b_so_id_tt number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_txt clob;
begin
select count(*) into b_i1 from tbh_tmN_tt_txt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from tbh_tmN_tt_txt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and loai='dt_ct';
    b_kq:=FKH_JS_GTRIu(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FTBH_TMN_TT_NGAY_HT(b_ma_dvi varchar2,b_so_id_ps number) return number
AS
    b_kq number;
begin
-- Dan - Tra ngay phat sinh
select nvl(min(ngay_ht),0) into b_kq from tbh_tmN_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
return b_kq;
end;
/
create or replace function FTBH_TMN_TT_SO_CT(b_ma_dvi varchar2,b_so_id_ps number) return varchar2
AS
    b_kq varchar2(20);
begin
-- Dan - Tra so_ct phat sinh
select nvl(min(so_ct),' ') into b_kq from tbh_tmN_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
return b_kq;
end;
/
create or replace function FTBH_TMN_TT_PTHUC(b_ma_dvi varchar2,b_so_id_ps number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra pthuc
select min(pthuc) into b_kq from tbh_tmN_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
return b_kq;
end;
/
create or replace procedure PTBH_TMN_TT_PT(
    b_ma_dvi varchar2,b_so_id_tt number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_bt number; b_tl number; b_tg number; b_tp number; b_m number;
    b_tien_con number; b_tien_con_qd number; b_thue_con number; b_thue_con_qd number;
    b_nha_bh varchar2(20); b_ngay_ht number; b_kieu varchar2(1);
    a_lh_nv pht_type.a_var; a_so_id_dt pht_type.a_num; a_tien pht_type.a_num; a_tien_qd pht_type.a_num;
    a_thue pht_type.a_num; a_thue_qd pht_type.a_num;
    a_t pht_type.a_num; a_v pht_type.a_num; a_n pht_type.a_var;
begin
-- Dan - Phan tich thanh toan
delete temp_1;
a_n(1):='C'; a_n(2):='T';
select nha_bh,ngay_ht,chi_qd,thu_qd,thue_v_qd,thue_r_qd into b_nha_bh,b_ngay_ht,a_t(1),a_t(2),a_v(1),a_v(2)
    from tbh_tmN_tt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
insert into temp_1(n1,n2,c1,c2,c3,c4,n3,n4,n5,n6)
    select so_id_ps,so_id,nhom,loai,nv,ma_nt,tien,tien_qd,thue,thue_qd
    from tbh_tmN_ct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
update temp_1 set (c7,n7,n8)=(select min(pthuc),sum(tien),sum(thue) from tbh_tmN_ps
    where ma_dvi=b_ma_dvi and so_id_ps=n1 and so_id=n2 and nha_bh=b_nha_bh and ma_nt=c4 and loai=c2);
for b_lp in 1..2 loop
    if a_t(b_lp)<>0 then
        select count(*),sum(n4),max(n3) into b_bt,b_i1,b_i2 from temp_1 where c3=a_n(b_lp) and c4<>'VND';
        if b_bt<>0 and b_i1<>0 then
            select nvl(sum(n4),0) into b_bt from temp_1 where c3=a_n(b_lp) and c4='VND';
            a_t(b_lp):=a_t(b_lp)-b_bt;
            b_i1:=a_t(b_lp)/b_i1;
            update temp_1 set n4=round(n4*b_i1,0) where c3=a_n(b_lp) and c4<>'VND';
            select sum(n4) into b_i1 from temp_1 where c3=a_n(b_lp) and c4<>'VND';
            b_i1:=a_t(b_lp)-b_i1;
            if b_i1<>0 then
                update temp_1 set n4=n4+b_i1 where c3=a_n(b_lp) and c4<>'VND' and n3=b_i2 and rownum=1;
            end if;
        else
            select count(*),sum(n4),max(n3) into b_bt,b_i1,b_i2 from temp_1 where c3=a_n(b_lp);
            if b_bt<>0 and b_i1<>0 then
                b_i1:=a_t(b_lp)/b_i1;
                update temp_1 set n4=round(n4*b_i1,0) where c3=a_n(b_lp);
                select sum(n4) into b_i1 from temp_1 where c3=a_n(b_lp);
                b_i1:=a_t(b_lp)-b_i1;
                if b_i1<>0 then
                    update temp_1 set n4=n4+b_i1 where c3=a_n(b_lp) and n3=b_i2 and rownum=1;
                end if;
                update temp_1 set n3=n4 where c3=a_n(b_lp);
            end if;
        end if;
    end if;
    if a_v(b_lp)<>0 then
        select count(*),sum(n6),max(n5) into b_bt,b_i1,b_i2 from temp_1 where c3=a_n(b_lp) and c4<>'VND';
        if b_bt<>0 and b_i1<>0 then
            select nvl(sum(n6),0) into b_bt from temp_1 where c3=a_n(b_lp) and c4='VND';
            a_t(b_lp):=a_t(b_lp)-b_bt;
            b_i1:=a_v(b_lp)/b_i1;
            update temp_1 set n6=round(n5*b_i1,0) where c3=a_n(b_lp) and c4<>'VND';
            select sum(n6) into b_i1 from temp_1 where c3=a_n(b_lp) and c4<>'VND';
            b_i1:=a_v(b_lp)-b_i1;
            if b_i1<>0 then
                update temp_1 set n6=n6+b_i1 where c3=a_n(b_lp) and c4<>'VND' and n5=b_i2 and rownum=1;
            end if;
        else
            select count(*),sum(n6),max(n5) into b_bt,b_i1,b_i2 from temp_1 where c3=a_n(b_lp);
            if b_bt<>0 and b_i1<>0 then
                b_i1:=a_v(b_lp)/b_i1;
                update temp_1 set n6=round(n5*b_i1,0) where c3=a_n(b_lp);
                select sum(n6) into b_i1 from temp_1 where c3=a_n(b_lp);
                b_i1:=a_v(b_lp)-b_i1;
                if b_i1<>0 then
                    update temp_1 set n6=n6+b_i1 where c3=a_n(b_lp) and n5=b_i2 and rownum=1;
                end if;
                update temp_1 set n5=n6 where c3=a_n(b_lp);
            end if;
        end if;
    end if;
end loop;
b_bt:=0; PKH_MANG_KD(a_lh_nv);
for r_lp in (select n1 so_id_ps,n2 so_id,c1 nhom,c2 loai,c3 nv,c8 pthuc,c4 ma_nt,n3 tien,n4 tien_qd,n5 thue,n6 thue_qd,n7 tien_goc,n8 thue_goc
    from temp_1 where n3<>0 and n7<>0) loop
    if r_lp.ma_nt='VND' then b_tp:=0; else b_tp:=2; end if;
    b_tl:=r_lp.tien/r_lp.tien_goc; b_tg:=r_lp.tien_qd/r_lp.tien;
    b_tien_con:=r_lp.tien; b_tien_con_qd:=r_lp.tien_qd;
    b_thue_con:=r_lp.thue; b_thue_con_qd:=r_lp.thue_qd;
    b_kieu:=FBH_DONG(b_ma_dvi,r_lp.so_id);
    b_m:=1; b_i1:=1; PKH_MANG_XOA(a_lh_nv);
    for r_lp1 in (select lh_nv,so_id_dt,tien,thue from tbh_tmN_ps where ma_dvi=b_ma_dvi and so_id_ps=r_lp.so_id_ps
        and so_id=r_lp.so_id and nha_bh=b_nha_bh and loai=r_lp.loai and ma_nt=r_lp.ma_nt) loop
        a_lh_nv(b_i1):=r_lp1.lh_nv; a_so_id_dt(b_i1):=r_lp1.so_id_dt;
        a_tien(b_i1):=round(r_lp1.tien*b_tl,b_tp); a_tien_qd(b_i1):=round(a_tien(b_i1)*b_tg,0);
        a_thue(b_i1):=round(r_lp1.thue*b_tl,b_tp); a_thue_qd(b_i1):=round(a_thue(b_i1)*b_tg,0);
        b_tien_con:=b_tien_con-a_tien(b_i1); b_tien_con_qd:=b_tien_con_qd-a_tien_qd(b_i1);
        b_thue_con:=b_thue_con-a_thue(b_i1); b_thue_con_qd:=b_thue_con_qd-a_thue_qd(b_i1);
        if a_tien(b_i1)>a_tien(b_m) then b_m:=b_i1; end if;
        b_i1:=b_i1+1;
    end loop;
    a_tien(b_m):=a_tien(b_m)+b_tien_con; a_tien_qd(b_m):=a_tien_qd(b_m)+b_tien_con_qd;
    a_thue(b_m):=a_thue(b_m)+b_thue_con; a_thue_qd(b_m):=a_thue_qd(b_m)+b_thue_con_qd;
    for b_lp in 1..a_lh_nv.count loop
        b_bt:=b_bt+1;
        insert into tbh_tmN_pt values(b_ma_dvi,b_so_id_tt,b_bt,b_ngay_ht,r_lp.so_id,a_so_id_dt(b_lp),r_lp.so_id_ps,r_lp.nhom,r_lp.loai,
            r_lp.nv,r_lp.pthuc,b_kieu,r_lp.ma_nt,a_lh_nv(b_lp),a_tien(b_lp),a_tien_qd(b_lp),a_thue(b_lp),a_thue_qd(b_lp));
    end loop;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TMN_TT_PT:loi'; end if;
end;
/
create or replace procedure PTBH_TMN_TT_PBO(b_ma_dvi varchar2,b_so_id_tt number,b_loi out varchar2)
AS
    b_i1 number; b_tp number; b_phong varchar2(10);
    b_dvi_xl varchar2(10); b_ngay_ht number; b_so_id number; b_bt number:=0;
    b_tien number; b_tien_qd number; b_tien_c number; b_tien_qd_c number; b_tien_t number; b_tien_qd_t number; 
begin
-- Dan - Tong hop phan bo phi nha dong, dong BH noi bo
select nvl(min(ngay_ht),0) into b_ngay_ht from tbh_tmN_pt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
if b_ngay_ht=0 then b_loi:=''; return; end if;
b_bt:=0;
for r_lp in (select so_id,nhom,loai,nv,pthuc,kieu,lh_nv,ma_nt,sum(tien) tien,sum(tien_qd) tien_qd from tbh_tmN_pt
    where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt group by so_id,nhom,loai,nv,pthuc,kieu,lh_nv,ma_nt) loop
    b_phong:=FBH_HD_PHONG(b_ma_dvi,r_lp.so_id); 
    if r_lp.nv='C' and r_lp.loai in('CH_LE_HH','CH_LE_DL') then
        b_so_id:=r_lp.so_id; b_tien:=r_lp.tien; b_tien_qd:=r_lp.tien_qd; b_tien_c:=b_tien; b_tien_qd_c:=b_tien_qd;
        if r_lp.ma_nt='VND' then b_tp:=0; else b_tp:=2; end if;
        for r_lp1 in (select nha_bh,max(pt) pt from tbh_tmN_tl where
            ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv in(' ',r_lp.lh_nv) group by nha_bh) loop
            b_dvi_xl:=r_lp1.nha_bh; b_tien_t:=round(b_tien*r_lp1.pt/100,b_tp);
            if b_tp=0 then b_tien_qd_t:=b_tien_t; else b_tien_qd_t:=round(b_tien_qd*r_lp1.pt/100,0); end if;
            b_bt:=b_bt+1;
            insert into tbh_tmN_pb values(b_dvi_xl,b_so_id_tt,b_bt,b_so_id,b_ngay_ht,b_ma_dvi,
                ' ',r_lp.nhom,r_lp.loai,r_lp.nv,r_lp.pthuc,r_lp.kieu,r_lp.lh_nv,r_lp.ma_nt,b_tien_t,b_tien_qd_t,0);
            b_tien_c:=b_tien_c-b_tien_t; b_tien_qd_c:=b_tien_qd_c-b_tien_qd_t;
        end loop;
        if b_tien_c<>0 then
            b_bt:=b_bt+1;
            insert into tbh_tmN_pb values(b_ma_dvi,b_so_id_tt,b_bt,b_so_id,b_ngay_ht,b_ma_dvi,b_phong,
                r_lp.nhom,r_lp.loai,r_lp.nv,r_lp.pthuc,r_lp.kieu,r_lp.lh_nv,r_lp.ma_nt,b_tien_c,b_tien_qd_c,-1);
        end if;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TMN_TT_PBO:loi'; end if;
end;
/
create or replace procedure FTBH_TMN_TT_NBH(b_oraIn varchar2,b_loi out varchar2)
AS
    b_so_id number; b_lenh varchar2(1000);
    b_ma_dvi varchar2(10); b_so_hd varchar2(20);
begin
-- Dan
b_lenh:=FKH_JS_LENH('ma_dvi,so_hd');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_hd using b_oraIn;
b_ma_dvi:=nvl(trim(b_ma_dvi),' '); b_so_hd:=nvl(trim(b_so_hd),' ');
b_so_id:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi,b_so_hd);
if b_so_id=0 then b_loi:='loi:So hop dong da xoa:loi'; return; end if;
insert into bh_kh_hoi_temp1 select nha_bh,FBH_MA_NBH_TEN(nha_bh)
    from tbh_tmN_tl where ma_dvi=b_ma_dvi and so_id=b_so_id and kieu='D';
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FTBH_TMN_TT_NBH:loi'; end if;
end;
/
create or replace procedure PTBH_TMN_TT_HD(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_i1 number; b_ma varchar2(20);
    b_so_hd varchar2(20); b_so_idD number; b_nbh nvarchar2(500):=' ';
begin
-- Dan - Liet ke ton
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_hd:=nvl(trim(b_oraIn),' '); b_oraOut:='';
if b_so_hd<>' ' then
    b_so_idD:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi,b_so_hd);
    if b_so_idD<>0 then
        select min(so_hd) into b_so_hd from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_idD;
        select nvl(min(nha_bh),' '),count(*) into b_ma,b_i1 from tbh_tmN_tl where ma_dvi=b_ma_dvi and so_id=b_so_idD and kieu='D';
        if b_i1=1 then b_nbh:=FBH_MA_NBH_TENl(b_ma); end if;
        select json_object('so_hd' value b_so_hd,'nbh' value b_nbh) into b_oraOut from dual;
    end if;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_TMN_TT_TON(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000);  b_lenh varchar2(1000);
    b_so_hd varchar2(20); b_nha_bh varchar2(20); b_so_id number;
begin
-- Dan - Liet ke ton
delete temp_1; delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nha_bh,so_hd');
EXECUTE IMMEDIATE b_lenh into b_nha_bh,b_so_hd using b_oraIn;
b_nha_bh:=nvl(trim(b_nha_bh),' '); b_so_hd:=nvl(trim(b_so_hd),' ');
--nampb : union => all
insert into temp_1(n1,n2,c1,c2,c3,c4,n3,n4)
    select so_id,so_id_ps,nhom,loai,nv,ma_nt,tien,thue
        from tbh_tmN_ps where ma_dvi=b_ma_dvi and nha_bh=b_nha_bh union all
    select b.so_id,b.so_id_ps,b.nhom,b.loai,nv,b.ma_nt,-b.tien,-b.thue
        from tbh_tmN_tt a,tbh_tmN_ct b where a.ma_dvi=b_ma_dvi and a.nha_bh=b_nha_bh and
        b.ma_dvi=b_ma_dvi and b.so_id_tt=a.so_id_tt;
insert into ket_qua(n1,n2,c1,c2,c3,c4,n3,n4) select n1,n2,c1,c2,c3,c4,sum(n3),sum(n4)
	from temp_1 group by n1,n2,c1,c2,c3,c4 having sum(n3)<>0;
update ket_qua set c5=FBH_DONG(b_ma_dvi,n1),c6=FBH_HD_GOC_SO_HD(b_ma_dvi,n1),
    n5=FTBH_TMN_TT_NGAY_HT(b_ma_dvi,n2),c7=FTBH_TMN_TT_SO_CT(b_ma_dvi,n2);
if b_so_hd<>' ' then delete ket_qua where c6<>b_so_hd; end if;
select JSON_ARRAYAGG(json_object(
    'ngay_ht' value n5,'so_hd' value c6,'so_ct' value c7,'kieu' value c5,'ma_nt' value c4,
    'tien' value n3,'thue' value n4,'loaiT' value ' ','chon' value ' ',
    'nhom' value c1,'nv' value c3,'loai' value c2,'so_id' value n1,'so_id_ps' value n2,'bt' value bt)
    order by bt returning clob) into b_oraOut from
    (select a.*,row_number() over (order by n5,c6,c5,c1,c2,c4) as bt from ket_qua a);
delete temp_1; delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FTBH_TMN_TT_QD(
    b_ma_dvi varchar2,b_so_id number,b_so_id_ps number,b_ma_nt varchar2,
    b_tien number,b_thue number,b_tien_qd out number,b_thue_qd out number)
AS
    b_tien_g number; b_thue_g number; b_tien_qd_g number; b_thue_qd_g number;
    b_tien_c number; b_thue_c number; b_tien_qd_c number; b_thue_qd_c number;
begin
-- Dan - Tinh qui doi VND
if b_ma_nt='VND' then
    b_tien_qd:=b_tien; b_thue_qd:=b_thue;
else
    select sum(tien),sum(thue),sum(tien_qd),sum(thue_qd) into b_tien_g,b_thue_g,b_tien_qd_g,b_thue_qd_g
        from tbh_tmN_ps where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_ps=b_so_id_ps and ma_nt=b_ma_nt;
    select nvl(sum(tien),0),nvl(sum(thue),0),nvl(sum(tien_qd),0),nvl(sum(thue_qd),0)
        into b_tien_c,b_thue_c,b_tien_qd_c,b_thue_qd_c
        from tbh_tmN_ct where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_ps=b_so_id_ps and ma_nt=b_ma_nt;
    b_tien_g:=b_tien_g-b_tien_c; b_thue_g:=b_thue_g-b_thue_c;
    b_tien_qd_g:=b_tien_qd_g-b_tien_qd_c; b_thue_qd_g:=b_thue_qd_g-b_thue_qd_c;
    b_tien_qd:=b_tien_qd_g; b_thue_qd:=b_thue_qd_g;
    if b_tien<>b_tien_g then
        if b_tien_qd_g<>0 then b_tien_qd:=round(b_tien_qd_g*b_tien/b_tien_qd_g,0); end if;
        if b_thue_qd_g<>0 then b_thue_qd:=round(b_thue_qd_g*b_thue/b_thue_qd_g,0); end if;
    end if;
end if;
end;
/
create or replace procedure PTBH_TMN_TT_QD(
	b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(200); b_lenh varchar2(2000);
    b_tien number; b_thue number; b_tsuat number;
    b_cit number:=0; b_citV number:=0; b_nbh varchar2(20);
    b_chi number:=0; b_thueV number:=0; b_thu number:=0; b_thueR number:=0; b_ttoan number;
    a_so_id pht_type.a_num; a_so_id_ps pht_type.a_num; a_loai pht_type.a_var;
    a_ma_nt pht_type.a_var; a_tien pht_type.a_num; a_thue pht_type.a_num;
    dt_ct clob; dt_hd clob;
begin
-- Dan - Tinh qui doi VND
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_hd');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_hd using b_oraIn;
b_lenh:=FKH_JS_LENH('so_id,so_id_ps,loai,ma_nt,tien,thue');
EXECUTE IMMEDIATE b_lenh bulk collect into a_so_id,a_so_id_ps,a_loai,a_ma_nt,a_tien,a_thue using dt_hd;
if a_so_id.count=0 then b_oraOut:=''; return; end if;
for b_lp in 1.. a_so_id.count loop
    b_loi:='loi:Sai so lieu goc dong '||trim(to_char(b_lp))||':loi';
    if a_so_id(b_lp) is null or a_so_id_ps(b_lp) is null or a_tien(b_lp) is null or
        trim(a_loai(b_lp)) is null or trim(a_ma_nt(b_lp)) is null then raise PROGRAM_ERROR;
    end if;
    a_loai(b_lp):=PKH_MA_TENl(a_loai(b_lp)); a_thue(b_lp):=nvl(a_thue(b_lp),0);
end loop;
for b_lp in 1.. a_so_id.count loop
    FTBH_TMN_TT_QD(b_ma_dvi,a_so_id(b_lp),a_so_id_ps(b_lp),a_ma_nt(b_lp),a_tien(b_lp),a_thue(b_lp),b_tien,b_thue);
    if a_loai(b_lp)='CH_LEPd' then b_cit:=b_cit+b_thue; b_thue:=0; end if;
    if substr(a_loai(b_lp),1,2)='CH' then
        b_chi:=b_chi+b_tien; b_thueV:=b_thueV+b_thue;
    else
        b_thu:=b_thu+b_tien; b_thueR:=b_thueR+b_thue;
    end if;
end loop;
if b_cit<>0 then
    b_nbh:=FKH_JS_GTRIs(dt_ct,'nha_bh');
    PTBH_PBO_NOP(' ',b_nbh,0,b_cit,0,b_tsuat,b_citV,b_loi);
end if;
b_ttoan:=b_chi+b_thueV-b_citV-b_thu-b_thueR;
select json_object('chi' value b_chi,'thuev' value b_thueV,'cit' value b_citV,
    'thu' value b_thu,'thuer' value b_thueR,'ttoan' value b_ttoan) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_TMN_TT_TTRANG(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number;
    b_so_id_tt number:=FKH_JS_GTRIn(b_oraIn,'so_id_tt');
    b_thue varchar2(1); cs_ttr clob:='';
begin
-- Dan - Tra tinh trang CT thanh toan
delete bh_hd_ttrang_temp; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from tbh_tmN_sc_vat where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
if b_i1<>0 then b_thue:='D'; else b_thue:='X'; end if;
insert into bh_hd_ttrang_temp values('do_thue',b_thue);
select JSON_ARRAYAGG(json_object(nv,tt)) into cs_ttr from bh_hd_ttrang_temp;
select json_object('cs_ttr' value cs_ttr) into b_oraOut from dual;
delete bh_hd_ttrang_temp; commit;
end;
/
create or replace procedure PTBH_TMN_TT_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id_tt number;
    dt_ct clob; dt_hd clob; dt_txt clob;
begin
-- Dan - Xem chi tiet thanh toan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id_tt:=FKH_JS_GTRIn(b_oraIn,'so_id_tt');
b_loi:='loi:Thanh toan da xoa:loi';
select json_object(so_ct,'nha_bh' value FBH_MA_NBH_TENl(nha_bh)) into dt_ct
    from tbh_tmN_tt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
select JSON_ARRAYAGG(json_object(
    'ngay_ht' value ngay_ht,'so_hd' value so_hd,'kieu' value kieu,'ma_nt' value ma_nt,
    'tien' value tien,'thue' value thue,'loaiT' value ' ','chon' value '',
	'nhom' value nhom,'nv' value nv,'loai' value loai,
    'so_id' value so_id,'so_id_ps' value so_id_ps,'bt' value bt)
    order by bt returning clob) into dt_hd from
    (select a.*,FBH_DONG(b_ma_dvi,so_id) kieu,FBH_HD_GOC_SO_HD(b_ma_dvi,so_id) so_hd,
    FTBH_TMN_TT_NGAY_HT(b_ma_dvi,so_id_ps) ngay_ht,FTBH_TMN_TT_PTHUC(b_ma_dvi,so_id_ps) pthuc
    from tbh_tmN_ct a where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt);
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from tbh_tmN_tt_txt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and loai='dt_ct';
select json_object('so_id_tt' value b_so_id_tt,'dt_hd' value dt_hd,
    'dt_ct' value dt_ct,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_TMN_TT_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_so_id number;
    b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number; b_phong varchar2(10);
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from tbh_tmN_tt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id_tt,'nha_bh' value FBH_MA_NBH_TEN(nha_bh)) returning clob) into cs_lke from
            (select so_id_tt,nha_bh,rownum sott from tbh_tmN_tt where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id_tt desc)
            where sott between b_tu and b_den;
    end if;
else
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from tbh_tmN_tt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id_tt,'nha_bh' value FBH_MA_NBH_TEN(nha_bh)) returning clob) into cs_lke from
            (select so_id_tt,nha_bh,rownum sott from tbh_tmN_tt where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id_tt desc) 
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_TMN_TT_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_phong varchar2(10); b_tu number; b_den number;
    b_so_id number; b_ngay_ht number; b_klk varchar2(1); b_trangkt number;
    b_trang number; b_dong number; cs_lke clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_klk,b_trangKt using b_oraIn;
if b_klk ='N' then
    select count(*) into b_dong from tbh_tmN_tt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_id_tt,rownum sott from tbh_tmN_tt where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id_tt desc) where so_id_tt<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id_tt,'nha_bh' value FBH_MA_NBH_TEN(nha_bh)) returning clob) into cs_lke from
        (select so_id_tt,nha_bh,rownum sott from tbh_tmN_tt where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id_tt desc)
        where sott between b_tu and b_den;
else
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from tbh_tmN_tt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from (select so_id_tt,rownum sott from tbh_tmN_tt where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id_tt desc) where so_id_tt<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id_tt,'nha_bh' value FBH_MA_NBH_TEN(nha_bh)) returning clob) into cs_lke from
        (select so_id_tt,nha_bh,rownum sott from tbh_tmN_tt where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id_tt desc) 
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_TMN_TT_TEST(
    b_ma_dvi varchar2,b_so_id_tt number,b_phong varchar2,dt_ct in out clob,dt_hd clob,
    b_ngay_ht out number,b_nha_bh out varchar2,b_so_ct out varchar2,
    b_chi_qd out number,b_thu_qd out number,b_chi_th_qd out number,b_thu_th_qd out number,
	b_nt_tra out varchar2,b_pt_tra out varchar2,b_tra out number,
    b_tra_qd out number,b_cit out number,b_cit_qd out number,
    a_so_id out pht_type.a_num,a_so_id_ps out pht_type.a_num,a_nhom out pht_type.a_var,
    a_loai out pht_type.a_var,a_nv out pht_type.a_var,a_ma_nt_tt out pht_type.a_var,
    a_tien_tt out pht_type.a_num,a_thue_tt out pht_type.a_num,
    a_tien_tt_qd out pht_type.a_num,a_thue_tt_qd out pht_type.a_num,
    a_pt out pht_type.a_var,a_ma_nt out pht_type.a_var,a_tien out pht_type.a_num,a_tien_qd out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_lenh varchar2(2000); b_loai varchar2(10);
    b_vao varchar2(1):='K'; b_ra varchar2(1):='K'; b_hh_do varchar2(1);
    b_chi_m number; b_chi_c number; b_chi_t number;
    b_thu_m number; b_thu_c number; b_thu_t number;
    b_chi_th_m number; b_chi_th_c number; b_chi_th_t number;
    b_thu_th_m number; b_thu_th_c number; b_thu_th_t number; b_con_qd number:=0;
begin
-- Dan - Kiem tra so lieu thanh toan dong bao hiem
b_lenh:=FKH_JS_LENH('ngay_ht,nha_bh,pt_tra,chi,thu,thuev,thuer,ttoan,nt_tra,tra,cit');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_nha_bh,b_pt_tra,
    b_chi_qd,b_thu_qd,b_chi_th_qd,b_thu_th_qd,b_con_qd,b_nt_tra,b_tra,b_cit_qd using dt_ct;
b_lenh:=FKH_JS_LENH('so_id,so_id_ps,nhom,loai,nv,ma_nt,tien,thue');
EXECUTE IMMEDIATE b_lenh bulk collect into
    a_so_id,a_so_id_ps,a_nhom,a_loai,a_nv,a_ma_nt_tt,a_tien_tt,a_thue_tt using dt_hd;
if b_ngay_ht is null or b_nha_bh is null or b_pt_tra is null or b_pt_tra not in('T','C') or
    a_so_id.count=0 then b_loi:='loi:Nhap so lieu sai:loi'; return;
end if;
b_loi:='loi:Nha bao hiem dang xu ly:loi';
select 0 into b_i1 from bh_ma_nbh where ma=b_nha_bh for update nowait;
if sql%rowcount=0 then return; end if;
b_chi_m:=0; b_chi_c:=b_chi_qd; b_chi_t:=0;
b_thu_m:=0; b_thu_c:=b_thu_qd; b_thu_t:=0;
b_chi_th_m:=0; b_chi_th_c:=b_chi_th_qd; b_chi_th_t:=0;
b_thu_th_m:=0; b_thu_th_c:=b_thu_th_qd; b_thu_th_t:=0;
for b_lp in 1.. a_so_id.count loop
    b_loi:='loi:Sai so lieu goc dong '||trim(to_char(b_lp))||':loi';
    if a_so_id(b_lp) is null or a_so_id_ps(b_lp) is null or trim(a_nhom(b_lp)) is null or 
        trim(a_loai(b_lp)) is null or trim(a_nv(b_lp)) is null or a_nv(b_lp) not in('T','C') or
        trim(a_ma_nt_tt(b_lp)) is null or a_tien_tt(b_lp) is null or a_tien_tt(b_lp)=0 then return;
    end if;
    a_thue_tt(b_lp):=nvl(a_thue_tt(b_lp),0);
end loop;
for b_lp in 1.. a_so_id.count loop
    FTBH_TMN_TT_QD(b_ma_dvi,a_so_id(b_lp),a_so_id_ps(b_lp),a_ma_nt_tt(b_lp),
        a_tien_tt(b_lp),a_thue_tt(b_lp),a_tien_tt_qd(b_lp),a_thue_tt_qd(b_lp));
    if a_nv(b_lp)='C' then
        b_vao:='C';
        if b_chi_qd<>0 then
            b_chi_c:=b_chi_c-a_tien_tt_qd(b_lp);
            if a_ma_nt_tt(b_lp)<>'VND' and (b_chi_m=0 or abs(a_tien_tt_qd(b_lp))>b_chi_t) then
                b_chi_m:=b_lp; b_chi_t:=abs(a_tien_tt_qd(b_lp));
            end if;
        end if;
        if b_chi_th_qd<>0 then
            b_chi_th_c:=b_chi_th_c-a_thue_tt_qd(b_lp);
            if a_ma_nt_tt(b_lp)<>'VND' and (b_chi_th_m=0 or abs(a_thue_tt_qd(b_lp))>b_chi_th_t) then
                b_chi_th_m:=b_lp; b_chi_th_t:=abs(a_thue_tt_qd(b_lp));
            end if;
        end if;
    else
        b_ra:='C';
        if b_thu_qd<>0 then
            b_thu_c:=b_thu_c-a_tien_tt_qd(b_lp);
            if a_ma_nt_tt(b_lp)<>'VND' and (b_thu_m=0 or abs(a_tien_tt_qd(b_lp))>b_thu_t) then
                b_thu_m:=b_lp; b_thu_t:=abs(a_tien_tt_qd(b_lp));
            end if;
        end if;
        if b_thu_th_qd<>0 then
            b_thu_th_c:=b_thu_th_c-a_thue_tt_qd(b_lp);
            if a_ma_nt_tt(b_lp)<>'VND' and (b_thu_th_m=0 or abs(a_thue_tt_qd(b_lp))>b_thu_th_t) then
                b_thu_th_m:=b_lp; b_thu_th_t:=abs(a_thue_tt_qd(b_lp));
            end if;
        end if;
    end if;
end loop;
if b_vao='K' then
    b_chi_qd:=0; b_chi_th_qd:=0;
else
    if b_chi_c<>0 then
        if b_chi_m=0 then b_chi_c:=0;
        else a_tien_tt_qd(b_chi_m):=a_tien_tt_qd(b_chi_m)+b_chi_c;
        end if;
    end if;
    if b_chi_th_c<>0 then
        if b_chi_th_m=0 then b_chi_th_c:=0;
        else a_thue_tt_qd(b_chi_th_m):=a_thue_tt_qd(b_chi_th_m)+b_chi_th_c; end if;
    end if;
end if;
if b_ra='K' then
    b_thu_qd:=0; b_thu_th_qd:=0;
else
    if b_thu_c<>0 then
        if b_thu_m=0 then b_thu_c:=0;
        else a_tien_tt_qd(b_thu_m):=a_tien_tt_qd(b_thu_m)+b_thu_c;
        end if;
    end if;
    if b_thu_th_c<>0 then
        if b_thu_th_m=0 then b_thu_th_c:=0;
        else a_thue_tt_qd(b_thu_th_m):=a_thue_tt_qd(b_thu_th_m)+b_thu_th_c;
        end if;
    end if;
end if;
if FBH_TT_KTRA(b_nt_tra)<>'C' then b_loi:='loi:Sai loai tien tra:loi'; return; end if;
if b_nt_tra='VND' then
	b_tra_qd:=b_tra; b_cit:=b_cit_qd;
else
    b_i1:=FBH_TT_TRA_TGTT(b_ngay_ht,b_nt_tra);
	b_tra_qd:=round(b_tra*b_i1,0); b_cit:=round(b_cit_qd/b_i1,2);
end if;
a_ma_nt(1):=b_nt_tra; a_tien(1):=b_tra-b_cit; a_pt(1):=b_pt_tra;
if b_nt_tra='VND' then
    a_tien_qd(1):=a_tien(1);
elsif b_pt_tra<>'C' then
    a_tien_qd(1):=FBH_TT_VND_QD(b_ngay_ht,b_nt_tra,a_tien(1));
else
    a_tien_qd(1):=PTBH_TMN_CN_QD(b_ma_dvi,b_nha_bh,b_nt_tra,b_ngay_ht,'T',a_tien(1));
end if;
if trim(b_so_ct) is null then b_so_ct:=substr(to_char(b_so_id_tt),3); end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PTBH_TMN_TT_XOA_VAT(b_ma_dvi varchar2,b_so_id_tt number,b_loi out varchar2)
AS
begin
-- Dan - Xoa VAT
delete tbh_tmN_vat_txt where ma_dvi=b_ma_dvi and so_id_vat
    in(select distinct so_id_vat from tbh_tmN_vat_ct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt);
delete tbh_tmN_vat where ma_dvi=b_ma_dvi and so_id_vat
    in(select distinct so_id_vat from tbh_tmN_vat_ct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt);
delete tbh_tmN_vat_ct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PTBH_TMN_TT_XOA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id_tt number,b_nh boolean,b_loi out varchar2)
AS
    b_nsd_c varchar2(10); b_ngay_ht number; b_nha_bh varchar2(20); b_phong varchar2(10);
    b_i1 number; b_ktra boolean:=false; b_dvi_xl varchar2(10); b_nv varchar2(1);
    a_so_id pht_type.a_num; a_so_id_ps pht_type.a_num;
begin
-- Dan - Xoa thanh toan dong bao hiem
select nha_bh,ngay_ht,nsd,so_id_kt,phong into b_nha_bh,b_ngay_ht,b_nsd_c,b_i1,b_phong
    from tbh_tmN_tt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','TA');
if b_loi is not null then return; end if;
if trim(b_nsd_c) is not null and b_nsd_c<>b_nsd then b_loi:='loi:Khong sua, xoa chung tu nguoi khac:loi'; return; end if;
if b_i1<>0 then b_loi:='loi:Thanh toan dong bao hiem da hach toan:loi'; return; end if;
select count(*) into b_i1 from tbh_tmN_vat_ct where so_id_tt=b_so_id_tt;
if b_i1<>0 then b_loi:='loi:Da phat hach hoa don:loi'; return; end if;
select min(ma_dvi),nvl(max(so_id_kt),0) into b_dvi_xl,b_i1 from tbh_tmN_pb where dvi_xl=b_ma_dvi and so_id_tt=b_so_id_tt;
if b_i1>0 then
    b_loi:='loi:Don vi '||b_dvi_xl||' da hach toan phan bo chi nha dong:loi'; return;
end if;
if b_nh=false then
    if FBH_TMN_PS_VAT(b_ma_dvi,b_so_id_tt)<>0 then
        b_loi:='loi:Thanh toan dong bao hiem da co hoa don VAT:loi'; return;
    end if;
end if;
b_i1:=0;
for r_lp in (select so_id,so_id_ps from tbh_tmN_ct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt) loop
    b_i1:=b_i1+1; a_so_id(b_i1):=r_lp.so_id; a_so_id_ps(b_i1):=r_lp.so_id_ps;
end loop;
b_i1:=0;
for r_lp in (select ma_nt,tien,tien_qd from tbh_tmN_pp where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and pt='C') loop
    if r_lp.tien>0 then b_nv:='T'; else b_nv:='C'; end if;
    PTBH_TMN_CN_THOP(b_ma_dvi,b_nv,b_ngay_ht,b_nha_bh,r_lp.ma_nt,-abs(r_lp.tien),-abs(r_lp.tien_qd),b_loi);
    if b_loi is not null then return; end if;
     b_ktra:=true;
end loop;
if b_ktra then
    PTBH_TMN_CN_KTRA(b_ma_dvi,b_loi);
    if b_loi is not null then return; end if;
end if;
delete tbh_tmN_pb where dvi_xl=b_ma_dvi and so_id_tt=b_so_id_tt;
delete tbh_tmN_pt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
delete tbh_tmN_tt_txt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
delete tbh_tmN_pp where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
delete tbh_tmN_ct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
delete tbh_tmN_tt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
for b_lp in 1..a_so_id.count loop
    PTBH_TMN_TH_PS(b_ma_dvi,a_so_id(b_lp),a_so_id_ps(b_lp),b_loi);
    if b_loi is not null then return; end if;
end loop;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TMN_TT_XOA_XOA:loi'; end if;
end;
/
create or replace procedure PTBH_TMN_TT_NH_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_phong varchar2,b_so_id_tt number,
    b_ngay_ht number,b_nha_bh varchar2,b_so_ct varchar2,
    b_chi_qd number,b_thu_qd number,b_thue_v_qd number,b_thue_r_qd number,
    b_nt_tra varchar2,b_pt_tra varchar2,b_tra number,b_tra_qd number,b_cit number,b_cit_qd number,
    a_so_id pht_type.a_num,a_so_id_ps pht_type.a_num,a_nhom pht_type.a_var,
    a_loai pht_type.a_var,a_nv pht_type.a_var,a_ma_nt_tt pht_type.a_var,
    a_tien_g pht_type.a_num,a_thue_g pht_type.a_num,
    a_tien_g_qd pht_type.a_num,a_thue_g_qd pht_type.a_num,
    a_pt pht_type.a_var,a_ma_nt pht_type.a_var,a_tien pht_type.a_num,a_tien_qd pht_type.a_num,
    dt_ct clob,b_loi out varchar2)
AS
    b_kieu varchar2(1); b_ktra boolean:=false; b_tien number; b_tien_qd number; b_nv varchar2(1);
begin
-- Dan - Nhap thanh toan dong bao hiem
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','TA');
if b_loi is not null then return; end if;
for b_lp in 1..a_pt.count loop
    if a_pt(b_lp)='C' then
        if a_tien(b_lp)>0 then b_nv:='T'; b_tien:=a_tien(b_lp); b_tien_qd:=a_tien_qd(b_lp);
        else b_nv:='C'; b_tien:=-a_tien(b_lp); b_tien_qd:=-a_tien_qd(b_lp);
        end if;
        PTBH_TMN_CN_THOP(b_ma_dvi,b_nv,b_ngay_ht,b_nha_bh,a_ma_nt(b_lp),b_tien,b_tien_qd,b_loi);
        if b_loi is not null then return; end if;
        b_ktra:=true;
    end if;
end loop;
if b_ktra then
    PTBH_TMN_CN_KTRA(b_ma_dvi,b_loi);
    if b_loi is not null then return; end if;
end if;
insert into tbh_tmN_tt values(
    b_ma_dvi,b_so_id_tt,b_ngay_ht,b_so_ct,b_phong,b_nha_bh,
    b_chi_qd,b_thu_qd,b_thue_v_qd,b_thue_r_qd,
    b_nt_tra,b_pt_tra,b_tra,b_tra_qd,b_cit,b_cit_qd,b_nsd,0);
b_loi:='loi:Loi Table tbh_tmN_CT:loi';
for b_lp in 1..a_so_id.count loop
    insert into tbh_tmN_ct values(b_ma_dvi,b_so_id_tt,b_lp,a_so_id(b_lp),a_so_id_ps(b_lp),a_nhom(b_lp),a_loai(b_lp),
        a_nv(b_lp),a_ma_nt_tt(b_lp),a_tien_g(b_lp),a_thue_g(b_lp),a_tien_g_qd(b_lp),a_thue_g_qd(b_lp));
end loop;
b_loi:='loi:Loi Table tbh_tmN_PP:loi';
for b_lp in 1..a_pt.count loop
    insert into tbh_tmN_pp values(b_ma_dvi,b_so_id_tt,b_lp,a_pt(b_lp),a_ma_nt(b_lp),a_tien(b_lp),a_tien_qd(b_lp));
end loop;
insert into tbh_tmN_tt_txt values(b_ma_dvi,b_so_id_tt,'dt_ct',dt_ct);
PTBH_TMN_TT_PT(b_ma_dvi,b_so_id_tt,b_loi);
if b_loi is not null then return; end if;
for b_lp in 1..a_so_id.count loop
    PTBH_TMN_TH_PS(b_ma_dvi,a_so_id(b_lp),a_so_id_ps(b_lp),b_loi);
    if b_loi is not null then return; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi Table tbh_tmN_TT:loi'; end if;
end;
/
create or replace procedure PTBH_TMN_TT_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_lenh varchar2(2000); dt_ct clob; dt_hd clob;
    b_so_id_tt number; b_ngay_ht number; b_nha_bh varchar2(20); b_so_ct varchar2(20); b_phong varchar2(10);
    b_chi_qd number; b_thu_qd number; b_thue_v_qd number; b_thue_r_qd number;
	b_nt_tra varchar2(5); b_pt_tra varchar2(5); b_tra number; b_tra_qd number; b_cit number; b_cit_qd number;
    
    a_so_id pht_type.a_num; a_so_id_ps pht_type.a_num; a_nhom pht_type.a_var;
    a_loai pht_type.a_var; a_nv pht_type.a_var; a_ma_nt_tt pht_type.a_var;
    a_tien_tt pht_type.a_num; a_thue_tt pht_type.a_num;
    a_tien_tt_qd pht_type.a_num; a_thue_tt_qd pht_type.a_num;
    a_pt pht_type.a_var; a_ma_nt pht_type.a_var;
    a_tien pht_type.a_num; a_tien_qd pht_type.a_num;
    a_so_id_tt pht_type.a_num; a_loai_vat pht_type.a_var; a_ma_nt_vat pht_type.a_var;
begin
-- Dan - Nhap thanh toan dong bao hiem
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id_tt:=FKH_JS_GTRIn(b_oraIn,'so_id_tt');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_hd');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_hd using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_hd);
if b_so_id_tt>0 then
    PTBH_TMN_TT_XOA_VAT(b_ma_dvi,b_so_id_tt,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    PTBH_TMN_TT_XOA_XOA(b_ma_dvi,b_nsd,b_so_id_tt,true,b_loi);
else
    PHT_ID_MOI(b_so_id_tt,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
PTBH_TMN_TT_TEST(b_ma_dvi,b_so_id_tt,b_phong,dt_ct,dt_hd,b_ngay_ht,b_nha_bh,b_so_ct,
    b_chi_qd,b_thu_qd,b_thue_v_qd,b_thue_r_qd,
	b_nt_tra,b_pt_tra,b_tra,b_tra_qd,b_cit,b_cit_qd,
    a_so_id,a_so_id_ps,a_nhom,a_loai,a_nv,a_ma_nt_tt,
    a_tien_tt,a_thue_tt,a_tien_tt_qd,a_thue_tt_qd,
    a_pt,a_ma_nt,a_tien,a_tien_qd,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTBH_TMN_TT_NH_NH(b_ma_dvi,b_nsd,b_phong,b_so_id_tt,b_ngay_ht,b_nha_bh,b_so_ct,
    b_chi_qd,b_thu_qd,b_thue_v_qd,b_thue_r_qd,
	b_nt_tra,b_pt_tra,b_tra,b_tra_qd,b_cit,b_cit_qd,
    a_so_id,a_so_id_ps,a_nhom,a_loai,a_nv,a_ma_nt_tt,
    a_tien_tt,a_thue_tt,a_tien_tt_qd,a_thue_tt_qd,
    a_pt,a_ma_nt,a_tien,a_tien_qd,dt_ct,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTBH_TMN_TH_VAT(b_ma_dvi,b_so_id_tt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTBH_TMN_TT_PBO(b_ma_dvi,b_so_id_tt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('so_id_tt' value b_so_id_tt,'so_ct' value b_so_ct) into b_oraOut from dual;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_TMN_TT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_so_id_tt number;
begin
-- Dan - Xoa thanh toan phi
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id_tt:=FKH_JS_GTRIn(b_oraIn,'so_id_tt');
if b_so_id_tt is null or b_so_id_tt=0 then
    b_loi:='loi:Chon xoa thanh toan:loi'; raise PROGRAM_ERROR;
end if;
PTBH_TMN_TT_XOA_VAT(b_ma_dvi,b_so_id_tt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTBH_TMN_TT_XOA_XOA(b_ma_dvi,b_nsd,b_so_id_tt,false,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTBH_TMN_TH_VAT(b_ma_dvi,b_so_id_tt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_TMN_TT_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(200); cs_lke clob:='';
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number; b_nha_bh varchar2(20);
begin
-- Dan - Tim thanh toan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,nha_bh');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_nha_bh using b_oraIn;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
b_nha_bh:=nvl(trim(b_nha_bh),' ');
select JSON_ARRAYAGG(json_object(
    ngay_ht,so_id_tt,'nv' value FBH_HD_NV(b_ma_dvi,so_id),
    'so_hd' value FBH_HD_GOC_SO_HD_D(b_ma_dvi,so_id),'ten' value FBH_HD_TEN(b_ma_dvi,so_id),'nha_bh' value FBH_DTAC_MA_TEN(nha_bh))
    order by ngay_ht desc,so_id_tt returning clob) into cs_lke from
    (select distinct a.ngay_ht,a.nha_bh,a.so_id_tt,b.so_id from tbh_tmN_tt a, tbh_tmN_ct b where
    a.ma_dvi=b_ma_dvi and a.ngay_ht between b_ngayD and b_ngayC and b_nha_bh in(' ',a.nha_bh) and
    b.ma_dvi=b_ma_dvi and b.so_id_tt=a.so_id_tt order by a.ngay_ht desc,a.so_id_tt) where rownum<201;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
