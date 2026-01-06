# Install

- Enable and initialize NVMe drive
  - Create install medium
    - Download from https://joshua-riek.github.io/ubuntu-rockchip-download/boards/orangepi-5-plus.html
      - See https://endoflife.date/ubuntu`
    - Create SD (needed for first time) or USB
      - NOTE: SD is needed for the first time, as MTD is empty, and the board can only boot from SD
  - Copy OS image to microSD
  - Boot the device
  - Run `sudo u-boot-install-mtd`
    - NOTE: This adds a bootloader, with boot order: SD, NVMe, USB, eMMC
  - Run `sudo ubuntu-rockchip-install /dev/nvme0n1`
    - Clones SD onto NVMe
    - Alternative:
      - `wget https://github.com/Joshua-Riek/ubuntu-rockchip/releases/download/v2.4.0/ubuntu-24.04-preinstalled-server-arm64-orangepi-5-plus.img.xz`
      - `xz -dc ubuntu-24.04-preinstalled-server-arm64-orangepi-5-plus.img.xz | sudo dd of=/dev/nvme0n1 bs=1M status=progress`
  - Run `sudo poweroff`
  - Remove the microSD
  - Reboot
- Prepare Docker

```
sudo apt update && sudo apt upgrade -y
# Install modules support if not present
sudo apt install linux-modules-extra-$(uname -r)

# 1. Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 2. Add your user to the Docker group (avoids using sudo for docker commands)
sudo usermod -aG docker $USER

# 3. Activate group changes (or logout and login again)
newgrp docker
```

- Setup portainer

```
sudo docker run -d \
  -p 9443:9443 \
  -p 8000:8000 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
```

- Launch `docker-compose.yaml`

# Switch Proxy model

- Open `data/privoxy/config`
- Update line `forward-socks5t`
- Run `docker kill -s HUP privoxy`

# Other tools

- ws-scrcpy
- pip3 install frida-tools
