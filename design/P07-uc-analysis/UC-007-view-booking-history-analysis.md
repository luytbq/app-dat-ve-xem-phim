# P07 - Phân tích use case UC-007 Xem lịch sử đặt vé - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P07 |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | 00-Conventions.md (C10); 00-Concurrency.md (M3); project-profile.md; P04-uc-specs/UC-007-view-booking-history.md 1.1; P01-actors.md 1.2; P02-usecases.md 1.9; P03-usecase-model.md 1.2; P05-glossary.md 1.2; P06-supplementary-spec.md 1.4; P04-uc-specs/_BR-register.md (đầu lô); P07-uc-analysis/UC-005-book-tickets-analysis.md (sổ đăng ký AC: F1, F3.4, F8 b, Câu hỏi mở, Vấn đề còn mở; đầu lô) và UC-006, UC-008, UC-009, UC-013, UC-014 (F3.4); _sync-log.md (mục Đầu vào cho lần chạy lại P07-P13, dòng UC-001, UC-007); dải mã được cấp Q-225 đến Q-234 |
| Phạm vi | UC-007 |
| Mã Q, ASM cuối đã cấp | Q-227 (Q-225 cấp ở UC-001, Q-226 và Q-227 ở use case này; trong dải Q-225 đến Q-234); không có ASM (NGHIEM_NGAT) |

## 1. Bối cảnh use case

| Thuộc tính | Giá trị |
|---|---|
| Mã và tên UC | UC-007 Xem lịch sử đặt vé (View Booking History) |
| Tác nhân chính | ACT-01 Khách (Người) |
| Tác nhân phụ | Không có |
| Include (UC) | Không có |
| Được include bởi (UC) | Không có |
| Extend (UC, điểm mở rộng, điều kiện) | Không có |
| Được extend bởi (UC, điểm mở rộng, điều kiện) | Không có |
| Use case liên quan không qua include, extend | UC-005 Đặt vé tạo lần đặt và vé (REQ-30, REQ-105). UC-008 Huỷ vé đặt trạng thái vé đã huỷ (REQ-40), UC-009 Soát vé đặt trạng thái đã sử dụng (REQ-52); UC-007 chỉ đọc trạng thái tại lúc hiển thị. UC-001 tạo tài khoản khách (AC-E-Customer). UC-010, UC-011, UC-012 có thể sửa tên phim, cụm rạp, phòng chiếu sau khi bán vé (BR-140) |
| Tác nhân thời gian | Không có. P02 không có use case do tác nhân thời gian kích hoạt trên lần đặt hoặc vé (P04 Mục 8), nên không có message hẹn mốc |
| File P07 đã có được dùng làm sổ đăng ký AC | UC-005-book-tickets-analysis.md. Tái dùng AC-E-Customer, AC-E-Booking, AC-E-Ticket, AC-E-Showtime. UC-006, UC-008, UC-009, UC-013, UC-014 dùng để tra tên lớp và trách nhiệm |

## 2. Đặc tả bổ sung

| Bước UC | Thực hiện bởi | Mô tả trong đặc tả | Mô tả bổ sung (hệ thống làm gì bên trong) | Nguồn (BR, GL, REQ) |
|---|---|---|---|---|
| 1 | Khách | Yêu cầu xem lịch sử đặt vé | Không đổi | EV-09 |
| 2 | Hệ thống | Hiển thị các lần đặt vé của chính khách (BR-94) | Control xác định khách của phiên, hỏi khách đã có lần đặt nào chưa. Nếu có, khách duyệt các lần đặt của mình từ gần nhất trước; mỗi lần đặt đếm vé của nó, lấy tên phim và tên cụm rạp theo vé lúc bán (BR-140) và ngày giờ bắt đầu từ suất chiếu của vé, rồi boundary hiển thị. | BR-94, BR-140, GL-24, Dữ liệu ra 1, Q-160 |
| 3 | Khách | Chọn một lần đặt vé cần xem | Không đổi | REQ-39, Dữ liệu vào 1 |
| 4 | Hệ thống | Kiểm tra lần đặt đã chọn thuộc về khách (BR-94) | Khách của phiên đối chiếu mã đặt vé đã chọn với các lần đặt của chính mình. Tìm lần đặt theo mã đặt vé coi là có sẵn. | BR-94 |
| 5 | Hệ thống | Hiển thị các vé của lần đặt đã chọn | Lần đặt đã chọn cung cấp mã đặt vé và, với mỗi vé của nó, nội dung vé theo REQ-105 kèm mã QR và trạng thái (Q-159). Vé cung cấp tên phim, cụm rạp, phòng chiếu và loại phòng lúc bán (BR-140), ghế, giá, mã QR, trạng thái; định dạng phim và ngày giờ bắt đầu lấy từ suất chiếu của vé. | REQ-105, BR-140, Dữ liệu ra 2, Q-159, GL-59 |
| 2a | Hệ thống | Thông báo khách chưa có lần đặt vé nào; kết thúc use case (thành công) | Khách chưa có lần đặt nào thì control báo boundary thông báo; không đọc vé hay suất chiếu nào. | Dữ liệu ra 1 |
| 4a | Hệ thống | Từ chối hiển thị và thông báo quy tắc bị vi phạm (BR-94); quay lại bước 3 | Lần đặt đã chọn không thuộc khách thì control báo boundary từ chối kèm quy tắc BR-94 và không đọc vé nào. | BR-94 |

