# P07 - Phân tích use case UC-008 Huỷ vé - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P07 |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md; P04-uc-specs/UC-008-cancel-ticket.md 1.4; P01-actors.md 1.1; P02-usecases.md 1.8; P03-usecase-model.md 1.0; P05-glossary.md 1.1; P06-supplementary-spec.md 1.1; P04-uc-specs/_BR-register.md; P07-uc-analysis/UC-005-book-tickets-analysis.md 1.0 (sổ đăng ký AC). Chạy song song với P07 của các use case khác: không đọc file P07 khác, mã Q tạm Q-U008-nn |
| Phạm vi | UC-008 |
| Mã Q, ASM cuối đã cấp | Q-94; không có ASM (NGHIEM_NGAT) |

## 1. Bối cảnh use case

| Thuộc tính | Giá trị |
|---|---|
| Mã và tên UC | UC-008 Huỷ vé (Cancel Ticket) |
| Tác nhân chính | ACT-01 Khách (Người); ACT-02 Nhân viên quầy (Người) |
| Tác nhân phụ | ACT-07 Cổng thanh toán (Hệ thống ngoài; nhận yêu cầu hoàn tiền ở bước 5 và báo kết quả ở bước 6; không tham gia luồng 5a) |
| Include (UC) | Không có |
| Được include bởi (UC) | Không có |
| Extend (UC, điểm mở rộng, điều kiện) | Không có |
| Được extend bởi (UC, điểm mở rộng, điều kiện) | Không có |
| Use case liên quan không qua include, extend | UC-005 Đặt vé tạo vé, lần đặt, lần giữ ghế, giao dịch thanh toán mà UC-008 huỷ và hoàn tiền, và dùng lại sơ đồ ghế khi ghế trống (BR-45); UC-009 Soát vé loại trừ với bước 4 trên cùng một vé (BR-30); UC-006 Hoàn tiền thanh toán trễ dùng chung khoá chống hoàn trùng và BR-26 với UC-008; UC-015, UC-016 đọc tình trạng hoàn tiền để trừ doanh thu (BR-77). Q-91 phụ thuộc Q-83 của UC-005 |
| Tác nhân thời gian | Không có. Thời hạn chờ 30 giây của yêu cầu hoàn tiền (BR-43) là thời hạn nội bộ do control nhận biết (A2). UC-008 không tạo, đổi hay làm mất hiệu lực mốc nào của use case do tác nhân thời gian kích hoạt (P04 Mục 8; EV-06 chỉ gắn với giữ ghế của UC-005) nên không có message hẹn, hẹn lại, huỷ mốc |
| File P07 đã có được dùng làm sổ đăng ký AC | P07-uc-analysis/UC-005-book-tickets-analysis.md (F1, F3.4, F8 b), Câu hỏi mở, Vấn đề còn mở). Tái dùng mã AC-B-PaymentGateway, AC-B-BookTicketsForm, AC-E-Ticket, AC-E-Booking, AC-E-SeatHold, AC-E-Showtime, AC-E-PaymentTransaction, AC-E-SeatStatus |

## 2. Đặc tả bổ sung

| Bước UC | Thực hiện bởi | Mô tả trong đặc tả | Mô tả bổ sung (hệ thống làm gì bên trong) | Nguồn (BR, GL, REQ) |
|---|---|---|---|---|
| 1 | Khách | Chọn vé cần huỷ trong các vé mua trực tuyến của mình và yêu cầu huỷ vé. | Không đổi | REQ-40, GL-64 |
| 1a1 | Nhân viên quầy | Nhập mã đặt vé của lần đặt chứa vé cần huỷ. | Không đổi | REQ-120, GL-28 |
| 1a1a | Hệ thống | Thông báo mã đặt vé không tồn tại; quay lại bước 1a1. | Control tìm lần đặt theo mã đặt vé; không có lần đặt nào trùng mã thì control báo boundary thông báo mã không tồn tại và cho nhập lại. | Dữ liệu vào 1, REQ-106 |
| 1a2 | Hệ thống | Hiển thị các vé của lần đặt. | Lần đặt lấy từ từng vé của mình vị trí ghế, giá vé và trạng thái vé (chưa sử dụng, đã huỷ, đã sử dụng); control chuyển cho boundary hiển thị. | GL-24, GL-59, GL-60, GL-61, GL-65 |
| 1a3 | Nhân viên quầy | Chọn vé cần huỷ và yêu cầu huỷ vé; tiếp tục bước 2. | Không đổi | REQ-83 |
| 2 | Hệ thống | Kiểm tra tác nhân được huỷ vé theo kênh mua vé. | Lần đặt chứa vé hỏi lần giữ ghế của mình xem người giữ ghế có phải tác nhân huỷ vé và kênh mua là trực tuyến hay tại quầy. Với nhân viên quầy và vé mua tại quầy, suất chiếu của vé còn đối chiếu cụm rạp của mình với cụm rạp của nhân viên quầy. | BR-17, GL-63, GL-64 |
| 2a | Hệ thống | Khách huỷ vé không phải vé mua trực tuyến của mình: từ chối huỷ vé. | Kết quả kiểm tra kênh ở bước 2 không khớp thì control báo boundary thông báo từ chối kèm quy tắc BR-17; vé và ghế không đổi. | BR-17 |
| 2b | Hệ thống | Nhân viên quầy huỷ vé mua trực tuyến: từ chối huỷ vé. | Như 2a, tác nhân là nhân viên quầy và kênh mua là trực tuyến. | BR-17 |
| 2c | Hệ thống | Nhân viên quầy huỷ vé quầy của cụm rạp khác: từ chối huỷ vé. | Suất chiếu của vé không thuộc cụm rạp của nhân viên quầy thì control báo boundary thông báo từ chối kèm quy tắc BR-17. | BR-17, BR-02 |
| 3 | Hệ thống | Kiểm tra thời điểm hệ thống thực hiện bước kiểm tra cách giờ bắt đầu suất chiếu ít nhất 2 tiếng. | Suất chiếu của vé so thời điểm kiểm tra (lấy lúc thực hiện bước này) với giờ bắt đầu của chính nó trừ 2 tiếng; suất chiếu đã bắt đầu hoặc đã kết thúc cũng không đạt. | BR-18, BR-32, GL-14, GL-16 |
| 3a | Hệ thống | Chưa tới 2 tiếng: từ chối huỷ vé và thông báo hạn huỷ vé. | Kết quả không đạt ở bước 3 thì control báo boundary thông báo hạn huỷ vé; vé và ghế không đổi. | BR-18 |
| 4 | Hệ thống | Kiểm tra vé chưa huỷ và chưa sử dụng, rồi ghi nhận vé đã huỷ, thành một thao tác không chia cắt. | Vé tự kiểm tra trạng thái của mình: chưa huỷ trước, chưa sử dụng sau; đạt cả hai thì chuyển sang đã huỷ ngay trong cùng thao tác, nên hai yêu cầu huỷ cùng một vé hoặc một yêu cầu huỷ và một lần soát cùng lúc chỉ có một bên thành công, bên sau nhận kết quả vé đã huỷ hoặc đã sử dụng. | BR-21, BR-30, GL-60, GL-61 |
| 4a | Hệ thống | Vé đã huỷ: thông báo vé đã huỷ và không hoàn tiền thêm. | Vé trả kết quả đã huỷ (kiểm trước 4b) thì control báo boundary thông báo; không có khoản hoàn nào được tạo. | BR-21 |
| 4b | Hệ thống | Vé chưa huỷ và đã sử dụng: từ chối huỷ vé và thông báo vé đã sử dụng không huỷ được. | Vé trả kết quả đã sử dụng thì control báo boundary thông báo từ chối; vé giữ nguyên. | BR-30 |
| 5 | Hệ thống | Yêu cầu cổng thanh toán hoàn 70% giá vé, làm tròn xuống đồng, kèm mã giao dịch và mã vé làm khoá chống hoàn trùng. | Vé tính số tiền hoàn từ giá vé của mình (70%, làm tròn xuống đồng). Giao dịch thanh toán của lần giữ ghế (qua lần đặt) kiểm tra tổng đã hoàn cộng số tiền hoàn không vượt số đã thanh toán và lập khoá từ mã giao dịch và mã vé; control gửi yêu cầu hoàn qua boundary cổng và bắt đầu chờ 30 giây. | BR-19, BR-20, BR-26, BR-31, BR-43, GL-20, GL-45 |
| 5a1 | Hệ thống | Hiển thị số tiền mặt cần hoàn cho khách mua tại quầy. | Vé tính số tiền hoàn như bước 5; control chuyển cho boundary quầy hiển thị số tiền mặt cần hoàn. | BR-19, BR-20, BR-31 |
| 5a2 | Nhân viên quầy | Hoàn tiền mặt cho khách mua tại quầy và xác nhận đã hoàn; tiếp tục bước 7. | Không đổi | BR-20, REQ-85 |
| 5b | Hệ thống | Cổng không phản hồi trong 30 giây và còn lượt thử lại: quay lại bước 5. | Hết 30 giây chờ thì control kiểm tra còn lượt thử lại; còn thì chờ lại và gửi lại yêu cầu hoàn với cùng khoá chống hoàn trùng. | BR-41, BR-43 |
| 5c | Hệ thống | Cổng không phản hồi trong 30 giây và hết lượt thử lại: ghi log lỗi khoản hoàn, tiếp tục bước 7. | Control ghi log lỗi khoản hoàn (mã vé, mã giao dịch, số tiền hoàn) để xử lý thủ công ngoài hệ thống, không gửi email cho khách. | BR-41, REQ-131 |
| 6 | Cổng thanh toán | Báo hoàn tiền thành công. | Không đổi | REQ-79 |
| 6a | Hệ thống | Cổng báo hoàn tiền thất bại và còn lượt thử lại: quay lại bước 5. | Control ngừng chờ, kiểm tra còn lượt thử lại; còn thì chờ lại và gửi lại yêu cầu hoàn với cùng khoá. | BR-41, BR-43 |
| 6b | Hệ thống | Cổng báo hoàn tiền thất bại và hết lượt thử lại: ghi log lỗi khoản hoàn, tiếp tục bước 7. | Như 5c. | BR-41, REQ-131 |
| 7 | Hệ thống | Ghi nhận khoản hoàn của vé kèm tình trạng hoàn tiền và trả ghế của vé về trạng thái trống. | Giao dịch thanh toán cộng số tiền hoàn vào tổng đã hoàn khi hoàn qua cổng thành công; vé ghi số tiền hoàn và tình trạng hoàn tiền (đã hoàn, hoặc chưa hoàn được và đã ghi log lỗi). Vé yêu cầu trạng thái ghế của mình chuyển từ đã bán về trống, kể cả khi hoàn tiền không thành công; control báo các màn hình đang xem sơ đồ ghế cập nhật. | BR-42, BR-26, GL-56, REQ-119 |
| 8 | Hệ thống | Thông báo huỷ vé thành công, hiển thị số tiền hoàn và tình trạng hoàn tiền. | Vé cung cấp nội dung vé đã huỷ (mã đặt vé, vị trí ghế, giá vé, số tiền hoàn, tình trạng hoàn tiền); control chuyển cho boundary hiển thị kèm hình thức hoàn tiền theo kênh mua. | Dữ liệu ra 1, BR-20, GL-56 |

## 3. Tìm lớp phân tích

### 3.1 Bảng boundary

| Tác nhân (ACT) | Loại tác nhân | Boundary | Loại boundary | Mới hoặc tái dùng (AC, UC nguồn) | Lý do |
|---|---|---|---|---|---|
| ACT-01 Khách | Người | CancelTicketForm | Giao diện người dùng | Mới - chạy song song, chờ P08 hợp nhất (AC-B-CancelTicketForm) | Khách chọn vé mua trực tuyến cần huỷ và nhận kết quả huỷ vé. |
| ACT-02 Nhân viên quầy | Người | CounterCancelTicketForm | Giao diện người dùng | Mới - chạy song song, chờ P08 hợp nhất (AC-B-CounterCancelTicketForm) | Nhân viên quầy dùng chung luồng với khách (P02 U-R10 b) nhưng khác ở nhiều bước: nhập mã đặt vé, xem các vé của lần đặt, hoàn tiền mặt. Một boundary cho mỗi cặp tác nhân và use case. |
| ACT-07 Cổng thanh toán | Hệ thống ngoài | PaymentGateway | Giao diện hệ thống | Tái dùng từ UC-005 (AC-B-PaymentGateway), bổ sung trách nhiệm | Cùng hệ thống ngoài; thêm yêu cầu hoàn tiền và nhận kết quả hoàn tiền (GL-02). Tên không trùng entity (entity là PaymentTransaction). |

