# Phương Án Fork runkit7 - Hỗ Trợ PHP 8.4

**Ngày:** 2026-04-23
**Quyết định:** Fork runkit7/runkit7 → diepxuan/runkit7

---

## 1. Mục Tiêu

- Hỗ trợ runkit7 cho PHP 8.4 và 8.5
- Không phụ thuộc upstream (runkit7/runkit7)
- Full control: có thể custom, fix bug, merge PR community

---

## 2. Bối Cảnh

### runkit7 Là Gì

PHP extension cho phép:
- Thêm/xóa/sửa hàm, phương thức, class lúc runtime
- Manipulate constants, properties động
- Dùng cho testing, mocking, hot-patching

### Vấn Đề Hiện Tại

- **Version hiện tại:** 4.0.0a6 (release 2024-08)
- **PHP 8.4 breaking changes:**
  - `doc_comment` di chuyển từ `info.user.doc_comment` → `doc_comment`
  - `rebuild_object_properties()` → `rebuild_object_properties_internal()`
- **Upstream status:**
  - Issue #277 mở từ 2025-06: "No possible to build project in php 8.4"
  - PR #276 của mfadul24: fix PHP 8.4 - **chưa merge, tests fail**
  - Không có release mới từ 2024-08

### Tại Sao Fork

- Upstream không active (18 tháng không release mới)
- PR community có patch nhưng không được merge
- Cần PHP 8.4 support cho PPA
- Không có extension thay thế tương thích API

---

## 3. Các Bước Thực Hiện

### Bước 1: Fork Repository

```bash
# Fork từ GitHub UI hoặc gh CLI
gh repo fork runkit7/runkit7 --org diepxuan --clone

cd runkit7

# Set up remotes
git remote add upstream https://github.com/runkit7/runkit7.git
```

### Bước 2: Apply PHP 8.4 Patch

**File 1: `runkit_classes.c` (line ~209)**

```c
#if PHP_VERSION_ID >= 80400
	new_class_entry->doc_comment = src->doc_comment;
#else
	new_class_entry->info.user.doc_comment = src->info.user.doc_comment;
#endif
```

**File 2: `runkit_props.c` (line ~39)**

```c
#if PHP_VERSION_ID >= 80400
	rebuild_object_properties_internal(object);
#else
	rebuild_object_properties(object);
#endif
```

**File 3: `.github/workflows/main.yml`**

Thêm PHP 8.3 và 8.4 vào test matrix:
```yaml
- PHP_VERSION: '8.3'
  PHP_VERSION_FULL: 8.3.22
- PHP_VERSION: '8.4'
  PHP_VERSION_FULL: 8.4.8
```

### Bước 3: Update Version

```
# runkit7.spec hoặc package.xml
version: 4.0.0a7
stability: alpha
```

**Lý do:**
- Phân biệt với upstream 4.0.0a6
- Cho phép PPA build version mới
- Dễ track khi sync upstream

### Bước 4: Build & Test

```bash
# Build trên PHP 8.4
pecl install -f runkit7-alpha

# Run tests
make test

# Build Debian package
dpkg-buildpackage --force-sign
```

### Bước 5: Update PPA Build System

**File: `src/php-ext/src/debian/runkit7.control.in`**

```
# Thay đổi X-PHP-Versions
-X-PHP-Versions: 7.2 7.3 7.4 8.0 8.1 8.2 8.3
+X-PHP-Versions: 7.2 7.3 7.4 8.0 8.1 8.2 8.3 8.4 8.5
```

**File: `src/php-ext/src/build.sh`**

```bash
# Thay đổi source download
# Từ: pecl download runkit7-$stability
# Sang: git clone https://github.com/diepxuan/runkit7.git
```

Hoặc giữ nguyên `pecl download` nhưng publish lên PECL từ fork.

### Bước 6: Push & Release

```bash
# Push fork
git push origin main

# Tạo release
gh release create v4.0.0a7 \
  --title "runkit7 4.0.0a7 (DiepXuan Fork)" \
  --notes "PHP 8.4 compatibility fix"

# Tag
git tag -a v4.0.0a7 -m "DiepXuan fork: PHP 8.4 support"
git push origin v4.0.0a7
```

---

## 4. Maintenance Plan

### Sync Upstream

**Tần suất:** Hàng tháng

```bash
# Fetch upstream
git fetch upstream

# Xem changes
git log HEAD..upstream/main --oneline

# Merge nếu có changes quan trọng
git merge upstream/main -m "[sync] Merge upstream runkit7/main"

# Resolve conflicts (nếu có)
# Test lại
make test

# Push
git push origin main
```

**Khi nào sync:**
- Upstream release version mới
- Upstream merge security fix
- Upstream có changes quan trọng (bug fix, performance)

**Khi nào KHÔNG sync:**
- Upstream chỉ thay đổi docs
- Upstream có breaking changes chưa test
- Fork đã diverge quá nhiều

### Release Flow

```
Upstream release → Sync → Test → Release fork
                                    ↓
                        Update X-PHP-Versions nếu cần
                                    ↓
                        Build PPA packages
                                    ↓
                        Update PPA repository
```

