# P02R - Review use case - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P02R |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md; P00-problem-brief.md 1.3; P01-actors.md 1.1; P02-usecases.md 1.1; yeu-cau-dat-ve.md |
| Phạm vi | TAC_NHAN, DANH_SACH_UC |
| Mã Q, ASM cuối đã cấp | Q-23; không có ASM (NGHIEM_NGAT) |

## 1. Tóm tắt

- Đối tượng review: 8 tác nhân của P01-actors.md 1.1 và 17 mã use case của P02-usecases.md 1.1 (16 use case đang dùng, UC-002 ở trạng thái Loại). Có tài liệu nguồn (yeu-cau-dat-ve.md, P00-problem-brief.md 1.3). Quy ước đã theo: đăng nhập không là use case (U-R01).
- Số phát hiện: Nghiêm trọng 0, Trung bình 1, Thấp 1.
- Kết luận: Đạt.
- Điểm làm tốt:
  - UC-005 Đặt vé gom đúng cả luồng khách trực tuyến và nhân viên quầy theo U-R10 b, nên cơ chế giữ ghế dùng chung chỉ xuất hiện ở một use case.
  - UC-006 Hoàn tiền thanh toán trễ tách đúng theo U-R08: kết quả giao dịch đến khi phiên đặt vé đã kết thúc là mục tiêu riêng của ACT-07 Cổng thanh toán.
  - Các trường hợp hết hạn giữ ghế, khách huỷ giữ ghế, thanh toán thất bại được giữ là luồng thay thế của UC-005 (U-R07 hết giờ trong phiên), không sinh tác nhân thời gian hay use case vụn.

## 2. Bảng kiểm kê

Không có mã tạm, dùng mã gốc: 8 tác nhân, 17 mã use case (16 đang dùng, 1 Loại), 0 quan hệ (chưa có sơ đồ).

## 3. Bảng phát hiện

| Mã | Phần tử | Vấn đề | Quy tắc vi phạm | Mức độ (Nghiêm trọng / Trung bình / Thấp) | Đề xuất sửa |
|---|---|---|---|---|---|
| UCR-01 | UC-005 Đặt vé; dòng REQ-12 của Mục 5 | Mục 5 ghi REQ-12 "Tiền điều kiện của UC-005, UC-007, UC-008". Với khách, đăng nhập không phải tiền điều kiện của UC-005: khách xem sơ đồ ghế không cần đăng nhập và chỉ phải đăng nhập trước khi xác nhận chọn ghế ("Khách xem sơ đồ ghế không cần đăng nhập, nhưng phải đăng nhập trước khi xác nhận chọn ghế", Mục 4; REQ-13, REQ-14). Ghi là tiền điều kiện sẽ làm P04 chặn khách chưa đăng nhập ngay từ đầu UC-005, trái nguồn | U-R01, U-T10 | Trung bình | Sửa dòng REQ-12 ở Mục 5 thành "Tiền điều kiện của UC-007, UC-008; với UC-005, là điều kiện tại bước xác nhận chọn ghế (REQ-13, REQ-14), không phải tiền điều kiện". Thêm vào Mô tả ngắn của UC-005 câu "Khách chưa đăng nhập được xem sơ đồ ghế, phải đăng nhập trước khi xác nhận chọn ghế." Với ACT-02 Nhân viên quầy, đăng nhập vẫn là tiền điều kiện của UC-005 (REQ-102) |
| UCR-02 | UC-002 Đăng nhập (dòng Loại ở bảng 4a) | Cột Nhóm chức năng của UC-002 vẫn ghi "Tài khoản" trong khi Mục 6 nói nhóm Tài khoản không còn; người đọc bảng 4a sẽ tưởng còn nhóm này | U-N4 | Thấp | Đổi cột Nhóm chức năng của UC-002 thành "-" |

## 4. Danh sách use case đề xuất sau sửa