Số boundary giao tiếp trực tiếp với tác nhân là 3, bằng số tác nhân tham gia (không có tác nhân thời gian). Khách khác đang xem sơ đồ ghế nhận cập nhật qua AC-B-BookTicketsForm của UC-005 (tái dùng, không tạo boundary mới): đây không là boundary của tác nhân tham gia UC-008 mà là điểm nhận message cập nhật sơ đồ ghế (REQ-119), nên tổng số lớp boundary trong VOPC là 4. Máy in và dịch vụ email không tham gia UC-008 (P04 Mục 8).

### 3.2 Bảng lọc danh từ

| STT | Danh từ hoặc cụm danh từ | Vị trí (bước UC, mục dữ liệu, BR) | Kết luận | Lý do |
|---|---|---|---|---|
| 1 | vé | 1, 4, 5, 7, 8; Dữ liệu vào 2; BR-21, BR-30 | Entity AC-E-Ticket | Hệ thống lưu; có trạng thái (chưa sử dụng, đã huỷ, đã sử dụng), giá vé, số tiền hoàn, tình trạng hoàn tiền; tự kiểm tra và ghi nhận huỷ không chia cắt, trả ghế về trống (GL-59, GL-60, GL-61, GL-65). |
| 2 | khách | 1, 2, 2a | Loại - là tác nhân hoặc ngoài phạm vi | ACT-01; boundary CancelTicketForm. Khách khác đang xem sơ đồ ghế cũng thuộc ACT-01, dùng boundary BookTicketsForm của UC-005. |
| 3 | nhân viên quầy | 1a, 2, 2b, 2c, 5a | Loại - là tác nhân hoặc ngoài phạm vi | ACT-02; boundary CounterCancelTicketForm. |
| 4 | tác nhân | 2, 2a, 2b, 2c | Loại - trùng hoặc đồng nghĩa với khách, nhân viên quầy | Cách nói chung của ACT-01 và ACT-02. |
| 5 | kênh mua vé, vé mua trực tuyến, vé mua tại quầy | 2, 5; BR-17, BR-20 | Loại - giá trị suy ra từ Booking | Kênh suy ra từ người giữ ghế của lần giữ ghế (khách: trực tuyến; nhân viên quầy: tại quầy), do Booking hỏi SeatHold khi cần (GL-63, GL-64). |
| 6 | cụm rạp | 2, 2c; BR-17 | Loại - khái niệm do UC-011 tạo, use case này chỉ đọc qua entity Showtime | Chỉ cần để so cụm rạp của suất chiếu với cụm rạp của nhân viên quầy (thuộc tính cinema của Showtime, Q-81 của UC-005). |
| 7 | suất chiếu | 3, 3a; BR-18 | Entity AC-E-Showtime | Có hành vi kiểm tra hạn huỷ từ giờ bắt đầu của chính nó (GL-47). |
| 8 | giờ bắt đầu | 3, 3a; BR-18, BR-32 | Loại - thuộc tính của Showtime | Thành phần của suất chiếu (GL-14). |
| 9 | hạn huỷ vé, 2 tiếng | 3, 3a; BR-18 | Loại - tham số của quy tắc BR-18 | Hằng số 2 tiếng tính lùi từ giờ bắt đầu (GL-16). |
| 10 | thời điểm hệ thống kiểm tra, thời điểm huỷ | 3; BR-32 | Loại - thao tác hoặc sự kiện | Thời điểm sự kiện, truyền như tham số khi kiểm tra. |
| 11 | thao tác không chia cắt | 4 | Loại - cấu trúc cài đặt | Cơ chế bảo đảm thuộc thiết kế (P09); ở mức phân tích là trách nhiệm cancelTicket của Ticket. |
| 12 | trạng thái vé (chưa sử dụng, đã huỷ, đã sử dụng) | 4, 4a, 4b; Dữ liệu ra 2 | Loại - thuộc tính của Ticket | Giá trị của status (GL-60, GL-61, GL-65). |
| 13 | yêu cầu huỷ khác, việc soát | 4a, 4b | Loại - thao tác hoặc sự kiện | Sự kiện đồng thời; việc soát thuộc UC-009 và loại trừ với việc huỷ trên cùng vé (BR-30). |
| 14 | cổng thanh toán | 5, 6 | Loại - là tác nhân hoặc ngoài phạm vi | ACT-07; boundary PaymentGateway (GL-02). |
| 15 | 70% giá vé, số tiền hoàn | 5, 5a1; BR-19, BR-31 | Loại - thuộc tính của Ticket | refundAmount, tính từ price của vé (GL-45); làm tròn xuống đồng theo BR-31. |
| 16 | giá vé | 5, 8; Dữ liệu ra 1, 2; BR-11 | Loại - thuộc tính của Ticket | price, giá đã ghi trên vé khi bán (GL-10, BR-67). |
| 17 | làm tròn xuống đồng | 5; BR-31 | Loại - tham số của quy tắc BR-31 | Quy tắc làm tròn của số tiền hoàn. |
| 18 | giao dịch thanh toán | 5; BR-26, BR-43 | Entity AC-E-PaymentTransaction | Hệ thống lưu số tiền đã thanh toán; có hành vi kiểm tra tổng đã hoàn không vượt số đã thanh toán và lập khoá chống hoàn trùng (GL-12). |
| 19 | mã giao dịch | 5; BR-43 | Loại - thuộc tính của PaymentTransaction | transactionCode (GL-29). |
| 20 | số tiền đã thanh toán, tổng đã hoàn | 5; BR-26 | Loại - thuộc tính của PaymentTransaction | amount và refundedTotal (GL-44). |
| 21 | mã vé | 5; BR-43 | Loại - thuộc tính của Ticket | ticketCode (GL-32). |
| 22 | khoá chống hoàn trùng, yêu cầu hoàn | 5, 5b, 6a; BR-43 | Loại - dữ liệu trao đổi qua boundary PaymentGateway | Khoá lập từ mã giao dịch và mã vé khi cần, gắn với từng yêu cầu hoàn, không lưu riêng (GL-20); yêu cầu hoàn là thao tác. |
| 23 | khoản hoàn | 7; GL-45, GL-56 | Loại - thuộc tính của Ticket | Số tiền hoàn và tình trạng hoàn tiền gắn với vé (refundAmount, refundStatus); Q-93. |
| 24 | tình trạng hoàn tiền | 7, 8; BR-41 | Loại - thuộc tính của Ticket | refundStatus: đã hoàn, hoặc chưa hoàn được và đã ghi log lỗi (GL-56). |
| 25 | hình thức hoàn tiền, tiền mặt | 5a1, 8; Dữ liệu ra 1; BR-20 | Loại - giá trị suy ra từ Booking | Suy ra từ kênh mua vé: qua cổng thanh toán với vé trực tuyến, tiền mặt với vé quầy; không lưu. |
| 26 | lượt thử lại, vài lần | 5b, 6a; BR-41 | Loại - tham số của quy tắc BR-41 | Số lần là quyết định thiết kế (P09); control chỉ xác định còn lượt hay không. |
| 27 | 30 giây, không phản hồi | 5b, 5c; BR-43 | Loại - tham số của quy tắc BR-43 | Thời hạn chờ nội bộ của control, không là tác nhân (A2). |
| 28 | log lỗi, xử lý thủ công ngoài hệ thống | 5c, 6b; BR-41 | Loại - cấu trúc cài đặt | Cơ chế ghi log thuộc thiết kế; xử lý thủ công nằm ngoài phạm vi, không có use case (REQ-131). |
| 29 | email | Mục 8; BR-41 | Loại - không tham gia hành vi của use case này (khái niệm của UC-006) | UC-008 không gửi email (ACT-08 không tham gia); chỉ được nhắc để xác định ranh giới. |
| 30 | ghế, ghế đôi, vị trí ghế | 7; Dữ liệu ra 1; REQ-87 | Loại - khái niệm do UC-012 tạo, use case này chỉ đọc hoặc đổi trạng thái qua entity SeatStatus | Vị trí ghế là thuộc tính seatPosition; ghế đôi là một ghế (GL-07, GL-26). |
| 31 | trạng thái ghế (trống, đã bán) | 7; BR-42 | Entity AC-E-SeatStatus | Có vòng đời riêng; chuyển từ đã bán về trống (GL-58). |
| 32 | sơ đồ ghế, người đang xem | 7; Mục 7 | Loại - giá trị suy ra từ Showtime | Tập trạng thái ghế của suất chiếu (GL-46); màn hình khác đang xem được cập nhật qua boundary BookTicketsForm của UC-005. |
| 33 | mã đặt vé | 1a1, 8; Dữ liệu vào 1 | Loại - thuộc tính của Booking | bookingCode (GL-28). |
| 34 | lần đặt, các vé của lần đặt | 1a1, 1a2 | Entity AC-E-Booking | Hệ thống lưu; tìm theo mã đặt vé, nắm các vé, kiểm tra kênh mua qua lần giữ ghế (GL-24). |
| 35 | người giữ ghế, lần giữ ghế | 2; BR-17 | Entity AC-E-SeatHold | Nắm người giữ ghế (khách hoặc nhân viên quầy) và giao dịch thanh toán của lần giữ ghế (GL-25). |
| 36 | tên phim, tên cụm rạp, phòng chiếu, ngày giờ bắt đầu | Dữ liệu ra 1; REQ-105 | Loại - dữ liệu trao đổi qua boundary CancelTicketForm | Thông tin hiển thị trên vé đã huỷ, do trách nhiệm provideTicketContent cung cấp; không thêm entity (Q-81 của UC-005). |
| 37 | doanh thu | Mục 8; BR-77 | Loại - không tham gia hành vi của use case này (khái niệm của UC-015, UC-016) | UC-008 chỉ ghi tình trạng hoàn tiền; việc trừ doanh thu thuộc UC-015, UC-016. |
| 38 | phiên làm việc, đăng nhập | Tiền điều kiện | Loại - cấu trúc cài đặt | Đăng nhập không là use case (hồ sơ dự án Mục 4); tác nhân của phiên do control xác định. |
| 39 | thông báo, thông tin, quy tắc, hệ thống | Nhiều bước | Loại - mơ hồ | Không phải khái niệm nghiệp vụ cụ thể; nội dung thông báo là dữ liệu trao đổi qua boundary. |

### 3.3 Bảng control

| Control | Use case điều phối | Mới hoặc tái dùng | Lý do (hoặc lý do không có control) |
|---|---|---|---|
| CancelTicketController | UC-008 | Mới - chạy song song, chờ P08 hợp nhất (AC-C-CancelTicketController) | Một control cho use case: điều phối trình tự bước 2 đến 8, nhận kết quả hoàn tiền, nhận sự kiện hết 30 giây (after BR-43), đếm lượt thử lại, ghi log lỗi khoản hoàn, báo các màn hình khác cập nhật sơ đồ ghế. Mọi quy tắc nghiệp vụ nằm ở entity. Có 8 trách nhiệm, trong đó 3 là message tự gọi theo A2 (startWaitingForRefundResponse, stopWaitingForRefundResponse, handleRefundNoResponse). |

### 3.4 Bảng lớp phân tích

