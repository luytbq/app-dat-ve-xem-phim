# P02 - Xác định use case - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P02 |
| Phiên bản | 1.9 |
| Thay đổi 1.9 | Gắn REQ-162, REQ-03 cho UC-012 và REQ-153 cho UC-015, UC-016 ở bảng 4b và Mục 5 (thêm dòng REQ-153, REQ-162) |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md; P00-problem-brief.md 1.11; P01-actors.md 1.2; yeu-cau-dat-ve.md; P02-usecases.md 1.9; P02R-review.md 1.0 (áp dụng UCR-01, UCR-02). Quy ước đã chốt: U-R01 ghi đè, không mô hình hoá Đăng nhập thành use case, chỉ ghi là tiền điều kiện |
| Phạm vi | Toàn hệ thống |
| Mã Q, ASM cuối đã cấp | Q-67; không có ASM (NGHIEM_NGAT) |

## 1. Danh sách mục tiêu tác nhân

| ACT | Mục tiêu | Mức mục tiêu dự kiến (Summary / User-goal / Subfunction) | REQ | CAND |
|---|---|---|---|---|
| ACT-01 Khách | Có tài khoản để đặt vé | User-goal | REQ-11 | CAND-01 |
| ACT-01 Khách | Xác thực để dùng chức năng cần đăng nhập | Subfunction (tiền điều kiện, không thành UC) | REQ-12, REQ-13 | CAND-02 |
| ACT-01 Khách | Biết phim nào đang chiếu, sắp chiếu và thông tin phim | User-goal | REQ-05, REQ-06, REQ-07, REQ-96 | CAND-05, CAND-06 |
| ACT-01 Khách | Biết suất chiếu của một phim hoặc tại một cụm rạp | User-goal | REQ-08, REQ-09, REQ-10 | CAND-07, CAND-08, CAND-09 |
| ACT-01 Khách | Có vé cho các ghế mong muốn của một suất chiếu | User-goal | REQ-13 đến REQ-34, REQ-88, REQ-89 | CAND-12 |
| ACT-01 Khách | Xem lại các lần đặt vé và vé đã mua | User-goal | REQ-39 | CAND-25 |
| ACT-01 Khách | Huỷ vé đã mua và nhận lại tiền | User-goal | REQ-40 đến REQ-44 | CAND-26 |
| ACT-02 Nhân viên quầy | Xác thực để làm việc | Subfunction (tiền điều kiện, không thành UC) | REQ-102 | CAND-03 |
| ACT-02 Nhân viên quầy | Bán vé cho khách mua trực tiếp | User-goal | REQ-45 đến REQ-49, REQ-81, REQ-82, REQ-92 | CAND-28 |
| ACT-02 Nhân viên quầy | Huỷ vé mua tại quầy cho khách | User-goal | REQ-83, REQ-84, REQ-85 | CAND-31 |
| ACT-03 Nhân viên soát vé | Xác thực để làm việc | Subfunction (tiền điều kiện, không thành UC) | REQ-102 | CAND-03 |
| ACT-03 Nhân viên soát vé | Cho khách có vé hợp lệ vào phòng chiếu | User-goal | REQ-50 đến REQ-52, REQ-93, REQ-94 | CAND-32 |
| ACT-04 Quản lý cụm rạp | Xác thực để làm việc | Subfunction (tiền điều kiện, không thành UC) | REQ-102 | CAND-03 |
| ACT-04 Quản lý cụm rạp | Duy trì danh sách phòng chiếu và sơ đồ ghế của cụm | User-goal | REQ-56, REQ-57, REQ-58 | CAND-37, CAND-38 |
| ACT-04 Quản lý cụm rạp | Có bảng giá của cụm | User-goal | REQ-59 | CAND-39 |
| ACT-04 Quản lý cụm rạp | Có lịch suất chiếu cho các phòng của cụm | User-goal | REQ-60 đến REQ-65 | CAND-40, CAND-41 |
| ACT-04 Quản lý cụm rạp | Nắm doanh thu và tỉ lệ lấp đầy của cụm | User-goal | REQ-66, REQ-67 | CAND-42, CAND-43 |
| ACT-04 Quản lý cụm rạp, ACT-05 Quản lý chuỗi | Vận hành chuỗi rạp | Summary | REQ-53 đến REQ-65 | CAND-49 |
| ACT-05 Quản lý chuỗi | Xác thực để làm việc | Subfunction (tiền điều kiện, không thành UC) | REQ-102 | CAND-03 |
| ACT-05 Quản lý chuỗi | Duy trì danh sách phim | User-goal | REQ-53, REQ-55, REQ-95 | CAND-35 |
| ACT-05 Quản lý chuỗi | Duy trì danh sách cụm rạp | User-goal | REQ-54 | CAND-36 |
| ACT-05 Quản lý chuỗi | Nắm và so sánh kết quả của toàn chuỗi | User-goal | REQ-68, REQ-69 | CAND-44, CAND-45 |
| ACT-06 Quản trị viên | Xác thực để làm việc | Subfunction (tiền điều kiện, không thành UC) | REQ-104 | CAND-04 |
| ACT-06 Quản trị viên | Duy trì tài khoản, cụm rạp và vai trò của nhân viên | User-goal | REQ-70, REQ-71, REQ-72 | CAND-46, CAND-47, CAND-48 |
| ACT-07 Cổng thanh toán | Báo kết quả giao dịch về hệ thống | Subfunction (trong thời gian giữ ghế); User-goal (sau thời điểm hết hạn giữ ghế) | REQ-29, REQ-34, REQ-35, REQ-36 | CAND-22, CAND-23 |

## 2. Danh sách sự kiện

