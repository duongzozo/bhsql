/*** MA PS ***/
create or replace function FBH_KH_SO_TT(b_ma_dvi varchar2,b_loai varchar2,b_nv varchar2,b_nam number) return number
AS
    b_kq number; b_i1 number:=0;
begin
-- Dan - Tra so thu tu theo nghiep vu, nam
select count(*) into b_kq from bh_kh_so_tt where loai=b_loai and nv=b_nv and nam=b_nam;
if b_kq=0 then
    b_kq:=1;
    insert into bh_kh_so_tt values(b_ma_dvi,b_loai,b_nv,b_nam,1);
else
    select stt into b_i1 from bh_kh_so_tt where loai=b_loai and nv=b_nv and nam=b_nam for update wait 100;
    if sql%rowcount<>0 then
        select stt into b_kq from bh_kh_so_tt where loai=b_loai and nv=b_nv and nam=b_nam;
        b_kq:=b_kq+1;
        update bh_kh_so_tt set stt=b_kq where loai=b_loai and nv=b_nv and nam=b_nam;
    end if;
end if;
return b_kq;
end;
/
create or replace function FTBH_MU_MA_LOAI(b_ma_dvi varchar2,b_ma varchar2) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra loai
select min(loai) into b_kq from tbh_mu_ma where ma_dvi=b_ma_dvi and ma=b_ma;
return b_kq;
end;
/
create or replace procedure PTBH_MU_MA_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_dong number; cs_lke clob;
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from tbh_mu_ma;
select JSON_ARRAYAGG(json_object(ma,ten,loai,nsd) order by ma) into cs_lke from tbh_mu_ma;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_MU_MA_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_trang number:=1; b_dong number; cs_lke clob;
begin
-- Dan - Xem Ma
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from tbh_mu_ma;
select JSON_ARRAYAGG(json_object(ma,ten,loai,nsd) order by ma) into cs_lke from tbh_mu_ma;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_MU_MA_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma'); cs_ct clob;
begin
-- Dan - Xem CT
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
select json_object(ma,ten,loai) into cs_ct from tbh_mu_ma where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
end;
/
create or replace procedure PTBH_MU_MA_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_loai varchar2(1);
begin
-- Dan - Nhap ma
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,loai');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_loai using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_loai is null or b_loai not in('T','C','G','H') then b_loi:='loi:Sai loai:loi'; raise PROGRAM_ERROR; end if;
delete tbh_mu_ma where ma_dvi=b_ma_dvi and ma=b_ma;
insert into tbh_mu_ma values (b_ma_dvi,b_ma,b_ten,b_loai,b_nsd);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_MU_MA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan - Nhap ma tai khoan chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete tbh_mu_ma where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** PHAT SINH ***/
create or replace function FTBH_MU_PS_SO_ID(b_ma_dvi varchar2,b_so_bk varchar2) return number
AS
    b_kq number;
begin
-- Dan - Tra so_id hop dong nhan tai co dinh
select nvl(min(so_id_ps),0) into b_kq from tbh_mu_ps where ma_dvi=b_ma_dvi and so_bk=b_so_bk;
return b_kq;
end;
/
create or replace function FTBH_MU_PS_SO_BK(b_ma_dvi varchar2,b_so_id_ps number) return varchar2
AS
    b_kq varchar2(30);
begin
-- Dan - Tra so bang ke
select min(so_bk) into b_kq from tbh_mu_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
return b_kq;
end;
/
create or replace function FTBH_MU_PS_SO_DC(b_ma_dvi varchar2,b_so_id_ps number) return varchar2
AS
    b_kq varchar2(30);
begin
-- Dan - Tra so doi chieu
select min(so_dc) into b_kq from tbh_mu_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
return b_kq;
end;
/
create or replace function FTBH_MU_PS_SO_HD(b_ma_dvi varchar2,b_so_id_ps number) return varchar2
AS
    b_kq varchar2(30);
begin
-- Dan - Tra so hop dong co dinh
select min(so_hd) into b_kq from tbh_mu_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
return b_kq;
end;
/
create or replace function FTBH_MU_PS_ID_NBH(b_ma_dvi varchar2,b_so_id_ps number) return varchar2
AS
    b_kq varchar2(20); b_so_hd varchar2(50);
