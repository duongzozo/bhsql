CREATE OR REPLACE PROCEDURE BC_BH_CHI_HHONG_KDBH_GOC
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngayd number,b_ngayc number,b_ma_dvi_ct varchar2,b_phong varchar2, b_ma_dt varchar2,
    cs_kq out pht_type.cs_type)
AS
    b_loi varchar2(100);b_ngaydn number;b_ma_dvi_m varchar2(20);b_ten_dvi varchar2(100);
Begin
-- Hiep Bao cao doanh thu bao hiem goc co giam phi, hoan phi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;

if b_ma_dvi_ct='00' then b_ma_dvi_m:='0'; else b_ma_dvi_m:=b_ma_dvi_ct; end if;
if b_ngayd is null or b_ngayc is null then b_loi:='loi:Nhap ngay bao cao:loi'; raise PROGRAM_ERROR;end if;
b_ngaydn:=round(b_ngayc,-4)+101;
b_loi:='loi:Ma chua dang ky:loi';
if b_ma_dvi is not null then select ten into b_ten_dvi from ht_ma_dvi where ma=b_ma_dvi;end if;
delete temp_1;delete temp_2;delete temp_3;delete ket_qua;commit;
---------------------------------------------------------------------------------------------------------------------------
--Ky truoc chuyen sang
------- GOC----------------------------------------------------------------------------------------------------------------
-- nga d?i l?i tai kho?n 62412 sang tai khoan 62414 theo yeu cau cua MIC
if b_ma_dvi_m='0' then 
    insert into temp_1(c3,n1) select lh_nv,sum(hhong_qd) from bh_hd_goc_hh_pt where 
        (ma_dvi,so_id_hh) in (select ma_dvi,so_id_hh from bh_hd_goc_hh where 
                          (ma_dvi,so_id_kt) in (select ma_dvi,so_id from kt_3 where 
                ma_tk_no like '62414%'  and (ngay_ht between b_ngaydn and b_ngayd-1))
                         )
        group by lh_nv;
       
-- Hoan phi doi lai hoa hong
    insert into temp_1(c3,n1) select lh_nv,sum(hhong_qd) from bh_hd_goc_hh_pt where 
        (ma_dvi,so_id_hh) in (select ma_dvi,so_id_hh from bh_hd_goc_hh where 
                           (ma_dvi,so_id_kt) in (select ma_dvi,so_id from kt_3 where 
                                 ma_tk_co like '62414%' and (ngay_ht between b_ngaydn and b_ngayd-1)
                                 )
                         )
        group by lh_nv;

--DONG BAO HIEM
-- Thu hoa hong: Follow: Phai tra hoa hong
--sum(FTT_VND_QD(ps.ma_dvi,ps.ngay_ht,ps.ma_nt,ps.dl))=sum(ct.dl_qd)

    insert into temp_1(c3,n1) Select ps.lh_nv, (Select sum(ct.tien_qd) from bh_hd_do_ct ct where ct.loai=ps.loai and ct.nv='T'
       and ct.so_id=ps.so_id and ct.so_id_ps=ps.so_id_ps and ct.loai like 'CH_LE_DL')
       from bh_hd_do_ps ps where 
       ps.so_id_ps in (Select a.so_id_ps from bh_hd_do_ct a where (ma_dvi,so_id_tt) in  (select ma_dvi,so_id_tt from bh_hd_do_tt where
       (ma_dvi,so_id_kt) in (Select ma_dvi,so_id from kt_3 where ma_tk_no like '62414%' and (ngay_ht between b_ngaydn and b_ngayd-1))));
