# TOOLS.md - Ghi Chú Cục Bộ

## OpenClaw Paths

| Loại | Path |
|------|------|
| State dir | `~/.openclaw` |
| Workspace | `~/.openclaw/workspace/projects/ppa` |
| Agent dir | `~/.openclaw/agents/ppa/agent` |
| Sessions | `~/.openclaw/agents/ppa/sessions` |

---

## Hạ tầng PPA

- **Repository:** `/root/.openclaw/workspace/projects/ppa`
- **Public URL:** https://ppa.diepxuan.com
- **GPG Key:** `Release.gpg`, `key.gpg`
- **Database:** `db/`

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

| Package | Mô tả |
|---------|------|
| management | DiepXuan management tools |
| php-sqlsrv | SQL Server driver cho PHP |
| php-pdo_sqlsrv | PDO SQL Server driver cho PHP |
| php-runkit7 | PHP runkit7 extension |

## Build Tools

- reprepro 5.3.0
- dpkg-dev, debhelper
- GPG signing enabled

## Xử Lý Lỗi Tool/Command

**Quick Reference:**
- Tool lỗi/loop → Dừng → Báo cáo → Đề xuất phương án
- Cùng kết quả 2 lần → Dừng → Báo cáo (không gọi lần 3)
- Retry tối đa 1 lần sau khi đã sửa

### Khi Tool Trả Về Cùng Kết Quả

1. **Dừng lại ngay** - không gọi lần thứ 3
2. **Kiểm tra** - kết quả lần 1 và lần 2 có giống nhau không?
3. **Báo cáo** với kết quả đã có
4. **Đề xuất bước tiếp theo**

**Quy tắc vàng:** Gọi 2 lần cùng kết quả → dừng → báo cáo. Không gọi lần thứ 3.

### Anti-patterns

- Gọi cùng command nhiều lần khi output giống nhau
- Retry vô tận khi không biết nguyên nhân
- Bỏ qua lỗi và tiếp tục work

### Khi nào retry

- Chỉ retry khi đã xác định nguyên nhân và có cách sửa
- Tối đa 1 lần retry sau khi đã sửa
- Nếu vẫn lỗi → dừng lại → báo cáo