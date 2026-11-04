# P11a - Danh sách màn hình - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (Toàn bộ: giai đoạn 1 và giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md; P01-actors.md 1.1; P02-usecases.md 1.8; P04-uc-specs UC-005 1.8, UC-008 1.4, UC-009, UC-013 1.2, UC-014 1.3; P05-glossary.md 1.1; P06-supplementary-spec.md 1.1; P07-uc-analysis (UC-005, UC-008, UC-009, UC-013, UC-014); P08-analysis-model.md 1.1 (F3); P09-architecture.md 1.2 (F5, F7.5, F7.6); P10-design-elements.md 1.1 (F3, F4); ui-standards.md 1.0; SCR-01 đến SCR-20 |
| Phạm vi | Toàn hệ thống: UC-005, UC-008, UC-009, UC-013, UC-014 và màn hình đăng nhập. UC-006 không có màn hình (tác nhân chính là cổng thanh toán) |
| Mã Q, ASM cuối đã cấp | Q-125; không có ASM (NGHIEM_NGAT). MSG đã cấp: MSG-01 đến MSG-79 |

Mức hợp lý: 20 màn hình; mỗi use case của một tác nhân chính có 1 đến 4 màn hình (UC-005 khách 4: SCR-03 đến SCR-06; UC-005 quầy 3: SCR-10 đến SCR-12; UC-008 khách 2: SCR-07, SCR-08; UC-008 quầy 3: SCR-13 đến SCR-15; UC-009 1: SCR-16; UC-013 1: SCR-18; UC-014 2: SCR-19, SCR-20). Boundary BookTicketsForm và CounterBookTicketsForm (một View mỗi boundary ở P10) sinh nhiều màn hình, ghi ở Đề xuất sửa artifact trước.

## Danh sách màn hình

