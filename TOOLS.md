# TOOLS.md - Ghi Chú Cục Bộ

## Hạ tầng PPA

- **Repository:** /root/.openclaw/workspace/projects/ppa
- **Public URL:** https://ppa.diepxuan.com
- **GPG Key:** /root/.openclaw/workspace/projects/ppa/Release.gpg, /root/.openclaw/workspace/projects/ppa/key.gpg
- **Database:** /root/.openclaw/workspace/projects/ppa/db/

## Distributions Hỗ Trợ

### Debian

- buster (10)
- bullseye (11)
- bookworm (12)
- trixie (13)

### Ubuntu

- bionic (18.04)
- focal (20.04)
- jammy (22.04)
- noble (24.04)
- oracular (24.10)
- plucky (25.04)

## Packages

- **ductn** - DiepXuan super package
- **ductn-ll** - Package cung cấp lệnh 'll' (alias ls -l)
- **lar** - Package hỗ trợ Laravel
- **m2** - Package hỗ trợ Magento 2
- **php-runkit7** - PHP runkit7 extension
- **php-sqlsrv** - SQL Server driver cho PHP
- **php-pdo_sqlsrv** - PDO SQL Server driver cho PHP

## Build Tools

- reprepro 5.3.0
- dpkg-dev, debhelper
- dput (dùng để upload lên Launchpad)
- GPG signing enabled

## SSH/Remote

- Launchpad PPA: caothu91ppa
- Config: ~/.dput.cf

## Xử Lý Lỗi Tool/Command

**Quy tắc:**

Khi thực hiện tool, cmd, exec, .v.v. nếu gặp lỗi hoặc loop:

1. **Dừng lại** - không gọi lại lặp lại
2. **Báo cáo Sếp** - mô tả lỗi, nguyên nhân nếu biết
3. **Đề xuất phương án:**
    - Cách sửa lỗi (nếu biết)
    - Phương án đi vòng / bỏ qua
    - Phương án thay thế

**Ví dụ lỗi:**

- `cat /usr/share/dh-php/pkg-pecl.mk` không tồn tại → dừng lại, không gọi lại 50 lần
- `gh pr diff` lỗi format → dừng lại, kiểm tra cú pháp
- `git push` fail → dừng lại, kiểm tra branch, remote

**Khi nào retry:**

- Chỉ retry khi đã xác định nguyên nhân và có cách sửa
- Tối đa 1 lần retry sau khi đã sửa
- Nếu vẫn lỗi → dừng lại → báo cáo Sếp
