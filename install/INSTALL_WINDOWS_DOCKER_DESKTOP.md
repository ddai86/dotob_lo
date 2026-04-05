# Hướng dẫn cài đặt dotob_lo trên Windows (WSL2 + Docker Desktop) — Online & Offline

Tài liệu này hướng dẫn triển khai dotob_lo trên Windows theo phương án:

- Windows 10/11 + WSL2
- Docker Desktop (WSL2 backend)
- Chạy bằng Docker Compose (online/offline)

## 1) Yêu cầu & khuyến nghị

### Phần cứng (khuyến nghị)

- CPU: tối thiểu 2 core (khuyến nghị 4 core+)
- RAM: tối thiểu 8GB (khuyến nghị 16GB+ nếu dùng nhiều app/collection)
- Ổ đĩa trống:
  - Tối thiểu 10GB (core)
  - Khuyến nghị 20–40GB+ nếu dùng offline tar lớn hoặc triển khai thêm apps/dữ liệu
- Bắt buộc bật ảo hoá (VT-x/AMD-V) trong BIOS/UEFI

### Phần mềm/môi trường (bắt buộc)

- Windows 10/11 64-bit
- WSL2 (Windows Subsystem for Linux v2)
- Docker Desktop (bật WSL2 backend)
- Docker Compose V2 (đi kèm Docker Desktop, kiểm tra bằng `docker compose version`)

### Cổng mạng

- TCP `8080`: web dotob_lo
- TCP `9999`: trang log dozzle (tuỳ chọn)

Nếu truy cập từ máy khác trong LAN, cần mở firewall Windows cho các cổng trên.

## 2) Cài WSL2

### 2.1) Tải/cài WSL2 (tự động)

Mở PowerShell (Run as administrator), chạy:

```powershell
wsl --install
wsl --set-default-version 2
```

Khởi động lại máy nếu được yêu cầu.

Nếu lệnh `wsl --install` báo lỗi (thường do Windows chưa bật tính năng), bật thủ công:

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

Sau đó reboot, rồi chạy lại:

```powershell
wsl --install
wsl --set-default-version 2
```

### 2.2) Cài Ubuntu cho WSL (khuyến nghị)

- Cách dễ nhất: mở Microsoft Store → tìm “Ubuntu” → Install.
- Nếu bạn đã có distro khác (Debian, Ubuntu 22.04, …) cũng được.

Mở Ubuntu lần đầu để hoàn tất tạo user/password.

### 2.3) Cập nhật WSL (khuyến nghị)

```powershell
wsl --update
wsl --shutdown
```

Kiểm tra WSL2:

```powershell
wsl -l -v
```

Bạn nên thấy distro (thường là Ubuntu) ở `VERSION 2`.

## 3) Cài Docker Desktop (WSL2 backend)

### 3.1) Tải & cài Docker Desktop

1. Tải Docker Desktop từ trang Docker (Docker Desktop for Windows).
2. Chạy file cài đặt `.exe`:
   - Giữ chọn “Use WSL 2 instead of Hyper-V” nếu trình cài đặt hỏi.
   - Hoàn tất cài đặt và mở Docker Desktop.
3. Nếu Docker Desktop yêu cầu đăng nhập, bạn có thể đăng nhập hoặc chọn dùng theo chính sách hiện có của bạn.

### 3.2) Cấu hình Docker Desktop để chạy với WSL2

Mở Docker Desktop → Settings:
   - General: bật “Use the WSL 2 based engine”
   - Resources → WSL Integration: bật integration cho distro bạn dùng (ví dụ Ubuntu)
Chờ Docker Desktop báo đang chạy.

Khuyến nghị thêm:

- Resources: giới hạn CPU/RAM phù hợp với máy (ví dụ 4 CPU, 8–12GB RAM nếu máy có 16GB+).
- Nếu bạn định lưu dữ liệu dotob_lo ở ổ khác, bạn chỉ cần đổi biến `DOTOB_HOST_DATA_DIR` (phần 7), không cần sửa file YAML.

Kiểm tra nhanh:

```powershell
docker version
docker compose version
docker run --rm hello-world
```

## 4) Chuẩn bị thư mục dữ liệu trên Windows

Khuyến nghị tạo thư mục dữ liệu cố định để dễ backup/di chuyển:

```powershell
mkdir C:\dotob-lo\storage, C:\dotob-lo\mysql, C:\dotob-lo\redis
```

## 5) Chọn chế độ triển khai

dotob_lo có 2 kiểu:

- Online: kéo image từ Internet rồi chạy bằng compose online.
- Offline: nạp image từ file `.tar` (không cần Internet khi cài), rồi chạy bằng compose offline.

File compose:

