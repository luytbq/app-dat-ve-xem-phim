# P01 - Xác định tác nhân - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P01 |
| Phiên bản | 1.1 |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md; P00-problem-brief.md 1.3; yeu-cau-dat-ve.md (đã bổ sung trả lời Q-23); P01-actors.md 1.0 |
| Phạm vi | Toàn hệ thống |
| Mã Q, ASM cuối đã cấp | Q-23; không có ASM (NGHIEM_NGAT) |

## 1. Ranh giới hệ thống

Hệ thống cần xây dựng là Hệ thống đặt vé xem phim CineBook: phần mềm cho khách đặt vé trực tuyến tại mọi cụm rạp và cho nhân viên các cụm rạp bán vé, soát vé, quản lý lịch chiếu trên cùng một sơ đồ ghế.

| Thành phần | Trong / Ngoài / Chờ Q-nn | Căn cứ (REQ hoặc trích nguồn, Q, ASM) | Hệ quả |
|---|---|---|---|
| Phần mềm đặt vé CineBook (giao diện cho khách, nhân viên và phần xử lý nghiệp vụ) | Trong | "Công ty cần phần mềm cho phép khách đặt vé trực tuyến tại mọi cụm rạp và giúp nhân viên bán vé tại quầy trên cùng một sơ đồ ghế" (đoạn mở đầu) | Là thành phần nội bộ, không phải tác nhân |
| Sơ đồ ghế của suất chiếu (trạng thái từng ghế) | Trong | REQ-15, REQ-46 | Là thành phần nội bộ, không phải tác nhân |
| Kho dữ liệu của hệ thống (phim, suất chiếu, vé, mã giao dịch...) | Trong | REQ-78 | Là thành phần nội bộ, không phải tác nhân |
| Cổng thanh toán của đối tác | Ngoài | REQ-79; Hồ sơ dự án: HE_THONG_NGOAI | Là tác nhân ACT-07 |
| Dịch vụ email bên ngoài | Ngoài | REQ-80; Hồ sơ dự án: HE_THONG_NGOAI | Là tác nhân ACT-08 |
| Máy tính tại quầy | Ngoài | REQ-49 ("máy in thông thường của máy tính tại quầy", Mục 12) | Ngoài, không phải tác nhân (nền tảng chạy thành phần nội bộ) |
| Máy in thông thường của máy tính tại quầy | Ngoài | REQ-49 | Ngoài, không phải tác nhân (không có giao tiếp riêng với hệ thống, nhận lệnh in qua máy tính tại quầy) |
| Thiết bị soát vé có camera | Ngoài | REQ-50 ("quét mã QR trên vé bằng camera của thiết bị", Mục 13) | Ngoài, không phải tác nhân (nền tảng chạy thành phần nội bộ; camera là kênh nhập) |
| Sơ đồ ghế giấy và việc bán vé thủ công tại quầy | Ngoài | "hai quầy cùng bán một suất chiếu trên sơ đồ ghế giấy" (đoạn mở đầu) | Ngoài, không phải tác nhân (cách làm cũ được thay thế) |

## 2. Bảng tác nhân

