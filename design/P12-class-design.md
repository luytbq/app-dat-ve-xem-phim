# P12 - Thiết kế lớp - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P12 |
| Phiên bản | 1.6 |
| Thay đổi 1.6 | Đồng bộ X3 lần 2 (design/_sync-log.md): thêm DC-HoldSettlement (End, Sell, FinishSale) gom trình tự kết thúc lần giữ ghế và bán ghế của HoldSeats, CancelHold, ConfirmCashReceived, HandleIpn (X1 RV-01); tách IF-26, IF-27 khỏi IF-17, IF-18, IF-20 (RV-06); tách cancelInTx thành cancelOnlineInTx, cancelCashInTx, cancelAndReleaseSeat và chuyển lockPaymentOfTicket sang DC-CancelTicketService (RV-09); HoldSeats kiểm BR-02 và đổi thứ tự báo lỗi (Q-145); kiểm số tiền IPN chỉ với báo thành công chưa xử lý (Q-146); NotFoundError cho người không phải người giữ ghế (Q-147); cleanupEvents ngữ cảnh riêng 2 giây (Q-148); Q-143, Q-150, Q-151, Q-152, Q-153, Q-154; đoạn Nếu dừng tại đây cho StartOnlinePayment, ProcessRefund; câu cam kết đổi cổng khớp Q-141 |
| Thay đổi 1.5 | Đồng bộ X3 (design/_sync-log.md): HoldSeats (g) ghi Trống bằng SaveChanges riêng trước khi giữ lại ghế của lần giữ ghế cũ (trg_seat_status_link của P13), IF-18.SaveChanges gọi nhiều lần trong một giao dịch; getter của DC-PaymentTransaction và DC-RefundRequest; ST-01 và ST-04 ở F6.2 khớp F3; ClaimLostError; ngưỡng bỏ lượt ProcessRefund 15 giây; ConfirmCashRefund kiểm cụm rạp (UC-008 2c); ngoại lệ của HoldSeats; bất biến nhánh không tới được; R-179 đến R-183; hai dòng F4 cho email |
| Thay đổi 1.4 | Ánh xạ // checkRoomChangeAllowed sang DC-Showtime, tách khỏi applyChanges để thống nhất với P07 và P08 |
| Thay đổi 1.3 | ProcessRefund có hàng rào ExtendClaim, claim từng dòng, email hoàn tiền chỉ cho hoàn toàn bộ (RF-01, RF-03); TxOptions có hạn tổng cho HoldSeats (RF-05); seat_event ghi sau cùng (RF-12); BEING_RELEASED (RF-17); RecordFailure không lưu gatewayTransactionNo (RF-13); kiểm BR-92 cho lượt PKG-27 (RF-02); đóng Vấn đề còn mở 7 (RF-15); đồng bộ đầu vào đã dùng (RF-06) |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md (mục 3, CONG_NGHE đã chốt theo P09 F11); P05-glossary.md 1.1 (tên thuật ngữ); P06-supplementary-spec.md 1.3 (BR, NFR); P08-analysis-model.md 1.5 (F3, F4, F4b, F4c, Câu hỏi mở, Đề xuất sửa); P09-architecture.md 1.7 (F3 đến F7); P10-design-elements.md 1.5 (F1 đến F5, Đề xuất sửa, Vấn đề còn mở); P11b-system-interfaces.md 1.4 và SS-01 1.3, SS-03 1.2, SS-04 1.2, SS-05 1.1 (F2, F3, F5, Đề xuất sửa, Vấn đề còn mở 11). P07 và P04 không được đính kèm theo yêu cầu người dùng (Vấn đề còn mở 2) |
| Phạm vi | Lõi giữ ghế, thanh toán, huỷ vé, soát vé: PKG-12, PKG-13, PKG-14, PKG-15, PKG-21, PKG-22 (SS-01), PKG-24 (SS-03), PKG-25 (SS-04), PKG-26 (chỉ IF-07), PKG-28 và phần PKG-27 mà các UC-005, UC-008, UC-009 dùng (mục 0.1) |
| Mã Q, ASM cuối đã cấp | Q-135; không có ASM (NGHIEM_NGAT) |

Trọng tâm: biến mô hình phân tích và phần tử thiết kế của chuỗi giữ ghế, thanh toán, huỷ vé và soát vé thành lớp Go lập trình được, giữ nguyên ngữ nghĩa 15 đơn vị loại trừ và thứ tự khoá 9 hạng (P08 F4b, P10 F3a). Bốn điểm chốt: (1) mọi trạng thái cuối của SeatHold không đổi (Q-79, BR-86) và hết hạn là sự thật tính từ expiryTime so với thời điểm CSDL, không phải sự kiện; (2) SeatStatus chỉ được giải phóng khi liên kết hiện tại (currentHold hoặc currentTicket) khớp lần giữ ghế hoặc vé đang xử lý, nên giải phóng chạy lặp an toàn; (3) lớp dịch vụ ở Application là nơi duy nhất mở giao dịch (IF-08) và thấy cả chuỗi khoá, mỗi lời gọi khoá đi qua DC-LockOrderGuard; (4) công việc dọn hết hạn, giải phóng ghế, hoàn tiền là lớp hiện thực IF-06, chạy lặp an toàn, không có bộ đếm giờ trong bộ nhớ.

Kết quả: 69 phần tử có hành vi (47 lớp, 22 interface) trong 11 package, 75 kiểu phụ trợ (value object, enumeration, ngoại lệ), 149 quan hệ (R-65 đến R-196, trừ R-76, R-83, R-96, R-109, R-165, R-167 đã bỏ, và mã R-nn của P08), 5 state machine (ST-01 đến ST-05), 8 class diagram, 5 sequence diagram thiết kế.

## 0. Phạm vi lần chạy và quy ước

0.1. Phạm vi. Theo yêu cầu người dùng, lần chạy này là một file cho lõi giữ ghế (race condition, giữ ghế tạm có timeout, giải phóng ghế), không chạy lặp theo package. Phạm vi vượt ngưỡng khoảng 20 lớp có hành vi của prompt (66 phần tử có hành vi, kể cả interface); lựa chọn được ghi ở Vấn đề còn mở 1. Thứ tự ưu tiên theo P11b Vấn đề còn mở 11: SS-01 và SS-03 làm đầy đủ, SS-04 chỉ vòng lặp theo chu kỳ có ngân sách, SS-05 chỉ interface IF-07 với ba operation (CheckRole là hàm thường).

| Nhóm | Package, subsystem | Trong lần chạy này | Để lượt sau |
|---|---|---|---|
| Presentation phía máy chủ | PKG-12 | DC-PaymentCallbackController (ba đường vào công khai, gồm điểm vào địa chỉ trả về) | PKG-11 (DC-BookingController, DC-SeatMapStreamController, DC-TicketController, DC-PricingScheduleController, DC-AuthFilter) |
| Application | PKG-13, PKG-14, PKG-15 | Toàn bộ lớp (9 lớp) | PKG-16, PKG-20 (DC-EmailOutboxJob), PKG-17 đến PKG-19 giữ chỗ |
| Services | PKG-21, PKG-22 (SS-01), PKG-24 (SS-03), PKG-25 (SS-04), PKG-26 (SS-05) | PKG-21 (DC-PgCinemaOperationsStore chỉ phần IF-11 đến IF-13); SS-01, SS-03, SS-04 đủ; SS-05 chỉ IF-07 | PKG-23 (SS-02), phần bên trong SS-05 |
| Domain | PKG-27, PKG-28 | PKG-28 đủ 8 entity và IF-16 đến IF-21; PKG-27 gồm DC-Showtime, DC-PriceList (chỉ operation của UC-005, UC-008, UC-009), IF-08, IF-11 đến IF-13, IF-24, IF-25 | DC-Cinema, DC-Auditorium, DC-Seat, DC-Movie, DC-PriceEntry, DC-CinemaManager, DC-TicketChecker, IF-14, IF-15; operation của UC-013, UC-014 |
| Giao diện React | PKG-05 đến PKG-10, PKG-29 | Không | Chạy cùng P11a |

Các lớp ngoài phạm vi mà lớp trong phạm vi tham chiếu (chỉ tên, ghi ở F8): DC-Seat, DC-Auditorium, DC-PriceEntry (PKG-27). Chữ ký chúng cần: Seat có Type() SeatType, Label() string; Auditorium có Type() AuditoriumType; hai giá trị này đi vào DC-PriceQuery.

0.2. Bảng ánh xạ kiểu sang Go (một lần cho cả artifact). CONG_NGHE của hồ sơ dự án (theo P09 F11) là Go, net/http, pgx, PostgreSQL 15 trở lên; P12 dùng Go.

| Kiểu trung lập (P11b) | Kiểu Go dùng ở P12 | Ghi chú |
|---|---|---|
| String | string | |
| Integer | int, hoặc int64 khi là đồng (PKG-22) | Tiền trong Domain là Money (int64 đồng, không dấu phẩy động) |
| Decimal, tiền | Money (DC-Money) | Làm tròn xuống đồng (BR-31) |
| Boolean | bool | |
| Date, DateTime | time.Time | Giá trị nghiệp vụ lấy từ IF-25.Now (đồng hồ CSDL), truyền vào method qua tham số now, không gọi time.Now trong entity |
| Duration | time.Duration | |
| List(T), Set(T) | []T, map[T]struct{} | |
| Map(String, String) | map[string]string | |
| Định danh | Kiểu số int64 đặt tên riêng (DC-CinemaIds, DC-TicketingIds) | Thiết kế: khoá theo thứ tự số tăng dần, không theo chuỗi (P09 F7.3); IF-04.showtimeId đổi từ String sang ShowtimeId (Đề xuất sửa P11b) |
| Không trả về, hoặc lỗi | error là giá trị trả về cuối | Lỗi nghiệp vụ là kiểu lỗi có tên (errors.As), lỗi kỹ thuật bọc nguyên nhân |
| Luồng kết quả bất đồng bộ (P11b cột Đồng bộ) | <-chan T | IF-04.Subscribe trả handle ngay, kênh items đọc bất đồng bộ; đóng kết nối gọi Unsubscribe |
| Thời gian chờ 30 giây (BR-43) | ctx có deadline | Mọi operation có I/O nhận ctx đầu tiên |
| ctx | context.Context | Viết tắt Ctx trong chữ ký |
| tx | Tx (IF-25) | Phiên giao dịch truyền vào mọi operation của interface kho |
| Hằng số lớp | thuộc tính Classifier chỉ đọc | Ví dụ HoldDuration, MaxAttempts |

0.3. Quy ước hiện thực.

- Association được hiện thực bằng struct giữ mã (ID) của đối tượng liên kết hoặc con trỏ đã nạp, không nạp đồ thị đối tượng; kho nạp đối tượng khi cần. Vì thế thuộc tính trỏ tới lớp khác không lặp lại ở F7 (thuộc tính định danh ghép như SeatKey là ngoại lệ có ghi lý do).
- Operation của interface kho nhận ctx và tx, mỗi operation khoá đúng một hạng (P10 F3a). Rank khoá cố định theo operation, lớp dịch vụ không truyền hạng. Operation không khoá (chỉ đọc) ghi "Hậu: không khoá".
- Entity là dữ liệu cộng quy tắc, không biết SQL, không gọi kho, không gọi đồng hồ; nhận thời điểm now qua tham số (Bước 2.6). Lớp dịch vụ nhận phụ thuộc qua constructor (tiêm phụ thuộc, ghi ở F5).
- Lỗi nghiệp vụ mà thao tác đã ghi một thay đổi cần giữ (ví dụ chuyển lần giữ ghế sang Hết hạn khi bị thao tác đến sau hạn) thì hàm fn của IF-08.Do trả nil và ghi kết quả vào biến của bên gọi; chỉ khi không có gì cần giữ mới trả lỗi để rollback.
- Operation của entity trả bool (ReleaseHold, ReleaseTicket, Expire, RecordFailure) khi "không đổi" là kết quả hợp lệ (chạy lặp an toàn); trả error khi đối tượng ở trạng thái mà sự kiện bị từ chối (ghi ở F6).
- Operation đọc không khoá: có tx ở chữ ký khi cần đọc trong cùng giao dịch với các khoá đã giữ (IF-19.FindByID, IF-20.FindByCode, IF-20.FindByTicket, IF-11.FindByID), không có tx khi chạy ngoài giao dịch trên kết nối riêng (IF-17.FindIDByRef, IF-19.FindByCode, IF-11.FindRouting, IF-11.FindInfo). IF-25 (Tx) chỉ có Now vì Domain không được thấy kiểu pgx; store ép Tx sang DC-PgTx, và chỉ DC-PgUnitOfWork tạo được Tx nên phép ép luôn đúng.
- Khi một lần giữ ghế kết thúc (Hết hạn, Đã huỷ, Thanh toán thất bại) trong một giao dịch đã giữ khoá hạng 6 của các ghế của nó, giao dịch đó trả ghế ngay (DC-HoldSettlement.End gọi SeatStatus.ReleaseHold, service SaveChanges); DC-SeatReleaseJob chỉ là lưới an toàn cho ghế còn sót (Q-134, NFR-07).
- Mọi chuyển lần giữ ghế sang Hết hạn, Đã huỷ, Thanh toán thất bại, Đã hoàn tất của service đi qua DC-HoldSettlement.End hoặc Sell; chỉ hai operation này gọi SeatHold.Expire, Cancel, FailPayment, Complete (ngoại lệ: DC-HoldExpiryJob.expireBatch gọi Expire theo lô vì không có ghế đã khoá hạng 6) và luôn gọi Expire(now) trước, nên bên gọi không thể quên.
- Giá trị ngoài miền mà F2 không nêu hành vi (tham số rỗng hoặc nil của NewSeatHold; Money bằng 0 hoặc âm ở NewFullRefund, NewTicketRefund, NewCashRefund, CheckRefundWithin, RecordRefunded, RefundAmount; ghế lùi mốc ở CheckUnchangedSince; hai key bằng nhau ở AcquireAll) là tiền điều kiện của bên gọi (Q-144): operation không kiểm và không có ca thử; lưới an toàn là CHECK của P13 (ck_payment_transaction_amount, ck_refund_request_amount, ck_ticket_price).
- Chữ ký dùng tên Go in hoa đầu cho operation public (+), in thường cho nội bộ package (~) hoặc private (-).

## F1. Bảng lớp thiết kế

| DC | Tên | Stereotype | PKG | Trách nhiệm | Nguồn AC | Loại | Persistent | Ghi chú thiết kế |
|---|---|---|---|---|---|---|---|---|
| DC-SeatHold | SeatHold | «entity» | PKG-28 | Giữ vòng đời một lần giữ ghế: tạo, hết hạn, hoàn tất, huỷ hoặc thanh toán thất bại, và không đổi sau khi đã ở trạng thái cuối | AC-E-SeatHold | class | Có | ST-01. Hết hạn là sự thật tính theo expiryTime, không phải sự kiện (P09 F7.4). Không gọi SeatStatus (Q-117) |
| DC-SeatStatus | SeatStatus | «entity» | PKG-28 | Giữ trạng thái một ghế trong một suất chiếu và chỉ giải phóng ghế khi liên kết hiện tại khớp lần giữ ghế hoặc vé đang xử lý | AC-E-SeatStatus | class | Có | ST-02. event_seq là cột kỹ thuật do PKG-21 ghi trong cùng câu UPDATE, không là thuộc tính miền |
| DC-PaymentTransaction | PaymentTransaction | «entity» | PKG-28 | Giữ vòng đời xử lý một giao dịch thanh toán và tổng tiền đã hoàn của nó | AC-E-PaymentTransaction | class | Có | ST-05. Gộp hai thuộc tính processed và result của P08 thành status |
| DC-RefundRequest | RefundRequest | «entity» | PKG-28 | Giữ vòng đời một yêu cầu hoàn tiền gồm số lần gửi, kết quả và khoá chống hoàn trùng | AC-E-RefundRequest | class | Có | ST-04. Trạng thái Cần xử lý thủ công theo P09 F7.7 và Q-118 |
| DC-Booking | Booking | «entity» | PKG-28 | Giữ mã đặt vé và tập vé của một lần giữ ghế đã hoàn tất, và kiểm kênh mua khi huỷ | AC-E-Booking | class | Có | Vòng đời: tạo cùng vé khi bán ghế, không đổi sau đó (không cần state machine) |
| DC-Ticket | Ticket | «entity» | PKG-28 | Giữ vòng đời một vé: huỷ một lần hoặc soát một lần, tuyệt đối không cả hai | AC-E-Ticket | class | Có | ST-03. Ảnh mã QR dựng từ ticketCode khi hiển thị hoặc gửi, không lưu |
| DC-HoldSettlement | HoldSettlement | «utility» | PKG-28 | Kết thúc một lần giữ ghế (hết hạn, huỷ, thanh toán thất bại) kèm trả các ghế còn trỏ tới nó, và bán ghế (hoàn tất lần giữ ghế, tạo lần đặt cùng vé, đánh dấu ghế đã bán), mỗi việc đúng một trình tự | Thiết kế (X1 RV-01) | class | Không | Lớp miền không trạng thái, không I/O, không khoá, không gọi kho (Pure Fabrication, đúng Q-117). Gom dãy Expire, UpdateStatus, ReleaseHold, SaveChanges đang lặp ở HoldSeats, CancelHold, ConfirmCashReceived, HandleIpn và dãy Complete, NewTicket, NewBooking, MarkSold lặp ở ConfirmCashReceived, HandleIpn. Thứ tự khoá hạng 5, 6, 8 và ranh giới giao dịch vẫn do bốn service giữ |
| DC-Customer | Customer | «entity» | PKG-28 | Giữ tài khoản khách và kiểm khách không còn lần giữ ghế chưa kết thúc | AC-E-Customer | class | Có | Tạm, chờ P07 UC-001. Kiểm mật khẩu do IF-07, ngoài phạm vi |
| DC-BoxOfficeClerk | BoxOfficeClerk | «entity» | PKG-28 | Giữ tài khoản nhân viên quầy và kiểm nhân viên không còn lần giữ ghế chưa kết thúc | AC-E-BoxOfficeClerk | class | Có | Tạm, chờ P07 UC-017 |
| IF-16 | IHolderRepository | «interface» | PKG-28 | Khoá người giữ ghế (hạng 4) và đọc tài khoản | P10 cơ chế Persistence | interface | Không | Hạng 4 |
| IF-17 | ISeatHoldRepository | «interface» | PKG-28 | Khoá, đọc, thêm và cập nhật trạng thái lần giữ ghế (hạng 5) | P10 cơ chế Persistence | interface | Không | Hạng 5; mã tăng dần khi khoá nhiều dòng; thao tác theo lô của job nền ở IF-26 |
| IF-18 | ISeatStatusRepository | «interface» | PKG-28 | Khoá, đọc và lưu trạng thái ghế kèm sự kiện đổi ghế (hạng 6) | P10 cơ chế Persistence | interface | Không | Hạng 6; (mã suất chiếu, mã ghế) tăng dần; LockByHolds của job nền ở IF-26 |
| IF-19 | IPaymentTransactionRepository | «interface» | PKG-28 | Khoá, đọc và cập nhật giao dịch thanh toán (hạng 7) | P10 cơ chế Persistence | interface | Không | Hạng 7 |
| IF-20 | IBookingRepository | «interface» | PKG-28 | Thêm và đọc lần đặt kèm vé | P10 cơ chế Persistence | interface | Không | Thêm dòng mới và đọc không khoá; khoá và cập nhật vé ở IF-27 (hạng 8) |
| IF-21 | IRefundRequestRepository | «interface» | PKG-28 | Thêm, khoá và cập nhật yêu cầu hoàn tiền (hạng 9) | P10 cơ chế Persistence | interface | Không | Hạng 9 |
| IF-26 | IHoldSweepRepository | «interface» | PKG-28 | Khoá theo lô các lần giữ ghế cần hết hạn hoặc cần trả ghế, và ghế của lô, chỉ cho hai công việc nền (hạng 5, 6) | Thiết kế (X1 RV-06) | interface | Không | Tách khỏi IF-17, IF-18 để bản giả của DC-HoldExpiryJob, DC-SeatReleaseJob nhỏ; hạng và SQL của từng operation không đổi |
| IF-27 | ITicketLockRepository | «interface» | PKG-28 | Khoá và cập nhật trạng thái vé (hạng 8) | Thiết kế (X1 RV-06) | interface | Không | Tách khỏi IF-20; DC-CancelTicketService, DC-CheckTicketService dùng; IF-20 chỉ còn thêm và đọc lần đặt |
| DC-Showtime | Showtime | «entity» | PKG-27 | Kiểm tra điều kiện bán, huỷ và soát vé của một suất chiếu và chốt giá vé cho các ghế chọn | AC-E-Showtime | class | Có | Chỉ chi tiết operation của UC-005, UC-008, UC-009; operation của UC-013, UC-014 để lượt PKG-27. Q-117: không gọi SeatHold, SeatStatus |
| DC-PriceList | PriceList | «entity» | PKG-27 | Xác định giá vé của một ghế theo loại phòng, định dạng phim, khung giờ và loại ghế | AC-E-PriceList | class | Có | Chỉ operation của UC-005; savePriceEntry, removePriceEntry, checkCoversShowtime của UC-013, UC-014 để lượt PKG-27. Mục giá (DC-PriceEntry) tham chiếu |
| IF-08 | IUnitOfWork | «interface» | PKG-27 | Chạy một hàm trong đúng một giao dịch READ COMMITTED, thử lại khi deadlock và khoá quá hạn | P10 cơ chế Đồng thời | interface | Không | Control mở giao dịch qua interface này (Bước 1.4). Kiểu Tx là IF-25 |
| IF-25 | Tx | «interface» | PKG-27 | Đại diện một giao dịch đang mở, truyền vào mọi operation của interface kho để chúng dùng cùng một kết nối | Thiết kế: giao dịch dùng chung | interface | Không | Cấp mới theo Bước 1.5; Domain không thấy kiểu pgx. Đề xuất sửa P10 |
| IF-11 | IShowtimeRepository | «interface» | PKG-27 | Đọc và khoá dòng suất chiếu (hạng 3) | P10 cơ chế Persistence | interface | Không | Chỉ operation dùng trong phạm vi; phần còn lại lượt PKG-27 |
| IF-12 | IPriceListRepository | «interface» | PKG-27 | Khoá và đọc bảng giá của cụm rạp (hạng 1) | P10 cơ chế Persistence | interface | Không | Chỉ operation của EX-01 |
| IF-13 | ICinemaRepository | «interface» | PKG-27 | Khoá phòng chiếu (hạng 2) và đọc ghế của phòng | P10 cơ chế Persistence | interface | Không | Chỉ operation của EX-01 |
| IF-24 | ICodeGenerator | «interface» | PKG-27 | Sinh mã tham chiếu cho lần giữ ghế, giao dịch, lần đặt và vé | Thiết kế: bộ sinh mã nhận qua constructor (Bước 2.6) | interface | Không | Cấp mới nối tiếp IF-23; để X2 kiểm thử với mã cố định. Đề xuất sửa P10 |
| DC-RandomCodeGenerator | RandomCodeGenerator | «utility» | PKG-27 | Sinh mã ngẫu nhiên bằng crypto/rand cho các mã tham chiếu | Thiết kế: hiện thực IF-24 | class | Không | Không giữ trạng thái |
| DC-BookTicketsService | BookTicketsService | «service» | PKG-13 | Điều phối giữ ghế, huỷ giữ ghế, bắt đầu thanh toán trực tuyến và xác nhận thu tiền mặt của một lần giữ ghế, và là ranh giới giao dịch của chúng | AC-C-BookTicketsController | class | Không | Control đổi tên Service (P10 F3). Nhiều phụ thuộc vì là nơi duy nhất thấy cả chuỗi khoá EX-01 (Q-117); Vấn đề còn mở 4 |
| DC-SeatMapService | SeatMapService | «service» | PKG-13 | Cung cấp ảnh chụp sơ đồ ghế và luồng khung SSE của một suất chiếu | AC-E-Showtime | class | Không | P10 cơ chế SSE (tách từ provideSeatMap); không giữ trạng thái giữa hai yêu cầu |
| DC-HoldExpiryJob | HoldExpiryJob | «service» | PKG-13 | Chuyển các lần giữ ghế đã quá hạn sang Hết hạn theo lô và dọn sự kiện đổi ghế cũ | AC-C-BookTicketsController | class | Không | Hiện thực IF-06; gộp từ DC-SeatEventCleanupJob (P10). Không có bộ đếm giờ trong bộ nhớ (P09 A7) |
| DC-SeatReleaseJob | SeatReleaseJob | «service» | PKG-13 | Trả các ghế còn trỏ tới lần giữ ghế đã kết thúc về Trống, chỉ khi liên kết hiện tại còn khớp | AC-E-SeatHold | class | Không | Hiện thực IF-06; lưới an toàn cho ghế còn trỏ tới lần giữ ghế đã kết thúc; các service trả ghế ngay trong giao dịch của chúng (Q-134) |
| DC-PaymentReportService | PaymentReportService | «service» | PKG-14 | Xử lý báo kết quả thanh toán của cổng thành một thao tác không chia cắt theo lần giữ ghế, và trả trạng thái thanh toán chỉ đọc cho trang kết quả | AC-C-PaymentReportController | class | Không | Control đổi tên Service. ST-01 và ST-05 được điều khiển ở đây; bảng quyết định P09 F7.6 là hàm thuần decide |
| DC-RefundService | RefundService | «service» | PKG-14 | Tạo yêu cầu hoàn tiền trong giao dịch của bên gọi và điều khiển vòng đời gửi hoàn qua cổng | AC-C-PaymentReportController | class | Không | Dùng chung cho UC-006 và UC-008 (Q-106); chế độ (a) dùng giao dịch của bên gọi, chế độ (b) và EX-10 mở giao dịch riêng |
| DC-RefundOutboxJob | RefundOutboxJob | «service» | PKG-14 | Nhận các dòng hàng đợi hoàn tiền đến hạn và giao cho DC-RefundService xử lý song song | AC-C-PaymentReportController | class | Không | Hiện thực IF-06 |
| DC-CancelTicketService | CancelTicketService | «service» | PKG-15 | Điều phối huỷ một vé: ghi nhận huỷ, trả ghế và tạo khoản hoàn trong một giao dịch | AC-C-CancelTicketController | class | Không | Một giao dịch gộp EX-06, EX-07, EX-09 theo thứ tự khoá hạng 6, 7, 8, 9 (P08 F4b quy tắc 4 sửa lại); Q-133 |
| DC-CheckTicketService | CheckTicketService | «service» | PKG-15 | Điều phối chọn suất chiếu để soát và soát một vé thành một lần duy nhất | AC-C-CheckTicketController | class | Không | Một trừu tượng (P10 F3) |
| DC-PaymentCallbackController | PaymentCallbackController | «boundary» | PKG-12 | Tiếp nhận ba đường vào công khai của cổng thanh toán (IPN, địa chỉ trả về, hỏi trạng thái) và dịch kết quả sang định dạng HTTP của cổng | AC-B-PaymentGateway | class | Không | P10 cơ chế Giao tiếp ngoài; không đăng nhập. Đường hỏi trạng thái đặt ở đây để không thêm cạnh PKG-11 --> PKG-14 (Đề xuất sửa P10) |
| DC-PgUnitOfWork | PgUnitOfWork | «service» | PKG-21 | Mở giao dịch PostgreSQL READ COMMITTED, chạy hàm của bên gọi và thử lại khi gặp deadlock hoặc hết thời gian chờ khoá | P10 cơ chế Đồng thời | class | Không | Hiện thực IF-08 |
| DC-PgTx | PgTx | «service» | PKG-21 | Giữ giao dịch pgx đang mở, bộ kiểm thứ tự khoá và thời điểm CSDL đã lấy của một giao dịch | Thiết kế: hiện thực IF-25 | class | Không | Các store ép kiểu IF-25 về PgTx; chỉ PKG-21 thấy kiểu này |
| DC-LockOrderGuard | LockOrderGuard | «utility» | PKG-21 | Từ chối mọi lời gọi khoá dòng đi lùi hạng hoặc đi lùi mã trong một giao dịch | P10 cơ chế Đồng thời | class | Không | Một thể hiện mỗi giao dịch, không an toàn đa luồng (một giao dịch chạy trên một goroutine) |
| DC-ConnectionPools | ConnectionPools | «utility» | PKG-21 | Giữ hai pool kết nối riêng cho yêu cầu người dùng và công việc nền | P10 cơ chế Persistence | class | Không | P09 F7.3, F7.4 |
| DC-SeatEventWriter | SeatEventWriter | «utility» | PKG-21 | Ghi một dòng seat_event cho mỗi suất chiếu bị ảnh hưởng, trong giao dịch đổi ghế sau khi đã khoá ghế | P10 cơ chế SSE | class | Không | Chỉ các Pg Store gọi, trong cùng thao tác cập nhật SeatStatus; không NOTIFY |
| DC-PgTicketingStore | PgTicketingStore | «service» | PKG-21 | Hiện thực SQL khoá và ghi cho các interface kho của PKG-28, mỗi phương thức khoá một hạng cố định | P10 cơ chế Persistence | class | Không | Hiện thực IF-16 đến IF-21, IF-26, IF-27; operation công khai là toàn bộ operation của tám interface đó (không lặp lại ở đây) |
| DC-PgCinemaOperationsStore | PgCinemaOperationsStore | «service» | PKG-21 | Hiện thực SQL khoá và đọc cho các interface kho của PKG-27 | P10 cơ chế Persistence | class | Không | Hiện thực IF-11, IF-12, IF-13 (phần trong phạm vi); operation công khai là toàn bộ operation của ba interface đó |
| DC-PgSeatEventStore | PgSeatEventStore | «service» | PKG-21 | Đọc, phát lại, chụp ảnh và dọn bảng seat_event cho PKG-24 và công việc dọn | P10 cơ chế SSE | class | Không | Hiện thực IF-22; operation công khai là toàn bộ operation của IF-22 |
| DC-PgOutboxStore | PgOutboxStore | «service» | PKG-21 | Xếp, nhận (claim) và ghi kết quả có điều kiện cho dòng hàng đợi gửi | P10 cơ chế Persistence (hàng đợi gửi) | class | Không | Hiện thực IF-23; operation công khai là toàn bộ operation của IF-23 |
| IF-22 | ISeatEventStore | «interface» | PKG-21 | Đọc, phát lại, chụp ảnh và dọn sự kiện đổi ghế | P10 cơ chế SSE | interface | Không | Chữ ký tạm của P11b Vấn đề còn mở 6 được chốt ở đây (readEventsAfter --> ReadEventsAfter...) |
| IF-23 | IOutboxStore | «interface» | PKG-21 | Xếp dòng hàng đợi gửi cùng giao dịch tạo ra nó, nhận dòng đến hạn và ghi kết quả có điều kiện claim_token | P10 cơ chế hàng đợi gửi | interface | Không | Dòng hàng đợi không thuộc 9 hạng khoá (P10 F3a EX-10) |
| IF-01 | IPaymentGateway | «interface» | PKG-22 | Hệ thống gọi ra cổng thanh toán: ký địa chỉ thanh toán, gửi hoàn tiền, tra cứu hoàn tiền | P11b SS-01 | interface | Không | Chữ ký theo P11b F3; Integer --> int64 đồng (PKG-22 không phụ thuộc Domain, P10 F6), DateTime --> time.Time, thời gian chờ 30 giây qua ctx |
| IF-02 | IPaymentReportReceiver | «interface» | PKG-22 | Cổng thanh toán báo kết quả vào hệ thống: kiểm chữ ký và giải mã thông báo | P11b SS-01 | interface | Không | replyToReport đã bỏ theo P10 (Đề xuất sửa P11b) |
| DC-PaymentGatewayManager | PaymentGatewayManager | «service» | PKG-22 | Điều phối ba lời gọi ra cổng VNPay sau IF-01 | P11b SS-01 | class | Không | Hiện thực IF-01 |
| DC-PaymentReportReceiver | PaymentReportReceiver | «service» | PKG-22 | Kiểm chữ ký rồi giải mã thông báo của cổng sau IF-02 | P11b SS-01 | class | Không | Hiện thực IF-02 |
| DC-VnpayUrlBuilder | VnpayUrlBuilder | «utility» | PKG-22 | Dựng và ký địa chỉ thanh toán VNPay | P11b SS-01 | class | Không | Nhận đồng hồ qua constructor để kiểm thử |
| DC-VnpayRefundClient | VnpayRefundClient | «service» | PKG-22 | Gửi yêu cầu hoàn và tra cứu hoàn tới cổng bằng HTTPS với thời gian chờ 30 giây | P11b SS-01 | class | Không | Mã trả lời lạ là UNKNOWN hoặc UNREACHABLE |
| DC-VnpaySigner | VnpaySigner | «utility» | PKG-22 | Ký và kiểm chữ ký HMAC-SHA512 theo chuẩn của cổng | P11b SS-01 | class | Không | Dùng khoá của DC-GatewayConfig |
| DC-VnpayReportDecoder | VnpayReportDecoder | «utility» | PKG-22 | Giải mã tham số thông báo VNPay thành PaymentReport | P11b SS-01 | class | Không | Bảng mã kết quả V-04 |
| DC-GatewayConfig | GatewayConfig | «utility» | PKG-22 | Giữ cấu hình cổng đọc từ biến môi trường | P11b SS-01 | class | Không | Không ghi log khoá ký, không lưu thông tin thẻ (NFR-10) |
| IF-04 | ISeatEventSubscription | «interface» | PKG-24 | Đăng ký nhận sự kiện đổi ghế của một suất chiếu từ một con trỏ theo mô hình kéo và huỷ đăng ký | P11b SS-03 | interface | Không | showtimeId String --> ShowtimeId (kiểu định danh số, Đề xuất sửa P11b); afterEventId rỗng --> 0 |
| DC-SeatEventHubManager | SeatEventHubManager | «service» | PKG-24 | Nhận đăng ký, phát lại rồi chuyển sang trực tiếp, và khởi động, dừng vòng đọc seat_event | P11b SS-03 | class | Không | Hiện thực IF-04 |
| DC-SeatEventPoller | SeatEventPoller | «service» | PKG-24 | Mỗi 500 ms đọc sự kiện sau mốc W và đẩy vào hàng đợi các kết nối của suất chiếu | P11b SS-03 | class | Không | Nhận hàm đồng hồ qua constructor |
| DC-SeatReplayReader | SeatReplayReader | «service» | PKG-24 | Phát lại sự kiện của một suất chiếu từ con trỏ vào hàng đợi và báo khi con trỏ đã bị xoá | P11b SS-03 | class | Không | - |
| DC-SubscriberRegistry | SubscriberRegistry | «utility» | PKG-24 | Giữ danh sách hàng đợi đăng ký theo suất chiếu | P11b SS-03 | class | Không | An toàn đa luồng bằng khoá mutex |
| DC-SubscriberQueue | SubscriberQueue | «utility» | PKG-24 | Giữ tối đa 256 sự kiện chờ của một kết nối và đóng khi đầy | P11b SS-03 | class | Không | - |
| DC-EmittedEventTracker | EmittedEventTracker | «utility» | PKG-24 | Nhớ mã sự kiện đã phát 20 giây gần nhất và mốc W | P11b SS-03 | class | Không | - |
| IF-05 | IJobScheduler | «interface» | PKG-25 | Đăng ký công việc định kỳ, bắt đầu và dừng chạy | P11b SS-04 | interface | Không | Khách hàng là hàm khởi động chương trình |
| IF-06 | IScheduledJob | «interface» | PKG-25 | Một công việc nền chạy một lượt các mục đến hạn trong ngân sách thời gian | P11b SS-04 | interface | Không | Interface gọi ngược: SS-04 định nghĩa, Application hiện thực |
| DC-JobSchedulerManager | JobSchedulerManager | «service» | PKG-25 | Nhận đăng ký công việc, mở và dừng các vòng chạy | P11b SS-04 | class | Không | Hiện thực IF-05; SS-04 chỉ là vòng lặp theo chu kỳ có ngân sách (P11b Vấn đề còn mở 11) |
| DC-JobRegistry | JobRegistry | «utility» | PKG-25 | Giữ danh sách công việc đã đăng ký với tên duy nhất | P11b SS-04 | class | Không | - |
| DC-JobLoop | JobLoop | «utility» | PKG-25 | Chạy một công việc theo chu kỳ, không chạy chồng, với ngân sách 8 giây mỗi lượt | P11b SS-04 | class | Không | Nhận hàm chờ qua constructor để kiểm thử |
| IF-07 | IAuthenticator | «interface» | PKG-26 | Kiểm mật khẩu, cấp và kiểm mã phiên tự kiểm chứng được | P11b SS-05 | interface | Không | Chỉ interface (SS-05 dùng qua interface); CheckRole là hàm thường (P11b Vấn đề còn mở 11); hashPassword chờ P07 UC-001, UC-017 |

Cột Nguồn AC của lớp dịch vụ và job ghi AC gốc đã tách theo P10 F3 (ví dụ DC-HoldExpiryJob tách từ AC-C-BookTicketsController). Lớp bên trong subsystem ghi "P11b SS-nn". Lớp thêm ở bước này ghi "Thiết kế: <lý do>": DC-RandomCodeGenerator và IF-24 (bộ sinh mã nhận qua constructor để X2 kiểm thử), IF-25 (kiểu Tx), DC-PgTx (hiện thực IF-25). Ba trạng thái "Tạm" của P08 (DC-Customer, DC-BoxOfficeClerk) giữ nguyên. Lớp không persistent không nằm trong P13.

F1b. Kiểu phụ trợ

| DC | Loại | PKG | Thành phần hoặc giá trị | Dùng trong chữ ký (DC.operation, IF.operation) |
|---|---|---|---|---|
| DC-TicketingIds | value object | PKG-28 | Nhóm kiểu định danh int64: SeatHoldId, BookingId, TicketId, PaymentTransactionId, RefundRequestId, CustomerId, BoxOfficeClerkId, EventId (mã seat_event). Gán khi lưu | IF-16 đến IF-22, DC-SeatHold, DC-Ticket |
| DC-HolderKind | enumeration | PKG-28 | CUSTOMER, CLERK (khách, nhân viên quầy: người giữ ghế) | DC-HolderRef |
| DC-HolderRef | value object | PKG-28 | kind (HolderKind), id (int64); so sánh bằng theo cả hai trường; hiện thực {xor} của R-48, R-49 | IF-16, IF-17, DC-SeatHold, DC-Customer |
| DC-ActorKind | enumeration | PKG-28 | CUSTOMER, CLERK, CHECKER (khách, nhân viên quầy, nhân viên soát vé) | DC-ActorContext |
| DC-ActorContext | value object | PKG-28 | kind (ActorKind), id (int64), cinemaId (CinemaId, 0 với khách); lấy từ SessionClaims của IF-07 do tầng gọi dựng. Hàm AsHolder() trả HolderRef khi kind là CUSTOMER hoặc CLERK | DC-CancelTicketService, DC-CheckTicketService, DC-Booking |
| DC-SeatKey | value object | PKG-28 | showtimeId (ShowtimeId), seatId (SeatId): định danh ghép của SeatStatus và khoá khoá dòng hạng 6 | DC-SeatStatus, DC-Ticket, IF-18 |
| DC-SeatState | enumeration | PKG-28 | AVAILABLE (Trống), HELD (Đang được giữ), SOLD (Đã bán) | DC-SeatStatus |
| DC-HoldStatus | enumeration | PKG-28 | ACTIVE (Đang giữ), COMPLETED (Đã hoàn tất), EXPIRED (Hết hạn), CANCELLED (Đã huỷ), PAYMENT_FAILED (Thanh toán thất bại) | DC-SeatHold |
| DC-TicketStatus | enumeration | PKG-28 | UNUSED (Chưa sử dụng), USED (Đã sử dụng), CANCELLED (Đã huỷ) | DC-Ticket |
| DC-PaymentStatus | enumeration | PKG-28 | PENDING (Chưa xử lý), FAILED (thất bại đã ghi nhận), TICKETED (Đã tạo vé), LATE_PAYMENT (Đã ghi nhận thanh toán trễ) | DC-PaymentTransaction |
| DC-RefundStatus | enumeration | PKG-28 | NEW (Mới), IN_FLIGHT (Đang chờ kết quả), WAITING_RETRY (Chờ gửi lại), REFUNDED (Đã hoàn), MANUAL_REQUIRED (Cần xử lý thủ công) | DC-RefundRequest |
| DC-RefundType | enumeration | PKG-28 | FULL (hoàn toàn bộ), TICKET_GATEWAY (hoàn một vé qua cổng), TICKET_CASH (hoàn một vé bằng tiền mặt) | DC-RefundRequest |
| DC-AttemptResult | enumeration | PKG-28 | SUCCEEDED, REJECTED, UNKNOWN: kết quả một lần gửi hoàn tiền, kiểu của Domain để DC-RefundRequest không phụ thuộc DC-RefundOutcome ở PKG-22 | DC-RefundRequest.RecordResult |
| DC-AdmitOutcome | enumeration | PKG-28 | ADMITTED, WRONG_CINEMA, WRONG_SHOWTIME, ALREADY_USED, CANCELLED (đúng thứ tự BR-33) | DC-Ticket.Admit |
| DC-HoldEndReason | enumeration | PKG-28 | EXPIRY (kết thúc vì hết hạn), CANCEL (người giữ ghế huỷ), PAYMENT_FAILURE (cổng báo thất bại) | DC-HoldSettlement.End |
| DC-HoldEndOutcome | value object | PKG-28 | holdChanged (bool: lần giữ ghế vừa đổi trạng thái, bên gọi phải UpdateStatus), expired (bool: lần giữ ghế đang ở Hết hạn), released ([]*SeatStatus: ghế vừa trả Trống, bên gọi phải SaveChanges) | DC-HoldSettlement.End |
| DC-SeatChangeEvent | value object | PKG-28 | eventId (EventId), showtimeId, createdAt (time.Time, đồng hồ CSDL), items (danh sách seatId + state mới) | IF-22, IF-04, DC-SeatMapService |
| DC-SeatSnapshot | value object | PKG-28 | showtimeId, showtimeChangedAt (lastChangedAt của suất chiếu, để quay lại gửi displayedAt ở BR-54), cursor (EventId lớn nhất đã thấy), cursorCreatedAt, seats (danh sách seatId, state, eventSeq của ghế) | IF-22.Snapshot, DC-SeatMapService.GetSnapshot |
| DC-BookingView | value object | PKG-28 | bookingCode, tickets (ticketCode, seatLabel, seatType, price, status, refundAmount, refundStatus) dùng hiển thị và gửi | DC-CancelTicketService.FindBooking, DC-BookTicketsService.ConfirmCashReceived |
| DC-HolderBusyError | exception | PKG-28 | Người giữ ghế còn lần giữ ghế chưa kết thúc (BR-04) | DC-Customer.CheckNoActiveSeatHold |
| DC-SeatUnavailableError | exception | PKG-28 | reason: NOT_AVAILABLE (ghế không Trống), LOCKED_BY_OTHER (55P03 của NOWAIT, ghế vừa có người chọn), BEING_RELEASED (55P03 nhưng ghế đang được trả về trống: lần giữ ghế trỏ tới đã ở trạng thái cuối hoặc quá expiry_time), NOT_FOUND | IF-18.LockForHold, IF-18.FindBeingReleased, DC-SeatStatus.HoldFor |
| DC-HoldNotActiveError | exception | PKG-28 | Lần giữ ghế không còn Đang giữ hoặc đã quá hạn; mang status hiện tại (BR-86) | DC-SeatHold.Complete, Cancel, FailPayment, DC-HoldSettlement.End, Sell |
| DC-LinkMismatchError | exception | PKG-28 | Liên kết hiện tại của ghế không khớp lần giữ ghế hoặc vé đang xử lý (R-63, R-64) | DC-SeatStatus.MarkSold, DC-HoldSettlement.Sell |
| DC-TicketStateError | exception | PKG-28 | Vé không ở trạng thái cho phép thao tác (đã huỷ, đã sử dụng); mang status (BR-21, BR-30) | DC-Ticket.Cancel |
| DC-ChannelMismatchError | exception | PKG-28 | Tác nhân huỷ không phải bên đã mua theo kênh (BR-17), hoặc nhân viên quầy thao tác trên suất chiếu ngoài cụm rạp của mình (BR-02) | DC-Booking.CheckCancellationChannel, DC-BookTicketsService.HoldSeats |
| DC-PaymentStateError | exception | PKG-28 | Giao dịch thanh toán không ở trạng thái cho phép chuyển (lỗi lập trình nếu xảy ra dưới khoá) | DC-PaymentTransaction.MarkTicketed |
| DC-RefundLimitError | exception | PKG-28 | Tổng hoàn vượt số tiền đã thanh toán (BR-26) | DC-PaymentTransaction.CheckRefundWithin, IF-19.AddRefunded |
| DC-RefundStateError | exception | PKG-28 | Yêu cầu hoàn không ở trạng thái cho phép chuyển | DC-RefundRequest.BeginAttempt |
| DC-Money | value object | PKG-27 | int64 đồng (VND), không âm. Operation: Add, Sub, Percent(p int) làm tròn xuống đồng (BR-31), GreaterThan; đổi sang int64(m) khi gọi IF-01, IF-02 (PKG-22 không phụ thuộc Domain) | DC-Ticket, DC-PaymentTransaction, DC-RefundRequest, DC-SeatStatus, IF-01 |
| DC-CinemaIds | value object | PKG-27 | Nhóm kiểu định danh int64: ShowtimeId, AuditoriumId, SeatId, CinemaId (Thiết kế: kiểu số để khoá theo thứ tự số tăng dần, P09 F7.3) | IF-11, IF-12, IF-13, IF-18, IF-04, DC-Showtime |
| DC-ShowtimeStatus | enumeration | PKG-27 | IN_SCHEDULE (Trong lịch chiếu), DELETED (Đã xoá) | DC-Showtime |
| DC-PriceQuery | value object | PKG-27 | auditoriumType, movieFormat, startTime, seatType (khoá tra mục giá, BR-11, BR-12) | DC-PriceList.DetermineSeatPrice |
| DC-ShowtimeRouting | value object | PKG-27 | auditoriumId, cinemaId: mã cần khoá trước khi khoá suất chiếu, đọc không khoá (P08 F4b quy tắc 7) | IF-11.FindRouting |
| DC-ShowtimeInfo | value object | PKG-27 | movieTitle, movieFormat, cinemaName, auditoriumName, startTime, endTime (dữ liệu hiển thị, đọc join) | IF-11.FindInfo, DC-CheckTicketService |
| DC-TxOptions | value object | PKG-27 | name, pool (USER / BACKGROUND), lockTimeout, maxDuration, deadline (hạn tổng tuyệt đối, có thể rỗng); hàm dựng UserTx(name), BackgroundTx(name), WithDeadline(t) (Thiết kế: lockTimeout 1 giây, maxDuration 4 giây, P09 F7.3; HoldSeats dùng deadline = lúc nhận yêu cầu + 1,8 giây) | IF-08.Do |
| DC-NotFoundError | exception | PKG-27 | Không tìm thấy dòng theo khoá | IF-11 đến IF-13, IF-16 đến IF-21 |
| DC-SystemBusyError | exception | PKG-27 | Hết thời gian chờ khoá hoặc deadlock sau 2 lần thử lại (hệ thống bận) | IF-08.Do |
| DC-ShowtimeNotOpenError | exception | PKG-27 | Chưa tới thời điểm mở bán hoặc đã tới giờ bắt đầu, hoặc suất chiếu Đã xoá (BR-01, BR-45) | DC-Showtime.CheckSaleOpen |
| DC-ShowtimeChangedError | exception | PKG-27 | Suất chiếu đã sửa hoặc xoá kể từ lúc hiển thị sơ đồ ghế (BR-54) | DC-Showtime.CheckUnchangedSince |
| DC-SeatSelectionError | exception | PKG-27 | reason: EMPTY, TOO_MANY (quá 8 ghế, BR-05), NOT_IN_AUDITORIUM, DUPLICATE | DC-Showtime.CheckSeatSelection |
| DC-CancelDeadlineError | exception | PKG-27 | Thời điểm kiểm tra cách giờ bắt đầu chưa tới 2 tiếng (BR-18, BR-32) | DC-Showtime.CheckCancellationDeadline |
| DC-HoldSeatsRequest | value object | PKG-13 | showtimeId, seatIds ([]SeatId), holder (HolderRef), holderCinemaId (CinemaId, 0 với khách; tầng gọi lấy từ ActorContext của phiên, không nhận từ trình duyệt), requestId (string, UUID của trình duyệt), displayedAt (time.Time, lastChangedAt lúc hiển thị sơ đồ ghế) | DC-BookTicketsService.HoldSeats |
| DC-HoldResult | value object | PKG-13 | holdId, holdRef, expiryTime, seats (seatId, label, seatType, price), total (Money), replayed (bool: true khi trả lại lần giữ ghế cùng requestId) | DC-BookTicketsService.HoldSeats, GetHold |
| DC-PaymentStart | value object | PKG-13 | transactionCode (string), paymentUrl (string) | DC-BookTicketsService.StartOnlinePayment |
| DC-SseFrame | value object | PKG-13 | id (string, mã sự kiện), event (string: seat, reload), data (string JSON); PKG-11 chỉ ghi ra kết nối | DC-SeatMapService.OpenStream |
| DC-SseStream | value object | PKG-13 | frames (<-chan SseFrame), close (func()); đóng thì gọi IF-04.Unsubscribe | DC-SeatMapService.OpenStream |
| DC-IpnOutcome | enumeration | PKG-14 | PROCESSED, DUPLICATE, INVALID_SIGNATURE, AMOUNT_MISMATCH, UNKNOWN_TRANSACTION, TEMPORARY_FAILURE, MALFORMED (thay DC-ReportHandlingResult của P11b) | DC-IpnAnswer |
| DC-IpnAnswer | value object | PKG-14 | outcome (IpnOutcome); không nêu mã HTTP hay RspCode, PKG-12 dịch sang câu trả lời của cổng (P10 F3 gộp từ DC-ReportReply) | DC-PaymentReportService.HandleIpn |
| DC-PaymentStatusView | value object | PKG-14 | holdRef, holdStatus (HoldStatus), paymentStatus (PaymentStatus của giao dịch mới nhất, rỗng nếu chưa có), bookingCode (rỗng nếu chưa có vé) | DC-PaymentReportService.QueryPaymentStatus |
| DC-CancelResult | value object | PKG-15 | ticketId, refundAmount (Money), refundType (TICKET_GATEWAY hoặc TICKET_CASH), refundStatus (RefundStatus lúc trả lời) | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund |
| DC-AdmitResult | value object | PKG-15 | outcome (AdmitOutcome), bookingCode, seatLabel, seatType (rỗng nếu không ADMITTED) | DC-CheckTicketService.CheckTicket |
| DC-LockRank | enumeration | PKG-21 | PRICE_LIST=1, AUDITORIUM=2, SHOWTIME=3, HOLDER=4, SEAT_HOLD=5, SEAT_STATUS=6, PAYMENT_TRANSACTION=7, TICKET=8, REFUND_REQUEST=9 (9 hạng của P08 F4b) | DC-LockOrderGuard |
| DC-LockKey | value object | PKG-21 | major (int64), minor (int64): khoá một dòng; SeatStatus dùng (mã suất chiếu, mã ghế), các hạng khác dùng (mã, 0) | DC-LockOrderGuard.Acquire |
| DC-LockOrderViolationError | exception | PKG-21 | Lời gọi khoá có hạng nhỏ hơn hạng lớn nhất đã lấy, hoặc cùng hạng mã nhỏ hơn; lỗi lập trình, không thử lại, giao dịch rollback | DC-LockOrderGuard, IF-08.Do |
| DC-OutboxKind | enumeration | PKG-21 | REFUND_GATEWAY, EMAIL_TICKET, EMAIL_REFUND | IF-23 |
| DC-OutboxStatus | enumeration | PKG-21 | PENDING (chờ), SUCCEEDED (thành công), EXHAUSTED (hết lần thử) | DC-OutboxEntry |
| DC-OutboxEntry | value object | PKG-21 | id, kind, sourceId (mã bản ghi nguồn), status, attemptCount, nextAttemptAt, claimToken, claimedUntil, idempotencyKey, lastError (P09 F7.7) | IF-23 |
| DC-ClaimLostError | exception | PKG-21 | claim_token không còn là của bên ghi kết quả (claim hết hạn và bị bản backend khác nhận) | IF-23.MarkSucceeded |
| DC-PaymentReport | value object | PKG-22 | outcome (SUCCEEDED, FAILED), transactionId, gatewayTransactionNo, holdReference (có thể rỗng), amount (int64, đồng), paidAt (có thể rỗng) (P11b F5) | IF-02 |
| DC-RefundOutcome | value object | PKG-22 | status (SUCCEEDED, REJECTED, UNKNOWN), gatewayRefundNo, reasonCode (P11b F5) | IF-01.RequestRefund |
| DC-RefundLookup | value object | PKG-22 | status (REFUNDED, NOT_REFUNDED, NOT_SUPPORTED, UNREACHABLE), refundedAmount (int64, đồng) (P11b F5) | IF-01.FindRefund |
| DC-InvalidGatewayRequestError | exception | PKG-22 | Tham số của bên gọi vi phạm tiền điều kiện (P11b F5) | IF-01 |
| DC-GatewayConfigurationError | exception | PKG-22 | Thiếu hoặc sai cấu hình bắt buộc của cổng (P11b F5) | IF-01 |
| DC-InvalidSignatureError | exception | PKG-22 | Chữ ký của thông báo không khớp (P11b F5) | IF-02 |
| DC-MalformedReportError | exception | PKG-22 | Thông báo thiếu tham số bắt buộc hoặc số tiền không là số (P11b F5) | IF-02 |
| DC-ReportHandlingResult | enumeration | PKG-22 | Gộp vào DC-IpnOutcome (PKG-14) theo P10 F3 (DC-ReportReply gộp vào DC-IpnAnswer); bỏ replyToReport khỏi IF-02. Mã P11b giữ, trạng thái Gộp | - |
| DC-SeatEventSubscription | value object | PKG-24 | subscriptionId (string), items (<-chan SeatStreamItem, bên gọi đọc) (P11b F5) | IF-04.Subscribe |
| DC-SeatStreamItem | value object | PKG-24 | kind (EVENT, RELOAD_REQUIRED, CLOSED), event (SeatChangeEvent, có khi EVENT), closeReason (SLOW_CONSUMER, UNSUBSCRIBED, SHUTDOWN, có khi CLOSED) (P11b F5) | IF-04.Subscribe, DC-SeatMapService |
| DC-SeatHubUnavailableError | exception | PKG-24 | Bộ phát chưa chạy, đang tắt hoặc đọc phát lại lỗi (P11b F5) | IF-04.Subscribe |
| DC-JobRunResult | value object | PKG-25 | processedCount (int), hasMore (bool: còn việc đến hạn khi hết ngân sách) (P11b F5) | IF-06.RunDue |
| DC-SchedulerStateError | exception | PKG-25 | Đăng ký sau Start, Start hai lần, tên công việc trùng hoặc chu kỳ không dương (P11b F5) | IF-05 |
| DC-Role | enumeration | PKG-26 | CUSTOMER, BOX_OFFICE_CLERK, TICKET_CHECKER, CINEMA_MANAGER, CHAIN_MANAGER, ADMINISTRATOR (P11b SS-05 F5) | IF-07 |
| DC-SessionClaims | value object | PKG-26 | subjectId (string), role (Role), cinemaId (string, rỗng với khách, quản lý chuỗi, quản trị viên), expiresAt (time.Time) (P11b SS-05 F5); tầng gọi dựng DC-ActorContext từ giá trị này | IF-07.VerifySession |
| DC-IssuedSession | value object | PKG-26 | token (string), expiresAt (time.Time) (P11b SS-05 F5) | IF-07.IssueSession |
| DC-SessionErrors | exception | PKG-26 | SessionInvalidError, SessionExpiredError, MalformedHashError, InvalidAuthRequestError (P11b SS-05 F5, bốn ngoại lệ) | IF-07 |

Lớp ngoài phạm vi mà lớp trong phạm vi tham chiếu (chỉ tên, không có dòng F1):

| DC | PKG | Lý do tham chiếu | Lượt chi tiết hoá |
|---|---|---|---|
| DC-Seat | PKG-27 | R-45 (SeatStatus --> Seat); nguồn Type(), Label() cho DC-PriceQuery và BookingView | PKG-27 |
| DC-Auditorium | PKG-27 | Tham số của DC-Showtime.QuoteSeatPrices; nguồn Type() cho DC-PriceQuery | PKG-27 |
| DC-PriceEntry | PKG-27 | Thành phần của DC-PriceList (R-41, composition) | PKG-27 |

Chữ ký interface tạm: Không có. IF-01, IF-02, IF-04, IF-05, IF-06, IF-07 đã có chữ ký ở P11b (chỉ đổi kiểu theo mục 0.2); IF-22 được chốt ở F2 (thay chữ ký tạm của P11b Vấn đề còn mở 6); IF-08, IF-11 đến IF-13, IF-16 đến IF-21, IF-23 do P12 thiết kế (P10 Vấn đề còn mở 6).

## F2. Bảng operation

Cột Phạm vi: Instance, hoặc Classifier (hàm dựng, hàm tĩnh). Visibility theo Go: + public (in hoa đầu), ~ nội bộ package, - nội bộ lớp. Chữ ký dùng Ctx = context.Context, Tx = IF-25 (mục 0.2). Operation của interface giữ tên và ngữ nghĩa P11b (tên đổi sang PascalCase của Go). Operation Bổ sung là getter để quan sát hậu điều kiện (Bước 2.4), không có setter.

F2.PKG-28 Ticketing

| DC | Visibility | Chữ ký | Mô tả | Tiền/hậu điều kiện | Nguồn (message P07 / UC bước) | Phạm vi | Ngoại lệ / lỗi |
|---|---|---|---|---|---|---|---|
| DC-SeatHold | + | NewSeatHold(holder HolderRef, showtimeId ShowtimeId, requestId string, holdRef string, now time.Time) *SeatHold | Tạo lần giữ ghế Đang giữ cho người giữ; expiryTime = now + HoldDuration | Tiền: now là tx.Now sau khi có khoá. Hậu: status ACTIVE | P08 AC-E-SeatHold// createSeatHold; ST-01 sự kiện create | Classifier | - |
| DC-SeatHold | + | Expire(now time.Time) bool | Chuyển ACTIVE sang EXPIRED khi now không trước expiryTime; trả true nếu có đổi; chạy lặp an toàn | BR-10, BR-85, BR-86. Hậu: trạng thái cuối không đổi | P08 AC-E-SeatHold// expire; ST-01 sự kiện expire | Instance | - |
| DC-SeatHold | + | Complete(now time.Time) error | Chuyển ACTIVE sang COMPLETED khi chưa quá hạn | Tiền: ACTIVE và now trước expiryTime (gọi Expire trước). Hậu: COMPLETED | P08 AC-E-SeatHold// endHold, completeSaleOnCashConfirmation; ST-01 | Instance | HoldNotActiveError |
| DC-SeatHold | + | Cancel(now time.Time) error | Chuyển ACTIVE sang CANCELLED khi tác nhân huỷ giữ ghế | Tiền: ACTIVE và chưa quá hạn. Hậu: CANCELLED | P08 AC-E-SeatHold// cancel; ST-01 | Instance | HoldNotActiveError |
| DC-SeatHold | + | FailPayment(now time.Time) error | Chuyển ACTIVE sang PAYMENT_FAILED khi cổng báo thất bại | Tiền: ACTIVE và chưa quá hạn. Hậu: PAYMENT_FAILED | P08 AC-E-SeatHold// endHold (báo thất bại); ST-01 | Instance | HoldNotActiveError |
| DC-SeatHold | + | IsActiveAt(now time.Time) bool | ACTIVE và now trước expiryTime | BR-04, BR-53, BR-85 | P08 AC-E-SeatHold// checkHoldStillActive | Instance | - |
| DC-SeatHold | + | IsHeldBy(holder HolderRef) bool | Người giữ ghế bằng holder | BR-17 | P08 AC-E-SeatHold// checkHeldBy | Instance | - |
| DC-SeatHold | + | CalculateTotal(seats []*SeatStatus) Money | Tổng heldPrice của các ghế đang giữ cho lần giữ ghế này: chỉ cộng ghế HELD có currentHold bằng ID của lần giữ ghế, bỏ qua ghế khác; danh sách rỗng trả 0 (Q-143) | BR-65 | P08 AC-E-SeatHold// calculateTotalAmount | Instance | - |
| DC-SeatHold | + | ID() SeatHoldId | Định danh | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-SeatHold | + | Ref() string | holdRef | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-SeatHold | + | Status() HoldStatus | Trạng thái hiện tại | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-SeatHold | + | ExpiryTime() time.Time | Thời điểm hết hạn | - | P08 AC-E-SeatHold// provideHoldSummary | Instance | - |
| DC-SeatHold | + | Holder() HolderRef | Người giữ ghế | - | P08 AC-E-SeatHold// checkHeldBy | Instance | - |
| DC-SeatHold | + | ShowtimeId() ShowtimeId | Suất chiếu của lần giữ ghế (R-46) | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-SeatStatus | + | NewAvailable(key SeatKey) *SeatStatus | Tạo trạng thái ghế Trống cho ghế của suất chiếu mới | Hậu: AVAILABLE, không có liên kết hiện tại | ST-02 sự kiện create | Classifier | - |
| DC-SeatStatus | + | HoldFor(holdId SeatHoldId, price Money) error | Chuyển AVAILABLE sang HELD, đặt currentHold là holdId và ghi giá đã chốt | BR-07, BR-08, BR-09. Tiền: AVAILABLE. Hậu: HELD, currentHold = holdId | P08 AC-E-SeatStatus// holdSeatFor, recordHeldPrice | Instance | SeatUnavailableError |
| DC-SeatStatus | + | MarkSold(holdId SeatHoldId, ticketId TicketId) error | Chuyển HELD sang SOLD khi currentHold đúng holdId; xoá currentHold, đặt currentTicket | BR-85. Tiền: HELD và currentHold = holdId. Hậu: SOLD | P08 AC-E-SeatStatus// markSold | Instance | LinkMismatchError |
| DC-SeatStatus | + | ReleaseHold(holdId SeatHoldId) bool | Về AVAILABLE chỉ khi HELD và currentHold = holdId; ngược lại không đổi; trả true nếu có đổi | REQ-76, R-63. Chạy lặp an toàn | P08 AC-E-SeatStatus// releaseSeat (lần giữ ghế) | Instance | - |
| DC-SeatStatus | + | IsHeldBy(holdId SeatHoldId) bool | State HELD và currentHold = holdId | R-63. Hậu: không đổi | Bổ sung: kiểm trước khi bán ghế (HandleIpn nhánh SELL) | Instance | - |
| DC-SeatStatus | + | ReleaseTicket(ticketId TicketId) bool | Về AVAILABLE chỉ khi SOLD và currentTicket = ticketId; ngược lại không đổi; trả true nếu có đổi | BR-42, R-64. Chạy lặp an toàn | P08 AC-E-SeatStatus// releaseSeat (vé) | Instance | - |
| DC-SeatStatus | + | IsAvailable() bool | Ghế Trống | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-SeatStatus | + | State() SeatState | Trạng thái ghế | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-SeatStatus | + | Key() SeatKey | Định danh ghép | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-SeatStatus | + | CurrentHold() (SeatHoldId, bool) | Lần giữ ghế hiện tại và có hay không (R-63) | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-SeatStatus | + | CurrentTicket() (TicketId, bool) | Vé hiện tại và có hay không (R-64) | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-SeatStatus | + | HeldPrice() Money | Giá đã chốt | - | P08 AC-E-SeatStatus// provideHeldSeatInfo | Instance | - |
| DC-PaymentTransaction | + | NewPending(hold *SeatHold, code string, amount Money) *PaymentTransaction | Tạo giao dịch chờ gắn lần giữ ghế (R-50), số tiền ghi lúc tạo | REQ-111. Hậu: PENDING | P08 AC-E-SeatHold// recordPaymentTransaction; AC-E-PaymentTransaction// createPaymentTransaction | Classifier | - |
| DC-PaymentTransaction | + | MarkTicketed(gatewayTransactionNo string, paidAt time.Time) error | PENDING sang TICKETED khi báo thành công đầu tiên tạo vé | BR-37. Tiền: PENDING | P08 AC-E-PaymentTransaction// markProcessed; ST-05 | Instance | PaymentStateError |
| DC-PaymentTransaction | + | MarkLatePayment(gatewayTransactionNo string, paidAt time.Time, reason string) error | PENDING hoặc FAILED sang LATE_PAYMENT, ghi lý do hoàn | BR-14, BR-15, BR-40 | P08 AC-E-PaymentTransaction// markLatePayment; ST-05 | Instance | PaymentStateError |
| DC-PaymentTransaction | + | RecordFailure() bool | PENDING sang FAILED; FAILED giữ nguyên; TICKETED và LATE_PAYMENT không đổi (chỉ ghi nhận); trả true nếu có đổi | BR-39 | P08 AC-E-PaymentTransaction// recordFailedResult; ST-05 | Instance | - |
| DC-PaymentTransaction | + | RecordDuplicate() error | Tăng duplicateReportCount khi giao dịch đã xử lý (TICKETED hoặc LATE_PAYMENT) | BR-37 | P08 AC-E-PaymentTransaction// recordDuplicateReport; ST-05 | Instance | PaymentStateError |
| DC-PaymentTransaction | + | IsProcessed() bool | Đã tạo vé hoặc đã ghi nhận thanh toán trễ | BR-37 | P08 AC-E-PaymentTransaction// checkNotProcessed | Instance | - |
| DC-PaymentTransaction | + | CheckRefundWithin(amount Money) error | Kiểm refundedTotal + amount không vượt amount | BR-26 | P08 AC-E-PaymentTransaction// checkRefundWithinPaidAmount | Instance | RefundLimitError |
| DC-PaymentTransaction | + | RecordRefunded(amount Money) error | Cộng amount vào refundedTotal trong bộ nhớ sau CheckRefundWithin; CSDL cộng bằng IF-19.AddRefunded | BR-26 | P08 AC-E-PaymentTransaction// recordRefundedAmount | Instance | RefundLimitError |
| DC-PaymentTransaction | + | ID() PaymentTransactionId | Định danh | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-PaymentTransaction | + | Code() string | Mã giao dịch | - | P08 AC-E-PaymentTransaction// provideRefundSummary | Instance | - |
| DC-PaymentTransaction | + | Amount() Money | Số tiền thanh toán | - | P08 AC-E-PaymentTransaction// provideRefundSummary | Instance | - |
| DC-PaymentTransaction | + | Status() PaymentStatus | Trạng thái xử lý | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-PaymentTransaction | + | PaidAt() time.Time | Thời điểm thanh toán thành công | - | P11b IF-01 requestRefund | Instance | - |
| DC-PaymentTransaction | + | GatewayTransactionNo() string | Mã giao dịch do cổng cấp, rỗng khi chưa có báo thành công | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-PaymentTransaction | + | LateReason() string | Lý do hoàn của thanh toán trễ, rỗng khi giao dịch không ở LATE_PAYMENT | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-PaymentTransaction | + | DuplicateReportCount() int | Số lần báo trùng đã ghi nhận | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-PaymentTransaction | + | RefundedTotal() Money | Tổng đã hoàn | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-RefundRequest | + | NewFullRefund(txn *PaymentTransaction, amount Money) *RefundRequest | Tạo yêu cầu hoàn toàn bộ; khoá = mã giao dịch + "-FULL" | BR-26, BR-43. Hậu: NEW | P08 AC-E-RefundRequest// createRefundRequest, generateIdempotencyKey | Classifier | - |
| DC-RefundRequest | + | NewTicketRefund(txn *PaymentTransaction, ticket *Ticket, amount Money) *RefundRequest | Tạo yêu cầu hoàn một vé qua cổng; khoá = mã giao dịch + "-T" + mã vé | BR-43. Hậu: NEW | P08 AC-E-RefundRequest// createRefundRequest, generateIdempotencyKey | Classifier | - |
| DC-RefundRequest | + | NewCashRefund(ticket *Ticket, amount Money) *RefundRequest | Tạo yêu cầu hoàn tiền mặt không gắn giao dịch, đã REFUNDED | BR-20 | P08 AC-E-Ticket// recordCashRefund | Classifier | - |
| DC-RefundRequest | + | BeginAttempt() error | NEW hoặc WAITING_RETRY sang IN_FLIGHT, tăng attemptCount; IN_FLIGHT sang IN_FLIGHT khi nhận lại claim sau khi tiến trình chết (tăng attemptCount), chỉ khi HasAttemptsRemaining | BR-43, Q-118. Hết lượt thì RefundStateError, bên gọi chuyển sang MarkManualRequired. Bất biến: ở NEW và WAITING_RETRY luôn còn lượt (RecordResult chỉ tạo WAITING_RETRY khi còn lượt), nên hết lượt chỉ xảy ra khi nhận lại claim ở IN_FLIGHT | P08 AC-E-RefundRequest// recordAttempt; ST-04 | Instance | RefundStateError |
| DC-RefundRequest | + | RecordResult(r AttemptResult, detail string) error | IN_FLIGHT: SUCCEEDED sang REFUNDED; REJECTED hoặc UNKNOWN sang WAITING_RETRY khi còn lượt, hết lượt sang MANUAL_REQUIRED | BR-41, Q-118 | P08 AC-E-RefundRequest// recordResult; ST-04 | Instance | RefundStateError |
| DC-RefundRequest | + | MarkManualRequired(reason string) error | Chuyển MANUAL_REQUIRED từ IN_FLIGHT khi không tra cứu được kết quả hoàn, hoặc nhận lại claim mà hết lượt. Là trạng thái cuối, không có đường đặt lại trong hệ thống (Q-135) | BR-41, Q-118 | P08 AC-E-PaymentReportController// logRefundFailure; ST-04 | Instance | RefundStateError |
| DC-RefundRequest | + | HasAttemptsRemaining() bool | attemptCount nhỏ hơn MaxAttempts | BR-41 | P08 AC-E-RefundRequest// checkRetryRemaining | Instance | - |
| DC-RefundRequest | + | Status() RefundStatus | Trạng thái xử lý | - | P08 AC-E-RefundRequest// provideRefundInfo | Instance | - |
| DC-RefundRequest | + | Amount() Money | Số tiền hoàn | - | P08 AC-E-RefundRequest// provideRefundInfo | Instance | - |
| DC-RefundRequest | + | IdempotencyKey() string | Khoá chống hoàn trùng | - | P11b IF-01 requestRefund | Instance | - |
| DC-RefundRequest | + | AttemptCount() int | Số lần đã gửi | - | P09 F7.7 (findRefund khi lớn hơn 1) | Instance | - |
| DC-RefundRequest | + | RequestType() RefundType | Loại yêu cầu hoàn (toàn bộ, một vé qua cổng, một vé bằng tiền mặt); bên gọi dùng để quyết định xếp email hoàn tiền | - | Bổ sung: quan sát hậu điều kiện; P12 F3 ProcessRefund bước 3 | Instance | - |
| DC-RefundRequest | + | RefundResult() string | Mã kết quả hoặc lý do lỗi của lần gửi cuối (detail của RecordResult, reason của MarkManualRequired) | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-Booking | + | NewBooking(hold *SeatHold, code string, seats []*SeatStatus, ticketCodes []string) *Booking | Tạo lần đặt cho lần giữ ghế đã hoàn tất, và tự tạo một vé cho mỗi ghế bằng newTicket(key, heldPrice, ticketCodes[i]) (R-51, R-52) | BR-80. Tiền: hold COMPLETED trong cùng giao dịch; len(ticketCodes) = len(seats) | P08 AC-E-Booking// createBooking; AC-E-SeatHold// issueBooking | Classifier | - |
| DC-Booking | + | CheckCancellationChannel(actor ActorContext) error | Khách chỉ huỷ vé mình mua trực tuyến, nhân viên quầy chỉ huỷ vé mua tại quầy | BR-17 | P08 AC-E-Booking// checkCancellationChannel | Instance | ChannelMismatchError |
| DC-Booking | + | Code() string | Mã đặt vé | - | P08 AC-E-Booking// provideBookingCode | Instance | - |
| DC-Booking | + | Tickets() []*Ticket | Vé của lần đặt | - | P08 AC-E-Booking// provideBookingInfo | Instance | - |
| DC-Booking | + | ID() BookingId | Định danh | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-Ticket | ~ | newTicket(key SeatKey, price Money, code string) *Ticket | Tạo vé Chưa sử dụng cho ghế đã bán, ghi giá đã chốt | BR-67. Hậu: UNUSED | P08 AC-E-Ticket// createTicket, generateQrCode; ST-03 sự kiện create | Classifier | - |
| DC-Ticket | + | Cancel() error | UNUSED sang CANCELLED; kiểm đã huỷ trước, đã sử dụng sau | BR-21, BR-30 | P08 AC-E-Ticket// cancelTicket, checkNotCancelledNotUsed, markCancelled; ST-03 | Instance | TicketStateError |
| DC-Ticket | + | Admit(showtime *Showtime, selected ShowtimeId, cinemaId CinemaId) AdmitOutcome | Kiểm theo thứ tự cụm rạp, suất chiếu, đã sử dụng, đã huỷ; hợp lệ thì chuyển USED; trả ADMITTED hoặc một lý do duy nhất | BR-22 đến BR-25, BR-30, BR-33. Hậu: USED chỉ khi ADMITTED | P08 AC-E-Ticket// admitTicket, markUsed; ST-03 | Instance | - |
| DC-Ticket | + | RefundAmount() Money | price.Percent(RefundPercent), làm tròn xuống đồng | BR-19, BR-31 | P08 AC-E-Ticket// calculateRefundAmount | Instance | - |
| DC-Ticket | + | IsCancelled() bool | Vé đã huỷ | BR-53 | P08 AC-E-Ticket// checkNotCancelled | Instance | - |
| DC-Ticket | + | ID() TicketId | Định danh | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-Ticket | + | Code() string | Mã vé | - | P08 AC-E-Ticket// provideTicketContent | Instance | - |
| DC-Ticket | + | Price() Money | Giá vé đã chốt | - | P08 AC-E-Ticket// provideTicketContent | Instance | - |
| DC-Ticket | + | Status() TicketStatus | Trạng thái vé | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-Ticket | + | Key() SeatKey | Ghế của vé (R-54) | - | P08 AC-E-Ticket// releaseTicketSeat | Instance | - |
| DC-HoldSettlement | + | End(now time.Time, hold *SeatHold, reason HoldEndReason, seats []*SeatStatus) (HoldEndOutcome, error) | Kết thúc lần giữ ghế: luôn gọi hold.Expire(now) trước; EXPIRY thì chỉ Expire; CANCEL, PAYMENT_FAILURE thì Cancel hoặc FailPayment khi chưa quá hạn; rồi ReleaseHold(hold.ID) từng ghế trong seats và trả các ghế đã đổi. Gọi lặp an toàn: lần giữ ghế đã Hết hạn thì EXPIRY chỉ trả ghế còn trỏ tới nó; seats rỗng hoặc nil thì chỉ đổi trạng thái | BR-04, BR-10, BR-85, BR-86. Tiền: seats đã khoá hạng 6 (hoặc rỗng). Hậu: ghế trả về có state AVAILABLE; trạng thái cuối khác không đổi; EXPIRY không bao giờ trả lỗi | X1 RV-01; P08 AC-E-SeatHold// expire, cancel, endHold; ST-01 | Instance | HoldNotActiveError (chỉ CANCEL, PAYMENT_FAILURE khi lần giữ ghế không còn Đang giữ) |
| DC-HoldSettlement | + | Sell(now time.Time, hold *SeatHold, seats []*SeatStatus, bookingCode string, ticketCodes []string) (*Booking, error) | Bán ghế: kiểm seats không rỗng, mọi ghế IsHeldBy(hold.ID), len(ticketCodes) = len(seats) (sai thì LinkMismatchError, chưa đổi gì); hold.Complete(now); NewBooking (tự tạo vé). Chưa đánh dấu ghế vì mã vé do kho gán khi InsertWithTickets | BR-67, BR-80, BR-85. Tiền: seats đã khoá hạng 6. Hậu: hold COMPLETED, Booking kèm vé UNUSED chưa có id | X1 RV-01; P08 AC-E-SeatHold// issueBooking, endHold; ST-01, ST-03 | Instance | LinkMismatchError, HoldNotActiveError |
| DC-HoldSettlement | + | FinishSale(hold *SeatHold, booking *Booking, seats []*SeatStatus) error | Sau InsertWithTickets: MarkSold(hold.ID, ticketId) cho từng ghế theo khoá ghế của vé | R-63, R-64. Tiền: booking đã được kho gán id vé. Hậu: ghế SOLD, cần SaveChanges | X1 RV-01; P08 AC-E-SeatStatus// markSold | Instance | LinkMismatchError |
| DC-Customer | + | Ref() HolderRef | Tham chiếu người giữ ghế kind CUSTOMER | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-Customer | + | CheckNoActiveSeatHold(unfinished []*SeatHold, now time.Time) error | Từ chối khi có lần giữ ghế ACTIVE chưa quá hạn trong unfinished | BR-04 | P08 AC-E-Customer// checkNoActiveSeatHold | Instance | HolderBusyError |
| DC-Customer | + | Email() string | Email của khách | - | P08 AC-E-Customer// provideEmail | Instance | - |
| DC-BoxOfficeClerk | + | Ref() HolderRef | Tham chiếu người giữ ghế kind CLERK | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-BoxOfficeClerk | + | CheckNoActiveSeatHold(unfinished []*SeatHold, now time.Time) error | Từ chối khi có lần giữ ghế ACTIVE chưa quá hạn trong unfinished | BR-04 | P08 AC-E-BoxOfficeClerk// checkNoActiveSeatHold | Instance | HolderBusyError |
| DC-BoxOfficeClerk | + | CinemaId() CinemaId | Cụm rạp của nhân viên (R-57) | BR-02 | P08 AC-E-BoxOfficeClerk// provideCinema | Instance | - |
| IF-16 | + | LockHolder(ctx Ctx, tx Tx, ref HolderRef) error | SELECT FOR NO KEY UPDATE dòng người giữ ghế; tuần tự hoá mọi EX-01 của cùng người (X-02) | Hạng 4 | P10 F3a EX-01 | Instance | NotFoundError, SystemBusyError |
| IF-16 | + | FindCustomer(ctx Ctx, tx Tx, id CustomerId) (*Customer, error) | Đọc không khoá | Hậu: không khoá | P08 AC-E-Customer// provideEmail | Instance | NotFoundError |
| IF-17 | + | LockUnfinishedOrByRequest(ctx Ctx, tx Tx, holder HolderRef, requestId string) ([]*SeatHold, error) | Khoá X lần giữ ghế ACTIVE của người giữ ghế và lần giữ ghế cùng requestId của chính người giữ ghế (lọc holder trong câu SQL), theo mã tăng dần (tối đa 2 dòng) | Hạng 5 | P10 F3a EX-01 | Instance | SystemBusyError |
| IF-17 | + | LockByID(ctx Ctx, tx Tx, id SeatHoldId) (*SeatHold, error) | SELECT FOR NO KEY UPDATE một lần giữ ghế | Hạng 5 | P10 F3a EX-02, EX-03, EX-04 | Instance | NotFoundError, SystemBusyError |
| IF-17 | + | FindIDByRef(ctx Ctx, holdRef string) (SeatHoldId, error) | Tra không khoá mã lần giữ ghế từ mã tham chiếu | Hậu: không khoá | P10 F3a EX-02 | Instance | NotFoundError |
| IF-17 | + | Insert(ctx Ctx, tx Tx, h *SeatHold) error | Thêm lần giữ ghế, gán id; unique của requestId và người giữ ghế ACTIVE là lưới an toàn | - | P08 AC-E-SeatHold// createSeatHold | Instance | lỗi unique |
| IF-17 | + | UpdateStatus(ctx Ctx, tx Tx, h *SeatHold) error | UPDATE status với điều kiện status hiện tại là ACTIVE | Đã giữ khoá hạng 5 | ST-01 | Instance | lỗi trạng thái đồng thời |
| IF-18 | + | LockForHold(ctx Ctx, tx Tx, showtimeId ShowtimeId, seatIds []SeatId) ([]*SeatStatus, error) | SELECT ORDER BY (suất chiếu, ghế) FOR NO KEY UPDATE NOWAIT, không lọc trạng thái | Hạng 6. Ghế bị khoá thì SeatUnavailableError(LOCKED_BY_OTHER), không thử lại | P10 F3a EX-01 | Instance | SeatUnavailableError |
| IF-18 | + | FindBeingReleased(ctx Ctx, showtimeId ShowtimeId, seatIds []SeatId) (bool, error) | Đọc không khoá, ngoài giao dịch giữ ghế (sau khi rollback vì 55P03): true nếu có ghế ở Đang được giữ mà lần giữ ghế trỏ tới (current_hold_id) đã ở trạng thái cuối hoặc quá expiry_time so với clock_timestamp() | Chỉ chọn thông điệp, không dùng để quyết định giữ ghế; không lấy khoá nên không thuộc hạng | P09 F7.3 EX-01 | Instance | lỗi CSDL |
| IF-18 | + | LockByHold(ctx Ctx, tx Tx, holdId SeatHoldId) ([]*SeatStatus, error) | Khoá X các ghế có current_hold_id = holdId, ORDER BY (suất chiếu, ghế) | Hạng 6 | P10 F3a EX-02, EX-03, EX-05 | Instance | SystemBusyError |
| IF-18 | + | LockByKey(ctx Ctx, tx Tx, key SeatKey) (*SeatStatus, error) | Khoá X một ghế theo khoá ghép | Hạng 6 | P10 F3a EX-06 | Instance | NotFoundError, SystemBusyError |
| IF-18 | + | FindByHold(ctx Ctx, tx Tx, holdId SeatHoldId) ([]*SeatStatus, error) | Đọc không khoá các ghế của lần giữ ghế (đã giữ khoá lần giữ ghế) | Hậu: không khoá | P08 AC-E-SeatStatus// provideHeldSeatInfo | Instance | - |
| IF-18 | + | SaveChanges(ctx Ctx, tx Tx, changed []*SeatStatus) error | UPDATE các ghế đã khoá theo khoá chính (liên kết hiện tại đã được kiểm trong bộ nhớ dưới khoá X), lấy mã sự kiện từ sequence ghi vào event_seq của từng ghế; dòng seat_event mỗi suất chiếu được PgTx gom lại và INSERT ở câu cuối cùng ngay trước COMMIT | Đã giữ khoá hạng 6. Gọi được nhiều lần trong một giao dịch: mỗi lần mỗi ghế một UPDATE theo khoá chính với trạng thái hiện tại, mã sự kiện lấy một lần cho giao dịch và dùng lại ở các lần sau. Bên gọi không dồn hai thay đổi liên tiếp của cùng một ghế (trả rồi giữ lại) vào một lần gọi vì trg_seat_status_link (P13) từ chối UPDATE đổi liên kết từ giá trị này sang giá trị khác. Không gọi NOTIFY. Hậu: khoảng từ INSERT seat_event tới COMMIT chỉ bị chặn bởi idle_in_transaction_session_timeout 5 giây (P09 F7.5 điểm 3) | P09 F7.5 điểm 1 | Instance | lỗi CSDL |
| IF-18 | + | InsertAll(ctx Ctx, tx Tx, all []*SeatStatus) error | Thêm trạng thái ghế của suất chiếu mới | - | ST-02 sự kiện create | Instance | lỗi unique |
| IF-19 | + | FindByCode(ctx Ctx, code string) (*PaymentTransaction, error) | Tra không khoá theo mã giao dịch | Hậu: không khoá | P10 F3a EX-02 | Instance | NotFoundError |
| IF-19 | + | FindByID(ctx Ctx, tx Tx, id PaymentTransactionId) (*PaymentTransaction, error) | Đọc không khoá theo mã (mã giao dịch, thời điểm trả tiền cho lần gửi hoàn) | Hậu: không khoá | P10 F3a EX-10 | Instance | NotFoundError |
| IF-19 | + | LockByCode(ctx Ctx, tx Tx, code string) (*PaymentTransaction, error) | SELECT FOR NO KEY UPDATE theo mã giao dịch | Hạng 7 | P10 F3a EX-02 | Instance | NotFoundError, SystemBusyError |
| IF-19 | + | LockByID(ctx Ctx, tx Tx, id PaymentTransactionId) (*PaymentTransaction, error) | SELECT FOR NO KEY UPDATE theo mã | Hạng 7 | P10 F3a EX-09 | Instance | NotFoundError, SystemBusyError |
| IF-19 | + | FindTicketedByHold(ctx Ctx, tx Tx, holdId SeatHoldId) (*PaymentTransaction, error) | Đọc không khoá giao dịch TICKETED của lần giữ ghế | Hậu: không khoá | P08 AC-E-SeatHold// providePaymentTransaction | Instance | NotFoundError |
| IF-19 | + | FindLatestByHold(ctx Ctx, tx Tx, holdId SeatHoldId) (*PaymentTransaction, error) | Đọc không khoá giao dịch được tạo sau cùng của lần giữ ghế (mọi trạng thái) | Hậu: không khoá. Dùng dưới khoá hạng 5 để quyết định báo thất bại có làm hỏng lần giữ ghế hay không | P09 F7.6 | Instance | NotFoundError |
| IF-19 | + | Insert(ctx Ctx, tx Tx, t *PaymentTransaction) error | Thêm giao dịch (đã gắn lần giữ ghế qua NewPending), gán id; unique của code | - | P08 AC-E-PaymentTransaction// createPaymentTransaction | Instance | lỗi unique |
| IF-19 | + | UpdateStatus(ctx Ctx, tx Tx, t *PaymentTransaction) error | Ghi status, gatewayTransactionNo, paidAt, lateReason, duplicateReportCount | Đã giữ khoá hạng 7 | ST-05 | Instance | lỗi CSDL |
| IF-19 | + | AddRefunded(ctx Ctx, tx Tx, id PaymentTransactionId, amount Money) error | UPDATE refunded_total = refunded_total + amount WHERE refunded_total + amount <= paid_amount; 0 dòng thì lỗi (phép cộng nằm trong câu UPDATE) | Đã giữ khoá hạng 7. BR-26, X-16 | P10 F3a EX-09 | Instance | RefundLimitError |
| IF-20 | + | InsertWithTickets(ctx Ctx, tx Tx, b *Booking) error | Thêm lần đặt và các vé, gán id; unique của bookingCode, ticketCode, vé chưa huỷ mỗi ghế là lưới an toàn | - | P08 AC-E-Booking// createBooking | Instance | lỗi unique |
| IF-20 | + | FindByCode(ctx Ctx, tx Tx, bookingCode string) (*Booking, error) | Đọc không khoá lần đặt và vé theo mã đặt vé | Hậu: không khoá | P08 AC-E-CancelTicketController// findBookingTickets | Instance | NotFoundError |
| IF-20 | + | FindByTicket(ctx Ctx, tx Tx, ticketId TicketId) (*Booking, error) | Đọc không khoá lần đặt chứa vé (kênh, người mua, lần giữ ghế) | Hậu: không khoá | P08 AC-E-Booking// checkCancellationChannel | Instance | NotFoundError |
| IF-20 | + | FindByHold(ctx Ctx, tx Tx, holdId SeatHoldId) (*Booking, error) | Đọc không khoá lần đặt của lần giữ ghế (R-51) | Hậu: không khoá | P08 AC-E-SeatHold// issueBooking | Instance | NotFoundError |
| IF-21 | + | Insert(ctx Ctx, tx Tx, r *RefundRequest) error | Thêm yêu cầu hoàn (đã gắn giao dịch và vé qua factory, R-55, R-56), gán id; unique của idempotencyKey | - | P08 AC-E-RefundRequest// createRefundRequest | Instance | lỗi unique |
| IF-21 | + | LockByID(ctx Ctx, tx Tx, id RefundRequestId) (*RefundRequest, error) | SELECT FOR NO KEY UPDATE | Hạng 9 | P10 F3a EX-10 | Instance | NotFoundError, SystemBusyError |
| IF-21 | + | Update(ctx Ctx, tx Tx, r *RefundRequest) error | Ghi status, attemptCount, refundResult | Đã giữ khoá hạng 9 | ST-04 | Instance | lỗi CSDL |
| IF-21 | + | FindByTicket(ctx Ctx, tx Tx, ticketId TicketId) (*RefundRequest, error) | Đọc không khoá yêu cầu hoàn của vé (R-56) | Hậu: không khoá | P08 AC-E-Ticket// provideTicketContent | Instance | NotFoundError |
| IF-21 | + | FindTransactionAndTicket(ctx Ctx, tx Tx, id RefundRequestId) (PaymentTransactionId, TicketId, error) | Đọc không khoá hai khoá ngoại R-55, R-56 của yêu cầu hoàn | Hậu: không khoá | P10 F3a EX-10 | Instance | NotFoundError |
| IF-26 | + | LockExpiredBatch(ctx Ctx, tx Tx, limit int) ([]*SeatHold, error) | Chọn mã ứng viên ACTIVE đã quá expiry_time không khoá, rồi khoá X theo mã tăng dần với SKIP LOCKED | Hạng 5 | P10 F3a EX-04; P09 F7.4 bước 1 | Instance | - |
| IF-26 | + | LockReleasableBatch(ctx Ctx, tx Tx, limit int) ([]*SeatHold, error) | Khoá X, SKIP LOCKED, mã tăng dần các lần giữ ghế ở trạng thái cuối khác COMPLETED mà còn ghế trỏ tới | Hạng 5 | P10 F3a EX-05; P09 F7.4 bước 2 | Instance | - |
| IF-26 | + | LockByHolds(ctx Ctx, tx Tx, holdIds []SeatHoldId) ([]*SeatStatus, error) | Như LockByHold cho cả lô | Hạng 6 | P10 F3a EX-05 (quét lô) | Instance | SystemBusyError |
| IF-27 | + | LockTicketByID(ctx Ctx, tx Tx, id TicketId) (*Ticket, error) | SELECT FOR NO KEY UPDATE vé | Hạng 8 | P10 F3a EX-07 | Instance | NotFoundError, SystemBusyError |
| IF-27 | + | LockTicketByCode(ctx Ctx, tx Tx, code string) (*Ticket, error) | SELECT FOR NO KEY UPDATE vé theo mã vé | Hạng 8 | P10 F3a EX-08 | Instance | NotFoundError, SystemBusyError |
| IF-27 | + | LockTicketShared(ctx Ctx, tx Tx, id TicketId) (*Ticket, error) | SELECT FOR SHARE vé | Hạng 8 | P10 F3a EX-10 | Instance | NotFoundError, SystemBusyError |
| IF-27 | + | UpdateTicketStatus(ctx Ctx, tx Tx, t *Ticket) error | Ghi status của vé | Đã giữ khoá hạng 8 | ST-03 | Instance | lỗi CSDL |

F2.PKG-27 CinemaOperations

| DC | Visibility | Chữ ký | Mô tả | Tiền/hậu điều kiện | Nguồn (message P07 / UC bước) | Phạm vi | Ngoại lệ / lỗi |
|---|---|---|---|---|---|---|---|
| DC-Showtime | + | CheckSaleOpen(now time.Time) error | Kiểm tra đã mở bán và chưa tới giờ bắt đầu; trả ShowtimeNotOpenError | Tiền: now lấy từ tx.Now. Hậu: không đổi | P08 AC-E-Showtime// checkSaleOpen | Instance | ShowtimeNotOpenError |
| DC-Showtime | + | CheckUnchangedSince(displayedAt time.Time) error | So lastChangedAt với mốc lúc hiển thị sơ đồ ghế và kiểm chưa Đã xoá | BR-54. Hậu: không đổi | P08 AC-E-Showtime// checkUnchangedSinceDisplayed | Instance | ShowtimeChangedError |
| DC-Showtime | + | CheckSeatSelection(selected []*Seat) error | Kiểm 1 đến MaxSeatsPerHold ghế, không trùng, đều thuộc phòng chiếu của suất chiếu; khi nhiều lý do cùng đúng báo theo thứ tự EMPTY, TOO_MANY, DUPLICATE, NOT_IN_AUDITORIUM (Q-152) | BR-05, BR-06 | P08 AC-E-Showtime// checkSeatSelectionLimit | Instance | SeatSelectionError |
| DC-Showtime | + | QuoteSeatPrices(list *PriceList, room *Auditorium, seats []*Seat) (map[SeatId]Money, error) | Chốt giá từng ghế bằng PriceList.DetermineSeatPrice theo loại phòng, định dạng, khung giờ, loại ghế | BR-65, BR-71, BR-72. Hậu: không đổi | P08 AC-E-Showtime// holdSeats (phần chốt giá, Q-117) | Instance | NotFoundError |
| DC-Showtime | + | BelongsToCinema(cinemaId CinemaId) bool | Suất chiếu thuộc cụm rạp của tác nhân | BR-02, BR-17, BR-22, BR-34 | P08 AC-E-Showtime// checkBelongsToCinema | Instance | - |
| DC-Showtime | + | CheckCancellationDeadline(now time.Time) error | Kiểm now cách giờ bắt đầu ít nhất 2 tiếng | BR-18, BR-32 | P08 AC-E-Showtime// checkCancellationDeadline | Instance | CancelDeadlineError |
| DC-Showtime | + | ID() ShowtimeId | Định danh | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-Showtime | + | StartTime() time.Time | Giờ bắt đầu | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-Showtime | + | Status() ShowtimeStatus | Trạng thái suất chiếu | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-Showtime | + | LastChangedAt() time.Time | Mốc thay đổi gần nhất, đưa ra màn hình để quay lại ở BR-54 | - | P08 AC-E-Showtime// provideShowtimeInfo | Instance | - |
| DC-PriceList | + | DetermineSeatPrice(q PriceQuery) (Money, error) | Tìm mục giá khớp q, khung giờ và ngày trong tuần xác định từ q.startTime đổi sang múi giờ Asia/Ho_Chi_Minh (UTC+7, múi giờ cố định của chuỗi rạp, Q-151); trả giá vé | BR-11, BR-12, BR-72. Hậu: không đổi | P08 AC-E-PriceList// determineSeatPrice | Instance | NotFoundError |
| IF-08 | + | Do(ctx Ctx, opts TxOptions, fn func(tx Tx) error) error | Mở giao dịch, gọi fn, commit khi fn trả nil, rollback khi trả lỗi; thử lại tối đa 2 lần khi 40P01 hoặc 55P03 chưa được store dịch thành lỗi nghiệp vụ | Tiền: fn idempotent với rollback. Hậu: commit trọn vẹn hoặc không dấu vết. Lỗi nghiệp vụ cần ghi lại thì fn trả nil và ghi kết quả vào biến của bên gọi. fn có thể chạy lại từ đầu nên bên gọi đặt lại biến kết quả ở đầu fn. Không thử lại sau lỗi COMMIT không có SQLSTATE (kết quả mơ hồ: giao dịch có thể đã commit, các thao tác đều idempotent theo trạng thái nên bên gọi tự kiểm lại). Panic trong fn được recover, rollback và trả lỗi. Hạn maxDuration tính từ ngay trước khi lấy kết nối. Khi opts.deadline không rỗng: hạn mỗi lần thử là nhỏ hơn của maxDuration và phần hạn còn lại, lockTimeout bị cắt theo phần hạn còn lại, chờ lấy kết nối không vượt phần hạn còn lại, và chỉ thử lại khi còn ít nhất 1 giây; hết hạn thì SystemBusyError | P10 F3a quy tắc áp dụng; P09 F7.3 | Instance | SystemBusyError, lỗi của fn, context.DeadlineExceeded |
| IF-25 | + | Now(ctx Ctx) (time.Time, error) | Thời điểm hiện tại của CSDL (clock_timestamp()), lấy một lần cho giao dịch rồi trả lại đúng giá trị đó ở lần gọi sau | Tiền: gọi sau khi đã lấy khoá cần thiết (P09 F7.2). Hậu: giá trị không đổi trong giao dịch | P10 F3a quy tắc áp dụng; P09 F7.2 | Instance | lỗi CSDL |
| IF-11 | + | FindRouting(ctx Ctx, id ShowtimeId) (ShowtimeRouting, error) | Đọc không khoá mã phòng chiếu và cụm rạp để biết cần khoá gì | Hậu: không khoá | P08 F4b quy tắc 7 | Instance | NotFoundError |
| IF-11 | + | LockShared(ctx Ctx, tx Tx, id ShowtimeId) (*Showtime, error) | SELECT FOR SHARE dòng suất chiếu (hạng 3) | Hạng 3 | P10 F3a EX-01 | Instance | NotFoundError, SystemBusyError |
| IF-11 | + | FindByID(ctx Ctx, tx Tx, id ShowtimeId) (*Showtime, error) | Đọc không khoá (soát vé, huỷ vé) | Hậu: không khoá | P10 F3a EX-07, EX-08 | Instance | NotFoundError |
| IF-11 | + | FindInfo(ctx Ctx, id ShowtimeId) (ShowtimeInfo, error) | Đọc join dữ liệu hiển thị của suất chiếu | Hậu: không khoá | P08 AC-E-Showtime// provideShowtimeInfo | Instance | NotFoundError |
| IF-12 | + | LockSharedByCinema(ctx Ctx, tx Tx, cinemaId CinemaId) (*PriceList, error) | SELECT FOR SHARE dòng bảng giá cùng các mục giá (hạng 1) | Hạng 1 | P10 F3a EX-01 | Instance | NotFoundError, SystemBusyError |
| IF-13 | + | LockAuditoriumShared(ctx Ctx, tx Tx, id AuditoriumId) (*Auditorium, error) | SELECT FOR SHARE dòng phòng chiếu (hạng 2) | Hạng 2 | P10 F3a EX-01 | Instance | NotFoundError, SystemBusyError |
| IF-13 | + | FindSeats(ctx Ctx, tx Tx, ids []SeatId) ([]*Seat, error) | Đọc không khoá các ghế theo mã (dữ liệu bố cục tĩnh) | Hậu: không khoá | P08 AC-E-Showtime// checkSeatSelectionLimit | Instance | NotFoundError |
| IF-24 | + | NewHoldRef() string | Mã tham chiếu lần giữ ghế, UUID v4 (REQ-136) | - | P08 AC-E-SeatHold// createSeatHold | Instance | - |
| IF-24 | + | NewTransactionCode() string | Mã giao dịch thanh toán gửi cổng (20 ký tự chữ số, Thiết kế: giới hạn trường mã tham chiếu của cổng) | - | P08 AC-E-PaymentTransaction// createPaymentTransaction | Instance | - |
| IF-24 | + | NewBookingCode() string | Mã đặt vé duy nhất (BR-80); đụng độ do unique của CSDL thì gọi lại | - | P08 AC-E-Booking// generateBookingCode | Instance | - |
| IF-24 | + | NewTicketCode() string | Mã vé 16 ký tự ngẫu nhiên không đoán được, cũng là nội dung mã QR (NFR-14) | - | P08 AC-E-Ticket// generateQrCode | Instance | - |
| DC-RandomCodeGenerator | + | NewHoldRef() string | Hiện thực IF-24 | - | IF-24.NewHoldRef | Instance | - |
| DC-RandomCodeGenerator | + | NewTransactionCode() string | Hiện thực IF-24 | - | IF-24.NewTransactionCode | Instance | - |
| DC-RandomCodeGenerator | + | NewBookingCode() string | Hiện thực IF-24 | - | IF-24.NewBookingCode | Instance | - |
| DC-RandomCodeGenerator | + | NewTicketCode() string | Hiện thực IF-24 | - | IF-24.NewTicketCode | Instance | - |

F2.PKG-13 SeatBooking

| DC | Visibility | Chữ ký | Mô tả | Tiền/hậu điều kiện | Nguồn (message P07 / UC bước) | Phạm vi | Ngoại lệ / lỗi |
|---|---|---|---|---|---|---|---|
| DC-BookTicketsService | + | HoldSeats(ctx Ctx, req HoldSeatsRequest) (HoldResult, error) | Thao tác không chia cắt EX-01: giữ cả nhóm ghế cho người giữ ghế hoặc không ghế nào; req.requestId trùng lần giữ ghế đã có thì trả lại lần đó (replayed) | Tiền: người giữ ghế đã đăng nhập (PKG-11). BR-04, BR-05, BR-07, BR-09, BR-10, BR-54, BR-65. Hậu: SeatHold ACTIVE, các ghế HELD, một dòng seat_event, không NOTIFY | P08 AC-C-BookTicketsController// requestSeatHold, startWaitingForHoldExpiry; UC-005 EX-01 | Instance | ShowtimeNotOpenError, ShowtimeChangedError, SeatSelectionError, HolderBusyError, SeatUnavailableError, HoldNotActiveError, ChannelMismatchError, LockOrderViolationError, SystemBusyError, NotFoundError |
| DC-BookTicketsService | + | GetHold(ctx Ctx, holdId SeatHoldId, by HolderRef) (HoldResult, error) | Đọc lần giữ ghế và các ghế đang giữ để khách mở lại "Tiếp tục thanh toán" | Tiền: by là người giữ ghế, khác thì NotFoundError (Q-147). Hậu: không đổi dữ liệu | P08 AC-E-SeatHold// provideHoldSummary; AC-E-SeatStatus// provideHeldSeatInfo | Instance | NotFoundError |
| DC-BookTicketsService | + | CancelHold(ctx Ctx, holdId SeatHoldId, by HolderRef) error | Một giao dịch gộp EX-04 và EX-05 (Q-134): kết thúc lần giữ ghế ở CANCELLED và trả các ghế về trống | BR-04, BR-85. Hậu: SeatHold CANCELLED, ghế AVAILABLE nếu còn thuộc lần giữ ghế này, cùng một commit | P08 AC-C-BookTicketsController// cancelSeatHold, stopWaitingForHoldExpiry | Instance | HoldNotActiveError, NotFoundError, SystemBusyError |
| DC-BookTicketsService | + | StartOnlinePayment(ctx Ctx, holdId SeatHoldId, by HolderRef, clientIp string) (PaymentStart, error) | Giao dịch ngắn dưới khoá lần giữ ghế: kiểm by là người giữ ghế (khác thì NotFoundError, Q-147), kiểm còn hiệu lực, thêm PaymentTransaction PENDING với số tiền chốt; sau commit nhờ IF-01 ký địa chỉ thanh toán | BR-90, P09 F7.6 bước 1, 2. Hậu: một PaymentTransaction PENDING mới mỗi lần gọi; lần giữ ghế giữ nguyên | P08 AC-C-BookTicketsController// startOnlinePayment | Instance | HoldNotActiveError, NotFoundError, GatewayConfigurationError |
| DC-BookTicketsService | + | ConfirmCashReceived(ctx Ctx, holdId SeatHoldId, clerk HolderRef) (BookingView, error) | EX-03: dưới khoá lần giữ ghế và ghế, kiểm clerk là người giữ ghế (khác thì NotFoundError, Q-147), so thời điểm CSDL với hạn, bán ghế bằng DC-HoldSettlement.Sell và FinishSale; quá hạn thì End ghi Hết hạn và trả ghế rồi từ chối | BR-44, BR-85. Hậu: COMPLETED, SOLD, Booking và Ticket; không gửi email (người giữ là nhân viên quầy) | P08 AC-C-BookTicketsController// confirmCashReceived; AC-E-SeatHold// completeSaleOnCashConfirmation | Instance | HoldNotActiveError, NotFoundError, SystemBusyError |
| DC-SeatMapService | + | GetSnapshot(ctx Ctx, showtimeId ShowtimeId) (SeatSnapshot, error) | Trạng thái từng ghế kèm event_seq và con trỏ, đọc bằng đúng một câu SQL | P09 F7.5 điểm 4. Hậu: không khoá | P08 AC-C-BookTicketsController// startBooking; AC-E-Showtime// provideSeatMap | Instance | NotFoundError |
| DC-SeatMapService | + | OpenStream(ctx Ctx, showtimeId ShowtimeId, afterEventId EventId) (SseStream, error) | Đăng ký IF-04.Subscribe rồi dịch SeatStreamItem thành khung SSE (id, event, data); afterEventId 0 nghĩa là chỉ từ lúc đăng ký | NFR-08, NFR-09. Hậu: đăng ký tồn tại tới khi close | P08 AC-B-BookTicketsForm// updateSeatMap (P10 F2 SS-03) | Instance | SeatHubUnavailableError |
| DC-HoldExpiryJob | + | RunDue(ctx Ctx, budget time.Duration) (JobRunResult, error) | Lặp lô EX-04 đến khi lô ít hơn batchSize hoặc hết budget, rồi xoá seat_event cũ hơn eventRetention bằng cleanupEvents trong ngữ cảnh riêng 2 giây | NFR-07. Hậu: mỗi lần giữ ghế ACTIVE đã quá hạn chuyển EXPIRED; chạy lặp an toàn | P11b IF-06.runDue; P08 AC-C-BookTicketsController// handleHoldExpired | Instance | lỗi CSDL |
| DC-HoldExpiryJob | - | expireBatch(ctx Ctx) (int, error) | Một giao dịch: IF-26.LockExpiredBatch, tx.Now, SeatHold.Expire từng dòng, IF-17.UpdateStatus, commit | Hạng 5 SKIP LOCKED | P10 F3a EX-04 | Instance | lỗi CSDL |
| DC-HoldExpiryJob | - | cleanupEvents(ctx Ctx) (int, error) | IF-22.DeleteOlderThan(eventRetention, batchSize) theo lô, chạy trong ngữ cảnh riêng có hạn 2 giây dù expireBatch đã hết ngân sách 8 giây của RunDue (Q-148) | - | P09 F7.5 điểm 6 | Instance | lỗi CSDL |
| DC-SeatReleaseJob | + | RunDue(ctx Ctx, budget time.Duration) (JobRunResult, error) | Lặp lô EX-05: khoá lô lần giữ ghế rồi lô ghế, trả ghế, ghi seat_event | REQ-76, NFR-07. Chạy lặp an toàn | P11b IF-06.runDue; P10 F3a EX-05 | Instance | lỗi CSDL |
| DC-SeatReleaseJob | - | releaseBatch(ctx Ctx) (int, error) | Một giao dịch cho một lô: IF-26.LockReleasableBatch, IF-26.LockByHolds, ReleaseHold, IF-18.SaveChanges | Hạng 5 rồi hạng 6, không xen kẽ | P09 F7.4 bước 2 | Instance | lỗi CSDL |

F2.PKG-14 PaymentRefund

| DC | Visibility | Chữ ký | Mô tả | Tiền/hậu điều kiện | Nguồn (message P07 / UC bước) | Phạm vi | Ngoại lệ / lỗi |
|---|---|---|---|---|---|---|---|
| DC-PaymentReportService | + | HandleIpn(ctx Ctx, params map[string]string) IpnAnswer | Kiểm chữ ký bằng IF-02, rồi EX-02 trong một giao dịch: khoá lần giữ ghế, ghế, giao dịch; quyết định bán ghế, thanh toán trễ, thất bại hoặc báo trùng; không trả error | BR-14, BR-15, BR-37, BR-39, BR-40, BR-85, BR-86, BR-91. Hậu: mọi báo cùng lần giữ ghế tuần tự hoá; tối đa một lần tạo vé | P08 AC-C-PaymentReportController// handlePaymentReport; UC-005 bước 11 đến 15; UC-006 bước 1 đến 3 | Instance | - |
| DC-PaymentReportService | + | ResolveReturnedPayment(params map[string]string) (string, bool) | Kiểm chữ ký các tham số của địa chỉ trả về bằng IF-02 và trả holdRef; false khi sai chữ ký hoặc thiếu tham số (PKG-12 không thấy kiểu lỗi của PKG-22); không đọc, không ghi CSDL | P09 F7.6; V-16. Hậu: không đổi dữ liệu | P11b Đề xuất sửa P10 (điểm vào địa chỉ trả về) | Instance | - |
| DC-PaymentReportService | + | QueryPaymentStatus(ctx Ctx, holdRef string) (PaymentStatusView, bool, error) | Đọc không khoá trạng thái lần giữ ghế, giao dịch mới nhất và mã đặt vé để trang kết quả hỏi lại; bool false khi không có lần giữ ghế mang holdRef | Q-126. Hậu: không đổi dữ liệu | P11b Đề xuất sửa P10; Q-126 | Instance | lỗi CSDL |
| DC-PaymentReportService | - | decide(r PaymentReport, hold *SeatHold, txn *PaymentTransaction, now time.Time) settlement | Hàm thuần theo bảng quyết định: SELL, LATE, FAILURE, DUPLICATE; không chạm CSDL để kiểm thử từng dòng | P09 F7.6 bảng quyết định | P08 AC-E-SeatHold// settlePaymentReport | Instance | - |
| DC-PaymentReportService | - | logUnrecognized(r PaymentReport) | Ghi log lỗi giao dịch không nhận ra, không tạo vé, không hoàn tiền | BR-38 | P08 AC-C-PaymentReportController// logUnrecognizedTransaction | Instance | - |
| DC-RefundService | + | CreateFullRefund(ctx Ctx, tx Tx, txn *PaymentTransaction) error | Chế độ (a) trong giao dịch EX-02: kiểm hạn mức, thêm RefundRequest FULL, cộng refundedTotal, xếp dòng hàng đợi hoàn tiền | BR-14, BR-15, BR-26, BR-40. Tiền: đã giữ khoá hạng 7. Không gửi email hoàn | P08 AC-E-PaymentTransaction// prepareRefundRequest; UC-006 bước 3 | Instance | RefundLimitError |
| DC-RefundService | + | RequestTicketRefund(ctx Ctx, tx Tx, txn *PaymentTransaction, ticket *Ticket, amount Money) error | Chế độ (b) trong giao dịch huỷ vé của bên gọi: kiểm hạn mức, thêm RefundRequest TICKET_GATEWAY, AddRefunded, xếp dòng hàng đợi; không commit riêng | BR-19, BR-26, BR-43. Tiền: đã giữ khoá hạng 7 (txn) và hạng 8 (vé). Hậu: không gọi cổng | P08 AC-C-CancelTicketController// requestCancellation (phần hoàn tiền); AC-E-PaymentTransaction// prepareRefundRequest | Instance | RefundLimitError |
| DC-RefundService | + | ProcessRefund(ctx Ctx, e OutboxEntry) error | EX-10 ba giao dịch ngắn: giao dịch 1 làm hàng rào (ExtendClaim có điều kiện claim_token, rồi BeginAttempt, commit), từ lần hai gọi IF-01.FindRefund rồi RequestRefund ngoài giao dịch (30 giây mỗi lời gọi, cắt theo claimed_until), ghi kết quả có điều kiện claim_token; hết lượt hoặc không tra cứu được thì MANUAL_REQUIRED; claim cũ hết hạn của yêu cầu đang IN_FLIGHT được nhận lại và tra cứu trước khi gửi lại | BR-41, BR-43, Q-118. Số lần thử quyết định hết lượt là attemptCount của RefundRequest; attempt_count của hàng đợi chỉ để theo dõi. Hậu: email hoàn tiền xếp hàng chỉ khi REFUNDED và requestType là FULL (UC-008 không gửi email, BR-41). Bỏ lượt vì phần claim còn lại quá ngắn thì trả nil và ghi log mức cảnh báo, không đổi dữ liệu (Q-150). Bất biến: chỉ bên giữ claim_token hợp lệ tại giao dịch 1 mới được gọi cổng | P08 AC-C-PaymentReportController// startWaitingForRefundResult, stopWaitingForRefundResult, handleRefundNoResponse, logRefundFailure | Instance | ClaimLostError, lỗi CSDL |
| DC-RefundService | - | toAttempt(o RefundOutcome) AttemptResult | Dịch kết quả cổng thành kiểu của Domain | - | P11b IF-01.requestRefund | Classifier | - |
| DC-RefundOutboxJob | + | RunDue(ctx Ctx, budget time.Duration) (JobRunResult, error) | workers luồng chạy song song, mỗi luồng rảnh Claim đúng một dòng REFUND_GATEWAY rồi xử lý hết dòng đó mới claim dòng kế, lặp đến hết việc đến hạn hoặc hết budget; dòng đã claim chạy xong dù quá budget | BR-41. Hậu: không dòng kẹt vĩnh viễn nhờ claimed_until | P11b IF-06.runDue | Instance | lỗi CSDL |

F2.PKG-15 TicketService

| DC | Visibility | Chữ ký | Mô tả | Tiền/hậu điều kiện | Nguồn (message P07 / UC bước) | Phạm vi | Ngoại lệ / lỗi |
|---|---|---|---|---|---|---|---|
| DC-CancelTicketService | + | FindBooking(ctx Ctx, bookingCode string, actor ActorContext) (BookingView, error) | Tìm lần đặt theo mã và dựng các vé kèm số tiền hoàn nếu huỷ; kiểm kênh và cụm rạp | BR-02, BR-17. Hậu: không đổi dữ liệu | P08 AC-C-CancelTicketController// findBookingTickets | Instance | NotFoundError, ChannelMismatchError |
| DC-CancelTicketService | + | CancelOnlineTicket(ctx Ctx, ticketId TicketId, customer ActorContext) (CancelResult, error) | Một giao dịch gộp EX-07 ghi nhận huỷ, EX-06 trả ghế, EX-09 tạo yêu cầu hoàn qua cổng (Q-133); gọi cổng hoàn tiền (EX-10) chạy sau commit qua hàng đợi | BR-17 đến BR-19, BR-21, BR-30, BR-42. Hậu: vé CANCELLED, ghế AVAILABLE nếu còn thuộc vé, RefundRequest NEW kèm dòng hàng đợi, cùng một commit. Vé đã huỷ thì TicketStateError (không có đường chạy tiếp) | P08 AC-C-CancelTicketController// requestCancellation | Instance | TicketStateError, ChannelMismatchError, CancelDeadlineError, RefundLimitError, SystemBusyError |
| DC-CancelTicketService | + | ConfirmCashRefund(ctx Ctx, ticketId TicketId, clerk ActorContext) (CancelResult, error) | Nhân viên quầy đã hoàn tiền mặt: huỷ vé, trả ghế và thêm RefundRequest TICKET_CASH đã REFUNDED trong một giao dịch (Q-125 của P04) | BR-17 đến BR-21, BR-30, BR-42. Hoàn tiền mặt không qua cổng, không email | P08 AC-C-CancelTicketController// confirmCashRefund; AC-E-Ticket// recordCashRefund | Instance | TicketStateError, ChannelMismatchError, CancelDeadlineError, SystemBusyError |
| DC-CancelTicketService | - | lockPaymentOfTicket(ctx Ctx, tx Tx, ticketId TicketId) (*PaymentTransaction, error) | Đọc không khoá lần đặt của vé (IF-20.FindByTicket) và giao dịch TICKETED của lần giữ ghế (IF-19.FindTicketedByHold), rồi IF-19.LockByID | Hạng 7. Tiền: đã giữ khoá hạng 6, chưa giữ hạng 8 | P10 F3a EX-09 | Instance | NotFoundError, SystemBusyError |
| DC-CancelTicketService | - | cancelOnlineInTx(ctx Ctx, tx Tx, ticketId TicketId, customer ActorContext) (CancelResult, error) | Thân giao dịch huỷ vé trực tuyến: đọc không khoá lần đặt và suất chiếu; khoá ghế (6), giao dịch thanh toán qua lockPaymentOfTicket (7), vé X qua IF-27 (8); CheckCancellationChannel; cancelAndReleaseSeat; RequestTicketRefund | Hạng 6, 7, 8, rồi chèn dòng hạng 9 mới | P10 F3a EX-06, EX-07, EX-09 | Instance | TicketStateError, ChannelMismatchError, CancelDeadlineError, RefundLimitError |
| DC-CancelTicketService | - | cancelCashInTx(ctx Ctx, tx Tx, ticketId TicketId, clerk ActorContext) (CancelResult, error) | Thân giao dịch huỷ vé tại quầy: đọc không khoá lần đặt và suất chiếu; khoá ghế (6), vé X (8), không có hạng 7; CheckCancellationChannel; Showtime.BelongsToCinema(clerk.cinemaId); cancelAndReleaseSeat; IF-21.Insert NewCashRefund | Hạng 6, 8, rồi chèn dòng hạng 9 mới | P10 F3a EX-06, EX-07 | Instance | TicketStateError, ChannelMismatchError, CancelDeadlineError |
| DC-CancelTicketService | - | cancelAndReleaseSeat(ctx Ctx, tx Tx, showtime *Showtime, ticket *Ticket, seat *SeatStatus, now time.Time) error | Phần chung của hai nhánh huỷ: Showtime.CheckCancellationDeadline(now); Ticket.Cancel; IF-27.UpdateTicketStatus; SeatStatus.ReleaseTicket; đổi được thì IF-18.SaveChanges | Đã giữ khoá hạng 6 và 8 | P10 F3a EX-06, EX-07 | Instance | TicketStateError, CancelDeadlineError |
| DC-CheckTicketService | + | StartChecking(ctx Ctx, showtimeId ShowtimeId, checker ActorContext) (ShowtimeInfo, error) | Kiểm suất chiếu thuộc cụm rạp của nhân viên rồi trả thông tin suất chiếu để hiển thị | BR-34. Hậu: không đổi dữ liệu | P08 AC-C-CheckTicketController// startChecking | Instance | NotFoundError, ChannelMismatchError |
| DC-CheckTicketService | + | CheckTicket(ctx Ctx, ticketCode string, showtimeId ShowtimeId, checker ActorContext) (AdmitResult, error) | EX-08: khoá vé X theo mã vé, đọc không khoá suất chiếu, Ticket.Admit; hai lần soát đồng thời một vé chỉ một lần ADMITTED | BR-22 đến BR-25, BR-30, BR-33. Hậu: USED chỉ khi ADMITTED | P08 AC-C-CheckTicketController// checkTicket | Instance | NotFoundError, SystemBusyError |

F2.PKG-12 PaymentCallbackApi

| DC | Visibility | Chữ ký | Mô tả | Tiền/hậu điều kiện | Nguồn (message P07 / UC bước) | Phạm vi | Ngoại lệ / lỗi |
|---|---|---|---|---|---|---|---|
| DC-PaymentCallbackController | + | HandleIpn(w http.ResponseWriter, r *http.Request) | Gom tham số truy vấn, gọi PaymentReportService.HandleIpn, dịch IpnAnswer sang JSON RspCode với HTTP 200 | P09 F7.6 | P08 AC-B-PaymentGateway// reportTransactionResult (P10 F2 IF-02) | Instance | - |
| DC-PaymentCallbackController | + | HandleReturn(w http.ResponseWriter, r *http.Request) | Điểm vào địa chỉ trả về: kiểm chữ ký rồi chuyển hướng khách tới trang kết quả của SPA kèm holdRef; không ghi gì | P09 F7.6: trang quay về chỉ đọc | P11b Đề xuất sửa P10 (điểm vào địa chỉ trả về) | Instance | - |
| DC-PaymentCallbackController | + | HandlePaymentStatus(w http.ResponseWriter, r *http.Request) | Trả JSON PaymentStatusView theo holdRef cho SPA hỏi lại mỗi 2 giây tối đa 60 giây | Q-126 | P11b Q-126 | Instance | - |
| DC-PaymentCallbackController | - | writeIpnAnswer(w http.ResponseWriter, a IpnAnswer) | Bảng dịch: PROCESSED 00, DUPLICATE 02, INVALID_SIGNATURE 97, AMOUNT_MISMATCH 04, UNKNOWN_TRANSACTION 01, TEMPORARY_FAILURE và MALFORMED 99 | P09 F7.6 bảng quyết định | P10 F3 DC-IpnAnswer | Instance | - |

F2.PKG-21 Persistence

| DC | Visibility | Chữ ký | Mô tả | Tiền/hậu điều kiện | Nguồn (message P07 / UC bước) | Phạm vi | Ngoại lệ / lỗi |
|---|---|---|---|---|---|---|---|
| DC-PgUnitOfWork | + | Do(ctx Ctx, opts TxOptions, fn func(tx Tx) error) error | Hiện thực IF-08: vòng thử lại quanh runOnce; vi phạm thứ tự khoá thì không thử lại | Xem IF-08.Do | IF-08.Do | Instance | SystemBusyError, LockOrderViolationError |
| DC-PgUnitOfWork | - | runOnce(ctx Ctx, opts TxOptions, fn func(tx Tx) error) error | BEGIN, SET LOCAL lock_timeout, tạo PgTx, gọi fn, COMMIT hoặc ROLLBACK; ngữ cảnh giới hạn opts.maxDuration | Thiết kế: lock_timeout 1 giây (cắt theo hạn tổng nếu có), giao dịch ghi ghế tối đa 4 giây | P09 F7.3 | Instance | lỗi CSDL |
| DC-PgUnitOfWork | - | isRetryable(err error) bool | Mã 40P01 hoặc 55P03 chưa bị store dịch thành lỗi nghiệp vụ | 55P03 của NOWAIT ở EX-01 không thử lại | P09 F7.3 | Classifier | - |
| DC-PgTx | + | Now(ctx Ctx) (time.Time, error) | Hiện thực IF-25: SELECT clock_timestamp() ở lần gọi đầu, các lần sau trả giá trị đã nhớ | Xem IF-25 | IF-25.Now | Instance | lỗi CSDL |
| DC-PgTx | ~ | guard() *LockOrderGuard | Bộ kiểm thứ tự khoá của giao dịch | - | Bổ sung: các store gọi trước mỗi câu khoá | Instance | - |
| DC-PgTx | ~ | conn() pgx.Tx | Giao dịch pgx để store chạy SQL | - | Bổ sung: các store dùng | Instance | - |
| DC-LockOrderGuard | + | Acquire(rank LockRank, key LockKey, exclusive bool) error | Ghi nhận khoá một dòng; hạng nhỏ hơn maxRank, hoặc cùng hạng mã nhỏ hơn maxKey thì vi phạm; cùng dòng khoá lại với chế độ bằng hoặc yếu hơn thì hợp lệ; nâng S lên X trên cùng dòng là vi phạm (P08 F4b quy tắc 3) | Chỉ tính khoá dòng (kể cả NOWAIT, SKIP LOCKED), không có khoá tư vấn | P10 F3a quy tắc áp dụng | Instance | LockOrderViolationError |
| DC-LockOrderGuard | + | AcquireAll(rank LockRank, keys []LockKey, exclusive bool) error | Ghi nhận một câu khoá nhiều dòng cùng hạng; keys phải tăng dần | Như Acquire | P10 F3a quy tắc áp dụng | Instance | LockOrderViolationError |
| DC-LockOrderGuard | + | Violated() bool | Đã vi phạm; PgUnitOfWork rollback và không thử lại | - | P10 F3a: đánh dấu giao dịch phải rollback | Instance | - |
| DC-ConnectionPools | + | NewConnectionPools(ctx Ctx, dsn string) (*ConnectionPools, error) | Mở hai pool từ chuỗi kết nối | - | Bổ sung: khởi tạo | Classifier | lỗi CSDL |
| DC-ConnectionPools | ~ | For(pool PoolKind) *pgxpool.Pool | Pool theo loại USER hoặc BACKGROUND | - | Bổ sung: PgUnitOfWork và các store dùng | Instance | - |
| DC-ConnectionPools | + | Close() | Đóng cả hai pool khi tắt chương trình | - | Bổ sung: kết thúc | Instance | - |
| DC-SeatEventWriter | ~ | Append(ctx Ctx, tx *PgTx, showtimeId ShowtimeId, items []SeatChangeItem) (EventId, error) | INSERT seat_event, mã sự kiện lấy từ sequence, created_at = clock_timestamp() lúc Append (không phải lúc BEGIN), trả mã để ghi vào event_seq của từng ghế | P09 F7.5 điểm 1. Tiền: ghế đã khoá. Hậu: dòng chỉ hiện khi commit | P09 F7.5 | Instance | lỗi CSDL |
| DC-PgTicketingStore | - | lockRows(ctx Ctx, tx Tx, rank LockRank, keys []LockKey, exclusive bool, sql string, args ...any) (pgx.Rows, error) | Gọi LockOrderGuard.AcquireAll trước, rồi chạy câu SQL khoá; dịch 55P03 của NOWAIT thành SeatUnavailableError(LOCKED_BY_OTHER) | Mỗi phương thức khoá khai báo đúng một hạng | P10 F3a quy tắc áp dụng | Instance | LockOrderViolationError, SeatUnavailableError |
| DC-PgTicketingStore | - | mapPgError(err error) error | Dịch lỗi pgx: 23505 thành lỗi unique, 55P03 và 40P01 giữ nguyên cho PgUnitOfWork thử lại | - | P09 F7.3 | Classifier | - |
| DC-PgCinemaOperationsStore | - | lockRow(ctx Ctx, tx Tx, rank LockRank, key LockKey, sql string, args ...any) (pgx.Row, error) | Gọi LockOrderGuard.Acquire rồi chạy SELECT FOR SHARE một dòng | Hạng 1, 2 hoặc 3 theo phương thức | P10 F3a EX-01 | Instance | LockOrderViolationError |
| DC-PgSeatEventStore | + | (toàn bộ operation của IF-22) | Hiện thực interface; SQL do lớp thực hiện, không thêm operation công khai |  | P10 cơ chế SSE | Instance |  |
| DC-PgOutboxStore | + | (toàn bộ operation của IF-23) | Hiện thực interface; SQL do lớp thực hiện, không thêm operation công khai |  | P10 cơ chế Persistence (hàng đợi gửi) | Instance |  |
| IF-22 | + | ReadEventsAfter(ctx Ctx, mark EventId, limit int) ([]SeatChangeEvent, error) | Các dòng có mã lớn hơn mark, sắp theo mã, tối đa limit | Chỉ quét khoảng 10 giây gần nhất qua chỉ mục khoá chính. Ràng buộc: cửa sổ chồng lớn hơn rõ rệt maxDuration (4 giây) cộng thời gian chờ lấy kết nối, và lớn hơn idle_in_transaction_session_timeout 5 giây (INSERT seat_event là câu cuối trước COMMIT), để giao dịch commit muộn vẫn được phát | P11b SS-03 S03W2 readEventsAfter; P09 F7.5 điểm 3 | Instance | lỗi CSDL |
| IF-22 | + | ReadShowtimeEvents(ctx Ctx, showtimeId ShowtimeId, cursor EventId, window time.Duration) ([]SeatChangeEvent, bool, error) | Các dòng của suất chiếu có mã lớn hơn cursor hoặc created_at không sớm hơn created_at của dòng cursor trừ window; bool false nghĩa là dòng cursor đã bị xoá | P09 F7.5 điểm 4. statement_timeout 3 giây | P11b SS-03 S03W1 readShowtimeEvents | Instance | lỗi CSDL |
| IF-22 | + | FindEvent(ctx Ctx, id EventId) (*SeatChangeEvent, error) | Một dòng theo mã | - | P11b SS-03 findEvent | Instance | NotFoundError |
| IF-22 | + | Snapshot(ctx Ctx, showtimeId ShowtimeId) (SeatSnapshot, error) | Trạng thái từng ghế kèm event_seq và con trỏ trong đúng một câu SQL | P09 F7.5 điểm 4 | P09 F7.5 điểm 4 | Instance | NotFoundError |
| IF-22 | + | DeleteOlderThan(ctx Ctx, age time.Duration, limit int) (int, error) | Xoá tối đa limit dòng cũ hơn age theo created_at; trả số dòng đã xoá | P09 F7.5 điểm 6 | P09 F7.5 điểm 6 | Instance | lỗi CSDL |
| IF-23 | + | Enqueue(ctx Ctx, tx Tx, e OutboxEntry) error | INSERT dòng PENDING cùng giao dịch của bên gọi; idempotencyKey unique | Hậu: dòng chỉ hiện khi commit | P09 F7.7 | Instance | lỗi unique |
| IF-23 | + | Claim(ctx Ctx, kind OutboxKind) (*OutboxEntry, error) | Một câu UPDATE ... LIMIT 1 ... SKIP LOCKED đặt claim_token, claimed_until = thời điểm CSDL + 120 giây, tăng attempt_count; commit ngay; không có dòng đến hạn thì trả rỗng | P09 F7.7 bước 1 | P09 F7.7 | Instance | lỗi CSDL |
| IF-23 | + | ExtendClaim(ctx Ctx, tx Tx, e OutboxEntry) (time.Time, error) | UPDATE outbox SET claimed_until = tx.Now + 120 giây WHERE id AND claim_token = e.claimToken; 0 dòng thì ClaimLostError; trả claimed_until mới; gọi trong giao dịch 1 của ProcessRefund, trước BeginAttempt, làm hàng rào chặn bên mất claim gọi cổng | P09 F7.7 bước 2 | P09 F7.7 | Instance | ClaimLostError |
| IF-23 | + | MarkSucceeded(ctx Ctx, tx Tx, e OutboxEntry) error | Đặt SUCCEEDED nếu claim_token còn là của e | P09 F7.7 bước 3 | P09 F7.7 | Instance | ClaimLostError |
| IF-23 | + | Reschedule(ctx Ctx, tx Tx, e OutboxEntry, delay time.Duration, lastError string) error | next_attempt_at = thời điểm CSDL + delay, xoá claim nếu token còn của e | P09 F7.7 bước 3 | P09 F7.7 | Instance | ClaimLostError |
| IF-23 | + | MarkExhausted(ctx Ctx, tx Tx, e OutboxEntry, lastError string) error | Đặt EXHAUSTED nếu token còn của e | P09 F7.7 | P09 F7.7 | Instance | ClaimLostError |

F2.PKG-22 PaymentGatewayClient (SS-01)

| DC | Visibility | Chữ ký | Mô tả | Tiền/hậu điều kiện | Nguồn (message P07 / UC bước) | Phạm vi | Ngoại lệ / lỗi |
|---|---|---|---|---|---|---|---|
| IF-01 | + | CreatePaymentTransaction(transactionId string, holdReference string, amount int64, expiresAt time.Time, customerAddress string) (string, error) | Ký địa chỉ thanh toán chứa mã giao dịch và mã tham chiếu lần giữ ghế; không gọi mạng; trả địa chỉ https | Tiền: PaymentTransaction PENDING đã commit, không có giao dịch CSDL đang mở, amount > 0, expiresAt sau hiện tại. Hậu: không đổi dữ liệu | P11b IF-01.createPaymentTransaction | Instance | GatewayConfigurationError, InvalidGatewayRequestError |
| IF-01 | + | RequestRefund(ctx Ctx, refundKey string, transactionId string, paidAt time.Time, originalAmount int64, refundAmount int64) (RefundOutcome, error) | Gửi hoàn tiền kèm khoá chống hoàn trùng, chờ tối đa 30 giây; Unknown là giá trị trả về, không phải lỗi | Tiền: không giữ khoá, không mở giao dịch; từ lần hai findRefund đã trả NOT_REFUNDED (Q-118). BR-43 | P11b IF-01.requestRefund | Instance | InvalidGatewayRequestError, GatewayConfigurationError |
| IF-01 | + | FindRefund(ctx Ctx, refundKey string, transactionId string, paidAt time.Time) (RefundLookup, error) | Tra cứu trạng thái hoàn theo khoá trước khi gửi lại, chờ tối đa 30 giây | Hậu: chỉ đọc. Q-118, Q-127 | P11b IF-01.findRefund | Instance | InvalidGatewayRequestError |
| IF-02 | + | ReportTransactionResult(parameters map[string]string) (PaymentReport, error) | Kiểm chữ ký rồi giải mã thông báo IPN hoặc địa chỉ trả về; số tiền chỉ được giải mã, việc so với bản ghi do DC-PaymentReportService làm | Tiền: parameters không rỗng. Hậu: thuần, không đổi dữ liệu | P11b IF-02.reportTransactionResult | Instance | InvalidSignatureError, MalformedReportError |
| DC-PaymentGatewayManager | + | CreatePaymentTransaction(transactionId string, holdReference string, amount int64, expiresAt time.Time, customerAddress string) (string, error) | Kiểm tiền điều kiện rồi gọi VnpayUrlBuilder | Xem IF-01 | IF-01.CreatePaymentTransaction | Instance | GatewayConfigurationError, InvalidGatewayRequestError |
| DC-PaymentGatewayManager | + | RequestRefund(ctx Ctx, refundKey string, transactionId string, paidAt time.Time, originalAmount int64, refundAmount int64) (RefundOutcome, error) | Kiểm refundAmount không vượt originalAmount rồi gọi VnpayRefundClient.Refund | Xem IF-01 | IF-01.RequestRefund | Instance | InvalidGatewayRequestError, GatewayConfigurationError |
| DC-PaymentGatewayManager | + | FindRefund(ctx Ctx, refundKey string, transactionId string, paidAt time.Time) (RefundLookup, error) | Gọi VnpayRefundClient.Query; cờ cấu hình không hỗ trợ tra cứu thì trả NOT_SUPPORTED | Xem IF-01 | IF-01.FindRefund | Instance | InvalidGatewayRequestError |
| DC-PaymentReportReceiver | + | ReportTransactionResult(parameters map[string]string) (PaymentReport, error) | VnpaySigner.Verify rồi VnpayReportDecoder.Decode | Xem IF-02 | IF-02.ReportTransactionResult | Instance | InvalidSignatureError, MalformedReportError |
| DC-VnpayUrlBuilder | ~ | BuildPaymentURL(transactionId string, holdReference string, amount int64, expiresAt time.Time, customerAddress string) (string, error) | Sắp xếp tham số, ký HMAC-SHA512 bằng VnpaySigner, ghép địa chỉ | V-01 đến V-03 chưa kiểm tài liệu (P11b) | P11b SS-01 F5 | Instance | GatewayConfigurationError |
| DC-VnpayRefundClient | ~ | Refund(ctx Ctx, refundKey string, transactionId string, paidAt time.Time, originalAmount int64, refundAmount int64) (RefundOutcome, error) | POST yêu cầu hoàn đã ký; hết 30 giây, mất kết nối hoặc sai chữ ký thì status UNKNOWN | BR-43 | P11b SS-01 F5 | Instance | GatewayConfigurationError |
| DC-VnpayRefundClient | ~ | Query(ctx Ctx, refundKey string, transactionId string, paidAt time.Time) (RefundLookup, error) | POST truy vấn hoàn đã ký | Q-118 | P11b SS-01 F5 | Instance | GatewayConfigurationError |
| DC-VnpaySigner | ~ | Sign(params map[string]string) string | Sắp tham số theo tên, nối chuỗi truy vấn, HMAC-SHA512 bằng khoá cấu hình | Thuần | P11b SS-01 F5 | Instance | - |
| DC-VnpaySigner | ~ | Verify(params map[string]string, signature string) bool | So chữ ký bằng so sánh thời gian hằng | NFR-16 | P11b SS-01 F5 | Instance | - |
| DC-VnpayReportDecoder | ~ | Decode(params map[string]string) (PaymentReport, error) | Đọc mã giao dịch, mã tham chiếu lần giữ ghế, số tiền (chia 100 nếu cổng nhân 100), kết quả | V-04, V-05 | P11b SS-01 F5 | Instance | MalformedReportError |
| DC-GatewayConfig | + | LoadGatewayConfig() (*GatewayConfig, error) | Đọc biến môi trường, thiếu giá trị bắt buộc thì lỗi | - | P11b SS-01 F5 | Classifier | GatewayConfigurationError |

F2.PKG-24 SeatEventHub (SS-03)

| DC | Visibility | Chữ ký | Mô tả | Tiền/hậu điều kiện | Nguồn (message P07 / UC bước) | Phạm vi | Ngoại lệ / lỗi |
|---|---|---|---|---|---|---|---|
| IF-04 | + | Subscribe(ctx Ctx, showtimeId ShowtimeId, afterEventId EventId) (SeatEventSubscription, error) | Đăng ký trước, phát lại từ con trỏ, rồi chuyển sang trực tiếp; trả handle ngay, luồng items đọc bất đồng bộ | Tiền: bộ phát đã khởi động. NFR-08, NFR-09. Bên gọi chịu được sự kiện lặp và lệch thứ tự giữa các ghế | P11b IF-04.subscribe | Instance | SeatHubUnavailableError |
| IF-04 | + | Unsubscribe(subscriptionId string) | Gỡ đăng ký, đóng hàng đợi với lý do UNSUBSCRIBED; gọi hai lần vô hại | - | P11b IF-04.unsubscribe | Instance | - |
| DC-SeatEventHubManager | + | Subscribe(ctx Ctx, showtimeId ShowtimeId, afterEventId EventId) (SeatEventSubscription, error) | Thêm hàng đợi vào SubscriberRegistry trước, rồi SeatReplayReader phát lại từ afterEventId | Xem IF-04 | IF-04.Subscribe | Instance | SeatHubUnavailableError |
| DC-SeatEventHubManager | + | Unsubscribe(subscriptionId string) | SubscriberRegistry.Remove | Xem IF-04 | IF-04.Unsubscribe | Instance | - |
| DC-SeatEventHubManager | + | Start(ctx Ctx) error | Chạy SeatEventPoller trong goroutine; gọi ở hàm khởi động chương trình | Gọi một lần | Bổ sung: IF-04 yêu cầu bộ phát đã khởi động | Instance | - |
| DC-SeatEventHubManager | + | Stop() | Dừng vòng đọc, đóng mọi hàng đợi với lý do SHUTDOWN | - | Bổ sung: tắt chương trình | Instance | - |
| DC-SeatEventPoller | ~ | Run(ctx Ctx) | Vòng pollOnce mỗi period tới khi ctx kết thúc | - | P11b SS-03 S03W2 | Instance | - |
| DC-SeatEventPoller | - | pollOnce(ctx Ctx) error | ReadEventsAfter(mốc W), bỏ mã đã phát, Offer vào hàng đợi, tiến mốc W, dọn tập mã đã phát | P09 F7.5 điểm 3 | P11b SS-03 S03W2 | Instance | lỗi CSDL |
| DC-SeatReplayReader | ~ | Replay(ctx Ctx, q *SubscriberQueue, showtimeId ShowtimeId, cursor EventId) error | ReadShowtimeEvents rồi Offer tuần tự; dòng cursor không còn thì Offer RELOAD_REQUIRED | P09 F7.5 điểm 4, 6 | P11b SS-03 S03W1 | Instance | SeatHubUnavailableError |
| DC-SubscriberRegistry | ~ | Add(showtimeId ShowtimeId) (string, *SubscriberQueue) | Tạo hàng đợi 256 phần tử, trả mã đăng ký | - | P11b SS-03 F5 | Instance | - |
| DC-SubscriberRegistry | ~ | Remove(subscriptionId string) | Gỡ và đóng hàng đợi UNSUBSCRIBED | - | P11b SS-03 F5 | Instance | - |
| DC-SubscriberRegistry | ~ | QueuesOf(showtimeId ShowtimeId) []*SubscriberQueue | Bản sao danh sách hàng đợi của suất chiếu | - | P11b SS-03 F5 | Instance | - |
| DC-SubscriberRegistry | ~ | CloseAll(reason CloseReason) | Đóng mọi hàng đợi khi dừng | - | P11b SS-03 F5 | Instance | - |
| DC-SubscriberQueue | ~ | Offer(item SeatStreamItem) bool | Đẩy không chặn; đầy thì Close(SLOW_CONSUMER) và trả false | NFR-08 | P11b SS-03 F5 | Instance | - |
| DC-SubscriberQueue | ~ | Items() <-chan SeatStreamItem | Luồng chỉ đọc cho bên gọi | - | P11b SS-03 F5 | Instance | - |
| DC-SubscriberQueue | ~ | Close(reason CloseReason) | Gửi CLOSED kèm lý do rồi đóng; gọi hai lần vô hại | - | P11b SS-03 F5 | Instance | - |
| DC-EmittedEventTracker | ~ | WasEmitted(id EventId) bool | Mã đã phát chưa | - | P11b SS-03 F5 | Instance | - |
| DC-EmittedEventTracker | ~ | Record(e SeatChangeEvent, now time.Time) | Ghi mã đã phát | - | P11b SS-03 F5 | Instance | - |
| DC-EmittedEventTracker | ~ | AdvanceMark(now time.Time) | Tiến mốc W theo các dòng đã phát cũ hơn 10 giây và xoá mã cũ hơn 20 giây | - | P11b SS-03 F5 | Instance | - |
| DC-EmittedEventTracker | ~ | Mark() EventId | Mốc W hiện tại | - | P11b SS-03 F5 | Instance | - |

F2.PKG-25 Scheduler (SS-04)

| DC | Visibility | Chữ ký | Mô tả | Tiền/hậu điều kiện | Nguồn (message P07 / UC bước) | Phạm vi | Ngoại lệ / lỗi |
|---|---|---|---|---|---|---|---|
| IF-05 | + | RegisterJob(name string, job IScheduledJob, interval time.Duration) error | Đăng ký công việc và chu kỳ (10 giây cho cả bốn công việc) | Tiền: chưa Start, tên duy nhất, interval > 0 | P11b IF-05.registerJob | Instance | SchedulerStateError |
| IF-05 | + | Start(ctx Ctx) error | Bắt đầu chạy định kỳ trên bản backend này; trả ngay | Tiền: gọi một lần | P11b IF-05.start | Instance | SchedulerStateError |
| IF-05 | + | Stop(grace time.Duration) | Không mở lượt mới; chờ lượt đang chạy tối đa grace (10 giây) | Chạy lượt dở an toàn vì chạy lặp được | P11b IF-05.stop | Instance | - |
| IF-06 | + | RunDue(ctx Ctx, budget time.Duration) (JobRunResult, error) | Chạy các mục đến hạn theo lô tới khi hết việc hoặc hết budget (8 giây); mục đã nhận chạy xong | Nhiều bản backend gọi song song được; chạy lặp an toàn | P11b IF-06.runDue | Instance | lỗi của công việc (SS-04 bắt và ghi log) |
| DC-JobSchedulerManager | + | RegisterJob(name string, job IScheduledJob, interval time.Duration) error | Kiểm trạng thái rồi JobRegistry.Add | Xem IF-05 | IF-05.RegisterJob | Instance | SchedulerStateError |
| DC-JobSchedulerManager | + | Start(ctx Ctx) error | Mở một JobLoop cho mỗi công việc | Xem IF-05 | IF-05.Start | Instance | SchedulerStateError |
| DC-JobSchedulerManager | + | Stop(grace time.Duration) | Dừng các vòng và chờ tối đa grace | Xem IF-05 | IF-05.Stop | Instance | - |
| DC-JobRegistry | ~ | Add(name string, job IScheduledJob, interval time.Duration) error | Thêm công việc, tên trùng thì lỗi | - | P11b SS-04 F5 | Instance | SchedulerStateError |
| DC-JobRegistry | ~ | All() []ScheduledJob | Danh sách đã đăng ký | - | P11b SS-04 F5 | Instance | - |
| DC-JobLoop | ~ | Run(ctx Ctx) | Mỗi interval gọi runOnce trong goroutine, bỏ qua nếu running | - | P11b SS-04 S04W1 | Instance | - |
| DC-JobLoop | - | runOnce(ctx Ctx) | Gọi IScheduledJob.RunDue(budget), bắt panic và lỗi rồi ghi log, không để lỗi lọt ra ngoài | - | P11b SS-04 S04W1 | Instance | - |

F2.PKG-26 Security (SS-05)

| DC | Visibility | Chữ ký | Mô tả | Tiền/hậu điều kiện | Nguồn (message P07 / UC bước) | Phạm vi | Ngoại lệ / lỗi |
|---|---|---|---|---|---|---|---|
| IF-07 | + | VerifyPassword(plainPassword string, storedHash string) (bool, error) | So mật khẩu với mã băm một chiều, so sánh thời gian hằng | NFR-01 đến NFR-03. Hậu: không đổi dữ liệu | P11b IF-07.verifyPassword | Instance | MalformedHashError |
| IF-07 | + | IssueSession(subjectId string, role Role, cinemaId string) (IssuedSession, error) | Cấp mã phiên tự kiểm chứng được (khách 24 giờ, nhân viên và quản trị viên 8 giờ, Q-129, Q-153) | Tiền: VerifyPassword đã trả true | P11b IF-07.issueSession | Instance | InvalidAuthRequestError |
| IF-07 | + | VerifySession(token string) (SessionClaims, error) | Kiểm chữ ký và hạn của mã phiên, trả claims để tầng gọi dựng ActorContext; phiên hết hạn khi now >= expiresAt, now lấy từ đồng hồ hệ thống tiêm vào bộ xác thực qua constructor (Q-154) | Hậu: không đọc CSDL | P11b IF-07.verifySession | Instance | SessionInvalidError, SessionExpiredError |

## F3. Bảng thiết kế method

| DC.operation | Thuật toán / các bước chính | Đối tượng và operation khác được dùng | Cách dùng thuộc tính, tham số, quan hệ | Hành vi theo trạng thái (nếu có ST) |
|---|---|---|---|---|
| DC-BookTicketsService.HoldSeats | 1. Kiểm nhanh không chạm CSDL: tính selectionFlaw = EMPTY khi seatIds rỗng, TOO_MANY khi quá DC-Showtime.MaxSeatsPerHold (BR-05), chỉ ghi nhớ, chưa ném lỗi (Q-145: lỗi này báo sau BR-04).<br>2. FindRouting(showtimeId) không khoá để biết mã phòng chiếu và cụm rạp (cần biết hạng 1 và 2 trước khi khoá hạng 3).<br>3. IF-08.Do(UserTx("HoldSeats")), trong fn: (a) khoá tăng dần: LockSharedByCinema (hạng 1), LockAuditoriumShared (2), LockShared suất chiếu (3), LockHolder (4), LockUnfinishedOrByRequest (5); (b) now = tx.Now một lần; (c) so phòng chiếu của suất chiếu đã khoá với bước 2, khác thì ShowtimeChangedError; (d) có lần giữ ghế cùng requestId của chính người giữ ghế: còn ACTIVE chưa quá hạn thì trả lại nó (replayed) và kết thúc, ngược lại HoldNotActiveError mang status; (e) người giữ là nhân viên quầy thì Showtime.BelongsToCinema(req.holderCinemaId), sai thì ChannelMismatchError (UC-005 2b, BR-02; HoldSeats là điểm ghi duy nhất nên kiểm tại đây, không chỉ ở bước hiển thị sơ đồ ghế); rồi CheckSaleOpen (2a, 2c); (f) lần giữ ghế ACTIVE cũ đã quá hạn thì HoldSettlement.End(now, cũ, EXPIRY, nil) (chuyển Hết hạn, chưa khoá ghế nào nên chưa trả ghế), UpdateStatus và nhớ mã của nó, còn lại gọi CheckNoActiveSeatHold(now) (HolderBusyError, BR-04); rồi ném selectionFlaw nếu có (SeatSelectionError EMPTY hoặc TOO_MANY, 6a); CheckUnchangedSince(displayedAt) (7d), FindSeats rồi CheckSeatSelection (thứ tự lý do EMPTY, TOO_MANY, DUPLICATE, NOT_IN_AUDITORIUM, Q-152); thứ tự báo lỗi cả hàm: 2b, 2a và 2c, 7c, 6a, 7d, 7a, 7e (Q-145); (g) LockForHold (hạng 6, NOWAIT): 55P03 thì SeatUnavailableError(LOCKED_BY_OTHER), không thử lại; sau khi giao dịch đã rollback, bên gọi gọi IF-18.FindBeingReleased và nếu true thì đổi reason thành BEING_RELEASED (thông điệp MSG-82 "ghế đang được trả, thử lại sau vài giây" thay cho MSG-11); số dòng khoá được khác số ghế yêu cầu thì SeatUnavailableError; ghế vừa khoá có currentHold bằng mã lần giữ ghế cũ vừa hết hạn thì HoldSettlement.End(now, cũ, EXPIRY, các ghế vừa khoá) trả Trống các ghế đó (lần gọi thứ hai cho lần giữ ghế đã Hết hạn nên chỉ trả ghế), rồi SaveChanges ngay cho các ghế End trả về (Q-134; ghi Trống trước khi gán lần giữ ghế mới vì trg_seat_status_link của P13 không cho một UPDATE đổi liên kết từ lần giữ ghế này sang lần giữ ghế khác; ghế khác của lần giữ ghế cũ không khoá thêm, job quét trả); sau đó có ghế không IsAvailable thì SeatUnavailableError; (h) QuoteSeatPrices, NewSeatHold(now), Insert, HoldFor từng ghế, SaveChanges (ghi seat_event cùng giao dịch, không NOTIFY; nếu (g) đã gọi SaveChanges thì đây là lần gọi thứ hai, dùng lại mã sự kiện, vẫn một dòng seat_event mỗi suất chiếu).<br>4. Commit rồi dựng HoldResult; tổng = hold.CalculateTotal(seats). Hạn tổng 1,8 giây tính từ lúc nhận yêu cầu (đặt ở UserTx("HoldSeats").WithDeadline), bao cả chờ pool và mọi lần thử; mỗi lần thử bị huỷ khi hết hạn nhỏ hơn trong 4 giây và phần hạn còn lại; thử lại với 40P01 chỉ khi còn ít nhất 1 giây; hết hạn thì SystemBusyError (P09 F7.3). | IF-08, IF-11, IF-12, IF-13, IF-16, IF-17, IF-18, IF-24; DC-Showtime, DC-Customer hoặc DC-BoxOfficeClerk, DC-SeatHold, DC-SeatStatus, DC-HoldSettlement | req.requestId làm khoá xác nhận lặp (cột unique của SeatHold); R-46, R-48, R-49, R-63, R-187; các IF tiêm qua constructor | ST-01: tạo ở Đang giữ. ST-02: Trống sang Đang được giữ cho cả nhóm hoặc không ghế nào; ghế đang được giữ hoặc đã bán bị từ chối. Lần giữ ghế cũ của người giữ đã quá hạn được ghi Hết hạn trong giao dịch; ghế của nó trùng với ghế vừa chọn đi Đang được giữ sang Trống rồi sang Đang được giữ ngay trong giao dịch (hai lần SaveChanges, mỗi lần một UPDATE), ghế khác của nó do job quét trả (Q-134) |
| DC-BookTicketsService.CancelHold | 1. Do(UserTx("CancelHold")), một giao dịch gộp EX-04 và EX-05 (Q-134): LockByID (hạng 5); now = tx.Now; lần giữ ghế không thuộc by thì NotFoundError (không lộ sự tồn tại); LockByHold (hạng 6).<br>2. HoldSettlement.End(now, hold, CANCEL, các ghế đã khoá hạng 6): quá hạn thì chuyển Hết hạn, chưa quá hạn thì Cancel(now); các ghế còn trỏ tới lần giữ ghế được trả Trống trong cùng lời gọi. Lần giữ ghế đã ở trạng thái cuối khác thì End trả HoldNotActiveError mang status, không ghi gì.<br>3. UpdateStatus rồi SaveChanges các ghế End trả về, cùng giao dịch; nếu outcome.expired thì đặt kết quả HoldNotActiveError(EXPIRED) và fn trả nil để commit. SeatReleaseJob chỉ là lưới an toàn (NFR-07). | IF-08, IF-17, IF-18; DC-HoldSettlement, DC-SeatHold, DC-SeatStatus | Khoá hạng 5 rồi hạng 6 trong một giao dịch (P10 F3a EX-04 gộp EX-05); R-187 | ST-01: Đang giữ sang Đã huỷ khi chưa quá hạn; đã ở trạng thái cuối thì HoldNotActiveError mang status. ST-02: Đang được giữ sang Trống |
| DC-BookTicketsService.StartOnlinePayment | 1. Giao dịch ngắn: LockByID (hạng 5), now = tx.Now, kiểm by là người giữ ghế (khác thì NotFoundError, không đổi dữ liệu, Q-147), HoldSettlement.End(now, hold, EXPIRY, nil) rồi UpdateStatus nếu quá hạn (commit rồi trả HoldNotActiveError), IsActiveAt(now).<br>2. FindByHold lấy các ghế, total = CalculateTotal; NewPending(hold, NewTransactionCode(), total); IF-19.Insert (dòng mới, hạng 7); commit.<br>Nếu dừng tại đây (đã commit, chưa ký địa chỉ): lần giữ ghế vẫn Đang giữ kèm một PaymentTransaction PENDING chưa dùng; khách bấm thanh toán lại tạo bản ghi PENDING mới (BR-90), hết hạn thì HoldExpiryJob và SeatReleaseJob giải phóng ghế, IPN đến muộn của bản ghi cũ xử lý như thanh toán trễ.<br>3. Ngoài giao dịch: IF-01.CreatePaymentTransaction(code, holdRef, int64(total), expiryTime, clientIp) trả địa chỉ đã ký, không gọi mạng. Lỗi ở bước 3 giữ nguyên lần giữ ghế (BR-90).<br>Mỗi lần gọi (kể cả thanh toán lại) tạo một PaymentTransaction PENDING mới, bản ghi chờ không bao giờ bị xoá (P09 F7.6). | IF-08, IF-17, IF-18, IF-19, IF-24, IF-01; DC-HoldSettlement, DC-PaymentTransaction | R-50, R-187 | ST-01: chỉ thực hiện khi Đang giữ và chưa quá hạn. ST-05: tạo Chưa xử lý |
| DC-BookTicketsService.ConfirmCashReceived | 1. Do(UserTx("ConfirmCash")): LockByID (5), LockByHold (6), now = tx.Now; kiểm clerk là người giữ ghế (khác thì NotFoundError, Q-147).<br>2. HoldSettlement.End(now, hold, EXPIRY, các ghế đã khoá hạng 6): outcome.expired thì UpdateStatus (nếu holdChanged), SaveChanges các ghế trả về cùng giao dịch (Q-134), đặt kết quả HoldNotActiveError(EXPIRED), fn trả nil để commit; nhân viên được báo trả lại tiền mặt (BR-44).<br>3. Ngược lại: HoldSettlement.Sell(now, hold, ghế đã khoá, NewBookingCode(), NewTicketCode() cho từng ghế) (Complete, tạo lần đặt cùng vé); InsertWithTickets; HoldSettlement.FinishSale (MarkSold từng ghế); SaveChanges; UpdateStatus hold.<br>4. Không xếp email: người giữ là nhân viên quầy, P04 UC-005 luồng 9a không gửi email (Đề xuất sửa P10 F3a EX-03). | IF-08, IF-17, IF-18, IF-20, IF-24; DC-HoldSettlement, DC-SeatHold, DC-SeatStatus | R-51, R-52, R-63, R-64, R-187 | ST-01: Đang giữ sang Đã hoàn tất hoặc Hết hạn; ST-02: Đang được giữ sang Đã bán, hoặc sang Trống khi lần giữ ghế hết hạn; ST-03: tạo vé Chưa sử dụng |
| DC-PaymentReportService.HandleIpn | 1. IF-02.ReportTransactionResult(params): sai chữ ký thì IpnAnswer(INVALID_SIGNATURE), thiếu tham số thì MALFORMED; không ghi gì.<br>2. Tra không khoá mã lần giữ ghế từ mã tham chiếu (FindIDByRef) hoặc mã giao dịch (FindByCode); không có cả hai thì logUnrecognized và UNKNOWN_TRANSACTION (BR-38).<br>3. Do(UserTx("SettleReport")), fn: LockByID lần giữ ghế (5), LockByHold ghế (6), LockByCode giao dịch (7; chưa có thì Insert từ dữ liệu báo dưới khoá hạng 5, và khi báo thành công mà lần giữ ghế còn Đang giữ thì r.amount phải bằng tổng giá các ghế đang trỏ tới nó (CalculateTotal), khác thì AMOUNT_MISMATCH, ghi log, không ghi gì); now = tx.Now một lần.<br>4. Chỉ với báo thành công mà giao dịch chưa xử lý (txn.IsProcessed sai): giao dịch đã có mà r.amount khác txn.Amount thì AMOUNT_MISMATCH, ghi log, không ghi gì (BR-91); báo thất bại (BR-39) và báo trùng (BR-37) không kiểm số tiền (Q-146). Rồi HoldSettlement.End(now, hold, EXPIRY, ghế đã khoá hạng 6): quá hạn thì lần giữ ghế sang Hết hạn và ghế còn trỏ tới nó được trả; holdChanged thì UpdateStatus, có ghế trả về thì SaveChanges (Q-134).<br>5. decide(r, hold, txn, now): báo thành công và txn.IsProcessed thì DUPLICATE; báo thành công, txn PENDING, hold IsActiveAt(now) thì SELL; báo thành công còn lại thì LATE; báo thất bại thì FAILURE.<br>6. SELL: HoldSettlement.Sell(now, hold, ghế đã khoá, NewBookingCode(), NewTicketCode() cho từng ghế) (Complete, tạo lần đặt cùng vé); Sell kiểm trước khi đổi gì rằng có ít nhất một ghế đã khoá và mọi ghế IsHeldBy(hold), LinkMismatchError thì chuyển sang nhánh LATE với lý do HOLD_LINK_BROKEN, ghi log lỗi nghiêm trọng, không rollback (P08 F4b EX-02: thao tác không hoàn tất xử lý như thanh toán trễ, Q-84); đúng thì InsertWithTickets, HoldSettlement.FinishSale (MarkSold từng ghế), SaveChanges, txn.MarkTicketed, UpdateStatus cả hai, Enqueue(EMAIL_TICKET). LATE: txn.MarkLatePayment, RefundService.CreateFullRefund(tx, txn). FAILURE: txn.RecordFailure; chỉ khi txn là giao dịch tạo sau cùng của lần giữ ghế (IF-19.FindLatestByHold, đọc không khoá dưới khoá hạng 5) và hold IsActiveAt thì HoldSettlement.End(now, hold, PAYMENT_FAILURE, ghế đã khoá hạng 6) (FailPayment và trả ghế) rồi UpdateStatus, SaveChanges cùng giao dịch (Q-134); giao dịch cũ báo thất bại khi đã có giao dịch mới hơn thì chỉ RecordFailure, lần giữ ghế giữ nguyên; rồi UpdateStatus. DUPLICATE: txn.RecordDuplicate, UpdateStatus.<br>7. Commit; lỗi tạm thời (40P01, 55P03 sau thử lại) thì rollback trọn và TEMPORARY_FAILURE để cổng gửi lại. | IF-02, IF-08, IF-17, IF-18, IF-19, IF-20, IF-23; DC-HoldSettlement, DC-SeatHold, DC-SeatStatus, DC-PaymentTransaction, DC-RefundService | R-12, R-13, R-14, R-15, R-50, R-51, R-63, R-188 | ST-01 (Đang giữ sang Đã hoàn tất, Thanh toán thất bại, Hết hạn), ST-05 (bảng chuyển trạng thái), ST-02 (Đang được giữ sang Đã bán, hoặc sang Trống khi lần giữ ghế kết thúc không bán). Hai báo đến đồng thời tuần tự hoá ở khoá hạng 5; báo sau thấy trạng thái cuối do báo trước để lại (BR-85, BR-86) |
| DC-PaymentReportService.decide | Hàm thuần theo bảng quyết định P09 F7.6, không chạm CSDL: (1) r thành công, txn.IsProcessed: DUPLICATE; (2) r thành công, txn.Status là PENDING, hold.IsActiveAt(now): SELL; (3) r thành công, còn lại (lần giữ ghế Hết hạn, Đã huỷ, Thanh toán thất bại, đã Đã hoàn tất bởi giao dịch khác, hoặc txn đã FAILED): LATE; (4) r thất bại: FAILURE. Bốn nhánh loại trừ nhau theo thứ tự trên. | DC-PaymentTransaction.IsProcessed, DC-SeatHold.IsActiveAt | Tham số r, hold, txn, now; kết quả là kiểu nội bộ settlement | Dùng trạng thái của ST-01 và ST-05 |
| DC-PaymentReportService.ResolveReturnedPayment và QueryPaymentStatus | Địa chỉ trả về chỉ hiện, không ghi (P09 F7.6). ResolveReturnedPayment: IF-02.ReportTransactionResult(params), thành công thì trả holdRef và true, ngược lại false. QueryPaymentStatus: FindIDByRef, đọc không khoá lần giữ ghế, giao dịch mới nhất của lần giữ ghế và mã đặt vé; dựng PaymentStatusView. Trang của SPA hỏi lại mỗi 2 giây tối đa 60 giây (Q-126). | IF-02, IF-17, IF-19, IF-20 | Không giữ khoá, không giao dịch ghi; ngoài ranh giới giao dịch của IF-08 | Chỉ đọc trạng thái ST-01 và ST-05 |
| DC-HoldExpiryJob.RunDue | 1. Lặp expireBatch tới khi lô trả ít hơn batchSize (200) hoặc hết budget (8 giây, đo bằng ngữ cảnh có deadline).<br>2. expireBatch: Do(BackgroundTx("ExpireBatch")): IF-26.LockExpiredBatch (hạng 5, chọn mã ứng viên expiry_time đã qua không khoá rồi khoá X SKIP LOCKED theo mã tăng dần); now = tx.Now; Expire(now) từng dòng; UpdateStatus chỉ khi còn Đang giữ; commit.<br>3. Cuối lượt, kể cả khi expireBatch đã dùng hết ngân sách 8 giây: cleanupEvents chạy trong ngữ cảnh riêng có hạn 2 giây (Q-148) và gọi IF-22.DeleteOlderThan(10 phút, 200) theo lô.<br>Hai bản backend chạy chồng hoặc khởi động lại giữa chừng: SKIP LOCKED chia lô, lần sau thấy trạng thái cuối nên không đổi. | IF-08, IF-17, IF-22, IF-26; DC-SeatHold | batchSize, eventRetention; pool nền 5 kết nối | ST-01: Đang giữ sang Hết hạn khi now không trước expiryTime; trạng thái cuối bỏ qua |
| DC-SeatReleaseJob.releaseBatch | releaseBatch: Do(BackgroundTx("ReleaseBatch")): IF-26.LockReleasableBatch (5, SKIP LOCKED, mã tăng dần) khoá cả lô lần giữ ghế trước; rồi IF-26.LockByHolds (6, ORDER BY suất chiếu, ghế) khoá cả lô ghế; với mỗi ghế gọi ReleaseHold(holdId của lần giữ ghế nào còn trỏ tới nó) và gom ghế đã đổi; SaveChanges (UPDATE theo khoá chính, một dòng seat_event mỗi suất chiếu); commit. Không xử lý từng lần giữ ghế xen kẽ hạng 5 và hạng 6. RunDue lặp releaseBatch như HoldExpiryJob. Job là lưới an toàn: các giao dịch kết thúc lần giữ ghế đã trả ghế của chúng ngay (Q-134), job chỉ gom ghế sót (hết hạn do HoldExpiryJob, tiến trình chết giữa chừng). Bất biến: LockByHolds chỉ trả ghế thuộc lô nên ReleaseHold luôn đổi được, không có nhánh trả false. | IF-08, IF-18, IF-26; DC-SeatHold, DC-SeatStatus | R-63: ghế còn thuộc lần giữ ghế khác thì ReleaseHold trả false | ST-02: Đang được giữ sang Trống chỉ khi currentHold = holdId; ghế đã Trống hoặc Đã bán bỏ qua |
| DC-CancelTicketService.CancelOnlineTicket | Một giao dịch duy nhất gộp EX-07, EX-06, EX-09 (Q-133), thân là cancelOnlineInTx (dùng chung cancelAndReleaseSeat với cancelCashInTx):<br>1. Do(UserTx("CancelTicket")), trong fn đọc không khoá trước: IF-20.FindByTicket (lần đặt, vé, Key() của ghế), IF-11.FindByID suất chiếu.<br>2. Khoá tăng dần: IF-18.LockByKey ghế (hạng 6); lockPaymentOfTicket (hạng 7: IF-20.FindByTicket, IF-19.FindTicketedByHold, IF-19.LockByID); IF-27.LockTicketByID (hạng 8).<br>3. now = tx.Now; Booking.CheckCancellationChannel(customer); rồi cancelAndReleaseSeat: Showtime.CheckCancellationDeadline(now); Ticket.Cancel (vé đã huỷ hoặc đã sử dụng thì TicketStateError, BR-21); IF-27.UpdateTicketStatus.<br>4. SeatStatus.ReleaseTicket(ticketId) (chỉ đổi khi currentTicket khớp vé); đổi được thì SaveChanges.<br>5. amount = Ticket.RefundAmount (70%, làm tròn xuống đồng); RefundService.RequestTicketRefund(ctx, tx, txn, ticket, amount): CheckRefundWithin, NewTicketRefund, IF-21.Insert (hạng 9, dòng mới), IF-19.AddRefunded, IF-23.Enqueue(REFUND_GATEWAY).<br>6. Commit. Gọi cổng hoàn tiền (EX-10) chạy sau commit qua hàng đợi, ngoài giao dịch. Lỗi ở bước nào thì rollback trọn: không có vé đã huỷ mà ghế kẹt Đã bán hoặc khách mất tiền không dấu vết. 40P01 thì thử lại cả giao dịch tối đa 2 lần. | IF-08, IF-11, IF-18, IF-19, IF-20, IF-27; DC-Ticket, DC-Booking, DC-Showtime, DC-SeatStatus, DC-PaymentTransaction, DC-RefundService (IF-21, IF-23 và IF-19.AddRefunded qua DC-RefundService) | R-52, R-53, R-54, R-64, R-193, R-195, R-196. Đọc không khoá trước khi khoá (P08 F4b quy tắc 7) | ST-03: Chưa sử dụng sang Đã huỷ; vé đã sử dụng hoặc đã huỷ thì TicketStateError. ST-02: Đã bán sang Trống chỉ khi currentTicket = ticketId. ST-04: tạo ở Mới |
| DC-CancelTicketService.ConfirmCashRefund | Một giao dịch duy nhất (Q-125 của P04, Q-133), thân là cancelCashInTx (dùng chung cancelAndReleaseSeat với cancelOnlineInTx):<br>1. Do(UserTx("CancelTicketCash")), đọc không khoá IF-20.FindByTicket và IF-11.FindByID suất chiếu.<br>2. Khoá tăng dần: IF-18.LockByKey ghế (hạng 6); IF-27.LockTicketByID (hạng 8). Không có khoá hạng 7 vì vé mua tại quầy không có giao dịch thanh toán.<br>3. now = tx.Now; CheckCancellationChannel(clerk); Showtime.BelongsToCinema(clerk.cinemaId) sai thì ChannelMismatchError (UC-008 2c); cancelAndReleaseSeat (CheckCancellationDeadline(now); Ticket.Cancel; IF-27.UpdateTicketStatus).<br>4. ReleaseTicket; đổi được thì SaveChanges.<br>5. IF-21.Insert yêu cầu hoàn TICKET_CASH đã REFUNDED (NewCashRefund, dòng hạng 9 mới đứng sau hạng 8 nên đúng thứ tự).<br>6. Commit. Ghi huỷ, trả ghế và ghi khoản hoàn tiền mặt cùng một commit. Hoàn tiền mặt không gọi cổng, không xếp hàng đợi, không email (BR-20). | IF-08, IF-11, IF-18, IF-20, IF-21, IF-27; DC-Ticket, DC-Booking, DC-Showtime, DC-SeatStatus, DC-RefundRequest | R-56, R-193 | ST-03, ST-04 (tạo ở Đã hoàn), ST-02 |
| DC-CheckTicketService.CheckTicket | 1. Do(UserTx("CheckTicket")): IF-27.LockTicketByCode (8, X). Hai nhân viên quét cùng vé: người sau chờ khoá tối đa lock_timeout 1 giây, đọc lại thấy USED.<br>2. FindByID suất chiếu không khoá (luôn có vì khoá ngoại ON DELETE RESTRICT từ vé tới seat_status và từ seat_status tới suất chiếu, nên không có nhánh NotFoundError); Ticket.Admit(showtime, showtimeId đã chọn, checker.cinemaId); ADMITTED thì IF-27.UpdateTicketStatus(USED).<br>3. Commit; dựng AdmitResult (kèm mã đặt vé, vị trí ghế khi ADMITTED). | IF-08, IF-11, IF-27; DC-Ticket, DC-Showtime | R-53, R-194 | ST-03: Chưa sử dụng sang Đã sử dụng khi hợp lệ; thứ tự lý do theo BR-33 |
| DC-RefundService.CreateFullRefund và RequestTicketRefund | CreateFullRefund (chế độ a, trong giao dịch EX-02 của bên gọi, đã giữ khoá hạng 7): txn.CheckRefundWithin(amount của giao dịch); NewFullRefund; IF-21.Insert; IF-19.AddRefunded; IF-23.Enqueue(REFUND_GATEWAY, idempotencyKey = khoá của yêu cầu hoàn); không xếp email.<br>RequestTicketRefund (chế độ b, cũng trong giao dịch huỷ vé của bên gọi, đã giữ khoá hạng 7 và 8): CheckRefundWithin, NewTicketRefund, Insert (hạng 9), AddRefunded, Enqueue; không commit riêng.<br>Phép cộng refunded_total nằm trong chính câu UPDATE, kèm điều kiện tổng không vượt đã thanh toán (X-16). | IF-08, IF-19, IF-21, IF-23; DC-PaymentTransaction, DC-RefundRequest | R-55, R-56, R-18 | ST-04: tạo ở Mới; ST-05 giữ nguyên (refundedTotal không đổi status) |
| DC-RefundService.ProcessRefund | 1. Giao dịch 1: LockByID RefundRequest (9); IF-23.ExtendClaim(tx, e) (cùng giao dịch với BeginAttempt): 0 dòng thì ClaimLostError, rollback, không gọi cổng; ghi lại claimedUntil trả về và mốc đơn điệu cục bộ lúc commit; đã REFUNDED hoặc MANUAL_REQUIRED thì MarkSucceeded dòng hàng đợi và thôi; đang IN_FLIGHT (claim cũ hết hạn sau khi tiến trình chết) mà hết lượt thì MarkManualRequired, ghi log, MarkSucceeded dòng hàng đợi và thôi; ngược lại BeginAttempt (từ NEW, WAITING_RETRY, hoặc IN_FLIGHT khi nhận lại claim); Update; commit (đếm lần gửi trước khi gọi cổng để tiến trình chết giữa chừng vẫn tính).<br>Nếu dừng tại đây (đã commit giao dịch 1, chưa gọi cổng): RefundRequest ở IN_FLIGHT với attemptCount đã tăng, dòng hàng đợi giữ claim tới claimed_until; khi claim hết hạn, RefundOutboxJob của một bản backend nhận lại, FindRefund trước khi gửi lại (Q-118), hết lượt thì MANUAL_REQUIRED.<br>2. Ngoài giao dịch: từ lần thứ hai (AttemptCount lớn hơn 1, kể cả lần nhận lại sau khi tiến trình chết) gọi IF-01.FindRefund: REFUNDED thì coi như SUCCEEDED không gửi lại; NOT_REFUNDED thì tiếp tục; NOT_SUPPORTED hoặc UNREACHABLE thì MarkManualRequired trong một giao dịch riêng rồi MarkSucceeded dòng hàng đợi (Q-118, không gửi lại tự động). Rồi IF-01.RequestRefund, cùng idempotencyKey ở mọi lần thử. Hạn mỗi lời gọi cổng là nhỏ hơn trong 30 giây và (claimedUntil trừ thời điểm hiện tại trừ 10 giây biên); trước mỗi lời gọi kiểm mốc đơn điệu cục bộ, còn dưới 15 giây (hạn tính ra dưới 5 giây, không đủ cho một lời gọi hữu ích) thì thôi, trả nil và ghi log mức cảnh báo (Q-150), không gọi cổng và không ghi gì (dòng được nhận lại sau claimed_until, bản nhận lại bắt buộc FindRefund trước).<br>Nếu dừng tại đây (cổng có thể đã nhận lệnh hoàn, chưa ghi kết quả): RefundRequest vẫn IN_FLIGHT; claim hết hạn thì dòng được nhận lại, FindRefund thấy REFUNDED thì coi như thành công, cùng idempotencyKey ở mọi lần thử nên cổng không hoàn hai lần.<br>3. Giao dịch 3: LockByID (9); RecordResult(toAttempt(outcome)); Update; SUCCEEDED thì Enqueue(EMAIL_REFUND) chỉ khi requestType là FULL (UC-008 không gửi email), rồi MarkSucceeded; còn lượt thì Reschedule(1, 5, 15 phút); hết lượt thì MarkExhausted. Mọi ghi vào hàng đợi có điều kiện claim_token, ClaimLostError thì rollback. Hết lượt chỉ tính theo attemptCount của RefundRequest (MaxAttempts = 4); attempt_count của hàng đợi chỉ để theo dõi. | IF-08, IF-01, IF-19, IF-21, IF-23; DC-RefundRequest | retryDelays; MaxAttempts = 4 | ST-04 (bảng chuyển trạng thái) |
| DC-PgUnitOfWork.Do | 1. Với mỗi lần thử (tối đa 1 cộng maxRetries): lấy kết nối từ ConnectionPools theo opts.pool; BEGIN READ COMMITTED; SET LOCAL lock_timeout = opts.lockTimeout; tạo PgTx với LockOrderGuard mới; gọi fn trong ngữ cảnh có deadline opts.maxDuration (và opts.deadline nếu có: hạn mỗi lần thử là nhỏ hơn của hai hạn tính ở thời điểm đó, lock_timeout cắt theo phần hạn còn lại, chờ kết nối không vượt phần hạn còn lại).<br>2. fn trả nil và guard chưa Violated thì INSERT các dòng seat_event đã gom (câu cuối cùng của giao dịch, P09 F7.5 điểm 1) rồi COMMIT, ngược lại ROLLBACK.<br>3. Guard Violated thì trả LockOrderViolationError, không thử lại. Lỗi 40P01 hoặc 55P03 chưa được store dịch thì chờ retryBackoff nhân số lần thử rồi lặp, chỉ khi opts.deadline rỗng hoặc còn ít nhất 1 giây; hết lần thử hoặc hết hạn thì SystemBusyError. 55P03 do NOWAIT đã thành SeatUnavailableError nên không thử lại.<br>4. Lỗi COMMIT không có SQLSTATE (mất kết nối) không thử lại, trả lỗi: giao dịch có thể đã commit, các thao tác đều idempotent theo trạng thái. Mỗi lần thử gọi lại fn từ đầu nên bên gọi đặt lại biến kết quả ở đầu fn. Panic trong fn được recover, rollback và trả lỗi. Hạn maxDuration đặt ngay trước khi lấy kết nối. | DC-ConnectionPools, DC-PgTx, DC-LockOrderGuard | opts: lockTimeout 1 giây, maxDuration 4 giây (Thiết kế: P09 F7.3) | Không liên quan trạng thái ST |
| DC-LockOrderGuard.Acquire | 1. So (rank, key) với (maxRank, maxKey): rank nhỏ hơn maxRank, hoặc cùng rank mà key nhỏ hơn maxKey, thì violated = true và trả LockOrderViolationError.<br>2. Ngược lại cập nhật (maxRank, maxKey). Guard nhớ chế độ đã giữ theo từng khoá: lấy lại cùng dòng với chế độ bằng hoặc yếu hơn không tính là đi lùi; nâng từ S lên X trên cùng dòng là vi phạm, vì hai giao dịch cùng giữ S rồi cùng đòi X sẽ deadlock (P08 F4b quy tắc 3).<br>3. AcquireAll lần lượt gọi Acquire cho keys đã tăng dần; keys không tăng dần là vi phạm.<br>Chỉ tính khoá dòng (kể cả NOWAIT, SKIP LOCKED); thiết kế không dùng khoá tư vấn. | DC-LockRank, DC-LockKey | maxRank, maxKey, violated của một giao dịch (không an toàn đa luồng, một giao dịch một goroutine) | Không liên quan trạng thái ST |
| DC-PgTicketingStore.SaveChanges (IF-18) | 1. Nhóm các SeatStatus đã đổi theo suất chiếu.<br>2. Với mỗi suất chiếu: SeatEventWriter.Append(showtimeId, items) lấy mã sự kiện từ sequence (không chờ commit, không NOTIFY).<br>3. UPDATE seat_status SET state, current_hold_id, current_ticket_id, held_price, event_seq WHERE khoá chính, cho các ghế đã khoá X; số dòng ảnh hưởng phải bằng số ghế đổi, khác thì lỗi và rollback.<br>Sự kiện chỉ hiện khi commit và biến mất nếu rollback nên không bao giờ đẩy trạng thái chưa commit. | DC-SeatEventWriter, DC-PgTx | R-44, R-63, R-64 | ST-02 |
| DC-HoldSettlement.End, Sell và FinishSale | End(now, hold, reason, seats): (1) changedByExpiry = hold.Expire(now). (2) reason EXPIRY: không làm gì thêm; nếu lần giữ ghế đang EXPIRED (vừa đổi hoặc đã EXPIRED từ trước) thì outcome.expired = true. (3) reason CANCEL hoặc PAYMENT_FAILURE: nếu changedByExpiry thì outcome.expired = true, không gọi Cancel hay FailPayment; ngược lại gọi hold.Cancel(now) hoặc hold.FailPayment(now), lỗi HoldNotActiveError thì trả lỗi, chưa đổi ghế nào. (4) Khi lần giữ ghế đang EXPIRED, CANCELLED hoặc PAYMENT_FAILED do lời gọi này, hoặc đang EXPIRED với reason EXPIRY: với từng ghế trong seats gọi ReleaseHold(hold.ID) và gom ghế trả về true vào outcome.released. (5) outcome.holdChanged = lần giữ ghế vừa đổi trạng thái ở lời gọi này.<br>Sell(now, hold, seats, bookingCode, ticketCodes): (1) seats rỗng, len(ticketCodes) khác len(seats), hoặc có ghế không IsHeldBy(hold.ID) thì LinkMismatchError, chưa đổi gì. (2) hold.Complete(now) (đã gọi Expire trước; HoldNotActiveError nếu không còn Đang giữ). (3) NewBooking(hold, bookingCode, seats, ticketCodes) tạo lần đặt cùng vé.<br>FinishSale(hold, booking, seats): với từng ghế, tìm vé có Key() bằng khoá ghế rồi seat.MarkSold(hold.ID, ticket.ID()); LinkMismatchError nếu không khớp (lỗi lập trình dưới khoá hạng 6).<br>Không I/O, không khoá, không gọi kho: bên gọi khoá hạng 5 và 6 trước, lưu bằng IF-17, IF-18, IF-20 sau (UpdateStatus, SaveChanges, InsertWithTickets). | DC-SeatHold, DC-SeatStatus, DC-Booking | R-184, R-185, R-186; không có thuộc tính (không trạng thái) | ST-01 (Đang giữ sang Đã hoàn tất, Đã huỷ, Thanh toán thất bại, Hết hạn), ST-02 (Đang được giữ sang Trống hoặc Đã bán), ST-03 (tạo vé Chưa sử dụng) |
| DC-SeatHold.Expire, Complete, Cancel, FailPayment | Expire(now): nếu status ACTIVE và now không trước expiryTime thì status = EXPIRED, trả true; ngược lại không đổi, trả false.<br>Complete, Cancel, FailPayment (now): nếu status ACTIVE và now trước expiryTime thì đặt COMPLETED, CANCELLED hoặc PAYMENT_FAILED; ngược lại trả HoldNotActiveError mang status hiện tại, không đổi. Chỉ DC-HoldSettlement gọi Complete, Cancel, FailPayment và luôn gọi Expire(now) trước (End, Sell), nên thao tác đến sau hạn thấy trạng thái Hết hạn; entity không đổi trạng thái khi bị gọi sai thứ tự (Q-142). | (không) | status, expiryTime; now là tham số (Bước 2.6) | ST-01; trạng thái cuối không đổi (Q-79, BR-86) |
| DC-SeatStatus.HoldFor, MarkSold, ReleaseHold, ReleaseTicket | HoldFor(holdId, price): state AVAILABLE thì state = HELD, currentHold = holdId, heldPrice = price; ngược lại SeatUnavailableError(NOT_AVAILABLE).<br>MarkSold(holdId, ticketId): state HELD và currentHold = holdId thì state = SOLD, xoá currentHold, đặt currentTicket; ngược lại LinkMismatchError.<br>ReleaseHold(holdId): state HELD và currentHold = holdId thì state = AVAILABLE, xoá currentHold và heldPrice, trả true; ngược lại trả false, không đổi.<br>ReleaseTicket(ticketId): state SOLD và currentTicket = ticketId thì state = AVAILABLE, xoá currentTicket và heldPrice, trả true; ngược lại false. | (không) | state, currentHold, currentTicket (R-63, R-64), heldPrice | ST-02; bất biến: state HELD khi và chỉ khi có currentHold, SOLD khi và chỉ khi có currentTicket |
| DC-Ticket.Admit | Kiểm theo thứ tự BR-33 và dừng ở lý do đầu tiên: showtime.BelongsToCinema(cinemaId) sai thì WRONG_CINEMA; showtime.ID khác selected thì WRONG_SHOWTIME; status USED thì ALREADY_USED; status CANCELLED thì CANCELLED; còn lại status = USED và trả ADMITTED. | DC-Showtime.BelongsToCinema, DC-Showtime.ID | status; showtime qua tham số | ST-03 |
| DC-RefundRequest.RecordResult | Yêu cầu status IN_FLIGHT, ngược lại RefundStateError. SUCCEEDED thì REFUNDED. REJECTED hoặc UNKNOWN: HasAttemptsRemaining (attemptCount nhỏ hơn MaxAttempts) thì WAITING_RETRY, ngược lại MANUAL_REQUIRED; ghi detail vào refundResult. | (không) | attemptCount, MaxAttempts = 4 (một lần đầu, ba lần thử lại, P09 F7.7) | ST-04 |
| DC-PaymentTransaction.MarkTicketed, MarkLatePayment, RecordFailure, RecordDuplicate | MarkTicketed: chỉ từ PENDING, đặt TICKETED, lưu gatewayTransactionNo và paidAt. MarkLatePayment: từ PENDING hoặc FAILED, đặt LATE_PAYMENT, lưu lateReason cùng gatewayTransactionNo và paidAt của báo thành công. RecordFailure: PENDING sang FAILED; FAILED, TICKETED, LATE_PAYMENT không đổi và trả false (BR-39); không lưu gatewayTransactionNo (báo thất bại của VNPay có thể mang mã 0 hoặc trùng, và chỉ mục unique từng phần của gateway_transaction_no sẽ làm báo thất bại thứ hai bị 23505 rồi cổng gửi lại mãi); RecordDuplicate cũng không lưu. Mã cổng chỉ được ghi khi báo thành công. RecordDuplicate: chỉ khi TICKETED hoặc LATE_PAYMENT, duplicateReportCount tăng 1. Chuyển sai trạng thái trả PaymentStateError (lỗi lập trình vì đã giữ khoá hạng 7). | (không) | status, duplicateReportCount | ST-05 |
| DC-SeatEventHubManager.Subscribe | 1. Bộ phát chưa Start hoặc đang tắt thì SeatHubUnavailableError.<br>2. SubscriberRegistry.Add(showtimeId): hàng đợi tồn tại trước khi đọc phát lại (để sự kiện xảy ra giữa hai bước không mất).<br>3. SeatReplayReader.Replay(queue, showtimeId, afterEventId): ReadShowtimeEvents rồi Offer tuần tự; không còn dòng con trỏ thì Offer RELOAD_REQUIRED.<br>4. Trả SeatEventSubscription ngay; sau đó SeatEventPoller đẩy sự kiện trực tiếp vào hàng đợi. Đầy 256 thì Close(SLOW_CONSUMER). | DC-SubscriberRegistry, DC-SeatReplayReader (đọc IF-22 bên trong Replay) | overlap 10 giây, hàng đợi 256 | Không liên quan trạng thái ST (ghế giữ thực hiện ở SeatStatus) |
| DC-SeatEventPoller.pollOnce | 1. ReadEventsAfter(mark W, limit).<br>2. Với mỗi sự kiện theo mã tăng dần chưa WasEmitted: Record(now), Offer vào hàng đợi của suất chiếu (QueuesOf).<br>3. AdvanceMark(now): W = mã lớn nhất trong các dòng đã phát có created_at cũ hơn 10 giây (lớn hơn rõ rệt maxDuration 4 giây của giao dịch ghi); xoá mã đã phát cũ hơn 20 giây. Bên nhận chỉ áp sự kiện khi mã lớn hơn event_seq của ghế nên phát lặp và lệch thứ tự giữa các ghế vô hại. | IF-22, DC-SubscriberRegistry, DC-EmittedEventTracker | period 500 ms; now qua constructor | Không liên quan trạng thái ST |
| DC-JobLoop.Run và runOnce | Run: mỗi interval chờ bằng after (đồng hồ đơn điệu); nếu running thì bỏ chu kỳ, ngược lại chạy runOnce trong goroutine. runOnce: đặt running, gọi RunDue(ctx có deadline budget), bắt panic và lỗi rồi ghi log, xoá running; lượt quá budget cộng 2 giây chỉ ghi log và không mở lượt mới của công việc đó tới khi lượt cũ kết thúc. | IF-06 | running, budget 8 giây | Không liên quan trạng thái ST |
| DC-VnpayRefundClient.Refund và Query | Dựng tham số theo mã giao dịch, khoá hoàn, số tiền; ký bằng VnpaySigner; POST HTTPS với thời gian chờ 30 giây. Trả lời hợp lệ đã kiểm chữ ký: mã thành công thì SUCCEEDED, mã từ chối rõ thì REJECTED; hết giờ, mất kết nối, sai chữ ký hoặc mã lạ thì UNKNOWN (Refund) hoặc UNREACHABLE (Query). Chi tiết giao thức phụ thuộc V-02, V-04, V-09, V-11 chưa kiểm (P11b). | DC-VnpaySigner, DC-GatewayConfig | httpClient.Timeout = 30 giây | Không liên quan trạng thái ST |

Operation còn lại là getter, predicate một dòng hoặc hiện thực nguyên một operation interface đã mô tả ở F2 nên không cần thiết kế method riêng.

### F3b. Sequence diagram thiết kế

Năm sơ đồ cho thao tác không chia cắt then chốt, thể hiện ranh giới giao dịch (khung tx nét đứt) và thứ tự khoá theo hạng (mỗi lời gọi khoá ghi [hạng n X hoặc S], LockOrderGuard.Acquire ở SQ-01 minh hoạ kiểm thứ tự cho mọi sơ đồ còn lại). Sơ đồ tuần tự do bộ sinh đặt toạ độ, không chạy diakempt. Mỗi sơ đồ một trang.

SQ-01. Giữ ghế EX-01 (UC-005). File diagrams/P12-sequence-hold-seats.drawio. EX-01 giữ ghế: chuỗi khoá 1 đến 6, SeatStatus khoá NOWAIT theo (suất chiếu, ghế) tăng dần, một thời điểm CSDL, seat_event cùng giao dịch, không NOTIFY.

| ID | Loại | Nhãn | Ghi chú |
|---|---|---|---|
| SQ-01-L8 | Lifeline | PostgreSQL | - |
| SQ-01-L7 | Lifeline | :SeatEventWriter | - |
| SQ-01-L6 | Lifeline | :LockOrderGuard | - |
| SQ-01-L5 | Lifeline | :PgTicketingStore (IF-16, IF-17, IF-18) | - |
| SQ-01-L4 | Lifeline | :PgCinemaOperationsStore (IF-11, IF-12, IF-13) | - |
| SQ-01-L3 | Lifeline | :PgUnitOfWork (IF-08) | - |
| SQ-01-L2 | Lifeline | :BookTicketsService | - |
| SQ-01-L1 | Lifeline | :BookingController (PKG-11, tham chiếu) | - |
| SQ-01-N1 | Note | BelongsToCinema (nhân viên quầy, BR-02); CheckSaleOpen; HoldSettlement.End(EXPIRY) lần giữ ghế cũ đã quá hạn, hoặc CheckNoActiveSeatHold (BR-04); số ghế; CheckUnchangedSince, CheckSeatSelection | Tự gọi của lifeline L2 |
| SQ-01-N2 | Note | QuoteSeatPrices; NewSeatHold(now); HoldSettlement.End(EXPIRY, các ghế vừa khoá) rồi SaveChanges để ghi Trống cho ghế trùng lần giữ ghế cũ vừa hết hạn; HoldFor(holdId, price) từng ghế | Tự gọi của lifeline L2 |
| SQ-01-N3 | Note | Lỗi không ghi gì: ShowtimeChangedError, HolderBusyError, SeatSelectionError, ShowtimeNotOpenError, HoldNotActiveError(requestId đã kết thúc): ROLLBACK. 40P01: rollback rồi chạy lại fn, tối đa 2 lần, hết lần thì SystemBusyError | Tự gọi của lifeline L2 |
| SQ-01-F3 | Fragment alt | alt ghế đang bị khoá hoặc không Trống | - |
| SQ-01-F3-G0 | Guard | [55P03 hoặc có ghế không Trống] | Nhánh đầu của SQ-01-F3 |
| SQ-01-F3-D1 | Separator | [mọi ghế Trống] | Nhánh tiếp theo của SQ-01-F3 |
| SQ-01-F2 | Fragment alt | alt requestId trùng lần giữ ghế đã có | - |
| SQ-01-F2-G0 | Guard | [đã có lần giữ ghế cùng requestId] | Nhánh đầu của SQ-01-F2 |
| SQ-01-F2-D1 | Separator | [else] | Nhánh tiếp theo của SQ-01-F2 |
| SQ-01-F1 | Fragment tx | tx: READ COMMITTED, lock_timeout 1 s, tối đa 4 s, thử lại 2 lần với 40P01 | - |

| ID | Nguồn | Đích | Loại | Nhãn (thứ tự STT trong nhãn) | Ghi chú |
|---|---|---|---|---|---|
| SQ-01-M1 | SQ-01-L1 | SQ-01-L2 | Message đồng bộ | HoldSeats(ctx, req) | - |
| SQ-01-M2 | SQ-01-L2 | SQ-01-L4 | Message đồng bộ | FindRouting(showtimeId) [đọc không khoá: mã phòng, cụm rạp] | - |
| SQ-01-M3 | SQ-01-L2 | SQ-01-L3 | Message đồng bộ | Do(UserTx("HoldSeats"), fn) | - |
| SQ-01-M4 | SQ-01-L3 | SQ-01-L8 | Message đồng bộ | BEGIN; SET LOCAL lock_timeout | - |
| SQ-01-M5 | SQ-01-L2 | SQ-01-L4 | Message đồng bộ | LockSharedByCinema [hạng 1 S] | - |
| SQ-01-M6 | SQ-01-L4 | SQ-01-L6 | Message đồng bộ | Acquire(1, cinemaId, S) | - |
| SQ-01-M7 | SQ-01-L4 | SQ-01-L8 | Message đồng bộ | SELECT price_list FOR SHARE | - |
| SQ-01-M8 | SQ-01-L2 | SQ-01-L4 | Message đồng bộ | LockAuditoriumShared [hạng 2 S] | - |
| SQ-01-M9 | SQ-01-L4 | SQ-01-L6 | Message đồng bộ | Acquire(2, auditoriumId, S) | - |
| SQ-01-M10 | SQ-01-L4 | SQ-01-L8 | Message đồng bộ | SELECT auditorium FOR SHARE | - |
| SQ-01-M11 | SQ-01-L2 | SQ-01-L4 | Message đồng bộ | LockShared [hạng 3 S] (suất chiếu) | - |
| SQ-01-M12 | SQ-01-L4 | SQ-01-L6 | Message đồng bộ | Acquire(3, showtimeId, S) | - |
| SQ-01-M13 | SQ-01-L4 | SQ-01-L8 | Message đồng bộ | SELECT showtime FOR SHARE | - |
| SQ-01-M14 | SQ-01-L2 | SQ-01-L5 | Message đồng bộ | LockHolder [hạng 4 X] | - |
| SQ-01-M15 | SQ-01-L5 | SQ-01-L6 | Message đồng bộ | Acquire(4, holderId, X) | - |
| SQ-01-M16 | SQ-01-L5 | SQ-01-L8 | Message đồng bộ | SELECT customer FOR NO KEY UPDATE | - |
| SQ-01-M17 | SQ-01-L2 | SQ-01-L5 | Message đồng bộ | LockUnfinishedOrByRequest [hạng 5 X, mã tăng dần] | - |
| SQ-01-M18 | SQ-01-L5 | SQ-01-L6 | Message đồng bộ | Acquire(5, holdId, X) | - |
| SQ-01-M19 | SQ-01-L5 | SQ-01-L8 | Message đồng bộ | SELECT seat_hold FOR NO KEY UPDATE | - |
| SQ-01-M20 | SQ-01-L2 | SQ-01-L3 | Message đồng bộ | tx.Now() [một lần, sau khi có khoá] | - |
| SQ-01-M21 | SQ-01-L3 | SQ-01-L8 | Message đồng bộ | SELECT clock_timestamp() | - |
| SQ-01-M22 | SQ-01-L2 | SQ-01-L1 | Message trả về | HoldResult(replayed = true), COMMIT | - |
| SQ-01-M23 | SQ-01-L2 | SQ-01-L5 | Message đồng bộ | LockForHold [hạng 6 X NOWAIT, ORDER BY suất chiếu, ghế] | - |
| SQ-01-M24 | SQ-01-L5 | SQ-01-L6 | Message đồng bộ | Acquire(6, key, X) cho từng ghế, tăng dần | - |
| SQ-01-M25 | SQ-01-L5 | SQ-01-L8 | Message đồng bộ | SELECT seat_status ... FOR NO KEY UPDATE NOWAIT | - |
| SQ-01-M26 | SQ-01-L2 | SQ-01-L1 | Message trả về | SeatUnavailableError, ROLLBACK, không thử lại | - |
| SQ-01-M27 | SQ-01-L2 | SQ-01-L5 | Message đồng bộ | Insert(hold) | - |
| SQ-01-M28 | SQ-01-L5 | SQ-01-L8 | Message đồng bộ | INSERT seat_hold (unique requestId) | - |
| SQ-01-M29 | SQ-01-L2 | SQ-01-L5 | Message đồng bộ | SaveChanges(ghế đã đổi) | - |
| SQ-01-M30 | SQ-01-L5 | SQ-01-L7 | Message đồng bộ | Append(showtimeId, items) | - |
| SQ-01-M31 | SQ-01-L7 | SQ-01-L8 | Message đồng bộ | INSERT seat_event RETURNING id [không NOTIFY] | - |
| SQ-01-M32 | SQ-01-L5 | SQ-01-L8 | Message đồng bộ | UPDATE seat_status SET state, current_hold_id, event_seq | - |
| SQ-01-M33 | SQ-01-L3 | SQ-01-L8 | Message đồng bộ | COMMIT (hoặc ROLLBACK khi fn trả lỗi) | - |
| SQ-01-M34 | SQ-01-L2 | SQ-01-L1 | Message trả về | HoldResult(holdId, expiryTime, seats, total) | - |

SQ-02. Xử lý IPN EX-02 (UC-005, UC-006). File diagrams/P12-sequence-handle-ipn.drawio. EX-02 xử lý IPN: kiểm chữ ký ngoài giao dịch, khoá 5, 6, 7, bốn nhánh quyết định, hàng đợi gửi cùng giao dịch, trả lời cổng sau commit.

| ID | Loại | Nhãn | Ghi chú |
|---|---|---|---|
| SQ-02-L8 | Lifeline | PostgreSQL | - |
| SQ-02-L7 | Lifeline | :RefundService + :PgOutboxStore (IF-23) | - |
| SQ-02-L6 | Lifeline | :PgTicketingStore (IF-17, IF-18, IF-19, IF-20) | - |
| SQ-02-L5 | Lifeline | :PgUnitOfWork (IF-08) | - |
| SQ-02-L4 | Lifeline | :PaymentReportReceiver (IF-02) | - |
| SQ-02-L3 | Lifeline | :PaymentReportService | - |
| SQ-02-L2 | Lifeline | :PaymentCallbackController (PKG-12) | - |
| SQ-02-L1 | Lifeline | Cổng VNPay (ACT-07) | - |
| SQ-02-N1 | Note | so số tiền với giao dịch (BR-91), hoặc với tổng giá ghế khi giao dịch tạo từ báo; chỉ với báo thành công chưa xử lý; HoldSettlement.End(EXPIRY): quá hạn thì Hết hạn và trả ghế; decide(report, hold, txn, now) | Tự gọi của lifeline L3 |
| SQ-02-N2 | Note | HoldSettlement.Sell (kiểm mọi ghế IsHeldBy(hold), sai thì chuyển LATE với HOLD_LINK_BROKEN, log nghiêm trọng; Complete; NewBooking tạo vé); FinishSale (MarkSold); txn.MarkTicketed | Tự gọi của lifeline L3 |
| SQ-02-N3 | Note | txn.MarkLatePayment(reason) | Tự gọi của lifeline L3 |
| SQ-02-N4 | Note | txn.RecordFailure; chỉ khi txn là giao dịch mới nhất của lần giữ ghế và Đang giữ: HoldSettlement.End(PAYMENT_FAILURE) (FailPayment và trả ghế đã khoá), SaveChanges | Tự gọi của lifeline L3 |
| SQ-02-N5 | Note | txn.RecordDuplicate (không tạo vé, không hoàn thêm) | Tự gọi của lifeline L3 |
| SQ-02-N6 | Note | AMOUNT_MISMATCH (BR-91, BR-40): log, không ghi gì, kết thúc giao dịch bằng ROLLBACK; 40P01 hoặc 55P03 hết lần thử: TEMPORARY_FAILURE | Tự gọi của lifeline L3 |
| SQ-02-F4 | Fragment alt | alt kết quả decide | - |
| SQ-02-F4-G0 | Guard | [SELL: báo thành công, Đang giữ, chưa quá hạn] | Nhánh đầu của SQ-02-F4 |
| SQ-02-F4-D1 | Separator | [LATE: báo thành công, lần giữ ghế không còn hiệu lực] | Nhánh tiếp theo của SQ-02-F4 |
| SQ-02-F4-D2 | Separator | [FAILURE: báo thất bại] | Nhánh tiếp theo của SQ-02-F4 |
| SQ-02-F4-D3 | Separator | [DUPLICATE: giao dịch đã xử lý] | Nhánh tiếp theo của SQ-02-F4 |
| SQ-02-F3 | Fragment tx | tx: READ COMMITTED, lock_timeout 1 s; mọi báo cùng lần giữ ghế tuần tự hoá ở hạng 5 | - |
| SQ-02-F2 | Fragment alt | alt tìm thấy lần giữ ghế hoặc giao dịch | - |
| SQ-02-F2-G0 | Guard | [không tìm thấy cả hai] | Nhánh đầu của SQ-02-F2 |
| SQ-02-F2-D1 | Separator | [tìm thấy] | Nhánh tiếp theo của SQ-02-F2 |
| SQ-02-F1 | Fragment alt | alt chữ ký và định dạng | - |
| SQ-02-F1-G0 | Guard | [sai chữ ký hoặc thiếu tham số] | Nhánh đầu của SQ-02-F1 |
| SQ-02-F1-D1 | Separator | [hợp lệ] | Nhánh tiếp theo của SQ-02-F1 |

| ID | Nguồn | Đích | Loại | Nhãn (thứ tự STT trong nhãn) | Ghi chú |
|---|---|---|---|---|---|
| SQ-02-M1 | SQ-02-L1 | SQ-02-L2 | Message đồng bộ | GET /ipn?tham số đã ký | - |
| SQ-02-M2 | SQ-02-L2 | SQ-02-L3 | Message đồng bộ | HandleIpn(ctx, params) | - |
| SQ-02-M3 | SQ-02-L3 | SQ-02-L4 | Message đồng bộ | ReportTransactionResult(params) [kiểm chữ ký, giải mã] | - |
| SQ-02-M4 | SQ-02-L3 | SQ-02-L2 | Message trả về | IpnAnswer(INVALID_SIGNATURE hoặc MALFORMED), không ghi gì | - |
| SQ-02-M5 | SQ-02-L3 | SQ-02-L6 | Message đồng bộ | FindIDByRef(holdRef), FindByCode(code) [không khoá] | - |
| SQ-02-M6 | SQ-02-L3 | SQ-02-L2 | Message trả về | IpnAnswer(UNKNOWN_TRANSACTION), ghi log xử lý thủ công (BR-38) | - |
| SQ-02-M7 | SQ-02-L3 | SQ-02-L5 | Message đồng bộ | Do(UserTx("SettleReport"), fn) | - |
| SQ-02-M8 | SQ-02-L5 | SQ-02-L8 | Message đồng bộ | BEGIN; SET LOCAL lock_timeout | - |
| SQ-02-M9 | SQ-02-L3 | SQ-02-L6 | Message đồng bộ | LockByID [hạng 5 X] lần giữ ghế | - |
| SQ-02-M10 | SQ-02-L6 | SQ-02-L8 | Message đồng bộ | SELECT seat_hold FOR NO KEY UPDATE | - |
| SQ-02-M11 | SQ-02-L3 | SQ-02-L6 | Message đồng bộ | LockByHold [hạng 6 X, ORDER BY suất chiếu, ghế] | - |
| SQ-02-M12 | SQ-02-L6 | SQ-02-L8 | Message đồng bộ | SELECT seat_status WHERE current_hold_id FOR NO KEY UPDATE | - |
| SQ-02-M13 | SQ-02-L3 | SQ-02-L6 | Message đồng bộ | LockByCode [hạng 7 X] giao dịch (chưa có thì Insert dưới khoá hạng 5) | - |
| SQ-02-M14 | SQ-02-L6 | SQ-02-L8 | Message đồng bộ | SELECT payment_transaction FOR NO KEY UPDATE | - |
| SQ-02-M15 | SQ-02-L3 | SQ-02-L5 | Message đồng bộ | tx.Now() [một lần, sau khi có khoá] | - |
| SQ-02-M16 | SQ-02-L3 | SQ-02-L6 | Message đồng bộ | InsertWithTickets [hạng 8, dòng mới]; SaveChanges ghế (+ seat_event); UpdateStatus hold, txn | - |
| SQ-02-M17 | SQ-02-L3 | SQ-02-L7 | Message đồng bộ | Enqueue(EMAIL_TICKET) | - |
| SQ-02-M18 | SQ-02-L3 | SQ-02-L7 | Message đồng bộ | CreateFullRefund(tx, txn): AddRefunded [hạng 7 đã giữ]; Insert RefundRequest [hạng 9, dòng mới]; Enqueue(REFUND_GATEWAY) | - |
| SQ-02-M19 | SQ-02-L3 | SQ-02-L6 | Message đồng bộ | UpdateStatus hold (nếu vừa Expire), txn | - |
| SQ-02-M20 | SQ-02-L3 | SQ-02-L6 | Message đồng bộ | UpdateStatus hold, txn | - |
| SQ-02-M21 | SQ-02-L3 | SQ-02-L6 | Message đồng bộ | UpdateStatus txn | - |
| SQ-02-M22 | SQ-02-L5 | SQ-02-L8 | Message đồng bộ | COMMIT (rollback toàn bộ khi lỗi tạm thời) | - |
| SQ-02-M23 | SQ-02-L3 | SQ-02-L2 | Message trả về | IpnAnswer(PROCESSED, DUPLICATE, AMOUNT_MISMATCH hoặc TEMPORARY_FAILURE) | - |
| SQ-02-M24 | SQ-02-L2 | SQ-02-L1 | Message đồng bộ | HTTP 200 JSON RspCode (00, 02, 04, 01, 97, 99) | - |

SQ-03. Dọn hết hạn và giải phóng ghế EX-04, EX-05 (UC-005). File diagrams/P12-sequence-expiry-sweep.drawio. EX-04 và EX-05 theo lô: hết hạn rồi giải phóng, SKIP LOCKED chia lô giữa các bản backend, khoá cả lô hạng 5 trước cả lô hạng 6.

| ID | Loại | Nhãn | Ghi chú |
|---|---|---|---|
| SQ-03-L7 | Lifeline | PostgreSQL | - |
| SQ-03-L6 | Lifeline | :PgSeatEventStore (IF-22) | - |
| SQ-03-L5 | Lifeline | :PgTicketingStore (IF-17, IF-18, IF-26) | - |
| SQ-03-L4 | Lifeline | :PgUnitOfWork (IF-08) | - |
| SQ-03-L3 | Lifeline | :SeatReleaseJob (IF-06) | - |
| SQ-03-L2 | Lifeline | :HoldExpiryJob (IF-06) | - |
| SQ-03-L1 | Lifeline | :JobLoop (SS-04) | - |
| SQ-03-N1 | Note | SeatHold.Expire(now) từng dòng | Tự gọi của lifeline L2 |
| SQ-03-F2 | Fragment tx | tx (pool nền 5 kết nối): một giao dịch mỗi lô | - |
| SQ-03-F1 | Fragment loop | loop đến khi lô ít hơn 200 hoặc hết budget | - |
| SQ-03-N2 | Note | SeatStatus.ReleaseHold(holdId): chỉ đổi khi currentHold còn khớp | Tự gọi của lifeline L3 |
| SQ-03-F4 | Fragment tx | tx: khoá cả lô hạng 5 rồi cả lô hạng 6, không xen kẽ | - |
| SQ-03-F3 | Fragment loop | loop đến khi lô ít hơn 200 hoặc hết budget | - |
| SQ-03-N3 | Note | Hai bản backend quét chồng hoặc một ghế vừa được giữ lại cho lần giữ ghế khác: SKIP LOCKED chia lô, điều kiện current_hold_id không khớp nên không đổi gì | Phủ lifeline L2 đến L7 |

| ID | Nguồn | Đích | Loại | Nhãn (thứ tự STT trong nhãn) | Ghi chú |
|---|---|---|---|---|---|
| SQ-03-M1 | SQ-03-L1 | SQ-03-L2 | Message đồng bộ | RunDue(ctx, 8 s) [mỗi 10 giây, không chạy chồng] | - |
| SQ-03-M2 | SQ-03-L2 | SQ-03-L4 | Message đồng bộ | Do(BackgroundTx("ExpireBatch"), fn) | - |
| SQ-03-M3 | SQ-03-L2 | SQ-03-L5 | Message đồng bộ | LockExpiredBatch(200) [hạng 5 X, SKIP LOCKED, mã tăng dần] | - |
| SQ-03-M4 | SQ-03-L5 | SQ-03-L7 | Message đồng bộ | chọn mã ứng viên expiry_time đã qua; SELECT ... ORDER BY id FOR NO KEY UPDATE SKIP LOCKED | - |
| SQ-03-M5 | SQ-03-L2 | SQ-03-L4 | Message đồng bộ | tx.Now() [sau khi có khoá] | - |
| SQ-03-M6 | SQ-03-L2 | SQ-03-L5 | Message đồng bộ | UpdateStatus (chỉ khi còn Đang giữ) | - |
| SQ-03-M7 | SQ-03-L4 | SQ-03-L7 | Message đồng bộ | COMMIT | - |
| SQ-03-M8 | SQ-03-L2 | SQ-03-L6 | Message đồng bộ | DeleteOlderThan(10 phút, 200) [dọn seat_event] | - |
| SQ-03-M9 | SQ-03-L1 | SQ-03-L3 | Message đồng bộ | RunDue(ctx, 8 s) | - |
| SQ-03-M10 | SQ-03-L3 | SQ-03-L4 | Message đồng bộ | Do(BackgroundTx("ReleaseBatch"), fn) | - |
| SQ-03-M11 | SQ-03-L3 | SQ-03-L5 | Message đồng bộ | LockReleasableBatch(200) [hạng 5 X, SKIP LOCKED] | - |
| SQ-03-M12 | SQ-03-L5 | SQ-03-L7 | Message đồng bộ | SELECT lần giữ ghế ở trạng thái cuối khác COMPLETED còn ghế trỏ tới | - |
| SQ-03-M13 | SQ-03-L3 | SQ-03-L5 | Message đồng bộ | LockByHolds(holdIds) [hạng 6 X, ORDER BY suất chiếu, ghế] | - |
| SQ-03-M14 | SQ-03-L5 | SQ-03-L7 | Message đồng bộ | SELECT seat_status WHERE current_hold_id IN (...) FOR NO KEY UPDATE | - |
| SQ-03-M15 | SQ-03-L3 | SQ-03-L5 | Message đồng bộ | SaveChanges(ghế đã đổi) | - |
| SQ-03-M16 | SQ-03-L5 | SQ-03-L7 | Message đồng bộ | UPDATE seat_status theo khoá chính của các ghế đã khoá; INSERT seat_event mỗi suất chiếu | - |
| SQ-03-M17 | SQ-03-L4 | SQ-03-L7 | Message đồng bộ | COMMIT | - |

SQ-04. Huỷ vé EX-06, EX-07, EX-09 trong một giao dịch (UC-008). File diagrams/P12-sequence-cancel-ticket.drawio. Ghi nhận huỷ, trả ghế và tạo yêu cầu hoàn là một giao dịch khoá theo hạng 6, 7, 8 rồi chèn dòng hạng 9 (Q-133); hoàn tiền chỉ xếp hàng đợi, gọi cổng ở EX-10 ngoài sơ đồ. Nhánh tiền mặt (ConfirmCashRefund) dùng cùng khuôn, ghi ở ghi chú SQ-04-N5.

| ID | Loại | Nhãn | Ghi chú |
|---|---|---|---|
| SQ-04-L7 | Lifeline | PostgreSQL | - |
| SQ-04-L6 | Lifeline | :PgCinemaOperationsStore (IF-11) + :PgOutboxStore (IF-23) | - |
| SQ-04-L5 | Lifeline | :PgTicketingStore (IF-18, IF-19, IF-20, IF-21, IF-27) | - |
| SQ-04-L4 | Lifeline | :PgUnitOfWork (IF-08) | - |
| SQ-04-L3 | Lifeline | :RefundService | - |
| SQ-04-L2 | Lifeline | :CancelTicketService | - |
| SQ-04-L1 | Lifeline | :TicketController (PKG-11, tham chiếu) | - |
| SQ-04-N1 | Note | Booking.CheckCancellationChannel; Showtime.CheckCancellationDeadline(now); Ticket.Cancel(); SeatStatus.ReleaseTicket(ticketId): chỉ đổi khi currentTicket khớp | Tự gọi của lifeline L2 |
| SQ-04-N2 | Note | CheckRefundWithin(amount); NewTicketRefund | Tự gọi của lifeline L3 |
| SQ-04-N3 | Note | Lỗi (TicketStateError, ChannelMismatchError, CancelDeadlineError, RefundLimitError): ROLLBACK trọn, không ghi gì. 40P01: rollback rồi chạy lại cả giao dịch, tối đa 2 lần | Phủ nhiều lifeline |
| SQ-04-N4 | Note | EX-10 (gọi cổng, 30 giây) chạy ở RefundOutboxJob sau commit, ngoài sơ đồ này | Phủ nhiều lifeline |
| SQ-04-N5 | Note | Nhánh tiền mặt (ConfirmCashRefund): cùng khuôn nhưng bỏ hạng 7 (M7 đến M9) và hàng đợi (M15 đến M18); sau Ticket.Cancel và ReleaseTicket thì Insert RefundRequest TICKET_CASH đã REFUNDED [hạng 9, dòng mới]; không gọi cổng, không email | Phủ nhiều lifeline |
| SQ-04-F1 | Fragment tx | tx: ghi nhận huỷ, trả ghế, tạo yêu cầu hoàn (một giao dịch, Q-133) | - |

| ID | Nguồn | Đích | Loại | Nhãn (thứ tự STT trong nhãn) | Ghi chú |
|---|---|---|---|---|---|
| SQ-04-M1 | SQ-04-L1 | SQ-04-L2 | Message đồng bộ | CancelOnlineTicket(ctx, ticketId, customer) | - |
| SQ-04-M2 | SQ-04-L2 | SQ-04-L4 | Message đồng bộ | Do(UserTx("CancelTicket"), fn) | - |
| SQ-04-M3 | SQ-04-L2 | SQ-04-L5 | Message đồng bộ | FindByTicket [không khoá: lần đặt, vé, kênh, người mua] | - |
| SQ-04-M4 | SQ-04-L2 | SQ-04-L6 | Message đồng bộ | FindByID suất chiếu [không khoá] | - |
| SQ-04-M5 | SQ-04-L2 | SQ-04-L5 | Message đồng bộ | LockByKey ghế [hạng 6 X] | - |
| SQ-04-M6 | SQ-04-L5 | SQ-04-L7 | Message đồng bộ | SELECT seat_status FOR NO KEY UPDATE | - |
| SQ-04-M7 | SQ-04-L2 | SQ-04-L5 | Message đồng bộ | lockPaymentOfTicket: FindByTicket, FindTicketedByHold [không khoá] | - |
| SQ-04-M8 | SQ-04-L2 | SQ-04-L5 | Message đồng bộ | LockByID giao dịch [hạng 7 X] | - |
| SQ-04-M9 | SQ-04-L5 | SQ-04-L7 | Message đồng bộ | SELECT payment_transaction FOR NO KEY UPDATE | - |
| SQ-04-M10 | SQ-04-L2 | SQ-04-L5 | Message đồng bộ | LockTicketByID [hạng 8 X] | - |
| SQ-04-M11 | SQ-04-L5 | SQ-04-L7 | Message đồng bộ | SELECT ticket FOR NO KEY UPDATE | - |
| SQ-04-M12 | SQ-04-L2 | SQ-04-L4 | Message đồng bộ | tx.Now() [sau khi có khoá] | - |
| SQ-04-M13 | SQ-04-L2 | SQ-04-L5 | Message đồng bộ | UpdateTicketStatus | - |
| SQ-04-M14 | SQ-04-L2 | SQ-04-L5 | Message đồng bộ | SaveChanges(ghế) [UPDATE theo khoá chính; INSERT seat_event] | - |
| SQ-04-M15 | SQ-04-L2 | SQ-04-L3 | Message đồng bộ | RequestTicketRefund(ctx, tx, txn, ticket, amount) | - |
| SQ-04-M16 | SQ-04-L3 | SQ-04-L5 | Message đồng bộ | AddRefunded: UPDATE refunded_total = refunded_total + amount WHERE tổng <= đã thanh toán | - |
| SQ-04-M17 | SQ-04-L3 | SQ-04-L5 | Message đồng bộ | Insert RefundRequest [hạng 9, dòng mới, unique idempotencyKey] | - |
| SQ-04-M18 | SQ-04-L3 | SQ-04-L6 | Message đồng bộ | Enqueue(REFUND_GATEWAY) [cùng giao dịch] | - |
| SQ-04-M19 | SQ-04-L4 | SQ-04-L7 | Message đồng bộ | COMMIT | - |
| SQ-04-M20 | SQ-04-L2 | SQ-04-L1 | Message trả về | CancelResult(refundAmount, refundStatus = NEW) | - |

SQ-05. Soát vé EX-08 (UC-009). File diagrams/P12-sequence-check-ticket.drawio. EX-08 soát vé: khoá hạng 8 làm hai lần soát đồng thời chỉ một lần thành công.

| ID | Loại | Nhãn | Ghi chú |
|---|---|---|---|
| SQ-05-L6 | Lifeline | PostgreSQL | - |
| SQ-05-L5 | Lifeline | :PgCinemaOperationsStore (IF-11) | - |
| SQ-05-L4 | Lifeline | :PgTicketingStore (IF-27) | - |
| SQ-05-L3 | Lifeline | :PgUnitOfWork (IF-08) | - |
| SQ-05-L2 | Lifeline | :CheckTicketService | - |
| SQ-05-L1 | Lifeline | :TicketController (PKG-11, tham chiếu) | - |
| SQ-05-N1 | Note | Ticket.Admit(showtime, selected, cinemaId): cụm rạp, suất chiếu, đã sử dụng, đã huỷ (BR-33) | Tự gọi của lifeline L2 |
| SQ-05-N2 | Note | không ghi gì | Tự gọi của lifeline L2 |
| SQ-05-F2 | Fragment alt | alt kết quả Admit | - |
| SQ-05-F2-G0 | Guard | [ADMITTED: vé chuyển Đã sử dụng] | Nhánh đầu của SQ-05-F2 |
| SQ-05-F2-D1 | Separator | [WRONG_CINEMA, WRONG_SHOWTIME, ALREADY_USED, CANCELLED] | Nhánh tiếp theo của SQ-05-F2 |
| SQ-05-F1 | Fragment tx | tx: lock_timeout 1 s; hai nhân viên quét cùng vé: người sau chờ khoá hạng 8 | - |

| ID | Nguồn | Đích | Loại | Nhãn (thứ tự STT trong nhãn) | Ghi chú |
|---|---|---|---|---|---|
| SQ-05-M1 | SQ-05-L1 | SQ-05-L2 | Message đồng bộ | CheckTicket(ctx, ticketCode, showtimeId, checker) | - |
| SQ-05-M2 | SQ-05-L2 | SQ-05-L3 | Message đồng bộ | Do(UserTx("CheckTicket"), fn) | - |
| SQ-05-M3 | SQ-05-L3 | SQ-05-L6 | Message đồng bộ | BEGIN; SET LOCAL lock_timeout | - |
| SQ-05-M4 | SQ-05-L2 | SQ-05-L4 | Message đồng bộ | LockTicketByCode [hạng 8 X] | - |
| SQ-05-M5 | SQ-05-L4 | SQ-05-L6 | Message đồng bộ | SELECT ticket WHERE ticket_code FOR NO KEY UPDATE | - |
| SQ-05-M6 | SQ-05-L2 | SQ-05-L5 | Message đồng bộ | FindByID suất chiếu [không khoá] | - |
| SQ-05-M7 | SQ-05-L2 | SQ-05-L4 | Message đồng bộ | UpdateTicketStatus(USED) | - |
| SQ-05-M8 | SQ-05-L3 | SQ-05-L6 | Message đồng bộ | COMMIT | - |
| SQ-05-M9 | SQ-05-L2 | SQ-05-L1 | Message trả về | AdmitResult(outcome, bookingCode, seatLabel, seatType) | - |

## F4. Bảng ánh xạ message --> operation

P07 không được đính kèm trong lần chạy này theo yêu cầu người dùng, nên F4 ánh xạ từ trách nhiệm của P08 F3 (dạng "// tênTráchNhiệm") sang operation, không từ từng message P07. Cột STT message ghi "P08". Việc đối chiếu từng message P07 để bắt message còn sót ghi ở Vấn đề còn mở 2. Trách nhiệm của lớp ngoài phạm vi ghi "Lượt sau".

| UC | STT message (P07) | Từ (AC/DC) | Đến (AC/DC) | Message phân tích (// tênTráchNhiệm) | Operation thiết kế (chữ ký đầy đủ) |
|---|---|---|---|---|---|
| UC-005 | P08 | AC-C-BookTicketsController | DC-SeatMapService | // startBooking | DC-SeatMapService.GetSnapshot(ctx Ctx, showtimeId ShowtimeId) (SeatSnapshot, error). Khác lớp nhận: P10 cơ chế SSE (provideSeatMap tách khỏi Showtime) |
| UC-005 | P08 | AC-C-BookTicketsController | DC-BookTicketsService | // requestSeatHold | DC-BookTicketsService.HoldSeats(ctx Ctx, req HoldSeatsRequest) (HoldResult, error) |
| UC-005 | P08 | AC-C-BookTicketsController | DC-AuthFilter (PKG-11) | // checkCustomerLoggedIn | Khác lớp nhận: P10 F3 cơ chế Bảo mật; DC-AuthFilter gọi IF-07.VerifySession (lượt PKG-11), không là operation trong phạm vi |
| UC-005 | P08 | AC-C-BookTicketsController | DC-HoldExpiryJob | // startWaitingForHoldExpiry | Không còn là lời gọi: hết hạn tính theo expiryTime (P09 F7.4, A7); DC-HoldExpiryJob.RunDue(ctx Ctx, budget time.Duration) (JobRunResult, error) |
| UC-005 | P08 | AC-C-BookTicketsController | DC-BookTicketsService | // startOnlinePayment | DC-BookTicketsService.StartOnlinePayment(ctx Ctx, holdId SeatHoldId, by HolderRef, clientIp string) (PaymentStart, error) |
| UC-005 | P08 | AC-C-BookTicketsController | DC-BookTicketsService | // stopWaitingForHoldExpiry | Không còn là lời gọi (P09 A7): CancelHold và ConfirmCashReceived đổi trạng thái lần giữ ghế dưới khoá nên lần quét hết hạn thấy trạng thái cuối |
| UC-005 | P08 | AC-C-BookTicketsController | DC-HoldExpiryJob, DC-SeatReleaseJob | // handleHoldExpired | Khác lớp nhận: P10 F3 (BookTicketsController tách thành DC-BookTicketsService và DC-HoldExpiryJob). DC-HoldExpiryJob.RunDue và DC-SeatReleaseJob.RunDue(ctx Ctx, budget time.Duration) (JobRunResult, error) |
| UC-005 | P08 | AC-C-BookTicketsController | DC-BookTicketsService | // cancelSeatHold | DC-BookTicketsService.CancelHold(ctx Ctx, holdId SeatHoldId, by HolderRef) error |
| UC-005 | P08 | AC-C-BookTicketsController | DC-BookTicketsService | // confirmCashReceived | DC-BookTicketsService.ConfirmCashReceived(ctx Ctx, holdId SeatHoldId, clerk HolderRef) (BookingView, error) |
| UC-005 | P08 | AC-B-BookTicketsForm, AC-B-CounterBookTicketsForm | DC-SeatMapService | // updateSeatMap | DC-SeatMapService.OpenStream(ctx Ctx, showtimeId ShowtimeId, afterEventId EventId) (SseStream, error), qua IF-04.Subscribe (P10 F2 SS-03) |
| UC-005, UC-006 | P08 | AC-C-PaymentReportController | DC-PaymentReportService | // handlePaymentReport | DC-PaymentReportService.HandleIpn(ctx Ctx, params map[string]string) IpnAnswer |
| UC-006 | P08 | AC-C-PaymentReportController | DC-PaymentReportService | // logUnrecognizedTransaction | DC-PaymentReportService.logUnrecognized(r PaymentReport) |
| UC-006 | P08 | AC-C-PaymentReportController, AC-C-CancelTicketController | DC-RefundService | // startWaitingForRefundResult, // stopWaitingForRefundResult | Không còn là lời gọi: chờ 30 giây là thời gian chờ của IF-01.RequestRefund bên trong DC-RefundService.ProcessRefund (P09 F7.7). Khác lớp nhận: P10 F3 (Q-106) |
| UC-006, UC-008 | P08 | AC-C-PaymentReportController, AC-C-CancelTicketController | DC-RefundService | // handleRefundNoResponse | DC-RefundService.ProcessRefund(ctx Ctx, e OutboxEntry) error (kết quả UNKNOWN). Khác lớp nhận: P10 F3 (Q-106) |
| UC-006, UC-008 | P08 | AC-C-PaymentReportController, AC-C-CancelTicketController | DC-RefundService | // logRefundFailure | DC-RefundService.ProcessRefund (RefundRequest.RecordResult hoặc MarkManualRequired). Khác lớp nhận: P10 F3 (Q-106) |
| UC-008 | P08 | AC-C-CancelTicketController | DC-CancelTicketService | // requestCancellation | DC-CancelTicketService.CancelOnlineTicket(ctx Ctx, ticketId TicketId, customer ActorContext) (CancelResult, error) |
| UC-008 | P08 | AC-C-CancelTicketController | DC-CancelTicketService | // findBookingTickets | DC-CancelTicketService.FindBooking(ctx Ctx, bookingCode string, actor ActorContext) (BookingView, error) |
| UC-008 | P08 | AC-C-CancelTicketController | DC-CancelTicketService | // confirmCashRefund | DC-CancelTicketService.ConfirmCashRefund(ctx Ctx, ticketId TicketId, clerk ActorContext) (CancelResult, error) |
| UC-009 | P08 | AC-C-CheckTicketController | DC-CheckTicketService | // startChecking | DC-CheckTicketService.StartChecking(ctx Ctx, showtimeId ShowtimeId, checker ActorContext) (ShowtimeInfo, error) |
| UC-009 | P08 | AC-C-CheckTicketController | DC-CheckTicketService | // checkTicket | DC-CheckTicketService.CheckTicket(ctx Ctx, ticketCode string, showtimeId ShowtimeId, checker ActorContext) (AdmitResult, error) |
| UC-005, UC-006 | P08 | AC-B-PaymentGateway | IF-01, IF-02 | // createPaymentTransaction, // requestRefund, // findRefund, // reportTransactionResult | IF-01.CreatePaymentTransaction, IF-01.RequestRefund, IF-01.FindRefund, IF-02.ReportTransactionResult (chữ ký P11b F3, đổi kiểu theo F2) |
| UC-005 | P08 | AC-C-BookTicketsController | DC-Customer | // checkNoActiveSeatHold | DC-Customer.CheckNoActiveSeatHold(unfinished []*SeatHold, now time.Time) error |
| UC-005 | P08 | AC-E-Customer | IF-07 | // authenticateCustomer | Khác lớp nhận: P10 F3. IF-07.VerifyPassword(plainPassword string, storedHash string) (bool, error); DC-Customer chỉ giữ dữ liệu đăng nhập |
| UC-006 | P08 | AC-C-PaymentReportController | DC-Customer | // provideEmail | DC-Customer.Email() string |
| UC-005 | P08 | AC-C-BookTicketsController | DC-BoxOfficeClerk | // checkNoActiveSeatHold (nhân viên quầy) | DC-BoxOfficeClerk.CheckNoActiveSeatHold(unfinished []*SeatHold, now time.Time) error |
| UC-005, UC-008 | P08 | AC-C-BookTicketsController | DC-BoxOfficeClerk | // provideCinema | DC-BoxOfficeClerk.CinemaId() CinemaId |
| UC-009 | P08 | AC-C-CheckTicketController | DC-ActorContext | // provideCinema (AC-E-TicketChecker) | Khác lớp nhận: cụm rạp của nhân viên soát vé nằm trong DC-ActorContext.cinemaId dựng từ SessionClaims; DC-TicketChecker thuộc lượt PKG-27 |
| UC-005 | P08 | AC-C-BookTicketsController | DC-Showtime | // checkSaleOpen | DC-Showtime.CheckSaleOpen(now time.Time) error |
| UC-005 | P08 | AC-C-BookTicketsController | DC-SeatMapService | // provideSeatMap | DC-SeatMapService.GetSnapshot (xem dòng startBooking). Khác lớp nhận: P10 cơ chế SSE |
| UC-005 | P08 | AC-C-BookTicketsController | DC-Showtime | // checkSeatSelectionLimit | DC-Showtime.CheckSeatSelection(selected []*Seat) error |
| UC-005 | P08 | AC-C-BookTicketsController | DC-Showtime, DC-BookTicketsService | // holdSeats | DC-Showtime.QuoteSeatPrices(list *PriceList, room *Auditorium, seats []*Seat) (map[SeatId]Money, error) cho phần chốt giá; phần tạo SeatHold và đổi SeatStatus do DC-BookTicketsService.HoldSeats điều phối. Khác lớp nhận: Q-117, P10 F3 |
| UC-005, UC-014 | P08 | AC-C-BookTicketsController | DC-Showtime | // checkUnchangedSinceDisplayed | DC-Showtime.CheckUnchangedSince(displayedAt time.Time) error |
| UC-005, UC-008, UC-009 | P08 | AC-C-BookTicketsController | DC-Showtime | // checkBelongsToCinema | DC-Showtime.BelongsToCinema(cinemaId CinemaId) bool |
| UC-008 | P08 | AC-C-CancelTicketController | DC-Showtime | // checkCancellationDeadline | DC-Showtime.CheckCancellationDeadline(now time.Time) error |
| UC-006, UC-009, UC-014 | P08 | AC-C-CheckTicketController | DC-Showtime | // provideShowtimeInfo | IF-11.FindInfo(ctx Ctx, id ShowtimeId) (ShowtimeInfo, error) và DC-Showtime.LastChangedAt(). Khác lớp nhận: dữ liệu hiển thị là mô hình đọc join |
| UC-013, UC-014 | P08 | AC-E-Showtime | DC-Showtime | // checkUsesPriceEntry, // createShowtime, // checkSaleOpenBeforeStart, // calculateEndTime, // checkNotStarted, // checkNoActiveHoldOrSoldTicket, // checkRoomChangeAllowed, // applyChanges, // removeFromSchedule, // markDeleted | Lượt sau (PKG-27 và PKG-16). // checkRoomChangeAllowed là operation riêng của DC-Showtime, gọi trước applyChanges: đổi phòng phải bị từ chối nếu suất chiếu từng có vé, kể cả vé đã huỷ (BR-92, P13 C-19), kiểm dưới khoá Ticket S hạng 8 và báo lỗi nghiệp vụ trước khi chạm khoá ngoại fk_ticket_seat_status |
| UC-005 | P08 | AC-E-Showtime | DC-PriceList | // determineSeatPrice | DC-PriceList.DetermineSeatPrice(q PriceQuery) (Money, error) |
| UC-013, UC-014 | P08 | AC-E-PriceList | DC-PriceList | // providePriceEntries, // checkTicketPriceValid, // savePriceEntry, // checkEntryUnchangedSinceDisplayed, // findOrCreatePriceEntry, // removePriceEntry, // deletePriceEntry, // determineTimeBand, // checkCoversShowtime | Lượt sau (PKG-27 và PKG-16) |
| UC-005 | P08 | AC-E-SeatStatus | DC-SeatMapService | // provideSeatStatus | DC-SeatMapService.GetSnapshot (SeatSnapshot.seats). Khác lớp nhận: ảnh chụp một câu SQL qua IF-22.Snapshot |
| UC-005 | P08 | AC-E-SeatStatus | DC-SeatStatus | // holdSeatFor, // recordHeldPrice | DC-SeatStatus.HoldFor(holdId SeatHoldId, price Money) error (recordHeldPrice gộp vào HoldFor: giữ ghế và chốt giá là một bước) |
| UC-005 | P08 | AC-E-SeatStatus | DC-SeatStatus | // provideHeldSeatInfo | DC-SeatStatus.HeldPrice() Money và IF-18.FindByHold; vị trí ghế, loại ghế lấy qua R-45 |
| UC-005 | P08 | AC-E-SeatStatus | DC-SeatStatus | // markSold | DC-SeatStatus.MarkSold(holdId SeatHoldId, ticketId TicketId) error |
| UC-005, UC-008 | P08 | AC-E-SeatStatus | DC-SeatStatus | // releaseSeat | DC-SeatStatus.ReleaseHold(holdId SeatHoldId) bool và DC-SeatStatus.ReleaseTicket(ticketId TicketId) bool (hai operation theo hai nguồn liên kết, không dùng tham số kiểu để chọn) |
| UC-005 | P08 | AC-E-SeatHold | DC-SeatHold | // createSeatHold | DC-SeatHold.NewSeatHold(holder HolderRef, showtimeId ShowtimeId, requestId string, holdRef string, now time.Time) *SeatHold |
| UC-005 | P08 | AC-E-SeatHold | DC-BookTicketsService | // provideHoldSummary | DC-BookTicketsService.GetHold(ctx Ctx, holdId SeatHoldId, by HolderRef) (HoldResult, error). Khác lớp nhận: dữ liệu ghế nằm ở SeatStatus (Q-117) |
| UC-005 | P08 | AC-E-SeatHold | DC-SeatHold | // calculateTotalAmount | DC-SeatHold.CalculateTotal(seats []*SeatStatus) Money |
| UC-005, UC-006 | P08 | AC-E-SeatHold | DC-PaymentTransaction | // recordPaymentTransaction | DC-PaymentTransaction.NewPending(hold *SeatHold, code string, amount Money) *PaymentTransaction |
| UC-005, UC-006 | P08 | AC-E-SeatHold | DC-PaymentReportService | // settlePaymentReport | DC-PaymentReportService.HandleIpn và decide (thao tác không chia cắt do lớp dịch vụ điều phối vì SeatHold không gọi SeatStatus, Booking, Ticket; Q-117, P10 F3a EX-02) |
| UC-005, UC-006, UC-014 | P08 | AC-E-SeatHold | DC-SeatHold | // checkHoldStillActive | DC-SeatHold.IsActiveAt(now time.Time) bool |
| UC-005 | P08 | AC-E-SeatHold | DC-SeatHold | // endHold | DC-SeatHold.Complete(now time.Time) error, DC-SeatHold.Cancel(now time.Time) error, DC-SeatHold.FailPayment(now time.Time) error (ba đích khác nhau thành ba operation); Expire cho đích Hết hạn. Service không gọi trực tiếp: DC-HoldSettlement.End và Sell gọi (Khác lớp nhận: X1 RV-01) |
| UC-005 | P08 | AC-E-SeatHold | DC-Booking | // issueBooking | DC-Booking.NewBooking(hold *SeatHold, code string, seats []*SeatStatus, ticketCodes []string) *Booking, gọi từ DC-HoldSettlement.Sell (Khác lớp nhận: X1 RV-01) |
| UC-005 | P08 | AC-E-SeatHold | DC-SeatHold | // expire | DC-SeatHold.Expire(now time.Time) bool |
| UC-005 | P08 | AC-E-SeatHold | DC-SeatStatus | // releaseHeldSeats | DC-SeatStatus.ReleaseHold(holdId SeatHoldId) bool, gọi trong giao dịch kết thúc lần giữ ghế qua DC-HoldSettlement.End (DC-BookTicketsService.CancelHold, ConfirmCashReceived, HoldSeats, DC-PaymentReportService.HandleIpn) và trực tiếp trong DC-SeatReleaseJob.releaseBatch (Khác lớp nhận: P10 F3 AC-E-SeatHold; Q-134) |
| UC-005 | P08 | AC-E-SeatHold | DC-SeatHold | // cancel | DC-SeatHold.Cancel(now time.Time) error |
| UC-005 | P08 | AC-E-SeatHold | DC-BookTicketsService | // completeSaleOnCashConfirmation | DC-BookTicketsService.ConfirmCashReceived (dùng DC-HoldSettlement.Sell và FinishSale, qua đó DC-SeatHold.Complete, DC-SeatStatus.MarkSold). Khác lớp nhận: Q-117 |
| UC-006 | P08 | AC-E-SeatHold | DC-EmailOutboxJob (PKG-20) | // provideRefundNoticeRecipient | Khác lớp nhận: nội dung email hoàn tiền do DC-EmailOutboxJob dựng (P10 F3, lượt PKG-20) từ DC-SeatHold.Holder() và IF-16.FindCustomer |
| UC-005 | 14 | AC-C-PaymentReportController | DC-EmailOutboxJob (PKG-20) | // sendTicketsEmail | Khác lớp nhận: IF-23.Enqueue(EMAIL_TICKET) trong DC-PaymentReportService.HandleIpn bước 6 nhánh SELL, cùng giao dịch với bán ghế; DC-EmailOutboxJob (PKG-20, lượt sau) gửi sau commit |
| UC-006 | 7 | AC-C-PaymentReportController | DC-EmailOutboxJob (PKG-20) | // sendRefundNotificationEmail | Khác lớp nhận: IF-23.Enqueue(EMAIL_REFUND) trong DC-RefundService.ProcessRefund bước 3, chỉ khi requestType là FULL; DC-EmailOutboxJob (PKG-20, lượt sau) gửi |
| UC-008 | P08 | AC-E-SeatHold | DC-SeatHold | // checkHeldBy | DC-SeatHold.IsHeldBy(holder HolderRef) bool |
| UC-008 | P08 | AC-E-SeatHold | IF-19 | // providePaymentTransaction | IF-19.FindTicketedByHold(ctx Ctx, tx Tx, holdId SeatHoldId) (*PaymentTransaction, error) |
| UC-005, UC-006 | P08 | AC-E-PaymentTransaction | DC-PaymentTransaction | // createPaymentTransaction | DC-PaymentTransaction.NewPending |
| UC-005, UC-006 | P08 | AC-E-PaymentTransaction | DC-PaymentTransaction | // checkNotProcessed | DC-PaymentTransaction.IsProcessed() bool |
| UC-005 | P08 | AC-E-PaymentTransaction | DC-PaymentTransaction | // markProcessed | DC-PaymentTransaction.MarkTicketed(gatewayTransactionNo string, paidAt time.Time) error |
| UC-005, UC-006 | P08 | AC-E-PaymentTransaction | DC-PaymentTransaction | // recordFailedResult | DC-PaymentTransaction.RecordFailure() bool |
| UC-006 | P08 | AC-E-PaymentTransaction | DC-PaymentTransaction | // markLatePayment | DC-PaymentTransaction.MarkLatePayment(gatewayTransactionNo string, paidAt time.Time, reason string) error |
| UC-006 | P08 | AC-E-PaymentTransaction | DC-PaymentTransaction | // recordDuplicateReport | DC-PaymentTransaction.RecordDuplicate() error |
| UC-006, UC-008 | P08 | AC-E-PaymentTransaction | DC-RefundService | // prepareRefundRequest | DC-RefundService.CreateFullRefund(ctx Ctx, tx Tx, txn *PaymentTransaction) error và DC-RefundService.RequestTicketRefund(ctx Ctx, tx Tx, txn *PaymentTransaction, ticket *Ticket, amount Money) error. Khác lớp nhận: tạo yêu cầu hoàn cần giao dịch và kho khác (Q-117, Q-106) |
| UC-006, UC-008 | P08 | AC-E-PaymentTransaction | DC-PaymentTransaction | // checkRefundWithinPaidAmount | DC-PaymentTransaction.CheckRefundWithin(amount Money) error |
| UC-006, UC-008 | P08 | AC-E-PaymentTransaction | DC-PaymentTransaction | // recordRefundedAmount | DC-PaymentTransaction.RecordRefunded(amount Money) error và IF-19.AddRefunded |
| UC-006 | P08 | AC-E-PaymentTransaction | DC-PaymentTransaction | // provideRefundSummary | DC-PaymentTransaction.Code() string, DC-PaymentTransaction.Amount() Money |
| UC-006, UC-008 | P08 | AC-E-RefundRequest | DC-RefundRequest | // createRefundRequest, // generateIdempotencyKey | DC-RefundRequest.NewFullRefund, NewTicketRefund, NewCashRefund (khoá sinh trong factory, không đổi qua các lần thử) |
| UC-006, UC-008 | P08 | AC-E-RefundRequest | DC-RefundRequest | // recordAttempt | DC-RefundRequest.BeginAttempt() error |
| UC-006, UC-008 | P08 | AC-E-RefundRequest | DC-RefundRequest | // recordResult | DC-RefundRequest.RecordResult(r AttemptResult, detail string) error |
| UC-006, UC-008 | P08 | AC-E-RefundRequest | DC-RefundRequest | // checkRetryRemaining | DC-RefundRequest.HasAttemptsRemaining() bool |
| UC-008 | P08 | AC-E-RefundRequest | DC-RefundRequest | // provideRefundInfo | DC-RefundRequest.Status() RefundStatus, DC-RefundRequest.Amount() Money |
| UC-005 | P08 | AC-E-Booking | DC-Booking | // createBooking | DC-Booking.NewBooking |
| UC-005 | P08 | AC-E-Booking | IF-24 | // generateBookingCode | Khác lớp nhận: IF-24.NewBookingCode() string (bộ sinh mã nhận qua constructor, Bước 2.6) |
| UC-005, UC-008 | P08 | AC-E-Booking | DC-Booking | // provideBookingInfo | DC-Booking.Tickets() []*Ticket; dữ liệu hiển thị dựng thành BookingView |
| UC-008 | P08 | AC-E-Booking | DC-Booking | // checkCancellationChannel | DC-Booking.CheckCancellationChannel(actor ActorContext) error |
| UC-008 | P08 | AC-E-Booking | IF-19 | // providePaymentTransaction | IF-19.FindTicketedByHold |
| UC-009 | P08 | AC-E-Booking | DC-Booking | // provideBookingCode | DC-Booking.Code() string |
| UC-005 | P08 | AC-E-Ticket | DC-Ticket | // createTicket | DC-Ticket.newTicket(key SeatKey, price Money, code string) *Ticket (nội bộ PKG-28, gọi từ DC-Booking.NewBooking) |
| UC-005 | P08 | AC-E-Ticket | IF-24 | // generateQrCode | IF-24.NewTicketCode() string; ảnh mã QR dựng từ mã vé khi hiển thị hoặc gửi, không lưu |
| UC-005, UC-008, UC-009 | P08 | AC-E-Ticket | DC-Ticket | // provideTicketContent | DC-Ticket.Code(), Price(), Status(), Key() và IF-21.FindByTicket; ghép thành BookingView |
| UC-008 | P08 | AC-E-Ticket | DC-Ticket | // cancelTicket, // checkNotCancelledNotUsed, // markCancelled | DC-Ticket.Cancel() error (một operation vì ba trách nhiệm là một thao tác không chia cắt) |
| UC-008 | P08 | AC-E-Ticket | DC-Ticket | // calculateRefundAmount | DC-Ticket.RefundAmount() Money |
| UC-008 | P08 | AC-E-Ticket | DC-RefundRequest | // recordCashRefund | DC-RefundRequest.NewCashRefund(ticket *Ticket, amount Money) *RefundRequest. Khác lớp nhận: P10 F3a EX-07 (DC-CancelTicketService.cancelCashInTx gọi) |
| UC-008 | P08 | AC-E-Ticket | DC-CancelTicketService | // releaseTicketSeat | DC-CancelTicketService.cancelAndReleaseSeat(ctx Ctx, tx Tx, showtime *Showtime, ticket *Ticket, seat *SeatStatus, now time.Time) error, dùng chung bởi cancelOnlineInTx và cancelCashInTx, gọi DC-SeatStatus.ReleaseTicket (Q-117: Ticket không gọi SeatStatus) |
| UC-009 | P08 | AC-E-Ticket | DC-Ticket | // admitTicket, // markUsed | DC-Ticket.Admit(showtime *Showtime, selected ShowtimeId, cinemaId CinemaId) AdmitOutcome (markUsed là bước bên trong, private) |
| UC-014 | P08 | AC-E-Ticket | DC-Ticket | // checkNotCancelled | DC-Ticket.IsCancelled() bool |

## F5. Bảng quan hệ

Quan hệ có gốc từ P08 giữ mã R-nn (R-10 đến R-15, R-18, R-44 đến R-56, R-60, R-63, R-64); đổi loại, đổi chiều hoặc đổi Lớp A ghi ở cột Lý do và ở Đề xuất sửa P08. Quan hệ mới từ R-65. Quan hệ P08 có một đầu ngoài phạm vi (R-16, R-17, R-19, R-30 đến R-43, R-57 đến R-59, R-61, R-62) do lượt chạy chứa Lớp A thiết kế (Vấn đề còn mở 1). Association "tiêm phụ thuộc" ghi A 0..* - B 1: mỗi bên dùng giữ đúng một bên được tiêm qua constructor, một thể hiện dùng chung. Dependency Căn cứ local là nạp qua interface kho trong method rồi dùng; parameter là nhận qua tham số.

| ID | Lớp A | Lớp B | Loại | Multiplicity | Điều hướng | Lý do | Vai trò (đầu A / đầu B) | Căn cứ hiển thị |
|---|---|---|---|---|---|---|---|---|
| R-10 | DC-BookTicketsService | DC-SeatHold | Dependency | - | A --> B | Đổi từ Association tạm của P08: control nhận SeatHold qua tham số và biến cục bộ, nạp bằng IF-17 | - | local |
| R-11 | DC-BookTicketsService | DC-Booking | Dependency | - | A --> B | Đổi từ Association tạm của P08: tạo lần đặt (EX-03) trong method | - | local |
| R-12 | DC-PaymentReportService | DC-SeatHold | Dependency | - | A --> B | Đổi từ Association tạm: biến cục bộ nạp bằng IF-17 (EX-02) | - | local |
| R-13 | DC-PaymentReportService | DC-Booking | Dependency | - | A --> B | Đổi từ Association tạm: tạo lần đặt trong method (EX-02) | - | local |
| R-14 | DC-PaymentReportService | DC-PaymentTransaction | Dependency | - | A --> B | Đổi từ Association tạm: biến cục bộ nạp bằng IF-19 | - | local |
| R-15 | DC-PaymentReportService | DC-RefundRequest | Dependency | - | A --> B | Đổi từ Association tạm: tạo qua DC-RefundService trong giao dịch EX-02 | - | local |
| R-18 | DC-RefundService | IF-01 | Association | A 0..* - B 1 | A --> B | Đổi lớp A: AC-B-PaymentGateway thành IF-01 theo P10 F3, hoàn tiền thuộc DC-RefundService (Q-106); Thiết kế: tiêm phụ thuộc | gateway | field |
| R-44 | DC-Showtime | DC-SeatStatus | Association | A 1 - B 1..* | B --> A | SeatStatus giữ mã suất chiếu trong key; PKG-27 không phụ thuộc PKG-28 nên chiều chỉ B --> A (P09 F4); Showtime không liệt kê ghế, tìm bằng truy vấn | showtime / seatStatuses | field |
| R-45 | DC-SeatStatus | DC-Seat | Association | A 0..* - B 1 | A --> B | Ghế của phòng chiếu; DC-Seat ngoài phạm vi, chỉ tên | seat | field |
| R-46 | DC-Showtime | DC-SeatHold | Association | A 1 - B 0..* | B --> A | SeatHold giữ mã suất chiếu; chiều B --> A vì PKG-27 không phụ thuộc PKG-28 (P09 F4, Q-117) | showtime / holds | field |
| R-47 | DC-SeatHold | DC-SeatStatus | Association | A 0..* - B 1..8 | Hai chiều | Quan hệ lịch sử của P08 được hiện thực bằng R-63 khi Đang giữ; không có bảng nối riêng. Vấn đề còn mở 6 | holds / seats | field |
| R-48 | DC-SeatHold | DC-Customer | Association | A 0..* - B 0..1 | A --> B | Người giữ ghế là khách; {xor} với R-49; hiện thực bằng HolderRef (kind, id) | holder | field |
| R-49 | DC-SeatHold | DC-BoxOfficeClerk | Association | A 0..* - B 0..1 | A --> B | Người giữ ghế là nhân viên quầy; {xor} với R-48 | holder | field |
| R-50 | DC-SeatHold | DC-PaymentTransaction | Association | A 1 - B 0..* | B --> A | PaymentTransaction giữ mã lần giữ ghế; SeatHold không liệt kê giao dịch (tìm bằng IF-19) | hold / transactions | field |
| R-51 | DC-SeatHold | DC-Booking | Association | A 1 - B 0..1 | B --> A | Booking giữ mã lần giữ ghế; SeatHold không cần biết lần đặt | hold / booking | field |
| R-52 | DC-Booking | DC-Ticket | Aggregation | A 1 - B 1..8 | A --> B | Giữ aggregation như P08: vé đã huỷ vẫn thuộc lần đặt | booking / tickets | field |
| R-53 | DC-Ticket | DC-Showtime | Association | A 0..* - B 1 | A --> B | Suy ra được từ R-54 nhưng giữ vì UC-009 so suất chiếu trực tiếp; nhất quán với key của R-54 | tickets / showtime | field |
| R-54 | DC-Ticket | DC-SeatStatus | Association | A 0..* - B 1 | A --> B | Ghế của vé theo key; quan hệ lịch sử, liên kết hiện tại là R-64 | tickets / seatStatus | field |
| R-55 | DC-PaymentTransaction | DC-RefundRequest | Association | A 0..1 - B 0..* | B --> A | RefundRequest giữ mã giao dịch (rỗng với hoàn tiền mặt); giao dịch không liệt kê yêu cầu hoàn | transaction / refunds | field |
| R-56 | DC-Ticket | DC-RefundRequest | Association | A 0..1 - B 0..1 | B --> A | RefundRequest giữ mã vé (rỗng với hoàn toàn bộ) | ticket / refund | field |
| R-60 | DC-Showtime | DC-PriceList | Dependency | - | A --> B | QuoteSeatPrices nhận PriceList qua tham số (Q-117); DC-PriceList đã khoá S ở hạng 1 | - | parameter |
| R-63 | DC-SeatHold | DC-SeatStatus | Association | A 0..1 - B 0..8 | B --> A | Liên kết hiện tại: SeatStatus giữ mã lần giữ ghế (cột current_hold_id); đặt khi HoldFor, xoá khi MarkSold và ReleaseHold | currentHold / heldSeats | field |
| R-64 | DC-Ticket | DC-SeatStatus | Association | A 0..1 - B 0..1 | B --> A | Liên kết hiện tại: SeatStatus giữ mã vé (cột current_ticket_id); đặt khi MarkSold, xoá khi ReleaseTicket | currentTicket / soldSeat | field |
| R-65 | DC-BookTicketsService | IF-08 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-66 | DC-BookTicketsService | IF-11 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-67 | DC-BookTicketsService | IF-12 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-68 | DC-BookTicketsService | IF-13 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-69 | DC-BookTicketsService | IF-16 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-70 | DC-BookTicketsService | IF-17 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-71 | DC-BookTicketsService | IF-18 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-72 | DC-BookTicketsService | IF-19 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-73 | DC-BookTicketsService | IF-20 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-74 | DC-BookTicketsService | IF-24 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-75 | DC-BookTicketsService | IF-01 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-77 | DC-SeatMapService | IF-22 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-78 | DC-SeatMapService | IF-04 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-79 | DC-HoldExpiryJob | IF-08 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-80 | DC-HoldExpiryJob | IF-17 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-81 | DC-HoldExpiryJob | IF-22 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-82 | DC-SeatReleaseJob | IF-08 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-84 | DC-SeatReleaseJob | IF-18 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-85 | DC-PaymentReportService | IF-08 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-86 | DC-PaymentReportService | IF-02 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-87 | DC-PaymentReportService | IF-17 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-88 | DC-PaymentReportService | IF-18 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-89 | DC-PaymentReportService | IF-19 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-90 | DC-PaymentReportService | IF-20 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-91 | DC-PaymentReportService | IF-23 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-92 | DC-PaymentReportService | DC-RefundService | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-93 | DC-RefundService | IF-08 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-94 | DC-RefundService | IF-01 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-95 | DC-RefundService | IF-19 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-97 | DC-RefundService | IF-21 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-98 | DC-RefundService | IF-23 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-99 | DC-RefundOutboxJob | IF-23 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-100 | DC-RefundOutboxJob | DC-RefundService | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-101 | DC-CancelTicketService | IF-08 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-102 | DC-CancelTicketService | IF-11 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-103 | DC-CancelTicketService | IF-18 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-104 | DC-CancelTicketService | IF-20 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-105 | DC-CancelTicketService | IF-21 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-106 | DC-CancelTicketService | DC-RefundService | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-107 | DC-CheckTicketService | IF-08 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-108 | DC-CheckTicketService | IF-11 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-110 | DC-PaymentCallbackController | DC-PaymentReportService | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-111 | DC-HoldExpiryJob | IF-06 | Realization | - | A --> B | Hiện thực interface | - | - |
| R-112 | DC-SeatReleaseJob | IF-06 | Realization | - | A --> B | Hiện thực interface | - | - |
| R-113 | DC-RefundOutboxJob | IF-06 | Realization | - | A --> B | Hiện thực interface | - | - |
| R-114 | DC-PaymentGatewayManager | IF-01 | Realization | - | A --> B | Hiện thực interface | - | - |
| R-115 | DC-PaymentReportReceiver | IF-02 | Realization | - | A --> B | Hiện thực interface | - | - |
| R-116 | DC-PaymentGatewayManager | DC-VnpayUrlBuilder | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-117 | DC-PaymentGatewayManager | DC-VnpayRefundClient | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-118 | DC-PaymentGatewayManager | DC-GatewayConfig | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-119 | DC-VnpayUrlBuilder | DC-VnpaySigner | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-120 | DC-VnpayUrlBuilder | DC-GatewayConfig | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-121 | DC-VnpayRefundClient | DC-VnpaySigner | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-122 | DC-VnpayRefundClient | DC-GatewayConfig | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-123 | DC-PaymentReportReceiver | DC-VnpaySigner | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-124 | DC-PaymentReportReceiver | DC-VnpayReportDecoder | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-125 | DC-VnpaySigner | DC-GatewayConfig | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc (khoá ký) | - | field |
| R-126 | DC-SeatEventHubManager | IF-04 | Realization | - | A --> B | Hiện thực interface | - | - |
| R-127 | DC-SeatEventHubManager | DC-SubscriberRegistry | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-128 | DC-SeatEventHubManager | DC-SeatReplayReader | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-129 | DC-SeatEventHubManager | DC-SeatEventPoller | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-130 | DC-SeatEventPoller | DC-SubscriberRegistry | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-131 | DC-SeatEventPoller | DC-EmittedEventTracker | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-132 | DC-SeatEventPoller | IF-22 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-133 | DC-SeatReplayReader | IF-22 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-134 | DC-SubscriberRegistry | DC-SubscriberQueue | Composition | A 1 - B 0..* | A --> B | Registry tạo và gỡ hàng đợi | queues | field |
| R-135 | DC-JobSchedulerManager | IF-05 | Realization | - | A --> B | Hiện thực interface | - | - |
| R-136 | DC-JobSchedulerManager | DC-JobRegistry | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-137 | DC-JobRegistry | DC-JobLoop | Composition | A 1 - B 0..* | A --> B | Registry giữ và dừng các vòng | loops | field |
| R-138 | DC-JobLoop | IF-06 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | job | field |
| R-139 | DC-PgUnitOfWork | IF-08 | Realization | - | A --> B | Hiện thực interface | - | - |
| R-140 | DC-PgTx | IF-25 | Realization | - | A --> B | Hiện thực interface | - | - |
| R-141 | DC-RandomCodeGenerator | IF-24 | Realization | - | A --> B | Hiện thực interface | - | - |
| R-142 | DC-PgSeatEventStore | IF-22 | Realization | - | A --> B | Hiện thực interface | - | - |
| R-143 | DC-PgOutboxStore | IF-23 | Realization | - | A --> B | Hiện thực interface | - | - |
| R-144 | DC-PgTicketingStore | IF-16 | Realization | - | A --> B | Hiện thực interface | - | - |
| R-145 | DC-PgTicketingStore | IF-17 | Realization | - | A --> B | Hiện thực interface | - | - |
| R-146 | DC-PgTicketingStore | IF-18 | Realization | - | A --> B | Hiện thực interface | - | - |
| R-147 | DC-PgTicketingStore | IF-19 | Realization | - | A --> B | Hiện thực interface | - | - |
| R-148 | DC-PgTicketingStore | IF-20 | Realization | - | A --> B | Hiện thực interface | - | - |
| R-149 | DC-PgTicketingStore | IF-21 | Realization | - | A --> B | Hiện thực interface | - | - |
| R-150 | DC-PgCinemaOperationsStore | IF-11 | Realization | - | A --> B | Hiện thực interface | - | - |
| R-151 | DC-PgCinemaOperationsStore | IF-12 | Realization | - | A --> B | Hiện thực interface | - | - |
| R-152 | DC-PgCinemaOperationsStore | IF-13 | Realization | - | A --> B | Hiện thực interface | - | - |
| R-153 | DC-PgUnitOfWork | DC-ConnectionPools | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-154 | DC-PgTicketingStore | DC-ConnectionPools | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-155 | DC-PgCinemaOperationsStore | DC-ConnectionPools | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-156 | DC-PgSeatEventStore | DC-ConnectionPools | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-157 | DC-PgOutboxStore | DC-ConnectionPools | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-158 | DC-PgTicketingStore | DC-SeatEventWriter | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-159 | DC-PgTx | DC-LockOrderGuard | Composition | A 1 - B 1 | A --> B | Mỗi giao dịch tạo và sở hữu một bộ kiểm, bị huỷ cùng giao dịch | guard | field |
| R-160 | DC-BookTicketsService | DC-Showtime | Dependency | - | A --> B | Nạp qua IF-11 và dùng trong HoldSeats | - | local |
| R-161 | DC-BookTicketsService | DC-SeatStatus | Dependency | - | A --> B | Nạp qua IF-18 và gọi HoldFor | - | local |
| R-162 | DC-BookTicketsService | DC-PaymentTransaction | Dependency | - | A --> B | Tạo giao dịch PENDING trong StartOnlinePayment | - | local |
| R-163 | DC-BookTicketsService | DC-Customer | Dependency | - | A --> B | Gọi CheckNoActiveSeatHold (BR-04) trên người giữ ghế | - | local |
| R-164 | DC-BookTicketsService | DC-BoxOfficeClerk | Dependency | - | A --> B | Gọi CheckNoActiveSeatHold (BR-04) trên người giữ ghế | - | local |
| R-166 | DC-PaymentReportService | DC-SeatStatus | Dependency | - | A --> B | Nạp qua IF-18 và truyền cho DC-HoldSettlement | - | local |
| R-168 | DC-RefundService | DC-RefundRequest | Dependency | - | A --> B | Tạo và điều khiển vòng đời yêu cầu hoàn | - | local |
| R-169 | DC-RefundService | DC-PaymentTransaction | Dependency | - | A --> B | Nạp qua IF-19, kiểm hạn mức | - | local |
| R-170 | DC-CancelTicketService | DC-Ticket | Dependency | - | A --> B | Nạp qua IF-27 và gọi Cancel | - | local |
| R-171 | DC-CancelTicketService | DC-SeatStatus | Dependency | - | A --> B | Nạp qua IF-18 và gọi ReleaseTicket | - | local |
| R-172 | DC-CancelTicketService | DC-Booking | Dependency | - | A --> B | Nạp qua IF-20 và gọi CheckCancellationChannel | - | local |
| R-173 | DC-CancelTicketService | DC-Showtime | Dependency | - | A --> B | Nạp qua IF-11 và kiểm hạn huỷ (BR-18) | - | local |
| R-174 | DC-CheckTicketService | DC-Ticket | Dependency | - | A --> B | Nạp qua IF-27 và gọi Admit | - | local |
| R-175 | DC-CheckTicketService | DC-Showtime | Dependency | - | A --> B | Nạp qua IF-11 và truyền cho Ticket.Admit | - | local |
| R-176 | DC-HoldExpiryJob | DC-SeatHold | Dependency | - | A --> B | Nạp theo lô qua IF-26 và gọi Expire | - | local |
| R-177 | DC-SeatReleaseJob | DC-SeatStatus | Dependency | - | A --> B | Nạp theo lô qua IF-26 và gọi ReleaseHold | - | local |
| R-178 | DC-SeatReleaseJob | DC-SeatHold | Dependency | - | A --> B | Nạp theo lô qua IF-26 | - | local |
| R-179 | DC-CancelTicketService | DC-RefundRequest | Dependency | - | A --> B | Dựng yêu cầu hoàn tiền mặt bằng NewCashRefund trong ConfirmCashRefund | - | local |
| R-180 | DC-PgUnitOfWork | DC-PgTx | Dependency | - | A --> B | Tạo PgTx cho mỗi lần thử của Do | - | local |
| R-181 | DC-PgUnitOfWork | DC-LockOrderGuard | Dependency | - | A --> B | Gắn bộ kiểm thứ tự khoá mới vào PgTx của mỗi lần thử | - | local |
| R-182 | DC-PgTicketingStore | DC-PgTx | Dependency | - | A --> B | Ép Tx (IF-25) về PgTx để dùng pgx.Tx và LockOrderGuard | - | local |
| R-183 | DC-PgCinemaOperationsStore | DC-PgTx | Dependency | - | A --> B | Ép Tx (IF-25) về PgTx để dùng pgx.Tx và LockOrderGuard | - | local |
| R-184 | DC-HoldSettlement | DC-SeatHold | Dependency | - | A --> B | Gọi Expire, Cancel, FailPayment, Complete trong End và Sell | - | local |
| R-185 | DC-HoldSettlement | DC-SeatStatus | Dependency | - | A --> B | Gọi ReleaseHold trong End và MarkSold trong FinishSale | - | local |
| R-186 | DC-HoldSettlement | DC-Booking | Dependency | - | A --> B | Gọi NewBooking trong Sell | - | local |
| R-187 | DC-BookTicketsService | DC-HoldSettlement | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-188 | DC-PaymentReportService | DC-HoldSettlement | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-189 | DC-PgTicketingStore | IF-26 | Realization | - | A --> B | Hiện thực interface | - | - |
| R-190 | DC-PgTicketingStore | IF-27 | Realization | - | A --> B | Hiện thực interface | - | - |
| R-191 | DC-HoldExpiryJob | IF-26 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-192 | DC-SeatReleaseJob | IF-26 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-193 | DC-CancelTicketService | IF-27 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-194 | DC-CheckTicketService | IF-27 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-195 | DC-CancelTicketService | IF-19 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc; lockPaymentOfTicket khoá giao dịch thanh toán của vé | - | field |
| R-196 | DC-CancelTicketService | DC-PaymentTransaction | Dependency | - | A --> B | Nạp qua IF-19 trong lockPaymentOfTicket và truyền cho RequestTicketRefund | - | local |

Quan hệ giữa interface kho và entity cùng package (chữ ký trả về kiểu entity) không tính là quan hệ riêng. Dependency của service tới entity ở package khác (ví dụ DC-BookTicketsService --> DC-Customer) liệt kê ở bảng trên nhưng không vẽ trên class diagram của package chứa control (Bước 6.1).

## F6. State machine

Năm lớp có state machine: SeatHold, SeatStatus, Ticket, RefundRequest, PaymentTransaction. Booking, Customer, BoxOfficeClerk, Showtime: Booking, Customer, BoxOfficeClerk không có trạng thái đáng kể (một trạng thái tính toán); Showtime có vòng đời Trong lịch chiếu, Đã xoá nhưng thuộc UC-014, làm ở lượt PKG-27 (Vấn đề còn mở 9).

### ST-01. Lần giữ ghế (DC-SeatHold)

F6.1. Bảng trạng thái

| ST | Lớp | Trạng thái | Mô tả / điều kiện nhận biết | entry | do | exit |
|---|---|---|---|---|---|---|
| ST-01 | DC-SeatHold | Đang giữ | status = ACTIVE; chưa quá expiryTime thì còn hiệu lực | đặt expiryTime = holdTime + 10 phút | - | - |
| ST-01 | DC-SeatHold | Đã hoàn tất | status = COMPLETED | - | - | - |
| ST-01 | DC-SeatHold | Hết hạn | status = EXPIRED | - | - | - |
| ST-01 | DC-SeatHold | Đã huỷ | status = CANCELLED | - | - | - |
| ST-01 | DC-SeatHold | Thanh toán thất bại | status = PAYMENT_FAILED | - | - | - |

F6.2. Bảng chuyển trạng thái

| ST | Lớp | Trạng thái | Sự kiện | Guard | Hành động | Trạng thái đích | STT | Operation tương ứng (DC.operation) | Nguồn (BR / UC bước) |
|---|---|---|---|---|---|---|---|---|---|
| ST-01 | DC-SeatHold | (initial) | create(holder, showtimeId, requestId, holdRef, now) | [cả nhóm ghế giữ được] | / expiryTime = now + HoldDuration | Đang giữ | 1 | DC-SeatHold.NewSeatHold | BR-07, BR-10; UC-005 EX-01 |
| ST-01 | DC-SeatHold | Đang giữ | complete(now) | [now < expiryTime] | / bán ghế, tạo lần đặt và vé (do DC-PaymentReportService, DC-BookTicketsService điều phối) | Đã hoàn tất | 2 | DC-SeatHold.Complete | BR-37, BR-44, BR-85; UC-005 bước 12 đến 15, 9a |
| ST-01 | DC-SeatHold | Đang giữ | expire(now) | [now >= expiryTime] | - | Hết hạn | 3 | DC-SeatHold.Expire | BR-10, BR-14, BR-85; UC-005 luồng 7b |
| ST-01 | DC-SeatHold | Đang giữ | cancel(now) | [now < expiryTime] | - | Đã huỷ | 4 | DC-SeatHold.Cancel | BR-85; UC-005 luồng *a |
| ST-01 | DC-SeatHold | Đang giữ | failPayment(now) | [now < expiryTime và giao dịch báo thất bại là giao dịch tạo sau cùng của lần giữ ghế] | / trả ghế ngay trong giao dịch (Q-134) | Thanh toán thất bại | 5 | DC-SeatHold.FailPayment | BR-39, BR-85; UC-005 luồng 11a |

Sự kiện bị từ chối hoặc bỏ qua:

| ST | Trạng thái | Sự kiện | Xử lý (bỏ qua / ngoại lệ <tên>) |
|---|---|---|---|
| ST-01 | Đang giữ | complete, cancel, failPayment khi now >= expiryTime | Ném HoldNotActiveError mang status hiện tại (ACTIVE), không đổi; bên gọi (service) luôn gọi Expire(now) trước và lưu nếu đổi (F3), nhờ vậy thao tác đến sau hạn thấy trạng thái Hết hạn và trả HoldNotActiveError(EXPIRED) (BR-85, BR-86) |
| ST-01 | Đã hoàn tất, Hết hạn, Đã huỷ, Thanh toán thất bại | complete, cancel, failPayment | Ném HoldNotActiveError mang status hiện tại; báo thanh toán đến sau xử lý theo trạng thái cuối do DC-PaymentReportService (BR-86) |
| ST-01 | Đang giữ | báo thất bại của giao dịch cũ khi đã có giao dịch mới hơn của lần giữ ghế | Không gọi failPayment; chỉ ghi thất bại vào giao dịch cũ, khách vẫn thanh toán được bằng giao dịch mới |
| ST-01 | Đã hoàn tất, Hết hạn, Đã huỷ, Thanh toán thất bại | expire | Bỏ qua, trả false (chạy lặp an toàn) |
| ST-01 | Đang giữ | expire khi now < expiryTime | Bỏ qua, trả false |

F6.3. Ánh xạ về mô hình lớp

| ST | Thuộc tính biểu diễn trạng thái | Kiểu (enumeration) | Operation được thêm/sửa |
|---|---|---|---|
| ST-01 | status | HoldStatus | NewSeatHold, Expire, Complete, Cancel, FailPayment; thêm IsActiveAt, Status |

F6.4. Sơ đồ state machine. File diagrams/P12-state-SeatHold.drawio. Không vẽ (final): bốn trạng thái cuối không có sự kiện kết thúc vòng đời (lưu trữ, xoá) trong nguồn. Trạng thái cuối không đổi (Q-79, BR-86); các lần giữ ghế cũ được giữ lại để xử lý báo đến sau.

| ID | Loại | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| ST-01-I | Initial |  | - | - | Trạng thái đầu khi đối tượng được tạo |
| ST-01-S1 | State | Đang giữ<br>entry / đặt expiryTime = holdTime + 10 phút | - | - | - |
| ST-01-S2 | State | Đã hoàn tất | - | - | - |
| ST-01-S3 | State | Hết hạn | - | - | - |
| ST-01-S4 | State | Đã huỷ | - | - | - |
| ST-01-S5 | State | Thanh toán thất bại | - | - | - |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn (su_kien [guard] / hanh_dong) | Ghi chú |
|---|---|---|---|---|---|
| ST-01-T1 | ST-01-I | ST-01-S1 | Transition | create(holder, showtimeId, requestId, holdRef, now) [cả nhóm ghế giữ được] / expiryTime = now + HoldDuration | - |
| ST-01-T2 | ST-01-S1 | ST-01-S2 | Transition | complete(now) [now < expiryTime] / bán ghế, tạo lần đặt và vé (do DC-PaymentReportService, DC-BookTicketsService điều phối) | - |
| ST-01-T3 | ST-01-S1 | ST-01-S3 | Transition | expire(now) [now >= expiryTime] | - |
| ST-01-T4 | ST-01-S1 | ST-01-S4 | Transition | cancel(now) [now < expiryTime] | - |
| ST-01-T5 | ST-01-S1 | ST-01-S5 | Transition | failPayment(now) [now < expiryTime, giao dịch báo là giao dịch mới nhất] | - |

### ST-02. Trạng thái ghế (DC-SeatStatus)

F6.1. Bảng trạng thái

| ST | Lớp | Trạng thái | Mô tả / điều kiện nhận biết | entry | do | exit |
|---|---|---|---|---|---|---|
| ST-02 | DC-SeatStatus | Trống | state = AVAILABLE, không có currentHold, không có currentTicket | - | - | - |
| ST-02 | DC-SeatStatus | Đang được giữ | state = HELD, có đúng currentHold | currentHold = holdId; heldPrice = giá đã chốt | - | - |
| ST-02 | DC-SeatStatus | Đã bán | state = SOLD, có đúng currentTicket | currentTicket = ticketId | - | - |

F6.2. Bảng chuyển trạng thái

| ST | Lớp | Trạng thái | Sự kiện | Guard | Hành động | Trạng thái đích | STT | Operation tương ứng (DC.operation) | Nguồn (BR / UC bước) |
|---|---|---|---|---|---|---|---|---|---|
| ST-02 | DC-SeatStatus | (initial) | create(key) | - | - | Trống | 1 | DC-SeatStatus.NewAvailable | UC-014 EX-13 (tạo cùng suất chiếu) |
| ST-02 | DC-SeatStatus | Trống | holdFor(holdId, price) | [state = AVAILABLE] | / currentHold = holdId; heldPrice = price | Đang được giữ | 2 | DC-SeatStatus.HoldFor | BR-07, BR-08, BR-09 |
| ST-02 | DC-SeatStatus | Đang được giữ | markSold(holdId, ticketId) | [currentHold = holdId] | / currentHold = nil; currentTicket = ticketId | Đã bán | 3 | DC-SeatStatus.MarkSold | BR-85; UC-005 |
| ST-02 | DC-SeatStatus | Đang được giữ | releaseHold(holdId) | [currentHold = holdId] | / currentHold = nil; heldPrice = nil | Trống | 4 | DC-SeatStatus.ReleaseHold | REQ-76, BR-10, NFR-07 |
| ST-02 | DC-SeatStatus | Đã bán | releaseTicket(ticketId) | [currentTicket = ticketId] | / currentTicket = nil; heldPrice = nil | Trống | 5 | DC-SeatStatus.ReleaseTicket | BR-42; UC-008 |

Sự kiện bị từ chối hoặc bỏ qua:

| ST | Trạng thái | Sự kiện | Xử lý (bỏ qua / ngoại lệ <tên>) |
|---|---|---|---|
| ST-02 | Đang được giữ, Đã bán | holdFor | Ném SeatUnavailableError(NOT_AVAILABLE) |
| ST-02 | Trống, Đã bán | markSold | Ném LinkMismatchError (không có lần giữ ghế hiện tại) |
| ST-02 | Đang được giữ | markSold khi currentHold khác holdId | Ném LinkMismatchError |
| ST-02 | Đang được giữ | releaseHold khi currentHold khác holdId | Không đổi, trả false (ghế đã được giữ lại cho lần giữ ghế khác, R-63) |
| ST-02 | Trống, Đã bán | releaseHold | Không đổi, trả false (chạy lặp an toàn) |
| ST-02 | Đã bán | releaseTicket khi currentTicket khác ticketId | Không đổi, trả false (ghế đã bán lại bằng vé khác, R-64) |
| ST-02 | Trống, Đang được giữ | releaseTicket | Không đổi, trả false |

F6.3. Ánh xạ về mô hình lớp

| ST | Thuộc tính biểu diễn trạng thái | Kiểu (enumeration) | Operation được thêm/sửa |
|---|---|---|---|
| ST-02 | state | SeatState | NewAvailable, HoldFor, MarkSold, ReleaseHold, ReleaseTicket; thêm State, IsAvailable |
| ST-02 | currentHold, currentTicket | liên kết R-63, R-64 (cột current_hold_id, current_ticket_id) | CurrentHold, CurrentTicket |

F6.4. Sơ đồ state machine. File diagrams/P12-state-SeatStatus.drawio. Không vẽ (final): ghế còn tồn tại suốt đời suất chiếu, không có sự kiện kết thúc vòng đời. Bất biến: state HELD khi và chỉ khi có currentHold; SOLD khi và chỉ khi có currentTicket.

| ID | Loại | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| ST-02-I | Initial |  | - | - | Trạng thái đầu khi đối tượng được tạo |
| ST-02-S1 | State | Trống | - | - | - |
| ST-02-S2 | State | Đang được giữ<br>entry / currentHold = holdId; heldPrice = giá đã chốt | - | - | - |
| ST-02-S3 | State | Đã bán<br>entry / currentTicket = ticketId | - | - | - |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn (su_kien [guard] / hanh_dong) | Ghi chú |
|---|---|---|---|---|---|
| ST-02-T1 | ST-02-I | ST-02-S1 | Transition | create(key) | - |
| ST-02-T2 | ST-02-S1 | ST-02-S2 | Transition | holdFor(holdId, price) [state = AVAILABLE] / currentHold = holdId; heldPrice = price | - |
| ST-02-T3 | ST-02-S2 | ST-02-S3 | Transition | markSold(holdId, ticketId) [currentHold = holdId] / currentHold = nil; currentTicket = ticketId | - |
| ST-02-T4 | ST-02-S2 | ST-02-S1 | Transition | releaseHold(holdId) [currentHold = holdId] / currentHold = nil; heldPrice = nil | - |
| ST-02-T5 | ST-02-S3 | ST-02-S1 | Transition | releaseTicket(ticketId) [currentTicket = ticketId] / currentTicket = nil; heldPrice = nil | - |

### ST-03. Vé (DC-Ticket)

F6.1. Bảng trạng thái

| ST | Lớp | Trạng thái | Mô tả / điều kiện nhận biết | entry | do | exit |
|---|---|---|---|---|---|---|
| ST-03 | DC-Ticket | Chưa sử dụng | status = UNUSED | - | - | - |
| ST-03 | DC-Ticket | Đã sử dụng | status = USED | - | - | - |
| ST-03 | DC-Ticket | Đã huỷ | status = CANCELLED | - | - | - |

F6.2. Bảng chuyển trạng thái

| ST | Lớp | Trạng thái | Sự kiện | Guard | Hành động | Trạng thái đích | STT | Operation tương ứng (DC.operation) | Nguồn (BR / UC bước) |
|---|---|---|---|---|---|---|---|---|---|
| ST-03 | DC-Ticket | (initial) | create(key, price, code) | - | / cùng giao dịch bán ghế | Chưa sử dụng | 1 | DC-HoldSettlement.Sell (qua DC-Booking.NewBooking, newTicket) | BR-67, BR-85; UC-005 |
| ST-03 | DC-Ticket | Chưa sử dụng | admit(showtime, selected, cinemaId) | [đúng cụm rạp và đúng suất chiếu đã chọn] | / trả ADMITTED | Đã sử dụng | 2 | DC-Ticket.Admit | BR-22 đến BR-25, BR-33; UC-009 |
| ST-03 | DC-Ticket | Chưa sử dụng | cancel() | [đã qua kiểm hạn huỷ vé và kênh mua] | - | Đã huỷ | 3 | DC-Ticket.Cancel | BR-21, BR-30; UC-008 |

Sự kiện bị từ chối hoặc bỏ qua:

| ST | Trạng thái | Sự kiện | Xử lý (bỏ qua / ngoại lệ <tên>) |
|---|---|---|---|
| ST-03 | Chưa sử dụng | admit khi sai cụm rạp | Không đổi, trả WRONG_CINEMA |
| ST-03 | Chưa sử dụng | admit khi sai suất chiếu | Không đổi, trả WRONG_SHOWTIME |
| ST-03 | Đã sử dụng | admit | Không đổi, trả ALREADY_USED |
| ST-03 | Đã huỷ | admit | Không đổi, trả CANCELLED |
| ST-03 | Đã sử dụng, Đã huỷ | cancel | Ném TicketStateError mang status (kiểm đã huỷ trước, đã sử dụng sau) |

F6.3. Ánh xạ về mô hình lớp

| ST | Thuộc tính biểu diễn trạng thái | Kiểu (enumeration) | Operation được thêm/sửa |
|---|---|---|---|
| ST-03 | status | TicketStatus | newTicket, Admit, Cancel; thêm Status, IsCancelled |

F6.4. Sơ đồ state machine. File diagrams/P12-state-Ticket.drawio. Không vẽ (final): vé đã sử dụng và vé đã huỷ vẫn được giữ cho hiển thị, báo cáo và hoàn tiền, không có sự kiện lưu trữ trong nguồn. Hai trạng thái cuối loại trừ nhau.

| ID | Loại | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| ST-03-I | Initial |  | - | - | Trạng thái đầu khi đối tượng được tạo |
| ST-03-S1 | State | Chưa sử dụng | - | - | - |
| ST-03-S2 | State | Đã sử dụng | - | - | - |
| ST-03-S3 | State | Đã huỷ | - | - | - |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn (su_kien [guard] / hanh_dong) | Ghi chú |
|---|---|---|---|---|---|
| ST-03-T1 | ST-03-I | ST-03-S1 | Transition | create(key, price, code) / cùng giao dịch bán ghế | - |
| ST-03-T2 | ST-03-S1 | ST-03-S2 | Transition | admit(showtime, selected, cinemaId) [đúng cụm rạp và đúng suất chiếu đã chọn] / trả ADMITTED | - |
| ST-03-T3 | ST-03-S1 | ST-03-S3 | Transition | cancel() [đã qua kiểm hạn huỷ vé và kênh mua] | Hạn huỷ do Showtime.CheckCancellationDeadline, kênh mua do Booking.CheckCancellationChannel kiểm trước khi gọi Cancel (P08 F4c) |

### ST-04. Yêu cầu hoàn tiền (DC-RefundRequest)

F6.1. Bảng trạng thái

| ST | Lớp | Trạng thái | Mô tả / điều kiện nhận biết | entry | do | exit |
|---|---|---|---|---|---|---|
| ST-04 | DC-RefundRequest | Mới | status = NEW | - | - | - |
| ST-04 | DC-RefundRequest | Đang chờ kết quả | status = IN_FLIGHT; vào lại chính trạng thái này khi nhận lại claim sau khi tiến trình chết | attemptCount++ | chờ cổng tối đa 30 giây (ngoài giao dịch CSDL) | - |
| ST-04 | DC-RefundRequest | Chờ gửi lại | status = WAITING_RETRY | - | hẹn lại sau 1, 5, 15 phút (hàng đợi gửi) | - |
| ST-04 | DC-RefundRequest | Đã hoàn | status = REFUNDED | - | - | - |
| ST-04 | DC-RefundRequest | Cần xử lý thủ công | status = MANUAL_REQUIRED | ghi log lỗi khoản hoàn | - | - |

F6.2. Bảng chuyển trạng thái

| ST | Lớp | Trạng thái | Sự kiện | Guard | Hành động | Trạng thái đích | STT | Operation tương ứng (DC.operation) | Nguồn (BR / UC bước) |
|---|---|---|---|---|---|---|---|---|---|
| ST-04 | DC-RefundRequest | (initial) | create(requestType, amount) | - | - | (choice C1) | 1 | DC-RefundRequest.NewFullRefund, NewTicketRefund, NewCashRefund | BR-26, BR-43, BR-20 |
| ST-04 | DC-RefundRequest | (choice C1) | - | [requestType = TICKET_CASH] | - | Đã hoàn | 2 | DC-RefundRequest.NewCashRefund | BR-20; UC-008 5a2 |
| ST-04 | DC-RefundRequest | (choice C1) | - | [else] | - | Mới | 3 | DC-RefundRequest.NewFullRefund, NewTicketRefund | BR-43 |
| ST-04 | DC-RefundRequest | Mới | beginAttempt() | - | - | Đang chờ kết quả | 4 | DC-RefundRequest.BeginAttempt | BR-43 |
| ST-04 | DC-RefundRequest | Chờ gửi lại | beginAttempt() | - | - | Đang chờ kết quả | 5 | DC-RefundRequest.BeginAttempt | BR-41, Q-118 |
| ST-04 | DC-RefundRequest | Đang chờ kết quả | beginAttempt() | [claim cũ hết hạn được nhận lại sau khi tiến trình chết, attemptCount < MaxAttempts; bên gọi giữ claim_token hợp lệ tại giao dịch 1] | / attemptCount++; bắt buộc findRefund trước khi gửi lại | Đang chờ kết quả | 6 | DC-RefundRequest.BeginAttempt | Q-118, P09 F7.7 |
| ST-04 | DC-RefundRequest | Đang chờ kết quả | recordResult(SUCCEEDED) | - | / xếp email hoàn tiền nếu requestType = FULL (trong cùng giao dịch ghi kết quả) | Đã hoàn | 7 | DC-RefundRequest.RecordResult | BR-43, BR-41 |
| ST-04 | DC-RefundRequest | Đang chờ kết quả | recordResult(REJECTED hoặc UNKNOWN) | [attemptCount < MaxAttempts] | / hẹn lại | Chờ gửi lại | 8 | DC-RefundRequest.RecordResult | BR-41 |
| ST-04 | DC-RefundRequest | Đang chờ kết quả | recordResult(REJECTED hoặc UNKNOWN) | [attemptCount >= MaxAttempts] | / ghi log lỗi | Cần xử lý thủ công | 9 | DC-RefundRequest.RecordResult | BR-41 |
| ST-04 | DC-RefundRequest | Đang chờ kết quả | markManualRequired(reason) | [findRefund trả NOT_SUPPORTED hoặc UNREACHABLE, hoặc nhận lại claim khi attemptCount >= MaxAttempts] | / ghi log lỗi | Cần xử lý thủ công | 10 | DC-RefundRequest.MarkManualRequired | Q-118, Q-127, BR-41 |

Sự kiện bị từ chối hoặc bỏ qua:

| ST | Trạng thái | Sự kiện | Xử lý (bỏ qua / ngoại lệ <tên>) |
|---|---|---|---|
| ST-04 | Mới | recordResult, markManualRequired | Ném RefundStateError (chưa gửi lần nào) |
| ST-04 | Đang chờ kết quả | beginAttempt khi attemptCount >= MaxAttempts | Ném RefundStateError (BeginAttempt chỉ kiểm trạng thái và lượt còn; hết lượt thì bên gọi gọi markManualRequired) |
| ST-04 | Đang chờ kết quả | gửi song song khi claim còn hiệu lực | Không thuộc DC-RefundRequest.BeginAttempt: DC-RefundService.ProcessRefund giao dịch 1 gọi IF-23.ExtendClaim có điều kiện claim_token, 0 dòng thì ClaimLostError, rollback, không gọi cổng (mỗi dòng hàng đợi một claim) |
| ST-04 | Chờ gửi lại | recordResult, markManualRequired | Ném RefundStateError (tra cứu chỉ chạy sau beginAttempt nên markManualRequired chỉ xảy ra ở Đang chờ kết quả) |
| ST-04 | Đã hoàn, Cần xử lý thủ công | beginAttempt, recordResult, markManualRequired | Ném RefundStateError |

F6.3. Ánh xạ về mô hình lớp

| ST | Thuộc tính biểu diễn trạng thái | Kiểu (enumeration) | Operation được thêm/sửa |
|---|---|---|---|
| ST-04 | status | RefundStatus | NewFullRefund, NewTicketRefund, NewCashRefund, BeginAttempt, RecordResult, MarkManualRequired; thêm Status, HasAttemptsRemaining |
| ST-04 | attemptCount | int | BeginAttempt, AttemptCount |

F6.4. Sơ đồ state machine. File diagrams/P12-state-RefundRequest.drawio. Không vẽ (final): Đã hoàn và Cần xử lý thủ công là trạng thái cuối, không có sự kiện kết thúc vòng đời trong nguồn. Hoàn tiền lỗi được xử lý thủ công ngoài hệ thống, không có use case đặt lại về chờ (Q-135, BR-41); khi vào Cần xử lý thủ công, sau commit ghi một dòng log có mã yêu cầu hoàn, mã giao dịch và số tiền để người vận hành đối chiếu.

| ID | Loại | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| ST-04-I | Initial |  | - | - | Trạng thái đầu khi đối tượng được tạo |
| ST-04-S1 | State | Mới | - | - | - |
| ST-04-S2 | State | Đang chờ kết quả<br>entry / attemptCount++<br>do / chờ cổng tối đa 30 giây (ngoài giao dịch CSDL) | - | - | - |
| ST-04-S3 | State | Chờ gửi lại<br>do / hẹn lại sau 1, 5, 15 phút (hàng đợi gửi) | - | - | - |
| ST-04-S4 | State | Đã hoàn | - | - | - |
| ST-04-S5 | State | Cần xử lý thủ công<br>entry / ghi log lỗi khoản hoàn | - | - | - |
| ST-04-C1 | Choice | requestType = TICKET_CASH? | - | - | Hai nhánh loại trừ, có else |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn (su_kien [guard] / hanh_dong) | Ghi chú |
|---|---|---|---|---|---|
| ST-04-T1 | ST-04-I | ST-04-C1 | Transition | create(requestType, amount) | - |
| ST-04-T2 | ST-04-C1 | ST-04-S4 | Transition | [requestType = TICKET_CASH] | - |
| ST-04-T3 | ST-04-C1 | ST-04-S1 | Transition | [else] | - |
| ST-04-T4 | ST-04-S1 | ST-04-S2 | Transition | beginAttempt() | - |
| ST-04-T5 | ST-04-S3 | ST-04-S2 | Transition | beginAttempt() | - |
| ST-04-T6 | ST-04-S2 | ST-04-S2 | Transition | beginAttempt() [claim cũ hết hạn được nhận lại, attemptCount < MaxAttempts; bên gọi giữ claim_token hợp lệ tại giao dịch 1] / findRefund trước khi gửi lại | Chuyển trạng thái tự thân |
| ST-04-T7 | ST-04-S2 | ST-04-S4 | Transition | recordResult(SUCCEEDED) / xếp email hoàn tiền nếu requestType = FULL (trong cùng giao dịch ghi kết quả) | - |
| ST-04-T8 | ST-04-S2 | ST-04-S3 | Transition | recordResult(REJECTED hoặc UNKNOWN) [attemptCount < MaxAttempts] / hẹn lại | - |
| ST-04-T9 | ST-04-S2 | ST-04-S5 | Transition | recordResult(REJECTED hoặc UNKNOWN) [attemptCount >= MaxAttempts] / ghi log lỗi | - |
| ST-04-T10 | ST-04-S2 | ST-04-S5 | Transition | markManualRequired(reason) [findRefund trả NOT_SUPPORTED hoặc UNREACHABLE, hoặc nhận lại claim khi attemptCount >= MaxAttempts] / ghi log lỗi | - |

### ST-05. Giao dịch thanh toán (DC-PaymentTransaction)

F6.1. Bảng trạng thái

| ST | Lớp | Trạng thái | Mô tả / điều kiện nhận biết | entry | do | exit |
|---|---|---|---|---|---|---|
| ST-05 | DC-PaymentTransaction | Chưa xử lý | status = PENDING | - | - | - |
| ST-05 | DC-PaymentTransaction | Đã ghi nhận thất bại | status = FAILED | - | - | - |
| ST-05 | DC-PaymentTransaction | Đã tạo vé | status = TICKETED | - | - | - |
| ST-05 | DC-PaymentTransaction | Đã ghi nhận thanh toán trễ | status = LATE_PAYMENT | ghi lateReason | - | - |

F6.2. Bảng chuyển trạng thái

| ST | Lớp | Trạng thái | Sự kiện | Guard | Hành động | Trạng thái đích | STT | Operation tương ứng (DC.operation) | Nguồn (BR / UC bước) |
|---|---|---|---|---|---|---|---|---|---|
| ST-05 | DC-PaymentTransaction | (initial) | create(hold, code, amount) | - | / số tiền ghi lúc tạo | Chưa xử lý | 1 | DC-PaymentTransaction.NewPending | REQ-111; UC-005 bước 10 |
| ST-05 | DC-PaymentTransaction | Chưa xử lý | reportSuccess(gatewayNo, paidAt) | [lần giữ ghế Đang giữ và now < expiryTime] | / bán ghế, tạo vé | Đã tạo vé | 2 | DC-PaymentTransaction.MarkTicketed | BR-37; UC-005 bước 12 |
| ST-05 | DC-PaymentTransaction | Chưa xử lý | reportSuccess(gatewayNo, paidAt) | [lần giữ ghế không còn hiệu lực] | / tạo yêu cầu hoàn toàn bộ | Đã ghi nhận thanh toán trễ | 3 | DC-PaymentTransaction.MarkLatePayment | BR-14, BR-15, BR-40; UC-006 |
| ST-05 | DC-PaymentTransaction | Chưa xử lý | reportFailure() | - | / ghi nhận | Đã ghi nhận thất bại | 4 | DC-PaymentTransaction.RecordFailure | BR-39; UC-005 luồng 11a |
| ST-05 | DC-PaymentTransaction | Đã ghi nhận thất bại | reportSuccess(gatewayNo, paidAt) | - | / tạo yêu cầu hoàn toàn bộ | Đã ghi nhận thanh toán trễ | 5 | DC-PaymentTransaction.MarkLatePayment | BR-15 |
| ST-05 | DC-PaymentTransaction | Đã tạo vé | reportSuccess(gatewayNo, paidAt) | - | / duplicateReportCount++ | Đã tạo vé | 6 | DC-PaymentTransaction.RecordDuplicate | BR-37 |
| ST-05 | DC-PaymentTransaction | Đã ghi nhận thanh toán trễ | reportSuccess(gatewayNo, paidAt) | - | / duplicateReportCount++ | Đã ghi nhận thanh toán trễ | 7 | DC-PaymentTransaction.RecordDuplicate | BR-37 |

Sự kiện bị từ chối hoặc bỏ qua:

| ST | Trạng thái | Sự kiện | Xử lý (bỏ qua / ngoại lệ <tên>) |
|---|---|---|---|
| ST-05 | Đã ghi nhận thất bại | reportFailure | Không đổi, trả false (chỉ ghi nhận) |
| ST-05 | Đã tạo vé, Đã ghi nhận thanh toán trễ | reportFailure | Không đổi, trả false (BR-39: không hoàn tiền) |
| ST-05 | Đã tạo vé | markLatePayment | Ném PaymentStateError (báo thành công đến sau là báo trùng) |
| ST-05 | Đã tạo vé, Đã ghi nhận thanh toán trễ | markTicketed | Ném PaymentStateError |
| ST-05 | Chưa xử lý, Đã ghi nhận thất bại | recordDuplicate | Ném PaymentStateError |

F6.3. Ánh xạ về mô hình lớp

| ST | Thuộc tính biểu diễn trạng thái | Kiểu (enumeration) | Operation được thêm/sửa |
|---|---|---|---|
| ST-05 | status | PaymentStatus | NewPending, MarkTicketed, MarkLatePayment, RecordFailure, RecordDuplicate; thêm IsProcessed, Status |
| ST-05 | refundedTotal | Money | CheckRefundWithin, RecordRefunded (không đổi status) |

F6.4. Sơ đồ state machine. File diagrams/P12-state-PaymentTransaction.drawio. Không vẽ (final): giao dịch được giữ để đối soát và hoàn tiền; Đã tạo vé và Đã ghi nhận thanh toán trễ chỉ nhận báo trùng. Gộp hai thuộc tính processed và result của P08 thành status vì Chưa xử lý cùng Thất bại là trạng thái riêng chấp nhận được (P08 F4c).

| ID | Loại | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| ST-05-I | Initial |  | - | - | Trạng thái đầu khi đối tượng được tạo |
| ST-05-S1 | State | Chưa xử lý | - | - | - |
| ST-05-S2 | State | Đã ghi nhận thất bại | - | - | - |
| ST-05-S3 | State | Đã tạo vé | - | - | - |
| ST-05-S4 | State | Đã ghi nhận thanh toán trễ<br>entry / ghi lateReason | - | - | - |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn (su_kien [guard] / hanh_dong) | Ghi chú |
|---|---|---|---|---|---|
| ST-05-T1 | ST-05-I | ST-05-S1 | Transition | create(hold, code, amount) / số tiền ghi lúc tạo | - |
| ST-05-T2 | ST-05-S1 | ST-05-S3 | Transition | reportSuccess(gatewayNo, paidAt) [lần giữ ghế Đang giữ và now < expiryTime] / bán ghế, tạo vé | - |
| ST-05-T3 | ST-05-S1 | ST-05-S4 | Transition | reportSuccess(gatewayNo, paidAt) [lần giữ ghế không còn hiệu lực] / tạo yêu cầu hoàn toàn bộ | - |
| ST-05-T4 | ST-05-S1 | ST-05-S2 | Transition | reportFailure() / ghi nhận | - |
| ST-05-T5 | ST-05-S2 | ST-05-S4 | Transition | reportSuccess(gatewayNo, paidAt) / tạo yêu cầu hoàn toàn bộ | - |
| ST-05-T6 | ST-05-S3 | ST-05-S3 | Transition | reportSuccess(gatewayNo, paidAt) / duplicateReportCount++ | - |
| ST-05-T7 | ST-05-S4 | ST-05-S4 | Transition | reportSuccess(gatewayNo, paidAt) / duplicateReportCount++ | - |

## F7. Bảng thuộc tính

Thuộc tính Classifier (hằng) ghi Phạm vi Classifier. Thuộc tính định danh ghi ràng buộc id; "gán khi lưu" nghĩa là CSDL cấp khi INSERT, multiplicity vẫn là 1. Thuộc tính trỏ tới lớp khác là association (F5) nên không lặp lại ở đây, trừ SeatKey (định danh ghép của SeatStatus).

| DC | Visibility | Tên | Kiểu | Multiplicity | Mặc định | Ràng buộc | Phạm vi | Derived (Có: công thức / Không) | Nguồn (AC / BR / ST / method) | Mô tả |
|---|---|---|---|---|---|---|---|---|---|---|
| DC-SeatHold | - | id | SeatHoldId | 1 | - | {id} | Instance | Không | P12 | Định danh, gán khi lưu; thứ tự khoá hạng 5 |
| DC-SeatHold | - | holdRef | string | 1 | - | {unique} | Instance | Không | AC-E-SeatHold | Mã tham chiếu lần giữ ghế (REQ-136), UUID v4 |
| DC-SeatHold | - | requestId | string | 1 | - | {unique} | Instance | Không | P09 F7.3 EX-01 | Mã yêu cầu do trình duyệt sinh, làm xác nhận lặp an toàn |
| DC-SeatHold | - | status | HoldStatus | 1 | ACTIVE | - | Instance | Không | AC-E-SeatHold, ST-01 | Trạng thái vòng đời |
| DC-SeatHold | - | holdTime | time.Time | 1 | - | {readOnly} | Instance | Không | AC-E-SeatHold | Thời điểm giữ thành công |
| DC-SeatHold | - | expiryTime | time.Time | 1 | - | {readOnly} | Instance | Không | BR-10 | holdTime + 10 phút |
| DC-SeatHold | + | HoldDuration | time.Duration | 1 | 10 * time.Minute | {readOnly} | Classifier | Không | BR-10 | Thời hạn giữ ghế |
| DC-SeatStatus | - | key | SeatKey | 1 | - | {id} | Instance | Không | R-44, R-45 | Định danh ghép (suất chiếu, ghế), cũng là khoá khoá hạng 6 |
| DC-SeatStatus | - | state | SeatState | 1 | AVAILABLE | - | Instance | Không | AC-E-SeatStatus, ST-02 | Khớp liên kết hiện tại |
| DC-SeatStatus | - | heldPrice | Money | 0..1 | - | có khi HELD hoặc SOLD | Instance | Không | AC-E-SeatStatus | Giá vé đã chốt (BR-65) |
| DC-PaymentTransaction | - | id | PaymentTransactionId | 1 | - | {id} | Instance | Không | P12 | Định danh, gán khi lưu; khoá hạng 7 |
| DC-PaymentTransaction | - | code | string | 1 | - | {unique} | Instance | Không | AC-E-PaymentTransaction | Mã giao dịch do hệ thống sinh, gửi cổng làm mã tham chiếu |
| DC-PaymentTransaction | - | amount | Money | 1 | - | {> 0} | Instance | Không | AC-E-PaymentTransaction | Số tiền chốt của lần giữ ghế |
| DC-PaymentTransaction | - | status | PaymentStatus | 1 | PENDING | - | Instance | Không | AC-E-PaymentTransaction, ST-05 | Trạng thái xử lý |
| DC-PaymentTransaction | - | gatewayTransactionNo | string | 0..1 | - | - | Instance | Không | P11b IF-02 | Mã giao dịch do cổng cấp, lưu khi báo thành công |
| DC-PaymentTransaction | - | paidAt | time.Time | 0..1 | - | - | Instance | Không | P11b IF-01 requestRefund | Thời điểm thanh toán thành công (cổng cần khi hoàn) |
| DC-PaymentTransaction | - | lateReason | string | 0..1 | - | - | Instance | Không | AC-E-PaymentTransaction | Lý do hoàn của thanh toán trễ |
| DC-PaymentTransaction | - | refundedTotal | Money | 1 | 0 | {<= amount} | Instance | Không | BR-26 | Tổng đã hoàn |
| DC-PaymentTransaction | - | duplicateReportCount | int | 1 | 0 | {>= 0} | Instance | Không | BR-37 | Số lần báo trùng |
| DC-RefundRequest | - | id | RefundRequestId | 1 | - | {id} | Instance | Không | P12 | Định danh, gán khi lưu; khoá hạng 9 |
| DC-RefundRequest | - | idempotencyKey | string | 1 | - | {unique} | Instance | Không | BR-43 | Khoá chống hoàn trùng, không đổi qua các lần thử |
| DC-RefundRequest | - | requestType | RefundType | 1 | - | - | Instance | Không | AC-E-RefundRequest | Hoàn toàn bộ, một vé qua cổng, một vé bằng tiền mặt |
| DC-RefundRequest | - | refundAmount | Money | 1 | - | {> 0} | Instance | Không | AC-E-RefundRequest | Số tiền hoàn |
| DC-RefundRequest | - | attemptCount | int | 1 | 0 | {0..4} | Instance | Không | BR-41, P09 F7.7 | Số lần đã gửi |
| DC-RefundRequest | - | status | RefundStatus | 1 | NEW | - | Instance | Không | AC-E-RefundRequest, ST-04 | Trạng thái xử lý |
| DC-RefundRequest | - | refundResult | string | 0..1 | - | - | Instance | Không | AC-E-RefundRequest | Mã kết quả hoặc lý do lỗi của lần gửi cuối |
| DC-RefundRequest | + | MaxAttempts | int | 1 | 4 | {readOnly} | Classifier | Không | P09 F7.7 | Một lần đầu cộng 3 lần thử lại |
| DC-Booking | - | id | BookingId | 1 | - | {id} | Instance | Không | P12 | Định danh, gán khi lưu |
| DC-Booking | - | bookingCode | string | 1 | - | {unique} | Instance | Không | BR-80 | Mã đặt vé duy nhất toàn hệ thống |
| DC-Booking | - | /channel | HolderKind | 1 | - | {readOnly} | Instance | Có: kind của người giữ ghế | BR-17 | Kênh mua suy từ người giữ ghế của lần giữ ghế R-51 |
| DC-Booking | - | /buyerId | int64 | 1 | - | {readOnly} | Instance | Có: id của người giữ ghế | BR-17 | Mã người mua suy từ người giữ ghế |
| DC-Ticket | - | id | TicketId | 1 | - | {id} | Instance | Không | P12 | Định danh, gán khi lưu; khoá hạng 8 |
| DC-Ticket | - | ticketCode | string | 1 | - | {unique} | Instance | Không | AC-E-Ticket, NFR-14 | Mã vé và nội dung mã QR |
| DC-Ticket | - | price | Money | 1 | - | {> 0} | Instance | Không | BR-67 | Giá vé đã chốt |
| DC-Ticket | - | status | TicketStatus | 1 | UNUSED | - | Instance | Không | AC-E-Ticket, ST-03 | Trạng thái vé |
| DC-Ticket | + | RefundPercent | int | 1 | 70 | {readOnly} | Classifier | Không | BR-19 | Phần trăm hoàn khi huỷ vé |
| DC-Customer | - | id | CustomerId | 1 | - | {id} | Instance | Không | P12 | Định danh |
| DC-Customer | - | email | string | 1 | - | {unique, <= 254} | Instance | Không | AC-E-Customer | Email đăng nhập (Thiết kế: 254 ký tự theo RFC 5321) |
| DC-Customer | - | phoneNumber | string | 1 | - | {unique} | Instance | Không | AC-E-Customer | Số điện thoại 10 chữ số (REQ-108) |
| DC-Customer | - | passwordHash | string | 1 | - | - | Instance | Không | NFR-02 | Mã băm một chiều của mật khẩu (thay thuộc tính password) |
| DC-BoxOfficeClerk | - | id | BoxOfficeClerkId | 1 | - | {id} | Instance | Không | P12 | Định danh |
| DC-Showtime | - | id | ShowtimeId | 1 | - | {id} | Instance | Không | P12 | Định danh, gán khi lưu |
| DC-Showtime | - | startTime | time.Time | 1 | - | - | Instance | Không | AC-E-Showtime | Giờ bắt đầu |
| DC-Showtime | - | saleOpenTime | time.Time | 1 | - | - | Instance | Không | AC-E-Showtime | Thời điểm mở bán (BR-01) |
| DC-Showtime | - | endTime | time.Time | 1 | - | - | Instance | Không | AC-E-Showtime | Giờ kết thúc |
| DC-Showtime | - | lastChangedAt | time.Time | 1 | - | - | Instance | Không | AC-E-Showtime | Mốc thay đổi, so ở BR-54 |
| DC-Showtime | - | movieFormat | string | 1 | - | - | Instance | Không | AC-E-Showtime | Định dạng phim |
| DC-Showtime | - | status | ShowtimeStatus | 1 | IN_SCHEDULE | - | Instance | Không | AC-E-Showtime | Trong lịch chiếu hoặc Đã xoá (BR-58) |
| DC-Showtime | - | /cinemaId | CinemaId | 1 | - | {readOnly} | Instance | Có: cinemaId của Auditorium (R-42, R-38) | P12 | Cụm rạp của phòng chiếu, nạp bằng join, không lưu |
| DC-PriceList | - | cinemaId | CinemaId | 1 | - | {id} | Instance | Không | P12 | Mỗi cụm rạp một bảng giá (R-40), cũng là khoá khoá hạng 1 |
| DC-PriceList | - | entries | PriceEntry | 0..72 | - | - | Instance | Không | AC-E-PriceList | Mục giá (R-41 composition), cùng kiểu mục ở lượt PKG-27 |
| DC-Showtime | + | MaxSeatsPerHold | int | 1 | 8 | {readOnly} | Classifier | Không | BR-05, Q-140 | Số ghế tối đa mỗi lần giữ ghế; hằng cố định, một nơi định nghĩa: HoldSeats đếm nhanh ở bước 1 và CheckSeatSelection dùng cùng hằng này |
| DC-HoldExpiryJob | - | batchSize | int | 1 | 200 | {readOnly} | Classifier | Không | P09 F7.4 | Thiết kế: kích thước lô |
| DC-HoldExpiryJob | - | eventRetention | time.Duration | 1 | 10 * time.Minute | {readOnly} | Classifier | Không | P09 F7.5 điểm 6 | Thiết kế: thời gian giữ seat_event |
| DC-SeatReleaseJob | - | batchSize | int | 1 | 200 | {readOnly} | Classifier | Không | P09 F7.4 | Thiết kế: kích thước lô |
| DC-RefundService | - | retryDelays | []time.Duration | 3 | 1m, 5m, 15m | {readOnly} | Classifier | Không | P09 F7.7 | Thiết kế: khoảng cách giữa các lần thử lại |
| DC-RefundOutboxJob | - | claimLimit | int | 1 | 1 | {readOnly} | Classifier | Không | P09 F7.7 | Thiết kế: số dòng nhận mỗi lần claim (mỗi luồng một dòng, claim ngay trước khi xử lý) |
| DC-RefundOutboxJob | - | workers | int | 1 | 5 | {readOnly} | Classifier | Không | P09 F7.7 | Thiết kế: số luồng xử lý song song |
| DC-PaymentCallbackController | - | resultPageUrl | string | 1 | - | - | Instance | Không | Q-126 | Địa chỉ trang kết quả của SPA, đọc từ cấu hình |
| DC-PgUnitOfWork | - | maxRetries | int | 1 | 2 | {readOnly} | Classifier | Không | P09 F7.3 | Thiết kế: số lần thử lại với 40P01 và 55P03 |
| DC-PgUnitOfWork | - | retryBackoff | time.Duration | 1 | 20 * time.Millisecond | {readOnly} | Classifier | Không | P09 F7.3 | Thiết kế: chờ ngắn nhân với số lần thử để hai bên lệch pha |
| DC-PgTx | - | raw | pgx.Tx | 1 | - | - | Instance | Không | Thiết kế | Giao dịch của thư viện pgx |
| DC-PgTx | - | now | time.Time | 0..1 | - | - | Instance | Không | P09 F7.2 | Thời điểm CSDL, lấy một lần |
| DC-LockOrderGuard | - | maxRank | LockRank | 1 | 0 | - | Instance | Không | P10 F3a | Hạng lớn nhất đã lấy |
| DC-LockOrderGuard | - | maxKey | LockKey | 1 | - | - | Instance | Không | P10 F3a | Mã lớn nhất đã lấy ở hạng maxRank |
| DC-LockOrderGuard | - | violated | bool | 1 | false | - | Instance | Không | P10 F3a | Đã có vi phạm; giao dịch phải rollback |
| DC-ConnectionPools | - | userPool | pgxpool.Pool | 1 | - | {size = 20} | Instance | Không | P09 F7.3 | Thiết kế: 20 kết nối mỗi bản backend |
| DC-ConnectionPools | - | backgroundPool | pgxpool.Pool | 1 | - | {size = 5} | Instance | Không | P09 F7.4 | Thiết kế: 5 kết nối cho công việc nền |
| DC-PgOutboxStore | - | claimWindow | time.Duration | 1 | 120 * time.Second | {readOnly} | Classifier | Không | P09 F7.7 | Thiết kế: thời hạn claim |
| DC-VnpayUrlBuilder | - | now | func() time.Time | 1 | time.Now | - | Instance | Không | Bước 2.6 | Đồng hồ cho vnp_CreateDate |
| DC-VnpayRefundClient | - | httpClient | http.Client | 1 | - | {timeout = 30s} | Instance | Không | BR-43, NFR-17 | Thời gian chờ 30 giây |
| DC-VnpayRefundClient | - | now | func() time.Time | 1 | time.Now | - | Instance | Không | Bước 2.6 | Đồng hồ cho vnp_CreateDate |
| DC-GatewayConfig | - | merchantCode | string | 1 | - | - | Instance | Không | P11b SS-01 F5 | Mã đơn vị |
| DC-GatewayConfig | - | hashSecret | string | 1 | - | {secret} | Instance | Không | P11b SS-01 F5 | Khoá ký |
| DC-GatewayConfig | - | paymentPageUrl | string | 1 | - | - | Instance | Không | P11b SS-01 F5 | Địa chỉ trang thanh toán |
| DC-GatewayConfig | - | apiUrl | string | 1 | - | - | Instance | Không | P11b SS-01 F5 | Địa chỉ API hoàn và tra cứu |
| DC-GatewayConfig | - | returnUrl | string | 1 | - | - | Instance | Không | P11b SS-01 F5 | Địa chỉ trả về |
| DC-GatewayConfig | - | supportsRefundLookup | bool | 1 | false | - | Instance | Không | Q-132 | Cổng có tra cứu hoàn |
| DC-SeatEventPoller | - | period | time.Duration | 1 | 500 * time.Millisecond | {readOnly} | Classifier | Không | P09 F7.5 điểm 3 | Thiết kế: chu kỳ đọc |
| DC-SeatEventPoller | - | now | func() time.Time | 1 | time.Now | - | Instance | Không | Bước 2.6 | Đồng hồ cho cửa sổ chồng |
| DC-SeatReplayReader | - | overlap | time.Duration | 1 | 10 * time.Second | {readOnly} | Classifier | Không | P09 F7.5 điểm 4 | Thiết kế: cửa sổ chồng, lớn hơn maxDuration cộng thời gian chờ kết nối |
| DC-SubscriberRegistry | - | byShowtime | map[ShowtimeId]map[string]SubscriberQueue | 1 | - | - | Instance | Không | P11b SS-03 F5 | Hàng đợi theo suất chiếu và mã đăng ký |
| DC-SubscriberQueue | - | items | chan SeatStreamItem | 1 | - | {cap = 256} | Instance | Không | P09 F7.5 | Thiết kế: hàng đợi 256 sự kiện mỗi kết nối |
| DC-SubscriberQueue | - | closed | bool | 1 | false | - | Instance | Không | P11b SS-03 F5 | Đã đóng |
| DC-EmittedEventTracker | - | emitted | map[EventId]time.Time | 1 | - | - | Instance | Không | P09 F7.5 điểm 3 | Mã đã phát và lúc phát |
| DC-EmittedEventTracker | - | mark | EventId | 1 | 0 | - | Instance | Không | P09 F7.5 điểm 3 | Mốc W: mã lớn nhất trong dòng đã phát cũ hơn 10 giây |
| DC-JobSchedulerManager | - | started | bool | 1 | false | - | Instance | Không | P11b SS-04 F5 | Đã Start |
| DC-JobRegistry | - | jobs | map[string]ScheduledJob | 1 | - | - | Instance | Không | P11b SS-04 F5 | Công việc theo tên |
| DC-JobLoop | - | running | atomic.Bool | 1 | false | - | Instance | Không | P09 F7.4 | Cờ đang chạy: bỏ chu kỳ nếu lượt trước chưa xong |
| DC-JobLoop | - | budget | time.Duration | 1 | 8 * time.Second | {readOnly} | Classifier | Không | P09 F7.4 | Thiết kế: ngân sách mỗi lượt |
| DC-JobLoop | - | after | func(time.Duration) <-chan time.Time | 1 | time.After | - | Instance | Không | Bước 2.6 | Hàm chờ chu kỳ (đồng hồ đơn điệu) |

Không có lớp nào ngoài phạm vi các lớp trên cần thuộc tính. Lớp chỉ hiện thực interface (DC-PgSeatEventStore) và lớp không giữ trạng thái không có thuộc tính; phụ thuộc tiêm là association ở F5.

## F8. Class diagram

| Sơ đồ | Phạm vi (PKG / UC) | File .drawio | Số lớp |
|---|---|---|---|
| P12-class-PKG-28 | PKG-28 | diagrams/P12-class-PKG-28.drawio | 17 (kèm 2 tham chiếu) |
| P12-class-PKG-27 | PKG-27 | diagrams/P12-class-PKG-27.drawio | 9 (kèm 3 tham chiếu) |
| P12-class-PKG-13 | PKG-13 | diagrams/P12-class-PKG-13.drawio | 4 (kèm 16 tham chiếu) |
| P12-class-PKG-12-PKG-14-PKG-15 | PKG-12, PKG-14, PKG-15 | diagrams/P12-class-PKG-12-PKG-14-PKG-15.drawio | 6 (kèm 13 tham chiếu) |
| P12-class-PKG-21 | PKG-21 | diagrams/P12-class-PKG-21.drawio | 11 (kèm 13 tham chiếu) |
| P12-class-PKG-22 | PKG-22 | diagrams/P12-class-PKG-22.drawio | 9 (kèm 1 tham chiếu) |
| P12-class-PKG-24 | PKG-24 | diagrams/P12-class-PKG-24.drawio | 7 (kèm 1 tham chiếu) |
| P12-class-PKG-25 | PKG-25 | diagrams/P12-class-PKG-25.drawio | 5 (kèm 0 tham chiếu) |

Cạnh tiêm phụ thuộc (A 0..* - B 1) không có nhãn multiplicity trên sơ đồ; các cạnh còn lại có nhãn multiplicity và vai trò ở hai đầu. Hộp nét đứt là lớp hoặc interface ngoài package ghi tên (tham chiếu). Cạnh nguồn là Lớp A, đích là Lớp B theo F5; association điều hướng B --> A có đầu mũi tên mở ở phía Lớp A.

F8.P12-class-PKG-28 P12 Lớp PKG-28 Ticketing

| ID | Loại | Nhãn (tên lớp) | Stereotype | Thuộc về (PKG) | Ghi chú |
|---|---|---|---|---|---|
| DC-SeatHold | Class | SeatHold | «entity» | PKG-28 | - |
| DC-SeatStatus | Class | SeatStatus | «entity» | PKG-28 | - |
| DC-PaymentTransaction | Class | PaymentTransaction | «entity» | PKG-28 | - |
| DC-RefundRequest | Class | RefundRequest | «entity» | PKG-28 | - |
| DC-Booking | Class | Booking | «entity» | PKG-28 | - |
| DC-Ticket | Class | Ticket | «entity» | PKG-28 | - |
| DC-HoldSettlement | Class | HoldSettlement | «utility» | PKG-28 | - |
| DC-Customer | Class | Customer | «entity» | PKG-28 | - |
| DC-BoxOfficeClerk | Class | BoxOfficeClerk | «entity» | PKG-28 | - |
| IF-16 | Interface | IHolderRepository | «interface» | PKG-28 | - |
| IF-17 | Interface | ISeatHoldRepository | «interface» | PKG-28 | - |
| IF-18 | Interface | ISeatStatusRepository | «interface» | PKG-28 | - |
| IF-19 | Interface | IPaymentTransactionRepository | «interface» | PKG-28 | - |
| IF-20 | Interface | IBookingRepository | «interface» | PKG-28 | - |
| IF-21 | Interface | IRefundRequestRepository | «interface» | PKG-28 | - |
| IF-26 | Interface | IHoldSweepRepository | «interface» | PKG-28 | - |
| IF-27 | Interface | ITicketLockRepository | «interface» | PKG-28 | - |
| DC-Showtime | Class | Showtime | «entity» | PKG-27 | tham chiếu |
| DC-Seat | Class | Seat | «entity» | PKG-27 | tham chiếu |

| ID | Nguồn (Lớp A) | Đích (Lớp B) | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| R-44 | DC-Showtime | DC-SeatStatus | Association | A 1 - B 1..* (showtime / seatStatuses) | B --> A |
| R-45 | DC-SeatStatus | DC-Seat | Association | A 0..* - B 1 (seat) | A --> B |
| R-46 | DC-Showtime | DC-SeatHold | Association | A 1 - B 0..* (showtime / holds) | B --> A |
| R-47 | DC-SeatHold | DC-SeatStatus | Association | A 0..* - B 1..8 (holds / seats) | Hai chiều |
| R-48 | DC-SeatHold | DC-Customer | Association | A 0..* - B 0..1 (holder) | A --> B |
| R-49 | DC-SeatHold | DC-BoxOfficeClerk | Association | A 0..* - B 0..1 (holder) | A --> B |
| R-50 | DC-SeatHold | DC-PaymentTransaction | Association | A 1 - B 0..* (hold / transactions) | B --> A |
| R-51 | DC-SeatHold | DC-Booking | Association | A 1 - B 0..1 (hold / booking) | B --> A |
| R-52 | DC-Booking | DC-Ticket | Aggregation | A 1 - B 1..8 (booking / tickets) | A --> B |
| R-53 | DC-Ticket | DC-Showtime | Association | A 0..* - B 1 (tickets / showtime) | A --> B |
| R-54 | DC-Ticket | DC-SeatStatus | Association | A 0..* - B 1 (tickets / seatStatus) | A --> B |
| R-55 | DC-PaymentTransaction | DC-RefundRequest | Association | A 0..1 - B 0..* (transaction / refunds) | B --> A |
| R-56 | DC-Ticket | DC-RefundRequest | Association | A 0..1 - B 0..1 (ticket / refund) | B --> A |
| R-63 | DC-SeatHold | DC-SeatStatus | Association | A 0..1 - B 0..8 (currentHold / heldSeats) | B --> A |
| R-64 | DC-Ticket | DC-SeatStatus | Association | A 0..1 - B 0..1 (currentTicket / soldSeat) | B --> A |

F8.P12-class-PKG-27 P12 Lớp PKG-27 CinemaOperations

| ID | Loại | Nhãn (tên lớp) | Stereotype | Thuộc về (PKG) | Ghi chú |
|---|---|---|---|---|---|
| DC-Showtime | Class | Showtime | «entity» | PKG-27 | - |
| DC-PriceList | Class | PriceList | «entity» | PKG-27 | - |
| IF-08 | Interface | IUnitOfWork | «interface» | PKG-27 | - |
| IF-25 | Interface | Tx | «interface» | PKG-27 | - |
| IF-11 | Interface | IShowtimeRepository | «interface» | PKG-27 | - |
| IF-12 | Interface | IPriceListRepository | «interface» | PKG-27 | - |
| IF-13 | Interface | ICinemaRepository | «interface» | PKG-27 | - |
| IF-24 | Interface | ICodeGenerator | «interface» | PKG-27 | - |
| DC-RandomCodeGenerator | Class | RandomCodeGenerator | «utility» | PKG-27 | - |
| DC-SeatStatus | Class | SeatStatus | «entity» | PKG-28 | tham chiếu |
| DC-SeatHold | Class | SeatHold | «entity» | PKG-28 | tham chiếu |
| DC-Ticket | Class | Ticket | «entity» | PKG-28 | tham chiếu |

| ID | Nguồn (Lớp A) | Đích (Lớp B) | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| R-141 | DC-RandomCodeGenerator | IF-24 | Realization | - | A --> B |
| R-44 | DC-Showtime | DC-SeatStatus | Association | A 1 - B 1..* (showtime / seatStatuses) | B --> A |
| R-46 | DC-Showtime | DC-SeatHold | Association | A 1 - B 0..* (showtime / holds) | B --> A |
| R-53 | DC-Ticket | DC-Showtime | Association | A 0..* - B 1 (tickets / showtime) | A --> B |
| R-60 | DC-Showtime | DC-PriceList | Dependency | - | A --> B |

F8.P12-class-PKG-13 P12 Lớp PKG-13 SeatBooking

| ID | Loại | Nhãn (tên lớp) | Stereotype | Thuộc về (PKG) | Ghi chú |
|---|---|---|---|---|---|
| DC-BookTicketsService | Class | BookTicketsService | «service» | PKG-13 | - |
| DC-SeatMapService | Class | SeatMapService | «service» | PKG-13 | - |
| DC-HoldExpiryJob | Class | HoldExpiryJob | «service» | PKG-13 | - |
| DC-SeatReleaseJob | Class | SeatReleaseJob | «service» | PKG-13 | - |
| IF-08 | Interface | IUnitOfWork | «interface» | PKG-27 | tham chiếu |
| IF-11 | Interface | IShowtimeRepository | «interface» | PKG-27 | tham chiếu |
| IF-12 | Interface | IPriceListRepository | «interface» | PKG-27 | tham chiếu |
| IF-13 | Interface | ICinemaRepository | «interface» | PKG-27 | tham chiếu |
| IF-16 | Interface | IHolderRepository | «interface» | PKG-28 | tham chiếu |
| IF-17 | Interface | ISeatHoldRepository | «interface» | PKG-28 | tham chiếu |
| IF-18 | Interface | ISeatStatusRepository | «interface» | PKG-28 | tham chiếu |
| IF-19 | Interface | IPaymentTransactionRepository | «interface» | PKG-28 | tham chiếu |
| IF-20 | Interface | IBookingRepository | «interface» | PKG-28 | tham chiếu |
| IF-24 | Interface | ICodeGenerator | «interface» | PKG-27 | tham chiếu |
| IF-26 | Interface | IHoldSweepRepository | «interface» | PKG-28 | tham chiếu |
| DC-HoldSettlement | Class | HoldSettlement | «utility» | PKG-28 | tham chiếu |
| IF-01 | Interface | IPaymentGateway | «interface» | PKG-22 | tham chiếu |
| IF-22 | Interface | ISeatEventStore | «interface» | PKG-21 | tham chiếu |
| IF-04 | Interface | ISeatEventSubscription | «interface» | PKG-24 | tham chiếu |
| IF-06 | Interface | IScheduledJob | «interface» | PKG-25 | tham chiếu |

| ID | Nguồn (Lớp A) | Đích (Lớp B) | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| R-65 | DC-BookTicketsService | IF-08 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-66 | DC-BookTicketsService | IF-11 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-67 | DC-BookTicketsService | IF-12 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-68 | DC-BookTicketsService | IF-13 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-69 | DC-BookTicketsService | IF-16 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-70 | DC-BookTicketsService | IF-17 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-71 | DC-BookTicketsService | IF-18 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-72 | DC-BookTicketsService | IF-19 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-73 | DC-BookTicketsService | IF-20 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-74 | DC-BookTicketsService | IF-24 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-75 | DC-BookTicketsService | IF-01 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-77 | DC-SeatMapService | IF-22 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-78 | DC-SeatMapService | IF-04 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-79 | DC-HoldExpiryJob | IF-08 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-80 | DC-HoldExpiryJob | IF-17 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-81 | DC-HoldExpiryJob | IF-22 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-82 | DC-SeatReleaseJob | IF-08 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-84 | DC-SeatReleaseJob | IF-18 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-187 | DC-BookTicketsService | DC-HoldSettlement | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-191 | DC-HoldExpiryJob | IF-26 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-192 | DC-SeatReleaseJob | IF-26 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-111 | DC-HoldExpiryJob | IF-06 | Realization | - | A --> B |
| R-112 | DC-SeatReleaseJob | IF-06 | Realization | - | A --> B |

F8.P12-class-PKG-12-PKG-14-PKG-15 P12 Lớp PKG-12 PKG-14 PKG-15

| ID | Loại | Nhãn (tên lớp) | Stereotype | Thuộc về (PKG) | Ghi chú |
|---|---|---|---|---|---|
| DC-PaymentReportService | Class | PaymentReportService | «service» | PKG-14 | - |
| DC-RefundService | Class | RefundService | «service» | PKG-14 | - |
| DC-RefundOutboxJob | Class | RefundOutboxJob | «service» | PKG-14 | - |
| DC-CancelTicketService | Class | CancelTicketService | «service» | PKG-15 | - |
| DC-CheckTicketService | Class | CheckTicketService | «service» | PKG-15 | - |
| DC-PaymentCallbackController | Class | PaymentCallbackController | «boundary» | PKG-12 | - |
| IF-08 | Interface | IUnitOfWork | «interface» | PKG-27 | tham chiếu |
| IF-02 | Interface | IPaymentReportReceiver | «interface» | PKG-22 | tham chiếu |
| IF-17 | Interface | ISeatHoldRepository | «interface» | PKG-28 | tham chiếu |
| IF-18 | Interface | ISeatStatusRepository | «interface» | PKG-28 | tham chiếu |
| IF-19 | Interface | IPaymentTransactionRepository | «interface» | PKG-28 | tham chiếu |
| IF-20 | Interface | IBookingRepository | «interface» | PKG-28 | tham chiếu |
| IF-23 | Interface | IOutboxStore | «interface» | PKG-21 | tham chiếu |
| IF-01 | Interface | IPaymentGateway | «interface» | PKG-22 | tham chiếu |
| IF-21 | Interface | IRefundRequestRepository | «interface» | PKG-28 | tham chiếu |
| IF-11 | Interface | IShowtimeRepository | «interface» | PKG-27 | tham chiếu |
| IF-27 | Interface | ITicketLockRepository | «interface» | PKG-28 | tham chiếu |
| DC-HoldSettlement | Class | HoldSettlement | «utility» | PKG-28 | tham chiếu |
| IF-06 | Interface | IScheduledJob | «interface» | PKG-25 | tham chiếu |

| ID | Nguồn (Lớp A) | Đích (Lớp B) | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| R-85 | DC-PaymentReportService | IF-08 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-86 | DC-PaymentReportService | IF-02 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-87 | DC-PaymentReportService | IF-17 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-88 | DC-PaymentReportService | IF-18 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-89 | DC-PaymentReportService | IF-19 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-90 | DC-PaymentReportService | IF-20 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-91 | DC-PaymentReportService | IF-23 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-92 | DC-PaymentReportService | DC-RefundService | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-188 | DC-PaymentReportService | DC-HoldSettlement | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-93 | DC-RefundService | IF-08 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-94 | DC-RefundService | IF-01 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-95 | DC-RefundService | IF-19 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-97 | DC-RefundService | IF-21 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-98 | DC-RefundService | IF-23 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-99 | DC-RefundOutboxJob | IF-23 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-100 | DC-RefundOutboxJob | DC-RefundService | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-101 | DC-CancelTicketService | IF-08 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-102 | DC-CancelTicketService | IF-11 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-103 | DC-CancelTicketService | IF-18 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-104 | DC-CancelTicketService | IF-20 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-105 | DC-CancelTicketService | IF-21 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-106 | DC-CancelTicketService | DC-RefundService | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-193 | DC-CancelTicketService | IF-27 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-195 | DC-CancelTicketService | IF-19 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-107 | DC-CheckTicketService | IF-08 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-108 | DC-CheckTicketService | IF-11 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-194 | DC-CheckTicketService | IF-27 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-110 | DC-PaymentCallbackController | DC-PaymentReportService | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-113 | DC-RefundOutboxJob | IF-06 | Realization | - | A --> B |
| R-18 | DC-RefundService | IF-01 | Association | A 0..* - B 1 (gateway) | A --> B |

F8.P12-class-PKG-21 P12 Lớp PKG-21 Persistence

| ID | Loại | Nhãn (tên lớp) | Stereotype | Thuộc về (PKG) | Ghi chú |
|---|---|---|---|---|---|
| DC-PgUnitOfWork | Class | PgUnitOfWork | «service» | PKG-21 | - |
| DC-PgTx | Class | PgTx | «service» | PKG-21 | - |
| DC-LockOrderGuard | Class | LockOrderGuard | «utility» | PKG-21 | - |
| DC-ConnectionPools | Class | ConnectionPools | «utility» | PKG-21 | - |
| DC-SeatEventWriter | Class | SeatEventWriter | «utility» | PKG-21 | - |
| DC-PgTicketingStore | Class | PgTicketingStore | «service» | PKG-21 | - |
| DC-PgCinemaOperationsStore | Class | PgCinemaOperationsStore | «service» | PKG-21 | - |
| DC-PgSeatEventStore | Class | PgSeatEventStore | «service» | PKG-21 | - |
| DC-PgOutboxStore | Class | PgOutboxStore | «service» | PKG-21 | - |
| IF-22 | Interface | ISeatEventStore | «interface» | PKG-21 | - |
| IF-23 | Interface | IOutboxStore | «interface» | PKG-21 | - |
| IF-08 | Interface | IUnitOfWork | «interface» | PKG-27 | tham chiếu |
| IF-25 | Interface | Tx | «interface» | PKG-27 | tham chiếu |
| IF-16 | Interface | IHolderRepository | «interface» | PKG-28 | tham chiếu |
| IF-17 | Interface | ISeatHoldRepository | «interface» | PKG-28 | tham chiếu |
| IF-18 | Interface | ISeatStatusRepository | «interface» | PKG-28 | tham chiếu |
| IF-19 | Interface | IPaymentTransactionRepository | «interface» | PKG-28 | tham chiếu |
| IF-20 | Interface | IBookingRepository | «interface» | PKG-28 | tham chiếu |
| IF-21 | Interface | IRefundRequestRepository | «interface» | PKG-28 | tham chiếu |
| IF-26 | Interface | IHoldSweepRepository | «interface» | PKG-28 | tham chiếu |
| IF-27 | Interface | ITicketLockRepository | «interface» | PKG-28 | tham chiếu |
| IF-11 | Interface | IShowtimeRepository | «interface» | PKG-27 | tham chiếu |
| IF-12 | Interface | IPriceListRepository | «interface» | PKG-27 | tham chiếu |
| IF-13 | Interface | ICinemaRepository | «interface» | PKG-27 | tham chiếu |

| ID | Nguồn (Lớp A) | Đích (Lớp B) | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| R-139 | DC-PgUnitOfWork | IF-08 | Realization | - | A --> B |
| R-140 | DC-PgTx | IF-25 | Realization | - | A --> B |
| R-142 | DC-PgSeatEventStore | IF-22 | Realization | - | A --> B |
| R-143 | DC-PgOutboxStore | IF-23 | Realization | - | A --> B |
| R-144 | DC-PgTicketingStore | IF-16 | Realization | - | A --> B |
| R-145 | DC-PgTicketingStore | IF-17 | Realization | - | A --> B |
| R-146 | DC-PgTicketingStore | IF-18 | Realization | - | A --> B |
| R-147 | DC-PgTicketingStore | IF-19 | Realization | - | A --> B |
| R-148 | DC-PgTicketingStore | IF-20 | Realization | - | A --> B |
| R-149 | DC-PgTicketingStore | IF-21 | Realization | - | A --> B |
| R-189 | DC-PgTicketingStore | IF-26 | Realization | - | A --> B |
| R-190 | DC-PgTicketingStore | IF-27 | Realization | - | A --> B |
| R-150 | DC-PgCinemaOperationsStore | IF-11 | Realization | - | A --> B |
| R-151 | DC-PgCinemaOperationsStore | IF-12 | Realization | - | A --> B |
| R-152 | DC-PgCinemaOperationsStore | IF-13 | Realization | - | A --> B |
| R-153 | DC-PgUnitOfWork | DC-ConnectionPools | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-154 | DC-PgTicketingStore | DC-ConnectionPools | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-155 | DC-PgCinemaOperationsStore | DC-ConnectionPools | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-156 | DC-PgSeatEventStore | DC-ConnectionPools | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-157 | DC-PgOutboxStore | DC-ConnectionPools | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-158 | DC-PgTicketingStore | DC-SeatEventWriter | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-159 | DC-PgTx | DC-LockOrderGuard | Composition | A 1 - B 1 (guard) | A --> B |

F8.P12-class-PKG-22 P12 Lớp PKG-22 PaymentGatewayClient

| ID | Loại | Nhãn (tên lớp) | Stereotype | Thuộc về (PKG) | Ghi chú |
|---|---|---|---|---|---|
| IF-01 | Interface | IPaymentGateway | «interface» | PKG-22 | - |
| IF-02 | Interface | IPaymentReportReceiver | «interface» | PKG-22 | - |
| DC-PaymentGatewayManager | Class | PaymentGatewayManager | «service» | PKG-22 | - |
| DC-PaymentReportReceiver | Class | PaymentReportReceiver | «service» | PKG-22 | - |
| DC-VnpayUrlBuilder | Class | VnpayUrlBuilder | «utility» | PKG-22 | - |
| DC-VnpayRefundClient | Class | VnpayRefundClient | «service» | PKG-22 | - |
| DC-VnpaySigner | Class | VnpaySigner | «utility» | PKG-22 | - |
| DC-VnpayReportDecoder | Class | VnpayReportDecoder | «utility» | PKG-22 | - |
| DC-GatewayConfig | Class | GatewayConfig | «utility» | PKG-22 | - |
| DC-RefundService | Class | RefundService | «service» | PKG-14 | tham chiếu |

| ID | Nguồn (Lớp A) | Đích (Lớp B) | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| R-114 | DC-PaymentGatewayManager | IF-01 | Realization | - | A --> B |
| R-115 | DC-PaymentReportReceiver | IF-02 | Realization | - | A --> B |
| R-116 | DC-PaymentGatewayManager | DC-VnpayUrlBuilder | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-117 | DC-PaymentGatewayManager | DC-VnpayRefundClient | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-118 | DC-PaymentGatewayManager | DC-GatewayConfig | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-119 | DC-VnpayUrlBuilder | DC-VnpaySigner | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-120 | DC-VnpayUrlBuilder | DC-GatewayConfig | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-121 | DC-VnpayRefundClient | DC-VnpaySigner | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-122 | DC-VnpayRefundClient | DC-GatewayConfig | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-123 | DC-PaymentReportReceiver | DC-VnpaySigner | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-124 | DC-PaymentReportReceiver | DC-VnpayReportDecoder | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-125 | DC-VnpaySigner | DC-GatewayConfig | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-18 | DC-RefundService | IF-01 | Association | A 0..* - B 1 (gateway) | A --> B |

F8.P12-class-PKG-24 P12 Lớp PKG-24 SeatEventHub

| ID | Loại | Nhãn (tên lớp) | Stereotype | Thuộc về (PKG) | Ghi chú |
|---|---|---|---|---|---|
| IF-04 | Interface | ISeatEventSubscription | «interface» | PKG-24 | - |
| DC-SeatEventHubManager | Class | SeatEventHubManager | «service» | PKG-24 | - |
| DC-SeatEventPoller | Class | SeatEventPoller | «service» | PKG-24 | - |
| DC-SeatReplayReader | Class | SeatReplayReader | «service» | PKG-24 | - |
| DC-SubscriberRegistry | Class | SubscriberRegistry | «utility» | PKG-24 | - |
| DC-SubscriberQueue | Class | SubscriberQueue | «utility» | PKG-24 | - |
| DC-EmittedEventTracker | Class | EmittedEventTracker | «utility» | PKG-24 | - |
| IF-22 | Interface | ISeatEventStore | «interface» | PKG-21 | tham chiếu |

| ID | Nguồn (Lớp A) | Đích (Lớp B) | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| R-126 | DC-SeatEventHubManager | IF-04 | Realization | - | A --> B |
| R-127 | DC-SeatEventHubManager | DC-SubscriberRegistry | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-128 | DC-SeatEventHubManager | DC-SeatReplayReader | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-129 | DC-SeatEventHubManager | DC-SeatEventPoller | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-130 | DC-SeatEventPoller | DC-SubscriberRegistry | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-131 | DC-SeatEventPoller | DC-EmittedEventTracker | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-132 | DC-SeatEventPoller | IF-22 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-133 | DC-SeatReplayReader | IF-22 | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-134 | DC-SubscriberRegistry | DC-SubscriberQueue | Composition | A 1 - B 0..* (queues) | A --> B |

F8.P12-class-PKG-25 P12 Lớp PKG-25 Scheduler

| ID | Loại | Nhãn (tên lớp) | Stereotype | Thuộc về (PKG) | Ghi chú |
|---|---|---|---|---|---|
| IF-05 | Interface | IJobScheduler | «interface» | PKG-25 | - |
| IF-06 | Interface | IScheduledJob | «interface» | PKG-25 | - |
| DC-JobSchedulerManager | Class | JobSchedulerManager | «service» | PKG-25 | - |
| DC-JobRegistry | Class | JobRegistry | «utility» | PKG-25 | - |
| DC-JobLoop | Class | JobLoop | «utility» | PKG-25 | - |

| ID | Nguồn (Lớp A) | Đích (Lớp B) | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| R-135 | DC-JobSchedulerManager | IF-05 | Realization | - | A --> B |
| R-136 | DC-JobSchedulerManager | DC-JobRegistry | Association | A 0..* - B 1 | tiêm phụ thuộc, không nhãn trên sơ đồ |
| R-137 | DC-JobRegistry | DC-JobLoop | Composition | A 1 - B 0..* (loops) | A --> B |
| R-138 | DC-JobLoop | IF-06 | Association | A 0..* - B 1 (job) | tiêm phụ thuộc, không nhãn trên sơ đồ |

## F9. Gán package và kiểm tra phụ thuộc package

| PKG | Lớp (DC) | Phụ thuộc vào PKG (suy từ F5 và chữ ký) | Hợp lệ theo P09 |
|---|---|---|---|
| PKG-28 | DC-SeatHold, DC-SeatStatus, DC-PaymentTransaction, DC-RefundRequest, DC-Booking, DC-Ticket, DC-HoldSettlement, DC-Customer, DC-BoxOfficeClerk, IF-16, IF-17, IF-18, IF-19, IF-20, IF-21, IF-26, IF-27 | PKG-27 | PKG-27: Có (P10 F6) |
| PKG-27 | DC-Showtime, DC-PriceList, IF-08, IF-25, IF-11, IF-12, IF-13, IF-24, DC-RandomCodeGenerator | - | Có (không phụ thuộc package nào) |
| PKG-13 | DC-BookTicketsService, DC-SeatMapService, DC-HoldExpiryJob, DC-SeatReleaseJob | PKG-21, PKG-22, PKG-24, PKG-25, PKG-27, PKG-28 | PKG-21: Có (P10 F6)<br>PKG-22: Có (P10 F6)<br>PKG-24: Có (P10 F6)<br>PKG-25: Có (P10 F6)<br>PKG-27: Có (P10 F6)<br>PKG-28: Có (P10 F6) |
| PKG-14 | DC-PaymentReportService, DC-RefundService, DC-RefundOutboxJob | PKG-21, PKG-22, PKG-25, PKG-27, PKG-28 | PKG-21: Có (P10 F6)<br>PKG-22: Có (P10 F6)<br>PKG-25: Có (P10 F6)<br>PKG-27: Có (P10 F6)<br>PKG-28: Có (P10 F6) |
| PKG-15 | DC-CancelTicketService, DC-CheckTicketService | PKG-14, PKG-27, PKG-28 | PKG-14: Có (P10 F6)<br>PKG-27: Có (P10 F6)<br>PKG-28: Có (P10 F6) |
| PKG-12 | DC-PaymentCallbackController | PKG-14 | PKG-14: Có (P10 F6) |
| PKG-21 | DC-PgUnitOfWork, DC-PgTx, DC-LockOrderGuard, DC-ConnectionPools, DC-SeatEventWriter, DC-PgTicketingStore, DC-PgCinemaOperationsStore, DC-PgSeatEventStore, DC-PgOutboxStore, IF-22, IF-23 | PKG-27, PKG-28 | PKG-27: Có (P10 F6)<br>PKG-28: Có (P10 F6) |
| PKG-22 | IF-01, IF-02, DC-PaymentGatewayManager, DC-PaymentReportReceiver, DC-VnpayUrlBuilder, DC-VnpayRefundClient, DC-VnpaySigner, DC-VnpayReportDecoder, DC-GatewayConfig | - | Có (không phụ thuộc package nào) |
| PKG-24 | IF-04, DC-SeatEventHubManager, DC-SeatEventPoller, DC-SeatReplayReader, DC-SubscriberRegistry, DC-SubscriberQueue, DC-EmittedEventTracker | PKG-21, PKG-27, PKG-28 | PKG-21: Có (P10 F6)<br>PKG-27: Có theo P09 F6 (cùng layer một chiều hoặc xuống layer dưới), P10 F6 chưa ghi, Đề xuất sửa P10<br>PKG-28: Có (P10 F6) |
| PKG-25 | IF-05, IF-06, DC-JobSchedulerManager, DC-JobRegistry, DC-JobLoop | - | Có (không phụ thuộc package nào) |
| PKG-26 | IF-07 | - | Có (không phụ thuộc package nào) |

Kiểm tra bằng chương trình trên đồ thị quan hệ F5: không có vòng (PKG-21 --> PKG-27 và PKG-28, PKG-28 --> PKG-27, PKG-24 --> PKG-21, PKG-28 và PKG-27, PKG-15 --> PKG-14; không cạnh nào ngược lại); không phụ thuộc hay realization đi lên layer trên (IF-06 do PKG-25 định nghĩa, PKG-13, PKG-14 hiện thực: realization đi xuống). Một cạnh P10 F6 chưa ghi: PKG-24 --> PKG-27 (Đề xuất sửa P10). PKG-12 chỉ phụ thuộc PKG-14: ResolveReturnedPayment và QueryPaymentStatus trả kiểu thuần để PKG-12 không import PKG-22 hay PKG-27. Số phần tử có hành vi mỗi package: PKG-28 có 17 (8 entity, DC-HoldSettlement và IF-16 đến IF-21, IF-26, IF-27, không tính DC-SeatChangeEvent và kiểu phụ trợ), vượt mức 15 của P10 F4 do thêm DC-HoldSettlement (X1 RV-01) và hai interface tách theo bên gọi (X1 RV-06); giữ nguyên vì tách package làm thêm cạnh phụ thuộc cho mọi package Application (P10 Vấn đề còn mở 2); PKG-21 có 11 (kể cả IF-22, IF-23); các package còn lại không quá 9.

Visibility: lớp job và hàm dựng chỉ hàm khởi động chương trình đăng ký nhận (P10 F5); chữ ký interface kho là public cho Application. Lớp bên trong SS-01, SS-03, SS-04 là package-private (P11b F5), chỉ interface và kiểu trong chữ ký là public.

## F10. Design pattern đã áp dụng

| Pattern | Vấn đề trong thiết kế này | Lớp tham gia (vai trò trong pattern) | Lý do chọn | Phương án đơn giản hơn đã xét |
|---|---|---|---|---|
| Repository (Data Mapper) | Tách SQL khoá dòng theo hạng khỏi logic nghiệp vụ; mỗi interface kho khai báo hạng khoá của từng operation | IF-11 đến IF-13, IF-16 đến IF-23, IF-26, IF-27 (Repository); DC-PgTicketingStore, DC-PgCinemaOperationsStore, DC-PgSeatEventStore, DC-PgOutboxStore (hiện thực) | P09 F5 buộc: entity phần lưu trữ là interface kho ở Domain, hiện thực ở PKG-21; để DC-LockOrderGuard kiểm được mọi lời gọi khoá | Entity tự chạy SQL: vi phạm quy tắc layer và Q-117 (không phần tử miền nào tự khoá) |
| Unit of Work | Mỗi thao tác EX-nn là đúng một giao dịch; control không biết kiểu kết nối của CSDL | IF-08 và IF-25 (interface), DC-PgUnitOfWork, DC-PgTx (hiện thực) | Bước 1.4: control mở giao dịch qua interface dùng chung; kèm vòng thử lại 40P01, 55P03 | Mỗi service tự gọi BEGIN và COMMIT: lặp logic thử lại, lặp kiểm thứ tự khoá |
| Adapter | Giao thức VNPay (ký HMAC-SHA512, tham số, mã trả lời) không khớp interface hệ thống mong đợi (kiểu thuần: mã giao dịch, số tiền, khoá chống hoàn trùng) | IF-01, IF-02 (đích); DC-PaymentGatewayManager, DC-PaymentReportReceiver (adapter); DC-VnpayUrlBuilder, DC-VnpayRefundClient, DC-VnpaySigner, DC-VnpayReportDecoder (phần giao thức) | NFR-15 đến NFR-17 yêu cầu giao tiếp với cổng; đổi cổng sửa PKG-22, bảng RspCode ở PKG-12 và phần đọc tham số ở PKG-14 (Q-141); P11b đã chốt thiết kế subsystem | Gọi VNPay thẳng từ DC-RefundService: lộ giao thức vào Application |
| Outbox (hàng đợi gửi cùng giao dịch) | Gọi cổng hoàn tiền (30 giây) và gửi email không được giữ khoá hay nằm trong giao dịch ghi ghế; vẫn không được mất khoản hoàn khi tiến trình chết | IF-23, DC-PgOutboxStore; DC-RefundService, DC-RefundOutboxJob | P09 F7.7: INSERT cùng giao dịch tạo ra nó, claim SKIP LOCKED, claim_token, at-least-once cho email và idempotent cho hoàn tiền nhờ khoá chống hoàn trùng | Gọi cổng ngay trong yêu cầu của khách: giữ khoá hạng 9 và kết nối tới 30 giây, đe doạ NFR-06 |
| Factory Method (tĩnh) | Entity có quy tắc khởi tạo riêng (hạn giữ ghế, khoá chống hoàn trùng, trạng thái đầu của hoàn tiền mặt) | DC-SeatHold.NewSeatHold, DC-RefundRequest.NewFullRefund, NewTicketRefund, NewCashRefund, DC-PaymentTransaction.NewPending, DC-Booking.NewBooking (tạo vé qua newTicket) | Quy tắc đặt trạng thái đầu nằm cùng lớp, không rải ở các service | Dựng struct trực tiếp ở service: dễ quên expiryTime hoặc khoá chống hoàn trùng |
| Pure Fabrication (GRASP) và Extract Class | Bốn operation của hai service lặp dãy kết thúc lần giữ ghế và dãy bán ghế; sửa một quy tắc phải sửa đồng thời ở bốn chỗ (Q-134 đã xảy ra) | DC-HoldSettlement (End, Sell, FinishSale); DC-BookTicketsService, DC-PaymentReportService (bên gọi) | Một nơi định nghĩa trình tự Expire, Cancel, FailPayment, Complete, ReleaseHold, tạo vé; không I/O nên vẫn đúng Q-117 và test không cần kho | Giữ lặp ở bốn operation: V(G) của HoldSeats, HandleIpn lớn (X2) và nguy cơ quên Expire trước (X1 RV-01) |
| Không áp dụng State (GoF) | Năm state machine có từ 3 đến 5 trạng thái, mỗi trạng thái chỉ có 2 đến 4 sự kiện và hành vi khác nhau chỉ là chấp nhận hoặc từ chối | Không có | Một thuộc tính enumeration và phép kiểm đầu mỗi operation đủ rõ; State thêm một lớp mỗi trạng thái mà không giảm điều kiện | Dùng đúng cấu trúc state đã chọn: enumeration cộng guard |

## Xử lý mục chuyển từ bước trước

| Nguồn | Mục | Cách xử lý trong P12 |
|---|---|---|
| P10 Đề xuất sửa (từ P11b) | Kiểu và ngoại lệ thiếu ở F3, F4, F5 (DC-RefundLookup, DC-ReportHandlingResult, bốn ngoại lệ SS-01; kiểu và ngoại lệ SS-03, SS-04, SS-05) | Đã cấp dòng F1b cho SS-01, SS-03, SS-04 và các kiểu trong chữ ký của IF-07 (DC-Role, DC-SessionClaims, DC-IssuedSession, bốn ngoại lệ); DC-ReportHandlingResult ghi trạng thái Gộp vào DC-IpnOutcome; phần P10 cập nhật ghi ở Đề xuất sửa artifact trước. DC-EmailAttachment, DC-EmailSendResult, DC-InvalidEmailMessageError (SS-02) và phần bên trong SS-05 để lượt sau |
| P10 Đề xuất sửa (từ P11b) | Điểm vào địa chỉ trả về (return URL) | Giải quyết: DC-PaymentCallbackController.HandleReturn kiểm chữ ký qua DC-PaymentReportService.ResolveReturnedPayment (IF-02, V-16) rồi chuyển hướng tới trang kết quả của SPA kèm holdRef, không ghi gì; trang hỏi lại bằng HandlePaymentStatus gọi DC-PaymentReportService.QueryPaymentStatus (đọc không khoá, Q-126). Không thêm cạnh package |
| P11b Vấn đề còn mở 11 | Thứ tự ưu tiên SS | Làm đầy đủ SS-01 và SS-03 (F1, F2, F3, F5, F7, class diagram PKG-22 và PKG-24); SS-04 chỉ DC-JobSchedulerManager, DC-JobRegistry, DC-JobLoop với vòng lặp theo chu kỳ có ngân sách; SS-05 chỉ IF-07 với ba operation (VerifyPassword, IssueSession, VerifySession), CheckRole là hàm thường nên không vào interface |
| P11b Vấn đề còn mở 6 | Chữ ký tạm IF-22 | Chốt ở F2: ReadEventsAfter, ReadShowtimeEvents, FindEvent, Snapshot, DeleteOlderThan |
| P11b Vấn đề còn mở 9 | Kiểu trung lập sang Go | Mục 0.2 |
| P10 Vấn đề còn mở 6 | IF-08 đến IF-23 do P12 thiết kế; nhóm interface ghép có thể tách | Thiết kế operation đầy đủ cho IF-08, IF-11 đến IF-13, IF-16 đến IF-23 (phần dùng trong phạm vi). Giữ ghép IF-13 và IF-16 vì mỗi operation khoá đúng một hạng và các lớp dịch vụ cần cùng lúc; IF-17, IF-18, IF-20 được tách theo bên gọi thành IF-26 (thao tác theo lô của hai job nền) và IF-27 (khoá vé) theo X1 RV-06 |

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ |
|---|---|---|---|
| Q-133 | Đã trả lời (gộp ghi nhận huỷ, trả ghế và tạo yêu cầu hoàn vào một giao dịch khoá theo hạng 6 ghế, 7 PaymentTransaction, 8 Ticket rồi chèn RefundRequest hạng 9; gọi cổng hoàn tiền nằm ngoài giao dịch qua hàng đợi; huỷ tại quầy gộp ghi huỷ, trả ghế và ghi khoản hoàn tiền mặt, Q-125). Câu hỏi gốc: Huỷ vé trực tuyến (UC-008) chạy ba giao dịch độc lập theo P08 F4b quy tắc 4: EX-07 ghi nhận huỷ, EX-09 tạo yêu cầu hoàn, EX-06 trả ghế. Nếu tiến trình chết giữa EX-07 và EX-09, vé đã huỷ nhưng chưa có yêu cầu hoàn nên khách mất tiền mà hệ thống không có dấu vết để xử lý thủ công. Có đồng ý gộp EX-07 và EX-09 thành một giao dịch (khoá hạng 7 PaymentTransaction rồi hạng 8 Ticket, đúng thứ tự tăng dần, hoàn tiền vẫn gọi cổng qua hàng đợi sau commit) và chỉ giữ EX-06 riêng theo BR-42, hay giữ ba giao dịch độc lập và chấp nhận chạy tiếp khi khách bấm huỷ lại (thiết kế hiện tại)? | DC-CancelTicketService.CancelOnlineTicket, DC-RefundService.RequestTicketRefund, ST-03, ST-04, P08 F4b quy tắc 4, P10 F3a EX-06, EX-07, EX-09, BR-21, BR-42 | P08 F4b quy tắc 4 ("không lồng") so với BR-21 (mỗi vé hoàn một lần) và BR-26 (hoàn không vượt đã thanh toán) |
| Q-134 | Đã trả lời (trả ghế ngay trong giao dịch đang giữ khoá hạng 6 khi lần giữ ghế kết thúc; job quét chỉ là lưới an toàn). Câu hỏi gốc: Khi một lần giữ ghế kết thúc mà ghế còn trỏ tới nó (báo thanh toán thất bại ở EX-02, hoặc EX-01 phát hiện lần giữ ghế cũ của chính người đó đã quá hạn), ghế chỉ được trả ở lượt quét kế tiếp của DC-SeatReleaseJob (tối đa khoảng 10 giây). Người giữ ghế chọn lại ngay đúng các ghế đó sẽ bị từ chối "ghế vừa có người chọn" dù ghế là của chính họ. Có cho trả ghế ngay trong giao dịch đang giữ khoá hạng 6 của ghế (không đổi thứ tự khoá, không thêm cạnh package) hay giữ nguyên chờ quét theo P10 F3a EX-05? | DC-PaymentReportService.HandleIpn, DC-BookTicketsService.HoldSeats, ST-01, ST-02, NFR-07 | P10 F3a EX-05 (giao dịch thanh toán thất bại do SeatReleaseJob giải phóng ở lượt quét kế tiếp) so với UC-005 luồng 11a ("ghế được trả") và BR-04 |
| Q-135 | Đã trả lời (người dùng đã quyết: hoàn tiền lỗi xử lý thủ công ngoài hệ thống, không có use case đặt lại trong hệ thống; UC-017 là quản lý tài khoản nhân viên, không liên quan). Câu hỏi gốc: Yêu cầu hoàn đang ở trạng thái Cần xử lý thủ công (P09 F7.7: "quản trị viên đặt lại về chờ để thử lại được"): việc đặt lại thuộc use case nào, ai được phép, và có giới hạn số lần đặt lại không? Nếu không có use case thì ST-04 không có chuyển trạng thái ra khỏi Cần xử lý thủ công. | DC-RefundRequest, ST-04 | P09 F7.7 và Vấn đề còn mở của P09; BR-41 ("xử lý thủ công ngoài hệ thống, không có use case") |

## Giả định

Không có (chế độ NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P10 | F3 (bảng phần tử mới do cơ chế), F4, F5 | Lớp và interface mới cấp ở P12 chưa có trong P10: IF-24 ICodeGenerator và DC-RandomCodeGenerator (PKG-27), IF-25 ITx (PKG-27), DC-PgTx (PKG-21, package-private); kiểu giá trị và ngoại lệ dùng trong chữ ký ở F1b | Thêm vào F3 (nguồn "Thiết kế"), F4 (PKG-27: thêm IF-24, IF-25, DC-RandomCodeGenerator; PKG-21: thêm DC-PgTx; mã PKG tiếp theo giữ PKG-30), F5 (DC-PgTx package-private; IF-24, IF-25 public; DC-RandomCodeGenerator public chỉ hàm khởi động) và các kiểu ở F1b: DC-Money, DC-CinemaIds, DC-TicketingIds, DC-HolderRef, DC-ActorContext, DC-SeatKey, DC-BookingView, DC-SeatSnapshot, DC-HoldSeatsRequest, DC-HoldResult, DC-PaymentStart, DC-PaymentStatusView, DC-IpnOutcome, DC-CancelResult, DC-AdmitResult, DC-SseFrame, DC-SseStream, DC-LockRank, DC-LockKey, DC-OutboxEntry và các enumeration, ngoại lệ (Đã áp dụng: P10 1.3) |
| P10 | F3 DC-PaymentCallbackController, F4 PKG-12, F5, F6 | Điểm vào địa chỉ trả về (P11b Đề xuất sửa P10) chưa có; trang kết quả cần đường hỏi lại trạng thái công khai (Q-126) | Ghi DC-PaymentCallbackController có ba đường vào công khai: HandleIpn, HandleReturn, HandlePaymentStatus; dùng DC-PaymentReportService.ResolveReturnedPayment và QueryPaymentStatus (cùng PKG-14 nên PKG-12 --> PKG-14 vẫn là cạnh duy nhất); đường hỏi trạng thái đặt ở PKG-12 để không thêm cạnh PKG-11 --> PKG-14 (Đã áp dụng: P10 1.3) |
| P10 | F3a EX-03 | EX-03 ghi "dòng hàng đợi email vé (IF-23)" nhưng người giữ ghế của EX-03 là nhân viên quầy, không có email, và P04 UC-005 luồng 9a không gửi email | Bỏ dòng hàng đợi email vé khỏi EX-03; chỉ EX-02 (kênh trực tuyến) xếp email vé (Đã áp dụng: P10 1.3) |
| P10 | F3a EX-05, EX-01, EX-02, EX-03, EX-04 | Q-134 đã trả lời: ghế được trả ngay trong giao dịch kết thúc lần giữ ghế | EX-02 (báo thất bại và nhánh hết hạn), EX-03 (hết hạn), EX-04 gộp EX-05 cho huỷ giữ ghế (khoá hạng 5 rồi 6), EX-01 (ghế trùng lần giữ ghế cũ vừa hết hạn) thêm bước SeatStatus.ReleaseHold trong cùng giao dịch; EX-05 chỉ còn là job quét theo lô, bỏ releaseSeatsOf theo yêu cầu và khoá S hạng 5 của nó (Đã áp dụng: P10 1.3) |
| P10 | F6 (phụ thuộc package) | IF-04 và DC-SeatChangeEvent dùng kiểu ShowtimeId của PKG-27 nên PKG-24 phụ thuộc PKG-27 (Services --> Domain, hợp lệ theo P09 F6, không vòng) nhưng P10 F6 chưa ghi | Thêm dòng PKG-24 --> PKG-27 (kiểu ShowtimeId trong chữ ký IF-04) (Đã áp dụng: P10 1.3 (cạnh D-60 và F6)) |
| P11b | SS-01 IF-02 (replyToReport) và DC-ReportHandlingResult | P10 1.2 đã bỏ replyToReport khỏi IF-02 và gộp kết quả xử lý vào DC-IpnAnswer; P11b F3, F5 còn nêu | Bỏ replyToReport và DC-ReportHandlingResult khỏi P11b SS-01 (mã giữ, trạng thái Gộp); IF-02 còn một operation (Đã áp dụng: P11b 1.3 (SS-01 1.2)) |
| P11b | IF-01, IF-02, IF-04, IF-07 (kiểu tham số) | Kiểu trung lập đổi sang Go: Integer tiền --> int64 đồng (PKG-22 không phụ thuộc Domain); DateTime --> time.Time; showtimeId String --> ShowtimeId số; afterEventId rỗng --> 0; kết quả luồng --> <-chan; không có kiểu bất đồng bộ cần sửa chữ ký | Cập nhật chữ ký P11b theo bảng ánh xạ kiểu ở mục 0.2 (đặc biệt IF-04.showtimeId), để chữ ký hai bên trùng (Đã áp dụng: P11b 1.3 (IF-04: showtimeId số, afterEventId 0; kiểu trung lập khác giữ, ánh xạ ở P12 mục 0.2)) |
| P11b | IF-22 (Vấn đề còn mở 6) | Chữ ký tạm readEventsAfter, readShowtimeEvents, findEvent được chốt ở P12 | Ghi tên chốt: ReadEventsAfter, ReadShowtimeEvents (thêm tham số window), FindEvent; thêm Snapshot và DeleteOlderThan (đã nêu ở P09 F7.5 và P10 F3 nhưng thiếu ở IF-22) (Đã áp dụng: P11b 1.3 (SS-03 1.2)) |
| P08 | F4 R-44, R-46, R-50, R-51, R-55, R-56, R-63, R-64 | Chiều điều hướng của P08 (từ lớp cha miền ra lớp con) ngược chiều phụ thuộc package: PKG-27 không phụ thuộc PKG-28 (P09 F4), và bên giữ mã là bên nhiều | Ghi chiều điều hướng B --> A cho tám quan hệ này (mã và Lớp A, B giữ nguyên); R-47 hiện thực bằng R-63 khi Đang giữ, không có bảng nối riêng (Đã áp dụng: P08 1.3) |
| P08 | F4 R-10 đến R-15, R-18 | Association tạm giữa control và entity, và AC-B-PaymentGateway --> AC-C-CancelTicketController, không còn đúng sau P10 | R-10 đến R-15 đổi thành Dependency (qua tham số, biến cục bộ); R-18 đổi Lớp A thành DC-RefundService --> IF-01 (Association tiêm phụ thuộc) (Đã áp dụng: P08 1.3) |
| P08 | F3 AC-E-PaymentTransaction (processed, result), F4c | Hai thuộc tính processed (3 giá trị) và result (2 giá trị) tương quan; Chưa xử lý cộng Thất bại là trạng thái riêng nên cần một enumeration | Gộp thành status gồm 4 giá trị: Chưa xử lý, Đã ghi nhận thất bại, Đã tạo vé, Đã ghi nhận thanh toán trễ (ST-05) (Đã áp dụng: P08 1.3) |
| P08 | F3 AC-E-SeatStatus (recordHeldPrice), AC-E-Ticket (cancelTicket, checkNotCancelledNotUsed, markCancelled) | Trách nhiệm tách quá mịn so với thao tác không chia cắt | Ghi gộp: recordHeldPrice vào holdSeatFor; ba trách nhiệm huỷ vé thành một operation Cancel (Đã áp dụng: P08 1.3) |
| P09 | F7.3 EX-01 | EX-01 cần đọc không khoá mã phòng chiếu và cụm rạp trước khi khoá hạng 1 và 2 (FindRouting), rồi so lại sau khi khoá suất chiếu | Ghi bước đọc không khoá này vào bảng EX-01 để khớp quy tắc 7 của P08 F4b (Đã áp dụng: P09 1.4) |
| P07 | UC-008 (thứ tự hoàn tiền, trả ghế) | Q-133 đã trả lời: ghi huỷ, trả ghế và tạo yêu cầu hoàn (hoặc ghi hoàn tiền mặt) là một giao dịch nên thứ tự message trong giao dịch không còn là rủi ro | Đối chiếu P07 UC-008: message ghi huỷ, trả ghế, tạo yêu cầu hoàn thuộc cùng một thao tác không chia cắt (Đã áp dụng: P07 UC-008 1.2) |
| P08 | F4b quy tắc 4, EX-06, EX-07, EX-09 | Q-133: huỷ vé không còn ba giao dịch độc lập; quy tắc "không lồng" không áp dụng cho chuỗi này | Gộp EX-06, EX-07, EX-09 thành một thao tác khoá ghế (6), PaymentTransaction (7), Ticket (8), rồi chèn RefundRequest (9) rồi Enqueue; chỉ cuộc gọi cổng (EX-10) nằm ngoài giao dịch; nhánh tiền mặt gộp EX-06, EX-07 và ghi khoản hoàn tiền mặt, bỏ hạng 7 (Đã áp dụng: P08 1.3) |
| P08 | F4b EX-02, F4c ST-01 và ST-05 | Báo thất bại của giao dịch cũ không được làm hỏng lần giữ ghế khi đã có giao dịch mới hơn; bán ghế thất bại vì liên kết ghế vỡ phải chuyển sang xử lý như thanh toán trễ | Ghi vào guard failPayment: chỉ khi giao dịch báo là giao dịch tạo sau cùng của lần giữ ghế; ghi nhánh HOLD_LINK_BROKEN dẫn tới LATE (EX-02, Q-84) (Đã áp dụng: P08 1.3) |
| P09 | F7.3 (EX-06, EX-07, EX-09), F7.6 | Q-133 gộp chuỗi huỷ vé thành một giao dịch; đường tạo giao dịch từ báo cần so số tiền với tổng giá ghế khi lần giữ ghế còn Đang giữ | Sửa bảng EX theo thứ tự khoá 6, 7, 8, 9 trong một giao dịch; bổ sung so số tiền ở bước chưa có PaymentTransaction (F7.6) và nhánh LATE khi liên kết ghế vỡ (Đã áp dụng: P09 1.4) |
| P09 | F7.7 | Q-135: không có use case đặt lại yêu cầu hoàn; tiến trình chết lúc đang gửi cần đường nhận lại | Bỏ câu "quản trị viên đặt lại về chờ"; Cần xử lý thủ công là trạng thái cuối. Ghi: claim hết hạn của yêu cầu đang chờ kết quả được nhận lại, tra cứu trước khi gửi lại (Q-118), số lần thử tính theo attemptCount của yêu cầu hoàn (Đã áp dụng: P09 1.4) |
| P09 | F7.5 điểm 3 và 4 | Cửa sổ chồng 5 giây quá sát maxDuration 4 giây của giao dịch ghi | Nâng cửa sổ chồng lên 10 giây, giữ mã đã phát 20 giây; ghi ràng buộc cửa sổ chồng lớn hơn maxDuration cộng thời gian chờ kết nối (Đã áp dụng: P09 1.4 (kèm SS-03 1.2 và P10 1.3 đổi cùng giá trị)) |
| P10 | F3 (phần tử mới), F3a EX-01, EX-02, EX-03, EX-04, EX-06, EX-07, EX-08, F4 PKG-28, F5, F6 | X1 RV-01 và RV-06 thêm DC-HoldSettlement (PKG-28), IF-26 IHoldSweepRepository, IF-27 ITicketLockRepository; thao tác kết thúc lần giữ ghế và bán ghế của EX-01 đến EX-04 đi qua DC-HoldSettlement; IF-20 chỉ còn thêm và đọc lần đặt | Thêm ba phần tử vào F3 (nguồn Thiết kế), F4 (PKG-28), F5 (public); sửa cột lớp và interface của EX-01 đến EX-04, EX-05 (IF-26), EX-07, EX-08 (IF-27); PKG-28 vượt mức 15 (Đã áp dụng: P10 1.5) |

## Vấn đề còn mở

1. Phạm vi vượt ngưỡng: 69 phần tử có hành vi (kể cả interface) so với ngưỡng khoảng 20 lớp của prompt. Người dùng yêu cầu một lần chạy cho lõi giữ ghế; theo prompt nên chạy lặp theo package (PKG-28 và PKG-27 trước, rồi PKG-21, PKG-13, PKG-14, PKG-15, PKG-12, rồi SS). Vì chạy một file, mỗi lớp được giữ ngắn gọn và các lớp ngoài lõi (PKG-11, PKG-16, PKG-20, PKG-05 đến PKG-10, PKG-29, phần còn lại của PKG-27, PKG-23, phần trong SS-05) để lượt sau. Lượt sau đính kèm file này để giữ nhất quán mã R-nn (tiếp từ R-197), ST-nn (tiếp từ ST-06), IF-nn (tiếp từ IF-28), Q-nn (tiếp từ Q-136).

2. F4 ánh xạ từ trách nhiệm P08, chưa đối chiếu từng message P07 (P07 không được đính kèm theo yêu cầu). Cần chạy kiểm chéo với P07 UC-005, UC-006, UC-008, UC-009 để bắt message còn sót, đặc biệt các message tới boundary giao diện và luồng thay thế; X1 sẽ kiểm.

3. Chuỗi khoá EX-02 phụ thuộc bước "chưa có PaymentTransaction thì INSERT dưới khoá SeatHold" (P09 F7.6); khi lần giữ ghế còn Đang giữ, số tiền của báo được so với tổng giá các ghế đang trỏ tới nó (AMOUNT_MISMATCH nếu khác), còn khi lần giữ ghế không còn hiệu lực thì không có giá để so và hoàn theo số tiền cổng báo (BR-40). Vì StartOnlinePayment luôn commit trước khi trả địa chỉ thanh toán, đường này chỉ là lưới an toàn. Ca kiểm thử đồng thời T4 của P09 F7.9 cần mô phỏng cả đường này.

4. DC-BookTicketsService có 12 phụ thuộc tiêm (IF-08, IF-11, IF-12, IF-13, IF-16, IF-17, IF-18, IF-19, IF-20, IF-24, IF-01 và DC-HoldSettlement) và 5 operation public. Giữ vì Q-117 buộc lớp dịch vụ là nơi duy nhất thấy cả chuỗi khoá EX-01 và nhiều phụ thuộc là hệ quả của chuỗi 6 hạng. Nếu X1 thấy quá lớn: tách StartOnlinePayment và ConfirmCashReceived (hai lý do thay đổi khác với giữ ghế) sang lớp riêng cùng PKG-13.

5. Số lượng operation getter của entity (đặt để quan sát hậu điều kiện, Bước 2.4) khiến DC-SeatHold có 14 operation public và DC-PaymentTransaction 13; dưới ngưỡng 15 đến 20 nhưng gần. Giữ vì X2 cần quan sát từng trạng thái.

6. R-47 (SeatHold 0..* - SeatStatus 1..8, lịch sử) không có bảng nối riêng: tập ghế của lần giữ ghế đã kết thúc không còn truy được sau khi ghế được trả. Đủ cho UC-005, UC-006, UC-008 (vé giữ khoá ghế qua R-54). Nếu báo cáo (UC-015, UC-016, chưa có P07) cần lịch sử ghế của lần giữ ghế Hết hạn, thêm bảng nối khi có P07.

7. Đã đóng: project-profile.md mục 3 đã cập nhật CONG_NGHE theo P09 F11 (mục giữ số thứ tự để các tham chiếu tới Vấn đề còn mở 9 không lệch).

8. Thông số kỹ thuật chọn ở P12 theo C1 mục 7, không phải giả định: lô 200, ngân sách 8 giây, hàng đợi 256, cửa sổ chồng seat_event 10 giây (lớn hơn maxDuration 4 giây), 3 lần thử lại hoàn tiền (MaxAttempts = 4), lock_timeout 1 giây, giao dịch ghi tối đa 4 giây, pool 20 và 5 (đều từ P09 F7); mã vé 16 ký tự, mã giao dịch 20 ký tự, UUID v4 cho mã tham chiếu lần giữ ghế, thời gian chờ backoff 20 ms của PgUnitOfWork, độ dài email 254 (RFC 5321). Giá trị nghiệp vụ lấy từ BR: 10 phút (BR-10), tối đa 8 ghế (BR-05), 70% (BR-19), hạn huỷ 2 tiếng (BR-18).

9. Mục 18 của Target: Showtime (Trong lịch chiếu, Đã xoá, P08 F4c) có từ BR dạng "chỉ được xoá khi chưa tới giờ, không có ghế giữ, không có vé chưa huỷ" nhưng thuộc UC-014 (có P07) và PKG-27 chưa chi tiết hoá ở lần chạy này: làm ST-06 khi chạy lượt PKG-27 và PKG-16. Cung chuyển trạng thái và operation sửa suất chiếu của lượt đó phải có kiểm BR-92 (không đổi phòng của suất chiếu đã từng có vé, kể cả vé đã huỷ; muốn đổi thì xoá suất chiếu rồi lập suất mới), thứ tự khoá theo P09 F7.3 EX-13.

10. Sơ đồ draw.io: lớp chạy diakempt -in-place -no-classlayout, state machine chạy diakempt -in-place, sơ đồ tuần tự do bộ sinh đặt toạ độ (không chạy diakempt). Bước samesize của diakempt kéo cao hộp lớp trong vài sơ đồ lớp nên có khoảng trắng trong hộp; cạnh tiêm phụ thuộc (A 0..* - B 1) không có nhãn multiplicity trên sơ đồ để tránh nhiễu và được ghi ở F5.

11. Giao dịch thanh toán ở trạng thái Chưa xử lý không có đối soát: khách bỏ trang cổng thì giao dịch nằm mãi ở Chưa xử lý (hợp lệ, lần giữ ghế hết hạn trước), nhưng nếu báo IPN thành công bị mất trong khi khách đã bị trừ tiền thì hệ thống không có cách tự biết, không vé và không hoàn. Giới hạn này được chấp nhận trong phạm vi đồ án; nếu cần, thêm IF-01.QueryTransaction chạy cho giao dịch Chưa xử lý quá hạn (P11b chưa có operation tra cứu giao dịch).

12. Lần giữ ghế đã kết thúc bởi HoldExpiryJob (hết hạn không do thao tác của người giữ) chỉ trả ghế ở lượt quét kế của SeatReleaseJob, tối đa khoảng 10 giây cho mỗi lượt và có thể hai lượt; người giữ chọn lại đúng ghế đó trong khoảng này vẫn gặp "ghế vừa có người chọn". Q-134 chỉ xoá khoảng trễ cho các giao dịch kết thúc lần giữ ghế đã giữ sẵn khoá ghế; giữ nguyên với job hết hạn vì job khoá theo lô SKIP LOCKED và không biết người giữ.
