resource "aws_key_pair" "Bases1-key" {
  key_name   = "Bases"
  public_key = file("${var.PATH_PUBLIC_KEYPAIR}")
}

resource "aws_instance" "ec2_bastion" {
  ami                    = "ami-090fa75af13c156b4"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.Bases1-key.key_name
  vpc_security_group_ids = [aws_security_group.Bases1-sg.id]
  subnet_id              = aws_subnet.PublicS1.id
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install mysql -y",
      "mysql --version"
    ]
  }
  connection {
    host        = self.public_ip
    user        = var.user_ssh
    private_key = file("${var.PATH_KEYPAIR}")
  }
  depends_on = [
    aws_db_instance.mysql-instance
  ]
}

resource "aws_security_group" "Bases1-sg" {
  vpc_id = aws_vpc.Bases1.id
  name   = "Bases1-sg"
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    }
  ]
}

