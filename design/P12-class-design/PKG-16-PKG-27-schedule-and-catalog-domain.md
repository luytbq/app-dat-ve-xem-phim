# P12 - Thiết kế lớp - PKG-16 ScheduleAndPricing và phần còn lại của PKG-27 CinemaOperations - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P12 (chạy theo package) |
| Phiên bản | 1.1 |
| Đầu vào đã dùng | project-profile.md; 00-Conventions.md; 00-Concurrency.md (M7); P12-class-design.md 1.6 (lõi: F1, F1b, F2.PKG-27, F5, F6, Vấn đề còn mở 9); P10-design-elements.md 2.0 (F3, F3a, F4, F5); P09-architecture.md 2.0 (F7.3 EX-11 đến EX-19); P08-analysis-model.md 2.0 (F3, F4, F4b, F4c); P07 của UC-012, UC-013, UC-014; P04 UC-012 đến UC-014 và _BR-register.md (đọc BR); P11a 2.0 (SCR-18 đến SCR-20, SCR-28, SCR-29); P11b 2.0 (không có SS trong phạm vi); P13-data-model.md 1.5 và P13-schema.sql (ánh xạ cột); _sync-log.md (Đầu vào cho lần chạy lại P08-P13). Dải mã được cấp cho phiên: R-200 đến R-239, ST-06 đến ST-09, IF-29 đến IF-31, Q-292 đến Q-301 |
| Phạm vi | PKG-16 (DC-ManagePriceListService, DC-ScheduleShowtimesService, DC-ManageAuditoriumsService) và phần còn lại của PKG-27: DC-Cinema, DC-Auditorium, DC-Seat, DC-Movie, DC-PriceEntry, phần còn lại của DC-Showtime và DC-PriceList, IF-11 đến IF-14; cấp mới IF-29 (PKG-28). UC-012, UC-013, UC-014; phần UC-010, UC-011 chạm DC-Movie, DC-Cinema |
| Mã Q, ASM cuối đã cấp | Q-282 (toàn dự án), không cấp Q mới trong dải Q-292 đến Q-301; không có ASM (NGHIEM_NGAT). R cuối: R-228. ST cuối: ST-07. IF cuối: IF-29 |

## 0. Phạm vi lần chạy và quy ước

0.1. Phạm vi. Lần chạy này chi tiết hoá 15 lớp có hành vi: 3 lớp dịch vụ của PKG-16; 7 lớp miền và 4 interface kho của PKG-27; IF-29 mới ở PKG-28. Lớp lõi đã chi tiết hoá ở P12-class-design.md (DC-Showtime: CheckSaleOpen, CheckUnchangedSince, CheckSeatSelection, QuoteSeatPrices, BelongsToCinema, CheckCancellationDeadline, các getter ID, StartTime, Status, LastChangedAt; DC-PriceList.DetermineSeatPrice; IF-08, IF-25, IF-24, DC-RandomCodeGenerator, DC-Money, DC-CinemaIds, DC-ShowtimeStatus, DC-PriceQuery, DC-ShowtimeRouting, DC-ShowtimeInfo, DC-TxOptions, các lỗi dùng chung; IF-11.FindRouting, LockShared, FindByID, FindInfo; IF-12.LockSharedByCinema; IF-13.LockAuditoriumShared, FindSeats) chỉ được dẫn lại, không định nghĩa lại. Quy ước chung (bảng ánh xạ kiểu sang Go, association bằng mã, ctx và tx, hạng khoá cố định theo operation, now qua tham số) theo mục 0.2, 0.3 của P12-class-design.md.

0.2. Operation đọc cho UC-003, UC-004, UC-015, UC-016 dùng DC-Movie.RunStatusAt, DC-Movie.Info, DC-Cinema.Info, IF-11.ListInfoByMovie, IF-11.ListInfoByCinema; việc lọc suất chiếu theo tiêu chí và tính số liệu báo cáo nằm ở PKG-17, PKG-18, PKG-33 (selectShowtimes, IF-28) nên DC-Showtime, DC-Auditorium không cần CheckInSchedule, CheckMatchesCriteria, CheckMatchesRoomCriteria, ProvideReportFigures. DC-ManageMoviesService, DC-ManageCinemasService thuộc PKG-30. Phần entity của UC-010, UC-011 (khởi tạo, kiểm hợp lệ, kiểm mốc, ghi thay đổi) nằm ở đây vì lớp thuộc PKG-27.

0.3. Quyết định thiết kế chung của lần chạy.

- Mô hình thanh toán tài nguyên giữ nguyên P10 F3a: lớp dịch vụ của PKG-16 là nơi duy nhất thấy cả chuỗi khoá EX-11 đến EX-15, EX-18, EX-19; entity không gọi kho và không gọi SeatHold, SeatStatus, Ticket (Q-117). Phần kiểm vượt biên package (lần giữ ghế còn hiệu lực, vé chưa huỷ) làm trong lớp dịch vụ bằng hàm private.
- Mốc "đã thay đổi kể từ lúc hiển thị" (BR-54, BR-60, BR-63, BR-138, BR-142, BR-146, Q-247) là lastChangedAt của chính đối tượng, so bằng nhau (khác nhau nghĩa là đã bị đổi, tạo hoặc bỏ). Mọi so sánh thời gian nghiệp vụ nhận now qua tham số, now lấy một lần từ Tx.Now sau khi có khoá.
- Entity lớp con của aggregate được nạp cùng gốc: DC-Auditorium nạp kèm các DC-Seat của nó (R-39, tối đa 400 cộng ghế đã bỏ), DC-PriceList nạp kèm DC-PriceEntry (R-41, tối đa 72 tổ hợp, kể cả mục đã bỏ). Các association còn lại giữ mã (R-38, R-40, R-42, R-43) và kho nạp khi cần.
- Giá trị so sánh tên (tên phòng, tên cụm rạp) dùng hàm DC-Cinema.NormalizeName (Q-266: bỏ khoảng trắng đầu và cuối, gộp khoảng trắng liền nhau, không phân biệt hoa thường).
- Ngày nghiệp vụ của phim và khung giờ của bảng giá tính theo múi giờ Asia/Ho_Chi_Minh (Q-268), đổi từ time.Time bằng một biến vị trí chung của DC-PriceList và DC-Movie (Thiết kế: múi giờ cố định của chuỗi rạp, giống ghi chú của DetermineSeatPrice ở lõi).
- Khoảng dọn phòng 15 phút (BR-51) và giới hạn sức chứa 50 đến 400 (BR-144) là hằng Classifier của DC-Auditorium, nguồn BR.

## F1. Bảng lớp thiết kế

| DC | Tên | Stereotype | PKG | Trách nhiệm | Nguồn AC | Loại | Persistent | Ghi chú thiết kế |
|---|---|---|---|---|---|---|---|---|
| DC-ManagePriceListService | ManagePriceListService | «service» | PKG-16 | Điều phối hiển thị, đặt giá, đổi giá và bỏ mục giá của bảng giá cụm rạp, là ranh giới giao dịch của EX-11, EX-12 | AC-C-ManagePriceListController | class | Không | Control đổi tên Service (P10 F3). Bốn phụ thuộc tiêm (IF-08, IF-11, IF-12, IF-13); không cần gộp hay tách |
| DC-ScheduleShowtimesService | ScheduleShowtimesService | «service» | PKG-16 | Điều phối lập mới, sửa, xoá suất chiếu và dữ liệu hiển thị của chúng, là ranh giới giao dịch của EX-13, EX-14 | AC-C-ScheduleShowtimesController | class | Không | Điều phối cả việc kiểm lần giữ ghế, vé và tạo, giải phóng SeatStatus (Q-117, Q-109). Bảy phụ thuộc tiêm (Vấn đề còn mở 3) |
| DC-ManageAuditoriumsService | ManageAuditoriumsService | «service» | PKG-16 | Điều phối thêm, sửa, xoá phòng chiếu và sơ đồ ghế, là ranh giới giao dịch của EX-15, EX-18, EX-19 | AC-C-ManageAuditoriumsController | class | Không | Điều phối cả việc tạo, bỏ SeatStatus của suất chiếu chưa mở bán (Q-249); bảy phụ thuộc tiêm |
| DC-Cinema | Cinema | «entity» | PKG-27 | Giữ thông tin một cụm rạp và kiểm tên cụm rạp, tên phòng chiếu của nó không trùng | AC-E-Cinema | class | Có | Không nắm danh sách phòng (R-38 chiều B --> A); chỉ làm phần UC-011, UC-012 |
| DC-Auditorium | Auditorium | «entity» | PKG-27 | Giữ thông tin phòng chiếu cùng sơ đồ ghế, kiểm hợp lệ, sức chứa, khoảng dọn phòng và tính thay đổi sơ đồ ghế | AC-E-Auditorium | class | Có | Giữ 20 trách nhiệm của P08 (P10 Vấn đề còn mở 10): bốn trách nhiệm (saveShowtime, addToSchedule, checkStillExists, checkEditAllowed) chuyển sang lớp dịch vụ; còn 20 operation public, phần lớn là kiểm nhỏ và getter |
| DC-Seat | Seat | «entity» | PKG-27 | Giữ vị trí và loại một ghế của phòng chiếu và vòng đời trong sơ đồ ghế | AC-E-Seat | class | Có | ST-07; ghế bỏ chỉ đánh dấu (BR-118) |
| DC-Movie | Movie | «entity» | PKG-27 | Giữ thông tin một phim và kiểm định dạng, ngày chiếu, thời lượng cho suất chiếu | AC-E-Movie | class | Có | Chỉ làm UC-010 và UC-014; UC-003, UC-004 để lượt PKG-17 |
| DC-Showtime | Showtime | «entity» | PKG-27 | Tiếp lõi: kiểm quy tắc lập, sửa, xoá suất chiếu và vòng đời Trong lịch chiếu, Đã xoá | AC-E-Showtime | class | Có | ST-06; phần của UC-005, UC-008, UC-009 đã ở lõi; không gọi SeatHold, SeatStatus, Ticket (Q-117). Tổng operation public sau lượt này: 28, vượt ngưỡng 15 đến 20, giữ vì P10 Vấn đề còn mở 10 và đa số là kiểm nhỏ cùng một aggregate (Vấn đề còn mở 2) |
| DC-PriceList | PriceList | «entity» | PKG-27 | Tiếp lõi: giữ các mục giá của một cụm rạp, kiểm giá hợp lệ, mốc thay đổi, phủ giá và bỏ mục giá | AC-E-PriceList | class | Có | Nơi duy nhất xác định khung giờ (BR-12, DetermineTimeBand) |
| DC-PriceEntry | PriceEntry | «entity» | PKG-27 | Giữ giá vé của một tổ hợp loại phòng, định dạng, loại ghế, khung giờ cùng mốc thay đổi | AC-E-PriceEntry | class | Có | Thành phần của DC-PriceList (R-41); cờ removed giữ dấu vết mục đã bỏ để nhận ra "đã bỏ kể từ lúc hiển thị" (BR-63) |
| IF-11 | IShowtimeRepository | «interface» | PKG-27 | Tiếp lõi: khoá, đọc, ghi suất chiếu cho EX-12, EX-13, EX-14, EX-15, EX-19 | P10 cơ chế Persistence | interface | Không | Thêm 9 operation |
| IF-12 | IPriceListRepository | «interface» | PKG-27 | Tiếp lõi: khoá độc quyền, đọc, ghi mục giá của bảng giá | P10 cơ chế Persistence | interface | Không | Thêm 4 operation |
| IF-13 | ICinemaRepository | «interface» | PKG-27 | Tiếp lõi: khoá, đọc, ghi cụm rạp, phòng chiếu và ghế | P10 cơ chế Persistence | interface | Không | Thêm 15 operation; hạng 0 và 2 |
| IF-14 | IMovieRepository | «interface» | PKG-27 | Khoá hạng 10, đọc và ghi phim | P10 cơ chế Persistence | interface | Không | Dùng cho EX-13 (S), EX-16 (X, PKG-30) |
| IF-29 | IShowtimeGuardRepository | «interface» | PKG-28 | Đọc và khoá lần giữ ghế, vé, trạng thái ghế của một suất chiếu cho việc lập, sửa, xoá lịch chiếu và sơ đồ ghế | Thiết kế: tách theo bên gọi (cùng cách IF-26, IF-27 ở X1 RV-06) | interface | Không | Cấp mới theo Bước 1.5: P10 F3a chỉ nêu IF-17, IF-18, IF-27 mà ba interface đó không có thao tác theo suất chiếu; tách để bản giả của DC-ScheduleShowtimesService, DC-ManageAuditoriumsService nhỏ. Hạng 5, 6, 8. Đề xuất sửa P10 |

### F1b. Kiểu phụ trợ

| DC | Loại | PKG | Thành phần hoặc giá trị | Dùng trong chữ ký |
|---|---|---|---|---|
| DC-MovieId | value object | PKG-27 | int64 (Thiết kế: cùng nhóm định danh số của DC-CinemaIds, khoá theo thứ tự số) | DC-Movie, IF-14, DC-Showtime |
| DC-AuditoriumType | enumeration | PKG-27 | STANDARD (thường), IMAX, FOURDX (4DX); cột P13 lưu 'STANDARD', 'IMAX', '4DX' | DC-Auditorium, DC-PriceEntry, DC-PriceQuery |
| DC-MovieFormat | enumeration | PKG-27 | FORMAT_2D, FORMAT_3D; cột P13 lưu '2D', '3D'. Thay kiểu string của lõi ở DC-Showtime.movieFormat, DC-PriceQuery.movieFormat | DC-Movie, DC-Auditorium, DC-Showtime, DC-PriceEntry |
| DC-SeatType | enumeration | PKG-27 | STANDARD (ghế thường), VIP, COUPLE (ghế đôi) | DC-Seat, DC-PriceEntry, DC-PriceQuery, DC-Auditorium.SeatTypes |
| DC-TimeBand | enumeration | PKG-27 | WEEKDAY_BEFORE_17, WEEKDAY_FROM_17, WEEKEND_BEFORE_17, WEEKEND_FROM_17 (BR-12) | DC-PriceList.DetermineTimeBand, DC-PriceCombo |
| DC-AgeRating | enumeration | PKG-27 | P, K, T13, T16, T18, C (Q-199) | DC-Movie, DC-MovieDraft |
| DC-BusinessDate | value object | PKG-27 | year, month, day (ngày theo Asia/Ho_Chi_Minh, không mang giờ; Q-268); So sánh theo thứ tự lịch | DC-Movie.RunStatusAt, DC-BrowseMoviesService |
| DC-RunStatus | enumeration | PKG-27 | NOW_SHOWING (đang chiếu), COMING_SOON (sắp chiếu), ENDED (đã qua ngày kết thúc chiếu) | DC-Movie.RunStatusAt, DC-BrowseMoviesService, DC-BrowseShowtimesService |
| DC-SeatMapState | enumeration | PKG-27 | IN_MAP (đang trong sơ đồ ghế), RETIRED (đã bỏ khỏi sơ đồ ghế) | DC-Seat (ST-07) |
| DC-ShowtimePhase | enumeration | PKG-27 | NOT_ON_SALE (chưa mở bán), ON_SALE (đang mở bán), SHOWING (đang chiếu), ENDED (đã kết thúc); suy ra, không lưu | DC-Showtime.Phase (ST-06) |
| DC-PriceCombo | value object | PKG-27 | auditoriumType, movieFormat, seatType, timeBand: định danh tổ hợp của mục giá (BR-62) | DC-PriceList, DC-PriceEntry, DC-Showtime.UsesPriceEntry |
| DC-SeatDraft | value object | PKG-27 | rowCode (string), seatNumber (int), seatType: một ghế do quản lý nhập | DC-Seat.NewSeat, DC-AuditoriumDraft |
| DC-AuditoriumDraft | value object | PKG-27 | name, auditoriumType, formats ([]MovieFormat), seats ([]SeatDraft): thông tin phòng chiếu đã nhập | DC-Auditorium.CreateAuditorium, ApplyChanges, DC-ManageAuditoriumsService |
| DC-SeatMapChange | value object | PKG-27 | added ([]SeatDraft), retired ([]SeatId), retyped (map[SeatId]SeatType), Changed (bool: có ghế thêm, bỏ hoặc đổi loại) | DC-Auditorium.ComputeSeatMapChange, ApplyChanges |
| DC-SeatMapDelta | value object | PKG-27 | addedSeatIds ([]SeatId), removedSeatIds ([]SeatId): ghế phải thêm, bỏ trạng thái ghế của một suất chiếu chưa mở bán | DC-Showtime.AdoptSeatMap |
| DC-AuditoriumRef | value object | PKG-27 | id (AuditoriumId), name (string): tên phòng đã có của cụm rạp | DC-Cinema.CheckAuditoriumNameAvailable, IF-13.ListAuditoriumRefs |
| DC-AuditoriumInfo | value object | PKG-27 | id, cinemaId, name, auditoriumType, formats, capacity (int), seatCountByType (map[SeatType]int), lastChangedAt | DC-Auditorium.Info, DC-ManageAuditoriumsService |
| DC-AuditoriumDetail | value object | PKG-27 | AuditoriumInfo cùng seats ([]SeatInfo) | DC-Auditorium.Detail |
| DC-SeatInfo | value object | PKG-27 | id, rowCode, seatNumber, seatType, mapState | DC-Seat.Info |
| DC-CinemaDraft | value object | PKG-27 | name, province, address (string, tuỳ chọn) | DC-Cinema.NewCinema, SaveChanges |
| DC-CinemaInfo | value object | PKG-27 | id, name, province, address, lastChangedAt | DC-Cinema.Info |
| DC-MovieDraft | value object | PKG-27 | title, durationMinutes, releaseDate, endOfRunDate, genre, ageRating, description, trailer (tuỳ chọn), releaseFormats | DC-Movie.NewMovie, SaveChanges |
| DC-MovieInfo | value object | PKG-27 | id, movieCode, title, durationMinutes, releaseDate, endOfRunDate, genre, ageRating, description, trailer, releaseFormats, lastChangedAt | DC-Movie.Info |
| DC-PriceEntryInfo | value object | PKG-27 | combo, ticketPrice (Money), lastChangedAt, removed | DC-PriceEntry.Info, DC-PriceList.ProvideEntries |
| DC-ShowtimeListItem | value object | PKG-27 | id, movieTitle, movieFormat, auditoriumName, auditoriumType, startTime, endTime, saleOpenTime, lastChangedAt: một dòng danh sách suất chiếu chưa xoá của cụm rạp (đọc join) | IF-11.ListByCinema, IF-11.FindListItem |
| DC-PriceListView | value object | PKG-16 | entries ([]PriceEntryInfo), cinemaId; mốc lúc hiển thị của tổ hợp chưa có mục giá là time.Time rỗng | DC-ManagePriceListService.GetPriceList |
| DC-PriceEntryRequest | value object | PKG-16 | combo, ticketPrice (int64), displayedAt (time.Time: mốc lúc hiển thị, rỗng nếu tổ hợp chưa có mục giá) | DC-ManagePriceListService.SubmitPriceEntry |
| DC-RemovePriceEntryRequest | value object | PKG-16 | combo, displayedAt | DC-ManagePriceListService.SubmitPriceEntryRemoval |
| DC-ScheduleFormData | value object | PKG-16 | auditoriums ([]AuditoriumInfo), movies ([]MovieInfo) | DC-ScheduleShowtimesService.StartScheduling |
| DC-NewShowtimeRequest | value object | PKG-16 | movieId, movieFormat, auditoriumId, startTime, saleOpenTime | DC-ScheduleShowtimesService.CreateShowtime |
| DC-UpdateShowtimeRequest | value object | PKG-16 | showtimeId, movieId, movieFormat, auditoriumId, startTime, saleOpenTime, displayedAt (mốc thay đổi lúc hiển thị) | DC-ScheduleShowtimesService.UpdateShowtime |
| DC-ShowtimeEditView | value object | PKG-16 | showtime (ShowtimeListItem), movieId, auditoriumId, auditoriums ([]AuditoriumInfo), movies ([]MovieInfo) | DC-ScheduleShowtimesService.PrepareShowtimeEdit |
| DC-EditAuditoriumRequest | value object | PKG-16 | auditoriumId, draft (AuditoriumDraft), displayedAt | DC-ManageAuditoriumsService.EditAuditorium |
| DC-FieldInvalidError | exception | PKG-27 | violations (map[string]string: tên trường --> điều kiện bị vi phạm, Q-204): tên, loại phòng, định dạng, ghế trống hoặc sai, cặp hàng và số ghế trùng; tên phim, thể loại, thời lượng, ngày, nhãn độ tuổi, định dạng phát hành; tên và tỉnh cụm rạp | DC-Auditorium.CheckAuditoriumInfoValid, DC-Seat.CheckSeatValid, DC-Movie.CheckMovieInfoValid, DC-Cinema.CheckCinemaInfoValid |
| DC-NotOwnCinemaError | exception | PKG-27 | Phòng chiếu không thuộc cụm rạp của quản lý cụm rạp (BR-46, BR-135) | DC-Auditorium.CheckBelongsToCinema |
| DC-FormatNotReleasedError | exception | PKG-27 | Định dạng không là định dạng phát hành của phim (BR-47) | DC-Movie.CheckReleasedInFormat |
| DC-FormatNotSupportedError | exception | PKG-27 | Phòng chiếu không chiếu được định dạng (BR-48) | DC-Auditorium.CheckSupportsFormat |
| DC-PriceNotCoveredError | exception | PKG-27 | Bảng giá thiếu giá cho một loại ghế của phòng theo khung giờ (BR-69, BR-73, BR-68); mang combo đầu tiên thiếu | DC-PriceList.CheckCoversShowtime, DC-Showtime.CheckStaysPriced |
| DC-OutsideRunPeriodError | exception | PKG-27 | Ngày chiếu ngoài khoảng khởi chiếu đến kết thúc chiếu của phim (BR-49) | DC-Movie.CheckWithinRunPeriod |
| DC-ShowtimeStartedError | exception | PKG-27 | Giờ bắt đầu không sau thời điểm kiểm tra (BR-56 khi lập, BR-57 khi sửa, xoá) | DC-Showtime.CheckNotStarted |
| DC-SaleOpenOrderError | exception | PKG-27 | Thời điểm mở bán không trước giờ bắt đầu (BR-55) | DC-Showtime.CheckSaleOpenBeforeStart |
| DC-RoomGapError | exception | PKG-27 | Khoảng cách tới suất chiếu khác trong phòng dưới 15 phút (BR-51) | DC-Auditorium.CheckRoomGap |
| DC-ShowtimeInUseError | exception | PKG-16 | Suất chiếu còn lần giữ ghế hiệu lực hoặc vé chưa huỷ (BR-53) | DC-ScheduleShowtimesService.checkNoActiveHoldOrSoldTicket |
| DC-RoomChangeNotAllowedError | exception | PKG-27 | Đổi phòng của suất chiếu đã từng có vé, kể cả vé đã huỷ (BR-92) | DC-Showtime.CheckRoomChangeAllowed |
| DC-AuditoriumGoneError | exception | PKG-27 | Phòng chiếu đích không còn (BR-147, luồng 8h) hoặc không còn để xoá, sửa | DC-ScheduleShowtimesService, DC-ManageAuditoriumsService |
| DC-AuditoriumChangedError | exception | PKG-27 | Phòng chiếu đã bị sửa kể từ lúc hiển thị (BR-146) | DC-Auditorium.CheckUnchangedSinceDisplayed |
| DC-AuditoriumNameTakenError | exception | PKG-27 | Tên phòng đã thuộc phòng khác của cụm rạp (BR-145) | DC-Cinema.CheckAuditoriumNameAvailable |
| DC-CapacityOutOfRangeError | exception | PKG-27 | Sức chứa ngoài 50 đến 400 ghế (BR-144) | DC-Auditorium.CheckCapacityInRange |
| DC-AuditoriumBlockedError | exception | PKG-27 | Phòng có suất chiếu đã mở bán mà chưa kết thúc nên không sửa sơ đồ ghế (BR-87) | DC-ManageAuditoriumsService.EditAuditorium |
| DC-AuditoriumHasScheduleError | exception | PKG-27 | Phòng đã từng có suất chiếu, kể cả đã xoá (BR-147) | DC-Auditorium.CheckNeverScheduled |
| DC-PriceEntryChangedError | exception | PKG-27 | Mục giá của tổ hợp đã bị đổi, tạo hoặc bỏ kể từ lúc hiển thị (BR-63) | DC-PriceList.CheckEntryUnchangedSinceDisplayed |
| DC-PriceEntryInUseError | exception | PKG-27 | Còn suất chiếu chưa tới giờ bắt đầu đang dùng mục giá (BR-64, BR-68) | DC-PriceList.RemovePriceEntry |
| DC-TicketPriceInvalidError | exception | PKG-27 | Giá vé không lớn hơn 0 (BR-70) | DC-PriceList.CheckTicketPriceValid |
| DC-MovieChangedError | exception | PKG-27 | Phim đã bị sửa kể từ lúc hiển thị (BR-138) | DC-Movie.CheckUnchangedSinceDisplayed |
| DC-CinemaChangedError | exception | PKG-27 | Cụm rạp đã bị sửa kể từ lúc hiển thị (BR-142) | DC-Cinema.CheckUnchangedSinceDisplayed |
| DC-CinemaNameTakenError | exception | PKG-27 | Tên cụm rạp đã thuộc cụm rạp khác (BR-141) | DC-Cinema.CheckNameNotTaken |
| DC-SeatStateError | exception | PKG-27 | Ghế đã bỏ khỏi sơ đồ ghế bị yêu cầu bỏ lần nữa hoặc đổi loại (ST-07) | DC-Seat.RetireFromSeatMap, SetType |

