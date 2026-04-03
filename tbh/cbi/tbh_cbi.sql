create or replace function FTBH_CBI_KTAI(b_ma_dvi_hd varchar2,b_so_id_hd number) return varchar2
AS
    b_kq varchar2(1):='C'; b_i1 number;
begin
-- Dan - Tra da xu ly khong tai
select count(*) into b_i1 from tbh_cbi where ma_dvi_hd=b_ma_dvi_hd and so_id_hd=b_so_id_hd and kieu_xl='K';
if b_i1=0 then
    select count(*) into b_i1 from tbh_tmB_cbi where ma_dviP=b_ma_dvi_hd and so_idP=b_so_id_hd and kieu_xl='K';
end if;
if b_i1<>0 then b_kq:='K'; end if;
return b_kq;
end;
/
create or replace function FTBH_CBI_NGAY(b_so_id number) return number
AS
    b_kq number:=0; b_i1 number; b_i2 number;
begin
-- Dan - Xac dinh ngay cuoi
for r_lp in (select distinct ma_dvi_hd,so_id_hd from tbh_cbi_hd where so_id=b_so_id) loop
    b_i1:=FBH_HD_SO_ID_BS(r_lp.ma_dvi_hd,r_lp.so_id_hd);
    select ngay_ht into b_i2 from bh_hd_goc where ma_dvi=r_lp.ma_dvi_hd and so_id=b_i1;
    if b_kq<b_i2 then b_kq:=b_i2; end if;
end loop;
if b_kq=0 then
    for r_lp in (select distinct ma_dvi_hd,so_id_hd from tbh_cbi where so_id=b_so_id) loop
        b_i1:=FBH_HD_SO_ID_BS(r_lp.ma_dvi_hd,r_lp.so_id_hd);
        select ngay_ht into b_i2 from bh_hd_goc where ma_dvi=r_lp.ma_dvi_hd and so_id=b_i1;
        if b_kq<b_i2 then b_kq:=b_i2; end if;
    end loop;
end if;
return b_kq;
end;
/
create or replace procedure PTBH_CBI_HDTA(b_ma_dvi varchar2,b_so_id number,b_ngay number,
    a_so_id_dt out pht_type.a_num,a_dt_ta out pht_type.a_var,a_so_id_ta out pht_type.a_num)
AS
    b_so_idD number; b_so_idB number; b_kt number:=0; b_i1 number; b_i2 number;
begin
-- Dan -- Tim ghep tai lien quan den 1 hop dong goc
b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
b_so_idB:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,b_ngay);
PBH_HD_DS_DT_ARR(b_ma_dvi,b_so_idB,a_so_id_dt);
PKH_MANG_KD_N(a_so_id_ta);
for b_lp in 1..a_so_id_dt.count loop
    a_dt_ta(b_lp):='K';
end loop;
if FBH_HD_NGAY_KT(b_ma_dvi,b_so_id,b_ngay)>b_ngay then return; end if;
for b_lp in 1..a_so_id_dt.count loop
    for r_lp in (select so_id from tbh_ghep_hd where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_idD and so_id_dt=a_so_id_dt(b_lp)) loop
        b_i1:=FTBH_GHEP_SO_ID_BS(r_lp.so_id,b_ngay);
        if FBH_HD_HU(b_ma_dvi,b_i1)='C' then continue; end if;        
        select count(*) into b_i2 from tbh_ghep_hd where
            so_id=b_i1 and ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_idD and so_id_dt=a_so_id_dt(b_lp);
        if b_i2<>0 then
            for b_lp1 in 1..b_kt loop
                if a_so_id_ta(b_lp1)=b_i1 then b_i1:=0; exit; end if;
            end loop;
            if b_i1<>0 then
                b_kt:=b_kt+1; a_so_id_ta(b_kt):=b_i1; a_dt_ta(b_lp):='C';
            end if;
        end if;
    end loop;
