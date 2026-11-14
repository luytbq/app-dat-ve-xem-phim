# P07 - Phân tích use case UC-006 Hoàn tiền thanh toán trễ - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
| --- | --- |
| Bước | P07 |
| Phiên bản | 1.2 |
| Thay đổi 1.2 | Thêm bảng thao tác không chia cắt theo P04 Mục 8 (mục 4.1); // recordRefundedAmount cộng tổng đã hoàn và kiểm lại không vượt số tiền đã thanh toán trong một thao tác theo giao dịch (BR-26); không đổi luồng, message và sơ đồ; đồng bộ đầu vào đã dùng |
| Đầu vào đã dùng | 00-Conventions.md; 00-Concurrency.md (M3); project-profile.md; P04-uc-specs/UC-006-refund-late-payment.md 1.9 (bảng Thao tác nguyên tử); P01-actors.md 1.2; P02-usecases.md 1.9; P03-usecase-model.md 1.2; P05-glossary.md 1.2; P06-supplementary-spec.md 1.4; P04-uc-specs/_BR-register.md (đã gộp BR-01 đến BR-147); P07-uc-analysis/UC-005-book-tickets-analysis.md 1.2 (đầu lô) (F1, F3.4, F8 b), Câu hỏi mở, Vấn đề còn mở; sổ đăng ký AC lấy từ file này; P07-uc-analysis/_review-P07-batch.md |; không dùng mã nào trong dải Q được cấp theo C10
| Phạm vi | UC-006 |
| Mã Q, ASM cuối đã cấp | Q-90; không có ASM (NGHIEM_NGAT) |

## 1. Bối cảnh use case

| Thuộc tính | Giá trị |
| --- | --- |
| Mã và tên UC | UC-006 Hoàn tiền thanh toán trễ (Refund Late Payment) |
| Tác nhân chính | ACT-07 Cổng thanh toán (Hệ thống ngoài; tự báo kết quả giao dịch ở bước 1, vào thời điểm do cổng quyết định) |
| Tác nhân phụ | ACT-07 Cổng thanh toán (Hệ thống ngoài; nhận yêu cầu hoàn tiền ở bước 4 và trả kết quả ở bước 5); ACT-08 Dịch vụ email (Hệ thống ngoài; chỉ nhận email thông báo hoàn tiền) |
| Include (UC) | Không có |
| Được include bởi (UC) | Không có |
| Extend (UC, điểm mở rộng, điều kiện) | Không có |
| Được extend bởi (UC, điểm mở rộng, điều kiện) | Không có |
| Use case liên quan không qua include, extend | UC-005 Đặt vé: cùng nhận kết quả giao dịch từ cổng qua control tiếp nhận dùng chung PaymentReportController (AC-C-PaymentReportController, UC-005 là chủ); báo thành công đến sau thời điểm hết hạn hoặc sau trạng thái cuối của lần giữ ghế thuộc UC-006 (BR-14, BR-15, BR-37, BR-86), luồng 2b thuộc UC-005 (EV-07); Q-83. UC-008 Huỷ vé: cùng hoàn tiền qua cổng, cùng entity RefundRequest, mỗi yêu cầu hoàn có khoá chống hoàn trùng riêng (BR-43, Q-87) |
| Tác nhân thời gian | Không có. P02 không có use case do tác nhân thời gian kích hoạt trên đối tượng mà UC-006 tạo hoặc đổi, nên không có message hẹn mốc. Thời hạn chờ kết quả hoàn tiền 30 giây (BR-43) là thời hạn nội bộ, vẽ bằng message tự gọi theo A2. |
| File P07 đã có được dùng làm sổ đăng ký AC | UC-005-book-tickets-analysis.md (15 mã AC: AC-B-BookTicketsForm, AC-B-CounterBookTicketsForm, AC-B-PaymentGateway, AC-B-EmailService, AC-C-BookTicketsController, AC-C-PaymentReportController, AC-E-Customer, AC-E-BoxOfficeClerk, AC-E-Showtime, AC-E-PriceList, AC-E-SeatStatus, AC-E-SeatHold, AC-E-PaymentTransaction, AC-E-Booking, AC-E-Ticket). |

## 2. Đặc tả bổ sung

| Bước UC | Thực hiện bởi | Mô tả trong đặc tả | Mô tả bổ sung (hệ thống làm gì bên trong) | Nguồn (BR, GL, REQ) |
| --- | --- | --- | --- | --- |
| 1 | Cổng thanh toán | Báo kết quả của một giao dịch thanh toán (xem Dữ liệu vào 1). | Không đổi | GL-17, NFR-16, REQ-79 |
| 2 | Hệ thống | Tra giao dịch theo mã giao dịch; với mã không phải của giao dịch hệ thống đã tạo thì tra lần giữ ghế theo mã tham chiếu lần giữ ghế kèm trong báo của cổng. Kiểm tra: kết quả thành công, nhận ra giao dịch, giao dịch chưa được xử lý, lần giữ ghế ở trạng thái Hết hạn, Đã huỷ, Thanh toán thất bại hoặc Đã hoàn tất; các kiểm tra và bước 3 là một thao tác xử lý tuần tự theo lần giữ ghế. | Control tiếp nhận dùng chung (PaymentReportController, UC-005 là chủ) tìm lần giữ ghế theo mã giao dịch đã lưu hoặc theo mã tham chiếu lần giữ ghế trong báo, rồi giao cho lần giữ ghế đúng một thao tác không chia cắt (settlePaymentReport, cùng trách nhiệm với UC-005). Trong thao tác đó giao dịch kiểm chưa được xử lý và lần giữ ghế kiểm còn hiệu lực qua checkHoldStillActive; lần giữ ghế Đang giữ mà đã quá thời điểm hết hạn đã được chuyển sang Hết hạn trước nên UC-006 chỉ thấy trạng thái cuối (Q-88). Không tìm được lần giữ ghế thì control chỉ ghi log lỗi (2e). | BR-14, BR-15, BR-37, BR-38, BR-40, BR-85, BR-86, GL-25, GL-31, REQ-136, REQ-160, REQ-161 |
| 3 | Hệ thống | Ghi nhận giao dịch là thanh toán trễ chờ hoàn tiền và không tạo vé. | Trong cùng thao tác của bước 2, giao dịch thanh toán được đánh dấu thanh toán trễ chờ hoàn tiền, kèm lý do hoàn và đã xử lý, nên báo đến sau của cùng giao dịch thấy trạng thái này. Giao dịch thứ hai chưa có bản ghi thì lần giữ ghế tạo giao dịch thanh toán mới từ mã giao dịch và số tiền trong báo bằng chính trách nhiệm recordPaymentTransaction của UC-005 (Q-90). Không tạo vé, không đổi trạng thái lần giữ ghế và ghế. | BR-14, BR-15, BR-37, BR-40, BR-85, GL-51, GL-13 |
| 4 | Hệ thống | Yêu cầu cổng thanh toán hoàn toàn bộ số tiền đã thanh toán của giao dịch, kèm khoá chống hoàn trùng của yêu cầu hoàn này (mã giao dịch và loại yêu cầu hoàn toàn bộ); số tiền lấy từ giao dịch hệ thống đã tạo, hoặc từ báo của cổng với giao dịch thứ hai. | Giao dịch thanh toán kiểm khoản hoàn là toàn bộ số tiền đã thanh toán và tổng đã hoàn không vượt số này, rồi tạo yêu cầu hoàn toàn bộ; yêu cầu hoàn sinh khoá chống hoàn trùng từ mã giao dịch và loại yêu cầu. Control bắt đầu chờ tối đa 30 giây, yêu cầu hoàn ghi nhận một lần gửi, rồi chuyển số tiền hoàn và khoá cho cổng qua boundary. Mọi lần thử lại dùng lại cùng yêu cầu hoàn và cùng khoá. | BR-14, BR-15, BR-26, BR-37, BR-40, BR-43, GL-20, GL-44, GL-45, Q-87 |
| 5 | Cổng thanh toán | Trả về kết quả hoàn tiền thành công. | Không đổi | GL-02, NFR-17 |
| 6 | Hệ thống | Ghi nhận giao dịch đã được hoàn toàn bộ số tiền hoàn. | Kết quả hoàn tiền là kết quả trả về của lời gọi hoàn (Q-91); control ngừng chờ. Giao dịch thanh toán cộng số tiền hoàn vào tổng đã hoàn, yêu cầu hoàn ghi kết quả thành công. | BR-26, BR-37, GL-45 |
| 7 | Hệ thống | Gửi email thông báo hoàn tiền cho khách qua dịch vụ email (xem Dữ liệu ra 1, Dữ liệu ra 2). | Giao dịch thanh toán cung cấp mã giao dịch, số tiền hoàn và lý do hoàn; lần giữ ghế lấy email của khách giữ ghế và tên phim, giờ bắt đầu từ suất chiếu (suất chiếu Đã xoá vẫn tra được, BR-58). Control chuyển nội dung cho dịch vụ email qua boundary và không chờ kết quả gửi. | BR-15, BR-58, BR-89, GL-06, REQ-90, REQ-116, REQ-157, NFR-18 |
| 2a | Hệ thống | Ghi nhận lần báo trùng, không tạo vé và không yêu cầu hoàn tiền thêm. | Giao dịch thanh toán tăng số lần báo trùng. Không tạo vé, không tạo yêu cầu hoàn; vé của giao dịch (nếu đã tạo ở UC-005) giữ nguyên. | BR-37, REQ-110, GL-12 |
| 2b | - | - | Lần giữ ghế còn hiệu lực chưa quá hạn: thao tác xử lý báo trả về kết quả bán ghế và UC-005 xử lý tiếp (bước 12 đến 15, EV-07); UC-006 không ghi gì. | EV-07, BR-86 |
| 2c | Hệ thống | Ghi nhận kết quả thất bại và không hoàn tiền. | Lần giữ ghế đã Hết hạn (kể cả vừa được chuyển từ Đang giữ quá hạn) hoặc Đã huỷ: giao dịch thanh toán ghi nhận kết quả thất bại báo muộn. Không có khoản hoàn vì khách chưa mất tiền. | BR-39, BR-86, REQ-133 |
| 2d | Hệ thống | Ghi nhận kết quả thất bại và không hoàn tiền. | Giao dịch nhận ra: giao dịch thanh toán ghi nhận kết quả thất bại, không đổi trạng thái lần giữ ghế. Giao dịch không nhận ra: không có giao dịch thanh toán để ghi, control chỉ ghi log (Q-89). | BR-39, BR-86, REQ-133, Q-89 |
| 2e | Hệ thống | Ghi log lỗi giao dịch để xử lý thủ công ngoài hệ thống; không tạo vé, không hoàn tiền, không gửi email. | Control không tìm được lần giữ ghế theo mã giao dịch lẫn mã tham chiếu nên chỉ ghi log lỗi gồm mã giao dịch, kết quả, mã tham chiếu, số tiền báo và thời điểm nhận báo. Không thực thể nào bị ghi hoặc đổi. | BR-38, GL-11, REQ-129 |
| 4a | - | - | Hết 30 giây không có kết quả hoàn tiền, yêu cầu hoàn ghi nhận không phản hồi và kiểm còn lượt thử lại; còn thì quay lại bước 4 với cùng yêu cầu hoàn và cùng khoá chống hoàn trùng. | BR-41, BR-43, GL-20 |
| 4b | Hệ thống | Ghi log lỗi khoản hoàn toàn bộ để xử lý thủ công ngoài hệ thống; không gửi email cho khách. | Hết lượt thử lại thì control ghi log lỗi khoản hoàn gồm mã giao dịch và số tiền hoàn (đã ghi từ bước 3, 4). Không có email cho khách. | BR-41, REQ-131 |
| 5a | - | - | Cổng trả về hoàn tiền thất bại, control ngừng chờ, yêu cầu hoàn ghi kết quả thất bại và kiểm còn lượt thử lại; còn thì quay lại bước 4 với cùng khoá chống hoàn trùng. | BR-41, BR-43 |
| 5b | Hệ thống | Ghi log lỗi khoản hoàn toàn bộ để xử lý thủ công ngoài hệ thống; không gửi email cho khách. | Hết lượt thử lại thì control ghi log lỗi khoản hoàn gồm mã giao dịch và số tiền hoàn. Không có email cho khách. | BR-41, REQ-131 |