/*
insert into temp_1(c3,n1)
select ps.lh_nv,sum(ct.tien_qd) from bh_hd_do_ct ct,bh_hd_do_ps ps where ct.so_id_ps=ps.so_id_ps
       and ct.nv='T' and ct.so_id=ps.so_id and (b_ma_dvi_m is null or ct.ma_dvi=b_ma_dvi_m) and ct.so_id_tt in (select so_id_tt from bh_hd_do_tt
                            where (b_ma_dvi_m is null or ma_dvi=b_ma_dvi_m)
                            and so_id_kt in (select so_id from kt_3
                                             where (b_ma_dvi_m is null or ma_dvi=b_ma_dvi_m) and ma_tk_no like '62412%'
                                             and (ngay_ht between b_ngaydn and b_ngayd-1)))
        group by lh_nv;

*/
-- Chi hoa hong: Leader: Doi duoc hoa hong
-- Hach toan dung: C624

    insert into temp_1(c3,n1) select ps.lh_nv,-sum(ct.tien_qd) from bh_hd_do_ct ct,bh_hd_do_ps ps where ct.so_id_ps=ps.so_id_ps
       and ct.nv='T' and ct.loai like 'CH_LE_DL' and ct.so_id=ps.so_id and ct.so_id_tt in (select so_id_tt from bh_hd_do_tt
                            where (ma_dvi,so_id_kt) in (select ma_dvi,so_id from kt_3
                                             where ma_tk_co like '62414%'
                                             and (ngay_ht between b_ngaydn and b_ngayd-1)))
        group by lh_nv;
-- Hach toan chuyen ve dao dau: N624
    insert into temp_1(c3,n1) select lh_nv,-sum(tien_qd) from (select distinct ps.lh_nv,ct.* from bh_hd_do_ct ct,bh_hd_do_ps ps where ct.so_id_ps=ps.so_id_ps
       and ct.nv='C' and ct.loai like 'CH_LE_DL' and ct.so_id=ps.so_id and ct.so_id_tt in (select so_id_tt from bh_hd_do_tt
                            where (ma_dvi,so_id_kt) in (select ma_dvi,so_id from kt_3
                                             where ma_tk_no like '62414%' and tien<0
                                             and (ngay_ht between b_ngaydn and b_ngayd-1))))
        group by lh_nv;


---------------------------------------------------------------------------------------------------------------------------
--Phat sinh trong ky
------- GOC----------------------------------------------------------------------------------------------------------------
    insert into temp_1(c3,n2) select lh_nv,sum(hhong_qd) from bh_hd_goc_hh_pt where 
        so_id_hh in (select so_id_hh from bh_hd_goc_hh
                            where (ma_dvi,so_id_kt) in (select ma_dvi,so_id from kt_3 where ma_tk_no like '62414%'
                                              and (ngay_ht between b_ngayd and b_ngayc)
                                             )
                         )
        group by lh_nv;
-- Hoan phi doi lai hoa hong
    insert into temp_1(c3,n2) select lh_nv,sum(hhong_qd) from bh_hd_goc_hh_pt where
        so_id_hh in (select so_id_hh from bh_hd_goc_hh
                            where (ma_dvi,so_id_kt) in (select ma_dvi,so_id from kt_3 where ma_tk_co like '62414%'
                                              and (ngay_ht between b_ngayd and b_ngayc)
                                             )
                         )
        group by lh_nv;
--Dong bao hiem
-- Thu hoa hong: Follow: Phai tra hoa hong
    insert into temp_1(c3,n2) select ps.lh_nv,sum(ct.tien_qd) from bh_hd_do_ct ct,bh_hd_do_ps ps where ct.so_id_ps=ps.so_id_ps and ct.loai=ps.loai
       and ct.nv='C' and ct.loai like 'CH_LE_DL' and ct.so_id=ps.so_id and ct.so_id_tt in (select so_id_tt from bh_hd_do_tt
                            where (ma_dvi,so_id_kt) in (select ma_dvi,so_id from kt_3
                                             where ma_tk_no like '62414%'
                                             and (ngay_ht between b_ngayd and b_ngayc)))
        group by lh_nv;
