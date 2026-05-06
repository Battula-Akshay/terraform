
# Terraform Variables – Complete Guide (Terraform Associate Exam)## 📌 What is a Variable?A Terraform variable is used to **parameterize infrastructure code**, making it reusable and dynamic instead of hardcoding values.---## 🎯 Why Use Variables?- Reusability (same code, different inputs)- Flexibility (dev, staging, prod)- Avoid hardcoding values- Improve collaboration- Secure sensitive data---##
 🧠 Types of Variables### 
 1. **Input Variables**
  "instance_type" {  type = string}
**Usage**:
var.instance_type

2. Output Values
output "instance_id" {  value = aws_instance.myec2.id}

3. Local Values
locals {  env = "dev"}
**Usage**:
local.env

⚠️ 2. Rules You MUST Follow
✔️ Allowed
Letters
Numbers
Underscores _
❌ Not Allowed
Spaces ❌ ("vpn ip")
Special characters ❌ ("vpn-ip", "vpn@ip")
Starting with numbers ❌ ("123vpn")

✔️ Yes, you can name variables anything
BUT:

Follow naming rules
Use meaningful names
Prefer snake_case
Always use var.<name> to access

Trap 1: Variable name ≠ variable value
variable "region" {}

Usage:

region = var.region

👉 var. is mandatory

❗ Trap 2: Case Sensitive
variable "Region" {}  ❌
variable "region" {}  ✔️

👉 Terraform treats them as different variables

❗ Trap 3: Undefined variable error
variable "vpn_ip" {}

If no default + no input → ❌ Terraform will ask input

❗ Trap 4: Wrong type
variable "count" {
  type = number
}

If you pass:

"two"

👉 ❌ Error

Add description (exam likes this)
variable "vpn_ip" {
  description = "IP address allowed to access VPN"
}
🔹 Always define type (VERY IMPORTANT)
variable "vpn_ip" {
  type = string
}
🔹 Add default if needed
variable "vpn_ip" {
  type    = string
  default = "0.0.0.0/0"
}
🔥 Root Cause

Terraform only auto-loads these filenames:

terraform.tfvars        ✅
*.auto.tfvars           ✅

👉 Your file:

variables.tfvars        ❌ NOT auto-loaded

That’s why Terraform is asking:

Enter a value:

⚠️ Variable Precedence (VERY IMPORTANT)
Order (Highest → Lowest):


CLI (-var, -var-file)


.auto.tfvars


terraform.tfvars


Environment variables (TF_VAR_)


Default value in .tf


Example:


default = t2.micro


tfvars = t2.small


CLI = t2.large


✅ Final value = t2.large

📦 Ways to Define Variables
1. Default Value
variable "instance_type" {  default = "t2.micro"}

2. terraform.tfvars
instance_type = "t2.small"

3. CLI
terraform apply -var="instance_type=t2.large"

4. Environment Variable
$env:TF_VAR_instance_type="t2.micro"

5. Prompt Input
If no default → Terraform asks input during execution.

🧪 Data Types
Primitive Types


string


number


bool


Complex Types


list(string)


map(string)


object({...})


set(string)


Example:
variable "instance_types" { 
 type = list(string)
 default = ["t2.micro", "t2.small"]
 }

🔁 Expressions with Variables
Conditional Expression
var.instance_type == "t2.micro" ? "cheap" : "costly"

🔄 Meta-Arguments Using Variables
count
count = var.create_instance ? 1 : 0
for_each
for_each = var.instance_map

🔐 Sensitive Variables
variable "password" {  type      = string  sensitive = true}

⚠️ Common Mistakes


❌ Forgetting var. prefix


❌ Wrong variable precedence


❌ Type mismatch (string vs number)


❌ Confusing var and local


❌ Uploading secrets to GitHub



🧠 Exam Traps
Trap 1: var vs local


var.x → external input


local.x → internal value


Trap 2: Precedence confusion
Trap 3: tfvars vs auto.tfvars


auto.tfvars loads automatically



📝 Sample Exam Questions
Q1:
Which has highest precedence?
A. default
B. tfvars
C. CLI
D. environment variable
✅ Answer: C

Q2:
How to reference variable?
A. ${instance_type}
B. var.instance_type
C. variable.instance_type
D. input.instance_type
✅ Answer: B

Q3:
Which file loads automatically?
A. vars.tf
B. terraform.tfvars
C. config.tf
D. state.tf
✅ Answer: B

📌 Revision Checklist


 var vs local


 Variable precedence


 tfvars vs auto.tfvars


 Data types


 CLI variables


 Environment variables


 Sensitive variables


 count / for_each



🚀 Final Notes


Always avoid hardcoding


Use variables for reusable infrastructure


Practice precedence scenarios


Use tfvars in real projects