## F2. Bảng operation

Bảng ánh xạ kiểu và quy ước chữ ký theo mục 0.2, 0.3 của P12-class-design.md. Tên operation public viết hoa đầu, ~ là nội bộ package, - là private.

F2.PKG-27 phần DC-Cinema, DC-Movie, DC-Seat, DC-Auditorium

| DC | Visibility | Chữ ký | Mô tả | Tiền/hậu điều kiện | Nguồn (message P07 / UC bước) | Phạm vi | Ngoại lệ / lỗi |
|---|---|---|---|---|---|---|---|
| DC-Cinema | + | NewCinema(d CinemaDraft, now time.Time) *Cinema | Tạo cụm rạp dự kiến, chưa có phòng, bảng giá hay nhân viên; đặt lastChangedAt = now | Hậu: chưa lưu, id gán khi lưu | P08 AC-E-Cinema// createCinema, addToCinemaList | Classifier | - |
| DC-Cinema | + | CheckCinemaInfoValid() error | Kiểm tên và tỉnh, thành phố không trống; trả điều kiện bị vi phạm của từng trường | Dữ liệu vào 1 của UC-011 (Q-204). Hậu: không đổi | P08 AC-E-Cinema// checkCinemaInfoValid | Instance | FieldInvalidError |
| DC-Cinema | + | CheckNameNotTaken(sameName *Cinema) error | sameName là cụm rạp tìm được theo tên chuẩn hoá (nil nếu không có); khác chính cụm rạp này thì từ chối | BR-141. Tiền: đã lấy khoá giá trị tên (P09 F7.3 EX-17). Hậu: không đổi | P08 AC-E-Cinema// checkNameTaken | Instance | CinemaNameTakenError |
| DC-Cinema | + | CheckUnchangedSinceDisplayed(displayedAt time.Time) error | So lastChangedAt với mốc lúc hiển thị | BR-142, Q-247. Hậu: không đổi | P08 AC-E-Cinema// checkUnchangedSinceDisplayed | Instance | CinemaChangedError |
| DC-Cinema | + | SaveChanges(d CinemaDraft, displayedAt, now time.Time) error | Kiểm mốc rồi ghi tên, tỉnh, địa chỉ và đặt lastChangedAt = now | BR-142. Hậu: phòng, suất chiếu, nhân viên không đổi | P08 AC-E-Cinema// saveCinemaChanges | Instance | CinemaChangedError |
| DC-Cinema | + | Info() CinemaInfo | Tên, tỉnh, địa chỉ, mốc thay đổi để hiển thị | - | P08 AC-E-Cinema// provideCinemaInfo | Instance | - |
| DC-Cinema | + | ID() CinemaId | Định danh | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-Cinema | + | CheckAuditoriumNameAvailable(name string, excludeId AuditoriumId, existing []AuditoriumRef) error | Tên chuẩn hoá của name không trùng tên phòng nào của existing trừ phòng mang excludeId (0 khi thêm) | BR-145, Q-266. Tiền: Cinema X đã khoá. Hậu: không đổi | P07 UC-012 msg 2.1.6.1, 2.1.6a.2 // checkAuditoriumNameAvailable | Instance | AuditoriumNameTakenError |
| DC-Cinema | + | NormalizeName(s string) string | Bỏ khoảng trắng đầu và cuối, gộp khoảng trắng liền nhau, chuyển chữ thường | Q-266. Thuần tính toán | Bổ sung: so sánh tên một nơi | Classifier | - |
| DC-Movie | + | NewMovie(d MovieDraft, now time.Time) *Movie | Tạo phim dự kiến; lastChangedAt = now | Hậu: chưa lưu; mã phim suy ra từ id khi lưu | P08 AC-E-Movie// createMovie, addToMovieList | Classifier | - |
| DC-Movie | + | CheckMovieInfoValid() error | Kiểm điều kiện của Dữ liệu vào 1 UC-010: tên và thể loại không trống, thời lượng > 0, ngày kết thúc chiếu không trước ngày khởi chiếu, nhãn độ tuổi thuộc tập, có ít nhất một định dạng phát hành | BR-134, Q-196 đến Q-199. Hậu: không đổi | P08 AC-E-Movie// checkMovieInfoValid | Instance | FieldInvalidError |
| DC-Movie | + | CheckUnchangedSinceDisplayed(displayedAt time.Time) error | So lastChangedAt với mốc lúc hiển thị | BR-138, Q-247 | P08 AC-E-Movie// checkUnchangedSinceDisplayed | Instance | MovieChangedError |
| DC-Movie | + | SaveChanges(d MovieDraft, displayedAt, now time.Time) error | Kiểm mốc rồi ghi thông tin mới, đặt lastChangedAt = now | BR-138, BR-84, BR-139. Hậu: suất chiếu đã lập không đổi (không chạm bảng suất chiếu) | P08 AC-E-Movie// saveMovieChanges | Instance | MovieChangedError |
| DC-Movie | + | CheckReleasedInFormat(f MovieFormat) error | f là một trong releaseFormats | BR-47 | P07 UC-014 msg 2.1.4, 2.1.17.2.1 // checkReleasedInFormat | Instance | FormatNotReleasedError |
| DC-Movie | + | CheckWithinRunPeriod(start time.Time) error | Ngày (Asia/Ho_Chi_Minh) của start nằm trong [releaseDate, endOfRunDate], gồm hai đầu | BR-49, Q-268 | P07 UC-014 msg 2.1.11, 2.1.17.2.2 // checkWithinRunPeriod | Instance | OutsideRunPeriodError |
| DC-Movie | + | Duration() time.Duration | Thời lượng phim | BR-50 | P07 UC-014 msg 2.1.16.1 // provideDuration | Instance | - |
| DC-Movie | + | Info() MovieInfo | Thông tin phim để hiển thị | - | P08 AC-E-Movie// provideMovieInfo | Instance | - |
| DC-Movie | + | ID() MovieId | Định danh | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-Movie | + | RunStatusAt(today BusinessDate) RunStatus | COMING_SOON khi today trước releaseDate; ENDED khi today sau endOfRunDate; còn lại NOW_SHOWING (ngày kết thúc chiếu vẫn thuộc khoảng chiếu) | BR-76. Hậu: không đổi | P07 UC-003 msg 1.1.1 // determineRunStatus; UC-004 msg 1.1.1 | Instance | - |
| DC-Seat | + | NewSeat(d SeatDraft) *Seat | Tạo ghế Trong sơ đồ ghế của phòng chiếu dự kiến | Hậu: mapState = IN_MAP (ST-07 sự kiện create) | P08 AC-E-Seat// createSeat | Classifier | - |
| DC-Seat | + | CheckSeatValid() error | Hàng không trống, số ghế > 0, loại ghế thuộc ba loại | REQ-16. Hậu: không đổi | P08 AC-E-Seat// checkSeatValid | Instance | FieldInvalidError |
| DC-Seat | + | RetireFromSeatMap() error | Đánh dấu ghế đã bỏ khỏi sơ đồ ghế; ghế giữ lại cho trạng thái ghế của suất chiếu đã kết thúc hoặc đã xoá | BR-118. Tiền: IN_MAP. Hậu: RETIRED | P08 AC-E-Seat// retireFromSeatMap | Instance | SeatStateError |
| DC-Seat | ~ | SetType(t SeatType) error | Đổi loại ghế của ghế đang trong sơ đồ | Tiền: IN_MAP. Chỉ DC-Auditorium.ApplyChanges gọi | ST-07 sự kiện retype | Instance | SeatStateError |
| DC-Seat | + | Info() SeatInfo | Vị trí, loại ghế, trạng thái trong sơ đồ | - | P08 AC-E-Seat// provideSeatInfo | Instance | - |
| DC-Seat | + | ID() SeatId | Định danh | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-Seat | + | Type() SeatType | Loại ghế | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-Seat | + | InMap() bool | Ghế còn trong sơ đồ ghế | - | Bổ sung: quan sát hậu điều kiện (ST-07) | Instance | - |
| DC-Auditorium | + | CreateAuditorium(cinemaId CinemaId, d AuditoriumDraft, now time.Time) *Auditorium | Tạo phòng dự kiến cùng các ghế bằng Seat.NewSeat | Hậu: chưa lưu; chưa kiểm hợp lệ | P07 UC-012 msg 2.1.1 // createAuditorium | Classifier | - |
| DC-Auditorium | + | CheckAuditoriumInfoValid() error | Kiểm tên không trống, loại phòng thuộc ba loại, có 1 hoặc 2 định dạng, mỗi cặp (hàng, số ghế) tối đa một ghế, từng ghế hợp lệ (Seat.CheckSeatValid); gom điều kiện vi phạm theo trường | REQ-02, REQ-55. Hậu: không đổi | P08 AC-E-Auditorium// checkAuditoriumInfoValid | Instance | FieldInvalidError |
| DC-Auditorium | + | CalculateCapacity() int | Số ghế còn trong sơ đồ ghế; ghế đôi là một ghế | BR-06, GL-50 | P07 UC-012 msg 2.1.3.1, 2.1.8.1 // calculateCapacity | Instance | - |
| DC-Auditorium | + | CheckCapacityInRange() error | CalculateCapacity nằm trong [MinCapacity, MaxCapacity] | BR-144 | P07 UC-012 msg 2.1.3 // checkCapacityInRange | Instance | CapacityOutOfRangeError |
| DC-Auditorium | + | CheckBelongsToCinema(cinemaId CinemaId) error | Phòng thuộc cụm rạp của quản lý | BR-46, BR-135 | P07 UC-012 msg 2a.1.1; UC-014 msg 2.1.2 // checkBelongsToCinema | Instance | NotOwnCinemaError |
| DC-Auditorium | + | CheckSupportsFormat(f MovieFormat) error | f nằm trong formats của phòng | BR-48 | P07 UC-014 msg 2.1.5 // checkSupportsFormat | Instance | FormatNotSupportedError |
| DC-Auditorium | + | SeatTypes() []SeatType | Các loại ghế có ít nhất một ghế trong sơ đồ | BR-69 | P07 UC-014 msg 2.1.6 // provideSeatTypes | Instance | - |
| DC-Auditorium | + | Type() AuditoriumType | Loại phòng | - | Bổ sung: nguồn của PriceQuery và CheckCoversShowtime | Instance | - |
| DC-Auditorium | + | Info() AuditoriumInfo | Tên, loại, định dạng, sức chứa, số ghế theo loại, mốc thay đổi | - | P08 AC-E-Auditorium// provideAuditoriumInfo | Instance | - |
| DC-Auditorium | + | Detail() AuditoriumDetail | Info cùng từng ghế (Seat.Info) | - | P08 AC-E-Auditorium// provideAuditoriumDetail | Instance | - |
| DC-Auditorium | + | DraftShowtime(movieId MovieId, f MovieFormat, start, saleOpen time.Time) *Showtime | Tạo suất chiếu dự kiến của phòng bằng Showtime.NewShowtime (Creator) | Hậu: chưa lưu | P07 UC-014 msg 2.1.12 // draftShowtime | Instance | - |
| DC-Auditorium | + | CheckRoomGap(draft *Showtime, others []*Showtime, excludeId ShowtimeId) error | Với mỗi suất chiếu chưa xoá của others (trừ excludeId): draft.startTime >= other.endTime + RoomGap hoặc other.startTime >= draft.endTime + RoomGap | BR-51: bằng đúng 15 phút là hợp lệ. Tiền: draft.endTime đã tính | P07 UC-014 msg 2.1.17.4 // checkRoomGap | Instance | RoomGapError |
| DC-Auditorium | + | CheckUnchangedSinceDisplayed(displayedAt time.Time) error | So lastChangedAt với mốc lúc hiển thị | BR-146, Q-247 | P07 UC-012 msg 2.1.6a.1 | Instance | AuditoriumChangedError |
| DC-Auditorium | + | ComputeSeatMapChange(drafts []SeatDraft) SeatMapChange | So sơ đồ nhập với ghế đang trong sơ đồ theo vị trí (hàng, số ghế): vị trí mới --> added; vị trí không còn --> retired; vị trí giữ nhưng đổi loại --> retyped; Changed khi một trong ba khác rỗng | Hậu: không đổi. Vị trí của ghế đã bỏ được nhập lại thì thành ghế mới | P07 UC-012 msg 2.1.6a.3 // checkSeatMapChanged | Instance | - |
| DC-Auditorium | + | ProjectedSeatTypes(change SeatMapChange) []SeatType | Các loại ghế còn lại trong sơ đồ sau khi áp change | Hậu: không đổi | Bổ sung: đầu vào của Showtime.CheckStaysPriced (BR-73) | Instance | - |
| DC-Auditorium | + | ApplyChanges(d AuditoriumDraft, change SeatMapChange, now time.Time) | Ghi tên, loại, định dạng; thêm ghế mới (NewSeat); RetireFromSeatMap các ghế retired; SetType các ghế retyped; đặt lastChangedAt = now | Tiền: đã qua mọi kiểm. Hậu: sơ đồ khớp d | P07 UC-012 msg 2.1.11a // applyChanges | Instance | - |
| DC-Auditorium | + | CheckNeverScheduled(everScheduled bool) error | everScheduled (có suất chiếu, kể cả đã xoá) thì từ chối | BR-147. Tiền: Auditorium X đã khoá | P07 UC-012 msg 2b.1.2.1 // checkNeverScheduled | Instance | AuditoriumHasScheduleError |
| DC-Auditorium | + | ID() AuditoriumId | Định danh | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-Auditorium | + | CinemaId() CinemaId | Cụm rạp chứa phòng (R-38) | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-Auditorium | + | InMapSeatIds() []SeatId | Mã các ghế đang trong sơ đồ | - | Bổ sung: đầu vào của Showtime.AdoptSeatMap | Instance | - |

F2.PKG-27 phần DC-Showtime, DC-PriceList, DC-PriceEntry

| DC | Visibility | Chữ ký | Mô tả | Tiền/hậu điều kiện | Nguồn (message P07 / UC bước) | Phạm vi | Ngoại lệ / lỗi |
|---|---|---|---|---|---|---|---|
| DC-Showtime | + | NewShowtime(movieId MovieId, f MovieFormat, auditoriumId AuditoriumId, start, saleOpen time.Time) *Showtime | Tạo suất chiếu dự kiến, status IN_SCHEDULE | Hậu: chưa lưu, endTime chưa tính; id và lastChangedAt gán khi lưu | P07 UC-014 msg 2.1.12.1 // createShowtime | Classifier | - |
| DC-Showtime | + | CheckNotStarted(now time.Time) error | Giờ bắt đầu sau now | BR-56 (lập), BR-57 (sửa, xoá), BR-45. Hậu: không đổi | P07 UC-014 msg 2.1.12.1.1, 1a.2.1.1 // checkStartAfter, checkNotStarted | Instance | ShowtimeStartedError |
| DC-Showtime | + | CheckSaleOpenBeforeStart() error | saleOpenTime trước startTime | BR-55 | P07 UC-014 msg 2.1.12.1.2 // checkSaleOpenBeforeStart | Instance | SaleOpenOrderError |
| DC-Showtime | + | CalculateEndTime(d time.Duration) | endTime = startTime + d | BR-50. Hậu: endTime đặt | P07 UC-014 msg 2.1.16 // calculateEndTime | Instance | - |
| DC-Showtime | + | RecheckMovie(movie *Movie) error | Với phim hiện hành: CheckReleasedInFormat(format), CheckWithinRunPeriod(startTime), rồi CalculateEndTime(movie.Duration()) | BR-47, BR-49, BR-50, BR-139. Tiền: movie đã khoá hạng 10 S. Hậu: endTime theo thời lượng hiện hành | P07 UC-014 msg 2.1.17.2 // recheckMovie | Instance | FormatNotReleasedError, OutsideRunPeriodError |
| DC-Showtime | + | CheckRoomChangeAllowed(targetId AuditoriumId, everHadTicket bool) error | targetId khác auditoriumId hiện tại mà everHadTicket (kể cả vé đã huỷ) thì từ chối | BR-92. Tiền: Showtime X và vé đã khoá S. Hậu: không đổi | P07 UC-014 msg 2.1.17[1a].4 // checkRoomChangeAllowed | Instance | RoomChangeNotAllowedError |
| DC-Showtime | + | ApplyChanges(draft *Showtime, now time.Time) | Ghi phim, định dạng, phòng, giờ bắt đầu, mở bán, giờ kết thúc từ draft và đặt lastChangedAt = now | BR-84. Tiền: đã qua mọi kiểm. Hậu: ST-06 sự kiện applyChanges | P07 UC-014 msg 2.1.17[1a].9 // applyChanges | Instance | ShowtimeChangedError (khi Đã xoá) |
| DC-Showtime | + | MarkDeleted(now time.Time) error | Chuyển status DELETED, đặt lastChangedAt = now; dữ liệu giữ lại | BR-58. Tiền: IN_SCHEDULE. Hậu: Đã xoá | P07 UC-014 msg 1b.2.1.1.4 // markDeleted | Instance | ShowtimeChangedError |
| DC-Showtime | + | UsesPriceEntry(combo PriceCombo, room *Auditorium, now time.Time) bool | Chưa xoá, chưa tới giờ bắt đầu, room.Type() = combo.auditoriumType, format = combo.movieFormat, DetermineTimeBand(startTime) = combo.timeBand và room.SeatTypes() chứa combo.seatType | BR-64, BR-68. Hậu: không đổi | P07 UC-013 msg 2a.1.1.2 // checkUsesPriceEntry | Instance | - |
| DC-Showtime | + | BlocksSeatMapEdit(now time.Time) bool | Chưa xoá, saleOpenTime <= now và now < endTime | BR-87, Q-209, Q-250. Hậu: không đổi | P07 UC-012 msg 2.1.6a.4 // checkBlocksSeatMapEdit | Instance | - |
| DC-Showtime | + | CheckStaysPriced(list *PriceList, t AuditoriumType, seatTypes []SeatType, now time.Time) error | Chưa xoá và chưa tới giờ bắt đầu thì list.CheckCoversShowtime(t, format, seatTypes, startTime); ngược lại hợp lệ | BR-73, BR-69, Q-250 | P07 UC-012 msg 2.1.6a.5 // checkStaysPriced | Instance | PriceNotCoveredError |
| DC-Showtime | + | AdoptSeatMap(inMapSeatIds, existingSeatIds []SeatId, now time.Time) SeatMapDelta | Suất chiếu chưa xoá và chưa mở bán (saleOpenTime > now): addedSeatIds = inMapSeatIds trừ existingSeatIds, removedSeatIds = existingSeatIds trừ inMapSeatIds; ngược lại trả delta rỗng | BR-118, Q-249. Không gọi PKG-28; việc ghi do DC-ManageAuditoriumsService | P07 UC-012 msg 2.1.11a.1 // adoptSeatMap | Instance | - |
| DC-Showtime | + | Phase(now time.Time) ShowtimePhase | Giai đoạn suy ra từ saleOpenTime, startTime, endTime và now; chỉ có nghĩa khi status IN_SCHEDULE | ST-06. Hậu: không đổi | Bổ sung: quan sát hậu điều kiện (ST-06) | Instance | - |
| DC-Showtime | + | AuditoriumId() AuditoriumId | Phòng chiếu (R-42) | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-Showtime | + | MovieId() MovieId | Phim (R-43) | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-Showtime | + | Format() MovieFormat | Định dạng chiếu | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-Showtime | + | SaleOpenTime() time.Time | Thời điểm mở bán | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-Showtime | + | EndTime() time.Time | Giờ kết thúc | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-PriceList | + | NewPriceList(cinemaId CinemaId) *PriceList | Tạo bảng giá rỗng của cụm rạp | R-40. Hậu: không có mục giá | P08 F2c (EX-17) | Classifier | - |
| DC-PriceList | + | CinemaId() CinemaId | Cụm rạp (R-40) | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-PriceList | + | ProvideEntries() []PriceEntryInfo | Các mục giá chưa bỏ kèm mốc từng mục | BR-62. Hậu: không đổi | P07 UC-013 msg 1.1.2, 1a.1.2 // providePriceEntries | Instance | - |
| DC-PriceList | + | CheckTicketPriceValid(price int64) error | price > 0 | BR-70 | P07 UC-013 msg 2.1.1 // checkTicketPriceValid | Instance | TicketPriceInvalidError |
| DC-PriceList | + | CheckEntryUnchangedSinceDisplayed(combo PriceCombo, displayedAt time.Time) error | Mốc của mục giá của combo (kể cả mục đã bỏ; time.Time rỗng nếu chưa từng có) bằng displayedAt | BR-63 | P07 UC-013 msg 2.1.3.1, 2a.1.1.1 | Instance | PriceEntryChangedError |
| DC-PriceList | + | SavePriceEntry(combo PriceCombo, price Money, displayedAt, now time.Time) (*PriceEntry, error) | Kiểm mốc, tìm hoặc tạo mục giá của combo (mục đã bỏ thì dùng lại), SetTicketPrice | BR-62, BR-63, BR-66, BR-71. Tiền: PriceList X đã khoá. Hậu: có hiệu lực ngay; giá đã chốt của lần giữ ghế và vé không đổi (BR-65, BR-67) | P07 UC-013 msg 2.1.3 // savePriceEntry | Instance | PriceEntryChangedError |
| DC-PriceList | - | findOrCreatePriceEntry(combo PriceCombo) *PriceEntry | Trả mục giá của combo, chưa có thì tạo mục mới rỗng giá | BR-62 | P07 UC-013 msg 2.1.3.2 | Instance | - |
| DC-PriceList | + | RemovePriceEntry(combo PriceCombo, displayedAt, now time.Time, showtimes []*Showtime, rooms map[AuditoriumId]*Auditorium) error | CheckEntryUnchangedSinceDisplayed trước; rồi nếu một suất chiếu của showtimes UsesPriceEntry(combo, rooms[auditoriumId], now) thì từ chối; rồi deletePriceEntry | BR-63, BR-64, BR-68, BR-71, BR-136. Tiền: PriceList X, Auditorium S, Showtime S đã khoá. Thứ tự kiểm 1a3a trước 1a3b | P07 UC-013 msg 2a.1.1 // removePriceEntry | Instance | PriceEntryChangedError, PriceEntryInUseError |
| DC-PriceList | - | deletePriceEntry(combo PriceCombo, now time.Time) | PriceEntry.markRemoved(now) cho mục của combo | BR-71. Hậu: mục đã bỏ, mốc = now | P07 UC-013 msg 2a.1.1.3 // deletePriceEntry | Instance | - |
| DC-PriceList | + | DetermineTimeBand(start time.Time) TimeBand | Đổi start sang Asia/Ho_Chi_Minh: thứ Hai đến thứ Sáu là ngày thường, thứ Bảy, Chủ nhật là cuối tuần; trước 17:00 hoặc từ 17:00 | BR-12, Q-268. Thuần tính toán; nơi duy nhất xác định khung giờ | P07 UC-013 msg 2a.1.1.2.1 // determineTimeBand | Classifier | - |
| DC-PriceList | + | CheckCoversShowtime(t AuditoriumType, f MovieFormat, seatTypes []SeatType, start time.Time) error | Với mỗi loại ghế của seatTypes phải có mục giá chưa bỏ của (t, f, seatType, DetermineTimeBand(start)); thiếu thì báo tổ hợp đầu tiên thiếu | BR-68, BR-69, BR-12. Hậu: không đổi | P07 UC-014 msg 2.1.7, 2.1.17.3; UC-012 msg 2.1.6a.5.1 // checkCoversShowtime | Instance | PriceNotCoveredError |
| DC-PriceEntry | + | Info() PriceEntryInfo | Tổ hợp, giá, mốc, cờ đã bỏ | - | P08 AC-E-PriceEntry// provideEntryInfo | Instance | - |
| DC-PriceEntry | + | Combo() PriceCombo | Tổ hợp bốn yếu tố | BR-62 | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-PriceEntry | + | SetTicketPrice(price Money, now time.Time) | Ghi giá, bỏ cờ đã bỏ, đặt lastChangedAt = now | BR-65, BR-67. Hậu: ST không áp dụng (Vấn đề còn mở 4) | P07 UC-013 msg 2.1.3.3 // setTicketPrice | Instance | - |
| DC-PriceEntry | ~ | markRemoved(now time.Time) | Đặt removed = true và lastChangedAt = now | BR-71. Chỉ DC-PriceList gọi | P07 UC-013 msg 2a.1.1.3 | Instance | - |