begin
-- Dan - Tra nha BH qua so ID
b_so_hd:=FTBH_MU_PS_SO_HD(b_ma_dvi,b_so_id_ps);
b_kq:=FTBH_VE_HD_NBH(b_ma_dvi,b_so_hd);
return b_kq;
end;
/
create or replace procedure PTBH_MU_PS_BTRU
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
	b_i1 number; b_kt number:=0; dt_hd clob:=FKH_JS_GTRIc(b_oraIn,'dt_hd');
    a_ma_ps pht_type.a_var; a_ma_nt pht_type.a_var; a_tien pht_type.a_num;
    a_ma_nt_tt pht_type.a_var; a_tien_tt pht_type.a_num; a_loai pht_type.a_var;
    dt_btru clob; b_c clob;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_ps,ma_nt,tien');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma_ps,a_ma_nt,a_tien using dt_hd;
for b_lp in 1..a_ma_ps.count loop
    b_loi:='loi:Nhap sai chi tiet dong '||to_char(b_lp)||':loi';
    if trim(a_ma_ps(b_lp)) is null or trim(a_ma_nt(b_lp)) is null or
        a_tien(b_lp) is null or a_tien(b_lp)=0 then raise PROGRAM_ERROR;
    end if;
    a_loai(b_lp):=FTBH_MU_MA_LOAI(b_ma_dvi,a_ma_ps(b_lp));
    if a_loai(b_lp) is null then
        b_loi:='loi:Nhap sai ma phat sinh '||a_ma_ps(b_lp)||':loi'; raise PROGRAM_ERROR;
    end if;
end loop;
for b_lp in 1..a_ma_ps.count loop
    b_i1:=0;
    for b_lp1 in 1..b_kt loop
        if a_ma_nt_tt(b_lp1)=a_ma_nt(b_lp) then b_i1:=b_lp1; exit; end if;
    end loop;
    if b_i1=0 then
        b_kt:=b_kt+1;
        a_ma_nt_tt(b_kt):=a_ma_nt(b_lp);
        if a_loai(b_lp)='T' then
            a_tien_tt(b_kt):=a_tien(b_lp);
        else
            a_tien_tt(b_kt):=-a_tien(b_lp);
        end if;
    elsif a_loai(b_lp)='T' then
        a_tien_tt(b_i1):=a_tien_tt(b_i1)+a_tien(b_lp);
    else
        a_tien_tt(b_i1):=a_tien_tt(b_i1)-a_tien(b_lp);
    end if;
end loop;
for b_lp in 1..b_kt loop
    if a_tien_tt(b_lp)<>0 then
        insert into temp_1(c1,n1) values(a_ma_nt_tt(b_lp),a_tien_tt(b_lp));
    end if;
end loop;
dt_btru:='';
for b_lp in 1..b_kt loop
    if a_tien_tt(b_lp)<>0 then
        select json_object('ma_nt' value a_ma_nt_tt(b_lp),'tien' value a_tien_tt(b_lp) returning varchar2) into b_c from dual;
        if dt_btru is not null then dt_btru:=dt_btru||','; end if;
        dt_btru:=dt_btru||b_c;
    end if;
end loop;
dt_btru:='['||dt_btru||']';
select json_object('dt_btru' value dt_btru returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_MU_PS_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_klk varchar2(1); b_ngay_ht number; b_tu number; b_den number;
    b_dong number; cs_lke clob;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('klk,ngay_ht,tu,den');
EXECUTE IMMEDIATE b_lenh into b_klk,b_ngay_ht,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from tbh_mu_ps where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(so_id_ps,so_bk,so_dc) returning clob) into cs_lke from
        (select so_id_ps,so_bk,so_dc,rownum sott from tbh_mu_ps
        where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id_ps)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from tbh_mu_ps where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(so_id_ps,so_bk,so_dc) returning clob) into cs_lke from
        (select so_id_ps,so_bk,so_dc,rownum sott from tbh_mu_ps
        where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id_ps)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/ 
