create or replace procedure PHD_HOI_SERI_J
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000); b_loi varchar2(100); b_i1 number;
    b_ngay_ht number; b_l_ct varchar2(1);b_ma_n varchar2(20);b_seri varchar2(10);b_dau number;
begin
-- Lan - Hoi seri cua ma hoa don lan nhap gan nhat va so cuoi + 1 cua lan gan nhat
b_lenh:=FKH_JS_LENH('ngay_ht,l_ct,ma_n');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_l_ct,b_ma_n using b_oraIn;
b_seri:='';b_dau:=0;
select nvl(max(so_id),0) into b_i1 from hd_2 where ma_dvi=b_ma_dvi and ma=b_ma_n
       and so_id in (select so_id from hd_1 where ma_dvi=b_ma_dvi and ngay_ht<=b_ngay_ht and l_ct=b_l_ct);
if b_i1=0 then return; end if;
select min(seri) into b_seri from hd_2 where ma_dvi=b_ma_dvi and so_id=b_i1;
select nvl(max(cuoi),0) into b_dau from hd_2 where ma_dvi=b_ma_dvi and so_id=b_i1;
b_dau:=b_dau+1;
select json_object('seri' value b_seri, 'dau' value b_dau) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHD_HOI_TON_J
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000); b_dong number; b_loi varchar2(100); b_tu number; b_den number;
    b_loai_bp varchar2(1);b_ma_bp varchar2(10); b_loai_n varchar2(2); b_ma_n varchar2(10);b_ma_hdac varchar2(10); cs_lke clob:='';
begin
-- Lan - Liet ke chung tu hoa don
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','NX','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('loai_n,ma_n,ma_hdac');
EXECUTE IMMEDIATE b_lenh into b_loai_n,b_ma_n,b_ma_hdac using b_oraIn;

if b_ma_n is null or b_ma_hdac is null then return; end if;
-- DBCL
if b_loai_n = 'D' then
    b_loai_bp :='D';
    select min(ma) into b_ma_bp from ht_ma_dvi where vp='C';
elsif b_loai_n = 'B' then
    b_loai_bp :='D';
    select ma_dvi into b_ma_bp from ht_ma_phong where ma=b_ma_n;
elsif b_loai_n = 'C' then
    b_loai_bp :='B';
    select phong into b_ma_bp from ht_ma_cb where ma=b_ma_n;
end if;
if b_ma_bp is null then
 b_loi:='loi:Khong tim thay thong tin cap quan ly:loi';
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;

select count(*) into b_dong from hd_sc where loai_bp=b_loai_bp and ma_bp=b_ma_bp and ma = b_ma_hdac;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
    
select JSON_ARRAYAGG(obj returning clob) into cs_lke from
 (select json_object(t.ma_dvi,'loai_bp' value max(t.loai_bp),'ma_bp' value max(t.ma_bp), t.ma, t.seri, t.dau, t.cuoi,'thang' value max(t.thang)) obj from hd_sc t 
         where t.loai_bp=b_loai_bp and ma_bp=b_ma_bp and ma = b_ma_hdac group by t.ma_dvi, t.ma, t.seri, t.dau, t.cuoi);
select json_object('dong' value b_dong, 'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHD_CT_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    cs_1 out pht_type.cs_type,cs_2 out pht_type.cs_type,b_so_id number)
AS
    b_loi varchar2(100);
begin
-- Lan - Xem chi tiet cua 1 CT HD qua ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','NX','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Chung tu da xoa:loi';
open cs_1 for select * from hd_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
open cs_2 for select ma,seri,quyen,dau,cuoi,cuoi-dau+1 as so_luong,gia,(cuoi-dau+1)*gia as tien,ma_tke from hd_2 where ma_dvi=b_ma_dvi and so_id=b_so_id;
exception when others then raise_application_error(-20105,b_loi);
end;
/
create or replace procedure PHD_CT_ID_J
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000); b_loi varchar2(100);b_so_id number; cs_hd1 clob; cs_hd2 clob;
begin
-- Lan - Xem chi tiet cua 1 CT HD qua ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','NX','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id');
EXECUTE IMMEDIATE b_lenh into b_so_id using b_oraIn;
b_loi:='loi:Chung tu khong ton tai:loi';
if b_so_id <1 then raise PROGRAM_ERROR; end if;
b_loi:='loi:Chung tu da xoa:loi';
select json_object(ma_dvi,so_id,so_id_bh,ngay_ht,l_ct,so_ct,'ngay_ct' value to_char(ngay_ct,'yyyymmdd'),ma_cc,loai_n,ma_n,nd,htoan,ngay_nh,nsd) into cs_hd1 from hd_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(obj returning clob) into cs_hd2 from
       (select json_object(ma,seri,quyen,dau,cuoi,'so_luong' value cuoi-dau+1 ,gia,'tien' value (cuoi-dau+1)*gia,ma_tke) obj from hd_2 where ma_dvi=b_ma_dvi and so_id=b_so_id);
select json_object('so_id' value b_so_id,'dt_hd1' value cs_hd1,'dt_hd2' value cs_hd2) into b_oraOut from dual;
exception when others then raise_application_error(-20105,b_loi);
end;
/
create or replace procedure PHD_LKE_ID_J
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000);b_loi varchar2(100); b_tu number; b_den number;
    b_so_id number;b_ngay_ht number;b_klk varchar2(1);
    b_trangkt number;b_trang number;b_dong number; cs_lke clob;
begin
-- Nga - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','NX','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,klk,trangkt,trang,dong');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_klk,b_trangkt,b_trang,b_dong using b_oraIn;
if b_klk ='T' then
    select count(*) into b_dong from hd_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,row_number() over (order by l_ct,so_ct) sott
        from hd_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by l_ct,so_ct) where so_id=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(JSON_OBJECT(a.so_id,a.l_ct,a.so_ct,a.ngay_ct,a.ma_cc,a.loai_n,a.ma_n,a.nd,a.nsd) returning clob) into cs_lke from (select * from (
        select so_id,l_ct,so_ct,ngay_ct,ma_cc,loai_n,ma_n,nd,nsd,row_number() over (order by so_id) sott
            from hd_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by l_ct,so_ct) where sott between b_tu and b_den) a;
else
    select count(*) into b_dong from hd_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd);
    select nvl(min(sott),b_dong) into b_tu from (select so_id,row_number() over (order by l_ct,so_ct) sott
        from hd_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd) order by l_ct,so_ct) where so_id=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(JSON_OBJECT(a.so_id,a.l_ct,a.so_ct,a.ngay_ct,a.ma_cc,a.loai_n,a.ma_n,a.nd,a.nsd) returning clob) into cs_lke
        from (select so_id,l_ct,so_ct,ngay_ct,ma_cc,loai_n,ma_n,nd,nsd,row_number() over (order by so_id) sott
            from hd_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd) order by l_ct,so_ct) a where a.sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHD_CT_XOA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2,b_goi varchar2:='')
AS
    b_loi_x varchar2(100);b_ngay_ht number;b_c10 varchar2(10);b_l_ct varchar2(1);b_htoan varchar2(1);
    b_ten_sv varchar2(50);b_ten_db varchar2(50);b_ten_dbo varchar2(50);b_i1 number;b_i2 number;b_i3 number;b_c1 varchar2(1);
    b_ten_sv_1 varchar2(50);b_ten_db_1 varchar2(50);b_ten_dbo_1 varchar2(50);b_loai_nh varchar2(1);b_ma_nh varchar2(20);b_thang number;
begin
---Lan--Xoa ctu hoa don---
if b_goi is null or b_goi='' then
    select so_id_bh into b_i1 from hd_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 then b_loi:='loi:Khong xoa chung tu ket xuat tu nghiep vu:loi'; return; end if;
end if;
--Lay thong tin ctu cu
select ngay_ht,htoan,nsd,l_ct,loai_n,ma_n into b_ngay_ht,b_htoan,b_c10,b_l_ct,b_loai_nh,b_ma_nh
       from hd_1 where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sqlcode<>0 or sql%rowcount<>1 then
    b_loi:='loi:Chung tu dang xu ly:loi';
    return;
end if;
if b_c10 is not null and b_nsd<>b_c10 then
    b_loi:='loi:Khong xoa chung tu nguoi khac:loi';
    return;
