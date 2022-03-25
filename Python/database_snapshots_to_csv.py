# -*- coding: utf-8 -*-
"""
Create a directory for today's date with a folder for each schema
then write a snapshot of each table into the appropriate folder

Created on Sat Feb 12 19:24:17 2022

@author: aidut
"""

import os
import pandas as pd
import pyodbc 
from datetime import datetime

# The Adventure Works database inlcudes a Hierarchy Id data type that pyodbc doesn't support
# Need this handler function to convert it to string
def HandleHierarchyId(v):
    return str(v)

server = 'DESKTOP-D91E6UV\SQLEXPRESS' 
database = 'AdventureWorks2019'

# This server instance is on my local machine. I'm using a trusted connection for convenience. 
# Ideally appropriate credentials would be used 
cnxn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER=' \
                      +server+';DATABASE='+database+';TRUSTED_CONNECTION=yes')
cnxn.add_output_converter(-151, HandleHierarchyId)
cursor = cnxn.cursor()

# Populate a list with the names of schemas in the database that include base tables
def get_schemas():
    sql = """
        SELECT TABLE_SCHEMA
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_TYPE = 'BASE TABLE'
        GROUP BY TABLE_SCHEMA; 
        """
    df_schemas = pd.read_sql(sql,cnxn)
    df_list = df_schemas.values.tolist()
    schema_list = [schema for schema in df_list for schema in schema]
    return schema_list

schemas = get_schemas()

# Append a timestamp to the directory name so we can store all files created at the same time in the same directory
timestamp = datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
parent_dir = r"C:\Users\aidut\projects\AdventureWorks\CSV\DatabaseSnapshots"
date_dir = os.path.join(parent_dir,timestamp) 

# Create a directory for each schema returned by get_schemas
def make_directories(schemas):
    if not os.path.exists(date_dir):
        os.mkdir(date_dir)
    for schema in schemas:
        full_path = os.path.join(parent_dir,timestamp,schema)
        if not os.path.exists(full_path):
            os.mkdir(full_path)

# Populate a list with every table name in each schema returned by get_schemas
def get_tables(schemas):
    table_list = []
    for schema in schemas:
        sql = """
            SELECT 
            	TABLE_SCHEMA
            ,	TABLE_NAME
            FROM INFORMATION_SCHEMA.TABLES
            WHERE 
            	TABLE_SCHEMA = '{}'
            	AND TABLE_TYPE = 'BASE TABLE'; 
            """.format(schema)
        df_tables = pd.read_sql(sql,cnxn)
        schema = df_tables['TABLE_SCHEMA']
        name = df_tables['TABLE_NAME']
        table = schema + '.' + name
        schema_table_list = table.values.tolist()
        table_list.append(schema_table_list)
        flat_table_list = [table for table in table_list for table in table]
    return flat_table_list

# Select all data from each table returned by get_tables and write each result 
# to an individual csv file.
# This is a proof of concept. Ideally SELECT * would be replaced with a more focused query
def write_tables(tables):
    for table in tables:
        sql = """
            SELECT *
            FROM {}
            """.format(table)
        df = pd.read_sql(sql,cnxn)
        schema_folder = table.split('.')[0]
        file_table_name = table.replace('.','-')
        filename = "{}/{}/{}-{}.csv".format(date_dir,schema_folder,file_table_name,timestamp)
        print(f"Writing table: {table}")
        df.to_csv(filename)
    
make_directories(schemas)
tables = get_tables(schemas)
write_tables(tables)

