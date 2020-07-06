# Создание самоподписанных сертификатов

Данные скрипты созданы по инструкции  
https://habr.com/ru/post/352722/

Клонировать репозиторий
- `$ git clone https://github.com/pr0n1x/selfsigned-ssl.git ~/path/to/selfsigned-ssl`
- `$ cd ~/path/to/selfsigned-ssl`

Создать корневой самоподписанный сертификат  
`$ ./create_root_ca.sh`

Создать самоподписанный сертификат для конкретного домена  
`$ ./create_cert_for_domain.sh my-domain.loc`


## Подключенние сампоподписанного сертификата к Apache2 (структура папок на примере Ubuntu)

Создадим символьную ссылку на папку с сертификатами в папку конфигурации Apache2  
- `$ cd /etc/apache2`
- `$ sudo ln -s ~/path/to/selfsigned-ssl ssl`

Добавляем подключение сертификата для виртуального хоста (/etc/apache2/site-enabled/my-domain.loc.conf).
Подставьте вместо $host имя вашего виртуального хоста (или используйте apache mod_macro).  
```
<VirtualHost ${APACHE_LOCALHOST_IP}:443 ${APACHE_EXTERNAL_IP}:443>
	ServerName $host
	ServerAlias www.$host
	ServerAdmin admin@$host
	#AssignUserID maximum maximum
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
