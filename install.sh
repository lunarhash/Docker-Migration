#!/bin/bash

echo "欢迎使用 Docker 项目迁移脚本！"

# 提示用户输入变量
read -p "请输入源目录 (默认: /home): " SOURCE_HOME_DIR
SOURCE_HOME_DIR=${SOURCE_HOME_DIR:-/home}

read -p "请输入目标服务器 IP 或主机名: " TARGET_SERVER
read -p "请输入目标服务器用户名: " TARGET_USER
read -p "目标服务器上的目标目录 (默认: /home): " TARGET_HOME_DIR
TARGET_HOME_DIR=${TARGET_HOME_DIR:-/home}

# 确认输入
echo "您输入的信息如下："
echo "源目录: $SOURCE_HOME_DIR"
echo "目标服务器: $TARGET_SERVER"
echo "目标用户名: $TARGET_USER"
echo "目标目录: $TARGET_HOME_DIR"
read -p "确认无误后按回车键继续 (Ctrl+C 取消)..."

# 检查源目录是否存在
if [ ! -d "$SOURCE_HOME_DIR" ]; then
    echo "错误：源目录 $SOURCE_HOME_DIR 不存在！"
    exit 1
fi

# 打包源文件夹
echo "正在打包源文件夹..."
tar -czvf home_backup.tar.gz -C $(dirname $SOURCE_HOME_DIR) $(basename $SOURCE_HOME_DIR)

# 传输到目标服务器
echo "正在将打包文件传输到目标服务器..."
scp home_backup.tar.gz ${TARGET_USER}@${TARGET_SERVER}:~

# 在目标服务器上解压、检查环境、设置权限并启动项目
echo "正在目标服务器上执行操作..."
ssh ${TARGET_USER}@${TARGET_SERVER} << EOF
    echo "正在解压文件..."
    tar -xzvf ~/home_backup.tar.gz -C $(dirname $TARGET_HOME_DIR)

    echo "检查是否安装 Docker 和 Docker Compose..."
    if ! command -v docker &> /dev/null; then
        echo "Docker 未安装，正在安装 Docker..."
        curl -fsSL https://get.docker.com | bash
        sudo systemctl start docker
        sudo systemctl enable docker
    else
        echo "Docker 已安装。"
    fi

    if ! command -v docker-compose &> /dev/null; then
        echo "Docker Compose 未安装，正在安装 Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '(?<=tag_name": ")[^"]*')/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    else
        echo "Docker Compose 已安装。"
    fi

    echo "设置目标目录权限..."
    sudo chown -R ${TARGET_USER}:${TARGET_USER} ${TARGET_HOME_DIR}
    sudo chmod -R 755 ${TARGET_HOME_DIR}

    echo "启动所有 Docker 项目..."
    cd ${TARGET_HOME_DIR}
    for project in \$(ls); do
        if [ -d "\$project" ] && [ -f "\$project/docker-compose.yml" ]; then
            echo "正在启动项目: \$project"
            cd "\$project"
            docker-compose up -d
            cd ..
        fi
    done

    echo "所有操作完成！"
EOF

# 提示用户是否清理本地文件
read -p "是否删除本地打包文件 (y/n)? " CLEANUP
if [ "$CLEANUP" == "y" ] || [ "$CLEANUP" == "Y" ]; then
    echo "清理本地打包文件..."
    rm home_backup.tar.gz
else
    echo "本地打包文件已保留为: home_backup.tar.gz"
fi

echo "迁移完成！"
