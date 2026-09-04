# pacproxy-tp — Magisk 透明分流模块

透明分流规则模块: 纯 IP 决策(私网+中国 CIDR 直连, 其余走代理), iptables REDIRECT 全量劫持。

## 特性

- **自包含**: 模块目录内嵌 python 运行时(`python/`), 不依赖 Termux/系统 python
- **上游自配置**: 代理地址由 `service.sh` 里 `UPSTREAM` 决定(默认 `127.0.0.1:9910`)
- **规则全自动**: `update.sh` 拉取官方 gfw-pac + 合并 `user-overrides/` 本地规则
- **保活**: `watchdog.sh` 每 10s 检查, 崩溃重启, 连续 3 次失败退避 5min
- **幂等 iptables**: PAC_TP 链被清理时自动重建

## 安装

Magisk 管理器中"从本地安装"

安装后默认监听 `6045`, 上游 `127.0.0.1:9910`。改上游不需要重新安装 — 写配置文件后重启服务:

```bash
# /data/adb/pacproxy-tp.conf (模块目录外, 升级/重装不丢)
echo 'UPSTREAM=127.0.0.1:9909' > /data/adb/pacproxy-tp.conf
su -c "sh /data/adb/modules/pacproxy-tp/service.sh stop"
su -c "sh /data/adb/modules/pacproxy-tp/service.sh start"
```

## 规则更新

```bash
su -c "sh /data/adb/modules/pacproxy-tp/update.sh"
```

拉取官方 `zhiyi7/gfw-pac` 规则 + `user-overrides/` 合并 → 重启 pacproxy。

## 构建 (从源码打包 Magisk zip)

```bash
# 需要: 已裁剪的 python 运行时 tar.gz (见下)
PYTHON_TAR=/path/to/pacproxy-python-slim.tar.gz ./build.sh
# 产物: dist/pacproxy-tp-vVERSION.zip
```

python 运行时由 `mk-python-slim.sh` 从 Termux python 3.10 构建裁剪(生产步骤见该脚本), 构建一次后作为 Release asset 固化。

## 目录结构

```
pacproxy-tp/
├── module.prop          # Magisk 模块元数据
├── pacproxy.py          # 分流核心 (Python asyncio)
├── service.sh           # 启动/停止 + iptables 劫持
├── watchdog.sh          # 保活
├── update.sh            # 规则更新
├── uninstall.sh         # 清理 iptables
├── build.sh             # 打包 Magisk zip
├── mk-python-slim.sh    # 裁剪 python 运行时
├── LICENSES/            # 第三方运行时许可文本
└── NOTICE               # 许可声明
```

## 许可

- 模块代码: MIT (见 dotfiles 仓库根 LICENSE)
- 集成 python 运行时: 见 `NOTICE` + `LICENSES/` (CPython PSF-2.0, musl MIT, OpenSSL Apache-2.0 等)