## 3. Tìm lớp phân tích

### 3.1 Bảng boundary

| Tác nhân (ACT) | Loại tác nhân | Boundary | Loại boundary | Mới hoặc tái dùng (AC, UC nguồn) | Lý do |
|---|---|---|---|---|---|
| ACT-01 Khách | Người | ViewBookingHistoryForm | Giao diện người dùng | Mới (AC-B-ViewBookingHistoryForm) | Khách yêu cầu xem lịch sử, chọn một lần đặt và nhận danh sách lần đặt hoặc các vé; boundary giao diện người dùng đặt tên theo tương tác của use case. |

Số boundary là 1, bằng số tác nhân tham gia (không có tác nhân phụ, không có tác nhân thời gian).

### 3.2 Bảng lọc danh từ

| STT | Danh từ hoặc cụm danh từ | Vị trí (bước UC, mục dữ liệu, BR) | Kết luận | Lý do |
|---|---|---|---|---|
| 1 | khách | 1, 2, 4; BR-94 | Entity AC-E-Customer | Thông tin về tác nhân, không phải tác nhân: hệ thống biết các lần đặt của khách (GL-18, BR-94). Dùng lại mã đã cấp ở UC-005. |
| 2 | lịch sử đặt vé, danh sách lần đặt | 1, 2; Dữ liệu ra 1 | Loại - cấu trúc cài đặt | Tập các lần đặt của khách, kết quả của việc duyệt Customer, không là khái niệm lưu riêng. |
| 3 | lần đặt, lần đặt vé | 2, 3, 4, 5; BR-94 | Entity AC-E-Booking | Hệ thống lưu, có hành vi cung cấp tóm tắt và chi tiết (GL-24). Dùng lại mã đã cấp ở UC-005. |
| 4 | mã đặt vé | 2, 3; Dữ liệu vào 1; Dữ liệu ra 1, 2 | Loại - thuộc tính của Booking | GL-28, BR-80. |
| 5 | số vé | 2; Dữ liệu ra 1 | Loại - giá trị suy ra từ Booking | Booking đếm các vé của mình khi cần, không lưu. |
| 6 | vé | 5; Dữ liệu ra 2 | Entity AC-E-Ticket | Có trạng thái và nội dung riêng (GL-59). Dùng lại mã đã cấp ở UC-005. |
| 7 | tên phim, tên cụm rạp, tên phòng chiếu, loại phòng | 2, 5; BR-140; Dữ liệu ra 1, 2 | Loại - thuộc tính của Ticket | Vé giữ giá trị lúc bán; sửa sau đó không đổi nội dung vé và lịch sử (BR-140). |
| 8 | định dạng phim, ngày giờ bắt đầu suất chiếu | 2, 5; Dữ liệu ra 1, 2 | Loại - thuộc tính của Showtime | Đọc từ suất chiếu của vé; đặc tả không yêu cầu giữ giá trị lúc bán cho hai thông tin này (Q-227). |
| 9 | suất chiếu | 2, 5 | Entity AC-E-Showtime | Cung cấp định dạng và giờ bắt đầu (GL-47). Dùng lại mã đã cấp ở UC-005. |
| 10 | vị trí ghế, loại ghế, giá vé, mã QR, trạng thái vé | 5; Dữ liệu ra 2 | Loại - thuộc tính của Ticket | GL-59, GL-60, GL-61, GL-65, GL-30. |
| 11 | phim, cụm rạp, phòng chiếu | 2, 5 | Loại - khái niệm do UC-010, UC-011, UC-012 tạo, use case này chỉ đọc qua entity Ticket | Chỉ hiển thị tên lúc bán lưu trên vé (BR-140). |
| 12 | ghế | 5; Dữ liệu ra 2 | Loại - khái niệm do UC-012 tạo, use case này chỉ đọc qua entity Ticket | Chỉ hiển thị vị trí và loại ghế đã ghi trên vé. |
| 13 | lần giữ ghế | Mục 8 | Loại - không tham gia hành vi của use case này | Khái niệm của UC-005; lần giữ ghế không dẫn tới lần đặt không nằm trong lịch sử. |
| 14 | vé mua tại quầy | Mục 8; GL-64 | Loại - là tác nhân hoặc ngoài phạm vi | Không gắn với tài khoản khách nào, không nằm trong lịch sử. |
| 15 | thứ tự hiển thị | Mục 8 | Loại - giá trị suy ra từ Booking | Sắp theo thời điểm đặt của lần đặt (bookedAt) khi hiển thị, không lưu thứ tự. |
| 16 | phiên làm việc, đăng nhập | Tiền điều kiện | Loại - cấu trúc cài đặt | Đăng nhập không là use case (hồ sơ dự án Mục 4); control xác định khách của phiên. |
| 17 | thông báo, quy tắc bị vi phạm | 2a, 4a | Loại - dữ liệu trao đổi qua boundary ViewBookingHistoryForm | Hiển thị, không lưu. |
| 18 | email chứa vé, dịch vụ email | Mục 8; BR-89 | Loại - không tham gia hành vi của use case này | Khái niệm của UC-005. |
| 19 | hệ thống, thông tin, dữ liệu | Nhiều bước | Loại - mơ hồ | Không là khái niệm nghiệp vụ cụ thể. |

