variable "domain" {
  type        = string
  description = "The domain associated with the hosted zone being signed"
}

variable "zone_id" {
  type        = string
  description = "The Route 53 hosted zone ID to enable DNSSEC on"
}
