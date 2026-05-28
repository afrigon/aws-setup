variable "name" {
  type        = string
  description = "The name of the role"
}

variable "state_bucket" {
  type        = string
  description = "The name of the terraform state s3 bucket"
}

variable "github" {
  type = object({
    owner      = string
    repository = string
  })
  description = "The owner of the target github repository"
}

variable "permissions" {
  type = list(object({
    actions   = list(string)
    resources = list(string)
    effect    = optional(string, "Allow")
  }))
  description = "The iam permission to inline on this role"
  default     = []
}
