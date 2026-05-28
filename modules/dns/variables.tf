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
