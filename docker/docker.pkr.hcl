variable "ph_version" {
	type		= string
}

locals {
	rubies = [
		{
			name 	= "ph-r237"
			image = "ruby:2.3.7-alpine3.8"
			tag 	= "${var.ph_version}-ruby2.3.7"
		},
		{
			name 	= "ph-r270"
			image = "ruby:2.7.0-alpine3.8"
			tag 	= "${var.ph_version}-ruby2.7.0"
		},
		{
			name 	= "ph-r317"
			image = "ruby:3.1.7-alpine3.8"
			tag 	= "${var.ph_version}-ruby3.1.7"
		},
		{
			name 	= "ph-r339"
			image = "ruby:3.3.9-alpine3.8"
			tag 	= "${var.ph_version}-ruby3.3.3"
		},
		{
			name 	= "ph-r347"
			image = "ruby:3.4.7-alpine3.8"
			tag 	= "${var.ph_version}-ruby3.4.7"
		}
	]
}

variable "repo" {
	type		= string
	default = "path_helper"
}

source "docker" "ph-general" {
  commit  = true
	changes = [
		"ENV PATH_HELPER_DOCKER_INSTANCE=true",
		"WORKDIR /root",
		"ENTRYPOINT [\"spec/shell_spec.sh\"]"
	]
}

source "docker" "ph-r270" {
  commit  = true
	changes = [
		"ENV PATH_HELPER_DOCKER_INSTANCE=true",
		"WORKDIR /root",
		"ENTRYPOINT [\"spec/shell_spec.sh\"]"
	]
}


build {
	#	sources = ["source.docker.ph-r270","source.docker.ph-r237"]
	source "source.docker.ph-general" {
		name		=	"ph-r270"
		image   = "ruby:2.7.0-alpine3.11"
	}
	source "source.docker.ph-general" {
		name		=	"ph-r237"
		image   = "ruby:2.3.7-alpine3.8"
	}

	provisioner "file"{
		source			= "spec"
		destination = "/tmp/spec"
	}
	provisioner "file" {
		source			=	"docker/assets/.ashenv"
		destination	=	"/tmp/.ashenv"
	}
	provisioner "file" {
		source			= "exe"
		destination = "/tmp/exe"
	}
	provisioner "file"{
		source			= "docker/assets/etc-paths"
		destination = "/tmp/etc-paths"
	}
  provisioner "shell" {
    script = "docker/install.sh"
  }

	post-processors {
		post-processor "docker-tag" {
			repository	=	"${var.repo}"	
			tag					= ["${var.ph_version}-${source.name}"]
		}
	}
}
