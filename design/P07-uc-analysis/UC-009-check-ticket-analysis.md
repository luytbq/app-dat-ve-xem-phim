# P07 - Phân tích use case UC-009 Soát vé - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P07 |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md; P04-uc-specs/UC-009-check-ticket.md 1.4; P01-actors.md 1.1; P02-usecases.md; P03-usecase-model.md 1.0; P05-glossary.md 1.1; P06-supplementary-spec.md; P04-uc-specs/_BR-register.md; P07-uc-analysis/UC-005-book-tickets-analysis.md 1.0 (sổ đăng ký AC: F1, F3.4, F8 b), Câu hỏi mở, Vấn đề còn mở) |
| Phạm vi | UC-009 |
| Mã Q, ASM cuối đã cấp | Q-97; không có ASM (NGHIEM_NGAT) |

## 1. Bối cảnh use case

| Thuộc tính | Giá trị |
|---|---|
| Mã và tên UC | UC-009 Soát vé (Check Ticket) |
| Tác nhân chính | ACT-03 Nhân viên soát vé (Người) |
| Tác nhân phụ | Không có. Camera của thiết bị là kênh nhập, không phải tác nhân (P01 A-T2, REQ-50) |
| Include (UC) | Không có |
| Được include bởi (UC) | Không có |
| Extend (UC, điểm mở rộng, điều kiện) | Không có |
| Được extend bởi (UC, điểm mở rộng, điều kiện) | Không có |
| Use case liên quan không qua include, extend | UC-008 Huỷ vé: kiểm tra và ghi trạng thái vé ở bước 4, 5 của UC-009 và ở bước 4 của UC-008 loại trừ lẫn nhau trên cùng một vé, bên ghi nhận trước thắng (BR-30, REQ-118). UC-005 Đặt vé tạo vé (REQ-30, REQ-105). UC-017 sở hữu nhân viên soát vé. UC-014 sở hữu suất chiếu |
| Tác nhân thời gian | Không có. P02 không có use case do tác nhân thời gian kích hoạt trên vé hoặc suất chiếu đang soát (P04 Mục 8), nên không có message hẹn mốc |
| File P07 đã có được dùng làm sổ đăng ký AC | UC-005-book-tickets-analysis.md. Tái dùng AC-E-Showtime, AC-E-Ticket, AC-E-Booking. Các file P07 khác chạy song song không đọc |

## 2. Đặc tả bổ sung

| Bước UC | Thực hiện bởi | Mô tả trong đặc tả | Mô tả bổ sung (hệ thống làm gì bên trong) | Nguồn (BR, GL, REQ) |
|---|---|---|---|---|
| 1 | Nhân viên soát vé | Chọn suất chiếu đang soát trong các suất chiếu của cụm rạp mình | Không đổi | BR-34, GL-48, REQ-93, REQ-123 |
| 2 | Hệ thống | Ghi nhận suất chiếu đã chọn là suất chiếu đang soát và hiển thị thông tin suất chiếu | Nhân viên soát vé của phiên làm việc kiểm tra suất chiếu đã chọn thuộc cụm rạp của mình rồi ghi nhận làm suất chiếu đang soát, áp dụng cho các vé quét liên tiếp tới khi chọn lại. Hệ thống lấy từ suất chiếu phim, định dạng, phòng chiếu, ngày giờ bắt đầu và hiển thị. | BR-34, GL-48, Dữ liệu ra 1, Q-95, Q-96, Q-97 |
| 3 | Nhân viên soát vé | Quét mã QR trên vé của khách bằng camera của thiết bị | Không đổi | REQ-50, Dữ liệu vào 2 |
| 4 | Hệ thống | Kiểm tra mã QR tương ứng với một vé, vé thuộc cụm rạp của nhân viên soát vé, vé thuộc suất chiếu đang soát, vé chưa sử dụng và vé chưa huỷ | Hệ thống lấy cụm rạp và suất chiếu đang soát của nhân viên soát vé, xác định vé từ mã QR. Vé kiểm tra theo thứ tự cụm rạp của suất chiếu của vé, suất chiếu của vé, trạng thái đã sử dụng, trạng thái đã huỷ và dừng ở điều kiện đầu tiên vi phạm. Kiểm tra và bước 5 là một thao tác không chia cắt trên chính vé đó. | BR-22, BR-23, BR-24, BR-25, BR-30, BR-33, REQ-128 |
| 5 | Hệ thống | Đánh dấu vé đã sử dụng | Khi vé qua cả bốn điều kiện, chính vé chuyển trạng thái từ chưa sử dụng sang đã sử dụng trong cùng thao tác với bước 4, để hai nhân viên cùng quét một vé chỉ một người thành công và việc huỷ vé cùng lúc ở UC-008 bị loại trừ. | BR-24, BR-30, REQ-52, GL-61 |
| 6 | Hệ thống | Thông báo vé hợp lệ cho nhân viên soát vé và hiển thị thông tin vé | Hệ thống lấy nội dung vé: mã đặt vé từ lần đặt chứa vé, thông tin suất chiếu, vị trí ghế, loại ghế, giá vé; hiển thị trừ mã QR. | REQ-105, REQ-127, Dữ liệu ra 2, GL-62 |
| 7 | Nhân viên soát vé | Lặp lại bước 3-6 cho đến khi không còn vé cần soát của suất chiếu đang soát | Không đổi | REQ-123, BR-34 |
| 4a | Hệ thống | Từ chối cho vào và báo lý do: mã QR không tương ứng vé | Không xác định được vé từ mã QR thì không có vé để kiểm tra tiếp; hệ thống báo lý do này và không đổi trạng thái nào. | REQ-94, REQ-51, Dữ liệu ra 3 |
| 4b | Hệ thống | Từ chối cho vào và báo lý do: vé thuộc cụm rạp khác | Cụm rạp của suất chiếu của vé khác cụm rạp của nhân viên soát vé; báo lý do này, vé không đổi trạng thái. | BR-22, BR-33 |
| 4c | Hệ thống | Từ chối cho vào và báo lý do: vé thuộc suất chiếu khác | Vé cùng cụm rạp nhưng suất chiếu của vé khác suất chiếu đang soát; báo lý do này, vé không đổi trạng thái. | BR-23, BR-33 |
| 4d | Hệ thống | Từ chối cho vào và báo lý do: vé đã sử dụng | Trạng thái vé là đã sử dụng, kể cả khi nhân viên soát vé khác vừa soát chính vé đó; báo lý do này, vé không đổi trạng thái. | BR-24, BR-30, BR-33 |
| 4e | Hệ thống | Từ chối cho vào và báo lý do: vé đã huỷ | Trạng thái vé là đã huỷ, kể cả khi vé vừa huỷ ở UC-008; báo lý do này, vé không đổi trạng thái. | BR-25, BR-30, BR-33 |

