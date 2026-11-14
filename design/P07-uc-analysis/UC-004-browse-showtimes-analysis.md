# P07 - Phân tích use case UC-004 Tra cứu lịch chiếu - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P07 |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | 00-Conventions.md; 00-Concurrency.md; project-profile.md; P01-actors.md 1.2; P02-usecases.md 1.9; P03-usecase-model.md 1.2; P05-glossary.md 1.2; P06-supplementary-spec.md 1.4; P04-uc-specs/_BR-register.md (đầu lô); P04-uc-specs/UC-004-browse-showtimes.md 1.1; P07-uc-analysis/UC-003-browse-movies-analysis.md 1.0 (cùng lô, dùng lại AC-E-Movie // determineRunStatus); sổ AC lập từ F3.4 của P07-uc-analysis/UC-005, UC-006, UC-008, UC-009, UC-013, UC-014 (đầu lô); P08-analysis-model.md 1.5 (mã AC-E-Cinema, AC-E-Seat đã cấp); _sync-log.md (Đầu vào cho lần chạy lại P07-P13, dòng UC-015, UC-016); dải mã Q được cấp 235 đến 244, không cấp ASM |
| Phạm vi | UC-004 |
| Mã Q, ASM cuối đã cấp | Q-180 (cấp ở P04, đã trả lời); không cấp Q mới ở use case này; không có ASM (NGHIEM_NGAT) |

## 1. Bối cảnh use case

| Thuộc tính | Giá trị |
|---|---|
| Mã và tên UC | UC-004 Tra cứu lịch chiếu (Browse Showtimes) |
| Tác nhân chính | ACT-01 Khách (Người) |
| Tác nhân phụ | Không có |
| Include (UC) | Không có |
| Được include bởi (UC) | Không có |
| Extend (UC, điểm mở rộng, điều kiện) | Không có |
| Được extend bởi (UC, điểm mở rộng, điều kiện) | Không có |
| Use case liên quan không qua include, extend | UC-005 Đặt vé: khách chọn suất chiếu ở UC-005 bước 1; UC-005 từ chối suất chiếu chưa mở bán hoặc đã tới giờ bắt đầu (BR-01, BR-45) nên lịch chiếu không bảo đảm đặt được. UC-014 Lập lịch suất chiếu: lập, sửa, xoá suất chiếu (BR-58). UC-010, UC-011, UC-012: cung cấp dữ liệu phim, cụm rạp, phòng chiếu. UC-003 Tra cứu phim: dùng chung điều kiện phân nhóm phim (BR-76) |
| Tác nhân thời gian | Không có. P02 không có use case do tác nhân thời gian kích hoạt trên đối tượng mà UC-004 đọc; P04 Mục 8 xác nhận không có bước hẹn hoặc huỷ mốc (F4.2 mục 17). Không có message hẹn mốc |
| File P07 đã có được dùng làm sổ đăng ký AC | UC-014-schedule-showtimes-analysis.md (AC-E-Showtime, AC-E-Auditorium, AC-E-Movie) và UC-003-browse-movies-analysis.md (cùng lô). Tái dùng AC-E-Cinema theo mã đã cấp ở P08 (chủ sở hữu UC-011). Các lớp còn lại không tham gia UC-004 |
| Đồng thời | Use case chỉ đọc nên không có thao tác không chia cắt và không có đơn vị loại trừ (P04 Mục 8: Thao tác nguyên tử Không có; 00-Concurrency.md M3 mục 1). Thay đổi do use case khác ghi nhận trong lúc đọc chỉ hiện ở lần xem sau |

## 2. Đặc tả bổ sung

| Bước UC | Thực hiện bởi | Mô tả trong đặc tả | Mô tả bổ sung (hệ thống làm gì bên trong) | Nguồn (BR, GL, REQ) |
|---|---|---|---|---|
| 1 | Khách | Yêu cầu xem lịch chiếu theo phim. | Không đổi | REQ-08 |
| 2 | Hệ thống | Hiển thị danh sách phim để chọn (xem Dữ liệu ra 1). | Control đi qua từng phim trong danh sách phim của chuỗi; mỗi phim tự phân nhóm theo ngày hiện tại (BR-76) và chỉ phim đang chiếu hoặc sắp chiếu cung cấp tên để đưa vào danh sách (Q-180). | BR-76, GL-38, GL-39, Q-180, REQ-08 |
| 3 | Khách | Chọn một phim, kèm các tiêu chí lọc tuỳ ý (xem Dữ liệu vào 1). | Không đổi | REQ-08, REQ-10 |
| 4 | Hệ thống | Xác định các suất chiếu của phim đã chọn ở các cụm rạp, thoả mọi tiêu chí lọc đã chọn (BR-58; chỉ suất chiếu chưa tới giờ bắt đầu, kể cả chưa tới thời điểm mở bán, BR-45). | Control đi qua từng suất chiếu của phim đã chọn. Mỗi suất chiếu tự kiểm còn trong lịch chiếu (chưa xoá, BR-58), chưa tới giờ bắt đầu (BR-45) và khớp mọi tiêu chí lọc khách đã chọn: định dạng, ngày của giờ bắt đầu (Q-179), loại phòng và tỉnh thành phố (hỏi phòng chiếu, rồi cụm rạp của phòng); tiêu chí không chọn thì không giới hạn. | BR-45, BR-58, GL-14, GL-47, GL-49, Q-176, Q-177, Q-179, REQ-10 |
| 5 | Hệ thống | Hiển thị lịch chiếu gồm các suất chiếu đã xác định (xem Dữ liệu ra 2). | Mỗi suất chiếu thoả điều kiện cung cấp phim (hỏi phim), định dạng, cụm rạp và tỉnh thành phố (hỏi phòng chiếu, rồi cụm rạp), phòng chiếu, loại phòng, ngày giờ bắt đầu, thời điểm mở bán; control gom chuyển cho boundary hiển thị. | Dữ liệu ra 2, Q-176, Q-178, REQ-61 |
| 4a | Hệ thống | Thông báo không có suất chiếu phù hợp. | Không suất chiếu nào của phim thoả điều kiện thì control báo boundary hiển thị thông báo; kết thúc thành công, dữ liệu không đổi. | BR-45, BR-58, REQ-08 |
| 1a | - | Khách chọn xem lịch chiếu theo cụm rạp thay vì theo phim. | Không đổi | REQ-09 |
| 1a1 | Khách | Yêu cầu xem lịch chiếu theo cụm rạp. | Không đổi | REQ-09 |
| 1a2 | Hệ thống | Hiển thị danh sách cụm rạp để chọn (xem Dữ liệu ra 3). | Control đi qua từng cụm rạp của chuỗi; mỗi cụm rạp cung cấp tên (và tỉnh thành phố) để đưa vào danh sách. | Dữ liệu ra 3, REQ-54, REQ-09 |
| 1a3 | Khách | Chọn một cụm rạp, kèm các tiêu chí lọc tuỳ ý (xem Dữ liệu vào 2). | Không đổi | REQ-09, REQ-10 |
| 1a4 | Hệ thống | Xác định các suất chiếu tại cụm rạp đã chọn, thoả mọi tiêu chí lọc đã chọn (BR-58; chỉ suất chiếu chưa tới giờ bắt đầu, kể cả chưa tới thời điểm mở bán, BR-45). | Như bước 4 nhưng control đi qua từng suất chiếu tại cụm rạp đã chọn thay vì của phim đã chọn. | BR-45, BR-58, Q-176, Q-177, Q-179, REQ-10 |
| 1a4a | Hệ thống | Thông báo không có suất chiếu phù hợp. | Như luồng 4a cho cụm rạp đã chọn; kết thúc thành công. | BR-45, BR-58, REQ-09 |
| 1a5 | Hệ thống | Hiển thị lịch chiếu gồm các suất chiếu đã xác định ở bước 1a4 (xem Dữ liệu ra 2). | Như bước 5. | Dữ liệu ra 2, REQ-61 |