## 3. Tìm lớp phân tích

### 3.1 Bảng boundary

| Tác nhân (ACT) | Loại tác nhân | Boundary | Loại boundary | Mới hoặc tái dùng (AC, UC nguồn) | Lý do |
| --- | --- | --- | --- | --- | --- |
| ACT-07 Cổng thanh toán | Hệ thống ngoài | PaymentGateway | Giao diện hệ thống | Tái dùng AC-B-PaymentGateway (UC-005) | Một boundary cho cả hai vai trò của ACT-07: nhận kết quả giao dịch (tác nhân chính, bước 1) và nhận yêu cầu hoàn và trả kết quả hoàn như kết quả của lời gọi (tác nhân phụ, bước 4, 5). Tên theo hệ thống ngoài, không trùng tên entity (entity là PaymentTransaction). |
| ACT-08 Dịch vụ email | Hệ thống ngoài | EmailService | Giao diện hệ thống | Tái dùng AC-B-EmailService (UC-005) | Chỉ nhận email thông báo hoàn tiền từ hệ thống. Khách không thao tác ở use case này (nhận email qua dịch vụ), nên không có boundary người dùng hay kênh thông báo riêng. |

Số boundary là 2, bằng số tác nhân tham gia trực tiếp (không có tác nhân người, không có tác nhân thời gian). Tác nhân người không tham gia use case (P04 Mục 8).

### 3.2 Bảng lọc danh từ

| STT | Danh từ hoặc cụm danh từ | Vị trí (bước UC, mục dữ liệu, BR) | Kết luận | Lý do |
| --- | --- | --- | --- | --- |
| 1 | giao dịch, giao dịch thanh toán | 1 đến 7; Dữ liệu vào 1; BR-37 | Entity AC-E-PaymentTransaction | Hệ thống lưu số tiền, mã giao dịch, đã xử lý hay chưa; có hành vi kiểm chưa xử lý, ghi nhận thanh toán trễ, ghi báo trùng, kiểm hạn mức hoàn (GL-12). |
| 2 | mã giao dịch | 2, 4; Dữ liệu vào 1, Dữ liệu ra 2; BR-43 | Loại - thuộc tính của PaymentTransaction | Không có định danh và hành vi riêng (GL-29). |
| 3 | kết quả giao dịch | 1, 2; Dữ liệu vào 1 | Loại - dữ liệu trao đổi qua boundary PaymentGateway | Thành công hoặc thất bại, cổng báo về; phần cần lưu ghi vào thuộc tính result của PaymentTransaction (GL-17). |
| 4 | cổng thanh toán | 1, 4, 5 | Loại - là tác nhân hoặc ngoài phạm vi | ACT-07; boundary là PaymentGateway. |
| 5 | lần giữ ghế | 2, 3; BR-85, BR-86 | Entity AC-E-SeatHold | Có vòng đời riêng, trạng thái cuối và là đơn vị xử lý tuần tự (GL-25). |
| 6 | mã tham chiếu lần giữ ghế | 2; Dữ liệu vào 1 mục 3; BR-40 | Loại - thuộc tính của SeatHold | Thuộc tính holdRef của SeatHold (GL-31). |
| 7 | trạng thái Đang giữ, Hết hạn, Đã huỷ, Thanh toán thất bại, Đã hoàn tất | 2, 2b, 2c, 2d; BR-86 | Loại - thuộc tính của SeatHold | Giá trị trạng thái của lần giữ ghế (GL-25). |
| 8 | thời điểm hết hạn giữ ghế | 2; Mục 8; BR-14 | Loại - thuộc tính của SeatHold | Mốc so với thời điểm nhận báo (GL-52). |
| 9 | thời điểm nhận báo | 2; Mục 8 | Loại - thao tác hoặc sự kiện | Thời điểm sự kiện, truyền như tham số khi xử lý. |
| 10 | giao dịch thứ hai | 2; BR-40 | Loại - trùng hoặc đồng nghĩa với PaymentTransaction | Là một giao dịch thanh toán có mã khác mã đã lưu (GL-13); cùng entity. |
| 11 | giao dịch hệ thống không nhận ra | 2, 2e; BR-38 | Loại - giá trị suy ra từ PaymentTransaction và SeatHold | Kết quả tra mã giao dịch và mã tham chiếu không ra đối tượng nào; không lưu (GL-11). |
| 12 | thanh toán trễ, thanh toán đến trễ | 3; BR-14, BR-15 | Loại - thuộc tính của PaymentTransaction | Trạng thái xử lý (processed) và lý do hoàn (lateReason) của giao dịch (GL-51). |
| 13 | lần báo trùng, báo trùng | 2a; BR-37 | Loại - thuộc tính của PaymentTransaction | Số lần báo trùng ghi vào giao dịch (duplicateReportCount); không có định danh riêng. |
| 14 | yêu cầu hoàn, khoản hoàn | 4, 6; BR-43 | Entity AC-E-RefundRequest | Có định danh theo khoá chống hoàn trùng, vòng đời (số lần gửi, kết quả) và hành vi riêng (sinh khoá, kiểm lượt thử lại). P05 mục 3 xếp "yêu cầu hoàn" vào Số tiền hoàn và Tình trạng hoàn tiền; mô hình hoá thành entity dùng chung với UC-008 theo Q-87. |
| 15 | khoá chống hoàn trùng, loại yêu cầu hoàn toàn bộ | 4; BR-43 | Loại - thuộc tính của RefundRequest | idempotencyKey và requestType; khoá gắn với từng yêu cầu hoàn (GL-20). |
| 16 | số tiền đã thanh toán | 4; Dữ liệu vào 1 mục 4; BR-26 | Loại - thuộc tính của PaymentTransaction | amount của giao dịch (GL-44). |
| 17 | số tiền hoàn, toàn bộ số tiền | 4, 6, 7; Dữ liệu ra 2; BR-26 | Loại - thuộc tính của RefundRequest | refundAmount; tổng đã hoàn của giao dịch là refundedTotal của PaymentTransaction (GL-45). |
| 18 | kết quả hoàn tiền | 5, 5a, 6 | Loại - thuộc tính của RefundRequest | result của lần gửi gần nhất: thành công, thất bại, không phản hồi; kết quả đi theo lời gọi hoàn (Q-91). |
| 19 | lượt thử lại, lần thử lại | 4a, 4b, 5a, 5b; BR-41 | Loại - tham số của quy tắc BR-41 | Số lần là quyết định thiết kế P09; chỉ attemptCount của RefundRequest đếm số lần gửi (P05 mục 3). |
| 20 | 30 giây | 4a, 4b; BR-43 | Loại - tham số của quy tắc BR-43 | Thời hạn chờ kết quả hoàn tiền. |
| 21 | log lỗi, xử lý thủ công ngoài hệ thống | 2e, 4b, 5b; BR-38, BR-41 | Loại - cấu trúc cài đặt | Thuật ngữ kỹ thuật và hoạt động ngoài phạm vi, hệ thống chỉ ghi, không đọc lại (P05 mục 3); control ghi log bằng message tự gọi. |
| 22 | vé | 3; Hậu điều kiện; BR-37 | Loại - không tham gia hành vi của use case này (khái niệm của UC-005) | Use case này không tạo vé; chỉ đọc cờ "đã dùng để tạo vé" qua trạng thái đã xử lý của PaymentTransaction. |
| 23 | ghế, trạng thái ghế | Mục 8 | Loại - không tham gia hành vi của use case này (khái niệm của UC-005) | Use case này không đổi trạng thái ghế; UC-005 giải phóng ghế. |
| 24 | lần đặt, mã đặt vé | BR-37 | Loại - không tham gia hành vi của use case này (khái niệm của UC-005) | Chỉ được nhắc tới để xác định ranh giới; không đọc hay ghi. |
| 25 | khách, tài khoản khách | 7; Dữ liệu ra 1 | Entity AC-E-Customer | Entity biểu diễn thông tin về tác nhân, không phải tác nhân (tác nhân người không tham gia use case); cung cấp email của khách đã giữ ghế (GL-18). |
| 26 | nhân viên quầy | Mục 8 (UC-005 bước 9a) | Loại - không tham gia hành vi của use case này (khái niệm của UC-005) | Lần giữ ghế của nhân viên quầy thu tiền mặt, không có giao dịch qua cổng nên không tới use case này. |
| 27 | email của khách, email thông báo hoàn tiền | 7; Dữ liệu ra 1 | Loại - thuộc tính của Customer | Địa chỉ email là thuộc tính của Customer; nội dung email là dữ liệu trao đổi qua boundary EmailService, không lưu (GL-06). |
| 28 | tên phim, phim | Dữ liệu ra 2 mục 3 | Loại - khái niệm do UC-010 tạo, use case này chỉ đọc qua entity Showtime | Tên phim chỉ hiển thị trong email; đọc qua Showtime như UC-005 (movieName là thuộc tính mới ở UC này, P08 hợp nhất với Phim). |
| 29 | suất chiếu, ngày giờ bắt đầu | 7; Dữ liệu ra 2 mục 4 | Entity AC-E-Showtime | Hệ thống lưu; cung cấp tên phim và giờ bắt đầu cho email hoàn tiền (GL-47). |
| 30 | lý do hoàn | 7; Dữ liệu ra 2 mục 5 | Loại - thuộc tính của PaymentTransaction | lateReason, xác định ở bước 2 và ghi ở bước 3 (BR-14, BR-15, BR-40). |
| 31 | dịch vụ email | 7 | Loại - là tác nhân hoặc ngoài phạm vi | ACT-08; boundary là EmailService. |
| 32 | hệ thống, thông tin, thao tác | Nhiều bước | Loại - mơ hồ | Không phải khái niệm nghiệp vụ cụ thể. |

### 3.3 Bảng control

| Control | Use case điều phối | Mới hoặc tái dùng | Lý do (hoặc lý do không có control) |
|---|---|---|---|
| PaymentReportController | UC-006 | Tái dùng từ UC-005 (AC-C-PaymentReportController), bổ sung trách nhiệm | UC-006 chỉ được kích hoạt bởi báo kết quả giao dịch của cổng, cùng sự kiện với bước 11 của UC-005, nên không có control riêng: control tiếp nhận dùng chung (Q-83) điều phối bước 2 đến 7 ở nhánh thanh toán trễ, chờ kết quả hoàn tiền (BR-43) và ghi log lỗi. Tiếp nhận và xử lý báo là trách nhiệm do UC-005 làm chủ; UC-006 thêm 5 trách nhiệm (logUnrecognizedTransaction, startWaitingForRefundResult, stopWaitingForRefundResult, handleRefundNoResponse, logRefundFailure). Control có 6 trách nhiệm, trong khoảng 2-10; mọi quy tắc nghiệp vụ nằm ở entity. |

### 3.4 Bảng lớp phân tích

