# DiepXuan PPA

DiepXuan PPA là repository APT chính thức để phát hành các package Debian/Ubuntu của DiepXuan.

Repository public:

```text
https://ppa.diepxuan.com
```

Mục tiêu của repo này là cung cấp một cách cài đặt ổn định, dễ kiểm tra và an toàn cho các package nội bộ, package hạ tầng và PHP extension cần dùng trong hệ sinh thái DiepXuan.

## Cài đặt nhanh

Cài repository và package `ductn`:

```bash
curl -fsSL https://ppa.diepxuan.com/install.sh | bash
```

Hoặc dùng `wget`:

```bash
wget -qO- https://ppa.diepxuan.com/install.sh | bash
```

Nếu chỉ muốn thêm repository mà chưa cài package:

```bash
curl -fsSL https://ppa.diepxuan.com/install.sh | bash -s -- --repository-only
```

Sau đó cài package khi cần:

```bash
sudo apt install ductn
```

## Package tiêu biểu

Một số package được phát hành qua PPA này:

- `ductn`
- `management`
- `diepxuan-archive-keyring`
- `php-sqlsrv`
- `php-pdo_sqlsrv`
- `php-runkit7`

Danh sách package khả dụng có thể khác nhau theo distro và codename.

## Hệ điều hành hỗ trợ

Repository được tổ chức theo Debian/Ubuntu codename.

Ví dụ các codename đang được dùng:

| Hệ điều hành | Codename |
| --- | --- |
| Debian 10 | `buster` |
| Debian 11 | `bullseye` |
| Debian 12 | `bookworm` |
| Debian 13 | `trixie` |
| Ubuntu 18.04 | `bionic` |
| Ubuntu 20.04 | `focal` |
| Ubuntu 22.04 | `jammy` |
| Ubuntu 24.04 | `noble` |
| Ubuntu 24.10 | `oracular` |
| Ubuntu 25.04 | `plucky` |

`install.sh` tự phát hiện codename từ `/etc/os-release` hoặc `/etc/lsb-release`.

## Bảo mật repository

APT repository được ký bằng GPG key sau:

```text
Key ID:      7E0EC917A5074BD3
Fingerprint: C8BD 5D6C 638E 8A11 9389 2926 7E0E C917 A507 4BD3
```

Installer sẽ:

1. Tải public key từ `https://ppa.diepxuan.com/key.gpg`.
2. Kiểm tra fingerprint của key tải về.
3. Cài hoặc refresh keyring tại `/usr/share/keyrings/diepxuan.gpg`.
4. Ghi APT source vào `/etc/apt/sources.list.d/diepxuan.list`.
5. Chạy `apt-get update`.

Điểm quan trọng: installer không chỉ kiểm tra file keyring có tồn tại hay không. Installer kiểm tra fingerprint thực tế để tránh lỗi key cũ hoặc sai key.

## Kiểm tra nhanh

Kiểm tra key public:

```bash
curl -fsSL https://ppa.diepxuan.com/key.gpg | gpg --show-keys --with-fingerprint --keyid-format long
```

Kiểm tra keyring đã cài trên máy:

```bash
gpg --show-keys --with-fingerprint --keyid-format long /usr/share/keyrings/diepxuan.gpg
```

Kiểm tra source list:

```bash
cat /etc/apt/sources.list.d/diepxuan.list
```

Ví dụ với Debian 12 Bookworm:

```text
deb [signed-by=/usr/share/keyrings/diepxuan.gpg] https://ppa.diepxuan.com bookworm main
```

## Xử lý lỗi phổ biến

Nếu gặp lỗi:

```text
NO_PUBKEY 7E0EC917A5074BD3
```

Chạy lại installer ở chế độ chỉ cấu hình repository:

```bash
curl -fsSL https://ppa.diepxuan.com/install.sh | bash -s -- --repository-only
sudo apt-get update
```

Nếu máy đang có keyring cũ, có thể reset thủ công:

```bash
sudo rm -f /usr/share/keyrings/diepxuan.gpg
curl -fsSL https://ppa.diepxuan.com/install.sh | bash -s -- --repository-only
sudo apt-get update
```

Xem hướng dẫn chi tiết tại:

- `docs/INSTALL.md`
- `docs/TROUBLESHOOTING.md`

## Tài liệu dành cho maintainer

- `docs/INSTALL.md`: hướng dẫn cài đặt và kiểm tra repository.
- `docs/TROUBLESHOOTING.md`: xử lý lỗi APT/GPG thường gặp.
- `docs/MAINTAINER.md`: quy trình kiểm tra script và tài liệu trước khi phát hành.

## Phát triển

Kiểm tra syntax script:

```bash
bash -n install.sh
```

Kiểm tra fingerprint key public:

```bash
curl -fsSL https://ppa.diepxuan.com/key.gpg | gpg --show-keys --with-colons --fingerprint | awk -F: '$1 == "fpr" {print $10; exit}'
```

Kỳ vọng:

```text
C8BD5D6C638E8A11938929267E0EC917A5074BD3
```

Mọi thay đổi nên đi qua branch riêng, commit rõ ràng và PR để review trước khi merge.