| EV | Sự kiện | Loại (Nghiệp vụ / Thời gian / Hệ thống ngoài / Thiết bị) | Nguồn phát (ACT) | Phản hồi mong đợi của hệ thống | REQ | CAND |
|---|---|---|---|---|---|---|
| EV-01 | Khách muốn có tài khoản | Nghiệp vụ | ACT-01 | Tạo tài khoản khách | REQ-11 | CAND-01 |
| EV-02 | Người dùng muốn dùng chức năng cần đăng nhập | Nghiệp vụ | ACT-01 đến ACT-06 | Xác thực và mở phiên làm việc theo vai trò; là tiền điều kiện của các UC, không thành UC (quy ước đã chốt) | REQ-12, REQ-102, REQ-104 | CAND-02, CAND-03, CAND-04 |
| EV-03 | Khách muốn biết phim đang chiếu, sắp chiếu | Nghiệp vụ | ACT-01 | Cung cấp danh sách và thông tin phim | REQ-05, REQ-06 | CAND-05 |
| EV-04 | Khách muốn biết lịch chiếu | Nghiệp vụ | ACT-01 | Cung cấp suất chiếu theo phim hoặc theo cụm rạp, theo bộ lọc | REQ-08, REQ-09, REQ-10 | CAND-07 |
| EV-05 | Khách muốn mua vé một suất chiếu (trực tuyến hoặc tại quầy) | Nghiệp vụ | ACT-01, ACT-02 | Giữ ghế, thu tiền, chuyển ghế sang đã bán, tạo vé | REQ-13, REQ-45 | CAND-12, CAND-28 |
| EV-06 | Hết 10 phút giữ ghế mà chưa thanh toán hoặc chưa xác nhận thu tiền | Thời gian | - | Giải phóng ghế đang giữ | REQ-22, REQ-32, REQ-76 | CAND-19 |
| EV-07 | Cổng thanh toán báo kết quả giao dịch trong thời gian giữ ghế | Hệ thống ngoài | ACT-07 | Thành công: chuyển ghế sang đã bán, tạo vé, gửi email; thất bại: giải phóng ghế | REQ-29, REQ-34 | CAND-21, CAND-22 |
| EV-08 | Cổng thanh toán báo thanh toán thành công sau thời điểm hết hạn giữ ghế, hoặc sau khi khách đã huỷ giữ ghế hoặc cổng đã báo thất bại, hoặc báo thêm giao dịch thành công thứ hai cho lần giữ ghế đã có vé; cổng cũng có thể báo trùng một giao dịch đã xử lý hoặc báo thất bại vào lúc muộn (chỉ ghi nhận, không hoàn tiền) | Hệ thống ngoài | ACT-07 | Không tạo vé, hoàn toàn bộ tiền, gửi email thông báo | REQ-35, REQ-36, REQ-90, REQ-109, REQ-130 | CAND-23 |
| EV-09 | Khách muốn xem lại vé đã đặt | Nghiệp vụ | ACT-01 | Cung cấp lịch sử đặt vé và vé | REQ-39 | CAND-25 |
| EV-10 | Khách muốn huỷ vé đã mua (trực tuyến hoặc tại quầy) | Nghiệp vụ | ACT-01, ACT-02 | Huỷ vé, hoàn 70%, trả ghế về trống | REQ-40, REQ-83 | CAND-26, CAND-31 |
| EV-11 | Khách mang vé tới cửa phòng chiếu | Nghiệp vụ | ACT-03 | Kiểm tra vé, đánh dấu vé đã sử dụng hoặc báo lý do không hợp lệ | REQ-50 | CAND-32 |
| EV-12 | Chuỗi có phim mới hoặc thông tin phim thay đổi | Nghiệp vụ | ACT-05 | Cập nhật danh sách phim | REQ-53 | CAND-35 |
| EV-13 | Chuỗi có cụm rạp mới hoặc thông tin cụm rạp thay đổi | Nghiệp vụ | ACT-05 | Cập nhật danh sách cụm rạp | REQ-54 | CAND-36 |
| EV-14 | Cụm rạp có phòng chiếu mới hoặc phòng chiếu thay đổi | Nghiệp vụ | ACT-04 | Cập nhật phòng chiếu và sơ đồ ghế | REQ-56 | CAND-37 |
| EV-15 | Cụm rạp thay đổi giá vé | Nghiệp vụ | ACT-04 | Cập nhật bảng giá của cụm | REQ-59 | CAND-39 |
| EV-16 | Cụm rạp cần lên lịch chiếu cho các phòng | Nghiệp vụ | ACT-04 | Lưu suất chiếu hợp lệ | REQ-60 | CAND-40 |
| EV-17 | Quản lý cụm rạp cần nắm kết quả kinh doanh của cụm | Nghiệp vụ | ACT-04 | Cung cấp báo cáo doanh thu và tỉ lệ lấp đầy của cụm | REQ-66, REQ-67 | CAND-42 |
| EV-18 | Quản lý chuỗi cần nắm và so sánh kết quả các cụm | Nghiệp vụ | ACT-05 | Cung cấp báo cáo toàn chuỗi và so sánh giữa các cụm | REQ-68, REQ-69 | CAND-44 |
| EV-19 | Có nhân viên mới hoặc nhân viên đổi cụm rạp, vai trò | Nghiệp vụ | ACT-06 | Cập nhật tài khoản, cụm rạp, vai trò của nhân viên | REQ-70, REQ-71, REQ-72 | CAND-46 |

## 3. Bảng ứng viên use case