| SCR | Tên | Boundary AC nguồn | UC | Tác nhân | Loại | Lớp thiết kế (DC) | Mục đích | Bước UC phục vụ |
|---|---|---|---|---|---|---|---|---|
| SCR-01 | Đăng nhập (Log in) | AC-B-BookTicketsForm (khách); nhân viên: chưa có | Tiền điều kiện UC-005, UC-008, UC-009, UC-013, UC-014 | ACT-01 Khách, ACT-02 Nhân viên quầy, ACT-03 Nhân viên soát vé, ACT-04 Quản lý cụm rạp | Độc lập (pop-up Con phụ thuộc khi mở từ SCR-04) | Chưa có | Nhập định danh và mật khẩu để có phiên làm việc | UC-005 luồng 5a1, 5a2; tiền điều kiện các UC còn lại |
| SCR-02 | Trang chủ khách (Customer home) | Điều hướng: SCR-03, SCR-07 | UC-005, UC-008 (lối vào) | ACT-01 Khách | Độc lập | Chưa có (điều hướng) | Chọn lối vào Đặt vé hoặc Huỷ vé, xem kết quả use case vừa kết thúc | UC-005 bước 1; UC-008 bước 1; thông điệp kết thúc, từ chối của UC-005 |
| SCR-03 | Chọn suất chiếu (Select showtime) | AC-B-BookTicketsForm | UC-005 | ACT-01 Khách | Độc lập | DC-BookTicketsView | Chọn suất chiếu muốn mua vé | 1, 2; luồng 2a, 2c |
| SCR-04 | Chọn ghế (Select seats) | AC-B-BookTicketsForm | UC-005 | ACT-01 Khách | Phụ thuộc có dữ liệu | DC-BookTicketsView | Xem sơ đồ ghế real-time và chọn ghế | 3, 4, 5, 6, 7; luồng 5a, 5b, 6a, 7a, 7c, 7d, 7e |
| SCR-05 | Giữ ghế và thanh toán (Hold seats and pay) | AC-B-BookTicketsForm | UC-005 | ACT-01 Khách | Phụ thuộc có dữ liệu | DC-BookTicketsView | Xem ghế đã giữ, tổng tiền, đồng hồ 10 phút, huỷ giữ ghế hoặc thanh toán qua VNPay | 8, 9, 10, 11; luồng 7b, 10a, 11a, *a |
| SCR-06 | Kết quả đặt vé (Booking result) | AC-B-BookTicketsForm | UC-005 | ACT-01 Khách | Phụ thuộc có dữ liệu | DC-BookTicketsView | Xem kết quả thanh toán, mã đặt vé và các vé | 11, 12, 13, 14, 15; luồng 7b, 11a |
| SCR-07 | Chọn vé cần huỷ (Select ticket to cancel) | AC-B-CancelTicketForm | UC-008 | ACT-01 Khách | Độc lập | DC-CancelTicketView | Chọn vé mua trực tuyến cần huỷ và xác nhận | 1, 2, 3, 4, 5, 6, 7; luồng 2a, 3a, 4a, 4b |
| SCR-08 | Kết quả huỷ vé (Cancellation result) | AC-B-CancelTicketForm | UC-008 | ACT-01 Khách | Phụ thuộc có dữ liệu | DC-CancelTicketView | Xem kết quả huỷ vé và khoản hoàn | 7, 8; luồng 5c, 6b |
| SCR-09 | Trang chủ quầy (Counter home) | Điều hướng: SCR-10, SCR-13 | UC-005, UC-008 (lối vào) | ACT-02 Nhân viên quầy | Độc lập | Chưa có (điều hướng) | Chọn lối vào Bán vé hoặc Huỷ vé tại quầy | UC-005 bước 1; UC-008 bước 1a; thông điệp kết thúc, từ chối của UC-005 tại quầy |
| SCR-10 | Chọn suất và ghế tại quầy (Select showtime and seats at counter) | AC-B-CounterBookTicketsForm | UC-005 | ACT-02 Nhân viên quầy | Độc lập | DC-CounterBookTicketsView | Chọn suất chiếu và ghế khách muốn mua tại quầy | 1, 2, 3, 4, 5, 6, 7; luồng 2a, 2b, 2c, 5b, 6a, 7a, 7c, 7d, 7e |
| SCR-11 | Giữ ghế và thu tiền mặt (Hold seats and collect cash) | AC-B-CounterBookTicketsForm | UC-005 | ACT-02 Nhân viên quầy | Phụ thuộc có dữ liệu | DC-CounterBookTicketsView | Xem ghế đã giữ, đồng hồ 10 phút, xác nhận đã thu tiền mặt hoặc huỷ giữ ghế | 8, 9a1, 9a2; luồng 9a1a, 7b, *a |
| SCR-12 | In vé tại quầy (Print tickets at counter) | AC-B-CounterBookTicketsForm | UC-005 | ACT-02 Nhân viên quầy | Phụ thuộc có dữ liệu | DC-CounterBookTicketsView | Xem mã đặt vé và vé, in vé | 9a3, 9a4, 9a5 |
| SCR-13 | Tìm vé theo mã đặt vé (Find tickets by booking code) | AC-B-CounterCancelTicketForm | UC-008 | ACT-02 Nhân viên quầy | Độc lập | DC-CounterCancelTicketView | Nhập mã đặt vé, chọn vé mua tại quầy cần huỷ | 1a1, 1a1a, 1a2, 1a3, 2, 3, 4; luồng 2b, 2c, 3a, 4a, 4b |
| SCR-14 | Hoàn tiền mặt (Cash refund) | AC-B-CounterCancelTicketForm | UC-008 | ACT-02 Nhân viên quầy | Phụ thuộc có dữ liệu | DC-CounterCancelTicketView | Xem số tiền mặt cần hoàn và xác nhận đã hoàn | 5a1, 5a2, 7 |
| SCR-15 | Kết quả huỷ vé tại quầy (Counter cancellation result) | AC-B-CounterCancelTicketForm | UC-008 | ACT-02 Nhân viên quầy | Phụ thuộc có dữ liệu | DC-CounterCancelTicketView | Xem kết quả huỷ vé tại quầy | 7, 8 |
| SCR-16 | Soát vé (Check ticket) | AC-B-CheckTicketForm | UC-009 | ACT-03 Nhân viên soát vé | Độc lập | DC-CheckTicketView | Chọn suất chiếu đang soát, quét mã QR, xem kết quả hợp lệ hoặc lý do từ chối | 1, 2, 3, 4, 5, 6, 7; luồng 4a, 4b, 4c, 4d, 4e |
| SCR-17 | Trang chủ quản lý cụm rạp (Cinema manager home) | Điều hướng: SCR-18, SCR-19 | UC-013, UC-014 (lối vào) | ACT-04 Quản lý cụm rạp | Độc lập | Chưa có (điều hướng) | Chọn lối vào Quản lý bảng giá hoặc Lập lịch suất chiếu | UC-013 bước 1; UC-014 bước 1 |
| SCR-18 | Bảng giá cụm rạp (Cinema price list) | AC-B-ManagePriceListForm | UC-013 | ACT-04 Quản lý cụm rạp | Độc lập | DC-ManagePriceListView | Xem bảng giá, đặt giá, bỏ giá | 1, 2, 3, 4, 5, 6; luồng 1a, 1a1-1a4, 4a, 5a, *a |
| SCR-19 | Danh sách suất chiếu (Showtime list) | AC-B-ScheduleShowtimesForm | UC-014 | ACT-04 Quản lý cụm rạp | Độc lập | DC-ScheduleShowtimesView | Xem danh sách suất chiếu, chọn lập, sửa, xoá | 1, 1a1-1a3, 1b1-1b4; luồng 1a3a, 1a3b, 1b3a, 1b3b, 1b3c |
| SCR-20 | Lập hoặc sửa suất chiếu (Create or edit showtime) | AC-B-ScheduleShowtimesForm | UC-014 | ACT-04 Quản lý cụm rạp | Con phụ thuộc | DC-ScheduleShowtimesView | Nhập thông tin suất chiếu để lập hoặc sửa | 2, 3, 4, 5, 6, 7, 8, 9; luồng 1a4, 4a, 5a, 5b, 5c, 6a, 6b, 6c, 8a-8e, *a |

