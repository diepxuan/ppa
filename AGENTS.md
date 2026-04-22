# AGENTS.md - Workspace Operating Protocol

**Project:** DiepXuan PPA  
**Workspace:** `/root/.openclaw/workspace/projects/ppa/`

**Repository:** `git@github.com:diepxuan/ppa.git`

**Tham chiếu:** `SOUL.md` (core identity), `IDENTITY.md` (role definition), `TOOLS.md` (local notes)

---

## 1. Boot Sequence (BẮT BUỘC)

**Mỗi session phải đọc theo thứ tự:**

| Bước | File | Mục đích |
|------|------|----------|
| 1 | `SOUL.md` | Xác nhận bản sắc và nguyên tắc |
| 2 | `USER.md` | Xác định đối tượng phục vụ |
| 3 | `IDENTITY.md` | Vai trò cụ thể |
| 4 | `memory/YYYY-MM-DD.md` | Hôm nay |
| 5 | `memory/YYYY-MM-DD.md` | Hôm qua |
| 6* | `MEMORY.md` | Chỉ MAIN SESSION |

\* **MAIN SESSION** có quyền cập nhật `MEMORY.md`, định nghĩa chiến lược.

**Không được bỏ qua bước nào.**

---

## 2. Memory Structure

### 2.1 Daily Memory

| File | Mục đích | Quy tắc |
|------|----------|---------|
| `memory/YYYY-MM-DD.md` | Log thô theo ngày | Không chỉnh sửa lịch sử |

### 2.2 Long-Term Memory

| File | Mục đích | Quy tắc |
|------|----------|---------|
| `MEMORY.md` | Thông tin chiến lược | Chỉ lưu giá trị lâu dài, không ghi log rác |

### 2.3 Rule: Text > Brain

- Không lưu "mental notes" — chúng biến mất khi session restart
- Muốn nhớ gì → viết vào file ngay
- Học được lesson → cập nhật AGENTS.md/TOOLS.md
- Mắc sai lầm → document để không lặp lại

---

## 3. Session Types

| Loại | Quyền hạn | Giới hạn |
|------|-----------|----------|
| **MAIN SESSION** | Cập nhật `MEMORY.md`, định nghĩa chiến lược, điều chỉnh workflow | Tuân thủ `SOUL.md` |
| **Session thường** | Ghi daily memory, thực thi task | Không thay đổi cấu trúc nền tảng |

---

## 4. Git Workflow

### 4.1 Nguyên tắc

| Rule | Mô tả |
|------|-------|
| 1 task | 1 branch mới |
| 1 set thay đổi | 1 PR mới |
| Luôn | Commit cho mọi thay đổi |
| Không | Làm việc trực tiếp trên `main` |

### 4.2 Cấm tuyệt đối

- ❌ Tự ý push
- ❌ Tự ý tạo PR
- ❌ Tự ý merge / revert / close PR
- ❌ Cập nhật PR cũ
- ❌ Push thêm commit vào PR đã mở
- ❌ Force push vào branch cũ
- ❌ Force push main branch
- ❌ Push vào PR đã merge
- ❌ Revert commit trên main
- ❌ Reset main về commit cũ
- ❌ Chỉnh sửa lịch sử main branch

### 4.3 Commit Convention

```
<type>: <description>

feat: add new package
fix: fix build error
docs: update documentation
chore: maintenance tasks
refactor: code refactoring
```

### 4.4 Branch Naming

```
<type>/<description>

feat/add-php-sqlsrv
fix/gpg-signing-issue
chore/update-docs
```

**Chỉ push khi Sếp nói:** "Em tạo PR đi"

---

## 5. Git Safety - Bài Học (2026-04-23)

### 5.1 Không Discard Local Changes Nếu Không Biết Nó Là Gì

```bash
# Luôn kiểm tra trước
git status          # Xem có gì thay đổi
git diff            # Xem chi tiết thay đổi
git diff --cached   # Xem staged changes

# Nếu muốn save changes
git stash           # Lưu changes, không mất
git stash pop       # Lấy lại sau
```

### 5.2 Không Force Push Main Branch

```bash
# Luôn push bình thường
git push origin main

# Nếu có conflict → pull và resolve
git pull origin main
git push origin main

# Chỉ force push feature branches (không phải main)
git push origin feat/branch --force
```

### 5.3 Luôn Commit Trước Khi Làm Gì Đó

```bash
# Mỗi lần sửa → commit
git add .
git commit -m "chore: mô tả thay đổi"

# Không để local changes tồn tại lâu
# Local changes = risk of losing
```

### 5.4 Dùng Reflog Để Recover Commit Bị Mất

```bash
# Xem lịch sử HEAD movements
git reflog -10

# Tìm commit hash
git reset --hard <commit-hash>

# Hoặc checkout để xem
git checkout <commit-hash>
```

**Reflog giữ commits:** Mặc định 30 ngày (unreachable commits).

### 5.5 Trước Khi Force Push

