# Building beanstalk for UCLDC Solr index

The solr index that powers the Calisphere website is hosted on the AWS Elasticbeanstalk platform.

The CNAME solr.calisphere.org points to https://ucldc-solr.us-west-2.elasticbeanstalk.com, whichever beanstalk environment which is at this address will be the server for our search requests.

The beanstalk is hosted in the Oregon (us-west-2) AWS region. The application name is ucldc-solr. Currently it runs on only one micro ec2 instance.

The process to create a new production index is as follows:

1. push the index to S3
2. clone the existing environment
3. in the cloned environment, set the env var INDEX_PATH to the new index sub-path in S3
4. Rebuild the cloned environment
5. check that the cloned environment is serving up the new index
6. Swap URLs from existing environment to the new cloned environment

This will put in place the new index.

Generally, I then rebuild the original environment and swap back so the name of the environment remains `ucldc-solr`. Not really necessary but makes it a bit easier to remember what's what.

## Step 1
To push a new index to S3, first run `/usr/local/bin/solr-index-to-s3.sh` on the production environment majorTom instance. You can look at the log at `/var/local/solr-update/log/solr-index-to-s3-YYYYMMDD_HHMMSS.out`. Find the `s3_file_path` reports it will be something like: `"s3_file_path": "s3://solr.ucldc/indexes/production/2016/06/solr-index.2016-06-21-19_53_40.tar.bz2"`. Take the part from the year on ( 2016/06/solr-index.2016-06-21-19_53_40.tar.bz2 ) as the input to the command to clone the existing environment.

## Steps 2-4
The script `clone-with-new-s3-index.sh` will do steps 2 to 4 above.

First, check what environments are running:
```shell
eb list
```

Edit the new-beanstalk.env file. The ENV_NAME is the source environment to clone, NEW_ENV_NAME is the name of the new cloned environment. API_KEY is our api access key. Source this to get the values of the env vars set `. new-beastalk.env` Now run
```shell
./clone-with-new-s3-index.sh <new index path>
```
where the new index path is from Step #1.

This command will take a good while.
When it finishes, you should be able to run:
```shell
eb printenv <NEW_ENV_NAME>
```

and see that INDEX_PATH is updated to the value passed to the script.

## Step 5
Check the new environments URL for the proper search results. Run 
```shell
cname_for_env.sh <environment name>
```
This will tell you what URL the environment is associated with.
You can check that the URL is up by running:
```shell
./check_solr_api_for_env.sh <environment name>
```

## Step 6
Swap URLs from the existing environment to the new cloned environment running the updated solr index.
First, check what environment has the ucldc-solr.us-west-1.elasticbeanstalk.com CNAME:
```shell
eb status <env name>
```

If both look right, swap the URLs and the new index will be live

```shell
eb swap -n <destination environment> <source environment>
eb swap -n ucldc-solr-1 ucldc-solr
```


## Updating the ucldc-solr environment
I have been then updating the ucdlc-solr environment and then swapping the url back, so that the environment we have up is always named "ucldc-solr", but this is not required. The important thing is that the ucdlc-solr.us-west-2.elasticbeanstalk.com/solr/query URL works.
