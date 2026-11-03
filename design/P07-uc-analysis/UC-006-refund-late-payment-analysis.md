# P07 - Phân tích use case UC-006 Hoàn tiền thanh toán trễ - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
| --- | --- |
| Bước | P07 |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md; P04-uc-specs/UC-006-refund-late-payment.md 1.5; P01-actors.md 1.1; P02-usecases.md; P03-usecase-model.md 1.0; P05-glossary.md 1.1; P06-supplementary-spec.md 1.1; P04-uc-specs/_BR-register.md; P07-uc-analysis/UC-005-book-tickets-analysis.md 1.0 (F1, F3.4, F8 b), Câu hỏi mở, Vấn đề còn mở; sổ đăng ký AC lấy từ file này) |
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
| Use case liên quan không qua include, extend | UC-005 Đặt vé: cùng nhận kết quả giao dịch từ cổng; báo thành công đến sau trạng thái cuối của lần giữ ghế chuyển sang UC-006 (BR-14, BR-15, BR-37, BR-86); luồng 2b của UC-006 thuộc UC-005 (EV-07). Việc control nào tiếp nhận báo đầu tiên và chuyển giao còn mở (Q-83 của UC-005, không tự quyết ở đây). UC-008 Huỷ vé: cùng hoàn tiền qua cổng, khoá chống hoàn trùng khác (mã giao dịch kèm mã vé, BR-43). |
| Tác nhân thời gian | Không có. P02 không có use case do tác nhân thời gian kích hoạt trên đối tượng mà UC-006 tạo hoặc đổi, nên không có message hẹn mốc. Thời hạn chờ kết quả hoàn tiền 30 giây (BR-43) là thời hạn nội bộ, vẽ bằng message tự gọi theo A2. |
| File P07 đã có được dùng làm sổ đăng ký AC | UC-005-book-tickets-analysis.md (14 mã AC: AC-B-BookTicketsForm, AC-B-CounterBookTicketsForm, AC-B-PaymentGateway, AC-B-EmailService, AC-C-BookTicketsController, AC-E-Customer, AC-E-BoxOfficeClerk, AC-E-Showtime, AC-E-PriceList, AC-E-SeatStatus, AC-E-SeatHold, AC-E-PaymentTransaction, AC-E-Booking, AC-E-Ticket). Không đọc file P07 của UC chạy song song. |

## 2. Đặc tả bổ sung

| Bước UC | Thực hiện bởi | Mô tả trong đặc tả | Mô tả bổ sung (hệ thống làm gì bên trong) | Nguồn (BR, GL, REQ) |
| --- | --- | --- | --- | --- |
| 1 | Cổng thanh toán | Báo kết quả của một giao dịch thanh toán (xem Dữ liệu vào 1). | Không đổi | GL-17, NFR-16, REQ-79 |
| 2 | Hệ thống | Tra giao dịch theo mã giao dịch; với mã không phải của giao dịch hệ thống đã tạo thì tra lần giữ ghế theo mã tham chiếu lần giữ ghế kèm trong báo của cổng. Kiểm tra: kết quả thành công, nhận ra giao dịch, giao dịch chưa được xử lý, lần giữ ghế ở trạng thái Hết hạn, Đã huỷ, Thanh toán thất bại hoặc Đã hoàn tất; các kiểm tra và bước 3 là một thao tác xử lý tuần tự theo lần giữ ghế. | Control tìm lần giữ ghế theo mã giao dịch đã lưu hoặc theo mã tham chiếu lần giữ ghế trong báo, rồi giao cho lần giữ ghế một thao tác không chia cắt theo lần giữ ghế. Trong thao tác đó lần giữ ghế kiểm giao dịch chưa được xử lý và xác định trạng thái hiệu lực của chính nó tại thời điểm nhận báo: Đang giữ nhưng đã quá thời điểm hết hạn tính là Hết hạn, trạng thái cuối giữ nguyên (Q-88). Không tìm được lần giữ ghế thì control chỉ ghi log lỗi (2e). | BR-14, BR-15, BR-37, BR-38, BR-40, BR-85, BR-86, GL-25, GL-31, REQ-136, REQ-160, REQ-161 |
| 3 | Hệ thống | Ghi nhận giao dịch là thanh toán trễ chờ hoàn tiền và không tạo vé. | Trong cùng thao tác của bước 2, giao dịch thanh toán được đánh dấu thanh toán trễ chờ hoàn tiền, kèm lý do hoàn và đã xử lý, nên báo đến sau của cùng giao dịch thấy trạng thái này. Giao dịch thứ hai chưa có bản ghi thì lần giữ ghế tạo giao dịch thanh toán mới từ mã giao dịch và số tiền trong báo (Q-90). Không tạo vé, không đổi trạng thái lần giữ ghế và ghế. | BR-14, BR-15, BR-37, BR-40, BR-85, GL-51, GL-13 |
| 4 | Hệ thống | Yêu cầu cổng thanh toán hoàn toàn bộ số tiền đã thanh toán của giao dịch, kèm khoá chống hoàn trùng của yêu cầu hoàn này (mã giao dịch và loại yêu cầu hoàn toàn bộ); số tiền lấy từ giao dịch hệ thống đã tạo, hoặc từ báo của cổng với giao dịch thứ hai. | Giao dịch thanh toán kiểm khoản hoàn là toàn bộ số tiền đã thanh toán và tổng đã hoàn không vượt số này, rồi tạo yêu cầu hoàn toàn bộ; yêu cầu hoàn sinh khoá chống hoàn trùng từ mã giao dịch và loại yêu cầu. Control bắt đầu chờ tối đa 30 giây, yêu cầu hoàn ghi nhận một lần gửi, rồi chuyển số tiền hoàn và khoá cho cổng qua boundary. Mọi lần thử lại dùng lại cùng yêu cầu hoàn và cùng khoá. | BR-14, BR-15, BR-26, BR-37, BR-40, BR-43, GL-20, GL-44, GL-45, Q-87 |
| 5 | Cổng thanh toán | Trả về kết quả hoàn tiền thành công. | Không đổi | GL-02, NFR-17 |
| 6 | Hệ thống | Ghi nhận giao dịch đã được hoàn toàn bộ số tiền. | Control ngừng chờ. Giao dịch thanh toán ghi nhận đã hoàn toàn bộ số tiền hoàn; yêu cầu hoàn ghi kết quả thành công. | BR-26, BR-37, GL-45 |
| 7 | Hệ thống | Gửi email thông báo hoàn tiền cho khách qua dịch vụ email (xem Dữ liệu ra 1, Dữ liệu ra 2). | Giao dịch thanh toán cung cấp mã giao dịch, số tiền hoàn và lý do hoàn; lần giữ ghế lấy email của khách giữ ghế và tên phim, giờ bắt đầu từ suất chiếu. Control chuyển nội dung cho dịch vụ email qua boundary và không chờ kết quả gửi. | BR-15, BR-89, GL-06, REQ-90, REQ-116, REQ-157, NFR-18 |
| 2a | Hệ thống | Ghi nhận lần báo trùng, không tạo vé và không yêu cầu hoàn tiền thêm. | Giao dịch thanh toán tăng số lần báo trùng. Không tạo vé, không tạo yêu cầu hoàn; vé của giao dịch (nếu đã tạo ở UC-005) giữ nguyên. | BR-37, REQ-110, GL-12 |
| 2b | - | - | Lần giữ ghế trả về kết quả còn hiệu lực chưa quá hạn; control dừng và không ghi gì. UC-005 xử lý báo này (EV-07). | EV-07, BR-86 |
| 2c | Hệ thống | Ghi nhận kết quả thất bại và không hoàn tiền. | Lần giữ ghế xác định trạng thái hiệu lực là Hết hạn hoặc Đã huỷ, giao dịch thanh toán ghi nhận kết quả thất bại báo muộn. Không có khoản hoàn vì khách chưa mất tiền. | BR-39, BR-86, REQ-133 |
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
| ACT-07 Cổng thanh toán | Hệ thống ngoài | PaymentGateway | Giao diện hệ thống | Tái dùng AC-B-PaymentGateway (UC-005) | Một boundary cho cả hai vai trò của ACT-07: nhận kết quả giao dịch (tác nhân chính, bước 1) và nhận yêu cầu hoàn, trả kết quả hoàn (tác nhân phụ, bước 4, 5). Tên theo hệ thống ngoài, không trùng tên entity (entity là PaymentTransaction). |
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
| 12 | thanh toán trễ, thanh toán đến trễ | 3; BR-14, BR-15 | Loại - thuộc tính của PaymentTransaction | Giá trị refundStatus và lý do hoàn (lateReason) của giao dịch (GL-51). |
| 13 | lần báo trùng, báo trùng | 2a; BR-37 | Loại - thuộc tính của PaymentTransaction | Số lần báo trùng ghi vào giao dịch (duplicateReportCount); không có định danh riêng. |
| 14 | yêu cầu hoàn, khoản hoàn | 4, 6; BR-43 | Entity AC-E-RefundRequest | Có định danh theo khoá chống hoàn trùng, vòng đời (số lần gửi, kết quả) và hành vi riêng (sinh khoá, kiểm lượt thử lại). P05 mục 3 xếp "yêu cầu hoàn" vào Số tiền hoàn và Tình trạng hoàn tiền; mô hình hoá thành entity chờ xác nhận ở Q-87. |
| 15 | khoá chống hoàn trùng, loại yêu cầu hoàn toàn bộ | 4; BR-43 | Loại - thuộc tính của RefundRequest | idempotencyKey và requestType; khoá gắn với từng yêu cầu hoàn (GL-20). |
| 16 | số tiền đã thanh toán | 4; Dữ liệu vào 1 mục 4; BR-26 | Loại - thuộc tính của PaymentTransaction | amount của giao dịch (GL-44). |
| 17 | số tiền hoàn, toàn bộ số tiền | 4, 6, 7; Dữ liệu ra 2; BR-26 | Loại - thuộc tính của RefundRequest | refundAmount; tổng đã hoàn của giao dịch là refundedAmount của PaymentTransaction (GL-45). |
| 18 | kết quả hoàn tiền | 5, 5a, 6 | Loại - thuộc tính của RefundRequest | result của lần gửi gần nhất: thành công, thất bại, không phản hồi. |
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
| --- | --- | --- | --- |
| RefundLatePaymentController | UC-006 | Mới (AC-C-RefundLatePaymentController) | Một control cho use case: nhận kết quả giao dịch từ boundary, tìm lần giữ ghế, điều phối bước 2 đến 7, chờ kết quả hoàn tiền (BR-43), ghi log lỗi. Mọi quy tắc nghiệp vụ (trạng thái hiệu lực, chưa xử lý, hạn mức hoàn, khoá chống hoàn trùng, lượt thử lại) nằm ở entity. Có 7 trách nhiệm, trong khoảng 2-10. Việc control này hay control của UC-005 tiếp nhận báo đầu tiên còn phụ thuộc Q-83. |