---

## 5. Timeline

| Bước | Thời gian | Ghi chú |
|------|-----------|---------|
| Fork repository | 15 phút | Tạo fork, clone |
| Apply patch | 30 phút | 2 file C code |
| Build & test | 1-2 giờ | Chạy tests, fix nếu fail |
| Update PPA | 30 phút | Thay đổi build system |
| Release | 15 phút | Tag, release |
| **Tổng** | **3-4 giờ** | Lần đầu |

**Maintenance sau này:**
- Sync upstream: 30 phút/tháng
- Release mới: 1-2 giờ/lần (nếu upstream update)

---

## 6. Risks & Mitigation

### Rủi Ro 1: Tests Fail Sau Khi Patch

**Mức độ:** Cao (PR #276 đã có tests fail)

**Mitigation:**
- Chạy `make test` trước khi release
- Document tests nào fail và lý do
- Nếu critical test fail → không release, báo Sếp

### Rủi Ro 2: Upstream Release Version Mới

**Mức độ:** Trung bình (18 tháng không release)

**Mitigation:**
- Sync upstream hàng tháng
- Merge changes quan trọng
- Nếu upstream fix PHP 8.4 → có thể bỏ fork

### Rủi Ro 3: PHP Version Mới (8.5, 8.6)

**Mức độ:** Thấp (PHP 8.5 chưa release)

**Mitigation:**
- Theo dõi PHP release schedule
- Test trên PHP 8.5 khi có
- Apply patch tương tự nếu cần

### Rủi Ro 4: Fork Diverge Quá Nhiều

**Mức độ:** Thấp (chỉ sửa 2 file)

**Mitigation:**
- Giữ patch tối thiểu
- Không thêm tính năng mới vào fork
- Chỉ fix bug và compatibility

---

## 7. Cost Estimate

### Chi Phí Ban Đầu

| Hạng mục | Thời gian | Ghi chú |
|----------|-----------|---------|
| Fork & setup | 15 phút | Tạo fork, clone |
| Apply patch | 30 phút | 2 file C code |
| Build & test | 1-2 giờ | Chạy tests, fix |
| Update PPA | 30 phút | Build system |
| Release | 15 phút | Tag, release |
| **Tổng** | **3-4 giờ** | |

### Chi Phí Dài Hạn

| Hạng mục | Tần suất | Thời gian |
|----------|----------|-----------|
| Sync upstream | Hàng tháng | 30 phút |
| Release mới | Khi upstream update | 1-2 giờ |
| PHP version mới | Mỗi 1-2 năm | 2-4 giờ |
| **Trung bình/năm** | | **4-8 giờ** |

---

## 8. File Thay Đổi

### Repository Mới: `diepxuan/runkit7`

| File | Thay đổi |
|------|----------|
| `runkit_classes.c` | Thêm `#if PHP_VERSION_ID >= 80400` |
| `runkit_props.c` | Thêm `#if PHP_VERSION_ID >= 80400` |
| `.github/workflows/main.yml` | Thêm PHP 8.3, 8.4 test matrix |
| `package.xml` | Update version → 4.0.0a7 |

### Repository PPA: `diepxuan/ppa`

| File | Thay đổi |
|------|----------|
| `src/php-ext/src/debian/runkit7.control.in` | `X-PHP-Versions` thêm 8.4, 8.5 |
| `src/php-ext/src/build.sh` | Thay đổi source download (nếu cần) |

---

## 9. Checklist

### Fork Setup

- [ ] Fork `runkit7/runkit7` → `diepxuan/runkit7`
- [ ] Clone fork về local
- [ ] Set up upstream remote
- [ ] Verify fork hoạt động

### Patch

- [ ] Apply patch `runkit_classes.c`
- [ ] Apply patch `runkit_props.c`
- [ ] Update `.github/workflows/main.yml`
- [ ] Update version → 4.0.0a7

### Build & Test

- [ ] Build trên PHP 8.4
- [ ] Run `make test`
- [ ] Document tests fail (nếu có)
- [ ] Build Debian package

### PPA Update

- [ ] Update `runkit7.control.in`
- [ ] Update `build.sh` (nếu cần)
- [ ] Build PPA package
- [ ] Test install trên PHP 8.4

### Release

- [ ] Push fork
- [ ] Tạo GitHub release v4.0.0a7
- [ ] Tag version
- [ ] Update PPA repository

---

## 10. Rollback Plan

Nếu fork không hoạt động hoặc có vấn đề nghiêm trọng:

1. **Revert PPA changes:**
   ```bash
   git revert <commit-hash>
   git push origin main
   ```

2. **Giữ nguyên `X-PHP-Versions` đến 8.3:**
   - Không build cho PHP 8.4
   - Chờ upstream fix hoặc phương án khác

3. **Xóa fork (nếu không cần):**
   ```bash
   gh repo delete diepxuan/runkit7
   ```

---

**Tài liệu này được tạo theo quyết định của Sếp ngày 2026-04-23.**
