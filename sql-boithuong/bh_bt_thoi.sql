/*** THU HOI ***/
create or replace function FBH_BT_THOI_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_txt clob;
begin
-- Dan
select count(*) into b_i1 from bh_bt_thoi_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_bt_thoi_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    b_kq:=FKH_JS_GTRIu(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace procedure PBH_BT_THOI_PT(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_so_id_bt number; b_ma_dvi_hd varchar2(10); b_so_id_hd number;
    b_ngay_ht number; b_ma_nt varchar2(5);
    b_tien number; b_tien_qd number; b_thue number; b_thue_qd number;
    a_so_id_dt pht_type.a_num; a_lh_nv pht_type.a_var; a_tien pht_type.a_num;
    a_tien_qd pht_type.a_num; a_thue pht_type.a_num; a_thue_qd pht_type.a_num;
Begin
-- Dan - Phan tich
b_loi:='loi:Thu hoi da xoa:loi';
select so_id_hs,ma_dvi_ql,so_id_hd,ma_nt,tien,tien_qd,thue,thue_qd,ngay_ht
    into b_so_id_bt,b_ma_dvi_hd,b_so_id_hd,b_ma_nt,b_tien,b_tien_qd,b_thue,b_thue_qd,b_ngay_ht
    from bh_bt_thoi where ma_dvi=b_ma_dvi and so_id=b_so_id;
PBH_BT_HS_PT(b_ma_dvi,b_so_id_bt,b_ngay_ht,b_ma_nt,b_tien,b_tien_qd,b_thue,b_thue_qd,
    a_so_id_dt,a_lh_nv,a_tien,a_tien_qd,a_thue,a_thue_qd,b_loi);
if b_loi is not null then return; end if;
for b_lp in 1..a_so_id_dt.count loop
    insert into bh_bt_thoi_pt values(b_ma_dvi,b_so_id,b_so_id_bt,b_ma_dvi_hd,b_so_id_hd,a_so_id_dt(b_lp),b_ngay_ht,
        a_lh_nv(b_lp),b_ma_nt,a_tien(b_lp),a_tien_qd(b_lp),a_thue(b_lp),a_thue_qd(b_lp),b_lp);
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BT_THOI_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_so_id number;
    dt_ct clob; dt_thoi clob; dt_txt clob;
begin
-- Dan - Xem chi tiet thanh toan phi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_loi:='loi:Thu hoi da xoa:loi';
select json_object(so_hs,so_ct returning clob) into dt_ct from bh_bt_thoi where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ma,ten,tien) order by ma returning clob) into dt_thoi
    from bh_bt_thoi_ct where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_bt_thoi_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
select json_object('so_id' value b_so_id,'dt_thoi' value dt_thoi,'dt_ct' value dt_ct,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_THOI_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_so_id_hs number;
    b_so_hs varchar2(30); b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number; b_phong varchar2(10);
    b_dong number:=0; cs_lke clob:='';
    
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hs,ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_so_hs,b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_bt_thoi where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id,ten) returning clob) into cs_lke from
            (select so_id,ten,rownum sott from bh_bt_thoi where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc)
            where sott between b_tu and b_den;
    end if;
elsif b_klk='P' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_bt_thoi where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id,ten) returning clob) into cs_lke from
            (select so_id,ten,rownum sott from bh_bt_thoi where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id desc)
            where sott between b_tu and b_den;
    end if;
elsif trim(b_so_hs) is not null then
    b_so_id_hs:=PBH_BT_HS_SOID(b_ma_dvi,b_so_hs);
    select count(*) into b_dong from bh_bt_thoi where ma_dvi=b_ma_dvi and so_id_hs=b_so_id_hs;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id,ngay_ht) returning clob) into cs_lke from
            (select so_id,ngay_ht,rownum sott from bh_bt_thoi where ma_dvi=b_ma_dvi and so_id_hs=b_so_id_hs order by ngay_ht desc)
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_THOI_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000); b_phong varchar2(10); b_tu number; b_den number;
    b_so_id number; b_ngay_ht number; b_klk varchar2(1); b_trangkt number;
    b_trang number; b_dong number; cs_lke clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_klk,b_trangKt using b_oraIn;
if b_klk ='N' then
    select count(*) into b_dong from bh_bt_thoi where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,rownum sott from bh_bt_thoi where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc) where so_id<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id,ten) returning clob) into cs_lke from
        (select so_id,ten,rownum sott from bh_bt_thoi where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc)
        where sott between b_tu and b_den;