end if;
b_thang:=to_number(substr(to_char(b_ngay_ht),1,6));
--Xoa hd_1
delete hd_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
--Tong hop nguoc lai ctu tu ngay xoa
if b_htoan='H' then
    delete temp_3;
    insert into temp_3(c1,c2,c3,c4,c5,c6) select distinct loai_x,ma_x,loai_n,ma_n,ma,seri from hd_3 where ma_dvi=b_ma_dvi and so_id=b_so_id;
    for b_lp in (select c1,c2,c3,c4,c5,c6 from temp_3 order by c1,c2,c3,c4,c5,c6) loop
        delete temp_1; insert into temp_1(n1) select distinct thang from hd_sc where ma_dvi=b_ma_dvi and thang>=b_thang
            and loai_bp=b_lp.c1 and ma_bp=b_lp.c2 and ma=b_lp.c5 and seri=b_lp.c6;
        delete temp_2; insert into temp_2(n1) select distinct thang from hd_sc where ma_dvi=b_ma_dvi and thang>=b_thang
            and loai_bp=b_lp.c3 and ma_bp=b_lp.c4 and ma=b_lp.c5 and seri=b_lp.c6;
        for b_lop in (select dau,cuoi from hd_3 where ma_dvi=b_ma_dvi and so_id=b_so_id and nvl(loai_x,'*')=nvl(b_lp.c1,'*')
            and nvl(ma_x,'*')=nvl(b_lp.c2,'*') and nvl(loai_n,'*')=nvl(b_lp.c3,'*') and nvl(ma_n,'*')=nvl(b_lp.c4,'*')
            and ma=b_lp.c5 and seri=b_lp.c6 order by dau,cuoi) loop
            if b_l_ct='N' then
				for b_lpn in (select n1 from temp_2 order by n1) loop
                select max(nvl(dau,0)) into b_i3 from hd_sc where ma_dvi=b_ma_dvi and loai_bp=b_lp.c3 and ma_bp=b_lp.c4
                and ma=b_lp.c5 and seri=b_lp.c6 and thang=b_lpn.n1;
                if b_i3=0 then  b_loi:='loi:Xoa chung tu trinh tu:loi';raise PROGRAM_ERROR;  return; end if;

                PHD_CT_TH_XUAT(b_ma_dvi,b_lpn.n1,b_lp.c3,b_lp.c4,b_lp.c5,b_lp.c6,b_lop.dau,b_lop.cuoi,b_loi);
                    if b_loi is not null then return; end if;
                end loop;
            elsif b_l_ct='X' then
                for b_lpn in (select n1 from temp_1 order by n1) loop
                    PHD_CT_TH_NH(b_ma_dvi,b_lpn.n1,b_lp.c1,b_lp.c2,b_lp.c5,b_lp.c6,b_lop.dau,b_lop.cuoi,b_loi);
                    if b_loi is not null then return; end if;
                end loop;
            else
                for b_lpn in (select n1 from temp_1 order by n1) loop
                    PHD_CT_TH_NH(b_ma_dvi,b_lpn.n1,b_lp.c1,b_lp.c2,b_lp.c5,b_lp.c6,b_lop.dau,b_lop.cuoi,b_loi);
                    if b_loi is not null then return; end if;
                end loop;
                if b_loai_nh<>'D' or (b_loai_nh='D' and b_ma_dvi=b_ma_nh) then
                    for b_lpn in (select n1 from temp_2 order by n1) loop
                        PHD_CT_TH_XUAT(b_ma_dvi,b_lpn.n1,b_lp.c3,b_lp.c4,b_lp.c5,b_lp.c6,b_lop.dau,b_lop.cuoi,b_loi);
                        if b_loi is not null then return; end if;
                    end loop;
                end if;
            end if;
        end loop;
        --Xoa cac ban ghi phat sinh trong so cai khi xoa ctu
        select nvl(max(dau),0) into b_i1 from hd_2 where ma_dvi=b_ma_dvi and ma=b_lp.c5 and seri=b_lp.c6
            and so_id in (select so_id from hd_1 where ma_dvi=b_ma_dvi and to_number(substr(to_char(ngay_ht),1,6))=b_thang);
        if b_i1=0 then delete hd_sc where ma_dvi=b_ma_dvi and ma=b_lp.c5 and seri=b_lp.c6 and thang=b_thang; end if;
    end loop;
end if;
--Xoa hd_2,hd_3
delete hd_2 where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete hd_3 where ma_dvi=b_ma_dvi and so_id=b_so_id;
--
if b_loai_nh='D' and b_l_ct='C' and b_ma_dvi<>b_ma_nh then
   select ten_sv,ten_db,ten_dbo into b_ten_sv,b_ten_db,b_ten_dbo from ht_ma_dvi where ma=b_ma_dvi;
   select ten_sv,ten_db,ten_dbo into b_ten_sv_1,b_ten_db_1,b_ten_dbo_1 from ht_ma_dvi where ma=b_ma_nh;
   if (upper(b_ten_db)=upper(b_ten_db_1) and upper(b_ten_dbo)=upper(b_ten_dbo_1)) then
        select count(*) into b_i1 from hd_1 where ma_dvi=b_ma_nh and so_id=b_so_id;
        if b_i1>0 then
            select htoan into b_c1 from hd_1 where ma_dvi=b_ma_nh and so_id=b_so_id;
            if b_c1='H' then
                b_loi:='loi:Chung tu tu dong da hach toan:loi';
                return;
            else
                PHD_CT_XOA_XOA (b_ma_nh,'',b_so_id,b_loi_x);
                if b_loi_x is not null then b_loi:=b_loi_x; return; end if;
            end if;
       end if;
    end if;
end if;
end;
/
create or replace procedure PHD_CT_XOA_J
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_lenh varchar2(1000); b_loi varchar2(100);b_ngay_ht number; b_so_id number;
begin
---Lan--Xoa ctu hoa don---
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','NX','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id');
EXECUTE IMMEDIATE b_lenh into b_so_id using b_oraIn;
select ngay_ht into b_ngay_ht from hd_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'HD','AL');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PHD_CT_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
if b_loi is not null then rollback;raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; raise_application_error(-20105,b_loi);
end;
/
create or replace procedure PHD_CT_SUA_SUA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number,b_htoan varchar2,
    b_so_id in out number,b_l_ct varchar2,b_so_ct varchar2,b_ngay_ct date,b_ma_cc varchar2,b_loai_nh varchar2,b_ma_nh varchar2,b_nd nvarchar2,
    a_ma pht_type.a_var,a_seri pht_type.a_var,a_quyen pht_type.a_var,a_dau pht_type.a_num,a_cuoi pht_type.a_num,a_tke pht_type.a_var,a_gia pht_type.a_num,b_loi out varchar2)
as
    b_c2 varchar2(2);b_c10 varchar2(10);b_dl varchar2(10);b_i1 number;b_i2 number;b_c1 varchar2(1);
    b_ten_sv varchar2(50);b_ten_db varchar2(50);b_ten_dbo varchar2(50);b_so_id_bh number;b_loai_nh_c varchar2(1);b_ma_nh_c varchar2(20);
    b_ten_sv_1 varchar2(50);b_ten_db_1 varchar2(50);b_ten_dbo_1 varchar2(50);b_htoan_c varchar2(1);b_thang number;
    b_ma_ac varchar2(20); b_seri_ac varchar2(20);
begin
---Lan--Sua ctu hoa don---
--Lay thong tin hd_1
select nsd,ngay_ht,so_id_bh,l_ct,loai_n,ma_n into b_c10,b_i1,b_so_id_bh,b_c1,b_loai_nh_c,b_ma_nh_c from hd_1
where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nsd<>b_c10 then
    b_loi:='loi:Khong sua chung tu nguoi khac:loi';
    return;
end if;
if b_so_id_bh<>0 then
    b_loi:='loi:Khong sua chung tu ket xuat tu nghiep vu:loi';
    return;
end if;
for b_lp in 1..a_ma.count loop
    if a_dau(b_lp)>a_cuoi(b_lp) then
        b_loi:='loi:So dau phai <= so cuoi:loi';
        return;
    end if;
end loop;
b_thang:=to_number(substr(to_char(b_ngay_ht),1,6));
---Xoa chung tu cu
delete hd_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete hd_2 where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete hd_3 where ma_dvi=b_ma_dvi and so_id=b_so_id;
--Truong hop dieu chuyen sang don vi cung schema
if b_c1='C' and b_loai_nh_c='D' and b_ma_dvi<>b_ma_nh_c then
    select nvl(min(htoan),'*') into b_htoan_c from hd_1 where ma_dvi=b_ma_nh_c and so_id=b_so_id;
    if b_htoan_c='H' then
        b_loi:='loi:Chung tu tu dong da hach toan:loi';
        return;
    else
        if b_htoan_c<>'*' then
            select nvl(ten_db,''),nvl(ten_dbo,'') into b_ten_db,b_ten_dbo from ht_ma_dvi where ma=b_ma_dvi;
            select nvl(ten_db,''),nvl(ten_dbo,'') into b_ten_db_1,b_ten_dbo_1 from ht_ma_dvi where ma=b_ma_nh_c;
            if (upper(b_ten_db)=upper(b_ten_db_1) and upper(b_ten_dbo)=upper(b_ten_dbo_1)) then
                PHD_CT_XOA_XOA(b_ma_nh_c,'',b_so_id,b_loi);
                if b_loi is not null then return; end if;
            end if;
        end if;
    end if;
end if;
---Nhap chung tu moi
PHD_CT_NH_NH (b_ma_dvi,b_nsd,b_ngay_ht,'T',b_so_id,b_so_id_bh,b_l_ct,b_so_ct,b_ngay_ct,
    b_ma_cc,b_loai_nh,b_ma_nh,b_nd,a_ma,a_seri,a_quyen,a_dau,a_cuoi,a_tke,a_gia,b_loi);
if b_loi is not null then return; end if;
update hd_1 set htoan=b_htoan where ma_dvi=b_ma_dvi and so_id=b_so_id;
---Xu ly hd_sc
--delete temp_sl;
for b_lp in 1..a_ma.count loop
    b_ma_ac:=nvl(a_ma(b_lp),' '); b_seri_ac:=nvl(a_seri(b_lp),' ');

    delete hd_sc where ma_dvi=b_ma_dvi and thang>=b_thang and ma=b_ma_ac and seri=b_seri_ac;
    PHD_CT_THL_THL(b_ma_dvi,b_thang,b_loi,0,0,b_ma_ac,b_seri_ac);
    if b_loi is not null then return; end if;
end loop;
b_loi:='';
exception when others then null;
end;
/
create or replace procedure PHD_CT_TH_XUAT
    (b_ma_dvi varchar2,b_thang number,b_loai_bp varchar2,b_ma_bp varchar2,
    b_ma varchar2,b_seri varchar2,b_dau number,b_cuoi number,b_loi out varchar2)
AS
    b_thang_m number;b_dau_cu number;b_cuoi_cu number;
    b_i1 number;b_i2 number;b_c2 varchar2(2);
begin
--Lan--Tong hop xuat hoa don vao so cai--
b_loi:='';
if b_ma is null then
    b_loi:='loi:Nhap ma hoa don, an chi:loi'; return;
end if;
select nvl(max(thang),0) into b_thang_m from hd_sc where ma_dvi=b_ma_dvi
    and loai_bp=b_loai_bp and ma_bp=b_ma_bp and ma=b_ma and seri=b_seri and dau<>0 and thang<=b_thang;
select nvl(max(dau),0) into b_dau_cu from hd_sc where ma_dvi=b_ma_dvi and loai_bp=b_loai_bp
    and ma_bp=b_ma_bp and ma=b_ma and seri=b_seri and dau<=b_dau and cuoi>=b_cuoi and thang=b_thang_m;
if b_dau_cu=0 then
    b_loi:='loi:Khong quan ly '||b_ma||' tu so '||trim(to_char(b_dau))||' den so '||trim(to_char(b_cuoi))||':loi';
    return;
end if;
select cuoi into b_cuoi_cu from hd_sc where ma_dvi=b_ma_dvi and loai_bp=b_loai_bp and ma_bp=b_ma_bp
    and ma=b_ma and seri=b_seri and dau=b_dau_cu and thang=b_thang_m;
