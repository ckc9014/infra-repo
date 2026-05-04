project_name = "project-1"
environment  = "dev"
azs          = ["eu-west-1a", "eu-west-1b"]
private_subnets = ["10.0.5.0/24", "10.0.6.0/24", "10.0.7.0/24"]
public_subnets  = ["10.0.105.0/24", "10.0.106.0/24", "10.0.107.0/24"]
node_instance_types = ["g4dn.xlarge"]
desired_size    = 3