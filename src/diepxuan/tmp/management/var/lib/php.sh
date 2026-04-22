#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("php:composer:install")
--php:composer:install() {
    cd ~
    curl -sS https://getcomposer.org/installer -o composer-setup.php
    HASH=$(curl -sS https://composer.github.io/installer.sig)
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
    sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    php -r "unlink('composer-setup.php');"
    rm -rf composer-setup.php
}
#!/usr/bin/env bash
#!/bin/bash

--php:apt:install() {
    sudo add-apt-repository ppa:ondrej/php -y
    sudo apt update
    # sudo apt install -y php-dev php-xml -y --allow-unauthenticated &>/dev/null
}

_DUCTN_COMMANDS+=("php:install")
--php:install() {
    --php:apt:install

    #!/bin/bash

    # sudo add-apt-repository ppa:ondrej/php
    # sudo apt update
    # sudo apt install libapache2-mod-php?.? -y --purge --auto-remove
    # sudo update-alternatives --config php

    #sudo update-alternatives --set php /usr/bin/php5.6
    #sudo update-alternatives --set phar /usr/bin/phar5.6
    #sudo update-alternatives --set phar.phar /usr/bin/phar.phar5.6
    #sudo update-alternatives --set phpize /usr/bin/phpize5.6
    #sudo update-alternatives --set php-config /usr/bin/php-config5.6

    # INSTALL PHP MODULES
    ########################
    # sudo apt install phpmd -y --purge --auto-remove &>/dev/null
    # sudo apt install composer -y --purge --auto-remove &>/dev/null

    # sudo apt install -y libapache2-mod-php?.? php?.? php?.?-mysql php?.?-mbstring php?.?-mysqli php?.?-intl php?.?-curl php?.?-gd php?.?-mcrypt php?.?-soap php?.?-dom php?.?-xml php?.?-zip php?.?-bcmath php?.?-imagick &>/dev/null
    # sudo apt install -y php?.?-mongodb &>/dev/null
    # ductn_php_mssql
    # sudo service apache2 restart
}

_DUCTN_COMMANDS+=("php:phpcsfixer:install")
--php:phpcsfixer:install() {
    cd ~
    curl -sS https://cs.symfony.com/download/php-cs-fixer-v3.phar -o php-cs-fixer
    if [ "$USERNAME" = "ductn" ]; then
        chmod +x php-cs-fixer
        sudo mv php-cs-fixer /usr/local/bin/php-cs-fixer
        sudo chown root:root /usr/local/bin/php-cs-fixer
    fi
}
