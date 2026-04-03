/*** XOL ***/
create or replace function FTBH_XOL_PH_ID_SO_PH(b_so_id number) return varchar2
AS
    b_kq varchar2(50);
begin
-- Dan - Tra so HD qua so ID
select nvl(min(so_ph),' ') into b_kq from tbh_xol_ph where so_id=b_so_id;
return b_kq;
end;
/
create or replace function FTBH_XOL_PH_HD_SO_ID(b_so_ph varchar2) return number
AS
    b_kq number;
begin
-- Dan - Tra so ID qua so HD
select nvl(min(so_id),0) into b_kq from tbh_xol_ph where so_ph=b_so_ph;
return b_kq;
end;
/
create or replace function FTBH_XOL_PH_TONG(
    b_so_id number,b_ma_ta varchar2,b_tu number,b_ngay number) return number
AS
    b_kq number:=0;
begin
-- Dan - Tra tong tien phuc hoi theo ma_ta,tu
select nvl(sum(tien),0) into b_kq from tbh_xol_ph a,tbh_xol_ph_dc b
    where a.so_idD=b_so_id and a.ngay_ht<=b_ngay and b.so_id=a.so_id and b.lh_nv=b_ma_ta and b.tu=b_tu;
return b_kq;
end;
/
create or replace procedure PTBH_XOL_PH_TAO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_so_hd varchar2(20); b_so_idD number; b_so_idC number;
    b_lan number; b_lanT number; b_vu number; b_tien number; b_ngay number; b_lanC varchar2(100);
    dk_lh_nv pht_type.a_var; dk_tu pht_type.a_num; dk_den pht_type.a_num;
    dk_pt pht_type.a_num; dk_bth pht_type.a_num; dk_vu pht_type.a_num; dk_tien pht_type.a_num;
    dt_ct clob; dt_dk clob:=''; b_txt clob;
begin
-- Dan - Tao thong tin phuc hoi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_idD:=FTBH_XOL_HD_SO_IDd(b_oraIn);
if b_so_idD=0 then b_loi:='loi:So hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
b_so_idC:=FTBH_XOL_SO_IDc(b_so_idD);
select JSON_ARRAYAGG(json_object(so_hd,ma_nt,glai,ngay_bd,ngay_kt)) into dt_ct from tbh_xol where so_id=b_so_idC;
select lh_nv,tu,den,pt,vu,tien bulk collect into dk_lh_nv,dk_tu,dk_den,dk_pt,dk_vu,dk_tien
    from tbh_xol_nv where so_id=b_so_idC order by bt;
for b_lp in 1..dk_tu.count loop
    select nvl(max(ngay),0) into b_ngay from tbh_xol_sc where
        so_id=b_so_idD and lh_nv=dk_lh_nv(b_lp) and tu=dk_tu(b_lp);
    if b_ngay=0 then continue; end if;
    select lanT,vuT,tienT into b_lanT,b_vu,b_tien from tbh_xol_sc where
        so_id=b_so_idD and ngay=b_ngay and lh_nv=dk_lh_nv(b_lp) and tu=dk_tu(b_lp);        
    if b_lanT=0 or (b_vu<>0 and b_tien>=dk_den(b_lp)-dk_tu(b_lp)) then continue; end if;
    select sum(lan) into b_lan from tbh_xol_sc where
        so_id=b_so_idD and lh_nv=dk_lh_nv(b_lp) and tu=dk_tu(b_lp) and lan>0;
    b_lanC:=to_char(b_lan-b_lanT+1)||'/'||to_char(b_lan);
    dk_vu(b_lp):=dk_vu(b_lp)-b_vu; dk_tien(b_lp):=dk_tien(b_lp)-b_tien; dk_bth(b_lp):=dk_tien(b_lp);
    select json_object('lh_nv' value dk_lh_nv(b_lp),
        'tu' value dk_tu(b_lp),'den' value dk_den(b_lp),'lan' value b_lan,
        'pt' value dk_pt(b_lp),'bth' value dk_bth(b_lp),'vu' value dk_vu(b_lp),
        'tien' value dk_tien(b_lp)) into b_txt from dual;
    if trim(dt_dk) is not null then dt_dk:=dt_dk||','; end if;
    dt_dk:=dt_dk||b_txt;
