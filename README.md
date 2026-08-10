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

<img width="404" height="70" alt="image" src="https://github.com/user-attachments/assets/64f37d68-1a1e-47fa-a73b-71cb1291fc57" />

### 6. 
Исходя из документации yandex cloud можно дать следущие ответы:
preemptible = true - параметр, который даёт возможность создать "Прерываемую" виртуальную машину. Мы такие делали и в придудщих занятий. Для учебной программы нормально.
А вот для продакшена без отказоустойчивости такой вариант не подходит. Ссылка на документация [тут](https://yandex.cloud/ru/docs/compute/concepts/preemptible-vm)

core_fraction = 5 - гарантирует виртуальной машине 5% производительности каждого CPU. Минимальный набор для установки пакетов, тестовых средств. Документация [тут](https://yandex.cloud/ru/docs/compute/concepts/performance-levels)

Скриншоты из ЛК yandex cloud:

<img width="2558" height="620" alt="image" src="https://github.com/user-attachments/assets/ab8d2d69-a40d-4744-94fa-4b3ea8e6671e" />

Скриншот команды curl:

<img width="792" height="394" alt="image" src="https://github.com/user-attachments/assets/b49dd86b-191c-441e-857a-8984c9143bb2" />