### 3.3 Bảng control

| Control | Use case điều phối | Mới hoặc tái dùng | Lý do (hoặc lý do không có control) |
|---|---|---|---|
| ViewBookingHistoryController | UC-007 | Mới (AC-C-ViewBookingHistoryController) | Một control cho use case: xác định khách của phiên, điều phối hiển thị danh sách lần đặt, kiểm tra quyền xem và hiển thị vé. Quy tắc BR-94 nằm ở Customer. Có 2 trách nhiệm. |

### 3.4 Bảng lớp phân tích

| AC | Stereotype | Tên | Trách nhiệm | Thuộc tính chính | Bước UC nguồn | Loại boundary | Mới hoặc tái dùng | GL |
|---|---|---|---|---|---|---|---|---|
| AC-B-ViewBookingHistoryForm | boundary | ViewBookingHistoryForm | // requestBookingHistory: khách yêu cầu xem lịch sử đặt vé<br>// showNoBooking: thông báo khách chưa có lần đặt vé nào<br>// showBookingHistory: hiển thị các lần đặt của khách<br>// selectBooking: khách chọn một lần đặt cần xem<br>// rejectBookingView: thông báo từ chối hiển thị kèm quy tắc bị vi phạm<br>// showBookingTickets: hiển thị các vé của lần đặt đã chọn | selectedBookingCode (Mã đặt vé) | 1, 2, 3, 5, 2a, 4a | Giao diện người dùng | Mới | GL-18 |
| AC-C-ViewBookingHistoryController | control | ViewBookingHistoryController | // startViewHistory: điều phối bước 2 và 2a: xác định khách của phiên, hỏi khách có lần đặt nào chưa, lấy các lần đặt để hiển thị<br>// viewBookingTickets: điều phối bước 4, 5, 4a: hỏi khách có sở hữu lần đặt đã chọn không, lấy các vé của lần đặt để hiển thị hoặc từ chối | - | 2, 4, 5, 2a, 4a | - | Mới | - |
| AC-E-Customer | entity | Customer | // checkHasBookings: kiểm tra khách đã có lần đặt vé nào chưa<br>// provideBookingHistory: duyệt các lần đặt của khách từ gần nhất trước, lấy tóm tắt của từng lần đặt (BR-94)<br>// checkOwnsBooking: kiểm tra lần đặt có mã đặt vé đã chọn thuộc các lần đặt của khách (BR-94) | - (email, phoneNumber, password đã có ở UC-005, không dùng ở use case này) | 2, 4, 2a, 4a | - | Tái dùng từ UC-005, UC-006, bổ sung trách nhiệm; chủ sở hữu UC-001 | GL-18 |
| AC-E-Booking | entity | Booking | // provideBookingSummary: cung cấp mã đặt vé, số vé (đếm các vé của lần đặt) và tên phim, tên cụm rạp, ngày giờ bắt đầu lấy từ một vé của lần đặt<br>// provideBookingHistoryDetail: cung cấp mã đặt vé và nội dung từng vé của lần đặt kèm mã QR và trạng thái | bookedAt (Ngày giờ) (mới ở UC này) | 2, 5 | - | Tái dùng từ UC-005, UC-008, bổ sung trách nhiệm | GL-24, GL-28 |
| AC-E-Ticket | entity | Ticket | // provideTicketSummary: cung cấp tên phim, tên cụm rạp theo vé lúc bán và ngày giờ bắt đầu của suất chiếu (BR-140)<br>// provideTicketForHistory: cung cấp nội dung vé kèm mã QR và trạng thái: tên phim, định dạng, cụm rạp, phòng và loại phòng, ngày giờ bắt đầu, vị trí ghế, loại ghế, giá vé (BR-140, REQ-105) | movieTitle (Văn bản) (mới ở UC này), cinemaName (Văn bản) (mới ở UC này), auditoriumName (Văn bản) (mới ở UC này), auditoriumType (Văn bản) (mới ở UC này) | 2, 5 | - | Tái dùng từ UC-005, UC-008, UC-009, bổ sung trách nhiệm | GL-59, GL-60, GL-61, GL-65 |
| AC-E-Showtime | entity | Showtime | // provideShowtimeSchedule: cung cấp định dạng phim và ngày giờ bắt đầu của suất chiếu | startTime (Ngày giờ), movieFormat (Văn bản) | 2, 5 | - | Tái dùng từ UC-005, UC-009, UC-014, bổ sung trách nhiệm | GL-47 |

Tổng cộng 6 lớp: 1 boundary, 1 control, 4 entity. Không có entity cốt lõi của chủ đề race condition: use case chỉ đọc.

## 4. Phân bổ hành vi