if b_thang_m<b_thang then
    insert into hd_sc select b_ma_dvi,b_loai_bp,b_ma_bp,b_ma,b_seri,dau,cuoi,b_thang
        from hd_sc where ma_dvi=b_ma_dvi and thang=b_thang_m and loai_bp=b_loai_bp and ma_bp=b_ma_bp and ma=b_ma and seri=b_seri;
end if;
if b_dau=b_dau_cu and b_cuoi<b_cuoi_cu then
    update hd_sc set dau=b_cuoi+1 where ma_dvi=b_ma_dvi
        and loai_bp=b_loai_bp and ma_bp=b_ma_bp and ma=b_ma and seri=b_seri and dau=b_dau_cu and thang=b_thang;
elsif b_cuoi=b_cuoi_cu and b_dau>b_dau_cu then
    update hd_sc set cuoi=b_dau-1 where ma_dvi=b_ma_dvi
        and loai_bp=b_loai_bp and ma_bp=b_ma_bp and ma=b_ma and seri=b_seri and dau=b_dau_cu and thang=b_thang;
elsif b_dau=b_dau_cu and b_cuoi=b_cuoi_cu then
    delete hd_sc where ma_dvi=b_ma_dvi and loai_bp=b_loai_bp and ma_bp=b_ma_bp
        and ma=b_ma and seri=b_seri and dau=0 and cuoi=0 and thang=b_thang;
    update hd_sc set dau=0,cuoi=0 where ma_dvi=b_ma_dvi
        and loai_bp=b_loai_bp and ma_bp=b_ma_bp and ma=b_ma and seri=b_seri and dau=b_dau_cu and thang=b_thang;
else
    update hd_sc set cuoi=b_dau-1 where ma_dvi=b_ma_dvi and loai_bp=b_loai_bp
        and ma_bp=b_ma_bp and ma=b_ma and seri=b_seri and dau=b_dau_cu and thang=b_thang;
    insert into hd_sc values (b_ma_dvi,b_loai_bp,b_ma_bp,b_ma,b_seri,b_cuoi+1,b_cuoi_cu,b_thang);
end if;
--Xu ly 0
select nvl(min(dau),0) into b_i1 from hd_sc where ma_dvi=b_ma_dvi and loai_bp=b_loai_bp and ma_bp=b_ma_bp
    and ma=b_ma and seri=b_seri and dau<>0 and thang=b_thang;
if b_i1>0 then
    delete hd_sc where ma_dvi=b_ma_dvi and loai_bp=b_loai_bp and ma_bp=b_ma_bp
        and ma=b_ma and seri=b_seri and dau=0 and cuoi=0 and thang=b_thang;
end if;
end;
/
create or replace procedure PHD_CT_TH_NH
    (b_ma_dvi varchar2,b_thang number,b_loai_bp varchar2,b_ma_bp varchar2,
    b_ma varchar2,b_seri varchar2,b_dau number,b_cuoi number,b_loi out varchar2)
AS
    b_thang_m number;b_dau_cu number;b_cuoi_cu number;
    b_i1 number;b_i2 number;b_c2 varchar2(2);
begin
--Lan--Tong hop nhap hoa don vao so cai--
b_loi:=''; b_i1:=0;
if b_ma is null then
    b_loi:='loi:Nhap ma hoa don, an chi:loi'; return;
end if;
select nvl(max(thang),0) into b_thang_m from hd_sc where ma_dvi=b_ma_dvi and thang<=b_thang
    and loai_bp=b_loai_bp and ma_bp=b_ma_bp and ma=b_ma and seri=b_seri;
select count(*) into b_i1 from hd_sc where ma_dvi=b_ma_dvi and thang=b_thang_m and loai_bp=b_loai_bp and ma_bp=b_ma_bp
    and ma=b_ma and seri=b_seri and dau<=b_cuoi and cuoi>=b_dau;
if b_i1>0 then
    b_loi:='loi:Sai so nhap '||b_ma||' tu so '||trim(to_char(b_dau))||' den so '||trim(to_char(b_cuoi))||':loi';
    return;
end if;
if b_thang_m<b_thang then
    insert into hd_sc select b_ma_dvi,b_loai_bp,b_ma_bp,b_ma,b_seri,dau,cuoi,b_thang
        from hd_sc where ma_dvi=b_ma_dvi and thang=b_thang_m and loai_bp=b_loai_bp and ma_bp=b_ma_bp and ma=b_ma and seri=b_seri;
end if;
delete hd_sc_bc_so;
insert into hd_sc_bc_so select dau,cuoi from hd_sc where ma_dvi=b_ma_dvi and thang=b_thang
    and loai_bp=b_loai_bp and ma_bp=b_ma_bp and ma=b_ma and seri=b_seri and dau<>0;
--Neu la ban ghi lien truoc
select count(*) into b_i1 from hd_sc_bc_so where dau=b_cuoi+1;
if b_i1<>0 then
    select cuoi into b_cuoi_cu from hd_sc_bc_so where dau=b_cuoi+1;
    --va lien sau
    select count(*) into b_i2 from hd_sc_bc_so where cuoi=b_dau-1;
    if b_i2<>0 then
        select dau into b_dau_cu from hd_sc_bc_so where cuoi=b_dau-1;
        --xoa 2 ban ghi 2 dau
        delete hd_sc where ma_dvi=b_ma_dvi and thang=b_thang and loai_bp=b_loai_bp and ma_bp=b_ma_bp
            and ma=b_ma and seri=b_seri and (dau=b_dau_cu or cuoi=b_cuoi_cu);
        insert into hd_sc values (b_ma_dvi,b_loai_bp,b_ma_bp,b_ma,b_seri,b_dau_cu,b_cuoi_cu,b_thang);
    else --Neu chi la lien truoc, khong lien sau
        update hd_sc set dau=b_dau where ma_dvi=b_ma_dvi and thang=b_thang and loai_bp=b_loai_bp and ma_bp=b_ma_bp and ma=b_ma
            and seri=b_seri and cuoi=b_cuoi_cu;
    end if;
else --neu khong phai la ban ghi lien truoc
    --nhung la lien sau
    select count(*) into b_i2 from hd_sc_bc_so where cuoi=b_dau-1;
    if b_i2<>0 then
        select dau into b_dau_cu from hd_sc_bc_so where cuoi=b_dau-1;
        update hd_sc set cuoi=b_cuoi where ma_dvi=b_ma_dvi and thang=b_thang
            and loai_bp=b_loai_bp and ma_bp=b_ma_bp and ma=b_ma and seri=b_seri and dau=b_dau_cu;
    else  --Neu khong phai la lien truoc, lien sau
        insert into hd_sc values (b_ma_dvi,b_loai_bp,b_ma_bp,b_ma,b_seri,b_dau,b_cuoi,b_thang);
    end if;
end if;
end;
/

create or replace procedure PHD_PH_DON_X(b_ma_dvi varchar2,b_ngay number,a_ma pht_type.a_var,
    a_seri pht_type.a_var,a_so_c pht_type.a_var,b_loi out varchar2)
AS
    b_so number;b_id number;b_gia number;b_ma varchar2(10);b_seri varchar2(10);b_ngay_ct date;
    a_ma_m pht_type.a_var;a_seri_m pht_type.a_var;
    a_quyen pht_type.a_var;
    a_dau pht_type.a_num;a_cuoi pht_type.a_num;a_tke pht_type.a_var;a_gia pht_type.a_num;
    b_dem number;b_tt number;b_bp varchar2(10);b_so_ct varchar2(20);b_d number;b_c number;b_i number;b_c1 varchar2(1);
begin
--Lan--Xoa cac gcn da nhap cu--
for b_lp in 1..a_ma.count loop
    PKH_MANG_XOA(a_ma_m);PKH_MANG_XOA(a_seri_m);PKH_MANG_XOA(a_tke);PKH_MANG_XOA_N(a_dau);PKH_MANG_XOA_N(a_cuoi);PKH_MANG_XOA_N(a_gia);
    b_so:=PKH_LOC_CHU_SO(a_so_c(b_lp)); b_ma:=a_ma(b_lp); b_seri:=a_seri(b_lp);
    select count(*) into b_dem from hd_2 where ma_dvi=b_ma_dvi
        and so_id in (select so_id from hd_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay and l_ct='X')
        and ma=b_ma and seri=b_seri and b_so between dau and cuoi;
    if b_dem=0 then return; end if;
    select nvl(max(so_id),0) into b_id from hd_1 where ma_dvi=b_ma_dvi and l_ct='X' and ngay_ht=b_ngay
        and so_id in (select so_id from hd_2 where ma_dvi=b_ma_dvi and ma=b_ma and seri=b_seri and b_so between dau and cuoi);
    select so_ct,ngay_ct,nsd into b_so_ct,b_ngay_ct,b_bp from hd_1 where ma_dvi=b_ma_dvi and so_id=b_id;
    if b_bp is not null then
        b_loi:='loi:Chung tu xuat tu dong da sua:loi';
        return;
    end if;
    select so_tt,dau,cuoi,gia,ma_tke into b_tt,b_d,b_c,b_gia,b_c1 from hd_2 where ma_dvi=b_ma_dvi and so_id=b_id
        and ma=b_ma and seri=b_seri and b_so between dau and cuoi;
    --cac doan khac
    delete temp_2;
    insert into temp_2(c1,c2,n1,n2,n3,c3) select ma,seri,dau,cuoi,gia,ma_tke from hd_2 where ma_dvi=b_ma_dvi and so_id=b_id and so_tt<>b_tt;
    b_i:=0;
    for b_lp_x in (select c1,c2,n1,n2,n3,c3 from temp_2) loop
         b_i:=b_i+1;
         a_ma_m(b_i):=b_lp_x.c1;a_seri_m(b_i):=b_lp_x.c2;a_dau(b_i):=b_lp_x.n1;a_cuoi(b_i):=b_lp_x.n2;a_tke(b_i):=b_lp_x.c3;a_gia(b_i):=b_lp_x.n3;
    end loop;
    --doan chua so bi xoa
    delete temp_2;
    if b_d<b_c then
        if b_d=b_so then
            insert into temp_2(n1,n2) values (b_d+1,b_c);
        elsif b_c=b_so then
            insert into temp_2(n1,n2) values (b_d,b_c-1);
        else
            insert into temp_2(n1,n2) values (b_d,b_so-1); insert into temp_2(n1,n2) values (b_so+1,b_c);
        end if;
        for b_lp_x2 in (select n1,n2 from temp_2 order by n1) loop
             b_i:=b_i+1;
             a_ma_m(b_i):=b_ma;a_seri_m(b_i):=b_seri;a_dau(b_i):=b_lp_x2.n1;a_cuoi(b_i):=b_lp_x2.n2;a_tke(b_i):=b_c1;a_gia(b_i):=b_gia;
        end loop;
    end if;
    if a_ma.count=0 then
        PHD_CT_XOA_XOA(b_ma_dvi,'',b_id,b_loi);
    else
        PHD_CT_SUA_SUA(b_ma_dvi,'','',b_ngay,'H',b_id,'X',b_so_ct,b_ngay_ct,'','','','Xuat tu dong',a_ma,a_seri,a_quyen,a_dau,a_cuoi,a_tke,a_gia,b_loi);
    end if;
    if b_loi is not null then
        b_loi:='loi:Sai GCN '||FKH_GHEP_SERI(b_ma,b_seri,b_so,'')||':loi';
        return;
    end if;