| ACT | Tên (VI) | Tên (EN) | Loại | Tính chất | Mô tả vai trò | Mục tiêu với hệ thống | Tổng quát hoá từ | REQ |
|---|---|---|---|---|---|---|---|---|
| ACT-01 | Khách | Customer | Người | Chính | Người xem phim dùng giao diện trực tuyến của hệ thống. Chưa đăng nhập vẫn tra cứu được phim, lịch chiếu, sơ đồ ghế; phải đăng nhập để đặt vé. Gộp các cách gọi "khách", "người khác", "nhiều khách" trong nguồn. Khách cũng là người nhận vé và thông báo hoàn tiền qua email | Tra cứu phim và lịch chiếu<br>Đăng ký tài khoản<br>Đặt vé và thanh toán trực tuyến<br>Xem lịch sử đặt vé<br>Huỷ vé đã mua | - | REQ-05 đến REQ-14, REQ-18, REQ-21, REQ-25, REQ-27, REQ-28, REQ-33, REQ-39, REQ-40, REQ-88, REQ-89 |
| ACT-02 | Nhân viên quầy | Box Office Clerk | Người | Chính | Nhân viên thuộc một cụm rạp, bán vé trực tiếp cho khách tại quầy trên cùng sơ đồ ghế với khách đặt trực tuyến, thu tiền mặt và in vé | Bán vé tại quầy<br>Huỷ vé mua tại quầy | - | REQ-45 đến REQ-49, REQ-81 đến REQ-85, REQ-92, REQ-100, REQ-102 |
| ACT-03 | Nhân viên soát vé | Ticket Checker | Người | Chính | Nhân viên thuộc một cụm rạp, quét mã QR trên vé trước cửa phòng chiếu bằng thiết bị có camera | Soát vé vào phòng chiếu | - | REQ-50, REQ-51, REQ-52, REQ-93, REQ-94, REQ-100, REQ-102 |
| ACT-04 | Quản lý cụm rạp | Cinema Manager | Người | Chính | Nhân viên quản lý một cụm rạp, chịu trách nhiệm phòng chiếu, bảng giá và lịch chiếu của cụm mình | Quản lý phòng chiếu và sơ đồ ghế<br>Thiết lập bảng giá của cụm rạp<br>Lập lịch suất chiếu<br>Xem báo cáo doanh thu và tỉ lệ lấp đầy của cụm rạp | - | REQ-56 đến REQ-67, REQ-86, REQ-97, REQ-98, REQ-100, REQ-102 |
| ACT-05 | Quản lý chuỗi | Chain Manager | Người | Chính | Nhân viên quản lý toàn chuỗi, không thuộc cụm rạp nào; quản lý danh mục phim, cụm rạp và theo dõi kết quả của toàn chuỗi | Quản lý danh sách phim<br>Quản lý danh sách cụm rạp<br>Xem và so sánh báo cáo toàn chuỗi | - | REQ-53, REQ-54, REQ-55, REQ-68, REQ-69, REQ-95, REQ-96, REQ-100, REQ-102 |
| ACT-06 | Quản trị viên | Administrator | Người | Chính | Người quản trị tài khoản nhân viên của chuỗi: tạo tài khoản, gán cụm rạp, phân vai trò. Tài khoản quản trị viên có sẵn khi cài đặt hệ thống, không do ai tạo qua hệ thống (đã trả lời Q-23) | Quản lý tài khoản nhân viên<br>Gán nhân viên vào cụm rạp<br>Phân quyền nhân viên theo vai trò | - | REQ-70, REQ-71, REQ-72, REQ-101, REQ-103, REQ-104 |
| ACT-07 | Cổng thanh toán | Payment Gateway | Hệ thống ngoài | Chính và phụ | Hệ thống thanh toán trực tuyến của đối tác, giao tiếp qua API (môi trường sandbox theo hồ sơ dự án). Phụ khi hệ thống gọi tạo giao dịch, hoàn tiền; chính khi tự gửi kết quả giao dịch (callback) vào thời điểm do nó quyết định, kể cả sau khi đã hết hạn giữ ghế | Cung cấp: tạo giao dịch thanh toán, hoàn tiền<br>Báo kết quả giao dịch về hệ thống (callback) | - | REQ-28, REQ-29, REQ-34, REQ-35, REQ-43, REQ-79 |
| ACT-08 | Dịch vụ email | Email Service | Hệ thống ngoài | Phụ | Dịch vụ gửi email bên ngoài (SMTP theo hồ sơ dự án) | Cung cấp: gửi email chứa vé, email thông báo hoàn tiền tới khách | - | REQ-31, REQ-80, REQ-90 |

## 3. Bên liên quan không phải tác nhân

| SH | Bên liên quan | Lợi ích hoặc mối quan tâm với hệ thống | Tương tác gián tiếp qua (ACT hoặc kênh) | REQ |
|---|---|---|---|---|
| SH-01 | Công ty CineBook | Bán vé trực tuyến tại mọi cụm rạp, chấm dứt bán trùng ghế, nắm doanh thu và tỉ lệ lấp đầy | Báo cáo do ACT-04 Quản lý cụm rạp và ACT-05 Quản lý chuỗi xem | Đoạn mở đầu, REQ-66 đến REQ-69 |
| SH-06 | Khách mua vé tại quầy | Mua được ghế mong muốn, nhận vé in, huỷ vé và nhận lại tiền mặt | ACT-02 Nhân viên quầy | REQ-45, REQ-47, REQ-83 đến REQ-85 |

## 4. Ứng viên tác nhân bị loại

