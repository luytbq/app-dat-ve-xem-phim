# P12 - Thiết kế lớp - PKG-11 HttpApi - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P12 |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | 00-Conventions.md (C3, C5, C7); 00-Concurrency.md (M7); project-profile.md (mục 2, 3, 4); P09-architecture.md 2.0 (F4, F5, F6, F7.1, F7.5, F7.8, F7.11, F7.12); P10-design-elements.md 2.0 (F3, F4, F5, F6, bảng cơ chế kiến trúc); P11a-gui 2.0 (ui-standards MSG-01 đến MSG-134, UI-STT 30, 48); P11b-system-interfaces 2.0 (SS-03 IF-04, SS-05 IF-07); _sync-log.md (SY-23, CQ-9); P12-class-design.md 2.0 (lõi, chỉ tham chiếu: DC-BookTicketsService, DC-SeatMapService, DC-CancelTicketService, DC-CheckTicketService, DC-ViewBookingHistoryService, DC-SseFrame, DC-SseStream, DC-PaymentCallbackController); P12-class-design/PKG-05-PKG-10-PKG-20-PKG-23-PKG-29-PKG-31-frontend-and-notification.md 1.0 (IF-41, DC-FetchApiClient, Q-332, Q-333, Q-341, mọi Store); PKG-16-PKG-27-schedule-and-catalog-domain.md (PKG-16); PKG-17-PKG-18-PKG-30-PKG-33-catalog-chain-reports.md (PKG-17, PKG-18, PKG-30); PKG-19-PKG-32-accounts-and-staff.md (PKG-19). P07, P04 không đính kèm: ánh xạ message ở F4 theo tên trách nhiệm đã dẫn trong cột Nguồn của các file P12 đã có (Vấn đề còn mở 2) |
| Phạm vi | PKG-11 HttpApi: 8 REST controller cho UC-001, 003, 004, 005, 007, 008, 009, 010 đến 017 và hai điểm đăng nhập, kết nối đẩy SSE sơ đồ ghế, bộ lọc DC-AuthFilter kiểm mã phiên và mốc truy cập của nhân viên (BR-101) qua DC-AccessCheckService. Phần lõi của PKG-11 trong P12-class-design.md 2.0 chỉ là tên (DC-BookingController, DC-SeatMapStreamController, DC-TicketController, DC-PricingScheduleController, DC-AuthFilter) và hai đối tượng SseFrame, SseStream do PKG-13 trả; mã và tên được giữ nguyên, file này chi tiết hoá. DC-PaymentCallbackController (PKG-12) chỉ dẫn lại |
| Mã Q, ASM cuối đã cấp | Q-351 (dải Q-342 đến Q-351, dùng đủ mười); không có ASM (NGHIEM_NGAT). Mã R dùng R-370 đến R-399; IF-44; ST-19; IF-45, IF-46 không dùng |

Trọng tâm: biến hợp đồng REST giữa trình duyệt (IF-41 IApiClient) và 15 lớp dịch vụ Application thành lớp Go lập trình được, mà PKG-11 không chứa quy tắc nghiệp vụ nào. Năm điểm chốt: (1) một bảng tuyến duy nhất gồm 60 tuyến REST của 8 controller, chốt phương thức, đường dẫn, DTO, quyền, mã lỗi (Q-332), cộng tuyến payment.status do PKG-12 phục vụ; (2) DC-AuthFilter là nơi duy nhất kiểm mã phiên, mọi tuyến không công khai đi qua nó; nhân viên bốn vai trò đi qua DC-AccessCheckService đúng một lần mỗi yêu cầu và danh tính hiện hành (vai trò, cụm rạp) lấy từ dòng Staff, không từ mã phiên (F7.11); (3) DC-HttpErrorMapper là nơi duy nhất đổi lỗi nghiệp vụ của Application thành mã HTTP, mã lỗi và mã MSG, nên controller không có if theo kiểu lỗi; (4) chống gửi trùng nhờ requestId của booking.holdSeats (Q-333) và thao tác đọc booking.getHold để đối chiếu sau khi mất mạng lúc xác nhận thu tiền mặt (Q-341); (5) kết nối SSE sơ đồ ghế có vòng đời riêng (ST-19), giới hạn 10 kết nối mỗi IP, nhịp tim 15 giây, không đọc kiểu của Domain.

Kết quả: 14 phần tử có hành vi (8 controller, DC-AuthFilter, DC-HttpErrorMapper, DC-RequestDecoder, DC-IpConnectionLimiter, DC-SseConnection, IF-44), 18 kiểu phụ trợ, 60 tuyến REST, 30 quan hệ (R-370 đến R-399), 1 state machine (ST-19), 1 class diagram, 10 câu hỏi mở (Q-342 đến Q-351).

## 0. Phạm vi và quy ước

0.1. Phạm vi. 14 phần tử có hành vi, dưới ngưỡng 15 đến 20, nên chạy một lần cho cả package. Lớp ngoài phạm vi mà file này tham chiếu (chỉ tên): DC-BookTicketsService, DC-SeatMapService, DC-SseStream, DC-SseFrame (PKG-13); DC-ViewBookingHistoryService, DC-CancelTicketService, DC-CheckTicketService (PKG-15); DC-ManagePriceListService, DC-ScheduleShowtimesService, DC-ManageAuditoriumsService (PKG-16); DC-BrowseMoviesService, DC-BrowseShowtimesService (PKG-17); DC-ViewCinemaReportService, DC-ViewChainReportService (PKG-18); DC-RegisterAccountService, DC-LoginService, DC-ManageStaffAccountsService, DC-AccessCheckService, DC-StaffAccess (PKG-19); IF-07, DC-SessionClaims, DC-IssuedSession, DC-Role (PKG-26); DC-ManageMoviesService, DC-ManageCinemasService (PKG-30); DC-ActorContext, DC-HolderRef (PKG-28); DC-PaymentCallbackController (PKG-12, phục vụ payment.status).

0.2. Kiểu dữ liệu (theo mục 0.2 của P12 lõi, thêm kiểu mạng). Go net/http với ServeMux theo mẫu "METHOD /đường/dẫn/{tham_số}" (Go 1.22 trở lên). Chữ ký handler luôn là func(w http.ResponseWriter, r *http.Request), viết tắt (w, r) ở sơ đồ. Định dạng dây:

| Giá trị | Biểu diễn JSON và URL | Ghi chú |
|---|---|---|
| Mã số (showtimeId, seatId, ticketId, movieId, cinemaId, auditoriumId, staffId, customerId) | số nguyên JSON; trong đường dẫn là chữ số thập phân | Thiết kế: bên gọi không đoán được holdRef nên mã lần giữ ghế luôn là holdRef (chuỗi), không là SeatHoldId |
| Tiền | số nguyên đồng | Không dấu phẩy động |
| Thời điểm (displayedAt, startTime, saleOpenTime, lastChangedAt, bookedAt) | chuỗi RFC 3339 UTC đủ 6 chữ số micro giây, ví dụ 2026-11-17T08:30:00.123456Z | Giữ nguyên độ chính xác để so bằng với mốc đã lưu (BR-102); trình duyệt gửi lại đúng chuỗi đã nhận, không đổi qua Date |
| Mốc đếm ngược (expiryTime, serverTime, expiresAt của phiên) | số nguyên mili giây từ epoch | Khớp DC-HoldView, DC-SessionInfo của PKG-29, PKG-31 |
| Ngày nghiệp vụ (date, from, to) | chuỗi yyyy-MM-dd theo múi giờ Asia/Ho_Chi_Minh | Trình duyệt đổi dd/MM/yyyy của màn hình sang dạng này |
| requestId | chuỗi UUID 36 ký tự | DC-RequestDecoder kiểm định dạng |
| Rỗng | trường vắng mặt hoặc null; danh sách rỗng là [] | Tuyến trả danh sách không bao giờ trả null |

0.3. Quy ước hiện thực chung của mọi handler (một nơi chốt, các bảng sau không lặp lại):

- Mỗi controller hiện thực IF-44 và trả danh sách DC-RouteSpec; chương trình chính đăng ký tất cả vào một ServeMux. Handler của tuyến không công khai được bọc bởi DC-AuthFilter.Require(allowed, next); handler công khai không bọc.
- Thứ tự trong handler: (1) bộ lọc: kiểm phiên, vai trò, dựng DC-CallerContext; (2) DC-RequestDecoder: giải mã đường dẫn, query, thân JSON thành tham số thuần; (3) một lời gọi service với ctx có deadline; (4) đổi kết quả thành DTO và ghi JSON, hoặc gọi DC-HttpErrorMapper.Write khi có lỗi. Controller không mở giao dịch, không giữ khoá, không giữ trạng thái giữa hai yêu cầu (P09 F7.8); ranh giới giao dịch nằm ở service.
- Thời hạn mỗi yêu cầu: ctx có deadline 14 giây đặt trong DC-AuthFilter.Require (cũng cho tuyến công khai qua DC-RouteSpec.Wrap), nhỏ hơn timeoutMs 15 giây của DC-FetchApiClient để máy chủ trả 503 SYSTEM_BUSY trước khi trình duyệt bỏ yêu cầu. Ngoại lệ: tuyến SSE không có deadline, kết thúc khi trình duyệt đóng hoặc ctx của yêu cầu bị huỷ (Q-348).
- Thân yêu cầu tối đa 262144 byte (256 KiB), chỉ nhận Content-Type application/json, từ chối trường lạ. Sơ đồ phòng chiếu 400 ghế khoảng 40 KiB nên đủ rộng (Q-348).
- Mã phiên gửi trong tiêu đề Authorization: Bearer <token> (khớp DC-SessionStore.authHeader). Cùng nguồn gốc với SPA nên không có CORS và không có cookie, nên không cần chống CSRF (Q-351). Tuyến SSE công khai nên không đòi mã phiên (EventSource không gửi được tiêu đề).
- Lỗi luôn là JSON có dạng DC-ApiErrorBody: code (chuỗi UPPER_SNAKE), messageId (mã MSG, rỗng khi không có), detail (đối tượng tuỳ lỗi: seatIds, reason, holdStatus, violations, field), khớp DC-ApiError của PKG-31. Bảng mã lỗi ở F2b. Thông điệp văn bản không đi qua dây: màn hình tra MSG của P11a.
- Mã thành công: 200 đọc và sửa có kết quả, 201 tạo mới, 204 không có thân. Mọi phản hồi JSON có Cache-Control: no-store trừ tuyến đọc công khai movie.list, movie.get, browse.* (Cache-Control: no-cache để mỗi lần kiểm lại, dữ liệu đổi theo ngày nghiệp vụ).
- Chống gửi trùng (Q-333, Q-341). booking.holdSeats mang requestId do trình duyệt sinh và giữ ở sessionStorage theo suất chiếu tới khi có kết quả; máy chủ không giữ bảng requestId riêng mà để DC-BookTicketsService.HoldSeats trả lại lần giữ ghế đã tạo (replayed = true, HTTP 200 thay vì 201). Trình duyệt mở lại trước tiên gọi booking.activeHold; không có thì gửi lại holdSeats cùng requestId. booking.confirmCash không bao giờ tự gửi lại; sau NetworkError, DC-CounterBookTicketsStore.reconcileCashResult chỉ gọi booking.getHold: holdStatus COMPLETED kèm bookingCode nghĩa là đã bán, rồi counter.findBooking nạp vé để in; ACTIVE thì cho xác nhận lại; trạng thái cuối khác thì kết thúc. counter.confirmCashRefund gọi lặp trả cùng kết quả (service chạy lặp an toàn). Tuyến sửa có displayedAt gửi lại sau khi lần đầu đã ghi sẽ nhận lỗi *_CHANGED (mốc cũ): trình duyệt tải lại danh sách rồi mới thao tác tiếp.
- Phân quyền theo vai trò dùng nhãn: PUB (công khai), CUS (CUSTOMER), CLK (BOX_OFFICE_CLERK), CHK (TICKET_CHECKER), CMG (CINEMA_MANAGER), CHM (CHAIN_MANAGER), ADM (ADMINISTRATOR). Khách và quản trị viên: vai trò lấy từ mã phiên đã kiểm chữ ký (không có mốc để so, F7.11). Bốn vai trò nhân viên: vai trò và cụm rạp lấy từ DC-StaffAccess do DC-AccessCheckService trả, không lấy từ mã phiên.
- Mã cụm rạp, mã khách, mã người giữ ghế không bao giờ nhận từ trình duyệt khi đã có trong phiên: report.cinema, các tuyến /api/cinema/..., /api/counter/..., /api/checking/..., /api/staff/... lấy cụm rạp từ DC-CallerContext.

0.4. Đối chiếu màn hình (P11a) với lỗi: bảng F2b gắn mỗi lỗi với MSG. Hai MSG do trình duyệt tự sinh không đi qua PKG-11: MSG-73 (mất mạng, DC-NetworkError) và MSG-01 (chưa đăng nhập khi chọn ghế). MSG-85 là 401 SESSION_INVALID của DC-AuthFilter; MSG-72 là SYSTEM_BUSY và INTERNAL.

0.5. Lệch với P09 F6 và cách xử lý. P09 F6 cấm Presentation phụ thuộc Domain, nhưng chữ ký công khai của Application dùng kiểu Domain (DC-ShowtimeId, DC-ActorContext, DC-HolderRef, DC-MovieInfo, DC-AuditoriumDraft, *Movie, *Cinema, kiểu lỗi). Controller buộc phải thấy các kiểu này để dịch ra DTO. Thiết kế chọn: PKG-11 được phụ thuộc PKG-27, PKG-28 chỉ để dùng kiểu định danh, kiểu giá trị, kiểu lỗi và getter chỉ đọc có trong chữ ký công khai; không gọi operation nghiệp vụ của Domain (Q-342). Đây là đề xuất sửa P09 F6, P10 F4 và là điểm treo của SY-23; F9 ghi trạng thái.

## F1. Bảng lớp thiết kế

| DC | Tên | Stereotype | PKG | Trách nhiệm | Nguồn AC | Loại | Persistent | Ghi chú thiết kế |
|---|---|---|---|---|---|---|---|---|
| DC-AuthFilter | AuthFilter | «service» | PKG-11 | Kiểm mã phiên, vai trò và mốc truy cập của nhân viên cho một yêu cầu rồi trao DC-CallerContext cho handler | Thiết kế: cơ chế Bảo mật P10 F3 (P10 cơ chế Bảo mật); AC-C-BookTicketsController.checkCustomerLoggedIn | class | Không | Giữ mã P10; package-private. Chỉ nơi này gọi IF-07.VerifySession và DC-AccessCheckService.CheckStaffAccess (P09 F7.11) |
| DC-BookingController | BookingController | «boundary» | PKG-11 | Tiếp nhận các yêu cầu giữ ghế, huỷ giữ ghế, thanh toán và xác nhận thu tiền mặt của UC-005 và chuyển cho DC-BookTicketsService | AC-B-BookTicketsForm, AC-B-CounterBookTicketsForm | class | Không | Giữ mã P10; REST controller khác lớp control phân tích (P10 F3) |
| DC-SeatMapStreamController | SeatMapStreamController | «boundary» | PKG-11 | Phục vụ ảnh chụp sơ đồ ghế và kết nối SSE của một suất chiếu cho mọi trình duyệt, kể cả chưa đăng nhập | P10 cơ chế Cập nhật sơ đồ ghế thời gian thực (SSE) | class | Không | Giữ mã P10; không chạm kiểu Domain, chỉ ghi khung SseFrame (P10 F3) |
| DC-TicketController | TicketController | «boundary» | PKG-11 | Tiếp nhận yêu cầu xem lịch sử đặt vé, huỷ vé của hai kênh và soát vé (UC-007, UC-008, UC-009) | AC-B-CancelTicketForm, AC-B-CounterCancelTicketForm, AC-B-CheckTicketForm, AC-B-ViewBookingHistoryForm | class | Không | Giữ mã P10; ba UC cùng xoay quanh vé nên một lớp (Vấn đề còn mở 4) |
| DC-PricingScheduleController | PricingScheduleController | «boundary» | PKG-11 | Tiếp nhận yêu cầu quản lý bảng giá, suất chiếu và phòng chiếu của quản lý cụm rạp (UC-012, UC-013, UC-014) | AC-B-ManagePriceListForm, AC-B-ScheduleShowtimesForm, AC-B-ManageAuditoriumsForm | class | Không | Giữ mã P10; cùng nhóm cấu hình cụm rạp và cùng tác nhân ACT-04 |
| DC-CatalogController | CatalogController | «boundary» | PKG-11 | Phục vụ các yêu cầu đọc phim, lịch chiếu và thông tin suất chiếu, không đòi đăng nhập trừ lịch chiếu của cụm rạp mình (UC-003, UC-004) | AC-B-BrowseMoviesForm, AC-B-BrowseShowtimesForm | class | Không | Giữ mã P10 |
| DC-AccountController | AccountController | «boundary» | PKG-11 | Tiếp nhận đăng ký khách, hai điểm đăng nhập riêng và quản lý tài khoản nhân viên (UC-001, UC-017) | AC-B-RegisterAccountForm, AC-B-ManageStaffAccountsForm | class | Không | Giữ mã P10; điểm đăng nhập là Q-267, không phải use case |
| DC-ReportController | ReportController | «boundary» | PKG-11 | Tiếp nhận yêu cầu xem báo cáo doanh thu và tỉ lệ lấp đầy của cụm rạp và của chuỗi (UC-015, UC-016) | AC-B-ViewCinemaReportForm, AC-B-ViewChainReportForm | class | Không | Giữ mã P10 |
| DC-ChainController | ChainController | «boundary» | PKG-11 | Tiếp nhận yêu cầu quản lý danh mục phim và cụm rạp của quản lý chuỗi (UC-010, UC-011) | AC-B-ManageMoviesForm, AC-B-ManageCinemasForm | class | Không | Giữ mã P10 |
| DC-HttpErrorMapper | HttpErrorMapper | «utility» | PKG-11 | Đổi một lỗi của Application thành mã HTTP, mã lỗi và mã MSG theo bảng F2b rồi ghi phản hồi lỗi | Thiết kế: một nơi duy nhất chứa bảng lỗi để 8 controller không lặp if theo kiểu lỗi | class | Không | Package-private; hàm thuần theo lỗi và phạm vi (ErrorScope) |
| DC-RequestDecoder | RequestDecoder | «utility» | PKG-11 | Giải mã tham số đường dẫn, query và thân JSON của một yêu cầu thành giá trị có kiểu và ghi thân JSON phản hồi | Thiết kế: tránh lặp giải mã, giới hạn kích thước và kiểm định dạng ở 60 handler | class | Không | Package-private; không phụ thuộc Domain, chỉ trả kiểu nguyên thuỷ và time.Time |
| DC-IpConnectionLimiter | IpConnectionLimiter | «service» | PKG-11 | Đếm và giới hạn số kết nối SSE đang mở của mỗi địa chỉ IP trên bản backend này | P10 cơ chế SSE (P09 F7.5: khoảng 10 kết nối mỗi IP) | class | Không | Giữ trong bộ nhớ vì giới hạn theo bản backend, mất khi khởi động lại (Q-349) |
| DC-SseConnection | SseConnection | «service» | PKG-11 | Ghi các khung SSE và nhịp tim ra một kết nối và kiểm soát vòng đời kết nối đó | Thiết kế: tách vòng đời kết nối (ST-19) khỏi controller để thử được mốc 15 giây | class | Không | Một thể hiện mỗi kết nối; có state machine ST-19; nhận hàm tạo ticker qua constructor để X2 thử nhịp tim |
| IF-44 | IRouteGroup | «interface» | PKG-11 | Cho chương trình chính lấy danh sách tuyến của một controller để đăng ký vào bộ định tuyến | Thiết kế: để một ca thử liệt kê mọi tuyến và so với DC-FetchApiClient.routeTable | interface | Không | Interface mới theo Bước 1.5, hiện thực bởi 8 controller; xem Đề xuất sửa P10 |

