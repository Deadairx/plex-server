provider "aws" {
    region = "us-west-2" # Can change later
}

locals {
    plex_port = "32400"
}

resource "aws_security_group" "plex_sg" {
    name = "plex-security-group"
    description = "Security group for Plex"

    ingress {
        from_port = local.plex_port
        to_port = local.plex_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # Change to your IP for Security
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # Change to your IP for Security
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "plex_server" {
    ami = "ami-0c94855ba95b798c7" # Supposedly Ubuntu 20.04 LTS, should update to latest
    instance_type = "t2.micro" # change to instance type

    key_name = "plex-key" # Replace

    subnet_id = "subnet-xxxxxxxxxxxxxxx" # Replace

    vcp_security_group_ids = [aws_security_group.plex_sg.id]

    tags = {
        Name = "plex-server"
    }
    user_data = <<-EOF
        #!/bin/bash
        sudo apt update && sudo apt upgrade -y
        sudo apt install -y apt-transport-https curl gnupg2
        echo "deb https://downloads.plex.tv/repo/deb/ public main" | sudo tee /etc/apt/sources.list.d/plexmediaserver.list
        curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add -
        sudo apt update
        sudo apt install -y plexmediaserver
        sudo systemctl start plexmediaserver
        sudo systemctl enable plexmediaserver
    EOF
}
