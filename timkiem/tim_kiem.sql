create or replace procedure PBH_2B_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_id number; b_so_idC number; b_ma_kh varchar2(20); b_xe_id number; b_so_hd varchar2(30);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number; b_ttrang varchar2(1);
    b_bien_xe varchar2(20); b_so_khung varchar2(30);
    b_ten nvarchar2(200); b_phong varchar2(10); b_nv varchar2(1);
    b_tu number; b_den number; b_qu varchar2(1);
begin
-- viet anh
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','2B','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,bien_xe,so_khung,ten,so_hd,tu,den,nv');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_bien_xe,b_so_khung,b_ten,b_so_hd,b_tu,b_den,b_nv using b_oraIn;
b_nv:=nvl(b_nv,'G');
b_ttrang:=nvl(trim(b_ttrang),' '); b_so_hd:=nvl(trim(b_so_hd),' '); b_ten:=upper(nvl(TRIM(b_ten), ' '));
b_cmt:=nvl(trim(b_cmt),' '); b_mobi:=nvl(trim(b_mobi),' '); b_email:=nvl(trim(b_email),' ');
b_bien_xe:=nvl(trim(b_bien_xe),' '); b_so_khung:=nvl(trim(b_so_khung),' ');
-- them phan quyen
b_qu:=FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','2B','X');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
b_xe_id:=FBH_2Btso_SO_ID(b_bien_xe,b_so_khung);
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    insert into temp_1(n1)
        select distinct so_id_d from bh_2b a, bh_2b_ds b where
            a.so_id=b.so_id and a.ma_dvi=b_ma_dvi and b_xe_id in(0,b.xe_id) and a.ma_kh = b_ma_kh
            and nv=b_nv and a.ngay_ht between b_ngayD and b_ngayC and (phong=b_phong or b_qu='C')
            and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%')
            and b_ttrang in (' ',ttrang) and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%');
elsif trim(b_bien_xe||b_so_khung) is not null then
    insert into temp_1(n1)
      select distinct so_id_d from bh_2b a, bh_2b_ds b where
          a.so_id=b.so_id and a.ma_dvi=b_ma_dvi and b_xe_id=xe_id
          and nv=b_nv and a.ngay_ht between b_ngayD and b_ngayC and (phong=b_phong or b_qu='C')
          and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%')
          and b_ttrang in (' ',ttrang) and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%');
else
    insert into temp_1(n1)
        select distinct so_id_d from bh_2b a, bh_2b_ds b where
            a.so_id=b.so_id and a.ma_dvi=b_ma_dvi and b_xe_id in(0,b.xe_id)
            and nv=b_nv and a.ngay_ht between b_ngayD and b_ngayC and (phong=b_phong or b_qu='C')
            and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%')
            and b_ttrang in (' ',ttrang) and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%');
end if;
for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
  b_so_idC:=FBH_2B_SO_IDc(b_ma_dvi,r_lp.so_id_d);
  insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10,c10,c11,c12,c13,c14)
    select t.so_hd,FBH_2B_TTRANG(b_ma_dvi,b_so_idC),tenc,cmtc,t.ngay_hl,t.ngay_kt,t.ngay_cap,b_so_idC,
           t.nv,bien_xe,so_khung,so_may,gcn
        from bh_2b t, bh_2b_ds t1 where t.so_id=t1.so_id and t.ma_dvi=b_ma_dvi and t.so_id=b_so_idC
            and nv=b_nv and t.ngay_ht between b_ngayD and b_ngayC and (phong=b_phong or b_qu='C')
            and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%')
            and b_ttrang in (' ',ttrang) and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%');
end loop;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'ma_dvi' value b_ma_dvi,'so_id' value n10,'nv' value c10,'bien_xe' value c11,
     'so_khung' value c12,'so_may' value c13,'gcn' value c14) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n3 desc, n10 desc) as sott from ket_qua t 
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_2B_BPHI_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); cs_lke clob; b_dong number;
    b_ma_sp varchar2(200); b_nhom varchar2(200); b_nv_bh varchar2(200); b_md_sd varchar2(200);
    b_loai_xe varchar2(200); b_nhom_xe varchar(200); b_dong_xe varchar2(200); b_dco varchar2(20);
    b_ttai number; b_so_cn number; b_gia number; b_tuoi number;
    b_tu number; b_den number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','2B','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_sp,nhom,nv_bh,md_sd,loai_xe,nhom_xe,dong_xe,dco,ttai,so_cn,gia,tuoi,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ma_sp,b_nhom,b_nv_bh,b_md_sd,b_loai_xe,b_nhom_xe,b_dong_xe,b_dco,b_ttai,b_so_cn,b_gia,b_tuoi,
        b_tu,b_den using b_oraIn;
b_ma_sp:=nvl(trim(b_ma_sp),' '); b_nhom:=nvl(trim(b_nhom),' ');
b_nv_bh:=nvl(trim(b_nv_bh),' '); b_md_sd:=nvl(trim(b_md_sd),' ');
--viet anh
b_loai_xe:=trim(PKH_MA_TENl(b_loai_xe)); b_nhom_xe:=trim(PKH_MA_TENl(b_nhom_xe));
b_dong_xe:=trim(PKH_MA_TENl(b_dong_xe)); b_dco:=trim(PKH_MA_TENl(b_dco));
b_ma_sp:=PKH_MA_TENl(b_ma_sp); b_nhom:=PKH_MA_TENl(b_nhom);
b_nv_bh:=PKH_MA_TENl(b_nv_bh); b_md_sd:=PKH_MA_TENl(b_md_sd);
select count(*) into b_dong from bh_2b_phi
  where b_nhom in (' ',nhom)
        and b_ma_sp in (' ',ma_sp) and b_md_sd in (' ',md_sd) and b_nv_bh in (' ',nv_bh)
        and (b_loai_xe = ' ' OR loai_xe LIKE '%' || b_loai_xe || '%') and (b_nhom_xe = ' ' OR nhom_xe LIKE '%' || b_nhom_xe || '%')
        and (b_dong_xe = ' ' OR dong LIKE '%' || b_dong_xe || '%') and (b_dco = ' ' OR dco LIKE '%' || b_dco || '%') 
        and b_ttai in (0,ttai) and b_so_cn in (0,so_cn) and b_gia in (0,gia) and b_tuoi in (0,tuoi);
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object('ma_sp' value FBH_2B_SP_TEN(ma_sp),'cdich' value FBH_MA_CDICH_TEN(cdich),'goi' value FBH_2B_GOI_TEN(goi),
    nhom,nv_bh,bh_tbo,'md_sd' value FBH_2B_MDSD_TEN(md_sd),'loai_xe' value FBH_2B_LOAI_TEN(loai_xe),'nhom_xe' value FBH_2B_NHOM_TEN(nhom_xe),
    'dong' value FBH_XE_DONG_TEN(dong),dco,ttai,so_cn,tuoi,gia,ngay_bd,ngay_kt,so_id)
    order by ma_sp,cdich,goi,nhom,nv_bh,bh_tbo,md_sd,loai_xe,nhom_xe,dong,dco,ttai,so_cn,tuoi,gia returning clob) into cs_lke from
    (select ma_sp,cdich,goi,nhom,nv_bh,bh_tbo,md_sd,loai_xe,nhom_xe,dong,
            dco,ttai,so_cn,tuoi,gia,ngay_bd,ngay_kt,so_id,rownum sott from bh_2b_phi
      where b_nhom in (' ',nhom)
          and b_ma_sp in (' ',ma_sp) and b_md_sd in (' ',md_sd) and b_nv_bh in (' ',nv_bh)
          and (b_loai_xe = ' ' OR loai_xe LIKE '%' || b_loai_xe || '%') and (b_nhom_xe = ' ' OR nhom_xe LIKE '%' || b_nhom_xe || '%')
          and (b_dong_xe = ' ' OR dong LIKE '%' || b_dong_xe || '%') and (b_dco = ' ' OR dco LIKE '%' || b_dco || '%')
          and b_ttai in (0,ttai) and b_so_cn in (0,so_cn) and b_gia in (0,gia) and b_tuoi in (0,tuoi)
         order by cdich,goi,bh_tbo,loai_xe,nhom_xe,dong,dco,ttai,so_cn,tuoi,gia)
      where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_2B_TIMh(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_id number; b_so_idC number; b_ma_kh varchar2(20); b_xe_id number; b_so_hd varchar2(30); b_so_hd_c varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number; b_ttrang varchar2(1);
    b_bien_xe varchar2(20); b_so_khung varchar2(30);
    b_ten nvarchar2(200); b_phong varchar2(10); b_nv varchar2(1);
    b_tu number; b_den number; b_qu varchar2(1);
begin
-- viet anh
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','2B','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,bien_xe,so_khung,ten,so_hd,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_bien_xe,b_so_khung,b_ten,b_so_hd,b_tu,b_den using b_oraIn;
b_ttrang:=nvl(trim(b_ttrang),' '); b_so_hd:=nvl(trim(b_so_hd),' '); b_ten:=upper(nvl(TRIM(b_ten), ' '));
b_cmt:=nvl(trim(b_cmt),' '); b_mobi:=nvl(trim(b_mobi),' '); b_email:=nvl(trim(b_email),' ');
b_bien_xe:=nvl(trim(b_bien_xe),' '); b_so_khung:=nvl(trim(b_so_khung),' ');

if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
b_xe_id:=FBH_2Btso_SO_ID(b_bien_xe,b_so_khung);
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    insert into temp_1(n1)
        select distinct so_id_d from bh_2b a, bh_2b_ds b where
            a.so_id=b.so_id and a.ma_dvi=b_ma_dvi and b_xe_id in(0,b.xe_id) and a.ma_kh = b_ma_kh
            and a.ngay_ht between b_ngayD and b_ngayC 
            and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%')
            and ttrang='D' and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%');
else
    insert into temp_1(n1)
        select distinct so_id_d from bh_2b a, bh_2b_ds b where
            a.so_id=b.so_id and a.ma_dvi=b_ma_dvi and b_xe_id in(0,b.xe_id)
            and a.ngay_ht between b_ngayD and b_ngayC 
            and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%')
            and ttrang='D' and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%');
end if;
for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
  b_so_idC:=FBH_2B_SO_IDc(b_ma_dvi,r_lp.so_id_d);
  select max(so_hd),max(nv) into b_so_hd,b_nv from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_idC;
     insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10,c10,c11,c12,c13,c14,c15)
        select t.so_hd,FBH_2B_TTRANG(b_ma_dvi,b_so_idC),tenc,cmtc,t.ngay_hl,t.ngay_kt,t.ngay_cap,b_so_idC,
               t.nv,bien_xe,so_khung,so_may,gcn,so_id_dt
            from bh_2b t, bh_2b_ds t1 where t.so_id=t1.so_id and t.ma_dvi=b_ma_dvi and t.so_id=b_so_idC
                and b_xe_id in(0,t1.xe_id) and t.ngay_ht between b_ngayD and b_ngayC 
                and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%')
                and ttrang='D' and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%');  
end loop;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'ma_dvi' value b_ma_dvi,'so_id' value n10,'nv' value c10,'bien_xe' value c11,
     'so_khung' value c12,'so_may' value c13,'gcn' value c14, 'so_id_dt' value c15 returning clob)
   returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n10 desc) as sott from ket_qua t 
      ) where sott between b_tu and b_den and rownum<202);
select count(*) into b_dong from ket_qua where rownum<202;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_2B_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36)); cs_ct clob:=''; cs_lke clob:='';
    b_so_id number; b_so_idC number; b_so_idD number; b_ttrang  varchar2(1); b_nv varchar2(1);
    b_ma_kh varchar2(20); b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ngayD number; b_ngayC number; b_so_hsT varchar2(20); b_so_hd varchar2(20);
    b_bien_xe varchar2(20); b_so_khung varchar2(30); b_so_may varchar2(30); b_ten nvarchar2(200);
    b_dong number; b_xe_id number;
    b_tu number; b_den number;
begin
-- Dan - Tim hop dong qua CMT, mobi, email
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','2B','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('dt_ct');
EXECUTE IMMEDIATE b_lenh into cs_ct using b_oraIn;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,bien_xe,so_khung,so_may,ten,so_hs,so_hd,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_bien_xe,b_so_khung,b_so_may,b_ten,b_so_hsT,b_so_hd,
                              b_tu,b_den using cs_ct;
b_xe_id:=FBH_2Btso_SO_ID(b_bien_xe,b_so_khung);
b_ttrang:=nvl(trim(b_ttrang),' '); b_ten:=nvl(trim(upper(b_ten)),' ');
b_so_hd:=nvl(trim(b_so_hd),' '); b_so_hsT:=nvl(trim(b_so_hsT),' ');
b_cmt:=nvl(trim(b_cmt),' '); b_mobi:=nvl(trim(b_mobi),' '); b_email:=nvl(trim(b_email),' ');
b_bien_xe:=nvl(trim(b_bien_xe),' '); b_so_khung:=nvl(trim(b_so_khung),' '); b_so_may:=nvl(trim(b_so_may),' ');
if b_xe_id is null then b_loi:='loi:Khong tim duoc xe:loi'; raise PROGRAM_ERROR; end if;
if b_ngayd in (0,30000101) then b_ngayd:=b_ngay; end if;
b_ma_kh:=FBH_DTAC_MAf('','',b_cmt,b_mobi,b_email,'','');
select count(*) into b_dong
    from bh_bt_2b a, bh_bt_2b_ct b where
        a.so_id = b.so_id and a.ma_dvi=b_ma_dvi and (a.ma_kh = b_ma_kh OR b_ma_kh IS NULL)
        and b_xe_id in (0, b.xe_id) and b_ttrang in (' ', a.ttrang)
        and (b_so_hd = ' ' OR a.so_hd LIKE '%' || b_so_hd || '%' OR a.gcn LIKE '%' || b_so_hd || '%')
        and (b_so_hsT = ' ' OR a.so_hs LIKE '%' || b_so_hsT || '%') and (b_ten = ' ' OR upper(a.ten) LIKE '%' || b_ten || '%')
        and a.ngay_ht between b_ngayd and b_ngayc and a.ngay_ht > b_ngay
        and rownum<202;
select JSON_ARRAYAGG(json_object(so_hs,'ngay' value ngay_xr,ttrang,so_hd,ten,gcn,ma_dvi,so_id,bien_xe returning clob) 
       order by so_id desc returning clob)
    into cs_lke from ( select a.*,b.bien_xe, rownum as sott
       from bh_bt_2b a, bh_bt_2b_ct b where
          a.so_id = b.so_id and a.ma_dvi=b_ma_dvi and (a.ma_kh = b_ma_kh OR b_ma_kh IS NULL)
          and b_xe_id in (0, b.xe_id) and b_ttrang in (' ', a.ttrang)
          and (b_so_hd = ' ' OR a.so_hd LIKE '%' || b_so_hd || '%' OR a.gcn LIKE '%' || b_so_hd || '%')
          and (b_so_hsT = ' ' OR a.so_hs LIKE '%' || b_so_hsT || '%') and (b_ten = ' ' OR upper(a.ten) LIKE '%' || b_ten || '%')
          and a.ngay_ht between b_ngayd and b_ngayc and a.ngay_ht > b_ngay
          and rownum<202
    ) where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* Hang */
create or replace procedure PBH_HANG_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(100); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_id number; b_so_idC number; b_ma_kh varchar2(20); b_so_hd varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number; b_ttrang varchar2(1);
    b_ten nvarchar2(500); b_phong varchar2(10);
    b_tu number; b_den number; b_qu varchar2(1);
begin
-- viet anh - Tim hop dong qua CMT, mobi, email
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,so_hd,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_ten,b_so_hd,b_tu,b_den using b_oraIn;
b_ttrang:=nvl(trim(b_ttrang),' '); b_ten:=nvl(trim(upper(b_ten)),' '); b_so_hd:=nvl(trim(b_so_hd),' ');
b_cmt:=nvl(trim(b_cmt),' '); b_mobi:=nvl(trim(b_mobi),' '); b_email:=nvl(trim(b_email),' ');
if b_ngayC=0 then b_ngayC:=30000101; end if;
if b_ngayd in (0,30000101) then b_ngayd:=b_ngay; end if;
-- them phan quyen
b_qu:=FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','HANG','X');
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    insert into temp_1(n1)
        select distinct so_id_d from bh_hang where
            ma_dvi=b_ma_dvi and ma_kh = b_ma_kh and (phong=b_phong or b_qu='C') 
            and ngay_ht between b_ngayD and b_ngayC and b_ttrang in (' ',ttrang)
            and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%')
            and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%');
else
    insert into temp_1(n1)
        select distinct so_id_d from bh_hang where
            ma_dvi=b_ma_dvi and (phong=b_phong or b_qu='C') 
            and ngay_ht between b_ngayD and b_ngayC and b_ttrang in (' ',ttrang)
            and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%')
            and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%');
end if;
for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
  b_so_idC:=FBH_HANG_SO_IDc(b_ma_dvi,r_lp.so_id_d);
  select max(so_hd) into b_so_hd from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_idC;
  insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10,c10)
      select so_hd,FBH_HANG_TTRANG(b_ma_dvi,b_so_idC),ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_so_idC,'H'
          from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_idC; 
end loop;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'ma_dvi' value b_ma_dvi,'so_id' value n10,'nv' value c10 ) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n10 desc) as sott from ket_qua t 
      ) where sott between b_tu and b_den and rownum<202);
select count(*) into b_dong from ket_qua where rownum<202;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_HANG_TIMh(
     b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36)); cs_lke clob:='';
    b_so_id number; b_so_idC number; b_so_idD number; b_nv varchar2(1);
    b_ma_kh varchar2(20); b_so_hd varchar2(20); b_ma_dviD varchar2(10);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100); b_dong number;
    b_ngayD number; b_ngayC number; b_ttrang varchar2(1);
    b_ten nvarchar2(500); b_tu number; b_den number;
begin
-- Dan - Tim hop dong qua CMT, mobi, email
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('dt_ct');
EXECUTE IMMEDIATE b_lenh into cs_lke using b_oraIn;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,so_hd,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_ten,b_so_hd,b_tu,b_den using cs_lke;
b_ttrang:=nvl(trim(b_ttrang),' '); b_ten:=nvl(trim(upper(b_ten)),' '); b_so_hd:=nvl(trim(b_so_hd),' ');
if b_ngayC=0 then b_ngayC:=30000101; end if;
if b_ngayd in (0,30000101) then b_ngayd:=b_ngay; end if;
b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
for r_lp in (
    select distinct ma_dvi,so_id_d from bh_hang where
         (ma_kh = b_ma_kh OR b_ma_kh IS NULL) and ngay_ht between b_ngayD and b_ngayC and b_ttrang in (' ',ttrang)
         and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%')
         and ngay_kt>b_ngay
) loop
    b_ma_dviD:=r_lp.ma_dvi; b_so_idD:=r_lp.so_id_d;
    b_so_idC:=FBH_HANG_SO_IDc(b_ma_dviD,b_so_idD);
    if FBH_HANG_TTRANG(b_ma_dviD,b_so_idC)='D' then
        b_so_hd:=FBH_HANG_SO_HDd(b_ma_dviD,b_so_idD);
        insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c10)
            select so_hd,ten,ngay_hl,ngay_kt,ngay_cap,b_so_idD,0,'H' from bh_hang where ma_dvi=b_ma_dviD and so_id=b_so_idC;
        insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c10)
            select ' ','- '||ten_hang,0,0,0,b_so_idD,0,'H' from bh_hang_ds where ma_dvi=b_ma_dviD and so_id=b_so_idC order by bt;
    end if;
end loop;
select count(*) into b_dong from ket_qua where rownum<202;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ten' value c2,'ngay_hl' value n1,'ngay_kt' value n2,'ngay_cap' value n3,
    'so_id' value n10,'so_id_dt' value n11,'nv' value c10 returning clob) order by n10 desc,n11 returning clob) into cs_lke from (
        select * from ( 
            select t.*, ROW_NUMBER() over (order by n10 desc,n11) as sott from ket_qua t 
        ) where sott between b_tu and b_den and rownum<202);
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_HANG_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_ngay number:=PKH_NG_CSO(add_months(sysdate,-1)); cs_lke clob:='';
    b_ma_kh varchar2(20); b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ngayd number;b_ngayc number;b_so_hsT varchar2(20); b_ttrang varchar2(1); b_dong number;
    b_ten nvarchar2(200); b_so_hd varchar2(20);
    b_tu number; b_den number;
begin
-- Dan - Tim hop dong qua CMT, mobi, email
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('dt_ct');
EXECUTE IMMEDIATE b_lenh into cs_lke using b_oraIn;
b_lenh:=FKH_JS_LENH('cmt,mobi,email,ngayd,ngayc,ten,so_hs,ttrang,so_hd,tu,den');
EXECUTE IMMEDIATE b_lenh into b_cmt,b_mobi,b_email,b_ngayd,b_ngayc,b_ten,b_so_hsT,b_ttrang,b_so_hd,b_tu,b_den using cs_lke;
b_ttrang:=nvl(trim(b_ttrang),' '); b_ten:=nvl(trim(upper(b_ten)),' ');
b_so_hsT:=nvl(trim(b_so_hsT),' '); b_so_hd:=nvl(trim(b_so_hd),' ');
if b_ngayd in (0,30000101) then b_ngayd:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_ma_kh:=FBH_DTAC_MAf('','',b_cmt,b_mobi,b_email,'','');
select JSON_ARRAYAGG(json_object(so_hs,'ngay' value ngay_xr,ttrang,so_hd,ten,ma_dvi,so_id returning clob) order by so_id desc returning clob) 
   into cs_lke from (
      select * from ( select t.*, ROW_NUMBER() over (order by so_id desc) as sott
          from bh_bt_hang t where (b_ma_kh is null or b_ma_kh = '' OR ma_kh = b_ma_kh)
            and b_ttrang in (' ', ttrang) and (b_so_hsT = ' ' OR so_hs LIKE '%' || b_so_hsT || '%')
            and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') and ngay_ht between b_ngayd and b_ngayc
            and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%')
            and ngay_ht > b_ngay and rownum<202
      ) where sott between b_tu and b_den );
select count(*) into b_dong
   from ( select t.*, ROW_NUMBER() over (order by so_id desc) as sott
      from bh_bt_hang t where (b_ma_kh is null or b_ma_kh = '' OR ma_kh = b_ma_kh)
        and b_ttrang in (' ', ttrang) and (b_so_hsT = ' ' OR so_hs LIKE '%' || b_so_hsT || '%')
        and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') and ngay_ht between b_ngayd and b_ngayc
        and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%')
        and ngay_ht > b_ngay and rownum<202);
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* nguoi */
create or replace procedure PBH_NGDL_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(100); b_lenh varchar2(2000);
    b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36)); cs_lke clob:='';
    b_so_idD number; b_so_idC number; b_so_id_dt number; b_nv varchar2(1);
    b_ma_kh varchar2(20):=''; b_so_hd varchar2(20); b_ttrang varchar2(1);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ten nvarchar2(200); b_gioi varchar2(1); b_ng_sinh number; b_dong number;
    b_ngayD number; b_ngayC number; b_ngay_ht number; b_ttrangT varchar2(1);
    b_tu number; b_den number; b_qu varchar2(1); b_phong varchar2(10);
begin
-- viet anh
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,gioi,ng_sinh,so_hd,tu,den,nv');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrangT,b_cmt,b_mobi,b_email,b_ten,b_gioi,b_ng_sinh,b_so_hd,b_tu,b_den,b_nv using b_oraIn;
b_ttrangT:=nvl(trim(b_ttrangT),' '); b_ten:=nvl(TRIM(upper(b_ten)), ' '); b_so_hd:=nvl(trim(b_so_hd),' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
-- them phan quyen
b_qu:=FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','NG','X');
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAf('','',b_cmt,b_mobi,b_email,b_gioi,b_ng_sinh);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    insert into temp_1(n1)
        select distinct so_id_d from bh_ngdl a, bh_ngdl_ds b where
           a.so_id=b.so_id and a.ma_kh=b_ma_kh and a.ma_dvi=b_ma_dvi and nv=b_nv
           and a.ngay_ht between b_ngayD and b_ngayC and b_ttrangT in (' ',a.ttrang)
           and (b_ten = ' ' OR upper(a.ten) LIKE '%' || b_ten || '%')
           and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%');
else
    insert into temp_1(n1)
        select distinct so_id_d from bh_ngdl a, bh_ngdl_ds b where
           a.so_id=b.so_id and a.ma_dvi=b_ma_dvi and nv=b_nv
           and a.ngay_ht between b_ngayD and b_ngayC and b_ttrangT in (' ',a.ttrang)
           and (b_ten = ' ' OR upper(a.ten) LIKE '%' || b_ten || '%')
           and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%');
end if;
for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
  b_so_idC:=FBH_NGDL_SO_IDc(b_ma_dvi,r_lp.so_id_d);
  select max(so_hd) into b_so_hd from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_idC;
     insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10,c10)
        select so_hd,FBH_NGDL_TTRANG(b_ma_dvi,b_so_idC),ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_so_idC,nv
            from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_idC;    