Câu trách nhiệm của các controller dùng "và" chỉ để nối các tên thao tác cùng một lý do thay đổi (hợp đồng REST của nhóm chức năng), như P10 F4 đã chốt.

### F1b. Kiểu phụ trợ

| DC | Loại | PKG | Thành phần hoặc giá trị | Dùng trong chữ ký |
|---|---|---|---|---|
| DC-RouteSpec | value object | PKG-11 | name (string, tuỳ chọn tên tuyến logic), method (string), pattern (string, mẫu ServeMux), allowedRoles ([]Role, rỗng nghĩa là công khai), handler (http.HandlerFunc), Wrap(h): bọc deadline 14 giây | IF-44.Routes, DC-AuthFilter.Require |
| DC-CallerContext | value object | PKG-11 | claims (SessionClaims), role (Role hiện hành), actor (ActorContext, hợp lệ khi vai trò là CUSTOMER, BOX_OFFICE_CLERK, TICKET_CHECKER), access (*StaffAccess, nil với khách và quản trị viên), HolderRef() (HolderRef), CustomerId() (CustomerId), CinemaId() (CinemaId) | DC-AuthFilter.authenticate, mọi handler không công khai |
| DC-ApiErrorBody | value object | PKG-11 | code (string), messageId (string), detail (map[string]any) | DC-HttpErrorMapper.Classify |
| DC-ErrorScope | enumeration | PKG-11 | BOOKING, TICKET, SCHEDULE, CATALOG, ACCOUNT, REPORT, CHAIN: chọn MSG khi cùng một lỗi có hai thông điệp (ví dụ SHOWTIME_CHANGED: MSG-12 ở BOOKING, MSG-68 ở SCHEDULE) | DC-HttpErrorMapper |
| DC-SseConnectionState | enumeration | PKG-11 | OPENING, STREAMING, CLOSED (ST-19) | DC-SseConnection.state |
| DC-SessionDto | value object | PKG-11 | token, subjectKind (CUSTOMER, STAFF, ADMIN), role, cinemaId (số hoặc null), displayName, expiresAt (ms epoch); khớp DC-SessionInfo | auth.customerLogin, auth.staffLogin |
| DC-HoldDto | value object | PKG-11 | holdRef, holdStatus (ACTIVE, COMPLETED, CANCELLED, EXPIRED, PAYMENT_FAILED), expiryTime (ms), serverTime (ms), seats ([]{seatId, label, seatType, price}), total, replayed, bookingCode (null khi chưa bán); khớp DC-HoldView của PKG-29 cộng holdStatus, bookingCode (Q-341) | booking.holdSeats, booking.activeHold, booking.getHold |
| DC-BookingDto | value object | PKG-11 | bookingCode, tickets ([]{ticketId, ticketCode, seatLabel, seatType, price, status, refundAmount, refundStatus}); ticketCode cũng là nội dung mã QR (Q-340) | booking.confirmCash, history.get, counter.findBooking |
| DC-CancelResultDto | value object | PKG-11 | ticketId, refundAmount, refundType (TICKET_GATEWAY hoặc TICKET_CASH), refundStatus; khớp DC-CancelResultView | ticket.cancel, counter.confirmCashRefund |
| DC-ShowtimeDto | value object | PKG-11 | showtimeId, movieId, movieTitle, format, cinemaId, cinemaName, province, auditoriumName, auditoriumType, startsAt, endsAt, saleOpenAt, status, lastChangedAt, maxSeatsPerHold (Q-339); khớp DC-ShowtimeView | showtime.get, browse.*, showtime.ownCinema, ticket.startChecking |
| DC-ShowtimeListItemDto | value object | PKG-11 | id, movieTitle, movieFormat, auditoriumName, auditoriumType, startTime, endTime, saleOpenTime, lastChangedAt | showtime.list, showtime.create, showtime.save |
| DC-SeatMapDto | value object | PKG-11 | showtimeId, showtimeChangedAt, cursor, seats ([]{seatId, state, eventSeq}); phản chiếu DC-SeatSnapshot | seatmap.snapshot |
| DC-MovieDto | value object | PKG-11 | movieId, movieCode, title, genre, durationMinutes, ageRating, releaseDate, endOfRunDate, description, trailer, releaseFormats, lastChangedAt (chỉ tuyến quản lý) | movie.get, movie.manage*, movie.create, movie.save |
| DC-CinemaDto | value object | PKG-11 | id, name, province, address, lastChangedAt | cinema.* |
| DC-AuditoriumDto | value object | PKG-11 | id, name, auditoriumType, formats, capacity, seatCountByType, lastChangedAt, seats ([]{id, rowCode, seatNumber, seatType}, chỉ auditorium.get) | auditorium.* |
| DC-PriceEntryDto | value object | PKG-11 | combo, ticketPrice, lastChangedAt (rỗng khi chưa có mục giá) | price.list, price.save |
| DC-StaffDto | value object | PKG-11 | id, email, fullName, role, cinemaId, cinemaName, status, lastChangedAt | staff.* |

## F2. Bảng operation

Chữ ký theo Go, mục 0.2 của P12 lõi. Mỗi handler là một operation public ứng với đúng một tuyến; mọi handler có dạng (w http.ResponseWriter, r *http.Request) và không trả giá trị. Lỗi ghi qua DC-HttpErrorMapper.Write.

### F2a. Bảng tuyến REST (chốt Q-332)

Nhãn quyền: PUB, CUS, CLK, CHK, CMG, CHM, ADM theo mục 0.3. Tuyến Tạm là tuyến phụ thuộc operation mới đề xuất ở lõi hoặc package khác (Đề xuất sửa artifact trước).