| Bước UC | Trách nhiệm | Lớp nhận (AC) | Nguyên tắc | Lý do khi có lựa chọn khác |
|---|---|---|---|---|
| 1 | // requestBookingHistory | AC-B-ViewBookingHistoryForm | Giao tiếp tác nhân | - |
| 2 | // startViewHistory | AC-C-ViewBookingHistoryController | Controller | - |
| 2, 2a | // checkHasBookings | AC-E-Customer | Information Expert | Các lần đặt của khách gắn với khách (BR-94). Đếm hoặc kiểm tập mà Customer nắm là một trách nhiệm của Customer, không gửi message tới từng Booking (A6 b). |
| 2 | // provideBookingHistory | AC-E-Customer | Information Expert | Việc liệt kê để hiển thị cần dữ liệu riêng từng lần đặt nên giao cho đối tượng toàn thể nắm tập (Customer), gửi message tới từng Booking trong loop [mỗi lần đặt của khách] (A6). Giao cho control thì control lặp thay đối tượng toàn thể và phải biết các lần đặt của khách (Q-226). |
| 2 | // provideBookingSummary | AC-E-Booking | Information Expert | Số vé là việc đếm trên tập vé mà Booking nắm (A6 b); mã đặt vé là dữ liệu của Booking. |
| 2 | // provideTicketSummary | AC-E-Ticket | Information Expert | Tên phim và tên cụm rạp lúc bán nằm ở vé (BR-140). Mọi vé của một lần đặt cùng suất chiếu và cùng thông tin lúc bán (GL-24, BR-07) nên một vé đại diện đủ cho tóm tắt. Booking không giữ các tên này nên không tự trả lời. |
| 2, 5 | // provideShowtimeSchedule | AC-E-Showtime | Information Expert | Định dạng phim và giờ bắt đầu là dữ liệu của suất chiếu, vé hỏi suất chiếu qua quan hệ cấu trúc (R-UC005-19). Đặt tên khác // provideShowtimeForChecking (UC-009) và // provideShowtimeInfo (UC-014) vì nội dung cung cấp khác. |
| 2 | // showBookingHistory | AC-B-ViewBookingHistoryForm | Giao tiếp tác nhân | - |
| 2a | // showNoBooking | AC-B-ViewBookingHistoryForm | Giao tiếp tác nhân | - |
| 3 | // selectBooking | AC-B-ViewBookingHistoryForm | Giao tiếp tác nhân | - |
| 4, 5 | // viewBookingTickets | AC-C-ViewBookingHistoryController | Controller | - |
| 4, 4a | // checkOwnsBooking | AC-E-Customer | Information Expert | Điều kiện "lần đặt thuộc khách" định nghĩa ở một nơi là Customer (BR-94), vì Customer nắm tập lần đặt của khách. Đặt ở Booking thì Booking phải biết khách của phiên; đặt ở control thì control tự tính quy tắc. |
| 4a | // rejectBookingView | AC-B-ViewBookingHistoryForm | Giao tiếp tác nhân | Quy tắc BR-94 truyền như dữ liệu. |
| 5 | // provideBookingHistoryDetail | AC-E-Booking | Information Expert | Các vé của lần đặt do Booking nắm (R-UC005-18); gửi message tới từng Ticket trong loop [mỗi vé của lần đặt] vì cần dữ liệu riêng từng vé. Đặt tên khác // provideBookingInfo (UC-005, UC-008) vì thêm mã QR và trạng thái. |
| 5 | // provideTicketForHistory | AC-E-Ticket | Information Expert | Nội dung vé thuộc vé. Đặt tên khác // provideTicketContent (UC-005, UC-008, UC-009) vì thêm mã QR và trạng thái, và lấy tên theo vé lúc bán. |
| 5 | // showBookingTickets | AC-B-ViewBookingHistoryForm | Giao tiếp tác nhân | - |

Thao tác nguyên tử của P04 (00-Concurrency.md M3 mục 1): Không có. Use case chỉ đọc (P04 Mục 8); trạng thái vé do UC-008, UC-009 đặt được đọc tại lúc hiển thị.

## 5. Sequence diagram phân tích

File diagrams/P07-sequence-UC-007.drawio, 1 trang. Số message không kể trả về: SD1 17. Luồng 2a kết thúc use case nên dùng break ở mức ngoài cùng; luồng 4a quay lại bước 3 nên dùng alt. Ba fragment ở mức ngoài cùng: break F1, loop F2, alt F3; loop F4 lồng trong toán hạng 2 của F3.

### SD1 - Luồng chính và luồng 2a, 4a

