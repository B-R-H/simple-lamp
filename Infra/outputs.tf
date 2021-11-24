output "registry_url" {
    description = "the ulr for the container registry"
    value = aws_ecr_repository.main-register.repository_url
}