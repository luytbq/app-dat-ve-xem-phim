# Sổ trách nhiệm P07 (phần mới của UC-003) - Hệ thống đặt vé xem phim CineBook

Bảng 1: dòng mới hoặc dòng được bổ sung trách nhiệm, thuộc tính, UC dùng.

| AC | Stereotype | Tên | Trách nhiệm | Thuộc tính | UC dùng |
|---|---|---|---|---|---|
| AC-B-BrowseMoviesForm | boundary | BrowseMoviesForm | // requestMovieList: khách yêu cầu xem danh sách phim<br>// showMovieList: hiển thị các phim đang chiếu và các phim sắp chiếu kèm tên, thể loại, thời lượng, độ tuổi được xem và ngày khởi chiếu của phim sắp chiếu<br>// notifyNoMovies: thông báo hiện chưa có phim đang chiếu hoặc sắp chiếu<br>// selectMovie: khách chọn một phim trong danh sách<br>// showMovieDetails: hiển thị thông tin của phim đã chọn | selectedMovie (Phim khách đã chọn) | UC-003 |
| AC-C-BrowseMoviesController | control | BrowseMoviesController | // startBrowsingMovies: điều phối bước 2, 3 và 2a: duyệt từng phim, hỏi nhóm của phim, lấy thông tin tóm tắt của phim đang chiếu hoặc sắp chiếu, báo boundary hiển thị danh sách hoặc thông báo không có phim<br>// viewMovieDetails: điều phối bước 5: lấy thông tin chi tiết của phim đã chọn và báo boundary hiển thị | - | UC-003 |
| AC-E-Movie | entity | Movie | // determineRunStatus: phân loại phim theo ngày hiện tại: đang chiếu, sắp chiếu hoặc không thuộc nhóm nào, theo ngày khởi chiếu và ngày kết thúc chiếu của phim (BR-76)<br>// provideMovieSummary: cung cấp tên, thể loại, thời lượng, độ tuổi được xem và, với phim sắp chiếu, ngày khởi chiếu để hiển thị trong danh sách<br>// provideMovieDetails: cung cấp tên, thể loại, thời lượng, độ tuổi được xem, mô tả, trailer để hiển thị | genre (Văn bản) (mới ở UC này)<br>ageRating (Văn bản) (mới ở UC này)<br>description (Văn bản) (mới ở UC này)<br>trailer (Trailer xem được qua hệ thống) (mới ở UC này) | UC-003 |

Bảng 2: điều kiện hoặc sự kiện từ hai use case trở lên cùng dựa vào.

| Điều kiện hoặc sự kiện | Lớp chịu trách nhiệm (AC) | Trách nhiệm | Định nghĩa | UC dùng |
|---|---|---|---|---|
| Phim đang chiếu hoặc sắp chiếu (phân nhóm theo ngày hiện tại, BR-76) | AC-E-Movie | // determineRunStatus | Đang chiếu: đã tới ngày khởi chiếu và chưa qua ngày kết thúc chiếu; sắp chiếu: chưa tới ngày khởi chiếu; đã qua ngày kết thúc chiếu: không thuộc nhóm nào | UC-003, UC-004 |