| AC | Stereotype | Tên | Trách nhiệm | Thuộc tính chính | Bước UC nguồn | Loại boundary | Mới hoặc tái dùng | GL |
|---|---|---|---|---|---|---|---|---|
| AC-B-CancelTicketForm | boundary | CancelTicketForm | // selectTicketToCancel: khách chọn vé mua trực tuyến cần huỷ và yêu cầu huỷ vé<br>// notifyRefusal: thông báo từ chối hoặc kết thúc thất bại kèm lý do<br>// showCancellationResult: thông báo huỷ vé thành công, hiển thị vé đã huỷ, giá vé, số tiền hoàn, hình thức và tình trạng hoàn tiền | - | 1, 2a, 3a, 4a, 4b, 8 | Giao diện người dùng | Mới - chạy song song, chờ P08 hợp nhất | GL-18 |
| AC-B-CounterCancelTicketForm | boundary | CounterCancelTicketForm | // enterBookingCode: nhân viên quầy nhập mã đặt vé của lần đặt chứa vé cần huỷ<br>// showBookingTickets: hiển thị các vé của lần đặt: vị trí ghế, giá vé, trạng thái vé<br>// selectTicketToCancel: nhân viên quầy chọn vé cần huỷ và yêu cầu huỷ vé<br>// notifyRefusal: thông báo từ chối kèm lý do, kể cả mã đặt vé không tồn tại<br>// showCashRefund: hiển thị số tiền mặt cần hoàn cho khách mua tại quầy<br>// confirmCashRefunded: nhân viên quầy xác nhận đã hoàn tiền mặt<br>// showCancellationResult: thông báo huỷ vé thành công, hiển thị vé đã huỷ, giá vé, số tiền hoàn, hình thức và tình trạng hoàn tiền | - | 1a1, 1a1a, 1a2, 1a3, 2b, 2c, 3a, 4a, 4b, 5a1, 5a2, 8 | Giao diện người dùng | Mới - chạy song song, chờ P08 hợp nhất | GL-35 |
| AC-B-PaymentGateway | boundary | PaymentGateway | // requestRefund: chuyển yêu cầu hoàn tiền (mã giao dịch, số tiền hoàn, khoá chống hoàn trùng) tới cổng thanh toán và nhận kết quả hoàn tiền | - | 5, 5b, 6, 6a | Giao diện hệ thống | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-02 |
| AC-B-BookTicketsForm | boundary | BookTicketsForm | // updateSeatMap: cập nhật sơ đồ ghế đang hiển thị khi trạng thái ghế của suất chiếu đổi | - | 7 | Giao diện người dùng | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-46 |
| AC-C-CancelTicketController | control | CancelTicketController | // requestCancellation: điều phối bước 2 đến 8 cho vé mua trực tuyến: kiểm tra, ghi nhận huỷ, hoàn tiền qua cổng, trả ghế, báo kết quả<br>// findBookingTickets: điều phối bước 1a1, 1a1a, 1a2: tìm lần đặt theo mã đặt vé và lấy các vé để hiển thị<br>// confirmCashRefund: điều phối bước 5a2, 7, 8 khi nhân viên quầy xác nhận đã hoàn tiền mặt<br>// startWaitingForRefundResponse: bắt đầu chờ phản hồi hoàn tiền của cổng thanh toán (BR-43)<br>// stopWaitingForRefundResponse: ngừng chờ khi cổng thanh toán đã trả kết quả hoàn tiền<br>// handleRefundNoResponse: nhận sự kiện hết 30 giây không có phản hồi hoàn tiền (BR-43)<br>// checkRefundRetriesLeft: xác định còn lượt thử lại yêu cầu hoàn tiền trong lần huỷ vé này (BR-41)<br>// logRefundFailure: ghi log lỗi khoản hoàn để xử lý thủ công ngoài hệ thống, không gửi email cho khách (BR-41) | - | 1 đến 8, 1a1 đến 1a3, 2a đến 2c, 3a, 4a, 4b, 5a1, 5a2, 5b, 5c, 6a, 6b | - | Mới - chạy song song, chờ P08 hợp nhất | - |
| AC-E-Ticket | entity | Ticket | // cancelTicket: thao tác không chia cắt: kiểm tra vé chưa huỷ và chưa sử dụng rồi ghi nhận vé đã huỷ (BR-21, BR-30)<br>// checkNotCancelledNotUsed: kiểm tra vé chưa huỷ (trước) rồi chưa sử dụng (BR-21, BR-30)<br>// markCancelled: chuyển trạng thái vé sang đã huỷ<br>// calculateRefundAmount: tính số tiền hoàn bằng 70% giá vé, làm tròn xuống đồng (BR-19, BR-31)<br>// recordRefund: ghi nhận số tiền hoàn và tình trạng hoàn tiền (đã hoàn, hoặc chưa hoàn được và đã ghi log lỗi) cho vé<br>// releaseTicketSeat: trả ghế của vé về trống sau khi vé đã huỷ (BR-42)<br>// provideTicketContent: cung cấp nội dung vé để hiển thị | refundAmount (Số tiền) (mới ở UC này), refundStatus (Trạng thái) (mới ở UC này); ticketCode, seatPosition, seatType, price, status đã có ở UC-005 | 1a2, 4, 4a, 4b, 5, 5a1, 7, 8 | - | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-59, GL-60, GL-61, GL-65, GL-45, GL-56 |
| AC-E-Booking | entity | Booking | // checkCancellationChannel: kiểm tra kênh mua vé của lần đặt khớp tác nhân huỷ vé (BR-17)<br>// providePaymentTransaction: cung cấp giao dịch thanh toán của lần đặt để hoàn tiền<br>// provideBookingInfo: cung cấp mã đặt vé và nội dung các vé của lần đặt (trách nhiệm đã có ở UC-005, cùng ý nghĩa) | bookingCode đã có ở UC-005 | 1a2, 2, 2a, 2b, 5 | - | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-24, GL-28, GL-63, GL-64 |
| AC-E-SeatHold | entity | SeatHold | // checkHeldBy: kiểm tra người giữ ghế của lần giữ ghế là tác nhân huỷ vé và cho biết kênh mua (BR-17)<br>// providePaymentTransaction: cung cấp giao dịch thanh toán đã xử lý thành công của lần giữ ghế | holdRef, status, holdTime, expiryTime đã có ở UC-005 | 2, 2a, 2b, 5 | - | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-25 |
| AC-E-Showtime | entity | Showtime | // checkCancellationDeadline: kiểm tra thời điểm kiểm tra cách giờ bắt đầu ít nhất 2 tiếng (BR-18, BR-32)<br>// checkBelongsToCinema: kiểm tra suất chiếu thuộc cụm rạp của nhân viên quầy (BR-17), trách nhiệm đã có ở UC-005, cùng ý nghĩa | startTime, cinema đã có ở UC-005 | 2c, 3, 3a | - | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-47, GL-14, GL-16 |
| AC-E-PaymentTransaction | entity | PaymentTransaction | // prepareRefundRequest: kiểm tra tổng đã hoàn cộng số tiền hoàn không vượt số tiền đã thanh toán (BR-26) và lập khoá chống hoàn trùng từ mã giao dịch và mã vé (BR-43)<br>// recordRefundedAmount: cộng số tiền hoàn vào tổng đã hoàn của giao dịch (BR-26) | refundedTotal (Số tiền) (mới ở UC này); transactionCode, amount đã có ở UC-005 | 5, 7 | - | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-12, GL-20, GL-29, GL-44 |
| AC-E-SeatStatus | entity | SeatStatus | // releaseSoldSeat: chuyển ghế đã bán về trống để chọn, giữ, mua như mọi ghế trống (BR-42) | seatPosition, seatType, status, heldPrice đã có ở UC-005 | 7 | - | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-58 |

Tổng cộng 11 lớp: 4 boundary, 1 control, 6 entity. Trách nhiệm releaseSoldSeat khác releaseSeat của UC-005 ở điều kiện (ghế đã bán chứ không phải đang giữ) nên đặt tên khác. Entity cốt lõi của chủ đề race condition, giữ ghế và giải phóng ghế: AC-E-Ticket (thao tác huỷ không chia cắt, một vé hoàn một lần) và AC-E-SeatStatus (trả ghế về trống).

## 4. Phân bổ hành vi

| Bước UC | Trách nhiệm | Lớp nhận (AC) | Nguyên tắc | Lý do khi có lựa chọn khác |
|---|---|---|---|---|
| 1 | // selectTicketToCancel | AC-B-CancelTicketForm | Giao tiếp tác nhân | - |
| 1 | // requestCancellation | AC-C-CancelTicketController | Controller | - |
| 1a1 | // enterBookingCode | AC-B-CounterCancelTicketForm | Giao tiếp tác nhân | - |
| 1a1, 1a1a, 1a2 | // findBookingTickets | AC-C-CancelTicketController | Controller | Tìm lần đặt theo mã đặt vé coi là có sẵn (A6 a); control gửi message thẳng tới lần đặt tìm được. |
| 1a1a | // notifyRefusal | AC-B-CounterCancelTicketForm | Giao tiếp tác nhân | - |
| 1a2 | // provideBookingInfo, provideTicketContent | AC-E-Booking, AC-E-Ticket | Information Expert | Lần đặt nắm các vé của mình qua quan hệ cấu trúc nên lặp qua từng vé để liệt kê (A6); vị trí ghế, giá, trạng thái là dữ liệu của vé. |
| 1a2 | // showBookingTickets | AC-B-CounterCancelTicketForm | Giao tiếp tác nhân | - |
| 1a3 | // selectTicketToCancel, // requestCancellation | AC-B-CounterCancelTicketForm, AC-C-CancelTicketController | Giao tiếp tác nhân, Controller | - |
| 2 | // checkCancellationChannel | AC-E-Booking | Information Expert | Kênh mua vé nằm ở người giữ ghế của lần giữ ghế (SeatHold), vé không giữ dữ liệu này. Giao Booking (đã có quan hệ cấu trúc với SeatHold và Ticket) và Booking hỏi SeatHold; giao control sẽ làm control giữ quy tắc BR-17. |
| 2 | // checkHeldBy | AC-E-SeatHold | Information Expert | Người giữ ghế là dữ liệu của lần giữ ghế (BR-04, GL-25). |
| 2, 2c | // checkBelongsToCinema | AC-E-Showtime | Information Expert | Dữ liệu ở hai lớp: cụm rạp của suất chiếu (Showtime) và cụm rạp của nhân viên quầy. Giao Showtime, nhận cụm rạp của nhân viên quầy làm tham số, như UC-005. |
| 2a, 2b, 2c, 3a, 4a, 4b | // notifyRefusal | AC-B-CancelTicketForm, AC-B-CounterCancelTicketForm | Giao tiếp tác nhân | Khách dùng CancelTicketForm, nhân viên quầy dùng CounterCancelTicketForm. |
| 3 | // checkCancellationDeadline | AC-E-Showtime | Information Expert | Giờ bắt đầu là dữ liệu của suất chiếu; giao control sẽ làm control giữ quy tắc thuộc dữ liệu của entity. |
| 4 | // cancelTicket, checkNotCancelledNotUsed, markCancelled | AC-E-Ticket | Information Expert | Trạng thái vé là dữ liệu của vé. Kiểm tra vé chưa huỷ, chưa sử dụng và ghi nhận đã huỷ nằm cùng một trách nhiệm của Ticket để yêu cầu tới sau gặp vé đã huỷ (một vé hoàn một lần, BR-21) và loại trừ với việc soát (BR-30). Tách kiểm tra ở control và ghi ở Ticket sẽ cho hai yêu cầu cùng thấy vé chưa huỷ. |
| 5 | // calculateRefundAmount | AC-E-Ticket | Information Expert | Giá vé là dữ liệu của vé; giao control sẽ làm control giữ quy tắc tính (BR-19, BR-31). |
| 5 | // providePaymentTransaction | AC-E-Booking, AC-E-SeatHold | Information Expert | Giao dịch thanh toán gắn với lần giữ ghế (GL-12); lần đặt đi tới lần giữ ghế qua quan hệ cấu trúc; Q-92. |
| 5 | // prepareRefundRequest | AC-E-PaymentTransaction | Information Expert | Số tiền đã thanh toán, tổng đã hoàn và mã giao dịch là dữ liệu của giao dịch; mã vé nhận làm tham số. |
| 5, 5b, 6a | // startWaitingForRefundResponse, // handleRefundNoResponse | AC-C-CancelTicketController | Controller | Thời hạn nội bộ (BR-43) không là tác nhân (A2). |
| 5, 5b, 6a | // requestRefund | AC-B-PaymentGateway | Giao tiếp tác nhân | - |
| 5b, 6a | // checkRefundRetriesLeft | AC-C-CancelTicketController | Controller | Số lần thử lại là quyết định thiết kế (P09); control chỉ biết còn lượt hay không trong lần huỷ vé này. |
| 5c, 6b | // logRefundFailure | AC-C-CancelTicketController | Controller | Ghi log không phải dữ liệu nghiệp vụ của entity nào (log lỗi là cấu trúc cài đặt). |
| 5a1 | // calculateRefundAmount, // showCashRefund | AC-E-Ticket, AC-B-CounterCancelTicketForm | Information Expert, Giao tiếp tác nhân | - |
| 5a2 | // confirmCashRefunded, // confirmCashRefund | AC-B-CounterCancelTicketForm, AC-C-CancelTicketController | Giao tiếp tác nhân, Controller | - |
| 6 | // requestRefund (kết quả trả về) | AC-B-PaymentGateway | Giao tiếp tác nhân | Kết quả hoàn tiền đi theo lời gọi, Q-91. |
| 6 | // stopWaitingForRefundResponse | AC-C-CancelTicketController | Controller | - |
| 7 | // recordRefundedAmount | AC-E-PaymentTransaction | Information Expert | Tổng đã hoàn là dữ liệu của giao dịch (BR-26). |
| 7 | // recordRefund | AC-E-Ticket | Information Expert | Khoản hoàn gắn với vé: số tiền hoàn và tình trạng hoàn tiền (GL-45, GL-56); Q-93. |
| 7 | // releaseTicketSeat, // releaseSoldSeat | AC-E-Ticket, AC-E-SeatStatus | Information Expert | Vé biết ghế của mình (GL-59) nên vé yêu cầu trạng thái ghế chuyển về trống; giao control sẽ buộc control biết ghế nào thuộc vé. |
| 7 | // updateSeatMap | AC-B-BookTicketsForm | Giao tiếp tác nhân | Control báo các màn hình đang xem sơ đồ ghế của suất chiếu (REQ-119); người xem tại quầy dùng CounterBookTicketsForm với cùng message. |
| 8 | // provideTicketContent | AC-E-Ticket | Information Expert | - |
| 8 | // showCancellationResult | AC-B-CancelTicketForm, AC-B-CounterCancelTicketForm | Giao tiếp tác nhân | - |

