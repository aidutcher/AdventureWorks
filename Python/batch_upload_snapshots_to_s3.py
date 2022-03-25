# -*- coding: utf-8 -*-
"""
Upload all files in a specified directory to a specified S3 bucket

Created on Sun Feb 13 12:44:31 2022

@author: aidut
"""

import logging
import boto3
from botocore.exceptions import ClientError
import os
from pathlib import Path

# Populate a list with all files in a specified directory
def list_files(directory):
    file_list = []
    files = Path(directory).glob('*')
    for root, dirs, files in os.walk(directory):
        for filename in files:
           file_list.append(os.path.join(root, filename))
    return file_list
    
# Upload an individual file (file_name) to an S3 bucket (bucket)
# with object_name = the base name of the file (i.e. HumanResources-Employee-2022-02-12-20-51-58.csv)
def upload_file(file_name, bucket, object_name=None):
    if object_name is None:
        object_name = os.path.basename(file_name)
    try:
        response = s3_client.upload_file(file_name, bucket, object_name)
    except ClientError as e:
        logging.error(e)
        return False
    return True

# For each file returned by list_files, call upload_file
def batch_upload(files):
    for file in files:
        object_name = os.path.basename(file)
        print('Uploading: {}'.format(file))
        upload_file(file,bucket,object_name)

s3_client = boto3.client('s3')
bucket = 'test-adventureworks-db-snapshots'
directory = r'C:\Users\aidut\projects\AdventureWorks\CSV\DatabaseSnapshots\2022-03-13-14-10-18'

files = list_files(directory)
batch_upload(files)


