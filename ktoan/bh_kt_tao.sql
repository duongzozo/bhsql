delete bh_kt_matk;
insert into bh_kt_matk values('110',20250101,'K','CN_KH_KH','131110',' ',' ');        -- Cong no khac khach hang
insert into bh_kt_matk values('110',20250101,'K','CN_KH_DL','131120',' ',' ');        -- Cong no khac dai ly
insert into bh_kt_matk values('110',20250101,'K','CN_KH_BH','338818',' ',' ');        -- Cong no khac nha bao hiem
insert into bh_kt_matk values('110',20250101,'K','CN_KH_TPA','335800',' ',' ');      -- Cong no khac TPA
insert into bh_kt_matk values('110',20250101,'K','CIT','338813',' ',' ');                  -- CIT nha bao hiem
insert into bh_kt_matk values('110',20250101,'K','PIT','338812',' ',' ');                  -- PIT dai ly ca nhan

-- PHI
insert into bh_kt_matk values('110',20250101,'G','DT_PH_BH','511110','333110',' ');				-- Doanh thu phi BH trong ky
insert into bh_kt_matk values('110',20250101,'G','DT_PH_BHl','532100','333110',' ');              -- Giam phi BH trong ky
insert into bh_kt_matk values('110',20250101,'G','DT_PH_BHh','531100','333110',' ');              -- Hoan phi BH trong ky
insert into bh_kt_matk values('110',20250101,'G','DT_PH_TR','338710',' ',' ');                        -- Doanh thu phi BH thu truoc
--
insert into bh_kt_matk values('110',20250101,'G','CN_PH_KH','131110',' ',' ');          -- Cong no phi khach hang
insert into bh_kt_matk values('110',20250101,'G','CN_PH_DL','131120',' ',' ');          -- Cong no phi dai ly
insert into bh_kt_matk values('110',20250101,'G','CN_PH_KHO','CN_PH_KHO',' ',' ');        -- Cong no phi kho doi
-- Tra Follow (AAA lead)
insert into bh_kt_matk values('110',20250101,'D','CN_PHF_BH','331610',' ',' ');                -- Cong no phi dong
insert into bh_kt_matk values('110',20250101,'D','CH_PHF_BHd','331610','333110',' ');	  -- Du chi phi nha dong
insert into bh_kt_matk values('110',20250101,'D','CH_PHF_BH','511110',' ',' ');       -- Chi phi nha dong
insert into bh_kt_matk values('110',20250101,'D','CH_PHF_BHv','333110',' ',' ');       -- VAT phai tra nha Dong
insert into bh_kt_matk values('110',20250101,'T','CN_PHF_BH','CN_PHF_BH',' ',' ');				  -- Cong no phi tai
insert into bh_kt_matk values('110',20250101,'T','CH_PHF_BHd','331310',' ',' ');      -- Du chi phi nha tai
insert into bh_kt_matk values('110',20250101,'T','CH_PHF_BH','533100','CH_PHF_BHv',' ');       -- Chi phi nha tai
--
insert into bh_kt_matk values('110',20250101,'D','DT_FLPd','131140','333110',' ');					-- Du thu Leading phi dong
insert into bh_kt_matk values('110',20250101,'D','DT_FLP','511180',' ',' ');					-- Thu Leading phi dong
insert into bh_kt_matk values('110',20250101,'D','DT_FLPv','333110',' ',' ');					-- VAT Leading phi dong
insert into bh_kt_matk values('110',20250101,'T','DT_FLPd','DT_FLPd',' ',' ');					-- Du thu Leading phi tai
insert into bh_kt_matk values('110',20250101,'T','DT_FLP','DT_FLP',' ',' ');					-- Thu Leading phi tai
-- Thu Lead (AAA follow)
insert into bh_kt_matk values('110',20250101,'D','CN_PHL_BH','131140',' ',' ');              -- Cong no phi dong AAA follow
insert into bh_kt_matk values('110',20250101,'D','DT_PHL_BH','DT_PHL_BH','DT_PHL_BHv',' ');     -- Thu phi nha dong
insert into bh_kt_matk values('110',20250101,'T','CN_PHL_BH','131210',' ',' ');			    -- Cong no phai thu phi tai
insert into bh_kt_matk values('110',20250101,'T','DT_PHL_BH','DT_PHL_BH','DT_PHL_BHv',' ');     -- Thu phi nha tai
--
insert into bh_kt_matk values('110',20250101,'D','CN_LEP','CN_LEP',' ',' ');					-- Cong no phai tra Leading phi dong
insert into bh_kt_matk values('110',20250101,'D','CH_LEPd','624188','133110',' ');					-- Du chi Leading phi dong
insert into bh_kt_matk values('110',20250101,'D','CH_LEP','338818',' ',' ');					-- Chi Leading phi nha dong
insert into bh_kt_matk values('110',20250101,'D','CH_LEH','CH_LFH','CH_LEPv',' ');				-- Chi hoa hong nha dong
insert into bh_kt_matk values('110',20250101,'D','CH_HH_DLd','624140','CN_KH_BH',' ');		-- Du dai ly nha dong chi ho
insert into bh_kt_matk values('110',20250101,'D','CH_HH_DL','331190','CN_KH_BH',' ');		-- Chi dai ly nha dong chi ho
insert into bh_kt_matk values('110',20250101,'T','CN_LEP','CN_LEP',' ',' ');					-- Cong no phai tra Leading phi tai
insert into bh_kt_matk values('110',20250101,'T','CH_LEPd','CH_LEPd','CN_LEP',' ');				-- Du chi Leading phi tai
insert into bh_kt_matk values('110',20250101,'T','CH_LEP','131210','CH_LEPv',' ');				-- Chi Leading phi nha tai
insert into bh_kt_matk values('110',20250101,'T','CN_PHT_BH','131210',' ',' ');        -- Cong no phi nha Tai Lead
-- Hoa hong dai ly
insert into bh_kt_matk values('110',20250101,'G','CN_HH_DL','331122',' ',' ');                -- Cong no hoa hong dai ly
insert into bh_kt_matk values('110',20250101,'G','CH_HH_DLd','33112','CH_HH_DLd',' ');              -- Du chi hoa hong, ho tro, dich vu dai ly
insert into bh_kt_matk values('110',20250101,'G','CH_HH_DLt','624140','CH_HH_DLt',' ');              -- Chi hoa hong dai ly to chuc
insert into bh_kt_matk values('110',20250101,'G','CH_HH_DLc','624140','CH_HH_DLc',' ');              -- Chi hoa hong dai ly ca nhan
insert into bh_kt_matk values('110',20250101,'G','CH_HT_DLt','624179','CH_HT_DLt',' ');              -- Chi ho tro dai ly to chuc
insert into bh_kt_matk values('110',20250101,'G','CH_HT_DLc','624174','CH_HT_DLc',' ');              -- Chi ho tro dai ly ca nhan
insert into bh_kt_matk values('110',20250101,'G','CH_DV_DL','624882','CH_DV_DL',' ');              -- Chi dich vu dai ly
insert into bh_kt_matk values('110',20250101,'G','CH_DV_DLv','CH_DV_DLv',' ',' ');		    -- CIT
insert into bh_kt_matk values('110',20250101,'G','CH_HH_DLv','133110',' ',' ');				-- VAT

