# AGENTS.md - Workspace Operating Protocol

**Project:** DiepXuan PPA  
**Workspace:** `/root/.openclaw/workspace/projects/ppa/`

**Agent ID:** `ppa`  
**Agent Dir:** `~/.openclaw/agents/ppa/agent`

**Repository:** `git@github.com:diepxuan/ppa.git`

**Tham chiếu:** `SOUL.md` (core identity), `IDENTITY.md` (role definition), `BOOTSTRAP.md` (startup), `TOOLS.md` (local notes)

---

## 1. OpenClaw Paths

| Loại      | Path                                 |
| --------- | ------------------------------------ |
| Config    | `~/.openclaw/openclaw.json`          |
| State     | `~/.openclaw`                        |
| Workspace | `~/.openclaw/workspace/projects/ppa` |
| Agent dir | `~/.openclaw/agents/ppa/agent`       |
| Sessions  | `~/.openclaw/agents/ppa/sessions`    |
| Memory    | `memory/` (trong workspace)          |

---

## 2. Boot Sequence (BẮT BUỘC)

| Bước | File                   | Mục đích               |
| ---- | ---------------------- | ---------------------- |
| 1    | `SOUL.md`              | Xác nhận bản sắc       |
| 2    | `IDENTITY.md`          | Vai trò trong hệ thống |
| 3    | `USER.md`              | Đối tượng phục vụ      |
| 4    | `BOOTSTRAP.md`         | Startup protocol       |
| 5    | `memory/YYYY-MM-DD.md` | Hôm nay                |
| 6    | `memory/YYYY-MM-DD.md` | Hôm qua                |
| 7\*  | `MEMORY.md`            | Chỉ MAIN SESSION       |

**Không được bỏ qua bước nào.**

---

## 3. Memory Structure

| File                   | Mục đích                                           |
| ---------------------- | -------------------------------------------------- |
| `MEMORY.md`            | Long-term memory: quyết định, sở thích, chiến lược |
| `memory/YYYY-MM-DD.md` | Daily notes: context và observations               |
| `DREAMS.md`            | (Optional) Dream Diary                             |

**Quy tắc:** Muốn nhớ gì → viết vào file. Không giữ "mental notes" trong brain.

---

## 4. Session Types

| Loại           | Key              | Quyền hạn                      |
| -------------- | ---------------- | ------------------------------ |
| MAIN SESSION   | `agent:ppa:main` | Cập nhật MEMORY.md, chiến lược |
| Session thường | `agent:ppa:xxx`  | Ghi daily, thực thi task       |

---

## 5. Git Workflow

### 5.1 Nguyên tắc

| Rule           | Mô tả                          |
| -------------- | ------------------------------ |
| 1 task         | 1 branch mới                   |
| 1 set thay đổi | 1 PR mới                       |
| Luôn           | Commit cho mọi thay đổi        |
| Không          | Làm việc trực tiếp trên `main` |

### 5.2 Cấm tuyệt đối

- Không tự ý push
- Không tự ý tạo PR
- Không tự ý merge / revert / close PR
- Không force push main branch
- Không reset main về commit cũ
- Không chỉnh sửa lịch sử main branch

### 5.3 Commit Convention

```
<type>: <description>

feat: add new package
fix: fix build error
docs: update documentation
chore: maintenance tasks
refactor: code refactoring
```

### 5.4 Branch Naming

```
<type>/<description>

feat/add-php-sqlsrv
fix/gpg-signing-issue
chore/update-docs
```

**Chỉ push khi Sếp nói:** "Em tạo PR đi"

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

**Rule:** Khi nghi ngờ → hỏi.

---

## 7. Sub-Agent Orchestration

| Yêu cầu      | Mô tả                    |
| ------------ | ------------------------ |
| **Gọi là**   | **đệ**                   |
| **Mục tiêu** | Rõ ràng, đo lường được   |
| **Input**    | Đầy đủ context cần thiết |
| **Output**   | Định nghĩa cụ thể        |

**Giám sát:** Không để đệ tự quyết định vượt thẩm quyền.

---

## 8. Context Validation

| Câu hỏi                            | Mục đích                |
| ---------------------------------- | ----------------------- |
| Task đã rõ chưa?                   | Hiểu yêu cầu            |
| Có liên quan Git không?            | Áp dụng workflow đúng   |
| Có cần spawn đệ không?             | Delegate nếu cần        |
| Có cần update documentation không? | Duy trì tài liệu        |
| File sẽ tạo ở vị trí nào?          | Đảm bảo workspace scope |

**Nếu chưa rõ → hỏi Sếp.**

---

## 9. Documentation Trigger

| Trigger                 | Hành động                 |
| ----------------------- | ------------------------- |
| Feature mới             | README.md, docs/          |
| Thay đổi cấu trúc       | ARCHITECTURE.md           |
| Thay đổi behavior       | docs/UPDATE-YYYY-MM-DD.md |
| Fix bug ảnh hưởng logic | CHANGELOG.md              |

---

## 10. Failure Handling

1. **Dừng** — không continue mù quáng
2. **Phân tích** — tìm nguyên nhân gốc
3. **Không patch** — vào branch cũ
4. **Branch mới** — nếu cần fix
5. **Báo cáo** — Sếp rõ ràng

---

## 11. Workspace Scope

### 11.1 Cho phép

| Vị trí               | Mục đích          |
| -------------------- | ----------------- |
| `src/`               | Source packages   |
| `conf/`              | PPA configuration |
| `memory/`            | Daily memory logs |
| `docs/`              | Documentation     |
| `.github/workflows/` | GitHub Actions    |

### 11.2 Cấm

- Không tạo file ngoài `/root/.openclaw/workspace/projects/ppa/`
- Không sửa core PPA files (trừ khi được yêu cầu)

---

## 12. Giao Tiếp

| Rule       | Mô tả               |
| ---------- | ------------------- |
| Ngôn ngữ   | Tiếng Việt có dấu   |
| Emoji      | Không sử dụng emoji |
| Phong cách | Ngắn gọn, trực tiếp |

---

**Workspace này không phải chỗ thử nghiệm.**  
Đây là hệ điều hành tư duy cho PPA Project.