Luồng 2a kết thúc use case nên vẽ bằng break ở mức ngoài cùng; luồng 4a quay lại bước 3 nên vẽ bằng alt, toán hạng luồng chính chỉ ghi guard. Khách của phiên làm việc đã đăng nhập (tiền điều kiện) được control xác định, lifeline :Customer là khách đó. Tìm lần đặt theo mã đặt vé coi là có sẵn (A6 a).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1-L-KH | Actor | :Khách | - | - | Tác nhân (ACT-01) |
| SD1-L-FM | Lifeline | :ViewBookingHistoryForm | «boundary» | - | AC-B-ViewBookingHistoryForm |
| SD1-L-CT | Lifeline | :ViewBookingHistoryController | «control» | - | AC-C-ViewBookingHistoryController |
| SD1-L-CU | Lifeline | :Customer | «entity» | - | AC-E-Customer; khách của phiên làm việc |
| SD1-L-BK | Lifeline | :Booking | «entity» | - | AC-E-Booking |
| SD1-L-TK | Lifeline | :Ticket | «entity» | - | AC-E-Ticket |
| SD1-L-ST | Lifeline | :Showtime | «entity» | - | AC-E-Showtime |
| SD1-F1 | Fragment | break [khách chưa có lần đặt vé nào (2a)] | - | - | mức ngoài cùng |
| SD1-F2 | Fragment | loop [mỗi lần đặt của khách, từ lần đặt gần nhất trước] | - | - | mức ngoài cùng |
| SD1-F3 | Fragment | alt [lần đặt đã chọn không thuộc khách (4a)] | - | - | mức ngoài cùng |
| SD1-F3-O2 | Fragment | [lần đặt đã chọn thuộc khách] | - | SD1-F3 | toán hạng 2 |
| SD1-F4 | Fragment | loop [mỗi vé của lần đặt] | - | SD1-F3-O2 | lồng trong SD1-F3-O2 |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1 | :Khách | :ViewBookingHistoryForm | // requestBookingHistory | Đồng bộ | - | 1 |
| 1.1 | :ViewBookingHistoryForm | :ViewBookingHistoryController | // startViewHistory | Đồng bộ | - | 2 |
| 1.1.1 | :ViewBookingHistoryController | :Customer | // checkHasBookings | Đồng bộ | - | 2 |
| 1.1.1 (trả về) | :Customer | :ViewBookingHistoryController | khách đã hoặc chưa có lần đặt vé nào | Trả về | - | 2 |
| 1.1.2 | :ViewBookingHistoryController | :ViewBookingHistoryForm | // showNoBooking | Đồng bộ | SD1-F1 | 2a |
| 1.1.3 | :ViewBookingHistoryController | :Customer | // provideBookingHistory | Đồng bộ | - | 2 |
| 1.1.3.1 | :Customer | :Booking | // provideBookingSummary | Đồng bộ | SD1-F2 | 2 |
| 1.1.3.1.1 | :Booking | :Ticket | // provideTicketSummary (một vé của lần đặt) | Đồng bộ | SD1-F2 | 2 |
| 1.1.3.1.1.1 | :Ticket | :Showtime | // provideShowtimeSchedule | Đồng bộ | SD1-F2 | 2 |
| 1.1.3.1.1.1 (trả về) | :Showtime | :Ticket | định dạng phim, ngày giờ bắt đầu | Trả về | SD1-F2 | 2 |
| 1.1.3.1.1 (trả về) | :Ticket | :Booking | tên phim, tên cụm rạp, ngày giờ bắt đầu | Trả về | SD1-F2 | 2 |
| 1.1.3.1 (trả về) | :Booking | :Customer | mã đặt vé, số vé, tên phim, tên cụm rạp, ngày giờ bắt đầu | Trả về | SD1-F2 | 2 |
| 1.1.3 (trả về) | :Customer | :ViewBookingHistoryController | các lần đặt của khách, lần đặt gần nhất trước | Trả về | - | 2 |
| 1.1.4 | :ViewBookingHistoryController | :ViewBookingHistoryForm | // showBookingHistory (các lần đặt của khách) | Đồng bộ | - | 2 |
| 2 | :Khách | :ViewBookingHistoryForm | // selectBooking (lần đặt cần xem) | Đồng bộ | - | 3 |
| 2.1 | :ViewBookingHistoryForm | :ViewBookingHistoryController | // viewBookingTickets (mã đặt vé đã chọn) | Đồng bộ | - | 4, 5 |
| 2.1.1 | :ViewBookingHistoryController | :Customer | // checkOwnsBooking (mã đặt vé đã chọn) | Đồng bộ | - | 4 |
| 2.1.1 (trả về) | :Customer | :ViewBookingHistoryController | lần đặt đã chọn thuộc hoặc không thuộc khách | Trả về | - | 4 |
| 2.1.2 | :ViewBookingHistoryController | :ViewBookingHistoryForm | // rejectBookingView (quy tắc BR-94) | Đồng bộ | SD1-F3 | 4a |
| 2.1.3 | :ViewBookingHistoryController | :Booking | // provideBookingHistoryDetail | Đồng bộ | SD1-F3-O2 | 5 |
| 2.1.3.1 | :Booking | :Ticket | // provideTicketForHistory | Đồng bộ | SD1-F4 | 5 |
| 2.1.3.1.1 | :Ticket | :Showtime | // provideShowtimeSchedule | Đồng bộ | SD1-F4 | 5 |
| 2.1.3.1.1 (trả về) | :Showtime | :Ticket | định dạng phim, ngày giờ bắt đầu | Trả về | SD1-F4 | 5 |
| 2.1.3.1 (trả về) | :Ticket | :Booking | nội dung vé kèm mã QR và trạng thái | Trả về | SD1-F4 | 5 |
| 2.1.3 (trả về) | :Booking | :ViewBookingHistoryController | mã đặt vé và nội dung các vé kèm mã QR và trạng thái | Trả về | SD1-F3-O2 | 5 |
| 2.1.4 | :ViewBookingHistoryController | :ViewBookingHistoryForm | // showBookingTickets (mã đặt vé, các vé của lần đặt) | Đồng bộ | SD1-F3-O2 | 5 |

## 6. Quy tắc tương tác giữa các lớp phân tích