elsif b_klk='P' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_bt_thoi where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,rownum sott from bh_bt_thoi where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id desc) where so_id<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id,ten) returning clob) into cs_lke from
        (select so_id,ten,rownum sott from bh_bt_thoi where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id desc) 
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_THOI_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; r_hd bh_bt_thoi%rowtype;
begin
select count(*) into b_i1 from bh_bt_thoi where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
b_loi:='loi:Chung tu dang xu ly:loi';
select * into r_hd from bh_bt_thoi where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sql%rowcount=0 then return; end if;
if b_nsd<>r_hd.nsd then b_loi:='loi:Khong sua, xoa chung tu nguoi khac:loi'; return; end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,r_hd.ngay_ht,'BH','BT');
if b_loi is not null then return; end if;
if r_hd.so_id_kt>0 then
    PBH_KT_TD_XOA(b_ma_dvi,r_hd.so_id_kt,b_loi);
    if b_loi is not null then return; end if;
end if;
if r_hd.kh_thu='C' then
	select count(*) into b_i1 from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=r_hd.so_id_hs and ttrang='D' and ngay_qd>r_hd.ngay_ht;
	if b_i1<>0 then b_loi:='loi:Khong sua, xoa chung tu ho so da duyet:loi'; return; end if;
end if;
if FTBH_PS(r_hd.ma_dvi,r_hd.so_id_hd,b_so_id)<>0 then b_loi:='loi:Khong xoa thu hoi da xu ly tai BH:loi'; return; end if;
PBH_TH_DO_XOA_PS(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
PTBH_TH_TA_XOA(b_so_id,0,0,0,b_loi);
if b_loi is not null then return; end if;
delete bh_bt_thoi_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_thoi_pt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_thoi_ct where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_thoi where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_THOI_XOA_XOA:loi'; end if;
end;
/
create or replace procedure PBH_BT_THOI_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi nvarchar2(200); b_i1 number; b_lenh varchar2(1000);
    b_so_id_hs number; b_phong varchar2(10); b_ma_kh varchar2(20); b_ten nvarchar2(500);
    b_tien_qd number; b_thue_qd number; b_tp number; b_nv varchar2(10); b_so_id number;
    b_ngay_ht number; b_so_ct varchar2(20); b_so_hs varchar2(20); b_ma_nt varchar2(5);
    b_tien number; b_thue number; b_ttoan number; b_c_thue varchar2(1); b_t_suat number;
    b_mau varchar2(20); b_seri varchar2(10); b_so_don varchar2(20); b_don varchar2(50):=' ';
    b_ma_thue varchar2(20); b_ten_mua nvarchar2(500);  b_dchi_mua nvarchar2(500); b_kh_thu varchar2(1);
    b_ma_dvi_xl varchar2(10); b_ma_dvi_ql varchar2(10); b_so_id_hd number; b_so_id_dt number;
    a_ma pht_type.a_var; a_ten pht_type.a_nvar; a_tien pht_type.a_num; a_tien_qd pht_type.a_num;
    dt_ct clob; dt_thoi clob;
begin
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_thoi');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_thoi using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_thoi);
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
else
    PBH_BT_THOI_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,so_ct,so_hs,ma_nt,tien,thue,c_thue,t_suat,so_don,ma_thue,ten_mua,dchi_mua,kh_thu');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_so_ct,b_so_hs,b_ma_nt,b_tien,b_thue,b_c_thue,b_t_suat,
    b_so_don,b_ma_thue,b_ten_mua,b_dchi_mua,b_kh_thu using dt_ct;
b_lenh:=FKH_JS_LENH('ma,ten,tien');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma,a_ten,a_tien using dt_thoi;
if b_ngay_ht=0 or b_so_hs=' ' or b_ma_nt=' ' or b_tien<=0 or
    b_c_thue not in('K','C') or b_t_suat<0 or b_thue<0 then
    b_loi:='loi:Sai so lieu nhap:loi'; raise PROGRAM_ERROR;
end if;
b_so_id_hs:=PBH_BT_HS_SOID(b_ma_dvi,b_so_hs);
if b_so_id_hs=0 then b_loi:='loi:Ho so boi thuong da xoa:loi'; end if;
select nv,ma_kh,ten,phong,ma_dvi_xl,ma_dvi_ql,so_id_hd,so_id_dt into
    b_nv,b_ma_kh,b_ten,b_phong,b_ma_dvi_xl,b_ma_dvi_ql,b_so_id_hd,b_so_id_dt
    from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id_hs;
b_kh_thu:=nvl(trim(b_kh_thu),'K');
if b_ma_nt='VND' then
    b_tien_qd:=b_tien; b_thue_qd:=b_thue;
    for b_lp in 1..a_ma.count loop a_tien_qd(b_lp):=a_tien(b_lp); end loop;
else
    if FBH_TT_KTRA(b_ma_nt)<>'C' then b_loi:='loi:Ma ngoai te chua dang ky:loi'; return; end if;
    b_i1:=FBH_TT_TRA_TGTT(b_ngay_ht,b_ma_nt);
    b_tien_qd:=round(b_tien*b_i1,0); b_thue_qd:=round(b_thue*b_i1,0);
    for b_lp in 1..a_ma.count loop a_tien_qd(b_lp):=round(a_tien(b_lp)*b_i1,0); end loop;
end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','BT');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_so_ct) is null then
    b_so_ct:=substr(to_char(b_so_id),3); PKH_JS_THAY(dt_ct,'so_ct',b_so_ct);
end if;
b_loi:='loi:Loi Table BH_BT_THOI:loi';
insert into bh_bt_thoi values(
    b_ma_dvi,b_so_id,b_ngay_ht,b_nv,b_so_hs,b_so_id_hs,b_ma_dvi_xl,b_ma_dvi_ql,b_so_id_hd,b_so_id_dt,
    b_so_ct,b_ma_nt,b_tien,b_thue,b_tien+b_thue,b_tien_qd,b_thue_qd,b_tien_qd+b_thue_qd,
    b_t_suat,b_kh_thu,b_ma_thue,b_ten_mua,b_dchi_mua,' ',' ',b_so_don,b_don,b_ma_kh,b_ten,b_phong,b_nsd,sysdate,0);
for b_lp in 1..a_ma.count loop
    insert into bh_bt_thoi_ct values(b_ma_dvi,b_so_id,b_so_id_hs,a_ma(b_lp),a_ten(b_lp),a_tien(b_lp),a_tien_qd(b_lp),b_lp);
end loop;
insert into bh_bt_thoi_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
if length(dt_thoi)<>0 then
    insert into bh_bt_thoi_txt values(b_ma_dvi,b_so_id,'dt_dk',dt_thoi);
end if;
PBH_BT_THOI_PT(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if FBH_DONG(b_ma_dvi_ql,b_so_id_hd)='D' then
    PBH_TH_DO_THOI(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
end if;
PTBH_TH_TA_THOI(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;

--duong insert vao job
PBH_HD_VAT_JOB_INSERT(b_ma_dvi,b_so_id,'THBT',b_nsd);

select json_object('so_id' value b_so_id,'so_ct' value b_so_ct) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;

/
create or replace procedure PBH_BT_THOI_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi nvarchar2(200); b_so_id number;
begin
-- Dan - Xoa thu hoi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
if b_so_id is null or b_so_id=0 then b_loi:='loi:Nhap SO ID:loi'; raise PROGRAM_ERROR; end if;
PBH_BT_THOI_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--duchq update length email
create or replace procedure PBH_BT_THOI_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(400); cs_lke clob:='';
    b_cmt varchar2(20); b_mobi varchar2(20); b_so_hs varchar2(30); b_email varchar2(100);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number; b_ma_kh varchar2(20);
begin
-- Dan - Tim tam ung qua CMT, mobi, email
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,cmt,mobi,email,so_hs');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_cmt,b_mobi,b_email,b_so_hs using b_oraIn;
if b_ngayd in (0,30000101) then b_ngayd:=b_ngay; end if; 
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_so_hs:=nvl(trim(b_so_hs),' ');
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
    select count(*) into b_dong from bh_bt_thoi where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and ngay_ht between b_ngayD and b_ngayC 
    and nsd=b_nsd and b_so_hs in (' ',so_hs);
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hs,ten,so_id) order by ngay_ht desc returning clob) into cs_lke
        from bh_bt_thoi where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and ngay_ht between b_ngayD and b_ngayC 
        and nsd=b_nsd and b_so_hs in (' ',so_hs);
elsif b_ngayD between b_ngay and 30000101 then
    select count(*) into b_dong from bh_bt_thoi where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC 
    and nsd=b_nsd and b_so_hs in (' ',so_hs);
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hs,ten,so_id) order by ngay_ht desc returning clob) into cs_lke
        from bh_bt_thoi where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC 
        and nsd=b_nsd and b_so_hs in (' ',so_hs);
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_THOI_DON(b_ma_dvi varchar2,b_so_id number,b_nv varchar2,b_loi out varchar2)
AS
    b_i1 number; b_kt number; r_hd bh_bt_thoi%rowtype;
    a_gcn_m pht_type.a_var; a_gcn_c pht_type.a_var; a_gcn_s pht_type.a_var;
begin 
-- Dan - Xoa - HDAC
b_loi:=''; b_kt:=0;
select * into r_hd from bh_bt_thoi where ma_dvi=b_ma_dvi and so_id=b_so_id;
if r_hd.so_don is not null then
    b_kt:=b_kt+1;
    a_gcn_m(b_kt):=r_hd.mau; a_gcn_c(b_kt):=r_hd.seri; a_gcn_s(b_kt):=r_hd.so_don;
    if trim(a_gcn_m(b_kt)) is not null and trim(a_gcn_c(b_kt)) is not null or trim(a_gcn_s(b_kt)) is not null then 
      PHD_PH_DON(b_ma_dvi,b_nv,r_hd.ngay_ht,b_so_id,a_gcn_m,a_gcn_c,a_gcn_s,r_hd.nsd,'',b_loi); 
    end if;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