## 5. Sequence diagram phân tích

File diagrams/P07-sequence-UC-008.drawio có 7 trang, mỗi trang một sơ đồ. ID cell của lifeline là "<ID trang>-L-<khoá>", ID cell của message là "<ID trang>-M-<STT>" (các ký tự [ ] ( ) * trong STT đổi thành _, message trả về thêm hậu tố -R). Luồng thay thế rẽ tại message có STT 1.1.1 dùng STT 1.1.1a, 1.1.1b theo chữ của mã luồng; biến thể ACT-02 dùng hậu tố [ACT-02] cho message tương ứng với luồng chính và STT riêng (1a, 1a.1, 1.1.1c) cho message chỉ có ở biến thể. Lifeline w:BookTicketsForm là boundary của khách khác đang xem cùng sơ đồ ghế. Luồng 5b, 5c vẽ như luồng thời hạn: message tự gọi after(BR-43) rồi xử lý hết hạn; thời hạn này chỉ trùm bước 5 và 6 nên không dùng trang "*a" (A2). Bước 4 (cancelTicket) là một message duy nhất tới Ticket, hai message tự gọi 1.1.3.1 và 1.1.3.2 nằm trong cùng thao tác không chia cắt.

### SD1 - Luồng chính, bước 1 đến 8

a) Luồng thể hiện: Khách huỷ một vé mua trực tuyến: kiểm tra kênh, hạn huỷ, ghi nhận huỷ không chia cắt, hoàn 70% qua cổng thanh toán thành công, trả ghế về trống, thông báo kết quả.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1-L-K | Actor | :Khách | - | - | Tác nhân (ACT-01) |
| SD1-L-BF | Lifeline | :CancelTicketForm | «boundary» | - | AC-B-CancelTicketForm |
| SD1-L-WF | Lifeline | w:BookTicketsForm | «boundary» | - | Boundary của khách khác đang xem sơ đồ ghế của suất chiếu (AC-B-BookTicketsForm, UC-005) |
| SD1-L-C | Lifeline | :CancelTicketController | «control» | - | AC-C-CancelTicketController |
| SD1-L-TK | Lifeline | :Ticket | «entity» | - | AC-E-Ticket |
| SD1-L-BK | Lifeline | :Booking | «entity» | - | AC-E-Booking |
| SD1-L-SH | Lifeline | :SeatHold | «entity» | - | AC-E-SeatHold |
| SD1-L-ST | Lifeline | :Showtime | «entity» | - | AC-E-Showtime |
| SD1-L-PT | Lifeline | :PaymentTransaction | «entity» | - | AC-E-PaymentTransaction |
| SD1-L-SS | Lifeline | :SeatStatus | «entity» | - | AC-E-SeatStatus |
| SD1-L-PG | Lifeline | :PaymentGateway | «boundary» | - | AC-B-PaymentGateway |
| SD1-L-A7 | Actor | :Cổng thanh toán | - | - | Tác nhân (ACT-07) |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1 | :Khách | :CancelTicketForm | // selectTicketToCancel (vé cần huỷ) | Đồng bộ | - | 1 |
| 1.1 | :CancelTicketForm | :CancelTicketController | // requestCancellation (vé cần huỷ) | Đồng bộ | - | 1 |
| 1.1.1 | :CancelTicketController | :Booking | // checkCancellationChannel (vé cần huỷ, khách của phiên) | Đồng bộ | - | 2 |
| 1.1.1.1 | :Booking | :SeatHold | // checkHeldBy (khách của phiên) | Đồng bộ | - | 2 |
| 1.1.1.1 (trả về) | :SeatHold | :Booking | người giữ ghế là khách của phiên | Trả về | - | 2 |
| 1.1.1 (trả về) | :Booking | :CancelTicketController | kênh mua vé khớp tác nhân | Trả về | - | 2 |
| 1.1.2 | :CancelTicketController | :Showtime | // checkCancellationDeadline (thời điểm kiểm tra, BR-18, BR-32) | Đồng bộ | - | 3 |
| 1.1.3 | :CancelTicketController | :Ticket | // cancelTicket | Đồng bộ | - | 4 |
| 1.1.3.1 | :Ticket | :Ticket | // checkNotCancelledNotUsed (BR-21, BR-30) | Tự gọi | - | 4 |
| 1.1.3.2 | :Ticket | :Ticket | // markCancelled | Tự gọi | - | 4 |
| 1.1.3 (trả về) | :Ticket | :CancelTicketController | vé đã ghi nhận huỷ | Trả về | - | 4 |
| 1.1.4 | :CancelTicketController | :Ticket | // calculateRefundAmount (BR-19, BR-31) | Đồng bộ | - | 5 |
| 1.1.4 (trả về) | :Ticket | :CancelTicketController | số tiền hoàn | Trả về | - | 5 |
| 1.1.5 | :CancelTicketController | :Booking | // providePaymentTransaction | Đồng bộ | - | 5 |
| 1.1.5.1 | :Booking | :SeatHold | // providePaymentTransaction | Đồng bộ | - | 5 |
| 1.1.5.1 (trả về) | :SeatHold | :Booking | giao dịch thanh toán của lần giữ ghế | Trả về | - | 5 |
| 1.1.5 (trả về) | :Booking | :CancelTicketController | giao dịch thanh toán của vé | Trả về | - | 5 |
| 1.1.6 | :CancelTicketController | :PaymentTransaction | // prepareRefundRequest (số tiền hoàn, mã vé, BR-26, BR-43) | Đồng bộ | - | 5 |
| 1.1.6 (trả về) | :PaymentTransaction | :CancelTicketController | mã giao dịch, khoá chống hoàn trùng | Trả về | - | 5 |
| 1.1.7 | :CancelTicketController | :CancelTicketController | // startWaitingForRefundResponse (BR-43) | Tự gọi | - | 5 |
| 1.1.8 | :CancelTicketController | :PaymentGateway | // requestRefund (mã giao dịch, số tiền hoàn, khoá chống hoàn trùng) | Đồng bộ | - | 5 |
| 1.1.8.1 | :PaymentGateway | :Cổng thanh toán | // requestRefund (mã giao dịch, số tiền hoàn, khoá chống hoàn trùng) | Đồng bộ | - | 5 |
| 1.1.8.1 (trả về) | :Cổng thanh toán | :PaymentGateway | báo hoàn tiền thành công | Trả về | - | 6 |
| 1.1.8 (trả về) | :PaymentGateway | :CancelTicketController | kết quả hoàn tiền: thành công | Trả về | - | 6 |
| 1.1.9 | :CancelTicketController | :CancelTicketController | // stopWaitingForRefundResponse | Tự gọi | - | 6 |
| 1.1.10 | :CancelTicketController | :PaymentTransaction | // recordRefundedAmount (số tiền hoàn) | Đồng bộ | - | 7 |
| 1.1.11 | :CancelTicketController | :Ticket | // recordRefund (số tiền hoàn, tình trạng hoàn tiền: đã hoàn) | Đồng bộ | - | 7 |
| 1.1.12 | :CancelTicketController | :Ticket | // releaseTicketSeat | Đồng bộ | - | 7 |
| 1.1.12.1 | :Ticket | :SeatStatus | // releaseSoldSeat | Đồng bộ | - | 7 |
| 1.1.13 | :CancelTicketController | w:BookTicketsForm | // updateSeatMap (ghế đã trống) | Đồng bộ | - | 7 |
| 1.1.14 | :CancelTicketController | :Ticket | // provideTicketContent | Đồng bộ | - | 8 |
| 1.1.14 (trả về) | :Ticket | :CancelTicketController | vé đã huỷ: vị trí ghế, giá vé, số tiền hoàn, tình trạng hoàn tiền | Trả về | - | 8 |
| 1.1.15 | :CancelTicketController | :CancelTicketForm | // showCancellationResult (vé đã huỷ, giá vé, số tiền hoàn, hình thức hoàn tiền, tình trạng hoàn tiền) | Đồng bộ | - | 8 |

### SD2 - Luồng 2a và 3a

a) Luồng thể hiện: Từ chối huỷ vé khi khách huỷ vé không phải vé mua trực tuyến của mình (2a) hoặc khi thời điểm kiểm tra cách giờ bắt đầu chưa tới 2 tiếng (3a); tác nhân Khách.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD2-L-BF | Lifeline | :CancelTicketForm | «boundary» | - | AC-B-CancelTicketForm |
| SD2-L-C | Lifeline | :CancelTicketController | «control» | - | AC-C-CancelTicketController |
| SD2-N1 | Note | Điểm rẽ: 2a sau message 1.1.1; 3a sau message 1.1.2 của SD1. Khi tác nhân là nhân viên quầy, notifyRefusal gửi tới :CounterCancelTicketForm | - | - | Chú thích |
| SD2-F1 | Fragment | break [khách huỷ vé không phải vé mua trực tuyến của mình (BR-17)] | - | - | Bao các message của fragment |
| SD2-F2 | Fragment | break [thời điểm kiểm tra cách giờ bắt đầu chưa tới 2 tiếng, kể cả suất chiếu đã bắt đầu hoặc đã kết thúc (BR-18, BR-32)] | - | - | Bao các message của fragment |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1.1.1a.1 | :CancelTicketController | :CancelTicketForm | // notifyRefusal (vé không phải vé mua trực tuyến của khách, BR-17) | Đồng bộ | SD2-F1 | 2a |
| 1.1.2a.1 | :CancelTicketController | :CancelTicketForm | // notifyRefusal (quá hạn huỷ vé, BR-18) | Đồng bộ | SD2-F2 | 3a |

### SD3 - Luồng 4a và 4b