end loop;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'ma_dvi' value b_ma_dvi,'so_id' value n10,'nv' value c10) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n10 desc) as sott from ket_qua t
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(100); b_lenh varchar2(2000);
    b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36)); cs_lke clob:='';
    b_so_idD number; b_so_idC number; b_so_id_dt number; b_nv varchar2(1);
    b_ma_kh varchar2(20):=''; b_so_hd varchar2(20); b_ttrang varchar2(1);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ten nvarchar2(200); b_gioi varchar2(1); b_ng_sinh number; b_dong number;
    b_ngayD number; b_ngayC number; b_ngay_ht number; b_ttrangT varchar2(1);
    b_tu number; b_den number; b_qu varchar2(1); b_phong varchar2(10);
begin
-- viet anh
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,gioi,ng_sinh,so_hd,tu,den,nv');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrangT,b_cmt,b_mobi,b_email,b_ten,b_gioi,b_ng_sinh,b_so_hd,b_tu,b_den,b_nv using b_oraIn;
b_ttrangT:=nvl(trim(b_ttrangT),' '); b_ten:=nvl(TRIM(upper(b_ten)), ' '); b_so_hd:=nvl(trim(b_so_hd),' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
-- them phan quyen
b_qu:=FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','NG','X');
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAf('','',b_cmt,b_mobi,b_email,b_gioi,b_ng_sinh);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    insert into temp_1(n1)
        select distinct so_id_d from bh_sk a, bh_sk_ds b where
           a.so_id=b.so_id and a.ma_kh=b_ma_kh and a.ma_dvi=b_ma_dvi and nv=b_nv
           and a.ngay_ht between b_ngayD and b_ngayC and b_ttrangT in (' ',a.ttrang)
           and (b_ten = ' ' OR upper(a.ten) LIKE '%' || b_ten || '%')
           and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%');
else
    insert into temp_1(n1)
        select distinct so_id_d from bh_sk a, bh_sk_ds b where
           a.so_id=b.so_id and a.ma_dvi=b_ma_dvi and nv=b_nv
           and a.ngay_ht between b_ngayD and b_ngayC and b_ttrangT in (' ',a.ttrang)
           and (b_ten = ' ' OR upper(a.ten) LIKE '%' || b_ten || '%')
           and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%');
end if;
for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
  b_so_idC:=FBH_SK_SO_IDc(b_ma_dvi,r_lp.so_id_d);
  select max(so_hd) into b_so_hd from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_idC;
     insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10,c10)
        select so_hd,FBH_SK_TTRANG(b_ma_dvi,b_so_idC),ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_so_idC,nv
            from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_idC;       
end loop;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'ma_dvi' value b_ma_dvi,'so_id' value n10,'nv' value c10) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n10 desc) as sott from ket_qua t 
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SKN_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(100); b_lenh varchar2(2000);
    b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36)); cs_lke clob:='';
    b_so_idD number; b_so_idC number; b_so_id_dt number; b_nv varchar2(1);
    b_ma_kh varchar2(20):=''; b_so_hd varchar2(20); b_ttrang varchar2(1);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ten nvarchar2(200); b_gioi varchar2(1); b_ng_sinh number; b_dong number;
    b_ngayD number; b_ngayC number; b_ngay_ht number; b_ttrangT varchar2(1);
    b_tu number; b_den number; b_qu varchar2(1); b_phong varchar2(10);
begin
-- viet anh
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,gioi,ng_sinh,so_hd,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrangT,b_cmt,b_mobi,b_email,b_ten,b_gioi,b_ng_sinh,b_so_hd,b_tu,b_den using b_oraIn;
b_ttrangT:=nvl(trim(b_ttrangT),' '); b_ten:=nvl(TRIM(upper(b_ten)), ' '); b_so_hd:=nvl(trim(b_so_hd),' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
-- them phan quyen
b_qu:=FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','NG','X');
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAf('','',b_cmt,b_mobi,b_email,b_gioi,b_ng_sinh);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    insert into temp_1(n1)
        select distinct so_id_d from bh_skN where
           ma_kh=b_ma_kh and ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and b_ttrangT in (' ',ttrang)
           and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%')
           and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%');
else
    insert into temp_1(n1)
        select distinct so_id_d from bh_skN where
           ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and b_ttrangT in (' ',ttrang)
           and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%')
           and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%');
end if;
for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
  b_so_idC:=FBH_SKN_SO_IDc(b_ma_dvi,r_lp.so_id_d);
  select max(so_hd) into b_so_hd from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_idC;
     insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10,c10)
        select t.so_hd,FBH_SKN_TTRANG(b_ma_dvi,b_so_idC),t.ten,t.cmt,t.ngay_hl,t.ngay_kt,t.ngay_cap,b_so_idC,t.nv
            from bh_skN t where ma_dvi=b_ma_dvi and so_id=b_so_idC;  
end loop;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'ma_dvi' value b_ma_dvi,'so_id' value n10,'nv' value c10) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n10 desc) as sott from ket_qua t 
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGDLN_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(100); b_lenh varchar2(2000);
    b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36)); cs_lke clob:='';
    b_so_idD number; b_so_idC number; b_so_id_dt number; b_nv varchar2(1);
    b_ma_kh varchar2(20):=''; b_so_hd varchar2(20); b_ttrang varchar2(1);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ten nvarchar2(200); b_gioi varchar2(1); b_ng_sinh number; b_dong number;
    b_ngayD number; b_ngayC number; b_ngay_ht number; b_ttrangT varchar2(1);
    b_tu number; b_den number; b_qu varchar2(1); b_phong varchar2(10);
begin
-- viet anh
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,gioi,ng_sinh,so_hd,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrangT,b_cmt,b_mobi,b_email,b_ten,b_gioi,b_ng_sinh,b_so_hd,b_tu,b_den using b_oraIn;
b_ttrangT:=nvl(trim(b_ttrangT),' '); b_ten:=nvl(TRIM(upper(b_ten)), ' '); b_so_hd:=nvl(trim(b_so_hd),' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
-- them phan quyen
b_qu:=FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','NG','X');
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAf('','',b_cmt,b_mobi,b_email,b_gioi,b_ng_sinh);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    insert into temp_1(n1)
        select distinct so_id_d from bh_ngdlN where
           ma_kh=b_ma_kh and ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and b_ttrangT in (' ',ttrang)
           and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%')
           and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%');
else
    insert into temp_1(n1)
        select distinct so_id_d from bh_ngdlN where
           ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and b_ttrangT in (' ',ttrang)
           and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%')
           and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%');
end if;
for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
  b_so_idC:=FBH_NGDLN_SO_IDc(b_ma_dvi,r_lp.so_id_d);
  select max(so_hd) into b_so_hd from bh_ngdlN where ma_dvi=b_ma_dvi and so_id=b_so_idC;
     insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10,c10)
        select t.so_hd,FBH_NGDLN_TTRANG(b_ma_dvi,b_so_idC),t.ten,t.cmt,t.ngay_hl,t.ngay_kt,t.ngay_cap,b_so_idC,t.nv
            from bh_ngdlN t where ma_dvi=b_ma_dvi and so_id=b_so_idC;  
end loop;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'ma_dvi' value b_ma_dvi,'so_id' value n10,'nv' value c10) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n10 desc,c1) as sott from ket_qua t 
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SKU_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36)); cs_lke clob:='';
    b_so_idC number;
    b_ma_kh varchar2(20):=''; b_so_hd varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ten nvarchar2(200); b_gioi varchar2(1); b_ng_sinh number; b_dong number;
    b_ngayD number; b_ngayC number; b_ttrangT varchar2(1);
    b_tu number; b_den number; b_qu varchar2(1); b_phong varchar2(10);
begin
-- viet anh
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,gioi,ng_sinh,so_hd,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrangT,b_cmt,b_mobi,b_email,b_ten,b_gioi,b_ng_sinh,b_so_hd,b_tu,b_den using b_oraIn;
b_ttrangT:=nvl(trim(b_ttrangT),' '); b_ten:=nvl(TRIM(upper(b_ten)), ' '); b_so_hd:=nvl(trim(b_so_hd),' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
-- them phan quyen
b_qu:=FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','NG','X');
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAf('','',b_cmt,b_mobi,b_email,b_gioi,b_ng_sinh);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    insert into temp_1(n1)
        select distinct so_id_d from bh_sk a where
           a.ma_kh=b_ma_kh and a.ma_dvi=b_ma_dvi and nv='U'
           and a.ngay_ht between b_ngayD and b_ngayC and b_ttrangT in (' ',a.ttrang)
           and (b_ten = ' ' OR upper(a.ten) LIKE '%' || b_ten || '%')
           and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%')
           and not exists ( select 1 from bh_sk_ds b where b.so_id = a.so_id );
else
    insert into temp_1(n1)
        select distinct so_id_d from bh_sk a where
           a.ma_dvi=b_ma_dvi and nv='U'
           and a.ngay_ht between b_ngayD and b_ngayC and b_ttrangT in (' ',a.ttrang)
           and (b_ten = ' ' OR upper(a.ten) LIKE '%' || b_ten || '%')
           and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%')
           and not exists ( select 1 from bh_sk_ds b where b.so_id = a.so_id );
end if;
for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
  b_so_idC:=FBH_SK_SO_IDc(b_ma_dvi,r_lp.so_id_d);
  select max(so_hd) into b_so_hd from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_idC;
     insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10,c10)
        select t.so_hd,FBH_SK_TTRANG(b_ma_dvi,b_so_idC),t.ten,t.cmt,t.ngay_hl,t.ngay_kt,t.ngay_cap,b_so_idC,t.nv
            from bh_sk t where t.ma_dvi=b_ma_dvi and t.so_id=b_so_idC;
end loop;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'ma_dvi' value b_ma_dvi,'so_id' value n10,'nv' value c10) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n10 desc) as sott from ket_qua t
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGDLU_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36)); cs_lke clob:='';
    b_so_idC number;
    b_ma_kh varchar2(20):=''; b_so_hd varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ten nvarchar2(200); b_gioi varchar2(1); b_ng_sinh number; b_dong number;
    b_ngayD number; b_ngayC number; b_ttrangT varchar2(1);
    b_tu number; b_den number; b_qu varchar2(1); b_phong varchar2(10);
begin
-- viet anh
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,gioi,ng_sinh,so_hd,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrangT,b_cmt,b_mobi,b_email,b_ten,b_gioi,b_ng_sinh,b_so_hd,b_tu,b_den using b_oraIn;
b_ttrangT:=nvl(trim(b_ttrangT),' '); b_ten:=nvl(TRIM(upper(b_ten)), ' '); b_so_hd:=nvl(trim(b_so_hd),' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
-- them phan quyen
b_qu:=FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','NG','X');
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAf('','',b_cmt,b_mobi,b_email,b_gioi,b_ng_sinh);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    insert into temp_1(n1)
        select distinct so_id_d from bh_ngdl a where
           a.ma_kh=b_ma_kh and a.ma_dvi=b_ma_dvi and nv='U'
           and a.ngay_ht between b_ngayD and b_ngayC and b_ttrangT in (' ',a.ttrang)
           and (b_ten = ' ' OR upper(a.ten) LIKE '%' || b_ten || '%')
           and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%')
           and not exists ( select 1 from bh_ngdl_ds b where b.so_id = a.so_id );
else
    insert into temp_1(n1)
        select distinct so_id_d from bh_ngdl a where
           a.ma_dvi=b_ma_dvi and nv='U'
           and a.ngay_ht between b_ngayD and b_ngayC and b_ttrangT in (' ',a.ttrang)
           and (b_ten = ' ' OR upper(a.ten) LIKE '%' || b_ten || '%')
           and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%')
           and not exists ( select 1 from bh_ngdl_ds b where b.so_id = a.so_id );
end if;
for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
  b_so_idC:=FBH_NGDL_SO_IDc(b_ma_dvi,r_lp.so_id_d);
  select max(so_hd) into b_so_hd from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_idC;
     insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10,c10)
        select t.so_hd,FBH_NGDL_TTRANG(b_ma_dvi,b_so_idC),t.ten,t.cmt,t.ngay_hl,t.ngay_kt,t.ngay_cap,b_so_idC,t.nv
            from bh_ngdl t where t.ma_dvi=b_ma_dvi and t.so_id=b_so_idC;
end loop;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'ma_dvi' value b_ma_dvi,'so_id' value n10,'nv' value c10) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n10 desc) as sott from ket_qua t
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_NG_TIMh(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_i1 number; b_lenh varchar2(1000);
    b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36)); cs_lke clob:='';
    b_ma_dviD varchar2(10); b_so_id number; b_so_idD number; b_so_idC number; b_nv varchar2(10); b_ma_kh varchar2(20);
    b_ngayd number;b_ngayc number;b_ttrang varchar2(1);b_cmt varchar2(20);b_mobi varchar2(20);
    b_email varchar2(100);b_ten nvarchar2(200);b_ng_sinh number;b_gioi varchar2(1);b_so_hd varchar2(20);
    b_tu number; b_den number;
    b_dong number;
begin
-- Dan - Tim hop dong, gcn qua CMT,ten,ngay sinh,gioi tinh
delete temp_1; delete temp_2; delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,ng_sinh,gioi,so_hd,tu,den,nv');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_ten,b_ng_sinh,b_gioi,b_so_hd,b_tu,b_den,b_nv using b_oraIn;
b_ttrang:=nvl(trim(b_ttrang),' '); b_so_hd:=upper(nvl(trim(b_so_hd),' ')); b_ten:=upper(nvl(TRIM(b_ten), ' '));
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
b_ma_kh:=FBH_DTAC_MAf('',b_ten,b_cmt,b_mobi,b_email,b_gioi,b_ng_sinh);
if b_ma_kh is null then b_ma_kh:= ' '; end if;
for r_lp in (
  select distinct a.ma_dvi,so_hd,so_id_d,ttrang,ngay_ht,a.ngay_kt from bh_ng a, bh_ng_ds b where 
         a.so_id=b.so_id and a.ngay_kt>b_ngay and a.nv like b_nv || '%'
         and b_ma_kh in (' ',a.ma_kh,b.ma_kh)
         --and (b_ma_kh is null or b_ma_kh = ' ' or a.ma_kh = b_ma_kh or b.ma_kh = b_ma_kh) 
         and (b_so_hd = ' ' or so_hd like '%' || b_so_hd || '%' or gcn like '%' || b_so_hd || '%')
         and (b_ten = ' ' or upper(a.ten) like '%' || b_ten || '%' or upper(b.ten) like '%' || b_ten || '%')
         and b_ttrang in (' ',ttrang) and ngay_ht between b_ngayD and b_ngayC
) loop
  b_ma_dviD:=r_lp.ma_dvi; b_so_idD:=r_lp.so_id_d;
  if FBH_NG_TTRANG(b_ma_dviD,b_so_idD)='D' then
      insert into temp_1(c1,n1,c2) values(b_ma_dviD,b_so_idD,r_lp.so_hd);
  end if;
end loop;
for r_lp in (select distinct t.ma_dvi,t.so_id from bh_ng_ds t, temp_1 t1
  where t.so_id = t1.n1 and b_ma_kh in (' ',t.ma_kh) and t.ngay_kt>b_ngay and b_so_hd in (' ', t1.c2)) loop
    b_ma_dviD:=r_lp.ma_dvi;
    b_so_idD:=FBH_NG_SO_IDd(b_ma_dviD,r_lp.so_id);
    if FBH_NG_TTRANG(b_ma_dviD,b_so_idD)='D' then
        insert into temp_1(c1,n1) values(b_ma_dviD,b_so_idD);
    end if;
end loop;
insert into temp_2(c1,n1) select distinct c1,n1 from temp_1;
for r_lp in (select c1 ma_dviD,n1 so_idD from temp_2) loop
    b_ma_dviD:=r_lp.ma_dviD; b_so_idD:=r_lp.so_idD;
    select so_hd,nv into b_so_hd,b_nv from bh_ng where so_id=b_so_idD;
    b_so_idC:=FBH_NG_SO_IDc(b_ma_dviD,b_so_idD,'C');
    if b_nv in('DLC','SKC','TDC') then
        insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10,n11,c12)
            select so_hd,so_hd,ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_so_idD,b_so_idD,nv
            from bh_ng where so_id=b_so_idC;
    else
        insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10,n11,c12)
            select so_hd,'',ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_so_idD,0,nv
            from bh_ng where so_id=b_so_idC;
        insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10,n11,c12)
            select '',gcn,ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_so_idD,so_id_dt,' '
            from bh_ng_ds where so_id=b_so_idC;
    end if;
end loop;
select count(*) into b_dong from ket_qua where rownum<600;
if b_dong<>0 then
    select JSON_ARRAYAGG(json_object('so_hd' value c1,'gcn' value c2,'ten' value c3,'cmt' value c4,'ngay_hl' value n1,
           'ngay_kt' value n2,'ngay_cap' value n3,'so_id_dt' value n11,'nv' value c12) returning clob)
        into cs_lke from ( select * from (
                select t.*, ROW_NUMBER() over (order by n10 desc,c12 desc,c3) as sott from ket_qua t 
            ) where sott between b_tu and b_den and rownum<600);
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete temp_1; delete temp_2; delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_NG_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36)); cs_lke clob:='';
    b_ma_kh varchar2(20); b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100); b_dong number;
    b_ngayD number; b_ngayC number; b_so_hsT varchar2(20); b_so_hd varchar2(20);
    b_ttrang varchar2(1); b_tu number; b_den number; b_nv varchar2(10);
begin
-- Dan - Tim hop dong qua CMT, mobi, email
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,so_hs,so_hd,tu,den,nv');
EXECUTE IMMEDIATE b_lenh into b_ngayd,b_ngayc,b_ttrang,b_cmt,b_mobi,b_email,b_so_hsT,b_so_hd,b_tu,b_den,b_nv using b_oraIn;
b_ttrang:=nvl(trim(b_ttrang),' ');
b_so_hd:=nvl(trim(b_so_hd),' '); b_so_hsT:=nvl(trim(b_so_hsT),' ');
if b_ngayd in (0,30000101) then b_ngayd:=b_ngay; end if;
b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
b_ma_kh:=nvl(trim(b_ma_kh),' '); b_so_hsT:=nvl(trim(b_so_hsT),' '); b_so_hd:=nvl(trim(b_so_hd),' ');
select JSON_ARRAYAGG(json_object(so_hs,'ngay' value ngay_xr,ttrang,'so_hd' value decode(so_hd,gcn,'',so_hd),
    gcn,ten,ma_dvi,so_id returning clob) order by so_id desc returning clob)
    into cs_lke from ( select *  from ( select t.*, ROW_NUMBER() over (order by so_id desc) as sott from bh_bt_ng t
        where b_ma_kh in(' ',ma_kh) and nv like b_nv || '%' and nv not in ('SKU','DLU')
              and b_ttrang in (' ', ttrang) and (b_so_hsT = ' ' or so_hs like '%' || b_so_hsT || '%')
              and (b_so_hd = ' ' or so_hd like '%' || b_so_hd || '%' or gcn like '%' || b_so_hd || '%')
              and ngay_ht between b_ngayd and b_ngayc and ngay_ht > b_ngay
        ) where sott between b_tu and b_den );
select count(*) into b_dong from bh_bt_ng t
        where b_ma_kh in(' ',ma_kh) and nv like b_nv || '%' and nv not in ('SKU','DLU')
              and b_ttrang in (' ', ttrang) and (b_so_hsT = ' ' or so_hs like '%' || b_so_hsT || '%')
              and (b_so_hd = ' ' or so_hd like '%' || b_so_hd || '%' or gcn like '%' || b_so_hd || '%')
              and ngay_ht between b_ngayd and b_ngayc and ngay_ht > b_ngay;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* tai san */
create or replace procedure PBH_PHH_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(100); b_lenh varchar2(2000); b_dong number; cs_lke clob:='';
    b_so_id number; b_so_idC number; b_ma_kh varchar2(20); b_so_hd varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ngayD number; b_ngayC number; b_ngay_ht number; b_ttrang varchar2(1);
    b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ten nvarchar2(500); b_phong varchar2(10); b_nv varchar2(1);
    b_tu number; b_den number; b_qu varchar2(1);
begin
-- viet anh - Tim hop dong qua CMT, mobi, email
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,so_hd,tu,den,nv');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_ten,b_so_hd,b_tu,b_den,b_nv using b_oraIn;
b_nv:=nvl(b_nv,'G');
b_ttrang:=nvl(trim(b_ttrang),' '); b_so_hd:=nvl(trim(b_so_hd),' '); b_ten:=nvl(trim(upper(b_ten)), ' ');
b_cmt:=nvl(trim(b_cmt),' '); b_mobi:=nvl(trim(b_mobi),' '); b_email:=nvl(trim(b_email),' ');
-- them phan quyen
b_qu:=FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','PHH','X');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    insert into temp_1(n1)
        select distinct so_id_d from bh_phh a, bh_phh_dvi b where
            a.so_id=b.so_id and a.ma_dvi=b_ma_dvi and a.ma_kh = b_ma_kh and nv=b_nv 
            and a.ngay_ht between b_ngayD and b_ngayC and (phong=b_phong or b_qu='C')
            and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%')
            and b_ttrang in (' ',ttrang) and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%');
else
    insert into temp_1(n1)
        select distinct so_id_d from bh_phh a, bh_phh_dvi b where
            a.so_id=b.so_id and a.ma_dvi=b_ma_dvi and nv=b_nv 
            and a.ngay_ht between b_ngayD and b_ngayC and (phong=b_phong or b_qu='C')
            and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%')
            and b_ttrang in (' ',ttrang) and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%');
end if;
for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
  b_so_idC:=FBH_PHH_SO_IDc(b_ma_dvi,r_lp.so_id_d);
  select max(so_hd) into b_so_hd from bh_phh where ma_dvi=b_ma_dvi and so_id=b_so_idC;
  if b_nv='G' then 
     insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10,c10)
        select t.so_hd,FBH_PHH_TTRANG(b_ma_dvi,b_so_idC),ten,cmt,t.ngay_hl,t.ngay_kt,t.ngay_cap,b_so_idC,t.nv
            from bh_phh t, bh_phh_dvi t1 where t.so_id=t1.so_id and t.ma_dvi=b_ma_dvi and t.so_id=b_so_idC;
  else
     insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10,c10)
        select so_hd,FBH_PHH_TTRANG(b_ma_dvi,b_so_idC),ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_so_idC,nv
            from bh_phh where ma_dvi=b_ma_dvi and so_id=b_so_idC;      
   end if;   
end loop;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'ma_dvi' value b_ma_dvi,'so_id' value n10,'nv' value c10) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n3 desc) as sott from ket_qua t 
      ) where sott between b_tu and b_den and rownum<202);
select count(*) into b_dong from ket_qua where rownum<202;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_PHH_TIMh(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36)); cs_lke clob:='';
    b_so_id number; b_so_idC number; b_so_idD number; b_ttrang  varchar2(1); b_nv varchar2(1);
    b_ma_kh varchar2(20); b_so_hd varchar2(20); b_ma_dviD varchar2(10);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ngayd number;b_ngayc number;
    b_ten nvarchar2(200); b_dong number; b_tu number; b_den number;
begin
-- Dan - Tim hop dong qua CMT, mobi, email
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,so_hd,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_ten,b_so_hd,b_tu,b_den using b_oraIn;
b_ttrang:=nvl(trim(b_ttrang),' '); b_ten:=nvl(trim(upper(b_ten)),' ');
b_so_hd:=nvl(trim(b_so_hd),' ');
b_cmt:=nvl(trim(b_cmt),' '); b_mobi:=nvl(trim(b_mobi),' '); b_email:=nvl(trim(b_email),' ');
if b_ngayd in (0,30000101) then b_ngayd:=b_ngay; end if;
b_ma_kh:=FBH_DTAC_MAf('',b_ten,b_cmt,b_mobi,b_email,'','');
for r_lp in (
    select distinct a.ma_dvi,a.so_id_d
      from bh_phh a,bh_phh_dvi b where a.so_id=b.so_id and b_cmt in (' ',cmt) and b_mobi in (' ',mobi) and b_email in (' ',email) 
           and a.ngay_ht between b_ngayd and b_ngayc and b_ttrang in (' ',a.ttrang)
           and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%')
           and (b_ten = ' ' OR upper(a.ten) LIKE '%' || b_ten || '%') and b.ngay_kt>b_ngay
    ) loop
    b_ma_dviD:=r_lp.ma_dvi; b_so_idD:=r_lp.so_id_d;
    b_so_idC:=FBH_PHH_SO_IDc(b_ma_dviD,b_so_idD);
    if FBH_PHH_TTRANG(b_ma_dviD,b_so_idC)='D' then
        b_so_hd:=FBH_PHH_SO_HDd(b_ma_dviD,b_so_idD); b_nv:=FBH_PHH_NV(b_ma_dviD,b_so_idD);
        insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c10)
            select so_hd,ten,ngay_hl,ngay_kt,ngay_cap,b_so_idD,0,b_nv from bh_phh where ma_dvi=b_ma_dviD and so_id=b_so_idC;
        insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c10)
            select ' ','- '||dvi,ngay_hl,ngay_kt,ngay_cap,b_so_idD,so_id_dt,b_nv from bh_phh_dvi where ma_dvi=b_ma_dviD and so_id=b_so_idC order by bt;
    end if;