| Tuyến logic | Phương thức | Đường dẫn | Controller.handler | Quyền | Vào | Ra | Service gọi | Mã lỗi | Nguồn |
|---|---|---|---|---|---|---|---|---|---|
| booking.holdSeats | POST | /api/showtimes/{showtimeId}/holds | DC-BookingController.HoldSeats | CUS, CLK | body: seatIds[], requestId (UUID), displayedAt | 201 mới hoặc 200 replayed: DC-HoldDto | BookTicketsService.HoldSeats | SHOWTIME_NOT_OPEN, SHOWTIME_CHANGED, SEAT_SELECTION_INVALID, HOLDER_BUSY, SEAT_UNAVAILABLE, CHANNEL_MISMATCH, SESSION_INVALID, SYSTEM_BUSY | UC-005 bước 7 |
| booking.activeHold | GET | /api/holds/active | DC-BookingController.GetActiveHold | CUS, CLK | - | 200 DC-HoldDto hoặc 204 khi không có | BookTicketsService.FindActiveHold (Tạm) | SYSTEM_BUSY | UC-005 luồng 5b, 7c; BR-04 |
| booking.getHold | GET | /api/holds/{holdRef} | DC-BookingController.GetHold | CUS, CLK | - | 200 DC-HoldDto (holdStatus, bookingCode khi đã bán) | BookTicketsService.GetHold | NOT_FOUND, SYSTEM_BUSY | UC-005; Q-341 |
| booking.cancelHold | DELETE | /api/holds/{holdRef} | DC-BookingController.CancelHold | CUS, CLK | - | 204 | BookTicketsService.CancelHold | HOLD_NOT_ACTIVE, NOT_FOUND, SYSTEM_BUSY | UC-005 luồng *a |
| payment.start | POST | /api/holds/{holdRef}/payment | DC-BookingController.StartOnlinePayment | CUS | - | 200 {transactionCode, paymentUrl} | BookTicketsService.StartOnlinePayment | HOLD_NOT_ACTIVE, NOT_FOUND, GATEWAY_CONFIG | UC-005 bước 10 |
| booking.confirmCash | POST | /api/holds/{holdRef}/cash-confirmation | DC-BookingController.ConfirmCashReceived | CLK | - | 200 DC-BookingDto | BookTicketsService.ConfirmCashReceived | HOLD_NOT_ACTIVE, NOT_FOUND, SYSTEM_BUSY, SESSION_INVALID | UC-005 bước 9a1 |
| seatmap.snapshot | GET | /api/showtimes/{showtimeId}/seat-map | DC-SeatMapStreamController.GetSeatMap | PUB | - | 200 DC-SeatMapDto | SeatMapService.GetSnapshot | NOT_FOUND, SYSTEM_BUSY | UC-005 bước 3; P09 F7.5 điểm 4 |
| seatmap.stream | GET | /api/showtimes/{showtimeId}/seat-events | DC-SeatMapStreamController.StreamSeatEvents | PUB | query: after (EventId, mặc định 0) hoặc header Last-Event-ID | 200 text/event-stream: khung seat, reload, nhịp tim | SeatMapService.OpenStream | SSE_LIMIT, HUB_UNAVAILABLE, NOT_FOUND | UC-005 bước 3; P09 F7.5 |
| history.list | GET | /api/me/bookings | DC-TicketController.ListBookingHistory | CUS | - | 200 {bookings[{bookingCode,ticketCount,movieTitle,cinemaName,startTime,bookedAt}]} | ViewBookingHistoryService.ListHistory | SYSTEM_BUSY | UC-007 |
| history.get | GET | /api/me/bookings/{bookingCode} | DC-TicketController.GetBookingTickets | CUS | - | 200 DC-BookingDto | ViewBookingHistoryService.FindBookingTickets | NOT_FOUND, BOOKING_NOT_OWNED | UC-007 |
| ticket.cancel | POST | /api/tickets/{ticketId}/cancellation | DC-TicketController.CancelOnlineTicket | CUS | - | 200 DC-CancelResultDto | CancelTicketService.CancelOnlineTicket | TICKET_STATE, CANCEL_DEADLINE, CHANNEL_MISMATCH, REFUND_LIMIT, SYSTEM_BUSY | UC-008 khách |
| counter.findBooking | GET | /api/counter/bookings/{bookingCode} | DC-TicketController.FindCounterBooking | CLK | - | 200 DC-BookingDto | CancelTicketService.FindBooking | NOT_FOUND, CHANNEL_MISMATCH | UC-008 quầy; Q-341 |
| counter.cancelPrepare | GET | /api/counter/tickets/{ticketId}/cash-refund | DC-TicketController.PrepareCashRefund | CLK | - | 200 {ticketId, amount, refundType=TICKET_CASH} | CancelTicketService.PrepareCashRefund (Tạm) | TICKET_STATE, CANCEL_DEADLINE, CHANNEL_MISMATCH, NOT_FOUND | UC-008 // requestCancellation |
| counter.confirmCashRefund | POST | /api/counter/tickets/{ticketId}/cash-refund | DC-TicketController.ConfirmCashRefund | CLK | - | 200 DC-CancelResultDto (gọi lặp trả cùng kết quả) | CancelTicketService.ConfirmCashRefund | TICKET_STATE, CANCEL_DEADLINE, CHANNEL_MISMATCH, SYSTEM_BUSY | UC-008 // confirmCashRefund |
| ticket.startChecking | GET | /api/checking/showtimes/{showtimeId} | DC-TicketController.StartChecking | CHK | - | 200 DC-ShowtimeDto | CheckTicketService.StartChecking | NOT_FOUND, CHANNEL_MISMATCH | UC-009 // startChecking |
| ticket.check | POST | /api/checking/showtimes/{showtimeId}/scans | DC-TicketController.CheckTicket | CHK | body: qrText | 200 {outcome, bookingCode, seatLabel, seatType} | CheckTicketService.CheckTicket | NOT_FOUND, SYSTEM_BUSY | UC-009 // checkTicket |
| price.list | GET | /api/cinema/price-entries | DC-PricingScheduleController.ListPriceEntries | CMG | - | 200 {cinemaId, entries[DC-PriceEntryDto]} | ManagePriceListService.GetPriceList | NOT_FOUND | UC-013 |
| price.save | PUT | /api/cinema/price-entries | DC-PricingScheduleController.SavePriceEntry | CMG | body: combo{auditoriumType,movieFormat,seatType,timeBand}, ticketPrice, displayedAt | 200 DC-PriceEntryDto | ManagePriceListService.SubmitPriceEntry | TICKET_PRICE_INVALID, PRICE_ENTRY_CHANGED, SYSTEM_BUSY | UC-013 |
| price.remove | POST | /api/cinema/price-entries/removal | DC-PricingScheduleController.RemovePriceEntry | CMG | body: combo, displayedAt | 204 | ManagePriceListService.SubmitPriceEntryRemoval | PRICE_ENTRY_CHANGED, PRICE_ENTRY_IN_USE, SYSTEM_BUSY | UC-013 |
| showtime.list | GET | /api/cinema/showtimes | DC-PricingScheduleController.ListShowtimes | CMG | - | 200 {showtimes[DC-ShowtimeListItemDto]} | ScheduleShowtimesService.ListShowtimes | - | UC-014 |
| showtime.formData | GET | /api/cinema/showtimes/form-data | DC-PricingScheduleController.GetScheduleFormData | CMG | - | 200 {auditoriums[], movies[]} | ScheduleShowtimesService.StartScheduling | - | UC-014 // startScheduling |
| showtime.editForm | GET | /api/cinema/showtimes/{showtimeId}/edit | DC-PricingScheduleController.GetShowtimeEditForm | CMG | - | 200 {showtime, movieId, auditoriumId, auditoriums[], movies[]} | ScheduleShowtimesService.PrepareShowtimeEdit | SHOWTIME_STARTED, SHOWTIME_IN_USE, NOT_FOUND, NOT_OWN_CINEMA | UC-014 // prepareShowtimeEdit |
| showtime.create | POST | /api/cinema/showtimes | DC-PricingScheduleController.CreateShowtime | CMG | body: movieId, movieFormat, auditoriumId, startTime, saleOpenTime | 201 DC-ShowtimeListItemDto | ScheduleShowtimesService.CreateShowtime | NOT_OWN_CINEMA, FORMAT_NOT_RELEASED, FORMAT_NOT_SUPPORTED, PRICE_NOT_COVERED, OUTSIDE_RUN_PERIOD, SHOWTIME_STARTED, SALE_OPEN_ORDER, AUDITORIUM_GONE, ROOM_GAP, SYSTEM_BUSY | UC-014 |
| showtime.save | PUT | /api/cinema/showtimes/{showtimeId} | DC-PricingScheduleController.UpdateShowtime | CMG | body: như tạo cộng displayedAt | 200 DC-ShowtimeListItemDto | ScheduleShowtimesService.UpdateShowtime | SHOWTIME_CHANGED, SHOWTIME_STARTED, SHOWTIME_IN_USE, ROOM_CHANGE_NOT_ALLOWED, và các lỗi của showtime.create | UC-014 |
| showtime.delete | POST | /api/cinema/showtimes/{showtimeId}/deletion | DC-PricingScheduleController.DeleteShowtime | CMG | body: displayedAt | 204 | ScheduleShowtimesService.DeleteShowtime | SHOWTIME_CHANGED, SHOWTIME_STARTED, SHOWTIME_IN_USE, NOT_OWN_CINEMA | UC-014 |
| auditorium.list | GET | /api/cinema/auditoriums | DC-PricingScheduleController.ListAuditoriums | CMG | - | 200 {auditoriums[DC-AuditoriumDto]} | ManageAuditoriumsService.ListAuditoriums | - | UC-012 |
| auditorium.get | GET | /api/cinema/auditoriums/{auditoriumId} | DC-PricingScheduleController.GetAuditorium | CMG | - | 200 DC-AuditoriumDto kèm seats[] | ManageAuditoriumsService.SelectAuditorium | NOT_FOUND, NOT_OWN_CINEMA | UC-012 |
| auditorium.create | POST | /api/cinema/auditoriums | DC-PricingScheduleController.CreateAuditorium | CMG | body: name, auditoriumType, formats[], seats[{rowCode,seatNumber,seatType}] | 201 DC-AuditoriumDto | ManageAuditoriumsService.AddAuditorium | FIELD_INVALID, CAPACITY_OUT_OF_RANGE, AUDITORIUM_NAME_TAKEN, SYSTEM_BUSY | UC-012 |
| auditorium.save | PUT | /api/cinema/auditoriums/{auditoriumId} | DC-PricingScheduleController.UpdateAuditorium | CMG | body: như tạo cộng displayedAt | 200 DC-AuditoriumDto | ManageAuditoriumsService.EditAuditorium | FIELD_INVALID, CAPACITY_OUT_OF_RANGE, NOT_OWN_CINEMA, AUDITORIUM_GONE, AUDITORIUM_CHANGED, AUDITORIUM_NAME_TAKEN, AUDITORIUM_BLOCKED, PRICE_NOT_COVERED | UC-012 |
| auditorium.remove | POST | /api/cinema/auditoriums/{auditoriumId}/removal | DC-PricingScheduleController.RemoveAuditorium | CMG | - | 204 | ManageAuditoriumsService.RemoveAuditorium | AUDITORIUM_GONE, NOT_OWN_CINEMA, AUDITORIUM_HAS_SCHEDULE | UC-012 |
| movie.list | GET | /api/movies | DC-CatalogController.ListMovies | PUB | - | 200 {nowShowing[], comingSoon[]} | BrowseMoviesService.ListMovies | SYSTEM_BUSY | UC-003 |
| movie.get | GET | /api/movies/{movieId} | DC-CatalogController.GetMovie | PUB | - | 200 DC-MovieDto (chi tiết) | BrowseMoviesService.GetMovieDetails | NOT_FOUND | UC-003 |
| browse.movieChoices | GET | /api/browse/movies | DC-CatalogController.ListMovieChoices | PUB | - | 200 {movies[{movieId,title}]} | BrowseShowtimesService.ListMoviesForBrowsing | SYSTEM_BUSY | UC-004 |
| browse.cinemaChoices | GET | /api/browse/cinemas | DC-CatalogController.ListCinemaChoices | PUB | - | 200 {cinemas[{cinemaId,name,province}]} | BrowseShowtimesService.ListCinemasForBrowsing | SYSTEM_BUSY | UC-004 |
| browse.showtimesByMovie | GET | /api/browse/movies/{movieId}/showtimes | DC-CatalogController.FindShowtimesByMovie | PUB | query: province, date (yyyy-MM-dd), auditoriumType, format (đều tuỳ chọn) | 200 {showtimes[DC-ShowtimeDto]} | BrowseShowtimesService.FindShowtimesByMovie | FIELD_INVALID | UC-004 |
| browse.showtimesByCinema | GET | /api/browse/cinemas/{cinemaId}/showtimes | DC-CatalogController.FindShowtimesByCinema | PUB | query như trên | 200 {showtimes[DC-ShowtimeDto]} | BrowseShowtimesService.FindShowtimesByCinema | FIELD_INVALID | UC-004; Q-335 |
| showtime.ownCinema | GET | /api/staff/cinema/showtimes | DC-CatalogController.FindOwnCinemaShowtimes | CLK, CHK | query: date (tuỳ chọn) | 200 {showtimes[DC-ShowtimeDto]} | BrowseShowtimesService.FindShowtimesByCinema (cinemaId từ DC-CallerContext) | SYSTEM_BUSY | Q-335 |
| showtime.get | GET | /api/showtimes/{showtimeId} | DC-CatalogController.GetShowtime | PUB | - | 200 DC-ShowtimeDto | BrowseShowtimesService.GetShowtime (Tạm) | NOT_FOUND | UC-005 bước 1 |
| auth.customerLogin | POST | /api/auth/customer-login | DC-AccountController.LoginCustomer | PUB | body: login (email hoặc số điện thoại), password | 200 DC-SessionDto | LoginService.LoginCustomer | LOGIN_FAILED, SYSTEM_BUSY | NFR-01; Q-267 |
| auth.staffLogin | POST | /api/auth/staff-login | DC-AccountController.LoginStaff | PUB | body: email, password | 200 DC-SessionDto | LoginService.LoginStaff | LOGIN_FAILED, STAFF_LOCKED, SYSTEM_BUSY | NFR-02, NFR-03; Q-267 |
| account.register | POST | /api/accounts | DC-AccountController.RegisterAccount | PUB | body: email, phoneNumber, password | 201 {customerId} | RegisterAccountService.RegisterAccount | REGISTRATION_DATA_INVALID, DUPLICATE_CUSTOMER, SYSTEM_BUSY | UC-001 |
| staff.list | GET | /api/admin/staff | DC-AccountController.ListStaff | ADM | - | 200 {staff[DC-StaffDto]} | ManageStaffAccountsService.ListStaffAccounts | SYSTEM_BUSY | UC-017 |
| staff.choices | GET | /api/admin/staff/choices | DC-AccountController.GetStaffChoices | ADM | - | 200 {roles[], cinemas[{id,name}]} | ManageStaffAccountsService.OpenStaffCreation | SYSTEM_BUSY | UC-017 // startStaffCreation |
| staff.get | GET | /api/admin/staff/{staffId} | DC-AccountController.GetStaff | ADM | - | 200 {staff: DC-StaffDto, choices} | ManageStaffAccountsService.OpenStaffForUpdate | NOT_FOUND | UC-017 // openStaffForUpdate |
| staff.create | POST | /api/admin/staff | DC-AccountController.CreateStaff | ADM | body: email, fullName, password, role, cinemaId|null | 201 DC-StaffDto | ManageStaffAccountsService.CreateStaffAccount | STAFF_DATA_INVALID, DUPLICATE_STAFF_EMAIL, NOT_FOUND | UC-017 |
| staff.updateAccess | PUT | /api/admin/staff/{staffId}/access | DC-AccountController.UpdateStaffAccess | ADM | body: role, cinemaId|null, displayedAt | 200 DC-StaffDto | ManageStaffAccountsService.UpdateStaffAccess | STAFF_DATA_INVALID, STALE_STAFF, NOT_FOUND | UC-017 |
| staff.lock | POST | /api/admin/staff/{staffId}/lock | DC-AccountController.LockStaff | ADM | body: displayedAt | 204 | ManageStaffAccountsService.LockStaffAccount | STAFF_STATUS_UNCHANGED, STALE_STAFF, NOT_FOUND | UC-017 |
| staff.unlock | POST | /api/admin/staff/{staffId}/unlock | DC-AccountController.UnlockStaff | ADM | body: displayedAt | 204 | ManageStaffAccountsService.UnlockStaffAccount | STAFF_STATUS_UNCHANGED, STALE_STAFF, NOT_FOUND | UC-017 |
| staff.rename | PUT | /api/admin/staff/{staffId}/name | DC-AccountController.RenameStaff | ADM | body: fullName, displayedAt | 204 | ManageStaffAccountsService.RenameStaffAccount | STAFF_DATA_INVALID, STALE_STAFF, NOT_FOUND | UC-017 |
| staff.resetPassword | POST | /api/admin/staff/{staffId}/password-reset | DC-AccountController.ResetStaffPassword | ADM | body: newPassword, displayedAt | 204 | ManageStaffAccountsService.ResetStaffAccountPassword | STAFF_DATA_INVALID, STALE_STAFF, NOT_FOUND | UC-017 |
| report.cinema | GET | /api/cinema/report | DC-ReportController.GetCinemaReport | CMG | query: groupBy, from, to (yyyy-MM-dd); cụm rạp lấy từ phiên | 200 {groupBy, groups[GroupFigures]}, rỗng thì groups=[] | ViewCinemaReportService.ViewCinemaReport | INVALID_PERIOD, SYSTEM_BUSY | UC-015 |
| report.chain | GET | /api/chain/report | DC-ReportController.GetChainReport | CHM | query: groupBy, from, to | 200 {groupBy, entries[{overall, cinemas[]}]} | ViewChainReportService.ViewChainReport | INVALID_PERIOD, SYSTEM_BUSY | UC-016 |
| movie.manageList | GET | /api/chain/movies | DC-ChainController.ListManagedMovies | CHM | - | 200 {movies[DC-MovieDto]} | ManageMoviesService.ListMovies | SYSTEM_BUSY | UC-010 |
| movie.manageGet | GET | /api/chain/movies/{movieId} | DC-ChainController.GetManagedMovie | CHM | - | 200 DC-MovieDto | ManageMoviesService.GetMovieForEdit | NOT_FOUND | UC-010 |
| movie.create | POST | /api/chain/movies | DC-ChainController.CreateMovie | CHM | body: title, durationMinutes, releaseDate, endOfRunDate, genre, ageRating, description, trailer, releaseFormats[] | 201 DC-MovieDto | ManageMoviesService.AddMovie | INVALID_INFO, SYSTEM_BUSY | UC-010 |
| movie.save | PUT | /api/chain/movies/{movieId} | DC-ChainController.UpdateMovie | CHM | body: như tạo cộng displayedAt | 200 DC-MovieDto | ManageMoviesService.SaveMovieChanges | INVALID_INFO, CHANGED_SINCE_DISPLAYED, NOT_FOUND | UC-010 |
| cinema.list | GET | /api/chain/cinemas | DC-ChainController.ListManagedCinemas | CHM | - | 200 {cinemas[DC-CinemaDto]} | ManageCinemasService.ListCinemas | SYSTEM_BUSY | UC-011 |
| cinema.get | GET | /api/chain/cinemas/{cinemaId} | DC-ChainController.GetManagedCinema | CHM | - | 200 DC-CinemaDto | ManageCinemasService.GetCinemaForEdit | NOT_FOUND | UC-011 |
| cinema.create | POST | /api/chain/cinemas | DC-ChainController.CreateCinema | CHM | body: name, province, address | 201 DC-CinemaDto | ManageCinemasService.AddCinema | INVALID_INFO, CINEMA_NAME_TAKEN | UC-011 |
| cinema.save | PUT | /api/chain/cinemas/{cinemaId} | DC-ChainController.UpdateCinema | CHM | body: như tạo cộng displayedAt | 200 DC-CinemaDto | ManageCinemasService.SaveCinemaChanges | INVALID_INFO, CINEMA_NAME_TAKEN, CHANGED_SINCE_DISPLAYED, NOT_FOUND | UC-011 |

Tuyến thứ 61 do PKG-12 phục vụ, không nằm trong PKG-11: payment.status, GET /api/payments/status?holdRef=..., công khai, DC-PaymentCallbackController.HandlePaymentStatus, trả PaymentStatusView (holdRef, holdStatus, paymentStatus, bookingCode). Có trong bảng routeTable của DC-FetchApiClient cùng 60 tuyến trên. Hai tuyến vào của cổng thanh toán (IPN, địa chỉ trả về) do PKG-12 và không đi qua IF-41.

### F2b. Bảng mã lỗi

| Mã lỗi (code) | HTTP | Thông điệp (messageId) | Điều kiện | Nguồn lỗi |
|---|---|---|---|---|
| REQUEST_INVALID | 400 | - | Thân yêu cầu sai cú pháp JSON, trường lạ, mã số hoặc thời điểm sai định dạng, quá 256 KiB, requestId không phải UUID | DC-RequestDecoder |
| SESSION_INVALID | 401 | MSG-85 | Thiếu mã phiên, sai chữ ký, hết hạn, hoặc nhân viên bị khoá, đổi quyền (StaffAccessRevokedError, StaffAccessChangedError) | DC-AuthFilter, IF-07, DC-StaffAccessRevokedError, DC-StaffAccessChangedError |
| LOGIN_FAILED | 401 | MSG-02 (khách), MSG-86 (nhân viên) | Thông tin đăng nhập sai, một thông điệp chung | DC-LoginFailedError |
| FORBIDDEN_ROLE | 403 | - | Vai trò hiện hành không thuộc danh sách của tuyến (IF-07.CheckRole) | DC-AuthFilter |
| STAFF_LOCKED | 403 | MSG-87 | Tài khoản nhân viên Bị khoá, chỉ báo sau khi mật khẩu đúng | DC-StaffLockedError |
| CHANNEL_MISMATCH | 403 | MSG-07, MSG-32, MSG-33, MSG-34 (theo detail.reason) | Sai kênh hoặc sai cụm rạp của nhân viên (BR-02, BR-17) | DC-ChannelMismatchError |
| BOOKING_NOT_OWNED | 403 | MSG-94 | Lần đặt không thuộc khách (BR-94) | DC-BookingNotOwnedError |
| NOT_OWN_CINEMA | 403 | MSG-58, MSG-113 | Đối tượng không thuộc cụm rạp của quản lý (BR-46, BR-135) | DC-NotOwnCinemaError |
| NOT_FOUND | 404 | MSG-31 (mã đặt vé), MSG-12 | Không có dòng theo khoá, hoặc holdRef không của người gọi (Q-147) | DC-NotFoundError |
| SHOWTIME_NOT_OPEN | 409 | MSG-84 | Suất chiếu chưa mở bán, đã bắt đầu hoặc đã xoá | DC-ShowtimeNotOpenError |
| SHOWTIME_CHANGED | 409 | MSG-12 (đặt vé), MSG-68 (lập lịch) | Suất chiếu đã sửa hoặc xoá từ lúc hiển thị (BR-54, BR-60) | DC-ShowtimeChangedError |
| HOLDER_BUSY | 409 | MSG-09 | Người giữ ghế còn lần giữ ghế chưa kết thúc (BR-04) | DC-HolderBusyError |
| SEAT_UNAVAILABLE | 409 | MSG-11 (detail.seatIds), MSG-82 khi BEING_RELEASED | Ghế vừa có người giữ hoặc mua, hoặc đang được trả về trống | DC-SeatUnavailableError |
| HOLD_NOT_ACTIVE | 409 | MSG-14 (khách), MSG-29 (quầy), MSG-20 (xác nhận thu tiền quá hạn); detail.holdStatus | Lần giữ ghế không còn Đang giữ (BR-86) | DC-HoldNotActiveError |
| PRICE_UNDEFINED | 409 | MSG-13 | Không xác định được giá của ghế (BR-72) | DC-PriceNotCoveredError khi gọi từ booking.holdSeats |
| TICKET_STATE | 409 | MSG-36 (đã huỷ), MSG-37 (đã dùng) | Vé không ở trạng thái cho phép huỷ (BR-21, BR-30) | DC-TicketStateError |
| CANCEL_DEADLINE | 409 | MSG-35 | Cách giờ chiếu chưa tới 2 tiếng (BR-18, BR-32) | DC-CancelDeadlineError |
| REFUND_LIMIT | 409 | MSG-41 | Tổng hoàn vượt số đã thanh toán (BR-26) | DC-RefundLimitError |
| SHOWTIME_IN_USE | 409 | MSG-66 | Suất chiếu còn giữ ghế hoặc vé chưa huỷ (BR-53) | DC-ShowtimeInUseError |
| ROOM_CHANGE_NOT_ALLOWED | 409 | MSG-83 | Đổi phòng của suất đã từng có vé (BR-92) | DC-RoomChangeNotAllowedError |
| AUDITORIUM_GONE | 409 | MSG-108 | Phòng chiếu không còn | DC-AuditoriumGoneError |
| AUDITORIUM_CHANGED | 409 | MSG-108 | Phòng chiếu đã sửa từ lúc hiển thị (BR-146) | DC-AuditoriumChangedError |
| AUDITORIUM_NAME_TAKEN | 409 | MSG-105 | Tên phòng đã dùng trong cụm rạp (BR-145) | DC-AuditoriumNameTakenError |
| AUDITORIUM_BLOCKED | 409 | MSG-106 | Có suất chiếu đã mở bán chưa kết thúc (BR-87) | DC-AuditoriumBlockedError |
| AUDITORIUM_HAS_SCHEDULE | 409 | MSG-112 | Phòng đã từng có suất chiếu (BR-147) | DC-AuditoriumHasScheduleError |
| PRICE_ENTRY_CHANGED | 409 | MSG-52 | Mục giá đã đổi từ lúc hiển thị (BR-63) | DC-PriceEntryChangedError |
| PRICE_ENTRY_IN_USE | 409 | MSG-53 | Còn suất chiếu chưa bắt đầu dùng mục giá (BR-64) | DC-PriceEntryInUseError |
| CHANGED_SINCE_DISPLAYED | 409 | MSG-99 (phim), MSG-102 (cụm rạp) | Phim hoặc cụm rạp đã sửa từ lúc hiển thị (BR-138, BR-142) | DC-ChangedSinceDisplayedError (PKG-30) |
| CINEMA_NAME_TAKEN | 409 | MSG-101 | Tên cụm rạp đã dùng (BR-141) | DC-CinemaNameTakenError |
| STALE_STAFF | 409 | MSG-120 | Tài khoản đã đổi từ lúc hiển thị (BR-102) | DC-StaleStaffError |
| STAFF_STATUS_UNCHANGED | 409 | MSG-124 (đã khoá), MSG-127 (đang hoạt động) | Khoá khi đã khoá, mở khoá khi đang hoạt động | DC-StaffStatusUnchangedError |
| DUPLICATE_STAFF_EMAIL | 409 | MSG-119 | Email đã thuộc nhân viên khác (BR-95) | DC-DuplicateStaffEmailError |
| DUPLICATE_CUSTOMER | 409 | MSG-90 | Email hoặc số điện thoại đã thuộc khách khác (BR-98) | DC-DuplicateCustomerError |
| SEAT_SELECTION_INVALID | 422 | MSG-10 (TOO_MANY); detail.reason | Chọn rỗng, quá 8 ghế, trùng ghế, ghế ngoài phòng (BR-05, BR-06) | DC-SeatSelectionError |
| REGISTRATION_DATA_INVALID | 422 | MSG-04, MSG-05, MSG-89 (theo detail.field) | Email, số điện thoại, mật khẩu sai (BR-81, BR-82, BR-99) | DC-RegistrationDataError |
| STAFF_DATA_INVALID | 422 | MSG-118, MSG-89 | Dữ liệu tài khoản nhân viên sai (BR-78, BR-79, BR-99) | DC-StaffDataError |
| INVALID_PERIOD | 422 | MSG-115 | Kỳ báo cáo thiếu hoặc từ ngày sau đến ngày | DC-InvalidPeriodError |
| INVALID_INFO | 422 | MSG-95, MSG-96, MSG-97, MSG-98 (detail.violations) | Thông tin phim hoặc cụm rạp sai | DC-InvalidInfoError |
| FIELD_INVALID | 422 | MSG-97, MSG-114, MSG-79 (detail.violations) | Trường phòng chiếu sai, hoặc tiêu chí lọc ngày sai | DC-FieldInvalidError |
| TICKET_PRICE_INVALID | 422 | MSG-51 | Giá vé không lớn hơn 0 (BR-70) | DC-TicketPriceInvalidError |
| CAPACITY_OUT_OF_RANGE | 422 | MSG-104 | Sức chứa ngoài 50 đến 400 (BR-144) | DC-CapacityOutOfRangeError |
| FORMAT_NOT_RELEASED | 422 | MSG-59 | Định dạng không phải định dạng phát hành (BR-47) | DC-FormatNotReleasedError |
| FORMAT_NOT_SUPPORTED | 422 | MSG-60 | Phòng không chiếu được định dạng (BR-48) | DC-FormatNotSupportedError |
| PRICE_NOT_COVERED | 422 | MSG-61, MSG-107 | Bảng giá thiếu giá cho một loại ghế (BR-69) | DC-PriceNotCoveredError |
| OUTSIDE_RUN_PERIOD | 422 | MSG-62 | Ngoài khoảng chiếu của phim (BR-49) | DC-OutsideRunPeriodError |
| SHOWTIME_STARTED | 422 | MSG-63 (lập), MSG-67 (sửa, xoá) | Giờ bắt đầu không sau hiện tại (BR-56, BR-57) | DC-ShowtimeStartedError |
| SALE_OPEN_ORDER | 422 | MSG-64 | Mở bán không trước giờ bắt đầu (BR-55) | DC-SaleOpenOrderError |
| ROOM_GAP | 422 | MSG-65 | Cách suất khác trong phòng dưới 15 phút (BR-51) | DC-RoomGapError |
| SSE_LIMIT | 429 | MSG-24 | Quá 10 kết nối SSE đang mở từ một địa chỉ IP tới bản backend này | DC-IpConnectionLimiter |
| INTERNAL | 500 | MSG-72 | Lỗi không phân loại, lỗi lập trình (LockOrderViolationError, PaymentStateError); chi tiết chỉ vào log | DC-HttpErrorMapper |
| SYSTEM_BUSY | 503 | MSG-72 | Hết thời gian chờ khoá hoặc deadlock sau thử lại, hết deadline 14 giây; kèm tiêu đề Retry-After: 2 | DC-SystemBusyError, context deadline |
| GATEWAY_CONFIG | 503 | MSG-15 | Cấu hình cổng thanh toán thiếu hoặc sai | DC-GatewayConfigurationError |
| HUB_UNAVAILABLE | 503 | MSG-24 | Bộ phát sự kiện đổi ghế chưa chạy | DC-SeatHubUnavailableError |

