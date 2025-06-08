provider "google" {
  project = var.project_id
  region  = "us-central1"
  zone    = "us-central1-a"
}

# Create a GCS bucket
resource "google_storage_bucket" "bucket" {
  name          = var.bucket_name
  location      = "US"
  force_destroy = true # Optional, to avoid prompt during deletion
}

# Create a GCE instance (e2-micro, free-tier eligible)
resource "google_compute_instance" "vm_instance" {
  name         = "demo-vm-instance"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y openjdk-11-jdk python3-pip
    pip3 install pyspark jupyter 
  EOT
}

# Create a Dataproc cluster (1-node, free-tier)
resource "google_dataproc_cluster" "dataproc_cluster" {
  name   = "demo-dataproc-cluster"
  region = "us-central1"

  cluster_config {

    gce_cluster_config {
      internal_ip_only = false
    }

    master_config {
      num_instances = 1
      machine_type  = "n1-standard-2"
      disk_config {
        boot_disk_size_gb = 30
      }
    }
  }

  depends_on = [google_compute_instance.vm_instance]
}

# Output for reference
output "gcs_bucket_name" {
  value = google_storage_bucket.bucket.name
}

output "vm_instance_ip" {
  value = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

output "dataproc_cluster_name" {
  value = google_dataproc_cluster.dataproc_cluster.name
}
