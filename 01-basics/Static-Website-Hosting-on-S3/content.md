The standard way to reference a resource attribute is using dot notation:<RESOURCE_TYPE>.<RESOURCE_NAME>.<ATTRIBUTE>
Example: aws_vpc.main.id refers to the id attribute of an aws_vpc resource named

Basic SyntaxStandard Interpolation: Enclose a reference or expression in ${} within a quoted string.

referencing Variables:
Access input variables using var.<NAME>.Example: "Environment: ${var.env_type}
"Resource Attributes: Reference attributes from other resources.Example:
"Subnet ID is ${aws_subnet.example.id}
"Calling Functions: Execute built-in functions inside the interpolation.
Example: "Upper Case: ${upper(var.name)}"
Arithmetic Operations: Perform basic math like addition or subtraction.Example: "Index is ${count.index + 1}"



data :

Does NOT create anything.

It only:

reads
fetches
generates
looks up existing information

Terraform outputs act like return values for your infrastructure, allowing you to highlight important information (like IP addresses or DNS names) after a deployment
output "instance_ip" {
  value       = aws_instance.web.public_ip
  description = "The public IP address of the web server."
}
