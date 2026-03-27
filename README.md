# dotob_lo
dotob.LO – Hệ thống máy chủ tri thức ngoại tuyến cá nhân, giúp bạn vận hành một bộ công cụ “tự chủ thông tin” ngay trong mạng nội bộ của mình.
<div align="center">
  <img src="dotob_logo.png" width="200" height="200"/>

  # dotob.LO
  ### Trung tâm điều khiển (Command Center) — Offline-first Knowledge & Tools

  Tích hợp phát triển bởi ICTSO
</div>

---

dotob.LO là hệ thống quản trị và điều phối một bộ công cụ chạy bằng Docker, tập trung vào trải nghiệm offline-first: kiến thức, giáo dục và công cụ dữ liệu có thể chạy nội bộ trên máy chủ của bạn.

## Triển khai (Online/Offline)

Các file đóng gói v1.0 nằm trong thư mục `install/`:
- Online (pin digest): `install/compose.dotob-lo.prod.online.yaml`
- Offline: `install/compose.dotob-lo.prod.offline.yaml`
- Hướng dẫn đóng gói: `install/PACKAGING.md`

### Online (khuyến nghị)

Build + push image lên GHCR và tự pin digest vào file compose online:

```powershell
docker login ghcr.io -u ddai86
.\install\package-online.ps1 -Registry ghcr
```

Triển khai lên Ubuntu/Debian:
1) Copy `install/compose.dotob-lo.prod.online.yaml` lên máy đích (ví dụ `/opt/dotob-lo/compose.yml`)
2) Sửa `URL`, `APP_KEY`, mật khẩu DB trong file
3) Chạy:

```bash
sudo mkdir -p /opt/dotob-lo/{storage,mysql,redis}
docker compose -p dotob-lo -f /opt/dotob-lo/compose.yml up -d
```

### Offline (không cần Internet ở máy đích)

Đóng gói offline kèm toàn bộ image app để cài app khi không có Internet:

```powershell
.\install\package-offline.ps1 -IncludeApps
```

Trên máy đích:

```bash
docker load -i dotob-lo_core_1.0.tar
docker compose -p dotob-lo -f compose.dotob-lo.prod.offline.yaml up -d
```

## Các thành phần chính

- Thư viện thông tin: Kiwix
- Nền tảng giáo dục: Kolibri
- Trợ lý AI cục bộ: Ollama + Qdrant
- Công cụ dữ liệu: CyberChef
- Ghi chú: FlatNotes

## Nguồn gốc dự án

dotob.LO được xây dựng tích hợp cho thị trường Việt Nam bởi ICTSO.

## License

Apache License 2.0: xem [LICENSE](LICENSE).
