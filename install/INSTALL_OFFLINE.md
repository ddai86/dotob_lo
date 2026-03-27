# Hướng dẫn cài đặt Offline dotob.LO (v1.0)

Tài liệu này hướng dẫn triển khai dotob.LO theo phương thức offline: máy đích không cần Internet. Đã đóng gói Docker images thành một file `.tar`, chép sang máy đích rồi `docker load` và chạy bằng Docker Compose.

## Điều kiện tiên quyết

- Máy đóng gói (có Internet): có Docker, đủ dung lượng đĩa để `docker save`.
- Máy đích (không Internet): cài sẵn Docker và Docker Compose (plugin `docker compose`).
- Cổng 8080/tcp mở trên máy đích nếu truy cập từ máy khác trong mạng.

## 1) Đóng gói bản cài đặt offline lưu tại:
- bản đóng gói này 4Gb~5Gb lên các bạn tải ở đây `https://ictso.top/tailieu/dotoblo/dotob-lo_core_1.0.tar`
- `install/dist/dotob-lo_core_1.0.tar.sha256`

## 2) Tải và chép bộ cài sang máy đích

Chép các file sau sang máy đích (ví dụ `/opt/dotob-lo/`):
- `https://ictso.top/tailieu/dotoblo/dotob-lo_core_1.0.tar/dotob-lo_core_1.0.tar`
- `install/dist/dotob-lo_core_1.0.tar.sha256`
- `install/compose.dotob-lo.prod.offline.yaml`

## 3) Xác minh file tar (khuyến nghị)

Trên máy đích (Linux), tại thư mục chứa file tar:

```bash
sha256sum -c dotob-lo_core_1.0.tar.sha256
```

Kết quả mong muốn: `OK`.

## 4) Nạp images và chạy hệ thống (máy đích offline)

1. Nạp images vào Docker:

```bash
docker load -i dotob-lo_core_1.0.tar
```

2. Chuẩn bị thư mục dữ liệu:

```bash
sudo mkdir -p /opt/dotob-lo/{storage,mysql,redis}
sudo chown -R $USER:$USER /opt/dotob-lo
```

3. Chỉnh các biến bắt buộc trong file compose offline (`compose.dotob-lo.prod.offline.yaml`):
- `URL`: `http://SERVER_IP_OR_DOMAIN:8080`
- `APP_KEY`: chuỗi ngẫu nhiên ≥16 ký tự
- `DB_PASSWORD`: mật khẩu MySQL cho ứng dụng
- `MYSQL_ROOT_PASSWORD` và `MYSQL_PASSWORD`: mật khẩu MySQL

4. Chạy stack:

```bash
docker compose -p dotob-lo -f compose.dotob-lo.prod.offline.yaml up -d
```

5. Kiểm tra:

```bash
docker compose -p dotob-lo ps
docker compose -p dotob-lo logs -f admin
curl -f http://SERVER_IP_OR_DOMAIN:8080/api/health
```

Truy cập giao diện: `http://SERVER_IP_OR_DOMAIN:8080`

## Ghi chú quan trọng

- File compose offline dùng `image: dotob-lo-admin:1.0` (local image). Vì vậy bắt buộc phải `docker load` file tar trước khi chạy.
- File `.tar` chỉ chứa Docker images, không chứa dữ liệu volumes/bind-mount. Dữ liệu bền vững nằm trong:
  - `/opt/dotob-lo/storage`
  - `/opt/dotob-lo/mysql`
  - `/opt/dotob-lo/redis`
- Nếu bạn chạy nhiều lần trên máy mới và muốn “dữ liệu sạch”, xoá các thư mục dữ liệu trên rồi chạy lại.

## Gỡ cài đặt

```bash
docker compose -p dotob-lo -f compose.dotob-lo.prod.offline.yaml down
# Tuỳ chọn: xoá dữ liệu (không thể khôi phục)
sudo rm -rf /opt/dotob-lo
```

---