| AC | Stereotype | Tên | Trách nhiệm | Thuộc tính chính | Bước UC nguồn | Loại boundary | Mới hoặc tái dùng | GL |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| AC-B-PaymentGateway | boundary | PaymentGateway | // reportTransactionResult: nhận kết quả giao dịch do cổng thanh toán báo về (cùng ý nghĩa với UC-005)<br>// requestRefund: chuyển yêu cầu hoàn toàn bộ, kèm khoá chống hoàn trùng, tới cổng thanh toán và nhận kết quả hoàn tiền trả về trong 30 giây | - | 1, 2, 4, 5, 2a, 2b, 2c, 2d, 4a, 5a | Giao diện hệ thống | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-02, GL-17 |
| AC-B-EmailService | boundary | EmailService | // sendRefundNotificationEmail: chuyển email thông báo hoàn tiền tới dịch vụ email | - | 7 | Giao diện hệ thống | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-06 |
| AC-C-PaymentReportController | control | PaymentReportController | // handlePaymentReport: tiếp nhận báo kết quả giao dịch (trách nhiệm của UC-005, cùng ý nghĩa); ở UC-006 điều phối tiếp khi kết quả là thanh toán trễ chờ hoàn: yêu cầu hoàn toàn bộ, chờ kết quả, gửi email (bước 2 đến 7)<br>// logUnrecognizedTransaction: ghi log lỗi giao dịch không nhận ra để xử lý thủ công ngoài hệ thống (BR-38)<br>// startWaitingForRefundResult: bắt đầu chờ kết quả hoàn tiền tối đa 30 giây (BR-43)<br>// stopWaitingForRefundResult: ngừng chờ khi cổng đã trả kết quả hoàn tiền<br>// handleRefundNoResponse: nhận sự kiện hết 30 giây không có kết quả hoàn tiền: ghi nhận, kiểm lượt thử lại (after BR-43)<br>// logRefundFailure: ghi log lỗi khoản hoàn khi hết lượt thử lại, không gửi email (BR-41) | - | 1 đến 7, 2a đến 2e, 4a, 4b, 5a, 5b | - | Tái dùng từ UC-005, bổ sung trách nhiệm | - |
| AC-E-SeatHold | entity | SeatHold | // settlePaymentReport: trách nhiệm xử lý báo của UC-005, ở UC-006 trả về thanh toán trễ chờ hoàn, báo trùng hoặc thất bại ghi nhận (BR-37, BR-85, BR-86)<br>// checkHoldStillActive: xác định lần giữ ghế còn hiệu lực tại thời điểm nhận báo, dùng chung với UC-005 và UC-014; Đang giữ mà quá hạn đã được chuyển sang Hết hạn (BR-14, BR-15, BR-40)<br>// recordPaymentTransaction: tạo giao dịch thanh toán cho giao dịch thứ hai từ mã giao dịch và số tiền trong báo (trách nhiệm của UC-005, BR-40, Q-90)<br>// provideRefundNoticeRecipient: cung cấp email của khách giữ ghế, tên phim và giờ bắt đầu suất chiếu cho email hoàn tiền | - | 2, 3, 7, 2a đến 2d | - | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-25, GL-31, GL-51 |
| AC-E-PaymentTransaction | entity | PaymentTransaction | // checkNotProcessed: kiểm giao dịch chưa dùng để tạo vé và chưa ghi nhận thanh toán trễ (BR-37)<br>// createPaymentTransaction: tạo giao dịch cho giao dịch thứ hai, do SeatHold ghi nhận (trách nhiệm của UC-005, BR-40)<br>// markLatePayment: ghi nhận giao dịch là thanh toán trễ chờ hoàn tiền, kèm lý do hoàn, đã xử lý (BR-14, BR-15, BR-40)<br>// recordDuplicateReport: ghi nhận lần báo trùng, không hoàn thêm (BR-37)<br>// recordFailedResult: ghi nhận kết quả thất bại của giao dịch, không hoàn tiền (BR-39)<br>// prepareRefundRequest: kiểm khoản hoàn không vượt số tiền đã thanh toán rồi tạo yêu cầu hoàn gắn giao dịch (BR-26, BR-43)<br>// checkRefundWithinPaidAmount: kiểm tổng đã hoàn cộng khoản hoàn không vượt số tiền đã thanh toán (BR-26)<br>// recordRefundedAmount: cộng số tiền hoàn vào tổng đã hoàn của giao dịch, kiểm lại tổng không vượt số tiền đã thanh toán ngay lúc cộng, là một thao tác không chia cắt theo giao dịch để hai khoản hoàn cùng lúc đều được cộng đủ (BR-26)<br>// provideRefundSummary: cung cấp mã giao dịch, số tiền hoàn và lý do hoàn cho email | lateReason (Văn bản) (mới ở UC này), refundedTotal (Số tiền) (mới ở UC này), duplicateReportCount (Số lượng) (mới ở UC này) | 2, 3, 4, 6, 7, 2a, 2c, 2d | - | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-12, GL-29, GL-44, GL-51 |
| AC-E-RefundRequest | entity | RefundRequest | // createRefundRequest: tạo yêu cầu hoàn gắn giao dịch, loại yêu cầu và số tiền hoàn (BR-43)<br>// generateIdempotencyKey: sinh khoá chống hoàn trùng từ mã giao dịch và loại yêu cầu, không đổi qua các lần thử lại (BR-43)<br>// recordAttempt: ghi nhận một lần gửi yêu cầu hoàn tới cổng<br>// recordResult: ghi nhận kết quả của lần gửi: thành công, thất bại, không phản hồi<br>// checkRetryRemaining: kiểm còn lượt thử lại (BR-41) | idempotencyKey (Văn bản), requestType (Văn bản), refundAmount (Số tiền), attemptCount (Số lượng), result (Văn bản) | 4, 6, 4a, 4b, 5a, 5b | - | Mới; UC-008 dùng lại, bổ sung liên kết tới vé | GL-20, GL-45, GL-56 |
| AC-E-Customer | entity | Customer | // provideEmail: cung cấp email của tài khoản khách đã giữ ghế | - | 7 | - | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-18 |
| AC-E-Showtime | entity | Showtime | // provideMovieAndStartTime: cung cấp tên phim và giờ bắt đầu của suất chiếu | movieName (Văn bản) (mới ở UC này) | 7 | - | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-47 |

Tổng cộng 8 lớp: 2 boundary, 1 control, 5 entity. Thuộc tính đã có ở UC-005 của lớp tái dùng (SeatHold: holdRef, status, holdTime, expiryTime; PaymentTransaction: transactionCode, amount, processed, result; Customer: email, phoneNumber, password; Showtime: startTime và các thuộc tính khác) dùng lại nguyên, bảng trên chỉ ghi thuộc tính mới ở UC này. Entity cốt lõi của chủ đề xử lý tuần tự theo lần giữ ghế và chống hoàn trùng: AC-E-SeatHold, AC-E-PaymentTransaction, AC-E-RefundRequest.

## 4. Phân bổ hành vi

| Bước UC | Trách nhiệm | Lớp nhận (AC) | Nguyên tắc | Lý do khi có lựa chọn khác |
| --- | --- | --- | --- | --- |
| 1 | // reportTransactionResult | AC-B-PaymentGateway | Giao tiếp tác nhân | - |
| 1 | // handlePaymentReport | AC-C-PaymentReportController | Controller | Một control tiếp nhận mọi báo của cổng (Q-83), UC-005 là chủ; control của UC-006 không tồn tại riêng nên không có control gọi control (F6). |
| 2, 3 | // settlePaymentReport | AC-E-SeatHold | Information Expert | Dữ liệu nằm ở nhiều lớp (trạng thái lần giữ ghế, giao dịch). Đơn vị xử lý tuần tự và khoá là lần giữ ghế (BR-85), trạng thái cuối chỉ lần giữ ghế biết (BR-86), nên giao cho SeatHold. Một trách nhiệm duy nhất cho mọi kết quả, UC-005 là chủ. Giao cho control làm control ôm quy tắc thuộc dữ liệu của entity; giao cho PaymentTransaction thì giao dịch phải biết trạng thái lần giữ ghế, tăng coupling. |
| 2 | // checkNotProcessed | AC-E-PaymentTransaction | Information Expert | Giao dịch biết mình đã dùng để tạo vé hay đã ghi nhận trễ chưa (BR-37). |
| 2 | // checkHoldStillActive | AC-E-SeatHold | Information Expert | Trạng thái và thời điểm hết hạn thuộc SeatHold; một trách nhiệm "còn hiệu lực" dùng chung với UC-005 và UC-014. Đang giữ mà quá hạn đã được chuyển sang Hết hạn trước (UC-005, SD10) nên UC-006 chỉ thấy trạng thái cuối (Q-88). |
| 3 | // markLatePayment | AC-E-PaymentTransaction | Information Expert | Đánh dấu thanh toán trễ và đã xử lý trên dữ liệu của giao dịch; trong cùng thao tác với bước 2. |
| 3 | // recordPaymentTransaction, createPaymentTransaction | AC-E-SeatHold, AC-E-PaymentTransaction | Creator | Giao dịch thứ hai chưa có bản ghi; SeatHold ghi nhận và có dữ liệu khởi tạo (mã tham chiếu, báo của cổng), đúng như UC-005 bước 10; dùng lại trách nhiệm đó thay cho một trách nhiệm tạo riêng ở PaymentTransaction (Q-90). |
| 4 | // prepareRefundRequest | AC-E-PaymentTransaction | Information Expert | Giao dịch nắm số tiền đã thanh toán và các khoản đã hoàn nên kiểm hạn mức rồi tạo yêu cầu hoàn; cùng một trách nhiệm với UC-008 (Q-87). |
| 4 | // checkRefundWithinPaidAmount | AC-E-PaymentTransaction | Information Expert | BR-26 tính trên dữ liệu của giao dịch (amount, refundedTotal). |
| 4 | // createRefundRequest | AC-E-RefundRequest | Creator | Giao dịch ghi nhận các yêu cầu hoàn của nó (một giao dịch có nhiều yêu cầu hoàn khác khoá, BR-43). |
| 4 | // generateIdempotencyKey | AC-E-RefundRequest | Information Expert | Khoá gắn với từng yêu cầu hoàn và không đổi qua các lần thử lại (BR-43). Đặt khoá ở PaymentTransaction thì hai yêu cầu hoàn khác nhau của một giao dịch dùng chung khoá, sai BR-43. |
| 4 | // startWaitingForRefundResult | AC-C-PaymentReportController | Giao cho control | Thời hạn nội bộ 30 giây (BR-43) không là tác nhân; A2. Cùng tên với UC-008. |
| 4 | // recordAttempt | AC-E-RefundRequest | Information Expert | Đếm số lần gửi của chính yêu cầu hoàn. |
| 4 | // requestRefund | AC-B-PaymentGateway | Giao tiếp tác nhân | Kết quả hoàn tiền đi theo lời gọi, không có callback riêng (Q-91). |
| 5 | // requestRefund (kết quả trả về) | AC-B-PaymentGateway | Giao tiếp tác nhân | Q-91. |
| 6 | // stopWaitingForRefundResult | AC-C-PaymentReportController | Giao cho control | - |
| 6 | // recordRefundedAmount | AC-E-PaymentTransaction | Information Expert | Tổng đã hoàn là dữ liệu của giao dịch (BR-26); cộng và kiểm lại hạn mức là một thao tác không chia cắt theo giao dịch vì kiểm ở bước 4 (// checkRefundWithinPaidAmount) và cộng ở bước 6 tách nhau; cùng tên với UC-008. |
| 6 | // recordResult | AC-E-RefundRequest | Information Expert | Kết quả lần gửi thuộc yêu cầu hoàn. |
| 7 | // provideRefundSummary | AC-E-PaymentTransaction | Information Expert | Mã giao dịch, số tiền hoàn, lý do hoàn do giao dịch giữ. |
| 7 | // provideRefundNoticeRecipient | AC-E-SeatHold | Information Expert | Lần giữ ghế có quan hệ cấu trúc tới khách và suất chiếu; control gọi một lần thay vì tự đi tới Customer và Showtime (low coupling). |
| 7 | // provideEmail | AC-E-Customer | Information Expert | - |
| 7 | // provideMovieAndStartTime | AC-E-Showtime | Information Expert | Đọc được cả suất chiếu Đã xoá (BR-58). |
| 7 | // sendRefundNotificationEmail | AC-B-EmailService | Giao tiếp tác nhân | - |
| 2a | // recordDuplicateReport | AC-E-PaymentTransaction | Information Expert | Số lần báo trùng ghi trên giao dịch. |
| 2b | // settlePaymentReport (trả về bán ghế) | AC-E-SeatHold | Information Expert | Kết quả bán ghế do UC-005 xử lý tiếp; UC-006 không ghi gì. |
| 2c, 2d | // recordFailedResult | AC-E-PaymentTransaction | Information Expert | Ghi kết quả thất bại báo muộn trên giao dịch nhận ra; cùng tên với UC-005 (11a). |
| 2d, 2e | // logUnrecognizedTransaction | AC-C-PaymentReportController | Giao cho control | Không có đối tượng nào để ghi (không tìm được lần giữ ghế hoặc giao dịch); log là hoạt động kỹ thuật, không là entity (P05 mục 3). |
| 4a, 4b, 5a, 5b | // handleRefundNoResponse | AC-C-PaymentReportController | Giao cho control | Nhận sự kiện hết thời hạn nội bộ (A2). |
| 4a, 4b, 5a, 5b | // recordResult, checkRetryRemaining | AC-E-RefundRequest | Information Expert | Lượt thử lại tính trên yêu cầu hoàn; số lần tối đa là quyết định thiết kế P09. |
| 4b, 5b | // logRefundFailure | AC-C-PaymentReportController | Giao cho control | Khoản hoàn chưa hoàn được đã ghi mã giao dịch và số tiền ở bước 3, 4; log ghi bằng message tự gọi. |

