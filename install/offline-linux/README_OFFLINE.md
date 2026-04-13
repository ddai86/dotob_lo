# Cài đặt offline (air-gapped)

Mục tiêu:

- Không cần Internet trên máy cài đặt.
- Toàn bộ images cần thiết được đóng gói thành 1 file `.tar`.

## 1) Tạo bundle (trên máy có Internet)

### Windows

```powershell
PowerShell -ExecutionPolicy Bypass -File install\package-offline.ps1 -IncludeApps
```

Kết quả tạo ở `install/dist/`:

- `dotob-lo_core_1.0.tar`
- `dotob-lo_core_1.0.tar.sha256`

Script cũng tạo thêm bản alias:

- `dotob-lo_offline_1.0.tar`
- `dotob-lo_offline_1.0.tar.sha256`

### Linux

```bash
bash install/package-offline.sh --include-apps
```

`--include-apps` được khuyến nghị để máy offline có thể cài các ứng dụng mà không cần pull Internet.

Mặc định bản offline sẽ tự cài sẵn các ứng dụng phổ biến sau khi cài xong:

- `_kiwix_server`, `_kolibri`, `_ollama`, `_flatnotes`, `_cyberchef`

Bạn có thể override danh sách bằng biến môi trường `DOTOB_PREINSTALL_SERVICES`.

## 2) Copy sang máy offline

Copy các file:

- `install/dist/dotob-lo_core_1.0.tar` (+ `.sha256`)
- `install/install-offline.ps1` hoặc `install/install-offline.sh`
- `install/compose.dotob-lo.prod.offline.yaml`

## 3) Cài đặt (trên máy offline)

### Windows

```powershell
PowerShell -ExecutionPolicy Bypass -File install\install-offline.ps1 -BundleTar install\dist\dotob-lo_core_1.0.tar -ServerHost 192.168.1.10
```

### Linux

```bash
sudo bash install/install-offline.sh --bundle-tar install/dist/dotob-lo_core_1.0.tar --server-host 192.168.1.10
```

Sau khi chạy xong:

- Admin: `http://<server-host>:8080`
- Apps gateway: `http://<server-host>:8081/apps/<service>/`

## 5) Nếu vào Settings > Apps không thấy ứng dụng

- Kiểm tra log migrator: `docker logs dotoblo_migrator`
- Chạy lại migrator (migrations + seeds + refresh catalog):
  - `docker compose -f <compose.yml> run --rm migrator`


## 4) Lưu ý ổn định

- `DOTOB_HOST_DATA_DIR` nên đặt ra ổ đĩa riêng (vd `/opt/dotob-lo`).
- Nếu muốn hoàn toàn offline cho các app, bật `-IncludeApps` khi tạo bundle để preload images phổ biến.
