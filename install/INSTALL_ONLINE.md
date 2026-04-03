# Hướng dẫn cài đặt dotob.LO (ONLINE) — Windows & Linux

ONLINE nghĩa là: máy cài đặt có Internet trong lúc cài.

## Khuyến nghị trước khi cài

- Dung lượng trống khuyến nghị: tối thiểu 10GB (để chứa Docker images + dữ liệu MySQL/Redis + logs).
- Nếu máy khác trong mạng LAN cần truy cập: đảm bảo không chặn cổng TCP `8080` (và `9999` nếu dùng trang log).
- Trên Windows, nên chạy installer bằng quyền Administrator.

## 1) Bạn cần tải file nào?

- Windows: `dotob-lo-installer-online.exe`<a href="dotob-lo-installer-online.exe" target="_blank">`tải về dotob-lo-installer-online.exe`</a>
- Linux (Ubuntu/Debian amd64): `dotob-lo-installer-online_1.0_amd64.deb` <a href="dotob-lo-installer-online_1.0_amd64.deb" target="_blank">`tải về dotob-lo-installer-online_1.0_amd64.deb`</a>

## 2) Cài đặt Windows (WSL2 + Docker Engine tự cài)

### Trước khi cài
- Bạn cần quyền Administrator.
- Khuyến nghị Windows 10/11 64-bit.

### Cài đặt
1. Chuột phải `dotob-lo-installer-online.exe` → Run as administrator.
2. Chọn thư mục cài đặt (giữ mặc định cũng được).
3. Khi hỏi “Khởi động dotob.LO cùng Windows?”:
   - Chọn Yes nếu muốn tự chạy sau mỗi lần mở máy.
   - Chọn No nếu muốn tự bật khi cần.
4. Chờ cài đặt hoàn tất.

### Mở dotob.LO
- Trên máy cài: `http://localhost:8080`
- Máy khác trong LAN: `http://<IP_LAN_MAY_WINDOWS>:8080`

Ghi chú: nếu dotob.LO chạy Docker trong WSL2, installer đã tự cấu hình expose ra LAN (port 8080/9999 + firewall).

Khuyến nghị: để tránh lỗi truy cập từ LAN, hãy mở Windows Defender Firewall cho cổng `8080` nếu bạn có bật tường lửa.

### Dừng / chạy lại
Trong Start Menu có nhóm “dotob.LO”:
- Start dotob.LO
- Stop dotob.LO
- Open dotob.LO

## 3) Cài đặt Linux (Ubuntu/Debian amd64)

### Trước khi cài
- Bạn cần quyền sudo/root.
- Internet để installer tự cài Docker Engine + docker compose plugin.

### Cài đặt
1. Copy file `dotob-lo-installer-online_1.0_amd64.deb` lên máy Linux.
2. Cài:

```bash
sudo apt install ./dotob-lo-installer-online_1.0_amd64.deb
```

Trong quá trình cài sẽ hỏi “Khởi động dotob.LO cùng hệ thống?”:
- Nhập `Y` để bật tự khởi động sau reboot.
- Nhập `n` để tắt.

### Mở dotob.LO
- Trên máy Linux: `http://localhost:8080`
- Máy khác trong LAN: `http://<IP_LAN_MAY_LINUX>:8080`

### Lệnh quản trị nhanh
```bash
dotob-lo status
dotob-lo logs
dotob-lo down
dotob-lo up
```

### Bật/tắt tự khởi động (systemd)
```bash
sudo systemctl enable --now dotob-lo.service
sudo systemctl disable --now dotob-lo.service
```

## 4) Nếu không truy cập được
- Kiểm tra `http://localhost:8080` trên chính máy cài.
- Nếu máy khác trong LAN không vào được: kiểm tra firewall (Windows Defender Firewall / ufw) và đảm bảo port 8080 không bị chặn.
- Xem logs:
  - Windows: `http://localhost:9999`
  - Linux: `dotob-lo logs`
