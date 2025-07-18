# 贝塔系统封装

根据 [packer-maas](https://github.com/canonical/packer-maas) 做的定制化封装模板

## 环境要求

- 支持虚拟化的物理机或支持虚拟化嵌套的虚拟机
- Ubuntu 24.04 LTS (理论22.04+)

## 依赖安装

> 注意下载 Git LFS

```bash
cd ~
git clone https://github.com/btzen/bt-packer-maas.git
cd bt-packer-maas
sudo ./install_deps.sh
```

## 封装系统

1. 上传系统镜像（推荐放在`~`目录下，例：`windows10.iso`）
2. 进入封装系统模板目录（例：`cd ~/bt-packer-maas/windows10`）
3. 执行 make 命令，具体参数请看对应模板目录下的 `README.md`
4. 自动脚本执行完毕后手动调整系统，例如系统更新，手动调整完毕后，手动运行完成脚本等待 QEMU 关机
5. 导出封装完成的镜像（例：`windows10.dd.gz`）