end loop;
select count(*) into b_dong from ket_qua where rownum<202;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ten' value c2,'ngay_hl' value n1,'ngay_kt' value n2,'ngay_cap' value n3,
    'so_id' value n10,'so_id_dt' value n11,'nv' value c10 returning clob) order by n10 desc,n11) 
    into cs_lke from (
        select * from ( select t.*, ROW_NUMBER() over (order by n10 desc,n11) as sott
            from ket_qua t 
        ) where sott between b_tu and b_den and rownum<202
    );
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_PHH_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36)); cs_lke clob:='';
    b_ma_kh varchar2(20); b_so_hs varchar2(30); b_ma_dviD varchar2(10);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ngayd number;b_ngayc number;b_so_hsT varchar2(20); b_so_hd varchar2(20);
    b_ten nvarchar2(200); b_ttrang varchar2(1); b_dong number;
    b_tu number; b_den number;
begin
-- Dan - Tim hop dong qua CMT, mobi, email
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('dt_ct');
EXECUTE IMMEDIATE b_lenh into cs_lke using b_oraIn;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,so_hs,so_hd,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_ten,b_so_hsT,b_so_hd,b_tu,b_den using cs_lke;
if b_ngayd in (0,30000101) then b_ngayd:=b_ngay; end if;
b_ttrang:=nvl(trim(b_ttrang),' '); b_ten:=nvl(trim(upper(b_ten)),' ');
b_so_hd:=nvl(trim(b_so_hd),' '); b_so_hsT:=nvl(trim(b_so_hsT),' ');
b_ma_kh:=FBH_DTAC_MAf('',b_ten,b_cmt,b_mobi,b_email,'','');
select count(*) into b_dong from bh_bt_phh where
        ma_dvi = b_ma_dvi and (ma_kh = b_ma_kh OR b_ma_kh is null) and (b_ttrang = ' ' OR ttrang LIKE '%' || b_ttrang || '%')
        and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') and (b_so_hsT = ' ' OR so_hs LIKE '%' || b_so_hsT || '%')
        and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%')
        and ngay_ht between b_ngayd and b_ngayc and ngay_ht>b_ngay and rownum<202;
select JSON_ARRAYAGG(json_object(so_hs,'ngay' value ngay_xr,ttrang,so_hd,ten,
    'dvi' value FBH_PHH_DVI(ma_dvi_ql,so_id_hd,so_id_dt,ngay_xr),ma_dvi,so_id returning clob) order by so_id desc returning clob)
    into cs_lke from (
        select a.*, rownum as sott from bh_bt_phh a where
              ma_dvi = b_ma_dvi and (ma_kh = b_ma_kh OR b_ma_kh is null) and (b_ttrang = ' ' OR ttrang LIKE '%' || b_ttrang || '%')
              and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') and (b_so_hsT = ' ' OR so_hs LIKE '%' || b_so_hsT || '%')
              and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%')
              and ngay_ht between b_ngayd and b_ngayc and ngay_ht>b_ngay
              and rownum<202
        ) where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- procedure cua a Huy ma_dt --> mrr
create or replace procedure PBH_PHH_TIM_MARR
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100);
  -- loai pp
  b_ma_dt nvarchar2(500) :=FKH_JS_GTRIs(b_oraIn,'ma_dt');
  b_ma_nhom varchar2(20);
  b_ma_rr varchar2(20); b_il number :=0;marr clob;
  
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
  select count(*) into b_il from bh_phh_dtuong where ma = b_ma_dt;
  if b_il > 0 then
    select nhom into b_ma_nhom from bh_phh_dtuong where ma = b_ma_dt;
    select count(*) into b_il from bh_phh_nhom where ma = b_ma_nhom;
    if b_il > 0 then
      select mrr into b_ma_rr from bh_phh_nhom where ma = b_ma_nhom;
    end if;
  end if;
  if trim(b_ma_rr) is not null then
    select json_object('ma' VALUE ma,'ten' VALUE ten) into marr from bh_phh_mrr where ma = b_ma_rr;
  end if;
select json_object('marr' value marr) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* ky thuat */
create or replace procedure PBH_PKT_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(100); b_lenh varchar2(2000); b_dong number; cs_lke clob:='';
    b_so_id number; b_so_idC number; b_ma_kh varchar2(20); b_so_hd varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100); b_ma_sp varchar2(10);
    b_ngayD number; b_ngayC number; b_ngay_ht number; b_ttrang varchar2(1);
    b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ten nvarchar2(500); b_phong varchar2(10); b_nv varchar2(1);
    b_tu number; b_den number; b_qu varchar2(1);
begin
-- viet anh - Tim hop dong qua CMT, mobi, email
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,so_hd,tu,den,nv,ma_sp');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_ten,b_so_hd,b_tu,b_den,b_nv,b_ma_sp using b_oraIn;
b_nv:=nvl(b_nv,'G');b_ma_sp:=nvl(b_ma_sp,' ');
b_ttrang:=nvl(trim(b_ttrang),' '); b_so_hd:=nvl(trim(b_so_hd),' '); b_ten:=nvl(TRIM(upper(b_ten)), ' ');
b_cmt:=nvl(trim(b_cmt),' '); b_mobi:=nvl(trim(b_mobi),' '); b_email:=nvl(trim(b_email),' ');
-- them phan quyen
b_qu:=FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','PKT','X');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    insert into temp_1(n1)
        select distinct so_id_d from bh_pkt a, bh_pkt_dvi b where
            a.so_id=b.so_id and a.ma_dvi=b_ma_dvi and a.ma_kh = b_ma_kh and nv=b_nv 
            and a.ngay_ht between b_ngayD and b_ngayC and (phong=b_phong or b_qu='C')
            and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%')
            and b_ttrang in (' ',ttrang) and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') and b_ma_sp in (' ',ma_sp);
else
    insert into temp_1(n1)
        select distinct so_id_d from bh_pkt a, bh_pkt_dvi b where
            a.so_id=b.so_id and a.ma_dvi=b_ma_dvi and nv=b_nv 
            and a.ngay_ht between b_ngayD and b_ngayC and (phong=b_phong or b_qu='C')
            and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%')
            and b_ttrang in (' ',ttrang) and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') and b_ma_sp in (' ',ma_sp);
end if;
for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
  b_so_idC:=FBH_PKT_SO_IDc(b_ma_dvi,r_lp.so_id_d);
  select max(so_hd) into b_so_hd from bh_pkt where ma_dvi=b_ma_dvi and so_id=b_so_idC;
  if b_nv='G' then 
     insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10,c10,c11)
        select t.so_hd,FBH_PKT_TTRANG(b_ma_dvi,b_so_idC),ten,cmt,t.ngay_hl,t.ngay_kt,t.ngay_cap,b_so_idC,t.nv,FBH_PKT_MA_SP_TEN(t.ma_sp)
            from bh_pkt t, bh_pkt_dvi t1 where t.so_id=t1.so_id and t.ma_dvi=b_ma_dvi and t.so_id=b_so_idC;
  else
     insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10,c10,c11)
        select so_hd,FBH_PKT_TTRANG(b_ma_dvi,b_so_idC),ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_so_idC,nv,FBH_PKT_MA_SP_TEN(ma_sp)
            from bh_pkt where ma_dvi=b_ma_dvi and so_id=b_so_idC;      
   end if;   
end loop;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'ma_dvi' value b_ma_dvi,'so_id' value n10,'nv' value c10,'ma_sp' value c11) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n3 desc) as sott from ket_qua t 
      ) where sott between b_tu and b_den and rownum<202);
select count(*) into b_dong from ket_qua where rownum<202;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_PKT_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36)); cs_lke clob:='';
    b_ma_kh varchar2(20); b_so_hs varchar2(30); b_ma_dviD varchar2(10);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ngayd number;b_ngayc number;b_so_hsT varchar2(20); b_so_hd varchar2(20);
    b_ten nvarchar2(200); b_ttrang varchar2(1); b_dong number;
    b_tu number; b_den number;
begin
-- viet anh - Tim hop dong qua CMT, mobi, email
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('dt_ct');
EXECUTE IMMEDIATE b_lenh into cs_lke using b_oraIn;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,so_hs,so_hd,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_ten,b_so_hsT,b_so_hd,b_tu,b_den using cs_lke;
if b_ngayd in (0,30000101) then b_ngayd:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_ttrang:=nvl(trim(b_ttrang),' '); b_ten:=nvl(trim(upper(b_ten)),' ');
b_so_hd:=nvl(trim(b_so_hd),' '); b_so_hsT:=nvl(trim(b_so_hsT),' ');
b_ma_kh:=FBH_DTAC_MAf('',b_ten,b_cmt,b_mobi,b_email,'','');
select count(*) into b_dong from bh_bt_pkt where
            ma_dvi = b_ma_dvi and (ma_kh = b_ma_kh OR b_ma_kh IS NULL) and b_ttrang in (' ',ttrang)
            and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') and (b_so_hsT = ' ' OR so_hs LIKE '%' || b_so_hsT || '%')
            and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%')
            and ngay_ht between b_ngayd and b_ngayc and ngay_ht>b_ngay and rownum<202;
select JSON_ARRAYAGG(json_object(so_hs,'ngay' value ngay_xr,ttrang,so_hd,ten,
    'dvi' value FBH_PKT_DVI(ma_dvi_ql,so_id_hd,so_id_dt,ngay_xr),ma_dvi,so_id) order by so_id desc returning clob)
    into cs_lke from (
      select a.*, rownum as sott from bh_bt_pkt a where
            ma_dvi = b_ma_dvi and (ma_kh = b_ma_kh OR b_ma_kh IS NULL) and b_ttrang in (' ',ttrang)
            and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') and (b_so_hsT = ' ' OR so_hs LIKE '%' || b_so_hsT || '%')
            and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%')
            and ngay_ht between b_ngayd and b_ngayc and ngay_ht>b_ngay and rownum<202
     ) where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_PKT_TIMh(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36)); cs_lke clob:='';
    b_so_id number; b_so_idC number; b_so_idD number; b_ttrang  varchar2(1); b_nv varchar2(1);
    b_ma_kh varchar2(20); b_so_hd varchar2(20); b_ma_dviD varchar2(10);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ngayd number;b_ngayc number;b_so_hdT varchar2(20);
    b_ten nvarchar2(200); b_dong number; b_tu number; b_den number;
begin
-- Dan - Tim hop dong qua CMT, mobi, email
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('dt_ct');
EXECUTE IMMEDIATE b_lenh into cs_lke using b_oraIn;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,so_hd,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_ten,b_so_hd,b_tu,b_den using cs_lke;
b_ttrang:=nvl(trim(b_ttrang),' '); b_ten:=nvl(trim(upper(b_ten)),' '); b_so_hd:=nvl(trim(b_so_hd),' ');
if b_ngayd in (0,30000101) then b_ngayd:=b_ngay; end if;
b_ma_kh:=FBH_DTAC_MAf('',b_ten,b_cmt,b_mobi,b_email,'','');
for r_lp in (select distinct a.ma_dvi,a.so_id_d
    from bh_pkt a,bh_pkt_dvi b where
          a.so_id = b.so_id and a.ma_dvi = b_ma_dvi and (a.ma_kh = b_ma_kh OR b_ma_kh IS NULL)
          and a.ngay_ht between b_ngayd and b_ngayc and b_ttrang in (' ',a.ttrang)
          and (b_ten = ' ' OR upper(a.ten) LIKE '%' || b_ten || '%')
          and (b_so_hd = ' ' OR a.so_hd LIKE '%' || b_so_hd || '%' OR b.gcn LIKE '%' || b_so_hd || '%') and a.ngay_kt>b_ngay
    ) loop
    b_ma_dviD:=r_lp.ma_dvi; b_so_idD:=r_lp.so_id_d;
    b_so_idC:=FBH_PKT_SO_IDc(b_ma_dviD,b_so_idD);
    if FBH_PKT_TTRANG(b_ma_dviD,b_so_idC)='D' then
        b_so_hd:=FBH_PKT_SO_HDd(b_ma_dviD,b_so_idD); b_nv:=FBH_PKT_NV(b_ma_dviD,b_so_idD);
        insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c10)
            select so_hd,ten,ngay_hl,ngay_kt,ngay_cap,b_so_idD,0,b_nv from bh_pkt where ma_dvi=b_ma_dviD and so_id=b_so_idC;
        insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c10)
            select ' ','- '||dvi,ngay_hl,ngay_kt,ngay_cap,b_so_idD,so_id_dt,b_nv from bh_pkt_dvi where ma_dvi=b_ma_dviD and so_id=b_so_idC order by bt;
    end if;
end loop;
select count(*) into b_dong from ket_qua where rownum<202;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ten' value c2,'ngay_hl' value n1,'ngay_kt' value n2,'ngay_cap' value n3,
    'so_id' value n10,'so_id_dt' value n11,'nv' value c10 returning clob)
    order by n10 desc,n11) into cs_lke from (
        select * from ( select t.*, ROW_NUMBER() over (order by n10 desc,n11) as sott
            from ket_qua t 
        ) where sott between b_tu and b_den and rownum<202
     );
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_id number; b_so_idC number; b_ma_kh varchar2(20); b_xe_id number; b_so_hd varchar2(30);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number; b_ttrang varchar2(1);
    b_ten nvarchar2(200); b_ten_tau nvarchar2(200); b_so_dk varchar2(20);
    b_phong varchar2(10); b_nv varchar2(1);
    b_tu number; b_den number; b_qu varchar2(1);
begin
-- viet anh
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,so_hd,ten_tau,so_dk,tu,den,nv');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_ten,b_so_hd,b_ten_tau,b_so_dk,b_tu,b_den,b_nv using b_oraIn; 
b_nv:=nvl(b_nv,'G');
b_ttrang:=nvl(trim(b_ttrang),' '); b_so_hd:=nvl(trim(b_so_hd),' '); b_ten:=nvl(TRIM(upper(b_ten)), ' ');
b_cmt:=nvl(trim(b_cmt),' '); b_mobi:=nvl(trim(b_mobi),' '); b_email:=nvl(trim(b_email),' ');
b_ten_tau:=upper(nvl(TRIM(b_ten_tau), ' ')); b_so_dk:=nvl(trim(b_so_dk),' ');
-- them phan quyen
b_qu:=FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','TAU','X');
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    insert into temp_1(n1)
        select distinct so_id_d from bh_tau a, bh_tau_ds b where
            a.so_id=b.so_id and a.ma_dvi=b_ma_dvi and a.ma_kh = b_ma_kh
            and nv=b_nv and a.ngay_ht between b_ngayD and b_ngayC and (phong=b_phong or b_qu='C')
            and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%')
            and b_ttrang in (' ',ttrang) and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%')
            and b_so_dk in (' ',so_dk) and (b_ten_tau = ' ' OR upper(ten_tau) LIKE '%' || b_ten_tau || '%');
else
    insert into temp_1(n1)
        select distinct so_id_d from bh_tau a, bh_tau_ds b where
            a.so_id=b.so_id and a.ma_dvi=b_ma_dvi
            and nv=b_nv and a.ngay_ht between b_ngayD and b_ngayC and (phong=b_phong or b_qu='C')
            and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%')
            and b_ttrang in (' ',ttrang) and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%')
            and b_so_dk in (' ',so_dk) and (b_ten_tau = ' ' OR upper(ten_tau) LIKE '%' || b_ten_tau || '%');
end if;
for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
  b_so_idC:=FBH_TAU_SO_IDc(b_ma_dvi,r_lp.so_id_d);
  select max(so_hd) into b_so_hd from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_idC;
  if b_nv='G' then 
     insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10,c10,c11,c12,c14)
        select t.so_hd,FBH_TAU_TTRANG(b_ma_dvi,b_so_idC),tenc,cmtc,t.ngay_hl,t.ngay_kt,t.ngay_cap,b_so_idC,t.nv,ten_tau,so_dk,gcn
            from bh_tau t, bh_tau_ds t1 where t.so_id=t1.so_id and t.ma_dvi=b_ma_dvi and t.so_id=b_so_idC;
  else
     insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10,c10,c11,c12,c14)
        select so_hd,FBH_TAU_TTRANG(b_ma_dvi,b_so_idC),ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_so_idC,nv,'','',''
            from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_idC;      
     insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10,c10,c11,c12,c14)
        select '',FBH_TAU_TTRANG(b_ma_dvi,b_so_idC),tenc,cmtc,ngay_hl,ngay_kt,ngay_cap,b_so_idC,'',ten_tau,so_dk,gcn
            from bh_tau_ds where ma_dvi=b_ma_dvi and so_id=b_so_idC;  
   end if;   
end loop;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'ma_dvi' value b_ma_dvi,'so_id' value n10,'nv' value c10,
     'ten_tau' value c11, 'so_dk' value c12,'gcn' value c14) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n10 desc) as sott from ket_qua t 
      ) where sott between b_tu and b_den and rownum<202);
select count(*) into b_dong from ket_qua where rownum<202;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TAU_TIMh(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36)); cs_lke clob:='';
    b_so_id number; b_so_idC number; b_so_idD number; b_ttrang  varchar2(1); b_nv varchar2(1);
    b_ma_kh varchar2(20); b_so_hd varchar2(20); b_ma_dviD varchar2(10);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ngayd number;b_ngayc number;b_so_hdT varchar2(20);
    b_so_dk varchar2(20); b_ten_tau nvarchar2(500); b_dong number;
    b_tu number; b_den number;
begin
-- Dan - Tim hop dong qua CMT, mobi, email
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('cmt,mobi,email,ngayd,ngayc,so_hd,so_dk,ten_tau,tu,den');
EXECUTE IMMEDIATE b_lenh into b_cmt,b_mobi,b_email,b_ngayd,b_ngayc,b_so_hdT,b_so_dk,b_ten_tau,b_tu,b_den using b_oraIn;
b_ttrang:=nvl(trim(b_ttrang),' '); b_ten_tau:=nvl(trim(upper(b_ten_tau)),' ');
b_so_hdT:=nvl(trim(b_so_hdT),' '); b_so_dk:=nvl(trim(b_so_dk),' ');
if b_ngayd in (0,30000101) then b_ngayd:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_ma_kh:=FBH_DTAC_MAf('','',b_cmt,b_mobi,b_email,'','');
for r_lp in (select distinct a.ma_dvi,a.so_id_d from bh_tau a,bh_tau_ds b
    where (b_so_dk = ' ' OR b.so_dk LIKE '%' || b_so_dk || '%')
          and (b_ma_kh is null or b_ma_kh = '' OR a.ma_kh = b_ma_kh)
          and (b_so_hdT = ' ' OR a.so_hd LIKE '%' || b_so_hdT || '%')
          and (b_ten_tau = ' ' OR upper(ten_tau) LIKE '%' || b_ten_tau || '%')
          and a.ngay_ht between b_ngayd and b_ngayc and b.ngay_kt>b_ngay and b.so_id=a.so_id
) loop
    b_ma_dviD:=r_lp.ma_dvi; b_so_idD:=r_lp.so_id_d;
    b_so_idC:=FBH_TAU_SO_IDc(b_ma_dviD,b_so_idD);
    if FBH_TAU_TTRANG(b_ma_dviD,b_so_idC)='D' then
        b_so_hd:=FBH_TAU_SO_HDd(b_ma_dviD,b_so_idD);
        insert into ket_qua(c1,c2,c3,c4,c5,n1,n2,n3,c10,n10,n11)
            select b_so_hd,gcn,tenC,so_dk,ten_tau,ngay_hl,ngay_kt,ngay_cap,b_ma_dviD,b_so_idD,so_id_dt
            from bh_tau_ds where so_id=b_so_idC;
    end if;
end loop;
select count(*) into b_dong from ket_qua where rownum<202;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'gcn' value c2,'ten' value c3,'so_dk' value c4,'ten_tau' value c5,'ngay_hl' value n1,
    'ngay_kt' value n2,'ngay_cap' value n3,'ma_dvi' value c10,'so_id' value n10,'so_id_dt' value n11 returning clob)
    order by c4,c5 returning clob) into cs_lke from (
        select * from ( select t.*, ROW_NUMBER() over (order by n10 desc,n11) as sott
            from ket_qua t
        ) where sott between b_tu and b_den and rownum<202
    );
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TAU_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36)); cs_lke clob:='';
    b_ma_kh varchar2(20); b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ngayd number;b_ngayc number;b_so_hsT varchar2(20); b_ttrang varchar2(1); b_so_dk varchar2(20); b_ten_tau nvarchar2(500); 
    b_so_hd varchar2(20);
    b_dong number; b_tu number; b_den number;
begin
-- viet anh - Tim hop dong qua CMT, mobi, email
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('dt_ct');
EXECUTE IMMEDIATE b_lenh into cs_lke using b_oraIn;
b_lenh:=FKH_JS_LENH('cmt,mobi,email,ngayd,ngayc,so_hs,so_dk,ten_tau,so_hd,tu,den');
EXECUTE IMMEDIATE b_lenh into b_cmt,b_mobi,b_email,b_ngayd,b_ngayc,b_so_hsT,b_so_dk,b_ten_tau,b_so_hd,b_tu,b_den using cs_lke;
b_ttrang:=nvl(trim(b_ttrang),' '); b_ten_tau:=nvl(trim(upper(b_ten_tau)),' ');
b_so_hsT:=nvl(trim(b_so_hsT),' '); b_so_dk:=nvl(trim(b_so_dk),' ');
b_so_hd:=nvl(trim(b_so_hd),' ');
if b_ngayd in (0,30000101) then b_ngayd:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
select count(*) into b_dong 
       from bh_bt_tau a,bh_bt_tau_ct b where
          a.so_id=b.so_id and (a.ma_kh = b_ma_kh OR b_ma_kh IS NULL) and b_ttrang in (' ',a.ttrang)
          and (b_so_hd = ' ' OR a.so_hd LIKE '%' || b_so_hd || '%' OR a.gcn LIKE '%' || b_so_hd || '%')
          and (b_so_hsT = ' ' OR a.so_hs LIKE '%' || b_so_hsT || '%')
          and (b_so_dk = ' ' OR b.so_dk LIKE '%' || b_so_dk || '%')
          and (b_ten_tau = ' ' OR upper(b.ten_tau) LIKE '%' || b_ten_tau || '%')
          and a.ngay_ht between b_ngayd and b_ngayc and a.ngay_ht>b_ngay;
select JSON_ARRAYAGG(json_object(so_hs,'ngay' value ngay_xr,ttrang,so_hd,ten,gcn,so_dk,ma_dvi,so_id,ngay_ht returning clob) 
       order by so_id desc returning clob) into cs_lke from (
         select a.*,b.so_dk,b.ten_tau, ROW_NUMBER() over (order by ngay_ht desc,a.so_id desc) as sott
           from bh_bt_tau a,bh_bt_tau_ct b where
              a.so_id=b.so_id and (a.ma_kh = b_ma_kh OR b_ma_kh IS NULL) and b_ttrang in (' ',a.ttrang)
              and (b_so_hd = ' ' OR a.so_hd LIKE '%' || b_so_hd || '%' OR a.gcn LIKE '%' || b_so_hd || '%')
              and (b_so_hsT = ' ' OR a.so_hs LIKE '%' || b_so_hsT || '%')
              and (b_so_dk = ' ' OR b.so_dk LIKE '%' || b_so_dk || '%')
              and (b_ten_tau = ' ' OR upper(b.ten_tau) LIKE '%' || b_ten_tau || '%')
              and a.ngay_ht between b_ngayd and b_ngayc and a.ngay_ht > b_ngay 
    ) where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* xe CG */
create or replace procedure PBH_XEB_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); cs_lke clob:='';
    b_so_id number; b_ma_kh varchar2(20); b_so_hd varchar2(20); b_phong varchar2(10);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ngayD number; b_ngayC number; b_ttrang varchar2(1); b_lan number;
    b_ten nvarchar2(200); b_bien_xe varchar2(20);
    b_tu number; b_den number; b_dong number; b_qu varchar2(1); b_nv varchar2(1);
