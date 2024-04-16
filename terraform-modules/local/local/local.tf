resource "null_resource" "modullo_project_folder" {
  count  = try(var.deployment, "local") == "local" ? 1 : 0
  provisioner "local-exec" {
    command = "mkdir -p ${var.project_root}/${var.project}"
    # Only execute the command if the directory doesn't exist
    only_if = "[ ! -d ${var.project_root}/${var.project} ]"
  }
}
