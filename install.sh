#!/bin/bash

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 配置文件
CONFIG_FILE="$HOME/.docker_migrate_config"

# 默认值
DEFAULT_SOURCE_DIR="$HOME"
DEFAULT_PROJECTS=("a" "b" "c" "d")

# 函数：打印带颜色的信息
print_message() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 函数：读取用户输入，带默认值
read_input() {
    local prompt="$1"
    local default="$2"
    local input
    
    echo -en "${BLUE}$prompt${NC} (默认: $default): "
    read input
    echo "${input:-$default}"
}

# 函数：确认操作
confirm() {
    local prompt="$1"
    local response
    
    echo -en "${BLUE}$prompt${NC} (y/N): "
    read response
    
    case "$response" in
        [yY][eE][sS]|[yY]) 
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# 函数：加载或创建配置
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        print_message "发现配置文件，正在加载..."
        source "$CONFIG_FILE"
    else
        print_message "未发现配置文件，将创建新配置..."
        TARGET_SERVER=$(read_input "请输入目标服务器地址 (格式: user@host)" "root@localhost")
        
        # 保存配置
        cat > "$CONFIG_FILE" << EOF
TARGET_SERVER="$TARGET_SERVER"
EOF
        print_success "配置已保存至 $CONFIG_FILE"
    fi
}

# 函数：检查必要条件
check_prerequisites() {
    print_message "检查必要条件..."
    
    # 检查 Docker
    if ! command -v docker &> /dev/null; then
        print_error "未找到 Docker，请先安装 Docker"
        exit 1
    fi
    
    # 检查 docker-compose
    if ! command -v docker-compose &> /dev/null; then
        print_error "未找到 docker-compose，请先安装 docker-compose"
        exit 1
    }
    
    print_success "必要条件检查完成"
}

# 函数：停止容器
stop_containers() {
    print_message "准备停止容器..."
    
    for project in "${DEFAULT_PROJECTS[@]}"; do
        if [ -f "$SOURCE_DIR/$project/docker-compose.yml" ]; then
            print_message "正在停止 $project 的容器..."
            docker-compose -f "$SOURCE_DIR/$project/docker-compose.yml" down || {
                print_error "停止 $project 容器失败"
                confirm "是否继续？" || exit 1
            }
        fi
    done
    
    print_success "所有容器已停止"
}

# 函数：创建备份
create_backup() {
    local BACKUP_NAME="docker_projects_$(date +%Y%m%d_%H%M%S)"
    print_message "创建备份: $BACKUP_NAME"
    
    cd "$SOURCE_DIR" || exit 1
    tar -czf "${BACKUP_NAME}.tar.gz" "${DEFAULT_PROJECTS[@]}" || {
        print_error "创建备份失败"
        exit 1
    }
    
    print_success "备份创建完成: ${BACKUP_NAME}.tar.gz"
    echo "$BACKUP_NAME"
}

# 函数：传输文件
transfer_files() {
    local BACKUP_NAME="$1"
    print_message "准备传输文件到 $TARGET_SERVER..."
    
    scp "${BACKUP_NAME}.tar.gz" "$TARGET_SERVER:$HOME/" || {
        print_error "文件传输失败"
        exit 1
    }
    
    print_success "文件传输完成"
}

# 主函数
main() {
    print_message "Docker项目迁移工具启动..."
    
    # 加载配置
    load_config
    
    # 检查必要条件
    check_prerequisites
    
    # 确认源目录
    SOURCE_DIR=$(read_input "请输入源项目目录" "$DEFAULT_SOURCE_DIR")
    
    # 确认项目列表
    print_message "当前将迁移以下项目: ${DEFAULT_PROJECTS[*]}"
    if ! confirm "是否继续？"; then
        print_message "操作已取消"
        exit 0
    fi
    
    # 执行迁移步骤
    stop_containers
    BACKUP_NAME=$(create_backup)
    transfer_files "$BACKUP_NAME"
    
    # 打印后续步骤
    cat << EOF

${GREEN}迁移完成！后续步骤：${NC}

1. 登录新服务器:
   ssh $TARGET_SERVER

2. 解压文件:
   cd $HOME
   tar -xzf ${BACKUP_NAME}.tar.gz

3. 启动服务:
   for dir in ${DEFAULT_PROJECTS[*]}; do
       cd \$HOME/\$dir && docker-compose up -d
   done

${BLUE}提示：本脚本已保存配置在 $CONFIG_FILE${NC}
EOF
}

# 执行主函数
main
