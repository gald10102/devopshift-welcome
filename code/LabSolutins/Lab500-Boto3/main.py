import boto3
from botocore.exceptions import ClientError
from pprint import pprint

s3_client = boto3.client("s3")
ec2_client = boto3.client("ec2")

# #print s3 buckets
# response = s3_client.list_buckets()
# for bucket in response["Buckets"]:
#     print(f"-{bucket["Name"]}")

# #start ec2 instance
# try:
#     response = ec2_client.start_instances(
#         InstanceIds=['id1','id2'],
#         AdditionalInfo='string',
#         DryRun=True|False
#     )
# except ClientError:
#     print("Client error")

# Create an EC2 client
ec2_client = boto3.client("ec2")

# Retrieve VPCs
response = ec2_client.describe_vpcs()

# Print VPC information
for vpc in response["Vpcs"]:
    print(f"VPC ID: {vpc['VpcId']}, CIDR Block: {vpc['CidrBlock']}")

# Create an IAM client
iam_client = boto3.client("iam")

# Retrieve users
response = iam_client.list_users()

# Print user information
for user in response["Users"]:
    print(f"User Name: {user['UserName']}, User ID: {user['UserId']}, Created On: {user['CreateDate']}")