# List of mini AWS projects created using Terraform

## Project 1 - Hosting a website on AWS S3 by [techwithlucy](https://github.com/techwithlucy/youtube/blob/main/5-mini-aws-projects.md)

- Two options available: Routing to website using Route53 or by using CloudFront to cache website.
- Assumes that custom domain name is already registered on Route53.
- Website template obtained from [here](https://www.free-css.com/free-css-templates/page294/troweld)
- Option 1: Using Route 53 (NOT RECOMMENDED)
    - Setup is easier and faster, but there is an obvious security loophole as website is open to public
    - HTTPS not supported on S3.
    - To prevent mismatch in NS: **Get `data` of existing one instead of creating a new hosted zone.**

- Option 2: Caching website using CloudFront
    - Basic setup instructions on the AWS console found [here](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/GettingStarted.SimpleDistribution.html)
    - Turns out that I needed to create extra records on my Route53 Hosted Zone that corresponds to the CNAME of the certificate in ACM.
        - [Official AWS Resource for DNS validation](https://docs.aws.amazon.com/acm/latest/userguide/dns-validation.html)
        - Referred to Terraform documentation for the [validation of ACM certificates](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation)
    - [Using OAC to restrict access to S3](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html)
    - Browser cache might need clearing if webpage still cannot be accessed
    
## Project 2 - Creating a serverless solution to operate a DynamoDB table using API Gateway and Lambda by [Saha Rajdeep](https://github.com/saha-rajdeep/serverless-lab)

- 

