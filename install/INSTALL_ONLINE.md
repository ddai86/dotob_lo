# Hướng dẫn cài đặt Online dotob.LO (v1.0)

Tài liệu này hướng dẫn triển khai dotob.LO theo phương thức online bằng Docker Compose, sử dụng image đã pin digest trong compose.

## Điều kiện tiên quyết

- Máy chủ có Internet.
- Cài Docker và Docker Compose (plugin `docker compose`).
- Mở cổng 8080/tcp trên tường lửa nếu truy cập từ mạng ngoài.
- Quyền sudo/root trên Linux hoặc Docker Desktop trên Windows.

## Cài đặt tự động (khuyến nghị)

Nếu bạn đang ở thư mục gốc dự án, có thể dùng script tự động hoá:

- Linux/macOS:
  ```bash
  sudo bash install/install-online.sh \
    --url "http://SERVER_IP_OR_DOMAIN:8080" \
    --db-password "your-db-pass" \
    --mysql-root-password "your-root-pass"
  ```
  Tuỳ chọn: `--data-dir "/opt/dotob-lo"`, `--project-name "dotob-lo"`, `--compose "install/compose.dotob-lo.prod.online.yaml"`, `--app-key "your-app-key"`

- Windows (PowerShell):
  ```powershell
  powershell -ExecutionPolicy Bypass -File install\install-online.ps1 `
    -Url "http://SERVER_IP_OR_DOMAIN:8080" `
    -DbPassword "your-db-pass" `
    -MysqlRootPassword "your-root-pass"
  ```
  Tuỳ chọn: `-DataDir "C:\dotob-lo"`, `-ProjectName "dotob-lo"`, `-Compose "install\compose.dotob-lo.prod.online.yaml"`, `-AppKey "your-app-key"`

## Nhanh gọn (Khuyến nghị)

1. Chuẩn bị thư mục dữ liệu (Linux):
   ```bash
   sudo mkdir -p /opt/dotob-lo/{storage,mysql,redis}
   sudo chown -R $USER:$USER /opt/dotob-lo
   ```

2. Lấy file compose online và chỉnh sửa biến cần thiết. Nếu bạn đang ở trong repo, dùng file:
   - `install/compose.dotob-lo.prod.online.yaml`

   Cần sửa các biến sau trong phần `services.admin.environment` và `services.mysql.environment`:
   - `APP_KEY`: chuỗi ngẫu nhiên ≥16 ký tự.
   - `URL`: đổi thành `http://SERVER_IP_OR_DOMAIN:8080` (hoặc domain của bạn).
   - `DB_PASSWORD`: mật khẩu MySQL cho ứng dụng.
   - `MYSQL_ROOT_PASSWORD`: mật khẩu root MySQL.
   - (Tuỳ chọn) đổi ánh xạ cổng trong `ports` nếu không muốn dùng 8080.

   Gợi ý tạo nhanh `APP_KEY`:
   - Linux/macOS: `openssl rand -hex 16`
   - Windows PowerShell:
     ```powershell
     -join ((33..126) | Get-Random -Count 24 | % {[char]$_})
     ```

3. Khởi chạy stack (trong thư mục chứa file compose):
   ```bash
   docker compose -p dotob-lo -f install/compose.dotob-lo.prod.online.yaml up -d
   ```

4. Kiểm tra trạng thái và log:
   ```bash
   docker compose -p dotob-lo ps
   docker compose -p dotob-lo logs -f admin
   ```

5. Truy cập giao diện quản trị:
   - `http://SERVER_IP_OR_DOMAIN:8080`

### Xác minh nhanh

```bash
curl -f http://SERVER_IP_OR_DOMAIN:8080/api/health
```

## Ghi chú quan trọng

- File compose đã pin digest image app. Không cần `docker pull` thủ công; Docker sẽ tự kéo đúng image.
- Compose online vẫn sẽ kéo các image phụ trợ (MySQL, Redis) từ Docker Hub.
- Dữ liệu bền vững nằm trong:
  - `/opt/dotob-lo/storage`
  - `/opt/dotob-lo/mysql`
  - `/opt/dotob-lo/redis`

## Tuỳ chỉnh

- Đổi cổng: sửa dòng `ports` của dịch vụ `admin`, ví dụ `- "9090:8080"` để truy cập qua cổng 9090.
- Đổi vị trí dữ liệu: cập nhật các bind mount trong `volumes` trỏ tới thư mục mong muốn.
- SSL/TLS: đặt reverse proxy (Nginx/Caddy/Traefik) phía trước và cấu hình HTTPS cho domain.

## Nâng cấp/Patch

- Vì đã pin digest, để nâng cấp phiên bản app, cập nhật lại dòng `image:` trong file compose với digest mới rồi:
  ```bash
  docker compose -p dotob-lo up -d
  ```
- Hoặc thay thế file compose online bằng bản mới nhất từ dự án và chạy lại lệnh trên.

## Khởi động cùng hệ thống

- Các container có `restart: unless-stopped` sẽ tự khởi động cùng Docker daemon.
- Để đảm bảo stack Compose khởi động khi máy boot, có thể tạo systemd unit chạy `docker compose -p dotob-lo up -d` sau khi Docker sẵn sàng.

## Gỡ cài đặt

```bash
docker compose -p dotob-lo -f install/compose.dotob-lo.prod.online.yaml down
# Tuỳ chọn: xoá dữ liệu (không thể khôi phục)
sudo rm -rf /opt/dotob-lo
```

## Windows (Docker Desktop)

- Có thể dùng file compose online như trên. Nếu muốn lưu dữ liệu vào ổ đĩa Windows, đổi bind mount sang đường dẫn tuyệt đối Windows, ví dụ:
  ```yaml
  volumes:
    - "C:/dotob-lo/storage:/app/storage"
    - "C:/dotob-lo/mysql:/var/lib/mysql"
    - "C:/dotob-lo/redis:/data"
  ```
- Khuyến nghị bật WSL2 backend trong Docker Desktop để hiệu năng tốt hơn.

## Sự cố thường gặp

- Cổng 8080 bận: đổi ánh xạ `ports` hoặc giải phóng cổng.
- Quyền thư mục: đảm bảo user Docker có quyền đọc/ghi vào `/opt/dotob-lo/*`.
- MySQL khởi tạo lâu: lần đầu chạy có thể mất vài chục giây; xem `docker compose logs -f mysql`.
- Không truy cập được từ ngoài: mở cổng 8080 trên firewall/router và kiểm tra `URL` đúng IP/Domain.

---
