# P07 - Phân tích use case UC-003 Tra cứu phim - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P07 |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | 00-Conventions.md; 00-Concurrency.md; project-profile.md; P01-actors.md 1.2; P02-usecases.md 1.9; P03-usecase-model.md 1.2; P05-glossary.md 1.2; P06-supplementary-spec.md 1.4; P04-uc-specs/_BR-register.md (đầu lô); P04-uc-specs/UC-003-browse-movies.md 1.1; sổ AC lập từ F3.4 của P07-uc-analysis/UC-005, UC-006, UC-008, UC-009, UC-013, UC-014 (đầu lô); P08-analysis-model.md 1.5 (mã AC-E-Cinema, AC-E-Seat đã cấp); _sync-log.md (Đầu vào cho lần chạy lại P07-P13, dòng UC-015, UC-016); dải mã Q được cấp 235 đến 244, không cấp ASM |
| Phạm vi | UC-003 |
| Mã Q, ASM cuối đã cấp | Q-175 (cấp ở P04, đã trả lời); không cấp Q mới ở use case này; không có ASM (NGHIEM_NGAT) |

## 1. Bối cảnh use case

| Thuộc tính | Giá trị |
|---|---|
| Mã và tên UC | UC-003 Tra cứu phim (Browse Movies) |
| Tác nhân chính | ACT-01 Khách (Người) |
| Tác nhân phụ | Không có |
| Include (UC) | Không có |
| Được include bởi (UC) | Không có |
| Extend (UC, điểm mở rộng, điều kiện) | Không có |
| Được extend bởi (UC, điểm mở rộng, điều kiện) | Không có |
| Use case liên quan không qua include, extend | UC-010 Quản lý phim: tạo và sửa dữ liệu phim mà use case này chỉ đọc (REQ-53, REQ-95). UC-004 Tra cứu lịch chiếu: tự bắt đầu bằng việc chọn phim hoặc cụm rạp, không nối từ thông tin phim (P04 Mục 8); dùng chung điều kiện phân nhóm phim (BR-76) |
| Tác nhân thời gian | Không có. P02 không có use case do tác nhân thời gian kích hoạt trên đối tượng mà UC-003 đọc; P04 Mục 8 xác nhận không có bước hẹn hoặc huỷ mốc (F4.2 mục 17). Không có message hẹn mốc |
| File P07 đã có được dùng làm sổ đăng ký AC | UC-014-schedule-showtimes-analysis.md. Tái dùng AC-E-Movie (UC-014 đã cấp mã, chủ sở hữu UC-010). Các lớp còn lại của UC-005, UC-006, UC-008, UC-009, UC-013, UC-014 không tham gia UC-003 |
| Đồng thời | Use case chỉ đọc nên không có thao tác không chia cắt và không có đơn vị loại trừ (P04 Mục 8: Thao tác nguyên tử Không có; 00-Concurrency.md M3 mục 1). Thay đổi do use case khác ghi nhận trong lúc đọc chỉ hiện ở lần xem sau |

## 2. Đặc tả bổ sung

| Bước UC | Thực hiện bởi | Mô tả trong đặc tả | Mô tả bổ sung (hệ thống làm gì bên trong) | Nguồn (BR, GL, REQ) |
|---|---|---|---|---|
| 1 | Khách | Yêu cầu xem danh sách phim. | Không đổi | REQ-05, REQ-06 |
| 2 | Hệ thống | Xác định các phim đang chiếu và các phim sắp chiếu theo ngày hiện tại, ngày khởi chiếu và ngày kết thúc chiếu của từng phim (BR-76). | Control đi qua từng phim trong danh sách phim của chuỗi. Mỗi phim so ngày hiện tại với ngày khởi chiếu và ngày kết thúc chiếu của chính nó để biết là đang chiếu, sắp chiếu hay đã qua ngày kết thúc chiếu (không thuộc nhóm nào, không đưa vào danh sách); ngày kết thúc chiếu vẫn thuộc khoảng chiếu. | BR-76, GL-38, GL-39, REQ-96 |
| 3 | Hệ thống | Hiển thị danh sách phim đang chiếu và danh sách phim sắp chiếu (xem Dữ liệu ra 1). | Mỗi phim thuộc một trong hai nhóm cung cấp tên, thể loại, thời lượng, độ tuổi được xem và, với phim sắp chiếu, ngày khởi chiếu. Control gom theo nhóm rồi chuyển cho boundary hiển thị; mô tả và trailer không có trong danh sách (Q-175). | Dữ liệu ra 1, Q-175, REQ-07, REQ-95 |
| 4 | Khách | Chọn một phim trong danh sách. | Không đổi | REQ-06 |
| 5 | Hệ thống | Hiển thị thông tin của phim đã chọn (xem Dữ liệu ra 2). | Phim đã chọn cung cấp tên, thể loại, thời lượng, độ tuổi được xem, mô tả và trailer; control chuyển cho boundary hiển thị. Không ghi dữ liệu nào. | Dữ liệu ra 2, REQ-07, GL-37 |
| 2a | Hệ thống | Thông báo hiện chưa có phim đang chiếu hoặc sắp chiếu. | Không phim nào thuộc hai nhóm thì control báo boundary hiển thị thông báo; kết thúc thành công, dữ liệu không đổi. | BR-76, REQ-05 |

