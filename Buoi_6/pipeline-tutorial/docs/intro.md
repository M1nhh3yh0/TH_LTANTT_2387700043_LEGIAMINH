---
sidebar_position: 1
---

# Giới thiệu

Đây là trang tài liệu **Docusaurus** được dùng trong **Bài 6 - Bảo mật với DevSecOps**,
phần **6.2.2 - Tạo pipeline CI/CD phức tạp** triển khai tự động lên **GitLab Pages**.

- **Sinh viên:** Lê Gia Minh
- **MSSV:** 2387700043
- **Lớp:** 23DATA1

## Mục tiêu

Trang web này được **build tự động** bởi pipeline GitLab CI/CD (`.gitlab-ci.yml`) qua 2 stage:

1. **build** — job `build-job` chạy `npm install` và `npm run build`, lưu thư mục
   `build/` dưới dạng *artifacts*.
2. **deploy** — job `pages` chuyển `build/` sang `public/` để **GitLab Pages**
   phục vụ trang công khai tại `https://legiaminh.gitlab.io/pipeline-tutorial/`.

## Luồng CI/CD

```
Commit code  ─►  Runner kéo image node  ─►  npm install + npm run build
      │                                             │
      │                                     artifacts: build/
      ▼                                             ▼
  GitLab Pages  ◄── job `pages`: mv build/ public/ ◄─┘
```

Khi mọi stage **passed**, trang web mới được xuất bản tự động — đúng tinh thần
**Continuous Deployment** của DevSecOps.