end loop;
end;
/
create or replace procedure PTBH_CBI_NH(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_nv varchar2(10);
begin
-- Dan - Nhap chuan bi ghep tai
PTBH_CBI_XOA(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
select min(nv) into b_nv from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nv is null then b_loi:='loi:Hop dong da xoa:loi'; return; end if;
if b_nv='PHH' then
    PTBH_CBI_NH_PHH(b_ma_dvi,b_so_id,b_loi);
elsif b_nv='PKT' then
    PTBH_CBI_NH_PKT(b_ma_dvi,b_so_id,b_loi);
elsif b_nv='HANG' then
    PTBH_CBI_NH_HANG(b_ma_dvi,b_so_id,b_loi);
elsif b_nv in('XE','TAU','2B','NG') then
    PTBH_CBI_NH_NHd(b_ma_dvi,b_so_id,b_loi);
else
    PTBH_CBI_NH_NHh(b_ma_dvi,b_so_id,b_loi);
end if;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_CBI_NH_NH:loi'; end if;
end;
/
create or replace procedure PTBH_CBI_HU_XOA
    (b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_dvi_ta varchar2(10); b_so_idD number; b_kt number:=0; a_so_id pht_type.a_num;
begin
-- Dan - Xoa huy bao tai
PTBH_TH_TA_XOA(b_so_id,0,0,0,b_loi);
if b_loi is not null then return; end if;
PTBH_CBI_XOA(b_ma_dvi,b_so_id,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_CBI_HU_XOA:loi'; end if;
end;
/
create or replace procedure PTBH_CBI_HU_NH(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_so_id_cbi number:=0; b_so_idD number; b_kieu_goc varchar2(1);
    b_nv varchar2(10); b_ngay_ht number; b_dvi_ta varchar2(10); b_so_hd varchar2(50);
    b_con number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
    a_so_id_dt pht_type.a_num; a_dt_ta pht_type.a_var; a_so_id_ta pht_type.a_num;
begin
-- Dan - Bao tai huy
b_dvi_ta:=FTBH_DVI_TA();
if b_dvi_ta is null then b_loi:=''; return; end if;
PTBH_CBI_HU_XOA(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
b_loi:='loi:Hop dong da xoa:loi';
select FBH_HD_NV_RUT(nv),ngay_hl,so_hd,so_id_d,nt_tien,nt_phi into b_nv,b_ngay_ht,b_so_hd,b_so_idD,b_nt_tien,b_nt_phi
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_con:=FBH_HD_HU_TLE(b_ma_dvi,b_so_id);
if FBH_HD_KIEU_HD(b_ma_dvi,b_so_id,'D') in('G','T') then b_kieu_goc:='G'; else b_kieu_goc:='N'; end if;
PTBH_CBI_HDTA(b_ma_dvi,b_so_id,30000101,a_so_id_dt,a_dt_ta,a_so_id_ta);
if a_so_id_ta.count<2 then
    for b_lp in 1..a_so_id_ta.count loop
        select count(*) into b_i1 from tbh_ghep where so_id=a_so_id_ta(b_lp);
        if b_i1=0 then
            select count(*) into b_i1 from tbh_tm where so_id=a_so_id_ta(b_lp);
        end if;
        if b_i1<>0 then
            PHT_ID_MOI(b_so_id_cbi,b_loi);
            if b_loi is not null then return; end if;
            b_loi:='loi:Loi Table TBH_CBI:loi';
            insert into tbh_cbi values(b_dvi_ta,b_so_id_cbi,b_nv,b_so_hd,'H',' ',b_ngay_ht,'B','C','K',b_ma_dvi,b_so_id,
                b_nt_tien,b_nt_phi,a_so_id_ta(b_lp),'Huy HD '||b_so_hd||' hoan phi '||to_char(b_con)||'%','',sysdate);
        end if;
    end loop;
end if;
PTBH_TH_TA_HU(b_ma_dvi,b_so_id,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_CBI_HU_NH:loi'; end if;
end;
/
create or replace procedure PTBH_CBI_XOA(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_so_idD number;
    a_so_id pht_type.a_num;
begin
-- Dan - Xoa chuan bi ghep tai
select distinct so_id bulk collect into a_so_id from tbh_cbi
    where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id;
forall b_lp in 1..a_so_id.count
    delete tbh_cbi_nbh where so_id=a_so_id(b_lp);
forall b_lp in 1..a_so_id.count
    delete tbh_cbi_hd where so_id=a_so_id(b_lp);
forall b_lp in 1..a_so_id.count
    delete tbh_cbi where so_id=a_so_id(b_lp);
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_CBI_XOA:loi'; end if;
end;
/
create or replace procedure PTBH_CBI(
    a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_so_idB number; a_ma_dviX pht_type.a_var;
begin
-- Dan - Tinh chuan bi ghep
for b_lp in 1..a_ma_dvi.count loop
    a_ma_dviX(b_lp):=a_ma_dvi(b_lp);
    if b_lp>1 then
        b_i1:=b_lp-1;
        for b_lp1 in 1..b_i1 loop
            if a_ma_dvi(b_lp1)=a_ma_dvi(b_lp) and a_so_id(b_lp1)=a_so_id(b_lp) then a_ma_dviX(b_lp):=' '; exit; end if;
        end loop;
    end if;
end loop;
for b_lp in 1..a_ma_dvi.count loop
    if a_ma_dviX(b_lp)=' ' then continue; end if;
    b_so_idB:=FBH_HD_SO_ID_BSd(a_ma_dvi(b_lp),a_so_id(b_lp));
    if b_so_idB=a_so_id(b_lp) then continue; end if;
    for b_lp1 in 1..a_ma_dvi.count loop
        if a_ma_dvi(b_lp1)=a_ma_dvi(b_lp) and a_so_id(b_lp1)=b_so_idB then a_ma_dviX(b_lp):=' '; exit; end if;
    end loop;
end loop;
for b_lp in 1..a_ma_dvi.count loop
    if a_ma_dviX(b_lp)<>' ' then
        PTBH_CBI_XOA(a_ma_dvi(b_lp),a_so_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end if;
end loop;
for b_lp in 1..a_ma_dvi.count loop
    if a_ma_dviX(b_lp)<>' ' then
        PTBH_CBI_NH(a_ma_dvi(b_lp),a_so_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_CBI:loi'; end if;
end;
/
create or replace procedure PTBH_CBI_CBL(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(200); b_lenh varchar2(1000);
    b_nv varchar2(10); b_ngayd number; b_ngayc number;
    b_so_id number; b_kieu_hd varchar2(1);
begin
-- Dan - Tong hop lai chuan bi tai
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','Q');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('nv,ngayd,ngayc');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ngayd,b_ngayc using b_oraIn;
for r_lp in (select ma_dvi,nv,so_id,ttrang,kieu_hd from bh_hd_goc where
    b_nv in('0',nv) and ngay_ht between b_ngayd and b_ngayc order by ngay_ht,ma_dvi,so_id) loop
    if r_lp.ttrang='D' then
        b_so_id:=FBH_HD_SO_ID_DAU(r_lp.ma_dvi,r_lp.so_id); b_kieu_hd:=FBH_HD_KIEU_HD(r_lp.ma_dvi,b_so_id);
        --LAM SACH
--         if not (b_kieu_hd='U' or (b_kieu_hd='K' and (r_lp.nv<>'HANG' or FBH_HH_HD_KEM(r_lp.ma_dvi,b_so_id)='C'))) then
--             PTBH_CBI_NH(r_lp.ma_dvi,b_so_id,b_loi);
--             if b_loi is not null then raise PROGRAM_ERROR; end if;
--         end if;
    end if;
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