F2.PKG-27 phần interface kho (đã có ở lõi: FindRouting, LockShared, FindByID, FindInfo của IF-11; LockSharedByCinema của IF-12; LockAuditoriumShared, FindSeats của IF-13)

| DC | Visibility | Chữ ký | Mô tả | Tiền/hậu điều kiện | Nguồn (message P07 / UC bước) | Phạm vi | Ngoại lệ / lỗi |
|---|---|---|---|---|---|---|---|
| IF-11 | + | LockExclusive(ctx Ctx, tx Tx, id ShowtimeId) (*Showtime, error) | SELECT FOR NO KEY UPDATE dòng suất chiếu (hạng 3) | Hạng 3 | P10 F3a EX-13, EX-14 | Instance | NotFoundError, SystemBusyError |
| IF-11 | + | LockSharedByAuditorium(ctx Ctx, tx Tx, auditoriumId AuditoriumId) ([]*Showtime, error) | SELECT ORDER BY mã FOR SHARE mọi suất chiếu của phòng, kể cả đã xoá, không lọc trạng thái | Hạng 3 | P10 F3a EX-15 | Instance | SystemBusyError |
| IF-11 | + | LockSharedNotStartedByCinema(ctx Ctx, tx Tx, cinemaId CinemaId, after time.Time) ([]*Showtime, error) | SELECT ORDER BY mã FOR SHARE các suất chiếu chưa xoá của cụm rạp có startTime > after (after = Tx.Now lấy sau khoá hạng 1) | Hạng 3. Lọc theo thời gian là tập cận trên; kiểm đúng nằm ở Showtime.UsesPriceEntry | P10 F3a EX-12 | Instance | SystemBusyError |
| IF-11 | + | FindInScheduleByAuditorium(ctx Ctx, tx Tx, auditoriumId AuditoriumId) ([]*Showtime, error) | Đọc không khoá các suất chiếu chưa xoá của phòng | Hậu: không khoá. Auditorium X đã giữ nên không có suất chiếu mới xen vào (P09 F7.3 EX-13) | P07 UC-014 msg 2.1.17.4 // checkRoomGap | Instance | - |
| IF-11 | + | ExistsByAuditorium(ctx Ctx, tx Tx, auditoriumId AuditoriumId) (bool, error) | SELECT 1 ... LIMIT 1, không lọc trạng thái | Hậu: không khoá | P08 AC-E-Auditorium// checkNeverScheduled | Instance | - |
| IF-11 | + | Insert(ctx Ctx, tx Tx, s *Showtime) error | Thêm suất chiếu, gán id và lastChangedAt = Tx.Now; EXCLUDE về khoảng cách phòng là lưới an toàn | Tiền: Auditorium X đã khoá | P07 UC-014 msg 2.1.17.5 // addToSchedule | Instance | lỗi ràng buộc |
| IF-11 | + | Update(ctx Ctx, tx Tx, s *Showtime) error | UPDATE các cột đổi được theo khoá chính | Tiền: Showtime X đã khoá | P08 AC-E-Showtime// applyChanges, markDeleted | Instance | lỗi ràng buộc |
| IF-11 | + | ListByCinema(ctx Ctx, cinemaId CinemaId) ([]ShowtimeListItem, error) | Đọc join không khoá các suất chiếu chưa xoá của cụm rạp, sắp theo giờ bắt đầu | Hậu: không khoá | P08 AC-E-Showtime// provideShowtimeInfo (UC-014) | Instance | - |
| IF-11 | + | FindListItem(ctx Ctx, tx Tx, id ShowtimeId) (ShowtimeListItem, error) | Đọc join một suất chiếu | Hậu: không khoá | P07 UC-014 msg 2.1.22 // provideShowtimeInfo | Instance | NotFoundError |
| IF-11 | + | ListInfoByMovie(ctx Ctx, movieId MovieId) ([]ShowtimeInfo, error) | Đọc join một lần các suất chiếu của phim cùng phòng, cụm rạp, định dạng, thời điểm mở bán và trạng thái | Hậu: không khoá; thứ tự theo giờ bắt đầu rồi tên cụm rạp, tên phòng (Q-302) | P07 UC-004 msg 2.1.1 đến 2.1.4 | Instance | - |
| IF-11 | + | ListInfoByCinema(ctx Ctx, cinemaId CinemaId) ([]ShowtimeInfo, error) | Như ListInfoByMovie cho các suất chiếu của một cụm rạp | Hậu: không khoá; thứ tự như ListInfoByMovie | P07 UC-004 msg 1a.2.1.1 đến 1a.2.1.6 | Instance | - |
| IF-12 | + | LockExclusiveByCinema(ctx Ctx, tx Tx, cinemaId CinemaId) (*PriceList, error) | SELECT FOR NO KEY UPDATE dòng bảng giá kèm mọi mục giá, kể cả mục đã bỏ (hạng 1) | Hạng 1 | P10 F3a EX-11, EX-12 | Instance | NotFoundError, SystemBusyError |
| IF-12 | + | FindByCinema(ctx Ctx, cinemaId CinemaId) (*PriceList, error) | Đọc không khoá bảng giá kèm mục giá để hiển thị | Hậu: không khoá | P07 UC-013 msg 1.1.2 | Instance | NotFoundError |
| IF-12 | + | SaveEntry(ctx Ctx, tx Tx, cinemaId CinemaId, e *PriceEntry) error | INSERT hoặc UPDATE mục giá theo khoá (cụm rạp, tổ hợp) | Tiền: hạng 1 X đã giữ | P08 AC-E-PriceList// savePriceEntry, deletePriceEntry | Instance | lỗi ràng buộc |
| IF-12 | + | Insert(ctx Ctx, tx Tx, pl *PriceList) error | INSERT bảng giá rỗng của cụm rạp mới | Cùng giao dịch với InsertCinema (EX-17) | P08 F2c; P10 F3a EX-17 | Instance | lỗi ràng buộc |
| IF-13 | + | LockCinemaExclusive(ctx Ctx, tx Tx, id CinemaId) (*Cinema, error) | SELECT FOR NO KEY UPDATE dòng cụm rạp (hạng 0) | Hạng 0. Sau khoá giá trị tên khi EX-17 | P10 F3a EX-15, EX-17, EX-18, EX-19 | Instance | NotFoundError, SystemBusyError |
| IF-13 | + | FindCinema(ctx Ctx, id CinemaId) (*Cinema, error) | Đọc không khoá một cụm rạp | Hậu: không khoá | P08 AC-E-Cinema// provideCinemaInfo | Instance | NotFoundError |
| IF-13 | + | ListCinemas(ctx Ctx) ([]*Cinema, error) | Đọc không khoá mọi cụm rạp | Hậu: không khoá. Q-246: bên gọi lặp | P08 AC-E-Cinema// provideCinemaInfo (UC-011) | Instance | - |
| IF-13 | + | FindCinemaByNormalizedName(ctx Ctx, tx Tx, name string) (*Cinema, error) | Đọc không khoá cụm rạp có norm_name trùng name | Tiền: đã giữ khoá giá trị tên | P08 AC-E-Cinema// checkNameTaken | Instance | NotFoundError |
| IF-13 | + | InsertCinema(ctx Ctx, tx Tx, c *Cinema) error | Thêm cụm rạp, gán id | Chỉ mục unique theo tên chuẩn hoá là lưới an toàn | P08 AC-E-Cinema// addToCinemaList | Instance | lỗi unique |
| IF-13 | + | SaveCinema(ctx Ctx, tx Tx, c *Cinema) error | UPDATE tên, tỉnh, địa chỉ, mốc | Tiền: hạng 0 X đã giữ | P08 AC-E-Cinema// saveCinemaChanges | Instance | lỗi unique |
| IF-13 | + | LockAuditoriumsExclusive(ctx Ctx, tx Tx, ids []AuditoriumId) ([]*Auditorium, error) | SELECT ORDER BY mã FOR NO KEY UPDATE các phòng kèm ghế; ids tăng dần, thiếu dòng nào thì NotFoundError | Hạng 2 | P10 F3a EX-13, EX-15 | Instance | NotFoundError, SystemBusyError |
| IF-13 | + | LockAuditoriumForDelete(ctx Ctx, tx Tx, id AuditoriumId) (*Auditorium, error) | SELECT FOR UPDATE phòng kèm ghế (có DELETE nên cần FOR UPDATE) | Hạng 2 (P09 F7.3 EX-19) | P10 F3a EX-19 | Instance | NotFoundError, SystemBusyError |
| IF-13 | + | LockAuditoriumsShared(ctx Ctx, tx Tx, cinemaId CinemaId) ([]*Auditorium, error) | SELECT ORDER BY mã FOR SHARE mọi phòng của cụm rạp kèm ghế | Hạng 2 | P10 F3a EX-12 | Instance | SystemBusyError |
| IF-13 | + | ListAuditoriums(ctx Ctx, cinemaId CinemaId) ([]*Auditorium, error) | Đọc không khoá các phòng của cụm rạp kèm ghế | Hậu: không khoá | P08 AC-E-Cinema// provideAuditoriums | Instance | - |
| IF-13 | + | ListAuditoriumRefs(ctx Ctx, tx Tx, cinemaId CinemaId) ([]AuditoriumRef, error) | Đọc không khoá mã và tên các phòng của cụm rạp | Tiền: Cinema X đã khoá | P08 AC-E-Cinema// checkAuditoriumNameAvailable | Instance | - |
| IF-13 | + | FindAuditorium(ctx Ctx, id AuditoriumId) (*Auditorium, error) | Đọc không khoá phòng kèm ghế | Hậu: không khoá | P07 UC-012 msg 2a.1.2; UC-014 msg 1a.2.1.6 | Instance | NotFoundError |
| IF-13 | + | InsertAuditorium(ctx Ctx, tx Tx, a *Auditorium) error | Thêm phòng rồi các ghế, gán id | Tiền: Cinema X đã khoá. Chỉ mục unique (cụm rạp, tên chuẩn hoá) là lưới an toàn | P08 AC-E-Cinema// addAuditorium | Instance | lỗi unique |
| IF-13 | + | SaveAuditorium(ctx Ctx, tx Tx, a *Auditorium) error | UPDATE phòng; INSERT ghế mới; UPDATE cờ mapState, loại của ghế đã đổi | Tiền: hạng 2 X đã giữ | P08 AC-E-Auditorium// applyChanges | Instance | lỗi ràng buộc |
| IF-13 | + | DeleteAuditorium(ctx Ctx, tx Tx, id AuditoriumId) error | DELETE các ghế rồi phòng cùng giao dịch | Tiền: hạng 2 FOR UPDATE đã giữ. Khoá ngoại không CASCADE là lưới an toàn (23503) | P08 AC-E-Cinema// removeAuditorium | Instance | lỗi ràng buộc |
| IF-14 | + | LockShared(ctx Ctx, tx Tx, id MovieId) (*Movie, error) | SELECT FOR SHARE dòng phim (hạng 10) | Hạng 10 | P10 F3a EX-13 | Instance | NotFoundError, SystemBusyError |
| IF-14 | + | LockExclusive(ctx Ctx, tx Tx, id MovieId) (*Movie, error) | SELECT FOR NO KEY UPDATE dòng phim (hạng 10) | Hạng 10 | P10 F3a EX-16 | Instance | NotFoundError, SystemBusyError |
| IF-14 | + | FindByID(ctx Ctx, id MovieId) (*Movie, error) | Đọc không khoá | Hậu: không khoá | P08 AC-E-Movie// provideMovieInfo | Instance | NotFoundError |
| IF-14 | + | List(ctx Ctx) ([]*Movie, error) | Đọc không khoá mọi phim | Hậu: không khoá. Q-246 | P07 UC-014 msg 1.1.3 // provideMovieInfo | Instance | - |
| IF-14 | + | Insert(ctx Ctx, tx Tx, m *Movie) error | Thêm phim, gán id | Không là EX (Q-200) | P08 AC-E-Movie// addToMovieList | Instance | - |
| IF-14 | + | Save(ctx Ctx, tx Tx, m *Movie) error | UPDATE phim | Tiền: hạng 10 X đã giữ | P08 AC-E-Movie// saveMovieChanges | Instance | - |
| IF-29 | + | FindHoldsByShowtime(ctx Ctx, tx Tx, showtimeId ShowtimeId) ([]*SeatHold, error) | Đọc không khoá các lần giữ ghế của suất chiếu | Hậu: không khoá | P08 AC-E-Showtime// checkNoActiveHoldOrSoldTicket | Instance | - |
| IF-29 | + | FindTicketsByShowtime(ctx Ctx, tx Tx, showtimeId ShowtimeId) ([]*Ticket, error) | Đọc không khoá mọi vé của suất chiếu, kể cả đã huỷ | Hậu: không khoá | P08 AC-E-Showtime// checkNoActiveHoldOrSoldTicket | Instance | - |
| IF-29 | + | LockHoldsSharedByShowtime(ctx Ctx, tx Tx, showtimeId ShowtimeId) ([]*SeatHold, error) | SELECT ORDER BY mã FOR SHARE mọi lần giữ ghế của suất chiếu, không lọc trạng thái | Hạng 5 | P10 F3a EX-13, EX-14 | Instance | SystemBusyError |
| IF-29 | + | LockTicketsSharedByShowtime(ctx Ctx, tx Tx, showtimeId ShowtimeId) ([]*Ticket, error) | SELECT ORDER BY mã FOR SHARE mọi vé của suất chiếu, không lọc trạng thái | Hạng 8 | P10 F3a EX-13, EX-14 | Instance | SystemBusyError |
| IF-29 | + | LockSeatStatusesByShowtimes(ctx Ctx, tx Tx, showtimeIds []ShowtimeId) ([]*SeatStatus, error) | SELECT ORDER BY (mã suất chiếu, mã ghế) FOR UPDATE; FOR UPDATE ngay từ đầu vì có câu DELETE (P09 F7.3 EX-13, EX-15) | Hạng 6 | P10 F3a EX-13, EX-15 | Instance | SystemBusyError |
| IF-29 | + | DeleteSeatStatuses(ctx Ctx, tx Tx, keys []SeatKey) error | DELETE trạng thái ghế theo khoá chính | Tiền: hạng 6 đã giữ; ghế đã Trống (EX-13 giải phóng trước), hoặc ghế bỏ khỏi sơ đồ của suất chiếu chưa mở bán | P08 AC-E-Showtime// adoptSeatMap | Instance | lỗi ràng buộc |

F2.PKG-16 lớp dịch vụ

| DC | Visibility | Chữ ký | Mô tả | Tiền/hậu điều kiện | Nguồn (message P07 / UC bước) | Phạm vi | Ngoại lệ / lỗi |
|---|---|---|---|---|---|---|---|
| DC-ManagePriceListService | + | GetPriceList(ctx Ctx, actor ActorContext) (PriceListView, error) | Đọc bảng giá của cụm rạp của actor và trả các mục giá kèm mốc | Tiền: actor là quản lý cụm rạp (đã kiểm ở PKG-19). Hậu: không khoá | P08 AC-C-ManagePriceListController// startPriceListSetup, startPriceRemoval | Instance | NotFoundError |
| DC-ManagePriceListService | + | SubmitPriceEntry(ctx Ctx, actor ActorContext, req PriceEntryRequest) (PriceEntryInfo, error) | Kiểm giá hợp lệ rồi, trong một giao dịch EX-11, lưu mục giá của tổ hợp | BR-62, BR-63, BR-66, BR-70, BR-71. Hậu: mục giá có hiệu lực ngay, hoặc không đổi | P08 AC-C-ManagePriceListController// submitPriceEntry | Instance | TicketPriceInvalidError, PriceEntryChangedError, SystemBusyError |
| DC-ManagePriceListService | + | SubmitPriceEntryRemoval(ctx Ctx, actor ActorContext, req RemovePriceEntryRequest) error | Trong một giao dịch EX-12, bỏ mục giá của tổ hợp khi chưa bị đổi và không còn suất chiếu đang dùng | BR-63, BR-64, BR-68, BR-71 | P08 AC-C-ManagePriceListController// submitPriceEntryRemoval | Instance | PriceEntryChangedError, PriceEntryInUseError, SystemBusyError |
| DC-ScheduleShowtimesService | + | StartScheduling(ctx Ctx, actor ActorContext) (ScheduleFormData, error) | Lấy các phòng chiếu của cụm rạp của actor và mọi phim để hiển thị | BR-46. Hậu: không khoá | P08 AC-C-ScheduleShowtimesController// startScheduling | Instance | - |
| DC-ScheduleShowtimesService | + | ListShowtimes(ctx Ctx, actor ActorContext) ([]ShowtimeListItem, error) | Các suất chiếu chưa xoá của cụm rạp, kèm mốc thay đổi để dùng làm mốc lúc hiển thị | BR-46, BR-60. Hậu: không khoá | P08 AC-C-ScheduleShowtimesController// startEditingShowtime, startDeletingShowtime | Instance | - |
| DC-ScheduleShowtimesService | + | PrepareShowtimeEdit(ctx Ctx, actor ActorContext, id ShowtimeId) (ShowtimeEditView, error) | Kiểm suất chiếu thuộc cụm rạp, chưa tới giờ bắt đầu, không có lần giữ ghế hiệu lực và vé chưa huỷ; rồi trả dữ liệu để sửa | BR-57, BR-53; kiểm trước 1a3b rồi 1a3a. Hậu: không khoá (kiểm lại dưới khoá ở UpdateShowtime) | P08 AC-C-ScheduleShowtimesController// prepareShowtimeEdit | Instance | ShowtimeStartedError, ShowtimeInUseError, NotFoundError, NotOwnCinemaError |
| DC-ScheduleShowtimesService | + | CreateShowtime(ctx Ctx, actor ActorContext, req NewShowtimeRequest) (ShowtimeListItem, error) | Một giao dịch EX-13: kiểm điều kiện lập, kiểm khoảng cách phòng, ghi suất chiếu và tạo trạng thái ghế Trống cho mọi ghế trong sơ đồ | BR-46 đến BR-52, BR-55, BR-56, BR-69, BR-139, BR-147. Hậu: suất chiếu và SeatStatus cùng commit hoặc không có gì | P08 AC-C-ScheduleShowtimesController// requestSaveShowtime | Instance | NotOwnCinemaError, FormatNotReleasedError, FormatNotSupportedError, PriceNotCoveredError, OutsideRunPeriodError, ShowtimeStartedError, SaleOpenOrderError, AuditoriumGoneError, RoomGapError, SystemBusyError |
| DC-ScheduleShowtimesService | + | UpdateShowtime(ctx Ctx, actor ActorContext, req UpdateShowtimeRequest) (ShowtimeListItem, error) | Một giao dịch EX-13: kiểm suất chiếu chưa đổi, chưa bắt đầu, không bị dùng, đổi phòng phải hợp lệ, kiểm lại điều kiện lập, rồi ghi; đổi phòng thì thay tập trạng thái ghế | BR-53, BR-57, BR-60, BR-92, và các BR của CreateShowtime. Hậu: không ghế nào khác Trống sau khi đổi phòng | P08 AC-C-ScheduleShowtimesController// requestSaveShowtime | Instance | ShowtimeChangedError, ShowtimeStartedError, ShowtimeInUseError, RoomChangeNotAllowedError, và các lỗi của CreateShowtime |
| DC-ScheduleShowtimesService | + | DeleteShowtime(ctx Ctx, actor ActorContext, id ShowtimeId, displayedAt time.Time) error | Một giao dịch EX-14: kiểm chưa đổi, chưa bắt đầu, không bị dùng rồi đánh dấu Đã xoá | BR-53, BR-57, BR-58, BR-60. Thứ tự kiểm 1b3c, 1b3b, 1b3a. Hậu: SeatStatus không đổi (EX-05, EX-06 vẫn chạy) | P08 AC-C-ScheduleShowtimesController// deleteShowtime | Instance | ShowtimeChangedError, ShowtimeStartedError, ShowtimeInUseError, NotOwnCinemaError, SystemBusyError |
| DC-ScheduleShowtimesService | - | checkNoActiveHoldOrSoldTicket(holds []*SeatHold, tickets []*Ticket, now time.Time) error | Có SeatHold.IsActiveAt(now) hoặc Ticket chưa IsCancelled thì từ chối | BR-53. Nơi duy nhất định nghĩa điều kiện (Showtime không gọi PKG-28) | P08 AC-E-Showtime// checkNoActiveHoldOrSoldTicket | Instance | ShowtimeInUseError |
| DC-ScheduleShowtimesService | - | replaceSeatStatuses(ctx Ctx, tx Tx, showtime *Showtime, room *Auditorium) error | Khoá trạng thái ghế cũ của suất chiếu (IF-29), giải phóng ghế còn dở bằng ReleaseHold, SaveChanges, xoá tập cũ, InsertAll tập của room | BR-53, BR-92, Q-109. Tiền: không lần giữ ghế hiệu lực, chưa từng có vé. Hậu: mọi ghế mới Trống | P08 F4b EX-13 (giải phóng ghế còn dở) | Instance | SystemBusyError |
| DC-ManageAuditoriumsService | + | ListAuditoriums(ctx Ctx, actor ActorContext) ([]AuditoriumInfo, error) | Các phòng chiếu của cụm rạp của actor kèm sức chứa và mốc | BR-135. Hậu: không khoá | P08 AC-C-ManageAuditoriumsController// startAuditoriumAddition, startAuditoriumEdit, startAuditoriumRemoval | Instance | - |
| DC-ManageAuditoriumsService | + | SelectAuditorium(ctx Ctx, actor ActorContext, id AuditoriumId) (AuditoriumDetail, error) | Kiểm phòng thuộc cụm rạp của actor rồi trả thông tin và từng ghế để sửa | BR-135 (luồng 1a2a). Hậu: không khoá | P08 AC-C-ManageAuditoriumsController// selectAuditorium | Instance | NotFoundError, NotOwnCinemaError |
| DC-ManageAuditoriumsService | + | AddAuditorium(ctx Ctx, actor ActorContext, d AuditoriumDraft) (AuditoriumInfo, error) | Tạo phòng dự kiến, kiểm hợp lệ và sức chứa (ngoài giao dịch), rồi một giao dịch EX-18 kiểm tên và ghi phòng cùng ghế | BR-144, BR-145, REQ-55. Thứ tự 4a, 4b, 4d. Hậu: phòng và ghế cùng commit | P08 AC-C-ManageAuditoriumsController// submitAuditorium (luồng chính) | Instance | FieldInvalidError, CapacityOutOfRangeError, AuditoriumNameTakenError, SystemBusyError |
| DC-ManageAuditoriumsService | + | EditAuditorium(ctx Ctx, actor ActorContext, req EditAuditoriumRequest) (AuditoriumInfo, error) | Kiểm hợp lệ và sức chứa (ngoài giao dịch), rồi một giao dịch EX-15 kiểm 5c, 4d, 5a, 5b và ghi phòng, ghế và trạng thái ghế của suất chiếu chưa mở bán | BR-73, BR-87, BR-118, BR-144, BR-145, BR-146. Hậu: tất cả hoặc không gì | P08 AC-C-ManageAuditoriumsController// submitAuditorium (luồng 1a) | Instance | FieldInvalidError, CapacityOutOfRangeError, NotOwnCinemaError, AuditoriumGoneError, AuditoriumChangedError, AuditoriumNameTakenError, AuditoriumBlockedError, PriceNotCoveredError, SystemBusyError |
| DC-ManageAuditoriumsService | + | RemoveAuditorium(ctx Ctx, actor ActorContext, id AuditoriumId) error | Một giao dịch EX-19: kiểm phòng thuộc cụm rạp, chưa từng có suất chiếu rồi xoá phòng cùng ghế | BR-135, BR-147, BR-136. Hậu: phòng và ghế cùng bị xoá hoặc không gì | P08 AC-C-ManageAuditoriumsController// submitAuditoriumRemoval | Instance | AuditoriumGoneError, NotOwnCinemaError, AuditoriumHasScheduleError, SystemBusyError |
| DC-ManageAuditoriumsService | - | applySeatMapToShowtimes(ctx Ctx, tx Tx, room *Auditorium, showtimes []*Showtime, now time.Time) error | Với từng suất chiếu chưa mở bán: khoá trạng thái ghế (IF-29), tính AdoptSeatMap, DeleteSeatStatuses ghế bỏ, InsertAll ghế mới | BR-118, Q-249. Tiền: phòng đã SaveAuditorium để ghế mới có id | P08 AC-E-Showtime// adoptSeatMap | Instance | SystemBusyError |

