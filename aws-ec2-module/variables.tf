variable "name" {
  description = "Prefix to use for resources name"
  default     = "InterProInvest-job-ec2-scheduler"
}

variable "stopstart_tags" {
  description = "Activate STOP/START for EC2 with the following tag"
  default = {
    TagKEY   = "stop/start"
    TagVALUE = "enabled"
  }
}

variable "start_cron_schedule" {
  description = "Cron Expression when to START Servers in UTC Time zone"
  default     = "cron(00 07 ? * MON-FRI *)"
}

variable "stop_cron_schedule" {
  description = "Cron Expression when to STOP Servers in UTC Time zone"
  default     = "cron(00 17 ? * MON-FRI *)"
}


variable "common_tags" {
  description = "Tags to apply to resources"
  default = {
    Developer = "A_Chebanov"
    Company   = "InterProInvest"
  }
}
