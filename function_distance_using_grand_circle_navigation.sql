--Developed by: Michael Akridge 2-26-2019  from internet sources
--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
--f_distance_m
-- grand circle navigation plsql
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
--
create or replace FUNCTION F_DISTANCE_M  (Lat1 IN NUMBER,
                                     Lon1 IN NUMBER,
                                     Lat2 IN NUMBER,
                                     Lon2 IN NUMBER,
                                     Radius IN NUMBER DEFAULT 6367450) RETURN NUMBER IS
 
 
            --Miles 3956.55  
            --Kilometers 6367.45 
            --Feet 20890584 
            --Meters 6367450 
 
 -- Convert degrees to radians
 DegToRad NUMBER := 57.29577951;

BEGIN
  RETURN(NVL(Radius,0) * ACOS((sin(NVL(Lat1,0) / DegToRad) * SIN(NVL(Lat2,0) / DegToRad)) +
        (COS(NVL(Lat1,0) / DegToRad) * COS(NVL(Lat2,0) / DegToRad) *
         COS(NVL(Lon2,0) / DegToRad - NVL(Lon1,0)/ DegToRad))));
END F_DISTANCE_M;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- simple sql example start
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT distinct 
        t1.columnid,t2.LATITUDE, t3.LONGITUDE, 
	t2.columnid, t2.SITELAT, t2.SITELON,
	F_DISTANCE_M(t1.LATITUDE, t1.LONGITUDE, t2.SITELAT, t2.SITELON) AS DISTANCE_M 
FROM table_name_one t1, table_name_two t2
ORDER BY distance_m


