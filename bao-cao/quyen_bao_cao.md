<!-- @doc
title: "Báo cáo Project II - CineBook"
author: "Bùi Quốc Luýt"
-->
<!-- @config
page:
  size: A4
  margin: 2.5
body:
  font: "Times New Roman"
  size: 13
  line_spacing: 1.5
image:
  caption: false
table:
  header:
    size: 13
    bold: true
  row:
    size: 13
-->
<!-- @footer center="{page}" skip_on_first_page=true -->


<!-- @style align=center /-->
**ĐẠI HỌC BÁCH KHOA HÀ NỘI**

<!-- @style align=center /-->
**TRƯỜNG CÔNG NGHỆ THÔNG TIN VÀ TRUYỀN THÔNG**

<!-- @style align=center /-->
![Bách Khoa](hust-logo.png)

<!-- @style align=center /-->
**BÁO CÁO BÀI TẬP LỚN**

<!-- @style align=center /-->
**PHÂN TÍCH VÀ THIẾT KẾ HỆ THỐNG**

<!-- @style align=center /-->
# XÂY DỰNG HỆ THỐNG ĐẶT VÉ XEM PHIM TRỰC TUYẾN CHO CHUỖI RẠP (CINEBOOK)

<br>

| | |
|---|---|
| **GVHD** | Thầy Phạm Quang Hiếu |
| **Học phần** | Project II |
| **Lớp** | VB2CQ CNTT K69 |
| **Sinh viên** | 202490069: Bùi Quốc Luýt |

<br>

<!-- @style align=center /-->
*Hà Nội, 2026*


<!-- @pagebreak -->

## Lời nói đầu

Một chuỗi rạp chiếu phim có hàng trăm suất chiếu mỗi ngày và hàng chục nghìn ghế. Vào giờ mở bán một bộ phim bom tấn, hàng nghìn người cùng muốn chọn đúng một số ít ghế đẹp của cùng một suất chiếu. Bài toán khó của một hệ thống đặt vé vì thế không nằm ở việc hiển thị phim hay tính tiền, mà ở chỗ bảo đảm rằng mỗi ghế chỉ bán cho đúng một người, kể cả khi các yêu cầu đến cùng lúc, khi cổng thanh toán báo kết quả trễ hoặc báo trùng, và khi một tiến trình bị dừng giữa chừng.

Báo cáo này trình bày toàn bộ quá trình **phân tích và thiết kế hệ thống** cho đề tài "Xây dựng hệ thống đặt vé xem phim trực tuyến cho chuỗi rạp (CineBook)", theo phương pháp phân tích thiết kế hướng đối tượng đang được giảng dạy tại Trường Công nghệ Thông tin và Truyền thông, Đại học Bách Khoa Hà Nội. Đây là báo cáo của học phần Project II: phạm vi dừng ở phân tích và thiết kế, chưa viết mã; phần cài đặt dành cho Project III. Trọng tâm của đề tài là **xử lý tranh chấp tài nguyên và đồng thời**, được dành riêng một chương (Chương 5) và là sợi chỉ xuyên suốt các chương còn lại.

Em xin chân thành cảm ơn thầy Phạm Quang Hiếu đã hướng dẫn và góp ý trong suốt quá trình thực hiện đề tài. Do thời gian và kinh nghiệm còn hạn chế, báo cáo không tránh khỏi thiếu sót; em rất mong nhận được nhận xét của thầy để hoàn thiện hơn.

*Sinh viên thực hiện - Bùi Quốc Luýt*

<!-- @pagebreak -->

<!-- @style align=center bold size=16 /-->
MỤC LỤC

<!-- @toc levels=1-3 -->

<!-- @pagebreak -->

## Danh mục thuật ngữ và viết tắt

| Thuật ngữ / Viết tắt | Giải thích |
|---|---|
| UML (Unified Modeling Language) | Ngôn ngữ mô hình hóa thống nhất, dùng để đặc tả và thiết kế hệ thống hướng đối tượng |
| UC (Use Case) | Ca sử dụng: một chức năng hệ thống cung cấp cho tác nhân |
| REQ | Yêu cầu nguồn, đánh mã REQ-01 đến REQ-162 khi chuẩn hóa đề bài |
| FR / NFR | Yêu cầu chức năng / yêu cầu phi chức năng |
| BR (Business Rule) | Quy tắc nghiệp vụ, đánh mã BR-01 đến BR-147 |
| BCE (Boundary - Control - Entity) | Mẫu phân lớp phân tích: lớp biên, lớp điều khiển, lớp thực thể |
| EX | Đơn vị loại trừ: một thao tác không chia cắt (một giao dịch) cần khóa một tập đối tượng theo thứ tự cố định; có 22 đơn vị EX-01 đến EX-22 |
| Hạng khóa | Số thứ tự của loại đối tượng trong thứ tự lấy khóa toàn cục (14 hạng, 0 đến 13), dùng để loại trừ deadlock |
| Race condition | Lỗi phụ thuộc thứ tự đến của các thao tác đồng thời |
| Deadlock | Các giao dịch chờ khóa của nhau theo chu trình; PostgreSQL báo mã 40P01 |
| Giữ ghế (SeatHold) | Lần giữ tạm một nhóm ghế cho một người trong 10 phút |
| IPN (Instant Payment Notification) | Thông báo kết quả giao dịch do máy chủ của cổng thanh toán gọi về hệ thống |
| VNPay sandbox | Môi trường thử nghiệm của cổng thanh toán VNPay |
| Idempotent | Xử lý lặp lại cùng một yêu cầu cho cùng kết quả, không gây tác dụng phụ lần hai |
| Khóa chống hoàn trùng | Khóa idempotency của yêu cầu hoàn tiền, ổn định qua mọi lần thử lại |
| Outbox | Bảng hàng đợi ghi cùng giao dịch nghiệp vụ, tiến trình nền đọc rồi gửi ra hệ thống ngoài |
| claim_token | Mã ngẫu nhiên một bản backend đặt khi nhận một dòng outbox; chỉ bên giữ mã hợp lệ mới được gọi cổng |
| Advisory lock (khóa tư vấn) | Khóa ứng dụng của PostgreSQL theo giá trị tùy ý, dùng để khóa đối tượng chưa tồn tại (email, tên) |
| SKIP LOCKED / NOWAIT | Tùy chọn khóa dòng của PostgreSQL: bỏ qua dòng đang bị khóa / báo lỗi ngay thay vì chờ |
| EXCLUDE | Ràng buộc loại trừ của PostgreSQL, dùng để cấm hai suất chiếu chồng giờ cùng phòng |
| SSE (Server-Sent Events) | Kênh đẩy một chiều từ máy chủ đến trình duyệt qua HTTP, dùng cập nhật sơ đồ ghế |
| SPA (Single Page Application) | Ứng dụng web một trang chạy trên trình duyệt (React) |
| ERD (Entity Relationship Diagram) | Biểu đồ thực thể - liên kết |
| TC (Test Case) | Ca kiểm thử, đánh mã TC-001 đến TC-895 |
| DC | Lớp thiết kế (Design Class), phân biệt với AC là lớp phân tích (Analysis Class) |

<!-- @pagebreak -->

# Chương 1. Khảo sát hiện trạng và Mô tả bài toán

Chương này trình bày bối cảnh của chuỗi rạp CineBook, hiện trạng bán vé, các vấn đề tồn tại, công nghệ dự kiến cho Project III, mục tiêu - phạm vi và các tác nhân của hệ thống. Đây là cơ sở để phân tích yêu cầu ở Chương 2.

## 1.1. Giới thiệu đề tài

Công ty CineBook vận hành chuỗi 15 cụm rạp chiếu phim tại 5 tỉnh, thành phố. Mỗi cụm rạp có từ 4 đến 12 phòng chiếu; mỗi phòng thuộc một trong ba loại (phòng thường, 4DX, IMAX) với sức chứa từ 50 đến 400 ghế. Toàn chuỗi chiếu khoảng 500 suất mỗi ngày.

Đề tài xây dựng hệ thống CineBook cho phép khách đặt vé trực tuyến tại mọi cụm rạp, đồng thời giúp nhân viên từng cụm rạp bán vé tại quầy và soát vé trên cùng một sơ đồ ghế. Nguồn yêu cầu là một bản mô tả nghiệp vụ gồm 22 mục; khi chuẩn hóa, bản mô tả này được tách thành 162 yêu cầu nguồn (REQ-01 đến REQ-162) để truy vết xuyên suốt các bước phân tích và thiết kế.

## 1.2. Khảo sát hiện trạng nghiệp vụ

### 1.2.1. Quy trình bán vé hiện tại

Hiện nay khách chỉ mua vé tại quầy của từng cụm rạp. Quy trình thực tế như sau:

1. Khách đến quầy, hỏi phim và suất chiếu còn chỗ.
2. Nhân viên đối chiếu sơ đồ ghế giấy của suất chiếu, chọn ghế cùng khách và thu tiền.
3. Nhân viên đánh dấu ghế đã bán trên sơ đồ giấy và in hoặc viết vé.
4. Khách vào rạp; nhân viên soát vé kiểm vé bằng mắt.

### 1.2.2. Các vấn đề tồn tại

| Vấn đề | Biểu hiện | Hệ quả |
|---|---|---|
| Bán trùng ghế | Hai quầy cùng bán một suất chiếu trên sơ đồ ghế giấy, không có nguồn sự thật chung | Hai khách cùng có vé cho một ghế, phát sinh tranh cãi và đền bù |
| Hàng chờ dài | Dịp phim bom tấn ra mắt, mọi khách đều phải đến quầy | Mất khách, quá tải nhân viên |
| Không mua được từ xa | Khách không thể xem lịch chiếu và giữ chỗ trước | Mất doanh thu từ nhóm khách muốn đặt trước |
| Soát vé thủ công | Kiểm vé bằng mắt, vé có thể bị dùng lại hoặc vé đã hủy vẫn được vào | Gian lận, thất thoát |
| Hoàn tiền và hủy vé không nhất quán | Mỗi quầy xử lý một kiểu, không đối chiếu được với tiền đã thu | Sai lệch doanh thu |
| Báo cáo chậm | Doanh thu và tỉ lệ lấp đầy tổng hợp thủ công | Quản lý chuỗi khó so sánh giữa các cụm |

Từ đó rút ra yêu cầu cốt lõi: một nguồn sự thật duy nhất về trạng thái từng ghế của từng suất chiếu, dùng chung cho kênh trực tuyến và kênh quầy, và bảo đảm đúng ngay cả khi hàng nghìn yêu cầu đến đồng thời.

## 1.3. Công nghệ dự kiến cho Project III

Công nghệ được chốt từ đầu để thiết kế bám sát khả năng của nền tảng, đặc biệt ở phần khóa và giao dịch.

| Thành phần | Lựa chọn | Lý do chính |
|---|---|---|
| Back-end | Go (net/http của thư viện chuẩn, driver pgx) | Goroutine nhẹ cho hàng nghìn kết nối đẩy giữ lâu; thư viện chuẩn đủ dùng, không cần framework nặng |
| Front-end | React, ứng dụng một trang (SPA), giao diện thích ứng từ 360 pixel | Một mã nguồn cho khách, nhân viên quầy, nhân viên soát vé (camera trên trình duyệt) và quản lý |
| Cơ sở dữ liệu | PostgreSQL 15 trở lên (bộ kiểm thử chạy trên PostgreSQL 16) | Có khóa dòng FOR SHARE, FOR NO KEY UPDATE, SKIP LOCKED, NOWAIT, khóa tư vấn, ràng buộc EXCLUDE; thay được Redis và hàng đợi tin nhắn |
| Thanh toán | VNPay sandbox: chuyển hướng trình duyệt sang URL có chữ ký HMAC-SHA512, nhận IPN, gọi API hoàn tiền | Cổng phổ biến tại Việt Nam, có môi trường thử |
| Email | SMTP | Thư viện chuẩn của Go hỗ trợ |
| Cập nhật sơ đồ ghế | Server-Sent Events | Chỉ cần một chiều từ máy chủ đến trình duyệt, chạy trên HTTP thường |

Hệ thống không dùng Redis và không dùng hàng đợi tin nhắn ngoài: khóa, hàng đợi gửi (outbox), bộ hẹn giờ và luồng sự kiện đổi ghế đều đặt trong PostgreSQL. Lý do là một nguồn sự thật duy nhất cho mọi thao tác không chia cắt (Chương 4 và Chương 5).

## 1.4. Mục tiêu và phạm vi

### 1.4.1. Mục tiêu

- Cho phép khách xem phim, lịch chiếu, sơ đồ ghế không cần đăng nhập; đăng nhập để giữ ghế, thanh toán trực tuyến và nhận vé có mã QR qua email.
- Cho phép nhân viên quầy bán vé tiền mặt và hủy vé mua tại quầy trên cùng sơ đồ ghế với kênh trực tuyến.
- Cho phép nhân viên soát vé quét mã QR, mỗi vé chỉ vào một lần.
- Hỗ trợ quản lý chuỗi, quản lý cụm rạp và quản trị viên quản lý phim, cụm rạp, phòng chiếu, bảng giá, suất chiếu, tài khoản nhân viên và xem báo cáo.
- Bảo đảm không ghế nào bị giữ hoặc bán cho hai người; giữ ghế trong 10 phút và tự giải phóng; xử lý đúng thanh toán đến trễ, đến trùng và hoàn tiền không trùng.

### 1.4.2. Phạm vi

| Trong phạm vi | Ngoài phạm vi |
|---|---|
| Tra cứu phim, lịch chiếu; đăng ký tài khoản khách | Đăng nhập không được mô hình hóa thành use case, chỉ là tiền điều kiện |
| Đặt vé trực tuyến và bán vé tại quầy, giữ ghế, thanh toán, gửi vé | Xử lý thủ công các khoản hoàn không hoàn được và giao dịch thành công mà hệ thống không nhận ra: hệ thống chỉ ghi log lỗi |
| Hoàn tiền thanh toán trễ, hủy vé và hoàn 70% giá vé | Cổng thanh toán và dịch vụ email: là hệ thống ngoài, chỉ gọi qua API |
| Soát vé bằng mã QR | Máy in vé chuyên dụng: dùng chức năng in của trình duyệt |
| Quản lý phim, cụm rạp, phòng chiếu và sơ đồ ghế, bảng giá, lịch suất chiếu | Soát vé bằng cách nhập tay khi camera không đọc được mã QR (cố ý không có) |
| Báo cáo doanh thu và tỉ lệ lấp đầy theo cụm rạp và toàn chuỗi | Cài đặt mã nguồn (thuộc Project III) |
| Quản lý tài khoản nhân viên, phân quyền | |

## 1.5. Mô tả nghiệp vụ

Quy trình nghiệp vụ trung tâm là **đặt vé**. Khách chọn suất chiếu đã mở bán, xem sơ đồ ghế, chọn tối đa 8 ghế rồi xác nhận; hệ thống giữ cả nhóm ghế trong 10 phút hoặc không giữ ghế nào. Trong thời gian giữ, khách thanh toán qua cổng; khi cổng báo thành công, ghế chuyển sang đã bán, hệ thống tạo mã đặt vé, mỗi ghế một vé có mã QR và gửi email. Quá 10 phút, hủy giữ ghế hoặc thanh toán thất bại thì ghế trở về trống. Nhân viên quầy dùng cùng quy trình nhưng thu tiền mặt thay cho cổng thanh toán. Hình dưới là biểu đồ hoạt động của quy trình này.

![Hình 1.1. Biểu đồ hoạt động quy trình đặt vé (UC-005).](diagrams/hinh-1-1-activity-uc005.png =444x)

<!-- @style align=center italic /-->
*Hình 1.1. Biểu đồ hoạt động quy trình đặt vé (UC-005).*

Ba quy trình còn lại gắn với đặt vé: thanh toán báo trễ phải hoàn tiền, hủy vé trước giờ chiếu 2 tiếng được hoàn 70% giá vé, và soát vé tại cửa phòng chiếu. Các quy trình này được phân tích ở Chương 2.

## 1.6. Tác nhân (Actors)

Hệ thống có tám tác nhân: sáu người và hai hệ thống ngoài.

<!-- @style align=center italic /-->
*Bảng 1.1. Danh sách tác nhân của hệ thống.*

| Mã | Tác nhân | Vai trò |
|---|---|---|
| ACT-01 | Khách | Xem phim, lịch chiếu, sơ đồ ghế không cần đăng nhập; đăng ký, đặt vé, xem lịch sử, hủy vé mua trực tuyến |
| ACT-02 | Nhân viên quầy | Thuộc một cụm rạp; bán vé tại quầy thu tiền mặt, hủy vé mua tại quầy |
| ACT-03 | Nhân viên soát vé | Thuộc một cụm rạp; quét mã QR của vé trước cửa phòng chiếu |
| ACT-04 | Quản lý cụm rạp | Quản lý phòng chiếu, sơ đồ ghế, bảng giá, lịch suất chiếu và báo cáo của cụm mình |
| ACT-05 | Quản lý chuỗi | Không thuộc cụm rạp nào; quản lý phim, cụm rạp, xem và so sánh báo cáo toàn chuỗi |
| ACT-06 | Quản trị viên | Quản lý tài khoản nhân viên, gán cụm rạp, phân vai trò; tài khoản có sẵn khi cài đặt |
| ACT-07 | Cổng thanh toán | Hệ thống ngoài: tạo giao dịch, báo kết quả (IPN), hoàn tiền; là tác nhân chính của UC-006 và phụ của UC-005, UC-008 |
| ACT-08 | Dịch vụ email | Hệ thống ngoài: gửi email chứa vé và email thông báo hoàn tiền |

Máy in của máy tính tại quầy và camera của thiết bị soát vé không phải tác nhân vì không có giao tiếp riêng với phần mềm: máy in nhận lệnh in qua trình duyệt, camera chỉ là kênh nhập của màn hình soát vé.


<!-- @pagebreak -->

# Chương 2. Phân tích yêu cầu

Chương này chuẩn hóa yêu cầu thành yêu cầu chức năng và phi chức năng, tuyển chọn các quy tắc nghiệp vụ tiêu biểu, xác định 16 use case và đặc tả chi tiết bốn use case quan trọng nhất của trọng tâm đồng thời: đặt vé (gồm giữ ghế, thanh toán VNPay và bán vé tại quầy), hoàn tiền thanh toán trễ, hủy vé và soát vé. Các use case còn lại được đặc tả tóm tắt.

## 2.1. Yêu cầu chức năng (FR)

Đề bài được chuẩn hóa thành 162 yêu cầu nguồn (REQ-01 đến REQ-162), gom thành các nhóm chức năng dưới đây. Mỗi nhóm được truy vết đến use case ở mục 2.4.