## Boundary không có màn hình

| AC | Loại boundary | Ánh xạ ở P10 (SS, DC) | Lý do |
|---|---|---|---|
| AC-B-PaymentGateway | Hệ thống ngoài (cổng thanh toán) | SS-01, IF-01, IF-02 | P10 ánh xạ sang subsystem; tác nhân là hệ thống ngoài ACT-07. Khách chỉ thấy kết quả qua SCR-05 (chuyển sang VNPay) và SCR-06 (trang kết quả) |
| AC-B-EmailService | Kênh thông báo (email) | SS-02, IF-03 | Kênh thông báo, không cần màn hình; khách thấy kết quả gửi vé trong MSG-17 của SCR-06 |

UC-006 Hoàn tiền thanh toán trễ: tác nhân chính ACT-07 Cổng thanh toán, tác nhân phụ ACT-08 Dịch vụ email, không có tác nhân người nên không có màn hình; khách nhận kết quả hoàn tiền qua email (GL-06).

## Bảng tổng hợp đánh giá chuẩn (F7)

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-01 | Nielsen 9 Nhận biết, chẩn đoán, khắc phục lỗi | Đạt | MSG-02 nêu việc cần làm và không cho biết trường nào sai | - |
| SCR-01 | WCAG 3.3.7 Không bắt nhập lại | Đạt | Dạng pop-up giữ nguyên ghế đã chọn và tự gửi lại việc xác nhận | - |
| SCR-01 | WCAG 3.3.8 Xác thực dễ tiếp cận | Đạt | Cho phép trình duyệt điền tự động, có Hiện mật khẩu (UI-STT 46) | - |
| SCR-01 | Baymard: nhãn trên ô nhập, giữ dữ liệu | Đạt | UI-STT 16, 20 | - |
| SCR-02 | Nielsen 1 Hiển thị trạng thái hệ thống | Vi phạm còn mở (do phạm vi) | Bốn lối vào UC-001, UC-003, UC-004, UC-007 chưa có màn hình đích | Chấp nhận, cập nhật khi các use case được đặc tả |
| SCR-02 | Nielsen 8 Thẩm mỹ, tối giản | Đạt | Hai thẻ hoạt động, bốn thẻ vô hiệu gom một dòng | - |
| SCR-03 | Nielsen 7 Linh hoạt và hiệu quả | Vi phạm còn mở | Không có lọc, tìm kiếm danh sách suất chiếu (thuộc UC-004 chưa đặc tả) | Chờ Q-120 |
| SCR-03 | Nielsen 3 Kiểm soát và tự do | Đạt | Từ chối ở lại danh sách theo UI-STT 29(2), không đẩy khách khỏi màn hình | - |
| SCR-04 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | Dải trạng thái kết nối, MSG-26, đếm ghế đã chọn (UI-STT 40, 41) | - |
| SCR-04 | Nielsen 5 Ngăn lỗi | Đạt | Ghế đang giữ, đã bán không chọn được; nút vô hiệu khi chưa chọn ghế | - |
| SCR-04 | WCAG 1.4.1 Không dùng màu làm tín hiệu duy nhất | Đạt | Bốn trạng thái ghế khác nhau cả biểu tượng, hoạ tiết, chữ (UI-STT 39) | - |
| SCR-04 | WCAG 1.4.10 Reflow | Không áp dụng | Sơ đồ ghế là nội dung hai chiều, cuộn ngang trong khung | Ghi ở UI-STT 39 |
| SCR-04 | WCAG 2.1.1 Bàn phím | Đạt | Lưới ghế dùng phím mũi tên và Space (UI-STT 26) | - |
| SCR-04 | WCAG 4.1.3 Thông điệp trạng thái | Đạt | Thay đổi ghế được gộp thành thông báo role=status (UI-STT 40) | - |
| SCR-04 | Baymard / Nielsen 6 | Đạt | Giữ lựa chọn khi đăng nhập và khi bị từ chối ở 6a, 7a | - |
| SCR-05 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | Đồng hồ, chữ "Sắp hết thời gian", MSG-26, MSG-27 (UI-STT 43, 27) | - |
| SCR-05 | Nielsen 3 Kiểm soát và tự do | Vi phạm còn mở | Khách tải lại hoặc rời trang rồi chưa có lối quay lại lần giữ ghế (Q-119); không gia hạn được vì BR-10 | Chờ Q-119 |
| SCR-05 | Nielsen 5 Ngăn lỗi | Đạt | Hộp xác nhận huỷ giữ ghế (MSG-18); cảnh báo khi rời trang (MSG-77) | - |
| SCR-05 | WCAG 2.2.1 Giới hạn thời gian | Đạt | Giới hạn 10 phút là quy tắc nghiệp vụ thiết yếu, có cảnh báo ở bốn mốc (UI-STT 36) | - |
| SCR-05 | WCAG 1.4.1 | Đạt | Trạng thái sắp hết hạn có chữ và nền, không chỉ màu | - |
| SCR-05 | Baymard: tóm tắt đơn và tổng tiền ở bước thanh toán | Đạt | Bảng ghế, giá và tổng tiền cạnh nút thanh toán (UI-STT 44) | - |
| SCR-06 | Nielsen 1 Hiển thị trạng thái hệ thống | Vi phạm còn mở | Khách đóng tab ở VNPay hoặc tải lại sau hạn polling thì không có màn hình xem lại kết quả (Q-119) | Chờ Q-119 |
| SCR-06 | Nielsen 9 | Đạt | MSG-14, MSG-16, MSG-30 nêu kết quả và việc tiếp theo (hoàn tiền, kiểm tra email) | - |
| SCR-06 | WCAG 1.1.1 Nội dung không phải chữ | Đạt | Mã QR có văn bản thay thế nêu ghế và mã đặt vé (UI-STT 34) | - |
| SCR-06 | WCAG 4.1.3 | Đạt | Kết quả đổi từ MSG-28 sang kết quả cuối qua vùng role=status | - |
| SCR-07 | Nielsen 5 Ngăn lỗi | Đạt | Hộp xác nhận nêu số tiền hoàn và không hoàn tác (UI-STT 37) | - |
| SCR-07 | Nielsen 1 | Đạt | MSG-78 trong lúc hoàn tiền kéo dài (UI-STT 27) | - |
| SCR-07 | WCAG 3.3.4 Ngăn lỗi tài chính | Đạt | Xác nhận trước khi huỷ vé và hoàn tiền | - |
| SCR-07 | Nielsen 7 | Vi phạm còn mở | Không có lọc theo mã đặt vé hoặc suất chiếu (chưa có trong đặc tả) | Chờ Q-121 |
| SCR-08 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | Tình trạng hoàn tiền hiện rõ cả khi chưa hoàn được (MSG-41) | - |
| SCR-08 | Nielsen 9 | Đạt | MSG-41 nêu khoản hoàn được xử lý thủ công | - |
| SCR-09 | Nielsen 4 Nhất quán | Đạt | Cùng bố cục thẻ với SCR-02 và SCR-17 (UI-STT 47) | - |
| SCR-10 | Nielsen 7 Linh hoạt và hiệu quả | Đạt | Chọn suất và ghế trên một màn hình cho thao tác lặp tại quầy | - |
| SCR-10 | Nielsen 1 | Đạt | Dải kết nối, đếm ghế, MSG-26 | - |
| SCR-10 | WCAG 1.4.1 | Đạt | Bốn ký hiệu ghế như SCR-04 (UI-STT 39) | - |
| SCR-10 | WCAG 2.1.1 | Đạt | UI-STT 26 | - |
| SCR-11 | Nielsen 5 Ngăn lỗi | Đạt | Hộp xác nhận thu tiền nêu số tiền (MSG-22) và xử lý xác nhận trễ bằng MSG-20 | - |
| SCR-11 | WCAG 3.3.4 Ngăn lỗi tài chính | Đạt | Xác nhận trước khi chuyển ghế sang đã bán | - |
| SCR-11 | WCAG 2.2.1 | Đạt | UI-STT 36, 43 | - |
| SCR-11 | Nielsen 3 | Vi phạm còn mở | Rời trang thì không có lối quay lại lần giữ ghế (Q-119); không gia hạn vì BR-10 | Chờ Q-119 |
| SCR-12 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | MSG-21 báo đã bán vé và việc cần làm tiếp | - |
| SCR-12 | WCAG 1.1.1 | Đạt | Mã QR có văn bản thay thế (UI-STT 34) | - |
| SCR-13 | Nielsen 5 Ngăn lỗi | Đạt | Hộp xác nhận nêu số tiền mặt hoàn và không hoàn tác (UI-STT 37) | - |
| SCR-13 | Nielsen 9 | Đạt | MSG-31 nêu việc cần làm tiếp và giữ mã đã nhập | - |
| SCR-13 | Baymard: giữ dữ liệu đã nhập | Đạt | Mã đặt vé còn nguyên sau MSG-31 (UI-STT 20) | - |
| SCR-13 | WCAG 3.3.4 | Đạt | Xác nhận trước khi huỷ vé | - |
| SCR-14 | Nielsen 5 Ngăn lỗi | Đạt | Hộp xác nhận nêu số tiền (MSG-42) | - |
| SCR-14 | Nielsen 3 Kiểm soát và tự do | Vi phạm còn mở | Vé đã huỷ ở bước 4 trước khi xác nhận hoàn tiền; rời màn hình chưa có cách xử lý (Q-125) | Chờ Q-125 |
| SCR-14 | WCAG 3.3.4 | Đạt | Xác nhận tài chính trước khi ghi nhận hoàn tiền | - |
| SCR-15 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | MSG-43 và tình trạng hoàn tiền hiện ngay sau xác nhận | - |
| SCR-16 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | Khối kết quả lớn có chữ, biểu tượng và màu; giữ tới lần quét kế (UI-STT 45) | - |
| SCR-16 | Nielsen 5 Ngăn lỗi | Đạt | Chống đọc lại cùng mã trong 3 giây để không sinh thêm kết quả đã sử dụng giả | - |
| SCR-16 | WCAG 1.4.1 | Đạt | Hợp lệ và từ chối khác nhau cả chữ, biểu tượng, màu | - |
| SCR-16 | WCAG 2.1.1 Bàn phím | Vi phạm còn mở | Việc quét bằng camera không có thao tác bàn phím thay thế; đặc tả cấm nhập tay mã QR (NFR-13) | Chấp nhận do ràng buộc thiết kế NFR-13; chọn suất chiếu và mọi điều khiển khác dùng được bằng bàn phím |
| SCR-16 | WCAG 4.1.3 | Đạt | Kết quả quét thông báo qua vùng role=alert/status | - |
| SCR-16 | Nielsen 7 | Đạt | Chọn suất một lần, quét liên tục không thao tác thêm | - |
| SCR-17 | Nielsen 1 Hiển thị trạng thái hệ thống | Vi phạm còn mở (do phạm vi) | Hai lối vào UC-012, UC-015 chưa có màn hình đích | Chấp nhận, cập nhật khi use case được đặc tả |
| SCR-18 | Nielsen 5 Ngăn lỗi | Đạt | Xác nhận trước khi bỏ giá (MSG-56); danh sách chọn thay ô gõ cho bốn yếu tố tổ hợp | - |
| SCR-18 | Nielsen 4 Nhất quán | Đạt | Bố cục bảng và biểu mẫu thống nhất với SCR-19 | - |
| SCR-18 | Baymard: một cột, nhãn trên ô, bắt buộc có dấu * | Đạt | UI-STT 16 áp dụng cho biểu mẫu Đặt giá | - |
| SCR-18 | WCAG 1.4.1 | Đạt | Hàng vừa lưu có viền trái và biểu tượng, không chỉ màu (UI-STT 18) | - |
| SCR-19 | Nielsen 5 Ngăn lỗi | Đạt | Hộp xác nhận xoá nêu hậu quả (MSG-71) | - |
| SCR-19 | Nielsen 3 | Đạt | Từ chối ở lại danh sách, không đẩy người dùng ra màn hình khác (UI-STT 29(2)) | - |
| SCR-19 | WCAG 2.4.3 | Đạt | Đóng pop-up SCR-20 trả tiêu điểm về nút đã mở (UI-STT 21) | - |
| SCR-20 | Nielsen 5 Ngăn lỗi | Đạt | Danh sách chọn cho phim, định dạng, phòng chiếu; hiện khoảng chiếu của phim ngay dưới ô (UI-STT 32) | - |
| SCR-20 | Nielsen 9 | Đạt | Mỗi từ chối có thông điệp riêng nêu cách khắc phục (MSG-58 đến MSG-65) | - |
| SCR-20 | Baymard: một cột, giữ dữ liệu khi lỗi | Đạt | UI-STT 16, 20 | - |
| SCR-20 | WCAG 2.4.3, 2.4.11 | Đạt | Tiêu điểm bị giữ trong hộp và trả về khi đóng (UI-STT 21) | - |
| SCR-20 | WCAG 3.3.2 | Đạt | Gợi ý định dạng ngày giờ dưới nhãn, không dùng placeholder thay nhãn | - |