-- Chi hoa hong: Leader: Doi duoc hoa hong
-- Hach toan dung: C624
    insert into temp_1(c3,n2) select ps.lh_nv,-sum(ct.tien_qd) from bh_hd_do_ct ct,bh_hd_do_ps ps where ct.so_id_ps=ps.so_id_ps and ct.loai=ps.loai
       and ct.nv='T' and ct.loai like 'CH_LE_DL' and ct.so_id=ps.so_id and ct.so_id_tt in (select so_id_tt from bh_hd_do_tt
                            where (ma_dvi,so_id_kt) in (select ma_dvi,so_id from kt_3
                                             where ma_tk_co like '62414%'
                                             and (ngay_ht between b_ngayd and b_ngayc)))
        group by lh_nv;
-- Hach toan nguoc: N624 dao dau gia tri tien
    insert into temp_1(c3,n2) select lh_nv,-sum(tien_qd) from (select distinct ps.lh_nv,ct.* from bh_hd_do_ct ct,bh_hd_do_ps ps where ct.so_id_ps=ps.so_id_ps
       and ct.loai=ps.loai and ct.nv='C' and ct.loai like 'CH_LE_DL' and ct.so_id=ps.so_id and ct.so_id_tt in (select so_id_tt from bh_hd_do_tt
                            where (ma_dvi,so_id_kt) in (select ma_dvi,so_id from kt_3
                                  where ma_tk_no like '62414%' and tien<0
                                  and (ngay_ht between b_ngayd and b_ngayc))))
        group by lh_nv;
---------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------------------
--Luy ke Phat sinh
------- GOC----------------------------------------------------------------------------------------------------------------
    insert into temp_1(c3,n3) select lh_nv,sum(hhong_qd) from bh_hd_goc_hh_pt where 
        so_id_hh in (select so_id_hh from bh_hd_goc_hh
                            where (ma_dvi,so_id_kt) in (select ma_dvi,so_id from kt_3 where ma_tk_no like '62414%'
                                              and (ngay_ht between b_ngaydn and b_ngayc)
                                             )
                         )
        group by lh_nv;
-- Hoan phi doi lai hoa hong
    insert into temp_1(c3,n3) select lh_nv,sum(hhong_qd) from bh_hd_goc_hh_pt where 
        so_id_hh in (select so_id_hh from bh_hd_goc_hh
                            where (ma_dvi,so_id_kt) in (select ma_dvi,so_id from kt_3 where ma_tk_co like '62414%'
                                              and (ngay_ht between b_ngaydn and b_ngayc)
                                             )
                         )
        group by lh_nv;
--Dong bao hiem
-- Thu hoa hong: Follow: Phai tra hoa hong
    insert into temp_1(c3,n3) select ps.lh_nv,sum(ct.tien_qd) from bh_hd_do_ct ct,bh_hd_do_ps ps where ct.so_id_ps=ps.so_id_ps and ct.loai=ps.loai
       and ct.nv='C' and ct.loai like 'CH_LE_DL' and ct.so_id=ps.so_id and ct.so_id_tt in (select so_id_tt from bh_hd_do_tt
                            where (ma_dvi,so_id_kt) in (select ma_dvi,so_id from kt_3
                                             where ma_tk_no like '62414%'
                                             and (ngay_ht between b_ngaydn and b_ngayc)))
        group by lh_nv;
-- Chi hoa hong: Leader: Doi duoc hoa hong
-- Hach toan dung: C624
    insert into temp_1(c3,n3) select ps.lh_nv,-sum(ct.tien_qd) from bh_hd_do_ct ct,bh_hd_do_ps ps where ct.so_id_ps=ps.so_id_ps and ct.loai=ps.loai
       and ct.nv='T' and ct.loai like 'CH_LE_DL' and ct.so_id=ps.so_id and ct.so_id_tt in (select so_id_tt from bh_hd_do_tt
                            where (ma_dvi,so_id_kt) in (select ma_dvi,so_id from kt_3
                                             where ma_tk_co like '62414%'
                                             and (ngay_ht between b_ngaydn and b_ngayc)))
        group by lh_nv;
