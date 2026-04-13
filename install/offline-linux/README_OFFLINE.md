# Cài đặt offline
Mục tiêu:

- Không cần Internet trên máy cài đặt.
- Toàn bộ images cần thiết được đóng gói thành 1 file `.tar`.

### Linux

`--include-apps` được khuyến nghị để máy offline có thể cài các ứng dụng mà không cần pull Internet.

## Cài đặt (trên máy offline)

Tải về các file:
- `dotob-lo_core_1.0.tar`
- `dotob-lo_core_1.0.tar.sha256`
- `offline-linux/install-offline.sh`
- `offline-linux/compose.dotob-lo.prod.offline.yaml`

### Linux

```bash
sudo bash install/install-offline.sh --bundle-tar install/dist/dotob-lo_core_1.0.tar --server-host 192.168.1.10
```

Sau khi chạy xong:

- Admin: `http://<server-host>:8080`
- Apps gateway: `http://<server-host>:8081/apps/<service>/`

##Nếu vào Settings > Apps không thấy ứng dụng

- Kiểm tra log migrator: `docker logs dotoblo_migrator`
- Chạy lại migrator (migrations + seeds + refresh catalog):
  - `docker compose -f <compose.yml> run --rm migrator`


##) Lưu ý ổn định

- `DOTOB_HOST_DATA_DIR` nên đặt ra ổ đĩa riêng (vd `/opt/dotob-lo`).
- Nếu muốn hoàn toàn offline cho các app, bật `-IncludeApps` khi tạo bundle để preload images phổ biến.
