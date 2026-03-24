variable "enable_cloudwan" {
  description = "Enable the Cloud WAN module. Keep this false for LocalStack runs because Network Manager / Cloud WAN is not covered in the LocalStack service coverage docs."
  type        = bool
  default     = false
}
