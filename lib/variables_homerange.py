# -*- coding: utf-8 -*-
# Python script for calculating usual statistics (mean, max, min, std, median) for specific 
# enviromental variables in species home range while iterating through different home range 
# radius size

import psycopg2
import psycopg2.extras
import sys
import time
import logging 

# Setting starting time
startTime = time.time()

# Variables for holding ecological variables and statistic to calculate
ecolVar = ['dem30','dah30','slope30','prox30']
statVar = ['median', 'mean', 'min', 'max', 'stddev']
valuesInsFin = []
lcovValues = {1:'moc', 2:'polj', 3:'sum', 4:'nesum',5:'vod', 6:'gol', 7:'nas'}
buffer = list(range(30,5040,30))

# Preparing queries
# SQL query for geting variables values for dem, dah, slope and prox
sqlQueryBuffer1 = """ WITH buffer AS (SELECT gid, ST_Buffer(geom,(%s)) AS hr from species)
            SELECT medo.gid, median, mean, min, max, stddev
            FROM (SELECT gid, (ST_SummaryStats(ST_Union(ST_Clip(rast, hr, TRUE)),1)).* FROM %s, buffer WHERE ST_Intersects(rast, hr) group by gid) sumo, 
                    (SELECT gid, median(val) FROM (SELECT gid, unnest((ST_DumpValues(ST_Clip(rast,hr,TRUE))).valarray) AS val 
                        FROM %s, buffer WHERE ST_Intersects(rast, hr)) hrbuffer WHERE val IS NOT NULL GROUP by gid) medo
            WHERE sumo.gid=medo.gid
            ORDER by gid """

# SQL query for geting values for land cover
sqlQueryBuffer2 = """ WITH buffer AS (SELECT gid, ST_Buffer(geom,(%s)) AS hr from species)
            SELECT gid, (gv).val, round(100*sum(ST_Area((gv).geom)/area)::numeric,2) AS percent
            FROM (SELECT gid, ST_Intersection(rast,hr) AS gv, ST_Area(hr) AS area FROM buffer, lcov30 WHERE ST_intersects(rast,hr)) foo
            WHERE (gv).val IS NOT NULL
            GROUP BY val, gid
            ORDER BY gid, percent DESC """

# SQL query for creating table in GISdb for holding all the values for each variable and each home range            
sqlCreateTable = """ DROP TABLE IF EXISTS public.emb_hor_hr;
                     CREATE TABLE public.emb_hor_hr(
                        id serial,
                        gid integer,
                        ecolvar text,
                        buffer integer,
                        statatrib text,
                        statatribvalue double precision)
                    WITH (OIDS=FALSE);
                    ALTER TABLE public.emb_hor_hr
                    OWNER TO postgres; """

# SQL query for inserting values into emb_hor_hr table
sqlQueryInsert = """ INSERT into emb_hor_hr (gid,ecolvar,buffer,statatrib,statatribvalue) VALUES (%s, %s, %s, %s, %s) """

try:
    # Establishing conenction to GISdb and creating a new database session
    con = psycopg2.connect("dbname='GISdb' user='postgres' password='' host='localhost'")
    
    # Creating cursor object and executing the SQL statement
    cur = con.cursor(cursor_factory=psycopg2.extras.DictCursor)
    
    # Creating table for storing final results
    cur.execute(sqlCreateTable)

    # Part One
    # Iterating through different ecological variables, home range buffers ans statistics to create list of values for insert
    # Executing results and commiting changes to db after each buffer iteration
    for var in ecolVar:
        print('Iterating through', var, 'variable.')
        for buff in buffer:
            print(buff, end=" ", flush=True)
            data=(buff,var,var)
            cur.execute(sqlQueryBuffer1 % data)
            rows = cur.fetchall()
            for row in rows:
                for stat in statVar:
                    values = [row["gid"], var[:-2], buff, stat, row[stat]]
                    valuesInsFin.append(values)
            cur.executemany(sqlQueryInsert,valuesInsFin)
            con.commit()
            valuesInsFin = []
        print('\n')
    
    # Print intermediate time
    timeCur = time.time() - startTime, "seconds"
    print ('Intermediate execution time is:', timeCur[0], timeCur[1], '\n')

    # Part Two
    # Iterating through land cover variable calculating for each home range percent of each land cover class in buffer 
    print('Iterating through lcov30 variable')
    
    # Reseting list for holding values for inserting into db
    valuesInsFin = []

    #Iterating through buffer executing results and commiting changes to db for part two
    for buff in buffer:
        print(buff, end=" ", flush=True)
        data=(buff,)
        cur.execute(sqlQueryBuffer2 % data)
        rows = cur.fetchall()
        for row in rows:
            values = [row["gid"], 'lcov_'+lcovValues[int(row["val"])], buff, 'percent', row["percent"]]
            valuesInsFin.append(values)
        cur.executemany(sqlQueryInsert,valuesInsFin)
        con.commit()
        valuesInsFin = []
    print('\n')
    
    # Print final time
    timeCur = time.time() - startTime, "seconds"
    print ('Final execution time is:', timeCur[0], timeCur[1], '\n')

except:
    logging.exception('')

finally:
    # Closing connection to database
    con.close()
