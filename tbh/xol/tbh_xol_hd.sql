/*** XOL ***/
create or replace function FTBH_XOL_TXT(b_so_id number,b_tim varchar2) return varchar2
AS
    b_kq varchar2(100):=' '; b_i1 number; b_txt clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
select count(*) into b_i1 from tbh_xol_txt where so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
	select txt into b_txt from tbh_xol_txt where so_id=b_so_id and loai='dt_ct';
	b_kq:=FKH_JS_GTRIs(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FTBH_XOL_NV(b_so_id number,b_nv varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_nvX varchar2(100);
begin
-- Dan - Tra nvu ap dung
select nvl(min(nv),' ') into b_nvX from tbh_xol where so_id=b_so_id;
if instr(b_nvX,b_nv)>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FTBH_XOL_SKIEN(
	b_so_id number,b_ngay varchar2:=30000101) return varchar2
AS
    b_kq varchar2(1); b_so_idB number;
begin
-- Dan - Tra co su kien theo nghiep vu nghiep vu
b_so_idB:=FTBH_XOL_SO_IDb(b_so_id,b_ngay);
b_kq:=FTBH_XOL_TXT(b_so_idB,'skien');
b_kq:=nvl(trim(b_kq),'K');
return b_kq;
end;
/
create or replace function FTBH_XOL_NBH(b_so_id number) return varchar2
AS
    b_kq varchar2(20);
begin
-- Dan - Tra so HD qua so ID
select nvl(min(nbh),' ') into b_kq from tbh_xol_nbh where so_id=b_so_id and kieu='C';
return b_kq;
end;
/
create or replace function FTBH_XOL_ID_SO_HD(b_so_id number) return varchar2
AS
    b_kq varchar2(50);
begin
-- Dan - Tra so HD qua so ID
select nvl(min(so_hd),' ') into b_kq from tbh_xol where so_id=b_so_id;
return b_kq;
end;
/
create or replace function FTBH_XOL_HD_SO_ID(b_so_hd varchar2) return number
AS
    b_kq number;
begin
-- Dan - Tra so ID qua so HD
select nvl(min(so_id),0) into b_kq from tbh_xol where so_hd=b_so_hd;
return b_kq;
end;
/
create or replace function FTBH_XOL_SO_IDd(b_so_id number) return number
as
    b_kq number;
begin
-- Dan - Tra so id dau
select nvl(min(so_id_d),0) into b_kq from tbh_xol where so_id=b_so_id;
return b_kq;
end;
/
create or replace function FTBH_XOL_HD_SO_IDd(b_so_hd varchar2) return number
as
    b_kq number;
begin
-- Dan - Tra so id dau
select nvl(min(so_id_d),0) into b_kq from tbh_xol where so_hd=b_so_hd;
return b_kq;
end;
/
create or replace function FTBH_XOL_SO_IDc(b_so_id number) return number
as
    b_kq number:=0; b_so_idD number:=b_so_id;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FTBH_XOL_SO_IDd(b_so_id);
select nvl(max(so_id),0) into b_kq from tbh_xol where so_id_d=b_so_idD;
return b_kq;
end;
/
create or replace function FTBH_XOL_HD_SO_IDc(b_so_hd varchar2) return number
as
    b_kq number; b_so_idD number;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FTBH_XOL_HD_SO_IDd(b_so_hd);
select nvl(max(so_id),0) into b_kq from tbh_xol where so_id_d=b_so_idD;
return b_kq;
end;
/
create or replace function FTBH_XOL_SO_IDb(
    b_so_id number,b_ngay number:=30000101) return number
as
    b_kq number; b_so_idD number;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FTBH_XOL_SO_IDd(b_so_id);
select nvl(max(so_id),0) into b_kq from tbh_xol where so_id_d=b_so_idD and ngay_bd<=b_ngay;
return b_kq;
end;
/
create or replace function FTBH_XOL_HD_SO_IDb(
    b_so_hd varchar2,b_ngay number:=30000101) return number
as
    b_kq number:=0; b_so_idD number;
begin
-- Dan - Tra so id cuoi
b_so_idD:=FTBH_XOL_HD_SO_IDd(b_so_hd);
select nvl(max(so_id),0) into b_kq from tbh_xol where so_id_d=b_so_idD and ngay_bd<=b_ngay;
return b_kq;
end;
/
create or replace function FTBH_XOL_SO_ID_DAU(b_so_id number) return number
AS
    b_so_idD number;
begin
-- Dan - Tra so ID tai dau qua so ID
select nvl(min(so_id_d),0) into b_so_idD from tbh_xol where so_id=b_so_id;
return b_so_idD;
end;
/
create or replace function FTBH_XOL_MA_NT(b_so_id number) return varchar2
AS
    b_kq varchar2(50);
begin
-- Dan - Tra so HD qua so ID
select nvl(min(ma_nt),'VND') into b_kq from tbh_xol where so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure FTBH_XOL_NV_SO_ID(
    b_nv varchar2,b_ngay number,
    a_so_id out pht_type.a_num,a_lh_nv out pht_type.a_var,a_tu out pht_type.a_num,
    a_den out pht_type.a_num,a_tien out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_den number; b_tien number;
begin
-- Dan - Hop dong tai XOL theo nv,ngay(hieu luc)
PKH_MANG_KD_N(a_so_id);
for r_lp in (select distinct so_id_d from tbh_xol where nv=b_nv and b_ngay between ngay_bd and ngay_kt) loop
    for r_lp1 in(select lh_nv,tu,nvl(max(ngay),0) ngay from tbh_xol_sc where so_id=r_lp.so_id_d and ngay<=b_ngay group by lh_nv,tu) loop
        if r_lp1.ngay<>0 then
            select den,tienT into b_den,b_tien from tbh_xol_sc where so_id=r_lp.so_id_d and ngay=r_lp1.ngay and lh_nv=r_lp1.lh_nv and tu=r_lp1.tu;
            if b_tien<>0 then
                b_i1:=a_so_id.count+1;
                a_so_id(b_i1):=r_lp.so_id_d; a_lh_nv(b_i1):=r_lp1.lh_nv; a_tu(b_i1):=r_lp1.tu; a_den(b_i1):=b_den; a_tien(b_i1):=b_tien;
            end if;
        end if;
    end loop;
end loop;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FTBH_XOL_NV_SO_ID:loi'; end if;
end;
/
create or replace procedure PTBH_XOL_KYTT(
    b_so_id number,a_ngay out pht_type.a_num,a_pt out pht_type.a_num)
AS
    b_tien number:=0; a_tien pht_type.a_num;
begin
select ngay,tien BULK COLLECT into a_ngay,a_pt from tbh_xol_kytt where so_id=b_so_id;
if a_ngay.count=1 then a_pt(1):=100;
else
    for b_lp in 1..a_ngay.count loop
        b_tien:=b_tien+a_pt(b_lp);
    end loop;
    if b_tien<>0 then
        for b_lp in 1..a_ngay.count loop
            a_pt(b_lp):=a_pt(b_lp)/b_tien;
        end loop;
    end if;
end if;
end;
/
create or replace procedure PTBH_TH_TA_XOL(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_so_idD number; b_so_idG number; b_ngay_ht number; b_tp number:=0;
    b_bt number:=0; b_nv varchar2(100); b_loai varchar2(1):='G';
    b_nt_phi varchar2(5); b_phi number; b_phiC number; b_thue number; b_thueC number; b_nha_bh varchar2(20);
    a_ngay pht_type.a_num; a_pt pht_type.a_num;
    a_nbh pht_type.a_var; a_phi pht_type.a_num; a_thue pht_type.a_num;
begin
-- Dan - Tong hop phat sinh hop dong
delete tbh_ghep_ps_temp1; delete tbh_ghep_ps_temp2; delete tbh_ps_pbo_temp;
select count(*) into b_i1 from tbh_xol where so_id=b_so_id;
if b_i1<>0 then
    select nv,ngay_ht,so_id_d,so_id_g,ma_nt into b_nv,b_ngay_ht,b_so_idD,b_so_idG,b_nt_phi from tbh_xol where so_id=b_so_id;
    if b_nt_phi<>'VND' then b_tp:=2; end if;
    select nbhC,nvl(sum(pt),0),nvl(sum(phi),0),nvl(sum(thue),0) bulk collect into a_nbh,a_pt,a_phi,a_thue
        from tbh_xol_nbh where so_id=b_so_id group by nbhC;
    insert into tbh_ghep_ps_temp1
        select b_so_id,0,' ',0,0,'X',lh_nv,' ',sum(phi),0,0 from tbh_xol_nv where so_id=b_so_id group by lh_nv;
    if b_so_idG<>0 then
        insert into tbh_ghep_ps_temp1
            select b_so_id,0,' ',0,0,'X',lh_nv,' ',-sum(phi),0,0 from tbh_xol_nv where so_id=b_so_idG group by lh_nv;
    end if;
    for r_lp in(select ma_ta,sum(phi) phi from tbh_ghep_ps_temp1 group by ma_ta having sum(phi)<>0) loop
        b_phi:=r_lp.phi; b_phiC:=b_phi;
        for b_lp in 1..a_nbh.count loop
            if b_lp=a_nbh.count then
                b_i1:=b_phiC;
                b_i2:=round(b_i1*a_thue(b_lp)/a_phi(b_lp),b_tp); --Nam: them tinh CIT
            else
                b_i1:=round(b_phi*a_pt(b_lp)/100,b_tp); b_phiC:=b_phiC-b_i1;
                b_i2:=round(b_i1*a_thue(b_lp)/a_phi(b_lp),b_tp);
            end if;
            insert into tbh_ghep_ps_temp2 values(b_so_id,0,' ',0,0,'X',r_lp.ma_ta,a_nbh(b_lp),b_i1,b_i2,0);
        end loop;
    end loop;
    if b_so_idD<>b_so_id then b_loai:='S'; end if;
    if b_so_idG=0 then PTBH_XOL_KYTT(b_so_id,a_ngay,a_pt); end if;
else
    select count(*) into b_i1 from tbh_xol_ph where so_id=b_so_id;
    if b_so_id=0 then b_loi:='loi:Phuc hoi da xoa:loi'; return; end if;
    select nv,ngay_ht,so_idD,ma_nt into b_nv,b_ngay_ht,b_so_idD,b_nt_phi from tbh_xol_ph where so_id=b_so_id;
    if b_nt_phi<>'VND' then b_tp:=2; end if;
    select nbhC,nvl(sum(pt),0),nvl(sum(phi),0),nvl(sum(thue),0) bulk collect into a_nbh,a_pt,a_phi,a_thue
        from tbh_xol_ph_nbh where so_id=b_so_id group by nbhC;
    for r_lp in(select lh_nv,sum(phi) phi from tbh_xol_ph_nv where so_id=b_so_id group by lh_nv having sum(phi)<>0) loop
        b_phi:=r_lp.phi; b_phiC:=b_phi;
        for b_lp in 1..a_nbh.count loop
            if b_lp=a_nbh.count then
                b_i1:=b_phiC;
            else
                b_i1:=round(b_phi*a_pt(b_lp)/100,b_tp); b_phiC:=b_phiC-b_i1;
                b_i2:=round(b_i1*a_thue(b_lp)/a_phi(b_lp),b_tp);
            end if;
            insert into tbh_ghep_ps_temp2 values(b_so_id,0,' ',0,0,'X',r_lp.lh_nv,a_nbh(b_lp),b_i1,b_i2,0);
        end loop;
    end loop;
    b_so_idG:=1;
end if;
if instr(b_nv,',')>0 then b_nv:=' '; end if;
if b_so_idG<>0 or a_ngay.count=1 then
    for r_lp in (select ma_ta,nha_bh,phi,thue from tbh_ghep_ps_temp2 order by ma_ta) loop
        b_bt:=b_bt+1;
        insert into tbh_ps_pbo_temp values(b_so_idD,0,' ',0,0,b_ngay_ht,'C','X',b_nv,b_loai,'HD_XOL',
            r_lp.ma_ta,r_lp.nha_bh,'X',b_nt_phi,r_lp.phi,r_lp.thue,0);
    end loop;
else
    for r_lp in (select ma_ta,nha_bh,phi,thue from tbh_ghep_ps_temp2 order by ma_ta) loop
        b_phi:=r_lp.phi; b_phiC:=b_phi; b_thue:=r_lp.thue; b_thueC:=b_thue;
        for b_lp in 1..a_ngay.count loop
            if b_lp=a_ngay.count then
                b_i1:=b_phiC; b_i2:=b_thueC;
            else
                b_i1:=round(b_phi*a_pt(b_lp),b_tp); b_phiC:=b_phiC-b_i1;
                b_i2:=round(b_thue*a_pt(b_lp),b_tp); b_thueC:=b_thueC-b_i2;
            end if;
            b_bt:=b_bt+1;
            insert into tbh_ps_pbo_temp values(b_so_idD,0,' ',0,0,a_ngay(b_lp),'C','X',b_nv,b_loai,'HD_XOL',
                r_lp.ma_ta,r_lp.nha_bh,'X',b_nt_phi,b_i1,b_i2,0);
        end loop;
    end loop;
end if;
PTBH_TH_PS_PBO(b_ma_dvi,b_so_id,b_so_id,0,0,b_loi);
if b_loi is not null then return; end if;
PTBH_TH_TA_PS_TON(b_ma_dvi,b_so_id,b_so_id,0,0,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TA_XOL:loi'; end if;
end;
/
create or replace procedure PTBH_XOL_THc(
    b_so_id number,b_ngay number,b_lh_nv varchar2,
    b_tu number,b_den number,b_lan number,b_vu number,b_tien number,b_loi out varchar2)
AS
    b_i1 number; b_ngayD number; b_lanD number; b_vuD number; b_tienD number;
begin
-- Dan - Tong hop
update tbh_xol_sc set lan=lan+b_lan,vu=vu+b_vu,tien=tien+b_tien
	where so_id=b_so_id and lh_nv=b_lh_nv and tu=b_tu and ngay=b_ngay;
if sql%rowcount=0 then
    insert into tbh_xol_sc values(b_so_id,b_lh_nv,b_tu,b_den,b_ngay,b_lan,b_vu,b_tien,0,0,0);
end if;
select nvl(max(ngay),0) into b_ngayD from tbh_xol_sc where so_id=b_so_id and lh_nv=b_lh_nv and tu=b_tu and ngay<b_ngay;
if b_ngayD=0 then
    b_lanD:=0; b_vuD:=0; b_tienD:=0;
else
    select lanT,vuT,tienT into b_lanD,b_vuD,b_tienD from tbh_xol_sc
        where so_id=b_so_id and lh_nv=b_lh_nv and tu=b_tu and ngay=b_ngayD;
end if;
for r_lp in (select * from tbh_xol_sc where so_id=b_so_id and lh_nv=b_lh_nv and tu=b_tu and ngay>b_ngayD) loop
    b_i1:=r_lp.ngay; b_lanD:=b_lanD+r_lp.lan; b_vuD:=b_vuD+r_lp.vu; b_tienD:=b_tienD+r_lp.tien;
    update tbh_xol_sc set lanT=b_lanD,vuT=b_vuD,tienT=b_tienD where so_id=b_so_id and lh_nv=b_lh_nv and tu=b_tu and ngay=b_i1;
end loop;
delete tbh_xol_sc where so_id=b_so_id and lh_nv=b_lh_nv and tu=b_tu and ngay=b_ngay and lan=0 and vu=0 and tien=0;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_XOL_THc:loi'; end if;
end;
/
create or replace procedure PTBH_XOL_TH(
    b_so_id number,b_ngay_bd number,dc_lh_nv pht_type.a_var,
    dc_tu pht_type.a_num,dc_den pht_type.a_num,dc_lan pht_type.a_num,
    dc_vu pht_type.a_num,dc_tien pht_type.a_num,b_loi out varchar2)
AS
begin
for b_lp in 1..dc_tu.count loop
    PTBH_XOL_THc(b_so_id,b_ngay_bd,dc_lh_nv(b_lp),dc_tu(b_lp),dc_den(b_lp),dc_lan(b_lp),dc_vu(b_lp),dc_tien(b_lp),b_loi);
    if b_loi is not null then return; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_XOL_TH:loi'; end if;
end;
/
create or replace function PTBH_XOL_KTRA_SC return varchar2
AS
    b_kq varchar2(100):=''; b_i1 number;
begin
select nvl(max(ngay),0) into b_i1 from tbh_xol_sc where lanT<0 or vuT<0 or tienT<0;
if b_i1<>0 then b_kq:='loi:Qua so ton hop dong XOL ngay '||PKH_SO_CNG(b_i1)||':loi'; end if;
return b_kq;
end;
/
create or replace procedure PTBH_XOL_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number;
begin
-- Dan - Hoi so ID qua so hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FTBH_XOL_HD_SO_ID(b_oraIn);
if b_so_id=0 then b_loi:='loi:So hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_XOL_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ngayD number; b_tu number; b_den number; b_dong number; cs_lke clob;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_tu,b_den using b_oraIn;
select count(*) into b_dong from tbh_xol where ngay_ht>=b_ngayD;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(nv,ngay_bd,so_hd,so_id) order by nv,ngay_bd desc,so_id desc returning clob) into cs_lke from
    (select nv,ngay_bd,so_hd,so_id,rownum sott from tbh_xol where ngay_ht>=b_ngayD order by nv,ngay_bd desc,so_id desc)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_XOL_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_so_hd varchar2(20);
    b_so_id number; b_ngayD number; b_trangKt number; b_tu number; b_den number;
    b_trang number; b_dong number; cs_lke clob;
begin
-- Dan - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngayd,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngayD,b_trangKt using b_oraIn;
select count(*) into b_dong from tbh_xol where ngay_ht>=b_ngayD;
select nvl(min(sott),b_dong) into b_tu from
    (select nv,ngay_bd,so_id,rownum sott from tbh_xol where ngay_ht>=b_ngayD order by nv,ngay_bd desc,so_id desc) where so_id>=b_so_id;
PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
select JSON_ARRAYAGG(json_object(nv,ngay_bd,so_hd,so_id) order by nv,ngay_bd desc,so_id desc returning clob) into cs_lke from
    (select nv,ngay_bd,so_hd,so_id,rownum sott from tbh_xol where ngay_ht>=b_ngayD order by nv,ngay_bd desc,so_id desc)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_XOL_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_so_id number;
    dt_ct clob:=''; dt_dk clob:=''; dt_bh clob:=''; dt_kytt clob:=''; dt_txt clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=nvl(FKH_JS_GTRIn(b_oraIn,'so_id'),0);
if b_so_id=0 then b_loi:='loi:Chon hop dong:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from tbh_xol where so_id=b_so_id;
if b_i1=0 then b_loi:='loi:Hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object(so_hd) into dt_ct from tbh_xol where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(tu,bt) order by bt returning clob) into dt_dk from tbh_xol_nv where so_id=b_so_id;
select JSON_ARRAYAGG(json_object('nbh' value FBH_DTAC_MA_TENl(nbh),bt) order by bt returning clob)
	into dt_bh from tbh_xol_nbh where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ngay,tien) order by ngay) into dt_kytt from tbh_xol_kytt where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt from tbh_xol_txt where so_id=b_so_id;
select json_object('so_id' value b_so_id,'dt_kytt' value dt_kytt,'dt_ct' value dt_ct,
    'dt_dk' value dt_dk,'dt_bh' value dt_bh,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_XOL_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2,b_nh varchar2:='K')
AS
    b_i1 number:=0; b_nsdC varchar2(20); b_so_idD number; b_ngay_ht number;
    dc_lh_nv pht_type.a_var; dc_tu pht_type.a_num; dc_den pht_type.a_num;
    dc_lan pht_type.a_num; dc_vu pht_type.a_num; dc_tien pht_type.a_num;

begin
-- Dan - Xoa
select count(*) into b_i1 from tbh_xol where so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select nsd,ngay_bd,so_id_d into b_nsdC,b_ngay_ht,b_so_idD from tbh_xol where so_id=b_so_id;
if b_nsdC not in(' ',b_nsd) then
    b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return;
end if;
select lh_nv,tu,den,-lan,-vu,-tien bulk collect into dc_lh_nv,dc_tu,dc_den,dc_lan,dc_vu,dc_tien from tbh_xol_dc where so_id=b_so_id;
PTBH_XOL_TH(b_so_idD,b_ngay_ht,dc_lh_nv,dc_tu,dc_den,dc_lan,dc_vu,dc_tien,b_loi);
if b_loi is not null then return; end if;
PTBH_TH_TA_XOA(b_so_id,0,0,0,b_loi);
if b_loi is not null then return; end if;
if b_nh='K' and b_so_idD=b_so_id then
    select count(*) into b_i1 from tbh_xol_ph where so_idD=b_so_id;
    if b_i1<>0 then b_loi:='loi:Da co phuc hoi:loi'; return; end if;
    select count(*) into b_i1 from tbh_ps where so_id=b_so_id and so_id_xl<>0;
    if b_i1<>0 then b_loi:='loi:Da co xu ly thanh toan phi tai XOL:loi'; return; end if;
end if;
delete tbh_xol_txt where so_id=b_so_id;
delete tbh_xol_dc where so_id=b_so_id;
delete tbh_xol_kytt where so_id=b_so_id;
delete tbh_xol_nv where so_id=b_so_id;
delete tbh_xol_nbh where so_id=b_so_id;
delete tbh_xol where so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_XOL_XOA_XOA:loi'; end if;
end;
/
create or replace procedure PTBH_XOL_TEST(
    b_so_id number,dt_ct clob,dt_dk clob,dt_bh clob,dt_kytt clob,
    b_ngay_ht out number,b_so_hd out varchar2,b_kieu_hd out varchar2,b_so_hd_g out varchar2,
    b_ma_nt out varchar2,b_glai out number,b_ttoan out number,b_ngay_bd out number,b_ngay_kt out number,
    b_nv out varchar2,b_so_idG out number,b_so_idD out number,
    dk_lh_nv out pht_type.a_var,dk_tu out pht_type.a_num,dk_den out pht_type.a_num,
    dk_lan out pht_type.a_num,dk_pt out pht_type.a_num,dk_phi out pht_type.a_num,dk_vu out pht_type.a_num,dk_tien out pht_type.a_num,
    nbh_so_hd out pht_type.a_var,nbh_ma out pht_type.a_var,nbh_kieu out pht_type.a_var,
    nbh_pt out pht_type.a_num,nbh_phi out pht_type.a_num,nbh_tl_thue out pht_type.a_num,
    nbh_thue out pht_type.a_num,nbh_maC out pht_type.a_var,
    tt_ngay out pht_type.a_num,tt_tien out pht_type.a_num,
    dc_lh_nv out pht_type.a_var,dc_tu out pht_type.a_num,dc_den out pht_type.a_num,
    dc_lan out pht_type.a_num,dc_phi out pht_type.a_num,dc_vu out pht_type.a_num,dc_tien out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_i3 number; b_pt number:=0; b_kt number; b_tp number:=0; b_txt clob;
    b_lenh varchar2(2000); b_ngay number:=PKH_NG_CSO(sysdate);
    b_2b varchar2(1); b_xe varchar2(1); b_hang varchar2(1); b_phh varchar2(1); b_tau varchar2(1);
    b_pkt varchar2(1); b_ptn varchar2(1); b_nguoi varchar2(1); b_hop varchar2(1); b_nong varchar2(1);
    cu_lh_nv pht_type.a_var; cu_tu pht_type.a_num; cu_den pht_type.a_num;
    cu_lan pht_type.a_num; cu_phi pht_type.a_num; cu_vu pht_type.a_num; cu_tien pht_type.a_num;
begin
-- Dan - Test
b_lenh:=FKH_JS_LENH('ngay_ht,so_hd,kieu_hd,so_hd_g,ma_nt,glai,ttoan,ngay_bd,ngay_kt,xm,xe,hang,phh,pkt,ptn,nguoi,tau,hop,nong');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_so_hd,b_kieu_hd,b_so_hd_g,b_ma_nt,b_glai,b_ttoan,
    b_ngay_bd,b_ngay_kt,b_2b,b_xe,b_hang,b_phh,b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong using dt_ct;
if b_kieu_hd is null or b_kieu_hd not in('G','B') then
    b_loi:='loi:Sai kieu hop dong:loi'; return;
end if;
if b_ngay_bd in(0,30000101) or b_ngay_kt in(0,30000101) or b_ngay_bd>b_ngay_kt then
    b_loi:='loi:Sai hieu luc hop dong:loi'; return;
end if;
if b_kieu_hd='B' and b_so_hd_g=' ' then b_loi:='loi:Nhap hop dong goc:loi'; return; end if;
if b_ma_nt<>'VND' then
    b_loi:='loi:Sai ma nguyen te:loi';
    select 0 into b_i1 from tt_ma_nt where ma=b_ma_nt;
end if;
if b_glai<=0 then b_loi:='loi:Sai muc giu lai:loi'; return; end if;
if b_kieu_hd='B' then
    b_loi:='loi:So cu da xoa:loi';
    select so_id,so_id_d into b_so_idG,b_so_idD from tbh_xol where so_hd=b_so_hd;
    select count(*) into b_i1 from tbh_xol where so_id_g=b_so_idG;
    if b_i1<>0 then b_loi:='loi:Hop dong da bo sung, sua doi doi:loi'; return; end if;
    select count(*) into b_i1 from tbh_xol where so_id_d=b_so_idD;
    b_so_hd:=substr(to_char(b_so_idD),3)||'/'||b_kieu_hd||to_char(b_i1+1);
else
    select count(*) into b_i1 from tbh_xol where so_hd=b_so_hd; --Nam: check trung so hop dong
    if b_i1<>0 then b_loi:='loi:So hop dong da ton tai:loi'; return; end if;
    b_so_idD:=b_so_id; b_so_idG:=0; b_so_hd:=substr(to_char(b_so_id),3);
end if;
b_nv:=FBH_MA_NV_DUNG(b_2b,b_xe,b_hang,b_phh,b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong);
b_lenh:=FKH_JS_LENH('so_hd,nbh,kieu,pt,phi');
EXECUTE IMMEDIATE b_lenh bulk collect into nbh_so_hd,nbh_ma,nbh_kieu,nbh_pt,nbh_phi using dt_bh;
for b_lp in 1..nbh_ma.count loop
    if nbh_ma(b_lp)=' ' or FBH_MA_NBH_HAN(nbh_ma(b_lp))<>'C' then
        b_loi:='loi:Sai nha tai dong: '||to_char(b_lp)||':loi'; return;
    end if;
    if nbh_kieu(b_lp) not in ('C','P') then
        b_loi:='loi:Sai kieu nha tai: '||nbh_ma(b_lp)||':loi'; return;
    end if;
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
    b_pt:=b_pt+nbh_pt(b_lp);
end loop;
if b_pt=0 then b_loi:='loi:Nhap ty le tai:loi'; return; end if;
if b_pt>100 then b_loi:='loi:Tai vuot 100%:loi'; return; end if;
if b_ma_nt<>'VND' then b_tp:=2; end if;
for b_lp in 1..nbh_ma.count loop
    PTBH_PBO_NOP(' ',nbh_ma(b_lp),b_ngay_bd,nbh_phi(b_lp),b_tp,nbh_tl_thue(b_lp),nbh_thue(b_lp),b_loi);
    if b_loi is not null then return; end if;
end loop;
b_lenh:=FKH_JS_LENH('lh_nv,tu,den,lan,pt,phi,vu,tien');
EXECUTE IMMEDIATE b_lenh bulk collect into dk_lh_nv,dk_tu,dk_den,dk_lan,dk_pt,dk_phi,dk_vu,dk_tien using dt_dk;
if dk_tu.count=0 then b_loi:='loi:Nhap dieu khoan:loi'; return; end if;
for b_lp in 1..dk_tu.count loop
    dk_lan(b_lp):=nvl(dk_lan(b_lp),1);
    if dk_lh_nv(b_lp)<>' ' and FBH_MA_LHNV_TAI_NV(dk_lh_nv(b_lp),b_nv)<>'C' then
        b_loi:='loi:Sai loai hinh nghiep vu:loi'; return;
    end if;
    if dk_tu(b_lp)=0 then b_loi:='loi:Nhap muc tu dong '||to_char(b_lp)||':loi'; return; end if;
    if dk_tu(b_lp)>=dk_den(b_lp) then b_loi:='loi:Sai khoang muc '||FKH_SO_Fm(dk_tu(b_lp))||':loi'; return; end if;
    if dk_lan(b_lp)=0 then b_loi:='loi:nhap so lan duoc phuc hoi muc '||FKH_SO_Fm(dk_tu(b_lp))||':loi'; return; end if;
    if dk_vu(b_lp)=0 then dk_vu(b_lp):=1; end if;
    if dk_tien(b_lp)=0 then dk_tien(b_lp):=dk_den(b_lp)-dk_tu(b_lp); end if;
end loop;
b_i1:=FKH_ARR_TONG(dk_phi);
if b_i1<>b_ttoan then b_loi:='loi:Sai tong phi:loi'; return; end if;
if trim(dt_kytt) is not null then
    b_lenh:=FKH_JS_LENH('ngay,tien');
    EXECUTE IMMEDIATE b_lenh bulk collect into tt_ngay,tt_tien using dt_kytt;
    for b_lp in 1..tt_ngay.count loop
        if tt_ngay(b_lp)=0 or tt_tien(b_lp)=0 then
            b_loi:='loi:Loi ky thanh toan dong '||to_char(b_lp)||':loi'; return;
        end if;
    end loop;
    b_i1:=FKH_ARR_TONG(tt_tien);
    if b_i1<>b_ttoan then b_loi:='loi:Sai ky thanh toan va tong phi:loi'; return; end if;
    for b_lp in 1..tt_ngay.count loop
        b_i1:=b_lp+1;
        if b_i1<=tt_ngay.count then
            for b_lp1 in b_i1..tt_ngay.count loop
                if tt_ngay(b_lp)=tt_ngay(b_lp1) then
                    b_loi:='loi:Trung ky thanh toan '||PKH_SO_CNG(tt_ngay(b_lp))||':loi'; return;
                end if;
            end loop;
        end if;
    end loop;
elsif b_kieu_hd='B' then
    select ngay,tien bulk collect into tt_ngay,tt_tien from tbh_xol_kytt where so_id=b_so_id;
    b_i1:=FKH_ARR_TONG(tt_tien);
    if b_i1<>b_ttoan then
        b_i2:=tt_ngay.count+1;
        if FKH_ARR_VTRI_N(tt_ngay,b_ngay)=0 then
            tt_ngay(b_i2):=b_ngay;
        else
            b_i3:=FKH_ARR_MAXn(tt_ngay);
            tt_ngay(b_i2):=PKH_NG_CSO(PKH_SO_CDT(b_i3)+1);
        end if;
        tt_tien(b_i2):=b_ttoan-b_i1;
    end if;
else
    tt_ngay(1):=b_ngay; tt_tien(1):=b_ttoan;
end if;
if b_so_idG=0 then
    for b_lp in 1.. dk_tu.count loop
        dc_lh_nv(b_lp):=dk_lh_nv(b_lp);
        dc_tu(b_lp):=dk_tu(b_lp); dc_den(b_lp):=dk_den(b_lp);
        dc_lan(b_lp):=dk_lan(b_lp); dc_phi(b_lp):=dk_phi(b_lp);
        dc_vu(b_lp):=dk_vu(b_lp); dc_tien(b_lp):=dk_tien(b_lp);
    end loop;
else
    b_loi:='loi:Hop dong cu da xoa:loi';
    select ngay_ht into b_i1 from tbh_xol where so_id=b_so_idG;
    if b_i1>=b_ngay_ht then b_loi:='loi:Sai ngay sua doi:loi'; end if;
    select lh_nv,tu,den,lan,phi,vu,tien bulk collect into cu_lh_nv,cu_tu,cu_den,cu_lan,cu_phi,cu_vu,cu_tien
        from tbh_xol_nv where so_id=b_so_idG;
    b_kt:=0;
    for b_lp in 1..dk_tu.count loop
        b_i1:=0;
        for b_lp1 in 1..cu_tu.count loop
            if dk_lh_nv(b_lp)=cu_lh_nv(b_lp1) and dk_tu(b_lp)=cu_tu(b_lp1) then
                b_i1:=1; exit;
            end if;
        end loop;
        if b_i1<>0 then
            b_kt:=b_kt+1;
            dc_lh_nv(b_kt):=dk_lh_nv(b_lp);
            dc_tu(b_kt):=dk_tu(b_lp); dc_den(b_kt):=dk_den(b_lp);
            dc_lan(b_kt):=dk_lan(b_lp)-cu_lan(b_i1); dc_phi(b_kt):=dk_phi(b_lp)-cu_phi(b_i1);
            dc_vu(b_kt):=dk_vu(b_lp)-cu_vu(b_i1); dc_tien(b_kt):=dk_tien(b_lp)-cu_tien(b_i1);
        end if;
    end loop;
    for b_lp in 1..cu_tu.count loop
        b_i1:=0;
        for b_lp1 in 1..dk_tu.count loop
            if dk_lh_nv(b_lp1)=cu_lh_nv(b_lp) and dk_tu(b_lp1)=cu_tu(b_lp) then
                b_i1:=1; exit;
            end if;
        end loop;
        if b_i1=0 then
            b_kt:=b_kt+1;
            dc_lh_nv(b_kt):=cu_lh_nv(b_lp);
            dc_tu(b_kt):=cu_tu(b_lp); dc_den(b_kt):=cu_den(b_lp);
            dc_lan(b_kt):=-cu_lan(b_lp); dc_phi(b_kt):=-cu_phi(b_lp);
            dc_vu(b_kt):=-cu_vu(b_lp); dc_tien(b_kt):=-cu_tien(b_lp);
        end if;
    end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_XOL_TEST:loi'; end if;
end;
/
create or replace procedure PTBH_XOL_NH(
	b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(1000);
    b_so_id number; b_ngay_ht number; b_so_hd varchar2(20); b_kieu_hd varchar2(1); b_so_hd_g varchar2(20);
    b_ma_nt varchar2(5); b_glai number; b_ttoan number;
    b_ngay_bd number; b_ngay_kt number; b_nv varchar2(100); b_so_idG number; b_so_idD number;
    dk_lh_nv pht_type.a_var; dk_tu pht_type.a_num; dk_den pht_type.a_num; dk_lan pht_type.a_num;
    dk_pt pht_type.a_num; dk_phi pht_type.a_num; dk_vu pht_type.a_num; dk_tien pht_type.a_num;
    nbh_so_hd pht_type.a_var; nbh_ma pht_type.a_var; nbh_kieu pht_type.a_var;
    nbh_pt pht_type.a_num; nbh_phi pht_type.a_num; nbh_tl_thue pht_type.a_num;
    nbh_thue pht_type.a_num; nbh_maC pht_type.a_var;
    tt_ngay pht_type.a_num; tt_tien pht_type.a_num;
    dc_lh_nv pht_type.a_var; dc_tu pht_type.a_num; dc_den pht_type.a_num; dc_lan pht_type.a_num;
    dc_phi pht_type.a_num; dc_vu pht_type.a_num; dc_tien pht_type.a_num;
    dt_ct clob; dt_dk clob; dt_bh clob; dt_kytt clob;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_bh,dt_kytt');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_bh,dt_kytt using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_bh); FKH_JSa_NULL(dt_kytt);
if b_so_id<>0 then
    PTBH_XOL_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi,'C');
else
    PHT_ID_MOI(b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTBH_XOL_TEST(b_so_id,dt_ct,dt_dk,dt_bh,dt_kytt,
    b_ngay_ht,b_so_hd,b_kieu_hd,b_so_hd_g,b_ma_nt,b_glai,b_ttoan,b_ngay_bd,b_ngay_kt,b_nv,b_so_idG,b_so_idD,
    dk_lh_nv,dk_tu,dk_den,dk_lan,dk_pt,dk_phi,dk_vu,dk_tien,
    nbh_so_hd,nbh_ma,nbh_kieu,nbh_pt,nbh_phi,nbh_tl_thue,nbh_thue,nbh_maC,
    tt_ngay,tt_tien,
    dc_lh_nv,dc_tu,dc_den,dc_lan,dc_phi,dc_vu,dc_tien,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table tbh_xol:loi';
insert into tbh_xol values(b_so_id,b_ngay_ht,b_so_hd,b_kieu_hd,b_so_hd_g,
    b_ma_nt,b_glai,b_ttoan,b_ngay_bd,b_ngay_kt,b_nv,b_so_idD,b_so_idG,b_nsd);
for b_lp in 1..dk_tu.count loop
    insert into tbh_xol_nv values(b_so_id,b_lp,dk_lh_nv(b_lp),dk_tu(b_lp),dk_den(b_lp),
        dk_lan(b_lp),dk_pt(b_lp),dk_phi(b_lp),dk_vu(b_lp),dk_tien(b_lp));
end loop;
for b_lp in 1..nbh_ma.count loop
    insert into tbh_xol_nbh values(b_so_id,nbh_so_hd(b_lp),nbh_ma(b_lp),nbh_kieu(b_lp),
        nbh_pt(b_lp),nbh_phi(b_lp),nbh_tl_thue(b_lp),nbh_thue(b_lp),nbh_maC(b_lp),b_lp);
end loop;
forall b_lp in 1..tt_ngay.count
    insert into tbh_xol_kytt values(b_so_id,b_ma_nt,tt_ngay(b_lp),tt_tien(b_lp));
forall b_lp in 1..dc_tu.count
    insert into tbh_xol_dc values(b_so_id,dc_lh_nv(b_lp),
        dc_tu(b_lp),dc_den(b_lp),dc_lan(b_lp),dc_phi(b_lp),dc_vu(b_lp),dc_tien(b_lp));
insert into tbh_xol_txt values(b_so_id,'dt_ct',dt_ct);
insert into tbh_xol_txt values(b_so_id,'dt_dk',dt_dk);
insert into tbh_xol_txt values(b_so_id,'dt_bh',dt_bh);
PTBH_XOL_TH(b_so_idD,b_ngay_bd,dc_lh_nv,dc_tu,dc_den,dc_lan,dc_vu,dc_tien,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:=PTBH_XOL_KTRA_SC();
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTBH_TH_TA_XOL(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('so_id' value b_so_id,'so_hd' value b_so_hd) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_XOL_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Dan - Xoa GCN
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTBH_XOL_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:=PTBH_XOL_KTRA_SC();
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