### 3.4 Bảng lớp phân tích

| AC | Stereotype | Tên | Trách nhiệm | Thuộc tính chính | Bước UC nguồn | Loại boundary | Mới hoặc tái dùng | GL |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| AC-B-PaymentGateway | boundary | PaymentGateway | // reportTransactionResult: nhận kết quả giao dịch do cổng thanh toán báo về<br>// requestRefund: chuyển yêu cầu hoàn toàn bộ, kèm khoá chống hoàn trùng, tới cổng thanh toán<br>// reportRefundResult: nhận kết quả hoàn tiền do cổng thanh toán trả về | - | 1, 2, 4, 5, 2a, 2b, 2c, 2d, 4a, 5a | Giao diện hệ thống | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-02, GL-17 |
| AC-B-EmailService | boundary | EmailService | // sendRefundNotificationEmail: chuyển email thông báo hoàn tiền tới dịch vụ email | - | 7 | Giao diện hệ thống | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-06 |
| AC-C-RefundLatePaymentController | control | RefundLatePaymentController | // handleLateTransactionResult: điều phối bước 2 đến 4 khi nhận kết quả giao dịch từ cổng: tìm lần giữ ghế, giao thao tác không chia cắt, yêu cầu hoàn<br>// logUnrecognizedTransaction: ghi log lỗi giao dịch không nhận ra để xử lý thủ công ngoài hệ thống (BR-38)<br>// startWaitingForRefundResult: bắt đầu chờ kết quả hoàn tiền tối đa 30 giây (BR-43)<br>// stopWaitingForRefundResult: ngừng chờ khi cổng đã trả kết quả hoàn tiền<br>// handleRefundResult: điều phối bước 5 đến 7 theo kết quả hoàn tiền cổng trả về<br>// handleRefundNoResponse: nhận sự kiện hết 30 giây không có kết quả hoàn tiền: ghi nhận, kiểm lượt thử lại (after BR-43)<br>// logRefundFailure: ghi log lỗi khoản hoàn khi hết lượt thử lại, không gửi email (BR-41) | - | 1 đến 7, 2a đến 2e, 4a, 4b, 5a, 5b | - | Mới | - |
| AC-E-SeatHold | entity | SeatHold | // settleLateTransactionResult: thao tác không chia cắt theo lần giữ ghế khi cổng báo kết quả: kiểm giao dịch chưa xử lý, xác định trạng thái hiệu lực, ghi nhận thanh toán trễ hoặc kết quả thất bại, không đổi trạng thái lần giữ ghế (BR-37, BR-85, BR-86)<br>// checkLateStatus: xác định trạng thái hiệu lực tại thời điểm nhận báo (Đang giữ quá hạn tính là Hết hạn) và lý do hoàn (BR-14, BR-15, BR-40)<br>// provideRefundNoticeRecipient: cung cấp email của khách giữ ghế, tên phim và giờ bắt đầu suất chiếu cho email hoàn tiền | - | 2, 3, 7, 2a đến 2d | - | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-25, GL-31, GL-51 |
| AC-E-PaymentTransaction | entity | PaymentTransaction | // checkNotProcessed: kiểm giao dịch chưa dùng để tạo vé và chưa ghi nhận thanh toán trễ (BR-37)<br>// markLatePayment: ghi nhận giao dịch là thanh toán trễ chờ hoàn tiền, kèm lý do hoàn, đã xử lý (BR-14, BR-15, BR-40)<br>// createLatePaymentTransaction: tạo giao dịch thanh toán cho giao dịch thứ hai từ mã giao dịch và số tiền trong báo của cổng (BR-40, Q-90)<br>// recordDuplicateReport: ghi nhận lần báo trùng, không hoàn thêm (BR-37)<br>// recordLateFailedResult: ghi nhận kết quả thất bại báo muộn, không hoàn tiền (BR-39)<br>// createFullRefundRequest: điều phối tạo yêu cầu hoàn toàn bộ sau khi kiểm hạn mức hoàn<br>// checkRefundWithinPaidAmount: kiểm tổng số tiền đã hoàn cộng khoản hoàn không vượt số tiền đã thanh toán (BR-26)<br>// markRefunded: ghi nhận giao dịch đã được hoàn toàn bộ số tiền<br>// provideRefundSummary: cung cấp mã giao dịch, số tiền hoàn và lý do hoàn cho email | lateReason (Văn bản) (mới ở UC này), refundStatus (Trạng thái) (mới ở UC này), refundedAmount (Số tiền) (mới ở UC này), duplicateReportCount (Số lượng) (mới ở UC này) | 2, 3, 4, 6, 7, 2a, 2c, 2d | - | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-12, GL-29, GL-44, GL-51 |
| AC-E-RefundRequest | entity | RefundRequest | // createRefundRequest: tạo yêu cầu hoàn toàn bộ gắn giao dịch, loại yêu cầu và số tiền hoàn (BR-43)<br>// generateIdempotencyKey: sinh khoá chống hoàn trùng từ mã giao dịch và loại yêu cầu hoàn toàn bộ, không đổi qua các lần thử lại (BR-43)<br>// recordAttempt: ghi nhận một lần gửi yêu cầu hoàn tới cổng<br>// recordResult: ghi nhận kết quả của lần gửi: thành công, thất bại, không phản hồi<br>// checkRetryRemaining: kiểm còn lượt thử lại (BR-41) | idempotencyKey (Văn bản), requestType (Văn bản), refundAmount (Số tiền), attemptCount (Số lượng), result (Văn bản) | 4, 6, 4a, 4b, 5a, 5b | - | Mới - chạy song song, chờ P08 hợp nhất | GL-20, GL-45 |
| AC-E-Customer | entity | Customer | // provideEmail: cung cấp email của tài khoản khách đã giữ ghế | - | 7 | - | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-18 |
| AC-E-Showtime | entity | Showtime | // provideMovieAndStartTime: cung cấp tên phim và giờ bắt đầu của suất chiếu | movieName (Văn bản) (mới ở UC này) | 7 | - | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-47 |

Tổng cộng 8 lớp: 2 boundary, 1 control, 5 entity. Thuộc tính đã có ở UC-005 của lớp tái dùng (SeatHold: holdRef, status, holdTime, expiryTime; PaymentTransaction: transactionCode, amount, processed, result; Customer: email, phoneNumber, password; Showtime: startTime và các thuộc tính khác) dùng lại nguyên, bảng trên chỉ ghi thuộc tính mới ở UC này. Entity cốt lõi của chủ đề xử lý tuần tự theo lần giữ ghế và chống hoàn trùng: AC-E-SeatHold, AC-E-PaymentTransaction, AC-E-RefundRequest.

## 4. Phân bổ hành vi

