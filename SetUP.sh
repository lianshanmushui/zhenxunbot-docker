#!/bin/bash
###
 # @Author: 源源球球✨ 1340793687@outlook.com
 # @Date: 2022-06-22 12:57:13
 # @LastEditors: 源源球球✨ 1340793687@outlook.com
 # @LastEditTime: 2022-07-05 11:42:49
 # @FilePath: /zhenxunbot-docker/SetUP.sh
 # Copyright (c) 2022 by 源源球球✨ 1340793687@outlook.com, All Rights Reserved. 
###

#预设颜色
red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'
_red() { echo -e ${red}$*${none}; }
_green() { echo -e ${green}$*${none}; }
_yellow() { echo -e ${yellow}$*${none}; }
_magenta() { echo -e ${magenta}$*${none}; }
_cyan() { echo -e ${cyan}$*${none}; }

# 预设语句
docker_is_running=`systemctl status sshd | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1`

read_config()
{
    clear
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

    clear
    echo -e "\033[32m请确认以下配置是否正确\033[0m"
    echo "容器名字:$container_name"
    echo "Bot的QQ号:$bot_qq"
    echo "Bot的QQ密码:$bot_qq_key"
    echo "超级用户的QQ号:$admin_qq"
    echo "WebUI的用户名:$webui_user"
    echo "WebUI的密码:$webui_passwd"
    echo "WebUI的端口:$webui_port"
    echo "自定义插件目录位置:$plugins_dir/my_plugins"
    sleep 2s

    echo ""
    read -p "是否配置正确?[y/n]" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "\033[32m\n配置正确,开始创建容器\033[0m"
        sleep 1s
    else
        echo "配置未确认,退出"
        exit 1
    fi
}

docker_create_if_error()
{
    if [[ $docker_run_log =~ "You have to remove (or rename) that container to be able to reuse that name" ]];then
        echo -e "\033[31m\n❌错误:已经有一个叫$container_name的容器了\033[0m"
    elif [[ $docker_run_log =~ "address already in use" ]];then
        echo -e "\033[31m\n❌错误:端口$webui_port被占用\033[0m"
    else
        echo $docker_run_log
        echo -e "\033[31m❌未知错误\033[0m"
    fi
}

docker_pull()
{
    clear
    # 设置加速器
    if [ ! -f /etc/docker/daemon.json ];then
        echo "🚀没有发现Docker配置,创建Docker配置文件目录"
        mkdir -p /etc/docker
        echo "🐋正在设置镜像下载加速器"
        echo -e "{\n"registry-mirrors": ["https://hyqkgfgr.mirror.aliyuncs.com"]\n}" > /etc/docker/daemon.json
        # 重启Docker
        echo "重新加载Docker设置"
        systemctl daemon-reload
        echo "重启Docker"
        systemctl restart docker
        if [ $? -eq 0 ]; then
            echo -e "\033[32m🐋Docker重启成功\033[0m"
        else
            echo -e "\033[31m❌Docker重启失败...\033[0m"
            exit 1
        fi
    else
        echo "🐋Docker配置文件已存在,不设置加速器"
    fi

    # 下载镜像
##################################https://www.cnblogs.com/YankaiJY/p/8831394.html


    echo "🐋开始下载镜像"
    docker pull jyishit/zhenxun_bot > /tmp/docker_pull.log
    if [ $? -eq 0 ]; then
        clear
        echo -e "\033[32m🐋镜像下载成功\033[0m"
        # docker_pull_log=$(cat /tmp/docker_pull.log)
        # if [[ $docker_pull_log =~ "Image is up to date for jyishit/zhenxun_bot:latest" ]];then
        #     echo -e "\033[32m🐋镜像已经是最新版\033[0m"
        # elif [[ $docker_pull_log =~ "Pull complete" ]];then
        #     echo -e "\033[32m🐋正在下载最新的镜像\033[0m"
        # fi
    else
        # docker_pull_log=$(cat /tmp/docker_pull.log)
        # echo docker_pull_log
        echo -e "\033[31m❌镜像下载失败...\033[0m"
        exit 1
    fi
}

