create or replace function FBH_QU_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nv varchar2,b_dvi varchar2) return varchar2
as
    b_loi varchar2(100);
begin
-- Dan - Kiem tra quyen xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH',b_nv,'NX');
if b_loi is null then
    if (b_dvi is null or b_dvi=b_ma_dvi) then
        b_loi:=FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH',b_nv,'X');
    else
        b_loi:=FHT_MA_NSD_DVI(b_ma_dvi,b_nsd,'BH',b_nv,'X',b_dvi);
    end if;
    if b_loi<>'C' then b_loi:='loi:Khong duoc xem:loi'; end if;
end if;
return b_loi;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_KH_SO_TT_NV(b_nv varchar2,b_nv_tu out varchar2)
AS
begin
-- Dan - Tra nghiep vu tuong ung
select nvl(min(nv_tu),b_nv) into b_nv_tu from bh_kh_so_tt_nv where nv=b_nv;
end;
/
CREATE OR REPLACE procedure FBH_KH_SO_TA(b_ma_dvi varchar2,b_nv varchar2,b_ngay_ht number,b_kq out varchar2)
AS
    b_stt number; b_nam number;
begin
-- Dan - Tra so tai
b_nam:=round(b_ngay_ht,10000);
PBH_KH_SO_TT(b_ma_dvi,'TA',b_nv,b_nam,b_stt);
b_kq:=trim(to_char(b_stt))||'/TA-'||b_nv||'/'||substr(trim(to_char(b_nam)),3);
end;
/
CREATE OR REPLACE procedure FBH_KH_SO_TADC(b_ma_dvi varchar2,b_nv varchar2,b_ngay_ht number,b_kq out varchar2)
AS
    b_stt number; b_nam number;
begin
-- Dan - Tra so tai
b_nam:=round(b_ngay_ht,10000);
PBH_KH_SO_TT(b_ma_dvi,'TA_DC',b_nv,b_nam,b_stt);
b_kq:=trim(to_char(b_stt))||'/TA_DC-'||b_nv||'/'||substr(trim(to_char(b_nam)),3);
end;
/
create or replace procedure PBH_KH_SO_TT(b_ma_dvi varchar2,b_loai varchar2,b_nv varchar2,b_nam number,b_kq out number)
AS
    PRAGMA AUTONOMOUS_TRANSACTION;
begin
-- Dan - Tra so thu tu theo nghiep vu, nam
select count(*) into b_kq from bh_kh_so_tt where ma_dvi=b_ma_dvi and loai=b_loai and nv=b_nv and nam=b_nam;
if b_kq=0 then
    b_kq:=1;
    insert into bh_kh_so_tt values(b_ma_dvi,b_loai,b_nv,b_nam,1);
else
    select stt into b_kq from bh_kh_so_tt where ma_dvi=b_ma_dvi and loai=b_loai and nv=b_nv and nam=b_nam for update wait 10;
	if sql%rowcount<>0 then
		b_kq:=b_kq+1;
		update bh_kh_so_tt set stt=b_kq where ma_dvi=b_ma_dvi and loai=b_loai and nv=b_nv and nam=b_nam;
	else
		b_kq:=0;
	end if;
end if;
commit;
exception when others then rollback; b_kq:=0;
end;
/
create or replace procedure PBH_KH_SO_HD
	(b_ma_dvi varchar2,b_loai varchar2,b_nv varchar2,b_nhom varchar2,b_nam number,b_phong varchar2,b_so_hd out varchar2)
AS
	b_stt number; b_nv_tu varchar2(20); b_nam_c varchar2(2);
begin
-- Dan - Tra so hop dong(HD,GCN), chao phi(CP), so ho so boi thuong(BT)
b_so_hd:='';
PBH_KH_SO_TT_NV(b_nv,b_nv_tu);
if b_nv_tu is null and b_nhom is null then return; end if;
if trim(b_nhom) is null then
	PBH_KH_SO_TT(b_ma_dvi,b_loai,b_nv_tu,b_nam,b_stt);
else
	if b_nv_tu is null then b_nv_tu:=b_nhom; else b_nv_tu:=b_nv_tu||'.'||b_nhom; end if;
	PBH_KH_SO_TT(b_ma_dvi,b_loai,b_nv_tu,b_nam,b_stt);
end if;
b_nam_c:=substr(trim(to_char(b_nam)),3);
b_so_hd:=trim(to_char(b_stt))||'/'||b_nam_c||'/'||b_loai||'-'||b_nv_tu||'/'||b_ma_dvi;
if b_phong is not null then b_so_hd:=b_so_hd||'-'||b_phong; end if;
b_so_hd:=trim(b_so_hd);
end;
/
create or replace procedure PBH_KH_SO_BS(b_ma_dvi varchar2,b_so_id_d number,b_nam number,b_so_bs out varchar2)
AS
    b_so_hd varchar2(50); b_i1 number:=1; b_stt number;
begin
-- Dan - Tra so sua doi bo sung
select so_hd into b_so_hd from bh_hd_goc where ma_dvi=b_ma_dvi and so_id_d=b_so_id_d;
select count(*) into b_stt from bh_hd_goc where ma_dvi=b_ma_dvi and so_id_d=b_so_id_d and kieu_hd='B';
while b_i1<>0 loop
     b_stt:=b_stt+1;
     b_so_bs:='BS'||trim(to_char(b_stt))||'/'||b_so_hd;
     select count(*) into b_i1 from bh_hd_goc where ma_dvi=b_ma_dvi and so_hd=b_so_bs;
end loop;
end;
/
create or replace procedure PBH_KH_SO_SU(b_ma_dvi varchar2,b_so_id_d number,b_nam number,b_so_bs out varchar2)
AS
    b_so_hd varchar2(50); b_i1 number:=1; b_stt number;
