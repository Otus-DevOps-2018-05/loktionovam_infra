# loktionovam_infra
loktionovam Infra repository

## Подключение через ssh к инстансам в GCP через bastion хост
### Начальные данные
* bastion
 * Пользователь: appuser
 * External IP: 35.206.144.27
 * Internal IP: 10.132.0.2
* someinternalhost
  * Пользователь: appuser
  * Internal IP: 10.132.0.3

На **bastion** имя **someinternalhost** разрешается в IP адрес
```bash
$ host  someinternalhost
someinternalhost.c.infra-207406.internal has address 10.132.0.3
```
### Для ssh версии 7.3 и выше
В новых версиях ssh для этих целей существует опция **ProxyJump** (ключ -J)
```bash
ssh -V
OpenSSH_7.6p1 Ubuntu-4, OpenSSL 1.0.2n  7 Dec 2017
```
Пример подключения из командной строки
```bash
$ ssh -i ~/.ssh/appuser -J appuser@35.206.144.27 appuser@someinternalhost
Welcome to Ubuntu 16.04.4 LTS (GNU/Linux 4.13.0-1019-gcp x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  Get cloud support with Ubuntu Advantage Cloud Guest:
    http://www.ubuntu.com/business/services/cloud

0 packages can be updated.
0 updates are security updates.


Last login: Sat Jun 16 08:06:18 2018 from 10.132.0.2
appuser@someinternalhost:~$
```

### Для ssh более старых версий
В старых версиях ssh опции **ProxyJump** нет, но можно использовать опцию **ProxyCommand** и команда для подключения к **someinternalhost** будет выглядеть так:
```bash
ssh  -o 'ProxyCommand ssh appuser@35.206.144.27 -W %h:%p' appuser@someinternalhost
```
### Настройка ~/.ssh/config
Чтобы каждый раз при подключении к **someinternalhost** не указывать параметры **bastion** хоста, можно модифицировать **~/.ssh/config**
```bash
$ if ssh -J 2>&1 | grep "unknown option -- J" >/dev/null; then PROXY_COMMAND='ProxyCommand ssh appuser@bastion -W %h:%p'; else PROXY_COMMAND='ProxyJump %r@bastion'; fi
$ cat <<EOF>>~/.ssh/config

host bastion
HostName 35.206.144.27

host someinternalhost
  HostName someinternalhost
  User appuser
  ServerAliveInterval 30
${PROXY_COMMAND}
  IdentityFile ~/.ssh/appuser
EOF

```
Проверка подключения через alias **someinternalhost**
```bash
$ ssh someinternalhost
Welcome to Ubuntu 16.04.4 LTS (GNU/Linux 4.13.0-1019-gcp x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  Get cloud support with Ubuntu Advantage Cloud Guest:
    http://www.ubuntu.com/business/services/cloud

0 packages can be updated.
0 updates are security updates.


Last login: Sat Jun 16 08:24:37 2018 from 10.132.0.2
appuser@someinternalhost:~$
```
## Подключение к инстансам в GCP через VPN

На **bastion** установлен и настроен pritunl VPN сервер. Для подключения к VPN нужно импортировать конфигурационный файл **cloud-bastion.ovpn** в OpenVPN клиент.

bastion_IP = 35.206.144.27
someinternalhost_IP = 10.132.0.3

## Управление GCP через gcloud

testapp_IP = 104.199.102.152
testapp_port = 9292  

Автоматическое создание инстанса тестового приложения **reddit-app** с использованием startup script
```bash
export GIT_REPO_URL=https://github.com/Otus-DevOps-2018-05/loktionovam_infra.git
gcloud compute instances create reddit-app \
--boot-disk-size=10GB \
--image-family ubuntu-1604-lts \
--image-project=ubuntu-os-cloud \
--machine-type=g1-small \
--tags puma-server \
--restart-on-failure \
--metadata-from-file startup-script=startup.sh \
--metadata=git_repo_url="${GIT_REPO_URL}",git_repo_branch=$(git rev-parse --abbrev-ref HEAD)
```
Создание правила файерволла для доступа к puma server
```bash
gcloud compute firewall-rules create default-puma-server --allow tcp:9292 --target-tags puma-server
```