| Bước UC | Trách nhiệm | Lớp nhận (AC) | Nguyên tắc | Lý do khi có lựa chọn khác |
| --- | --- | --- | --- | --- |
| 1 | // reportTransactionResult | AC-B-PaymentGateway | Giao tiếp tác nhân | - |
| 1 | // handleLateTransactionResult | AC-C-RefundLatePaymentController | Controller | Phụ thuộc Q-83: nếu control của UC-005 tiếp nhận báo đầu tiên (như SD10 của UC-005) thì message 1.1 do control đó gửi tới control này. |
| 2 | // settleLateTransactionResult | AC-E-SeatHold | Information Expert | Dữ liệu nằm ở nhiều lớp (trạng thái lần giữ ghế, giao dịch). Đơn vị xử lý tuần tự và khoá là lần giữ ghế (BR-85), trạng thái cuối chỉ lần giữ ghế biết (BR-86), nên giao cho SeatHold. Giao cho control làm control ôm quy tắc thuộc dữ liệu của entity; giao cho PaymentTransaction thì giao dịch phải biết trạng thái lần giữ ghế, tăng coupling. |
| 2 | // checkNotProcessed | AC-E-PaymentTransaction | Information Expert | Giao dịch biết mình đã dùng để tạo vé hay đã ghi nhận trễ chưa (BR-37). |
| 2 | // checkLateStatus | AC-E-SeatHold | Information Expert | Trạng thái và thời điểm hết hạn thuộc SeatHold; Đang giữ quá hạn tính là Hết hạn nhưng không đổi trạng thái (Q-88). |
| 3 | // markLatePayment | AC-E-PaymentTransaction | Information Expert | Đánh dấu thanh toán trễ và đã xử lý trên dữ liệu của giao dịch; trong cùng thao tác với bước 2. |
| 3 | // createLatePaymentTransaction | AC-E-PaymentTransaction | Creator | Giao dịch thứ hai chưa có bản ghi; SeatHold ghi nhận và có dữ liệu khởi tạo (mã tham chiếu, báo của cổng), như recordPaymentTransaction ở UC-005 (Q-90). |
| 4 | // createFullRefundRequest | AC-E-PaymentTransaction | Information Expert | Giao dịch nắm số tiền đã thanh toán và các khoản đã hoàn nên điều phối kiểm hạn mức rồi tạo yêu cầu hoàn. |
| 4 | // checkRefundWithinPaidAmount | AC-E-PaymentTransaction | Information Expert | BR-26 tính trên dữ liệu của giao dịch (amount, refundedAmount). |
| 4 | // createRefundRequest | AC-E-RefundRequest | Creator | Giao dịch ghi nhận các yêu cầu hoàn của nó (một giao dịch có nhiều yêu cầu hoàn khác khoá, BR-43). |
| 4 | // generateIdempotencyKey | AC-E-RefundRequest | Information Expert | Khoá gắn với từng yêu cầu hoàn và không đổi qua các lần thử lại (BR-43). Đặt khoá ở PaymentTransaction thì hai yêu cầu hoàn khác nhau của một giao dịch dùng chung khoá, sai BR-43. |
| 4 | // startWaitingForRefundResult | AC-C-RefundLatePaymentController | Giao cho control | Thời hạn nội bộ 30 giây (BR-43) không là tác nhân; A2. |
| 4 | // recordAttempt | AC-E-RefundRequest | Information Expert | Đếm số lần gửi của chính yêu cầu hoàn. |
| 4 | // requestRefund | AC-B-PaymentGateway | Giao tiếp tác nhân | - |
| 5 | // reportRefundResult | AC-B-PaymentGateway | Giao tiếp tác nhân | - |
| 5 | // handleRefundResult, // stopWaitingForRefundResult | AC-C-RefundLatePaymentController | Controller | - |
| 6 | // markRefunded | AC-E-PaymentTransaction | Information Expert | Ghi nhận đã hoàn toàn bộ và cộng vào refundedAmount của giao dịch. |
| 6 | // recordResult | AC-E-RefundRequest | Information Expert | Kết quả lần gửi thuộc yêu cầu hoàn. |
| 7 | // provideRefundSummary | AC-E-PaymentTransaction | Information Expert | Mã giao dịch, số tiền hoàn, lý do hoàn do giao dịch giữ. |
| 7 | // provideRefundNoticeRecipient | AC-E-SeatHold | Information Expert | Lần giữ ghế có quan hệ cấu trúc tới khách và suất chiếu; control gọi một lần thay vì tự đi tới Customer và Showtime (low coupling). |
| 7 | // provideEmail | AC-E-Customer | Information Expert | - |
| 7 | // provideMovieAndStartTime | AC-E-Showtime | Information Expert | - |
| 7 | // sendRefundNotificationEmail | AC-B-EmailService | Giao tiếp tác nhân | - |
| 2a | // recordDuplicateReport | AC-E-PaymentTransaction | Information Expert | Số lần báo trùng ghi trên giao dịch. |
| 2b | // settleLateTransactionResult (trả về còn hiệu lực) | AC-E-SeatHold | Information Expert | Control chỉ nhận kết quả và dừng, UC-005 xử lý. |
| 2c, 2d | // recordLateFailedResult | AC-E-PaymentTransaction | Information Expert | Ghi kết quả thất bại báo muộn trên giao dịch nhận ra. |
| 2d, 2e | // logUnrecognizedTransaction | AC-C-RefundLatePaymentController | Giao cho control | Không có đối tượng nào để ghi (không tìm được lần giữ ghế hoặc giao dịch); log là hoạt động kỹ thuật, không là entity (P05 mục 3). |
| 4a, 4b, 5a, 5b | // handleRefundNoResponse | AC-C-RefundLatePaymentController | Giao cho control | Nhận sự kiện hết thời hạn nội bộ (A2). |
| 4a, 4b, 5a, 5b | // recordResult, // checkRetryRemaining | AC-E-RefundRequest | Information Expert | Lượt thử lại tính trên yêu cầu hoàn; số lần tối đa là quyết định thiết kế P09. |
| 4b, 5b | // logRefundFailure | AC-C-RefundLatePaymentController | Giao cho control | Khoản hoàn chưa hoàn được đã ghi mã giao dịch và số tiền ở bước 3, 4; log ghi bằng message tự gọi. |

## 5. Sequence diagram phân tích

File diagrams/P07-sequence-UC-006.drawio gồm 6 trang, mỗi trang một sơ đồ dưới đây. Lifeline ACT-07 (:Cổng thanh toán) đặt ở bên trái vì là tác nhân chính; ACT-08 ở bên phải. Việc cổng thanh toán nhận yêu cầu hoàn (message 1.1.5.1) vẽ về lại lifeline này vì cùng một tác nhân ở hai vai trò.

### SD1 - Luồng chính, bước 1 đến 7

a) Luồng thể hiện: Luồng chính: cổng báo thành công, lần giữ ghế ở trạng thái cuối hoặc quá hạn, hoàn toàn bộ, gửi email (BR-14, BR-15, BR-37, BR-85, BR-86, BR-43).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| SD1-L-A7 | Actor | :Cổng thanh toán | - | - | Tác nhân (ACT-07), vừa tác nhân chính vừa tác nhân phụ |
| SD1-L-PG | Lifeline | :PaymentGateway | «boundary» | - | AC-B-PaymentGateway |
| SD1-L-C | Lifeline | :RefundLatePaymentController | «control» | - | AC-C-RefundLatePaymentController |
| SD1-L-SH | Lifeline | :SeatHold | «entity» | - | AC-E-SeatHold |
| SD1-L-PT | Lifeline | :PaymentTransaction | «entity» | - | AC-E-PaymentTransaction |
| SD1-L-RR | Lifeline | :RefundRequest | «entity» | - | AC-E-RefundRequest (đỉnh lifeline đặt ngang message Tạo) |
| SD1-L-CU | Lifeline | :Customer | «entity» | - | AC-E-Customer |
| SD1-L-ST | Lifeline | :Showtime | «entity» | - | AC-E-Showtime |
| SD1-L-ES | Lifeline | :EmailService | «boundary» | - | AC-B-EmailService |
| SD1-L-A8 | Actor | :Dịch vụ email | - | - | Tác nhân (ACT-08) |
| SD1-N1 | Note | Q-83 chưa chốt: control nào tiếp nhận báo đầu tiên. Trang này tính từ lúc control của UC-006 nhận báo (message 1.1). | - | - | Chú thích |
| SD1-N2 | Note | Thao tác không chia cắt theo lần giữ ghế (BR-85, BR-86): các message 1.1.1.1 đến 1.1.1.3 xảy ra liền nhau, báo khác của cùng lần giữ ghế chờ đến lượt. | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | :Cổng thanh toán | :PaymentGateway | // reportTransactionResult (kết quả thành công, mã giao dịch, mã tham chiếu lần giữ ghế, số tiền đã thanh toán) | Đồng bộ | - | 1 |
| 1.1 | :PaymentGateway | :RefundLatePaymentController | // handleLateTransactionResult (kết quả, mã giao dịch, mã tham chiếu lần giữ ghế, số tiền đã thanh toán, thời điểm nhận báo) | Đồng bộ | - | 1 |
| 1.1.1 | :RefundLatePaymentController | :SeatHold | // settleLateTransactionResult (lần giữ ghế tìm theo mã giao dịch hoặc mã tham chiếu lần giữ ghế, kết quả, số tiền đã thanh toán, thời điểm nhận báo) | Đồng bộ | - | 2, 3 |
| 1.1.1.1 | :SeatHold | :PaymentTransaction | // checkNotProcessed (mã giao dịch) | Đồng bộ | - | 2 |
| 1.1.1.2 | :SeatHold | :SeatHold | // checkLateStatus (thời điểm nhận báo) | Tự gọi | - | 2 |
| 1.1.1.3 | :SeatHold | :PaymentTransaction | // markLatePayment (lý do hoàn) | Đồng bộ | - | 3 |
| 1.1.1 (trả về) | :SeatHold | :RefundLatePaymentController | giao dịch cần hoàn toàn bộ, lý do hoàn | Trả về | - | 3 |
| 1.1.2 | :RefundLatePaymentController | :PaymentTransaction | // createFullRefundRequest (mã giao dịch) | Đồng bộ | - | 4 |
| 1.1.2.1 | :PaymentTransaction | :PaymentTransaction | // checkRefundWithinPaidAmount (toàn bộ số tiền đã thanh toán) | Tự gọi | - | 4 |
| 1.1.2.2 | :PaymentTransaction | :RefundRequest | «create» // createRefundRequest (mã giao dịch, loại hoàn toàn bộ, số tiền hoàn) | Tạo | - | 4 |
| 1.1.2.2.1 | :RefundRequest | :RefundRequest | // generateIdempotencyKey (mã giao dịch, loại hoàn toàn bộ) | Tự gọi | - | 4 |
| 1.1.2 (trả về) | :PaymentTransaction | :RefundLatePaymentController | yêu cầu hoàn: khoá chống hoàn trùng, số tiền hoàn | Trả về | - | 4 |
| 1.1.3 | :RefundLatePaymentController | :RefundLatePaymentController | // startWaitingForRefundResult (BR-43) | Tự gọi | - | 4 |
| 1.1.4 | :RefundLatePaymentController | :RefundRequest | // recordAttempt | Đồng bộ | - | 4 |
| 1.1.5 | :RefundLatePaymentController | :PaymentGateway | // requestRefund (mã giao dịch, số tiền hoàn, khoá chống hoàn trùng) | Đồng bộ | - | 4 |
| 1.1.5.1 | :PaymentGateway | :Cổng thanh toán | // requestRefund (mã giao dịch, số tiền hoàn, khoá chống hoàn trùng) | Đồng bộ | - | 4 |
| 2 | :Cổng thanh toán | :PaymentGateway | // reportRefundResult (thành công, mã giao dịch) | Đồng bộ | - | 5 |
| 2.1 | :PaymentGateway | :RefundLatePaymentController | // handleRefundResult (thành công, mã giao dịch) | Đồng bộ | - | 5 |
| 2.1.1 | :RefundLatePaymentController | :RefundLatePaymentController | // stopWaitingForRefundResult | Tự gọi | - | 5 |
| 2.1.2 | :RefundLatePaymentController | :PaymentTransaction | // markRefunded (số tiền hoàn) | Đồng bộ | - | 6 |
| 2.1.2.1 | :PaymentTransaction | :RefundRequest | // recordResult (thành công) | Đồng bộ | - | 6 |
| 2.1.3 | :RefundLatePaymentController | :PaymentTransaction | // provideRefundSummary | Đồng bộ | - | 7 |
| 2.1.3 (trả về) | :PaymentTransaction | :RefundLatePaymentController | mã giao dịch, số tiền hoàn, lý do hoàn | Trả về | - | 7 |
| 2.1.4 | :RefundLatePaymentController | :SeatHold | // provideRefundNoticeRecipient | Đồng bộ | - | 7 |
| 2.1.4.1 | :SeatHold | :Customer | // provideEmail | Đồng bộ | - | 7 |
| 2.1.4.2 | :SeatHold | :Showtime | // provideMovieAndStartTime | Đồng bộ | - | 7 |
| 2.1.4 (trả về) | :SeatHold | :RefundLatePaymentController | email khách, tên phim, suất chiếu | Trả về | - | 7 |
| 2.1.5 | :RefundLatePaymentController | :EmailService | // sendRefundNotificationEmail (email khách, mã giao dịch, số tiền hoàn, tên phim, suất chiếu, lý do hoàn) | Đồng bộ | - | 7 |
| 2.1.5.1 | :EmailService | :Dịch vụ email | // sendRefundNotificationEmail (email khách, mã giao dịch, số tiền hoàn, tên phim, suất chiếu, lý do hoàn) | Đồng bộ | - | 7 |

