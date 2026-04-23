# runkit7 - DiepXuan Fork

## Tổng Quan

runkit7 là PHP extension cho phép manipulate functions, methods, classes, constants, properties lúc runtime.

**Fork:** [diepxuan/runkit7](https://github.com/diepxuan/runkit7)
**Upstream:** [runkit7/runkit7](https://github.com/runkit7/runkit7)

## Tài Liệu

- [Fork Plan](../src/diepxuan/runkit7/runkit7-fork-plan.md) - Chi tiết phương án fork, timeline, maintenance

## PHP Versions

- Supported: 7.2, 7.3, 7.4, 8.0, 8.1, 8.2, 8.3, 8.4, 8.5
- PHP 8.4+ requires fork (upstream PR #276 not merged)

## Installation

```bash
# From PPA
echo "deb https://ppa.diepxuan.com <codename> main" | sudo tee /etc/apt/sources.list.d/diepxuan.list
sudo apt update
sudo apt install php-runkit7
```

## Status

- **Fork:** Active
- **PHP 8.4:** Patched (PR #1)
- **Upstream sync:** Monthly review
