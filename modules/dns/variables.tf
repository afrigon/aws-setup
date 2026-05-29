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

variable "update_registrar" {
  type        = bool
  description = "Whether to push this zone's nameservers to the Route 53 Domains registrar. Only applies to domains registered through Route 53 Domains."
  default     = false
}

variable "default_ttl" {
  type        = number
  description = "The default time to live for dns records"
  default     = 1800
}