## 3. Tìm lớp phân tích

### 3.1 Bảng boundary

| Tác nhân (ACT) | Loại tác nhân | Boundary | Loại boundary | Mới hoặc tái dùng (AC, UC nguồn) | Lý do |
|---|---|---|---|---|---|
| ACT-01 Khách | Người | BrowseShowtimesForm | Giao diện người dùng | Mới (AC-B-BrowseShowtimesForm) | Khách yêu cầu xem lịch chiếu theo phim hoặc theo cụm rạp, chọn phim hoặc cụm rạp kèm tiêu chí lọc và nhận danh sách phim, danh sách cụm rạp, lịch chiếu hoặc thông báo rỗng. Một boundary cho cả hai cách tra cứu, không tách theo màn hình. Khác BrowseMoviesForm của UC-003 vì boundary giao diện người dùng đặt tên theo tương tác của từng use case (A3). |

Số boundary là 1, bằng số tác nhân tham gia (không có tác nhân phụ, không có tác nhân thời gian).

### 3.2 Bảng lọc danh từ

| STT | Danh từ hoặc cụm danh từ | Vị trí (bước UC, mục dữ liệu, BR) | Kết luận | Lý do |
|---|---|---|---|---|
| 1 | khách | 1, 3, 1a1, 1a3 | Loại - là tác nhân hoặc ngoài phạm vi | Tác nhân chính, không đăng nhập (REQ-08, REQ-09). |
| 2 | lịch chiếu | 1, 5, 1a1, 1a5 | Loại - cấu trúc cài đặt | P05 mục 3: cách gọi tập hợp các suất chiếu, không là thực thể riêng. |
| 3 | phim, danh sách phim | 2, 3; Dữ liệu ra 1 | Entity AC-E-Movie | Hệ thống lưu; có hành vi phân nhóm phim đang chiếu, sắp chiếu (BR-76) và cung cấp tên (GL-37). Danh sách phim là kết quả duyệt các Movie (cấu trúc cài đặt). |
| 4 | phim đang chiếu, phim sắp chiếu | 2; BR-76 | Loại - giá trị suy ra từ Movie | GL-38, GL-39: tính từ ngày hiện tại và ngày của phim, không lưu. |
| 5 | suất chiếu | 4, 5, 1a4, 1a5; BR-45, BR-58 | Entity AC-E-Showtime | Hệ thống lưu; có hành vi kiểm còn trong lịch chiếu, chưa tới giờ bắt đầu, khớp tiêu chí lọc và cung cấp thông tin hiển thị (GL-47). |
| 6 | suất chiếu đã xoá | Mục 8; BR-58 | Loại - thuộc tính của Showtime | GL-49: giá trị Đã xoá của thuộc tính status; bị loại khỏi lịch chiếu. |
| 7 | cụm rạp, danh sách cụm rạp | 1a2, 1a3; Dữ liệu ra 2, 3 | Entity AC-E-Cinema | Hệ thống lưu; cung cấp tên và tỉnh thành phố, kiểm tỉnh thành phố theo tiêu chí lọc (GL-03). Danh sách cụm rạp là cấu trúc cài đặt; cụm rạp do UC-011 quản lý, mã đã cấp ở P08. |
| 8 | phòng chiếu, loại phòng | 4, 5; Dữ liệu vào 1 dòng 4; Dữ liệu ra 2 | Entity AC-E-Auditorium | Hệ thống lưu; giữ loại phòng và cụm rạp của phòng nên kiểm tiêu chí loại phòng và tỉnh thành phố, cung cấp tên phòng và loại phòng (GL-40, GL-27). |
| 9 | tiêu chí lọc | 3, 1a3; Dữ liệu vào 1, 2 | Loại - dữ liệu trao đổi qua boundary BrowseShowtimesForm | Giá trị khách nhập, không lưu. |
| 10 | tỉnh, thành phố | Dữ liệu vào 1 dòng 2; Dữ liệu ra 2 dòng 7 | Loại - thuộc tính của Cinema | REQ-10, Q-178; thuộc tính province mới ở UC này. |
| 11 | ngày, ngày giờ bắt đầu, giờ bắt đầu | Dữ liệu vào 1 dòng 3; Dữ liệu ra 2 dòng 5; BR-45 | Loại - thuộc tính của Showtime | GL-14; ngày lọc so với ngày của giờ bắt đầu (Q-179). |
| 12 | định dạng phim, định dạng | Dữ liệu vào 1 dòng 5; Dữ liệu ra 2 dòng 2 | Loại - thuộc tính của Showtime | GL-05; thuộc tính movieFormat đã có. |
| 13 | thời điểm mở bán | Dữ liệu ra 2 dòng 8; Q-176 | Loại - thuộc tính của Showtime | GL-53; thuộc tính saleOpenTime đã có. |
| 14 | tên phim, tên cụm rạp, tên phòng chiếu | Dữ liệu ra 1, 2, 3 | Loại - thuộc tính của Movie, Cinema, Auditorium | Tên của từng khái niệm tương ứng. |
| 15 | ghế, trạng thái ghế, số ghế còn trống, giá vé | Mục 8; Q-178 | Loại - không tham gia hành vi của use case này (khái niệm của UC-005) | Lịch chiếu không hiển thị ghế và giá vé. |
| 16 | giờ kết thúc | Mục 8; Q-178 | Loại - không tham gia hành vi của use case này | Không hiển thị trong lịch chiếu. |
| 17 | thông báo không có suất chiếu phù hợp | 4a, 1a4a | Loại - dữ liệu trao đổi qua boundary BrowseShowtimesForm | Nội dung thông báo, không lưu. |
| 18 | thứ tự sắp xếp kết quả | Mục 8 | Loại - cấu trúc cài đặt | Thuộc thiết kế giao diện (P04 Mục 8). |
| 19 | yêu cầu xem, việc chọn | 1, 3, 1a1, 1a3 | Loại - thao tác hoặc sự kiện | Hành động của khách tại boundary. |
| 20 | hệ thống, thông tin, kết quả | Nhiều bước | Loại - mơ hồ | Không là khái niệm nghiệp vụ cụ thể. |

