import aws_cdk as cdk
import aws_cdk.aws_s3 as s3
from constructs import Construct

class CdkAppStack(cdk.Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)


        bucket = s3.Bucket(self, "test-aw-database-snapshots", 
            versioned=True,
            removal_policy=cdk.RemovalPolicy.DESTROY,
            auto_delete_objects=True)
                
            
