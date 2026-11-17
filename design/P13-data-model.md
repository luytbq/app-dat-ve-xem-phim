# P13 - Mô hình dữ liệu - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P13 |
| Phiên bản | 2.0 |
| Thay đổi 2.0 | Chạy lại cho toàn hệ thống 16 use case theo P08 đến P12 bản 2.x (design/_sync-log.md, mục Đầu vào cho lần chạy lại P13; Đề xuất sửa artifact trước của P08, P09, P10, P12): gộp ba bảng nhân viên thành một bảng staff có cột role (bốn vai trò, BR-79) cộng bảng administrator một dòng (Q-271); hàm SQL immutable norm_email, norm_name và chỉ mục unique theo biểu thức cho email khách, email nhân viên, tên cụm rạp, (cụm rạp, tên phòng); cột mốc last_changed_at cho cinema, movie, auditorium, staff; staff.access_changed_at; cinema.province; movie.trailer; seat.in_seat_map và uq_seat_position từng phần; booking.customer_id cho phép NULL cùng booked_at và chỉ mục lịch sử; bốn cột giá trị lúc bán trên ticket (BR-140); showtime không có cột sức chứa; thêm trigger showtime (ST-06), seat (ST-07), cột bất biến của vé và email nhân viên, đối chiếu booking với khách của lần giữ ghế, cụm rạp phải có bảng giá lúc COMMIT; F4.5 mở rộng EX-01 đến EX-22 theo 14 hạng khoá và khoá giá trị bằng advisory lock (P09 2.0 F7.3); báo cáo đọc REPEATABLE READ READ ONLY; ERD và script DDL cập nhật; bộ ca thử mới design/P13-schema-tests.sql chạy trên PostgreSQL 16 (207 ca đạt trên 207, cộng năm kịch bản đồng thời nhiều phiên). Giữ nguyên mọi ràng buộc của luồng giữ ghế, IPN, hoàn tiền, outbox, EXCLUDE chồng giờ |
| Thay đổi 1.5 | Đồng bộ X3 lần 2 (design/_sync-log.md): lý do lưu cột seat_hold.expiry_time khớp Q-140 (hằng BR-10 cố định, giữ CHECK ck_seat_hold_expiry và ck_refund_request_attempts); dải R-nn của Dependency tới R-196; P13-schema.sql không đổi |
| Thay đổi 1.4 | Đồng bộ X3 (design/_sync-log.md): EX-01 và SQL mẫu thêm UPDATE trả Trống riêng cho ghế chọn lại của lần giữ ghế cũ, khớp P12 F3 HoldSeats (g) và IF-18.SaveChanges; cập nhật dải R-nn của Dependency; P13-schema.sql không đổi, đã chạy lại bộ ca trigger trên PostgreSQL 16 |
| Thay đổi 1.1 | Xử lý review R13D-01 đến R13D-07 (design/_review-P13.md); Q-136 đến Q-138 đã trả lời theo đề xuất của review: thêm cột tài khoản cho ba bảng nhân viên, cột danh mục cho cinema và movie, giữ toàn bộ dữ liệu lịch sử; thêm C-22; ghi rõ hệ quả của fk_ticket_seat_status lên việc đổi phòng (C-19); DDL đã chạy thật trên PostgreSQL 16 |
| Thay đổi 1.2 | Đối chiếu Đề xuất sửa artifact trước với P12 1.2 và P09: ghi trạng thái từng dòng (Chờ P12, Không cần sửa, Chưa áp dụng) |
| Thay đổi 1.3 | Xử lý review cuối (design/_review-final.md): C-19 và F4.5 EX-13 theo BR-92, R13D-01 đánh dấu Đã áp dụng (RF-02); SQL claim từng dòng và hàng rào claim_token (RF-01); seat_event ghi sau cùng bằng nextval (RF-12); lý do ngoại lệ lọc status của EX-13, EX-14 và thứ tự đọc vé trước khoá hạng 6 (RF-11); gateway_transaction_no chỉ ghi khi báo thành công (RF-13); email hoàn tiền chỉ cho FULL (RF-03); đóng Vấn đề còn mở 1 (RF-15); P13-schema.sql không đổi; đồng bộ đầu vào đã dùng (RF-06) |
| Đầu vào đã dùng | 00-Conventions.md; 00-Concurrency.md (M8); project-profile.md; P12-class-design.md 2.1 (F1, F1b, F5, F6, F7, Câu hỏi mở, Giả định, Đề xuất sửa artifact trước) và các file design/P12-class-design/*.md (PKG-16-PKG-27 1.1, PKG-17-PKG-18-PKG-30-PKG-33 2.1, PKG-19-PKG-32 1.1, PKG-05-PKG-10-PKG-20-PKG-23-PKG-29-PKG-31 1.1, PKG-11 1.1: F1, F6, F7, Đề xuất sửa artifact trước); P08-analysis-model.md 2.1 (F3, F4a, F4b, bảng quan hệ R-01 đến R-101); P09-architecture.md 2.1 (F7.2, F7.3, F7.11, F7.12); P10-design-elements.md 2.1 (Đề xuất sửa artifact trước); P05-glossary.md 1.2 (miền giá trị loại phòng, loại ghế, định dạng); P04-uc-specs/_BR-register.md (đã gộp BR-01 đến BR-147) và P04 UC-010, UC-011, UC-012 (miền giá trị, độ dài); P06-supplementary-spec.md 1.4 (NFR-04 đến NFR-10, khối lượng); design/_sync-log.md (mục Đầu vào cho lần chạy lại P13) |
| Phạm vi | Toàn hệ thống 16 use case: 20 bảng. Lõi giữ ghế, thanh toán, huỷ vé, soát vé (10 bảng cộng seat_event, outbox); danh mục và vận hành rạp (cinema, auditorium, seat, movie, price_list, price_entry và hai bảng định dạng); tài khoản (customer, staff, administrator). Mã TBL-11 và TBL-12 không còn dùng (gộp vào TBL-08), mã không cấp lại; TBL-22 là bảng mới |
| Mã Q, ASM cuối đã cấp | Q-138 của P13 (Q-136 đến Q-138 đã trả lời, Q-136 được thay bởi quyết định gộp bảng staff theo P08 Q-228 và P12 Q-271); không cấp Q mới; không có ASM (NGHIEM_NGAT) |

Trọng tâm: biến các lớp persistent của P12 thành lược đồ PostgreSQL mà bản thân CSDL đã chặn được các trạng thái sai do race condition, kể cả khi lớp dịch vụ quên khoá. Khoá ở ứng dụng (14 hạng từ 0 đến 13 của P08 F4b, P09 F7.3, gồm khoá dòng và khoá tư vấn theo giá trị) quyết định ai chờ ai; lược đồ này là lớp thứ hai, gồm bảy nhóm lưới an toàn: (1) mỗi ghế của một suất chiếu có đúng một dòng seat_status với tối đa một liên kết hiện tại, liên kết ghép với lần giữ ghế hoặc vé cùng suất chiếu, cùng ràng buộc CHECK khớp trạng thái; (2) unique từng phần cho vé chưa huỷ mỗi ghế và lần giữ ghế đang giữ mỗi người; (3) EXCLUDE chặn hai suất chiếu chồng giờ cùng phòng; (4) trigger chặn rời khỏi trạng thái cuối, đi sai đồ thị chuyển (lần giữ ghế, trạng thái ghế, vé, giao dịch, hoàn tiền, hàng đợi, suất chiếu, ghế trong sơ đồ) và ghi đè liên kết hiện tại của ghế; (5) unique cho mã giao dịch, khoá chống hoàn trùng, một lần đặt mỗi lần giữ ghế; (6) chỉ mục unique theo biểu thức norm_email, norm_name cho các giá trị trải qua cả tập (email khách, email nhân viên, tên cụm rạp, tên phòng trong cụm rạp) kèm CHECK vai trò và cụm rạp của nhân viên; (7) bảng seat_event và outbox với chỉ mục phục vụ phát sự kiện, dọn hết hạn và claim. F4.5 ánh xạ từng EX-01 đến EX-22 sang câu lệnh khoá trên bảng cụ thể; F6.4 liệt kê mọi lưới an toàn kèm kẻ thù mà nó chặn.

Kết quả: 20 bảng, 130 cột, 60 ràng buộc CHECK có tên, 1 ràng buộc EXCLUDE, 23 khoá ngoại, 27 câu CREATE INDEX (15 chỉ mục thường, 12 chỉ mục unique, trong đó 4 theo biểu thức và 8 từng phần) cộng 12 ràng buộc UNIQUE, 13 trigger, 3 hàm SQL IMMUTABLE (norm_email, norm_name, showtime_busy_range) và 5 hàm trigger. Mô hình khái niệm có 19 thực thể và 25 mối quan hệ.

## F1. Quyết định loại CSDL

| Hạng mục | Quyết định | Căn cứ (NFR / P09 / CONG_NGHE) |
|---|---|---|
| Loại CSDL | Quan hệ, một CSDL, ghi tại một node chính | P09 F7.2: cần giao dịch, khoá dòng, ràng buộc unique, bảng sự kiện và hàng đợi; NoSQL bị loại vì EX-01 đến EX-09 là giao dịch nhiều đối tượng |
| Hệ quản trị | PostgreSQL 15 trở lên, extension btree_gist; cơ sở dữ liệu bộ mã UTF-8 với locale hạ được chữ hoa có dấu tiếng Việt (ví dụ en_US.utf8, không dùng locale C) và không đổi locale sau khi đã có dữ liệu, vì chỉ mục theo biểu thức norm_email, norm_name phụ thuộc lower() của locale | P09 F11 (đã cập nhật vào project-profile.md mục 3); btree_gist cho EXCLUDE trên (phòng chiếu, khoảng thời gian); P09 F7.3 (đã kiểm trên PostgreSQL 16: "Cụm Á" và "cụm  Á " cho cùng giá trị chuẩn hoá) |
| Mức cô lập | READ COMMITTED cho mọi giao dịch ghi; mỗi giao dịch giữ ghế đặt lock_timeout 1 giây bằng SET LOCAL. Báo cáo UC-015, UC-016 là giao dịch BEGIN ISOLATION LEVEL REPEATABLE READ READ ONLY để mọi câu của một báo cáo thấy cùng một ảnh chụp (không giữ khoá, không lỗi tuần tự hoá) | P09 F7.3: SERIALIZABLE bị loại vì 1.000 giao dịch tranh một suất chiếu (NFR-05, NFR-06); P09 F7.12 |
| Chiến lược khoá chính | Khoá thay thế BIGINT GENERATED BY DEFAULT AS IDENTITY cho thực thể độc lập (khớp kiểu int64 của DC-TicketingIds, DC-CinemaIds; mã phim, cụm rạp, khách, nhân viên cũng là cột IDENTITY, P09 F7.3 EX-16); khoá ghép cho SeatStatus (showtime_id, seat_id), PriceList (cinema_id, dùng chung khoá với Cinema), PriceEntry (cinema_id cộng bốn yếu tố tổ hợp) và bảng thuộc tính đa trị; bảng administrator có id cố định 1 (một dòng). BY DEFAULT để X2 nạp được dữ liệu kiểm thử có mã cố định | P12 0.2, F1b; Conventions C1 mục 7 |
| Khoá tự nhiên | email khách và email nhân viên (unique theo norm_email), phone_number, tên cụm rạp (unique theo norm_name), (cụm rạp, tên phòng) (unique theo norm_name), booking_code, ticket_code, code của giao dịch, idempotency_key, hold_ref, request_id giữ UNIQUE, không làm khoá chính vì dài hoặc có thể đổi | Prompt P13 F4 quy ước chung; P09 F7.3 |
| Quy ước tên | Bảng số ít snake_case; khoá chính tên id; khoá ngoại tên theo bảng cha (customer_id); ràng buộc pk_, fk_<con>_<cha>, uq_, ck_, ex_; chỉ mục ix_ hoặc uq_ khi unique; trigger trg_<bảng>_<cột>; hàm fn_ (trigger) và norm_ (chuẩn hoá) | NGON_NGU_TEN_PHAN_TU của hồ sơ |
| Chuẩn hoá giá trị so trùng | Hai hàm SQL IMMUTABLE: norm_email(v) = lower(btrim(v)) và norm_name(v) = lower(btrim(gộp mọi dãy khoảng trắng thành một dấu cách)); dùng đúng một định nghĩa này ở chỉ mục unique theo biểu thức, câu kiểm trùng và khoá tư vấn pg_advisory_xact_lock(1000 + hạng, hashtext(giá trị chuẩn hoá)); số điện thoại có định dạng cố định (BR-82) nên so nguyên giá trị. Không có bảng khoá giá trị | P09 F7.3 (khoá theo giá trị hạng 0, 11 đến 13), Q-265, Q-266 |
| Mốc thay đổi | Cột last_changed_at TIMESTAMPTZ (micro giây, so bằng nhau) cho showtime, price_entry, cinema, movie, auditorium, staff để từ chối bên ghi nhận sau (BR-54, BR-63, BR-102, BR-138, BR-142, BR-146); cột access_changed_at của staff là mốc truy cập (BR-101, P09 F7.11). Mốc lấy từ đồng hồ CSDL của giao dịch ghi, so sánh ở ứng dụng dưới khoá hạng tương ứng; CSDL chỉ bảo đảm NOT NULL | P09 F7.2, F7.11 |
| Kiểu tiền | BIGINT, đơn vị đồng, số nguyên (không dấu phẩy động) | P12 DC-Money (int64 đồng), BR-70 |
| Kiểu thời gian | TIMESTAMPTZ; mọi so sánh nghiệp vụ lấy đồng hồ CSDL một lần mỗi giao dịch | P09 F7.2 |
| Enumeration | VARCHAR kèm CHECK; không có bảng danh mục vì tập giá trị cố định và không ai thêm giá trị | P13 F2 lỗi thường gặp |
| Xoá dữ liệu | Không xoá cứng bản ghi nghiệp vụ: mọi khoá ngoại ON DELETE RESTRICT, kể cả phòng chiếu --> cụm rạp, suất chiếu --> phòng chiếu và phim, ghế --> phòng chiếu (lưới an toàn của EX-19, BR-147); xoá suất chiếu là xoá mềm (status DELETED, BR-58), ghế bỏ khỏi sơ đồ là xoá mềm (in_seat_map FALSE, BR-118), tài khoản nhân viên chỉ khoá (BR-96). Xoá cứng chỉ có ở EX-19 (phòng chưa từng có suất chiếu cùng ghế của nó) và EX-13, EX-15 (seat_status của suất chiếu chưa từng có vé hoặc chưa mở bán). CASCADE chỉ cho composition PriceList - PriceEntry, hai bảng thuộc tính đa trị | BR-58, BR-118, BR-147, P13 F4.2 |
| Bảng cơ chế | seat_event và outbox không khai báo khoá ngoại để không sinh khoá ngầm lên dòng cha | P09 F7.3 |
| Khối lượng (NFR-04) | 15 cụm rạp, 4 đến 12 phòng mỗi cụm, 50 đến 400 ghế mỗi phòng, khoảng 500 suất chiếu mỗi ngày: seat_status tối đa 200.000 dòng mỗi ngày (500 suất x 400 ghế), khoảng 73 triệu dòng mỗi năm nếu giữ hết; seat_event chỉ giữ 10 phút; seat_hold, ticket, payment_transaction tăng theo lượng bán. Giữ toàn bộ, không phân vùng, không dọn (Q-138 đã trả lời; hướng lưu trữ cho sản phẩm thật ở Vấn đề còn mở 4) | P06 NFR-04, NFR-05; P09 F7.5 điểm 6 |
| Phạm vi dữ liệu mỗi loại | Chỉ có một loại (quan hệ); không dùng JSON cho dữ liệu nghiệp vụ, trừ cột items của seat_event là tải trọng của một sự kiện (F5.3) | P13 F1 lỗi thường gặp |

## F2. Bảng lớp persistent và chiến lược ánh xạ

Lớp persistent là lớp có Persistent = Có ở P12 F1 (lõi và các file PKG-16-PKG-27, PKG-19-PKG-32), cộng các lớp entity của P08 mà P12 chỉ nêu tên ở file lõi nhưng chi tiết hoá ở các file package (DC-Cinema, DC-Auditorium, DC-Seat, DC-Movie, DC-PriceEntry, DC-Staff và ba lớp con). Hai kiểu giá trị DC-SeatChangeEvent và DC-OutboxEntry (Persistent = Không ở P12) được lưu bằng bảng cơ chế do P09 F7.5 và F7.7 yêu cầu; DC-AdministratorAccount (value object, một dòng do cài đặt tạo, Q-271) lưu bằng bảng riêng. Thứ tự TBL theo thứ tự các hàng dưới đây; TBL-11 và TBL-12 của bản 1.x không còn dùng và không cấp lại.

| DC | Persistent | Thực thể (E-) | TBL | Chiến lược | Lý do |
|---|---|---|---|---|---|
| DC-SeatHold | Có | E-SeatHold | TBL-01 | Một lớp - một bảng | Entity lõi, ST-01 |
| DC-SeatStatus | Có | E-SeatStatus | TBL-02 | Một lớp - một bảng, khoá ghép | Định danh bởi cặp (Showtime, Seat) theo F4.2; ST-02 |
| DC-PaymentTransaction | Có | E-PaymentTransaction | TBL-03 | Một lớp - một bảng | ST-05 |
| DC-RefundRequest | Có | E-RefundRequest | TBL-04 | Một lớp - một bảng | ST-04; ba loại hoàn gộp một bảng vì cùng vòng đời |
| DC-Booking | Có | E-Booking | TBL-05 | Một lớp - một bảng | /channel và /buyerId là thuộc tính dẫn xuất nên không lưu; customer_id lưu (R-65) và booked_at lưu (P12 DC-Booking.bookedAt) |
| DC-Ticket | Có | E-Ticket | TBL-06 | Một lớp - một bảng | ST-03; mã QR dựng từ ticket_code nên không lưu; bốn giá trị lúc bán (BR-140) lưu |
| DC-Customer | Có | E-Customer | TBL-07 | Một lớp - một bảng | P12 PKG-28, AC-E-Customer |
| DC-Staff | Có | E-Staff | TBL-08 | Class table rút gọn thành single table (F4.3): một bảng staff | Lớp cha của ba lớp con theo vai trò (R-67 đến R-69); lớp con không có thuộc tính riêng; quản lý chuỗi là giá trị role không có lớp con |
| DC-BoxOfficeClerk | Có | E-BoxOfficeClerk | TBL-08 | Single table: dòng staff có role BOX_OFFICE_CLERK | R-67; seat_hold.box_office_clerk_id trỏ tới staff.id |
| DC-TicketChecker | Có | E-TicketChecker | TBL-08 | Single table: dòng staff có role TICKET_CHECKER | R-68 |
| DC-CinemaManager | Có | E-CinemaManager | TBL-08 | Single table: dòng staff có role CINEMA_MANAGER | R-69 |
| DC-Showtime | Có | E-Showtime | TBL-09 | Một lớp - một bảng | /cinemaId là dẫn xuất (join qua phòng chiếu) nên không lưu; sức chứa không lưu, đếm từ seat_status (P08 R-44, BR-118) |
| DC-PriceList | Có | E-PriceList | TBL-10 | Một lớp - một bảng, chỉ có khoá | Cần một dòng làm đích khoá hạng 1; chia khoá với Cinema (R-40 là 1 - 1) |
| DC-Cinema | Có | E-Cinema | TBL-13 | Một lớp - một bảng | P12 PKG-27; thêm province, last_changed_at |
| DC-Auditorium | Có | E-Auditorium | TBL-14 | Một lớp - một bảng; supportedFormats sang TBL-19 | P12 PKG-27; sức chứa đếm từ bảng seat (không lưu), thêm last_changed_at |
| DC-Seat | Có | E-Seat | TBL-15 | Một lớp - một bảng | P12 PKG-27; seatPosition thành hai cột row_code và seat_number; mapState (ST-07) thành cột BOOLEAN in_seat_map |
| DC-Movie | Có | E-Movie | TBL-16 | Một lớp - một bảng; releaseFormats sang TBL-18 | P12 PKG-27; thêm trailer, last_changed_at; /movieCode dẫn xuất từ id nên không lưu |
| DC-PriceEntry | Có | E-PriceEntry | TBL-17 | Một lớp - một bảng, bộ phận của composition R-41 | Khoá chính ghép chính là ràng buộc BR-62 |
| DC-Movie.releaseFormats | Thuộc tính đa trị của lớp persistent | - | TBL-18 | Bảng thuộc tính đa trị | 1NF: định dạng 2D, 3D là tập giá trị đơn (BR-47) |
| DC-Auditorium.supportedFormats | Thuộc tính đa trị của lớp persistent | - | TBL-19 | Bảng thuộc tính đa trị | 1NF (BR-48) |
| DC-SeatChangeEvent | Không (value object); lưu bằng bảng cơ chế | - | TBL-20 | Bảng cơ chế seat_event | P09 F7.5: thay NOTIFY bằng bảng sự kiện để commit không bị tuần tự hoá |
| DC-OutboxEntry | Không (value object); lưu bằng bảng cơ chế | - | TBL-21 | Bảng cơ chế outbox | P09 F7.7: hàng đợi gửi hoàn tiền và email, ghi cùng giao dịch nguồn |
| DC-AdministratorAccount | Không (value object); lưu bằng bảng riêng | E-AdministratorAccount | TBL-22 | Một lớp - một bảng, chỉ một dòng | Q-271, NFR-12: tài khoản có sẵn khi cài đặt, không thuộc bốn vai trò của BR-79 nên ngoài staff, không có mốc truy cập (P09 F7.11) |
| DC-BookTicketsService, DC-SeatMapService, DC-HoldExpiryJob, DC-SeatReleaseJob, DC-PaymentReportService, DC-RefundService, DC-RefundOutboxJob, DC-CancelTicketService, DC-CheckTicketService, DC-ScheduleShowtimesService, DC-ManagePriceListService, DC-ManageStaffAccountsService, DC-RegisterAccountService, DC-LoginService, DC-AccessCheckService, DC-BrowseMoviesService, DC-BrowseShowtimesService, DC-ViewBookingHistoryService, các lớp dịch vụ UC-010 đến UC-017 và báo cáo | Không | - | - | Không ánh xạ | Lớp «service» (control), không giữ dữ liệu sau khi chương trình kết thúc |
| DC-ReportPeriod, DC-ReportGroup (P08 F2c, PKG-33) | Không | - | - | Không ánh xạ | Entity phân tích không lưu: số liệu báo cáo tính tại lúc xem, không bảng tổng hợp (BR-117, P09 F7.12) |
| DC-PaymentCallbackController, các controller và form của PKG-11 | Không | - | - | Không ánh xạ | «boundary» |
| DC-PgUnitOfWork, DC-PgTx, DC-LockOrderGuard, DC-ConnectionPools, DC-SeatEventWriter, DC-PgSeatEventStore, DC-PgOutboxStore, DC-PgTicketingStore, DC-PgCinemaOperationsStore | Không | - | - | Không ánh xạ | Lớp hạ tầng truy cập dữ liệu: chúng đọc và ghi các bảng trên chứ không là dữ liệu; khoá giá trị dùng khoá tư vấn nên không có bảng khoá giá trị |
| DC-PaymentGatewayManager, DC-PaymentReportReceiver, DC-VnpayUrlBuilder, DC-VnpayRefundClient, DC-VnpaySigner, DC-VnpayReportDecoder, DC-GatewayConfig | Không | - | - | Không ánh xạ | Tích hợp cổng; cấu hình đọc từ môi trường, không lưu khoá ký hay thông tin thẻ (NFR-10) |
| DC-SeatEventHubManager, DC-SeatEventPoller, DC-SeatReplayReader, DC-SubscriberRegistry, DC-SubscriberQueue, DC-EmittedEventTracker, DC-JobSchedulerManager, DC-JobRegistry, DC-JobLoop, DC-RandomCodeGenerator, DC-SessionClaims và các kiểu của PKG-26, PKG-31 | Không | - | - | Không ánh xạ | Trạng thái chỉ tồn tại trong bộ nhớ của tiến trình hoặc trong mã phiên tự kiểm chứng (P09 F7.8, F7.11: không có entity phiên) |
| IF-01 đến IF-43 | Không | - | - | Không ánh xạ | Interface |
| Các kiểu phụ trợ còn lại của P12 F1b (DC-Money, DC-SeatKey, DC-HolderRef, DC-StaffRole, DC-StaffStatus, DC-SeatMapState, enumeration, ngoại lệ, ...) | Không | - | - | Không ánh xạ riêng | Value object thành cột (Money thành BIGINT, HolderRef thành hai khoá ngoại customer_id và box_office_clerk_id, SeatKey thành khoá ghép); enumeration thành CHECK (StaffRole, StaffStatus, AgeRating, ...); SeatMapState thành BOOLEAN in_seat_map |

Cây kế thừa persistent: một cây (Staff với ba lớp con), ánh xạ ở F4.3.

## F3. Mô hình khái niệm (ER)

### F3.1. Thực thể

| E | Tên thực thể | Mô tả | Định danh | Thuộc tính (định danh gạch chân trong sơ đồ) | Thực thể yếu | Nguồn DC |
|---|---|---|---|---|---|---|
| E-Customer | Khách | Tài khoản khách đặt vé trực tuyến | id | id (định danh); email; phoneNumber; passwordHash | Không | DC-Customer |
| E-Staff | Nhân viên | Tài khoản nhân viên của chuỗi; vai trò là một trong bốn giá trị của role (BR-79) | id | id (định danh); email; fullName; passwordHash; role; status; lastChangedAt; accessChangedAt | Không | DC-Staff |
| E-BoxOfficeClerk | Nhân viên quầy | Nhân viên có vai trò bán vé và huỷ vé tại quầy của một cụm rạp | id (kế thừa E-Staff) | Không có thuộc tính riêng; dùng thuộc tính của E-Staff | Không | DC-BoxOfficeClerk |
| E-TicketChecker | Nhân viên soát vé | Nhân viên có vai trò soát vé của một cụm rạp | id (kế thừa E-Staff) | Không có thuộc tính riêng; dùng thuộc tính của E-Staff | Không | DC-TicketChecker |
| E-CinemaManager | Quản lý cụm rạp | Nhân viên có vai trò quản lý bảng giá, lịch chiếu, phòng chiếu của một cụm rạp | id (kế thừa E-Staff) | Không có thuộc tính riêng; dùng thuộc tính của E-Staff | Không | DC-CinemaManager |
| E-AdministratorAccount | Quản trị viên | Tài khoản quản trị viên duy nhất do cài đặt tạo, ngoài tập nhân viên (Q-271) | id | id (định danh); email; passwordHash | Không | DC-AdministratorAccount |
| E-SeatHold | Lần giữ ghế | Việc giữ tạm một nhóm ghế của một suất chiếu cho một người giữ trong 10 phút | id | id (định danh); holdRef; requestId; status; holdTime; expiryTime | Không | DC-SeatHold |
| E-PaymentTransaction | Giao dịch thanh toán | Một lần khách thanh toán qua cổng cho một lần giữ ghế | id | id (định danh); code; amount; status; gatewayTransactionNo; paidAt; lateReason; refundedTotal; duplicateReportCount | Không | DC-PaymentTransaction |
| E-RefundRequest | Yêu cầu hoàn tiền | Yêu cầu hoàn toàn bộ, hoàn một vé qua cổng hoặc hoàn một vé bằng tiền mặt | id | id (định danh); idempotencyKey; requestType; refundAmount; attemptCount; status; refundResult | Không | DC-RefundRequest |
| E-Cinema | Cụm rạp | Cụm rạp của chuỗi, gồm nhiều phòng chiếu | id | id (định danh); name; province; address; lastChangedAt | Không | DC-Cinema |
| E-Showtime | Suất chiếu | Một lượt trình chiếu một phim trong một phòng chiếu | id | id (định danh); startTime; saleOpenTime; endTime; lastChangedAt; movieFormat; status; cinemaId (dẫn xuất) | Không | DC-Showtime |
| E-Booking | Lần đặt | Lần đặt vé phát sinh từ một lần giữ ghế đã hoàn tất | id | id (định danh); bookingCode; bookedAt; channel (dẫn xuất); buyerId (dẫn xuất) | Không | DC-Booking |
| E-Ticket | Vé | Vé của đúng một ghế trong một suất chiếu, mang giá trị lúc bán (BR-140) | id | id (định danh); ticketCode; price; movieTitle; cinemaName; auditoriumName; auditoriumType; status | Không | DC-Ticket |
| E-Auditorium | Phòng chiếu | Phòng chiếu của một cụm rạp | id | id (định danh); name; auditoriumType; supportedFormats (đa trị); lastChangedAt | Không | DC-Auditorium |
| E-SeatStatus | Trạng thái ghế | Tình trạng của một ghế trong một suất chiếu | định danh bởi Showtime và Seat | state; heldPrice | Có | DC-SeatStatus |
| E-Seat | Ghế | Vị trí ngồi trong một phòng chiếu; ghế bỏ khỏi sơ đồ vẫn được giữ (BR-118) | id | id (định danh); rowCode; seatNumber; seatType; inSeatMap | Không | DC-Seat |
| E-Movie | Phim | Phim của chuỗi; tên được trùng, phân biệt bằng mã phim (Q-200) | id | id (định danh); title; releaseFormats (đa trị); durationMinutes; releaseDate; endOfRunDate; genre; ageRating; description; trailer; lastChangedAt; movieCode (dẫn xuất) | Không | DC-Movie |
| E-PriceList | Bảng giá | Bảng giá riêng của một cụm rạp | định danh bởi Cinema | entryChangeTimes (dẫn xuất) | Có | DC-PriceList |
| E-PriceEntry | Mục giá | Giá vé của một tổ hợp loại phòng, định dạng, loại ghế, khung giờ | định danh bởi PriceList và bốn yếu tố tổ hợp | auditoriumType (định danh riêng phần); movieFormat (định danh riêng phần); seatType (định danh riêng phần); timeBand (định danh riêng phần); ticketPrice; lastChangedAt; removed | Có | DC-PriceEntry |

### F3.2. Mối quan hệ

| ER | Tên mối quan hệ | Thực thể A | Thực thể B | Bản số (A - B) | Tham gia A, B | Thuộc tính của mối quan hệ | Nguồn R (P12, P08) |
|---|---|---|---|---|---|---|---|
| ER-01 | gồm | E-Cinema | E-Auditorium | 1:N | A tuỳ chọn, B bắt buộc | - | R-38 |
| ER-02 | gồm | E-Auditorium | E-Seat | 1:N | A bắt buộc, B bắt buộc | - | R-39 |
| ER-03 | có (xác định thực thể yếu) | E-Cinema | E-PriceList | 1:1 | A bắt buộc, B bắt buộc | - | R-40 |
| ER-04 | gồm (xác định thực thể yếu) | E-PriceList | E-PriceEntry | 1:N | A tuỳ chọn, B bắt buộc | - | R-41 |
| ER-05 | tổ chức | E-Auditorium | E-Showtime | 1:N | A tuỳ chọn, B bắt buộc | - | R-42 |
| ER-06 | chiếu | E-Showtime | E-Movie | N:1 | A bắt buộc, B tuỳ chọn | - | R-43 |
| ER-07 | gồm (xác định thực thể yếu) | E-Showtime | E-SeatStatus | 1:N | A bắt buộc, B bắt buộc | - | R-44 |
| ER-08 | có tình trạng (xác định thực thể yếu) | E-Seat | E-SeatStatus | 1:N | A tuỳ chọn, B bắt buộc | - | R-45 |
| ER-09 | nhận | E-Showtime | E-SeatHold | 1:N | A tuỳ chọn, B bắt buộc | - | R-46 |
| ER-10 | giữ ghế | E-Customer | E-SeatHold | 1:N | A tuỳ chọn, B tuỳ chọn | - | R-48 (xor với ER-11) |
| ER-11 | giữ ghế | E-BoxOfficeClerk | E-SeatHold | 1:N | A tuỳ chọn, B tuỳ chọn | - | R-49 (xor với ER-10) |
| ER-12 | phát sinh | E-SeatHold | E-PaymentTransaction | 1:N | A tuỳ chọn, B bắt buộc | - | R-50 |
| ER-13 | dẫn tới | E-SeatHold | E-Booking | 1:1 | A tuỳ chọn, B bắt buộc | - | R-51 |
| ER-14 | gồm | E-Booking | E-Ticket | 1:N | A bắt buộc, B bắt buộc | - | R-52 |
| ER-15 | đã chiếm | E-Ticket | E-SeatStatus | N:1 | A bắt buộc, B tuỳ chọn | - | R-54 (lịch sử) |
| ER-16 | thuộc | E-Ticket | E-Showtime | N:1 | A bắt buộc, B tuỳ chọn | - | R-53 (suy ra được qua ER-15 và ER-07) |
| ER-17 | đang giữ | E-SeatHold | E-SeatStatus | 1:N | A tuỳ chọn, B tuỳ chọn | - | R-63 (hiện tại; R-47 lịch sử hiện thực bằng quan hệ này) |
| ER-18 | đang chiếm | E-Ticket | E-SeatStatus | 1:1 | A tuỳ chọn, B tuỳ chọn | - | R-64 (hiện tại) |
| ER-19 | sinh ra | E-PaymentTransaction | E-RefundRequest | 1:N | A tuỳ chọn, B tuỳ chọn | - | R-55 |
| ER-20 | được hoàn bởi | E-Ticket | E-RefundRequest | 1:1 | A tuỳ chọn, B tuỳ chọn | - | R-56 |
| ER-24 | tuyển | E-Cinema | E-Staff | 1:N | A tuỳ chọn, B tuỳ chọn | - | R-66 (thay R-57 đến R-59; quản lý chuỗi không thuộc cụm rạp nào) |
| ER-25 | đặt | E-Customer | E-Booking | 1:N | A tuỳ chọn, B tuỳ chọn | - | R-65 (lần đặt tại quầy không thuộc khách nào) |
| ER-26 | là | E-BoxOfficeClerk | E-Staff | 1:1 | A bắt buộc, B tuỳ chọn | - | R-67 (kế thừa) |
| ER-27 | là | E-TicketChecker | E-Staff | 1:1 | A bắt buộc, B tuỳ chọn | - | R-68 (kế thừa) |
| ER-28 | là | E-CinemaManager | E-Staff | 1:1 | A bắt buộc, B tuỳ chọn | - | R-69 (kế thừa) |

R-47 (SeatHold 0..* - SeatStatus 1..8, lịch sử) không có mối quan hệ riêng: P12 hiện thực khi Đang giữ bằng R-63 (ER-17). Dependency trong P12 (R-60 đến R-62 và mọi dải R-nn từ R-160 trở đi) và association tiêm phụ thuộc giữa lớp service, interface không phải mối quan hệ dữ liệu nên không vào mô hình ER. Quản lý chuỗi không có thực thể riêng: là giá trị role của E-Staff (P08 F2a STT 41). ER-21 đến ER-23 của bản 1.x (tuyển nhân viên theo ba vai trò) nay là ER-24 (Cinema - Staff, R-66); mã ER-21 đến ER-23 không dùng lại.

## F4. Mô hình logic (CSDL quan hệ)

### F4.1. Lược đồ quan hệ

| TBL | Tên bảng | Lược đồ (PK ghi trước, đánh dấu PK:, FK:) | Khoá ứng viên khác | Nguồn (E / DC) |
|---|---|---|---|---|
| TBL-01 | seat_hold | seat_hold(PK: id, FK: showtime_id, FK: customer_id, FK: box_office_clerk_id, hold_ref, request_id, status, hold_time, expiry_time) | (hold_ref); (request_id); (customer_id) WHERE status = 'ACTIVE'; (box_office_clerk_id) WHERE status = 'ACTIVE' | E-SeatHold / DC-SeatHold |
| TBL-02 | seat_status | seat_status(PK: FK: showtime_id, PK: FK: seat_id, state, held_price, FK: current_hold_id, FK: current_ticket_id, event_seq) | (current_ticket_id) WHERE current_ticket_id IS NOT NULL | E-SeatStatus / DC-SeatStatus |
| TBL-03 | payment_transaction | payment_transaction(PK: id, FK: seat_hold_id, code, amount, status, gateway_transaction_no, paid_at, late_reason, refunded_total, duplicate_report_count) | (code); (seat_hold_id) WHERE status = 'TICKETED'; (gateway_transaction_no) WHERE gateway_transaction_no IS NOT NULL | E-PaymentTransaction / DC-PaymentTransaction |
| TBL-04 | refund_request | refund_request(PK: id, FK: payment_transaction_id, FK: ticket_id, idempotency_key, request_type, refund_amount, attempt_count, status, refund_result) | (ticket_id); (idempotency_key); (payment_transaction_id) WHERE request_type = 'FULL' | E-RefundRequest / DC-RefundRequest |
| TBL-05 | booking | booking(PK: id, booking_code, FK: seat_hold_id, FK: customer_id, booked_at) | (booking_code); (seat_hold_id) | E-Booking / DC-Booking |
| TBL-06 | ticket | ticket(PK: id, FK: booking_id, FK: showtime_id, FK: seat_id, ticket_code, price, movie_title, cinema_name, auditorium_name, auditorium_type, status) | (ticket_code); (showtime_id, seat_id) WHERE status <> 'CANCELLED' | E-Ticket / DC-Ticket |
| TBL-07 | customer | customer(PK: id, email, phone_number, password_hash) | (norm_email(email)); (phone_number) | E-Customer / DC-Customer |
| TBL-08 | staff | staff(PK: id, email, full_name, password_hash, role, FK: cinema_id, status, last_changed_at, access_changed_at) | (norm_email(email)) | E-Staff, E-BoxOfficeClerk, E-TicketChecker, E-CinemaManager / DC-Staff và ba lớp con |
| TBL-09 | showtime | showtime(PK: id, FK: auditorium_id, FK: movie_id, start_time, sale_open_time, end_time, last_changed_at, movie_format, status) | Không có (chống chồng giờ bằng EXCLUDE, không phải khoá) | E-Showtime / DC-Showtime |
| TBL-10 | price_list | price_list(PK: FK: cinema_id) | Không có | E-PriceList / DC-PriceList |
| TBL-13 | cinema | cinema(PK: id, name, province, address, last_changed_at) | (norm_name(name)) | E-Cinema / DC-Cinema |
| TBL-14 | auditorium | auditorium(PK: id, FK: cinema_id, name, auditorium_type, last_changed_at) | (cinema_id, norm_name(name)) | E-Auditorium / DC-Auditorium |
| TBL-15 | seat | seat(PK: id, FK: auditorium_id, row_code, seat_number, seat_type, in_seat_map) | (auditorium_id, row_code, seat_number) WHERE in_seat_map | E-Seat / DC-Seat |
| TBL-16 | movie | movie(PK: id, title, duration_minutes, release_date, end_of_run_date, genre, age_rating, description, trailer, last_changed_at) | Không có (tên được trùng, Q-200) | E-Movie / DC-Movie |
| TBL-17 | price_entry | price_entry(PK: FK: cinema_id, PK: auditorium_type, PK: movie_format, PK: seat_type, PK: time_band, ticket_price, last_changed_at, removed) | Không có | E-PriceEntry / DC-PriceEntry |
| TBL-18 | movie_format | movie_format(PK: FK: movie_id, PK: movie_format) | Không có | thuộc tính đa trị E-Movie.releaseFormats / DC-Movie (releaseFormats) |
| TBL-19 | auditorium_format | auditorium_format(PK: FK: auditorium_id, PK: movie_format) | Không có | thuộc tính đa trị E-Auditorium.supportedFormats / DC-Auditorium (supportedFormats) |
| TBL-20 | seat_event | seat_event(PK: id, showtime_id, created_at, items) | Không có | Không có (bảng cơ chế) / DC-SeatChangeEvent |
| TBL-21 | outbox | outbox(PK: id, kind, source_id, status, attempt_count, next_attempt_at, claim_token, claimed_until, idempotency_key, last_error, created_at) | (idempotency_key) | Không có (bảng cơ chế) / DC-OutboxEntry |
| TBL-22 | administrator | administrator(PK: id, email, password_hash) | Không có (đúng một dòng, id = 1) | E-AdministratorAccount / DC-AdministratorAccount |

### F4.2. Ánh xạ quan hệ giữa lớp

| R (P12, P08) | Loại | Multiplicity | Cách ánh xạ | FK hoặc bảng trung gian | Kiểu quan hệ dữ liệu | ON DELETE |
|---|---|---|---|---|---|---|
| R-38 | Aggregation | Cinema 1 - Auditorium 0..* | FK ở phía N | auditorium.cinema_id NOT NULL (fk_auditorium_cinema); phía 0..* vì cụm rạp mới chưa có phòng chiếu (UC-011) | độc lập | RESTRICT |
| R-39 | Composition | Auditorium 1 - Seat 50..400 | FK ở phía N. Seat có khoá thay thế id riêng vì seat_status tham chiếu ghế nên không phải quan hệ phụ thuộc, và ON DELETE là RESTRICT thay vì CASCADE: ghế bỏ khỏi sơ đồ chỉ đặt in_seat_map = FALSE (BR-118), còn xoá ghế cùng phòng do EX-19 làm tường minh (DELETE ghế rồi DELETE phòng trong một giao dịch, BR-147); sức chứa 50 đến 400 kiểm ở ứng dụng (BR-144) | seat.auditorium_id NOT NULL (fk_seat_auditorium) | độc lập | RESTRICT |
| R-40 | Association | Cinema 1 - PriceList 1 | Khoá chính của bảng phụ đồng thời là FK (1 - 1 cả hai bắt buộc, giữ bảng riêng vì PriceList là đích khoá hạng 1) | price_list.cinema_id PK, FK (fk_price_list_cinema) | phụ thuộc | RESTRICT |
| R-41 | Composition | PriceList 1 - PriceEntry 0..72 | FK nằm trong khoá chính của bộ phận | price_entry(cinema_id, ...) FK (fk_price_entry_price_list) | phụ thuộc | CASCADE |
| R-42 | Association | Auditorium 1 - Showtime 0..* | FK ở phía N | showtime.auditorium_id NOT NULL (fk_showtime_auditorium) | độc lập | RESTRICT |
| R-43 | Association | Showtime 0..* - Movie 1 | FK ở phía N | showtime.movie_id NOT NULL (fk_showtime_movie) | độc lập | RESTRICT |
| R-44 | Association | Showtime 1 - SeatStatus 50..400 | Lớp có định danh do hai lớp cha xác định: khoá chính là cặp khoá ngoại (SeatStatus có thuộc tính riêng nên là bảng trung gian); sức chứa của suất chiếu là số dòng seat_status, không có cột riêng (BR-118) | seat_status.showtime_id PK, FK (fk_seat_status_showtime) | phụ thuộc | RESTRICT (dữ liệu có giá trị lịch sử, BR-58) |
| R-45 | Association | SeatStatus 0..* - Seat 1 | Như R-44 | seat_status.seat_id PK, FK (fk_seat_status_seat) | phụ thuộc | RESTRICT |
| R-46 | Association | Showtime 1 - SeatHold 0..* | FK ở phía N | seat_hold.showtime_id NOT NULL (fk_seat_hold_showtime) | độc lập | RESTRICT |
| R-47 | Association (lịch sử) | SeatHold 0..* - SeatStatus 1..8 | Hiện thực khi Đang giữ bằng R-63; không có bảng nối (P12 Vấn đề còn mở 6) | Không áp dụng | Không áp dụng | Không áp dụng |
| R-48 | Association | SeatHold 0..* - Customer 0..1 | FK ở phía N, cho phép NULL | seat_hold.customer_id (fk_seat_hold_customer) | độc lập | RESTRICT |
| R-49 | Association | SeatHold 0..* - BoxOfficeClerk 0..1 | FK ở phía N, cho phép NULL; BoxOfficeClerk là dòng staff có role BOX_OFFICE_CLERK (R-67), nên khoá ngoại trỏ tới staff.id; {xor} với R-48 bằng ck_seat_hold_one_holder; vai trò của dòng staff kiểm ở ứng dụng (C-24) | seat_hold.box_office_clerk_id (fk_seat_hold_staff) | độc lập | RESTRICT |
| R-50 | Association | SeatHold 1 - PaymentTransaction 0..* | FK ở phía N | payment_transaction.seat_hold_id NOT NULL (fk_payment_transaction_seat_hold) | độc lập | RESTRICT |
| R-51 | Association | SeatHold 1 - Booking 0..1 | FK ở phía tuỳ chọn kèm UNIQUE | booking.seat_hold_id NOT NULL UNIQUE (fk_booking_seat_hold, uq_booking_seat_hold) | độc lập | RESTRICT |
| R-52 | Aggregation | Booking 1 - Ticket 1..8 | FK ở phía N; không phải composition vì vé đã huỷ vẫn thuộc lần đặt | ticket.booking_id NOT NULL (fk_ticket_booking) | độc lập | RESTRICT |
| R-53 | Association | Ticket 0..* - Showtime 1 | Đi cùng R-54: cột showtime_id của FK ghép tới seat_status; không có FK riêng tới showtime vì sẽ trùng (suy ra được, P12 R-53) | ticket.showtime_id (một nửa fk_ticket_seat_status) | độc lập | RESTRICT |
| R-54 | Association | Ticket 0..* - SeatStatus 1 | FK ghép ở phía N | ticket(showtime_id, seat_id) --> seat_status (fk_ticket_seat_status) | độc lập | RESTRICT |
| R-55 | Association | PaymentTransaction 0..1 - RefundRequest 0..* | FK ở phía N, cho phép NULL (hoàn tiền mặt) | refund_request.payment_transaction_id (fk_refund_request_payment_transaction) | độc lập | RESTRICT |
| R-56 | Association | Ticket 0..1 - RefundRequest 0..1 | FK ở phía N kèm UNIQUE (BR-21: mỗi vé hoàn một lần) | refund_request.ticket_id UNIQUE (fk_refund_request_ticket, uq_refund_request_ticket) | độc lập | RESTRICT |
| R-65 | Association | Customer 0..1 - Booking 0..* | FK ở phía N, cho phép NULL (lần đặt tại quầy không thuộc khách nào); là bản sao của khách giữ ghế của lần giữ ghế (R-51, R-48), nên booking.customer_id khớp seat_hold.customer_id (C-25) và nằm ở F5.3 | booking.customer_id (fk_booking_customer) | độc lập | RESTRICT |
| R-66 | Association | Staff 0..* - Cinema 0..1 | FK ở phía N, cho phép NULL (quản lý chuỗi không thuộc cụm rạp nào, BR-78); ck_staff_role_cinema ép NULL khi và chỉ khi role là CHAIN_MANAGER; thay R-57, R-58, R-59 | staff.cinema_id (fk_staff_cinema) | độc lập | RESTRICT |
| R-67, R-68, R-69 | Generalization | BoxOfficeClerk, TicketChecker, CinemaManager - Staff | Single table (F4.3): ba lớp con và lớp cha cùng một dòng staff, phân biệt bằng cột role | staff.role | Không áp dụng | Không áp dụng |
| R-63 | Association | SeatHold 0..1 - SeatStatus 0..8 | FK ghép ở phía N, cho phép NULL; ghép thêm showtime_id để lần giữ ghế hiện tại cùng suất chiếu với ghế | seat_status(current_hold_id, showtime_id) --> seat_hold(id, showtime_id) (fk_seat_status_seat_hold) | độc lập | RESTRICT |
| R-64 | Association | Ticket 0..1 - SeatStatus 0..1 | FK ghép ở phía tuỳ chọn kèm UNIQUE từng phần; ghép thêm (showtime_id, seat_id) để vé hiện tại là vé của chính ghế đó | seat_status(current_ticket_id, showtime_id, seat_id) --> ticket (fk_seat_status_ticket, uq_seat_status_current_ticket) | độc lập | RESTRICT |
| Thuộc tính đa trị releaseFormats, supportedFormats | - | Movie 1 - 1..* định dạng; Auditorium 1 - 1..* định dạng | Bảng thuộc tính đa trị, khoá chính ghép | movie_format, auditorium_format (fk_movie_format_movie, fk_auditorium_format_auditorium) | phụ thuộc | CASCADE |
| R-60, R-61, R-62 và mọi Dependency, association tiêm phụ thuộc, Realization của P12 F5 | Dependency / Association / Realization | - | Không ánh xạ thành khoá ngoại | Không áp dụng | Không áp dụng | Không áp dụng |

Ngoại lệ về việc không dùng khoá ngoại có chủ đích: showtime không có FK ghép tới movie_format và auditorium_format để ép BR-47, BR-48, vì BR-84 cho phép phim hoặc phòng chiếu đổi định dạng sau khi suất chiếu đã lập mà suất chiếu không đổi; hai quy tắc này chỉ kiểm lúc lập hoặc sửa suất chiếu (F4.4).

### F4.3. Ánh xạ generalization

Một cây kế thừa persistent: Staff (R-67 đến R-69, P08 F2a STT 41) với ba lớp con BoxOfficeClerk, TicketChecker, CinemaManager; quản lý chuỗi là giá trị thứ tư của role, không có lớp con (P12 PKG-32 DC-StaffRole, BR-79).

| Cây kế thừa (lớp cha - các lớp con) | Chiến lược | Bảng | Cột phân biệt loại | Lý do chọn |
|---|---|---|---|---|
| DC-Staff - DC-BoxOfficeClerk, DC-TicketChecker, DC-CinemaManager (và vai trò quản lý chuỗi) | Single table | staff (TBL-08) | role: BOX_OFFICE_CLERK, TICKET_CHECKER, CINEMA_MANAGER, CHAIN_MANAGER (ck_staff_role) | Ba lớp con không có thuộc tính riêng (P12 PKG-19-PKG-32 F7: "DC-CinemaManager, DC-TicketChecker không có thuộc tính riêng"), nên không có cột NULL theo loại; email phải duy nhất xuyên mọi vai trò (BR-95) và chỉ một chỉ mục unique theo biểu thức trên một bảng giữ được điều đó, còn concrete table cần ràng buộc liên bảng; mọi vai trò dùng chung đường đăng nhập, kiểm phiên theo mốc truy cập (P09 F7.11) và khoá hạng 4; đổi vai trò (UC-017 luồng 1a) là UPDATE cột role của cùng một tài khoản, không chuyển dòng giữa bảng; seat_hold chỉ cần một khoá ngoại tới staff thay vì hai. Quy tắc theo vai trò (nhân viên quầy mới giữ ghế) kiểm ở ứng dụng; ràng buộc theo loại duy nhất ở CSDL là ck_staff_role_cinema (quản lý chuỗi không có cụm rạp, ba vai trò còn lại có đúng một cụm rạp, BR-78) |

Customer và AdministratorAccount không thuộc cây này: khách và nhân viên là hai tập tài khoản độc lập (cùng email dùng được ở cả hai, Q-267), tài khoản quản trị viên nằm ngoài bốn vai trò của BR-79 (Q-271). seat_hold giữ hai khoá ngoại tuỳ chọn (customer_id, box_office_clerk_id) thay vì một khoá tới lớp cha chung vì người giữ ghế là khách hoặc nhân viên quầy, hai bảng khác nhau.

### F4.4. Ràng buộc liên bảng

| Mã | Ràng buộc | Bảng | Nguồn (BR / ST / R-nn) | Cách giữ (trigger / CHECK / unique / ứng dụng trong giao dịch) |
|---|---|---|---|---|
| C-01 | Một ghế của một suất chiếu chỉ có tối đa một lần giữ ghế hiện tại và một vé hiện tại; trạng thái ghế khớp liên kết | seat_status | BR-08, BR-09, R-63, R-64 | Cấu trúc: một dòng mỗi (suất chiếu, ghế); CHECK ck_seat_status_state_link; trigger trg_seat_status_link chặn ghi đè liên kết đang có; ứng dụng dưới khoá hạng 6 |
| C-02 | Lần giữ ghế hiện tại của ghế phải thuộc cùng suất chiếu; vé hiện tại phải là vé của chính ghế đó | seat_status | R-63, R-64 | FK ghép fk_seat_status_seat_hold, fk_seat_status_ticket |
| C-03 | Một ghế của một suất chiếu có tối đa một vé chưa huỷ | ticket | BR-09, BR-21 | UNIQUE từng phần uq_ticket_active_seat |
| C-04 | Mỗi người giữ ghế có tối đa một lần giữ ghế đang giữ, xuyên mọi suất chiếu | seat_hold | BR-04 | UNIQUE từng phần uq_seat_hold_active_customer, uq_seat_hold_active_clerk; ứng dụng khoá người giữ hạng 4 và chuyển lần giữ ghế cũ quá hạn sang EXPIRED trước khi tạo mới |
| C-05 | Một lần giữ ghế thuộc đúng một người giữ (khách hoặc nhân viên quầy) | seat_hold | R-48, R-49 {xor} | CHECK ck_seat_hold_one_holder |
| C-06 | Hai suất chiếu chưa xoá trong một phòng không chồng giờ và cách nhau ít nhất 15 phút | showtime | BR-51, BR-52 | EXCLUDE ex_showtime_auditorium_overlap; ứng dụng kiểm dưới khoá phòng chiếu hạng 2 (EX-13) |
| C-07 | Trạng thái cuối không đổi; chuyển trạng thái chỉ theo đồ thị ST-01 đến ST-05 | seat_hold, seat_status, ticket, payment_transaction, refund_request, outbox | BR-85, BR-86, BR-30, Q-79 | Trigger trg_*; ứng dụng dùng UPDATE ... WHERE status = <trạng thái nguồn> |
| C-08 | Mỗi giao dịch thanh toán thành công chỉ xử lý một lần: một mã giao dịch, một giao dịch tạo vé mỗi lần giữ ghế, một lần đặt mỗi lần giữ ghế | payment_transaction, booking | BR-37, BR-85 | UNIQUE uq_payment_transaction_code, uq_payment_transaction_ticketed_hold, uq_booking_seat_hold, uq_payment_transaction_gateway_no |
| C-09 | Tổng đã hoàn của giao dịch không vượt số đã thanh toán và chỉ giao dịch đã thanh toán mới có khoản hoàn | payment_transaction | BR-26 | CHECK ck_payment_transaction_refund_limit, ck_payment_transaction_refund_paid; ứng dụng cộng trong chính câu UPDATE (P09 F7.3 EX-09) |
| C-10 | Hoàn không trùng: một khoá chống hoàn trùng cho mỗi yêu cầu, mỗi vé một yêu cầu hoàn, mỗi giao dịch một lần hoàn toàn bộ | refund_request | BR-16, BR-21, BR-43 | UNIQUE uq_refund_request_idempotency_key, uq_refund_request_ticket, uq_refund_request_full_per_payment |
| C-11 | Loại yêu cầu hoàn khớp với liên kết giao dịch và vé | refund_request | R-55, R-56, BR-20 | CHECK ck_refund_request_link |
| C-12 | Số lần gửi hoàn tối đa 4 và khớp trạng thái | refund_request | BR-41, ST-04 | CHECK ck_refund_request_attempts, ck_refund_request_attempt_status |
| C-13 | Số ghế của một lần giữ ghế tối đa 8; mỗi lần đặt có 1 đến 8 vé | seat_status, ticket | BR-05, R-52 | Ứng dụng trong EX-01 và EX-02; không biểu diễn được bằng khoá hay CHECK một dòng |
| C-14 | Giá vé chốt: ticket.price bằng seat_status.held_price lúc bán; payment_transaction.amount bằng tổng giá các ghế khi lần giữ ghế còn Đang giữ | ticket, seat_status, payment_transaction | BR-65, BR-67 | Ứng dụng trong EX-02 (AMOUNT_MISMATCH); P12 Vấn đề còn mở 3 |
| C-15 | Số tiền hoàn của một vé bằng 70% giá vé, làm tròn xuống đồng | refund_request, ticket | BR-19, BR-31 | Ứng dụng (DC-Ticket.CalculateRefundAmount) |
| C-16 | Định dạng suất chiếu thuộc định dạng phát hành của phim và định dạng chiếu được của phòng; ngày chiếu trong khoảng chiếu của phim; giờ kết thúc bằng giờ bắt đầu cộng thời lượng | showtime, movie_format, auditorium_format, movie | BR-47, BR-48, BR-49, BR-50 | Ứng dụng khi lập hoặc sửa suất chiếu; không FK vì BR-84 (F4.2) |
| C-17 | Bảng giá phủ mọi loại ghế của phòng khi lập hoặc sửa suất chiếu; không bỏ mục giá khi còn suất chiếu chưa chiếu đang dùng | price_entry, showtime, seat | BR-59, BR-64, BR-68, BR-69, BR-72 | Ứng dụng dưới khoá hạng 1 và 2 (EX-11, EX-12, EX-13) |
| C-18 | Nhân viên chỉ thao tác trên suất chiếu, vé, phòng chiếu, bảng giá của cụm rạp mình (quản lý chuỗi xem mọi cụm rạp) | staff, showtime | BR-02, BR-22, BR-34, BR-46, BR-61, BR-135 | Ứng dụng: so staff.cinema_id của dòng đọc lại mỗi yêu cầu (P09 F7.11) với cụm rạp của suất chiếu qua phòng chiếu; CSDL chỉ ép cinema_id NULL khi và chỉ khi CHAIN_MANAGER (C-24) |
| C-19 | Chỉ sửa hoặc xoá suất chiếu khi không có lần giữ ghế đang giữ hoặc vé chưa huỷ. Đổi phòng chỉ khi suất chiếu chưa từng có vé, kể cả vé đã huỷ (BR-92, quyết định R13D-01 phương án A): đổi phòng phải thay toàn bộ seat_status của suất chiếu (mã ghế khác theo phòng), mà fk_ticket_seat_status (RESTRICT) chặn xoá dòng seat_status còn vé tham chiếu, kể cả vé đã huỷ. Suất chiếu từng có vé thì xoá mềm (EX-14, khi BR-53 cho phép) rồi lập suất mới, dữ liệu cũ vẫn giữ (BR-58) | showtime, seat_status, seat_hold, ticket | BR-53, BR-54, BR-57, BR-58, BR-92 | Ứng dụng dưới khoá hạng 3, 5, 8 (EX-13, EX-14): với đổi phòng, kiểm không có ticket nào của suất chiếu (mọi trạng thái) và báo lỗi nghiệp vụ BR-92 trước khi xoá seat_status, không để lỗi 23503 tới người dùng; fk_ticket_seat_status là lưới an toàn (23503, thử X4) |
| C-20 | Thời điểm mở bán trước giờ bắt đầu; giờ kết thúc sau giờ bắt đầu | showtime | BR-55, BR-50 | CHECK ck_showtime_sale_before_start, ck_showtime_end_after_start |
| C-21 | Thời hạn giữ ghế đúng 10 phút | seat_hold | BR-10 | CHECK ck_seat_hold_expiry |
| C-22 | Ghế của seat_status thuộc phòng chiếu của suất chiếu | seat_status, seat, showtime | R-44, R-45 | Ứng dụng: EX-13 và EX-15 tạo seat_status bằng INSERT ... SELECT từ các ghế của phòng của suất chiếu, không nhận danh sách ghế từ bên ngoài. Không thêm cột auditorium_id vào seat_status để khoá ghép kiểm: bảng này lớn nhất hệ thống (F1), thêm cột và khoá ghép chỉ để chặn đường ghi sai ngoài ứng dụng là không đáng. Ghế bỏ khỏi sơ đồ (in_seat_map FALSE) vẫn có seat_status của suất chiếu đã kết thúc hoặc đã xoá (BR-118) nên fk_seat_status_seat không CASCADE |
| C-23 | Giá trị so trùng trải qua cả tập: tên cụm rạp duy nhất trong chuỗi, tên phòng duy nhất trong cụm rạp, email khách duy nhất, email nhân viên duy nhất xuyên mọi vai trò, số điện thoại khách duy nhất; so sau chuẩn hoá (hoa thường, chữ có dấu, khoảng trắng đầu cuối và liền nhau) | cinema, auditorium, customer, staff | BR-141, BR-145, BR-98, BR-95, Q-265, Q-266 | Chỉ mục unique theo biểu thức uq_cinema_name_norm, uq_auditorium_cinema_name_norm, uq_customer_email_norm, uq_staff_email_norm và UNIQUE uq_customer_phone_number; ứng dụng lấy khoá tư vấn theo giá trị trước khi kiểm (EX-17, EX-20, EX-21; tên phòng không cần vì EX-15, EX-18 đã giữ Cinema X); chỉ mục là lưới an toàn nếu một đường ghi quên khoá (23505) |
| C-24 | Vai trò và cụm rạp của nhân viên: một trong bốn vai trò, quản lý chuỗi không có cụm rạp, ba vai trò còn lại đúng một cụm rạp; trạng thái ACTIVE hoặc LOCKED; chỉ nhân viên vai trò BOX_OFFICE_CLERK giữ ghế | staff, seat_hold | BR-78, BR-79, BR-96, R-49, R-67 | CHECK ck_staff_role, ck_staff_role_cinema, ck_staff_status; vai trò của người giữ ghế nhân viên quầy kiểm ở ứng dụng (EX-01 dưới khoá Staff hạng 4); CSDL không biểu diễn được vì vai trò của dòng staff đổi được (EX-22) trong khi lần giữ ghế cũ giữ nguyên (BR-100) |
| C-25 | booking.customer_id bằng khách của lần giữ ghế (rỗng khi người giữ là nhân viên quầy) | booking, seat_hold | R-51, R-65, BR-17, BR-94 | Trigger trg_booking_customer (INSERT và UPDATE cột customer_id, seat_hold_id); fk_booking_customer |
| C-26 | Giá trị lúc bán của vé (giá, tên phim, tên cụm rạp, tên phòng, loại phòng) có đủ và không đổi sau khi bán, kể cả khi phim, cụm rạp, phòng đổi sau đó | ticket | BR-140, BR-67 | NOT NULL, CHECK ck_ticket_auditorium_type, trigger trg_ticket_sale_values chặn UPDATE các cột này; ứng dụng sao chép lúc tạo vé (DC-Ticket, EX-02, EX-03) |
| C-27 | Ghế bỏ khỏi sơ đồ không quay lại sơ đồ; vị trí của ghế đã bỏ nhập lại thành ghế mới; hai ghế đang trong sơ đồ không cùng vị trí | seat | BR-118, ST-07, BR-144 | uq_seat_position (unique từng phần WHERE in_seat_map), trigger trg_seat_in_seat_map (chỉ TRUE sang FALSE); sức chứa 50 đến 400 đếm ghế đang trong sơ đồ ở ứng dụng (BR-144) |
| C-28 | Suất chiếu đã xoá không khôi phục (ngừng bán, dữ liệu giữ lại); suất chiếu không lưu sức chứa | showtime | BR-58, ST-06, BR-118 | Trigger trg_showtime_status (chỉ IN_SCHEDULE sang DELETED); sức chứa tính từ seat_status của suất chiếu chưa xoá (P09 F7.12) |
| C-29 | Mỗi cụm rạp có đúng một bảng giá, tạo cùng giao dịch với cụm rạp | cinema, price_list | R-40, BR-62 | Khoá chính price_list.cinema_id cùng FK (tối đa một); constraint trigger hoãn trg_cinema_has_price_list kiểm lúc COMMIT (tối thiểu một); ứng dụng INSERT cả hai trong EX-17 |
| C-30 | Chỉ xoá phòng chiếu chưa từng có suất chiếu (kể cả đã xoá) và các ghế của nó; không xoá ghế, cụm rạp, phim còn được tham chiếu | auditorium, seat, showtime, cinema, movie | BR-147, BR-136, R-38, R-39, R-42, R-43 | Mọi khoá ngoại tới cụm rạp, phòng chiếu, ghế, phim là RESTRICT (23503), nên một suất chiếu lọt vào giữa lúc kiểm và lúc xoá làm DELETE thất bại thay vì để lại suất chiếu mồ côi; ứng dụng kiểm dưới Cinema X, Auditorium X (EX-19) |
| C-31 | Chỉ có đúng một tài khoản quản trị viên | administrator | NFR-12, Q-271 | PK id kèm CHECK ck_administrator_single_row (id = 1); email chuẩn hoá hợp lệ. Email quản trị viên trùng email nhân viên không chặn được bằng chỉ mục (khác bảng): do cài đặt tạo, DC-LoginService tra staff trước, quản trị viên sau |
| C-32 | Email nhân viên không đổi sau khi tạo | staff | Q-162, P09 F7.3 EX-22 | Trigger trg_staff_email; cần vì EX-22 chỉ lấy FOR NO KEY UPDATE trên dòng staff (email không phải cột khoá nên khoá ngầm KEY SHARE của seat_hold.box_office_clerk_id không xung đột) |
| C-33 | Mốc thay đổi và mốc truy cập: từ chối bên ghi nhận sau khi mốc khác mốc lúc hiển thị; mốc truy cập khác mốc trong phiên thì phiên bị từ chối | cinema, movie, auditorium, staff, showtime, price_entry | BR-54, BR-63, BR-102, BR-138, BR-142, BR-146, BR-101 | Ứng dụng: khoá dòng (hạng tương ứng) rồi so bằng nhau ở micro giây, UPDATE đặt mốc mới từ đồng hồ CSDL lấy một lần (P09 F7.2); CSDL chỉ ép NOT NULL; không có ràng buộc biểu diễn được vì mốc lúc hiển thị chỉ có ở phía trình duyệt |
| C-34 | Báo cáo đọc một ảnh chụp thống nhất | ticket, showtime, seat_status, refund_request, payment_transaction | BR-115 đến BR-119, P09 F7.12 | Ứng dụng: giao dịch BEGIN ISOLATION LEVEL REPEATABLE READ READ ONLY; không có ràng buộc dữ liệu; ca B5 của P13-schema-tests.sql kiểm người đọc và người ghi không chặn nhau |

Đối chiếu P12 F3: các operation ghi cột trạng thái (SeatHold.Expire, Complete, Cancel, FailPayment; SeatStatus.HoldFor, MarkSold, ReleaseHold, ReleaseTicket; Ticket.Admit, Cancel; PaymentTransaction.MarkTicketed, MarkLatePayment, RecordFailure; RefundRequest.BeginAttempt, RecordResult, MarkManualRequired; Showtime.MarkDeleted theo ST-06; Seat.RetireFromSeatMap theo ST-07; Staff.LockStaff, UnlockStaff theo ST-12 không có trigger vì hai chiều) đều chỉ đi theo các cung của ST-01 đến ST-07, nên các trigger của C-07, C-27, C-28 không mâu thuẫn với P12. Một mâu thuẫn nhỏ về tên cột (amount ở P12 so với paid_amount ở P09 F7.3 EX-09) đã được P09 sửa (Đề xuất sửa artifact trước). Operation ghi giá trị lúc bán (DC-Ticket.Snapshot khi tạo vé) chỉ ghi một lần lúc INSERT nên không mâu thuẫn với trg_ticket_sale_values; DC-Staff.* không sửa email nên không mâu thuẫn với trg_staff_email.

Yêu cầu với tầng truy cập dữ liệu để các CHECK không làm hỏng giao dịch hợp lệ (CHECK kiểm tra từng câu lệnh, không hoãn được):
- Đổi trạng thái và các cột đi kèm trong cùng một câu UPDATE: seat_status (state, current_hold_id, current_ticket_id, held_price), payment_transaction (status cùng paid_at, gateway_transaction_no, late_reason, và status LATE_PAYMENT trước hoặc cùng câu với refunded_total), refund_request (status cùng attempt_count).
- INSERT ticket trước, rồi UPDATE seat_status đặt current_ticket_id (fk_seat_status_ticket kiểm vé có thật và đúng ghế); INSERT seat_hold trước, rồi UPDATE seat_status đặt current_hold_id.
- Khi trả ghế (ReleaseHold, ReleaseTicket) đặt cả state, liên kết hiện tại và held_price trong một câu UPDATE.

### F4.4a. Bất biến của P08 F4a và ràng buộc ở F4.4 (00-Concurrency.md M8 mục 1)

| EX | Bất biến giữ được | Ràng buộc ở F4.4 hoặc lý do không có |
|---|---|---|
| EX-01 | Mỗi ghế mỗi suất chiếu tối đa một lần giữ; mỗi người tối đa một lần giữ đang giữ; nhân viên quầy còn hiệu lực | C-01, C-02, C-04, C-05; còn hiệu lực của phiên là so mốc ở ứng dụng (C-33, C-24) |
| EX-02, EX-03 | Một lần thanh toán thành công chỉ tạo vé một lần; bán ghế đúng lần giữ | C-08, C-03, C-07, C-14 (giá khớp là ứng dụng) |
| EX-04, EX-05 | Trạng thái cuối không đổi; trả ghế chỉ khi liên kết hiện tại khớp | C-07, C-01 |
| EX-06, EX-07, EX-08 | Một vé chỉ huỷ hoặc soát một lần; ghế bán lại được | C-07, C-03, C-26 |
| EX-09, EX-10 | Tổng hoàn không vượt số đã thanh toán; hoàn không trùng; tối đa 4 lần gửi | C-09, C-10, C-11, C-12 |
| EX-11, EX-12 | Mục giá theo mốc; không bỏ mục giá còn suất chiếu dùng | C-17, C-33 (mốc là ứng dụng) |
| EX-13, EX-14 | Suất chiếu không chồng giờ; đổi phòng chỉ khi chưa từng có vé; xoá mềm một chiều; phim hiện hành | C-06, C-16, C-19, C-20, C-28, C-30 |
| EX-15 | Tên phòng duy nhất; sơ đồ ghế lịch sử giữ lại; sức chứa | C-23, C-27, C-22, C-30 (sức chứa 50 đến 400 là ứng dụng) |
| EX-16 | Mốc thay đổi phim; tên phim được trùng | C-33; không có ràng buộc unique tên phim (Q-200) |
| EX-17, EX-18 | Tên cụm rạp, tên phòng duy nhất; cụm rạp luôn có bảng giá | C-23, C-29, C-33 |
| EX-19 | Xoá phòng chỉ khi chưa từng có suất chiếu | C-30 |
| EX-20, EX-21 | Email khách, số điện thoại khách, email nhân viên duy nhất | C-23, C-24 |
| EX-22 | Một thao tác tài khoản nhân viên tại một thời điểm; phiên bị thu hồi ngay | C-24, C-32, C-33 |

### F4.5. Ánh xạ EX-01 đến EX-22 sang câu lệnh khoá

Quy ước theo P09 2.1 F7.3: S là SELECT ... FOR SHARE; X là SELECT ... FOR NO KEY UPDATE (không dùng FOR UPDATE để không xung đột với khoá ngầm FOR KEY SHARE của khoá ngoại; ngoại lệ có DELETE thật nêu ở EX-13, EX-15, EX-19); nhiều dòng cùng hạng thì SELECT ... ORDER BY <khoá chính> FOR NO KEY UPDATE (ngoại lệ: quét hết hạn EX-04 sắp theo expiry_time để dùng ix_seat_hold_expiry; chấp nhận được vì SKIP LOCKED không bao giờ chờ khoá nên thứ tự lấy khoá không tạo chu trình chờ; thao tác kế tiếp ở hạng 6 vẫn ORDER BY showtime_id, seat_id), câu khoá chỉ lọc theo khoá, không lọc theo trạng thái nghiệp vụ (ngoại lệ: khoá seat_hold của suất chiếu ở EX-13, EX-14 lọc status = 'ACTIVE'; vẫn đúng vì READ COMMITTED đánh giá lại WHERE trên bản dòng mới sau khi chờ khoá, nên lần giữ ghế vừa chuyển sang trạng thái cuối trong lúc chờ bị loại đúng, còn vé mới tạo được thấy ở câu đọc vé sau). Không UPDATE cột thuộc chỉ mục unique đầy đủ (id, các khoá ghép, mã duy nhất); các chỉ mục unique từng phần và theo biểu thức của lược đồ này (norm_email, norm_name) không tính là khoá mà khoá ngoại tham chiếu, nên UPDATE status, tên, email không nâng khoá (đã kiểm trên PostgreSQL 16, ca B4 của P13-schema-tests.sql: giao dịch đang UPDATE tên cụm rạp không chặn INSERT phòng chiếu hay nhân viên của cụm rạp đó).

Thứ tự lấy khoá toàn cục, 14 hạng (P08 F4b, P09 F7.3), khoá lấy theo (hạng, thứ tự trong hạng) tăng ngặt: 0 khoá giá trị tên cụm rạp rồi cinema; 1 price_list; 2 auditorium; 3 showtime; 4 customer hoặc staff; 5 seat_hold; 6 seat_status; 7 payment_transaction; 8 ticket; 9 refund_request; 10 movie; 11 giá trị email khách; 12 giá trị số điện thoại khách; 13 giá trị email nhân viên. Khoá giá trị (hạng 0, 11, 12, 13) là khoá tư vấn mức giao dịch dạng hai số nguyên pg_advisory_xact_lock(1000 + hạng, hashtext(giá trị chuẩn hoá)): 1000 tên cụm rạp theo norm_name, 1011 email khách theo norm_email, 1012 số điện thoại khách (nguyên giá trị, BR-82), 1013 email nhân viên theo norm_email; hai giá trị khác nhau trùng hash chỉ gây chờ thừa vì câu kiểm so giá trị thật dưới khoá. Bảng chỉ ghi các dòng bị khoá theo thứ tự hạng; hạng ghi "mới" là dòng tạo trong thao tác nên không cần khoá. Huỷ vé trực tuyến là một giao dịch gộp EX-06, EX-07, EX-09 (Q-133, P12). Ở mọi thao tác ghi seat_event, mã sự kiện lấy trước bằng nextval để ghi vào event_seq, còn câu INSERT seat_event là câu ghi cuối cùng của giao dịch, ngay trước COMMIT, để khoảng từ INSERT đến COMMIT bị idle_in_transaction_session_timeout 5 giây chặn (P09 F7.5 điểm 3).

| EX | Chuỗi khoá theo hạng (hạng: bảng - câu lệnh) | Câu ghi sau khoá | Lưới an toàn nếu bên gọi quên khoá hoặc sai thứ tự |
|---|---|---|---|
| EX-01 | 1: price_list WHERE cinema_id - S; 2: auditorium WHERE id - S; 3: showtime WHERE id - S (P09 thu hẹp từ X); 4: customer (khách) hoặc staff (nhân viên quầy) WHERE id - X, với nhân viên quầy so status = 'ACTIVE' và access_changed_at của dòng vừa khoá với mốc trong phiên, khác thì từ chối (P09 F7.11, X-33); 5: seat_hold WHERE customer_id (hoặc box_office_clerk_id) = người giữ AND status = 'ACTIVE' - X, chỉ khi có lần giữ ghế cũ (so request_id trước: cùng mã yêu cầu thì trả lại lần giữ ghế cũ); 6: seat_status WHERE showtime_id = ? AND seat_id = ANY(?) ORDER BY showtime_id, seat_id - FOR NO KEY UPDATE NOWAIT, không lọc state | INSERT seat_hold; nextval mã sự kiện; khi người giữ chọn lại ghế của lần giữ ghế cũ vừa hết hạn (P12 F3 HoldSeats (g)): trước đó UPDATE seat_status SET state = 'AVAILABLE', current_hold_id = NULL, held_price = NULL, event_seq cho các ghế ấy (một câu riêng, vì trg_seat_status_link từ chối UPDATE đổi current_hold_id từ giá trị này sang giá trị khác); UPDATE seat_status SET state = 'HELD', current_hold_id, held_price, event_seq (sau khi so số dòng khoá và state = 'AVAILABLE' với đồng hồ CSDL lấy một lần, ghế vừa trả trong cùng giao dịch tính là Trống); INSERT seat_event (câu cuối trước COMMIT) | uq_seat_hold_active_customer, uq_seat_hold_active_clerk, uq_seat_hold_request_id, fk_seat_hold_staff, ck_seat_status_state_link, fk_seat_status_seat_hold, trg_seat_status_state, trg_seat_status_link |
| EX-02 | 5: seat_hold WHERE id - X; 6: seat_status WHERE current_hold_id = ? ORDER BY showtime_id, seat_id - X; 7: payment_transaction WHERE code - X (chưa có thì INSERT dưới khoá hạng 5); hạng 8, 9: mới (booking, ticket, refund_request) | Bán: UPDATE payment_transaction SET status = 'TICKETED' WHERE status = 'PENDING'; UPDATE seat_hold SET status = 'COMPLETED' WHERE status = 'ACTIVE'; INSERT booking (customer_id của khách giữ ghế hoặc NULL với nhân viên quầy, booked_at lấy từ đồng hồ CSDL của giao dịch); INSERT ticket kèm giá trị lúc bán movie_title, cinema_name, auditorium_name, auditorium_type đọc từ phim, cụm rạp, phòng dưới khoá (BR-140); UPDATE seat_status SET state = 'SOLD', current_hold_id = NULL, current_ticket_id; INSERT outbox EMAIL_TICKET; INSERT seat_event. Trễ: UPDATE payment_transaction SET status = 'LATE_PAYMENT'; INSERT refund_request FULL; UPDATE refunded_total = refunded_total + amount; INSERT outbox REFUND_GATEWAY | uq_payment_transaction_code, uq_payment_transaction_ticketed_hold, uq_booking_seat_hold, trg_booking_customer, uq_ticket_active_seat, trg_ticket_sale_values, uq_refund_request_idempotency_key, uq_refund_request_full_per_payment, ck_payment_transaction_refund_limit, trg_seat_hold_status, trg_payment_transaction_status |
| EX-03 | 5: seat_hold WHERE id - X; 6: seat_status WHERE current_hold_id = ? ORDER BY showtime_id, seat_id - X | Bán như EX-02 (không PaymentTransaction), hoặc từ chối nếu quá expiry_time (chuyển EXPIRED và trả ghế) | uq_booking_seat_hold, uq_ticket_active_seat, ck_seat_status_state_link, trg_seat_hold_status |
| EX-04 | 5: seat_hold WHERE id - X. Quét theo lô: SELECT id FROM seat_hold WHERE status = 'ACTIVE' AND expiry_time <= ? ORDER BY expiry_time LIMIT 200 FOR NO KEY UPDATE SKIP LOCKED (ix_seat_hold_expiry). Đường huỷ giữ ghế, thanh toán thất bại, hết hạn có sẵn khoá hạng 6 trả ghế ngay (Q-134) bằng 6: seat_status WHERE current_hold_id = ? - X | UPDATE seat_hold SET status = <EXPIRED nếu quá hạn, ngược lại trạng thái yêu cầu> WHERE id = ? AND status = 'ACTIVE' | trg_seat_hold_status: trạng thái cuối không đổi |
| EX-05 | Công việc quét (giao dịch riêng): 5: SELECT h.id FROM seat_hold h WHERE h.status IN ('EXPIRED', 'CANCELLED', 'PAYMENT_FAILED') AND h.id IN (SELECT current_hold_id FROM seat_status WHERE current_hold_id IS NOT NULL) ORDER BY h.id LIMIT 200 FOR NO KEY UPDATE OF h SKIP LOCKED; 6: seat_status WHERE current_hold_id = ANY(?) ORDER BY showtime_id, seat_id - X | UPDATE seat_status SET state = 'AVAILABLE', current_hold_id = NULL, held_price = NULL, event_seq WHERE khoá chính thuộc danh sách vừa khoá AND current_hold_id = mã lần giữ ghế; INSERT seat_event mỗi suất chiếu. Chạy lặp: lần sau không còn dòng khớp current_hold_id | ix_seat_status_current_hold; ck_seat_status_state_link |
| EX-06 | Trong giao dịch huỷ vé gộp: 6: seat_status WHERE showtime_id = ? AND seat_id = ? - X (đầu tiên, sau đó mới tới hạng 7, 8) | UPDATE seat_status SET state = 'AVAILABLE', current_ticket_id = NULL, held_price = NULL, event_seq WHERE showtime_id AND seat_id AND current_ticket_id = mã vé đã huỷ; INSERT seat_event | ix_ticket_showtime_seat; ck_seat_status_state_link; chạy lặp an toàn nhờ điều kiện current_ticket_id |
| EX-07 | Trong giao dịch huỷ vé gộp: 8: ticket WHERE id - X (sau hạng 6, 7) | UPDATE ticket SET status = 'CANCELLED' WHERE id = ? AND status = 'UNUSED' | trg_ticket_status; uq_ticket_active_seat giải phóng ghế cho vé mới |
| EX-08 | 8: ticket WHERE ticket_code = ? - X (uq_ticket_ticket_code) | UPDATE ticket SET status = 'USED' WHERE id = ? AND status = 'UNUSED' | trg_ticket_status: huỷ và soát cùng vé chỉ một bên thành công |
| EX-09 | Trong giao dịch huỷ vé gộp: 7: payment_transaction WHERE id - X (sau hạng 6, trước hạng 8); hạng 9: mới | UPDATE payment_transaction SET refunded_total = refunded_total + ? WHERE id = ? (cộng trong chính câu); INSERT refund_request; INSERT outbox REFUND_GATEWAY | ck_payment_transaction_refund_limit; uq_refund_request_ticket, uq_refund_request_idempotency_key |
| EX-10 | Ba giao dịch ngắn. GD0: claim đúng một dòng outbox (không thuộc hạng), commit ngay. GD1: 9: refund_request WHERE id - X rồi UPDATE outbox SET claimed_until = ... WHERE id AND claim_token = ? (hàng rào, 0 dòng thì ClaimLostError). GD2: gọi cổng, ngoài giao dịch. GD3: 9: refund_request WHERE id - X rồi UPDATE outbox WHERE id AND claim_token = ? | GD1 (cùng giao dịch với hàng rào): UPDATE refund_request SET status = 'IN_FLIGHT', attempt_count = attempt_count + 1 WHERE status IN ('NEW', 'WAITING_RETRY', 'IN_FLIGHT'). GD3: UPDATE refund_request SET status, refund_result; UPDATE outbox SET status = 'SUCCEEDED'; INSERT outbox EMAIL_REFUND khi hoàn thành công và request_type = 'FULL'. Hoàn tiền mặt nằm trong giao dịch huỷ vé gộp (không có hạng 7) | ck_refund_request_attempts, ck_refund_request_attempt_status, trg_refund_request_status, trg_outbox_status, ck_outbox_claim_pair, uq_outbox_idempotency_key |
| EX-11 | 1: price_list WHERE cinema_id - X; sau khoá đọc price_entry theo khoá chính, so last_changed_at | UPDATE price_entry SET ticket_price, last_changed_at, removed = FALSE WHERE khoá chính AND last_changed_at = mốc lúc hiển thị; chưa có thì INSERT | Khoá chính ghép của price_entry (BR-62); ck_price_entry_price |
| EX-12 | 1: price_list - X; 2: auditorium WHERE cinema_id = ? ORDER BY id - S; 3: showtime WHERE auditorium_id IN (phòng của cụm) AND status = 'IN_SCHEDULE' ORDER BY id - S | UPDATE price_entry SET removed = TRUE, last_changed_at WHERE khoá chính AND last_changed_at = mốc lúc hiển thị | Khoá hạng 1 X loại trừ EX-01 (S) và EX-13 (S) |
| EX-13 | 1: price_list - S; 2: auditorium WHERE id IN (một hoặc hai phòng) ORDER BY id - X; 3: showtime WHERE id - X (khi sửa); 5: seat_hold WHERE showtime_id = ? AND status = 'ACTIVE' ORDER BY id - S; 6: seat_status WHERE showtime_id = ? ORDER BY showtime_id, seat_id - FOR UPDATE (khi đổi phòng, chỉ khi suất chiếu chưa từng có vé, BR-92 và C-19; lấy FOR UPDATE ngay từ đầu vì câu DELETE ở cột bên cạnh cần mức khoá này, không nâng từ FOR NO KEY UPDATE; lập mới thì INSERT, không khoá); 8: ticket WHERE showtime_id = ? ORDER BY id - S (mọi trạng thái, để biết suất chiếu có từng có vé không); 10: movie WHERE id = ? - S, lấy sau cùng (phim hiện hành: kiểm lại định dạng phát hành, ngày chiếu, tính lại giờ kết thúc, BR-139, BR-47, BR-49, BR-50; phòng đích đã bị EX-19 xoá thì câu khoá auditorium không trả dòng và từ chối, BR-147). Khác P08: không khác thứ tự hay chế độ; hạng 10 chỉ thêm ở P08 2.0. Quyết định có khoá hạng 6 hay không phụ thuộc kết quả hạng 8, nên trước chuỗi khoá, khi đổi phòng, đọc không khoá SELECT EXISTS (SELECT 1 FROM ticket WHERE showtime_id = ?): có vé thì báo lỗi BR-92 và rollback, không khoá gì thêm; chưa có vé thì khoá theo hạng tăng dần (6 rồi 8) và đọc lại ticket dưới khoá hạng 8. Đọc không khoá trước là an toàn vì Showtime X cộng SeatHold S chặn mọi đường tạo vé mới của suất chiếu này | INSERT hoặc UPDATE showtime kèm last_changed_at; INSERT seat_status Trống cho từng ghế của phòng khi lập mới. Đổi phòng: DELETE FROM seat_status WHERE showtime_id = ? (các dòng đã khoá FOR UPDATE), rồi INSERT INTO seat_status (showtime_id, seat_id) SELECT ?, id FROM seat WHERE auditorium_id = <phòng mới> | ex_showtime_auditorium_overlap, uq_ticket_active_seat, ck_showtime_sale_before_start, ck_showtime_end_after_start, fk_showtime_auditorium, fk_showtime_movie, trg_showtime_status |
| EX-14 | 3: showtime WHERE id - X; 5: seat_hold WHERE showtime_id = ? AND status = 'ACTIVE' - S; 8: ticket WHERE showtime_id = ? AND status <> 'CANCELLED' - S | UPDATE showtime SET status = 'DELETED', last_changed_at WHERE id = ? AND status = 'IN_SCHEDULE' | ck_showtime_status; không xoá cứng nên seat_status, seat_hold, ticket còn nguyên (BR-58) |
| EX-15 | 0: cinema WHERE id = (mã cụm rạp tra không khoá từ phòng, không đổi sau khi lập) - X; 1: price_list - S; 2: auditorium WHERE id - X; 3: showtime WHERE auditorium_id = ? ORDER BY id - S (kể cả suất chiếu đã xoá); 6: seat_status WHERE showtime_id IN (suất chiếu chưa mở bán của phòng) ORDER BY showtime_id, seat_id - FOR UPDATE ngay từ đầu (có câu DELETE seat_status của ghế bỏ khỏi sơ đồ; không nâng từ NO KEY UPDATE). Sau khoá lấy một lần thời điểm hiện tại của CSDL rồi kiểm theo thứ tự P08: (5c) last_changed_at của phòng bằng mốc lúc hiển thị; (4d) SELECT 1 FROM auditorium WHERE cinema_id = ? AND norm_name(name) = norm_name(?) AND id <> ?; (5a) không có suất chiếu IN_SCHEDULE đã tới sale_open_time mà chưa tới end_time; (5b) mọi suất chiếu IN_SCHEDULE chưa tới start_time vẫn đủ giá theo loại phòng, loại ghế mới | UPDATE auditorium (name, auditorium_type, last_changed_at); ghế bỏ khỏi sơ đồ: UPDATE seat SET in_seat_map = FALSE (không DELETE, BR-118); ghế đổi loại: UPDATE seat SET seat_type; ghế mới: INSERT seat; với từng suất chiếu chưa mở bán: INSERT seat_status Trống cho ghế mới, DELETE seat_status của ghế không còn trong sơ đồ; không ghi seat_event (suất chiếu chưa mở bán thì chưa hiển thị sơ đồ) | uq_auditorium_cinema_name_norm, uq_seat_position (từng phần WHERE in_seat_map), trg_seat_in_seat_map, fk_seat_status_seat, ix_seat_status_seat. Khác P08: P09 thêm Showtime S cả suất chiếu đã xoá (BR-147 và X-29) và khoá SeatStatus FOR UPDATE thay vì X |
| EX-16 | 10: movie WHERE id - X (sửa phim, FOR NO KEY UPDATE); thêm phim không khoá (mã IDENTITY, tên được trùng, Q-200) | Sửa: so last_changed_at của dòng với mốc lúc hiển thị, khác thì từ chối; bằng thì UPDATE các cột và đặt mốc mới; chỉ UPDATE movie (và INSERT, DELETE movie_format), không đụng showtime nên suất chiếu đã lập không đổi (BR-84, BR-139). Thêm: INSERT movie, INSERT movie_format | ck_movie_age_rating, ck_movie_duration, ck_movie_run_period, ck_movie_title_not_blank; không có unique tên phim |
| EX-17 | 0: pg_advisory_xact_lock(1000, hashtext(norm_name(tên mới))) rồi cinema WHERE id - X (sửa); thêm: không có dòng để khoá. Luôn lấy khoá tên kể cả khi tên không đổi | Kiểm trước SELECT 1 FROM cinema WHERE norm_name(name) = norm_name(?) AND id <> ? (5b, BR-141), rồi (khi sửa) so last_changed_at với mốc lúc hiển thị (5a, BR-142), rồi UPDATE cinema (name, province, address, last_changed_at). Thêm: INSERT cinema rồi INSERT price_list (cinema_id) cùng giao dịch (R-40) | uq_cinema_name_norm (23505), trg_cinema_has_price_list (kiểm lúc COMMIT), ck_cinema_name_not_blank, ck_cinema_province_not_blank. Hai cụm rạp đổi tên cho nhau: bên sau bị từ chối ở câu kiểm, không tới chờ trên chỉ mục unique |
| EX-18 | 0: cinema WHERE id = (mã cụm rạp lấy từ dòng staff của phiên) - X | Kiểm tên phòng (4d, BR-145) bằng SELECT 1 FROM auditorium WHERE cinema_id = ? AND norm_name(name) = norm_name(?); INSERT auditorium (kèm last_changed_at), INSERT auditorium_format, INSERT seat (một câu nhiều dòng, in_seat_map mặc định TRUE); sức chứa 50 đến 400 kiểm ở ứng dụng trên phòng dự kiến (BR-144). Phòng mới chưa ai tham chiếu nên không khoá Auditorium | uq_auditorium_cinema_name_norm, uq_seat_position, ck_auditorium_name_not_blank |
| EX-19 | 0: cinema WHERE id - X; 2: auditorium WHERE id - FOR UPDATE ngay từ đầu (có câu DELETE); không còn dòng thì từ chối | Kiểm SELECT 1 FROM showtime WHERE auditorium_id = ? LIMIT 1 (không lọc status, BR-147); rồi DELETE FROM seat WHERE auditorium_id = ?, DELETE auditorium (auditorium_format xoá theo CASCADE) trong cùng giao dịch. Phòng chưa từng có suất chiếu nên không seat_status nào tham chiếu ghế của nó | fk_showtime_auditorium, fk_seat_status_seat, fk_seat_auditorium (RESTRICT, 23503) |
| EX-20 | 11: pg_advisory_xact_lock(1011, hashtext(norm_email(email))); 12: pg_advisory_xact_lock(1012, hashtext(số điện thoại)) | Kiểm SELECT 1 FROM customer WHERE norm_email(email) = norm_email(?) OR phone_number = ?, trùng thì từ chối (luồng 7a); không thì INSERT customer (mật khẩu đã băm trước khi mở giao dịch) | uq_customer_email_norm, uq_customer_phone_number, ck_customer_email_format, ck_customer_phone_format |
| EX-21 | 13: pg_advisory_xact_lock(1013, hashtext(norm_email(email))) | Kiểm SELECT 1 FROM staff WHERE norm_email(email) = norm_email(?) trên mọi vai trò (5a, BR-95); INSERT staff (status ACTIVE, last_changed_at và access_changed_at bằng một giá trị đồng hồ CSDL); khoá ngoại cụm rạp chỉ lấy KEY SHARE ngầm lên cinema | uq_staff_email_norm, ck_staff_role, ck_staff_role_cinema |
| EX-22 | 4: staff WHERE id - X (một dòng) | Kiểm điều kiện riêng của thao tác (khoá: ACTIVE; mở khoá: LOCKED; sửa họ tên: không rỗng), rồi so last_changed_at với mốc lúc hiển thị (BR-102), rồi UPDATE staff: khoá, đổi vai trò hoặc cụm rạp đặt status hoặc role, cinema_id kèm access_changed_at = last_changed_at = now; mở khoá, sửa họ tên, đặt lại mật khẩu chỉ đặt last_changed_at. Không UPDATE seat_hold của nhân viên quầy (BR-100) | ck_staff_status, ck_staff_role_cinema, ck_staff_full_name_not_blank, trg_staff_email (email không đổi) |

Khác P08 F4a, ghi tại dòng: EX-01 khoá showtime hạng 3 bằng S (P09 thu hẹp từ X; EX-13 và EX-14 lấy X nên vẫn loại trừ với EX-01); EX-05 khoá seat_hold hạng 5 bằng X trên đường quét (P08 ghi S) vì sau đó trả ghế; EX-13 khi đổi phòng lấy SeatStatus FOR UPDATE ngay từ đầu; EX-15 lấy SeatStatus FOR UPDATE thay vì X vì có DELETE; EX-17, EX-20, EX-21 hiện thực "khoá theo giá trị" của P08 bằng khoá tư vấn mức giao dịch kèm chỉ mục unique theo biểu thức làm lưới an toàn; EX-06 và EX-10 không ghi khoá S ticket hạng 8 vì thao tác nằm trong giao dịch huỷ vé gộp đã có khoá X ticket (EX-07). Đối chiếu khoá ngầm của khoá ngoại: cha có con là cinema (auditorium, price_list, staff), auditorium (seat, showtime), movie (showtime), staff (seat_hold); mọi khoá X trên các cha này là FOR NO KEY UPDATE (tên, mốc, họ tên, vai trò, access_changed_at không là cột khoá, email nhân viên bất biến theo trg_staff_email) nên KEY SHARE ngầm của INSERT dòng con không chờ; ngoại lệ có DELETE (EX-13, EX-15, EX-19) lấy FOR UPDATE ngay từ đầu và bên có thể giữ KEY SHARE ngầm lên các dòng đó đều đã giữ khoá hạng thấp hơn.

Mẫu câu lệnh cho các chuỗi nóng nhất, cụm rạp, tài khoản và báo cáo (giao dịch READ COMMITTED; tham số $n là minh hoạ):

```sql
-- EX-01: giữ nhóm ghế
BEGIN;
SET LOCAL lock_timeout = '1s';
SELECT cinema_id FROM price_list WHERE cinema_id = $1 FOR SHARE;                  -- hạng 1
SELECT id FROM auditorium WHERE id = $2 FOR SHARE;                                 -- hạng 2
SELECT id FROM showtime WHERE id = $3 FOR SHARE;                                   -- hạng 3
SELECT id FROM customer WHERE id = $4 FOR NO KEY UPDATE;                           -- hạng 4
SELECT id FROM seat_hold WHERE customer_id = $4 AND status = 'ACTIVE'
  FOR NO KEY UPDATE;                                                               -- hạng 5 (nếu có)
SELECT showtime_id, seat_id, state FROM seat_status
  WHERE showtime_id = $3 AND seat_id = ANY ($5)
  ORDER BY showtime_id, seat_id
  FOR NO KEY UPDATE NOWAIT;                                                        -- hạng 6; 55P03 nghĩa là ghế vừa có người chọn
-- ứng dụng: đủ số dòng, mọi state = 'AVAILABLE', lấy now = clock_timestamp() một lần
-- ghế còn HELD bởi lần giữ ghế cũ của chính người giữ (đã quá hạn, đã ghi EXPIRED) thì trả về Trống trước, một câu riêng:
-- UPDATE seat_status SET state = 'AVAILABLE', current_hold_id = NULL, held_price = NULL, event_seq = $11
--   WHERE showtime_id = $3 AND seat_id = ANY ($13) AND current_hold_id = $14;   -- $14 là mã lần giữ ghế cũ
INSERT INTO seat_hold (showtime_id, customer_id, hold_ref, request_id, hold_time, expiry_time)
  VALUES ($3, $4, $6, $7, $8, $8 + interval '10 minutes') RETURNING id;
SELECT nextval(pg_get_serial_sequence('seat_event', 'id'));                       -- mã sự kiện, bind làm $11
UPDATE seat_status SET state = 'HELD', current_hold_id = $10, held_price = v.price, event_seq = $11
  FROM unnest($5::bigint[], $12::bigint[]) AS v(seat_id, price)
  WHERE seat_status.showtime_id = $3 AND seat_status.seat_id = v.seat_id;
INSERT INTO seat_event (id, showtime_id, items) VALUES ($11, $3, $9);             -- câu ghi cuối, ngay trước COMMIT
COMMIT;

-- EX-04 và EX-05: hai bước quét của công việc nền (mỗi bước một giao dịch riêng, mỗi lô tối đa 200)
SELECT id FROM seat_hold WHERE status = 'ACTIVE' AND expiry_time <= clock_timestamp()
  ORDER BY expiry_time LIMIT 200 FOR NO KEY UPDATE SKIP LOCKED;
UPDATE seat_hold SET status = 'EXPIRED' WHERE id = ANY ($1) AND status = 'ACTIVE' AND expiry_time <= $2;

SELECT h.id FROM seat_hold h
  WHERE h.status IN ('EXPIRED', 'CANCELLED', 'PAYMENT_FAILED')
    AND h.id IN (SELECT current_hold_id FROM seat_status WHERE current_hold_id IS NOT NULL)
  ORDER BY h.id LIMIT 200 FOR NO KEY UPDATE OF h SKIP LOCKED;
SELECT showtime_id, seat_id FROM seat_status WHERE current_hold_id = ANY ($1)
  ORDER BY showtime_id, seat_id FOR NO KEY UPDATE;
UPDATE seat_status SET state = 'AVAILABLE', current_hold_id = NULL, held_price = NULL, event_seq = $2
  WHERE showtime_id = $3 AND seat_id = ANY ($4) AND current_hold_id = ANY ($1);

-- Claim đúng một dòng outbox (P09 F7.7 bước 1) ngay trước khi xử lý, commit ngay; sau đó chỉ claim_token còn đúng mới ghi được kết quả
UPDATE outbox SET claim_token = gen_random_uuid(),
                  claimed_until = clock_timestamp() + interval '120 seconds',
                  attempt_count = attempt_count + 1
  WHERE id IN (SELECT id FROM outbox
               WHERE kind = $1 AND status = 'PENDING' AND next_attempt_at <= clock_timestamp()
                 AND (claimed_until IS NULL OR claimed_until < clock_timestamp())
               ORDER BY next_attempt_at LIMIT 1 FOR NO KEY UPDATE SKIP LOCKED)
  RETURNING id, source_id, claim_token, attempt_count;

-- Hàng rào trong giao dịch 1 của ProcessRefund, trước khi gọi cổng (P09 F7.7 bước 2); 0 dòng bị cập nhật thì ClaimLostError, rollback, không gọi cổng
UPDATE outbox SET claimed_until = clock_timestamp() + interval '120 seconds'
  WHERE id = $1 AND claim_token = $2
  RETURNING claimed_until;

-- EX-17: lưu cụm rạp (thêm), khoá giá trị tên ở hạng 0 trước mọi khoá dòng; EX-20, EX-21 tương tự với hạng 1011 đến 1013
BEGIN;
SELECT pg_advisory_xact_lock(1000, hashtext(norm_name($1)));                      -- hạng 0, giá trị tên đã chuẩn hoá bởi cùng hàm với chỉ mục
SELECT 1 FROM cinema WHERE norm_name(name) = norm_name($1);                       -- có dòng thì từ chối (5b, BR-141)
INSERT INTO cinema (name, province, address, last_changed_at) VALUES ($1, $2, $3, clock_timestamp()) RETURNING id;
INSERT INTO price_list (cinema_id) VALUES ($4);                                   -- $4 là id vừa nhận; trg_cinema_has_price_list kiểm lúc COMMIT
COMMIT;

-- EX-22: khoá tài khoản nhân viên (so mốc rồi ghi, một giao dịch)
BEGIN;
SELECT id, status, last_changed_at FROM staff WHERE id = $1 FOR NO KEY UPDATE;    -- hạng 4
-- ứng dụng: status = 'ACTIVE' và last_changed_at bằng mốc lúc hiển thị, lấy now = clock_timestamp() một lần
UPDATE staff SET status = 'LOCKED', access_changed_at = $2, last_changed_at = $2 WHERE id = $1;
COMMIT;

-- Báo cáo UC-015, UC-016: một ảnh chụp cho mọi câu của báo cáo, không giữ khoá
BEGIN ISOLATION LEVEL REPEATABLE READ READ ONLY;
SELECT (s.start_time AT TIME ZONE 'Asia/Ho_Chi_Minh')::date AS show_date, a.cinema_id, sum(t.price) AS gross
  FROM ticket t JOIN showtime s ON s.id = t.showtime_id JOIN auditorium a ON a.id = s.auditorium_id
 WHERE s.start_time >= $1 AND s.start_time < $2 GROUP BY 1, 2;
SELECT s.id, count(*) AS capacity FROM showtime s JOIN seat_status ss ON ss.showtime_id = s.id
 WHERE s.status = 'IN_SCHEDULE' AND s.start_time >= $1 AND s.start_time < $2 GROUP BY s.id;
COMMIT;
```

## F5. Chuẩn hoá (CSDL quan hệ)

### F5.1. Bảng kiểm tra

Ký hiệu FD theo tên cột; căn cứ là BR và ngữ nghĩa trong cột Phụ thuộc hàm, không suy từ dữ liệu mẫu.

| TBL | Khoá (chính và ứng viên) | Phụ thuộc hàm (FD) | 1NF | 2NF | 3NF | BCNF | Kết luận |
|---|---|---|---|---|---|---|---|
| seat_hold | id; hold_ref; request_id | id --> mọi cột; hold_ref --> id; request_id --> id; hold_time --> expiry_time (hằng số 10 phút, BR-10) | Đạt | Đạt (khoá đơn) | Không đạt vì hold_time --> expiry_time là FD giữa hai cột không khoá | Không đạt cùng lý do | Phi chuẩn hoá có chủ đích (F5.3) |
| seat_status | (showtime_id, seat_id) | khoá --> state, held_price, current_hold_id, current_ticket_id, event_seq; (current_hold_id, current_ticket_id có NULL hay không) xác định state | Đạt | Đạt (mọi cột phụ thuộc cả khoá) | Đạt về FD theo giá trị; state là dẫn xuất từ mẫu NULL của hai liên kết, giữ có chủ đích (F5.3) | Đạt | Đạt có điều kiện (F5.3) |
| payment_transaction | id; code | id --> mọi cột; code --> id; refunded_total là tổng khoản hoàn của refund_request thuộc giao dịch | Đạt | Đạt | Đạt về FD; refunded_total là tổng dẫn xuất, giữ có chủ đích (F5.3) | Đạt | Đạt có điều kiện (F5.3) |
| refund_request | id; idempotency_key; ticket_id | id --> mọi cột; idempotency_key --> id; ticket_id --> id (BR-21) | Đạt | Đạt | Đạt | Đạt (các khoá ứng viên đều đơn, không chồng lấn) | Đạt |
| booking | id; booking_code; seat_hold_id | id --> mọi cột; booking_code --> id; seat_hold_id --> id (R-51); seat_hold_id --> customer_id (khách giữ ghế của lần giữ ghế, R-65) và booked_at không suy ra từ seat_hold | Đạt | Đạt | customer_id phụ thuộc bắc cầu vào khoá qua seat_hold_id --> seat_hold.customer_id: phi chuẩn hoá có chủ đích (F5.3) | Đạt | Đạt có điều kiện (F5.3) |
| ticket | id; ticket_code | id --> mọi cột; ticket_code --> id; (showtime_id, seat_id) không là khoá vì ghế bán lại được (BR-42); price, movie_title, cinema_name, auditorium_name, auditorium_type là giá trị lúc bán, không phụ thuộc hàm vào phim, cụm rạp, phòng hiện hành (BR-140, BR-67) | Đạt | Đạt | Đạt (các cột lúc bán là một sự kiện khác với dữ liệu hiện hành, F5.3) | Đạt | Đạt |
| customer | id; norm_email(email); phone_number | id --> mọi cột; norm_email(email) --> id; phone_number --> id | Đạt | Đạt | Đạt | Đạt (các khoá ứng viên đều đơn, không chồng lấn) | Đạt |
| staff | id; norm_email(email) | id --> mọi cột; norm_email(email) --> id (BR-95); role --> (cinema_id có NULL hay không) (BR-78, quy tắc ràng buộc, không phải FD giữa hai cột không khoá vì cinema_id còn tuỳ thuộc tài khoản) | Đạt | Đạt | Đạt | Đạt | Đạt |
| administrator | id | id --> email, password_hash (đúng một dòng) | Đạt | Đạt | Đạt | Đạt | Đạt |
| showtime | id | id --> mọi cột; end_time không suy từ start_time vì thời lượng phim có thể đổi (BR-50, BR-84) | Đạt | Đạt | Đạt | Đạt | Đạt |
| price_list | cinema_id | Không có thuộc tính không khoá | Đạt | Đạt | Đạt | Đạt | Đạt |
| cinema | id; norm_name(name) | id --> name, province, address, last_changed_at; norm_name(name) --> id (BR-141) | Đạt | Đạt | Đạt (province phụ thuộc cụm rạp, không phụ thuộc tên: hai cụm rạp cùng tỉnh không chia sẻ dòng) | Đạt | Đạt |
| auditorium | id; (cinema_id, norm_name(name)) | id --> cinema_id, name, auditorium_type, last_changed_at; (cinema_id, norm_name(name)) --> id (BR-145) | Đạt | Đạt | Đạt | Đạt (hai khoá ứng viên, khoá thứ hai chứa cinema_id nhưng không chồng với khoá chính đơn) | Đạt |
| seat | id; (auditorium_id, row_code, seat_number) WHERE in_seat_map | id --> mọi cột; (auditorium_id, row_code, seat_number) --> id, seat_type chỉ trong tập ghế đang trong sơ đồ (ghế đã bỏ có thể cùng vị trí với ghế mới, BR-118) | Đạt | Đạt | Đạt | Đạt (khoá ứng viên từng phần) | Đạt |
| movie | id | id --> title, duration_minutes, release_date, end_of_run_date, genre, age_rating, description, trailer, last_changed_at (tên không là khoá: được trùng, Q-200) | Đạt | Đạt | Đạt | Đạt | Đạt |
| price_entry | (cinema_id, auditorium_type, movie_format, seat_type, time_band) | khoá --> ticket_price, last_changed_at, removed (BR-62) | Đạt | Đạt (mọi cột phụ thuộc cả khoá ghép) | Đạt | Đạt | Đạt |
| movie_format | (movie_id, movie_format) | Toàn khoá | Đạt (tách từ thuộc tính đa trị) | Đạt | Đạt | Đạt | Đạt |
| auditorium_format | (auditorium_id, movie_format) | Toàn khoá | Đạt (tách từ thuộc tính đa trị) | Đạt | Đạt | Đạt | Đạt |
| seat_event | id | id --> showtime_id, created_at, items | Đạt (items là tải trọng nguyên khối của một sự kiện, F5.3) | Đạt | Đạt | Đạt | Đạt có điều kiện (F5.3) |
| outbox | id; idempotency_key | id --> mọi cột; idempotency_key --> id | Đạt | Đạt | Đạt | Đạt | Đạt |

### F5.2. Quá trình tách

- Thuộc tính đa trị Movie.releaseFormats (2D, 3D) vi phạm 1NF nếu để trong một cột. Bảng trước: movie(id, title, release_formats, ...). Tách thành movie(id, title, ...) và movie_format(movie_id, movie_format).
- Thuộc tính đa trị Auditorium.supportedFormats: tách tương tự thành auditorium(id, ...) và auditorium_format(auditorium_id, movie_format).
- P08 gộp: PaymentTransaction.processed và result là hai thuộc tính tương quan, P12 đã gộp thành status nên không còn FD giữa hai cột không khoá.
- Booking không lưu channel và buyerId vì suy ra được qua seat_hold (R-51, R-48, R-49); customer_id lưu có chủ đích vì tra lịch sử theo khách (F5.3) và được trigger giữ khớp.
- Showtime không lưu cinema_id vì auditorium_id --> cinema_id (bắc cầu); tương tự ticket không lưu showtime_id riêng ngoài khoá ghép (showtime_id, seat_id) là danh tính ghế của vé.
- Gộp ba bảng nhân viên: ở 1.x có ba quan hệ box_office_clerk, ticket_checker, cinema_manager cùng lược đồ (id, cinema_id, email, password_hash, full_name, active). Cùng tập FD (id --> mọi cột, email --> id) và BR-95 buộc email duy nhất trên cả ba, nên gộp thành staff(id, email, full_name, password_hash, role, cinema_id, status, last_changed_at, access_changed_at); cột active (BOOLEAN) thành status (ACTIVE, LOCKED, ST-12). Việc gộp là để một khoá ứng viên duy nhất giữ được BR-95, không phi chuẩn hoá.
- Tài khoản quản trị viên không vào staff (không thuộc bốn vai trò, không có mốc truy cập, Q-271); không có FD chung nên không gộp.
- Sức chứa của suất chiếu không lưu: sức chứa = số dòng seat_status của suất chiếu (đã đóng băng từ lúc mở bán, BR-118), lưu thêm sẽ là FD showtime_id --> capacity trùng với count(seat_status).

### F5.3. Phi chuẩn hoá có chủ đích

| TBL.cột | Dạng phi chuẩn hoá | Lý do (NFR / BR, số liệu) | Cơ chế giữ nhất quán |
|---|---|---|---|
| seat_hold.expiry_time | Cột dẫn xuất lưu sẵn từ hold_time cộng 10 phút | Công việc nền quét hết hạn theo chỉ mục từng phần trên expiry_time (NFR-07: ghế trả về trong 1 phút; 4.000 lần giữ ghế hết hạn cùng giây, P09 F7.4); BR-10 là hằng cố định của hệ thống (Q-140): đổi giá trị là phát hành lại kèm di trú dữ liệu và ràng buộc, không cấu hình được lúc chạy | CHECK ck_seat_hold_expiry; cả hai cột do ứng dụng ghi một lần lúc INSERT từ cùng một giá trị đồng hồ CSDL và bất biến (trigger chặn sửa trạng thái cuối) |
| seat_status.state | Trạng thái dẫn xuất từ mẫu NULL của current_hold_id và current_ticket_id | Ảnh chụp sơ đồ ghế đọc trạng thái trong một câu SQL cho 400 ghế (NFR-08) và ST-02 có thuộc tính state | CHECK ck_seat_status_state_link bắt buộc state khớp hai liên kết và held_price; trigger trg_seat_status_state chặn chuyển trạng thái sai |
| seat_status.held_price, ticket.price | Giá vé sao chép từ bảng giá tại thời điểm chốt | Giá lịch sử, không phải dư thừa: bảng giá đổi sau đó không đổi giá đã chốt (BR-65, BR-67) | Chỉ ghi lúc chốt (EX-01) và lúc bán (EX-02, EX-03); không có đường cập nhật theo bảng giá |
| seat_status.event_seq | Cột kỹ thuật lưu mã seat_event gần nhất của ghế | Trình duyệt chỉ áp sự kiện có mã lớn hơn event_seq của ghế (P09 F7.5 điểm 5) và ảnh chụp trả kèm mã | Ghi trong cùng câu UPDATE đổi ghế, sau khi INSERT seat_event nhận mã |
| payment_transaction.refunded_total | Tổng khoản hoàn lưu sẵn thay vì SUM(refund_request) | Kiểm hạn mức BR-26 phải nguyên tử giữa hai vé huỷ đồng thời (X-16); SUM cần khoá cả tập yêu cầu hoàn | Cộng trong chính câu UPDATE dưới khoá hạng 7; CHECK ck_payment_transaction_refund_limit; đối soát bằng truy vấn SUM trong kiểm thử |
| seat_event.items | Danh sách (ghế, trạng thái) trong cột JSONB thay vì bảng con | P09 F7.5: một lần giữ nhóm 8 ghế là một dòng sự kiện, đọc nguyên khối để phát SSE; mỗi dòng tối đa số ghế của phòng (400) | CHECK ck_seat_event_items (mảng khác rỗng); không truy vấn theo phần tử; dòng bị xoá sau 10 phút |
| price_entry.removed | Mục giá đã bỏ vẫn giữ dòng để lưu mốc thay đổi của tổ hợp | P08 F3: entryChangeTimes ghi mốc của từng tổ hợp, kể cả tổ hợp đã bỏ, để BR-63 từ chối yêu cầu đặt giá dựa trên màn hình cũ | Mọi truy vấn bảng giá hiện hành lọc removed = FALSE; EX-12 đặt removed = TRUE và last_changed_at trong một câu |
| booking.customer_id | Sao chép khách giữ ghế của seat_hold (R-65: Customer 0..1 - Booking 0..*) | UC-007 liệt kê các lần đặt của khách từ gần nhất (BR-94, Q-322): tra theo (customer_id, booked_at DESC) không phải join seat_hold rồi lọc customer_id, và một lần đặt tại quầy có customer_id NULL | trg_booking_customer chặn customer_id khác khách của lần giữ ghế (cả INSERT lẫn UPDATE); fk_booking_customer; cột chỉ ghi lúc INSERT booking trong EX-02, EX-03 |
| ticket.movie_title, cinema_name, auditorium_name, auditorium_type, price | Giá trị lúc bán sao chép từ phim, cụm rạp, phòng chiếu, bảng giá | Không phải dư thừa: vé và email ghi tên phim, cụm rạp, phòng lúc bán, sửa tên sau đó không đổi vé đã bán (BR-140, BR-67; P12 DC-Ticket {readOnly}) | Chỉ ghi lúc INSERT ticket; trg_ticket_sale_values chặn mọi UPDATE các cột này; NOT NULL |
| staff.last_changed_at, access_changed_at | Mốc lưu hai cột riêng thay vì một | access_changed_at chỉ đổi khi khoá, đổi vai trò, đổi cụm rạp (BR-101); last_changed_at đổi cả khi sửa họ tên hoặc đặt lại mật khẩu (BR-102): sửa họ tên không được thu hồi phiên đang mở | Ứng dụng đặt trong cùng câu UPDATE ở EX-22 (C-33) |

## F6. Mô hình vật lý

### F6.1. Bảng cột

| TBL | Tên bảng | Cột | Kiểu | PK/FK/UQ | NULL | Mặc định | Nguồn DC | Tham chiếu FK (TBL.cột, ON DELETE, ON UPDATE) | CHECK / mô tả |
|---|---|---|---|---|---|---|---|---|---|
| TBL-01 | seat_hold | id | BIGINT | PK | NOT NULL | identity | DC-SeatHold.id |  | Định danh gán khi lưu; khoá hạng 5 |
| TBL-01 | seat_hold | showtime_id | BIGINT | FK | NOT NULL |  | R-46 | TBL-09.id, RESTRICT, NO ACTION (fk_seat_hold_showtime) | Suất chiếu của cả nhóm ghế (BR-07) |
| TBL-01 | seat_hold | customer_id | BIGINT | FK | NULL |  | R-48 | TBL-07.id, RESTRICT, NO ACTION (fk_seat_hold_customer) | Người giữ là khách; đúng một trong hai cột người giữ khác NULL (ck_seat_hold_one_holder) |
| TBL-01 | seat_hold | box_office_clerk_id | BIGINT | FK | NULL |  | R-49 | TBL-08.id, RESTRICT, NO ACTION (fk_seat_hold_staff) | Người giữ là nhân viên quầy (dòng staff có role BOX_OFFICE_CLERK, R-67); xor với customer_id; vai trò kiểm ở ứng dụng (C-24) |
| TBL-01 | seat_hold | hold_ref | VARCHAR(36) | UQ | NOT NULL |  | DC-SeatHold.holdRef |  | UUID v4 dạng chữ (Thiết kế: 36 ký tự của UUID) |
| TBL-01 | seat_hold | request_id | VARCHAR(36) | UQ | NOT NULL |  | DC-SeatHold.requestId |  | UUID do trình duyệt sinh; xác nhận lặp an toàn (P09 F7.3 EX-01) |
| TBL-01 | seat_hold | status | VARCHAR(16) |  | NOT NULL | ACTIVE | DC-SeatHold.status |  | ACTIVE, COMPLETED, EXPIRED, CANCELLED, PAYMENT_FAILED (ST-01); trạng thái cuối không đổi (trg_seat_hold_status) |
| TBL-01 | seat_hold | hold_time | TIMESTAMPTZ |  | NOT NULL |  | DC-SeatHold.holdTime |  | Đồng hồ CSDL lúc giữ thành công |
| TBL-01 | seat_hold | expiry_time | TIMESTAMPTZ |  | NOT NULL |  | DC-SeatHold.expiryTime |  | Bằng hold_time cộng 10 phút (BR-10, ck_seat_hold_expiry) |
| TBL-02 | seat_status | showtime_id | BIGINT | PK, FK | NOT NULL |  | R-44 | TBL-09.id, RESTRICT, NO ACTION (fk_seat_status_showtime); TBL-01.showtime_id, RESTRICT, NO ACTION (FK ghép fk_seat_status_seat_hold); TBL-06.showtime_id, RESTRICT, NO ACTION (FK ghép fk_seat_status_ticket) | Thành phần 1 của DC-SeatKey; thứ tự khoá hạng 6 theo (showtime_id, seat_id); khoá chính ghép pk_seat_status |
| TBL-02 | seat_status | seat_id | BIGINT | PK, FK | NOT NULL |  | R-45 | TBL-15.id, RESTRICT, NO ACTION (fk_seat_status_seat); TBL-06.seat_id, RESTRICT, NO ACTION (FK ghép fk_seat_status_ticket) | Thành phần 2 của DC-SeatKey; khoá chính ghép pk_seat_status |
| TBL-02 | seat_status | state | VARCHAR(10) |  | NOT NULL | AVAILABLE | DC-SeatStatus.state |  | AVAILABLE, HELD, SOLD (ST-02); khớp liên kết hiện tại (ck_seat_status_state_link); đổi trạng thái hợp lệ (trg_seat_status_state) |
| TBL-02 | seat_status | held_price | BIGINT |  | NULL |  | DC-SeatStatus.heldPrice |  | Giá đã chốt (BR-65); có khi HELD hoặc SOLD; đồng; lớn hơn 0 |
| TBL-02 | seat_status | current_hold_id | BIGINT | FK | NULL |  | R-63 | TBL-01.id, RESTRICT, NO ACTION (FK ghép fk_seat_status_seat_hold) | Lần giữ ghế hiện tại; khác NULL khi HELD |
| TBL-02 | seat_status | current_ticket_id | BIGINT | FK | NULL |  | R-64 | TBL-06.id, RESTRICT, NO ACTION (FK ghép fk_seat_status_ticket) | Vé hiện tại; khác NULL khi SOLD; mỗi vé chiếm tối đa một ghế (uq_seat_status_current_ticket) |
| TBL-02 | seat_status | event_seq | BIGINT |  | NOT NULL | 0 | Thiết kế: P09 F7.5 điểm 1 |  | Mã seat_event của thay đổi gần nhất của ghế; 0 là chưa có sự kiện; ghi trong cùng câu UPDATE đổi ghế |
| TBL-03 | payment_transaction | id | BIGINT | PK | NOT NULL | identity | DC-PaymentTransaction.id |  | Định danh gán khi lưu; khoá hạng 7 |
| TBL-03 | payment_transaction | seat_hold_id | BIGINT | FK | NOT NULL |  | R-50 | TBL-01.id, RESTRICT, NO ACTION (fk_payment_transaction_seat_hold) | Lần giữ ghế được thanh toán; mỗi lần bấm thanh toán là một dòng mới (BR-90) |
| TBL-03 | payment_transaction | code | VARCHAR(20) | UQ | NOT NULL |  | DC-PaymentTransaction.code |  | 20 chữ số do hệ thống sinh, gửi cổng làm mã tham chiếu (Thiết kế: giới hạn trường mã của cổng, P12 IF-24); báo trùng nhận ra qua cột này |
| TBL-03 | payment_transaction | amount | BIGINT |  | NOT NULL |  | DC-PaymentTransaction.amount |  | Đồng; lớn hơn 0 (ck_payment_transaction_amount) |
| TBL-03 | payment_transaction | status | VARCHAR(16) |  | NOT NULL | PENDING | DC-PaymentTransaction.status |  | PENDING, FAILED, TICKETED, LATE_PAYMENT (ST-05); đổi trạng thái hợp lệ (trg_payment_transaction_status) |
| TBL-03 | payment_transaction | gateway_transaction_no | VARCHAR(30) |  | NULL |  | DC-PaymentTransaction.gatewayTransactionNo |  | Mã giao dịch do cổng cấp (Thiết kế: dự phòng độ dài); NOT NULL khi TICKETED hoặc LATE_PAYMENT; unique từng phần; chỉ ghi khi báo thành công (MarkTicketed, MarkLatePayment), RecordFailure không ghi để báo thất bại lặp (mã 0 của VNPay) không vi phạm chỉ mục unique |
| TBL-03 | payment_transaction | paid_at | TIMESTAMPTZ |  | NULL |  | DC-PaymentTransaction.paidAt |  | NOT NULL khi TICKETED hoặc LATE_PAYMENT |
| TBL-03 | payment_transaction | late_reason | VARCHAR(200) |  | NULL |  | DC-PaymentTransaction.lateReason |  | Lý do hoàn của thanh toán trễ (Thiết kế: độ dài dự phòng); NOT NULL khi LATE_PAYMENT |
| TBL-03 | payment_transaction | refunded_total | BIGINT |  | NOT NULL | 0 | DC-PaymentTransaction.refundedTotal |  | Tổng đã hoàn; không vượt amount (BR-26, ck_payment_transaction_refund_limit); cộng bằng phép cộng trong câu UPDATE |
| TBL-03 | payment_transaction | duplicate_report_count | INTEGER |  | NOT NULL | 0 | DC-PaymentTransaction.duplicateReportCount |  | Số lần báo trùng (BR-37); không âm |
| TBL-04 | refund_request | id | BIGINT | PK | NOT NULL | identity | DC-RefundRequest.id |  | Định danh gán khi lưu; khoá hạng 9 |
| TBL-04 | refund_request | payment_transaction_id | BIGINT | FK | NULL |  | R-55 | TBL-03.id, RESTRICT, NO ACTION (fk_refund_request_payment_transaction) | NULL với hoàn tiền mặt (TICKET_CASH); NOT NULL với FULL và TICKET_GATEWAY (ck_refund_request_link) |
| TBL-04 | refund_request | ticket_id | BIGINT | FK, UQ | NULL |  | R-56 | TBL-06.id, RESTRICT, NO ACTION (fk_refund_request_ticket) | NULL với hoàn toàn bộ (FULL); mỗi vé tối đa một yêu cầu hoàn (BR-21) |
| TBL-04 | refund_request | idempotency_key | VARCHAR(64) | UQ | NOT NULL |  | DC-RefundRequest.idempotencyKey |  | Khoá chống hoàn trùng, gửi nguyên cho cổng ở mọi lần thử (BR-43); không đổi (Thiết kế: 64 ký tự cho khoá dựng từ mã giao dịch 20 ký tự và loại yêu cầu) |
| TBL-04 | refund_request | request_type | VARCHAR(16) |  | NOT NULL |  | DC-RefundRequest.requestType |  | FULL, TICKET_GATEWAY, TICKET_CASH (DC-RefundType) |
| TBL-04 | refund_request | refund_amount | BIGINT |  | NOT NULL |  | DC-RefundRequest.refundAmount |  | Đồng; lớn hơn 0 |
| TBL-04 | refund_request | attempt_count | INTEGER |  | NOT NULL | 0 | DC-RefundRequest.attemptCount |  | 0 đến 4: một lần đầu cộng 3 lần thử lại (BR-41, P09 F7.7) |
| TBL-04 | refund_request | status | VARCHAR(16) |  | NOT NULL | NEW | DC-RefundRequest.status |  | NEW, IN_FLIGHT, WAITING_RETRY, REFUNDED, MANUAL_REQUIRED (ST-04); REFUNDED và MANUAL_REQUIRED không đổi (trg_refund_request_status) |
| TBL-04 | refund_request | refund_result | VARCHAR(200) |  | NULL |  | DC-RefundRequest.refundResult |  | Mã kết quả hoặc lý do lỗi của lần gửi cuối (Thiết kế: độ dài dự phòng) |
| TBL-05 | booking | id | BIGINT | PK | NOT NULL | identity | DC-Booking.id |  | Định danh gán khi lưu |
| TBL-05 | booking | booking_code | VARCHAR(16) | UQ | NOT NULL |  | DC-Booking.bookingCode |  | Mã đặt vé duy nhất toàn hệ thống (BR-80); Thiết kế: 16 ký tự như mã vé |
| TBL-05 | booking | seat_hold_id | BIGINT | FK, UQ | NOT NULL |  | R-51 | TBL-01.id, RESTRICT, NO ACTION (fk_booking_seat_hold) | Mỗi lần giữ ghế dẫn tới tối đa một lần đặt; kênh mua và người mua suy ra qua lần giữ ghế (DC-Booking./channel, /buyerId không lưu) |
| TBL-05 | booking | customer_id | BIGINT | FK | NULL |  | R-65 | TBL-07.id, RESTRICT, NO ACTION (fk_booking_customer) | Khách mua; NULL với lần đặt tại quầy (người giữ ghế là nhân viên quầy, BR-17, BR-20); bản sao của seat_hold.customer_id, khớp bằng trg_booking_customer (C-25, F5.3) |
| TBL-05 | booking | booked_at | TIMESTAMPTZ |  | NOT NULL |  | DC-Booking.bookedAt |  | Thời điểm bán (now của Sell, đồng hồ CSDL); khoá sắp xếp lịch sử từ gần nhất trước (BR-94); ix_booking_customer_booked |
| TBL-06 | ticket | id | BIGINT | PK | NOT NULL | identity | DC-Ticket.id |  | Định danh gán khi lưu; khoá hạng 8 |
| TBL-06 | ticket | booking_id | BIGINT | FK | NOT NULL |  | R-52 | TBL-05.id, RESTRICT, NO ACTION (fk_ticket_booking) | Lần đặt chứa vé; vé đã huỷ vẫn thuộc lần đặt |
| TBL-06 | ticket | showtime_id | BIGINT | FK | NOT NULL |  | R-53, R-54 | TBL-02.showtime_id, RESTRICT, NO ACTION (FK ghép fk_ticket_seat_status) | Suất chiếu của vé, một nửa khoá ghép tới seat_status; không có FK riêng tới showtime vì đã đi qua seat_status |
| TBL-06 | ticket | seat_id | BIGINT | FK | NOT NULL |  | R-54 | TBL-02.seat_id, RESTRICT, NO ACTION (FK ghép fk_ticket_seat_status) | Ghế của vé, nửa còn lại của khoá ghép tới seat_status |
| TBL-06 | ticket | ticket_code | VARCHAR(16) | UQ | NOT NULL |  | DC-Ticket.ticketCode |  | Mã vé 16 ký tự ngẫu nhiên, cũng là nội dung mã QR (NFR-14, P12 IF-24) |
| TBL-06 | ticket | price | BIGINT |  | NOT NULL |  | DC-Ticket.price |  | Giá đã chốt, giữ nguyên khi bảng giá đổi (BR-67); đồng; lớn hơn 0; không sửa được sau khi tạo (trg_ticket_sale_values) |
| TBL-06 | ticket | movie_title | VARCHAR(200) |  | NOT NULL |  | DC-Ticket.movieTitle |  | Tên phim lúc bán (BR-140); độ dài bằng movie.title; không đổi khi phim sửa |
| TBL-06 | ticket | cinema_name | VARCHAR(100) |  | NOT NULL |  | DC-Ticket.cinemaName |  | Tên cụm rạp lúc bán (BR-140); độ dài bằng cinema.name |
| TBL-06 | ticket | auditorium_name | VARCHAR(50) |  | NOT NULL |  | DC-Ticket.auditoriumName |  | Tên phòng chiếu lúc bán (BR-140); độ dài bằng auditorium.name |
| TBL-06 | ticket | auditorium_type | VARCHAR(10) |  | NOT NULL |  | DC-Ticket.auditoriumType |  | Loại phòng lúc bán: STANDARD, 4DX, IMAX (BR-140, ck_ticket_auditorium_type) |
| TBL-06 | ticket | status | VARCHAR(10) |  | NOT NULL | UNUSED | DC-Ticket.status |  | UNUSED, USED, CANCELLED (ST-03); USED và CANCELLED không đổi (trg_ticket_status) |
| TBL-07 | customer | id | BIGINT | PK | NOT NULL | identity | DC-Customer.id |  | Định danh; khoá hạng 4 |
| TBL-07 | customer | email | VARCHAR(254) | UQ | NOT NULL |  | DC-Customer.email |  | Thiết kế: 254 ký tự theo RFC 5321; duy nhất theo norm_email (uq_customer_email_norm, không phân biệt hoa thường, chữ có dấu, khoảng trắng đầu cuối); định dạng email chuẩn kiểm trên giá trị chuẩn hoá (BR-81, ck_customer_email_format) |
| TBL-07 | customer | phone_number | VARCHAR(10) | UQ | NOT NULL |  | DC-Customer.phoneNumber |  | Số Việt Nam 10 chữ số bắt đầu bằng 0 (BR-82, ck_customer_phone_format); duy nhất nguyên giá trị (uq_customer_phone_number, BR-98) |
| TBL-07 | customer | password_hash | VARCHAR(255) |  | NOT NULL |  | DC-Customer.passwordHash |  | Mã băm một chiều (NFR-02); Thiết kế: 255 ký tự đủ cho bcrypt và argon2; không lưu mật khẩu rõ |
| TBL-08 | staff | id | BIGINT | PK | NOT NULL | identity | DC-Staff.id |  | Định danh dòng staff cũng là định danh của nhân viên quầy, nhân viên soát vé, quản lý cụm rạp; khoá hạng 4 |
| TBL-08 | staff | email | VARCHAR(254) | UQ | NOT NULL |  | DC-Staff.email |  | Thiết kế: 254 ký tự theo RFC 5321 (Q-273); duy nhất theo norm_email trên mọi vai trò (uq_staff_email_norm, BR-95); không đổi sau khi tạo (trg_staff_email, Q-162) |
| TBL-08 | staff | full_name | VARCHAR(100) |  | NOT NULL |  | DC-Staff.fullName |  | Họ tên, không rỗng, tối đa 100 ký tự (Q-163, Q-273, ck_staff_full_name_not_blank) |
| TBL-08 | staff | password_hash | VARCHAR(255) |  | NOT NULL |  | DC-Staff.passwordHash |  | Mã băm một chiều (NFR-02); Thiết kế: 255 ký tự đủ cho bcrypt và argon2; không lưu mật khẩu rõ |
| TBL-08 | staff | role | VARCHAR(16) |  | NOT NULL |  | DC-Staff.role |  | BOX_OFFICE_CLERK, TICKET_CHECKER, CINEMA_MANAGER, CHAIN_MANAGER (BR-79, ck_staff_role); đổi vai trò là UPDATE cột này (UC-017 luồng 1a) |
| TBL-08 | staff | cinema_id | BIGINT | FK | NULL |  | R-66 | TBL-13.id, RESTRICT, NO ACTION (fk_staff_cinema) | Cụm rạp của nhân viên; NULL khi và chỉ khi role là CHAIN_MANAGER (BR-78, ck_staff_role_cinema) |
| TBL-08 | staff | status | VARCHAR(8) |  | NOT NULL | ACTIVE | DC-Staff.status |  | ACTIVE (Đang hoạt động), LOCKED (Bị khoá) (ST-12, BR-96, BR-97, ck_staff_status); tài khoản chỉ khoá, không xoá vì lần giữ ghế cũ còn trỏ tới (RESTRICT) |
| TBL-08 | staff | last_changed_at | TIMESTAMPTZ |  | NOT NULL |  | DC-Staff.lastChangedAt |  | Mốc thay đổi, so bằng nhau ở micro giây ở mọi thao tác ghi (BR-102); đồng hồ CSDL |
| TBL-08 | staff | access_changed_at | TIMESTAMPTZ |  | NOT NULL |  | DC-Staff.accessChangedAt |  | Mốc thay đổi quyền truy cập: khoá, đổi vai trò, đổi cụm rạp (BR-101); đăng nhập đọc giá trị này vào mã phiên, mỗi yêu cầu so bằng nhau (P09 F7.11); đồng hồ CSDL |
| TBL-09 | showtime | id | BIGINT | PK | NOT NULL | identity | DC-Showtime.id |  | Định danh gán khi lưu; khoá hạng 3 |
| TBL-09 | showtime | auditorium_id | BIGINT | FK | NOT NULL |  | R-42 | TBL-14.id, RESTRICT, NO ACTION (fk_showtime_auditorium) | Phòng chiếu; cụm rạp suy ra qua phòng chiếu (DC-Showtime./cinemaId không lưu) |
| TBL-09 | showtime | movie_id | BIGINT | FK | NOT NULL |  | R-43 | TBL-16.id, RESTRICT, NO ACTION (fk_showtime_movie) | Phim của suất chiếu |
| TBL-09 | showtime | start_time | TIMESTAMPTZ |  | NOT NULL |  | DC-Showtime.startTime |  | Giờ bắt đầu |
| TBL-09 | showtime | sale_open_time | TIMESTAMPTZ |  | NOT NULL |  | DC-Showtime.saleOpenTime |  | Thời điểm mở bán, trước start_time (BR-55) |
| TBL-09 | showtime | end_time | TIMESTAMPTZ |  | NOT NULL |  | DC-Showtime.endTime |  | Giờ kết thúc = giờ bắt đầu cộng thời lượng phim tại lúc lập (BR-50); lưu vì thời lượng phim có thể đổi sau (BR-84) |
| TBL-09 | showtime | last_changed_at | TIMESTAMPTZ |  | NOT NULL |  | DC-Showtime.lastChangedAt |  | Mốc thay đổi, so ở BR-54 |
| TBL-09 | showtime | movie_format | VARCHAR(2) |  | NOT NULL |  | DC-Showtime.movieFormat |  | 2D hoặc 3D (GL-05) |
| TBL-09 | showtime | status | VARCHAR(12) |  | NOT NULL | IN_SCHEDULE | DC-Showtime.status |  | IN_SCHEDULE, DELETED (xoá mềm, BR-58) |
| TBL-10 | price_list | cinema_id | BIGINT | PK, FK | NOT NULL |  | R-40 | TBL-13.id, RESTRICT, NO ACTION (fk_price_list_cinema) | Mỗi cụm rạp đúng một bảng giá (GL-01); là khoá khoá hạng 1 |
| TBL-13 | cinema | id | BIGINT | PK | NOT NULL | identity | AC-E-Cinema (P08) |  | Định danh |
| TBL-13 | cinema | name | VARCHAR(100) |  | NOT NULL |  | DC-Cinema.name |  | Thiết kế: 100 ký tự cho tên cụm rạp; không rỗng; duy nhất theo norm_name (uq_cinema_name_norm, BR-141) |
| TBL-13 | cinema | province | VARCHAR(100) |  | NOT NULL |  | DC-Cinema.province |  | Tỉnh, thành phố (Q-204), căn cứ khách lọc lịch chiếu (REQ-10); Thiết kế: 100 ký tự; không rỗng |
| TBL-13 | cinema | address | VARCHAR(255) |  | NULL |  | DC-Cinema.address |  | Địa chỉ cụm rạp, không bắt buộc (multiplicity 0..1) |
| TBL-13 | cinema | last_changed_at | TIMESTAMPTZ |  | NOT NULL |  | DC-Cinema.lastChangedAt |  | Mốc thay đổi (BR-142, Q-247) |
| TBL-14 | auditorium | id | BIGINT | PK | NOT NULL | identity | AC-E-Auditorium (P08) |  | Định danh; khoá hạng 2 |
| TBL-14 | auditorium | cinema_id | BIGINT | FK | NOT NULL |  | R-38 | TBL-13.id, RESTRICT, NO ACTION (fk_auditorium_cinema) | Cụm rạp chứa phòng chiếu |
| TBL-14 | auditorium | name | VARCHAR(50) |  | NOT NULL |  | DC-Auditorium.name |  | Thiết kế: 50 ký tự cho tên phòng; không rỗng; duy nhất trong cụm rạp theo norm_name (uq_auditorium_cinema_name_norm, BR-145) |
| TBL-14 | auditorium | auditorium_type | VARCHAR(10) |  | NOT NULL |  | AC-E-Auditorium.auditoriumType |  | STANDARD, 4DX, IMAX (GL-27) |
| TBL-14 | auditorium | last_changed_at | TIMESTAMPTZ |  | NOT NULL |  | DC-Auditorium.lastChangedAt |  | Mốc thay đổi (BR-146, Q-247) |
| TBL-15 | seat | id | BIGINT | PK | NOT NULL | identity | AC-E-Seat (P08) |  | Định danh; SeatId |
| TBL-15 | seat | auditorium_id | BIGINT | FK | NOT NULL |  | R-39 | TBL-14.id, RESTRICT, NO ACTION (fk_seat_auditorium) | Phòng chiếu chứa ghế |
| TBL-15 | seat | row_code | VARCHAR(3) |  | NOT NULL |  | DC-Seat.rowCode |  | Mã hàng (Thiết kế: tối đa 3 ký tự, ví dụ F, AA; không rỗng); duy nhất theo (auditorium_id, row_code, seat_number) chỉ trong các ghế đang trong sơ đồ (uq_seat_position) |
| TBL-15 | seat | seat_number | INTEGER |  | NOT NULL |  | AC-E-Seat.seatPosition |  | Số ghế trong hàng; lớn hơn 0 |
| TBL-15 | seat | seat_type | VARCHAR(10) |  | NOT NULL |  | AC-E-Seat.seatType |  | STANDARD, VIP, COUPLE (GL-26); ghế đôi là một ghế (BR-06) |
| TBL-15 | seat | in_seat_map | BOOLEAN |  | NOT NULL | TRUE | DC-Seat.mapState |  | TRUE: đang trong sơ đồ ghế (IN_MAP); FALSE: đã bỏ khỏi sơ đồ (RETIRED), vẫn giữ cho seat_status của suất chiếu đã kết thúc hoặc đã xoá (BR-118); một chiều TRUE sang FALSE (trg_seat_in_seat_map, ST-07) |
| TBL-16 | movie | id | BIGINT | PK | NOT NULL | identity | AC-E-Movie (P08) |  | Định danh |
| TBL-16 | movie | title | VARCHAR(200) |  | NOT NULL |  | DC-Movie.title |  | Thiết kế: 200 ký tự cho tên phim; không rỗng; được trùng tên phim khác (Q-200) |
| TBL-16 | movie | duration_minutes | INTEGER |  | NOT NULL |  | AC-E-Movie.duration |  | Thời lượng, phút; lớn hơn 0 (BR-50) |
| TBL-16 | movie | release_date | DATE |  | NOT NULL |  | AC-E-Movie.releaseDate |  | Ngày khởi chiếu (BR-76) |
| TBL-16 | movie | end_of_run_date | DATE |  | NOT NULL |  | AC-E-Movie.endOfRunDate |  | Ngày kết thúc chiếu, không trước ngày khởi chiếu (BR-49) |
| TBL-16 | movie | genre | VARCHAR(50) |  | NOT NULL |  | DC-Movie.genre |  | Thể loại, một giá trị, không rỗng (P12 multiplicity 1; P04 UC-010 ghi không bắt buộc, xem Đề xuất sửa artifact trước) |
| TBL-16 | movie | age_rating | VARCHAR(10) |  | NOT NULL |  | DC-Movie.ageRating |  | Nhãn P, K, T13, T16, T18, C (Q-199, ck_movie_age_rating) |
| TBL-16 | movie | description | TEXT |  | NOT NULL | '' | DC-Movie.description |  | Mô tả phim, độ dài không giới hạn; rỗng được (UC-010 không bắt buộc), nên mặc định chuỗi rỗng thay vì NULL |
| TBL-16 | movie | trailer | VARCHAR(2048) |  | NULL |  | DC-Movie.trailer |  | Đường dẫn tới video ngoài hệ thống (Q-198, Q-199), không bắt buộc; Thiết kế: 2048 ký tự là độ dài URL thông dụng; không chỉ có khoảng trắng |
| TBL-16 | movie | last_changed_at | TIMESTAMPTZ |  | NOT NULL |  | DC-Movie.lastChangedAt |  | Mốc thay đổi (BR-138, Q-247); mã phim hiển thị (movieCode) suy từ id nên không có cột |
| TBL-17 | price_entry | cinema_id | BIGINT | PK, FK | NOT NULL |  | R-41 | TBL-10.cinema_id, CASCADE, NO ACTION (fk_price_entry_price_list) | Bảng giá chứa mục giá (composition); khoá chính ghép pk_price_entry |
| TBL-17 | price_entry | auditorium_type | VARCHAR(10) | PK | NOT NULL |  | AC-E-PriceEntry.auditoriumType |  | STANDARD, 4DX, IMAX; khoá chính ghép pk_price_entry |
| TBL-17 | price_entry | movie_format | VARCHAR(2) | PK | NOT NULL |  | AC-E-PriceEntry.movieFormat |  | 2D, 3D; khoá chính ghép pk_price_entry |
| TBL-17 | price_entry | seat_type | VARCHAR(10) | PK | NOT NULL |  | AC-E-PriceEntry.seatType |  | STANDARD, VIP, COUPLE; khoá chính ghép pk_price_entry |
| TBL-17 | price_entry | time_band | VARCHAR(20) | PK | NOT NULL |  | AC-E-PriceEntry.timeBand |  | WEEKDAY_BEFORE_17, WEEKDAY_FROM_17, WEEKEND_BEFORE_17, WEEKEND_FROM_17 (BR-12); khoá chính ghép pk_price_entry |
| TBL-17 | price_entry | ticket_price | BIGINT |  | NOT NULL |  | AC-E-PriceEntry.ticketPrice |  | Số nguyên đồng lớn hơn 0 (BR-70) |
| TBL-17 | price_entry | last_changed_at | TIMESTAMPTZ |  | NOT NULL |  | AC-E-PriceEntry.lastChangedAt |  | Mốc thay đổi của tổ hợp, so ở BR-63 |
| TBL-17 | price_entry | removed | BOOLEAN |  | NOT NULL | FALSE | AC-E-PriceList.entryChangeTimes |  | TRUE là mục giá đã bỏ khỏi bảng giá nhưng vẫn giữ mốc thay đổi của tổ hợp (BR-63, P08 F3: kể cả tổ hợp đã bỏ) |
| TBL-18 | movie_format | movie_id | BIGINT | PK, FK | NOT NULL |  | AC-E-Movie.releaseFormats | TBL-16.id, CASCADE, NO ACTION (fk_movie_format_movie) | Phim; khoá chính ghép pk_movie_format |
| TBL-18 | movie_format | movie_format | VARCHAR(2) | PK | NOT NULL |  | AC-E-Movie.releaseFormats |  | Định dạng phát hành: 2D, 3D (BR-47); khoá chính ghép pk_movie_format |
| TBL-19 | auditorium_format | auditorium_id | BIGINT | PK, FK | NOT NULL |  | AC-E-Auditorium.supportedFormats | TBL-14.id, CASCADE, NO ACTION (fk_auditorium_format_auditorium) | Phòng chiếu; khoá chính ghép pk_auditorium_format |
| TBL-19 | auditorium_format | movie_format | VARCHAR(2) | PK | NOT NULL |  | AC-E-Auditorium.supportedFormats |  | Định dạng chiếu được: 2D, 3D (BR-48); khoá chính ghép pk_auditorium_format |
| TBL-20 | seat_event | id | BIGINT | PK | NOT NULL | identity | DC-SeatChangeEvent.eventId |  | Mã sự kiện tăng dần từ sequence của cột identity (GENERATED BY DEFAULT nên nhận mã lấy trước bằng nextval); lấy mã không chờ commit của giao dịch khác; dòng được INSERT như câu ghi cuối ngay trước COMMIT (P09 F7.5) |
| TBL-20 | seat_event | showtime_id | BIGINT |  | NOT NULL |  | DC-SeatChangeEvent.showtimeId |  | Không khai báo khoá ngoại để không sinh khoá ngầm lên dòng cha (P09 F7.3) |
| TBL-20 | seat_event | created_at | TIMESTAMPTZ |  | NOT NULL | clock_timestamp() | DC-SeatChangeEvent.createdAt |  | Đồng hồ CSDL lúc INSERT, không phải lúc BEGIN (P12 DC-SeatEventWriter.Append) |
| TBL-20 | seat_event | items | JSONB |  | NOT NULL |  | DC-SeatChangeEvent.items |  | Mảng các đối tượng seat_id và state mới, ví dụ [{"seat_id": 12, "state": "HELD"}]; một lần giữ nhóm 8 ghế là một dòng |
| TBL-21 | outbox | id | BIGINT | PK | NOT NULL | identity | DC-OutboxEntry.id |  | Định danh dòng hàng đợi |
| TBL-21 | outbox | kind | VARCHAR(16) |  | NOT NULL |  | DC-OutboxEntry.kind |  | REFUND_GATEWAY, EMAIL_TICKET, EMAIL_REFUND (DC-OutboxKind) |
| TBL-21 | outbox | source_id | BIGINT |  | NOT NULL |  | DC-OutboxEntry.sourceId |  | Mã bản ghi nguồn (refund_request.id hoặc booking.id theo kind); không khai báo khoá ngoại (P09 F7.3) |
| TBL-21 | outbox | status | VARCHAR(10) |  | NOT NULL | PENDING | DC-OutboxEntry.status |  | PENDING, SUCCEEDED, EXHAUSTED (DC-OutboxStatus); SUCCEEDED và EXHAUSTED không đổi (trg_outbox_status) |
| TBL-21 | outbox | attempt_count | INTEGER |  | NOT NULL | 0 | DC-OutboxEntry.attemptCount |  | Tăng khi claim; chỉ để theo dõi, số lần thử quyết định hết lượt là refund_request.attempt_count; không âm; không có cận trên vì dòng bị bỏ dở sau lần thứ 4 vẫn được nhận lại và phải đủ chỗ để tăng (P09 F7.7 bước 4), giới hạn 4 lần do bên xử lý kiểm |
| TBL-21 | outbox | next_attempt_at | TIMESTAMPTZ |  | NOT NULL | clock_timestamp() | DC-OutboxEntry.nextAttemptAt |  | Hẹn lại sau 1, 5, 15 phút |
| TBL-21 | outbox | claim_token | UUID |  | NULL |  | DC-OutboxEntry.claimToken |  | Mã ngẫu nhiên của bên đang claim; ghi kết quả có điều kiện claim_token còn là của mình |
| TBL-21 | outbox | claimed_until | TIMESTAMPTZ |  | NULL |  | DC-OutboxEntry.claimedUntil |  | Thời điểm CSDL cộng 120 giây lúc claim, được đặt lại cùng giá trị ở hàng rào giao dịch 1 của ProcessRefund; qua mốc này dòng được nhận lại |
| TBL-21 | outbox | idempotency_key | VARCHAR(100) | UQ | NOT NULL |  | DC-OutboxEntry.idempotencyKey |  | Thiết kế: 100 ký tự; với hoàn tiền bằng khoá chống hoàn trùng của yêu cầu hoàn; với email làm Message-ID |
| TBL-21 | outbox | last_error | VARCHAR(500) |  | NULL |  | DC-OutboxEntry.lastError |  | Thiết kế: 500 ký tự lỗi cuối |
| TBL-21 | outbox | created_at | TIMESTAMPTZ |  | NOT NULL | clock_timestamp() | Thiết kế: cột kỹ thuật |  | Thời điểm xếp hàng, phục vụ vận hành |
| TBL-22 | administrator | id | BIGINT | PK | NOT NULL | 1 | DC-AdministratorAccount.id |  | Luôn bằng 1: đúng một tài khoản (ck_administrator_single_row) |
| TBL-22 | administrator | email | VARCHAR(254) |  | NOT NULL |  | DC-AdministratorAccount.email |  | Thiết kế: 254 ký tự theo RFC 5321; định dạng email chuẩn kiểm trên giá trị chuẩn hoá; đăng nhập qua điểm đăng nhập của nhân viên (P09 F7.11) |
| TBL-22 | administrator | password_hash | VARCHAR(255) |  | NOT NULL |  | DC-AdministratorAccount.passwordHash |  | Mã băm một chiều (NFR-02); do cài đặt tạo, chưa có thao tác đổi mật khẩu (Q-271) |

Ràng buộc CHECK nhiều cột, EXCLUDE và khoá phụ trợ của khoá ngoại ghép:

| TBL | Ràng buộc | Biểu thức | Nguồn |
|---|---|---|---|
| TBL-01 | ck_seat_hold_status | status IN ('ACTIVE', 'COMPLETED', 'EXPIRED', 'CANCELLED', 'PAYMENT_FAILED') | ST-01, DC-HoldStatus |
| TBL-01 | ck_seat_hold_one_holder | num_nonnulls(customer_id, box_office_clerk_id) = 1 | R-48, R-49 {xor} |
| TBL-01 | ck_seat_hold_expiry | expiry_time = hold_time + interval '10 minutes' | BR-10 |
| TBL-01 | uq_seat_hold_id_showtime | UNIQUE (id, showtime_id) | Đích của khoá ngoại ghép (khoá phụ trợ, không phải khoá nghiệp vụ) |
| TBL-02 | ck_seat_status_state_link | (state = 'AVAILABLE' AND current_hold_id IS NULL AND current_ticket_id IS NULL AND held_price IS NULL) OR (state = 'HELD' AND current_hold_id IS NOT NULL AND current_ticket_id IS NULL AND held_price IS NOT NULL) OR (state = 'SOLD' AND current_hold_id IS NULL AND current_ticket_id IS NOT NULL AND held_price IS NOT NULL) | Bất bội của SeatStatus (P08 F3): Trống không liên kết; Đang được giữ đúng một lần giữ ghế; Đã bán đúng một vé |
| TBL-02 | ck_seat_status_price | held_price > 0 | BR-70 |
| TBL-02 | ck_seat_status_event_seq | event_seq >= 0 | Thiết kế |
| TBL-03 | ck_payment_transaction_status | status IN ('PENDING', 'FAILED', 'TICKETED', 'LATE_PAYMENT') | ST-05, DC-PaymentStatus |
| TBL-03 | ck_payment_transaction_amount | amount > 0 | DC-PaymentTransaction.amount {> 0} |
| TBL-03 | ck_payment_transaction_refund_limit | refunded_total >= 0 AND refunded_total <= amount | BR-26, P09 F7.3 EX-09 |
| TBL-03 | ck_payment_transaction_refund_paid | refunded_total = 0 OR status IN ('TICKETED', 'LATE_PAYMENT') | BR-26: chỉ giao dịch đã thanh toán thành công mới có khoản hoàn |
| TBL-03 | ck_payment_transaction_duplicate | duplicate_report_count >= 0 | BR-37 |
| TBL-03 | ck_payment_transaction_paid_info | status NOT IN ('TICKETED', 'LATE_PAYMENT') OR (paid_at IS NOT NULL AND gateway_transaction_no IS NOT NULL) | ST-05: báo thành công mang mã cổng và thời điểm |
| TBL-03 | ck_payment_transaction_late_reason | status <> 'LATE_PAYMENT' OR late_reason IS NOT NULL | BR-14, BR-15, ST-05 |
| TBL-04 | ck_refund_request_status | status IN ('NEW', 'IN_FLIGHT', 'WAITING_RETRY', 'REFUNDED', 'MANUAL_REQUIRED') | ST-04, DC-RefundStatus |
| TBL-04 | ck_refund_request_type | request_type IN ('FULL', 'TICKET_GATEWAY', 'TICKET_CASH') | DC-RefundType |
| TBL-04 | ck_refund_request_link | (request_type = 'FULL' AND payment_transaction_id IS NOT NULL AND ticket_id IS NULL) OR (request_type = 'TICKET_GATEWAY' AND payment_transaction_id IS NOT NULL AND ticket_id IS NOT NULL) OR (request_type = 'TICKET_CASH' AND payment_transaction_id IS NULL AND ticket_id IS NOT NULL) | R-55, R-56, BR-20 |
| TBL-04 | ck_refund_request_amount | refund_amount > 0 | DC-RefundRequest.refundAmount {> 0} |
| TBL-04 | ck_refund_request_attempts | attempt_count BETWEEN 0 AND 4 | BR-41, MaxAttempts |
| TBL-04 | ck_refund_request_attempt_status | (status <> 'NEW' OR attempt_count = 0) AND (status NOT IN ('IN_FLIGHT', 'WAITING_RETRY') OR attempt_count >= 1) AND (status <> 'REFUNDED' OR request_type = 'TICKET_CASH' OR attempt_count >= 1) | ST-04: lần gửi được đếm trước khi gọi cổng; hoàn tiền mặt tạo ra đã ở REFUNDED |
| TBL-06 | ck_ticket_status | status IN ('UNUSED', 'USED', 'CANCELLED') | ST-03, DC-TicketStatus |
| TBL-06 | ck_ticket_price | price > 0 | BR-67, BR-70 |
| TBL-06 | uq_ticket_id_showtime_seat | UNIQUE (id, showtime_id, seat_id) | Đích của khoá ngoại ghép (khoá phụ trợ, không phải khoá nghiệp vụ) |
| TBL-06 | ck_ticket_auditorium_type | auditorium_type IN ('STANDARD', '4DX', 'IMAX') | BR-140, GL-27 |
| TBL-07 | ck_customer_email_format | norm_email(email) ~ '^[^@[:space:]]+@[^@[:space:]]+$' | BR-81 (lưới an toàn tối thiểu trên giá trị chuẩn hoá; kiểm đầy đủ ở ứng dụng) |
| TBL-07 | ck_customer_phone_format | phone_number ~ '^0[0-9]{9}$' | BR-82 |
| TBL-08 | ck_staff_email_format | norm_email(email) ~ '^[^@[:space:]]+@[^@[:space:]]+$' | BR-81 (lưới an toàn tối thiểu) |
| TBL-08 | ck_staff_full_name_not_blank | btrim(full_name) <> '' | Q-163 |
| TBL-08 | ck_staff_role | role IN ('BOX_OFFICE_CLERK', 'TICKET_CHECKER', 'CINEMA_MANAGER', 'CHAIN_MANAGER') | BR-79, DC-StaffRole |
| TBL-08 | ck_staff_status | status IN ('ACTIVE', 'LOCKED') | ST-12, DC-StaffStatus |
| TBL-08 | ck_staff_role_cinema | (role = 'CHAIN_MANAGER') = (cinema_id IS NULL) | BR-78: quản lý chuỗi không thuộc cụm rạp, ba vai trò còn lại thuộc đúng một cụm rạp |
| TBL-09 | ck_showtime_status | status IN ('IN_SCHEDULE', 'DELETED') | DC-ShowtimeStatus |
| TBL-09 | ck_showtime_format | movie_format IN ('2D', '3D') | GL-05 |
| TBL-09 | ck_showtime_sale_before_start | sale_open_time < start_time | BR-55 |
| TBL-09 | ck_showtime_end_after_start | end_time > start_time | BR-50 |
| TBL-09 | ex_showtime_auditorium_overlap | EXCLUDE USING gist (auditorium_id WITH =, showtime_busy_range(start_time, end_time) WITH &&) WHERE (status = 'IN_SCHEDULE') | BR-51, BR-52: hai suất chiếu chưa xoá trong cùng một phòng không chồng giờ và cách nhau ít nhất 15 phút dọn phòng |
| TBL-13 | ck_cinema_name_not_blank | norm_name(name) <> '' | BR-141, UC-011 dữ liệu vào 1 |
| TBL-13 | ck_cinema_province_not_blank | norm_name(province) <> '' | Q-204 |
| TBL-14 | ck_auditorium_type | auditorium_type IN ('STANDARD', '4DX', 'IMAX') | GL-27 |
| TBL-14 | ck_auditorium_name_not_blank | norm_name(name) <> '' | BR-145 |
| TBL-15 | ck_seat_type | seat_type IN ('STANDARD', 'VIP', 'COUPLE') | GL-26 |
| TBL-15 | ck_seat_number | seat_number > 0 | Thiết kế |
| TBL-15 | uq_seat_position | UNIQUE (auditorium_id, row_code, seat_number) | Khoá ứng viên ghép |
| TBL-15 | ck_seat_row_code_not_blank | btrim(row_code) <> '' | UC-012 dữ liệu vào 1a |
| TBL-16 | ck_movie_duration | duration_minutes > 0 | BR-50 |
| TBL-16 | ck_movie_run_period | end_of_run_date >= release_date | BR-49, BR-76 |
| TBL-16 | ck_movie_title_not_blank | btrim(title) <> '' | UC-010 dữ liệu vào 1 |
| TBL-16 | ck_movie_genre_not_blank | btrim(genre) <> '' | P12 DC-Movie.genre {không trống}, Q-196 |
| TBL-16 | ck_movie_age_rating | age_rating IN ('P', 'K', 'T13', 'T16', 'T18', 'C') | Q-199 |
| TBL-16 | ck_movie_trailer_not_blank | trailer IS NULL OR btrim(trailer) <> '' | Q-198 |
| TBL-17 | ck_price_entry_auditorium_type | auditorium_type IN ('STANDARD', '4DX', 'IMAX') | GL-27 |
| TBL-17 | ck_price_entry_movie_format | movie_format IN ('2D', '3D') | GL-05 |
| TBL-17 | ck_price_entry_seat_type | seat_type IN ('STANDARD', 'VIP', 'COUPLE') | GL-26 |
| TBL-17 | ck_price_entry_time_band | time_band IN ('WEEKDAY_BEFORE_17', 'WEEKDAY_FROM_17', 'WEEKEND_BEFORE_17', 'WEEKEND_FROM_17') | BR-12 |
| TBL-17 | ck_price_entry_price | ticket_price > 0 | BR-70 |
| TBL-18 | ck_movie_format_value | movie_format IN ('2D', '3D') | GL-05 |
| TBL-19 | ck_auditorium_format_value | movie_format IN ('2D', '3D') | GL-05 |
| TBL-20 | ck_seat_event_items | jsonb_typeof(items) = 'array' AND jsonb_array_length(items) > 0 | P09 F7.5 điểm 1 |
| TBL-21 | ck_outbox_kind | kind IN ('REFUND_GATEWAY', 'EMAIL_TICKET', 'EMAIL_REFUND') | DC-OutboxKind |
| TBL-21 | ck_outbox_status | status IN ('PENDING', 'SUCCEEDED', 'EXHAUSTED') | DC-OutboxStatus |
| TBL-21 | ck_outbox_attempts | attempt_count >= 0 | P09 F7.7 |
| TBL-21 | ck_outbox_claim_pair | (claim_token IS NULL) = (claimed_until IS NULL) | P09 F7.7 bước 1, 3 |
| TBL-22 | ck_administrator_single_row | id = 1 | Q-271: đúng một tài khoản quản trị viên |
| TBL-22 | ck_administrator_email_format | norm_email(email) ~ '^[^@[:space:]]+@[^@[:space:]]+$' | BR-81 (lưới an toàn tối thiểu) |

ON UPDATE của mọi khoá ngoại là NO ACTION (mặc định) vì không có thao tác nào đổi khoá chính.

### F6.2. Ánh xạ kiểu dữ liệu

| Kiểu thiết kế | Kiểu vật lý đã dùng |
|---|---|
| String có độ dài tối đa | VARCHAR(n), n từ BR (email 254 theo RFC 5321, số điện thoại 10 theo BR-82) hoặc quyết định thiết kế ghi ở cột mô tả |
| Integer / Long | INTEGER / BIGINT |
| Decimal (tiền) | BIGINT đồng, vì P12 chốt DC-Money là int64 đồng và BR-70 là số nguyên đồng; không dùng FLOAT hoặc REAL |
| Boolean | BOOLEAN |
| Văn bản dài không giới hạn | TEXT (chỉ movie.description) |
| Date / DateTime | DATE / TIMESTAMPTZ |
| Enumeration | VARCHAR(n) kèm CHECK tập giá trị |
| Định danh thay thế | BIGINT GENERATED BY DEFAULT AS IDENTITY |
| Danh sách trong một sự kiện | JSONB (chỉ seat_event.items) |
| Mã ngẫu nhiên claim | UUID |

### F6.3. Index

| TBL | Tên index | Cột (theo thứ tự) | Loại | Phục vụ truy vấn (UC bước / NFR) |
|---|---|---|---|---|
| TBL-01 | uq_seat_hold_active_customer | customer_id WHERE status = 'ACTIVE' | UNIQUE từng phần | BR-04: mỗi khách tối đa một lần giữ ghế đang giữ; lưới an toàn của EX-01 sau khoá người giữ hạng 4 |
| TBL-01 | uq_seat_hold_active_clerk | box_office_clerk_id WHERE status = 'ACTIVE' | UNIQUE từng phần | BR-04: như trên cho nhân viên quầy |
| TBL-01 | ix_seat_hold_expiry | expiry_time WHERE status = 'ACTIVE' | thường, từng phần | P09 F7.4 bước 1: quét hết hạn theo lô, sắp theo expiry_time, FOR NO KEY UPDATE SKIP LOCKED (NFR-07) |
| TBL-01 | ix_seat_hold_showtime_active | showtime_id WHERE status = 'ACTIVE' | thường, từng phần | EX-13, EX-14 hạng 5: kiểm suất chiếu còn lần giữ ghế đang giữ (BR-53) |
| TBL-02 | ix_seat_status_current_hold | current_hold_id WHERE current_hold_id IS NOT NULL | thường, từng phần | EX-02, EX-05: tìm ghế của một lần giữ ghế (WHERE current_hold_id = ...); quét giải phóng chỉ duyệt các ghế đang bị giữ |
| TBL-02 | uq_seat_status_current_ticket | current_ticket_id WHERE current_ticket_id IS NOT NULL | UNIQUE từng phần | R-64 (0..1 - 0..1): một vé không thể chiếm hai ghế; EX-06 |
| TBL-02 | ix_seat_status_seat | seat_id | thường | EX-15 và khoá ngoại fk_seat_status_seat: sửa sơ đồ ghế tìm các SeatStatus của một ghế |
| TBL-03 | uq_payment_transaction_ticketed_hold | seat_hold_id WHERE status = 'TICKETED' | UNIQUE từng phần | BR-37: mỗi lần giữ ghế tối đa một giao dịch đã dùng để tạo vé; lưới an toàn cho IPN gửi trùng hai bản backend (EX-02) |
| TBL-03 | uq_payment_transaction_gateway_no | gateway_transaction_no WHERE gateway_transaction_no IS NOT NULL | UNIQUE từng phần | Hai giao dịch hệ thống không thể cùng mã giao dịch của cổng; IPN idempotent |
| TBL-03 | ix_payment_transaction_hold | seat_hold_id, id | thường | Giao dịch tạo sau cùng của lần giữ ghế (guard failPayment, ST-01); QueryPaymentStatus; khoá ngoại |
| TBL-04 | uq_refund_request_full_per_payment | payment_transaction_id WHERE request_type = 'FULL' | UNIQUE từng phần | BR-16: mỗi giao dịch thanh toán trễ chỉ hoàn toàn bộ một lần |
| TBL-04 | ix_refund_request_payment | payment_transaction_id | thường | EX-09: các yêu cầu hoàn của một giao dịch; khoá ngoại |
| TBL-04 | ix_refund_request_manual | id WHERE status = 'MANUAL_REQUIRED' | thường, từng phần | Truy vấn vận hành liệt kê khoản hoàn cần xử lý thủ công (P09 F7.7, BR-41) |
| TBL-05 | ix_booking_customer_booked | customer_id, booked_at DESC WHERE customer_id IS NOT NULL | thường, từng phần | UC-007 bước 2: các lần đặt của khách từ gần nhất (BR-94, Q-322); lần đặt tại quầy (NULL) không có trong chỉ mục |
| TBL-06 | uq_ticket_active_seat | showtime_id, seat_id WHERE status <> 'CANCELLED' | UNIQUE từng phần | BR-09: một ghế của một suất chiếu chỉ có tối đa một vé chưa huỷ; lưới an toàn cho EX-02, EX-03, EX-13 |
| TBL-06 | ix_ticket_showtime_seat | showtime_id, seat_id | thường | Khoá ngoại fk_ticket_seat_status gồm cả vé đã huỷ (kiểm RESTRICT khi xoá hoặc thay SeatStatus ở EX-13); EX-13, EX-14 hạng 8 đọc vé của suất chiếu |
| TBL-06 | ix_ticket_booking | booking_id | thường | UC-008 bước 1: các vé của một lần đặt theo mã đặt vé (FindByCode); khoá ngoại |
| TBL-07 | uq_customer_email_norm | norm_email(email) | UNIQUE theo biểu thức | EX-20, UC-001 bước 7 (BR-98); đăng nhập khách bằng email (NFR-01): WHERE norm_email(email) = norm_email(?) dùng chính chỉ mục này |
| TBL-08 | uq_staff_email_norm | norm_email(email) | UNIQUE theo biểu thức | EX-21 (BR-95, mọi vai trò); đăng nhập nhân viên bằng email (NFR-02) tìm theo norm_email(email) |
| TBL-09 | ix_showtime_auditorium_start | auditorium_id, start_time | thường | UC-014 (showShowtimes): các suất chiếu của một phòng theo giờ; EX-12, EX-15 hạng 3; khoá ngoại; UC-015, UC-016: suất chiếu theo ngày chiếu của phòng trong cụm rạp, kể cả suất chiếu đã xoá vì vé đã huỷ của suất đã xoá vẫn tính doanh thu (BR-115, BR-119); không còn điều kiện từng phần để phục vụ cả báo cáo |
| TBL-13 | uq_cinema_name_norm | norm_name(name) | UNIQUE theo biểu thức | EX-17 (BR-141); tên cụm rạp là lưới an toàn của khoá giá trị hạng 0 |
| TBL-14 | ix_auditorium_cinema | cinema_id | thường | UC-014 bước 2: các phòng chiếu của cụm rạp; EX-12 duyệt phòng của cụm; khoá ngoại |
| TBL-14 | uq_auditorium_cinema_name_norm | cinema_id, norm_name(name) | UNIQUE theo biểu thức | EX-15, EX-18 (BR-145); thay cho chỉ mục ix cinema_id khi tìm phòng theo tên trong một cụm rạp |
| TBL-15 | uq_seat_position | auditorium_id, row_code, seat_number WHERE in_seat_map | UNIQUE từng phần | UC-012: hai ghế đang trong sơ đồ không cùng vị trí; vị trí ghế đã bỏ nhập lại thành ghế mới (ComputeSeatMapChange); EX-15 tìm ghế của một phòng |
| TBL-20 | ix_seat_event_showtime_event | showtime_id, id | thường | Phát lại cho kết nối SSE: các dòng của một suất chiếu có mã lớn hơn con trỏ (ReadShowtimeEvents, P09 F7.5 điểm 4) |
| TBL-20 | ix_seat_event_created_at | created_at | thường | Dọn dòng cũ hơn 10 phút (DeleteOlderThan); điều kiện created_at của phát lại; mốc W (P09 F7.5 điểm 3, 6) |
| TBL-21 | ix_outbox_due | kind, next_attempt_at WHERE status = 'PENDING' | thường, từng phần | Claim: chọn tối đa 20 dòng đến hạn theo kind, ORDER BY next_attempt_at, FOR NO KEY UPDATE SKIP LOCKED (P09 F7.7 bước 1) |

Chỉ mục có chủ ý không tạo: showtime.movie_id (chưa có truy vấn lọc theo phim; xoá phim không có, nên không cần tìm suất chiếu của phim; UC-003, UC-004 lọc suất chiếu theo ngày chiếu và cụm rạp qua ix_showtime_auditorium_start); staff.cinema_id (UC-017 liệt kê toàn bộ nhân viên theo mã, khoảng vài trăm dòng; không xoá cụm rạp); cinema.province (tối đa 15 cụm rạp, lọc bằng quét bảng); movie theo ngày chiếu (vài trăm phim, UC-003 lọc bằng quét bảng); seat_hold.customer_id và box_office_clerk_id ngoài chỉ mục từng phần (không xoá khách hay nhân viên); payment_transaction.gateway_transaction_no ngoài chỉ mục unique từng phần; booking.seat_hold_id đã có chỉ mục của UNIQUE. Mỗi chỉ mục mất chi phí ghi nên bảng nóng seat_status chỉ có ba chỉ mục phụ, seat_event hai. Báo cáo (P09 F7.12): vé theo showtime_id dùng ix_ticket_showtime_seat, seat_status theo showtime_id dùng khoá chính, suất chiếu theo (phòng, giờ bắt đầu) dùng ix_showtime_auditorium_start, nên P13 không thêm chỉ mục riêng cho báo cáo.

Chi phí biết trước, chấp nhận: ix_seat_status_current_hold phủ mọi ghế đang HELD chứ không chỉ ghế của lần giữ đã kết thúc, nên quét EX-05 mỗi phút duyệt toàn bộ ghế đang giữ; tập này nhỏ (tối đa vài nghìn dòng ở giờ cao điểm). Chỉ xem lại nếu kiểm thử tải (P09 F7.9) cho thấy quét chậm. Dòng outbox đã SUCCEEDED hoặc EXHAUSTED không có chỉ mục và không có công việc dọn (Q-138: giữ toàn bộ); ix_outbox_due chỉ phủ PENDING nên bảng phình dần không ảnh hưởng truy vấn nóng. Sản phẩm thật dọn theo Vấn đề còn mở 4.

### F6.4. Lưới an toàn chống race condition ở mức CSDL

Mỗi dòng nêu tình huống sai có thể xảy ra nếu một đường ghi quên khoá hoặc sai thứ tự, và ràng buộc làm giao dịch đó thất bại thay vì để dữ liệu sai.

| Tình huống sai | BR | Ràng buộc chặn | Kết quả ở CSDL |
|---|---|---|---|
| Hai người cùng giữ một ghế | BR-08, BR-09 | Một dòng seat_status mỗi (suất chiếu, ghế) với đúng một current_hold_id; ck_seat_status_state_link; trg_seat_status_link không cho đổi liên kết đang có sang giá trị khác (chọn lại ghế của lần giữ ghế cũ phải trả về Trống bằng một UPDATE riêng rồi mới gán lần giữ ghế mới); ứng dụng dùng khoá hạng 6 NOWAIT và UPDATE ... WHERE state = 'AVAILABLE' | Bên đến sau bị 55P03 hoặc UPDATE 0 dòng; nếu một đường ghi quên cả hai, trigger báo 23514 thay vì ghi đè lần giữ ghế của người trước |
| Một ghế bán cho hai người | BR-09 | uq_ticket_active_seat; uq_seat_status_current_ticket; fk_seat_status_ticket | INSERT ticket thứ hai cho cùng ghế chưa huỷ báo 23505 |
| Ghế gắn với lần giữ ghế hoặc vé của suất chiếu khác | R-63, R-64 | FK ghép fk_seat_status_seat_hold, fk_seat_status_ticket | 23503 |
| Một người có hai lần giữ ghế đang giữ | BR-04 | uq_seat_hold_active_customer, uq_seat_hold_active_clerk | 23505 |
| Xác nhận lặp tạo hai lần giữ ghế | EX-01 | uq_seat_hold_request_id | 23505; ứng dụng trả lại lần giữ ghế cũ |
| Hai suất chiếu chồng giờ cùng phòng | BR-51, BR-52 | ex_showtime_auditorium_overlap | 23P01 (exclusion_violation) |
| Lần giữ ghế đã ở trạng thái cuối bị đổi | BR-85, BR-86, Q-79 | trg_seat_hold_status; UPDATE ... WHERE status = 'ACTIVE' | 23514; UPDATE điều kiện trả 0 dòng |
| Vé đã huỷ bị soát, vé đã soát bị huỷ | BR-30, BR-21, BR-24 | trg_ticket_status; UPDATE ... WHERE status = 'UNUSED' | Bên sau trả 0 dòng hoặc 23514 |
| Ghế đã bán bị trả về trống bởi job quét lặp | REQ-76, X-18 | Điều kiện current_hold_id hoặc current_ticket_id trong câu UPDATE; ck_seat_status_state_link | UPDATE 0 dòng khi liên kết không còn khớp |
| IPN gửi trùng xử lý hai lần | BR-37, X-09 | uq_payment_transaction_code, uq_payment_transaction_ticketed_hold, uq_booking_seat_hold, uq_payment_transaction_gateway_no | 23505 cho bên chậm; giao dịch rollback hoàn toàn |
| Hoàn vượt số đã thanh toán | BR-26, X-16 | ck_payment_transaction_refund_limit; phép cộng trong câu UPDATE | 23514 |
| Hoàn trùng | BR-16, BR-21, BR-43 | uq_refund_request_idempotency_key, uq_refund_request_ticket, uq_refund_request_full_per_payment | 23505 |
| Hai bản backend gửi cùng dòng outbox | P09 F7.7 | claimed_until và claim_token; SKIP LOCKED; uq_outbox_idempotency_key; ck_outbox_claim_pair; trg_outbox_status | Bên mất claim ghi kết quả 0 dòng (ClaimLostError) |
| Trùng mã sự kiện hoặc sự kiện lệch thứ tự giữa các ghế | NFR-08 | seat_event.id từ identity, event_seq theo từng ghế; trình duyệt áp theo event_seq | Không cần khoá; thứ tự từng ghế đúng nhờ khoá hạng 6 |
| Quét hết hạn đọc cả bảng | NFR-07 | ix_seat_hold_expiry từng phần theo status = 'ACTIVE' | Index scan trên tập nhỏ |
| Hai cụm rạp cùng tên, chỉ khác hoa thường hoặc khoảng trắng, do hai phiên lưu đồng thời | BR-141, X-26 | uq_cinema_name_norm (theo norm_name); khoá tư vấn hạng 0 ở ứng dụng | Bên sau 23505 nếu quên khoá; khi lấy khoá thì bị từ chối ở câu kiểm |
| Hai tài khoản nhân viên cùng email ở hai vai trò khác nhau | BR-95, X-31 | uq_staff_email_norm trên một bảng chung | 23505 |
| Hai khách đăng ký cùng email (khác hoa thường) hoặc cùng số điện thoại | BR-98, X-30 | uq_customer_email_norm, uq_customer_phone_number | 23505 |
| Hai phòng cùng tên (chuẩn hoá) trong một cụm rạp | BR-145, X-27 | uq_auditorium_cinema_name_norm | 23505 |
| Nhân viên có vai trò và cụm rạp mâu thuẫn (quản lý chuỗi có cụm rạp, vai trò khác không có) | BR-78 | ck_staff_role_cinema | 23514 |
| Hai thao tác tài khoản nhân viên đè nhau | BR-102, X-32 | Khoá staff hạng 4 và so last_changed_at ở ứng dụng; email không đổi (trg_staff_email) để khoá không nâng thành FOR UPDATE | Bên sau thấy mốc đã đổi và bị từ chối |
| Ghế đã bỏ khỏi sơ đồ quay lại sơ đồ | BR-118, ST-07 | trg_seat_in_seat_map; uq_seat_position từng phần | 23514 |
| Suất chiếu đã xoá được khôi phục | BR-58, ST-06 | trg_showtime_status | 23514 |
| Tên phim, cụm rạp, phòng, giá trên vé đã bán bị sửa theo dữ liệu hiện hành | BR-140, BR-67 | NOT NULL; trg_ticket_sale_values | 23502 khi thiếu, 23514 khi sửa |
| Lần đặt gắn nhầm khách (không phải khách giữ ghế) | BR-17, BR-94 | trg_booking_customer | 23514 |
| Cụm rạp tạo ra không có bảng giá | R-40 | trg_cinema_has_price_list (hoãn tới COMMIT) | 23514 lúc COMMIT |
| Xoá phòng, ghế, seat_status còn được tham chiếu bởi suất chiếu, vé | BR-147, BR-92, BR-118 | Mọi khoá ngoại RESTRICT (fk_showtime_auditorium, fk_seat_status_seat, fk_ticket_seat_status) | 23503 |
| Hai tài khoản quản trị viên | NFR-12, Q-271 | ck_administrator_single_row cùng khoá chính | 23514 hoặc 23505 |
| Báo cáo thấy doanh thu và sức chứa lệch nhau do vé bán giữa hai câu | BR-117, P09 F7.12 | Giao dịch REPEATABLE READ READ ONLY ở ứng dụng | Cả báo cáo thấy một ảnh chụp, người ghi không chờ |

Điều CSDL không chặn được, chỉ ứng dụng giữ: số ghế tối đa của lần giữ ghế, số vé của lần đặt, giá chốt khớp bảng giá, quyền theo cụm rạp, và mọi quy tắc F4.4 ghi "Ứng dụng". Các quy tắc này được bảo vệ bằng chuỗi khoá F4.5 chứ không bằng ràng buộc.

### F6.5. Hàm và trigger

| Tên | Loại | Bảng | Việc làm | Nguồn |
|---|---|---|---|---|
| norm_email(text) | Hàm SQL IMMUTABLE | - | lower(btrim(giá trị)); dùng ở chỉ mục unique, ck_*_email_format, câu kiểm trùng, khoá tư vấn | P09 F7.3, Q-265 |
| norm_name(text) | Hàm SQL IMMUTABLE | - | lower(btrim(gộp mọi dãy khoảng trắng thành một dấu cách)) | P09 F7.3, Q-266 |
| showtime_busy_range(timestamptz, timestamptz) | Hàm SQL IMMUTABLE | showtime | Khoảng bận [giờ bắt đầu, giờ kết thúc cộng 15 phút dọn phòng) cho EXCLUDE | BR-51 |
| trg_seat_hold_status, trg_seat_status_state, trg_ticket_status, trg_payment_transaction_status, trg_refund_request_status, trg_outbox_status, trg_showtime_status, trg_seat_in_seat_map | BEFORE UPDATE (fn_enforce_status_transition) | seat_hold, seat_status, ticket, payment_transaction, refund_request, outbox, showtime, seat | Chặn rời trạng thái cuối và chuyển ngoài đồ thị ST-01 đến ST-07, DC-OutboxStatus | C-07, C-27, C-28 |
| trg_seat_status_link | BEFORE UPDATE OF current_hold_id, current_ticket_id (fn_seat_status_link_guard) | seat_status | Chặn đổi thẳng liên kết hiện tại sang giá trị khác; phải trả ghế trước (đường hai lượt) | C-01 |
| trg_ticket_sale_values, trg_staff_email | BEFORE UPDATE (fn_reject_update) | ticket, staff | Chặn sửa giá trị lúc bán và email nhân viên | C-26, C-32 |
| trg_booking_customer | BEFORE INSERT, UPDATE (fn_booking_customer_guard) | booking | customer_id bằng khách của lần giữ ghế | C-25 |
| trg_cinema_has_price_list | CONSTRAINT TRIGGER AFTER INSERT, DEFERRABLE INITIALLY DEFERRED (fn_cinema_has_price_list) | cinema | Cụm rạp có bảng giá lúc COMMIT | C-29 |

## F7. Mô hình tài liệu

Không áp dụng (CSDL quan hệ).

## F8. ERD

### F8.1. ERD logic và vật lý

File: diagrams/P13-erd-logical.drawio. Bảng vẽ theo F6.1, mỗi cột một dòng dạng "PK,FK tên: KIỂU". Quan hệ phụ thuộc (khoá ngoại nằm trong khoá chính của bảng con) nét liền; quan hệ độc lập nét đứt; đầu bảng cha ERmandOne (khoá ngoại NOT NULL) hoặc ERzeroToOne (khoá ngoại cho phép NULL); đầu bảng con ERzeroToMany, ERoneToMany hoặc ERzeroToOne, ERmandOne khi 1 - 1. Bảng seat_event và outbox không có cạnh (không khai báo khoá ngoại); bảng administrator không có cạnh (không quan hệ với bảng nào). Các cạnh của khoá ngoại ghép vẽ một cạnh (fk_ticket_seat_status phủ R-53 và R-54).

Node:

| ID | Loại | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| TBL-01 | Table | seat_hold | «table» | - | 9 cột; DC-SeatHold |
| TBL-02 | Table | seat_status | «table» | - | 7 cột; DC-SeatStatus |
| TBL-03 | Table | payment_transaction | «table» | - | 10 cột; DC-PaymentTransaction |
| TBL-04 | Table | refund_request | «table» | - | 9 cột; DC-RefundRequest |
| TBL-05 | Table | booking | «table» | - | 5 cột; DC-Booking |
| TBL-06 | Table | ticket | «table» | - | 11 cột; DC-Ticket |
| TBL-07 | Table | customer | «table» | - | 4 cột; DC-Customer |
| TBL-08 | Table | staff | «table» | - | 9 cột; DC-Staff, DC-BoxOfficeClerk, DC-TicketChecker, DC-CinemaManager |
| TBL-09 | Table | showtime | «table» | - | 9 cột; DC-Showtime |
| TBL-10 | Table | price_list | «table» | - | 1 cột; DC-PriceList |
| TBL-13 | Table | cinema | «table» | - | 5 cột; DC-Cinema |
| TBL-14 | Table | auditorium | «table» | - | 5 cột; DC-Auditorium |
| TBL-15 | Table | seat | «table» | - | 6 cột; DC-Seat |
| TBL-16 | Table | movie | «table» | - | 10 cột; DC-Movie |
| TBL-17 | Table | price_entry | «table» | - | 8 cột; DC-PriceEntry |
| TBL-18 | Table | movie_format | «table» | - | 2 cột; DC-Movie (releaseFormats) |
| TBL-19 | Table | auditorium_format | «table» | - | 2 cột; DC-Auditorium (supportedFormats) |
| TBL-20 | Table | seat_event | «table» | - | 4 cột; DC-SeatChangeEvent |
| TBL-21 | Table | outbox | «table» | - | 11 cột; DC-OutboxEntry |
| TBL-22 | Table | administrator | «table» | - | 3 cột; DC-AdministratorAccount |

Edge:

| ID | Nguồn (bảng cha) | Đích (bảng con chứa FK) | Loại quan hệ | Nhãn / multiplicity (cha - con) | Ghi chú |
|---|---|---|---|---|---|
| fk_seat_hold_customer | TBL-07 customer | TBL-01 seat_hold | Độc lập | 0..1 - 0..* | R-48 |
| fk_seat_hold_showtime | TBL-09 showtime | TBL-01 seat_hold | Độc lập | 1 - 0..* | R-46 |
| fk_seat_hold_staff | TBL-08 staff | TBL-01 seat_hold | Độc lập | 0..1 - 0..* | R-49 (R-67 đến R-69: nhân viên quầy là một dòng staff) |
| fk_seat_status_seat | TBL-15 seat | TBL-02 seat_status | Phụ thuộc | 1 - 0..* | R-45 |
| fk_seat_status_seat_hold | TBL-01 seat_hold | TBL-02 seat_status | Độc lập | 0..1 - 0..* | R-63; FK ghép: lần giữ ghế hiện tại phải cùng suất chiếu với ghế; MATCH SIMPLE nên bỏ qua khi current_hold_id NULL |
| fk_seat_status_showtime | TBL-09 showtime | TBL-02 seat_status | Phụ thuộc | 1 - 1..* | R-44 |
| fk_seat_status_ticket | TBL-06 ticket | TBL-02 seat_status | Độc lập | 0..1 - 0..1 | R-64; FK ghép: vé hiện tại phải là vé của chính ghế này; tạo bằng ALTER TABLE sau khi có bảng ticket (vòng tham chiếu với fk_ticket_seat_status) |
| fk_payment_transaction_seat_hold | TBL-01 seat_hold | TBL-03 payment_transaction | Độc lập | 1 - 0..* | R-50 |
| fk_refund_request_payment_transaction | TBL-03 payment_transaction | TBL-04 refund_request | Độc lập | 0..1 - 0..* | R-55 |
| fk_refund_request_ticket | TBL-06 ticket | TBL-04 refund_request | Độc lập | 0..1 - 0..1 | R-56 |
| fk_booking_customer | TBL-07 customer | TBL-05 booking | Độc lập | 0..1 - 0..* | R-65; cột cho phép NULL (lần đặt tại quầy), khớp khách của lần giữ ghế bằng trg_booking_customer |
| fk_booking_seat_hold | TBL-01 seat_hold | TBL-05 booking | Độc lập | 1 - 0..1 | R-51 |
| fk_ticket_booking | TBL-05 booking | TBL-06 ticket | Độc lập | 1 - 1..* | R-52 |
| fk_ticket_seat_status | TBL-02 seat_status | TBL-06 ticket | Độc lập | 1 - 0..* | R-53, R-54; FK ghép phủ cả R-53 (suất chiếu) lẫn R-54 (ghế) |
| fk_staff_cinema | TBL-13 cinema | TBL-08 staff | Độc lập | 0..1 - 0..* | R-66; NULL với quản lý chuỗi (ck_staff_role_cinema) |
| fk_showtime_auditorium | TBL-14 auditorium | TBL-09 showtime | Độc lập | 1 - 0..* | R-42 |
| fk_showtime_movie | TBL-16 movie | TBL-09 showtime | Độc lập | 1 - 0..* | R-43 |
| fk_price_list_cinema | TBL-13 cinema | TBL-10 price_list | Phụ thuộc | 1 - 1 | R-40 |
| fk_auditorium_cinema | TBL-13 cinema | TBL-14 auditorium | Độc lập | 1 - 0..* | R-38 |
| fk_seat_auditorium | TBL-14 auditorium | TBL-15 seat | Độc lập | 1 - 1..* | R-39 |
| fk_price_entry_price_list | TBL-10 price_list | TBL-17 price_entry | Phụ thuộc | 1 - 0..* | R-41 |
| fk_movie_format_movie | TBL-16 movie | TBL-18 movie_format | Phụ thuộc | 1 - 1..* | Thuộc tính đa trị |
| fk_auditorium_format_auditorium | TBL-14 auditorium | TBL-19 auditorium_format | Phụ thuộc | 1 - 1..* | Thuộc tính đa trị |

### F8.2. ER khái niệm

File: diagrams/P13-erd-conceptual.drawio, ký pháp Chen. Thuộc tính nối với thực thể ở cột Thuộc về của bảng thuộc tính; không vẽ cột khoá ngoại, cột kỹ thuật (event_seq, claim_token) và hai bảng cơ chế. Bản số ghi trên đoạn nối thực thể - hình thoi. Mỗi quan hệ ER-nn có hai cạnh ER-nn-A (từ thực thể A tới hình thoi) và ER-nn-B (từ hình thoi tới thực thể B); mỗi thuộc tính AT-<E>-<tên> có cạnh AT-<E>-<tên>-edge tới thực thể. Quan hệ kế thừa (ER-26 đến ER-28, hình thoi "là") nối E-BoxOfficeClerk, E-TicketChecker, E-CinemaManager với E-Staff; ba thực thể con không có thuộc tính riêng.

Node thực thể và mối quan hệ:

| ID | Loại | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| E-Customer | Thực thể | Customer | - | - | 4 thuộc tính vẽ |
| E-Staff | Thực thể | Staff | - | - | 8 thuộc tính vẽ |
| E-BoxOfficeClerk | Thực thể | BoxOfficeClerk | - | - | Kế thừa thuộc tính của E-Staff (ISA) |
| E-TicketChecker | Thực thể | TicketChecker | - | - | Kế thừa thuộc tính của E-Staff (ISA) |
| E-CinemaManager | Thực thể | CinemaManager | - | - | Kế thừa thuộc tính của E-Staff (ISA) |
| E-AdministratorAccount | Thực thể | AdministratorAccount | - | - | 3 thuộc tính vẽ |
| E-SeatHold | Thực thể | SeatHold | - | - | 6 thuộc tính vẽ |
| E-PaymentTransaction | Thực thể | PaymentTransaction | - | - | 9 thuộc tính vẽ |
| E-RefundRequest | Thực thể | RefundRequest | - | - | 7 thuộc tính vẽ |
| E-Cinema | Thực thể | Cinema | - | - | 5 thuộc tính vẽ |
| E-Showtime | Thực thể | Showtime | - | - | 8 thuộc tính vẽ |
| E-Booking | Thực thể | Booking | - | - | 5 thuộc tính vẽ |
| E-Ticket | Thực thể | Ticket | - | - | 8 thuộc tính vẽ |
| E-Auditorium | Thực thể | Auditorium | - | - | 5 thuộc tính vẽ |
| E-SeatStatus | Thực thể yếu | SeatStatus | - | - | 2 thuộc tính vẽ |
| E-Seat | Thực thể | Seat | - | - | 5 thuộc tính vẽ |
| E-Movie | Thực thể | Movie | - | - | 12 thuộc tính vẽ |
| E-PriceList | Thực thể yếu | PriceList | - | - | 1 thuộc tính vẽ |
| E-PriceEntry | Thực thể yếu | PriceEntry | - | - | 7 thuộc tính vẽ |
| ER-01 | Mối quan hệ | gồm | - | - | R-38 |
| ER-02 | Mối quan hệ | gồm | - | - | R-39 |
| ER-03 | Mối quan hệ xác định thực thể yếu | có | - | - | R-40 |
| ER-04 | Mối quan hệ xác định thực thể yếu | gồm | - | - | R-41 |
| ER-05 | Mối quan hệ | tổ chức | - | - | R-42 |
| ER-06 | Mối quan hệ | chiếu | - | - | R-43 |
| ER-07 | Mối quan hệ xác định thực thể yếu | gồm | - | - | R-44 |
| ER-08 | Mối quan hệ xác định thực thể yếu | có tình trạng | - | - | R-45 |
| ER-09 | Mối quan hệ | nhận | - | - | R-46 |
| ER-10 | Mối quan hệ | giữ ghế | - | - | R-48 (xor với ER-11) |
| ER-11 | Mối quan hệ | giữ ghế | - | - | R-49 (xor với ER-10) |
| ER-12 | Mối quan hệ | phát sinh | - | - | R-50 |
| ER-13 | Mối quan hệ | dẫn tới | - | - | R-51 |
| ER-14 | Mối quan hệ | gồm | - | - | R-52 |
| ER-15 | Mối quan hệ | đã chiếm | - | - | R-54 (lịch sử) |
| ER-16 | Mối quan hệ | thuộc | - | - | R-53 (suy ra được qua ER-15 và ER-07) |
| ER-17 | Mối quan hệ | đang giữ | - | - | R-63 (hiện tại; R-47 lịch sử hiện thực bằng quan hệ này) |
| ER-18 | Mối quan hệ | đang chiếm | - | - | R-64 (hiện tại) |
| ER-19 | Mối quan hệ | sinh ra | - | - | R-55 |
| ER-20 | Mối quan hệ | được hoàn bởi | - | - | R-56 |
| ER-24 | Mối quan hệ | tuyển | - | - | R-66 (thay R-57 đến R-59; quản lý chuỗi không thuộc cụm rạp nào) |
| ER-25 | Mối quan hệ | đặt | - | - | R-65 (lần đặt tại quầy không thuộc khách nào) |
| ER-26 | Mối quan hệ | là | - | - | R-67 (kế thừa) |
| ER-27 | Mối quan hệ | là | - | - | R-68 (kế thừa) |
| ER-28 | Mối quan hệ | là | - | - | R-69 (kế thừa) |
| NOTE-xor | Note | {xor} | - | - | Nối bằng nét đứt với ER-10 và ER-11 |

Node thuộc tính:

| ID | Loại thuộc tính | Thuộc về |
|---|---|---|
| AT-Customer-id | định danh | E-Customer |
| AT-Customer-email | đơn | E-Customer |
| AT-Customer-phoneNumber | đơn | E-Customer |
| AT-Customer-passwordHash | đơn | E-Customer |
| AT-Staff-id | định danh | E-Staff |
| AT-Staff-email | đơn | E-Staff |
| AT-Staff-fullName | đơn | E-Staff |
| AT-Staff-passwordHash | đơn | E-Staff |
| AT-Staff-role | đơn | E-Staff |
| AT-Staff-status | đơn | E-Staff |
| AT-Staff-lastChangedAt | đơn | E-Staff |
| AT-Staff-accessChangedAt | đơn | E-Staff |
| AT-AdministratorAccount-id | định danh | E-AdministratorAccount |
| AT-AdministratorAccount-email | đơn | E-AdministratorAccount |
| AT-AdministratorAccount-passwordHash | đơn | E-AdministratorAccount |
| AT-SeatHold-id | định danh | E-SeatHold |
| AT-SeatHold-holdRef | đơn | E-SeatHold |
| AT-SeatHold-requestId | đơn | E-SeatHold |
| AT-SeatHold-status | đơn | E-SeatHold |
| AT-SeatHold-holdTime | đơn | E-SeatHold |
| AT-SeatHold-expiryTime | đơn | E-SeatHold |
| AT-PaymentTransaction-id | định danh | E-PaymentTransaction |
| AT-PaymentTransaction-code | đơn | E-PaymentTransaction |
| AT-PaymentTransaction-amount | đơn | E-PaymentTransaction |
| AT-PaymentTransaction-status | đơn | E-PaymentTransaction |
| AT-PaymentTransaction-gatewayTransactionNo | đơn | E-PaymentTransaction |
| AT-PaymentTransaction-paidAt | đơn | E-PaymentTransaction |
| AT-PaymentTransaction-lateReason | đơn | E-PaymentTransaction |
| AT-PaymentTransaction-refundedTotal | đơn | E-PaymentTransaction |
| AT-PaymentTransaction-duplicateReportCount | đơn | E-PaymentTransaction |
| AT-RefundRequest-id | định danh | E-RefundRequest |
| AT-RefundRequest-idempotencyKey | đơn | E-RefundRequest |
| AT-RefundRequest-requestType | đơn | E-RefundRequest |
| AT-RefundRequest-refundAmount | đơn | E-RefundRequest |
| AT-RefundRequest-attemptCount | đơn | E-RefundRequest |
| AT-RefundRequest-status | đơn | E-RefundRequest |
| AT-RefundRequest-refundResult | đơn | E-RefundRequest |
| AT-Cinema-id | định danh | E-Cinema |
| AT-Cinema-name | đơn | E-Cinema |
| AT-Cinema-province | đơn | E-Cinema |
| AT-Cinema-address | đơn | E-Cinema |
| AT-Cinema-lastChangedAt | đơn | E-Cinema |
| AT-Showtime-id | định danh | E-Showtime |
| AT-Showtime-startTime | đơn | E-Showtime |
| AT-Showtime-saleOpenTime | đơn | E-Showtime |
| AT-Showtime-endTime | đơn | E-Showtime |
| AT-Showtime-lastChangedAt | đơn | E-Showtime |
| AT-Showtime-movieFormat | đơn | E-Showtime |
| AT-Showtime-status | đơn | E-Showtime |
| AT-Showtime-cinemaId | dẫn xuất | E-Showtime |
| AT-Booking-id | định danh | E-Booking |
| AT-Booking-bookingCode | đơn | E-Booking |
| AT-Booking-bookedAt | đơn | E-Booking |
| AT-Booking-channel | dẫn xuất | E-Booking |
| AT-Booking-buyerId | dẫn xuất | E-Booking |
| AT-Ticket-id | định danh | E-Ticket |
| AT-Ticket-ticketCode | đơn | E-Ticket |
| AT-Ticket-price | đơn | E-Ticket |
| AT-Ticket-movieTitle | đơn | E-Ticket |
| AT-Ticket-cinemaName | đơn | E-Ticket |
| AT-Ticket-auditoriumName | đơn | E-Ticket |
| AT-Ticket-auditoriumType | đơn | E-Ticket |
| AT-Ticket-status | đơn | E-Ticket |
| AT-Auditorium-id | định danh | E-Auditorium |
| AT-Auditorium-name | đơn | E-Auditorium |
| AT-Auditorium-auditoriumType | đơn | E-Auditorium |
| AT-Auditorium-supportedFormats | đa trị | E-Auditorium |
| AT-Auditorium-lastChangedAt | đơn | E-Auditorium |
| AT-SeatStatus-state | đơn | E-SeatStatus |
| AT-SeatStatus-heldPrice | đơn | E-SeatStatus |
| AT-Seat-id | định danh | E-Seat |
| AT-Seat-rowCode | đơn | E-Seat |
| AT-Seat-seatNumber | đơn | E-Seat |
| AT-Seat-seatType | đơn | E-Seat |
| AT-Seat-inSeatMap | đơn | E-Seat |
| AT-Movie-id | định danh | E-Movie |
| AT-Movie-title | đơn | E-Movie |
| AT-Movie-releaseFormats | đa trị | E-Movie |
| AT-Movie-durationMinutes | đơn | E-Movie |
| AT-Movie-releaseDate | đơn | E-Movie |
| AT-Movie-endOfRunDate | đơn | E-Movie |
| AT-Movie-genre | đơn | E-Movie |
| AT-Movie-ageRating | đơn | E-Movie |
| AT-Movie-description | đơn | E-Movie |
| AT-Movie-trailer | đơn | E-Movie |
| AT-Movie-lastChangedAt | đơn | E-Movie |
| AT-Movie-movieCode | dẫn xuất | E-Movie |
| AT-PriceList-entryChangeTimes | dẫn xuất | E-PriceList |
| AT-PriceEntry-auditoriumType | định danh riêng phần | E-PriceEntry |
| AT-PriceEntry-movieFormat | định danh riêng phần | E-PriceEntry |
| AT-PriceEntry-seatType | định danh riêng phần | E-PriceEntry |
| AT-PriceEntry-timeBand | định danh riêng phần | E-PriceEntry |
| AT-PriceEntry-ticketPrice | đơn | E-PriceEntry |
| AT-PriceEntry-lastChangedAt | đơn | E-PriceEntry |
| AT-PriceEntry-removed | đơn | E-PriceEntry |

Edge mối quan hệ:

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| ER-01-A | E-Cinema | ER-01 | Nối thực thể - mối quan hệ | 1 | |
| ER-01-B | ER-01 | E-Auditorium | Nối mối quan hệ - thực thể | N | |
| ER-02-A | E-Auditorium | ER-02 | Nối thực thể - mối quan hệ | 1 | |
| ER-02-B | ER-02 | E-Seat | Nối mối quan hệ - thực thể | N | |
| ER-03-A | E-Cinema | ER-03 | Nối thực thể - mối quan hệ | 1 | |
| ER-03-B | ER-03 | E-PriceList | Nối mối quan hệ - thực thể | 1 | |
| ER-04-A | E-PriceList | ER-04 | Nối thực thể - mối quan hệ | 1 | |
| ER-04-B | ER-04 | E-PriceEntry | Nối mối quan hệ - thực thể | N | |
| ER-05-A | E-Auditorium | ER-05 | Nối thực thể - mối quan hệ | 1 | |
| ER-05-B | ER-05 | E-Showtime | Nối mối quan hệ - thực thể | N | |
| ER-06-A | E-Showtime | ER-06 | Nối thực thể - mối quan hệ | N | |
| ER-06-B | ER-06 | E-Movie | Nối mối quan hệ - thực thể | 1 | |
| ER-07-A | E-Showtime | ER-07 | Nối thực thể - mối quan hệ | 1 | |
| ER-07-B | ER-07 | E-SeatStatus | Nối mối quan hệ - thực thể | N | |
| ER-08-A | E-Seat | ER-08 | Nối thực thể - mối quan hệ | 1 | |
| ER-08-B | ER-08 | E-SeatStatus | Nối mối quan hệ - thực thể | N | |
| ER-09-A | E-Showtime | ER-09 | Nối thực thể - mối quan hệ | 1 | |
| ER-09-B | ER-09 | E-SeatHold | Nối mối quan hệ - thực thể | N | |
| ER-10-A | E-Customer | ER-10 | Nối thực thể - mối quan hệ | 1 | |
| ER-10-B | ER-10 | E-SeatHold | Nối mối quan hệ - thực thể | N | |
| ER-11-A | E-BoxOfficeClerk | ER-11 | Nối thực thể - mối quan hệ | 1 | |
| ER-11-B | ER-11 | E-SeatHold | Nối mối quan hệ - thực thể | N | |
| ER-12-A | E-SeatHold | ER-12 | Nối thực thể - mối quan hệ | 1 | |
| ER-12-B | ER-12 | E-PaymentTransaction | Nối mối quan hệ - thực thể | N | |
| ER-13-A | E-SeatHold | ER-13 | Nối thực thể - mối quan hệ | 1 | |
| ER-13-B | ER-13 | E-Booking | Nối mối quan hệ - thực thể | 1 | |
| ER-14-A | E-Booking | ER-14 | Nối thực thể - mối quan hệ | 1 | |
| ER-14-B | ER-14 | E-Ticket | Nối mối quan hệ - thực thể | N | |
| ER-15-A | E-Ticket | ER-15 | Nối thực thể - mối quan hệ | N | |
| ER-15-B | ER-15 | E-SeatStatus | Nối mối quan hệ - thực thể | 1 | |
| ER-16-A | E-Ticket | ER-16 | Nối thực thể - mối quan hệ | N | |
| ER-16-B | ER-16 | E-Showtime | Nối mối quan hệ - thực thể | 1 | |
| ER-17-A | E-SeatHold | ER-17 | Nối thực thể - mối quan hệ | 1 | |
| ER-17-B | ER-17 | E-SeatStatus | Nối mối quan hệ - thực thể | N | |
| ER-18-A | E-Ticket | ER-18 | Nối thực thể - mối quan hệ | 1 | |
| ER-18-B | ER-18 | E-SeatStatus | Nối mối quan hệ - thực thể | 1 | |
| ER-19-A | E-PaymentTransaction | ER-19 | Nối thực thể - mối quan hệ | 1 | |
| ER-19-B | ER-19 | E-RefundRequest | Nối mối quan hệ - thực thể | N | |
| ER-20-A | E-Ticket | ER-20 | Nối thực thể - mối quan hệ | 1 | |
| ER-20-B | ER-20 | E-RefundRequest | Nối mối quan hệ - thực thể | 1 | |
| ER-24-A | E-Cinema | ER-24 | Nối thực thể - mối quan hệ | 1 | |
| ER-24-B | ER-24 | E-Staff | Nối mối quan hệ - thực thể | N | |
| ER-25-A | E-Customer | ER-25 | Nối thực thể - mối quan hệ | 1 | |
| ER-25-B | ER-25 | E-Booking | Nối mối quan hệ - thực thể | N | |
| ER-26-A | E-BoxOfficeClerk | ER-26 | Nối thực thể - mối quan hệ | 1 | |
| ER-26-B | ER-26 | E-Staff | Nối mối quan hệ - thực thể | 1 | |
| ER-27-A | E-TicketChecker | ER-27 | Nối thực thể - mối quan hệ | 1 | |
| ER-27-B | ER-27 | E-Staff | Nối mối quan hệ - thực thể | 1 | |
| ER-28-A | E-CinemaManager | ER-28 | Nối thực thể - mối quan hệ | 1 | |
| ER-28-B | ER-28 | E-Staff | Nối mối quan hệ - thực thể | 1 | |

## F9. Script DDL

Script cũng nằm ở design/P13-schema.sql (cùng nội dung). Thứ tự: extension, hàm (showtime_busy_range, norm_email, norm_name), bảng cha trước bảng con, ALTER TABLE cho vòng tham chiếu seat_status - ticket, chỉ mục, hàm và trigger. Bộ ca thử ở design/P13-schema-tests.sql.

```sql
-- CineBook: lược đồ PostgreSQL 15 trở lên, mức cô lập READ COMMITTED (báo cáo UC-015, UC-016 đọc ở REPEATABLE READ READ ONLY).
-- Chạy bằng tài khoản có quyền tạo extension (btree_gist là extension tin cậy từ PostgreSQL 13).
-- Cơ sở dữ liệu phải có bộ mã UTF-8 và locale hạ được chữ hoa có dấu tiếng Việt (ví dụ en_US.utf8); locale C chỉ hạ chữ ASCII
-- nên norm_name, norm_email cho kết quả sai với chữ có dấu.

CREATE EXTENSION IF NOT EXISTS btree_gist;

-- Khoảng bận của một suất chiếu trong phòng: từ giờ bắt đầu đến giờ kết thúc cộng 15 phút dọn phòng (BR-51).
-- Khai báo IMMUTABLE vì phép cộng khoảng phút cố định không phụ thuộc múi giờ; cần để dùng được trong EXCLUDE.
CREATE FUNCTION showtime_busy_range(start_time TIMESTAMPTZ, end_time TIMESTAMPTZ)
RETURNS tstzrange
LANGUAGE sql IMMUTABLE PARALLEL SAFE
AS $$ SELECT tstzrange(start_time, end_time + interval '15 minutes', '[)') $$;

-- Chuẩn hoá giá trị để so sánh trùng: một định nghĩa dùng chung cho chỉ mục unique, câu kiểm trùng và khoá tư vấn
-- (pg_advisory_xact_lock(1000 + hạng, hashtext(norm_*(giá trị)))), nên không có hai bản chuẩn hoá lệch nhau.
-- Khai báo IMMUTABLE để dùng trong chỉ mục theo biểu thức; kết quả của lower() phụ thuộc locale của cơ sở dữ liệu,
-- vì vậy không được đổi locale sau khi đã có dữ liệu.
CREATE FUNCTION norm_email(v TEXT) RETURNS TEXT
LANGUAGE sql IMMUTABLE PARALLEL SAFE STRICT
AS $$ SELECT lower(btrim(v, E' \t\r\n')) $$;

CREATE FUNCTION norm_name(v TEXT) RETURNS TEXT
LANGUAGE sql IMMUTABLE PARALLEL SAFE STRICT
AS $$ SELECT lower(btrim(regexp_replace(v, '[[:space:]]+', ' ', 'g'))) $$;

-- TBL-13 cinema (DC-Cinema)
CREATE TABLE cinema (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY,
  name VARCHAR(100) NOT NULL,
  province VARCHAR(100) NOT NULL,
  address VARCHAR(255),
  last_changed_at TIMESTAMPTZ NOT NULL,
  CONSTRAINT pk_cinema PRIMARY KEY (id),
  CONSTRAINT ck_cinema_name_not_blank CHECK (norm_name(name) <> ''),
  CONSTRAINT ck_cinema_province_not_blank CHECK (norm_name(province) <> '')
);

-- TBL-16 movie (DC-Movie)
CREATE TABLE movie (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY,
  title VARCHAR(200) NOT NULL,
  duration_minutes INTEGER NOT NULL,
  release_date DATE NOT NULL,
  end_of_run_date DATE NOT NULL,
  genre VARCHAR(50) NOT NULL,
  age_rating VARCHAR(10) NOT NULL,
  description TEXT DEFAULT '' NOT NULL,
  trailer VARCHAR(2048),
  last_changed_at TIMESTAMPTZ NOT NULL,
  CONSTRAINT pk_movie PRIMARY KEY (id),
  CONSTRAINT ck_movie_title_not_blank CHECK (btrim(title) <> ''),
  CONSTRAINT ck_movie_genre_not_blank CHECK (btrim(genre) <> ''),
  CONSTRAINT ck_movie_age_rating CHECK (age_rating IN ('P', 'K', 'T13', 'T16', 'T18', 'C')),
  CONSTRAINT ck_movie_trailer_not_blank CHECK (trailer IS NULL OR btrim(trailer) <> ''),
  CONSTRAINT ck_movie_duration CHECK (duration_minutes > 0),
  CONSTRAINT ck_movie_run_period CHECK (end_of_run_date >= release_date)
);

-- TBL-18 movie_format (DC-Movie (releaseFormats))
CREATE TABLE movie_format (
  movie_id BIGINT NOT NULL,
  movie_format VARCHAR(2) NOT NULL,
  CONSTRAINT pk_movie_format PRIMARY KEY (movie_id, movie_format),
  CONSTRAINT ck_movie_format_value CHECK (movie_format IN ('2D', '3D')),
  CONSTRAINT fk_movie_format_movie FOREIGN KEY (movie_id)
    REFERENCES movie (id) ON DELETE CASCADE
);

-- TBL-14 auditorium (DC-Auditorium)
CREATE TABLE auditorium (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY,
  cinema_id BIGINT NOT NULL,
  name VARCHAR(50) NOT NULL,
  auditorium_type VARCHAR(10) NOT NULL,
  last_changed_at TIMESTAMPTZ NOT NULL,
  CONSTRAINT pk_auditorium PRIMARY KEY (id),
  CONSTRAINT ck_auditorium_name_not_blank CHECK (norm_name(name) <> ''),
  CONSTRAINT ck_auditorium_type CHECK (auditorium_type IN ('STANDARD', '4DX', 'IMAX')),
  CONSTRAINT fk_auditorium_cinema FOREIGN KEY (cinema_id)
    REFERENCES cinema (id) ON DELETE RESTRICT
);

-- TBL-19 auditorium_format (DC-Auditorium (supportedFormats))
CREATE TABLE auditorium_format (
  auditorium_id BIGINT NOT NULL,
  movie_format VARCHAR(2) NOT NULL,
  CONSTRAINT pk_auditorium_format PRIMARY KEY (auditorium_id, movie_format),
  CONSTRAINT ck_auditorium_format_value CHECK (movie_format IN ('2D', '3D')),
  CONSTRAINT fk_auditorium_format_auditorium FOREIGN KEY (auditorium_id)
    REFERENCES auditorium (id) ON DELETE CASCADE
);

-- TBL-15 seat (DC-Seat)
CREATE TABLE seat (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY,
  auditorium_id BIGINT NOT NULL,
  row_code VARCHAR(3) NOT NULL,
  seat_number INTEGER NOT NULL,
  seat_type VARCHAR(10) NOT NULL,
  in_seat_map BOOLEAN DEFAULT TRUE NOT NULL,
  CONSTRAINT pk_seat PRIMARY KEY (id),
  CONSTRAINT ck_seat_row_code_not_blank CHECK (btrim(row_code) <> ''),
  CONSTRAINT ck_seat_type CHECK (seat_type IN ('STANDARD', 'VIP', 'COUPLE')),
  CONSTRAINT ck_seat_number CHECK (seat_number > 0),
  CONSTRAINT fk_seat_auditorium FOREIGN KEY (auditorium_id)
    REFERENCES auditorium (id) ON DELETE RESTRICT
);

-- TBL-09 showtime (DC-Showtime)
CREATE TABLE showtime (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY,
  auditorium_id BIGINT NOT NULL,
  movie_id BIGINT NOT NULL,
  start_time TIMESTAMPTZ NOT NULL,
  sale_open_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  last_changed_at TIMESTAMPTZ NOT NULL,
  movie_format VARCHAR(2) NOT NULL,
  status VARCHAR(12) DEFAULT 'IN_SCHEDULE' NOT NULL,
  CONSTRAINT pk_showtime PRIMARY KEY (id),
  CONSTRAINT ck_showtime_status CHECK (status IN ('IN_SCHEDULE', 'DELETED')),
  CONSTRAINT ck_showtime_format CHECK (movie_format IN ('2D', '3D')),
  CONSTRAINT ck_showtime_sale_before_start CHECK (sale_open_time < start_time),
  CONSTRAINT ck_showtime_end_after_start CHECK (end_time > start_time),
  CONSTRAINT fk_showtime_auditorium FOREIGN KEY (auditorium_id)
    REFERENCES auditorium (id) ON DELETE RESTRICT,
  CONSTRAINT fk_showtime_movie FOREIGN KEY (movie_id)
    REFERENCES movie (id) ON DELETE RESTRICT,
  CONSTRAINT ex_showtime_auditorium_overlap EXCLUDE USING gist (auditorium_id WITH =, showtime_busy_range(start_time, end_time) WITH &&)
    WHERE (status = 'IN_SCHEDULE')
);

-- TBL-10 price_list (DC-PriceList)
CREATE TABLE price_list (
  cinema_id BIGINT NOT NULL,
  CONSTRAINT pk_price_list PRIMARY KEY (cinema_id),
  CONSTRAINT fk_price_list_cinema FOREIGN KEY (cinema_id)
    REFERENCES cinema (id) ON DELETE RESTRICT
);

-- TBL-17 price_entry (DC-PriceEntry)
CREATE TABLE price_entry (
  cinema_id BIGINT NOT NULL,
  auditorium_type VARCHAR(10) NOT NULL,
  movie_format VARCHAR(2) NOT NULL,
  seat_type VARCHAR(10) NOT NULL,
  time_band VARCHAR(20) NOT NULL,
  ticket_price BIGINT NOT NULL,
  last_changed_at TIMESTAMPTZ NOT NULL,
  removed BOOLEAN DEFAULT FALSE NOT NULL,
  CONSTRAINT pk_price_entry PRIMARY KEY (cinema_id, auditorium_type, movie_format, seat_type, time_band),
  CONSTRAINT ck_price_entry_auditorium_type CHECK (auditorium_type IN ('STANDARD', '4DX', 'IMAX')),
  CONSTRAINT ck_price_entry_movie_format CHECK (movie_format IN ('2D', '3D')),
  CONSTRAINT ck_price_entry_seat_type CHECK (seat_type IN ('STANDARD', 'VIP', 'COUPLE')),
  CONSTRAINT ck_price_entry_time_band CHECK (time_band IN ('WEEKDAY_BEFORE_17', 'WEEKDAY_FROM_17', 'WEEKEND_BEFORE_17', 'WEEKEND_FROM_17')),
  CONSTRAINT ck_price_entry_price CHECK (ticket_price > 0),
  CONSTRAINT fk_price_entry_price_list FOREIGN KEY (cinema_id)
    REFERENCES price_list (cinema_id) ON DELETE CASCADE
);

-- TBL-07 customer (DC-Customer)
CREATE TABLE customer (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY,
  email VARCHAR(254) NOT NULL,
  phone_number VARCHAR(10) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  CONSTRAINT pk_customer PRIMARY KEY (id),
  CONSTRAINT uq_customer_phone_number UNIQUE (phone_number),
  CONSTRAINT ck_customer_email_format CHECK (norm_email(email) ~ '^[^@[:space:]]+@[^@[:space:]]+$'),
  CONSTRAINT ck_customer_phone_format CHECK (phone_number ~ '^0[0-9]{9}$')
);

-- TBL-08 staff (DC-Staff, DC-BoxOfficeClerk, DC-TicketChecker, DC-CinemaManager, quản lý chuỗi): một bảng, vai trò là cột role.
CREATE TABLE staff (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY,
  email VARCHAR(254) NOT NULL,
  full_name VARCHAR(100) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(16) NOT NULL,
  cinema_id BIGINT,
  status VARCHAR(8) DEFAULT 'ACTIVE' NOT NULL,
  last_changed_at TIMESTAMPTZ NOT NULL,
  access_changed_at TIMESTAMPTZ NOT NULL,
  CONSTRAINT pk_staff PRIMARY KEY (id),
  CONSTRAINT ck_staff_email_format CHECK (norm_email(email) ~ '^[^@[:space:]]+@[^@[:space:]]+$'),
  CONSTRAINT ck_staff_full_name_not_blank CHECK (btrim(full_name) <> ''),
  CONSTRAINT ck_staff_role CHECK (role IN ('BOX_OFFICE_CLERK', 'TICKET_CHECKER', 'CINEMA_MANAGER', 'CHAIN_MANAGER')),
  CONSTRAINT ck_staff_status CHECK (status IN ('ACTIVE', 'LOCKED')),
  CONSTRAINT ck_staff_role_cinema CHECK ((role = 'CHAIN_MANAGER') = (cinema_id IS NULL)),
  CONSTRAINT fk_staff_cinema FOREIGN KEY (cinema_id)
    REFERENCES cinema (id) ON DELETE RESTRICT
);

-- TBL-22 administrator (DC-AdministratorAccount): đúng một dòng do cài đặt tạo, ngoài bảng staff (NFR-12).
CREATE TABLE administrator (
  id BIGINT DEFAULT 1 NOT NULL,
  email VARCHAR(254) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  CONSTRAINT pk_administrator PRIMARY KEY (id),
  CONSTRAINT ck_administrator_single_row CHECK (id = 1),
  CONSTRAINT ck_administrator_email_format CHECK (norm_email(email) ~ '^[^@[:space:]]+@[^@[:space:]]+$')
);

-- TBL-01 seat_hold (DC-SeatHold)
CREATE TABLE seat_hold (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY,
  showtime_id BIGINT NOT NULL,
  customer_id BIGINT,
  box_office_clerk_id BIGINT,
  hold_ref VARCHAR(36) NOT NULL,
  request_id VARCHAR(36) NOT NULL,
  status VARCHAR(16) DEFAULT 'ACTIVE' NOT NULL,
  hold_time TIMESTAMPTZ NOT NULL,
  expiry_time TIMESTAMPTZ NOT NULL,
  CONSTRAINT pk_seat_hold PRIMARY KEY (id),
  CONSTRAINT uq_seat_hold_hold_ref UNIQUE (hold_ref),
  CONSTRAINT uq_seat_hold_request_id UNIQUE (request_id),
  CONSTRAINT uq_seat_hold_id_showtime UNIQUE (id, showtime_id),
  CONSTRAINT ck_seat_hold_status CHECK (status IN ('ACTIVE', 'COMPLETED', 'EXPIRED', 'CANCELLED', 'PAYMENT_FAILED')),
  CONSTRAINT ck_seat_hold_one_holder CHECK (num_nonnulls(customer_id, box_office_clerk_id) = 1),
  CONSTRAINT ck_seat_hold_expiry CHECK (expiry_time = hold_time + interval '10 minutes'),
  CONSTRAINT fk_seat_hold_showtime FOREIGN KEY (showtime_id)
    REFERENCES showtime (id) ON DELETE RESTRICT,
  CONSTRAINT fk_seat_hold_customer FOREIGN KEY (customer_id)
    REFERENCES customer (id) ON DELETE RESTRICT,
  CONSTRAINT fk_seat_hold_staff FOREIGN KEY (box_office_clerk_id)
    REFERENCES staff (id) ON DELETE RESTRICT
);

-- TBL-02 seat_status (DC-SeatStatus)
CREATE TABLE seat_status (
  showtime_id BIGINT NOT NULL,
  seat_id BIGINT NOT NULL,
  state VARCHAR(10) DEFAULT 'AVAILABLE' NOT NULL,
  held_price BIGINT,
  current_hold_id BIGINT,
  current_ticket_id BIGINT,
  event_seq BIGINT DEFAULT 0 NOT NULL,
  CONSTRAINT pk_seat_status PRIMARY KEY (showtime_id, seat_id),
  CONSTRAINT ck_seat_status_state_link CHECK ((state = 'AVAILABLE' AND current_hold_id IS NULL AND current_ticket_id IS NULL AND held_price IS NULL)
    OR (state = 'HELD' AND current_hold_id IS NOT NULL AND current_ticket_id IS NULL AND held_price IS NOT NULL)
    OR (state = 'SOLD' AND current_hold_id IS NULL AND current_ticket_id IS NOT NULL AND held_price IS NOT NULL)),
  CONSTRAINT ck_seat_status_price CHECK (held_price > 0),
  CONSTRAINT ck_seat_status_event_seq CHECK (event_seq >= 0),
  CONSTRAINT fk_seat_status_showtime FOREIGN KEY (showtime_id)
    REFERENCES showtime (id) ON DELETE RESTRICT,
  CONSTRAINT fk_seat_status_seat FOREIGN KEY (seat_id)
    REFERENCES seat (id) ON DELETE RESTRICT,
  CONSTRAINT fk_seat_status_seat_hold FOREIGN KEY (current_hold_id, showtime_id)
    REFERENCES seat_hold (id, showtime_id) ON DELETE RESTRICT
);

-- TBL-03 payment_transaction (DC-PaymentTransaction)
CREATE TABLE payment_transaction (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY,
  seat_hold_id BIGINT NOT NULL,
  code VARCHAR(20) NOT NULL,
  amount BIGINT NOT NULL,
  status VARCHAR(16) DEFAULT 'PENDING' NOT NULL,
  gateway_transaction_no VARCHAR(30),
  paid_at TIMESTAMPTZ,
  late_reason VARCHAR(200),
  refunded_total BIGINT DEFAULT 0 NOT NULL,
  duplicate_report_count INTEGER DEFAULT 0 NOT NULL,
  CONSTRAINT pk_payment_transaction PRIMARY KEY (id),
  CONSTRAINT uq_payment_transaction_code UNIQUE (code),
  CONSTRAINT ck_payment_transaction_status CHECK (status IN ('PENDING', 'FAILED', 'TICKETED', 'LATE_PAYMENT')),
  CONSTRAINT ck_payment_transaction_amount CHECK (amount > 0),
  CONSTRAINT ck_payment_transaction_refund_limit CHECK (refunded_total >= 0 AND refunded_total <= amount),
  CONSTRAINT ck_payment_transaction_refund_paid CHECK (refunded_total = 0 OR status IN ('TICKETED', 'LATE_PAYMENT')),
  CONSTRAINT ck_payment_transaction_duplicate CHECK (duplicate_report_count >= 0),
  CONSTRAINT ck_payment_transaction_paid_info CHECK (status NOT IN ('TICKETED', 'LATE_PAYMENT') OR (paid_at IS NOT NULL AND gateway_transaction_no IS NOT NULL)),
  CONSTRAINT ck_payment_transaction_late_reason CHECK (status <> 'LATE_PAYMENT' OR late_reason IS NOT NULL),
  CONSTRAINT fk_payment_transaction_seat_hold FOREIGN KEY (seat_hold_id)
    REFERENCES seat_hold (id) ON DELETE RESTRICT
);

-- TBL-05 booking (DC-Booking)
CREATE TABLE booking (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY,
  booking_code VARCHAR(16) NOT NULL,
  seat_hold_id BIGINT NOT NULL,
  customer_id BIGINT,
  booked_at TIMESTAMPTZ NOT NULL,
  CONSTRAINT pk_booking PRIMARY KEY (id),
  CONSTRAINT uq_booking_booking_code UNIQUE (booking_code),
  CONSTRAINT uq_booking_seat_hold UNIQUE (seat_hold_id),
  CONSTRAINT fk_booking_seat_hold FOREIGN KEY (seat_hold_id)
    REFERENCES seat_hold (id) ON DELETE RESTRICT,
  CONSTRAINT fk_booking_customer FOREIGN KEY (customer_id)
    REFERENCES customer (id) ON DELETE RESTRICT
);

-- TBL-06 ticket (DC-Ticket)
CREATE TABLE ticket (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY,
  booking_id BIGINT NOT NULL,
  showtime_id BIGINT NOT NULL,
  seat_id BIGINT NOT NULL,
  ticket_code VARCHAR(16) NOT NULL,
  price BIGINT NOT NULL,
  movie_title VARCHAR(200) NOT NULL,
  cinema_name VARCHAR(100) NOT NULL,
  auditorium_name VARCHAR(50) NOT NULL,
  auditorium_type VARCHAR(10) NOT NULL,
  status VARCHAR(10) DEFAULT 'UNUSED' NOT NULL,
  CONSTRAINT pk_ticket PRIMARY KEY (id),
  CONSTRAINT uq_ticket_ticket_code UNIQUE (ticket_code),
  CONSTRAINT uq_ticket_id_showtime_seat UNIQUE (id, showtime_id, seat_id),
  CONSTRAINT ck_ticket_status CHECK (status IN ('UNUSED', 'USED', 'CANCELLED')),
  CONSTRAINT ck_ticket_price CHECK (price > 0),
  CONSTRAINT ck_ticket_auditorium_type CHECK (auditorium_type IN ('STANDARD', '4DX', 'IMAX')),
  CONSTRAINT fk_ticket_booking FOREIGN KEY (booking_id)
    REFERENCES booking (id) ON DELETE RESTRICT,
  CONSTRAINT fk_ticket_seat_status FOREIGN KEY (showtime_id, seat_id)
    REFERENCES seat_status (showtime_id, seat_id) ON DELETE RESTRICT
);

-- Vòng tham chiếu seat_status <--> ticket: khoá ngoại của seat_status tới ticket tạo sau khi có bảng ticket.
ALTER TABLE seat_status ADD CONSTRAINT fk_seat_status_ticket FOREIGN KEY (current_ticket_id, showtime_id, seat_id)
    REFERENCES ticket (id, showtime_id, seat_id) ON DELETE RESTRICT;

-- TBL-04 refund_request (DC-RefundRequest)
CREATE TABLE refund_request (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY,
  payment_transaction_id BIGINT,
  ticket_id BIGINT,
  idempotency_key VARCHAR(64) NOT NULL,
  request_type VARCHAR(16) NOT NULL,
  refund_amount BIGINT NOT NULL,
  attempt_count INTEGER DEFAULT 0 NOT NULL,
  status VARCHAR(16) DEFAULT 'NEW' NOT NULL,
  refund_result VARCHAR(200),
  CONSTRAINT pk_refund_request PRIMARY KEY (id),
  CONSTRAINT uq_refund_request_ticket UNIQUE (ticket_id),
  CONSTRAINT uq_refund_request_idempotency_key UNIQUE (idempotency_key),
  CONSTRAINT ck_refund_request_status CHECK (status IN ('NEW', 'IN_FLIGHT', 'WAITING_RETRY', 'REFUNDED', 'MANUAL_REQUIRED')),
  CONSTRAINT ck_refund_request_type CHECK (request_type IN ('FULL', 'TICKET_GATEWAY', 'TICKET_CASH')),
  CONSTRAINT ck_refund_request_link CHECK ((request_type = 'FULL' AND payment_transaction_id IS NOT NULL AND ticket_id IS NULL)
    OR (request_type = 'TICKET_GATEWAY' AND payment_transaction_id IS NOT NULL AND ticket_id IS NOT NULL)
    OR (request_type = 'TICKET_CASH' AND payment_transaction_id IS NULL AND ticket_id IS NOT NULL)),
  CONSTRAINT ck_refund_request_amount CHECK (refund_amount > 0),
  CONSTRAINT ck_refund_request_attempts CHECK (attempt_count BETWEEN 0 AND 4),
  CONSTRAINT ck_refund_request_attempt_status CHECK ((status <> 'NEW' OR attempt_count = 0)
    AND (status NOT IN ('IN_FLIGHT', 'WAITING_RETRY') OR attempt_count >= 1)
    AND (status <> 'REFUNDED' OR request_type = 'TICKET_CASH' OR attempt_count >= 1)),
  CONSTRAINT fk_refund_request_payment_transaction FOREIGN KEY (payment_transaction_id)
    REFERENCES payment_transaction (id) ON DELETE RESTRICT,
  CONSTRAINT fk_refund_request_ticket FOREIGN KEY (ticket_id)
    REFERENCES ticket (id) ON DELETE RESTRICT
);

-- TBL-20 seat_event (DC-SeatChangeEvent)
CREATE TABLE seat_event (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY,
  showtime_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT clock_timestamp() NOT NULL,
  items JSONB NOT NULL,
  CONSTRAINT pk_seat_event PRIMARY KEY (id),
  CONSTRAINT ck_seat_event_items CHECK (jsonb_typeof(items) = 'array' AND jsonb_array_length(items) > 0)
);

-- TBL-21 outbox (DC-OutboxEntry)
CREATE TABLE outbox (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY,
  kind VARCHAR(16) NOT NULL,
  source_id BIGINT NOT NULL,
  status VARCHAR(10) DEFAULT 'PENDING' NOT NULL,
  attempt_count INTEGER DEFAULT 0 NOT NULL,
  next_attempt_at TIMESTAMPTZ DEFAULT clock_timestamp() NOT NULL,
  claim_token UUID,
  claimed_until TIMESTAMPTZ,
  idempotency_key VARCHAR(100) NOT NULL,
  last_error VARCHAR(500),
  created_at TIMESTAMPTZ DEFAULT clock_timestamp() NOT NULL,
  CONSTRAINT pk_outbox PRIMARY KEY (id),
  CONSTRAINT uq_outbox_idempotency_key UNIQUE (idempotency_key),
  CONSTRAINT ck_outbox_kind CHECK (kind IN ('REFUND_GATEWAY', 'EMAIL_TICKET', 'EMAIL_REFUND')),
  CONSTRAINT ck_outbox_status CHECK (status IN ('PENDING', 'SUCCEEDED', 'EXHAUSTED')),
  CONSTRAINT ck_outbox_attempts CHECK (attempt_count >= 0),
  CONSTRAINT ck_outbox_claim_pair CHECK ((claim_token IS NULL) = (claimed_until IS NULL))
);

-- Chỉ mục (F6.3)
CREATE UNIQUE INDEX uq_cinema_name_norm ON cinema (norm_name(name));
CREATE UNIQUE INDEX uq_auditorium_cinema_name_norm ON auditorium (cinema_id, norm_name(name));
CREATE UNIQUE INDEX uq_customer_email_norm ON customer (norm_email(email));
CREATE UNIQUE INDEX uq_staff_email_norm ON staff (norm_email(email));
CREATE UNIQUE INDEX uq_seat_position ON seat (auditorium_id, row_code, seat_number) WHERE in_seat_map;
CREATE INDEX ix_auditorium_cinema ON auditorium (cinema_id);
CREATE INDEX ix_showtime_auditorium_start ON showtime (auditorium_id, start_time);
CREATE INDEX ix_booking_customer_booked ON booking (customer_id, booked_at DESC) WHERE customer_id IS NOT NULL;
CREATE UNIQUE INDEX uq_seat_hold_active_customer ON seat_hold (customer_id) WHERE status = 'ACTIVE';
CREATE UNIQUE INDEX uq_seat_hold_active_clerk ON seat_hold (box_office_clerk_id) WHERE status = 'ACTIVE';
CREATE INDEX ix_seat_hold_expiry ON seat_hold (expiry_time) WHERE status = 'ACTIVE';
CREATE INDEX ix_seat_hold_showtime_active ON seat_hold (showtime_id) WHERE status = 'ACTIVE';
CREATE INDEX ix_seat_status_current_hold ON seat_status (current_hold_id) WHERE current_hold_id IS NOT NULL;
CREATE UNIQUE INDEX uq_seat_status_current_ticket ON seat_status (current_ticket_id) WHERE current_ticket_id IS NOT NULL;
CREATE INDEX ix_seat_status_seat ON seat_status (seat_id);
CREATE UNIQUE INDEX uq_payment_transaction_ticketed_hold ON payment_transaction (seat_hold_id) WHERE status = 'TICKETED';
CREATE UNIQUE INDEX uq_payment_transaction_gateway_no ON payment_transaction (gateway_transaction_no) WHERE gateway_transaction_no IS NOT NULL;
CREATE INDEX ix_payment_transaction_hold ON payment_transaction (seat_hold_id, id);
CREATE UNIQUE INDEX uq_ticket_active_seat ON ticket (showtime_id, seat_id) WHERE status <> 'CANCELLED';
CREATE INDEX ix_ticket_showtime_seat ON ticket (showtime_id, seat_id);
CREATE INDEX ix_ticket_booking ON ticket (booking_id);
CREATE UNIQUE INDEX uq_refund_request_full_per_payment ON refund_request (payment_transaction_id) WHERE request_type = 'FULL';
CREATE INDEX ix_refund_request_payment ON refund_request (payment_transaction_id);
CREATE INDEX ix_refund_request_manual ON refund_request (id) WHERE status = 'MANUAL_REQUIRED';
CREATE INDEX ix_seat_event_showtime_event ON seat_event (showtime_id, id);
CREATE INDEX ix_seat_event_created_at ON seat_event (created_at);
CREATE INDEX ix_outbox_due ON outbox (kind, next_attempt_at) WHERE status = 'PENDING';

-- Trạng thái cuối không đổi và chỉ đi theo đồ thị chuyển hợp lệ (ST-01 đến ST-07, DC-OutboxStatus).
-- Tên cột trạng thái truyền qua tham số của trigger vì seat_status dùng cột state, seat dùng cột in_seat_map (kiểu BOOLEAN,
-- so sánh dạng chữ true và false), các bảng khác dùng status. Staff không có trigger vì ACTIVE và LOCKED chuyển qua lại (ST-12).
CREATE FUNCTION fn_enforce_status_transition() RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  old_val text := to_jsonb(OLD) ->> TG_ARGV[0];
  new_val text := to_jsonb(NEW) ->> TG_ARGV[0];
  allowed text[];
BEGIN
  allowed := CASE TG_TABLE_NAME || ':' || old_val
    WHEN 'seat_hold:ACTIVE' THEN ARRAY['COMPLETED', 'EXPIRED', 'CANCELLED', 'PAYMENT_FAILED']
    WHEN 'seat_status:AVAILABLE' THEN ARRAY['HELD']
    WHEN 'seat_status:HELD' THEN ARRAY['SOLD', 'AVAILABLE']
    WHEN 'seat_status:SOLD' THEN ARRAY['AVAILABLE']
    WHEN 'ticket:UNUSED' THEN ARRAY['USED', 'CANCELLED']
    WHEN 'payment_transaction:PENDING' THEN ARRAY['FAILED', 'TICKETED', 'LATE_PAYMENT']
    WHEN 'payment_transaction:FAILED' THEN ARRAY['LATE_PAYMENT']
    WHEN 'refund_request:NEW' THEN ARRAY['IN_FLIGHT']
    WHEN 'refund_request:IN_FLIGHT' THEN ARRAY['WAITING_RETRY', 'REFUNDED', 'MANUAL_REQUIRED']
    WHEN 'refund_request:WAITING_RETRY' THEN ARRAY['IN_FLIGHT']
    WHEN 'outbox:PENDING' THEN ARRAY['SUCCEEDED', 'EXHAUSTED']
    WHEN 'showtime:IN_SCHEDULE' THEN ARRAY['DELETED']
    WHEN 'seat:true' THEN ARRAY['false']
  END;
  IF allowed IS NULL OR NOT (new_val = ANY (allowed)) THEN
    RAISE EXCEPTION 'Chuyển trạng thái % --> % của bảng % không hợp lệ', old_val, new_val, TG_TABLE_NAME
      USING ERRCODE = 'check_violation';
  END IF;
  RETURN NEW;
END
$$;

-- Liên kết hiện tại của ghế chỉ đi NULL --> giá trị hoặc giá trị --> NULL; ghi đè trực tiếp sang giá trị khác
-- nghĩa là có đường ghi quên kiểm trạng thái, và bị từ chối thay vì làm mất lần giữ ghế hoặc vé đang có.
CREATE FUNCTION fn_seat_status_link_guard() RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF (OLD.current_hold_id IS NOT NULL AND NEW.current_hold_id IS NOT NULL
        AND NEW.current_hold_id <> OLD.current_hold_id)
     OR (OLD.current_ticket_id IS NOT NULL AND NEW.current_ticket_id IS NOT NULL
        AND NEW.current_ticket_id <> OLD.current_ticket_id) THEN
    RAISE EXCEPTION 'Ghế (suất chiếu %, ghế %) đang có liên kết hiện tại, phải trả ghế trước khi gán liên kết khác',
      OLD.showtime_id, OLD.seat_id
      USING ERRCODE = 'check_violation';
  END IF;
  RETURN NEW;
END
$$;

CREATE TRIGGER trg_seat_status_link BEFORE UPDATE OF current_hold_id, current_ticket_id ON seat_status
  FOR EACH ROW EXECUTE FUNCTION fn_seat_status_link_guard();

CREATE TRIGGER trg_seat_hold_status BEFORE UPDATE OF status ON seat_hold
  FOR EACH ROW WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION fn_enforce_status_transition('status');
CREATE TRIGGER trg_seat_status_state BEFORE UPDATE OF state ON seat_status
  FOR EACH ROW WHEN (OLD.state IS DISTINCT FROM NEW.state)
  EXECUTE FUNCTION fn_enforce_status_transition('state');
CREATE TRIGGER trg_ticket_status BEFORE UPDATE OF status ON ticket
  FOR EACH ROW WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION fn_enforce_status_transition('status');
CREATE TRIGGER trg_payment_transaction_status BEFORE UPDATE OF status ON payment_transaction
  FOR EACH ROW WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION fn_enforce_status_transition('status');
CREATE TRIGGER trg_refund_request_status BEFORE UPDATE OF status ON refund_request
  FOR EACH ROW WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION fn_enforce_status_transition('status');
CREATE TRIGGER trg_outbox_status BEFORE UPDATE OF status ON outbox
  FOR EACH ROW WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION fn_enforce_status_transition('status');
CREATE TRIGGER trg_showtime_status BEFORE UPDATE OF status ON showtime
  FOR EACH ROW WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION fn_enforce_status_transition('status');
CREATE TRIGGER trg_seat_in_seat_map BEFORE UPDATE OF in_seat_map ON seat
  FOR EACH ROW WHEN (OLD.in_seat_map IS DISTINCT FROM NEW.in_seat_map)
  EXECUTE FUNCTION fn_enforce_status_transition('in_seat_map');

-- Cột bất biến sau khi tạo: giá trị lúc bán của vé (BR-140, BR-67) và email nhân viên (khoá FOR NO KEY UPDATE của EX-22
-- chỉ đúng khi email không đổi, vì chỉ mục unique theo biểu thức không phải khoá mà khoá ngoại có thể tham chiếu).
CREATE FUNCTION fn_reject_update() RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  RAISE EXCEPTION 'Cột % của bảng % không được sửa sau khi tạo', TG_ARGV[0], TG_TABLE_NAME
    USING ERRCODE = 'check_violation';
END
$$;

CREATE TRIGGER trg_ticket_sale_values BEFORE UPDATE OF price, movie_title, cinema_name, auditorium_name, auditorium_type ON ticket
  FOR EACH ROW WHEN (OLD.price IS DISTINCT FROM NEW.price OR OLD.movie_title IS DISTINCT FROM NEW.movie_title
    OR OLD.cinema_name IS DISTINCT FROM NEW.cinema_name OR OLD.auditorium_name IS DISTINCT FROM NEW.auditorium_name
    OR OLD.auditorium_type IS DISTINCT FROM NEW.auditorium_type)
  EXECUTE FUNCTION fn_reject_update('giá trị lúc bán');
CREATE TRIGGER trg_staff_email BEFORE UPDATE OF email ON staff
  FOR EACH ROW WHEN (OLD.email IS DISTINCT FROM NEW.email)
  EXECUTE FUNCTION fn_reject_update('email');

-- booking.customer_id là bản sao của người giữ ghế khách của lần giữ ghế (R-51, R-48): rỗng khi người giữ là nhân viên quầy.
CREATE FUNCTION fn_booking_customer_guard() RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  holder_customer_id BIGINT;
BEGIN
  SELECT customer_id INTO holder_customer_id FROM seat_hold WHERE id = NEW.seat_hold_id;
  IF NEW.customer_id IS DISTINCT FROM holder_customer_id THEN
    RAISE EXCEPTION 'booking.customer_id (%) khác khách của lần giữ ghế % (%)',
      NEW.customer_id, NEW.seat_hold_id, holder_customer_id
      USING ERRCODE = 'check_violation';
  END IF;
  RETURN NEW;
END
$$;

CREATE TRIGGER trg_booking_customer BEFORE INSERT OR UPDATE OF customer_id, seat_hold_id ON booking
  FOR EACH ROW EXECUTE FUNCTION fn_booking_customer_guard();

-- Mỗi cụm rạp có đúng một bảng giá (R-40): kiểm lúc COMMIT để INSERT cụm rạp và INSERT bảng giá nằm cùng giao dịch theo thứ tự tuỳ ý.
CREATE FUNCTION fn_cinema_has_price_list() RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM price_list WHERE cinema_id = NEW.id) THEN
    RAISE EXCEPTION 'Cụm rạp % chưa có bảng giá', NEW.id
      USING ERRCODE = 'check_violation';
  END IF;
  RETURN NULL;
END
$$;

CREATE CONSTRAINT TRIGGER trg_cinema_has_price_list AFTER INSERT ON cinema
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION fn_cinema_has_price_list();
```

### F9.1. Kết quả chạy thật trên PostgreSQL 16

Môi trường: docker run postgres:16 (16.16, bộ mã UTF8, locale en_US.utf8), áp design/P13-schema.sql bằng psql với ON_ERROR_STOP=1: 0 lỗi, 20 bảng. Bộ ca thử design/P13-schema-tests.sql chạy trong một giao dịch rồi ROLLBACK, mỗi ca ghi mong đợi và tự báo ĐẠT hoặc TRƯỢT: 207/207 ca đạt. Phủ: một lần giữ ghế ACTIVE mỗi khách và mỗi nhân viên quầy; một vé chưa huỷ mỗi ghế mỗi suất chiếu; EXCLUDE chồng giờ cùng phòng (kể cả khoảng dọn phòng 15 phút, suất đã xoá không tính); rời trạng thái cuối bị chặn ở seat_hold, ticket, payment_transaction, refund_request, outbox, showtime, seat; trg_seat_status_link chặn đổi thẳng liên kết lần giữ ghế và vé, cho đường hai lượt; unique IPN (mã giao dịch, một giao dịch TICKETED mỗi lần giữ ghế, mã cổng, một lần đặt mỗi lần giữ ghế); khoá chống hoàn trùng, mỗi vé một yêu cầu hoàn, một lần hoàn toàn bộ mỗi giao dịch; outbox: idempotency_key, claim từng dòng bằng LIMIT 1 SKIP LOCKED, hàng rào claim_token, nhận lại dòng hết hạn claim; BR-92 khoá ngoại khi đổi phòng (xoá seat_status của suất chiếu từng có vé bị 23503); email nhân viên (xuyên vai trò), email khách và số điện thoại khách, tên cụm rạp, tên phòng unique theo norm (chữ có dấu, hoa thường, khoảng trắng); các bảng và ràng buộc mới (staff, administrator, booking.customer_id, giá trị lúc bán của vé, in_seat_map, cụm rạp phải có bảng giá, CHECK của phim, cụm rạp); mẫu câu khoá của F4.5 chạy được; năm kịch bản đồng thời hai phiên psql (Phần B của file kiểm thử), kết quả chạy thật:

| Mã | Kịch bản | Kết quả |
|---|---|---|
| B1 | Hai phiên cùng giữ ghế (suất chiếu 1, ghế 1) theo chuỗi khoá EX-01, phiên A giữ giao dịch mở 3 giây, phiên B bắt đầu sau 1 giây | Phiên A giữ được (seat_status HELD, current_hold_id 101); phiên B nhận 55P03 ở câu seat_status FOR NO KEY UPDATE NOWAIT (could not obtain lock on row in relation seat_status); khách 2 không có lần giữ ghế |
| B2 | Khoá giá trị hạng 0: phiên A giữ pg_advisory_xact_lock(1000, hashtext(norm_name(Cụm Mới))) | Phiên B cùng tên viết khác hoa thường và khoảng trắng chờ rồi hết lock_timeout 800 ms (55P03); tên khác hẳn lấy khoá ngay |
| B3 | Claim từng dòng outbox: hai phiên cùng chạy câu LIMIT 1 FOR NO KEY UPDATE SKIP LOCKED trong giao dịch mở | Phiên A nhận dòng 1, phiên B nhận dòng 2, không ai chờ |
| B4 | Phiên A UPDATE tên cụm rạp chưa COMMIT; phiên B INSERT phòng chiếu và INSERT nhân viên của cụm rạp đó | Cả hai INSERT chạy xong ngay, không chờ (chỉ mục unique theo biểu thức không phải khoá mà khoá ngoại tham chiếu) |
| B5 | Báo cáo BEGIN ISOLATION LEVEL REPEATABLE READ READ ONLY đếm vé, phiên ghi INSERT vé và COMMIT giữa hai lần đếm | INSERT vé xong sau 2 ms (không chờ báo cáo); báo cáo đếm lại trong cùng giao dịch vẫn thấy 0 vé, sau COMMIT thấy 1 |

Bộ ca đo đồng thời T1 đến T6 của P09 F7.9 (1.000 giao dịch song song, p95, không có 40P01) chưa chạy: thuộc X2 và Project 3.

### F9.2. Đối chiếu đầu vào của lần chạy lại P13

| Phần tử | Nội dung đề nghị | Xử lý ở 2.0 |
|---|---|---|
| booking | customer_id nullable, booked_at, chỉ mục (customer_id, booked_at giảm dần) | Có: cột, fk_booking_customer, ix_booking_customer_booked, trg_booking_customer, F5.3 |
| ticket | movie_title, cinema_name, auditorium_name, auditorium_type NOT NULL sao chép lúc bán (BR-140) | Có: bốn cột NOT NULL, ck_ticket_auditorium_type, trg_ticket_sale_values (C-26) |
| seat | in_seat_map mặc định TRUE; uq_seat_position unique từng phần | Có: chỉ mục từng phần, trg_seat_in_seat_map (C-27) |
| showtime | Không có cột sức chứa; sức chứa lúc mở bán | Không cột; sức chứa là số dòng seat_status (BR-118); trg_showtime_status (C-28) |
| cinema | province, last_changed_at; tên duy nhất | Có; uq_cinema_name_norm (C-23) |
| movie | trailer, last_changed_at, thời lượng, ngày, nhãn độ tuổi; mã phim không cột | Có; ck_movie_* ; movieCode suy từ id |
| auditorium | last_changed_at; (cinema_id, tên) duy nhất | Có; uq_auditorium_cinema_name_norm |
| staff | Gộp TBL-08, TBL-11, TBL-12; id, email, full_name, password_hash, role, cinema_id NULL, status, last_changed_at, access_changed_at; seat_hold.box_office_clerk_id tới staff; bảng administrator một dòng | Có (TBL-08, TBL-22; F4.3, C-24, C-31, C-32) |
| hàm chuẩn hoá | norm_email, norm_name immutable; chỉ mục unique theo biểu thức; cơ sở dữ liệu có locale tiếng Việt cho lower() | Có; hai hàm, bốn chỉ mục theo biểu thức; yêu cầu locale ghi ở F1 và đầu script. P12 đề xuất thêm "cột giá trị norm_name": không thêm cột, vì P09 F7.3 chọn chỉ mục theo biểu thức (UPDATE tên chỉ lấy NO KEY UPDATE) |
| khoá giá trị | Không bảng khoá giá trị; khoá tư vấn hai số nguyên | Có: F1, F4.5 (hạng 0, 11 đến 13) |
| chỉ mục báo cáo | Không đổi | ix_showtime_auditorium_start bỏ điều kiện từng phần để phục vụ cả suất chiếu đã xoá còn vé (F6.3) |
| P09 Đề xuất: cụm rạp tạo cùng bảng giá rỗng | R-40 | trg_cinema_has_price_list (C-29) |
| P09 Đề xuất: khoá ngoại phòng, suất chiếu, ghế không CASCADE | Lưới an toàn của EX-19 | Mọi khoá ngoại này RESTRICT (C-30) |
| P09 Đề xuất: mốc thay đổi cho phim, cụm rạp, phòng chiếu, nhân viên, mục giá | Cột mốc | Có (C-33); đề xuất số phiên bản không dùng, so mốc thời gian theo P12 |
| P10 Đề xuất: tài khoản quản trị viên (Q-271) | Bảng một dòng | TBL-22 administrator |
| P12 Vấn đề còn mở 9 (state machine Showtime) | Một chiều IN_SCHEDULE sang DELETED | Đã chốt ở P12 ST-06; thêm trg_showtime_status |
| 1.5 Vấn đề còn mở 9 | Trigger cho showtime.status | Đã áp dụng (trg_showtime_status) |

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Trạng thái | Trả lời |
|---|---|---|---|---|---|
| Q-136 | Tài khoản nhân viên (UC-017) gồm những thuộc tính nào (tên đăng nhập hoặc email, mật khẩu băm, họ tên, trạng thái) và lưu thành ba bảng theo ba lớp P08 (box_office_clerk, ticket_checker, cinema_manager) hay một bảng nhân viên có cột vai trò (BR-79: mỗi nhân viên đúng một vai trò)? Khi nhân viên nghỉ việc, tài khoản bị xoá hay chỉ khoá, trong khi lần giữ ghế cũ vẫn trỏ tới nhân viên quầy (ON DELETE RESTRICT)? | TBL-08, TBL-11, TBL-12, fk_seat_hold_staff, ck_seat_hold_one_holder | P08 F3 AC-E-BoxOfficeClerk, AC-E-TicketChecker, AC-E-CinemaManager "Tạm (chờ P07 của UC-017)"; BR-78, BR-79; P12 F7 chỉ có thuộc tính id | Đã trả lời | Bản 1.1: giữ ba bảng, mỗi bảng thêm email duy nhất, password_hash, full_name, active. Bản 2.0: thay bằng một bảng staff có cột role (P08 2.0 Q-228: Staff là lớp cha ba lớp con, R-67 đến R-69; BR-95 buộc email duy nhất xuyên ba vai trò; Q-271: quản trị viên ở bảng riêng). Nghỉ việc vẫn là khoá tài khoản (status LOCKED, BR-96), không xoá, vì lần giữ ghế và vé cũ còn trỏ tới nhân viên (ON DELETE RESTRICT) |
| Q-137 | Các danh mục UC-010, UC-011, UC-012 có thêm thuộc tính nào ngoài phần các UC đã phân tích dùng: phim (thể loại, độ tuổi được xem, mô tả, trailer), cụm rạp (địa chỉ), phòng chiếu (sức chứa có lưu riêng hay đếm từ ghế) và sơ đồ ghế (có ghế vật lý không dùng, lối đi)? | TBL-13, TBL-14, TBL-15, TBL-16, TBL-18, TBL-19 | P05 GL-37, GL-40; P08 F3 các lớp Tạm (chờ P07 của UC-010, UC-011, UC-012) | Đã trả lời | movie thêm genre, age_rating, description; cinema thêm address; tất cả NULL được. Không thêm ghế vật lý không dùng, lối đi biểu diễn bằng khoảng trống số ghế; sức chứa đếm từ bảng seat, không lưu cột riêng |
| Q-138 | Dữ liệu lịch sử của suất chiếu đã chiếu (seat_status, seat_hold, ticket, payment_transaction, refund_request, outbox đã xong) phải lưu bao lâu trước khi lưu trữ hoặc xoá? Mỗi ngày phát sinh tối đa khoảng 200.000 dòng seat_status (NFR-04) nên khoảng 73 triệu dòng mỗi năm nếu giữ hết | Quyết định phân vùng bảng theo ngày chiếu hoặc công việc dọn; F1 mục khối lượng; chỉ mục của seat_status | P06 không có yêu cầu về thời gian lưu dữ liệu; BR-58 chỉ yêu cầu giữ dữ liệu suất chiếu đã xoá cho vé, hoàn tiền, báo cáo | Đã trả lời | Đồ án giữ toàn bộ dữ liệu lịch sử, không phân vùng, không dọn. Sản phẩm thật: lưu trữ seat_status và seat_hold của suất chiếu cũ hơn 90 ngày, giữ ticket, payment_transaction, refund_request lâu hơn theo yêu cầu kế toán, dọn outbox đã xong sau 30 ngày (Vấn đề còn mở 4) |

## Giả định

Không có (chế độ NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P09 | F7.3 EX-09 | Ghi "CHECK refunded_total <= paid_amount", trong khi P12 F7 chốt thuộc tính là amount (số tiền chốt của lần giữ ghế, cũng là số cổng báo đã trả) và không có paid_amount | Đổi paid_amount thành amount; P13 dùng amount (ck_payment_transaction_refund_limit) (Đã áp dụng: P09 1.4, F7.3 EX-09 dùng amount) |
| P12 | F7 DC-RefundRequest.idempotencyKey; P08 F3 generateIdempotencyKey | idempotencyKey có multiplicity 1 {unique} nhưng hoàn tiền mặt (TICKET_CASH) không có giao dịch để dựng khoá "từ mã giao dịch và loại yêu cầu" | Ghi rõ cách dựng khoá cho TICKET_CASH (ví dụ từ mã vé và loại yêu cầu); P13 giữ cột NOT NULL UNIQUE theo P12 (Chờ P12: sửa ở artifact P12, ngoài phạm vi lượt này) |
| P12 | Lượt PKG-27 (DC-PriceList.entries, DC-PriceEntry) | R-41 nói bỏ mục giá là bỏ khỏi bảng giá, trong khi P08 F3 yêu cầu PriceList nhớ mốc thay đổi "kể cả tổ hợp đã bỏ" (BR-63) | Thêm thuộc tính removed (Boolean, mặc định false) cho DC-PriceEntry; "bỏ" là đặt removed = true và giữ mốc thay đổi. P13 đã lưu price_entry.removed (Chờ P12: sửa ở artifact P12, ngoài phạm vi lượt này) |
| P12 | F7 DC-Ticket | Vé không có thuộc tính showtime và seat, trong khi khoá ghép (showtimeId, seatId) của R-54 là danh tính ghế của vé | Ghi trong F7 hoặc F5 rằng Ticket giữ SeatKey; P13 ánh xạ thành ticket.showtime_id và ticket.seat_id (Chờ P12: sửa ở artifact P12, ngoài phạm vi lượt này) |
| P12 | F7 DC-SeatStatus | Cột event_seq P12 coi là cột kỹ thuật ngoài thuộc tính miền; P13 mặc định 0 và NOT NULL cho ghế chưa có sự kiện | Không cần sửa; ghi nhận để EX-13 (tạo SeatStatus Trống) ghi event_seq cùng sự kiện tạo ghế hoặc để 0 (Không cần sửa) |
| P04 | UC-014, BR-53 | BR-53 và C-19 chỉ cấm sửa suất chiếu khi còn lần giữ ghế đang giữ hoặc vé chưa huỷ, nhưng đổi phòng thay toàn bộ seat_status và bị fk_ticket_seat_status chặn khi suất chiếu từng có vé đã huỷ | Bổ sung: đổi phòng chỉ cho phép khi suất chiếu chưa từng có vé (kể cả đã huỷ); nếu không thì xoá suất chiếu cũ và lập suất mới (BR-58 giữ dữ liệu). P12 DC-Showtime.Update (đổi phòng) cần kiểm điều kiện này (Đã áp dụng: chủ dự án chốt R13D-01 phương án A; quy tắc là BR-92 ở P04 UC-014 và sổ BR, đề bài Mục 16, C-19, F4.5 EX-13) |
| P12 | Vấn đề còn mở 9 (state machine Showtime) | Chưa có cung chuyển trạng thái cho Showtime nên CSDL không chặn DELETED --> IN_SCHEDULE, trái BR-58 | Chốt Showtime: IN_SCHEDULE --> DELETED một chiều; khi đó P13 thêm cung vào fn_enforce_status_transition và trigger trg_showtime_status (Chờ P12: sửa ở artifact P12, ngoài phạm vi lượt này) |
| P12 | PKG-16-PKG-27 F7 DC-Movie.genre, DC-Movie.ageRating, DC-Movie.description (multiplicity 1) so với P04 UC-010 dữ liệu vào 1 (thể loại, độ tuổi, mô tả "Không bắt buộc") | P12 và P04 lệch nhau: P12 CheckMovieInfoValid bắt buộc thể loại không trống, nhãn độ tuổi thuộc tập; P04 ghi các trường này không bắt buộc | Thống nhất P04 hoặc P12 (đặt multiplicity 0..1 hoặc nới P04). P13 theo P12: genre và age_rating NOT NULL, description NOT NULL mặc định chuỗi rỗng; nới thì đổi ba cột sang NULL, không đổi ràng buộc khác (Chờ P12 và P04) |
| P12 | PKG-16-PKG-27 Đề xuất sửa artifact trước dòng P13 (cột giá trị norm_name) | P12 đề xuất thêm cột giá trị norm_name cho chỉ mục unique tên cụm rạp, tên phòng | P13 không thêm cột: P09 F7.3 đã chốt chỉ mục unique theo biểu thức norm_name(name); cột sinh lưu sẵn không đổi tính chất khoá (Đã xử lý: P13 2.0, uq_cinema_name_norm, uq_auditorium_cinema_name_norm) |
| P12 | PKG-19-PKG-32 Đề xuất dòng P13 (bảng staff, administrator) | Ba bảng nhân viên không khớp một dòng Staff có vai trò | Đã gộp thành staff, thêm administrator (Đã áp dụng: P13 2.0) |
| P12 | Lõi Đề xuất dòng P13 (booking, ticket, seat, showtime, staff, hàm chuẩn hoá) | Cột và chỉ mục mà P12 2.0 dùng | Đã áp dụng toàn bộ trừ "kiểm DB có locale tiếng Việt": ghi thành yêu cầu ở F1 và đầu P13-schema.sql, người cài đặt phải tạo CSDL đúng locale (Đã áp dụng: P13 2.0) |
| P08 | Đề xuất dòng P13 (seat, showtime, booking, cinema, staff) | Seat không xoá thật; Showtime không lưu capacity; Booking.customer rỗng được; Cinema tạo cùng bảng giá rỗng; email nhân viên duy nhất xuyên vai trò; ràng buộc duy nhất theo giá trị đã chuẩn hoá | Đã áp dụng toàn bộ (Đã áp dụng: P13 2.0, F9.2) |
| P09 | Đề xuất dòng P13 (hàm chuẩn hoá, chỉ mục, cột) | Xem F9.2 | Đã áp dụng toàn bộ; bổ sung ngoài đề xuất: bỏ điều kiện từng phần của ix_showtime_auditorium_start (báo cáo doanh thu cần cả suất chiếu đã xoá còn vé), P09 F7.12 có thể ghi chú chỉ mục này (Đã áp dụng: P13 2.0) |
| P10 | Đề xuất dòng P13 (tài khoản quản trị viên, Q-271) | DC-LoginService cần nơi đọc tài khoản quản trị viên | Đã thêm bảng administrator một dòng (TBL-22) (Đã áp dụng: P13 2.0) |
| X1, X2 | P13-schema-tests.sql, F9.1 | Bộ ca thử lược đồ mới và năm kịch bản đồng thời đã chạy trên PostgreSQL 16 | X1 đối chiếu F4.5 với P09 F7.3 (EX-16 đến EX-22) và P12 PKG-28; X2 dùng làm nền cho ca tích hợp, thêm ca đo đồng thời T1 đến T6 của P09 F7.9 và ca tên có dấu của T6 (Chờ X1, X2) |
| P04, P12 | Email quản trị viên và email nhân viên (C-31) | Hai bảng khác nhau nên chỉ mục không chặn được cùng một email ở cả administrator và staff | Hoặc ghi ở P04 UC-017 rằng email nhân viên không được trùng email quản trị viên (kiểm ở EX-21), hoặc chấp nhận vì tài khoản quản trị viên do cài đặt tạo và DC-LoginService tra staff trước (Chờ P04, P12) |

## Vấn đề còn mở

1. Đã đóng: project-profile.md mục 3 đã cập nhật CONG_NGHE theo P09 F11.
2. Script DDL đã chạy thật trên PostgreSQL 16 (0 lỗi, 20 bảng) cùng bộ ca thử 207/207 ca đạt và năm kịch bản đồng thời hai phiên (F9.1). Còn lại cần chạy: bộ ca đo đồng thời T1 đến T6 của P09 F7.9 ở quy mô 1.000 giao dịch, đặc biệt khẳng định không có 40P01 và p95 giữ ghế dưới 1,2 giây.
3. Đã đóng (1.x ghi bảng danh mục và nhân viên chỉ có cột tối thiểu): P08 đến P12 bản 2.x đã đặc tả UC-010 đến UC-017 và các cột đã bổ sung; mã TBL không đổi, TBL-11 và TBL-12 gộp vào TBL-08.
4. Khối lượng seat_status tối đa khoảng 73 triệu dòng mỗi năm (F1, Q-138). Đồ án giữ toàn bộ dữ liệu trong một bảng không phân vùng với khoá chính (showtime_id, seat_id) (Q-138). Sản phẩm thật lưu trữ seat_status và seat_hold của suất chiếu cũ hơn 90 ngày sang bảng lưu trữ, giữ ticket, payment_transaction, refund_request lâu hơn theo yêu cầu kế toán, và dọn outbox đã xong sau 30 ngày; phân vùng chỉ cần khi có số liệu thật vì đổi khoá chính và FK ghép.
5. Chuỗi khoá EX-01 theo P09 (Showtime lấy S) chứ không theo P08 F4a (X); nếu ca đo T1 buộc chuyển hạng 1 đến 3 sang khoá tư vấn (pg_advisory_xact_lock) thì F4.5 đổi ba hạng đầu của EX-01, EX-11 đến EX-15, lược đồ không đổi.
6. Mười ba trigger (trong đó tám trigger đổi trạng thái, trg_seat_status_link và bốn trigger bảo vệ cột, đối chiếu, bảng giá) chạy cho mỗi UPDATE cột liên quan của các bảng nóng; chi phí là một hàm PL/pgSQL ngắn mỗi dòng. Chưa đo; ca đo T1 nên chạy cả bản có và không có trigger để biết chi phí.
7. showtime không có FK ép BR-47, BR-48 (F4.2) và ticket.price, seat_status.held_price không có ràng buộc khớp bảng giá; các quy tắc này nằm ở ứng dụng nên cần ca kiểm thử riêng ở X2.
8. DC-PaymentTransaction.gatewayTransactionNo có unique từng phần (Thiết kế, không từ BR) và chỉ được ghi khi báo thành công (P12 RecordFailure không ghi, vì giao dịch khách huỷ hoặc thất bại của VNPay thường mang mã 0); cần xác nhận mã giao dịch của cổng VNPay sandbox là duy nhất cho mỗi giao dịch thành công (P09 Vấn đề còn mở 6).
9. Đã đóng: state machine Showtime đã chốt ở P12 ST-06 (một chiều IN_SCHEDULE sang DELETED); trg_showtime_status chặn khôi phục.
10. Các bất biến chỉ biểu diễn được ở ứng dụng (F4.4: C-13, C-14, C-15, C-16, C-17, C-18, C-24 phần vai trò người giữ ghế, C-33 mốc thay đổi, sức chứa 50 đến 400) cần ca kiểm thử ở X2; CSDL không có ràng buộc tương ứng.
11. Yêu cầu môi trường: CSDL tạo với locale hạ được chữ có dấu tiếng Việt (en_US.utf8 hoặc tương đương). Đổi locale sau khi có dữ liệu làm chỉ mục theo biểu thức norm_email, norm_name sai, phải REINDEX.
