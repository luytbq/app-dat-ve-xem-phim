# Sổ đăng ký quy tắc nghiệp vụ - Hệ thống đặt vé xem phim CineBook (phần mới của UC-017)

| BR | Quy tắc | Loại | UC áp dụng | REQ | Cấp lần đầu tại | Trạng thái | Ghi chú |
|---|---|---|---|---|---|---|---|
| BR-95 | Email của mỗi tài khoản nhân viên là duy nhất giữa mọi tài khoản nhân viên. | Ràng buộc | UC-017 | REQ-102 (phụ) | P04 UC-017 | Hiệu lực | Theo Q-136 (email duy nhất). P13 đang đặt duy nhất theo từng bảng, cần duy nhất xuyên các bảng nhân viên (xem Đề xuất sửa artifact trước của UC-017) |
| BR-96 | Khi nhân viên nghỉ việc, tài khoản nhân viên bị khoá chứ không bị xoá; dữ liệu liên quan tới nhân viên (lần giữ ghế, vé đã bán) được giữ nguyên. | Kích hoạt hành động | UC-017 | REQ-70 (phụ) | P04 UC-017 | Hiệu lực | Theo Q-136 (nghỉ việc thì khoá, không xoá, vì lần giữ ghế và vé cũ còn trỏ tới nhân viên) |
| BR-97 | Nhân viên có tài khoản bị khoá không đăng nhập được vào hệ thống. | Ràng buộc | UC-017 | REQ-102 (phụ) | P04 UC-017 | Hiệu lực | Theo Q-136 (cột trạng thái hoạt động dùng cho đăng nhập và khoá tài khoản). Hiệu lực với phiên đang mở chờ Q-165 |
