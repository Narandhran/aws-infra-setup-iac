# Create a null resource to trigger an output
resource "null_resource" "hello" {
  provisioner "local-exec" {
    command = "echo \"Hello, World!\""
  }
}