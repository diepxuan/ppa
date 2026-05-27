# Troubleshooting DiepXuan PPA

Tài liệu này tổng hợp các lỗi thường gặp khi dùng DiepXuan PPA và cách xử lý an toàn.

## 1. Lỗi `NO_PUBKEY 7E0EC917A5074BD3`

Lỗi mẫu:

```text
W: An error occurred during the signature verification.
The repository is not updated and the previous index files will be used.
GPG error: https://ppa.diepxuan.com bookworm InRelease:
The following signatures couldn't be verified because the public key is not available:
NO_PUBKEY 7E0EC917A5074BD3
```

### Nguyên nhân

APT không tìm được public key dùng để verify chữ ký của repository.

Các nguyên nhân thường gặp:

- `/usr/share/keyrings/diepxuan.gpg` chưa tồn tại.
- Keyring tồn tại nhưng là key cũ hoặc sai key.
- Source list không dùng đúng `signed-by=/usr/share/keyrings/diepxuan.gpg`.
- Máy từng cài PPA bằng script cũ, script cũ chỉ kiểm tra file keyring có tồn tại chứ chưa kiểm tra fingerprint.

### Cách xử lý khuyến nghị

Chạy lại installer ở chế độ chỉ cấu hình repository:

```bash
curl -fsSL https://ppa.diepxuan.com/install.sh | bash -s -- --repository-only
sudo apt-get update
```

Installer mới sẽ tự kiểm tra fingerprint và refresh keyring nếu keyring hiện tại sai hoặc cũ.

### Reset thủ công

Nếu muốn reset hoàn toàn keyring local:

```bash
sudo rm -f /usr/share/keyrings/diepxuan.gpg
curl -fsSL https://ppa.diepxuan.com/install.sh | bash -s -- --repository-only
sudo apt-get update
```

## 2. Kiểm tra fingerprint key

Key hợp lệ:

```text
Key ID:      7E0EC917A5074BD3
Fingerprint: C8BD 5D6C 638E 8A11 9389 2926 7E0E C917 A507 4BD3
```

Kiểm tra key public trên server:

```bash
curl -fsSL https://ppa.diepxuan.com/key.gpg | gpg --show-keys --with-fingerprint --keyid-format long
```

Kiểm tra keyring local:

```bash
gpg --show-keys --with-fingerprint --keyid-format long /usr/share/keyrings/diepxuan.gpg
```

Nếu fingerprint local không khớp, chạy lại installer hoặc reset keyring như mục 1.

## 3. Kiểm tra source list

Source list nằm tại:

```text
/etc/apt/sources.list.d/diepxuan.list
```

Kiểm tra nội dung:

```bash
cat /etc/apt/sources.list.d/diepxuan.list
```

Dạng đúng:

```text
deb [signed-by=/usr/share/keyrings/diepxuan.gpg] https://ppa.diepxuan.com <codename> main
```

Ví dụ Debian 12 Bookworm:

```text
deb [signed-by=/usr/share/keyrings/diepxuan.gpg] https://ppa.diepxuan.com bookworm main
```

Nếu file đang trỏ tới keyring khác, hãy chạy lại:

```bash
curl -fsSL https://ppa.diepxuan.com/install.sh | bash -s -- --repository-only
```

## 4. Lỗi không xác định được codename

Nếu installer báo không xác định được codename, kiểm tra:

```bash
cat /etc/os-release
cat /etc/lsb-release 2>/dev/null || true
```

Có thể tải installer về rồi chạy với biến `CODENAME` rõ ràng:

```bash
curl -fsSL https://ppa.diepxuan.com/install.sh -o /tmp/diepxuan-install.sh
CODENAME=bookworm bash /tmp/diepxuan-install.sh --repository-only
```

## 5. Lỗi thiếu `gpg`

Installer sẽ tự cài `gnupg` trên Debian/Ubuntu nếu chưa có `gpg`.

Nếu môi trường không cho phép installer cài package tự động, cài thủ công trước:

```bash
sudo apt-get update
sudo apt-get install -y gnupg
```

Sau đó chạy lại installer.

## 6. Kiểm tra package có sẵn hay không

Ví dụ kiểm tra `ductn`:

```bash
apt-cache policy ductn
```

Nếu không thấy package từ `ppa.diepxuan.com`, kiểm tra lại:

```bash
sudo apt-get update
cat /etc/apt/sources.list.d/diepxuan.list
```

Package có thể chưa được build cho distro/codename hiện tại.

## 7. Thu thập thông tin để báo lỗi

Khi cần debug, thu thập các output sau:

```bash
cat /etc/os-release
cat /etc/apt/sources.list.d/diepxuan.list
gpg --show-keys --with-fingerprint --keyid-format long /usr/share/keyrings/diepxuan.gpg
sudo apt-get update
apt-cache policy ductn
```

Gửi đầy đủ output lỗi để maintainer xác định nguyên nhân nhanh hơn.