### 3.3 Bảng control

| Control | Use case điều phối | Mới hoặc tái dùng | Lý do (hoặc lý do không có control) |
|---|---|---|---|
| BrowseShowtimesController | UC-004 | Mới (AC-C-BrowseShowtimesController) | Một control cho use case: điều phối bốn yêu cầu của tác nhân (danh sách phim, lịch chiếu theo phim, danh sách cụm rạp, lịch chiếu theo cụm rạp), duyệt từng phim, cụm rạp, suất chiếu. Quy tắc lọc nằm ở Showtime, Auditorium, Cinema. Có 4 trách nhiệm. |

### 3.4 Bảng lớp phân tích

| AC | Stereotype | Tên | Trách nhiệm | Thuộc tính chính | Bước UC nguồn | Loại boundary | Mới hoặc tái dùng | GL |
|---|---|---|---|---|---|---|---|---|
| AC-B-BrowseShowtimesForm | boundary | BrowseShowtimesForm | // requestShowtimesByMovie: khách yêu cầu xem lịch chiếu theo phim<br>// showMovieList: hiển thị danh sách tên phim đang chiếu, sắp chiếu để chọn<br>// selectMovieAndCriteria: khách chọn một phim kèm các tiêu chí lọc tuỳ ý<br>// showShowtimes: hiển thị lịch chiếu gồm phim, định dạng, cụm rạp, phòng chiếu, ngày giờ bắt đầu, loại phòng, tỉnh thành phố, thời điểm mở bán của từng suất chiếu<br>// notifyNoShowtimes: thông báo không có suất chiếu phù hợp<br>// requestShowtimesByCinema: khách yêu cầu xem lịch chiếu theo cụm rạp<br>// showCinemaList: hiển thị danh sách tên cụm rạp để chọn<br>// selectCinemaAndCriteria: khách chọn một cụm rạp kèm các tiêu chí lọc tuỳ ý | browseCriteria (Phim hoặc cụm rạp đã chọn, tỉnh thành phố, ngày, loại phòng, định dạng phim) | 1, 2, 3, 5, 4a, 1a, 1a1, 1a2, 1a3, 1a5, 1a4a | Giao diện người dùng | Mới | GL-18 |
| AC-C-BrowseShowtimesController | control | BrowseShowtimesController | // startBrowsingByMovie: điều phối bước 2: duyệt từng phim, lấy tên phim đang chiếu hoặc sắp chiếu, báo boundary hiển thị danh sách phim<br>// findShowtimesByMovie: điều phối bước 4, 5, 4a: duyệt từng suất chiếu của phim đã chọn, hỏi điều kiện liệt kê, lấy thông tin hiển thị, báo boundary hiển thị lịch chiếu hoặc thông báo<br>// startBrowsingByCinema: điều phối bước 1a2: duyệt từng cụm rạp, lấy tên, báo boundary hiển thị danh sách cụm rạp<br>// findShowtimesByCinema: điều phối bước 1a4, 1a5, 1a4a: như findShowtimesByMovie cho các suất chiếu tại cụm rạp đã chọn | - | 2, 4, 5, 4a, 1a2, 1a4, 1a5, 1a4a | - | Mới | - |
| AC-E-Movie | entity | Movie | // determineRunStatus: phân loại phim theo ngày hiện tại: đang chiếu, sắp chiếu hoặc không thuộc nhóm nào (BR-76)<br>// provideMovieTitle: cung cấp tên phim | title (Văn bản) | 2, 5, 1a5 | - | Tái dùng từ UC-003, UC-014, bổ sung trách nhiệm; chủ sở hữu UC-010 | GL-37, GL-38, GL-39 |
| AC-E-Showtime | entity | Showtime | // checkInSchedule: kiểm tra suất chiếu còn trong lịch chiếu, chưa bị xoá (BR-58)<br>// checkNotStarted: kiểm tra giờ bắt đầu sau thời điểm kiểm tra, tức suất chiếu chưa tới giờ bắt đầu (BR-45)<br>// checkMatchesCriteria: kiểm tra suất chiếu khớp các tiêu chí lọc đã chọn: định dạng phim, ngày của giờ bắt đầu, và loại phòng, tỉnh thành phố (hỏi phòng chiếu); tiêu chí không chọn thì không giới hạn<br>// provideShowtimeForBrowsing: cung cấp phim (hỏi phim), định dạng, phòng chiếu và cụm rạp (hỏi phòng chiếu), ngày giờ bắt đầu, loại phòng, tỉnh thành phố, thời điểm mở bán để hiển thị trong lịch chiếu | startTime (Ngày giờ)<br>saleOpenTime (Ngày giờ)<br>movieFormat (Văn bản)<br>movie (Phim)<br>auditorium (Phòng chiếu)<br>status (Trạng thái: Trong lịch chiếu, Đã xoá) | 4, 5, 1a4, 1a5 | - | Tái dùng từ UC-014, bổ sung trách nhiệm | GL-47, GL-14, GL-53, GL-49 |
| AC-E-Auditorium | entity | Auditorium | // checkMatchesRoomCriteria: kiểm tra loại phòng của phòng chiếu khớp tiêu chí loại phòng và hỏi cụm rạp của phòng khớp tiêu chí tỉnh thành phố<br>// provideAuditoriumForBrowsing: cung cấp tên phòng chiếu, loại phòng và thông tin cụm rạp của phòng (hỏi cụm rạp) để hiển thị trong lịch chiếu | name (Văn bản)<br>auditoriumType (Văn bản)<br>cinema (Cụm rạp) | 4, 5, 1a4, 1a5 | - | Tái dùng từ UC-014, bổ sung trách nhiệm; chủ sở hữu UC-012 | GL-40, GL-27 |
| AC-E-Cinema | entity | Cinema | // provideCinemaInfo: cung cấp tên cụm rạp và tỉnh thành phố để hiển thị<br>// checkInProvince: kiểm tra cụm rạp thuộc tỉnh, thành phố đã chọn trong tiêu chí lọc (REQ-10) | name (Văn bản) (mới ở UC này)<br>province (Tỉnh, thành phố) (mới ở UC này) | 1a2, 4, 5, 1a4, 1a5 | - | Mới - chủ sở hữu UC-011 (mã đã cấp ở P08) | GL-03 |