## 3. Tìm lớp phân tích

### 3.1 Bảng boundary

| Tác nhân (ACT) | Loại tác nhân | Boundary | Loại boundary | Mới hoặc tái dùng (AC, UC nguồn) | Lý do |
|---|---|---|---|---|---|
| ACT-03 Nhân viên soát vé | Người | CheckTicketForm | Giao diện người dùng | Mới (AC-B-CheckTicketForm) | Nhân viên soát vé chọn suất chiếu đang soát, quét mã QR và nhận kết quả hợp lệ hoặc lý do từ chối. Camera của thiết bị là kênh nhập của nhân viên soát vé nên thao tác quét đi qua chính boundary này, không có boundary thiết bị. |

Số boundary là 1, bằng số tác nhân tham gia (không có tác nhân phụ, không có tác nhân thời gian).

### 3.2 Bảng lọc danh từ

| STT | Danh từ hoặc cụm danh từ | Vị trí (bước UC, mục dữ liệu, BR) | Kết luận | Lý do |
|---|---|---|---|---|
| 1 | nhân viên soát vé | 1, 3, 7; BR-22, BR-34 | Entity AC-E-TicketChecker | Thông tin về tác nhân, không phải tác nhân: hệ thống biết cụm rạp của nhân viên (BR-78) và suất chiếu đang soát của nhân viên (GL-36, GL-48). |
| 2 | suất chiếu | 1, 2, 4; BR-23 | Entity AC-E-Showtime | Hệ thống lưu; có hành vi kiểm tra thuộc cụm rạp và cung cấp thông tin hiển thị (GL-47). |
| 3 | suất chiếu đang soát | 1, 2, 7; BR-23, BR-34; Dữ liệu vào 1 | Loại - thuộc tính của TicketChecker | Suất chiếu mà nhân viên đã chọn, giữ qua các lần quét (GL-48); Q-97. |
| 4 | cụm rạp | 1, 4; BR-22, BR-34 | Loại - khái niệm do UC-011 tạo, use case này chỉ đọc qua entity Showtime | Chỉ cần để so cụm rạp của suất chiếu với cụm rạp của nhân viên soát vé; thuộc tính cinema của Showtime và TicketChecker (Q-81 của UC-005). |
| 5 | phim, định dạng phim, tên phim | Dữ liệu ra 1, 2 | Loại - khái niệm do UC-010 tạo, use case này chỉ đọc qua entity Showtime | Chỉ hiển thị; đọc qua Showtime (movieTitle, movieFormat). |
| 6 | phòng chiếu, loại phòng | Dữ liệu ra 1, 2 | Loại - khái niệm do UC-012 tạo, use case này chỉ đọc qua entity Showtime | Chỉ hiển thị; đọc qua Showtime (auditoriumName, auditoriumType). |
| 7 | ngày giờ bắt đầu, giờ bắt đầu | Dữ liệu ra 1, 2; BR-83 | Loại - thuộc tính của Showtime | GL-14. BR-83 không giới hạn thời điểm soát nên giờ bắt đầu không được dùng để kiểm tra. |
| 8 | vé | 3, 4, 5, 6, 4a đến 4e | Entity AC-E-Ticket | Có trạng thái (chưa sử dụng, đã sử dụng, đã huỷ) và hành vi kiểm tra điều kiện soát, đánh dấu đã sử dụng (GL-59). |
| 9 | mã QR | 3, 4, 4a; Dữ liệu vào 2 | Loại - thuộc tính của Ticket | Hình mã hoá của mã vé; mã QR quét vào là dữ liệu trao đổi qua boundary CheckTicketForm để xác định vé (GL-30, REQ-128). |
| 10 | vé chưa sử dụng, vé đã sử dụng, vé đã huỷ, vé hợp lệ | 4, 5, 4d, 4e; BR-24, BR-25 | Loại - thuộc tính của Ticket | Giá trị trạng thái và kết quả kiểm tra của Ticket (GL-60, GL-61, GL-62, GL-65). |
| 11 | lần đặt, mã đặt vé | 6; Dữ liệu ra 2 | Entity AC-E-Booking | Lần đặt chứa vé nắm mã đặt vé hiển thị trên vé (GL-24, GL-28); mã đặt vé là thuộc tính của Booking. |
| 12 | vị trí ghế, loại ghế, giá vé | 6; Dữ liệu ra 2 | Loại - thuộc tính của Ticket | Vé giữ vị trí ghế, loại ghế và giá đã ghi (R-UC005 Ticket). |
| 13 | ghế | 6 | Loại - khái niệm do UC-012 tạo, use case này chỉ đọc qua entity Ticket | Chỉ hiển thị vị trí và loại ghế đã ghi trên vé. |
| 14 | khách | Sự kiện kích hoạt, 3 | Loại - là tác nhân hoặc ngoài phạm vi | ACT-01 chỉ mang vé tới cửa phòng chiếu, không tương tác với hệ thống ở use case này. |
| 15 | camera, thiết bị | 3; Dữ liệu vào 2 | Loại - là tác nhân hoặc ngoài phạm vi | Kênh nhập gắn liền thiết bị soát vé (P01 A-T2, REQ-50). |
| 16 | lý do vé không hợp lệ | 4a đến 4e; Dữ liệu ra 3 | Loại - dữ liệu trao đổi qua boundary CheckTicketForm | Một trong năm lý do theo BR-33, không lưu. |
| 17 | thông tin vé, thông tin suất chiếu, nội dung vé | 2, 6; Dữ liệu ra 1, 2 | Loại - dữ liệu trao đổi qua boundary CheckTicketForm | Tập hợp các thuộc tính đã nêu ở dòng 5 đến 12, hiển thị không lưu. |
| 18 | thứ tự điều kiện, điều kiện soát | 4; BR-33 | Loại - tham số của quy tắc BR-33 | Thứ tự cụm rạp, suất chiếu, đã sử dụng, đã huỷ nằm trong quy tắc. |
| 19 | phiên làm việc, đăng nhập | Tiền điều kiện | Loại - cấu trúc cài đặt | Đăng nhập không là use case (hồ sơ dự án Mục 4); control xác định nhân viên của phiên. |
| 20 | việc huỷ vé, hoàn tiền | Mục 8; BR-30 | Loại - không tham gia hành vi của use case này (khái niệm của UC-008) | UC-009 không thực hiện huỷ; chỉ phải loại trừ với việc huỷ trên cùng vé. |
| 21 | nhập tay | Mục 8; NFR-13 | Loại - không tham gia hành vi của use case này | Không có cách nhập tay (REQ-126). |
| 22 | hệ thống, thông báo, thao tác, điều kiện | Nhiều bước | Loại - mơ hồ | Không là khái niệm nghiệp vụ cụ thể. |