## 3. Tìm lớp phân tích

### 3.1 Bảng boundary

| Tác nhân (ACT) | Loại tác nhân | Boundary | Loại boundary | Mới hoặc tái dùng (AC, UC nguồn) | Lý do |
|---|---|---|---|---|---|
| ACT-01 Khách | Người | BrowseMoviesForm | Giao diện người dùng | Mới (AC-B-BrowseMoviesForm) | Khách yêu cầu xem danh sách, chọn một phim và nhận danh sách phim, thông tin phim hoặc thông báo không có phim. Một boundary cho cả hai lần hiển thị vì cùng một tác nhân trong cùng use case, không tách theo màn hình. |

Số boundary là 1, bằng số tác nhân tham gia (không có tác nhân phụ, không có tác nhân thời gian).

### 3.2 Bảng lọc danh từ

| STT | Danh từ hoặc cụm danh từ | Vị trí (bước UC, mục dữ liệu, BR) | Kết luận | Lý do |
|---|---|---|---|---|
| 1 | khách | 1, 4; ACT-01 | Loại - là tác nhân hoặc ngoài phạm vi | Tác nhân chính; không đăng nhập (REQ-05) nên hệ thống không cần hồ sơ khách trong hành vi này (GL-18). |
| 2 | phim, danh sách phim, danh sách phim của chuỗi | 2, 3, 4, 5; Mục 8 | Entity AC-E-Movie | Hệ thống lưu; có hành vi phân nhóm theo BR-76 và cung cấp thông tin hiển thị (GL-37). Danh sách phim là kết quả duyệt các Movie, không là entity riêng (cấu trúc cài đặt) và do UC-010 quản lý. |
| 3 | danh sách | 1, 3 | Loại - cấu trúc cài đặt | Cách gom các phim để hiển thị, không có định danh và vòng đời riêng. |
| 4 | phim đang chiếu, phim sắp chiếu, nhóm phim | 2, 3, 2a; BR-76; Dữ liệu ra 1 dòng 1 | Loại - giá trị suy ra từ Movie | GL-38, GL-39: tính từ ngày hiện tại và hai ngày của phim khi cần, không lưu. |
| 5 | ngày hiện tại | 2; BR-76 | Loại - tham số của quy tắc BR-76 | Mốc so sánh của quy tắc phân nhóm. |
| 6 | ngày khởi chiếu, ngày kết thúc chiếu, khoảng chiếu | 2; BR-76; Dữ liệu ra 1 dòng 6 | Loại - thuộc tính của Movie | REQ-95; thuộc tính releaseDate, endOfRunDate đã có ở UC-014. |
| 7 | tên phim, thể loại, thời lượng, độ tuổi được xem, mô tả, trailer | Dữ liệu ra 1, 2 | Loại - thuộc tính của Movie | REQ-07; thuộc tính title, duration đã có ở UC-014; genre, ageRating, description, trailer là thuộc tính mới ở UC này. |
| 8 | thông tin phim | 5; Dữ liệu ra 2 | Loại - dữ liệu trao đổi qua boundary BrowseMoviesForm | Tập các thuộc tính của Movie, hiển thị không lưu. |
| 9 | thông báo chưa có phim | 2a | Loại - dữ liệu trao đổi qua boundary BrowseMoviesForm | Nội dung thông báo, không lưu. |
| 10 | yêu cầu xem danh sách, việc chọn phim | 1, 4 | Loại - thao tác hoặc sự kiện | Hành động của khách tại boundary. |
| 11 | suất chiếu, lịch chiếu | Mục 8 | Loại - không tham gia hành vi của use case này (khái niệm của UC-004, UC-014) | P04 Mục 8 nêu use case không nối sang lịch chiếu; không đọc hay ghi suất chiếu. |
| 12 | chuỗi | Mục 8 | Loại - là tác nhân hoặc ngoài phạm vi | Tên riêng của tổ chức (P05 mục 3). |
| 13 | hệ thống, thông tin, dữ liệu | Nhiều bước | Loại - mơ hồ | Không là khái niệm nghiệp vụ cụ thể. |

