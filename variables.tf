variable "region" {
  description = "AWS regio"
  type = string
}

variable "mongo_public_key" {
    type = string
}
variable "mongo_private_key" {
    type = string
}

variable "lambda_role_name" {
  description = "SQS Lambda IAM Role name"
  type = string
}

variable "cluster_name" {
  description = "Mongo DB cluster name"
  type = string
}

variable "org_id" {
  description = "MongoDB Atlas Organization ID"
  type        = string
}

variable "project_name" {
  description = "MongoDB Atlas project name"
  type        = string
}

variable "project_id" {
  description = "MongoDB Atlas project ID"
  type        = string
}

variable "db_user" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database user password"
  type        = string
}

variable "database_name" {
  description = "Database name for user permissions"
  type        = string
}

variable "ip_address" {
  description = "IP Address of the NAT Gateway"
  type        = string
}

variable "connection_string" {
  description = "Mongo DB connection string"
  type        = string
}

variable image_tag {
  description = "Docker image version tag"
  type = string
}