create or replace procedure PTBH_MU_PS_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_so_id_ps number; b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number;
    b_trangkt number; b_trang number; b_dong number; cs_lke clob;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,klk,ngay_ht,tu,den,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id_ps,b_klk,b_ngay_ht,b_tu,b_den,b_trangkt using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from tbh_mu_ps where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_id_ps,rownum sott from tbh_mu_ps
        where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id_ps) where so_id_ps>=b_so_id_ps;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id_ps,so_bk,so_dc) returning clob) into cs_lke from
        (select so_id_ps,so_bk,so_dc,rownum sott from tbh_mu_ps
        where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id_ps)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from tbh_mu_ps where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    select nvl(min(sott),b_dong) into b_tu from (select so_id_ps,rownum sott from tbh_mu_ps
        where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id_ps) where so_id_ps>=b_so_id_ps;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id_ps,so_bk,so_dc) returning clob) into cs_lke from
        (select so_id_ps,so_bk,so_dc,rownum sott from tbh_mu_ps
        where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id_ps)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_MU_PS_SO_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_bk varchar2(20):=FKH_JS_GTRIs(b_oraIn,'so_bk'); b_so_id number;
begin
-- Dan - Tra so ID qua so bang ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FTBH_MU_PS_SO_ID(b_ma_dvi,b_so_bk);
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_MU_PS_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id_ps number:=FKH_JS_GTRIn(b_oraIn,'so_id');
    cs_ct clob; cs_hd clob; cs_tt clob;
begin
-- Dan - Liet ke chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Phat sinh da xoa:loi';
select json_object(so_id_ps,ngay_ht,so_hd,so_bk,so_dc,ttrang,nd returning clob) into cs_ct from tbh_mu_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
select JSON_ARRAYAGG(json_object(nv,ma_ps,ma_nt,tien,nd) order by bt returning clob) into cs_hd
    from tbh_mu_ps_ct where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
select JSON_ARRAYAGG(json_object(ma_nt,tien) order by bt returning clob) into cs_tt
    from tbh_mu_ps_btr where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
select json_object('so_id' value b_so_id_ps,'cs_ct' value cs_ct,'cs_hd' value cs_hd,'cs_tt' value cs_tt) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_MU_PS_XOA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id_ps number,b_loi out varchar2)
AS
    b_i1 number; b_nsdC varchar2(10); b_so_id_kt number;
begin
-- Dan - Xoa
b_loi:='';
select nsd,so_id_kt into b_nsdC,b_so_id_kt from tbh_mu_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
if b_nsd<>b_nsdC then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
select count(*) into b_i1 from tbh_mu_tt_ct where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
if b_i1<>0 then b_loi:='loi:Khong sua, xoa so lieu da thanh toan:loi'; return; end if;
if b_so_id_kt>0 then
    PBH_KT_TD_XOA(b_ma_dvi,b_so_id_kt,b_loi);
    if b_loi is not null then return; end if;
