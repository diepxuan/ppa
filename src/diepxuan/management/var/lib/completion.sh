_DUCTN_COMMANDS+=("sys:completion" "sys:completion:commands")

# --sys:completion() {
# [ $(--sys:completion:exists ductn) ] && --sys:completion:base
# [ $(--sys:completion:exists magerun) ] && --sys:completion:magerun
# [ $(--sys:completion:exists magerun2) ] && --sys:completion:magerun2
# [ $(--sys:completion:exists wp) ] && --sys:completion:wp
# [ $(--sys:completion:exists angular) ] && --sys:completion:angular
# }

--sys:completion:base() {
    # bash completion for the `ductn cli` command
    # ################################################################
    if ! shopt -oq posix; then
        if [[ -f /var/www/base/bash/completion/ductn.sh ]]; then
            echo /var/www/base/bash/completion/ductn.sh
        elif [[ -f $HOME/.completion/ductn.sh ]]; then
            echo $HOME/.completion/ductn.sh
        fi
    fi
}

--sys:completion:magerun() {
    # completion magerun
    # ################################################################
    # https://raw.githubusercontent.com/netz98/n98-magerun/develop/res/autocompletion/bash/n98-magerun.phar.bash
    if ! shopt -oq posix; then
        if [[ -f /var/www/base/bash/completion/magerun.sh ]]; then
            echo /var/www/base/bash/completion/magerun.sh
        elif [[ -f $HOME/.completion/magerun.sh ]]; then
            echo $HOME/.completion/magerun.sh
        fi
    fi
}
--sys:completion:magerun2() {
    # completion magerun2
    # ################################################################
    # https://raw.githubusercontent.com/netz98/n98-magerun2/develop/res/autocompletion/bash/n98-magerun2.phar.bash
    if ! shopt -oq posix; then
        if [[ -f /var/www/base/bash/completion/magerun2.sh ]]; then
            echo /var/www/base/bash/completion/magerun2.sh
        elif [[ -f $HOME/.completion/magerun2.sh ]]; then
            echo $HOME/.completion/magerun2.sh
        fi
    fi
}

--sys:completion:wp() {
    # bash completion for the `wp` command
    # ################################################################
    if ! shopt -oq posix; then
        if [[ -f /var/www/base/bash/completion/wp.sh ]]; then
            echo /var/www/base/bash/completion/wp.sh
        elif [[ -f $HOME/.completion/wp.sh ]]; then
            echo $HOME/.completion/wp.sh
        fi
    fi
}

--sys:completion:angular() {
    # bash completion for the `angular cli` command
    # ################################################################
    if ! shopt -oq posix; then
        if [[ -f /var/www/base/bash/completion/angular2.sh ]]; then
            echo /var/www/base/bash/completion/angular2.sh
        elif [[ -f $HOME/.completion/angular2.sh ]]; then
            echo $HOME/.completion/angular2.sh
        fi
    fi
}

--sys:completion:commands() {
    echo "${_DUCTN_COMMANDS[*]}"
}

--sys:completion:exists() {
    [ ! -x "$(command -v $@)" ] && echo 0 || echo 1
}