| CAND | Ứng viên | Kết luận | Phép thử không đạt | Lý do | REQ | Nguồn phát hiện |
|---|---|---|---|---|---|---|
| CAND-01 | Đăng ký tài khoản | Giữ thành UC-001 | - | U-R03: khách chưa có tài khoản tạo tài khoản để đặt vé | REQ-11 | Mục tiêu, EV-01 |
| CAND-02 | Đăng nhập | Loại | U-T1, U-T3, U-AP01 | Quy ước đã chốt ghi đè U-R01: đăng nhập không là UC, được ghi là tiền điều kiện của các UC cần xác thực ở P04 (phiên bản 1.0 đã cấp UC-002, nay UC-002 ở trạng thái Loại) | REQ-12, REQ-13, REQ-102, REQ-104 | Mục tiêu, EV-02 |
| CAND-03 | Đăng nhập của nhân viên | Loại | U-T1, U-T3, U-AP01 | Quy ước đã chốt ghi đè U-R01: tiền điều kiện của các UC của nhân viên | REQ-102 | Mục tiêu, EV-02 |
| CAND-04 | Đăng nhập của quản trị viên | Loại | U-T1, U-T3, U-AP01 | Quy ước đã chốt ghi đè U-R01: tiền điều kiện của UC-017; tài khoản có sẵn khi cài đặt (REQ-103) | REQ-104 | Mục tiêu, EV-02 |
| CAND-05 | Xem danh sách phim đang chiếu và sắp chiếu | Giữ thành UC-003 | - | U-R05, U-R17: mục tiêu thông tin độc lập của khách | REQ-05 | Mục tiêu, EV-03 |
| CAND-06 | Xem thông tin phim | Gộp vào UC-003 | U-AP01 | U-R05: xem danh sách rồi xem chi tiết là một UC | REQ-06, REQ-07 | Động từ |
| CAND-07 | Xem lịch chiếu theo phim | Giữ thành UC-004 | - | U-R05: mục tiêu thông tin độc lập của khách | REQ-08 | Mục tiêu, EV-04 |
| CAND-08 | Xem lịch chiếu theo cụm rạp | Gộp vào UC-004 | U-AP15 | U-R12: biến thể cách tra cứu cùng mục tiêu, thành luồng thay thế | REQ-09 | Động từ |
| CAND-09 | Lọc lịch chiếu | Gộp vào UC-004 | U-AP12 | U-R17: lọc là bước tuỳ chọn của tra cứu | REQ-10 | Động từ |
| CAND-10 | Xem sơ đồ ghế của suất chiếu | Là bước của UC-005 | U-T1, U-AP01 | U-R05: việc xem phục vụ bước chọn ghế của đặt vé | REQ-14, REQ-15 | Động từ |
| CAND-11 | Cập nhật sơ đồ ghế khi người khác giữ hoặc mua ghế | Là bước của UC-005 | U-T9, U-AP11 | U-R09: hệ quả của việc giữ, bán ghế, xảy ra trong phiên xem sơ đồ ghế | REQ-18, REQ-19 | Động từ |
| CAND-12 | Đặt vé | Giữ thành UC-005 | - | Mục tiêu chính của khách; kết quả là vé cho các ghế đã chọn | REQ-13 | Mục tiêu, EV-05 |
| CAND-13 | Chọn ghế | Là bước của UC-005 | U-T1, U-AP01 | Thao tác đơn, không có kết quả trọn vẹn | REQ-20, REQ-88 | Động từ |
| CAND-14 | Giữ ghế tạm | Là bước của UC-005 | U-T1, U-T5 | Q4 không thoả: chỉ UC-005 dùng; giữ ghế thất bại kết thúc mục tiêu đặt vé | REQ-21 đến REQ-24, REQ-26, REQ-27, REQ-89 | Động từ |
| CAND-15 | Báo việc giữ ghế không thành công | Là bước của UC-005 | U-T9, U-AP03 | Phản hồi của hệ thống trong bước giữ ghế | REQ-25 | Động từ |
| CAND-16 | Thanh toán trực tuyến | Là bước của UC-005 | U-T1 | Q4 d không thoả: thanh toán thất bại giải phóng ghế, tức là huỷ mục tiêu đặt vé | REQ-28 | Động từ |
| CAND-17 | Chuyển ghế sang đã bán và tạo vé | Là bước của UC-005 | U-T9, U-AP03 | Hệ quả của thanh toán thành công | REQ-29, REQ-30 | Động từ |
| CAND-18 | Gửi vé qua email | Là bước của UC-005 | U-T9, U-AP03 | U-R06: thông báo là hệ quả của UC; ACT-08 là tác nhân phụ | REQ-31 | Động từ |
| CAND-19 | Giải phóng ghế khi hết thời gian giữ | Là bước của UC-005 | U-T8, U-AP11 | U-R07 hết giờ trong phiên: chờ thanh toán hoặc chờ xác nhận thu tiền | REQ-32, REQ-76 | Sự kiện EV-06 |
| CAND-20 | Huỷ việc giữ ghế | Là bước của UC-005 | U-T1, U-T5 | Khách bỏ mục tiêu đặt vé trong phiên; là luồng thay thế của UC-005 | REQ-33 | Động từ |
| CAND-21 | Giải phóng ghế khi thanh toán thất bại | Là bước của UC-005 | U-T9, U-AP03 | U-R08: kết quả giao dịch trong phiên là bước của UC đang chạy | REQ-34 | Sự kiện EV-07 |
| CAND-22 | Ghi nhận kết quả thanh toán trong thời gian giữ ghế | Là bước của UC-005 | U-T1 | U-R08: phản hồi của cổng thanh toán trong phiên đặt vé | REQ-29 | Sự kiện EV-07 |
| CAND-23 | Hoàn tiền khi thanh toán báo về sau thời điểm hết hạn giữ ghế | Giữ thành UC-006 | - | U-R08: cổng thanh toán tự gửi kết quả vào lúc phiên đặt vé đã kết thúc (giữ ghế đã hết hạn), hệ thống phải xử lý như mục tiêu riêng | REQ-35, REQ-36 | Sự kiện EV-08 |
| CAND-24 | Gửi email thông báo hoàn tiền | Là bước của UC-006 | U-T9, U-AP03 | U-R06: thông báo là hệ quả của UC; ACT-08 là tác nhân phụ | REQ-90 | Động từ |
| CAND-25 | Xem lịch sử đặt vé | Giữ thành UC-007 | - | U-R05: mục tiêu thông tin độc lập của khách | REQ-39 | Mục tiêu, EV-09 |
| CAND-26 | Huỷ vé | Giữ thành UC-008 | - | U-R04 b: giao dịch nghiệp vụ có quy tắc thời hạn và mức hoàn riêng | REQ-40, REQ-41, REQ-42, REQ-44 | Mục tiêu, EV-10 |
| CAND-27 | Hoàn tiền vé bị huỷ qua cổng thanh toán | Là bước của UC-008 | U-T9, U-AP03 | U-R08: ACT-07 là tác nhân phụ của việc huỷ vé | REQ-43 | Động từ |
| CAND-28 | Bán vé tại quầy | Gộp vào UC-005 | U-AP15 | U-R10 b: nhân viên quầy đặt vé hộ khách; thu tiền mặt và in vé tương ứng với thanh toán qua cổng và nhận vé qua email; kết quả như nhau (ghế đã bán, có vé) | REQ-45 đến REQ-47, REQ-82, REQ-92 | Mục tiêu, EV-05 |
| CAND-29 | Xác nhận đã thu tiền | Là bước của UC-005 | U-T1, U-AP01 | Bước của luồng bán tại quầy | REQ-48, REQ-81 | Động từ |
| CAND-30 | In vé | Là bước của UC-005 | U-T1, U-AP01 | Bước của luồng bán tại quầy | REQ-49 | Động từ |
| CAND-31 | Huỷ vé mua tại quầy | Gộp vào UC-008 | U-AP15 | U-R10 b: hoàn tiền mặt tại quầy tương ứng với hoàn tiền qua cổng; kết quả như nhau (vé bị huỷ, ghế trống) | REQ-83, REQ-84, REQ-85 | Mục tiêu, EV-10 |
| CAND-32 | Soát vé | Giữ thành UC-009 | - | U-R18: nhân viên soát vé là tác nhân chính; camera của thiết bị chỉ là kênh nhập | REQ-50, REQ-51, REQ-52 | Mục tiêu, EV-11 |
| CAND-33 | Chọn suất chiếu đang soát | Là bước của UC-009 | U-T1, U-AP01 | Bước mở phiên soát vé | REQ-93 | Động từ |
| CAND-34 | Báo lý do vé không hợp lệ | Là bước của UC-009 | U-T9, U-AP03 | Phản hồi của hệ thống trong bước kiểm tra vé | REQ-94 | Động từ |
| CAND-35 | Quản lý danh sách phim | Giữ thành UC-010 | - | U-R04: CRUD dữ liệu danh mục của một tác nhân | REQ-53, REQ-55, REQ-95 | Mục tiêu, EV-12 |
| CAND-36 | Quản lý danh sách cụm rạp | Giữ thành UC-011 | - | U-R04: CRUD dữ liệu danh mục của một tác nhân | REQ-54 | Mục tiêu, EV-13 |
| CAND-37 | Quản lý phòng chiếu | Giữ thành UC-012 | - | U-R04: CRUD dữ liệu danh mục của một tác nhân | REQ-56, REQ-57, REQ-58 | Mục tiêu, EV-14 |
| CAND-38 | Thiết kế sơ đồ ghế của phòng chiếu | Gộp vào UC-012 | U-AP07 | U-R04: sơ đồ ghế là thành phần của phòng chiếu (REQ-57), được cập nhật cùng phòng | REQ-57 | Động từ |
| CAND-39 | Thiết lập bảng giá của cụm rạp | Giữ thành UC-013 | - | U-R15: tham số nghiệp vụ do quản lý cụm rạp thiết lập | REQ-59 | Mục tiêu, EV-15 |
| CAND-40 | Lập lịch suất chiếu | Giữ thành UC-014 | - | Giao dịch có nhiều quy tắc riêng (định dạng, khoảng ngày chiếu, dọn phòng, mở bán) | REQ-60 đến REQ-64 | Mục tiêu, EV-16 |
| CAND-41 | Sửa, xoá suất chiếu | Gộp vào UC-014 | U-AP07 | U-R04: cùng tác nhân, cùng dữ liệu; ràng buộc sửa, xoá ở REQ-65 là luồng thay thế | REQ-65 | Động từ |
| CAND-42 | Xem báo cáo doanh thu của cụm rạp | Giữ thành UC-015 | - | U-R05: mục tiêu thông tin độc lập của quản lý cụm rạp | REQ-66 | Mục tiêu, EV-17 |
| CAND-43 | Xem báo cáo tỉ lệ lấp đầy của cụm rạp | Gộp vào UC-015 | U-AP12 | U-R05: cùng tác nhân, cùng cách thao tác, chỉ khác nội dung | REQ-67 | Động từ |
| CAND-44 | Xem báo cáo toàn chuỗi | Giữ thành UC-016 | - | U-R05: tác nhân khác UC-015 và có mục đích so sánh giữa các cụm | REQ-68 | Mục tiêu, EV-18 |
| CAND-45 | So sánh báo cáo giữa các cụm rạp | Gộp vào UC-016 | U-AP12 | U-R05: cùng tác nhân, cùng dữ liệu báo cáo | REQ-69 | Động từ |
| CAND-46 | Quản lý tài khoản nhân viên | Giữ thành UC-017 | - | U-R15: quản lý tài khoản và phân quyền do quản trị viên làm | REQ-70 | Mục tiêu, EV-19 |
| CAND-47 | Gán nhân viên vào cụm rạp | Gộp vào UC-017 | U-AP07 | U-R04, U-R15: cụm rạp là thuộc tính của tài khoản nhân viên | REQ-71 | Động từ |
| CAND-48 | Phân quyền nhân viên theo vai trò | Gộp vào UC-017 | U-AP07 | U-R15: vai trò là thuộc tính của tài khoản nhân viên | REQ-72 | Động từ |
| CAND-49 | Vận hành chuỗi rạp | Tách thành CAND-35, CAND-36, CAND-37, CAND-39, CAND-40 | U-T1, U-T6, U-AP04 | Summary: gom nhiều mục tiêu của hai tác nhân | REQ-53 đến REQ-65 | Mục tiêu |
| CAND-50 | Xác định phim đang chiếu, sắp chiếu theo ngày | Là bước của UC-003 | U-T9, U-AP11 | U-R09: quy tắc REQ-96 áp dụng khi khách tra cứu phim, không có sự kiện kích hoạt riêng | REQ-96 | Động từ |
| CAND-51 | Chặn đặt vé trước thời điểm mở bán | Là bước của UC-005 | U-T9, U-AP03 | Quy tắc REQ-86 kiểm tra trong bước chọn suất chiếu | REQ-86 | Động từ |