-- Hach toan nguoc: N624 dao dau gia tri tien
    insert into temp_1(c3,n3) select lh_nv,-sum(tien_qd) from (select distinct ps.lh_nv,ct.* from bh_hd_do_ct ct,bh_hd_do_ps ps where ct.so_id_ps=ps.so_id_ps
       and ct.loai=ps.loai and ct.nv='C' and ct.loai like 'CH_LE_DL' and ct.so_id=ps.so_id and ct.so_id_tt in (select so_id_tt from bh_hd_do_tt
                            where (ma_dvi,so_id_kt) in (select ma_dvi,so_id from kt_3
                                             where ma_tk_no like '62414%' and tien<0
                                             and (ngay_ht between b_ngaydn and b_ngayc))))
        group by lh_nv;
---------------------------------------------------------------------------------------------------------------------------

else 
    insert into temp_1(c3,n1) select lh_nv,sum(hhong_qd) from bh_hd_goc_hh_pt where ma_dvi=b_ma_dvi_m
            and so_id_hh in (select so_id_hh from bh_hd_goc_hh where ma_dvi=b_ma_dvi_m
                              and so_id_kt in (select so_id from kt_3 where ma_dvi=b_ma_dvi_m and
                    ma_tk_no like '62414%'  and (ngay_ht between b_ngaydn and b_ngayd-1))
                             )
            group by lh_nv;
    -- Hoan phi doi lai hoa hong
    insert into temp_1(c3,n1) select lh_nv,sum(hhong_qd) from bh_hd_goc_hh_pt where ma_dvi=b_ma_dvi_m
            and so_id_hh in (select so_id_hh from bh_hd_goc_hh where ma_dvi=b_ma_dvi_m
                             and so_id_kt in (select so_id from kt_3 where ma_dvi=b_ma_dvi_m
                              and ma_tk_co like '62414%' and (ngay_ht between b_ngaydn and b_ngayd-1)
                                              )
                             )
            group by lh_nv;

    --DONG BAO HIEM
    -- Thu hoa hong: Follow: Phai tra hoa hong
    --sum(FTT_VND_QD(ps.ma_dvi,ps.ngay_ht,ps.ma_nt,ps.dl))=sum(ct.dl_qd)

    insert into temp_1(c3,n1) Select ps.lh_nv, (Select sum(ct.tien_qd) from bh_hd_do_ct ct where ct.loai=ps.loai and ct.nv='T'
           and ct.so_id=ps.so_id and ct.so_id_ps=ps.so_id_ps and ct.loai like 'CH_LE_DL')
           from bh_hd_do_ps ps where ps.ma_dvi=b_ma_dvi_m
           and ps.so_id_ps in (Select a.so_id_ps from bh_hd_do_ct a where so_id_tt in (select so_id_tt from bh_hd_do_tt where
           so_id_kt in (Select so_id from kt_3 where ma_dvi=b_ma_dvi_m and ma_tk_no like '62414%' and (ngay_ht between b_ngaydn and b_ngayd-1))));
    /*
    insert into temp_1(c3,n1)
    select ps.lh_nv,sum(ct.tien_qd) from bh_hd_do_ct ct,bh_hd_do_ps ps where ct.so_id_ps=ps.so_id_ps
           and ct.nv='T' and ct.so_id=ps.so_id and (b_ma_dvi_m is null or ct.ma_dvi=b_ma_dvi_m) and ct.so_id_tt in (select so_id_tt from bh_hd_do_tt
                                where (b_ma_dvi_m is null or ma_dvi=b_ma_dvi_m)
                                and so_id_kt in (select so_id from kt_3
                                                 where (b_ma_dvi_m is null or ma_dvi=b_ma_dvi_m) and ma_tk_no like '62412%'
                                                 and (ngay_ht between b_ngaydn and b_ngayd-1)))
            group by lh_nv;

    */
    -- Chi hoa hong: Leader: Doi duoc hoa hong
    -- Hach toan dung: C624

    insert into temp_1(c3,n1) select ps.lh_nv,-sum(ct.tien_qd) from bh_hd_do_ct ct,bh_hd_do_ps ps where ct.so_id_ps=ps.so_id_ps
           and ct.nv='T' and ct.loai like 'CH_LE_DL' and ct.so_id=ps.so_id and ct.ma_dvi=b_ma_dvi_m and ct.so_id_tt in (select so_id_tt from bh_hd_do_tt
                                where ma_dvi=b_ma_dvi_m
                                and so_id_kt in (select so_id from kt_3
                                                 where ma_dvi=b_ma_dvi_m and ma_tk_co like '62414%'
                                                 and (ngay_ht between b_ngaydn and b_ngayd-1)))
            group by lh_nv;
    -- Hach toan chuyen ve dao dau: N624
    insert into temp_1(c3,n1) select lh_nv,-sum(tien_qd) from (select distinct ps.lh_nv,ct.* from bh_hd_do_ct ct,bh_hd_do_ps ps where ct.so_id_ps=ps.so_id_ps
           and ct.nv='C' and ct.loai like 'CH_LE_DL' and ct.so_id=ps.so_id and ct.ma_dvi=b_ma_dvi_m and ct.so_id_tt in (select so_id_tt from bh_hd_do_tt
                                where ma_dvi=b_ma_dvi_m
                                and so_id_kt in (select so_id from kt_3
                                                 where ma_dvi=b_ma_dvi_m and ma_tk_no like '62414%' and tien<0
                                                 and (ngay_ht between b_ngaydn and b_ngayd-1))))
            group by lh_nv;


    ---------------------------------------------------------------------------------------------------------------------------
    --Phat sinh trong ky
    ------- GOC----------------------------------------------------------------------------------------------------------------
    insert into temp_1(c3,n2) select lh_nv,sum(hhong_qd) from bh_hd_goc_hh_pt where ma_dvi=b_ma_dvi_m
            and so_id_hh in (select so_id_hh from bh_hd_goc_hh
                                where ma_dvi=b_ma_dvi_m
                                and so_id_kt in (select so_id from kt_3 where ma_dvi=b_ma_dvi_m and ma_tk_no like '62414%'
                                                  and (ngay_ht between b_ngayd and b_ngayc)
                                                 )
                             )
            group by lh_nv;
    -- Hoan phi doi lai hoa hong
    insert into temp_1(c3,n2) select lh_nv,sum(hhong_qd) from bh_hd_goc_hh_pt where ma_dvi=b_ma_dvi_m
            and so_id_hh in (select so_id_hh from bh_hd_goc_hh
                                where ma_dvi=b_ma_dvi_m
                                and so_id_kt in (select so_id from kt_3 where ma_dvi=b_ma_dvi_m and ma_tk_co like '62414%'
                                                  and (ngay_ht between b_ngayd and b_ngayc)
                                                 )
                             )
            group by lh_nv;
    --Dong bao hiem
    -- Thu hoa hong: Follow: Phai tra hoa hong
    insert into temp_1(c3,n2) select ps.lh_nv,sum(ct.tien_qd) from bh_hd_do_ct ct,bh_hd_do_ps ps where ct.so_id_ps=ps.so_id_ps and ct.loai=ps.loai
           and ct.nv='C' and ct.loai like 'CH_LE_DL' and ct.so_id=ps.so_id and ct.ma_dvi=b_ma_dvi_m and ct.so_id_tt in (select so_id_tt from bh_hd_do_tt
                                where ma_dvi=b_ma_dvi_m
                                and so_id_kt in (select so_id from kt_3
                                                 where ma_dvi=b_ma_dvi_m and ma_tk_no like '62414%'
                                                 and (ngay_ht between b_ngayd and b_ngayc)))
            group by lh_nv;
    -- Chi hoa hong: Leader: Doi duoc hoa hong
    -- Hach toan dung: C624
    insert into temp_1(c3,n2) select ps.lh_nv,-sum(ct.tien_qd) from bh_hd_do_ct ct,bh_hd_do_ps ps where ct.so_id_ps=ps.so_id_ps and ct.loai=ps.loai
           and ct.nv='T' and ct.loai like 'CH_LE_DL' and ct.so_id=ps.so_id and ct.ma_dvi=b_ma_dvi_m and ct.so_id_tt in (select so_id_tt from bh_hd_do_tt
                                where ma_dvi=b_ma_dvi_m
                                and so_id_kt in (select so_id from kt_3
                                                 where ma_dvi=b_ma_dvi_m and ma_tk_co like '62414%'
                                                 and (ngay_ht between b_ngayd and b_ngayc)))
            group by lh_nv;
    -- Hach toan nguoc: N624 dao dau gia tri tien
    insert into temp_1(c3,n2) select lh_nv,-sum(tien_qd) from (select distinct ps.lh_nv,ct.* from bh_hd_do_ct ct,bh_hd_do_ps ps where ct.so_id_ps=ps.so_id_ps
           and ct.loai=ps.loai and ct.nv='C' and ct.loai like 'CH_LE_DL' and ct.so_id=ps.so_id and ct.ma_dvi=b_ma_dvi_m and ct.so_id_tt in (select so_id_tt from bh_hd_do_tt
                                where ma_dvi=b_ma_dvi_m
                                and so_id_kt in (select so_id from kt_3
                                                 where ma_dvi=b_ma_dvi_m and ma_tk_no like '62414%' and tien<0
                                                 and (ngay_ht between b_ngayd and b_ngayc))))
            group by lh_nv;
    ---------------------------------------------------------------------------------------------------------------------------


    ---------------------------------------------------------------------------------------------------------------------------
    --Luy ke Phat sinh
    ------- GOC----------------------------------------------------------------------------------------------------------------
    insert into temp_1(c3,n3) select lh_nv,sum(hhong_qd) from bh_hd_goc_hh_pt where ma_dvi=b_ma_dvi_m
            and so_id_hh in (select so_id_hh from bh_hd_goc_hh
                                where ma_dvi=b_ma_dvi_m
                                and so_id_kt in (select so_id from kt_3 where ma_dvi=b_ma_dvi_m and ma_tk_no like '62414%'
                                                  and (ngay_ht between b_ngaydn and b_ngayc)
                                                 )
                             )
            group by lh_nv;
    -- Hoan phi doi lai hoa hong
    insert into temp_1(c3,n3) select lh_nv,sum(hhong_qd) from bh_hd_goc_hh_pt where ma_dvi=b_ma_dvi_m
            and so_id_hh in (select so_id_hh from bh_hd_goc_hh
                                where ma_dvi=b_ma_dvi_m
                                and so_id_kt in (select so_id from kt_3 where ma_dvi=b_ma_dvi_m and ma_tk_co like '62414%'
                                                  and (ngay_ht between b_ngaydn and b_ngayc)
                                                 )
                             )
            group by lh_nv;
    --Dong bao hiem
    -- Thu hoa hong: Follow: Phai tra hoa hong
    insert into temp_1(c3,n3) select ps.lh_nv,sum(ct.tien_qd) from bh_hd_do_ct ct,bh_hd_do_ps ps where ct.so_id_ps=ps.so_id_ps and ct.loai=ps.loai
           and ct.nv='C' and ct.loai like 'CH_LE_DL' and ct.so_id=ps.so_id and ct.ma_dvi=b_ma_dvi_m and ct.so_id_tt in (select so_id_tt from bh_hd_do_tt
                                where ma_dvi=b_ma_dvi_m
                                and so_id_kt in (select so_id from kt_3
                                                 where ma_dvi=b_ma_dvi_m and ma_tk_no like '62414%'
                                                 and (ngay_ht between b_ngaydn and b_ngayc)))
            group by lh_nv;
    -- Chi hoa hong: Leader: Doi duoc hoa hong
    -- Hach toan dung: C624
    insert into temp_1(c3,n3) select ps.lh_nv,-sum(ct.tien_qd) from bh_hd_do_ct ct,bh_hd_do_ps ps where ct.so_id_ps=ps.so_id_ps and ct.loai=ps.loai
           and ct.nv='T' and ct.loai like 'CH_LE_DL' and ct.so_id=ps.so_id and ct.ma_dvi=b_ma_dvi_m and ct.so_id_tt in (select so_id_tt from bh_hd_do_tt
                                where ma_dvi=b_ma_dvi_m
                                and so_id_kt in (select so_id from kt_3
                                                 where ma_dvi=b_ma_dvi_m and ma_tk_co like '62414%'
                                                 and (ngay_ht between b_ngaydn and b_ngayc)))
            group by lh_nv;
    -- Hach toan nguoc: N624 dao dau gia tri tien
    insert into temp_1(c3,n3) select lh_nv,-sum(tien_qd) from (select distinct ps.lh_nv,ct.* from bh_hd_do_ct ct,bh_hd_do_ps ps where ct.so_id_ps=ps.so_id_ps
           and ct.loai=ps.loai and ct.nv='C' and ct.loai like 'CH_LE_DL' and ct.so_id=ps.so_id and ct.ma_dvi=b_ma_dvi_m and ct.so_id_tt in (select so_id_tt from bh_hd_do_tt
                                where ma_dvi=b_ma_dvi_m
                                and so_id_kt in (select so_id from kt_3
                                                 where ma_dvi=b_ma_dvi_m and ma_tk_no like '62414%' and tien<0
                                                 and (ngay_ht between b_ngaydn and b_ngayc))))
            group by lh_nv;
    ---------------------------------------------------------------------------------------------------------------------------
