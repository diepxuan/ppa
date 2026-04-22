#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("httpd:install")
--httpd:install() {
    #!/usr/bin/env bash

    # CREATE Dav Access
    ###################
    # mkdir -p /var/www/DavLock
    sudo a2enmod dav dav_fs auth_digest &>/dev/null
    sudo chmod 775 /var/www/
    sudo chown :www-data /var/www/

    # APPLY APACHE CONFIG
    #####################
    sudo a2ensite ductn.conf
    # sudo a2dismod mpm_prefork mpm_worker mpm_event

    # sudo apt-get install libapache2-mpm-itk
    # sudo a2enmod mpm_itk

    sudo a2enmod proxy proxy_http headers deflate expires rewrite mcrypt reqtimeout vhost_alias ssl env dir mime

    # sudo a2dismod php?.?
    # sudo a2enmod php7.1

    sudo apache2ctl configtest
    sudo service apache2 restart
    # sudo service apache2 status

}

_DUCTN_COMMANDS+=("httpd:config")
--httpd:config() {
    --httpd:config:sites
    # sudo chown -R :www-data /home/*/public_html/
    apachectl configtest
}

_DUCTN_COMMANDS+=("httpd:restart")
--httpd:restart() {
    --httpd:config
    sudo systemctl restart apache2
}

--httpd:config:sites() {
    # CREATE ductn SITE
    ###################
    #shellcheck disable=SC2002
    echo "$_httpd_conf" | sudo tee /etc/apache2/sites-available/ductn.conf
}

_httpd_conf=$(
    cat <<EOF
php_admin_value date.timezone           "Asia/Ho_Chi_Minh"

php_value       display_errors          1
php_value       display_startup_errors  1
php_flag        display_errors          1
php_flag        display_startup_errors  1
php_value       error_reporting         -1

php_value       max_execution_time      30
php_value       memory_limit            256M

php_value       post_max_size           128M
php_value       upload_max_filesize     128M

php_value       max_input_vars          75000

php_value       session.gc_maxlifetime  2628000

AcceptFilter http none
AcceptFilter https none

# User www-data
User ductn
Group www-data

<Directory /home/*/public_html>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
    Order allow,deny
    Allow from all
</Directory>

# <IfModule ssl_module>
#     Listen 443
# </IfModule>

# AliasMatch "^/.well-known/acme-challenge/([a-zA-Z0-9_.-]+)"      "/var/www/html/sslverify/ductn"

########################################################################
# vhost per user
########################################################################
<IfModule mpm_itk_module>

    # <Directory /home/*/public_html/>
    #     AssignUserFromPath "^/home/([^/]+)" ductn www-data
    # </Directory>

    <Directory /home/luong/public_html/>
        AssignUserID luong www-data
    </Directory>

    <Directory /home/pma/public_html/>
        AssignUserID pma www-data
    </Directory>

    # <Directory /home/sarcomfashion/public_html/>
    #     AssignUserID sarcomfashion www-data
    # </Directory>

    # <Directory /home/shop/public_html/>
    #     AssignUserID shop www-data
    # </Directory>

    <Directory /home/dynupdate/public_html/>
        AssignUserID dynupdate www-data
    </Directory>

    # <Directory /home/vpn/public_html/>
    #     AssignUserID vpn www-data
    # </Directory>

    <Directory /home/store/public_html/>
        AssignUserID store www-data
    </Directory>

    <Directory /home/ductn/public_html/>
        AssignUserID ductn www-data
    </Directory>
</IfModule>

<VirtualHost *:80>
    UseCanonicalName Off
    ServerAlias admin.diepxuan.com
    ServerAlias admin.diepxuan.*
    VirtualDocumentRoot /home/ductn/public_html/
</VirtualHost>

<VirtualHost *:443>
    UseCanonicalName Off
    ServerAlias admin.diepxuan.com
    ServerAlias admin.diepxuan.*
    VirtualDocumentRoot /home/ductn/public_html/

    SSLEngine on
    SSLProtocol all -SSLv2 -SSLv3

    SSLCipherSuite ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP

    SSLCertificateFile      /etc/letsencrypt/live/diepxuan.com/fullchain.pem
    SSLCertificateKeyFile   /etc/letsencrypt/live/diepxuan.com/privkey.pem
</VirtualHost>

########################################################################
# domain: work.diepxuan.*
########################################################################
<VirtualHost *:80>
    UseCanonicalName Off
    ServerAlias work.diepxuan.com
    ServerAlias work.diepxuan.*
    VirtualDocumentRoot /home/luong/public_html/
</VirtualHost>

<VirtualHost *:443>
    UseCanonicalName Off
    ServerAlias work.diepxuan.com
    ServerAlias work.diepxuan.*
    VirtualDocumentRoot /home/luong/public_html/

    SSLEngine on
    SSLProtocol all -SSLv2 -SSLv3

    SSLCipherSuite ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP

    SSLCertificateFile      /etc/letsencrypt/live/diepxuan.com/fullchain.pem
    SSLCertificateKeyFile   /etc/letsencrypt/live/diepxuan.com/privkey.pem
</VirtualHost>

########################################################################
# domain: diepxuan.* to www.diepxuan.vn
########################################################################

<VirtualHost *:80>
    UseCanonicalName Off
    ServerName  diepxuan.com
    ServerAlias diepxuan.*
    ServerAlias www.diepxuan.*
    VirtualDocumentRoot /home/store/public_html/
</VirtualHost>

<VirtualHost *:443>
    UseCanonicalName Off
    ServerName  diepxuan.com
    ServerAlias diepxuan.*
    ServerAlias www.diepxuan.*
    VirtualDocumentRoot /home/store/public_html/

    SSLEngine on
    SSLProtocol all -SSLv2 -SSLv3

    SSLCipherSuite ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP

    SSLCertificateFile      /etc/letsencrypt/live/diepxuan.com/fullchain.pem
    SSLCertificateKeyFile   /etc/letsencrypt/live/diepxuan.com/privkey.pem
</VirtualHost>

########################################################################
# domain: *.diepxuan.*
########################################################################
<VirtualHost *:80>
    UseCanonicalName Off
    ServerAlias *.diepxuan.com
    ServerAlias *.diepxuan.*
    VirtualDocumentRoot /home/%1.0/public_html/
</VirtualHost>

<VirtualHost *:443>
    UseCanonicalName Off
    ServerAlias *.diepxuan.com
    ServerAlias *.diepxuan.*
    VirtualDocumentRoot /home/%1.0/public_html/

    SSLEngine on
    SSLProtocol all -SSLv2 -SSLv3

    SSLCipherSuite ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP

    SSLCertificateFile      /etc/letsencrypt/live/diepxuan.com/fullchain.pem
    SSLCertificateKeyFile   /etc/letsencrypt/live/diepxuan.com/privkey.pem
</VirtualHost>
EOF
)