begin
-- Dan - Tim bao gia qua CMT, mobi, email
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,so_hd,bien_xe,nv,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_ten,b_so_hd,b_bien_xe,b_nv,b_tu,b_den using b_oraIn;
b_ttrang:=nvl(trim(b_ttrang),' ');b_ten:=nvl(trim(upper(b_ten)),' ');
b_bien_xe:=nvl(trim(upper(b_bien_xe)),' ');
if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
-- them phan quyen
b_qu:=FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','XE','X');
b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
b_nv:=nvl(b_nv,'G');
for r_lp in (
   select * from (
      select distinct a.so_id,max(lan) lan  from bh_xeB a, bh_xeB_ds b where 
          a.so_id=b.so_id and a.ma_dvi=b_ma_dvi and (phong=b_phong or b_qu='C')
          and (b_ma_kh is null or b_ma_kh = '' OR ma_kh = b_ma_kh) and ngay_ht between b_ngayD and b_ngayC 
          and (b_ten = ' ' OR upper(a.ten) LIKE '%' || b_ten || '%') and (b_bien_xe = ' ' OR upper(b.ten) LIKE '%' || b_bien_xe || '%')
          and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%') and b_ttrang in (' ',ttrang) and nv=b_nv  group by a.so_id ) 
) loop
b_so_id:=r_lp.so_id; b_lan:=r_lp.lan;
select max(so_hd) into b_so_hd from bh_xeB where ma_dvi=b_ma_dvi and so_id=b_so_id;
insert into ket_qua(c1,c2,c3,n1,n2,n3,n10,c10,c11)
  select b_so_hd,ttrang,a.ten,ngay_hl,ngay_kt,ngay_ht,b_so_id,nv,b.ten
      from bh_xeB a, bh_xeB_ds b where 
          a.so_id=b.so_id and a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and lan=b_lan
          and (b_bien_xe = ' ' OR upper(b.ten) LIKE '%' || b_bien_xe || '%') and nv=b_nv;
end loop;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'ngay_hl' value n1,'ngay_kt' value n2,
       'ngay_ht' value n3,'ma_dvi' value b_ma_dvi,'so_id' value n10,'nv' value c10,'bien_xe' value c11 returning clob)
    order by c1 desc returning clob) into cs_lke from (
    select * from (
        select t.*, ROW_NUMBER() over (order by n3 desc,n10 desc) as sott from ket_qua t 
    ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_id number; b_so_idC number; b_ma_kh varchar2(20); b_xe_id number; b_so_hd varchar2(30);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number; b_ttrang varchar2(1);
    b_bien_xe varchar2(20); b_so_khung varchar2(30);
    b_ten nvarchar2(200); b_phong varchar2(10); b_nv varchar2(1);
    b_tu number; b_den number; b_qu varchar2(1);
begin
-- viet anh
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,bien_xe,so_khung,ten,so_hd,tu,den,nv');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_bien_xe,b_so_khung,b_ten,b_so_hd,b_tu,b_den,b_nv using b_oraIn;
b_nv:=nvl(b_nv,'G');
b_ttrang:=nvl(trim(b_ttrang),' '); b_so_hd:=nvl(trim(b_so_hd),' '); b_ten:=upper(nvl(TRIM(b_ten), ' '));
b_cmt:=nvl(trim(b_cmt),' '); b_mobi:=nvl(trim(b_mobi),' '); b_email:=nvl(trim(b_email),' ');
b_bien_xe:=nvl(trim(b_bien_xe),' '); b_so_khung:=nvl(trim(b_so_khung),' ');
-- them phan quyen
b_qu:=FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','XE','X');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
b_xe_id:=FBH_XEtso_SO_ID(b_bien_xe,b_so_khung);
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    insert into temp_1(n1)
        select distinct so_id_d from bh_xe a, bh_xe_ds b where
            a.so_id=b.so_id and a.ma_dvi=b_ma_dvi and b_xe_id in(0,b.xe_id) and a.ma_kh = b_ma_kh
            and nv=b_nv and a.ngay_ht between b_ngayD and b_ngayC and (phong=b_phong or b_qu='C')
            and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%')
            and b_ttrang in (' ',ttrang) and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%');
elsif trim(b_bien_xe||b_so_khung) is not null then
    insert into temp_1(n1)
      select distinct so_id_d from bh_xe a, bh_xe_ds b where
          a.so_id=b.so_id and a.ma_dvi=b_ma_dvi and b_xe_id=xe_id
          and nv=b_nv and a.ngay_ht between b_ngayD and b_ngayC and (phong=b_phong or b_qu='C')
          and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%')
          and b_ttrang in (' ',ttrang) and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%');
else
    insert into temp_1(n1)
        select distinct so_id_d from bh_xe a, bh_xe_ds b where
            a.so_id=b.so_id and a.ma_dvi=b_ma_dvi and b_xe_id in(0,b.xe_id)
            and nv=b_nv and a.ngay_ht between b_ngayD and b_ngayC and (phong=b_phong or b_qu='C')
            and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%')
            and b_ttrang in (' ',ttrang) and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%');
end if;
for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
  b_so_idC:=FBH_XE_SO_IDc(b_ma_dvi,r_lp.so_id_d);
     insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10,c10,c11,c12,c13,c14)
        select t.so_hd,FBH_XE_TTRANG(b_ma_dvi,b_so_idC),tenc,cmtc,t.ngay_hl,t.ngay_kt,t.ngay_cap,b_so_idC,
               t.nv,bien_xe,so_khung,so_may,gcn
            from bh_xe t, bh_xe_ds t1 where t.so_id=t1.so_id and t.ma_dvi=b_ma_dvi and t.so_id=b_so_idC
                and b_xe_id in(0,t1.xe_id)
                and nv=b_nv and t.ngay_ht between b_ngayD and b_ngayC and (phong=b_phong or b_qu='C')
                and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%')
                and b_ttrang in (' ',ttrang) and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%');
end loop;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'ma_dvi' value b_ma_dvi,'so_id' value n10,'nv' value c10,'bien_xe' value c11,
     'so_khung' value c12,'so_may' value c13,'gcn' value c14) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n3 desc, n10 desc) as sott from ket_qua t 
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_XE_TIMh(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_id number; b_so_idC number; b_ma_kh varchar2(20); b_xe_id number; b_so_hd varchar2(30); b_so_hd_c varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number; b_ttrang varchar2(1);
    b_bien_xe varchar2(20); b_so_khung varchar2(30);
    b_ten nvarchar2(200); b_phong varchar2(10); b_nv varchar2(1);
    b_tu number; b_den number; b_qu varchar2(1);
begin
-- viet anh
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,bien_xe,so_khung,ten,so_hd,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_bien_xe,b_so_khung,b_ten,b_so_hd,b_tu,b_den using b_oraIn;
b_ttrang:=nvl(trim(b_ttrang),' '); b_so_hd:=nvl(trim(b_so_hd),' '); b_ten:=upper(nvl(TRIM(b_ten), ' '));
b_cmt:=nvl(trim(b_cmt),' '); b_mobi:=nvl(trim(b_mobi),' '); b_email:=nvl(trim(b_email),' ');
b_bien_xe:=nvl(trim(b_bien_xe),' '); b_so_khung:=nvl(trim(b_so_khung),' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
b_xe_id:=FBH_XEtso_SO_ID(b_bien_xe,b_so_khung);
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    insert into temp_1(n1)
        select distinct so_id_d from bh_xe a, bh_xe_ds b where
            a.so_id=b.so_id and a.ma_dvi=b_ma_dvi and b_xe_id in(0,b.xe_id) and a.ma_kh = b_ma_kh
            and a.ngay_ht between b_ngayD and b_ngayC 
            and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%')
            and ttrang='D' and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%');
else
    insert into temp_1(n1)
        select distinct so_id_d from bh_xe a, bh_xe_ds b where
            a.so_id=b.so_id and a.ma_dvi=b_ma_dvi and b_xe_id in(0,b.xe_id)
            and a.ngay_ht between b_ngayD and b_ngayC 
            and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%')
            and ttrang='D' and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%');
end if;
for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
  b_so_idC:=FBH_XE_SO_IDc(b_ma_dvi,r_lp.so_id_d);
  select max(so_hd),max(nv) into b_so_hd,b_nv from bh_xe where ma_dvi=b_ma_dvi and so_id=b_so_idC;
     insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10,c10,c11,c12,c13,c14,c15)
        select t.so_hd,FBH_XE_TTRANG(b_ma_dvi,b_so_idC),tenc,cmtc,t.ngay_hl,t.ngay_kt,t.ngay_cap,b_so_idC,
               t.nv,bien_xe,so_khung,so_may,gcn,so_id_dt
            from bh_xe t, bh_xe_ds t1 where t.so_id=t1.so_id and t.ma_dvi=b_ma_dvi and t.so_id=b_so_idC
                and b_xe_id in(0,t1.xe_id) and t.ngay_ht between b_ngayD and b_ngayC 
                and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%' OR gcn LIKE '%' || b_so_hd || '%')
                and ttrang='D' and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%');   
end loop;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'ma_dvi' value b_ma_dvi,'so_id' value n10,'nv' value c10,'bien_xe' value c11,
     'so_khung' value c12,'so_may' value c13,'gcn' value c14, 'so_id_dt' value c15 returning clob)returning clob) 
     into cs_lke from ( select * from (
          select t.*, ROW_NUMBER() over (order by n3 desc, n10 desc) as sott from ket_qua t
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_XE_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36)); cs_ct clob:=''; cs_lke clob:='';
    b_so_id number; b_so_idC number; b_so_idD number; b_ttrang  varchar2(1); b_nv varchar2(1);
    b_ma_kh varchar2(20); b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ngayD number; b_ngayC number; b_so_hsT varchar2(20); b_so_hd varchar2(20);
    b_bien_xe varchar2(20); b_so_khung varchar2(30); b_so_may varchar2(30); b_ten nvarchar2(200);
    b_dong number; b_xe_id number; b_tu number; b_den number;
begin
-- Dan - Tim hop dong qua CMT, mobi, email
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('dt_ct');
EXECUTE IMMEDIATE b_lenh into cs_ct using b_oraIn;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,bien_xe,so_khung,so_may,ten,so_hs,so_hd,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_bien_xe,b_so_khung,b_so_may,b_ten,b_so_hsT,b_so_hd,
                              b_tu,b_den using cs_ct;
b_xe_id:=FBH_XEtso_SO_ID(b_bien_xe,b_so_khung);
b_ttrang:=nvl(trim(b_ttrang),' '); b_ten:=nvl(trim(upper(b_ten)),' ');
b_so_hd:=nvl(trim(b_so_hd),' '); b_so_hsT:=nvl(trim(b_so_hsT),' ');
b_cmt:=nvl(trim(b_cmt),' '); b_mobi:=nvl(trim(b_mobi),' '); b_email:=nvl(trim(b_email),' ');
b_bien_xe:=nvl(trim(b_bien_xe),' '); b_so_khung:=nvl(trim(b_so_khung),' '); b_so_may:=nvl(trim(b_so_may),' ');
if b_xe_id is null then b_loi:='loi:Khong tim duoc xe:loi'; raise PROGRAM_ERROR; end if;
if b_ngayd in (0,30000101) then b_ngayd:=b_ngay; end if;
b_ma_kh:=FBH_DTAC_MAf('','',b_cmt,b_mobi,b_email,'','');
select count(*) into b_dong
       from bh_bt_xe a, bh_bt_xe_ct b where
            a.so_id = b.so_id and a.ma_dvi=b_ma_dvi and (a.ma_kh = b_ma_kh OR b_ma_kh IS NULL)
            and b_xe_id in (0, b.xe_id) and b_ttrang in (' ', a.ttrang)
            and (b_so_hd = ' ' OR a.so_hd LIKE '%' || b_so_hd || '%' OR a.gcn LIKE '%' || TRIM(b_so_hd) || '%')
            and (b_so_hsT = ' ' OR a.so_hs LIKE '%' || b_so_hsT || '%') and (b_ten = ' ' OR upper(a.ten) LIKE '%' || b_ten || '%')
            and a.ngay_ht between b_ngayd and b_ngayc and a.ngay_ht > b_ngay;
select JSON_ARRAYAGG(json_object(so_hs,'ngay' value ngay_xr,ttrang,so_hd,ten,gcn,ma_dvi,so_id,bien_xe,ngay_ht returning clob) 
     order by so_id desc returning clob) into cs_lke from (
        select a.*,b.bien_xe, ROW_NUMBER() over (order by ngay_ht desc,a.so_id desc) as sott
           from bh_bt_xe a, bh_bt_xe_ct b where
              a.so_id = b.so_id and a.ma_dvi=b_ma_dvi and (a.ma_kh = b_ma_kh OR b_ma_kh IS NULL)
              and b_xe_id in (0, b.xe_id) and b_ttrang in (' ', a.ttrang)
              and (b_so_hd = ' ' OR a.so_hd LIKE '%' || b_so_hd || '%' OR a.gcn LIKE '%' || TRIM(b_so_hd) || '%')
              and (b_so_hsT = ' ' OR a.so_hs LIKE '%' || b_so_hsT || '%') and (b_ten = ' ' OR upper(a.ten) LIKE '%' || b_ten || '%')
              and a.ngay_ht between b_ngayd and b_ngayc and a.ngay_ht > b_ngay
    ) where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_XEtso_SO_IDj(b_bien_xe varchar2,b_so_khung varchar2, b_so_may varchar2) return number
AS
    b_kq number:=0;
begin
-- Dan - Tra nghiep vu
if trim(b_so_khung) is not null then
    select nvl(min(xe_id),0) into b_kq from bh_xe_ID where so_khung=b_so_khung;
end if;
if b_kq=0 and trim(b_so_may) is not null then
    select nvl(min(xe_id),0) into b_kq from bh_xe_ID where so_may=b_so_may;
end if;
if b_kq=0 and trim(b_bien_xe) is not null then
    select nvl(min(xe_id),0) into b_kq from bh_xe_ID where bien_xe=b_bien_xe;
end if;
return b_kq;
end;
/
create or replace procedure PBH_XE_BPHI_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); cs_lke clob; b_dong number;
    b_ma_sp varchar2(200); b_nhom varchar2(200); b_nv_bh varchar2(200); b_md_sd varchar2(200);
    b_loai_xe varchar2(200); b_nhom_xe varchar(200); b_dong_xe varchar2(200); b_dco varchar2(20);
    b_ttai number; b_so_cn number; b_gia number; b_tuoi number;
    b_tu number; b_den number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_sp,nhom,nv_bh,md_sd,loai_xe,nhom_xe,dong_xe,dco,ttai,so_cn,gia,tuoi,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ma_sp,b_nhom,b_nv_bh,b_md_sd,b_loai_xe,b_nhom_xe,b_dong_xe,b_dco,b_ttai,b_so_cn,b_gia,b_tuoi,
        b_tu,b_den using b_oraIn;
b_ma_sp:=nvl(trim(b_ma_sp),' '); b_nhom:=nvl(trim(b_nhom),' ');
b_nv_bh:=nvl(trim(b_nv_bh),' '); b_md_sd:=nvl(trim(b_md_sd),' ');
--viet anh
b_loai_xe:=trim(PKH_MA_TENl(b_loai_xe)); b_nhom_xe:=trim(PKH_MA_TENl(b_nhom_xe));
b_dong_xe:=trim(PKH_MA_TENl(b_dong_xe)); b_dco:=trim(PKH_MA_TENl(b_dco));
b_ma_sp:=PKH_MA_TENl(b_ma_sp); b_nhom:=PKH_MA_TENl(b_nhom);
b_nv_bh:=PKH_MA_TENl(b_nv_bh); b_md_sd:=PKH_MA_TENl(b_md_sd);
select count(*) into b_dong from bh_xe_phi
  where b_nhom in (' ',nhom)
        and b_ma_sp in (' ',ma_sp) and b_md_sd in (' ',md_sd) and b_nv_bh in (' ',nv_bh)
        and (b_loai_xe = ' ' OR loai_xe LIKE '%' || b_loai_xe || '%') and (b_nhom_xe = ' ' OR nhom_xe LIKE '%' || b_nhom_xe || '%')
        and (b_dong_xe = ' ' OR dong LIKE '%' || b_dong_xe || '%') and (b_dco = ' ' OR dco LIKE '%' || b_dco || '%') 
        and b_ttai in (0,ttai) and b_so_cn in (0,so_cn) and b_gia in (0,gia) and b_tuoi in (0,tuoi);
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object('ma_sp' value FBH_XE_SP_TEN(ma_sp),'cdich' value FBH_MA_CDICH_TEN(cdich),'goi' value FBH_XE_GOI_TEN(goi),
    nhom,nv_bh,bh_tbo,'md_sd' value FBH_XE_MDSD_TEN(md_sd),'loai_xe' value FBH_XE_LOAI_TEN(loai_xe),'nhom_xe' value FBH_XE_NHOM_TEN(nhom_xe),
    'dong' value FBH_XE_DONG_TEN(dong),dco,ttai,so_cn,tuoi,gia,ngay_bd,ngay_kt,so_id)
    order by ma_sp,cdich,goi,nhom,nv_bh,bh_tbo,md_sd,loai_xe,nhom_xe,dong,dco,ttai,so_cn,tuoi,gia returning clob) into cs_lke from
    (select ma_sp,cdich,goi,nhom,nv_bh,bh_tbo,md_sd,loai_xe,nhom_xe,dong,
            dco,ttai,so_cn,tuoi,gia,ngay_bd,ngay_kt,so_id,rownum sott from bh_xe_phi
      where b_nhom in (' ',nhom)
          and b_ma_sp in (' ',ma_sp) and b_md_sd in (' ',md_sd) and b_nv_bh in (' ',nv_bh)
          and (b_loai_xe = ' ' OR loai_xe LIKE '%' || b_loai_xe || '%') and (b_nhom_xe = ' ' OR nhom_xe LIKE '%' || b_nhom_xe || '%')
          and (b_dong_xe = ' ' OR dong LIKE '%' || b_dong_xe || '%') and (b_dco = ' ' OR dco LIKE '%' || b_dco || '%')
          and b_ttai in (0,ttai) and b_so_cn in (0,so_cn) and b_gia in (0,gia) and b_tuoi in (0,tuoi)
         order by cdich,goi,bh_tbo,loai_xe,nhom_xe,dong,dco,ttai,so_cn,tuoi,gia)
      where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_TT_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_idD number; b_ma_kh varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number;
    b_so_hd varchar2(20); b_so_id number;
begin
-- viet anh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,cmt,mobi,email,so_hd');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_cmt,b_mobi,b_email,b_so_hd using b_oraIn;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
b_so_id:=FBH_HD_GOC_SO_ID(b_ma_dvi,b_so_hd);
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    select JSON_ARRAYAGG(json_object(a.ngay_ht,'nv' value FBH_HD_NV(b.ma_dvi,b.so_id),
        'so_hd' value FBH_HD_GOC_SO_HD_D(b.ma_dvi,b.so_id),a.ten,a.so_id_tt) order by a.ngay_ht desc returning clob) into cs_lke
        from bh_hd_goc_ttps a, bh_hd_goc_tthd b where
             a.ma_dvi=b_ma_dvi and a.ma_kh=b_ma_kh and a.ngay_ht between b_ngayD and b_ngayC
             and a.nsd=b_nsd and b.ma_dvi=a.ma_dvi and b.so_id_tt=a.so_id_tt and rownum<202;
else
    select JSON_ARRAYAGG(json_object(a.ngay_ht,'nv' value FBH_HD_NV(b.ma_dvi,b.so_id),
        'so_hd' value FBH_HD_GOC_SO_HD_D(b.ma_dvi,b.so_id),a.ten,a.so_id_tt) order by a.ngay_ht desc returning clob) into cs_lke
        from bh_hd_goc_ttps a, bh_hd_goc_tthd b where
             a.ma_dvi=b_ma_dvi and a.ngay_ht between b_ngayD and b_ngayC and a.nsd=b_nsd
             and b.ma_dvi=a.ma_dvi and b_so_id in (0,so_id) and b.so_id_tt=a.so_id_tt and rownum<202;
end if;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--duchq update length email
create or replace procedure PBH_BT_HK_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(400); cs_lke clob:='';
    b_cmt varchar2(20); b_mobi varchar2(20); b_so_hs varchar2(30); b_email varchar2(100);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number; b_ma_kh varchar2(20);
begin
-- Dan - Tim thanh toan qua CMT, mobi, email
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,cmt,mobi,email,so_hs');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_cmt,b_mobi,b_email,b_so_hs using b_oraIn;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
b_so_hs:=nvl(trim(b_so_hs),' ');
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    select count(*) into b_dong from bh_bt_hk where ma_dvi=b_ma_dvi and
            ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd and b_so_hs in (' ',so_hs);
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hs,ten,so_id) order by ngay_ht desc returning clob) into cs_lke
        from bh_bt_hk where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC 
        and nsd=b_nsd and b_so_hs in (' ',so_hs);
elsif b_ngayD between b_ngay and 30000101 then
    select count(*) into b_dong from bh_bt_hk where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC 
    and nsd=b_nsd and b_so_hs in (' ',so_hs);
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hs,ten,so_id) order by ngay_ht desc returning clob) into cs_lke
        from bh_bt_hk where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd and b_so_hs in (' ',so_hs);
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_2BB_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); cs_lke clob:='';
    b_so_id number; b_ma_kh varchar2(20); b_so_hd varchar2(20); b_phong varchar2(10);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ngayD number; b_ngayC number; b_ttrang varchar2(1); b_lan number;
    b_ten nvarchar2(200); b_bien_xe varchar2(20);
    b_tu number; b_den number; b_dong number; b_qu varchar2(1); b_nv varchar2(1);
begin
-- Dan - Tim bao gia qua CMT, mobi, email
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','2B','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,so_hd,bien_xe,nv,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_ten,b_so_hd,b_bien_xe,b_nv,b_tu,b_den using b_oraIn;
b_ttrang:=nvl(trim(b_ttrang),' ');b_ten:=nvl(trim(upper(b_ten)),' ');
b_bien_xe:=nvl(trim(upper(b_bien_xe)),' ');
if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
-- them phan quyen
b_qu:=FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','2B','X');
b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
b_nv:=nvl(b_nv,'G');
for r_lp in (
   select * from (
      select distinct a.so_id,max(lan) lan  from bh_2bB a, bh_2bB_ds b where 
          a.so_id=b.so_id and a.ma_dvi=b_ma_dvi and (phong=b_phong or b_qu='C')
          and (b_ma_kh is null or b_ma_kh = '' OR ma_kh = b_ma_kh) and ngay_ht between b_ngayD and b_ngayC 
          and (b_ten = ' ' OR upper(a.ten) LIKE '%' || b_ten || '%') and (b_bien_xe = ' ' OR upper(b.ten) LIKE '%' || b_bien_xe || '%')
          and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%') and b_ttrang in (' ',ttrang) and nv=b_nv  group by a.so_id ) 
) loop
b_so_id:=r_lp.so_id; b_lan:=r_lp.lan;
select max(so_hd) into b_so_hd from bh_2bB where ma_dvi=b_ma_dvi and so_id=b_so_id;
insert into ket_qua(c1,c2,c3,n1,n2,n3,n10,c10,c11)
  select b_so_hd,ttrang,a.ten,ngay_hl,ngay_kt,ngay_ht,b_so_id,nv,b.ten
      from bh_2bB a, bh_2bB_ds b where 
          a.so_id=b.so_id and a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and lan=b_lan
          and (b_bien_xe = ' ' OR upper(b.ten) LIKE '%' || b_bien_xe || '%') and nv=b_nv;
end loop;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'ngay_hl' value n1,'ngay_kt' value n2,
       'ngay_ht' value n3,'ma_dvi' value b_ma_dvi,'so_id' value n10,'nv' value c10,'bien_xe' value c11 returning clob)
    order by c1 desc returning clob) into cs_lke from (
    select * from (
        select t.*, ROW_NUMBER() over (order by n3 desc,n10 desc) as sott from ket_qua t 
    ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/

create or replace procedure PBH_PTNCC_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_so_idC number; b_ma_kh varchar2(20); b_so_hd varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100); 
    b_ten nvarchar2(500); b_phong varchar2(10); b_nv varchar2(1); b_ma_sp varchar2(10);
    b_ngayD number; b_ngayC number; b_ngay_ht number; b_ttrang varchar2(1);
begin
-- Nam - Tim hop dong qua CMT, mobi, email
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,so_hd,nv,ma_sp');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_ten,b_so_hd,b_nv,b_ma_sp using b_oraIn;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);b_ma_sp:=nvl(trim(b_ma_sp),' ');
b_ttrang:=nvl(trim(b_ttrang),' '); b_ten:=nvl(trim(upper(b_ten)), ' ');
b_i1:=PKH_NG_CSO(add_months(sysdate,-36));
if b_ngayD in (0,30000101) or b_ngayD<b_i1 then b_ngayD:=b_i1; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_i1:=0;
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    for r_lp in (select distinct so_id_d from bh_ptncc where ma_dvi=b_ma_dvi and ma_kh = b_ma_kh and nv=b_nv 
          and ngay_ht between b_ngayD and b_ngayC and phong=b_phong
          and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%') and b_ma_sp in (' ',ma_sp)
          and b_ttrang in (' ',ttrang) and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') order by so_id_d desc) loop
        b_so_idC:=FBH_PTNCC_SO_IDc(b_ma_dvi,r_lp.so_id_d);
        select max(so_hd),max(ngay_ht) into b_so_hd,b_ngay_ht from bh_ptncc where ma_dvi=b_ma_dvi and so_id=b_so_idC;
        insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n4,n10,c11)
            select b_so_hd,ttrang,ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_ngay_ht,b_so_idC,FBH_PTNCC_SP_TEN(ma_sp)
            from bh_ptncc where ma_dvi=b_ma_dvi and so_id=b_so_idC;
    end loop;
else
    for r_lp in (select distinct so_id_d from bh_ptncc where ma_dvi=b_ma_dvi and nv=b_nv 
          and ngay_ht between b_ngayD and b_ngayC and phong=b_phong
          and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%')
          and b_ttrang in (' ',ttrang) and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') order by so_id_d desc) loop
        b_so_idC:=FBH_PTNCC_SO_IDc(b_ma_dvi,r_lp.so_id_d);
        select max(so_hd),max(ngay_ht) into b_so_hd,b_ngay_ht from bh_ptncc where ma_dvi=b_ma_dvi and so_id=b_so_idC;
        insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n4,n10,c11)
            select b_so_hd,ttrang,ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_ngay_ht,b_so_idC,FBH_PTNCC_SP_TEN(ma_sp)
            from bh_ptncc where ma_dvi=b_ma_dvi and so_id=b_so_idC;
        b_i1:=b_i1+1;
        if b_i1>300 then exit; end if;
    end loop;
end if;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,
    'ngay_hl' value n1,'ngay_kt' value n2,'ngay_cap' value n3,'ma_sp' value c11,
    'ma_dvi' value b_ma_dvi,'so_id' value n10 returning clob)
    order by n4 desc,c1 returning clob) into b_oraOut from ket_qua;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_NHOM_SPJ(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); cs_lke clob;
    b_ngay number:=PKH_NG_CSO(sysdate); b_nv varchar2(10):=b_oraIn;
