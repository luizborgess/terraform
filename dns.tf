
resource "cloudflare_dns_record" "jellyfin" {
  zone_id = "c8cb80ec5637bd53aa8cec679db8676c"
  name    = "jellyfin.hlspace.org"
  type    = "A"
  ttl     = 1
  proxied = false
  content = "192.168.24.10"
}

resource "cloudflare_dns_record" "pairdrop" {
  zone_id = "c8cb80ec5637bd53aa8cec679db8676c"
  name    = "pairdrop.hlspace.org"
  type    = "A"
  ttl     = 1
  proxied = false
  content = "192.168.24.10"
}


resource "cloudflare_dns_record" "traefik" {
  zone_id = "c8cb80ec5637bd53aa8cec679db8676c"
  name    = "traefik.hlspace.org"
  type    = "A"
  ttl     = 1
  proxied = false
  content = "192.168.24.10"
}
resource "cloudflare_dns_record" "www" {
  zone_id = "c8cb80ec5637bd53aa8cec679db8676c"
  name    = "www.hlspace.org"
  type    = "CNAME"
  ttl     = 1
  proxied = false
  content = "luizborgess.github.io"
}


resource "cloudflare_dns_record" "github_challenge" {
  zone_id = "c8cb80ec5637bd53aa8cec679db8676c"
  name    = "_github-pages-challenge-luizborgess.hlspace.org"
  type    = "TXT"
  ttl     = 1
  content = "\"47ccf526274f591887680c5d366a4e\""
}

resource "cloudflare_dns_record" "hlspace_spf" {
  zone_id = "c8cb80ec5637bd53aa8cec679db8676c"
  name    = "hlspace.org"
  type    = "TXT"
  ttl     = 1
  content = "\"v=spf1 include:_spf.mx.cloudflare.net ~all\""
}