<!-- @style align=center italic /-->
*Bảng 2.1. Các nhóm yêu cầu chức năng.*

| Mã | Nhóm yêu cầu | REQ tiêu biểu | Use case |
|---|---|---|---|
| FR-01 | Xem phim, thông tin phim, lịch chiếu và lọc theo tỉnh, ngày, loại phòng, định dạng, không cần đăng nhập | REQ-05 đến REQ-10 | UC-003, UC-004 |
| FR-02 | Đăng ký, đăng nhập tài khoản khách bằng email hoặc số điện thoại | REQ-11, REQ-12 | UC-001 (đăng nhập là tiền điều kiện) |
| FR-03 | Xem sơ đồ ghế ba trạng thái, tự cập nhật trong 3 giây; chọn tối đa 8 ghế; giữ ghế tạm 10 phút, tất cả hoặc không ghế nào | REQ-13 đến REQ-27, REQ-87 đến REQ-89 | UC-005 |
| FR-04 | Thanh toán trực tuyến, tạo mã đặt vé, vé có mã QR, gửi vé qua email | REQ-28 đến REQ-31 | UC-005 |
| FR-05 | Giải phóng ghế khi hết hạn, khách hủy, thanh toán thất bại; xử lý thanh toán đến trễ và hoàn toàn bộ | REQ-32 đến REQ-36, REQ-90 | UC-005, UC-006 |
| FR-06 | Giá vé theo bảng giá riêng từng cụm rạp (loại phòng, định dạng, loại ghế, khung giờ) | REQ-37, REQ-38, REQ-91 | UC-005, UC-013 |
| FR-07 | Xem lịch sử đặt vé; hủy từng vé trước giờ chiếu 2 tiếng, hoàn 70% | REQ-39 đến REQ-44 | UC-007, UC-008 |
| FR-08 | Bán vé tại quầy tiền mặt, in vé, hủy vé mua tại quầy | REQ-45 đến REQ-49, REQ-81 đến REQ-85, REQ-92 | UC-005, UC-008 |
| FR-09 | Soát vé bằng mã QR, mỗi vé chỉ một lần, báo một lý do theo thứ tự cụm rạp, suất chiếu, đã dùng, đã hủy | REQ-50 đến REQ-52, REQ-93, REQ-94 | UC-009 |
| FR-10 | Quản lý phim, cụm rạp | REQ-53 đến REQ-55, REQ-95, REQ-96 | UC-010, UC-011 |
| FR-11 | Quản lý phòng chiếu, sơ đồ ghế, bảng giá | REQ-56 đến REQ-59, REQ-146 đến REQ-150, REQ-152 | UC-012, UC-013 |
| FR-12 | Lập lịch suất chiếu, thời điểm mở bán, không chồng giờ | REQ-60 đến REQ-65, REQ-86, REQ-135, REQ-137 đến REQ-145, REQ-151 | UC-014 |
| FR-13 | Báo cáo doanh thu và tỉ lệ lấp đầy theo ngày, phim, suất chiếu; so sánh giữa cụm rạp | REQ-66 đến REQ-69, REQ-99 | UC-015, UC-016 |
| FR-14 | Quản lý tài khoản nhân viên, gán cụm rạp, phân quyền theo vai trò | REQ-70 đến REQ-72, REQ-100 đến REQ-104 | UC-017 |

## 2.2. Yêu cầu phi chức năng (NFR)

Đặc tả bổ sung ghi 18 NFR đo được (NFR-01 đến NFR-18), phân theo FURPS+. Bảng dưới tóm tắt, mỗi NFR đều có tiêu chí đo và mức đạt trong tài liệu nguồn.

<!-- @style align=center italic /-->
*Bảng 2.2. Yêu cầu phi chức năng và mức đạt.*

| Mã | Nhóm | Phát biểu | Mức đạt |
|---|---|---|---|
| NFR-01 đến NFR-03 | Chức năng | Khách, nhân viên, quản trị viên đăng nhập được | Đăng nhập bằng email hoặc số điện thoại; tài khoản nhân viên do quản trị viên tạo |
| NFR-04 | Hiệu năng | 4.000 khách đồng thời toàn chuỗi vào giờ mở bán | Ít nhất 99% thao tác thành công không do lỗi hệ thống; không ghế nào bị giữ hoặc bán hai lần |
| NFR-05 | Hiệu năng | 1.000 khách cùng thao tác trên một suất chiếu | Như NFR-04; giữ ghế tất cả hoặc không; số ghế giữ cộng số ghế bán không vượt sức chứa |
| NFR-06 | Hiệu năng | Giữ ghế trả kết quả không quá 2 giây | Tải thường: mọi lần; tải đỉnh: 95% lần; kể cả kết quả từ chối |
| NFR-07 | Hiệu năng | Ghế hết hạn giải phóng không quá 1 phút sau hạn | Mọi lần, cả tải thường và tải đỉnh |
| NFR-08, NFR-09 | Hiệu năng | Sơ đồ ghế phản ánh ghế đổi trạng thái chậm nhất 3 giây | Tải thường: mọi lần; tải đỉnh: 95% lần |
| NFR-10 | Bảo mật | Không lưu thông tin thẻ thanh toán | Chỉ lưu mã giao dịch do cổng cấp |
| NFR-11 | Ràng buộc | Ứng dụng web thích ứng, từ 360 pixel; soát vé qua HTTPS có camera | Chrome, Edge, Firefox, Safari bản mới nhất |
| NFR-12 | Ràng buộc | Tài khoản quản trị viên có sẵn khi cài đặt, không tạo qua hệ thống | Đúng một tài khoản |
| NFR-13, NFR-14 | Ràng buộc | Soát vé không có cách nhập tay; mã QR không có định dạng quy định | Hệ thống tự xác định vé từ mã |
| NFR-15 đến NFR-17 | Giao tiếp | Tạo giao dịch, nhận kết quả (IPN) và hoàn tiền với cổng thanh toán | Kiểm thử tích hợp trên sandbox; thời gian chờ 30 giây |
| NFR-18 | Giao tiếp | Gửi email vé và email hoàn tiền qua dịch vụ email | Lỗi gửi không làm mất hiệu lực của vé hay khoản hoàn |

Các NFR hiệu năng NFR-04 đến NFR-09 là động lực kiến trúc của hệ thống: chúng buộc thiết kế khóa hẹp, giao dịch ngắn, bộ hẹn giờ giải phóng ghế và kênh đẩy sơ đồ ghế (Chương 4 và 5).

## 2.3. Quy tắc nghiệp vụ tiêu biểu

Sổ quy tắc nghiệp vụ gồm 121 mã BR (BR-01 đến BR-147), trong đó 113 đang hiệu lực, 3 gộp vào quy tắc khác và 5 bị loại. Bảng dưới trích các quy tắc quyết định thiết kế tranh chấp.

<!-- @style align=center italic /-->
*Bảng 2.3. Quy tắc nghiệp vụ tiêu biểu.*

| Mã | Quy tắc | Hệ quả thiết kế |
|---|---|---|
| BR-04 | Mỗi khách và mỗi nhân viên quầy có tối đa một lần giữ ghế chưa kết thúc | Khóa dòng người giữ ghế; chỉ mục unique từng phần |
| BR-05, BR-06 | Tối đa 8 ghế mỗi lần giữ; ghế đôi tính một ghế | Kiểm trong thao tác giữ ghế |
| BR-07, BR-09 | Giữ ghế thành công khi tất cả ghế còn trống; một ghế chỉ bán cho một người | Khóa ghế theo thứ tự cố định; ràng buộc unique ở CSDL |
| BR-10 | Giữ tạm 10 phút, áp dụng cả bán tại quầy | Hạn giữ tính từ đồng hồ CSDL, hết hạn là sự thật được tính |
| BR-14, BR-15 | Thanh toán thành công báo sau hạn, sau khi khách hủy giữ ghế hoặc sau thất bại: không tạo vé, hoàn toàn bộ | Quyết định dưới khóa lần giữ ghế |
| BR-18, BR-19 | Hủy vé trước giờ chiếu ít nhất 2 tiếng; hoàn 70% giá vé, làm tròn xuống đồng | Kiểm thời điểm tại lúc hệ thống xử lý |
| BR-24, BR-30 | Vé chỉ soát một lần; hủy và soát cùng lúc thì bên ghi nhận trước thành công | Khóa dòng vé, cập nhật có điều kiện trạng thái |
| BR-37 | Mỗi giao dịch thành công chỉ xử lý một lần; báo trùng không hoàn thêm | IPN idempotent, cờ đã xử lý dưới khóa |
| BR-41 | Cổng từ chối hoặc không trả lời hoàn tiền thì thử lại vài lần; vẫn lỗi thì ghi log, xử lý thủ công, không email khách | Outbox, tối đa 4 lần gửi |
| BR-42 | Ghế của vé hủy trả về trống kể cả khi hoàn tiền thất bại | Hủy vé, trả ghế và tạo yêu cầu hoàn trong một giao dịch |
| BR-43 | Mọi lần thử lại của một yêu cầu hoàn dùng lại cùng khóa chống hoàn trùng | Khóa gắn mã giao dịch và mã vé hoặc loại yêu cầu |
| BR-44 | Xác nhận thu tiền mặt sau hạn bị từ chối, nhân viên trả lại tiền | Cùng khóa SeatHold với hết hạn và IPN |
| BR-45 | Từ giờ bắt đầu suất chiếu ngừng nhận lần giữ ghế mới | Kiểm trong thao tác giữ ghế |
| BR-51, BR-52 | Suất chiếu cùng phòng không chồng giờ, có thời gian dọn phòng 15 phút | Ràng buộc EXCLUDE ở CSDL |
| BR-85, BR-86 | Lần giữ ghế chỉ kết thúc ở đúng một trạng thái cuối | Chuyển trạng thái dưới khóa, trigger chặn đổi lại |
| BR-93 | Báo thất bại của giao dịch cũ không làm mất ghế nếu khách đã tạo giao dịch mới hơn | Chỉ giao dịch tạo sau cùng mới đổi trạng thái lần giữ ghế |
| BR-95, BR-98, BR-141 | Email nhân viên, email và số điện thoại khách, tên cụm rạp là duy nhất | Khóa tư vấn theo giá trị cộng chỉ mục unique |
| BR-101 | Thu hồi quyền nhân viên có hiệu lực ngay với phiên đang mở | Mốc truy cập đối chiếu CSDL ở mỗi yêu cầu |
| BR-87 | Không sửa sơ đồ ghế phòng đang có suất chưa chiếu đã bán vé hoặc đang giữ ghế | Khóa phòng chiếu cùng trạng thái ghế |

## 2.4. Biểu đồ Use Case tổng quát và danh sách Use Case

![Hình 2.1. Biểu đồ use case tổng quát của hệ thống CineBook.](diagrams/hinh-2-1-use-case.png =600x)

<!-- @style align=center italic /-->
*Hình 2.1. Biểu đồ use case tổng quát của hệ thống CineBook.*

Biểu đồ có 16 use case và 22 quan hệ association; không có include, extend hay generalization vì không còn use case con và không có biến thể tách riêng. Nhân viên quầy dùng chung UC-005 và UC-008 với khách (cột giữa), không có use case riêng. Cổng thanh toán là tác nhân chính của UC-006 (tự gửi kết quả vào lúc nó quyết định) và là tác nhân phụ của UC-005, UC-008. Mã UC-002 (đăng nhập) bị loại theo quy ước: đăng nhập chỉ là tiền điều kiện.

<!-- @style align=center italic /-->
*Bảng 2.4. Danh sách 16 use case.*

| Mã | Tên use case | Tác nhân chính | Tác nhân phụ | Nhóm |
|---|---|---|---|---|
| UC-001 | Đăng ký tài khoản | Khách | - | Bán vé |
| UC-003 | Tra cứu phim | Khách | - | Bán vé |
| UC-004 | Tra cứu lịch chiếu | Khách | - | Bán vé |
| UC-005 | Đặt vé | Khách, Nhân viên quầy | Cổng thanh toán, Dịch vụ email | Bán vé |
| UC-006 | Hoàn tiền thanh toán trễ | Cổng thanh toán | Dịch vụ email | Bán vé |
| UC-007 | Xem lịch sử đặt vé | Khách | - | Bán vé |
| UC-008 | Hủy vé | Khách, Nhân viên quầy | Cổng thanh toán | Bán vé |
| UC-009 | Soát vé | Nhân viên soát vé | - | Bán vé |
| UC-010 | Quản lý phim | Quản lý chuỗi | - | Vận hành rạp |
| UC-011 | Quản lý cụm rạp | Quản lý chuỗi | - | Vận hành rạp |
| UC-012 | Quản lý phòng chiếu | Quản lý cụm rạp | - | Vận hành rạp |
| UC-013 | Quản lý bảng giá | Quản lý cụm rạp | - | Vận hành rạp |
| UC-014 | Lập lịch suất chiếu | Quản lý cụm rạp | - | Vận hành rạp |
| UC-015 | Xem báo cáo cụm rạp | Quản lý cụm rạp | - | Báo cáo và quản trị |
| UC-016 | Xem báo cáo toàn chuỗi | Quản lý chuỗi | - | Báo cáo và quản trị |
| UC-017 | Quản lý tài khoản nhân viên | Quản trị viên | - | Báo cáo và quản trị |

## 2.5. Đặc tả Use Case

Bốn use case dưới đây được đặc tả chi tiết vì chúng chứa toàn bộ tranh chấp tài nguyên của hệ thống. Mỗi đặc tả gồm bảng thông tin chung, luồng chính, luồng thay thế tiêu biểu và biểu đồ hoạt động. Đặc tả đầy đủ trong tài liệu nguồn (thư mục design) dài hơn nhiều, báo cáo chỉ giữ phần cốt lõi.

### 2.5.1. UC-005 - Đặt vé

<!-- @style align=center italic /-->
*Bảng 2.5. Thông tin chung của UC-005 Đặt vé.*

| Thành phần | Nội dung |
|---|---|
| Mã / Tên | UC-005 / Đặt vé (Book Tickets) |
| Tác nhân chính | Khách; Nhân viên quầy (bán vé tại quầy) |
| Tác nhân phụ | Cổng thanh toán, Dịch vụ email |
| Mô tả | Mua vé cho một số ghế của một suất chiếu. Kết quả là các ghế chuyển sang đã bán, mỗi ghế một vé có mã QR và cùng một mã đặt vé |
| Tiền điều kiện | Khách có thể bắt đầu khi chưa đăng nhập, đăng nhập kiểm ở bước 5; nhân viên quầy đã đăng nhập |
| Hậu điều kiện (thành công) | Ghế ở trạng thái đã bán; có mã đặt vé và vé có QR; mã giao dịch của cổng được lưu; email vé đã xếp hàng gửi |
| Hậu điều kiện tối thiểu | Thất bại thì không vé nào được tạo và không ghế nào còn ở trạng thái đang giữ cho lần đặt này; ghế được giải phóng chậm nhất 1 phút sau hạn |
| Quy tắc liên quan | BR-01, BR-04 đến BR-12, BR-37, BR-44, BR-45, BR-65, BR-85, BR-89, BR-90, BR-93 |

<!-- @style align=center italic /-->
*Bảng 2.6. Luồng sự kiện chính của UC-005 (kênh trực tuyến).*

| Bước | Thực hiện | Hành động |
|---|---|---|
| 1 | Khách | Chọn suất chiếu |
| 2 | Hệ thống | Kiểm suất chiếu đã mở bán (BR-01) và chưa tới giờ bắt đầu (BR-45) |
| 3 | Hệ thống | Hiển thị sơ đồ ghế, cập nhật trạng thái ghế khi người khác giữ hoặc mua |
| 4 | Khách | Chọn ghế, xác nhận chọn ghế; ghế đang chọn vẫn trống cho đến khi xác nhận (BR-03) |
| 5 | Hệ thống | Kiểm khách đã đăng nhập |
| 6 | Hệ thống | Kiểm số ghế không quá 8 (BR-05, BR-06) |
| 7 | Hệ thống | Trong một thao tác không chia cắt: kiểm suất chiếu chưa đổi, người giữ ghế không có lần giữ chưa kết thúc, mọi ghế còn trống; xác định giá từng ghế theo bảng giá; giữ cả nhóm ghế 10 phút |
| 8 | Hệ thống | Hiển thị ghế đã giữ, giá từng ghế, tổng tiền và đồng hồ đếm ngược |
| 9 | Khách | Yêu cầu thanh toán trực tuyến |
| 10 | Hệ thống | Tạo giao dịch thanh toán, truyền kèm mã tham chiếu lần giữ ghế cho cổng |
| 11 | Cổng thanh toán | Báo giao dịch thành công |
| 12 | Hệ thống | Chuyển ghế sang đã bán, đối chiếu mã giao dịch, đánh dấu giao dịch đã xử lý (BR-37) |
| 13 | Hệ thống | Tạo mã đặt vé và mỗi ghế một vé có mã QR |
| 14 | Hệ thống | Gửi vé qua email |
| 15 | Hệ thống | Thông báo thành công, hiển thị mã đặt vé và các vé |

<!-- @style align=center italic /-->
*Bảng 2.7. Luồng thay thế và ngoại lệ tiêu biểu của UC-005.*

| Luồng | Điều kiện | Xử lý |
|---|---|---|
| 1a | Tác nhân đang có lần giữ ghế chưa kết thúc (tải lại trang, đóng tab) | Hiện lối Tiếp tục thanh toán kèm thời gian còn lại, không giữ ghế mới |
| 2a, 2c | Suất chưa mở bán hoặc đã bắt đầu | Từ chối bán vé |
| 7a | Ít nhất một ghế không còn trống, kể cả khi người khác vừa xác nhận chọn cùng ghế (BR-09) | Báo các ghế không còn trống, không giữ ghế nào |
| 7b | Tới hạn giữ ghế mà chưa có thanh toán thành công | Giải phóng ghế, thông báo hết thời gian |
| 7c | Tác nhân đang có lần giữ ghế chưa kết thúc (BR-04) | Từ chối giữ ghế |
| 7d | Suất chiếu bị sửa hoặc xóa từ lúc hiển thị sơ đồ ghế (BR-54) | Từ chối, bắt đầu lại |
| 10a | Cổng từ chối hoặc không trả lời yêu cầu tạo giao dịch | Giữ nguyên lần giữ ghế, cho khách thử lại, hạn không đổi |
| 10b | Khách quay về từ cổng khi hệ thống chưa nhận IPN | Hỏi lại trạng thái mỗi 2 giây, tối đa 60 giây |
| 11a | Cổng báo thất bại của giao dịch tạo sau cùng (BR-93) | Giải phóng ghế; giao dịch cũ báo thất bại thì chỉ ghi nhận |
| 14a | Dịch vụ email lỗi (BR-89) | Vé giữ nguyên hiệu lực, thử gửi lại vài lần rồi ghi log |
| *a | Khách hoặc nhân viên hủy giữ ghế | Giải phóng ghế; thanh toán thành công báo sau đó xử lý ở UC-006 |
| 9a | Nhân viên quầy bán vé tại quầy | Thu tiền mặt (BR-13), xác nhận đã thu, hệ thống chuyển ghế sang đã bán, tạo vé, nhân viên in vé |
| 9a1a | Xác nhận thu tiền tới sau hạn giữ ghế hoặc lần giữ ghế đã ở trạng thái cuối (BR-44) | Từ chối xác nhận, không bán ghế, nhân viên trả lại tiền mặt cho khách |