### 3.3 Bảng control

| Control | Use case điều phối | Mới hoặc tái dùng | Lý do (hoặc lý do không có control) |
|---|---|---|---|
| BrowseMoviesController | UC-003 | Mới (AC-C-BrowseMoviesController) | Một control cho use case: nhận yêu cầu từ boundary, duyệt từng phim để phân nhóm và chọn thông tin hiển thị, nhận yêu cầu xem một phim. Quy tắc phân nhóm nằm ở Movie. Có 2 trách nhiệm. |

### 3.4 Bảng lớp phân tích

| AC | Stereotype | Tên | Trách nhiệm | Thuộc tính chính | Bước UC nguồn | Loại boundary | Mới hoặc tái dùng | GL |
|---|---|---|---|---|---|---|---|---|
| AC-B-BrowseMoviesForm | boundary | BrowseMoviesForm | // requestMovieList: khách yêu cầu xem danh sách phim<br>// showMovieList: hiển thị các phim đang chiếu và các phim sắp chiếu kèm tên, thể loại, thời lượng, độ tuổi được xem và ngày khởi chiếu của phim sắp chiếu<br>// notifyNoMovies: thông báo hiện chưa có phim đang chiếu hoặc sắp chiếu<br>// selectMovie: khách chọn một phim trong danh sách<br>// showMovieDetails: hiển thị thông tin của phim đã chọn | selectedMovie (Phim khách đã chọn) | 1, 3, 4, 5, 2a | Giao diện người dùng | Mới | GL-18 |
| AC-C-BrowseMoviesController | control | BrowseMoviesController | // startBrowsingMovies: điều phối bước 2, 3 và 2a: duyệt từng phim, hỏi nhóm của phim, lấy thông tin tóm tắt của phim đang chiếu hoặc sắp chiếu, báo boundary hiển thị danh sách hoặc thông báo không có phim<br>// viewMovieDetails: điều phối bước 5: lấy thông tin chi tiết của phim đã chọn và báo boundary hiển thị | - | 2, 3, 5, 2a | - | Mới | - |
| AC-E-Movie | entity | Movie | // determineRunStatus: phân loại phim theo ngày hiện tại: đang chiếu, sắp chiếu hoặc không thuộc nhóm nào, theo ngày khởi chiếu và ngày kết thúc chiếu của phim (BR-76)<br>// provideMovieSummary: cung cấp tên, thể loại, thời lượng, độ tuổi được xem và, với phim sắp chiếu, ngày khởi chiếu để hiển thị trong danh sách<br>// provideMovieDetails: cung cấp tên, thể loại, thời lượng, độ tuổi được xem, mô tả, trailer để hiển thị | title (Văn bản)<br>duration (Số phút)<br>releaseDate (Ngày)<br>endOfRunDate (Ngày)<br>genre (Văn bản) (mới ở UC này)<br>ageRating (Văn bản) (mới ở UC này)<br>description (Văn bản) (mới ở UC này)<br>trailer (Trailer xem được qua hệ thống) (mới ở UC này) | 2, 3, 5 | - | Tái dùng từ UC-014, bổ sung trách nhiệm; chủ sở hữu UC-010 | GL-37, GL-38, GL-39 |

Tổng cộng 3 lớp: 1 boundary, 1 control, 1 entity. Dưới ngưỡng 4 lớp vì use case chỉ đọc một khái niệm là phim: không có entity nào khác tham gia hành vi (P04 Mục 8, bảng lọc danh từ F3.2 không còn ứng viên entity). Entity AC-E-Movie có hành vi riêng (phân nhóm theo BR-76) nên không thiếu trách nhiệm.

## 4. Phân bổ hành vi

