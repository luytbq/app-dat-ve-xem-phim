# P12 - Thiết kế lớp - PKG-17 Catalog, PKG-18 Reporting, PKG-30 ChainManagement, PKG-33 ReportModel - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P12 |
| Phiên bản | 2.2 |
| Thay đổi 2.2 | Đồng bộ X3 lần 6 (design/_sync-log.md): DC-BrowseShowtimesService, DC-ViewChainReportService phụ thuộc IF-47 ICinemaReader thay IF-13 (R-483, R-484 thay R-244, R-254; RV-16) |
| Đầu vào đã dùng | 00-Conventions.md (C10); 00-Concurrency.md (M7); project-profile.md; P04-uc-specs UC-003, UC-004, UC-010, UC-011, UC-015, UC-016 và _BR-register.md (BR-76, BR-77, BR-84, BR-88, BR-115 đến BR-119, BR-134, BR-138, BR-139, BR-141, BR-142); P06-supplementary-spec.md; P07-uc-analysis UC-003, UC-004, UC-010, UC-011, UC-015, UC-016 (bảng message, Câu hỏi mở, Đề xuất sửa artifact trước); P08-analysis-model.md 2.0 (F3, F4, F4b EX-16, EX-17); P09-architecture.md 2.0 (F7.2, F7.3, F7.10, F7.12, Q-268, Q-269); P10-design-elements.md 2.0 (F3, F3a EX-16, EX-17, F4, F5, F6); P11a-gui SCR-23 đến SCR-25, SCR-30, SCR-32 đến SCR-36; P12-class-design.md 1.6 (lõi, chỉ đọc, quy ước mục 0.2, 0.3 và chữ ký IF-08, IF-11, IF-13, IF-25, DC-Money, DC-CinemaIds, DC-TxOptions); _sync-log.md (mục Đầu vào cho lần chạy lại P08-P13, dòng P12). P12-class-design/PKG-16-PKG-27-schedule-and-catalog-domain.md chưa có khi chạy. Dải mã của phiên (C10): R-240 đến R-269, ST-10 đến ST-11, IF-32 đến IF-34, Q-302 đến Q-311. Q đến Q-282 coi như đã chốt theo đề xuất |
| Phạm vi | PKG-30 ChainManagement, PKG-17 Catalog, PKG-18 Reporting, PKG-33 ReportModel; UC-003, UC-004, UC-010, UC-011, UC-015, UC-016. Lớp miền Movie, Cinema, Showtime thuộc PKG-27 do phiên khác thiết kế song song: ở đây chỉ dùng tên DC và operation đã có ở P10 2.0 hoặc P12-class-design.md, operation miền cần thêm ghi ở mục Đề xuất sửa artifact trước |
| Mã Q, ASM cuối đã cấp | Q-304 (Q-302 đến Q-304 cấp ở file này, dải Q-302 đến Q-311); không có ASM (NGHIEM_NGAT). R-269 là mã cuối của dải R; không dùng ST-10, ST-11, IF-32 đến IF-34 |

