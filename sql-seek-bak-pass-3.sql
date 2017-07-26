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

-- Кількість проб по віддіденням
SELECT WARD, count(WARD) cnt_WARD FROM surgery17_1 GROUP BY WARD

-- Кількість проб по штамам
SELECT * FROM (
SELECT g_org, count(g_org) cnt_g_org FROM (
SELECT casewhen(rs_org IS NULL,s.organism,rs_org) g_org, s.organism ogm, s.* FROM surgery17_1 s left join (SELECT rs_org, ol.* FROM rs_org_org roo,ORGLIST ol, (SELECT  MIN(id) mid FROM ORGLIST ol GROUP BY org) x
 WHERE ol.org=roo.org and x.mid=ol.id) x ON x.org=s.organism 
) GROUP BY g_org
) x left join rs_org ON rs_org=g_org


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