| Bước UC | Trách nhiệm | Lớp nhận (AC) | Nguyên tắc | Lý do khi có lựa chọn khác |
|---|---|---|---|---|
| 1, 4 | // requestMovieList, // selectMovie | AC-B-BrowseMoviesForm | Giao tiếp tác nhân | - |
| 2, 3, 2a | // startBrowsingMovies | AC-C-BrowseMoviesController | Controller | Boundary chỉ chuyển yêu cầu, không phân nhóm. |
| 2 | // determineRunStatus | AC-E-Movie | Information Expert | Ngày khởi chiếu và ngày kết thúc chiếu là dữ liệu của phim nên phim tự phân nhóm. Phương án khác: control so ngày cho từng phim, bị loại vì control sẽ giữ quy tắc BR-76 thuộc dữ liệu của entity. Cùng một điều kiện được UC-004 bước 2 dùng lại (sổ bảng 2). Không có đối tượng toàn thể (danh sách phim của chuỗi không là entity) nên control lặp và gửi message tới từng phim (A6). |
| 3 | // provideMovieSummary | AC-E-Movie | Information Expert | Thông tin hiển thị là dữ liệu của phim; ngày khởi chiếu chỉ cung cấp cho phim sắp chiếu theo Dữ liệu ra 1. |
| 3 | // showMovieList | AC-B-BrowseMoviesForm | Giao tiếp tác nhân | - |
| 2a | // notifyNoMovies | AC-B-BrowseMoviesForm | Giao tiếp tác nhân | Control biết không có phim nào thuộc hai nhóm sau khi duyệt xong; không cần message riêng để kiểm tra (tìm và đếm theo kết quả là việc có sẵn, A6). |
| 4, 5 | // viewMovieDetails | AC-C-BrowseMoviesController | Controller | - |
| 5 | // provideMovieDetails | AC-E-Movie | Information Expert | Đặt tên khác // provideMovieSummary vì nội dung cung cấp khác (Dữ liệu ra 2 có mô tả, trailer). |
| 5 | // showMovieDetails | AC-B-BrowseMoviesForm | Giao tiếp tác nhân | - |

Thao tác nguyên tử: không có (P04 Mục 8), nên không có dòng thao tác nguyên tử ở F4 (00-Concurrency.md M3 mục 1).

## 5. Sequence diagram phân tích

File diagrams/P07-sequence-UC-003.drawio, 1 trang. Số message không kể trả về: SD1 10. Fragment ở mức ngoài cùng: loop, break (2).

### SD1 - Luồng chính và luồng 2a

a) Luồng thể hiện: Khách yêu cầu xem danh sách phim, hệ thống phân nhóm phim đang chiếu, sắp chiếu rồi hiển thị; luồng 2a kết thúc khi không có phim nào; khách chọn một phim và hệ thống hiển thị thông tin phim.

Luồng 2a kết thúc use case (thành công) nên vẽ bằng break ở mức ngoài cùng; điều kiện của break được control biết sau khi duyệt hết danh sách phim, không cần message riêng. Bước 4 và bước 5 tiếp nối ngay sau bước 3 nên cùng trang.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1-L-A | Actor | :Khách | - | - | Tác nhân (ACT-01) |
| SD1-L-F | Lifeline | :BrowseMoviesForm | «boundary» | - | AC-B-BrowseMoviesForm |
| SD1-L-C | Lifeline | :BrowseMoviesController | «control» | - | AC-C-BrowseMoviesController |
| SD1-L-M | Lifeline | :Movie | «entity» | - | AC-E-Movie |
| SD1-F1 | Fragment | loop [mỗi phim trong danh sách phim của chuỗi] | - | - | mức ngoài cùng |
| SD1-F2 | Fragment | opt [phim đang chiếu hoặc sắp chiếu] | - | SD1-F1 | lồng trong SD1-F1 |
| SD1-F3 | Fragment | break [không có phim đang chiếu hoặc sắp chiếu (2a)] | - | - | mức ngoài cùng |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1 | :Khách | :BrowseMoviesForm | // requestMovieList | Đồng bộ | - | 1 |
| 1.1 | :BrowseMoviesForm | :BrowseMoviesController | // startBrowsingMovies | Đồng bộ | - | 2 |
| 1.1.1 | :BrowseMoviesController | :Movie | // determineRunStatus | Đồng bộ | SD1-F1 | 2 |
| 1.1.1 (trả về) | :Movie | :BrowseMoviesController | đang chiếu, sắp chiếu hoặc không thuộc nhóm nào | Trả về | SD1-F1 | 2 |
| 1.1.2 | :BrowseMoviesController | :Movie | // provideMovieSummary | Đồng bộ | SD1-F2 | 3 |
| 1.1.2 (trả về) | :Movie | :BrowseMoviesController | tên, thể loại, thời lượng, độ tuổi được xem, ngày khởi chiếu (phim sắp chiếu) | Trả về | SD1-F2 | 3 |
| 1.1.3 | :BrowseMoviesController | :BrowseMoviesForm | // notifyNoMovies | Đồng bộ | SD1-F3 | 2a |
| 1.1.4 | :BrowseMoviesController | :BrowseMoviesForm | // showMovieList (các phim đang chiếu, các phim sắp chiếu) | Đồng bộ | - | 3 |
| 2 | :Khách | :BrowseMoviesForm | // selectMovie (phim đã chọn) | Đồng bộ | - | 4 |
| 2.1 | :BrowseMoviesForm | :BrowseMoviesController | // viewMovieDetails (phim đã chọn) | Đồng bộ | - | 4, 5 |
| 2.1.1 | :BrowseMoviesController | :Movie | // provideMovieDetails | Đồng bộ | - | 5 |
| 2.1.1 (trả về) | :Movie | :BrowseMoviesController | tên, thể loại, thời lượng, độ tuổi được xem, mô tả, trailer | Trả về | - | 5 |
| 2.1.2 | :BrowseMoviesController | :BrowseMoviesForm | // showMovieDetails (thông tin phim) | Đồng bộ | - | 5 |