## 4. Bảng use case

Bảng 4a. Bảng lõi

| UC | Tên (VI) | Tên (EN) | Tác nhân chính (ACT) | Tác nhân phụ (ACT) | Mức | Nhóm chức năng |
|---|---|---|---|---|---|---|
| UC-001 | Đăng ký tài khoản | Register Account | ACT-01 Khách | - | User-goal | Bán vé |
| UC-002 | Đăng nhập | Log In | - | - | Loại | - |
| UC-003 | Tra cứu phim | Browse Movies | ACT-01 | - | User-goal | Bán vé |
| UC-004 | Tra cứu lịch chiếu | Browse Showtimes | ACT-01 | - | User-goal | Bán vé |
| UC-005 | Đặt vé | Book Tickets | ACT-01, ACT-02 | ACT-07 Cổng thanh toán, ACT-08 Dịch vụ email | User-goal | Bán vé |
| UC-006 | Hoàn tiền thanh toán trễ | Refund Late Payment | ACT-07 | ACT-07, ACT-08 | User-goal | Bán vé |
| UC-007 | Xem lịch sử đặt vé | View Booking History | ACT-01 | - | User-goal | Bán vé |
| UC-008 | Huỷ vé | Cancel Ticket | ACT-01, ACT-02 | ACT-07 | User-goal | Bán vé |
| UC-009 | Soát vé | Check Ticket | ACT-03 | - | User-goal | Bán vé |
| UC-010 | Quản lý phim | Manage Movies | ACT-05 | - | User-goal | Vận hành rạp |
| UC-011 | Quản lý cụm rạp | Manage Cinemas | ACT-05 | - | User-goal | Vận hành rạp |
| UC-012 | Quản lý phòng chiếu | Manage Auditoriums | ACT-04 | - | User-goal | Vận hành rạp |
| UC-013 | Quản lý bảng giá | Manage Price List | ACT-04 | - | User-goal | Vận hành rạp |
| UC-014 | Lập lịch suất chiếu | Schedule Showtimes | ACT-04 | - | User-goal | Vận hành rạp |
| UC-015 | Xem báo cáo cụm rạp | View Cinema Report | ACT-04 | - | User-goal | Báo cáo và quản trị |
| UC-016 | Xem báo cáo toàn chuỗi | View Chain Report | ACT-05 | - | User-goal | Báo cáo và quản trị |
| UC-017 | Quản lý tài khoản nhân viên | Manage Staff Accounts | ACT-06 | - | User-goal | Báo cáo và quản trị |

Bảng 4b. Bảng mô tả

