# aws-nzism

Deploys the AWS
[Operational Best Practices for NZISM](https://docs.aws.amazon.com/config/latest/developerguide/operational-best-practices-for-nzism.html)
conformance pack using [Terraform](https://www.terraform.io/). See the AWS Config
[conformance packs documentation](https://docs.aws.amazon.com/config/latest/developerguide/conformance-packs.html) for background.

## Deployment

As well as deploying the conformance pack, this sample can create the prerequisite AWS Config
[configuration recorder](https://docs.aws.amazon.com/config/latest/developerguide/stop-start-recorder.html)
if you don't already have one. To do this, in [terraform.tfvars](terraform.tfvars) set `create_recorder` to
`true` and `bucket_name` to the name of a new
[S3 delivery bucket](https://docs.aws.amazon.com/config/latest/developerguide/manage-delivery-channel.html)
to create. If `create_recorder` is set to `false` then you must have your own recorder running before you deploy.

The sample pack templates aren't directly available in S3, so before deployment you need to copy the template
to your own S3 bucket. For example, use the [AWS CLI](https://aws.amazon.com/cli/):
```
git clone https://github.com/awslabs/aws-config-rules.git
aws s3 cp aws-config-rules/aws-config-conformance-packs/Operational-Best-Practices-for-NZISM.yaml s3://my-bucket/nzism.yaml
```

In [terraform.tfvars](terraform.tfvars) set `template_s3_uri` to the URI of the uploaded template, `s3://my-bucket/nzism.yaml`
in this example.

To deploy, run:
```
terraform init
terraform apply
```

To uninstall, empty the delivery bucket if you deployed with `create_recorder=true`, then run:
```
terraform destroy
```

## Conformance Pack Parameters

Although this sample doesn't do it, you can also set input parameters for the conformance pack. To do this,
review the `input_parameter` section in the
[Terraform docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_conformance_pack)
then edit [main.tf](main.tf) as needed.