### 4.1 Thao tác không chia cắt theo P04 Mục 8

| Thao tác (P04) | Bước | Lớp điều phối | Lớp tham gia | Message vào đầu tiên | Điểm tuần tự |
|---|---|---|---|---|---|
| Ghi nhận thanh toán trễ chờ hoàn tiền | 2, 3 | AC-E-SeatHold, // settlePaymentReport (UC-005 là chủ) | AC-E-PaymentTransaction (// checkNotProcessed, // markLatePayment, // recordPaymentTransaction), AC-C-PaymentReportController | 1.1 từ AC-B-PaymentGateway tới AC-C-PaymentReportController (// handlePaymentReport), là lớp nhận đầu tiên của báo kết quả giao dịch | Theo lần giữ ghế (BR-85, BR-86), cùng điểm tuần tự với UC-005 bước 11, 12, 11a, 9a2 và luồng 7b, *a; báo trùng, thất bại muộn (2a, 2c, 2d) đi qua cùng trách nhiệm. Báo đến trước được xử lý, báo đến sau thấy trạng thái cuối |
| Hoàn toàn bộ qua cổng và ghi nhận khoản đã hoàn | 4, 5, 6 | AC-E-PaymentTransaction, // prepareRefundRequest (bước 4) và // recordRefundedAmount (bước 6) | AC-E-RefundRequest (khoá chống hoàn trùng, lượt thử), AC-C-PaymentReportController, AC-B-PaymentGateway | 1.1.2 từ AC-C-PaymentReportController | Theo giao dịch thanh toán: tổng đã hoàn (refundedTotal) được kiểm ở bước 4 và cộng ở bước 6, nên // recordRefundedAmount cộng và kiểm lại không vượt số tiền đã thanh toán (BR-26); đối thủ UC-008 bước 5, 7 trên cùng giao dịch. Mọi lần thử lại dùng lại cùng RefundRequest và khoá (BR-43) |

Phạm vi bất biến và điểm tuần tự khớp nhau: bất biến "mỗi giao dịch chỉ xử lý một lần" trải qua mọi báo của giao dịch nên điểm tuần tự là lần giữ ghế ứng với giao dịch (BR-85) cộng cờ đã xử lý của giao dịch (BR-37); bất biến hạn mức hoàn có điểm tuần tự là giao dịch.

## 5. Sequence diagram phân tích

File diagrams/P07-sequence-UC-006.drawio gồm 6 trang, mỗi trang một sơ đồ dưới đây. Lifeline ACT-07 (:Cổng thanh toán) đặt ở bên trái vì là tác nhân chính; ACT-08 ở bên phải. Việc cổng thanh toán nhận yêu cầu hoàn và trả kết quả hoàn (message 1.1.5.1) vẽ về lại lifeline này vì cùng một tác nhân ở hai vai trò. Các message tiếp nhận và xử lý báo (1 đến 1.1.1 trả về) thuộc trách nhiệm do UC-005 làm chủ; trang này chỉ vẽ phần dẫn tới nhánh của UC-006.

### SD1 - Luồng chính, bước 1 đến 7

a) Luồng thể hiện: Luồng chính: cổng báo thành công, lần giữ ghế ở trạng thái cuối hoặc đã quá hạn, hoàn toàn bộ, gửi email (BR-14, BR-15, BR-37, BR-85, BR-86, BR-43).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| SD1-L-A7 | Actor | :Cổng thanh toán | - | - | Tác nhân (ACT-07), vừa tác nhân chính vừa tác nhân phụ |
| SD1-L-PG | Lifeline | :PaymentGateway | «boundary» | - | AC-B-PaymentGateway |
| SD1-L-PC | Lifeline | :PaymentReportController | «control» | - | AC-C-PaymentReportController |
| SD1-L-SH | Lifeline | :SeatHold | «entity» | - | AC-E-SeatHold |
| SD1-L-PT | Lifeline | :PaymentTransaction | «entity» | - | AC-E-PaymentTransaction |
| SD1-L-RR | Lifeline | :RefundRequest | «entity» | - | AC-E-RefundRequest (đỉnh lifeline đặt ngang message Tạo) |
| SD1-L-CU | Lifeline | :Customer | «entity» | - | AC-E-Customer |
| SD1-L-ST | Lifeline | :Showtime | «entity» | - | AC-E-Showtime |
| SD1-L-ES | Lifeline | :EmailService | «boundary» | - | AC-B-EmailService |
| SD1-L-A8 | Actor | :Dịch vụ email | - | - | Tác nhân (ACT-08) |
| SD1-N1 | Note | Các message 1 đến 1.1.1 (trả về) là tiếp nhận và xử lý báo của control dùng chung, UC-005 là chủ (SD1b, SD10 của UC-005); trang này vẽ nhánh thanh toán trễ. Lần giữ ghế Đang giữ mà quá hạn đã được chuyển sang Hết hạn trước message 1.1.1.2 (SD10 của UC-005). | - | - | Chú thích |
| SD1-N2 | Note | Thao tác không chia cắt theo lần giữ ghế (BR-85, BR-86): các message 1.1.1.1 đến 1.1.1.3 xảy ra liền nhau, báo khác của cùng lần giữ ghế chờ đến lượt. | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | :Cổng thanh toán | :PaymentGateway | // reportTransactionResult (kết quả thành công, mã giao dịch, mã tham chiếu lần giữ ghế, số tiền đã thanh toán) | Đồng bộ | - | 1 |
| 1.1 | :PaymentGateway | :PaymentReportController | // handlePaymentReport (kết quả, mã giao dịch, mã tham chiếu lần giữ ghế, số tiền đã thanh toán, thời điểm nhận báo) | Đồng bộ | - | 1 |
| 1.1.1 | :PaymentReportController | :SeatHold | // settlePaymentReport (lần giữ ghế tìm theo mã giao dịch hoặc mã tham chiếu lần giữ ghế, kết quả, số tiền đã thanh toán, thời điểm nhận báo) | Đồng bộ | - | 2, 3 |
| 1.1.1.1 | :SeatHold | :PaymentTransaction | // checkNotProcessed (mã giao dịch) | Đồng bộ | - | 2 |
| 1.1.1.2 | :SeatHold | :SeatHold | // checkHoldStillActive (thời điểm nhận báo) | Tự gọi | - | 2 |
| 1.1.1.3 | :SeatHold | :PaymentTransaction | // markLatePayment (lý do hoàn) | Đồng bộ | - | 3 |
| 1.1.1 (trả về) | :SeatHold | :PaymentReportController | kết quả: thanh toán trễ chờ hoàn toàn bộ, lý do hoàn | Trả về | - | 3 |
| 1.1.2 | :PaymentReportController | :PaymentTransaction | // prepareRefundRequest (mã giao dịch, loại hoàn toàn bộ, số tiền hoàn) | Đồng bộ | - | 4 |
| 1.1.2.1 | :PaymentTransaction | :PaymentTransaction | // checkRefundWithinPaidAmount (toàn bộ số tiền đã thanh toán) | Tự gọi | - | 4 |
| 1.1.2.2 | :PaymentTransaction | :RefundRequest | «create» // createRefundRequest (mã giao dịch, loại hoàn toàn bộ, số tiền hoàn) | Tạo | - | 4 |
| 1.1.2.2.1 | :RefundRequest | :RefundRequest | // generateIdempotencyKey (mã giao dịch, loại hoàn toàn bộ) | Tự gọi | - | 4 |
| 1.1.2 (trả về) | :PaymentTransaction | :PaymentReportController | yêu cầu hoàn: khoá chống hoàn trùng, số tiền hoàn | Trả về | - | 4 |
| 1.1.3 | :PaymentReportController | :PaymentReportController | // startWaitingForRefundResult (BR-43) | Tự gọi | - | 4 |
| 1.1.4 | :PaymentReportController | :RefundRequest | // recordAttempt | Đồng bộ | - | 4 |
| 1.1.5 | :PaymentReportController | :PaymentGateway | // requestRefund (mã giao dịch, số tiền hoàn, khoá chống hoàn trùng) | Đồng bộ | - | 4 |
| 1.1.5.1 | :PaymentGateway | :Cổng thanh toán | // requestRefund (mã giao dịch, số tiền hoàn, khoá chống hoàn trùng) | Đồng bộ | - | 4 |
| 1.1.5.1 (trả về) | :Cổng thanh toán | :PaymentGateway | kết quả hoàn tiền: thành công | Trả về | - | 5 |
| 1.1.5 (trả về) | :PaymentGateway | :PaymentReportController | kết quả hoàn tiền: thành công | Trả về | - | 5 |
| 1.1.6 | :PaymentReportController | :PaymentReportController | // stopWaitingForRefundResult | Tự gọi | - | 5 |
| 1.1.7 | :PaymentReportController | :PaymentTransaction | // recordRefundedAmount (số tiền hoàn) | Đồng bộ | - | 6 |
| 1.1.8 | :PaymentReportController | :RefundRequest | // recordResult (thành công) | Đồng bộ | - | 6 |
| 1.1.9 | :PaymentReportController | :PaymentTransaction | // provideRefundSummary | Đồng bộ | - | 7 |
| 1.1.9 (trả về) | :PaymentTransaction | :PaymentReportController | mã giao dịch, số tiền hoàn, lý do hoàn | Trả về | - | 7 |
| 1.1.10 | :PaymentReportController | :SeatHold | // provideRefundNoticeRecipient | Đồng bộ | - | 7 |
| 1.1.10.1 | :SeatHold | :Customer | // provideEmail | Đồng bộ | - | 7 |
| 1.1.10.2 | :SeatHold | :Showtime | // provideMovieAndStartTime | Đồng bộ | - | 7 |
| 1.1.10 (trả về) | :SeatHold | :PaymentReportController | email khách, tên phim, suất chiếu | Trả về | - | 7 |
| 1.1.11 | :PaymentReportController | :EmailService | // sendRefundNotificationEmail (email khách, mã giao dịch, số tiền hoàn, tên phim, suất chiếu, lý do hoàn) | Đồng bộ | - | 7 |
| 1.1.11.1 | :EmailService | :Dịch vụ email | // sendRefundNotificationEmail (email khách, mã giao dịch, số tiền hoàn, tên phim, suất chiếu, lý do hoàn) | Đồng bộ | - | 7 |