begin
-- Dan - Tra so sua doi bo sung
select so_hd into b_so_hd from bh_hd_goc where ma_dvi=b_ma_dvi and so_id_d=b_so_id_d;
select count(*) into b_stt from bh_hd_goc where ma_dvi=b_ma_dvi and so_id_d=b_so_id_d and kieu_hd='S';
while b_i1<>0 loop
     b_stt:=b_stt+1;
     b_so_bs:='SU'||trim(to_char(b_stt))||'/'||b_so_hd;
     select count(*) into b_i1 from bh_hd_goc where ma_dvi=b_ma_dvi and so_hd=b_so_bs;
end loop;
end;
/
create or replace function FBH_KH_SO_KEM(b_ma_dvi varchar2,b_so_id_g number) return varchar2
AS
    b_i1 number; b_so_hd varchar2(50); b_stt number; b_moi varchar2(50):='';
begin
-- Dan - Tra so sua doi bo sung
b_so_hd:=FBH_HD_GOC_SO_HD(b_ma_dvi,b_so_id_g);
select count(*) into b_stt from (select * from bh_hd_goc where ma_dvi=b_ma_dvi and so_id_g=b_so_id_g) where kieu_hd='K';
while true loop
    b_stt:=b_stt+1;
    b_moi:=trim(to_char(b_stt))||'/KEM['||b_so_hd||']';
    select count(*) into b_i1 from bh_hd_goc where ma_dvi=b_ma_dvi and so_hd=b_moi;
    if b_i1=0 then exit; end if;
end loop;
return b_moi;
end;
/
create or replace function FBH_KH_SO_GD(b_ma_dvi varchar2,b_ma_dvi_bt varchar2,b_so_id_bt number) return varchar2
AS
    b_kq varchar2(50); b_stt number; b_so_hs varchar2(50); b_nv varchar2(50);
begin
-- Dan - Tra so giam dinh
b_so_hs:=FBH_BT_HS_SOHS(b_ma_dvi_bt,b_so_id_bt);
select count(*) into b_stt from bh_bt_gd_hs where ma_dvi=b_ma_dvi_bt and so_id_bt=b_so_id_bt;
if b_ma_dvi<>b_ma_dvi_bt then b_nv:='GDH/'||b_ma_dvi; else b_nv:='GD'; end if;
b_stt:=b_stt+1;
b_kq:=trim(to_char(b_stt))||'/'||b_nv||'/'||b_so_hs;
return b_kq;
end;
/
create or replace procedure PBH_KH_SO_KT
    (b_ma_dvi varchar2,b_nv varchar2,b_ngay number,b_stt out number,b_so_ct out varchar2)
AS
    b_namC varchar2(2); b_nam number;
begin
-- Dan - Tra so chung tu ke toan
b_nam:=PKH_SO_NAM(b_ngay);
PBH_KH_SO_TT(b_ma_dvi,'KTBH',b_nv,b_nam,b_stt);
b_namC:=substr(trim(to_char(b_nam)),3);
b_so_ct:=trim(to_char(b_stt))||'/'||b_namC||'/'||b_nv||'/'||b_ma_dvi;
end;
/
create or replace procedure PBH_KH_TTT_CT_LKE
	(b_ma_dvi varchar2,b_ps varchar2,b_so_id number,cs_lke out pht_type.cs_type)
AS
begin
-- Dan - Xem thong tin them chi tiet chung tu theo nghiep vu,so_id
open cs_lke for select * from bh_kh_ttt_ct where ma_dvi=b_ma_dvi and ps=b_ps and so_id=b_so_id;
end;
/
create or replace procedure PBH_KH_TTT_CT_NH
    (b_ma_dvi varchar2,b_ma_dvi_ql varchar2,b_ps varchar2,b_nv varchar2,b_so_id number,
    a_ma pht_type.a_var,a_nd pht_type.a_nvar,b_loi out varchar2)
AS
    b_loai varchar2(1); a_so pht_type.a_num; b_ten nvarchar2(1000);
begin
-- Dan - Nhap thong tin them chi tiet
if a_ma.count=0 then b_loi:=''; return; end if;
for b_lp in 1..a_ma.count loop
    if a_ma(b_lp) is null or a_nd(b_lp) is null then b_loi:='loi:Nhap sai ma '||a_ma(b_lp)||':loi'; return; end if;
    select loai into b_loai from bh_kh_ttt where ma_dvi=b_ma_dvi and ps=b_ps and nv=b_nv and ma=a_ma(b_lp);
    if b_loai='S' then a_so(b_lp):=to_number(a_nd(b_lp));
    elsif b_loai='N' then a_so(b_lp):=PKH_CNG_SO(a_nd(b_lp));
    else a_so(b_lp):=0;
    end if;
end loop;
for b_lp in 1..a_ma.count loop
    b_ten:=substr(a_nd(b_lp),1,2000);
    insert into bh_kh_ttt_ct values(b_ma_dvi,b_ps,b_nv,b_so_id,0,a_ma(b_lp),b_ten,a_so(b_lp));
end loop;
if trim(b_ma_dvi_ql) is not null and b_ma_dvi<>b_ma_dvi_ql then
    for b_lp in 1..a_ma.count loop
        b_ten:=substr(a_nd(b_lp),1,2000);
        insert into bh_kh_ttt_ct values(b_ma_dvi_ql,b_ps,b_nv,b_so_id,0,a_ma(b_lp),b_ten,a_so(b_lp));
    end loop;
end if;
b_loi:='';
exception when others then null;
end;
/
-- chuclh: db khac file
create or replace procedure PBH_KH_TTT_CT_NH_DT
    (b_ma_dvi varchar2,b_ma_dvi_ql varchar2,b_ps varchar2,b_nv varchar2,b_so_id number,
    a_so_id_dt pht_type.a_num,a_ma pht_type.a_var,a_nd pht_type.a_nvar,b_loi out varchar2)
AS
    b_loai varchar2(1); a_so pht_type.a_num; b_dvi_ta varchar2(10):=FTBH_DVI_TA();
