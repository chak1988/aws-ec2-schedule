
module "aws-ec2-schedule-log" {
  source              = "../aws-ec2-module"
  start_cron_schedule = "cron(00 07 ? * MON-FRI *)"
  stop_cron_schedule  = "cron(00 17 ? * MON-FRI *)"
  stopstart_tags      = { TagKEY : "log-collector-servers", TagVALUE : "enabled" }
}


module "aws-ec2-schedule-cleaner" {
  source              = "../aws-ec2-module"
  start_cron_schedule = "cron(00 10 ? * SAT-SUN *)"
  stop_cron_schedule  = "cron(00 12 ? * SAT-SUN *)"
  stopstart_tags      = { TagKEY : "cleaner-jobs", TagVALUE : "enabled" }
}