Bước 7 là điểm tranh chấp lớn nhất: nó phải kiểm và giữ cả nhóm ghế, tạo lần giữ ghế và chốt giá trong một thao tác không chia cắt. Phân tích đơn vị loại trừ tương ứng (EX-01) nằm ở Chương 5. Luồng 9a cho thấy bán vé tại quầy dùng đúng cùng quy tắc giữ ghế 8 ghế, 10 phút, tất cả hoặc không, nhờ đó hai kênh không thể bán trùng.

### 2.5.2. UC-006 - Hoàn tiền thanh toán trễ

<!-- @style align=center italic /-->
*Bảng 2.8. Thông tin chung của UC-006 Hoàn tiền thanh toán trễ.*

| Thành phần | Nội dung |
|---|---|
| Mã / Tên | UC-006 / Hoàn tiền thanh toán trễ (Refund Late Payment) |
| Tác nhân chính | Cổng thanh toán (tự gửi IPN vào lúc nó quyết định) |
| Tác nhân phụ | Dịch vụ email (cổng cũng thực hiện hoàn tiền) |
| Sự kiện kích hoạt | Cổng báo thanh toán thành công khi lần giữ ghế đã hết hạn, đã bị khách hủy, đã báo thất bại, hoặc giao dịch là giao dịch thứ hai của lần giữ ghế đã có vé; hoặc báo trùng; hoặc báo thất bại muộn (chỉ ghi nhận) |
| Hậu điều kiện | Không vé nào được tạo từ giao dịch; giao dịch ghi nhận thanh toán trễ và hoàn toàn bộ qua cổng; email thông báo hoàn tiền gửi cho khách |
| Hậu điều kiện tối thiểu | Giao dịch không bị hoàn toàn bộ quá một lần (BR-37); tổng các lần hoàn không vượt số đã thanh toán (BR-26) |
| Quy tắc liên quan | BR-14, BR-15, BR-26, BR-37 đến BR-43, BR-89, BR-91 |

<!-- @style align=center italic /-->
*Bảng 2.9. Luồng sự kiện của UC-006.*

| Bước | Thực hiện | Hành động |
|---|---|---|
| 1 | Cổng thanh toán | Báo kết quả một giao dịch (kèm mã giao dịch, mã tham chiếu lần giữ ghế, số tiền) |
| 2 | Hệ thống | Tra giao dịch; kiểm kết quả thành công, nhận ra giao dịch, giao dịch chưa xử lý (BR-37), lần giữ ghế ở trạng thái hết hạn, đã hủy, thanh toán thất bại hoặc đã có vé |
| 3 | Hệ thống | Ghi nhận thanh toán trễ chờ hoàn, không tạo vé |
| 4 | Hệ thống | Yêu cầu cổng hoàn toàn bộ số tiền, kèm khóa chống hoàn trùng (mã giao dịch và loại yêu cầu) |
| 5 | Cổng thanh toán | Trả kết quả hoàn thành công |
| 6 | Hệ thống | Ghi nhận giao dịch đã được hoàn toàn bộ |
| 7 | Hệ thống | Gửi email thông báo hoàn tiền cho khách |

Các luồng thay thế quyết định tính đúng đắn: 2a báo trùng chỉ ghi nhận, không hoàn thêm; 2c, 2d báo thất bại muộn chỉ ghi nhận, không hoàn; 2e giao dịch hệ thống không nhận ra và 2f số tiền lệch chỉ ghi log để xử lý thủ công, không hoàn tự động; 4a, 5a cổng không phản hồi trong 30 giây hoặc hoàn thất bại thì không gửi lại ngay mà tra cứu kết quả hoàn rồi mới thử lại; 4b, 5b hết lượt thử thì ghi log xử lý thủ công và không gửi email cho khách; 7a email lỗi không làm mất hiệu lực khoản hoàn.

![Hình 2.2. Biểu đồ hoạt động UC-006 Hoàn tiền thanh toán trễ.](diagrams/hinh-2-2-activity-uc006.png =512x)

<!-- @style align=center italic /-->
*Hình 2.2. Biểu đồ hoạt động UC-006 Hoàn tiền thanh toán trễ.*

### 2.5.3. UC-008 - Hủy vé

<!-- @style align=center italic /-->
*Bảng 2.10. Thông tin chung của UC-008 Hủy vé.*

| Thành phần | Nội dung |
|---|---|
| Mã / Tên | UC-008 / Hủy vé (Cancel Ticket) |
| Tác nhân chính | Khách (vé mua trực tuyến của mình); Nhân viên quầy (vé mua tại quầy của cụm mình) |
| Tác nhân phụ | Cổng thanh toán (hoàn tiền vé mua trực tuyến) |
| Mô tả | Hủy từng vé trước giờ chiếu ít nhất 2 tiếng, hoàn 70% giá vé (làm tròn xuống đồng), trả ghế về trống |
| Hậu điều kiện | Vé ở trạng thái đã hủy; ghế trống; khoản hoàn được ghi nhận kèm tình trạng đã hoàn hoặc chưa hoàn được và đã ghi log lỗi |
| Quy tắc liên quan | BR-17 đến BR-21, BR-26, BR-30 đến BR-32, BR-41 đến BR-43 |

<!-- @style align=center italic /-->
*Bảng 2.11. Luồng sự kiện chính của UC-008.*

| Bước | Thực hiện | Hành động |
|---|---|---|
| 1 | Khách | Chọn vé cần hủy trong các vé mua trực tuyến của mình |
| 2 | Hệ thống | Kiểm quyền hủy theo kênh mua vé (BR-17) |
| 3 | Hệ thống | Kiểm thời điểm kiểm tra cách giờ bắt đầu suất chiếu ít nhất 2 tiếng (BR-18, BR-32) |
| 4 | Hệ thống | Kiểm vé chưa hủy và chưa sử dụng, rồi ghi nhận vé đã hủy, một thao tác không chia cắt (BR-21, BR-30) |
| 5 | Hệ thống | Yêu cầu cổng hoàn 70% giá vé kèm mã giao dịch và mã vé làm khóa chống hoàn trùng |
| 6 | Cổng thanh toán | Báo hoàn tiền thành công |
| 7 | Hệ thống | Ghi nhận khoản hoàn và trả ghế về trống (BR-42) |
| 8 | Hệ thống | Thông báo hủy thành công, hiển thị số tiền hoàn |

Luồng 1a: nhân viên quầy nhập mã đặt vé, chọn vé mua tại quầy, hoàn tiền mặt (5a) và gộp ghi nhận hủy, xác nhận hoàn tiền mặt, trả ghế vào một thao tác không chia cắt. Luồng 4a, 4b: vé đã hủy hoặc đã sử dụng (kể cả vừa bị bên kia xử lý ngay trước đó) thì bị từ chối. Luồng 5b, 6a, 5c, 6b: cổng không trả lời hoặc từ chối thì tra cứu rồi thử lại; hết lượt thì ghi log xử lý thủ công nhưng vé vẫn là đã hủy và ghế vẫn trống.

![Hình 2.3. Biểu đồ hoạt động UC-008 Hủy vé.](diagrams/hinh-2-3-activity-uc008.png =541x)

<!-- @style align=center italic /-->
*Hình 2.3. Biểu đồ hoạt động UC-008 Hủy vé.*

### 2.5.4. UC-009 - Soát vé

<!-- @style align=center italic /-->
*Bảng 2.12. Đặc tả UC-009 Soát vé.*

| Thành phần | Nội dung |
|---|---|
| Mã / Tên | UC-009 / Soát vé (Check Ticket) |
| Tác nhân chính | Nhân viên soát vé (thuộc một cụm rạp) |
| Mô tả | Chọn một suất chiếu đang soát rồi quét liên tiếp mã QR trên vé bằng camera; hệ thống kiểm và đánh dấu vé đã sử dụng hoặc báo một lý do không hợp lệ |
| Luồng chính | (1) Chọn suất chiếu của cụm rạp mình, (2) hệ thống ghi nhận suất đang soát, (3) quét mã QR, (4) kiểm mã tương ứng vé, vé thuộc cụm rạp, thuộc suất đang soát, chưa sử dụng, chưa hủy, (5) đánh dấu đã sử dụng, (6) thông báo hợp lệ, (7) lặp bước 3 đến 6 |
| Luồng ngoại lệ | 2a suất chiếu không thuộc cụm rạp; 4a mã không tương ứng vé; 4b vé thuộc cụm rạp khác; 4c vé thuộc suất khác; 4d vé đã sử dụng (kể cả vừa được nhân viên khác soát); 4e vé đã hủy (kể cả vừa hủy ở UC-008) |
| Quy tắc liên quan | BR-22 đến BR-25, BR-30, BR-33, BR-34; NFR-13, NFR-14 |

Khi vé vi phạm nhiều điều kiện, hệ thống chỉ báo một lý do theo thứ tự cố định: cụm rạp, suất chiếu, đã sử dụng, đã hủy (BR-33). Tranh chấp duy nhất của UC này là hai nhân viên soát cùng một vé, hoặc soát cùng lúc với hủy vé (BR-30): bên ghi nhận trước thành công.

![Hình 2.4. Biểu đồ hoạt động UC-009 Soát vé.](diagrams/hinh-2-4-activity-uc009.png =513x)

<!-- @style align=center italic /-->
*Hình 2.4. Biểu đồ hoạt động UC-009 Soát vé.*

### 2.5.5. Đặc tả tóm tắt các use case còn lại

<!-- @style align=center italic /-->
*Bảng 2.13. Đặc tả tóm tắt 12 use case còn lại.*

| Mã | Mục tiêu và luồng chính | Điểm đáng chú ý |
|---|---|---|
| UC-001 Đăng ký tài khoản | Khách nhập email, số điện thoại, mật khẩu; hệ thống kiểm định dạng và tạo tài khoản dùng được ngay | Email chuẩn, số điện thoại 10 chữ số bắt đầu bằng 0 (BR-81, BR-82); email và số điện thoại duy nhất (BR-98), khóa tư vấn theo giá trị (EX-20) |
| UC-003 Tra cứu phim | Xem phim đang chiếu, sắp chiếu và thông tin một phim, không cần đăng nhập | Đang chiếu: đã tới ngày khởi chiếu và chưa qua ngày kết thúc |
| UC-004 Tra cứu lịch chiếu | Xem suất chiếu theo phim hoặc theo cụm rạp, lọc theo tỉnh, ngày, loại phòng, định dạng | Chỉ hiển thị suất còn trong lịch |
| UC-007 Xem lịch sử đặt vé | Khách xem các lần đặt và vé của mình | Chỉ thấy lần đặt của chính mình (BR-94) |
| UC-010 Quản lý phim | Quản lý chuỗi thêm, sửa phim: định dạng 2D, 3D, ngày khởi chiếu, kết thúc | Sửa kiểm mốc thay đổi để không ghi đè (EX-16); tên phim được trùng |
| UC-011 Quản lý cụm rạp | Quản lý chuỗi thêm, sửa cụm rạp | Tên cụm rạp duy nhất, khóa tư vấn (EX-17); tạo kèm bảng giá rỗng |
| UC-012 Quản lý phòng chiếu | Quản lý cụm rạp thêm, sửa, xóa phòng chiếu và sơ đồ ghế | Sức chứa 50 đến 400 (BR-144); không sửa khi có suất đã bán hoặc đang giữ ghế (BR-87); xóa chỉ khi chưa từng có suất (BR-147) |
| UC-013 Quản lý bảng giá | Đặt giá, đổi giá, bỏ giá theo loại phòng, định dạng, loại ghế, khung giờ | Không bỏ mục giá đang được suất chưa chiếu dùng (BR-64); giá đã chốt của lần giữ ghế không đổi (BR-65) |
| UC-014 Lập lịch suất chiếu | Lập, sửa, xóa suất chiếu cho phòng của cụm | Giờ kết thúc bằng giờ bắt đầu cộng thời lượng phim; dọn phòng 15 phút; ngày chiếu trong khoảng của phim; không sửa khi có ghế giữ hoặc vé chưa hủy; đổi phòng chỉ khi suất chưa từng có vé (BR-92) |
| UC-015 Xem báo cáo cụm rạp | Doanh thu và tỉ lệ lấp đầy theo ngày, phim, suất chiếu | Doanh thu bằng tiền vé đã bán trừ tiền đã hoàn; ghế đôi tính một ghế, không tính ghế đang giữ |
| UC-016 Xem báo cáo toàn chuỗi | Như UC-015 cho toàn chuỗi và so sánh giữa cụm rạp | Báo cáo đọc trong một ảnh chụp nhất quán (REPEATABLE READ, chỉ đọc) |
| UC-017 Quản lý tài khoản nhân viên | Tạo, đổi cụm rạp và vai trò, khóa, mở khóa, đổi tên, đặt lại mật khẩu | Email nhân viên duy nhất xuyên mọi vai trò (BR-95); khóa hoặc đổi quyền có hiệu lực ngay với phiên đang mở (BR-101) |


<!-- @pagebreak -->

# Chương 3. Phân tích

Chương này xây dựng mô hình phân tích hợp nhất từ phân tích riêng từng use case: mô hình lĩnh vực, lớp phân tích theo mẫu BCE, các biểu đồ tuần tự tiêu biểu và máy trạng thái của các đối tượng có vòng đời. Mô hình phân tích hợp nhất bao phủ đủ 16 use case, gồm 55 lớp (19 boundary, 16 control, 20 entity) với 401 trách nhiệm.

## 3.1. Mô hình hóa lĩnh vực (Domain Model)

Mô hình lĩnh vực có 20 lớp thực thể, chia hai nhóm. Nhóm vận hành rạp gồm Cinema, Auditorium, Seat, Movie, Showtime, PriceList, PriceEntry. Nhóm bán vé gồm Customer, Staff (lớp cha của BoxOfficeClerk, TicketChecker, CinemaManager), SeatStatus, SeatHold, PaymentTransaction, RefundRequest, Booking, Ticket; hai lớp ReportPeriod, ReportGroup phục vụ báo cáo và không lưu.

![Hình 3.1. Biểu đồ lớp phân tích nhóm thực thể bán vé (Entity - Bán vé).](diagrams/hinh-3-1-domain-ban-ve.png =600x)

<!-- @style align=center italic /-->
*Hình 3.1. Biểu đồ lớp phân tích nhóm thực thể bán vé (Entity - Bán vé).*

Các quyết định mô hình hóa đáng chú ý:

- SeatStatus là trạng thái của một ghế trong một suất chiếu, không phải của ghế vật lý. Mỗi suất chiếu sinh sẵn một SeatStatus cho mỗi ghế, nên "ghế" là đối tượng nhỏ nhất bị tranh chấp.
- SeatStatus có hai liên kết hiện tại, currentHold (lần giữ ghế đang giữ) và currentTicket (vé đang giữ). Bất biến: ghế Trống khi không có cả hai; Đang được giữ khi có đúng một lần giữ ghế hiện tại và không có vé; Đã bán khi có đúng một vé hiện tại và không có lần giữ ghế. Hai liên kết này cho phép các thao tác giải phóng chạy lặp an toàn: chỉ trả ghế nếu liên kết hiện tại đúng là lần giữ ghế hay vé đang xử lý.
- SeatHold có người giữ là khách hoặc nhân viên quầy (loại trừ lẫn nhau), nhờ đó kênh trực tuyến và kênh quầy dùng chung một quy tắc.
- Giá vé được chốt vào SeatStatus lúc giữ ghế và sao chép vào Ticket lúc bán, cùng với tên phim, cụm rạp, phòng; đổi bảng giá hay đổi tên sau đó không làm đổi vé đã bán.
- Quản lý chuỗi là một giá trị của vai trò trong Staff, không phải lớp riêng; quản trị viên là tài khoản riêng đúng một dòng, ngoài bảng nhân viên.

## 3.2. Biểu đồ lớp phân tích (BCE)

Mỗi use case có ít nhất một boundary cho giao diện, một control điều phối và các entity. Với UC-005, boundary tách theo kênh (BookTicketsForm cho khách, CounterBookTicketsForm cho nhân viên quầy), hai boundary hệ thống (PaymentGateway, EmailService) và một control BookTicketsController. Báo thanh toán của cổng đi vào một control riêng PaymentReportController vì nó là sự kiện không do tác nhân người khởi tạo.

![Hình 3.2. Biểu đồ lớp phân tích BCE của UC-005 Đặt vé.](diagrams/hinh-3-2-bce-uc005.png =600x)

<!-- @style align=center italic /-->
*Hình 3.2. Biểu đồ lớp phân tích BCE của UC-005 Đặt vé.*

<!-- @style align=center italic /-->
*Bảng 3.1. Thống kê lớp phân tích theo stereotype.*

| Stereotype | Số lớp | Ví dụ |
|---|---|---|
| Boundary | 19 | BookTicketsForm, CounterBookTicketsForm, CheckTicketForm, ScheduleShowtimesForm; PaymentGateway, EmailService |
| Control | 16 | BookTicketsController, PaymentReportController, CancelTicketController, CheckTicketController |
| Entity | 20 | Showtime, SeatStatus, SeatHold, PaymentTransaction, RefundRequest, Booking, Ticket |

Nguyên tắc phân bổ trách nhiệm là chuyên gia thông tin: mỗi kiểm tra đặt ở lớp giữ dữ liệu của nó. Showtime kiểm đã mở bán và chưa đổi từ lúc hiển thị; SeatHold kiểm người giữ không có lần giữ chưa kết thúc và quyết định hết hạn, hủy, hoàn tất; SeatStatus chuyển trạng thái ghế; PaymentTransaction kiểm chưa xử lý và theo dõi tổng đã hoàn; RefundRequest sinh khóa chống hoàn trùng; Ticket kiểm điều kiện soát.

## 3.3. Phân tích hành vi

### 3.3.1. Biểu đồ tuần tự

