terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 4.6.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_network" "private_network" {
  name = "my_network"
}

resource "docker_volume" "shared_volume" {
  name = "shared_volume"
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "tutorial"
  ports {
    internal = 80
    external = 8354
  }
  networks_advanced {
    name = docker_network.private_network.name
  }
  volumes {
    volume_name    = docker_volume.shared_volume.name
    container_path = "/usr/share/nginx/html"
    read_only      = false
  }
}