a) Luồng thể hiện: Từ chối huỷ vé khi vé đã huỷ (4a, kiểm trước) hoặc vé chưa huỷ và đã sử dụng (4b); vé và ghế không đổi.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD3-L-BF | Lifeline | :CancelTicketForm | «boundary» | - | AC-B-CancelTicketForm |
| SD3-L-C | Lifeline | :CancelTicketController | «control» | - | AC-C-CancelTicketController |
| SD3-N1 | Note | Điểm rẽ: sau message 1.1.3 (trả về) của SD1. Khi tác nhân là nhân viên quầy, notifyRefusal gửi tới :CounterCancelTicketForm | - | - | Chú thích |
| SD3-F1 | Fragment | break [vé đã huỷ, kể cả vừa bị huỷ bởi yêu cầu huỷ khác xử lý ngay trước đó (BR-21)] | - | - | Bao các message của fragment |
| SD3-F2 | Fragment | break [vé chưa huỷ và đã sử dụng, kể cả vừa được soát ngay trước đó (BR-30)] | - | - | Bao các message của fragment |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1.1.3a.1 | :CancelTicketController | :CancelTicketForm | // notifyRefusal (vé đã huỷ, không hoàn tiền thêm, BR-21) | Đồng bộ | SD3-F1 | 4a |
| 1.1.3b.1 | :CancelTicketController | :CancelTicketForm | // notifyRefusal (vé đã sử dụng không huỷ được, BR-30) | Đồng bộ | SD3-F2 | 4b |

### SD4 - Luồng 5b và 5c

a) Luồng thể hiện: Cổng thanh toán không phản hồi yêu cầu hoàn tiền trong 30 giây: thử lại khi còn lượt (5b) hoặc ghi log lỗi khoản hoàn rồi tiếp tục bước 7 khi hết lượt (5c).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD4-L-C | Lifeline | :CancelTicketController | «control» | - | AC-C-CancelTicketController |
| SD4-L-PG | Lifeline | :PaymentGateway | «boundary» | - | AC-B-PaymentGateway |
| SD4-L-A7 | Actor | :Cổng thanh toán | - | - | Tác nhân (ACT-07) |
| SD4-N1 | Note | Điểm rẽ: sau message 1.1.7 của SD1, khi hết 30 giây chờ mà chưa có phản hồi | - | - | Chú thích |
| SD4-F1 | Fragment | alt [còn lượt thử lại (BR-41)] | - | - | Bao các message của fragment |
| SD4-N2 | Note | quay lại bước 5 | - | - | Chú thích |
| SD4-F1-O2 | Fragment | [đã hết lượt thử lại (BR-41)] | - | SD4-F1 | Toán hạng thứ hai; đường ngăn là edge SD4-F1-O2-SEP nét đứt |
| SD4-N3 | Note | tiếp tục bước 7: không có 1.1.10; 1.1.11 ghi tình trạng hoàn tiền chưa hoàn được và đã ghi log lỗi; từ 1.1.12 như SD1 (BR-42) | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1.1.7b.1 | :CancelTicketController | :CancelTicketController | // after(BR-43) handleRefundNoResponse | Tự gọi | - | 5b |
| 1.1.7b.2 | :CancelTicketController | :CancelTicketController | // checkRefundRetriesLeft (BR-41) | Tự gọi | - | 5b |
| 1.1.7b.3 | :CancelTicketController | :CancelTicketController | // startWaitingForRefundResponse (BR-43) | Tự gọi | SD4-F1 | 5b |
| 1.1.7b.4 | :CancelTicketController | :PaymentGateway | // requestRefund (mã giao dịch, số tiền hoàn, cùng khoá chống hoàn trùng, BR-43) | Đồng bộ | SD4-F1 | 5b |
| 1.1.7b.4.1 | :PaymentGateway | :Cổng thanh toán | // requestRefund (mã giao dịch, số tiền hoàn, cùng khoá chống hoàn trùng, BR-43) | Đồng bộ | SD4-F1 | 5b |
| 1.1.7c.1 | :CancelTicketController | :CancelTicketController | // logRefundFailure (mã vé, mã giao dịch, số tiền hoàn, BR-41) | Tự gọi | SD4-F1 | 5c |

### SD5 - Luồng 6a và 6b

a) Luồng thể hiện: Cổng thanh toán báo hoàn tiền thất bại: thử lại khi còn lượt (6a) hoặc ghi log lỗi khoản hoàn rồi tiếp tục bước 7 khi hết lượt (6b).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD5-L-C | Lifeline | :CancelTicketController | «control» | - | AC-C-CancelTicketController |
| SD5-L-PG | Lifeline | :PaymentGateway | «boundary» | - | AC-B-PaymentGateway |
| SD5-L-A7 | Actor | :Cổng thanh toán | - | - | Tác nhân (ACT-07) |
| SD5-N1 | Note | Điểm rẽ: tại message 1.1.8 (trả về) của SD1 khi kết quả hoàn tiền là thất bại | - | - | Chú thích |
| SD5-F1 | Fragment | alt [còn lượt thử lại (BR-41)] | - | - | Bao các message của fragment |
| SD5-N2 | Note | quay lại bước 5 | - | - | Chú thích |
| SD5-F1-O2 | Fragment | [đã hết lượt thử lại (BR-41)] | - | SD5-F1 | Toán hạng thứ hai; đường ngăn là edge SD5-F1-O2-SEP nét đứt |
| SD5-N3 | Note | tiếp tục bước 7: không có 1.1.10; 1.1.11 ghi tình trạng hoàn tiền chưa hoàn được và đã ghi log lỗi; từ 1.1.12 như SD1 (BR-42) | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1.1.8a.1 | :CancelTicketController | :CancelTicketController | // stopWaitingForRefundResponse | Tự gọi | - | 6a |
| 1.1.8a.2 | :CancelTicketController | :CancelTicketController | // checkRefundRetriesLeft (BR-41) | Tự gọi | - | 6a |
| 1.1.8a.3 | :CancelTicketController | :CancelTicketController | // startWaitingForRefundResponse (BR-43) | Tự gọi | SD5-F1 | 6a |
| 1.1.8a.4 | :CancelTicketController | :PaymentGateway | // requestRefund (mã giao dịch, số tiền hoàn, cùng khoá chống hoàn trùng, BR-43) | Đồng bộ | SD5-F1 | 6a |
| 1.1.8a.4.1 | :PaymentGateway | :Cổng thanh toán | // requestRefund (mã giao dịch, số tiền hoàn, cùng khoá chống hoàn trùng, BR-43) | Đồng bộ | SD5-F1 | 6a |
| 1.1.8b.1 | :CancelTicketController | :CancelTicketController | // logRefundFailure (mã vé, mã giao dịch, số tiền hoàn, BR-41) | Tự gọi | SD5-F1 | 6b |

### SD6 - Luồng 5a

a) Luồng thể hiện: Biến thể ACT-02, vé mua tại quầy: hiển thị số tiền mặt cần hoàn, nhân viên quầy hoàn tiền mặt và xác nhận, tiếp tục bước 7 và 8; không có giao dịch hoàn tiền qua cổng thanh toán.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD6-L-NV | Actor | :Nhân viên quầy | - | - | Tác nhân (ACT-02) |
| SD6-L-CF | Lifeline | :CounterCancelTicketForm | «boundary» | - | AC-B-CounterCancelTicketForm |
| SD6-L-WF | Lifeline | w:BookTicketsForm | «boundary» | - | Boundary của khách khác đang xem sơ đồ ghế của suất chiếu (AC-B-BookTicketsForm, UC-005) |
| SD6-L-C | Lifeline | :CancelTicketController | «control» | - | AC-C-CancelTicketController |
| SD6-L-TK | Lifeline | :Ticket | «entity» | - | AC-E-Ticket |
| SD6-L-SS | Lifeline | :SeatStatus | «entity» | - | AC-E-SeatStatus |
| SD6-N1 | Note | Điểm rẽ: tại bước 5, thay cho 1.1.4 đến 1.1.9 của SD1 khi tác nhân là nhân viên quầy (vé mua tại quầy, BR-20) | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1.1.4a.1 | :CancelTicketController | :Ticket | // calculateRefundAmount (BR-19, BR-31) | Đồng bộ | - | 5a1 |
| 1.1.4a.1 (trả về) | :Ticket | :CancelTicketController | số tiền hoàn | Trả về | - | 5a1 |
| 1.1.4a.2 | :CancelTicketController | :CounterCancelTicketForm | // showCashRefund (số tiền mặt cần hoàn, hình thức hoàn tiền: tiền mặt) | Đồng bộ | - | 5a1 |
| 2(5a) | :Nhân viên quầy | :CounterCancelTicketForm | // confirmCashRefunded | Đồng bộ | - | 5a2 |
| 2(5a).1 | :CounterCancelTicketForm | :CancelTicketController | // confirmCashRefund | Đồng bộ | - | 5a2 |
| 2(5a).1.1 | :CancelTicketController | :Ticket | // recordRefund (số tiền hoàn, tình trạng hoàn tiền: đã hoàn) | Đồng bộ | - | 7 |
| 2(5a).1.2 | :CancelTicketController | :Ticket | // releaseTicketSeat | Đồng bộ | - | 7 |
| 2(5a).1.2.1 | :Ticket | :SeatStatus | // releaseSoldSeat | Đồng bộ | - | 7 |
| 2(5a).1.3 | :CancelTicketController | w:BookTicketsForm | // updateSeatMap (ghế đã trống) | Đồng bộ | - | 7 |
| 2(5a).1.4 | :CancelTicketController | :Ticket | // provideTicketContent | Đồng bộ | - | 8 |
| 2(5a).1.4 (trả về) | :Ticket | :CancelTicketController | vé đã huỷ: vị trí ghế, giá vé, số tiền hoàn, tình trạng hoàn tiền | Trả về | - | 8 |
| 2(5a).1.5 | :CancelTicketController | :CounterCancelTicketForm | // showCancellationResult (vé đã huỷ, giá vé, số tiền hoàn, hình thức hoàn tiền, tình trạng hoàn tiền) | Đồng bộ | - | 8 |

### SD7 - Biến thể ACT-02, luồng 1a, 2b và 2c