begin
-- Dan
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FBH_PQU_NHOM_SP(b_nv,cs_lke);
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_PTNHANG_TIMh(
   b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36)); cs_lke clob:='';
    b_so_idC number; b_so_idD number; b_ttrang  varchar2(1); b_nv varchar2(5); b_lh_bh varchar2(5);
    b_ma_kh varchar2(20); b_so_hd varchar2(20); b_ma_dviD varchar2(10);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ngayd number;b_ngayc number;b_so_hdT varchar2(20);
    b_ten nvarchar2(200); b_dong number;
    b_tu number; b_den number;
begin
-- Dan - Tim hop dong qua CMT, mobi, email
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,so_hd,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_ten,b_so_hdT,b_tu,b_den using b_oraIn;
b_ttrang:=nvl(trim(b_ttrang),' '); b_ten:=nvl(trim(upper(b_ten)),' ');
if b_ngayd in (0,30000101) then b_ngayd:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_ma_kh:=FBH_DTAC_MAf('',b_ten,b_cmt,b_mobi,b_email,'','');
for r_lp in (
  select distinct ma_dvi,so_id_d
    from bh_ptn where
      (b_ma_kh is null or b_ma_kh = '' OR ma_kh = b_ma_kh) and b_ttrang in (' ',ttrang)
      and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') and (b_so_hdT = ' ' OR so_hd LIKE '%' || b_so_hdT || '%')
      and ngay_ht between b_ngayd and b_ngayc and ngay_kt > b_ngay and nv='TNH'
    ) loop
    b_ma_dviD:=r_lp.ma_dvi; b_so_idD:=r_lp.so_id_d;
    b_so_idC:=FBH_PTN_SO_IDc(b_ma_dviD,b_so_idD);
    if FBH_PTN_TTRANG(b_ma_dviD,b_so_idC)='D' then
        b_so_hd:=FBH_PTN_SO_HDd(b_ma_dviD,b_so_idD); b_nv:=FBH_PTN_NV(b_ma_dviD,b_so_idD);
        insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c10,c11)
            select so_hd,ten,ngay_hl,ngay_kt,ngay_cap,b_so_idD,0,nv,cmt
             from bh_ptn where ma_dvi=b_ma_dviD and so_id=b_so_idC and nv='TNH';
    end if;
end loop;
select count(*) into b_dong from ket_qua where rownum<202;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ten' value c2,'ngay_hl' value n1,'ngay_kt' value n2,'ngay_cap' value n3,
    'so_id' value n10,'so_id_dt' value n11,'nv' value c10,'cmt' value c11 returning clob)
    order by n10 desc,n11 returning clob) into cs_lke from (
        select * from (
            select t.*, ROW_NUMBER() over (order by n10 desc,n11) as sott from ket_qua t
        ) where sott between b_tu and b_den and rownum<202);
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_PTNHANG_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    cs_ct clob:=''; cs_lke clob:='';
    b_so_id number; b_so_idC number; b_so_idD number; b_ttrang  varchar2(1); b_nv varchar2(1);
    b_ma_kh varchar2(20); b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ngayD number; b_ngayC number; b_so_hsT varchar2(20); b_so_hd varchar2(20);
    b_ten nvarchar2(200); b_dong number; b_tu number; b_den number;
begin
-- Dan - Tim hop dong qua CMT, mobi, email
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('dt_ct');
EXECUTE IMMEDIATE b_lenh into cs_ct using b_oraIn;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,so_hs,so_hd,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_ten,b_so_hsT,b_so_hd,b_tu,b_den using cs_ct;
b_ttrang:=nvl(trim(b_ttrang),' '); b_ten:=nvl(trim(upper(b_ten)),' ');
b_so_hd:=nvl(trim(b_so_hd),' '); b_so_hsT:=nvl(trim(b_so_hsT),' ');
b_cmt:=nvl(trim(b_cmt),' '); b_mobi:=nvl(trim(b_mobi),' '); b_email:=nvl(trim(b_email),' ');
if b_ngayd in (0,30000101) then b_ngayd:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_ma_kh:=FBH_DTAC_MAf('','',b_cmt,b_mobi,b_email,'','');
select count(*) into b_dong
   from bh_bt_ptn where (b_ma_kh is null or b_ma_kh = '' or ma_kh = b_ma_kh)
        and b_ttrang in (' ', ttrang) and (b_so_hsT = ' ' OR so_hs LIKE '%' || b_so_hsT || '%')
        and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%') and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%')
        and ngay_ht between b_ngayd and b_ngayc and ngay_ht > b_ngay and nv='TNH' and rownum<202;
select JSON_ARRAYAGG(json_object(so_hs,'ngay' value ngay_xr,ttrang,so_hd,ten,ma_dvi,so_id returning clob) 
   order by so_id desc returning clob)
      into cs_lke from (
          select a.*, rownum as sott
             from bh_bt_ptn a where (b_ma_kh is null or b_ma_kh = '' or ma_kh = b_ma_kh)
                and b_ttrang in (' ', ttrang) and (b_so_hsT = ' ' OR so_hs LIKE '%' || b_so_hsT || '%')
                and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%') and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%')
                and ngay_ht between b_ngayd and b_ngayc and ngay_ht > b_ngay and nv='TNH' and rownum<202
        )  where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- XOL
--duchq update length email
create or replace procedure PTBH_XOL_TIMh(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_ngay number:=PKH_NG_CSO(add_months(sysdate,-24));
    b_so_id number; b_so_idC number; b_so_idD number; b_nv varchar2(10);
    b_ma_kh varchar2(20); b_so_hd varchar2(20); b_ma_dviD varchar2(10);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100); b_ten_dvi nvarchar2(500);
    cs_lke clob:='';
    b_ngayD number; b_ngayC number;
    b_ten nvarchar2(200);
    b_tu number; b_den number;
begin
-- Dan - Tim hop dong qua CMT, mobi, email
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,cmt,mobi,email,ten,so_hd,ngayd,ngayc,tu,den');
EXECUTE IMMEDIATE b_lenh into b_nv,b_cmt,b_mobi,b_email,b_ten,b_so_hd,b_ngayD,b_ngayC,b_tu,b_den using b_oraIn;
b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
--if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
if b_ngayd in (0,30000101) then b_ngayd:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_ten:=nvl(trim(b_ten),' ');
b_so_hd:=nvl(trim(b_so_hd),' ');
if b_nv='PHH' then
    for r_lp in (select distinct ma_dvi,so_id_d from bh_phh where
             (ma_kh = b_ma_kh OR b_ma_kh IS NULL)
             and (b_so_hd = ' ' OR upper(so_hd) LIKE '%' || upper(b_so_hd) || '%')
             and (b_ten = ' ' OR upper(ten) LIKE '%' || upper(b_ten) || '%')
             and ngay_ht between b_ngayD and b_ngayC
             and ngay_kt>b_ngay) loop
        b_ma_dviD:=r_lp.ma_dvi; b_so_idD:=r_lp.so_id_d;
        --b_ten_dvi:=FHT_MA_DVI_TENG(b_ma_dviD);
        if FBH_PHH_TTRANG(b_ma_dviD,b_so_idD)='D' then
            b_so_idC:=FBH_PHH_SO_IDc(b_ma_dviD,b_so_idD);
            b_so_hd:=FBH_PHH_SO_HDd(b_ma_dviD,b_so_idD);
            insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c11,c12,c14)
                select b_so_hd,ten,ngay_hl,ngay_kt,ngay_cap,b_so_idD,0,b_ma_dviD,b_ma_dviD,b_so_hd
                from bh_phh where ma_dvi=b_ma_dviD and so_id=b_so_idC;
            if FBH_PHH_NV(b_ma_dviD,b_so_idD)='H' then
                insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c11,c12,c14)
                    select ' ','- '||dvi,ngay_hl,ngay_kt,ngay_cap,b_so_idD,so_id_dt,' ',b_ma_dviD,b_so_hd
                    from bh_phh_dvi where ma_dvi=b_ma_dviD and so_id=b_so_idC order by bt;
            end if;
        end if;
    end loop;
elsif b_nv='PKT' then
    for r_lp in (select distinct ma_dvi,so_id_d from bh_pkt where
             (ma_kh = b_ma_kh OR b_ma_kh IS NULL)
             and (b_so_hd = ' ' OR upper(so_hd) LIKE '%' || upper(b_so_hd) || '%')
             and (b_ten = ' ' OR upper(ten) LIKE '%' || upper(b_ten) || '%')
             and ngay_ht between b_ngayD and b_ngayC
             and ngay_kt>b_ngay) loop
        b_ma_dviD:=r_lp.ma_dvi; b_so_idD:=r_lp.so_id_d;
        --b_ten_dvi:=FHT_MA_DVI_TENG(b_ma_dviD);
        if FBH_PKT_TTRANG(b_ma_dviD,b_so_idD)='D' then
            b_so_idC:=FBH_PKT_SO_IDc(b_ma_dviD,b_so_idD);
            b_so_hd:=FBH_PKT_SO_HDd(b_ma_dviD,b_so_idD);
            insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c11,c12,c14)
                select b_so_hd,ten,ngay_hl,ngay_kt,ngay_cap,b_so_idD,0,b_ma_dviD,b_ma_dviD,b_so_hd
                from bh_pkt where ma_dvi=b_ma_dviD and so_id=b_so_idC;
            if FBH_PKT_NV(b_ma_dviD,b_so_idD)='H' then
                insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c11,c12,c14)
                    select ' ','- '||dvi,ngay_hl,ngay_kt,ngay_cap,b_so_idD,so_id_dt,' ',b_ma_dviD,b_so_hd
                    from bh_pkt_dvi where ma_dvi=b_ma_dviD and so_id=b_so_idC order by bt;
            end if;
        end if;
    end loop;
elsif b_nv='XE' then
    for r_lp in (select distinct ma_dvi,so_id_d from bh_xe where
             (ma_kh = b_ma_kh OR b_ma_kh IS NULL)
             and (b_so_hd = ' ' OR upper(so_hd) LIKE '%' || upper(b_so_hd) || '%')
             and (b_ten = ' ' OR upper(ten) LIKE '%' || upper(b_ten) || '%')
             and ngay_ht between b_ngayD and b_ngayC
             and ngay_kt>b_ngay) loop
        b_ma_dviD:=r_lp.ma_dvi; b_so_idD:=r_lp.so_id_d;
        --b_ten_dvi:=FHT_MA_DVI_TENG(b_ma_dviD);
        if FBH_XE_TTRANG(b_ma_dviD,b_so_idD)='D' then
            b_so_idC:=FBH_XE_SO_IDc(b_ma_dviD,b_so_idD);
            b_so_hd:=FBH_XE_SO_HDd(b_ma_dviD,b_so_idD);
            insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c11,c12,c14)
                select b_so_hd,ten,ngay_hl,ngay_kt,ngay_cap,b_so_idD,0,b_ma_dviD,b_ma_dviD,b_so_hd
                from bh_xe where ma_dvi=b_ma_dviD and so_id=b_so_idC;
            if FBH_XE_NV(b_ma_dviD,b_so_idD)='H' then
                insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c11,c12,c14)
                    select ' ','- '||decode(bien_xe,' ',so_khung,bien_xe),
                    ngay_hl,ngay_kt,ngay_cap,b_so_idD,so_id_dt,' ',b_ma_dviD,b_so_hd
                    from bh_xe_ds where ma_dvi=b_ma_dviD and so_id=b_so_idC order by bt;
            end if;
        end if;
    end loop;
elsif b_nv='2B' then
    for r_lp in (select distinct ma_dvi,so_id_d from bh_2b where
             (ma_kh = b_ma_kh OR b_ma_kh IS NULL)
             and (b_so_hd = ' ' OR upper(so_hd) LIKE '%' || upper(b_so_hd) || '%')
             and (b_ten = ' ' OR upper(ten) LIKE '%' || upper(b_ten) || '%')
             and ngay_ht between b_ngayD and b_ngayC
             and ngay_kt>b_ngay) loop
        b_ma_dviD:=r_lp.ma_dvi; b_so_idD:=r_lp.so_id_d;
        --b_ten_dvi:=FHT_MA_DVI_TENG(b_ma_dviD);
        if FBH_2B_TTRANG(b_ma_dviD,b_so_idD)='D' then
            b_so_idC:=FBH_2B_SO_IDc(b_ma_dviD,b_so_idD);
            b_so_hd:=FBH_2B_SO_HDd(b_ma_dviD,b_so_idD);
            insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c11,c12,c14)
                select b_so_hd,ten,ngay_hl,ngay_kt,ngay_cap,b_so_idD,0,b_ma_dviD,b_ma_dviD,b_so_hd
                from bh_2b where ma_dvi=b_ma_dviD and so_id=b_so_idC;
            if FBH_2B_NV(b_ma_dviD,b_so_idD)='H' then
                insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c11,c12,c14)
                    select ' ','- '||decode(bien_xe,' ',so_khung,bien_xe),
                    ngay_hl,ngay_kt,ngay_cap,b_so_idD,so_id_dt,' ',b_ma_dviD,b_so_hd
                    from bh_2b_ds where ma_dvi=b_ma_dviD and so_id=b_so_idC order by bt;
            end if;
        end if;
    end loop;
elsif b_nv='TAU' then
    for r_lp in (select distinct ma_dvi,so_id_d from bh_tau where
             (ma_kh = b_ma_kh OR b_ma_kh IS NULL)
             and (b_so_hd = ' ' OR upper(so_hd) LIKE '%' || upper(b_so_hd) || '%')
             and (b_ten = ' ' OR upper(ten) LIKE '%' || upper(b_ten) || '%')
             and ngay_ht between b_ngayD and b_ngayC
             and ngay_kt>b_ngay) loop
        b_ma_dviD:=r_lp.ma_dvi; b_so_idD:=r_lp.so_id_d;
        --b_ten_dvi:=FHT_MA_DVI_TENG(b_ma_dviD);
        if FBH_TAU_TTRANG(b_ma_dviD,b_so_idD)='D' then
            b_so_idC:=FBH_TAU_SO_IDc(b_ma_dviD,b_so_idD);
            b_so_hd:=FBH_TAU_SO_HDd(b_ma_dviD,b_so_idD);
            insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c11,c12,c14)
                select b_so_hd,ten,ngay_hl,ngay_kt,ngay_cap,b_so_idD,0,b_ma_dviD,b_ma_dviD,b_so_hd
                from bh_TAU where ma_dvi=b_ma_dviD and so_id=b_so_idC;
            if FBH_TAU_NV(b_ma_dviD,b_so_idD)='H' then
                insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c11,c12,c14)
                    select ' ','- '||so_dk||ten_tau,
                    ngay_hl,ngay_kt,ngay_cap,b_so_idD,so_id_dt,' ',b_ma_dviD,b_so_hd
                    from bh_tau_ds where ma_dvi=b_ma_dviD and so_id=b_so_idC order by bt;
            end if;
        end if;
    end loop;
else
    for r_lp in (select distinct ma_dvi,so_id_d from bh_hd_goc where
             (ma_kh = b_ma_kh OR b_ma_kh IS NULL)
             and (b_so_hd = ' ' OR upper(so_hd) LIKE '%' || upper(b_so_hd) || '%')
             and (b_ten = ' ' OR upper(ten) LIKE '%' || upper(b_ten) || '%')
             and ngay_ht between b_ngayD and b_ngayC
             and ngay_kt>b_ngay) loop
        b_ma_dviD:=r_lp.ma_dvi; b_so_idD:=r_lp.so_id_d;
        --b_ten_dvi:=FHT_MA_DVI_TENG(b_ma_dviD);
        if FBH_HD_TTRANG(b_ma_dviD,b_so_idD)='D' then
            b_so_idC:=FBH_HD_SO_ID_BS(b_ma_dviD,b_so_idD);
            b_so_hd:=FBH_HD_GOC_SO_HD(b_ma_dviD,b_so_idD);
            insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c11,c12,c14)
                select b_so_hd,ten,ngay_hl,ngay_kt,ngay_cap,b_so_idD,0,b_ma_dviD,b_ma_dviD,b_so_hd
                from bh_hd_goc where ma_dvi=b_ma_dviD and so_id=b_so_idC;
        end if;
    end loop;
end if;
select JSON_ARRAYAGG(json_object('ma_dviH' value c11,'so_hdH' value c1,'ten' value c2,
    'ngay_hl' value n1,'ngay_kt' value n2,'ngay_cap' value n3,'so_id' value n10,
    'so_id_dt' value n11,'ma_dvi' value c12,'so_hd' value c14 returning clob)
    order by n10 desc,n11 returning clob) into cs_lke from ket_qua where rownum<200;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_XOL_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_nv varchar2(10); b_ngayD number; b_ngayC number;
    b_so_ct varchar2(20); b_so_hd varchar2(20); cs_lke clob:='';
begin
-- Dan - Tim ty le tai co dinh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,ngayd,ngayc,so_ct,so_hd');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ngayD,b_ngayC,b_so_ct,b_so_hd using b_oraIn;
if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_so_ct:=trim(b_so_ct);
if b_so_ct is not null then b_so_ct:='%'||upper(b_so_ct)||'%'; end if;
b_so_hd:=trim(b_so_hd);
if b_so_hd is not null then b_so_hd:='%'||upper(b_so_hd)||'%'; end if;
select JSON_ARRAYAGG(json_object(
    a.so_id,a.ngay_ht,a.so_ct,b.ma_dvi_hd,b.so_hd,'ten' value FTBH_GHEP_NH_TEN(b_nv,b.ma_dvi_hd,b.so_id_hd,b.so_id_dt))
    order by a.ngay_ht desc,a.so_ct returning clob) into cs_lke
    from tbh_xol_nh a,tbh_xol_nh_hd b where
    a.nv=b_nv and a.ngay_ht between b_ngayD and b_ngayC and
    (b_so_ct is null or upper(a.so_ct) like b_so_ct) and
    b.so_id=a.so_id and (b_so_hd is null or upper(b.so_hd) like b_so_hd) and rownum<200;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAUB_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); cs_lke clob:='';
    b_so_id number; b_ma_kh varchar2(20); b_so_hd varchar2(20); b_phong varchar2(10);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number; b_ttrang varchar2(1); b_lan number;
    b_ten nvarchar2(200); b_nv varchar2(1); b_qu varchar2(1);
    b_tu number; b_den number;
begin
-- Dan - Tim bao gia qua CMT, mobi, email
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,so_hd,nv,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_ten,b_so_hd,b_nv,b_tu,b_den using b_oraIn;
b_ttrang:=nvl(trim(b_ttrang),' '); b_so_hd:=nvl(trim(b_so_hd),' '); b_ten:=nvl(TRIM(upper(b_ten)), ' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
-- them phan quyen
b_qu:=FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','TAU','X');
b_nv:=nvl(b_nv,'G');
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    select count(*) into b_dong from bh_tauB where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh 
             and ngay_ht between b_ngayD and b_ngayC and (phong=b_phong or b_qu='C')
             and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%')
             and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%') and nv=b_nv and b_ttrang in (' ',ttrang)
             and rownum<202;
    if b_dong > 0 then
      for r_lp in (select distinct so_id,max(lan) lan from bh_tauB where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh 
               and ngay_ht between b_ngayD and b_ngayC and (phong=b_phong or b_qu='C')
               and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%')
               and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%') and nv=b_nv and b_ttrang in (' ',ttrang)
               and rownum<202 group by so_id) loop
      select max(so_hd) into b_so_hd from bh_tauB where ma_dvi=b_ma_dvi and so_id=r_lp.so_id;
      insert into ket_qua(c1,c2,c3,n1,n2,n10,c10)
          select b_so_hd,ttrang,ten,ngay_ht,ngay_kt,r_lp.so_id,nv
          from bh_tauB where ma_dvi=b_ma_dvi and so_id=r_lp.so_id and lan=r_lp.lan;
      end loop;
    end if;
else
    select count(*) into b_dong from bh_tauB where ma_dvi=b_ma_dvi
             and ngay_ht between b_ngayD and b_ngayC and (phong=b_phong or b_qu='C')
             and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%')
             and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%') and nv=b_nv and b_ttrang in (' ',ttrang)
             and rownum<202;
    if b_dong > 0 then
      for r_lp in (select distinct so_id,max(lan) lan from bh_tauB where ma_dvi=b_ma_dvi
               and ngay_ht between b_ngayD and b_ngayC and (phong=b_phong or b_qu='C')
               and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%')
               and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%') and nv=b_nv and b_ttrang in (' ',ttrang)
               and rownum<202 group by so_id) loop
      select max(so_hd) into b_so_hd from bh_tauB where ma_dvi=b_ma_dvi and so_id=r_lp.so_id;
      insert into ket_qua(c1,c2,c3,n1,n2,n10,c10)
          select b_so_hd,ttrang,ten,ngay_ht,ngay_kt,r_lp.so_id,nv
          from bh_tauB where ma_dvi=b_ma_dvi and so_id=r_lp.so_id and lan=r_lp.lan;
      end loop;
    end if;
end if;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,
    'ngay_hl' value n1,'ngay_kt' value n2,'ma_dvi' value b_ma_dvi,'so_id' value n10,'nv' value c10) returning clob) 
    into cs_lke from ( select * from (
        select t.*, ROW_NUMBER() over (order by c1 desc) as sott from ket_qua t 
    ) where sott between b_tu and b_den);
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHHB_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_dong number; cs_lke clob:='';
    b_so_id number; b_lan number; b_ma_kh varchar2(20); b_so_hd varchar2(20); b_ten nvarchar2(500);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100); b_ma_sp varchar2(20);
    b_ngayD number; b_ngayC number; b_ttrang varchar2(1); b_nv varchar2(1); b_phong varchar2(10);
begin
-- Dan - Tim hop dong qua CMT, mobi, email
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ma_sp,nv,so_hd,ten');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_ma_sp,b_nv,b_so_hd,b_ten using b_oraIn;
b_ttrang:=nvl(trim(b_ttrang),' '); b_so_hd:=nvl(trim(b_so_hd),' '); b_nv:=nvl(trim(b_nv),'G');
b_ma_sp:=nvl(trim(b_ma_sp),' '); b_ten:=nvl(trim(upper(b_ten)),' ');
if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    for r_lp in (select so_id,max(lan) lan from bh_phhB where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and
        ngay_ht between b_ngayD and b_ngayC and phong=b_phong and b_ttrang in (' ',ttrang) and nv=b_nv 
        and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%')
        and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') and b_ma_sp in (' ',ma_sp) group by so_id) loop
        b_so_id:=r_lp.so_id; b_lan:=r_lp.lan;
        insert into ket_qua(c1,c2,c3,n1,n10,n11,c10,c11)
            select so_hd,ttrang,ten,ngay_ht,b_so_id,b_lan,nv,FBH_PHH_SP_TEN(ma_sp)
            from bh_phhB where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan;
    end loop;
else
    for r_lp in (select so_id,max(lan) lan from bh_phhB where ma_dvi=b_ma_dvi and
        ngay_ht between b_ngayD and b_ngayC and phong=b_phong and b_ttrang in (' ',ttrang) and nv=b_nv 
        and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%')
        and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') and b_ma_sp in (' ',ma_sp) group by so_id) loop
        b_so_id:=r_lp.so_id; b_lan:=r_lp.lan;
        insert into ket_qua(c1,c2,c3,n1,n10,n11,c10,c11)
            select so_hd,ttrang,ten,ngay_ht,b_so_id,b_lan,nv,FBH_PHH_SP_TEN(ma_sp)
            from bh_phhB where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan;
    end loop;
end if;
select count(*) into b_dong from ket_qua;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'lan' value n11,'ttrang' value c2,'ten' value c3,
    'ngay_ht' value n1,'ma_dvi' value b_ma_dvi,'so_id' value n10,'nv' value c10,'ma_sp' value c11 returning clob)
    order by n3 desc,c1 returning clob) into cs_lke from ket_qua;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKTB_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); cs_lke clob:='';
    b_so_id number; b_ma_kh varchar2(20); b_so_hd varchar2(20); b_phong varchar2(10);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number; b_ttrang varchar2(1); b_lan number;
    b_ten nvarchar2(200); b_nv varchar2(1); b_qu varchar2(1);
    b_tu number; b_den number;