## 6. Quy tắc tương tác giữa các lớp phân tích

| Vi phạm | Message hoặc link | Cách sửa đã áp dụng |
|---|---|---|
| Không có | - | - |

Ghi chú kiểm tra: mọi message của control tới Movie và tới BrowseMoviesForm; không có message giữa hai actor; Movie không gọi lớp nào.

## 7. Communication diagram

File diagrams/P07-communication-UC-003.drawio, 1 trang CM1 gồm luồng chính và mọi luồng thay thế (MUC_CHI_TIET là DAY_DU), giữ STT của SD1.

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| CM1-O-A | Actor | :Khách | - | - | Tác nhân (ACT-01) |
| CM1-O-F | Object | :BrowseMoviesForm | «boundary» | - | AC-B-BrowseMoviesForm |
| CM1-O-C | Object | :BrowseMoviesController | «control» | - | AC-C-BrowseMoviesController |
| CM1-O-M | Object | :Movie | «entity» | - | AC-E-Movie |

b) Bảng Edge

| ID | Nguồn | Đích | Loại (Link) | Nhãn | Chiều message |
|---|---|---|---|---|---|
| CM1-L1 | CM1-O-A | CM1-O-F | Link | 1: // requestMovieList (-->)<br>2: // selectMovie (phim đã chọn) (-->) | Nguồn-->Đích: 1, 2 |
| CM1-L2 | CM1-O-F | CM1-O-C | Link | 1.1: // startBrowsingMovies (-->)<br>1.1.3: // notifyNoMovies (<--) [không có phim đang chiếu hoặc sắp chiếu (2a)]<br>1.1.4: // showMovieList (các phim đang chiếu, các phim sắp chiếu) (<--)<br>2.1: // viewMovieDetails (phim đã chọn) (-->)<br>2.1.2: // showMovieDetails (thông tin phim) (<--) | Nguồn-->Đích: 1.1, 2.1; Đích-->Nguồn: 1.1.3, 1.1.4, 2.1.2 |
| CM1-L3 | CM1-O-C | CM1-O-M | Link | 1.1.1: // determineRunStatus (-->) [lặp: mỗi phim trong danh sách phim của chuỗi]<br>1.1.2: // provideMovieSummary (-->) [phim đang chiếu hoặc sắp chiếu]<br>2.1.1: // provideMovieDetails (-->) | Nguồn-->Đích: 1.1.1, 1.1.2, 2.1.1 |

## 8. VOPC

File diagrams/P07-class-UC-003.drawio. ID cell của lớp là mã AC; ngăn thuộc tính và ngăn trách nhiệm có ID "<mã AC>-ATTR" và "<mã AC>-RESP".

a) Bảng Node (lớp)

