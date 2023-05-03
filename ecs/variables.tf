variable "project" {
  type = string
  default = "age"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "createdBy" {
  type = string
  default = "Northbay"
}

variable "ecsCpu" {
  type = number
  default = 0.5
  description = "Number of cpu units used by the task. If the requires_compatibilities is FARGATE this field is required"
}

variable "ecsMemory" {
  type = number
  default = 512
  description = "Amount (in MiB) of memory used by the task. If the requires_compatibilities is FARGATE this field is required"
}

variable "ecsTaskExecutionRoleArn" {
  type = string
  description = "ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume"
}

variable "ecsContainerPort" {
  type = number
  default = 80
  description = "Port required for port mapping in containers"
}

variable "ecsReplicas" {
  type = number
  default = 1
  description = "Number of containers to run"
}

variable "ecsTaskSecurityGroupIds" {
  type = list(string)
  description = "List of security group Ids to be associated with ECS Tasks"
}

variable "ecsTaskSubnetIds" {
  type = list(string)
  description = "List of subnet Ids to be associated with ECS Tasks"
}

variable "ecsTargetGroupId" {
  type = string
  description = "Target Group Ids for ECS Service"
}

variable "ecsAutoscaleMinInstances" {
  type = number
  default = 1
  description = " The minimum number of containers that should be running"
}

variable "ecsAutoscaleMaxInstances" {
  type = number
  default = 2
  description = "The maximum number of containers that should be running."
}

variable "ecsLogsRetentionInDays" {
  type        = number
  default     = 7
  description = "Specifies the number of days you want to retain log events"
}

variable "ecsRegion" {
  type = string
  default = "us-west-1"
  description = "AWS Region in which ECS is created"
}

variable "ecsDefaultDockerImage" {
  default = ""
  description = "The default docker image to use"
}

variable "ecsAutoScalingLowerThreshold" {
  type = number
  default = 20
  description = "Minimum threshold value to scale down"
}

# If the average CPU utilization over a minute rises to this threshold,
# the number of containers will be increased (but not above ecs_autoscale_max_instances).
variable "ecsAutoScalingUpperThreshold" {
  type = number
  default = 80
  description = "Maximum threshold value to scale up"
}