Tổng cộng 6 lớp: 1 boundary, 1 control, 4 entity. Entity AC-E-Cinema do UC-011 sở hữu; use case này chỉ đọc nên chỉ có trách nhiệm cung cấp và kiểm tra, các entity đều có ít nhất một trách nhiệm kiểm tra hoặc phân loại.

## 4. Phân bổ hành vi

| Bước UC | Trách nhiệm | Lớp nhận (AC) | Nguyên tắc | Lý do khi có lựa chọn khác |
|---|---|---|---|---|
| 1, 3, 1a1, 1a3, 1a | // requestShowtimesByMovie, // selectMovieAndCriteria, // requestShowtimesByCinema, // selectCinemaAndCriteria | AC-B-BrowseShowtimesForm | Giao tiếp tác nhân | - |
| 2, 4, 1a2, 1a4 | // startBrowsingByMovie, // findShowtimesByMovie, // startBrowsingByCinema, // findShowtimesByCinema | AC-C-BrowseShowtimesController | Controller | Boundary chỉ chuyển yêu cầu và tiêu chí, không lọc. |
| 2 | // determineRunStatus | AC-E-Movie | Information Expert | Cùng điều kiện với UC-003 bước 2 (BR-76), định nghĩa một nơi ở Movie, UC-004 hỏi lại không tự tính (F3.5 c). Không có đối tượng toàn thể (danh sách phim của chuỗi không là entity) nên control lặp và gửi message tới từng phim (A6). |
| 2, 5, 1a5 | // provideMovieTitle | AC-E-Movie | Information Expert | Tên phim là dữ liệu của phim. Ở bước 5 Showtime hỏi Movie (R-UC014-09) thay vì sao chép tên vào suất chiếu. |
| 2, 1a2 | // showMovieList, // showCinemaList | AC-B-BrowseShowtimesForm | Giao tiếp tác nhân | - |
| 1a2 | // provideCinemaInfo | AC-E-Cinema | Information Expert | Không có đối tượng toàn thể (danh sách cụm rạp của chuỗi không là entity) nên control lặp (A6). Cụm rạp giữ tên và tỉnh thành phố. |
| 4, 1a4 | // checkInSchedule | AC-E-Showtime | Information Expert | Trạng thái Đã xoá là dữ liệu của suất chiếu (BR-58). Việc chọn tập suất chiếu của phim hoặc của cụm rạp theo khoá coi là có sẵn (A6 a); control lặp trên tập đó vì cần kết quả kiểm từng suất chiếu. |
| 4, 1a4 | // checkNotStarted | AC-E-Showtime | Information Expert | Dùng lại trách nhiệm của UC-014 cho cùng điều kiện giờ bắt đầu (BR-45, BR-57); không tạo trách nhiệm trùng nghĩa (F3.5 c). |
| 4, 1a4 | // checkMatchesCriteria | AC-E-Showtime | Information Expert | Định dạng và giờ bắt đầu là dữ liệu của suất chiếu. Loại phòng và tỉnh thành phố nằm ở phòng chiếu và cụm rạp nên suất chiếu hỏi tiếp qua quan hệ cấu trúc (Showtime với Auditorium, Auditorium với Cinema) thay vì control hỏi từng lớp (giảm coupling của control). |
| 4, 1a4 | // checkMatchesRoomCriteria | AC-E-Auditorium | Information Expert | Phòng chiếu giữ loại phòng và cụm rạp của mình. |
| 4, 1a4 | // checkInProvince | AC-E-Cinema | Information Expert | Cụm rạp giữ tỉnh thành phố. |
| 5, 1a5 | // provideShowtimeForBrowsing | AC-E-Showtime | Information Expert | Đặt tên khác // provideShowtimeInfo của UC-014 vì nội dung cung cấp khác (có tỉnh thành phố, không có giờ kết thúc, Q-178). |
| 5, 1a5 | // provideAuditoriumForBrowsing | AC-E-Auditorium | Information Expert | Đặt tên khác // provideAuditoriumInfo của UC-014 vì nội dung khác (có cụm rạp, không có định dạng chiếu được). |
| 5, 1a5 | // provideCinemaInfo | AC-E-Cinema | Information Expert | Cùng trách nhiệm với bước 1a2; mỗi lần lấy phần dữ liệu cần dùng. |
| 5, 1a5 | // showShowtimes | AC-B-BrowseShowtimesForm | Giao tiếp tác nhân | - |
| 4a, 1a4a | // notifyNoShowtimes | AC-B-BrowseShowtimesForm | Giao tiếp tác nhân | Control biết kết quả rỗng sau khi duyệt hết (A6 b). |

Thao tác nguyên tử: không có (P04 Mục 8).

## 5. Sequence diagram phân tích

File diagrams/P07-sequence-UC-004.drawio, 2 trang. Số message không kể trả về: SD1 18, SD2 17. Fragment ở mức ngoài cùng mỗi trang: loop, loop, break (3).

### SD1 - Luồng chính và luồng 4a

a) Luồng thể hiện: Khách yêu cầu xem lịch chiếu theo phim, chọn phim kèm tiêu chí lọc; hệ thống liệt kê các suất chiếu thoả điều kiện; luồng 4a kết thúc khi không có suất chiếu phù hợp.

