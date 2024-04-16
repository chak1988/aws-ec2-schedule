# AWS EC2 Scheduler to Manage EC2 Instances (START/STOP)

## Terraform main.tf will deploy:
 - 2 Lambda Functions to Start/Stop EC2 Instances with specific Tag
 - 2 EventBridge Rule to Start/Stop EC2 Instances by CRON schedule
 - 2 CloudWatch Log Group for Lambda Start/Stop EC2
 - IAM Role + IAM Policy to /Stop/Start/Describe EC2

Cron Expression examples:
 * https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-create-rule-schedule.html
 * https://docs.aws.amazon.com/lambda/latest/dg/services-cloudwatchevents-expressions.html

Examples of cron expression:
```
start_cron_schedule = "cron(00 07 ? * MON-FRI *)"  # Start Servers at 10:00 by Kyiv time-zone every working day.
stop_cron_schedule  = "cron(00 17 ? * MON-FRI *)"  # Stop  Servers at 20:00 will stop by Kyiv time-zone every working day.
```
## How to use as a module by default

module "aws-ec2-schedule" {
  source = "../aws-ec2-module"
}

OR

module "aws-ec2-schedule" {
  source              = "git::https://github.com/your-git-username/your-repository-name.git"
}

## How to use as a module  with your own variables
 module "aws-ec2-schedule" {
  source              = "git::https://github.com/your-git-username/your-repository-name.git"
  start_cron_schedule = "cron(00 07 ? * MON-FRI *)"
  stop_cron_schedule  = "cron(00 17 ? * MON-FRI *)"
  stopstart_tags = { TagKEY: "some_key", TagVALUE: "some_value"}
  name = "company_example_job"
  common_tags = {CompanyName : "SomeName", KeyTag : "KeyValue"}
}