-- Шаблон кінцевого select чутливості по штамах. Комбінується з генерованих вставок.
SELECT x.*
, AMC_ND20.okproc_AMC_ND20 AMC_ND20 
FROM (
SELECT * FROM (
SELECT g_org, g_org group_org, COUNT(g_org) cnt_g_org FROM (
SELECT CASEWHEN(rs_org IS NULL,s.organism,rs_org) g_org, s.organism ogm, s.* FROM surgery17_1 s 
LEFT JOIN (SELECT rs_org, ol.* FROM rs_org_org roo,ORGLIST ol, (SELECT  MIN(id) mid FROM ORGLIST ol GROUP BY org) x
WHERE ol.org=roo.org and x.mid=ol.id) x ON x.org=s.organism 
) GROUP BY g_org
) x LEFT JOIN rs_org ON rs_org=g_org
) x
  LEFT JOIN (SELECT  group_org  group_org_AMC_ND20, CASEWHEN(all_AMC_ND20 >0, CEIL(ok_AMC_ND20*1000/all_AMC_ND20)/10,0) okproc_AMC_ND20, petri /*, x.* */FROM (SELECT  group_org , COUNT(group_org) petri , SUM(s_AMC_ND20) ok_AMC_ND20 , SUM(a_AMC_ND20) all_AMC_ND20 /*, x.* */ FROM (SELECT ward, CASEWHEN(x.org IS NULL, '0ai',x.org) group_org, amc_nd20, CASEWHEN(AMC_ND20>s,1,0) s_AMC_ND20, CASEWHEN(s IS NULL,0,1) a_AMC_ND20, organism , x.*FROM (SELECT * FROM surgery17_1 WHERE AMC_ND20 IS NOT NULL) s LEFT JOIN  (SELECT roo.org org_in_rs, r.* FROM rs r, rs_org_org roo WHERE roo.rs_org=r.org AND code='AMC_ND20' ) x ON organism=org_in_rs ) x GROUP BY group_org) x ORDER BY petri DESC ) AMC_ND20 on  x.group_org=AMC_ND20.group_org_AMC_ND20 
ORDER BY cnt_g_org DESC

-- Шаблон кінцевого select чутливості по відділеннях і штамах. Комбінується з генерованих вставок.
SELECT x.*
, CEIL(cnt_group_org*1000/cnt_ward)/10||'%' stamm_procent_for_all
, ro.name 
, AMC_ND20.okproc_AMC_ND20 AMC_ND20 
FROM (
SELECT x.*, cnt_ward FROM (
SELECT ward, group_org, COUNT(group_org) cnt_group_org FROM (
SELECT x.ward, group_org FROM (
SELECT CASEWHEN(rs_org IS NULL,s.organism,rs_org) group_org, s.organism ogm, s.* FROM surgery17_1 s 
LEFT JOIN (SELECT rs_org, ol.* FROM rs_org_org roo,ORGLIST ol, (SELECT MIN(id) mid FROM ORGLIST ol GROUP BY org) x
WHERE ol.org=roo.org and x.mid=ol.id) x ON x.org=s.organism 
) x
) GROUP BY ward, group_org
) x, (SELECT WARD, COUNT(WARD) cnt_WARD FROM surgery17_1 GROUP BY WARD) y
WHERE x.ward=y.ward
) x  LEFT JOIN rs_org ro ON rs_org=group_org
 LEFT JOIN (SELECT ward ward_AMC_ND20, group_org group_org_AMC_ND20 , CASEWHEN(all_AMC_ND20>0, CEIL(ok_AMC_ND20*1000/all_AMC_ND20)/10,0) okproc_AMC_ND20, petri /*, x.* */ FROM (SELECT ward, group_org , COUNT(group_org) petri , SUM(s_AMC_ND20) ok_AMC_ND20, SUM(a_AMC_ND20) all_AMC_ND20 /*, x.* */ FROM ( SELECT ward, CASEWHEN(x.org is null, '0ai',x.org) group_org, amc_nd20, CASEWHEN(AMC_ND20>s,1,0) s_AMC_ND20, CASEWHEN(s is null,0,1) a_AMC_ND20, organism , x.* FROM (SELECT * FROM surgery17_1 WHERE AMC_ND20 IS NOT NULL) s LEFT JOIN  (SELECT roo.org org_in_rs, r.* FROM rs r, rs_org_org roo WHERE roo.rs_org=r.org AND code='AMC_ND20') x ON organism=org_in_rs) x GROUP BY ward, group_org) x ORDER BY ward, petri DESC ) AMC_ND20 on x.ward=AMC_ND20.ward_AMC_ND20 and x.group_org=AMC_ND20.group_org_AMC_ND20 
 LEFT JOIN (SELECT ward ward_VOR_ND1, group_org group_org_VOR_ND1 , CASEWHEN(all_VOR_ND1>0, CEIL(ok_VOR_ND1*1000/all_VOR_ND1)/10,0) okproc_VOR_ND1, petri /*, x.* */ FROM (SELECT ward, group_org , COUNT(group_org) petri , SUM(s_VOR_ND1) ok_VOR_ND1, SUM(a_VOR_ND1) all_VOR_ND1 /*, x.* */ FROM ( SELECT ward, CASEWHEN(x.org is null, '0ai',x.org) group_org, amc_nd20, CASEWHEN(VOR_ND1>s,1,0) s_VOR_ND1, CASEWHEN(s is null,0,1) a_VOR_ND1, organism , x.* FROM (SELECT * FROM surgery17_1 WHERE VOR_ND1 IS NOT NULL) s LEFT JOIN  (SELECT roo.org org_in_rs, r.* FROM rs r, rs_org_org roo WHERE roo.rs_org=r.org AND code='VOR_ND1') x ON organism=org_in_rs) x GROUP BY ward, group_org) x ORDER BY ward, petri DESC ) VOR_ND1 on x.ward=VOR_ND1.ward_VOR_ND1 and x.group_org=VOR_ND1.group_org_VOR_ND1 