Quy tắc phân loại: 400 yêu cầu sai dạng (chưa vào service); 401 phiên hoặc đăng nhập; 403 không đủ quyền hoặc sai kênh, cụm rạp; 404 không có dòng; 409 trạng thái hiện tại không cho phép hoặc dữ liệu đã đổi (khách sửa lại bằng cách tải lại); 422 dữ liệu nhập vi phạm quy tắc (khách sửa dữ liệu nhập); 429 giới hạn kết nối; 5xx lỗi hệ thống. Lỗi chưa có trong bảng rơi vào INTERNAL.

### F2c. Operation của các lớp khác

| DC | Visibility | Chữ ký | Mô tả | Tiền/hậu điều kiện | Nguồn | Phạm vi | Ngoại lệ / lỗi |
|---|---|---|---|---|---|---|---|
| DC-AuthFilter | + | NewAuthFilter(auth IAuthenticator, access *AccessCheckService, errs *HttpErrorMapper) *AuthFilter | Tạo bộ lọc với ba phụ thuộc tiêm | - | Bổ sung: khởi tạo | Classifier | - |
| DC-AuthFilter | + | Require(allowed []Role, next CallerHandler) http.Handler | Trả handler bọc: đặt deadline 14 giây, kiểm phiên, kiểm vai trò rồi gọi next(w, r, caller); allowed rỗng là lỗi lập trình lúc đăng ký | Tiền: allowed không rỗng. Hậu: next chỉ chạy khi phiên và vai trò hợp lệ | P10 cơ chế Bảo mật; P09 F7.11; AC-C-BookTicketsController.checkCustomerLoggedIn | Instance | SESSION_INVALID, FORBIDDEN_ROLE, SYSTEM_BUSY |
| DC-AuthFilter | - | authenticate(r *http.Request) (CallerContext, error) | Lấy token, IF-07.VerifySession; khách và quản trị viên dựng ngay; bốn vai trò nhân viên gọi DC-AccessCheckService.CheckStaffAccess(claims) một lần rồi dựng ActorContext từ vai trò và cụm rạp hiện hành | Hậu: không đổi dữ liệu | P09 F7.11; BR-101 | Instance | StaffAccessRevokedError, SystemBusyError, lỗi của VerifySession |
| DC-AuthFilter | - | bearerToken(r *http.Request) (string, bool) | Tách token khỏi tiêu đề Authorization; false khi thiếu hoặc không có tiền tố Bearer | - | Bổ sung: tách hàm | Instance | - |
| DC-HttpErrorMapper | + | Write(w http.ResponseWriter, r *http.Request, err error, scope ErrorScope) | Gọi Classify rồi ghi mã HTTP và DC-ApiErrorBody; ghi log kèm lỗi gốc cho INTERNAL, không đưa chi tiết lỗi ra dây | Hậu: đúng một phản hồi | Bổ sung: một nơi chứa bảng lỗi | Instance | - |
| DC-HttpErrorMapper | + | Classify(err error, scope ErrorScope) (int, ApiErrorBody) | Tra errors.As theo thứ tự từ cụ thể tới chung, ra mã HTTP, code, messageId theo F2b; SeatUnavailable, SeatSelection, HoldNotActive đưa vào detail | Hậu: hàm thuần, không ghi gì | Bổ sung: kiểm thử được không cần HTTP | Instance | - |
| DC-RequestDecoder | + | DecodeJSON(w http.ResponseWriter, r *http.Request, dst any) error | Giới hạn thân 256 KiB bằng http.MaxBytesReader, bắt buộc Content-Type application/json, từ chối trường lạ và nhiều giá trị JSON | Hậu: dst đầy đủ khi trả nil | Bổ sung: giải mã thân | Instance | RequestInvalidError |
| DC-RequestDecoder | + | PathInt64(r *http.Request, name string) (int64, error) | Đọc tham số đường dẫn số nguyên dương | - | Bổ sung | Instance | RequestInvalidError |
| DC-RequestDecoder | + | QueryDate(r *http.Request, name string) (*BusinessDate, error) | Đọc query ngày yyyy-MM-dd tuỳ chọn; vắng thì nil | - | Bổ sung | Instance | RequestInvalidError |
| DC-RequestDecoder | + | ParseInstant(text string) (time.Time, error) | Đọc chuỗi RFC 3339 và giữ micro giây | - | Bổ sung | Classifier | RequestInvalidError |
| DC-RequestDecoder | + | WriteJSON(w http.ResponseWriter, status int, body any) | Ghi tiêu đề, mã và thân JSON | - | Bổ sung | Instance | - |
| DC-IpConnectionLimiter | + | NewIpConnectionLimiter(maxPerIp int) *IpConnectionLimiter | Tạo bộ đếm | Tiền: maxPerIp lớn hơn 0 | Bổ sung: khởi tạo | Classifier | - |
| DC-IpConnectionLimiter | + | TryAcquire(clientIp string) (release func(), ok bool) | Tăng đếm nếu dưới giới hạn; release giảm đếm đúng một lần dù gọi nhiều lần | Hậu: ok false khi đã đủ 10 | P09 F7.5 | Instance | - |
| DC-IpConnectionLimiter | + | ClientIp(r *http.Request) string | Lấy địa chỉ IP của trình duyệt: phần tử đầu của X-Forwarded-For khi bộ cân bằng tải tin cậy đặt (cấu hình), ngược lại RemoteAddr bỏ cổng | - | Q-349 | Instance | - |
| DC-SseConnection | + | NewSseConnection(newTicker func(time.Duration) (<-chan time.Time, func())) *SseConnection | Tạo kết nối ở OPENING; ticker nhận qua constructor | - | Bổ sung: khởi tạo; Bước 2.6 | Classifier | - |
| DC-SseConnection | + | Run(ctx Ctx, w http.ResponseWriter, r *http.Request, stream SseStream) | Ghi tiêu đề SSE, rồi lặp: ghi khung nhận từ stream.frames, ghi nhịp tim mỗi 15 giây; kết thúc khi ctx huỷ, kênh đóng hoặc ghi lỗi, luôn gọi stream.close | Tiền: stream đã mở. Hậu: state CLOSED, stream.close đã gọi đúng một lần | P09 F7.5; ST-19 | Instance | - |
| DC-SseConnection | - | writeFrame(f SseFrame) error | Ghi id, event, data của khung theo định dạng SSE và Flush, đặt hạn ghi 10 giây | - | ST-19 sự kiện frame | Instance | lỗi ghi |
| DC-SseConnection | - | writeHeartbeat() error | Ghi dòng chú thích nhịp tim (bắt đầu bằng dấu hai chấm) và Flush | - | ST-19 sự kiện heartbeatTick | Instance | lỗi ghi |
| DC-SseConnection | + | State() SseConnectionState | Trạng thái hiện tại | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| IF-44 | + | Routes() []RouteSpec | Danh sách tuyến mà controller phụ trách | Hậu: tên tuyến và mẫu không trùng giữa các controller | Thiết kế: IF-44 | Instance | - |
| DC-BookingController, DC-SeatMapStreamController, DC-TicketController, DC-PricingScheduleController, DC-CatalogController, DC-AccountController, DC-ReportController, DC-ChainController | + | Routes() []RouteSpec | Hiện thực IF-44.Routes: trả các tuyến của controller kèm vai trò cho phép | Hậu: số tuyến khớp F2a | Thiết kế: IF-44 | Instance | - |
| DC-BookingController, DC-SeatMapStreamController, DC-TicketController, DC-PricingScheduleController, DC-CatalogController, DC-AccountController, DC-ReportController, DC-ChainController | + | NewXxxController(services..., decoder *RequestDecoder, errs *HttpErrorMapper) | Hàm dựng, ví dụ NewBookingController(book *BookTicketsService, ...); AuthFilter truyền ở Routes qua DC-RouteSpec | Bổ sung: khởi tạo | Classifier | - |

### F2d. Handler theo controller

Mỗi dòng là một tuyến ở F2a.