begin
-- Dan - Tim bao gia qua CMT, mobi, email
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,so_hd,nv,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_ten,b_so_hd,b_nv,b_tu,b_den using b_oraIn;
b_ttrang:=nvl(trim(b_ttrang),' '); b_so_hd:=nvl(trim(b_so_hd),' '); b_ten:=nvl(TRIM(upper(b_ten)), ' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
-- them phan quyen
b_qu:=FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','PKT','X');
b_nv:=nvl(b_nv,'G');
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    select count(*) into b_dong from bh_pktB where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh 
             and ngay_ht between b_ngayD and b_ngayC and (phong=b_phong or b_qu='C')
             and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%')
             and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%') and nv=b_nv and b_ttrang in (' ',ttrang)
             and rownum<202;
    if b_dong > 0 then
      for r_lp in (select distinct so_id,max(lan) lan from bh_pktB where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh 
               and ngay_ht between b_ngayD and b_ngayC and (phong=b_phong or b_qu='C')
               and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%')
               and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%') and nv=b_nv and b_ttrang in (' ',ttrang)
               and rownum<202 group by so_id) loop
      select max(so_hd) into b_so_hd from bh_pktB where ma_dvi=b_ma_dvi and so_id=r_lp.so_id;
      insert into ket_qua(c1,c2,c3,n1,n2,n10,c10)
          select b_so_hd,ttrang,ten,ngay_ht,ngay_kt,r_lp.so_id,nv
          from bh_pktB where ma_dvi=b_ma_dvi and so_id=r_lp.so_id and lan=r_lp.lan;
      end loop;
    end if;
else
    select count(*) into b_dong from bh_pktB where ma_dvi=b_ma_dvi
             and ngay_ht between b_ngayD and b_ngayC and (phong=b_phong or b_qu='C')
             and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%')
             and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%') and nv=b_nv and b_ttrang in (' ',ttrang)
             and rownum<202;
    if b_dong > 0 then
      for r_lp in (select distinct so_id,max(lan) lan from bh_pktB where ma_dvi=b_ma_dvi
               and ngay_ht between b_ngayD and b_ngayC and (phong=b_phong or b_qu='C')
               and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%')
               and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%') and nv=b_nv and b_ttrang in (' ',ttrang)
               and rownum<202 group by so_id) loop
      select max(so_hd) into b_so_hd from bh_pktB where ma_dvi=b_ma_dvi and so_id=r_lp.so_id;
      insert into ket_qua(c1,c2,c3,n1,n2,n10,c10)
          select b_so_hd,ttrang,ten,ngay_ht,ngay_kt,r_lp.so_id,nv
          from bh_pktB where ma_dvi=b_ma_dvi and so_id=r_lp.so_id and lan=r_lp.lan;
      end loop;
    end if;
end if;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,
    'ngay_hl' value n1,'ngay_kt' value n2,'ma_dvi' value b_ma_dvi,'so_id' value n10,'nv' value c10) returning clob) 
    into cs_lke from ( select * from (
        select t.*, ROW_NUMBER() over (order by n1 desc) as sott from ket_qua t
    ) where sott between b_tu and b_den);
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_TIMJ(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); cs_lke clob:=''; b_tu number; b_den number;
    b_nv varchar2(5); b_ma_kh varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number; b_phong varchar2(10);
begin
-- Dan - Tim hop dong qua CMT, mobi, email
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,ngayd,ngayc,cmt,mobi,email,tu,den');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ngayD,b_ngayC,b_cmt,b_mobi,b_email,b_tu,b_den using b_oraIn;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
b_nv:=nvl(trim(b_nv),'*');
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;   
    select count(*) into b_dong from bh_hd_goc where ma_kh=b_ma_kh and ngay_ht between b_ngayD and b_ngayC and phong=b_phong and so_id_g=0 and b_nv in('*',nv);
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        insert into temp_1(c1,c2,c3,c4,c5,c6,c7,n1,n2,n3,n4) select nv,so_hd,ttrang,ten,ma_dvi,FBH_DTAC_MA_CMT(ma_kh),ma_kh,so_id,
               ngay_hl,ngay_kt,ngay_ht from (select nv,so_hd,ttrang,ten,ma_dvi,so_id,ma_kh,ngay_hl,ngay_kt,ngay_ht,rownum sott 
                    from bh_hd_goc where
            ma_kh=b_ma_kh and ngay_ht between b_ngayD and b_ngayC and phong=b_phong and so_id_g=0 and b_nv in('*',nv) order by ngay_ht desc,nv,so_hd)
            where sott between b_tu and b_den;
    end if;
elsif b_ngayD between b_ngay and 30000101 then
    select count(*) into b_dong from bh_hd_goc where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and phong=b_phong and so_id_g=0 and b_nv in('*',nv);
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        insert into temp_1(c1,c2,c3,c4,c5,c6,c7,n1,n2,n3,n4) select nv,so_hd,ttrang,ten,ma_dvi,FBH_DTAC_MA_CMT(ma_kh),ma_kh,so_id,
               ngay_hl,ngay_kt,ngay_ht from (select nv,so_hd,ttrang,ten,ma_dvi,so_id,ma_kh,ngay_hl,ngay_kt,ngay_ht,rownum sott 
                    from bh_hd_goc where
            ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and phong=b_phong and so_id_g=0 and b_nv in('*',nv) order by ngay_ht desc,nv,so_hd)
            where sott between b_tu and b_den;
    end if;
end if;
select JSON_ARRAYAGG(json_object('nv' value c1,'so_hd' value c2,'ttrang' value c3,'ten' value c4,'ma_dvi' value c5,
       'cmt' value c6,'so_id' value n1,'ngay_hl' value n2,'ngay_kt' value n3,'ngay_ht' value n4,'ma_kh' value c7) 
       order by n4 desc,c1,c2 returning clob) into cs_lke from temp_1;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANGB_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_id number; b_ma_kh varchar2(20); b_so_hd varchar2(20); b_phong varchar2(10);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number; b_ttrang varchar2(1); b_lan number;
begin
-- Dan - Tim bao gia qua CMT, mobi, email
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email using b_oraIn;
b_ttrang:=nvl(trim(b_ttrang),' ');
if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    for r_lp in (select distinct so_id,max(lan) lan from bh_hangB where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and
        ngay_ht between b_ngayD and b_ngayC and phong=b_phong and b_ttrang in (' ',ttrang) group by so_id) loop
        select max(so_hd) into b_so_hd from bh_hangB where ma_dvi=b_ma_dvi and so_id=r_lp.so_id;
        insert into ket_qua(c1,c2,c3,c4,n1,n10)
            select b_so_hd,ttrang,ten,cmt,ngay_ht,r_lp.so_id
            from bh_hangB where ma_dvi=b_ma_dvi and so_id=r_lp.so_id and lan=r_lp.lan;
    end loop;
elsif b_ngayD between b_ngay and 30000101 then
    for r_lp in (select distinct so_id,max(lan) lan from bh_hangB where ma_dvi=b_ma_dvi and
        ngay_ht between b_ngayD and b_ngayC and phong=b_phong and b_ttrang in (' ',ttrang) group by so_id) loop
        select max(so_hd) into b_so_hd from bh_hangB where ma_dvi=b_ma_dvi and so_id=r_lp.so_id;
        insert into ket_qua(c1,c2,c3,c4,n1,n10)
            select b_so_hd,ttrang,ten,cmt,ngay_ht,r_lp.so_id
            from bh_hangB where ma_dvi=b_ma_dvi and so_id=r_lp.so_id and lan=r_lp.lan;
    end loop;
end if;
select count(*) into b_dong from ket_qua;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,
                    'ma_dvi' value b_ma_dvi,'cmt' value c4,'so_id' value n10 returning clob)
                    order by c1 desc returning clob) into cs_lke from ket_qua;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHHD_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_hdon varchar2(30); b_ma_kh varchar2(20);
    b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number; b_ttrang varchar2(1);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_dong number; b_tu number; b_den number;
begin
-- viet anh
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','VAT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hdon,ngayd,ngayc,ttrang,cmt,mobi,email,tu,den');
EXECUTE IMMEDIATE b_lenh into b_so_hdon,b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_tu,b_den using b_oraIn;
b_so_hdon:=nvl(trim(b_so_hdon),' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_ttrang:=nvl(trim(b_ttrang),' ');
b_cmt:=nvl(trim(b_cmt),' '); b_mobi:=nvl(trim(b_mobi),' '); b_email:=nvl(trim(b_email),' ');
b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);

if trim(b_so_hdon) is not null then
  select count(*) into b_dong
         from BH_HD_GOC_VAT a where
                 (a.ma_kh = b_ma_kh OR b_ma_kh IS NULL) and ngay_vat between b_ngayD and b_ngayC
                and b_ttrang in (' ',a.ttrang) and don=b_so_hdon;
  select JSON_ARRAYAGG(json_object(so_id_vat,nv,'ngay' value ngay_vat,'so_hdon' value don,'so_hd' value so_hd,ten,
         ttoan_qd,'thue' value thue_ct,'ttoan' value ttoan_ct returning clob)
       order by ngay_vat desc returning clob) into cs_lke from (
          select t.*, rownum as sott from (select a.so_id_vat,a.ngay_vat,a.don,a.ten,c.nv,c.so_hd,sum(b.ttoan_qd) as ttoan_qd,sum(b.thue) as thue_ct,sum(b.ttoan) as ttoan_ct
             from BH_HD_GOC_VAT a, BH_HD_GOC_VAT_CT b, BH_HD_GOC c 
             where a.so_id_vat = b.so_id_vat and b.so_id = c.so_id  and (a.ma_kh = b_ma_kh OR b_ma_kh IS NULL) and ngay_vat between b_ngayD and b_ngayC
                and b_ttrang in (' ',a.ttrang) and don=b_so_hdon group by a.so_id_vat,a.ngay_vat,a.don,a.ten,c.nv,c.so_hd) t
      ) where sott between b_tu and b_den;
else 
  select count(*) into b_dong
         from BH_HD_GOC_VAT a where
                (a.ma_kh = b_ma_kh OR b_ma_kh IS NULL) and ngay_vat between b_ngayD and b_ngayC
                and b_ttrang in (' ',a.ttrang);
  select JSON_ARRAYAGG(json_object(so_id_vat,nv,'ngay' value ngay_vat,'so_hdon' value don,'so_hd' value so_hd,ten,
         ttoan_qd,'thue' value thue_ct,'ttoan' value ttoan_ct returning clob)
       order by ngay_vat desc returning clob) into cs_lke from (
           select t.*, rownum as sott from (select a.so_id_vat,a.ngay_vat,a.don,a.ten,c.nv,c.so_hd,sum(b.ttoan_qd) as ttoan_qd,sum(b.thue) as thue_ct,sum(b.ttoan) as ttoan_ct
             from BH_HD_GOC_VAT a, BH_HD_GOC_VAT_CT b, BH_HD_GOC c 
             where a.so_id_vat = b.so_id_vat and b.so_id = c.so_id  and (a.ma_kh = b_ma_kh OR b_ma_kh IS NULL) and ngay_vat between b_ngayD and b_ngayC
                and b_ttrang in (' ',a.ttrang)  group by a.so_id_vat,a.ngay_vat,a.don,a.ten,c.nv,c.so_hd) t
      ) where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HOP_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000); cs_lke clob:='';
    b_so_idC number; b_ma_kh varchar2(20); b_so_hd varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);b_ma_sp varchar2(10);
    b_ten nvarchar2(500); b_phong varchar2(10); b_nv varchar2(10); b_nhom varchar2(1);
    b_ngayD number; b_ngayC number; b_ngay_ht number; b_ttrang varchar2(1);
    b_tu number; b_den number; b_qu varchar2(1); b_dong number;
begin
-- Nam - Tim hop dong qua CMT, mobi, email
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HOP','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,so_hd,nv,nhom,ma_sp,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_ten,b_so_hd,b_nv,b_nhom,b_ma_sp,b_tu,b_den using b_oraIn;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
b_ttrang:=nvl(trim(b_ttrang),' '); b_ten:=nvl(trim(upper(b_ten)), ' '); b_ma_sp:=nvl(trim(b_ma_sp), ' ');
b_i1:=PKH_NG_CSO(add_months(sysdate,-36));
if b_ngayD in (0,30000101) or b_ngayD<b_i1 then b_ngayD:=b_i1; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_i1:=0;
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    for r_lp in (select distinct so_id_d from bh_hop where ma_dvi=b_ma_dvi and ma_kh = b_ma_kh and nv=b_nv and nhom=b_nhom
          and ngay_ht between b_ngayD and b_ngayC and phong=b_phong
          and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%') and b_ma_sp in (' ',ma_sp)
          and b_ttrang in (' ',ttrang) and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') order by so_id_d desc) loop
        b_so_idC:=FBH_HOP_SO_IDc(b_ma_dvi,r_lp.so_id_d);
        select max(so_hd),max(ngay_ht) into b_so_hd,b_ngay_ht from bh_hop where ma_dvi=b_ma_dvi and so_id=b_so_idC;
        insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n4,n10,c11)
            select b_so_hd,ttrang,ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_ngay_ht,b_so_idC,FBH_HOP_SP_TEN(ma_sp)
            from bh_hop where ma_dvi=b_ma_dvi and so_id=b_so_idC;
    end loop;
else
    for r_lp in (select distinct so_id_d from bh_hop where ma_dvi=b_ma_dvi and nv=b_nv and nhom=b_nhom
          and ngay_ht between b_ngayD and b_ngayC and phong=b_phong
          and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%') and b_ma_sp in (' ',ma_sp)
          and b_ttrang in (' ',ttrang) and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') order by so_id_d desc) loop
        b_so_idC:=FBH_HOP_SO_IDc(b_ma_dvi,r_lp.so_id_d);
        select max(so_hd),max(ngay_ht) into b_so_hd,b_ngay_ht from bh_hop where ma_dvi=b_ma_dvi and so_id=b_so_idC;
        insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n4,n10,c11)
            select b_so_hd,ttrang,ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_ngay_ht,b_so_idC,FBH_HOP_SP_TEN(ma_sp)
            from bh_hop where ma_dvi=b_ma_dvi and so_id=b_so_idC;
        b_i1:=b_i1+1;
        if b_i1>300 then exit; end if;
    end loop;
end if;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,
    'ngay_hl' value n1,'ngay_kt' value n2,'ngay_cap' value n3, 'ma_sp' value c11,
    'ma_dvi' value b_ma_dvi,'so_id' value n10 returning clob)) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n4 desc,c1) as sott from ket_qua t 
      ) where sott between b_tu and b_den);
select count(*) into b_dong from ket_qua;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_NGU_TIMh(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36)); cs_lke clob:='';
    b_so_idC number;
    b_ma_kh varchar2(20):=''; b_so_hd varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ten nvarchar2(200); b_gioi varchar2(1); b_ng_sinh number; b_dong number;
    b_ngayD number; b_ngayC number; b_ttrangT varchar2(1);
    b_tu number; b_den number; b_nv varchar2(10); b_qu varchar2(1); b_phong varchar2(10);
begin
-- viet anh
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,gioi,ng_sinh,so_hd,tu,den,nv');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrangT,b_cmt,b_mobi,b_email,b_ten,b_gioi,b_ng_sinh,b_so_hd,b_tu,b_den,b_nv using b_oraIn;
b_ttrangT:=nvl(b_ttrangT,' '); b_ten:=nvl(b_ten, ' '); b_so_hd:=nvl(b_so_hd,' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
-- them phan quyen
b_qu:=FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','NG','X');
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAf('','',b_cmt,b_mobi,b_email,b_gioi,b_ng_sinh);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    insert into temp_1(n1)
        select distinct so_id_d from bh_ng a where
           a.ma_kh=b_ma_kh and a.ma_dvi=b_ma_dvi and nv=b_nv
           and a.ngay_ht between b_ngayD and b_ngayC and ttrang='D'
           and (b_ten = ' ' OR upper(a.ten) LIKE '%' || b_ten || '%')
           and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%');
else
    insert into temp_1(n1)
        select distinct so_id_d from bh_ng a where
           a.ma_dvi=b_ma_dvi and nv=b_nv
           and a.ngay_ht between b_ngayD and b_ngayC and ttrang='D'
           and (b_ten = ' ' OR upper(a.ten) LIKE '%' || b_ten || '%')
           and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%');
end if;
for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
  b_so_idC:=FBH_NG_SO_IDc(b_ma_dvi,r_lp.so_id_d);
  select max(so_hd) into b_so_hd from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_idC;
     insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10,c10)
        select t.so_hd,ttrang,t.ten,t.cmt,t.ngay_hl,t.ngay_kt,t.ngay_cap,b_so_idC,t.nv
            from bh_ng t where t.ma_dvi=b_ma_dvi and t.so_id=b_so_idC;
end loop;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'ma_dvi' value b_ma_dvi,'so_id' value n10,'nv' value c10) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by c1 desc) as sott from ket_qua t
      ) where sott between b_tu and b_den and sott<600);
select count(*) into b_dong from ket_qua;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_NGU_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36)); cs_lke clob:='';
    b_ma_kh varchar2(20); b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100); b_dong number;
    b_ngayD number; b_ngayC number; b_so_hsT varchar2(20); b_so_hd varchar2(20);
    b_ttrang varchar2(1); b_tu number; b_den number; b_nv varchar2(10);
begin
-- Dan - Tim hop dong qua CMT, mobi, email
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,so_hs,so_hd,tu,den,nv');
EXECUTE IMMEDIATE b_lenh into b_ngayd,b_ngayc,b_ttrang,b_cmt,b_mobi,b_email,b_so_hsT,b_so_hd,b_tu,b_den,b_nv using b_oraIn;
b_ttrang:=nvl(trim(b_ttrang),' ');
b_so_hd:=nvl(trim(b_so_hd),' '); b_so_hsT:=nvl(trim(b_so_hsT),' ');
if b_ngayd in (0,30000101) then b_ngayd:=b_ngay; end if;
b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
b_ma_kh:=nvl(trim(b_ma_kh),' '); b_so_hsT:=nvl(trim(b_so_hsT),' '); b_so_hd:=nvl(trim(b_so_hd),' ');
select JSON_ARRAYAGG(json_object(so_hs,'ngay' value ngay_xr,ttrang,'so_hd' value decode(so_hd,gcn,'',so_hd),
    gcn,ten,ma_dvi,so_id returning clob) order by so_id desc returning clob)
    into cs_lke from ( select *  from ( select t.*, ROW_NUMBER() over (order by so_id desc) as sott from bh_bt_ng t
        where b_ma_kh in(' ',ma_kh) and nv=b_nv
              and b_ttrang in (' ', ttrang) and (b_so_hsT = ' ' or so_hs like '%' || b_so_hsT || '%')
              and (b_so_hd = ' ' or so_hd like '%' || b_so_hd || '%' or gcn like '%' || b_so_hd || '%')
              and ngay_ht between b_ngayd and b_ngayc and ngay_ht > b_ngay
        ) where sott between b_tu and b_den );
select count(*) into b_dong from bh_bt_ng t
        where b_ma_kh in(' ',ma_kh) and nv=b_nv
              and b_ttrang in (' ', ttrang) and (b_so_hsT = ' ' or so_hs like '%' || b_so_hsT || '%')
              and (b_so_hd = ' ' or so_hd like '%' || b_so_hd || '%' or gcn like '%' || b_so_hd || '%')
              and ngay_ht between b_ngayd and b_ngayc and ngay_ht > b_ngay;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_PHOI_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_id number; b_so_idC number; b_ma_kh varchar2(20); b_so_hd varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(20);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number;
begin
-- Dan - Tim hop dong qua CMT, mobi, email
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,cmt,mobi,email,so_hd');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_cmt,b_mobi,b_email,b_so_hd using b_oraIn;
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_so_hd:=nvl(trim(b_so_hd),' ');
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    select count(*) into b_dong from bh_hd_goc_phoi where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and b_so_hd in (' ',so_hd) and ngay_ht between b_ngayD and b_ngayC;
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hd,ten,'nv' value FBH_HD_NV(ma_dvi,so_id)) order by ngay_ht desc,so_hd returning clob) into cs_lke
        from bh_hd_goc_phoi where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and b_so_hd in (' ',so_hd) and ngay_ht between b_ngayD and b_ngayC;
elsif b_ngayD between b_ngay and 30000101 then
    select count(*) into b_dong from bh_hd_goc_phoi where ma_dvi=b_ma_dvi and b_so_hd in (' ',so_hd) and ngay_ht between b_ngayD and b_ngayC;
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hd,ten,'nv' value FBH_HD_NV(ma_dvi,so_id)) order by ngay_ht desc,so_hd returning clob) into cs_lke
        from bh_hd_goc_phoi where ma_dvi=b_ma_dvi and b_so_hd in (' ',so_hd) and ngay_ht between b_ngayD and b_ngayC;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_TIMx(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_so_id number; b_so_idC number; b_ma_kh varchar2(20); b_so_hd varchar2(20); b_nv varchar2(1);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100); b_ma_sp varchar2(20); b_ten nvarchar2(500);
    b_ngayD number; b_ngayC number; b_ngay_ht number; b_ttrang varchar2(1);
begin
-- Dan - Tim hop dong qua CMT, mobi, email
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ma_sp,nv,so_hd,ten');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_ma_sp,b_nv,b_so_hd,b_ten using b_oraIn;
b_ttrang:=nvl(trim(b_ttrang),' '); b_so_hd:=nvl(trim(b_so_hd),' '); b_nv:=nvl(trim(b_nv),'G');
b_ma_sp:=nvl(trim(b_ma_sp),' '); b_ten:=nvl(trim(upper(b_ten)),' ');
b_i1:=PKH_NG_CSO(add_months(sysdate,-36));
if b_ngayD in (0,30000101) or b_ngayD<b_i1 then b_ngayD:=b_i1; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_i1:=0;
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    for r_lp in (select distinct so_id_d from bh_phh where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and
        ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd and b_ttrang in (' ',ttrang) and nv=b_nv 
        and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%')
        and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') and b_ma_sp in (' ',ma_sp) order by so_id_d desc) loop
        b_so_idC:=FBH_PHH_SO_IDc(b_ma_dvi,r_lp.so_id_d);
        select max(ngay_ht) into b_ngay_ht from bh_phh where ma_dvi=b_ma_dvi and so_id=b_so_idC;
        insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n4,n10,c10,c11)
            select so_hd,ttrang,ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_ngay_ht,b_so_idC,nv,FBH_PHH_SP_TEN(ma_sp)
            from bh_phh where ma_dvi=b_ma_dvi and so_id=b_so_idC;
    end loop;
else
    for r_lp in (select distinct so_id_d from bh_phh where ma_dvi=b_ma_dvi and
        ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd and b_ttrang in (' ',ttrang) and nv=b_nv 
        and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%')
        and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') and b_ma_sp in (' ',ma_sp) order by so_id_d desc) loop
        b_so_idC:=FBH_PHH_SO_IDc(b_ma_dvi,r_lp.so_id_d);
        select max(ngay_ht) into b_ngay_ht from bh_phh where ma_dvi=b_ma_dvi and so_id=b_so_idC;
        insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n4,n10,c10,c11)
            select so_hd,ttrang,ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_ngay_ht,b_so_idC,nv,FBH_PHH_SP_TEN(ma_sp)
            from bh_phh where ma_dvi=b_ma_dvi and so_id=b_so_idC;
        b_i1:=b_i1+1;
        if b_i1>300 then exit; end if;
    end loop;
end if;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,
    'ngay_hl' value n1,'ngay_kt' value n2,'ngay_cap' value n3,
    'ma_dvi' value b_ma_dvi,'so_id' value n10,'nv' value c10,'ma_sp' value c11 returning clob)
    order by n4 desc,c1 returning clob) into b_oraOut from ket_qua;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- tim kiem hs giam dinh
create or replace procedure PBH_BT_GD_HS_TIM(
     b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ngayD number; b_ngayC number; 
    b_so_hs_bt varchar2(20); b_k_ma_gd varchar2(1); b_ma_gd varchar2(20); b_ttrang varchar2(1);
    b_tu number; b_den number; b_dong number; cs_lke clob;
Begin
-- viet anh
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,so_hs_bt,k_ma_gd,ma_gd,ttrang,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_so_hs_bt,b_k_ma_gd,b_ma_gd,b_ttrang,b_tu,b_den using b_oraIn;
b_ngayD:=nvl(b_ngayd,0); b_ngayC:=nvl(b_ngayC,0);
b_so_hs_bt:=nvl(trim(b_so_hs_bt),' '); b_ma_gd:=nvl(trim(b_ma_gd),' ');  b_ttrang:=nvl(trim(b_ttrang),' ');
b_tu:=nvl(b_tu,0); b_den:=nvl(b_den,0); b_k_ma_gd:=nvl(trim(b_k_ma_gd),' ');
if b_ngayC in(0,30000101) then b_ngayC:=PKH_NG_CSO(sysdate); end if;
b_i1:=PKH_NG_CSO(add_months(PKH_SO_CDT(b_ngayC),-36));
if b_ngayD in(0,30000101) or b_ngayD<b_i1 then b_ngayD:=b_i1; end if;
insert into temp_1(n1,n2,n3,c1,c2,c3,c4,c5,c6)
    select so_id,ngay_ht,tien,so_hs,so_hs_bt,ttrang,FBH_BT_GD_HS_GDINH_TEN(b_ma_dvi,so_id),ten,ma_nt
           from bh_bt_gd_hs where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and
                b_so_hs_bt in(' ',so_hs_bt) and b_k_ma_gd in(' ',k_ma_gd) and b_ma_gd in(' ',ma_gd) and b_ttrang in(' ',ttrang) 
                and rownum<302
    order by ngay_ht desc,so_id;
select count(*) into b_dong from temp_1;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(ngay_ht,so_hs,so_hs_bt,ttrang,ma_gd,ma_nt,tien,ten,so_id) returning clob) into cs_lke from
    (select n1 so_id,n2 ngay_ht,n3 tien,c1 so_hs,c2 so_hs_bt,c3 ttrang,c4 ma_gd,c5 ten,c6 ma_nt,rownum sott from temp_1 order by n1 desc,n1)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