Luồng 4a kết thúc use case (thành công) nên vẽ bằng break ở mức ngoài cùng, đặt sau vòng lặp vì control chỉ biết kết quả rỗng sau khi duyệt hết các suất chiếu của phim. Bước 5 hiển thị là message 2.1.6 sau break.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1-L-A | Actor | :Khách | - | - | Tác nhân (ACT-01) |
| SD1-L-F | Lifeline | :BrowseShowtimesForm | «boundary» | - | AC-B-BrowseShowtimesForm |
| SD1-L-C | Lifeline | :BrowseShowtimesController | «control» | - | AC-C-BrowseShowtimesController |
| SD1-L-M | Lifeline | :Movie | «entity» | - | AC-E-Movie |
| SD1-L-S | Lifeline | :Showtime | «entity» | - | AC-E-Showtime |
| SD1-L-U | Lifeline | :Auditorium | «entity» | - | AC-E-Auditorium |
| SD1-L-N | Lifeline | :Cinema | «entity» | - | AC-E-Cinema |
| SD1-F1 | Fragment | loop [mỗi phim trong danh sách phim của chuỗi] | - | - | mức ngoài cùng |
| SD1-F2 | Fragment | opt [phim đang chiếu hoặc sắp chiếu] | - | SD1-F1 | lồng trong SD1-F1 |
| SD1-F3 | Fragment | loop [mỗi suất chiếu của phim đã chọn] | - | - | mức ngoài cùng |
| SD1-F4 | Fragment | opt [còn trong lịch chiếu, chưa tới giờ bắt đầu và khớp tiêu chí lọc] | - | SD1-F3 | lồng trong SD1-F3 |
| SD1-F5 | Fragment | break [không có suất chiếu nào của phim đã chọn thoả tiêu chí lọc (4a)] | - | - | mức ngoài cùng |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1 | :Khách | :BrowseShowtimesForm | // requestShowtimesByMovie | Đồng bộ | - | 1 |
| 1.1 | :BrowseShowtimesForm | :BrowseShowtimesController | // startBrowsingByMovie | Đồng bộ | - | 2 |
| 1.1.1 | :BrowseShowtimesController | :Movie | // determineRunStatus | Đồng bộ | SD1-F1 | 2 |
| 1.1.1 (trả về) | :Movie | :BrowseShowtimesController | đang chiếu, sắp chiếu hoặc không thuộc nhóm nào | Trả về | SD1-F1 | 2 |
| 1.1.2 | :BrowseShowtimesController | :Movie | // provideMovieTitle | Đồng bộ | SD1-F2 | 2 |
| 1.1.2 (trả về) | :Movie | :BrowseShowtimesController | tên phim | Trả về | SD1-F2 | 2 |
| 1.1.3 | :BrowseShowtimesController | :BrowseShowtimesForm | // showMovieList (tên các phim đang chiếu, sắp chiếu) | Đồng bộ | - | 2 |
| 2 | :Khách | :BrowseShowtimesForm | // selectMovieAndCriteria (phim, tiêu chí lọc tuỳ ý) | Đồng bộ | - | 3 |
| 2.1 | :BrowseShowtimesForm | :BrowseShowtimesController | // findShowtimesByMovie (phim, tiêu chí lọc) | Đồng bộ | - | 3, 4 |
| 2.1.1 | :BrowseShowtimesController | :Showtime | // checkInSchedule | Đồng bộ | SD1-F3 | 4 |
| 2.1.1 (trả về) | :Showtime | :BrowseShowtimesController | còn trong lịch chiếu hoặc đã xoá | Trả về | SD1-F3 | 4 |
| 2.1.2 | :BrowseShowtimesController | :Showtime | // checkNotStarted | Đồng bộ | SD1-F3 | 4 |
| 2.1.2 (trả về) | :Showtime | :BrowseShowtimesController | chưa tới giờ bắt đầu hoặc đã tới giờ bắt đầu | Trả về | SD1-F3 | 4 |
| 2.1.3 | :BrowseShowtimesController | :Showtime | // checkMatchesCriteria (tiêu chí lọc) | Đồng bộ | SD1-F3 | 4 |
| 2.1.3.1 | :Showtime | :Auditorium | // checkMatchesRoomCriteria (loại phòng, tỉnh thành phố) | Đồng bộ | SD1-F3 | 4 |
| 2.1.3.1.1 | :Auditorium | :Cinema | // checkInProvince (tỉnh thành phố) | Đồng bộ | SD1-F3 | 4 |
| 2.1.3 (trả về) | :Showtime | :BrowseShowtimesController | khớp hoặc không khớp tiêu chí lọc | Trả về | SD1-F3 | 4 |
| 2.1.4 | :BrowseShowtimesController | :Showtime | // provideShowtimeForBrowsing | Đồng bộ | SD1-F4 | 5 |
| 2.1.4.1 | :Showtime | :Movie | // provideMovieTitle | Đồng bộ | SD1-F4 | 5 |
| 2.1.4.2 | :Showtime | :Auditorium | // provideAuditoriumForBrowsing | Đồng bộ | SD1-F4 | 5 |
| 2.1.4.2.1 | :Auditorium | :Cinema | // provideCinemaInfo | Đồng bộ | SD1-F4 | 5 |
| 2.1.4 (trả về) | :Showtime | :BrowseShowtimesController | phim, định dạng, cụm rạp, phòng chiếu, ngày giờ bắt đầu, loại phòng, tỉnh thành phố, thời điểm mở bán | Trả về | SD1-F4 | 5 |
| 2.1.5 | :BrowseShowtimesController | :BrowseShowtimesForm | // notifyNoShowtimes | Đồng bộ | SD1-F5 | 4a |
| 2.1.6 | :BrowseShowtimesController | :BrowseShowtimesForm | // showShowtimes (các suất chiếu đã xác định) | Đồng bộ | - | 5 |

### SD2 - Luồng 1a và luồng 1a4a

a) Luồng thể hiện: Khách chọn xem lịch chiếu theo cụm rạp thay vì theo phim: rẽ nhánh tại message 1 của SD1; hệ thống hiển thị danh sách cụm rạp, rồi liệt kê các suất chiếu tại cụm rạp đã chọn thoả tiêu chí; luồng 1a4a kết thúc khi không có suất chiếu phù hợp.

