# Bucket to store website, in this case it needs to be static

resource "google_storage_bucket" "website" {
    name = "example-website-by-tomi"
    location = "EUROPE-CENTRAL2"
}

# Make new object(index.html) public

resource "google_storage_object_access_control" "public_rule" {
    object = google_storage_bucket_object.static_site_src.name
    bucket = google_storage_bucket.website.name
    role = "READER"
    entity = "allUsers"
}

# Make new object(profile.jpg) public

resource "google_storage_object_access_control" "public_rule_for_pic" {
    object = google_storage_bucket_object.static_site_pic_src.name
    bucket = google_storage_bucket.website.name
    role = "READER"
    entity = "allUsers"
}

# Upload the html file to bucket

resource "google_storage_bucket_object" "static_site_src" {
    name = "index.html"
    source = "../website/index.html"
    bucket = google_storage_bucket.website.name
}

# Upload profile picture to bucket

resource "google_storage_bucket_object" "static_site_pic_src" {
    name = "profile.jpg"
    source = "../website/profile.jpg"
    bucket = google_storage_bucket.website.name
}

# Reserve a static ip address

resource "google_compute_global_address" "website_ip" {
    name = "website-lb-ip"
}

# Get the managed DNS zone

data "google_dns_managed_zone" "dns_zone" {
    name = "terraform-example-website"
}

# Add Ip to the DNS 

resource "google_dns_record_set" "website" {
    name = "website.${data.google_dns_managed_zone.dns_zone.dns_name}"
    type = "A"
    ttl = 300
    managed_zone = data.google_dns_managed_zone.dns_zone.name
    rrdatas = [google_compute_global_address.website_ip.address]
}

# Add the bucket as a cdn backend

resource "google_compute_backend_bucket" "website-backend" {
    name = "website-backend"
    bucket_name = google_storage_bucket.website.name
    description = "Contains the files needed for the website"
    enable_cdn = true
}

# GCP URL MAP

resource "google_compute_url_map" "website" {
    name = "website-url-map"
    default_service = google_compute_backend_bucket.website-backend.self_link
    host_rule {
        hosts = ["*"]
        path_matcher = "allpaths"
        }
        path_matcher {
            name = "allpaths"
            default_service = google_compute_backend_bucket.website-backend.self_link
        }

}

# GCP HTTP Proxy

resource "google_compute_target_http_proxy" "website" {
    name = "website-target-proxy"
    url_map = google_compute_url_map.website.self_link
}

# GCP forwarding rule

resource "google_compute_global_forwarding_rule" "default" {
    name = "website-forwarding-rule"
    load_balancing_scheme = "EXTERNAL"
    ip_address = google_compute_global_address.website_ip.address
    ip_protocol = "TCP"
    port_range = "80"
    target = google_compute_target_http_proxy.website.self_link
}

