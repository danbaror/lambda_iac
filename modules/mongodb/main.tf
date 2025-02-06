resource "mongodbatlas_project" "this" {
  name   = var.project_name
  org_id = var.org_id
}

resource "mongodbatlas_cluster" "this" {
  project_id   = mongodbatlas_project.this.id
  name         = var.cluster_name
  provider_name = "TENANT"   # This is required for free-tier clusters
  cloud_backup = false       # Free tier does not support backups

  provider_region_name = var.region
  cluster_type         = "REPLICASET" # Required for free clusters
}

resource "mongodbatlas_database_user" "this" {
  username           = var.db_user
  password           = var.db_password
  project_id        = mongodbatlas_project.this.id
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = var.database_name
  }
}
