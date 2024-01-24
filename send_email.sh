#!/bin/bash
#
#********************************************************************
#Author:            bmxch
#QQ:                1786964965
#Date:              2022-04-25
#FileName:          send_email.sh
#URL:               https://blog.csdn.net/bmxch?type=blog
#Description:       自动化设置root密码为随机数
#Copyright (C):     2023 All rights reserved
#********************************************************************

# 提示用户输入电子邮件地址  

echo "请输入您的电子邮件地址："  

read email_send  


# 提示用户输入电子邮件密码或者令牌  

echo "请输入您的电子邮件密码或者令牌："  

read -s email_passwd  # 使用-s选项来隐藏输入的密码 

email_smtp_server='smtp.qq.com'

. /etc/os-release

msg_error() {
  echo -e "\033[1;31m$1\033[0m"
}

msg_info() {
  echo -e "\033[1;32m$1\033[0m"
}

msg_warn() {
  echo -e "\033[1;33m$1\033[0m"
}


color () {
    RES_COL=60
    MOVE_TO_COL="echo -en \\033[${RES_COL}G"
    SETCOLOR_SUCCESS="echo -en \\033[1;32m"
    SETCOLOR_FAILURE="echo -en \\033[1;31m"
    SETCOLOR_WARNING="echo -en \\033[1;33m"
    SETCOLOR_NORMAL="echo -en \E[0m"
    echo -n "$1" && $MOVE_TO_COL
    echo -n "["
    if [ $2 = "success" -o $2 = "0" ] ;then
        ${SETCOLOR_SUCCESS}
        echo -n $"  OK  "    
    elif [ $2 = "failure" -o $2 = "1"  ] ;then 
        ${SETCOLOR_FAILURE}
        echo -n $"FAILED"
    else
        ${SETCOLOR_WARNING}
        echo -n $"WARNING"
    fi
    ${SETCOLOR_NORMAL}
    echo -n "]"
    echo 
}


install_sendemail () {
    if [[ $ID =~ rhel|centos|rocky ]];then
        rpm -q sendemail &> /dev/null ||  yum install -y sendemail
    elif [ $ID = 'ubuntu' ];then
        dpkg -l sendemail &>/dev/null || { apt update; apt install -y libio-socket-ssl-perl libnet-ssleay-perl sendemail ; } 
    else
        color "不支持此操作系统，退出!" 1
        exit
    fi
}

send_email () {
    # 定义并接受三个参数：接收者邮箱、邮件主题和邮件内容  

    local email_receive="$1"  # 接收者邮箱  

    local email_subject="$2"   # 邮件主题  

    local email_message="$3"   # 邮件内容 

    # 使用sendemail命令发送邮件。sendemail是一个用于发送邮件的命令行工具。  
    # 这里使用了-f, -t, -u, -m, -s, -o message-charset=utf-8, -o tls=yes, -xu 和 -xp 参数来设置发件人邮箱、收件人邮箱、邮件主题、邮件内容、SMTP服务器地址等。  
    # 注意：这里需要确保$email_send, $email_smtp_server, $email_send 和 $email_passwd 这些变量已经被正确设置。  
    sendemail -f $email_send -t $email_receive -u $email_subject -m $email_message -s $email_smtp_server -o message-charset=utf-8 -o tls=yes -xu $email_send -xp $email_passwd
    
    [ $? -eq 0 ] && color "邮件发送成功!" 0 || color "邮件发送失败!" 1 
}

if [ $# -ne 3 ];then 
    color "脚本参数不正确!" 1
    msg_info "Usage: `basename $0` <mail_address> <subject> <message>"
    exit 1
fi

install_sendemail 

send_email "$1" "$2" "$3"