### 3.3 Bảng control

| Control | Use case điều phối | Mới hoặc tái dùng | Lý do (hoặc lý do không có control) |
|---|---|---|---|
| CheckTicketController | UC-009 | Mới (AC-C-CheckTicketController) | Một control cho use case: nhận sự kiện từ boundary, xác định nhân viên soát vé của phiên, điều phối chọn suất chiếu đang soát và kiểm tra từng vé. Mọi quy tắc soát nằm ở entity. Có 2 trách nhiệm. |

### 3.4 Bảng lớp phân tích

| AC | Stereotype | Tên | Trách nhiệm | Thuộc tính chính | Bước UC nguồn | Loại boundary | Mới hoặc tái dùng | GL |
|---|---|---|---|---|---|---|---|---|
| AC-B-CheckTicketForm | boundary | CheckTicketForm | // selectCheckingShowtime: nhân viên soát vé chọn suất chiếu đang soát<br>// showCheckingShowtime: hiển thị thông tin suất chiếu đang soát<br>// scanTicketQr: nhân viên soát vé quét mã QR trên vé bằng camera của thiết bị<br>// showValidTicket: thông báo vé hợp lệ và hiển thị nội dung vé trừ mã QR<br>// rejectTicket: thông báo từ chối cho vào kèm một lý do | scannedQr (Mã QR của vé) | 1, 2, 3, 6, 4a, 4b, 4c, 4d, 4e | Giao diện người dùng | Mới | GL-36 |
| AC-C-CheckTicketController | control | CheckTicketController | // startChecking: điều phối bước 2: ghi nhận suất chiếu đang soát rồi lấy thông tin suất chiếu để hiển thị<br>// checkTicket: điều phối bước 4 đến 6 và 4a đến 4e: lấy phạm vi soát, xác định vé từ mã QR, yêu cầu vé cho vào, hiển thị hợp lệ hoặc lý do | - | 2, 4, 5, 6, 4a, 4b, 4c, 4d, 4e | - | Mới | - |
| AC-E-TicketChecker | entity | TicketChecker | // recordCheckingShowtime: kiểm tra suất chiếu thuộc cụm rạp của mình rồi ghi nhận làm suất chiếu đang soát (BR-34)<br>// provideCheckingScope: cung cấp cụm rạp và suất chiếu đang soát để kiểm tra vé (BR-22, BR-23) | cinema (Cụm rạp của nhân viên soát vé), checkingShowtime (Suất chiếu đang soát) (mới ở UC này) | 2, 4 | - | Mới - chạy song song, chờ P08 hợp nhất (chủ sở hữu UC-017) | GL-36, GL-48 |
| AC-E-Showtime | entity | Showtime | // checkBelongsToCinema: kiểm tra suất chiếu thuộc cụm rạp của nhân viên (BR-22, BR-34)<br>// provideShowtimeInfo: cung cấp phim, định dạng, cụm rạp, phòng chiếu và loại phòng, ngày giờ bắt đầu để hiển thị | movieTitle (Văn bản) (mới ở UC này), auditoriumName (Văn bản) (mới ở UC này) | 2, 4, 6, 4b | - | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-47 |
| AC-E-Ticket | entity | Ticket | // admitTicket: thao tác không chia cắt: kiểm tra cụm rạp, suất chiếu, đã sử dụng, đã huỷ theo thứ tự BR-33 và khi hợp lệ đánh dấu đã sử dụng; trả về hợp lệ hoặc một lý do duy nhất (BR-22 đến BR-25, BR-30, BR-33)<br>// markUsed: chuyển trạng thái vé từ chưa sử dụng sang đã sử dụng (REQ-52)<br>// provideTicketContent: cung cấp nội dung vé: mã đặt vé, thông tin suất chiếu, vị trí ghế, loại ghế, giá vé (REQ-105) | status (Trạng thái: chưa sử dụng, đã sử dụng, đã huỷ) | 4, 5, 6, 4b, 4c, 4d, 4e | - | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-59, GL-60, GL-61, GL-65 |
| AC-E-Booking | entity | Booking | // provideBookingCode: cung cấp mã đặt vé in trên vé (BR-80) | bookingCode (Văn bản) | 6 | - | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-24, GL-28 |