-- tim kiem bao gia con nguoi
create or replace procedure PBH_NGB_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_dong number; cs_lke clob:='';
    b_so_id number; b_lan number; b_ma_kh varchar2(20); b_so_hd varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ngayD number; b_ngayC number; b_ttrang varchar2(1); b_phong varchar2(10);
begin
-- Dan - Tim hop dong qua CMT, mobi, email
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email using b_oraIn;
b_ttrang:=nvl(trim(b_ttrang),' ');
if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    for r_lp in (select so_id,max(lan) lan from bh_ngB where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and
        ngay_ht between b_ngayD and b_ngayC and phong=b_phong and b_ttrang in (' ',ttrang) group by so_id) loop
        b_so_id:=r_lp.so_id; b_lan:=r_lp.lan;
        select FHT_MA_DTAC_CMT(b_ma_dvi,ma_kh) into b_cmt from bh_ngB where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan;
        insert into ket_qua(c1,c2,c3,c4,c10,n1,n2,n3,n10,n11)
            select so_hd,ttrang,ten,b_cmt,nv,ngay_ht,ngay_hl,ngay_kt,b_so_id,b_lan
            from bh_ngB where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan;
    end loop;
else
    for r_lp in (select so_id,max(lan) lan from bh_ngB where ma_dvi=b_ma_dvi and
        ngay_ht between b_ngayD and b_ngayC and phong=b_phong and b_ttrang in (' ',ttrang) group by so_id) loop
        b_so_id:=r_lp.so_id; b_lan:=r_lp.lan;
        select FHT_MA_DTAC_CMT(b_ma_dvi,ma_kh) into b_cmt from bh_ngB where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan;
        insert into ket_qua(c1,c2,c3,c4,c10,n1,n2,n3,n10,n11)
            select so_hd,ttrang,ten,b_cmt,nv,ngay_ht,ngay_hl,ngay_kt,b_so_id,b_lan
            from bh_ngB where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan;
    end loop;
