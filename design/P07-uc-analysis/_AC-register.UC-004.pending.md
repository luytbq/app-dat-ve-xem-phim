# Sổ trách nhiệm P07 (phần mới của UC-004) - Hệ thống đặt vé xem phim CineBook

Bảng 1: dòng mới hoặc dòng được bổ sung trách nhiệm, thuộc tính, UC dùng.

| AC | Stereotype | Tên | Trách nhiệm | Thuộc tính | UC dùng |
|---|---|---|---|---|---|
| AC-B-BrowseShowtimesForm | boundary | BrowseShowtimesForm | // requestShowtimesByMovie: khách yêu cầu xem lịch chiếu theo phim<br>// showMovieList: hiển thị danh sách tên phim đang chiếu, sắp chiếu để chọn<br>// selectMovieAndCriteria: khách chọn một phim kèm các tiêu chí lọc tuỳ ý<br>// showShowtimes: hiển thị lịch chiếu gồm phim, định dạng, cụm rạp, phòng chiếu, ngày giờ bắt đầu, loại phòng, tỉnh thành phố, thời điểm mở bán của từng suất chiếu<br>// notifyNoShowtimes: thông báo không có suất chiếu phù hợp<br>// requestShowtimesByCinema: khách yêu cầu xem lịch chiếu theo cụm rạp<br>// showCinemaList: hiển thị danh sách tên cụm rạp để chọn<br>// selectCinemaAndCriteria: khách chọn một cụm rạp kèm các tiêu chí lọc tuỳ ý | browseCriteria (Phim hoặc cụm rạp đã chọn, tỉnh thành phố, ngày, loại phòng, định dạng phim) | UC-004 |
| AC-C-BrowseShowtimesController | control | BrowseShowtimesController | // startBrowsingByMovie: điều phối bước 2: duyệt từng phim, lấy tên phim đang chiếu hoặc sắp chiếu, báo boundary hiển thị danh sách phim<br>// findShowtimesByMovie: điều phối bước 4, 5, 4a: duyệt từng suất chiếu của phim đã chọn, hỏi điều kiện liệt kê, lấy thông tin hiển thị, báo boundary hiển thị lịch chiếu hoặc thông báo<br>// startBrowsingByCinema: điều phối bước 1a2: duyệt từng cụm rạp, lấy tên, báo boundary hiển thị danh sách cụm rạp<br>// findShowtimesByCinema: điều phối bước 1a4, 1a5, 1a4a: như findShowtimesByMovie cho các suất chiếu tại cụm rạp đã chọn | - | UC-004 |
| AC-E-Movie | entity | Movie | // provideMovieTitle: cung cấp tên phim | - | UC-004 |
| AC-E-Showtime | entity | Showtime | // checkInSchedule: kiểm tra suất chiếu còn trong lịch chiếu, chưa bị xoá (BR-58)<br>// checkMatchesCriteria: kiểm tra suất chiếu khớp các tiêu chí lọc đã chọn: định dạng phim, ngày của giờ bắt đầu, và loại phòng, tỉnh thành phố (hỏi phòng chiếu); tiêu chí không chọn thì không giới hạn<br>// provideShowtimeForBrowsing: cung cấp phim (hỏi phim), định dạng, phòng chiếu và cụm rạp (hỏi phòng chiếu), ngày giờ bắt đầu, loại phòng, tỉnh thành phố, thời điểm mở bán để hiển thị trong lịch chiếu | - | UC-004 |
| AC-E-Auditorium | entity | Auditorium | // checkMatchesRoomCriteria: kiểm tra loại phòng của phòng chiếu khớp tiêu chí loại phòng và hỏi cụm rạp của phòng khớp tiêu chí tỉnh thành phố<br>// provideAuditoriumForBrowsing: cung cấp tên phòng chiếu, loại phòng và thông tin cụm rạp của phòng (hỏi cụm rạp) để hiển thị trong lịch chiếu | - | UC-004 |
| AC-E-Cinema | entity | Cinema | // provideCinemaInfo: cung cấp tên cụm rạp và tỉnh thành phố để hiển thị<br>// checkInProvince: kiểm tra cụm rạp thuộc tỉnh, thành phố đã chọn trong tiêu chí lọc (REQ-10) | name (Văn bản) (mới ở UC này)<br>province (Tỉnh, thành phố) (mới ở UC này) | UC-004 |

Bảng 2: điều kiện hoặc sự kiện từ hai use case trở lên cùng dựa vào.

| Điều kiện hoặc sự kiện | Lớp chịu trách nhiệm (AC) | Trách nhiệm | Định nghĩa | UC dùng |
|---|---|---|---|---|
| Phim đang chiếu hoặc sắp chiếu (phân nhóm theo ngày hiện tại, BR-76) | AC-E-Movie | // determineRunStatus | Đang chiếu: đã tới ngày khởi chiếu và chưa qua ngày kết thúc chiếu; sắp chiếu: chưa tới ngày khởi chiếu; đã qua ngày kết thúc chiếu: không thuộc nhóm nào | UC-003, UC-004 |
| Suất chiếu chưa tới giờ bắt đầu (BR-45, BR-57) | AC-E-Showtime | // checkNotStarted | Giờ bắt đầu sau thời điểm kiểm tra | UC-004, UC-014 |