| UC | Mục tiêu (kết quả có giá trị) | Mô tả ngắn | Sự kiện kích hoạt | REQ | CAND nguồn |
|---|---|---|---|---|---|
| UC-001 | Khách có tài khoản gắn với email, số điện thoại và mật khẩu để đặt vé. | Khách chưa có tài khoản đăng ký bằng email, số điện thoại và mật khẩu. | Khách muốn có tài khoản (EV-01) | REQ-11 | CAND-01 |
| UC-002 | - | Loại ở phiên bản 1.1 theo quy ước đã chốt: đăng nhập không là use case. Việc khách, nhân viên, quản trị viên đã đăng nhập được ghi là tiền điều kiện của UC-005, UC-007, UC-008 (khách) và mọi UC của ACT-02 đến ACT-06 ở P04. | Người dùng muốn dùng chức năng cần đăng nhập (EV-02) | REQ-12, REQ-102, REQ-103, REQ-104 | CAND-02, CAND-03, CAND-04 |
| UC-003 | Khách biết các phim đang chiếu, sắp chiếu và thông tin của phim quan tâm. | Khách xem danh sách phim đang chiếu, sắp chiếu (xác định theo ngày khởi chiếu và ngày kết thúc chiếu) rồi xem thông tin một phim; không cần đăng nhập. | Khách muốn biết phim đang chiếu, sắp chiếu (EV-03) | REQ-05, REQ-06, REQ-07, REQ-96 | CAND-05, CAND-06, CAND-50 |
| UC-004 | Khách biết các suất chiếu phù hợp với phim, cụm rạp, ngày, loại phòng, định dạng mình quan tâm. | Khách xem lịch chiếu theo phim hoặc theo cụm rạp, có thể lọc theo tỉnh, thành phố, ngày, loại phòng, định dạng phim; không cần đăng nhập. | Khách muốn biết lịch chiếu (EV-04) | REQ-08, REQ-09, REQ-10 | CAND-07, CAND-08, CAND-09 |
| UC-005 | Khách có vé (mỗi ghế một vé có mã QR, cùng một mã đặt vé) cho các ghế đã chọn của một suất chiếu; các ghế chuyển sang đã bán. | Khách chọn suất chiếu đã mở bán, xem sơ đồ ghế, chọn tối đa 8 ghế và xác nhận để hệ thống giữ cả nhóm ghế trong 10 phút, rồi thanh toán qua cổng thanh toán và nhận vé qua email. Nhân viên quầy dùng UC này để bán vé tại quầy cho khách mua trực tiếp: thu tiền mặt, xác nhận đã thu tiền và in vé. Hết thời gian giữ, khách huỷ hoặc thanh toán thất bại thì ghế được giải phóng. Khách chưa đăng nhập được xem sơ đồ ghế, phải đăng nhập trước khi xác nhận chọn ghế. | Khách muốn mua vé một suất chiếu (EV-05) | REQ-13 đến REQ-34, REQ-45 đến REQ-49, REQ-81, REQ-82, REQ-86, REQ-88, REQ-89, REQ-92, REQ-119, REQ-134, REQ-135, REQ-142, REQ-149, REQ-152 | CAND-10 đến CAND-22, CAND-28, CAND-29, CAND-30, CAND-51 |
| UC-006 | Khách được hoàn toàn bộ số tiền đã thanh toán và được báo qua email khi thanh toán thành công về tới hệ thống sau thời điểm hết hạn giữ ghế, hoặc sau khi khách đã huỷ giữ ghế hoặc cổng thanh toán đã báo thất bại, hoặc khi giao dịch là giao dịch thứ hai cho lần giữ ghế đã có vé. Khi giao dịch hệ thống không nhận ra, use case chỉ ghi log lỗi và để lại cho xử lý thủ công ngoài hệ thống. | Cổng thanh toán báo một giao dịch thành công sau thời điểm hết hạn giữ ghế, hoặc sau khi khách đã huỷ giữ ghế hoặc cổng đã báo thất bại, hoặc cho lần giữ ghế đã có vé từ giao dịch khác; hệ thống không tạo vé, yêu cầu cổng thanh toán hoàn toàn bộ tiền và gửi email thông báo hoàn tiền cho khách. Với giao dịch hệ thống không nhận ra, hệ thống chỉ ghi log lỗi, không hoàn tiền, không gửi email. | Cổng thanh toán báo thanh toán thành công sau thời điểm hết hạn giữ ghế, hoặc sau khi khách đã huỷ giữ ghế hoặc cổng đã báo thất bại, hoặc báo thành công cho giao dịch hệ thống không nhận ra hoặc lần giữ ghế đã có vé (EV-08) | REQ-35, REQ-36, REQ-90, REQ-109 đến REQ-111, REQ-116, REQ-129 đến REQ-133 | CAND-23, CAND-24 |
| UC-007 | Khách biết các lần đặt vé và các vé mình đã mua. | Khách đã đăng nhập xem lịch sử đặt vé và vé của mình. | Khách muốn xem lại vé đã đặt (EV-09) | REQ-39 | CAND-25 |
| UC-008 | Vé được huỷ, khách được hoàn 70% giá vé, ghế trở về trạng thái trống. | Khách huỷ từng vé đã mua trực tuyến trước giờ chiếu ít nhất 2 tiếng và được hoàn tiền qua cổng thanh toán. Nhân viên quầy dùng UC này để huỷ vé mua tại quầy của cụm mình, hoàn tiền mặt. | Khách muốn huỷ vé đã mua (EV-10) | REQ-40 đến REQ-44, REQ-83, REQ-84, REQ-85, REQ-118 đến REQ-122, REQ-131, REQ-132 | CAND-26, CAND-27, CAND-31 |
| UC-009 | Khách có vé hợp lệ được vào phòng chiếu; vé được đánh dấu đã sử dụng. | Nhân viên soát vé chọn suất chiếu đang soát, quét mã QR trên từng vé bằng camera của thiết bị; hệ thống kiểm tra vé và đánh dấu đã sử dụng, hoặc báo lý do không hợp lệ. | Khách mang vé tới cửa phòng chiếu (EV-11) | REQ-50, REQ-51, REQ-52, REQ-93, REQ-94, REQ-118, REQ-123 đến REQ-128 | CAND-32, CAND-33, CAND-34 |
| UC-010 | Danh sách phim của chuỗi đúng và đủ thông tin để lập lịch chiếu và cho khách tra cứu. | Quản lý chuỗi quản lý danh sách phim: thông tin phim, định dạng phát hành, ngày khởi chiếu, ngày kết thúc chiếu. | Chuỗi có phim mới hoặc thông tin phim thay đổi (EV-12) | REQ-53, REQ-55, REQ-95 | CAND-35 |
| UC-011 | Danh sách cụm rạp của chuỗi đúng và đủ. | Quản lý chuỗi quản lý danh sách cụm rạp. | Chuỗi có cụm rạp mới hoặc thông tin cụm rạp thay đổi (EV-13) | REQ-54 | CAND-36 |
| UC-012 | Các phòng chiếu của cụm có đúng loại phòng, sức chứa, định dạng chiếu được và sơ đồ ghế. | Quản lý cụm rạp quản lý phòng chiếu của cụm mình cùng sơ đồ ghế; không sửa được sơ đồ ghế của phòng đang có suất chiếu chưa diễn ra đã bán vé hoặc có ghế đang được giữ. | Cụm rạp có phòng chiếu mới hoặc phòng chiếu thay đổi (EV-14) | REQ-56, REQ-57, REQ-58, REQ-03, REQ-162 | CAND-37, CAND-38 |
| UC-013 | Cụm rạp có bảng giá theo loại phòng, định dạng phim, loại ghế và khung giờ. | Quản lý cụm rạp thiết lập bảng giá của cụm mình: đặt giá hoặc bỏ giá của một tổ hợp loại phòng, định dạng, loại ghế, khung giờ. | Cụm rạp thay đổi giá vé (EV-15) | REQ-37, REQ-38, REQ-59, REQ-91, REQ-146 đến REQ-151 | CAND-39 |
| UC-014 | Các phòng của cụm có lịch suất chiếu hợp lệ, kèm thời điểm mở bán. | Quản lý cụm rạp lập, sửa, xoá suất chiếu cho các phòng của cụm mình, theo các quy tắc về định dạng, khoảng ngày chiếu, thời điểm mở bán, giờ kết thúc, dọn phòng 15 phút, bảng giá của cụm có đủ giá cho suất chiếu; không sửa, xoá được suất chiếu đang có ghế được giữ, có vé đã bán chưa bị huỷ hoặc đã tới giờ bắt đầu. | Cụm rạp cần lên lịch chiếu (EV-16) | REQ-60 đến REQ-65, REQ-86, REQ-97, REQ-98, REQ-137 đến REQ-145, REQ-151 | CAND-40, CAND-41 |
| UC-015 | Quản lý cụm rạp biết doanh thu và tỉ lệ lấp đầy ghế của cụm mình. | Quản lý cụm rạp xem báo cáo doanh thu và tỉ lệ lấp đầy ghế của cụm mình theo ngày, theo phim, theo suất chiếu. | Quản lý cụm rạp cần nắm kết quả kinh doanh (EV-17) | REQ-66, REQ-67, REQ-99, REQ-153 | CAND-42, CAND-43 |
| UC-016 | Quản lý chuỗi biết doanh thu, tỉ lệ lấp đầy của toàn chuỗi và so sánh được giữa các cụm. | Quản lý chuỗi xem báo cáo doanh thu và tỉ lệ lấp đầy ghế cho toàn chuỗi, so sánh giữa các cụm rạp. | Quản lý chuỗi cần nắm và so sánh kết quả (EV-18) | REQ-68, REQ-69, REQ-99, REQ-153 | CAND-44, CAND-45 |
| UC-017 | Nhân viên có tài khoản đúng cụm rạp và đúng vai trò. | Quản trị viên quản lý tài khoản nhân viên, gán nhân viên vào cụm rạp và phân vai trò (nhân viên quầy, nhân viên soát vé, quản lý cụm rạp, quản lý chuỗi). | Có nhân viên mới hoặc nhân viên đổi cụm rạp, vai trò (EV-19) | REQ-70, REQ-71, REQ-72, REQ-100, REQ-101 | CAND-46, CAND-47, CAND-48 |

## 5. Ma trận truy vết REQ --> UC