## F3. Bảng thiết kế method

Mọi EX của PKG-16 là đúng một giao dịch (P09 F7.10), nên dòng "Nếu dừng tại đây" của mỗi operation ghi: tiến trình dừng thì giao dịch rollback, không để lại trạng thái dở và không cần ai đi tiếp. Quy ước: hàm fn của IF-08.Do có thể chạy lại từ đầu sau 40P01 hoặc 55P03 nên đặt lại biến kết quả ở đầu fn; mọi khoá lấy qua interface kho theo đúng thứ tự hạng, DC-LockOrderGuard kiểm.

| DC.operation | Thuật toán / các bước chính | Đối tượng và operation khác được dùng | Cách dùng thuộc tính, tham số, quan hệ | Hành vi theo trạng thái (nếu có ST) |
|---|---|---|---|---|
| DC-ManagePriceListService.SubmitPriceEntry | 1. Ngoài giao dịch: list = IF-12.FindByCinema(actor.cinemaId) (không khoá); list.CheckTicketPriceValid(req.ticketPrice) (4a).<br>2. Do(UserTx("SavePriceEntry"), fn).<br>3. fn: IF-12.LockExclusiveByCinema (hạng 1 X), now = tx.Now.<br>4. list.SavePriceEntry(req.combo, Money(req.ticketPrice), req.displayedAt, now): kiểm mốc (5a) rồi tạo hoặc đổi giá.<br>5. IF-12.SaveEntry(tx, cinemaId, entry); trả entry.Info().<br>Nếu dừng tại đây: rollback, bảng giá không đổi, không ai đi tiếp | IF-12, IF-08, DC-PriceList, DC-PriceEntry | cinemaId lấy từ actor, không nhận từ trình duyệt | - |
| DC-ManagePriceListService.SubmitPriceEntryRemoval | 1. Do(UserTx("RemovePriceEntry"), fn).<br>2. fn: IF-12.LockExclusiveByCinema (1 X); IF-13.LockAuditoriumsShared (2 S, tăng dần mã); now = tx.Now; IF-11.LockSharedNotStartedByCinema(cinemaId, now) (3 S).<br>3. rooms = map mã --> phòng; list.RemovePriceEntry(req.combo, req.displayedAt, now, showtimes, rooms): kiểm mốc (1a3a) trước, kiểm suất chiếu đang dùng (1a3b) sau, rồi đánh dấu đã bỏ.<br>4. IF-12.SaveEntry cho mục đã bỏ.<br>Nếu dừng tại đây: rollback, mục giá còn nguyên | IF-12, IF-13, IF-11, DC-PriceList, DC-Showtime | PriceList X loại trừ mọi EX-01, EX-13 trong lúc kiểm nên không suất chiếu mới xen vào (X-04, X-06) | - |
| DC-PriceList.SavePriceEntry | 1. CheckEntryUnchangedSinceDisplayed(combo, displayedAt).<br>2. e = findOrCreatePriceEntry(combo).<br>3. e.SetTicketPrice(price, now).<br>4. Trả e | DC-PriceEntry | Mục đã bỏ được dùng lại: SetTicketPrice bỏ cờ removed (tạo lại sau khi bỏ) | - |
| DC-PriceList.RemovePriceEntry | 1. CheckEntryUnchangedSinceDisplayed(combo, displayedAt): mục không còn, đã bỏ hoặc mốc khác thì PriceEntryChangedError.<br>2. Với mỗi s trong showtimes: nếu s.UsesPriceEntry(combo, rooms[s.AuditoriumId()], now) thì PriceEntryInUseError.<br>3. deletePriceEntry(combo, now) | DC-Showtime.UsesPriceEntry, DC-PriceEntry.markRemoved | Tổ hợp chưa từng có mục giá thì không có gì để bỏ: kết quả là PriceEntryChangedError (bảng giá hiển thị không có tổ hợp này nên yêu cầu đến từ trạng thái cũ) | - |
| DC-PriceList.DetermineTimeBand | 1. t = start.In(Asia/Ho_Chi_Minh).<br>2. cuối tuần khi t.Weekday là Saturday hoặc Sunday.<br>3. trước 17:00 khi t.Hour < 17 (17:00 đúng thuộc khung từ 17:00).<br>4. Trả một trong bốn TimeBand | - | Dùng chung cho DetermineSeatPrice (lõi), CheckCoversShowtime, Showtime.UsesPriceEntry | - |
| DC-PriceList.CheckCoversShowtime | 1. band = DetermineTimeBand(start).<br>2. Với mỗi seatType trong seatTypes (thứ tự cố định STANDARD, VIP, COUPLE): tìm mục chưa bỏ của (t, f, seatType, band); không có thì PriceNotCoveredError mang tổ hợp đó | DC-PriceEntry.Combo | Mục đã bỏ không tính | - |
| DC-ScheduleShowtimesService.CreateShowtime | Giai đoạn A, đọc không khoá, để báo lỗi đúng thứ tự P04 và phản hồi sớm:<br>1. IF-13.FindAuditorium(req.auditoriumId) (không có thì AuditoriumGoneError), IF-14.FindByID(req.movieId), IF-12.FindByCinema(actor.cinemaId); now = đồng hồ CSDL qua một giao dịch đọc ngắn.<br>2. Kiểm theo thứ tự: room.CheckBelongsToCinema (4a), movie.CheckReleasedInFormat (5a), room.CheckSupportsFormat (5b), list.CheckCoversShowtime (5c), movie.CheckWithinRunPeriod (6a), draft = room.DraftShowtime(...), draft.CheckNotStarted(now) (6b), draft.CheckSaleOpenBeforeStart (6c).<br>Giai đoạn B, một giao dịch EX-13:<br>3. Do(UserTx("CreateShowtime"), fn); fn: IF-12.LockSharedByCinema (1 S); IF-13.LockAuditoriumsExclusive([auditoriumId]) (2 X; không còn dòng thì AuditoriumGoneError, 8h); IF-14.LockShared(movieId) (10 S); now = tx.Now.<br>4. draft = room.DraftShowtime(...); draft.RecheckMovie(movie) (8g, tính endTime); list.CheckCoversShowtime (8e); others = IF-11.FindInScheduleByAuditorium; room.CheckRoomGap(draft, others, 0) (8b).<br>5. IF-11.Insert(draft); với mỗi seatId của room.InMapSeatIds(): DC-SeatStatus.NewAvailable(SeatKey{draft.ID(), seatId}); IF-18.InsertAll(statuses).<br>6. Trả IF-11.FindListItem.<br>Nếu dừng tại đây (sau giai đoạn A hoặc giữa giai đoạn B): chưa ghi gì hoặc rollback, không để lại suất chiếu thiếu trạng thái ghế | IF-12, IF-13, IF-14, IF-11, IF-18, DC-Auditorium, DC-Movie, DC-PriceList, DC-Showtime, DC-SeatStatus | Phòng X chặn mọi EX-13, EX-19 cùng phòng (X-07, X-28) nên kiểm khoảng cách rồi ghi không có phantom; Movie S loại trừ EX-16 (X-25); EXCLUDE và unique từng phần ở CSDL là lưới an toàn. Hạng 1, 2, 10 tăng ngặt | - |
| DC-ScheduleShowtimesService.UpdateShowtime | Giai đoạn A như CreateShowtime bước 1 và 2 cho phòng, phim, bảng giá của yêu cầu (4a đến 6c), bỏ qua DraftShowtime của suất chiếu mới: dùng draft.<br>Giai đoạn B, một giao dịch EX-13:<br>3. Do(UserTx("UpdateShowtime"), fn); fn: IF-12.LockSharedByCinema (1 S); đọc không khoá IF-11.FindByID để biết phòng hiện tại cur; IF-13.LockAuditoriumsExclusive(các mã {cur, đích} tăng dần, bỏ trùng) (2 X); IF-11.LockExclusive(id) (3 X); so lại phòng hiện tại với cur, khác thì lặp lại từ đầu fn (tối đa 2 lần) rồi SystemBusyError.<br>4. showtime.BelongsToCinema(actor.cinemaId) sai thì NotOwnCinemaError.<br>5. IF-29.LockHoldsSharedByShowtime (5 S); nếu đổi phòng: IF-29.LockSeatStatusesByShowtimes([id]) (6 X) ở replaceSeatStatuses sau khi kiểm; IF-29.LockTicketsSharedByShowtime (8 S); IF-14.LockShared(movieId) (10 S); now = tx.Now.<br>6. Kiểm theo thứ tự P04: showtime.CheckUnchangedSince(displayedAt) (8c), CheckNotStarted(now) (8d), checkNoActiveHoldOrSoldTicket (8a), CheckRoomChangeAllowed(đích, len(vé) > 0) (8f), draft.RecheckMovie (8g), CheckCoversShowtime (8e), CheckNotStarted trên draft (6b), CheckSaleOpenBeforeStart (6c), CheckRoomGap(draft, others, id) (8b).<br>7. showtime.ApplyChanges(draft, now); IF-11.Update; nếu đổi phòng: replaceSeatStatuses.<br>8. Trả IF-11.FindListItem.<br>Nếu dừng tại đây: rollback, suất chiếu và trạng thái ghế không đổi | IF-12, IF-13, IF-11, IF-29, IF-14, IF-18, DC-Showtime, DC-SeatHold, DC-Ticket, DC-Auditorium | Khoá hạng 6 trước hạng 8 (SeatStatus rồi Ticket) cả khi đổi phòng: bước 5 lấy hạng 6 trước hạng 8 khi cur khác đích. BR-92 kiểm ở bước 6 từ vé đã khoá S, kể cả vé đã huỷ | Showtime chỉ sửa được ở Chưa mở bán, Đang mở bán (ST-06): các giai đoạn khác thì CheckNotStarted từ chối; Đã xoá thì CheckUnchangedSince từ chối |
| DC-ScheduleShowtimesService.DeleteShowtime | 1. Do(UserTx("DeleteShowtime"), fn).<br>2. fn: IF-11.LockExclusive(id) (3 X; không còn dòng thì ShowtimeChangedError, 1b3c); showtime.BelongsToCinema(actor.cinemaId) sai thì NotOwnCinemaError; IF-29.LockHoldsSharedByShowtime (5 S); IF-29.LockTicketsSharedByShowtime (8 S); now = tx.Now.<br>3. Kiểm: showtime.CheckUnchangedSince(displayedAt) (1b3c), CheckNotStarted(now) (1b3b), checkNoActiveHoldOrSoldTicket (1b3a).<br>4. showtime.MarkDeleted(now); IF-11.Update.<br>Nếu dừng tại đây: rollback, suất chiếu còn trong lịch | IF-11, IF-29, DC-Showtime, DC-SeatHold, DC-Ticket | Không đụng SeatStatus (không NOTIFY, không seat_event); EX-05, EX-06 vẫn chạy trên suất chiếu Đã xoá | ST-06: chỉ Chưa mở bán, Đang mở bán chuyển được sang Đã xoá |
| DC-ScheduleShowtimesService.PrepareShowtimeEdit | 1. Do(UserTx("PrepareShowtimeEdit"), fn) chỉ đọc, không khoá.<br>2. fn: IF-11.FindByID; BelongsToCinema; now = tx.Now; CheckNotStarted (1a3b); IF-29.FindHoldsByShowtime, FindTicketsByShowtime rồi checkNoActiveHoldOrSoldTicket (1a3a).<br>3. Trả ShowtimeEditView gồm IF-11.FindListItem, IF-13.ListAuditoriums, IF-14.List.<br>Nếu dừng tại đây: chỉ đọc, không đổi gì | IF-11, IF-29, IF-13, IF-14 | Kiểm này chỉ để báo sớm; UpdateShowtime kiểm lại dưới khoá | - |
| DC-ScheduleShowtimesService.replaceSeatStatuses | 1. old = IF-29.LockSeatStatusesByShowtimes([showtime.ID()]) (6 X).<br>2. Với mỗi s của old: nếu CurrentHold có thì s.ReleaseHold(holdId) (lần giữ ghế đã kết thúc mà ghế chưa trả, BR-53); nếu sau đó s không IsAvailable thì lỗi lập trình (không thể còn vé, BR-92).<br>3. IF-18.SaveChanges(các ghế đã đổi).<br>4. IF-29.DeleteSeatStatuses(khoá của old).<br>5. IF-18.InsertAll(DC-SeatStatus.NewAvailable cho mọi InMapSeatIds của room) | IF-29, IF-18, DC-SeatStatus | seat_event do IF-18.SaveChanges ghi (P09 F7.5); sau bước 5 không ghế nào khác Trống | - |
| DC-ManageAuditoriumsService.AddAuditorium | 1. Ngoài giao dịch: a = CreateAuditorium(actor.cinemaId, d, now); a.CheckAuditoriumInfoValid (4a); a.CheckCapacityInRange (4b).<br>2. Do(UserTx("AddAuditorium"), fn) EX-18; fn: IF-13.LockCinemaExclusive(actor.cinemaId) (0 X); refs = IF-13.ListAuditoriumRefs; cinema.CheckAuditoriumNameAvailable(d.name, 0, refs) (4d); IF-13.InsertAuditorium(a).<br>3. Trả a.Info().<br>Nếu dừng tại đây: rollback, không có phòng thiếu ghế | IF-13, IF-08, DC-Auditorium, DC-Cinema, DC-Seat | now ở bước 1 lấy từ đồng hồ CSDL qua giao dịch đọc ngắn rồi đặt lại bằng tx.Now khi ghi (Thiết kế: lastChangedAt ghi bằng Tx.Now trong InsertAuditorium) | - |
| DC-ManageAuditoriumsService.EditAuditorium | 1. Ngoài giao dịch: a = IF-13.FindAuditorium; a.CheckBelongsToCinema(actor.cinemaId); dự kiến = CreateAuditorium(...).CheckAuditoriumInfoValid (4a) và CheckCapacityInRange (4b).<br>2. Do(UserTx("EditAuditorium"), fn) EX-15; fn: IF-13.LockCinemaExclusive (0 X); IF-12.LockSharedByCinema (1 S); IF-13.LockAuditoriumsExclusive([id]) (2 X, không còn thì AuditoriumGoneError); a.CheckBelongsToCinema; IF-11.LockSharedByAuditorium (3 S, kể cả đã xoá); now = tx.Now.<br>3. Kiểm: a.CheckUnchangedSinceDisplayed(displayedAt) (5c); refs = ListAuditoriumRefs, cinema.CheckAuditoriumNameAvailable(d.name, id, refs) (4d); change = a.ComputeSeatMapChange(d.seats); nếu change.Changed và có s không xoá với s.BlocksSeatMapEdit(now) thì AuditoriumBlockedError (5a); types = a.ProjectedSeatTypes(change) (Type mới là d.auditoriumType); mỗi s chưa xoá: s.CheckStaysPriced(list, d.auditoriumType, types, now) (5b).<br>4. Ghi: a.ApplyChanges(d, change, now); IF-13.SaveAuditorium(a); applySeatMapToShowtimes(a, showtimes, now) khi change.Changed.<br>5. Trả a.Info().<br>Nếu dừng tại đây: rollback, phòng và trạng thái ghế không đổi | IF-13, IF-12, IF-11, IF-29, IF-18, IF-08, DC-Auditorium, DC-Cinema, DC-Showtime, DC-PriceList, DC-Seat | Cinema X tuần tự hoá EX-15, EX-18, EX-19 cùng cụm rạp (X-27); Auditorium X loại trừ EX-13 (X-19), EX-19 (X-29); ComputeSeatMapChange bỏ qua việc mở lại ghế đã bỏ: vị trí đó là ghế mới | - |
| DC-ManageAuditoriumsService.RemoveAuditorium | 1. Do(UserTx("RemoveAuditorium"), fn) EX-19; fn: IF-13.LockCinemaExclusive (0 X); IF-13.LockAuditoriumForDelete (2, FOR UPDATE; không còn dòng thì AuditoriumGoneError); a.CheckBelongsToCinema(actor.cinemaId).<br>2. ok = IF-11.ExistsByAuditorium; a.CheckNeverScheduled(ok) (1b3a).<br>3. IF-13.DeleteAuditorium(id).<br>Nếu dừng tại đây: rollback, phòng và ghế còn nguyên | IF-13, IF-11, DC-Auditorium | Không kiểm mốc lúc hiển thị: P04 UC-012 1b3 và BR-146 chỉ nêu "sửa" (Đề xuất sửa P08, P09) | - |
| DC-ManageAuditoriumsService.applySeatMapToShowtimes | 1. targets = các suất chiếu chưa xoá của showtimes có saleOpenTime > now.<br>2. cur = IF-29.LockSeatStatusesByShowtimes(mã của targets) (6 X, theo (suất chiếu, ghế) tăng dần).<br>3. Với mỗi t: delta = t.AdoptSeatMap(room.InMapSeatIds(), mã ghế của cur thuộc t, now).<br>4. IF-29.DeleteSeatStatuses(khoá ghế bỏ), IF-18.InsertAll(NewAvailable ghế mới) | IF-29, IF-18, DC-Showtime.AdoptSeatMap, DC-SeatStatus | Suất chiếu đã kết thúc, đã xoá, đã mở bán giữ sơ đồ lúc mở bán (BR-118); hạng 6 sau hạng 3, tăng ngặt. Không ghi seat_event: suất chiếu chưa mở bán thì sơ đồ chưa hiển thị (P09 F7.5) | - |
| DC-Auditorium.CheckRoomGap | Với mỗi o của others, bỏ qua o.ID() = excludeId và o đã xoá: hợp lệ khi draft.startTime >= o.endTime + RoomGap hoặc o.startTime >= draft.endTime + RoomGap; ngược lại RoomGapError | DC-Showtime | Bằng đúng 15 phút hợp lệ (BR-51); khớp với EXCLUDE ở CSDL | - |
| DC-Auditorium.ComputeSeatMapChange | 1. Lập bản đồ vị trí --> ghế cho các ghế đang IN_MAP.<br>2. Với mỗi ghế nhập: vị trí không có trong bản đồ thì added; có mà khác loại thì retyped[seatId] = loại mới; có và cùng loại thì giữ.<br>3. Ghế trong bản đồ mà vị trí không còn trong dữ liệu nhập thì retired.<br>4. Changed = ba tập không đều rỗng | DC-Seat | Vị trí của ghế đã RETIRED nhập lại thì thuộc added (ghế mới); lưới an toàn P13 (unique từng phần) ở Đề xuất sửa P13 | - |
| DC-Auditorium.ApplyChanges | 1. Gán name, auditoriumType, formats.<br>2. Với mỗi seatId của change.retired: seat.RetireFromSeatMap().<br>3. Với mỗi (seatId, loại) của change.retyped: seat.SetType(loại).<br>4. Thêm Seat.NewSeat cho mỗi change.added.<br>5. lastChangedAt = now | DC-Seat | Thứ tự bước 2 trước bước 4 để vị trí được nhập lại không đụng ghế cũ | Seat: ST-07 |
| DC-Showtime.AdoptSeatMap | 1. Nếu status DELETED hoặc saleOpenTime <= now: trả SeatMapDelta rỗng.<br>2. addedSeatIds = inMapSeatIds không có trong existingSeatIds; removedSeatIds = existingSeatIds không có trong inMapSeatIds | - | Thuần tính toán trên mã ghế | ST-06: chỉ Chưa mở bán |
| DC-Showtime.RecheckMovie | 1. movie.CheckReleasedInFormat(format).<br>2. movie.CheckWithinRunPeriod(startTime).<br>3. CalculateEndTime(movie.Duration()) | DC-Movie | Phim đọc dưới khoá S là phim hiện hành (BR-139); suất chiếu đã lưu không tự đổi khi phim đổi (BR-84) | - |
| DC-Showtime.UsesPriceEntry | Trả false ngay khi status DELETED hoặc Phase khác Chưa mở bán, Đang mở bán; ngược lại so bốn yếu tố của combo với room.Type(), Format(), PriceList.DetermineTimeBand(startTime), room.SeatTypes() | DC-Auditorium, DC-PriceList.DetermineTimeBand | Dùng DetermineTimeBand là nơi duy nhất xác định khung giờ (BR-12) | ST-06 |
| DC-Movie.RunStatusAt | d = releaseDate và e = endOfRunDate (ngày); today < d thì COMING_SOON; today > e thì ENDED; còn lại NOW_SHOWING | - | releaseDate, endOfRunDate | - |
| DC-Movie.CheckWithinRunPeriod | d = start.In(Asia/Ho_Chi_Minh) cắt về ngày; hợp lệ khi releaseDate <= d <= endOfRunDate (releaseDate, endOfRunDate lưu là ngày) | - | Q-268 | - |
| DC-Cinema.CheckAuditoriumNameAvailable | n = NormalizeName(name); với mỗi r của existing có r.id khác excludeId: NormalizeName(r.name) = n thì AuditoriumNameTakenError | DC-Cinema.NormalizeName | Tên phòng kiểm dưới Cinema X nên không cần khoá giá trị (BR-145) | - |