--
insert into bh_kt_matk values('110',20250101,'D','CN_HH_DL','331190',' ',' ');                -- Cong no hoa hong d.ly nha dong
insert into bh_kt_matk values('110',20250101,'D','DT_HH_DLd','131190',' ',' ');              -- Du thu h.hong d.ly nha dong
insert into bh_kt_matk values('110',20250101,'D','DT_HH_DL','331160',' ',' ');				-- Thu h.hong d.ly nha dong
-- TPA
insert into bh_kt_matk values('110',20250101,'G','CN_DV_TPA','335800',' ',' ');              -- Cong no dich vu TPA
insert into bh_kt_matk values('110',20250101,'G','CH_DV_TPAd','335800','CH_DV_TPAd',' ');    -- Du chi dich vu TPA
insert into bh_kt_matk values('110',20250101,'G','CH_DV_TPA','624191','133110',' ');     -- Chi dich vu TPA
insert into bh_kt_matk values('110',20250101,'G','CH_DV_TPAv','133110',' ',' ');			-- Thue dvu TPA
--
insert into bh_kt_matk values('110',20250101,'D','CN_DV_TPA','138810',' ',' ');              -- Cong no dich vu TPA nha dong
insert into bh_kt_matk values('110',20250101,'D','DT_DV_TPAd','624191','138810',' ');    -- Du thu dich vu TPA nha dong
insert into bh_kt_matk values('110',20250101,'D','DT_DV_TPA','138810','333110',' ');     -- Thu dich vu TPA nha dong
insert into bh_kt_matk values('110',20250101,'D','DT_DV_TPAv','333110',' ',' ');     -- VAT dich vu TPA nha dong
-- BTH
insert into bh_kt_matk values('110',20250101,'G','CN_BT_KH','331110',' ',' ');				-- Cong no boi thuong khach hang
insert into bh_kt_matk values('110',20250101,'G','CN_BTL_BH','131430',' ',' ');				-- Cong no boi thuong nha Dong Lead
insert into bh_kt_matk values('110',20250101,'G','CN_BT_BH','331210',' ',' ');				-- Cong no boi thuong nha Tai Lead
insert into bh_kt_matk values('110',20250101,'G','CN_BT_HK','331110',' ',' ');				-- Cong no boi thuong huong khac
insert into bh_kt_matk values('110',20250101,'G','CN_BT_TPA','335800',' ',' ');				-- Cong no TPA boi thuong ho
--
insert into bh_kt_matk values('110',20250101,'G','CH_BT_BHd','624110','133120',' ');      -- Du chi boi thuong
insert into bh_kt_matk values('110',20250101,'G','CH_BTL_BHd','3381','133120',' ');      -- Du chi boi thuong Tai Lead
insert into bh_kt_matk values('110',20250101,'G','CH_BT_BH','331110','133120',' ');        -- Chi boi thuong
insert into bh_kt_matk values('110',20250101,'G','CH_BT_BHv','133120',' ',' ');        -- VAT boi thuong
--
insert into bh_kt_matk values('110',20250101,'D','CN_BTF_BH','131430',' ',' ');              -- Cong no phai thu boi thuong dong
insert into bh_kt_matk values('110',20250101,'D','DT_BTF_BHd','131430','133120',' ');    -- Du thu boi thuong nha dong
insert into bh_kt_matk values('110',20250101,'D','DT_BTF_BH','624110','133120',' ');     -- Thu boi thuong nha dong
insert into bh_kt_matk values('110',20250101,'D','DT_BTF_BHv','133120',' ',' ');     -- VAT boi thuong nha dong
insert into bh_kt_matk values('110',20250101,'T','CN_BTF_BH','131310',' ',' ');              -- Cong no phai thu boi thuong tai
insert into bh_kt_matk values('110',20250101,'T','DT_BTF_BHd','131310',' ',' ');    -- Du thu boi thuong nha tai
insert into bh_kt_matk values('110',20250101,'T','DT_BTF_BH','624313','DT_BTF_BHv',' ');        -- Thu boi thuong nha tai
-- GD
insert into bh_kt_matk values('110',20250101,'G','CN_BT_GD','331190',' ',' ');                -- Cong no boi thuong giam dinh
insert into bh_kt_matk values('110',20250101,'G','CH_BT_GDd','624150','133120',' ');              -- Du chi giam dinh
insert into bh_kt_matk values('110',20250101,'G','CH_BT_GD','331190','133120',' ');        -- Chi giam dinh
insert into bh_kt_matk values('110',20250101,'G','CH_BT_GDv','133120',' ',' ');        -- VAT  giam dinh
--
insert into bh_kt_matk values('110',20250101,'D','CN_BTF_GD','131140',' ',' ');                -- Cong no phai thu giam dinh dong
insert into bh_kt_matk values('110',20250101,'D','DT_BTF_GDd','131140',' ',' ');    -- Du thu giam dinh nha dong
insert into bh_kt_matk values('110',20250101,'D','DT_BTF_GD','624150','133120',' ');        -- Thu giam dinh nha dong
insert into bh_kt_matk values('110',20250101,'D','DT_BTF_GDv','133120',' ',' ');        -- VAT giam dinh nha dong
insert into bh_kt_matk values('110',20250101,'T','CN_BTF_GD','131310',' ',' ');                -- Cong no phai thu giam dinh tai
insert into bh_kt_matk values('110',20250101,'T','DT_BTF_GDd','131310',' ',' ');    -- Du thu giam dinh nha tai
insert into bh_kt_matk values('110',20250101,'T','DT_BTF_GD','624313','DT_BTF_GDv',' ');        -- Thu giam dinh nha tai
-- TBA
insert into bh_kt_matk values('110',20250101,'G','DT_BT_TB','511120','333110',' ');        -- Thu doi TBA
--
insert into bh_kt_matk values('110',20250101,'D','CN_BTF_TB','331610',' ',' ');                -- Cong no phai chi NTB dong
insert into bh_kt_matk values('110',20250101,'D','CH_BTF_TBd','511120','331610',' ');    -- Du chi NTB nha dong
insert into bh_kt_matk values('110',20250101,'D','CH_BTF_TB','331610','CH_BTF_TBv',' ');        -- Thu NTB nha dong
insert into bh_kt_matk values('110',20250101,'D','CH_BTF_TBv','133110',' ',' ');        -- VAT Thu NTB nha dong
insert into bh_kt_matk values('110',20250101,'T','CN_BTF_TB','CN_BTF_TB',' ',' ');                -- Cong no phai chi NTB tai
insert into bh_kt_matk values('110',20250101,'T','CH_BTF_TBd','511120','331380',' ');    -- Du chi TBA nha tai
insert into bh_kt_matk values('110',20250101,'T','CH_BTF_TB','331380','CH_BTF_TBv',' ');        -- Chi NTB nha tai
-- THO
insert into bh_kt_matk values('110',20250101,'G','DT_BT_TH','511130','333110',' ');        -- Thu hoi
--
insert into bh_kt_matk values('110',20250101,'D','CN_BTF_TH','331610',' ',' ');              	-- Cong no phai chi THO dong
insert into bh_kt_matk values('110',20250101,'D','CH_BTF_THd','511130','331610',' ');    		-- Du chi THO nha dong
insert into bh_kt_matk values('110',20250101,'D','CH_BTF_TH','331610','CH_BTF_THv',' ');     	-- Thu THO nha dong
insert into bh_kt_matk values('110',20250101,'D','CH_BTF_THv','133110',' ',' ');     	-- Thu THO nha dong
insert into bh_kt_matk values('110',20250101,'T','CN_BTF_TH','CN_BTF_TH',' ',' ');              -- Cong no phai chi THO tai
insert into bh_kt_matk values('110',20250101,'T','CH_BTF_THd','511380','331380',' ');    		-- Du chi THO nha tai
insert into bh_kt_matk values('110',20250101,'T','CH_BTF_TH','331380','CH_BTF_THv',' ');     -- Chi THO nha tai
-- XOL
insert into bh_kt_matk values('110',20250101,'T','CN_PH_XOL','CN_PH_XOL',' ',' ');              -- Cong no phi tai XOL
insert into bh_kt_matk values('110',20250101,'T','CH_PH_XOL','CH_PH_XOL','CH_PH_XOLv',' ');     -- Chi phi tai XOL
insert into bh_kt_matk values('110',20250101,'T','HD_XOLd','331310','CH_PH_XOLv',' ');     -- Chi phi tai XOL
insert into bh_kt_matk values('110',20250101,'T','CN_BT_XOL','CN_BT_XOL',' ',' ');              -- Cong no boi thuong tai XOL
insert into bh_kt_matk values('110',20250101,'T','DT_BT_XOLd','DT_BT_XOLd','CN_BT_XOL',' ');    -- Du thu boi thuong XOL
insert into bh_kt_matk values('110',20250101,'T','DT_BT_XOL','DT_BT_XOL','DT_BT_XOLv',' ');     -- Thu boi thuong XOL