### SD2 - Luồng 2e, 2a và 2b

a) Luồng thể hiện: Giao dịch thành công không nhận ra (2e); báo trùng giao dịch đã xử lý (2a); lần giữ ghế còn hiệu lực, thuộc UC-005 (2b).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| SD2-L-PG | Lifeline | :PaymentGateway | «boundary» | - | AC-B-PaymentGateway |
| SD2-L-C | Lifeline | :RefundLatePaymentController | «control» | - | AC-C-RefundLatePaymentController |
| SD2-L-SH | Lifeline | :SeatHold | «entity» | - | AC-E-SeatHold |
| SD2-L-PT | Lifeline | :PaymentTransaction | «entity» | - | AC-E-PaymentTransaction |
| SD2-N1 | Note | Điểm rẽ trong SD1: 2e tại message 1.1 (không tìm được lần giữ ghế); 2a tại message 1.1.1.1 (giao dịch đã xử lý); 2b tại message 1.1.1.2 (lần giữ ghế còn hiệu lực). | - | - | Chú thích |
| SD2-F1 | Fragment | break [kết quả thành công và hệ thống không nhận ra giao dịch (2e, BR-38)] | - | - | Bao các message của fragment |
| SD2-F2 | Fragment | break [kết quả thành công và giao dịch đã được xử lý trước đó (2a, BR-37)] | - | - | Bao các message của fragment |
| SD2-F3 | Fragment | break [lần giữ ghế còn Đang giữ và chưa quá thời điểm hết hạn (2b)] | - | - | Bao các message của fragment |
| SD2-N2 | Note | Kết thúc use case, không ghi gì. UC-005 xử lý báo này (bước 11, 12, luồng 11a, EV-07). | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
| --- | --- | --- | --- | --- | --- | --- |
| 1.1e | :RefundLatePaymentController | :RefundLatePaymentController | // logUnrecognizedTransaction (mã giao dịch, kết quả, mã tham chiếu lần giữ ghế, số tiền đã thanh toán, thời điểm nhận báo) | Tự gọi | SD2-F1 | 2e |
| 1.1.1.1a | :SeatHold | :PaymentTransaction | // recordDuplicateReport (thời điểm nhận báo) | Đồng bộ | SD2-F2 | 2a |
| 1.1.1b (trả về) | :SeatHold | :RefundLatePaymentController | lần giữ ghế còn hiệu lực, thuộc UC-005 | Trả về | SD2-F3 | 2b |

### SD3 - Luồng 2c và 2d

a) Luồng thể hiện: Kết quả thất bại báo muộn hoặc báo cho giao dịch đã có vé hoặc không nhận ra: chỉ ghi nhận, không hoàn tiền (BR-39).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| SD3-L-C | Lifeline | :RefundLatePaymentController | «control» | - | AC-C-RefundLatePaymentController |
| SD3-L-SH | Lifeline | :SeatHold | «entity» | - | AC-E-SeatHold |
| SD3-L-PT | Lifeline | :PaymentTransaction | «entity» | - | AC-E-PaymentTransaction |
| SD3-N1 | Note | Điểm rẽ trong SD1: kết quả thất bại, tại message 1.1 (2d không nhận ra) và message 1.1.1 (2c, 2d nhận ra). | - | - | Chú thích |
| SD3-F1 | Fragment | break [kết quả thất bại và lần giữ ghế đã hết hạn hoặc đã bị khách huỷ (2c, BR-39)] | - | - | Bao các message của fragment |
| SD3-F2 | Fragment | break [kết quả thất bại, giao dịch nhận ra, không thuộc 2b, 2c: đã có vé hoặc lần giữ ghế đã có báo thất bại (2d, BR-39)] | - | - | Bao các message của fragment |
| SD3-F3 | Fragment | break [kết quả thất bại và hệ thống không nhận ra giao dịch (2d, BR-39)] | - | - | Bao các message của fragment |
| SD3-N2 | Note | Không có giao dịch thanh toán để ghi nhận kết quả, nên chỉ ghi log (Q-89). | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
| --- | --- | --- | --- | --- | --- | --- |
| 1.1.1c | :RefundLatePaymentController | :SeatHold | // settleLateTransactionResult (lần giữ ghế tìm theo mã giao dịch hoặc mã tham chiếu lần giữ ghế, kết quả, số tiền đã thanh toán, thời điểm nhận báo) | Đồng bộ | SD3-F1 | 2c |
| 1.1.1c.1 | :SeatHold | :SeatHold | // checkLateStatus (thời điểm nhận báo) | Tự gọi | SD3-F1 | 2c |
| 1.1.1c.2 | :SeatHold | :PaymentTransaction | // recordLateFailedResult (thất bại, thời điểm nhận báo) | Đồng bộ | SD3-F1 | 2c |
| 1.1.1d | :RefundLatePaymentController | :SeatHold | // settleLateTransactionResult (lần giữ ghế tìm theo mã giao dịch hoặc mã tham chiếu lần giữ ghế, kết quả, số tiền đã thanh toán, thời điểm nhận báo) | Đồng bộ | SD3-F2 | 2d |
| 1.1.1d.1 | :SeatHold | :SeatHold | // checkLateStatus (thời điểm nhận báo) | Tự gọi | SD3-F2 | 2d |
| 1.1.1d.2 | :SeatHold | :PaymentTransaction | // recordLateFailedResult (thất bại, thời điểm nhận báo) | Đồng bộ | SD3-F2 | 2d |
| 1.1d | :RefundLatePaymentController | :RefundLatePaymentController | // logUnrecognizedTransaction (mã giao dịch, kết quả, mã tham chiếu lần giữ ghế, số tiền đã thanh toán, thời điểm nhận báo) | Tự gọi | SD3-F3 | 2d |

### SD4 - Luồng 4a và 4b

a) Luồng thể hiện: Cổng không phản hồi yêu cầu hoàn tiền trong 30 giây: thử lại với cùng khoá chống hoàn trùng (4a) hoặc ghi log lỗi khi hết lượt (4b) (BR-41, BR-43).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| SD4-L-C | Lifeline | :RefundLatePaymentController | «control» | - | AC-C-RefundLatePaymentController |
| SD4-L-RR | Lifeline | :RefundRequest | «entity» | - | AC-E-RefundRequest |
| SD4-N1 | Note | Điểm rẽ trong SD1: sau message 1.1.5, khi hết 30 giây chờ bắt đầu từ message 1.1.3 mà cổng chưa trả kết quả. | - | - | Chú thích |
| SD4-F1 | Fragment | break [không phản hồi trong 30 giây và đã hết lượt thử lại (4b, BR-41)] | - | - | Bao các message của fragment |
| SD4-F2 | Fragment | opt [không phản hồi trong 30 giây và còn lượt thử lại (4a, BR-41)] | - | - | Bao các message của fragment |
| SD4-N2 | Note | Quay lại bước 4: lặp message 1.1.3 đến 1.1.5.1 của SD1 với cùng yêu cầu hoàn và cùng khoá chống hoàn trùng (BR-43). | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
| --- | --- | --- | --- | --- | --- | --- |
| 1.1.3a | :RefundLatePaymentController | :RefundLatePaymentController | // after(BR-43) handleRefundNoResponse | Tự gọi | - | 4a, 4b |
| 1.1.3a.1 | :RefundLatePaymentController | :RefundRequest | // recordResult (không phản hồi) | Đồng bộ | - | 4a, 4b |
| 1.1.3a.2 | :RefundLatePaymentController | :RefundRequest | // checkRetryRemaining | Đồng bộ | - | 4a, 4b |
| 1.1.3b | :RefundLatePaymentController | :RefundLatePaymentController | // logRefundFailure (mã giao dịch, số tiền hoàn) | Tự gọi | SD4-F1 | 4b |