## F4. Bảng ánh xạ message --> operation

Phạm vi: message đi xuống hoặc ngang có lớp nhận thuộc phạm vi, message đi lên có lớp gửi thuộc phạm vi (control tới boundary), UC-012, UC-013, UC-014. Message từ tác nhân tới boundary giao diện không thuộc phạm vi (boundary React ở PKG-05 đến PKG-10, chạy cùng P11a). Message trả về có dữ liệu không thành dòng riêng. "Khác lớp nhận" ghi nơi P10 hoặc P12 đã chuyển trách nhiệm. Các P08 // cancelRequest và // discardRequest không thành operation vì yêu cầu chưa ghi gì và không có trạng thái phía máy chủ (UC-012 SD4, UC-013 SD3, UC-014 SD5).

| UC | STT message (P07) | Từ (AC/DC) | Đến (AC/DC) | Message phân tích (// tênTráchNhiệm) | Operation thiết kế (chữ ký đầy đủ) |
|---|---|---|---|---|---|
| UC-012 | 1.1 | AC-B-ManageAuditoriumsForm | AC-C-ManageAuditoriumsController | // startAuditoriumAddition | DC-ManageAuditoriumsService.ListAuditoriums(ctx, actor) |
| UC-012 | 1.1.1 | AC-C-ManageAuditoriumsController | AC-E-CinemaManager | // provideCinema (BR-135) | Khác lớp nhận: DC-ActorContext.cinemaId (P10 F3 DC-Staff; phiên đã kiểm ở PKG-19), không là operation |
| UC-012 | 1.1.2 | AC-C-ManageAuditoriumsController | AC-E-Cinema | // provideAuditoriums | Khác lớp nhận: IF-13.ListAuditoriums(ctx, cinemaId); Cinema không nắm danh sách phòng (R-38 chiều B --> A) |
| UC-012 | 1.1.2.1 | AC-E-Cinema | AC-E-Auditorium | // provideAuditoriumInfo | DC-Auditorium.Info() AuditoriumInfo |
| UC-012 | 1.1.3 | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // showAuditoriumList (danh sách phòng chiếu) | Trả về: ListAuditoriums trả []AuditoriumInfo |
| UC-012 | 2.1 | AC-B-ManageAuditoriumsForm | AC-C-ManageAuditoriumsController | // submitAuditorium (thông tin phòng chiếu, sơ đồ ghế; luồng 1a kèm mốc thay đổi lúc hiển thị) | DC-ManageAuditoriumsService.AddAuditorium(ctx, actor, draft) (luồng chính); DC-ManageAuditoriumsService.EditAuditorium(ctx, actor, req) (luồng 1a) |
| UC-012 | 2.1.1 | AC-C-ManageAuditoriumsController | AC-E-Auditorium | // createAuditorium (thông tin phòng chiếu đã nhập) | DC-Auditorium.CreateAuditorium(cinemaId, draft, now) *Auditorium (Classifier) |
| UC-012 | 2.1.1.1 | AC-E-Auditorium | AC-E-Seat | // createSeat (hàng, số ghế, loại ghế) | DC-Seat.NewSeat(d SeatDraft) *Seat (Classifier) |
| UC-012 | 2.1.1.1.1 | AC-E-Seat | AC-E-Seat | // checkSeatValid (hàng, số ghế, loại ghế) | DC-Seat.CheckSeatValid() error |
| UC-012 | 2.1.2 | AC-C-ManageAuditoriumsController | AC-E-Auditorium | // checkAuditoriumInfoValid | DC-Auditorium.CheckAuditoriumInfoValid() error |
| UC-012 | 2.1.3 | AC-C-ManageAuditoriumsController | AC-E-Auditorium | // checkCapacityInRange (BR-144) | DC-Auditorium.CheckCapacityInRange() error |
| UC-012 | 2.1.3.1 | AC-E-Auditorium | AC-E-Auditorium | // calculateCapacity (ghế đôi tính một ghế, BR-06) | DC-Auditorium.CalculateCapacity() int |
| UC-012 | 2.1.4 | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // notifyRefusal (điều kiện bị vi phạm của từng trường) | Ngoại lệ: DC-ManageAuditoriumsService.AddAuditorium, EditAuditorium ném FieldInvalidError |
| UC-012 | 2.1.5 | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // notifyRefusal (sức chứa ngoài khoảng 50 đến 400 ghế, BR-144) | Ngoại lệ: DC-ManageAuditoriumsService.AddAuditorium, EditAuditorium ném CapacityOutOfRangeError |
| UC-012 | 2.1.6 | AC-C-ManageAuditoriumsController | AC-E-Cinema | // addAuditorium (phòng chiếu dự kiến, tên phòng chiếu) | Khác lớp nhận: DC-ManageAuditoriumsService.AddAuditorium (DC-Cinema.CheckAuditoriumNameAvailable rồi IF-13.InsertAuditorium; P10 F3a EX-18) |
| UC-012 | 2.1.6.1 | AC-E-Cinema | AC-E-Cinema | // checkAuditoriumNameAvailable (tên phòng chiếu, BR-145) | DC-Cinema.CheckAuditoriumNameAvailable(name, excludeId, existing) error |
| UC-012 | 2.1.7 | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // notifyRefusal (tên phòng chiếu đã thuộc phòng khác trong cụm rạp, BR-145) | Ngoại lệ: DC-ManageAuditoriumsService.AddAuditorium, EditAuditorium ném AuditoriumNameTakenError |
| UC-012 | 2.1.8 | AC-C-ManageAuditoriumsController | AC-E-Auditorium | // provideAuditoriumInfo (phòng chiếu đã lưu) | DC-Auditorium.Info() AuditoriumInfo |
| UC-012 | 2.1.8.1 | AC-E-Auditorium | AC-E-Auditorium | // calculateCapacity (ghế đôi tính một ghế, BR-06) | DC-Auditorium.CalculateCapacity() int |
| UC-012 | 2.1.9 | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // showSavedAuditorium (phòng chiếu đã lưu cùng sức chứa) | Trả về: AddAuditorium hoặc EditAuditorium trả AuditoriumInfo |
| UC-012 | 1a.1 | AC-B-ManageAuditoriumsForm | AC-C-ManageAuditoriumsController | // startAuditoriumEdit | DC-ManageAuditoriumsService.ListAuditoriums(ctx, actor) |
| UC-012 | 1a.1.1 | AC-C-ManageAuditoriumsController | AC-E-CinemaManager | // provideCinema (BR-135) | Khác lớp nhận: DC-ActorContext.cinemaId (P10 F3 DC-Staff; phiên đã kiểm ở PKG-19), không là operation |
| UC-012 | 1a.1.2 | AC-C-ManageAuditoriumsController | AC-E-Cinema | // provideAuditoriums | Khác lớp nhận: IF-13.ListAuditoriums(ctx, cinemaId); Cinema không nắm danh sách phòng (R-38 chiều B --> A) |
| UC-012 | 1a.1.2.1 | AC-E-Cinema | AC-E-Auditorium | // provideAuditoriumInfo | DC-Auditorium.Info() AuditoriumInfo |
| UC-012 | 1a.1.3 | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // showAuditoriumList (danh sách phòng chiếu, mốc thay đổi lúc hiển thị) | Trả về: ListAuditoriums trả []AuditoriumInfo |
| UC-012 | 2a.1 | AC-B-ManageAuditoriumsForm | AC-C-ManageAuditoriumsController | // selectAuditorium (phòng chiếu đã chọn) | DC-ManageAuditoriumsService.SelectAuditorium(ctx, actor, id) |
| UC-012 | 2a.1.1 | AC-C-ManageAuditoriumsController | AC-E-Auditorium | // checkBelongsToCinema (cụm rạp của quản lý cụm rạp, BR-135) | DC-Auditorium.CheckBelongsToCinema(cinemaId CinemaId) error |
| UC-012 | 2a.1.2 | AC-C-ManageAuditoriumsController | AC-E-Auditorium | // provideAuditoriumDetail | DC-Auditorium.Detail() AuditoriumDetail |
| UC-012 | 2a.1.2.1 | AC-E-Auditorium | AC-E-Seat | // provideSeatInfo | DC-Seat.Info() SeatInfo |
| UC-012 | 2a.1.3 | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // showAuditoriumForEdit (thông tin hiện tại của phòng chiếu, từng ghế) | Trả về: SelectAuditorium trả AuditoriumDetail |
| UC-012 | 2.1.6a | AC-C-ManageAuditoriumsController | AC-E-Auditorium | // checkEditAllowed (thông tin phòng chiếu đã kiểm, sơ đồ ghế mới, mốc thay đổi lúc hiển thị) | Khác lớp nhận: DC-ManageAuditoriumsService.EditAuditorium, tách thành CheckUnchangedSinceDisplayed, Cinema.CheckAuditoriumNameAvailable, ComputeSeatMapChange, Showtime.BlocksSeatMapEdit, Showtime.CheckStaysPriced (P10 F3a EX-15) |
| UC-012 | 2.1.6a.1 | AC-E-Auditorium | AC-E-Auditorium | // checkUnchangedSinceDisplayed (mốc thay đổi lúc hiển thị, BR-146) | DC-Auditorium.CheckUnchangedSinceDisplayed(displayedAt time.Time) error |
| UC-012 | 2.1.6a.2 | AC-E-Auditorium | AC-E-Cinema | // checkAuditoriumNameAvailable (tên phòng chiếu, không kể phòng này, BR-145) | DC-Cinema.CheckAuditoriumNameAvailable(name, excludeId, existing) error |
| UC-012 | 2.1.6a.3 | AC-E-Auditorium | AC-E-Auditorium | // checkSeatMapChanged (sơ đồ ghế mới so với sơ đồ hiện tại) | DC-Auditorium.ComputeSeatMapChange(drafts []SeatDraft) SeatMapChange (kết quả Changed) |
| UC-012 | 2.1.6a.4 | AC-E-Auditorium | AC-E-Showtime | // checkBlocksSeatMapEdit (BR-87) | DC-Showtime.BlocksSeatMapEdit(now time.Time) bool |
| UC-012 | 2.1.6a.5 | AC-E-Auditorium | AC-E-Showtime | // checkStaysPriced (loại phòng mới, loại ghế mới, BR-73) | DC-Showtime.CheckStaysPriced(list, auditoriumType, seatTypes, now) error |
| UC-012 | 2.1.6a.5.1 | AC-E-Showtime | AC-E-PriceList | // checkCoversShowtime (loại phòng, loại ghế, giờ bắt đầu, định dạng, BR-69) | DC-PriceList.CheckCoversShowtime(auditoriumType, format, seatTypes, startTime) error |
| UC-012 | 2.1.7a | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // notifyRefusal (phòng chiếu đã bị sửa, mở lại phòng chiếu từ đầu, BR-146) | Ngoại lệ: DC-ManageAuditoriumsService.EditAuditorium ném AuditoriumChangedError |
| UC-012 | 2.1.8a | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // notifyRefusal (tên phòng chiếu đã thuộc phòng khác trong cụm rạp, BR-145) | Ngoại lệ: DC-ManageAuditoriumsService.AddAuditorium, EditAuditorium ném AuditoriumNameTakenError |
| UC-012 | 2.1.9a | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // notifyRefusal (phòng có suất chiếu đã mở bán chưa kết thúc, BR-87) | Ngoại lệ: DC-ManageAuditoriumsService.EditAuditorium ném AuditoriumBlockedError |
| UC-012 | 2.1.10a | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // notifyRefusal (suất chiếu chưa tới giờ bắt đầu sẽ thiếu giá, BR-73) | Ngoại lệ: DC-ManageAuditoriumsService.EditAuditorium ném PriceNotCoveredError |
| UC-012 | 2.1.11a | AC-C-ManageAuditoriumsController | AC-E-Auditorium | // applyChanges (thông tin phòng chiếu đã kiểm, sơ đồ ghế mới) | DC-Auditorium.ApplyChanges(draft, change, now) |
| UC-012 | 2.1.11a.1 | AC-E-Auditorium | AC-E-Showtime | // adoptSeatMap (sơ đồ ghế mới, BR-118) | DC-Showtime.AdoptSeatMap(inMapSeats, existing, now) SeatMapDelta |
| UC-012 | 2.1.12a | AC-C-ManageAuditoriumsController | AC-E-Auditorium | // provideAuditoriumInfo (phòng chiếu đã lưu) | DC-Auditorium.Info() AuditoriumInfo |
| UC-012 | 2.1.12a.1 | AC-E-Auditorium | AC-E-Auditorium | // calculateCapacity (ghế đôi tính một ghế, BR-06) | DC-Auditorium.CalculateCapacity() int |
| UC-012 | 2.1.13a | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // showSavedAuditorium (phòng chiếu đã lưu cùng sức chứa) | Trả về: AddAuditorium hoặc EditAuditorium trả AuditoriumInfo |
| UC-012 | 1b.1 | AC-B-ManageAuditoriumsForm | AC-C-ManageAuditoriumsController | // startAuditoriumRemoval | DC-ManageAuditoriumsService.ListAuditoriums(ctx, actor) |
| UC-012 | 1b.1.1 | AC-C-ManageAuditoriumsController | AC-E-CinemaManager | // provideCinema (BR-135) | Khác lớp nhận: DC-ActorContext.cinemaId (P10 F3 DC-Staff; phiên đã kiểm ở PKG-19), không là operation |
| UC-012 | 1b.1.2 | AC-C-ManageAuditoriumsController | AC-E-Cinema | // provideAuditoriums | Khác lớp nhận: IF-13.ListAuditoriums(ctx, cinemaId); Cinema không nắm danh sách phòng (R-38 chiều B --> A) |
| UC-012 | 1b.1.2.1 | AC-E-Cinema | AC-E-Auditorium | // provideAuditoriumInfo | DC-Auditorium.Info() AuditoriumInfo |
| UC-012 | 1b.1.3 | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // showAuditoriumList (danh sách phòng chiếu) | Trả về: ListAuditoriums trả []AuditoriumInfo |
| UC-012 | 2b.1 | AC-B-ManageAuditoriumsForm | AC-C-ManageAuditoriumsController | // submitAuditoriumRemoval (phòng chiếu đã chọn) | DC-ManageAuditoriumsService.RemoveAuditorium(ctx, actor, id) |
| UC-012 | 2b.1.1 | AC-C-ManageAuditoriumsController | AC-E-Auditorium | // checkBelongsToCinema (cụm rạp của quản lý cụm rạp, BR-135) | DC-Auditorium.CheckBelongsToCinema(cinemaId CinemaId) error |
| UC-012 | 2b.1.2 | AC-C-ManageAuditoriumsController | AC-E-Cinema | // removeAuditorium (phòng chiếu đã chọn) | Khác lớp nhận: DC-ManageAuditoriumsService.RemoveAuditorium (kiểm rồi IF-13.DeleteAuditorium; P10 F3a EX-19) |
| UC-012 | 2b.1.2.1 | AC-E-Cinema | AC-E-Auditorium | // checkNeverScheduled (BR-147) | DC-Auditorium.CheckNeverScheduled(everScheduled bool) error |
| UC-012 | 2b.1.3 | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // notifyRefusal (phòng chiếu đã từng có suất chiếu, kể cả suất chiếu đã xoá, BR-147) | Ngoại lệ: DC-ManageAuditoriumsService.RemoveAuditorium ném AuditoriumHasScheduleError |
| UC-012 | 2b.1.4 | AC-C-ManageAuditoriumsController | AC-B-ManageAuditoriumsForm | // showRemovalSuccess | Trả về: RemoveAuditorium trả nil |
| UC-012 | 1*a.1 | AC-B-ManageAuditoriumsForm | AC-C-ManageAuditoriumsController | // cancelRequest | Không thành operation: huỷ yêu cầu chỉ bỏ trạng thái trình duyệt (P07 UC-012 SD4) |
| UC-012 | 1*a.1.1 | AC-C-ManageAuditoriumsController | AC-C-ManageAuditoriumsController | // discardRequest (không đổi phòng chiếu) | Không thành operation: không có trạng thái phía máy chủ để bỏ |
| UC-013 | 1.1 | AC-B-ManagePriceListForm | AC-C-ManagePriceListController | // startPriceListSetup | DC-ManagePriceListService.GetPriceList(ctx, actor) |
| UC-013 | 1.1.1 | AC-C-ManagePriceListController | AC-E-CinemaManager | // provideCinema (BR-61) | Khác lớp nhận: DC-ActorContext.cinemaId (P10 F3 DC-Staff; phiên đã kiểm ở PKG-19), không là operation |
| UC-013 | 1.1.2 | AC-C-ManagePriceListController | AC-E-PriceList | // providePriceEntries (cụm rạp) | DC-PriceList.ProvideEntries() []PriceEntryInfo (bảng giá nạp bằng IF-12.FindByCinema) |
| UC-013 | 1.1.2.1 | AC-E-PriceList | AC-E-PriceEntry | // provideEntryInfo | DC-PriceEntry.Info() PriceEntryInfo |
| UC-013 | 1.1.3 | AC-C-ManagePriceListController | AC-B-ManagePriceListForm | // showPriceList (bảng giá, tình trạng lúc hiển thị) | Trả về: GetPriceList trả PriceListView |
| UC-013 | 2.1 | AC-B-ManagePriceListForm | AC-C-ManagePriceListController | // submitPriceEntry (tổ hợp, giá vé, tình trạng lúc hiển thị) | DC-ManagePriceListService.SubmitPriceEntry(ctx, actor, req) |
| UC-013 | 2.1.1 | AC-C-ManagePriceListController | AC-E-PriceList | // checkTicketPriceValid (giá vé) | DC-PriceList.CheckTicketPriceValid(price Money) error |
| UC-013 | 2.1.2 | AC-C-ManagePriceListController | AC-B-ManagePriceListForm | // notifyRefusal (giá vé không hợp lệ, BR-70) | Ngoại lệ: DC-ManagePriceListService.SubmitPriceEntry ném TicketPriceInvalidError |
| UC-013 | 2.1.3 | AC-C-ManagePriceListController | AC-E-PriceList | // savePriceEntry (tổ hợp, giá vé, tình trạng lúc hiển thị) | DC-PriceList.SavePriceEntry(combo, price, displayedAt, now) (*PriceEntry, error) |
| UC-013 | 2.1.3.1 | AC-E-PriceList | AC-E-PriceList | // checkEntryUnchangedSinceDisplayed (tổ hợp, tình trạng lúc hiển thị) | DC-PriceList.CheckEntryUnchangedSinceDisplayed(combo, displayedAt) error |
| UC-013 | 2.1.3.2 | AC-E-PriceList | AC-E-PriceList | // findOrCreatePriceEntry (tổ hợp) | DC-PriceList.findOrCreatePriceEntry(combo) *PriceEntry (private) |
| UC-013 | 2.1.3.3 | AC-E-PriceList | AC-E-PriceEntry | // setTicketPrice (giá vé) | DC-PriceEntry.SetTicketPrice(price Money, now time.Time) |
| UC-013 | 2.1.4 | AC-C-ManagePriceListController | AC-B-ManagePriceListForm | // notifyRefusal (mục giá đã thay đổi, mở lại bảng giá từ đầu, BR-63) | Ngoại lệ: DC-ManagePriceListService.SubmitPriceEntry, SubmitPriceEntryRemoval ném PriceEntryChangedError |
| UC-013 | 2.1.5 | AC-C-ManagePriceListController | AC-B-ManagePriceListForm | // showSavedPriceEntry (mục giá đã lưu) | Trả về: SubmitPriceEntry trả PriceEntryInfo |
| UC-013 | 1a.1 | AC-B-ManagePriceListForm | AC-C-ManagePriceListController | // startPriceRemoval | DC-ManagePriceListService.GetPriceList(ctx, actor) |
| UC-013 | 1a.1.1 | AC-C-ManagePriceListController | AC-E-CinemaManager | // provideCinema (BR-61) | Khác lớp nhận: DC-ActorContext.cinemaId (P10 F3 DC-Staff; phiên đã kiểm ở PKG-19), không là operation |
| UC-013 | 1a.1.2 | AC-C-ManagePriceListController | AC-E-PriceList | // providePriceEntries (cụm rạp) | DC-PriceList.ProvideEntries() []PriceEntryInfo (bảng giá nạp bằng IF-12.FindByCinema) |
| UC-013 | 1a.1.2.1 | AC-E-PriceList | AC-E-PriceEntry | // provideEntryInfo | DC-PriceEntry.Info() PriceEntryInfo |
| UC-013 | 1a.1.3 | AC-C-ManagePriceListController | AC-B-ManagePriceListForm | // showPriceList (bảng giá, tình trạng lúc hiển thị) | Trả về: GetPriceList trả PriceListView |
| UC-013 | 2a.1 | AC-B-ManagePriceListForm | AC-C-ManagePriceListController | // submitPriceEntryRemoval (mục giá, tình trạng lúc hiển thị) | DC-ManagePriceListService.SubmitPriceEntryRemoval(ctx, actor, req) |
| UC-013 | 2a.1.1 | AC-C-ManagePriceListController | AC-E-PriceList | // removePriceEntry (mục giá, tình trạng lúc hiển thị) | DC-PriceList.RemovePriceEntry(combo, displayedAt, now, showtimes, rooms) error |
| UC-013 | 2a.1.1.1 | AC-E-PriceList | AC-E-PriceList | // checkEntryUnchangedSinceDisplayed (mục giá, tình trạng lúc hiển thị) | DC-PriceList.CheckEntryUnchangedSinceDisplayed(combo, displayedAt) error |
| UC-013 | 2a.1.1.2 | AC-E-PriceList | AC-E-Showtime | // checkUsesPriceEntry (loại phòng, định dạng, loại ghế, khung giờ của mục giá) | DC-Showtime.UsesPriceEntry(combo, room, now) bool |
| UC-013 | 2a.1.1.2.1 | AC-E-Showtime | AC-E-PriceList | // determineTimeBand (giờ bắt đầu của suất chiếu) | DC-PriceList.DetermineTimeBand(startTime time.Time) TimeBand (Classifier) |
| UC-013 | 2a.1.1.3 | AC-E-PriceList | AC-E-PriceList | // deletePriceEntry (mục giá) | DC-PriceList.deletePriceEntry(combo, now) (private; gọi DC-PriceEntry.markRemoved) |
| UC-013 | 2a.1.2 | AC-C-ManagePriceListController | AC-B-ManagePriceListForm | // notifyRefusal (mục giá đã thay đổi hoặc không còn, mở lại bảng giá từ đầu, BR-63) | Ngoại lệ: DC-ManagePriceListService.SubmitPriceEntry, SubmitPriceEntryRemoval ném PriceEntryChangedError |
| UC-013 | 2a.1.3 | AC-C-ManagePriceListController | AC-B-ManagePriceListForm | // notifyRefusal (còn suất chiếu đang dùng mục giá, BR-64) | Ngoại lệ: DC-ManagePriceListService.SubmitPriceEntryRemoval ném PriceEntryInUseError |
| UC-013 | 2a.1.4 | AC-C-ManagePriceListController | AC-B-ManagePriceListForm | // showRemovalSuccess | Trả về: SubmitPriceEntryRemoval trả nil |
| UC-013 | 1*a.1 | AC-B-ManagePriceListForm | AC-C-ManagePriceListController | // cancelRequest | Không thành operation: huỷ yêu cầu chỉ bỏ trạng thái trình duyệt, chưa có gì ghi (P07 UC-013 SD3) |
| UC-013 | 1*a.1.1 | AC-C-ManagePriceListController | AC-C-ManagePriceListController | // discardRequest (không đổi bảng giá) | Không thành operation: không có trạng thái phía máy chủ để bỏ |
| UC-014 | 1.1 | AC-B-ScheduleShowtimesForm | AC-C-ScheduleShowtimesController | // startScheduling | DC-ScheduleShowtimesService.StartScheduling(ctx, actor) |
| UC-014 | 1.1.1 | AC-C-ScheduleShowtimesController | AC-E-CinemaManager | // provideCinema | Khác lớp nhận: DC-ActorContext.cinemaId (P10 F3 DC-Staff; phiên đã kiểm ở PKG-19), không là operation |
| UC-014 | 1.1.2 | AC-C-ScheduleShowtimesController | AC-E-Auditorium | // provideAuditoriumInfo (cụm rạp) | DC-Auditorium.Info() AuditoriumInfo (nạp bằng IF-13.ListAuditoriums) |
| UC-014 | 1.1.3 | AC-C-ScheduleShowtimesController | AC-E-Movie | // provideMovieInfo | DC-Movie.Info() MovieInfo (nạp bằng IF-14.List) |
| UC-014 | 1.1.4 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // showAuditoriumsAndMovies (phòng chiếu, phim) | Trả về: StartScheduling trả ScheduleFormData |
| UC-014 | 2.1 | AC-B-ScheduleShowtimesForm | AC-C-ScheduleShowtimesController | // requestSaveShowtime (phim, định dạng, phòng chiếu, giờ bắt đầu, thời điểm mở bán) | DC-ScheduleShowtimesService.CreateShowtime(ctx, actor, req) (lập mới); DC-ScheduleShowtimesService.UpdateShowtime(ctx, actor, req) (sửa) |
| UC-014 | 2.1.1 | AC-C-ScheduleShowtimesController | AC-E-CinemaManager | // provideCinema | Khác lớp nhận: DC-ActorContext.cinemaId (P10 F3 DC-Staff; phiên đã kiểm ở PKG-19), không là operation |
| UC-014 | 2.1.2 | AC-C-ScheduleShowtimesController | AC-E-Auditorium | // checkBelongsToCinema (cụm rạp của quản lý cụm rạp) | DC-Auditorium.CheckBelongsToCinema(cinemaId CinemaId) error |
| UC-014 | 2.1.3 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-46 bị vi phạm) | Ngoại lệ: DC-ScheduleShowtimesService.CreateShowtime, UpdateShowtime ném NotOwnCinemaError |
| UC-014 | 2.1.4 | AC-C-ScheduleShowtimesController | AC-E-Movie | // checkReleasedInFormat (định dạng) | DC-Movie.CheckReleasedInFormat(f MovieFormat) error |
| UC-014 | 2.1.5 | AC-C-ScheduleShowtimesController | AC-E-Auditorium | // checkSupportsFormat (định dạng) | DC-Auditorium.CheckSupportsFormat(f MovieFormat) error |
| UC-014 | 2.1.6 | AC-C-ScheduleShowtimesController | AC-E-Auditorium | // provideSeatTypes | DC-Auditorium.SeatTypes() []SeatType |
| UC-014 | 2.1.7 | AC-C-ScheduleShowtimesController | AC-E-PriceList | // checkCoversShowtime (loại phòng, định dạng, các loại ghế, giờ bắt đầu) | DC-PriceList.CheckCoversShowtime(auditoriumType, format, seatTypes, startTime) error |
| UC-014 | 2.1.8 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-47 bị vi phạm) | Ngoại lệ: DC-ScheduleShowtimesService.CreateShowtime, UpdateShowtime ném FormatNotReleasedError |
| UC-014 | 2.1.9 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-48 bị vi phạm) | Ngoại lệ: DC-ScheduleShowtimesService.CreateShowtime, UpdateShowtime ném FormatNotSupportedError |
| UC-014 | 2.1.10 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-69 bị vi phạm) | Ngoại lệ: DC-ScheduleShowtimesService.CreateShowtime, UpdateShowtime ném PriceNotCoveredError |
| UC-014 | 2.1.11 | AC-C-ScheduleShowtimesController | AC-E-Movie | // checkWithinRunPeriod (ngày của giờ bắt đầu) | DC-Movie.CheckWithinRunPeriod(startTime time.Time) error |
| UC-014 | 2.1.12 | AC-C-ScheduleShowtimesController | AC-E-Auditorium | // draftShowtime (phim, định dạng, giờ bắt đầu, thời điểm mở bán) | DC-Auditorium.DraftShowtime(movieId, format, start, saleOpen) *Showtime |
| UC-014 | 2.1.12.1 | AC-E-Auditorium | AC-E-Showtime | // createShowtime (phim, định dạng, phòng chiếu, giờ bắt đầu, thời điểm mở bán) | DC-Showtime.NewShowtime(movieId, format, auditoriumId, start, saleOpen) *Showtime (Classifier) |
| UC-014 | 2.1.12.1.1 | AC-E-Showtime | AC-E-Showtime | // checkStartAfter (thời điểm kiểm tra) | DC-Showtime.CheckNotStarted(now time.Time) error |
| UC-014 | 2.1.12.1.2 | AC-E-Showtime | AC-E-Showtime | // checkSaleOpenBeforeStart | DC-Showtime.CheckSaleOpenBeforeStart() error |
| UC-014 | 2.1.13 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-49 bị vi phạm) | Ngoại lệ: DC-ScheduleShowtimesService.CreateShowtime, UpdateShowtime ném OutsideRunPeriodError |
| UC-014 | 2.1.14 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-56 bị vi phạm) | Ngoại lệ: DC-ScheduleShowtimesService.CreateShowtime, UpdateShowtime, PrepareShowtimeEdit, DeleteShowtime ném ShowtimeStartedError |
| UC-014 | 2.1.15 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-55 bị vi phạm) | Ngoại lệ: DC-ScheduleShowtimesService.CreateShowtime, UpdateShowtime ném SaleOpenOrderError |
| UC-014 | 2.1.16 | AC-C-ScheduleShowtimesController | AC-E-Showtime | // calculateEndTime | DC-Showtime.CalculateEndTime(duration time.Duration) (gán endTime) |
| UC-014 | 2.1.16.1 | AC-E-Showtime | AC-E-Movie | // provideDuration | DC-Movie.Duration() time.Duration |
| UC-014 | 2.1.17 | AC-C-ScheduleShowtimesController | AC-E-Auditorium | // saveShowtime (suất chiếu dự kiến) | Khác lớp nhận: DC-ScheduleShowtimesService.CreateShowtime hoặc UpdateShowtime (một giao dịch EX-13, P10 F3a) |
| UC-014 | 2.1.17.1 | AC-E-Auditorium | AC-E-Auditorium | // checkStillExists | Khác lớp nhận: IF-13.LockAuditoriumsExclusive trả NotFoundError, dịch thành AuditoriumGoneError (P10 F3a EX-13) |
| UC-014 | 2.1.17.2 | AC-E-Auditorium | AC-E-Showtime | // recheckMovie | DC-Showtime.RecheckMovie(movie *Movie) error |
| UC-014 | 2.1.17.2.1 | AC-E-Showtime | AC-E-Movie | // checkReleasedInFormat (định dạng) | DC-Movie.CheckReleasedInFormat(f MovieFormat) error |
| UC-014 | 2.1.17.2.2 | AC-E-Showtime | AC-E-Movie | // checkWithinRunPeriod (ngày của giờ bắt đầu) | DC-Movie.CheckWithinRunPeriod(startTime time.Time) error |
| UC-014 | 2.1.17.2.3 | AC-E-Showtime | AC-E-Movie | // provideDuration | DC-Movie.Duration() time.Duration |
| UC-014 | 2.1.17.2.4 | AC-E-Showtime | AC-E-Showtime | // calculateEndTime | DC-Showtime.CalculateEndTime(duration time.Duration) (gán endTime) |
| UC-014 | 2.1.17.3 | AC-E-Auditorium | AC-E-PriceList | // checkCoversShowtime (loại phòng, định dạng, loại ghế, giờ bắt đầu) | DC-PriceList.CheckCoversShowtime(auditoriumType, format, seatTypes, startTime) error |
| UC-014 | 2.1.17.4 | AC-E-Auditorium | AC-E-Auditorium | // checkRoomGap (suất chiếu dự kiến) | DC-Auditorium.CheckRoomGap(draft, others, excludeId) error |
| UC-014 | 2.1.17.5 | AC-E-Auditorium | AC-E-Auditorium | // addToSchedule (suất chiếu dự kiến) | Khác lớp nhận: IF-11.Insert(ctx, tx, s) trong CreateShowtime |
| UC-014 | 2.1.18 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-47 hoặc BR-49 bị vi phạm) | Ngoại lệ: DC-ScheduleShowtimesService.CreateShowtime, UpdateShowtime ném FormatNotReleasedError hoặc OutsideRunPeriodError |
| UC-014 | 2.1.19 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal (phòng chiếu không còn, quy tắc BR-147) | Ngoại lệ: DC-ScheduleShowtimesService.CreateShowtime, UpdateShowtime ném AuditoriumGoneError |
| UC-014 | 2.1.20 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-69 bị vi phạm) | Ngoại lệ: DC-ScheduleShowtimesService.CreateShowtime, UpdateShowtime ném PriceNotCoveredError |
| UC-014 | 2.1.21 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-51 bị vi phạm) | Ngoại lệ: DC-ScheduleShowtimesService.CreateShowtime, UpdateShowtime ném RoomGapError |
| UC-014 | 2.1.22 | AC-C-ScheduleShowtimesController | AC-E-Showtime | // provideShowtimeInfo | DC-ScheduleShowtimesService.ListShowtimes (qua IF-11.ListByCinema / FindListItem trả ShowtimeListItem) |
| UC-014 | 2.1.23 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // showSavedShowtime (suất chiếu đã lưu) | Trả về: CreateShowtime hoặc UpdateShowtime trả ShowtimeListItem |
| UC-014 | 1a.1 | AC-B-ScheduleShowtimesForm | AC-C-ScheduleShowtimesController | // startEditingShowtime | DC-ScheduleShowtimesService.ListShowtimes(ctx, actor) |
| UC-014 | 1a.1.1 | AC-C-ScheduleShowtimesController | AC-E-CinemaManager | // provideCinema | Khác lớp nhận: DC-ActorContext.cinemaId (P10 F3 DC-Staff; phiên đã kiểm ở PKG-19), không là operation |
| UC-014 | 1a.1.2 | AC-C-ScheduleShowtimesController | AC-E-Showtime | // provideShowtimeInfo | DC-ScheduleShowtimesService.ListShowtimes (qua IF-11.ListByCinema / FindListItem trả ShowtimeListItem) |
| UC-014 | 1a.1.3 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // showShowtimes (các suất chiếu đã lập) | Trả về: ListShowtimes trả []ShowtimeListItem |
| UC-014 | 1a.2.1 | AC-B-ScheduleShowtimesForm | AC-C-ScheduleShowtimesController | // prepareShowtimeEdit (suất chiếu) | DC-ScheduleShowtimesService.PrepareShowtimeEdit(ctx, actor, id) |
| UC-014 | 1a.2.1.1 | AC-C-ScheduleShowtimesController | AC-E-Showtime | // checkNotStarted (thời điểm kiểm tra) | DC-Showtime.CheckNotStarted(now time.Time) error |
| UC-014 | 1a.2.1.2 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-57 bị vi phạm) | Ngoại lệ: DC-ScheduleShowtimesService.CreateShowtime, UpdateShowtime, PrepareShowtimeEdit, DeleteShowtime ném ShowtimeStartedError |
| UC-014 | 1a.2.1.3 | AC-C-ScheduleShowtimesController | AC-E-Showtime | // checkNoActiveHoldOrSoldTicket (thời điểm kiểm tra) | Khác lớp nhận: DC-ScheduleShowtimesService.checkNoActiveHoldOrSoldTicket (private); Showtime không gọi SeatHold, Ticket (P10 F3 AC-E-Showtime) |
| UC-014 | 1a.2.1.3.1 | AC-E-Showtime | AC-E-SeatHold | // checkHoldStillActive (thời điểm kiểm tra) | DC-SeatHold.IsActiveAt(now time.Time) bool (lõi, F2.PKG-28) |
| UC-014 | 1a.2.1.3.2 | AC-E-Showtime | AC-E-Ticket | // checkNotCancelled | DC-Ticket.IsCancelled() bool (lõi, F2.PKG-28) |
| UC-014 | 1a.2.1.4 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-53 bị vi phạm) | Ngoại lệ: DC-ScheduleShowtimesService.PrepareShowtimeEdit, UpdateShowtime, DeleteShowtime ném ShowtimeInUseError |
| UC-014 | 1a.2.1.5 | AC-C-ScheduleShowtimesController | AC-E-Showtime | // provideShowtimeInfo | DC-ScheduleShowtimesService.ListShowtimes (qua IF-11.ListByCinema / FindListItem trả ShowtimeListItem) |
| UC-014 | 1a.2.1.6 | AC-C-ScheduleShowtimesController | AC-E-Auditorium | // provideAuditoriumInfo (cụm rạp) | DC-Auditorium.Info() AuditoriumInfo (nạp bằng IF-13.ListAuditoriums) |
| UC-014 | 1a.2.1.7 | AC-C-ScheduleShowtimesController | AC-E-Movie | // provideMovieInfo | DC-Movie.Info() MovieInfo (nạp bằng IF-14.List) |
| UC-014 | 1a.2.1.8 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // showShowtimeForEdit (suất chiếu, phòng chiếu, phim) | Trả về: PrepareShowtimeEdit trả ShowtimeEditView |
| UC-014 | 2.1.17[1a] | AC-C-ScheduleShowtimesController | AC-E-Auditorium | // saveShowtime (suất chiếu đang sửa, suất chiếu dự kiến, mốc thay đổi đã hiển thị, thời điểm kiểm tra) | Khác lớp nhận: DC-ScheduleShowtimesService.CreateShowtime hoặc UpdateShowtime (một giao dịch EX-13, P10 F3a) |
| UC-014 | 2.1.17[1a].1 | AC-E-Auditorium | AC-E-Showtime | // checkUnchangedSinceDisplayed (mốc thay đổi đã hiển thị) | DC-Showtime.CheckUnchangedSince(displayedAt time.Time) error (lõi) |
| UC-014 | 2.1.17[1a].2 | AC-E-Auditorium | AC-E-Showtime | // checkNotStarted (thời điểm kiểm tra) | DC-Showtime.CheckNotStarted(now time.Time) error |
| UC-014 | 2.1.17[1a].3 | AC-E-Auditorium | AC-E-Showtime | // checkNoActiveHoldOrSoldTicket (thời điểm kiểm tra) | Khác lớp nhận: DC-ScheduleShowtimesService.checkNoActiveHoldOrSoldTicket (private); Showtime không gọi SeatHold, Ticket (P10 F3 AC-E-Showtime) |
| UC-014 | 2.1.17[1a].3.1 | AC-E-Showtime | AC-E-SeatHold | // checkHoldStillActive (thời điểm kiểm tra) | DC-SeatHold.IsActiveAt(now time.Time) bool (lõi, F2.PKG-28) |
| UC-014 | 2.1.17[1a].3.2 | AC-E-Showtime | AC-E-Ticket | // checkNotCancelled | DC-Ticket.IsCancelled() bool (lõi, F2.PKG-28) |
| UC-014 | 2.1.17[1a].4 | AC-E-Auditorium | AC-E-Showtime | // checkRoomChangeAllowed (phòng chiếu đích) | DC-Showtime.CheckRoomChangeAllowed(targetId AuditoriumId, everHadTicket bool) error |
| UC-014 | 2.1.17[1a].5 | AC-E-Auditorium | AC-E-Auditorium | // checkStillExists | Khác lớp nhận: IF-13.LockAuditoriumsExclusive trả NotFoundError, dịch thành AuditoriumGoneError (P10 F3a EX-13) |
| UC-014 | 2.1.17[1a].6 | AC-E-Auditorium | AC-E-Showtime | // recheckMovie | DC-Showtime.RecheckMovie(movie *Movie) error |
| UC-014 | 2.1.17[1a].6.1 | AC-E-Showtime | AC-E-Movie | // checkReleasedInFormat (định dạng) | DC-Movie.CheckReleasedInFormat(f MovieFormat) error |
| UC-014 | 2.1.17[1a].6.2 | AC-E-Showtime | AC-E-Movie | // checkWithinRunPeriod (ngày của giờ bắt đầu) | DC-Movie.CheckWithinRunPeriod(startTime time.Time) error |
| UC-014 | 2.1.17[1a].6.3 | AC-E-Showtime | AC-E-Movie | // provideDuration | DC-Movie.Duration() time.Duration |
| UC-014 | 2.1.17[1a].6.4 | AC-E-Showtime | AC-E-Showtime | // calculateEndTime | DC-Showtime.CalculateEndTime(duration time.Duration) (gán endTime) |
| UC-014 | 2.1.17[1a].7 | AC-E-Auditorium | AC-E-PriceList | // checkCoversShowtime (loại phòng, định dạng, loại ghế, giờ bắt đầu) | DC-PriceList.CheckCoversShowtime(auditoriumType, format, seatTypes, startTime) error |
| UC-014 | 2.1.17[1a].8 | AC-E-Auditorium | AC-E-Auditorium | // checkRoomGap (suất chiếu dự kiến, bỏ qua suất chiếu đang sửa) | DC-Auditorium.CheckRoomGap(draft, others, excludeId) error |
| UC-014 | 2.1.17[1a].9 | AC-E-Auditorium | AC-E-Showtime | // applyChanges (suất chiếu dự kiến) | DC-Showtime.ApplyChanges(draft *Showtime, now time.Time) |
| UC-014 | 2.1.18[8c] | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal (suất chiếu đã thay đổi hoặc không còn, quy tắc BR-60) | Ngoại lệ: DC-ScheduleShowtimesService.UpdateShowtime, DeleteShowtime ném ShowtimeChangedError |
| UC-014 | 2.1.18[8d] | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-57 bị vi phạm) | Ngoại lệ: DC-ScheduleShowtimesService.CreateShowtime, UpdateShowtime, PrepareShowtimeEdit, DeleteShowtime ném ShowtimeStartedError |
| UC-014 | 2.1.18[8a] | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-53 bị vi phạm) | Ngoại lệ: DC-ScheduleShowtimesService.PrepareShowtimeEdit, UpdateShowtime, DeleteShowtime ném ShowtimeInUseError |
| UC-014 | 2.1.18[8f] | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-92 bị vi phạm) | Ngoại lệ: DC-ScheduleShowtimesService.UpdateShowtime ném RoomChangeNotAllowedError |
| UC-014 | 2.1.18[8g] | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-47 hoặc BR-49 bị vi phạm) | Ngoại lệ: DC-ScheduleShowtimesService.CreateShowtime, UpdateShowtime ném FormatNotReleasedError hoặc OutsideRunPeriodError |
| UC-014 | 2.1.19[8h] | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal (phòng chiếu không còn, quy tắc BR-147) | Ngoại lệ: DC-ScheduleShowtimesService.CreateShowtime, UpdateShowtime ném AuditoriumGoneError |
| UC-014 | 2.1.20[8e] | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-69 bị vi phạm) | Ngoại lệ: DC-ScheduleShowtimesService.CreateShowtime, UpdateShowtime ném PriceNotCoveredError |
| UC-014 | 2.1.21[8b] | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-51 bị vi phạm) | Ngoại lệ: DC-ScheduleShowtimesService.CreateShowtime, UpdateShowtime ném RoomGapError |
| UC-014 | 2.1.22[1a] | AC-C-ScheduleShowtimesController | AC-E-Showtime | // provideShowtimeInfo | DC-ScheduleShowtimesService.ListShowtimes (qua IF-11.ListByCinema / FindListItem trả ShowtimeListItem) |
| UC-014 | 2.1.23[1a] | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // showSavedShowtime (suất chiếu đã lưu) | Trả về: CreateShowtime hoặc UpdateShowtime trả ShowtimeListItem |
| UC-014 | 1b.1 | AC-B-ScheduleShowtimesForm | AC-C-ScheduleShowtimesController | // startDeletingShowtime | DC-ScheduleShowtimesService.ListShowtimes(ctx, actor) |
| UC-014 | 1b.1.1 | AC-C-ScheduleShowtimesController | AC-E-CinemaManager | // provideCinema | Khác lớp nhận: DC-ActorContext.cinemaId (P10 F3 DC-Staff; phiên đã kiểm ở PKG-19), không là operation |
| UC-014 | 1b.1.2 | AC-C-ScheduleShowtimesController | AC-E-Showtime | // provideShowtimeInfo | DC-ScheduleShowtimesService.ListShowtimes (qua IF-11.ListByCinema / FindListItem trả ShowtimeListItem) |
| UC-014 | 1b.1.3 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // showShowtimes (các suất chiếu đã lập) | Trả về: ListShowtimes trả []ShowtimeListItem |
| UC-014 | 1b.2.1 | AC-B-ScheduleShowtimesForm | AC-C-ScheduleShowtimesController | // deleteShowtime (suất chiếu, mốc thay đổi đã hiển thị) | DC-ScheduleShowtimesService.DeleteShowtime(ctx, actor, id, displayedAt) |
| UC-014 | 1b.2.1.1 | AC-C-ScheduleShowtimesController | AC-E-Showtime | // removeFromSchedule (mốc thay đổi đã hiển thị, thời điểm kiểm tra) | Khác lớp nhận: DC-ScheduleShowtimesService.DeleteShowtime (CheckUnchangedSince, CheckNotStarted, kiểm hold/vé, MarkDeleted; P10 F3a EX-14) |
| UC-014 | 1b.2.1.1.1 | AC-E-Showtime | AC-E-Showtime | // checkUnchangedSinceDisplayed (mốc thay đổi đã hiển thị) | DC-Showtime.CheckUnchangedSince(displayedAt time.Time) error (lõi) |
| UC-014 | 1b.2.1.1.2 | AC-E-Showtime | AC-E-Showtime | // checkNotStarted (thời điểm kiểm tra) | DC-Showtime.CheckNotStarted(now time.Time) error |
| UC-014 | 1b.2.1.1.3 | AC-E-Showtime | AC-E-Showtime | // checkNoActiveHoldOrSoldTicket (thời điểm kiểm tra) | Khác lớp nhận: DC-ScheduleShowtimesService.checkNoActiveHoldOrSoldTicket (private); Showtime không gọi SeatHold, Ticket (P10 F3 AC-E-Showtime) |
| UC-014 | 1b.2.1.1.3.1 | AC-E-Showtime | AC-E-SeatHold | // checkHoldStillActive (thời điểm kiểm tra) | DC-SeatHold.IsActiveAt(now time.Time) bool (lõi, F2.PKG-28) |
| UC-014 | 1b.2.1.1.3.2 | AC-E-Showtime | AC-E-Ticket | // checkNotCancelled | DC-Ticket.IsCancelled() bool (lõi, F2.PKG-28) |
| UC-014 | 1b.2.1.1.4 | AC-E-Showtime | AC-E-Showtime | // markDeleted | DC-Showtime.MarkDeleted(now time.Time) error |
| UC-014 | 1b.2.1.2 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal (suất chiếu đã thay đổi hoặc không còn, quy tắc BR-60) | Ngoại lệ: DC-ScheduleShowtimesService.UpdateShowtime, DeleteShowtime ném ShowtimeChangedError |
| UC-014 | 1b.2.1.3 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-57 bị vi phạm) | Ngoại lệ: DC-ScheduleShowtimesService.CreateShowtime, UpdateShowtime, PrepareShowtimeEdit, DeleteShowtime ném ShowtimeStartedError |
| UC-014 | 1b.2.1.4 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-53 bị vi phạm) | Ngoại lệ: DC-ScheduleShowtimesService.PrepareShowtimeEdit, UpdateShowtime, DeleteShowtime ném ShowtimeInUseError |
| UC-014 | 1b.2.1.5 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // notifyDeleted (suất chiếu đã xoá) | Trả về: DeleteShowtime trả nil |
| UC-014 | 1*a.1 | AC-B-ScheduleShowtimesForm | AC-C-ScheduleShowtimesController | // cancelRequest | Không thành operation: huỷ yêu cầu chỉ bỏ trạng thái trình duyệt (P07 UC-014 SD5) |
| UC-014 | 1*a.1.1 | AC-C-ScheduleShowtimesController | AC-C-ScheduleShowtimesController | // discardRequest (không thay đổi suất chiếu nào) | Không thành operation: không có trạng thái phía máy chủ để bỏ |
| UC-014 | 1*a.1.2 | AC-C-ScheduleShowtimesController | AC-B-ScheduleShowtimesForm | // showRequestCancelled | Không thành operation: hiển thị huỷ là việc của trình duyệt |