end if;
select count(*) into b_dong from ket_qua;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,'ngay_ht' value n1,
    'ngay_hl' value n2,'ngay_kt' value n3,'ma_dvi' value b_ma_dvi,'nv' value c10,'so_id' value n10,'lan' value n11 returning clob)
    order by n1 desc,c1 returning clob) into cs_lke from ket_qua;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_2B_TIM_IMP(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_id number;  b_so_idC number; b_so_hd_c varchar2(40); b_so_hd varchar2(40);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number;
    b_ten nvarchar2(200); b_phong varchar2(10); b_nv varchar2(1);
    b_tu number; b_den number;
begin
-- Duchq
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','2B','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,so_hd,tu,den,nv');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_so_hd,b_tu,b_den,b_nv using b_oraIn;
b_nv:=nvl(b_nv,'G'); b_so_hd:=nvl(trim(b_so_hd),' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if trim(b_so_hd) is not null then
  insert into temp_1(n1) select so_id from bh_hd_map where ma_dvi = b_ma_dvi and so_hd = b_so_hd;
  for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
    b_so_idC:=FBH_2B_SO_IDc(b_ma_dvi,r_lp.so_id_d);
    insert into ket_qua(c1,c2,c3,n1,n2,n3,n4,c4)
    select t1.so_hd,t.so_hd,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.nv
    from bh_hd_map t
      join bh_2b t1 on t.so_id = t1.so_id
      join bh_2b_ds t2 on t.so_id = t2.so_id
    where t.so_id = b_so_idC and t1.nv = b_nv and t1.ngay_ht between b_ngayD and b_ngayC;
  end loop;
else
  -- lay all theo dieu kien
  insert into ket_qua(c1,c2,c3,n1,n2,n3,n4,c4)
  select t1.so_hd,t.so_hd,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.nv
    from bh_hd_map t
         join bh_2b t1 on t.so_id = t1.so_id
         join bh_2b_ds t2 on t.so_id = t2.so_id
   where t.ma_dvi = b_ma_dvi
     and t1.nv = b_nv
     and t1.ngay_ht between b_ngayD and b_ngayC;
end if;

select JSON_ARRAYAGG(json_object('ma_dvi' value b_ma_dvi,'so_hd' value c1,'so_hd_c' value c2,'gcn' value c3,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'so_id' value n4,'nv' value c4) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n3 desc, n4 desc) as sott from ket_qua t
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNVC_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(2000); cs_lke clob:=''; b_i1 number;
    b_so_id number; b_so_idC number; b_ma_kh varchar2(20); b_so_hd varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100); b_ma_sp varchar2(10);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number; b_ttrang varchar2(1); b_ten nvarchar2(500);
begin
-- Nam - Tim hop dong qua CMT, mobi, email
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ma_sp,ten');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_ma_sp,b_ten using b_oraIn;
b_ttrang:=nvl(trim(b_ttrang),' '); b_ma_sp:=nvl(trim(b_ma_sp),' '); b_ten:=nvl(trim(upper(b_ten)), ' ');
b_i1:=PKH_NG_CSO(add_months(sysdate,-36));
if b_ngayD in (0,30000101) or b_ngayD<b_i1 then b_ngayD:=b_i1; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_i1:=0;
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    for r_lp in (select distinct so_id_d from bh_ptnvc where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and
        ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd and b_ttrang in (' ',ttrang) and b_ma_sp in (' ',ma_sp)
        and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%'))
        loop b_so_idC:=FBH_PTNVC_SO_IDc(b_ma_dvi,r_lp.so_id_d);
        select max(so_hd) into b_so_hd from bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_idC;
        insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10,c11)
            select b_so_hd,ttrang,ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_so_idC,FBH_PTNVC_SP_TEN(ma_sp)
            from bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_idC;
    end loop;
elsif b_ngayD between b_ngay and 30000101 then
    for r_lp in (select distinct so_id_d from bh_ptnvc where ma_dvi=b_ma_dvi and
        ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd and b_ttrang in (' ',ttrang) and b_ma_sp in (' ',ma_sp)
        and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%'))
        loop b_so_idC:=FBH_PTNVC_SO_IDc(b_ma_dvi,r_lp.so_id_d);
        select max(so_hd) into b_so_hd from bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_idC;
        insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n10,c11)
            select b_so_hd,ttrang,ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_so_idC,FBH_PTNVC_SP_TEN(ma_sp)
            from bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_idC;
        b_i1:=b_i1+1;
        if b_i1>300 then exit; end if;
    end loop;
end if;
select count(*) into b_dong from ket_qua;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,
    'ngay_hl' value n1,'ngay_kt' value n2,'ngay_cap' value n3,'ma_sp' value c11,
    'ma_dvi' value b_ma_dvi,'so_id' value n10)
    order by c1 desc returning clob) into cs_lke from ket_qua;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_XE_TIM_IMP(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_id number;  b_so_idC number; b_so_hd_c varchar2(40); b_so_hd varchar2(40);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number;
    b_ten nvarchar2(200); b_phong varchar2(10); b_nv varchar2(1);
    b_tu number; b_den number;
begin
-- viet anh
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','XE','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,so_hd_c,tu,den,nv');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_so_hd_c,b_tu,b_den,b_nv using b_oraIn;
b_nv:=nvl(b_nv,'G'); b_so_hd_c:=nvl(trim(b_so_hd_c),' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if trim(b_so_hd_c) is not null then
  insert into temp_1(n1) select so_id from bh_hd_map where ma_dvi = b_ma_dvi and so_hd_c = b_so_hd_c;
  for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
    b_so_idC:=FBH_XE_SO_IDc(b_ma_dvi,r_lp.so_id_d);
    insert into ket_qua(c1,c2,c3,n1,n2,n3,n4,c4)
    select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.nv
    from bh_hd_map t
      join bh_xe t1 on t.so_id = t1.so_id
      join bh_xe_ds t2 on t.so_id = t2.so_id
    where t.so_id = b_so_idC and t1.nv = b_nv and t.so_hd_c = b_so_hd_c and t1.ngay_ht between b_ngayD and b_ngayC;
  end loop;
else
  -- lay all theo dieu kien
  insert into ket_qua(c1,c2,c3,n1,n2,n3,n4,c4)
  select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.nv
    from bh_hd_map t
         join bh_xe t1 on t.so_id = t1.so_id
         join bh_xe_ds t2 on t.so_id = t2.so_id
   where t.ma_dvi = b_ma_dvi
     and t1.nv = b_nv
     and t1.ngay_ht between b_ngayD and b_ngayC;
end if;
select JSON_ARRAYAGG(json_object('ma_dvi' value b_ma_dvi,'so_hd' value c1,'so_hd_c' value c2,'gcn' value c3,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'so_id' value n4,'nv' value c4) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n3 desc, n4 desc) as sott from ket_qua t
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHH_TIM_IMP(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_id number;  b_so_idC number; b_so_hd_c varchar2(40); b_so_hd varchar2(40);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number;
    b_ten nvarchar2(200); b_phong varchar2(10); b_nv varchar2(1);
    b_tu number; b_den number;
begin
-- viet anh
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,so_hd_c,tu,den,nv');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_so_hd_c,b_tu,b_den,b_nv using b_oraIn;
b_nv:=nvl(b_nv,'G'); b_so_hd_c:=nvl(trim(b_so_hd_c),' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if trim(b_so_hd_c) is not null then
  insert into temp_1(n1) select so_id from bh_hd_map where ma_dvi = b_ma_dvi and so_hd_c = b_so_hd_c;
  for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
    b_so_idC:=FBH_PHH_SO_IDc(b_ma_dvi,r_lp.so_id_d);
    insert into ket_qua(c1,c2,c3,n1,n2,n3,n4,c4)
    select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.nv
    from bh_hd_map t
      join bh_phh t1 on t.so_id = t1.so_id
      join bh_phh_dvi t2 on t.so_id = t2.so_id
    where t.so_id = b_so_idC and t1.nv = b_nv and t.so_hd_c = b_so_hd_c and t1.ngay_ht between b_ngayD and b_ngayC;
  end loop;
else
  -- lay all theo dieu kien
  insert into ket_qua(c1,c2,c3,n1,n2,n3,n4,c4)
  select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.nv
    from bh_hd_map t
         join bh_phh t1 on t.so_id = t1.so_id
         join bh_phh_dvi t2 on t.so_id = t2.so_id
   where t.ma_dvi = b_ma_dvi
     and t1.nv = b_nv
     and t1.ngay_ht between b_ngayD and b_ngayC;
end if;
select JSON_ARRAYAGG(json_object('ma_dvi' value b_ma_dvi,'so_hd' value c1,'so_hd_c' value c2,'gcn' value c3,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'so_id' value n4,'nv' value c4) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n3 desc, n4 desc) as sott from ket_qua t
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKT_TIM_IMP(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_id number;  b_so_idC number; b_so_hd_c varchar2(40); b_so_hd varchar2(40);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number;
    b_ten nvarchar2(200); b_phong varchar2(10); b_nv varchar2(1);
    b_tu number; b_den number;
begin
-- viet anh
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,so_hd_c,tu,den,nv');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_so_hd_c,b_tu,b_den,b_nv using b_oraIn;
b_nv:=nvl(b_nv,'G'); b_so_hd_c:=nvl(trim(b_so_hd_c),' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if trim(b_so_hd_c) is not null then
  insert into temp_1(n1) select so_id from bh_hd_map where ma_dvi = b_ma_dvi and so_hd_c = b_so_hd_c;
  for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
    b_so_idC:=FBH_PKT_SO_IDc(b_ma_dvi,r_lp.so_id_d);
    insert into ket_qua(c1,c2,c3,n1,n2,n3,n4,c4)
    select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.nv
    from bh_hd_map t
      join bh_pkt t1 on t.so_id = t1.so_id
      join bh_pkt_dvi t2 on t.so_id = t2.so_id
    where t.so_id = b_so_idC and t1.nv = b_nv and t.so_hd_c = b_so_hd_c and t1.ngay_ht between b_ngayD and b_ngayC;
  end loop;
else
  -- lay all theo dieu kien
  insert into ket_qua(c1,c2,c3,n1,n2,n3,n4,c4)
  select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.nv
    from bh_hd_map t
         join bh_pkt t1 on t.so_id = t1.so_id
         join bh_pkt_dvi t2 on t.so_id = t2.so_id
   where t.ma_dvi = b_ma_dvi
     and t1.nv = b_nv
     and t1.ngay_ht between b_ngayD and b_ngayC;
end if;
select JSON_ARRAYAGG(json_object('ma_dvi' value b_ma_dvi,'so_hd' value c1,'so_hd_c' value c2,'gcn' value c3,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'so_id' value n4,'nv' value c4) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n3 desc, n4 desc) as sott from ket_qua t
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HANG_TIM_IMP(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_id number;  b_so_idC number; b_so_hd_c varchar2(40); b_so_hd varchar2(40);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number;
    b_ten nvarchar2(200); b_phong varchar2(10); b_nv varchar2(1);
    b_tu number; b_den number;
begin
-- viet anh
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HANG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,so_hd_c,tu,den,nv');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_so_hd_c,b_tu,b_den,b_nv using b_oraIn;
b_nv:=nvl(b_nv,'G'); b_so_hd_c:=nvl(trim(b_so_hd_c),' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if trim(b_so_hd_c) is not null then
  insert into temp_1(n1) select so_id from bh_hd_map where ma_dvi = b_ma_dvi and so_hd_c = b_so_hd_c;
  for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
    b_so_idC:=FBH_HANG_SO_IDc(b_ma_dvi,r_lp.so_id_d);
    insert into ket_qua(c1,c2,n1,n2,n3,n4)
    select t1.so_hd,t.so_hd_c,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id
    from bh_hd_map t
      join bh_hang t1 on t.so_id = t1.so_id
      join bh_hang_ds t2 on t.so_id = t2.so_id
    where t.so_id = b_so_idC and t.so_hd_c = b_so_hd_c and t1.ngay_ht between b_ngayD and b_ngayC;
  end loop;
else
  -- lay all theo dieu kien
  insert into ket_qua(c1,c2,n1,n2,n3,n4)
  select t1.so_hd,t.so_hd_c,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id
    from bh_hd_map t
         join bh_hang t1 on t.so_id = t1.so_id
         join bh_hang_ds t2 on t.so_id = t2.so_id
   where t.ma_dvi = b_ma_dvi
     and t1.ngay_ht between b_ngayD and b_ngayC;
end if;
select JSON_ARRAYAGG(json_object('ma_dvi' value b_ma_dvi,'so_hd' value c1,'so_hd_c' value c2,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'so_id' value n4) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n3 desc, n4 desc) as sott from ket_qua t
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TAU_TIM_IMP(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_id number;  b_so_idC number; b_so_hd_c varchar2(40); b_so_hd varchar2(40);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number;
    b_ten nvarchar2(200); b_phong varchar2(10); b_nv varchar2(1);
    b_tu number; b_den number;
begin
-- viet anh
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TAU','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,so_hd_c,tu,den,nv');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_so_hd_c,b_tu,b_den,b_nv using b_oraIn;
b_nv:=nvl(b_nv,'G'); b_so_hd_c:=nvl(trim(b_so_hd_c),' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if trim(b_so_hd_c) is not null then
  insert into temp_1(n1) select so_id from bh_hd_map where ma_dvi = b_ma_dvi and so_hd_c = b_so_hd_c;
  for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
    b_so_idC:=FBH_TAU_SO_IDc(b_ma_dvi,r_lp.so_id_d);
    insert into ket_qua(c1,c2,c3,n1,n2,n3,n4,c4)
    select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.nv
    from bh_hd_map t
      join bh_tau t1 on t.so_id = t1.so_id
      join bh_tau_ds t2 on t.so_id = t2.so_id
    where t.so_id = b_so_idC and t1.nv = b_nv and t.so_hd_c = b_so_hd_c and t1.ngay_ht between b_ngayD and b_ngayC;
  end loop;
else
  -- lay all theo dieu kien
  insert into ket_qua(c1,c2,c3,n1,n2,n3,n4,c4)
  select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.nv
    from bh_hd_map t
         join bh_tau t1 on t.so_id = t1.so_id
         join bh_tau_ds t2 on t.so_id = t2.so_id
   where t.ma_dvi = b_ma_dvi
     and t1.nv = b_nv
     and t1.ngay_ht between b_ngayD and b_ngayC;
end if;
select JSON_ARRAYAGG(json_object('ma_dvi' value b_ma_dvi,'so_hd' value c1,'so_hd_c' value c2,'gcn' value c3,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'so_id' value n4,'nv' value c4) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n3 desc, n4 desc) as sott from ket_qua t
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNCC_TIM_IMP(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_id number;  b_so_idC number; b_so_hd_c varchar2(40); b_so_hd varchar2(40);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number;
    b_ten nvarchar2(200); b_phong varchar2(10); b_nv varchar2(10); b_lbh varchar2(1);
    b_tu number; b_den number;
begin
-- viet anh
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,so_hd_c,tu,den,lbh');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_so_hd_c,b_tu,b_den,b_lbh using b_oraIn;
b_lbh:=nvl(b_lbh,'G'); b_so_hd_c:=nvl(trim(b_so_hd_c),' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if trim(b_so_hd_c) is not null then
  insert into temp_1(n1) select so_id from bh_hd_map where ma_dvi = b_ma_dvi and so_hd_c = b_so_hd_c;
  for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
    b_so_idC:=FBH_PTN_SO_IDc(b_ma_dvi,r_lp.so_id_d);
    insert into ket_qua(c1,c2,c3,n1,n2,n3,n4,c4)
    select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.lbh
    from bh_hd_map t
      join bh_ptn t1 on t.so_id = t1.so_id
      join bh_ptn_dvi t2 on t.so_id = t2.so_id
    where t.so_id = b_so_idC and t1.lbh = b_lbh and t.so_hd_c = b_so_hd_c and t1.ngay_ht between b_ngayD and b_ngayC and t1.nv='TNCC';
  end loop;
else
  -- lay all theo dieu kien
  insert into ket_qua(c1,c2,c3,n1,n2,n3,n4,c4)
  select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.lbh
    from bh_hd_map t
         join bh_ptn t1 on t.so_id = t1.so_id
         join bh_ptn_dvi t2 on t.so_id = t2.so_id
   where t.ma_dvi = b_ma_dvi
     and t1.lbh = b_lbh and t1.nv='TNCC'
     and t1.ngay_ht between b_ngayD and b_ngayC;
end if;
select JSON_ARRAYAGG(json_object('ma_dvi' value b_ma_dvi,'so_hd' value c1,'so_hd_c' value c2,'gcn' value c3,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'so_id' value n4,'nv' value c4) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n3 desc, n4 desc) as sott from ket_qua t
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNNN_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_so_idC number; b_ma_kh varchar2(20); b_so_hd varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100); 
    b_ten nvarchar2(500); b_phong varchar2(10); b_ma_sp varchar2(10); b_nv varchar2(1);
    b_ngayD number; b_ngayC number; b_ngay_ht number; b_ttrang varchar2(1);
begin
-- Nam - Tim hop dong qua CMT, mobi, email
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,so_hd,nv,ma_sp');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_ten,b_so_hd,b_nv,b_ma_sp using b_oraIn;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd); b_ma_sp:=nvl(trim(b_ma_sp),' ');
b_ttrang:=nvl(trim(b_ttrang),' '); b_ten:=nvl(trim(upper(b_ten)), ' ');
b_i1:=PKH_NG_CSO(add_months(sysdate,-36));
if b_ngayD in (0,30000101) or b_ngayD<b_i1 then b_ngayD:=b_i1; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_i1:=0;
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    for r_lp in (select distinct so_id_d from bh_ptnnn where ma_dvi=b_ma_dvi and ma_kh = b_ma_kh and nv=b_nv 
          and ngay_ht between b_ngayD and b_ngayC and phong=b_phong
          and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%') and b_ma_sp in (' ',ma_sp)
          and b_ttrang in (' ',ttrang) and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') order by so_id_d desc) loop
        b_so_idC:=FBH_PTNNN_SO_IDc(b_ma_dvi,r_lp.so_id_d);
        select max(so_hd),max(ngay_ht) into b_so_hd,b_ngay_ht from bh_ptnnn where ma_dvi=b_ma_dvi and so_id=b_so_idC;
        insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n4,n10,c11)
            select b_so_hd,ttrang,ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_ngay_ht,b_so_idC,FBH_PTNNN_SP_TEN(ma_sp)
            from bh_ptnnn where ma_dvi=b_ma_dvi and so_id=b_so_idC;
    end loop;
else
    for r_lp in (select distinct so_id_d from bh_ptnnn where ma_dvi=b_ma_dvi and nv=b_nv 
          and ngay_ht between b_ngayD and b_ngayC and phong=b_phong
          and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%') and b_ma_sp in (' ',ma_sp)
          and b_ttrang in (' ',ttrang) and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') order by so_id_d desc) loop
        b_so_idC:=FBH_PTNNN_SO_IDc(b_ma_dvi,r_lp.so_id_d);
        select max(so_hd),max(ngay_ht) into b_so_hd,b_ngay_ht from bh_ptnnn where ma_dvi=b_ma_dvi and so_id=b_so_idC;
        insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n4,n10,c11)
            select b_so_hd,ttrang,ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_ngay_ht,b_so_idC,FBH_PTNNN_SP_TEN(ma_sp)
            from bh_ptnnn where ma_dvi=b_ma_dvi and so_id=b_so_idC;
        b_i1:=b_i1+1;
        if b_i1>300 then exit; end if;
    end loop;
end if;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,
    'ngay_hl' value n1,'ngay_kt' value n2,'ngay_cap' value n3,'ma_sp' value c11,
    'ma_dvi' value b_ma_dvi,'so_id' value n10 returning clob)
    order by n4 desc,c1 returning clob) into b_oraOut from ket_qua;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNNN_TIM_IMP(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_id number;  b_so_idC number; b_so_hd_c varchar2(40); b_so_hd varchar2(40);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number;
    b_ten nvarchar2(200); b_phong varchar2(10); b_nv varchar2(10); b_lbh varchar2(1);
    b_tu number; b_den number;
begin
-- viet anh
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,so_hd_c,tu,den,lbh');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_so_hd_c,b_tu,b_den,b_lbh using b_oraIn;
b_lbh:=nvl(b_lbh,'G'); b_so_hd_c:=nvl(trim(b_so_hd_c),' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if trim(b_so_hd_c) is not null then
  insert into temp_1(n1) select so_id from bh_hd_map where ma_dvi = b_ma_dvi and so_hd_c = b_so_hd_c;
  for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
    b_so_idC:=FBH_PTN_SO_IDc(b_ma_dvi,r_lp.so_id_d);
    insert into ket_qua(c1,c2,c3,n1,n2,n3,n4,c4)
    select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.lbh
    from bh_hd_map t
      join bh_ptn t1 on t.so_id = t1.so_id
      join bh_ptn_dvi t2 on t.so_id = t2.so_id
    where t.so_id = b_so_idC and t1.lbh = b_lbh and t.so_hd_c = b_so_hd_c and t1.ngay_ht between b_ngayD and b_ngayC and t1.nv='TNNN';
  end loop;
else
  -- lay all theo dieu kien
  insert into ket_qua(c1,c2,c3,n1,n2,n3,n4,c4)
  select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.lbh
    from bh_hd_map t
         join bh_ptn t1 on t.so_id = t1.so_id
         join bh_ptn_dvi t2 on t.so_id = t2.so_id
   where t.ma_dvi = b_ma_dvi
     and t1.lbh = b_lbh and t1.nv='TNNN'
     and t1.ngay_ht between b_ngayD and b_ngayC;
end if;
select JSON_ARRAYAGG(json_object('ma_dvi' value b_ma_dvi,'so_hd' value c1,'so_hd_c' value c2,'gcn' value c3,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'so_id' value n4,'nv' value c4) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n3 desc, n4 desc) as sott from ket_qua t
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNVC_TIM_IMP(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_id number;  b_so_idC number; b_so_hd_c varchar2(40); b_so_hd varchar2(40);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number;
    b_ten nvarchar2(200); b_phong varchar2(10); b_nv varchar2(10); b_lbh varchar2(1);
    b_tu number; b_den number;
begin
-- viet anh
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,so_hd_c,tu,den,lbh');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_so_hd_c,b_tu,b_den,b_lbh using b_oraIn;
b_lbh:=nvl(b_lbh,'G'); b_so_hd_c:=nvl(trim(b_so_hd_c),' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if trim(b_so_hd_c) is not null then
  insert into temp_1(n1) select so_id from bh_hd_map where ma_dvi = b_ma_dvi and so_hd_c = b_so_hd_c;
  for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
    b_so_idC:=FBH_PTN_SO_IDc(b_ma_dvi,r_lp.so_id_d);
    insert into ket_qua(c1,c2,c3,n1,n2,n3,n4,c4)
    select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.lbh
    from bh_hd_map t
      join bh_ptn t1 on t.so_id = t1.so_id
      join bh_ptn_dvi t2 on t.so_id = t2.so_id
    where t.so_id = b_so_idC and t1.lbh = b_lbh and t.so_hd_c = b_so_hd_c and t1.ngay_ht between b_ngayD and b_ngayC and t1.nv='TNVC';
  end loop;
else
  -- lay all theo dieu kien
  insert into ket_qua(c1,c2,c3,n1,n2,n3,n4,c4)
  select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.lbh
    from bh_hd_map t
         join bh_ptn t1 on t.so_id = t1.so_id
         join bh_ptn_dvi t2 on t.so_id = t2.so_id
   where t.ma_dvi = b_ma_dvi
     and t1.lbh = b_lbh and t1.nv='TNVC'
     and t1.ngay_ht between b_ngayD and b_ngayC;
end if;
select JSON_ARRAYAGG(json_object('ma_dvi' value b_ma_dvi,'so_hd' value c1,'so_hd_c' value c2,'gcn' value c3,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'so_id' value n4,'nv' value c4) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n3 desc, n4 desc) as sott from ket_qua t
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNCH_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_so_idC number; b_ma_kh varchar2(20); b_so_hd varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ten nvarchar2(500); b_phong varchar2(10); b_nv varchar2(10); b_nhom varchar2(1); b_ma_sp varchar2(10);
    b_ngayD number; b_ngayC number; b_ngay_ht number; b_ttrang varchar2(1);
begin
-- Nam - Tim hop dong qua CMT, mobi, email
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,so_hd,nv,nhom,ma_sp');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_ten,b_so_hd,b_nv,b_nhom,b_ma_sp using b_oraIn;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);b_ma_sp:=nvl(trim(b_ma_sp),' ');
b_ttrang:=nvl(trim(b_ttrang),' '); b_ten:=nvl(trim(upper(b_ten)), ' ');
b_i1:=PKH_NG_CSO(add_months(sysdate,-36));
if b_ngayD in (0,30000101) or b_ngayD<b_i1 then b_ngayD:=b_i1; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_i1:=0;
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    for r_lp in (select distinct so_id_d from bh_ptnch where ma_dvi=b_ma_dvi and ma_kh = b_ma_kh and nv=b_nv and nhom=b_nhom
          and ngay_ht between b_ngayD and b_ngayC and phong=b_phong
          and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%') and b_ma_sp in (' ',ma_sp)
          and b_ttrang in (' ',ttrang) and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') order by so_id_d desc) loop
        b_so_idC:=FBH_PTNCH_SO_IDc(b_ma_dvi,r_lp.so_id_d);
        select max(so_hd),max(ngay_ht) into b_so_hd,b_ngay_ht from bh_ptnch where ma_dvi=b_ma_dvi and so_id=b_so_idC;
        insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n4,n10,c11)
            select b_so_hd,ttrang,ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_ngay_ht,b_so_idC,FBH_PTNCH_SP_TEN(ma_sp)
            from bh_ptnch where ma_dvi=b_ma_dvi and so_id=b_so_idC;
    end loop;
else
    for r_lp in (select distinct so_id_d from bh_ptnch where ma_dvi=b_ma_dvi and nv=b_nv and nhom=b_nhom
          and ngay_ht between b_ngayD and b_ngayC and phong=b_phong
          and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%')
          and b_ttrang in (' ',ttrang) and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') order by so_id_d desc) loop
        b_so_idC:=FBH_PTNCH_SO_IDc(b_ma_dvi,r_lp.so_id_d);
        select max(so_hd),max(ngay_ht) into b_so_hd,b_ngay_ht from bh_ptnch where ma_dvi=b_ma_dvi and so_id=b_so_idC;
        insert into ket_qua(c1,c2,c3,c4,n1,n2,n3,n4,n10,c11)
            select b_so_hd,ttrang,ten,cmt,ngay_hl,ngay_kt,ngay_cap,b_ngay_ht,b_so_idC,FBH_PTNCH_SP_TEN(ma_sp)
            from bh_ptnch where ma_dvi=b_ma_dvi and so_id=b_so_idC;
        b_i1:=b_i1+1;
        if b_i1>300 then exit; end if;
    end loop;
end if;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ttrang' value c2,'ten' value c3,'cmt' value c4,
    'ngay_hl' value n1,'ngay_kt' value n2,'ngay_cap' value n3,'ma_sp' value c11,
    'ma_dvi' value b_ma_dvi,'so_id' value n10 returning clob)
    order by n4 desc,c1 returning clob) into b_oraOut from ket_qua;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_QTAC_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_dong number:=0; cs_lke clob:=''; b_tim nvarchar2(200);
    b_lenh varchar2(1000); b_tu number; b_den number;
    b_nv varchar2(1000);
    b_2b varchar2(1); b_xe varchar2(1); b_hang varchar2(1); b_phh varchar2(1);
    b_pkt varchar2(1); b_ptn varchar2(1); b_nguoi varchar2(1); b_tau varchar2(1);
    b_hop varchar2(1); b_nong varchar2(1);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,nv,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_nv,b_tu,b_den using b_oraIn;
b_lenh:=FKH_JS_LENH('xm,xe,hang,phh,pkt,ptn,nguoi,tau,hop,nong');
EXECUTE IMMEDIATE b_lenh into b_2b,b_xe,b_hang,b_phh,b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong using b_nv;
b_nv:=FBH_MA_NV_DUNG(b_2b,b_xe,b_hang,b_phh,b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong);
if b_tim is null then
  select count(*) into b_dong from bh_ma_qtac where (b_nv = ' ' OR upper(nv) = b_nv);
  PKH_LKE_TRANG(b_dong,b_tu,b_den);
  select JSON_ARRAYAGG(obj) into cs_lke from
    (select json_object(ma,ten,nsd) obj,rownum sott from bh_ma_qtac where (b_nv = ' ' OR upper(nv) = b_nv) order by ten)
            where sott between b_tu and b_den;
else
  select count(*) into b_dong from bh_ma_qtac where upper(ten) like b_tim and (b_nv = ' ' OR upper(nv) = b_nv);
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma) returning clob) into cs_lke from
        (select a.*,rownum sott from bh_ma_qtac a where upper(ten) like b_tim and (b_nv = ' ' OR upper(nv) = b_nv) order by ma) 
    where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_LHNV_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob; b_nv varchar2(1000);
    b_2b varchar2(1); b_xe varchar2(1); b_hang varchar2(1); b_phh varchar2(1);
    b_pkt varchar2(1); b_ptn varchar2(1); b_nguoi varchar2(1); b_tau varchar2(1);
    b_hop varchar2(1); b_nong varchar2(1);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,nv,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_nv,b_tu,b_den using b_oraIn;
b_lenh:=FKH_JS_LENH('xm,xe,hang,phh,pkt,ptn,nguoi,tau,hop,nong');
EXECUTE IMMEDIATE b_lenh into b_2b,b_xe,b_hang,b_phh,b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong using b_nv;
b_nv:=FBH_MA_NV_DUNG(b_2b,b_xe,b_hang,b_phh,b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong);
if b_tim is null then
    select count(*) into b_dong from bh_ma_lhnv where (b_nv = ' ' OR upper(nv) = b_nv);
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep) returning clob) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_ma_lhnv where (b_nv = ' ' OR upper(nv) = b_nv) order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_lhnv where upper(ten) like b_tim and (b_nv = ' ' OR upper(nv) = b_nv);
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma) returning clob) into cs_lke from
        (select a.*,rownum sott from bh_ma_lhnv a where upper(ten) like b_tim and (b_nv = ' ' OR upper(nv) = b_nv) order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_DK_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob; b_nv varchar2(1000);
    b_2b varchar2(1); b_xe varchar2(1); b_hang varchar2(1); b_phh varchar2(1);
    b_pkt varchar2(1); b_ptn varchar2(1); b_nguoi varchar2(1); b_tau varchar2(1);
    b_hop varchar2(1); b_nong varchar2(1);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,nv,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_nv,b_tu,b_den using b_oraIn;
b_lenh:=FKH_JS_LENH('xm,xe,hang,phh,pkt,ptn,nguoi,tau,hop,nong');
EXECUTE IMMEDIATE b_lenh into b_2b,b_xe,b_hang,b_phh,b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong using b_nv;
b_nv:=trim(FBH_MA_NV_DUNG(b_2b,b_xe,b_hang,b_phh,b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong));
if b_tim is null then
    select count(*) into b_dong from bh_ma_dk t where ( b_nv is null or exists ( 
           select 1 from ( select trim(regexp_substr(b_nv, '[^,]+', 1, level)) t1 from dual
                connect by regexp_substr(b_nv, '[^,]+', 1, level) is not null
            ) where t1 is not null and instr(',' || upper(t.nv) || ',', ',' || upper(t1) || ',') > 0));
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep) returning clob) into cs_lke from
        (select t.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_ma_dk order by ma) a
            start with trim(ma_ct) is null CONNECT BY prior ma=ma_ct) t where ( b_nv is null or exists ( 
             select 1 from ( select trim(regexp_substr(b_nv, '[^,]+', 1, level)) t1 from dual
                  connect by regexp_substr(b_nv, '[^,]+', 1, level) is not null
              ) where t1 is not null and instr(',' || upper(t.nv) || ',', ',' || upper(t1) || ',') > 0)))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_dk t where upper(ten) like b_tim and ( b_nv is null or exists ( 
           select 1 from ( select trim(regexp_substr(b_nv, '[^,]+', 1, level)) t1 from dual
                connect by regexp_substr(b_nv, '[^,]+', 1, level) is not null
            ) where t1 is not null and instr(',' || upper(t.nv) || ',', ',' || upper(t1) || ',') > 0));
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma) returning clob) into cs_lke from
        (select t.*,rownum sott from bh_ma_dk t where upper(ten) like b_tim and ( b_nv is null or exists ( 
           select 1 from ( select trim(regexp_substr(b_nv, '[^,]+', 1, level)) t1 from dual
                connect by regexp_substr(b_nv, '[^,]+', 1, level) is not null
            ) where t1 is not null and instr(',' || upper(t.nv) || ',', ',' || upper(t1) || ',') > 0)) order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_DKBS_TIM (
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob; b_nv varchar2(1000);
    b_2b varchar2(1); b_xe varchar2(1); b_hang varchar2(1); b_phh varchar2(1);
    b_pkt varchar2(1); b_ptn varchar2(1); b_nguoi varchar2(1); b_tau varchar2(1);
    b_hop varchar2(1); b_nong varchar2(1);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,nv,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_nv,b_tu,b_den using b_oraIn;
b_lenh:=FKH_JS_LENH('xm,xe,hang,phh,pkt,ptn,nguoi,tau,hop,nong');
EXECUTE IMMEDIATE b_lenh into b_2b,b_xe,b_hang,b_phh,b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong using b_nv;
b_nv:=trim(FBH_MA_NV_DUNG(b_2b,b_xe,b_hang,b_phh,b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong));
if b_tim is null then
    select count(*) into b_dong from bh_ma_dkbs t where ( b_nv is null or exists ( 
           select 1 from ( select trim(regexp_substr(b_nv, '[^,]+', 1, level)) t1 from dual
                connect by regexp_substr(b_nv, '[^,]+', 1, level) is not null
            ) where t1 is not null and instr(',' || upper(t.nv) || ',', ',' || upper(t1) || ',') > 0));
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
        (select  ma,ten,nsd,rownum sott from bh_ma_dkbs t where ( b_nv is null or exists ( 
           select 1 from ( select trim(regexp_substr(b_nv, '[^,]+', 1, level)) t1 from dual
                connect by regexp_substr(b_nv, '[^,]+', 1, level) is not null
            ) where t1 is not null and instr(',' || upper(t.nv) || ',', ',' || upper(t1) || ',') > 0)) order by ma)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_dkbs t where ( b_nv is null or exists ( 
           select 1 from ( select trim(regexp_substr(b_nv, '[^,]+', 1, level)) t1 from dual
                connect by regexp_substr(b_nv, '[^,]+', 1, level) is not null
            ) where t1 is not null and instr(',' || upper(t.nv) || ',', ',' || upper(t1) || ',') > 0)) and upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
        (select ma,ten,nsd,rownum sott from bh_ma_dkbs t where ( b_nv is null or exists ( 
           select 1 from ( select trim(regexp_substr(b_nv, '[^,]+', 1, level)) t1 from dual
                connect by regexp_substr(b_nv, '[^,]+', 1, level) is not null
            ) where t1 is not null and instr(',' || upper(t.nv) || ',', ',' || upper(t1) || ',') > 0)) and upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_DKLT_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob; b_nv varchar2(1000);
    b_2b varchar2(1); b_xe varchar2(1); b_hang varchar2(1); b_phh varchar2(1);
    b_pkt varchar2(1); b_ptn varchar2(1); b_nguoi varchar2(1); b_tau varchar2(1);
    b_hop varchar2(1); b_nong varchar2(1);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,nv,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_nv,b_tu,b_den using b_oraIn;
b_lenh:=FKH_JS_LENH('xm,xe,hang,phh,pkt,ptn,nguoi,tau,hop,nong');
EXECUTE IMMEDIATE b_lenh into b_2b,b_xe,b_hang,b_phh,b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong using b_nv;
b_nv:=trim(FBH_MA_NV_DUNG(b_2b,b_xe,b_hang,b_phh,b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong));
if b_tim is null then
    select count(*) into b_dong from bh_ma_dklt t where ( b_nv is null or exists ( 
           select 1 from ( select trim(regexp_substr(b_nv, '[^,]+', 1, level)) t1 from dual
                connect by regexp_substr(b_nv, '[^,]+', 1, level) is not null
            ) where t1 is not null and instr(',' || upper(t.nv) || ',', ',' || upper(t1) || ',') > 0));
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma_dk,ma,ten,nsd,'xep' value decode(ma,' ',ma_dk,'--'||ma)) returning clob) into cs_lke
        from (select  t.*,rownum sott from bh_ma_dklt t where ( b_nv is null or exists (
           select 1 from ( select trim(regexp_substr(b_nv, '[^,]+', 1, level)) t1 from dual
                connect by regexp_substr(b_nv, '[^,]+', 1, level) is not null
            ) where t1 is not null and instr(',' || upper(t.nv) || ',', ',' || upper(t1) || ',') > 0))
        order by ma_dk,ma)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_dklt t where upper(ten) like b_tim and ( b_nv is null or exists ( 
           select 1 from ( select trim(regexp_substr(b_nv, '[^,]+', 1, level)) t1 from dual
                connect by regexp_substr(b_nv, '[^,]+', 1, level) is not null
            ) where t1 is not null and instr(',' || upper(t.nv) || ',', ',' || upper(t1) || ',') > 0));
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma_dk,ma,ten,nsd,'xep' value ma||'<'||ma_dk) returning clob) into cs_lke from
        (select t.*,rownum sott from bh_ma_dklt t where ma<>' ' and upper(ten) like b_tim and ( b_nv is null or exists ( 
           select 1 from ( select trim(regexp_substr(b_nv, '[^,]+', 1, level)) t1 from dual
                connect by regexp_substr(b_nv, '[^,]+', 1, level) is not null
            ) where t1 is not null and instr(',' || upper(t.nv) || ',', ',' || upper(t1) || ',') > 0)) order by ma_dk,ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGDL_TIM_IMP(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_id number;  b_so_idC number; b_so_hd_c varchar2(40); b_so_hd varchar2(40);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number;
    b_ten nvarchar2(200); b_phong varchar2(10); b_nv varchar2(1);
    b_tu number; b_den number;
begin
-- Duc tim kiem so_hd chuyen doi
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,so_hd_c,tu,den,nv');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_so_hd_c,b_tu,b_den,b_nv using b_oraIn;
b_so_hd_c:=nvl(trim(b_so_hd_c),' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if trim(b_so_hd_c) is not null then
  insert into temp_1(n1) select so_id from bh_hd_map where ma_dvi = b_ma_dvi and so_hd_c = b_so_hd_c;
  for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
    b_so_idC:=FBH_NGDL_SO_IDc(b_ma_dvi,r_lp.so_id_d);
    insert into ket_qua(c1,c2,c3,n1,n2,n3,n4,c4)
    select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.nv
    from bh_hd_map t
      join bh_ngdl t1 on t.so_id = t1.so_id
      join bh_ngdl_ds t2 on t.so_id = t2.so_id
    where t.so_id = b_so_idC and t1.nv = b_nv and t.so_hd_c = b_so_hd_c and t1.ngay_ht between b_ngayD and b_ngayC;
  end loop;
else
  -- lay all theo dieu kien
  insert into ket_qua(c1,c2,c3,n1,n2,n3,n4,c4)
  select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.nv
    from bh_hd_map t
         join bh_ngdl t1 on t.so_id = t1.so_id
         join bh_ngdl_ds t2 on t.so_id = t2.so_id
   where t.ma_dvi = b_ma_dvi
     and t1.nv = b_nv
     and t1.ngay_ht between b_ngayD and b_ngayC;
end if;
select JSON_ARRAYAGG(json_object('ma_dvi' value b_ma_dvi,'so_hd' value c1,'so_hd_c' value c2,'gcn' value c3,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'so_id' value n4,'nv' value c4) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n3 desc, n4 desc) as sott from ket_qua t
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SK_TIM_IMP(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_id number;  b_so_idC number; b_so_hd_c varchar2(40); b_so_hd varchar2(40);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number;
    b_ten nvarchar2(200); b_phong varchar2(10); b_nv varchar2(1);
    b_tu number; b_den number;
begin
-- Duc tim kiem so_hd chuyen doi
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,so_hd_c,tu,den,nv');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_so_hd_c,b_tu,b_den,b_nv using b_oraIn;
b_so_hd_c:=nvl(trim(b_so_hd_c),' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if trim(b_so_hd_c) is not null then
  insert into temp_1(n1) select so_id from bh_hd_map where ma_dvi = b_ma_dvi and so_hd_c = b_so_hd_c;
  for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
    b_so_idC:=FBH_SK_SO_IDc(b_ma_dvi,r_lp.so_id_d);
    insert into ket_qua(c1,c2,c3,n1,n2,n3,n4,c4)
    select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.nv
    from bh_hd_map t
      join bh_sk t1 on t.so_id = t1.so_id
      join bh_sk_ds t2 on t.so_id = t2.so_id
    where t.so_id = b_so_idC and t1.nv = b_nv and t.so_hd_c = b_so_hd_c and t1.ngay_ht between b_ngayD and b_ngayC;
  end loop;
else
  -- lay all theo dieu kien
  insert into ket_qua(c1,c2,c3,n1,n2,n3,n4,c4)
  select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.nv
    from bh_hd_map t
         join bh_sk t1 on t.so_id = t1.so_id
         join bh_sk_ds t2 on t.so_id = t2.so_id
   where t.ma_dvi = b_ma_dvi
     and t1.nv = b_nv
     and t1.ngay_ht between b_ngayD and b_ngayC;
end if;
select JSON_ARRAYAGG(json_object('ma_dvi' value b_ma_dvi,'so_hd' value c1,'so_hd_c' value c2,'gcn' value c3,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'so_id' value n4,'nv' value c4) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n3 desc, n4 desc) as sott from ket_qua t
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGTD_TIM_IMP(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_id number;  b_so_idC number; b_so_hd_c varchar2(40); b_so_hd varchar2(40);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number;
    b_ten nvarchar2(200); b_phong varchar2(10); b_nv varchar2(1);
    b_tu number; b_den number;
begin
-- Duc tim kiem so_hd chuyen doi
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,so_hd_c,tu,den,nv');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_so_hd_c,b_tu,b_den,b_nv using b_oraIn;
b_so_hd_c:=nvl(trim(b_so_hd_c),' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if trim(b_so_hd_c) is not null then
  insert into temp_1(n1) select so_id from bh_hd_map where ma_dvi = b_ma_dvi and so_hd_c = b_so_hd_c;
  for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
    b_so_idC:=FBH_NGTD_SO_IDc(b_ma_dvi,r_lp.so_id_d);
    insert into ket_qua(c1,c2,c3,n1,n2,n3,n4,c4)
    select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.nv
    from bh_hd_map t
      join bh_ngtd t1 on t.so_id = t1.so_id
      join bh_ngtd_ds t2 on t.so_id = t2.so_id
    where t.so_id = b_so_idC and t1.nv = b_nv and t.so_hd_c = b_so_hd_c and t1.ngay_ht between b_ngayD and b_ngayC;
  end loop;
else
  -- lay all theo dieu kien
  insert into ket_qua(c1,c2,c3,n1,n2,n3,n4,c4)
  select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.nv
    from bh_hd_map t
         join bh_ngtd t1 on t.so_id = t1.so_id
         join bh_ngtd_ds t2 on t.so_id = t2.so_id
   where t.ma_dvi = b_ma_dvi
     and t1.nv = b_nv
     and t1.ngay_ht between b_ngayD and b_ngayC;
end if;
select JSON_ARRAYAGG(json_object('ma_dvi' value b_ma_dvi,'so_hd' value c1,'so_hd_c' value c2,'gcn' value c3,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'so_id' value n4,'nv' value c4) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n3 desc, n4 desc) as sott from ket_qua t
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NGDLN_TIM_IMP(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_id number;  b_so_idC number; b_so_hd_c varchar2(40); b_so_hd varchar2(40);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number;
    b_ten nvarchar2(200); b_phong varchar2(10); b_nv varchar2(1);
    b_tu number; b_den number;
begin
-- Duc tim kiem so_hd chuyen doi
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,so_hd_c,tu,den,nv');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_so_hd_c,b_tu,b_den,b_nv using b_oraIn;
b_so_hd_c:=nvl(trim(b_so_hd_c),' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if trim(b_so_hd_c) is not null then
  insert into temp_1(n1) select so_id from bh_hd_map where ma_dvi = b_ma_dvi and so_hd_c = b_so_hd_c;
  for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
    b_so_idC:=FBH_NGDLN_SO_IDc(b_ma_dvi,r_lp.so_id_d);
    insert into ket_qua(c1,c2,n1,n2,n3,n4,c4)
    select t1.so_hd,t.so_hd_c,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.nv
    from bh_hd_map t
      join bh_ngdlN t1 on t.so_id = t1.so_id
    where t.so_id = b_so_idC and t1.nv = b_nv and t.so_hd_c = b_so_hd_c and t1.ngay_ht between b_ngayD and b_ngayC;
  end loop;
else
  -- lay all theo dieu kien
  insert into ket_qua(c1,c2,n1,n2,n3,n4,c4)
  select t1.so_hd,t.so_hd_c,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.nv
    from bh_hd_map t
         join bh_ngdlN t1 on t.so_id = t1.so_id
   where t.ma_dvi = b_ma_dvi
     and t1.nv = b_nv
     and t1.ngay_ht between b_ngayD and b_ngayC;
end if;
select JSON_ARRAYAGG(json_object('ma_dvi' value b_ma_dvi,'so_hd' value c1,'so_hd_c' value c2,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'so_id' value n4,'nv' value c4) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n3 desc, n4 desc) as sott from ket_qua t
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SKN_TIM_IMP(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_id number;  b_so_idC number; b_so_hd_c varchar2(40); b_so_hd varchar2(40);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number;
    b_ten nvarchar2(200); b_phong varchar2(10); b_nv varchar2(1);
    b_tu number; b_den number;
begin
-- Duc tim kiem so_hd chuyen doi
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,so_hd_c,tu,den,nv');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_so_hd_c,b_tu,b_den,b_nv using b_oraIn;
b_so_hd_c:=nvl(trim(b_so_hd_c),' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if trim(b_so_hd_c) is not null then
  insert into temp_1(n1) select so_id from bh_hd_map where ma_dvi = b_ma_dvi and so_hd_c = b_so_hd_c;
  for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
    b_so_idC:=FBH_SKN_SO_IDc(b_ma_dvi,r_lp.so_id_d);
    insert into ket_qua(c1,c2,n1,n2,n3,n4,c4)
    select t1.so_hd,t.so_hd_c,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.nv
    from bh_hd_map t
      join bh_skN t1 on t.so_id = t1.so_id
    where t.so_id = b_so_idC and t1.nv = b_nv and t.so_hd_c = b_so_hd_c and t1.ngay_ht between b_ngayD and b_ngayC;
  end loop;
else
  -- lay all theo dieu kien
  insert into ket_qua(c1,c2,n1,n2,n3,n4,c4)
  select t1.so_hd,t.so_hd_c,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id,t1.nv
    from bh_hd_map t
         join bh_skN t1 on t.so_id = t1.so_id
   where t.ma_dvi = b_ma_dvi
     and t1.nv = b_nv
     and t1.ngay_ht between b_ngayD and b_ngayC;
end if;
select JSON_ARRAYAGG(json_object('ma_dvi' value b_ma_dvi,'so_hd' value c1,'so_hd_c' value c2,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'so_id' value n4,'nv' value c4) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n3 desc, n4 desc) as sott from ket_qua t
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;