Mỗi use case được phân tích theo từng luồng, mỗi luồng một biểu đồ tuần tự; riêng UC-005 có 18 biểu đồ. Báo cáo chọn các biểu đồ gắn trực tiếp với tranh chấp.

![Hình 3.3. Biểu đồ tuần tự UC-005, luồng chính bước 1 đến 7 (chọn suất, xem sơ đồ ghế, giữ ghế).](diagrams/hinh-3-3-seq-uc005-sd1a.png =600x)

<!-- @style align=center italic /-->
*Hình 3.3. Biểu đồ tuần tự UC-005, luồng chính bước 1 đến 7 (chọn suất, xem sơ đồ ghế, giữ ghế).*

Ở bước 7, BookTicketsController gọi lần lượt Showtime (kiểm mở bán, kiểm suất chưa đổi), kiểm người giữ ghế không có lần giữ chưa kết thúc, xác định giá từng ghế theo PriceList, rồi giao SeatStatus chuyển từng ghế sang đang được giữ và tạo SeatHold. Toàn bộ chuỗi này là một thao tác không chia cắt; mức phân tích nêu đối tượng cần loại trừ (EX-01), cơ chế khóa do thiết kế kiến trúc quyết định.

![Hình 3.4. Biểu đồ tuần tự UC-005, luồng chính bước 8 đến 12 (thanh toán và bán ghế).](diagrams/hinh-3-4-seq-uc005-sd1b.png =600x)

<!-- @style align=center italic /-->
*Hình 3.4. Biểu đồ tuần tự UC-005, luồng chính bước 8 đến 12 (thanh toán và bán ghế).*

![Hình 3.5. Biểu đồ tuần tự UC-006, luồng chính (báo thanh toán trễ và hoàn toàn bộ).](diagrams/hinh-3-5-seq-uc006.png =600x)

<!-- @style align=center italic /-->
*Hình 3.5. Biểu đồ tuần tự UC-006, luồng chính (báo thanh toán trễ và hoàn toàn bộ).*

Điểm đáng chú ý ở UC-006: PaymentReportController tiếp nhận mọi báo kết quả của cổng, tìm lần giữ ghế theo mã giao dịch hoặc mã tham chiếu lần giữ ghế, rồi giao cho SeatHold quyết định. Cùng một đường vào xử lý cả thanh toán đúng hạn (UC-005 bước 11 đến 13) lẫn thanh toán trễ (UC-006), vì cổng không biết phía hệ thống đang ở trạng thái nào.

![Hình 3.6. Biểu đồ tuần tự UC-008, luồng chính (hủy vé, hoàn tiền, trả ghế).](diagrams/hinh-3-6-seq-uc008.png =600x)

<!-- @style align=center italic /-->
*Hình 3.6. Biểu đồ tuần tự UC-008, luồng chính (hủy vé, hoàn tiền, trả ghế).*

### 3.3.2. Biểu đồ hoạt động

Biểu đồ hoạt động của UC-005, UC-006, UC-008 và UC-009 đã trình bày ở Hình 1.1, 2.2, 2.3 và 2.4. Các biểu đồ này thể hiện rõ các nhánh quyết định theo thời gian (hết hạn, đã hủy, đã sử dụng) là nơi phát sinh race condition.

### 3.3.3. Biểu đồ trạng thái (State Machine)

Năm đối tượng có vòng đời quan trọng. Trạng thái cuối được bảo vệ ở hai tầng: câu cập nhật có điều kiện trạng thái cũ và trigger ở CSDL không cho chuyển trạng thái trái bảng.

![Hình 3.7. Máy trạng thái lần giữ ghế (SeatHold).](diagrams/hinh-3-7-state-seathold.png =600x)

<!-- @style align=center italic /-->
*Hình 3.7. Máy trạng thái lần giữ ghế (SeatHold).*

SeatHold có 5 trạng thái: Đang giữ là trạng thái duy nhất có thể rời; bốn trạng thái cuối là Đã hoàn tất, Hết hạn, Đã hủy, Thanh toán thất bại. Quy tắc then chốt (BR-85, BR-86): một lần giữ ghế còn nhãn Đang giữ nhưng đã quá hạn được coi là Hết hạn trước khi xử lý bất kỳ sự kiện nào đến sau, nên kết quả không phụ thuộc thứ tự đến của IPN, hủy giữ ghế hay công việc quét hết hạn.

![Hình 3.8. Máy trạng thái ghế của một suất chiếu (SeatStatus).](diagrams/hinh-3-8-state-seatstatus.png =600x)

<!-- @style align=center italic /-->
*Hình 3.8. Máy trạng thái ghế của một suất chiếu (SeatStatus).*

![Hình 3.9. Máy trạng thái vé (Ticket).](diagrams/hinh-3-9-state-ticket.png =600x)

<!-- @style align=center italic /-->
*Hình 3.9. Máy trạng thái vé (Ticket).*

Vé có ba trạng thái: chưa dùng, đã dùng, đã hủy; hai trạng thái sau đều là cuối. Chuyển sang đã dùng (soát vé) và sang đã hủy (hủy vé) loại trừ nhau: bên ghi nhận trước thành công (BR-30).

![Hình 3.10. Máy trạng thái giao dịch thanh toán (PaymentTransaction).](diagrams/hinh-3-10-state-payment.png =600x)

<!-- @style align=center italic /-->
*Hình 3.10. Máy trạng thái giao dịch thanh toán (PaymentTransaction).*

Giao dịch thanh toán: PENDING (chờ kết quả) chuyển sang TICKETED khi bán được vé, FAILED khi cổng báo thất bại, hoặc LATE_PAYMENT khi thanh toán thành công báo trễ. Giao dịch chỉ được xử lý một lần.

![Hình 3.11. Máy trạng thái yêu cầu hoàn tiền (RefundRequest).](diagrams/hinh-3-11-state-refund.png =600x)

<!-- @style align=center italic /-->
*Hình 3.11. Máy trạng thái yêu cầu hoàn tiền (RefundRequest).*

Yêu cầu hoàn tiền: NEW, IN_FLIGHT (đang chờ kết quả, mỗi lần gửi tăng số lần thử), WAITING_RETRY (hẹn thử lại), REFUNDED và MANUAL_REQUIRED (cần xử lý thủ công, trạng thái cuối). Tối đa 4 lần gửi gồm lần đầu và 3 lần thử lại.


<!-- @pagebreak -->

# Chương 4. Thiết kế kiến trúc

Chương này chọn mẫu kiến trúc, chia package theo lớp, xác định các subsystem che giao tiếp ngoài, nêu cách triển khai và giao diện với cổng VNPay. Cơ chế xử lý đồng thời nằm trong kiến trúc nhưng được trình bày riêng ở Chương 5.

## 4.1. Lựa chọn kiến trúc

Ba phương án được so sánh theo các tiêu chí rút từ NFR và ràng buộc đồ án.

<!-- @style align=center italic /-->
*Bảng 4.1. So sánh phương án kiến trúc.*

| Tiêu chí | PA1: modular monolith, khóa và hàng đợi trong PostgreSQL | PA2: microservices, giao dịch phân tán | PA3: một bản backend, khóa trong bộ nhớ |
|---|---|---|---|
| Đúng đắn đồng thời | Tốt: khóa dòng và ràng buộc một nguồn sự thật | Kém: khó bảo đảm giữ ghế tất cả hoặc không | Đúng khi một bản, sai khi nhân bản |
| Hiệu năng 2 giây, 3 giây | Tốt: một lần đi tới CSDL, khóa hẹp | Kém: thêm bước gọi mạng | Tốt |
| Chịu khởi động lại, nhiều bản | Tốt: không giữ trạng thái trong bộ nhớ | Tốt | Kém: mất bộ đếm giờ |
| Phù hợp quy mô đồ án | Tốt: một mã nguồn, một CSDL | Kém: quá lớn | Tốt |
| Kết luận | Chọn | Loại | Loại |

Phương án PA1 được chọn: front-end React SPA và back-end Go dạng modular monolith bốn lớp (Presentation, Application, Services, Domain), nhiều bản backend giống nhau chạy sau bộ cân bằng tải, một PostgreSQL. Các phương án bị loại ở mức cơ chế gồm: mức cô lập SERIALIZABLE (dưới 1.000 giao dịch tranh một suất chiếu sẽ có nhiều lỗi 40001 phải thử lại, vượt 2 giây), thăm dò định kỳ sơ đồ ghế (4.000 yêu cầu mỗi giây chỉ để biết không có gì mới), WebSocket (không cần hai chiều) và NOTIFY của PostgreSQL trong giao dịch giữ ghế (mọi commit có NOTIFY phải xếp hàng một ở bước commit).

## 4.2. Biểu đồ gói (Package Diagram)

Kiến trúc có 4 lớp và 29 package có hành vi (PKG-05 đến PKG-33). Phụ thuộc theo kiểu layered nới lỏng: Application được dùng trực tiếp lớp miền; Presentation chỉ phụ thuộc Application và Security; không có phụ thuộc đi lên và không có vòng.

![Hình 4.1. Biểu đồ gói cấp lớp của hệ thống CineBook.](diagrams/hinh-4-1-package-layers.png =600x)

<!-- @style align=center italic /-->
*Hình 4.1. Biểu đồ gói cấp lớp của hệ thống CineBook.*

<!-- @style align=center italic /-->
*Bảng 4.2. Các package chính theo lớp.*

| Lớp | Package | Trách nhiệm |
|---|---|---|
| Presentation | CustomerWeb, CounterWeb, CheckInWeb, CinemaAdminWeb, ChainAdminWeb, AccountAdminWeb (PKG-05 đến PKG-10); SeatMapClient, SessionClient (PKG-29, PKG-31); HttpApi, PaymentCallbackApi (PKG-11, PKG-12) | Giao diện theo từng tác nhân trên trình duyệt; tiếp nhận REST, kênh đẩy sơ đồ ghế và IPN ở máy chủ |
| Application | SeatBooking (PKG-13), PaymentRefund (PKG-14), TicketService (PKG-15), ScheduleAndPricing (PKG-16), Catalog (PKG-17), Reporting (PKG-18), AccountManagement (PKG-19), Notification (PKG-20), ChainManagement (PKG-30) | Điều phối từng use case thành các thao tác không chia cắt |
| Services | Persistence (PKG-21), PaymentGatewayClient (PKG-22), EmailGatewayClient (PKG-23), SeatEventHub (PKG-24), Scheduler (PKG-25), Security (PKG-26) | Truy cập dữ liệu và khóa, hệ thống ngoài, luồng sự kiện đổi ghế, công việc nền, bảo mật |
| Domain | CinemaOperations (PKG-27), Ticketing (PKG-28), StaffAccounts (PKG-32), ReportModel (PKG-33) | Lớp miền và interface kho dữ liệu |

Bản thiết kế chi tiết hơn của package (có interface và phụ thuộc từng cạnh) là kết quả của bước thiết kế phần tử:

![Hình 4.2. Biểu đồ gói thiết kế chi tiết (các package PKG-05 đến PKG-33).](diagrams/hinh-4-2-package-design.png =600x)

<!-- @style align=center italic /-->
*Hình 4.2. Biểu đồ gói thiết kế chi tiết (các package PKG-05 đến PKG-33).*

Hai lựa chọn phụ thuộc có chủ đích: interface kho dữ liệu (repository) do Domain định nghĩa và Persistence hiện thực, để lớp miền không biết SQL; và công việc nền do Scheduler định nghĩa interface rồi các package Application hiện thực (đảo phụ thuộc), nên không có mũi tên gọi ngược lên.

## 4.3. Subsystem và biểu đồ thành phần

Năm subsystem che các phần tử có hành vi phức tạp hoặc tiếp xúc hệ thống ngoài, mỗi subsystem một interface ổn định:

<!-- @style align=center italic /-->
*Bảng 4.3. Các subsystem và interface.*

| Subsystem | Interface | Che giấu |
|---|---|---|
| SS-01 PaymentGateway | IF-01 IPaymentGateway, IF-02 IPaymentReportReceiver | Ký URL thanh toán, kiểm chữ ký IPN, máy khách hoàn tiền, định dạng trả lời của cổng; đổi cổng chỉ sửa package này |
| SS-02 EmailGateway | IF-03 IEmailSender | Kết nối SMTP, thời gian chờ 30 giây, Message-ID chống lặp |
| SS-03 SeatEventHub | IF-04 ISeatEventSubscription | Đọc bảng seat_event theo con trỏ, cửa sổ chồng 10 giây, phát lại, hàng đợi từng kết nối |
| SS-04 Scheduler | IF-05 IJobScheduler, IF-06 IScheduledJob | Chạy định kỳ, chống chạy chồng, ngân sách thời gian, pool kết nối riêng |
| SS-05 Security | IF-07 IAuthenticator | Băm mật khẩu, cấp và kiểm mã phiên, mốc truy cập |

![Hình 4.3. Biểu đồ ngữ cảnh subsystem SS-01 PaymentGateway.](diagrams/hinh-4-3-subsystem-ss01.png =600x)

<!-- @style align=center italic /-->
*Hình 4.3. Biểu đồ ngữ cảnh subsystem SS-01 PaymentGateway.*

## 4.4. Biểu đồ triển khai (Deployment Diagram)

![Hình 4.4. Biểu đồ triển khai của hệ thống CineBook.](diagrams/hinh-4-4-deployment.png =600x)

<!-- @style align=center italic /-->
*Hình 4.4. Biểu đồ triển khai của hệ thống CineBook.*

Có sáu node: trình duyệt (điện thoại, máy tính bảng, máy tính) chạy gói React SPA; bộ cân bằng tải kết thúc HTTPS và phục vụ tệp tĩnh; máy chủ ứng dụng (2 bản giống nhau trong triển khai mẫu, mở rộng từ 1 đến N); máy chủ PostgreSQL một node; cổng VNPay sandbox và dịch vụ email SMTP là hệ thống ngoài. Mọi bản backend giống nhau và không giữ trạng thái giữa hai yêu cầu: khóa, thời điểm hết hạn, hàng đợi gửi, liên kết hiện tại và sự kiện đổi ghế đều nằm trong PostgreSQL, nên bản nào xử lý yêu cầu nào cũng cùng thấy một thứ tự loại trừ. Công việc nền chạy trên mọi bản và chia việc bằng SKIP LOCKED, không cần bầu chủ.

## 4.5. Giao diện hệ thống: cổng thanh toán VNPay và email

VNPay không có lệnh tạo giao dịch qua mạng. Hệ thống tự dựng URL thanh toán có chữ ký HMAC-SHA512 rồi chuyển trình duyệt của khách sang URL đó; mã tham chiếu giao dịch và thông tin đơn hàng mang mã tham chiếu lần giữ ghế đều nằm trong phần được ký. Có hai đường báo kết quả với vai trò khác hẳn nhau:

- Địa chỉ trả về (return URL) khi trình duyệt khách quay lại: chỉ hiển thị trạng thái đọc từ CSDL, tuyệt đối không ghi dữ liệu.
- IPN từ máy chủ VNPay: đường duy nhất làm đổi dữ liệu. Hệ thống phải trả lời HTTP 200 kèm JSON RspCode.

<!-- @style align=center italic /-->
*Bảng 4.4. Mã trả lời IPN và hành vi của hệ thống.*

| RspCode | Tình huống | Hành vi |
|---|---|---|
| 00 | Xử lý thành công: bán vé, hoặc ghi nhận thanh toán trễ và tạo yêu cầu hoàn, hoặc ghi nhận thất bại | Không ghi lại |
| 01 | Không tìm thấy giao dịch và không có mã tham chiếu lần giữ ghế hợp lệ | Ghi log xử lý thủ công, cổng ngừng gửi lại |
| 02 | Báo trùng giao dịch đã xử lý | Tăng bộ đếm báo trùng, không tạo vé, không hoàn thêm |
| 04 | Số tiền không khớp (chỉ kiểm với báo thành công chưa xử lý) | Ghi log, không ghi dữ liệu |
| 97 | Chữ ký sai | Không ghi gì |
| 99 hoặc 5xx | Lỗi tạm thời của CSDL hoặc hết thời gian chờ khóa; giao dịch rollback toàn bộ | Cổng gửi lại |

Tham số ký và tên tham số IPN (vnp_TxnRef, vnp_Amount nhân 100, vnp_ResponseCode, vnp_TransactionStatus, vnp_SecureHash) được chốt theo bộ tham số vnp_ chuẩn của VNPay; chúng cần kiểm lại với tài liệu sandbox hiện hành khi viết mã (xem mục 8.2). Gửi email và gọi hoàn tiền không bao giờ nằm trong giao dịch giữ khóa: chúng đi qua bảng outbox rồi tiến trình nền gọi sau commit, với thời gian chờ 30 giây mỗi lời gọi.

Giao diện giữa trình duyệt và máy chủ gồm REST cho thao tác nghiệp vụ và một kênh SSE công khai cho sơ đồ ghế (xem Chương 5). Mã phiên của nhân viên là token ký kèm mốc truy cập, đối chiếu CSDL ở mỗi yêu cầu để thu hồi quyền có hiệu lực ngay (BR-101); phiên khách hết hạn sau 24 giờ.


<!-- @pagebreak -->

# Chương 5. Xử lý tranh chấp tài nguyên và đồng thời

Đây là trọng tâm của đề tài. Chương trình bày các tài nguyên bị tranh chấp, đơn vị loại trừ và thứ tự khóa chống deadlock, rồi đi qua từng cơ chế theo chuỗi nghiệp vụ giữ ghế, thanh toán, hết hạn, hủy vé, hoàn tiền; cuối chương là các lỗi race thật đã tìm ra và sửa trong quá trình thiết kế. Toàn bộ cơ chế dựa vào PostgreSQL ở mức cô lập READ COMMITTED mặc định.

## 5.1. Các tài nguyên bị tranh chấp và kịch bản

<!-- @style align=center italic /-->
*Bảng 5.1. Tài nguyên tranh chấp và kịch bản xung đột điển hình.*

