# BOOTSTRAP.md - Reference Index

File này là **chỉ mục tham chiếu** cho session startup. Nội dung boot
sequence thực tế nằm ở các file được liệt kê dưới đây — BOOTSTRAP.md
không lặp lại, chỉ chỉ ra "đọc gì, ở đâu".

Theo OpenClaw docs (`concepts/agent-workspace.md`), `BOOTSTRAP.md` vốn
dành cho first-run ritual và nên xóa sau khi hoàn tất. Trong workspace
PPA, file này được giữ lại như một routing helper, không phải nguồn
truth cho protocol.

---

## 1. Đọc gì khi khởi động

| Thứ tự | File | Vai trò | Bắt buộc? |
|--------|------|---------|-----------|
| 1 | `AGENTS.md` | Protocol gốc, instruction precedence, git discipline | Có |
| 2 | `SOUL.md` | Bản sắc, giọng nói, nguyên tắc cao nhất | Có |
| 3 | `IDENTITY.md` | Vai trò PPA Bot trong hệ thống OpenClaw | Có |
| 4 | `USER.md` | Đối tượng phục vụ, working style | Có |
| 5 | `TOOLS.md` | Đường dẫn OpenClaw, hạ tầng PPA, build tools | Khi task liên quan tool/build |
| 6 | `memory/YYYY-MM-DD.md` | Daily memory hôm nay và hôm qua | Nếu tồn tại |
| 7 | `MEMORY.md` | Long-term memory | Nếu MAIN SESSION và tồn tại |

**Ghi chú Codex:** `AGENTS.md` là file project instructions mặc định
mà Codex đã nạp. Các file còn lại là context bổ sung — BOOTSTRAP.md
chỉ định thứ tự, không thay thế AGENTS.md.

Nếu file memory chưa tồn tại: báo cáo ngắn rồi tiếp tục. Không tự tạo
file trống để thỏa mãn startup sequence.

---

## 2. Checklist trước khi hành động

Chi tiết ở `AGENTS.md` §2 (Boot Sequence) và §6 (Git Discipline).
Tóm tắt nhanh:

- Task đã rõ chưa? — Nếu chưa, hỏi Sếp.
- Có liên quan Git không? — Xem AGENTS.md §6.
- Có cần spawn đệ không? — Xem AGENTS.md §8.
- Có cần update documentation không? — Xem AGENTS.md §10 (Documentation Trigger) hoặc mục 4 dưới.
- File sẽ tạo ở đâu? — Trong workspace, không lan ra ngoài.

---

## 3. Quy tắc an toàn khi thi hành

Chi tiết ở `AGENTS.md` §6 (Git Discipline) và IDENTITY.md §4
(Quan hệ quyền hạn). Tóm tắt:

- Không bỏ qua boot sequence.
- Không tự ý push, tạo PR, sửa PR cũ.
- 1 task = 1 branch = 1 PR.
- Không hành động khi chưa hiểu đủ hệ thống.
- Khi nghi ngờ → hỏi Sếp trước khi làm.

---

## 4. Trigger cập nhật tài liệu

Phải tạo hoặc cập nhật tài liệu khi có một trong các trigger sau:

- Feature mới.
- Thay đổi cấu trúc hoặc behavior.
- Fix bug ảnh hưởng logic.

Nội dung và vị trí cập nhật xem tài liệu con tương ứng
(`README.md`, `docs/`, `CHANGELOG.md`).

---

## 5. Xử lý khi gặp lỗi

Chi tiết ở `AGENTS.md` §11 (Failure Handling). Quy trình:

1. Dừng.
2. Phân tích nguyên nhân.
3. Không patch trực tiếp vào branch cũ.
4. Tạo branch mới nếu cần fix.
5. Báo cáo Sếp rõ ràng.

---

**BOOTSTRAP.md là chỉ mục, không phải nguồn truth.**
Mọi thay đổi protocol phải sửa ở file được tham chiếu (AGENTS.md,
SOUL.md, IDENTITY.md, USER.md, TOOLS.md), không sửa ở đây.