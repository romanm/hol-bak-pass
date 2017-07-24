-- Ертапенем 
SELECT casewhen(length(ert_chut)<=2,1,0) ert_chut_notchut, x.* FROM (
SELECT REGEXP_REPLACE(REGEXP_REPLACE(s.COMMENT,'Ертапенем +',''),' +чутл.','') ert_chut, 
s.COMMENT cmt1, s.* FROM surgery17_1 s where COMMENT like 'Ерта%'
) x