a) Luồng thể hiện: Nhân viên quầy nhập mã đặt vé, xem các vé của lần đặt, chọn vé cần huỷ (1a); kiểm tra kênh mua vé và cụm rạp, từ chối khi vé mua trực tuyến (2b) hoặc vé quầy của cụm rạp khác (2c).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD7-L-NV | Actor | :Nhân viên quầy | - | - | Tác nhân (ACT-02) |
| SD7-L-CF | Lifeline | :CounterCancelTicketForm | «boundary» | - | AC-B-CounterCancelTicketForm |
| SD7-L-C | Lifeline | :CancelTicketController | «control» | - | AC-C-CancelTicketController |
| SD7-L-BK | Lifeline | :Booking | «entity» | - | AC-E-Booking |
| SD7-L-SH | Lifeline | :SeatHold | «entity» | - | AC-E-SeatHold |
| SD7-L-ST | Lifeline | :Showtime | «entity» | - | AC-E-Showtime |
| SD7-L-TK | Lifeline | :Ticket | «entity» | - | AC-E-Ticket |
| SD7-F1 | Fragment | alt [mã đặt vé không trùng mã của lần đặt nào (1a1a)] | - | - | Bao các message của fragment |
| SD7-N1 | Note | quay lại bước 1a1 | - | - | Chú thích |
| SD7-F1-O2 | Fragment | [mã đặt vé trùng mã của một lần đặt] | - | SD7-F1 | Toán hạng thứ hai; đường ngăn là edge SD7-F1-O2-SEP nét đứt |
| SD7-F2 | Fragment | loop [mỗi vé của lần đặt] | - | SD7-F1 | Bao các message của fragment |
| SD7-F3 | Fragment | break [tác nhân là nhân viên quầy và vé là vé mua trực tuyến (BR-17)] | - | - | Bao các message của fragment |
| SD7-F4 | Fragment | break [vé mua tại quầy của cụm rạp khác cụm rạp của nhân viên quầy (BR-17)] | - | - | Bao các message của fragment |
| SD7-N2 | Note | tiếp tục bước 3 như SD1 với :CounterCancelTicketForm thay :CancelTicketForm; vé mua tại quầy hoàn tiền mặt theo SD6 | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1a | :Nhân viên quầy | :CounterCancelTicketForm | // enterBookingCode (mã đặt vé) | Đồng bộ | - | 1a1 |
| 1a.1 | :CounterCancelTicketForm | :CancelTicketController | // findBookingTickets (mã đặt vé) | Đồng bộ | - | 1a1 |
| 1a.1.1 | :CancelTicketController | :CounterCancelTicketForm | // notifyRefusal (mã đặt vé không tồn tại) | Đồng bộ | SD7-F1 | 1a1a |
| 1a.1.2 | :CancelTicketController | :Booking | // provideBookingInfo | Đồng bộ | SD7-F1 | 1a2 |
| 1a.1.2.1 | :Booking | :Ticket | // provideTicketContent | Đồng bộ | SD7-F2 | 1a2 |
| 1a.1.2 (trả về) | :Booking | :CancelTicketController | mã đặt vé và nội dung các vé: vị trí ghế, giá vé, trạng thái vé | Trả về | SD7-F1 | 1a2 |
| 1a.1.3 | :CancelTicketController | :CounterCancelTicketForm | // showBookingTickets (các vé của lần đặt: vị trí ghế, giá vé, trạng thái vé) | Đồng bộ | SD7-F1 | 1a2 |
| 1a.2 | :Nhân viên quầy | :CounterCancelTicketForm | // selectTicketToCancel (vé cần huỷ) | Đồng bộ | - | 1a3 |
| 1.1[ACT-02] | :CounterCancelTicketForm | :CancelTicketController | // requestCancellation (vé cần huỷ) | Đồng bộ | - | 1a3 |
| 1.1.1[ACT-02] | :CancelTicketController | :Booking | // checkCancellationChannel (vé cần huỷ, nhân viên quầy của phiên) | Đồng bộ | - | 2 |
| 1.1.1.1[ACT-02] | :Booking | :SeatHold | // checkHeldBy (nhân viên quầy của phiên) | Đồng bộ | - | 2 |
| 1.1.1.1[ACT-02] (trả về) | :SeatHold | :Booking | kênh của lần giữ ghế: tại quầy hoặc trực tuyến | Trả về | - | 2 |
| 1.1.1[ACT-02] (trả về) | :Booking | :CancelTicketController | kênh mua vé khớp tác nhân hoặc không | Trả về | - | 2 |
| 1.1.1b.1 | :CancelTicketController | :CounterCancelTicketForm | // notifyRefusal (vé mua trực tuyến, BR-17) | Đồng bộ | SD7-F3 | 2b |
| 1.1.1c | :CancelTicketController | :Showtime | // checkBelongsToCinema (cụm rạp của nhân viên quầy) | Đồng bộ | - | 2c |
| 1.1.1c (trả về) | :Showtime | :CancelTicketController | suất chiếu thuộc cụm rạp của nhân viên quầy hoặc không | Trả về | - | 2c |
| 1.1.1c.1 | :CancelTicketController | :CounterCancelTicketForm | // notifyRefusal (vé quầy của cụm rạp khác, BR-17) | Đồng bộ | SD7-F4 | 2c |

## 6. Quy tắc tương tác giữa các lớp phân tích

| Vi phạm | Message hoặc link | Cách sửa đã áp dụng |
|---|---|---|
| Không có | - | - |

Không có vi phạm. Đã kiểm trên mọi message: actor chỉ gửi tới boundary của mình (K, NV tới CancelTicketForm, CounterCancelTicketForm); actor ACT-07 chỉ trao đổi với PaymentGateway; boundary chỉ gọi control và actor của nó; control gọi boundary, entity và chính nó; entity gọi entity chỉ khi có quan hệ cấu trúc (Booking với SeatHold và Ticket, Ticket với SeatStatus) hoặc tự gọi chính mình (Ticket).

## 7. Communication diagram

File diagrams/P07-communication-UC-008.drawio có 3 trang: CM1 cho luồng chính (SD1), CM2 cho luồng thay thế của Khách (SD2 đến SD5), CM3 cho biến thể ACT-02 (SD6, SD7), giữ nguyên STT của sequence diagram (MUC_CHI_TIET là DAY_DU). Message trả về không vẽ. Message ghi kèm guard trong ngoặc vuông khi nằm trong fragment alt, break hoặc loop. ID cell của đối tượng là "<ID trang>-O-<khoá>", ID cell của link là ID trong bảng Edge.

### Trang CM1 - Luồng chính (SD1)

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| CM1-O-K | Actor | :Khách | - | - | (ACT-01) |
| CM1-O-BF | Object | :CancelTicketForm | «boundary» | - | AC-B-CancelTicketForm |
| CM1-O-WF | Object | w:BookTicketsForm | «boundary» | - | AC-B-BookTicketsForm |
| CM1-O-C | Object | :CancelTicketController | «control» | - | AC-C-CancelTicketController |
| CM1-O-TK | Object | :Ticket | «entity» | - | AC-E-Ticket |
| CM1-O-BK | Object | :Booking | «entity» | - | AC-E-Booking |
| CM1-O-SH | Object | :SeatHold | «entity» | - | AC-E-SeatHold |
| CM1-O-ST | Object | :Showtime | «entity» | - | AC-E-Showtime |
| CM1-O-PT | Object | :PaymentTransaction | «entity» | - | AC-E-PaymentTransaction |
| CM1-O-SS | Object | :SeatStatus | «entity» | - | AC-E-SeatStatus |
| CM1-O-PG | Object | :PaymentGateway | «boundary» | - | AC-B-PaymentGateway |
| CM1-O-A7 | Actor | :Cổng thanh toán | - | - | (ACT-07) |

b) Bảng Edge

| ID | Nguồn | Đích | Loại | Nhãn | Chiều message |
|---|---|---|---|---|---|
| CM1-L1 | CM1-O-K | CM1-O-BF | Link | 1: // selectTicketToCancel (vé cần huỷ) (-->) | Nguồn-->Đích: 1 |
| CM1-L2 | CM1-O-BF | CM1-O-C | Link | 1.1: // requestCancellation (vé cần huỷ) (-->)<br>1.1.15: // showCancellationResult (vé đã huỷ, giá vé, số tiền hoàn, hình thức hoàn tiền, tình trạng hoàn tiền) (<--) | Nguồn-->Đích: 1.1; Đích-->Nguồn: 1.1.15 |
| CM1-L3 | CM1-O-C | CM1-O-BK | Link | 1.1.1: // checkCancellationChannel (vé cần huỷ, khách của phiên) (-->)<br>1.1.5: // providePaymentTransaction (-->) | Nguồn-->Đích: 1.1.1, 1.1.5 |
| CM1-L4 | CM1-O-BK | CM1-O-SH | Link | 1.1.1.1: // checkHeldBy (khách của phiên) (-->)<br>1.1.5.1: // providePaymentTransaction (-->) | Nguồn-->Đích: 1.1.1.1, 1.1.5.1 |
| CM1-L5 | CM1-O-C | CM1-O-ST | Link | 1.1.2: // checkCancellationDeadline (thời điểm kiểm tra, BR-18, BR-32) (-->) | Nguồn-->Đích: 1.1.2 |
| CM1-L6 | CM1-O-C | CM1-O-TK | Link | 1.1.3: // cancelTicket (-->)<br>1.1.4: // calculateRefundAmount (BR-19, BR-31) (-->)<br>1.1.11: // recordRefund (số tiền hoàn, tình trạng hoàn tiền: đã hoàn) (-->)<br>1.1.12: // releaseTicketSeat (-->)<br>1.1.14: // provideTicketContent (-->) | Nguồn-->Đích: 1.1.3, 1.1.4, 1.1.11, 1.1.12, 1.1.14 |
| CM1-L7 | CM1-O-TK | CM1-O-TK | Link | 1.1.3.1: // checkNotCancelledNotUsed (BR-21, BR-30) (-->)<br>1.1.3.2: // markCancelled (-->) | Nguồn-->Đích: 1.1.3.1, 1.1.3.2 |
| CM1-L8 | CM1-O-C | CM1-O-PT | Link | 1.1.6: // prepareRefundRequest (số tiền hoàn, mã vé, BR-26, BR-43) (-->)<br>1.1.10: // recordRefundedAmount (số tiền hoàn) (-->) | Nguồn-->Đích: 1.1.6, 1.1.10 |
| CM1-L9 | CM1-O-C | CM1-O-C | Link | 1.1.7: // startWaitingForRefundResponse (BR-43) (-->)<br>1.1.9: // stopWaitingForRefundResponse (-->) | Nguồn-->Đích: 1.1.7, 1.1.9 |
| CM1-L10 | CM1-O-C | CM1-O-PG | Link | 1.1.8: // requestRefund (mã giao dịch, số tiền hoàn, khoá chống hoàn trùng) (-->) | Nguồn-->Đích: 1.1.8 |
| CM1-L11 | CM1-O-PG | CM1-O-A7 | Link | 1.1.8.1: // requestRefund (mã giao dịch, số tiền hoàn, khoá chống hoàn trùng) (-->) | Nguồn-->Đích: 1.1.8.1 |
| CM1-L12 | CM1-O-TK | CM1-O-SS | Link | 1.1.12.1: // releaseSoldSeat (-->) | Nguồn-->Đích: 1.1.12.1 |
| CM1-L13 | CM1-O-WF | CM1-O-C | Link | 1.1.13: // updateSeatMap (ghế đã trống) (<--) | Đích-->Nguồn: 1.1.13 |

### Trang CM2 - Luồng thay thế của Khách (SD2 đến SD5)

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| CM2-O-BF | Object | :CancelTicketForm | «boundary» | - | AC-B-CancelTicketForm |
| CM2-O-C | Object | :CancelTicketController | «control» | - | AC-C-CancelTicketController |
| CM2-O-PG | Object | :PaymentGateway | «boundary» | - | AC-B-PaymentGateway |
| CM2-O-A7 | Actor | :Cổng thanh toán | - | - | (ACT-07) |

b) Bảng Edge

| ID | Nguồn | Đích | Loại | Nhãn | Chiều message |
|---|---|---|---|---|---|
| CM2-L1 | CM2-O-BF | CM2-O-C | Link | 1.1.1a.1: // notifyRefusal (vé không phải vé mua trực tuyến của khách, BR-17) (<--) [khách huỷ vé không phải vé mua trực tuyến của mình (BR-17)]<br>1.1.2a.1: // notifyRefusal (quá hạn huỷ vé, BR-18) (<--) [thời điểm kiểm tra cách giờ bắt đầu chưa tới 2 tiếng, kể cả suất chiếu đã bắt đầu hoặc đã kết thúc (BR-18, BR-32)]<br>1.1.3a.1: // notifyRefusal (vé đã huỷ, không hoàn tiền thêm, BR-21) (<--) [vé đã huỷ, kể cả vừa bị huỷ bởi yêu cầu huỷ khác xử lý ngay trước đó (BR-21)]<br>1.1.3b.1: // notifyRefusal (vé đã sử dụng không huỷ được, BR-30) (<--) [vé chưa huỷ và đã sử dụng, kể cả vừa được soát ngay trước đó (BR-30)] | Đích-->Nguồn: 1.1.1a.1, 1.1.2a.1, 1.1.3a.1, 1.1.3b.1 |
| CM2-L2 | CM2-O-C | CM2-O-C | Link | 1.1.7b.1: // after(BR-43) handleRefundNoResponse (-->)<br>1.1.7b.2: // checkRefundRetriesLeft (BR-41) (-->)<br>1.1.7b.3: // startWaitingForRefundResponse (BR-43) (-->) [còn lượt thử lại (BR-41)]<br>1.1.7c.1: // logRefundFailure (mã vé, mã giao dịch, số tiền hoàn, BR-41) (-->) [còn lượt thử lại (BR-41)]<br>1.1.8a.1: // stopWaitingForRefundResponse (-->)<br>1.1.8a.2: // checkRefundRetriesLeft (BR-41) (-->)<br>1.1.8a.3: // startWaitingForRefundResponse (BR-43) (-->) [còn lượt thử lại (BR-41)]<br>1.1.8b.1: // logRefundFailure (mã vé, mã giao dịch, số tiền hoàn, BR-41) (-->) [còn lượt thử lại (BR-41)] | Nguồn-->Đích: 1.1.7b.1, 1.1.7b.2, 1.1.7b.3, 1.1.7c.1, 1.1.8a.1, 1.1.8a.2, 1.1.8a.3, 1.1.8b.1 |
| CM2-L3 | CM2-O-C | CM2-O-PG | Link | 1.1.7b.4: // requestRefund (mã giao dịch, số tiền hoàn, cùng khoá chống hoàn trùng, BR-43) (-->) [còn lượt thử lại (BR-41)]<br>1.1.8a.4: // requestRefund (mã giao dịch, số tiền hoàn, cùng khoá chống hoàn trùng, BR-43) (-->) [còn lượt thử lại (BR-41)] | Nguồn-->Đích: 1.1.7b.4, 1.1.8a.4 |
| CM2-L4 | CM2-O-PG | CM2-O-A7 | Link | 1.1.7b.4.1: // requestRefund (mã giao dịch, số tiền hoàn, cùng khoá chống hoàn trùng, BR-43) (-->) [còn lượt thử lại (BR-41)]<br>1.1.8a.4.1: // requestRefund (mã giao dịch, số tiền hoàn, cùng khoá chống hoàn trùng, BR-43) (-->) [còn lượt thử lại (BR-41)] | Nguồn-->Đích: 1.1.7b.4.1, 1.1.8a.4.1 |

