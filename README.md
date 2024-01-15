In this project, I configure a Cloud Storage bucket to host a static website on GCP.

In the `version_1/infra` folder I set up all the necessary resources one by one with SSL certificate.

In the `version_2/infra` folder I use the [`cloud-foundation-fabric`](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/master/modules) modules to set up the resources. 

During this project, I used the following APIs and Services:
- Google Cloud Storage bucket
- Cloud CDN
- External App Load Balancer
- Cloud DNS

I deploy the website through a CI/CD pipeline and I use a remote backend for the tf_state file which is managed by Gitlab!

The same website can be found on:
https://lakatostomi.github.io/

I have deployed a Web App on GCP which is available on:
https://github.com/lakatostomi/rest-api-on-gcp