begin
-- Dan - Nhap thong tin them chi tiet
if a_ma.count=0 then b_loi:=''; return; end if;
for b_lp in 1..a_ma.count loop
    b_loi:='loi:Nhap sai ma '||a_ma(b_lp)||':loi';
    if a_ma(b_lp) is null or a_nd(b_lp) is null then return; end if;
    select loai into b_loai from bh_kh_ttt where ma_dvi=b_dvi_ta and ps=b_ps and nv=b_nv and ma=a_ma(b_lp);
    a_so(b_lp):=0;
    if b_loai='S' then a_so(b_lp):=PKH_LOC_CHU_SO(a_nd(b_lp),'T','T');
    elsif b_loai='N' then a_so(b_lp):=PKH_CNG_SO(a_nd(b_lp));
    end if;
end loop;
b_loi:='loi:Loi Table BH_KH_TTT_CT:loi';
for b_lp in 1..a_ma.count loop
    insert into bh_kh_ttt_ct values(b_ma_dvi,b_ps,b_nv,b_so_id,a_so_id_dt(b_lp),a_ma(b_lp),a_nd(b_lp),a_so(b_lp));
end loop;
if b_ma_dvi<>b_ma_dvi_ql then
    for b_lp in 1..a_ma.count loop
        insert into bh_kh_ttt_ct values(b_ma_dvi_ql,b_ps,b_nv,b_so_id,a_so_id_dt(b_lp),a_ma(b_lp),a_nd(b_lp),a_so(b_lp));
    end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
-- chuclh: db khac file
create or replace procedure PBH_KH_TTT_CT_NH_DTg
	(b_ma_dvi varchar2,b_ma_dvi_ql varchar2,b_nv varchar2,b_so_id number,
    a_so_id_dt pht_type.a_num,a_ps pht_type.a_var,a_ma pht_type.a_var,a_nd pht_type.a_nvar,b_loi out varchar2)
AS
    b_loai varchar2(1); a_so pht_type.a_num;
begin
-- Dan - Nhap thong tin them chi tiet cho doi tuong
if a_ma.count=0 then b_loi:=''; return; end if;
for b_lp in 1..a_ma.count loop
    b_loi:='loi:Nhap sai ma '||a_ma(b_lp)||':loi';
    if a_ma(b_lp) is null or a_nd(b_lp) is null then return; end if;
    if instr(a_ma(b_lp),1,1)<>'$' then
        select loai into b_loai from bh_kh_ttt where ma_dvi=b_ma_dvi and ps=a_ps(b_lp) and nv=b_nv and ma=a_ma(b_lp);
        a_so(b_lp):=0;
        if b_loai='S' then a_so(b_lp):=PKH_LOC_CHU_SO(a_nd(b_lp),'T','T');
        elsif b_loai='N' then a_so(b_lp):=PKH_CNG_SO(a_nd(b_lp));
        end if;
    end if;
end loop;
b_loi:='loi:Loi Table BH_KH_TTT_CT:loi';
for b_lp in 1..a_ma.count loop
    insert into bh_kh_ttt_ct values(b_ma_dvi,a_ps(b_lp),b_nv,b_so_id,a_so_id_dt(b_lp),a_ma(b_lp),a_nd(b_lp),a_so(b_lp));
end loop;
if b_ma_dvi<>b_ma_dvi_ql then
    for b_lp in 1..a_ma.count loop
        insert into bh_kh_ttt_ct values(b_ma_dvi_ql,a_ps(b_lp),b_nv,b_so_id,a_so_id_dt(b_lp),a_ma(b_lp),a_nd(b_lp),a_so(b_lp));
    end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_KH_TTT_CT_XOA
	(b_ma_dvi varchar2,b_ma_dvi_ql varchar2,b_ps varchar2,b_so_id number,b_loi out varchar2)
AS
begin
-- Dan - Xoa thong tin them chi tiet
b_loi:='loi:Loi Table KH_TTT_CT:loi';
delete bh_kh_ttt_ct where ma_dvi=b_ma_dvi and ps=b_ps and so_id=b_so_id;
if b_ma_dvi<>b_ma_dvi_ql then
	delete bh_kh_ttt_ct where ma_dvi=b_ma_dvi_ql and ps=b_ps and so_id=b_so_id;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_KH_TTT_CT_KTRA
	(b_ma_dvi varchar2,b_ps varchar2,b_so_id number,b_so_id_dt number,b_ktra out nvarchar2)
AS
	b_i1 number; b_nv varchar2(10); b_loi varchar2(100);
begin
b_loi:='loi:Chua nhap thong tin thong ke:loi';
b_ktra:='';
if b_ps='BT' then b_nv:=FBH_BT_HS_HD_NV(b_ma_dvi,b_so_id);
elsif b_ps='HD' then b_nv:=FBH_HD_NV(b_ma_dvi,b_so_id);
end if;
for b_lp in (select ma,ten from bh_kh_ttt where ma_dvi=b_ma_dvi and ps=b_ps and nv=b_nv and bb='C') loop
	select count(*) into b_i1 from bh_kh_ttt_ct where ma_dvi=b_ma_dvi and ps=b_ps and nv=b_nv
		and so_id=b_so_id and so_id_dt=b_so_id_dt and ma=b_lp.ma;
	if b_i1=0 then b_ktra:=b_lp.ten; return; end if;
end loop;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_KH_TTT_HOI_ND
	(b_ma_dvi varchar2,b_ps varchar2,b_so_id varchar2,b_ma varchar2) return nvarchar2
AS
	b_nd nvarchar2(400);
begin
-- Dan - Tra noi dung cua thong tin them
select max(nd) into b_nd from bh_kh_ttt_ct where ma_dvi=b_ma_dvi and ps=b_ps and so_id=b_so_id and ma=b_ma;
return b_nd;
end;
/
create or replace function FBH_KH_TTT_HOI_SO
	(b_ma_dvi varchar2,b_ps varchar2,b_so_id varchar2,b_ma varchar2) return number
AS
	b_so number;
begin
-- Dan - Tra noi dung dang so
select max(so) into b_so from bh_kh_ttt_ct where ma_dvi=b_ma_dvi and ps=b_ps and so_id=b_so_id and ma=b_ma;
return b_so;
end;
/
create or replace procedure PBH_KH_TTT_LKEj
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,cs_lke out pht_type.cs_type)
AS
	b_loi varchar2(100); b_lenh varchar2(1000); b_ps varchar2(10); b_nv varchar2(10);