end loop;
end;
/
create or replace procedure PHD_CT_NH_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_ngay_ht number,b_htoan varchar2,
    b_so_id in out number,b_so_id_bh number,b_l_ct varchar2,b_so_ct varchar2,b_ngay_ct date,
    b_ma_cc varchar2,b_loai_nh varchar2,b_ma_nh varchar2,b_nd nvarchar2,
    a_ma pht_type.a_var,a_seri pht_type.a_var,a_quyen pht_type.a_var,a_dau pht_type.a_num,
    a_cuoi pht_type.a_num,a_tke pht_type.a_var,a_gia pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number;b_i2 number;b_c10 varchar2(10);b_dl varchar2(10);b_c11 varchar2(10);b_ma_hd varchar2(20); b_vp varchar2(20);
    b_ten_sv varchar2(50);b_ten_db varchar2(50);b_ten_dbo varchar2(50);b_tt number; b_qly varchar2(1);
    b_ten_sv_1 varchar2(50);b_ten_db_1 varchar2(50);b_ten_dbo_1 varchar2(50);b_thang number;b_nhom varchar2(5);
    a_ma_m pht_type.a_var; b_ma_m varchar(20);
begin
---Lan--Nhap ctu hoa don---Da sua: bat nhap ma hd, xuat dung giao CB Qly
delete from temp_4;
select count(*) into b_i1 from ht_ma_dvi where vp='C';
if b_i1 <=0 then 
 b_loi:='loi:Khong ton tai van phong:loi';
 return;
end if;
select max(MA) into b_vp from ht_ma_dvi where vp='C';
insert into temp_4(c1,c2,c3,c4) select ma_dvi,nv||'>'|| ma, ma,nv from hd_ma_hd where ma_dvi=b_vp;
for b_lp in 1..a_ma.count loop
    b_ma_m := trim(substr(a_ma(b_lp), instr(a_ma(b_lp), '>') + 1)); 
    if b_ma_m is null or b_ma_m = '' then 
        b_ma_m := a_ma(b_lp); 
    end if;
    select count(*),c2 into b_i1,b_ma_m from temp_4 where c1=b_vp and c3=b_ma_m group by c2;
    if b_i1=0 then b_loi:='loi:Chua dang ky ma hoa don '||rtrim(a_ma(b_lp))||':loi'; return;
    end if;
    if a_dau(b_lp)>a_cuoi(b_lp) then
        b_loi:='loi:So dau phai <= so cuoi:loi';
        return;
    end if;
    a_ma_m(b_lp) := b_ma_m;
end loop;
if b_l_ct='X' then
    for b_lp in 1..a_ma.count loop
        if a_tke(b_lp) is null or a_tke(b_lp) not in ('D','M','H','T','O') then
            b_loi:='loi:Ma t.ke:D,M,H,T,O:loi';
            return;
        end if;
        for b_lps in a_dau(b_lp)..a_cuoi(b_lp) loop
            delete temp_1;
            insert into temp_1(n1) select so_id from hd_2 where ma_dvi=b_ma_dvi and ma=a_ma(b_lp) and b_lps between dau and cuoi;
            select nvl(min(l_ct),'*') into b_c10 from hd_1 where ma_dvi=b_ma_dvi and so_id in (select n1 from temp_1) and l_ct='X';
            if b_c10='X' then
                b_loi:='loi:An chi '||a_ma(b_lp)||' '||to_char(b_lps)||' da su dung:loi';
                return;
            end if;
        end loop;
    end loop;
end if;
b_tt:=b_so_id;
b_thang:=to_number(substr(to_char(b_ngay_ht),1,6));
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then return; end if;
end if;
delete temp_3;
--Nhap vao hd_1
delete hd_1 where ma_dvi=b_ma_dvi and so_id=b_so_id; -- chuclh moi them
insert into hd_1 values (b_ma_dvi,b_so_id,b_so_id_bh,b_ngay_ht,b_l_ct,b_so_ct,b_ngay_ct,b_ma_cc,b_loai_nh,b_ma_nh,b_nd,b_htoan,sysdate,b_nsd);
--Nhap vao temp_3
--temp_3(n15=tt,c1=loai_x,c2=ma_x,c3=dl_x,c4=loai_n,c5=ma_n,c6=dl_n,c7=ma,n1=do_dai,c8=seri,n2=dau,n3=cuoi,n4=gia)
for b_lp in 1..a_ma.count loop
    delete hd_2 where ma_dvi=b_ma_dvi and so_id=b_so_id and so_tt=b_lp;  -- chuclh moi them
    insert into hd_2 values (b_ma_dvi,b_so_id,b_lp,a_ma_m(b_lp),a_seri(b_lp),a_quyen(b_lp),a_dau(b_lp),a_cuoi(b_lp),a_tke(b_lp),a_gia(b_lp));
    if b_l_ct='N' then
        insert into temp_3(n15,c1,c2,c4,c5,c7,c8,c9,n2,n3)
            values(b_lp,' ',' ',b_loai_nh,b_ma_nh,a_ma_m(b_lp),a_seri(b_lp),a_quyen(b_lp),a_dau(b_lp),a_cuoi(b_lp));
    else
        PHD_CT_TH_XUAT_TIM(b_ma_dvi,b_ngay_ht,b_so_id,a_ma_m(b_lp),a_seri(b_lp),a_dau(b_lp),a_cuoi(b_lp),0);
        select count(*) into b_i2 from temp_1;
        if b_i2=0 then
            b_loi:='loi:Khong xuat duoc tu so '||trim(to_char(a_dau(b_lp)))||' den so '||trim(to_char(a_cuoi(b_lp)))||' '||b_so_id||':loi';
            return;
        else
            insert into temp_3(n15,c1,c2,c4,c5,c7,c8,c9,n2,n3,n4)
                select b_lp,c1,c2,b_loai_nh,b_ma_nh,a_ma_m(b_lp),a_seri(b_lp),a_quyen(b_lp),n1,n2,n3 from temp_1;
        end if;
        select count(*) into b_i1 from ht_ma_dvi where ten like '%AAA%';
        if b_i1=0 then
            if b_l_ct='X' then
               for b_lpp in (select distinct c1,c5 from temp_1) loop
                    select phong into b_c10 from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_nsd;
                    select phong into b_c11 from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_lpp.c5;
                        if b_c11<>b_c10 then
                           b_loi:='loi: Khong xuat duoc '||a_ma_m(b_lp)||'. HDAC dang o phong '||b_c11||':loi';
                            return;
                        end if;
                    if b_lpp.c1 not in ('C','L') then
                       select ma_nhom into b_nhom from hd_ma_hd where ma_dvi=b_ma_dvi and nv||'>'||ma=a_ma_m(b_lp);
                       if b_nhom='AC' then
                           select nvl(min(ma_qly),'C') into b_qly from hd_ma_qly where ma_dvi=b_ma_dvi;
                           if b_qly='C' then
                               b_loi:='loi:Chua giao nguoi quan ly '||a_ma_m(b_lp)||' tu so '||trim(to_char(a_dau(b_lp)))||' den so '||trim(to_char(a_cuoi(b_lp)))||':loi';
                               return;
                           end if;
                       end if;
                    end if;
                 end loop;
            end if;
        else
            if b_l_ct='X' then
                for b_lpp in (select distinct c1,c2 from temp_1) loop
                    if b_lpp.c1 not in ('B','C','L') then
                       b_loi:='loi:Chua giao nguoi quan ly '||a_ma_m(b_lp)||' tu so '||trim(to_char(a_dau(b_lp)))||' den so '||trim(to_char(a_cuoi(b_lp)))||':loi';
                       return;
                    else
                       if b_nsd not in ('ADMIN','QLDL','QLHD') then
                            select nvl(min(phong),'*') into b_c10 from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_nsd;
                            if b_lpp.c1='B' then
                               if b_lpp.c2<>b_c10 then
                                   b_loi:='loi:Bo phan khac quan ly '||a_ma_m(b_lp)||' tu so '||trim(to_char(a_dau(b_lp)))||' den so '||trim(to_char(a_cuoi(b_lp)))||':loi';
                                   return;
                               end if;
                            elsif b_lpp.c1='C' then
                               select count(*) into b_i2 from ht_ma_dvi where ten like '%MIC%';
                               if b_i2<>0 and b_lpp.c2<>b_nsd then
                                   b_loi:='loi:Can bo khac quan ly '||a_ma_m(b_lp)||' tu so '||trim(to_char(a_dau(b_lp)))||' den so '||trim(to_char(a_cuoi(b_lp)))||':loi';
                                   return;
                               end if;
                            end if;
                        end if;
                    end if;
                end loop;
            end if;
        end if;
        if b_l_ct='C' then
            for b_lpp1 in (select distinct c1,c2,c5,n1,n2 from temp_1) loop
                if b_loai_nh='C' then
                    if b_lpp1.c1='B' then
                        select count(*) into b_i1 from ht_ma_cb where ma_dvi=b_ma_dvi and ma=b_ma_nh and phong=b_lpp1.c2;
                            if b_i1=0 then b_loi:='loi:Bo phan khac quan ly '||a_ma_m(b_lp)||' tu so '||trim(to_char(b_lpp1.n1))||' den so '||trim(to_char(b_lpp1.n2))||':loi';
                            return;
                            end if;
                    elsif b_lpp1.c1='C' then
                        b_loi:='loi:Khong dieu chuyen giua cac can bo '||a_ma_m(b_lp)||' tu so '||trim(to_char(b_lpp1.n1))||' den so '||trim(to_char(b_lpp1.n2))||':loi';
                        return;
                    elsif b_lpp1.c1='D' then
                       b_loi:='loi:Chua dieu chuyen cho bo phan '||a_ma_m(b_lp)||' tu so '||trim(to_char(b_lpp1.n1))||' den so '||trim(to_char(b_lpp1.n2))||':loi';
                       return;
                    end if;
                elsif b_loai_nh='B' then
                    if b_lpp1.c1='B' then
                        b_loi:='loi:Khong dieu chuyen giua cac bo phan '||a_ma_m(b_lp)||' tu so '||trim(to_char(b_lpp1.n1))||' den so '||trim(to_char(b_lpp1.n2))||':loi';
                        return;
                    elsif b_lpp1.c1='C' then
                       select phong into b_c10 from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_nsd;
                       select phong into b_c11 from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_lpp1.c5;
                        if b_ma_nh<>b_c10 or b_c11<>b_c10 then
                            b_loi:='loi:Khong dieu chuyen cho phong khac :loi';
                            return;
                        end if;
                    elsif b_lpp1.c1='D' then
                        select phong into b_c10 from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_nsd;
                        select phong into b_c11 from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_lpp1.c5;
                        if b_c11<>b_c10 then
                            b_loi:='loi: NSD khong thuoc phong '||b_c11||'. HDAC dang o phong '||b_c11||':loi';
                            return;
                        end if;
                    end if;
                elsif b_loai_nh='D' then
                    select min(ma) into b_c10 from ht_ma_dvi where vp='C';
                    if b_ma_nh=b_c10 and b_ma_nh<>b_ma_dvi then
                        if b_lpp1.c1 in ('B','C','L') then
                            b_loi:='loi:Chua dieu chuyen len chi nhanh '||a_ma_m(b_lp)||' tu so '||trim(to_char(b_lpp1.n1))||' den so '||trim(to_char(b_lpp1.n2))||':loi';
                            return;
                        end if;
                    else
                        if b_lpp1.c1='B' then
                           select phong into b_c10 from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_nsd;
                            if b_lpp1.c2<>b_c10 then
                                b_loi:='loi:Khong quan ly 1' || b_lpp1.c2 || ' - '||a_ma_m(b_lp)||' tu so '||trim(to_char(b_lpp1.n1))||' den so '||trim(to_char(b_lpp1.n2))||':loi';
                                return;
                            end if;
                        else
                            if b_ma_nh=b_ma_dvi then
                                b_loi:='loi:Chua dieu chuyen ve bo phan '||a_ma_m(b_lp)||' tu so '||trim(to_char(b_lpp1.n1))||' den so '||trim(to_char(b_lpp1.n2))||':loi';
                                return;
                            else
                                select phong into b_c10 from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_nsd;
                                select phong into b_c11 from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_lpp1.c5;
                                if b_c11<>b_c10 then
                                    b_loi:='loi: NSD khong thuoc phong '||b_c11||'. HDAC dang o phong '||b_c11||':loi';
                                return;
                        end if;
                            end if;
                        end if;
                    end if;
                elsif b_loai_nh='L' then
                    if b_lpp1.c1 not in ('B','C') then
                       b_loi:='loi:Chua dieu chuyen cho bo phan '||a_ma_m(b_lp)||' tu so '||trim(to_char(b_lpp1.n1))||' den so '||trim(to_char(b_lpp1.n2))||':loi';
                        return;
                    end if;
                end if;
            end loop;
        end if;
    end if;