| Tài nguyên | Kịch bản xung đột | Hậu quả nếu không xử lý |
|---|---|---|
| Ghế của một suất chiếu | 1.000 khách cùng xác nhận chọn các ghế chồng lấn; khách trực tuyến và nhân viên quầy cùng chọn một ghế | Một ghế bán cho hai người |
| Quyền giữ ghế của một người | Hai yêu cầu cùng một khách ở hai suất chiếu khác nhau | Vi phạm tối đa một lần giữ ghế chưa kết thúc (BR-04) |
| Lần giữ ghế | IPN báo thành công, khách hủy giữ ghế, công việc quét hết hạn và xác nhận thu tiền mặt đến cùng lúc | Vừa bán ghế vừa giải phóng ghế; vé tạo từ lần giữ ghế đã hết hạn |
| Giao dịch thanh toán | Cổng báo trùng cùng một IPN, đến đồng thời ở hai bản backend | Hai lần đặt, hai bộ vé, hoặc hoàn tiền hai lần |
| Vé | Hủy vé và soát vé cùng lúc; hai nhân viên cùng soát một vé | Vé vừa vào rạp vừa được hoàn tiền; một vé vào hai lần |
| Yêu cầu hoàn tiền | Hai bản backend cùng nhận một dòng hàng đợi; thử lại sau khi cổng đã hoàn | Hoàn tiền hai lần |
| Cấu hình rạp | Hai quản lý cùng sửa một phòng chiếu hoặc một mục giá; sửa sơ đồ ghế trong lúc đang giữ ghế | Mất cập nhật; ghế tồn tại trên suất chiếu nhưng không còn trong phòng |
| Giá trị duy nhất chưa tồn tại | Hai khách đăng ký cùng email; hai cụm rạp cùng tên | Trùng dữ liệu vì chưa có dòng nào để khóa |
| Lịch chiếu | Hai suất chồng giờ cùng phòng | Một phòng chiếu hai phim cùng lúc |

## 5.2. Đơn vị loại trừ (EX)

Phân tích đã gom mọi tranh chấp thành 22 đơn vị loại trừ. Mỗi đơn vị là một thao tác không chia cắt, được hiện thực bằng đúng một giao dịch cơ sở dữ liệu; chỉ lời gọi ra hệ thống ngoài nằm ngoài giao dịch. Giữa các đơn vị có 33 cặp loại trừ (X-01 đến X-33) cho biết thao tác nào không được xen vào thao tác nào, khóa chung nào thực hiện loại trừ và kết cục khi hai thao tác đụng nhau.

<!-- @style align=center italic /-->
*Bảng 5.2. 22 đơn vị loại trừ.*

| Mã | Thao tác không chia cắt | Use case | Khóa chính |
|---|---|---|---|
| EX-01 | Kiểm và giữ cả nhóm ghế, chốt giá | UC-005 | Bảng giá S, phòng S, suất chiếu S, người giữ ghế X, ghế X |
| EX-02 | Xử lý báo kết quả giao dịch: bán ghế, hoặc ghi nhận thanh toán trễ kèm yêu cầu hoàn | UC-005, UC-006 | Lần giữ ghế X, ghế X, giao dịch X |
| EX-03 | Xác nhận đã thu tiền mặt, bán ghế | UC-005 | Lần giữ ghế X, ghế X |
| EX-04 | Hết hạn, hủy giữ ghế: kết thúc lần giữ ghế ở đúng một trạng thái cuối | UC-005 | Lần giữ ghế X |
| EX-05 | Giải phóng ghế sau khi lần giữ ghế kết thúc | UC-005 | Lần giữ ghế S, ghế X |
| EX-06, EX-07, EX-09 | Hủy vé: ghi nhận đã hủy, trả ghế, giữ hạn mức hoàn, tạo yêu cầu hoàn (gộp một giao dịch) | UC-008 | Ghế X, giao dịch X, vé X |
| EX-08 | Cho vé vào, đánh dấu đã sử dụng | UC-009 | Vé X |
| EX-10 | Ghi nhận lần gửi và kết quả hoàn qua cổng | UC-006, UC-008 | Yêu cầu hoàn X |
| EX-11, EX-12 | Đặt giá, đổi giá, bỏ mục giá | UC-013 | Bảng giá X; phòng S, suất chiếu S khi bỏ giá |
| EX-13 | Lập hoặc sửa suất chiếu | UC-014 | Bảng giá S, phòng X, suất chiếu X, lần giữ ghế S, ghế X, vé S, phim S |
| EX-14 | Xóa suất chiếu khỏi lịch | UC-014 | Suất chiếu X, lần giữ ghế S, vé S |
| EX-15 | Sửa phòng chiếu và sơ đồ ghế | UC-012 | Cụm rạp X, bảng giá S, phòng X, suất chiếu S, ghế X |
| EX-16 | Lưu phim đã sửa | UC-010 | Phim X |
| EX-17 | Lưu cụm rạp (kiểm tên duy nhất) | UC-011 | Khóa giá trị tên X, cụm rạp X |
| EX-18, EX-19 | Thêm, xóa phòng chiếu và ghế | UC-012 | Cụm rạp X (và phòng X khi xóa) |
| EX-20 | Đăng ký tài khoản khách (email, số điện thoại duy nhất) | UC-001 | Khóa giá trị email X, số điện thoại X |
| EX-21 | Lưu tài khoản nhân viên mới | UC-017 | Khóa giá trị email nhân viên X |
| EX-22 | Sửa, khóa, mở khóa, đặt lại mật khẩu nhân viên | UC-017 | Nhân viên X |

Ký hiệu S là khóa đọc chung (SELECT FOR SHARE), X là khóa ghi riêng (SELECT FOR NO KEY UPDATE).

## 5.3. Thứ tự hạng khóa chống deadlock

Deadlock chỉ xảy ra khi hai giao dịch lấy khóa theo thứ tự ngược nhau. Thiết kế loại bỏ nó từ gốc bằng cách đánh số mọi loại đối tượng thành 14 hạng và buộc mọi đơn vị loại trừ lấy khóa theo (hạng, thứ tự trong hạng) tăng ngặt. Một thứ tự toàn phần thì không thể có chu trình chờ.

<!-- @style align=center italic /-->
*Bảng 5.3. 14 hạng khóa và thứ tự trong hạng.*

| Hạng | Đối tượng | Thứ tự trong hạng |
|---|---|---|
| 0 | Khóa giá trị tên cụm rạp, rồi cụm rạp | Khóa giá trị trước, rồi mã cụm rạp |
| 1 | Bảng giá | Mã cụm rạp |
| 2 | Phòng chiếu | Mã phòng tăng dần |
| 3 | Suất chiếu | Mã suất tăng dần |
| 4 | Khách hoặc nhân viên (người giữ ghế, tài khoản đang sửa) | Một dòng |
| 5 | Lần giữ ghế | Mã tăng dần |
| 6 | Trạng thái ghế | (mã suất chiếu, mã ghế) số nguyên tăng dần |
| 7 | Giao dịch thanh toán | Mã tăng dần |
| 8 | Vé | Mã tăng dần |
| 9 | Yêu cầu hoàn | Mã tăng dần |
| 10 | Phim | Một dòng |
| 11, 12 | Khóa giá trị email khách, số điện thoại khách (email trước) | Một khóa |
| 13 | Khóa giá trị email nhân viên | Một khóa |

Các quy tắc bổ sung giữ cho thứ tự này đúng trên PostgreSQL thật:

- Khóa trước, đọc và kiểm sau. Ở READ COMMITTED, câu SELECT FOR NO KEY UPDATE chờ khóa rồi trả phiên bản dòng mới nhất sau khi bên giữ khóa commit; kết quả đọc trước khi có khóa không được dùng để quyết định (xem lỗi RF-19 ở mục 5.10).
- Khóa nhiều dòng cùng hạng bằng một câu ORDER BY ... FOR NO KEY UPDATE; câu khóa chỉ lọc theo khóa, không lọc theo trạng thái nghiệp vụ, rồi so số dòng trả về với số dòng cần để dòng đổi trạng thái không bị lọc mất âm thầm.
- Dùng FOR NO KEY UPDATE thay cho FOR UPDATE cho mọi dòng chỉ bị cập nhật cột không phải khóa. Lý do: khi chèn dòng con, PostgreSQL tự lấy khóa FOR KEY SHARE trên dòng cha qua khóa ngoại; khóa này không xung đột với FOR NO KEY UPDATE nhưng xung đột với FOR UPDATE, nên FOR UPDATE tạo chu trình chờ ngoài thứ tự hạng (ví dụ giữ ghế của khách đang giữ dòng khách trong khi IPN của chính khách đó chèn đặt vé tham chiếu dòng khách). Để giữ nguyên tính chất này, không cập nhật cột thuộc chỉ mục unique đầy đủ và không khai báo khóa ngoại cho hai bảng kỹ thuật seat_event, outbox.
- Lớp an toàn khi chờ khóa: giao dịch giữ ghế đặt lock_timeout dưới 1 giây; mọi đơn vị thử lại tối đa 2 lần khi gặp 40P01 (deadlock) hoặc 55P03 (hết thời gian chờ khóa); khóa ghế của EX-01 dùng NOWAIT nên ghế đang bị người khác khóa trả ngay "ghế vừa có người chọn" mà không chờ.
- Hạn tổng 1,8 giây cho giữ ghế, tính từ lúc nhận yêu cầu, bao cả chờ lấy kết nối từ pool và mọi lần thử, nên mọi kết quả kể cả từ chối đều trả không quá 1,8 giây, nhỏ hơn 2 giây của NFR-06.

Đối chiếu từng cặp loại trừ cho thấy chuỗi lõi (giữ ghế, IPN, hết hạn, hủy vé, hoàn tiền) lấy khóa theo hạng 5, 6, 7, 8, 9 tăng ngặt, không có đơn vị nào lấy ngược hạng.

## 5.4. Giữ ghế: tất cả hoặc không ghế nào (EX-01)

![Hình 5.1. Biểu đồ tuần tự giữ ghế EX-01 (UC-005).](diagrams/hinh-5-1-seq-hold-seats.png =600x)

<!-- @style align=center italic /-->
*Hình 5.1. Biểu đồ tuần tự giữ ghế EX-01 (UC-005).*

Trình tự trong một giao dịch: (1) đọc không khóa mã phòng và cụm rạp của suất chiếu để biết cần khóa hạng nào; (2) lần lượt khóa bảng giá S, phòng chiếu S, suất chiếu S; sau khi khóa suất chiếu, so lại phòng, khác thì từ chối vì suất chiếu đã đổi (BR-54); (3) khóa dòng người giữ ghế X, đồng thời kiểm trạng thái hoạt động và mốc truy cập của nhân viên quầy; (4) nếu người này còn lần giữ ghế chưa kết thúc cũ thì khóa nó, và lần giữ ghế cũ đã quá hạn được chuyển Hết hạn ngay trong giao dịch để BR-04 coi là đã kết thúc; (5) lấy một lần thời điểm hiện tại của CSDL, kiểm đã mở bán, chưa tới giờ bắt đầu; (6) khóa các ghế theo thứ tự (mã suất chiếu, mã ghế) với NOWAIT; (7) kiểm cả nhóm còn trống, xác định giá theo bảng giá, tạo SeatHold, đặt liên kết hiện tại của từng ghế, ghi seat_event là câu cuối trước COMMIT.

Hai lớp bảo vệ khác nhau cùng chặn các ca sai:

- Hai khách chọn cùng ghế: khóa ghế tuần tự hóa; bên đến sau thấy ghế đã đang giữ (hoặc nhận lỗi NOWAIT ngay) và bị từ chối, cả nhóm không giữ ghế nào.
- Cùng một khách ở hai suất khác nhau: khóa dòng người giữ ghế hạng 4 tuần tự hóa; CSDL thêm chỉ mục unique từng phần theo trạng thái ACTIVE cho khách và cho nhân viên quầy làm lưới an toàn.
- Xác nhận lặp khi phản hồi bị mất: mã yêu cầu (UUID do trình duyệt sinh cho mỗi lần xác nhận) là cột unique của lần giữ ghế; yêu cầu lặp nhận lại đúng lần giữ ghế cũ thay vì bị báo vi phạm BR-04.

## 5.5. Hết hạn và giải phóng ghế

Hết hạn là sự thật được tính, không phải sự kiện được chạy. Mỗi lần giữ ghế lưu expiry_time bằng thời điểm giữ cộng 10 phút theo đồng hồ CSDL. Mọi thao tác quyết định theo hạn (IPN, hủy giữ ghế, xác nhận thu tiền, kiểm BR-04) so thời điểm hiện tại của CSDL với expiry_time sau khi đã khóa lần giữ ghế. Một lần giữ ghế còn nhãn Đang giữ nhưng đã quá hạn được xử lý như Hết hạn, dù công việc nền chạy trễ 5 giây hay 50 giây. Công việc nền chỉ quyết định khi nào ghế được trả về trống (NFR-07).

![Hình 5.3. Biểu đồ tuần tự dọn hết hạn và giải phóng ghế (EX-04, EX-05).](diagrams/hinh-5-3-seq-expiry-sweep.png =600x)

<!-- @style align=center italic /-->
*Hình 5.3. Biểu đồ tuần tự dọn hết hạn và giải phóng ghế (EX-04, EX-05).*

Công việc nền chạy mỗi 10 giây trên mọi bản backend, dùng pool kết nối riêng 5 kết nối để không giành kết nối với yêu cầu người dùng, gồm hai bước theo lô 200 dòng với ngân sách 8 giây:

1. Quét hết hạn (EX-04): chọn tối đa 200 lần giữ ghế Đang giữ đã quá hạn bằng FOR NO KEY UPDATE SKIP LOCKED, chuyển Hết hạn các dòng còn quá hạn. SKIP LOCKED không chờ, nên các bản backend chia lô cho nhau và không tạo chu trình chờ.
2. Quét giải phóng (EX-05): với lần giữ ghế đã ở trạng thái cuối khác Đã hoàn tất mà ghế vẫn còn trỏ tới, khóa ghế rồi trả về Trống kèm một dòng seat_event mỗi suất chiếu. Bước này cũng sửa các trường hợp tiến trình chết giữa EX-04 và EX-05.

Chạy lặp an toàn nhờ liên kết hiện tại: EX-04 chỉ đổi lần giữ ghế đang Đang giữ; EX-05 chỉ đổi ghế có current_hold_id đúng bằng lần giữ ghế đang xử lý. Hai bản backend quét chồng, quét hai lần hay khởi động lại giữa chừng đều không trả nhầm ghế vừa được người khác giữ lại. Không có bộ đếm giờ trong bộ nhớ nên khởi động lại không làm mất lần giữ ghế nào. Về thông lượng: 4.000 lần giữ ghế hết hạn cùng giây là 20 lô, vài giây trên một bản, xa dưới 60 giây của NFR-07.

## 5.6. IPN idempotent

![Hình 5.2. Biểu đồ tuần tự xử lý IPN EX-02 (UC-005, UC-006).](diagrams/hinh-5-2-seq-handle-ipn.png =600x)

<!-- @style align=center italic /-->
*Hình 5.2. Biểu đồ tuần tự xử lý IPN EX-02 (UC-005, UC-006).*

IPN có thể đến trùng, đến muộn, đến sai thứ tự hoặc đồng thời ở hai bản backend. Điểm vào của hệ thống kiểm chữ ký và số tiền theo cách của cổng, rồi chạy EX-02 trong một giao dịch: khóa lần giữ ghế X, các ghế của nó X, giao dịch X (hạng 5, 6, 7). Khóa lần giữ ghế làm mọi báo của cùng một lần giữ ghế tuần tự, kể cả hai báo giống hệt đến cùng lúc ở hai bản. Quyết định dưới khóa, lấy thời điểm hiện tại của CSDL một lần:

<!-- @style align=center italic /-->
*Bảng 5.4. Bảng quyết định xử lý báo kết quả giao dịch dưới khóa.*

| Điều kiện sau khi có khóa | Kết quả | Trả lời cổng |
|---|---|---|
| Thành công, giao dịch chưa xử lý, lần giữ ghế Đang giữ và chưa quá hạn | Bán ghế, lần giữ ghế Đã hoàn tất, tạo lần đặt và vé, đánh dấu giao dịch đã xử lý, ghi hàng đợi email vé và seat_event | 00 |
| Thành công, chưa xử lý, lần giữ ghế Hết hạn, Đã hủy, Thanh toán thất bại, quá hạn, hoặc là giao dịch thứ hai của lần giữ ghế đã có vé | Chuyển Hết hạn trước nếu cần; ghi thanh toán trễ, tạo yêu cầu hoàn toàn bộ kèm khóa chống hoàn trùng, ghi hàng đợi hoàn tiền; không tạo vé | 00 |
| Thành công, giao dịch đã xử lý | Báo trùng: tăng bộ đếm, không tạo vé, không hoàn thêm | 02 |
| Thất bại | Ghi nhận thất bại; chỉ khi là giao dịch tạo sau cùng và lần giữ ghế còn Đang giữ mới chuyển Thanh toán thất bại và trả ghế | 00 |
| Chữ ký sai | Không ghi gì | 97 |
| Mã giao dịch không tồn tại, không có mã tham chiếu lần giữ ghế hợp lệ | Ghi log xử lý thủ công | 01 |
| Lỗi tạm thời, hết thời gian chờ khóa | Rollback toàn bộ | 99 hoặc 5xx |

Tính idempotent đến từ hai tầng. Tầng ứng dụng: trạng thái dưới khóa, xử lý lần hai thấy cờ đã xử lý. Tầng CSDL làm lưới an toàn: một lần đặt cho mỗi lần giữ ghế, một vé cho mỗi ghế đã bán chưa hủy, một yêu cầu hoàn cho mỗi khóa chống hoàn trùng, một giao dịch thanh toán cho mỗi mã giao dịch của cổng, tối đa một giao dịch ở trạng thái TICKETED cho mỗi lần giữ ghế. Gửi lại IPN khi lỗi tạm thời an toàn vì giao dịch đã rollback toàn bộ.

Giao dịch PENDING được tạo trước khi khách sang trang thanh toán, nên IPN đến sớm không thể không tìm thấy bản ghi; nếu bước đó lỗi, mã tham chiếu lần giữ ghế trong IPN vẫn đủ để EX-02 tự tạo bản ghi. Bản ghi chờ không bao giờ bị xóa.

## 5.7. Hủy vé, hoàn tiền không trùng và outbox

![Hình 5.4. Biểu đồ tuần tự hủy vé một giao dịch (EX-06, EX-07, EX-09).](diagrams/hinh-5-4-seq-cancel-ticket.png =600x)

<!-- @style align=center italic /-->
*Hình 5.4. Biểu đồ tuần tự hủy vé một giao dịch (EX-06, EX-07, EX-09).*

Hủy vé vé mua trực tuyến gộp ba việc vào một giao dịch theo thứ tự hạng 6, 7, 8 rồi chèn yêu cầu hoàn (hạng 9): ghi nhận vé đã hủy, trả ghế về trống và giữ hạn mức hoàn của giao dịch. Chỉ lời gọi cổng hoàn tiền nằm ngoài. Nhờ vậy không có trạng thái vé đã hủy mà ghế còn kẹt Đã bán, hoặc khách mất tiền không dấu vết (BR-42).

