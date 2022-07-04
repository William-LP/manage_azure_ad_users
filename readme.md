# Manage Azure AD Users

This module has been created to help you track internal and guest users in you Azure Active Directory tenant

## How does it work

This module will create internal users with according properties and group them inside a departement group based on the `department` field loaded from provided csv file.


Then for each **group project** csv file the module will create a group (name will be the same a file name) and set user as group members. Every external users will received an invitation (guest user) if they are part of at least a group project.


Password for internal created user is made as follow : `<lastname><firstname's 1st letter><firstname's length>`

It has to be change at first login.

## Example

```hcl
module "users" {
    source = "./manage_azure_ad_users"
    internal_users_csv_file = "internal.csv"
    group_projects_csv_file = "./projects"
    internal_domain = "my-domain.com"
}
```

## File structure 

> Beware that heading line are required by terraform code to create `users` object.

**internal.csv**
```
first_name,last_name,department,job_title,prefered_email
Michael,Scott,HeadOffice,Manager,m.scott
Jim,Halpert,Sales,Engineer,halpert-jim
Pam,Beesly,Sales,Engineer,
```

if no **prefered_email** is set user mail and UPN will be first.lastname@internal-domain.com

**project/group_project1.csv**
```
email
guest1@gmail.com
michael.scott@my-domain.com
```