begin
-- Dan - Xem thong tin them chung tu theo nghiep vu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH',b_ps,'');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ps,nv');
EXECUTE IMMEDIATE b_lenh into b_ps,b_nv using b_oraIn;
open cs_lke for select * from bh_kh_ttt where ma_dvi=b_ma_dvi and ps=b_ps and nv=b_nv order by bt;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** KHAI BAO LOC ***/
create or replace function FBH_KH_MUC_NVQ(b_nv varchar2) return varchar2
AS
	b_i1 number; b_kq varchar2(10):='';
begin
-- Dan - Tra nghiep vu
b_i1:=instr(b_nv,'_');
if b_i1>1 then b_kq:=substr(b_nv,1,b_i1); end if;
return b_kq;
end;
/
create or replace procedure PBH_KH_MUC_LKE
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nv varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(200); b_nvq varchar2(10);
begin
-- Dan - Liet ke
b_nvq:=FBH_KH_MUC_NVQ(b_nv);
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH',b_nvq,'');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs1 for select * from bh_kh_muc where ma_dvi=b_ma_dvi and nv=b_nv order by ngay DESC,muc,so_id;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KH_MUC_CT
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nv varchar2,b_so_id number,cs_ct out pht_type.cs_type,cs_dk out pht_type.cs_type)
AS
	b_loi varchar2(200); b_nvq varchar2(10);
begin
-- Dan - Xem chi tiet
b_nvq:=FBH_KH_MUC_NVQ(b_nv);
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH',b_nvq,'');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs_ct for select * from bh_kh_muc where ma_dvi=b_ma_dvi and so_id=b_so_id;
open cs_dk for select * from bh_kh_muc_ct where ma_dvi=b_ma_dvi and so_id=b_so_id;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KH_MUC_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nv varchar2,b_so_id in out number,b_ngay number,b_muc varchar2,
	dk_ma in out pht_type.a_var,dk_tu_nd pht_type.a_var,dk_tu_dk pht_type.a_var,
	dk_den_nd pht_type.a_var,dk_den_dk pht_type.a_var,dk_loai pht_type.a_var)
AS
	b_loi varchar2(200); b_nvq varchar2(10); b_i1 number;
begin
-- Dan - Nhap
b_nvq:=FBH_KH_MUC_NVQ(b_nv);
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH',b_nvq,'MQ');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay is null or b_ngay<=0 then b_loi:='loi:Nhap ngay:loi'; return; end if;
PKH_MANG(dk_ma);
for b_lp in 1..dk_ma.count loop
	b_loi:='loi:Sai chi tiet dong '||to_char(b_lp)||':loi';
	if (dk_ma(b_lp) is null or dk_loai(b_lp) is null or dk_loai(b_lp) not in('C','S','N','T')
		or trim(dk_tu_nd(b_lp)) is null and dk_tu_dk(b_lp) is not null)
		or (trim(dk_tu_nd(b_lp)) is not null and dk_tu_dk(b_lp) is null)
		or (trim(dk_den_nd(b_lp)) is null and dk_den_dk(b_lp) is not null)
		or (trim(dk_den_nd(b_lp)) is not null and dk_den_dk(b_lp) is null)
		or (dk_tu_dk(b_lp) is not null and 
			(dk_tu_dk(b_lp) not in('=','<','>','<=','>=','<>','~','*')
			or (dk_loai(b_lp)<>'C' and dk_tu_dk(b_lp)in('*','~'))))
		or (dk_den_dk(b_lp) is not null and 
			(dk_den_dk(b_lp) not in('=','<','>','<=','>=','<>','~','*')
			or (dk_loai(b_lp)<>'C' and dk_den_dk(b_lp)in('*','~'))))
		then raise PROGRAM_ERROR;
	end if;
	if dk_loai(b_lp)='S' then
		if dk_tu_nd(b_lp) is not null then b_i1:=to_number(dk_tu_nd(b_lp)); end if;
		if dk_den_nd(b_lp) is not null then b_i1:=to_number(dk_den_nd(b_lp)); end if;
	elsif dk_loai(b_lp) in('N','T') then
		if dk_tu_nd(b_lp) is not null then b_i1:=PKH_CNG_SO(dk_tu_nd(b_lp)); end if;
		if dk_den_nd(b_lp) is not null then b_i1:=PKH_CNG_SO(dk_den_nd(b_lp)); end if;
	end if;
end loop;
if b_so_id=0 then
	PHT_ID_MOI(b_so_id,b_loi);
	if b_loi is not null then raise PROGRAM_ERROR; end if;
else
	delete bh_kh_muc_ct where ma_dvi=b_ma_dvi and so_id=b_so_id;
	delete bh_kh_muc where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
b_loi:='loi:Loi Table BH_KH_MUC:loi';
insert into bh_kh_muc values(b_ma_dvi,b_so_id,b_nv,b_ngay,b_muc,b_nsd);
b_loi:='loi:Loi Table BH_KH_MUC_CT:loi';
for b_lp in 1..dk_ma.count loop
	insert into bh_kh_muc_ct values(b_ma_dvi,b_so_id,dk_ma(b_lp),dk_tu_nd(b_lp),
		dk_tu_dk(b_lp),dk_den_nd(b_lp),dk_den_dk(b_lp),dk_loai(b_lp));
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KH_MUC_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nv varchar2,b_so_id number)
AS
	b_loi varchar2(200); b_nvq varchar2(10);
begin
-- Dan - Xoa
b_nvq:=FBH_KH_MUC_NVQ(b_nv);
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH',b_nvq,'MQ');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then b_loi:='loi:Nhap so ID:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table bh_kh_muc:loi';
delete bh_kh_muc_ct where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_kh_muc where ma_dvi=b_ma_dvi and so_id=b_so_id;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KH_MUC_DK
    (b_ma_dvi varchar2,b_nv varchar2,b_ngay number,a_dk out pht_type.a_var,a_muc out pht_type.a_var,b_loi out varchar2)