Gọi cổng đi qua bảng outbox. Dòng outbox được chèn cùng giao dịch tạo ra nó (loại REFUND_GATEWAY, EMAIL_TICKET hoặc EMAIL_REFUND) và có khóa idempotency duy nhất. Vòng đời một dòng:

1. Claim từng dòng: tiến trình nền chạy một câu UPDATE chọn một dòng đến hạn bằng FOR NO KEY UPDATE SKIP LOCKED, đặt claim_token ngẫu nhiên và claimed_until bằng thời điểm CSDL cộng 120 giây, rồi commit ngay. Không claim trước một lô, để hạn claim luôn tính từ lúc dòng bắt đầu được xử lý.
2. Gọi ngoài giao dịch, thời gian chờ 30 giây mỗi lời gọi (BR-43), không giữ khóa hay kết nối khi chờ. Với hoàn tiền, giao dịch 1 của lần gửi làm hàng rào: cập nhật claimed_until với điều kiện claim_token còn là của mình; 0 dòng thì lỗi mất claim và không gọi cổng. Bất biến: chỉ bên giữ claim_token hợp lệ tại giao dịch 1 mới được gọi cổng.
3. Ghi kết quả có điều kiện claim_token vẫn là của mình. Lỗi thì hẹn lại sau 1, 5, 15 phút; sau 3 lần thử lại (tổng 4 lần gửi) mà vẫn lỗi thì yêu cầu hoàn sang trạng thái Cần xử lý thủ công, vẫn nằm trong CSDL và có truy vấn liệt kê trong tài liệu vận hành (BR-41).
4. Tiến trình chết sau claim: hết claimed_until thì dòng được nhận lại, nên không có dòng kẹt vĩnh viễn. Trước mỗi lần gửi lại (từ lần hai), hệ thống tra cứu kết quả hoàn của cổng theo khóa.

Hoàn tiền không trùng nhờ ba lớp độc lập: khóa chống hoàn trùng bất biến qua mọi lần thử (mã giao dịch kèm mã vé với hủy vé, mã giao dịch kèm loại yêu cầu với hoàn toàn bộ); chỉ mục unique cho yêu cầu hoàn theo mã vé, theo khóa và một yêu cầu hoàn toàn bộ cho mỗi giao dịch; ràng buộc tổng đã hoàn không vượt số đã thanh toán (BR-26). Email là at-least-once (có thể gửi trùng trong trường hợp hiếm), chấp nhận được; idempotency_key được đặt làm Message-ID để phía nhận loại trùng. Không có email hoàn tiền cho hoàn một vé.

## 5.8. Lưới an toàn ở cơ sở dữ liệu

Mọi quy tắc tranh chấp đều có ràng buộc ở CSDL làm lưới thứ hai, để khi một đường ghi quên khóa hay sai thứ tự thì giao dịch thất bại thay vì để dữ liệu sai.

<!-- @style align=center italic /-->
*Bảng 5.5. Tình huống sai và ràng buộc chặn.*

| Tình huống sai | Ràng buộc chặn | Kết quả |
|---|---|---|
| Hai người giữ một ghế | Một dòng trạng thái ghế cho mỗi (suất chiếu, ghế) với đúng một liên kết hiện tại; ràng buộc CHECK giữa trạng thái và liên kết; trigger không cho đổi liên kết đang có sang giá trị khác | Báo vi phạm check |
| Ghế bán cho hai người | Unique từng phần trên vé theo (suất chiếu, ghế) khi vé chưa hủy | 23505 |
| Một người có hai lần giữ ghế đang giữ | Unique từng phần theo trạng thái ACTIVE cho khách và cho nhân viên quầy | 23505 |
| Hai suất chiếu chồng giờ cùng phòng | Ràng buộc EXCLUDE dùng chỉ mục GiST trên (phòng, khoảng thời gian bận) cho suất còn trong lịch | 23P01 |
| Lần giữ ghế, vé, giao dịch, yêu cầu hoàn đổi trạng thái trái bảng | 8 trigger kiểm bảng chuyển trạng thái; cập nhật có điều kiện trạng thái cũ | 23514 hoặc 0 dòng |
| IPN xử lý hai lần | Unique mã giao dịch, giao dịch TICKETED một lần cho mỗi lần giữ ghế, một đặt vé mỗi lần giữ ghế, unique mã giao dịch của cổng | 23505 |
| Hoàn trùng hoặc hoàn vượt | Unique khóa chống hoàn trùng, theo vé, hoàn toàn bộ một lần; CHECK tổng đã hoàn | 23505, 23514 |
| Hai bản gửi cùng dòng outbox | claim_token, claimed_until, SKIP LOCKED, unique khóa idempotency | Bên mất claim ghi 0 dòng |
| Hai khách cùng email, hai cụm rạp cùng tên | Unique trên giá trị chuẩn hóa (hàm lower, btrim, gộp khoảng trắng) | 23505 |
| Sửa dữ liệu bán trên vé đã bán | Trigger chặn đổi giá, tên phim, cụm rạp, phòng trên vé | 23514 |
| Xóa phòng, ghế còn được tham chiếu | Mọi khóa ngoại ON DELETE RESTRICT | 23503 |

Ràng buộc EXCLUDE (cần extension btree_gist) là cách duy nhất trong thiết kế để cấm chồng giờ mà không phụ thuộc thứ tự thao tác của ứng dụng. Khoảng thời gian bận của một suất là giờ bắt đầu đến giờ kết thúc cộng 15 phút dọn phòng; hàm tính khoảng được khai báo IMMUTABLE vì phép cộng phút cố định không phụ thuộc múi giờ, điều kiện để dùng trong EXCLUDE.

Với các giá trị duy nhất chưa có dòng nào để khóa (email, số điện thoại, tên cụm rạp), thiết kế dùng advisory lock mức giao dịch theo giá trị chuẩn hóa, thay vì bảng khóa giá trị hay chỉ dựa vào lỗi 23505. Chỉ dựa vào chỉ mục unique bị loại vì lỗi hiện muộn, đảo thứ tự kiểm, làm hỏng giao dịch đang mở và cho chu trình chờ khi hai cụm rạp đổi tên cho nhau; bảng khóa giá trị bị loại vì phình theo số giá trị từng xuất hiện. Advisory lock hai số nguyên (hạng cộng 1000, băm giá trị) không có dữ liệu lưu thêm, tự nhả khi commit, rollback hoặc kết nối chết, nằm trong bộ phát hiện deadlock của PostgreSQL và lấy được đúng vị trí hạng 0, 11, 12, 13. Chỉ mục unique vẫn có mặt như lưới an toàn cuối.

## 5.9. Cập nhật sơ đồ ghế trong 3 giây

Sơ đồ ghế chỉ cần chiều máy chủ đến trình duyệt, nên dùng Server-Sent Events. Mỗi giao dịch đổi trạng thái ghế chèn một dòng vào bảng seat_event (một dòng cho mỗi suất chiếu bị ảnh hưởng, không phải mỗi ghế) như câu cuối cùng trước COMMIT, và ghi mã sự kiện vào event_seq của từng ghế đổi. Mỗi bản backend đọc bảng này mỗi 500 ms theo con trỏ và phát đến các kết nối SSE của mình. Vì mã lấy trước, commit sau, người đọc có cửa sổ chồng 10 giây và loại trùng; trình duyệt chỉ áp sự kiện khi mã lớn hơn event_seq đang có của ghế đó, nên phát lặp, phát lại hay lệch thứ tự đều vô hại. Ảnh chụp sơ đồ ghế (REST) kèm con trỏ; kết nối SSE mở với tham số after bằng con trỏ đó và nối lại tự phát lại. Dòng sự kiện quá 10 phút bị dọn; con trỏ quá cũ thì máy chủ yêu cầu tải lại sau độ trễ ngẫu nhiên 0 đến 3 giây để không dồn tải. Ngân sách thời gian khoảng 1 giây (chờ tối đa 500 ms cộng truy vấn cộng ghi), còn dư cho đuôi độ trễ.

## 5.10. Các lỗi race thật đã tìm và sửa trong quá trình thiết kế

Thiết kế được review nhiều vòng và các lỗi dưới đây là lỗi thật, tìm ra khi đọc chéo giữa các tài liệu, khi dựng kịch bản hai phiên trên PostgreSQL 16 hoặc khi thiết kế ca kiểm thử. Bảng liệt kê lỗi, kịch bản thất bại và cách sửa; cột mức ghi theo bản review, dấu gạch là lỗi không được xếp mức riêng.

<!-- @style align=center italic /-->
*Bảng 5.6. Lỗi race thật và cách sửa.*

| Mã | Mức | Lỗi | Kịch bản thất bại | Cách sửa |
|---|---|---|---|---|
| R12-01, R12-02 | Nghiêm trọng | Hủy vé chia nhiều giao dịch | Tiến trình chết giữa các giao dịch: vé đã hủy mà ghế kẹt Đã bán mãi mãi; hoặc khách đã bị trừ tiền mà không có yêu cầu hoàn, không dấu vết; không hủy lại được vì vé đã hủy | Gộp ghi nhận hủy, trả ghế, giữ hạn mức và tạo yêu cầu hoàn thành đúng một giao dịch theo thứ tự hạng 6, 7, 8, rồi 9; chỉ lời gọi cổng nằm ngoài |
| R12-03 | Cao | Thử lại hủy vé không chạy tiếp được | Chèn yêu cầu hoàn vi phạm unique khóa chống hoàn trùng làm rollback cả giao dịch; bước trả ghế không bao giờ chạy | Hết đường thử lại sau khi gộp một giao dịch |
| R12-04 | - | Yêu cầu hoàn kẹt IN_FLIGHT | Tiến trình chết sau giao dịch 1: khi nhận lại dòng, bắt đầu lần gửi mới ném lỗi trạng thái mãi, khoản hoàn không về thủ công, không email | Thêm chuyển trạng thái thoát khỏi IN_FLIGHT; nhận lại dòng thì tra cứu kết quả hoàn trước khi gửi lại |
| RF-01 | Nghiêm trọng | Claim outbox theo lô mở đường hoàn tiền hai lần | Thông số claim theo lô (20 dòng, 5 luồng, hạn 120 giây, tới 60 giây mỗi dòng) phá giả định tiến trình còn sống luôn xong trước khi hết claim: dòng xử lý muộn trong lô quá claimed_until, bản khác nhận lại và gọi cổng trong khi bản đầu vẫn đang gửi | Claim từng dòng; hàng rào claim_token ở giao dịch 1 và tính lại hạn từ lúc đó; hạn lời gọi theo claimed_until; số lần thử theo attemptCount của yêu cầu hoàn |
| X2 / trigger | - | Chọn lại ghế sau hết hạn bị trigger từ chối | Lần giữ ghế cũ đã quá hạn mà công việc quét chưa chạy; khách chọn lại đúng ghế: giải phóng rồi giữ lại trong bộ nhớ ghi một câu UPDATE đổi liên kết từ H0 sang H1, trigger bảo vệ chặn | Giữ nguyên lưới an toàn ở CSDL; đổi cách gọi: lưu ngay trạng thái Trống bằng một UPDATE riêng, rồi giữ lại ở lần UPDATE thứ hai trong cùng giao dịch; kiểm 5 ca trên PostgreSQL 16 đều đạt |
| RF-04 / BR-93 | Trung bình | Báo thất bại của giao dịch cũ làm mất ghế | Khách bấm thanh toán hai lần; giao dịch cũ báo thất bại muộn trong khi giao dịch mới đang chờ: ghế bị trả về trống | Chỉ báo thất bại của giao dịch tạo sau cùng mới chuyển lần giữ ghế sang Thanh toán thất bại |
| R13D-01 / BR-92 | Trung bình | Đổi phòng của suất từng có vé | Khóa ngoại RESTRICT chặn xóa trạng thái ghế còn vé tham chiếu, kể cả vé đã hủy, nhưng quy tắc nghiệp vụ lại cho phép sửa | Đổi phòng chỉ cho phép khi suất chưa từng có vé; nếu không thì xóa suất cũ, lập suất mới |
| RV-01 | - | Dãy kết thúc lần giữ ghế và bán ghế lặp ở bốn nơi | Sửa một quy tắc phải sửa đồng thời bốn chỗ; một lỗi lệch đã từng xảy ra | Tách một lớp chung gom trình tự Expire, Cancel, FailPayment, Complete, ReleaseHold và tạo vé, không I/O |
| Khóa ngầm | - | FOR UPDATE xung đột khóa ngầm khóa ngoại | Giữ ghế giữ dòng khách bằng FOR UPDATE trong khi IPN của khách đó chèn đặt vé tham chiếu dòng khách: chu trình chờ ngoài thứ tự hạng | Mọi khóa X trên dòng chỉ bị cập nhật cột không phải khóa dùng FOR NO KEY UPDATE; chỉ mục unique theo biểu thức để đổi tên không nâng khóa; kiểm trên PostgreSQL 16 |
| Phát sự kiện | - | NOTIFY trong giao dịch giữ ghế | Khóa toàn cơ sở dữ liệu ở bước commit xếp hàng các commit; đuôi độ trễ có thể vượt 2 giây | Dùng bảng sự kiện seat_event và đọc theo con trỏ |
| RF-18 | Cao | Hủy vé và soát vé cùng vé không bị chặn bởi lưới CSDL | Câu UPDATE có điều kiện trạng thái cũ khớp 0 dòng không báo lỗi, trigger không chạy: vé Used, ghế Trống, vẫn có yêu cầu hoàn 70%; tái hiện được bằng hai phiên psql | Đề xuất: kiểm số dòng bị ảnh hưởng ở mọi câu ghi trạng thái, dùng vé do câu khóa trả về, thêm trigger ghế rời Đã bán thì vé phải đã hủy; chưa áp vào tài liệu thiết kế |
| RF-19 | Cao | Thao tác quản trị quyết định trên đối tượng đọc trước khóa | Hai quản lý cùng sửa phòng 7: bên sau kiểm mốc trên bản cũ nên ghi đè; tạo suất chiếu theo sơ đồ ghế cũ khiến suất có ghế không còn trong phòng | Đề xuất: dùng đối tượng do hàm khóa trả về, thêm điều kiện mốc thay đổi, thêm ca kiểm thử có rào chắn; chưa áp vào tài liệu thiết kế |

Hai dòng cuối (RF-18, RF-19) là phát hiện của lượt review cuối, đã có đề xuất sửa nhưng chưa được đồng bộ vào các tài liệu; xem mục 8.2. Giá trị của chúng cho đề tài là chỉ ra đúng loại lỗi mà "lưới an toàn" dễ che giấu: câu cập nhật có điều kiện trạng thái cũ không bao giờ báo lỗi khi khớp 0 dòng, nên cần kiểm số dòng. Mọi lỗi trên đều được phát hiện ở giai đoạn thiết kế, trước khi có mã nguồn, và mỗi lỗi đều dẫn đến ca kiểm thử đồng thời tương ứng (Chương 7).


<!-- @pagebreak -->

# Chương 6. Thiết kế chi tiết

Chương này trình bày thiết kế lớp tiêu biểu, thiết kế cơ sở dữ liệu (ERD và từ điển dữ liệu 20 bảng) và thiết kế giao diện (40 màn hình). Toàn bộ thiết kế lớp phủ 29 package có hành vi với 177 phần tử (146 lớp, 31 interface); báo cáo chỉ giữ các lớp gắn với tranh chấp.

## 6.1. Thiết kế lớp chi tiết

### 6.1.1. Cấu trúc lớp của nhóm giữ ghế

![Hình 6.1. Biểu đồ lớp package SeatBooking (PKG-13): dịch vụ giữ ghế và các công việc nền.](diagrams/hinh-6-1-class-pkg13.png =600x)

<!-- @style align=center italic /-->
*Hình 6.1. Biểu đồ lớp package SeatBooking (PKG-13): dịch vụ giữ ghế và các công việc nền.*

Package SeatBooking gồm dịch vụ đặt vé BookTicketsService (HoldSeats, GetHold, CancelHold, StartOnlinePayment, ConfirmCashReceived), dịch vụ sơ đồ ghế SeatMapService (GetSnapshot, OpenStream), ba công việc nền (HoldExpiryJob, SeatReleaseJob, SeatEventCleanupJob) và tiện ích HoldSettlement. Các lớp này chỉ phụ thuộc interface kho dữ liệu (ISeatHoldRepository, ISeatStatusRepository, IUnitOfWork...) do Domain định nghĩa; hiện thực SQL nằm ở package Persistence.

### 6.1.2. Mô tả một số lớp tiêu biểu

<!-- @style align=center italic /-->
*Bảng 6.1. Các lớp thiết kế tiêu biểu.*

| Lớp (package) | Vai trò | Operation chính |
|---|---|---|
| SeatHold (Ticketing) | Entity giữ vòng đời lần giữ ghế; trạng thái cuối bất biến | NewSeatHold (expiryTime = now + HoldDuration), Expire, Complete, Cancel, FailPayment, CheckHolderHasNoUnfinishedHold |
| HoldSettlement (Ticketing) | Tiện ích gom trình tự kết thúc lần giữ ghế và bán ghế, không I/O | End (hết hạn, hủy, thất bại, kèm trả ghế), Sell, FinishSale |
| BookTicketsService (SeatBooking) | Điều phối UC-005 thành các giao dịch | HoldSeats (tách thành ba hàm private), CancelHold, StartOnlinePayment, ConfirmCashReceived |
| PaymentReportService (PaymentRefund) | Xử lý báo kết quả của cổng, quyết định dưới khóa theo bảng quyết định ở mục 5.6 | HandleIpn, ResolveReturnedPayment |
| RefundService, RefundRequest | Tạo và gửi yêu cầu hoàn, giữ hạn mức hoàn | NewFullRefund, NewTicketRefund, NewCashRefund, BeginAttempt, RecordResult (REFUNDED, WAITING_RETRY hoặc MANUAL_REQUIRED, tối đa 4 lần), ProcessRefund |
| LockOrderGuard (Persistence) | Kiểm lúc chạy thứ tự khóa: lấy khóa có hạng nhỏ hơn hạng đã giữ thì báo lỗi vi phạm thứ tự, nâng từ S lên X trên cùng một dòng cũng là vi phạm | Acquire, AcquireValue |
| PgUnitOfWork (Persistence) | Mở giao dịch READ COMMITTED, đặt lock_timeout, thử lại 40P01 và 55P03, hạn tổng, chế độ chỉ đọc cho báo cáo (REPEATABLE READ) | Do, runOnce, LockValue |
| PaymentGatewayManager, VnpayUrlBuilder, VnpaySigner, VnpayRefundClient (PaymentGatewayClient) | Adapter che giao thức VNPay sau interface IPaymentGateway | BuildPaymentURL, Sign, Verify, Refund, Query |
| SeatEventPoller, SeatEventHub (SeatEventHub) | Đọc seat_event theo con trỏ mỗi 500 ms và phát tới kết nối SSE | pollOnce, Subscribe |
| ShowtimeSchedulingRules, SeatMapEditor (CinemaOperations) | Quy tắc lịch chiếu và sửa sơ đồ ghế tách khỏi entity | Kiểm dọn phòng, ngày chiếu, tính thay đổi sơ đồ |

