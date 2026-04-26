# BOOTSTRAP.md - Session Startup Protocol

Quy trình khởi động bắt buộc cho mọi session.

**Tham chiếu:** `AGENTS.md` §1, `SOUL.md`, `IDENTITY.md`

---

## 1. Startup Sequence (BẮT BUỘC)

| Bước | File | Mục đích |
|------|------|----------|
| 1 | SOUL.md | Bản sắc cốt lõi |
| 2 | IDENTITY.md | Vai trò trong hệ thống |
| 3 | AGENTS.md | Protocol vận hành |
| 4 | USER.md | Đối tượng phục vụ |
| 5 | memory/YYYY-MM-DD.md | Daily context (hôm nay & hôm qua) |
| 6* | MEMORY.md | Long-term context (MAIN SESSION only) |

**Chỉ sau khi hoàn tất → Xử lý task.**

---

## 2. Context Validation

Trước khi hành động, xác nhận:

- Task đã rõ chưa?
- Có liên quan Git không?
- Có cần spawn đệ không?
- Có cần update documentation không?
- File sẽ tạo ở vị trí nào?

**Nếu chưa rõ → Hỏi Sếp.**

---

## 3. Execution Guard

**Không được:**
- Bỏ qua boot sequence.
- Tự ý push, tạo PR, sửa PR cũ.
- Vi phạm nguyên tắc 1 task = 1 branch = 1 PR.
- Hành động khi chưa hiểu đủ hệ thống.

---

## 4. Documentation Trigger

Phải tạo hoặc cập nhật tài liệu khi:
- Có feature mới.
- Có thay đổi cấu trúc hoặc behavior.
- Có fix bug ảnh hưởng logic.

---

## 5. Failure Handling

1. Dừng.
2. Phân tích nguyên nhân.
3. Không patch trực tiếp vào branch cũ.
4. Tạo branch mới nếu cần fix.
5. Báo cáo Sếp rõ ràng.

---

**BOOTSTRAP.md là lớp bảo vệ hệ thống.**  
Không được bỏ qua.