### SD2 - Luồng 2e, 2a và 2b

a) Luồng thể hiện: Giao dịch thành công không nhận ra (2e); báo trùng giao dịch đã xử lý (2a); lần giữ ghế còn hiệu lực, kết quả bán ghế thuộc UC-005 (2b).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| SD2-L-PG | Lifeline | :PaymentGateway | «boundary» | - | AC-B-PaymentGateway |
| SD2-L-PC | Lifeline | :PaymentReportController | «control» | - | AC-C-PaymentReportController |
| SD2-L-SH | Lifeline | :SeatHold | «entity» | - | AC-E-SeatHold |
| SD2-L-PT | Lifeline | :PaymentTransaction | «entity» | - | AC-E-PaymentTransaction |
| SD2-F1 | Fragment | break [kết quả thành công và hệ thống không nhận ra giao dịch (2e, BR-38)] | - | - | Bao các message của fragment |
| SD2-F2 | Fragment | break [kết quả thành công và giao dịch đã được xử lý trước đó (2a, BR-37)] | - | - | Bao các message của fragment |
| SD2-F3 | Fragment | break [kết quả thành công, giao dịch chưa xử lý và lần giữ ghế còn Đang giữ, chưa quá thời điểm hết hạn (2b)] | - | - | Bao các message của fragment |
| SD2-N1 | Note | Điểm rẽ trong SD1: 2e tại message 1.1 (không tìm được lần giữ ghế); 2a tại message 1.1.1.1 (giao dịch đã xử lý); 2b tại message 1.1.1.2 (lần giữ ghế còn hiệu lực). | - | - | Chú thích |
| SD2-N2 | Note | Kết thúc use case, không ghi gì. Báo này được UC-005 xử lý (bước 12 đến 15, SD1b và SD1c của UC-005, EV-07). | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
| --- | --- | --- | --- | --- | --- | --- |
| 1.1e | :PaymentReportController | :PaymentReportController | // logUnrecognizedTransaction (mã giao dịch, kết quả, mã tham chiếu lần giữ ghế, số tiền đã thanh toán, thời điểm nhận báo) | Tự gọi | SD2-F1 | 2e |
| 1.1.1.1a | :SeatHold | :PaymentTransaction | // recordDuplicateReport (thời điểm nhận báo) | Đồng bộ | SD2-F2 | 2a |
| 1.1.1 (trả về) | :SeatHold | :PaymentReportController | kết quả: bán ghế, lần giữ ghế còn hiệu lực (UC-005) | Trả về | SD2-F3 | 2b |

### SD3 - Luồng 2c và 2d

a) Luồng thể hiện: Kết quả thất bại báo muộn hoặc báo cho giao dịch đã có vé hoặc không nhận ra: chỉ ghi nhận, không hoàn tiền (BR-39).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| SD3-L-PC | Lifeline | :PaymentReportController | «control» | - | AC-C-PaymentReportController |
| SD3-L-SH | Lifeline | :SeatHold | «entity» | - | AC-E-SeatHold |
| SD3-L-PT | Lifeline | :PaymentTransaction | «entity» | - | AC-E-PaymentTransaction |
| SD3-F1 | Fragment | break [kết quả thất bại và lần giữ ghế đã hết hạn hoặc đã bị khách huỷ (2c, BR-39)] | - | - | Bao các message của fragment |
| SD3-F2 | Fragment | break [kết quả thất bại, giao dịch nhận ra, không thuộc 2c: đã có vé hoặc lần giữ ghế đã có báo thất bại (2d, BR-39)] | - | - | Bao các message của fragment |
| SD3-F3 | Fragment | break [kết quả thất bại và hệ thống không nhận ra giao dịch (2d, BR-39)] | - | - | Bao các message của fragment |
| SD3-N1 | Note | Điểm rẽ trong SD1: kết quả thất bại, tại message 1.1 (2d không nhận ra) và message 1.1.1 (2c, 2d nhận ra). Lần giữ ghế còn Đang giữ, chưa quá hạn thuộc luồng 11a của UC-005 (SD9). | - | - | Chú thích |
| SD3-N2 | Note | Không có giao dịch thanh toán để ghi nhận kết quả, nên chỉ ghi log (Q-89). | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
| --- | --- | --- | --- | --- | --- | --- |
| 1.1.1c | :PaymentReportController | :SeatHold | // settlePaymentReport (lần giữ ghế tìm theo mã giao dịch hoặc mã tham chiếu lần giữ ghế, kết quả, số tiền đã thanh toán, thời điểm nhận báo) | Đồng bộ | SD3-F1 | 2c |
| 1.1.1c.1 | :SeatHold | :SeatHold | // checkHoldStillActive (thời điểm nhận báo) | Tự gọi | SD3-F1 | 2c |
| 1.1.1c.2 | :SeatHold | :PaymentTransaction | // recordFailedResult (thất bại, thời điểm nhận báo) | Đồng bộ | SD3-F1 | 2c |
| 1.1.1d | :PaymentReportController | :SeatHold | // settlePaymentReport (lần giữ ghế tìm theo mã giao dịch hoặc mã tham chiếu lần giữ ghế, kết quả, số tiền đã thanh toán, thời điểm nhận báo) | Đồng bộ | SD3-F2 | 2d |
| 1.1.1d.1 | :SeatHold | :SeatHold | // checkHoldStillActive (thời điểm nhận báo) | Tự gọi | SD3-F2 | 2d |
| 1.1.1d.2 | :SeatHold | :PaymentTransaction | // recordFailedResult (thất bại, thời điểm nhận báo) | Đồng bộ | SD3-F2 | 2d |
| 1.1d | :PaymentReportController | :PaymentReportController | // logUnrecognizedTransaction (mã giao dịch, kết quả, mã tham chiếu lần giữ ghế, số tiền đã thanh toán, thời điểm nhận báo) | Tự gọi | SD3-F3 | 2d |

### SD4 - Luồng 4a và 4b

a) Luồng thể hiện: Cổng không phản hồi yêu cầu hoàn tiền trong 30 giây: thử lại với cùng khoá chống hoàn trùng (4a) hoặc ghi log lỗi khi hết lượt (4b) (BR-41, BR-43).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| SD4-L-PC | Lifeline | :PaymentReportController | «control» | - | AC-C-PaymentReportController |
| SD4-L-RR | Lifeline | :RefundRequest | «entity» | - | AC-E-RefundRequest (đỉnh lifeline đặt ngang message Tạo) |
| SD4-F1 | Fragment | break [không phản hồi trong 30 giây và đã hết lượt thử lại (4b, BR-41)] | - | - | Bao các message của fragment |
| SD4-F2 | Fragment | opt [không phản hồi trong 30 giây và còn lượt thử lại (4a, BR-41)] | - | - | Bao các message của fragment |
| SD4-N1 | Note | Điểm rẽ trong SD1: sau message 1.1.5, khi hết 30 giây chờ bắt đầu từ message 1.1.3 mà cổng chưa trả kết quả. | - | - | Chú thích |
| SD4-N2 | Note | Quay lại bước 4: lặp message 1.1.3 đến 1.1.5.1 của SD1 với cùng yêu cầu hoàn và cùng khoá chống hoàn trùng (BR-43). | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
| --- | --- | --- | --- | --- | --- | --- |
| 1.1.3a | :PaymentReportController | :PaymentReportController | // after(BR-43) handleRefundNoResponse | Tự gọi | - | 4a, 4b |
| 1.1.3a.1 | :PaymentReportController | :RefundRequest | // recordResult (không phản hồi) | Đồng bộ | - | 4a, 4b |
| 1.1.3a.2 | :PaymentReportController | :RefundRequest | // checkRetryRemaining | Đồng bộ | - | 4a, 4b |
| 1.1.3b | :PaymentReportController | :PaymentReportController | // logRefundFailure (mã giao dịch, số tiền hoàn) | Tự gọi | SD4-F1 | 4b |

### SD5 - Luồng 5a và 5b

a) Luồng thể hiện: Cổng trả về kết quả hoàn tiền thất bại: thử lại với cùng khoá chống hoàn trùng (5a) hoặc ghi log lỗi khi hết lượt (5b) (BR-41, BR-43).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| SD5-L-PC | Lifeline | :PaymentReportController | «control» | - | AC-C-PaymentReportController |
| SD5-L-RR | Lifeline | :RefundRequest | «entity» | - | AC-E-RefundRequest (đỉnh lifeline đặt ngang message Tạo) |
| SD5-F1 | Fragment | break [hoàn tiền thất bại và đã hết lượt thử lại (5b, BR-41)] | - | - | Bao các message của fragment |
| SD5-F2 | Fragment | opt [hoàn tiền thất bại và còn lượt thử lại (5a, BR-41)] | - | - | Bao các message của fragment |
| SD5-N1 | Note | Điểm rẽ trong SD1: tại message 1.1.5 (trả về), khi kết quả hoàn tiền trả về là thất bại. | - | - | Chú thích |
| SD5-N2 | Note | Quay lại bước 4: lặp message 1.1.3 đến 1.1.5.1 của SD1 với cùng yêu cầu hoàn và cùng khoá chống hoàn trùng (BR-43). | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
| --- | --- | --- | --- | --- | --- | --- |
| 1.1.5a.1 | :PaymentReportController | :PaymentReportController | // stopWaitingForRefundResult | Tự gọi | - | 5a, 5b |
| 1.1.5a.2 | :PaymentReportController | :RefundRequest | // recordResult (thất bại) | Đồng bộ | - | 5a, 5b |
| 1.1.5a.3 | :PaymentReportController | :RefundRequest | // checkRetryRemaining | Đồng bộ | - | 5a, 5b |
| 1.1.5b.1 | :PaymentReportController | :PaymentReportController | // logRefundFailure (mã giao dịch, số tiền hoàn) | Tự gọi | SD5-F1 | 5b |

### SD6 - Biến thể giao dịch thứ hai (BR-40)

a) Luồng thể hiện: Luồng chính khi mã giao dịch khác mã đã lưu và gắn được với lần giữ ghế đã có vé qua mã tham chiếu lần giữ ghế (BR-40, REQ-136).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| SD6-L-PG | Lifeline | :PaymentGateway | «boundary» | - | AC-B-PaymentGateway |
| SD6-L-PC | Lifeline | :PaymentReportController | «control» | - | AC-C-PaymentReportController |
| SD6-L-SH | Lifeline | :SeatHold | «entity» | - | AC-E-SeatHold |
| SD6-L-PT | Lifeline | :PaymentTransaction | «entity» | - | AC-E-PaymentTransaction (đỉnh lifeline đặt ngang message Tạo) |
| SD6-N1 | Note | Điểm rẽ trong SD1: message 1.1.1. Chưa có giao dịch thanh toán mang mã này nên không có kiểm tra 1.1.1.1; giao dịch được tạo bằng recordPaymentTransaction của UC-005. Bước 4 đến 7 như SD1 từ message 1.1.2, số tiền hoàn lấy từ báo của cổng. | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
| --- | --- | --- | --- | --- | --- | --- |
| 1.1.1[BR-40] | :PaymentReportController | :SeatHold | // settlePaymentReport (lần giữ ghế tìm theo mã giao dịch hoặc mã tham chiếu lần giữ ghế, kết quả, số tiền đã thanh toán, thời điểm nhận báo) | Đồng bộ | - | 2, 3 |
| 1.1.1.2[BR-40] | :SeatHold | :SeatHold | // checkHoldStillActive (thời điểm nhận báo) | Tự gọi | - | 2 |
| 1.1.1.3[BR-40] | :SeatHold | :SeatHold | // recordPaymentTransaction (mã giao dịch, số tiền đã thanh toán trong báo) | Tự gọi | - | 3 |
| 1.1.1.3.1[BR-40] | :SeatHold | :PaymentTransaction | «create» // createPaymentTransaction (mã giao dịch, số tiền đã thanh toán trong báo) | Tạo | - | 3 |
| 1.1.1.4[BR-40] | :SeatHold | :PaymentTransaction | // markLatePayment (lý do hoàn) | Đồng bộ | - | 3 |
| 1.1.1[BR-40] (trả về) | :SeatHold | :PaymentReportController | kết quả: thanh toán trễ chờ hoàn toàn bộ, lý do hoàn | Trả về | - | 3 |