docker_create()
{
    # 创建容器
    echo "🐋开始创建容器"
    docker run -itd \
    -e bot_qq=$bot_qq \
    -e bot_qq_key=$bot_qq_key \
    -e admin_qq=$admin_qq \
    -e webui_user=$webui_user \
    -e webui_passwd=$webui_passwd \
    -p $webui_port:8081 \
    -v $plugins_dir/my_plugins:/home/zhenxun_bot/my_plugins \
    --name=$container_name \
    jyishit/zhenxun_bot > /tmp/docker_run.log 2>&1
    docker_run_log=$(cat /tmp/docker_run.log)
    if [ $? -eq 0 ]; then
        echo -e "\033[32m🎉Bot容器创建成功!\033[0m"
        echo "🐋容器ID是$docker_run_log"
        echo -e "这个脚本好用的话给个Star⭐呗~"
        sed -i '$a\container_name='$container_name'' /etc/profile
        source /etc/profile
        exit 0
    else
        docker_create_if_error
        echo -e "\033[31m❌Bot容器创建失败\033[0m"
        exit 1
    fi
}

docker_start()
{
    echo "正在启动Bot容器..."
    docker start $container_name
    if [ $? -eq 0 ]; then
        echo "🎉Bot容器启动成功"
    else
        echo "❌Bot容器启动失败"
    fi
}

docker_stop()
{
    echo "正在停止Bot容器..."
    docker stop $container_name
    if [ $? -eq 0 ]; then
        echo "🎉Bot容器停止成功"
    else
        echo "❌Bot容器停止失败"
    fi
}

docker_remove()
{
    echo "正在删除Bot容器..."
    docker rm $container_name
    if [ $? -eq 0 ]; then
        echo "🎉Bot容器删除成功"
    else
        echo "❌Bot容器删除失败"
    fi
}

docker_restart()
{
    # echo "正在重启Bot容器..."
    # docker restart $container_name
    # if [ $? -eq 0 ]; then
    #     echo "🎉Bot容器重启成功"
    # else
    #     echo "❌Bot容器重启失败"
    # fi
    #!/bin/bash
i=0
str='#'
ch=('|' '\' '-' '/')
index=0
while [ $i -le 25 ]
do
    printf "[%-25s][%d%%][%c]\r" $str $(($i*4)) ${ch[$index]}
    str+='#'
    let i++
    let index=i%4
    sleep 0.1
done
printf "\n"
echo "安装完成"

}

main()
{
    clear
    echo -e "\e[1;30;47m 真寻Docker辅助脚本 \e[0m"
    source /etc/profile
    PS3='请选择你要执行的功能[1~6]: '
    options=("创建Bot容器" "启动Bot容器" "停止Bot容器" "删除Bot容器" "重启Bot容器" "退出")
    select opt in "${options[@]}"
    do
        case $opt in
            "创建Bot容器")
                read_config
                docker_pull
                docker_create
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
            "重启Bot容器")
                docker_restart
                ;;
            "退出")
                break
                ;;
            *) echo 请选择1~6以内的;;
        esac
    done
}

# 从这里开始执行
# 判断root权限
clear
if [ "$UID" -ne "0" ] ;then
    echo -e "\n 请使用 ${red}root ${none}用户运行 ${yellow}~(^_^) ${none}\n" && exit 1
fi

# 检查Docker
echo "🐋正在检查Docker环境"
# sleep 1s
docker -v
if [ $? -eq  0 ]; then
    echo "🐳检查到Docker已安装"
else
    _red "❌你没有安装Docker,请先安装后再执行此脚本~(^_^)"
    exit 1
fi

# docker服务有没有运行
if [ "$docker_is_running" == "running" ]
    then  
        echo "Docker服务正在运行"
    else
        systemctl start docker
        if [ $? -eq 0 ]; then
            echo "🎉Docker服务启动成功"
        else
            _red "❌Docker服务启动失败"
            exit 1
        fi
fi

# 判断系统
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    if [ -f /etc/redhat-release ]; then
        echo "检测到您的系统为CentOS,这个系统还未经测试"
    elif [ -f /etc/arch-release ]; then
        echo "检测到您的系统为ArchLinux,这个系统还未经测试"
    elif [ -f /etc/debian_version ]; then
        echo -e ""
    else
        echo "这个脚本很可能在你的系统上无法正常运行,自己注意点"
    fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "检测到您的系统为macOS,这个系统还未经测试"
    else
        echo "这个脚本很可能在你的系统上无法正常运行,自己注意点"
fi

# 检测是不是WSL环境
if [ -d /mnt/c ]; then
    echo "检测到此脚本运行在WSL内,将无法自动启动Docker,但不影响其他功能"
fi

# 判断架构
get_arch=`arch`
if [[ $get_arch =~ "x86_64" ]];then
    main
elif [[ $get_arch =~ "aarch64" ]];then
    main
else
    echo -e "❌${red}检测到你的设备不是amd64或arm64架构${none},本镜像不支持你的设备,${yellow}请使用amd64或arm64架构的设备运行本脚本~(^_^)${none}"
    exit 1
fi