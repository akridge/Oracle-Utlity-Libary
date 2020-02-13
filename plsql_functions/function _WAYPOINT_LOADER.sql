--------------------------------------------------------
--  DDL for Function F_WAYPOINT_LOADER v1.5
-- source from C. Martinez
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "SCHEMANAME"."F_WAYPOINT_LOADER" (input IN CLOB)
 
RETURN VARCHAR
 
AS
 
    --VARIABLES FOR HOLDING GPS DATA
    gpsData CLOB := input;
    headers CLOB;
    element CLOB;--ELEMENTS OF DATA BETWEEN THE ','
    
    --COUNTER VARIABLES
    i INTEGER;
    j INTEGER;
    k INTEGER;
    siteOccurs INTEGER := 0;
    svInserts INTEGER := 0;
    losInserts INTEGER := 0;
    
    --DELIMITER VARIABLES
    commaR INTEGER;
    numberColumns INTEGER(10);
    
    
    --ARRAY TYPE VARIABLE
    TYPE charArray IS TABLE OF VARCHAR(100) INDEX BY PLS_INTEGER;
    
    --ARRAY VARIABLES FOR INSERTION
    mainArray charArray;
    siteArray charArray;
    dateVisitArray charArray;
    latArray charArray;
    longArray charArray;
    islandArray charArray;
    regionArray charArray;
 
    --VARIABLES TO STORE RETRIEVED TABLE DATA
    ISLANDCODES charArray; 
    ISLANDNAMES charArray;
    REGIONS charArray;
    
    --EXCEPTION VARIABLES
    exBadSiteName EXCEPTION;
    exBadDate EXCEPTION;
    exBadLatLong EXCEPTION;
    exBadData EXCEPTION;
    exEmptyData EXCEPTION;
    
    --ROUND VARIABLE
    roundID number;
 
    --RETURN VARIABLE
    returnStr VARCHAR(200) := 'test';
    
         
    /*
    
    READ ME
    
    ---------------------------------
    
    1. BREAK GPS TEXT FILE INTO LINES, THEN BREAK THE LINES INTO ELEMENTS USING THE COMMAS FOR mainArray, AND FIGURE OUT THE NUMBER OF COLUMNS
    2. CHECK IF THE DATA FORMAT IS CORRECT
    3. USING THE NUMBER OF COLUMNS TO SEPARATE mainArray COLUMNS INTO THEIR OWN RESPECTIVE ARRAYS (latArray, longArray, siteArray, dateVisistedArray, regionArray, islandArray)
    4. RETRIEVE MOST CURRENT ISLAND/REGION CODES FROM THE DATABASE TO COMPARE AND USE WITH GPS DATA
    5. CHECK THE FIRST 3 CHARACTERS OF siteArray TO ENSURE SITE NAME HAS VALID ISLAND CODE
    6. CHECK IF ALL SITE NAMES WERE VALID
    7. CHECK IF SITE NAME HAS ONLY ONE '-'
    8. CHECK THAT EVERYTHING AFTER THE '-' IN THE SITE NAME IS 2-4 NUMBERS
    9. CHECK THAT LATITUDE AND LONGITUDE CONSISTS OF ONLY NUMBERS
    10. CHECK THAT DATE VISITED IS NOT A FUTURE DATE
    11. INSERT ONLY SITES THAT DO NOT EXIST IN LIST_OF_SITES TABLE
    12. REMOVE SITES AND CORRESPONDING DATA LISTED MORE THAN ONCE IN THE GPS TEXT FILE
    13. REMOVE SITES THAT EXIST IN THE SITE_VISIT TABLE WITH THE EXACT SAME VALUES!
    14. INSERT INTO TABLE
    
    ----------------------------
    
    */
    
 
