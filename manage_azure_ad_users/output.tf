output "guests_users" {
  value = local.guests_users
}

output "internal_users" {
  value = keys(local.internal_users)
}

output "users_by_projects" {
  value = { for p in toset(local.users_by_projects[*].project) : trimsuffix(basename(p), ".csv") => {
    members = [for u in local.users_by_projects[*] : u.user.email if u.project == p]
    }
  }
}