### SD5 - Luồng 5a và 5b

a) Luồng thể hiện: Cổng trả về kết quả hoàn tiền thất bại: thử lại với cùng khoá chống hoàn trùng (5a) hoặc ghi log lỗi khi hết lượt (5b) (BR-41, BR-43).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| SD5-L-A7 | Actor | :Cổng thanh toán | - | - | Tác nhân (ACT-07), vừa tác nhân chính vừa tác nhân phụ |
| SD5-L-PG | Lifeline | :PaymentGateway | «boundary» | - | AC-B-PaymentGateway |
| SD5-L-C | Lifeline | :RefundLatePaymentController | «control» | - | AC-C-RefundLatePaymentController |
| SD5-L-RR | Lifeline | :RefundRequest | «entity» | - | AC-E-RefundRequest |
| SD5-N1 | Note | Điểm rẽ trong SD1: message 2, khi kết quả hoàn tiền là thất bại. | - | - | Chú thích |
| SD5-F1 | Fragment | break [hoàn tiền thất bại và đã hết lượt thử lại (5b, BR-41)] | - | - | Bao các message của fragment |
| SD5-F2 | Fragment | opt [hoàn tiền thất bại và còn lượt thử lại (5a, BR-41)] | - | - | Bao các message của fragment |
| SD5-N2 | Note | Quay lại bước 4: lặp message 1.1.3 đến 1.1.5.1 của SD1 với cùng yêu cầu hoàn và cùng khoá chống hoàn trùng (BR-43). | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
| --- | --- | --- | --- | --- | --- | --- |
| 2a | :Cổng thanh toán | :PaymentGateway | // reportRefundResult (thất bại, mã giao dịch) | Đồng bộ | - | 5a, 5b |
| 2a.1 | :PaymentGateway | :RefundLatePaymentController | // handleRefundResult (thất bại, mã giao dịch) | Đồng bộ | - | 5a, 5b |
| 2a.1.1 | :RefundLatePaymentController | :RefundLatePaymentController | // stopWaitingForRefundResult | Tự gọi | - | 5a, 5b |
| 2a.1.2 | :RefundLatePaymentController | :RefundRequest | // recordResult (thất bại) | Đồng bộ | - | 5a, 5b |
| 2a.1.3 | :RefundLatePaymentController | :RefundRequest | // checkRetryRemaining | Đồng bộ | - | 5a, 5b |
| 2a.1.4b | :RefundLatePaymentController | :RefundLatePaymentController | // logRefundFailure (mã giao dịch, số tiền hoàn) | Tự gọi | SD5-F1 | 5b |

### SD6 - Biến thể giao dịch thứ hai (BR-40)

a) Luồng thể hiện: Luồng chính khi mã giao dịch khác mã đã lưu và gắn được với lần giữ ghế đã có vé qua mã tham chiếu lần giữ ghế (BR-40, REQ-136).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| SD6-L-PG | Lifeline | :PaymentGateway | «boundary» | - | AC-B-PaymentGateway |
| SD6-L-C | Lifeline | :RefundLatePaymentController | «control» | - | AC-C-RefundLatePaymentController |
| SD6-L-SH | Lifeline | :SeatHold | «entity» | - | AC-E-SeatHold |
| SD6-L-PT | Lifeline | :PaymentTransaction | «entity» | - | AC-E-PaymentTransaction (đỉnh lifeline đặt ngang message Tạo) |
| SD6-N1 | Note | Điểm rẽ trong SD1: message 1.1.1. Chưa có giao dịch thanh toán mang mã này nên không có kiểm tra 1.1.1.1. Bước 4 đến 7 như SD1 từ message 1.1.2, số tiền hoàn lấy từ báo của cổng. | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
| --- | --- | --- | --- | --- | --- | --- |
| 1.1.1[BR-40] | :RefundLatePaymentController | :SeatHold | // settleLateTransactionResult (lần giữ ghế tìm theo mã giao dịch hoặc mã tham chiếu lần giữ ghế, kết quả, số tiền đã thanh toán, thời điểm nhận báo) | Đồng bộ | - | 2, 3 |
| 1.1.1.2[BR-40] | :SeatHold | :SeatHold | // checkLateStatus (thời điểm nhận báo) | Tự gọi | - | 2 |
| 1.1.1.3[BR-40] | :SeatHold | :PaymentTransaction | «create» // createLatePaymentTransaction (mã giao dịch, số tiền đã thanh toán trong báo, lý do hoàn) | Tạo | - | 3 |
| 1.1.1[BR-40] (trả về) | :SeatHold | :RefundLatePaymentController | giao dịch cần hoàn toàn bộ, lý do hoàn | Trả về | - | 3 |

## 6. Quy tắc tương tác giữa các lớp phân tích

| Vi phạm | Message hoặc link | Cách sửa đã áp dụng |
| --- | --- | --- |
| Không có | - | - |

Các điểm đã kiểm: actor chỉ gửi message tới boundary của nó (message 1, 2, 2a); boundary chỉ gửi tới control hoặc actor của nó (1.1, 1.1.5.1, 2.1.5.1); control gọi boundary, entity và chính nó; entity gọi entity khác chỉ khi có quan hệ cấu trúc (SeatHold với PaymentTransaction, Customer, Showtime; PaymentTransaction với RefundRequest); message trả về đi từ entity về control không phải là lời gọi. Tác nhân thời gian không có.

## 7. Communication diagram

File diagrams/P07-communication-UC-006.drawio có 2 trang: CM1 cho luồng chính (SD1), CM2 cho mọi luồng thay thế, ngoại lệ và biến thể (SD2 đến SD6), giữ nguyên STT của sequence diagram (MUC_CHI_TIET là DAY_DU). Message trả về không vẽ. Message nằm trong fragment ghi kèm guard rút gọn trong ngoặc vuông.

### Trang CM1 - Luồng chính (SD1)

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| CM1-O-A7 | Actor | :Cổng thanh toán | - | - | Tác nhân (ACT-07), vừa tác nhân chính vừa tác nhân phụ |
| CM1-O-PG | Object | :PaymentGateway | «boundary» | - | AC-B-PaymentGateway |
| CM1-O-C | Object | :RefundLatePaymentController | «control» | - | AC-C-RefundLatePaymentController |
| CM1-O-SH | Object | :SeatHold | «entity» | - | AC-E-SeatHold |
| CM1-O-PT | Object | :PaymentTransaction | «entity» | - | AC-E-PaymentTransaction |
| CM1-O-RR | Object | :RefundRequest | «entity» | - | AC-E-RefundRequest |
| CM1-O-CU | Object | :Customer | «entity» | - | AC-E-Customer |
| CM1-O-ST | Object | :Showtime | «entity» | - | AC-E-Showtime |
| CM1-O-ES | Object | :EmailService | «boundary» | - | AC-B-EmailService |
| CM1-O-A8 | Actor | :Dịch vụ email | - | - | Tác nhân (ACT-08) |

b) Bảng Edge (link)