AS
    b_i1 number; b_kt number:=0; b_lenh varchar2(1000); b_ma varchar2(50); b_ngay_m number; b_s varchar2(1000); a_s pht_type.a_var;
begin
-- Dan - Dieu kien muc rui ro
PKH_MANG_KD(a_dk); PKH_MANG_KD(a_muc);
select nvl(max(ngay),0) into b_ngay_m from bh_kh_muc where ma_dvi=b_ma_dvi and nv=b_nv and ngay<=b_ngay;
for r_lp in (select so_id,muc from bh_kh_muc where ma_dvi=b_ma_dvi and nv=b_nv and ngay=b_ngay_m order by muc) loop
    b_kt:=b_kt+1; b_lenh:='';
    for r_lp1 in (select * from bh_kh_muc_ct where ma_dvi=b_ma_dvi and so_id=r_lp.so_id) loop
        if trim(b_lenh) is not null then b_lenh:=b_lenh||' and '; end if;
        b_ma:=trim(r_lp1.ma);
        b_i1:=instr(b_ma,'.');
        if b_i1>0 then b_ma:=substr(b_ma,1,b_i1); end if;
        if r_lp1.loai='C' then
            if r_lp1.tu_nd is not null then
                b_s:=upper(r_lp1.tu_nd);
                if instr(b_s,',')>0 then
                    b_lenh:=b_lenh||'(';
                    PKH_CH_ARR(b_s,a_s);
                    for b_lp in 1..a_s.count loop
                        if (b_lp>1) then b_lenh:=b_lenh||' or '; end if;
                        if r_lp1.tu_dk in('=','<>') then
                            b_lenh:=b_lenh||'upper('||b_ma||')'||r_lp1.tu_dk||''''||a_s(b_lp)||'''';
                        elsif r_lp1.tu_dk='~' then
                            b_lenh:=b_lenh||'upper('||b_ma||') like '''||a_s(b_lp)||'%''';
                        else
                            b_lenh:=b_lenh||'upper('||b_ma||') not like '''||a_s(b_lp)||'%''';
                        end if;
                    end loop;
                    b_lenh:=b_lenh||')';
                else
                    if r_lp1.tu_dk in('=','<>') then
                        b_lenh:=b_lenh||'upper('||b_ma||')'||r_lp1.tu_dk||''''||b_s||'''';
                    elsif r_lp1.tu_dk='~' then
                        b_lenh:=b_lenh||'upper('||b_ma||') like '''||b_s||'%''';
                    else
                        b_lenh:=b_lenh||'upper('||b_ma||') not like '''||b_s||'%''';
                    end if;
                end if;
            end if;
            if r_lp1.den_nd is not null then
                if r_lp1.tu_nd is not null then b_lenh:=b_lenh||' and '; end if;
                b_s:=upper(r_lp1.den_nd);
                if instr(b_s,',')>0 then
                    b_lenh:=b_lenh||'(';
                    PKH_CH_ARR(b_s,a_s);
                    for b_lp in 1..a_s.count loop
                        if (b_lp>1) then b_lenh:=b_lenh||' or '; end if;
                        if r_lp1.den_dk in('=','<>') then
                            b_lenh:=b_lenh||'upper('||b_ma||')'||r_lp1.den_dk||''''||a_s(b_lp)||'''';
                        elsif r_lp1.den_dk='~' then
                            b_lenh:=b_lenh||'upper('||b_ma||') like '''||a_s(b_lp)||'%''';
                        else
                            b_lenh:=b_lenh||'upper('||b_ma||') not like '''||a_s(b_lp)||'%''';
                        end if;
                    end loop;
                    b_lenh:=b_lenh||')';
                else
                    if r_lp1.den_dk in('=','<>') then
                        b_lenh:=b_lenh||'upper('||b_ma||')'||r_lp1.den_dk||''''||b_s||'''';
                    elsif r_lp1.den_dk='~' then
                        b_lenh:=b_lenh||'upper('||b_ma||') like '''||b_s||'%''';
                    else
                        b_lenh:=b_lenh||'upper('||b_ma||') not like '''||b_s||'%''';
                    end if;
                end if;
            end if;
        elsif r_lp1.loai='S' then
            if r_lp1.tu_nd is not null then
                b_lenh:=b_lenh||b_ma||r_lp1.tu_dk||r_lp1.tu_nd;
            end if;
            if r_lp1.den_nd is not null then
                if r_lp1.tu_nd is not null then b_lenh:=b_lenh||' and '; end if;
                b_lenh:=b_lenh||b_ma||r_lp1.den_dk||r_lp1.den_nd;
            end if;         
        elsif r_lp1.loai='N' then
            if r_lp1.tu_nd is not null then
                b_s:=to_char(PKH_CNG_SO(r_lp1.tu_nd));
                b_lenh:=b_lenh||b_ma||r_lp1.tu_dk||b_s;
            end if;
            if r_lp1.den_nd is not null then
                if r_lp1.tu_nd is not null then b_lenh:=b_lenh||' and '; end if;
                b_s:=to_char(PKH_CNG_SO(r_lp1.den_nd));
                b_lenh:=b_lenh||b_ma||r_lp1.den_dk||b_s;
            end if;
        else
            if r_lp1.tu_nd is not null then
                b_s:=''''||to_char(PKH_CNG_NG(r_lp1.tu_nd))||'''';
                b_lenh:=b_lenh||b_ma||r_lp1.tu_dk||b_s;
            end if;
            if r_lp1.den_nd is not null then
                if r_lp1.tu_nd is not null then b_lenh:=b_lenh||' and '; end if;
                b_s:=''''||to_char(PKH_CNG_NG(r_lp1.den_nd))||'''';
                b_lenh:=b_lenh||b_ma||r_lp1.den_dk||b_s;
            end if;
        end if;
    end loop;
    a_dk(b_kt):=b_lenh; a_muc(b_kt):=r_lp.muc;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_KH_MUC_TRA(b_ma_dvi varchar2,b_nv varchar2,b_bang varchar2,b_ngay number,b_muc out varchar2,b_loi out varchar2)
AS
	b_i1 number; b_lenh varchar2(1000); a_dk pht_type.a_var; a_muc pht_type.a_var;