end loop;
--Nhap vao hd_3
if b_l_ct='C' then
    for b_lp in (select c1,c2,c4,c5,c7,c8,n2,n3 from temp_3) loop
        if (b_lp.c1=b_lp.c4 and b_lp.c2=b_lp.c5) then
            b_loi:='loi:'||b_lp.c4||' '||b_lp.c5||' da co '||b_lp.c7||' tu so '||trim(to_char(b_lp.n2))||' den so '||trim(to_char(b_lp.n3))||':loi';
            return;
        end if;
    end loop;
end if;
insert into hd_3 select b_ma_dvi,b_so_id,n15,c1,c2,c4,c5,c7,c8,c9,n2,n3,n4 from temp_3 order by n15;
--Tong hop so cai
if b_htoan='H' then
    delete temp_sl;
    insert into temp_sl(c1,c2,c4,c5,c7,c8,c9) select distinct c1,c2,c4,c5,c7,c8,c9 from temp_3;
    for b_lp in (select c1,c2,c4,c5,c7,c8,c9 from temp_sl order by c1,c2,c4,c5,c7,c8,c9) loop
        delete temp_1; insert into temp_1(n1) values (b_thang);
        insert into temp_1(n1) select distinct thang from hd_sc where ma_dvi=b_ma_dvi
            and thang>b_thang and loai_bp=b_lp.c1 and ma_bp=b_lp.c2 and ma=b_lp.c7;
        delete temp_2; insert into temp_2(n1) values (b_thang);
        insert into temp_2(n1) select distinct thang from hd_sc where ma_dvi=b_ma_dvi
            and thang>b_thang and loai_bp=b_lp.c4 and ma_bp=b_lp.c5 and ma=b_lp.c7;
        for b_lop in (select n2,n3 from temp_3 where c1=b_lp.c1 and c2=b_lp.c2
            and nvl(c4,'*')=nvl(b_lp.c4,'*') and nvl(c5,'*')=nvl(b_lp.c5,'*') and c7=b_lp.c7 and nvl(c8,'*')=nvl(b_lp.c8,'*') order by n2,n3) loop
            if b_l_ct='N' then
                select nvl(min(so_id),0) into b_i1 from hd_2 where ma_dvi=b_ma_dvi
                    and so_id<>b_so_id and ma=b_lp.c7 and seri=b_lp.c8 and dau<=b_lop.n3 and cuoi>=b_lop.n2;
                if b_i1<>0 then
                    select l_ct into b_c10 from hd_1 where ma_dvi=b_ma_dvi and so_id=b_i1;
                    if b_c10='N' then
                        b_loi:='loi:'||b_lp.c7||' tu so '||to_char(b_lop.n2)||' den so '||to_char(b_lop.n3)||' da nhap ve'||':loi';
                        return;
                    end if;
                end if;
                for b_lpn in (select n1 from temp_2 order by n1) loop
                    PHD_CT_TH_NH(b_ma_dvi,b_lpn.n1,b_lp.c4,b_lp.c5,b_lp.c7,nvl(b_lp.c8,' '),b_lop.n2,b_lop.n3,b_loi);
                    if b_loi is not null then return; end if;
                end loop;
            elsif b_l_ct='X' then
                for b_lpn in (select n1 from temp_1 order by n1) loop
                    PHD_CT_TH_XUAT(b_ma_dvi,b_lpn.n1,b_lp.c1,b_lp.c2,b_lp.c7,nvl(b_lp.c8,' '),b_lop.n2,b_lop.n3,b_loi);
                    if b_loi is not null then return; end if;
                end loop;
            else
                for b_lpn in (select n1 from temp_1 order by n1) loop
                    PHD_CT_TH_XUAT(b_ma_dvi,b_lpn.n1,b_lp.c1,b_lp.c2,b_lp.c7,nvl(b_lp.c8,' '),b_lop.n2,b_lop.n3,b_loi);
                    if b_loi is not null then return; end if;
                end loop;
                   ----
                if b_loai_nh<>'D' or (b_loai_nh='D' and b_ma_dvi=b_ma_nh) then
                    for b_lpn in (select n1 from temp_2 order by n1) loop
                        PHD_CT_TH_NH(b_ma_dvi,b_lpn.n1,b_lp.c4,b_lp.c5,b_lp.c7,nvl(b_lp.c8,' '),b_lop.n2,b_lop.n3,b_loi); -- seri chua biet dien gi
                        if b_loi is not null then return; end if;
                    end loop;
                end if;
            end if;
        end loop;
    end loop;
end if;
--Truong hop dieu chuyen sang don vi cung schema
if b_loai_nh='D' and b_l_ct='C' and b_ma_dvi<>b_ma_nh then
   -- chuclh - bo check
   --select nvl(ten_db,' '),nvl(ten_dbo,' ') into b_ten_db,b_ten_dbo from ht_ma_dvi where ma=b_ma_dvi;
   --select nvl(ten_db,' '),nvl(ten_dbo,' ') into b_ten_db_1,b_ten_dbo_1 from ht_ma_dvi where ma=b_ma_nh;
   --if (upper(b_ten_db)=upper(b_ten_db_1) and upper(b_ten_dbo)=upper(b_ten_dbo_1)) then
        PHD_CT_NH_NH (b_ma_nh,'',b_ngay_ht,'T',b_so_id,0,'N',b_so_ct,b_ngay_ct,'',b_loai_nh,b_ma_nh,
                'Nhan dieu chuyen-Tu dong',a_ma,a_seri,a_quyen,a_dau,a_cuoi,a_tke,a_gia,b_loi);
        if b_loi is not null then return; end if;
   --end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PHD_CT_NH_J
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000);b_loi varchar2(150);b_c2 varchar2(2);b_ngay_m number;b_dau number;b_cuoi number;
    b_i1 number;b_i2 number;b_c1 varchar2(1);b_c10 varchar2(10);b_dl varchar2(10);
    b_ngay_ht number;b_htoan varchar2(1);b_so_id number;
    b_l_ct varchar2(1);b_so_ct varchar2(20);b_ngay_ct varchar2(20);d_ngay_ct date; b_ma_cc varchar2(10);b_loai_nh varchar2(2);b_ma_nh varchar2(20);b_nd nvarchar2(400);
    dt_ct clob; dt_dk_ct clob; a_ma pht_type.a_var;a_seri pht_type.a_var;a_quyen pht_type.a_var;a_dau pht_type.a_num;
    a_cuoi pht_type.a_num;a_tke pht_type.a_var;a_gia pht_type.a_num;b_so_id_bh number:=0;