Cùng cách liệt kê suất chiếu như SD1 nên các message kiểm tra và cung cấp thông tin dùng lại cùng trách nhiệm.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD2-L-A | Actor | :Khách | - | - | Tác nhân (ACT-01) |
| SD2-L-F | Lifeline | :BrowseShowtimesForm | «boundary» | - | AC-B-BrowseShowtimesForm |
| SD2-L-C | Lifeline | :BrowseShowtimesController | «control» | - | AC-C-BrowseShowtimesController |
| SD2-L-M | Lifeline | :Movie | «entity» | - | AC-E-Movie |
| SD2-L-S | Lifeline | :Showtime | «entity» | - | AC-E-Showtime |
| SD2-L-U | Lifeline | :Auditorium | «entity» | - | AC-E-Auditorium |
| SD2-L-N | Lifeline | :Cinema | «entity» | - | AC-E-Cinema |
| SD2-F1 | Fragment | loop [mỗi cụm rạp trong danh sách cụm rạp của chuỗi] | - | - | mức ngoài cùng |
| SD2-F2 | Fragment | loop [mỗi suất chiếu tại cụm rạp đã chọn] | - | - | mức ngoài cùng |
| SD2-F3 | Fragment | opt [còn trong lịch chiếu, chưa tới giờ bắt đầu và khớp tiêu chí lọc] | - | SD2-F2 | lồng trong SD2-F2 |
| SD2-F4 | Fragment | break [không có suất chiếu nào tại cụm rạp đã chọn thoả tiêu chí lọc (1a4a)] | - | - | mức ngoài cùng |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1a | :Khách | :BrowseShowtimesForm | // requestShowtimesByCinema | Đồng bộ | - | 1a, 1a1 |
| 1a.1 | :BrowseShowtimesForm | :BrowseShowtimesController | // startBrowsingByCinema | Đồng bộ | - | 1a2 |
| 1a.1.1 | :BrowseShowtimesController | :Cinema | // provideCinemaInfo | Đồng bộ | SD2-F1 | 1a2 |
| 1a.1.1 (trả về) | :Cinema | :BrowseShowtimesController | tên cụm rạp, tỉnh thành phố | Trả về | SD2-F1 | 1a2 |
| 1a.1.2 | :BrowseShowtimesController | :BrowseShowtimesForm | // showCinemaList (tên các cụm rạp) | Đồng bộ | - | 1a2 |
| 1a.2 | :Khách | :BrowseShowtimesForm | // selectCinemaAndCriteria (cụm rạp, tiêu chí lọc tuỳ ý) | Đồng bộ | - | 1a3 |
| 1a.2.1 | :BrowseShowtimesForm | :BrowseShowtimesController | // findShowtimesByCinema (cụm rạp, tiêu chí lọc) | Đồng bộ | - | 1a3, 1a4 |
| 1a.2.1.1 | :BrowseShowtimesController | :Showtime | // checkInSchedule | Đồng bộ | SD2-F2 | 1a4 |
| 1a.2.1.1 (trả về) | :Showtime | :BrowseShowtimesController | còn trong lịch chiếu hoặc đã xoá | Trả về | SD2-F2 | 1a4 |
| 1a.2.1.2 | :BrowseShowtimesController | :Showtime | // checkNotStarted | Đồng bộ | SD2-F2 | 1a4 |
| 1a.2.1.2 (trả về) | :Showtime | :BrowseShowtimesController | chưa tới giờ bắt đầu hoặc đã tới giờ bắt đầu | Trả về | SD2-F2 | 1a4 |
| 1a.2.1.3 | :BrowseShowtimesController | :Showtime | // checkMatchesCriteria (tiêu chí lọc) | Đồng bộ | SD2-F2 | 1a4 |
| 1a.2.1.3.1 | :Showtime | :Auditorium | // checkMatchesRoomCriteria (loại phòng, tỉnh thành phố) | Đồng bộ | SD2-F2 | 1a4 |
| 1a.2.1.3.1.1 | :Auditorium | :Cinema | // checkInProvince (tỉnh thành phố) | Đồng bộ | SD2-F2 | 1a4 |
| 1a.2.1.3 (trả về) | :Showtime | :BrowseShowtimesController | khớp hoặc không khớp tiêu chí lọc | Trả về | SD2-F2 | 1a4 |
| 1a.2.1.4 | :BrowseShowtimesController | :Showtime | // provideShowtimeForBrowsing | Đồng bộ | SD2-F3 | 1a5 |
| 1a.2.1.4.1 | :Showtime | :Movie | // provideMovieTitle | Đồng bộ | SD2-F3 | 1a5 |
| 1a.2.1.4.2 | :Showtime | :Auditorium | // provideAuditoriumForBrowsing | Đồng bộ | SD2-F3 | 1a5 |
| 1a.2.1.4.2.1 | :Auditorium | :Cinema | // provideCinemaInfo | Đồng bộ | SD2-F3 | 1a5 |
| 1a.2.1.4 (trả về) | :Showtime | :BrowseShowtimesController | phim, định dạng, cụm rạp, phòng chiếu, ngày giờ bắt đầu, loại phòng, tỉnh thành phố, thời điểm mở bán | Trả về | SD2-F3 | 1a5 |
| 1a.2.1.5 | :BrowseShowtimesController | :BrowseShowtimesForm | // notifyNoShowtimes | Đồng bộ | SD2-F4 | 1a4a |
| 1a.2.1.6 | :BrowseShowtimesController | :BrowseShowtimesForm | // showShowtimes (các suất chiếu đã xác định) | Đồng bộ | - | 1a5 |

## 6. Quy tắc tương tác giữa các lớp phân tích

| Vi phạm | Message hoặc link | Cách sửa đã áp dụng |
|---|---|---|
| Không có | - | - |

Ghi chú kiểm tra: Showtime --> Movie, Showtime --> Auditorium, Auditorium --> Cinema là entity gọi entity có quan hệ cấu trúc (R-UC004-05, 06, 07). Control gọi trực tiếp Movie, Showtime, Cinema.

## 7. Communication diagram

File diagrams/P07-communication-UC-004.drawio, 1 trang CM1 gồm luồng chính và mọi luồng thay thế (MUC_CHI_TIET là DAY_DU), giữ STT của SD1, SD2.

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| CM1-O-A | Actor | :Khách | - | - | Tác nhân (ACT-01) |
| CM1-O-F | Object | :BrowseShowtimesForm | «boundary» | - | AC-B-BrowseShowtimesForm |
| CM1-O-C | Object | :BrowseShowtimesController | «control» | - | AC-C-BrowseShowtimesController |
| CM1-O-M | Object | :Movie | «entity» | - | AC-E-Movie |
| CM1-O-S | Object | :Showtime | «entity» | - | AC-E-Showtime |
| CM1-O-U | Object | :Auditorium | «entity» | - | AC-E-Auditorium |
| CM1-O-N | Object | :Cinema | «entity» | - | AC-E-Cinema |

b) Bảng Edge