Trọng tâm: biến sáu lớp control đọc và ghi danh mục thành lớp dịch vụ Go lập trình được và đặt đúng ranh giới giao dịch của EX-16, EX-17. Bốn điểm chốt: (1) UC-003, UC-004, UC-015, UC-016 chỉ đọc, không là EX, không khoá; báo cáo chạy trong một giao dịch REPEATABLE READ READ ONLY ở pool báo cáo để doanh thu và sức chứa cùng một ảnh chụp (P09 F7.12); (2) phép cộng theo nhóm trong P07 (duyệt từng suất chiếu rồi gửi // addShowtimeFigures) được thay bằng số liệu đã gộp do IF-28 trả, nên không có lớp nào ở PKG-18 duyệt từng suất chiếu hay từng vé; (3) lưu phim (EX-16) khoá một dòng phim hạng 10 rồi so mốc bằng nhau, lưu cụm rạp (EX-17) khoá giá trị tên cụm rạp rồi khoá Cinema hạng 0, kiểm tên trước mốc (5b trước 5a); (4) không lớp nào ở bốn package có vòng đời đáng kể nên không có state machine (mục F6).

Kết quả: 9 phần tử có hành vi chi tiết hoá (6 lớp dịch vụ, 2 entity không lưu, 1 interface IF-28), 19 kiểu phụ trợ (F1b), 30 quan hệ (R-240 đến R-269 và 9 mã R của P08 giữ nguyên), 3 class diagram, 0 state machine, 3 câu hỏi mở mới.

## 0. Quy ước áp dụng

- Ngôn ngữ và kiểu: Go, theo mục 0.2 và 0.3 của P12-class-design.md (Ctx là context.Context, Tx là IF-25, Money là DC-Money, định danh là DC-CinemaIds, operation public in hoa đầu, mọi operation có I/O nhận ctx đầu tiên, lỗi nghiệp vụ là kiểu lỗi có tên).
- Kiểu của PKG-27 dùng ở đây (định nghĩa ở F1b của file PKG-16-PKG-27): BusinessDate (ngày nghiệp vụ theo Asia/Ho_Chi_Minh, Q-268), MovieId, RunStatus (NOW_SHOWING, COMING_SOON, ENDED), AgeRating, MovieFormat, AuditoriumType, MovieDraft, CinemaDraft, MovieInfo, CinemaInfo, FieldInvalidError, MovieChangedError, CinemaChangedError, CinemaNameTakenError.
- Thời điểm hiện tại: lớp dịch vụ lấy từ Tx.Now của giao dịch đang mở (IF-25), không gọi đồng hồ hệ thống; múi giờ nghiệp vụ là thuộc tính zone nhận qua constructor. Entity nhận thời điểm qua tham số.
- Mốc thay đổi (lastChangedAt) truyền ra trình duyệt và gửi lại nguyên giá trị dạng chuỗi; so bằng nhau chính xác tới micro giây (P09 F7.3 EX-16, EX-17). Trình duyệt không được đổi mốc sang kiểu Date của JavaScript vì mất độ chính xác dưới mili giây.
- Lớp dịch vụ trả entity (Movie, Cinema) ra PKG-11, như quyết định hoãn DTO ở chữ ký công khai của lõi (SY-23); riêng PKG-17 và PKG-18 trả kiểu kết quả riêng vì cần dựng nhóm, phân loại.
- Hủy yêu cầu (luồng *a của UC-010, UC-011) không có operation: control không giữ trạng thái chờ giữa hai yêu cầu (P09 A7) nên huỷ là bỏ yêu cầu ở trình duyệt.

## F1. Bảng lớp thiết kế

| DC | Tên | Stereotype | PKG | Trách nhiệm | Nguồn AC | Loại | Persistent | Ghi chú thiết kế |
|---|---|---|---|---|---|---|---|---|
| DC-BrowseMoviesService | BrowseMoviesService | «control» | PKG-17 | Điều phối việc phân nhóm phim đang chiếu, sắp chiếu và lấy thông tin phim cho khách, chỉ đọc | AC-C-BrowseMoviesController | class | Không | P10 F3 đổi Controller thành Service; không là EX; mở giao dịch đọc qua IF-08, không khoá |
| DC-BrowseShowtimesService | BrowseShowtimesService | «control» | PKG-17 | Điều phối việc liệt kê phim, cụm rạp và lịch chiếu thoả tiêu chí lọc cho khách, chỉ đọc | AC-C-BrowseShowtimesController | class | Không | P10 F3 đổi Controller thành Service; không là EX; lọc theo ngày chiếu theo múi giờ nghiệp vụ (Q-268) |
| DC-ViewCinemaReportService | ViewCinemaReportService | «control» | PKG-18 | Điều phối việc lập báo cáo doanh thu và tỉ lệ lấp đầy của một cụm rạp trong một kỳ, chỉ đọc | AC-C-ViewCinemaReportController | class | Không | P10 F3 đổi Controller thành Service; không là EX; giao dịch REPEATABLE READ READ ONLY ở pool báo cáo (P09 F7.12) |
| DC-ViewChainReportService | ViewChainReportService | «control» | PKG-18 | Điều phối việc lập báo cáo toàn chuỗi và so sánh các cụm rạp trong một kỳ, chỉ đọc | AC-C-ViewChainReportController | class | Không | P10 F3 đổi Controller thành Service; không là EX; mọi cụm rạp của chuỗi có dòng trong mỗi nhóm (Q-237) |
| DC-ManageMoviesService | ManageMoviesService | «control» | PKG-30 | Điều phối việc liệt kê, thêm và sửa phim của chuỗi và là ranh giới giao dịch của EX-16 | AC-C-ManageMoviesController | class | Không | P10 F3 đổi Controller thành Service; EX-16 chỉ khi sửa (hạng 10), thêm phim không là EX (Q-200) |
| DC-ManageCinemasService | ManageCinemasService | «control» | PKG-30 | Điều phối việc liệt kê, thêm và sửa cụm rạp của chuỗi và là ranh giới giao dịch của EX-17 | AC-C-ManageCinemasController | class | Không | P10 F3 đổi Controller thành Service; EX-17 gồm khoá giá trị tên cụm rạp rồi khoá Cinema (hạng 0); thêm cụm rạp tạo kèm bảng giá rỗng |
| DC-ReportPeriod | ReportPeriod | «entity» | PKG-33 | Giữ từ ngày, đến ngày của một yêu cầu báo cáo, kiểm tính hợp lệ và đổi thành khoảng thời điểm | AC-E-ReportPeriod | class | Không | Không lưu, chỉ sống trong một yêu cầu báo cáo (P10 F3) |
| DC-ReportGroup | ReportGroup | «entity» | PKG-33 | Cộng số liệu của các suất chiếu thuộc một khoá nhóm và tính tỉ lệ lấp đầy của nhóm | AC-E-ReportGroup | class | Không | Không lưu; nhận số liệu đã gộp của IF-28 thay vì duyệt từng suất chiếu (P09 F7.12) |
| IF-28 | IReportRepository | «interface» | PKG-33 | Cung cấp số liệu báo cáo đã gộp theo khoá nhóm trong một ảnh chụp chỉ đọc | P10 cơ chế báo cáo | interface | Không | Do DC-PgReportStore (PKG-21) hiện thực; đặt ở Domain để PKG-21 không đi lên Application |

F1b. Kiểu phụ trợ

| DC | Loại | PKG | Thành phần hoặc giá trị | Dùng trong chữ ký |
|---|---|---|---|---|
| DC-MovieSummary | value object | PKG-17 | movieId, title, genre, durationMinutes, ageRating, releaseDate (chỉ phim sắp chiếu, còn lại rỗng) | DC-BrowseMoviesService.ListMovies |
| DC-MovieDetails | value object | PKG-17 | movieId, title, genre, durationMinutes, ageRating, description, trailer | DC-BrowseMoviesService.GetMovieDetails |
| DC-MovieListing | value object | PKG-17 | nowShowing, comingSoon: []MovieSummary; IsEmpty() Boolean | DC-BrowseMoviesService.ListMovies |
| DC-MovieOption | value object | PKG-17 | movieId, title | DC-BrowseShowtimesService.ListMoviesForBrowsing |
| DC-CinemaOption | value object | PKG-17 | cinemaId, name, province | DC-BrowseShowtimesService.ListCinemasForBrowsing |
| DC-BrowseCriteria | value object | PKG-17 | province, date (BusinessDate), auditoriumType (AuditoriumType), format (MovieFormat), mỗi trường tuỳ chọn (con trỏ rỗng là không lọc) | DC-BrowseShowtimesService.FindShowtimesByMovie, FindShowtimesByCinema, selectShowtimes |
| DC-ShowtimeListing | value object | PKG-17 | items: []ShowtimeInfo; IsEmpty() Boolean | DC-BrowseShowtimesService.FindShowtimesByMovie, FindShowtimesByCinema |
| DC-ReportRequest | value object | PKG-18 | view (ReportView), fromDate, toDate (*BusinessDate) | DC-ViewCinemaReportService.ViewCinemaReport, DC-ViewChainReportService.ViewChainReport |
| DC-CinemaReport | value object | PKG-18 | view; groups: []GroupFigures; IsEmpty() Boolean | DC-ViewCinemaReportService.ViewCinemaReport |
| DC-ChainReport | value object | PKG-18 | view; entries: []ChainReportEntry; IsEmpty() Boolean | DC-ViewChainReportService.ViewChainReport |
| DC-ChainReportEntry | value object | PKG-18 | overall: GroupFigures (nhóm toàn chuỗi); cinemas: []CinemaGroupFigures (mọi cụm rạp, theo tên) | DC-ChainReport |
| DC-CinemaGroupFigures | value object | PKG-18 | cinemaId, cinemaName, figures: GroupFigures | DC-ChainReportEntry |
| DC-ReportView | enumeration | PKG-33 | BY_DATE (theo ngày), BY_MOVIE (theo phim), BY_SHOWTIME (theo suất chiếu) | DC-ReportRequest, DC-ReportQuery, DC-GroupKey |
| DC-GroupKey | value object | PKG-33 | view, date (BusinessDate, chỉ BY_DATE), id (int64: mã phim hoặc mã suất chiếu, 0 với BY_DATE), label (tên nhóm hiển thị); so sánh bằng theo bốn trường | DC-ReportGroup, DC-ReportFigures |
| DC-ReportFigures | value object | PKG-33 | key (GroupKey), cinemaId (CinemaId), revenue (Money), soldSeats (int), capacity (int) | IF-28.FindCinemaFigures, IF-28.FindChainFigures, DC-ReportGroup.AddFigures |
| DC-GroupFigures | value object | PKG-33 | key, revenue, soldSeats, capacity, occupancyPercent (float64), occupancyApplicable (Boolean) | DC-ReportGroup.Figures |
| DC-ReportQuery | value object | PKG-33 | view (ReportView), start, end (time.Time, khoảng nửa mở) | IF-28.FindCinemaFigures, IF-28.FindChainFigures |
| DC-InvalidPeriodError | exception | PKG-33 | reason: MISSING_FROM, MISSING_TO, FROM_AFTER_TO | DC-ReportPeriod.CheckValid |

Câu trách nhiệm của từng lớp không có liên từ nối hai trách nhiệm khác lý do thay đổi. Kết luận bốn câu hỏi của Bước 1.4 cho sáu lớp dịch vụ: cần thật (mỗi lớp là ranh giới giao dịch hoặc điều phối nhiều lời gọi repository); tách theo tác nhân và lý do thay đổi như P10 (khách, quản lý chuỗi, hai báo cáo khác nhau ở phạm vi cụm rạp so với toàn chuỗi); căn cứ là độ phức tạp (BrowseShowtimes, ViewChainReport), giao dịch (ManageMovies, ManageCinemas) và hiệu năng (báo cáo gộp ở CSDL). Không cấp IF mới: giao dịch dùng IF-08, đồng hồ dùng Tx.Now, repository dùng IF-11 đến IF-14, IF-28.

## F2. Bảng operation

Ánh xạ kiểu: Date của P07 thành BusinessDate, tiền thành Money, tỉ lệ lấp đầy thành float64 kèm cờ áp dụng (không phải tiền nên không vi phạm quy tắc tiền), kết quả trả lời bất đồng bộ không có (mọi operation đồng bộ). Operation không trả giá trị ghi (T, error).

| DC | Visibility | Chữ ký | Mô tả | Tiền/hậu điều kiện | Nguồn | Phạm vi | Ngoại lệ / lỗi |
|---|---|---|---|---|---|---|---|
| DC-BrowseMoviesService | + | ListMovies(ctx Ctx) (MovieListing, error) | Phân các phim của chuỗi thành đang chiếu và sắp chiếu theo ngày nghiệp vụ hiện tại; phim đã qua ngày kết thúc chiếu bị bỏ; trả danh sách rỗng (IsEmpty) khi không phim nào thuộc hai nhóm | Hậu: không ghi, không khoá. Ngày hiện tại lấy từ tx.Now đổi theo zone (BR-76) | P07 UC-003 msg 1.1 // startBrowsingMovies, 1.1.1 // determineRunStatus, 1.1.2 // provideMovieSummary, 1.1.3 // notifyNoMovies, 1.1.4 // showMovieList | Instance | SystemBusyError |
| DC-BrowseMoviesService | + | GetMovieDetails(ctx Ctx, movieId MovieId) (MovieDetails, error) | Lấy tên, thể loại, thời lượng, độ tuổi, mô tả, trailer của phim đã chọn | Tiền: movieId lấy từ danh sách vừa hiển thị. Hậu: không ghi, không khoá | P07 UC-003 msg 2.1 // viewMovieDetails, 2.1.1 // provideMovieInfo, 2.1.2 // showMovieDetails | Instance | NotFoundError, SystemBusyError |
| DC-BrowseShowtimesService | + | ListMoviesForBrowsing(ctx Ctx) ([]MovieOption, error) | Liệt kê tên các phim đang chiếu, sắp chiếu để khách chọn | Hậu: không ghi, không khoá; phim đã qua ngày kết thúc chiếu bị bỏ (BR-76) | P07 UC-004 msg 1.1 // startBrowsingByMovie, 1.1.1 // determineRunStatus, 1.1.2 // provideMovieTitle, 1.1.3 // showMovieList | Instance | SystemBusyError |
| DC-BrowseShowtimesService | + | FindShowtimesByMovie(ctx Ctx, movieId MovieId, criteria BrowseCriteria) (ShowtimeListing, error) | Liệt kê suất chiếu của phim còn trong lịch chiếu, chưa tới giờ bắt đầu và khớp tiêu chí lọc; trả danh sách rỗng (IsEmpty) khi không có suất nào | Hậu: không ghi, không khoá; thứ tự theo Q-302 | P07 UC-004 msg 2.1 // findShowtimesByMovie, 2.1.1 // checkInSchedule, 2.1.2 // checkNotStarted, 2.1.3 // checkMatchesCriteria, 2.1.4 // provideShowtimeForBrowsing, 2.1.5 // notifyNoShowtimes, 2.1.6 // showShowtimes | Instance | SystemBusyError |
| DC-BrowseShowtimesService | + | GetShowtime(ctx Ctx, showtimeId ShowtimeId) (ShowtimeInfo, error) | Đọc thông tin một suất chiếu (phim, cụm rạp, phòng, giờ, trạng thái, mốc thay đổi) cho màn chọn ghế; không đòi đăng nhập | Hậu: không ghi, không khoá. Suất chiếu đã xoá coi như không có | Bổ sung: P12 PKG-11 Q-345; P07 UC-005 bước 1, 2 | Instance | NotFoundError, SystemBusyError |
| DC-BrowseShowtimesService | + | ListCinemasForBrowsing(ctx Ctx) ([]CinemaOption, error) | Liệt kê tên và tỉnh, thành phố của mọi cụm rạp để khách chọn | Hậu: không ghi, không khoá | P07 UC-004 msg 1a.1 // startBrowsingByCinema, 1a.1.1 // provideCinemaInfo, 1a.1.2 // showCinemaList | Instance | SystemBusyError |
| DC-BrowseShowtimesService | + | FindShowtimesByCinema(ctx Ctx, cinemaId CinemaId, criteria BrowseCriteria) (ShowtimeListing, error) | Liệt kê suất chiếu tại cụm rạp còn trong lịch chiếu, chưa tới giờ bắt đầu và khớp tiêu chí lọc; trả danh sách rỗng (IsEmpty) khi không có suất nào | Hậu: không ghi, không khoá; thứ tự theo Q-302 | P07 UC-004 msg 1a.2.1 // findShowtimesByCinema, 1a.2.1.1 đến 1a.2.1.6 | Instance | SystemBusyError |
| DC-BrowseShowtimesService | - | selectShowtimes(infos []ShowtimeInfo, criteria BrowseCriteria, now time.Time) []ShowtimeInfo | Giữ các suất chiếu trong lịch chiếu, giờ bắt đầu sau now và khớp tiêu chí; giữ thứ tự đầu vào | Hàm thuần, không chạm CSDL | Bổ sung: một nơi định nghĩa điều kiện liệt kê cho hai đường theo phim và theo cụm rạp (P07 UC-004 vấn đề còn mở 2) | Instance | - |
| DC-ViewCinemaReportService | + | ViewCinemaReport(ctx Ctx, cinemaId CinemaId, req ReportRequest) (CinemaReport, error) | Lập báo cáo của cụm rạp theo cách xem và kỳ của req: kiểm kỳ, lấy số liệu gộp, cộng vào nhóm, tính tỉ lệ lấp đầy; trả báo cáo rỗng (IsEmpty) khi cụm rạp không có suất chiếu nào trong kỳ kể cả suất chiếu đã xoá | Tiền: cinemaId lấy từ dòng Staff hiện hành của phiên, không từ tham số của trình duyệt (P09 F7.12). Hậu: không ghi, không khoá, không lưu số liệu | P07 UC-015 msg 1.1 // startCinemaReport, 1.1.1 // createReportPeriod, 1.1.2 // checkPeriodValid, 1.1.3 // notifyInvalidPeriod, 1.1.5 // provideShowtimesInPeriod, 1.1.6 // notifyNoShowtimes, 1.1.7 đến 1.1.11, 1.1.12 // showReport | Instance | InvalidPeriodError, SystemBusyError |
| DC-ViewChainReportService | + | ViewChainReport(ctx Ctx, req ReportRequest) (ChainReport, error) | Lập báo cáo toàn chuỗi: nhóm toàn chuỗi và nhóm của từng cụm rạp theo cùng khoá nhóm, đặt cạnh nhau để so sánh; cụm rạp không có số liệu trong nhóm hiện 0 đồng và tỉ lệ không áp dụng; trả báo cáo rỗng (IsEmpty) khi chuỗi không có suất chiếu nào trong kỳ | Hậu: không ghi, không khoá. Tỉ lệ toàn chuỗi là tổng ghế chia tổng sức chứa, không là trung bình các tỉ lệ (BR-88) | P07 UC-016 msg 1.1 // startChainReport, 1.1.1 // createReportPeriod, 1.1.2 // checkPeriodValid, 1.1.3 // notifyInvalidPeriod, 1.1.4 // provideShowtimesInPeriod, 1.1.5 // notifyNoShowtimes, 1.1.6 đến 1.1.15, 1.1.16 // showChainReport | Instance | InvalidPeriodError, SystemBusyError |
| DC-ManageMoviesService | + | ListMovies(ctx Ctx) ([]*Movie, error) | Lấy mọi phim của chuỗi kèm mốc thay đổi để hiển thị và gửi lại khi lưu | Hậu: không ghi, không khoá | P07 UC-010 msg 1.1 // startMovieAddition, 1.1.1 // provideMovieInfo, 1.1.2 // showMovieList; 1a.1 // startMovieEdit, 1a.1.1, 1a.1.2 | Instance | SystemBusyError |
| DC-ManageMoviesService | + | GetMovieForEdit(ctx Ctx, movieId MovieId) (*Movie, error) | Lấy thông tin hiện tại của phim đã chọn để sửa | Hậu: không ghi, không khoá | P07 UC-010 msg 2a.1 // selectMovie, 2a.1.1 // provideMovieInfo, 2a.1.2 // showMovieForEdit | Instance | NotFoundError, SystemBusyError |
| DC-ManageMoviesService | + | AddMovie(ctx Ctx, d MovieDraft) (*Movie, error) | Kiểm thông tin phim, rồi thêm phim vào danh sách phim của chuỗi, cấp mã phim và đặt mốc thay đổi; tên được trùng tên phim khác | Tiền: d lấy từ trình duyệt, chưa tin. Hậu: một dòng phim mới, hoặc không đổi gì khi có lỗi | P07 UC-010 msg 2.1 // submitMovie, 2.1.1 // createMovie, 2.1.2 // checkMovieInfoValid, 2.1.3 // notifyRefusal, 2.1.4 // addToMovieList, 2.1.5 // showSavedMovie | Instance | FieldInvalidError, SystemBusyError |
| DC-ManageMoviesService | + | SaveMovieChanges(ctx Ctx, movieId MovieId, d MovieDraft, displayedAt time.Time) (*Movie, error) | Kiểm thông tin phim, rồi dưới khoá dòng phim kiểm phim chưa bị sửa kể từ displayedAt và ghi thông tin mới cùng mốc mới; suất chiếu đã lập không đổi | Tiền: displayedAt là mốc nhận từ lúc hiển thị, truyền nguyên giá trị. Hậu: dòng phim đổi và mốc đổi, hoặc không đổi gì (BR-84, BR-138, BR-139) | P07 UC-010 msg 3a.1 // submitMovieChanges, 3a.1.1 // checkMovieInfoValid, 3a.1.2 // notifyRefusal, 3a.1.3 // saveMovieChanges, 3a.1.3.1 // checkUnchangedSinceDisplayed, 3a.1.4 // notifyRefusal, 3a.1.5 // showSavedMovie | Instance | FieldInvalidError, MovieChangedError, NotFoundError, SystemBusyError |
| DC-ManageCinemasService | + | ListCinemas(ctx Ctx) ([]*Cinema, error) | Lấy mọi cụm rạp của chuỗi kèm mốc thay đổi để hiển thị và gửi lại khi lưu | Hậu: không ghi, không khoá | P07 UC-011 msg 1.1 // startCinemaAddition, 1.1.1 // provideCinemaInfo, 1.1.2 // showCinemaList; 1a.1 // startCinemaEdit | Instance | SystemBusyError |
| DC-ManageCinemasService | + | GetCinemaForEdit(ctx Ctx, cinemaId CinemaId) (*Cinema, error) | Lấy thông tin hiện tại của cụm rạp đã chọn để sửa | Hậu: không ghi, không khoá | P07 UC-011 msg 2a.1 // selectCinema, 2a.1.1 // provideCinemaInfo, 2a.1.2 // showCinemaForEdit | Instance | NotFoundError, SystemBusyError |
| DC-ManageCinemasService | + | AddCinema(ctx Ctx, d CinemaDraft) (*Cinema, error) | Kiểm thông tin, rồi trong một giao dịch kiểm tên chưa thuộc cụm rạp nào và thêm cụm rạp cùng bảng giá rỗng | Hậu: một cụm rạp và một bảng giá rỗng cùng commit, hoặc không đổi gì (BR-141) | P07 UC-011 msg 2.1 // submitCinema, 2.1.1 // createCinema, 2.1.2 // checkCinemaInfoValid, 2.1.3 // notifyRefusal, 2.1.4 // checkNameTaken, 2.1.5 // notifyRefusal, 2.1.6 // addToCinemaList, 2.1.7 // showSavedCinema | Instance | FieldInvalidError, CinemaNameTakenError, SystemBusyError |
| DC-ManageCinemasService | + | SaveCinemaChanges(ctx Ctx, cinemaId CinemaId, d CinemaDraft, displayedAt time.Time) (*Cinema, error) | Kiểm thông tin, rồi trong một giao dịch kiểm tên chưa thuộc cụm rạp khác, kiểm cụm rạp chưa bị sửa kể từ displayedAt và ghi thông tin mới cùng mốc mới | Tiền: displayedAt truyền nguyên giá trị đã nhận. Hậu: dòng cụm rạp đổi, phòng chiếu, suất chiếu, nhân viên không đổi (BR-141, BR-142) | P07 UC-011 msg 3a.1 // submitCinemaChanges, 3a.1.1 đến 3a.1.7 | Instance | FieldInvalidError, CinemaNameTakenError, CinemaChangedError, NotFoundError, SystemBusyError |
| DC-ReportPeriod | + | NewReportPeriod(fromDate *BusinessDate, toDate *BusinessDate) *ReportPeriod | Lập kỳ báo cáo từ hai ngày nhận được, chưa kiểm | Hậu: không kiểm; CheckValid kiểm sau | P07 UC-015 msg 1.1.1 // createReportPeriod; UC-016 msg 1.1.1 | Classifier | - |
| DC-ReportPeriod | + | CheckValid() error | Kiểm kỳ có từ ngày, có đến ngày và từ ngày không sau đến ngày; trả lý do đầu tiên vi phạm theo thứ tự MISSING_FROM, MISSING_TO, FROM_AFTER_TO | Hậu: không đổi. GL-66, Q-181 | P07 UC-015 msg 1.1.2 // checkPeriodValid; UC-016 msg 1.1.2 | Instance | InvalidPeriodError |
| DC-ReportPeriod | + | ToRange(zone *time.Location) (start time.Time, end time.Time) | Đổi kỳ thành khoảng nửa mở [từ ngày 00:00, đến ngày cộng một ngày 00:00) theo múi giờ zone | Tiền: CheckValid đã trả nil. Hậu: không đổi | P09 F7.12; Q-268 | Instance | - |
| DC-ReportGroup | + | NewReportGroup(key GroupKey) *ReportGroup | Tạo nhóm trống không gắn cụm rạp (nhóm toàn chuỗi, hoặc nhóm của báo cáo cụm rạp) | Hậu: revenue, soldSeats, capacity bằng 0 | P07 UC-015 msg 1.1.8 // createReportGroup; UC-016 msg 1.1.7 | Classifier | - |
| DC-ReportGroup | + | NewCinemaReportGroup(key GroupKey, cinemaId CinemaId) *ReportGroup | Tạo nhóm trống của một cụm rạp | Hậu: CinemaId() trả cinemaId; R-70 | P07 UC-016 msg 1.1.9 // createReportGroup (khoá nhóm, cụm rạp) | Classifier | - |
| DC-ReportGroup | + | AddFigures(f ReportFigures) | Cộng doanh thu ròng, số ghế đã bán và sức chứa của một dòng số liệu đã gộp vào nhóm | Tiền: f.Key bằng key của nhóm (bên gọi bảo đảm, không kiểm). Hậu: ba tổng tăng đúng bằng f | P07 UC-015 msg 1.1.9 // addShowtimeFigures; UC-016 msg 1.1.8, 1.1.10 | Instance | - |
| DC-ReportGroup | + | OccupancyPercent() (percent float64, applicable bool) | Tính tỉ lệ lấp đầy phần trăm bằng soldSeats nhân 100 chia capacity; capacity bằng 0 thì trả (0, false) tức không áp dụng | BR-88, Q-235. Hậu: không đổi. Tỉ lệ không phải tiền nên dùng float64 | P07 UC-015 msg 1.1.10 // calculateOccupancyRate; UC-016 msg 1.1.11, 1.1.13 | Instance | - |
| DC-ReportGroup | + | Figures() GroupFigures | Cung cấp khoá nhóm, doanh thu, số ghế đã bán, sức chứa và tỉ lệ lấp đầy để hiển thị | Hậu: không đổi | P07 UC-015 msg 1.1.11 // provideGroupFigures; UC-016 msg 1.1.12, 1.1.14 | Instance | - |
| DC-ReportGroup | + | CinemaId() (cinemaId CinemaId, ok bool) | Cho biết cụm rạp của nhóm; ok sai với nhóm toàn chuỗi | Hậu: không đổi | Bổ sung: quan sát hậu điều kiện của NewCinemaReportGroup | Instance | - |
| IF-28 | + | FindCinemaFigures(ctx Ctx, tx Tx, cinemaId CinemaId, q ReportQuery) ([]ReportFigures, error) | Trả mỗi nhóm của q.View một dòng gồm doanh thu ròng, số ghế đã bán chưa huỷ, sức chứa của các suất chiếu của cụm rạp có giờ bắt đầu trong khoảng [q.Start, q.End), kể cả suất chiếu chưa tới giờ bắt đầu và suất chiếu đã xoá | Hậu: không khoá. Doanh thu ròng của vé = giá vé trừ phần hoàn của chính vé đã hoàn; khoản hoàn toàn bộ của thanh toán trễ không trừ (BR-77, BR-115, BR-119). Sức chứa là số dòng SeatStatus của suất chiếu chưa xoá, suất chiếu đã xoá có sức chứa 0 (BR-116, BR-118). Trả rỗng khi không có suất chiếu nào. Thứ tự dòng theo Q-303 | P10 F3 IF-28; P07 UC-015 msg 1.1.5, 1.1.7.1 đến 1.1.7.5 | Instance | SystemBusyError |
| IF-28 | + | FindChainFigures(ctx Ctx, tx Tx, q ReportQuery) ([]ReportFigures, error) | Như FindCinemaFigures cho mọi cụm rạp, mỗi dòng theo cặp (khoá nhóm, cụm rạp) có suất chiếu trong khoảng | Hậu: không khoá; cặp (khoá nhóm, cụm rạp) không có suất chiếu thì không có dòng, bên gọi tự bổ sung 0 đồng (Q-237). Thứ tự dòng theo Q-303 | P10 F3 IF-28; P07 UC-016 msg 1.1.4, 1.1.6.1 đến 1.1.6.5 | Instance | SystemBusyError |

Operation của entity và interface miền thuộc PKG-27 mà các lớp ở đây gọi, theo tên và chữ ký ở P12 PKG-16-PKG-27 F2:

| DC hoặc IF | Operation dùng | Dùng bởi |
|---|---|---|
| DC-Movie | NewMovie(d MovieDraft, now time.Time); CheckMovieInfoValid(); CheckUnchangedSinceDisplayed và SaveChanges(d, displayedAt, now); RunStatusAt(today BusinessDate) RunStatus; Info() MovieInfo; ID() MovieId | DC-ManageMoviesService, DC-BrowseMoviesService, DC-BrowseShowtimesService |
| DC-Cinema | NewCinema(d CinemaDraft, now time.Time); CheckCinemaInfoValid(); CheckNameNotTaken(sameName *Cinema); SaveChanges(d, displayedAt, now); Info() CinemaInfo; ID() CinemaId | DC-ManageCinemasService, DC-BrowseShowtimesService, DC-ViewChainReportService |
| DC-PriceList | NewPriceList(cinemaId CinemaId) | DC-ManageCinemasService |
| IF-14 | List(ctx); FindByID(ctx, id); Insert(ctx, tx, m); LockExclusive(ctx, tx, id) (hạng 10); Save(ctx, tx, m) | DC-ManageMoviesService, DC-BrowseMoviesService |
| IF-13 | ListCinemas(ctx) (thứ tự theo Q-303); FindCinema(ctx, id); FindCinemaByNormalizedName(ctx, tx, name); InsertCinema(ctx, tx, c); LockCinemaExclusive(ctx, tx, id) (hạng 0); SaveCinema(ctx, tx, c) | DC-ManageCinemasService, DC-BrowseShowtimesService, DC-ViewChainReportService |
| IF-12 | Insert(ctx, tx, pl) | DC-ManageCinemasService |
| IF-11 | ListInfoByMovie(ctx, movieId) ([]ShowtimeInfo, error); ListInfoByCinema(ctx, cinemaId) ([]ShowtimeInfo, error); cả hai đọc join một lần, không khoá | DC-BrowseShowtimesService |
| DC-ShowtimeInfo | Trường showtimeId, movieId, cinemaId, province, auditoriumType, saleOpenTime, status, movieFormat kiểu MovieFormat | DC-BrowseShowtimesService |
| IF-08 | LockValue(ctx, tx, kind ValueLockKind, value string) với giá trị CINEMA_NAME | DC-ManageCinemasService |
| DC-TxOptions | ReportTx(name string): pool REPORT, REPEATABLE READ READ ONLY, statement_timeout 15 giây (Q-269) | DC-ViewCinemaReportService, DC-ViewChainReportService |

## F3. Bảng thiết kế method

Các operation đều chạy trong một giao dịch hoặc không giao dịch; không có operation nào gồm hai giao dịch nên không có dòng Nếu dừng tại đây (00-Concurrency.md M7 mục 1). Thao tác thử lại (M7 mục 3): IF-08.Do có thể chạy lại fn từ đầu sau deadlock hoặc hết thời gian chờ khoá; mọi fn dưới đây khởi tạo lại biến kết quả ở đầu fn và chỉ ghi trong giao dịch, nên chạy lại khi lần trước chưa commit là an toàn, không có bước nào cần bỏ qua.

| DC.operation | Thuật toán / các bước chính | Đối tượng và operation khác được dùng | Cách dùng thuộc tính, tham số, quan hệ | Hành vi theo trạng thái (nếu có ST) |
|---|---|---|---|---|
| DC-BrowseMoviesService.ListMovies | 1. IF-08.Do(UserTx("ListMovies")): movies = IF-14.List; today = BusinessDate của tx.Now đổi theo zone.<br>2. Với mỗi phim: status = RunStatusAt(today); NOW_SHOWING thêm MovieSummary vào nowShowing; COMING_SOON thêm vào comingSoon kèm ReleaseDate; ENDED bỏ (BR-76: ngày kết thúc chiếu vẫn thuộc khoảng chiếu).<br>3. Trả MovieListing; IsEmpty đúng khi cả hai nhóm rỗng (luồng 2a). Thứ tự phim theo Q-302. | IF-08, IF-14, DC-Movie | zone; không giữ khoá | Không có ST |
| DC-BrowseMoviesService.GetMovieDetails | Do(UserTx("GetMovieDetails")): IF-14.FindByID (không có thì NotFoundError); dựng MovieDetails từ getter của phim. Không kiểm phim còn đang chiếu vì phim chọn từ danh sách vừa hiển thị. | IF-08, IF-14, DC-Movie | movieId | Không có ST |
| DC-BrowseShowtimesService.ListMoviesForBrowsing | Như ListMovies nhưng chỉ lấy MovieOption (mã, tên) của phim NOW_SHOWING và COMING_SOON, theo thứ tự Q-302. | IF-08, IF-14, DC-Movie | zone | Không có ST |
| DC-BrowseShowtimesService.FindShowtimesByMovie, FindShowtimesByCinema | 1. Do(UserTx(...)): infos = IF-11.ListInfoByMovie hoặc ListInfoByCinema (một câu join phim, suất chiếu, phòng, cụm rạp, không khoá); now = tx.Now.<br>2. selectShowtimes(infos, criteria, now) giữ suất chiếu theo thứ tự: status IN_SCHEDULE (checkInSchedule), StartTime sau now (checkNotStarted, BR-56), rồi criteria khớp: province bằng, ngày chiếu của StartTime đổi theo zone bằng date, auditoriumType bằng, format bằng; trường tiêu chí rỗng thì bỏ qua.<br>3. Sắp theo Q-302, trả ShowtimeListing; IsEmpty đúng khi không còn suất nào (luồng 4a, 1a4a). | IF-08, IF-11 | criteria, zone | Không có ST |
| DC-BrowseShowtimesService.GetShowtime | Do(UserTx("GetShowtime")): info = IF-11.FindInfo(showtimeId) (không có hoặc status DELETED thì NotFoundError); trả info (kèm lastChangedAt để màn chọn ghế gửi lại displayedAt ở BR-54). | IF-08, IF-11 | showtimeId | Không có ST |
| DC-BrowseShowtimesService.ListCinemasForBrowsing | Do(UserTx("ListCinemas")): IF-47.ListCinemas; dựng CinemaOption (mã, tên, tỉnh thành phố). | IF-08, IF-13, DC-Cinema | - | Không có ST |
| DC-ManageMoviesService.AddMovie | 1. Kiểm trước giao dịch: NewMovie(d, time.Time{}).CheckMovieInfoValid() (mốc chưa dùng); lỗi thì ném FieldInvalidError (luồng 4a, BR-134, Q-196 đến Q-199); danh sách phim không đổi.<br>2. IF-08.Do(UserTx("AddMovie")), trong fn: m = NewMovie(d, tx.Now); IF-14.Insert(m) (mã IDENTITY gán khi lưu). Không khoá, không kiểm trùng tên (Q-200); commit.<br>Ranh giới: một giao dịch, một INSERT. | IF-08, IF-14, DC-Movie | d | Không có ST |
| DC-ManageMoviesService.SaveMovieChanges | 1. Kiểm như AddMovie bước 1 (FieldInvalidError).<br>2. IF-08.Do(UserTx("SaveMovie")), trong fn đặt lại biến kết quả: m = IF-14.LockExclusive(movieId) (hạng 10, NotFoundError nếu không có); m.SaveChanges(d, displayedAt, tx.Now): mốc đã đổi thì MovieChangedError, fn trả lỗi, rollback, không ghi gì (BR-138); IF-14.Save(m); commit.<br>3. Chỉ UPDATE dòng phim, không đụng suất chiếu (BR-84, BR-139). Yêu cầu bấm lại sau khi lần trước đã commit mang mốc cũ nên bị từ chối (P09 F7.10). | IF-08, IF-14, DC-Movie, DC-LockOrderGuard (qua IF-14) | displayedAt phải là mốc nhận lúc hiển thị | Không có ST |
| DC-ManageMoviesService.ListMovies, GetMovieForEdit | Do(UserTx(...)): IF-14.List hoặc FindByID; trả entity. Không khoá: mốc trả ra là căn cứ cho kiểm ở SaveMovieChanges. | IF-08, IF-14 | - | Không có ST |
| DC-ManageCinemasService.AddCinema | 1. Kiểm trước giao dịch: NewCinema(d, time.Time{}).CheckCinemaInfoValid() lỗi thì FieldInvalidError (4a, Q-204: tên và tỉnh thành phố không trống).<br>2. IF-08.Do(UserTx("AddCinema")), trong fn: IF-08.LockValue(CINEMA_NAME, d.Name) (hạng 0, khoá tư vấn theo norm_name); same = IF-13.FindCinemaByNormalizedName(d.Name); c = NewCinema(d, tx.Now); c.CheckNameNotTaken(same) lỗi thì CinemaNameTakenError (5b, BR-141); IF-13.InsertCinema(c) (gán mã); IF-12.Insert(NewPriceList(c.ID())); commit.<br>3. Cụm rạp và bảng giá rỗng cùng một commit nên không có cụm rạp thiếu bảng giá (P09 F7.10). Chỉ mục unique theo norm_name(tên) là lưới an toàn. | IF-08, IF-12, IF-13, DC-Cinema, DC-PriceList | d | Không có ST |
| DC-ManageCinemasService.SaveCinemaChanges | 1. Kiểm như AddCinema bước 1.<br>2. IF-08.Do(UserTx("SaveCinema")): LockValue(CINEMA_NAME, d.Name) luôn lấy kể cả khi tên không đổi; c = IF-13.LockCinemaExclusive(cinemaId) (hạng 0, NotFoundError nếu không có); same = IF-13.FindCinemaByNormalizedName(d.Name); c.CheckNameNotTaken(same): tìm thấy cụm rạp khác c thì CinemaNameTakenError (5b); rồi c.SaveChanges(d, displayedAt, tx.Now): mốc đã đổi thì CinemaChangedError (5a, BR-142); IF-13.SaveCinema(c); commit.<br>3. Phòng chiếu, suất chiếu, nhân viên không đổi. Khoá giá trị đứng trước khoá Cinema nên hai cụm rạp đổi tên cho nhau không tạo chu trình chờ (P10 F3a EX-17). | IF-08, IF-13, DC-Cinema | displayedAt | Không có ST |
| DC-ManageCinemasService.ListCinemas, GetCinemaForEdit | Như ListMovies, GetMovieForEdit với IF-13.ListCinemas, IF-13.FindCinema. | IF-08, IF-13 | - | Không có ST |
| DC-ViewCinemaReportService.ViewCinemaReport | 1. period = NewReportPeriod(req.FromDate, req.ToDate); period.CheckValid lỗi thì ném InvalidPeriodError, chưa mở giao dịch (luồng 1a).<br>2. start, end = period.ToRange(zone); q = ReportQuery{req.View, start, end}.<br>3. IF-08.Do(ReportTx("CinemaReport")): rows = IF-28.FindCinemaFigures(cinemaId, q). Một giao dịch REPEATABLE READ READ ONLY nên mọi câu thấy cùng ảnh chụp (P09 F7.12).<br>4. rows rỗng thì trả CinemaReport rỗng (luồng 2a, Q-236).<br>5. Với mỗi dòng theo thứ tự nhận: g = nhóm theo f.Key (NewReportGroup nếu chưa có); g.AddFigures(f). Rồi mỗi nhóm: Figures() (đã gồm OccupancyPercent, không áp dụng khi sức chứa 0, Q-235).<br>6. Trả CinemaReport theo thứ tự nhóm của IF-28 (Q-303). | IF-08, IF-28, DC-ReportPeriod, DC-ReportGroup | zone; cinemaId do PKG-11 lấy từ dòng Staff của phiên | Không có ST |
| DC-ViewChainReportService.ViewChainReport | 1. Kiểm kỳ như ViewCinemaReport bước 1, 2.<br>2. IF-08.Do(ReportTx("ChainReport")): rows = IF-28.FindChainFigures(q); cinemas = IF-47.ListCinemas (theo tên, Q-303).<br>3. rows rỗng thì trả ChainReport rỗng (2a).<br>4. Với mỗi dòng f: chain[f.Key].AddFigures(f) (NewReportGroup nếu chưa có) và cinemaGroup[f.Key][f.CinemaId].AddFigures(f) (NewCinemaReportGroup nếu chưa có). Hai nhóm cộng riêng nên tỉ lệ toàn chuỗi là tổng ghế chia tổng sức chứa, không trung bình tỉ lệ (BR-88).<br>5. Với mỗi khoá nhóm và mỗi cụm rạp trong cinemas chưa có nhóm: NewCinemaReportGroup rỗng (0 đồng, không áp dụng, Q-237).<br>6. Dựng ChainReportEntry cho mỗi khoá nhóm: overall = chain.Figures(), cinemas theo thứ tự cinemas. | IF-08, IF-28, IF-13, DC-ReportPeriod, DC-ReportGroup, DC-Cinema | zone | Không có ST |
| DC-ReportPeriod.CheckValid | Theo thứ tự: fromDate rỗng thì MISSING_FROM; toDate rỗng thì MISSING_TO; fromDate sau toDate thì FROM_AFTER_TO; còn lại nil. Từ ngày bằng đến ngày là hợp lệ (kỳ một ngày). | - | fromDate, toDate | Không có ST |
| DC-ReportPeriod.ToRange | start = fromDate lúc 00:00 theo zone; end = (toDate cộng một ngày) lúc 00:00 theo zone. Khoảng nửa mở nên suất chiếu lúc 23:59 ngày cuối thuộc kỳ, 00:00 ngày kế tiếp thì không. | - | zone qua tham số | Không có ST |
| DC-ReportGroup.AddFigures, OccupancyPercent | AddFigures: revenue cộng f.Revenue (Money.Add), soldSeats và capacity cộng tương ứng. OccupancyPercent: capacity bằng 0 thì (0, false), ngược lại (soldSeats nhân 100 chia capacity, true) bằng phép chia số thực; không làm tròn ở đây, bên hiển thị chọn số chữ số. | DC-Money | revenue, soldSeats, capacity | Không có ST |
| IF-28.FindCinemaFigures, FindChainFigures (yêu cầu cho DC-PgReportStore, PKG-21) | Một câu GROUP BY theo khoá nhóm của q.View (ngày chiếu theo AT TIME ZONE Asia/Ho_Chi_Minh của giờ bắt đầu, mã phim, mã suất chiếu), thêm cụm rạp với FindChainFigures. Doanh thu = tổng giá vé (đã bán, kể cả vé đã huỷ) trừ tổng phần hoàn của vé đã hoàn, xếp vào suất chiếu có vé (BR-77, BR-115); khoản hoàn toàn bộ thanh toán trễ không trừ (BR-119). Số ghế đã bán = số vé chưa huỷ (ghế đôi một ghế, ghế đang giữ không tính, BR-06, BR-88). Sức chứa = số dòng SeatStatus của suất chiếu chưa xoá, suất chiếu đã xoá cho 0 (BR-116, BR-118). Mọi suất chiếu có giờ bắt đầu trong khoảng được tính kể cả chưa mở bán hoặc đã xoá (BR-117). | - | q.Start, q.End | Không có ST |

## F4. Bảng ánh xạ message --> operation

Mọi message của sáu P07 có lớp gửi hoặc lớp nhận thuộc phạm vi. Message gửi tới tác nhân người, message boundary --> control ánh xạ tới operation của lớp dịch vụ (PKG-11 chuyển tiếp). Message tới lớp entity PKG-27 ánh xạ tới operation đề xuất ở bảng cuối F2. Message trả về có dữ liệu là kiểu trả về của dòng gọi nên không có dòng riêng.

| UC | STT message (P07) | Từ | Đến | Message phân tích | Operation thiết kế |
|---|---|---|---|---|---|
| UC-003 | 1.1 | AC-B-BrowseMoviesForm | AC-C-BrowseMoviesController | // startBrowsingMovies | DC-BrowseMoviesService.ListMovies(ctx Ctx) (MovieListing, error) |
| UC-003 | 1.1.1 | AC-C-BrowseMoviesController | AC-E-Movie | // determineRunStatus | DC-Movie.RunStatusAt(today BusinessDate) RunStatus (PKG-27), gọi trong ListMovies |
| UC-003 | 1.1.2 | AC-C-BrowseMoviesController | AC-E-Movie | // provideMovieSummary | Getter của DC-Movie (PKG-27); ListMovies dựng DC-MovieSummary |
| UC-003 | 1.1.3, 1.1.4 | AC-C-BrowseMoviesController | AC-B-BrowseMoviesForm | // notifyNoMovies, // showMovieList | Trả về: DC-BrowseMoviesService.ListMovies trả DC-MovieListing, IsEmpty cho luồng 2a |
| UC-003 | 2.1 | AC-B-BrowseMoviesForm | AC-C-BrowseMoviesController | // viewMovieDetails | DC-BrowseMoviesService.GetMovieDetails(ctx Ctx, movieId MovieId) (MovieDetails, error) |
| UC-003 | 2.1.1 | AC-C-BrowseMoviesController | AC-E-Movie | // provideMovieInfo | IF-14.FindByID và getter của DC-Movie (PKG-27) |
| UC-003 | 2.1.2 | AC-C-BrowseMoviesController | AC-B-BrowseMoviesForm | // showMovieDetails | Trả về: GetMovieDetails trả DC-MovieDetails |
| UC-004 | 1.1 | AC-B-BrowseShowtimesForm | AC-C-BrowseShowtimesController | // startBrowsingByMovie | DC-BrowseShowtimesService.ListMoviesForBrowsing(ctx Ctx) ([]MovieOption, error) |
| UC-004 | 1.1.1, 1.1.2 | AC-C-BrowseShowtimesController | AC-E-Movie | // determineRunStatus, // provideMovieTitle | DC-Movie.RunStatusAt, DC-Movie.Info (PKG-27), gọi trong ListMoviesForBrowsing |
| UC-004 | 1.1.3 | AC-C-BrowseShowtimesController | AC-B-BrowseShowtimesForm | // showMovieList | Trả về: ListMoviesForBrowsing trả []DC-MovieOption |
| UC-004 | 2.1 | AC-B-BrowseShowtimesForm | AC-C-BrowseShowtimesController | // findShowtimesByMovie | DC-BrowseShowtimesService.FindShowtimesByMovie(ctx Ctx, movieId MovieId, criteria BrowseCriteria) (ShowtimeListing, error) |
| UC-004 | 2.1.1, 2.1.2, 2.1.3, 2.1.3.1, 2.1.3.1.1 | AC-C-BrowseShowtimesController, AC-E-Showtime, AC-E-Auditorium | AC-E-Showtime, AC-E-Auditorium, AC-E-Cinema | // checkInSchedule, // checkNotStarted, // checkMatchesCriteria, // checkMatchesRoomCriteria, // checkInProvince | Khác lớp nhận: P10 F3 (đọc qua IF-11, IF-13, IF-14): DC-BrowseShowtimesService.selectShowtimes(infos, criteria, now) trên DC-ShowtimeInfo do IF-11.ListInfoByMovie trả (PKG-27) |
| UC-004 | 2.1.4, 2.1.4.1, 2.1.4.2, 2.1.4.2.1 | AC-C-BrowseShowtimesController, AC-E-Showtime | AC-E-Showtime, AC-E-Movie, AC-E-Auditorium, AC-E-Cinema | // provideShowtimeForBrowsing, // provideMovieTitle, // provideAuditoriumInfo, // provideCinemaInfo | Khác lớp nhận: P10 F3; một lần đọc join IF-11.ListInfoByMovie trả DC-ShowtimeInfo (PKG-27) |
| UC-004 | 2.1.5, 2.1.6 | AC-C-BrowseShowtimesController | AC-B-BrowseShowtimesForm | // notifyNoShowtimes, // showShowtimes | Trả về: FindShowtimesByMovie trả DC-ShowtimeListing, IsEmpty cho luồng 4a |
| UC-004 | 1a.1 | AC-B-BrowseShowtimesForm | AC-C-BrowseShowtimesController | // startBrowsingByCinema | DC-BrowseShowtimesService.ListCinemasForBrowsing(ctx Ctx) ([]CinemaOption, error) |
| UC-004 | 1a.1.1 | AC-C-BrowseShowtimesController | AC-E-Cinema | // provideCinemaInfo | IF-47.ListCinemas và getter Name, Province của DC-Cinema (PKG-27) |
| UC-004 | 1a.1.2 | AC-C-BrowseShowtimesController | AC-B-BrowseShowtimesForm | // showCinemaList | Trả về: ListCinemasForBrowsing trả []DC-CinemaOption |
| UC-005 | Bổ sung | - | AC-C-BrowseShowtimesController | Đọc một suất chiếu cho màn chọn ghế | DC-BrowseShowtimesService.GetShowtime(ctx Ctx, showtimeId ShowtimeId) (ShowtimeInfo, error) |
| UC-004 | 1a.2.1 | AC-B-BrowseShowtimesForm | AC-C-BrowseShowtimesController | // findShowtimesByCinema | DC-BrowseShowtimesService.FindShowtimesByCinema(ctx Ctx, cinemaId CinemaId, criteria BrowseCriteria) (ShowtimeListing, error) |
| UC-004 | 1a.2.1.1 đến 1a.2.1.4.2.1 | AC-C-BrowseShowtimesController, AC-E-Showtime | AC-E-Showtime, AC-E-Movie, AC-E-Auditorium, AC-E-Cinema | như 2.1.1 đến 2.1.4.2.1 | Khác lớp nhận: P10 F3; IF-11.ListInfoByCinema và selectShowtimes |
| UC-004 | 1a.2.1.5, 1a.2.1.6 | AC-C-BrowseShowtimesController | AC-B-BrowseShowtimesForm | // notifyNoShowtimes, // showShowtimes | Trả về: FindShowtimesByCinema trả DC-ShowtimeListing, IsEmpty cho luồng 1a4a |
| UC-010 | 1.1, 1a.1 | AC-B-ManageMoviesForm | AC-C-ManageMoviesController | // startMovieAddition, // startMovieEdit | DC-ManageMoviesService.ListMovies(ctx Ctx) ([]*Movie, error) |
| UC-010 | 1.1.1, 1a.1.1 | AC-C-ManageMoviesController | AC-E-Movie | // provideMovieInfo | IF-14.List và getter của DC-Movie (PKG-27) |
| UC-010 | 1.1.2, 1a.1.2 | AC-C-ManageMoviesController | AC-B-ManageMoviesForm | // showMovieList | Trả về: ListMovies trả []*Movie kèm LastChangedAt |
| UC-010 | 2.1 | AC-B-ManageMoviesForm | AC-C-ManageMoviesController | // submitMovie | DC-ManageMoviesService.AddMovie(ctx Ctx, d MovieDraft) (*Movie, error) |
| UC-010 | 2.1.1 | AC-C-ManageMoviesController | AC-E-Movie | // createMovie | DC-Movie.NewMovie(d MovieDraft, now time.Time) *Movie (PKG-27) |
| UC-010 | 2.1.2, 3a.1.1 | AC-C-ManageMoviesController | AC-E-Movie | // checkMovieInfoValid | DC-Movie.CheckMovieInfoValid() error (PKG-27); vi phạm của từng trường đổi thành FieldInvalidError |
| UC-010 | 2.1.3, 3a.1.2 | AC-C-ManageMoviesController | AC-B-ManageMoviesForm | // notifyRefusal (điều kiện từng trường) | Ngoại lệ: AddMovie, SaveMovieChanges ném FieldInvalidError mang violations |
| UC-010 | 2.1.4 | AC-C-ManageMoviesController | AC-E-Movie | // addToMovieList | IF-14.Insert (PKG-27); mốc thay đổi đặt ở DC-Movie.NewMovie |
| UC-010 | 2.1.5, 3a.1.5 | AC-C-ManageMoviesController | AC-B-ManageMoviesForm | // showSavedMovie | Trả về: AddMovie, SaveMovieChanges trả *Movie |
| UC-010 | 2a.1 | AC-B-ManageMoviesForm | AC-C-ManageMoviesController | // selectMovie | DC-ManageMoviesService.GetMovieForEdit(ctx Ctx, movieId MovieId) (*Movie, error) |
| UC-010 | 2a.1.1 | AC-C-ManageMoviesController | AC-E-Movie | // provideMovieInfo | IF-14.FindByID và getter của DC-Movie (PKG-27) |
| UC-010 | 2a.1.2 | AC-C-ManageMoviesController | AC-B-ManageMoviesForm | // showMovieForEdit | Trả về: GetMovieForEdit trả *Movie |
| UC-010 | 3a.1 | AC-B-ManageMoviesForm | AC-C-ManageMoviesController | // submitMovieChanges | DC-ManageMoviesService.SaveMovieChanges(ctx Ctx, movieId MovieId, d MovieDraft, displayedAt time.Time) (*Movie, error) |
| UC-010 | 3a.1.3 | AC-C-ManageMoviesController | AC-E-Movie | // saveMovieChanges | IF-14.LockExclusive, DC-Movie.ApplyChanges(info, now), IF-14.Update (PKG-27) |
| UC-010 | 3a.1.3.1 | AC-E-Movie | AC-E-Movie | // checkUnchangedSinceDisplayed | DC-Movie.CheckUnchangedSinceDisplayed(displayedAt time.Time) error (PKG-27) |
| UC-010 | 3a.1.4 | AC-C-ManageMoviesController | AC-B-ManageMoviesForm | // notifyRefusal (phim đã bị sửa) | Ngoại lệ: SaveMovieChanges ném MovieChangedError |
| UC-010 | 1*a.1, 1*a.1.1 | AC-B-ManageMoviesForm, AC-C-ManageMoviesController | AC-C-ManageMoviesController | // cancelRequest, // discardRequest | Không có operation: control không giữ trạng thái giữa hai yêu cầu (P09 A7) |
| UC-011 | 1.1, 1a.1 | AC-B-ManageCinemasForm | AC-C-ManageCinemasController | // startCinemaAddition, // startCinemaEdit | DC-ManageCinemasService.ListCinemas(ctx Ctx) ([]*Cinema, error) |
| UC-011 | 1.1.1, 1a.1.1 | AC-C-ManageCinemasController | AC-E-Cinema | // provideCinemaInfo | IF-13.ListCinemas và getter của DC-Cinema (PKG-27) |
| UC-011 | 1.1.2, 1a.1.2 | AC-C-ManageCinemasController | AC-B-ManageCinemasForm | // showCinemaList | Trả về: ListCinemas trả []*Cinema kèm LastChangedAt |
| UC-011 | 2.1 | AC-B-ManageCinemasForm | AC-C-ManageCinemasController | // submitCinema | DC-ManageCinemasService.AddCinema(ctx Ctx, d CinemaDraft) (*Cinema, error) |
| UC-011 | 2.1.1 | AC-C-ManageCinemasController | AC-E-Cinema | // createCinema | DC-Cinema.NewCinema(d CinemaDraft, now time.Time) *Cinema (PKG-27) |
| UC-011 | 2.1.2, 3a.1.1 | AC-C-ManageCinemasController | AC-E-Cinema | // checkCinemaInfoValid | DC-Cinema.CheckCinemaInfoValid() error (PKG-27); vi phạm của từng trường đổi thành FieldInvalidError |
| UC-011 | 2.1.3, 3a.1.2 | AC-C-ManageCinemasController | AC-B-ManageCinemasForm | // notifyRefusal (điều kiện từng trường) | Ngoại lệ: AddCinema, SaveCinemaChanges ném FieldInvalidError |
| UC-011 | 2.1.4, 3a.1.3 | AC-C-ManageCinemasController | AC-E-Cinema (cụm rạp trùng tên) | // checkNameTaken | Khác lớp nhận: P09 F7.3 (so tên bằng norm_name ở SQL): IF-13.FindCinemaByNormalizedName(ctx, tx, name) và IF-08.LockValue(CINEMA_NAME, name); kết quả tìm được đưa cho DC-Cinema.CheckNameNotTaken |
| UC-011 | 2.1.5, 3a.1.4 | AC-C-ManageCinemasController | AC-B-ManageCinemasForm | // notifyRefusal (tên đã thuộc cụm rạp khác) | Ngoại lệ: AddCinema, SaveCinemaChanges ném CinemaNameTakenError |
| UC-011 | 2.1.6 | AC-C-ManageCinemasController | AC-E-Cinema | // addToCinemaList | IF-13.InsertCinema, IF-12.Insert (PKG-27); mốc thay đổi đặt ở DC-Cinema.NewCinema |
| UC-011 | 2.1.7, 3a.1.7 | AC-C-ManageCinemasController | AC-B-ManageCinemasForm | // showSavedCinema | Trả về: AddCinema, SaveCinemaChanges trả *Cinema |
| UC-011 | 2a.1 | AC-B-ManageCinemasForm | AC-C-ManageCinemasController | // selectCinema | DC-ManageCinemasService.GetCinemaForEdit(ctx Ctx, cinemaId CinemaId) (*Cinema, error) |
| UC-011 | 2a.1.1, 2a.1.2 | AC-C-ManageCinemasController | AC-E-Cinema, AC-B-ManageCinemasForm | // provideCinemaInfo, // showCinemaForEdit | IF-13.FindCinema; Trả về: GetCinemaForEdit trả *Cinema |
| UC-011 | 3a.1 | AC-B-ManageCinemasForm | AC-C-ManageCinemasController | // submitCinemaChanges | DC-ManageCinemasService.SaveCinemaChanges(ctx Ctx, cinemaId CinemaId, d CinemaDraft, displayedAt time.Time) (*Cinema, error) |
| UC-011 | 3a.1.5 | AC-C-ManageCinemasController | AC-E-Cinema | // saveCinemaChanges | IF-13.LockCinemaExclusive, DC-Cinema.ApplyChanges(info, now), IF-13.UpdateCinema (PKG-27) |
| UC-011 | 3a.1.5.1 | AC-E-Cinema | AC-E-Cinema | // checkUnchangedSinceDisplayed | DC-Cinema.CheckUnchangedSinceDisplayed(displayedAt time.Time) error (PKG-27) |
| UC-011 | 3a.1.6 | AC-C-ManageCinemasController | AC-B-ManageCinemasForm | // notifyRefusal (cụm rạp đã bị sửa) | Ngoại lệ: SaveCinemaChanges ném CinemaChangedError |
| UC-011 | 1*a.1, 1*a.1.1 | AC-B-ManageCinemasForm, AC-C-ManageCinemasController | AC-C-ManageCinemasController | // cancelRequest, // discardRequest | Không có operation (như UC-010) |
| UC-015 | 1.1 | AC-B-ViewCinemaReportForm | AC-C-ViewCinemaReportController | // startCinemaReport | DC-ViewCinemaReportService.ViewCinemaReport(ctx Ctx, cinemaId CinemaId, req ReportRequest) (CinemaReport, error) |
| UC-015 | 1.1.1 | AC-C-ViewCinemaReportController | AC-E-ReportPeriod | // createReportPeriod | DC-ReportPeriod.NewReportPeriod(fromDate *BusinessDate, toDate *BusinessDate) *ReportPeriod |
| UC-015 | 1.1.2 | AC-C-ViewCinemaReportController | AC-E-ReportPeriod | // checkPeriodValid | DC-ReportPeriod.CheckValid() error |
| UC-015 | 1.1.3 | AC-C-ViewCinemaReportController | AC-B-ViewCinemaReportForm | // notifyInvalidPeriod | Ngoại lệ: ViewCinemaReport ném InvalidPeriodError |
| UC-015 | 1.1.4 | AC-C-ViewCinemaReportController | AC-E-CinemaManager | // provideCinema | Khác lớp nhận: P09 F7.12, P10 F3: cinemaId là tham số của ViewCinemaReport do DC-ReportController (PKG-11) lấy từ dòng Staff hiện hành; không có operation ở PKG-18 |
| UC-015 | 1.1.5 | AC-C-ViewCinemaReportController | AC-E-Cinema | // provideShowtimesInPeriod | Khác lớp nhận: P10 F3 (IF-28): IF-28.FindCinemaFigures(ctx Ctx, tx Tx, cinemaId CinemaId, q ReportQuery) ([]ReportFigures, error) |
| UC-015 | 1.1.6 | AC-C-ViewCinemaReportController | AC-B-ViewCinemaReportForm | // notifyNoShowtimes | Trả về: ViewCinemaReport trả DC-CinemaReport, IsEmpty cho luồng 2a |
| UC-015 | 1.1.7, 1.1.7.1 đến 1.1.7.5 | AC-C-ViewCinemaReportController, AC-E-Showtime | AC-E-Showtime, AC-E-Movie, AC-E-Auditorium, AC-E-Ticket, AC-E-RefundRequest | // provideReportFigures, // provideMovieTitle, // provideAuditoriumInfo, // checkNotCancelled, // calculateNetRevenue, // provideRefundInfo, // calculateCapacity | Khác lớp nhận: P10 F3 (IF-28), P09 F7.12: gộp ở CSDL, DC-ReportFigures là kết quả mỗi nhóm; định nghĩa doanh thu và sức chứa ở F3 của IF-28 |
| UC-015 | 1.1.8 | AC-C-ViewCinemaReportController | AC-E-ReportGroup | // createReportGroup | DC-ReportGroup.NewReportGroup(key GroupKey) *ReportGroup |
| UC-015 | 1.1.9 | AC-C-ViewCinemaReportController | AC-E-ReportGroup | // addShowtimeFigures | DC-ReportGroup.AddFigures(f ReportFigures) |
| UC-015 | 1.1.10 | AC-C-ViewCinemaReportController | AC-E-ReportGroup | // calculateOccupancyRate | DC-ReportGroup.OccupancyPercent() (percent float64, applicable bool) |
| UC-015 | 1.1.11 | AC-C-ViewCinemaReportController | AC-E-ReportGroup | // provideGroupFigures | DC-ReportGroup.Figures() GroupFigures |
| UC-015 | 1.1.12 | AC-C-ViewCinemaReportController | AC-B-ViewCinemaReportForm | // showReport | Trả về: ViewCinemaReport trả DC-CinemaReport |
| UC-016 | 1.1 | AC-B-ViewChainReportForm | AC-C-ViewChainReportController | // startChainReport | DC-ViewChainReportService.ViewChainReport(ctx Ctx, req ReportRequest) (ChainReport, error) |
| UC-016 | 1.1.1, 1.1.2 | AC-C-ViewChainReportController | AC-E-ReportPeriod | // createReportPeriod, // checkPeriodValid | DC-ReportPeriod.NewReportPeriod, DC-ReportPeriod.CheckValid |
| UC-016 | 1.1.3 | AC-C-ViewChainReportController | AC-B-ViewChainReportForm | // notifyInvalidPeriod | Ngoại lệ: ViewChainReport ném InvalidPeriodError |
| UC-016 | 1.1.4 | AC-C-ViewChainReportController | AC-E-Cinema | // provideShowtimesInPeriod | Khác lớp nhận: P10 F3 (IF-28): IF-28.FindChainFigures(ctx Ctx, tx Tx, q ReportQuery) ([]ReportFigures, error) |
| UC-016 | 1.1.5 | AC-C-ViewChainReportController | AC-B-ViewChainReportForm | // notifyNoShowtimes | Trả về: ViewChainReport trả DC-ChainReport, IsEmpty cho luồng 2a |
| UC-016 | 1.1.6, 1.1.6.1 đến 1.1.6.5 | AC-C-ViewChainReportController, AC-E-Showtime | AC-E-Showtime, AC-E-Movie, AC-E-Auditorium, AC-E-Ticket, AC-E-RefundRequest | // provideReportFigures và các message con | Khác lớp nhận: P10 F3 (IF-28), như UC-015 1.1.7 |
| UC-016 | 1.1.7, 1.1.9 | AC-C-ViewChainReportController | AC-E-ReportGroup | // createReportGroup (nhóm toàn chuỗi, nhóm cụm rạp) | DC-ReportGroup.NewReportGroup(key); DC-ReportGroup.NewCinemaReportGroup(key GroupKey, cinemaId CinemaId) |
| UC-016 | 1.1.8, 1.1.10 | AC-C-ViewChainReportController | AC-E-ReportGroup | // addShowtimeFigures | DC-ReportGroup.AddFigures(f ReportFigures) |
| UC-016 | 1.1.11, 1.1.13 | AC-C-ViewChainReportController | AC-E-ReportGroup | // calculateOccupancyRate | DC-ReportGroup.OccupancyPercent() |
| UC-016 | 1.1.12, 1.1.14 | AC-C-ViewChainReportController | AC-E-ReportGroup | // provideGroupFigures | DC-ReportGroup.Figures() |
| UC-016 | 1.1.15 | AC-C-ViewChainReportController | AC-E-Cinema | // provideCinemaInfo | IF-47.ListCinemas và getter ID, Name của DC-Cinema (PKG-27) |
| UC-016 | 1.1.16 | AC-C-ViewChainReportController | AC-B-ViewChainReportForm | // showChainReport | Trả về: ViewChainReport trả DC-ChainReport |

## F5. Bảng quan hệ

Quan hệ có mã R-nn của P08 giữ mã. R-76, R-77, R-78 (BrowseShowtimes tới Movie, Showtime, Cinema) bỏ, thay bằng R-247 vì dữ liệu hiển thị đến qua một DC-ShowtimeInfo; R-92 (ViewCinemaReport tới CinemaManager), R-93 (tới Cinema), R-94 và R-99 (tới Showtime) bỏ vì cụm rạp là tham số cinemaId và số liệu suất chiếu đến qua IF-28. Quan hệ P08 R-73, R-75, R-82, R-84, R-90, R-96 (boundary --> control) thuộc phiên giao diện (PKG-05, PKG-08, PKG-09, PKG-11). Mã dải R-240 đến R-269 đã dùng hết.

| ID | Lớp A | Lớp B | Loại | Multiplicity | Điều hướng | Lý do | Vai trò | Căn cứ hiển thị |
|---|---|---|---|---|---|---|---|---|
| R-240 | DC-BrowseMoviesService | IF-08 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - / uow | field |
| R-241 | DC-BrowseMoviesService | IF-14 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - / movies | field |
| R-74 | DC-BrowseMoviesService | DC-Movie | Dependency |  | A --> B | Giữ mã P08 R-74; Association tạm của P08 thành Dependency vì Movie đến qua kết quả của IF-14.List, không giữ lâu |  | biến cục bộ |
| R-242 | DC-BrowseShowtimesService | IF-08 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - / uow | field |
| R-243 | DC-BrowseShowtimesService | IF-11 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - / showtimes | field |
| R-483 | DC-BrowseShowtimesService | IF-47 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - / cinemas | field |
| R-245 | DC-BrowseShowtimesService | IF-14 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - / movies | field |
| R-246 | DC-BrowseShowtimesService | DC-BrowseCriteria | Dependency |  | A --> B | Tiêu chí lọc nhận qua tham số của FindShowtimesByMovie, FindShowtimesByCinema |  | tham số |
| R-247 | DC-BrowseShowtimesService | DC-ShowtimeInfo | Dependency |  | A --> B | Thay P08 R-76, R-77, R-78: dữ liệu hiển thị của suất chiếu, phòng, cụm rạp đến qua DC-ShowtimeInfo của IF-11, một lần đọc join |  | biến cục bộ |
| R-248 | DC-MovieListing | DC-MovieSummary | Composition | A 1 - B 0..* | A --> B | Danh sách chỉ tồn tại cùng kết quả; hai nhóm đang chiếu, sắp chiếu | listing / summaries | field |
| R-249 | DC-ShowtimeListing | DC-ShowtimeInfo | Composition | A 1 - B 0..* | A --> B | Kết quả liệt kê giữ các suất chiếu đã chọn | listing / items | field |
| R-250 | DC-ViewCinemaReportService | IF-08 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - / uow | field |
| R-251 | DC-ViewCinemaReportService | IF-28 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - / reports | field |
| R-91 | DC-ViewCinemaReportService | DC-ReportPeriod | Dependency |  | A --> B | Giữ mã P08 R-91; Association tạm thành Dependency vì kỳ chỉ sống trong một lần gọi |  | biến cục bộ |
| R-95 | DC-ViewCinemaReportService | DC-ReportGroup | Dependency |  | A --> B | Giữ mã P08 R-95; nhóm tạo và dùng trong một lần gọi |  | biến cục bộ |
| R-252 | DC-ViewChainReportService | IF-08 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - / uow | field |
| R-253 | DC-ViewChainReportService | IF-28 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - / reports | field |
| R-484 | DC-ViewChainReportService | IF-47 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc; lấy danh sách cụm rạp để mọi cụm rạp có dòng (Q-237) | - / cinemas | field |
| R-97 | DC-ViewChainReportService | DC-ReportPeriod | Dependency |  | A --> B | Giữ mã P08 R-97; như R-91 |  | biến cục bộ |
| R-98 | DC-ViewChainReportService | DC-Cinema | Dependency |  | A --> B | Giữ mã P08 R-98; Cinema đến qua kết quả của IF-13.ListCinemas (tên cụm rạp, mã) |  | biến cục bộ |
| R-100 | DC-ViewChainReportService | DC-ReportGroup | Dependency |  | A --> B | Giữ mã P08 R-100; hai nhóm chainGroup, cinemaGroup tạo trong một lần gọi |  | biến cục bộ |
| R-255 | DC-CinemaReport | DC-GroupFigures | Composition | A 1 - B 0..* | A --> B | Báo cáo giữ số liệu từng nhóm | report / groups | field |
| R-256 | DC-ChainReport | DC-ChainReportEntry | Composition | A 1 - B 0..* | A --> B | Báo cáo giữ một dòng cho mỗi nhóm | report / entries | field |
| R-257 | DC-ChainReportEntry | DC-CinemaGroupFigures | Composition | A 1 - B 0..* | A --> B | Mỗi nhóm giữ số liệu của mọi cụm rạp để so sánh (Q-237) | entry / cinemas | field |
| R-70 | DC-ReportGroup | DC-Cinema | Association | A 0..* - B 0..1 | A --> B | Giữ mã P08 R-70; nhóm toàn chuỗi không thuộc cụm rạp nào; hiện thực bằng CinemaId, không nạp Cinema (P12 core mục 0.3) | groups / cinema | field |
| R-258 | DC-ReportGroup | DC-GroupKey | Association | A 0..* - B 1 | A --> B | Mỗi nhóm có đúng một khoá nhóm; kiểu giá trị dùng chung nhiều nhóm | - / key | field |
| R-259 | DC-ReportFigures | DC-GroupKey | Association | A 0..* - B 1 | A --> B | Mỗi dòng số liệu thuộc một khoá nhóm | - / key | field |
| R-260 | IF-28 | DC-ReportFigures | Dependency |  | A --> B | Kiểu trả về của hai operation truy vấn |  | kiểu trả về |
| R-261 | DC-ReportGroup | DC-ReportFigures | Dependency |  | A --> B | AddFigures nhận dòng số liệu qua tham số |  | tham số |
| R-262 | DC-ManageMoviesService | IF-08 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - / uow | field |
| R-263 | DC-ManageMoviesService | IF-14 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - / movies | field |
| R-83 | DC-ManageMoviesService | DC-Movie | Dependency |  | A --> B | Giữ mã P08 R-83; Association tạm thành Dependency vì phim tạo hoặc nạp trong một lần gọi |  | biến cục bộ |
| R-264 | DC-ManageMoviesService | DC-MovieInfo | Dependency |  | A --> B | Thông tin phim nhận qua tham số của AddMovie, SaveMovieChanges |  | tham số |
| R-265 | DC-ManageCinemasService | IF-08 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - / uow | field |
| R-266 | DC-ManageCinemasService | IF-13 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - / cinemas | field |
| R-267 | DC-ManageCinemasService | IF-12 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc; tạo bảng giá rỗng cùng giao dịch thêm cụm rạp | - / priceLists | field |
| R-85 | DC-ManageCinemasService | DC-Cinema | Dependency |  | A --> B | Giữ mã P08 R-85; như R-83 |  | biến cục bộ |
| R-268 | DC-ManageCinemasService | DC-CinemaInfo | Dependency |  | A --> B | Thông tin cụm rạp nhận qua tham số của AddCinema, SaveCinemaChanges |  | tham số |
| R-269 | DC-ManageCinemasService | DC-ValueLockKind | Dependency |  | A --> B | Truyền loại khoá giá trị CINEMA_NAME cho IF-08.LockValue |  | tham số |

Mọi association ở bảng trên có căn cứ field (interface hoặc kiểu giá trị giữ trong struct); dependency có căn cứ tham số, kiểu trả về hoặc biến cục bộ. Multiplicity của tiêm phụ thuộc theo quy ước "A 0..* - B 1". Không dùng generalization, nên không có rủi ro LSP.

## F6. State machine

Không có state machine; ST-10 và ST-11 không dùng. Lý do: DC-Movie (thuộc PKG-27) có RunStatus đang chiếu, sắp chiếu, hết chiếu nhưng suy ra từ hai ngày và ngày hiện tại (BR-76), không phải thuộc tính động, và thuộc phiên PKG-27; DC-ReportGroup chỉ cộng dồn, DC-ReportPeriod chỉ có hợp lệ hoặc không, không lớp nào có hành vi khác nhau theo trạng thái. Sáu lớp dịch vụ không giữ trạng thái. Ghi chú M7 mục 2: không có trạng thái trung gian nên không cần chuyển trạng thái do cơ chế hồi phục.

## F7. Bảng thuộc tính

Lớp dịch vụ giữ thêm các phụ thuộc tiêm qua constructor (IF-08, IF-11, IF-13, IF-14, IF-12, IF-28) là association ở F5 nên không lặp ở bảng này.

| DC | Visibility | Tên | Kiểu | Multiplicity | Mặc định | Ràng buộc | Phạm vi | Derived | Nguồn | Mô tả |
|---|---|---|---|---|---|---|---|---|---|---|
| DC-BrowseMoviesService | - | zone | *time.Location | 1 | Asia/Ho_Chi_Minh | {readOnly} | Instance | Không | Q-268 | Múi giờ nghiệp vụ để đổi thời điểm của CSDL thành ngày nghiệp vụ |
| DC-BrowseShowtimesService | - | zone | *time.Location | 1 | Asia/Ho_Chi_Minh | {readOnly} | Instance | Không | Q-268 | Múi giờ nghiệp vụ cho lọc theo ngày chiếu và ngày hiện tại |
| DC-ViewCinemaReportService | - | zone | *time.Location | 1 | Asia/Ho_Chi_Minh | {readOnly} | Instance | Không | Q-268 | Múi giờ nghiệp vụ để đổi kỳ báo cáo thành khoảng thời điểm |
| DC-ViewChainReportService | - | zone | *time.Location | 1 | Asia/Ho_Chi_Minh | {readOnly} | Instance | Không | Q-268 | Múi giờ nghiệp vụ để đổi kỳ báo cáo thành khoảng thời điểm |
| DC-ReportPeriod | - | fromDate | *BusinessDate | 0..1 | - | - | Instance | Không | AC-E-ReportPeriod | Từ ngày; rỗng khi quản lý chưa nhập |
| DC-ReportPeriod | - | toDate | *BusinessDate | 0..1 | - | - | Instance | Không | AC-E-ReportPeriod | Đến ngày; rỗng khi quản lý chưa nhập |
| DC-ReportGroup | - | key | GroupKey | 1 | - | {readOnly} | Instance | Không | AC-E-ReportGroup | Khoá nhóm: ngày chiếu, phim hoặc suất chiếu |
| DC-ReportGroup | - | revenue | Money | 1 | 0 | {>= 0} | Instance | Không | BR-77, BR-115 | Doanh thu ròng đã cộng của nhóm |
| DC-ReportGroup | - | soldSeats | int | 1 | 0 | {>= 0} | Instance | Không | BR-88 | Tổng ghế của vé đã bán chưa huỷ |
| DC-ReportGroup | - | capacity | int | 1 | 0 | {>= 0} | Instance | Không | BR-116, BR-118 | Tổng sức chứa của các suất chiếu chưa xoá |

## F8. Class diagram

| Sơ đồ | Phạm vi (PKG / UC) | File .drawio | Số lớp |
|---|---|---|---|
| Catalog | PKG-17; UC-003, UC-004 | diagrams/P12-class-PKG-17.drawio | 12 nút, 2 lớp có ngăn đầy đủ |
| Reporting và ReportModel | PKG-18, PKG-33; UC-015, UC-016 | diagrams/P12-class-PKG-18-PKG-33.drawio | 15 nút, 5 lớp có ngăn đầy đủ |
| ChainManagement | PKG-30; UC-010, UC-011 | diagrams/P12-class-PKG-30.drawio | 11 nút, 2 lớp có ngăn đầy đủ |

Lớp PKG-27 và kiểu phụ trợ chỉ xuất hiện làm tham chiếu (tên và stereotype, không ngăn thành viên). Package có control chỉ vẽ interface PKG-27 được dùng và các entity trực tiếp trong kết quả; các dependency khác tới PKG-27 liệt kê ở F5.

F8.1. Sơ đồ PKG-17

| ID | Loại | Nhãn | Stereotype | Thuộc về (PKG) | Ghi chú |
|---|---|---|---|---|---|
| DC-BrowseMoviesService | Class | BrowseMoviesService | «control» | PKG-17 | - |
| DC-BrowseShowtimesService | Class | BrowseShowtimesService | «control» | PKG-17 | - |
| IF-14 | Interface | IMovieRepository | «interface» | PKG-27 | tham chiếu (PKG-27) |
| IF-08 | Interface | IUnitOfWork | «interface» | PKG-27 | tham chiếu (PKG-27) |
| IF-11 | Interface | IShowtimeRepository | «interface» | PKG-27 | tham chiếu (PKG-27) |
| IF-47 | Interface | ICinemaReader | «interface» | PKG-27 | tham chiếu (PKG-27) |
| DC-Movie | Class | Movie | «entity» | PKG-27 | tham chiếu (PKG-27) |
| DC-ShowtimeInfo | Class | ShowtimeInfo | «value object» | PKG-27 | tham chiếu (PKG-27) |
| DC-MovieListing | Class | MovieListing | «value object» | PKG-17 | thành phần ở F1b, ngăn thuộc tính và operation không vẽ |
| DC-ShowtimeListing | Class | ShowtimeListing | «value object» | PKG-17 | thành phần ở F1b, ngăn thuộc tính và operation không vẽ |
| DC-MovieSummary | Class | MovieSummary | «value object» | PKG-17 | thành phần ở F1b, ngăn thuộc tính và operation không vẽ |
| DC-BrowseCriteria | Class | BrowseCriteria | «value object» | PKG-17 | thành phần ở F1b, ngăn thuộc tính và operation không vẽ |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| R-240 | DC-BrowseMoviesService | IF-08 | Association | A 0..* - B 1 | tiêm phụ thuộc |
| R-241 | DC-BrowseMoviesService | IF-14 | Association | A 0..* - B 1 | tiêm phụ thuộc |
| R-74 | DC-BrowseMoviesService | DC-Movie | Dependency | - | - |
| R-242 | DC-BrowseShowtimesService | IF-08 | Association | A 0..* - B 1 | tiêm phụ thuộc |
| R-243 | DC-BrowseShowtimesService | IF-11 | Association | A 0..* - B 1 | tiêm phụ thuộc |
| R-483 | DC-BrowseShowtimesService | IF-47 | Association | A 0..* - B 1 | tiêm phụ thuộc |
| R-245 | DC-BrowseShowtimesService | IF-14 | Association | A 0..* - B 1 | tiêm phụ thuộc |
| R-246 | DC-BrowseShowtimesService | DC-BrowseCriteria | Dependency | - | - |
| R-247 | DC-BrowseShowtimesService | DC-ShowtimeInfo | Dependency | - | - |
| R-248 | DC-MovieListing | DC-MovieSummary | Composition | A 1 - B 0..* | - |
| R-249 | DC-ShowtimeListing | DC-ShowtimeInfo | Composition | A 1 - B 0..* | - |

F8.2. Sơ đồ PKG-18 và PKG-33

| ID | Loại | Nhãn | Stereotype | Thuộc về (PKG) | Ghi chú |
|---|---|---|---|---|---|
| DC-ViewCinemaReportService | Class | ViewCinemaReportService | «control» | PKG-18 | - |
| DC-ViewChainReportService | Class | ViewChainReportService | «control» | PKG-18 | - |
| IF-08 | Interface | IUnitOfWork | «interface» | PKG-27 | tham chiếu (PKG-27) |
| IF-28 | Interface | IReportRepository | «interface» | PKG-33 | - |
| IF-47 | Interface | ICinemaReader | «interface» | PKG-27 | tham chiếu (PKG-27) |
| DC-ReportPeriod | Class | ReportPeriod | «entity» | PKG-33 | - |
| DC-ReportGroup | Class | ReportGroup | «entity» | PKG-33 | - |
| DC-Cinema | Class | Cinema | «entity» | PKG-27 | tham chiếu (PKG-27) |
| DC-ReportFigures | Class | ReportFigures | «value object» | PKG-33 | thành phần ở F1b, ngăn thuộc tính và operation không vẽ |
| DC-GroupKey | Class | GroupKey | «value object» | PKG-33 | thành phần ở F1b, ngăn thuộc tính và operation không vẽ |
| DC-CinemaReport | Class | CinemaReport | «value object» | PKG-18 | thành phần ở F1b, ngăn thuộc tính và operation không vẽ |
| DC-ChainReport | Class | ChainReport | «value object» | PKG-18 | thành phần ở F1b, ngăn thuộc tính và operation không vẽ |
| DC-ChainReportEntry | Class | ChainReportEntry | «value object» | PKG-18 | thành phần ở F1b, ngăn thuộc tính và operation không vẽ |
| DC-GroupFigures | Class | GroupFigures | «value object» | PKG-33 | thành phần ở F1b, ngăn thuộc tính và operation không vẽ |
| DC-CinemaGroupFigures | Class | CinemaGroupFigures | «value object» | PKG-18 | thành phần ở F1b, ngăn thuộc tính và operation không vẽ |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| R-250 | DC-ViewCinemaReportService | IF-08 | Association | A 0..* - B 1 | tiêm phụ thuộc |
| R-251 | DC-ViewCinemaReportService | IF-28 | Association | A 0..* - B 1 | tiêm phụ thuộc |
| R-91 | DC-ViewCinemaReportService | DC-ReportPeriod | Dependency | - | - |
| R-95 | DC-ViewCinemaReportService | DC-ReportGroup | Dependency | - | - |
| R-252 | DC-ViewChainReportService | IF-08 | Association | A 0..* - B 1 | tiêm phụ thuộc |
| R-253 | DC-ViewChainReportService | IF-28 | Association | A 0..* - B 1 | tiêm phụ thuộc |
| R-484 | DC-ViewChainReportService | IF-47 | Association | A 0..* - B 1 | tiêm phụ thuộc |
| R-97 | DC-ViewChainReportService | DC-ReportPeriod | Dependency | - | - |
| R-98 | DC-ViewChainReportService | DC-Cinema | Dependency | - | - |
| R-100 | DC-ViewChainReportService | DC-ReportGroup | Dependency | - | - |
| R-255 | DC-CinemaReport | DC-GroupFigures | Composition | A 1 - B 0..* | - |
| R-256 | DC-ChainReport | DC-ChainReportEntry | Composition | A 1 - B 0..* | - |
| R-257 | DC-ChainReportEntry | DC-CinemaGroupFigures | Composition | A 1 - B 0..* | - |
| R-70 | DC-ReportGroup | DC-Cinema | Association | A 0..* - B 0..1 | - |
| R-258 | DC-ReportGroup | DC-GroupKey | Association | A 0..* - B 1 | - |
| R-259 | DC-ReportFigures | DC-GroupKey | Association | A 0..* - B 1 | - |
| R-260 | IF-28 | DC-ReportFigures | Dependency | - | - |
| R-261 | DC-ReportGroup | DC-ReportFigures | Dependency | - | - |

F8.3. Sơ đồ PKG-30

| ID | Loại | Nhãn | Stereotype | Thuộc về (PKG) | Ghi chú |
|---|---|---|---|---|---|
| DC-ManageMoviesService | Class | ManageMoviesService | «control» | PKG-30 | - |
| DC-ManageCinemasService | Class | ManageCinemasService | «control» | PKG-30 | - |
| IF-14 | Interface | IMovieRepository | «interface» | PKG-27 | tham chiếu (PKG-27) |
| IF-08 | Interface | IUnitOfWork | «interface» | PKG-27 | tham chiếu (PKG-27) |
| IF-13 | Interface | ICinemaRepository | «interface» | PKG-27 | tham chiếu (PKG-27) |
| IF-12 | Interface | IPriceListRepository | «interface» | PKG-27 | tham chiếu (PKG-27) |
| DC-Movie | Class | Movie | «entity» | PKG-27 | tham chiếu (PKG-27) |
| DC-MovieInfo | Class | MovieInfo | «value object» | PKG-27 | tham chiếu (PKG-27) |
| DC-Cinema | Class | Cinema | «entity» | PKG-27 | tham chiếu (PKG-27) |
| DC-CinemaInfo | Class | CinemaInfo | «value object» | PKG-27 | tham chiếu (PKG-27) |
| DC-ValueLockKind | Enumeration | ValueLockKind | «enumeration» | PKG-27 | tham chiếu (PKG-27) |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| R-262 | DC-ManageMoviesService | IF-08 | Association | A 0..* - B 1 | tiêm phụ thuộc |
| R-263 | DC-ManageMoviesService | IF-14 | Association | A 0..* - B 1 | tiêm phụ thuộc |
| R-83 | DC-ManageMoviesService | DC-Movie | Dependency | - | - |
| R-264 | DC-ManageMoviesService | DC-MovieInfo | Dependency | - | - |
| R-265 | DC-ManageCinemasService | IF-08 | Association | A 0..* - B 1 | tiêm phụ thuộc |
| R-266 | DC-ManageCinemasService | IF-13 | Association | A 0..* - B 1 | tiêm phụ thuộc |
| R-267 | DC-ManageCinemasService | IF-12 | Association | A 0..* - B 1 | tiêm phụ thuộc |
| R-85 | DC-ManageCinemasService | DC-Cinema | Dependency | - | - |
| R-268 | DC-ManageCinemasService | DC-CinemaInfo | Dependency | - | - |
| R-269 | DC-ManageCinemasService | DC-ValueLockKind | Dependency | - | - |

## F9. Gán package và kiểm tra phụ thuộc package

| PKG | Lớp (DC) | Phụ thuộc vào PKG (suy từ F5) | Hợp lệ theo P09 (Có / Không: lý do) |
|---|---|---|---|
| PKG-17 Catalog | DC-BrowseMoviesService, DC-BrowseShowtimesService và 7 kiểu F1b | PKG-27 (IF-08, IF-11, IF-47, IF-14, DC-Movie, DC-ShowtimeInfo) | Có: Application xuống Domain, không vòng. Cạnh PKG-17 --> PKG-21 của P10 không có quan hệ lớp nào ở đây vì IF-08 thuộc PKG-27; việc nối bản hiện thực chỉ ở hàm khởi động (Đề xuất sửa artifact trước) |
| PKG-18 Reporting | DC-ViewCinemaReportService, DC-ViewChainReportService và 5 kiểu F1b | PKG-27 (IF-08, IF-47, DC-Cinema, BusinessDate, TxOptions), PKG-33 (IF-28, DC-ReportPeriod, DC-ReportGroup) | Có: xuống Domain, không vòng. Cạnh PKG-18 --> PKG-21 và PKG-18 --> PKG-28 của P10 không có quan hệ lớp: doanh thu ròng tính ở IF-28, không gọi DC-Ticket, DC-RefundRequest |
| PKG-30 ChainManagement | DC-ManageMoviesService, DC-ManageCinemasService, DC-FieldInvalidError, DC-CinemaNameTakenError | PKG-27 (IF-08, IF-12, IF-13, IF-14, DC-Movie, DC-Cinema, DC-PriceList, DC-ValueLockKind) | Có: như trên; cạnh PKG-30 --> PKG-21 không có quan hệ lớp |
| PKG-33 ReportModel | DC-ReportPeriod, DC-ReportGroup, IF-28 và 8 kiểu F1b | PKG-27 (DC-CinemaIds, DC-Money, IF-25 Tx, DC-Cinema) | Có: Domain sang Domain, một chiều. DC-PgReportStore (PKG-21) hiện thực IF-28 là realization xuống layer dưới đặt interface ở Domain, hợp lệ |

Kiểm tra gán package: DC-FieldInvalidError đặt ở PKG-30 vì chỉ dịch vụ PKG-30 ném; DC-InvalidPeriodError đặt ở PKG-33 cùng DC-ReportPeriod ném nó. Mọi lớp public của PKG-17, PKG-18, PKG-30 là lớp dịch vụ mà PKG-11 gọi; kiểu kết quả public vì PKG-11 đọc.

## F10. Design pattern đã áp dụng

Không có pattern mới. Repository (IF-11 đến IF-14, IF-28) và Unit of Work (IF-08) đã chọn ở P09, P10. Không tạo Strategy cho ba cách xem báo cáo vì khác biệt chỉ nằm ở mệnh đề GROUP BY của IF-28 và nhãn nhóm, không ở thuật toán cộng; không tạo Specification cho tiêu chí lọc lịch chiếu vì chỉ có một nơi dùng (selectShowtimes).

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Người quyết | Đề xuất |
|---|---|---|---|---|---|
| Q-302 | Đã trả lời (chủ dự án chốt theo đề xuất). Câu hỏi gốc: Danh sách phim (UC-003, UC-004), danh sách cụm rạp và lịch chiếu (UC-004) hiển thị theo thứ tự nào? | DC-BrowseMoviesService.ListMovies, DC-BrowseShowtimesService (mọi operation liệt kê); SCR-23, SCR-25 | P04 UC-003, UC-004 không nêu thứ tự; khách thấy được | Bên nghiệp vụ | Phim đang chiếu theo tên rồi mã phim, phim sắp chiếu theo ngày khởi chiếu rồi tên; cụm rạp theo tên; suất chiếu theo giờ bắt đầu rồi tên cụm rạp, tên phòng |
| Q-303 | Đã trả lời (chủ dự án chốt theo đề xuất). Câu hỏi gốc: Báo cáo (UC-015, UC-016) xếp các nhóm và các cụm rạp trong nhóm theo thứ tự nào? | IF-28 (thứ tự dòng), DC-ViewChainReportService.ViewChainReport; SCR-30, SCR-36 | P04 UC-015, UC-016 không nêu thứ tự nhóm, thứ tự cụm rạp | Bên nghiệp vụ | Nhóm theo ngày tăng dần, theo phim theo tên rồi mã phim, theo suất chiếu theo giờ bắt đầu; cụm rạp theo tên tăng dần |
| Q-304 | Đã trả lời (chủ dự án chốt theo đề xuất). Câu hỏi gốc: Báo cáo theo phim gom theo mã phim hay theo tên phim, khi hai phim trùng tên (được phép, Q-200)? | DC-GroupKey (BY_MOVIE), IF-28; SCR-30, SCR-36 | Q-200 cho phép trùng tên, UC-015 nói "theo phim" | Bên nghiệp vụ | Gom theo mã phim, hiển thị tên phim; hai phim trùng tên thành hai nhóm cùng nhãn |

## Giả định

Không áp dụng (CHE_DO_GIA_DINH là NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P13 | Không | Không đổi: cột mốc thay đổi, chỉ mục unique norm_name(tên cụm rạp) và chỉ mục báo cáo đã có ở P09 | - |
| X2 | Thao tác bị ảnh hưởng | Chưa có ca thử cho sáu lớp dịch vụ, ReportPeriod, ReportGroup | Chạy X2 cho PKG-17, PKG-18, PKG-30, PKG-33 sau khi PKG-27 chốt |

## Vấn đề còn mở

1. Quan hệ P08 có một đầu ngoài phạm vi (Movie, Cinema, Showtime, Auditorium, Ticket, RefundRequest với nhau, ví dụ các quan hệ miền của Movie, Showtime) không thiết kế ở đây; chỉ liệt kê: do phiên PKG-27 và PKG-28 thiết kế.
2. Các lớp chi tiết hoá phụ thuộc operation PKG-27 chưa tồn tại (bảng cuối F2); khi phiên PKG-27 chốt, chạy lại P12 cho phạm vi này để khớp tên và chữ ký.
3. Mức hợp lý: DC-ManageCinemasService có 4 operation và 3 phụ thuộc repository, DC-BrowseShowtimesService có 5 operation (một private); đều dưới ngưỡng 15 operation.
4. Chữ ký công khai trả entity (Movie, Cinema) ra PKG-11 theo quyết định hoãn DTO SY-23; chưa đạt tiêu chí tách DTO.
5. float64 cho tỉ lệ lấp đầy: chấp nhận vì tỉ lệ không phải tiền; số chữ số hiển thị do SCR-30, SCR-36 quyết định.
6. Thời gian hiển thị báo cáo: Q-269 chốt mục tiêu 5 giây (cụm rạp, 31 ngày) và 10 giây (toàn chuỗi); chưa đo được ở bước thiết kế, ca đo T7 của P09 F7.9 kiểm; statement_timeout 15 giây làm ViewCinemaReport và ViewChainReport trả SystemBusyError khi vượt.
7. Tiêu chí Target 7 đạt cho mọi message của sáu UC; tiêu chí 18 (state machine) đạt bằng F6 (không lớp nào cần); tiêu chí 28 (TRANH_CHAP_TAI_NGUYEN): EX-16, EX-17 có ranh giới giao dịch, thứ tự khoá và đường thử lại ở F3, các dòng Bảng hỏng liên quan (bấm lại, dừng giữa thao tác ghi nhiều bản ghi) khớp F3.
