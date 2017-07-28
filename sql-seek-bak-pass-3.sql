-- Чутливість по відділеннях і по штамах по діску AMC_ND20
SELECT ward, group_org , CASEWHEN(all_AMC_ND20 >0, CEIL(ok_AMC_ND20*1000/all_AMC_ND20)/10,0) okproc_AMC_ND20 /*, x.* */
FROM (
SELECT ward, group_org , COUNT(group_org) petri , SUM(s_AMC_ND20) ok_AMC_ND20 , SUM(a_AMC_ND20) all_AMC_ND20 /*, x.* */
FROM (
SELECT ward, CASEWHEN(x.org IS NULL, 'ani',x.org) group_org, amc_nd20
, CASEWHEN(AMC_ND20>s,1,0) s_AMC_ND20 , CASEWHEN(s IS NULL,0,1) a_AMC_ND20 , organism , x.*
FROM (SELECT * FROM surgery17_1 WHERE AMC_ND20 IS NOT NULL) s LEFT JOIN  (
SELECT roo.org org_in_rs, r.* FROM rs r, rs_org_org roo WHERE roo.rs_org=r.org AND code='AMC_ND20'
) x ON organism=org_in_rs
) x GROUP BY ward, group_org) x ORDER BY ward, petri DESC

-- Всі випадки по діску AMC_ND20. ani = (analize null info) проаналізувати неможливо
SELECT ward, CASEWHEN(x.org is null, 'ani',x.org) group_org, amc_nd20
, CASEWHEN(AMC_ND20>s,1,0) s_AMC_ND20 , CASEWHEN(s is null,0,1) a_AMC_ND20 , organism , x.* 
FROM (SELECT * FROM surgery17_1 WHERE AMC_ND20 IS NOT NULL) s LEFT JOIN  (
SELECT roo.org org_in_rs, r.* FROM rs r, rs_org_org roo WHERE roo.rs_org=r.org AND code='AMC_ND20'
) x ON organism=org_in_rs

-- Кількість по відділення і по штамам
SELECT x.*,ro.name FROM (
SELECT x.*, cnt_ward FROM (
SELECT ward, group_org, count(group_org) cnt_group_org FROM (
SELECT casewhen(rs_org IS NULL,s.organism,rs_org) group_org, s.organism ogm, s.* FROM surgery17_1 s 
LEFT JOIN (SELECT rs_org, ol.* FROM rs_org_org roo,ORGLIST ol, (SELECT  MIN(id) mid FROM ORGLIST ol GROUP BY org) x
 WHERE ol.org=roo.org and x.mid=ol.id) x ON x.org=s.organism 
) GROUP BY ward, group_org
) x, (SELECT WARD, COUNT(WARD) cnt_WARD FROM surgery17_1 GROUP BY WARD) y
WHERE x.ward=y.ward
) x  LEFT JOIN rs_org ro ON rs_org=group_org
ORDER BY cnt_ward DESC, cnt_group_org DESC

SELECT x.*,ro.name FROM (
SELECT x.*, cnt_ward FROM (
SELECT ward, group_org, count(group_org) cnt_group_org FROM (
SELECT x.ward, group_org FROM (
SELECT casewhen(rs_org IS NULL,s.organism,rs_org) group_org, s.organism ogm, s.* FROM surgery17_1 s 
LEFT JOIN (SELECT rs_org, ol.* FROM rs_org_org roo,ORGLIST ol, (SELECT  MIN(id) mid FROM ORGLIST ol GROUP BY org) x
WHERE ol.org=roo.org and x.mid=ol.id) x ON x.org=s.organism 
) x
) GROUP BY ward, group_org
) x, (SELECT WARD, COUNT(WARD) cnt_WARD FROM surgery17_1 GROUP BY WARD) y
WHERE x.ward=y.ward
) x  LEFT JOIN rs_org ro ON rs_org=group_org
ORDER BY cnt_ward DESC, cnt_group_org DESC


-- Кількість проб по віддіденням
SELECT WARD, count(WARD) cnt_WARD FROM surgery17_1 GROUP BY WARD

-- Кількість проб по штамам
SELECT * FROM (
SELECT g_org, count(g_org) cnt_g_org FROM (
SELECT casewhen(rs_org IS NULL,s.organism,rs_org) g_org, s.organism ogm, s.* FROM surgery17_1 s 
LEFT JOIN (SELECT rs_org, ol.* FROM rs_org_org roo,ORGLIST ol, (SELECT  MIN(id) mid FROM ORGLIST ol GROUP BY org) x
 WHERE ol.org=roo.org and x.mid=ol.id) x ON x.org=s.organism 
) GROUP BY g_org
) x LEFT JOIN rs_org ON rs_org=g_org


-- all normal probe
SELECT * FROM (
SELECT * FROM surgery17_1 s, ORGLIST ol, (SELECT  MIN(id) mid FROM ORGLIST ol GROUP BY org) x 
WHERE x.mid=ol.id and s.organism=ol.org
) x 
WHERE NOT(gram='f' OR COMMENT_aberration)

-- all probe
SELECT ol.* FROM surgery17_1 s, ORGLIST ol, (SELECT  min(id) mid FROM ORGLIST ol GROUP BY org) x 
WHERE x.mid=ol.id and s.organism=ol.org

-- unique orglist
SELECT * FROM ORGLIST ol, (SELECT  min(id) mid FROM ORGLIST ol GROUP BY org) x WHERE x.mid=ol.id

-- Ертапенем 
SELECT casewhen(length(ert_chut)<=2,1,0) ert_chut_notchut, x.* FROM (
SELECT REGEXP_REPLACE(REGEXP_REPLACE(s.COMMENT,'Ертапенем +',''),' +чутл.','') ert_chut, 
s.COMMENT cmt1, s.* FROM surgery17_1 s where COMMENT like 'Ерта%'
) x

-- Гриби
SELECT * FROM (
SELECT ol.* FROM surgery17_1 s, ORGLIST ol, (SELECT  MIN(id) mid FROM ORGLIST ol GROUP BY org) x 
WHERE x.mid=ol.id and s.organism=ol.org
) x WHERE gram='f'

