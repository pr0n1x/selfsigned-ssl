# Создание самоподписанных сертификатов

## Для чего
Для облегчения процедуры создания самоподписанных сертификатов ::)
По сути для локальной разработки сайтов, которые имеют требования по работе через https, коих очень много на сегодняшний день.

Как правило, у разработчика два выбора:
1. *Настраивать сервисы с разной конфигурацией для **локальной** разработки и для **продуктовой** эксплуатации.*
	> Это не дает возможности адекватно протестировать все режимы работы сервиса на машинах разработчиков. Также отсутствие SSL по *разным* причинам будет порождать чудовищное количество предупреждений в консоли браузера, что, безусловно, сильно мешает.
2. Использовать самоподписанные сертификаты на машинах разработчиков.
	> Нужно генерировать сертификаты и как-то пояснить системе и браузеру, что этим сертификатам можно доверять

### Небольшое, но важное, примечание
Системе лучше сразу "скормить" корневой сертификат, тогда системные утилиты типа curl или wget не будут "задавать лишних вопросов" при работе со всеми локальными хостами, порожденными корневым сертификатом. см. ниже как

Данные скрипты созданы по инструкции  
https://habr.com/ru/post/352722/

## Как использовать
### Клонировать репозиторий
- `$ git clone https://github.com/pr0n1x/selfsigned-ssl.git ~/path/to/selfsigned-ssl`
- `$ cd ~/path/to/selfsigned-ssl`

### Создать корневой самоподписанный сертификат  
`$ ./create_root_ca.sh`

### Создать самоподписанный сертификат для конкретного домена  
`$ ./create_domain.sh my-domain.loc`


### Подключение сампоподписанного сертификата к Apache2 (структура папок на примере Ubuntu)

Создадим символьную ссылку на папку с сертификатами в папку конфигурации Apache2  
- `$ cd /etc/apache2`
- `$ sudo ln -s ~/path/to/selfsigned-ssl/cert ssl`

Добавляем подключение сертификата для виртуального хоста (/etc/apache2/site-enabled/my-domain.loc.conf).
Подставьте вместо $host имя вашего виртуального хоста (или используйте apache mod_macro).  
```
<VirtualHost ${APACHE_LOCALHOST_IP}:443 ${APACHE_EXTERNAL_IP}:443>
	ServerName $host
	ServerAlias www.$host
	ServerAdmin admin@$host
	#AssignUserID user group
	DocumentRoot /path/to/$host
	ErrorLog ${APACHE_LOG_DIR}/$host.error.log
	# Possible values include: debug, info, notice, warn, error, crit,
	# alert, emerg.
	LogLevel warn
	CustomLog ${APACHE_LOG_DIR}/$host.access.log combined
	
	# ... some other params
	
	SSLEngine on
	SSLCertificateFile      /etc/apache2/ssl/$host.crt
	SSLCertificateKeyFile   /etc/apache2/ssl/$host.key
	SSLCertificateChainFile /etc/apache2/ssl/rootCA.pem
</VirtualHost>
```

## Скармливаем системе корневой сертификат

### ubuntu/debian
1. $ `cd /usr/share/ca-certificates`
2. $ `sudo mkdir local-web-development`
3. $ `cd local-web-development`
4. $ `sudo ln -s /etc/apache2/ssl/rootCA.pem ./` -убедитесь в том, что пункт по созданию ссылки из предыдущего пункта выполнен. А, вообще, обустраивайте ваши папки как удобно ::)
4. $ `sudo sh -c 'echo "local-web-development/rootCA.pem" >> /etc/ca-certificates.conf'`
5. $ `sudo update-ca-certificates`

#### **Примечание**
В интернетах пишут, что надо выполнить команду $ `sudo dpkg-reconfigure ca-certificates`.  
Делать этого не нужно. А выполняют её по причине срабатывания команды `update-ca-certificates` только на изменения в файле `/etc/ca-certificates.conf`.

 Эта команда просто собирает сертификаты в системе и генерирует новый файл `/etc/ca-certificates.conf`. Если вы уже положили свой сертификат в папку `/usr/share/ca-certificates/local-web-development`, то `dpkg-reconfigure ca-certificates` найдет ваш сертификат и добавит в конфиг. Соответственно вместо 4-го пункта действительно можно выполнить эту команду, только большого смысла в этом нет.

 К сожалению браузеры, почему-то, не подхатывают корневой сертификат из системы. Потому его необходимо загрузить в ваш браузер явными импортом. Такая ф-ия есть во всех современных браузерах. Однако, загрузить один корневой сертификат в браузер сильно проще чем плодить кучу исключений или импортов на каждый отдельный локальный хост для разработки.

 ### Другие linux-ы
 По аналогии - пути и называния утилит могут отличаться. Кто знает как - кидайте pull-request на изменение этого readme ::)

 ### Windows
 Точно как-то делается. Кто знает как - кидайте pull-request на изменение этого readme ::)
