In this project I configure a Cloud Storage bucket to host a static website on GCP.

In `version_1/infra` folder I set up all the neccessery resources one-by-one with SSL certificate.

In `version_2/infra` I use the [`cloud-foundation-fabric`](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/master/modules) modules to set up the resources. 

During this project I use the following APIs and Services:
- Google Cloud Storage bucket
- Cloud CDN
- External App Load Balancer
- Cloud DNS

The same website can be found on:
https://lakatostomi.github.io/

I have deployed a Web App on GCP which is avalaible on:
https://github.com/lakatostomi/rest-api-on-gcp