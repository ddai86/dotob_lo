# Hướng dẫn cài đặt dotob_lo trên Linux (Docker Engine + Docker Compose V2) — Online & Offline

Tài liệu này hướng dẫn triển khai dotob_lo trên Linux theo phương án:

- Docker Engine
- Docker Compose V2 (plugin `docker compose`)
- Chạy bằng file compose (online/offline)

## 1) Yêu cầu & khuyến nghị

### Phần cứng (khuyến nghị)

- CPU: tối thiểu 2 core (khuyến nghị 4 core+)
- RAM: tối thiểu 4GB (khuyến nghị 8–16GB+ nếu dùng nhiều app/collection)
- Ổ đĩa trống:
  - Tối thiểu 10GB (core)
  - Khuyến nghị 20–40GB+ nếu dùng offline tar lớn hoặc triển khai thêm apps/dữ liệu

### Phần mềm/môi trường (bắt buộc)

- Linux 64-bit
  - Ubuntu/Debian (khuyến nghị)
  - CentOS/Alma/Rocky (ổn)
- Docker Engine đang chạy
- Docker Compose V2 (kiểm tra bằng `docker compose version`)

### Cổng mạng

- TCP `8080`: web dotob_lo
- TCP `9999`: trang log dozzle (tuỳ chọn)

Nếu truy cập từ máy khác trong LAN/VPS, cần mở firewall/security group cho các cổng trên.

## 2) Cài Docker Engine + Docker Compose V2

### 2.1) Ubuntu / Debian

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
```

Kiểm tra:

```bash
docker version
docker compose version
sudo docker run --rm hello-world
```

### 2.2) CentOS / AlmaLinux / Rocky

```bash
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
```

Kiểm tra:

```bash
docker version
docker compose version
sudo docker run --rm hello-world
```

### 2.3) (Tuỳ chọn) Chạy Docker không cần sudo

```bash
sudo usermod -aG docker $USER
newgrp docker
```

## 3) Chuẩn bị thư mục dữ liệu

Mặc định, file compose sẽ dùng thư mục dữ liệu tại `/opt/dotob-lo` (không cần chỉnh YAML). Tạo trước:

```bash
sudo mkdir -p /opt/dotob-lo/{storage,mysql,redis}
sudo chown -R $USER:$USER /opt/dotob-lo
```

Nếu bạn muốn đặt dữ liệu ở thư mục khác, hãy set biến `DOTOB_HOST_DATA_DIR` khi chạy compose (hoặc đặt trong `.env` cùng thư mục chạy lệnh).

Ví dụ:

```bash
export DOTOB_HOST_DATA_DIR=/data/dotob-lo
sudo mkdir -p $DOTOB_HOST_DATA_DIR/{storage,mysql,redis}
sudo chown -R $USER:$USER $DOTOB_HOST_DATA_DIR
```

## 4) Chọn chế độ triển khai (Online/Offline)

File compose:

- Online: [compose.dotob-lo.prod.online.yaml](install/compose.dotob-lo.prod.online.yaml)
- Offline: [compose.dotob-lo.prod.offline.yaml](install/compose.dotob-lo.prod.offline.yaml)

## 5) Cấu hình bắt buộc trong file compose (cả online/offline)

Trong `services.admin.environment`, bắt buộc đặt các biến sau:

- `URL`: URL mà người dùng truy cập
  - Trên chính máy: `http://localhost:8080`
  - Cho LAN/VPS: `http://<IP_OR_DOMAIN>:8080`
- `APP_KEY`: chuỗi ngẫu nhiên ≥ 16 ký tự
- `DB_PASSWORD`: mật khẩu DB ứng dụng
- `MYSQL_ROOT_PASSWORD` và `MYSQL_PASSWORD`: mật khẩu MySQL

Gợi ý tạo chuỗi ngẫu nhiên (Linux):

```bash
openssl rand -hex 16
openssl rand -base64 24
```

## 6) Triển khai bản ONLINE

1. Mở file compose online:
   - [compose.dotob-lo.prod.online.yaml](install/compose.dotob-lo.prod.online.yaml)
2. Sửa các biến trong `services.admin.environment`:
   - `URL`
   - `APP_KEY`
   - `DB_PASSWORD`
   - `MYSQL_ROOT_PASSWORD`
   - `MYSQL_PASSWORD`
3. Chạy:

```bash
docker compose -f ./install/compose.dotob-lo.prod.online.yaml up -d
```

Kiểm tra:

```bash
docker ps
docker logs dotoblo_admin --tail 200
curl -f http://localhost:8080/api/health
```

Truy cập:

- `http://<IP_OR_DOMAIN>:8080`
- (tuỳ chọn logs) `http://<IP_OR_DOMAIN>:9999`

## 7) Triển khai bản OFFLINE

### 7.1) Chuẩn bị file offline tar

Bạn cần file `dotob-lo_core_1.0.tar`<a href="https://ictso.top/tailieu/dotoblo/dotob-lo_core_1.0.tar" target="_blank">tải về dotob-lo_core_1.0.tar</a> (đã đóng gói sẵn) trên máy Linux.

Nếu máy Linux “offline hoàn toàn”, hãy copy file tar bằng USB/LAN nội bộ.

### 7.2) Nạp images từ file tar

```bash
docker load -i ./dotob-lo_core_1.0.tar
```

Kiểm tra có image local:

```bash
docker image ls | grep dotob-lo-admin
```

### 7.3) Chạy compose offline

1. Mở file compose offline:
   - [compose.dotob-lo.prod.offline.yaml](install/compose.dotob-lo.prod.offline.yaml)
2. Sửa các biến trong `services.admin.environment`:
   - `URL`
   - `APP_KEY`
   - `DB_PASSWORD`
   - `MYSQL_ROOT_PASSWORD`
   - `MYSQL_PASSWORD`
3. Chạy:

```bash
docker compose -f ./install/compose.dotob-lo.prod.offline.yaml up -d
```

Nếu thấy lỗi kiểu “image not found / pull access denied” với `dotob-lo-admin:1.0`, nguyên nhân thường là chưa `docker load` đúng file tar.

## 8) Lệnh quản trị cơ bản

- Xem trạng thái:

```bash
docker compose -f ./install/compose.dotob-lo.prod.online.yaml ps
```

- Xem log:

```bash
docker compose -f ./install/compose.dotob-lo.prod.online.yaml logs -f admin
```

- Dừng:

```bash
docker compose -f ./install/compose.dotob-lo.prod.online.yaml down
```

## 9) Lưu ý an toàn

- dotob_lo mount Docker socket: `/var/run/docker.sock:/var/run/docker.sock`. Điều này cho phép ứng dụng điều khiển Docker trên máy host. Chỉ chạy trên máy bạn tin cậy và đặt mật khẩu mạnh cho tài khoản dotob_lo.
- Không expose Dozzle ra Internet công khai nếu không có lớp bảo vệ (reverse proxy + auth/allowlist).