Tổng cộng 6 lớp: 1 boundary, 1 control, 4 entity. Entity cốt lõi của chủ đề race condition: AC-E-Ticket (đơn vị loại trừ giữa hai lần soát cùng vé và giữa soát với huỷ vé của UC-008).

## 4. Phân bổ hành vi

| Bước UC | Trách nhiệm | Lớp nhận (AC) | Nguyên tắc | Lý do khi có lựa chọn khác |
|---|---|---|---|---|
| 1 | // selectCheckingShowtime | AC-B-CheckTicketForm | Giao tiếp tác nhân | - |
| 2 | // startChecking | AC-C-CheckTicketController | Controller | - |
| 2 | // recordCheckingShowtime | AC-E-TicketChecker | Information Expert | Suất chiếu đang soát gắn với nhân viên soát vé (GL-48) nên TicketChecker giữ, thay vì control giữ dữ liệu qua nhiều lần quét (control không giữ dữ liệu nghiệp vụ lâu dài); Q-97. |
| 2 | // checkBelongsToCinema | AC-E-Showtime | Information Expert | Showtime nắm cụm rạp của suất chiếu; TicketChecker chỉ truyền cụm rạp của mình, nên TicketChecker cần quan hệ tới Showtime. |
| 2 | // provideShowtimeInfo | AC-E-Showtime | Information Expert | - |
| 2 | // showCheckingShowtime | AC-B-CheckTicketForm | Giao tiếp tác nhân | - |
| 3 | // scanTicketQr | AC-B-CheckTicketForm | Giao tiếp tác nhân | Camera là kênh nhập của boundary, không có boundary thiết bị riêng. |
| 4 | // checkTicket | AC-C-CheckTicketController | Controller | - |
| 4 | // provideCheckingScope | AC-E-TicketChecker | Information Expert | - |
| 4 | // admitTicket | AC-E-Ticket | Information Expert | Trạng thái vé và việc đánh dấu đã sử dụng nằm ở Ticket nên kiểm tra rồi ghi đặt cùng một lớp để làm một thao tác không chia cắt trên vé. Đặt ở control sẽ tách kiểm tra khỏi ghi. Đặt ở TicketChecker sẽ cho nhân viên ghi trạng thái của vé. Cụm rạp và suất chiếu đang soát được control truyền vào để Ticket không phụ thuộc TicketChecker. |
| 4, 4b | // checkBelongsToCinema | AC-E-Showtime | Information Expert | Ticket không giữ cụm rạp, hỏi Showtime của vé qua quan hệ cấu trúc. |
| 5 | // markUsed | AC-E-Ticket | Information Expert | - |
| 6 | // provideTicketContent | AC-E-Ticket | Information Expert | - |
| 6 | // provideShowtimeInfo | AC-E-Showtime | Information Expert | - |
| 6 | // provideBookingCode | AC-E-Booking | Information Expert | Mã đặt vé thuộc lần đặt chứa vé, không thuộc Ticket. |
| 6 | // showValidTicket | AC-B-CheckTicketForm | Giao tiếp tác nhân | - |
| 4a đến 4e | // rejectTicket | AC-B-CheckTicketForm | Giao tiếp tác nhân | Một trách nhiệm cho cả năm lý do, lý do truyền như dữ liệu. |
| 4a | Xác định vé từ mã QR (không tương ứng vé nào) | AC-C-CheckTicketController | Controller | Tìm vé theo khoá là việc coi như có sẵn (A6 a); control quyết định rẽ nhánh 4a khi không tìm được vé và không cần message riêng. |
| 7 | Lặp lại bước 3 đến 6 | Nhân viên soát vé | Giao tiếp tác nhân | Vòng lặp của tác nhân, vẽ bằng fragment loop. |

## 5. Sequence diagram phân tích

File diagrams/P07-sequence-UC-009.drawio, 2 trang. Số message không kể trả về: SD1a 6, SD1b 15. Mọi luồng thay thế 4a đến 4e kết thúc ở bước 7 nên vẽ bằng alt trong trang luồng chính, không có break.