Một điểm thiết kế đáng nói là LockOrderGuard: thứ tự khóa không chỉ là quy ước trong tài liệu mà được kiểm bằng mã. Mọi lời gọi khóa của Persistence đi qua guard; vi phạm thứ tự hạng bị phát hiện ngay trong kiểm thử thay vì chờ deadlock xảy ra ở môi trường thật.

### 6.1.3. Các mẫu thiết kế áp dụng

<!-- @style align=center italic /-->
*Bảng 6.2. Mẫu thiết kế và lý do chọn.*

| Mẫu | Vấn đề giải quyết |
|---|---|
| Repository | Tách SQL khóa dòng khỏi logic nghiệp vụ; mỗi interface kho khai báo hạng khóa của từng operation |
| Unit of Work | Mỗi EX là đúng một giao dịch; control không biết kiểu kết nối CSDL; kèm vòng thử lại |
| Adapter | Giao thức VNPay (chữ ký, tham số, mã trả lời) không khớp interface thuần của hệ thống |
| Outbox | Gọi cổng hoàn tiền và gửi email không giữ khóa nhưng không được mất khoản hoàn khi tiến trình chết |
| Factory Method tĩnh | Quy tắc khởi tạo riêng của entity (hạn giữ ghế, khóa chống hoàn trùng, trạng thái đầu) |
| Pure Fabrication | HoldSettlement gom dãy lặp ở bốn operation của hai service |
| Không dùng State (GoF) | Năm máy trạng thái chỉ có 3 đến 5 trạng thái, hành vi khác nhau chỉ là chấp nhận hay từ chối; enumeration cộng guard là đủ |

## 6.2. Thiết kế cơ sở dữ liệu

Lược đồ PostgreSQL gồm 20 bảng, 14 trigger (13 trigger thường và một constraint trigger hoãn tới COMMIT), 27 chỉ mục, một ràng buộc EXCLUDE và hai hàm chuẩn hóa norm_email, norm_name. Mỗi lớp thực thể ánh xạ một bảng; ba lớp con của Staff được gộp vào một bảng staff có cột vai trò; tài khoản quản trị viên ở bảng riêng đúng một dòng.

### 6.2.1. Sơ đồ thực thể - liên kết (ERD)

![Hình 6.2. Sơ đồ thực thể - liên kết mức khái niệm.](diagrams/hinh-6-2-erd-conceptual.png =600x)

<!-- @style align=center italic /-->
*Hình 6.2. Sơ đồ thực thể - liên kết mức khái niệm.*

![Hình 6.3. Sơ đồ thực thể - liên kết mức logic và vật lý.](diagrams/hinh-6-3-erd-logical.png =600x)

<!-- @style align=center italic /-->
*Hình 6.3. Sơ đồ thực thể - liên kết mức logic và vật lý.*

### 6.2.2. Từ điển dữ liệu rút gọn

<!-- @style align=center italic /-->
*Bảng 6.3. Từ điển dữ liệu rút gọn của 20 bảng.*

| Bảng | Nội dung | Cột chính | Ràng buộc đáng chú ý |
|---|---|---|---|
| cinema | Cụm rạp | id, name, province, address, last_changed_at | unique theo tên đã chuẩn hóa; trigger buộc có bảng giá khi COMMIT |
| movie | Phim | id, title, duration_minutes, release_date, end_of_run_date, genre, age_rating, trailer | mốc thay đổi dùng cho sửa không ghi đè |
| movie_format | Định dạng phát hành của phim | movie_id, movie_format | định dạng 2D hoặc 3D |
| auditorium | Phòng chiếu | id, cinema_id, name, auditorium_type | loại STANDARD, 4DX, IMAX; unique (cụm rạp, tên chuẩn hóa) |
| auditorium_format | Định dạng phòng chiếu được | auditorium_id, movie_format | khóa ghép |
| seat | Ghế vật lý | id, auditorium_id, row_code, seat_number, seat_type, in_seat_map | loại STANDARD, VIP, COUPLE; unique vị trí khi còn trong sơ đồ |
| showtime | Suất chiếu | id, auditorium_id, movie_id, start_time, sale_open_time, end_time, status | EXCLUDE chồng giờ; mở bán trước giờ chiếu; trạng thái IN_SCHEDULE hoặc DELETED một chiều |
| price_list | Bảng giá của cụm rạp | cinema_id | một bảng giá cho mỗi cụm rạp |
| price_entry | Mục giá | cinema_id, auditorium_type, movie_format, seat_type, time_band, ticket_price, removed | khóa theo tổ hợp bốn thuộc tính |
| customer | Tài khoản khách | id, email, phone_number, password_hash | unique email chuẩn hóa, unique số điện thoại |
| staff | Nhân viên (mọi vai trò trừ quản trị viên) | id, email, full_name, role, cinema_id, status, access_changed_at | trạng thái ACTIVE hoặc LOCKED; vai trò và cụm rạp khớp BR-78; email không đổi sau khi tạo |
| administrator | Quản trị viên | id, email, password_hash | CHECK đúng một dòng |
| seat_hold | Lần giữ ghế | id, showtime_id, customer_id, box_office_clerk_id, hold_ref, request_id, status, hold_time, expiry_time | đúng một người giữ; unique từng phần theo ACTIVE; expiry_time bằng hold_time cộng 10 phút |
| seat_status | Trạng thái ghế theo suất | showtime_id, seat_id, state, held_price, current_hold_id, current_ticket_id, event_seq | khóa chính ghép; CHECK trạng thái và liên kết; khóa ngoại ghép |
| payment_transaction | Giao dịch thanh toán | id, seat_hold_id, code, amount, status, gateway_transaction_no, paid_at, refunded_total, duplicate_report_count | trạng thái PENDING, FAILED, TICKETED, LATE_PAYMENT; CHECK đã hoàn không vượt đã thanh toán |
| booking | Lần đặt vé | id, booking_code, seat_hold_id, customer_id, booked_at | unique mã đặt vé; một lần đặt cho mỗi lần giữ ghế |
| ticket | Vé | id, booking_id, showtime_id, seat_id, ticket_code, price, movie_title, cinema_name, status | unique ghế theo suất khi chưa hủy; giá trị bán bất biến |
| refund_request | Yêu cầu hoàn | id, payment_transaction_id, ticket_id, idempotency_key, request_type, refund_amount, attempt_count, status | loại FULL, TICKET_GATEWAY, TICKET_CASH; unique khóa; attempt_count từ 0 đến 4 |
| seat_event | Sự kiện đổi ghế | id, showtime_id, created_at, items | items là mảng JSON không rỗng; không có khóa ngoại |
| outbox | Hàng đợi gửi | id, kind, source_id, status, attempt_count, next_attempt_at, claim_token, claimed_until, idempotency_key | claim_token và claimed_until cùng rỗng hoặc cùng có |

<!-- @style align=center italic /-->
*Bảng 6.4. Chi tiết bảng seat_status (trạng thái ghế theo suất chiếu).*

| Tên trường | Kiểu | Ràng buộc |
|---|---|---|
| showtime_id | BIGINT | Khóa chính ghép, khóa ngoại showtime |
| seat_id | BIGINT | Khóa chính ghép, khóa ngoại seat |
| state | VARCHAR(10) | AVAILABLE, HELD hoặc SOLD; mặc định AVAILABLE |
| held_price | BIGINT | Giá chốt, lớn hơn 0; rỗng khi AVAILABLE |
| current_hold_id | BIGINT | Lần giữ ghế hiện tại; chỉ có khi HELD; khóa ngoại ghép (id, showtime_id) tới seat_hold |
| current_ticket_id | BIGINT | Vé hiện tại; chỉ có khi SOLD; unique khi không rỗng |
| event_seq | BIGINT | Mã sự kiện của lần đổi gần nhất, không âm; trình duyệt dùng để áp sự kiện đúng thứ tự |

<!-- @style align=center italic /-->
*Bảng 6.5. Chi tiết bảng seat_hold (lần giữ ghế).*

| Tên trường | Kiểu | Ràng buộc |
|---|---|---|
| id | BIGINT | Khóa chính, tự sinh |
| showtime_id | BIGINT | Khóa ngoại suất chiếu |
| customer_id, box_office_clerk_id | BIGINT | Đúng một trong hai khác rỗng |
| hold_ref | VARCHAR(36) | Unique; mã tham chiếu truyền cho cổng thanh toán |
| request_id | VARCHAR(36) | Unique; mã yêu cầu chống xác nhận lặp |
| status | VARCHAR(16) | ACTIVE, COMPLETED, EXPIRED, CANCELLED, PAYMENT_FAILED |
| hold_time, expiry_time | TIMESTAMPTZ | expiry_time bằng hold_time cộng 10 phút |

<!-- @style align=center italic /-->
*Bảng 6.6. Chi tiết bảng outbox (hàng đợi gửi ra hệ thống ngoài).*

| Tên trường | Kiểu | Ràng buộc |
|---|---|---|
| kind | VARCHAR(16) | REFUND_GATEWAY, EMAIL_TICKET, EMAIL_REFUND |
| source_id | BIGINT | Mã bản ghi nguồn (không có khóa ngoại để tránh khóa ngầm) |
| status | VARCHAR(10) | PENDING, SUCCEEDED, EXHAUSTED |
| attempt_count, next_attempt_at | INTEGER, TIMESTAMPTZ | Không âm; lịch thử lại 1, 5, 15 phút |
| claim_token, claimed_until | UUID, TIMESTAMPTZ | Cùng rỗng hoặc cùng có |
| idempotency_key | VARCHAR(100) | Unique; dùng làm Message-ID của email |

## 6.3. Thiết kế giao diện

Giao diện là một SPA React thích ứng, gồm 40 màn hình (SCR-01 đến SCR-40) phục vụ mọi use case có tác nhân người (UC-006 không có màn hình vì tác nhân chính là cổng thanh toán). Mỗi màn hình có hình ảnh, danh sách chức năng, định nghĩa thuộc tính trường và thông điệp (MSG-01 đến MSG-134).

<!-- @style align=center italic /-->
*Bảng 6.7. Danh sách màn hình theo tác nhân.*

| Tác nhân | Màn hình | Use case |
|---|---|---|
| Khách | SCR-01 đăng nhập khách, SCR-02 trang chủ, SCR-03 chọn suất chiếu, SCR-04 chọn ghế, SCR-05 giữ ghế và thanh toán, SCR-06 kết quả đặt vé, SCR-07 chọn vé cần hủy, SCR-08 kết quả hủy vé, SCR-22 đăng ký, SCR-23 danh sách phim, SCR-24 thông tin phim, SCR-25 tra cứu lịch chiếu, SCR-26 lịch sử đặt vé, SCR-27 vé của lần đặt | UC-001, 003, 004, 005, 007, 008 |
| Nhân viên quầy | SCR-09 trang chủ quầy, SCR-10 chọn suất và ghế, SCR-11 giữ ghế và thu tiền mặt, SCR-12 in vé, SCR-13 tìm vé theo mã đặt vé, SCR-14 hoàn tiền mặt, SCR-15 kết quả hủy tại quầy | UC-005, UC-008 |
| Nhân viên soát vé | SCR-16 soát vé | UC-009 |
| Quản lý cụm rạp | SCR-17 trang chủ, SCR-18 bảng giá, SCR-19 danh sách suất chiếu, SCR-20 lập hoặc sửa suất chiếu, SCR-28 danh sách phòng chiếu, SCR-29 lập hoặc sửa phòng chiếu, SCR-30 báo cáo cụm rạp | UC-012 đến UC-015 |
| Quản lý chuỗi | SCR-31 trang chủ, SCR-32 danh sách phim, SCR-33 form phim, SCR-34 danh sách cụm rạp, SCR-35 form cụm rạp, SCR-36 báo cáo toàn chuỗi | UC-010, 011, 016 |
| Quản trị viên | SCR-21 đăng nhập nhân viên, SCR-37 danh sách tài khoản, SCR-38 form tài khoản, SCR-39 đổi tên, SCR-40 đặt lại mật khẩu | UC-017 |

![Hình 6.4. Sơ đồ dịch chuyển màn hình của khách.](diagrams/hinh-6-4-screen-transition.png =600x)

<!-- @style align=center italic /-->
*Hình 6.4. Sơ đồ dịch chuyển màn hình của khách.*

### 6.3.1. SCR-04 Chọn ghế

Màn hình trung tâm của đề tài. Sơ đồ ghế nhận sự kiện đổi ghế qua SSE và cập nhật trong vòng 3 giây; ghế đang chọn vẫn trống trên hệ thống cho đến khi xác nhận; ghế đang chọn mà bị người khác lấy thì tự bỏ chọn và báo; mất kết nối thì có nút tải lại, nối lại thì tải lại ảnh chụp kèm con trỏ.

```text
+------------------------------------------------------------+
| CineBook   Trang chủ                                         |
|------------------------------------------------------------|
| Chọn ghế                                                     |
| Phim A, 2D, Phòng 3, 15/11/2026 19:30                        |
| (!) Ghế F7, F8 vừa có người khác giữ hoặc mua ...             |
| (o) Đang cập nhật trực tiếp                                   |
|                    ====== MÀN HÌNH ======                     |
|  A  [A1][A2][A3][A4][A5][A6][A7][A8][A9]                       |
|  F  [F1][F2][F3][F4][F5][F6][#F7][#F8][F9]   #=viền đỏ       |
|  M  [M1 ========][M2 ========][M3 ========]   ghế đôi        |
| Chú giải: [ ] Trống  [v] Đang chọn  [/L] Đang được giữ  [X] Đã bán |
| Đã chọn: A3, A4 - 2 ghế (tối đa 8)                            |
|                                      [ Xác nhận chọn ghế ]     |
+------------------------------------------------------------+
```

### 6.3.2. SCR-05 Giữ ghế và thanh toán

Hiển thị ghế đã giữ, giá từng ghế đã chốt, tổng tiền và đồng hồ đếm ngược 10 phút. Nút thanh toán chuyển khách sang trang VNPay; nút hủy giữ ghế giải phóng ghế ngay. Khi khách quay về mà chưa có kết quả, màn hình hiển thị đang xác nhận và hỏi lại mỗi 2 giây, tối đa 60 giây.

```text
+------------------------------------------------------------+
| CineBook   Trang chủ                                         |
|------------------------------------------------------------|
| Giữ ghế và thanh toán                                        |
| +--------------------------------+ +----------------------+ |
| | Phim A, 2D, Phòng 3            | | Thời gian giữ ghế    | |
| | 15/11/2026 19:30               | | còn lại              | |
| | Ghế    | Loại    |   Giá vé    | |      08:42           | |
| | F7     | Ghế VIP | 120.000 đ   | | Hết hạn lúc 19:02:11 | |
| | F8     | Ghế VIP | 120.000 đ   | +----------------------+ |
| | Tổng tiền (2 vé)   240.000 đ   |                          |
| +--------------------------------+                          |
|                 [ Huỷ giữ ghế ]  [ Thanh toán qua VNPay ]   |
+------------------------------------------------------------+
```

### 6.3.3. SCR-16 Soát vé

Chạy trên điện thoại hoặc máy tính bảng qua HTTPS để dùng camera. Nhân viên chọn suất chiếu một lần rồi quét liên tiếp; kết quả hiển thị một lý do duy nhất nếu từ chối. Không có ô nhập mã tay (NFR-13).

```text
+------------------------------------------------------------+
| CineBook                                                     |
|------------------------------------------------------------|
| Soát vé                                                      |
| Suất chiếu đang soát *  [ Phim A, 2D, Phòng 3, 15/11 19:30 v ]|
| +----------------------------------+                         |
| |        [ vùng camera 4:3 ]       |   Hướng camera vào mã QR |
| +----------------------------------+   trên vé của khách      |
| +----------------------------------------------------------+ |
| | VÉ HỢP LỆ - Mời khách vào phòng chiếu                     | |
| | CB0001234 | Phim A, 2D | CineBook Cầu Giấy | Phòng 3 (IMAX)| |
| | 15/11/2026 19:30 | F7 | Ghế VIP | 120.000 đ               | |
| +----------------------------------------------------------+ |
| (hoặc) TỪ CHỐI: vé đã sử dụng.                               |
+------------------------------------------------------------+
```


<!-- @pagebreak -->

# Chương 7. Kiểm chứng thiết kế

Vì chưa có mã nguồn, thiết kế được kiểm chứng bằng bốn cách: review thiết kế theo các nguyên lý coupling và cohesion, review cuối theo chuỗi truy vết trọng tâm, thiết kế unit test và ca kiểm thử đồng thời cho từng operation, và chạy thật lược đồ CSDL cùng bộ ca thử trên PostgreSQL 16.

## 7.1. Review thiết kế (X1)

Review thiết kế đánh giá toàn bộ lớp thiết kế 2.x theo các nhóm tiêu chí: coupling, cohesion, SOLID, GRASP, design smell, nhất quán giữa các artifact, dữ liệu và phụ thuộc package. Phạm vi gồm 29 package, 177 phần tử có hành vi (146 lớp, 31 interface), 233 mã kiểu phụ trợ, 355 mã quan hệ và 20 bảng.

<!-- @style align=center italic /-->
*Bảng 7.1. Kết quả review thiết kế X1.*

| Hạng mục | Kết quả |
|---|---|
| Phát hiện | 28 phát hiện RV-01 đến RV-28 |
| Đã xử lý | 25 phát hiện (gồm 17 của lần review mở rộng, xử lý trong lần đồng bộ cuối); RV-02 hết hiệu lực do quyết định sau đó |
| Còn hiệu lực | 2 phát hiện mức Thấp (RV-21: hai lớp con của Staff gần như rỗng; RV-26: số phụ thuộc tiêm lớn ở bốn service điều phối), chấp nhận có lý do |
| Nghiêm trọng, Cao, Trung bình còn lại | 0 |
| Nhóm không có vi phạm | SOLID LSP, GRASP Pure Fabrication, Indirection, Protected Variations, Law of Demeter, KISS, YAGNI, chuẩn hóa dữ liệu, khóa, kiểu tiền |