begin
---Lan--Nhap ctu hoa don---
b_lenh:=FKH_JS_LENH('so_id');
EXECUTE IMMEDIATE b_lenh into b_so_id using b_oraIn;
b_lenh:=FKH_JS_LENHc('dt_ct,dk_ct');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk_ct using b_oraIn;
b_lenh:=FKH_JS_LENH('ngay_ht,htoan,l_ct,so_ct,ngay_ct,ma_cc,loai_n,ma_n,nd');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_htoan,b_l_ct,b_so_ct,b_ngay_ct,b_ma_cc,b_loai_nh,b_ma_nh,b_nd using dt_ct;
if b_ngay_ct is not null then
   d_ngay_ct := to_date(b_ngay_ct,'yyyymmdd');  
end if;
b_lenh:=FKH_JS_LENH('ma,seri,quyen,dau,cuoi,ma_tke,gia');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma,a_seri,a_quyen,a_dau,a_cuoi,a_tke,a_gia using dt_dk_ct;
if a_ma.count=0 then b_loi:='loi:Nhap dieu khoan:loi'; return; end if;
for b_lp in 1..a_seri.count loop
 a_seri(b_lp):=NVL(a_seri(b_lp),' ');a_quyen(b_lp):=NVL(a_quyen(b_lp),' ');
