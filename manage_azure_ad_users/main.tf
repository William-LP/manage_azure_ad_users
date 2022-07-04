provider "azuread" {}

data "azuread_domains" "default" {
  only_initial = true
}

locals {
  domain_name       = data.azuread_domains.default.domains.0.domain_name
  decoded_users     = csvdecode(file(var.internal_users_csv_file))
  data_users        = values(azuread_user.users)[*].user_principal_name
  internal_users    = { for u in local.decoded_users : replace(format("%s.%s@%s", lower(u.first_name), lower(u.last_name), var.internal_domain), " ", "-") => u }
  guests_users      = distinct(setsubtract(local.users_by_projects[*].user.email, values(azuread_user.users)[*].user_principal_name))
  all_users         = concat([for u in local.guests_users : "${replace(u, "@", "_")}#EXT#@${local.domain_name}"], local.data_users)
  department_groups = toset(local.decoded_users[*].department)
  projects          = fileset(path.module, "${var.group_projects}/*.csv")

  users_by_projects = distinct(flatten([
    for project in local.projects : [
      for user in csvdecode(file(project)) : {
        project = project
        user    = user
      }
    ]
  ]))

  binding_pivot_table = [for project in local.projects : [
    for user in csvdecode(file(project)) : {
      uid     = element([for u in data.azuread_user.all_users : u.id if u.mail == user.email], 0)
      project = project
    }
  ]]
}

resource "azuread_user" "users" {
  for_each            = local.internal_users
  user_principal_name = each.value.prefered_email != "" ? format("%s@%s",each.value.prefered_email,var.internal_domain) : each.key
  mail                = each.value.prefered_email != "" ? format("%s@%s",each.value.prefered_email,var.internal_domain) : each.key
  password = format(
    "%s%s%s!",
    replace(lower(each.value.last_name), " ", "-"),
    substr(lower(each.value.first_name), 0, 1),
    length(each.value.first_name)
  )
  force_password_change = true
  display_name          = "${each.value.first_name} ${each.value.last_name}"
  department            = each.value.department
  job_title             = each.value.job_title
}

resource "azuread_group" "department_groups" {
  for_each           = local.department_groups
  display_name       = each.key
  security_enabled   = true
  assignable_to_role = true
  members            = [for u in values(azuread_user.users) : u.id if u.department == each.key]
}



data "azuread_user" "all_users" {
  for_each            = toset(local.all_users)
  user_principal_name = each.key
  depends_on = [
    azuread_invitation.guests,
    azuread_user.users
  ]
}


resource "azuread_invitation" "guests" {
  for_each           = toset(local.guests_users)
  user_display_name  = each.key
  user_email_address = each.key
  message {
    language = "en-US"
  }
  redirect_url       = "https://portal.azure.com"
}

resource "azuread_group" "projects" {
  for_each           = local.projects
  display_name       = trimsuffix(basename(each.key), ".csv")
  security_enabled   = true
  assignable_to_role = true
  members            = [for binding in flatten(local.binding_pivot_table) : binding.uid if binding.project == each.key]
}

