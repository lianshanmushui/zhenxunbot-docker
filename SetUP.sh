#!/bin/bash
###
 # @Author: 源源球球✨ 1340793687@outlook.com
 # @Date: 2022-06-22 12:57:13
 # @LastEditors: 源源球球✨ 1340793687@outlook.com
 # @LastEditTime: 2022-06-22 15:50:44
 # @FilePath: /zhenxunbot-docker/SetUP.sh
 # @Description: 
 # 
 # Copyright (c) 2022 by 源源球球✨ 1340793687@outlook.com, All Rights Reserved. 
###


function docker_check()
{
	echo "🐋正在检查Docker环境"
    sleep 1s
	docker -v
    if [ $? -eq  0 ]; then
        echo "🚀检查到Docker已安装"
        sleep 1s
    else
        echo "😢你没有安装Docker,请先安装后再执行此脚本..."
        sleep 3s
        exit 1
    fi
}

function read_config()
{
    echo "✨请按照提示输入信息,有默认值的可以直接按回车使用默认值"
    sleep 3s
    echo ""

    read -p "请输入容器的名字(默认为zhenxun):" container_name
    container_name=${container_name:-"zhenxun"}
    echo -e "\033[32m容器名字已设为$container_name\033[0m"
    echo ""

    read -p "请输入Bot使用的QQ号:" bot_qq
    echo -e "\033[32mBot的QQ号已设为$bot_qq\033[0m"
    echo ""

    read -p "请输入Bot使用的QQ密码:" bot_qq_key
    echo -e "\033[32mBot的QQ密码已设为$bot_qq_key\033[0m"
    echo ""

    read -p "请输入超级用户的QQ号:" admin_qq
    echo -e "\033[32m超级用户的QQ号已设为$admin_qq\033[0m"
    echo ""

    read -p "请输入WebUI的用户名(默认为admin):" webui_user
    webui_user=${webui_user:-"admin"}
    echo -e "\033[32mWebUI的用户名已设为$webui_user\033[0m"
    echo ""

    read -p "请输入WebUI的密码(默认为123456):" webui_passwd
    webui_passwd=${webui_passwd:-"123456"}
    echo -e "\033[32mWebUI的密码已设为$webui_passwd\033[0m"
    echo ""

    read -p "请输入WebUI的端口(默认为8080):" webui_port
    webui_port=${webui_port:-"8080"}
    echo -e "\033[32mWebUI的端口已设为$webui_port\033[0m"
    echo ""

    read -p "请输入创建自定义插件目录的绝对位置(默认为当前目录):" plugins_dir
    plugins_dir=${plugins_dir:-"$PWD"}
    echo -e "\033[32m自定义插件目录位置已设为$plugins_dir/my_plugins\033[0m"
    echo ""

    echo "请确认以下配置是否正确"
    echo "容器名字:$container_name"
    echo "Bot的QQ号:$bot_qq"
    echo "Bot的QQ密码:$bot_qq_key"
    echo "超级用户的QQ号:$admin_qq"
    echo "WebUI的用户名:$webui_user"
    echo "WebUI的密码:$webui_passwd"
    echo "WebUI的端口:$webui_port"
    echo "自定义插件目录位置:$plugins_dir/my_plugins"
    sleep 2s

    read -p "是否配置正确?[y/n]" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "\033[32m\n配置正确,开始创建容器\033[0m"
        sleep 2s
        docker_create
    else
        echo "配置未确认,退出"
        exit 1
    fi
}

function docker_create()
{
    echo "开始创建容器"

    docker run -itd \
    -e bot_qq=$bot_qq \
    -e bot_qq_key=$bot_qq_key \
    -e admin_qq=$admin_qq \
    -e webui_user=$webui_user \
    -e webui_passwd=$webui_passwd \
    -p $webui_port:8081 \
    -v $plugins_dir/my_plugins:/home/zhenxun_bot/my_plugins \
    --name=$container_name \
    zhenxun:latest

    if [ $? -eq 0 ]; then
        echo -e "\033[32m🎉Bot容器创建成功!芜湖~\033[0m"
        echo -e "这个脚本好用的话给个Star⭐呗~"
        sed -i '$a\container_name='$container_name'' /etc/profile
        source /etc/profile
        exit 0
    else
        echo -e "\033[31m😢Bot容器创建失败...\033[0m"
        exit 1
    fi
}

function docker_start()
{
    echo "正在启动Bot容器..."
    docker start $container_name
    if [ $? -eq 0 ]; then
        echo "🎉Bot容器启动成功"
    else
        echo "😢Bot容器启动失败"
    fi
}

function docker_stop()
{
    echo "正在停止Bot容器..."
    docker stop $container_name
    if [ $? -eq 0 ]; then
        echo "🎉Bot容器停止成功"
    else
        echo "😢Bot容器停止失败"
    fi
}

function docker_remove()
{
    echo "正在删除Bot容器..."
    docker rm $container_name
    if [ $? -eq 0 ]; then
        echo "🎉Bot容器删除成功"
    else
        echo "😢Bot容器删除失败"
    fi
}

if [ "$UID" -ne "0" ] ;then
    echo '请使用root权限运行此脚本'
    exit 1
else
    source /etc/profile
    echo "✨真寻机器人Docker容器管理脚本"
    PS3='请选择你要执行的功能: '
    options=("创建Bot容器" "启动Bot容器" "停止Bot容器" "删除Bot容器" "退出")
    select opt in "${options[@]}"
    do
        case $opt in
            "创建Bot容器")
                docker_check
                read_config
                ;;
            "启动Bot容器")
                docker_start
                ;;
            "停止Bot容器")
                docker_stop
                ;;
            "删除Bot容器")
                docker_remove
                ;;
            "退出")
                break
                ;;
            *) echo invalid option;;
        esac
    done
fi

