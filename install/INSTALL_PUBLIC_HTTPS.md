# Triển khai production public (HTTPS, chỉ mở 80/443)

Mục tiêu:

- Public Internet chỉ mở `80` và `443`.
- Không publish `8080/8081` ra ngoài.
- Gateway tự cấp TLS bằng Let's Encrypt (HTTP-01).
- Apps gateway chạy ở `path mode`: `https://<domain>/apps/<service>/`.

## 1) Điều kiện

- Bạn có domain trỏ A record về IP public (WAN) của bạn.
- Router/modem port forward:
  - WAN `80` -> LAN `80` (máy chủ)
  - WAN `443` -> LAN `443` (máy chủ)
- ISP không chặn inbound 80/443 và bạn không bị CGNAT.

Nếu bạn muốn “NAT theo IP, không cần domain”, dùng biến thể HTTP-only:

- `install/compose.dotob-lo.prod.public.ip.yaml`
- NAT port `80` (khuyến nghị bật auth cho `/apps/*`)

## 2) Chuẩn bị secrets

- Copy file mẫu: `install/env.prod.public.example` -> `install/env.prod.public`
- Điền:
  - `DOTOB_PUBLIC_HOST` (domain)
  - `DOTOB_PUBLIC_URL` (https://domain)
  - `DOTOB_ACME_EMAIL`
  - `APP_KEY`, `DB_PASSWORD`, `MYSQL_ROOT_PASSWORD`

Khuyến nghị bật Basic Auth cho Apps Gateway:

- Tạo dòng `user:hash`:
  - `docker run --rm httpd:2.4-alpine htpasswd -nbB gatewayuser "PASSWORD"`
- Gán vào `DOTOB_APPS_GATEWAY_AUTH_USERS`.

## 3) Chạy compose

- Dùng file: `install/compose.dotob-lo.prod.public.yaml`
- Khuyến nghị set `DOTOB_HOST_DATA_DIR` ra ngoài repo (vd `/opt/dotob-lo`).

Ví dụ:

```bash
export DOTOB_HOST_DATA_DIR=/opt/dotob-lo
docker compose -f install/compose.dotob-lo.prod.public.yaml --env-file install/env.prod.public up -d
```

## 4) Kiểm tra

- `https://<domain>/` vào trang admin.
- `https://<domain>/apps/<service>/` vào app.
- Trên host, đảm bảo không còn publish `8080/8081` ra Internet.