end if;

insert into ket_qua(c3,n1,n2,n3) select c3,sum(n1),sum(n2),sum(n3) from temp_1 group by c3;
--update ket_qua set c1=(select ma from bh_ma_lhnv where ma_dvi=b_ma_dvi and ma=substr(c3,1,2) and tc='T');
--update ket_qua set c2=(select ten from bh_ma_lhnv where ma_dvi=b_ma_dvi and ma=c1);
-- Don ma tong
insert into temp_2(c3,n1,n2,n3) select substr(c3,1,2),sum(n1),sum(n2),sum(n3) from ket_qua group by substr(c3,1,2);
-- Don Tong cong
insert into temp_3(n5,n6,n7) select sum(n1),sum(n2),sum(n3) from ket_qua;
--Lay ma tong dua ra baao cao
insert into ket_qua(c3,n1,n2,n3,n9) select c3,n1,n2,n3,2 from temp_2;
--Updaate so tong cong
update ket_qua set (n5,n6,n7)=(select n5,n6,n7 from temp_3);
update ket_qua set c4=(select ten from bh_ma_lhnv where ma_dvi=b_ma_dvi and ma=c3);
-- Dac thu theo
update ket_qua set n30=1 where c1 like 'XG%';
update ket_qua set n30=2 where c1 like 'CN%';
update ket_qua set n30=3 where c1 like 'HH%';
update ket_qua set n30=4 where c1 like 'TT%';
update ket_qua set n30=5 where c1 like 'HH%';
update ket_qua set n30=6 where c1 like 'TS%';
update ket_qua set n30=7 where c1 like 'HP%';
update ket_qua set n30=8 where c1 like 'TN%';

---------------------------------------------------------------------------------------------------------------------------
open cs_kq for select ' ' ma_tk,' ' ten_tk,nvl(c3,' ') ma_tke,nvl(c4,' ') ten_tke,nvl(n1,0) dk,
     nvl(n2,0) ps,nvl(n3,0) lk_ps,nvl(n4,0) ck,nvl(n5,0) tdk, nvl(n6,0) tps,nvl(n7,0) tlk_ps,nvl(n8,0) tck,nvl(n9,1) nhom
    from ket_qua order by n30,c3;
exception when others then raise_application_error(-20105,b_loi);
end;
/