output "k0s_cluster" {
  value = yamlencode(local.k0s_tmpl)

}