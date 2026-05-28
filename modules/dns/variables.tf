variable "domain" {
  type        = string
  description = "The domain associated with this zone"
}

variable "email_configuration" {
  type = object({
    mxa  = string
    mxb  = string
    spf  = string
    dkim = string
  })
  description = "The email related records for this zone"
  default     = null
}

variable "is_aws_domains" {
  type        = bool
  description = "Whether this domain is registered through Route 53 Domains. When true, the module manages the registrar's nameservers and publishes the DNSSEC DS record."
  default     = false
}