BEGIN
 
    ---------------------------------
    
    --1. BREAK GPS TEXT FILE INTO LINES, THEN BREAK THE LINES INTO ELEMENTS USING THE COMMAS FOR mainArray, AND FIGURE OUT THE NUMBER OF COLUMNS
    
    ---------------------------------
    i := LENGTH(gpsData);
    j := 1;
    k := 1;
    
    IF gpsData IS NULL THEN
    
        RAISE exEmptyData;
    
    END IF;
    
 
    headers := LPAD(gpsData, INSTR(gpsData,CHR(10)));
    numberColumns := REGEXP_COUNT(headers, ',') + 1;
    gpsData := TRANSLATE(gpsData, CHR(10), ',');
    gpsData := UPPER(gpsData);
    
    WHILE i > 0
    LOOP
    
        commaR := INSTR(gpsData, ',') - 1;
    
        IF commaR > 0 THEN
            
            
            
                element := LPAD(gpsData, commaR);
                gpsData := SUBSTR(gpsData, commaR + 2);
                mainArray(j) := element;
            
                    
        ELSE
                    
            element := gpsData;
            mainArray(j) := element;
            i := 0;

        END IF;
        
        i := i - 1;
        j := j + 1;
       
        
    END LOOP;
 
    
    
    ---------------------------------   
       
    --2. CHECK IF THE DATA FORMAT IS CORRECT
    
    ---------------------------------
    

    IF MOD(mainArray.COUNT, numberColumns) != 0 THEN
        
        RAISE exBadData;
    
    END IF;
 
 
    ---------------------------------   
       
    --3. USING THE NUMBER OF COLUMNS TO SEPARATE mainArray COLUMNS INTO THEIR OWN RESPECTIVE ARRAYS (latArray, longArray, siteArray, dateVisistedArray, regionArray, islandArray)
    
    ---------------------------------
     
    i := 1;
    
    WHILE i < numberColumns + 1
    LOOP
        
        --LATITUDE ARRAY
        IF mainArray(i) = 'LAT' THEN
            
            j := i + numberColumns;
            
            WHILE j < mainArray.COUNT 
            LOOP
            
                latArray(k) := mainArray(j);                
                j := j + numberColumns;
                k := k + 1;
                
            END LOOP;
            
            
            i := i + 1;
            k := 1;
        
		--LONGITUDE ARRAY		
        ELSIF mainArray(i) = 'LONG' THEN
            
            j := i + numberColumns;
            
            WHILE j < mainArray.COUNT 
            LOOP
            
                longArray(k) := mainArray(j);                
                j := j + numberColumns;
                k := k + 1;
                
            END LOOP;
            
            
            i := i + 1;
            k := 1;
        
		--SITE NAME ARRAY		
        ELSIF mainArray(i) = 'IDENT' THEN
            
            j := i + numberColumns;
            
            WHILE j < mainArray.COUNT 
            LOOP
            
                siteArray(k) := mainArray(j);
                j := j + numberColumns;
                k := k + 1;
                
            END LOOP;
            
            
            i := i + 1;
            k := 1;
        
		--LOCAL TIME/DATE ARRAY		
        ELSIF mainArray(i) = 'LTIME' THEN --DATE
            
            j := i + numberColumns;
            
            WHILE j <= mainArray.COUNT 
            LOOP
            
                dateVisitArray(k) := mainArray(j); 
                j := j + numberColumns;
                k := k + 1;
                
            END LOOP;
            
            
            i := i + 1;
            k := 1;
        
		--INCREMENT BY 1
        ELSE
        
           i := i + 1;
           k := 1;
        
        END IF;
    
    END LOOP;
    
    i := 1;
    
    ---------------------------------   
       
    --4. RETRIEVE MOST CURRENT ISLAND/REGION CODES FROM THE DATABASE TO COMPARE AND USE WITH GPS DATA
    
    ---------------------------------
 
    j := 1;
    
	FOR i IN (SELECT ISLAND_NAM, ISLAND_COD, REGION_COD FROM ISLANDS ORDER BY ISLAND_COD)
	LOOP
		ISLANDNAMES(j) := i.ISLAND_NAM;
	    ISLANDCODES(j) := i.ISLAND_COD;
        REGIONS(j) := i.REGION_COD;
        j := j + 1;
		
	END LOOP;
    
    
    ---------------------------------   
       
    --5. CHECK THE FIRST 3 CHARACTERS OF siteArray TO ENSURE SITE NAME HAS VALID ISLAND CODE
    
    ---------------------------------
    
    i := 1;
    j := 1;
    k := 0;
    
    <<MAIN>>
    FOR i IN 1 .. siteArray.LAST
    LOOP
    
        
        <<INNER>>
        FOR j IN 1 .. ISLANDCODES.LAST
        LOOP
        
            
        
            IF LPAD(siteArray(i), 3) = ISLANDCODES(j) THEN
                
                islandArray(i) := ISLANDNAMES(j);
                regionArray(i) := REGIONS(j);
                k := k + 1;               
                EXIT INNER;
                
            END IF;           
            
        END LOOP INNER;   
        
    END LOOP MAIN;
    
    ---------------------------------   
       
    --6. CHECK IF ALL  NAMES WERE VALID
    
    ---------------------------------
    
    IF k < siteArray.COUNT THEN       
        
        RAISE exBadSiteName;
 
    END IF;
    
    ---------------------------------   
       
    --7. CHECK IF SITE NAME HAS ONLY ONE '-'
    
    ---------------------------------
    
    FOR i IN 1 .. siteArray.LAST
    LOOP
    
        IF INSTR(siteArray(i), '-') = 0 OR INSTR(siteArray(i), '-') != 4 OR INSTR(siteArray(i), '-', 1, 2) > 4 OR LENGTH(siteArray(i)) < 6 THEN
 
            RAISE exBadSiteName;
 
        END IF;
    
    END LOOP;
    
    ---------------------------------   
       
    --8. CHECK THAT EVERYTHING AFTER THE '-' IN THE SITE NAME IS 2-4 NUMBERS
    
    ---------------------------------
    
    FOR i IN 1 .. siteArray.LAST
    LOOP
    
        IF LENGTH(SUBSTR(siteArray(i), 5 )) < 2  OR  LENGTH(SUBSTR(siteArray(i), 5)) > 4 OR LENGTH(TRIM(TRANSLATE(SUBSTR(siteArray(i), 5, 4), '0123456789',' '))) > 0 THEN
 
            RAISE exBadSiteName;
 
        END IF;
    
    END LOOP;
    
    ---------------------------------   
       
    --9. CHECK THAT LATITUDE AND LONGITUDE CONSISTS OF ONLY NUMBERS
    
    ---------------------------------
    
    FOR i IN 1 .. latArray.LAST
    LOOP
    
        IF LENGTH(TRIM(TRANSLATE(latArray(i), ' +-.0123456789',' '))) > 0 OR LENGTH(TRIM(TRANSLATE(longArray(i), ' +-.0123456789',' '))) > 0 THEN
                
            RAISE exBadLatLong;              
 
        END IF;
                
    
    END LOOP;
    
    ---------------------------------   
       
    --10. CHECK THAT DATE VISITED IS NOT A FUTURE DATE
    
    ---------------------------------
        
    FOR i IN 1 .. dateVisitArray.LAST
    LOOP
    
        --IF dateVisitArray.EXISTS(i) THEN
        
            IF TO_DATE(dateVisitArray(i), 'YYYY/MM/DD HH24:MI:SS') > SYSDATE THEN
 
                RAISE exBadDate;
                
            --END IF;
 
        END IF;
        
        EXIT WHEN i > dateVisitArray.LAST;
    
    END LOOP;
        
    ---------------------------------   
       
    --11. INSERT ONLY SITES THAT DO NOT EXIST IN LIST_OF_SITES TABLE
    
    ---------------------------------
    
    FOR i IN siteArray.FIRST .. siteArray.LAST 
    LOOP
        
        siteOccurs := 0;
        
        FOR j IN (SELECT SITE FROM LIST_OF_SITES)
        LOOP
            
            IF siteArray(i) = j.SITE THEN
                
                siteOccurs := siteOccurs + 1;                
                
            END IF;
        
        END LOOP;
        
        IF siteOccurs < 1 THEN
        
            INSERT INTO LIST_OF_SITES(SITE, LATITUDE, LONGITUDE, REGION, ISLAND)
            VALUES(siteArray(i), latArray(i), longArray(i), regionArray(i), islandArray(i));
            losInserts := losInserts + 1;
           
        END IF;
        
    END LOOP;    
   
    
    ---------------------------------   
       
    --12. REMOVE SITES AND CORRESPONDING DATA LISTED MORE THAN ONCE IN THE GPS TEXT FILE
    
    ---------------------------------
    
    i := 1;
    j := 1;
    
    <<MAIN>>
    LOOP     
    
        j := 1;
        
        <<INNER>>
        LOOP
        
            IF siteArray.EXISTS(i) AND siteArray.EXISTS(j) THEN
            
                IF i <> j AND siteArray(i) = siteArray(j) 
                AND dateVisitArray(i) = dateVisitArray(j)
                AND latArray(i) = latArray(j) 
                AND longArray(i) = longArray(j) 
                AND dateVisitArray(i) = dateVisitArray(j) THEN
 
                    siteArray.DELETE(i);
                    latArray.DELETE(i);
                    longArray.DELETE(i);
                    dateVisitArray.DELETE(i);
                    islandArray.DELETE(i);
                    regionArray.DELETE(i);             
 
 
                END IF;                
                
            END IF;
            
            j := j + 1;
            
            EXIT INNER WHEN j > siteArray.LAST;
            
        END LOOP;      
        
        i := i + 1;
        EXIT WHEN i > siteArray.LAST;
        
    END LOOP;
    
    
    
    ---------------------------------   
       
    --13. REMOVE SITES THAT EXIST IN THE SITE_VISIT TABLE WITH THE EXACT SAME VALUES!
    
    ---------------------------------
    
    i := 1;
    j := 1;

    <<A>>
    FOR i IN 1 .. siteArray.LAST
    LOOP       
        
        siteOccurs := 0;
        
        <<B>>
        FOR j in (SELECT SITE, LATITUDE, LONGITUDE, DATE_, LOCALTIME FROM SITE_VISIT)
        LOOP

            IF siteArray.EXISTS(i) AND siteArray(i) = j.SITE 
            AND latArray(i) = j.LATITUDE AND longArray(i) = j.LONGITUDE 
            AND TO_DATE(dateVisitArray(i), 'YYYY/MM/DD HH24:MI:SS') = j.DATE_ AND TO_TIMESTAMP(dateVisitArray(i), 'YYYY/MM/DD HH24:MI:SS') = j.LOCALTIME THEN
                
                siteOccurs := 1;               
                
                EXIT B WHEN siteOccurs > 0;

            END IF;            

        END LOOP;       
        
        IF siteOccurs > 0 THEN
        
            siteArray.DELETE(i);
            latArray.DELETE(i);
            longArray.DELETE(i);
            dateVisitArray.DELETE(i);
            islandArray.DELETE(i);
            regionArray.DELETE(i);
        
        END IF;
        
        IF siteArray.COUNT < 1 THEN 
        
            EXIT;
            
        END IF;
        
    END LOOP;
     
    ---------------------------------   
       
    --14. INSERT INTO SITE VISITS TABLE
    
    ---------------------------------
   
    i := 1;
    
    select max(roundid) into roundID from round;
    
    IF siteArray.COUNT > 0 THEN
    
        LOOP

            IF siteArray.EXISTS(i) THEN

                INSERT INTO SITE_VISIT(SITE, LATITUDE, LONGITUDE, DATE_, LOCALTIME, ROUNDID)
                VALUES(siteArray(i), latArray(i), longArray(i), TO_DATE(dateVisitArray(i), 'YYYY/MM/DD HH24:MI:SS'), TO_TIMESTAMP(dateVisitArray(i), 'YYYY/MM/DD HH24:MI:SS'), roundID);
                svInserts := svInserts + 1;

            END IF;

            i := i + 1;

            EXIT WHEN i > siteArray.LAST;

        END LOOP;   
    
    END IF;
    
    returnStr := losInserts || ' row(s) inserted into table LIST_OF_SITES, and ' || svInserts || ' row(s) inserted into table SITE_VISIT.';
    
    DBMS_OUTPUT.PUT_LINE(returnStr);
    RETURN returnStr;
   
 
EXCEPTION
 
    WHEN exBadData THEN
        
        raise_application_error(-20001,'NUMBER OF HEADERS, AND THE NUMBER OF DATA COLUMNS IS NOT EQUAL. ENSURE YOU COPY AND PASTE DIRECTLY FROM THE FILE.');
        
    WHEN exEmptyData THEN

        raise_application_error(-20001,'PLEASE ENTER DATA INTO THE FORM.');    
 
    WHEN exBadSiteName THEN
        
        raise_application_error(-20001,'INVALID SITE NAME WAS ENTERED. SITE NAMES MUST CONTAIN A VALID 3 LETTER ISLAND CODE FOLLOWED A ''-'' AND 2-4 DIGITS. EX: AGR-001');
        
    WHEN exBadDate THEN
    
         raise_application_error(-20001,'SITE VISIT DATE CANNOT BE IN THE FUTURE');
     
    WHEN exBadLatLong THEN
        
        raise_application_error(-20001,'LATITUDE AND LONGITUDE VALUES MUST CONSIST OF ONLY NUMBERS.');
    
END;

/