| REQ | Nội dung tóm tắt | UC phủ | Ghi chú (lý do nếu không phủ) |
|---|---|---|---|
| REQ-01 | Quy mô 15 cụm rạp, 4-12 phòng mỗi cụm | - | Chuyển P06 (dữ liệu quy mô) |
| REQ-02 | Ba loại phòng | UC-012 | Không có |
| REQ-03 | Sức chứa 50-400 ghế | UC-012 | Điều kiện hợp lệ của sơ đồ ghế (Q-211); cũng là dữ liệu quy mô ở P06 |
| REQ-04 | Khoảng 500 suất mỗi ngày | - | Chuyển P06 (dữ liệu quy mô) |
| REQ-05 | Xem danh sách phim đang chiếu, sắp chiếu | UC-003 | Không có |
| REQ-06 | Xem thông tin phim | UC-003 | Không có |
| REQ-07 | Thành phần thông tin phim | UC-003, UC-010 | Không có |
| REQ-08 | Xem lịch chiếu theo phim | UC-004 | Không có |
| REQ-09 | Xem lịch chiếu theo cụm rạp | UC-004 | Không có |
| REQ-10 | Lọc lịch chiếu | UC-004 | Không có |
| REQ-11 | Đăng ký tài khoản | UC-001 | Không có |
| REQ-12 | Khách đăng nhập | - | Tiền điều kiện của UC-007, UC-008 (U-R01); với UC-005, là điều kiện tại bước xác nhận chọn ghế (REQ-13, REQ-14), không phải tiền điều kiện |
| REQ-13 | Khách đã đăng nhập đặt vé | UC-005 | Không có |
| REQ-14 | Xem sơ đồ ghế không cần đăng nhập | UC-005 | Không có |
| REQ-15 | Ba trạng thái ghế | UC-005 | Không có |
| REQ-16 | Ba loại ghế | UC-005, UC-012 | Không có |
| REQ-17 | Ghế đôi bán như một ghế | UC-005 | Không có |
| REQ-18 | Cập nhật sơ đồ ghế | UC-005 | Không có |
| REQ-19 | Sơ đồ ghế cập nhật trong 3 giây | UC-005 | Chuyển P06 (phi chức năng) |
| REQ-20 | Tối đa 8 ghế mỗi lần đặt | UC-005 | Không có |
| REQ-21 | Giữ cả nhóm ghế khi xác nhận | UC-005 | Không có |
| REQ-22 | Giữ ghế 10 phút | UC-005 | Không có |
| REQ-23 | Ghế đang giữ không ai khác chọn được | UC-005 | Không có |
| REQ-24 | Giữ tất cả hoặc không ghế nào | UC-005 | Không có |
| REQ-25 | Báo giữ ghế không thành công | UC-005 | Không có |
| REQ-26 | Một ghế chỉ bán cho một người | UC-005 | Không có |
| REQ-27 | Nhiều khách cùng xác nhận một ghế, chỉ một người giữ được | UC-005 | Không có |
| REQ-28 | Thanh toán trực tuyến | UC-005 | Không có |
| REQ-29 | Chuyển ghế sang đã bán khi thanh toán thành công | UC-005 | Không có |
| REQ-30 | Tạo mã đặt vé và vé có mã QR | UC-005 | Không có |
| REQ-31 | Gửi vé qua email | UC-005 | Không có |
| REQ-32 | Giải phóng ghế khi hết thời gian giữ | UC-005 | Luồng thay thế (U-R07 hết giờ trong phiên) |
| REQ-33 | Khách huỷ việc giữ ghế | UC-005 | Luồng thay thế |
| REQ-34 | Giải phóng ghế khi thanh toán thất bại | UC-005 | Luồng thay thế |
| REQ-35 | Hoàn tiền khi thanh toán báo về sau hết hạn | UC-006 | Không có |
| REQ-36 | Không tạo vé khi thanh toán báo về sau hết hạn | UC-006 | Không có |
| REQ-37 | Bảng giá riêng từng cụm | UC-013, UC-005 | Không có |
| REQ-38 | Các yếu tố quyết định giá vé | UC-013, UC-005 | Không có |
| REQ-39 | Xem lịch sử đặt vé | UC-007 | Không có |
| REQ-40 | Khách huỷ từng vé | UC-008 | Không có |
| REQ-41 | Huỷ trước giờ chiếu ít nhất 2 tiếng | UC-008 | Không có |
| REQ-42 | Hoàn 70% giá vé | UC-008 | Không có |
| REQ-43 | Hoàn tiền qua cổng thanh toán | UC-008 | Không có |
| REQ-44 | Trả ghế của vé bị huỷ về trống | UC-008 | Không có |
| REQ-45 | Nhân viên quầy bán vé | UC-005 | U-R10 b |
| REQ-46 | Quầy dùng chung sơ đồ ghế và quy tắc giữ ghế | UC-005 | Không có |
| REQ-47 | Khách tại quầy trả tiền mặt | UC-005 | Không có |
| REQ-48 | Nhân viên quầy xác nhận đã thu tiền | UC-005 | Không có |
| REQ-49 | Nhân viên quầy in vé | UC-005 | Không có |
| REQ-50 | Quét mã QR để soát vé | UC-009 | Không có |
| REQ-51 | Điều kiện vé hợp lệ | UC-009 | Không có |
| REQ-52 | Đánh dấu vé đã sử dụng | UC-009 | Không có |
| REQ-53 | Quản lý danh sách phim | UC-010 | Không có |
| REQ-54 | Quản lý danh sách cụm rạp | UC-011 | Không có |
| REQ-55 | Định dạng phát hành của phim | UC-010 | Không có |
| REQ-56 | Quản lý phòng chiếu | UC-012 | Không có |
| REQ-57 | Thành phần phòng chiếu | UC-012 | Không có |
| REQ-58 | Không sửa sơ đồ ghế khi đang có suất bán vé hoặc ghế đang giữ | UC-012 | Không có |
| REQ-59 | Thiết lập bảng giá | UC-013 | Không có |
| REQ-60 | Lập lịch suất chiếu | UC-014 | Không có |
| REQ-61 | Thành phần suất chiếu | UC-014 | Không có |
| REQ-62 | Định dạng suất chiếu thuộc định dạng phát hành | UC-014 | Không có |
| REQ-63 | Phòng chiếu được định dạng của suất | UC-014 | Không có |
| REQ-64 | Dọn phòng 15 phút | UC-014 | Không có |
| REQ-65 | Không sửa, xoá suất có ghế đang giữ hoặc vé đã bán | UC-014 | Không có |
| REQ-66 | Báo cáo doanh thu của cụm | UC-015 | Không có |
| REQ-67 | Báo cáo tỉ lệ lấp đầy của cụm | UC-015 | Không có |
| REQ-68 | Báo cáo toàn chuỗi | UC-016 | Không có |
| REQ-69 | So sánh giữa các cụm | UC-016 | Không có |
| REQ-70 | Quản lý tài khoản nhân viên | UC-017 | Không có |
| REQ-71 | Gán nhân viên vào cụm rạp | UC-017 | Không có |
| REQ-72 | Phân quyền theo vai trò | UC-017 | Không có |
| REQ-73 | 4.000 khách đồng thời | - | Chuyển P06 (phi chức năng) |
| REQ-74 | 1.000 khách trên một suất | - | Chuyển P06 (phi chức năng); liên quan UC-005 |
| REQ-75 | Giữ ghế trong 2 giây | UC-005 | Chuyển P06 (phi chức năng) |
| REQ-76 | Giải phóng ghế trễ nhất 1 phút | UC-005 | Chuyển P06 (phi chức năng) |
| REQ-77 | Không lưu thông tin thẻ | - | Chuyển P06 (ràng buộc) |
| REQ-78 | Lưu mã giao dịch | UC-005 | Không có |
| REQ-79 | Giao tiếp cổng thanh toán | UC-005, UC-006, UC-008 | Không có |
| REQ-80 | Giao tiếp dịch vụ email | UC-005, UC-006 | Không có |
| REQ-81 | Chuyển ghế sang đã bán khi xác nhận thu tiền | UC-005 | Không có |
| REQ-82 | Tạo vé cho ghế bán tại quầy | UC-005 | Không có |
| REQ-83 | Nhân viên quầy huỷ vé mua tại quầy | UC-008 | U-R10 b |
| REQ-84 | Vé quầy huỷ trước 2 tiếng | UC-008 | Không có |
| REQ-85 | Vé quầy hoàn 70% tiền mặt | UC-008 | Không có |
| REQ-86 | Không bán trước thời điểm mở bán | UC-005, UC-014 | Không có |
| REQ-87 | Ghế đôi tính là một ghế | UC-005, UC-012, UC-015, UC-016 | Không có |
| REQ-88 | Ghế đang chọn vẫn trống tới khi xác nhận | UC-005 | Không có |
| REQ-89 | Mỗi khách tối đa một lần giữ ghế | UC-005 | Không có |
| REQ-90 | Email thông báo hoàn tiền | UC-006 | Không có |
| REQ-91 | Cách xác định khung giờ chiếu | UC-013, UC-005 | Không có |
| REQ-92 | Mỗi nhân viên quầy tối đa một lần giữ ghế | UC-005 | Không có |
| REQ-93 | Chọn suất chiếu đang soát | UC-009 | Không có |
| REQ-94 | Báo lý do vé không hợp lệ | UC-009 | Không có |
| REQ-95 | Ngày khởi chiếu, ngày kết thúc chiếu | UC-010 | Không có |
| REQ-96 | Định nghĩa đang chiếu, sắp chiếu | UC-003 | Không có |
| REQ-97 | Ngày suất chiếu trong khoảng chiếu của phim | UC-014 | Không có |
| REQ-98 | Giờ kết thúc suất chiếu | UC-014 | Không có |
| REQ-99 | Cách tính doanh thu | UC-015, UC-016 | Không có |
| REQ-100 | Nhân viên thuộc đúng một cụm | UC-017 | Không có |
| REQ-101 | Mỗi nhân viên một vai trò | UC-017 | Không có |
| REQ-102 | Nhân viên đăng nhập | - | Tiền điều kiện của mọi UC của ACT-02 đến ACT-05, kể cả UC-005, UC-008 khi ACT-02 thực hiện (U-R01); P04 ghi ở hàng Tiền điều kiện |
| REQ-103 | Tài khoản quản trị viên có sẵn | - | Chuyển P06 (ràng buộc) |
| REQ-104 | Quản trị viên đăng nhập | - | Tiền điều kiện của UC-017 (U-R01); P04 ghi ở hàng Tiền điều kiện |
| REQ-105 | Nội dung ghi trên vé | UC-005 | Không có |
| REQ-106 | Mã đặt vé duy nhất toàn hệ thống | UC-005 | Không có |
| REQ-107 | Định dạng email | UC-001 | Không có |
| REQ-108 | Định dạng số điện thoại | UC-001 | Không có |
| REQ-109 | Không tạo vé, hoàn tiền khi thanh toán báo về sau khi huỷ giữ ghế hoặc sau khi báo thất bại | UC-006 | Không có |
| REQ-110 | Báo trùng kết quả giao dịch: không hoàn lần nữa, ghi nhận | UC-006 | Không có |
| REQ-111 | Kết quả giao dịch kèm mã giao dịch; số tiền hoàn lấy từ giao dịch hệ thống đã tạo | UC-006 | Không có |
| REQ-112 | Hoàn tiền bị từ chối: thử lại, vẫn lỗi thì xử lý thủ công, không email khách | UC-006, UC-008 | Trạng thái Loại, thay bởi REQ-131 |
| REQ-113 | Hoàn tiền không phản hồi trong 30 giây: thử lại, chống hoàn hai lần | UC-006, UC-008 | Trạng thái Loại, thay bởi REQ-132 |
| REQ-114 | Thất bại báo muộn: chỉ ghi nhận, không hoàn tiền | UC-006 | Trạng thái Loại, thay bởi REQ-133 |
| REQ-115 | Giao dịch không nhận ra hoặc lần giữ ghế đã có vé: không tạo vé, hoàn toàn bộ | UC-006 | Trạng thái Loại, thay bởi REQ-129 và REQ-130 |
| REQ-116 | Nội dung email thông báo hoàn tiền | UC-006 | Không có |
| REQ-117 | Hoàn tiền huỷ vé chưa hoàn tất: vé vẫn huỷ, ghế chưa trống | UC-008 | Trạng thái Loại, thay bởi REQ-131 |
| REQ-118 | Vé đã soát không huỷ được; huỷ và soát cùng lúc, bên ghi nhận trước thắng | UC-008, UC-009 | Không có |
| REQ-119 | Mọi lần ghế trở về trống hiện trên sơ đồ ghế trong 3 giây | UC-005, UC-008 | Không có |
| REQ-120 | Nhân viên quầy tìm vé cần huỷ bằng mã đặt vé | UC-008 | Không có |
| REQ-121 | Mốc so hạn huỷ 2 tiếng là lúc hệ thống kiểm tra | UC-008 | Không có |
| REQ-122 | Làm tròn xuống số tiền hoàn 70% | UC-008 | Không có |
| REQ-123 | Soát vé: chỉ chọn suất của cụm rạp mình, chọn một lần | UC-009 | Không có |
| REQ-124 | Soát vé: chỉ báo một lý do theo thứ tự ưu tiên | UC-009 | Không có |
| REQ-125 | Không giới hạn thời điểm soát vé | UC-009 | Không có |
| REQ-126 | Không nhập tay khi camera không đọc được mã QR | UC-009 | Không có |
| REQ-127 | Nội dung hiển thị khi soát vé | UC-009 | Không có |
| REQ-128 | Mã QR không quy định định dạng | UC-009 | Không có |
| REQ-129 | Giao dịch thành công không nhận ra: ghi log lỗi, xử lý thủ công ngoài hệ thống | UC-006 | Không có |
| REQ-130 | Giao dịch thứ hai cho lần giữ ghế đã có vé: không tạo vé, hoàn toàn bộ | UC-006 | Không có |
| REQ-131 | Hoàn tiền qua cổng lỗi sau thử lại: ghế vẫn trống, ghi log lỗi, xử lý thủ công ngoài hệ thống, không email | UC-006, UC-008 | Không có use case xử lý thủ công (ngoài phạm vi) |
| REQ-132 | Hoàn tiền không phản hồi trong 30 giây: thử lại, khoá chống hoàn trùng theo từng yêu cầu hoàn | UC-006, UC-008 | Không có |
| REQ-133 | Thất bại báo muộn, báo cho giao dịch đã có vé hoặc không nhận ra: chỉ ghi nhận | UC-006 | Không có |
| REQ-134 | Nhân viên quầy đã thu tiền mặt mà lần giữ ghế hết hạn trước khi xác nhận: từ chối xác nhận, trả lại tiền mặt; thao tác không chia cắt | UC-005 | Không có |
| REQ-135 | Ngừng bán vé từ giờ bắt đầu suất chiếu, kể cả bán tại quầy | UC-005 | Không có |
| REQ-137 | Thời điểm mở bán phải trước giờ bắt đầu suất chiếu | UC-014 | Không có |
| REQ-138 | Không lập, sửa suất chiếu sang giờ bắt đầu đã qua | UC-014 | Không có |
| REQ-139 | Suất chiếu đã tới giờ bắt đầu không sửa, xoá được | UC-014 | Không có |
| REQ-140 | Xoá suất chiếu: bỏ khỏi lịch, giữ dữ liệu cho vé đã huỷ, hoàn tiền, báo cáo | UC-014 | Không có |
| REQ-141 | Ghế quá thời điểm hết hạn giữ không còn chặn sửa, xoá suất chiếu | UC-014 | Không có |
| REQ-142 | Suất chiếu bị sửa, xoá lúc đang xem sơ đồ ghế: từ chối khi xác nhận chọn ghế | UC-005, UC-014 | Không có |
| REQ-143 | Hai quản lý cùng sửa một suất chiếu: người lưu sau bị từ chối | UC-014 | Không có |
| REQ-144 | Phim, phòng thay đổi sau khi lập suất chiếu: không tự đổi suất chiếu | UC-014 | Không có |
| REQ-145 | Không lập, sửa thành suất chiếu khi bảng giá chưa có giá cho mọi loại ghế có trong phòng, ứng với khung giờ, theo loại phòng và định dạng | UC-014 | Không có |
| REQ-146 | Bỏ mục giá, trừ mục giá đang được suất chiếu chưa tới giờ bắt đầu dùng | UC-013 | Không có |
| REQ-147 | Giá vé là số nguyên đồng lớn hơn 0, không có trần; mọi tổ hợp đặt được giá | UC-013 | Không có |
| REQ-148 | Hai yêu cầu cùng đặt hoặc bỏ giá một mục giá: người lưu sau bị từ chối | UC-013 | Không có |
| REQ-149 | Giá của lần giữ ghế chốt khi giữ ghế tới hết lần giữ; vé đã bán giữ giá | UC-013, UC-005 | Không có |
| REQ-150 | Thay đổi bảng giá có hiệu lực ngay khi lưu, không hẹn ngày | UC-013 | Không có |
| REQ-151 | Kiểm tra bảng giá và lưu suất chiếu là thao tác không chia cắt với việc bỏ giá | UC-013, UC-014 | Không có |
| REQ-152 | Bảng giá không có giá cho ghế đã chọn: từ chối giữ ghế | UC-005 | Không có |
| REQ-153 | Công thức tỉ lệ lấp đầy theo suất chiếu, ngày, phim | UC-015, UC-016 | Không có |
| REQ-162 | Không sửa sơ đồ ghế khi phòng có suất chiếu đã tới thời điểm mở bán mà chưa kết thúc | UC-012 | Không có |