### SD1a - Luồng chính bước 1 đến 2

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1a-L-NV | Actor | :Nhân viên soát vé | - | - | - |
| SD1a-L-FM | Lifeline | :CheckTicketForm | boundary | - | - |
| SD1a-L-CT | Lifeline | :CheckTicketController | control | - | - |
| SD1a-L-TC | Lifeline | :TicketChecker | entity | - | - |
| SD1a-L-ST | Lifeline | :Showtime | entity | - | - |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1 | :Nhân viên soát vé | :CheckTicketForm | // selectCheckingShowtime (suất chiếu) | Đồng bộ | - | 1 |
| 1.1 | :CheckTicketForm | :CheckTicketController | // startChecking (suất chiếu) | Đồng bộ | - | 2 |
| 1.1.1 | :CheckTicketController | :TicketChecker | // recordCheckingShowtime (suất chiếu) | Đồng bộ | - | 2 |
| 1.1.1.1 | :TicketChecker | :Showtime | // checkBelongsToCinema (cụm rạp của nhân viên soát vé) | Đồng bộ | - | 2 |
| 1.1.2 | :CheckTicketController | :Showtime | // provideShowtimeInfo | Đồng bộ | - | 2 |
| 1.1.2 (trả về) | :Showtime | :CheckTicketController | thông tin suất chiếu | Trả về | - | 2 |
| 1.1.3 | :CheckTicketController | :CheckTicketForm | // showCheckingShowtime (thông tin suất chiếu) | Đồng bộ | - | 2 |

### SD1b - Luồng chính bước 3 đến 7 và luồng 4a đến 4e

Bước 7 thể hiện bằng loop; loop là fragment duy nhất ở mức ngoài cùng ngoài ref. Message 2.1.3 và các nhánh 2.1.5 đến 2.1.9 do control gửi sau khi nhận kết quả soát từ Ticket. Điểm rẽ 4b đến 4e là toán hạng của alt F4 theo kết quả trả về của admitTicket (Ticket đã kiểm tra theo thứ tự BR-33, nên mỗi toán hạng ứng với đúng một lý do).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1b-L-NV | Actor | :Nhân viên soát vé | - | - | - |
| SD1b-L-FM | Lifeline | :CheckTicketForm | boundary | - | - |
| SD1b-L-CT | Lifeline | :CheckTicketController | control | - | - |
| SD1b-L-TC | Lifeline | :TicketChecker | entity | - | - |
| SD1b-L-ST | Lifeline | :Showtime | entity | - | - |
| SD1b-L-TK | Lifeline | :Ticket | entity | - | - |
| SD1b-L-BK | Lifeline | :Booking | entity | - | - |
| SD1b-F0 | Fragment | ref SD1a - Luồng chính bước 1 đến 2 | - | - | ref tới trang trước |
| SD1b-F1 | Fragment | loop [còn vé cần soát của suất chiếu đang soát] | - | - | mức ngoài cùng |
| SD1b-F2 | Fragment | alt [mã QR không tương ứng vé nào] | - | - | lồng trong SD1b-F1 |
| SD1b-F2-O2 | Fragment | [mã QR tương ứng một vé] | - | SD1b-F2 | toán hạng 2 |
| SD1b-F3 | Fragment | opt [vé qua cả bốn điều kiện] | - | - | lồng trong SD1b-F2 |
| SD1b-F4 | Fragment | alt [vé hợp lệ] | - | - | lồng trong SD1b-F2 |
| SD1b-F4-O2 | Fragment | [vé thuộc cụm rạp khác cụm rạp của nhân viên soát vé] | - | SD1b-F4 | toán hạng 2 |
| SD1b-F4-O3 | Fragment | [vé thuộc suất chiếu khác suất chiếu đang soát] | - | SD1b-F4 | toán hạng 3 |
| SD1b-F4-O4 | Fragment | [vé đã sử dụng, kể cả khi nhân viên soát vé khác vừa soát chính vé đó] | - | SD1b-F4 | toán hạng 4 |
| SD1b-F4-O5 | Fragment | [vé đã huỷ, kể cả khi vừa huỷ ở UC-008] | - | SD1b-F4 | toán hạng 5 |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 2 | :Nhân viên soát vé | :CheckTicketForm | // scanTicketQr (mã QR trên vé) | Đồng bộ | SD1b-F1 | 3 |
| 2.1 | :CheckTicketForm | :CheckTicketController | // checkTicket (mã QR) | Đồng bộ | SD1b-F1 | 3, 4 |
| 2.1.1 | :CheckTicketController | :TicketChecker | // provideCheckingScope | Đồng bộ | SD1b-F1 | 4 |
| 2.1.1 (trả về) | :TicketChecker | :CheckTicketController | cụm rạp và suất chiếu đang soát | Trả về | SD1b-F1 | 4 |
| 2.1.2 | :CheckTicketController | :CheckTicketForm | // rejectTicket (lý do: mã QR không tương ứng vé) | Đồng bộ | SD1b-F2 | 4a |
| 2.1.3 | :CheckTicketController | :Ticket | // admitTicket (cụm rạp và suất chiếu đang soát) | Đồng bộ | SD1b-F2 | 4, 5 |
| 2.1.3.1 | :Ticket | :Showtime | // checkBelongsToCinema (cụm rạp) | Đồng bộ | SD1b-F2 | 4, 4b |
| 2.1.3.2 | :Ticket | :Ticket | // markUsed | Tự gọi | SD1b-F3 | 5 |
| 2.1.3 (trả về) | :Ticket | :CheckTicketController | kết quả soát: hợp lệ, hoặc một lý do duy nhất | Trả về | SD1b-F2 | 4 |
| 2.1.4 | :CheckTicketController | :Ticket | // provideTicketContent | Đồng bộ | SD1b-F4 | 6 |
| 2.1.4.1 | :Ticket | :Showtime | // provideShowtimeInfo | Đồng bộ | SD1b-F4 | 6 |
| 2.1.4.2 | :Ticket | :Booking | // provideBookingCode | Đồng bộ | SD1b-F4 | 6 |
| 2.1.4 (trả về) | :Ticket | :CheckTicketController | nội dung vé | Trả về | SD1b-F4 | 6 |
| 2.1.5 | :CheckTicketController | :CheckTicketForm | // showValidTicket (nội dung vé) | Đồng bộ | SD1b-F4 | 6 |
| 2.1.6 | :CheckTicketController | :CheckTicketForm | // rejectTicket (lý do: vé thuộc cụm rạp khác) | Đồng bộ | SD1b-F4 | 4b |
| 2.1.7 | :CheckTicketController | :CheckTicketForm | // rejectTicket (lý do: vé thuộc suất chiếu khác) | Đồng bộ | SD1b-F4 | 4c |
| 2.1.8 | :CheckTicketController | :CheckTicketForm | // rejectTicket (lý do: vé đã sử dụng) | Đồng bộ | SD1b-F4 | 4d |
| 2.1.9 | :CheckTicketController | :CheckTicketForm | // rejectTicket (lý do: vé đã huỷ) | Đồng bộ | SD1b-F4 | 4e |

