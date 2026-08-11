# Домашнее задание к занятию «Основы Terraform. Yandex Cloud»

## Чек лист по готовности.

1. Аккаунт зарегистрирован в Yandex cloud (по прошлым занятиям)
2. Yandex CLI тоже установлен по прошлым занятиям.
3. Исходных код имеется на личном ПК.

Работа будет вестись через VS Code.

## Задание 1.

### 1. Изучение файла variables.tf
Изучив этот файл, можно увидеть, что тут указаны входные переменные для создания инфраструктуры в Yandex cloud.
cloud_id создержит идентификатор облака.
folder_id идентификатор каталога.
Переменная default_zone задаёт зону доступности, по стандарту идёт ru_central1_a (я обычно использую ru_central1_b).
default_cidr создает диапазон внутрненних ip адресов в подсети 10.0.1.0/24.
vpc_name создает имя для виртуальной машины.
И vms_ssh_root_key предназначения для хранения ssh ключей.

Этот код не создает ничего, он нужен для объявления параметров.

### 2. Создание аккаунта и ключа.

<img width="894" height="438" alt="image" src="https://github.com/user-attachments/assets/207e8ca9-cf4e-4d1e-bf8c-e6acfd1b2c6c" />

### 3. Вставляем публичный ключик в код.

```text
### Ключик часть его скрыл
variable "vms_ssh_root_key" {
  type        = string
  default     = "ssh-rsa AAAAB3NzaC******5MUUQX" 
  description = "ssh-keygen -t ed25519"
}
```

### 4. Выполняем инициализацию.
```text
yandex_vpc_network.develop: Creating...
yandex_vpc_network.develop: Creation complete after 3s [id=enp0vvodjv01ugjumjrk]
yandex_vpc_subnet.develop: Creating...
yandex_vpc_subnet.develop: Creation complete after 0s [id=e2l50cse3lms38ber74j]
yandex_compute_instance.platform: Creating...
╷
│ Error: Error while requesting API to create instance: client-request-id = be961408-ac0f-4d39-8f7b-da73a3425f89 client-trace-id = dcae82a5-8d44-4b73-a053-d8618b64b9d6 rpc error: code = FailedPrecondition desc = Platform "standart-v4" not found
│ 
│   with yandex_compute_instance.platform,
│   on main.tf line 15, in resource "yandex_compute_instance" "platform":
│   15: resource "yandex_compute_instance" "platform" {
```
Видим такую красивую ошибку. Ругается на следующие строки в main.tf:
```
resource "yandex_compute_instance" "platform" {
  name        = "netology-develop-platform-web"
  platform_id = "standart-v4"
```
Исправляем на standard-v1 и дальше делаем terraform apply и опять ошибка:

```
andex_compute_instance.platform: Creating...
╷
│ Error: Error while requesting API to create instance: client-request-id = 50626f9d-73c2-48f1-aa3a-1edcb471ae95 client-trace-id = 4facc679-7e69-48d7-8ef5-2f15c8ced9c3 rpc error: code = InvalidArgument desc = the specified number of cores is not available on platform "standard-v1"; allowed core number: 2, 4
│ 
│   with yandex_compute_instance.platform,
│   on main.tf line 15, in resource "yandex_compute_instance" "platform":
│   15: resource "yandex_compute_instance" "platform" {
```

Меняем core с 1 на 2 и запускаем вновь apply:
```
  Enter a value: yes

yandex_compute_instance.platform: Creating...
yandex_compute_instance.platform: Still creating... [00m10s elapsed]
yandex_compute_instance.platform: Still creating... [00m20s elapsed]
yandex_compute_instance.platform: Still creating... [00m30s elapsed]
yandex_compute_instance.platform: Still creating... [00m40s elapsed]
yandex_compute_instance.platform: Still creating... [00m50s elapsed]
yandex_compute_instance.platform: Creation complete after 53s [id=epdd5bm8d5ra0g0tuokr]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
PS C:\Users\Александр\Documents\Project3\ter-homeworks\02\src> 
```
Вывод: во первых опечатка в слове standart -> standartd и просто версии v4 нет, мы использовали самую простую доступную которая есть в документации v1.
Второй момент, с ядрами. К Сожалению v1 может использовать минимум 2 ядра, поэтому и меняем на 2 core.