| ID | Nguồn | Đích | Loại (Link) | Nhãn | Chiều message |
|---|---|---|---|---|---|
| CM1-L1 | CM1-O-A | CM1-O-F | Link | 1: // requestShowtimesByMovie (-->)<br>2: // selectMovieAndCriteria (phim, tiêu chí lọc tuỳ ý) (-->)<br>1a: // requestShowtimesByCinema (-->)<br>1a.2: // selectCinemaAndCriteria (cụm rạp, tiêu chí lọc tuỳ ý) (-->) | Nguồn-->Đích: 1, 2, 1a, 1a.2 |
| CM1-L2 | CM1-O-F | CM1-O-C | Link | 1.1: // startBrowsingByMovie (-->)<br>1.1.3: // showMovieList (tên các phim đang chiếu, sắp chiếu) (<--)<br>2.1: // findShowtimesByMovie (phim, tiêu chí lọc) (-->)<br>2.1.5: // notifyNoShowtimes (<--) [không có suất chiếu nào của phim đã chọn thoả tiêu chí lọc (4a)]<br>2.1.6: // showShowtimes (các suất chiếu đã xác định) (<--)<br>1a.1: // startBrowsingByCinema (-->)<br>1a.1.2: // showCinemaList (tên các cụm rạp) (<--)<br>1a.2.1: // findShowtimesByCinema (cụm rạp, tiêu chí lọc) (-->)<br>1a.2.1.5: // notifyNoShowtimes (<--) [không có suất chiếu nào tại cụm rạp đã chọn thoả tiêu chí lọc (1a4a)]<br>1a.2.1.6: // showShowtimes (các suất chiếu đã xác định) (<--) | Nguồn-->Đích: 1.1, 2.1, 1a.1, 1a.2.1; Đích-->Nguồn: 1.1.3, 2.1.5, 2.1.6, 1a.1.2, 1a.2.1.5, 1a.2.1.6 |
| CM1-L3 | CM1-O-C | CM1-O-M | Link | 1.1.1: // determineRunStatus (-->) [lặp: mỗi phim trong danh sách phim của chuỗi]<br>1.1.2: // provideMovieTitle (-->) [phim đang chiếu hoặc sắp chiếu] | Nguồn-->Đích: 1.1.1, 1.1.2 |
| CM1-L4 | CM1-O-C | CM1-O-S | Link | 2.1.1: // checkInSchedule (-->) [lặp: mỗi suất chiếu của phim đã chọn]<br>2.1.2: // checkNotStarted (-->) [lặp: mỗi suất chiếu của phim đã chọn]<br>2.1.3: // checkMatchesCriteria (tiêu chí lọc) (-->) [lặp: mỗi suất chiếu của phim đã chọn]<br>2.1.4: // provideShowtimeForBrowsing (-->) [còn trong lịch chiếu, chưa tới giờ bắt đầu và khớp tiêu chí lọc]<br>1a.2.1.1: // checkInSchedule (-->) [lặp: mỗi suất chiếu tại cụm rạp đã chọn]<br>1a.2.1.2: // checkNotStarted (-->) [lặp: mỗi suất chiếu tại cụm rạp đã chọn]<br>1a.2.1.3: // checkMatchesCriteria (tiêu chí lọc) (-->) [lặp: mỗi suất chiếu tại cụm rạp đã chọn]<br>1a.2.1.4: // provideShowtimeForBrowsing (-->) [còn trong lịch chiếu, chưa tới giờ bắt đầu và khớp tiêu chí lọc] | Nguồn-->Đích: 2.1.1, 2.1.2, 2.1.3, 2.1.4, 1a.2.1.1, 1a.2.1.2, 1a.2.1.3, 1a.2.1.4 |
| CM1-L5 | CM1-O-S | CM1-O-U | Link | 2.1.3.1: // checkMatchesRoomCriteria (loại phòng, tỉnh thành phố) (-->) [lặp: mỗi suất chiếu của phim đã chọn]<br>2.1.4.2: // provideAuditoriumForBrowsing (-->) [còn trong lịch chiếu, chưa tới giờ bắt đầu và khớp tiêu chí lọc]<br>1a.2.1.3.1: // checkMatchesRoomCriteria (loại phòng, tỉnh thành phố) (-->) [lặp: mỗi suất chiếu tại cụm rạp đã chọn]<br>1a.2.1.4.2: // provideAuditoriumForBrowsing (-->) [còn trong lịch chiếu, chưa tới giờ bắt đầu và khớp tiêu chí lọc] | Nguồn-->Đích: 2.1.3.1, 2.1.4.2, 1a.2.1.3.1, 1a.2.1.4.2 |
| CM1-L6 | CM1-O-U | CM1-O-N | Link | 2.1.3.1.1: // checkInProvince (tỉnh thành phố) (-->) [lặp: mỗi suất chiếu của phim đã chọn]<br>2.1.4.2.1: // provideCinemaInfo (-->) [còn trong lịch chiếu, chưa tới giờ bắt đầu và khớp tiêu chí lọc]<br>1a.2.1.3.1.1: // checkInProvince (tỉnh thành phố) (-->) [lặp: mỗi suất chiếu tại cụm rạp đã chọn]<br>1a.2.1.4.2.1: // provideCinemaInfo (-->) [còn trong lịch chiếu, chưa tới giờ bắt đầu và khớp tiêu chí lọc] | Nguồn-->Đích: 2.1.3.1.1, 2.1.4.2.1, 1a.2.1.3.1.1, 1a.2.1.4.2.1 |
| CM1-L7 | CM1-O-S | CM1-O-M | Link | 2.1.4.1: // provideMovieTitle (-->) [còn trong lịch chiếu, chưa tới giờ bắt đầu và khớp tiêu chí lọc]<br>1a.2.1.4.1: // provideMovieTitle (-->) [còn trong lịch chiếu, chưa tới giờ bắt đầu và khớp tiêu chí lọc] | Nguồn-->Đích: 2.1.4.1, 1a.2.1.4.1 |
| CM1-L8 | CM1-O-C | CM1-O-N | Link | 1a.1.1: // provideCinemaInfo (-->) [lặp: mỗi cụm rạp trong danh sách cụm rạp của chuỗi] | Nguồn-->Đích: 1a.1.1 |

## 8. VOPC

File diagrams/P07-class-UC-004.drawio. ID cell của lớp là mã AC; ngăn thuộc tính và ngăn trách nhiệm có ID "<mã AC>-ATTR" và "<mã AC>-RESP".

a) Bảng Node (lớp)

| ID (mã AC) | Loại (Class) | Nhãn (tên lớp) | Stereotype | Thuộc về | Ngăn thuộc tính | Ngăn trách nhiệm |
|---|---|---|---|---|---|---|
| AC-B-BrowseShowtimesForm | Class | BrowseShowtimesForm | «boundary» | - | browseCriteria (Phim hoặc cụm rạp đã chọn, tỉnh thành phố, ngày, loại phòng, định dạng phim) | // requestShowtimesByMovie<br>// showMovieList<br>// selectMovieAndCriteria<br>// showShowtimes<br>// notifyNoShowtimes<br>// requestShowtimesByCinema<br>// showCinemaList<br>// selectCinemaAndCriteria |
| AC-C-BrowseShowtimesController | Class | BrowseShowtimesController | «control» | - | - | // startBrowsingByMovie<br>// findShowtimesByMovie<br>// startBrowsingByCinema<br>// findShowtimesByCinema |
| AC-E-Movie | Class | Movie | «entity» | - | title (Văn bản) | // determineRunStatus<br>// provideMovieTitle |
| AC-E-Showtime | Class | Showtime | «entity» | - | startTime (Ngày giờ)<br>saleOpenTime (Ngày giờ)<br>movieFormat (Văn bản)<br>movie (Phim)<br>auditorium (Phòng chiếu)<br>status (Trạng thái: Trong lịch chiếu, Đã xoá) | // checkInSchedule<br>// checkNotStarted<br>// checkMatchesCriteria<br>// provideShowtimeForBrowsing |
| AC-E-Auditorium | Class | Auditorium | «entity» | - | name (Văn bản)<br>auditoriumType (Văn bản)<br>cinema (Cụm rạp) | // checkMatchesRoomCriteria<br>// provideAuditoriumForBrowsing |
| AC-E-Cinema | Class | Cinema | «entity» | - | name (Văn bản) (mới ở UC này)<br>province (Tỉnh, thành phố) (mới ở UC này) | // provideCinemaInfo<br>// checkInProvince |

