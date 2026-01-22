# 修改默认IP & 固件名称 & 编译署名
sed -i 's/192.168.1.1/192.168.106.1/g' package/base-files/files/bin/config_generate
# sed -i "s/hostname='.*'/hostname='Roc'/g" package/base-files/files/bin/config_generate
# sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ Built by Roc')/g" feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js

# 更改默认shell为bash
echo "/bin/bash"  >> package/base-files/files/etc/shells && sed -i 's#^root:x:0:0:root:/root:/bin/ash$#root:x:0:0:root:/root:/bin/bash#' package/base-files/files/etc/passwd;

function cat_kernel_config() {
  if [ -f $1 ]; then
    cat >> $1 <<EOF
CONFIG_BPF=y
CONFIG_BPF_SYSCALL=y
CONFIG_BPF_JIT=y
CONFIG_CGROUPS=y
CONFIG_KPROBES=y
CONFIG_NET_INGRESS=y
CONFIG_NET_EGRESS=y
CONFIG_NET_SCH_INGRESS=m
CONFIG_NET_CLS_BPF=m
CONFIG_NET_CLS_ACT=y
CONFIG_BPF_STREAM_PARSER=y
CONFIG_DEBUG_INFO=y
# CONFIG_DEBUG_INFO_REDUCED is not set
CONFIG_DEBUG_INFO_BTF=y
CONFIG_KPROBE_EVENTS=y
CONFIG_BPF_EVENTS=y

CONFIG_SCHED_CLASS_EXT=y
CONFIG_PROBE_EVENTS_BTF_ARGS=y
CONFIG_IMX_SCMI_MISC_DRV=y
CONFIG_ARM64_CONTPTE=y
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
# CONFIG_TRANSPARENT_HUGEPAGE_NEVER is not set
EOF
    echo "cat_kernel_config to $1 done"
  fi
}


# sed -i "/^define Device\/jdcloud_re-ss-01/,/^endef/ { /KERNEL_SIZE := 6144k/s//KERNEL_SIZE := 12288k/ }" $image_file

#为jdcloud_re-ss 添加12M内核版本，同时保留6M内核版本
# image_file='./target/linux/qualcommax/image/ipq60xx.mk'
# cp ./target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6000-re-ss-01.dts ./target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6000-re-ss-01-dae.dts

# # 添加正确的12M内核版本设备定义，复用原有的DTS文件
# cat >> $image_file <<'EOF'

# define Device/jdcloud_re-ss-01-dae
# 	$(call Device/FitImage)
# 	$(call Device/EmmcImage)
# 	DEVICE_VENDOR := JDCloud
# 	DEVICE_MODEL := RE-SS-01
# 	DEVICE_VARIANT := DAE
# 	DEVICE_ALT0_VENDOR := JDCloud
# 	DEVICE_ALT0_VARIANT := DAE
# 	KERNEL_SIZE := 12288k
# 	BLOCKSIZE := 128k
# 	SOC := ipq6000
# 	DEVICE_DTS_CONFIG := config@cp03-c2
# 	DEVICE_PACKAGES := ipq-wifi-jdcloud_re-ss-01
# 	IMAGE/factory.bin := append-kernel | pad-to $$(KERNEL_SIZE) | append-rootfs | append-metadata
# endef
# TARGET_DEVICES += jdcloud_re-ss-01-dae
# EOF

cat_kernel_config "target/linux/qualcommax/ipq60xx/config-default"





rm -rf package/emortal/luci-app-athena-led
git clone --depth=1 https://github.com/NONGFAH/luci-app-athena-led package/luci-app-athena-led
chmod +x package/luci-app-athena-led/root/etc/init.d/athena_led package/luci-app-athena-led/root/usr/sbin/athena-led


# 调整NSS驱动q6_region内存区域预留大小（ipq6018.dtsi默认预留85MB，ipq6018-512m.dtsi默认预留55MB，带WiFi必须至少预留54MB，以下分别是改成预留16MB、32MB、64MB和96MB）
# sed -i 's/reg = <0x0 0x4ab00000 0x0 0x[0-9a-f]\+>/reg = <0x0 0x4ab00000 0x0 0x01000000>/' target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6018-512m.dtsi
# sed -i 's/reg = <0x0 0x4ab00000 0x0 0x[0-9a-f]\+>/reg = <0x0 0x4ab00000 0x0 0x02000000>/' target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6018-512m.dtsi
# sed -i 's/reg = <0x0 0x4ab00000 0x0 0x[0-9a-f]\+>/reg = <0x0 0x4ab00000 0x0 0x04000000>/' target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6018-512m.dtsi
# sed -i 's/reg = <0x0 0x4ab00000 0x0 0x[0-9a-f]\+>/reg = <0x0 0x4ab00000 0x0 0x06000000>/' target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6018-512m.dtsi

git clone --depth=1 https://github.com/nikkinikki-org/OpenWrt-nikki package/OpenWrt-nikki
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2  package/openwrt-passwall2
git clone --depth=1 -b lede https://github.com/pymumu/luci-app-smartdns package/luci-app-smartdns
git clone --depth=1 https://github.com/pymumu/openwrt-smartdns package/smartdns
git clone --depth=1 https://github.com/sbwml/luci-app-openlist2 package/openlist
git clone --depth=1 https://github.com/EasyTier/luci-app-easytier.git package/luci-app-easytier

./scripts/feeds update -a
./scripts/feeds install -a