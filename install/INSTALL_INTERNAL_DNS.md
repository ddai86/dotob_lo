# DNS nội bộ để dùng host-mode trên LAN/Internet

Bạn có 2 hướng “ổn định + chuẩn production”:

## A) Khuyến nghị: dùng domain thật + Split-horizon DNS

Mục tiêu:

- Internet truy cập: `https://dotob.example.com` và apps: `https://<service>.apps.example.com/`
- LAN truy cập y hệt, nhưng DNS nội bộ trả về IP LAN để tránh hairpin NAT và tăng ổn định.

### 1) Public DNS

- `dotob.example.com` -> A record -> IP WAN
- `*.apps.example.com` -> A record -> IP WAN

### 2) Internal DNS (Split-horizon)

- `dotob.example.com` -> A record -> IP LAN (máy chạy gateway)
- `*.apps.example.com` -> A record -> IP LAN

### 3) Cấu hình dotob.LO

- `DOTOB_APPS_GATEWAY_MODE=host`
- `DOTOB_APPS_GATEWAY_DOMAIN=apps.example.com`
- `DOTOB_APPS_GATEWAY_URL=https://dotob.example.com` (hoặc `https://apps.example.com` tuỳ bạn)

Ghi chú TLS:

- Nếu mỗi app là 1 subdomain, Traefik có thể tự xin cert theo từng host (HTTP-01) nhưng dễ chạm rate-limit khi tạo nhiều subdomain.
- Production tối ưu: dùng wildcard cert (DNS-01) nếu bạn có provider hỗ trợ API.

## B) LAN-only: tự dựng DNS nội bộ (apps.lan)

Áp dụng khi bạn chỉ cần host-mode trong LAN (ngoài Internet sẽ không dùng DNS nội bộ trừ khi đi qua VPN).

### 1) Chạy DNS server nội bộ (CoreDNS)

- File compose mẫu: `install/compose.dotob-lo.dns.internal.yaml`
- File CoreDNS: `install/dns/coredns/Corefile`

Bạn cần sửa dòng:

- `REPLACE_WITH_DOTOB_GATEWAY_LAN_IP` -> IP LAN của máy chạy gateway (vd `192.168.1.10`).

Chạy:

```bash
docker compose -f install/compose.dotob-lo.dns.internal.yaml up -d
```

### 2) Phát DNS cho toàn mạng

- Cách ổn định nhất: cấu hình DHCP trên router để phát DNS = IP của `dotoblo_dns`.
- Hoặc cấu hình DNS thủ công trên từng máy client.

### 3) Cấu hình dotob.LO

- `DOTOB_APPS_GATEWAY_MODE=host`
- `DOTOB_APPS_GATEWAY_DOMAIN=apps.lan`
- `DOTOB_APPS_GATEWAY_URL=http://<IP-LAN>:8081` (hoặc qua HTTPS/reverse proxy nếu bạn có)

## C) Muốn dùng “DNS nội bộ” khi ở ngoài Internet

DNS nội bộ không tự chạy trên Internet. Để dùng host-mode từ ngoài mà vẫn dùng “DNS nội bộ”, bạn cần:

- VPN (khuyến nghị): WireGuard/Tailscale, push DNS nội bộ cho client.
- Hoặc dùng domain thật (mục A).