## 6. Quy tắc tương tác giữa các lớp phân tích

| Vi phạm | Message hoặc link | Cách sửa đã áp dụng |
|---|---|---|
| Không có | - | - |

Ghi chú kiểm tra: TicketChecker --> Showtime (CM1-L4) và Ticket --> Showtime, Ticket --> Booking (CM1-L7, CM1-L8) là entity gọi entity có quan hệ cấu trúc (R-UC009-05, 06, 07). Message tự gọi 2.1.3.2 nằm trong Ticket.

## 7. Communication diagram

File diagrams/P07-communication-UC-009.drawio, 1 trang CM1 gồm luồng chính và luồng 4a đến 4e (MUC_CHI_TIET là DAY_DU), giữ STT của SD1a, SD1b.

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| CM1-O-NV | Actor | :Nhân viên soát vé | - | - | - |
| CM1-O-FM | Object | :CheckTicketForm | boundary | - | - |
| CM1-O-CT | Object | :CheckTicketController | control | - | - |
| CM1-O-TC | Object | :TicketChecker | entity | - | - |
| CM1-O-ST | Object | :Showtime | entity | - | - |
| CM1-O-TK | Object | :Ticket | entity | - | - |
| CM1-O-BK | Object | :Booking | entity | - | - |

b) Bảng Edge

| ID | Nguồn | Đích | Loại (Link) | Nhãn | Chiều message |
|---|---|---|---|---|---|
| CM1-L1 | CM1-O-NV | CM1-O-FM | Link | 1: // selectCheckingShowtime (suất chiếu) (-->)<br>2: // scanTicketQr (mã QR trên vé) (-->) | 1: Nguồn-->Đích; 2: Nguồn-->Đích |
| CM1-L2 | CM1-O-FM | CM1-O-CT | Link | 1.1: // startChecking (suất chiếu) (-->)<br>1.1.3: // showCheckingShowtime (thông tin suất chiếu) (<--)<br>2.1: // checkTicket (mã QR) (-->)<br>2.1.2: // rejectTicket (lý do: mã QR không tương ứng vé) (<--)<br>2.1.5: // showValidTicket (nội dung vé) (<--)<br>2.1.6: // rejectTicket (lý do: vé thuộc cụm rạp khác) (<--)<br>2.1.7: // rejectTicket (lý do: vé thuộc suất chiếu khác) (<--)<br>2.1.8: // rejectTicket (lý do: vé đã sử dụng) (<--)<br>2.1.9: // rejectTicket (lý do: vé đã huỷ) (<--) | 1.1: Nguồn-->Đích; 1.1.3: Đích-->Nguồn; 2.1: Nguồn-->Đích; 2.1.2: Đích-->Nguồn; 2.1.5: Đích-->Nguồn; 2.1.6: Đích-->Nguồn; 2.1.7: Đích-->Nguồn; 2.1.8: Đích-->Nguồn; 2.1.9: Đích-->Nguồn |
| CM1-L3 | CM1-O-CT | CM1-O-TC | Link | 1.1.1: // recordCheckingShowtime (suất chiếu) (-->)<br>2.1.1: // provideCheckingScope (-->) | 1.1.1: Nguồn-->Đích; 2.1.1: Nguồn-->Đích |
| CM1-L4 | CM1-O-TC | CM1-O-ST | Link | 1.1.1.1: // checkBelongsToCinema (cụm rạp của nhân viên soát vé) (-->) | 1.1.1.1: Nguồn-->Đích |
| CM1-L5 | CM1-O-CT | CM1-O-ST | Link | 1.1.2: // provideShowtimeInfo (-->) | 1.1.2: Nguồn-->Đích |
| CM1-L6 | CM1-O-CT | CM1-O-TK | Link | 2.1.3: // admitTicket (cụm rạp và suất chiếu đang soát) (-->)<br>2.1.4: // provideTicketContent (-->) | 2.1.3: Nguồn-->Đích; 2.1.4: Nguồn-->Đích |
| CM1-L7 | CM1-O-TK | CM1-O-ST | Link | 2.1.3.1: // checkBelongsToCinema (cụm rạp) (-->)<br>2.1.4.1: // provideShowtimeInfo (-->) | 2.1.3.1: Nguồn-->Đích; 2.1.4.1: Nguồn-->Đích |
| CM1-L8 | CM1-O-TK | CM1-O-BK | Link | 2.1.4.2: // provideBookingCode (-->) | 2.1.4.2: Nguồn-->Đích |
| CM1-L9 | CM1-O-TK | CM1-O-TK | Link (tự nối) | 2.1.3.2: // markUsed (-->) | 2.1.3.2: Nguồn-->Đích |

