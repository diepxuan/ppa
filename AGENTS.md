# AGENTS.md - PPA Workspace Protocol

File này là protocol entrypoint của workspace PPA.

Codex tự động đọc `AGENTS.md` trước khi làm việc. Các agent khác dùng chung
workspace này cũng phải xem `AGENTS.md` là tài liệu gốc, rồi đọc các file tham
chiếu bên dưới để lấy đủ bối cảnh.

---

## 1. Codex Compatibility

| Lớp | File | Vai trò |
|-----|------|---------|
| Codex protocol | `AGENTS.md` | Entry point mặc định của Codex và workspace |
| Identity | `SOUL.md` | Bản sắc, giọng nói, nguyên tắc cao nhất trong workspace |
| Role | `IDENTITY.md` | Vai trò PPA Bot trong hệ thống OpenClaw |
| User | `USER.md` | Thông tin và cách phục vụ Sếp |
| Startup index | `BOOTSTRAP.md` | Chỉ mục tham chiếu — không lặp nội dung protocol |
| Local notes | `TOOLS.md` | Đường dẫn, hạ tầng, tool notes |
| Memory | `MEMORY.md`, `memory/YYYY-MM-DD.md` | Ngữ cảnh dài hạn và hằng ngày nếu tồn tại |

Nguyên tắc:

- Không đổi tên `AGENTS.md`; đây là tên mặc định Codex dùng để lấy project instructions.
- Không nhồi toàn bộ context vào `AGENTS.md`; giữ file này là router/protocol ngắn gọn.
- Các file tham chiếu còn lại là nguồn context bắt buộc theo workspace, dù không phải file mặc định của Codex.
- Cấu hình Codex thuộc `.codex/config.toml` hoặc `~/.codex/config.toml`, không đặt lẫn vào protocol nếu không cần.

---

## 2. Boot Sequence

Mỗi session phải:

1. Xác nhận `AGENTS.md` đã được nạp làm protocol gốc.
2. Đọc `SOUL.md` — bản sắc và giọng nói (cao nhất cho voice).
3. Đọc `IDENTITY.md` — vai trò trong hệ thống OpenClaw.
4. Đọc `USER.md` — đối tượng phục vụ, working style.
5. Đọc `TOOLS.md` nếu task liên quan đường dẫn, hạ tầng, build hoặc tool.
6. Đọc memory hôm nay và hôm qua nếu tồn tại: `memory/YYYY-MM-DD.md`.
7. Nếu MAIN SESSION và `MEMORY.md` tồn tại: đọc `MEMORY.md`.

Lưu ý về OpenClaw docs: `BOOTSTRAP.md` vốn là first-run ritual và nên xóa
sau khi hoàn tất. Workspace PPA không dùng `BOOTSTRAP.md` (đã gộp routing
vào §2 và §3 tại đây).

Nếu file memory chưa tồn tại, báo cáo ngắn gọn rồi tiếp tục. Không tự tạo memory
chỉ để hoàn tất boot sequence, trừ khi Sếp yêu cầu hoặc task cần ghi nhớ context.

---

## 3. Instruction Precedence

Thứ tự xử lý trong workspace này (theo OpenClaw prompt assembly):

1. System/developer instructions của runtime OpenClaw.
2. `SOUL.md` — voice, persona, ngôn ngữ (inject trong Project Context).
3. `AGENTS.md` — protocol vận hành workspace (inject trong Project Context).
4. Các file tham chiếu còn lại: `IDENTITY.md`, `USER.md`, `TOOLS.md`.
5. Memory files (`MEMORY.md`, `memory/YYYY-MM-DD.md`) nếu session đọc tới.
6. Yêu cầu trực tiếp mới nhất của Sếp (user turn cuối cùng).

**Lưu ý:** OpenClaw inject các bootstrap file đồng đẳng trong Project Context, không có internal precedence tự đặt giữa các file workspace. Nếu `SOUL.md` và `AGENTS.md` mâu thuẫn, runtime ưu tiên theo thứ tự liệt kê ở trên chứ không tự phân xử. Quy tắc này do em tự đặt để hành vi dễ đoán, không phải cơ chế runtime.

---

## 4. Session Types

| Loại | Key | Quyền hạn |
|------|-----|-----------|
| MAIN SESSION | `agent:ppa:main` | Cập nhật `MEMORY.md`, quyết định chiến lược |
| Session thường | `agent:ppa:<channel>:<scope>` | Ghi `memory/YYYY-MM-DD.md`, thực thi task |

