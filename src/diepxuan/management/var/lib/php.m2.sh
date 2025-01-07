#!/usr/bin/env bash
#!/bin/bash

WEBSERVER_GROUP="www-data"

_dev:m2:ch() {
    _ch() {
        for arg in "$@"; do
            [[ -e "$arg" ]] && chmod g+ws $arg
            [[ -d "$arg" ]] && chmod -R g+w $arg
        done
    }

    _ch app/etc
    _ch vendor
    _ch generated
    _ch generation
    _ch generation/code

    _ch pub/static
    _ch pub/media

    _ch var
    _ch var/log
    _ch var/cache
    _ch var/page_cache
    _ch var/generation
    _ch var/view_preprocessed
    _ch var/tmp

    _ch wp/wp-content/themes

    # find var vendor pub/static pub/media app/etc -type f -print0 -printf '\r\n' -exec chmod g+w {} \;
    # find var vendor pub/static pub/media app/etc -type d -print0 -printf '\r\n' -exec chmod g+ws {} \;
}

_dev:m2:group() {
    usermod -aG $WEBSERVER_GROUP $(whoami)
}

_dev:m2:urn() {
    _magento dev:urn-catalog:generate .idea/misc.xml
    _dev:m2:perm
}

_dev:m2:perm() {
    chown -R :$WEBSERVER_GROUP .
    chmod u+x bin/magento
    _dev:m2:ch
}

_dev:m2:rmgen() {
    find generated generated/code generation generation/code var/generation -maxdepth 1 -mindepth 1 -type d -not -name 'Magento' -not -name 'Composer' -not -name 'Symfony' -print0 -printf '\r\n' -exec rm -rf {} \;
    _magerun2 generation:flush
}

