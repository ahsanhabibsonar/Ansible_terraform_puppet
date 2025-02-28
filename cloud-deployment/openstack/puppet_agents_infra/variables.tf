locals {
  puppet_agents = toset([
    #"storage-1", "dev-1",
    "storage-1", "storage-2", "dev-1", "dev-2", "compile-1", "compile-2", "test1",
  ])
}

