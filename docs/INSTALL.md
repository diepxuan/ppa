# Hướng dẫn cài đặt DiepXuan PPA

Tài liệu này mô tả cách thêm DiepXuan PPA vào Debian/Ubuntu, kiểm tra GPG key và cài package từ repository.

## 1. Cài đặt tự động

Cách khuyến nghị là dùng installer public:

```bash
curl -fsSL https://ppa.diepxuan.com/install.sh | bash
```

Lệnh trên sẽ:

1. Xác định distro codename.
2. Cài `gnupg` nếu hệ Debian/Ubuntu chưa có `gpg`.
3. Tải GPG public key.
4. Kiểm tra fingerprint của key.
5. Cài hoặc refresh keyring tại `/usr/share/keyrings/diepxuan.gpg`.
6. Ghi APT source tại `/etc/apt/sources.list.d/diepxuan.list`.
7. Chạy `apt-get update`.
8. Cài package `ductn`.

## 2. Chỉ thêm repository

Nếu chỉ muốn cấu hình repository, không cài `ductn`:

```bash
curl -fsSL https://ppa.diepxuan.com/install.sh | bash -s -- --repository-only
```

Sau đó có thể cài package thủ công:

```bash
sudo apt install ductn
```

## 3. Cài bằng `wget`

Nếu máy không có `curl` nhưng có `wget`:

```bash
wget -qO- https://ppa.diepxuan.com/install.sh | bash
```

Hoặc chỉ thêm repository:

```bash
wget -qO- https://ppa.diepxuan.com/install.sh | bash -s -- --repository-only
```

## 4. Cấu hình thủ công

Chỉ dùng cách thủ công khi cần debug hoặc khi installer không phù hợp với môi trường hiện tại.

### 4.1. Cài dependency

```bash
sudo apt-get update
sudo apt-get install -y gnupg curl
```

### 4.2. Tải và cài keyring

```bash
curl -fsSL https://ppa.diepxuan.com/key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/diepxuan.gpg
```

### 4.3. Thêm source list

Thay `<codename>` bằng codename của hệ điều hành, ví dụ `bookworm`, `bullseye`, `jammy`, `noble`.

```bash
echo "deb [signed-by=/usr/share/keyrings/diepxuan.gpg] https://ppa.diepxuan.com <codename> main" | sudo tee /etc/apt/sources.list.d/diepxuan.list
```

Ví dụ Debian 12 Bookworm:

```bash
echo "deb [signed-by=/usr/share/keyrings/diepxuan.gpg] https://ppa.diepxuan.com bookworm main" | sudo tee /etc/apt/sources.list.d/diepxuan.list
```

### 4.4. Cập nhật APT index

```bash
sudo apt-get update
```

## 5. GPG key chuẩn

APT repository được ký bằng key:

```text
Key ID:      7E0EC917A5074BD3
Fingerprint: C8BD 5D6C 638E 8A11 9389 2926 7E0E C917 A507 4BD3
```

Fingerprint dạng không khoảng trắng:

```text
C8BD5D6C638E8A11938929267E0EC917A5074BD3
```

Kiểm tra key public trên server:

```bash
curl -fsSL https://ppa.diepxuan.com/key.gpg | gpg --show-keys --with-fingerprint --keyid-format long
```

Kiểm tra keyring đã cài:

```bash
gpg --show-keys --with-fingerprint --keyid-format long /usr/share/keyrings/diepxuan.gpg
```

## 6. Kiểm tra sau cài đặt

Kiểm tra source list:

```bash
cat /etc/apt/sources.list.d/diepxuan.list
```

Kiểm tra `apt-get update`:

```bash
sudo apt-get update
```

Kiểm tra package:

```bash
apt-cache policy ductn
```

Nếu `apt-get update` không còn báo lỗi GPG và `apt-cache policy` hiển thị package từ `ppa.diepxuan.com`, repository đã được cấu hình đúng.

## 7. Gỡ cấu hình repository

Nếu cần gỡ repository khỏi máy:

```bash
sudo rm -f /etc/apt/sources.list.d/diepxuan.list
sudo rm -f /usr/share/keyrings/diepxuan.gpg
sudo apt-get update
```

Lưu ý: thao tác này chỉ gỡ cấu hình repository và keyring, không tự gỡ các package đã cài từ repository.
