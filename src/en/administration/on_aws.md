# Installing on AWS

> ⚠️ **Disclaimer:** this installation method is not recommended by the Lemmy developers. If you have any problems, you need to solve them yourself or ask the respective authors. If you notice any Lemmy bugs on an instance installed like this, please mention it in the bug report.

## Lemmy AWS CDK

This contains the necessary infrastructure definitions to deploy [Lemmy](https://github.com/LemmyNet/lemmy)
to AWS using their [Cloud Development Kit](https://docs.aws.amazon.com/cdk/latest/guide/home.html).

### Included:

* ECS fargate cluster
  * Lemmy-UI
  * Lemmy
  * Pictrs
* CloudFront CDN
* EFS storage for image uploads
* Aurora Serverless Postgres DB
* Bastion VPC host
* Load balancers for Lemmy
* DNS records for your site

## Quickstart

Clone the [Lemmy-CDK]( https://github.com/jetbridge/lemmy-cdk). 

Clone [Lemmy](https://github.com/LemmyNet/lemmy) and [Lemmy-UI](https://github.com/LemmyNet/lemmy-ui) to the directory above this.

```shell
cp example.env.local .env.local
# edit .env.local
```

You should edit .env.local with your site settings.

```shell
npm install -g aws-cdk
npm install
cdk bootstrap
cdk deploy
```

## Cost
This is *not* the cheapest way to run Lemmy. The Serverless Aurora DB can run you ~$90/mo if it doesn't go to sleep.

## Useful CDK commands

* `npm run build`   compile typescript to js
* `npm run watch`   watch for changes and compile
* `npm run test`    perform the jest unit tests
* `cdk deploy`      deploy this stack to your default AWS account/region
* `cdk diff`        compare deployed stack with current state
* `cdk synth`       emits the synthesized CloudFormation template
