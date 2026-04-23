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

**Quick Reference:**
- Tool lỗi/loop → Dừng → Báo cáo → Đề xuất phương án
- Cùng kết quả 2 lần → Dừng → Báo cáo (không gọi lần 3)
- Retry tối đa 1 lần sau khi đã sửa

**Quy tắc chung:**

Khi thực hiện tool, cmd, exec nếu gặp lỗi hoặc loop:

1. **Dừng lại** - không gọi lại lặp lại
2. **Báo cáo** - mô tả lỗi, nguyên nhân nếu biết
3. **Đề xuất phương án:**
    - Cách sửa lỗi (nếu biết)
    - Phương án đi vòng / bỏ qua
    - Phương án thay thế

### Khi Tool Trả Về Cùng Kết Quả

**Quy tắc:**

Khi gọi tool nhiều lần và kết quả **giống nhau** (cùng output, cùng status):

1. **Dừng lại ngay** - không gọi lần thứ 3
2. **Kiểm tra:**
    - Kết quả lần 1 và lần 2 có giống nhau không?
    - Nếu giống → tool đã trả hết thông tin, gọi thêm cũng vô ích
3. **Báo cáo** với kết quả đã có
4. **Đề xuất bước tiếp theo** - không cần gọi thêm tool

**Dấu hiệu nhận biết loop:**

- Gọi cùng 1 command nhiều lần
- Output giống hệt nhau
- Không có bước trung gian thay đổi state
- Không có lý do chính đáng để retry

**Hành động đúng:**

- Gọi command **1 lần** → nhận kết quả → phân tích → báo cáo
- Nếu cần thêm thông tin → gọi command **khác**, không gọi lại command cũ
- Nếu command fail → dừng → báo cáo, không retry vô tận

**Quy tắc vàng:** Gọi 2 lần cùng kết quả → dừng → báo cáo. Không gọi lần thứ 3.

### Anti-patterns (Không làm)

- Gọi cùng command nhiều lần khi output giống nhau
- Retry vô tận khi không biết nguyên nhân
- Bỏ qua lỗi và tiếp tục work
- Copy-paste command nhiều lần mà không kiểm tra kết quả

### Khi nào retry:

- Chỉ retry khi đã xác định nguyên nhân và có cách sửa
- Tối đa 1 lần retry sau khi đã sửa
- Nếu vẫn lỗi → dừng lại → báo cáo

### Ví dụ:

- `cat /usr/share/dh-php/pkg-pecl.mk` gọi 50+ lần → file không tồn tại → dừng
- `ls -la` + `diff` gọi 10 lần → cùng kết quả → dừng
- `gh pr diff` lỗi format → dừng, kiểm tra cú pháp
- `git push` fail → dừng, kiểm tra branch, remote