## 6. Quy tắc tương tác giữa các lớp phân tích

| Vi phạm | Message hoặc link | Cách sửa đã áp dụng |
| --- | --- | --- |
| Không có | - | - |

Các điểm đã kiểm: actor chỉ gửi message tới boundary của nó (message 1, 1.1.5.1 trả về); boundary chỉ gửi tới control hoặc actor của nó (1.1, 1.1.5.1, 1.1.11.1); control gọi boundary, entity và chính nó, không có control gọi control; entity gọi entity khác chỉ khi có quan hệ cấu trúc (SeatHold với PaymentTransaction, Customer, Showtime; PaymentTransaction với RefundRequest); message trả về đi từ entity về control không phải là lời gọi. Tác nhân thời gian không có.

## 7. Communication diagram

File diagrams/P07-communication-UC-006.drawio có 2 trang: CM1 cho luồng chính (SD1), CM2 cho mọi luồng thay thế, ngoại lệ và biến thể (SD2 đến SD6), giữ nguyên STT của sequence diagram (MUC_CHI_TIET là DAY_DU). Message trả về không vẽ. Message nằm trong fragment ghi kèm guard rút gọn trong ngoặc vuông.

### Trang CM1 - Luồng chính (SD1)

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| CM1-O-A7 | Actor | :Cổng thanh toán | - | - | Tác nhân (ACT-07), vừa tác nhân chính vừa tác nhân phụ |
| CM1-O-PG | Object | :PaymentGateway | «boundary» | - | AC-B-PaymentGateway |
| CM1-O-PC | Object | :PaymentReportController | «control» | - | AC-C-PaymentReportController |
| CM1-O-SH | Object | :SeatHold | «entity» | - | AC-E-SeatHold |
| CM1-O-PT | Object | :PaymentTransaction | «entity» | - | AC-E-PaymentTransaction |
| CM1-O-RR | Object | :RefundRequest | «entity» | - | AC-E-RefundRequest (đỉnh lifeline đặt ngang message Tạo) |
| CM1-O-CU | Object | :Customer | «entity» | - | AC-E-Customer |
| CM1-O-ST | Object | :Showtime | «entity» | - | AC-E-Showtime |
| CM1-O-ES | Object | :EmailService | «boundary» | - | AC-B-EmailService |
| CM1-O-A8 | Actor | :Dịch vụ email | - | - | Tác nhân (ACT-08) |

b) Bảng Edge (link)

| ID | Nguồn | Đích | Loại (Link) | Nhãn (các message theo STT) | Chiều message (Nguồn-->Đích hoặc Đích-->Nguồn) |
| --- | --- | --- | --- | --- | --- |
| CM1-L1 | CM1-O-A7 | CM1-O-PG | Link | 1: // reportTransactionResult (kết quả thành công, mã giao dịch, mã tham chiếu lần giữ ghế, số tiền đã thanh toán) (-->)<br>1.1.5.1: // requestRefund (mã giao dịch, số tiền hoàn, khoá chống hoàn trùng) (<--) | Nguồn-->Đích: 1; Đích-->Nguồn: 1.1.5.1 |
| CM1-L2 | CM1-O-PG | CM1-O-PC | Link | 1.1: // handlePaymentReport (kết quả, mã giao dịch, mã tham chiếu lần giữ ghế, số tiền đã thanh toán, thời điểm nhận báo) (-->)<br>1.1.5: // requestRefund (mã giao dịch, số tiền hoàn, khoá chống hoàn trùng) (<--) | Nguồn-->Đích: 1.1; Đích-->Nguồn: 1.1.5 |
| CM1-L3 | CM1-O-PC | CM1-O-SH | Link | 1.1.1: // settlePaymentReport (lần giữ ghế tìm theo mã giao dịch hoặc mã tham chiếu lần giữ ghế, kết quả, số tiền đã thanh toán, thời điểm nhận báo) (-->)<br>1.1.10: // provideRefundNoticeRecipient (-->) | Nguồn-->Đích: 1.1.1, 1.1.10 |
| CM1-L4 | CM1-O-SH | CM1-O-PT | Link | 1.1.1.1: // checkNotProcessed (mã giao dịch) (-->)<br>1.1.1.3: // markLatePayment (lý do hoàn) (-->) | Nguồn-->Đích: 1.1.1.1, 1.1.1.3 |
| CM1-L5 | CM1-O-SH | CM1-O-SH | Link | 1.1.1.2: // checkHoldStillActive (thời điểm nhận báo) (-->) | Nguồn-->Đích: 1.1.1.2 |
| CM1-L6 | CM1-O-PC | CM1-O-PT | Link | 1.1.2: // prepareRefundRequest (mã giao dịch, loại hoàn toàn bộ, số tiền hoàn) (-->)<br>1.1.7: // recordRefundedAmount (số tiền hoàn) (-->)<br>1.1.9: // provideRefundSummary (-->) | Nguồn-->Đích: 1.1.2, 1.1.7, 1.1.9 |
| CM1-L7 | CM1-O-PT | CM1-O-PT | Link | 1.1.2.1: // checkRefundWithinPaidAmount (toàn bộ số tiền đã thanh toán) (-->) | Nguồn-->Đích: 1.1.2.1 |
| CM1-L8 | CM1-O-PT | CM1-O-RR | Link | 1.1.2.2: «create» // createRefundRequest (mã giao dịch, loại hoàn toàn bộ, số tiền hoàn) (-->) | Nguồn-->Đích: 1.1.2.2 |
| CM1-L9 | CM1-O-RR | CM1-O-RR | Link | 1.1.2.2.1: // generateIdempotencyKey (mã giao dịch, loại hoàn toàn bộ) (-->) | Nguồn-->Đích: 1.1.2.2.1 |
| CM1-L10 | CM1-O-PC | CM1-O-PC | Link | 1.1.3: // startWaitingForRefundResult (BR-43) (-->)<br>1.1.6: // stopWaitingForRefundResult (-->) | Nguồn-->Đích: 1.1.3, 1.1.6 |
| CM1-L11 | CM1-O-PC | CM1-O-RR | Link | 1.1.4: // recordAttempt (-->)<br>1.1.8: // recordResult (thành công) (-->) | Nguồn-->Đích: 1.1.4, 1.1.8 |
| CM1-L12 | CM1-O-SH | CM1-O-CU | Link | 1.1.10.1: // provideEmail (-->) | Nguồn-->Đích: 1.1.10.1 |
| CM1-L13 | CM1-O-SH | CM1-O-ST | Link | 1.1.10.2: // provideMovieAndStartTime (-->) | Nguồn-->Đích: 1.1.10.2 |
| CM1-L14 | CM1-O-PC | CM1-O-ES | Link | 1.1.11: // sendRefundNotificationEmail (email khách, mã giao dịch, số tiền hoàn, tên phim, suất chiếu, lý do hoàn) (-->) | Nguồn-->Đích: 1.1.11 |
| CM1-L15 | CM1-O-ES | CM1-O-A8 | Link | 1.1.11.1: // sendRefundNotificationEmail (email khách, mã giao dịch, số tiền hoàn, tên phim, suất chiếu, lý do hoàn) (-->) | Nguồn-->Đích: 1.1.11.1 |

### Trang CM2 - Luồng thay thế, ngoại lệ và biến thể (SD2 đến SD6)

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| CM2-O-PG | Object | :PaymentGateway | «boundary» | - | AC-B-PaymentGateway |
| CM2-O-PC | Object | :PaymentReportController | «control» | - | AC-C-PaymentReportController |
| CM2-O-SH | Object | :SeatHold | «entity» | - | AC-E-SeatHold |
| CM2-O-PT | Object | :PaymentTransaction | «entity» | - | AC-E-PaymentTransaction |
| CM2-O-RR | Object | :RefundRequest | «entity» | - | AC-E-RefundRequest (đỉnh lifeline đặt ngang message Tạo) |

b) Bảng Edge (link)

| ID | Nguồn | Đích | Loại (Link) | Nhãn (các message theo STT) | Chiều message (Nguồn-->Đích hoặc Đích-->Nguồn) |
| --- | --- | --- | --- | --- | --- |
| CM2-L1 | CM2-O-PC | CM2-O-PC | Link | 1.1e: // logUnrecognizedTransaction (mã giao dịch, kết quả, mã tham chiếu lần giữ ghế, số tiền đã thanh toán, thời điểm nhận báo) (-->) [kết quả thành công và hệ thống không nhận ra giao dịch (2e, BR-38)]<br>1.1d: // logUnrecognizedTransaction (mã giao dịch, kết quả, mã tham chiếu lần giữ ghế, số tiền đã thanh toán, thời điểm nhận báo) (-->) [kết quả thất bại và hệ thống không nhận ra giao dịch (2d, BR-39)]<br>1.1.3a: // after(BR-43) handleRefundNoResponse (-->)<br>1.1.3b: // logRefundFailure (mã giao dịch, số tiền hoàn) (-->) [không phản hồi trong 30 giây và đã hết lượt thử lại (4b, BR-41)]<br>1.1.5a.1: // stopWaitingForRefundResult (-->)<br>1.1.5b.1: // logRefundFailure (mã giao dịch, số tiền hoàn) (-->) [hoàn tiền thất bại và đã hết lượt thử lại (5b, BR-41)] | Nguồn-->Đích: 1.1e, 1.1d, 1.1.3a, 1.1.3b, 1.1.5a.1, 1.1.5b.1 |
| CM2-L2 | CM2-O-SH | CM2-O-PT | Link | 1.1.1.1a: // recordDuplicateReport (thời điểm nhận báo) (-->) [kết quả thành công và giao dịch đã được xử lý trước đó (2a, BR-37)]<br>1.1.1c.2: // recordFailedResult (thất bại, thời điểm nhận báo) (-->) [kết quả thất bại và lần giữ ghế đã hết hạn hoặc đã bị khách huỷ (2c, BR-39)]<br>1.1.1d.2: // recordFailedResult (thất bại, thời điểm nhận báo) (-->) [kết quả thất bại, giao dịch nhận ra, không thuộc 2c: đã có vé hoặc lần giữ ghế đã có báo thất bại (2d, BR-39)]<br>1.1.1.3.1[BR-40]: «create» // createPaymentTransaction (mã giao dịch, số tiền đã thanh toán trong báo) (-->)<br>1.1.1.4[BR-40]: // markLatePayment (lý do hoàn) (-->) | Nguồn-->Đích: 1.1.1.1a, 1.1.1c.2, 1.1.1d.2, 1.1.1.3.1[BR-40], 1.1.1.4[BR-40] |
| CM2-L3 | CM2-O-PC | CM2-O-SH | Link | 1.1.1c: // settlePaymentReport (lần giữ ghế tìm theo mã giao dịch hoặc mã tham chiếu lần giữ ghế, kết quả, số tiền đã thanh toán, thời điểm nhận báo) (-->) [kết quả thất bại và lần giữ ghế đã hết hạn hoặc đã bị khách huỷ (2c, BR-39)]<br>1.1.1d: // settlePaymentReport (lần giữ ghế tìm theo mã giao dịch hoặc mã tham chiếu lần giữ ghế, kết quả, số tiền đã thanh toán, thời điểm nhận báo) (-->) [kết quả thất bại, giao dịch nhận ra, không thuộc 2c: đã có vé hoặc lần giữ ghế đã có báo thất bại (2d, BR-39)]<br>1.1.1[BR-40]: // settlePaymentReport (lần giữ ghế tìm theo mã giao dịch hoặc mã tham chiếu lần giữ ghế, kết quả, số tiền đã thanh toán, thời điểm nhận báo) (-->) | Nguồn-->Đích: 1.1.1c, 1.1.1d, 1.1.1[BR-40] |
| CM2-L4 | CM2-O-SH | CM2-O-SH | Link | 1.1.1c.1: // checkHoldStillActive (thời điểm nhận báo) (-->) [kết quả thất bại và lần giữ ghế đã hết hạn hoặc đã bị khách huỷ (2c, BR-39)]<br>1.1.1d.1: // checkHoldStillActive (thời điểm nhận báo) (-->) [kết quả thất bại, giao dịch nhận ra, không thuộc 2c: đã có vé hoặc lần giữ ghế đã có báo thất bại (2d, BR-39)]<br>1.1.1.2[BR-40]: // checkHoldStillActive (thời điểm nhận báo) (-->)<br>1.1.1.3[BR-40]: // recordPaymentTransaction (mã giao dịch, số tiền đã thanh toán trong báo) (-->) | Nguồn-->Đích: 1.1.1c.1, 1.1.1d.1, 1.1.1.2[BR-40], 1.1.1.3[BR-40] |
| CM2-L5 | CM2-O-PC | CM2-O-RR | Link | 1.1.3a.1: // recordResult (không phản hồi) (-->)<br>1.1.3a.2: // checkRetryRemaining (-->)<br>1.1.5a.2: // recordResult (thất bại) (-->)<br>1.1.5a.3: // checkRetryRemaining (-->) | Nguồn-->Đích: 1.1.3a.1, 1.1.3a.2, 1.1.5a.2, 1.1.5a.3 |

