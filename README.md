# Docker项目迁移工具

一个用于快速迁移Docker项目的交互式命令行工具。

## 功能特点

- 交互式配置
- 自动检查环境依赖
- 支持配置文件
- 错误处理和恢复
- 自动备份

## 使用方法

1. 输入命令：
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/lunarhash/dockermigration/refs/heads/main/install.sh)
```

## 配置文件

配置文件位置：`~/.docker_install_config`

可以手动编辑配置文件来修改默认设置。

## 注意事项

- 确保源服务器和目标服务器都已安装Docker和docker-compose
- 建议在迁移前备份重要数据
- 确保服务器之间可以通过SSH互相访问
