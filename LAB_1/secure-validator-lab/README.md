# SecureValidator

Thư viện Python kiểm tra (validation) và làm sạch (sanitization) dữ liệu đầu vào,
kèm giao diện web Flask minh hoạ. Bài thực hành môn **Lập trình An ninh thông tin**.



## Tính năng

| Hàm | Mục đích |
|-----|----------|
| `validate_email(email)` | Kiểm tra định dạng email |
| `validate_url(url)` | Kiểm tra URL hợp lệ, chống SSRF cơ bản |
| `validate_filename(filename)` | Chặn path traversal |
| `sanitize_sql_input(input_str)` | Làm sạch dữ liệu chống SQL Injection |
| `sanitize_html_input(html_str)` | Mã hoá dữ liệu chống XSS |

## Cấu trúc thư mục

```
secure-validator-lab/
├── app.py                      # Ứng dụng web Flask
├── requirements.txt            # Thư viện phụ thuộc
├── securevalidator/
│   ├── __init__.py
│   └── core.py                 # 5 hàm chính của thư viện
├── templates/index.html        # Giao diện form nhập liệu
└── tests/
    ├── test_validators.py      # Unit test chức năng
    └── test_weaknesses.py      # Test minh hoạ điểm yếu
```

## Cài đặt và chạy

```bash
pip install -r requirements.txt
python app.py
```

Mở trình duyệt vào <http://127.0.0.1:5000/>.

## Chạy kiểm thử

```bash
python -m unittest discover tests
```

## Phân tích điểm mạnh & điểm yếu

### Điểm mạnh

- **Kiểm tra nhiều lớp đầu vào**: bao phủ 5 loại rủi ro phổ biến (email, URL,
  tên file, SQL, HTML) trong một thư viện thống nhất.
- **`sanitize_html_input` làm đúng chuẩn**: dùng `html.escape` của thư viện chuẩn
  để mã hoá `< > & " '`. Trong ngữ cảnh HTML thông thường, payload như
  `<script>` hay `<img onerror=...>` đều bị vô hiệu hoá — không tìm được bypass.
- **`validate_filename` chặn được path traversal cơ bản**: từ chối `..`, `/`, `\`
  nên `../../etc/passwd` bị loại.
- **Tách biệt rõ ràng**: logic bảo mật nằm gọn trong `securevalidator/`, dễ tái
  sử dụng và viết unit test độc lập.
- **Có bộ unit test** cho cả dữ liệu hợp lệ lẫn dữ liệu độc hại.

###  Điểm yếu (và cách khắc phục)

| Hàm | Điểm yếu | Input lọt qua (đã kiểm chứng) | Cách vá đúng |
|-----|----------|-------------------------------|--------------|
| `validate_url` | Chỉ kiểm tra `scheme` là http/https và có tên miền, **không kiểm tra IP đích** → vẫn dính SSRF | `http://127.0.0.1/admin`, `http://169.254.169.254/` | Phân giải hostname rồi chặn IP loopback/nội bộ/link-local; dùng whitelist domain |
| `sanitize_sql_input` | Dùng **blacklist** và thay thế **một lượt** → có thể lồng từ khoá để tái tạo | `OORR` → `OR`; `UNIUNIONON` → `UNION` | Không lọc chuỗi; dùng **parameterized query / prepared statement** |
| `validate_filename` | Chỉ chặn `..` `/` `\`, bỏ sót Alternate Data Stream (Windows) | `report.pdf:secret` được coi là hợp lệ | Whitelist ký tự cho phép (chữ, số, `. _ -`), chặn dấu `:` |
| `validate_email` | Regex quá lỏng, chỉ kiểm tra hình thức tối thiểu | `a@a.a` được coi là hợp lệ | Dùng thư viện chuyên dụng (vd `email-validator`) hoặc xác thực qua email thật |

### Nguyên tắc rút ra

- **Whitelist ưu tiên hơn blacklist**: các lỗ hở của `sanitize_sql_input` và
  `validate_filename` đều đến từ cách tiếp cận blacklist.
- **Chống SQL Injection đúng cách là dùng prepared statement**, không phải lọc chuỗi.
- **Validation phải theo đúng ngữ cảnh**: `html.escape` an toàn cho HTML body nhưng
  chưa chắc đủ cho ngữ cảnh thuộc tính HTML hoặc JavaScript.
