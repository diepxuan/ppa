# DiepXuan PPA

DiepXuan PPA là repository APT dùng để phát hành các package Debian/Ubuntu của DiepXuan.

Public repository:

```text
https://ppa.diepxuan.com
```

## Package hiện có

Repository này phục vụ các package nội bộ/extension như:

- `ductn`
- `management`
- `diepxuan-archive-keyring`
- `php-sqlsrv`
- `php-pdo_sqlsrv`
- `php-runkit7`

Danh sách package thực tế phụ thuộc vào distro codename đang dùng.

## Hệ điều hành hỗ trợ

Repository được cấu hình theo codename Debian/Ubuntu, ví dụ:

- Debian: `buster`, `bullseye`, `bookworm`, `trixie`
- Ubuntu: `bionic`, `focal`, `jammy`, `noble`, `oracular`, `plucky`

Script `install.sh` tự đọc codename từ `/etc/os-release` hoặc `/etc/lsb-release`.

## Cài đặt nhanh

Cài repository và package `ductn`:

```bash
curl -fsSL https://ppa.diepxuan.com/install.sh | bash
```

Hoặc dùng `wget`:

```bash
wget -qO- https://ppa.diepxuan.com/install.sh | bash
```

Chỉ cấu hình repository, không cài `ductn`:

```bash
curl -fsSL https://ppa.diepxuan.com/install.sh | bash -s -- --repository-only
```

Sau đó có thể cài package thủ công:

```bash
sudo apt install ductn
```

## GPG signing key

APT repository được ký bằng key:

```text
Key ID:      7E0EC917A5074BD3
Fingerprint: C8BD 5D6C 638E 8A11 9389 2926 7E0E C917 A507 4BD3
```

Key public được tải từ:

```text
https://ppa.diepxuan.com/key.gpg
```

Keyring local được lưu tại:

```text
/usr/share/keyrings/diepxuan.gpg
```

APT source được lưu tại:

```text
/etc/apt/sources.list.d/diepxuan.list
```

Dòng repository có dạng:

```text
deb [signed-by=/usr/share/keyrings/diepxuan.gpg] https://ppa.diepxuan.com <codename> main
```

Ví dụ với Debian 12 Bookworm:

```text
deb [signed-by=/usr/share/keyrings/diepxuan.gpg] https://ppa.diepxuan.com bookworm main
```

## Kiểm tra key thủ công

Tải key và xem fingerprint:

```bash
curl -fsSL https://ppa.diepxuan.com/key.gpg | gpg --show-keys --with-fingerprint --keyid-format long
```

Kết quả hợp lệ phải có:

```text
7E0EC917A5074BD3
C8BD 5D6C 638E 8A11 9389 2926 7E0E C917 A507 4BD3
```

Kiểm tra keyring đã cài trên máy:

```bash
gpg --show-keys --with-fingerprint --keyid-format long /usr/share/keyrings/diepxuan.gpg
```

Nếu fingerprint không đúng, chạy lại installer. Script sẽ tự refresh keyring sai hoặc cũ.

## Hành vi của `install.sh`

`install.sh` thực hiện các bước:

1. Parse option `--repository-only` nếu có.
2. Xác định distro codename.
3. Tải public key từ `https://ppa.diepxuan.com/key.gpg`.
4. Kiểm tra fingerprint key tải về phải đúng:

   ```text
   C8BD5D6C638E8A11938929267E0EC917A5074BD3
   ```

5. Convert key sang keyring dạng dearmor.
6. Kiểm tra keyring đang có tại `/usr/share/keyrings/diepxuan.gpg`.
7. Nếu keyring thiếu, sai, hoặc cũ thì cài lại keyring mới.
8. Ghi lại APT source vào `/etc/apt/sources.list.d/diepxuan.list`.
9. Chạy `apt-get update`.
10. Cài `ductn`, trừ khi dùng `--repository-only`.

Điểm quan trọng: script không chỉ kiểm tra file keyring có tồn tại hay không. Script kiểm tra fingerprint thực tế để tránh lỗi:

```text
NO_PUBKEY 7E0EC917A5074BD3
```

## Sửa lỗi thường gặp

### Lỗi `NO_PUBKEY 7E0EC917A5074BD3`

Lỗi mẫu:

```text
W: An error occurred during the signature verification.
GPG error: https://ppa.diepxuan.com bookworm InRelease:
The following signatures couldn't be verified because the public key is not available:
NO_PUBKEY 7E0EC917A5074BD3
```

Nguyên nhân thường gặp:

- Máy có keyring cũ ở `/usr/share/keyrings/diepxuan.gpg`.
- Keyring tồn tại nhưng không chứa fingerprint đúng.
- File source list trỏ tới keyring khác.

Cách xử lý khuyến nghị:

```bash
curl -fsSL https://ppa.diepxuan.com/install.sh | bash -s -- --repository-only
sudo apt-get update
```

Nếu muốn reset thủ công:

```bash
sudo rm -f /usr/share/keyrings/diepxuan.gpg
curl -fsSL https://ppa.diepxuan.com/install.sh | bash -s -- --repository-only
sudo apt-get update
```

### Kiểm tra source list

```bash
cat /etc/apt/sources.list.d/diepxuan.list
```

Kỳ vọng với Bookworm:

```text
deb [signed-by=/usr/share/keyrings/diepxuan.gpg] https://ppa.diepxuan.com bookworm main
```

### Kiểm tra repository update

```bash
sudo apt-get update
```

Nếu không còn lỗi `NO_PUBKEY`, repository đã được cấu hình đúng.

## Phát triển trong repo

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

Không push hoặc tạo PR trực tiếp nếu chưa được Sếp cho phép.
