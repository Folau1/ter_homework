locals {
  vm_web_name = "${var.project_name}-${var.vpc_name}-${var.platform_name}-web"
  vm_db_name  = "${var.project_name}-${var.vpc_name}-${var.platform_name}-db"
}
/*
Тут мы меняем имя вм в локале. Раздробили на несколько частей и вставили!
*/