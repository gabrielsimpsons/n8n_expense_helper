
# Create an EFS file system
resource "aws_efs_file_system" "helpers_efs" {
  #  Apply the backup policy if provided
  lifecycle_policy {
    transition_to_ia = "AFTER_14_DAYS" # Save on costs
  }
  tags = {
    Name = "helpers-efs"
  }
}
# Apply backup policy if provided
resource "aws_efs_backup_policy" "helpers_efs_backup_policy" {
  file_system_id = aws_efs_file_system.helpers_efs.id
  backup_policy {
    status = "ENABLED"
  }
}

# Create an EFS mount target.  This allows an EC2 instance to mount the EFS volume.
resource "aws_efs_mount_target" "helpers_efs_mount" {
    for_each       = var.subnet_public_ids
    file_system_id = aws_efs_file_system.helpers_efs.id
    subnet_id      = each.value
    security_groups = [aws_security_group.efs_sg.id]
}

# EFS Mount point
output "efs_mount_point" {
  value = aws_efs_file_system.helpers_efs.id
}