## 6. Thống kê và nhận xét ngưỡng

| ACT | Số UC là tác nhân chính | Số UC là tác nhân phụ | Nhận xét |
|---|---|---|---|
| ACT-01 Khách | 6 | 0 | Trong mức 2-12 |
| ACT-02 Nhân viên quầy | 2 | 0 | Trong mức; bán vé và huỷ vé dùng chung UC với khách theo U-R10 b |
| ACT-03 Nhân viên soát vé | 1 | 0 | Một UC là đúng với nguồn: nhân viên soát vé chỉ có mục tiêu soát vé |
| ACT-04 Quản lý cụm rạp | 4 | 0 | Trong mức |
| ACT-05 Quản lý chuỗi | 3 | 0 | Trong mức |
| ACT-06 Quản trị viên | 1 | 0 | Một UC là đúng với nguồn: quản trị viên chỉ quản lý tài khoản nhân viên |
| ACT-07 Cổng thanh toán | 1 | 3 | Tác nhân chính duy nhất ở UC-006, đồng thời là tác nhân phụ thực hiện hoàn tiền trong chính UC đó |
| ACT-08 Dịch vụ email | 0 | 2 | Tác nhân phụ |

Tổng số UC: 16 User-goal, không có Subfunction; UC-002 ở trạng thái Loại không được đếm. Số UC mỗi nhóm: Bán vé 8 (gồm UC-001 Đăng ký tài khoản, là điều kiện tiên quyết của quy trình bán vé nên vẫn đứng đầu), Vận hành rạp 5, Báo cáo và quản trị 3. Nhóm Tài khoản không còn vì chỉ còn một UC, UC-001 nhập vào nhóm Bán vé. Các con số nằm trong mức hợp lý.