-- Thu, chi khac Hop dong
insert into bh_kt_matk values('110',20250101,'G','KH_HD_CP','KH_HD_CP','KH_HD_CPv',' ');        -- Thu, chi khac hop dong
--
insert into bh_kt_matk values('110',20250101,'D','CN_HD_CPd','KH_HD_CN',' ',' ');               -- Cong no thu, chi khac hop dong dong
insert into bh_kt_matk values('110',20250101,'D','KH_HD_CPd','KH_HD_CPd','KH_HD_CN',' ');       -- Du thu, chi khac hop dong dong
insert into bh_kt_matk values('110',20250101,'D','KH_HD_CP','KH_HD_CP','KH_HD_CPv',' ');        -- Thu, chi khac hop dong dong
insert into bh_kt_matk values('110',20250101,'T','CN_HD_CPd','KH_HD_CN',' ',' ');               -- Cong no thu, chi khac hop dong tai
insert into bh_kt_matk values('110',20250101,'T','KH_HD_CPd','KH_HD_CPd','KH_HD_CN',' ');        -- Du thu, chi khac hop dong tai
insert into bh_kt_matk values('110',20250101,'T','KH_HD_CP','KH_HD_CP','KH_HD_CPv',' ');        -- Thu, chi khac hop dong tai

-- Thu, chi khac tai
insert into bh_kt_matk values('110',20250101,'T','KH_TA_CP','KH_TA_CP','KH_TA_CPv',' ');        -- Thu, chi khac tai
commit;
update bh_kt_matk set ma_dvi = '0800';
commit;