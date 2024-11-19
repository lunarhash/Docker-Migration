# Docker Migration Tools

一个用于 Docker 项目完整迁移的工具集。

## 快速使用

直接从 GitHub 下载并执行:

```bash
curl -o docker_migrate.sh https://raw.githubusercontent.com/YOUR_USERNAME/docker-migration-tools/main/docker_migrate.sh
chmod +x docker_migrate.sh
```

## 使用方法

1. 仅备份:
```bash
sudo ./docker_migrate.sh backup
```

2. 备份并迁移:
```bash
sudo ./docker_migrate.sh migrate username@new_server_ip
```

## 功能特点

- 自动备份整个 home 目录
- 智能排除无用文件和目录
- 自动时间戳备份文件
- 彩色输出提示信息
- 完整性检查

## 注意事项

1. 请确保有足够的磁盘空间
2. 建议先配置 SSH 密钥
3. 需要 root 权限运行

## 许可证

MIT License