| Vi phạm | Message hoặc link | Cách sửa đã áp dụng |
|---|---|---|
| Không có | - | - |

Ghi chú kiểm tra: Customer --> Booking (CM1-L4), Booking --> Ticket (CM1-L5), Ticket --> Showtime (CM1-L6) là entity gọi entity có quan hệ cấu trúc (R-UC007-04, R-UC007-05, R-UC007-06). Control gọi trực tiếp Customer và Booking (CM1-L3, CM1-L7); lần đặt đã chọn được tìm theo mã đặt vé (A6 a).

## 7. Communication diagram

File diagrams/P07-communication-UC-007.drawio, 1 trang CM1 gồm luồng chính và luồng 2a, 4a (MUC_CHI_TIET là DAY_DU), giữ STT của SD1.

### Trang CM1 - Luồng chính và luồng 2a, 4a (SD1)

Một trang cho mọi luồng (MUC_CHI_TIET là DAY_DU), giữ STT của SD1. Message trả về không vẽ.

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| CM1-O-KH | Actor | :Khách | - | - | Tác nhân (ACT-01) |
| CM1-O-FM | Object | :ViewBookingHistoryForm | «boundary» | - | AC-B-ViewBookingHistoryForm |
| CM1-O-CT | Object | :ViewBookingHistoryController | «control» | - | AC-C-ViewBookingHistoryController |
| CM1-O-CU | Object | :Customer | «entity» | - | AC-E-Customer; khách của phiên làm việc |
| CM1-O-BK | Object | :Booking | «entity» | - | AC-E-Booking |
| CM1-O-TK | Object | :Ticket | «entity» | - | AC-E-Ticket |
| CM1-O-ST | Object | :Showtime | «entity» | - | AC-E-Showtime |

b) Bảng Edge

| ID | Nguồn | Đích | Loại (Link) | Nhãn | Chiều message |
|---|---|---|---|---|---|
| CM1-L1 | CM1-O-KH | CM1-O-FM | Link | 1: // requestBookingHistory (-->)<br>2: // selectBooking (lần đặt cần xem) (-->) | Nguồn-->Đích: 1, 2 |
| CM1-L2 | CM1-O-FM | CM1-O-CT | Link | 1.1: // startViewHistory (-->)<br>1.1.2: // showNoBooking (<--) [khách chưa có lần đặt vé nào (2a)]<br>1.1.4: // showBookingHistory (các lần đặt của khách) (<--)<br>2.1: // viewBookingTickets (mã đặt vé đã chọn) (-->)<br>2.1.2: // rejectBookingView (quy tắc BR-94) (<--) [lần đặt đã chọn không thuộc khách (4a)]<br>2.1.4: // showBookingTickets (mã đặt vé, các vé của lần đặt) (<--) [lần đặt đã chọn thuộc khách] | Nguồn-->Đích: 1.1, 2.1; Đích-->Nguồn: 1.1.2, 1.1.4, 2.1.2, 2.1.4 |
| CM1-L3 | CM1-O-CT | CM1-O-CU | Link | 1.1.1: // checkHasBookings (-->)<br>1.1.3: // provideBookingHistory (-->)<br>2.1.1: // checkOwnsBooking (mã đặt vé đã chọn) (-->) | Nguồn-->Đích: 1.1.1, 1.1.3, 2.1.1 |
| CM1-L4 | CM1-O-CU | CM1-O-BK | Link | 1.1.3.1: // provideBookingSummary (-->) [lặp: mỗi lần đặt của khách, từ lần đặt gần nhất trước] | Nguồn-->Đích: 1.1.3.1 |
| CM1-L5 | CM1-O-BK | CM1-O-TK | Link | 1.1.3.1.1: // provideTicketSummary (một vé của lần đặt) (-->) [lặp: mỗi lần đặt của khách, từ lần đặt gần nhất trước]<br>2.1.3.1: // provideTicketForHistory (-->) [lặp: mỗi vé của lần đặt] | Nguồn-->Đích: 1.1.3.1.1, 2.1.3.1 |
| CM1-L6 | CM1-O-TK | CM1-O-ST | Link | 1.1.3.1.1.1: // provideShowtimeSchedule (-->) [lặp: mỗi lần đặt của khách, từ lần đặt gần nhất trước]<br>2.1.3.1.1: // provideShowtimeSchedule (-->) [lặp: mỗi vé của lần đặt] | Nguồn-->Đích: 1.1.3.1.1.1, 2.1.3.1.1 |
| CM1-L7 | CM1-O-CT | CM1-O-BK | Link | 2.1.3: // provideBookingHistoryDetail (-->) [lần đặt đã chọn thuộc khách] | Nguồn-->Đích: 2.1.3 |

## 8. VOPC

File diagrams/P07-class-UC-007.drawio. ID cell của lớp là mã AC; ngăn thuộc tính và ngăn trách nhiệm có ID "<mã AC>-ATTR" và "<mã AC>-RESP".

a) Bảng Node (lớp)

