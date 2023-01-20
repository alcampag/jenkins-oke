variable "compartment_id" {
}

variable "region" {
}

variable "container_repo_configs" {
    type = list(object({
        display_name = string
        is_public = bool
    }))
}