| Ứng viên | Lý do loại | REQ |
|---|---|---|
| Khách chưa đăng nhập | Gộp vào ACT-01 Khách: cùng một người, đăng nhập là điều kiện để dùng một số chức năng chứ không phải vai trò khác | REQ-05, REQ-12, REQ-13 |
| "Người khác", "nhiều khách cùng lúc" | Gộp vào ACT-01 Khách: là các khách khác cùng thao tác trên một suất chiếu | REQ-18, REQ-27 |
| Nhân viên (cách gọi chung) | A-T3: tên chung cho bốn vai trò có mục tiêu khác nhau, đã tách thành ACT-02 đến ACT-05. Không tạo tác nhân cha vì phần chung của bốn vai trò chỉ là đăng nhập, không phải nhóm mục tiêu chung (Bước 5a) | REQ-72, REQ-100, REQ-101, REQ-102 |
| Bộ định thời (hết 10 phút giữ ghế khi đặt vé trực tuyến) | Bước 2.3: hết giờ chờ trong phiên, là luồng thay thế của use case đặt vé (chờ thanh toán) | REQ-22, REQ-32, REQ-76 |
| Bộ định thời (hết 10 phút giữ ghế khi bán tại quầy) | Bước 2.3: hết giờ chờ trong phiên, là luồng thay thế của use case bán vé tại quầy | REQ-46 |
| Máy tính tại quầy | A-T4: nền tảng chạy giao diện của hệ thống, không có mục tiêu hay dịch vụ riêng | REQ-49 |
| Máy in thông thường của máy tính tại quầy | A-T2: không có giao tiếp riêng với hệ thống, nhận lệnh in qua máy tính tại quầy | REQ-49 |
| Thiết bị soát vé | A-T4: nền tảng chạy giao diện của hệ thống, không có mục tiêu hay dịch vụ riêng | REQ-50 |
| Camera của thiết bị soát vé | A-T2: kênh nhập gắn liền thiết bị soát vé; người thao tác là ACT-03 | REQ-50 |
| Cơ sở dữ liệu của hệ thống | A-T1: thành phần nội bộ | REQ-78 |
| Sơ đồ ghế giấy, quầy bán vé thủ công | A-T1, A-T4: cách làm cũ được thay thế | Đoạn mở đầu |
| Khách mua vé tại quầy | A-T2: chỉ tương tác qua ACT-02 Nhân viên quầy (xếp vào Mục 3) | REQ-45, REQ-47 |
| Công ty CineBook | A-T2: không thao tác trên hệ thống (xếp vào Mục 3) | Đoạn mở đầu |
| Đối tác sở hữu cổng thanh toán | Gộp vào ACT-07 Cổng thanh toán: tổ chức đối tác chỉ tương tác qua hệ thống của mình | REQ-79 |

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ |
|---|---|---|---|
| Q-23 | Đã trả lời (Tài khoản quản trị viên có sẵn khi cài đặt hệ thống, không do ai tạo qua hệ thống), đề bài bổ sung Mục 18, P00 tạo REQ-103, REQ-104. Quản trị viên có đăng nhập bằng tài khoản như nhân viên không, và tài khoản quản trị viên do ai tạo? (Quản trị viên là một vai trò nhân viên, đăng nhập như nhân viên / Tài khoản quản trị viên có sẵn khi cài đặt hệ thống, không do ai tạo qua hệ thống) | ACT-06; REQ-70 đến REQ-72, REQ-102; tác nhân của use case đăng nhập ở P02 | Mục 18 chỉ nói "Nhân viên đăng nhập bằng tài khoản do quản trị viên tạo" và không liệt kê quản trị viên trong các vai trò |

## Đề xuất sửa artifact trước

Không có

## Vấn đề còn mở

- REQ-32 (giải phóng ghế khi hết thời gian giữ) không có tác nhân khởi xướng riêng. Theo Bước 2.3, việc hết hạn là luồng thay thế của use case đặt vé của ACT-01 Khách và use case bán vé tại quầy của ACT-02 Nhân viên quầy; REQ-76 (độ trễ giải phóng) là yêu cầu phi chức năng của luồng đó.
- REQ-18 (cập nhật sơ đồ ghế) do hệ thống thực hiện trong phiên xem sơ đồ ghế của ACT-01 Khách; không có tác nhân khởi xướng riêng.