end loop;
if trim(dt_dk) is not null then dt_dk:='['||dt_dk||']'; end if;
select json_object('so_id' value 0,'dt_ct' value dt_ct,'dt_dk' value dt_dk returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_XOL_PH_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number;
begin
-- Dan - Hoi so ID qua so phuc hoi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FTBH_XOL_PH_HD_SO_ID(b_oraIn);
if b_so_id=0 then b_loi:='loi:So phuc hoi da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_XOL_PH_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ngay_ht number; b_tu number; b_den number;
    b_dong number; cs_lke clob;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_tu,b_den using b_oraIn;
select count(*) into b_dong from tbh_xol_ph where ngay_ht=b_ngay_ht;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(so_ph,so_id) returning clob) into cs_lke from
    (select so_ph,so_id,rownum sott from tbh_xol_ph where ngay_ht=b_ngay_ht order by so_ph)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_XOL_PH_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_so_ph varchar2(20);
    b_so_id number; b_ngay_ht number; b_trangKt number; b_tu number; b_den number;
    b_trang number; b_dong number; cs_lke clob;
begin
-- Dan - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_trangKt using b_oraIn;
b_so_ph:=FTBH_XOL_PH_ID_SO_PH(b_so_id);
if b_so_ph is null then b_loi:='loi:phuc hoi da xoa:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from tbh_xol_ph where ngay_ht=b_ngay_ht ;
select nvl(min(sott),b_dong) into b_tu from
    (select so_ph,rownum sott from tbh_xol_ph where ngay_ht=b_ngay_ht order by so_ph) where so_ph>=b_so_ph;
PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
select JSON_ARRAYAGG(json_object(so_ph,so_id) returning clob) into cs_lke from
    (select so_ph,so_id,rownum sott from tbh_xol_ph where ngay_ht=b_ngay_ht order by so_ph)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_XOL_PH_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number;
    dt_ct clob; dt_dk clob; dt_txt clob;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
if b_so_id=0 then b_loi:='loi:Chon so phuc hoi:loi'; raise PROGRAM_ERROR; end if;
select json_object(so_ph,'so_hd' value FTBH_XOL_ID_SO_HD(so_idD)) into dt_ct from tbh_xol_ph where so_id=b_so_id;
select JSON_ARRAYAGG(json_object('lh_nv' value FBH_MA_LHNV_TAI_TENf(lh_nv),tu,den,bt) order by bt returning clob)
    into dt_dk from tbh_xol_ph_nv where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt from tbh_xol_ph_txt where so_id=b_so_id;