_dev:m2:static() {
    rm -rf var/view_preprocessed/* pub/static/frontend/* pub/static/adminhtml/* pub/static/_requirejs/*
    _magerun2 dev:asset:clear
}

_dev:m2:cache() {
    # rm -rf var/cache/* var/page_cache/* var/tmp/* var/generation/* var/di/*
    # _magerun2 cache:clean
    _magento cache:flush
    _dev:m2:perm
}

_dev:m2:index() {
    _magento indexer:reindex
    _dev:m2:perm
}

_dev:m2:grunt() {
    #_dev:m2:rmgen
    #_dev:m2:static
    #_dev:m2:cache
    # _magento setup:upgrade
    _grunt exec:all
    #_dev:m2:perm
    _grunt watch
}

_dev:m2:up() {
    # _dev:m2:perm
    # _dev:m2:rmgen
    # _dev:m2:static
    # _dev:m2:cache
    _magento setup:upgrade $@
    _dev:m2:perm
}

_dev:m2:config() {
    _magerun2 module:enable --all
    _magerun2 setup:di:compile
    _dev:m2:perm
}

_dev:m2:setting() {
    _magerun2 config:store:set admin/security/admin_account_sharing 1
    _magerun2 config:store:set admin/security/use_form_key 0
    _magerun2 config:store:set admin/startup/page dashboard

    _magerun2 config:store:set customer/startup/redirect_dashboard 0

    _magerun2 config:store:set web/seo/use_rewrites 1
    _magerun2 config:store:set web/session/use_frontend_sid 0
    _magerun2 config:store:set web/url/redirect_to_base 1

    _magerun2 config:store:set web/browser_capabilities/local_storage 1

    _magerun2 config:store:set web/secure/use_in_frontend 1
    _magerun2 config:store:set web/secure/use_in_adminhtml 1
    _magerun2 config:store:set web/secure/enable_hsts 1
    _magerun2 config:store:set web/secure/enable_upgrade_insecure 1

    _magerun2 config:store:set admin/autologin/enable 1
    _magerun2 config:store:set admin/autologin/username admin

    _magerun2 config:store:set system/smtp/active 1
    _magerun2 config:store:set system/smtp/smtphost smtp.zoho.com
    _magerun2 config:store:set system/smtp/username admin@diepxuan.com
    _magerun2 config:store:set system/smtp/password fbJdfF2xsKd5NSrv

    if [ ! -z $1 ]; then
        _magerun2 config:store:set web/unsecure/base_url http://$1/
        _magerun2 config:store:set web/secure/base_url https://$1/
        _magerun2 config:store:set web/cookie/cookie_domain $1
    fi

    _magerun2 admin:notifications --off

    _dev:m2:cache

}

_dev:m2:developer() {
    composer -vvv require --dev diepxuan/module-email
    _dev:m2:perm
    _dev:m2:rmgen
    _dev:m2:static
    _dev:m2:cache

    _magerun2 maintenance:enable
    _magerun2 deploy:mode:set developer
    _magerun2 module:enable --all
    _magento setup:upgrade
    _magerun2 setup:di:compile
    _magerun2 maintenance:disable

    _dev:m2:cache
    _dev:m2:perm
}

# _DUCTN_M2+=(delsolr)
# _dev:m2:delsolr() {
#     sudo su solr -c "/opt/solr/bin/solr delete -c ${1}"
# }

# _DUCTN_M2+=(addsolr)
# _dev:m2:addsolr() {
#     sudo su solr -c "/opt/solr/bin/solr delete -c ${1}"
#     sudo su solr -c "/opt/solr/bin/solr create -c ${1}"
#     cat vendor/partsbx/core/src/module-partsbx-solr/conf/managed-schema | sudo su solr -c "tee /var/solr/data/${1}\/conf/managed-schema"
#     sudo service solr restart
#     unset -f _m2fixsolr
# }

_dev:m2:logenable() {
    _magento dev:query-log:enable
}

_dev:m2:logdisable() {
    _magento dev:query-log:disable
}

_dev:m2:tempdebugenable() {
    _magerun2 dev:template-hints-blocks --on
    _magerun2 dev:template-hints --on
}

_dev:m2:tempdebugdisable() {
    _magerun2 dev:template-hints-blocks --off
    _magerun2 dev:template-hints --off
}

# _dev:m2:install() {
#     curl -O https://files.magerun.net/n98-magerun2.phar && chmod +x n98-magerun2.phar && mv n98-magerun2.phar /usr/local/bin/magerun2
# }

_dev:m2:completion() {
    symfony-autocomplete --shell=bash -- magerun2 | sed '1d ; $ s/$/.phar '"n98-magerun2 magerun2"'/' | tee /etc/bash_completion.d/n98-magerun2
}

_dev:m2:completion:commands() {
    declare -F | grep _dev:m2: | awk '{print $3}' | cut -f3 -d':' | grep -v -e "^$" | awk '{print $1}'
}

_magerun2() {
    [[ ! -f bin/magento ]] && exit 0
    [[ ! -f bin/magerun2 ]] &&
        curl -O https://files.magerun.net/n98-magerun2.phar &&
        chmod +x n98-magerun2.phar &&
        mv n98-magerun2.phar bin/magerun2

    [[ -f bin/magerun2 ]] && php -d memory_limit=756M -d max_execution_time=18000 bin/magerun2 $*
}

_magento() {
    [[ -f bin/magento ]] && php -d memory_limit=756M -d max_execution_time=18000 bin/magento $*
}

_grunt() {
    npx grunt --version >/dev/null 2>&1 || npm install
    npx grunt --version >/dev/null 2>&1 && npx grunt $*
}

d_m2() {
    [[ ! -f bin/magento ]] && exit 0
    [[ $(type -t _dev:m2:$1) == function ]] && "_dev:m2:$@" && exit 0
    [[ ! $(type -t _dev:m2:$1) == function ]] && php -d memory_limit=756M -d max_execution_time=18000 bin/magento $@
}

--isenabled() {
    echo '1'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