### Trang CM3 - Biến thể ACT-02 (SD6, SD7)

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| CM3-O-NV | Actor | :Nhân viên quầy | - | - | (ACT-02) |
| CM3-O-CF | Object | :CounterCancelTicketForm | «boundary» | - | AC-B-CounterCancelTicketForm |
| CM3-O-WF | Object | w:BookTicketsForm | «boundary» | - | AC-B-BookTicketsForm |
| CM3-O-C | Object | :CancelTicketController | «control» | - | AC-C-CancelTicketController |
| CM3-O-BK | Object | :Booking | «entity» | - | AC-E-Booking |
| CM3-O-SH | Object | :SeatHold | «entity» | - | AC-E-SeatHold |
| CM3-O-ST | Object | :Showtime | «entity» | - | AC-E-Showtime |
| CM3-O-TK | Object | :Ticket | «entity» | - | AC-E-Ticket |
| CM3-O-SS | Object | :SeatStatus | «entity» | - | AC-E-SeatStatus |

b) Bảng Edge

| ID | Nguồn | Đích | Loại | Nhãn | Chiều message |
|---|---|---|---|---|---|
| CM3-L1 | CM3-O-C | CM3-O-TK | Link | 1.1.4a.1: // calculateRefundAmount (BR-19, BR-31) (-->)<br>2(5a).1.1: // recordRefund (số tiền hoàn, tình trạng hoàn tiền: đã hoàn) (-->)<br>2(5a).1.2: // releaseTicketSeat (-->)<br>2(5a).1.4: // provideTicketContent (-->) | Nguồn-->Đích: 1.1.4a.1, 2(5a).1.1, 2(5a).1.2, 2(5a).1.4 |
| CM3-L2 | CM3-O-CF | CM3-O-C | Link | 1.1.4a.2: // showCashRefund (số tiền mặt cần hoàn, hình thức hoàn tiền: tiền mặt) (<--)<br>2(5a).1: // confirmCashRefund (-->)<br>2(5a).1.5: // showCancellationResult (vé đã huỷ, giá vé, số tiền hoàn, hình thức hoàn tiền, tình trạng hoàn tiền) (<--)<br>1a.1: // findBookingTickets (mã đặt vé) (-->)<br>1a.1.1: // notifyRefusal (mã đặt vé không tồn tại) (<--) [mã đặt vé không trùng mã của lần đặt nào (1a1a)]<br>1a.1.3: // showBookingTickets (các vé của lần đặt: vị trí ghế, giá vé, trạng thái vé) (<--) [mã đặt vé không trùng mã của lần đặt nào (1a1a)]<br>1.1[ACT-02]: // requestCancellation (vé cần huỷ) (-->)<br>1.1.1b.1: // notifyRefusal (vé mua trực tuyến, BR-17) (<--) [tác nhân là nhân viên quầy và vé là vé mua trực tuyến (BR-17)]<br>1.1.1c.1: // notifyRefusal (vé quầy của cụm rạp khác, BR-17) (<--) [vé mua tại quầy của cụm rạp khác cụm rạp của nhân viên quầy (BR-17)] | Nguồn-->Đích: 2(5a).1, 1a.1, 1.1[ACT-02]; Đích-->Nguồn: 1.1.4a.2, 2(5a).1.5, 1a.1.1, 1a.1.3, 1.1.1b.1, 1.1.1c.1 |
| CM3-L3 | CM3-O-NV | CM3-O-CF | Link | 2(5a): // confirmCashRefunded (-->)<br>1a: // enterBookingCode (mã đặt vé) (-->)<br>1a.2: // selectTicketToCancel (vé cần huỷ) (-->) | Nguồn-->Đích: 2(5a), 1a, 1a.2 |
| CM3-L4 | CM3-O-TK | CM3-O-SS | Link | 2(5a).1.2.1: // releaseSoldSeat (-->) | Nguồn-->Đích: 2(5a).1.2.1 |
| CM3-L5 | CM3-O-WF | CM3-O-C | Link | 2(5a).1.3: // updateSeatMap (ghế đã trống) (<--) | Đích-->Nguồn: 2(5a).1.3 |
| CM3-L6 | CM3-O-C | CM3-O-BK | Link | 1a.1.2: // provideBookingInfo (-->) [mã đặt vé không trùng mã của lần đặt nào (1a1a)]<br>1.1.1[ACT-02]: // checkCancellationChannel (vé cần huỷ, nhân viên quầy của phiên) (-->) | Nguồn-->Đích: 1a.1.2, 1.1.1[ACT-02] |
| CM3-L7 | CM3-O-BK | CM3-O-TK | Link | 1a.1.2.1: // provideTicketContent (-->) [lặp: mỗi vé của lần đặt] | Nguồn-->Đích: 1a.1.2.1 |
| CM3-L8 | CM3-O-BK | CM3-O-SH | Link | 1.1.1.1[ACT-02]: // checkHeldBy (nhân viên quầy của phiên) (-->) | Nguồn-->Đích: 1.1.1.1[ACT-02] |
| CM3-L9 | CM3-O-C | CM3-O-ST | Link | 1.1.1c: // checkBelongsToCinema (cụm rạp của nhân viên quầy) (-->) | Nguồn-->Đích: 1.1.1c |

## 8. VOPC

File diagrams/P07-class-UC-008.drawio. ID cell của lớp là mã AC; ngăn thuộc tính và ngăn trách nhiệm có ID "<mã AC>-ATTR" và "<mã AC>-RESP". Thuộc tính ghi trong ngăn chỉ gồm thuộc tính dùng trong UC-008 (thuộc tính đã có ở UC-005 và không dùng lại ở đây không lặp). Mỗi link giữa hai lớp khác nhau ở F7 sinh một quan hệ; link Cổng thanh toán - PaymentGateway và Khách, Nhân viên quầy - boundary là link actor, không vào VOPC.

a) Bảng Node (lớp)

| ID (mã AC) | Loại (Class) | Nhãn (tên lớp) | Stereotype | Thuộc về | Ngăn thuộc tính | Ngăn trách nhiệm |
|---|---|---|---|---|---|---|
| AC-B-CancelTicketForm | Class | CancelTicketForm | «boundary» | - | - | // selectTicketToCancel<br>// notifyRefusal<br>// showCancellationResult |
| AC-B-CounterCancelTicketForm | Class | CounterCancelTicketForm | «boundary» | - | - | // enterBookingCode<br>// showBookingTickets<br>// selectTicketToCancel<br>// notifyRefusal<br>// showCashRefund<br>// confirmCashRefunded<br>// showCancellationResult |
| AC-B-PaymentGateway | Class | PaymentGateway | «boundary» | - | - | // requestRefund |
| AC-B-BookTicketsForm | Class | BookTicketsForm | «boundary» | - | - | // updateSeatMap |
| AC-C-CancelTicketController | Class | CancelTicketController | «control» | - | - | // requestCancellation<br>// findBookingTickets<br>// confirmCashRefund<br>// startWaitingForRefundResponse<br>// stopWaitingForRefundResponse<br>// handleRefundNoResponse<br>// checkRefundRetriesLeft<br>// logRefundFailure |
| AC-E-Ticket | Class | Ticket | «entity» | - | ticketCode (Văn bản)<br>seatPosition (Mã hàng, số ghế)<br>seatType (Văn bản)<br>price (Số tiền)<br>status (Trạng thái)<br>refundAmount (Số tiền) (mới ở UC này)<br>refundStatus (Trạng thái) (mới ở UC này) | // cancelTicket<br>// checkNotCancelledNotUsed<br>// markCancelled<br>// calculateRefundAmount<br>// recordRefund<br>// releaseTicketSeat<br>// provideTicketContent |
| AC-E-Booking | Class | Booking | «entity» | - | bookingCode (Văn bản) | // checkCancellationChannel<br>// providePaymentTransaction<br>// provideBookingInfo |
| AC-E-SeatHold | Class | SeatHold | «entity» | - | holdRef (Văn bản)<br>status (Trạng thái)<br>holdTime (Ngày giờ)<br>expiryTime (Ngày giờ) | // checkHeldBy<br>// providePaymentTransaction |
| AC-E-Showtime | Class | Showtime | «entity» | - | startTime (Ngày giờ)<br>cinema (Cụm rạp) | // checkCancellationDeadline<br>// checkBelongsToCinema |
| AC-E-PaymentTransaction | Class | PaymentTransaction | «entity» | - | transactionCode (Văn bản)<br>amount (Số tiền)<br>refundedTotal (Số tiền) (mới ở UC này) | // prepareRefundRequest<br>// recordRefundedAmount |
| AC-E-SeatStatus | Class | SeatStatus | «entity» | - | seatPosition (Mã hàng, số ghế)<br>seatType (Văn bản)<br>status (Trạng thái)<br>heldPrice (Số tiền) | // releaseSoldSeat |

b) Bảng quan hệ

| ID | Lớp A | Lớp B | Loại | Multiplicity | Vai trò | Nguồn |
|---|---|---|---|---|---|---|
| R-UC008-01 | AC-B-CancelTicketForm | AC-C-CancelTicketController | Association | - | - | tạm thời; link F7: CM1-L2, CM2-L1 |
| R-UC008-02 | AC-B-CounterCancelTicketForm | AC-C-CancelTicketController | Association | - | - | tạm thời; link F7: CM3-L2 |
| R-UC008-03 | AC-B-PaymentGateway | AC-C-CancelTicketController | Association | - | - | tạm thời; link F7: CM1-L10, CM2-L3 |
| R-UC008-04 | AC-B-BookTicketsForm | AC-C-CancelTicketController | Association | - | - | tạm thời; link F7: CM1-L13, CM3-L5 |
| R-UC008-05 | AC-C-CancelTicketController | AC-E-Ticket | Association | - | - | tạm thời; link F7: CM1-L6, CM3-L1 |
| R-UC008-06 | AC-C-CancelTicketController | AC-E-Booking | Association | - | - | tạm thời; link F7: CM1-L3, CM3-L6 |
| R-UC008-07 | AC-C-CancelTicketController | AC-E-Showtime | Association | - | - | tạm thời; link F7: CM1-L5, CM3-L9 |
| R-UC008-08 | AC-C-CancelTicketController | AC-E-PaymentTransaction | Association | - | - | tạm thời; link F7: CM1-L8 |
| R-UC008-09 | AC-E-SeatHold | AC-E-Booking | Association | A 1 - B 0..1 | - | Một lần giữ ghế dẫn tới tối đa một lần đặt (GL-24); cùng R-UC005-17; link F7: CM1-L4, CM3-L8 |
| R-UC008-10 | AC-E-Booking | AC-E-Ticket | Aggregation | A 1 - B 1..8 | - | Lần đặt gồm mỗi ghế một vé, tối đa 8 ghế (GL-24, BR-05); cùng R-UC005-18; link F7: CM3-L7 |
| R-UC008-11 | AC-E-Ticket | AC-E-SeatStatus | Association | A 0..* - B 1 | - | Vé ứng với đúng một ghế của một suất chiếu (GL-59); ghế đã trống bán lại được nên một trạng thái ghế có thể ứng với nhiều vé theo thời gian (BR-42); quan hệ mới ở UC này; link F7: CM1-L12, CM3-L4 |
| R-UC008-12 | AC-E-SeatHold | AC-E-PaymentTransaction | Association | A 1 - B 0..* | - | Giao dịch thanh toán tạo cho tổng tiền của một lần giữ ghế, thử lại tạo giao dịch mới (GL-12); cùng R-UC005-16; bằng chứng từ đặc tả (Dữ liệu ra của vé mua trực tuyến, BR-26, BR-43), không có link; Q-92 |

