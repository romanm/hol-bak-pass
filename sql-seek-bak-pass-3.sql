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

-- all normal probe
SELECT * FROM (
SELECT * FROM surgery17_1 s, ORGLIST ol, (SELECT  min(id) mid FROM ORGLIST ol GROUP BY org) x 
WHERE x.mid=ol.id and s.organism=ol.org
) x 
where not(gram='f' or COMMENT_aberration)

-- all probe
SELECT ol.* FROM surgery17_1 s, ORGLIST ol, (SELECT  min(id) mid FROM ORGLIST ol GROUP BY org) x 
WHERE x.mid=ol.id and s.organism=ol.org

-- unique orglist
SELECT * FROM ORGLIST ol, (SELECT  min(id) mid FROM ORGLIST ol GROUP BY org) x WHERE x.mid=ol.id