## 8. VOPC

File diagrams/P07-class-UC-009.drawio. ID cell của lớp là mã AC; ngăn thuộc tính và ngăn trách nhiệm có ID "<mã AC>-ATTR" và "<mã AC>-RESP".

a) Bảng Node (lớp)

| ID (mã AC) | Loại (Class) | Nhãn (tên lớp) | Stereotype | Thuộc về | Ngăn thuộc tính | Ngăn trách nhiệm |
|---|---|---|---|---|---|---|
| AC-B-CheckTicketForm | Class | CheckTicketForm | «boundary» | - | scannedQr (Mã QR của vé) | // selectCheckingShowtime<br>// showCheckingShowtime<br>// scanTicketQr<br>// showValidTicket<br>// rejectTicket |
| AC-C-CheckTicketController | Class | CheckTicketController | «control» | - | - | // startChecking<br>// checkTicket |
| AC-E-TicketChecker | Class | TicketChecker | «entity» | - | cinema (Cụm rạp của nhân viên soát vé)<br>checkingShowtime (Suất chiếu đang soát) (mới ở UC này) | // recordCheckingShowtime<br>// provideCheckingScope |
| AC-E-Showtime | Class | Showtime | «entity» | - | startTime (Ngày giờ)<br>movieFormat (Văn bản)<br>auditoriumType (Văn bản)<br>cinema (Cụm rạp)<br>movieTitle (Văn bản) (mới ở UC này)<br>auditoriumName (Văn bản) (mới ở UC này) | // checkBelongsToCinema<br>// provideShowtimeInfo |
| AC-E-Ticket | Class | Ticket | «entity» | - | ticketCode (Văn bản)<br>qrCode (Hình ảnh)<br>seatPosition (Mã hàng, số ghế)<br>seatType (Văn bản)<br>price (Số tiền)<br>status (Trạng thái) | // admitTicket<br>// markUsed<br>// provideTicketContent |
| AC-E-Booking | Class | Booking | «entity» | - | bookingCode (Văn bản) | // provideBookingCode |

b) Bảng quan hệ

| ID | Lớp A | Lớp B | Loại | Multiplicity | Vai trò | Nguồn |
|---|---|---|---|---|---|---|
| R-UC009-01 | AC-B-CheckTicketForm | AC-C-CheckTicketController | Association | - | - | tạm thời; link F7: CM1-L2 |
| R-UC009-02 | AC-C-CheckTicketController | AC-E-TicketChecker | Association | - | - | tạm thời; link F7: CM1-L3 |
| R-UC009-03 | AC-C-CheckTicketController | AC-E-Showtime | Association | - | - | tạm thời; link F7: CM1-L5 |
| R-UC009-04 | AC-C-CheckTicketController | AC-E-Ticket | Association | - | - | tạm thời; link F7: CM1-L6 |
| R-UC009-05 | AC-E-TicketChecker | AC-E-Showtime | Association | A 0..* - B 0..1 | - | Nhân viên soát vé có tối đa một suất chiếu đang soát; nhiều nhân viên cùng soát một suất chiếu (GL-48, BR-34, BR-24); Q-97; link F7: CM1-L4 |
| R-UC009-06 | AC-E-Ticket | AC-E-Showtime | Association | A 0..* - B 1 | - | Vé thuộc đúng một ghế của một suất chiếu (GL-59, BR-23); cùng quan hệ R-UC005-19; link F7: CM1-L7 |
| R-UC009-07 | AC-E-Booking | AC-E-Ticket | Aggregation | A 1 - B 1..8 | - | Lần đặt gồm mỗi ghế một vé, mã đặt vé in trên mỗi vé (GL-24, GL-28, BR-05); cùng quan hệ R-UC005-18; link F7: CM1-L8 |

Link CM1-L1 là actor - boundary, link tự nối CM1-L9 không sinh quan hệ.

## 9. Ma trận truy vết

| Bước UC | Message (STT) | Lớp tham gia (AC) |
|---|---|---|
| 1 | 1 | Nhân viên soát vé, AC-B-CheckTicketForm |
| 2 | 1.1, 1.1.1, 1.1.1.1, 1.1.2, 1.1.3 | AC-B-CheckTicketForm, AC-C-CheckTicketController, AC-E-TicketChecker, AC-E-Showtime |
| 3 | 2, 2.1 | Nhân viên soát vé, AC-B-CheckTicketForm, AC-C-CheckTicketController |
| 4 | 2.1, 2.1.1, 2.1.3, 2.1.3.1 | AC-C-CheckTicketController, AC-E-TicketChecker, AC-E-Ticket, AC-E-Showtime |
| 5 | 2.1.3, 2.1.3.2 | AC-E-Ticket |
| 6 | 2.1.4, 2.1.4.1, 2.1.4.2, 2.1.5 | AC-C-CheckTicketController, AC-E-Ticket, AC-E-Showtime, AC-E-Booking, AC-B-CheckTicketForm |
| 7 | loop SD1b-F1 | Nhân viên soát vé |
| 4a | 2.1.2 | AC-C-CheckTicketController, AC-B-CheckTicketForm |
| 4b | 2.1.3.1, 2.1.6 | AC-E-Ticket, AC-E-Showtime, AC-C-CheckTicketController, AC-B-CheckTicketForm |
| 4c | 2.1.3, 2.1.7 | AC-E-Ticket, AC-C-CheckTicketController, AC-B-CheckTicketForm |
| 4d | 2.1.3, 2.1.8 | AC-E-Ticket, AC-C-CheckTicketController, AC-B-CheckTicketForm |
| 4e | 2.1.3, 2.1.9 | AC-E-Ticket, AC-C-CheckTicketController, AC-B-CheckTicketForm |