- Online: [compose.dotob-lo.prod.online.yaml](install/compose.dotob-lo.prod.online.yaml)
- Offline: [compose.dotob-lo.prod.offline.yaml](install/compose.dotob-lo.prod.offline.yaml)

## 6) Cấu hình bắt buộc trong file compose (cả online/offline)

Trong `services.admin.environment`, bắt buộc đặt các biến sau:

- `URL`: URL mà người dùng truy cập
  - Chỉ dùng trên máy cài: `http://localhost:8080`
  - Cho LAN: `http://<IP_LAN_MAY_WINDOWS>:8080`
- `APP_KEY`: chuỗi ngẫu nhiên ≥ 16 ký tự
- `DB_PASSWORD`: mật khẩu DB ứng dụng
- `MYSQL_ROOT_PASSWORD` và `MYSQL_PASSWORD`: mật khẩu MySQL

Gợi ý tạo chuỗi ngẫu nhiên (PowerShell):

```powershell
# APP_KEY 32 ký tự
-join ((48..57)+(65..90)+(97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})

# Password 24 ký tự
-join ((48..57)+(65..90)+(97..122) | Get-Random -Count 24 | ForEach-Object {[char]$_})
```

## 7) Thiết lập đường dẫn dữ liệu (không cần sửa file YAML)

Các file compose dùng biến `DOTOB_HOST_DATA_DIR` để trỏ tới thư mục dữ liệu trên máy host.

Với Docker Desktop, đường dẫn host nên dùng dạng Linux path do Docker Desktop cung cấp:

- Nếu bạn tạo dữ liệu ở `C:\dotob-lo\...` thì đặt:
  - `DOTOB_HOST_DATA_DIR=/run/desktop/mnt/host/c/dotob-lo`
- Nếu dùng ổ D (ví dụ `D:\dotob-lo\...`) thì đặt:
  - `DOTOB_HOST_DATA_DIR=/run/desktop/mnt/host/d/dotob-lo`

### Cách 1: Đặt biến trong phiên PowerShell hiện tại

```powershell
$env:DOTOB_HOST_DATA_DIR = "/run/desktop/mnt/host/c/dotob-lo"
```

### Cách 2: Dùng file .env (khuyến nghị nếu chạy nhiều lần)

Tạo file `.env` tại đúng thư mục bạn chạy lệnh `docker compose` (thường là thư mục gốc dự án), với nội dung:

```env
DOTOB_HOST_DATA_DIR=/run/desktop/mnt/host/c/dotob-lo
```

## 8) Triển khai bản ONLINE

Tại thư mục dự án, chạy:

```powershell
docker compose -f .\install\compose.dotob-lo.prod.online.yaml up -d
```

Kiểm tra:

```powershell
docker ps
docker logs dotoblo_admin --tail 200
```

Truy cập:

- `http://localhost:8080`
- (tuỳ chọn logs) `http://localhost:9999`

## 9) Triển khai bản OFFLINE

### 9.1) Nạp images từ file tar

Bạn cần file `dotob-lo_core_1.0.tar` trên máy Windows.

Chạy:

```powershell
docker load -i .\dotob-lo_core_1.0.tar
```

Kiểm tra có image local:

```powershell
docker image ls | findstr dotob-lo-admin
```

### 9.2) Chạy compose offline

```powershell
docker compose -f .\install\compose.dotob-lo.prod.offline.yaml up -d
```

Nếu thấy lỗi kiểu “image not found / pull access denied” với `dotob-lo-admin:1.0`, nguyên nhân thường là chưa `docker load` đúng file tar.

## 10) Mở truy cập từ LAN (tuỳ chọn)

1. Lấy IP LAN của Windows (ví dụ `192.168.1.10`).
2. Mở firewall cho TCP 8080 (và 9999 nếu cần).
3. Đặt `URL=http://192.168.1.10:8080` trong compose.
4. Máy khác truy cập `http://192.168.1.10:8080`.

## 11) Lệnh quản trị cơ bản

- Xem trạng thái:

```powershell
docker compose -f .\install\compose.dotob-lo.prod.online.yaml ps
```

- Xem log:

```powershell
docker compose -f .\install\compose.dotob-lo.prod.online.yaml logs -f admin
```

- Dừng:

```powershell
docker compose -f .\install\compose.dotob-lo.prod.online.yaml down
```

## 12) Lưu ý an toàn

- dotob_lo mount Docker socket: `/var/run/docker.sock:/var/run/docker.sock`. Điều này cho phép ứng dụng điều khiển Docker trên máy host. Chỉ chạy trên máy bạn tin cậy và đặt mật khẩu mạnh cho tài khoản dotob_lo.
- Không expose Portainer/Dozzle ra Internet công khai nếu không có lớp bảo vệ (reverse proxy + auth/allowlist).
