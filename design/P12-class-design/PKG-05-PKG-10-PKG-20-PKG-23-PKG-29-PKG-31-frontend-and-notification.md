# P12 - Thiết kế lớp - Giao diện React, thông báo email và đồng bộ sơ đồ ghế - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P12 |
| Phiên bản | 1.2 |
| Thay đổi 1.2 | Đồng bộ X3 lần 6 (design/_sync-log.md): thêm DC-RequestStoreBase, DC-ManagedListStore, DC-ReportStoreBase (RV-19, R-498 đến R-507); đổi tên DC-SeatMapState thành DC-SeatMapGrid, DC-ReportRequest thành DC-ReportFormInput, DC-CashRefundView thành DC-CounterCashRefundView (RV-23); thêm IF-48 ISessionSource, DC-FetchApiClient không còn phụ thuộc DC-SessionStore (RV-24, R-508, R-509) |
| Đầu vào đã dùng | 00-Conventions.md; 00-Concurrency.md (M7); project-profile.md; P08-analysis-model.md 2.0 (F3, F4, bảng quan hệ R-01 đến R-101); P09-architecture.md 2.0 (F3 đến F7.5, F7.7, F7.11); P10-design-elements.md 2.0 (F3, F4, F5, Đề xuất sửa artifact trước); P11a-gui 2.0 (screen-list, screen-transition SCR-01 đến SCR-40, ui-standards UI-STT 41, 43, 48); P11b-system-interfaces SS-02 1.1 (IF-03, F5); P07 UC-001, UC-003, UC-004, UC-005, UC-007 đến UC-017 (message của các boundary Form); design/P12-class-design.md 1.6 (tham chiếu, không sửa: IF-06, IF-08, IF-11, IF-16, IF-19 đến IF-21, IF-23, DC-HoldResult, DC-PaymentStatusView, DC-CancelResult, DC-AdmitResult); _sync-log.md (Đầu vào cho lần chạy lại P08-P13, dòng P12). Dải mã của phiên (C10): R-330 đến R-369, ST-17 đến ST-18, IF-41 đến IF-43, Q-332 đến Q-341 |
| Phạm vi | PKG-05 CustomerWeb, PKG-06 CounterWeb, PKG-07 CheckInWeb, PKG-08 CinemaAdminWeb, PKG-09 ChainAdminWeb, PKG-10 AccountAdminWeb, PKG-29 SeatMapClient, PKG-31 SessionClient, PKG-20 Notification, PKG-23 EmailGatewayClient (SS-02). Tham chiếu, không sửa: design/P12-class-design.md (lõi) |
| Mã Q, ASM cuối đã cấp | Q-341 (dải Q-332 đến Q-341 của phiên); không có ASM (NGHIEM_NGAT) |

Kết quả: 64 phần tử có hành vi (60 lớp, 4 interface) trong 10 package, 39 kiểu phụ trợ, 120 quan hệ ở 55 mã R (R-330 đến R-365 mới; 19 mã P08 giữ nguyên), 2 state machine (ST-17, ST-18), 5 class diagram, 2 state diagram.

Trọng tâm: lớp trình bày chạy ở trình duyệt (TypeScript, React) giữ đúng ba quy tắc chống race condition ở phía người dùng: (1) mỗi lần bấm xác nhận chọn ghế mang một requestId để gửi lại khi mất mạng không giữ ghế hai lần; (2) sơ đồ ghế chỉ áp sự kiện mới hơn eventSeq của từng ghế nên phát lặp, phát lại và lệch thứ tự đều vô hại (P09 F7.5); (3) mọi kết quả cuối của lần giữ ghế do máy chủ quyết, trình duyệt chỉ đọc lại trạng thái, không tự đoán. Phần email (Go) lấy dòng hàng đợi đã claim, dựng thư ngoài giao dịch rồi gửi qua IF-03, ghi kết quả có điều kiện claim_token.

## 0. Phạm vi lần chạy và quy ước

0.1. Phạm vi. Lần chạy theo package cho tầng trình bày và thông báo mà lõi P12 (P12-class-design.md 1.6) để lại. Tệp lõi chỉ được tham chiếu: phía máy chủ dùng lại IF-06, IF-08, IF-11, IF-16, IF-19, IF-20, IF-21, IF-23 và các kiểu kết quả đã có; PKG-11 HttpApi chưa có thiết kế lớp (P12 lõi mục 0.1 để lại) nên các Store gọi qua tuyến logic của IF-41 (Q-332). Số phần tử có hành vi vượt ngưỡng khoảng 20 của prompt nên chạy theo package, một tệp cho mười package có quan hệ chặt (tầng trình bày cùng gọi xuống PKG-11 và hai package phía máy chủ nhỏ); lựa chọn ghi ở Vấn đề còn mở 1.

| Nhóm | Package | Phần tử có hành vi |
|---|---|---|
| Giao diện React | PKG-05 | 17: DC-CustomerHomeView, DC-RegisterAccountView, DC-RegisterAccountStore, DC-BrowseMoviesView, DC-BrowseMoviesStore, DC-BrowseShowtimesView, DC-BrowseShowtimesStore, DC-ViewBookingHistoryView, DC-ViewBookingHistoryStore, DC-CancelTicketView, DC-CancelTicketStore, DC-BookTicketsView, DC-SelectShowtimePage, DC-SelectSeatsPage, DC-HoldAndPayPage, DC-BookingResultPage, DC-BookTicketsStore |
| Giao diện React | PKG-06 | 8: DC-CounterHomeView, DC-CounterBookTicketsView, DC-CounterSelectSeatsPage, DC-CounterHoldAndCashPage, DC-CounterPrintTicketsPage, DC-CounterBookTicketsStore, DC-CounterCancelTicketView, DC-CounterCancelTicketStore |
| Giao diện React | PKG-07 | 2: DC-CheckTicketView, DC-CheckTicketStore |
| Giao diện React | PKG-08 | 9: DC-CinemaAdminHomeView, DC-ManagePriceListView, DC-ManagePriceListStore, DC-ScheduleShowtimesView, DC-ScheduleShowtimesStore, DC-ManageAuditoriumsView, DC-ManageAuditoriumsStore, DC-ViewCinemaReportView, DC-ViewCinemaReportStore |
| Giao diện React | PKG-09 | 7: DC-ChainAdminHomeView, DC-ManageMoviesView, DC-ManageMoviesStore, DC-ManageCinemasView, DC-ManageCinemasStore, DC-ViewChainReportView, DC-ViewChainReportStore |
| Giao diện React | PKG-10 | 2: DC-ManageStaffAccountsView, DC-ManageStaffAccountsStore |
| Application phía máy chủ | PKG-20 | 1: DC-EmailOutboxJob |
| Services (SS-02) | PKG-23 | 5: IF-03, DC-EmailGatewayManager, DC-MimeMessageBuilder, DC-SmtpClient, DC-SmtpConfig |
| Giao diện React | PKG-29 | 6: IF-42, DC-BrowserEventSourceFactory, DC-SeatMapReducer, DC-SeatMapSyncClient, DC-HoldCountdown, DC-HoldFlowStore |
| Giao diện React | PKG-31 | 11: IF-41, IF-43, IF-48, DC-BrowserTicker, DC-FetchApiClient, DC-StoreBase, DC-RequestStoreBase, DC-ManagedListStore, DC-ReportStoreBase, DC-SessionStore, DC-LoginView |

0.2. Bảng ánh xạ kiểu sang TypeScript và Go (một lần cho cả artifact). Phần giao diện dùng TypeScript (React SPA, theo P09 F11); PKG-20 và PKG-23 dùng Go như P12 lõi mục 0.2.

| Kiểu trung lập | TypeScript (PKG-05 đến PKG-10, PKG-29, PKG-31) | Go (PKG-20, PKG-23) | Ghi chú |
|---|---|---|---|
| String | string | string | |
| Integer, định danh | number | int, int64, kiểu định danh của P12 lõi | Định danh là số nguyên; mã đặt vé, mã tham chiếu là string |
| Decimal, tiền | number (số nguyên đồng) | Money (P12 lõi) | Không dùng số thực cho tiền; trình duyệt chỉ hiển thị |
| Boolean | boolean | bool | |
| Date, DateTime | number (ms epoch) cho mốc đếm ngược; string ISO 8601 cho mốc hiển thị và displayedAt | time.Time | Thời hạn giữ ghế lấy từ máy chủ, không từ đồng hồ trình duyệt (P11a UI-STT 43) |
| List<T> | readonly T[] | []T | |
| Lời gọi chờ kết quả (Đồng bộ ở P11b) | Promise<T> | trả giá trị và error | Promise thay cho luồng chờ; IF-03.SendEmail đồng bộ theo P11b |
| Luồng kết quả bất đồng bộ | gọi lại StreamHandlers (IF-42) | - | EventSource đẩy sự kiện |
| Ngoại lệ | class kế thừa Error (ApiError, NetworkError, BookingStateError) | error | |

Kiểu hợp đồng REST: Các kiểu SeatId, ShowtimeId, MovieId, CinemaId, AuditoriumId, TicketId, StaffId, PriceEntryKey là number (định danh số) hoặc string (mã đặt vé, mã tham chiếu); BookingRoute, BookingScreen, CounterBookingRoute, CounterBookingScreen, BrowseMode, BrowseCriteria, các kiểu hàng danh sách (MovieSummary, ShowtimeRow, TicketView, StaffRow, AuditoriumRow, MovieRow, CinemaRow, PriceListView, ReportView, ChainReportView ...) và kiểu dữ liệu nhập (RegistrationData, PriceEntryInput, ShowtimeInput, AuditoriumInput, MovieInput, CinemaInput, StaffInput, StaffDialogInput ...) là kiểu TypeScript phản chiếu thân JSON của PKG-11, không cấp mã DC (thuộc hợp đồng REST của PKG-11, P12 PKG-11 chốt trường).

0.3. Quy ước tầng trình bày. View là component React (hàm và hook, mô tả như lớp có operation là bộ xử lý sự kiện và vòng đời, không đi vào JSX); Store là lớp TypeScript giữ trạng thái bất biến, đổi qua setState, phát thay đổi cho View (khuôn Flux của P09 F5), gọi PKG-11 qua IF-41. View không gọi IF-41; Store không biết View. Operation của Store cùng tên với trách nhiệm phân tích nhóm (open, load, save, remove) theo góc nhìn bên gọi. Mọi thông điệp người dùng nhìn thấy có mã MSG-nn của P11a; Store chỉ giữ mã MSG (Refusal.messageId) và View dựng chữ từ ui-standards.

0.4. Chữ ký interface tạm: Không có. IF-03 đã có chữ ký ở P11b F3; IF-41, IF-42, IF-43 do lần chạy này cấp (Bước 1.5).

## F1. Bảng lớp thiết kế

| DC | Tên | Stereotype | PKG | Trách nhiệm | Nguồn AC | Loại | Persistent | Ghi chú thiết kế |
|---|---|---|---|---|---|---|---|---|
| DC-CustomerHomeView | CustomerHomeView | «boundary» | PKG-05 | Hiển thị trang chủ khách với lối vào Đặt vé, Huỷ vé, Xem phim, Lịch chiếu, Lịch sử, Đăng ký và dải giữ ghế đang chạy | P10 Thiết kế: SCR-02 | class | Không | Chỉ điều hướng; không có trách nhiệm AC |
| DC-RegisterAccountView | RegisterAccountView | «boundary» | PKG-05 | Hiển thị form đăng ký tài khoản khách và thông báo kết quả đăng ký | AC-B-RegisterAccountForm | class | Không | SCR-22 |
| DC-RegisterAccountStore | RegisterAccountStore | «control» | PKG-05 | Giữ trạng thái đăng ký và gửi yêu cầu đăng ký tới máy chủ | AC-B-RegisterAccountForm | class | Không | Kế thừa DC-StoreBase |
| DC-BrowseMoviesView | BrowseMoviesView | «boundary» | PKG-05 | Hiển thị danh sách phim đang chiếu, sắp chiếu và thông tin một phim | AC-B-BrowseMoviesForm | class | Không | SCR-23, SCR-24 |
| DC-BrowseMoviesStore | BrowseMoviesStore | «control» | PKG-05 | Giữ danh sách phim và phim đang xem chi tiết | AC-B-BrowseMoviesForm | class | Không | Chỉ đọc |
| DC-BrowseShowtimesView | BrowseShowtimesView | «boundary» | PKG-05 | Hiển thị bộ lọc và lịch chiếu theo phim hoặc theo cụm rạp | AC-B-BrowseShowtimesForm | class | Không | SCR-25 |
| DC-BrowseShowtimesStore | BrowseShowtimesStore | «control» | PKG-05 | Giữ lựa chọn phim, cụm rạp, tiêu chí lọc và lịch chiếu tìm được | AC-B-BrowseShowtimesForm | class | Không | Chỉ đọc |
| DC-ViewBookingHistoryView | ViewBookingHistoryView | «boundary» | PKG-05 | Hiển thị lịch sử các lần đặt vé của khách và vé của một lần đặt | AC-B-ViewBookingHistoryForm | class | Không | SCR-26, SCR-27 |
| DC-ViewBookingHistoryStore | ViewBookingHistoryStore | «control» | PKG-05 | Giữ lịch sử đặt vé của khách và vé của lần đặt đang xem | AC-B-ViewBookingHistoryForm | class | Không | Chỉ đọc |
| DC-CancelTicketView | CancelTicketView | «boundary» | PKG-05 | Hiển thị các vé khách có thể huỷ, hộp xác nhận huỷ và kết quả huỷ vé | AC-B-CancelTicketForm | class | Không | SCR-07, SCR-08; dùng chung boundary (R-19) với đặt vé ở phần sơ đồ ghế |
| DC-CancelTicketStore | CancelTicketStore | «control» | PKG-05 | Giữ danh sách vé huỷ được và kết quả huỷ vé của khách | AC-B-CancelTicketForm | class | Không | Huỷ vé là thao tác một lần; chống bấm hai lần bằng status SUBMITTING |
| DC-BookTicketsView | BookTicketsView | «boundary» | PKG-05 | Điều phối bốn màn hình đặt vé của khách, vùng thông điệp chung và pop-up đăng nhập | AC-B-BookTicketsForm | class | Không | P11a Đề xuất: tách thành component trang; View là vỏ của luồng |
| DC-SelectShowtimePage | SelectShowtimePage | «boundary» | PKG-05 | Hiển thị danh sách suất chiếu có thể đặt và chuyển sang chọn ghế khi khách chọn một suất | AC-B-BookTicketsForm | class | Không | SCR-03 |
| DC-SelectSeatsPage | SelectSeatsPage | «boundary» | PKG-05 | Hiển thị sơ đồ ghế trực tiếp, chú giải, số ghế đã chọn và nút xác nhận chọn ghế | AC-B-BookTicketsForm | class | Không | SCR-04 |
| DC-HoldAndPayPage | HoldAndPayPage | «boundary» | PKG-05 | Hiển thị các ghế đã giữ, tổng tiền, đồng hồ đếm ngược và nút thanh toán qua VNPay hoặc huỷ giữ ghế | AC-B-BookTicketsForm | class | Không | SCR-05 |
| DC-BookingResultPage | BookingResultPage | «boundary» | PKG-05 | Hiển thị kết quả đặt vé sau khi cổng VNPay chuyển trình duyệt về: thành công kèm mã đặt vé, thất bại hoặc đang chờ | AC-B-BookTicketsForm | class | Không | SCR-06 |
| DC-BookTicketsStore | BookTicketsStore | «control» | PKG-05 | Mở rộng luồng giữ ghế bằng thanh toán trực tuyến: tạo địa chỉ thanh toán và đọc kết quả thanh toán | AC-B-BookTicketsForm | class | Không | Kế thừa DC-HoldFlowStore |
| DC-CounterHomeView | CounterHomeView | «boundary» | PKG-06 | Hiển thị trang chủ nhân viên quầy với lối vào Bán vé, Huỷ vé và dải giữ ghế đang chạy | P10 Thiết kế: SCR-09 | class | Không | Chỉ điều hướng |
| DC-CounterBookTicketsView | CounterBookTicketsView | «boundary» | PKG-06 | Điều phối ba màn hình bán vé tại quầy và vùng thông điệp chung | AC-B-CounterBookTicketsForm | class | Không | P11a Đề xuất: tách thành component trang; View là vỏ của luồng |
| DC-CounterSelectSeatsPage | CounterSelectSeatsPage | «boundary» | PKG-06 | Hiển thị bộ chọn suất chiếu của cụm rạp, sơ đồ ghế trực tiếp và nút xác nhận chọn ghế tại quầy | AC-B-CounterBookTicketsForm | class | Không | SCR-10 |
| DC-CounterHoldAndCashPage | CounterHoldAndCashPage | «boundary» | PKG-06 | Hiển thị các ghế đã giữ, tổng tiền, đồng hồ đếm ngược và nút xác nhận đã thu tiền mặt hoặc huỷ giữ ghế | AC-B-CounterBookTicketsForm | class | Không | SCR-11 |
| DC-CounterPrintTicketsPage | CounterPrintTicketsPage | «boundary» | PKG-06 | Hiển thị mã đặt vé và các vé vừa bán để in bằng chức năng in của trình duyệt | AC-B-CounterBookTicketsForm | class | Không | SCR-12 |
| DC-CounterBookTicketsStore | CounterBookTicketsStore | «control» | PKG-06 | Mở rộng luồng giữ ghế bằng xác nhận đã thu tiền mặt để bán vé tại quầy | AC-B-CounterBookTicketsForm | class | Không | Kế thừa DC-HoldFlowStore |
| DC-CounterCancelTicketView | CounterCancelTicketView | «boundary» | PKG-06 | Hiển thị ô nhập mã đặt vé, các vé của lần đặt, số tiền mặt cần hoàn và kết quả huỷ vé tại quầy | AC-B-CounterCancelTicketForm | class | Không | SCR-13, SCR-14, SCR-15 |
| DC-CounterCancelTicketStore | CounterCancelTicketStore | «control» | PKG-06 | Giữ lần đặt tìm theo mã, yêu cầu hoàn tiền mặt và kết quả huỷ vé tại quầy | AC-B-CounterCancelTicketForm | class | Không | Huỷ và xác nhận hoàn tiền mặt là hai bước; vé đã huỷ mà chưa xác nhận hoàn vẫn giữ ở SCR-14 |
| DC-CheckTicketView | CheckTicketView | «boundary» | PKG-07 | Hiển thị bộ chọn suất chiếu đang soát, camera đọc mã QR và kết quả vé hợp lệ hoặc lý do từ chối cho vào | AC-B-CheckTicketForm | class | Không | SCR-16; camera dùng thư viện đọc QR có sẵn, không thành lớp (P10) |
| DC-CheckTicketStore | CheckTicketStore | «control» | PKG-07 | Giữ suất chiếu đang soát và kết quả của lần quét mã QR gần nhất | AC-B-CheckTicketForm | class | Không | Chặn quét trùng: cùng chuỗi trong 3 giây hoặc khi một yêu cầu đang chạy thì bỏ qua (camera đọc nhiều khung cho một mã) |
| DC-CinemaAdminHomeView | CinemaAdminHomeView | «boundary» | PKG-08 | Hiển thị trang chủ quản lý cụm rạp với lối vào Bảng giá, Suất chiếu, Phòng chiếu và Báo cáo | P10 Thiết kế: SCR-17 | class | Không | Chỉ điều hướng |
| DC-ManagePriceListView | ManagePriceListView | «boundary» | PKG-08 | Hiển thị bảng giá của cụm rạp, form đặt giá một tổ hợp và hộp xác nhận bỏ giá | AC-B-ManagePriceListForm | class | Không | SCR-18 |
| DC-ManagePriceListStore | ManagePriceListStore | «control» | PKG-08 | Giữ bảng giá của cụm rạp với tình trạng từng mục giá lúc hiển thị và gửi yêu cầu đặt, bỏ giá | AC-B-ManagePriceListForm | class | Không | Mốc displayedAt từng mục giá gửi kèm để máy chủ phát hiện sửa chồng |
| DC-ScheduleShowtimesView | ScheduleShowtimesView | «boundary» | PKG-08 | Hiển thị danh sách suất chiếu của cụm rạp và form lập, sửa, xoá suất chiếu | AC-B-ScheduleShowtimesForm | class | Không | SCR-19, SCR-20 |
| DC-ScheduleShowtimesStore | ScheduleShowtimesStore | «control» | PKG-08 | Giữ danh sách suất chiếu, phòng chiếu, phim để chọn và trạng thái form lập, sửa, xoá suất chiếu | AC-B-ScheduleShowtimesForm | class | Không | Mốc displayedAt của suất gửi kèm khi sửa, xoá để phát hiện sửa chồng (BR-54) |
| DC-ManageAuditoriumsView | ManageAuditoriumsView | «boundary» | PKG-08 | Hiển thị danh sách phòng chiếu của cụm rạp và form thêm, sửa sơ đồ ghế, xoá phòng chiếu | AC-B-ManageAuditoriumsForm | class | Không | SCR-28, SCR-29 |
| DC-ManageAuditoriumsStore | ManageAuditoriumsStore | «control» | PKG-08 | Giữ danh sách phòng chiếu kèm mốc thay đổi lúc hiển thị và trạng thái form phòng chiếu | AC-B-ManageAuditoriumsForm | class | Không | Mốc lastChangedAt từng phòng gửi kèm khi sửa, xoá (BR-146) |
| DC-ViewCinemaReportView | ViewCinemaReportView | «boundary» | PKG-08 | Hiển thị form chọn cách xem, kỳ báo cáo và bảng doanh thu, tỉ lệ lấp đầy của cụm rạp | AC-B-ViewCinemaReportForm | class | Không | SCR-30 |
| DC-ViewCinemaReportStore | ViewCinemaReportStore | «control» | PKG-08 | Giữ báo cáo doanh thu và tỉ lệ lấp đầy của cụm rạp và kết quả của lần yêu cầu gần nhất | AC-B-ViewCinemaReportForm | class | Không | Chỉ đọc; số liệu tính tại lúc xem, không lưu (BR-117) |
| DC-ChainAdminHomeView | ChainAdminHomeView | «boundary» | PKG-09 | Hiển thị trang chủ quản lý chuỗi với lối vào Phim, Cụm rạp và Báo cáo toàn chuỗi | Thiết kế: P11a Đề xuất (SCR-31) | class | Không | DC mới theo đề xuất P11a; chỉ điều hướng; Đề xuất sửa P10 thêm vào PKG-09 |
| DC-ManageMoviesView | ManageMoviesView | «boundary» | PKG-09 | Hiển thị danh sách phim của chuỗi và form thêm, sửa phim | AC-B-ManageMoviesForm | class | Không | SCR-32, SCR-33 |
| DC-ManageMoviesStore | ManageMoviesStore | «control» | PKG-09 | Giữ danh sách phim kèm mốc thay đổi lúc hiển thị và trạng thái form phim | AC-B-ManageMoviesForm | class | Không | Mốc lastChangedAt từng phim gửi kèm khi sửa (BR-138) |
| DC-ManageCinemasView | ManageCinemasView | «boundary» | PKG-09 | Hiển thị danh sách cụm rạp của chuỗi và form thêm, sửa cụm rạp | AC-B-ManageCinemasForm | class | Không | SCR-34, SCR-35 |
| DC-ManageCinemasStore | ManageCinemasStore | «control» | PKG-09 | Giữ danh sách cụm rạp kèm mốc thay đổi lúc hiển thị và trạng thái form cụm rạp | AC-B-ManageCinemasForm | class | Không | Mốc lastChangedAt từng cụm rạp gửi kèm khi sửa (BR-142) |
| DC-ViewChainReportView | ViewChainReportView | «boundary» | PKG-09 | Hiển thị form chọn cách xem, kỳ báo cáo và bảng doanh thu, tỉ lệ lấp đầy toàn chuỗi kèm so sánh từng cụm rạp | AC-B-ViewChainReportForm | class | Không | SCR-36 |
| DC-ViewChainReportStore | ViewChainReportStore | «control» | PKG-09 | Giữ báo cáo toàn chuỗi và kết quả của lần yêu cầu gần nhất | AC-B-ViewChainReportForm | class | Không | Chỉ đọc; số liệu tính tại lúc xem (BR-117) |
| DC-ManageStaffAccountsView | ManageStaffAccountsView | «boundary» | PKG-10 | Hiển thị danh sách tài khoản nhân viên và các hộp thoại tạo, đổi vai trò hoặc cụm rạp, khoá, mở khoá, sửa họ tên, đặt lại mật khẩu | AC-B-ManageStaffAccountsForm | class | Không | SCR-37 đến SCR-40; một boundary 20 trách nhiệm của sáu thao tác một use case, không tách (P10 F3) |
| DC-ManageStaffAccountsStore | ManageStaffAccountsStore | «control» | PKG-10 | Giữ danh sách tài khoản nhân viên kèm mốc thay đổi lúc hiển thị và gửi các thao tác quản trị tài khoản | AC-B-ManageStaffAccountsForm | class | Không | Mốc lastChangedAt từng tài khoản gửi kèm mọi thao tác sửa (BR-146); mật khẩu không giữ trong state sau khi gửi |
| DC-EmailOutboxJob | EmailOutboxJob | «service» | PKG-20 | Nhận các dòng hàng đợi email đến hạn, dựng thư vé hoặc thư hoàn tiền, gửi qua IF-03 ngoài giao dịch và ghi kết quả có điều kiện claim | P10 cơ chế (P09 F7.7; AC-B-EmailService); P11b SS-02 F1 | class | Không | Hiện thực IF-06; dựng nội dung gộp từ DC-EmailComposer (P10). Hàm sinh ảnh QR nhận qua constructor (qrEncoder) để kiểm thử |
| IF-03 | IEmailSender | «interface» | PKG-23 | Gửi một email đã dựng sẵn tới dịch vụ email SMTP và báo kết quả | P11b SS-02 | interface | Không | Chữ ký theo P11b F3; không có chữ ký tạm |
| DC-EmailGatewayManager | EmailGatewayManager | «service» | PKG-23 | Nhận SendEmail, kiểm dữ liệu thư rồi giao cho bộ dựng MIME và máy khách SMTP và đổi lỗi giao thức thành EmailSendResult | P11b SS-02 | class | Không | Hiện thực IF-03; visibility package |
| DC-MimeMessageBuilder | MimeMessageBuilder | «utility» | PKG-23 | Đổi EmailMessage thành thư MIME UTF-8 có Message-ID từ khoá chống lặp và ảnh QR nhúng | P11b SS-02 | class | Không | Visibility package |
| DC-SmtpClient | SmtpClient | «service» | PKG-23 | Mở phiên SMTP có TLS, gửi thư thô và phân loại mã trả lời thành thành công, từ chối vĩnh viễn hoặc tạm thời | P11b SS-02 | class | Không | Visibility package; V-17 (nhà cung cấp SMTP chưa chọn) |
| DC-SmtpConfig | SmtpConfig | «utility» | PKG-23 | Giữ cấu hình SMTP đọc từ biến môi trường khi khởi động và không để lộ thông tin xác thực ra log | P11b SS-02 | class | Không | Visibility package |
| IF-42 | IEventSourceFactory | «interface» | PKG-29 | Mở một kết nối đẩy sự kiện (SSE) tới một địa chỉ và trả bộ nhận sự kiện | Thiết kế: để DC-SeatMapSyncClient kiểm thử được mà không cần EventSource thật | interface | Không | Interface mới; hiện thực DC-BrowserEventSourceFactory |
| DC-BrowserEventSourceFactory | BrowserEventSourceFactory | «utility» | PKG-29 | Hiện thực IEventSourceFactory bằng EventSource của trình duyệt và đổi khung seat, reload, nhịp tim thành lời gọi handlers | Thiết kế: hiện thực IF-42 | class | Không | Hiện thực IF-42; không thêm operation công khai |
| DC-SeatMapReducer | SeatMapReducer | «control» | PKG-29 | Áp ảnh chụp và sự kiện đổi ghế vào sơ đồ ghế theo quy tắc chỉ nhận sự kiện mới hơn eventSeq của từng ghế | P10 cơ chế (P09 F7.5 điểm 5); P08 // updateSeatMap | class | Không | Hàm thuần trên SeatMapGrid; không giữ trạng thái, không gọi mạng |
| DC-SeatMapSyncClient | SeatMapSyncClient | «control» | PKG-29 | Giữ sơ đồ ghế của một suất chiếu đồng bộ với máy chủ: tải ảnh chụp, mở kết nối đẩy từ con trỏ, nối lại và tải lại khi cần | P10 cơ chế (P09 F7.5; AC-B-BookTicketsForm // updateSeatMap) | class | Không | Kế thừa DC-StoreBase; có state machine ST-18 |
| DC-HoldCountdown | HoldCountdown | «control» | PKG-29 | Tính thời gian giữ ghế còn lại từ thời điểm hết hạn của máy chủ, bù độ lệch đồng hồ, và báo các mốc cảnh báo | Thiết kế: P11a ui-standards UI-STT 43 (BR-10); dùng chung PKG-05, PKG-06 | class | Không | Kế thừa DC-StoreBase; hai Store đặt chỗ dùng chung |
| DC-HoldFlowStore | HoldFlowStore | «control» | PKG-29 | Điều phối luồng chọn ghế, giữ ghế, huỷ giữ ghế và mở lại lần giữ ghế đang chạy, dùng chung cho khách và nhân viên quầy | Thiết kế: tách phần chung của AC-B-BookTicketsForm và AC-B-CounterBookTicketsForm | abstract class | Không | Lớp abstract kế thừa DC-StoreBase; DC-BookTicketsStore và DC-CounterBookTicketsStore kế thừa; có state machine ST-17. Đề xuất sửa P10: đặt ở PKG-29 |
| IF-41 | IApiClient | «interface» | PKG-31 | Gửi một yêu cầu REST có mã phiên tới PKG-11 và trả kết quả đã giải mã hoặc ném ApiError | Thiết kế: để Store kiểm thử bằng bản giả và không phụ thuộc fetch | interface | Không | Interface mới do cơ chế thiết kế; hiện thực DC-FetchApiClient |
| IF-43 | ITicker | «interface» | PKG-31 | Cung cấp thời điểm hiện tại và bộ hẹn giờ lặp cho lớp giao diện để kiểm thử được mốc thời gian | Thiết kế: Bước 2.6 (không gọi đồng hồ hệ thống trực tiếp) | interface | Không | Interface mới; hiện thực DC-BrowserTicker |
| DC-BrowserTicker | BrowserTicker | «utility» | PKG-31 | Hiện thực ITicker bằng Date.now và setInterval, setTimeout của trình duyệt | Thiết kế: hiện thực IF-43 | class | Không | Hiện thực IF-43; không thêm operation công khai |
| DC-FetchApiClient | FetchApiClient | «service» | PKG-31 | Đổi một ApiRequest thành lời gọi fetch có mã phiên và đổi phản hồi lỗi thành ApiError | Thiết kế: hiện thực IF-41 | class | Không | Hiện thực IF-41; bảng tuyến logic sang phương thức và đường dẫn do P12 của PKG-11 chốt (Q-332) |
| IF-48 | ISessionSource | «interface» | PKG-31 | Cho DC-FetchApiClient lấy giá trị Authorization của phiên và báo phiên hết hiệu lực khi nhận 401, không biết DC-SessionStore | Thiết kế: Extract Interface (X1 RV-24), phá vòng lớp DC-FetchApiClient và DC-SessionStore | interface | Không | DC-SessionStore hiện thực; bản giả của DC-FetchApiClient trong X2 không cần khởi tạo DC-SessionStore thật |
| DC-StoreBase | StoreBase<S> | «control» | PKG-31 | Giữ trạng thái bất biến của một Store và báo cho người đăng ký khi trạng thái đổi | Thiết kế: khuôn Flux (P09 F5), mẫu Observer | abstract class | Không | Lớp abstract; mọi Store của PKG-05 đến PKG-10 và DC-HoldFlowStore kế thừa |
| DC-RequestStoreBase | RequestStoreBase<S> | «control» | PKG-31 | Giữ trạng thái gửi yêu cầu, lý do từ chối và số thứ tự yêu cầu của một Store có gửi yêu cầu tới máy chủ | Thiết kế: Extract Superclass (X1 RV-19) | abstract class | Không | Lớp abstract, kế thừa DC-StoreBase; DC-ManagedListStore và DC-ReportStoreBase kế thừa |
| DC-ManagedListStore | ManagedListStore<S> | «control» | PKG-31 | Bước lưu có mốc displayedAt và quy tắc nạp lại danh sách khi bị từ chối do mốc cũ (BR-138, BR-142, BR-146) cho năm Store quản lý | Thiết kế: Extract Superclass (X1 RV-19) | abstract class | Không | Lớp abstract; DC-ManagePriceListStore, DC-ScheduleShowtimesStore, DC-ManageAuditoriumsStore, DC-ManageMoviesStore, DC-ManageCinemasStore kế thừa |
| DC-ReportStoreBase | ReportStoreBase<S> | «control» | PKG-31 | Đánh số yêu cầu, bỏ kết quả của yêu cầu cũ và giữ thông báo kỳ báo cáo cho hai Store báo cáo | Thiết kế: Extract Superclass (X1 RV-19) | abstract class | Không | Lớp abstract; DC-ViewCinemaReportStore, DC-ViewChainReportStore kế thừa |
| DC-SessionStore | SessionStore | «control» | PKG-31 | Giữ mã phiên và danh tính của người dùng đang đăng nhập, và đưa về màn đăng nhập khi phiên không còn hiệu lực | P10 cơ chế (P09 F5, F7.11) | class | Không | Kế thừa DC-StoreBase; mã phiên lưu ở sessionStorage (Q-337) |
| DC-LoginView | LoginView | «boundary» | PKG-31 | Hiển thị một form đăng nhập dùng cho khách hoặc nhân viên, ở dạng trang hoặc pop-up, và chuyển người dùng tới màn hình đầu của vai trò | P10 cơ chế (PKG-31); P11a Đề xuất: một component phục vụ SCR-01 và SCR-21 | class | Không | Một component nhận accountKind (Q-267, E-39, E-40) |

Căn cứ tách và gộp (Bước 1.1, 1.4): (a) mỗi AC-B Form của P10 F3 đã tách thành View và Store; riêng AC-B-BookTicketsForm và AC-B-CounterBookTicketsForm tách thêm component trang theo màn hình (đề xuất P11a mục P10-F3), vì một View gánh bốn màn hình có 11 trách nhiệm trộn việc chọn ghế, thanh toán và kết quả; (b) phần chung của hai Store đặt vé (chọn ghế, giữ ghế, huỷ, mở lại, đếm ngược) tách thành DC-HoldFlowStore ở PKG-29 vì hai package tác nhân PKG-05, PKG-06 không được dùng lẫn nhau (A3); (c) DC-LoginView một component cho SCR-01 và SCR-21 theo accountKind (Q-267); (d) DC-ChainAdminHomeView thêm theo đề xuất P11a (SCR-31). Không tách thêm control vì không có control ở tầng này; DC-EmailOutboxJob giữ cả dựng thư và gửi vì thư chỉ có một bên gọi (P10 đã gộp DC-EmailComposer).

F1b. Kiểu phụ trợ

| DC | Loại | PKG | Thành phần hoặc giá trị | Dùng trong chữ ký |
|---|---|---|---|---|
| DC-ApiError | exception | PKG-31 | status (number), code (string), messageId (string, mã MSG), detail (string) | IF-41.send |
| DC-NetworkError | exception | PKG-31 | Hết thời gian chờ hoặc mất mạng khi gọi REST; cho phép thử lại cùng requestId | IF-41.send |
| DC-ApiRequest | value object | PKG-31 | route (string, tên tuyến logic), params (Record), query (Record), body (unknown) | IF-41.send, openStream |
| DC-LoadStatus | enumeration | PKG-31 | IDLE, LOADING, READY, SUBMITTING, FAILED | mọi Store |
| DC-Refusal | value object | PKG-31 | messageId (mã MSG hiển thị), params (giá trị chèn vào thông điệp, ví dụ danh sách ghế bị lấy) | mọi Store |
| DC-AccountKind | enumeration | PKG-31 | CUSTOMER, STAFF | DC-SessionStore.login, DC-LoginView.mount |
| DC-LoginMode | enumeration | PKG-31 | PAGE, POPUP | DC-LoginView.mount |
| DC-SessionInfo | value object | PKG-31 | token (string), subjectKind (CUSTOMER, STAFF, ADMIN), role (Role), cinemaId (number hoặc null), displayName (string), expiresAt (number, ms epoch) | DC-SessionStore, DC-LoginView.homeRouteFor |
| DC-LoginOutcome | value object | PKG-31 | ok (boolean), session (SessionInfo, khi ok), refusal (Refusal, khi từ chối) | DC-SessionStore.login |
| DC-ExpireReason | enumeration | PKG-31 | SESSION_INVALID (mã phiên bị từ chối, nhân viên đổi quyền), SESSION_EXPIRED (quá hạn) | DC-SessionStore.expire |
| DC-ScreenId | enumeration | PKG-31 | SCR-01 đến SCR-40 (mã màn hình P11a) | DC-LoginView.homeRouteFor, các View điều hướng |
| DC-ConnectionState | enumeration | PKG-29 | CONNECTING, LIVE, RECONNECTING, RELOAD_PENDING, CLOSED (ST-18) | DC-SeatMapSyncClient.connection |
| DC-SeatMapGrid | value object | PKG-29 | seats (Map seatId --> SeatCell), cursor (number, mã sự kiện lớn nhất đã thấy), showtimeChangedAt (string, lastChangedAt của suất chiếu) | DC-SeatMapReducer, DC-SeatMapSyncClient |
| DC-SeatCell | value object | PKG-29 | seatId, label, seatType, state (AVAILABLE, HELD, SOLD), eventSeq (number) | DC-SeatMapGrid |
| DC-SeatMapSnapshot | value object | PKG-29 | Ảnh chụp sơ đồ ghế REST: showtimeId, showtimeChangedAt, cursor, seats (seatId, state, eventSeq); phản chiếu DC-SeatSnapshot của PKG-28 | DC-SeatMapReducer.fromSnapshot |
| DC-SeatEventView | value object | PKG-29 | eventId (number), showtimeId, items (seatId, state); phản chiếu DC-SeatChangeEvent của PKG-28 | DC-SeatMapReducer.applyEvent |
| DC-StreamHandlers | value object | PKG-29 | onOpen, onSeatEvent, onReload, onHeartbeat, onError (các hàm gọi lại) | IF-42.open |
| DC-StreamHandle | value object | PKG-29 | close (hàm đóng kết nối) | IF-42.open |
| DC-BookingPhase | enumeration | PKG-29 | NO_SHOWTIME, SELECTING_SEATS, HOLD_REQUESTED, HELD, PAYMENT_REDIRECTING, AWAITING_RESULT, BOOKED, ENDED (ST-17) | DC-HoldFlowStore |
| DC-EndReason | enumeration | PKG-29 | EXPIRED, CANCELLED, PAYMENT_FAILED | DC-HoldFlowStore |
| DC-WarningLevel | enumeration | PKG-29 | NONE, WARN | DC-HoldCountdown.warningLevel |
| DC-HoldView | value object | PKG-29 | holdRef, expiryTime (ms epoch), serverTime (ms epoch), seats (seatId, label, seatType, price), total (number, đồng), replayed (boolean); phản chiếu DC-HoldResult của PKG-13 cộng serverTime | DC-HoldFlowStore |
| DC-ShowtimeView | value object | PKG-29 | showtimeId, movieTitle, format, cinemaName, auditoriumName, startsAt, lastChangedAt, maxSeatsPerHold | DC-HoldFlowStore.openShowtime |
| DC-PaymentOutcome | value object | PKG-05 | holdStatus, paymentStatus, bookingCode (rỗng nếu chưa có vé); phản chiếu DC-PaymentStatusView của PKG-14 | DC-BookTicketsStore.loadPaymentOutcome |
| DC-SoldTickets | value object | PKG-06 | bookingCode, tickets (TicketView), qrContents | DC-CounterBookTicketsStore.confirmCashReceived |
| DC-CounterCashRefundView | value object | PKG-06 | ticketId, amount (đồng), refundType = TICKET_CASH | DC-CounterCancelTicketStore |
| DC-CancelResultView | value object | PKG-05 | ticketId, refundAmount, refundType, refundStatus; phản chiếu DC-CancelResult của PKG-15 | DC-CancelTicketStore, DC-CounterCancelTicketStore |
| DC-ScanOutcome | value object | PKG-07 | outcome (ADMITTED, WRONG_CINEMA, WRONG_SHOWTIME, ALREADY_USED, CANCELLED), bookingCode, seatLabel, seatType; phản chiếu DC-AdmitResult của PKG-15 | DC-CheckTicketStore.scanTicket |
| DC-ReportFormInput | value object | PKG-08 | groupBy (cách xem), fromDate, toDate (ngày dd/mm/yyyy theo múi giờ nghiệp vụ) | DC-ViewCinemaReportStore, DC-ViewChainReportStore |
| DC-ReportNotice | enumeration | PKG-08 | INVALID_PERIOD, NO_SHOWTIMES | hai Store báo cáo |
| DC-StaffAction | enumeration | PKG-10 | UPDATE, LOCK, UNLOCK, RENAME, RESET_PASSWORD | DC-ManageStaffAccountsView.onRowActionSelected |
| DC-StaffDialogKind | enumeration | PKG-10 | CREATE, UPDATE, RENAME, RESET_PASSWORD | DC-ManageStaffAccountsView |
| DC-EmailMessage | value object | PKG-23 | recipientAddress, subject, body (HTML UTF-8), attachments (EmailAttachment 0..*), deduplicationKey | IF-03.SendEmail |
| DC-EmailAttachment | value object | PKG-23 | name, mimeType, content ([]byte), inline (true cho ảnh QR nhúng) | DC-EmailMessage |
| DC-EmailSendResult | value object | PKG-23 | status (Accepted, Rejected, TemporaryFailure), maybeDelivered (bool), detail (string) | IF-03.SendEmail |
| DC-InvalidEmailMessageError | exception | PKG-23 | Địa chỉ nhận sai định dạng, tiêu đề hoặc khoá chống lặp rỗng | IF-03.SendEmail |
| DC-TlsMode | enumeration | PKG-23 | STARTTLS, IMPLICIT_TLS | DC-SmtpConfig |
| DC-ConfigurationError | exception | PKG-23 | Thiếu hoặc sai giá trị cấu hình SMTP lúc khởi động | DC-SmtpConfig.LoadSmtpConfig |
| DC-BookingStateError | exception | PKG-29 | Sự kiện không hợp lệ ở trạng thái hiện tại của luồng đặt chỗ hoặc kết nối (ST-17, ST-18) | DC-HoldFlowStore.openShowtime, cancelHold; DC-SeatMapSyncClient.start |

## F2. Bảng operation

Chữ ký TypeScript: tenOperation(thamSo: Kieu): KieuTraVe; Promise<void> là lời gọi chờ kết quả không trả giá trị. Operation không trả về ghi ": void". Mọi Store có thêm getState, subscribe, setState từ DC-StoreBase (liệt kê một lần ở dòng DC-StoreBase). Phạm vi mặc định là Instance; ngoại lệ ghi ở cột Phạm vi.

| DC | Visibility | Chữ ký | Mô tả | Tiền/hậu điều kiện | Nguồn (message P07 / UC bước) | Phạm vi | Ngoại lệ / lỗi |
|---|---|---|---|---|---|---|---|
| DC-CustomerHomeView | + | mount(): Promise<void> | Nạp lần giữ ghế đang chạy (nếu đã đăng nhập) để hiện dải Tiếp tục thanh toán | Hậu: dải hiện khi store.hold khác null | P11a SCR-02; E-32 | Instance | - |
| DC-CustomerHomeView | + | onResumePaymentClicked(): void | Mở SCR-05 với lần giữ ghế đang chạy | Tiền: có lần giữ ghế ACTIVE. Hậu: điều hướng SCR-05 | P11a E-32 | Instance | - |
| DC-CustomerHomeView | + | onMenuSelected(target: ScreenId): void | Điều hướng tới màn hình khách; Huỷ vé khi chưa đăng nhập thì mở SCR-01 | Hậu: điều hướng | P11a E-10 đến E-12, E-41, E-44 | Instance | - |
| DC-RegisterAccountView | + | mount(): void | Mở form, gọi RegisterAccountStore.openForm | Hậu: form hiện | P07 UC-001 // requestRegistration; P11a SCR-22 | Instance | - |
| DC-RegisterAccountView | + | onSubmit(data: RegistrationData): Promise<void> | Kiểm nhanh định dạng email, số điện thoại 10 chữ số, mật khẩu từ 8 ký tự rồi gọi store.submitRegistration | Tiền: các ô đủ. Hậu: thành công thì điều hướng SCR-01 kèm thông báo; từ chối thì hiện lý do | P07 UC-001 // submitRegistrationData; REQ-107, REQ-108; BR-98, BR-99 | Instance | - |
| DC-RegisterAccountView | + | onCancel(): void | Huỷ yêu cầu, về SCR-02 | Hậu: điều hướng SCR-02, form bỏ | P07 UC-001 luồng *a; P11a E-43 | Instance | - |
| DC-RegisterAccountStore | + | openForm(): void | Đặt status READY, xoá refusal cũ | - | P07 UC-001 // startRegistration | Instance | - |
| DC-RegisterAccountStore | + | submitRegistration(data: RegistrationData): Promise<void> | Gửi yêu cầu đăng ký; thành công đặt registered = true | Tiền: status READY. Hậu: bị từ chối (trùng email, số điện thoại, mật khẩu ngắn) thì refusal; không giữ mật khẩu sau khi gửi | P07 UC-001 // registerAccount; rejectRegistration; BR-98, BR-99 | Instance | ApiError |
| DC-BrowseMoviesView | + | mount(): Promise<void> | Gọi store.loadMovieList | Hậu: danh sách hoặc MSG không có phim | P07 UC-003 // requestMovieList | Instance | - |
| DC-BrowseMoviesView | + | onMovieClicked(movieId: MovieId): Promise<void> | Gọi store.selectMovie rồi hiện SCR-24 | Hậu: điều hướng SCR-24 | P07 UC-003 // selectMovie; P11a E-45 | Instance | - |
| DC-BrowseMoviesView | + | onBackToListClicked(): void | Quay lại danh sách | Hậu: về SCR-23 | P11a E-46 | Instance | - |
| DC-BrowseMoviesStore | + | loadMovieList(): Promise<void> | Tải phim đang chiếu và sắp chiếu | Hậu: movies đủ hai nhóm; cả hai rỗng thì noMovies = true (MSG) | P07 UC-003 // startBrowsingMovies; // showMovieList; // notifyNoMovies | Instance | ApiError |
| DC-BrowseMoviesStore | + | selectMovie(movieId: MovieId): Promise<void> | Tải thông tin phim | Hậu: selected = phim | P07 UC-003 // viewMovieDetails; // showMovieDetails | Instance | ApiError |
| DC-BrowseShowtimesView | + | mount(): Promise<void> | Mở chế độ theo phim, tải lựa chọn | Hậu: danh sách phim hiện | P07 UC-004 // requestShowtimesByMovie; P11a SCR-25 | Instance | - |
| DC-BrowseShowtimesView | + | onModeChosen(mode: BrowseMode): Promise<void> | Chuyển giữa tra theo phim và theo cụm rạp, tải danh sách lựa chọn tương ứng | Hậu: criteria xoá, lựa chọn tải xong | P07 UC-004 // requestShowtimesByCinema | Instance | - |
| DC-BrowseShowtimesView | + | onSearchSubmitted(criteria: BrowseCriteria): Promise<void> | Gửi tiêu chí (phim hoặc cụm rạp, tỉnh thành phố, ngày, loại phòng, định dạng) | Tiền: đã chọn phim hoặc cụm rạp. Hậu: lịch chiếu hoặc MSG không có suất | P07 UC-004 // selectMovieAndCriteria, // selectCinemaAndCriteria | Instance | - |
| DC-BrowseShowtimesStore | + | loadMovieChoices(): Promise<void> | Tải danh sách tên phim đang chiếu, sắp chiếu | Hậu: movieChoices | P07 UC-004 // startBrowsingByMovie; // showMovieList | Instance | ApiError |
| DC-BrowseShowtimesStore | + | loadCinemaChoices(): Promise<void> | Tải danh sách tên cụm rạp | Hậu: cinemaChoices | P07 UC-004 // startBrowsingByCinema; // showCinemaList | Instance | ApiError |
| DC-BrowseShowtimesStore | + | findShowtimes(criteria: BrowseCriteria): Promise<void> | Tìm suất chiếu theo tiêu chí; ngày chiếu hiểu theo múi giờ Asia/Ho_Chi_Minh ở máy chủ | Hậu: showtimes; rỗng thì noShowtimes = true | P07 UC-004 // findShowtimesByMovie, // findShowtimesByCinema; Q-268 | Instance | ApiError |
| DC-ViewBookingHistoryView | + | mount(): Promise<void> | Gọi store.loadHistory | Hậu: danh sách hoặc MSG chưa có lần đặt | P07 UC-007 // requestBookingHistory; P11a SCR-26 | Instance | - |
| DC-ViewBookingHistoryView | + | onBookingSelected(bookingCode: string): Promise<void> | Gọi store.openBooking rồi hiện SCR-27 | Hậu: điều hướng SCR-27 | P07 UC-007 // selectBooking; P11a E-50 | Instance | - |
| DC-ViewBookingHistoryView | + | onBackClicked(): void | Quay lại danh sách | Hậu: về SCR-26 | P11a E-51 | Instance | - |
| DC-ViewBookingHistoryStore | + | loadHistory(): Promise<void> | Tải các lần đặt của khách kèm trạng thái từng vé | Hậu: bookings; rỗng thì noBooking = true | P07 UC-007 // startViewHistory; // showBookingHistory; // showNoBooking; BR-99 | Instance | ApiError |
| DC-ViewBookingHistoryStore | + | openBooking(bookingCode: string): Promise<void> | Tải vé của một lần đặt thuộc khách; lần đặt của người khác bị từ chối | Hậu: tickets; từ chối thì refusal | P07 UC-007 // viewBookingTickets; // rejectBookingView; // showBookingTickets; BR-94 | Instance | ApiError |
| DC-CancelTicketView | + | mount(): Promise<void> | Gọi store.loadCancellableTickets | Hậu: danh sách vé hiện | P07 UC-008 // selectTicketToCancel (chuẩn bị); P11a SCR-07 | Instance | - |
| DC-CancelTicketView | + | onTicketSelected(ticketId: TicketId): void | Mở hộp xác nhận huỷ | Hậu: confirming = ticketId | P11a SCR-07 | Instance | - |
| DC-CancelTicketView | + | onCancelConfirmed(): Promise<void> | Gọi store.cancelTicket rồi hiện SCR-08 | Tiền: confirming khác null. Hậu: điều hướng SCR-08 khi thành công; từ chối thì ở lại SCR-07 với thông điệp | P07 UC-008 // selectTicketToCancel; P11a E-20 | Instance | - |
| DC-CancelTicketView | + | onCancelDismissed(): void | Đóng hộp xác nhận | Hậu: confirming = null | P11a SCR-07 | Instance | - |
| DC-CancelTicketStore | + | loadCancellableTickets(): Promise<void> | Tải vé mua trực tuyến của khách còn huỷ được | Hậu: tickets | Bổ sung: SCR-07 cần danh sách để chọn (P07 UC-008 không có message) | Instance | ApiError |
| DC-CancelTicketStore | + | cancelTicket(ticketId: TicketId): Promise<void> | Gửi yêu cầu huỷ; thành công giữ CancelResultView (số tiền hoàn, hình thức, tình trạng hoàn tiền) | Tiền: status READY. Hậu: SUBMITTING trong lúc gửi; từ chối (quá hạn, đã dùng, đã huỷ) thì refusal | P07 UC-008 // requestCancellation; // showCancellationResult; // notifyRefusal; BR-27 đến BR-29 | Instance | ApiError |
| DC-BookTicketsView | + | mount(route: BookingRoute): Promise<void> | Chọn màn theo route: SCR-03 mặc định, SCR-05 khi có lần giữ ghế đang chạy, SCR-06 khi quay về từ cổng | Hậu: store khởi động tương ứng | P11a E-13, E-18, E-32, E-34 | Instance | - |
| DC-BookTicketsView | + | unmount(): void | Gọi store.dispose | Hậu: SeatMapSyncClient dừng | Bổ sung: rời màn hình | Instance | - |
| DC-BookTicketsView | + | handleLoginRequired(): void | Mở LoginView dạng POPUP; đăng nhập xong thì gọi lại store.confirmSeatSelection với tập ghế đã chọn | Tiền: store.needsLogin. Hậu: tập chọn không đổi | P07 UC-005 // requestLogin, // provideCredentials; luồng 5a1; P11a E-14 | Instance | - |
| DC-BookTicketsView | + | navigateTo(screen: BookingScreen): void | Chuyển giữa SCR-03 đến SCR-06 và về SCR-02 | Hậu: URL và màn hình đổi | P11a E-13 đến E-19 | Instance | - |
| DC-BookTicketsView | + | onLeaveRequested(): boolean | Hỏi MSG-77 khi rời SCR-05 qua menu | Hậu: lần giữ ghế vẫn chạy khi rời | P11a SCR-05 mục 5; Q-119 | Instance | - |
| DC-SelectShowtimePage | + | mount(): Promise<void> | Tải danh sách suất chiếu mở bán | Hậu: danh sách hiện | P07 UC-005 // selectShowtime (chuẩn bị); P11a SCR-03; Q-335 | Instance | - |
| DC-SelectShowtimePage | + | onShowtimeChosen(showtimeId: ShowtimeId): Promise<void> | Gọi store.openShowtime; thành công điều hướng SCR-04 | Tiền: suất đã mở bán, chưa bắt đầu. Hậu: bị từ chối thì ở lại với thông điệp | P07 UC-005 // selectShowtime; P11a E-13 | Instance | - |
| DC-SelectSeatsPage | + | onSeatClicked(seatId: SeatId): void | Gọi store.toggleSeat | Hậu: tập chọn đổi | P07 UC-005 // confirmSeatSelection (chọn ghế) | Instance | - |
| DC-SelectSeatsPage | + | onConfirmSelection(): Promise<void> | Gọi store.confirmSeatSelection; kết quả điều hướng SCR-05, SCR-02, SCR-03 hoặc mở pop-up đăng nhập | Hậu: theo phase của store | P07 UC-005 // confirmSeatSelection; P11a E-14 đến E-17 | Instance | - |
| DC-SelectSeatsPage | + | onReconnectClicked(): Promise<void> | Gọi syncClient.reload khi kết nối mất (dải MSG-24) | Hậu: sơ đồ tải lại | P11a SCR-04 (UI-STT 41) | Instance | - |
| DC-HoldAndPayPage | + | mount(): Promise<void> | Nạp lần giữ ghế đang chạy nếu store chưa có | Hậu: hold hiện, đếm ngược chạy | P11a SCR-05 mục 1; E-32, E-34 | Instance | - |
| DC-HoldAndPayPage | + | onPayClicked(): Promise<void> | Gọi store.startOnlinePayment rồi chuyển trình duyệt sang địa chỉ cổng trả về | Tiền: phase HELD. Hậu: mỗi lần bấm tạo địa chỉ mới (BR-90); lỗi trước lúc chuyển thì ở lại SCR-05 | P07 UC-005 // requestOnlinePayment; MSG-26, MSG-27 | Instance | - |
| DC-HoldAndPayPage | + | onCancelHoldClicked(): void | Mở hộp xác nhận MSG-18 | Hậu: confirmingCancel = true | P11a SCR-05 mục 4 | Instance | - |
| DC-HoldAndPayPage | + | onCancelHoldConfirmed(): Promise<void> | Gọi store.cancelHold rồi mở SCR-02 kèm MSG-19 | Hậu: điều hướng SCR-02 | P07 UC-005 // cancelSeatHold; luồng *a | Instance | - |
| DC-HoldAndPayPage | + | onCountdownExpired(): void | Vô hiệu hai nút, hiện MSG-14, mở SCR-02 | Hậu: điều hướng SCR-02 | P07 UC-005 luồng 7b | Instance | - |
| DC-BookingResultPage | + | mount(holdRef: string): Promise<void> | Gọi store.loadPaymentOutcome(holdRef) | Hậu: kết quả hiện hoặc trạng thái đang chờ | P07 UC-005 // showPaymentOutcome, // showBookingSuccess | Instance | - |
| DC-BookingResultPage | + | onBackToPaymentClicked(): void | Mở lại SCR-05 khi lần giữ ghế còn Đang giữ | Hậu: điều hướng SCR-05 | P11a E-34 | Instance | - |
| DC-BookingResultPage | + | onBackHomeClicked(): void | Về SCR-02 | Hậu: điều hướng SCR-02 | P11a SCR-06 | Instance | - |
| DC-BookTicketsStore | + | loadBookableShowtimes(): Promise<void> | Tải suất chiếu mở bán để chọn ở SCR-03 | Hậu: showtimes | P07 UC-005 // selectShowtime (chuẩn bị); Q-335 | Instance | ApiError |
| DC-BookTicketsStore | + | startOnlinePayment(): Promise<string> | Yêu cầu tạo giao dịch thanh toán cho lần giữ ghế; trả địa chỉ cổng để View chuyển trình duyệt | Tiền: phase HELD. Hậu: phase PAYMENT_REDIRECTING rồi trả địa chỉ; lỗi thì phase HELD và refusal; mỗi lần tạo địa chỉ mới (BR-90) | P07 UC-005 // startOnlinePayment; BR-90; MSG-26, MSG-27 | Instance | ApiError |
| DC-BookTicketsStore | + | loadPaymentOutcome(holdRef: string): Promise<void> | Đọc trạng thái giao dịch của lần giữ ghế: hỏi lại mỗi 2 giây tối đa 30 giây cho tới khi có kết quả cuối | Tiền: holdRef không rỗng. Hậu: BOOKED kèm mã đặt vé; ENDED (endReason PAYMENT_FAILED); hết 30 giây vẫn chưa rõ thì giữ AWAITING_RESULT kèm thông báo kiểm lại lịch sử (Q-334); chạy lại khi tải lại trang an toàn (chỉ đọc) | P07 UC-005 // showPaymentOutcome, // showBookingSuccess; BR-90; P11a E-18 | Instance | ApiError |
| DC-CounterHomeView | + | mount(): Promise<void> | Nạp lần giữ ghế đang chạy của nhân viên để hiện dải Tiếp tục | Hậu: dải hiện khi store.hold khác null | P11a SCR-09; E-33 | Instance | - |
| DC-CounterHomeView | + | onResumeCashClicked(): void | Mở SCR-11 với lần giữ ghế đang chạy | Tiền: có lần giữ ghế ACTIVE. Hậu: điều hướng SCR-11 | P11a E-33 | Instance | - |
| DC-CounterHomeView | + | onMenuSelected(target: ScreenId): void | Điều hướng tới SCR-10 hoặc SCR-13 | Hậu: điều hướng | P11a E-21, E-22 | Instance | - |
| DC-CounterBookTicketsView | + | mount(route: CounterBookingRoute): Promise<void> | Chọn màn theo route: SCR-10 mặc định, SCR-11 khi có lần giữ ghế đang chạy | Hậu: store khởi động tương ứng | P11a E-23, E-33 | Instance | - |
| DC-CounterBookTicketsView | + | unmount(): void | Gọi store.dispose | Hậu: SeatMapSyncClient dừng | Bổ sung: rời màn hình | Instance | - |
| DC-CounterBookTicketsView | + | navigateTo(screen: CounterBookingScreen): void | Chuyển giữa SCR-10 đến SCR-12 và về SCR-09 | Hậu: màn hình đổi | P11a E-23 đến E-26 | Instance | - |
| DC-CounterBookTicketsView | + | onLeaveRequested(): boolean | Hỏi MSG-77 khi rời SCR-11 qua menu | Hậu: lần giữ ghế vẫn chạy khi rời | P11a SCR-11 | Instance | - |
| DC-CounterSelectSeatsPage | + | mount(): Promise<void> | Tải suất chiếu của cụm rạp của nhân viên | Hậu: danh sách hiện | P07 UC-005 // selectShowtime (chuẩn bị); P11a SCR-10; Q-335 | Instance | - |
| DC-CounterSelectSeatsPage | + | onShowtimeChosen(showtimeId: ShowtimeId): Promise<void> | Gọi store.openShowtime, hiện sơ đồ ghế | Tiền: suất thuộc cụm rạp của nhân viên (BR-02). Hậu: bị từ chối thì thông điệp, ở lại SCR-10 | P07 UC-005 // selectShowtime; luồng 2a, 2b, 2c | Instance | - |
| DC-CounterSelectSeatsPage | + | onSeatClicked(seatId: SeatId): void | Gọi store.toggleSeat | Hậu: tập chọn đổi | P07 UC-005 // confirmSeatSelection (chọn ghế) | Instance | - |
| DC-CounterSelectSeatsPage | + | onConfirmSelection(): Promise<void> | Gọi store.confirmSeatSelection; thành công mở SCR-11, bị từ chối về SCR-09 | Hậu: theo phase của store | P07 UC-005 // confirmSeatSelection; P11a E-23, E-24 | Instance | - |
| DC-CounterHoldAndCashPage | + | mount(): Promise<void> | Nạp lần giữ ghế đang chạy nếu store chưa có | Hậu: hold hiện, đếm ngược chạy | P11a E-33 | Instance | - |
| DC-CounterHoldAndCashPage | + | onCashReceivedClicked(): Promise<void> | Gọi store.confirmCashReceived; thành công mở SCR-12; xác nhận trễ (9a1a) thì thông báo trả lại tiền mặt và về SCR-09 | Tiền: phase HELD. Hậu: chỉ gọi một lần mỗi lần bấm (khoá nút khi đang gửi) | P07 UC-005 // confirmCashReceived; luồng 9a1, 9a1a; P11a E-25, E-26 | Instance | - |
| DC-CounterHoldAndCashPage | + | onCancelHoldConfirmed(): Promise<void> | Gọi store.cancelHold rồi về SCR-09 | Hậu: điều hướng SCR-09 | P07 UC-005 luồng *a | Instance | - |
| DC-CounterHoldAndCashPage | + | onCountdownExpired(): void | Vô hiệu nút, hiện MSG-29, về SCR-09 | Hậu: điều hướng SCR-09 | P07 UC-005 luồng 7b | Instance | - |
| DC-CounterPrintTicketsPage | + | onPrintClicked(): void | Mở hộp thoại in của trình duyệt cho vùng vé | Hậu: không đổi dữ liệu máy chủ | P07 UC-005 // printTickets; P01 (máy in nối máy tính tại quầy) | Instance | - |
| DC-CounterPrintTicketsPage | + | onBackHomeClicked(): void | Về SCR-09 | Hậu: store.reset | P11a SCR-12 | Instance | - |
| DC-CounterBookTicketsStore | + | loadCinemaShowtimes(): Promise<void> | Tải suất chiếu của cụm rạp của nhân viên (cụm rạp lấy từ phiên ở máy chủ) | Hậu: showtimes | P07 UC-005 // selectShowtime (chuẩn bị); BR-02; Q-335 | Instance | ApiError |
| DC-CounterBookTicketsStore | - | reconcileCashResult(): Promise<void> | Sau NetworkError của confirmCashReceived: hỏi máy chủ trạng thái lần giữ ghế; COMPLETED thì nạp mã đặt vé và vé để in, ACTIVE thì cho xác nhận lại, trạng thái cuối khác thì kết thúc | Hậu: phase BOOKED, HELD hoặc ENDED theo máy chủ; chỉ đọc nên chạy lặp an toàn | P07 UC-005 luồng 9a1a; BR-44; Q-341 | Instance | ApiError |
| DC-CounterBookTicketsStore | + | confirmCashReceived(): Promise<void> | Gửi xác nhận đã thu tiền mặt; thành công giữ mã đặt vé và các vé để in | Tiền: phase HELD. Hậu: phase BOOKED (ST-17); lần giữ ghế đã Hết hạn, Đã huỷ hoặc Thanh toán thất bại thì HoldNotActive và refusal "trả lại tiền mặt" (9a1a), phase theo trạng thái cuối; KHÔNG tự gửi lại khi mất mạng (gửi lại sau khi đã bán bị HoldNotActive, tiền mặt bị báo nhầm là phải trả lại): gặp NetworkError thì gọi reconcileCashResult | P07 UC-005 // confirmCashReceived; // showTicketsForPrint; luồng 9a1, 9a1a, 9a4; BR-44, BR-86 | Instance | ApiError |
| DC-CounterCancelTicketView | + | mount(): void | Mở SCR-13 | Hậu: ô nhập hiện | P11a SCR-13 | Instance | - |
| DC-CounterCancelTicketView | + | onBookingCodeSubmitted(code: string): Promise<void> | Gọi store.findBooking | Hậu: vé hiện hoặc thông báo mã không tồn tại | P07 UC-008 // enterBookingCode; P11a SCR-13 | Instance | - |
| DC-CounterCancelTicketView | + | onTicketCancelConfirmed(ticketId: TicketId): Promise<void> | Gọi store.cancelTicket rồi hiện SCR-14 | Hậu: điều hướng SCR-14 khi thành công | P07 UC-008 // selectTicketToCancel; P11a E-27 | Instance | - |
| DC-CounterCancelTicketView | + | onCashRefundConfirmed(): Promise<void> | Gọi store.confirmCashRefunded rồi hiện SCR-15 | Tiền: nhân viên đã hoàn tiền mặt cho khách. Hậu: điều hướng SCR-15 | P07 UC-008 // confirmCashRefunded; P11a E-28 | Instance | - |
| DC-CounterCancelTicketView | + | onBackHomeClicked(): void | Về SCR-09 | Hậu: store.reset | P11a SCR-15 | Instance | - |
| DC-CounterCancelTicketStore | + | findBooking(code: string): Promise<void> | Tìm các vé của lần đặt theo mã đặt vé và kiểm vé mua tại quầy của cụm rạp mình | Hậu: bookingTickets; mã không tồn tại hoặc khác cụm rạp thì refusal | P07 UC-008 // findBookingTickets; // showBookingTickets; // notifyRefusal; UC-008 2c | Instance | ApiError |
| DC-CounterCancelTicketStore | + | cancelTicket(ticketId: TicketId): Promise<void> | Gửi yêu cầu huỷ vé; vé mua tại quầy thì nhận CounterCashRefundView | Tiền: bookingTickets có vé. Hậu: cashRefund = số tiền mặt cần hoàn | P07 UC-008 // requestCancellation; // showCashRefund | Instance | ApiError |
| DC-CounterCancelTicketStore | + | confirmCashRefunded(ticketId: TicketId): Promise<void> | Gửi xác nhận đã hoàn tiền mặt | Tiền: cashRefund khác null. Hậu: result = kết quả huỷ; gọi lặp trả cùng kết quả | P07 UC-008 // confirmCashRefunded; // showCancellationResult | Instance | ApiError |
| DC-CounterCancelTicketStore | + | reset(): void | Xoá lần đặt, hoàn tiền, kết quả | Hậu: trạng thái ban đầu | Bổ sung: kết thúc luồng | Instance | - |
| DC-CheckTicketView | + | mount(): Promise<void> | Tải suất chiếu của cụm rạp, khôi phục suất đang soát từ sessionStorage | Hậu: nếu đã chọn suất thì mở camera | P11a SCR-16 | Instance | - |
| DC-CheckTicketView | + | onShowtimeChosen(showtimeId: ShowtimeId): Promise<void> | Gọi store.selectCheckingShowtime rồi mở camera | Hậu: suất chiếu đang soát hiện | P07 UC-009 // selectCheckingShowtime; P11a SCR-16 | Instance | - |
| DC-CheckTicketView | + | onQrDecoded(text: string): Promise<void> | Nhận chuỗi từ thư viện đọc QR, gọi store.scanTicket | Tiền: đã chọn suất. Hậu: kết quả hiện và camera tiếp tục đọc | P07 UC-009 // scanTicketQr | Instance | - |
| DC-CheckTicketView | + | onCameraError(error: CameraError): void | Hiện thông báo không dùng được camera (từ chối quyền, không có thiết bị) | Hậu: không gọi API | P11a SCR-16; P10 F3 (camera là kênh nhập) | Instance | - |
| DC-CheckTicketView | + | onChangeShowtimeClicked(): void | Bỏ suất đang soát để chọn lại | Hậu: store.clearShowtime | P07 UC-009 // selectCheckingShowtime | Instance | - |
| DC-CheckTicketStore | + | loadShowtimesToCheck(): Promise<void> | Tải suất chiếu của cụm rạp của nhân viên soát vé | Hậu: showtimes | Bổ sung: SCR-16 cần danh sách để chọn (Q-335) | Instance | ApiError |
| DC-CheckTicketStore | + | selectCheckingShowtime(showtimeId: ShowtimeId): Promise<void> | Tải thông tin suất chiếu, giữ suất trong phiên làm việc | Hậu: checkingShowtime, ghi sessionStorage (Q-336) | P07 UC-009 // startChecking; // showCheckingShowtime | Instance | ApiError |
| DC-CheckTicketStore | + | scanTicket(qrText: string): Promise<void> | Gửi chuỗi QR và suất đang soát; máy chủ tự tra vé (NFR-14); kết quả ADMITTED hiện nội dung vé trừ mã QR, lý do khác hiện đúng một lý do theo thứ tự BR-33 | Tiền: checkingShowtime khác null. Hậu: lastResult; bỏ qua quét trùng như Ghi chú; vé chỉ vào được một lần ở máy chủ | P07 UC-009 // checkTicket; // showValidTicket; // rejectTicket; BR-33 | Instance | ApiError |
| DC-CheckTicketStore | + | clearShowtime(): void | Bỏ suất đang soát và kết quả | Hậu: checkingShowtime = null, xoá sessionStorage | Bổ sung: đổi suất | Instance | - |
| DC-CinemaAdminHomeView | + | onMenuSelected(target: ScreenId): void | Điều hướng tới SCR-18, SCR-19, SCR-28 hoặc SCR-30 | Hậu: điều hướng | P11a E-29, E-30 | Instance | - |
| DC-ManagePriceListView | + | mount(): Promise<void> | Gọi store.loadPriceList | Hậu: bảng giá hiện | P07 UC-013 // requestPriceListSetup; P11a SCR-18 | Instance | - |
| DC-ManagePriceListView | + | onEntrySubmitted(entry: PriceEntryInput): Promise<void> | Kiểm nhanh giá nguyên dương rồi gọi store.savePriceEntry | Hậu: mục giá đã lưu hiện | P07 UC-013 // enterPriceEntry; BR-67 (giá không đổi vé đã bán) | Instance | - |
| DC-ManagePriceListView | + | onRemoveClicked(entryKey: PriceEntryKey): void | Mở hộp xác nhận bỏ giá | Hậu: confirmingRemoval = entryKey | P07 UC-013 // requestPriceRemoval; P11a SCR-18 | Instance | - |
| DC-ManagePriceListView | + | onRemoveConfirmed(): Promise<void> | Gọi store.removePriceEntry | Tiền: confirmingRemoval khác null | P07 UC-013 // selectPriceEntryToRemove | Instance | - |
| DC-ManagePriceListView | + | onCancelClicked(): void | Huỷ yêu cầu, về SCR-17 | Hậu: điều hướng SCR-17 | P07 UC-013 // cancelRequest | Instance | - |
| DC-ManagePriceListStore | + | loadPriceList(): Promise<void> | Tải bảng giá, giữ lastChangedAt của từng mục lúc hiển thị | Hậu: priceList | P07 UC-013 // startPriceListSetup; // showPriceList | Instance | ApiError |
| DC-ManagePriceListStore | + | savePriceEntry(entry: PriceEntryInput): Promise<void> | Gửi tổ hợp và giá kèm tình trạng mục giá lúc hiển thị | Tiền: status READY. Hậu: thành công thì cập nhật mục giá; bị từ chối (đã bị sửa, vi phạm quy tắc) thì refusal và nạp lại bảng giá | P07 UC-013 // submitPriceEntry; // showSavedPriceEntry; // notifyRefusal | Instance | ApiError |
| DC-ManagePriceListStore | + | removePriceEntry(entryKey: PriceEntryKey): Promise<void> | Gửi yêu cầu bỏ giá kèm tình trạng lúc hiển thị | Hậu: mục giá khỏi priceList hoặc refusal | P07 UC-013 // startPriceRemoval, // submitPriceEntryRemoval; // showRemovalSuccess | Instance | ApiError |
| DC-ScheduleShowtimesView | + | mount(): Promise<void> | Gọi store.loadShowtimes | Hậu: danh sách hiện | P07 UC-014 // requestNewShowtime (chuẩn bị); P11a SCR-19 | Instance | - |
| DC-ScheduleShowtimesView | + | onNewClicked(): Promise<void> | Gọi store.openCreateForm, mở SCR-20 | Hậu: form trống hiện | P07 UC-014 // requestNewShowtime; P11a E-31 | Instance | - |
| DC-ScheduleShowtimesView | + | onEditClicked(showtimeId: ShowtimeId): Promise<void> | Gọi store.openEditForm; suất không sửa được thì thông báo | Hậu: form có dữ liệu hiện | P07 UC-014 // requestEditShowtime, // selectShowtimeToEdit; P11a E-31 | Instance | - |
| DC-ScheduleShowtimesView | + | onDeleteClicked(showtimeId: ShowtimeId): void | Mở hộp xác nhận xoá | Hậu: confirmingDelete = showtimeId | P07 UC-014 // requestDeleteShowtime | Instance | - |
| DC-ScheduleShowtimesView | + | onDeleteConfirmed(): Promise<void> | Gọi store.deleteShowtime | Tiền: confirmingDelete khác null | P07 UC-014 // selectShowtimeToDelete | Instance | - |
| DC-ScheduleShowtimesView | + | onFormSubmitted(input: ShowtimeInput): Promise<void> | Gọi store.saveShowtime; thành công đóng pop-up | Hậu: về SCR-19 khi thành công; từ chối thì ở lại form | P07 UC-014 // submitShowtimeInfo; P11a SCR-20 | Instance | - |
| DC-ScheduleShowtimesView | + | onFormCancelled(): void | Đóng form, báo yêu cầu đã huỷ | Hậu: store.cancelForm | P07 UC-014 // cancelRequest | Instance | - |
| DC-ScheduleShowtimesStore | + | loadShowtimes(): Promise<void> | Tải suất chiếu của cụm rạp | Hậu: showtimes | P07 UC-014 // startEditingShowtime, // startDeletingShowtime; // showShowtimes | Instance | ApiError |
| DC-ScheduleShowtimesStore | + | openCreateForm(): Promise<void> | Tải phòng chiếu của cụm rạp và danh sách phim, mở form trống | Hậu: form.mode = CREATE | P07 UC-014 // startScheduling; // showAuditoriumsAndMovies | Instance | ApiError |
| DC-ScheduleShowtimesStore | + | openEditForm(showtimeId: ShowtimeId): Promise<void> | Tải thông tin suất, phòng chiếu và phim để sửa; ghi displayedAt | Tiền: suất đạt kiểm sửa được (1a3). Hậu: form.mode = EDIT | P07 UC-014 // prepareShowtimeEdit; // showShowtimeForEdit; luồng 1a3a, 1a3b | Instance | ApiError |
| DC-ScheduleShowtimesStore | + | saveShowtime(input: ShowtimeInput): Promise<void> | Gửi suất chiếu (phim, định dạng, phòng, giờ bắt đầu, thời điểm mở bán) kèm displayedAt khi sửa | Tiền: status READY. Hậu: thành công thì showtimes cập nhật, form đóng; từ chối (trùng giờ, phim hoặc phòng đã đổi, đã có vé) thì refusal và form giữ dữ liệu nhập | P07 UC-014 // requestSaveShowtime; // showSavedShowtime; // notifyRefusal (19 lý do); BR-47 đến BR-50, BR-54 | Instance | ApiError |
| DC-ScheduleShowtimesStore | + | deleteShowtime(showtimeId: ShowtimeId): Promise<void> | Gửi yêu cầu xoá kèm displayedAt | Hậu: suất khỏi showtimes hoặc refusal | P07 UC-014 // deleteShowtime; // notifyDeleted | Instance | ApiError |
| DC-ScheduleShowtimesStore | + | cancelForm(): void | Đóng form, xoá dữ liệu nhập | Hậu: form = null | P07 UC-014 // cancelRequest, // showRequestCancelled | Instance | - |
| DC-ManageAuditoriumsView | + | mount(): Promise<void> | Gọi store.loadAuditoriums | Hậu: danh sách hiện | P07 UC-012 // requestAuditoriumAddition (chuẩn bị); P11a SCR-28 | Instance | - |
| DC-ManageAuditoriumsView | + | onAddClicked(): void | Gọi store.openAddForm, mở SCR-29 | Hậu: form trống hiện | P07 UC-012 // requestAuditoriumAddition; P11a SCR-29 | Instance | - |
| DC-ManageAuditoriumsView | + | onEditClicked(auditoriumId: AuditoriumId): Promise<void> | Gọi store.openEditForm | Hậu: form có từng ghế hiện | P07 UC-012 // requestAuditoriumEdit, // selectAuditoriumToEdit | Instance | - |
| DC-ManageAuditoriumsView | + | onRemoveClicked(auditoriumId: AuditoriumId): void | Mở hộp xác nhận xoá phòng | Hậu: confirmingRemoval đặt | P07 UC-012 // requestAuditoriumRemoval | Instance | - |
| DC-ManageAuditoriumsView | + | onRemoveConfirmed(): Promise<void> | Gọi store.removeAuditorium | Tiền: confirmingRemoval khác null | P07 UC-012 // selectAuditoriumToRemove | Instance | - |
| DC-ManageAuditoriumsView | + | onFormSubmitted(input: AuditoriumInput): Promise<void> | Kiểm nhanh sức chứa 50 đến 400 rồi gọi store.saveAuditorium | Hậu: về SCR-28 khi thành công | P07 UC-012 // enterAuditoriumInfo; BR-144, BR-145 | Instance | - |
| DC-ManageAuditoriumsView | + | onFormCancelled(): void | Đóng form | Hậu: store.cancelForm | P07 UC-012 // cancelRequest | Instance | - |
| DC-ManageAuditoriumsStore | + | loadAuditoriums(): Promise<void> | Tải phòng chiếu của cụm rạp kèm lastChangedAt | Hậu: auditoriums | P07 UC-012 // startAuditoriumAddition (danh sách), // startAuditoriumEdit, // startAuditoriumRemoval; // showAuditoriumList | Instance | ApiError |
| DC-ManageAuditoriumsStore | + | openAddForm(): void | Mở form phòng chiếu trống | Hậu: form.mode = CREATE | P07 UC-012 // startAuditoriumAddition | Instance | - |
| DC-ManageAuditoriumsStore | + | openEditForm(auditoriumId: AuditoriumId): Promise<void> | Tải thông tin phòng và từng ghế để sửa; ghi lastChangedAt | Hậu: form.mode = EDIT | P07 UC-012 // selectAuditorium; // showAuditoriumForEdit | Instance | ApiError |
| DC-ManageAuditoriumsStore | + | saveAuditorium(input: AuditoriumInput): Promise<void> | Gửi tên, loại phòng, định dạng chiếu được, sơ đồ ghế kèm lastChangedAt khi sửa | Hậu: thành công thì hiện phòng đã lưu và sức chứa; từ chối (tên trùng, sức chứa ngoài 50..400, phòng đã bị sửa, ghế có suất chiếu) thì refusal, form giữ nhập | P07 UC-012 // submitAuditorium; // showSavedAuditorium; // notifyRefusal; BR-141, BR-144 đến BR-147 | Instance | ApiError |
| DC-ManageAuditoriumsStore | + | removeAuditorium(auditoriumId: AuditoriumId): Promise<void> | Gửi yêu cầu xoá kèm lastChangedAt | Hậu: phòng khỏi auditoriums hoặc refusal (phòng đã từng có suất chiếu, BR-147) | P07 UC-012 // submitAuditoriumRemoval; // showRemovalSuccess | Instance | ApiError |
| DC-ManageAuditoriumsStore | + | cancelForm(): void | Đóng form | Hậu: form = null | P07 UC-012 // cancelRequest | Instance | - |
| DC-ViewCinemaReportView | + | onReportRequested(request: ReportFormInput): Promise<void> | Kiểm nhanh từ ngày không sau đến ngày rồi gọi store.requestReport | Hậu: báo cáo hoặc thông báo kỳ không hợp lệ, không có suất chiếu | P07 UC-015 // requestCinemaReport; GL-66; BR-115 | Instance | - |
| DC-ViewCinemaReportStore | + | requestReport(request: ReportFormInput): Promise<void> | Gửi kỳ và cách xem; cụm rạp lấy từ phiên ở máy chủ, không gửi từ trình duyệt | Hậu: report; kỳ sai thì notice INVALID_PERIOD; không có suất chiếu thì notice NO_SHOWTIMES; yêu cầu mới thay yêu cầu đang chạy (bỏ kết quả cũ) | P07 UC-015 // startCinemaReport; // showReport; // notifyInvalidPeriod; // notifyNoShowtimes; P09 F7.12 | Instance | ApiError |
| DC-ChainAdminHomeView | + | onMenuSelected(target: ScreenId): void | Điều hướng tới SCR-32, SCR-34 hoặc SCR-36 | Hậu: điều hướng | P11a SCR-31 | Instance | - |
| DC-ManageMoviesView | + | mount(): Promise<void> | Gọi store.loadMovies | Hậu: danh sách hiện | P07 UC-010 // requestMovieEdit (chuẩn bị); P11a SCR-32 | Instance | - |
| DC-ManageMoviesView | + | onAddClicked(): void | Gọi store.openAddForm, mở SCR-33 | Hậu: form trống hiện | P07 UC-010 // requestMovieAddition | Instance | - |
| DC-ManageMoviesView | + | onEditClicked(movieId: MovieId): Promise<void> | Gọi store.openEditForm | Hậu: form có dữ liệu hiện | P07 UC-010 // requestMovieEdit, // selectMovieToEdit | Instance | - |
| DC-ManageMoviesView | + | onFormSubmitted(input: MovieInput): Promise<void> | Gọi store.saveMovie; thành công đóng pop-up | Hậu: về SCR-32 khi thành công; từ chối thì ở lại form | P07 UC-010 // enterMovieInfo; BR-138, BR-139 | Instance | - |
| DC-ManageMoviesView | + | onFormCancelled(): void | Đóng form | Hậu: store.cancelForm | P07 UC-010 // cancelRequest | Instance | - |
| DC-ManageMoviesStore | + | loadMovies(): Promise<void> | Tải danh sách phim của chuỗi kèm lastChangedAt | Hậu: movies | P07 UC-010 // startMovieEdit; // showMovieList | Instance | ApiError |
| DC-ManageMoviesStore | + | openAddForm(): void | Mở form phim trống | Hậu: form.mode = CREATE | P07 UC-010 // startMovieAddition | Instance | - |
| DC-ManageMoviesStore | + | openEditForm(movieId: MovieId): Promise<void> | Tải thông tin phim để sửa, ghi lastChangedAt | Hậu: form.mode = EDIT | P07 UC-010 // selectMovie; // showMovieForEdit | Instance | ApiError |
| DC-ManageMoviesStore | + | saveMovie(input: MovieInput): Promise<void> | Gửi thông tin phim, định dạng phát hành, hai ngày kèm lastChangedAt khi sửa | Hậu: thành công hiện phim đã lưu; từ chối (điều kiện hợp lệ, phim đã bị sửa) thì refusal, form giữ nhập | P07 UC-010 // submitMovie, // submitMovieChanges; // showSavedMovie; // notifyRefusal; BR-138, BR-139 | Instance | ApiError |
| DC-ManageMoviesStore | + | cancelForm(): void | Đóng form | Hậu: form = null | P07 UC-010 // cancelRequest | Instance | - |
| DC-ManageCinemasView | + | mount(): Promise<void> | Gọi store.loadCinemas | Hậu: danh sách hiện | P07 UC-011 // requestCinemaEdit (chuẩn bị); P11a SCR-34 | Instance | - |
| DC-ManageCinemasView | + | onAddClicked(): void | Gọi store.openAddForm, mở SCR-35 | Hậu: form trống hiện | P07 UC-011 // requestCinemaAddition | Instance | - |
| DC-ManageCinemasView | + | onEditClicked(cinemaId: CinemaId): Promise<void> | Gọi store.openEditForm | Hậu: form có dữ liệu hiện | P07 UC-011 // requestCinemaEdit, // selectCinemaToEdit | Instance | - |
| DC-ManageCinemasView | + | onFormSubmitted(input: CinemaInput): Promise<void> | Gọi store.saveCinema | Hậu: về SCR-34 khi thành công | P07 UC-011 // enterCinemaInfo; BR-141, BR-142 | Instance | - |
| DC-ManageCinemasView | + | onFormCancelled(): void | Đóng form | Hậu: store.cancelForm | P07 UC-011 // cancelRequest | Instance | - |
| DC-ManageCinemasStore | + | loadCinemas(): Promise<void> | Tải cụm rạp của chuỗi kèm lastChangedAt | Hậu: cinemas | P07 UC-011 // startCinemaEdit; // showCinemaList | Instance | ApiError |
| DC-ManageCinemasStore | + | openAddForm(): void | Mở form cụm rạp trống | Hậu: form.mode = CREATE | P07 UC-011 // startCinemaAddition | Instance | - |
| DC-ManageCinemasStore | + | openEditForm(cinemaId: CinemaId): Promise<void> | Tải thông tin cụm rạp để sửa, ghi lastChangedAt | Hậu: form.mode = EDIT | P07 UC-011 // selectCinema; // showCinemaForEdit | Instance | ApiError |
| DC-ManageCinemasStore | + | saveCinema(input: CinemaInput): Promise<void> | Gửi tên, tỉnh hoặc thành phố, địa chỉ kèm lastChangedAt khi sửa | Hậu: thành công hiện cụm rạp đã lưu; từ chối (tên trùng, cụm rạp đã bị sửa) thì refusal, form giữ nhập | P07 UC-011 // submitCinema, // submitCinemaChanges; // showSavedCinema; // notifyRefusal; BR-141, BR-142 | Instance | ApiError |
| DC-ManageCinemasStore | + | cancelForm(): void | Đóng form | Hậu: form = null | P07 UC-011 // cancelRequest | Instance | - |
| DC-ViewChainReportView | + | onReportRequested(request: ReportFormInput): Promise<void> | Kiểm nhanh từ ngày không sau đến ngày rồi gọi store.requestReport | Hậu: báo cáo hoặc thông báo | P07 UC-016 // requestChainReport; GL-66; BR-115 | Instance | - |
| DC-ViewChainReportStore | + | requestReport(request: ReportFormInput): Promise<void> | Gửi kỳ và cách xem | Hậu: report gồm nhóm và so sánh từng cụm rạp; kỳ sai thì notice INVALID_PERIOD; không có suất chiếu thì NO_SHOWTIMES; yêu cầu mới thay yêu cầu đang chạy | P07 UC-016 // startChainReport; // showChainReport; // notifyInvalidPeriod; // notifyNoShowtimes; P09 F7.12 | Instance | ApiError |
| DC-ManageStaffAccountsView | + | mount(): Promise<void> | Gọi store.loadStaff | Hậu: danh sách hiện | P07 UC-017 // requestUpdateStaff (chuẩn bị); P11a SCR-37 | Instance | - |
| DC-ManageStaffAccountsView | + | onCreateClicked(): Promise<void> | Gọi store.openCreateForm, mở SCR-38 | Hậu: hộp thoại tạo hiện | P07 UC-017 // requestCreateStaff; P11a SCR-38 | Instance | - |
| DC-ManageStaffAccountsView | + | onRowActionSelected(action: StaffAction, staffId: StaffId): Promise<void> | Thực hiện hành động chọn trên một dòng: UPDATE mở SCR-38 (cập nhật), LOCK và UNLOCK gọi store.lockStaff, store.unlockStaff sau xác nhận, RENAME mở SCR-39, RESET_PASSWORD mở SCR-40 | Tiền: dòng đã hiển thị kèm lastChangedAt. Hậu: hộp thoại tương ứng hiện hoặc đổi trạng thái ngay | P07 UC-017 // requestUpdateStaff, // selectStaff, // requestLockStaff, // requestUnlockStaff, // requestRenameStaff, // requestResetStaffPassword | Instance | - |
| DC-ManageStaffAccountsView | + | onDialogSubmitted(dialog: StaffDialogInput): Promise<void> | Chuyển dữ liệu hộp thoại tới action tương ứng của store (createStaff, updateRoleAndCinema, renameStaff, resetPassword) | Hậu: thành công đóng hộp thoại và hiện thông báo; từ chối thì hộp thoại ở lại kèm lý do | P07 UC-017 // submitStaffData, // submitRoleAndCinema, // submitNewFullName, // submitNewPassword | Instance | - |
| DC-ManageStaffAccountsView | + | onDialogCancelled(): void | Đóng hộp thoại, báo yêu cầu đã huỷ | Hậu: store.cancelDialog | P07 UC-017 // cancelStaffRequest, // showStaffRequestCancelled | Instance | - |
| DC-ManageStaffAccountsStore | + | loadStaff(): Promise<void> | Tải danh sách tài khoản nhân viên kèm trạng thái, vai trò, cụm rạp, lastChangedAt | Hậu: staff | P07 UC-017 // startStaffAction; // showStaffList | Instance | ApiError |
| DC-ManageStaffAccountsStore | + | openCreateForm(): Promise<void> | Tải danh sách cụm rạp và bốn vai trò cho hộp thoại tạo | Hậu: choices; dialog tạo hiện | P07 UC-017 // startStaffCreation; // showStaffAccountChoices | Instance | ApiError |
| DC-ManageStaffAccountsStore | + | createStaff(data: StaffInput): Promise<void> | Gửi email, họ tên, mật khẩu ban đầu, vai trò, cụm rạp | Hậu: thành công thêm vào staff; từ chối (email trùng, mật khẩu dưới 8 ký tự, cụm rạp không hợp lệ với vai trò) thì refusal | P07 UC-017 // saveStaffAccount; // showSavedStaffAccount; // rejectStaffAccount; BR-78, BR-98, BR-99 | Instance | ApiError |
| DC-ManageStaffAccountsStore | + | openUpdateForm(staffId: StaffId): Promise<void> | Tải thông tin hiện tại, cụm rạp và vai trò cho hộp thoại cập nhật | Hậu: dialog cập nhật hiện | P07 UC-017 // openStaffForUpdate; // showStaffForUpdate | Instance | ApiError |
| DC-ManageStaffAccountsStore | + | updateRoleAndCinema(staffId: StaffId, role: StaffRole, cinemaId: CinemaId  |  null, displayedAt: string): Promise<void> | Hậu: thành công thì dòng cập nhật; từ chối (tài khoản đã bị sửa) thì refusal | Gửi vai trò và cụm rạp mới kèm mốc; P07 UC-017 // updateStaffAccount; BR-100, BR-101, BR-146 | Instance | ApiError |
| DC-ManageStaffAccountsStore | + | lockStaff(staffId: StaffId, displayedAt: string): Promise<void> | Gửi yêu cầu khoá; đã khoá thì notice STATUS_UNCHANGED | Hậu: dòng Đã khoá hoặc notice | P07 UC-017 // changeStaffStatus; // notifyStaffStatusUnchanged; // notifyStaffChanged | Instance | ApiError |
| DC-ManageStaffAccountsStore | + | unlockStaff(staffId: StaffId, displayedAt: string): Promise<void> | Gửi yêu cầu mở khoá; đang hoạt động thì notice STATUS_UNCHANGED | Hậu: dòng Đang hoạt động hoặc notice | P07 UC-017 // changeStaffStatus; // notifyStaffStatusUnchanged; // notifyStaffChanged | Instance | ApiError |
| DC-ManageStaffAccountsStore | + | renameStaff(staffId: StaffId, fullName: string, displayedAt: string): Promise<void> | Gửi họ tên mới kèm mốc | Hậu: dòng cập nhật hoặc refusal | P07 UC-017 // renameStaffAccount; // notifyStaffChanged | Instance | ApiError |
| DC-ManageStaffAccountsStore | + | resetPassword(staffId: StaffId, newPassword: string, displayedAt: string): Promise<void> | Gửi mật khẩu mới kèm mốc | Hậu: thành công thì notice CHANGED; mật khẩu không lưu trong state | P07 UC-017 // resetStaffAccountPassword; // notifyStaffChanged; BR-99 | Instance | ApiError |
| DC-ManageStaffAccountsStore | + | cancelDialog(): void | Đóng hộp thoại | Hậu: dialog = null | P07 UC-017 // cancelStaffRequest | Instance | - |
| DC-EmailOutboxJob | + | RunDue(ctx Ctx, budget time.Duration) (JobRunResult, error) | Lặp: claim một dòng EMAIL_TICKET hoặc EMAIL_REFUND đến hạn, xử lý hết dòng đó, tới khi hết việc hoặc hết budget | Tiền: budget > 0. Hậu: mỗi dòng đã claim kết thúc ở SUCCEEDED, PENDING (hẹn lại) hoặc EXHAUSTED; chạy lặp và nhiều bản backend gọi song song an toàn (claim_token) | P11b IF-06.runDue; P09 F7.7; NFR-07 | Instance | lỗi CSDL |
| DC-EmailOutboxJob | - | processEntry(ctx Ctx, e OutboxEntry) error | Dựng thư theo e.kind, gửi qua IF-03, ghi kết quả bằng giao dịch ngắn | Tiền: e đã claim. Hậu: đúng một trong MarkSucceeded, Reschedule, MarkExhausted được ghi, hoặc ClaimLostError thì bỏ dòng | P07 UC-005 msg 4.1.3; UC-006 msg 1.1.11; BR-89 | Instance | ClaimLostError |
| DC-EmailOutboxJob | - | composeTicketEmail(ctx Ctx, e OutboxEntry) (EmailMessage, error) | Đọc lần đặt và vé không khoá, đọc email khách, dựng thư HTML UTF-8 có nội dung từng vé và ảnh QR nhúng | Hậu: deduplicationKey = e.idempotencyKey; không đổi dữ liệu | P07 UC-005 // sendTicketsEmail (dữ liệu truyền); REQ-105; BR-140 | Instance | NotFoundError |
| DC-EmailOutboxJob | - | composeRefundEmail(ctx Ctx, e OutboxEntry) (EmailMessage, error) | Đọc yêu cầu hoàn, giao dịch, thông tin suất chiếu, email khách; dựng thư gồm mã giao dịch, số tiền hoàn, tên phim, suất chiếu, lý do hoàn | Hậu: không đổi dữ liệu | P07 UC-006 // sendRefundNotificationEmail (dữ liệu truyền); REQ-116 | Instance | NotFoundError |
| DC-EmailOutboxJob | - | applyResult(ctx Ctx, e OutboxEntry, r EmailSendResult) error | Accepted thì MarkSucceeded; Rejected thì MarkExhausted; TemporaryFailure thì Reschedule với delay theo attemptCount (1, 5, 15 phút) hoặc MarkExhausted khi đã đủ 3 lần thử lại | Hậu: ghi detail vào lastError | BR-89; P09 F7.7 | Instance | ClaimLostError |
| DC-EmailOutboxJob | - | retryDelay(attemptCount int) (time.Duration, bool) | Trả độ trễ lần thử kế (1, 5, 15 phút) hoặc false khi hết lượt | Thuần tính toán | BR-89 | Instance | - |
| IF-03 | + | SendEmail(ctx Ctx, message EmailMessage) (EmailSendResult, error) | Gửi một thư; Accepted, Rejected, TemporaryFailure là giá trị trả về, không phải error | Tiền: dòng hàng đợi đã claim, thư dựng đủ, không gọi trong giao dịch. Hậu: không đổi dữ liệu hệ thống; Message-ID lấy từ deduplicationKey; không bảo đảm idempotent (chấp nhận gửi trùng hiếm) | P11b IF-03.sendEmail; P07 UC-005 msg 4.1.3.1; UC-006 msg 1.1.11.1 | Instance | InvalidEmailMessageError |
| DC-EmailGatewayManager | + | SendEmail(ctx Ctx, message EmailMessage) (EmailSendResult, error) | Kiểm thư, dựng MIME, gửi, trả kết quả; ghi một dòng log gồm khoá chống lặp, trạng thái, mã trả lời (không ghi nội dung thư) | - | Xem IF-03; P11b IF-03.sendEmail | Instance | InvalidEmailMessageError |
| DC-EmailGatewayManager | - | validate(message EmailMessage) error | Kiểm địa chỉ đúng định dạng (REQ-107), tiêu đề và khoá chống lặp không rỗng | Thuần kiểm tra | P11b F3 tiền điều kiện | Instance | InvalidEmailMessageError |
| DC-MimeMessageBuilder | + | Build(message EmailMessage) ([]byte, error) | Dựng thư HTML UTF-8; mỗi attachment inline nhúng theo Content-ID; Message-ID = <deduplicationKey@miền cấu hình> | Hậu: cùng đầu vào cho cùng Message-ID | P11b SS-02 F5 | Instance | InvalidEmailMessageError |
| DC-SmtpClient | + | Send(ctx Ctx, to string, raw []byte) EmailSendResult | Kết nối (tối đa 10 giây), TLS, MAIL FROM, RCPT TO, DATA; toàn thư tối đa 30 giây; 2xx là Accepted, 5xx là Rejected, 4xx hoặc lỗi mạng là TemporaryFailure, maybeDelivered = true khi lỗi xảy ra sau khi đã gửi nội dung | Hậu: luôn đóng kết nối | P11b IF-03 timeout, F7 | Instance | - |
| DC-SmtpConfig | + | LoadSmtpConfig(getenv func(string) string) (SmtpConfig, error) | Đọc máy chủ, cổng, chế độ TLS, tài khoản, mật khẩu, địa chỉ người gửi, miền Message-ID; thiếu giá trị bắt buộc thì lỗi khởi động | Classifier. Hậu: mật khẩu không xuất hiện trong String() | P11b SS-02 F5 | Classifier | ConfigurationError |
| IF-42 | + | open(url: string, handlers: StreamHandlers): StreamHandle | Mở kết nối; handlers có onOpen, onSeatEvent, onReload, onHeartbeat, onError | Hậu: StreamHandle.close() đóng kết nối, gọi nhiều lần vô hại | Bổ sung: P09 F7.5 điểm 4 | Instance | - |
| DC-SeatMapReducer | + | fromSnapshot(snapshot: SeatMapSnapshot): SeatMapGrid | Dựng sơ đồ ghế từ ảnh chụp (ghế, state, eventSeq, con trỏ, showtimeChangedAt) | Hậu: cursor = snapshot.cursor | P09 F7.5 điểm 4 | Instance | - |
| DC-SeatMapReducer | + | applyEvent(map: SeatMapGrid, event: SeatEventView): SeatMapGrid | Với từng ghế trong sự kiện chỉ áp khi event.eventId > eventSeq hiện có của ghế; cập nhật cursor = max(cursor, eventId) | Hậu: sự kiện lặp, phát lại, lệch thứ tự giữa các ghế đều không đổi kết quả (chạy lặp an toàn); trả đối tượng mới | P07 UC-005 // updateSeatMap; P09 F7.5 điểm 5; NFR-08 | Instance | - |
| DC-SeatMapReducer | + | changedSeatIds(before: SeatMapGrid, after: SeatMapGrid): SeatId[] | Danh sách ghế đổi state giữa hai bản | Hậu: không đổi trạng thái | Bổ sung: DC-HoldFlowStore báo ghế đang chọn đã bị lấy (MSG-11) | Instance | - |
| DC-SeatMapSyncClient | + | start(showtimeId: ShowtimeId): Promise<void> | Tải ảnh chụp, dựng SeatMapGrid, mở kết nối đẩy với after = cursor | Tiền: trạng thái CLOSED. Hậu: connection LIVE khi kết nối mở; nếu ảnh chụp lỗi thì RELOAD_PENDING và hẹn thử lại | P07 UC-005 // showSeatMap; P09 F7.5 | Instance | ApiError |
| DC-SeatMapSyncClient | + | stop(): void | Đóng kết nối, huỷ hẹn giờ, về CLOSED | Hậu: không còn callback nào gọi sau stop | Bổ sung: rời màn hình | Instance | - |
| DC-SeatMapSyncClient | + | reload(): Promise<void> | Tải lại ảnh chụp rồi mở lại kết nối từ con trỏ mới | Hậu: sơ đồ thay bằng ảnh chụp mới; sự kiện áp theo eventSeq nên không mất hay lặp | P09 F7.5 điểm 6 (RELOAD_REQUIRED) | Instance | ApiError |
| DC-SeatMapSyncClient | + | currentMap(): SeatMapGrid | Sơ đồ ghế hiện tại | - | Bổ sung: quan sát | Instance | - |
| DC-SeatMapSyncClient | + | connection(): ConnectionState | Trạng thái kết nối (CONNECTING, LIVE, RECONNECTING, RELOAD_PENDING, CLOSED) | - | ST-18; P11a UI-STT 41 | Instance | - |
| DC-SeatMapSyncClient | - | onSeatEvent(event: SeatEventView): void | Áp sự kiện qua SeatMapReducer, ghi lastFrameAt | Hậu: map mới, báo người đăng ký | ST-18 sự kiện seatEvent | Instance | - |
| DC-SeatMapSyncClient | - | onHeartbeat(): void | Ghi lastFrameAt | - | ST-18 sự kiện heartbeat | Instance | - |
| DC-SeatMapSyncClient | - | onStreamError(): void | Chuyển RECONNECTING và hẹn nối lại sau lùi thời gian 1, 2, 4 giây tối đa 10 giây | Hậu: một hẹn giờ nối lại duy nhất | ST-18 sự kiện streamError | Instance | - |
| DC-SeatMapSyncClient | - | onReloadRequired(): void | Hẹn reload sau độ trễ ngẫu nhiên 0 đến 3 giây | Hậu: một hẹn giờ reload duy nhất | P09 F7.5 điểm 6; ST-18 sự kiện reloadRequired | Instance | - |
| DC-SeatMapSyncClient | - | checkLiveness(): void | Mỗi giây: quá 20 giây không nhận khung nào thì coi kết nối chết; mỗi 60 giây tải lại ảnh chụp làm lưới an toàn | Hậu: có thể gọi onStreamError hoặc reload | P09 F7.5 (nhịp tim 15 giây, 20 giây chết, 60 giây làm mới) | Instance | - |
| DC-HoldCountdown | + | start(expiryTime: number, serverTime: number, onExpired: () => void): void | Đặt gốc đếm: offset = serverTime - ITicker.now() lúc nhận phản hồi; mỗi giây cập nhật remainingSeconds | Hậu: về 0 thì gọi onExpired đúng một lần; gọi start lại thay gốc đếm cũ | P11a UI-STT 43; BR-10; WCAG 2.2.1 | Instance | - |
| DC-HoldCountdown | + | stop(): void | Dừng hẹn giờ | - | Bổ sung: rời màn hình | Instance | - |
| DC-HoldCountdown | + | remainingSeconds(): number | Giây còn lại, không âm | - | Bổ sung: quan sát | Instance | - |
| DC-HoldCountdown | + | warningLevel(): WarningLevel | NONE, WARN (còn 2 phút trở xuống), trả giá trị để hiện "Sắp hết thời gian" | - | P11a UI-STT 43 | Instance | - |
| DC-HoldCountdown | + | announceMarks(): number[] | Các mốc (300, 120, 60, 30 giây) đã qua mà chưa báo cho trình đọc màn hình | Hậu: mỗi mốc chỉ trả một lần | P11a SCR-05 mục 2 (trình đọc màn hình) | Instance | - |
| DC-HoldFlowStore | + | openShowtime(showtimeId: ShowtimeId): Promise<void> | Tải suất chiếu (giờ chiếu, mở bán, giới hạn ghế mỗi lần giữ), khởi động DC-SeatMapSyncClient | Tiền: phase NO_SHOWTIME. Hậu: phase SELECTING_SEATS; suất chưa mở bán hoặc đã đổi thì refusal (MSG-84, MSG-12) và phase giữ NO_SHOWTIME | P07 UC-005 // startBooking, // showSeatMap | Instance | ApiError |
| DC-HoldFlowStore | + | toggleSeat(seatId: SeatId): void | Thêm hoặc bỏ ghế khỏi tập đang chọn; ghế không Trống bị bỏ qua | Tiền: phase SELECTING_SEATS. Hậu: vượt số ghế tối đa thì không thêm và đặt refusal MSG-10 | P07 UC-005 // confirmSeatSelection (chuẩn bị); MSG-10 | Instance | - |
| DC-HoldFlowStore | + | confirmSeatSelection(): Promise<void> | Gửi yêu cầu giữ ghế kèm requestId, displayedAt; thành công thì giữ HoldView và bật đếm ngược | Tiền: phase SELECTING_SEATS, tập chọn không rỗng. Hậu: phase HELD (replayed hoặc mới); khách chưa đăng nhập thì needsLogin = true, tập chọn giữ nguyên, phase giữ SELECTING_SEATS; bị từ chối thì refusal và phase về SELECTING_SEATS hoặc NO_SHOWTIME | P07 UC-005 // requestSeatHold; luồng 5a, 5b, 7c, 7d, 7e; BR-04, BR-54 | Instance | ApiError |
| DC-HoldFlowStore | + | cancelHold(): Promise<void> | Gửi huỷ giữ ghế, dừng đếm ngược | Tiền: phase HELD. Hậu: phase ENDED (endReason CANCELLED); huỷ khi lần giữ ghế đã kết thúc thì máy chủ trả trạng thái cuối và phase theo trạng thái đó | P07 UC-005 luồng *a; MSG-18, MSG-19 | Instance | ApiError |
| DC-HoldFlowStore | + | loadActiveHold(): Promise<void> | Nạp lần giữ ghế đang chạy của người dùng (mở lại từ dải giữ ghế hoặc sau khi tải lại trang) | Hậu: có lần giữ ghế ACTIVE thì phase HELD và đếm ngược; không có thì phase NO_SHOWTIME | P11a E-32, E-33, E-34; BR-04 | Instance | ApiError |
| DC-HoldFlowStore | + | onHoldExpired(): void | Đếm ngược về 0: dừng đồng bộ, phase ENDED (endReason EXPIRED), đặt refusal MSG-14 (khách) hoặc MSG-29 (quầy) | Hậu: các hành động thanh toán, thu tiền bị vô hiệu ở View | P07 UC-005 luồng 7b; BR-10 | Instance | - |
| DC-HoldFlowStore | + | dispose(): void | Dừng DC-SeatMapSyncClient và DC-HoldCountdown, bỏ đăng ký | Hậu: gọi nhiều lần vô hại; lần giữ ghế đang chạy vẫn chạy ở máy chủ | Bổ sung: rời màn hình | Instance | - |
| DC-HoldFlowStore | # | onSeatMapChanged(): void | Khi sơ đồ đổi: ghế đang chọn đã bị người khác giữ hoặc mua thì bỏ khỏi tập chọn và đặt conflictSeatIds (MSG-11) | Hậu: tập chọn chỉ còn ghế Trống | P07 UC-005 // updateSeatMap; P11a SCR-04 | Instance | - |
| DC-HoldFlowStore | # | applyHold(hold: HoldView): void | Nhận lần giữ ghế: lưu HoldView, bắt đầu đếm ngược với expiryTime và serverTime | Hậu: phase HELD | Bổ sung: dùng chung confirmSeatSelection, loadActiveHold | Instance | - |
| IF-41 | + | send<T>(request: ApiRequest): Promise<T> | Gửi yêu cầu; request gồm route (tên tuyến logic), params, body; trả nội dung đã giải mã JSON | Hậu: phản hồi 401 "phiên không còn hiệu lực" đã chuyển cho DC-SessionStore.expire trước khi ném | Thiết kế: P09 F7.11, P11a ui-standards UI-STT 48 | Instance | ApiError |
| IF-41 | + | openStream(request: ApiRequest): Promise<string> | Trả địa chỉ tuyệt đối kèm tham số cho kết nối đẩy (SSE) | - | Không đổi trạng thái; Thiết kế: P09 F7.5 | Instance | - |
| IF-48 | + | authHeader(): string | null | Trả giá trị Authorization của phiên hiện tại hoặc null | Hậu: không đổi trạng thái | Thiết kế: X1 RV-24 | Instance | - |
| IF-48 | + | expire(reason: ExpireReason): void | Xoá phiên khi máy chủ từ chối (401) | Hậu: phiên đã xoá; gọi nhiều lần vô hại | Thiết kế: X1 RV-24 | Instance | - |
| IF-43 | + | now(): number | Thời điểm hiện tại của trình duyệt, mili giây từ epoch | - | Bổ sung: đồng hồ tiêm vào | Instance | - |
| IF-43 | + | every(periodMs: number, tick: () => void): () => void | Gọi tick mỗi periodMs; trả hàm huỷ hẹn giờ | Hậu: hàm huỷ gọi nhiều lần vô hại | Bổ sung: đếm ngược, nhịp tim, lùi thời gian nối lại | Instance | - |
| IF-43 | + | after(delayMs: number, action: () => void): () => void | Gọi action một lần sau delayMs; trả hàm huỷ | - | Bổ sung: độ trễ ngẫu nhiên tải lại ảnh chụp (P09 F7.5 điểm 6) | Instance | - |
| DC-FetchApiClient | + | send<T>(request: ApiRequest): Promise<T> | Dựng yêu cầu từ routeTable, đính Authorization khi có phiên, giải mã JSON | Tiền: route có trong routeTable. Hậu: HTTP 401 mã SESSION_INVALID thì gọi SessionStore.expire rồi ném ApiError | P11a UI-STT 48; P09 F7.11 | Instance | ApiError, NetworkError |
| DC-FetchApiClient | + | openStream(request: ApiRequest): Promise<string> | Dựng địa chỉ SSE kèm tham số after; SSE công khai nên không kèm mã phiên | - | P09 F7.5 | Instance | ApiError |
| DC-StoreBase | + | getState(): S | Trả trạng thái hiện tại (đối tượng bất biến) | - | Bổ sung: View và kiểm thử đọc trạng thái | Instance | - |
| DC-StoreBase | + | subscribe(listener: () => void): () => void | Đăng ký nghe thay đổi; trả hàm huỷ đăng ký | Hậu: listener được gọi sau mỗi setState, không gọi lúc đăng ký | Bổ sung: View React đăng ký (useSyncExternalStore) | Instance | - |
| DC-StoreBase | # | setState(next: S): void | Thay trạng thái bằng bản mới rồi gọi mọi listener | Hậu: getState() trả next | Bổ sung: Store con đổi trạng thái | Instance | - |
| DC-RequestStoreBase | # | beginRequest(): number | Tăng requestSeq, đặt status LOADING, xoá refusal; trả số thứ tự của yêu cầu | Hậu: requestSeq tăng một | Thiết kế: X1 RV-19 | Instance | - |
| DC-RequestStoreBase | # | isCurrent(seq: number): boolean | Đúng khi seq bằng requestSeq hiện tại (kết quả của yêu cầu cũ bị bỏ) | Hậu: không đổi trạng thái | Thiết kế: X1 RV-19 | Instance | - |
| DC-RequestStoreBase | # | setRefusal(refusal: Refusal | null): void | Ghi lý do từ chối, status IDLE | Hậu: refusal = tham số | Thiết kế: X1 RV-19 | Instance | - |
| DC-ManagedListStore | # | submitWithDisplayedAt<T>(send: () => Promise<T>, reload: () => Promise<void>): Promise<T | null> | Gọi send (đã kèm displayedAt); bị từ chối do mốc cũ (đã bị yêu cầu khác đổi) thì setRefusal, gọi reload để nạp lại danh sách và không ghi đè dữ liệu nhập | BR-138, BR-142, BR-146. Hậu: thành công trả kết quả, từ chối trả null | Thiết kế: X1 RV-19 | Instance | ApiError |
| DC-ReportStoreBase | # | runReport<R>(fetch: () => Promise<R>, apply: (r: R) => void): Promise<void> | beginRequest; bỏ kết quả khi isCurrent sai; kỳ không hợp lệ hoặc không có suất chiếu thì đặt notice | BR-117. Hậu: chỉ yêu cầu mới nhất ghi vào Store | Thiết kế: X1 RV-19 | Instance | ApiError |
| DC-SessionStore | + | login(kind: AccountKind, identifier: string, password: string): Promise<LoginOutcome> | Gửi thông tin đăng nhập tới điểm đăng nhập của khách hoặc của nhân viên; thành công thì giữ phiên | Tiền: identifier và password không rỗng. Hậu: thành công thì getState().session khác null và ghi sessionStorage; thất bại trả LoginOutcome.refused kèm mã MSG, không đổi phiên | P11a SCR-01, SCR-21; NFR-01 đến NFR-03; P09 F7.11 (hai điểm đăng nhập, Q-267) | Instance | - |
| DC-SessionStore | + | logout(): void | Xoá phiên khỏi bộ nhớ và sessionStorage | Hậu: session = null | Bổ sung: menu đăng xuất | Instance | - |
| DC-SessionStore | + | expire(reason: ExpireReason): void | Xoá phiên khi máy chủ từ chối (401) và ghi lý do để màn đăng nhập hiện MSG-85 | Hậu: session = null, expiredReason = reason, kind lưu để về đúng màn SCR-01 hoặc SCR-21. Gọi nhiều lần vô hại | P11a UI-STT 48, MSG-85; BR-101 | Instance | - |
| DC-SessionStore | + | restore(): void | Nạp phiên từ sessionStorage khi mở ứng dụng, bỏ phiên đã quá expiresAt | Hậu: session = bản đã lưu nếu còn hạn, ngược lại null và xoá bản lưu | Bổ sung: tải lại trang | Instance | - |
| DC-SessionStore | + | authHeader(): string  |  null | - | Trả giá trị Authorization của phiên hiện tại hoặc null; Bổ sung: DC-FetchApiClient đính mã phiên | Instance | - |
| DC-SessionStore | + | currentSession(): SessionInfo  |  null | - | Trả phiên hiện tại; Bổ sung: quan sát hậu điều kiện của login, expire | Instance | - |
| DC-LoginView | + | mount(kind: AccountKind, mode: LoginMode, onLoggedIn?: (s: SessionInfo) => void): void | Hiện form theo loại tài khoản; mode PAGE chuyển màn khi thành công, POPUP gọi onLoggedIn rồi đóng | Tiền: kind CUSTOMER hoặc STAFF. Hậu: nếu SessionStore.expiredReason khác null thì hiện MSG-85 | P11a SCR-01, SCR-21; E-06 đến E-09, E-37, E-38 | Instance | - |
| DC-LoginView | + | onSubmit(identifier: string, password: string): Promise<void> | Gọi SessionStore.login; thành công thì điều hướng (PAGE) hoặc báo người gọi (POPUP); thất bại hiện thông điệp từ chối | Tiền: hai ô không rỗng (kiểm ở View). Hậu: phiên đã giữ khi thành công | P07 UC-005 // provideCredentials; NFR-01 đến NFR-03 | Instance | - |
| DC-LoginView | + | onSwitchKindClicked(): void | Đổi giữa form khách và form nhân viên (liên kết ở dạng trang) | Hậu: kind đảo; không có ở POPUP | P11a E-39, E-40 | Instance | - |
| DC-LoginView | + | homeRouteFor(session: SessionInfo): ScreenId | Chọn màn hình đầu theo vai trò: khách SCR-02, quầy SCR-09, soát vé SCR-16, quản lý cụm rạp SCR-17, quản lý chuỗi SCR-31, quản trị viên SCR-37 | Hậu: không đổi trạng thái | P11a E-06 đến E-09, E-37, E-38; NFR-02, NFR-03 | Instance | - |

## F3. Bảng thiết kế method

Operation không hiển nhiên có method ở bảng dưới; operation còn lại của View chỉ chuyển sự kiện người dùng thành lời gọi Store (không có thuật toán). Store không mở giao dịch cơ sở dữ liệu: ranh giới giao dịch nằm ở lớp dịch vụ PKG-13 đến PKG-19 (P12 lõi); riêng PKG-20 mở giao dịch ngắn qua IF-08 theo P09 F7.7, mỗi giao dịch một việc, không giữ giao dịch khi gửi thư.

| DC.operation | Thuật toán / các bước chính | Đối tượng và operation khác được dùng | Cách dùng thuộc tính, tham số, quan hệ | Hành vi theo trạng thái (nếu có ST) |
|---|---|---|---|---|
| DC-HoldFlowStore.confirmSeatSelection() | 1. Tiền kiểm: phase SELECTING_SEATS, tập chọn không rỗng, không vượt maxSeatsPerHold (MSG-10).<br>2. Chưa đăng nhập (SessionStore.currentSession() null) thì needsLogin = true, giữ nguyên tập chọn, dừng (luồng 5a1).<br>3. Nếu requestId chưa có thì sinh UUID và ghi sessionStorage theo showtimeId (Q-333).<br>4. phase = HOLD_REQUESTED; gửi route "booking.holdSeats" với showtimeId, seatIds, requestId, displayedAt = showtime.lastChangedAt.<br>5. Thành công: applyHold(hold), xoá requestId.<br>6. ApiError: SUAT_DA_DOI hoặc SUAT_CHUA_MO_BAN thì phase NO_SHOWTIME; còn lại phase SELECTING_SEATS, syncClient.reload() để sơ đồ phản ánh ghế vừa bị lấy; xoá requestId.<br>7. NetworkError: giữ requestId, gửi lại tối đa 2 lần cách 1 giây (Thiết kế: máy chủ nhận cùng requestId trả replayed nên không giữ hai lần); hết lần thì refusal "kiểm tra lần giữ ghế" và gọi loadActiveHold.<br>Nếu dừng tại đây: đóng tab hoặc mất mạng sau bước 4 thì máy chủ có thể đã giữ ghế; mở lại ứng dụng, SCR-02 hiện dải giữ ghế đang chạy (loadActiveHold, E-32); không thao tác gì thì lần giữ ghế hết hạn sau 10 phút và ghế tự trả (BR-10, REQ-76) | SessionStore.currentSession, IF-41.send, DC-SeatMapSyncClient.reload, applyHold | requestId, selectedSeatIds, showtime.lastChangedAt, needsLogin | ST-17: chỉ chạy ở SelectingSeats |
| DC-HoldFlowStore.openShowtime(showtimeId) | 1. IF-41.send("showtime.get", showtimeId) lấy ShowtimeView; từ chối vì chưa mở bán (MSG-84), đã bắt đầu, khác cụm rạp (BR-02) thì refusal và dừng, phase giữ NO_SHOWTIME.<br>2. Lưu showtime, xoá tập chọn và conflictSeatIds.<br>3. syncClient.start(showtimeId); đăng ký nghe syncClient để gọi onSeatMapChanged.<br>4. phase = SELECTING_SEATS | IF-41.send, DC-SeatMapSyncClient.start | showtime, selectedSeatIds | ST-17: từ NoShowtime; Held thì ném BookingStateError (BR-04) |
| DC-HoldFlowStore.loadActiveHold() | 1. IF-41.send("booking.activeHold"); không có lần giữ ghế ACTIVE thì giữ NO_SHOWTIME.<br>2. Có thì applyHold(hold): lưu HoldView, countdown.start(expiryTime, serverTime, onHoldExpired).<br>3. Nạp thêm ShowtimeView để SCR-05, SCR-11 hiện suất chiếu | IF-41.send, DC-HoldCountdown.start | hold, showtime | Chỉ chạy ở NoShowtime |
| DC-HoldFlowStore.onSeatMapChanged() | 1. changed = SeatMapReducer.changedSeatIds(trước, sau) giao selectedSeatIds.<br>2. Với ghế đã sang HELD hoặc SOLD: bỏ khỏi selectedSeatIds, thêm vào conflictSeatIds.<br>3. conflictSeatIds không rỗng thì refusal MSG-11 kèm danh sách ghế; ghế do chính mình giữ (hold.seats) không tính xung đột | DC-SeatMapReducer.changedSeatIds | selectedSeatIds, conflictSeatIds, hold | Chỉ ở SelectingSeats; Held bỏ qua |
| DC-BookTicketsStore.startOnlinePayment() | 1. Tiền kiểm phase HELD và remainingSeconds > 0.<br>2. phase = PAYMENT_REDIRECTING; IF-41.send("payment.start", holdRef); mỗi lần gọi máy chủ tạo giao dịch và địa chỉ mới cho cùng lần giữ ghế (BR-90).<br>3. Trả paymentUrl cho View chuyển trình duyệt; phase = AWAITING_RESULT.<br>4. ApiError (lỗi trước lúc chuyển): phase HELD, refusal MSG-26 hoặc thông điệp lỗi hệ thống.<br>Nếu dừng tại đây: giao dịch PENDING có thể đã tạo nhưng trình duyệt chưa chuyển; lần giữ ghế vẫn ACTIVE, khách quay lại SCR-05 từ SCR-02 (E-32) và bấm thanh toán, địa chỉ mới; kết quả cuối do thông báo IPN của cổng quyết định ở máy chủ, không phụ thuộc trình duyệt | IF-41.send | hold, phase | ST-17: Held --> PaymentRedirecting --> AwaitingResult |
| DC-BookTicketsStore.loadPaymentOutcome(holdRef) | 1. phase = AWAITING_RESULT.<br>2. Vòng lặp: IF-41.send("payment.status", holdRef) (chỉ đọc); có bookingCode thì phase BOOKED; holdStatus PAYMENT_FAILED hoặc EXPIRED thì phase ENDED kèm endReason; holdStatus ACTIVE và không có kết quả thì chờ pollIntervalMs (2 giây) rồi hỏi lại.<br>3. Quá pollMaxMs (30 giây) vẫn chưa rõ: dừng hỏi, giữ AWAITING_RESULT, refusal hướng khách kiểm tra Lịch sử đặt vé (Q-334).<br>4. Chạy lại khi tải lại trang an toàn vì chỉ đọc | IF-41.send, ITicker.after | paymentOutcome, pollIntervalMs, pollMaxMs | ST-17: AwaitingResult |
| DC-CounterBookTicketsStore.confirmCashReceived() | 1. Tiền kiểm phase HELD; khoá nút bằng cờ submitting ở View.<br>2. IF-41.send("booking.confirmCash", holdRef) một lần, không tự gửi lại.<br>3. Thành công: soldTickets, phase BOOKED.<br>4. HoldNotActive (Hết hạn, Đã huỷ, Thanh toán thất bại): phase ENDED, refusal báo nhân viên trả lại tiền mặt (9a1a, BR-44).<br>5. NetworkError: reconcileCashResult() hỏi trạng thái lần giữ ghế (chỉ đọc); COMPLETED thì như bước 3, ACTIVE thì cho bấm lại, trạng thái cuối khác thì như bước 4.<br>Nếu dừng tại đây: máy chủ có thể đã bán vé; gửi lại sau khi đã bán bị HoldNotActive(COMPLETED) và báo nhầm trả tiền mặt, nên chỉ đối chiếu bằng thao tác đọc | IF-41.send | hold, soldTickets, phase | ST-17: Held --> Booked hoặc Ended |
| DC-SeatMapReducer.applyEvent(map, event) | 1. Với mỗi item (seatId, state) của event: lấy ô hiện có; chưa có ô thì bỏ qua (ghế ngoài sơ đồ lúc chụp).<br>2. Chỉ khi event.eventId > ô.eventSeq thì thay state và eventSeq = event.eventId; ngược lại bỏ qua item đó.<br>3. cursor = max(cursor, event.eventId).<br>4. Trả bản sao mới (không sửa map vào); kết quả không phụ thuộc thứ tự, lặp hay phát lại (quy tắc P09 F7.5 điểm 5) | - | map.seats, map.cursor | Hàm thuần |
| DC-SeatMapSyncClient.start(showtimeId) | 1. connection = CONNECTING, showtimeId lưu.<br>2. IF-41.send("seatmap.snapshot", showtimeId); lỗi thì onStreamError-kiểu lùi thời gian: connection RELOAD_PENDING và hẹn reload.<br>3. map = SeatMapReducer.fromSnapshot(snapshot).<br>4. url = IF-41.openStream(after = map.cursor); IF-42.open(url, handlers); onOpen: connection LIVE, retryCount = 0.<br>5. Bắt đầu ITicker.every(1000, checkLiveness) | IF-41.send, IF-41.openStream, IF-42.open, SeatMapReducer.fromSnapshot | map, retryCount, lastFrameAt | ST-18: Closed --> Connecting --> Live |
| DC-SeatMapSyncClient.onStreamError() | 1. Đóng kết nối hiện tại (StreamHandle.close).<br>2. retryCount++; delay = min(1000 * 2^(retryCount-1), 10000) ms; đặt một hẹn giờ nối lại duy nhất (huỷ hẹn cũ).<br>3. connection = RECONNECTING.<br>4. Tới hẹn: mở lại stream với after = map.cursor, không tải lại ảnh chụp (máy chủ phát lại từ con trỏ); nếu máy chủ trả RELOAD_REQUIRED thì onReloadRequired | ITicker.after, IF-42.open | retryCount, map.cursor | ST-18: Live, Connecting --> Reconnecting |
| DC-SeatMapSyncClient.reload() | 1. Huỷ hẹn reload; đóng kết nối.<br>2. Tải ảnh chụp mới, map thay hoàn toàn bằng fromSnapshot.<br>3. Mở stream với after = cursor mới; sự kiện giữa ảnh chụp và stream nằm trong phần phát lại nên không mất.<br>4. Thất bại thì RELOAD_PENDING với độ lùi như onStreamError | IF-41.send, IF-42.open | map, connection | ST-18: ReloadPending --> Connecting |
| DC-HoldCountdown.start(expiryTime, serverTime, onExpired) | 1. clockOffsetMs = serverTime - ITicker.now() đo lúc nhận phản hồi (UI-STT 43).<br>2. Mỗi giây (ITicker.every 1000): remaining = max(0, ceil((expiryTime - (now + offset)) / 1000)).<br>3. remaining chạm 0 và chưa expiredFired thì expiredFired = true và gọi onExpired một lần.<br>4. announceMarks trả mốc 300, 120, 60, 30 giây đã qua chưa báo; warningLevel WARN khi remaining <= 120 | ITicker.every | expiryTime, clockOffsetMs, remaining | - |
| DC-SessionStore.login(kind, identifier, password) | 1. Chọn route theo kind: "auth.customerLogin" hoặc "auth.staffLogin" (hai điểm đăng nhập riêng, Q-267).<br>2. IF-41.send không kèm mã phiên; thành công thì session = SessionInfo, ghi sessionStorage, expiredReason = null.<br>3. ApiError mã thông tin sai hoặc tài khoản bị khoá thì trả LoginOutcome.refused kèm messageId; không đổi session.<br>4. Không giữ password sau lời gọi | IF-41.send | session, expiredReason | - |
| DC-FetchApiClient.send(request) | 1. Tra routeTable[request.route] ra phương thức và đường dẫn, thay params, thêm query, body JSON.<br>2. Đính Authorization từ SessionStore.authHeader() khi có.<br>3. fetchFn với AbortController timeoutMs; hết hạn thì NetworkError.<br>4. HTTP 2xx: giải mã JSON.<br>5. HTTP 401 mã SESSION_INVALID hoặc SESSION_EXPIRED: SessionStore.expire(reason) rồi ném ApiError (màn đăng nhập hiện MSG-85).<br>6. Lỗi khác: ném ApiError(status, code, messageId) | DC-SessionStore.authHeader, expire | routeTable, timeoutMs | - |
| DC-CheckTicketStore.scanTicket(qrText) | 1. Bỏ qua khi checkingShowtime null.<br>2. Bỏ qua khi qrText bằng lastScannedText trong duplicateWindowMs (3 giây) hoặc một yêu cầu đang chạy (status SUBMITTING).<br>3. IF-41.send("ticket.check", qrText, showtimeId); máy chủ tra vé từ chuỗi, kiểm theo thứ tự BR-33 và đánh dấu đã dùng trong một giao dịch.<br>4. lastResult = ScanOutcome; lỗi mạng thì refusal, không đoán kết quả và không thử lại tự động (thử lại sau khi đã đánh dấu sẽ trả ALREADY_USED) | IF-41.send, ITicker.now | lastScannedText, lastScannedAt, lastResult | Không có ST |
| DC-ScheduleShowtimesStore.saveShowtime(input) | 1. Tiền kiểm status READY; status = SUBMITTING.<br>2. IF-41.send("showtime.save", input, displayedAt = form.displayedAt khi sửa).<br>3. Thành công: cập nhật showtimes, form = null, status READY.<br>4. ApiError (một trong 19 lý do P07 hoặc suất đã đổi, BR-54): refusal = messageId; form giữ dữ liệu nhập; suất đã đổi hoặc không còn thì loadShowtimes để làm mới.<br>Các Store có displayedAt (giá, phòng, phim, cụm rạp, tài khoản nhân viên) làm cùng khung: gửi kèm mốc lúc hiển thị, bị từ chối vì đã bị sửa thì nạp lại dòng đó và hiện lý do, không ghi đè (BR-138, BR-142, BR-146) | IF-41.send | form, showtimes, refusal | - |
| DC-ViewCinemaReportStore.requestReport(request) | 1. requestSeq++; seq = requestSeq; status LOADING.<br>2. IF-41.send("report.cinema", request) (máy chủ lấy cụm rạp từ phiên).<br>3. Khi trả về mà seq khác requestSeq thì bỏ kết quả (có yêu cầu mới hơn).<br>4. Kỳ sai thì notice INVALID_PERIOD; không có suất chiếu thì NO_SHOWTIME.<br>ViewChainReportStore.requestReport làm cùng khung với route "report.chain" | IF-41.send | requestSeq, report, notice | - |
| DC-EmailOutboxJob.RunDue(ctx, budget) | 1. ctx với deadline = budget (8 giây, đồng bộ IF-06 của core).<br>2. Lặp: IF-23.Claim(EMAIL_TICKET) rồi nếu trống thì Claim(EMAIL_REFUND); không dòng đến hạn thì dừng, hasMore = false.<br>3. processEntry(e); lỗi ClaimLostError thì bỏ dòng, tiếp tục.<br>4. Dừng khi hết budget; hasMore = true nếu còn việc.<br>5. Mỗi dòng xử lý hết rồi mới claim dòng kế (không gửi song song trong một lượt, email không cần thông lượng cao) | IF-23.Claim, processEntry | - | - |
| DC-EmailOutboxJob.processEntry(ctx, e) | 1. Dựng thư ngoài giao dịch: composeTicketEmail hoặc composeRefundEmail (đọc không khoá bằng IF-08.Do tx chỉ đọc ngắn); NotFoundError thì MarkExhausted (dữ liệu nguồn mất, không thử lại).<br>2. IF-03.SendEmail(ctx, message) ngoài giao dịch (P09 F7.1).<br>3. Do(UserTx("EmailResult")) fn: applyResult theo EmailSendResult.<br>4. ClaimLostError: bỏ dòng (bên khác đã nhận claim; có thể gửi trùng, Message-ID cùng khoá chống lặp giúp phía nhận loại trùng).<br>Nếu dừng tại đây: sau bước 2 tiến trình chết: claim hết hạn sau 120 giây, bản backend khác nhận và gửi lại; chấp nhận gửi trùng hiếm (P11b F3: không idempotent). Sau bước 1 chết: không đổi gì, claim hết hạn rồi chạy lại từ bước 1. Chạy lại khi lần trước đã làm một phần: bước 1 và 2 luôn chạy lại, bước 3 chỉ ghi nếu claim_token còn của bên gọi | IF-08.Do, IF-03.SendEmail, IF-23.MarkSucceeded, Reschedule, MarkExhausted | e.claimToken, e.attemptCount | Không có ST ở lớp này; vòng đời dòng hàng đợi là DC-OutboxStatus (PKG-21) |
| DC-EmailOutboxJob.applyResult(ctx, e, r) | 1. Accepted: IF-23.MarkSucceeded.<br>2. Rejected: IF-23.MarkExhausted(lastError = r.detail), ghi log lỗi; vé hoặc khoản hoàn vẫn hiệu lực (BR-89).<br>3. TemporaryFailure: delay, ok = retryDelay(e.attemptCount); ok thì IF-23.Reschedule(delay, r.detail), ngược lại MarkExhausted.<br>4. retryDelay: attemptCount 1 --> 1 phút, 2 --> 5 phút, 3 --> 15 phút, từ 4 trở đi hết lượt (3 lần thử lại sau lần gửi đầu) | IF-23 | retryDelays, maxRetries | - |
| DC-SmtpClient.Send(ctx, to, raw) | 1. ctx con với deadline totalTimeout (30 giây); dial với dialTimeout (10 giây).<br>2. Kết nối, TLS theo tlsMode, xác thực, MAIL FROM, RCPT TO, DATA, kết thúc.<br>3. Phân loại: mã 2xx Accepted; 5xx Rejected; 4xx hoặc lỗi mạng TemporaryFailure; lỗi sau khi đã gửi nội dung DATA thì maybeDelivered = true.<br>4. Luôn đóng kết nối; không log nội dung thư | DC-SmtpConfig | dialTimeout, totalTimeout | - |

## F4. Bảng ánh xạ message --> operation

Message của boundary Form trong P07 đi từ tác nhân tới Form (sự kiện người dùng, ánh xạ tới View), từ Form tới Controller (Store gửi yêu cầu REST qua IF-41; lớp nhận phía máy chủ là PKG-13 đến PKG-19, thiết kế ở P12 lõi và P12 PKG-11) và từ Controller về Form (đi lên layer trên: kết quả hay ngoại lệ của lời gọi Store đang chờ, không thành operation của View). Message updateSeatMap tới sau, không có lời gọi đang chờ, đi qua DC-SeatMapReducer của PKG-29. Message của PKG-20, PKG-23 ở bốn dòng cuối.

| UC | STT message (P07) | Từ (AC) | Đến (AC) | Message phân tích (// tênTráchNhiệm) | Operation thiết kế (chữ ký đầy đủ) |
|---|---|---|---|---|---|
| UC-001 | 1 | Tác nhân | AC-B-RegisterAccountForm | // requestRegistration | DC-RegisterAccountView.mount() |
| UC-001 | 1.1 | AC-B-RegisterAccountForm | AC-C-RegisterAccountController | // startRegistration | DC-RegisterAccountStore.openForm(): void |
| UC-001 | 1.1.1 | AC-C-RegisterAccountController | AC-B-RegisterAccountForm | // showRegistrationRequest | Trả về: DC-RegisterAccountStore.openForm đặt trạng thái kết quả (showRegistrationRequest); View hiển thị |
| UC-001 | 2 | Tác nhân | AC-B-RegisterAccountForm | // submitRegistrationData | DC-RegisterAccountView.onSubmit(data: RegistrationData): Promise<void> |
| UC-001 | 2.1 | AC-B-RegisterAccountForm | AC-C-RegisterAccountController | // registerAccount | DC-RegisterAccountStore.submitRegistration(data: RegistrationData): Promise<void> |
| UC-001 | 2.1.3 | AC-C-RegisterAccountController | AC-B-RegisterAccountForm | // rejectRegistration | Ngoại lệ: DC-RegisterAccountStore.submitRegistration đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-001 | 2.1.4 | AC-C-RegisterAccountController | AC-B-RegisterAccountForm | // rejectRegistration | Ngoại lệ: DC-RegisterAccountStore.submitRegistration đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-001 | 2.1.5 | AC-C-RegisterAccountController | AC-B-RegisterAccountForm | // rejectRegistration | Ngoại lệ: DC-RegisterAccountStore.submitRegistration đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-001 | 2.1.7 | AC-C-RegisterAccountController | AC-B-RegisterAccountForm | // rejectRegistration | Ngoại lệ: DC-RegisterAccountStore.submitRegistration đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-001 | 2.1.8 | AC-C-RegisterAccountController | AC-B-RegisterAccountForm | // showRegistrationSuccess | Trả về: DC-RegisterAccountStore.submitRegistration đặt trạng thái kết quả (showRegistrationSuccess); View hiển thị |
| UC-003 | 1 | Tác nhân | AC-B-BrowseMoviesForm | // requestMovieList | DC-BrowseMoviesView.mount(): Promise<void> |
| UC-003 | 1.1 | AC-B-BrowseMoviesForm | AC-C-BrowseMoviesController | // startBrowsingMovies | DC-BrowseMoviesStore.loadMovieList(): Promise<void> |
| UC-003 | 1.1.3 | AC-C-BrowseMoviesController | AC-B-BrowseMoviesForm | // notifyNoMovies | Ngoại lệ: DC-BrowseMoviesStore.loadMovieList đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-003 | 1.1.4 | AC-C-BrowseMoviesController | AC-B-BrowseMoviesForm | // showMovieList | Trả về: DC-BrowseMoviesStore.loadMovieList đặt trạng thái kết quả (showMovieList); View hiển thị |
| UC-003 | 2 | Tác nhân | AC-B-BrowseMoviesForm | // selectMovie | DC-BrowseMoviesView.onMovieClicked(movieId: MovieId): Promise<void> |
| UC-003 | 2.1 | AC-B-BrowseMoviesForm | AC-C-BrowseMoviesController | // viewMovieDetails | DC-BrowseMoviesStore.selectMovie(movieId: MovieId): Promise<void> |
| UC-003 | 2.1.2 | AC-C-BrowseMoviesController | AC-B-BrowseMoviesForm | // showMovieDetails | Trả về: DC-BrowseMoviesStore.selectMovie đặt trạng thái kết quả (showMovieDetails); View hiển thị |
| UC-004 | 1 | Tác nhân | AC-B-BrowseShowtimesForm | // requestShowtimesByMovie | DC-BrowseShowtimesView.onModeChosen(mode: BrowseMode): Promise<void> |
| UC-004 | 1a | Tác nhân | AC-B-BrowseShowtimesForm | // requestShowtimesByCinema | DC-BrowseShowtimesView.onModeChosen(mode: BrowseMode): Promise<void> |
| UC-004 | 1.1 | AC-B-BrowseShowtimesForm | AC-C-BrowseShowtimesController | // startBrowsingByMovie | DC-BrowseShowtimesStore.loadMovieChoices(): Promise<void> |
| UC-004 | 1a.1 | AC-B-BrowseShowtimesForm | AC-C-BrowseShowtimesController | // startBrowsingByCinema | DC-BrowseShowtimesStore.loadCinemaChoices(): Promise<void> |
| UC-004 | 1a.1.2 | AC-C-BrowseShowtimesController | AC-B-BrowseShowtimesForm | // showCinemaList | Trả về: DC-BrowseShowtimesStore.loadCinemaChoices đặt trạng thái kết quả (showCinemaList); View hiển thị |
| UC-004 | 1.1.3 | AC-C-BrowseShowtimesController | AC-B-BrowseShowtimesForm | // showMovieList | Trả về: DC-BrowseShowtimesStore.loadMovieChoices đặt trạng thái kết quả (showMovieList); View hiển thị |
| UC-004 | 1a.2 | Tác nhân | AC-B-BrowseShowtimesForm | // selectCinemaAndCriteria | DC-BrowseShowtimesView.onSearchSubmitted(criteria: BrowseCriteria): Promise<void> |
| UC-004 | 1a.2.1 | AC-B-BrowseShowtimesForm | AC-C-BrowseShowtimesController | // findShowtimesByCinema | DC-BrowseShowtimesStore.findShowtimes(criteria: BrowseCriteria): Promise<void> |
| UC-004 | 1a.2.1.5 | AC-C-BrowseShowtimesController | AC-B-BrowseShowtimesForm | // notifyNoShowtimes | Ngoại lệ: DC-BrowseShowtimesStore.findShowtimes đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-004 | 1a.2.1.6 | AC-C-BrowseShowtimesController | AC-B-BrowseShowtimesForm | // showShowtimes | Trả về: DC-BrowseShowtimesStore.findShowtimes đặt trạng thái kết quả (showShowtimes); View hiển thị |
| UC-004 | 2 | Tác nhân | AC-B-BrowseShowtimesForm | // selectMovieAndCriteria | DC-BrowseShowtimesView.onSearchSubmitted(criteria: BrowseCriteria): Promise<void> |
| UC-004 | 2.1 | AC-B-BrowseShowtimesForm | AC-C-BrowseShowtimesController | // findShowtimesByMovie | DC-BrowseShowtimesStore.findShowtimes(criteria: BrowseCriteria): Promise<void> |
| UC-004 | 2.1.5 | AC-C-BrowseShowtimesController | AC-B-BrowseShowtimesForm | // notifyNoShowtimes | Ngoại lệ: DC-BrowseShowtimesStore.findShowtimes đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-004 | 2.1.6 | AC-C-BrowseShowtimesController | AC-B-BrowseShowtimesForm | // showShowtimes | Trả về: DC-BrowseShowtimesStore.findShowtimes đặt trạng thái kết quả (showShowtimes); View hiển thị |
| UC-005 | 1 | Tác nhân | AC-B-BookTicketsForm | // selectShowtime | DC-SelectShowtimePage.onShowtimeChosen(showtimeId: ShowtimeId): Promise<void> |
| UC-005 | 1.1 | AC-B-BookTicketsForm | AC-C-BookTicketsController | // startBooking | DC-HoldFlowStore.openShowtime(showtimeId: ShowtimeId): Promise<void> |
| UC-005 | 1.1.1a.1 | AC-C-BookTicketsController | AC-B-BookTicketsForm | // notifyRefusal | Ngoại lệ: DC-BookTicketsStore.startOnlinePayment đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-005 | 1.1.1b.1 | AC-C-BookTicketsController | AC-B-CounterBookTicketsForm | // notifyRefusal | Ngoại lệ: DC-HoldFlowStore.openShowtime đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-005 | 1.1.1c.1 | AC-C-BookTicketsController | AC-B-BookTicketsForm | // notifyRefusal | Ngoại lệ: DC-BookTicketsStore.startOnlinePayment đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-005 | 1.1.1a.1[ACT-02] | AC-C-BookTicketsController | AC-B-CounterBookTicketsForm | // notifyRefusal | Ngoại lệ: DC-HoldFlowStore.openShowtime đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-005 | 1.1.1c.1[ACT-02] | AC-C-BookTicketsController | AC-B-CounterBookTicketsForm | // notifyRefusal | Ngoại lệ: DC-HoldFlowStore.openShowtime đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-005 | 1.1[ACT-02] | AC-B-CounterBookTicketsForm | AC-C-BookTicketsController | // startBooking | DC-HoldFlowStore.openShowtime(showtimeId: ShowtimeId): Promise<void> |
| UC-005 | 1.1.3 | AC-C-BookTicketsController | AC-B-BookTicketsForm | // showSeatMap | Trả về: DC-HoldFlowStore.openShowtime đặt trạng thái kết quả (showSeatMap); View hiển thị |
| UC-005 | 1.1.3[ACT-02] | AC-C-BookTicketsController | AC-B-CounterBookTicketsForm | // showSeatMap | Trả về: DC-HoldFlowStore.openShowtime đặt trạng thái kết quả (showSeatMap); View hiển thị |
| UC-005 | 1[ACT-02] | Tác nhân | AC-B-CounterBookTicketsForm | // selectShowtime | DC-CounterSelectSeatsPage.onShowtimeChosen(showtimeId: ShowtimeId): Promise<void> |
| UC-005 | 2 | Tác nhân | AC-B-BookTicketsForm | // confirmSeatSelection | DC-SelectSeatsPage.onConfirmSelection(): Promise<void> |
| UC-005 | 2.1 | AC-B-BookTicketsForm | AC-C-BookTicketsController | // requestSeatHold | DC-HoldFlowStore.confirmSeatSelection(): Promise<void> |
| UC-005 | 2.1.1a.1 | AC-C-BookTicketsController | AC-B-BookTicketsForm | // requestLogin | Trả về: DC-HoldFlowStore.confirmSeatSelection đặt needsLogin = true; DC-BookTicketsView.handleLoginRequired(): void |
| UC-005 | 2.1.1a.2 | Tác nhân | AC-B-BookTicketsForm | // provideCredentials | DC-LoginView.onSubmit(identifier: string, password: string): Promise<void> |
| UC-005 | 2.1.1a.3 | AC-B-BookTicketsForm | AC-C-BookTicketsController | // requestSeatHold | DC-HoldFlowStore.confirmSeatSelection(): Promise<void> |
| UC-005 | 2.1[ACT-02] | AC-B-CounterBookTicketsForm | AC-C-BookTicketsController | // requestSeatHold | DC-HoldFlowStore.confirmSeatSelection(): Promise<void> |
| UC-005 | 2.1.2b.1 | AC-C-BookTicketsController | AC-B-BookTicketsForm | // notifyRefusal | Ngoại lệ: DC-HoldFlowStore.confirmSeatSelection đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-005 | 2.1.3a.1 | AC-C-BookTicketsController | AC-B-BookTicketsForm | // notifyRefusal | Ngoại lệ: DC-HoldFlowStore.confirmSeatSelection đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-005 | 2.1.4a.1 | AC-C-BookTicketsController | AC-B-BookTicketsForm | // notifyRefusal | Ngoại lệ: DC-HoldFlowStore.confirmSeatSelection đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-005 | 2.1.4c.1 | AC-C-BookTicketsController | AC-B-BookTicketsForm | // notifyRefusal | Ngoại lệ: DC-HoldFlowStore.confirmSeatSelection đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-005 | 2.1.4d.1 | AC-C-BookTicketsController | AC-B-BookTicketsForm | // notifyRefusal | Ngoại lệ: DC-HoldFlowStore.confirmSeatSelection đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-005 | 2.1.4e.1 | AC-C-BookTicketsController | AC-B-BookTicketsForm | // notifyRefusal | Ngoại lệ: DC-HoldFlowStore.confirmSeatSelection đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-005 | 2.1.5(7b).4 | AC-C-BookTicketsController | AC-B-BookTicketsForm | // updateSeatMap | DC-SeatMapReducer.applyEvent(map: SeatMapGrid, event: SeatEventView): SeatMapGrid (Khác lớp nhận: P09 F7.5, sự kiện tới qua SSE, không có lời gọi đang chờ) |
| UC-005 | 2.1.5(7b).5 | AC-C-BookTicketsController | AC-B-BookTicketsForm | // notifyRefusal | Ngoại lệ: DC-HoldFlowStore.confirmSeatSelection đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-005 | 2.1.6 | AC-C-BookTicketsController | AC-B-BookTicketsForm | // updateSeatMap | DC-SeatMapReducer.applyEvent(map: SeatMapGrid, event: SeatEventView): SeatMapGrid (Khác lớp nhận: P09 F7.5, sự kiện tới qua SSE, không có lời gọi đang chờ) |
| UC-005 | 2.1.6[ACT-02] | AC-C-BookTicketsController | AC-B-BookTicketsForm | // updateSeatMap | DC-SeatMapReducer.applyEvent(map: SeatMapGrid, event: SeatEventView): SeatMapGrid (Khác lớp nhận: P09 F7.5, sự kiện tới qua SSE, không có lời gọi đang chờ) |
| UC-005 | 2.1.8 | AC-C-BookTicketsController | AC-B-BookTicketsForm | // showHeldSeats | Trả về: DC-HoldFlowStore.confirmSeatSelection đặt trạng thái kết quả (showHeldSeats); View hiển thị |
| UC-005 | 2.1.8[ACT-02] | AC-C-BookTicketsController | AC-B-CounterBookTicketsForm | // showHeldSeats | Trả về: DC-HoldFlowStore.confirmSeatSelection đặt trạng thái kết quả (showHeldSeats); View hiển thị |
| UC-005 | 2[ACT-02] | Tác nhân | AC-B-CounterBookTicketsForm | // confirmSeatSelection | DC-CounterSelectSeatsPage.onConfirmSelection(): Promise<void> |
| UC-005 | 3 | Tác nhân | AC-B-BookTicketsForm | // requestOnlinePayment | DC-HoldAndPayPage.onPayClicked(): Promise<void> |
| UC-005 | 3a | Tác nhân | AC-B-CounterBookTicketsForm | // confirmCashReceived | DC-CounterHoldAndCashPage.onCashReceivedClicked(): Promise<void> |
| UC-005 | 3.1 | AC-B-BookTicketsForm | AC-C-BookTicketsController | // startOnlinePayment | DC-BookTicketsStore.startOnlinePayment(): Promise<string> |
| UC-005 | 3a.1 | AC-B-CounterBookTicketsForm | AC-C-BookTicketsController | // confirmCashReceived | DC-CounterBookTicketsStore.confirmCashReceived(): Promise<void> |
| UC-005 | 3.1.1a.1 | AC-C-BookTicketsController | AC-B-BookTicketsForm | // notifyRefusal | Ngoại lệ: DC-HoldFlowStore.confirmSeatSelection đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-005 | 3a.1.2.1a.2 | AC-C-BookTicketsController | AC-B-CounterBookTicketsForm | // notifyRefusal | Ngoại lệ: DC-CounterBookTicketsStore.confirmCashReceived đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-005 | 3a.1.3 | AC-C-BookTicketsController | AC-B-BookTicketsForm | // updateSeatMap | DC-SeatMapReducer.applyEvent(map: SeatMapGrid, event: SeatEventView): SeatMapGrid (Khác lớp nhận: P09 F7.5, sự kiện tới qua SSE, không có lời gọi đang chờ) |
| UC-005 | 3a.1.5 | AC-C-BookTicketsController | AC-B-CounterBookTicketsForm | // showTicketsForPrint | Trả về: DC-CounterBookTicketsStore.confirmCashReceived đặt soldTickets (SoldTickets); sau NetworkError thì reconcileCashResult |
| UC-005 | 3a.2 | Tác nhân | AC-B-CounterBookTicketsForm | // printTickets | DC-CounterPrintTicketsPage.onPrintClicked(): void |
| UC-005 | 4.1.2 | AC-C-PaymentReportController | AC-B-BookTicketsForm | // updateSeatMap | DC-SeatMapReducer.applyEvent(map: SeatMapGrid, event: SeatEventView): SeatMapGrid (Khác lớp nhận: P09 F7.5, sự kiện tới qua SSE, không có lời gọi đang chờ) |
| UC-005 | 4.1.3 | AC-C-PaymentReportController | AC-B-EmailService | // sendTicketsEmail | Khác lớp nhận: IF-23.Enqueue(EMAIL_TICKET) trong DC-PaymentReportService.HandleIpn (P12 lõi F4); DC-EmailOutboxJob.RunDue --> processEntry --> IF-03.SendEmail(ctx, message) |
| UC-005 | 4a.1.3 | AC-C-PaymentReportController | AC-B-BookTicketsForm | // updateSeatMap | DC-SeatMapReducer.applyEvent(map: SeatMapGrid, event: SeatEventView): SeatMapGrid (Khác lớp nhận: P09 F7.5, sự kiện tới qua SSE, không có lời gọi đang chờ) |
| UC-005 | 4.1.3.1 | AC-B-EmailService | Dịch vụ email | // sendTicketsEmail | DC-EmailGatewayManager.SendEmail(ctx, message): (EmailSendResult, error) (IF-03) |
| UC-005 | 4a.1.4 | AC-C-PaymentReportController | AC-B-BookTicketsForm | // notifyRefusal | Ngoại lệ: DC-HoldFlowStore.confirmSeatSelection đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-005 | 4.1.5 | AC-C-PaymentReportController | AC-B-BookTicketsForm | // showBookingSuccess | Trả về: DC-BookTicketsStore.loadPaymentOutcome trả PaymentOutcome (bookingCode) |
| UC-006 | 1.1.11 | AC-C-PaymentReportController | AC-B-EmailService | // sendRefundNotificationEmail | Khác lớp nhận: IF-23.Enqueue(EMAIL_REFUND) trong DC-RefundService.ProcessRefund (P12 lõi F4); DC-EmailOutboxJob.RunDue --> processEntry --> IF-03.SendEmail(ctx, message) |
| UC-006 | 1.1.11.1 | AC-B-EmailService | Dịch vụ email | // sendRefundNotificationEmail | DC-EmailGatewayManager.SendEmail(ctx, message): (EmailSendResult, error) (IF-03) |
| UC-007 | 1 | Tác nhân | AC-B-ViewBookingHistoryForm | // requestBookingHistory | DC-ViewBookingHistoryView.mount(): Promise<void> |
| UC-007 | 1.1 | AC-B-ViewBookingHistoryForm | AC-C-ViewBookingHistoryController | // startViewHistory | DC-ViewBookingHistoryStore.loadHistory(): Promise<void> |
| UC-007 | 1.1.2 | AC-C-ViewBookingHistoryController | AC-B-ViewBookingHistoryForm | // showNoBooking | Trả về: DC-ViewBookingHistoryStore.loadHistory đặt trạng thái kết quả (showNoBooking); View hiển thị |
| UC-007 | 1.1.4 | AC-C-ViewBookingHistoryController | AC-B-ViewBookingHistoryForm | // showBookingHistory | Trả về: DC-ViewBookingHistoryStore.loadHistory đặt trạng thái kết quả (showBookingHistory); View hiển thị |
| UC-007 | 2 | Tác nhân | AC-B-ViewBookingHistoryForm | // selectBooking | DC-ViewBookingHistoryView.onBookingSelected(bookingCode: string): Promise<void> |
| UC-007 | 2.1 | AC-B-ViewBookingHistoryForm | AC-C-ViewBookingHistoryController | // viewBookingTickets | DC-ViewBookingHistoryStore.openBooking(bookingCode: string): Promise<void> |
| UC-007 | 2.1.2 | AC-C-ViewBookingHistoryController | AC-B-ViewBookingHistoryForm | // rejectBookingView | Ngoại lệ: DC-ViewBookingHistoryStore.openBooking đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-007 | 2.1.4 | AC-C-ViewBookingHistoryController | AC-B-ViewBookingHistoryForm | // showBookingTickets | Trả về: DC-ViewBookingHistoryStore.openBooking đặt trạng thái kết quả (showBookingTickets); View hiển thị |
| UC-008 | 1 | Tác nhân | AC-B-CancelTicketForm | // selectTicketToCancel | DC-CancelTicketView.onCancelConfirmed(): Promise<void> |
| UC-008 | 1a | Tác nhân | AC-B-CounterCancelTicketForm | // enterBookingCode | DC-CounterCancelTicketView.onBookingCodeSubmitted(code: string): Promise<void> |
| UC-008 | 1.1 | AC-B-CancelTicketForm | AC-C-CancelTicketController | // requestCancellation | DC-CancelTicketStore.cancelTicket(ticketId: TicketId): Promise<void> |
| UC-008 | 1a.1 | AC-B-CounterCancelTicketForm | AC-C-CancelTicketController | // findBookingTickets | DC-CounterCancelTicketStore.findBooking(code: string): Promise<void> |
| UC-008 | 1a.1.1 | AC-C-CancelTicketController | AC-B-CounterCancelTicketForm | // notifyRefusal | Ngoại lệ: DC-CounterCancelTicketStore.findBooking đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-008 | 1.1.1a.1 | AC-C-CancelTicketController | AC-B-CancelTicketForm | // notifyRefusal | Ngoại lệ: DC-CancelTicketStore.cancelTicket đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-008 | 1.1.1b.1 | AC-C-CancelTicketController | AC-B-CounterCancelTicketForm | // notifyRefusal | Ngoại lệ: DC-CounterCancelTicketStore.cancelTicket đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-008 | 1.1.1c.1 | AC-C-CancelTicketController | AC-B-CounterCancelTicketForm | // notifyRefusal | Ngoại lệ: DC-CounterCancelTicketStore.cancelTicket đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-008 | 1.1[ACT-02] | AC-B-CounterCancelTicketForm | AC-C-CancelTicketController | // requestCancellation | DC-CounterCancelTicketStore.cancelTicket(ticketId: TicketId): Promise<void> |
| UC-008 | 1.1.2a.1 | AC-C-CancelTicketController | AC-B-CancelTicketForm | // notifyRefusal | Ngoại lệ: DC-CancelTicketStore.cancelTicket đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-008 | 1a.1.3 | AC-C-CancelTicketController | AC-B-CounterCancelTicketForm | // showBookingTickets | Trả về: DC-CounterCancelTicketStore.findBooking đặt trạng thái kết quả (showBookingTickets); View hiển thị |
| UC-008 | 1.1.3a.1 | AC-C-CancelTicketController | AC-B-CancelTicketForm | // notifyRefusal | Ngoại lệ: DC-CancelTicketStore.cancelTicket đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-008 | 1.1.3b.1 | AC-C-CancelTicketController | AC-B-CancelTicketForm | // notifyRefusal | Ngoại lệ: DC-CancelTicketStore.cancelTicket đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-008 | 1.1.4a.2 | AC-C-CancelTicketController | AC-B-CounterCancelTicketForm | // showCashRefund | Trả về: DC-CounterCancelTicketStore. đặt trạng thái kết quả (showCashRefund); View hiển thị |
| UC-008 | 1.1.14 | AC-C-CancelTicketController | AC-B-BookTicketsForm | // updateSeatMap | DC-SeatMapReducer.applyEvent(map: SeatMapGrid, event: SeatEventView): SeatMapGrid (Khác lớp nhận: P09 F7.5, sự kiện tới qua SSE, không có lời gọi đang chờ) |
| UC-008 | 1.1.16 | AC-C-CancelTicketController | AC-B-CancelTicketForm | // showCancellationResult | Trả về: DC-CancelTicketStore.cancelTicket đặt trạng thái kết quả (showCancellationResult); View hiển thị |
| UC-008 | 1a.2 | Tác nhân | AC-B-CounterCancelTicketForm | // selectTicketToCancel | DC-CounterCancelTicketView.onTicketCancelConfirmed(ticketId: TicketId): Promise<void> |
| UC-008 | 2(5a) | Tác nhân | AC-B-CounterCancelTicketForm | // confirmCashRefunded | DC-CounterCancelTicketView.onCashRefundConfirmed(): Promise<void> |
| UC-008 | 2(5a).1 | AC-B-CounterCancelTicketForm | AC-C-CancelTicketController | // confirmCashRefund | DC-CounterCancelTicketStore.confirmCashRefunded(ticketId: TicketId): Promise<void> |
| UC-008 | 2(5a).1.3 | AC-C-CancelTicketController | AC-B-BookTicketsForm | // updateSeatMap | DC-SeatMapReducer.applyEvent(map: SeatMapGrid, event: SeatEventView): SeatMapGrid (Khác lớp nhận: P09 F7.5, sự kiện tới qua SSE, không có lời gọi đang chờ) |
| UC-008 | 2(5a).1.5 | AC-C-CancelTicketController | AC-B-CounterCancelTicketForm | // showCancellationResult | Trả về: DC-CounterCancelTicketStore.confirmCashRefunded đặt trạng thái kết quả (showCancellationResult); View hiển thị |
| UC-009 | 1 | Tác nhân | AC-B-CheckTicketForm | // selectCheckingShowtime | DC-CheckTicketView.onShowtimeChosen(showtimeId: ShowtimeId): Promise<void> |
| UC-009 | 1.1 | AC-B-CheckTicketForm | AC-C-CheckTicketController | // startChecking | DC-CheckTicketStore.selectCheckingShowtime(showtimeId: ShowtimeId): Promise<void> |
| UC-009 | 1.1.4 | AC-C-CheckTicketController | AC-B-CheckTicketForm | // showCheckingShowtime | Trả về: DC-CheckTicketStore.selectCheckingShowtime đặt trạng thái kết quả (showCheckingShowtime); View hiển thị |
| UC-009 | 2 | Tác nhân | AC-B-CheckTicketForm | // scanTicketQr | DC-CheckTicketView.onQrDecoded(text: string): Promise<void> |
| UC-009 | 2.1 | AC-B-CheckTicketForm | AC-C-CheckTicketController | // checkTicket | DC-CheckTicketStore.scanTicket(qrText: string): Promise<void> |
| UC-009 | 2.1.2 | AC-C-CheckTicketController | AC-B-CheckTicketForm | // rejectTicket | Ngoại lệ: DC-CheckTicketStore.scanTicket đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-009 | 2.1.5 | AC-C-CheckTicketController | AC-B-CheckTicketForm | // showValidTicket | Trả về: DC-CheckTicketStore.scanTicket đặt trạng thái kết quả (showValidTicket); View hiển thị |
| UC-009 | 2.1.6 | AC-C-CheckTicketController | AC-B-CheckTicketForm | // rejectTicket | Ngoại lệ: DC-CheckTicketStore.scanTicket đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-009 | 2.1.7 | AC-C-CheckTicketController | AC-B-CheckTicketForm | // rejectTicket | Ngoại lệ: DC-CheckTicketStore.scanTicket đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-009 | 2.1.8 | AC-C-CheckTicketController | AC-B-CheckTicketForm | // rejectTicket | Ngoại lệ: DC-CheckTicketStore.scanTicket đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-009 | 2.1.9 | AC-C-CheckTicketController | AC-B-CheckTicketForm | // rejectTicket | Ngoại lệ: DC-CheckTicketStore.scanTicket đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-010 | 1 | Tác nhân | AC-B-ManageMoviesForm | // requestMovieAddition | DC-ManageMoviesView.onAddClicked(): void |
| UC-010 | 1a | Tác nhân | AC-B-ManageMoviesForm | // requestMovieEdit | DC-ManageMoviesView.onEditClicked(movieId: MovieId): Promise<void> |
| UC-010 | 1.1 | AC-B-ManageMoviesForm | AC-C-ManageMoviesController | // startMovieAddition | DC-ManageMoviesStore.openAddForm(): void |
| UC-010 | 1a.1 | AC-B-ManageMoviesForm | AC-C-ManageMoviesController | // startMovieEdit | DC-ManageMoviesStore.loadMovies(): Promise<void> |
| UC-010 | 1.1.2 | AC-C-ManageMoviesController | AC-B-ManageMoviesForm | // showMovieList | Trả về: DC-ManageMoviesStore.openAddForm đặt trạng thái kết quả (showMovieList); View hiển thị |
| UC-010 | 1a.1.2 | AC-C-ManageMoviesController | AC-B-ManageMoviesForm | // showMovieList | Trả về: DC-ManageMoviesStore.loadMovies đặt trạng thái kết quả (showMovieList); View hiển thị |
| UC-010 | 2 | Tác nhân | AC-B-ManageMoviesForm | // enterMovieInfo | DC-ManageMoviesView.onFormSubmitted(input: MovieInput): Promise<void> |
| UC-010 | 2a | Tác nhân | AC-B-ManageMoviesForm | // selectMovieToEdit | DC-ManageMoviesView.onEditClicked(movieId: MovieId): Promise<void> |
| UC-010 | 2.1 | AC-B-ManageMoviesForm | AC-C-ManageMoviesController | // submitMovie | DC-ManageMoviesStore.saveMovie(input: MovieInput): Promise<void> |
| UC-010 | 2a.1 | AC-B-ManageMoviesForm | AC-C-ManageMoviesController | // selectMovie | DC-ManageMoviesStore.openEditForm(movieId: MovieId): Promise<void> |
| UC-010 | 2a.1.2 | AC-C-ManageMoviesController | AC-B-ManageMoviesForm | // showMovieForEdit | Trả về: DC-ManageMoviesStore.openEditForm đặt trạng thái kết quả (showMovieForEdit); View hiển thị |
| UC-010 | 2.1.3 | AC-C-ManageMoviesController | AC-B-ManageMoviesForm | // notifyRefusal | Ngoại lệ: DC-ManageMoviesStore.saveMovie đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-010 | 2.1.5 | AC-C-ManageMoviesController | AC-B-ManageMoviesForm | // showSavedMovie | Trả về: DC-ManageMoviesStore.saveMovie đặt trạng thái kết quả (showSavedMovie); View hiển thị |
| UC-010 | 3a | Tác nhân | AC-B-ManageMoviesForm | // enterMovieInfo | DC-ManageMoviesView.onFormSubmitted(input: MovieInput): Promise<void> |
| UC-010 | 3a.1 | AC-B-ManageMoviesForm | AC-C-ManageMoviesController | // submitMovieChanges | DC-ManageMoviesStore.saveMovie(input: MovieInput): Promise<void> |
| UC-010 | 3a.1.2 | AC-C-ManageMoviesController | AC-B-ManageMoviesForm | // notifyRefusal | Ngoại lệ: DC-ManageMoviesStore.saveMovie đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-010 | 3a.1.4 | AC-C-ManageMoviesController | AC-B-ManageMoviesForm | // notifyRefusal | Ngoại lệ: DC-ManageMoviesStore.saveMovie đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-010 | 3a.1.5 | AC-C-ManageMoviesController | AC-B-ManageMoviesForm | // showSavedMovie | Trả về: DC-ManageMoviesStore.saveMovie đặt trạng thái kết quả (showSavedMovie); View hiển thị |
| UC-011 | 1 | Tác nhân | AC-B-ManageCinemasForm | // requestCinemaAddition | DC-ManageCinemasView.onAddClicked(): void |
| UC-011 | 1a | Tác nhân | AC-B-ManageCinemasForm | // requestCinemaEdit | DC-ManageCinemasView.onEditClicked(cinemaId: CinemaId): Promise<void> |
| UC-011 | 1.1 | AC-B-ManageCinemasForm | AC-C-ManageCinemasController | // startCinemaAddition | DC-ManageCinemasStore.openAddForm(): void |
| UC-011 | 1a.1 | AC-B-ManageCinemasForm | AC-C-ManageCinemasController | // startCinemaEdit | DC-ManageCinemasStore.loadCinemas(): Promise<void> |
| UC-011 | 1.1.2 | AC-C-ManageCinemasController | AC-B-ManageCinemasForm | // showCinemaList | Trả về: DC-ManageCinemasStore.openAddForm đặt trạng thái kết quả (showCinemaList); View hiển thị |
| UC-011 | 1a.1.2 | AC-C-ManageCinemasController | AC-B-ManageCinemasForm | // showCinemaList | Trả về: DC-ManageCinemasStore.loadCinemas đặt trạng thái kết quả (showCinemaList); View hiển thị |
| UC-011 | 2 | Tác nhân | AC-B-ManageCinemasForm | // enterCinemaInfo | DC-ManageCinemasView.onFormSubmitted(input: CinemaInput): Promise<void> |
| UC-011 | 2a | Tác nhân | AC-B-ManageCinemasForm | // selectCinemaToEdit | DC-ManageCinemasView.onEditClicked(cinemaId: CinemaId): Promise<void> |
| UC-011 | 2.1 | AC-B-ManageCinemasForm | AC-C-ManageCinemasController | // submitCinema | DC-ManageCinemasStore.saveCinema(input: CinemaInput): Promise<void> |
| UC-011 | 2a.1 | AC-B-ManageCinemasForm | AC-C-ManageCinemasController | // selectCinema | DC-ManageCinemasStore.openEditForm(cinemaId: CinemaId): Promise<void> |
| UC-011 | 2a.1.2 | AC-C-ManageCinemasController | AC-B-ManageCinemasForm | // showCinemaForEdit | Trả về: DC-ManageCinemasStore.openEditForm đặt trạng thái kết quả (showCinemaForEdit); View hiển thị |
| UC-011 | 2.1.3 | AC-C-ManageCinemasController | AC-B-ManageCinemasForm | // notifyRefusal | Ngoại lệ: DC-ManageCinemasStore.saveCinema đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-011 | 2.1.5 | AC-C-ManageCinemasController | AC-B-ManageCinemasForm | // notifyRefusal | Ngoại lệ: DC-ManageCinemasStore.saveCinema đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-011 | 2.1.7 | AC-C-ManageCinemasController | AC-B-ManageCinemasForm | // showSavedCinema | Trả về: DC-ManageCinemasStore.saveCinema đặt trạng thái kết quả (showSavedCinema); View hiển thị |
| UC-011 | 3a | Tác nhân | AC-B-ManageCinemasForm | // enterCinemaInfo | DC-ManageCinemasView.onFormSubmitted(input: CinemaInput): Promise<void> |
| UC-011 | 3a.1 | AC-B-ManageCinemasForm | AC-C-ManageCinemasController | // submitCinemaChanges | DC-ManageCinemasStore.saveCinema(input: CinemaInput): Promise<void> |
| UC-011 | 3a.1.2 | AC-C-ManageCinemasController | AC-B-ManageCinemasForm | // notifyRefusal | Ngoại lệ: DC-ManageCinemasStore.saveCinema đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-011 | 3a.1.4 | AC-C-ManageCinemasController | AC-B-ManageCinemasForm | // notifyRefusal | Ngoại lệ: DC-ManageCinemasStore.saveCinema đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-011 | 3a.1.6 | AC-C-ManageCinemasController | AC-B-ManageCinemasForm | // notifyRefusal | Ngoại lệ: DC-ManageCinemasStore.saveCinema đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-011 | 3a.1.7 | AC-C-ManageCinemasController | AC-B-ManageCinemasForm | // showSavedCinema | Trả về: DC-ManageCinemasStore.saveCinema đặt trạng thái kết quả (showSavedCinema); View hiển thị |
| UC-012 | 1 | Tác nhân | AC-B-ManageAuditoriumsForm | // requestAuditoriumAddition | DC-ManageAuditoriumsView.onAddClicked(): void |
| UC-012 | 1a | Tác nhân | AC-B-ManageAuditoriumsForm | // requestAuditoriumEdit | DC-ManageAuditoriumsView.onEditClicked(auditoriumId: AuditoriumId): Promise<void> |
| UC-012 | 1b | Tác nhân | AC-B-ManageAuditoriumsForm | // requestAuditoriumRemoval | DC-ManageAuditoriumsView.onRemoveClicked(auditoriumId: AuditoriumId): void |
| UC-012 | 1.1 | AC-B-ManageAuditoriumsForm | AC-C-ManageAuditoriumsController | // startAuditoriumAddition | DC-ManageAuditoriumsStore.openAddForm(): void |
| UC-012 | 1a.1 | AC-B-ManageAuditoriumsForm | AC-C-ManageAuditoriumsController | // startAuditoriumEdit | DC-ManageAuditoriumsStore.loadAuditoriums(): Promise<void> |
| UC-012 | 1b.1 | AC-B-ManageAuditoriumsForm | AC-C-ManageAuditoriumsController | // startAuditoriumRemoval | DC-ManageAuditoriumsStore.loadAuditoriums(): Promise<void> |
| UC-012 | 1.1.3 | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // showAuditoriumList | Trả về: DC-ManageAuditoriumsStore.openAddForm đặt trạng thái kết quả (showAuditoriumList); View hiển thị |
| UC-012 | 1a.1.3 | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // showAuditoriumList | Trả về: DC-ManageAuditoriumsStore.loadAuditoriums đặt trạng thái kết quả (showAuditoriumList); View hiển thị |
| UC-012 | 1b.1.3 | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // showAuditoriumList | Trả về: DC-ManageAuditoriumsStore.loadAuditoriums đặt trạng thái kết quả (showAuditoriumList); View hiển thị |
| UC-012 | 2 | Tác nhân | AC-B-ManageAuditoriumsForm | // enterAuditoriumInfo | DC-ManageAuditoriumsView.onFormSubmitted(input: AuditoriumInput): Promise<void> |
| UC-012 | 2a | Tác nhân | AC-B-ManageAuditoriumsForm | // selectAuditoriumToEdit | DC-ManageAuditoriumsView.onEditClicked(auditoriumId: AuditoriumId): Promise<void> |
| UC-012 | 2b | Tác nhân | AC-B-ManageAuditoriumsForm | // selectAuditoriumToRemove | DC-ManageAuditoriumsView.onRemoveConfirmed(): Promise<void> |
| UC-012 | 2.1 | AC-B-ManageAuditoriumsForm | AC-C-ManageAuditoriumsController | // submitAuditorium | DC-ManageAuditoriumsStore.saveAuditorium(input: AuditoriumInput): Promise<void> |
| UC-012 | 2a.1 | AC-B-ManageAuditoriumsForm | AC-C-ManageAuditoriumsController | // selectAuditorium | DC-ManageAuditoriumsStore.openEditForm(auditoriumId: AuditoriumId): Promise<void> |
| UC-012 | 2b.1 | AC-B-ManageAuditoriumsForm | AC-C-ManageAuditoriumsController | // submitAuditoriumRemoval | DC-ManageAuditoriumsStore.removeAuditorium(auditoriumId: AuditoriumId): Promise<void> |
| UC-012 | 2a.1.3 | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // showAuditoriumForEdit | Trả về: DC-ManageAuditoriumsStore.openEditForm đặt trạng thái kết quả (showAuditoriumForEdit); View hiển thị |
| UC-012 | 2b.1.3 | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // notifyRefusal | Ngoại lệ: DC-ManageAuditoriumsStore.removeAuditorium đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-012 | 2.1.4 | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // notifyRefusal | Ngoại lệ: DC-ManageAuditoriumsStore.saveAuditorium đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-012 | 2b.1.4 | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // showRemovalSuccess | Trả về: DC-ManageAuditoriumsStore.removeAuditorium đặt trạng thái kết quả (showRemovalSuccess); View hiển thị |
| UC-012 | 2.1.5 | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // notifyRefusal | Ngoại lệ: DC-ManageAuditoriumsStore.saveAuditorium đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-012 | 2.1.7 | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // notifyRefusal | Ngoại lệ: DC-ManageAuditoriumsStore.saveAuditorium đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-012 | 2.1.7a | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // notifyRefusal | Ngoại lệ: DC-ManageAuditoriumsStore.openEditForm đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-012 | 2.1.8a | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // notifyRefusal | Ngoại lệ: DC-ManageAuditoriumsStore.openEditForm đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-012 | 2.1.9 | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // showSavedAuditorium | Trả về: DC-ManageAuditoriumsStore.saveAuditorium đặt trạng thái kết quả (showSavedAuditorium); View hiển thị |
| UC-012 | 2.1.9a | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // notifyRefusal | Ngoại lệ: DC-ManageAuditoriumsStore.openEditForm đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-012 | 2.1.10a | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // notifyRefusal | Ngoại lệ: DC-ManageAuditoriumsStore.openEditForm đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-012 | 2.1.13a | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // showSavedAuditorium | Trả về: DC-ManageAuditoriumsStore.openEditForm đặt trạng thái kết quả (showSavedAuditorium); View hiển thị |
| UC-013 | 1 | Tác nhân | AC-B-ManagePriceListForm | // requestPriceListSetup | DC-ManagePriceListView.mount(): Promise<void> |
| UC-013 | 1a | Tác nhân | AC-B-ManagePriceListForm | // requestPriceRemoval | DC-ManagePriceListView.onRemoveClicked(entryKey: PriceEntryKey): void |
| UC-013 | 1.1 | AC-B-ManagePriceListForm | AC-C-ManagePriceListController | // startPriceListSetup | DC-ManagePriceListStore.loadPriceList(): Promise<void> |
| UC-013 | 1a.1 | AC-B-ManagePriceListForm | AC-C-ManagePriceListController | // startPriceRemoval | DC-ManagePriceListStore.loadPriceList(): Promise<void> |
| UC-013 | 1.1.3 | AC-C-ManagePriceListController | AC-B-ManagePriceListForm | // showPriceList | Trả về: DC-ManagePriceListStore.loadPriceList đặt trạng thái kết quả (showPriceList); View hiển thị |
| UC-013 | 1a.1.3 | AC-C-ManagePriceListController | AC-B-ManagePriceListForm | // showPriceList | Trả về: DC-ManagePriceListStore.loadPriceList đặt trạng thái kết quả (showPriceList); View hiển thị |
| UC-013 | 2 | Tác nhân | AC-B-ManagePriceListForm | // enterPriceEntry | DC-ManagePriceListView.onEntrySubmitted(entry: PriceEntryInput): Promise<void> |
| UC-013 | 2a | Tác nhân | AC-B-ManagePriceListForm | // selectPriceEntryToRemove | DC-ManagePriceListView.onRemoveConfirmed(): Promise<void> |
| UC-013 | 2.1 | AC-B-ManagePriceListForm | AC-C-ManagePriceListController | // submitPriceEntry | DC-ManagePriceListStore.savePriceEntry(entry: PriceEntryInput): Promise<void> |
| UC-013 | 2a.1 | AC-B-ManagePriceListForm | AC-C-ManagePriceListController | // submitPriceEntryRemoval | DC-ManagePriceListStore.removePriceEntry(entryKey: PriceEntryKey): Promise<void> |
| UC-013 | 2.1.2 | AC-C-ManagePriceListController | AC-B-ManagePriceListForm | // notifyRefusal | Ngoại lệ: DC-ManagePriceListStore.savePriceEntry đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-013 | 2a.1.2 | AC-C-ManagePriceListController | AC-B-ManagePriceListForm | // notifyRefusal | Ngoại lệ: DC-ManagePriceListStore.removePriceEntry đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-013 | 2a.1.3 | AC-C-ManagePriceListController | AC-B-ManagePriceListForm | // notifyRefusal | Ngoại lệ: DC-ManagePriceListStore.removePriceEntry đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-013 | 2.1.4 | AC-C-ManagePriceListController | AC-B-ManagePriceListForm | // notifyRefusal | Ngoại lệ: DC-ManagePriceListStore.savePriceEntry đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-013 | 2a.1.4 | AC-C-ManagePriceListController | AC-B-ManagePriceListForm | // showRemovalSuccess | Trả về: DC-ManagePriceListStore.removePriceEntry đặt trạng thái kết quả (showRemovalSuccess); View hiển thị |
| UC-013 | 2.1.5 | AC-C-ManagePriceListController | AC-B-ManagePriceListForm | // showSavedPriceEntry | Trả về: DC-ManagePriceListStore.savePriceEntry đặt trạng thái kết quả (showSavedPriceEntry); View hiển thị |
| UC-014 | 1 | Tác nhân | AC-B-ScheduleShowtimesForm | // requestNewShowtime | DC-ScheduleShowtimesView.onNewClicked(): Promise<void> |
| UC-014 | 1a | Tác nhân | AC-B-ScheduleShowtimesForm | // requestEditShowtime | DC-ScheduleShowtimesView.onEditClicked(showtimeId: ShowtimeId): Promise<void> |
| UC-014 | 1b | Tác nhân | AC-B-ScheduleShowtimesForm | // requestDeleteShowtime | DC-ScheduleShowtimesView.onDeleteClicked(showtimeId: ShowtimeId): void |
| UC-014 | 1.1 | AC-B-ScheduleShowtimesForm | AC-C-ScheduleShowtimesController | // startScheduling | DC-ScheduleShowtimesStore.openCreateForm(): Promise<void> |
| UC-014 | 1a.1 | AC-B-ScheduleShowtimesForm | AC-C-ScheduleShowtimesController | // startEditingShowtime | DC-ScheduleShowtimesStore.loadShowtimes(): Promise<void> |
| UC-014 | 1b.1 | AC-B-ScheduleShowtimesForm | AC-C-ScheduleShowtimesController | // startDeletingShowtime | DC-ScheduleShowtimesStore.loadShowtimes(): Promise<void> |
| UC-014 | 1a.1.3 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // showShowtimes | Trả về: DC-ScheduleShowtimesStore.loadShowtimes đặt trạng thái kết quả (showShowtimes); View hiển thị |
| UC-014 | 1b.1.3 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // showShowtimes | Trả về: DC-ScheduleShowtimesStore.loadShowtimes đặt trạng thái kết quả (showShowtimes); View hiển thị |
| UC-014 | 1.1.4 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // showAuditoriumsAndMovies | Trả về: DC-ScheduleShowtimesStore.openCreateForm đặt trạng thái kết quả (showAuditoriumsAndMovies); View hiển thị |
| UC-014 | 1a.2 | Tác nhân | AC-B-ScheduleShowtimesForm | // selectShowtimeToEdit | DC-ScheduleShowtimesView.onEditClicked(showtimeId: ShowtimeId): Promise<void> |
| UC-014 | 1b.2 | Tác nhân | AC-B-ScheduleShowtimesForm | // selectShowtimeToDelete | DC-ScheduleShowtimesView.onDeleteConfirmed(): Promise<void> |
| UC-014 | 1a.2.1 | AC-B-ScheduleShowtimesForm | AC-C-ScheduleShowtimesController | // prepareShowtimeEdit | DC-ScheduleShowtimesStore.openEditForm(showtimeId: ShowtimeId): Promise<void> |
| UC-014 | 1b.2.1 | AC-B-ScheduleShowtimesForm | AC-C-ScheduleShowtimesController | // deleteShowtime | DC-ScheduleShowtimesStore.deleteShowtime(showtimeId: ShowtimeId): Promise<void> |
| UC-014 | 1a.2.1.2 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal | Ngoại lệ: DC-ScheduleShowtimesStore.openEditForm đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-014 | 1b.2.1.2 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal | Ngoại lệ: DC-ScheduleShowtimesStore.deleteShowtime đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-014 | 1b.2.1.3 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal | Ngoại lệ: DC-ScheduleShowtimesStore.deleteShowtime đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-014 | 1a.2.1.4 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal | Ngoại lệ: DC-ScheduleShowtimesStore.openEditForm đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-014 | 1b.2.1.4 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal | Ngoại lệ: DC-ScheduleShowtimesStore.deleteShowtime đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-014 | 1b.2.1.5 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyDeleted | Ngoại lệ: DC-ScheduleShowtimesStore.deleteShowtime đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-014 | 1a.2.1.8 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // showShowtimeForEdit | Trả về: DC-ScheduleShowtimesStore.openEditForm đặt trạng thái kết quả (showShowtimeForEdit); View hiển thị |
| UC-014 | 2 | Tác nhân | AC-B-ScheduleShowtimesForm | // submitShowtimeInfo | DC-ScheduleShowtimesView.onFormSubmitted(input: ShowtimeInput): Promise<void> |
| UC-014 | 2.1 | AC-B-ScheduleShowtimesForm | AC-C-ScheduleShowtimesController | // requestSaveShowtime | DC-ScheduleShowtimesStore.saveShowtime(input: ShowtimeInput): Promise<void> |
| UC-014 | 2.1.3 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal | Ngoại lệ: DC-ScheduleShowtimesStore.saveShowtime đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-014 | 2.1.8 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal | Ngoại lệ: DC-ScheduleShowtimesStore.saveShowtime đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-014 | 2.1.9 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal | Ngoại lệ: DC-ScheduleShowtimesStore.saveShowtime đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-014 | 2.1.10 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal | Ngoại lệ: DC-ScheduleShowtimesStore.saveShowtime đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-014 | 2.1.13 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal | Ngoại lệ: DC-ScheduleShowtimesStore.saveShowtime đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-014 | 2.1.14 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal | Ngoại lệ: DC-ScheduleShowtimesStore.saveShowtime đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-014 | 2.1.15 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal | Ngoại lệ: DC-ScheduleShowtimesStore.saveShowtime đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-014 | 2.1.18 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal | Ngoại lệ: DC-ScheduleShowtimesStore.saveShowtime đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-014 | 2.1.18[8a] | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal | Ngoại lệ: DC-ScheduleShowtimesStore.openEditForm đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-014 | 2.1.18[8c] | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal | Ngoại lệ: DC-ScheduleShowtimesStore.openEditForm đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-014 | 2.1.18[8d] | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal | Ngoại lệ: DC-ScheduleShowtimesStore.openEditForm đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-014 | 2.1.18[8f] | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal | Ngoại lệ: DC-ScheduleShowtimesStore.openEditForm đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-014 | 2.1.18[8g] | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal | Ngoại lệ: DC-ScheduleShowtimesStore.openEditForm đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-014 | 2.1.19 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal | Ngoại lệ: DC-ScheduleShowtimesStore.saveShowtime đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-014 | 2.1.19[8h] | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal | Ngoại lệ: DC-ScheduleShowtimesStore.openEditForm đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-014 | 2.1.20 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal | Ngoại lệ: DC-ScheduleShowtimesStore.saveShowtime đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-014 | 2.1.20[8e] | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal | Ngoại lệ: DC-ScheduleShowtimesStore.openEditForm đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-014 | 2.1.21 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal | Ngoại lệ: DC-ScheduleShowtimesStore.saveShowtime đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-014 | 2.1.21[8b] | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal | Ngoại lệ: DC-ScheduleShowtimesStore.openEditForm đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-014 | 2.1.23 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // showSavedShowtime | Trả về: DC-ScheduleShowtimesStore.saveShowtime đặt trạng thái kết quả (showSavedShowtime); View hiển thị |
| UC-014 | 2.1.23[1a] | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // showSavedShowtime | Trả về: DC-ScheduleShowtimesStore.openEditForm đặt trạng thái kết quả (showSavedShowtime); View hiển thị |
| UC-015 | 1 | Tác nhân | AC-B-ViewCinemaReportForm | // requestCinemaReport | DC-ViewCinemaReportView.onReportRequested(request: ReportFormInput): Promise<void> |
| UC-015 | 1.1 | AC-B-ViewCinemaReportForm | AC-C-ViewCinemaReportController | // startCinemaReport | DC-ViewCinemaReportStore.requestReport(request: ReportFormInput): Promise<void> |
| UC-015 | 1.1.3 | AC-C-ViewCinemaReportController | AC-B-ViewCinemaReportForm | // notifyInvalidPeriod | Ngoại lệ: DC-ViewCinemaReportStore.requestReport đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-015 | 1.1.6 | AC-C-ViewCinemaReportController | AC-B-ViewCinemaReportForm | // notifyNoShowtimes | Ngoại lệ: DC-ViewCinemaReportStore.requestReport đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-015 | 1.1.12 | AC-C-ViewCinemaReportController | AC-B-ViewCinemaReportForm | // showReport | Trả về: DC-ViewCinemaReportStore.requestReport đặt trạng thái kết quả (showReport); View hiển thị |
| UC-016 | 1 | Tác nhân | AC-B-ViewChainReportForm | // requestChainReport | DC-ViewChainReportView.onReportRequested(request: ReportFormInput): Promise<void> |
| UC-016 | 1.1 | AC-B-ViewChainReportForm | AC-C-ViewChainReportController | // startChainReport | DC-ViewChainReportStore.requestReport(request: ReportFormInput): Promise<void> |
| UC-016 | 1.1.3 | AC-C-ViewChainReportController | AC-B-ViewChainReportForm | // notifyInvalidPeriod | Ngoại lệ: DC-ViewChainReportStore.requestReport đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-016 | 1.1.5 | AC-C-ViewChainReportController | AC-B-ViewChainReportForm | // notifyNoShowtimes | Ngoại lệ: DC-ViewChainReportStore.requestReport đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-016 | 1.1.16 | AC-C-ViewChainReportController | AC-B-ViewChainReportForm | // showChainReport | Trả về: DC-ViewChainReportStore.requestReport đặt trạng thái kết quả (showChainReport); View hiển thị |
| UC-017 | 1 | Tác nhân | AC-B-ManageStaffAccountsForm | // requestCreateStaff | DC-ManageStaffAccountsView.onCreateClicked(): Promise<void> |
| UC-017 | 1a | Tác nhân | AC-B-ManageStaffAccountsForm | // requestUpdateStaff | DC-ManageStaffAccountsView.onRowActionSelected(action: StaffAction, staffId: StaffId): Promise<void> |
| UC-017 | 1b | Tác nhân | AC-B-ManageStaffAccountsForm | // requestLockStaff | DC-ManageStaffAccountsView.onRowActionSelected(action: StaffAction, staffId: StaffId): Promise<void> |
| UC-017 | 1c | Tác nhân | AC-B-ManageStaffAccountsForm | // requestUnlockStaff | DC-ManageStaffAccountsView.onRowActionSelected(action: StaffAction, staffId: StaffId): Promise<void> |
| UC-017 | 1d | Tác nhân | AC-B-ManageStaffAccountsForm | // requestRenameStaff | DC-ManageStaffAccountsView.onRowActionSelected(action: StaffAction, staffId: StaffId): Promise<void> |
| UC-017 | 1e | Tác nhân | AC-B-ManageStaffAccountsForm | // requestResetStaffPassword | DC-ManageStaffAccountsView.onRowActionSelected(action: StaffAction, staffId: StaffId): Promise<void> |
| UC-017 | 1.1 | AC-B-ManageStaffAccountsForm | AC-C-ManageStaffAccountsController | // startStaffCreation | DC-ManageStaffAccountsStore.openCreateForm(): Promise<void> |
| UC-017 | 1a.1 | AC-B-ManageStaffAccountsForm | AC-C-ManageStaffAccountsController | // startStaffAction | DC-ManageStaffAccountsStore.loadStaff(): Promise<void> |
| UC-017 | 1b.1 | AC-B-ManageStaffAccountsForm | AC-C-ManageStaffAccountsController | // startStaffAction | DC-ManageStaffAccountsStore.loadStaff(): Promise<void> |
| UC-017 | 1c.1 | AC-B-ManageStaffAccountsForm | AC-C-ManageStaffAccountsController | // startStaffAction | DC-ManageStaffAccountsStore.loadStaff(): Promise<void> |
| UC-017 | 1d.1 | AC-B-ManageStaffAccountsForm | AC-C-ManageStaffAccountsController | // startStaffAction | DC-ManageStaffAccountsStore.loadStaff(): Promise<void> |
| UC-017 | 1e.1 | AC-B-ManageStaffAccountsForm | AC-C-ManageStaffAccountsController | // startStaffAction | DC-ManageStaffAccountsStore.loadStaff(): Promise<void> |
| UC-017 | 1a.1.2 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // showStaffList | Trả về: DC-ManageStaffAccountsStore.loadStaff đặt trạng thái kết quả (showStaffList); View hiển thị |
| UC-017 | 1b.1.2 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // showStaffList | Trả về: DC-ManageStaffAccountsStore.loadStaff đặt trạng thái kết quả (showStaffList); View hiển thị |
| UC-017 | 1c.1.2 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // showStaffList | Trả về: DC-ManageStaffAccountsStore.loadStaff đặt trạng thái kết quả (showStaffList); View hiển thị |
| UC-017 | 1d.1.2 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // showStaffList | Trả về: DC-ManageStaffAccountsStore.loadStaff đặt trạng thái kết quả (showStaffList); View hiển thị |
| UC-017 | 1e.1.2 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // showStaffList | Trả về: DC-ManageStaffAccountsStore.loadStaff đặt trạng thái kết quả (showStaffList); View hiển thị |
| UC-017 | 1.1.3 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // showStaffAccountChoices | Trả về: DC-ManageStaffAccountsStore.openCreateForm đặt trạng thái kết quả (showStaffAccountChoices); View hiển thị |
| UC-017 | 1a.2 | Tác nhân | AC-B-ManageStaffAccountsForm | // selectStaff | DC-ManageStaffAccountsView.onRowActionSelected(action: StaffAction, staffId: StaffId): Promise<void> |
| UC-017 | 1b.2 | Tác nhân | AC-B-ManageStaffAccountsForm | // selectStaff | DC-ManageStaffAccountsView.onRowActionSelected(action: StaffAction, staffId: StaffId): Promise<void> |
| UC-017 | 1c.2 | Tác nhân | AC-B-ManageStaffAccountsForm | // selectStaff | DC-ManageStaffAccountsView.onRowActionSelected(action: StaffAction, staffId: StaffId): Promise<void> |
| UC-017 | 1d.2 | Tác nhân | AC-B-ManageStaffAccountsForm | // selectStaff | DC-ManageStaffAccountsView.onRowActionSelected(action: StaffAction, staffId: StaffId): Promise<void> |
| UC-017 | 1e.2 | Tác nhân | AC-B-ManageStaffAccountsForm | // selectStaff | DC-ManageStaffAccountsView.onRowActionSelected(action: StaffAction, staffId: StaffId): Promise<void> |
| UC-017 | 1a.2.1 | AC-B-ManageStaffAccountsForm | AC-C-ManageStaffAccountsController | // openStaffForUpdate | DC-ManageStaffAccountsStore.openUpdateForm(staffId: StaffId): Promise<void> |
| UC-017 | 1b.2.1 | AC-B-ManageStaffAccountsForm | AC-C-ManageStaffAccountsController | // changeStaffStatus | DC-ManageStaffAccountsStore.lockStaff(staffId, displayedAt) hoặc unlockStaff(staffId, displayedAt): Promise<void> |
| UC-017 | 1c.2.1 | AC-B-ManageStaffAccountsForm | AC-C-ManageStaffAccountsController | // changeStaffStatus | DC-ManageStaffAccountsStore.lockStaff(staffId, displayedAt) hoặc unlockStaff(staffId, displayedAt): Promise<void> |
| UC-017 | 1b.2.1.2 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // notifyStaffStatusUnchanged | Ngoại lệ: DC-ManageStaffAccountsStore.lockStaff đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-017 | 1c.2.1.2 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // notifyStaffStatusUnchanged | Ngoại lệ: DC-ManageStaffAccountsStore.lockStaff đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-017 | 1b.2.1.3 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // rejectStaffAccount | Ngoại lệ: DC-ManageStaffAccountsStore.lockStaff đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-017 | 1c.2.1.3 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // rejectStaffAccount | Ngoại lệ: DC-ManageStaffAccountsStore.lockStaff đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-017 | 1a.2.1.4 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // showStaffForUpdate | Trả về: DC-ManageStaffAccountsStore.openUpdateForm đặt trạng thái kết quả (showStaffForUpdate); View hiển thị |
| UC-017 | 1b.2.1.4 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // notifyStaffChanged | Ngoại lệ: DC-ManageStaffAccountsStore.lockStaff đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-017 | 1c.2.1.4 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // notifyStaffChanged | Ngoại lệ: DC-ManageStaffAccountsStore.lockStaff đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-017 | 1a.3 | Tác nhân | AC-B-ManageStaffAccountsForm | // submitRoleAndCinema | DC-ManageStaffAccountsView.onDialogSubmitted(dialog: StaffDialogInput): Promise<void> |
| UC-017 | 1d.3 | Tác nhân | AC-B-ManageStaffAccountsForm | // submitNewFullName | DC-ManageStaffAccountsView.onDialogSubmitted(dialog: StaffDialogInput): Promise<void> |
| UC-017 | 1e.3 | Tác nhân | AC-B-ManageStaffAccountsForm | // submitNewPassword | DC-ManageStaffAccountsView.onDialogSubmitted(dialog: StaffDialogInput): Promise<void> |
| UC-017 | 1a.3.1 | AC-B-ManageStaffAccountsForm | AC-C-ManageStaffAccountsController | // updateStaffAccount | DC-ManageStaffAccountsStore.updateRoleAndCinema(staffId, role, cinemaId, displayedAt): Promise<void> |
| UC-017 | 1d.3.1 | AC-B-ManageStaffAccountsForm | AC-C-ManageStaffAccountsController | // renameStaffAccount | DC-ManageStaffAccountsStore.renameStaff(staffId, fullName, displayedAt): Promise<void> |
| UC-017 | 1e.3.1 | AC-B-ManageStaffAccountsForm | AC-C-ManageStaffAccountsController | // resetStaffAccountPassword | DC-ManageStaffAccountsStore.resetPassword(staffId, newPassword, displayedAt): Promise<void> |
| UC-017 | 1a.3.1.2 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // rejectStaffAccount | Ngoại lệ: DC-ManageStaffAccountsStore.updateRoleAndCinema đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-017 | 1d.3.1.2 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // rejectStaffAccount | Ngoại lệ: DC-ManageStaffAccountsStore.renameStaff đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-017 | 1e.3.1.2 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // rejectStaffAccount | Ngoại lệ: DC-ManageStaffAccountsStore.resetPassword đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-017 | 1a.3.1.3 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // rejectStaffAccount | Ngoại lệ: DC-ManageStaffAccountsStore.updateRoleAndCinema đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-017 | 1d.3.1.3 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // rejectStaffAccount | Ngoại lệ: DC-ManageStaffAccountsStore.renameStaff đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-017 | 1e.3.1.3 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // notifyStaffChanged | Ngoại lệ: DC-ManageStaffAccountsStore.resetPassword đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-017 | 1d.3.1.4 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // notifyStaffChanged | Ngoại lệ: DC-ManageStaffAccountsStore.renameStaff đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-017 | 1a.3.1.5 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // rejectStaffAccount | Ngoại lệ: DC-ManageStaffAccountsStore.updateRoleAndCinema đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-017 | 1a.3.1.7 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // showSavedStaffAccount | Trả về: DC-ManageStaffAccountsStore.updateRoleAndCinema đặt trạng thái kết quả (showSavedStaffAccount); View hiển thị |
| UC-017 | 2 | Tác nhân | AC-B-ManageStaffAccountsForm | // submitStaffData | DC-ManageStaffAccountsView.onDialogSubmitted(dialog: StaffDialogInput): Promise<void> |
| UC-017 | 2.1 | AC-B-ManageStaffAccountsForm | AC-C-ManageStaffAccountsController | // saveStaffAccount | DC-ManageStaffAccountsStore.createStaff(data: StaffInput): Promise<void> |
| UC-017 | 2.1.3 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // rejectStaffAccount | Ngoại lệ: DC-ManageStaffAccountsStore.createStaff đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-017 | 2.1.4 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // rejectStaffAccount | Ngoại lệ: DC-ManageStaffAccountsStore.createStaff đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-017 | 2.1.5 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // rejectStaffAccount | Ngoại lệ: DC-ManageStaffAccountsStore.createStaff đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-017 | 2.1.6 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // rejectStaffAccount | Ngoại lệ: DC-ManageStaffAccountsStore.createStaff đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-017 | 2.1.8 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // rejectStaffAccount | Ngoại lệ: DC-ManageStaffAccountsStore.createStaff đặt refusal (ApiError kèm mã MSG); View hiển thị |
| UC-017 | 2.1.10 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // showSavedStaffAccount | Trả về: DC-ManageStaffAccountsStore.createStaff đặt trạng thái kết quả (showSavedStaffAccount); View hiển thị |

Phủ: 308 dòng. Message tới tác nhân người (show*, notify*, reject*) hiển thị bằng View từ trạng thái Store; bảng Store ở F7 nêu trường tương ứng.

## F5. Bảng quan hệ

Mã R-nn mới nối tiếp từ R-330 (dải của phiên); mã có gốc P08 giữ nguyên. Một mã R có thể gồm nhiều cặp cùng loại, cùng lý do (cột Lớp A, Lớp B liệt kê từng cặp); trên sơ đồ mỗi cặp là một cạnh, ID cạnh là R-nn hoặc R-nn.k.

| ID | Lớp A | Lớp B | Loại | Multiplicity | Điều hướng | Lý do | Vai trò | Căn cứ hiển thị |
|---|---|---|---|---|---|---|---|---|
| R-330 | DC-RegisterAccountStore, DC-BrowseMoviesStore, DC-BrowseShowtimesStore, DC-ViewBookingHistoryStore, DC-CancelTicketStore, DC-CounterCancelTicketStore, DC-CheckTicketStore, DC-ManageStaffAccountsStore, DC-SessionStore, DC-SeatMapSyncClient, DC-HoldCountdown, DC-HoldFlowStore | DC-StoreBase | Generalization |  | A --> B | Thiết kế: mọi Store là một khoá trạng thái Flux có người đăng ký (mẫu Observer); thay thế được lớp cha vì không đổi hợp đồng getState, subscribe |  |  |
| R-498 | DC-ManagePriceListStore | DC-ManagedListStore | Generalization |  | A --> B | Thiết kế: Extract Superclass (X1 RV-19), thay R-330 cho Store này | |  |
| R-499 | DC-ScheduleShowtimesStore | DC-ManagedListStore | Generalization |  | A --> B | Thiết kế: Extract Superclass (X1 RV-19), thay R-330 cho Store này | |  |
| R-500 | DC-ManageAuditoriumsStore | DC-ManagedListStore | Generalization |  | A --> B | Thiết kế: Extract Superclass (X1 RV-19), thay R-330 cho Store này | |  |
| R-501 | DC-ManageMoviesStore | DC-ManagedListStore | Generalization |  | A --> B | Thiết kế: Extract Superclass (X1 RV-19), thay R-330 cho Store này | |  |
| R-502 | DC-ManageCinemasStore | DC-ManagedListStore | Generalization |  | A --> B | Thiết kế: Extract Superclass (X1 RV-19), thay R-330 cho Store này | |  |
| R-503 | DC-ViewCinemaReportStore | DC-ReportStoreBase | Generalization |  | A --> B | Thiết kế: Extract Superclass (X1 RV-19), thay R-330 cho Store này | |  |
| R-504 | DC-ViewChainReportStore | DC-ReportStoreBase | Generalization |  | A --> B | Thiết kế: Extract Superclass (X1 RV-19), thay R-330 cho Store này | |  |
| R-505 | DC-ManagedListStore | DC-RequestStoreBase | Generalization |  | A --> B | Thiết kế: Extract Superclass (X1 RV-19), thay R-330 cho Store này | |  |
| R-506 | DC-ReportStoreBase | DC-RequestStoreBase | Generalization |  | A --> B | Thiết kế: Extract Superclass (X1 RV-19), thay R-330 cho Store này | |  |
| R-507 | DC-RequestStoreBase | DC-StoreBase | Generalization |  | A --> B | Thiết kế: Extract Superclass (X1 RV-19), thay R-330 cho Store này | |  |
| R-331 | DC-BookTicketsStore, DC-CounterBookTicketsStore | DC-HoldFlowStore | Generalization |  | A --> B | Thiết kế: hai kênh dùng chung luồng chọn ghế, giữ ghế, huỷ giữ ghế; khác nhau ở bước kết thúc (thanh toán trực tuyến hoặc thu tiền mặt); thay thế được lớp cha (Template Method) |  |  |
| R-332 | DC-FetchApiClient | IF-41 | Realization |  | A --> B | Hiện thực interface |  |  |
| R-333 | DC-BrowserTicker | IF-43 | Realization |  | A --> B | Hiện thực interface |  |  |
| R-334 | DC-BrowserEventSourceFactory | IF-42 | Realization |  | A --> B | Hiện thực interface |  |  |
| R-335 | DC-EmailOutboxJob | IF-06 | Realization |  | A --> B | Hiện thực interface công việc nền do PKG-25 định nghĩa |  |  |
| R-336 | DC-EmailGatewayManager | IF-03 | Realization |  | A --> B | Hiện thực interface của SS-02 |  |  |
| R-337 | DC-RegisterAccountView, DC-BrowseMoviesView, DC-BrowseShowtimesView, DC-ViewBookingHistoryView, DC-CancelTicketView | DC-RegisterAccountStore, DC-BrowseMoviesStore, DC-BrowseShowtimesStore, DC-ViewBookingHistoryStore, DC-CancelTicketStore | Association | A 1 - B 1 | A --> B | View giữ Store của màn hình mình và đăng ký nghe thay đổi; Store không biết View | store | field |
| R-338 | DC-BookTicketsView, DC-CustomerHomeView | DC-BookTicketsStore | Association | A 0..* - B 1 | A --> B | Vỏ đặt vé và trang chủ khách cùng đọc một Store giữ lần giữ ghế đang chạy (dải Tiếp tục thanh toán) | store | field |
| R-339 | DC-BookTicketsView | DC-SelectShowtimePage, DC-SelectSeatsPage, DC-HoldAndPayPage, DC-BookingResultPage | Composition | A 1 - B 1 | A --> B | Mỗi component trang chỉ tồn tại trong vỏ đặt vé, bị huỷ cùng vỏ (P11a Đề xuất) | shell / page | field |
| R-340 | DC-SelectShowtimePage, DC-SelectSeatsPage, DC-HoldAndPayPage, DC-BookingResultPage | DC-BookTicketsStore | Dependency |  | A --> B | Trang nhận Store qua props của vỏ, không giữ lâu dài |  | tham số |
| R-341 | DC-CounterHomeView, DC-CounterBookTicketsView, DC-CounterCancelTicketView | DC-CounterBookTicketsStore, DC-CounterCancelTicketStore | Association | A 0..* - B 1 | A --> B | View giữ Store của màn hình; trang chủ quầy và vỏ bán vé cùng đọc một Store | store | field |
| R-342 | DC-CounterBookTicketsView | DC-CounterSelectSeatsPage, DC-CounterHoldAndCashPage, DC-CounterPrintTicketsPage | Composition | A 1 - B 1 | A --> B | Mỗi component trang chỉ tồn tại trong vỏ bán vé tại quầy (P11a Đề xuất) | shell / page | field |
| R-343 | DC-CounterSelectSeatsPage, DC-CounterHoldAndCashPage, DC-CounterPrintTicketsPage | DC-CounterBookTicketsStore | Dependency |  | A --> B | Trang nhận Store qua props của vỏ |  | tham số |
| R-344 | DC-CheckTicketView | DC-CheckTicketStore | Association | A 1 - B 1 | A --> B | View giữ Store của màn soát vé | store | field |
| R-345 | DC-ManagePriceListView, DC-ScheduleShowtimesView, DC-ManageAuditoriumsView, DC-ViewCinemaReportView | DC-ManagePriceListStore, DC-ScheduleShowtimesStore, DC-ManageAuditoriumsStore, DC-ViewCinemaReportStore | Association | A 1 - B 1 | A --> B | View giữ Store của màn hình | store | field |
| R-346 | DC-ManageMoviesView, DC-ManageCinemasView, DC-ViewChainReportView | DC-ManageMoviesStore, DC-ManageCinemasStore, DC-ViewChainReportStore | Association | A 1 - B 1 | A --> B | View giữ Store của màn hình | store | field |
| R-347 | DC-ManageStaffAccountsView | DC-ManageStaffAccountsStore | Association | A 1 - B 1 | A --> B | View giữ Store của màn hình | store | field |
| R-348 | DC-HoldFlowStore, DC-SeatMapSyncClient, DC-SessionStore, DC-RegisterAccountStore, DC-BrowseMoviesStore, DC-BrowseShowtimesStore, DC-ViewBookingHistoryStore, DC-CancelTicketStore, DC-CounterCancelTicketStore, DC-CheckTicketStore, DC-ManagePriceListStore, DC-ScheduleShowtimesStore, DC-ManageAuditoriumsStore, DC-ViewCinemaReportStore, DC-ManageMoviesStore, DC-ManageCinemasStore, DC-ViewChainReportStore, DC-ManageStaffAccountsStore | IF-41 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc (một thể hiện DC-FetchApiClient dùng chung, nối ở điểm khởi động ứng dụng) | api | field |
| R-349 | DC-HoldFlowStore | DC-SeatMapSyncClient | Association | A 1 - B 1 | A --> B | Mỗi lần đặt chỗ có một bộ đồng bộ sơ đồ ghế | syncClient | field |
| R-350 | DC-HoldFlowStore | DC-HoldCountdown | Association | A 1 - B 1 | A --> B | Mỗi Store có một bộ đếm ngược của lần giữ ghế | countdown | field |
| R-351 | DC-SeatMapSyncClient | IF-42 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | streams | field |
| R-352 | DC-SeatMapSyncClient | DC-SeatMapReducer | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc (hàm thuần dùng chung) | reducer | field |
| R-353 | DC-SeatMapSyncClient, DC-HoldCountdown, DC-CheckTicketStore | IF-43 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc (đồng hồ và hẹn giờ) | ticker | field |
| R-508 | DC-FetchApiClient | IF-48 | Association | A 0..* - B 1 | A --> B | Đính mã phiên vào yêu cầu và báo hết hiệu lực khi nhận 401; thay R-354, không còn vòng với DC-SessionStore | session | field |
| R-509 | DC-SessionStore | IF-48 | Realization |  | A --> B | Hiện thực interface |  |  |
| R-355 | DC-LoginView | DC-SessionStore | Association | A 0..* - B 1 | A --> B | Form đăng nhập gọi SessionStore.login và đọc expiredReason | session | field |
| R-356 | DC-BookTicketsView | DC-LoginView | Dependency |  | A --> B | Vỏ đặt vé dựng LoginView dạng POPUP khi cần đăng nhập (UC-005 luồng 5a1) |  | biến cục bộ |
| R-357 | DC-EmailOutboxJob | IF-23 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc (claim, MarkSucceeded, Reschedule, MarkExhausted) | outbox | field |
| R-358 | DC-EmailOutboxJob | IF-08 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc (giao dịch ngắn đọc dữ liệu thư và ghi kết quả) | uow | field |
| R-359 | DC-EmailOutboxJob | IF-03 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc (gửi thư ngoài giao dịch) | sender | field |
| R-360 | DC-EmailOutboxJob | IF-20, IF-19, IF-21, IF-11, IF-16 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc (đọc không khoá lần đặt, giao dịch, yêu cầu hoàn, suất chiếu, khách để dựng thư) | bookings / payments / refunds / showtimes / holders | field |
| R-361 | DC-EmailGatewayManager | DC-MimeMessageBuilder | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | builder | field |
| R-362 | DC-EmailGatewayManager | DC-SmtpClient | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | client | field |
| R-363 | DC-SmtpClient, DC-MimeMessageBuilder | DC-SmtpConfig | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc (cấu hình nạp một lần lúc khởi động) | config | field |
| R-364 | DC-EmailMessage | DC-EmailAttachment | Composition | A 1 - B 0..* | A --> B | Tệp đính kèm chỉ tồn tại trong thư (P11b C02-06) | message / attachments | field |
| R-365 | DC-HoldFlowStore | DC-SessionStore | Association | A 0..* - B 1 | A --> B | Biết khách đã đăng nhập chưa trước khi gửi yêu cầu giữ ghế (luồng 5a1); đọc phiên, không đổi | session | field |
| R-01 | DC-BookTicketsStore | DC-BookingController | Dependency |  | A --> B | Giữ mã P08 (Association Form --> Controller): đổi thành Dependency vì hai bên cách nhau ranh giới HTTP, Store không giữ tham chiếu tới controller mà gửi yêu cầu REST qua IF-41 (giữ ghế, bắt đầu thanh toán); Lớp B thuộc PKG-11, chi tiết ở P12 PKG-11 |  | qua IF-41 |
| R-02 | DC-CounterBookTicketsStore | DC-BookingController | Dependency |  | A --> B | Giữ mã P08 (Association Form --> Controller): đổi thành Dependency vì hai bên cách nhau ranh giới HTTP, Store không giữ tham chiếu tới controller mà gửi yêu cầu REST qua IF-41 (giữ ghế, xác nhận thu tiền mặt); Lớp B thuộc PKG-11, chi tiết ở P12 PKG-11 |  | qua IF-41 |
| R-06 | DC-BookTicketsStore | DC-PaymentCallbackController | Dependency |  | A --> B | Giữ mã P08 (Association Form --> Controller): đổi thành Dependency vì hai bên cách nhau ranh giới HTTP, Store không giữ tham chiếu tới controller mà gửi yêu cầu REST qua IF-41 (đọc kết quả thanh toán (showBookingSuccess); cập nhật sơ đồ ghế qua SSE ở R-19); Lớp B thuộc PKG-11, chi tiết ở P12 PKG-11 |  | qua IF-41 |
| R-16 | DC-CancelTicketStore | DC-TicketController | Dependency |  | A --> B | Giữ mã P08 (Association Form --> Controller): đổi thành Dependency vì hai bên cách nhau ranh giới HTTP, Store không giữ tham chiếu tới controller mà gửi yêu cầu REST qua IF-41 (huỷ vé của khách); Lớp B thuộc PKG-11, chi tiết ở P12 PKG-11 |  | qua IF-41 |
| R-17 | DC-CounterCancelTicketStore | DC-TicketController | Dependency |  | A --> B | Giữ mã P08 (Association Form --> Controller): đổi thành Dependency vì hai bên cách nhau ranh giới HTTP, Store không giữ tham chiếu tới controller mà gửi yêu cầu REST qua IF-41 (tra mã đặt vé, huỷ vé tại quầy, xác nhận hoàn tiền mặt); Lớp B thuộc PKG-11, chi tiết ở P12 PKG-11 |  | qua IF-41 |
| R-19 | DC-SeatMapSyncClient | DC-SeatMapStreamController | Dependency |  | A --> B | Giữ mã P08 (Association Form --> Controller): đổi thành Dependency vì hai bên cách nhau ranh giới HTTP, Store không giữ tham chiếu tới controller mà gửi yêu cầu REST qua IF-41 (ảnh chụp và luồng sự kiện đổi ghế dùng chung cho đặt vé và huỷ vé (UC-008 bước 7)); Lớp B thuộc PKG-11, chi tiết ở P12 PKG-11 |  | qua IF-41 |
| R-25 | DC-CheckTicketStore | DC-TicketController | Dependency |  | A --> B | Giữ mã P08 (Association Form --> Controller): đổi thành Dependency vì hai bên cách nhau ranh giới HTTP, Store không giữ tham chiếu tới controller mà gửi yêu cầu REST qua IF-41 (soát vé); Lớp B thuộc PKG-11, chi tiết ở P12 PKG-11 |  | qua IF-41 |
| R-29 | DC-ManagePriceListStore | DC-PricingScheduleController | Dependency |  | A --> B | Giữ mã P08 (Association Form --> Controller): đổi thành Dependency vì hai bên cách nhau ranh giới HTTP, Store không giữ tham chiếu tới controller mà gửi yêu cầu REST qua IF-41 (bảng giá); Lớp B thuộc PKG-11, chi tiết ở P12 PKG-11 |  | qua IF-41 |
| R-32 | DC-ScheduleShowtimesStore | DC-PricingScheduleController | Dependency |  | A --> B | Giữ mã P08 (Association Form --> Controller): đổi thành Dependency vì hai bên cách nhau ranh giới HTTP, Store không giữ tham chiếu tới controller mà gửi yêu cầu REST qua IF-41 (suất chiếu); Lớp B thuộc PKG-11, chi tiết ở P12 PKG-11 |  | qua IF-41 |
| R-71 | DC-RegisterAccountStore | DC-AccountController | Dependency |  | A --> B | Giữ mã P08 (Association Form --> Controller): đổi thành Dependency vì hai bên cách nhau ranh giới HTTP, Store không giữ tham chiếu tới controller mà gửi yêu cầu REST qua IF-41 (đăng ký); Lớp B thuộc PKG-11, chi tiết ở P12 PKG-11 |  | qua IF-41 |
| R-73 | DC-BrowseMoviesStore | DC-CatalogController | Dependency |  | A --> B | Giữ mã P08 (Association Form --> Controller): đổi thành Dependency vì hai bên cách nhau ranh giới HTTP, Store không giữ tham chiếu tới controller mà gửi yêu cầu REST qua IF-41 (tra phim); Lớp B thuộc PKG-11, chi tiết ở P12 PKG-11 |  | qua IF-41 |
| R-75 | DC-BrowseShowtimesStore | DC-CatalogController | Dependency |  | A --> B | Giữ mã P08 (Association Form --> Controller): đổi thành Dependency vì hai bên cách nhau ranh giới HTTP, Store không giữ tham chiếu tới controller mà gửi yêu cầu REST qua IF-41 (tra lịch chiếu); Lớp B thuộc PKG-11, chi tiết ở P12 PKG-11 |  | qua IF-41 |
| R-79 | DC-ViewBookingHistoryStore | DC-TicketController | Dependency |  | A --> B | Giữ mã P08 (Association Form --> Controller): đổi thành Dependency vì hai bên cách nhau ranh giới HTTP, Store không giữ tham chiếu tới controller mà gửi yêu cầu REST qua IF-41 (lịch sử đặt vé); Lớp B thuộc PKG-11, chi tiết ở P12 PKG-11 |  | qua IF-41 |
| R-82 | DC-ManageMoviesStore | DC-ChainController | Dependency |  | A --> B | Giữ mã P08 (Association Form --> Controller): đổi thành Dependency vì hai bên cách nhau ranh giới HTTP, Store không giữ tham chiếu tới controller mà gửi yêu cầu REST qua IF-41 (phim); Lớp B thuộc PKG-11, chi tiết ở P12 PKG-11 |  | qua IF-41 |
| R-84 | DC-ManageCinemasStore | DC-ChainController | Dependency |  | A --> B | Giữ mã P08 (Association Form --> Controller): đổi thành Dependency vì hai bên cách nhau ranh giới HTTP, Store không giữ tham chiếu tới controller mà gửi yêu cầu REST qua IF-41 (cụm rạp); Lớp B thuộc PKG-11, chi tiết ở P12 PKG-11 |  | qua IF-41 |
| R-86 | DC-ManageAuditoriumsStore | DC-PricingScheduleController | Dependency |  | A --> B | Giữ mã P08 (Association Form --> Controller): đổi thành Dependency vì hai bên cách nhau ranh giới HTTP, Store không giữ tham chiếu tới controller mà gửi yêu cầu REST qua IF-41 (phòng chiếu); Lớp B thuộc PKG-11, chi tiết ở P12 PKG-11 |  | qua IF-41 |
| R-90 | DC-ViewCinemaReportStore | DC-ReportController | Dependency |  | A --> B | Giữ mã P08 (Association Form --> Controller): đổi thành Dependency vì hai bên cách nhau ranh giới HTTP, Store không giữ tham chiếu tới controller mà gửi yêu cầu REST qua IF-41 (báo cáo cụm rạp); Lớp B thuộc PKG-11, chi tiết ở P12 PKG-11 |  | qua IF-41 |
| R-96 | DC-ViewChainReportStore | DC-ReportController | Dependency |  | A --> B | Giữ mã P08 (Association Form --> Controller): đổi thành Dependency vì hai bên cách nhau ranh giới HTTP, Store không giữ tham chiếu tới controller mà gửi yêu cầu REST qua IF-41 (báo cáo chuỗi); Lớp B thuộc PKG-11, chi tiết ở P12 PKG-11 |  | qua IF-41 |
| R-101 | DC-ManageStaffAccountsStore | DC-AccountController | Dependency |  | A --> B | Giữ mã P08 (Association Form --> Controller): đổi thành Dependency vì hai bên cách nhau ranh giới HTTP, Store không giữ tham chiếu tới controller mà gửi yêu cầu REST qua IF-41 (tài khoản nhân viên); Lớp B thuộc PKG-11, chi tiết ở P12 PKG-11 |  | qua IF-41 |

Quan hệ P08 giữ mã nhưng đổi loại: mười chín mã R-01 đến R-101 là Association giữa Form và Controller của P08; ở thiết kế hai bên cách nhau ranh giới HTTP, nên là Dependency qua IF-41, Lớp B thuộc PKG-11 hoặc PKG-12 (không tính vào F9 vì là lời gọi mạng, không phải phụ thuộc mã nguồn). Quan hệ P08 mà đầu B không còn tồn tại như một lớp phía trình duyệt (AC-C-... đã thành lớp dịch vụ PKG-13 đến PKG-19) do lần chạy chứa Lớp B thiết kế (P12 lõi, P12 PKG-11). Quan hệ P08 R-03, R-04, R-05 (PaymentGateway, EmailService với controller) đã thiết kế ở P12 lõi và SS-01, SS-02; không lặp lại.

## F6. State machine

Hai state machine: ST-17 (luồng đặt chỗ ở trình duyệt, nơi race condition giữ ghế được xử lý phía người dùng) và ST-18 (kết nối đồng bộ sơ đồ ghế). View và các Store khác không có state machine: trạng thái của chúng là LoadStatus (IDLE, LOADING, READY, SUBMITTING, FAILED), không có BR dạng "chỉ được X khi đang Y" ngoài việc chặn bấm hai lần (cờ submitting). Vòng đời vé, giữ ghế, thanh toán ở máy chủ là ST-01 đến ST-05 của P12 lõi.

### ST-17. Luồng đặt chỗ (DC-HoldFlowStore)

F6.1. Bảng trạng thái

| ST | Lớp | Trạng thái | Mô tả / điều kiện nhận biết | entry | do | exit |
|---|---|---|---|---|---|---|
| ST-17 | DC-HoldFlowStore | NoShowtime | phase = NO_SHOWTIME: chưa mở suất chiếu nào, hoặc suất bị từ chối | - | - | - |
| ST-17 | DC-HoldFlowStore | SelectingSeats | phase = SELECTING_SEATS: suất đã mở, DC-SeatMapSyncClient chạy, tập ghế chọn đổi được | syncClient.start(showtimeId) | đồng bộ sơ đồ ghế (ST-18) | - |
| ST-17 | DC-HoldFlowStore | HoldRequested | phase = HOLD_REQUESTED: đã gửi yêu cầu giữ ghế kèm requestId, chưa có phản hồi | lưu requestId vào sessionStorage | - | xoá requestId khi có kết quả |
| ST-17 | DC-HoldFlowStore | Held | phase = HELD: hold khác null, lần giữ ghế ACTIVE theo máy chủ | countdown.start(expiryTime, serverTime) | đếm ngược mỗi giây | countdown.stop() khi rời Held |
| ST-17 | DC-HoldFlowStore | PaymentRedirecting | phase = PAYMENT_REDIRECTING: đang tạo giao dịch thanh toán, chuẩn bị chuyển sang cổng | - | - | - |
| ST-17 | DC-HoldFlowStore | AwaitingResult | phase = AWAITING_RESULT: trình duyệt đã quay về từ cổng, đang đọc kết quả thanh toán | - | hỏi lại 2 giây một lần, tối đa 30 giây | - |
| ST-17 | DC-HoldFlowStore | Booked | phase = BOOKED: có mã đặt vé (trực tuyến) hoặc đã bán tại quầy | syncClient.stop() | - | - |
| ST-17 | DC-HoldFlowStore | Ended | phase = ENDED, endReason EXPIRED, CANCELLED hoặc PAYMENT_FAILED: lần giữ ghế đã kết thúc không có vé | syncClient.stop(), countdown.stop() | - | - |

F6.2. Bảng chuyển trạng thái

| ST | Lớp | Trạng thái | Sự kiện | Guard | Hành động | Trạng thái đích | STT | Operation tương ứng | Nguồn |
|---|---|---|---|---|---|---|---|---|---|
| ST-17 | DC-HoldFlowStore | (initial) | create | - | / phase = NO_SHOWTIME | NoShowtime | 1 | hàm dựng DC-HoldFlowStore | Bổ sung: khởi tạo |
| ST-17 | DC-HoldFlowStore | NoShowtime | openShowtime(showtimeId) | [suất mở bán, chưa bắt đầu, đúng phòng] | / lưu ShowtimeView, syncClient.start | SelectingSeats | 2 | DC-HoldFlowStore.openShowtime | P07 UC-005 msg 1.1, 1.1.3; BR-01, BR-02 |
| ST-17 | DC-HoldFlowStore | NoShowtime | openShowtime(showtimeId) | [suất chưa mở bán, đã đổi, không còn, hoặc khác cụm rạp của nhân viên] | / refusal = MSG-84, MSG-12 hoặc MSG của BR-02 | NoShowtime | 3 | DC-HoldFlowStore.openShowtime | P07 UC-005 luồng 2a, 2b, 2c; MSG-12, MSG-84 |
| ST-17 | DC-HoldFlowStore | NoShowtime | loadActiveHold() | [có lần giữ ghế ACTIVE] | / applyHold(hold) | Held | 4 | DC-HoldFlowStore.loadActiveHold | P11a E-32, E-33; BR-04 |
| ST-17 | DC-HoldFlowStore | NoShowtime | loadActiveHold() | [không có lần giữ ghế ACTIVE] | / không đổi | NoShowtime | 5 | DC-HoldFlowStore.loadActiveHold | P11a E-32, E-33 |
| ST-17 | DC-HoldFlowStore | SelectingSeats | toggleSeat(seatId) | - | / thêm hoặc bỏ ghế Trống; vượt số ghế tối đa thì refusal MSG-10 | SelectingSeats | 6 | DC-HoldFlowStore.toggleSeat | MSG-10 |
| ST-17 | DC-HoldFlowStore | SelectingSeats | seatMapChanged | - | / bỏ ghế đã bị lấy khỏi tập chọn, conflictSeatIds (MSG-11) | SelectingSeats | 7 | DC-HoldFlowStore.onSeatMapChanged | P07 UC-005 // updateSeatMap; MSG-11 |
| ST-17 | DC-HoldFlowStore | SelectingSeats | confirmSeatSelection() | [tập chọn không rỗng và (đã đăng nhập)] | / requestId = UUID mới nếu chưa có; gửi giữ ghế | HoldRequested | 8 | DC-HoldFlowStore.confirmSeatSelection | P07 UC-005 msg 2.1; BR-04 |
| ST-17 | DC-HoldFlowStore | SelectingSeats | confirmSeatSelection() | [tập chọn không rỗng và chưa đăng nhập] | / needsLogin = true | SelectingSeats | 9 | DC-HoldFlowStore.confirmSeatSelection | P07 UC-005 luồng 5a1; // requestLogin |
| ST-17 | DC-HoldFlowStore | HoldRequested | holdGranted(hold) | - | / applyHold(hold) | Held | 10 | DC-HoldFlowStore.confirmSeatSelection | P07 UC-005 // showHeldSeats |
| ST-17 | DC-HoldFlowStore | HoldRequested | holdRefused(error) | [mã GHE_BI_LAY, QUA_SO_GHE, DA_CO_LAN_GIU_GHE hoặc ghế không hợp lệ] | / refusal, syncClient.reload() | SelectingSeats | 11 | DC-HoldFlowStore.confirmSeatSelection | P07 UC-005 luồng 5b, 7a, 7c, 7e; MSG-10, MSG-11 |
| ST-17 | DC-HoldFlowStore | HoldRequested | holdRefused(error) | [mã SUAT_DA_DOI, SUAT_CHUA_MO_BAN hoặc SAI_CUM_RAP] | / refusal | NoShowtime | 12 | DC-HoldFlowStore.confirmSeatSelection | P07 UC-005 luồng 7d, 2a; MSG-12, MSG-84 |
| ST-17 | DC-HoldFlowStore | HoldRequested | networkError | - | / gửi lại cùng requestId (máy chủ trả replayed = true, không giữ ghế hai lần) | HoldRequested | 13 | DC-HoldFlowStore.confirmSeatSelection | BR-85; Q-333; P00 race condition |
| ST-17 | DC-HoldFlowStore | Held | startOnlinePayment() | [kênh khách] | / gửi tạo giao dịch | PaymentRedirecting | 14 | DC-BookTicketsStore.startOnlinePayment | P07 UC-005 msg 3.1; BR-90 |
| ST-17 | DC-HoldFlowStore | PaymentRedirecting | paymentUrlReady(url) | - | / View chuyển trình duyệt sang url; store dừng ở đây khi trang bị thay | AwaitingResult | 15 | DC-BookTicketsStore.startOnlinePayment | P07 UC-005 // startOnlinePayment |
| ST-17 | DC-HoldFlowStore | PaymentRedirecting | paymentStartFailed(error) | - | / refusal; lần giữ ghế vẫn ACTIVE | Held | 16 | DC-BookTicketsStore.startOnlinePayment | P11a SCR-05 mục 3; M7 lối ra |
| ST-17 | DC-HoldFlowStore | Held | loadPaymentOutcome(holdRef) | - | / hỏi trạng thái (trang kết quả mở trực tiếp sau khi tải lại) | AwaitingResult | 17 | DC-BookTicketsStore.loadPaymentOutcome | P11a E-18 |
| ST-17 | DC-HoldFlowStore | AwaitingResult | loadPaymentOutcome(holdRef) | [có mã đặt vé] | / paymentOutcome | Booked | 18 | DC-BookTicketsStore.loadPaymentOutcome | P07 UC-005 // showBookingSuccess |
| ST-17 | DC-HoldFlowStore | AwaitingResult | loadPaymentOutcome(holdRef) | [thanh toán thất bại hoặc lần giữ ghế Thanh toán thất bại] | / endReason = PAYMENT_FAILED | Ended | 19 | DC-BookTicketsStore.loadPaymentOutcome | P07 UC-005 luồng 11a |
| ST-17 | DC-HoldFlowStore | AwaitingResult | loadPaymentOutcome(holdRef) | [lần giữ ghế Hết hạn] | / endReason = EXPIRED | Ended | 20 | DC-BookTicketsStore.loadPaymentOutcome | P07 UC-005 luồng 7b; BR-86 |
| ST-17 | DC-HoldFlowStore | AwaitingResult | loadPaymentOutcome(holdRef) | [chưa có kết quả và đã hỏi dưới 30 giây] | / hẹn hỏi lại sau 2 giây | AwaitingResult | 21 | DC-BookTicketsStore.loadPaymentOutcome | Q-334 |
| ST-17 | DC-HoldFlowStore | AwaitingResult | backToPayment() | [lần giữ ghế còn ACTIVE] | / applyHold(hold) | Held | 22 | DC-BookTicketsStore.loadPaymentOutcome | P11a E-34 |
| ST-17 | DC-HoldFlowStore | Held | confirmCashReceived() | [lần giữ ghế còn ACTIVE, kênh quầy] | / gửi xác nhận; soldTickets | Booked | 23 | DC-CounterBookTicketsStore.confirmCashReceived | P07 UC-005 luồng 9a1 |
| ST-17 | DC-HoldFlowStore | Held | confirmCashReceived() | [HoldNotActive: lần giữ ghế đã Hết hạn, Đã huỷ hoặc Thanh toán thất bại] | / refusal trả lại tiền mặt (9a1a); endReason theo trạng thái cuối | Ended | 24 | DC-CounterBookTicketsStore.confirmCashReceived | P07 UC-005 luồng 9a1a; BR-44 |
| ST-17 | DC-HoldFlowStore | Held | confirmCashReceived() | [NetworkError] | / reconcileCashResult() thay vì gửi lại | Held | 25 | DC-CounterBookTicketsStore.reconcileCashResult | Q-341; BR-44 |
| ST-17 | DC-HoldFlowStore | Held | cancelHold() | - | / gửi huỷ giữ ghế; endReason = CANCELLED | Ended | 26 | DC-HoldFlowStore.cancelHold | P07 UC-005 luồng *a; MSG-19 |
| ST-17 | DC-HoldFlowStore | Held | holdExpired | [remainingSeconds = 0] | / endReason = EXPIRED; refusal MSG-14 hoặc MSG-29 | Ended | 27 | DC-HoldFlowStore.onHoldExpired | P07 UC-005 luồng 7b; BR-10 |
| ST-17 | DC-HoldFlowStore | Booked | dispose() | - | / giải phóng bộ đồng bộ | (final) | 28 | DC-HoldFlowStore.dispose | Bổ sung: kết thúc vòng đời khi rời màn hình |
| ST-17 | DC-HoldFlowStore | Ended | dispose() | - | / giải phóng bộ đồng bộ | (final) | 29 | DC-HoldFlowStore.dispose | Bổ sung: kết thúc vòng đời khi rời màn hình |

Sự kiện bị từ chối

| ST | Trạng thái | Sự kiện | Xử lý |
|---|---|---|---|
| ST-17 | SelectingSeats | loadActiveHold() | Bỏ qua (đang chọn ghế, không nạp đè) |
| ST-17 | SelectingSeats | cancelHold() | Bỏ qua (chưa có lần giữ ghế; View không hiện nút) |
| ST-17 | HoldRequested | toggleSeat(seatId) | Bỏ qua (tập chọn đã gửi) |
| ST-17 | HoldRequested | confirmSeatSelection() | Bỏ qua (chống bấm hai lần; một yêu cầu đang chạy) |
| ST-17 | Held | openShowtime(showtimeId) | Ngoại lệ BookingStateError (BR-04: một người một lần giữ ghế; phải huỷ hoặc chờ hết hạn) |
| ST-17 | Held | confirmSeatSelection() | Bỏ qua (đã có lần giữ ghế) |
| ST-17 | PaymentRedirecting | cancelHold() | Bỏ qua (đang chuyển cổng; khách huỷ ở SCR-05 sau khi quay lại) |
| ST-17 | AwaitingResult | cancelHold() | Ngoại lệ BookingStateError (đã chuyển cổng; máy chủ quyết kết quả, BR-85) |
| ST-17 | Booked, Ended | mọi sự kiện trừ dispose() | Bỏ qua (trạng thái cuối; mở suất chiếu mới dùng Store mới) |

F6.3. Ánh xạ về mô hình lớp

| ST | Thuộc tính biểu diễn trạng thái | Kiểu (enumeration) | Operation được thêm/sửa |
|---|---|---|---|
| ST-17 | phase: BookingPhase (kèm endReason: EndReason khi ENDED) | DC-BookingPhase, DC-EndReason | DC-BookTicketsStore.startOnlinePayment, loadPaymentOutcome; DC-CounterBookTicketsStore.confirmCashReceived, reconcileCashResult; DC-HoldFlowStore.dispose |

F6.4. Sơ đồ state machine

File diagrams/P12-state-DC-HoldFlowStore.drawio. Chỉ có trạng thái cuối nghiệp vụ Booked và Ended nối tới (final) khi dispose() kết thúc vòng đời của Store.

| ID | Loại | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| ST-17-I | Initial | (initial) | - | DC-HoldFlowStore | - |
| ST-17-S1 | State | NoShowtime | - | DC-HoldFlowStore | - |
| ST-17-S2 | State | SelectingSeats (entry / syncClient.start(showtimeId)) (do / đồng bộ sơ đồ ghế (ST-18)) | - | DC-HoldFlowStore | - |
| ST-17-S3 | State | HoldRequested (entry / lưu requestId vào sessionStorage) (exit / xoá requestId khi có kết quả) | - | DC-HoldFlowStore | - |
| ST-17-S4 | State | Held (entry / countdown.start(expiryTime, serverTime)) (do / đếm ngược mỗi giây) (exit / countdown.stop() khi rời Held) | - | DC-HoldFlowStore | - |
| ST-17-S5 | State | PaymentRedirecting | - | DC-HoldFlowStore | - |
| ST-17-S6 | State | AwaitingResult (do / hỏi lại 2 giây một lần, tối đa 30 giây) | - | DC-HoldFlowStore | - |
| ST-17-S7 | State | Booked (entry / syncClient.stop()) | - | DC-HoldFlowStore | - |
| ST-17-S8 | State | Ended (entry / syncClient.stop(), countdown.stop()) | - | DC-HoldFlowStore | - |
| ST-17-F1 | Final | (final) | - | DC-HoldFlowStore | - |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn | Ghi chú |
|---|---|---|---|---|---|
| ST-17-T1 | ST-17-I | ST-17-S1 | Transition | create / phase = NO_SHOWTIME | Bổ sung: khởi tạo |
| ST-17-T2 | ST-17-S1 | ST-17-S2 | Transition | openShowtime(showtimeId) [suất mở bán, chưa bắt đầu, đúng phòng] / lưu ShowtimeView, syncClient.start | P07 UC-005 msg 1.1, 1.1.3; BR-01, BR-02 |
| ST-17-T3 | ST-17-S1 | ST-17-S1 | Transition | openShowtime(showtimeId) [suất chưa mở bán, đã đổi, không còn, hoặc khác cụm rạp của nhân viên] / refusal = MSG-84, MSG-12 hoặc MSG của BR-02 | P07 UC-005 luồng 2a, 2b, 2c; MSG-12, MSG-84 |
| ST-17-T4 | ST-17-S1 | ST-17-S4 | Transition | loadActiveHold() [có lần giữ ghế ACTIVE] / applyHold(hold) | P11a E-32, E-33; BR-04 |
| ST-17-T5 | ST-17-S1 | ST-17-S1 | Transition | loadActiveHold() [không có lần giữ ghế ACTIVE] / không đổi | P11a E-32, E-33 |
| ST-17-T6 | ST-17-S2 | ST-17-S2 | Transition | toggleSeat(seatId) / thêm hoặc bỏ ghế Trống; vượt số ghế tối đa thì refusal MSG-10 | MSG-10 |
| ST-17-T7 | ST-17-S2 | ST-17-S2 | Transition | seatMapChanged / bỏ ghế đã bị lấy khỏi tập chọn, conflictSeatIds (MSG-11) | P07 UC-005 // updateSeatMap; MSG-11 |
| ST-17-T8 | ST-17-S2 | ST-17-S3 | Transition | confirmSeatSelection() [tập chọn không rỗng và (đã đăng nhập)] / requestId = UUID mới nếu chưa có; gửi giữ ghế | P07 UC-005 msg 2.1; BR-04 |
| ST-17-T9 | ST-17-S2 | ST-17-S2 | Transition | confirmSeatSelection() [tập chọn không rỗng và chưa đăng nhập] / needsLogin = true | P07 UC-005 luồng 5a1; // requestLogin |
| ST-17-T10 | ST-17-S3 | ST-17-S4 | Transition | holdGranted(hold) / applyHold(hold) | P07 UC-005 // showHeldSeats |
| ST-17-T11 | ST-17-S3 | ST-17-S2 | Transition | holdRefused(error) [mã GHE_BI_LAY, QUA_SO_GHE, DA_CO_LAN_GIU_GHE hoặc ghế không hợp lệ] / refusal, syncClient.reload() | P07 UC-005 luồng 5b, 7a, 7c, 7e; MSG-10, MSG-11 |
| ST-17-T12 | ST-17-S3 | ST-17-S1 | Transition | holdRefused(error) [mã SUAT_DA_DOI, SUAT_CHUA_MO_BAN hoặc SAI_CUM_RAP] / refusal | P07 UC-005 luồng 7d, 2a; MSG-12, MSG-84 |
| ST-17-T13 | ST-17-S3 | ST-17-S3 | Transition | networkError / gửi lại cùng requestId (máy chủ trả replayed = true, không giữ ghế hai lần) | BR-85; Q-333; P00 race condition |
| ST-17-T14 | ST-17-S4 | ST-17-S5 | Transition | startOnlinePayment() [kênh khách] / gửi tạo giao dịch | P07 UC-005 msg 3.1; BR-90 |
| ST-17-T15 | ST-17-S5 | ST-17-S6 | Transition | paymentUrlReady(url) / View chuyển trình duyệt sang url; store dừng ở đây khi trang bị thay | P07 UC-005 // startOnlinePayment |
| ST-17-T16 | ST-17-S5 | ST-17-S4 | Transition | paymentStartFailed(error) / refusal; lần giữ ghế vẫn ACTIVE | P11a SCR-05 mục 3; M7 lối ra |
| ST-17-T17 | ST-17-S4 | ST-17-S6 | Transition | loadPaymentOutcome(holdRef) / hỏi trạng thái (trang kết quả mở trực tiếp sau khi tải lại) | P11a E-18 |
| ST-17-T18 | ST-17-S6 | ST-17-S7 | Transition | loadPaymentOutcome(holdRef) [có mã đặt vé] / paymentOutcome | P07 UC-005 // showBookingSuccess |
| ST-17-T19 | ST-17-S6 | ST-17-S8 | Transition | loadPaymentOutcome(holdRef) [thanh toán thất bại hoặc lần giữ ghế Thanh toán thất bại] / endReason = PAYMENT_FAILED | P07 UC-005 luồng 11a |
| ST-17-T20 | ST-17-S6 | ST-17-S8 | Transition | loadPaymentOutcome(holdRef) [lần giữ ghế Hết hạn] / endReason = EXPIRED | P07 UC-005 luồng 7b; BR-86 |
| ST-17-T21 | ST-17-S6 | ST-17-S6 | Transition | loadPaymentOutcome(holdRef) [chưa có kết quả và đã hỏi dưới 30 giây] / hẹn hỏi lại sau 2 giây | Q-334 |
| ST-17-T22 | ST-17-S6 | ST-17-S4 | Transition | backToPayment() [lần giữ ghế còn ACTIVE] / applyHold(hold) | P11a E-34 |
| ST-17-T23 | ST-17-S4 | ST-17-S7 | Transition | confirmCashReceived() [lần giữ ghế còn ACTIVE, kênh quầy] / gửi xác nhận; soldTickets | P07 UC-005 luồng 9a1 |
| ST-17-T24 | ST-17-S4 | ST-17-S8 | Transition | confirmCashReceived() [HoldNotActive: lần giữ ghế đã Hết hạn, Đã huỷ hoặc Thanh toán thất bại] / refusal trả lại tiền mặt (9a1a); endReason theo trạng thái cuối | P07 UC-005 luồng 9a1a; BR-44 |
| ST-17-T25 | ST-17-S4 | ST-17-S4 | Transition | confirmCashReceived() [NetworkError] / reconcileCashResult() thay vì gửi lại | Q-341; BR-44 |
| ST-17-T26 | ST-17-S4 | ST-17-S8 | Transition | cancelHold() / gửi huỷ giữ ghế; endReason = CANCELLED | P07 UC-005 luồng *a; MSG-19 |
| ST-17-T27 | ST-17-S4 | ST-17-S8 | Transition | holdExpired [remainingSeconds = 0] / endReason = EXPIRED; refusal MSG-14 hoặc MSG-29 | P07 UC-005 luồng 7b; BR-10 |
| ST-17-T28 | ST-17-S7 | ST-17-F1 | Transition | dispose() / giải phóng bộ đồng bộ | Bổ sung: kết thúc vòng đời khi rời màn hình |
| ST-17-T29 | ST-17-S8 | ST-17-F1 | Transition | dispose() / giải phóng bộ đồng bộ | Bổ sung: kết thúc vòng đời khi rời màn hình |

### ST-18. Kết nối đồng bộ sơ đồ ghế (DC-SeatMapSyncClient)

F6.1. Bảng trạng thái

| ST | Lớp | Trạng thái | Mô tả / điều kiện nhận biết | entry | do | exit |
|---|---|---|---|---|---|---|
| ST-18 | DC-SeatMapSyncClient | Closed | connection = CLOSED: chưa mở hoặc đã dừng | - | - | - |
| ST-18 | DC-SeatMapSyncClient | Connecting | connection = CONNECTING: đang tải ảnh chụp hoặc mở kết nối đẩy từ con trỏ | - | - | - |
| ST-18 | DC-SeatMapSyncClient | Live | connection = LIVE: kết nối mở, nhận khung | retryCount = 0, lastFrameAt = now | checkLiveness mỗi giây | - |
| ST-18 | DC-SeatMapSyncClient | Reconnecting | connection = RECONNECTING: kết nối mất, chờ nối lại | đóng kết nối cũ, hẹn nối lại sau độ lùi | - | huỷ hẹn giờ nối lại |
| ST-18 | DC-SeatMapSyncClient | ReloadPending | connection = RELOAD_PENDING: chờ tải lại ảnh chụp sau độ trễ ngẫu nhiên | hẹn reload sau 0 đến 3 giây | - | huỷ hẹn giờ reload |

F6.2. Bảng chuyển trạng thái

| ST | Lớp | Trạng thái | Sự kiện | Guard | Hành động | Trạng thái đích | STT | Operation tương ứng | Nguồn |
|---|---|---|---|---|---|---|---|---|---|
| ST-18 | DC-SeatMapSyncClient | (initial) | create | - | / connection = CLOSED | Closed | 1 | hàm dựng DC-SeatMapSyncClient | Bổ sung: khởi tạo |
| ST-18 | DC-SeatMapSyncClient | Closed | start(showtimeId) | - | / tải ảnh chụp, SeatMapReducer.fromSnapshot | Connecting | 2 | DC-SeatMapSyncClient.start | P07 UC-005 // showSeatMap; P09 F7.5 điểm 4 |
| ST-18 | DC-SeatMapSyncClient | Connecting | streamOpened | - | / retryCount = 0 | Live | 3 | DC-SeatMapSyncClient.start | P09 F7.5 điểm 4 |
| ST-18 | DC-SeatMapSyncClient | Connecting | snapshotFailed(error) | - | / lùi thời gian, hẹn reload | ReloadPending | 4 | DC-SeatMapSyncClient.start | P09 F7.5 (độ tin cậy) |
| ST-18 | DC-SeatMapSyncClient | Connecting | streamError | - | / retryCount++ | Reconnecting | 5 | DC-SeatMapSyncClient.onStreamError | ST-18 |
| ST-18 | DC-SeatMapSyncClient | Live | seatEvent(event) | - | / map = applyEvent(map, event); lastFrameAt = now | Live | 6 | DC-SeatMapSyncClient.onSeatEvent | P07 UC-005 // updateSeatMap; P09 F7.5 điểm 5 |
| ST-18 | DC-SeatMapSyncClient | Live | heartbeat | - | / lastFrameAt = now | Live | 7 | DC-SeatMapSyncClient.onHeartbeat | P09 F7.5 (nhịp tim 15 giây) |
| ST-18 | DC-SeatMapSyncClient | Live | streamError | - | / retryCount++ | Reconnecting | 8 | DC-SeatMapSyncClient.onStreamError | ST-18 |
| ST-18 | DC-SeatMapSyncClient | Live | when(now - lastFrameAt > 20 s) | - | / đóng kết nối | Reconnecting | 9 | DC-SeatMapSyncClient.checkLiveness | P09 F7.5 (20 giây coi là chết) |
| ST-18 | DC-SeatMapSyncClient | Live | reloadRequired | - | / không có | ReloadPending | 10 | DC-SeatMapSyncClient.onReloadRequired | P09 F7.5 điểm 6 (RELOAD_REQUIRED, SLOW_CONSUMER) |
| ST-18 | DC-SeatMapSyncClient | Live | when(60 s kể từ lần tải ảnh chụp cuối) | - | / tải lại ảnh chụp | Connecting | 11 | DC-SeatMapSyncClient.checkLiveness | P09 F7.5 (làm mới 60 giây, lưới an toàn) |
| ST-18 | DC-SeatMapSyncClient | Reconnecting | reconnectTimer | - | / mở kết nối với after = cursor | Connecting | 12 | DC-SeatMapSyncClient.start | P09 F7.5 điểm 4; Q-114 |
| ST-18 | DC-SeatMapSyncClient | Reconnecting | reloadRequired | - | / không có | ReloadPending | 13 | DC-SeatMapSyncClient.onReloadRequired | P09 F7.5 điểm 6 |
| ST-18 | DC-SeatMapSyncClient | ReloadPending | reloadTimer | - | / tải lại ảnh chụp, thay map | Connecting | 14 | DC-SeatMapSyncClient.reload | P09 F7.5 điểm 6 |
| ST-18 | DC-SeatMapSyncClient | Connecting | stop() | - | / đóng kết nối, huỷ hẹn giờ | Closed | 15 | DC-SeatMapSyncClient.stop | Bổ sung: rời màn hình |
| ST-18 | DC-SeatMapSyncClient | Live | stop() | - | / đóng kết nối, huỷ hẹn giờ | Closed | 16 | DC-SeatMapSyncClient.stop | Bổ sung: rời màn hình |
| ST-18 | DC-SeatMapSyncClient | Reconnecting | stop() | - | / huỷ hẹn giờ | Closed | 17 | DC-SeatMapSyncClient.stop | Bổ sung: rời màn hình |
| ST-18 | DC-SeatMapSyncClient | ReloadPending | stop() | - | / huỷ hẹn giờ | Closed | 18 | DC-SeatMapSyncClient.stop | Bổ sung: rời màn hình |

Sự kiện bị từ chối

| ST | Trạng thái | Sự kiện | Xử lý |
|---|---|---|---|
| ST-18 | Closed | seatEvent, heartbeat, streamError, reloadRequired | Bỏ qua (callback muộn sau stop(); không có kết nối) |
| ST-18 | Connecting | seatEvent | Bỏ qua (chưa có ảnh chụp để áp; sự kiện nằm trong phần phát lại từ con trỏ) |
| ST-18 | Live, Connecting, Reconnecting, ReloadPending | start(showtimeId) | Ngoại lệ BookingStateError nếu khác suất chiếu; cùng suất thì bỏ qua |
| ST-18 | Reconnecting, ReloadPending | seatEvent, heartbeat | Bỏ qua (kết nối cũ đã đóng) |

F6.3. Ánh xạ về mô hình lớp

| ST | Thuộc tính biểu diễn trạng thái | Kiểu (enumeration) | Operation được thêm/sửa |
|---|---|---|---|
| ST-18 | connection: ConnectionState | DC-ConnectionState | DC-SeatMapSyncClient.onSeatEvent, onHeartbeat, onStreamError, onReloadRequired, checkLiveness |

F6.4. Sơ đồ state machine

File diagrams/P12-state-DC-SeatMapSyncClient.drawio. Không vẽ trạng thái cuối: bộ đồng bộ dùng lại được sau stop().

| ID | Loại | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| ST-18-I | Initial | (initial) | - | DC-SeatMapSyncClient | - |
| ST-18-S1 | State | Closed | - | DC-SeatMapSyncClient | - |
| ST-18-S2 | State | Connecting | - | DC-SeatMapSyncClient | - |
| ST-18-S3 | State | Live (entry / retryCount = 0, lastFrameAt = now) (do / checkLiveness mỗi giây) | - | DC-SeatMapSyncClient | - |
| ST-18-S4 | State | Reconnecting (entry / đóng kết nối cũ, hẹn nối lại sau độ lùi) (exit / huỷ hẹn giờ nối lại) | - | DC-SeatMapSyncClient | - |
| ST-18-S5 | State | ReloadPending (entry / hẹn reload sau 0 đến 3 giây) (exit / huỷ hẹn giờ reload) | - | DC-SeatMapSyncClient | - |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn | Ghi chú |
|---|---|---|---|---|---|
| ST-18-T1 | ST-18-I | ST-18-S1 | Transition | create / connection = CLOSED | Bổ sung: khởi tạo |
| ST-18-T2 | ST-18-S1 | ST-18-S2 | Transition | start(showtimeId) / tải ảnh chụp, SeatMapReducer.fromSnapshot | P07 UC-005 // showSeatMap; P09 F7.5 điểm 4 |
| ST-18-T3 | ST-18-S2 | ST-18-S3 | Transition | streamOpened / retryCount = 0 | P09 F7.5 điểm 4 |
| ST-18-T4 | ST-18-S2 | ST-18-S5 | Transition | snapshotFailed(error) / lùi thời gian, hẹn reload | P09 F7.5 (độ tin cậy) |
| ST-18-T5 | ST-18-S2 | ST-18-S4 | Transition | streamError / retryCount++ | ST-18 |
| ST-18-T6 | ST-18-S3 | ST-18-S3 | Transition | seatEvent(event) / map = applyEvent(map, event); lastFrameAt = now | P07 UC-005 // updateSeatMap; P09 F7.5 điểm 5 |
| ST-18-T7 | ST-18-S3 | ST-18-S3 | Transition | heartbeat / lastFrameAt = now | P09 F7.5 (nhịp tim 15 giây) |
| ST-18-T8 | ST-18-S3 | ST-18-S4 | Transition | streamError / retryCount++ | ST-18 |
| ST-18-T9 | ST-18-S3 | ST-18-S4 | Transition | when(now - lastFrameAt > 20 s) / đóng kết nối | P09 F7.5 (20 giây coi là chết) |
| ST-18-T10 | ST-18-S3 | ST-18-S5 | Transition | reloadRequired / không có | P09 F7.5 điểm 6 (RELOAD_REQUIRED, SLOW_CONSUMER) |
| ST-18-T11 | ST-18-S3 | ST-18-S2 | Transition | when(60 s kể từ lần tải ảnh chụp cuối) / tải lại ảnh chụp | P09 F7.5 (làm mới 60 giây, lưới an toàn) |
| ST-18-T12 | ST-18-S4 | ST-18-S2 | Transition | reconnectTimer / mở kết nối với after = cursor | P09 F7.5 điểm 4; Q-114 |
| ST-18-T13 | ST-18-S4 | ST-18-S5 | Transition | reloadRequired / không có | P09 F7.5 điểm 6 |
| ST-18-T14 | ST-18-S5 | ST-18-S2 | Transition | reloadTimer / tải lại ảnh chụp, thay map | P09 F7.5 điểm 6 |
| ST-18-T15 | ST-18-S2 | ST-18-S1 | Transition | stop() / đóng kết nối, huỷ hẹn giờ | Bổ sung: rời màn hình |
| ST-18-T16 | ST-18-S3 | ST-18-S1 | Transition | stop() / đóng kết nối, huỷ hẹn giờ | Bổ sung: rời màn hình |
| ST-18-T17 | ST-18-S4 | ST-18-S1 | Transition | stop() / huỷ hẹn giờ | Bổ sung: rời màn hình |
| ST-18-T18 | ST-18-S5 | ST-18-S1 | Transition | stop() / huỷ hẹn giờ | Bổ sung: rời màn hình |

Mục M7 (00-Concurrency.md): mọi trạng thái trung gian của ST-17 có chuyển ra do cơ chế hồi phục: HoldRequested thoát bằng gửi lại cùng requestId, bị từ chối hoặc lỗi mạng hết lượt rồi loadActiveHold (chuyển 11, 12, 13); PaymentRedirecting thoát bằng lỗi trở về Held hoặc trang kết quả (chuyển 15, 16); AwaitingResult thoát bằng hỏi lại, hết hạn hoặc thất bại (chuyển 18 đến 22). Guard không dùng kết quả của lời gọi ngoài chưa diễn ra: guard của chuyển 8 và 9 chỉ dùng phiên và tập ghế đang có; kết quả máy chủ là sự kiện holdGranted, holdRefused. ST-18: mọi trạng thái trung gian thoát ra bằng hẹn giờ hoặc stop().

## F7. Bảng thuộc tính

| DC | Visibility | Tên | Kiểu | Multiplicity | Mặc định | Ràng buộc | Phạm vi | Derived | Nguồn (AC / BR / ST / method) | Mô tả |
|---|---|---|---|---|---|---|---|---|---|---|
| DC-CustomerHomeView | - | menu | MenuItem[] | 1..* | - | {readOnly} | Instance | Không | P11a SCR-02 | Các thẻ điều hướng |
| DC-RegisterAccountView | - | fieldErrors | Map<string, string> | 0..* | rỗng | - | Instance | Không | REQ-107, REQ-108 | Lỗi định dạng từng ô |
| DC-RegisterAccountStore | - | status | LoadStatus | 1 | IDLE | - | Instance | Không | Bổ sung | Trạng thái tải, gửi |
| DC-RegisterAccountStore | - | refusal | Refusal  |  null | 0..1 | null | Instance | Không | - | P07 UC-001 // rejectRegistration |
| DC-RegisterAccountStore | - | registered | boolean | 1 | false | - | Instance | Không | P07 UC-001 // showRegistrationSuccess | Đã đăng ký thành công |
| DC-BrowseMoviesView | - | screen | "LIST"  |  "DETAILS" | 1 | LIST | Instance | Không | - | P11a SCR-23, SCR-24 |
| DC-BrowseMoviesStore | - | status | LoadStatus | 1 | IDLE | - | Instance | Không | Bổ sung | Trạng thái tải |
| DC-BrowseMoviesStore | - | nowShowing | MovieSummary[] | 0..* | [] | - | Instance | Không | P07 UC-003 | Phim đang chiếu |
| DC-BrowseMoviesStore | - | upcoming | MovieSummary[] | 0..* | [] | - | Instance | Không | P07 UC-003 | Phim sắp chiếu (kèm ngày khởi chiếu) |
| DC-BrowseMoviesStore | - | selected | MovieDetails  |  null | 0..1 | null | Instance | Không | - | P07 UC-003 selectedMovie |
| DC-BrowseShowtimesView | - | mode | BrowseMode | 1 | BY_MOVIE | - | Instance | Không | P07 UC-004 | Theo phim hoặc theo cụm rạp |
| DC-BrowseShowtimesStore | - | status | LoadStatus | 1 | IDLE | - | Instance | Không | Bổ sung | Trạng thái tải |
| DC-BrowseShowtimesStore | - | movieChoices | NameChoice[] | 0..* | [] | - | Instance | Không | P07 UC-004 | Phim để chọn |
| DC-BrowseShowtimesStore | - | cinemaChoices | NameChoice[] | 0..* | [] | - | Instance | Không | P07 UC-004 | Cụm rạp để chọn |
| DC-BrowseShowtimesStore | - | criteria | BrowseCriteria | 1 | rỗng | - | Instance | Không | P07 UC-004 browseCriteria | Tiêu chí hiện tại |
| DC-BrowseShowtimesStore | - | showtimes | ShowtimeRow[] | 0..* | [] | - | Instance | Không | P07 UC-004 // showShowtimes | Kết quả |
| DC-BrowseShowtimesStore | - | noShowtimes | boolean | 1 | false | - | Instance | Không | P07 UC-004 // notifyNoShowtimes | Không có suất phù hợp |
| DC-ViewBookingHistoryView | - | screen | "LIST"  |  "TICKETS" | 1 | LIST | Instance | Không | - | P11a SCR-26, SCR-27 |
| DC-ViewBookingHistoryStore | - | status | LoadStatus | 1 | IDLE | - | Instance | Không | Bổ sung | Trạng thái tải |
| DC-ViewBookingHistoryStore | - | bookings | BookingSummary[] | 0..* | [] | - | Instance | Không | P07 UC-007 | Các lần đặt |
| DC-ViewBookingHistoryStore | - | noBooking | boolean | 1 | false | - | Instance | Không | P07 UC-007 // showNoBooking | Chưa có lần đặt |
| DC-ViewBookingHistoryStore | - | tickets | TicketView[] | 0..* | [] | - | Instance | Không | P07 UC-007 // showBookingTickets | Vé của lần đặt đang xem |
| DC-ViewBookingHistoryStore | - | selectedBookingCode | string  |  null | 0..1 | null | Instance | Không | - | P07 UC-007 selectedBookingCode |
| DC-ViewBookingHistoryStore | - | refusal | Refusal  |  null | 0..1 | null | Instance | Không | - | P07 UC-007 // rejectBookingView |
| DC-CancelTicketView | - | confirming | TicketId  |  null | 0..1 | null | Instance | Không | - | P11a SCR-07 |
| DC-CancelTicketView | - | screen | "SELECT"  |  "RESULT" | 1 | SELECT | Instance | Không | - | P11a SCR-07, SCR-08 |
| DC-CancelTicketStore | - | status | LoadStatus | 1 | IDLE | - | Instance | Không | Bổ sung | Trạng thái tải, gửi |
| DC-CancelTicketStore | - | tickets | TicketView[] | 0..* | [] | - | Instance | Không | P07 UC-008 | Vé huỷ được |
| DC-CancelTicketStore | - | result | CancelResultView  |  null | 0..1 | null | Instance | Không | - | P07 UC-008 // showCancellationResult |
| DC-CancelTicketStore | - | refusal | Refusal  |  null | 0..1 | null | Instance | Không | - | P07 UC-008 // notifyRefusal |
| DC-BookTicketsView | - | screen | BookingScreen | 1 | SELECT_SHOWTIME | - | Instance | Không | P11a SCR-03 đến SCR-06 | Màn hình đang hiện |
| DC-HoldAndPayPage | - | confirmingCancel | boolean | 1 | false | - | Instance | Không | P11a SCR-05 | Hộp xác nhận huỷ đang mở |
| DC-BookTicketsStore | - | showtimes | ShowtimeRow[] | 0..* | [] | - | Instance | Không | P11a SCR-03 | Suất chiếu mở bán |
| DC-BookTicketsStore | - | paymentOutcome | PaymentOutcome  |  null | 0..1 | null | Instance | Không | - | P07 UC-005 // showPaymentOutcome |
| DC-BookTicketsStore | - | pollIntervalMs | number | 1 | 2000 | {readOnly} | Classifier | Không | Thiết kế: Q-334 | Chu kỳ hỏi lại trạng thái thanh toán |
| DC-BookTicketsStore | - | pollMaxMs | number | 1 | 30000 | {readOnly} | Classifier | Không | Thiết kế: Q-334 | Thời gian hỏi lại tối đa |
| DC-CounterHomeView | - | menu | MenuItem[] | 1..* | - | {readOnly} | Instance | Không | P11a SCR-09 | Các thẻ điều hướng |
| DC-CounterBookTicketsView | - | screen | CounterBookingScreen | 1 | SELECT_SEATS | - | Instance | Không | P11a SCR-10 đến SCR-12 | Màn hình đang hiện |
| DC-CounterHoldAndCashPage | - | submitting | boolean | 1 | false | - | Instance | Không | Thiết kế | Chặn bấm xác nhận hai lần |
| DC-CounterPrintTicketsPage | - | printFn | () => void | 1 | window.print | {readOnly} | Instance | Không | Thiết kế: tiêm để kiểm thử | Hàm in |
| DC-CounterBookTicketsStore | - | showtimes | ShowtimeRow[] | 0..* | [] | - | Instance | Không | P11a SCR-10 | Suất chiếu của cụm rạp |
| DC-CounterBookTicketsStore | - | soldTickets | SoldTickets  |  null | 0..1 | null | Instance | Không | - | P07 UC-005 // showTicketsForPrint |
| DC-CounterCancelTicketView | - | screen | "FIND"  |  "REFUND"  |  "RESULT" | 1 | Instance | Không | FIND | - |
| DC-CounterCancelTicketStore | - | status | LoadStatus | 1 | IDLE | - | Instance | Không | Bổ sung | Trạng thái tải, gửi |
| DC-CounterCancelTicketStore | - | bookingTickets | TicketView[] | 0..* | [] | - | Instance | Không | P07 UC-008 // showBookingTickets | Vé của lần đặt |
| DC-CounterCancelTicketStore | - | cashRefund | CounterCashRefundView  |  null | 0..1 | null | Instance | Không | - | P07 UC-008 // showCashRefund |
| DC-CounterCancelTicketStore | - | result | CancelResultView  |  null | 0..1 | null | Instance | Không | - | P07 UC-008 // showCancellationResult |
| DC-CounterCancelTicketStore | - | refusal | Refusal  |  null | 0..1 | null | Instance | Không | - | P07 UC-008 // notifyRefusal |
| DC-CheckTicketView | - | cameraActive | boolean | 1 | false | - | Instance | Không | P11a SCR-16 | Camera đang đọc |
| DC-CheckTicketStore | - | status | LoadStatus | 1 | IDLE | - | Instance | Không | Bổ sung | Trạng thái tải, gửi |
| DC-CheckTicketStore | - | showtimes | ShowtimeRow[] | 0..* | [] | - | Instance | Không | P11a SCR-16 | Suất chiếu để chọn |
| DC-CheckTicketStore | - | checkingShowtime | ShowtimeView  |  null | 0..1 | null | Instance | Không | - | P07 UC-009 checkingShowtime |
| DC-CheckTicketStore | - | lastResult | ScanOutcome  |  null | 0..1 | null | Instance | Không | - | P07 UC-009 // showValidTicket, // rejectTicket |
| DC-CheckTicketStore | - | lastScannedText | string  |  null | 0..1 | null | Instance | Không | - | Thiết kế |
| DC-CheckTicketStore | - | lastScannedAt | number | 1 | 0 | - | Instance | Không | Thiết kế | Mốc quét (ITicker) |
| DC-CheckTicketStore | - | duplicateWindowMs | number | 1 | 3000 | {readOnly} | Classifier | Không | Thiết kế: camera đọc nhiều khung cho một mã | Cửa sổ chặn quét trùng |
| DC-CinemaAdminHomeView | - | menu | MenuItem[] | 1..* | - | {readOnly} | Instance | Không | P11a SCR-17 | Các thẻ điều hướng |
| DC-ManagePriceListView | - | confirmingRemoval | PriceEntryKey  |  null | 0..1 | null | Instance | Không | - | P11a SCR-18 |
| DC-ManagePriceListStore | - | priceList | PriceListView | 1 | rỗng | - | Instance | Không | P07 UC-013 displayedPriceList | Bảng giá đang hiển thị |
| DC-ManagePriceListStore | - | lastSaved | PriceEntryView  |  null | 0..1 | null | Instance | Không | - | P07 UC-013 // showSavedPriceEntry |
| DC-ScheduleShowtimesView | - | confirmingDelete | ShowtimeId  |  null | 0..1 | null | Instance | Không | - | P11a SCR-19 |
| DC-ScheduleShowtimesStore | - | showtimes | ShowtimeRow[] | 0..* | [] | - | Instance | Không | P07 UC-014 // showShowtimes | Suất chiếu của cụm rạp |
| DC-ScheduleShowtimesStore | - | auditoriums | AuditoriumChoice[] | 0..* | [] | - | Instance | Không | P07 UC-014 // showAuditoriumsAndMovies | Phòng chiếu để chọn |
| DC-ScheduleShowtimesStore | - | movies | MovieChoice[] | 0..* | [] | - | Instance | Không | P07 UC-014 // showAuditoriumsAndMovies | Phim để chọn |
| DC-ScheduleShowtimesStore | - | form | ShowtimeFormState  |  null | 0..1 | null | Instance | Không | - | P07 UC-014 selectedShowtime |
| DC-ManageAuditoriumsView | - | confirmingRemoval | AuditoriumId  |  null | 0..1 | null | Instance | Không | - | P11a SCR-28 |
| DC-ManageAuditoriumsStore | - | auditoriums | AuditoriumRow[] | 0..* | [] | - | Instance | Không | P07 UC-012 displayedAuditoriumList | Phòng chiếu đang hiển thị |
| DC-ManageAuditoriumsStore | - | form | AuditoriumFormState  |  null | 0..1 | null | Instance | Không | - | P07 UC-012 selectedAuditorium |
| DC-ManageAuditoriumsStore | - | lastSaved | AuditoriumRow  |  null | 0..1 | null | Instance | Không | - | P07 UC-012 // showSavedAuditorium |
| DC-ViewCinemaReportView | - | request | ReportFormInput | 1 | - | - | Instance | Không | P07 UC-015 reportRequest | Cách xem, từ ngày, đến ngày đang nhập |
| DC-ViewCinemaReportStore | - | report | ReportView  |  null | 0..1 | null | Instance | Không | - | P07 UC-015 // showReport |
| DC-ChainAdminHomeView | - | menu | MenuItem[] | 1..* | - | {readOnly} | Instance | Không | P11a SCR-31 | Các thẻ điều hướng |
| DC-ManageMoviesStore | - | movies | MovieRow[] | 0..* | [] | - | Instance | Không | P07 UC-010 displayedMovieList | Phim đang hiển thị |
| DC-ManageMoviesStore | - | form | MovieFormState  |  null | 0..1 | null | Instance | Không | - | P07 UC-010 selectedMovie |
| DC-ManageMoviesStore | - | lastSaved | MovieRow  |  null | 0..1 | null | Instance | Không | - | P07 UC-010 // showSavedMovie |
| DC-ManageCinemasStore | - | cinemas | CinemaRow[] | 0..* | [] | - | Instance | Không | P07 UC-011 displayedCinemaList | Cụm rạp đang hiển thị |
| DC-ManageCinemasStore | - | form | CinemaFormState  |  null | 0..1 | null | Instance | Không | - | P07 UC-011 selectedCinema |
| DC-ManageCinemasStore | - | lastSaved | CinemaRow  |  null | 0..1 | null | Instance | Không | - | P07 UC-011 // showSavedCinema |
| DC-ViewChainReportView | - | request | ReportFormInput | 1 | - | - | Instance | Không | P07 UC-016 reportRequest | Cách xem, từ ngày, đến ngày đang nhập |
| DC-ViewChainReportStore | - | report | ChainReportView  |  null | 0..1 | null | Instance | Không | - | P07 UC-016 // showChainReport |
| DC-ManageStaffAccountsView | - | dialog | StaffDialogKind  |  null | 0..1 | null | Instance | Không | - | P11a SCR-38 đến SCR-40 |
| DC-ManageStaffAccountsStore | - | status | LoadStatus | 1 | IDLE | - | Instance | Không | Bổ sung | Trạng thái tải, gửi |
| DC-ManageStaffAccountsStore | - | staff | StaffRow[] | 0..* | [] | - | Instance | Không | P07 UC-017 // showStaffList | Tài khoản đang hiển thị |
| DC-ManageStaffAccountsStore | - | choices | StaffChoices  |  null | 0..1 | null | Instance | Không | - | P07 UC-017 // showStaffAccountChoices |
| DC-ManageStaffAccountsStore | - | selected | StaffRow  |  null | 0..1 | null | Instance | Không | - | P07 UC-017 selectedStaff |
| DC-ManageStaffAccountsStore | - | refusal | Refusal  |  null | 0..1 | null | Instance | Không | - | P07 UC-017 // rejectStaffAccount |
| DC-ManageStaffAccountsStore | - | notice | StaffNotice  |  null | 0..1 | null | Instance | Không | - | P07 UC-017 // notifyStaffChanged |
| DC-EmailOutboxJob | - | outbox | IOutboxStore | 1 | - | - | Instance | Không | Thiết kế: tiêm phụ thuộc | IF-23 |
| DC-EmailOutboxJob | - | uow | IUnitOfWork | 1 | - | - | Instance | Không | Thiết kế: tiêm phụ thuộc | IF-08 |
| DC-EmailOutboxJob | - | sender | IEmailSender | 1 | - | - | Instance | Không | Thiết kế: tiêm phụ thuộc | IF-03 |
| DC-EmailOutboxJob | - | qrEncoder | func(content string) ([]byte, error) | 1 | - | - | Instance | Không | Thiết kế: tiêm để kiểm thử | Sinh ảnh QR PNG từ mã vé |
| DC-EmailOutboxJob | - | retryDelays | []time.Duration | 3 | {1 phút, 5 phút, 15 phút} | {readOnly} | Classifier | Không | BR-89, P09 F7.7 | Độ trễ giữa các lần thử |
| DC-EmailOutboxJob | - | maxRetries | int | 1 | 3 | {readOnly} | Classifier | Không | BR-89 | Số lần thử lại sau lần gửi đầu |
| DC-EmailGatewayManager | - | builder | MimeMessageBuilder | 1 | - | - | Instance | Không | Thiết kế: tiêm phụ thuộc | Bộ dựng MIME |
| DC-EmailGatewayManager | - | client | SmtpClient | 1 | - | - | Instance | Không | Thiết kế: tiêm phụ thuộc | Máy khách SMTP |
| DC-MimeMessageBuilder | - | config | SmtpConfig | 1 | - | - | Instance | Không | Thiết kế: tiêm phụ thuộc | Miền của Message-ID và địa chỉ người gửi |
| DC-SmtpClient | - | config | SmtpConfig | 1 | - | - | Instance | Không | Thiết kế: tiêm phụ thuộc | Máy chủ, cổng, TLS, tài khoản |
| DC-SmtpClient | - | dialTimeout | time.Duration | 1 | 10 * time.Second | {readOnly} | Instance | Không | P11b IF-03 Timeout | Thời gian kết nối tối đa |
| DC-SmtpClient | - | totalTimeout | time.Duration | 1 | 30 * time.Second | {readOnly} | Instance | Không | P09 F7.7 | Thời gian cho cả thư |
| DC-SmtpConfig | - | host | string | 1 | - | - | Instance | Không | P11b SS-02 F5 | Máy chủ SMTP |
| DC-SmtpConfig | - | port | int | 1 | - | {1..65535} | Instance | Không | P11b SS-02 F5 | Cổng |
| DC-SmtpConfig | - | tlsMode | TlsMode | 1 | STARTTLS | - | Instance | Không | P11b SS-02 F5 | Chế độ TLS |
| DC-SmtpConfig | - | username | string | 1 | - | - | Instance | Không | P11b SS-02 F5 | Tài khoản |
| DC-SmtpConfig | - | password | string | 1 | - | {không log} | Instance | Không | P11b SS-02 F5 | Mật khẩu |
| DC-SmtpConfig | - | senderAddress | string | 1 | - | - | Instance | Không | P11b SS-02 F5 | Địa chỉ người gửi |
| DC-SmtpConfig | - | messageIdDomain | string | 1 | - | - | Instance | Không | P11b SS-02 F5 | Miền của Message-ID |
| DC-SeatMapSyncClient | - | showtimeId | ShowtimeId  |  null | 0..1 | null | Instance | Không | - | P09 F7.5 |
| DC-SeatMapSyncClient | - | map | SeatMapGrid | 1 | rỗng | - | Instance | Không | P09 F7.5 | Sơ đồ hiện tại (State của StoreBase) |
| DC-SeatMapSyncClient | - | connection | ConnectionState | 1 | CLOSED | - | Instance | Không | ST-18 | Trạng thái kết nối |
| DC-SeatMapSyncClient | - | lastFrameAt | number | 1 | 0 | - | Instance | Không | P09 F7.5 | Mốc nhận khung cuối (ms, theo ITicker) |
| DC-SeatMapSyncClient | - | retryCount | number | 1 | 0 | {>= 0} | Instance | Không | Thiết kế | Số lần nối lại liên tiếp để tính độ lùi |
| DC-SeatMapSyncClient | - | livenessTimeoutMs | number | 1 | 20000 | {readOnly} | Classifier | Không | P09 F7.5 | Quá hạn không nhận khung thì coi kết nối chết |
| DC-SeatMapSyncClient | - | snapshotRefreshMs | number | 1 | 60000 | {readOnly} | Classifier | Không | P09 F7.5 | Chu kỳ làm mới ảnh chụp |
| DC-SeatMapSyncClient | - | reloadJitterMs | number | 1 | 3000 | {readOnly} | Classifier | Không | P09 F7.5 điểm 6 | Độ trễ ngẫu nhiên tối đa trước khi tải lại |
| DC-HoldCountdown | - | expiryTime | number | 1 | 0 | - | Instance | Không | P11a UI-STT 43 | Thời điểm hết hạn của máy chủ (ms epoch) |
| DC-HoldCountdown | - | clockOffsetMs | number | 1 | 0 | - | Instance | Không | P11a UI-STT 43 | Giờ máy chủ trừ giờ máy khách lúc nhận phản hồi |
| DC-HoldCountdown | - | remaining | number | 1 | 0 | {>= 0} | Instance | Không | Bổ sung | Giây còn lại (State) |
| DC-HoldCountdown | - | announced | Set<number> | 1 | rỗng | - | Instance | Không | Thiết kế | Mốc đã báo cho trình đọc màn hình |
| DC-HoldCountdown | - | expiredFired | boolean | 1 | false | - | Instance | Không | Thiết kế | Bảo đảm onExpired gọi một lần |
| DC-HoldFlowStore | - | phase | BookingPhase | 1 | NO_SHOWTIME | ST-17 | Instance | Không | ST-17 | Trạng thái luồng đặt chỗ |
| DC-HoldFlowStore | - | endReason | EndReason  |  null | 0..1 | null | Instance | Không | {chỉ có khi phase = ENDED} | ST-17 |
| DC-HoldFlowStore | - | showtime | ShowtimeView  |  null | 0..1 | null | Instance | Không | - | P07 UC-005 // showSeatMap |
| DC-HoldFlowStore | - | selectedSeatIds | SeatId[] | 0..* | [] | {không trùng} | Instance | Không | P07 UC-005 selectedSeats | Các ghế đang chọn |
| DC-HoldFlowStore | - | hold | HoldView  |  null | 0..1 | null | Instance | Không | - | P07 UC-005 // showHeldSeats |
| DC-HoldFlowStore | - | refusal | Refusal  |  null | 0..1 | null | Instance | Không | - | P07 UC-005 // notifyRefusal |
| DC-HoldFlowStore | - | conflictSeatIds | SeatId[] | 0..* | [] | - | Instance | Không | MSG-11 | Ghế vừa bị lấy |
| DC-HoldFlowStore | - | needsLogin | boolean | 1 | false | - | Instance | Không | P07 UC-005 // requestLogin | Cần mở pop-up đăng nhập |
| DC-HoldFlowStore | - | requestId | string | 1 | - | {UUID} | Instance | Không | BR-85, SY-14 | Mã chống lặp của lần giữ ghế đang thử; lưu sessionStorage tới khi có kết quả (Q-333) |
| DC-FetchApiClient | - | routeTable | ReadonlyMap<string, RouteSpec> | 1 | - | {readOnly} | Instance | Không | Q-332 | Tuyến logic sang phương thức và đường dẫn |
| DC-FetchApiClient | - | timeoutMs | number | 1 | 15000 | {> 0} | Instance | Không | Thiết kế: thời gian chờ mỗi yêu cầu REST (NFR-06 giữ ghế p95 2 giây, dư cho mạng di động) | Hết thời gian thì ném NetworkError |
| DC-FetchApiClient | - | fetchFn | typeof fetch | 1 | fetch | {readOnly} | Instance | Không | Thiết kế: tiêm để kiểm thử | Hàm gửi thật |
| DC-StoreBase | - | state | S | 1 | - | - | Instance | Không | Bổ sung | Trạng thái hiện tại |
| DC-StoreBase | - | listeners | Set<() => void> | 1 | rỗng | - | Instance | Không | Bổ sung | Người đăng ký |
| DC-RequestStoreBase | - | status | LoadStatus | 1 | IDLE | - | Instance | Không | Bổ sung | Trạng thái tải, gửi |
| DC-RequestStoreBase | - | refusal | Refusal | null | 0..1 | null | Instance | Không | - | Lý do từ chối của yêu cầu gần nhất |
| DC-RequestStoreBase | - | requestSeq | number | 1 | 0 | {>= 0} | Instance | Không | Thiết kế | Đánh số yêu cầu để bỏ kết quả của yêu cầu cũ |
| DC-ReportStoreBase | - | notice | ReportNotice | null | 0..1 | null | Instance | Không | - | Thông báo kỳ không hợp lệ hoặc không có suất chiếu |
| DC-SessionStore | - | session | SessionInfo  |  null | 0..1 | null | Instance | Không | - | P09 F7.11 |
| DC-SessionStore | - | expiredReason | ExpireReason  |  null | 0..1 | null | Instance | Không | - | MSG-85 |
| DC-SessionStore | - | storageKey | string | 1 | "cinebook.session" | {readOnly} | Classifier | Không | Thiết kế | Khoá sessionStorage |
| DC-LoginView | - | kind | AccountKind | 1 | CUSTOMER | - | Instance | Không | Q-267 | Loại tài khoản đang đăng nhập |
| DC-LoginView | - | mode | LoginMode | 1 | PAGE | - | Instance | Không | P11a E-14 | PAGE hoặc POPUP |
| DC-LoginView | - | refusal | Refusal  |  null | 0..1 | null | Instance | Không | - | P07 UC-005 // provideCredentials |
| DC-LoginView | - | submitting | boolean | 1 | false | - | Instance | Không | Thiết kế | Chặn bấm đăng nhập hai lần |

Giá trị ở cột Mặc định ghi "-" là không có giá trị mặc định. Thuộc tính trạng thái (phase, connection) là enumeration theo ST-17, ST-18. Thuộc tính trỏ tới lớp khác (View --> Store, Store --> IF-41) đã có association ở F5 và không lặp ở đây, trừ trường hợp tiêm phụ thuộc của lớp Go ghi tên field để dễ đối chiếu.

## F8. Class diagram

| Sơ đồ | Phạm vi (PKG / UC) | File .drawio | Số lớp |
|---|---|---|---|
| PKG-05 CustomerWeb | PKG-05 | P12-class-PKG-05.drawio | 17 (chi tiết) + 3 tham chiếu |
| PKG-06 CounterWeb, PKG-07 CheckInWeb | PKG-06, PKG-07 | P12-class-PKG-06-PKG-07.drawio | 10 (chi tiết) + 2 tham chiếu |
| PKG-08 CinemaAdminWeb, PKG-09 ChainAdminWeb, PKG-10 AccountAdminWeb | PKG-08, PKG-09, PKG-10 | P12-class-PKG-08-PKG-09-PKG-10.drawio | 18 (chi tiết) + 1 tham chiếu |
| PKG-29 SeatMapClient, PKG-31 SessionClient | PKG-29, PKG-31 | P12-class-PKG-29-PKG-31.drawio | 13 (chi tiết) + 0 tham chiếu |
| PKG-20 Notification, PKG-23 EmailGatewayClient (SS-02) | PKG-20, PKG-23 | P12-class-PKG-20-PKG-23.drawio | 8 (chi tiết) + 8 tham chiếu |
| Luồng đặt chỗ | DC-HoldFlowStore (ST-17) | P12-state-DC-HoldFlowStore.drawio | 1 |
| Kết nối đồng bộ sơ đồ ghế | DC-SeatMapSyncClient (ST-18) | P12-state-DC-SeatMapSyncClient.drawio | 1 |

Nội dung ngăn thuộc tính và ngăn operation lấy đúng từ F7, F2. Lớp ngoài package chỉ ghi tên kèm mã package ("tham chiếu"). Dependency Form --> Controller của PKG-11, PKG-12 (R-01 đến R-101) liệt kê ở F5, không vẽ để sơ đồ không có hàng chục cạnh; dependency tới interface kho Go ở sơ đồ PKG-20, PKG-23 vẽ vì chỉ có tám interface.

### P12-class-PKG-05

| ID | Loại | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| DC-StoreBase | Class | StoreBase<S> (PKG-31) | «control» | PKG-31 | tham chiếu |
| DC-HoldFlowStore | Class | HoldFlowStore (PKG-29) | «control» | PKG-29 | tham chiếu |
| DC-LoginView | Class | LoginView (PKG-31) | «boundary» | PKG-31 | tham chiếu |
| DC-BookTicketsStore | Class | BookTicketsStore | «control» | PKG-05 | chi tiết |
| DC-RegisterAccountStore | Class | RegisterAccountStore | «control» | PKG-05 | chi tiết |
| DC-BrowseMoviesStore | Class | BrowseMoviesStore | «control» | PKG-05 | chi tiết |
| DC-BrowseShowtimesStore | Class | BrowseShowtimesStore | «control» | PKG-05 | chi tiết |
| DC-ViewBookingHistoryStore | Class | ViewBookingHistoryStore | «control» | PKG-05 | chi tiết |
| DC-CancelTicketStore | Class | CancelTicketStore | «control» | PKG-05 | chi tiết |
| DC-BookTicketsView | Class | BookTicketsView | «boundary» | PKG-05 | chi tiết |
| DC-CustomerHomeView | Class | CustomerHomeView | «boundary» | PKG-05 | chi tiết |
| DC-RegisterAccountView | Class | RegisterAccountView | «boundary» | PKG-05 | chi tiết |
| DC-BrowseMoviesView | Class | BrowseMoviesView | «boundary» | PKG-05 | chi tiết |
| DC-BrowseShowtimesView | Class | BrowseShowtimesView | «boundary» | PKG-05 | chi tiết |
| DC-ViewBookingHistoryView | Class | ViewBookingHistoryView | «boundary» | PKG-05 | chi tiết |
| DC-CancelTicketView | Class | CancelTicketView | «boundary» | PKG-05 | chi tiết |
| DC-SelectShowtimePage | Class | SelectShowtimePage | «boundary» | PKG-05 | chi tiết |
| DC-SelectSeatsPage | Class | SelectSeatsPage | «boundary» | PKG-05 | chi tiết |
| DC-HoldAndPayPage | Class | HoldAndPayPage | «boundary» | PKG-05 | chi tiết |
| DC-BookingResultPage | Class | BookingResultPage | «boundary» | PKG-05 | chi tiết |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| R-330.1 | DC-RegisterAccountStore | DC-StoreBase | Generalization | - | R-330 |
| R-330.2 | DC-BrowseMoviesStore | DC-StoreBase | Generalization | - | R-330 |
| R-330.3 | DC-BrowseShowtimesStore | DC-StoreBase | Generalization | - | R-330 |
| R-330.4 | DC-ViewBookingHistoryStore | DC-StoreBase | Generalization | - | R-330 |
| R-330.5 | DC-CancelTicketStore | DC-StoreBase | Generalization | - | R-330 |
| R-330.19 | DC-HoldFlowStore | DC-StoreBase | Generalization | - | R-330 |
| R-331.1 | DC-BookTicketsStore | DC-HoldFlowStore | Generalization | - | R-331 |
| R-337.1 | DC-RegisterAccountView | DC-RegisterAccountStore | Association | A 1 - B 1 | R-337 |
| R-337.2 | DC-BrowseMoviesView | DC-BrowseMoviesStore | Association | A 1 - B 1 | R-337 |
| R-337.3 | DC-BrowseShowtimesView | DC-BrowseShowtimesStore | Association | A 1 - B 1 | R-337 |
| R-337.4 | DC-ViewBookingHistoryView | DC-ViewBookingHistoryStore | Association | A 1 - B 1 | R-337 |
| R-337.5 | DC-CancelTicketView | DC-CancelTicketStore | Association | A 1 - B 1 | R-337 |
| R-338.1 | DC-BookTicketsView | DC-BookTicketsStore | Association | A 0..* - B 1 | R-338 |
| R-338.2 | DC-CustomerHomeView | DC-BookTicketsStore | Association | A 0..* - B 1 | R-338 |
| R-339.1 | DC-BookTicketsView | DC-SelectShowtimePage | Composition | A 1 - B 1 | R-339 |
| R-339.2 | DC-BookTicketsView | DC-SelectSeatsPage | Composition | A 1 - B 1 | R-339 |
| R-339.3 | DC-BookTicketsView | DC-HoldAndPayPage | Composition | A 1 - B 1 | R-339 |
| R-339.4 | DC-BookTicketsView | DC-BookingResultPage | Composition | A 1 - B 1 | R-339 |
| R-340.1 | DC-SelectShowtimePage | DC-BookTicketsStore | Dependency | - | R-340 |
| R-340.2 | DC-SelectSeatsPage | DC-BookTicketsStore | Dependency | - | R-340 |
| R-340.3 | DC-HoldAndPayPage | DC-BookTicketsStore | Dependency | - | R-340 |
| R-340.4 | DC-BookingResultPage | DC-BookTicketsStore | Dependency | - | R-340 |
| R-356 | DC-BookTicketsView | DC-LoginView | Dependency | - | R-356 |

### P12-class-PKG-06-PKG-07

| ID | Loại | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| DC-StoreBase | Class | StoreBase<S> (PKG-31) | «control» | PKG-31 | tham chiếu |
| DC-HoldFlowStore | Class | HoldFlowStore (PKG-29) | «control» | PKG-29 | tham chiếu |
| DC-CounterBookTicketsStore | Class | CounterBookTicketsStore | «control» | PKG-06 | chi tiết |
| DC-CounterCancelTicketStore | Class | CounterCancelTicketStore | «control» | PKG-06 | chi tiết |
| DC-CheckTicketStore | Class | CheckTicketStore | «control» | PKG-07 | chi tiết |
| DC-CounterBookTicketsView | Class | CounterBookTicketsView | «boundary» | PKG-06 | chi tiết |
| DC-CounterHomeView | Class | CounterHomeView | «boundary» | PKG-06 | chi tiết |
| DC-CounterCancelTicketView | Class | CounterCancelTicketView | «boundary» | PKG-06 | chi tiết |
| DC-CheckTicketView | Class | CheckTicketView | «boundary» | PKG-07 | chi tiết |
| DC-CounterSelectSeatsPage | Class | CounterSelectSeatsPage | «boundary» | PKG-06 | chi tiết |
| DC-CounterHoldAndCashPage | Class | CounterHoldAndCashPage | «boundary» | PKG-06 | chi tiết |
| DC-CounterPrintTicketsPage | Class | CounterPrintTicketsPage | «boundary» | PKG-06 | chi tiết |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| R-330.6 | DC-CounterCancelTicketStore | DC-StoreBase | Generalization | - | R-330 |
| R-330.7 | DC-CheckTicketStore | DC-StoreBase | Generalization | - | R-330 |
| R-330.19 | DC-HoldFlowStore | DC-StoreBase | Generalization | - | R-330 |
| R-331.2 | DC-CounterBookTicketsStore | DC-HoldFlowStore | Generalization | - | R-331 |
| R-341.1 | DC-CounterHomeView | DC-CounterBookTicketsStore | Association | A 0..* - B 1 | R-341 |
| R-341.2 | DC-CounterBookTicketsView | DC-CounterBookTicketsStore | Association | A 0..* - B 1 | R-341 |
| R-341.3 | DC-CounterCancelTicketView | DC-CounterCancelTicketStore | Association | A 0..* - B 1 | R-341 |
| R-342.1 | DC-CounterBookTicketsView | DC-CounterSelectSeatsPage | Composition | A 1 - B 1 | R-342 |
| R-342.2 | DC-CounterBookTicketsView | DC-CounterHoldAndCashPage | Composition | A 1 - B 1 | R-342 |
| R-342.3 | DC-CounterBookTicketsView | DC-CounterPrintTicketsPage | Composition | A 1 - B 1 | R-342 |
| R-343.1 | DC-CounterSelectSeatsPage | DC-CounterBookTicketsStore | Dependency | - | R-343 |
| R-343.2 | DC-CounterHoldAndCashPage | DC-CounterBookTicketsStore | Dependency | - | R-343 |
| R-343.3 | DC-CounterPrintTicketsPage | DC-CounterBookTicketsStore | Dependency | - | R-343 |
| R-344 | DC-CheckTicketView | DC-CheckTicketStore | Association | A 1 - B 1 | R-344 |

### P12-class-PKG-08-PKG-09-PKG-10

| ID | Loại | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| DC-StoreBase | Class | StoreBase<S> (PKG-31) | «control» | PKG-31 | tham chiếu |
| DC-RequestStoreBase | Class | RequestStoreBase<S> (PKG-31) | «control» | PKG-31 | tham chiếu |
| DC-ManagedListStore | Class | ManagedListStore<S> (PKG-31) | «control» | PKG-31 | tham chiếu |
| DC-ReportStoreBase | Class | ReportStoreBase<S> (PKG-31) | «control» | PKG-31 | tham chiếu |
| DC-ManagePriceListStore | Class | ManagePriceListStore | «control» | PKG-08 | chi tiết |
| DC-ScheduleShowtimesStore | Class | ScheduleShowtimesStore | «control» | PKG-08 | chi tiết |
| DC-ManageAuditoriumsStore | Class | ManageAuditoriumsStore | «control» | PKG-08 | chi tiết |
| DC-ViewCinemaReportStore | Class | ViewCinemaReportStore | «control» | PKG-08 | chi tiết |
| DC-ManageMoviesStore | Class | ManageMoviesStore | «control» | PKG-09 | chi tiết |
| DC-ManageCinemasStore | Class | ManageCinemasStore | «control» | PKG-09 | chi tiết |
| DC-ViewChainReportStore | Class | ViewChainReportStore | «control» | PKG-09 | chi tiết |
| DC-ManageStaffAccountsStore | Class | ManageStaffAccountsStore | «control» | PKG-10 | chi tiết |
| DC-ManagePriceListView | Class | ManagePriceListView | «boundary» | PKG-08 | chi tiết |
| DC-ScheduleShowtimesView | Class | ScheduleShowtimesView | «boundary» | PKG-08 | chi tiết |
| DC-ManageAuditoriumsView | Class | ManageAuditoriumsView | «boundary» | PKG-08 | chi tiết |
| DC-ViewCinemaReportView | Class | ViewCinemaReportView | «boundary» | PKG-08 | chi tiết |
| DC-ManageMoviesView | Class | ManageMoviesView | «boundary» | PKG-09 | chi tiết |
| DC-ManageCinemasView | Class | ManageCinemasView | «boundary» | PKG-09 | chi tiết |
| DC-ViewChainReportView | Class | ViewChainReportView | «boundary» | PKG-09 | chi tiết |
| DC-ManageStaffAccountsView | Class | ManageStaffAccountsView | «boundary» | PKG-10 | chi tiết |
| DC-CinemaAdminHomeView | Class | CinemaAdminHomeView | «boundary» | PKG-08 | chi tiết |
| DC-ChainAdminHomeView | Class | ChainAdminHomeView | «boundary» | PKG-09 | chi tiết |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| R-330.15 | DC-ManageStaffAccountsStore | DC-StoreBase | Generalization | - | R-330 |
| R-498 | DC-ManagePriceListStore | DC-ManagedListStore | Generalization | - | R-498 |
| R-499 | DC-ScheduleShowtimesStore | DC-ManagedListStore | Generalization | - | R-499 |
| R-500 | DC-ManageAuditoriumsStore | DC-ManagedListStore | Generalization | - | R-500 |
| R-501 | DC-ManageMoviesStore | DC-ManagedListStore | Generalization | - | R-501 |
| R-502 | DC-ManageCinemasStore | DC-ManagedListStore | Generalization | - | R-502 |
| R-503 | DC-ViewCinemaReportStore | DC-ReportStoreBase | Generalization | - | R-503 |
| R-504 | DC-ViewChainReportStore | DC-ReportStoreBase | Generalization | - | R-504 |
| R-505 | DC-ManagedListStore | DC-RequestStoreBase | Generalization | - | R-505 |
| R-506 | DC-ReportStoreBase | DC-RequestStoreBase | Generalization | - | R-506 |
| R-507 | DC-RequestStoreBase | DC-StoreBase | Generalization | - | R-507 |
| R-345.1 | DC-ManagePriceListView | DC-ManagePriceListStore | Association | A 1 - B 1 | R-345 |
| R-345.2 | DC-ScheduleShowtimesView | DC-ScheduleShowtimesStore | Association | A 1 - B 1 | R-345 |
| R-345.3 | DC-ManageAuditoriumsView | DC-ManageAuditoriumsStore | Association | A 1 - B 1 | R-345 |
| R-345.4 | DC-ViewCinemaReportView | DC-ViewCinemaReportStore | Association | A 1 - B 1 | R-345 |
| R-346.1 | DC-ManageMoviesView | DC-ManageMoviesStore | Association | A 1 - B 1 | R-346 |
| R-346.2 | DC-ManageCinemasView | DC-ManageCinemasStore | Association | A 1 - B 1 | R-346 |
| R-346.3 | DC-ViewChainReportView | DC-ViewChainReportStore | Association | A 1 - B 1 | R-346 |
| R-347 | DC-ManageStaffAccountsView | DC-ManageStaffAccountsStore | Association | A 1 - B 1 | R-347 |

### P12-class-PKG-29-PKG-31

| ID | Loại | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| DC-StoreBase | Class | StoreBase<S> | «control» | PKG-31 | chi tiết |
| DC-HoldFlowStore | Class | HoldFlowStore | «control» | PKG-29 | chi tiết |
| DC-HoldCountdown | Class | HoldCountdown | «control» | PKG-29 | chi tiết |
| DC-SeatMapSyncClient | Class | SeatMapSyncClient | «control» | PKG-29 | chi tiết |
| IF-43 | Interface | ITicker | «interface» | PKG-31 | chi tiết |
| IF-41 | Interface | IApiClient | «interface» | PKG-31 | chi tiết |
| IF-42 | Interface | IEventSourceFactory | «interface» | PKG-29 | chi tiết |
| DC-SeatMapReducer | Class | SeatMapReducer | «control» | PKG-29 | chi tiết |
| DC-BrowserTicker | Class | BrowserTicker | «utility» | PKG-31 | chi tiết |
| DC-FetchApiClient | Class | FetchApiClient | «service» | PKG-31 | chi tiết |
| DC-BrowserEventSourceFactory | Class | BrowserEventSourceFactory | «utility» | PKG-29 | chi tiết |
| DC-SessionStore | Class | SessionStore | «control» | PKG-31 | chi tiết |
| IF-48 | Interface | ISessionSource | «interface» | PKG-31 | chi tiết |
| DC-LoginView | Class | LoginView | «boundary» | PKG-31 | chi tiết |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| R-330.16 | DC-SessionStore | DC-StoreBase | Generalization | - | R-330 |
| R-330.17 | DC-SeatMapSyncClient | DC-StoreBase | Generalization | - | R-330 |
| R-330.18 | DC-HoldCountdown | DC-StoreBase | Generalization | - | R-330 |
| R-330.19 | DC-HoldFlowStore | DC-StoreBase | Generalization | - | R-330 |
| R-332 | DC-FetchApiClient | IF-41 | Realization | - | R-332 |
| R-333 | DC-BrowserTicker | IF-43 | Realization | - | R-333 |
| R-334 | DC-BrowserEventSourceFactory | IF-42 | Realization | - | R-334 |
| R-348.1 | DC-HoldFlowStore | IF-41 | Association | A 0..* - B 1 | R-348 |
| R-348.2 | DC-SeatMapSyncClient | IF-41 | Association | A 0..* - B 1 | R-348 |
| R-348.3 | DC-SessionStore | IF-41 | Association | A 0..* - B 1 | R-348 |
| R-349 | DC-HoldFlowStore | DC-SeatMapSyncClient | Association | A 1 - B 1 | R-349 |
| R-350 | DC-HoldFlowStore | DC-HoldCountdown | Association | A 1 - B 1 | R-350 |
| R-351 | DC-SeatMapSyncClient | IF-42 | Association | A 0..* - B 1 | R-351 |
| R-352 | DC-SeatMapSyncClient | DC-SeatMapReducer | Association | A 0..* - B 1 | R-352 |
| R-353.1 | DC-SeatMapSyncClient | IF-43 | Association | A 0..* - B 1 | R-353 |
| R-353.2 | DC-HoldCountdown | IF-43 | Association | A 0..* - B 1 | R-353 |
| R-508 | DC-FetchApiClient | IF-48 | Association | A 0..* - B 1 | R-508 |
| R-509 | DC-SessionStore | IF-48 | Realization |  | R-509 |
| R-355 | DC-LoginView | DC-SessionStore | Association | A 0..* - B 1 | R-355 |
| R-365 | DC-HoldFlowStore | DC-SessionStore | Association | A 0..* - B 1 | R-365 |

### P12-class-PKG-20-PKG-23

| ID | Loại | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| IF-06 | Interface | IScheduledJob (PKG-25) | «interface» | PKG-25 | tham chiếu |
| IF-23 | Interface | IOutboxStore (PKG-28) | «interface» | PKG-28 | tham chiếu |
| IF-08 | Interface | IUnitOfWork (PKG-27) | «interface» | PKG-27 | tham chiếu |
| IF-20 | Interface | IBookingRepository (PKG-28) | «interface» | PKG-28 | tham chiếu |
| IF-19 | Interface | IPaymentTransactionRepository (PKG-28) | «interface» | PKG-28 | tham chiếu |
| IF-21 | Interface | IRefundRequestRepository (PKG-28) | «interface» | PKG-28 | tham chiếu |
| IF-11 | Interface | IShowtimeRepository (PKG-27) | «interface» | PKG-27 | tham chiếu |
| IF-16 | Interface | IHolderRepository (PKG-28) | «interface» | PKG-28 | tham chiếu |
| DC-EmailOutboxJob | Class | EmailOutboxJob | «service» | PKG-20 | chi tiết |
| IF-03 | Interface | IEmailSender | «interface» | PKG-23 | chi tiết |
| DC-EmailGatewayManager | Class | EmailGatewayManager | «service» | PKG-23 | chi tiết |
| DC-MimeMessageBuilder | Class | MimeMessageBuilder | «utility» | PKG-23 | chi tiết |
| DC-SmtpClient | Class | SmtpClient | «service» | PKG-23 | chi tiết |
| DC-SmtpConfig | Class | SmtpConfig | «utility» | PKG-23 | chi tiết |
| DC-EmailMessage | Class | EmailMessage | «value object» | PKG-23 | chi tiết |
| DC-EmailAttachment | Class | EmailAttachment | «value object» | PKG-23 | chi tiết |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| R-335 | DC-EmailOutboxJob | IF-06 | Realization | - | R-335 |
| R-336 | DC-EmailGatewayManager | IF-03 | Realization | - | R-336 |
| R-357 | DC-EmailOutboxJob | IF-23 | Association | A 0..* - B 1 | R-357 |
| R-358 | DC-EmailOutboxJob | IF-08 | Association | A 0..* - B 1 | R-358 |
| R-359 | DC-EmailOutboxJob | IF-03 | Association | A 0..* - B 1 | R-359 |
| R-360.1 | DC-EmailOutboxJob | IF-20 | Association | A 0..* - B 1 | R-360 |
| R-360.2 | DC-EmailOutboxJob | IF-19 | Association | A 0..* - B 1 | R-360 |
| R-360.3 | DC-EmailOutboxJob | IF-21 | Association | A 0..* - B 1 | R-360 |
| R-360.4 | DC-EmailOutboxJob | IF-11 | Association | A 0..* - B 1 | R-360 |
| R-360.5 | DC-EmailOutboxJob | IF-16 | Association | A 0..* - B 1 | R-360 |
| R-361 | DC-EmailGatewayManager | DC-MimeMessageBuilder | Association | A 0..* - B 1 | R-361 |
| R-362 | DC-EmailGatewayManager | DC-SmtpClient | Association | A 0..* - B 1 | R-362 |
| R-363.1 | DC-SmtpClient | DC-SmtpConfig | Association | A 0..* - B 1 | R-363 |
| R-363.2 | DC-MimeMessageBuilder | DC-SmtpConfig | Association | A 0..* - B 1 | R-363 |
| R-364 | DC-EmailMessage | DC-EmailAttachment | Composition | A 1 - B 0..* | R-364 |

### Sơ đồ trạng thái

Bảng Node và Edge của ST-17, ST-18 ở F6.4.

## F9. Gán package và kiểm tra phụ thuộc package

| PKG | Lớp (DC) | Phụ thuộc vào PKG (suy từ F5) | Hợp lệ theo P09 (Có / Không: lý do) |
|---|---|---|---|
| PKG-05 | DC-CustomerHomeView, DC-RegisterAccountView, DC-RegisterAccountStore, DC-BrowseMoviesView, DC-BrowseMoviesStore, DC-BrowseShowtimesView, DC-BrowseShowtimesStore, DC-ViewBookingHistoryView, DC-ViewBookingHistoryStore, DC-CancelTicketView, DC-CancelTicketStore, DC-BookTicketsView, DC-SelectShowtimePage, DC-SelectSeatsPage, DC-HoldAndPayPage, DC-BookingResultPage, DC-BookTicketsStore | PKG-29, PKG-31 | Có: PKG-29, PKG-31 theo P10 F4 |
| PKG-06 | DC-CounterHomeView, DC-CounterBookTicketsView, DC-CounterSelectSeatsPage, DC-CounterHoldAndCashPage, DC-CounterPrintTicketsPage, DC-CounterBookTicketsStore, DC-CounterCancelTicketView, DC-CounterCancelTicketStore | PKG-29, PKG-31 | Có: PKG-29, PKG-31 theo P10 F4 |
| PKG-07 | DC-CheckTicketView, DC-CheckTicketStore | PKG-31 | Có: PKG-31 theo P10 F4 |
| PKG-08 | DC-CinemaAdminHomeView, DC-ManagePriceListView, DC-ManagePriceListStore, DC-ScheduleShowtimesView, DC-ScheduleShowtimesStore, DC-ManageAuditoriumsView, DC-ManageAuditoriumsStore, DC-ViewCinemaReportView, DC-ViewCinemaReportStore | PKG-31 | Có: PKG-31 theo P10 F4 |
| PKG-09 | DC-ChainAdminHomeView, DC-ManageMoviesView, DC-ManageMoviesStore, DC-ManageCinemasView, DC-ManageCinemasStore, DC-ViewChainReportView, DC-ViewChainReportStore | PKG-31 | Có: PKG-31 theo P10 F4 |
| PKG-10 | DC-ManageStaffAccountsView, DC-ManageStaffAccountsStore | PKG-31 | Có: PKG-31 theo P10 F4 |
| PKG-20 | DC-EmailOutboxJob | PKG-23, PKG-25, PKG-27, PKG-28 | Có: PKG-23, PKG-25, PKG-27, PKG-28 theo P10 F4 (IF-23 ở PKG-28 từ X3 lần 6, IF-06 ở PKG-25, IF-08 và IF-11 ở PKG-27, IF-16, IF-19 đến IF-21 ở PKG-28) |
| PKG-23 | IF-03, DC-EmailGatewayManager, DC-MimeMessageBuilder, DC-SmtpClient, DC-SmtpConfig | - | Có: không phụ thuộc package khác |
| PKG-29 | IF-42, DC-BrowserEventSourceFactory, DC-SeatMapReducer, DC-SeatMapSyncClient, DC-HoldCountdown, DC-HoldFlowStore | PKG-31 | Không theo P10 F4 (PKG-29 ghi "-"): DC-HoldFlowStore kế thừa DC-StoreBase và dùng IF-41, DC-SessionStore của PKG-31. Phụ thuộc cùng layer, một chiều (PKG-31 không phụ thuộc PKG-29), không vòng; Đề xuất sửa P10 F4, F6: thêm cạnh PKG-29 --> PKG-31 |
| PKG-31 | IF-41, IF-43, IF-48, DC-BrowserTicker, DC-FetchApiClient, DC-StoreBase, DC-RequestStoreBase, DC-ManagedListStore, DC-ReportStoreBase, DC-SessionStore, DC-LoginView | - | Có: không phụ thuộc package khác; không còn vòng lớp giữa DC-FetchApiClient và DC-SessionStore (DC-FetchApiClient chỉ phụ thuộc IF-48, R-508, R-509) |

Kiểm tra gán package: boundary của hai tác nhân khác nhau không cùng package (PKG-05 khách, PKG-06 quầy, PKG-07 soát vé, PKG-08 quản lý cụm rạp, PKG-09 quản lý chuỗi, PKG-10 quản trị viên); phần dùng chung hai tác nhân (DC-HoldFlowStore, DC-HoldCountdown, đồng bộ sơ đồ ghế) ở PKG-29 và phần dùng chung mọi tác nhân (phiên, IF-41, DC-StoreBase, DC-LoginView) ở PKG-31, theo A3. PKG-05 có 17 phần tử có hành vi và PKG-29 có 6, PKG-31 có 7: PKG-05 vượt khoảng 15 do tách thêm bốn component trang (P11a Đề xuất); giữ vì các trang chỉ tồn tại trong một vỏ (composition R-339) và cùng đổi theo UC-005 (CCP). Không có phụ thuộc vòng giữa package, không phụ thuộc ngược layer; PKG-05 đến PKG-10 đứng cùng layer Presentation với PKG-29, PKG-31. Phụ thuộc Form --> Controller (R-01 đến R-101) là lời gọi HTTP giữa trình duyệt và máy chủ, không tính là phụ thuộc package của mã nguồn.

## F10. Design pattern đã áp dụng

| Pattern | Vấn đề trong thiết kế này | Lớp tham gia (vai trò trong pattern) | Lý do chọn | Phương án đơn giản hơn đã xét |
|---|---|---|---|---|
| Observer | Nhiều View React cần được báo khi trạng thái của một Store đổi, Store không nên biết View cụ thể | DC-StoreBase (Subject: subscribe, setState); View (Observer đăng ký qua useSyncExternalStore) | Khuôn Flux của P09 F5: dữ liệu một chiều Store --> View | Truyền state qua props từ gốc ứng dụng: các Store dùng chung (trang chủ và vỏ đặt vé cùng đọc DC-BookTicketsStore) buộc nâng state lên gốc, tăng coupling giữa các package View |
| Template Method | Luồng chọn ghế, giữ ghế, huỷ giữ ghế giống nhau ở kênh khách và kênh quầy, chỉ khác bước kết thúc | DC-HoldFlowStore (khung luồng), DC-BookTicketsStore, DC-CounterBookTicketsStore (bước kết thúc: thanh toán trực tuyến hoặc thu tiền mặt) | Một nơi duy nhất giữ quy tắc requestId, đếm ngược, đồng bộ ghế (race condition, BR-04, BR-85); lớp cha thay thế được ở mọi chỗ | Hai Store sao chép nhau: vá một lỗi giữ ghế phải sửa hai nơi và A3 cấm một package dùng lẫn của package tác nhân khác |
| Adapter | EventSource, Date.now, setInterval của trình duyệt khó kiểm thử mốc thời gian và nhịp tim; SMTP là giao thức ngoài (SS-02) | IF-42 và DC-BrowserEventSourceFactory; IF-43 và DC-BrowserTicker; IF-03 và DC-EmailGatewayManager | X2 cần thử mốc 20 giây không có khung, độ lùi nối lại, đếm ngược; SS-02 đổi nhà cung cấp SMTP chỉ sửa PKG-23 | Gọi thẳng API trình duyệt: không kiểm thử được mốc thời gian mà không chờ thật |
| Facade | Store cần một điểm vào REST duy nhất có mã phiên, thời gian chờ và xử lý 401 | IF-41 và DC-FetchApiClient | Mọi Store dùng chung một cách đính mã phiên và đưa về đăng nhập khi phiên mất (P09 F7.11) | Mỗi Store tự gọi fetch: lặp xử lý 401 ở 17 nơi và dễ sót |

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Người quyết | Đề xuất |
|---|---|---|---|---|---|
| Q-332 | Đã trả lời (chủ dự án chốt theo đề xuất). Câu hỏi gốc: Bảng tuyến REST (tên tuyến logic, phương thức, đường dẫn, thân yêu cầu và phản hồi) mà DC-FetchApiClient.routeTable cần do ai chốt và theo khuôn nào? | DC-FetchApiClient.routeTable, mọi Store; P12 PKG-11 | PKG-11 (DC-BookingController và các controller khác) chưa có thiết kế lớp; P10 F3 chỉ ghi Store gọi controller | Nhóm dự án (lần chạy P12 PKG-11) | Mỗi controller của PKG-11 một nhóm tuyến, tên tuyến logic theo dạng <nhóm>.<hành động> như dùng ở F3 (booking.holdSeats, seatmap.snapshot, ticket.check ...); P12 PKG-11 chốt phương thức, đường dẫn, trường; không đổi chữ ký Store khi chốt |
| Q-333 | Đã trả lời (chủ dự án chốt theo đề xuất). Câu hỏi gốc: Khi khách đóng tab hoặc mất mạng trong lúc đang chờ phản hồi giữ ghế, requestId có được giữ ở sessionStorage để lần mở lại gửi cùng mã không? | DC-HoldFlowStore.confirmSeatSelection, DC-HoldFlowStore.requestId; BR-85 | P04 UC-005 và BR-85 nêu chống giữ ghế hai lần nhưng không nêu phía trình duyệt | Nhóm dự án | Có: lưu requestId theo suất chiếu ở sessionStorage tới khi có kết quả; mở lại thì loadActiveHold trước, không có lần giữ ghế mới gửi lại cùng requestId |
| Q-334 | Đã trả lời (chủ dự án chốt theo đề xuất). Câu hỏi gốc: Trang kết quả thanh toán hỏi lại bao lâu một lần và tối đa bao lâu khi cổng chưa báo kết quả (IPN đến chậm)? | DC-BookTicketsStore.loadPaymentOutcome, SCR-06 | P04 UC-005 bước 10, 11 và BR-90 không nêu thời gian chờ ở màn hình kết quả | Nhóm dự án | 2 giây một lần, tối đa 30 giây; hết thì giữ trạng thái đang chờ và hướng khách kiểm tra Lịch sử đặt vé (thanh toán đến muộn xử lý bởi UC-006 nên khách không mất tiền) |
| Q-335 | Đã trả lời (chủ dự án chốt theo đề xuất). Câu hỏi gốc: Danh sách suất chiếu để chọn ở SCR-03, SCR-10 và SCR-16 lấy từ thao tác nào, vì P07 UC-005, UC-009 không có message tải danh sách? | DC-BookTicketsStore.loadBookableShowtimes, DC-CounterBookTicketsStore.loadCinemaShowtimes, DC-CheckTicketStore.loadShowtimesToCheck; PKG-11 | P07 UC-005 msg selectShowtime và UC-009 msg selectCheckingShowtime bắt đầu từ lúc tác nhân đã chọn | Nhóm dự án | Dùng đọc lịch chiếu của DC-CatalogController (UC-004, không khoá, không đăng nhập) với bộ lọc suất mở bán chưa bắt đầu và theo cụm rạp của phiên cho hai kênh nhân viên; không thêm trách nhiệm cho DC-BookTicketsService |
| Q-336 | Đã trả lời (chủ dự án chốt theo đề xuất). Câu hỏi gốc: Suất chiếu đang soát ở SCR-16 có giữ khi tải lại trang không (P08 ghi giữ trong phiên làm việc)? | DC-CheckTicketStore.checkingShowtime | P08 AC-B-CheckTicketForm.checkingShowtime "giữ trong phiên làm việc" | Nhóm dự án | Có: ghi sessionStorage cùng mã phiên, xoá khi đăng xuất hoặc khi phiên hết hiệu lực |
| Q-337 | Đã trả lời (chủ dự án chốt theo đề xuất). Câu hỏi gốc: Mã phiên giữ ở đâu trên trình duyệt: bộ nhớ, sessionStorage hay localStorage? | DC-SessionStore.session, DC-SessionStore.restore; NFR-01 đến NFR-03 | P09 F7.11 chỉ ghi "giữ mã phiên trên trình duyệt" | Nhóm dự án | sessionStorage: sống qua tải lại trang (lần giữ ghế đang chạy mở lại được, E-32), mất khi đóng tab; không dùng localStorage vì máy quầy dùng chung |
| Q-338 | Đã trả lời (chủ dự án chốt theo đề xuất). Câu hỏi gốc: Dòng hàng đợi EMAIL_TICKET và EMAIL_REFUND mang sourceId là mã gì để DC-EmailOutboxJob đọc dữ liệu thư? | DC-EmailOutboxJob.composeTicketEmail, composeRefundEmail; DC-PaymentReportService.HandleIpn, DC-RefundService.ProcessRefund | P12 lõi xếp Enqueue(EMAIL_TICKET) và Enqueue(EMAIL_REFUND) nhưng không ghi sourceId của từng loại | Nhóm dự án (chủ P12 lõi) | EMAIL_TICKET: sourceId là mã Booking; EMAIL_REFUND: sourceId là mã RefundRequest; idempotencyKey làm khoá chống lặp và Message-ID |
| Q-339 | Đã trả lời (chủ dự án chốt theo đề xuất). Câu hỏi gốc: Số ghế tối đa mỗi lần giữ (8) để View kiểm nhanh có lấy từ máy chủ hay đặt hằng ở trình duyệt? | DC-ShowtimeView.maxSeatsPerHold, DC-HoldFlowStore.toggleSeat; DC-Showtime.MaxSeatsPerHold (P12 lõi) | P12 lõi đã chốt hằng một nơi ở DC-Showtime (SY-15); trình duyệt lặp hằng sẽ lệch khi đổi | Nhóm dự án | Lấy từ phản hồi thông tin suất chiếu (trường maxSeatsPerHold), trình duyệt chỉ kiểm nhanh, máy chủ vẫn quyết (MSG-10) |
| Q-340 | Đã trả lời (chủ dự án chốt theo đề xuất). Câu hỏi gốc: Vé in tại quầy (SCR-12) dựng ảnh QR ở trình duyệt hay lấy ảnh từ máy chủ? | DC-SoldTickets.qrContents, DC-CounterPrintTicketsPage | P01: máy in nối máy tính tại quầy; P10 không nêu thư viện sinh QR ở trình duyệt | Nhóm dự án | Máy chủ trả chuỗi nội dung QR (mã vé); trình duyệt dựng ảnh bằng thư viện sinh QR có sẵn (cùng loại với thư viện đọc QR ở SCR-16), không lưu ảnh |
| Q-341 | Đã trả lời (chủ dự án chốt theo đề xuất). Câu hỏi gốc: Sau khi mất mạng lúc xác nhận thu tiền mặt, nhân viên quầy đối chiếu kết quả bằng thao tác đọc nào: GetHold của DC-BookTicketsService có trả trạng thái lần giữ ghế và mã đặt vé khi đã bán không? | DC-CounterBookTicketsStore.reconcileCashResult; DC-HoldResult, DC-BookTicketsService.GetHold (P12 lõi); BR-44 | DC-HoldResult của P12 lõi không có holdStatus, bookingCode; gửi lại ConfirmCashReceived sau khi đã bán trả HoldNotActive nên bị hiểu nhầm là phải trả tiền mặt | Nhóm dự án (chủ P12 lõi) | Thêm holdStatus và bookingCode (cùng vé khi COMPLETED) vào kết quả đọc GetHold; Store chỉ dùng thao tác đọc này để đối chiếu |

## Giả định

Không có (chế độ NGHIEM_NGAT).

## Đề xuất sửa artifact trước

Không có

## Vấn đề còn mở

1. Phạm vi vượt ngưỡng khoảng 20 lớp có hành vi của prompt (64 phần tử). Lựa chọn: một tệp cho mười package theo yêu cầu người dùng của lần chạy; các lớp của tầng trình bày đều mỏng (bộ xử lý sự kiện và Store thao tác trạng thái), nên không chia hai lượt. Nếu thấy dài, tách theo F-section hoặc theo nhóm tác nhân khi sửa.
2. Các tuyến logic ở F3 (booking.holdSeats, booking.confirmCash, seatmap.snapshot, payment.status, ticket.check, report.cinema, showtime.save, auth.customerLogin ...) khớp bảng tuyến F2a của file PKG-11-http-api.md (Q-332); đổi tên tuyến thì đổi cả hai file.
3. Mục tiêu hiệu năng NFR-06 (giữ ghế p95 2 giây), NFR-08, NFR-09 (sơ đồ ghế trong 3 giây) chỉ kiểm được bằng ca đo T1 đến T7 (P09 Vấn đề còn mở 2); P12 chỉ chốt hằng thời gian phía trình duyệt (20 giây coi kết nối chết, 60 giây làm mới, độ trễ ngẫu nhiên 0 đến 3 giây, hỏi trạng thái thanh toán 2 giây tối đa 30 giây, timeout REST 15 giây) là tham số kỹ thuật theo C1 mục 7.
4. PKG-05 có 17 phần tử có hành vi, vượt mức 15 (F9); PKG-31 có vòng nội bộ giữa DC-FetchApiClient và DC-SessionStore (cùng package, ghi ở F9).
5. Chưa thiết kế: giao diện chọn sơ đồ ghế trong form phòng chiếu (DC-ManageAuditoriumsView giữ lưới ghế nhập; thuật toán nhập lưới do code), thư viện đọc QR và sinh QR (không thành lớp, P10), vỏ ứng dụng React gốc (định tuyến, nối IF-41, IF-42, IF-43 vào Store ở hàm khởi động) nằm ngoài mô hình package như phần nối của P12 lõi.
6. Lớp có trạng thái chỉ là LoadStatus (các Store khác ST-17) không làm state machine theo [Target] 18 vì không có BR dạng "chỉ được X khi đang Y" và có ít hơn ba trạng thái nghiệp vụ; chống bấm hai lần dùng cờ SUBMITTING.
7. Operation bổ sung không có message P07: loadBookableShowtimes, loadCinemaShowtimes, loadShowtimesToCheck, loadCancellableTickets (Q-335 và Bổ sung), reconcileCashResult (Q-341).
8. Mật khẩu khách nhập ở View chỉ đi qua tham số và không lưu trong state của Store sau khi gửi (NFR-01 đến NFR-03); cơ chế che trong DevTools không thuộc P12.
