resource "google_compute_instance" "db" {
  name         = "reddit-db"
  machine_type = "g1-small"
  zone         = "${var.zone}"

  tags = ["reddit-db"]

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  boot_disk {
    initialize_params {
      image = "${var.db_disk_image}"
    }
  }

  network_interface {
    network = "default"

    access_config = {}
  }
}

#Note: Source tags cannot be used to allow access to an instance's external IP address. Use internal ip address instead.
resource "google_compute_firewall" "firewall_mongo" {
  name    = "allow-mongo-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["${var.db_port}"]
  }

  target_tags = ["reddit-db"]

  source_tags = ["reddit-app"]
}
