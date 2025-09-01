/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

variable "metadata" {
  type = any
}

variable "project" {
  type = string
}

/*----------------------------------------------------------------------*/
/* RDS Aurora | Variable Definition                                     */
/*----------------------------------------------------------------------*/

variable "rds_aurora_parameters" {
  type        = any
  description = ""
  default     = {}
}

variable "rds_aurora_defaults" {
  description = "Map of default values which will be used for each item."
  type        = any
  default     = {}
}
