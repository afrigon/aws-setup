variable "region" {
  type        = string
  description = "The target aws region"
  default     = "us-east-1"
}

variable "github" {
  type = object({
    owner      = string
    repository = string
  })
  description = "The owner of the target github repository"
}