| ID | Nguồn | Đích | Loại (Link) | Nhãn (các message theo STT) | Chiều message (Nguồn-->Đích hoặc Đích-->Nguồn) |
| --- | --- | --- | --- | --- | --- |
| CM1-L1 | CM1-O-A7 | CM1-O-PG | Link | 1: // reportTransactionResult (kết quả thành công, mã giao dịch, mã tham chiếu lần giữ ghế, số tiền đã thanh toán) (-->)<br>1.1.5.1: // requestRefund (mã giao dịch, số tiền hoàn, khoá chống hoàn trùng) (<--)<br>2: // reportRefundResult (thành công, mã giao dịch) (-->) | Nguồn-->Đích: 1, 2; Đích-->Nguồn: 1.1.5.1 |
| CM1-L2 | CM1-O-PG | CM1-O-C | Link | 1.1: // handleLateTransactionResult (kết quả, mã giao dịch, mã tham chiếu lần giữ ghế, số tiền đã thanh toán, thời điểm nhận báo) (-->)<br>1.1.5: // requestRefund (mã giao dịch, số tiền hoàn, khoá chống hoàn trùng) (<--)<br>2.1: // handleRefundResult (thành công, mã giao dịch) (-->) | Nguồn-->Đích: 1.1, 2.1; Đích-->Nguồn: 1.1.5 |
| CM1-L3 | CM1-O-C | CM1-O-SH | Link | 1.1.1: // settleLateTransactionResult (lần giữ ghế tìm theo mã giao dịch hoặc mã tham chiếu lần giữ ghế, kết quả, số tiền đã thanh toán, thời điểm nhận báo) (-->)<br>2.1.4: // provideRefundNoticeRecipient (-->) | Nguồn-->Đích: 1.1.1, 2.1.4 |
| CM1-L4 | CM1-O-SH | CM1-O-PT | Link | 1.1.1.1: // checkNotProcessed (mã giao dịch) (-->)<br>1.1.1.3: // markLatePayment (lý do hoàn) (-->) | Nguồn-->Đích: 1.1.1.1, 1.1.1.3 |
| CM1-L5 | CM1-O-SH | CM1-O-SH | Link | 1.1.1.2: // checkLateStatus (thời điểm nhận báo) (-->) | Nguồn-->Đích: 1.1.1.2 |
| CM1-L6 | CM1-O-C | CM1-O-PT | Link | 1.1.2: // createFullRefundRequest (mã giao dịch) (-->)<br>2.1.2: // markRefunded (số tiền hoàn) (-->)<br>2.1.3: // provideRefundSummary (-->) | Nguồn-->Đích: 1.1.2, 2.1.2, 2.1.3 |
| CM1-L7 | CM1-O-PT | CM1-O-PT | Link | 1.1.2.1: // checkRefundWithinPaidAmount (toàn bộ số tiền đã thanh toán) (-->) | Nguồn-->Đích: 1.1.2.1 |
| CM1-L8 | CM1-O-PT | CM1-O-RR | Link | 1.1.2.2: «create» // createRefundRequest (mã giao dịch, loại hoàn toàn bộ, số tiền hoàn) (-->)<br>2.1.2.1: // recordResult (thành công) (-->) | Nguồn-->Đích: 1.1.2.2, 2.1.2.1 |
| CM1-L9 | CM1-O-RR | CM1-O-RR | Link | 1.1.2.2.1: // generateIdempotencyKey (mã giao dịch, loại hoàn toàn bộ) (-->) | Nguồn-->Đích: 1.1.2.2.1 |
| CM1-L10 | CM1-O-C | CM1-O-C | Link | 1.1.3: // startWaitingForRefundResult (BR-43) (-->)<br>2.1.1: // stopWaitingForRefundResult (-->) | Nguồn-->Đích: 1.1.3, 2.1.1 |
| CM1-L11 | CM1-O-C | CM1-O-RR | Link | 1.1.4: // recordAttempt (-->) | Nguồn-->Đích: 1.1.4 |
| CM1-L12 | CM1-O-SH | CM1-O-CU | Link | 2.1.4.1: // provideEmail (-->) | Nguồn-->Đích: 2.1.4.1 |
| CM1-L13 | CM1-O-SH | CM1-O-ST | Link | 2.1.4.2: // provideMovieAndStartTime (-->) | Nguồn-->Đích: 2.1.4.2 |
| CM1-L14 | CM1-O-C | CM1-O-ES | Link | 2.1.5: // sendRefundNotificationEmail (email khách, mã giao dịch, số tiền hoàn, tên phim, suất chiếu, lý do hoàn) (-->) | Nguồn-->Đích: 2.1.5 |
| CM1-L15 | CM1-O-ES | CM1-O-A8 | Link | 2.1.5.1: // sendRefundNotificationEmail (email khách, mã giao dịch, số tiền hoàn, tên phim, suất chiếu, lý do hoàn) (-->) | Nguồn-->Đích: 2.1.5.1 |

### Trang CM2 - Luồng thay thế, ngoại lệ và biến thể (SD2 đến SD6)

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| CM2-O-C | Object | :RefundLatePaymentController | «control» | - | AC-C-RefundLatePaymentController |
| CM2-O-SH | Object | :SeatHold | «entity» | - | AC-E-SeatHold |
| CM2-O-PT | Object | :PaymentTransaction | «entity» | - | AC-E-PaymentTransaction |
| CM2-O-RR | Object | :RefundRequest | «entity» | - | AC-E-RefundRequest |
| CM2-O-A7 | Actor | :Cổng thanh toán | - | - | Tác nhân (ACT-07), vừa tác nhân chính vừa tác nhân phụ |
| CM2-O-PG | Object | :PaymentGateway | «boundary» | - | AC-B-PaymentGateway |

b) Bảng Edge (link)

| ID | Nguồn | Đích | Loại (Link) | Nhãn (các message theo STT) | Chiều message (Nguồn-->Đích hoặc Đích-->Nguồn) |
| --- | --- | --- | --- | --- | --- |
| CM2-L1 | CM2-O-C | CM2-O-C | Link | 1.1e: // logUnrecognizedTransaction (mã giao dịch, kết quả, mã tham chiếu lần giữ ghế, số tiền đã thanh toán, thời điểm nhận báo) (-->) [2e: không nhận ra]<br>1.1d: // logUnrecognizedTransaction (mã giao dịch, kết quả, mã tham chiếu lần giữ ghế, số tiền đã thanh toán, thời điểm nhận báo) (-->) [2d: không nhận ra]<br>1.1.3a: // after(BR-43) handleRefundNoResponse (-->)<br>1.1.3b: // logRefundFailure (mã giao dịch, số tiền hoàn) (-->) [4b: hết lượt]<br>2a.1.1: // stopWaitingForRefundResult (-->)<br>2a.1.4b: // logRefundFailure (mã giao dịch, số tiền hoàn) (-->) [5b: hết lượt] | Nguồn-->Đích: 1.1e, 1.1d, 1.1.3a, 1.1.3b, 2a.1.1, 2a.1.4b |
| CM2-L2 | CM2-O-SH | CM2-O-PT | Link | 1.1.1.1a: // recordDuplicateReport (thời điểm nhận báo) (-->) [2a: báo trùng]<br>1.1.1c.2: // recordLateFailedResult (thất bại, thời điểm nhận báo) (-->) [2c: thất bại muộn]<br>1.1.1d.2: // recordLateFailedResult (thất bại, thời điểm nhận báo) (-->) [2d: thất bại khác]<br>1.1.1.3[BR-40]: «create» // createLatePaymentTransaction (mã giao dịch, số tiền đã thanh toán trong báo, lý do hoàn) (-->) | Nguồn-->Đích: 1.1.1.1a, 1.1.1c.2, 1.1.1d.2, 1.1.1.3[BR-40] |
| CM2-L3 | CM2-O-C | CM2-O-SH | Link | 1.1.1c: // settleLateTransactionResult (lần giữ ghế tìm theo mã giao dịch hoặc mã tham chiếu lần giữ ghế, kết quả, số tiền đã thanh toán, thời điểm nhận báo) (-->) [2c: thất bại muộn]<br>1.1.1d: // settleLateTransactionResult (lần giữ ghế tìm theo mã giao dịch hoặc mã tham chiếu lần giữ ghế, kết quả, số tiền đã thanh toán, thời điểm nhận báo) (-->) [2d: thất bại khác]<br>1.1.1[BR-40]: // settleLateTransactionResult (lần giữ ghế tìm theo mã giao dịch hoặc mã tham chiếu lần giữ ghế, kết quả, số tiền đã thanh toán, thời điểm nhận báo) (-->) | Nguồn-->Đích: 1.1.1c, 1.1.1d, 1.1.1[BR-40] |
| CM2-L4 | CM2-O-SH | CM2-O-SH | Link | 1.1.1c.1: // checkLateStatus (thời điểm nhận báo) (-->) [2c: thất bại muộn]<br>1.1.1d.1: // checkLateStatus (thời điểm nhận báo) (-->) [2d: thất bại khác]<br>1.1.1.2[BR-40]: // checkLateStatus (thời điểm nhận báo) (-->) | Nguồn-->Đích: 1.1.1c.1, 1.1.1d.1, 1.1.1.2[BR-40] |
| CM2-L5 | CM2-O-C | CM2-O-RR | Link | 1.1.3a.1: // recordResult (không phản hồi) (-->)<br>1.1.3a.2: // checkRetryRemaining (-->)<br>2a.1.2: // recordResult (thất bại) (-->)<br>2a.1.3: // checkRetryRemaining (-->) | Nguồn-->Đích: 1.1.3a.1, 1.1.3a.2, 2a.1.2, 2a.1.3 |
| CM2-L6 | CM2-O-A7 | CM2-O-PG | Link | 2a: // reportRefundResult (thất bại, mã giao dịch) (-->) | Nguồn-->Đích: 2a |
| CM2-L7 | CM2-O-PG | CM2-O-C | Link | 2a.1: // handleRefundResult (thất bại, mã giao dịch) (-->) | Nguồn-->Đích: 2a.1 |

## 8. VOPC

File diagrams/P07-class-UC-006.drawio. ID cell của lớp là mã AC; ngăn thuộc tính và ngăn trách nhiệm có ID "<mã AC>-ATTR" và "<mã AC>-RESP".

a) Bảng Node (lớp)

