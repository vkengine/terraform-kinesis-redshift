# Kinesis-redshift

[comment]: <> ([![Build Status][build_status_badge]][build_status_link])

[comment]: <> ([![PyPI version][pypi_badge]][pypi_link])

This project builds infrastructure that stores important information transmitted from 
front-end and sinks to Redshift cluster. 
Tracking endpoint receives the data from front-end and 
stores it in a Kinesis stream (or SQS) as JSON. 
It follows the [3 basic principles of streaming data](streaming_key_components.md)


- [System Design](#system-design)
- [System Requirements](#system-requirements)
- [Repo Structure](#repo-structure)
- [Getting Started](#getting-started)



## System Design
The solution is based on AWS services.

* **Requirements :** 
    * The Kinesis stream (or SQS) and Redshift cluster reside in different AWS accounts, and we don't want to make Redshift publicly accessible.
    * The architecture of the pipeline should allow re-importing records to Redshift.
    * The volume of events in Kinesis stream (or SQS) is approximately 1 million per hour, but we should be able to scale the pipeline if volume increases.


* **High Level Design(HLD) :**
    * Using Resource-based policies and AWS Identity and Access Management (IAM) policies for programmatic-only access to S3 bucket objects
    * parametrizing copy job to accept partition in s3 bucket
    * leveraging the Amazon Redshift massively parallel processing (MPP)


* **Low Level Design(LLD) :**
    * kinesis firehose writes to s3 bucket in s3 bucket in an _account A_ and Redshift cluster residing in _account B_ 
      has role has permission to get object from _account A_. for more information read :
      [cross-account-access-s3](https://aws.amazon.com/premiumsupport/knowledge-center/cross-account-access-s3/)
    * A lambda running a copy job in _account B_ with same role as described above is run periodically 
      that can read from the buckets and as kinesis stream partitions the data in a bucket
      we can leverage this to point load job (copy command) to a specific partition, or a bunch of partitions to 
      re-import ( **_Airflow comes really handy in such cases with super easy to use user interface, look for a dag run and clear the tasks_** )
    * This is straight forward the more the number of nodes the more data can be loaded to Redshift.
      read : [Parallel processing](https://docs.aws.amazon.com/redshift/latest/dg/t_splitting-data-files.html)
      
## System Requirements
```
Terraform >= v1.0.6
Python >= v3.0.0
```
At the time of development the latest version of terraform was v1.0.6
and backward/forward compatibility is solely dependent on a provider(in this case HashiCorp)

    
## Repo Structure
```
Project/
|-- infrastructure (all terraform script)/
|   |-- account_a(resources specific to account a)
|   |-- account_b(resources specific to account b)    
|
|-- lambda/
|   |-- write_to_k_stream (dummy file to generate some data)
|   |-- load to reshift
|
|-- makefile
|-- README
```

## Getting Started
create these two files in project root :
* .env
```
this should from account a with s3 access
access_key_id=<your_value>
secret_access_key=<your_key>
```
* build.tfvars
```
redshift_master_username = <your_username>
redshift_mastr_password = <your_password>
```

1. To create Infra:
```make create-infra```
   
2. to create some dummy data:
```make create-infra```
   
3. To destroy infra:
```make destroy```
   

# TODO :
* lambda deployment - terraform (minor)
* parmetrize lambda - to look for file in a bucket with provided keys (major)
* script to scale up scale down redshift cluster (major - outside scope of this project)
* fix readme (minor)