- MAIN SESSION chạy trong channel trực tiếp với Sếp (webchat/Telegram DM...).
- Session thường phục vụ task cụ thể, không ghi đè `MEMORY.md`.

---

## 5. Memory Structure

| File | Mục đích |
|------|----------|
| `MEMORY.md` | Long-term: quyết định, sở thích, chiến lược |
| `memory/YYYY-MM-DD.md` | Daily: context và observations |

---

## 6. Git Discipline

### 6.1 Nguyên tắc

- 1 task = 1 branch mới.
- 1 set thay đổi = 1 PR mới.
- Luôn commit cho mọi thay đổi.
- Không làm việc trực tiếp trên `main`.

### 6.2 Cấm tuyệt đối

- Không force push `main`.
- Không reset `main` về commit cũ.
- Không chỉnh sửa lịch sử `main`.
- Không làm sạch, revert, reset hoặc ghi đè thay đổi đang có nếu chưa được Sếp yêu cầu.

### 6.3 Commit Convention

```
<type>: <description>

Ví dụ:
- feat: add new package
- fix: fix build error
- docs: update documentation
- chore: maintenance tasks
- refactor: code refactoring
```

### 6.4 Branch Naming

```
<type>/<short-description>

Ví dụ:
- feat/add-php-sqlsrv
- fix/gpg-signing-issue
- chore/update-docs
```

**Chỉ push khi Sếp nói:** "Em tạo PR đi".

### 6.5 Multi-agent safety

Vì nhiều AI agent dùng chung workspace, luôn chạy `git status` trước khi sửa file.

---

## 7. External vs Internal Actions

### 7.1 Safe (làm không cần hỏi)

- Đọc file, explore codebase.
- Search web, check documentation.
- Organize workspace, refactor nội bộ.
- Update documentation.
- Commit changes (local).
- Tạo branch mới.

### 7.2 Hỏi Sếp trước

- Push lên remote, tạo PR, merge / revert / close PR.
- Gửi email, tweet, public posts.
- Chạy destructive commands (`rm`, `drop`, `delete`).
- Thay đổi workflow nền tảng (CI, systemd, nginx, crontab, shell rc).

### 7.3 Cấm chạm remote

- Không tự ý push, tạo PR, merge, revert, close.
- Không chỉnh sửa lịch sử branch shared (force push, reset).

**Rule:** Khi nghi ngờ → hỏi Sếp trước khi làm.

---

## 8. Sub-Agents

- Gọi là **đệ**.
- Mô tả rõ: mục tiêu, input, output, giới hạn quyền.
- Đệ không được vượt quyền PPA Bot.
- Giám sát: không để đệ tự quyết định vượt thẩm quyền.

---

## 9. Workspace Scope

### 9.1 Cho phép

| Vị trí | Mục đích |
|--------|---------|
| `src/` | Source packages |
| `conf/` | PPA configuration |
| `memory/` | Daily memory logs (chỉ đọc, không bắt buộc tạo) |
| `docs/` | Documentation |
| `README.md` | Project overview |
| `.github/workflows/` | GitHub Actions |

### 9.2 Cấm

- Không tạo file ngoài `/root/.openclaw/workspace/projects/ppa/`.
- Không sửa core PPA files (trừ khi được yêu cầu).
- Không commit secret (private key, token, password) dù workspace là private repo.

---

## 10. Documentation Trigger

Phải tạo hoặc cập nhật tài liệu khi:

- Feature mới → `README.md`, `docs/`.
- Thay đổi cấu trúc → `ARCHITECTURE.md` (nếu có) hoặc `docs/`.
- Thay đổi behavior → `docs/UPDATE-YYYY-MM-DD.md` hoặc `CHANGELOG.md`.
- Fix bug ảnh hưởng logic → `CHANGELOG.md`.

Chi tiết build/release → `TOOLS.md` §5.

---

## 11. Failure Handling

1. **Dừng** — không continue mù quáng.
2. **Phân tích** — tìm nguyên nhân gốc.
3. **Không patch** trực tiếp vào branch cũ.
4. **Tạo branch mới** nếu cần fix.
5. **Báo cáo** Sếp rõ ràng.

---

## 12. Shared Workspace Rules

- Không xóa hoặc rút gọn protocol files nếu chưa được Sếp yêu cầu rõ.
- Khi cập nhật protocol, giữ `AGENTS.md` là entrypoint và dùng ref đến file con.
- Thay đổi protocol phải nêu rõ tác động đến Codex và các AI agent khác.
- Không tự ý đổi cấu trúc memory hoặc Codex config.

---

Không bỏ qua boot sequence. Không hành động khi chưa nắm đủ context.
