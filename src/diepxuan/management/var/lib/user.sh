#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("user:new")
--user:new() {
    local user=$1

    sudo adduser $user --disabled-password --gecos \"\"
    sudo adduser $user www-data
    sudo usermod -aG www-data $user
    id -u $user

    sudo mkdir -p /home/$user/.ssh
    cat ~/.ssh//id_rsa.pub | sudo tee --append /home/$user/.ssh/authorized_keys >/dev/null

    --user:config $user
}

_DUCTN_COMMANDS+=("user:config")
--user:config() {
    local user=$1
    [[ -z $user ]] && user=$(whoami)

    if [[ $user = "ductn" ]]; then
        --user:config:admin $user

        [[ -n $(groups $user | grep -e 'mssql') ]] || sudo usermod -aG mssql $user >/dev/null 2>&1
        [[ -n $(groups $user | grep -e 'www-data') ]] || sudo usermod -aG www-data $user >/dev/null 2>&1
    fi

    --user:config:bash $user
    --user:config:chmod $user
}

--user:config:bash() {
    local user=$1
    [[ -z $user ]] && user=$(whoami)
    sudo sed -i 's/.*force_color_prompt\=.*/force_color_prompt\=yes/' /home/$user/.bashrc >/dev/null
    [[ -f /home/$user/.bash_aliases ]] && sudo sed -i "s|.*/var/www/base/bash/.bash_aliases.*||" /home/$user/.bash_aliases >/dev/null

    local match="########## DUCTN Aliases ##########"
    local aliases=/home/$user/.bash_aliases
    local match_index=$(grep "$match" $aliases | wc -l)

    sudo touch $aliases
    if [[ $match_index == 0 ]]; then
        echo $match | sudo tee -a $aliases >/dev/null
        echo $match | sudo tee -a $aliases >/dev/null
    elif [[ $match_index == 1 ]]; then
        sudo sed -i "/$match/a\\$match" $aliases
    fi

    cat <<'EOF' | sudo sed -i -e "/$match/{:a;N;/\n$match$/!ba;r /dev/stdin" -e ";d}" $aliases
########## DUCTN Aliases ##########
PS1="$PS1 \n$ "

export PATH=$PATH:$HOME/bin:$HOME/.composer/vendor/bin
[ -d $HOME/.config/composer ] && export PATH=$PATH:$HOME/.config/composer/vendor/bin
[ -d $HOME/.composer ] && export PATH=$PATH:$HOME/.composer/vendor/bin

[ -d /opt/mssql-tools/bin/ ] && PATH="$PATH:/opt/mssql-tools/bin"
[ -d /opt/mssql/bin/ ] && PATH="$PATH:/opt/mssql/bin"

alias ll >/dev/null 2>&1 || alias ll="ls -alF"

########## DUCTN Aliases ##########
EOF
}

--user:config:chmod() {
    local user=$1
    [[ -z $user ]] && user=$(whoami)

    sudo chmod 755 /home/$user

    sudo mkdir -p /home/$user/.ssh
    sudo chmod 777 /home/$user/.ssh

    sudo chmod -R 600 /home/$user/.ssh
    sudo chmod 700 /home/$user/.ssh
    sudo chown -R $user:$user /home/$user/.ssh

    sudo chmod 644 /home/$user/.bash_aliases
    sudo chown -R $user:$user /home/$user/.bash_aliases

    sudo mkdir -p /home/$user/public_html
    sudo chmod 755 /home/$user/public_html
    sudo chown -R $user:www-data /home/$user/public_html

    sudo mkdir -p /home/$user/.ssl
    sudo chown -R $user:$user /home/$user/.ssl
}

--user:config:admin() {
    [[ -f /etc/sudoers.d/90-users ]] && return
    echo "ductn ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/90-users >/dev/null
}

--user:is_sudoer() {
    local user=$(whoami)
    [[ -n $1 ]] && user=$1
    [[ -n $(groups $user | grep -e 'sudo\|root') ]]
}
