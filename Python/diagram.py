# -*- coding: utf-8 -*-
"""
Created on Tue Mar 22 20:16:41 2022

@author: aidut
"""

import os
from diagrams import Cluster, Diagram
from diagrams.aws.storage import S3
from diagrams.aws.analytics import Glue, GlueCrawlers, GlueDataCatalog, Redshift

os.environ["PATH"] += os.pathsep + 'D:/Program Files (x86)/Graphviz2.38/bin/'

from diagrams.onprem.database import MSSQL

with Diagram("AW Data Pipeline", filename = "aw_data_pipeline_diagram"):
    
    sql_server = MSSQL("SQL Server")

    with Cluster("Pipelines"):

        raw = S3("raw")
        
        with Cluster("dev"):

            dev_staging = S3("staging")
            dev_processed = S3("processed")
            dev_first_etl = Glue("Glue ETL job")
            dev_second_etl = Glue("Glue ETL job")
            dev_third_etl = Glue("Glue ETL job")
            dev_staging_crawler = GlueCrawlers("crawler")
            dev_processed_crawler = GlueCrawlers("crawler")
            dev_catalog = GlueDataCatalog("catalog")           
            dev_redshift = Redshift("Redshift")
            
        with Cluster("test"):
            
            test_staging = S3("staging")
            test_processed = S3("processed")
            test_first_etl = Glue("Glue ETL job")
            test_second_etl = Glue("Glue ETL job")
            test_third_etl = Glue("Glue ETL job")
            test_staging_crawler = GlueCrawlers("crawler")
            test_processed_crawler = GlueCrawlers("crawler")
            test_catalog = GlueDataCatalog("catalog")
            test_redshift = Redshift("Redshift")          
            
        with Cluster("prod"):
            
            prod_staging = S3("staging")
            prod_processed = S3("processed")
            prod_first_etl = Glue("Glue ETL job")
            prod_second_etl = Glue("Glue ETL job")
            prod_third_etl = Glue("Glue ETL job")
            prod_staging_crawler = GlueCrawlers("crawler")
            prod_processed_crawler = GlueCrawlers("crawler")
            prod_catalog = GlueDataCatalog("catalog")
            prod_redshift = Redshift("Redshift")
            
        etl_jobs = [dev_first_etl,
                    test_first_etl,
                    prod_first_etl]
            
    sql_server >> raw >> etl_jobs 
    
    dev_first_etl >> dev_staging 
    dev_staging >> dev_staging_crawler >> dev_catalog
    dev_staging >> dev_second_etl >> dev_processed
    dev_processed >> dev_processed_crawler >> dev_catalog
    dev_processed >> dev_third_etl >> dev_redshift
    
    test_first_etl >> test_staging 
    test_staging >> test_staging_crawler >> test_catalog
    test_staging >> test_second_etl >> test_processed
    test_processed >> test_processed_crawler >> test_catalog
    test_processed >> test_third_etl >> test_redshift
    
    prod_first_etl >> prod_staging 
    prod_staging >> prod_staging_crawler >> prod_catalog
    prod_staging >> prod_second_etl >> prod_processed
    prod_processed >> prod_processed_crawler >> prod_catalog
    prod_processed >> prod_third_etl >> prod_redshift
