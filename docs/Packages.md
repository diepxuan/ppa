# Packages - Danh sách Packages trong DiepXuan PPA

## Tổng quan

DiepXuan PPA cung cấp các packages cho Debian và Ubuntu, bao gồm:
- **PHP Extensions** - Các extension PHP từ PECL
- **Management Tools** - Công cụ quản trị hệ thống
- **Repository Setup** - Package cấu hình repository

## Cấu trúc Repository

### Repo gốc

**Repository:** `diepxuan/php-ext`
**URL:** https://github.com/diepxuan/php-ext
**Mô tả:** Build system thống nhất cho PHP PECL extensions
**Vai trò:** Repo gốc chứa build system và cấu trúc chung

### Repositories Clone

**Repositories:** `diepxuan/php-*`
**Mô tả:** Repositories clone dùng để build package php-*
**Vai trò:** Mỗi repository clone build một package PHP extension cụ thể

## Danh sách Packages

### 1. PHP Extensions

#### 1.1 php-sqlsrv

**Package:** `php-sqlsrv`
**Repository:** `diepxuan/php-sqlsrv`
**URL:** https://github.com/diepxuan/php-sqlsrv
**Submodule path:** `src/diepxuan/php-sqlsrv`
**PECL:** [sqlsrv](https://pecl.php.net/package/sqlsrv)
**PHP:** 8.1+
**Mô tả:** Microsoft Drivers for PHP for SQL Server (SQLSRV)

**Dependencies:**
- **Build:** unixodbc-dev, unixodbc, msodbcsql18, php-dev
- **Runtime:** msodbcsql18

**Distributions:**
- Debian: 10 (Buster), 11 (Bullseye), 12 (Bookworm)
- Ubuntu: 18.04 (Bionic), 20.04 (Focal), 22.04 (Jammy), 24.04 (Noble), 24.10 (Oracular), 25.04 (Plucky)

**Workflow:** `.github/workflows/php-sqlsrv.yml`

#### 1.2 php-pdo_sqlsrv

**Package:** `php-pdo_sqlsrv`
**Repository:** `diepxuan/php-pdo_sqlsrv`
**URL:** https://github.com/diepxuan/php-pdo_sqlsrv
**Submodule path:** `src/diepxuan/php-pdo_sqlsrv`
**PECL:** [pdo_sqlsrv](https://pecl.php.net/package/pdo_sqlsrv)
**PHP:** 8.1+
**Mô tả:** Microsoft Drivers for PHP for SQL Server (PDO_SQLSRV)

**Dependencies:**
- **Build:** unixodbc-dev, unixodbc, msodbcsql18, php-dev
- **Runtime:** msodbcsql18

**Distributions:**
- Debian: 10 (Buster), 11 (Bullseye), 12 (Bookworm)
- Ubuntu: 18.04 (Bionic), 20.04 (Focal), 22.04 (Jammy), 24.04 (Noble), 24.10 (Oracular), 25.04 (Plucky)

**Workflow:** `.github/workflows/php-pdo_sqlsrv.yml`

#### 1.3 php-runkit7

**Package:** `php-runkit7`
**Repository:** `diepxuan/php-runkit7`
**URL:** https://github.com/diepxuan/php-runkit7
**Submodule path:** `src/diepxuan/php-runkit7`
**PECL:** [runkit7](https://pecl.php.net/package/runkit7)
**PHP:** 7.2+
**Mô tả:** PHP runkit7 extension

**Module thay thế:** `runkit7` (tích hợp vào diepxuan/php-runkit7)
**Module gốc:** `runkit7/runkit7`
**Repository gốc:** https://github.com/diepxuan/runkit7
**Submodule path:** `src/runkit7`

**Dependencies:**
- **Build:** php-dev
- **Runtime:** (none)

**Distributions:**
- Debian: 10 (Buster), 11 (Bullseye), 12 (Bookworm)
- Ubuntu: 18.04 (Bionic), 20.04 (Focal), 22.04 (Jammy), 24.04 (Noble), 24.10 (Oracular), 25.04 (Plucky)

**Workflow:** `.github/workflows/php-runkit7.yml`

### 2. Management Tools

#### 2.1 management

**Package:** `management`
**Repository:** `diepxuan/management`
**URL:** https://github.com/diepxuan/management
**Submodule path:** `src/diepxuan/management`
**Mô tả:** Công cụ quản trị hệ thống

**Distributions:**
- Debian: 10 (Buster), 11 (Bullseye), 12 (Bookworm)
- Ubuntu: 18.04 (Bionic), 20.04 (Focal), 22.04 (Jammy), 24.04 (Noble), 24.10 (Oracular), 25.04 (Plucky)

**Workflow:** `.github/workflows/management.yml`

### 3. Repository Setup

#### 3.1 diepxuan-repositories

**Package:** `diepxuan-repositories`
**Repository:** `diepxuan/package-repositories`
**URL:** https://github.com/diepxuan/package-repositories
**Submodule path:** `src/diepxuan/repositories`
**Mô tả:** Package dùng để init apt source cho PPA và cho Microsoft

**Chức năng:**
- Thiết lập Microsoft APT repository
- Import Microsoft GPG key
- Thêm Microsoft APT source list
- Cho phép cài đặt msodbcsql18 và unixodbc-dev

**Dependencies:**
- curl
- gnupg
- lsb-release
- apt-transport-https

**Files được cài đặt:**
- `/usr/share/keyrings/microsoft-prod.gpg` - Microsoft GPG key
- `/etc/apt/sources.list.d/microsoft-prod.list` - Microsoft APT repository

**Distributions:**
- Debian: 10 (Buster), 11 (Bullseye), 12 (Bookworm), 13 (Trixie)
- Ubuntu: 18.04 (Bionic), 20.04 (Focal), 22.04 (Jammy), 24.04 (Noble), 24.10 (Oracular), 25.04 (Plucky)

**Workflow:** (chưa có workflow riêng)

## GitHub Actions Workflows

### Workflow chung

**File:** `diepxuan/.github/.github/workflows/debian-package-ppa.yml`
**Mô tả:** Workflow chung để build và publish packages lên PPA
**Vai trò:** Workflow này được sử dụng bởi tất cả các packages

### Workflows cụ thể

#### php-runkit7 Build

**File:** `.github/workflows/php-runkit7.yml`
**Trigger:**
- Push vào branch main với thay đổi trong `src/diepxuan/php-runkit7/**`
- Pull request vào branch main với thay đổi trong `src/diepxuan/php-runkit7/**`
- Manual trigger từ Actions tab

**Jobs:**
- `module-build`: Build package php-runkit7

**Secrets:**
- `GPG_KEY` - GPG key để ký package
- `GPG_KEY_ID` - GPG key ID
- `GIT_COMMITTER_EMAIL` - Email committer
- `SSH_ID_RSA` - SSH key để publish

#### php-sqlsrv Build

**File:** `.github/workflows/php-sqlsrv.yml`
**Trigger:**
- Push vào branch main với thay đổi trong `src/diepxuan/php-sqlsrv/**`
- Pull request vào branch main với thay đổi trong `src/diepxuan/php-sqlsrv/**`
- Manual trigger từ Actions tab

**Jobs:**
- `module-build`: Build package php-sqlsrv

**Secrets:**
- `GPG_KEY` - GPG key để ký package
- `GPG_KEY_ID` - GPG key ID
- `GIT_COMMITTER_EMAIL` - Email committer
- `SSH_ID_RSA` - SSH key để publish

#### php-pdo_sqlsrv Build

**File:** `.github/workflows/php-pdo_sqlsrv.yml`
**Trigger:**
- Push vào branch main với thay đổi trong `src/diepxuan/php-pdo_sqlsrv/**`
- Pull request vào branch main với thay đổi trong `src/diepxuan/php-pdo_sqlsrv/**`
- Manual trigger từ Actions tab

**Jobs:**
- `module-build`: Build package php-pdo_sqlsrv

**Secrets:**
- `GPG_KEY` - GPG key để ký package
- `GPG_KEY_ID` - GPG key ID
- `GIT_COMMITTER_EMAIL` - Email committer
- `SSH_ID_RSA` - SSH key để publish

#### management Build

**File:** `.github/workflows/management.yml`
**Trigger:**
- Push vào branch main với thay đổi trong `src/diepxuan/management/**`
- Pull request vào branch main với thay đổi trong `src/diepxuan/management/**`
- Manual trigger từ Actions tab

**Jobs:**
- `module-build`: Build package management

**Secrets:**
- `GPG_KEY` - GPG key để ký package
- `GPG_KEY_ID` - GPG key ID
- `GIT_COMMITTER_EMAIL` - Email committer
- `SSH_ID_RSA` - SSH key để publish

#### GPG Setup

**File:** `.github/workflows/gpgsetup.yml`
**Mô tả:** Setup GPG key cho build process
**Vai trò:** Workflow này được sử dụng bởi workflow chung

## Quy trình Build

### 1. Trigger Workflow

Workflow được trigger khi:
- Push code vào branch main
- Tạo pull request vào branch main
- Manual trigger từ Actions tab

### 2. Build Package

Workflow chung `debian-package-ppa.yml` thực hiện:
1. Checkout repository
2. Setup GPG key
3. Setup SSH key
4. Cài đặt build dependencies
5. Download source từ PECL/GitHub
6. Build package Debian
7. Test installation
8. Publish lên Launchpad PPA

### 3. Publish Package

Package được publish lên:
- **Launchpad PPA:** caothu91ppa
- **DiepXuan PPA:** https://ppa.diepxuan.com

### 4. Sync Repositories

Sync hai chiều giữa php-ext và các repo con:
- **php-ext update → push sang php-runkit7, php-sqlsrv, php-pdo_sqlsrv**
- **php-runkit7/php-sqlsrv/php-pdo_sqlsrv update → merge về php-ext**

## Cài đặt Packages

### Thêm PPA

```bash
# Thêm DiepXuan PPA
echo "deb [signed-by=/usr/share/keyrings/diepxuan.gpg] \
https://ppa.diepxuan.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/diepxuan.list

# Import GPG key
curl -fsSL https://ppa.diepxuan.com/key.gpg | \
sudo gpg --dearmor -o /usr/share/keyrings/diepxuan.gpg

# Cập nhật danh sách package
sudo apt update
```

### Cài đặt Packages

```bash
# Cài đặt diepxuan-repositories
sudo apt install diepxuan-repositories

# Cài đặt PHP extensions
sudo apt install php-sqlsrv php-pdo-sqlsrv php-runkit7

# Cài đặt management tools
sudo apt install management
```

## Submodules

### Danh sách Submodules

| Submodule | Path | URL | Mô tả |
|----------|------|-----|-------|
| management | src/diepxuan/management | https://github.com/diepxuan/management.git | Công cụ quản trị |
| github | src/github | https://github.com/diepxuan/.github.git | GitHub Actions |
| repositories | src/diepxuan/repositories | git@github.com:diepxuan/package-repositories.git | Package repositories |
| runkit7 | src/runkit7 | https://github.com/diepxuan/runkit7.git | Runkit7 module gốc |
| php-runkit7 | src/diepxuan/php-runkit7 | https://github.com/diepxuan/php-runkit7.git | PHP runkit7 package |
| php-sqlsrv | src/diepxuan/php-sqlsrv | https://github.com/diepxuan/php-sqlsrv.git | PHP sqlsrv package |
| php-pdo_sqlsrv | src/diepxuan/php-pdo_sqlsrv | https://github.com/diepxuan/php-pdo_sqlsrv.git | PHP pdo_sqlsrv package |
| php-ext | src/php-ext | https://github.com/diepxuan/php-ext.git | PHP extensions repo gốc |

## Build System

### Build Script

**File:** `src/diepxuan/build.sh`
**Mô tả:** Script build chung cho tất cả packages
**Environment variables:**
- `repository` - Xác định module (e.g., `diepxuan/php-sqlsrv`)
- `GPG_KEY` - GPG key để ký package
- `GPG_KEY_ID` - GPG key ID

### Build Process

```bash
cd src/
bash build.sh
```

**Steps:**
1. Cài đặt build dependencies
2. Setup GPG key
3. Download source từ PECL/GitHub
4. Build package Debian
5. Test installation
6. Publish lên Launchpad PPA

## Distributions Hỗ trợ

### Debian

| Phiên bản | Codename | Hỗ trợ |
|-----------|----------|---------|
| 10 | Buster | Có |
| 11 | Bullseye | Có |
| 12 | Bookworm | Có |
| 13 | Trixie | Có |

### Ubuntu

| Phiên bản | Codename | Hỗ trợ |
|-----------|----------|---------|
| 18.04 | Bionic | Có |
| 20.04 | Focal | Có |
| 22.04 | Jammy | Có |
| 24.04 | Noble | Có |
| 24.10 | Oracular | Có |
| 25.04 | Plucky | Có |

## Liên kết

- **GitHub:** https://github.com/diepxuan/ppa
- **PPA:** https://ppa.diepxuan.com
- **Launchpad:** https://launchpad.net/~caothu91/+archive/ubuntu/ppa
- **Documentation:** https://docs.diepxuan.com

## Bảo trì

### Người bảo trì

- **Trần Ngọc Đức** <ductn@diepxuan.com>
- **DiepXuan Co., Ltd**

### License

- **PHP Extensions:** PHP License
- **Management Tools:** MIT License
- **Repository Setup:** MIT License

## Cập nhật

### Phiên bản hiện tại

- **php-sqlsrv:** 5.12.0
- **php-pdo_sqlsrv:** 5.12.0
- **php-runkit7:** 4.0.0
- **management:** 1.0.0
- **diepxuan-repositories:** 1.0.0

### Cập nhật gần nhất

- **2026-04-26:** Cập nhật tài liệu sang tiếng Việt
- **2026-04-25:** Thêm diepxuan-repositories package
- **2026-04-22:** Khởi tạo PPA