## 9. Ma trận truy vết

| Bước UC | Message (STT) | Lớp tham gia (AC) |
|---|---|---|
| 1 | 1, 1.1 | AC-B-CancelTicketForm, AC-C-CancelTicketController |
| 1a1 | 1a, 1a.1 | AC-B-CounterCancelTicketForm, AC-C-CancelTicketController |
| 1a1a | 1a.1.1 | AC-C-CancelTicketController, AC-B-CounterCancelTicketForm |
| 1a2 | 1a.1.2, 1a.1.2.1, 1a.1.2 (trả về), 1a.1.3 | AC-C-CancelTicketController, AC-E-Booking, AC-E-Ticket, AC-B-CounterCancelTicketForm |
| 1a3 | 1a.2, 1.1[ACT-02] | AC-B-CounterCancelTicketForm, AC-C-CancelTicketController |
| 2 | 1.1.1, 1.1.1.1, 1.1.1.1 (trả về), 1.1.1 (trả về), 1.1.1[ACT-02], 1.1.1.1[ACT-02], 1.1.1.1[ACT-02] (trả về), 1.1.1[ACT-02] (trả về) | AC-C-CancelTicketController, AC-E-Booking, AC-E-SeatHold |
| 2a | 1.1.1a.1 | AC-C-CancelTicketController, AC-B-CancelTicketForm |
| 2b | 1.1.1b.1 | AC-C-CancelTicketController, AC-B-CounterCancelTicketForm |
| 2c | 1.1.1c, 1.1.1c (trả về), 1.1.1c.1 | AC-C-CancelTicketController, AC-E-Showtime, AC-B-CounterCancelTicketForm |
| 3 | 1.1.2 | AC-C-CancelTicketController, AC-E-Showtime |
| 3a | 1.1.2a.1 | AC-C-CancelTicketController, AC-B-CancelTicketForm |
| 4 | 1.1.3, 1.1.3.1, 1.1.3.2, 1.1.3 (trả về) | AC-C-CancelTicketController, AC-E-Ticket |
| 4a | 1.1.3a.1 | AC-C-CancelTicketController, AC-B-CancelTicketForm |
| 4b | 1.1.3b.1 | AC-C-CancelTicketController, AC-B-CancelTicketForm |
| 5 | 1.1.4, 1.1.4 (trả về), 1.1.5, 1.1.5.1, 1.1.5.1 (trả về), 1.1.5 (trả về), 1.1.6, 1.1.6 (trả về), 1.1.7, 1.1.8, 1.1.8.1 | AC-C-CancelTicketController, AC-E-Ticket, AC-E-Booking, AC-E-SeatHold, AC-E-PaymentTransaction, AC-B-PaymentGateway |
| 5a1 | 1.1.4a.1, 1.1.4a.1 (trả về), 1.1.4a.2 | AC-C-CancelTicketController, AC-E-Ticket, AC-B-CounterCancelTicketForm |
| 5a2 | 2(5a), 2(5a).1 | AC-B-CounterCancelTicketForm, AC-C-CancelTicketController |
| 5b | 1.1.7b.1, 1.1.7b.2, 1.1.7b.3, 1.1.7b.4, 1.1.7b.4.1 | AC-C-CancelTicketController, AC-B-PaymentGateway |
| 5c | 1.1.7c.1 | AC-C-CancelTicketController |
| 6 | 1.1.8.1 (trả về), 1.1.8 (trả về), 1.1.9 | AC-B-PaymentGateway, AC-C-CancelTicketController |
| 6a | 1.1.8a.1, 1.1.8a.2, 1.1.8a.3, 1.1.8a.4, 1.1.8a.4.1 | AC-C-CancelTicketController, AC-B-PaymentGateway |
| 6b | 1.1.8b.1 | AC-C-CancelTicketController |
| 7 | 1.1.10, 1.1.11, 1.1.12, 1.1.12.1, 1.1.13, 2(5a).1.1, 2(5a).1.2, 2(5a).1.2.1, 2(5a).1.3 | AC-C-CancelTicketController, AC-E-PaymentTransaction, AC-E-Ticket, AC-E-SeatStatus, AC-B-BookTicketsForm |
| 8 | 1.1.14, 1.1.14 (trả về), 1.1.15, 2(5a).1.4, 2(5a).1.4 (trả về), 2(5a).1.5 | AC-C-CancelTicketController, AC-E-Ticket, AC-B-CancelTicketForm, AC-B-CounterCancelTicketForm |

## 10. File .drawio

Ba file nằm trong diagrams/: P07-sequence-UC-008.drawio (7 trang), P07-communication-UC-008.drawio (3 trang), P07-class-UC-008.drawio (1 trang). XML không nén, ID cell trùng ID trong bảng mô hình.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ |
|---|---|---|---|
| Q-91 | Bước 6 (cổng báo hoàn tiền thành công hoặc thất bại) được phân tích như kết quả trả về của lời gọi hoàn tiền tới PaymentGateway trong thời hạn 30 giây (BR-43). Cổng thanh toán có báo kết quả hoàn tiền bằng callback riêng không; nếu có thì control nào tiếp nhận, và điều đó phụ thuộc kết luận Q-83 của UC-005 (control nào nhận callback cổng rồi chuyển cho UC-006)? (Kết quả trả về của lời gọi như SD1, SD4, SD5 / Callback, control tiếp nhận theo kết luận Q-83) | SD1 message 1.1.8, SD4, SD5; AC-B-PaymentGateway, // requestRefund; P07 của UC-005 và UC-006; P09 | GL-02 nêu giao tiếp gồm "tạo giao dịch, callback kết quả, hoàn tiền" nhưng không nói cách báo kết quả hoàn tiền; BR-43 chỉ nêu thời hạn chờ 30 giây |
| Q-92 | Một lần giữ ghế có thể có nhiều giao dịch thanh toán do thử lại tạo giao dịch mới (R-UC005-16). Khi hoàn tiền vé mua trực tuyến, giao dịch cần hoàn là giao dịch đã xử lý thành công của lần giữ ghế dẫn tới lần đặt chứa vé (như phân tích, đi qua Ticket, Booking, SeatHold) hay lưu tham chiếu giao dịch trực tiếp trên lần đặt hoặc vé? (Giao dịch đã xử lý thành công của lần giữ ghế / Tham chiếu trực tiếp trên lần đặt hoặc vé) | SD1 message 1.1.5, 1.1.5.1; AC-E-Booking, AC-E-SeatHold, // providePaymentTransaction; R-UC008-12; P08 | P04 UC-008 bước 5 chỉ nêu "mã giao dịch và mã vé"; GL-12, GL-29 không nêu quan hệ giữa vé và giao dịch |
| Q-93 | Khoản hoàn của một vé (số tiền hoàn, tình trạng hoàn tiền) được mô hình hoá là thuộc tính refundAmount, refundStatus của Ticket (như phân tích) hay entity riêng Refund, chung với hoàn toàn bộ thanh toán trễ của UC-006? (Thuộc tính của Ticket / Entity Refund) | AC-E-Ticket, // recordRefund; R-UC008; P07 của UC-006; P08 | GL-45 dùng "Số tiền hoàn" cho cả vé bị huỷ và thanh toán đến trễ; P05 xếp "khoản hoàn, yêu cầu hoàn" vào số tiền hoàn và tình trạng hoàn tiền, còn P04 Mục 1 ghi khoản hoàn "được ghi nhận cho vé" |
| Q-94 | Khi cộng số tiền hoàn vào tổng đã hoàn của giao dịch mà vượt số tiền đã thanh toán (BR-26) thì use case xử lý thế nào? Phân tích coi // prepareRefundRequest luôn đạt vì mỗi vé chỉ hoàn một lần (BR-21) với 70% giá vé và không tạo luồng lỗi. (Không có luồng lỗi vì không xảy ra / Bổ sung luồng từ chối hoàn tiền) | SD1 message 1.1.6; AC-E-PaymentTransaction, // prepareRefundRequest | P04 UC-008 nêu BR-26 ở bước 5 nhưng không có luồng thay thế khi quy tắc bị vi phạm |

## Giả định

Không có (chế độ NGHIEM_NGAT).

## Đề xuất sửa artifact trước

Không có

## Vấn đề còn mở

- Phụ thuộc Q-83 (UC-005): UC-008 không tự quyết điểm tiếp nhận callback của cổng. Kết quả hoàn tiền được phân tích là trả về của lời gọi (Q-91), nên không có message callback hoàn tiền; nếu Q-83 và Q-91 chốt callback thì SD1, SD4, SD5 và PaymentGateway phải bổ sung // reportRefundResult.
- Thao tác không chia cắt ở bước 4 là trách nhiệm cancelTicket của Ticket. Nó phải loại trừ với việc soát cùng một vé ở UC-009 bước 4, 5 (BR-30) và với yêu cầu huỷ khác của cùng vé (BR-21); phân tích chỉ chỉ ra ranh giới của thao tác, cơ chế loại trừ chọn ở P09.
- Bước 7 là bước duy nhất làm ghế về trống, và mọi đường đi (thành công, 5c, 6b, 5a2) đều qua bước 7: SD1, SD4, SD5, SD6 cùng kết thúc ở // releaseTicketSeat. Ghế trả về trống sau giờ bắt đầu suất chiếu không bán lại được ở UC-005 (BR-45); UC-008 không kiểm thêm.
- Số lớp là 11 (4 boundary, 1 control, 6 entity), trong đó 3 lớp là lớp mới của UC-008 (CancelTicketForm, CounterCancelTicketForm, CancelTicketController), 8 lớp tái dùng từ UC-005. Control có 8 trách nhiệm, trong đó 3 là message tự gọi theo A2; checkRefundRetriesLeft chỉ giữ việc còn lượt hay không, số lần thử lại và khoảng cách giữa hai lần là quyết định thiết kế (P09).
- Lớp tái dùng được bổ sung trách nhiệm: PaymentGateway (// requestRefund), BookTicketsForm (// updateSeatMap, đã được UC-005 dùng ở SD1a nhưng chưa có trong F3.4 của UC-005), Ticket, Booking, SeatHold, Showtime, PaymentTransaction, SeatStatus. Trách nhiệm // releaseSoldSeat khác // releaseSeat của UC-005 ở điều kiện (ghế đã bán, không phải đang giữ). Thuộc tính mới ở UC này: refundAmount, refundStatus của Ticket; refundedTotal của PaymentTransaction. Quan hệ mới Ticket - SeatStatus (R-UC008-11).
- Người xem sơ đồ ghế tại quầy dùng CounterBookTicketsForm của UC-005 với cùng message updateSeatMap, không vẽ lifeline riêng. Khi tác nhân là nhân viên quầy, các message notifyRefusal của 3a, 4a, 4b gửi tới CounterCancelTicketForm thay CancelTicketForm (ghi chú ở SD2, SD3), không vẽ trang riêng.
- Chạy song song: ba lớp mới ghi "Mới - chạy song song, chờ P08 hợp nhất". Mã Q tạm Q-91 đến Q-94 cần P08 đánh lại số liên tục.
- File P07-sequence-UC-008.drawio giữ bố cục sinh từ bảng mô hình (không chạy diakempt). Hai file communication và class đã qua diakempt (communication bỏ bước compact, class bỏ bước classlayout); nhãn link trong communication dài vì mỗi cặp đối tượng một link nên một số nhãn có thể chồng nhau.
- Luồng 1a vẽ trong biến thể ACT-02 (SD7) cùng 2b, 2c; luồng 5a vẽ ở SD6 và lặp lại bước 7, 8 của biến thể vì 5a nhập lại luồng chính ở bước 7 với tác nhân khác.