ORDER BY cnt_ward DESC, cnt_group_org DESC

-- Генерація select чутливості по відділеннях і по штамах для кожного диска
SELECT x.*
, ', '||code||'.okproc_'||code||' '||code||' ' show_field
, ' LEFT JOIN (' 
|| chutlivist
|| ') '||code||' on x.ward='||code||'.ward_'||code||' and x.group_org='||code||'.group_org_'||code||' ' left_join
, ' LEFT JOIN (' 
|| chutlivist_stamm
|| ') '||code||' on  x.group_org='||code||'.group_org_'||code||' ' left_join_stamm
  FROM (
SELECT x.* 
,'SELECT ward ward_'||code||', group_org group_org_'||code||' , CASEWHEN(all_'||code||'>0, CEIL(ok_'||code||'*1000/all_'||code||')/10,0) okproc_'||code||', petri /*, x.* */ '
||'FROM ('
||'SELECT ward, group_org , COUNT(group_org) petri , SUM(s_'||code||') ok_'||code||', SUM(a_'||code||') all_'||code||' /*, x.* */ '
||'FROM ( '
||x.all
||') x GROUP BY ward, group_org) x ORDER BY ward, petri DESC ' chutlivist
, 'SELECT  group_org  group_org_'||code||', CASEWHEN(all_'||code||' >0, CEIL(ok_'||code||'*1000/all_'||code||')/10,0) okproc_'||code||', petri /*, x.* */'
||'FROM ('
||'SELECT  group_org , COUNT(group_org) petri , SUM(s_'||code||') ok_'||code||' , SUM(a_'||code||') all_'||code||' /*, x.* */ '
||'FROM ('
||'SELECT ward, CASEWHEN(x.org IS NULL, ''0ai'',x.org) group_org, amc_nd20'
||', CASEWHEN('||code||'>s,1,0) s_'||code||', CASEWHEN(s IS NULL,0,1) a_'||code||', organism , x.*'
||'FROM (SELECT * FROM surgery17_1 WHERE '||code||' IS NOT NULL) s LEFT JOIN  ('
||'SELECT roo.org org_in_rs, r.* FROM rs r, rs_org_org roo WHERE roo.rs_org=r.org AND code='''||code||''' '
||') x ON organism=org_in_rs '
||') x GROUP BY group_org) x ORDER BY petri DESC ' chutlivist_stamm
FROM (
SELECT DISTINCT code
,'SELECT ward, CASEWHEN(x.org is null, ''ani'',x.org) group_org, amc_nd20'
||', CASEWHEN('||code||'>s,1,0) s_'||code||', CASEWHEN(s is null,0,1) a_'||code||', organism , x.* '
||'FROM (SELECT * FROM surgery17_1 WHERE '||code||' IS NOT NULL) s LEFT JOIN  ('
||'SELECT roo.org org_in_rs, r.* FROM rs r, rs_org_org roo WHERE roo.rs_org=r.org AND code='''||code||''''
||') x ON organism=org_in_rs' all
,'UNION SELECT organism, count(organism) cnt, '''||code||''' disk FROM ( SELECT  organism '
||'FROM (SELECT * FROM surgery17_1 WHERE '||code||' IS NOT NULL) s LEFT JOIN  ( '
||'SELECT roo.org org_in_rs, r.* FROM rs r, rs_org_org roo WHERE roo.rs_org=r.org AND code='''||code||''' '
||') x ON organism=org_in_rs '
||'WHERE x.org IS NULL) GROUP BY organism'
||'' analize0
FROM rs WHERE used ) x ) x
ORDER BY code

SELECT x.* 
,'SELECT ward, group_org, CASEWHEN(all_'||code||'>0, CEIL(ok_'||code||'*1000/all_'||code||')/10,0) okproc_'||code||', petri /*, x.* */ '
||'FROM ('
||'SELECT ward, group_org , COUNT(group_org) petri , SUM(s_'||code||') ok_'||code||', SUM(a_'||code||') all_'||code||' /*, x.* */ '
||'FROM ( '
||x.all
||') x GROUP BY ward, group_org) x ORDER BY ward, petri DESC ' chutlivist
FROM (
SELECT DISTINCT code
,'SELECT ward, CASEWHEN(x.org IS NULL, ''0ai'',x.org) group_org, amc_nd20'
||', CASEWHEN('||code||'>s,1,0) s_'||code||', CASEWHEN(s IS NULL,0,1) a_'||code||', organism , x.* '
||'FROM (SELECT * FROM surgery17_1 WHERE '||code||' IS NOT NULL) s LEFT JOIN  ('
||'SELECT roo.org org_in_rs, r.* FROM rs r, rs_org_org roo WHERE roo.rs_org=r.org AND code='''||code||''''
||') x ON organism=org_in_rs' all
FROM rs WHERE used ) x
ORDER BY code

-- Чутливість по відділеннях і по штамах по діску AMC_ND20
SELECT ward, group_org , CASEWHEN(all_AMC_ND20 >0, CEIL(ok_AMC_ND20*1000/all_AMC_ND20)/10,0) okproc_AMC_ND20, petri /*, x.* */
FROM (
SELECT ward, group_org , COUNT(group_org) petri , SUM(s_AMC_ND20) ok_AMC_ND20 , SUM(a_AMC_ND20) all_AMC_ND20 /*, x.* */
FROM (
SELECT ward, CASEWHEN(x.org IS NULL, '0ai',x.org) group_org, amc_nd20
, CASEWHEN(AMC_ND20>s,1,0) s_AMC_ND20 , CASEWHEN(s IS NULL,0,1) a_AMC_ND20 , organism , x.*
FROM (SELECT * FROM surgery17_1 WHERE AMC_ND20 IS NOT NULL) s LEFT JOIN  (
SELECT roo.org org_in_rs, r.* FROM rs r, rs_org_org roo WHERE roo.rs_org=r.org AND code='AMC_ND20'
) x ON organism=org_in_rs
) x GROUP BY ward, group_org) x ORDER BY ward, petri DESC

-- Всі випадки по діску AMC_ND20 що не можна проаналізувати з вказанням штаму.
SELECT organism, count(organism) cnt, 'AMC_ND20' disk FROM ( SELECT  organism
FROM (SELECT * FROM surgery17_1 WHERE AMC_ND20 IS NOT NULL) s LEFT JOIN  (
SELECT roo.org org_in_rs, r.* FROM rs r, rs_org_org roo WHERE roo.rs_org=r.org AND code='AMC_ND20'
) x ON organism=org_in_rs
WHERE x.org IS NULL) GROUP BY organism

-- Всі випадки по діску AMC_ND20. 0ai = (null analize info) проаналізувати неможливо
SELECT ward, CASEWHEN(x.org IS NULL, '0ai',x.org) group_org, amc_nd20
, CASEWHEN(AMC_ND20>s,1,0) s_AMC_ND20 , CASEWHEN(s IS NULL,0,1) a_AMC_ND20 , organism , x.* 
FROM (SELECT * FROM surgery17_1 WHERE AMC_ND20 IS NOT NULL) s LEFT JOIN  (
SELECT roo.org org_in_rs, r.* FROM rs r, rs_org_org roo WHERE roo.rs_org=r.org AND code='AMC_ND20'
) x ON organism=org_in_rs

-- Кількість по відділення і по штамам
SELECT x.*,ro.name FROM (
SELECT x.*, cnt_ward FROM (
SELECT ward, group_org, count(group_org) cnt_group_org FROM (
SELECT CASEWHEN(rs_org IS NULL,s.organism,rs_org) group_org, s.organism ogm, s.* FROM surgery17_1 s 
LEFT JOIN (SELECT rs_org, ol.* FROM rs_org_org roo,ORGLIST ol, (SELECT  MIN(id) mid FROM ORGLIST ol GROUP BY org) x
 WHERE ol.org=roo.org and x.mid=ol.id) x ON x.org=s.organism 
) GROUP BY ward, group_org
) x, (SELECT WARD, COUNT(WARD) cnt_WARD FROM surgery17_1 GROUP BY WARD) y
WHERE x.ward=y.ward
) x  LEFT JOIN rs_org ro ON rs_org=group_org
ORDER BY cnt_ward DESC, cnt_group_org DESC

SELECT x.*,ro.name FROM (
SELECT x.*, cnt_ward FROM (
SELECT ward, group_org, COUNT(group_org) cnt_group_org FROM (
SELECT x.ward, group_org FROM (
SELECT CASEWHEN(rs_org IS NULL,s.organism,rs_org) group_org, s.organism ogm, s.* FROM surgery17_1 s 
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
SELECT g_org, COUNT(g_org) cnt_g_org FROM (
SELECT CASEWHEN(rs_org IS NULL,s.organism,rs_org) g_org, s.organism ogm, s.* FROM surgery17_1 s 
LEFT JOIN (SELECT rs_org, ol.* FROM rs_org_org roo,ORGLIST ol, (SELECT  MIN(id) mid FROM ORGLIST ol GROUP BY org) x
WHERE ol.org=roo.org and x.mid=ol.id) x ON x.org=s.organism 
) GROUP BY g_org
) x LEFT JOIN rs_org ON rs_org=g_org
ORDER BY cnt_g_org DESC

-- all normal probe
SELECT * FROM (
SELECT * FROM surgery17_1 s, ORGLIST ol, (SELECT  MIN(id) mid FROM ORGLIST ol GROUP BY org) x 
WHERE x.mid=ol.id and s.organism=ol.org
) x 
WHERE NOT(gram='f' OR COMMENT_aberration)

-- all probe
SELECT ol.* FROM surgery17_1 s, ORGLIST ol, (SELECT  MIN(id) mid FROM ORGLIST ol GROUP BY org) x 
WHERE x.mid=ol.id and s.organism=ol.org

-- unique orglist
SELECT * FROM ORGLIST ol, (SELECT  MIN(id) mid FROM ORGLIST ol GROUP BY org) x WHERE x.mid=ol.id

-- Ертапенем 
SELECT CASEWHEN(length(ert_chut)<=2,1,0) ert_chut_notchut, x.* FROM (
SELECT REGEXP_REPLACE(REGEXP_REPLACE(s.COMMENT,'Ертапенем +',''),' +чутл.','') ert_chut, 
s.COMMENT cmt1, s.* FROM surgery17_1 s where COMMENT like 'Ерта%'
) x

-- Гриби
SELECT * FROM (
SELECT ol.* FROM surgery17_1 s, ORGLIST ol, (SELECT  MIN(id) mid FROM ORGLIST ol GROUP BY org) x 
WHERE x.mid=ol.id and s.organism=ol.org
) x WHERE gram='f'

-- Неможливо проаналізувати

-- Неможливо проаналізувати по діскам
SELECT disk, COUNT(disk) cnt_org, SUM(cnt) fall FROM (
-- copy  analize0  union selects
) GROUP BY disk
ORDER BY cnt_org DESC

-- Неможливо проаналізувати по штамам
SELECT x.*, org_clean FROM (
SELECT organism, COUNT(organism) cnt_disk, SUM(cnt) fall FROM (
-- copy  analize0  union selects
) GROUP BY organism
) x, (
SELECT * FROM ORGLIST ol, (SELECT  MIN(id) mid FROM ORGLIST ol GROUP BY org) x WHERE x.mid=ol.id
) y WHERE y.org=organism
ORDER BY fall DESC