## Thay đổi so với phiên bản trước

| UCR | Phần tử đã đổi (UC, CAND, dòng REQ) | Thay đổi |
|---|---|---|
| Đồng bộ P04 (phiên bản 1.9) | UC-012, UC-015, UC-016 (cột REQ), REQ-03, REQ-153, REQ-162 (Mục 5) | Gắn REQ-162 và REQ-03 cho UC-012, REQ-153 cho UC-015 và UC-016; không thêm use case, giữ nguyên tên và mã các UC |
| Quy ước đã chốt (không qua P02R) | UC-002, CAND-02, CAND-03, CAND-04 | Đăng nhập không là use case: UC-002 chuyển sang Loại, các CAND đăng nhập kết luận Loại |
| Hệ quả của quy ước | REQ-12, REQ-102, REQ-104 (Mục 5) | Không còn UC phủ; ghi là tiền điều kiện của các UC ở P04 |
| Hệ quả của quy ước | UC-001 (cột Nhóm chức năng) | Chuyển từ nhóm Tài khoản sang nhóm Bán vé vì nhóm Tài khoản chỉ còn một UC |
| Hệ quả của quy ước | Mục 6 | Cập nhật số UC theo tác nhân và tổng số UC |
| UCR-01 (phiên bản 1.2) | UC-005 (Mô tả ngắn), dòng REQ-12, REQ-102 Mục 5 | Với khách, đăng nhập là điều kiện tại bước xác nhận chọn ghế của UC-005, không phải tiền điều kiện; với nhân viên quầy vẫn là tiền điều kiện |
| UCR-02 (phiên bản 1.2) | UC-002 (cột Nhóm chức năng) | Đổi từ "Tài khoản" thành "-" |
| Trả lời Q-61 đến Q-67 (phiên bản 1.8) | UC-005 (cột REQ), UC-013 (Mô tả ngắn, cột REQ), UC-014 (Mô tả ngắn, cột REQ), REQ-145 đến REQ-152 (Mục 5) | Sửa REQ-145 (thêm loại ghế, khung giờ); thêm REQ-146 đến REQ-152; UC-013 thêm bỏ giá; UC-005 thêm REQ-149, REQ-152; không thêm use case, giữ nguyên tên và mã các UC |
| Trả lời Q-52 đến Q-60 (phiên bản 1.7) | UC-005 (cột REQ), UC-014 (Mô tả ngắn, cột REQ), REQ-137 đến REQ-145 (Mục 5) | Thêm REQ-137 đến REQ-145; UC-014 thêm quy tắc mở bán, giờ bắt đầu, bảng giá, xoá giữ dữ liệu, sửa đồng thời; UC-005 thêm REQ-142; không thêm use case, giữ nguyên tên và mã các UC |
| Trả lời Q-49, Q-50 và bỏ luồng hoàn tiền mặt không thành công (phiên bản 1.6) | EV-08, UC-005 (cột REQ), REQ-131, REQ-134, REQ-135 (Mục 5) | Thêm REQ-134, REQ-135; EV-08 nêu thêm báo trùng và thất bại muộn; REQ-131 chỉ còn hoàn qua cổng thanh toán; không thêm use case, giữ nguyên tên và mã các UC |
| Quyết định sau review cuối P04 (phiên bản 1.5) | EV-08, UC-006 (Mục tiêu, Mô tả ngắn, cột REQ), UC-008 (cột REQ), REQ-112 đến REQ-117 và REQ-129 đến REQ-133 (Mục 5) | Giao dịch không nhận ra chuyển sang ghi log lỗi, xử lý thủ công ngoài hệ thống (trả lời Q-48); hoàn tiền lỗi trả ghế về trống, xử lý thủ công ngoài hệ thống; REQ-112, REQ-113, REQ-114, REQ-115, REQ-117 chuyển Loại; không thêm use case; giữ nguyên tên và mã các UC |
| Trả lời Q-27 đến Q-46 (phiên bản 1.4) | UC-006 (Mục tiêu, Mô tả ngắn, Sự kiện kích hoạt), EV-08, REQ-110 đến REQ-128 (Mục 5), cột REQ của UC-005, UC-006, UC-008, UC-009 | Thêm REQ-110 đến REQ-128 vào ma trận truy vết; mở rộng UC-006 để bao cả giao dịch hệ thống không nhận ra và lần giữ ghế đã có vé (Q-32); giữ nguyên tên và mã các UC |
| Trả lời Q-25 (phiên bản 1.3) | UC-006 (Mục tiêu, Mô tả ngắn, Sự kiện kích hoạt), EV-08, REQ-105 đến REQ-109 (Mục 5) | Mở rộng UC-006 để bao cả trường hợp thanh toán thành công báo về sau khi khách huỷ giữ ghế hoặc sau khi cổng báo thất bại; giữ nguyên tên và mã UC-006 |

## Câu hỏi mở

Q-01 đến Q-46, Q-48, Q-49 và Q-50 đã được trả lời ở P00, P01, P04 (Q-36 gộp vào Q-30, Q-47 gộp vào Q-35). Q-51 (P04 UC-006, nội dung báo của cổng cho giao dịch thứ hai) chưa trả lời và không đổi danh sách use case. Q-52 đến Q-60 (P04 UC-014) và Q-61 đến Q-67 (P04 UC-014, UC-013) đã được trả lời và không đổi danh sách use case.

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P01 | ACT-02 | Mục tiêu "Bán vé tại quầy", "Huỷ vé mua tại quầy" được phủ bởi UC-005 Đặt vé và UC-008 Huỷ vé theo U-R10 b | Giữ nguyên P01; cách gọi của người đại diện đã ghi ở Mô tả ngắn của UC-005, UC-008. Không cần chạy lại P01 |

## Vấn đề còn mở

- Xử lý thủ công khoản hoàn tiền không hoàn được và giao dịch thành công không nhận ra diễn ra ngoài hệ thống (REQ-129, REQ-131), nên không có use case của ACT-06 cho việc này và nằm ngoài phạm vi.
- UC-005 Đặt vé gộp việc khách đặt vé trực tuyến và nhân viên quầy bán vé tại quầy theo U-R10 b: hai luồng chỉ khác các bước tương ứng (thanh toán qua cổng so với thu tiền mặt và xác nhận; nhận vé qua email so với in vé), kết quả như nhau. Khác biệt được đặc tả thành luồng thay thế và BR theo vai trò ở P04. Tương tự cho UC-008 Huỷ vé.
- UC-006 có ACT-07 Cổng thanh toán vừa là tác nhân chính (gửi kết quả giao dịch trễ) vừa là tác nhân phụ (thực hiện hoàn tiền), đúng với tính chất "Chính và phụ" ở P01.
- Hết thời gian giữ ghế (EV-06) là luồng thay thế của UC-005 theo U-R07 hết giờ trong phiên, không có tác nhân thời gian (P01 Mục 4).
