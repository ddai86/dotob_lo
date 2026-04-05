# Hướng dẫn cài đặt dotob_lo trên macOS (Docker Desktop) — Online & Offline

Tài liệu này hướng dẫn triển khai dotob_lo trên macOS theo phương án:

- Docker Desktop for Mac (kèm Docker Engine + Docker Compose V2)
- Chạy bằng file compose (online/offline)
- Dùng biến `DOTOB_HOST_DATA_DIR` để không phải sửa đường dẫn trong YAML

## 1) Yêu cầu & khuyến nghị

### Phần cứng (khuyến nghị)

- CPU: tối thiểu 2 core (khuyến nghị 4 core+)
- RAM: tối thiểu 8GB (khuyến nghị 16GB+ nếu dùng nhiều app/collection)
- Ổ đĩa trống:
  - Tối thiểu 10GB (core)
  - Khuyến nghị 20–40GB+ nếu dùng offline tar lớn hoặc triển khai thêm apps/dữ liệu

### Phần mềm/môi trường (bắt buộc)

- macOS 64-bit (Intel hoặc Apple Silicon)
- Docker Desktop for Mac
- Docker Compose V2 (kiểm tra bằng `docker compose version`)

### Cổng mạng

- TCP `8080`: web dotob_lo
- TCP `9999`: trang log dozzle (tuỳ chọn)

Nếu truy cập từ máy khác trong LAN, cần mở firewall trên macOS (nếu có) và đảm bảo router không chặn.

## 2) Cài Docker Desktop trên macOS

### 2.1) Tải & cài đặt

1. Tải Docker Desktop for Mac từ trang Docker.
2. Chọn đúng bản theo CPU:
   - Apple Silicon (M1/M2/M3…)
   - Intel
3. Mở file `.dmg` → kéo Docker vào Applications → chạy Docker Desktop.
4. Nếu macOS yêu cầu quyền (Privileged Helper / Network), hãy cho phép để Docker hoạt động ổn định.

### 2.2) Kiểm tra Docker + Compose

Mở Terminal:

```bash
docker version
docker compose version
docker run --rm hello-world
```

### 2.3) Lưu ý cho Apple Silicon (M1/M2/M3)

Nếu gặp lỗi kiểu `exec format error` khi chạy container, nguyên nhân thường do image chỉ có `amd64`.

- Cách xử lý ưu tiên: trong Docker Desktop Settings, bật tuỳ chọn chạy/giả lập `x86_64/amd64` (nếu có).
- Nếu dùng offline tar được đóng gói từ máy `amd64`, bạn vẫn có thể chạy trên Apple Silicon bằng giả lập, nhưng hiệu năng sẽ giảm.

## 3) Chuẩn bị thư mục dữ liệu (không cần sửa YAML)

Trên macOS, khuyến nghị để dữ liệu trong thư mục user (để Docker Desktop mount được):

```bash
export DOTOB_HOST_DATA_DIR="$HOME/dotob-lo"
mkdir -p "$DOTOB_HOST_DATA_DIR"/{storage,mysql,redis}
```

Kiểm tra biến đã set:

```bash
echo "$DOTOB_HOST_DATA_DIR"
```

## 4) Chọn chế độ triển khai (Online/Offline)

File compose:

- Online: [compose.dotob-lo.prod.online.yaml](install/compose.dotob-lo.prod.online.yaml)
- Offline: [compose.dotob-lo.prod.offline.yaml](install/compose.dotob-lo.prod.offline.yaml)

## 5) Cấu hình bắt buộc trong file compose (cả online/offline)

Trong `services.admin.environment`, bắt buộc đặt các biến sau:

- `URL`: URL mà người dùng truy cập
  - Trên chính máy: `http://localhost:8080`
  - Cho LAN: `http://<IP_MAC>:8080`
- `APP_KEY`: chuỗi ngẫu nhiên ≥ 16 ký tự
- `DB_PASSWORD`: mật khẩu DB ứng dụng
- `MYSQL_ROOT_PASSWORD` và `MYSQL_PASSWORD`: mật khẩu MySQL

Gợi ý tạo chuỗi ngẫu nhiên:

```bash
openssl rand -hex 16
openssl rand -base64 24
```

## 6) Triển khai bản ONLINE

Tại thư mục dự án, đảm bảo đã set `DOTOB_HOST_DATA_DIR` (mục 3), rồi chạy:

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

- `http://localhost:8080`
- (tuỳ chọn logs) `http://localhost:9999`

## 7) Triển khai bản OFFLINE

### 7.1) Nạp images từ file tar

Bạn cần file `dotob-lo_core_1.0.tar`<a href="https://ictso.top/tailieu/dotoblo/dotob-lo_core_1.0.tar" target="_blank">tải về dotob-lo_core_1.0.tar</a> trên máy macOS.

```bash
docker load -i ./dotob-lo_core_1.0.tar
```

Kiểm tra có image local:

```bash
docker image ls | grep dotob-lo-admin
```

### 7.2) Chạy compose offline

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