begin
-- Dan - Tra muc rui ro
b_muc:='';
PBH_KH_MUC_DK(b_ma_dvi,b_nv,b_ngay,a_dk,a_muc,b_loi);
if b_loi is not null then return; end if;
for b_lp in 1..a_dk.count loop
	if a_dk(b_lp) is not null then
		b_lenh:='select count(*) from '||b_bang||' where '||a_dk(b_lp);
		EXECUTE IMMEDIATE b_lenh into b_i1;
		if b_i1<>0 then b_muc:=a_muc(b_lp); exit; end if;
	end if;
end loop;
if b_muc is null then
	for b_lp in 1..a_dk.count loop
		if a_dk(b_lp) is null then b_muc:=a_muc(b_lp); exit; end if;
	end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_KH_KSG
    (b_ma_dvi_n varchar2,b_nsd varchar2,b_pas varchar2,b_nv varchar2,b_ma_dvi_hd varchar2,b_so_id number,cs_ct out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tien number:=0; b_ttoan number:=0; b_mh varchar2(200); b_ma_dvi varchar2(20); b_nhom varchar2(10); b_nhomTc varchar2(1);
begin
-- Dan - Chi tiet GCNBH
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi_n,b_nsd,b_pas,'BH','','');
if trim(b_ma_dvi_hd) is null then b_ma_dvi:=b_ma_dvi_n; else b_ma_dvi:=b_ma_dvi_hd; end if;
b_mh:=FKH_KSOAT_TRA(b_ma_dvi,b_so_id);
--LAM SACH
-- if b_nv='HANG' then
--     select nvl(sum(ttoan),0),nvl(sum(tien),0) into b_ttoan,b_tien from bh_hhgcn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
--     open cs_ct for select a.*,b_ttoan ttoan,b_tien tien_bh,b_mh mh from bh_hhgcn a where ma_dvi=b_ma_dvi and so_id=b_so_id;
-- elsif b_nv='NG' then
--     select sum(ttoan),sum(tien) into b_ttoan,b_tien from bh_nguoihd_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
--     open cs_ct for select a.*,b_ttoan ttoan,b_tien tien_bh,b_mh mh from bh_nguoihd a where ma_dvi=b_ma_dvi and so_id=b_so_id;
-- elsif b_nv='PHH' then
--     select sum(ttoan),sum(tien) into b_ttoan,b_tien from bh_phhgcn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
--     open cs_ct for select a.*,b_ttoan ttoan,b_tien tien_bh,b_mh mh from bh_phhgcn a where ma_dvi=b_ma_dvi and so_id=b_so_id;
-- elsif b_nv='PKT' then
--     select sum(ttoan),sum(tien) into b_ttoan,b_tien from bh_pktgcn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
--     open cs_ct for select a.*,b_ttoan ttoan,b_tien tien_bh,b_mh mh from bh_pktgcn a where ma_dvi=b_ma_dvi and so_id=b_so_id;
-- elsif b_nv='PTN' then
--     select sum(ttoan),sum(tien) into b_ttoan,b_tien from bh_ptngcn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
--     open cs_ct for select a.*,b_ttoan ttoan,b_tien tien_bh,b_mh mh from bh_ptngcn a where ma_dvi=b_ma_dvi and so_id=b_so_id;
-- elsif b_nv='2B' then
--     select sum(ttoan),sum(tien) into b_ttoan,b_tien from bh_2b_hdgoc_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
--     open cs_ct for select a.*,b_ttoan ttoan,b_tien tien_bh,b_mh mh from bh_2bhdgoc a where ma_dvi=b_ma_dvi and so_id=b_so_id;
-- elsif b_nv='XE' then
--     select sum(ttoan),sum(tien) into b_ttoan,b_tien from bh_xehdgoc_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
--     open cs_ct for select a.*,b_ttoan ttoan,b_tien tien_bh,b_mh mh from bh_xehdgoc a where ma_dvi=b_ma_dvi and so_id=b_so_id;
-- elsif b_nv='TAU' then
--     select sum(ttoan),sum(tien) into b_ttoan,b_tien from bh_tauhdgoc_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
--     open cs_ct for select a.*,b_ttoan ttoan,b_tien tien_bh,b_mh mh from bh_tauhdgoc a where ma_dvi=b_ma_dvi and so_id=b_so_id;
-- end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;

