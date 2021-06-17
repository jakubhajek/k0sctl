locals {
  vpc_cidr = "10.11.0.0/16"
}

locals {
  security_groups = {
    public = {
      name        = "public_sg"
      description = "Security Group for Public Access"
      ingress = {
        ssh = {
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
        }
        http = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
        }
        etc_peers = {
          from        = 2380
          to          = 2380
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }
        kube-api-server = {
          from        = 6443
          to          = 6443
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
        }
        calico = {
          from        = 4789
          to          = 4789
          protocol    = "udp"
          cidr_blocks = [local.vpc_cidr]
        }
        kublet = {
          from        = 10250
          to          = 10250
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }

        k0s-api = {
          from        = 9443
          to          = 9443
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }
        k0s-api = {
          from        = 9443
          to          = 9443
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }
        konnectivity = {
          from        = 8132
          to          = 8133
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }
        test-port = {
          from        = 30800
          to          = 30805
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }


      }
    }
  }

  k0s_tmpl = {
    apiVersion = "k0sctl.k0sproject.io/v1beta1"
    kind       = "cluster"
    spec = {
      hosts = [
        for host in concat(module.instances.cluster-controller, module.instances.cluster-workers) : {
          ssh = {
            address = host.public_ip
            user    = "ubuntu"
            keyPath = "aws_private.pem"
          }
          role = host.tags["Role"]
        }
      ]
      k0s = {
        version = "0.13.1"
      }
    }
  }

}