| DC | Visibility | Chữ ký | Mô tả | Tiền/hậu điều kiện | Nguồn | Phạm vi | Ngoại lệ / lỗi |
|---|---|---|---|---|---|---|---|
| DC-BookingController | + | HoldSeats(w http.ResponseWriter, r *http.Request) | Tuyến POST /api/showtimes/{showtimeId}/holds: giải mã, gọi BookTicketsService.HoldSeats, ghi kết quả | Quyền: CUS, CLK. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-005 bước 7 | Instance | SHOWTIME_NOT_OPEN, SHOWTIME_CHANGED, SEAT_SELECTION_INVALID, HOLDER_BUSY, SEAT_UNAVAILABLE, CHANNEL_MISMATCH, SESSION_INVALID, SYSTEM_BUSY |
| DC-BookingController | + | GetActiveHold(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/holds/active: giải mã, gọi BookTicketsService.FindActiveHold (Tạm), ghi kết quả | Quyền: CUS, CLK. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-005 luồng 5b, 7c; BR-04 | Instance | SYSTEM_BUSY |
| DC-BookingController | + | GetHold(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/holds/{holdRef}: giải mã, gọi BookTicketsService.GetHold, ghi kết quả | Quyền: CUS, CLK. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-005; Q-341 | Instance | NOT_FOUND, SYSTEM_BUSY |
| DC-BookingController | + | CancelHold(w http.ResponseWriter, r *http.Request) | Tuyến DELETE /api/holds/{holdRef}: giải mã, gọi BookTicketsService.CancelHold, ghi kết quả | Quyền: CUS, CLK. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-005 luồng *a | Instance | HOLD_NOT_ACTIVE, NOT_FOUND, SYSTEM_BUSY |
| DC-BookingController | + | StartOnlinePayment(w http.ResponseWriter, r *http.Request) | Tuyến POST /api/holds/{holdRef}/payment: giải mã, gọi BookTicketsService.StartOnlinePayment, ghi kết quả | Quyền: CUS. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-005 bước 10 | Instance | HOLD_NOT_ACTIVE, NOT_FOUND, GATEWAY_CONFIG |
| DC-BookingController | + | ConfirmCashReceived(w http.ResponseWriter, r *http.Request) | Tuyến POST /api/holds/{holdRef}/cash-confirmation: giải mã, gọi BookTicketsService.ConfirmCashReceived, ghi kết quả | Quyền: CLK. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-005 bước 9a1 | Instance | HOLD_NOT_ACTIVE, NOT_FOUND, SYSTEM_BUSY, SESSION_INVALID |
| DC-SeatMapStreamController | + | GetSeatMap(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/showtimes/{showtimeId}/seat-map: giải mã, gọi SeatMapService.GetSnapshot, ghi kết quả | Quyền: PUB. Công khai. Hậu: không đổi trạng thái ngoài service | UC-005 bước 3; P09 F7.5 điểm 4 | Instance | NOT_FOUND, SYSTEM_BUSY |
| DC-SeatMapStreamController | + | StreamSeatEvents(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/showtimes/{showtimeId}/seat-events: giải mã, gọi SeatMapService.OpenStream, ghi kết quả | Quyền: PUB. Công khai. Hậu: không đổi trạng thái ngoài service | UC-005 bước 3; P09 F7.5 | Instance | SSE_LIMIT, HUB_UNAVAILABLE, NOT_FOUND |
| DC-TicketController | + | ListBookingHistory(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/me/bookings: giải mã, gọi ViewBookingHistoryService.ListHistory, ghi kết quả | Quyền: CUS. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-007 | Instance | SYSTEM_BUSY |
| DC-TicketController | + | GetBookingTickets(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/me/bookings/{bookingCode}: giải mã, gọi ViewBookingHistoryService.FindBookingTickets, ghi kết quả | Quyền: CUS. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-007 | Instance | NOT_FOUND, BOOKING_NOT_OWNED |
| DC-TicketController | + | CancelOnlineTicket(w http.ResponseWriter, r *http.Request) | Tuyến POST /api/tickets/{ticketId}/cancellation: giải mã, gọi CancelTicketService.CancelOnlineTicket, ghi kết quả | Quyền: CUS. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-008 khách | Instance | TICKET_STATE, CANCEL_DEADLINE, CHANNEL_MISMATCH, REFUND_LIMIT, SYSTEM_BUSY |
| DC-TicketController | + | FindCounterBooking(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/counter/bookings/{bookingCode}: giải mã, gọi CancelTicketService.FindBooking, ghi kết quả | Quyền: CLK. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-008 quầy; Q-341 | Instance | NOT_FOUND, CHANNEL_MISMATCH |
| DC-TicketController | + | PrepareCashRefund(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/counter/tickets/{ticketId}/cash-refund: giải mã, gọi CancelTicketService.PrepareCashRefund (Tạm), ghi kết quả | Quyền: CLK. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-008 // requestCancellation | Instance | TICKET_STATE, CANCEL_DEADLINE, CHANNEL_MISMATCH, NOT_FOUND |
| DC-TicketController | + | ConfirmCashRefund(w http.ResponseWriter, r *http.Request) | Tuyến POST /api/counter/tickets/{ticketId}/cash-refund: giải mã, gọi CancelTicketService.ConfirmCashRefund, ghi kết quả | Quyền: CLK. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-008 // confirmCashRefund | Instance | TICKET_STATE, CANCEL_DEADLINE, CHANNEL_MISMATCH, SYSTEM_BUSY |
| DC-TicketController | + | StartChecking(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/checking/showtimes/{showtimeId}: giải mã, gọi CheckTicketService.StartChecking, ghi kết quả | Quyền: CHK. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-009 // startChecking | Instance | NOT_FOUND, CHANNEL_MISMATCH |
| DC-TicketController | + | CheckTicket(w http.ResponseWriter, r *http.Request) | Tuyến POST /api/checking/showtimes/{showtimeId}/scans: giải mã, gọi CheckTicketService.CheckTicket, ghi kết quả | Quyền: CHK. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-009 // checkTicket | Instance | NOT_FOUND, SYSTEM_BUSY |
| DC-PricingScheduleController | + | ListPriceEntries(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/cinema/price-entries: giải mã, gọi ManagePriceListService.GetPriceList, ghi kết quả | Quyền: CMG. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-013 | Instance | NOT_FOUND |
| DC-PricingScheduleController | + | SavePriceEntry(w http.ResponseWriter, r *http.Request) | Tuyến PUT /api/cinema/price-entries: giải mã, gọi ManagePriceListService.SubmitPriceEntry, ghi kết quả | Quyền: CMG. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-013 | Instance | TICKET_PRICE_INVALID, PRICE_ENTRY_CHANGED, SYSTEM_BUSY |
| DC-PricingScheduleController | + | RemovePriceEntry(w http.ResponseWriter, r *http.Request) | Tuyến POST /api/cinema/price-entries/removal: giải mã, gọi ManagePriceListService.SubmitPriceEntryRemoval, ghi kết quả | Quyền: CMG. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-013 | Instance | PRICE_ENTRY_CHANGED, PRICE_ENTRY_IN_USE, SYSTEM_BUSY |
| DC-PricingScheduleController | + | ListShowtimes(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/cinema/showtimes: giải mã, gọi ScheduleShowtimesService.ListShowtimes, ghi kết quả | Quyền: CMG. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-014 | Instance | - |
| DC-PricingScheduleController | + | GetScheduleFormData(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/cinema/showtimes/form-data: giải mã, gọi ScheduleShowtimesService.StartScheduling, ghi kết quả | Quyền: CMG. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-014 // startScheduling | Instance | - |
| DC-PricingScheduleController | + | GetShowtimeEditForm(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/cinema/showtimes/{showtimeId}/edit: giải mã, gọi ScheduleShowtimesService.PrepareShowtimeEdit, ghi kết quả | Quyền: CMG. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-014 // prepareShowtimeEdit | Instance | SHOWTIME_STARTED, SHOWTIME_IN_USE, NOT_FOUND, NOT_OWN_CINEMA |
| DC-PricingScheduleController | + | CreateShowtime(w http.ResponseWriter, r *http.Request) | Tuyến POST /api/cinema/showtimes: giải mã, gọi ScheduleShowtimesService.CreateShowtime, ghi kết quả | Quyền: CMG. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-014 | Instance | NOT_OWN_CINEMA, FORMAT_NOT_RELEASED, FORMAT_NOT_SUPPORTED, PRICE_NOT_COVERED, OUTSIDE_RUN_PERIOD, SHOWTIME_STARTED, SALE_OPEN_ORDER, AUDITORIUM_GONE, ROOM_GAP, SYSTEM_BUSY |
| DC-PricingScheduleController | + | UpdateShowtime(w http.ResponseWriter, r *http.Request) | Tuyến PUT /api/cinema/showtimes/{showtimeId}: giải mã, gọi ScheduleShowtimesService.UpdateShowtime, ghi kết quả | Quyền: CMG. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-014 | Instance | SHOWTIME_CHANGED, SHOWTIME_STARTED, SHOWTIME_IN_USE, ROOM_CHANGE_NOT_ALLOWED, và các lỗi của showtime.create |
| DC-PricingScheduleController | + | DeleteShowtime(w http.ResponseWriter, r *http.Request) | Tuyến POST /api/cinema/showtimes/{showtimeId}/deletion: giải mã, gọi ScheduleShowtimesService.DeleteShowtime, ghi kết quả | Quyền: CMG. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-014 | Instance | SHOWTIME_CHANGED, SHOWTIME_STARTED, SHOWTIME_IN_USE, NOT_OWN_CINEMA |
| DC-PricingScheduleController | + | ListAuditoriums(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/cinema/auditoriums: giải mã, gọi ManageAuditoriumsService.ListAuditoriums, ghi kết quả | Quyền: CMG. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-012 | Instance | - |
| DC-PricingScheduleController | + | GetAuditorium(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/cinema/auditoriums/{auditoriumId}: giải mã, gọi ManageAuditoriumsService.SelectAuditorium, ghi kết quả | Quyền: CMG. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-012 | Instance | NOT_FOUND, NOT_OWN_CINEMA |
| DC-PricingScheduleController | + | CreateAuditorium(w http.ResponseWriter, r *http.Request) | Tuyến POST /api/cinema/auditoriums: giải mã, gọi ManageAuditoriumsService.AddAuditorium, ghi kết quả | Quyền: CMG. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-012 | Instance | FIELD_INVALID, CAPACITY_OUT_OF_RANGE, AUDITORIUM_NAME_TAKEN, SYSTEM_BUSY |
| DC-PricingScheduleController | + | UpdateAuditorium(w http.ResponseWriter, r *http.Request) | Tuyến PUT /api/cinema/auditoriums/{auditoriumId}: giải mã, gọi ManageAuditoriumsService.EditAuditorium, ghi kết quả | Quyền: CMG. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-012 | Instance | FIELD_INVALID, CAPACITY_OUT_OF_RANGE, NOT_OWN_CINEMA, AUDITORIUM_GONE, AUDITORIUM_CHANGED, AUDITORIUM_NAME_TAKEN, AUDITORIUM_BLOCKED, PRICE_NOT_COVERED |
| DC-PricingScheduleController | + | RemoveAuditorium(w http.ResponseWriter, r *http.Request) | Tuyến POST /api/cinema/auditoriums/{auditoriumId}/removal: giải mã, gọi ManageAuditoriumsService.RemoveAuditorium, ghi kết quả | Quyền: CMG. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-012 | Instance | AUDITORIUM_GONE, NOT_OWN_CINEMA, AUDITORIUM_HAS_SCHEDULE |
| DC-CatalogController | + | ListMovies(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/movies: giải mã, gọi BrowseMoviesService.ListMovies, ghi kết quả | Quyền: PUB. Công khai. Hậu: không đổi trạng thái ngoài service | UC-003 | Instance | SYSTEM_BUSY |
| DC-CatalogController | + | GetMovie(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/movies/{movieId}: giải mã, gọi BrowseMoviesService.GetMovieDetails, ghi kết quả | Quyền: PUB. Công khai. Hậu: không đổi trạng thái ngoài service | UC-003 | Instance | NOT_FOUND |
| DC-CatalogController | + | ListMovieChoices(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/browse/movies: giải mã, gọi BrowseShowtimesService.ListMoviesForBrowsing, ghi kết quả | Quyền: PUB. Công khai. Hậu: không đổi trạng thái ngoài service | UC-004 | Instance | SYSTEM_BUSY |
| DC-CatalogController | + | ListCinemaChoices(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/browse/cinemas: giải mã, gọi BrowseShowtimesService.ListCinemasForBrowsing, ghi kết quả | Quyền: PUB. Công khai. Hậu: không đổi trạng thái ngoài service | UC-004 | Instance | SYSTEM_BUSY |
| DC-CatalogController | + | FindShowtimesByMovie(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/browse/movies/{movieId}/showtimes: giải mã, gọi BrowseShowtimesService.FindShowtimesByMovie, ghi kết quả | Quyền: PUB. Công khai. Hậu: không đổi trạng thái ngoài service | UC-004 | Instance | FIELD_INVALID |
| DC-CatalogController | + | FindShowtimesByCinema(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/browse/cinemas/{cinemaId}/showtimes: giải mã, gọi BrowseShowtimesService.FindShowtimesByCinema, ghi kết quả | Quyền: PUB. Công khai. Hậu: không đổi trạng thái ngoài service | UC-004; Q-335 | Instance | FIELD_INVALID |
| DC-CatalogController | + | FindOwnCinemaShowtimes(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/staff/cinema/showtimes: giải mã, gọi BrowseShowtimesService.FindShowtimesByCinema (cinemaId từ DC-CallerContext), ghi kết quả | Quyền: CLK, CHK. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | Q-335 | Instance | SYSTEM_BUSY |
| DC-CatalogController | + | GetShowtime(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/showtimes/{showtimeId}: giải mã, gọi BrowseShowtimesService.GetShowtime (Tạm), ghi kết quả | Quyền: PUB. Công khai. Hậu: không đổi trạng thái ngoài service | UC-005 bước 1 | Instance | NOT_FOUND |
| DC-AccountController | + | LoginCustomer(w http.ResponseWriter, r *http.Request) | Tuyến POST /api/auth/customer-login: giải mã, gọi LoginService.LoginCustomer, ghi kết quả | Quyền: PUB. Công khai. Hậu: không đổi trạng thái ngoài service | NFR-01; Q-267 | Instance | LOGIN_FAILED, SYSTEM_BUSY |
| DC-AccountController | + | LoginStaff(w http.ResponseWriter, r *http.Request) | Tuyến POST /api/auth/staff-login: giải mã, gọi LoginService.LoginStaff, ghi kết quả | Quyền: PUB. Công khai. Hậu: không đổi trạng thái ngoài service | NFR-02, NFR-03; Q-267 | Instance | LOGIN_FAILED, STAFF_LOCKED, SYSTEM_BUSY |
| DC-AccountController | + | RegisterAccount(w http.ResponseWriter, r *http.Request) | Tuyến POST /api/accounts: giải mã, gọi RegisterAccountService.RegisterAccount, ghi kết quả | Quyền: PUB. Công khai. Hậu: không đổi trạng thái ngoài service | UC-001 | Instance | REGISTRATION_DATA_INVALID, DUPLICATE_CUSTOMER, SYSTEM_BUSY |
| DC-AccountController | + | ListStaff(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/admin/staff: giải mã, gọi ManageStaffAccountsService.ListStaffAccounts, ghi kết quả | Quyền: ADM. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-017 | Instance | SYSTEM_BUSY |
| DC-AccountController | + | GetStaffChoices(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/admin/staff/choices: giải mã, gọi ManageStaffAccountsService.OpenStaffCreation, ghi kết quả | Quyền: ADM. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-017 // startStaffCreation | Instance | SYSTEM_BUSY |
| DC-AccountController | + | GetStaff(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/admin/staff/{staffId}: giải mã, gọi ManageStaffAccountsService.OpenStaffForUpdate, ghi kết quả | Quyền: ADM. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-017 // openStaffForUpdate | Instance | NOT_FOUND |
| DC-AccountController | + | CreateStaff(w http.ResponseWriter, r *http.Request) | Tuyến POST /api/admin/staff: giải mã, gọi ManageStaffAccountsService.CreateStaffAccount, ghi kết quả | Quyền: ADM. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-017 | Instance | STAFF_DATA_INVALID, DUPLICATE_STAFF_EMAIL, NOT_FOUND |
| DC-AccountController | + | UpdateStaffAccess(w http.ResponseWriter, r *http.Request) | Tuyến PUT /api/admin/staff/{staffId}/access: giải mã, gọi ManageStaffAccountsService.UpdateStaffAccess, ghi kết quả | Quyền: ADM. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-017 | Instance | STAFF_DATA_INVALID, STALE_STAFF, NOT_FOUND |
| DC-AccountController | + | LockStaff(w http.ResponseWriter, r *http.Request) | Tuyến POST /api/admin/staff/{staffId}/lock: giải mã, gọi ManageStaffAccountsService.LockStaffAccount, ghi kết quả | Quyền: ADM. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-017 | Instance | STAFF_STATUS_UNCHANGED, STALE_STAFF, NOT_FOUND |
| DC-AccountController | + | UnlockStaff(w http.ResponseWriter, r *http.Request) | Tuyến POST /api/admin/staff/{staffId}/unlock: giải mã, gọi ManageStaffAccountsService.UnlockStaffAccount, ghi kết quả | Quyền: ADM. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-017 | Instance | STAFF_STATUS_UNCHANGED, STALE_STAFF, NOT_FOUND |
| DC-AccountController | + | RenameStaff(w http.ResponseWriter, r *http.Request) | Tuyến PUT /api/admin/staff/{staffId}/name: giải mã, gọi ManageStaffAccountsService.RenameStaffAccount, ghi kết quả | Quyền: ADM. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-017 | Instance | STAFF_DATA_INVALID, STALE_STAFF, NOT_FOUND |
| DC-AccountController | + | ResetStaffPassword(w http.ResponseWriter, r *http.Request) | Tuyến POST /api/admin/staff/{staffId}/password-reset: giải mã, gọi ManageStaffAccountsService.ResetStaffAccountPassword, ghi kết quả | Quyền: ADM. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-017 | Instance | STAFF_DATA_INVALID, STALE_STAFF, NOT_FOUND |
| DC-ReportController | + | GetCinemaReport(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/cinema/report: giải mã, gọi ViewCinemaReportService.ViewCinemaReport, ghi kết quả | Quyền: CMG. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-015 | Instance | INVALID_PERIOD, SYSTEM_BUSY |
| DC-ReportController | + | GetChainReport(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/chain/report: giải mã, gọi ViewChainReportService.ViewChainReport, ghi kết quả | Quyền: CHM. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-016 | Instance | INVALID_PERIOD, SYSTEM_BUSY |
| DC-ChainController | + | ListManagedMovies(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/chain/movies: giải mã, gọi ManageMoviesService.ListMovies, ghi kết quả | Quyền: CHM. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-010 | Instance | SYSTEM_BUSY |
| DC-ChainController | + | GetManagedMovie(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/chain/movies/{movieId}: giải mã, gọi ManageMoviesService.GetMovieForEdit, ghi kết quả | Quyền: CHM. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-010 | Instance | NOT_FOUND |
| DC-ChainController | + | CreateMovie(w http.ResponseWriter, r *http.Request) | Tuyến POST /api/chain/movies: giải mã, gọi ManageMoviesService.AddMovie, ghi kết quả | Quyền: CHM. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-010 | Instance | INVALID_INFO, SYSTEM_BUSY |
| DC-ChainController | + | UpdateMovie(w http.ResponseWriter, r *http.Request) | Tuyến PUT /api/chain/movies/{movieId}: giải mã, gọi ManageMoviesService.SaveMovieChanges, ghi kết quả | Quyền: CHM. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-010 | Instance | INVALID_INFO, CHANGED_SINCE_DISPLAYED, NOT_FOUND |
| DC-ChainController | + | ListManagedCinemas(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/chain/cinemas: giải mã, gọi ManageCinemasService.ListCinemas, ghi kết quả | Quyền: CHM. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-011 | Instance | SYSTEM_BUSY |
| DC-ChainController | + | GetManagedCinema(w http.ResponseWriter, r *http.Request) | Tuyến GET /api/chain/cinemas/{cinemaId}: giải mã, gọi ManageCinemasService.GetCinemaForEdit, ghi kết quả | Quyền: CHM. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-011 | Instance | NOT_FOUND |
| DC-ChainController | + | CreateCinema(w http.ResponseWriter, r *http.Request) | Tuyến POST /api/chain/cinemas: giải mã, gọi ManageCinemasService.AddCinema, ghi kết quả | Quyền: CHM. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-011 | Instance | INVALID_INFO, CINEMA_NAME_TAKEN |
| DC-ChainController | + | UpdateCinema(w http.ResponseWriter, r *http.Request) | Tuyến PUT /api/chain/cinemas/{cinemaId}: giải mã, gọi ManageCinemasService.SaveCinemaChanges, ghi kết quả | Quyền: CHM. Tiền: người gọi qua DC-AuthFilter.Require. Hậu: không đổi trạng thái ngoài service | UC-011 | Instance | INVALID_INFO, CINEMA_NAME_TAKEN, CHANGED_SINCE_DISPLAYED, NOT_FOUND |

## F3. Bảng thiết kế method

Phạm vi giao dịch: không có. Mọi handler chỉ gọi service; giao dịch, khoá và hạng khoá nằm trong service (P12 lõi F3). Với handler gọi service ghi nhiều giai đoạn (booking.holdSeats, ticket.cancel), phần "Nếu dừng tại đây" nằm ở F3 của lõi; ở đây chỉ thêm điều xảy ra khi kết nối bị cắt giữa chừng: ctx của yêu cầu bị huỷ, service dừng ở ranh giới giao dịch gần nhất hoặc đã commit, và lời gọi lại theo F2 quy ước chống gửi trùng.

| DC.operation | Thuật toán / các bước chính | Đối tượng và operation khác được dùng | Cách dùng thuộc tính, tham số, quan hệ | Hành vi theo trạng thái (nếu có ST) |
|---|---|---|---|---|
| DC-AuthFilter.Require | 1. Bọc ctx của yêu cầu bằng deadline requestDeadline.<br>2. authenticate; lỗi thì HttpErrorMapper.Write(ErrorScope theo tuyến) và dừng.<br>3. IF-07.CheckRole(caller.role, allowed); sai thì 403 FORBIDDEN_ROLE.<br>4. Gọi next(w, r, caller) | IF-07.CheckRole, DC-HttpErrorMapper.Write | allowed, requestDeadline | - |
| DC-AuthFilter.authenticate | 1. bearerToken; thiếu thì lỗi SESSION_INVALID.<br>2. claims = IF-07.VerifySession(token); lỗi thì SESSION_INVALID (hết hạn và sai chữ ký cùng mã; trình duyệt xử lý như nhau).<br>3. subjectKind CUSTOMER: role CUSTOMER, actor = ActorContext(CUSTOMER, subjectId).<br>4. subjectKind STAFF và claims.role ADMINISTRATOR: role ADMINISTRATOR, access nil.<br>5. Còn lại là bốn vai trò nhân viên: access = DC-AccessCheckService.CheckStaffAccess(ctx, claims) đúng một lần; StaffAccessRevokedError thì SESSION_INVALID (MSG-85).<br>6. role = access.role, cinemaId = access.cinemaId, actor kind theo role (CLERK, CHECKER) với accessChangedAt lấy từ claims | IF-07.VerifySession, DC-AccessCheckService.CheckStaffAccess | Không dùng role, cinemaId trong claims để phân quyền (có thể đã cũ, F7.11) | - |
| DC-HttpErrorMapper.Classify | 1. context.DeadlineExceeded hoặc SystemBusyError hoặc SeatHubUnavailable --> 503 SYSTEM_BUSY.<br>2. Với từng kiểu lỗi trong F2b: errors.As theo thứ tự đặt trong bảng; lỗi cụ thể trước lỗi chung (DC-PriceNotCoveredError là PRICE_UNDEFINED ở ErrorScope BOOKING, PRICE_NOT_COVERED ở SCHEDULE).<br>3. messageId chọn theo scope và reason.<br>4. Không khớp thì 500 INTERNAL | errors.As | scope | - |
| DC-BookingController.HoldSeats | 1. showtimeId = PathInt64; body = DecodeJSON; requestId phải là UUID, seatIds không rỗng cũng do service kiểm (BR-05).<br>2. displayedAt = ParseInstant.<br>3. holder = caller.HolderRef(); accessChangedAt = caller.actor.accessChangedAt (nhân viên quầy), không nhận từ trình duyệt.<br>4. res = BookTicketsService.HoldSeats(ctx, HoldSeatsRequest).<br>5. Trả DC-HoldDto: 201 nếu replayed false, 200 nếu true | DC-BookTicketsService.HoldSeats | Cụm rạp của quầy do service lấy từ dòng Staff đã khoá (không từ yêu cầu) | - |
| DC-BookingController.ConfirmCashReceived | 1. holdRef = path.<br>2. BookTicketsService.ConfirmCashReceived(ctx, holdRef, caller.HolderRef()).<br>3. Trả DC-BookingDto.<br>4. Lỗi HOLD_NOT_ACTIVE kèm detail.holdStatus để quầy hiện MSG-20 (trả lại tiền mặt) khi lần giữ ghế đã Hết hạn, Đã huỷ, Thanh toán thất bại | DC-BookTicketsService.ConfirmCashReceived | Không tự gửi lại; đối chiếu bằng booking.getHold (Q-341) | - |
| DC-BookingController.StartOnlinePayment | 1. holdRef = path; clientIp = DC-IpConnectionLimiter.ClientIp(r) (cùng quy tắc lấy IP với kết nối SSE).<br>2. BookTicketsService.StartOnlinePayment.<br>3. Trả {transactionCode, paymentUrl}; mỗi lần gọi tạo địa chỉ mới (BR-90) | DC-BookTicketsService.StartOnlinePayment | clientIp chỉ để ký địa chỉ cổng | - |
| DC-SeatMapStreamController.StreamSeatEvents | 1. showtimeId = PathInt64; after = query after hoặc tiêu đề Last-Event-ID (tiêu đề ưu tiên khi cả hai có), mặc định 0.<br>2. release, ok = limiter.TryAcquire(ClientIp); không ok thì 429 SSE_LIMIT, dừng.<br>3. stream = SeatMapService.OpenStream(ctx, showtimeId, after); lỗi thì release rồi 503 HUB_UNAVAILABLE hoặc 404.<br>4. Chạy SseConnection.Run(ctx, w, r, stream) đồng bộ; khi trả về gọi release | DC-IpConnectionLimiter, DC-SeatMapService.OpenStream, DC-SseConnection.Run | ctx của yêu cầu, không deadline | ST-19 |
| DC-SseConnection.Run | 1. Ghi tiêu đề Content-Type text/event-stream, Cache-Control no-cache, X-Accel-Buffering no, Connection keep-alive; Flush; state STREAMING.<br>2. Lặp select: ctx.Done (client đi); frame từ stream.frames (kênh đóng thì thoát); tick 15 giây (writeHeartbeat).<br>3. writeFrame hoặc writeHeartbeat lỗi thì thoát.<br>4. defer stream.close(); state CLOSED | DC-SseStream.frames, close | heartbeatInterval, writeTimeout dùng http.ResponseController.SetWriteDeadline | Bảng ST-19 |
| DC-TicketController.CancelOnlineTicket | 1. ticketId = path.<br>2. CancelTicketService.CancelOnlineTicket(ctx, ticketId, caller.actor).<br>3. Trả DC-CancelResultDto. Khi refundStatus chưa xong (hoàn qua cổng chạy sau commit) vẫn trả 200 với trạng thái hiện tại (MSG-41) | DC-CancelTicketService | Hoàn tiền gọi cổng chạy ngoài yêu cầu (P09 F7.7) nên không gây vượt deadline 14 giây | - |
| DC-TicketController.PrepareCashRefund | 1. ticketId = path.<br>2. CancelTicketService.PrepareCashRefund(ctx, ticketId, caller.actor): chỉ đọc, kiểm vé thuộc kênh quầy của cụm rạp, chưa huỷ, chưa dùng, còn trước hạn huỷ.<br>3. Trả số tiền hoàn mặt (70 phần trăm, BR-19) để quầy hiện MSG-39 | DC-CancelTicketService.PrepareCashRefund (Tạm) | - | - |
| DC-TicketController.CheckTicket | 1. showtimeId = path; qrText = body.<br>2. CheckTicketService.CheckTicket(ctx, qrText, showtimeId, caller.actor).<br>3. Kết quả AdmitResult luôn là 200 kể cả bị từ chối: outcome (ADMITTED, UNKNOWN, OTHER_CINEMA, OTHER_SHOWTIME, USED, CANCELLED) quyết MSG-44 đến MSG-49; chỉ lỗi hệ thống mới là 4xx, 5xx | DC-CheckTicketService.CheckTicket | Một lần quét bị từ chối là kết quả nghiệp vụ, không là lỗi HTTP | - |
| DC-AccountController.LoginCustomer | 1. body.login, body.password không rỗng, nếu rỗng thì 400 (View đã kiểm MSG-03).<br>2. session = LoginService.LoginCustomer.<br>3. claims = IF-07.VerifySession(session.token) chỉ để lấy role, cinemaId.<br>4. Trả DC-SessionDto (displayName = login đã nhập, Q-346) | DC-LoginService, IF-07.VerifySession | Mọi lỗi sai thông tin là một LOGIN_FAILED, không lộ trường nào sai (Q-131) | - |
| DC-AccountController.LoginStaff | Như LoginCustomer với LoginService.LoginStaff; subjectKind trả ADMIN khi role ADMINISTRATOR, ngược lại STAFF; STAFF_LOCKED (MSG-87) chỉ khi mật khẩu đúng | DC-LoginService | - | - |
| DC-AccountController.UpdateStaffAccess và nhóm staff.* | 1. staffId = path; displayedAt = ParseInstant(body.displayedAt).<br>2. Gọi operation tương ứng của ManageStaffAccountsService với displayedAt làm expectedChangedAt.<br>3. 204 cho khoá, mở khoá, đổi tên, đặt lại mật khẩu; 200 DC-StaffDto cho tạo và đổi quyền | DC-ManageStaffAccountsService | Mật khẩu chỉ nằm trong thân yêu cầu, không bao giờ vào log (DC-RequestDecoder không ghi thân) | - |
| DC-ReportController.GetCinemaReport | 1. view = query groupBy; from, to = QueryDate; thiếu một trong hai là tham số nil, service báo InvalidPeriod.<br>2. cinemaId = caller.CinemaId().<br>3. ViewCinemaReportService.ViewCinemaReport; báo cáo rỗng (IsEmpty) vẫn trả 200 để màn hình hiện MSG-116 | DC-ViewCinemaReportService | Cụm rạp lấy từ phiên, không tin query (P09 F7.12) | - |

Nguyên tắc cho handler còn lại: các bước 1 giải mã, 2 gọi một service, 3 đổi sang DTO; không có thuật toán nào khác nên không lập dòng riêng.

## F4. Bảng ánh xạ message --> operation

Message từ Form tới Controller của P07 đã được các Store của file frontend ánh xạ tới tuyến logic; bảng này nối tuyến tới handler của PKG-11. STT message P07 không đính kèm nên bảng ghi tên trách nhiệm (Vấn đề còn mở 2). Message đi lên (// notifyRefusal, // show...) là kiểu trả về hoặc mã lỗi của handler, ghi ở cột Operation.

| UC | STT message (P07) | Từ (AC/DC) | Đến (AC/DC) | Message phân tích (// tênTráchNhiệm) | Operation thiết kế |
|---|---|---|---|---|---|
| UC-001 | theo P07 | DC-RegisterAccountStore | DC-AccountController | // registerAccount | DC-AccountController.RegisterAccount; trả 201 {customerId} |
| UC-001 | theo P07 | DC-AccountController | DC-RegisterAccountStore | // rejectRegistration | Ngoại lệ: REGISTRATION_DATA_INVALID, DUPLICATE_CUSTOMER (422, 409) |
| UC-003 | theo P07 | DC-BrowseMoviesStore | DC-CatalogController | // viewMovieDetails, // startBrowsingMovies | DC-CatalogController.ListMovies, GetMovie |
| UC-004 | theo P07 | DC-BrowseShowtimesStore | DC-CatalogController | // startBrowsingByMovie, // startBrowsingByCinema, // findShowtimesByMovie, // findShowtimesByCinema | DC-CatalogController.ListMovieChoices, ListCinemaChoices, FindShowtimesByMovie, FindShowtimesByCinema |
| UC-005 | theo P07 | DC-HoldFlowStore | DC-BookingController | // confirmSeatSelection | DC-BookingController.HoldSeats |
| UC-005 | theo P07 | DC-HoldFlowStore | DC-BookingController | // cancelHold (luồng *a), mở lại lần giữ ghế | DC-BookingController.CancelHold, GetActiveHold, GetHold |
| UC-005 | theo P07 | DC-BookTicketsStore | DC-BookingController | // startOnlinePayment | DC-BookingController.StartOnlinePayment |
| UC-005 | theo P07 | DC-CounterBookTicketsStore | DC-BookingController | // confirmCashReceived | DC-BookingController.ConfirmCashReceived |
| UC-005 | theo P07 | DC-SeatMapSyncClient | DC-SeatMapStreamController | // showSeatMap, // updateSeatMap | DC-SeatMapStreamController.GetSeatMap, StreamSeatEvents |
| UC-005 | theo P07 | DC-HoldFlowStore | DC-CatalogController | // selectShowtime (chuẩn bị, Q-335) | DC-CatalogController.GetShowtime, FindOwnCinemaShowtimes, FindShowtimesByCinema |
| UC-005 | theo P07 | mọi Store | DC-AuthFilter | // checkCustomerLoggedIn | DC-AuthFilter.Require (khác lớp nhận: P10 cơ chế Bảo mật) |
| UC-007 | theo P07 | DC-ViewBookingHistoryStore | DC-TicketController | // startViewHistory, // viewBookingTickets | DC-TicketController.ListBookingHistory, GetBookingTickets |
| UC-008 | theo P07 | DC-CancelTicketStore | DC-TicketController | // requestCancellation | DC-TicketController.CancelOnlineTicket |
| UC-008 | theo P07 | DC-CounterCancelTicketStore | DC-TicketController | // findBookingTickets | DC-TicketController.FindCounterBooking |
| UC-008 | theo P07 | DC-CounterCancelTicketStore | DC-TicketController | // requestCancellation (quầy) | DC-TicketController.PrepareCashRefund (Tạm) |
| UC-008 | theo P07 | DC-CounterCancelTicketStore | DC-TicketController | // confirmCashRefunded | DC-TicketController.ConfirmCashRefund |
| UC-009 | theo P07 | DC-CheckTicketStore | DC-TicketController | // startChecking, // checkTicket | DC-TicketController.StartChecking, CheckTicket |
| UC-010 | theo P07 | DC-ManageMoviesStore | DC-ChainController | // startMovieEdit, // selectMovie, // submitMovie, // submitMovieChanges | DC-ChainController.ListManagedMovies, GetManagedMovie, CreateMovie, UpdateMovie |
| UC-011 | theo P07 | DC-ManageCinemasStore | DC-ChainController | // startCinemaEdit, // selectCinema, // submitCinema, // submitCinemaChanges | DC-ChainController.ListManagedCinemas, GetManagedCinema, CreateCinema, UpdateCinema |
| UC-012 | theo P07 | DC-ManageAuditoriumsStore | DC-PricingScheduleController | // startAuditoriumAddition, // selectAuditorium, // submitAuditorium, // submitAuditoriumRemoval | DC-PricingScheduleController.ListAuditoriums, GetAuditorium, CreateAuditorium, UpdateAuditorium, RemoveAuditorium |
| UC-013 | theo P07 | DC-ManagePriceListStore | DC-PricingScheduleController | // startPriceListSetup, // submitPriceEntry, // submitPriceEntryRemoval | DC-PricingScheduleController.ListPriceEntries, SavePriceEntry, RemovePriceEntry |
| UC-014 | theo P07 | DC-ScheduleShowtimesStore | DC-PricingScheduleController | // startScheduling, // prepareShowtimeEdit, // submitShowtime, // deleteShowtime | DC-PricingScheduleController.ListShowtimes, GetScheduleFormData, GetShowtimeEditForm, CreateShowtime, UpdateShowtime, DeleteShowtime |
| UC-015 | theo P07 | DC-ViewCinemaReportStore | DC-ReportController | // startCinemaReport | DC-ReportController.GetCinemaReport |
| UC-016 | theo P07 | DC-ViewChainReportStore | DC-ReportController | // startChainReport | DC-ReportController.GetChainReport |
| UC-017 | theo P07 | DC-ManageStaffAccountsStore | DC-AccountController | // startStaffAction, // startStaffCreation, // saveStaffAccount, // updateStaffAccount, // changeStaffStatus, // renameStaffAccount, // resetStaffAccountPassword | DC-AccountController.ListStaff, GetStaffChoices, GetStaff, CreateStaff, UpdateStaffAccess, LockStaff, UnlockStaff, RenameStaff, ResetStaffPassword |
| UC-001, UC-017 | theo P07 | DC-SessionStore | DC-AccountController | Đăng nhập hai điểm (Q-267, không là use case) | DC-AccountController.LoginCustomer, LoginStaff |

Các tuyến chuyển tới service không có message P07 gốc (Bổ sung): showtime.ownCinema, ticket.startChecking dùng cho soát vé đã có message; booking.activeHold, booking.getHold (P11a E-32 đến E-34, Q-341).

## F5. Bảng quan hệ

Quan hệ có gốc P08 giữa Form và Controller (R-01, R-02, R-06, R-16, R-17, R-19, R-25, R-29, R-32, R-71, R-73, R-75, R-79, R-82, R-84, R-86, R-90, R-96, R-101) đã được file frontend đổi thành Dependency qua IF-41 và không lặp lại ở đây. Quan hệ Controller với lớp dịch vụ là quan hệ mới do thiết kế, đều là tiêm phụ thuộc (A 0..* - B 1).

| ID | Lớp A | Lớp B | Loại | Multiplicity | Điều hướng | Lý do | Vai trò | Căn cứ hiển thị |
|---|---|---|---|---|---|---|---|---|
| R-370 | DC-AuthFilter | IF-07 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc; kiểm chữ ký, hạn mã phiên và vai trò | auth | field |
| R-371 | DC-AuthFilter | DC-AccessCheckService | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc; kiểm mốc truy cập nhân viên một lần mỗi yêu cầu (BR-101) | access | field |
| R-372 | DC-BookingController, DC-SeatMapStreamController, DC-TicketController, DC-PricingScheduleController, DC-CatalogController, DC-AccountController, DC-ReportController, DC-ChainController | IF-44 | Realization |  | A --> B | Hiện thực interface | | |
| R-373 | tám controller như R-372 | DC-AuthFilter | Association | A 8 - B 1 | A --> B | Thiết kế: mỗi controller bọc handler không công khai bằng cùng một bộ lọc | filter | field |
| R-374 | tám controller như R-372 | DC-HttpErrorMapper | Association | A 8 - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | errs | field |
| R-375 | tám controller như R-372 | DC-RequestDecoder | Association | A 8 - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | decoder | field |
| R-376 | DC-BookingController | DC-BookTicketsService | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | book | field |
| R-377 | DC-SeatMapStreamController | DC-SeatMapService | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | seatMap | field |
| R-378 | DC-SeatMapStreamController | DC-IpConnectionLimiter | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc; một bộ đếm dùng chung cho mọi kết nối SSE | limiter | field |
| R-379 | DC-SeatMapStreamController | DC-SseConnection | Dependency |  | A --> B | Tạo một SseConnection cho mỗi kết nối trong handler | | local |
| R-380 | DC-SseConnection | DC-SseStream | Dependency |  | A --> B | Nhận SseStream làm tham số của Run | | tham số |
| R-381 | DC-TicketController | DC-ViewBookingHistoryService | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | history | field |
| R-382 | DC-TicketController | DC-CancelTicketService | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | cancel | field |
| R-383 | DC-TicketController | DC-CheckTicketService | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | check | field |
| R-384 | DC-PricingScheduleController | DC-ManagePriceListService | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | prices | field |
| R-385 | DC-PricingScheduleController | DC-ScheduleShowtimesService | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | showtimes | field |
| R-386 | DC-PricingScheduleController | DC-ManageAuditoriumsService | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | auditoriums | field |
| R-387 | DC-CatalogController | DC-BrowseMoviesService | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | movies | field |
| R-388 | DC-CatalogController | DC-BrowseShowtimesService | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | showtimes | field |
| R-389 | DC-AccountController | DC-RegisterAccountService | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | register | field |
| R-390 | DC-AccountController | DC-LoginService | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | login | field |
| R-391 | DC-AccountController | DC-ManageStaffAccountsService | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | staff | field |
| R-392 | DC-AccountController | IF-07 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc; đọc claims của phiên vừa cấp để trả vai trò, cụm rạp | auth | field |
| R-393 | DC-ReportController | DC-ViewCinemaReportService | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | cinemaReport | field |
| R-394 | DC-ReportController | DC-ViewChainReportService | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | chainReport | field |
| R-395 | DC-ChainController | DC-ManageMoviesService | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | movies | field |
| R-396 | DC-ChainController | DC-ManageCinemasService | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | cinemas | field |
| R-397 | DC-AuthFilter | DC-CallerContext | Dependency |  | A --> B | Dựng và trả cho handler | | local |
| R-398 | IF-44 | DC-RouteSpec | Dependency |  | A --> B | Routes trả []RouteSpec | | tham số, kiểu trả về |
| R-399 | DC-HttpErrorMapper | DC-ApiErrorBody | Dependency |  | A --> B | Classify trả ApiErrorBody | | kiểu trả về |

Dependency vào kiểu Domain trong chữ ký (DC-ActorContext, DC-HolderRef, các kiểu định danh, DTO nội bộ của service) không lập dòng riêng: ghi ở mục 0.5, F9 và Q-342.

## F6. State machine

### ST-19. Kết nối SSE sơ đồ ghế (DC-SseConnection)

F6.1. Bảng trạng thái

| ST | Lớp | Trạng thái | Mô tả / điều kiện nhận biết | entry | do | exit |
|---|---|---|---|---|---|---|
| ST-19 | DC-SseConnection | Opening | state = OPENING: đã nhận yêu cầu, chưa ghi tiêu đề SSE; có thể đang chờ OpenStream | - | - | - |
| ST-19 | DC-SseConnection | Streaming | state = STREAMING: đã ghi tiêu đề, đang chuyển khung và nhịp tim | ghi tiêu đề SSE, Flush | chờ khung, nhịp tim mỗi 15 giây | - |
| ST-19 | DC-SseConnection | Closed | state = CLOSED: không còn ghi gì | gọi stream.close đúng một lần | - | - |

F6.2. Bảng chuyển trạng thái

| ST | Lớp | Trạng thái | Sự kiện | Guard | Hành động | Trạng thái đích | STT | Operation tương ứng | Nguồn |
|---|---|---|---|---|---|---|---|---|---|
| ST-19 | DC-SseConnection | (initial) | accept | | / state = OPENING | Opening | 1 | DC-SseConnection.NewSseConnection | P09 F7.5 |
| ST-19 | DC-SseConnection | Opening | slotDenied | [TryAcquire trả false] | / trả 429 SSE_LIMIT | Closed | 2 | DC-SeatMapStreamController.StreamSeatEvents | P09 F7.5 giới hạn kết nối mỗi IP |
| ST-19 | DC-SseConnection | Opening | openFailed | [OpenStream trả lỗi] | / trả 503 HUB_UNAVAILABLE hoặc 404; release | Closed | 3 | DC-SeatMapStreamController.StreamSeatEvents | P11b SS-03 lỗi |
| ST-19 | DC-SseConnection | Opening | streamOpened | [OpenStream thành công] | / ghi tiêu đề SSE | Streaming | 4 | DC-SseConnection.Run | P09 F7.5 điểm 4 |
| ST-19 | DC-SseConnection | Streaming | frame(f) | [kênh frames còn mở, ghi thành công] | / writeFrame(f), Flush | Streaming | 5 | DC-SseConnection.writeFrame | P09 F7.5 điểm 3, 6 |
| ST-19 | DC-SseConnection | Streaming | heartbeatTick | [ghi thành công] | / writeHeartbeat | Streaming | 6 | DC-SseConnection.writeHeartbeat | P09 F7.5 nhịp tim 15 giây |
| ST-19 | DC-SseConnection | Streaming | clientGone | [ctx của yêu cầu bị huỷ] | / stream.close, release | Closed | 7 | DC-SseConnection.Run | P09 F7.5 |
| ST-19 | DC-SseConnection | Streaming | channelClosed | [kênh frames đóng: hàng đợi 256 đầy hoặc dịch vụ dừng] | / stream.close, release | Closed | 8 | DC-SseConnection.Run | P09 F7.5 (đầy thì đóng để trình duyệt nối lại) |
| ST-19 | DC-SseConnection | Streaming | writeFailed | [writeFrame hoặc writeHeartbeat trả lỗi, kể cả quá hạn ghi 10 giây] | / stream.close, release | Closed | 9 | DC-SseConnection.Run | Thiết kế: trình duyệt chậm không giữ goroutine |

Sự kiện bị từ chối

| ST | Trạng thái | Sự kiện | Xử lý |
|---|---|---|---|
| ST-19 | Closed | frame, heartbeatTick, clientGone, channelClosed, writeFailed | Bỏ qua (Run đã thoát, không còn nơi nhận sự kiện) |
| ST-19 | Opening | frame, heartbeatTick | Không xảy ra: vòng lặp chỉ bắt đầu sau streamOpened |
| ST-19 | Streaming | slotDenied, openFailed, streamOpened | Không xảy ra: chỉ phát sinh ở Opening |

F6.3. Ánh xạ về mô hình lớp

| ST | Thuộc tính biểu diễn trạng thái | Kiểu (enumeration) | Operation được thêm/sửa |
|---|---|---|---|
| ST-19 | DC-SseConnection.state | DC-SseConnectionState (OPENING, STREAMING, CLOSED) | Run, writeFrame, writeHeartbeat, State (Bổ sung: quan sát hậu điều kiện) |

F6.4. Sơ đồ state machine. Closed là cuối vòng đời của một đối tượng một lần dùng, không có sự kiện lưu trữ hay xoá nên không vẽ (final). Không có file diagrams/P12-state-DC-SseConnection.drawio: ba trạng thái và chín chuyển đủ đọc ở F6.2 (Vấn đề còn mở 5).

Quy tắc đồng thời (M7): ST-19 không giữ khoá cơ sở dữ liệu. Mọi trạng thái trung gian (Opening, Streaming) có chuyển ra do ba nguyên nhân tự nhiên (trình duyệt đi, kênh đóng, ghi lỗi), không phụ thuộc cơ chế hồi phục riêng. Trình duyệt tự nối lại bằng Last-Event-ID (P09 F7.5).

## F7. Bảng thuộc tính

Controller không có thuộc tính dữ liệu ngoài các phụ thuộc tiêm, mà các phụ thuộc này là association (F5) nên không lặp lại.

| DC | Visibility | Tên | Kiểu | Multiplicity | Mặc định | Ràng buộc | Phạm vi | Derived | Nguồn | Mô tả |
|---|---|---|---|---|---|---|---|---|---|---|
| DC-AuthFilter | - | requestDeadline | time.Duration | 1 | 14s | {readOnly, nhỏ hơn timeoutMs 15s của DC-FetchApiClient} | Instance | Không | Thiết kế: Q-348 | Thời hạn ctx cho mỗi yêu cầu |
| DC-AuthFilter | - | bearerPrefix | string | 1 | "Bearer " | {readOnly} | Classifier | Không | Thiết kế: DC-SessionStore.authHeader | Tiền tố tiêu đề Authorization |
| DC-RequestDecoder | - | maxBodyBytes | int | 1 | 262144 | {> 0} | Instance | Không | Thiết kế: Q-348 | Kích thước thân tối đa |
| DC-IpConnectionLimiter | - | maxPerIp | int | 1 | 10 | {> 0} | Instance | Không | P09 F7.5 | Số kết nối SSE tối đa mỗi IP trên một bản backend |
| DC-IpConnectionLimiter | - | active | map[string]int | 1 | rỗng | {đếm không âm; xoá khoá khi về 0} | Instance | Không | Thiết kế | Số kết nối đang mở theo IP |
| DC-IpConnectionLimiter | - | mu | sync.Mutex | 1 | - | - | Instance | Không | Thiết kế | Bảo vệ active |
| DC-IpConnectionLimiter | - | trustedForwardedFor | bool | 1 | false | {cấu hình} | Instance | Không | Q-349 | Có tin tiêu đề X-Forwarded-For của bộ cân bằng tải |
| DC-SseConnection | - | state | DC-SseConnectionState | 1 | OPENING | ST-19 | Instance | Không | ST-19 | Trạng thái kết nối |
| DC-SseConnection | - | heartbeatInterval | time.Duration | 1 | 15s | {> 0} | Instance | Không | P09 F7.5 | Chu kỳ nhịp tim |
| DC-SseConnection | - | writeTimeout | time.Duration | 1 | 10s | {> 0} | Instance | Không | Thiết kế: trình duyệt chậm bị cắt, hàng đợi 256 của dịch vụ không chờ mãi | Hạn cho mỗi lần ghi |
| DC-SseConnection | - | newTicker | func(time.Duration) (<-chan time.Time, func()) | 1 | time.NewTicker bọc lại | {readOnly} | Instance | Không | Thiết kế: Bước 2.6 | Tiêm để X2 thử nhịp tim không chờ thật |

## F8. Class diagram

| Sơ đồ | Phạm vi (PKG / UC) | File .drawio | Số lớp |
|---|---|---|---|
| P12-class-PKG-11 | PKG-11 (kèm lớp tham chiếu của PKG-13, PKG-15 đến PKG-19, PKG-26, PKG-30) | diagrams/P12-class-PKG-11.drawio | 14 phần tử của PKG-11 và 16 tham chiếu |

Không lập sơ đồ theo UC: mỗi UC chỉ có một controller và một đến ba service, đã đọc được ở sơ đồ package. Controller chỉ vẽ tên handler (ngăn operation), không vẽ ngăn thuộc tính vì không có (F7). Node ghi chú NOTE-ctrl gom bốn quan hệ R-372 đến R-375 chung cho tám controller để tránh 32 cạnh; kiểu phụ trợ (DC-CallerContext, DC-RouteSpec, DC-ApiErrorBody) không vẽ nên R-397 đến R-399 không có cạnh.

Node:

| ID | Loại | Nhãn | Stereotype | Thuộc về (PKG) | Ghi chú | x | y | w | h |
|---|---|---|---|---|---|---|---|---|---|
| DC-BookingController | Class | BookingController | «boundary» | PKG-11 |  | 0 | 300 | 320 | 200 |
| DC-BookTicketsService | Class | BookTicketsService | «service» | PKG-13 | tham chiếu | 0 | 60 | 170 | 60 |
| DC-SeatMapStreamController | Class | SeatMapStreamController | «boundary» | PKG-11 |  | 380 | 300 | 320 | 140 |
| DC-SeatMapService | Class | SeatMapService | «service» | PKG-13 | tham chiếu | 380 | 60 | 170 | 60 |
| DC-TicketController | Class | TicketController | «boundary» | PKG-11 |  | 760 | 300 | 320 | 240 |
| DC-ViewBookingHistoryService | Class | ViewBookingHistoryService | «service» | PKG-15 | tham chiếu | 760 | 60 | 170 | 60 |
| DC-CancelTicketService | Class | CancelTicketService | «service» | PKG-15 | tham chiếu | 940 | 60 | 170 | 60 |
| DC-CheckTicketService | Class | CheckTicketService | «service» | PKG-15 | tham chiếu | 1120 | 60 | 170 | 60 |
| DC-PricingScheduleController | Class | PricingScheduleController | «boundary» | PKG-11 |  | 1140 | 300 | 320 | 330 |
| DC-ManagePriceListService | Class | ManagePriceListService | «service» | PKG-16 | tham chiếu | 1140 | 60 | 170 | 60 |
| DC-ScheduleShowtimesService | Class | ScheduleShowtimesService | «service» | PKG-16 | tham chiếu | 1320 | 60 | 170 | 60 |
| DC-ManageAuditoriumsService | Class | ManageAuditoriumsService | «service» | PKG-16 | tham chiếu | 1500 | 60 | 170 | 60 |
| DC-CatalogController | Class | CatalogController | «boundary» | PKG-11 |  | 1520 | 300 | 320 | 240 |
| DC-BrowseMoviesService | Class | BrowseMoviesService | «service» | PKG-17 | tham chiếu | 1520 | 60 | 170 | 60 |
| DC-BrowseShowtimesService | Class | BrowseShowtimesService | «service» | PKG-17 | tham chiếu | 1700 | 60 | 170 | 60 |
| DC-AccountController | Class | AccountController | «boundary» | PKG-11 |  | 1900 | 300 | 320 | 300 |
| DC-RegisterAccountService | Class | RegisterAccountService | «service» | PKG-19 | tham chiếu | 1900 | 60 | 170 | 60 |
| DC-LoginService | Class | LoginService | «service» | PKG-19 | tham chiếu | 2080 | 60 | 170 | 60 |
| DC-ManageStaffAccountsService | Class | ManageStaffAccountsService | «service» | PKG-19 | tham chiếu | 2260 | 60 | 170 | 60 |
| DC-ReportController | Class | ReportController | «boundary» | PKG-11 |  | 2280 | 300 | 320 | 140 |
| DC-ViewCinemaReportService | Class | ViewCinemaReportService | «service» | PKG-18 | tham chiếu | 2280 | 60 | 170 | 60 |
| DC-ViewChainReportService | Class | ViewChainReportService | «service» | PKG-18 | tham chiếu | 2460 | 60 | 170 | 60 |
| DC-ChainController | Class | ChainController | «boundary» | PKG-11 |  | 2660 | 300 | 320 | 240 |
| DC-ManageMoviesService | Class | ManageMoviesService | «service» | PKG-30 | tham chiếu | 2660 | 60 | 170 | 60 |
| DC-ManageCinemasService | Class | ManageCinemasService | «service» | PKG-30 | tham chiếu | 2840 | 60 | 170 | 60 |
| DC-AuthFilter | Class | AuthFilter | «service» | PKG-11 |  | 0 | 750 | 360 | 150 |
| DC-HttpErrorMapper | Class | HttpErrorMapper | «utility» | PKG-11 |  | 440 | 750 | 360 | 120 |
| DC-RequestDecoder | Class | RequestDecoder | «utility» | PKG-11 |  | 880 | 750 | 360 | 170 |
| DC-IpConnectionLimiter | Class | IpConnectionLimiter | «service» | PKG-11 |  | 1320 | 750 | 360 | 150 |
| DC-SseConnection | Class | SseConnection | «service» | PKG-11 |  | 1760 | 750 | 360 | 190 |
| IF-44 | Interface | IRouteGroup | «interface» | PKG-11 |  | 2200 | 750 | 260 | 110 |
| IF-07 | Interface | IAuthenticator | «interface» | PKG-26 | tham chiếu | 0 | 1050 | 170 | 60 |
| DC-AccessCheckService | Class | AccessCheckService | «service» | PKG-19 | tham chiếu | 440 | 1050 | 170 | 60 |
| DC-SseStream | Class | SseStream | «value object» | PKG-13 | tham chiếu | 1760 | 1050 | 170 | 60 |
| NOTE-ctrl | Note | Mỗi trong 8 controller: R-372 đến R-375 |  | PKG-11 | gom cạnh dùng chung | 1000 | 1050 | 340 | 60 |

Edge (Nguồn là Lớp A theo F5):

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| R-370 | DC-AuthFilter | IF-07 | Association | A 0..* - B 1 | Kiểm chữ ký và hạn của mã phiên |
| R-371 | DC-AuthFilter | DC-AccessCheckService | Association | A 0..* - B 1 | Đối chiếu mốc truy cập của nhân viên |
| R-372 | NOTE-ctrl | IF-44 | Realization |  | Tám controller hiện thực IRouteGroup |
| R-373 | NOTE-ctrl | DC-AuthFilter | Association | A 8 - B 1 | Tám controller dùng AuthFilter |
| R-374 | NOTE-ctrl | DC-HttpErrorMapper | Association | A 8 - B 1 | Tám controller dùng HttpErrorMapper |
| R-375 | NOTE-ctrl | DC-RequestDecoder | Association | A 8 - B 1 | Tám controller dùng RequestDecoder |
| R-376 | DC-BookingController | DC-BookTicketsService | Association | A 0..* - B 1 | Tiêm phụ thuộc |
| R-377 | DC-SeatMapStreamController | DC-SeatMapService | Association | A 0..* - B 1 | Tiêm phụ thuộc |
| R-378 | DC-SeatMapStreamController | DC-IpConnectionLimiter | Association | A 0..* - B 1 | Giới hạn 10 kết nối SSE mỗi địa chỉ IP |
| R-379 | DC-SeatMapStreamController | DC-SseConnection | Dependency |  | Tạo một SseConnection cho mỗi kết nối |
| R-380 | DC-SseConnection | DC-SseStream | Dependency |  | Nhận SseStream làm tham số của Run |
| R-381 | DC-TicketController | DC-ViewBookingHistoryService | Association | A 0..* - B 1 | Tiêm phụ thuộc |
| R-382 | DC-TicketController | DC-CancelTicketService | Association | A 0..* - B 1 | Tiêm phụ thuộc |
| R-383 | DC-TicketController | DC-CheckTicketService | Association | A 0..* - B 1 | Tiêm phụ thuộc |
| R-384 | DC-PricingScheduleController | DC-ManagePriceListService | Association | A 0..* - B 1 | Tiêm phụ thuộc |
| R-385 | DC-PricingScheduleController | DC-ScheduleShowtimesService | Association | A 0..* - B 1 | Tiêm phụ thuộc |
| R-386 | DC-PricingScheduleController | DC-ManageAuditoriumsService | Association | A 0..* - B 1 | Tiêm phụ thuộc |
| R-387 | DC-CatalogController | DC-BrowseMoviesService | Association | A 0..* - B 1 | Tiêm phụ thuộc |
| R-388 | DC-CatalogController | DC-BrowseShowtimesService | Association | A 0..* - B 1 | Tiêm phụ thuộc |
| R-389 | DC-AccountController | DC-RegisterAccountService | Association | A 0..* - B 1 | Tiêm phụ thuộc |
| R-390 | DC-AccountController | DC-LoginService | Association | A 0..* - B 1 | Tiêm phụ thuộc |
| R-391 | DC-AccountController | DC-ManageStaffAccountsService | Association | A 0..* - B 1 | Tiêm phụ thuộc |
| R-392 | DC-AccountController | IF-07 | Association | A 0..* - B 1 | Đọc claims của phiên vừa cấp để trả vai trò, cụm rạp |
| R-393 | DC-ReportController | DC-ViewCinemaReportService | Association | A 0..* - B 1 | Tiêm phụ thuộc |
| R-394 | DC-ReportController | DC-ViewChainReportService | Association | A 0..* - B 1 | Tiêm phụ thuộc |
| R-395 | DC-ChainController | DC-ManageMoviesService | Association | A 0..* - B 1 | Tiêm phụ thuộc |
| R-396 | DC-ChainController | DC-ManageCinemasService | Association | A 0..* - B 1 | Tiêm phụ thuộc |
| R-397 | DC-AuthFilter | DC-CallerContext | Dependency |  | Dựng và trả DC-CallerContext cho handler (không vẽ: kiểu phụ trợ) |
| R-398 | IF-44 | DC-RouteSpec | Dependency |  | Routes trả []RouteSpec (không vẽ) |
| R-399 | DC-HttpErrorMapper | DC-ApiErrorBody | Dependency |  | Classify trả ApiErrorBody (không vẽ) |

## F9. Gán package và kiểm tra phụ thuộc package

| PKG | Lớp (DC) | Phụ thuộc vào PKG (suy từ F5) | Hợp lệ theo P09 (Có / Không: lý do) |
|---|---|---|---|
| PKG-11 | DC-AuthFilter, DC-BookingController, DC-SeatMapStreamController, DC-TicketController, DC-PricingScheduleController, DC-CatalogController, DC-AccountController, DC-ReportController, DC-ChainController, DC-HttpErrorMapper, DC-RequestDecoder, DC-IpConnectionLimiter, DC-SseConnection, IF-44 | PKG-13, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-30 (Presentation --> Application); PKG-26 (ngoại lệ kiểm mã phiên) | Có: khớp P09 F6 |
| PKG-11 | như trên | PKG-27, PKG-28 (kiểu định danh, kiểu giá trị, kiểu lỗi trong chữ ký công khai của Application) | Không: P09 F6 cấm Presentation --> Domain. Khắc phục: (a) áp RV-02 (SY-23) để service chỉ trao DTO và kiểu thuần; hoặc (b) P09 F6 thêm ngoại lệ hẹp cho PKG-11 --> PKG-27, PKG-28 (Q-342). Ghi ở Vấn đề còn mở 1 |
| PKG-11 | như trên | không phụ thuộc PKG-21, PKG-22, PKG-24, PKG-25 | Có: Presentation không phụ thuộc Services khác PKG-26 |

Không có phụ thuộc vòng: không package nào phụ thuộc ngược PKG-11. Tám controller đều public cho chương trình chính (chỉ hàm New và Routes); DC-AuthFilter, DC-HttpErrorMapper, DC-RequestDecoder, DC-IpConnectionLimiter, DC-SseConnection là package-private (P10 F5 đã ghi DC-AuthFilter package-private; bốn lớp còn lại thêm vào P10 F5). Gán package: tám controller của hai tác nhân khác nhau (khách và nhân viên) nằm cùng PKG-11 vì cùng lý do thay đổi là hợp đồng REST với trình duyệt (P10 F4); điều này khác quy tắc "không gộp hai tác nhân vào một package" của giao diện React vì phía máy chủ không có giao diện riêng cho từng tác nhân.

## F10. Design pattern đã áp dụng

| Pattern | Vấn đề trong thiết kế này | Lớp tham gia (vai trò trong pattern) | Lý do chọn | Phương án đơn giản hơn đã xét |
|---|---|---|---|---|
| Decorator (middleware) | Mọi tuyến không công khai cần cùng bước kiểm phiên, vai trò, deadline trước handler | DC-AuthFilter.Require (decorator), handler của controller (thành phần được bọc) | Một nơi giữ BR-101 và thứ tự kiểm; controller không thể quên kiểm phiên vì tuyến được đăng ký qua DC-RouteSpec có allowedRoles | Mỗi handler tự gọi kiểm phiên: 52 chỗ lặp, một chỗ sót là lỗ hổng |
| Facade | Trình duyệt cần một mặt REST theo nhóm chức năng trên 15 service | Tám controller (facade), các service Application | Mỗi nhóm một controller khớp với P10 F4 | Một controller duy nhất: god class 60 handler |
| Adapter | Phần dịch giữa lỗi nghiệp vụ và HTTP | DC-HttpErrorMapper | Bảng lỗi một nơi, thử bảng không cần HTTP | switch lỗi trong từng handler |
| Observer (đã có ở PKG-13, SS-03) | Đẩy sự kiện đổi ghế | DC-SseConnection chỉ là bên nhận kênh khung | Controller không đăng ký bộ nhận, chỉ đọc kênh do DC-SeatMapService trả (P10 F3) | Thăm dò định kỳ bị loại ở P09 F3 |

## Xử lý mục chuyển từ bước trước

| Nguồn | Mục | Cách xử lý ở file này | Trạng thái |
|---|---|---|---|
| _sync-log.md | SY-23 (X1 RV-02, CQ-9): DTO thay kiểu miền ở chữ ký công khai PKG-13, PKG-15, chờ thiết kế PKG-11 | PKG-11 đã có DTO phía dây (F1b) và controller làm phép dịch; service vẫn trao kiểu Domain. Chưa đổi chữ ký service; chọn giữa áp RV-02 hoặc ngoại lệ P09 F6 là Q-342 | Đã xử lý một phần ở P12 PKG-11 1.0: PKG-11 đã thiết kế; chờ chủ dự án chốt Q-342 |
| P12 frontend | Q-332 (bảng tuyến REST) | Chốt ở F2a: 60 tuyến, cộng payment.status của PKG-12; tên tuyến logic giữ như file frontend | Đã chốt theo đề xuất |
| P12 frontend | Q-333 (requestId khi mất mạng) | Mục 0.3: requestId UUID bắt buộc, replayed, booking.activeHold | Đã chốt theo đề xuất |
| P12 frontend | Q-341 (đối chiếu thu tiền mặt) | booking.getHold trả holdStatus, bookingCode; counter.findBooking nạp vé | Đã chốt theo đề xuất; chờ đề xuất sửa lõi (Q-343) |
| P12 frontend | Q-335 (danh sách suất chiếu) | showtime.ownCinema, browse.showtimesByCinema | Đã chốt theo đề xuất |
| P12 lõi | Mục "PKG-11 không đổi so với P10 1.5 nên chưa chi tiết hoá" | File này chi tiết hoá 8 controller và DC-AuthFilter | Đã xử lý |

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Người quyết | Đề xuất |
|---|---|---|---|---|---|
| Q-342 | PKG-11 được phụ thuộc kiểu Domain trong chữ ký công khai của Application (PKG-27, PKG-28) hay service đổi sang DTO và kiểu thuần (RV-02)? | Mục 0.5, F9, mọi handler; P09 F6, P10 F4 | P09 F6 cấm Presentation --> Domain, nhưng chữ ký công khai của PKG-13 đến PKG-19, PKG-30 dùng kiểu Domain; SY-23 chưa quyết | Nhóm dự án | Ngoại lệ hẹp: PKG-11 --> PKG-27, PKG-28 chỉ để dùng kiểu định danh, giá trị, lỗi và getter chỉ đọc, không gọi operation nghiệp vụ; áp RV-02 sau Project 3 nếu còn thời gian |
| Q-343 | Các service của lõi có thêm operation tìm lần giữ ghế theo holdRef và theo người giữ ghế, và có nhận holdRef thay holdId không? | booking.activeHold, booking.getHold, booking.cancelHold, payment.start, booking.confirmCash; DC-HoldResult | Trình duyệt chỉ có holdRef (chuỗi), service lõi nhận holdId (SeatHoldId); PKG-11 không được gọi kho IF-17 | Nhóm dự án (chủ P12 lõi) | Đổi GetHold, CancelHold, StartOnlinePayment, ConfirmCashReceived nhận holdRef string; thêm FindActiveHold(ctx, by HolderRef) (HoldResult, bool, error); DC-HoldResult thêm holdStatus, bookingCode, serverTime (cùng Q-341); DC-SeatSnapshot thêm rowCode, seatNumber, seatType cho mỗi ghế để vẽ sơ đồ; DC-ActorKind thêm MANAGER vì DC-ManagePriceListService, DC-ScheduleShowtimesService, DC-ManageAuditoriumsService nhận ActorContext của quản lý cụm rạp |
| Q-344 | Bước "yêu cầu huỷ" của quầy (P07 UC-008 // requestCancellation) kiểm gì ở máy chủ trước khi hiện số tiền hoàn mặt? | counter.cancelPrepare, DC-CounterCancelTicketStore.cancelTicket | DC-CancelTicketService chỉ có FindBooking và ConfirmCashRefund; luồng 1b.1, 1c.1 cần từ chối trước khi quầy hoàn tiền | Nhóm dự án (chủ P12 lõi) | Thêm DC-CancelTicketService.PrepareCashRefund(ctx, ticketId, clerk ActorContext) (CashRefundView, error): chỉ đọc, kiểm kênh, trạng thái, hạn huỷ, trả số tiền 70 phần trăm; không khoá |
| Q-345 | Tuyến showtime.get (thông tin một suất chiếu cho màn chọn ghế) lấy từ service nào? | showtime.get, DC-HoldFlowStore.openShowtime, DC-ShowtimeDto | Không có operation đọc một suất chiếu theo mã cho khách; BrowseShowtimesService chỉ liệt kê | Nhóm dự án (chủ P12 PKG-17) | Thêm DC-BrowseShowtimesService.GetShowtime(ctx, showtimeId) (ShowtimeInfo, error) trả thêm lastChangedAt; không đòi đăng nhập |
| Q-346 | displayName trong phiên là gì khi DC-IssuedSession chỉ có token và expiresAt? | DC-SessionDto.displayName, DC-SessionStore | DC-SessionInfo cần displayName; LoginService không trả họ tên | Nhóm dự án | Dùng chính định danh đã nhập (email hoặc số điện thoại) làm displayName; không đổi LoginService |
| Q-347 | DC-CancelTicketStore.loadCancellableTickets lấy từ đâu? | DC-CancelTicketStore, SCR-07 | P07 UC-008 không có message tải danh sách; không có service trả vé còn huỷ được | Nhóm dự án (chủ P12 frontend) | Không thêm tuyến: Store gọi history.list rồi history.get cho lần đặt khách chọn, lọc vé trực tuyến chưa huỷ chưa dùng ở trình duyệt; máy chủ vẫn quyết ở ticket.cancel |
| Q-348 | Hạn thời gian và kích thước của yêu cầu REST là bao nhiêu? | DC-AuthFilter.requestDeadline, DC-RequestDecoder.maxBodyBytes | P09 chỉ nêu thời gian chờ cổng 30 giây (BR-43), NFR-06 và timeoutMs 15 giây phía trình duyệt | Nhóm dự án | Deadline 14 giây (nhỏ hơn 15 giây của trình duyệt), thân tối đa 256 KiB, SSE không deadline |
| Q-349 | Giới hạn 10 kết nối SSE mỗi IP tính theo IP nào khi có bộ cân bằng tải, và có gộp giữa các bản backend không? | DC-IpConnectionLimiter | P09 F7.5 nêu khoảng 10 mỗi IP nhưng không nêu cách lấy IP và phạm vi | Nhóm dự án | Mỗi bản backend đếm riêng trong bộ nhớ; lấy IP từ X-Forwarded-For của bộ cân bằng tải khi cấu hình tin cậy, ngược lại RemoteAddr; vượt thì 429 |
| Q-350 | Phân loại mã HTTP cho lỗi nghiệp vụ (409 so với 422) và cho đăng nhập sai (401) | F2b, DC-HttpErrorMapper; DC-FetchApiClient chỉ coi SESSION_INVALID và SESSION_EXPIRED là hết phiên | P09, P11a không nêu mã HTTP | Nhóm dự án | 409 khi trạng thái hiện tại hoặc dữ liệu đã đổi (tải lại rồi làm tiếp); 422 khi dữ liệu nhập vi phạm quy tắc (sửa dữ liệu); LOGIN_FAILED là 401 nhưng không là SESSION_INVALID nên không xoá phiên; SESSION_EXPIRED không phát riêng vì IF-07.VerifySession không phân biệt, mọi lỗi phiên là SESSION_INVALID |
| Q-351 | SPA và API có cùng nguồn gốc không, và mã phiên đặt ở tiêu đề hay cookie? | Mục 0.3, DC-AuthFilter | P09 F7.1 chỉ ghi REST qua HTTPS và mã phiên gửi kèm mỗi yêu cầu | Nhóm dự án | Cùng nguồn gốc (bộ cân bằng tải định tuyến /api); tiêu đề Authorization Bearer; không cookie nên không CORS, không CSRF |

## Giả định

Không có (chế độ NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P12 lõi | DC-BookTicketsService.GetHold, CancelHold, StartOnlinePayment, ConfirmCashReceived; DC-HoldResult; DC-SeatSnapshot; DC-ActorKind | Q-343: nhận holdRef, thêm FindActiveHold, holdStatus, bookingCode, serverTime, thuộc tính ghế, vai trò MANAGER | Sửa chữ ký và kiểu như Q-343; PKG-11 dùng chữ ký đề xuất, các tuyến booking.* và seatmap.snapshot là Tạm tới lúc đó |
| P12 lõi | DC-CancelTicketService | Q-344: thiếu PrepareCashRefund | Thêm operation chỉ đọc |
| P12 PKG-17 | DC-BrowseShowtimesService | Q-345: thiếu GetShowtime | Thêm operation |
| P12 PKG-19 | DC-LoginService, DC-IssuedSession | Q-346: không mang họ tên | Không đổi; ghi displayName là định danh nhập |
| P12 frontend | DC-CancelTicketStore.loadCancellableTickets | Q-347: không có tuyến riêng | Gọi history.list và history.get |
| P12 frontend | DC-FetchApiClient.routeTable; DC-SessionStore.expire | Q-332 đã chốt; Q-350: chỉ SESSION_INVALID được phát | Điền routeTable theo F2a (60 tuyến cộng payment.status); coi SESSION_EXPIRED là dự phòng; Store đọc detail.holdStatus của HOLD_NOT_ACTIVE |
| P10 | F3 bảng cơ chế kiến trúc, F4, F5 | Phần tử mới của PKG-11: DC-HttpErrorMapper, DC-RequestDecoder, DC-IpConnectionLimiter, DC-SseConnection, IF-44; kiểu phụ trợ DTO; ghi DC-CatalogController thêm GetShowtime, FindOwnCinemaShowtimes | Thêm vào bảng phần tử mới, cột Phần tử chứa của PKG-11 (visibility package-private trừ IF-44 và tám controller) |
| P10, P09 | F4, F6 (PKG-11) | Q-342: cạnh PKG-11 --> PKG-27, PKG-28 | Ghi ngoại lệ hẹp hoặc áp RV-02 |
| P09 | F7.5 | IP của kết nối SSE (Q-349) | Ghi cách lấy IP và giới hạn mỗi bản backend |
| P11a | SCR-01, SCR-21 và các màn hình dùng MSG | MSG theo mã lỗi (F2b) | Đối chiếu bảng F2b khi viết ca kiểm thử giao diện |
| Chạy lại | X2, X3 | PKG-11 mới có thiết kế, SY-23 đổi trạng thái | X2 thiết kế ca cho DC-AuthFilter.Require, DC-HttpErrorMapper.Classify, ST-19; X3 cập nhật dòng SY-23 trong _sync-log.md (file này không sửa) |

## Vấn đề còn mở

1. Phụ thuộc PKG-11 --> PKG-27, PKG-28 vi phạm P09 F6 cho tới khi chốt Q-342 (F9).
2. P07 không đính kèm theo yêu cầu: F4 ghi tên trách nhiệm, cột STT message là "theo P07"; khi có P07 điền STT.
3. Năm tuyến (booking.activeHold, counter.cancelPrepare, showtime.get và các tuyến phụ thuộc đổi chữ ký holdRef của booking.*, seatmap.snapshot) là Tạm tới khi lõi và PKG-17 nhận đề xuất (Q-343 đến Q-345); [Target] 7 đạt ở mức tên trách nhiệm.
4. DC-TicketController gom ba UC (UC-007, UC-008, UC-009) với 8 handler; vẫn dưới 15 đến 20 operation public nên giữ (Q-340 của frontend cùng nhóm vé).
5. Không vẽ file P12-state-DC-SseConnection.drawio: ba trạng thái (F6.4).
6. Mã IF-45, IF-46 của dải được cấp không dùng: không có interface nào khác có lý do (interface phía người dùng của service sẽ là realization đi lên layer, bị cấm bởi F9).
7. Ca đo NFR-06 (giữ ghế p95 2 giây) và NFR-08, NFR-09 (3 giây) phụ thuộc deadline 14 giây và SSE, chỉ kiểm được ở ca đo T1 đến T7 của P09.
8. Nhật ký không ghi thân yêu cầu (mật khẩu), chỉ ghi tuyến, mã trạng thái và thời gian; cơ chế log thuộc chương trình chính ngoài mô hình package.
