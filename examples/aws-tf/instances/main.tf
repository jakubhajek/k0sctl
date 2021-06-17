resource "random_id" "worker_node_id" {
  byte_length = 2
  count       = var.worker_count
}
resource "random_id" "controller_node_id" {
  byte_length = 2
  count       = var.controller_count

}
# get the proper AMI
data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]

  }
}

resource "tls_private_key" "k0sctl" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "cluster-key" {
  key_name   = format("%s_key", var.cluster_name)
  public_key = tls_private_key.k0sctl.public_key_openssh
}

// Save the private key to filesystem
resource "local_file" "aws_private_pem" {
  file_permission = "600"
  filename        = format("%s/%s", path.module, "aws_private.pem")
  content         = tls_private_key.k0sctl.private_key_pem
}

resource "aws_instance" "cluster-workers" {
  count                  = var.worker_count
  ami                    = data.aws_ami.server_ami.id
  instance_type          = var.cluster_flavor
  key_name               = aws_key_pair.cluster-key.key_name
  vpc_security_group_ids = [var.public_sg]
  user_data = templatefile(var.user_data_path, {

    nodename = "worker-${random_id.worker_node_id[count.index].dec}"
    }
  )
  subnet_id                   = var.public_subnets[count.index]
  associate_public_ip_address = true
  source_dest_check           = false
  root_block_device {
    volume_type = "gp2"
    volume_size = 20
  }
  tags = {
    Role                                    = "worker"
    Name                                    = "worker-${random_id.worker_node_id[count.index].dec}"
    "kubernetes.io/cluster/your_cluster_id" = "owned"
  }
}

resource "aws_instance" "cluster-controller" {
  count                  = var.controller_count
  ami                    = data.aws_ami.server_ami.id
  instance_type          = var.cluster_flavor
  key_name               = aws_key_pair.cluster-key.key_name
  vpc_security_group_ids = [var.public_sg]
  user_data = templatefile(var.user_data_path, {
    nodename = "controller-${random_id.controller_node_id[count.index].dec}"
    }
  )

  subnet_id                   = var.public_subnets[count.index]
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp2"
    volume_size = 10
  }
  tags = {
    Role                                    = "controller"
    Name                                    = "controller-${random_id.controller_node_id[count.index].dec}"
    "kubernetes.io/cluster/your_cluster_id" = "owned"
  }
}