## 8. VOPC

File diagrams/P07-class-UC-006.drawio. ID cell của lớp là mã AC; ngăn thuộc tính và ngăn trách nhiệm có ID "<mã AC>-ATTR" và "<mã AC>-RESP".

a) Bảng Node (lớp)

| ID (mã AC) | Loại (Class) | Nhãn (tên lớp) | Stereotype | Thuộc về | Ngăn thuộc tính | Ngăn trách nhiệm |
| --- | --- | --- | --- | --- | --- | --- |
| AC-B-PaymentGateway | Class | PaymentGateway | «boundary» | - | - | // reportTransactionResult<br>// requestRefund |
| AC-B-EmailService | Class | EmailService | «boundary» | - | - | // sendRefundNotificationEmail |
| AC-C-PaymentReportController | Class | PaymentReportController | «control» | - | - | // handlePaymentReport<br>// logUnrecognizedTransaction<br>// startWaitingForRefundResult<br>// stopWaitingForRefundResult<br>// handleRefundNoResponse<br>// logRefundFailure |
| AC-E-SeatHold | Class | SeatHold | «entity» | - | - | // settlePaymentReport<br>// checkHoldStillActive<br>// recordPaymentTransaction<br>// provideRefundNoticeRecipient |
| AC-E-PaymentTransaction | Class | PaymentTransaction | «entity» | - | lateReason (Văn bản) (mới ở UC này)<br>refundedTotal (Số tiền) (mới ở UC này)<br>duplicateReportCount (Số lượng) (mới ở UC này) | // checkNotProcessed<br>// createPaymentTransaction<br>// markLatePayment<br>// recordDuplicateReport<br>// recordFailedResult<br>// prepareRefundRequest<br>// checkRefundWithinPaidAmount<br>// recordRefundedAmount<br>// provideRefundSummary |
| AC-E-RefundRequest | Class | RefundRequest | «entity» | - | idempotencyKey (Văn bản)<br>requestType (Văn bản)<br>refundAmount (Số tiền)<br>attemptCount (Số lượng)<br>result (Văn bản) | // createRefundRequest<br>// generateIdempotencyKey<br>// recordAttempt<br>// recordResult<br>// checkRetryRemaining |
| AC-E-Customer | Class | Customer | «entity» | - | - | // provideEmail |
| AC-E-Showtime | Class | Showtime | «entity» | - | movieName (Văn bản) (mới ở UC này) | // provideMovieAndStartTime |

Ngăn thuộc tính của lớp tái dùng chỉ liệt kê thuộc tính mới ở UC này; thuộc tính đã có ở UC-005 xem F8 a) của UC-005.

b) Bảng quan hệ

| ID | Lớp A | Lớp B | Loại | Multiplicity | Vai trò | Nguồn |
| --- | --- | --- | --- | --- | --- | --- |
| R-UC006-01 | AC-B-PaymentGateway | AC-C-PaymentReportController | Association | - | - | tạm thời; link F7: CM1-L2 |
| R-UC006-02 | AC-B-EmailService | AC-C-PaymentReportController | Association | - | - | tạm thời; link F7: CM1-L14 |
| R-UC006-03 | AC-C-PaymentReportController | AC-E-SeatHold | Association | - | - | tạm thời; link F7: CM1-L3, CM2-L3 |
| R-UC006-04 | AC-C-PaymentReportController | AC-E-PaymentTransaction | Association | - | - | tạm thời; link F7: CM1-L6 |
| R-UC006-05 | AC-C-PaymentReportController | AC-E-RefundRequest | Association | - | - | tạm thời; link F7: CM1-L11, CM2-L5 |
| R-UC006-06 | AC-E-SeatHold | AC-E-PaymentTransaction | Association | A 1 - B 0..* | - | Giao dịch thanh toán gắn với một lần giữ ghế; giao dịch thứ hai cũng gắn qua mã tham chiếu lần giữ ghế (GL-12, GL-13, BR-40); cùng quan hệ R-UC005-16, giao dịch thứ hai tạo qua SeatHold.recordPaymentTransaction, Q-90; link F7: CM1-L4, CM2-L2 |
| R-UC006-07 | AC-E-PaymentTransaction | AC-E-RefundRequest | Association | A 1 - B 0..* | - | Mỗi yêu cầu hoàn thuộc một giao dịch, một giao dịch có thể có nhiều yêu cầu hoàn khác khoá (BR-43, BR-26); một yêu cầu hoàn thuộc đúng một giao dịch, UC-008 thêm quan hệ tới vé, Q-87; link F7: CM1-L8 |
| R-UC006-08 | AC-E-SeatHold | AC-E-Customer | Association | A 0..* - B 0..1 | - | Người giữ ghế là khách (GL-25); cùng quan hệ R-UC005-14, Q-86; link F7: CM1-L12 |
| R-UC006-09 | AC-E-Showtime | AC-E-SeatHold | Association | A 1 - B 0..* | - | Mỗi lần giữ ghế thuộc đúng một suất chiếu (GL-25); cùng quan hệ R-UC005-10; link F7: CM1-L13 |

Link tự nối (message tự gọi) và link actor-boundary không sinh quan hệ VOPC. Quan hệ SeatHold - Customer và Showtime - SeatHold lấy lại từ UC-005 (R-UC005-14, R-UC005-10) cho cùng cặp lớp; SeatHold - PaymentTransaction lấy lại từ R-UC005-16.

## 9. Ma trận truy vết

| Bước UC | Message (STT) | Lớp tham gia (AC) |
| --- | --- | --- |
| 1 | 1, 1.1 | AC-B-PaymentGateway, AC-C-PaymentReportController |
| 2 | 1.1.1, 1.1.1.1, 1.1.1.2, 1.1.1[BR-40], 1.1.1.2[BR-40] | AC-C-PaymentReportController, AC-E-SeatHold, AC-E-PaymentTransaction |
| 3 | 1.1.1, 1.1.1.3, 1.1.1 (trả về), 1.1.1[BR-40], 1.1.1.3[BR-40], 1.1.1.3.1[BR-40], 1.1.1.4[BR-40], 1.1.1[BR-40] (trả về) | AC-C-PaymentReportController, AC-E-SeatHold, AC-E-PaymentTransaction |
| 4 | 1.1.2, 1.1.2.1, 1.1.2.2, 1.1.2.2.1, 1.1.2 (trả về), 1.1.3, 1.1.4, 1.1.5, 1.1.5.1 | AC-C-PaymentReportController, AC-E-PaymentTransaction, AC-E-RefundRequest, AC-B-PaymentGateway |
| 5 | 1.1.5.1 (trả về), 1.1.5 (trả về), 1.1.6 | AC-B-PaymentGateway, AC-C-PaymentReportController |
| 6 | 1.1.7, 1.1.8 | AC-C-PaymentReportController, AC-E-PaymentTransaction, AC-E-RefundRequest |
| 7 | 1.1.9, 1.1.9 (trả về), 1.1.10, 1.1.10.1, 1.1.10.2, 1.1.10 (trả về), 1.1.11, 1.1.11.1 | AC-C-PaymentReportController, AC-E-PaymentTransaction, AC-E-SeatHold, AC-E-Customer, AC-E-Showtime, AC-B-EmailService |
| 2a | 1.1.1.1a | AC-E-SeatHold, AC-E-PaymentTransaction |
| 2b | 1.1.1 (trả về) | AC-E-SeatHold, AC-C-PaymentReportController |
| 2c | 1.1.1c, 1.1.1c.1, 1.1.1c.2 | AC-C-PaymentReportController, AC-E-SeatHold, AC-E-PaymentTransaction |
| 2d | 1.1.1d, 1.1.1d.1, 1.1.1d.2, 1.1d | AC-C-PaymentReportController, AC-E-SeatHold, AC-E-PaymentTransaction |
| 2e | 1.1e | AC-C-PaymentReportController |
| 4a | 1.1.3a, 1.1.3a.1, 1.1.3a.2 | AC-C-PaymentReportController, AC-E-RefundRequest |
| 4b | 1.1.3a, 1.1.3a.1, 1.1.3a.2, 1.1.3b | AC-C-PaymentReportController, AC-E-RefundRequest |
| 5a | 1.1.5a.1, 1.1.5a.2, 1.1.5a.3 | AC-C-PaymentReportController, AC-E-RefundRequest |
| 5b | 1.1.5a.1, 1.1.5a.2, 1.1.5a.3, 1.1.5b.1 | AC-C-PaymentReportController, AC-E-RefundRequest |

Bước 1 và 5 là bước của tác nhân; message của hai bước này đi từ actor vào AC-B-PaymentGateway (actor không là lớp trong VOPC).

## 10. File .drawio

