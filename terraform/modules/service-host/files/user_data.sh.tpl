#!/bin/bash
set -euo pipefail
exec > >(tee /var/log/user-data.log) 2>&1

echo "Starting application deployment..."

install_if_missing() {
  local binary="$1"
  shift

  if command -v "$binary" >/dev/null 2>&1; then
    return 0
  fi

  sudo dnf install -y "$@"
}

install_if_missing docker docker
install_if_missing nginx nginx
if ! command -v curl >/dev/null 2>&1; then
  sudo dnf install -y curl-minimal || sudo dnf install -y curl
fi

sudo systemctl enable docker
sudo systemctl enable nginx
sudo systemctl start docker
sudo systemctl start nginx

ROOT_SOURCE="$(findmnt -n -o SOURCE /)"
ROOT_DISK="$(lsblk -no PKNAME "$${ROOT_SOURCE}" 2>/dev/null || true)"
DATA_DISK="$(lsblk -dpno NAME,TYPE | awk -v root="/dev/$${ROOT_DISK}" '$2 == "disk" && $1 != root { print $1; exit }')"

if [ -n "$${DATA_DISK}" ]; then
  if ! sudo blkid "$${DATA_DISK}" >/dev/null 2>&1; then
    sudo mkfs.ext4 "$${DATA_DISK}"
  fi

  sudo mkdir -p /data
  if ! mountpoint -q /data; then
    sudo mount "$${DATA_DISK}" /data
  fi

  if ! grep -q "$${DATA_DISK} /data ext4 defaults,nofail 0 2" /etc/fstab; then
    echo "$${DATA_DISK} /data ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab
  fi
fi

until sudo docker info >/dev/null 2>&1; do
  echo "Waiting for Docker..."
  sleep 2
done

sudo mkdir -p /etc/nginx/conf.d
cat <<'NGINX_MAIN' | sudo tee /etc/nginx/nginx.conf >/dev/null
${nginx_conf}
NGINX_MAIN

cat <<'NGINX_APP' | sudo tee /etc/nginx/conf.d/approutes.conf >/dev/null
${approutes_conf}
NGINX_APP

sudo docker network inspect ec2-net >/dev/null 2>&1 || \
  sudo docker network create \
    --driver bridge \
    --subnet 172.30.0.0/24 \
    ec2-net

sudo docker rm -f ec2-go-service >/dev/null 2>&1 || true
sudo docker pull ${docker_image}
sudo docker run -d \
  --name ec2-go-service \
  --restart unless-stopped \
  --network ec2-net \
  --ip 172.30.0.10 \
  -v /data:/data \
  ${docker_image}

MAX_RETRIES=30
RETRY=0
until curl -sf http://172.30.0.10:8081/health >/dev/null 2>&1; do
  RETRY=$((RETRY + 1))
  if [ "$${RETRY}" -ge "$${MAX_RETRIES}" ]; then
    sudo docker logs ec2-go-service || true
    echo "ERROR: Application failed to become healthy on the bridge network after $${MAX_RETRIES} attempts"
    exit 1
  fi
  echo "Waiting for application health on bridge network... ($${RETRY}/$${MAX_RETRIES})"
  sleep 5
done

sudo nginx -t
sudo systemctl restart nginx

curl -sf http://localhost/_nginx/health >/dev/null
curl -sf http://localhost/health >/dev/null

echo "Application deployed successfully"
