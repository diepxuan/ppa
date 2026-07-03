# TOOLS.md - PPA Local Notes

Tài liệu này ghi chú cục bộ về đường dẫn OpenClaw, hạ tầng PPA và công cụ
build/test. Đây là nguồn context cho tool-related task, không phải persona.

Theo OpenClaw docs (`concepts/agent-workspace.md`), `TOOLS.md` là
**notes for skills** — guidance, không điều khiển tool availability.

---

## 1. OpenClaw Paths

| Loại | Path |
|------|------|
| Config | `~/.openclaw/openclaw.json` |
| State | `~/.openclaw/` |
| Workspace | `~/.openclaw/workspace/projects/ppa` |
| Agent dir | `~/.openclaw/agents/ppa/agent` |
| Sessions | `~/.openclaw/agents/ppa/sessions` |
| Memory | `MEMORY.md`, `memory/YYYY-MM-DD.md` (trong workspace) |

---

## 2. PPA Infrastructure

- **Repository:** `/root/.openclaw/workspace/projects/ppa`
- **Public URL:** https://ppa.diepxuan.com
- **GPG Key (public only):** `Release.gpg`, `key.gpg` — đây là **public signing key**
  đã publish để client verify package. Public key được commit vào repo là bình
  thường. **Tuyệt đối không commit private key** (`secring.gpg` hoặc bất kỳ
  private block nào) vào workspace — giữ ở ngoài repo (keyring mount riêng
  hoặc secret manager).
- **Key ID:** `7E0EC917A5074BD3`
- **Fingerprint:** `C8BD 5D6C 638E 8A11 9389 2926 7E0E C917 A507 4BD3`
- **Database:** `db/`
- **Installer:** `install.sh` (curl-pipe-to-bash, có kiểm tra fingerprint)

---

## 3. Phân phối hỗ trợ

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

---

## 4. Packages

| Package | Mô tả |
|---------|-------|
| ductn | DiepXuan CLI tool |
| management | DiepXuan management tools |
| diepxuan-archive-keyring | APT keyring package |
| php-sqlsrv | SQL Server driver cho PHP |
| php-pdo_sqlsrv | PDO SQL Server driver cho PHP |
| php-runkit7 | PHP runkit7 extension |

Danh sách khả dụng thay đổi theo distro/codename. Xem `pool/` cho danh sách thực tế.

---

## 5. Build Tools

- `reprepro` — quản lý APT repository
- `dpkg-dev`, `debhelper` — build Debian package
- `debuild -us -uc` — build không ký (dùng cho CI/local)
- GPG signing enabled (keyring `keyrings/`)
- `bash -n install.sh` — syntax check installer

### Build flow chuẩn

```bash
# Từ source package directory
debuild -us -uc

# Test install locally
sudo dpkg -i ../<package>_<version>_<arch>.deb
```

### Release checklist

- [ ] Update changelog (`debian/changelog`)
- [ ] Bump version trong `debian/changelog`
- [ ] Test package locally
- [ ] Build và kiểm tra `.deb`
- [ ] Commit → PR → review → merge
- [ ] Upload to PPA qua `reprepro` workflow

---

## 6. Error Handling

Chi tiết xem `AGENTS.md` §7. Tóm tắt:

- Tool lỗi/loop → Dừng → Báo cáo → Đề xuất phương án.
- Cùng kết quả 2 lần → Dừng → Không gọi lần 3.
- Retry tối đa 1 lần sau khi đã xác định nguyên nhân và sửa.

### Anti-patterns

- Gọi cùng command nhiều lần khi output giống nhau.
- Retry vô tận khi không biết nguyên nhân.
- Bỏ qua lỗi và tiếp tục.

### Khi nào retry

- Chỉ retry khi đã xác định nguyên nhân và có cách sửa.
- Tối đa 1 lần retry sau khi đã sửa.
- Nếu vẫn lỗi → dừng lại → báo cáo.

---

**Quy tắc vàng:** Gọi 2 lần cùng kết quả → dừng → báo cáo. Không gọi lần thứ 3.