| UC | Tên (VI) | Tên (EN) | Tác nhân chính | Tác nhân phụ | Mục tiêu (kết quả có giá trị) | Thay đổi | Mã phát hiện |
|---|---|---|---|---|---|---|---|
| UC-001 | Đăng ký tài khoản | Register Account | ACT-01 | - | Khách có tài khoản để đặt vé | Giữ | - |
| UC-002 | Đăng nhập | Log In | - | - | - | Loại (giữ trạng thái của P02 1.1), sửa cột Nhóm chức năng | UCR-02 |
| UC-003 | Tra cứu phim | Browse Movies | ACT-01 | - | Khách biết phim đang chiếu, sắp chiếu và thông tin phim | Giữ | - |
| UC-004 | Tra cứu lịch chiếu | Browse Showtimes | ACT-01 | - | Khách biết các suất chiếu phù hợp | Giữ | - |
| UC-005 | Đặt vé | Book Tickets | ACT-01, ACT-02 | ACT-07, ACT-08 | Khách có vé cho các ghế đã chọn; ghế chuyển sang đã bán | Sửa mô tả ngắn (điểm đăng nhập của khách) | UCR-01 |
| UC-006 | Hoàn tiền thanh toán trễ | Refund Late Payment | ACT-07 | ACT-07, ACT-08 | Khách được hoàn toàn bộ tiền và báo qua email | Giữ | - |
| UC-007 | Xem lịch sử đặt vé | View Booking History | ACT-01 | - | Khách biết các lần đặt vé và vé đã mua | Giữ | - |
| UC-008 | Huỷ vé | Cancel Ticket | ACT-01, ACT-02 | ACT-07 | Vé được huỷ, hoàn 70%, ghế trở về trống | Giữ | - |
| UC-009 | Soát vé | Check Ticket | ACT-03 | - | Khách có vé hợp lệ được vào phòng chiếu | Giữ | - |
| UC-010 | Quản lý phim | Manage Movies | ACT-05 | - | Danh sách phim đúng và đủ | Giữ | - |
| UC-011 | Quản lý cụm rạp | Manage Cinemas | ACT-05 | - | Danh sách cụm rạp đúng và đủ | Giữ | - |
| UC-012 | Quản lý phòng chiếu | Manage Auditoriums | ACT-04 | - | Phòng chiếu có đúng thông tin và sơ đồ ghế | Giữ | - |
| UC-013 | Quản lý bảng giá | Manage Price List | ACT-04 | - | Cụm rạp có bảng giá | Giữ | - |
| UC-014 | Lập lịch suất chiếu | Schedule Showtimes | ACT-04 | - | Các phòng có lịch suất chiếu hợp lệ | Giữ | - |
| UC-015 | Xem báo cáo cụm rạp | View Cinema Report | ACT-04 | - | Quản lý cụm rạp biết doanh thu, tỉ lệ lấp đầy của cụm | Giữ | - |
| UC-016 | Xem báo cáo toàn chuỗi | View Chain Report | ACT-05 | - | Quản lý chuỗi biết và so sánh kết quả các cụm | Giữ | - |
| UC-017 | Quản lý tài khoản nhân viên | Manage Staff Accounts | ACT-06 | - | Nhân viên có tài khoản đúng cụm rạp, đúng vai trò | Giữ | - |

## 4b. Danh sách tác nhân sau sửa

| ACT | Tên (VI) | Tên (EN) | Loại | Tính chất | Thay đổi | Mã phát hiện |
|---|---|---|---|---|---|---|
| ACT-01 | Khách | Customer | Người | Chính | Giữ | - |
| ACT-02 | Nhân viên quầy | Box Office Clerk | Người | Chính | Giữ | - |
| ACT-03 | Nhân viên soát vé | Ticket Checker | Người | Chính | Giữ | - |
| ACT-04 | Quản lý cụm rạp | Cinema Manager | Người | Chính | Giữ | - |
| ACT-05 | Quản lý chuỗi | Chain Manager | Người | Chính | Giữ | - |
| ACT-06 | Quản trị viên | Administrator | Người | Chính | Giữ | - |
| ACT-07 | Cổng thanh toán | Payment Gateway | Hệ thống ngoài | Chính và phụ | Giữ | - |
| ACT-08 | Dịch vụ email | Email Service | Hệ thống ngoài | Phụ | Giữ | - |

## 6. Giới hạn của review

- Phạm vi không gồm SO_DO vì chưa có sơ đồ use case (P03 chưa chạy); Mục 5 Quan hệ đề xuất sau sửa không áp dụng.
- Nhận xét không thành phát hiện: UC-005 gom luồng trực tuyến, luồng quầy và các luồng thay thế (giữ ghế thất bại, chưa mở bán, đang có lượt giữ khác, hết hạn, khách huỷ, thanh toán thất bại). Luồng chính vẫn ước lượng trong khoảng 8-12 bước nên đạt U-T4; P04 cần theo dõi kích thước, nếu vượt ngưỡng thì xét tách theo Q4 c.

## Câu hỏi mở

Không có

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P02 | UC-005, dòng REQ-12 Mục 5 | UCR-01 | Chạy lại P02 kèm P02R-review.md, áp dụng UCR-01 |
| P02 | UC-002 | UCR-02 | Áp dụng cùng lần chạy lại với UCR-01 |

## Vấn đề còn mở

Không có
