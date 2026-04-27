# Quy Trình Build Package

## Tổng Quan

Quy trình build package cho DiepXuan PPA gồm 3 giai đoạn chính:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         QUY TRÌNH BUILD PACKAGE                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────────────┐     ┌──────────────────────┐     ┌──────────────────────┐  │
│  │  GIAI ĐOẠN 1         │     │  GIAI ĐOẠN 2         │     │  GIAI ĐOẠN 3         │  │
│  │  Build & Test        │ ──▶ │  Publish             │ ──▶ │  Repository Update   │  │
│  └──────────────────────┘     └──────────────────────┘     └──────────────────────┘  │
│                                                                              │
│  package-repositories      debian-package-publish.yml          PPA Workflow   │
│  main.yml                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Giai Đoạn 1: Build & Test

### Trigger
Khi có thay đổi trong package (push hoặc PR vào branch chính)

### Workflow
```
src/diepxuan/package-repositories/.github/workflows/main.yml
```

### Mô Tả
- Checkout source code của package
- Setup GPG key để sign packages
- Setup SSH configuration
- Chạy script `src/build.sh` để build package
- Tạo các file `.deb`, `.dsc`, `.tar.gz`
- Di chuyển artifacts vào thư mục `dists/`

### Kết Quả
- Package source được build thành công
- Các file build artifacts trong thư mục `dists/`

---

## Giai Đoạn 2: Publish

### Trigger
Sau khi build test thành công (giai đoạn 1 hoàn tất)

### Workflow
```
src/github/.github/workflows/debian-package-publish.yml
```

### Mô Tả
- Cập nhật submodule của package lên commit mới nhất trong PPA repository
- Thao tác này đồng thời kích hoạt workflow chính của PPA

### Kết Quả
- Submodule package được cập nhật trong PPA repo
- Giai đoạn 3 được tự động kích hoạt

---

## Giai Đoạn 3: Repository Update

### Trigger
Submodule được cập nhật (từ giai đoạn 2)

### Workflow
```
src/github/.github/workflows/debian-package-ppa.yml
```

### Mô Tả
- Sử dụng Docker để build package trên nhiều OS khác nhau
- Build cho các distribution: Debian 10-13, Ubuntu 18.04-25.04
- Multi-architecture: amd64, arm64
- Thêm .deb files vào APT repository bằng reprepro
- Commit và push thay đổi lên PPA repository

### Các Bước Thực Hiện
1. **Setup Docker Buildx** - Cài đặt Docker Buildx để build multi-platform
2. **Setup QEMU** - Cài đặt QEMU để hỗ trợ multi-architecture
3. **Build trong Docker** - Chạy build script trong container với OS tương ứng
4. **Install dependencies** - Cài đặt build dependencies
5. **Add to APT** - Dùng reprepro để thêm .deb vào repository
6. **Push changes** - Commit và push lên PPA repository

### Distributions Được Build
- **Debian:** buster (10), bullseye (11), bookworm (12), trixie (13)
- **Ubuntu:** bionic (18.04), focal (20.04), jammy (22.04), noble (24.04), oracular (24.10), plucky (25.04)

### Architecture
- **amd64** (x86_64)
- **arm64** (aarch64)

### Kết Quả
- Package được thêm vào APT repository cho nhiều OS và architecture
- Người dùng có thể cài đặt package qua PPA

---

## Chi Tiết Kỹ Thuật

### Package Structure
```
src/diepxuan/
├── package-repositories/
│   ├── src/
│   │   ├── build.sh          # Build script
│   │   └── debian/           # Debian packaging files
│   │       ├── changelog
│   │       ├── control
│   │       ├── copyright
│   │       ├── rules
│   │       └── source/
│   └── .github/
│       └── workflows/
│           └── main.yml      # Giai đoạn 1
└── .github/
    └── workflows/
        └── main.yml          # Giai đoạn 3
```

### Distributions Hỗ Trợ

#### Debian
- buster (10)
- bullseye (11)
- bookworm (12)
- trixie (13)

#### Ubuntu
- bionic (18.04)
- focal (20.04)
- jammy (22.04)
- noble (24.04)
- oracular (24.10)
- plucky (25.04)

---

## Các File Quan Trọng

| File | Mô Tả |
|------|-------|
| `src/diepxuan/{package}/src/build.sh` | Script build chính |
| `src/diepxuan/{package}/src/debian/changelog` | Debian changelog |
| `src/diepxuan/{package}/src/debian/control` | Package control file |
| `src/diepxuan/{package}/src/debian/rules` | Build rules |
| `src/github/.github/workflows/debian-package-publish.yml` | Publish workflow |
| `.github/workflows/main.yml` | Main PPA workflow |