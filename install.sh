#!/bin/bash

# 检查是否安装了必要的工具
check_tools() {
    for tool in ssh tar docker scp; do
        if ! command -v $tool &>/dev/null; then
            echo "错误：请先安装 $tool"
            exit 1
        fi
    done
}

# 选择要迁移的文件夹
select_project() {
    echo "以下是 /home 文件夹中的项目："
    ls /home
    read -p "请输入要迁移的项目名称（输入 'all' 迁移全部项目）： " PROJECT_NAME
    if [[ "$PROJECT_NAME" != "all" ]] && [ ! -d "/home/$PROJECT_NAME" ]; then
        echo "错误：/home/$PROJECT_NAME 不存在，请重新运行脚本并输入正确的项目名称。"
        exit 1
    fi
}

# 输入目标服务器信息
get_server_info() {
    read -p "请输入目标服务器的用户名（例如 root）： " TARGET_USER
    read -p "请输入目标服务器的IP地址： " TARGET_IP
    echo "请输入目标服务器的密码："
    read -s TARGET_PASSWORD
}

# 打包项目和 Docker 数据
package_project() {
    echo "正在打包项目和 Docker 数据..."
    TIMESTAMP=$(date +"%Y%m%d%H%M%S")
    BACKUP_FILE="/home/docker_migration_backup_$TIMESTAMP.tar.gz"

    if [[ "$PROJECT_NAME" == "all" ]]; then
        echo "正在打包所有项目..."
        docker save $(docker images -q) > /home/docker_images_backup.tar
        tar -czvf "$BACKUP_FILE" /home /home/docker_images_backup.tar /var/lib/docker/volumes/
    else
        echo "正在打包项目 $PROJECT_NAME..."
        docker save $(docker images -q) > /home/docker_images_backup.tar
        tar -czvf "$BACKUP_FILE" "/home/$PROJECT_NAME" /home/docker_images_backup.tar /var/lib/docker/volumes/
    fi
    echo "打包完成：$BACKUP_FILE"
}

# 传输到新服务器
transfer_to_new_server() {
    echo "正在将打包文件传输到目标服务器..."
    export SSHPASS=$TARGET_PASSWORD
    sshpass -e scp "$BACKUP_FILE" $TARGET_USER@$TARGET_IP:/home/
    if [ $? -eq 0 ]; then
        echo "文件已成功传输到 $TARGET_USER@$TARGET_IP:/home/"
    else
        echo "文件传输失败，请检查网络或目标服务器信息。"
        exit 1
    fi
    unset SSHPASS
}

# 在新服务器上解压并恢复
restore_on_new_server() {
    echo "请在新服务器上运行以下命令手动恢复数据："
    echo "-------------------------------------------------"
    echo "ssh $TARGET_USER@$TARGET_IP"
    echo "tar -xzvf /home/docker_migration_backup_$TIMESTAMP.tar.gz -C /"
    echo "docker load < /home/docker_images_backup.tar"
    echo "echo '数据恢复完成，请检查。'"
    echo "-------------------------------------------------"
}

# 主函数
main() {
    check_tools
    select_project
    get_server_info
    package_project
    transfer_to_new_server
    restore_on_new_server
}

main