### 5. Выполняем команду curl ifconfig.me на сервере.
Подключаюсь через MobaXterm. Добавляю тот самый созданный ssh ключик, который делали для сервисного аккаунта authorized_key.json.

<img width="608" height="404" alt="image" src="https://github.com/user-attachments/assets/677ef4fb-bc83-43c6-b754-902b62de3492" />


### 6. 
Исходя из документации yandex cloud можно дать следущие ответы:
preemptible = true - параметр, который даёт возможность создать "Прерываемую" виртуальную машину. Мы такие делали и в придудщих занятий. Для учебной программы нормально.
А вот для продакшена без отказоустойчивости такой вариант не подходит. Ссылка на документация [тут](https://yandex.cloud/ru/docs/compute/concepts/preemptible-vm)

core_fraction = 5 - гарантирует виртуальной машине 5% производительности каждого CPU. Минимальный набор для установки пакетов, тестовых средств. Документация [тут](https://yandex.cloud/ru/docs/compute/concepts/performance-levels)

Скриншоты из ЛК yandex cloud:

<img width="2548" height="899" alt="image" src="https://github.com/user-attachments/assets/7296acd1-9f93-4094-9b5e-5fcacd707528" />

Скриншот команды curl:

<img width="608" height="404" alt="image" src="https://github.com/user-attachments/assets/bb6904b9-6b48-4ef3-95b8-72e225ae4c4c" />

## Задание 2

### 1-3 Заменяем все хардкор-значения 
<details>
<summary>Код main.tf</summary>

```
data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_image_family
}

resource "yandex_compute_instance" "platform" {
  name        = var.vm_web_name
  platform_id = var.vm_web_platform_id

  resources {
    cores         = var.vm_web_cores
    memory        = var.vm_web_memory
    core_fraction = var.vm_web_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  scheduling_policy {
    preemptible = var.vm_web_preemptible
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.vm_web_nat
  }
}
```

</details>

И меняем захардкорженные значения:

<details>
<summary>Код variables.tf</summary>

```
variable "vm_web_image_family" {
  type    = string
  default = "ubuntu-2004-lts"
}

variable "vm_web_name" {
  type    = string
  default = "netology-develop-platform-web"
}

variable "vm_web_platform_id" {
  type    = string
  default = "standard-v1"
}

variable "vm_web_cores" {
  type    = number
  default = 2
}

variable "vm_web_memory" {
  type    = number
  default = 1
}

variable "vm_web_core_fraction" {
  type    = number
  default = 5
}

variable "vm_web_preemptible" {
  type    = bool
  default = true
}

variable "vm_web_nat" {
  type    = bool
  default = true
}
```

</details>

Проверяем terraform plan:

<img width="635" height="195" alt="image" src="https://github.com/user-attachments/assets/a23b40a0-f410-4ec7-9bb1-2d05dbbc2faf" />



## Задание 3.
### 1-3

Добавляю вторую виртуалку на ru-central1-b

<details>
<summary>Код main.tf</summary>

```hcl
resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}

resource "yandex_vpc_subnet" "develop_db" {
  name           = "${var.vpc_name}-db"
  zone           = var.vm_db_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.vm_db_cidr
}

data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_image_family
}

data "yandex_compute_image" "ubuntu_db" {
  family = var.vm_db_image_family
}

resource "yandex_compute_instance" "platform" {
  name        = var.vm_web_name
  zone        = var.default_zone
  platform_id = var.vm_web_platform_id

  resources {
    cores         = var.vm_web_cores
    memory        = var.vm_web_memory
    core_fraction = var.vm_web_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  scheduling_policy {
    preemptible = var.vm_web_preemptible
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.vm_web_nat
  }

  metadata = {
    "serial-port-enable" = "1"
    "ssh-keys"           = "ubuntu:${var.vms_ssh_root_key}"
  }
}

resource "yandex_compute_instance" "platform_db" {
  name        = var.vm_db_name
  zone        = var.vm_db_zone
  platform_id = var.vm_db_platform_id

  resources {
    cores         = var.vm_db_cores
    memory        = var.vm_db_memory
    core_fraction = var.vm_db_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_db.image_id
    }
  }

  scheduling_policy {
    preemptible = var.vm_db_preemptible
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop_db.id
    nat       = var.vm_db_nat
  }

  metadata = {
    "serial-port-enable" = "1"
    "ssh-keys"           = "ubuntu:${var.vms_ssh_root_key}"
  }
}
```

</details>

<details>
<summary>Код vms_platform.tf</summary>

```hcl
variable "vm_web_image_family" {
  type    = string
  default = "ubuntu-2004-lts"
}

variable "vm_web_name" {
  type    = string
  default = "netology-develop-platform-web"
}

variable "vm_web_platform_id" {
  type    = string
  default = "standard-v1"
}

variable "vm_web_cores" {
  type    = number
  default = 2
}

variable "vm_web_memory" {
  type    = number
  default = 1
}

variable "vm_web_core_fraction" {
  type    = number
  default = 5
}

variable "vm_web_preemptible" {
  type    = bool
  default = true
}

variable "vm_web_nat" {
  type    = bool
  default = true
}

variable "vm_db_image_family" {
  type    = string
  default = "ubuntu-2004-lts"
}

variable "vm_db_name" {
  type    = string
  default = "netology-develop-platform-db"
}

variable "vm_db_zone" {
  type    = string
  default = "ru-central1-b"
}

variable "vm_db_platform_id" {
  type    = string
  default = "standard-v1"
}

variable "vm_db_cores" {
  type    = number
  default = 2
}

variable "vm_db_memory" {
  type    = number
  default = 2
}

variable "vm_db_core_fraction" {
  type    = number
  default = 20
}

variable "vm_db_preemptible" {
  type    = bool
  default = true
}

variable "vm_db_nat" {
  type    = bool
  default = true
}

variable "vm_db_cidr" {
  type    = list(string)
  default = ["10.0.2.0/24"]
}
```

</details>

Скриншот подтверждения создания 2-ух ВМ:

<img width="2494" height="483" alt="image" src="https://github.com/user-attachments/assets/cd0b4569-9013-46e1-bcff-cbe822db9fda" />



## Задание 4.
### 1-2.

Делаем output файл простой и понятный с выводами "instance_name", "external_ip","fqdn" для каждой ВМ

```
output "vm_info" {
  value = {
    web = {
      instance_name = yandex_compute_instance.platform.name
      external_ip   = yandex_compute_instance.platform.network_interface[0].nat_ip_address
      fqdn          = yandex_compute_instance.platform.fqdn
    }

    db = {
      instance_name = yandex_compute_instance.platform_db.name
      external_ip   = yandex_compute_instance.platform_db.network_interface[0].nat_ip_address
      fqdn          = yandex_compute_instance.platform_db.fqdn
    }
  }
}
```

Вывод из консоли:

<img width="782" height="412" alt="image" src="https://github.com/user-attachments/assets/8b33c3a0-0214-471e-a32d-c4891839ecc9" />
<img width="628" height="257" alt="image" src="https://github.com/user-attachments/assets/5b21e5ad-f847-4f6d-aeaa-a9b896b02a5a" />

##Задание 5.
### 1-3.
Для того, чтобы terraform правильно прочитал наши переменные, мы его разделили на две части:
"project_name" и "platform_name" Добавили в конец нашего vms_platform.tf:

```
variable "project_name" {
  type    = string
  default = "netology"
}

variable "platform_name" {
  type    = string
  default = "platform"
}
```
Далее вставляем по примеру из лекции в locals:

```
locals {
  vm_web_name = "${var.project_name}-${var.vpc_name}-${var.platform_name}-web"
  vm_db_name  = "${var.project_name}-${var.vpc_name}-${var.platform_name}-db"
}
```

Тут стоит отметить, что vpc_name уже присутствует в variables.tf, поэтому её можно не объявлять заново.(отметит что это дубликат)

И заменяем в main.tf:
```
  name        = local.vm_web_name
и
  name        = local.vm_db_name
```
Применяем terraform apply - без изменений!

## Задание 6
### 1 Ресурсы.
Присваиваем значения в vms_platform тип ресурсов в map:

```
variable "vms_resources" {
  type = map(object({
    cores         = number
    memory        = number
    core_fraction = number
    hdd_size      = number
    hdd_type      = string
  }))
}
```

Создаем файлик terraform.tfvars и добавляем туда то, что нам нужно:

```
vms_resources = {
  web = {
    cores         = 2
    memory        = 1
    core_fraction = 5
    hdd_size      = 10
    hdd_type      = "network-hdd"
  }

  db = {
    cores         = 2
    memory        = 2
    core_fraction = 20
    hdd_size      = 10
    hdd_type      = "network-ssd"
  }
}
```
Делаем также и для metadata:

```
metadata = {
  "serial-port-enable" = "1"
  "ssh-keys"           = "ubuntu:ssh-rsa AAAAB3N*******op0OP5MUUQX"
}
```

Нужно закомментировать старый ssh ключ и добавить в main.tf по новому:

```
metadata = var.metadata
```
Комментируем всё старое и запускаем terraform validate, terraform plan:

<img width="776" height="412" alt="image" src="https://github.com/user-attachments/assets/5ff7d0ea-a701-45f6-8c81-2b130945a7c5" />

Изменений никаких нет! Задание закрываем.

## Задание 7*

### 1.
Командой local.test_list[1] можно отобразить второй элемент test_list.
Вывод:

```
 local.test_list[1]
"staging"
```
### 2. 
Длина списка test_list c помощью leght:

```
> length(local.test_list)
3
```

### 3. 

Погуглив, немного не понял, но там в терраформе другая форма немного используется. Но гугл АИ дал подсказку.
Сначала попробовал такое:

```
> keys(local.test_map)
[
  "admin",
  "user",
]
```
Видим два ключа, пробуем вставить admin:

```
> local.test_map["admin"]
"John"
> 
```
Это и есть ответ.

### 4.

```
> local.test_list[2]
"production"
> local.servers["production"].image
"ubuntu-20-04"
> local.servers["production"].cpu
10
> local.servers["production"].ram
40
```

Проверили добавляем фразу по чуть чуть:

```
> "${local.test_map.admin} is ${keys(local.test_map)[0]}"
"John is admin"
> "${local.test_map.admin} is ${keys(local.test_map)[0]} for ${local.test_list[2]} server"
"John is admin for production server"
> "${local.test_map.admin} is ${keys(local.test_map)[0]} for ${local.test_list[2]} server based on OS ${local.servers[local.test_list[2]].image}"
"John is admin for production server based on OS ubuntu-20-04"
> "${local.test_map.admin} is ${keys(local.test_map)[0]} for ${local.test_list[2]} server based on OS ${local.servers[local.test_list[2]].image} with ${local.servers[local.test_list[2]].cpu} vcpu, ${local.servers[local.test_list[2]].ram} ram and ${length(local.servers[local.test_list[2]].disks)} virtual disks"
"John is admin for production server based on OS ubuntu-20-04 with 10 vcpu, 40 ram and 4 virtual disks"
```
## Задание 8*

### 1-2.

Добавим кусок кода в terraform.tfvars.
Делаем validate и заходим в консоль:

```
> var.test
tolist([
  tomap({
    "dev1" = tolist([
      "ssh -o 'StrictHostKeyChecking=no' ubuntu@62.84.124.117",
      "10.0.1.7",
    ])
  }),
  tomap({
    "dev2" = tolist([
      "ssh -o 'StrictHostKeyChecking=no' ubuntu@84.252.140.88",
      "10.0.2.29",
    ])
  }),
  tomap({
    "prod1" = tolist([
      "ssh -o 'StrictHostKeyChecking=no' ubuntu@51.250.2.101",
      "10.0.1.30",
    ])
  }),
])
> var.test[0]["dev1"][0]
"ssh -o 'StrictHostKeyChecking=no' ubuntu@62.84.124.117"
> 
```

Задание выполнено.

## Задание 9*

После того, как мы отключим внешние айпи адреса, через MobaXterm к серверам уже не подключиться.

Сначала я добавил в terraform.tfvars новые строчки:

```
metadata = {
  "serial-port-enable" = "1"
  "ssh-keys"           = "ubuntu:ssh-rsa AAAAB3N******Hop0OP5MUUQX"
}

```
Которые убирают NAT из кода.

Подключился к каждому серверу поменял пароль и активировал пользователя (потому что состояние было L а нам нужно чтобы было P:

```
sudo passwd -u ubuntu
sudo passwd -S ubuntu

Получил:

ubuntu P 08/11/2026 0 99999 7 -1
```
Это на каждом сервере сделал.

Затем создал таблицу маршрутизации в main.tf:
```
resource "yandex_vpc_route_table" "develop" {
  name       = "develop-route-table"
  network_id = yandex_vpc_network.develop.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}
```

Созданную таблицу маршрутизации подключил к обеим подсетям:

route_table_id = yandex_vpc_route_table.develop.id

После добавления ресурсов выполнил terraform validate, terraform plan.


Terraform показал создание NAT Gateway и таблицы маршрутизации, а также изменение двух подсетей:

```
Plan: 2 to add, 2 to change, 0 to destroy.
```

После создания NAT Gateway отключил собственные внешние IP у обеих ВМ. В terraform.tfvars добавил:
```
vm_web_nat = false
vm_db_nat  = false
```

Дальше как обычно terraform validate и terraform plan:
Plan: 0 to add, 2 to change, 0 to destroy.
И в конце terraform apply:
Apply complete! Resources: 0 added, 2 changed, 0 destroyed.
Дополнительно через консоль проверил:

```
PS C:\Users\Александр\Documents\Project3\ter-homeworks\02\src> terraform console                            
> var.vm_web_nat
false
> var.vm_db_nat
false
> yandex_compute_instance.platform.network_interface[0].nat
false
> yandex_compute_instance.platform_db.network_interface[0].nat
false
```

Все значения false значит все получилось! Захожу в консоль яндекса:

<img width="1315" height="734" alt="image" src="https://github.com/user-attachments/assets/36468b4b-3180-4fa6-ad8f-5f893708614b" />

<img width="857" height="595" alt="image" src="https://github.com/user-attachments/assets/930520d5-0857-430e-ac4e-5bd026c93055" />


На ВМ остались только внутренние айпи адреса.

<img width="2548" height="896" alt="image" src="https://github.com/user-attachments/assets/db2e1a00-8bac-4c29-94c9-db80635640d3" />

Краткий вывод из всего выше проделланого: Маршрут, по которому мы кинули 0.0.0.0/0 отправляет исходящий трафик в NAT Gateway, а он выполняет преобразование адресов и выпускает трафик наружу. При этом напрямую подключиться к ВМ из интернета по SSH уже нельзя.
Делаем финальный terraform destroy:
```
Destroy complete! Resources: 7 destroyed.
```

Все задания выполнены!
