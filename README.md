# AWS Multi-VPC Infrastructure for Web Application

## Overview
This project provides a secure and scalable web application infrastructure on AWS. It uses **Terraform** to provision resources, ensuring Infrastructure-as-Code (IaC) principles are applied. The architecture is divided into two VPCs to segregate application-specific resources and shared resources, with secure connectivity and automated provisioning.

---

## Features

### Infrastructure
- **Two VPCs**:
  - **VPC-Dev**: Hosts the web servers and application-related resources.
  - **VPC-Shared**: Contains shared resources like the MySQL database and Bastion Host.
- **High Availability**:
  - Public and private subnets in multiple Availability Zones.
- **Routing Configuration**:
  - Public subnets with Internet Gateways for external access.
  - Private subnets with NAT Gateways for secure outbound access.
- **Secure Communication**:
  - VPC Peering between VPC-Dev and VPC-Shared for cross-VPC communication.
  - S3 VPC Endpoint for private connectivity to S3 buckets.
- **Security**:
  - Security groups configured for granular inbound and outbound traffic control.
- **Application Load Balancer (ALB)**: Exposes the application to the internet.
- **Bastion Host**: Provides secure SSH access to instances in private subnets.
- **S3 Bucket**: Stores application assets, accessible via VPC Endpoint.

### Compute Instances
- **Web Servers**: Two EC2 instances running Docker in private subnets.
- **Database Server**: MySQL database hosted on an EC2 instance in a private subnet.
- **Bastion Host**: Secure SSH access point to private resources.

### Design
- Automated infrastructure deployment using Terraform.
- Secure VPC design with controlled ingress and egress rules.
- Containerized Python web application deployed via Docker and stored in Amazon ECR.
- ALB configuration for high availability.
- Private S3 bucket access using IAM roles and VPC Endpoint.
- MySQL database connectivity from web servers.


---

## Architecture Diagram
![image](https://github.com/user-attachments/assets/3a944be9-8fc1-4783-8333-8a87ca9761be)


---

## Technologies Used
- **Terraform**: Infrastructure as Code tool for AWS resource provisioning.
- **AWS Services**:
  - EC2
  - VPC
  - S3
  - NAT Gateway
  - Internet Gateway
  - VPC Peering
  - Route Tables
- **Docker**: For containerizing and deploying the web application.
- **Bash Scripts**: For automating the setup of infrastructure and software.

---

## Project Structure
```plaintext
.
├── main.tf               # Terraform configuration file for infrastructure
├── README.md             # Documentation
├── my-local-app          # Placeholder for application source code
├── dockerfile            # to build the image from it 
├── requirements.txt      # contain the Flask web framework as a reference to the dockerfile
```

---

## **Setup Instructions**

### **Prerequisites**
- **Terraform** (v1.x or higher) installed.
- AWS CLI configured with valid credentials.
- An existing SSH key pair (`vockey`) in AWS.
- Docker installed locally for testing (if required).

## **Infrastructure Deployment**
1. Clone the repository:
   ```bash
   git clone git@github.com:ismailsamyy/AWS_Project.git
   cd AWS_Project
2. Initialize Terraform::
   ```bash
   terraform init
3. Review and apply the configuration:
   ```bash
   terraform apply
   ```
   Confirm the changes by typing yes. This will provision the infrastructure.

4. Create Application Load Balancer
   - Create Target Group and add Webserver 1 and webserver 2 to it
   - Deploy the Application Load Balancer in the VPC-DEV , and select the two public subnets in the two availability zones (AZs).
   - Attach the ALB-SG security group (created by the Terraform script) to the Application Load Balancer
   - Add a listener on HTTP (port 80) and configure it to forward traffic to the previously created Target Group

5. Accept the Peering Connection:
   - In the VPC section, go to the Peering Connections section.
   - Find the Dev-to-Shared-Peering connection, click on it, and from the dropdown actions, select Accept.
   - This request was made by the Terraform script to link the two VPCs.
  
---

## **Application Deployment**

1. **SSH into the Bastion Host**  
   First, establish an SSH connection to the Bastion host.

2. **SSH from the Bastion Host to WebSERVER 1 or 2**  
   Next, SSH into either WebSERVER 1 or WebSERVER 2 from the Bastion host.

3. **Install Docker on the Webserver and Build the Docker Image**  
   On the Webserver, install Docker and build the Docker image from the `Dockerfile` and `requirements.txt` provided earlier:
   ```bash
   sudo yum install docker
   sudo systemctl start docker
   sudo docker build -t my-python-app .

4. Create a Local Directory on the Webserver and Copy Application Files
Create a local directory (my-local-app) on the webserver and copy the contents of the provided my-local-app directory into it: 
    ```bash
   mkdir my-local-app
5. Upload the Image to an S3 Bucket and Copy It to the Local Directory
Upload the snake image to the S3 bucket and get its URL. Ensure that the EC2 instance has access to the S3 bucket by attaching the appropriate IAM role. After that, copy the image from the S3 bucket to the local directory: 
    ```bash
   aws s3 cp s3://my-private-bucket/cat.jpg /home/ec2-user/my-local-app/static/

6. Run the Docker Container
Run the Docker container, ensuring it listens on port 80 and syncs the local directory (my-local-app) with the /app directory inside the container:
    ```bash
   sudo docker run -d -p 80:80 -v ~/my-local-app:/app my-python-app
7. Test the Application
Verify the deployment by copying the DNS name of the Application Load Balancer and pasting it into your browser. You should see the application running.
![image](https://github.com/user-attachments/assets/20e73fe8-3b7e-4b19-a976-c4c616cbd810)


    