Ví dụ các phát hiện có tác động: RV-01 (dãy kết thúc lần giữ ghế lặp ở bốn nơi, sửa bằng HoldSettlement), RV-05 và RV-16 (hai lớp truy cập dữ liệu quá lớn, 39 và 52 operation, tách thành chín Pg Store theo interface), RV-04 (công việc hết hạn gộp với dọn seat_event, tách riêng), RV-07 (hằng 10 phút lặp ở CHECK và mã), RV-28 (quy tắc chỉ nhân viên quầy mới giữ ghế không có ở CSDL, thêm trigger).

Review cuối (đối chiếu chuỗi giữ ghế, IPN, bán vé, hết hạn, hủy vé, hoàn tiền) kết luận chuỗi lõi đứng vững khi soát từng cặp loại trừ: mọi giao dịch lấy khóa theo hạng tăng ngặt, khóa ngầm của khóa ngoại rơi vào dòng mà chính giao dịch đã giữ ở chế độ tương thích, hết hạn tính theo đồng hồ CSDL sau khi khóa. Review này đồng thời chỉ ra 11 phát hiện mới (0 nghiêm trọng, 2 cao, 4 trung bình, 5 thấp), trong đó RF-18 và RF-19 là các lỗi race ở mục 5.10; 17 phát hiện của lần review trước đã được sửa và kiểm lại.

## 7.2. Thiết kế unit test (X2)

Bộ thiết kế unit test dùng các kỹ thuật phân vùng tương đương, giá trị biên, bảng quyết định, chuyển trạng thái và đường đi theo đồ thị luồng điều khiển, với mục tiêu 100% C1 cho operation ưu tiên Cao và 100% C0 cho phần còn lại. Hệ thống ca kiểm thử mã từ TC-001 đến TC-895.

<!-- @style align=center italic /-->
*Bảng 7.2. Số liệu tổng hợp bộ ca kiểm thử X2.*

| Hạng mục | Số lượng |
|---|---|
| Tổng số ca kiểm thử hiện hành | 889 |
| Ca unit (đối tượng thuần hoặc test double) | 836 |
| Ca tích hợp (PostgreSQL thật, nhiều goroutine hoặc nhiều bản backend) | 53 |
| Ưu tiên Cao | 726 (677 unit, 49 tích hợp) |
| Ưu tiên Trung bình | 163 (159 unit, 4 tích hợp) |
| Hệ phủ | Phân vùng (EC), biên (BV), bảng quyết định (DT), chuyển trạng thái (CT), nhánh ngoại lệ (CE) |
| Tình huống hỏng (Bảng hỏng của kiến trúc) | 10 trên 10 tình huống có ca thử hồi phục |

Điểm khác biệt của bộ ca là ca tích hợp đồng thời: mỗi cặp loại trừ có ca chạy hai goroutine (hoặc hai bản backend) sau rào chắn, lặp 1.000 lần, và với mỗi cặp thử cả hai thứ tự đến cho kết cục khác nhau. Ví dụ: hai goroutine cùng giữ một nhóm ghế (TC-363), hai thứ tự đến của giữ ghế (TC-364), hai suất chiếu cùng một khách (TC-365), giữ ghế khi ghế đang bị khóa (TC-367, phải trả trong dưới 200 ms), chọn lại ghế sau hết hạn (TC-368), hai IPN giống hệt đồng thời (TC-370), IPN với hủy giữ ghế (TC-371), IPN sát mốc hết hạn (TC-372), quét giải phóng chạy chồng hai bản backend (TC-374), 4.000 lần giữ ghế hết hạn cùng giây (TC-375), hai nhân viên cùng soát một vé (TC-376). Các ca tải T1 đến T7 (1.000 giữ ghế song song, 4.000 kết nối SSE, hết hạn hàng loạt, hàng đợi hoàn tiền, claim không trùng, khóa giá trị, báo cáo) được thiết kế với cấu hình chuẩn 2 bản backend, 1 PostgreSQL, công cụ k6; các ca này chưa chạy vì chưa có mã.

Độ phức tạp chu trình được kiểm ở mức thiết kế: ba hàm công khai HoldSeats (21), HandleIpn (13) và ProcessRefund (13) vượt ngưỡng 10 đã được tách thành các hàm private nhỏ hơn 10; mọi operation còn lại có V(G) từ 2 đến 8.

## 7.3. Kiểm thử lược đồ CSDL trên PostgreSQL 16

Lược đồ được áp lên PostgreSQL 16.16 (Docker, bộ mã UTF8) bằng psql với tùy chọn dừng khi lỗi: 0 lỗi, 20 bảng. Bộ ca thử viết bằng SQL chạy trong một giao dịch rồi ROLLBACK; mỗi ca khai báo mã SQLSTATE mong đợi (hoặc 00000 nếu thành công) và tự báo ĐẠT hoặc TRƯỢT. Kết quả: 212 trên 212 ca đạt.

<!-- @style align=center italic /-->
*Bảng 7.3. Các nhóm ca thử lược đồ.*

| Nhóm | Nội dung kiểm |
|---|---|
| B | Hàm chuẩn hóa norm_email, norm_name và danh mục |
| C | Tên cụm rạp, tên phòng, ghế |
| D | Phim, mục giá, định dạng |
| E | Tài khoản khách, nhân viên, quản trị viên |
| F | Suất chiếu và ràng buộc EXCLUDE chồng giờ |
| G | Lần giữ ghế và trạng thái ghế |
| H | Thanh toán, đặt vé, vé: IPN idempotent |
| I | Yêu cầu hoàn tiền |
| J | Hàng đợi outbox và seat_event |
| K | Các mẫu câu khóa của thiết kế chạy được (cú pháp, tên bảng, cột) |

Ngoài bộ ca một phiên, các kịch bản hai phiên psql đồng thời được dùng để tái hiện lỗi thiết kế (mục 5.10), trong đó có kịch bản hủy vé và soát vé cùng vé của RF-18. Bộ ca thử đã phát hiện nhiều lỗi lược đồ thật, ví dụ trigger bảo vệ liên kết ghế chặn luồng chọn lại ghế, và ràng buộc khóa ngoại ghép chặn đổi vai trò nhân viên đã từng giữ ghế (thay bằng trigger). Phần kiểm thử không bao gồm đo tải; việc khẳng định không có deadlock 40P01 và p95 giữ ghế dưới 1,2 giây ở 1.000 giao dịch song song vẫn phải chờ có mã nguồn.

## 7.4. Đồng bộ liên artifact

Hồ sơ thiết kế được giữ nhất quán qua sáu lần đồng bộ (X3) với mã đồng bộ SY đánh đến SY-143, mỗi lần áp các phát hiện của review và kiểm thử lên các artifact bị ảnh hưởng. Công cụ kiểm hình thức (check_artifacts) báo 0 lỗi; các cảnh báo còn lại chủ yếu là tọa độ sơ đồ lệch lưới. Dấu vết này cho thấy quy trình review, sửa, kiểm lại được thực hiện thật chứ không dừng ở một bản nháp.

<!-- @pagebreak -->

# Chương 8. Kết luận

## 8.1. Kết quả đạt được

- Một hồ sơ phân tích thiết kế đầy đủ cho CineBook: 162 yêu cầu nguồn, 16 use case, 121 quy tắc nghiệp vụ (113 hiệu lực), 18 yêu cầu phi chức năng đo được, 55 lớp phân tích, 29 package thiết kế, 177 phần tử thiết kế có hành vi, 20 bảng CSDL và 40 màn hình.
- Giải pháp xử lý tranh chấp trọng tâm: 22 đơn vị loại trừ, 33 cặp loại trừ, thứ tự khóa 14 hạng được kiểm bằng mã (LockOrderGuard), giữ ghế tất cả hoặc không với NOWAIT và hạn tổng 1,8 giây, hết hạn tính theo đồng hồ CSDL, IPN idempotent hai tầng, outbox với claim_token chống hoàn tiền trùng, advisory lock cho giá trị duy nhất chưa tồn tại và EXCLUDE chống chồng giờ.
- Lưới an toàn ở CSDL (14 trigger, chỉ mục unique từng phần, EXCLUDE, khóa ngoại ghép) được kiểm bằng 212 ca thử đạt trên PostgreSQL 16.
- Chứng cứ kiểm chứng: 28 phát hiện review thiết kế, 889 ca kiểm thử được thiết kế (53 ca tích hợp đồng thời) và nhiều lỗi race thật được tìm ra và sửa ngay ở giai đoạn thiết kế.

## 8.2. Hạn chế

- Chưa có mã nguồn: mọi khẳng định về hiệu năng (NFR-06 đến NFR-09), về không deadlock dưới tải và về độ trễ 3 giây của sơ đồ ghế mới là kết quả lập luận và thiết kế ca đo, chưa được đo thật. Các ca tải T1 đến T7 cần chạy ở Project III.
- Giả định về VNPay chưa kiểm với tài liệu sandbox hiện hành. Q-132: thiết kế không dựa vào việc cổng tự loại trùng yêu cầu hoàn theo khóa; cờ hỗ trợ tra cứu hoàn mặc định tắt, nên lần gửi hoàn thứ hai trở đi nếu không tra cứu được sẽ chuyển sang xử lý thủ công thay vì gửi lại tự động. Q-355: tên và ý nghĩa các tham số IPN (vnp_TxnRef, vnp_Amount nhân 100, vnp_ResponseCode, vnp_TransactionStatus, vnp_SecureHash), số lần và khoảng cách gửi lại IPN, hành vi khi RspCode khác 00 và 02, và việc có IPN cho giao dịch thất bại hay không đều chốt theo bộ tham số chuẩn và cần kiểm lại.
- Các phát hiện của lượt review cuối chưa được áp vào tài liệu: RF-18 (kiểm số dòng bị ảnh hưởng ở các câu ghi trạng thái có điều kiện), RF-19 (thao tác quản trị phải dùng đối tượng do hàm khóa trả về), RF-20 (nếu IPN không bao giờ tới thì khách mất tiền: cần công việc đối soát tra cứu giao dịch), RF-21 (tự thử lại hoàn tiền khi tra cứu không được lệch với mô tả của đề bài) và các phát hiện mức trung bình, thấp khác.
- Hai phát hiện thiết kế mức Thấp (RV-21, RV-26) được chấp nhận có lý do.
- Quy mô tài liệu nguồn rất lớn so với một báo cáo; báo cáo này chỉ là bản cô đọng, các bảng chi tiết (đặc tả đầy đủ từng use case, 889 ca kiểm thử, đặc tả từng màn hình) nằm trong thư mục design của repo.

## 8.3. Hướng phát triển cho Project III

- Cài đặt theo thứ tự rủi ro: lược đồ CSDL và bộ ca thử (đã có), rồi PgUnitOfWork với LockOrderGuard, rồi EX-01 đến EX-05 (giữ ghế, IPN, hết hạn, giải phóng), rồi outbox và hoàn tiền, sau đó các use case quản trị và báo cáo.
- Áp các đề xuất RF-18 đến RF-21 vào thiết kế trước khi cài đặt các phần liên quan; bổ sung công việc đối soát giao dịch với API truy vấn của VNPay.
- Kiểm tài liệu sandbox VNPay để đóng các giả định Q-132 và Q-355; chạy bộ ca tích hợp đồng thời TC-363 đến TC-376 và các ca tải T1 đến T7 với k6 trên cấu hình chuẩn.
- Nếu p95 giữ ghế vượt 1,2 giây ở 1.000 giao dịch song song, chuyển khóa hạng 1 đến 3 sang advisory lock có chế độ chia sẻ theo cùng thứ tự, như phương án dự phòng đã thiết kế.

<!-- @pagebreak -->

# Tài liệu tham khảo

[1] Nguyễn Nhật Quang, *Bài giảng Phân tích và Thiết kế Hệ thống hướng đối tượng*, Trường Công nghệ Thông tin và Truyền thông, Đại học Bách Khoa Hà Nội.

[2] G. Booch, J. Rumbaugh, I. Jacobson, *The Unified Modeling Language User Guide*, 2nd ed., Addison-Wesley, 2005.

[3] C. Larman, *Applying UML and Patterns*, 3rd ed., Prentice Hall, 2004.

[4] The PostgreSQL Global Development Group, *PostgreSQL 16 Documentation: Chapter 13 Concurrency Control, Explicit Locking, Advisory Locks, Exclusion Constraints*, https://www.postgresql.org/docs/16/.

[5] M. Fowler, *Patterns of Enterprise Application Architecture*, Addison-Wesley, 2002.

[6] C. Richardson, *Microservices Patterns*, Manning, 2018 (mẫu Transactional Outbox).

[7] VNPAY, *Tài liệu tích hợp cổng thanh toán VNPAY (môi trường sandbox)*, https://sandbox.vnpayment.vn/apis/.

[8] The Go Authors, *The Go Programming Language Specification*, https://go.dev/ref/spec.

[9] WHATWG, *HTML Living Standard: Server-sent events*, https://html.spec.whatwg.org/multipage/server-sent-events.html.

<!-- @pagebreak -->

# Phụ lục

## Phụ lục A. Một số ca kiểm thử tiêu biểu

Bảng dưới liệt kê một số ca trong 889 ca của bộ thiết kế unit test (mã TC theo tài liệu nguồn).

<!-- @style align=center italic /-->
*Bảng A.1. Một số ca kiểm thử tiêu biểu.*

| Mã | Mục tiêu | Điều kiện đầu và dữ liệu vào | Kết quả mong đợi |
|---|---|---|---|
| TC-001 | Tạo lần giữ ghế cho khách (unit) | Người giữ là khách 7, now = 10:00:00.000 | Trạng thái ACTIVE, hạn 10:10:00.000 |
| TC-005, TC-006, TC-007 | Giá trị biên hết hạn (unit) | Lần giữ ghế ACTIVE hạn E; Expire tại E trừ 1 ms, E, E cộng 1 ms | Trả false và vẫn ACTIVE; trả true, EXPIRED; trả true, EXPIRED |
| TC-363 | Hai khách cùng giữ ghế 101 đến 103 (tích hợp, lặp 1.000 lần) | Hai goroutine cùng gọi giữ ghế sau rào chắn | Đúng một lần thành công, lần kia báo ghế không còn trống |
| TC-365 | Cùng một khách ở hai suất chiếu (tích hợp, lặp 1.000 lần) | Hai goroutine cùng khách 7 giữ ghế suất 55 và suất 56 | Đúng một lần thành công, lần kia báo người giữ đang bận; khách có đúng một lần giữ ghế ACTIVE |
| TC-367 | Ghế đang bị khóa bởi giao dịch khác (tích hợp) | Ghế 101 bị khóa 5 giây; khách 7 giữ ghế 101 | Trả ghế vừa có người chọn trong dưới 200 ms, không chờ lock_timeout, không thử lại |
| TC-368 | Chọn lại ghế sau hết hạn khi job chưa quét (tích hợp) | Khách 7 có lần giữ ghế H0 đã quá hạn giữ ghế 101; khách chọn lại 101 và 102 | Thành công: H0 sang EXPIRED, ghế 101 do lần giữ mới giữ, không vi phạm trigger |
| TC-370 | Hai IPN thành công giống hệt đến đồng thời (tích hợp, lặp 1.000 lần) | Hai bản backend nhận IPN cùng lúc | Đúng một lần đặt, một vé mỗi ghế; một lần xử lý, một lần báo trùng; bộ đếm báo trùng bằng 1; không 40P01 |
| TC-371 | IPN thành công đồng thời với hủy giữ ghế (tích hợp, hai thứ tự đến) | Hai thứ tự lấy khóa lần giữ ghế | Thứ tự A: IPN bán ghế, hủy giữ ghế nhận lỗi lần giữ ghế không còn hiệu lực; thứ tự B: không tạo vé, thanh toán xử lý như thanh toán trễ |
| TC-375 | 4.000 lần giữ ghế hết hạn cùng giây (tích hợp, tải) | 2 bản backend chạy lịch 10 giây | Mọi ghế trống không quá 60 giây sau hạn; khoảng 20 lô |
| TC-376 | Hai nhân viên cùng soát một vé (tích hợp, lặp 1.000 lần) | Vé UNUSED, hai CheckTicket đồng thời | Đúng một lần được vào, một lần báo đã sử dụng; vé ở trạng thái USED |

## Phụ lục B. Quy trình pipeline phân tích thiết kế

Hồ sơ được tạo qua một chuỗi bước có đầu ra là các artifact trong thư mục design, mỗi bước có review và đồng bộ ngược khi phát hiện sai lệch. Số hiệu bước dùng làm tên artifact.

<!-- @style align=center italic /-->
*Bảng A.2. Các bước của quy trình phân tích thiết kế.*

| Bước | Nội dung | Đầu ra chính |
|---|---|---|
| P00 | Chuẩn hóa yêu cầu | 162 REQ, phạm vi, bên liên quan, câu hỏi mở |
| P01 | Tác nhân | 8 tác nhân |
| P02 (và P02R) | Xác định use case và review | 16 use case |
| P03 | Mô hình use case | Biểu đồ use case tổng quát |
| P04 | Đặc tả use case | Luồng chính, thay thế, dữ liệu vào ra, biểu đồ hoạt động, sổ BR |
| P05 | Từ điển thuật ngữ | 66 thuật ngữ |
| P06 | Đặc tả bổ sung | 18 NFR, 121 BR |
| P07 | Phân tích từng use case | Lớp, tuần tự, giao tiếp theo luồng |
| P08 | Mô hình phân tích hợp nhất | 55 lớp, 22 EX, 14 hạng khóa, vòng đời trạng thái |
| P09 | Thiết kế kiến trúc | Lựa chọn kiến trúc, package, hiện thực EX bằng PostgreSQL, triển khai |
| P10 | Phần tử thiết kế | Subsystem, interface, package thiết kế |
| P11a, P11b | Giao diện người dùng và giao diện hệ thống | 40 màn hình; 5 subsystem hệ thống |
| P12 | Thiết kế lớp | Lớp, operation, method, trạng thái, quan hệ |
| P13 | Mô hình dữ liệu | ERD, lược đồ SQL 20 bảng, bộ ca thử |
| X1 | Review thiết kế | 28 phát hiện |
| X2 | Thiết kế unit test | 889 ca kiểm thử |
| X3 | Đồng bộ | 6 lần, mã SY đến SY-143 |

Mỗi bước kết thúc bằng một lượt review độc lập; các phát hiện được ghi thành đề xuất sửa artifact trước, rồi lượt đồng bộ X3 áp lên các artifact bị ảnh hưởng và chạy lại phần kiểm máy. Cách làm này là lý do thiết kế tranh chấp được đối chiếu chéo nhiều lần giữa phân tích, kiến trúc, lớp, dữ liệu và kiểm thử.