end if;
delete tbh_mu_ps_ct where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
delete tbh_mu_ps_tt where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
delete tbh_mu_ps_btr where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
delete tbh_mu_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PTBH_MU_PS_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_so_id_ps number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Dan - Xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id_ps is null then b_loi:='loi:Nhap so ID:loi'; raise PROGRAM_ERROR; end if;
PTBH_MU_PS_XOA_XOA(b_ma_dvi,b_nsd,b_so_id_ps,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_MU_PS_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob, b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_i1 number;
    dt_ct clob; dt_hd clob; dt_tt clob;
    b_so_id_ps number; b_ngay_ht number; b_so_hd varchar2(20); b_so_bk varchar2(20);
    b_so_dc varchar2(20); b_ttrang varchar2(1); b_nd nvarchar2(500);
    a_nv pht_type.a_var; a_ma_ps pht_type.a_var; a_ma_nt pht_type.a_var; a_tien pht_type.a_num; a_nd pht_type.a_nvar;
    a_ma_nt_tt pht_type.a_var; a_tien_tt pht_type.a_num; a_tien_qd pht_type.a_num; a_tien_tt_qd pht_type.a_num;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,dt_ct,dt_hd,dt_tt');
EXECUTE IMMEDIATE b_lenh into b_so_id_ps,dt_ct,dt_hd,dt_tt using b_oraIn;
b_lenh:=FKH_JS_LENH('ngay_ht,so_hd,so_bk,so_dc,ttrang,nd');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_so_hd,b_so_bk,b_so_dc,b_ttrang,b_nd using dt_ct;
if b_ngay_ht is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;

--if trim(b_so_hd) is null or FTBH_HD_VE_SO_ID(b_ma_dvi,b_so_hd)=0 then

if trim(b_so_hd) is null then
    b_loi:='loi:Sai so hop dong:loi'; raise PROGRAM_ERROR;
end if;
if b_ttrang is null or b_ttrang not in ('D','X') then
    b_loi:='loi:Sai tinh trang:loi'; raise PROGRAM_ERROR;
end if;
b_lenh:=FKH_JS_LENH('nv,ma_ps,ma_nt,tien,nd');
EXECUTE IMMEDIATE b_lenh bulk collect into a_nv,a_ma_ps,a_ma_nt,a_tien,a_nd using dt_hd;
if a_nv.count=0 then b_loi:='loi:Nhap chi tiet:loi'; raise PROGRAM_ERROR; end if;
PKH_MANG(a_ma_nt_tt);
for b_lp in 1..a_nv.count loop
    b_loi:='loi:Nhap sai chi tiet dong '||to_char(b_lp)||':loi';
    if trim(a_nv(b_lp)) is null or trim(a_ma_ps(b_lp)) is null or
        trim(a_ma_nt(b_lp)) is null or a_tien(b_lp) is null or a_tien(b_lp)=0 then raise PROGRAM_ERROR;
    end if;
    select 0 into b_i1 from tbh_mu_ma where ma_dvi=b_ma_dvi and ma=a_ma_ps(b_lp);
    if a_ma_nt(b_lp)='VND' then
        a_tien_qd(b_lp):=a_tien(b_lp);
    else
        a_tien_qd(b_lp):=FTT_VND_QD(b_ma_dvi,b_ngay_ht,a_ma_nt(b_lp),a_tien(b_lp));
    end if;
end loop;
b_lenh:=FKH_JS_LENH('ma_nt,tien');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma_nt_tt,a_tien_tt using dt_tt;
for b_lp in 1..a_ma_nt_tt.count loop
    if a_ma_nt_tt(b_lp)='VND' then
        a_tien_tt_qd(b_lp):=a_tien_tt(b_lp);
    else
        a_tien_tt_qd(b_lp):=FTT_VND_QD(b_ma_dvi,b_ngay_ht,a_ma_nt_tt(b_lp),a_tien_tt(b_lp));
    end if; 
end loop;
if b_so_id_ps<>0 then
    b_so_bk:=FTBH_MU_PS_SO_BK(b_ma_dvi,b_so_id_ps);
    PTBH_MU_PS_XOA_XOA(b_ma_dvi,b_nsd,b_so_id_ps,b_loi);
else
    b_so_bk:=FTBH_SO_TA(b_ma_dvi,'MUPS',b_ngay_ht);
    PHT_ID_MOI(b_so_id_ps,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table tbh_mu_ps_ct:loi';
for b_lp in 1..a_nv.count loop
    insert into tbh_mu_ps_ct values(b_ma_dvi,b_so_id_ps,b_lp,a_nv(b_lp),
        a_ma_ps(b_lp),a_ma_nt(b_lp),a_tien(b_lp),a_tien_qd(b_lp),a_nd(b_lp));
end loop;
b_loi:='loi:Loi Table tbh_mu_ps_btr:loi'; b_i1:=0;
for b_lp in 1..a_ma_nt_tt.count loop
    insert into tbh_mu_ps_btr values(b_ma_dvi,b_so_id_ps,b_lp,b_ngay_ht,b_so_hd,a_ma_nt(b_lp),a_tien_tt(b_lp),a_tien_tt_qd(b_lp),0);
    b_i1:=b_i1+a_tien_tt_qd(b_lp);
end loop;
b_loi:='loi:Loi Table tbh_mu_ps:loi';
insert into tbh_mu_ps values(b_ma_dvi,b_so_id_ps,b_ngay_ht,b_so_hd,b_so_bk,b_so_dc,b_ttrang,b_i1,b_nd,b_nsd,0,sysdate);
commit;
select json_object('so_id' value b_so_id_ps,'so_bk' value b_so_bk) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
	