| ID (mã AC) | Loại (Class) | Nhãn (tên lớp) | Stereotype | Thuộc về | Ngăn thuộc tính | Ngăn trách nhiệm |
|---|---|---|---|---|---|---|
| AC-B-ViewBookingHistoryForm | Class | ViewBookingHistoryForm | «boundary» | - | selectedBookingCode (Mã đặt vé) | // requestBookingHistory<br>// showNoBooking<br>// showBookingHistory<br>// selectBooking<br>// rejectBookingView<br>// showBookingTickets |
| AC-C-ViewBookingHistoryController | Class | ViewBookingHistoryController | «control» | - | - | // startViewHistory<br>// viewBookingTickets |
| AC-E-Customer | Class | Customer | «entity» | - | email (Văn bản)<br>phoneNumber (Văn bản)<br>password (Văn bản) | // checkHasBookings<br>// provideBookingHistory<br>// checkOwnsBooking |
| AC-E-Booking | Class | Booking | «entity» | - | bookingCode (Văn bản)<br>bookedAt (Ngày giờ) (mới ở UC này) | // provideBookingSummary<br>// provideBookingHistoryDetail |
| AC-E-Ticket | Class | Ticket | «entity» | - | ticketCode (Văn bản)<br>qrCode (Hình ảnh)<br>seatPosition (Mã hàng, số ghế)<br>seatType (Văn bản)<br>price (Số tiền)<br>status (Trạng thái)<br>movieTitle (Văn bản) (mới ở UC này)<br>cinemaName (Văn bản) (mới ở UC này)<br>auditoriumName (Văn bản) (mới ở UC này)<br>auditoriumType (Văn bản) (mới ở UC này) | // provideTicketSummary<br>// provideTicketForHistory |
| AC-E-Showtime | Class | Showtime | «entity» | - | startTime (Ngày giờ)<br>movieFormat (Văn bản) | // provideShowtimeSchedule |

b) Bảng quan hệ

| ID | Lớp A | Lớp B | Loại | Multiplicity | Vai trò | Nguồn |
|---|---|---|---|---|---|---|
| R-UC007-01 | AC-B-ViewBookingHistoryForm | AC-C-ViewBookingHistoryController | Association | - | - | tạm thời; link F7: CM1-L2 |
| R-UC007-02 | AC-C-ViewBookingHistoryController | AC-E-Customer | Association | - | - | tạm thời; link F7: CM1-L3 |
| R-UC007-03 | AC-C-ViewBookingHistoryController | AC-E-Booking | Association | - | - | tạm thời; link F7: CM1-L7 |
| R-UC007-04 | AC-E-Customer | AC-E-Booking | Association | A 1 - B 0..* | - | Khách chỉ xem các lần đặt của chính mình (BR-94, GL-24); lần đặt của khách đi qua người giữ ghế của lần giữ ghế (R-UC005-14, R-UC005-17), xem Q-226; link F7: CM1-L4 |
| R-UC007-05 | AC-E-Booking | AC-E-Ticket | Aggregation | A 1 - B 1..8 | - | Lần đặt gồm mỗi ghế một vé, tối đa 8 ghế (GL-24, BR-05); cùng quan hệ R-UC005-18; link F7: CM1-L5 |
| R-UC007-06 | AC-E-Ticket | AC-E-Showtime | Association | A 0..* - B 1 | - | Vé thuộc đúng một ghế của một suất chiếu (GL-59); cùng quan hệ R-UC005-19; link F7: CM1-L6 |

Link CM1-L1 là actor - boundary nên không vào VOPC.

## 9. Ma trận truy vết

| Bước UC | Message (STT) | Lớp tham gia (AC) |
|---|---|---|
| 1 | 1 | Khách, AC-B-ViewBookingHistoryForm |
| 2 | 1.1, 1.1.1, 1.1.1 (trả về), 1.1.3, 1.1.3.1, 1.1.3.1.1, 1.1.3.1.1.1, 1.1.3.1.1.1 (trả về), 1.1.3.1.1 (trả về), 1.1.3.1 (trả về), 1.1.3 (trả về), 1.1.4 | AC-B-ViewBookingHistoryForm, AC-C-ViewBookingHistoryController, AC-E-Customer, AC-E-Booking, AC-E-Ticket, AC-E-Showtime |
| 3 | 2 | Khách, AC-B-ViewBookingHistoryForm |
| 4 | 2.1, 2.1.1, 2.1.1 (trả về) | AC-B-ViewBookingHistoryForm, AC-C-ViewBookingHistoryController, AC-E-Customer |
| 5 | 2.1, 2.1.3, 2.1.3.1, 2.1.3.1.1, 2.1.3.1.1 (trả về), 2.1.3.1 (trả về), 2.1.3 (trả về), 2.1.4 | AC-C-ViewBookingHistoryController, AC-E-Booking, AC-E-Ticket, AC-E-Showtime, AC-B-ViewBookingHistoryForm |
| 2a | 1.1.2 | AC-C-ViewBookingHistoryController, AC-B-ViewBookingHistoryForm |
| 4a | 2.1.2 | AC-C-ViewBookingHistoryController, AC-B-ViewBookingHistoryForm |

## 10. File .drawio