## 10. File .drawio

Ba file nằm trong diagrams/: P07-sequence-UC-009.drawio (2 trang), P07-communication-UC-009.drawio (1 trang), P07-class-UC-009.drawio (1 trang). XML không nén, ID cell trùng ID trong bảng mô hình. Sequence giữ bản sinh từ bảng (không chạy diakempt); communication đã qua diakempt bỏ bước compact; class đã qua diakempt bỏ bước classlayout.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ |
|---|---|---|---|
| Q-95 | Việc hiển thị danh sách các suất chiếu của cụm rạp để nhân viên soát vé chọn ở bước 1 có phải một bước hệ thống của UC-009 không? (Có, thêm bước hệ thống trước bước 1 / Không, danh sách là phần giao diện của bước 1) | Bước 1; AC-B-CheckTicketForm; AC-E-Showtime | P04 bước 1 là bước của nhân viên soát vé, không có bước hệ thống đưa ra các suất chiếu cần chọn; Dữ liệu vào 1 chỉ nêu điều kiện hợp lệ |
| Q-96 | Khi suất chiếu được chọn ở bước 1 không thuộc cụm rạp của nhân viên soát vé (BR-34), hệ thống xử lý thế nào? (Từ chối và cho chọn lại, thêm luồng 2a / Không xảy ra vì chỉ trình bày suất của cụm rạp mình) | Bước 2; // recordCheckingShowtime, // checkBelongsToCinema; SD1a | P04 không có luồng thay thế cho bước 1, 2; BR-34 chỉ nêu "chỉ chọn" |
| Q-97 | Suất chiếu đang soát lưu gắn với nhân viên soát vé (còn khi đăng xuất, đăng nhập lại, khi dùng thiết bị khác) hay chỉ trong một phiên làm việc? (Gắn với nhân viên, TicketChecker giữ checkingShowtime / Chỉ trong phiên làm việc, không là dữ liệu của entity) | AC-E-TicketChecker (checkingShowtime, // recordCheckingShowtime, // provideCheckingScope); R-UC009-05; SD1a, SD1b | GL-48 và BR-34 nêu "chọn một lần rồi quét liên tiếp tới khi chọn lại" nhưng không nêu vòng đời |

## Giả định

Không có (chế độ NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P04 | UC-009 bước 1, 2 | Không có bước hệ thống đưa ra các suất chiếu để chọn (Q-95) và không có luồng khi suất chiếu chọn không thuộc cụm rạp (Q-96) | Bổ sung sau khi có trả lời Q-95, Q-96 hoặc ghi rõ ở Mục 3 là bước 1, 2 không có luồng thay thế |

## Vấn đề còn mở

- Phụ thuộc UC-008 (chạy song song): thao tác huỷ vé ở UC-008 bước 4 phải thực hiện không chia cắt trên cùng đối tượng AC-E-Ticket với // admitTicket của UC-009, để một vé không đồng thời đã huỷ và đã sử dụng (BR-30, P04 UC-009 Mục 8). P08 phải đối chiếu tên trách nhiệm huỷ trên Ticket của UC-008 và gộp; mọi thay đổi trạng thái của một vé nên xử lý tuần tự theo vé như Q-79 xử lý với lần giữ ghế. Phân tích chỉ chỉ ra Ticket, // admitTicket là thao tác không chia cắt; cơ chế loại trừ chọn ở P09.
- Hai nhân viên cùng quét một vé: cả hai cùng gọi // admitTicket trên cùng Ticket; thao tác tuần tự trên vé nên người sau nhận kết quả đã sử dụng (luồng 4d).
- Thao tác không chia cắt gồm cả kiểm tra cụm rạp và suất chiếu của vé theo P04 Mục 8 dù hai điều kiện này không đổi sau khi vé tạo; nếu P09 chỉ cần khoá phần trạng thái vé thì không ảnh hưởng thứ tự BR-33.
- Điểm rẽ 4a quyết định ở control vì không có đối tượng vé để nhận message; việc tìm vé theo mã QR coi là có sẵn (A6 a).
- Số lớp là 6, trong khoảng 4-12. Entity Showtime, Ticket, Booking tái dùng từ UC-005 và TicketChecker mới chờ P08 hợp nhất với P07 của UC-017 nếu có.
- Showtime, TicketChecker nối với Cụm rạp bằng thuộc tính cinema theo cách rút gọn như UC-005 (Q-81).
- Q-83 của UC-005 không liên quan tới UC-009.
- Chạy song song: mã Q tạm Q-95 đến Q-97, P08 cấp mã chính thức.
- Mốc thời gian soát không giới hạn (BR-83) nên không có message kiểm tra thời điểm.
