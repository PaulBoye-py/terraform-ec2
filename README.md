# AWS Infrastructure Setup with Terraform

This Terraform project sets up a simple AWS infrastructure with a Virtual Private Cloud (VPC), Internet Gateway, Route Table, Subnet, Security Group, Network Interface, Elastic IP, and an EC2 instance running a basic Apache web server.

## Prerequisites

- Terraform >= 1.2.0
- AWS Account
- AWS IAM User with programmatic access and required permissions
- AWS Key Pair for SSH access to the EC2 instance

## Project Structure

This Terraform project includes the following AWS resources:

- **VPC**: Virtual Private Cloud to isolate our infrastructure.
- **Internet Gateway**: To enable internet access.
- **Route Table**: Configured to route internet traffic to the Internet Gateway.
- **Subnet**: A subnet within the VPC for resource allocation.
- **Security Group**: Controls inbound and outbound traffic, allowing HTTP, HTTPS, and SSH access.
- **Network Interface**: A network interface in the subnet with a private IP.
- **Elastic IP**: A static IP address that is associated with the EC2 instance.
- **EC2 Instance**: Amazon Linux instance running Apache to serve a basic web page.

## Getting Started

### 1. Clone the repository

```bash
git clone <repository-url>
cd <repository-folder>
```

### 2. Create a `.tfvars` file

In the project root, create a file named `terraform.tfvars` and add your AWS credentials and configuration. Replace `<YOUR_ACCESS_KEY>` and `<YOUR_SECRET_KEY>` with your actual AWS Access Key and Secret Key.

```hcl
aws_access_key = "<YOUR_ACCESS_KEY>"
aws_secret_key = "<YOUR_SECRET_KEY>"
```

### 3. Initialize Terraform

Initialize the Terraform workspace to download the required provider plugins.

```bash
terraform init
```

### 4. Plan the infrastructure

Review the resources that will be created.

```bash
terraform plan
```

### 5. Apply the configuration

Run the following command to deploy the resources to AWS.

```bash
terraform apply
```

When prompted, type `yes` to confirm the infrastructure changes.

### 6. Access the Web Server

Once the infrastructure is deployed, you can access the web server using the public IP associated with the Elastic IP resource. Open a web browser and navigate to:

```bash
http://<Elastic-IP>
```

The page should display: **"Your very first web server"**

## Project Details

### Resources Created

- **VPC** (`aws_vpc.production-vpc`): A VPC with CIDR block `10.0.0.0/16`.
- **Internet Gateway** (`aws_internet_gateway.production-igw`): Enables internet access within the VPC.
- **Route Table** (`aws_route_table.production_route_table`): Routes traffic to the Internet Gateway.
- **Subnet** (`aws_subnet.subnet-1`): A subnet with CIDR block `10.0.1.0/24` in availability zone `us-east-1a`.
- **Security Group** (`aws_security_group.allow_web_traffic`): Allows inbound traffic on ports 22, 80, and 443.
- **Network Interface** (`aws_network_interface.web-server-nic`): Private IP interface in the subnet.
- **Elastic IP** (`aws_eip.prod-eip`): A public IP assigned to the EC2 instance.
- **EC2 Instance** (`aws_instance.web-server`): Amazon Linux instance with Apache installed, hosting a basic web page.

### User Data Script

The EC2 instance uses a User Data script to install and start Apache on launch:

```bash
#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
echo "Your very first web server" | sudo tee /var/www/html/index.html
```

## Cleanup

To avoid any unnecessary charges, destroy the resources once you’re done:

```bash
terraform destroy
```

Type `yes` to confirm.

## Troubleshooting

- **Error: Permission Denied**: Ensure your AWS credentials in `terraform.tfvars` are correct and that the IAM user has sufficient permissions.
- **Instance Access Issues**: Verify that your security group allows inbound SSH traffic (port 22) and that you're using the correct key pair.

## License

This project is licensed under the MIT License.

---

Happy Terraforming!
