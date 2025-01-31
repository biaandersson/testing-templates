# Configure the DigitalOcean Provider
provider "digitalocean" {
  # Token should be set via DIGITALOCEAN_TOKEN environment variable
}

# Create test users
resource "digitalocean_database_user" "test_users" {
  count      = 3
  cluster_id = digitalocean_database_cluster.postgres.id
  name       = "test_user${count.index + 1}"
}

# Create test database
resource "digitalocean_database_db" "test_db" {
  cluster_id = digitalocean_database_cluster.postgres.id
  name       = "test_database"
}

# Create sample content records
locals {
  sample_posts = [
    {
      title  = "Sample Post 1"
      body   = "This is a test post content"
      author = "test_user1"
    },
    {
      title  = "Sample Post 2"
      body   = "Another test post content"
      author = "test_user2"
    }
  ]
}

# Create a test bucket for content storage
resource "digitalocean_spaces_bucket" "content" {
  name   = "test-content-bucket"
  region = "nyc3"
  acl    = "private"
}

# Upload sample files
resource "digitalocean_spaces_bucket_object" "sample_files" {
  count  = length(local.sample_posts)
  bucket = digitalocean_spaces_bucket.content.name
  key    = "post-${count.index + 1}.json"
  content = jsonencode({
    title  = local.sample_posts[count.index].title
    body   = local.sample_posts[count.index].body
    author = local.sample_posts[count.index].author
  })
  content_type = "application/json"
}
