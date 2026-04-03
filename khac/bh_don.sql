create or replace procedure PBH_NG_HDON(b_ma_dvi varchar2,b_ngayd number,b_ngayc number,b_loi out varchar2)
AS
	b_ngay number; b_d1 date; b_d2 date; b_gcn varchar2(50);
begin
-- Dan - Liet ke hoa don da su dung
b_loi:='loi:Loi liet ke HD nguoi:loi';
b_d1:=PKH_SO_CDT(b_ngayd); b_d2:=PKH_SO_CDT(b_ngayc);
--LAM SACH
-- for r_lp in (select ngay_cap,so_id,so_id_g,nsd,phong,so_hd from bh_nguoihd
-- 	where ma_dvi=b_ma_dvi and (ngay_cap between b_d1 and b_d2)) loop
-- 	b_ngay:=PKH_NG_CSO(r_lp.ngay_cap);
-- 	for r_lp1 in (select gcn_m,gcn_c,gcn_s,gcn,so_id_dt from bh_nguoihd_ds
-- 		where ma_dvi=b_ma_dvi and so_id=r_lp.so_id and gcn_s is not null) loop
-- 	    if r_lp1.gcn_s is not null then
-- 		if r_lp.so_id_g<>0 then
-- 			select nvl(min(gcn),' ') into b_gcn from bh_nguoihd_ds
-- 				where ma_dvi=b_ma_dvi and so_id=r_lp.so_id_g and so_id_dt=r_lp1.so_id_dt;
-- 		else	b_gcn:=' ';
-- 		end if;
-- 		if b_gcn<>r_lp1.gcn then
-- 			insert into temp_1(n1,n2,n3,c1,c2,c3,c4,c5,c6,c7,c8) values(b_ngay,r_lp.so_id,r_lp1.so_id_dt,b_ma_dvi,'NG-GCN',
-- 				r_lp1.gcn_m,r_lp1.gcn_c,r_lp1.gcn_s,r_lp.nsd,r_lp.phong,r_lp.so_hd);
-- 		end if;
-- 	    end if;
-- 	end loop;
-- end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;

/
create or replace procedure PBH_2BL_HDON(b_ma_dvi varchar2,b_ngayd number,b_ngayc number,b_loi out varchar2)
AS
	b_ngay number; b_d1 date; b_d2 date; b_gcn varchar2(50);
begin
-- Dan - Liet ke hoa don da su dung
b_loi:='loi:Loi liet ke GCN xe 2 banh le:loi';
b_d1:=PKH_SO_CDT(b_ngayd); b_d2:=PKH_SO_CDT(b_ngayc);

--LAM SACH
-- for r_lp in (select ngay_cap,so_id,so_id_g,gcn_m,gcn_c,gcn_s,nsd,phong,so_hd from bh_2blgcn
-- 	where ma_dvi=b_ma_dvi and (ngay_cap between b_d1 and b_d2)) loop
-- 	b_ngay:=PKH_NG_CSO(r_lp.ngay_cap);
-- 	if r_lp.so_id_g<>0 then
-- 		select nvl(min(so_hd),' ') into b_gcn from bh_2blgcn where ma_dvi=b_ma_dvi and so_id=r_lp.so_id_g;
-- 	else	b_gcn:=' ';
-- 	end if;
-- 	if r_lp.so_hd<>b_gcn then
-- 		insert into temp_1(n1,n2,c1,c2,c3,c4,c5,c6,c7,c8)
-- 			values(b_ngay,r_lp.so_id,b_ma_dvi,'2BL',
-- 			r_lp.gcn_m,r_lp.gcn_c,r_lp.gcn_s,r_lp.nsd,r_lp.phong,r_lp.so_hd);
-- 	end if;
-- end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;

/
create or replace procedure PBH_HD_VAT_HDON
	(b_ma_dvi varchar2,b_ngayd number,b_ngayc number,b_loi out varchar2)
AS
begin
-- Dan - Liet ke hoa don da su dung
b_loi:='loi:Loi liet ke hoa don VAT thanh toan phi:loi';
insert into temp_1(n1,n2,c1,c2,c3,c4,c5,c6,c7)
	select ngay_ht,so_id_vat,b_ma_dvi,'THU_PHI',mau,seri,so_don,nsd,phong from bh_hd_goc_vat
	where ma_dvi=b_ma_dvi and (ngay_ht between b_ngayd and b_ngayc);
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HD_HU
	(b_ma_dvi varchar2,b_ngayd number,b_ngayc number,b_loi out varchar2)
AS
begin
-- Dan - Liet ke hoa don da su dung
b_loi:='loi:Loi liet ke hoa don huy hop dong:loi';
insert into temp_1(n1,n2,c1,c2,c3,c4,c5,c6,c7)
	select ngay_ht,so_id,b_ma_dvi,'HUY',mau,seri,so_don,nsd,phong from bh_hd_goc_hu
	where ma_dvi=b_ma_dvi and (ngay_ht between b_ngayd and b_ngayc) and kvat='P';
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HD_VAT_DOI_HDON
	(b_ma_dvi varchar2,b_ngayd number,b_ngayc number,b_loi out varchar2)
AS
begin
-- Dan - Liet ke doi hoa don
b_loi:='loi:Loi liet ke doi hoa don VAT thanh toan phi:loi';
insert into temp_1(n1,n2,c1,c2,c3,c4,c5,c6,c7)
	select ngay_ht,so_id,b_ma_dvi,'DOI_VAT',mau,seri,so_don,nsd,phong from bh_hd_goc_vat_doi
	where ma_dvi=b_ma_dvi and (ngay_ht between b_ngayd and b_ngayc);
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PTV_HDON
	(b_ma_dvi varchar2,b_ngayd number,b_ngayc number,b_loi out varchar2)
AS
	b_d1 date; b_d2 date; b_i1 number; b_l_ct varchar2(1); b_htoan varchar2(1); b_nsd varchar2(10); b_so_id number;
begin
-- Dan - Liet ke hoa don da su dung tu modul ke toan
b_loi:='loi:Loi liet ke hoa don VAT ke toan:loi';
b_d1:=PKH_SO_CDT(b_ngayd); b_d2:=PKH_SO_CDT(b_ngayc);
for r_lp in (select distinct so_id,ngay_ct,mau,seri,so_hd from tv_2 where ma_dvi=b_ma_dvi and hoan='K'
	and (to_date(ngay_ct,'dd-mm-yyyy') between b_d1 and b_d2)) loop
	b_so_id:=r_lp.so_id;
	select l_ct,htoan,nsd into b_l_ct,b_htoan,b_nsd from tv_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
	if b_l_ct in('R','T') and b_htoan<>'T' then
		b_i1:=PKH_NG_CSO(r_lp.ngay_ct);
		insert into temp_1(n1,n2,c1,c2,c3,c4,c5,c6) values(b_i1,b_so_id,b_ma_dvi,'KTHT',r_lp.mau,r_lp.seri,r_lp.so_hd,b_nsd);
	end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;