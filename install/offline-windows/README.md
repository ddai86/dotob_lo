# Cài đặt “dễ nhất tuyệt đối” (không cần can thiệp nhiều)

Mục tiêu:

- Người cài chỉ cần **giải nén** và **chạy 1 lệnh / 1 file**.
- Offline bundle đã kèm sẵn images + tự cài sẵn các ứng dụng phổ biến.

## Windows (offline)

Phát hành dạng thư mục/zip (khuyến nghị):

- `dotob-lo-installer-online.exe`<a href="https://ictso.top/tailieu/dotoblo/dotob-lo-installer-online.exe" target="_blank">tải  tại đây</a>
- `dotob-lo_core_1.0.tar` <a href="https://ictso.top/tailieu/dotoblo/dotob-lo_core_1.0.tar" target="_blank">tải  tại đây</a>
- `Start-dotobLO-Offline.cmd`

Người dùng chỉ cần chạy:

- `Start-dotobLO-Offline.cmd`

Installer sẽ tự copy tar vào thư mục cài và tự chạy setup.

## Linux Ubuntu/Debian (offline)

Phát hành dạng thư mục/tar.gz:

- `dotob-lo_core_1.0.tar` <a href="https://ictso.top/tailieu/dotoblo/dotob-lo-installer-online.exe" target="_blank">tải  tại đây</a>
- `install-offline.sh`
- `Start-dotobLO-Offline.sh`

Người dùng chạy:

```bash
sudo bash Start-dotobLO-Offline.sh
```

Script sẽ `docker load` và khởi chạy stack offline.

