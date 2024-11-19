#!/bin/bash

# 颜色输出
print_green() {
    echo -e "\e[32m$1\e[0m"
}

print_red() {
    echo -e "\e[31m$1\e[0m"
}

# 一键执行函数
execute_migration() {
    print_green "开始下载并执行迁移脚本..."
    # 直接下载并通过bash执行,无需chmod
    curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/docker-migration-tools/main/docker_migrate.sh | sudo bash -s -- "$@"
}

# 显示使用方法
show_usage() {
    echo "使用方法:"
    echo "1. 仅备份:"
    echo "   curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/docker-migration-tools/main/install.sh | bash -s backup"
    echo 
    echo "2. 备份并迁移:"
    echo "   curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/docker-migration-tools/main/install.sh | bash -s migrate username@target_server"
}

# 主函数
main() {
    if [ $# -eq 0 ]; then
        show_usage
        exit 1
    fi
    
    execute_migration "$@"
}

# 执行主函数,传入所有参数
main "$@"