end loop;
if b_nsd is not null then
    if b_l_ct='C' then 
        if b_loai_nh is null or b_loai_nh=' ' or b_ma_nh is null or b_ma_nh=' ' then
            b_loi:='loi:Chua nhap don vi nhan:loi';raise PROGRAM_ERROR;
        end if;
        if b_loai_nh='D' then b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','DC','Q'); end if;
        if b_loai_nh='B' then b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','DC','X'); end if;
        if b_loai_nh in ('C','L') then
            b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','DC','N');
            select phong into b_c10 from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_nsd;
            if b_loai_nh='C' then
                select phong into b_dl from ht_ma_cb where ma=b_ma_nh;
            --else
             --   select phong into b_dl from bh_dl_ma_kh where ma_dvi=b_ma_dvi and ma=b_ma_nh;
            end if;
            if b_c10<>b_dl then
                b_loi:='loi:Chi duoc dieu chuyen cho can bo, dai ly cung phong:loi';raise PROGRAM_ERROR;
            end if;
            
        end if;
    elsif b_l_ct='N' then 
        b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','NX','N');
        if b_loai_nh is null or b_loai_nh=' ' or b_ma_nh is null or b_ma_nh=' ' then
            b_loi:='loi:Chua nhap don vi nhan:loi'; end if;
    elsif b_l_ct='X' then  b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','NX','N');
    end if;
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'HD','AL');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PHD_TEST (b_ma_dvi,b_nsd,b_pas,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_l_ct='N' then
    select vp into b_c1 from ht_ma_dvi where ma=b_ma_dvi;
    if b_loai_nh='D' then select nvl(min(vp),'') into b_c1 from ht_ma_dvi where ma=b_ma_nh; end if;
    if b_c1<>'C' and b_nsd is not null then
        b_loi:='loi:Van phong moi duoc nhap tu nha cung cap:loi';
        raise PROGRAM_ERROR;
    end if;
elsif b_l_ct='X' then
    if b_nsd not in ('ADMIN','QLDL','QLHD') then
        for b_lp in 1..a_tke.count loop
            if a_tke(b_lp)='D' then
                b_loi:='loi:Chi nhap hoa don, an chi mat, hong, huy:loi';
                raise PROGRAM_ERROR;
            end if;
        end loop;
    end if;
end if;
PHD_CT_NH_NH(b_ma_dvi,b_nsd,b_ngay_ht,b_htoan,b_so_id,b_so_id_bh,b_l_ct,b_so_ct,d_ngay_ct,b_ma_cc,b_loai_nh,b_ma_nh,b_nd,a_ma,a_seri,a_quyen,a_dau,a_cuoi,a_tke,a_gia,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHD_CT_SUA_J
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number;b_lenh varchar2(1000);b_loi varchar2(150); b_c10 varchar2(10);b_dl varchar2(10);
    b_ngay_ht number;b_htoan varchar2(1);b_so_id number;
    b_l_ct varchar2(1);b_so_ct varchar2(20);b_ngay_ct number; d_ngay_ct date; b_ma_cc varchar2(10);b_loai_nh varchar2(2);b_ma_nh varchar2(20);b_nd nvarchar2(400);
    dt_ct clob; dt_dk_ct clob; a_ma pht_type.a_var;a_seri pht_type.a_var;a_quyen pht_type.a_var;a_dau pht_type.a_num;
    a_cuoi pht_type.a_num;a_tke pht_type.a_var;a_gia pht_type.a_num;b_so_id_bh number:=0;
begin
---Lan--Nhap ctu hoa don---
b_lenh:=FKH_JS_LENH('so_id');
EXECUTE IMMEDIATE b_lenh into b_so_id using b_oraIn;
b_lenh:=FKH_JS_LENHc('dt_ct,dk_ct');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk_ct using b_oraIn;
b_lenh:=FKH_JS_LENH('ngay_ht,htoan,l_ct,so_ct,ngay_ct,ma_cc,loai_n,ma_n,nd');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_htoan,b_l_ct,b_so_ct,b_ngay_ct,b_ma_cc,b_loai_nh,b_ma_nh,b_nd using dt_ct;
if b_ngay_ct is not null then
   d_ngay_ct := to_date(b_ngay_ct,'yyyymmdd');
end if;
b_lenh:=FKH_JS_LENH('ma,seri,quyen,dau,cuoi,tke,gia');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma,a_seri,a_quyen,a_dau,a_cuoi,a_tke,a_gia using dt_dk_ct;
if a_ma.count=0 then b_loi:='loi:Nhap dieu khoan:loi'; return; end if;
for b_lp in 1..a_seri.count loop
 a_seri(b_lp):=NVL(a_seri(b_lp),' ');a_quyen(b_lp):=NVL(a_quyen(b_lp),' ');
end loop;
---Lan--Sua ctu hoa don---
if b_l_ct='C' then
    if b_loai_nh is null or b_loai_nh=' ' or b_loai_nh not in ('D','C','B','L') or b_ma_nh is null or b_ma_nh=' ' then
        b_loi:='loi:Nhap sai don vi nhan:loi';
    elsif b_loai_nh='D' then
        b_loi:='loi:Sai ma don vi nhan:loi';
        b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','DC','Q');
    elsif b_loai_nh='B' then
        b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','DC','X');
    elsif b_loai_nh in ('C','L') then
        select phong into b_c10 from ht_ma_cb where ma_dvi=b_ma_dvi and ma=b_nsd;
        if b_loai_nh='C' then
            select count(*) into b_i1 from ht_ma_cb where ma_dvi=b_ma_dvi and ma=b_ma_nh;
            if b_i1>0 then
             select phong into b_dl from ht_ma_cb where ma_dvi=b_ma_dvi and ma=b_ma_nh;
            end if;
        --else
         --   select phong into b_dl from bh_dl_ma_kh where ma_dvi=b_ma_dvi and ma=b_ma_nh;
        end if;
        if b_c10<>b_dl then
            b_loi:='loi:Chi duoc dieu chuyen cho can bo, dai ly cung phong:loi'; raise PROGRAM_ERROR;
        end if;
            b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','DC','N');
    end if;
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'HD','AL');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PHD_CT_SUA_SUA(b_ma_dvi,b_nsd,b_pas,b_ngay_ht,b_htoan,b_so_id,b_l_ct,b_so_ct,d_ngay_ct,b_ma_cc,
    b_loai_nh,b_ma_nh,b_nd,a_ma,a_seri,a_quyen,a_dau,a_cuoi,a_tke,a_gia,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; raise_application_error(-20105,b_loi);
end;
/
create or replace procedure PHD_CT_TH_XUAT_TIM
    (b_ma_dvi varchar2,b_ngay_ht number,b_id number,b_ma varchar2,b_seri varchar2,b_dau number,b_cuoi number,b_kieu number:=0)
AS
    b_dau_cu number;b_cuoi_cu number;b_dau_in number;b_so_id number:=0;
    b_i1 number;b_gia number;b_c2 varchar2(2);b_bt number;b_nsd varchar2(50);
begin
delete temp_1;delete temp_2;
if b_id>0 then
    insert into temp_2(n1) select so_id from hd_1 where ma_dvi=b_ma_dvi and ngay_ht<=b_ngay_ht and so_id<b_id and l_ct in ('N','C') and htoan='H';
else
    insert into temp_2(n1) select so_id from hd_1 where ma_dvi=b_ma_dvi and ngay_ht<=b_ngay_ht and l_ct in ('N','C') and htoan='H';
end if;
b_dau_in:=b_dau;

while b_dau_in>0 loop
    select nvl(max(so_id),0) into b_so_id from hd_2 where ma_dvi=b_ma_dvi and so_id in (select n1 from temp_2) and ma=b_ma and seri=b_seri
        and b_dau_in between dau and cuoi;
    if b_kieu<>0 then
        select nvl(min(so_id),0) into b_so_id from hd_2 where ma_dvi=b_ma_dvi and so_id in (select n1 from temp_2) and ma=b_ma and seri=b_seri
            and b_dau_in between dau and cuoi;
    end if;
    if b_so_id=0 then return; end if;
    select so_tt into b_bt from hd_2 where ma_dvi=b_ma_dvi and so_id=b_so_id and ma=b_ma and seri=b_seri
        and b_dau_in between dau and cuoi;
    if b_so_id>0 then
        select cuoi,gia into b_cuoi_cu,b_gia from hd_2 where ma_dvi=b_ma_dvi and so_id=b_so_id and seri=b_seri and so_tt=b_bt;
        select nsd into b_nsd from hd_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
        if b_cuoi<=b_cuoi_cu then
            insert into temp_1(c1,c2,n1,n2,n3,n4,c5) select loai_n,ma_n,b_dau_in,b_cuoi,b_gia,b_so_id,b_nsd from hd_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
            b_dau_in:=0;
        else
            insert into temp_1(c1,c2,n1,n2,n3,n4,c5) select loai_n,ma_n,b_dau_in,b_cuoi_cu,b_gia,b_so_id,nsd from hd_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
            b_dau_in:=b_cuoi_cu+1;
        end if;
    else
        b_dau_in:=0;
    end if;
end loop;
end;
/
create or replace procedure PHD_CT_THL_THL
    (b_ma_dvi varchar2,b_thang number,b_loi_th out varchar2,b_so_id_1 number,b_so_id_2 number,b_ma varchar2,b_seri varchar2)
AS
    b_i1 number; b_ten_db varchar2(50); b_ten_dbo varchar2(50);
    b_ten_db_1 varchar2(50);b_ten_dbo_1 varchar2(50);b_ngay number;
begin
---Lan--Tong hop lai chung tu hoa don---
b_loi_th:='';
b_ngay:=b_thang*100+01;
--Tong hop ctu
delete temp_1;
if (b_so_id_1>0 and b_so_id_2>0) then
   insert into temp_1 (n1,c7,n2,c4,c5) select so_id,l_ct,ngay_ht,loai_n,ma_n from hd_1
        where (ma_dvi,so_id) in (select ma_dvi,so_id from hd_2 where ma_dvi=b_ma_dvi and (b_ma is null or ma=b_ma) and (b_seri is null or seri=b_seri))
        and ngay_ht>=b_ngay and so_id>=b_so_id_1 and so_id<b_so_id_2 and htoan='H';
else
    insert into temp_1 (n1,c7,n2,c4,c5) select so_id,l_ct,ngay_ht,loai_n,ma_n from hd_1
    where (ma_dvi,so_id) in (select ma_dvi,so_id from hd_2 where ma_dvi=b_ma_dvi and (b_ma is null or ma=b_ma) and (b_seri is null or seri=b_seri))
    and ngay_ht>=b_ngay and htoan='H' ;
end if;
update temp_1 set n2=to_number(substr(to_char(n2),1,6));
select count(*) into b_i1 from temp_1 where n1<>0;
if b_i1=0 then return;end if;
for r_lp in (select n1,c7,n2,c4,c5 from temp_1 where n1<>0 order by n2,n1) loop
    delete temp_sl;
    insert into temp_sl(c1,c2,c4,c5,c7,c8) select distinct loai_x,ma_x,loai_n,ma_n,ma,seri from hd_3
        where ma_dvi=b_ma_dvi and so_id=r_lp.n1 and (b_ma is null or ma=b_ma) and (b_seri is null or seri=b_seri);
    for b_lop in (select c1,c2,c4,c5,c7,c8 from temp_sl order by c1,c2,c4,c5,c7,c8) loop
        for r_lp_1 in (select dau,cuoi from hd_3 where ma_dvi=b_ma_dvi and so_id=r_lp.n1
                and nvl(loai_x,'*')=nvl(b_lop.c1,'*') and nvl(ma_x,'*')=nvl(b_lop.c2,'*')
                and nvl(loai_n,'*')=nvl(b_lop.c4,'*') and nvl(ma_n,'*')=nvl(b_lop.c5,'*')
                and nvl(ma,'*')=nvl(b_lop.c7,'*') and nvl(seri,'*')=nvl(b_lop.c8,'*') order by dau,cuoi) loop
            if r_lp.c7='N' then
                PHD_CT_TH_NH(b_ma_dvi,r_lp.n2,b_lop.c4,b_lop.c5,b_lop.c7,b_lop.c8,r_lp_1.dau,r_lp_1.cuoi,b_loi_th);
                if b_loi_th is not null then return;end if;
            elsif r_lp.c7='C' then
                PHD_CT_TH_XUAT(b_ma_dvi,r_lp.n2,b_lop.c1,b_lop.c2,b_lop.c7,b_lop.c8,r_lp_1.dau,r_lp_1.cuoi,b_loi_th);
                if b_loi_th is not null then return;end if;
                ---
                if r_lp.c4<>'D' or (r_lp.c4='D' and b_ma_dvi=b_lop.c5) then
                    PHD_CT_TH_NH(b_ma_dvi,r_lp.n2,b_lop.c4,b_lop.c5,b_lop.c7,b_lop.c8,r_lp_1.dau,r_lp_1.cuoi,b_loi_th);
                    if b_loi_th is not null then return;end if;
                end if;
            else
                PHD_CT_TH_XUAT(b_ma_dvi,r_lp.n2,b_lop.c1,b_lop.c2,b_lop.c7,b_lop.c8,r_lp_1.dau,r_lp_1.cuoi,b_loi_th);
                if b_loi_th is not null then return;end if;
            end if;
        end loop;
    end loop;
end loop;
end;
/
create or replace procedure PHD_HOI_BP
       (b_ma_dvi varchar2,b_ngay number,b_mau varchar2,b_so number,b_seri varchar2,b_loai out varchar2,b_ma out varchar2)
AS
       b_ngay_m number;b_thang number;
begin
--Lan--Kiem tra so hoa don co trong so cai khong--
b_ma:='';
b_thang:=to_number(substr(to_char(b_ngay),1,6));
select nvl(max(thang),0) into b_ngay_m from hd_sc where ma_dvi=b_ma_dvi and thang<=b_thang
    and ma=b_mau and seri in (' ',b_seri) and b_so between dau and cuoi;
if b_ngay_m=0 then b_loai:='*'; return; end if;

SELECT loai_bp, ma_bp into b_loai,b_ma FROM hd_sc
WHERE ma_dvi=b_ma_dvi and thang=b_ngay_m and ma=b_mau and seri in (' ',b_seri) and b_so between dau and cuoi AND loai_bp = (
    SELECT MAX(loai_bp) FROM hd_sc WHERE ma_dvi=b_ma_dvi and thang=b_ngay_m and ma=b_mau and seri in (' ',b_seri) and b_so between dau and cuoi);
 /*   
select nvl(max(loai_bp),'*'),max(ma_bp) into b_loai,b_ma from hd_sc where
       ma_dvi=b_ma_dvi and thang=b_ngay_m and ma=b_mau and b_so between dau and cuoi;

select nvl(min(loai_bp),'*'),min(ma_bp) into b_loai,b_ma from hd_sc where
       ma_dvi=b_ma_dvi and thang=b_ngay_m and ma=b_mau and seri=b_seri and b_so between dau and cuoi;
*/
end;
/
create or replace procedure PHD_CT_THLJ_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_thang number; b_ngay number; b_ma varchar2(20);
begin
---Lan--Tong hop lai chung tu hoa don---
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','TH','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PHD_TEST (b_ma_dvi,b_nsd,b_pas,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ngay');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ngay using b_oraIn;
--Xoa sc_hd co ngay>=ngay tong hop lai
b_thang:=to_number(substr(to_char(b_ngay),1,6));
delete temp_sl;
insert into temp_sl(c1) select distinct seri from hd_2 where ma_dvi=b_ma_dvi and ma=b_ma;
for b_lp in (select c1 from temp_sl order by c1) loop
    delete hd_sc where ma_dvi=b_ma_dvi and thang>=b_thang and ma=b_ma and seri=b_lp.c1;
    PHD_CT_THL_THL(b_ma_dvi,b_thang,b_loi,0,0,b_ma,b_lp.c1);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end loop;
commit;
exception when others then rollback; raise_application_error(-20105,b_loi);
end;
/
create or replace procedure PHD_MA_HDJ_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000); b_vp varchar2(1);
    b_ma varchar2(20);b_mau varchar2(20);
    b_nhom varchar2(10);b_nv varchar2(20);b_do_dai number;b_ten nvarchar2(50);b_lien number;b_to number;
begin
-- viet anh - Nhap ma hoa don
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','MA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,mau,ma_nhom,nv,ten,do_dai,so_lien,so_to');
EXECUTE IMMEDIATE b_lenh into b_ma,b_mau,b_nhom,b_nv,b_ten,b_do_dai,b_lien,b_to using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma hoa don, an chi:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai nhom hoa don, an chi:loi';
if b_nhom is null then raise PROGRAM_ERROR;
else select 0 into b_i1 from hd_ma_nhom where ma=b_nhom;
end if;
if b_do_dai is null or b_do_dai=0 then
    b_loi:='loi:Nhap do dai phan ky hieu va so:loi'; raise PROGRAM_ERROR;
end if;
b_loi:='loi:Chon nghiep vu:loi';
if b_nv is null then raise PROGRAM_ERROR; end if;
select vp into b_vp from ht_ma_dvi where ma=b_ma_dvi;
select count(*) into b_i1 from hd_ma_hd where ma_dvi=b_ma_dvi and ma=b_ma;
if b_vp='C' then
     delete hd_ma_hd where ma=b_ma and nv=b_nv;
     insert into hd_ma_hd select ma,b_ma,b_mau,b_nhom,b_nv,b_ten,b_do_dai,b_lien,b_to,b_nsd from ht_ma_dvi;
     --insert into hd_ma_hd values(b_ma_dvi,b_ma,b_mau,b_nhom,b_nv,b_ten,b_do_dai,b_lien,b_to,b_nsd);
else
    delete hd_ma_hd where ma_dvi=b_ma_dvi and ma=b_ma and mau=b_mau and nv=b_nv;
    insert into hd_ma_hd values(b_ma_dvi,b_ma,b_mau,b_nhom,b_nv,b_ten,b_do_dai,b_lien,b_to,b_nsd);
end if;
/*if b_i1>0 then
    if b_vp='C' then
        update hd_ma_hd set mau=b_mau,ma_nhom=b_nhom,ten=b_ten,do_dai=b_do_dai,so_lien=b_lien,
            so_to=b_to,nsd=b_nsd where ma=b_ma;
    else
        update hd_ma_hd set mau=b_mau,ma_nhom=b_nhom,ten=b_ten,do_dai=b_do_dai,so_lien=b_lien,
            so_to=b_to,nsd=b_nsd where ma_dvi=b_ma_dvi and ma=b_ma;
    end if;
else
    if b_vp='C' then
        insert into hd_ma_hd select ma,b_ma,b_mau,b_nhom,b_ten,b_do_dai,b_lien,b_to,b_nsd from ht_ma_dvi;
    else insert into hd_ma_hd values(b_ma_dvi,b_ma,b_mau,b_nhom,b_ten,b_do_dai,b_lien,b_to,b_nsd);
    end if;
end if;*/
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHD_MA_HDJ_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000); b_vp varchar2(1);
    b_ma varchar2(20);b_mau varchar2(20);
    b_nhom varchar2(10);b_nv varchar2(20);b_do_dai number;b_ten nvarchar2(50);b_lien number;b_to number;
begin
-- viet anh - Nhap ma hoa don
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','MA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,mau,ma_nhom,nv,ten,do_dai,so_lien,so_to');
EXECUTE IMMEDIATE b_lenh into b_ma,b_mau,b_nhom,b_nv,b_ten,b_do_dai,b_lien,b_to using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma hoa don, an chi:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai nhom hoa don, an chi:loi';
if b_nhom is null then raise PROGRAM_ERROR;
else select 0 into b_i1 from hd_ma_nhom where ma=b_nhom;
end if;
if b_do_dai is null or b_do_dai=0 then
    b_loi:='loi:Nhap do dai phan ky hieu va so:loi'; raise PROGRAM_ERROR;
end if;
b_loi:='loi:Chon nghiep vu:loi';
if b_nv is null then raise PROGRAM_ERROR; end if;
select vp into b_vp from ht_ma_dvi where ma=b_ma_dvi;
select count(*) into b_i1 from hd_ma_hd where ma_dvi=b_ma_dvi and ma=b_ma;
if b_vp='C' then
     delete hd_ma_hd where ma=b_ma and nv=b_nv;
     insert into hd_ma_hd select ma,b_ma,b_mau,b_nhom,b_nv,b_ten,b_do_dai,b_lien,b_to,b_nsd from ht_ma_dvi;
     --insert into hd_ma_hd values(b_ma_dvi,b_ma,b_mau,b_nhom,b_nv,b_ten,b_do_dai,b_lien,b_to,b_nsd);
else
    delete hd_ma_hd where ma_dvi=b_ma_dvi and ma=b_ma and mau=b_mau and nv=b_nv;
    insert into hd_ma_hd values(b_ma_dvi,b_ma,b_mau,b_nhom,b_nv,b_ten,b_do_dai,b_lien,b_to,b_nsd);
end if;
/*if b_i1>0 then
    if b_vp='C' then
        update hd_ma_hd set mau=b_mau,ma_nhom=b_nhom,ten=b_ten,do_dai=b_do_dai,so_lien=b_lien,
            so_to=b_to,nsd=b_nsd where ma=b_ma;
    else
        update hd_ma_hd set mau=b_mau,ma_nhom=b_nhom,ten=b_ten,do_dai=b_do_dai,so_lien=b_lien,
            so_to=b_to,nsd=b_nsd where ma_dvi=b_ma_dvi and ma=b_ma;
    end if;
else
    if b_vp='C' then
        insert into hd_ma_hd select ma,b_ma,b_mau,b_nhom,b_ten,b_do_dai,b_lien,b_to,b_nsd from ht_ma_dvi;
    else insert into hd_ma_hd values(b_ma_dvi,b_ma,b_mau,b_nhom,b_ten,b_do_dai,b_lien,b_to,b_nsd);
    end if;
end if;*/
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHD_MA_HDJ_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(20):=FKH_JS_GTRIs(b_oraIn,'ma');
    b_vp varchar2(1);
begin
-- viet anh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','MA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma hoa don, an chi:loi'; raise PROGRAM_ERROR; end if;
select vp into b_vp from ht_ma_dvi where ma=b_ma_dvi;
if b_vp='C' then
    select count(*) into b_i1 from hd_2 where ma=b_ma;
    if b_i1<>0 then b_loi:='loi:Ma dang su dung:loi'; raise PROGRAM_ERROR; end if;
    delete hd_ma_hd where ma=b_ma;
else
    select count(*) into b_i1 from hd_2 where ma_dvi=b_ma_dvi and ma=b_ma;
    if b_i1<>0 then b_loi:='loi:Ma dang su dung:loi'; raise PROGRAM_ERROR; end if;
    delete hd_ma_hd where ma_dvi=b_ma_dvi and ma=b_ma;
end if;
commit;
exception when others then raise_application_error(-20105,b_loi);
end;
/
create or replace procedure PHD_MA_HDJ_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_ct clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- viet anh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','MA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma_dvi,ma,mau,ma_nhom,nv,ten,do_dai,so_lien,so_to,nsd) into cs_ct from hd_ma_hd where ma_dvi=b_ma_dvi and ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- viet anh -- prod thieu
create or replace procedure PHD_MA_HDJ_LKE(
     b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob;
begin
-- viet anh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from hd_ma_hd where ma_dvi=b_ma_dvi;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(ma_dvi,ma,ten) obj,ROW_NUMBER() over (order by ma) as sott from
            (select * from hd_ma_hd where ma_dvi=b_ma_dvi order by ma))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from hd_ma_hd where ma_dvi=b_ma_dvi and upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,ROW_NUMBER() over (order by ma) as sott from
            (select ma_dvi,ma,ten,json_object(a.*,'xep' value ma) obj from hd_ma_hd a)
            where ma_dvi=b_ma_dvi and upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHD_MA_HDJ_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','MA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from hd_ma_hd where ma_dvi=b_ma_dvi;
