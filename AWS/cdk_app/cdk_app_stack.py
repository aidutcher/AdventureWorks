import aws_cdk as cdk
import aws_cdk.aws_s3 as s3
from constructs import Construct

class CdkAppStack(cdk.Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # Defining the test, dev, and prod database snapshot buckets
        # Standup these buckets, test pipeline features, then destroy
        
        test_bucket = s3.Bucket(self, "test-aw-database-snapshots", 
            versioned=True,
            block_public_access=s3.BlockPublicAccess.BLOCK_ALL,
            removal_policy=cdk.RemovalPolicy.DESTROY,
            auto_delete_objects=True)
                
        dev_bucket = s3.Bucket(self, "dev-aw-database-snapshots", 
            versioned=True,
            block_public_access=s3.BlockPublicAccess.BLOCK_ALL, 
            removal_policy=cdk.RemovalPolicy.DESTROY,
            auto_delete_objects=True)
            
        prod_bucket = s3.Bucket(self, "prod-aw-database-snapshots", 
            versioned=True,
            block_public_access=s3.BlockPublicAccess.BLOCK_ALL,  
            removal_policy=cdk.RemovalPolicy.DESTROY,
            auto_delete_objects=True)