| ID (mã AC) | Loại (Class) | Nhãn (tên lớp) | Stereotype | Thuộc về | Ngăn thuộc tính | Ngăn trách nhiệm |
|---|---|---|---|---|---|---|
| AC-B-BrowseMoviesForm | Class | BrowseMoviesForm | «boundary» | - | selectedMovie (Phim khách đã chọn) | // requestMovieList<br>// showMovieList<br>// notifyNoMovies<br>// selectMovie<br>// showMovieDetails |
| AC-C-BrowseMoviesController | Class | BrowseMoviesController | «control» | - | - | // startBrowsingMovies<br>// viewMovieDetails |
| AC-E-Movie | Class | Movie | «entity» | - | title (Văn bản)<br>duration (Số phút)<br>releaseDate (Ngày)<br>endOfRunDate (Ngày)<br>genre (Văn bản) (mới ở UC này)<br>ageRating (Văn bản) (mới ở UC này)<br>description (Văn bản) (mới ở UC này)<br>trailer (Trailer xem được qua hệ thống) (mới ở UC này) | // determineRunStatus<br>// provideMovieSummary<br>// provideMovieDetails |

b) Bảng quan hệ

| ID | Lớp A | Lớp B | Loại | Multiplicity | Vai trò | Nguồn |
|---|---|---|---|---|---|---|
| R-UC003-01 | AC-B-BrowseMoviesForm | AC-C-BrowseMoviesController | Association | - | - | tạm thời; link F7: CM1-L2 |
| R-UC003-02 | AC-C-BrowseMoviesController | AC-E-Movie | Association | - | - | tạm thời; link F7: CM1-L3 |

Link actor - boundary không vào VOPC. Không có link tự nối.

## 9. Ma trận truy vết

| Bước UC | Message (STT) | Lớp tham gia (AC) |
|---|---|---|
| 1 | 1 | Khách, AC-B-BrowseMoviesForm |
| 2 | 1.1, 1.1.1, 1.1.1 (trả về) | AC-B-BrowseMoviesForm, AC-C-BrowseMoviesController, AC-E-Movie |
| 3 | 1.1.2, 1.1.2 (trả về), 1.1.4 | AC-C-BrowseMoviesController, AC-E-Movie, AC-B-BrowseMoviesForm |
| 4 | 2, 2.1 | Khách, AC-B-BrowseMoviesForm, AC-C-BrowseMoviesController |
| 5 | 2.1, 2.1.1, 2.1.1 (trả về), 2.1.2 | AC-B-BrowseMoviesForm, AC-C-BrowseMoviesController, AC-E-Movie |
| 2a | 1.1.3 | AC-C-BrowseMoviesController, AC-B-BrowseMoviesForm |

## 10. File .drawio

Ba file nằm trong diagrams/: P07-sequence-UC-003.drawio (1 trang), P07-communication-UC-003.drawio (1 trang), P07-class-UC-003.drawio (1 trang). XML không nén, ID cell trùng ID trong bảng mô hình.

## Câu hỏi mở

Không có

## Giả định

Không áp dụng (CHE_DO_GIA_DINH là NGHIEM_NGAT).

## Đề xuất sửa artifact trước

Không có

## Vấn đề còn mở

- Phim đã qua ngày kết thúc chiếu không thuộc nhóm nào nên không xuất hiện trong danh sách (suy ra từ BR-76, P04 Mục 8); control duyệt cả các phim này rồi bỏ.
- Điều kiện "phim đang chiếu hoặc sắp chiếu" định nghĩa ở AC-E-Movie // determineRunStatus và được UC-004 bước 2 dùng lại (sổ trách nhiệm bảng 2).
- Use case chỉ có 3 lớp (dưới ngưỡng 4) vì chỉ đọc dữ liệu phim; đã kiểm tra bảng lọc danh từ không bỏ sót entity.
- Control có 2 trách nhiệm, trong khoảng 2-10. Movie có 3 trách nhiệm hành vi, không thiếu trách nhiệm.
- Thuộc tính mới của Movie (genre, ageRating, description, trailer) theo P04 Dữ liệu ra 1, 2 (Q-175); UC-010 là chủ sở hữu và có thể đổi tên thuộc tính khi chạy P07; P08 hợp nhất.
- Q-175 đã được trả lời ở P04; không có câu hỏi mới. Các tên thuộc tính và tên trách nhiệm là lựa chọn mô hình, không là câu hỏi (C1 mục 8).