## F5. Bảng quan hệ

Quan hệ có gốc ở P08 giữ mã R-nn của P08. Quan hệ của control P08 (R-30 đến R-37, R-87 đến R-89) trở thành quan hệ của lớp dịch vụ: control nhận phiên qua DC-ActorContext (provideCinema không là message tới entity, Khác lớp nhận ở F4) và dùng entity qua biến cục bộ. Quan hệ giữa boundary và control (R-29, R-32, R-86) thuộc lần chạy PKG-05 đến PKG-10. R-60 (DC-Showtime ..> DC-PriceList) đã thiết kế ở lõi. R-62 (Auditorium ..> PriceList) không còn: lời gọi PriceList.CheckCoversShowtime do lớp dịch vụ thực hiện (Q-117), giữ mã để truy vết.

| ID | Lớp A | Lớp B | Loại | Multiplicity | Điều hướng | Lý do | Vai trò | Căn cứ hiển thị |
|---|---|---|---|---|---|---|---|---|
| R-38 | DC-Cinema | DC-Auditorium | Aggregation | A 1 - B 0..* | B --> A | P08 R-38. Phòng giữ mã cụm rạp; cụm rạp không nắm danh sách, tìm bằng IF-13.ListAuditoriums; aggregation vì phòng đã có suất chiếu không xoá được (BR-147) | cinema / auditoriums | field (cinemaId) |
| R-39 | DC-Auditorium | DC-Seat | Composition | A 1 - B 50..400 | A --> B | P08 R-39 (Q-253). Xoá phòng xoá cùng ghế (BR-147); 50 đến 400 đếm ghế trong sơ đồ (BR-144), ghế đã bỏ nằm thêm trong tập (BR-118) | auditorium / seats | field ([]*Seat) |
| R-40 | DC-Cinema | DC-PriceList | Association | A 1 - B 1 | B --> A | P08 R-40 (GL-01). Bảng giá khoá bởi mã cụm rạp; tạo cùng cụm rạp (EX-17) | cinema / priceList | field (cinemaId) |
| R-41 | DC-PriceList | DC-PriceEntry | Composition | A 1 - B 0..72 | A --> B | P08 R-41 (BR-62). Tối đa 3 x 2 x 3 x 4 tổ hợp; mục đã bỏ vẫn nằm trong tập (cờ removed) để nhận ra thay đổi lúc hiển thị | priceList / entries | field ([]*PriceEntry) |
| R-42 | DC-Auditorium | DC-Showtime | Association | A 1 - B 0..* | B --> A | P08 R-42. Suất chiếu giữ mã phòng; phòng tìm suất chiếu bằng IF-11 (không giữ danh sách, số suất chiếu không có cận trên) | auditorium / showtimes | field (auditoriumId) |
| R-43 | DC-Showtime | DC-Movie | Association | A 0..* - B 1 | A --> B | P08 R-43. Suất chiếu giữ mã phim | showtimes / movie | field (movieId) |
| R-61 | DC-PriceList | DC-Showtime | Dependency | | A --> B | P08 R-61. RemovePriceEntry nhận các suất chiếu qua tham số, gọi UsesPriceEntry | | parameter |
| R-30 | DC-ManagePriceListService | DC-ActorContext | Dependency | | A --> B | P08 R-30. Cụm rạp của quản lý lấy từ ActorContext (Khác lớp nhận ở F4) | | parameter |
| R-31 | DC-ManagePriceListService | DC-PriceList | Dependency | | A --> B | P08 R-31. Nạp qua IF-12 và dùng trong một phương thức | | local |
| R-33 | DC-ScheduleShowtimesService | DC-ActorContext | Dependency | | A --> B | P08 R-33 | | parameter |
| R-34 | DC-ScheduleShowtimesService | DC-Auditorium | Dependency | | A --> B | P08 R-34. Nạp qua IF-13 | | local |
| R-35 | DC-ScheduleShowtimesService | DC-Movie | Dependency | | A --> B | P08 R-35. Nạp qua IF-14 | | local |
| R-36 | DC-ScheduleShowtimesService | DC-Showtime | Dependency | | A --> B | P08 R-36. Nạp qua IF-11 | | local |
| R-37 | DC-ScheduleShowtimesService | DC-PriceList | Dependency | | A --> B | P08 R-37. Nạp qua IF-12 | | local |
| R-87 | DC-ManageAuditoriumsService | DC-ActorContext | Dependency | | A --> B | P08 R-87 | | parameter |
| R-88 | DC-ManageAuditoriumsService | DC-Cinema | Dependency | | A --> B | P08 R-88. Nạp qua IF-13 dưới khoá hạng 0 | | local |
| R-89 | DC-ManageAuditoriumsService | DC-Auditorium | Dependency | | A --> B | P08 R-89. Nạp qua IF-13 | | local |
| R-200 | DC-ManagePriceListService | IF-08 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | | field |
| R-201 | DC-ManagePriceListService | IF-12 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | | field |
| R-202 | DC-ManagePriceListService | IF-13 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | | field |
| R-203 | DC-ManagePriceListService | IF-11 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | | field |
| R-204 | DC-ScheduleShowtimesService | IF-08 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | | field |
| R-205 | DC-ScheduleShowtimesService | IF-11 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | | field |
| R-206 | DC-ScheduleShowtimesService | IF-12 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | | field |
| R-207 | DC-ScheduleShowtimesService | IF-13 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | | field |
| R-208 | DC-ScheduleShowtimesService | IF-14 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | | field |
| R-209 | DC-ScheduleShowtimesService | IF-29 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | | field |
| R-210 | DC-ScheduleShowtimesService | IF-18 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc (InsertAll, SaveChanges) | | field |
| R-211 | DC-ManageAuditoriumsService | IF-08 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | | field |
| R-212 | DC-ManageAuditoriumsService | IF-11 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | | field |
| R-213 | DC-ManageAuditoriumsService | IF-12 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | | field |
| R-214 | DC-ManageAuditoriumsService | IF-13 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | | field |
| R-215 | DC-ManageAuditoriumsService | IF-29 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | | field |
| R-216 | DC-ManageAuditoriumsService | IF-18 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc (InsertAll) | | field |
| R-217 | DC-Showtime | DC-Movie | Dependency | | A --> B | RecheckMovie nhận phim qua tham số | | parameter |
| R-218 | DC-Showtime | DC-Auditorium | Dependency | | A --> B | UsesPriceEntry nhận phòng qua tham số | | parameter |
| R-219 | DC-Auditorium | DC-Showtime | Dependency | | A --> B | DraftShowtime tạo suất chiếu dự kiến; CheckRoomGap nhận suất chiếu qua tham số | | local, parameter |
| R-220 | DC-PriceList | DC-Auditorium | Dependency | | A --> B | RemovePriceEntry nhận các phòng qua tham số | | parameter |
| R-221 | DC-ScheduleShowtimesService | DC-SeatStatus | Dependency | | A --> B | Tạo SeatStatus Trống và ReleaseHold (PKG-16 --> PKG-28 được P10 F4 cho phép) | | local |
| R-222 | DC-ScheduleShowtimesService | DC-SeatHold | Dependency | | A --> B | checkNoActiveHoldOrSoldTicket nhận lần giữ ghế qua tham số, gọi IsActiveAt | | parameter |
| R-223 | DC-ScheduleShowtimesService | DC-Ticket | Dependency | | A --> B | checkNoActiveHoldOrSoldTicket nhận vé qua tham số, gọi IsCancelled | | parameter |
| R-224 | DC-ManageAuditoriumsService | DC-SeatStatus | Dependency | | A --> B | applySeatMapToShowtimes tạo SeatStatus Trống cho ghế mới | | local |
| R-225 | DC-ManageAuditoriumsService | DC-Showtime | Dependency | | A --> B | Nạp qua IF-11 và gọi BlocksSeatMapEdit, CheckStaysPriced, AdoptSeatMap | | local |
| R-226 | DC-ManageAuditoriumsService | DC-PriceList | Dependency | | A --> B | Nạp qua IF-12, truyền vào Showtime.CheckStaysPriced | | local |
| R-227 | DC-ManagePriceListService | DC-Showtime | Dependency | | A --> B | Nạp qua IF-11, truyền vào PriceList.RemovePriceEntry | | local |
| R-228 | DC-ManagePriceListService | DC-Auditorium | Dependency | | A --> B | Nạp qua IF-13, truyền vào PriceList.RemovePriceEntry | | local |