Tổng hợp Shneiderman: nhất quán --> Đạt (UI-STT 05-09, 22, 47); khả dụng cho mọi người dùng --> Đạt (UI-STT 15, 33-36); phản hồi đầy đủ --> Đạt (UI-STT 27, 28, 40, 41, 43); hội thoại có điểm kết thúc rõ --> Đạt (SCR-06, SCR-08, SCR-12, SCR-15); ngăn lỗi --> Đạt (UI-STT 19, 37); hoàn tác dễ dàng --> Vi phạm còn mở (đặc tả không có hoàn tác); người dùng làm chủ --> Đạt, ngoại lệ Q-119; giảm tải trí nhớ ngắn hạn --> Đạt (UI-STT 39, 43, 44).

Số dòng Vi phạm còn mở: 0; Vi phạm đã sửa: 0; mọi vi phạm còn mở do phạm vi đặc tả hoặc câu hỏi mở (Q-119, Q-120, Q-121, Q-125) hoặc ràng buộc NFR-13.

## Câu hỏi mở

Xem ui-standards.md: Q-119 đến Q-125 (mã tạm, chạy song song với P11b). Câu hỏi quan trọng nhất: Q-119 (quay lại lần giữ ghế đang chạy và kết quả đặt vé).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P10 | F4 (PKG-05, PKG-06, PKG-08) | Chưa có View cho màn hình đăng nhập và màn hình điều hướng của khách, nhân viên quầy, quản lý cụm rạp | Thêm DC-LoginView, DC-CustomerHomeView (PKG-05), DC-CounterHomeView (PKG-06), DC-CinemaAdminHomeView (PKG-08) |
| P10 | F3 (AC-B-BookTicketsForm, AC-B-CounterBookTicketsForm) | Mỗi boundary một View nhưng sinh nhiều màn hình (SCR-03 đến SCR-06, SCR-10 đến SCR-12) | Ghi ở P12: tách View thành các component trang tương ứng |
| P08, P10 | Boundary giao diện của UC-001 Đăng ký tài khoản | UC-001 là use case trước phiên, P08 và P10 chưa có boundary giao diện nên chưa có màn hình | Thêm boundary khi UC-001 có P07; thêm lối vào ở SCR-02 |
| P08 | AC-B-BookTicketsForm, AC-B-CounterBookTicketsForm | Thiếu trách nhiệm hiển thị thời điểm hết hạn giữ ghế và đọc trạng thái giao dịch ở trang kết quả (xem ui-standards.md) | Thêm showHoldCountdown, showPaymentOutcome |

## Vấn đề còn mở

1. Chưa lập mockup HTML (XUAT_HTML = Không).
2. Các vi phạm còn mở trong bảng F7 chờ Q-119, Q-120, Q-121, Q-125 hoặc do phạm vi.
3. Thông điệp của mọi SCR đã nằm trong danh mục MSG của ui-standards.md (mục h của mọi SCR ghi Không có), mọi ngoại lệ đã đưa vào quy định gốc; không có dòng nào để gom thêm.