| ID (mã AC) | Loại (Class) | Nhãn (tên lớp) | Stereotype | Thuộc về | Ngăn thuộc tính | Ngăn trách nhiệm |
| --- | --- | --- | --- | --- | --- | --- |
| AC-B-PaymentGateway | Class | PaymentGateway | «boundary» | - | - | // reportTransactionResult<br>// requestRefund<br>// reportRefundResult |
| AC-B-EmailService | Class | EmailService | «boundary» | - | - | // sendRefundNotificationEmail |
| AC-C-RefundLatePaymentController | Class | RefundLatePaymentController | «control» | - | - | // handleLateTransactionResult<br>// logUnrecognizedTransaction<br>// startWaitingForRefundResult<br>// stopWaitingForRefundResult<br>// handleRefundResult<br>// handleRefundNoResponse<br>// logRefundFailure |
| AC-E-SeatHold | Class | SeatHold | «entity» | - | - | // settleLateTransactionResult<br>// checkLateStatus<br>// provideRefundNoticeRecipient |
| AC-E-PaymentTransaction | Class | PaymentTransaction | «entity» | - | lateReason (Văn bản) (mới ở UC này)<br>refundStatus (Trạng thái) (mới ở UC này)<br>refundedAmount (Số tiền) (mới ở UC này)<br>duplicateReportCount (Số lượng) (mới ở UC này) | // checkNotProcessed<br>// markLatePayment<br>// createLatePaymentTransaction<br>// recordDuplicateReport<br>// recordLateFailedResult<br>// createFullRefundRequest<br>// checkRefundWithinPaidAmount<br>// markRefunded<br>// provideRefundSummary |
| AC-E-RefundRequest | Class | RefundRequest | «entity» | - | idempotencyKey (Văn bản)<br>requestType (Văn bản)<br>refundAmount (Số tiền)<br>attemptCount (Số lượng)<br>result (Văn bản) | // createRefundRequest<br>// generateIdempotencyKey<br>// recordAttempt<br>// recordResult<br>// checkRetryRemaining |
| AC-E-Customer | Class | Customer | «entity» | - | - | // provideEmail |
| AC-E-Showtime | Class | Showtime | «entity» | - | movieName (Văn bản) (mới ở UC này) | // provideMovieAndStartTime |

Ngăn thuộc tính của lớp tái dùng chỉ liệt kê thuộc tính mới ở UC này; thuộc tính đã có ở UC-005 xem F8 a) của UC-005.

b) Bảng quan hệ

| ID | Lớp A | Lớp B | Loại | Multiplicity | Vai trò | Nguồn |
| --- | --- | --- | --- | --- | --- | --- |
| R-UC006-01 | AC-B-PaymentGateway | AC-C-RefundLatePaymentController | Association | - | - | tạm thời; link F7: CM1-L2, CM2-L7 |
| R-UC006-02 | AC-B-EmailService | AC-C-RefundLatePaymentController | Association | - | - | tạm thời; link F7: CM1-L14 |
| R-UC006-03 | AC-C-RefundLatePaymentController | AC-E-SeatHold | Association | - | - | tạm thời; link F7: CM1-L3, CM2-L3 |
| R-UC006-04 | AC-C-RefundLatePaymentController | AC-E-PaymentTransaction | Association | - | - | tạm thời; link F7: CM1-L6 |
| R-UC006-05 | AC-C-RefundLatePaymentController | AC-E-RefundRequest | Association | - | - | tạm thời; link F7: CM1-L11, CM2-L5 |
| R-UC006-06 | AC-E-SeatHold | AC-E-PaymentTransaction | Association | A 1 - B 0..* | - | Giao dịch thanh toán gắn với một lần giữ ghế; giao dịch thứ hai cũng gắn qua mã tham chiếu lần giữ ghế (GL-12, GL-13, BR-40); cùng quan hệ R-UC005-16, Q-90; link F7: CM1-L4, CM2-L2 |
| R-UC006-07 | AC-E-PaymentTransaction | AC-E-RefundRequest | Association | A 1 - B 0..* | - | Mỗi yêu cầu hoàn thuộc một giao dịch, một giao dịch có thể có nhiều yêu cầu hoàn khác khoá (BR-43, BR-26); Q-87; link F7: CM1-L8 |
| R-UC006-08 | AC-E-SeatHold | AC-E-Customer | Association | A 0..* - B 0..1 | - | Người giữ ghế là khách (GL-25); cùng quan hệ R-UC005-14, Q-86; link F7: CM1-L12 |
| R-UC006-09 | AC-E-Showtime | AC-E-SeatHold | Association | A 1 - B 0..* | - | Mỗi lần giữ ghế thuộc đúng một suất chiếu (GL-25); cùng quan hệ R-UC005-10; link F7: CM1-L13 |

Link tự nối (message tự gọi) và link actor-boundary không sinh quan hệ VOPC. Quan hệ SeatHold - Customer và Showtime - SeatHold lấy lại từ UC-005 (R-UC005-14, R-UC005-10) cho cùng cặp lớp; SeatHold - PaymentTransaction lấy lại từ R-UC005-16.

## 9. Ma trận truy vết

| Bước UC | Message (STT) | Lớp tham gia (AC) |
| --- | --- | --- |
| 1 | 1, 1.1 | AC-B-PaymentGateway, AC-C-RefundLatePaymentController |
| 2 | 1.1.1, 1.1.1.1, 1.1.1.2, 1.1.1[BR-40], 1.1.1.2[BR-40] | AC-C-RefundLatePaymentController, AC-E-SeatHold, AC-E-PaymentTransaction |
| 3 | 1.1.1, 1.1.1.3, 1.1.1 (trả về), 1.1.1[BR-40], 1.1.1.3[BR-40], 1.1.1[BR-40] (trả về) | AC-C-RefundLatePaymentController, AC-E-SeatHold, AC-E-PaymentTransaction |
| 4 | 1.1.2, 1.1.2.1, 1.1.2.2, 1.1.2.2.1, 1.1.2 (trả về), 1.1.3, 1.1.4, 1.1.5, 1.1.5.1 | AC-C-RefundLatePaymentController, AC-E-PaymentTransaction, AC-E-RefundRequest, AC-B-PaymentGateway |
| 5 | 2, 2.1, 2.1.1 | AC-B-PaymentGateway, AC-C-RefundLatePaymentController |
| 6 | 2.1.2, 2.1.2.1 | AC-C-RefundLatePaymentController, AC-E-PaymentTransaction, AC-E-RefundRequest |
| 7 | 2.1.3, 2.1.3 (trả về), 2.1.4, 2.1.4.1, 2.1.4.2, 2.1.4 (trả về), 2.1.5, 2.1.5.1 | AC-C-RefundLatePaymentController, AC-E-PaymentTransaction, AC-E-SeatHold, AC-E-Customer, AC-E-Showtime, AC-B-EmailService |
| 2a | 1.1.1.1a | AC-E-SeatHold, AC-E-PaymentTransaction |
| 2b | 1.1.1b (trả về) | AC-E-SeatHold, AC-C-RefundLatePaymentController |
| 2c | 1.1.1c, 1.1.1c.1, 1.1.1c.2 | AC-C-RefundLatePaymentController, AC-E-SeatHold, AC-E-PaymentTransaction |
| 2d | 1.1.1d, 1.1.1d.1, 1.1.1d.2, 1.1d | AC-C-RefundLatePaymentController, AC-E-SeatHold, AC-E-PaymentTransaction |
| 2e | 1.1e | AC-C-RefundLatePaymentController |
| 4a | 1.1.3a, 1.1.3a.1, 1.1.3a.2 | AC-C-RefundLatePaymentController, AC-E-RefundRequest |
| 4b | 1.1.3a, 1.1.3a.1, 1.1.3a.2, 1.1.3b | AC-C-RefundLatePaymentController, AC-E-RefundRequest |
| 5a | 2a, 2a.1, 2a.1.1, 2a.1.2, 2a.1.3 | AC-B-PaymentGateway, AC-C-RefundLatePaymentController, AC-E-RefundRequest |
| 5b | 2a, 2a.1, 2a.1.1, 2a.1.2, 2a.1.3, 2a.1.4b | AC-B-PaymentGateway, AC-C-RefundLatePaymentController, AC-E-RefundRequest |

Bước 1 và 5 là bước của tác nhân; message của hai bước này đi từ actor vào AC-B-PaymentGateway (actor không là lớp trong VOPC).

## 10. File .drawio

Ba file nằm trong diagrams/: P07-sequence-UC-006.drawio (6 trang), P07-communication-UC-006.drawio (2 trang), P07-class-UC-006.drawio (1 trang). XML không nén, ID cell trùng ID trong bảng mô hình (ID cell message sequence dạng <ID trang>-M-<STT>; STT có hậu tố [BR-40] thì bỏ dấu ngoặc vuông, dùng gạch dưới). Sequence giữ bản sinh từ bảng; communication đã qua diakempt bỏ bước compact; class đã qua diakempt bỏ bước classlayout.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ |
| --- | --- | --- | --- |
| Q-87 | P05 mục 3 xếp "khoản hoàn, yêu cầu hoàn" vào Số tiền hoàn (GL-45) và Tình trạng hoàn tiền (GL-56), không là thuật ngữ riêng. Nhưng BR-43 đòi khoá chống hoàn trùng gắn với từng yêu cầu hoàn, phân biệt được với yêu cầu hoàn khác trên cùng giao dịch, và có lượt thử lại tính theo yêu cầu. UC-006 mô hình hoá thành entity RefundRequest (idempotencyKey, requestType, refundAmount, attemptCount, result) thuộc một PaymentTransaction. Giữ entity này, hay đưa khoá và số lần thử lại thành thuộc tính của PaymentTransaction (khi đó UC-008, nơi một giao dịch có nhiều lần hoàn theo vé, cần cấu trúc khác)? (Giữ entity RefundRequest, P08 hợp nhất với UC-008 / Thuộc tính của PaymentTransaction) | AC-E-RefundRequest, AC-E-PaymentTransaction; R-UC006-07; // generateIdempotencyKey, // recordAttempt, // checkRetryRemaining; P05; P08 | P05 mục 3 và BR-43 xếp "yêu cầu hoàn" khác nhau: P05 coi là cách gọi, BR-43 coi là đối tượng mang khoá |
| Q-88 | Khi nhận báo thành công, lần giữ ghế còn ở trạng thái Đang giữ nhưng đã quá thời điểm hết hạn (ghế chưa được giải phóng, REQ-76): ai chuyển lần giữ ghế sang Hết hạn và giải phóng ghế? P04 UC-006 Mục 8 nói use case này không đổi trạng thái ghế, còn SD10 của UC-005 chuyển sang Hết hạn rồi mới giao UC-006. UC-006 hiện coi trạng thái hiệu lực là Hết hạn để hoàn tiền (BR-14), không đổi trạng thái lần giữ ghế. (UC-005 chuyển trước khi giao cho UC-006 / UC-006 tự chuyển trong thao tác không chia cắt) | AC-E-SeatHold, // checkLateStatus, // settleLateTransactionResult; bước 2; SD1; Q-83; BR-14, BR-85, BR-86 | P04 Mục 8 đoạn 4 (mốc quyết định là thời điểm nhận báo) và đoạn 10 (không đổi trạng thái ghế); BR-86 chỉ nói trạng thái cuối không đổi |
| Q-89 | Kết quả thất bại cổng báo cho giao dịch hệ thống không nhận ra (luồng 2d, BR-39) được "ghi nhận" ở đâu, khi không có giao dịch thanh toán nào để ghi và log lỗi là hoạt động kỹ thuật? UC-006 hiện chỉ ghi log như luồng 2e. (Chỉ ghi log / Ghi nhận vào một nơi khác do P04 chỉ rõ) | SD3 message 1.1d; // logUnrecognizedTransaction; luồng 2d | P04 luồng 2d dùng cùng động từ "ghi nhận" cho cả giao dịch đã có vé và giao dịch không nhận ra |
| Q-90 | Giao dịch thứ hai (BR-40) chưa có bản ghi trong hệ thống khi cổng báo. Bước 3 "ghi nhận giao dịch là thanh toán trễ" có tạo mới giao dịch thanh toán (mã giao dịch, số tiền trong báo) không? UC-006 hiện tạo mới để báo trùng của giao dịch này nhận ra được ở luồng 2a (BR-37), để tính hạn mức hoàn (BR-26) và để khoá chống hoàn trùng có mã giao dịch. (Tạo mới ở bước 3 / Phương án khác do P04 chỉ rõ) | SD6; AC-E-PaymentTransaction, // createLatePaymentTransaction; R-UC006-06; bước 3; BR-37, BR-40, BR-26 | P04 bước 3 và Tiền điều kiện chỉ nêu giao dịch do hệ thống tạo ở UC-005 bước 10 |