Quan hệ P08 có một đầu ngoài phạm vi: R-29, R-32, R-86 (boundary React, PKG-05 đến PKG-10); R-53 và R-44, R-46 đã ở lõi. Quan hệ P08 không thiết kế: R-62 (xem trên); R-57 đến R-59 (không dùng, thay bằng R-66 do PKG-32).

## F6. State machine

Lớp có trạng thái trong phạm vi: DC-Showtime (ST-06) và DC-Seat (ST-07). Lớp không làm state machine: DC-Auditorium, DC-Cinema, DC-Movie (chỉ tồn tại hoặc không, mốc lastChangedAt không là trạng thái); DC-PriceEntry (cờ removed chỉ là dấu vết để phát hiện thay đổi lúc hiển thị; mọi sự kiện hợp lệ ở cả hai giá trị, bỏ mục đã bỏ bị từ chối bằng kiểm mốc ở DC-PriceList, nên không có hành vi đổi theo trạng thái).

### ST-06. Suất chiếu (DC-Showtime)

F6.1. Bảng trạng thái

| ST | Lớp | Trạng thái | Mô tả / điều kiện nhận biết | entry | do | exit |
|---|---|---|---|---|---|---|
| ST-06 | DC-Showtime | Trong lịch chiếu | status = IN_SCHEDULE; trạng thái gộp của bốn giai đoạn con dưới đây | - | - | - |
| ST-06 | DC-Showtime | Chưa mở bán | IN_SCHEDULE và now < saleOpenTime (suy ra, không lưu) | - | - | - |
| ST-06 | DC-Showtime | Đang mở bán | IN_SCHEDULE và saleOpenTime <= now < startTime | - | - | - |
| ST-06 | DC-Showtime | Đang chiếu | IN_SCHEDULE và startTime <= now < endTime | - | - | - |
| ST-06 | DC-Showtime | Đã kết thúc | IN_SCHEDULE và now >= endTime (BR-50) | - | - | - |
| ST-06 | DC-Showtime | Đã xoá | status = DELETED; ngừng bán vé, dữ liệu giữ lại cho vé đã huỷ, hoàn tiền, báo cáo (BR-58) | - | - | - |

F6.2. Bảng chuyển trạng thái

| ST | Lớp | Trạng thái | Sự kiện | Guard | Hành động | Trạng thái đích | STT | Operation tương ứng (DC.operation) | Nguồn (BR / UC bước) |
|---|---|---|---|---|---|---|---|---|---|
| ST-06 | DC-Showtime | (initial) | create(movieId, format, auditoriumId, start, saleOpen) | - | / endTime = start + thời lượng phim | (choice C1) | 1 | DC-Showtime.NewShowtime, CalculateEndTime | BR-50, BR-55, BR-56; UC-014 bước 8 |
| ST-06 | DC-Showtime | (choice C1) | - | [saleOpenTime > now] | - | Chưa mở bán | 2 | DC-Showtime.Phase | BR-01; UC-014 bước 9 |
| ST-06 | DC-Showtime | (choice C1) | - | [else] | - | Đang mở bán | 3 | DC-Showtime.Phase | BR-01, BR-55 |
| ST-06 | DC-Showtime | Chưa mở bán | when(now >= saleOpenTime) | - | - | Đang mở bán | 4 | DC-Showtime.Phase, CheckSaleOpen | BR-01 |
| ST-06 | DC-Showtime | Đang mở bán | when(now >= startTime) | - | - | Đang chiếu | 5 | DC-Showtime.Phase, CheckNotStarted | BR-45, BR-57 |
| ST-06 | DC-Showtime | Đang chiếu | when(now >= endTime) | - | - | Đã kết thúc | 6 | DC-Showtime.Phase, BlocksSeatMapEdit | BR-50, BR-87 |
| ST-06 | DC-Showtime | Chưa mở bán | applyChanges(draft, now) | [saleOpenTime mới > now] | / ghi phim, định dạng, phòng, giờ; lastChangedAt = now | Chưa mở bán | 7 | DC-Showtime.ApplyChanges | BR-53, BR-57, BR-84, BR-92; UC-014 luồng 1a |
| ST-06 | DC-Showtime | Chưa mở bán | applyChanges(draft, now) | [saleOpenTime mới <= now] | / như trên | Đang mở bán | 8 | DC-Showtime.ApplyChanges | như trên |
| ST-06 | DC-Showtime | Đang mở bán | applyChanges(draft, now) | [saleOpenTime mới <= now] | / như trên | Đang mở bán | 9 | DC-Showtime.ApplyChanges | như trên |
| ST-06 | DC-Showtime | Đang mở bán | applyChanges(draft, now) | [saleOpenTime mới > now] | / như trên | Chưa mở bán | 10 | DC-Showtime.ApplyChanges | như trên |
| ST-06 | DC-Showtime | Chưa mở bán | markDeleted(now) | [chưa tới giờ bắt đầu, không có lần giữ ghế hiệu lực hay vé chưa huỷ] | / status = DELETED; lastChangedAt = now | Đã xoá | 11 | DC-Showtime.MarkDeleted | BR-53, BR-57, BR-58, BR-60; UC-014 luồng 1b |
| ST-06 | DC-Showtime | Đang mở bán | markDeleted(now) | [như trên] | / như trên | Đã xoá | 12 | DC-Showtime.MarkDeleted | như trên |

Guard "không có lần giữ ghế hiệu lực hay vé chưa huỷ" do DC-ScheduleShowtimesService.checkNoActiveHoldOrSoldTicket kiểm trước khi gọi ApplyChanges, MarkDeleted (dữ liệu của PKG-28 không vào được PKG-27); guard "chưa tới giờ bắt đầu" do CheckNotStarted. Các guard chỉ dùng dữ liệu đã đọc dưới khoá Showtime X, SeatHold S, Ticket S ở thời điểm xét, không dùng kết quả của lời gọi ngoài. Các chuyển giữa bốn giai đoạn con là tín hiệu thời gian, không do operation nào phát; trạng thái được đọc bằng DC-Showtime.Phase.

Sự kiện bị từ chối hoặc bỏ qua:

| ST | Trạng thái | Sự kiện | Xử lý (bỏ qua / ngoại lệ <tên>) |
|---|---|---|---|
| ST-06 | Đang chiếu, Đã kết thúc | applyChanges, markDeleted | Không đổi, CheckNotStarted ném ShowtimeStartedError (BR-57, kiểm sau CheckUnchangedSince) |
| ST-06 | Đã xoá | applyChanges, markDeleted | Không đổi, CheckUnchangedSince ném ShowtimeChangedError (BR-60: đã thay đổi hoặc không còn); gọi thẳng MarkDeleted lần hai thì ném ShowtimeChangedError |
| ST-06 | Chưa mở bán | CheckSaleOpen (bán vé) | Không đổi, ném ShowtimeNotOpenError (BR-01) |
| ST-06 | Đang chiếu, Đã kết thúc, Đã xoá | CheckSaleOpen (bán vé) | Không đổi, ném ShowtimeNotOpenError (BR-45, BR-58) |

F6.3. Ánh xạ về mô hình lớp

| ST | Thuộc tính biểu diễn trạng thái | Kiểu (enumeration) | Operation được thêm/sửa |
|---|---|---|---|
| ST-06 | status (lưu) và Phase(now) (suy ra từ saleOpenTime, startTime, endTime) | ShowtimeStatus, ShowtimePhase | Thêm NewShowtime, CheckNotStarted, CalculateEndTime, ApplyChanges, MarkDeleted, Phase |

F6.4. Sơ đồ state machine. File diagrams/P12-state-Showtime.drawio. Không vẽ (final): suất chiếu Đã xoá và Đã kết thúc vẫn được giữ cho vé, hoàn tiền, báo cáo, không có sự kiện lưu trữ trong nguồn.

| ID | Loại | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| ST-06-I | Initial |  | - | - | Trạng thái đầu khi suất chiếu được tạo |
| ST-06-C1 | Choice |  | - | - | Rẽ theo saleOpenTime so với now |
| ST-06-S0 | Composite state | Trong lịch chiếu (status = IN_SCHEDULE) | - | - | Chứa bốn giai đoạn suy ra |
| ST-06-S1 | State | Chưa mở bán | - | ST-06-S0 | - |
| ST-06-S2 | State | Đang mở bán | - | ST-06-S0 | - |
| ST-06-S3 | State | Đang chiếu | - | ST-06-S0 | - |
| ST-06-S4 | State | Đã kết thúc | - | ST-06-S0 | - |
| ST-06-S5 | State | Đã xoá | - | - | Dữ liệu giữ lại (BR-58) |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn (su_kien [guard] / hanh_dong) | Ghi chú |
|---|---|---|---|---|---|
| ST-06-T1 | ST-06-I | ST-06-C1 | Transition | create(movieId, format, auditoriumId, start, saleOpen) / endTime = start + thời lượng | - |
| ST-06-T2 | ST-06-C1 | ST-06-S1 | Transition | [saleOpenTime > now] | - |
| ST-06-T3 | ST-06-C1 | ST-06-S2 | Transition | [else] | - |
| ST-06-T4 | ST-06-S1 | ST-06-S2 | Transition | when(now >= saleOpenTime) | Tín hiệu thời gian |
| ST-06-T5 | ST-06-S2 | ST-06-S3 | Transition | when(now >= startTime) | Tín hiệu thời gian |
| ST-06-T6 | ST-06-S3 | ST-06-S4 | Transition | when(now >= endTime) | Tín hiệu thời gian |
| ST-06-T7 | ST-06-S1 | ST-06-S1 | Transition | applyChanges [saleOpenTime mới > now] / lastChangedAt = now | Tự chuyển |
| ST-06-T8 | ST-06-S1 | ST-06-S2 | Transition | applyChanges [saleOpenTime mới <= now] / lastChangedAt = now | - |
| ST-06-T9 | ST-06-S2 | ST-06-S2 | Transition | applyChanges [saleOpenTime mới <= now] / lastChangedAt = now | Tự chuyển |
| ST-06-T10 | ST-06-S2 | ST-06-S1 | Transition | applyChanges [saleOpenTime mới > now] / lastChangedAt = now | - |
| ST-06-T11 | ST-06-S1 | ST-06-S5 | Transition | markDeleted [không bị dùng] / status = DELETED | - |
| ST-06-T12 | ST-06-S2 | ST-06-S5 | Transition | markDeleted [không bị dùng] / status = DELETED | - |

### ST-07. Ghế của phòng chiếu (DC-Seat)

F6.1. Bảng trạng thái

| ST | Lớp | Trạng thái | Mô tả / điều kiện nhận biết | entry | do | exit |
|---|---|---|---|---|---|---|
| ST-07 | DC-Seat | Trong sơ đồ ghế | mapState = IN_MAP; tính vào sức chứa | - | - | - |
| ST-07 | DC-Seat | Đã bỏ khỏi sơ đồ ghế | mapState = RETIRED; không tính vào sức chứa, giữ lại cho trạng thái ghế của suất chiếu đã kết thúc hoặc đã xoá (BR-118) | - | - | - |

F6.2. Bảng chuyển trạng thái

| ST | Lớp | Trạng thái | Sự kiện | Guard | Hành động | Trạng thái đích | STT | Operation tương ứng (DC.operation) | Nguồn (BR / UC bước) |
|---|---|---|---|---|---|---|---|---|---|
| ST-07 | DC-Seat | (initial) | create(rowCode, seatNumber, seatType) | [CheckSeatValid đạt, sức chứa 50 đến 400] | - | Trong sơ đồ ghế | 1 | DC-Seat.NewSeat | BR-144, REQ-16; UC-012 bước 4, 5 |
| ST-07 | DC-Seat | Trong sơ đồ ghế | retire() | - | / mapState = RETIRED | Đã bỏ khỏi sơ đồ ghế | 2 | DC-Seat.RetireFromSeatMap | BR-118; UC-012 bước 5 luồng 1a |
| ST-07 | DC-Seat | Trong sơ đồ ghế | retype(seatType) | - | / seatType = seatType mới | Trong sơ đồ ghế | 3 | DC-Seat.SetType | BR-73; UC-012 bước 5 luồng 1a |

Sự kiện bị từ chối hoặc bỏ qua:

| ST | Trạng thái | Sự kiện | Xử lý (bỏ qua / ngoại lệ <tên>) |
|---|---|---|---|
| ST-07 | Đã bỏ khỏi sơ đồ ghế | retire, retype | Không đổi, ném SeatStateError |

F6.3. Ánh xạ về mô hình lớp

| ST | Thuộc tính biểu diễn trạng thái | Kiểu (enumeration) | Operation được thêm/sửa |
|---|---|---|---|
| ST-07 | mapState | SeatMapState | Thêm NewSeat, RetireFromSeatMap, SetType, InMap |

F6.4. Sơ đồ state machine. File diagrams/P12-state-Seat.drawio. Không vẽ (final): ghế đã bỏ vẫn giữ để tham chiếu từ trạng thái ghế của suất chiếu cũ, nguồn không nêu sự kiện lưu trữ. Lớp chỉ có hai trạng thái, giữ vì BR-118 buộc tồn tại trạng thái Đã bỏ (ghế không xoá).

| ID | Loại | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| ST-07-I | Initial |  | - | - | Trạng thái đầu |
| ST-07-S1 | State | Trong sơ đồ ghế | - | - | - |
| ST-07-S2 | State | Đã bỏ khỏi sơ đồ ghế | - | - | - |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn (su_kien [guard] / hanh_dong) | Ghi chú |
|---|---|---|---|---|---|
| ST-07-T1 | ST-07-I | ST-07-S1 | Transition | create(rowCode, seatNumber, seatType) | - |
| ST-07-T2 | ST-07-S1 | ST-07-S2 | Transition | retire() / mapState = RETIRED | - |
| ST-07-T3 | ST-07-S1 | ST-07-S1 | Transition | retype(seatType) | Tự chuyển |

## F7. Bảng thuộc tính