Ba file nằm trong diagrams/: P07-sequence-UC-006.drawio (6 trang), P07-communication-UC-006.drawio (2 trang), P07-class-UC-006.drawio (1 trang). XML không nén, ID cell trùng ID trong bảng mô hình (ID cell message sequence dạng <ID trang>-M-<STT>; STT có hậu tố [BR-40] thì bỏ dấu ngoặc vuông, dùng gạch dưới).

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Trạng thái |
| --- | --- | --- | --- | --- |
| Q-87 | P05 mục 3 xếp "khoản hoàn, yêu cầu hoàn" vào Số tiền hoàn (GL-45) và Tình trạng hoàn tiền (GL-56), không là thuật ngữ riêng. Nhưng BR-43 đòi khoá chống hoàn trùng gắn với từng yêu cầu hoàn, phân biệt được với yêu cầu hoàn khác trên cùng giao dịch, và có lượt thử lại tính theo yêu cầu. UC-006 mô hình hoá thành entity RefundRequest (idempotencyKey, requestType, refundAmount, attemptCount, result) thuộc một PaymentTransaction. Giữ entity này, hay đưa khoá và số lần thử lại thành thuộc tính của PaymentTransaction (khi đó UC-008, nơi một giao dịch có nhiều lần hoàn theo vé, cần cấu trúc khác)? (Giữ entity RefundRequest, P08 hợp nhất với UC-008 / Thuộc tính của PaymentTransaction) | AC-E-RefundRequest, AC-E-PaymentTransaction; R-UC006-07; // generateIdempotencyKey, // recordAttempt, // checkRetryRemaining; P05; P08 | P05 mục 3 và BR-43 xếp "yêu cầu hoàn" khác nhau: P05 coi là cách gọi, BR-43 coi là đối tượng mang khoá | Đã trả lời: giữ entity RefundRequest dùng chung cho UC-006 và UC-008 (thêm liên kết tới vé), khoá và lượt thử lại theo từng yêu cầu hoàn; PaymentTransaction giữ tổng đã hoàn; Ticket chỉ tham chiếu (theo đề xuất của review). Gộp: Q-93 (UC-008) gộp vào Q-87. Thêm thuật ngữ vào P05. |
| Q-88 | Khi nhận báo thành công, lần giữ ghế còn ở trạng thái Đang giữ nhưng đã quá thời điểm hết hạn (ghế chưa được giải phóng, REQ-76): ai chuyển lần giữ ghế sang Hết hạn và giải phóng ghế? P04 UC-006 Mục 8 nói use case này không đổi trạng thái ghế, còn SD10 của UC-005 chuyển sang Hết hạn rồi mới giao UC-006. UC-006 hiện coi trạng thái hiệu lực là Hết hạn để hoàn tiền (BR-14), không đổi trạng thái lần giữ ghế. (UC-005 chuyển trước khi giao cho UC-006 / UC-006 tự chuyển trong thao tác không chia cắt) | AC-E-SeatHold, // checkHoldStillActive, // settlePaymentReport; bước 2; SD1; Q-83; BR-14, BR-85, BR-86 | P04 Mục 8 đoạn 4 (mốc quyết định là thời điểm nhận báo) và đoạn 10 (không đổi trạng thái ghế); BR-86 chỉ nói trạng thái cuối không đổi | Gộp vào Q-83 (UC-005). Đã trả lời: điểm tiếp nhận chuyển lần giữ ghế Đang giữ quá hạn sang Hết hạn trước, UC-006 chỉ thấy trạng thái cuối. |
| Q-89 | Kết quả thất bại cổng báo cho giao dịch hệ thống không nhận ra (luồng 2d, BR-39) được "ghi nhận" ở đâu, khi không có giao dịch thanh toán nào để ghi và log lỗi là hoạt động kỹ thuật? UC-006 hiện chỉ ghi log như luồng 2e. (Chỉ ghi log / Ghi nhận vào một nơi khác do P04 chỉ rõ) | SD3 message 1.1d; // logUnrecognizedTransaction; luồng 2d | P04 luồng 2d dùng cùng động từ "ghi nhận" cho cả giao dịch đã có vé và giao dịch không nhận ra | Đã trả lời: chỉ ghi log lỗi như luồng 2e, vì không có giao dịch hay lần giữ ghế nào để ghi và BR-39 chỉ cần không hoàn tiền (theo đề xuất của review). |
| Q-90 | Giao dịch thứ hai (BR-40) chưa có bản ghi trong hệ thống khi cổng báo. Bước 3 "ghi nhận giao dịch là thanh toán trễ" có tạo mới giao dịch thanh toán (mã giao dịch, số tiền trong báo) không? UC-006 hiện tạo mới để báo trùng của giao dịch này nhận ra được ở luồng 2a (BR-37), để tính hạn mức hoàn (BR-26) và để khoá chống hoàn trùng có mã giao dịch. (Tạo mới ở bước 3 / Phương án khác do P04 chỉ rõ) | SD6; AC-E-SeatHold, // recordPaymentTransaction; R-UC006-06; bước 3; BR-37, BR-40, BR-26 | P04 bước 3 và Tiền điều kiện chỉ nêu giao dịch do hệ thống tạo ở UC-005 bước 10 | Gộp vào Q-85 (UC-005). Đã trả lời: tạo mới giao dịch thứ hai, do SeatHold ghi nhận bằng trách nhiệm recordPaymentTransaction của UC-005. |

## Giả định

Không có (chế độ NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
| --- | --- | --- | --- |
| P04 | UC-006 bước 7 | BR-89 (dịch vụ email từ chối hoặc không phản hồi lúc gửi email thông báo hoàn tiền) chỉ nằm ở Mục 8, luồng thay thế không có mã luồng tương ứng nên không có message lỗi ở P07 | Thêm luồng 7a (dịch vụ email từ chối hoặc không phản hồi: khoản hoàn giữ nguyên hiệu lực, thử gửi lại, ghi log lỗi, kết thúc) hoặc ghi rõ ở Mục 3 là bước 7 không có luồng thay thế |
| P04 | UC-006 bước 3, luồng 2d | Chưa nói giao dịch thứ hai có được tạo bản ghi ở bước 3 không (Q-90) và kết quả thất bại của giao dịch không nhận ra được ghi nhận ở đâu (Q-89) | Ghi giao dịch thứ hai được tạo ở bước 3 và luồng 2d của giao dịch không nhận ra chỉ ghi log |
| P04 | UC-006 Mục 8, luồng 2b | Lần giữ ghế Đang giữ nhưng đã quá thời điểm hết hạn mà báo thành công đến: Mục 8 chỉ nói không đổi trạng thái ghế, chưa nói ai chuyển lần giữ ghế sang Hết hạn (Q-88) | Ghi điểm tiếp nhận chuyển lần giữ ghế sang Hết hạn trước khi UC-006 xử lý |
| P05 | Mục 3 "Khoản hoàn, yêu cầu hoàn" | RefundRequest được chốt là entity dùng chung (Q-87) nên "yêu cầu hoàn" là khái niệm có định danh | Thêm thuật ngữ Yêu cầu hoàn (Refund Request) vào P05 mục 2 và bỏ khỏi mục 3 |
| P03 | Quan hệ UC-005 và UC-006 | P03 không có quan hệ giữa hai use case, trong khi báo thành công đến sau trạng thái cuối do UC-005 hoặc UC-006 xử lý qua điểm tiếp nhận dùng chung (Q-83) | Thêm quan hệ giữa UC-005 và UC-006 qua điểm tiếp nhận dùng chung |
| P02R | UC-006 và UC-008 | Cùng một cơ chế hoàn tiền qua cổng (khoá chống hoàn trùng, chờ 30 giây, thử lại, log lỗi: BR-26, BR-41, BR-43) lặp ở hai use case | Cân nhắc tách use case được include "Hoàn tiền qua cổng thanh toán" cho UC-006 và UC-008; khi đó control chờ, thử lại, log dùng chung thay cho hai bộ trách nhiệm trùng tên |

## Vấn đề còn mở

- UC-006 không có control riêng: control là PaymentReportController, UC-005 làm chủ cùng SeatHold.settlePaymentReport và SeatHold.checkHoldStillActive (Q-83). UC-006 chỉ vẽ nhánh thanh toán trễ, báo trùng, thất bại muộn và hoàn tiền, bắt đầu từ message 1.1 của PaymentGateway tới PaymentReportController.
- Xử lý tuần tự theo lần giữ ghế: toàn bộ kiểm tra và ghi nhận ở bước 2, 3 (message 1.1.1.1 đến 1.1.1.3) nằm trong trách nhiệm // settlePaymentReport của SeatHold, cùng đơn vị khoá với việc bán ghế của UC-005. Mỗi báo thấy trạng thái do báo trước để lại; lần giữ ghế đã ở trạng thái cuối thì không đổi (UC-006 chỉ ghi vào PaymentTransaction), nên báo đến sau luôn được xử lý theo trạng thái cuối, và chỉ báo đầu tiên của một giao dịch qua được // checkNotProcessed (BR-37). Cơ chế khoá chọn ở P09.
- Chống hoàn trùng: lớp bảo vệ thứ nhất là xử lý tuần tự ở bước 2, 3 (mỗi giao dịch chỉ có một yêu cầu hoàn toàn bộ); lớp thứ hai là khoá chống hoàn trùng của RefundRequest, sinh một lần ở // generateIdempotencyKey từ mã giao dịch và loại yêu cầu hoàn toàn bộ, mọi lần thử lại dùng lại cùng RefundRequest và cùng khoá. UC-008 dùng cùng RefundRequest với khoá từ mã giao dịch và mã vé.
- Sequence SD4 và SD5 dùng opt cho luồng quay lại bước 4 thay cho alt của F5: hai trang chỉ vẽ phần khác luồng chính, không có toán hạng luồng chính để làm toán hạng thứ hai của alt; luồng hết lượt thử lại kết thúc use case nên dùng break đặt trước. Luồng 2b vẽ bằng break có message trả về của // settlePaymentReport (kết quả bán ghế), không còn break rỗng.
- Customer và Showtime ở UC này chỉ có trách nhiệm cung cấp dữ liệu (// provideEmail, // provideMovieAndStartTime); đặc tả không có hành vi nào khác trên dữ liệu đó, hành vi thuộc UC-001 và UC-014 nên chấp nhận. Showtime đọc được cả suất chiếu Đã xoá (BR-58). Thuộc tính movieName của Showtime trùng nghĩa với movieTitle (UC-009) và movie (UC-014); P08 gộp.
- Số lần thử lại (BR-41) và khoảng cách giữa hai lần thử là quyết định thiết kế (P09); phân tích chỉ có // checkRetryRemaining. Thời hạn chờ 30 giây tính cho mỗi lần gửi: mỗi lần quay lại bước 4 lặp message 1.1.3 (bắt đầu chờ).
- Thông tin cổng trả về: số tiền đã thanh toán trong báo chỉ dùng cho giao dịch thứ hai (Dữ liệu vào 1 mục 4); với giao dịch hệ thống đã tạo, số tiền lấy từ PaymentTransaction. Việc nhận ra giao dịch (tra theo mã giao dịch rồi mã tham chiếu) coi là có sẵn theo A6 a), control gửi message thẳng tới lần giữ ghế tìm được; khi không tìm được thì control tự ghi log (2e, 2d).
- Mới: AC-E-RefundRequest (UC-006 là chủ, UC-008 dùng lại và thêm liên kết tới vé). Lớp tái dùng bổ sung trách nhiệm hoặc thuộc tính: PaymentGateway, EmailService, PaymentReportController, SeatHold, PaymentTransaction, Customer, Showtime. Trách nhiệm cùng nghĩa dùng lại tên của UC-005 (reportTransactionResult, recordFailedResult, recordPaymentTransaction, checkHoldStillActive); trách nhiệm khác điều kiện đặt tên khác (markLatePayment so với markProcessed). Tên trách nhiệm hoàn tiền thống nhất với UC-008 (prepareRefundRequest, recordRefundedAmount, startWaitingForRefundResult, stopWaitingForRefundResult, handleRefundNoResponse, logRefundFailure).
- Số lớp là 8 (2 boundary, 1 control tái dùng, 5 entity), trong khoảng 4-12. Control có 6 trách nhiệm, 5 trong đó là message tự gọi theo A2 hoặc ghi log (startWaitingForRefundResult, stopWaitingForRefundResult, handleRefundNoResponse, logUnrecognizedTransaction, logRefundFailure); không giữ quy tắc thuộc dữ liệu của entity.
