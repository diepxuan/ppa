# Maintainer Notes

Tài liệu này dành cho maintainer của DiepXuan PPA khi cập nhật installer, README và tài liệu liên quan.

## 1. Nguyên tắc tài liệu

README nên thân thiện, ngắn gọn và tập trung vào người dùng cuối:

- Repository dùng để làm gì.
- Cài đặt nhanh như thế nào.
- Key GPG chính xác là gì.
- Khi lỗi phổ biến thì xử lý ra sao.
- Link sang tài liệu chi tiết thay vì nhồi toàn bộ nội dung vào README.

Các hướng dẫn dài nên tách sang `docs/`:

- `docs/INSTALL.md`: cài đặt, kiểm tra, gỡ cấu hình.
- `docs/TROUBLESHOOTING.md`: lỗi thường gặp và cách debug.
- `docs/MAINTAINER.md`: checklist cho maintainer.

## 2. Checklist khi sửa `install.sh`

Trước khi commit thay đổi installer, chạy tối thiểu:

```bash
bash -n install.sh
```

Kiểm tra help output:

```bash
./install.sh --help
```

Kiểm tra key public:

```bash
curl -fsSL https://ppa.diepxuan.com/key.gpg | gpg --show-keys --with-colons --fingerprint | awk -F: '$1 == "fpr" {print $10; exit}'
```

Kỳ vọng:

```text
C8BD5D6C638E8A11938929267E0EC917A5074BD3
```

## 3. Checklist khi sửa GPG key logic

Phải đảm bảo installer:

1. Tải key từ nguồn chính thức.
2. Kiểm tra fingerprint key tải về.
3. Không tin keyring local chỉ vì file tồn tại.
4. Refresh keyring nếu fingerprint sai hoặc thiếu.
5. Dùng `signed-by=/usr/share/keyrings/diepxuan.gpg` trong source list.
6. Báo lỗi rõ nếu fingerprint không khớp.

## 4. Test giả lập an toàn

Không cần ghi vào `/usr/share/keyrings` thật khi test. Có thể override path:

```bash
TMPDIR=.tmp/install-test
mkdir -p "$TMPDIR/bin" "$TMPDIR/root"

printf '%s\n' '#!/usr/bin/env bash' 'echo "fake apt-get $*"' > "$TMPDIR/bin/apt-get"
chmod +x "$TMPDIR/bin/apt-get"

KEYRING_PATH="$PWD/$TMPDIR/root/diepxuan.gpg" \
SOURCES_LIST_PATH="$PWD/$TMPDIR/root/diepxuan.list" \
CODENAME=bookworm \
PATH="$PWD/$TMPDIR/bin:$PATH" \
./install.sh --repository-only
```

Sau đó kiểm tra fingerprint keyring test:

```bash
gpg --show-keys --with-colons --fingerprint "$TMPDIR/root/diepxuan.gpg" | awk -F: '$1 == "fpr" {print $10; exit}'
```

## 5. Checklist PR

Trước khi tạo PR:

```bash
git diff --check
bash -n install.sh
./install.sh --help
```

Nếu thay đổi behavior người dùng:

- Cập nhật `README.md`.
- Cập nhật `docs/INSTALL.md` nếu liên quan cài đặt.
- Cập nhật `docs/TROUBLESHOOTING.md` nếu liên quan lỗi/debug.

## 6. Lưu ý về Git workflow

- Mỗi task dùng branch riêng.
- Commit rõ ràng theo conventional commits.
- Không push, tạo PR, merge nếu chưa có lệnh rõ ràng từ Sếp.
- Không đưa thay đổi submodule không liên quan vào PR tài liệu.