select nvl(min(sott),0) into b_tu from (select ma_dvi,ma,ROW_NUMBER() over (order by ma) as sott from hd_ma_hd where ma_dvi=b_ma_dvi
                        order by ma) where ma>=b_ma;
PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
    (select ma_dvi,ma,ten,nsd,ROW_NUMBER() over (order by ma) as sott from hd_ma_hd where ma_dvi=b_ma_dvi order by ma)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHD_MA_NHJ_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob;
begin
-- viet anh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','MA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from hd_ma_nhom where ma_dvi=b_ma_dvi;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select json_object(*) obj,ROW_NUMBER() over (order by ten) as sott from
            (select * from hd_ma_nhom where ma_dvi=b_ma_dvi order by ten))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from hd_ma_nhom where ma_dvi=b_ma_dvi and upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj returning clob) into cs_lke from
        (select obj,ROW_NUMBER() over (order by ten) as sott from
            (select ma,ten,json_object(a.*,'xep' value ma) obj from hd_ma_nhom a where ma_dvi=b_ma_dvi)
            where upper(ten) like b_tim order by ten)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHD_MA_QLYJ_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma_qly varchar2(10); b_lenh varchar2(1000);
begin
-- Lan - Nhap muc qly
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_qly');
EXECUTE IMMEDIATE b_lenh into b_ma_qly using b_oraIn;
b_loi:='loi:Va cham NSD:loi';
delete hd_ma_qly where ma_dvi=b_ma_dvi;
insert into hd_ma_qly values(b_ma_dvi,b_ma_qly,b_nsd,sysdate);
commit;
exception when others then raise_application_error(-20105,b_loi);
end;
/
create or replace procedure PHD_CT_TIM_J
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000);b_loi varchar2(100); b_n1 number; b_n2 number; b_dc0 varchar2(4); b_dc1 varchar2(4);b_lct varchar2(1);
    b_ngay_d number;b_ngay_c number;b_loai_nh varchar2(10);b_ma_nh varchar2(10);b_ma_tke varchar2(10);
    b_ma varchar2(20);b_nd nvarchar2(10);b_so number;b_so_c number;b_tu number; b_den number;
    b_dong number;cs_lke clob;
begin
-- Tim kiem chung tu hoa don Da sua theo JS
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HD','NX','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('l_ct,ngay_d,ngay_c,loai_n,ma_n,tke,ma,nd,dau,cuoi,tu,den');
EXECUTE IMMEDIATE b_lenh into b_lct,b_ngay_d,b_ngay_c,b_loai_nh,b_ma_nh,b_ma_tke,b_ma,b_nd,b_so,b_so_c,b_tu,b_den using b_oraIn;
delete temp_1; commit;
if b_lct='T' then
    insert into temp_1(n1) select so_id from hd_1 where ma_dvi=b_ma_dvi and
       (ngay_ht between b_ngay_d and b_ngay_c)
       and (b_nd is null or upper(nd) like b_nd)
       and (b_ma_nh is null or (loai_n=b_loai_nh and ma_n=b_ma_nh));
else
    insert into temp_1(n1) select so_id from hd_1 where ma_dvi=b_ma_dvi and
       (ngay_ht between b_ngay_d and b_ngay_c) and l_ct=b_lct and (b_nd is null or upper(nd) like b_nd)
       and (b_ma_nh is null or (loai_n=b_loai_nh and ma_n=b_ma_nh));
end if;
if b_ma is not null then
    delete temp_3;
    if nvl(b_so,0)=0 then
       delete temp_1 where not exists
           (select * from hd_2 where ma_dvi=b_ma_dvi and so_id=n1 and ma=b_ma);
    else
        if b_so_c=0 then
            insert into temp_3(n1) values (b_so);
        else
            for b_lp in b_so..b_so_c loop
                insert into temp_3(n1) values (b_lp);
            end loop;
        end if;
        delete temp_2;
        for b_lpp in (select n1 from temp_3 order by n1) loop
            b_n1:=b_lpp.n1;
            insert into temp_2(n1) select so_id from hd_2 where ma_dvi=b_ma_dvi and ma=b_ma and b_n1 between dau and cuoi;
        end loop;
        delete temp_1 where n1 not in (select n1 from temp_2);
    end if;
end if;
delete temp_2;
insert into temp_2(n1,c1,c2,c3,c4,c5,c6,c7,n2) select distinct b.so_id,b.l_ct,so_ct,loai_n,ma_n,nd,ma,PKH_SO_CNG(b.ngay_ht),b.ngay_ht
    from hd_1 b,hd_2 c where b.ma_dvi=b_ma_dvi and b.so_id=c.so_id and b.so_id in (select n1 from temp_1) and (c.ma=b_ma or b_ma is null) and
    c.ma_dvi=b_ma_dvi and (b_ma_tke='A' or c.ma_tke=b_ma_tke);
select count(*) into b_dong from temp_2;
select JSON_ARRAYAGG(obj returning clob) into cs_lke from
    (select JSON_OBJECT(so_id,l_ct,so_ct,loai_n,ma_n,nd,ma,ngay_htc) obj from (select n1 so_id, c1 l_ct,c2 so_ct,c3 loai_n,c4 ma_n,c5 nd,c6 ma,c7 ngay_htc,
    row_number() over (order by n2,c2) sott from temp_2 order by n1) where sott between b_tu and b_den);
select json_object('dong' value b_dong, 'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then raise_application_error(-20105,b_loi);
end;
/