/
/*** GHEP ***/
create or replace procedure PBH_KH_GHEP_LKE
    (b_ma_dvi_n varchar2,b_nsd_n varchar2,b_pas varchar2,b_ma_dvi varchar2,b_nsd varchar2,b_ngay number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_i1 number;
begin
-- Dan - Ghep File giam dinh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi_n,b_nsd_n,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma_dvi is null or b_nsd is null or b_ngay is null then b_loi:='loi:Nhap nguoi, ngay giam dinh:loi'; raise PROGRAM_ERROR; end if;
b_i1:=b_ngay*1000000;
open cs_lke for select distinct so_id,nd,'' ngay from bh_kh_gd where ma_dvi=b_ma_dvi and pas=b_nsd and so_id>=b_i1 order by so_id desc;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_KH_GIO_LOI(b_gio varchar2) return varchar2
as
    b_kq varchar2(100):='Sai kieu gio'; b_c1 varchar2(1); b_s varchar2(50); b_i1 number;
    a_s pht_type.a_var;
begin
-- dan - 
if trim(b_gio) is null then return ''; end if;
b_i1:=length(b_gio);
for b_lp in 1..b_i1 loop
    b_c1:=substr(b_gio,b_lp,1);
    if instr('0123456789:',b_c1)=0 then return b_kq; end if;
end loop;
PKH_CH_ARR(b_gio,a_s,':');
if a_s.count>2 then return b_kq; end if;
if a_s.count=1 then
    b_s:=a_s(1)||'00';
else
    if length(a_s(2))<2 then
        b_s:='0'||a_s(2);
    else
        b_s:=a_s(2);
        if PKH_LOC_CHU_SO(b_s,'F','F')>59 then return b_kq; end if;
    end if;
    b_s:=a_s(1)||b_s;
end if;
if PKH_LOC_CHU_SO(b_s,'F','F')< 2360 then b_kq:= ''; end if;
return b_kq;
end;
/
create or replace procedure PBH_KH_GIO_DUYET(
	b_ngay date,b_gio_hl varchar2,b_ngay_hl date,b_gio_kt varchar2,b_ngay_kt date,
	b_gio_hlL out varchar2,b_ngay_hlL out date,b_gio_ktL out varchar2,b_ngay_ktL out date)
as
	b_i1 number:=PKH_LOC_CHU_SO(b_gio_hl); b_d date:=trunc(b_ngay); b_gio varchar2(5):=to_char(b_ngay,'hh:mi');
begin
-- Dan - Gio duyet
b_gio_hlL:=b_gio_hl; b_ngay_hlL:=b_ngay_hl;
b_gio_ktL:=b_gio_kt; b_ngay_ktL:=b_ngay_kt;
if b_ngay_hl<b_d then
    b_gio_hlL:=b_gio; b_gio_ktL:=b_gio; b_ngay_hlL:=b_d;
    b_i1:=FKH_KHO_TH(b_ngay_hl,b_ngay_kt);
    if b_i1>0 then
        b_d:=add_months(b_ngay_hl,b_i1)-1;
        if b_d=b_ngay_kt then b_ngay_ktL:=add_months(b_ngay_hlL,b_i1)-1; end if;
    end if;
    if b_ngay_ktL=b_ngay_kt then
        b_i1:=FKH_KHO_NG(b_ngay_hl,b_ngay_kt);
        b_ngay_ktL:=b_ngay_hlL+b_i1;
    end if;
elsif b_i1<>0 and b_i1>PKH_LOC_CHU_SO(b_gio) then
    b_gio_hlL:=b_gio; b_gio_ktL:=b_gio;
end if;
end;
/
create or replace function FBH_KH_AHUONG(
    b_tdoX1 number,b_tdoY1 number,b_bk1 number,b_tdoX2 number,b_tdoY2 number,b_bk2 number) return varchar2
AS
    b_kq varchar2(1):='K'; b_kc number;
begin
-- Dan - Xac dinh anh huong
b_kc:=FKH_KCACH(b_tdoX1,b_tdoY1,b_tdoX2,b_tdoY2,'M')-b_bk1-b_bk2;
if b_kc<0 then b_kq:='C'; end if;
return b_kq;
exception when others then return 'K';
end;
/
create or replace function FBH_KH_ARRc_JS(a_c pht_type.a_clob) return clob
AS
    b_kq clob:='[';
begin
-- Tra chuoi Js cua mang clob
for b_lp in 1..a_c.count loop
    if b_lp>1 then b_kq:=b_kq||','; end if;
    b_kq:=b_kq||a_c(b_lp);
end loop;
b_kq:=b_kq||']';
return b_kq;
end;
/
/*** Gui thong bao ***/
create or replace procedure PKH_GUI_TAO
    (b_ps varchar2,b_so_idG number,b_loai varchar2,b_toi varchar2,b_nd nvarchar2,b_loi out varchar2)
AS
    b_so_id number;
begin
-- Dan - Tao thong bao
PHT_ID_MOI(b_so_id,b_loi);
if b_loi is not null then return; end if;
b_loi:='loi:Loi insert Table kh_gui:loi';
insert into kh_gui values(b_so_id,b_ps,b_so_idG,b_loai,b_toi,b_nd,sysdate);
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
commit;
end;
/
create or replace procedure PKH_GUI_TON(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke ton
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','GUI','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs1 for select * from kh_gui order by so_id;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_GUI_TTRANG(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,b_ttrang out varchar2)
AS
    b_loi varchar2(100); b_i1 number;
begin
-- Dan - Kiem tra da gui chua
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','GUI','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from kh_guiL where so_id=b_so_id;
if b_i1<>0 then
    b_ttrang:='D';
else
    select count(*) into b_i1 from kh_gui where so_id=b_so_id;
    if b_i1<>0 then b_ttrang:='C'; else b_ttrang:='X'; end if;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_GUI_GUI(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number)
AS
	b_loi varchar2(100);
begin
-- Dan - Da gui
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','GUI','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Update Table kh_gui:loi';
insert into kh_guiL select a.*,sysdate from kh_gui a where so_id=b_so_id;
delete kh_gui where so_id=b_so_id;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_GUI_XOA(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2)
AS
    b_loi varchar2(100); b_d date:=sysdate-30;
begin
-- Dan - Xoa thong bao da gui sau 30 ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','GUI','N');
if b_loi is null then
    delete kh_guiL where gui<b_d;
    commit;
end if;
exception when others then rollback;
end;
/
create or replace function FBH_TKEnh(
    b_kieu_kt varchar2,b_ma_kt varchar2,b_kieu_gt varchar2,b_ma_gt varchar2) return varchar2
AS
    b_kq varchar2(1):='';
begin
-- Dan - Thong ke ngan hang khong
if b_kieu_kt in('D','N') and trim(b_ma_kt) is not null then
    select max(ma) into b_kq from bh_tkeNH where instr(b_ma_kt,ma)=1;
end if;
if b_kq is null and b_kieu_gt in('D','N') and trim(b_ma_gt) is not null then
    select max(ma) into b_kq from bh_tkeNH where instr(b_ma_gt,ma)=1;
end if;
if b_kq is not null and b_kq='VN' then b_kq:='101,102'; end if;
return b_kq;
end;
/
-- Tien te
create or replace function FBH_TT_TRA_TGTT(b_ngay number,b_ma_nt varchar2) return number
AS
    b_d1 date; b_d2 date; b_tg number:=1; b_ma_dvi varchar2(20):=FTBH_DVI_TA();
begin
-- Dan - Tra ty gia thuc te
b_d2:=PKH_SO_CDT(b_ngay);
select max(ngay) into b_d1 from tt_tgtt where ma_dvi=b_ma_dvi and ma=b_ma_nt and ngay<=b_d2;
if b_d1 is not null then
    select ty_gia into b_tg from tt_tgtt where ma_dvi=b_ma_dvi and ma=b_ma_nt and ngay=b_d1;
end if;
return b_tg;
end;
/
create or replace function FBH_TT_TGTT_TUNG
    (b_ngay number,b_ma_nt_v varchar2,b_ma_nt_r varchar2) return number
AS
    b_tg_v number; b_tg_r number; b_kq number; b_ma_dvi varchar2(20):=FTBH_DVI_TA();
begin
-- Dan - Tra ty gia tuong ung
if b_ma_nt_v=b_ma_nt_r then b_kq:=1;
else
    if b_ma_nt_v='VND' then b_tg_v:=1; else b_tg_v:=FTT_TRA_TGTT(b_ma_dvi,b_ngay,b_ma_nt_v); end if;
    if b_ma_nt_r='VND' then b_tg_r:=1; else b_tg_r:=FTT_TRA_TGTT(b_ma_dvi,b_ngay,b_ma_nt_r); end if;
    b_kq:=round(b_tg_v/b_tg_r,6);
end if;
return b_kq;
end;
/
create or replace function FBH_TT_VND_QD
    (b_ngay number,b_ma_nt varchar2,b_tien number) return number
AS
    b_kq number; b_tg number; b_ma_dvi varchar2(20):=FTBH_DVI_TA();
begin
-- Dan - Doi ra VND
b_tg:=FTT_TRA_TGTT(b_ma_dvi,b_ngay,b_ma_nt);
b_kq:=round(b_tien*b_tg,0);
return b_kq;
end;
/
create or replace function FBH_TT_USD_QD
    (b_ngay number,b_ma_nt varchar2,b_tien number) return number
AS
    b_tg_usd number; b_kq number; b_tg number; b_ma_dvi varchar2(20):=FTBH_DVI_TA();
begin
-- Dan - Doi ra USD
if b_ma_nt='USD' then b_kq:=b_tien;
else
    b_tg_usd:=FTT_TRA_TGTT(b_ma_dvi,b_ngay,'USD');
    if b_ma_nt='VND' then b_tg:=1; else b_tg:=FTT_TRA_TGTT(b_ma_dvi,b_ngay,b_ma_nt); end if;
    b_kq:=round(b_tien*b_tg/b_tg_usd,2);
end if;
return b_kq;
end;
/
create or replace function FBH_TT_TUNG_QD
    (b_ngay number,b_ma_nt_v varchar2,b_tien_v number,b_ma_nt_r varchar2) return number
AS
    b_tg_v number; b_tg_r number; b_kq number; b_le number; b_ma_dvi varchar2(20):=FTBH_DVI_TA();
begin
-- Dan - Doi ra loai tien tuong ung
if b_ma_nt_v=b_ma_nt_r then b_kq:=b_tien_v;
else
    if b_ma_nt_v='VND' then b_tg_v:=1; else b_tg_v:=FTT_TRA_TGTT(b_ma_dvi,b_ngay,b_ma_nt_v); end if;
    if b_ma_nt_r='VND' then b_tg_r:=1; b_le:=0; else b_tg_r:=FTT_TRA_TGTT(b_ma_dvi,b_ngay,b_ma_nt_r); b_le:=2; end if;
    b_kq:=round(b_tien_v*b_tg_v/b_tg_r,b_le);
end if;
return b_kq;
end;
/
create or replace function FBH_TT_KTRA(b_ma_nt varchar2) return varchar2
AS
    b_kq varchar2(1):='C'; b_ma_dvi varchar2(20):=FTBH_DVI_TA(); b_i1 number;
begin
if b_ma_nt<>'VND' then
    select count(*) into b_i1 from tt_ma_nt where ma_dvi=b_ma_dvi and ma=b_ma_nt;
    if b_i1=0 then b_kq:='K'; end if;
end if;
return b_kq;
end;
/
create or replace procedure PBH_TT_TRA_TGTT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma_nt varchar2(5):=nvl(trim(b_oraIn),' ');
    b_tygia number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_tygia:=FBH_TT_TRA_TGTT(b_ngay,b_ma_nt);
select json_object('tygia' value b_tygia) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TT_NHANG(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
--nam: lay du lieu tu bang theo kh_ma_nhang a Huy
select JSON_ARRAYAGG(json_object(ma,ten) order by ten) into b_oraOut from kh_ma_nhang where ma_dvi=b_ma_dvi;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TT_MA_TK(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma_nh varchar2(200);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ma_nh:=PKH_MA_TENl(b_oraIn);
--nam: lay du lieu tu bang theo kh_ma_nhang a Huy
select JSON_ARRAYAGG(json_object('ma' value ma_tk,'ten' value ma_tk) order by ma_tk) into b_oraOut
    from kh_nh_tk where ma_dvi=b_ma_dvi and ma_nh=b_ma_nh;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_HD_TEN_DT(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return nvarchar2
AS
    b_ten nvarchar2(400); b_nv varchar2(10); b_so_idB number;
begin
-- Dan - Ten doi tuong theo so_id
if b_so_id_dt=0 then return ''; end if;
b_nv:=FBH_HD_NV(b_ma_dvi,b_so_id);
b_so_idB:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id);
if b_nv='PHH' then
    select min(dvi) into b_ten from bh_phh_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
elsif b_nv='PKT' then
    select min(dvi) into b_ten from bh_pkt_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
elsif b_nv='NG' then
    select min(ten) into b_ten from bh_ng_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
elsif b_nv='XE' then
    b_ten:=FBH_XE_BIEN(b_ma_dvi,b_so_idB,b_so_id_dt);
elsif b_nv='2B' then
    b_ten:=FBH_2B_BIEN(b_ma_dvi,b_so_idB,b_so_id_dt);
elsif b_nv='TAU' then
    b_ten:=FBH_TAU_BIEN(b_ma_dvi,b_so_idB,b_so_id_dt);
elsif b_nv='PTN' then
    select min(dtuong) into b_ten from bh_ptn_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
elsif b_nv='HOP' then
    select min(dtuong) into b_ten from bh_hop_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
end if;
return b_ten;
end;