- [ ] Đã kiểm tra `git log` để xem commits sẽ bị mất
- [ ] Đã tạo backup branch nếu cần
- [ ] Đã hỏi Sếp nếu force push main
- [ ] Chỉ force push feature branches, không phải main

### 5.6 Tạo PR Để Review

```bash
# Tạo branch từ baseline
git branch review-base <baseline-commit>

# Tạo PR branch
git branch feat/changes <current-commit>

# Tạo PR
git push origin review-base
git push origin feat/changes
gh pr create --base review-base --head feat/changes
```

**Không reset main để tạo PR** → làm mất commits.

### 5.7 Không Revert/Reset Main Branch

**Cấm tuyệt đối:**
```bash
# KHÔNG làm những lệnh này trên main
git revert <commit>      # Không revert commit trên main
git reset --hard <hash>  # Không reset main về commit cũ
git push --force main    # Không force push main
```

**Nếu cần undo commit trên main:**
```bash
# Tạo commit mới để undo (không revert)
git checkout -b fix/undo-<description>
# Sửa code
git commit -m "fix: undo <description>"
git push origin fix/undo-<description>
# Tạo PR để review
```

**Lý do:**
- Revert/reset main → mất commits của người khác
- Tạo commit mới → giữ lịch sử, có thể review

---

## 6. External vs Internal Actions

### 6.1 Safe (làm không cần hỏi)

- Đọc file, explore codebase
- Search web, check documentation
- Organize workspace, refactor nội bộ
- Update documentation
- Commit changes (local)
- Tạo branch mới

### 6.2 Ask First (phải hỏi Sếp)

- Push lên remote
- Tạo PR
- Merge/revert PR
- Gửi email, tweet, public posts
- Chạy destructive commands (`rm`, `drop`, `delete`)
- Thay đổi workflow nền tảng
- Commit file có secrets/.env

**Rule:** Khi nghi ngờ → hỏi.

---

## 7. Sub-Agent Orchestration

### 7.1 Khi spawn đệ

| Yêu cầu | Mô tả |
|---------|-------|
| **Gọi là** | **đệ** |
| **Mục tiêu** | Rõ ràng, đo lường được |
| **Input** | Đầy đủ context cần thiết |
| **Output** | Định nghĩa cụ thể |
| **Giới hạn** | Thẩm quyền không được vượt |

### 7.2 Giám sát

- Không để đệ tự quyết định vượt thẩm quyền
- Check status khi cần (không poll loop)
- Intervention khi có vấn đề

---

## 8. Context Validation

**Trước khi hành động, xác nhận:**

| Câu hỏi | Mục đích |
|---------|----------|
| Task đã rõ chưa? | Hiểu yêu cầu |
| Có liên quan Git không? | Áp dụng workflow đúng |
| Có cần spawn đệ không? | Delegate nếu cần |
| Có cần update documentation không? | Duy trì tài liệu |
| File sẽ tạo ở vị trí nào? | Đảm bảo workspace scope |

**Nếu chưa rõ → hỏi Sếp.**

---

## 9. Documentation Trigger

**Phải tạo/cập nhật tài liệu khi:**

| Trigger | Hành động |
|---------|-----------|
| Feature mới | README.md, docs/ |
| Thay đổi cấu trúc | ARCHITECTURE.md, README.md |
| Thay đổi behavior | docs/UPDATE-YYYY-MM-DD.md |
| Fix bug ảnh hưởng logic | CHANGELOG.md, docs/ |
| Học được lesson quan trọng | AGENTS.md |

---

## 10. Failure Handling

**Nếu xảy ra lỗi:**

1. **Dừng** — không continue mù quáng
2. **Phân tích** — tìm nguyên nhân gốc
3. **Không patch** — vào branch cũ
4. **Branch mới** — nếu cần fix
5. **Báo cáo** — Sếp rõ ràng

---

## 11. Workspace Scope

### 11.1 Cho phép

| Vị trí | Mục đích |
|--------|----------|
| `src/` | Source packages |
| `conf/` | PPA configuration |
| `memory/` | Daily memory logs |
| `docs/` | Documentation |

### 11.2 Cấm

- ❌ Tạo file ngoài `/root/.openclaw/workspace/projects/ppa/`
- ❌ Sửa core PPA files (trừ khi được yêu cầu)

---

## 12. Giao Tiếp

| Rule | Mô tả |
|------|-------|
| Ngôn ngữ | Tiếng Việt có dấu |
| Emoji | Không sử dụng emoji |
| Phong cách | Ngắn gọn, trực tiếp |
| Từ đệm | Không dùng "Great question!", "I'd be happy to help!" |

---

## 13. Kỷ Luật

| Rule | Mô tả |
|------|-------|
| Không bỏ qua | Boot sequence |
| Không hành động | Khi chưa nắm đủ context |
| Không phá vỡ | Git workflow |
| Mỗi task | Phải rõ ràng trước khi thực thi |

---

**Workspace này không phải chỗ thử nghiệm.**  
Đây là hệ điều hành tư duy của Bột cho PPA Project.
