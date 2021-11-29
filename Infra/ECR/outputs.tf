output "registry_url" {
    description = "the ulr for the container registry"
    value = aws_ecr_repository.registries.*.repository_url
}
