## Python files for various ETL and data processing tasks

#### Packages currently used (may not be comprehensive)

diagrams
boto3
pyodbc
pandas

#### File descriptions

**diagram.py**

Using the diagrams package, creates an architecture diagram for dev, test, and prod AWS Glue Workflows, based on an [AWS blog post](https://aws.amazon.com/blogs/architecture/field-notes-how-to-build-an-aws-glue-workflow-using-the-aws-cloud-development-kit/) 

**database_snapshots_to_csv.py**

Queries every table in a MS SQL Server database, creates a directory for the results,
and writes each table to a csv file in the directory.


**batch_upload_snapshots_to_s3.py**

Uploads all files in a specified directory to a specified AWS S3 bucket.