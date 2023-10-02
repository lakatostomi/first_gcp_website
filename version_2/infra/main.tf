module "website_bucket" {
  source     = "../../modules/gcs"
  project_id = var.project_id
  name       = var.bucket_name
  objects_to_upload = {
    main_page = {
      name         = "index.html"
      source       = "../../website/index.html"
      content_type = "text/html"
    }
    profile_pic = {
      name         = "profile.jpg"
      source       = "../../website/profile.jpg"
      content_type = "image/jpeg"
    }
  }
  iam = {
    "roles/storage.objectViewer" = ["allUsers"]
  }
  storage_class = "REGIONAL"
  location      = "europe-west4"
  website = {
    main_page_suffix = "index.html"
  }
}

resource "google_compute_global_address" "website_ip" {
  project  = var.project_id
  provider = google
  name     = "lb-static-ip"
}

module "public-dns" {
  source      = "../../modules/dns"
  project_id  = var.project_id
  description = "My managed domain"
  name        = var.dns_managed_zone
  zone_config = {
    domain = var.dns_record_set
  }
  recordsets = {
    "A website" = { ttl = 300, records = ["${google_compute_global_address.website_ip.address}"] }
  }
}

module "global_lb" {
  source     = "../../modules/net-lb-app-ext"
  project_id = var.project_id
  name       = "website-ext-lb"
  address    = google_compute_global_address.website_ip.address
  ports      = ["80"]
  protocol   = "HTTP"
  backend_buckets_config = {
    website-bucket = {
      bucket_name = module.website_bucket.name
      enable_cdn  = true
    }
  }
  urlmap_config = {
    default_service = "website-bucket"
    host_rules = [{
      hosts        = ["*"]
      path_matcher = "allpaths"
    }]
    path_matchers = {
      allpaths = {
        default_service = "website-bucket"

      }
    }
  }
}


