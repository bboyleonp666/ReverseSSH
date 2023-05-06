#!/bin/bash

MSG() {
    echo -e -n "[$(date '+%Y%m%d-%H%M%S')] [MESSAGE] $1\r\n"
}

reverse_ssh_inputs() {
    while [[ ! -n $public_ip ]]; do
        MSG "You have to input Public IP to continue!"
	read -p "Public IP: " public_ip
    done

    while [[ ! -n $public_user ]]; do
        MSG "You have to input Public IP user to continue!"
	read -p "Public IP user: " public_user
    done

    echo
    MSG "Press Enter to keep the following as default"
    read -p "Remote host port: " remote_port
    read -p "Remote host ssh port: " remote_ssh_port
    read -p "SSH key name: " ssh_key_name
    echo
    read -p "Are all of the above correct (default: Y)? [Y/n] " check
    case $check in
        [nN] )
	    MSG "Retry again ..."
	    echo
            reverse_ssh_inputs
	    ;;

	* )
	    MSG "Continue ..."
	    ;;
    esac
}


MSG "This script should be run under your remote (private) host"
MSG "If you are now in your VPS (your public IP server), then press Ctrl+C to exit!"
read -p "Is this your remote (private) host? (default: true)" check
echo

# This script should be run under your remote host
SSH_DIR="/home/$(logname)/.ssh"

default_remote_port=5209
default_remote_ssh_port=22
default_ssh_key_name=reverse_ssh_rsa

MSG "Please input the following information ..."
echo "=================================================="
MSG "Public IP            | the public IP of your server or VPS     |"
MSG "Public IP user       | the user of your server or VPS          |"
MSG "Remote host port     | the port to forward your ssh connection | default: $default_remote_port"
MSG "Remote host ssh port | in case your ssh port is not 22         | default: $default_remote_ssh_port"
MSG "SSH key name         | the ssh public key pair name            | default: $default_ssh_key_name"
echo "=================================================="
echo
reverse_ssh_inputs


[[ -n $remote_port ]] || remote_port=$default_remote_port
[[ -n $remote_ssh_port ]] || remote_ssh_port=$default_remote_ssh_port
[[ -n $ssh_key_name ]] || ssh_key_name=$default_ssh_key_name

MSG "Get fingerprint for ssh"
ssh -t "$public_user@$public_ip" "exit"

MSG "Make directory ssh directory"
mkdir -p "$SSH_DIR"

MSG "Generating public key pair"
ssh-keygen -t rsa -N "" -f "$SSH_DIR/$ssh_key_name"

MSG "Copy public key to '$public_ip'"
ssh-copy-id -i "$SSH_DIR/$ssh_key_name" "$public_user@$public_ip"

MSG "Make config file ..."
SSH_CONF="$SSH_DIR/config"
[[ -e $SSH_CONF ]] || touch $SSH_CONF

MSG "Writing config to $SSH_CONF"
HOST=reverseTunnel
while [[ $(grep "Host $HOST" $SSH_CONF ) ]]; do
    MSG "Host '$HOST' already exist"
    MSG "Please give it a new name"
    read -p "New Host: " HOST
done

echo "Host $HOST" >> $SSH_CONF
echo "    HostName $public_ip" >> $SSH_CONF
echo "    RemoteForward $remote_port localhost:$remote_ssh_port" >> $SSH_CONF
echo "    ServerAliveInterval 60" >> $SSH_CONF
echo "    IdentityFile $SSH_DIR/$ssh_key_name" >> $SSH_CONF
echo "    User $public_user" >> $SSH_CONF
echo "" >> $SSH_CONF

MSG "Setup is finished!"
MSG "You can enjoy your reverse tunnel via ssh by the following command"
MSG "  $ ssh -Nf $HOST"
