# Public dễ vận hành (NAT IP, 1 cổng 80)

Mục tiêu:

- Bình thường dùng `localhost` hoặc IP LAN.
- Khi cần public chỉ cần NAT port `80` ra Internet (không bắt buộc domain).
- Không expose `8080/8081` ra Internet.

## 1) Thành phần

- Compose: `install/compose.dotob-lo.prod.public.ip.yaml`
- Script cài đặt:
  - Linux: `install/install-public-ip.sh`
  - Windows: `install/install-public-ip.ps1`

## 2) Cách chạy (khuyến nghị dùng script)

Script sẽ:

- Tạo secrets mạnh.
- Copy compose vào data dir.
- Thay `SERVER_IP_OR_DOMAIN` theo tham số bạn truyền.

### Linux

```bash
sudo bash install/install-public-ip.sh --public-host 192.168.1.10
```

Khi bạn NAT ra Internet, bạn có thể chạy lại với IP public hoặc giữ nguyên (UI chủ yếu dùng path tương đối).

### Windows (PowerShell Admin)

```powershell
PowerShell -ExecutionPolicy Bypass -File install\install-public-ip.ps1 -PublicHost 192.168.1.10
```

## 3) NAT/Firewall

- Router/modem: forward WAN TCP `80` -> LAN TCP `80` (máy chủ).
- Firewall host: mở inbound TCP `80`.

## 4) Bảo mật tối thiểu khi public

Khuyến nghị bắt buộc bật Basic Auth cho `/apps/*`:

- Tạo chuỗi htpasswd:

```bash
docker run --rm httpd:2.4-alpine htpasswd -nbB gatewayuser "PASSWORD"
```

- Gán vào env `DOTOB_APPS_GATEWAY_AUTH_USERS` (dòng `user:$2y$...`).