## Giả định

Không có (chế độ NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
| --- | --- | --- | --- |
| P04 | UC-006 bước 7 | BR-89 (dịch vụ email từ chối hoặc không phản hồi lúc gửi email thông báo hoàn tiền) chỉ nằm ở Mục 8, luồng thay thế không có mã luồng tương ứng nên không có message lỗi ở P07 | Thêm luồng 7a (dịch vụ email từ chối hoặc không phản hồi: khoản hoàn giữ nguyên hiệu lực, thử gửi lại, ghi log lỗi, kết thúc) hoặc ghi rõ ở Mục 3 là bước 7 không có luồng thay thế |
| P04 | UC-006 bước 3, luồng 2d | Chưa nói giao dịch thứ hai có được tạo bản ghi ở bước 3 không (Q-90) và kết quả thất bại của giao dịch không nhận ra được ghi nhận ở đâu (Q-89) | Bổ sung sau khi có trả lời Q-89, Q-90 |
| P05 | Mục 3 "Khoản hoàn, yêu cầu hoàn" | Nếu Q-87 chọn giữ entity RefundRequest thì "yêu cầu hoàn" trở thành khái niệm có định danh | Thêm thuật ngữ Yêu cầu hoàn (Refund Request) vào P05 mục 2 và bỏ khỏi mục 3 |
| P03 | Quan hệ UC-005 và UC-006 | P03 không có quan hệ giữa hai use case, trong khi báo thành công đến sau trạng thái cuối do UC-005 hoặc UC-006 xử lý (Q-83) | Chờ trả lời Q-83 rồi quyết định có thêm quan hệ hay không |

## Vấn đề còn mở

- Phụ thuộc Q-83 (UC-005): control tiếp nhận báo đầu tiên chưa chốt. UC-006 vẽ điểm vào là message 1.1 từ PaymentGateway tới RefundLatePaymentController, và trách nhiệm // handleLateTransactionResult của control này. Nếu chọn phương án A của Q-83 (control của UC-005 tiếp nhận rồi chuyển, như SD10 của UC-005) thì message 1.1 do BookTicketsController gửi, cần quan hệ giữa hai use case ở P03 và F6 (control gọi control) cho phép gọi đó; nếu chọn B hoặc C thì PaymentGateway hoặc điểm tiếp nhận riêng gửi tới control tương ứng. Sequence, communication, VOPC của UC-006 phải rà lại sau Q-83.
- Xử lý tuần tự theo lần giữ ghế: toàn bộ kiểm tra và ghi nhận ở bước 2, 3 (message 1.1.1.1 đến 1.1.1.3) nằm trong một trách nhiệm // settleLateTransactionResult của SeatHold, cùng đơn vị khoá với thao tác // completeSaleOnPaymentSuccess của UC-005. Mỗi báo thấy trạng thái do báo trước để lại; lần giữ ghế đã ở trạng thái cuối thì không đổi (UC-006 chỉ ghi vào PaymentTransaction), nên báo đến sau luôn được xử lý theo trạng thái cuối, và chỉ báo đầu tiên của một giao dịch qua được // checkNotProcessed (BR-37). Cơ chế khoá (khoá theo lần giữ ghế, loại trừ với thao tác của UC-005) chọn ở P09.
- Chống hoàn trùng: lớp bảo vệ thứ nhất là xử lý tuần tự ở bước 2, 3 (mỗi giao dịch chỉ có một yêu cầu hoàn toàn bộ); lớp thứ hai là khoá chống hoàn trùng của RefundRequest, sinh một lần ở // generateIdempotencyKey từ mã giao dịch và loại yêu cầu hoàn toàn bộ, mọi lần thử lại dùng lại cùng RefundRequest và cùng khoá. Khoá này khác khoá hoàn 70% của UC-008 (mã giao dịch kèm mã vé) nhờ RefundRequest là đối tượng riêng cho từng yêu cầu hoàn. P08 hợp nhất RefundRequest với khái niệm tương ứng của UC-008 (thêm liên kết tới vé).
- Sequence SD4 và SD5 dùng opt cho luồng quay lại bước 4 thay cho alt của F5: trang hết hạn và trang hoàn tiền thất bại chỉ vẽ phần khác luồng chính, không có toán hạng luồng chính để làm toán hạng thứ hai của alt. Break (hết lượt thử lại) đặt trước, theo thứ tự F5. Message 1.1.1.1 đến 1.1.1.3 và các message check của SeatHold, PaymentTransaction là kiểm tra trong thao tác không chia cắt nên nằm trên cùng trang chính.
- Luồng 2b chỉ có message trả về (1.1.1b) và break rỗng message gọi: P04 ghi Thực hiện bởi "-" vì UC-005 xử lý. Cách control chuyển báo này cho UC-005 phụ thuộc Q-83.
- Customer và Showtime ở UC này chỉ có trách nhiệm cung cấp dữ liệu (// provideEmail, // provideMovieAndStartTime); đặc tả không có hành vi nào khác trên dữ liệu đó, hành vi thuộc UC-001 và UC-014 nên chấp nhận. Showtime thêm thuộc tính movieName (mới ở UC này) vì tên phim chỉ đọc qua Showtime như UC-005; P08 hợp nhất với entity Phim khi có P07 của UC-010 và UC-014.
- Số lần thử lại (BR-41) và khoảng cách giữa hai lần thử là quyết định thiết kế (P09); phân tích chỉ có // checkRetryRemaining. Thời hạn chờ 30 giây tính cho mỗi lần gửi: mỗi lần quay lại bước 4 lặp message 1.1.3 (bắt đầu chờ).
- Thông tin cổng trả về: số tiền đã thanh toán trong báo chỉ dùng cho giao dịch thứ hai (Dữ liệu vào 1 mục 4); với giao dịch hệ thống đã tạo, số tiền lấy từ PaymentTransaction. Việc nhận ra giao dịch (tra theo mã giao dịch rồi mã tham chiếu) coi là có sẵn theo A6 a), control gửi message thẳng tới lần giữ ghế tìm được; khi không tìm được thì control tự ghi log (2e, 2d).
- Mới - chạy song song, chờ P08 hợp nhất: AC-E-RefundRequest (có thể trùng khái niệm với lớp hoàn tiền của UC-008). AC-C-RefundLatePaymentController là control riêng của UC-006. Các lớp tái dùng bổ sung trách nhiệm hoặc thuộc tính: PaymentGateway, EmailService, SeatHold, PaymentTransaction, Customer, Showtime. Trách nhiệm cùng nghĩa dùng lại tên của UC-005 (reportTransactionResult); trách nhiệm khác điều kiện đặt tên khác (markLatePayment so với markProcessed, recordLateFailedResult so với recordFailedResult, createLatePaymentTransaction so với createPaymentTransaction, checkLateStatus so với checkHoldStillActive).
- Số lớp là 8 (2 boundary, 1 control, 5 entity), trong khoảng 4-12. Control có 7 trách nhiệm, 5 trong đó là message tự gọi theo A2 hoặc ghi log (startWaitingForRefundResult, stopWaitingForRefundResult, handleRefundNoResponse, logUnrecognizedTransaction, logRefundFailure); không giữ quy tắc thuộc dữ liệu của entity.
- Sequence giữ bản sinh từ bảng mô hình (không chạy diakempt). Communication và class đã qua diakempt; nhãn link trong communication dài vì mỗi cặp đối tượng một link nên còn một số nhãn chồng nhau.