Ba file nằm trong diagrams/: P07-sequence-UC-007.drawio (1 trang), P07-communication-UC-007.drawio (1 trang), P07-class-UC-007.drawio (1 trang). XML không nén, ID cell trùng ID trong bảng mô hình.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Người quyết | Đề xuất |
|---|---|---|---|---|---|
| Q-226 | Lần đặt gắn với khách qua người giữ ghế của lần giữ ghế (R-UC005-14, R-UC005-17), nhưng UC-007 duyệt và kiểm tra theo khách (BR-94). Mô hình có quan hệ trực tiếp Customer - Booking, hay chỉ đi qua SeatHold và để SeatHold nắm các lần đặt của khách? | R-UC007-04; AC-E-Customer (// checkHasBookings, // provideBookingHistory, // checkOwnsBooking); P08 | P04 BR-94 nêu "lịch sử của chính mình" mà không nêu quan hệ giữa khách và lần đặt; GL-24, GL-25 chỉ nêu Lần đặt là kết quả của Lần giữ ghế | Nhóm dự án | Thêm quan hệ Customer 1 - Booking 0..* ở P08, dẫn xuất từ người giữ ghế của lần giữ ghế; Customer nắm tập lần đặt của khách |
| Q-227 | Vé đã huỷ thuộc suất chiếu sau đó được sửa (suất chiếu không còn vé chưa huỷ nên sửa được, BR-53). Lịch sử hiển thị định dạng phim và ngày giờ bắt đầu theo suất chiếu hiện hành, hay theo giá trị lúc bán như tên phim, cụm rạp, phòng chiếu (BR-140)? | AC-E-Ticket, AC-E-Showtime (// provideShowtimeSchedule); SD1 message 1.1.3.1.1.1, 2.1.3.1.1; BR-140 | BR-140 chỉ nêu bốn thông tin giữ giá trị lúc bán, không nêu định dạng phim và ngày giờ bắt đầu | Bên nghiệp vụ | Giữ như BR-140: chỉ bốn thông tin trên lấy theo vé; định dạng và ngày giờ bắt đầu đọc từ suất chiếu hiện hành. Nếu bên nghiệp vụ muốn lịch sử không đổi thì Ticket giữ thêm hai thông tin này và bỏ message tới Showtime |

## Giả định

Không có (chế độ NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P07 | UC-005 bước 13 (AC-E-Ticket // createTicket, AC-E-Booking // createBooking) | UC-007 cần vé giữ tên phim, tên cụm rạp, tên phòng chiếu, loại phòng lúc bán (BR-140) và lần đặt giữ thời điểm đặt để xếp lần đặt gần nhất trước | Ghi bốn thông tin lúc bán lên vé khi tạo vé, ghi thời điểm đặt khi tạo lần đặt |
| P08 | AC-E-Customer, AC-E-Booking, AC-E-Ticket, AC-E-Showtime | Thêm trách nhiệm và thuộc tính của UC-007; thiếu quan hệ Customer - Booking (Q-226) | Thêm // checkHasBookings, // provideBookingHistory, // checkOwnsBooking vào Customer; // provideBookingSummary, // provideBookingHistoryDetail và bookedAt vào Booking; // provideTicketSummary, // provideTicketForHistory và bốn thuộc tính lúc bán vào Ticket; // provideShowtimeSchedule vào Showtime; thêm quan hệ Customer 1 - Booking 0..* |
| P04 | UC-007 bước 2, Dữ liệu ra 1 | Thứ tự lần đặt gần nhất trước chỉ nằm ở Mục 8, Dữ liệu ra 1 không có thời điểm đặt | Ghi thứ tự hiển thị vào bước 2 hoặc Dữ liệu ra 1 |

## Vấn đề còn mở

- Số lớp là 6, trong khoảng 4-12. Entity Customer, Booking, Ticket, Showtime tái dùng từ UC-005.
- Mọi message của use case là đọc; không có thao tác nguyên tử (M3 mục 1 không áp dụng). Trạng thái vé do UC-008, UC-009 đổi nên vé vừa huỷ hoặc vừa soát hiện ở lần xem sau, không cần loại trừ.
- Customer có 3 trách nhiệm, Booking 2, Ticket 2, Showtime 1; Showtime và Ticket chủ yếu cung cấp dữ liệu, đặc tả không có hành vi nào khác trên dữ liệu đó. Entity Customer có hành vi kiểm tra (// checkOwnsBooking, // checkHasBookings).
- Tóm tắt của một lần đặt lấy tên phim và cụm rạp từ một vé bất kỳ của lần đặt (// provideTicketSummary). Cách này dựa trên việc mọi vé của một lần đặt cùng suất chiếu và cùng thông tin lúc bán (GL-24, BR-07). P08 xem xét Booking giữ trực tiếp các thông tin này nếu muốn bỏ message qua Ticket.
- Tên phim, cụm rạp, phòng chiếu và loại phòng lấy từ Ticket (BR-140); định dạng phim và ngày giờ bắt đầu lấy từ Showtime theo đặc tả hiện hành (Q-227).
- Quan hệ Customer - Booking trong R-UC007-04 là dẫn xuất từ người giữ ghế của lần giữ ghế (Q-226); P08 chốt cách biểu diễn.
- Việc xếp lần đặt gần nhất trước dùng thuộc tính bookedAt của Booking, thêm theo ghi chú ở P04 Mục 8; nếu P04 không giữ thứ tự này thì bỏ thuộc tính.
- Control xác định khách của phiên làm việc (tiền điều kiện đăng nhập) nên lifeline :Customer là khách đó và không có message xác thực.