select json_object('so_id' value b_so_id,'dt_ct' value dt_ct,
    'dt_dk' value dt_dk,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_XOL_PH_XOA_XOA(
    b_nsd varchar2,b_so_id number,b_loi out varchar2,b_nh varchar2:='K')
AS
    b_i1 number:=0; b_nsdC varchar2(20); b_so_idD number; b_ngay_ht number;
    dc_lh_nv pht_type.a_var; dc_tu pht_type.a_num; dc_den pht_type.a_num;
    dc_lan pht_type.a_num; dc_vu pht_type.a_num; dc_tien pht_type.a_num;
begin
-- Dan - Xoa
select count(*) into b_i1 from tbh_xol_ph where so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select nsd,so_idD,ngay_ht into b_nsdC,b_so_idD,b_ngay_ht from tbh_xol_ph where so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
if b_nsdC not in(' ',b_nsd) then
    b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return;
end if;
select lh_nv,tu,den,-lan,-vu,-tien bulk collect into dc_lh_nv,dc_tu,dc_den,dc_lan,dc_vu,dc_tien
    from tbh_xol_ph_dc where so_id=b_so_id;
PTBH_XOL_TH(b_so_idD,b_ngay_ht,dc_lh_nv,dc_tu,dc_den,dc_lan,dc_vu,dc_tien,b_loi);
if b_loi is not null then return; end if;
PTBH_TH_TA_XOA(b_so_id,0,0,0,b_loi);
if b_loi is not null then return; end if;
if b_nh='K' then
    select nvl(max(ngay_ht),0) into b_i1 from tbh_xol_ph where so_idD=b_so_idD and so_id>b_so_id;
    if b_i1<>0 then b_loi:='loi:Da co phuc hoi ngay '||PKH_SO_CNG(b_i1)||':loi'; return; end if;
    select count(*) into b_i1 from tbh_ps where so_id=b_so_id and so_id_xl<>0;
    if b_i1<>0 then b_loi:='loi:Da co xu ly thanh toan phi phuc hoi:loi'; return; end if;
end if;
delete tbh_xol_ph_txt where so_id=b_so_id;
delete tbh_xol_ph_dc where so_id=b_so_id;
delete tbh_xol_ph_nv where so_id=b_so_id;
delete tbh_xol_ph_nbh where so_id=b_so_id;
delete tbh_xol_ph where so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_XOL_PH_XOA_XOA:loi'; else null; end if;
end;
/
create or replace procedure PTBH_XOL_PH_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Dan - Xoa GCN
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTBH_XOL_PH_XOA_XOA(b_nsd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_XOL_PH_TEST(
    b_so_id number,dt_ct in out clob,dt_dk clob,
    b_so_ph out varchar2,b_ma_nt out varchar2,b_glai out number,b_ttoan out number,
    b_ngay_bd out number,b_ngay_kt out number,b_ngay_ht out number,
    b_nv out varchar2,b_so_idD out number,
    dk_lh_nv out pht_type.a_var,dk_tu out pht_type.a_num,dk_den out pht_type.a_num,dk_lan out pht_type.a_var,
    dk_pt out pht_type.a_num,dk_bth out pht_type.a_num,dk_phi out pht_type.a_num,
    dk_vu out pht_type.a_num,dk_tien out pht_type.a_num,
    nbh_so_hd out pht_type.a_var,nbh_ma out pht_type.a_var,nbh_kieu out pht_type.a_var,
    nbh_pt out pht_type.a_num,nbh_phi out pht_type.a_num,nbh_tl_thue out pht_type.a_num,
    nbh_thue out pht_type.a_num,nbh_maC out pht_type.a_var,
    dc_lh_nv out pht_type.a_var,dc_tu out pht_type.a_num,dc_den out pht_type.a_num,dc_lan out pht_type.a_num,
    dc_phi out pht_type.a_num,dc_vu out pht_type.a_num,dc_tien out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_phiC number; b_tp number:=0; b_txt clob;
    b_lenh varchar2(2000); b_ngay number:=PKH_NG_CSO(sysdate);
    b_fm varchar2(50):=FKH_Fm(); b_so_hd varchar2(20); b_so_idC number;
begin
-- Dan - Test
b_loi:='loi:Loi xu ly PTBH_XOL_PH_TEST:loi';
b_lenh:=FKH_JS_LENH('so_hd,ttoan,ngay_ht');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_ttoan,b_ngay_ht using dt_ct;
if b_ngay_ht in(0,30000101) then b_loi:='loi:Nhap ngay phuc hoi:loi'; return; end if;
if b_so_hd=' ' then b_loi:='loi:Nhap so hop dong hoi goc:loi'; return; end if;
b_so_idC:=FTBH_XOL_HD_SO_IDc(b_so_hd);
if b_so_idC=0 then return; end if;
b_so_idD:=FTBH_XOL_SO_IDd(b_so_idC);
select ma_nt,glai,ngay_bd,ngay_kt,nv into b_ma_nt,b_glai,b_ngay_bd,b_ngay_kt,b_nv from tbh_xol where so_id=b_so_idC;
select count(*) into b_i1 from tbh_xol_ph where so_idD=b_so_idD;
b_so_ph:=FTBH_XOL_ID_SO_HD(b_so_idD)||'/P'||to_char(b_i1+1);
b_lenh:=FKH_JS_LENH('lh_nv,tu,den,lan,pt,bth,phi,vu,tien');
EXECUTE IMMEDIATE b_lenh bulk collect into dk_lh_nv,dk_tu,dk_den,dk_lan,dk_pt,dk_bth,dk_phi,dk_vu,dk_tien using dt_dk;
if dk_tu.count=0 then b_loi:='loi:Nhap muc phuc hoi:loi'; return; end if;
for b_lp in 1..dk_tu.count loop
    if dk_lh_nv(b_lp)<>' ' and FBH_MA_LHNV_TAI_NV(dk_lh_nv(b_lp),b_nv)<>'C' then
        b_loi:='loi:Sai nghiep vu: '||dk_lh_nv(b_lp)||':loi'; return;
    end if;
    if dk_bth(b_lp)=0 or dk_phi(b_lp)=0 then
        b_loi:='loi:Nhap so phuc hoi, so phi cho muc: '||trim(to_char(dk_tu(b_lp),b_fm))||':loi'; return;
    end if;
    if dk_vu(b_lp)=0 then dk_vu(b_lp):=1; end if;
    if dk_tien(b_lp)=0 then dk_tien(b_lp):=dk_bth(b_lp); end if;
end loop;
b_i1:=FKH_ARR_TONG(dk_phi);
if b_i1<>b_ttoan then b_loi:='loi:Sai tong phi:loi'; return; end if;
if b_ma_nt<>'VND' then b_tp:=2; end if;
select so_hd,nbh,kieu,pt,0,tl_thue,0,nbhC bulk collect into
    nbh_so_hd,nbh_ma,nbh_kieu,nbh_pt,nbh_phi,nbh_tl_thue,nbh_thue,nbh_maC
    from tbh_xol_nbh where so_id=b_so_idC;
b_phiC:=b_ttoan;
for b_lp in 1..nbh_ma.count loop
    if b_lp=nbh_ma.count then
        nbh_phi(b_lp):=b_phiC;
    else
        nbh_phi(b_lp):=round(b_ttoan*nbh_pt(b_lp)/100,b_tp); b_phiC:=b_phiC-nbh_phi(b_lp);
    end if;
    if nbh_tl_thue(b_lp)<>0 then nbh_thue(b_lp):=round(nbh_phi(b_lp)*nbh_tl_thue(b_lp)/100,b_tp); end if;
end loop;
for b_lp in 1..dk_tu.count loop
    dc_lh_nv(b_lp):=dk_lh_nv(b_lp);
    dc_tu(b_lp):=dk_tu(b_lp); dc_den(b_lp):=dk_den(b_lp); dc_lan(b_lp):=-1;
    dc_phi(b_lp):=dk_phi(b_lp); dc_vu(b_lp):=dk_vu(b_lp); dc_tien(b_lp):=dk_tien(b_lp);
end loop;
PKH_JS_THAY(dt_ct,'so_ph',b_so_ph);
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PTBH_XOL_PH_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_so_id number; b_so_ph varchar2(20);
    b_nv varchar2(100); b_ma_nt varchar2(5); b_glai number; b_ttoan number;
    b_ngay_ht number; b_so_idD number; b_ngay_bd number; b_ngay_kt number;
    dk_lh_nv pht_type.a_var; dk_tu pht_type.a_num; dk_den pht_type.a_num; dk_lan pht_type.a_var;
    dk_pt pht_type.a_num; dk_bth pht_type.a_num; dk_phi pht_type.a_num; dk_vu pht_type.a_num; dk_tien pht_type.a_num;
    nbh_so_hd pht_type.a_var; nbh_ma pht_type.a_var; nbh_kieu pht_type.a_var;
    nbh_pt pht_type.a_num; nbh_phi pht_type.a_num; nbh_tl_thue pht_type.a_num;
    nbh_thue pht_type.a_num; nbh_maC pht_type.a_var;
    dc_lh_nv pht_type.a_var; dc_tu pht_type.a_num; dc_den pht_type.a_num; dc_lan pht_type.a_num;
    dc_phi pht_type.a_num; dc_vu pht_type.a_num; dc_tien pht_type.a_num;
    dt_ct clob; dt_dk clob;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk);
if b_so_id>0 then
    PTBH_XOL_PH_XOA_XOA(b_nsd,b_so_id,b_loi,'C');
else
    PHT_ID_MOI(b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTBH_XOL_PH_TEST(b_so_id,dt_ct,dt_dk,
    b_so_ph,b_ma_nt,b_glai,b_ttoan,b_ngay_bd,b_ngay_kt,b_ngay_ht,b_nv,b_so_idD,
    dk_lh_nv,dk_tu,dk_den,dk_lan,dk_pt,dk_bth,dk_phi,dk_vu,dk_tien,
    nbh_so_hd,nbh_ma,nbh_kieu,nbh_pt,nbh_phi,nbh_tl_thue,nbh_thue,nbh_maC,
    dc_lh_nv,dc_tu,dc_den,dc_lan,dc_phi,dc_vu,dc_tien,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table tbh_xol_ph:loi';
insert into tbh_xol_ph values(b_so_id,b_ngay_ht,b_so_ph,b_ma_nt,b_glai,b_ttoan,b_ngay_bd,b_ngay_kt,b_nv,b_so_idD,b_nsd);
b_loi:='loi:Loi Table tbh_xol_ph_nv:loi';
for b_lp in 1..dk_tu.count loop
    insert into tbh_xol_ph_nv values(b_so_id,b_lp,dk_lh_nv(b_lp),dk_tu(b_lp),dk_den(b_lp),
        dk_lan(b_lp),dk_pt(b_lp),dk_bth(b_lp),dk_phi(b_lp),dk_vu(b_lp),dk_tien(b_lp));
end loop;
for b_lp in 1..nbh_ma.count loop
    insert into tbh_xol_ph_nbh values(b_so_id,nbh_so_hd(b_lp),nbh_ma(b_lp),nbh_kieu(b_lp),
        nbh_pt(b_lp),nbh_phi(b_lp),nbh_tl_thue(b_lp),nbh_thue(b_lp),nbh_maC(b_lp),b_lp);
end loop;
forall b_lp in 1..dc_tu.count
    insert into tbh_xol_ph_dc values(b_so_id,dc_lh_nv(b_lp),
        dc_tu(b_lp),dc_den(b_lp),dc_lan(b_lp),dc_phi(b_lp),dc_vu(b_lp),dc_tien(b_lp));
insert into tbh_xol_ph_txt values(b_so_id,'dt_ct',dt_ct);
insert into tbh_xol_ph_txt values(b_so_id,'dt_dk',dt_dk);
PTBH_XOL_TH(b_so_idD,b_ngay_ht,dc_lh_nv,dc_tu,dc_den,dc_lan,dc_vu,dc_tien,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTBH_TH_TA_XOL(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('so_id' value b_so_id,'so_ph' value b_so_ph) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
