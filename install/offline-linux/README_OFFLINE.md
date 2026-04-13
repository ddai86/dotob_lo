# Cài đặt “dễ nhất tuyệt đối” (không cần can thiệp nhiều)

Mục tiêu:

- Người cài chỉ cần **giải nén** và **chạy 1 lệnh / 1 file**.
- Offline bundle đã kèm sẵn images + tự cài sẵn các ứng dụng phổ biến.

## Linux Ubuntu/Debian (offline)

Bạn tải các file sau về để cùng 1 thư mục(khuyến nghị):
- `dotob-lo_core_1.0.tar.sha256`<a href="https://ictso.top/tailieu/dotoblo/dotob-lo_core_1.0.tar.sha256" target="_blank">tải  tại đây</a>
- `install-offline.sh`<a href="https://ictso.top/tailieu/dotoblo/install-offline.sh" target="_blank">tải  tại đây</a>
- `dotob-lo_core_1.0.tar` <a href="https://ictso.top/tailieu/dotoblo/dotob-lo_core_1.0.tar" target="_blank">tải  tại đây</a>
- `Start-dotobLO-Offline.sh`<a href="https://ictso.top/tailieu/dotoblo/Start-dotobLO-Offline.sh" target="_blank">tải  tại đây</a>

Người dùng chạy:

```bash
sudo bash Start-dotobLO-Offline.sh
```

Script sẽ `docker load` và khởi chạy stack offline.

