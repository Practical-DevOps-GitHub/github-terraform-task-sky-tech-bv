terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

# Define PAT
variable "var_PAT" {
  description = "Personal access token for sprint task"
  type        = string
  default     = "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"
  sensitive   = true
}
# Define variable with existing folder name
variable "repo_name" {
  description = "Try to give get access to existing repository"
  type        = string
  default     = "github-terraform-task-sky-tech-bv"
}
# Define variable with name of org owner
variable "repo_owner" {
  description = "Name of the owner to get access"
  type        = string
  default     = "Practical-DevOps-GitHub"
}

# Configure the GitHub Provider
provider "github" {
  token = var.var_PAT
  owner = var.repo_owner
}

# 1 Task 3: Make softservedata codeovner for main branch
resource "github_repository_file" "CODEOWNERS" {
  repository          = var.repo_name
  branch              = "main"
  file                = ".github/CODEOWNERS"
  content             = "* @softservedata"
  overwrite_on_create = false
}

# 2 Task 4: Creation pull-request template
resource "github_repository_file" "template" {
  repository          = var.repo_name
  branch              = "main"
  file                = ".github/pull_request_template.md"
  content             = "## Describe your changes\n\n## Issue ticket number and link\n\n## Checklist before requesting a review\n- [ ] I have performed a self-review of my code\n- [ ] If it is a core feature, I have added thorough tests\n- [ ] Do we need to implement analytics?\n- [ ] Will this be part of a product update? If yes, please write one phrase about this update"
  overwrite_on_create = true
}

# 3 Task: Add user softservedata like corraborator to our folder with maintain rules
resource "github_repository_collaborator" "add_collaborator" {
  repository = var.repo_name
  username   = "softservedata"
  permission = "maintain"
}


# 4 Task 2: Add branch with develop name
resource "github_branch" "develop" {
  repository = var.repo_name
  branch     = "develop"
}
# 5 Task 2: Make branch develop default-branch
resource "github_branch_default" "default" {
  repository = var.repo_name
  branch     = github_branch.develop.branch
}

# 6 Task 5: Add DEPLOY_KEY
resource "github_repository_deploy_key" "DEPLOY_KEY" {
  title      = "DEPLOY_KEY"
  repository = var.repo_name
  key        = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEK35xxRGWMCxgiuh8zUdwRlDVy8U2sFYENOIDGugry+"
  read_only  = "false"
}

# 7 Task 6: Create discord notification webhook
resource "github_repository_webhook" "discord_webhook" {
  repository = var.repo_name

  configuration {
    url          = "https://discord.com/api/webhooks/1137036962415530027/6hEGw6Q2YGKaGqEIFLsjxCtM2zG3tKz5rJ_2AHzT-YRAiFyvfXUNISYAaZNSeBAgj_4h/sprint9"
    content_type = "json"
    insecure_ssl = false
  }

  events = ["pull_request"]
}

# 8 Task 7: Add PAT to action secret
resource "github_actions_secret" "PAT" {
  repository       = var.repo_name
  secret_name      = "PAT"
  plaintext_value  = var.var_PAT
}

# 9 Task 3: Add protection rules to develop branch
resource "github_branch_protection_v3" "develop_protection" {
  repository = var.repo_name
  branch     = github_branch.develop.branch
  required_pull_request_reviews {
    required_approving_review_count = 2
  }
}

# 10 Task 3: Add protection rules to main branch
resource "github_branch_protection_v3" "main_protection" {
  repository = var.repo_name
  branch     = "main"
  required_pull_request_reviews {
    required_approving_review_count = 0
    require_code_owner_reviews      = true
  }
}