b) Bảng quan hệ

| ID | Lớp A | Lớp B | Loại | Multiplicity | Vai trò | Nguồn |
|---|---|---|---|---|---|---|
| R-UC004-01 | AC-B-BrowseShowtimesForm | AC-C-BrowseShowtimesController | Association | - | - | tạm thời; link F7: CM1-L2 |
| R-UC004-02 | AC-C-BrowseShowtimesController | AC-E-Movie | Association | - | - | tạm thời; link F7: CM1-L3 |
| R-UC004-03 | AC-C-BrowseShowtimesController | AC-E-Showtime | Association | - | - | tạm thời; link F7: CM1-L4 |
| R-UC004-04 | AC-C-BrowseShowtimesController | AC-E-Cinema | Association | - | - | tạm thời; link F7: CM1-L8 |
| R-UC004-05 | AC-E-Showtime | AC-E-Movie | Association | A 0..* - B 1 | - | Mỗi suất chiếu trình chiếu một phim (GL-47); cùng R-UC014-09; link F7: CM1-L7 |
| R-UC004-06 | AC-E-Auditorium | AC-E-Showtime | Association | A 1 - B 0..* | - | Suất chiếu diễn ra trong đúng một phòng chiếu (GL-47); cùng R-UC014-07; link F7: CM1-L5 |
| R-UC004-07 | AC-E-Cinema | AC-E-Auditorium | Aggregation | A 1 - B 1..* | - | Cụm rạp gồm nhiều phòng chiếu (GL-03, GL-40); cùng R-38 của P08; link F7: CM1-L6 |

Link actor - boundary không vào VOPC. Không có link tự nối. Quan hệ Showtime - Movie, Auditorium - Showtime, Cinema - Auditorium dùng lại quan hệ đã có ở UC-014 và P08.

## 9. Ma trận truy vết

| Bước UC | Message (STT) | Lớp tham gia (AC) |
|---|---|---|
| 1 | 1 | Khách, AC-B-BrowseShowtimesForm |
| 2 | 1.1, 1.1.1, 1.1.1 (trả về), 1.1.2, 1.1.2 (trả về), 1.1.3 | AC-B-BrowseShowtimesForm, AC-C-BrowseShowtimesController, AC-E-Movie |
| 3 | 2, 2.1 | Khách, AC-B-BrowseShowtimesForm, AC-C-BrowseShowtimesController |
| 4 | 2.1, 2.1.1, 2.1.1 (trả về), 2.1.2, 2.1.2 (trả về), 2.1.3, 2.1.3.1, 2.1.3.1.1, 2.1.3 (trả về) | AC-B-BrowseShowtimesForm, AC-C-BrowseShowtimesController, AC-E-Showtime, AC-E-Auditorium, AC-E-Cinema |
| 5 | 2.1.4, 2.1.4.1, 2.1.4.2, 2.1.4.2.1, 2.1.4 (trả về), 2.1.6 | AC-C-BrowseShowtimesController, AC-E-Showtime, AC-E-Movie, AC-E-Auditorium, AC-E-Cinema, AC-B-BrowseShowtimesForm |
| 4a | 2.1.5 | AC-C-BrowseShowtimesController, AC-B-BrowseShowtimesForm |
| 1a | 1a | Khách, AC-B-BrowseShowtimesForm |
| 1a1 | 1a | Khách, AC-B-BrowseShowtimesForm |
| 1a2 | 1a.1, 1a.1.1, 1a.1.1 (trả về), 1a.1.2 | AC-B-BrowseShowtimesForm, AC-C-BrowseShowtimesController, AC-E-Cinema |
| 1a3 | 1a.2, 1a.2.1 | Khách, AC-B-BrowseShowtimesForm, AC-C-BrowseShowtimesController |
| 1a4 | 1a.2.1, 1a.2.1.1, 1a.2.1.1 (trả về), 1a.2.1.2, 1a.2.1.2 (trả về), 1a.2.1.3, 1a.2.1.3.1, 1a.2.1.3.1.1, 1a.2.1.3 (trả về) | AC-B-BrowseShowtimesForm, AC-C-BrowseShowtimesController, AC-E-Showtime, AC-E-Auditorium, AC-E-Cinema |
| 1a4a | 1a.2.1.5 | AC-C-BrowseShowtimesController, AC-B-BrowseShowtimesForm |
| 1a5 | 1a.2.1.4, 1a.2.1.4.1, 1a.2.1.4.2, 1a.2.1.4.2.1, 1a.2.1.4 (trả về), 1a.2.1.6 | AC-C-BrowseShowtimesController, AC-E-Showtime, AC-E-Movie, AC-E-Auditorium, AC-E-Cinema, AC-B-BrowseShowtimesForm |

## 10. File .drawio

Ba file nằm trong diagrams/: P07-sequence-UC-004.drawio (2 trang), P07-communication-UC-004.drawio (1 trang), P07-class-UC-004.drawio (1 trang). XML không nén, ID cell trùng ID trong bảng mô hình.

## Câu hỏi mở

Không có

## Giả định

Không áp dụng (CHE_DO_GIA_DINH là NGHIEM_NGAT).

## Đề xuất sửa artifact trước

Không có

## Vấn đề còn mở

- Việc chọn tập suất chiếu của phim đã chọn hoặc của cụm rạp đã chọn theo khoá coi là có sẵn (A6 a); control lặp trên tập đó để hỏi từng suất chiếu. Cinema không có trách nhiệm liệt kê suất chiếu cho use case này.
- Điều kiện "chưa tới giờ bắt đầu" dùng lại AC-E-Showtime // checkNotStarted của UC-014 (cùng định nghĩa giờ bắt đầu sau thời điểm kiểm tra); điều kiện "phim đang chiếu hoặc sắp chiếu" dùng lại AC-E-Movie // determineRunStatus của UC-003 (sổ trách nhiệm bảng 2).
- Cinema thêm thuộc tính province (tỉnh, thành phố) theo Q-178 của P04 và Q-204 của UC-011 trong sổ đồng bộ; UC-011 là chủ sở hữu và có thể đổi tên thuộc tính khi chạy P07; P08 hợp nhất.
- Control có 4 trách nhiệm, trong khoảng 2-10. Showtime có 4 trách nhiệm hành vi, Auditorium 2, Cinema 2, Movie 2; không entity nào thiếu trách nhiệm.
- Số lớp là 6, trong khoảng 4-12.
- Không có câu hỏi mở mới; Q-176 đến Q-180 đã được trả lời ở P04.