Thuộc tính trỏ tới lớp khác là association (F5) nên không lặp lại: DC-Auditorium.cinemaId (R-38), DC-PriceList.cinemaId (R-40), DC-Showtime.auditoriumId (R-42), DC-Showtime.movieId (R-43), DC-Auditorium.seats (R-39), DC-PriceList.entries (R-41). Lớp dịch vụ của PKG-16 chỉ có các phụ thuộc tiêm (F5), không có thuộc tính khác. Thuộc tính của DC-Showtime, DC-PriceList đã có ở lõi (id, startTime, saleOpenTime, endTime, lastChangedAt, movieFormat, status, /cinemaId, MaxSeatsPerHold) giữ nguyên, riêng movieFormat đổi kiểu string thành MovieFormat (F1b). Phần định danh "gán khi lưu" như lõi.

| DC | Visibility | Tên | Kiểu | Multiplicity | Mặc định | Ràng buộc | Phạm vi | Derived (Có: công thức / Không) | Nguồn (AC / BR / ST / method) | Mô tả |
|---|---|---|---|---|---|---|---|---|---|---|
| DC-Cinema | - | id | CinemaId | 1 | - | {id} | Instance | Không | P12 | Định danh, gán khi lưu; khoá hạng 0 |
| DC-Cinema | - | name | string | 1 | - | {không trống, duy nhất theo NormalizeName} | Instance | Không | AC-E-Cinema, BR-141 | Tên cụm rạp (VARCHAR 100) |
| DC-Cinema | - | province | string | 1 | - | {không trống} | Instance | Không | AC-E-Cinema, Q-204 | Tỉnh hoặc thành phố |
| DC-Cinema | - | address | string | 0..1 | - | - | Instance | Không | AC-E-Cinema | Địa chỉ |
| DC-Cinema | - | lastChangedAt | time.Time | 1 | - | - | Instance | Không | BR-142, Q-247 | Mốc thay đổi gần nhất |
| DC-Auditorium | - | id | AuditoriumId | 1 | - | {id} | Instance | Không | P12 | Định danh, gán khi lưu; khoá hạng 2 |
| DC-Auditorium | - | name | string | 1 | - | {không trống, duy nhất trong cụm rạp theo NormalizeName} | Instance | Không | AC-E-Auditorium, BR-145 | Tên phòng |
| DC-Auditorium | - | auditoriumType | AuditoriumType | 1 | STANDARD | - | Instance | Không | AC-E-Auditorium, REQ-02 | Loại phòng |
| DC-Auditorium | - | formats | []MovieFormat | 1..2 | - | {không trùng} | Instance | Không | AC-E-Auditorium (supportedFormats), BR-48 | Định dạng chiếu được |
| DC-Auditorium | - | lastChangedAt | time.Time | 1 | - | - | Instance | Không | BR-146, Q-247 | Mốc thay đổi gần nhất |
| DC-Auditorium | + | MinCapacity | int | 1 | 50 | {readOnly} | Classifier | Không | BR-144 | Sức chứa tối thiểu |
| DC-Auditorium | + | MaxCapacity | int | 1 | 400 | {readOnly} | Classifier | Không | BR-144 | Sức chứa tối đa |
| DC-Auditorium | + | RoomGap | time.Duration | 1 | 15 * time.Minute | {readOnly} | Classifier | Không | BR-51 | Khoảng dọn phòng giữa hai suất chiếu |
| DC-Seat | - | id | SeatId | 1 | - | {id} | Instance | Không | P12 | Định danh, gán khi lưu |
| DC-Seat | - | rowCode | string | 1 | - | {1 đến 3 ký tự} | Instance | Không | AC-E-Seat (seatPosition) | Mã hàng (VARCHAR 3) |
| DC-Seat | - | seatNumber | int | 1 | - | {> 0} | Instance | Không | AC-E-Seat (seatPosition) | Số ghế trong hàng |
| DC-Seat | - | seatType | SeatType | 1 | STANDARD | - | Instance | Không | AC-E-Seat, REQ-16 | Loại ghế |
| DC-Seat | - | mapState | SeatMapState | 1 | IN_MAP | - | Instance | Không | AC-E-Seat (inSeatMap), ST-07 | Trạng thái trong sơ đồ ghế |
| DC-Movie | - | id | MovieId | 1 | - | {id} | Instance | Không | P12 | Định danh, gán khi lưu; khoá hạng 10 |
| DC-Movie | - | title | string | 1 | - | {không trống} | Instance | Không | AC-E-Movie | Tên phim, được trùng tên phim khác (Q-200) |
| DC-Movie | - | durationMinutes | int | 1 | - | {> 0} | Instance | Không | AC-E-Movie (duration), BR-50 | Thời lượng, phút |
| DC-Movie | - | releaseDate | time.Time | 1 | - | {ngày} | Instance | Không | AC-E-Movie, BR-49 | Ngày khởi chiếu |
| DC-Movie | - | endOfRunDate | time.Time | 1 | - | {ngày, >= releaseDate} | Instance | Không | AC-E-Movie, BR-49 | Ngày kết thúc chiếu |
| DC-Movie | - | genre | string | 1 | - | {không trống} | Instance | Không | AC-E-Movie, Q-196 | Thể loại |
| DC-Movie | - | ageRating | AgeRating | 1 | - | - | Instance | Không | AC-E-Movie, Q-199 | Nhãn độ tuổi |
| DC-Movie | - | description | string | 1 | - | - | Instance | Không | AC-E-Movie | Mô tả |
| DC-Movie | - | trailer | string | 0..1 | - | {đường dẫn tới video ngoài hệ thống} | Instance | Không | AC-E-Movie, Q-198 | Trailer |
| DC-Movie | - | releaseFormats | []MovieFormat | 1..2 | - | {không trùng} | Instance | Không | AC-E-Movie, BR-47 | Định dạng phát hành |
| DC-Movie | - | /movieCode | string | 1 | - | - | Instance | Có: "M" cộng id đệm số 0 đến 5 chữ số | AC-E-Movie (movieCode) | Mã phim hệ thống cấp, phân biệt phim trùng tên; không lưu cột riêng |
| DC-Movie | - | lastChangedAt | time.Time | 1 | - | - | Instance | Không | BR-138, Q-247 | Mốc thay đổi gần nhất |
| DC-PriceList | + | BusinessZone | *time.Location | 1 | Asia/Ho_Chi_Minh | {readOnly} | Classifier | Không | Q-268 | Múi giờ nghiệp vụ của khung giờ |
| DC-PriceEntry | - | auditoriumType | AuditoriumType | 1 | - | {thuộc khoá tổ hợp} | Instance | Không | AC-E-PriceEntry, BR-62 | Loại phòng của tổ hợp |
| DC-PriceEntry | - | movieFormat | MovieFormat | 1 | - | {thuộc khoá tổ hợp} | Instance | Không | AC-E-PriceEntry, BR-62 | Định dạng của tổ hợp |
| DC-PriceEntry | - | seatType | SeatType | 1 | - | {thuộc khoá tổ hợp} | Instance | Không | AC-E-PriceEntry, BR-62 | Loại ghế của tổ hợp |
| DC-PriceEntry | - | timeBand | TimeBand | 1 | - | {thuộc khoá tổ hợp} | Instance | Không | AC-E-PriceEntry, BR-12 | Khung giờ của tổ hợp |
| DC-PriceEntry | - | ticketPrice | Money | 1 | - | {> 0} | Instance | Không | AC-E-PriceEntry, BR-70 | Giá vé của tổ hợp, đồng |
| DC-PriceEntry | - | lastChangedAt | time.Time | 1 | - | - | Instance | Không | AC-E-PriceList (entryChangeTimes), BR-63 | Mốc thay đổi của tổ hợp, kể cả khi bỏ |
| DC-PriceEntry | - | removed | bool | 1 | false | - | Instance | Không | BR-71, BR-63 | Mục đã bỏ khỏi bảng giá, giữ làm dấu vết mốc |

## F8. Class diagram

| Sơ đồ | Phạm vi (PKG / UC) | File .drawio | Số lớp |
|---|---|---|---|
| P12-class-PKG-16 | PKG-16 | diagrams/P12-class-PKG-16.drawio | 3 (kèm 7 tham chiếu) |
| P12-class-PKG-27 | PKG-27 | diagrams/P12-class-PKG-27.drawio | 15 (kèm 3 tham chiếu) |

Sơ đồ PKG-16 chỉ vẽ lớp dịch vụ và interface được dùng; dependency tới entity của package khác (R-30 đến R-37, R-87 đến R-89, R-221 đến R-228) ở F5, không vẽ. Sơ đồ PKG-27 gồm mọi lớp của package có trong F2 (kể cả lớp lõi IF-08, IF-25, IF-24, DC-RandomCodeGenerator) và cạnh R-44, R-46, R-53, R-60, R-141 của lõi. Cạnh association B --> A vẽ đầu mũi mở ở phía Lớp A. Multiplicity của cạnh tiêm phụ thuộc (A 0..* - B 1) không vẽ nhãn để sơ đồ không nhiễu (cùng quy ước lõi). Ngăn thuộc tính và operation lấy đúng từ F7, F2 (ngăn thuộc tính của lớp dịch vụ rỗng vì chỉ có phụ thuộc tiêm).

F8.P12-class-PKG-16 P12 Lớp PKG-16 ScheduleAndPricing

| ID | Loại (Class / Interface / Enumeration / Package / Note) | Nhãn (tên lớp) | Stereotype | Thuộc về (PKG) | Ghi chú (lớp ngoài package: "tham chiếu") |
|---|---|---|---|---|---|
| DC-ManagePriceListService | Class | ManagePriceListService | «service» | PKG-16 |  |
| DC-ScheduleShowtimesService | Class | ScheduleShowtimesService | «service» | PKG-16 |  |
| DC-ManageAuditoriumsService | Class | ManageAuditoriumsService | «service» | PKG-16 |  |
| IF-08 | Interface | IUnitOfWork | «interface» | PKG-27 | tham chiếu |
| IF-11 | Interface | IShowtimeRepository | «interface» | PKG-27 | tham chiếu |
| IF-12 | Interface | IPriceListRepository | «interface» | PKG-27 | tham chiếu |
| IF-13 | Interface | ICinemaRepository | «interface» | PKG-27 | tham chiếu |
| IF-14 | Interface | IMovieRepository | «interface» | PKG-27 | tham chiếu |
| IF-18 | Interface | ISeatStatusRepository | «interface» | PKG-28 | tham chiếu |
| IF-29 | Interface | IShowtimeGuardRepository | «interface» | PKG-28 | tham chiếu |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| R-200 | DC-ManagePriceListService | IF-08 | Association |  | Tiêm phụ thuộc, không nhãn |
| R-201 | DC-ManagePriceListService | IF-12 | Association |  | Tiêm phụ thuộc, không nhãn |
| R-202 | DC-ManagePriceListService | IF-13 | Association |  | Tiêm phụ thuộc, không nhãn |
| R-203 | DC-ManagePriceListService | IF-11 | Association |  | Tiêm phụ thuộc, không nhãn |
| R-204 | DC-ScheduleShowtimesService | IF-08 | Association |  | Tiêm phụ thuộc, không nhãn |
| R-205 | DC-ScheduleShowtimesService | IF-11 | Association |  | Tiêm phụ thuộc, không nhãn |
| R-206 | DC-ScheduleShowtimesService | IF-12 | Association |  | Tiêm phụ thuộc, không nhãn |
| R-207 | DC-ScheduleShowtimesService | IF-13 | Association |  | Tiêm phụ thuộc, không nhãn |
| R-208 | DC-ScheduleShowtimesService | IF-14 | Association |  | Tiêm phụ thuộc, không nhãn |
| R-209 | DC-ScheduleShowtimesService | IF-29 | Association |  | Tiêm phụ thuộc, không nhãn |
| R-210 | DC-ScheduleShowtimesService | IF-18 | Association |  | Tiêm phụ thuộc, không nhãn |
| R-211 | DC-ManageAuditoriumsService | IF-08 | Association |  | Tiêm phụ thuộc, không nhãn |
| R-212 | DC-ManageAuditoriumsService | IF-11 | Association |  | Tiêm phụ thuộc, không nhãn |
| R-213 | DC-ManageAuditoriumsService | IF-12 | Association |  | Tiêm phụ thuộc, không nhãn |
| R-214 | DC-ManageAuditoriumsService | IF-13 | Association |  | Tiêm phụ thuộc, không nhãn |
| R-215 | DC-ManageAuditoriumsService | IF-29 | Association |  | Tiêm phụ thuộc, không nhãn |
| R-216 | DC-ManageAuditoriumsService | IF-18 | Association |  | Tiêm phụ thuộc, không nhãn |

F8.P12-class-PKG-27 P12 Lớp PKG-27 CinemaOperations

| ID | Loại (Class / Interface / Enumeration / Package / Note) | Nhãn (tên lớp) | Stereotype | Thuộc về (PKG) | Ghi chú (lớp ngoài package: "tham chiếu") |
|---|---|---|---|---|---|
| DC-Cinema | Class | Cinema | «entity» | PKG-27 |  |
| DC-Auditorium | Class | Auditorium | «entity» | PKG-27 |  |
| DC-Seat | Class | Seat | «entity» | PKG-27 |  |
| DC-Movie | Class | Movie | «entity» | PKG-27 |  |
| DC-Showtime | Class | Showtime | «entity» | PKG-27 |  |
| DC-PriceList | Class | PriceList | «entity» | PKG-27 |  |
| DC-PriceEntry | Class | PriceEntry | «entity» | PKG-27 |  |
| IF-11 | Interface | IShowtimeRepository | «interface» | PKG-27 |  |
| IF-12 | Interface | IPriceListRepository | «interface» | PKG-27 |  |
| IF-13 | Interface | ICinemaRepository | «interface» | PKG-27 |  |
| IF-14 | Interface | IMovieRepository | «interface» | PKG-27 |  |
| IF-08 | Interface | IUnitOfWork | «interface» | PKG-27 |  |
| IF-25 | Interface | Tx | «interface» | PKG-27 |  |
| IF-24 | Interface | ICodeGenerator | «interface» | PKG-27 |  |
| DC-RandomCodeGenerator | Class | RandomCodeGenerator | «utility» | PKG-27 |  |
| DC-SeatStatus | Class | SeatStatus | «entity» | PKG-28 | tham chiếu |
| DC-SeatHold | Class | SeatHold | «entity» | PKG-28 | tham chiếu |
| DC-Ticket | Class | Ticket | «entity» | PKG-28 | tham chiếu |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| R-38 | DC-Cinema | DC-Auditorium | Aggregation | A 1 - B 0..* |  |
| R-39 | DC-Auditorium | DC-Seat | Composition | A 1 - B 50..400 |  |
| R-40 | DC-Cinema | DC-PriceList | Association (điều hướng B --> A) | A 1 - B 1 |  |
| R-41 | DC-PriceList | DC-PriceEntry | Composition | A 1 - B 0..72 |  |
| R-42 | DC-Auditorium | DC-Showtime | Association (điều hướng B --> A) | A 1 - B 0..* |  |
| R-43 | DC-Showtime | DC-Movie | Association | A 0..* - B 1 |  |
| R-44 | DC-Showtime | DC-SeatStatus | Association (điều hướng B --> A) | A 1 - B 1..* |  |
| R-46 | DC-Showtime | DC-SeatHold | Association (điều hướng B --> A) | A 1 - B 0..* |  |
| R-53 | DC-Ticket | DC-Showtime | Association | A 0..* - B 1 |  |
| R-60 | DC-Showtime | DC-PriceList | Dependency |  |  |
| R-61 | DC-PriceList | DC-Showtime | Dependency |  |  |
| R-141 | DC-RandomCodeGenerator | IF-24 | Realization |  |  |
| R-217 | DC-Showtime | DC-Movie | Dependency |  |  |
| R-218 | DC-Showtime | DC-Auditorium | Dependency |  |  |
| R-219 | DC-Auditorium | DC-Showtime | Dependency |  |  |
| R-220 | DC-PriceList | DC-Auditorium | Dependency |  |  |

## F9. Gán package và kiểm tra phụ thuộc package

| PKG | Lớp (DC) | Phụ thuộc vào PKG (suy từ F5) | Hợp lệ theo P09 (Có / Không: lý do) |
|---|---|---|---|
| PKG-16 | DC-ManagePriceListService, DC-ScheduleShowtimesService, DC-ManageAuditoriumsService | PKG-27 (IF-08, IF-11 đến IF-14, DC-Cinema, DC-Auditorium, DC-Movie, DC-Showtime, DC-PriceList); PKG-28 (IF-18, IF-29, DC-ActorContext, DC-SeatStatus, DC-SeatHold, DC-Ticket) | Có: Application --> Domain, đúng tập PKG-21, PKG-27, PKG-28 của P10 F4 (không dùng PKG-21); không có phụ thuộc ngược |
| PKG-27 | DC-Cinema, DC-Auditorium, DC-Seat, DC-Movie, DC-Showtime, DC-PriceList, DC-PriceEntry, IF-11 đến IF-14 | Không phụ thuộc package nào khác; R-44, R-46, R-53 với PKG-28 có chiều B --> A (PKG-28 --> PKG-27) | Có: PKG-27 không phụ thuộc PKG-28 (P09 F4); Showtime không gọi SeatHold, SeatStatus, Ticket (Q-117) nên phần kiểm lần giữ ghế, vé nằm ở PKG-16 |
| PKG-28 | IF-29 | PKG-27 (ShowtimeId, SeatKey, các kiểu mã) | Có: Domain --> Domain một chiều giống IF-17, IF-18; không đi lên layer trên |

Gán package: IF-29 đặt ở PKG-28 vì trả DC-SeatHold, DC-Ticket, DC-SeatStatus (cùng aggregate PKG-28) và để PKG-27 không phải thấy kiểu của PKG-28. Các kiểu yêu cầu và kết quả của dịch vụ (DC-PriceEntryRequest, DC-NewShowtimeRequest, DC-ShowtimeEditView...) đặt ở PKG-16 vì chỉ dùng ở chữ ký công khai của PKG-16 và PKG-11. Lớp mới có visibility public hoặc được package khác dùng: IF-29, DC-ShowtimeInUseError và các kiểu F1b của PKG-27 dùng trong chữ ký public (ghi ở Đề xuất sửa artifact trước, dòng P10).

## F10. Design pattern đã áp dụng

| Pattern | Vấn đề trong thiết kế này | Lớp tham gia (vai trò trong pattern) | Lý do chọn | Phương án đơn giản hơn đã xét |
|---|---|---|---|---|
| Repository (đã chọn ở P10 cơ chế Persistence; Domain định nghĩa interface, PKG-21 hiện thực) | Tách truy cập dữ liệu và khoá theo hạng khỏi quy tắc nghiệp vụ của entity | IF-11 đến IF-14, IF-29 (interface kho); DC-PgCinemaOperationsStore, DC-PgTicketingStore (hiện thực, PKG-21) | P09 F5 và MAU_THIET_KE_DA_CHOT: Domain không thấy pgx; bản giả kho cho X2 | Entity tự chạy SQL: không đạt vì làm Domain phụ thuộc pgx và entity phải thấy chuỗi khoá (Q-117) |
| Strategy (không áp dụng) | Khung giờ giá (BR-12) và khoảng dọn phòng (BR-51) là hằng nghiệp vụ, không có biến thể theo cấu hình | - | YAGNI: chỉ có bốn khung giờ cố định, một hàm DetermineTimeBand | - |

Không áp dụng pattern thêm.

## Câu hỏi mở

Không có. Dải Q-292 đến Q-301 được cấp cho phiên không dùng tới (để trống cho X3 ghi lại). Các Q đã chốt theo đề xuất mà thiết kế dựa vào: Q-109, Q-117, Q-196 đến Q-200, Q-204, Q-209, Q-212, Q-245 đến Q-251, Q-253, Q-266, Q-268 (xem các cột nguồn của F2, F3).

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Người quyết | Đề xuất |
|---|---|---|---|---|---|

## Giả định

Không có (CHE_DO_GIA_DINH là NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P13 | cinema, movie, auditorium, seat, showtime, price_entry | Schema 1.5 thiếu cột của P08 2.0: cinema.province và last_changed_at; movie.trailer, last_changed_at (movie_code không cần cột, suy từ id); auditorium.last_changed_at; seat.in_seat_map (BOOLEAN, mặc định true); cột giá trị norm_name cho chỉ mục unique tên cụm rạp, tên phòng | Thêm cột trên. Ràng buộc uq_seat_position đổi thành unique từng phần WHERE in_seat_map để vị trí của ghế đã bỏ nhập lại thành ghế mới (ComputeSeatMapChange) |

## Vấn đề còn mở

1. Phạm vi: 15 lớp có hành vi (3 dịch vụ, 7 entity, 4 interface kho của PKG-27, IF-29), trong ngưỡng 15 đến 20 của một lượt theo package.
2. DC-Showtime có 28 operation public và DC-Auditorium 20, vượt hoặc ngang ngưỡng 15 đến 20 của F1. Giữ theo P10 Vấn đề còn mở 10: phần lớn là kiểm nhỏ cùng một aggregate và getter cần cho X2; mười operation đầu của DC-Showtime thuộc lõi. Nếu X1 thấy quá lớn: tách DC-ShowtimeSchedulingRules (CheckNotStarted, CheckSaleOpenBeforeStart, CheckRoomChangeAllowed, AdoptSeatMap, UsesPriceEntry, BlocksSeatMapEdit, CheckStaysPriced) ra một lớp dịch vụ miền không giữ dữ liệu.
3. DC-ScheduleShowtimesService có bảy phụ thuộc tiêm và gộp lập mới, sửa (hai operation cùng EX-13). Giữ vì Q-117 buộc một nơi thấy cả chuỗi khoá và vì phần thân dùng chung. Nếu X1 thấy quá lớn: tách phần sửa sang lớp riêng cùng PKG-16.
4. Không làm state machine cho DC-Auditorium, DC-Cinema, DC-Movie (chỉ có tạo, sửa, xoá, không operation nào đổi kết quả theo trạng thái) và DC-PriceEntry (xem F6). DC-Seat chỉ có hai trạng thái, giữ ST-07 vì BR-118.
5. CreateShowtime và UpdateShowtime đọc phòng, phim, bảng giá hai lần (giai đoạn A không khoá để báo lỗi đúng thứ tự P04 và phản hồi sớm; giai đoạn B dưới khoá để quyết định). Thiết kế: UC quản lý có tải thấp nên chi phí đọc thêm chấp nhận được; nếu bỏ giai đoạn A thì thứ tự báo lỗi 5a, 5b, 5c, 6a, 6b, 6c của P04 vẫn giữ được vì cùng chạy tuần tự dưới khoá, và RecheckMovie (8g) trở thành bước trùng.
6. UpdateShowtime lấy phòng hiện tại bằng đọc không khoá để biết cần khoá phòng nào (cùng nguyên tắc FindRouting của EX-01), rồi so lại dưới khoá Showtime X; khác thì thử lại tối đa hai lần, quá thì SystemBusyError.
7. Các đồng bộ cần ở lượt khác: hiện thực SQL của IF-11 đến IF-14, IF-29 (PKG-21); schema cột mới (P13); P11a ánh xạ thông điệp cho lỗi mới (AuditoriumGoneError, ShowtimeInUseError, PriceEntryInUseError...) khi chạy lại P11a.
8. Mã không dùng trong dải của phiên: R-229 đến R-239, ST-08, ST-09, IF-30, IF-31, Q-292 đến Q-301; để X3 ghi lại.
9. Đã đóng: operation cho UC-003, UC-004, UC-015, UC-016 ở mục 0.2 (mục giữ số thứ tự để tham chiếu không lệch).
10. Target 7: message từ tác nhân tới boundary giao diện (STT 1, 2, 1a, 1b, ...) không có dòng ở F4 vì boundary React thuộc PKG-05 đến PKG-10.
