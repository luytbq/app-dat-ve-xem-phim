# P07 - Phân tích use case UC-012 Quản lý phòng chiếu - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P07 |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | 00-Conventions.md (C10); 00-Concurrency.md (M3); project-profile.md; P04-uc-specs/UC-012-manage-auditoriums.md 1.1; P01-actors.md 1.2; P02-usecases.md 1.9; P03-usecase-model.md 1.2; P05-glossary.md 1.2; P06-supplementary-spec.md 1.4; P04-uc-specs/_BR-register.md; P08-analysis-model.md 1.5 (F3, F4b: AC-E-Cinema, AC-E-Auditorium, AC-E-Seat, EX-13, EX-15, X-19, X-21, Q-109, Q-110); P07-uc-analysis/UC-005-book-tickets-analysis.md (đầu lô; sổ đăng ký AC: F1, F3.4, F8 b), Câu hỏi mở, Vấn đề còn mở); P07-uc-analysis/UC-010-manage-movies-analysis.md và UC-011-manage-cinemas-analysis.md (cùng phiên; Q-245 đến Q-248, AC-E-Cinema); P07-uc-analysis/UC-013-manage-price-list-analysis.md (AC-E-CinemaManager, AC-E-PriceList, mẫu định dạng); P07-uc-analysis/UC-014-schedule-showtimes-analysis.md (AC-E-Auditorium, AC-E-Showtime, AC-E-PriceList); _sync-log.md (Đầu vào cho lần chạy lại P07-P13, dòng UC-012); dải mã Q-245 đến Q-254 (đầu lô) |
| Phạm vi | UC-012 |
| Mã Q, ASM cuối đã cấp | Q-254 (Q-249 đến Q-254 cấp ở use case này, chờ chủ dự án chốt theo đề xuất; Q-245 đến Q-248 cấp ở UC-010, UC-011; dải được cấp Q-245 đến Q-254, đã dùng hết); không có ASM (NGHIEM_NGAT) |

## 1. Bối cảnh use case

| Thuộc tính | Giá trị |
|---|---|
| Mã và tên UC | UC-012 Quản lý phòng chiếu (Manage Auditoriums) |
| Tác nhân chính | ACT-04 Quản lý cụm rạp (Người) |
| Tác nhân phụ | Không có |
| Include (UC) | Không có |
| Được include bởi (UC) | Không có |
| Extend (UC, điểm mở rộng, điều kiện) | Không có |
| Được extend bởi (UC, điểm mở rộng, điều kiện) | Không có |
| Use case liên quan không qua include, extend | UC-014 lập, sửa suất chiếu của phòng (bước 8) và xoá suất chiếu (luồng 1b3): đối thủ của sửa phòng và xoá phòng (BR-136, BR-87, BR-73, BR-147); UC-005 chốt giá khi giữ ghế (bước 7): đối thủ của đổi loại phòng (BR-137); UC-013 bỏ mục giá (luồng 1a3): đối thủ của đổi loại phòng, loại ghế (BR-136, BR-73); UC-011 quản lý cụm rạp chứa phòng chiếu (chỉ đọc, cụm rạp không bị xoá); UC-017 sở hữu khái niệm quản lý cụm rạp và cụm rạp của họ; UC-015, UC-016 chỉ đọc sức chứa (chưa có P07, không cần loại trừ) |
| Tác nhân thời gian | Không có. Thời điểm mở bán là mốc của UC-005 và UC-014, UC-012 không tạo hay đổi mốc (P04 Mục 8), P02 không có use case do tác nhân thời gian kích hoạt trên dữ liệu phòng chiếu, nên không có message hẹn mốc (A2) |
| File P07 đã có được dùng làm sổ đăng ký AC | UC-005-book-tickets-analysis.md (sổ gốc, trạng thái đầu lô). UC-014-schedule-showtimes-analysis.md: dùng lại AC-E-Auditorium (UC-014 ghi "chủ sở hữu UC-012"), AC-E-Showtime, AC-E-PriceList, AC-E-CinemaManager; UC-013-manage-price-list-analysis.md: AC-E-PriceList, AC-E-CinemaManager. UC-011-manage-cinemas-analysis.md (cùng phiên): AC-E-Cinema. AC-E-Seat chưa có trong file P07 nào, mã và tên theo P08-analysis-model.md 1.5 (Tạm, chờ P07 của UC-012); UC-012 là chủ sở hữu. Phần mới của sổ ghi ở _AC-register.UC-012.pending.md (C10) |

## 2. Đặc tả bổ sung

| Bước UC | Thực hiện bởi | Mô tả trong đặc tả | Mô tả bổ sung (hệ thống làm gì bên trong) | Nguồn (BR, GL, REQ) |
|---|---|---|---|---|
| 1 | Quản lý cụm rạp | Yêu cầu thêm phòng chiếu mới cho cụm rạp của mình. | Không đổi | REQ-56 |
| 2 | Hệ thống | Hiển thị các phòng chiếu hiện có của cụm rạp mà quản lý cụm rạp thuộc về (BR-135; xem Dữ liệu ra 1). | Hồ sơ quản lý cụm rạp cho biết cụm rạp của quản lý; cụm rạp nắm các phòng chiếu của mình và nhận của mỗi phòng tên, loại phòng, các định dạng chiếu được, sức chứa (đếm ghế, ghế đôi tính một ghế) rồi chuyển cho boundary hiển thị. | BR-06, BR-135, GL-03, GL-40, GL-50, REQ-56, REQ-100 |
| 3 | Quản lý cụm rạp | Nhập tên phòng chiếu, chọn loại phòng và các định dạng phim chiếu được, nhập sơ đồ ghế rồi gửi (xem Dữ liệu vào 1, Dữ liệu vào 1a; BR-74). | Không đổi | BR-74, REQ-57, GL-46 |
| 4 | Hệ thống | Kiểm tra thông tin phòng chiếu và sơ đồ ghế hợp lệ theo điều kiện của Dữ liệu vào 1 (BR-144, BR-145). | Control tạo phòng chiếu dự kiến cùng các ghế từ sơ đồ ghế nhập. Mỗi ghế kiểm hàng không trống, số ghế là số, loại ghế là một trong ba loại; phòng kiểm tên không trống, loại phòng là một trong ba loại, một hoặc cả hai định dạng chiếu được, mỗi cặp hàng và số ghế tối đa một ghế, rồi đếm sức chứa (ghế đôi một ghế) trong khoảng 50 đến 400. Kiểm tên phòng chưa dùng (BR-145) nằm trong thao tác ghi ở bước 5. | BR-06, BR-144, BR-145, REQ-02, REQ-16, Q-245, Q-251 |
| 5 | Hệ thống | Kiểm tra, với phòng chiếu đã có ở luồng 1a, sơ đồ ghế chỉ thay đổi khi phòng không có suất chiếu đã tới thời điểm mở bán mà chưa kết thúc (BR-87) và việc đổi loại phòng hoặc loại ghế không làm suất chiếu chưa tới giờ bắt đầu của phòng thiếu giá (BR-73, BR-69), rồi lưu phòng chiếu cùng sơ đồ ghế vào cụm rạp của quản lý cụm rạp, tất cả là một thao tác không chia cắt với việc lưu suất chiếu của phòng, việc bỏ mục giá và việc chốt giá (BR-135, BR-136, BR-137), và với phòng chiếu đã chọn ở luồng 1a, phòng chưa bị yêu cầu khác sửa kể từ lúc hiển thị (BR-146); suất chiếu đã xoá không được tính khi kiểm BR-87 và BR-73 (Q-209). | Thêm: cụm rạp kiểm tên phòng chưa thuộc phòng khác rồi ghi phòng dự kiến vào cụm rạp. Sửa: phòng đã chọn kiểm mốc thay đổi chưa đổi, tên chưa thuộc phòng khác (hỏi cụm rạp), sơ đồ ghế chỉ đổi khi không có suất chiếu đã mở bán chưa kết thúc (hỏi suất chiếu, không kể suất đã xoá), suất chiếu chưa tới giờ bắt đầu còn đủ giá theo loại phòng, loại ghế sau khi lưu (suất chiếu hỏi bảng giá); đạt thì ghi thông tin và sơ đồ mới, đặt lại mốc và cho từng suất chiếu chưa mở bán dùng sơ đồ mới. Hai phần là một thao tác. | BR-06, BR-73, BR-84, BR-87, BR-118, BR-135 đến BR-137, BR-145, BR-146, Q-209, Q-210, Q-249 đến Q-251 |
| 6 | Hệ thống | Thông báo lưu phòng chiếu thành công và hiển thị phòng chiếu đã lưu cùng sức chứa (xem Dữ liệu ra 2; BR-06). | Control nhận từ phòng chiếu đã lưu tên, loại phòng, định dạng chiếu được, sức chứa (đếm ghế, ghế đôi một ghế) và số ghế theo từng loại ghế, chuyển cho boundary hiển thị cùng thông báo thành công. | BR-06, GL-50 |
| 1a | Quản lý cụm rạp | Quản lý cụm rạp chọn sửa một phòng chiếu đã có thay vì thêm phòng chiếu mới. | Không đổi | REQ-56, EV-14 |
| 1a1 | Hệ thống | Hiển thị các phòng chiếu của cụm rạp mà quản lý cụm rạp thuộc về (BR-135; xem Dữ liệu ra 1). | Như bước 2; boundary ghi lại mốc thay đổi của từng phòng chiếu lúc hiển thị để gửi kèm yêu cầu lưu ở bước 5. | BR-135, BR-146 |
| 1a2 | Quản lý cụm rạp | Chọn phòng chiếu cần sửa (xem Dữ liệu vào 2). | Phòng chọn phải thuộc cụm rạp của quản lý: phòng chiếu đối chiếu cụm rạp của mình với cụm rạp của quản lý (P04 chưa có luồng khi vi phạm, Q-252). Lựa chọn của quản lý chép nguyên. | BR-135, Q-252 |
| 1a3 | Hệ thống | Hiển thị thông tin hiện tại của phòng chiếu đã chọn, gồm sơ đồ ghế, để sửa (xem Dữ liệu ra 3). | Phòng chiếu cung cấp tên, loại phòng, định dạng chiếu được và cho từng ghế của phòng cung cấp hàng, số ghế, loại ghế; control chuyển cho boundary hiển thị. | GL-40, GL-46 |
| 1b | Quản lý cụm rạp | Quản lý cụm rạp chọn xoá một phòng chiếu thay vì thêm phòng chiếu mới (Q-208). | Không đổi | REQ-56, Q-208 |
| 1b1 | Hệ thống | Hiển thị các phòng chiếu của cụm rạp mà quản lý cụm rạp thuộc về (BR-135; xem Dữ liệu ra 1). | Như bước 2. | BR-135 |
| 1b2 | Quản lý cụm rạp | Chọn phòng chiếu cần xoá (xem Dữ liệu vào 2). | Phòng chọn phải thuộc cụm rạp của quản lý, kiểm như bước 1a2 (Q-252). Lựa chọn của quản lý chép nguyên. | BR-135, Q-252 |
| 1b3 | Hệ thống | Kiểm tra phòng chiếu chưa từng có suất chiếu, kể cả suất chiếu đã xoá (BR-147), rồi xoá phòng chiếu cùng các ghế của phòng, tất cả là một thao tác không chia cắt với việc lưu suất chiếu của phòng (BR-136). | Cụm rạp hỏi phòng chiếu đã chọn có từng suất chiếu trong lịch chiếu của phòng không (kể cả suất đã xoá, đếm trên tập suất chiếu của phòng); chưa từng thì cụm rạp bỏ phòng cùng các ghế của phòng khỏi cụm rạp. Kiểm và xoá cùng một thao tác. | BR-136, BR-147, BR-58, Q-208 |
| 1b3a | Hệ thống | Phòng chiếu đã từng có suất chiếu, kể cả suất chiếu đã xoá (BR-147). Từ chối xoá, không đổi phòng chiếu và thông báo quy tắc bị vi phạm. | Phòng chiếu báo đã từng có suất chiếu, cụm rạp không bỏ phòng; control chuyển quy tắc bị vi phạm cho boundary thông báo. | BR-147 |
| 1b4 | Hệ thống | Thông báo xoá phòng chiếu thành công. | Control chuyển kết quả xoá thành công cho boundary hiển thị. | BR-147 |
| 4a | Hệ thống | Từ chối lưu và thông báo điều kiện bị vi phạm của từng trường (thông tin phòng chiếu hoặc sơ đồ ghế không đạt điều kiện hợp lệ). | Phòng chiếu dự kiến báo điều kiện bị vi phạm của từng trường (kể cả ghế không hợp lệ hoặc vị trí ghế trùng), control chuyển cho boundary; phòng chiếu không đổi, quản lý nhập lại ở bước 3. | REQ-02, REQ-16, Dữ liệu vào 1, 1a |
| 4b | Hệ thống | Sức chứa của sơ đồ ghế ngoài khoảng 50 đến 400 ghế (BR-144), không thuộc 4a. Từ chối lưu và thông báo quy tắc bị vi phạm. | Phòng chiếu dự kiến đếm sức chứa (ghế đôi một ghế) và báo ngoài khoảng, control chuyển quy tắc bị vi phạm cho boundary. | BR-06, BR-144, Q-211 |
| 4d | Hệ thống | Tên phòng chiếu đã thuộc một phòng chiếu khác trong cùng cụm rạp (BR-145), không thuộc 4a, 4b. Từ chối lưu và thông báo quy tắc bị vi phạm. | Cụm rạp báo tên đã thuộc phòng khác của cụm rạp trong thao tác ghi, control chuyển quy tắc bị vi phạm cho boundary; quản lý nhập lại ở bước 3. | BR-145, Q-213, Q-251 |
| 5a | Hệ thống | Sơ đồ ghế bị thay đổi và phòng chiếu có suất chiếu (không kể suất chiếu đã xoá, Q-209) đã tới thời điểm mở bán mà chưa kết thúc, so tại thời điểm hệ thống kiểm tra (BR-87); kiểm trước 5b. Từ chối lưu, không đổi phòng chiếu và sơ đồ ghế, và thông báo quy tắc bị vi phạm. | Phòng chiếu so sơ đồ ghế mới với hiện tại; khác thì hỏi suất chiếu của phòng đã mở bán chưa kết thúc theo giờ kết thúc (BR-50); có thì không ghi gì và control chuyển quy tắc bị vi phạm cho boundary. | BR-50, BR-87, Q-209, Q-250 |
| 5b | Hệ thống | Việc đổi loại phòng hoặc thêm loại ghế vào phòng làm ít nhất một suất chiếu chưa tới giờ bắt đầu của phòng (không kể suất chiếu đã xoá, Q-209) thiếu giá theo BR-69 (BR-73), không thuộc 5a. Từ chối lưu và thông báo quy tắc bị vi phạm. | Suất chiếu chưa tới giờ bắt đầu của phòng hỏi bảng giá có giá cho mọi loại ghế sau khi lưu; thiếu giá thì không ghi gì và control chuyển quy tắc bị vi phạm cho boundary. | BR-69, BR-73, Q-209, Q-250 |
| 5c | Hệ thống | Chỉ khi theo luồng 1a: phòng chiếu đã bị yêu cầu khác sửa kể từ lúc hiển thị (BR-146). Từ chối lưu, không ghi đè thay đổi trước và thông báo quy tắc bị vi phạm. | Phòng chọn báo mốc thay đổi hiện tại khác mốc lúc hiển thị, không ghi gì; control chuyển lý do cho boundary thông báo, quản lý mở lại phòng từ bước 1a1. | BR-146, Q-214, Q-247, Q-254 |
| *a | Hệ thống | Tại bất kỳ bước nào trước bước 5 (trước bước 1b3 với luồng 1b), kể cả trong luồng 1a, quản lý cụm rạp huỷ yêu cầu. Huỷ yêu cầu, không thay đổi phòng chiếu. | Không có thời hạn; huỷ có thể xảy ra ở mọi bước trước bước 5 (trước 1b3 với luồng 1b). Control bỏ yêu cầu đang xử lý, phòng chiếu không bị chạm tới. | P04 Mục 3 luồng *a |

## 3. Tìm lớp phân tích

### 3.1 Bảng boundary

| Tác nhân (ACT) | Loại tác nhân | Boundary | Loại boundary | Mới hoặc tái dùng (AC, UC nguồn) | Lý do |
|---|---|---|---|---|---|
| ACT-04 Quản lý cụm rạp | Người | ManageAuditoriumsForm | Giao diện người dùng | Mới (AC-B-ManageAuditoriumsForm) | Quản lý cụm rạp xem các phòng chiếu của cụm, nhập thông tin phòng và sơ đồ ghế, chọn phòng cần sửa hoặc xoá, huỷ và nhận thông báo kết quả. Một boundary cho cặp tác nhân và use case, không tách theo màn hình hay theo luồng thêm, sửa, xoá |

### 3.2 Bảng lọc danh từ

| STT | Danh từ hoặc cụm danh từ | Vị trí (bước UC, mục dữ liệu, BR) | Kết luận | Lý do |
|---|---|---|---|---|
| 1 | Quản lý cụm rạp | Tác nhân chính, tiền điều kiện, BR-135 | Loại - là tác nhân hoặc ngoài phạm vi | Tác nhân ACT-04. Hồ sơ của quản lý được giữ lại ở dòng sau |
| 2 | Hồ sơ quản lý cụm rạp (cụm rạp mà quản lý thuộc về) | Bước 2, 1a1, 1b1, BR-135, tiền điều kiện | Entity (AC-E-CinemaManager) | Entity biểu diễn thông tin về tác nhân, không phải bản thân tác nhân. Cho biết cụm rạp để chỉ xem, thêm, sửa, xoá phòng của cụm mình; tái dùng từ UC-013, UC-014 (GL-42) |
| 3 | Hệ thống | Các bước hệ thống | Loại - mơ hồ | Chỉ là bên thực hiện bước |
| 4 | Cụm rạp | Bước 1, 2, 5, 1b3, BR-135, BR-145 | Entity (AC-E-Cinema) | Cụm rạp nắm các phòng chiếu của mình (GL-03), nơi kiểm tên phòng duy nhất và bỏ phòng; chủ sở hữu UC-011, tái dùng từ UC-011 (mã theo P08) |
| 5 | Phòng chiếu | Bước 1, 2, 3, 5, 1a1, 1b1, BR-135 | Entity (AC-E-Auditorium) | Có định danh, được tạo, sửa, xoá; tái dùng mã của UC-014, UC-012 là chủ sở hữu (GL-40) |
| 6 | Danh sách phòng chiếu, các phòng chiếu hiện có | Bước 2, 1a1, 1b1, Dữ liệu ra 1 | Loại - cấu trúc cài đặt | Kết quả liệt kê các phòng chiếu của cụm rạp; cụm rạp nắm tập phòng nên liệt kê giao cho Cinema |
| 7 | Tên phòng chiếu | Dữ liệu vào 1 trường 1, BR-145 | Loại - thuộc tính của Auditorium | name; duy nhất trong cụm rạp (BR-145) |
| 8 | Loại phòng | Bước 3, Dữ liệu vào 1 trường 2, BR-73, BR-137 | Loại - thuộc tính của Auditorium | auditoriumType; phòng thường, 4DX hoặc IMAX (GL-27); là một yếu tố của mục giá, không phải khái niệm riêng |
| 9 | Định dạng phim chiếu được | Bước 3, Dữ liệu vào 1 trường 3 | Loại - thuộc tính của Auditorium | supportedFormats; một hoặc cả hai giá trị 2D, 3D (GL-05) |
| 10 | Sơ đồ ghế | Bước 3, 5, Dữ liệu vào 1 trường 4, GL-46 | Loại - trùng hoặc đồng nghĩa với Seat | Sơ đồ ghế cố định của phòng là tập các ghế của phòng, không có định danh riêng (P02 CAND-38: thành phần của phòng chiếu); P05 GL-46 nêu hai ngữ cảnh, UC-012 dùng nghĩa bố cục cố định |
| 11 | Ghế | Dữ liệu vào 1a, BR-06, BR-74 | Entity (AC-E-Seat) | Có vị trí, loại ghế, được tạo và kiểm hợp lệ, xoá cùng phòng (GL-07); mã theo P08, chủ sở hữu UC-012, Q-253 |
| 12 | Hàng, số ghế, vị trí ghế | Dữ liệu vào 1a trường 1, 2 | Loại - thuộc tính của Seat | seatPosition; lối đi biểu diễn bằng khoảng trống giữa các số ghế, không có ghế vật lý không dùng (Q-137) |
| 13 | Loại ghế | Dữ liệu vào 1a trường 3, BR-73 | Loại - thuộc tính của Seat | seatType; ghế thường, ghế VIP, ghế đôi (GL-26) |
| 14 | Ghế đôi | Dữ liệu vào 1a trường 3, BR-06, BR-74 | Loại - tham số của quy tắc BR-06 | Giá trị của loại ghế; tính một ghế khi đếm sức chứa, bán như một ghế |
| 15 | Sức chứa | Bước 6, Dữ liệu vào 1 trường 4, BR-06, BR-144 | Loại - giá trị suy ra từ Seat | Đếm số ghế của sơ đồ ghế, ghế đôi một ghế (GL-50); không lưu |
| 16 | Số ghế theo loại ghế | Dữ liệu ra 2 | Loại - giá trị suy ra từ Seat | Đếm ghế theo loại khi hiển thị |
| 17 | 50 đến 400 ghế, 4 đến 12 phòng | BR-144, Mục 8, REQ-01, REQ-03 | Loại - tham số của quy tắc BR-144 | Ngưỡng của sức chứa; số phòng 4 đến 12 là số liệu quy mô, không là giới hạn (Q-212) |
| 18 | Suất chiếu | Bước 5, 1b3, BR-87, BR-73, BR-147 | Entity (AC-E-Showtime) | Tái dùng mã của UC-005, UC-013, UC-014; UC-012 hỏi suất chiếu tìm theo điều kiện và bảo suất chiếu chưa mở bán dùng sơ đồ mới (GL-47) |
| 19 | Thời điểm mở bán, giờ kết thúc, giờ bắt đầu | Bước 5, BR-87, BR-73, BR-50 | Loại - thuộc tính của Showtime | saleOpenTime, endTime, startTime (GL-53, GL-15, GL-14) |
| 20 | Suất chiếu đã xoá | Bước 5, 1b3, Q-209 | Loại - thuộc tính của Showtime | status; không tính khi kiểm BR-87, BR-73, nhưng tính khi kiểm phòng đã từng có suất chiếu (BR-147) |
| 21 | Bảng giá | Bước 5, BR-73, BR-69 | Entity (AC-E-PriceList) | Tái dùng; UC-012 hỏi bảng giá có đủ giá cho suất chiếu sau khi lưu (GL-01) |
| 22 | Mục giá, giá vé, khung giờ chiếu | BR-73, BR-69 | Loại - không tham gia hành vi của use case này (khái niệm của UC-013) | Bảng giá tự tra mục giá và xác định khung giờ; UC-012 chỉ hỏi bảng giá có đủ giá |
| 23 | Trạng thái ghế của suất chiếu | Hậu điều kiện, Mục 8, BR-118 | Loại - khái niệm do UC-014 tạo, use case này chỉ đổi qua entity Showtime | Suất chiếu nắm trạng thái ghế của mình (R-44) và tự cập nhật khi dùng sơ đồ mới (Q-249); P08 Q-109 ghi UC-014 tạo trạng thái ghế |
| 24 | Lần giữ ghế, ghế đang giữ | Mục 8, BR-87, BR-65 | Loại - không tham gia hành vi của use case này (khái niệm của UC-005) | BR-87 đã chặn sửa sơ đồ khi có lần giữ ghế đang chạy nên UC-012 không kiểm riêng |
| 25 | Vé đã bán, vé đã huỷ, tên phòng và loại phòng ghi trên vé | Hậu điều kiện, Mục 8, BR-140, BR-67, BR-118 | Loại - không tham gia hành vi của use case này (khái niệm của UC-005, UC-008) | Vé giữ giá trị lúc bán và không đổi; UC-012 không đọc vé |
| 26 | Sức chứa, tỉ lệ lấp đầy của suất chiếu đã kết thúc | BR-118, Mục 8 | Loại - không tham gia hành vi của use case này (khái niệm của UC-015, UC-016) | Báo cáo đọc dữ liệu lúc mở bán; UC-012 chỉ không đổi chúng |
| 27 | Mốc thay đổi lúc hiển thị | Bước 5, 5c, BR-146 | Loại - thuộc tính của Auditorium | lastChangedAt; so với mốc hiện tại để biết phòng đã bị sửa (Q-247) |
| 28 | Yêu cầu khác (sửa cùng phòng) | Bước 5, 5c, BR-146 | Loại - thao tác hoặc sự kiện | Một lần lưu phòng khác; hệ quả được so bằng mốc thay đổi |
| 29 | Thao tác không chia cắt | Bước 5, 1b3, BR-136, BR-137 | Loại - thao tác hoặc sự kiện | Cách thực hiện, giao cho Auditorium // checkEditAllowed, // applyChanges, Cinema // addAuditorium, // removeAuditorium |
| 30 | Thông báo, điều kiện vi phạm, quy tắc bị vi phạm | Bước 6, 1b4, 4a, 4b, 4d, 5a, 5b, 5c, 1b3a | Loại - dữ liệu trao đổi qua boundary ManageAuditoriumsForm | Không lưu |
| 31 | Phiên làm việc | Tiền điều kiện | Loại - là tác nhân hoặc ngoài phạm vi | Đăng nhập không mô hình hoá (project-profile mục 4) |
| 32 | Kết quả | Bước 6, 1b4 | Loại - mơ hồ | Chỉ là thông báo thành công hoặc thất bại, đã tính ở dòng thông báo |

### 3.3 Bảng control

| Control | Use case điều phối | Mới hoặc tái dùng | Lý do (hoặc lý do không có control) |
|---|---|---|---|
| ManageAuditoriumsController | UC-012 | Mới (AC-C-ManageAuditoriumsController) | Một control cho use case: nhận yêu cầu từ boundary, điều phối hiển thị phòng chiếu, tạo phòng chiếu dự kiến, kiểm hợp lệ, thêm, kiểm tra và lưu thay đổi (một thao tác không chia cắt), xoá phòng, báo kết quả. Quy tắc về sức chứa, tên phòng, sơ đồ ghế, suất chiếu và giá nằm ở entity. Có 8 trách nhiệm |

### 3.4 Bảng lớp phân tích

| AC | Stereotype | Tên | Trách nhiệm | Thuộc tính chính | Bước UC nguồn | Loại boundary | Mới hoặc tái dùng | GL |
|---|---|---|---|---|---|---|---|---|
| AC-B-ManageAuditoriumsForm | boundary | ManageAuditoriumsForm | // requestAuditoriumAddition: quản lý cụm rạp yêu cầu thêm phòng chiếu mới<br>// showAuditoriumList: hiển thị các phòng chiếu của cụm rạp, giữ mốc thay đổi của từng phòng lúc hiển thị<br>// enterAuditoriumInfo: quản lý cụm rạp nhập tên, chọn loại phòng và định dạng chiếu được, nhập sơ đồ ghế rồi gửi<br>// notifyRefusal: thông báo từ chối kèm điều kiện hoặc quy tắc bị vi phạm<br>// showSavedAuditorium: thông báo lưu phòng chiếu thành công và hiển thị phòng chiếu đã lưu cùng sức chứa<br>// requestAuditoriumEdit: quản lý cụm rạp chọn sửa một phòng chiếu đã có thay vì thêm phòng chiếu mới<br>// selectAuditoriumToEdit: quản lý cụm rạp chọn phòng chiếu cần sửa<br>// showAuditoriumForEdit: hiển thị thông tin hiện tại của phòng chiếu đã chọn, gồm từng ghế, để sửa<br>// requestAuditoriumRemoval: quản lý cụm rạp chọn xoá một phòng chiếu thay vì thêm phòng chiếu mới<br>// selectAuditoriumToRemove: quản lý cụm rạp chọn phòng chiếu cần xoá<br>// showRemovalSuccess: thông báo xoá phòng chiếu thành công<br>// cancelRequest: quản lý cụm rạp huỷ yêu cầu | displayedAuditoriumList (Danh sách phòng chiếu đang hiển thị, kèm mốc thay đổi của từng phòng chiếu lúc hiển thị)<br>enteredAuditoriumInfo (Tên, loại phòng, định dạng chiếu được và sơ đồ ghế đã nhập)<br>selectedAuditorium (Phòng chiếu đã chọn để sửa hoặc xoá) | 1, 2, 3, 6, 1a, 1a1, 1a2, 1a3, 1b, 1b1, 1b2, 1b3a, 1b4, 4a, 4b, 4d, 5a, 5b, 5c, *a | Giao diện người dùng | Mới | GL-42, GL-46 |
| AC-C-ManageAuditoriumsController | control | ManageAuditoriumsController | // startAuditoriumAddition: điều phối bước 1 và 2: xác định cụm rạp của quản lý, lấy các phòng chiếu của cụm rạp để hiển thị<br>// submitAuditorium: điều phối bước 3 đến 6: tạo phòng chiếu dự kiến, kiểm hợp lệ, rồi thêm phòng vào cụm rạp (luồng chính) hoặc kiểm và lưu thay đổi (luồng 1a), báo kết quả<br>// startAuditoriumEdit: điều phối bước 1a1: xác định cụm rạp của quản lý, lấy các phòng chiếu của cụm rạp để hiển thị<br>// selectAuditorium: điều phối bước 1a2 và 1a3: kiểm phòng chọn thuộc cụm rạp của quản lý, lấy thông tin hiện tại của phòng để hiển thị<br>// startAuditoriumRemoval: điều phối bước 1b1: xác định cụm rạp của quản lý, lấy các phòng chiếu của cụm rạp để hiển thị<br>// submitAuditoriumRemoval: điều phối bước 1b2 đến 1b4: kiểm phòng chọn thuộc cụm rạp của quản lý, xoá phòng khỏi cụm rạp, báo kết quả<br>// cancelRequest: điều phối luồng *a: huỷ yêu cầu<br>// discardRequest: bỏ yêu cầu đang xử lý, không đổi phòng chiếu (luồng *a) | - | 1, 2, 3, 4, 5, 6, 1a1, 1a2, 1a3, 1b1, 1b2, 1b3, 1b3a, 1b4, 4a, 4b, 4d, 5a, 5b, 5c, *a | - | Mới | - |
| AC-E-CinemaManager | entity | CinemaManager | // provideCinema: cung cấp cụm rạp mà quản lý cụm rạp thuộc về, để chỉ xem, thêm, sửa, xoá phòng chiếu của cụm mình (BR-135) | cinema (Cụm rạp của quản lý cụm rạp) | 2, 1a1, 1b1 | - | Tái dùng từ UC-013, UC-014 | GL-42 |
| AC-E-Cinema | entity | Cinema | // provideAuditoriums: cung cấp các phòng chiếu của cụm rạp để hiển thị, đi qua từng phòng chiếu (cùng tên với P08 của UC-014)<br>// checkAuditoriumNameAvailable: kiểm tra tên phòng chiếu chưa thuộc phòng khác của cụm rạp, không kể phòng đang sửa; kiểm tra trên tập phòng chiếu mà cụm rạp nắm (BR-145)<br>// addAuditorium: thao tác không chia cắt: kiểm tên phòng chiếu chưa thuộc phòng khác rồi ghi phòng chiếu dự kiến vào cụm rạp (BR-145, Q-251)<br>// removeAuditorium: thao tác không chia cắt: hỏi phòng chiếu đã chọn chưa từng có suất chiếu rồi bỏ phòng cùng các ghế khỏi cụm rạp (BR-147) | name (Văn bản) | 2, 5, 1a1, 1b1, 1b3 | - | Tái dùng từ UC-011, bổ sung trách nhiệm | GL-03, GL-40 |
| AC-E-Auditorium | entity | Auditorium | // provideAuditoriumInfo: cung cấp tên, loại phòng, định dạng chiếu được, sức chứa, số ghế theo từng loại ghế và mốc thay đổi để hiển thị (UC-012 bổ sung sức chứa, số ghế theo loại ghế, mốc thay đổi vào nội dung của UC-014)<br>// createAuditorium: khởi tạo phòng chiếu dự kiến từ thông tin đã nhập, tạo các ghế của sơ đồ ghế (Q-245)<br>// checkAuditoriumInfoValid: kiểm tra tên không trống, loại phòng là một trong ba loại, một hoặc cả hai định dạng chiếu được, mỗi cặp hàng và số ghế có tối đa một ghế, các ghế hợp lệ (hỏi từng ghế), và trả về điều kiện bị vi phạm của từng trường (BR-135 không thuộc, REQ-02, REQ-55)<br>// calculateCapacity: tính sức chứa bằng số ghế của sơ đồ ghế, ghế đôi tính một ghế (BR-06, GL-50); đếm trên tập ghế mà phòng nắm<br>// checkCapacityInRange: kiểm tra sức chứa nằm trong khoảng 50 đến 400 ghế (BR-144)<br>// checkBelongsToCinema: kiểm tra phòng chiếu thuộc cụm rạp của quản lý cụm rạp (BR-135); cùng ý nghĩa với trách nhiệm cùng tên của UC-014 (BR-46)<br>// provideAuditoriumDetail: cung cấp tên, loại phòng, định dạng chiếu được và từng ghế của phòng để hiển thị và sửa, đi qua từng ghế<br>// checkUnchangedSinceDisplayed: kiểm tra phòng chiếu chưa bị yêu cầu khác sửa kể từ lúc hiển thị bằng cách so mốc thay đổi hiện tại với mốc lúc hiển thị (BR-146, Q-247)<br>// checkEditAllowed: thao tác không chia cắt (phần kiểm tra): kiểm phòng chưa bị sửa, tên phòng chưa thuộc phòng khác, sơ đồ ghế chỉ đổi khi phòng không có suất chiếu đã mở bán chưa kết thúc, suất chiếu chưa tới giờ bắt đầu vẫn đủ giá (BR-87, BR-73, BR-145, BR-146)<br>// checkSeatMapChanged: kiểm tra sơ đồ ghế mới khác sơ đồ ghế hiện tại của phòng<br>// applyChanges: thao tác không chia cắt (phần ghi): ghi tên, loại phòng, định dạng chiếu được, sơ đồ ghế mới, đặt lại mốc thay đổi, rồi cho từng suất chiếu chưa mở bán dùng sơ đồ ghế mới (BR-118, BR-84)<br>// checkNeverScheduled: kiểm tra phòng chưa từng có suất chiếu trong lịch chiếu của phòng, kể cả suất chiếu đã xoá (BR-147); đếm trên tập suất chiếu mà phòng nắm | name (Văn bản)<br>auditoriumType (Văn bản)<br>supportedFormats (Văn bản)<br>seatTypes (Văn bản)<br>cinema (Cụm rạp)<br>lastChangedAt (Ngày giờ) (mới ở UC này) | 2, 4, 5, 6, 1a1, 1a2, 1a3, 1b1, 1b2, 1b3 | - | Tái dùng từ UC-014 (chủ sở hữu UC-012), bổ sung trách nhiệm | GL-40, GL-46, GL-50 |
| AC-E-Seat | entity | Seat | // createSeat: khởi tạo ghế của phòng chiếu dự kiến với hàng, số ghế, loại ghế<br>// checkSeatValid: kiểm tra hàng không trống, số ghế là số, loại ghế là một trong ba loại (REQ-16)<br>// provideSeatInfo: cung cấp hàng, số ghế và loại ghế để hiển thị (cùng tên với P08) | seatPosition (Mã hàng, số ghế) (mới ở UC này)<br>seatType (Văn bản: ghế thường, ghế VIP, ghế đôi) (mới ở UC này) | 4, 1a3 | - | Mới - chủ sở hữu UC-012 (mã và tên theo P08, trạng thái Tạm) | GL-07, GL-26 |
| AC-E-Showtime | entity | Showtime | // checkBlocksSeatMapEdit: kiểm tra suất chiếu đã tới thời điểm mở bán và chưa kết thúc theo giờ kết thúc (BR-50), không kể suất chiếu đã xoá, so với thời điểm hệ thống kiểm tra (BR-87, Q-209)<br>// checkStaysPriced: kiểm tra suất chiếu chưa tới giờ bắt đầu, còn trong lịch chiếu vẫn đủ giá sau khi phòng đổi loại phòng hoặc loại ghế, bằng cách hỏi bảng giá (BR-73, BR-69, Q-250)<br>// adoptSeatMap: dùng sơ đồ ghế mới cho suất chiếu chưa mở bán: tạo trạng thái ghế trống cho ghế mới, bỏ trạng thái ghế của ghế không còn; suất chiếu đã kết thúc hoặc đã xoá giữ sơ đồ lúc mở bán (BR-118, Q-249) | startTime (Ngày giờ)<br>saleOpenTime (Ngày giờ)<br>endTime (Ngày giờ)<br>movieFormat (Văn bản)<br>status (Trạng thái: Trong lịch chiếu, Đã xoá) | 5 | - | Tái dùng từ UC-005, UC-013, UC-014, bổ sung trách nhiệm | GL-47, GL-53, GL-15 |
| AC-E-PriceList | entity | PriceList | // checkCoversShowtime: kiểm tra bảng giá của cụm rạp có giá cho mọi loại ghế của phòng chiếu, ứng với khung giờ xác định từ giờ bắt đầu (BR-12), theo loại phòng và định dạng (BR-68, BR-69); UC-012 truyền loại phòng và loại ghế sau khi lưu (Q-250) | cinema (Cụm rạp) | 5 | - | Tái dùng từ UC-005, UC-013, UC-014 | GL-01, GL-33 |

Tổng cộng 8 lớp: 1 boundary, 1 control, 6 entity. Entity cốt lõi của chủ đề race condition: AC-E-Auditorium (loại trừ giữa hai yêu cầu cùng sửa một phòng: BR-146; giữa sửa phòng và UC-014 bước 8, UC-005 bước 7, UC-013 luồng 1a3: BR-136, BR-137, BR-87, BR-73; giữa xoá phòng và lập suất chiếu: BR-147), AC-E-Cinema (tên phòng duy nhất: BR-145), AC-E-Showtime, AC-E-PriceList. Phần mới của sổ trách nhiệm ghi ở _AC-register.UC-012.pending.md (C10), gồm 3 dòng của Bảng 2 (điều kiện dùng chung với UC-013, UC-014).

## 4. Phân bổ hành vi

| Bước UC | Trách nhiệm | Lớp nhận (AC) | Nguyên tắc | Lý do khi có lựa chọn khác |
|---|---|---|---|---|
| 1 | // requestAuditoriumAddition | AC-B-ManageAuditoriumsForm | Giao tiếp tác nhân | - |
| 1 | // startAuditoriumAddition | AC-C-ManageAuditoriumsController | Controller | - |
| 2 | // provideCinema | AC-E-CinemaManager | Information Expert | Cụm rạp của quản lý nằm ở hồ sơ quản lý; giao cho control thì control giữ dữ liệu nhân sự, cao coupling và mất cohesion |
| 2 | // provideAuditoriums | AC-E-Cinema | Information Expert | Cụm rạp là đối tượng toàn thể nắm các phòng chiếu (GL-03) nên liệt kê giao cho cụm rạp, nó gửi message tới từng phòng chiếu trong loop; control lặp thì phải biết cấu trúc của cụm rạp |
| 2 | // provideAuditoriumInfo | AC-E-Auditorium | Information Expert | Dữ liệu phòng chiếu và sức chứa (đếm ghế của phòng, BR-06) nằm ở phòng chiếu |
| 2 | // showAuditoriumList | AC-B-ManageAuditoriumsForm | Giao tiếp tác nhân | - |
| 3 | // enterAuditoriumInfo | AC-B-ManageAuditoriumsForm | Giao tiếp tác nhân | - |
| 3 | // submitAuditorium | AC-C-ManageAuditoriumsController | Controller | - |
| 4 | // createAuditorium | AC-E-Auditorium | Creator | Control có dữ liệu khởi tạo và cụm rạp chỉ ghi nhận phòng sau khi hợp lệ; tạo phòng chiếu dự kiến rồi để phòng tự kiểm (Q-245). Kiểm bằng control rồi mới tạo thì quy tắc thuộc dữ liệu của phòng nằm ở control |
| 4 | // createSeat | AC-E-Seat | Creator | Phòng chiếu chứa các ghế (composition, Q-253) và có dữ liệu khởi tạo từ sơ đồ ghế nhập nên tạo từng ghế |
| 4 | // checkSeatValid | AC-E-Seat | Information Expert | Hàng, số ghế, loại ghế là dữ liệu của chính ghế |
| 4 | // checkAuditoriumInfoValid | AC-E-Auditorium | Information Expert | Điều kiện hợp lệ là quy tắc về giá trị của chính các trường phòng chiếu và quan hệ giữa các ghế (vị trí không trùng); giao cho control là để quy tắc dữ liệu ở control. Kiểm từng ghế giao cho ghế (// checkSeatValid), kiểm trên cả tập giao cho phòng |
| 4 | // checkCapacityInRange | AC-E-Auditorium | Information Expert | Sức chứa là giá trị suy ra từ ghế của phòng; ngưỡng 50 đến 400 là quy tắc của phòng (BR-144) |
| 4 | // calculateCapacity | AC-E-Auditorium | Information Expert | Phòng chiếu nắm tập ghế nên đếm sức chứa là trách nhiệm của phòng, không gửi message tới từng ghế (A6 b) |
| 5 | // addAuditorium | AC-E-Cinema | Information Expert | Tên phòng duy nhất trong cụm rạp (BR-145) là điều kiện trên tập phòng chiếu mà cụm rạp nắm; kiểm tên và ghi phải là một thao tác (M1 quy tắc 1, Q-251). Giao cho control thì kiểm và ghi tách rời; giao cho phòng dự kiến thì phòng không biết các phòng khác |
| 5 | // checkAuditoriumNameAvailable | AC-E-Cinema | Information Expert | Cụm rạp nắm tập phòng chiếu nên kiểm tên không trùng là một trách nhiệm của cụm rạp, không gửi message tới từng phòng (A6 b); phòng chiếu đang sửa hỏi cụm rạp (R-UC012-05) thay vì tự so tên với phòng khác |
| 5 | // checkEditAllowed | AC-E-Auditorium | Information Expert | Dữ liệu ở phòng (mốc thay đổi, sơ đồ ghế, loại phòng), ở cụm rạp (tên), ở suất chiếu (thời gian) và ở bảng giá. Giao cho phòng điều phối phần kiểm của thao tác không chia cắt vì phòng là lớp chủ của EX-15 (P08); mỗi điều kiện vẫn do lớp nắm dữ liệu định nghĩa và trả lời. Giao cho control thì control tự duyệt dữ liệu của bốn lớp (god control) |
| 5 | // checkUnchangedSinceDisplayed | AC-E-Auditorium | Information Expert | Mốc thay đổi nằm ở phòng chiếu; điều kiện chưa bị sửa kể từ lúc hiển thị chỉ định nghĩa ở phòng |
| 5 | // checkSeatMapChanged | AC-E-Auditorium | Information Expert | Sơ đồ ghế hiện tại nằm ở phòng; so với sơ đồ mới là việc của phòng |
| 5 | // checkBlocksSeatMapEdit | AC-E-Showtime | Information Expert | Thời điểm mở bán, giờ kết thúc và trạng thái trong lịch chiếu nằm ở suất chiếu; phòng nắm tập suất chiếu nhưng cần dữ liệu riêng từng suất, nên suất chiếu tìm theo điều kiện trả lời có hoặc không (A6 a, Q-250), như UC-013 Q-98 |
| 5 | // checkStaysPriced | AC-E-Showtime | Information Expert | Giờ bắt đầu, định dạng và trạng thái trong lịch chiếu nằm ở suất chiếu; bảng giá giữ giá. Suất chiếu hỏi bảng giá bằng // checkCoversShowtime của UC-014 với giá trị phòng sau khi lưu, tránh để Auditorium duyệt dữ liệu của suất chiếu (Q-250) |
| 5 | // checkCoversShowtime | AC-E-PriceList | Information Expert | Bảng giá nắm mục giá (BR-62); điều kiện bảng giá đủ giá cho suất chiếu chỉ định nghĩa ở bảng giá (dùng chung với UC-014, F3.5 bảng 2) |
| 5 | // applyChanges | AC-E-Auditorium | Information Expert | Phòng chiếu nắm thông tin và sơ đồ ghế của mình nên tự ghi; phòng chứa lịch chiếu (R-42) nên bảo suất chiếu chưa mở bán dùng sơ đồ mới. Giao cho control thì control ghi dữ liệu của phòng |
| 5 | // adoptSeatMap | AC-E-Showtime | Information Expert | Showtime nắm các trạng thái ghế của suất chiếu (R-44) nên tự tạo và bỏ trạng thái ghế, UC-012 không vẽ message tới SeatStatus (Q-249) |
| 6 | // provideAuditoriumInfo | AC-E-Auditorium | Information Expert | Như bước 2 |
| 6 | // calculateCapacity | AC-E-Auditorium | Information Expert | Như bước 4 |
| 6 | // showSavedAuditorium | AC-B-ManageAuditoriumsForm | Giao tiếp tác nhân | - |
| 1a | // requestAuditoriumEdit | AC-B-ManageAuditoriumsForm | Giao tiếp tác nhân | - |
| 1a1 | // startAuditoriumEdit | AC-C-ManageAuditoriumsController | Controller | - |
| 1a1 | // provideCinema | AC-E-CinemaManager | Information Expert | Như bước 2 |
| 1a1 | // provideAuditoriums | AC-E-Cinema | Information Expert | Như bước 2 |
| 1a1 | // provideAuditoriumInfo | AC-E-Auditorium | Information Expert | Như bước 2 |
| 1a1 | // showAuditoriumList | AC-B-ManageAuditoriumsForm | Giao tiếp tác nhân | - |
| 1a2 | // selectAuditoriumToEdit | AC-B-ManageAuditoriumsForm | Giao tiếp tác nhân | - |
| 1a2 | // selectAuditorium | AC-C-ManageAuditoriumsController | Controller | - |
| 1a2 | // checkBelongsToCinema | AC-E-Auditorium | Information Expert | Phòng chiếu giữ cụm rạp của mình; quản lý chỉ cung cấp cụm rạp nên không để CinemaManager duyệt phòng chiếu (giảm coupling) |
| 1a3 | // provideAuditoriumDetail | AC-E-Auditorium | Information Expert | Dữ liệu phòng chiếu và các ghế của phòng nằm ở phòng; phòng là toàn thể của ghế nên liệt kê từng ghế giao cho phòng và nó gửi message tới từng ghế trong loop |
| 1a3 | // provideSeatInfo | AC-E-Seat | Information Expert | - |
| 1a3 | // showAuditoriumForEdit | AC-B-ManageAuditoriumsForm | Giao tiếp tác nhân | - |
| 1b | // requestAuditoriumRemoval | AC-B-ManageAuditoriumsForm | Giao tiếp tác nhân | - |
| 1b1 | // startAuditoriumRemoval | AC-C-ManageAuditoriumsController | Controller | - |
| 1b1 | // provideCinema | AC-E-CinemaManager | Information Expert | Như bước 2 |
| 1b1 | // provideAuditoriums | AC-E-Cinema | Information Expert | Như bước 2 |
| 1b1 | // provideAuditoriumInfo | AC-E-Auditorium | Information Expert | Như bước 2 |
| 1b1 | // showAuditoriumList | AC-B-ManageAuditoriumsForm | Giao tiếp tác nhân | - |
| 1b2 | // selectAuditoriumToRemove | AC-B-ManageAuditoriumsForm | Giao tiếp tác nhân | - |
| 1b2 | // submitAuditoriumRemoval | AC-C-ManageAuditoriumsController | Controller | - |
| 1b2 | // checkBelongsToCinema | AC-E-Auditorium | Information Expert | Như bước 1a2 |
| 1b3 | // removeAuditorium | AC-E-Cinema | Information Expert | Cụm rạp là toàn thể của phòng chiếu nên bỏ phòng khỏi cụm rạp là việc của cụm rạp; điều kiện chưa từng có suất chiếu nằm ở phòng (hỏi qua // checkNeverScheduled). Kiểm và bỏ phải là một thao tác (BR-147) |
| 1b3 | // checkNeverScheduled | AC-E-Auditorium | Information Expert | Phòng nắm tập suất chiếu của mình (R-42, kể cả suất chiếu đã xoá) nên kiểm trên cả tập là trách nhiệm của phòng, không gửi message tới từng suất chiếu (A6 b) |
| 1b3a | // notifyRefusal | AC-B-ManageAuditoriumsForm | Giao tiếp tác nhân | - |
| 1b4 | // showRemovalSuccess | AC-B-ManageAuditoriumsForm | Giao tiếp tác nhân | - |
| 4a | // notifyRefusal | AC-B-ManageAuditoriumsForm | Giao tiếp tác nhân | - |
| 4b | // notifyRefusal | AC-B-ManageAuditoriumsForm | Giao tiếp tác nhân | - |
| 4d | // notifyRefusal | AC-B-ManageAuditoriumsForm | Giao tiếp tác nhân | - |
| 5a | // notifyRefusal | AC-B-ManageAuditoriumsForm | Giao tiếp tác nhân | - |
| 5b | // notifyRefusal | AC-B-ManageAuditoriumsForm | Giao tiếp tác nhân | - |
| 5c | // notifyRefusal | AC-B-ManageAuditoriumsForm | Giao tiếp tác nhân | - |
| *a | // cancelRequest | AC-B-ManageAuditoriumsForm | Giao tiếp tác nhân / Controller | - |
| *a | // cancelRequest | AC-C-ManageAuditoriumsController | Giao tiếp tác nhân / Controller | - |
| *a | // discardRequest | AC-C-ManageAuditoriumsController | Controller | Control chỉ bỏ yêu cầu, không giữ dữ liệu nghiệp vụ nên không có lựa chọn khác |

Thao tác không chia cắt theo bảng "Thao tác nguyên tử" của P04 Mục 8 (00-Concurrency.md M3 mục 1):

| Thao tác (P04 Mục 8) | Bước | Lớp điều phối | Lớp tham gia | Điểm tuần tự (M3 mục 2) |
|---|---|---|---|---|
| Lưu phòng chiếu và sơ đồ ghế (sửa phòng đã có), P08 EX-15 | 5 | AC-C-ManageAuditoriumsController (SD2b: 2.1.6a; SD2c: 2.1.11a; hai lời gọi trong cùng một thao tác) | AC-E-Auditorium (lớp chủ), AC-E-Cinema (tên phòng), AC-E-Showtime (suất chiếu tìm theo điều kiện, từng suất chưa mở bán), AC-E-PriceList (bảng giá) | Đối tượng Auditorium của phòng, vì BR-87, BR-73, BR-146 và loại trừ với UC-014 bước 8, UC-005 bước 7, UC-013 luồng 1a3 (BR-136, BR-137) cùng tập là một phòng. Phạm vi khớp, trừ BR-145 (tên duy nhất theo cụm rạp) trải qua mọi phòng của cụm: ghi ở Vấn đề còn mở cho P08 |
| Thêm phòng chiếu | 5 | AC-C-ManageAuditoriumsController (SD1c: 2.1.6) | AC-E-Cinema (lớp chủ, nắm tập phòng), AC-E-Auditorium (phòng dự kiến) | Đối tượng Cinema của cụm rạp, khớp bất biến "tên phòng duy nhất trong cùng cụm rạp" (BR-145); UC-014 bước 2 chỉ đọc danh sách phòng, không cần loại trừ |
| Kiểm tra phòng chưa từng có suất chiếu rồi xoá phòng và các ghế | 1b3 | AC-C-ManageAuditoriumsController (SD3: 2b.1.2) | AC-E-Cinema (lớp chủ, bỏ phòng), AC-E-Auditorium (phòng chọn, kiểm chưa từng có suất chiếu) | Đối tượng Auditorium của phòng (loại trừ với UC-014 bước 8 lập suất chiếu của phòng: BR-136, BR-147; hai yêu cầu xoá hoặc xoá với sửa: BR-146) và Cinema (bỏ phòng khỏi tập phòng của cụm). P08 chưa có đơn vị loại trừ cho thao tác này |

Thứ tự đã chọn của các kiểm tra trong SD2b: mốc thay đổi (5c), tên phòng (4d), sơ đồ ghế (5a), giá (5b); thứ tự báo khi nhiều điều kiện cùng vi phạm ở Q-254. Mốc kết thúc của suất chiếu trong BR-87 là giờ kết thúc theo BR-50 (Showtime // checkBlocksSeatMapEdit dùng endTime), không phải lúc ghế được giải phóng.

## 5. Sequence diagram phân tích

File diagrams/P07-sequence-UC-012.drawio có 8 trang, đều dưới ngưỡng 30 message và 3 fragment ở mức ngoài cùng (không kể ref). Luồng chính tách theo đoạn bước thành SD1a (bước 1-2), SD1b (bước 3-4, dùng chung với luồng 1a), SD1c (bước 5-6); luồng 1a thành SD2a, SD2b, SD2c; luồng 1b ở SD3. Luồng 4a, 4b, 4d, 5c quay lại bước trước nên dùng alt; luồng 5a, 5b, 1b3a kết thúc use case nên dùng break ở mức ngoài cùng; luồng *a ở trang riêng SD4.

### a) SD1a - Luồng chính, bước 1-2

Luồng thêm phòng chiếu, đoạn bước 1-2. Cụm rạp của quản lý cụm rạp là đối tượng nắm các phòng chiếu của cụm (GL-03), nên liệt kê giao cho Cinema và Cinema gửi message tới từng phòng chiếu trong loop (A6).

b) Bảng Node

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1a-L-A4 | Actor | :Quản lý cụm rạp | - | - | Tác nhân (ACT-04) |
| SD1a-L-PF | Lifeline | :ManageAuditoriumsForm | «boundary» | - | AC-B-ManageAuditoriumsForm |
| SD1a-L-C | Lifeline | :ManageAuditoriumsController | «control» | - | AC-C-ManageAuditoriumsController |
| SD1a-L-CM | Lifeline | :CinemaManager | «entity» | - | AC-E-CinemaManager |
| SD1a-L-CI | Lifeline | :Cinema | «entity» | - | AC-E-Cinema; cụm rạp của quản lý cụm rạp |
| SD1a-L-AU | Lifeline | :Auditorium | «entity» | - | AC-E-Auditorium; mỗi phòng chiếu của cụm rạp khi liệt kê |
| SD1a-F1 | Fragment | loop [mỗi phòng chiếu của cụm rạp] | - | - | Bao các message của fragment |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1 | :Quản lý cụm rạp | :ManageAuditoriumsForm | // requestAuditoriumAddition | Đồng bộ | - | 1 |
| 1.1 | :ManageAuditoriumsForm | :ManageAuditoriumsController | // startAuditoriumAddition | Đồng bộ | - | 1 |
| 1.1.1 | :ManageAuditoriumsController | :CinemaManager | // provideCinema (BR-135) | Đồng bộ | - | 2 |
| 1.1.1 (trả về) | :CinemaManager | :ManageAuditoriumsController | cụm rạp của quản lý cụm rạp | Trả về | - | 2 |
| 1.1.2 | :ManageAuditoriumsController | :Cinema | // provideAuditoriums | Đồng bộ | - | 2 |
| 1.1.2.1 | :Cinema | :Auditorium | // provideAuditoriumInfo | Đồng bộ | SD1a-F1 | 2 |
| 1.1.2.1 (trả về) | :Auditorium | :Cinema | tên, loại phòng, định dạng chiếu được, sức chứa | Trả về | SD1a-F1 | 2 |
| 1.1.2 (trả về) | :Cinema | :ManageAuditoriumsController | danh sách phòng chiếu của cụm rạp | Trả về | - | 2 |
| 1.1.3 | :ManageAuditoriumsController | :ManageAuditoriumsForm | // showAuditoriumList (danh sách phòng chiếu) | Đồng bộ | - | 2 |

### a) SD1b - Bước 3-4, 4a, 4b (luồng chính và luồng 1a)

Đoạn bước 3-4 dùng chung cho luồng chính (sau SD1a) và luồng 1a (sau SD2a). Phòng chiếu mới chưa tồn tại nên control tạo phòng chiếu dự kiến cùng các ghế của sơ đồ ghế nhập (Q-245): Auditorium tạo từng Seat trong loop, mỗi Seat tự kiểm hợp lệ. Hai kiểm tra 2.1.2 và 2.1.3 cùng đi trước một alt ba toán hạng (4a, 4b, hợp lệ); 4b chỉ xét khi không thuộc 4a, ghi bằng note. Luồng 4a và 4b quay lại bước 3 nên dùng alt, không dùng break. Trang có 2 fragment.

b) Bảng Node

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1b-L-A4 | Actor | :Quản lý cụm rạp | - | - | Tác nhân (ACT-04) |
| SD1b-L-PF | Lifeline | :ManageAuditoriumsForm | «boundary» | - | AC-B-ManageAuditoriumsForm |
| SD1b-L-C | Lifeline | :ManageAuditoriumsController | «control» | - | AC-C-ManageAuditoriumsController |
| SD1b-L-AD | Lifeline | phòngMới:Auditorium | «entity» | - | AC-E-Auditorium; phòng chiếu dự kiến chưa vào cụm rạp (Q-245) |
| SD1b-L-SE | Lifeline | :Seat | «entity» | - | AC-E-Seat; mỗi ghế của sơ đồ ghế |
| SD1b-F1 | Fragment | loop [mỗi ghế của sơ đồ ghế đã nhập] | - | - | Bao các message của fragment |
| SD1b-F2 | Fragment | alt [thông tin phòng chiếu hoặc sơ đồ ghế không đạt điều kiện hợp lệ (4a)] | - | - | Bao các message của fragment |
| SD1b-F2-O2 | Fragment | [sức chứa ngoài khoảng 50 đến 400 ghế, không thuộc 4a (4b)] | - | SD1b-F2 | Toán hạng thứ 2; đường ngăn là edge SD1b-F2-O2-SEP nét đứt |
| SD1b-F2-O3 | Fragment | [thông tin phòng chiếu và sức chứa hợp lệ] | - | SD1b-F2 | Toán hạng thứ 3; đường ngăn là edge SD1b-F2-O3-SEP nét đứt |
| SD1b-N1 | Note | 2.1.3 chỉ xét khi thông tin hợp lệ (4b không thuộc 4a) | - | - | Chú thích |
| SD1b-N2 | Note | quay lại bước 3 | - | - | Chú thích |
| SD1b-N3 | Note | quay lại bước 3 | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 2 | :Quản lý cụm rạp | :ManageAuditoriumsForm | // enterAuditoriumInfo (tên phòng chiếu, loại phòng, định dạng chiếu được, sơ đồ ghế) | Đồng bộ | - | 3 |
| 2.1 | :ManageAuditoriumsForm | :ManageAuditoriumsController | // submitAuditorium (thông tin phòng chiếu, sơ đồ ghế; luồng 1a kèm mốc thay đổi lúc hiển thị) | Đồng bộ | - | 3 |
| 2.1.1 | :ManageAuditoriumsController | phòngMới:Auditorium | «create» // createAuditorium (thông tin phòng chiếu đã nhập) | Tạo | - | 4 |
| 2.1.1.1 | phòngMới:Auditorium | :Seat | «create» // createSeat (hàng, số ghế, loại ghế) | Tạo | SD1b-F1 | 4 |
| 2.1.1.1.1 | :Seat | :Seat | // checkSeatValid (hàng, số ghế, loại ghế) | Tự gọi | SD1b-F1 | 4 |
| 2.1.2 | :ManageAuditoriumsController | phòngMới:Auditorium | // checkAuditoriumInfoValid | Đồng bộ | - | 4 |
| 2.1.2 (trả về) | phòngMới:Auditorium | :ManageAuditoriumsController | thông tin hợp lệ hoặc điều kiện bị vi phạm của từng trường | Trả về | - | 4 |
| 2.1.3 | :ManageAuditoriumsController | phòngMới:Auditorium | // checkCapacityInRange (BR-144) | Đồng bộ | - | 4 |
| 2.1.3.1 | phòngMới:Auditorium | phòngMới:Auditorium | // calculateCapacity (ghế đôi tính một ghế, BR-06) | Tự gọi | - | 4 |
| 2.1.3 (trả về) | phòngMới:Auditorium | :ManageAuditoriumsController | sức chứa trong khoảng 50 đến 400 ghế hoặc không | Trả về | - | 4 |
| 2.1.4 | :ManageAuditoriumsController | :ManageAuditoriumsForm | // notifyRefusal (điều kiện bị vi phạm của từng trường) | Đồng bộ | SD1b-F2 | 4a |
| 2.1.5 | :ManageAuditoriumsController | :ManageAuditoriumsForm | // notifyRefusal (sức chứa ngoài khoảng 50 đến 400 ghế, BR-144) | Đồng bộ | SD1b-F2 | 4b |

### a) SD1c - Luồng chính, bước 5-6, 4d

Đoạn bước 5-6 của luồng thêm, bắt đầu bằng ref tới SD1b. Cinema kiểm tên phòng chưa thuộc phòng khác của cụm rạp rồi ghi phòng dự kiến trong cùng một thao tác // addAuditorium (Q-251); luồng 4d quay lại bước 3 nên dùng alt và nằm sau lời gọi.

b) Bảng Node

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1c-L-PF | Lifeline | :ManageAuditoriumsForm | «boundary» | - | AC-B-ManageAuditoriumsForm |
| SD1c-L-C | Lifeline | :ManageAuditoriumsController | «control» | - | AC-C-ManageAuditoriumsController |
| SD1c-L-CI | Lifeline | :Cinema | «entity» | - | AC-E-Cinema; cụm rạp của quản lý cụm rạp |
| SD1c-L-AD | Lifeline | phòngMới:Auditorium | «entity» | - | AC-E-Auditorium; phòng chiếu dự kiến chưa vào cụm rạp (Q-245) |
| SD1c-R1 | Fragment | ref SD1b - Bước 3-4, 4a, 4b | - | - | ref, đặt ở mức ngoài cùng |
| SD1c-F1 | Fragment | alt [tên phòng chiếu đã thuộc phòng khác trong cùng cụm rạp (4d)] | - | - | Bao các message của fragment |
| SD1c-F1-O2 | Fragment | [tên phòng chiếu chưa thuộc phòng khác] | - | SD1c-F1 | Toán hạng thứ 2; đường ngăn là edge SD1c-F1-O2-SEP nét đứt |
| SD1c-N1 | Note | quay lại bước 3 | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 2.1.6 | :ManageAuditoriumsController | :Cinema | // addAuditorium (phòng chiếu dự kiến, tên phòng chiếu) | Đồng bộ | - | 5 |
| 2.1.6.1 | :Cinema | :Cinema | // checkAuditoriumNameAvailable (tên phòng chiếu, BR-145) | Tự gọi | - | 5 |
| 2.1.6 (trả về) | :Cinema | :ManageAuditoriumsController | phòng chiếu đã lưu, hoặc kết quả tên phòng đã thuộc phòng khác | Trả về | - | 5 |
| 2.1.7 | :ManageAuditoriumsController | :ManageAuditoriumsForm | // notifyRefusal (tên phòng chiếu đã thuộc phòng khác trong cụm rạp, BR-145) | Đồng bộ | SD1c-F1 | 4d |
| 2.1.8 | :ManageAuditoriumsController | phòngMới:Auditorium | // provideAuditoriumInfo (phòng chiếu đã lưu) | Đồng bộ | - | 6 |
| 2.1.8.1 | phòngMới:Auditorium | phòngMới:Auditorium | // calculateCapacity (ghế đôi tính một ghế, BR-06) | Tự gọi | - | 6 |
| 2.1.8 (trả về) | phòngMới:Auditorium | :ManageAuditoriumsController | tên, loại phòng, định dạng chiếu được, sức chứa, số ghế theo từng loại ghế | Trả về | - | 6 |
| 2.1.9 | :ManageAuditoriumsController | :ManageAuditoriumsForm | // showSavedAuditorium (phòng chiếu đã lưu cùng sức chứa) | Đồng bộ | - | 6 |

### a) SD2a - Luồng 1a, bước 1a1-1a3

Luồng sửa phòng chiếu, đoạn 1a-1a3, trang riêng vì rẽ ngay từ bước 1; STT dùng hậu tố a. Phòng chọn phải thuộc cụm rạp của quản lý (Dữ liệu vào 2, BR-135): P04 chưa có luồng khi vi phạm (Q-252), message 2a.1.1 chỉ kiểm, không vẽ fragment. Sau 1a3 quay lại bước 3 (SD1b). Trang có 2 fragment loop.

b) Bảng Node

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD2a-L-A4 | Actor | :Quản lý cụm rạp | - | - | Tác nhân (ACT-04) |
| SD2a-L-PF | Lifeline | :ManageAuditoriumsForm | «boundary» | - | AC-B-ManageAuditoriumsForm |
| SD2a-L-C | Lifeline | :ManageAuditoriumsController | «control» | - | AC-C-ManageAuditoriumsController |
| SD2a-L-CM | Lifeline | :CinemaManager | «entity» | - | AC-E-CinemaManager |
| SD2a-L-CI | Lifeline | :Cinema | «entity» | - | AC-E-Cinema; cụm rạp của quản lý cụm rạp |
| SD2a-L-AU | Lifeline | :Auditorium | «entity» | - | AC-E-Auditorium; mỗi phòng chiếu của cụm rạp khi liệt kê |
| SD2a-L-AS | Lifeline | phòngChọn:Auditorium | «entity» | - | AC-E-Auditorium; phòng chiếu đã chọn để sửa hoặc xoá |
| SD2a-L-SE | Lifeline | :Seat | «entity» | - | AC-E-Seat; mỗi ghế của sơ đồ ghế |
| SD2a-F1 | Fragment | loop [mỗi phòng chiếu của cụm rạp] | - | - | Bao các message của fragment |
| SD2a-F2 | Fragment | loop [mỗi ghế của phòng chiếu] | - | - | Bao các message của fragment |
| SD2a-N1 | Note | phòng chọn không thuộc cụm rạp của quản lý: từ chối theo BR-135, P04 chưa có luồng (Q-252) | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1a | :Quản lý cụm rạp | :ManageAuditoriumsForm | // requestAuditoriumEdit | Đồng bộ | - | 1a |
| 1a.1 | :ManageAuditoriumsForm | :ManageAuditoriumsController | // startAuditoriumEdit | Đồng bộ | - | 1a1 |
| 1a.1.1 | :ManageAuditoriumsController | :CinemaManager | // provideCinema (BR-135) | Đồng bộ | - | 1a1 |
| 1a.1.1 (trả về) | :CinemaManager | :ManageAuditoriumsController | cụm rạp của quản lý cụm rạp | Trả về | - | 1a1 |
| 1a.1.2 | :ManageAuditoriumsController | :Cinema | // provideAuditoriums | Đồng bộ | - | 1a1 |
| 1a.1.2.1 | :Cinema | :Auditorium | // provideAuditoriumInfo | Đồng bộ | SD2a-F1 | 1a1 |
| 1a.1.2.1 (trả về) | :Auditorium | :Cinema | tên, loại phòng, định dạng chiếu được, sức chứa, mốc thay đổi | Trả về | SD2a-F1 | 1a1 |
| 1a.1.2 (trả về) | :Cinema | :ManageAuditoriumsController | danh sách phòng chiếu của cụm rạp | Trả về | - | 1a1 |
| 1a.1.3 | :ManageAuditoriumsController | :ManageAuditoriumsForm | // showAuditoriumList (danh sách phòng chiếu, mốc thay đổi lúc hiển thị) | Đồng bộ | - | 1a1 |
| 2a | :Quản lý cụm rạp | :ManageAuditoriumsForm | // selectAuditoriumToEdit (phòng chiếu cần sửa) | Đồng bộ | - | 1a2 |
| 2a.1 | :ManageAuditoriumsForm | :ManageAuditoriumsController | // selectAuditorium (phòng chiếu đã chọn) | Đồng bộ | - | 1a2 |
| 2a.1.1 | :ManageAuditoriumsController | phòngChọn:Auditorium | // checkBelongsToCinema (cụm rạp của quản lý cụm rạp, BR-135) | Đồng bộ | - | 1a2 |
| 2a.1.1 (trả về) | phòngChọn:Auditorium | :ManageAuditoriumsController | thuộc cụm rạp của quản lý hoặc không | Trả về | - | 1a2 |
| 2a.1.2 | :ManageAuditoriumsController | phòngChọn:Auditorium | // provideAuditoriumDetail | Đồng bộ | - | 1a3 |
| 2a.1.2.1 | phòngChọn:Auditorium | :Seat | // provideSeatInfo | Đồng bộ | SD2a-F2 | 1a3 |
| 2a.1.2.1 (trả về) | :Seat | phòngChọn:Auditorium | hàng, số ghế, loại ghế | Trả về | SD2a-F2 | 1a3 |
| 2a.1.2 (trả về) | phòngChọn:Auditorium | :ManageAuditoriumsController | tên, loại phòng, định dạng chiếu được, từng ghế của phòng | Trả về | - | 1a3 |
| 2a.1.3 | :ManageAuditoriumsController | :ManageAuditoriumsForm | // showAuditoriumForEdit (thông tin hiện tại của phòng chiếu, từng ghế) | Đồng bộ | - | 1a3 |

### a) SD2b - Luồng 1a, bước 5 kiểm tra, 4d, 5a, 5b, 5c

Đoạn kiểm tra của bước 5 luồng sửa, bắt đầu bằng ref tới SD1b (bước 3-4 dùng chung); STT dùng hậu tố a tại điểm rẽ 2.1.6 của SD1c. Lời gọi 2.1.6a gom các kiểm tra của thao tác không chia cắt: mốc thay đổi (5c), tên phòng (4d), sơ đồ ghế có đổi (5a), bảng giá còn đủ (5b); phần ghi ở SD2c, cùng thao tác (bảng cuối mục 4). Suất chiếu tìm theo điều kiện (Q-250). Luồng 5a và 5b kết thúc use case nên dùng break ở mức ngoài cùng, sau alt của 5c và 4d (cùng quay lại bước trước, Q-254). Trang có 3 fragment không kể ref.

b) Bảng Node

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD2b-L-PF | Lifeline | :ManageAuditoriumsForm | «boundary» | - | AC-B-ManageAuditoriumsForm |
| SD2b-L-C | Lifeline | :ManageAuditoriumsController | «control» | - | AC-C-ManageAuditoriumsController |
| SD2b-L-AS | Lifeline | phòngChọn:Auditorium | «entity» | - | AC-E-Auditorium; phòng chiếu đã chọn để sửa hoặc xoá |
| SD2b-L-CI | Lifeline | :Cinema | «entity» | - | AC-E-Cinema; cụm rạp của quản lý cụm rạp |
| SD2b-L-ST1 | Lifeline | chặn:Showtime | «entity» | - | AC-E-Showtime; suất chiếu của phòng đã tới thời điểm mở bán và chưa kết thúc, không kể suất chiếu đã xoá, tìm theo điều kiện (A6 a, Q-250) |
| SD2b-L-ST2 | Lifeline | chưaChiếu:Showtime | «entity» | - | AC-E-Showtime; suất chiếu của phòng chưa tới giờ bắt đầu, không kể suất chiếu đã xoá, tìm theo điều kiện (A6 a, Q-250) |
| SD2b-L-PL | Lifeline | :PriceList | «entity» | - | AC-E-PriceList; bảng giá của cụm rạp |
| SD2b-R1 | Fragment | ref SD1b - Bước 3-4, 4a, 4b | - | - | ref, đặt ở mức ngoài cùng |
| SD2b-F1 | Fragment | alt [phòng chiếu đã bị yêu cầu khác sửa kể từ lúc hiển thị (5c)] | - | - | Bao các message của fragment |
| SD2b-F1-O2 | Fragment | [tên phòng chiếu đã thuộc phòng khác trong cùng cụm rạp (4d)] | - | SD2b-F1 | Toán hạng thứ 2; đường ngăn là edge SD2b-F1-O2-SEP nét đứt |
| SD2b-F1-O3 | Fragment | [phòng chưa bị sửa kể từ lúc hiển thị và tên phòng chưa thuộc phòng khác] | - | SD2b-F1 | Toán hạng thứ 3; đường ngăn là edge SD2b-F1-O3-SEP nét đứt |
| SD2b-F2 | Fragment | break [sơ đồ ghế bị thay đổi và phòng có suất chiếu đã tới thời điểm mở bán mà chưa kết thúc (5a)] | - | - | Bao các message của fragment |
| SD2b-F3 | Fragment | break [đổi loại phòng hoặc loại ghế làm suất chiếu chưa tới giờ bắt đầu thiếu giá, không thuộc 5a (5b)] | - | - | Bao các message của fragment |
| SD2b-N1 | Note | 5c quay lại bước 1a1, 4d quay lại bước 3 | - | - | Chú thích |
| SD2b-N2 | Note | 2.1.6a.4 chỉ xét khi sơ đồ ghế thay đổi; 2.1.6a.5 chỉ xét khi đổi loại phòng hoặc loại ghế | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 2.1.6a | :ManageAuditoriumsController | phòngChọn:Auditorium | // checkEditAllowed (thông tin phòng chiếu đã kiểm, sơ đồ ghế mới, mốc thay đổi lúc hiển thị) | Đồng bộ | - | 5 |
| 2.1.6a.1 | phòngChọn:Auditorium | phòngChọn:Auditorium | // checkUnchangedSinceDisplayed (mốc thay đổi lúc hiển thị, BR-146) | Tự gọi | - | 5 |
| 2.1.6a.2 | phòngChọn:Auditorium | :Cinema | // checkAuditoriumNameAvailable (tên phòng chiếu, không kể phòng này, BR-145) | Đồng bộ | - | 5 |
| 2.1.6a.2 (trả về) | :Cinema | phòngChọn:Auditorium | tên chưa thuộc phòng khác hoặc đã thuộc | Trả về | - | 5 |
| 2.1.6a.3 | phòngChọn:Auditorium | phòngChọn:Auditorium | // checkSeatMapChanged (sơ đồ ghế mới so với sơ đồ hiện tại) | Tự gọi | - | 5 |
| 2.1.6a.4 | phòngChọn:Auditorium | chặn:Showtime | // checkBlocksSeatMapEdit (BR-87) | Đồng bộ | - | 5 |
| 2.1.6a.4 (trả về) | chặn:Showtime | phòngChọn:Auditorium | có suất chiếu đã mở bán chưa kết thúc hoặc không | Trả về | - | 5 |
| 2.1.6a.5 | phòngChọn:Auditorium | chưaChiếu:Showtime | // checkStaysPriced (loại phòng mới, loại ghế mới, BR-73) | Đồng bộ | - | 5 |
| 2.1.6a.5.1 | chưaChiếu:Showtime | :PriceList | // checkCoversShowtime (loại phòng, loại ghế, giờ bắt đầu, định dạng, BR-69) | Đồng bộ | - | 5 |
| 2.1.6a.5.1 (trả về) | :PriceList | chưaChiếu:Showtime | bảng giá phủ mọi loại ghế hoặc thiếu giá | Trả về | - | 5 |
| 2.1.6a.5 (trả về) | chưaChiếu:Showtime | phòngChọn:Auditorium | có suất chiếu thiếu giá hoặc không | Trả về | - | 5 |
| 2.1.6a (trả về) | phòngChọn:Auditorium | :ManageAuditoriumsController | được phép lưu, hoặc lý do bị từ chối | Trả về | - | 5 |
| 2.1.7a | :ManageAuditoriumsController | :ManageAuditoriumsForm | // notifyRefusal (phòng chiếu đã bị sửa, mở lại phòng chiếu từ đầu, BR-146) | Đồng bộ | SD2b-F1 | 5c |
| 2.1.8a | :ManageAuditoriumsController | :ManageAuditoriumsForm | // notifyRefusal (tên phòng chiếu đã thuộc phòng khác trong cụm rạp, BR-145) | Đồng bộ | SD2b-F1 | 4d |
| 2.1.9a | :ManageAuditoriumsController | :ManageAuditoriumsForm | // notifyRefusal (phòng có suất chiếu đã mở bán chưa kết thúc, BR-87) | Đồng bộ | SD2b-F2 | 5a |
| 2.1.10a | :ManageAuditoriumsController | :ManageAuditoriumsForm | // notifyRefusal (suất chiếu chưa tới giờ bắt đầu sẽ thiếu giá, BR-73) | Đồng bộ | SD2b-F3 | 5b |

### a) SD2c - Luồng 1a, bước 5 ghi, 6

Đoạn ghi của bước 5 và bước 6 luồng sửa, bắt đầu bằng ref tới SD2b (mọi kiểm tra đạt). Auditorium ghi thông tin mới, rồi Auditorium gửi message tới từng suất chiếu chưa mở bán của phòng để dùng sơ đồ ghế mới (BR-118); Showtime tự cập nhật trạng thái ghế của mình (Q-249). Loop chỉ chạy khi sơ đồ ghế thay đổi.

b) Bảng Node

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD2c-L-PF | Lifeline | :ManageAuditoriumsForm | «boundary» | - | AC-B-ManageAuditoriumsForm |
| SD2c-L-C | Lifeline | :ManageAuditoriumsController | «control» | - | AC-C-ManageAuditoriumsController |
| SD2c-L-AS | Lifeline | phòngChọn:Auditorium | «entity» | - | AC-E-Auditorium; phòng chiếu đã chọn để sửa hoặc xoá |
| SD2c-L-ST3 | Lifeline | chưaMởBán:Showtime | «entity» | - | AC-E-Showtime; mỗi suất chiếu của phòng chưa tới thời điểm mở bán, không kể suất chiếu đã xoá |
| SD2c-R1 | Fragment | ref SD2b - Luồng 1a, bước 5 kiểm tra, 4d, 5a, 5b, 5c | - | - | ref, đặt ở mức ngoài cùng |
| SD2c-F1 | Fragment | loop [mỗi suất chiếu của phòng chưa tới thời điểm mở bán, khi sơ đồ ghế thay đổi] | - | - | Bao các message của fragment |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 2.1.11a | :ManageAuditoriumsController | phòngChọn:Auditorium | // applyChanges (thông tin phòng chiếu đã kiểm, sơ đồ ghế mới) | Đồng bộ | - | 5 |
| 2.1.11a.1 | phòngChọn:Auditorium | chưaMởBán:Showtime | // adoptSeatMap (sơ đồ ghế mới, BR-118) | Đồng bộ | SD2c-F1 | 5 |
| 2.1.11a.1 (trả về) | chưaMởBán:Showtime | phòngChọn:Auditorium | suất chiếu đã dùng sơ đồ ghế mới | Trả về | SD2c-F1 | 5 |
| 2.1.11a (trả về) | phòngChọn:Auditorium | :ManageAuditoriumsController | phòng chiếu đã lưu | Trả về | - | 5 |
| 2.1.12a | :ManageAuditoriumsController | phòngChọn:Auditorium | // provideAuditoriumInfo (phòng chiếu đã lưu) | Đồng bộ | - | 6 |
| 2.1.12a.1 | phòngChọn:Auditorium | phòngChọn:Auditorium | // calculateCapacity (ghế đôi tính một ghế, BR-06) | Tự gọi | - | 6 |
| 2.1.12a (trả về) | phòngChọn:Auditorium | :ManageAuditoriumsController | tên, loại phòng, định dạng chiếu được, sức chứa, số ghế theo từng loại ghế | Trả về | - | 6 |
| 2.1.13a | :ManageAuditoriumsController | :ManageAuditoriumsForm | // showSavedAuditorium (phòng chiếu đã lưu cùng sức chứa) | Đồng bộ | - | 6 |

### a) SD3 - Luồng 1b, 1b3a

Luồng xoá phòng chiếu, trang riêng vì rẽ ngay từ bước 1; STT dùng hậu tố b. Cinema là đối tượng toàn thể của phòng chiếu nên bỏ phòng cùng các ghế (// removeAuditorium) là trách nhiệm của Cinema, sau khi hỏi phòng chiếu đã từng có suất chiếu chưa (đếm trên lịch chiếu của phòng, A6 b, kể cả suất chiếu đã xoá). Luồng 1b3a kết thúc use case thất bại nên dùng break ở mức ngoài cùng; 1b4 kết thúc thành công.

b) Bảng Node

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD3-L-A4 | Actor | :Quản lý cụm rạp | - | - | Tác nhân (ACT-04) |
| SD3-L-PF | Lifeline | :ManageAuditoriumsForm | «boundary» | - | AC-B-ManageAuditoriumsForm |
| SD3-L-C | Lifeline | :ManageAuditoriumsController | «control» | - | AC-C-ManageAuditoriumsController |
| SD3-L-CM | Lifeline | :CinemaManager | «entity» | - | AC-E-CinemaManager |
| SD3-L-CI | Lifeline | :Cinema | «entity» | - | AC-E-Cinema; cụm rạp của quản lý cụm rạp |
| SD3-L-AU | Lifeline | :Auditorium | «entity» | - | AC-E-Auditorium; mỗi phòng chiếu của cụm rạp khi liệt kê |
| SD3-L-AS | Lifeline | phòngChọn:Auditorium | «entity» | - | AC-E-Auditorium; phòng chiếu đã chọn để sửa hoặc xoá |
| SD3-F1 | Fragment | loop [mỗi phòng chiếu của cụm rạp] | - | - | Bao các message của fragment |
| SD3-F2 | Fragment | break [phòng chiếu đã từng có suất chiếu, kể cả suất chiếu đã xoá (1b3a)] | - | - | Bao các message của fragment |
| SD3-N1 | Note | phòng chọn không thuộc cụm rạp của quản lý: từ chối theo BR-135, P04 chưa có luồng (Q-252) | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1b | :Quản lý cụm rạp | :ManageAuditoriumsForm | // requestAuditoriumRemoval | Đồng bộ | - | 1b |
| 1b.1 | :ManageAuditoriumsForm | :ManageAuditoriumsController | // startAuditoriumRemoval | Đồng bộ | - | 1b1 |
| 1b.1.1 | :ManageAuditoriumsController | :CinemaManager | // provideCinema (BR-135) | Đồng bộ | - | 1b1 |
| 1b.1.1 (trả về) | :CinemaManager | :ManageAuditoriumsController | cụm rạp của quản lý cụm rạp | Trả về | - | 1b1 |
| 1b.1.2 | :ManageAuditoriumsController | :Cinema | // provideAuditoriums | Đồng bộ | - | 1b1 |
| 1b.1.2.1 | :Cinema | :Auditorium | // provideAuditoriumInfo | Đồng bộ | SD3-F1 | 1b1 |
| 1b.1.2.1 (trả về) | :Auditorium | :Cinema | tên, loại phòng, định dạng chiếu được, sức chứa | Trả về | SD3-F1 | 1b1 |
| 1b.1.2 (trả về) | :Cinema | :ManageAuditoriumsController | danh sách phòng chiếu của cụm rạp | Trả về | - | 1b1 |
| 1b.1.3 | :ManageAuditoriumsController | :ManageAuditoriumsForm | // showAuditoriumList (danh sách phòng chiếu) | Đồng bộ | - | 1b1 |
| 2b | :Quản lý cụm rạp | :ManageAuditoriumsForm | // selectAuditoriumToRemove (phòng chiếu cần xoá) | Đồng bộ | - | 1b2 |
| 2b.1 | :ManageAuditoriumsForm | :ManageAuditoriumsController | // submitAuditoriumRemoval (phòng chiếu đã chọn) | Đồng bộ | - | 1b2 |
| 2b.1.1 | :ManageAuditoriumsController | phòngChọn:Auditorium | // checkBelongsToCinema (cụm rạp của quản lý cụm rạp, BR-135) | Đồng bộ | - | 1b2 |
| 2b.1.1 (trả về) | phòngChọn:Auditorium | :ManageAuditoriumsController | thuộc cụm rạp của quản lý hoặc không | Trả về | - | 1b2 |
| 2b.1.2 | :ManageAuditoriumsController | :Cinema | // removeAuditorium (phòng chiếu đã chọn) | Đồng bộ | - | 1b3 |
| 2b.1.2.1 | :Cinema | phòngChọn:Auditorium | // checkNeverScheduled (BR-147) | Đồng bộ | - | 1b3 |
| 2b.1.2.1 (trả về) | phòngChọn:Auditorium | :Cinema | chưa từng có suất chiếu hoặc đã từng | Trả về | - | 1b3 |
| 2b.1.2 (trả về) | :Cinema | :ManageAuditoriumsController | phòng chiếu đã xoá, hoặc lý do bị từ chối | Trả về | - | 1b3 |
| 2b.1.3 | :ManageAuditoriumsController | :ManageAuditoriumsForm | // notifyRefusal (phòng chiếu đã từng có suất chiếu, kể cả suất chiếu đã xoá, BR-147) | Đồng bộ | SD3-F2 | 1b3a |
| 2b.1.4 | :ManageAuditoriumsController | :ManageAuditoriumsForm | // showRemovalSuccess | Đồng bộ | - | 1b4 |

### a) SD4 - Luồng *a

Trang riêng theo A2 và F5 c): bắt đầu bằng ref tới các trang trước bước 5 (trước 1b3 với luồng 1b), note nêu khoảng message có thể xảy ra, STT lấy message đầu khoảng kèm mã luồng (1*a). Không có break vì huỷ có thể xảy ra tại nhiều điểm; không có message hoàn tác vì phòng chiếu chưa bị ghi.

b) Bảng Node

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD4-L-A4 | Actor | :Quản lý cụm rạp | - | - | Tác nhân (ACT-04) |
| SD4-L-PF | Lifeline | :ManageAuditoriumsForm | «boundary» | - | AC-B-ManageAuditoriumsForm |
| SD4-L-C | Lifeline | :ManageAuditoriumsController | «control» | - | AC-C-ManageAuditoriumsController |
| SD4-R1 | Fragment | ref SD1a - Luồng chính, bước 1-2 | - | - | ref, đặt ở mức ngoài cùng |
| SD4-R2 | Fragment | ref SD1b - Bước 3-4, 4a, 4b | - | - | ref, đặt ở mức ngoài cùng |
| SD4-R3 | Fragment | ref SD2a - Luồng 1a, bước 1a1-1a3 | - | - | ref, đặt ở mức ngoài cùng |
| SD4-R4 | Fragment | ref SD3 - Luồng 1b, 1b3a | - | - | ref, đặt ở mức ngoài cùng |
| SD4-N1 | Note | có thể xảy ra tại bất kỳ message nào từ 1 đến 1.1.3 của SD1a, từ 2 đến 2.1.5 của SD1b, từ 1a đến 2a.1.3 của SD2a và từ 1b đến 2b.1.1 của SD3 (trước bước 5, trước 1b3) | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1*a | :Quản lý cụm rạp | :ManageAuditoriumsForm | // cancelRequest | Đồng bộ | - | *a |
| 1*a.1 | :ManageAuditoriumsForm | :ManageAuditoriumsController | // cancelRequest | Đồng bộ | - | *a |
| 1*a.1.1 | :ManageAuditoriumsController | :ManageAuditoriumsController | // discardRequest (không đổi phòng chiếu) | Tự gọi | - | *a |

## 6. Quy tắc tương tác giữa các lớp phân tích

| Vi phạm | Message hoặc link | Cách sửa đã áp dụng |
|---|---|---|
| Không có | - | - |

Đã kiểm: actor chỉ gửi message tới ManageAuditoriumsForm; ManageAuditoriumsForm chỉ gửi tới ManageAuditoriumsController; ManageAuditoriumsController gọi CinemaManager, Cinema, Auditorium và ManageAuditoriumsForm. Entity gọi entity chỉ khi có quan hệ cấu trúc: Cinema --> Auditorium (R-UC012-05, cả hai chiều: Auditorium --> Cinema ở 2.1.6a.2), Auditorium --> Seat (R-UC012-06), Auditorium --> Showtime (R-UC012-07), Showtime --> PriceList (R-UC012-08). Không lifeline nào đại diện cho một tập: loop gửi message tới từng phòng, từng ghế, từng suất chiếu; chặn:Showtime và chưaChiếu:Showtime là một suất chiếu tìm theo điều kiện (A6 a).

## 7. Communication diagram

File diagrams/P07-communication-UC-012.drawio có 1 trang CM1 cho mọi luồng (MUC_CHI_TIET là DAY_DU): luồng chính, 4a, 4b, 4d (SD1a, SD1b, SD1c), luồng 1a, 5a, 5b, 5c (SD2a, SD2b, SD2c), luồng 1b, 1b3a (SD3) và *a (SD4), giữ nguyên STT của sequence diagram. Message trả về không vẽ. Link tự nối không sinh quan hệ VOPC. Guard của fragment ghi trong ngoặc vuông cuối message.

### Trang CM1 - Mọi luồng

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| CM1-O-A4 | Actor | :Quản lý cụm rạp | - | - | Tác nhân (ACT-04) |
| CM1-O-PF | Object | :ManageAuditoriumsForm | «boundary» | - | AC-B-ManageAuditoriumsForm |
| CM1-O-C | Object | :ManageAuditoriumsController | «control» | - | AC-C-ManageAuditoriumsController |
| CM1-O-CM | Object | :CinemaManager | «entity» | - | AC-E-CinemaManager |
| CM1-O-CI | Object | :Cinema | «entity» | - | AC-E-Cinema; cụm rạp của quản lý cụm rạp |
| CM1-O-AU | Object | :Auditorium | «entity» | - | AC-E-Auditorium; mỗi phòng chiếu của cụm rạp khi liệt kê |
| CM1-O-AD | Object | phòngMới:Auditorium | «entity» | - | AC-E-Auditorium; phòng chiếu dự kiến chưa vào cụm rạp (Q-245) |
| CM1-O-AS | Object | phòngChọn:Auditorium | «entity» | - | AC-E-Auditorium; phòng chiếu đã chọn để sửa hoặc xoá |
| CM1-O-SE | Object | :Seat | «entity» | - | AC-E-Seat; mỗi ghế của sơ đồ ghế |
| CM1-O-ST1 | Object | chặn:Showtime | «entity» | - | AC-E-Showtime; suất chiếu của phòng đã tới thời điểm mở bán và chưa kết thúc, không kể suất chiếu đã xoá, tìm theo điều kiện (A6 a, Q-250) |
| CM1-O-ST2 | Object | chưaChiếu:Showtime | «entity» | - | AC-E-Showtime; suất chiếu của phòng chưa tới giờ bắt đầu, không kể suất chiếu đã xoá, tìm theo điều kiện (A6 a, Q-250) |
| CM1-O-ST3 | Object | chưaMởBán:Showtime | «entity» | - | AC-E-Showtime; mỗi suất chiếu của phòng chưa tới thời điểm mở bán, không kể suất chiếu đã xoá |
| CM1-O-PL | Object | :PriceList | «entity» | - | AC-E-PriceList; bảng giá của cụm rạp |

b) Bảng Edge

| ID | Nguồn | Đích | Loại | Nhãn | Chiều message |
|---|---|---|---|---|---|
| CM1-L1 | CM1-O-A4 | CM1-O-PF | Link | 1: // requestAuditoriumAddition (-->)<br>2: // enterAuditoriumInfo (tên phòng chiếu, loại phòng, định dạng chiếu được, sơ đồ ghế) (-->)<br>1a: // requestAuditoriumEdit (-->)<br>2a: // selectAuditoriumToEdit (phòng chiếu cần sửa) (-->)<br>1b: // requestAuditoriumRemoval (-->)<br>2b: // selectAuditoriumToRemove (phòng chiếu cần xoá) (-->)<br>1*a: // cancelRequest (-->) | Nguồn-->Đích: 1, 2, 1a, 2a, 1b, 2b, 1*a |
| CM1-L2 | CM1-O-PF | CM1-O-C | Link | 1.1: // startAuditoriumAddition (-->)<br>1.1.3: // showAuditoriumList (danh sách phòng chiếu) (<--)<br>2.1: // submitAuditorium (thông tin phòng chiếu, sơ đồ ghế; luồng 1a kèm mốc thay đổi lúc hiển thị) (-->)<br>2.1.4: // notifyRefusal (điều kiện bị vi phạm của từng trường) (<--) [thông tin phòng chiếu hoặc sơ đồ ghế không đạt điều kiện hợp lệ (4a)]<br>2.1.5: // notifyRefusal (sức chứa ngoài khoảng 50 đến 400 ghế, BR-144) (<--) [sức chứa ngoài khoảng 50 đến 400 ghế, không thuộc 4a (4b)]<br>2.1.7: // notifyRefusal (tên phòng chiếu đã thuộc phòng khác trong cụm rạp, BR-145) (<--) [tên phòng chiếu đã thuộc phòng khác trong cùng cụm rạp (4d)]<br>2.1.9: // showSavedAuditorium (phòng chiếu đã lưu cùng sức chứa) (<--)<br>1a.1: // startAuditoriumEdit (-->)<br>1a.1.3: // showAuditoriumList (danh sách phòng chiếu, mốc thay đổi lúc hiển thị) (<--)<br>2a.1: // selectAuditorium (phòng chiếu đã chọn) (-->)<br>2a.1.3: // showAuditoriumForEdit (thông tin hiện tại của phòng chiếu, từng ghế) (<--)<br>2.1.7a: // notifyRefusal (phòng chiếu đã bị sửa, mở lại phòng chiếu từ đầu, BR-146) (<--) [phòng chiếu đã bị yêu cầu khác sửa kể từ lúc hiển thị (5c)]<br>2.1.8a: // notifyRefusal (tên phòng chiếu đã thuộc phòng khác trong cụm rạp, BR-145) (<--) [tên phòng chiếu đã thuộc phòng khác trong cùng cụm rạp (4d)]<br>2.1.9a: // notifyRefusal (phòng có suất chiếu đã mở bán chưa kết thúc, BR-87) (<--) [sơ đồ ghế bị thay đổi và phòng có suất chiếu đã tới thời điểm mở bán mà chưa kết thúc (5a)]<br>2.1.10a: // notifyRefusal (suất chiếu chưa tới giờ bắt đầu sẽ thiếu giá, BR-73) (<--) [đổi loại phòng hoặc loại ghế làm suất chiếu chưa tới giờ bắt đầu thiếu giá, không thuộc 5a (5b)]<br>2.1.13a: // showSavedAuditorium (phòng chiếu đã lưu cùng sức chứa) (<--)<br>1b.1: // startAuditoriumRemoval (-->)<br>1b.1.3: // showAuditoriumList (danh sách phòng chiếu) (<--)<br>2b.1: // submitAuditoriumRemoval (phòng chiếu đã chọn) (-->)<br>2b.1.3: // notifyRefusal (phòng chiếu đã từng có suất chiếu, kể cả suất chiếu đã xoá, BR-147) (<--) [phòng chiếu đã từng có suất chiếu, kể cả suất chiếu đã xoá (1b3a)]<br>2b.1.4: // showRemovalSuccess (<--)<br>1*a.1: // cancelRequest (-->) | Nguồn-->Đích: 1.1, 2.1, 1a.1, 2a.1, 1b.1, 2b.1, 1*a.1; Đích-->Nguồn: 1.1.3, 2.1.4, 2.1.5, 2.1.7, 2.1.9, 1a.1.3, 2a.1.3, 2.1.7a, 2.1.8a, 2.1.9a, 2.1.10a, 2.1.13a, 1b.1.3, 2b.1.3, 2b.1.4 |
| CM1-L3 | CM1-O-C | CM1-O-CM | Link | 1.1.1: // provideCinema (BR-135) (-->)<br>1a.1.1: // provideCinema (BR-135) (-->)<br>1b.1.1: // provideCinema (BR-135) (-->) | Nguồn-->Đích: 1.1.1, 1a.1.1, 1b.1.1 |
| CM1-L4 | CM1-O-C | CM1-O-CI | Link | 1.1.2: // provideAuditoriums (-->)<br>2.1.6: // addAuditorium (phòng chiếu dự kiến, tên phòng chiếu) (-->)<br>1a.1.2: // provideAuditoriums (-->)<br>1b.1.2: // provideAuditoriums (-->)<br>2b.1.2: // removeAuditorium (phòng chiếu đã chọn) (-->) | Nguồn-->Đích: 1.1.2, 2.1.6, 1a.1.2, 1b.1.2, 2b.1.2 |
| CM1-L5 | CM1-O-CI | CM1-O-AU | Link | 1.1.2.1: // provideAuditoriumInfo (-->) [lặp: mỗi phòng chiếu của cụm rạp]<br>1a.1.2.1: // provideAuditoriumInfo (-->) [lặp: mỗi phòng chiếu của cụm rạp]<br>1b.1.2.1: // provideAuditoriumInfo (-->) [lặp: mỗi phòng chiếu của cụm rạp] | Nguồn-->Đích: 1.1.2.1, 1a.1.2.1, 1b.1.2.1 |
| CM1-L6 | CM1-O-C | CM1-O-AD | Link | 2.1.1: «create» // createAuditorium (thông tin phòng chiếu đã nhập) (-->)<br>2.1.2: // checkAuditoriumInfoValid (-->)<br>2.1.3: // checkCapacityInRange (BR-144) (-->)<br>2.1.8: // provideAuditoriumInfo (phòng chiếu đã lưu) (-->) | Nguồn-->Đích: 2.1.1, 2.1.2, 2.1.3, 2.1.8 |
| CM1-L7 | CM1-O-AD | CM1-O-SE | Link | 2.1.1.1: «create» // createSeat (hàng, số ghế, loại ghế) (-->) [lặp: mỗi ghế của sơ đồ ghế đã nhập] | Nguồn-->Đích: 2.1.1.1 |
| CM1-L8 | CM1-O-SE | CM1-O-SE | Link | 2.1.1.1.1: // checkSeatValid (hàng, số ghế, loại ghế) (-->) [lặp: mỗi ghế của sơ đồ ghế đã nhập] | Nguồn-->Đích: 2.1.1.1.1 |
| CM1-L9 | CM1-O-AD | CM1-O-AD | Link | 2.1.3.1: // calculateCapacity (ghế đôi tính một ghế, BR-06) (-->)<br>2.1.8.1: // calculateCapacity (ghế đôi tính một ghế, BR-06) (-->) | Nguồn-->Đích: 2.1.3.1, 2.1.8.1 |
| CM1-L10 | CM1-O-CI | CM1-O-CI | Link | 2.1.6.1: // checkAuditoriumNameAvailable (tên phòng chiếu, BR-145) (-->) | Nguồn-->Đích: 2.1.6.1 |
| CM1-L11 | CM1-O-C | CM1-O-AS | Link | 2a.1.1: // checkBelongsToCinema (cụm rạp của quản lý cụm rạp, BR-135) (-->)<br>2a.1.2: // provideAuditoriumDetail (-->)<br>2.1.6a: // checkEditAllowed (thông tin phòng chiếu đã kiểm, sơ đồ ghế mới, mốc thay đổi lúc hiển thị) (-->)<br>2.1.11a: // applyChanges (thông tin phòng chiếu đã kiểm, sơ đồ ghế mới) (-->)<br>2.1.12a: // provideAuditoriumInfo (phòng chiếu đã lưu) (-->)<br>2b.1.1: // checkBelongsToCinema (cụm rạp của quản lý cụm rạp, BR-135) (-->) | Nguồn-->Đích: 2a.1.1, 2a.1.2, 2.1.6a, 2.1.11a, 2.1.12a, 2b.1.1 |
| CM1-L12 | CM1-O-AS | CM1-O-SE | Link | 2a.1.2.1: // provideSeatInfo (-->) [lặp: mỗi ghế của phòng chiếu] | Nguồn-->Đích: 2a.1.2.1 |
| CM1-L13 | CM1-O-AS | CM1-O-AS | Link | 2.1.6a.1: // checkUnchangedSinceDisplayed (mốc thay đổi lúc hiển thị, BR-146) (-->)<br>2.1.6a.3: // checkSeatMapChanged (sơ đồ ghế mới so với sơ đồ hiện tại) (-->)<br>2.1.12a.1: // calculateCapacity (ghế đôi tính một ghế, BR-06) (-->) | Nguồn-->Đích: 2.1.6a.1, 2.1.6a.3, 2.1.12a.1 |
| CM1-L14 | CM1-O-AS | CM1-O-CI | Link | 2.1.6a.2: // checkAuditoriumNameAvailable (tên phòng chiếu, không kể phòng này, BR-145) (-->)<br>2b.1.2.1: // checkNeverScheduled (BR-147) (<--) | Nguồn-->Đích: 2.1.6a.2; Đích-->Nguồn: 2b.1.2.1 |
| CM1-L15 | CM1-O-AS | CM1-O-ST1 | Link | 2.1.6a.4: // checkBlocksSeatMapEdit (BR-87) (-->) | Nguồn-->Đích: 2.1.6a.4 |
| CM1-L16 | CM1-O-AS | CM1-O-ST2 | Link | 2.1.6a.5: // checkStaysPriced (loại phòng mới, loại ghế mới, BR-73) (-->) | Nguồn-->Đích: 2.1.6a.5 |
| CM1-L17 | CM1-O-ST2 | CM1-O-PL | Link | 2.1.6a.5.1: // checkCoversShowtime (loại phòng, loại ghế, giờ bắt đầu, định dạng, BR-69) (-->) | Nguồn-->Đích: 2.1.6a.5.1 |
| CM1-L18 | CM1-O-AS | CM1-O-ST3 | Link | 2.1.11a.1: // adoptSeatMap (sơ đồ ghế mới, BR-118) (-->) [lặp: mỗi suất chiếu của phòng chưa tới thời điểm mở bán, khi sơ đồ ghế thay đổi] | Nguồn-->Đích: 2.1.11a.1 |
| CM1-L19 | CM1-O-C | CM1-O-C | Link | 1*a.1.1: // discardRequest (không đổi phòng chiếu) (-->) | Nguồn-->Đích: 1*a.1.1 |

## 8. VOPC

File diagrams/P07-class-UC-012.drawio. ID cell của lớp là mã AC; ngăn thuộc tính và ngăn trách nhiệm có ID "<mã AC>-ATTR" và "<mã AC>-RESP".

a) Bảng Node (lớp)

| ID (mã AC) | Loại (Class) | Nhãn (tên lớp) | Stereotype | Thuộc về | Ngăn thuộc tính | Ngăn trách nhiệm |
|---|---|---|---|---|---|---|
| AC-B-ManageAuditoriumsForm | Class | ManageAuditoriumsForm | «boundary» | - | displayedAuditoriumList (Danh sách phòng chiếu đang hiển thị, kèm mốc thay đổi của từng phòng chiếu lúc hiển thị)<br>enteredAuditoriumInfo (Tên, loại phòng, định dạng chiếu được và sơ đồ ghế đã nhập)<br>selectedAuditorium (Phòng chiếu đã chọn để sửa hoặc xoá) | // requestAuditoriumAddition<br>// showAuditoriumList<br>// enterAuditoriumInfo<br>// notifyRefusal<br>// showSavedAuditorium<br>// requestAuditoriumEdit<br>// selectAuditoriumToEdit<br>// showAuditoriumForEdit<br>// requestAuditoriumRemoval<br>// selectAuditoriumToRemove<br>// showRemovalSuccess<br>// cancelRequest |
| AC-C-ManageAuditoriumsController | Class | ManageAuditoriumsController | «control» | - | - | // startAuditoriumAddition<br>// submitAuditorium<br>// startAuditoriumEdit<br>// selectAuditorium<br>// startAuditoriumRemoval<br>// submitAuditoriumRemoval<br>// cancelRequest<br>// discardRequest |
| AC-E-CinemaManager | Class | CinemaManager | «entity» | - | cinema (Cụm rạp của quản lý cụm rạp) | // provideCinema |
| AC-E-Cinema | Class | Cinema | «entity» | - | name (Văn bản) | // provideAuditoriums<br>// checkAuditoriumNameAvailable<br>// addAuditorium<br>// removeAuditorium |
| AC-E-Auditorium | Class | Auditorium | «entity» | - | name (Văn bản)<br>auditoriumType (Văn bản)<br>supportedFormats (Văn bản)<br>seatTypes (Văn bản)<br>cinema (Cụm rạp)<br>lastChangedAt (Ngày giờ) (mới ở UC này) | // provideAuditoriumInfo<br>// createAuditorium<br>// checkAuditoriumInfoValid<br>// calculateCapacity<br>// checkCapacityInRange<br>// checkBelongsToCinema<br>// provideAuditoriumDetail<br>// checkUnchangedSinceDisplayed<br>// checkEditAllowed<br>// checkSeatMapChanged<br>// applyChanges<br>// checkNeverScheduled |
| AC-E-Seat | Class | Seat | «entity» | - | seatPosition (Mã hàng, số ghế) (mới ở UC này)<br>seatType (Văn bản: ghế thường, ghế VIP, ghế đôi) (mới ở UC này) | // createSeat<br>// checkSeatValid<br>// provideSeatInfo |
| AC-E-Showtime | Class | Showtime | «entity» | - | startTime (Ngày giờ)<br>saleOpenTime (Ngày giờ)<br>endTime (Ngày giờ)<br>movieFormat (Văn bản)<br>status (Trạng thái: Trong lịch chiếu, Đã xoá) | // checkBlocksSeatMapEdit<br>// checkStaysPriced<br>// adoptSeatMap |
| AC-E-PriceList | Class | PriceList | «entity» | - | cinema (Cụm rạp) | // checkCoversShowtime |

b) Bảng quan hệ

| ID | Lớp A | Lớp B | Loại | Multiplicity | Vai trò | Nguồn |
|---|---|---|---|---|---|---|
| R-UC012-01 | AC-B-ManageAuditoriumsForm | AC-C-ManageAuditoriumsController | Association | - | - | tạm thời; link F7: CM1-L2 |
| R-UC012-02 | AC-C-ManageAuditoriumsController | AC-E-CinemaManager | Association | - | - | tạm thời; link F7: CM1-L3 |
| R-UC012-03 | AC-C-ManageAuditoriumsController | AC-E-Cinema | Association | - | - | tạm thời; link F7: CM1-L4 |
| R-UC012-04 | AC-C-ManageAuditoriumsController | AC-E-Auditorium | Association | - | - | tạm thời (ba đối tượng Auditorium: phòng dự kiến, phòng đã chọn); link F7: CM1-L6, CM1-L11 |
| R-UC012-05 | AC-E-Cinema | AC-E-Auditorium | Aggregation | A 1 - B 0..* | - | GL-03 "gồm nhiều Phòng chiếu"; cụm rạp mới chưa có phòng (UC-011, Q-212), xoá phòng được (BR-147); thay R-38 của P08 (1..*); link F7: CM1-L5, CM1-L14 |
| R-UC012-06 | AC-E-Auditorium | AC-E-Seat | Composition | A 1 - B 50..400 | - | GL-07, GL-40 "có sơ đồ ghế"; xoá phòng xoá cùng các ghế (luồng 1b3); sức chứa 50 đến 400 (BR-144); Q-253; link F7: CM1-L7, CM1-L12 |
| R-UC012-07 | AC-E-Auditorium | AC-E-Showtime | Association | A 1 - B 0..* | - | GL-47 "trong một Phòng chiếu"; BR-87, BR-73, BR-147 hỏi suất chiếu của phòng; trùng R-UC014-07, P08 R-42; link F7: CM1-L15, CM1-L16, CM1-L18 |
| R-UC012-08 | AC-E-Showtime | AC-E-PriceList | Association | A 0..* - B 1 | - | Giá lấy theo bảng giá của cụm rạp có suất chiếu (BR-11, GL-01); suất chiếu hỏi bảng giá đủ giá (BR-73, BR-69); trùng R-UC013-05, R-UC005-12; link F7: CM1-L17 |
| R-UC012-09 | AC-E-CinemaManager | AC-E-Cinema | Association | A 0..* - B 1 | - | BR-78 "thuộc đúng một cụm rạp", tiền điều kiện UC-012 (REQ-100); thay thuộc tính cinema rút gọn; không có link F7 riêng (xem ghi chú dưới bảng) |

Các lifeline cùng lớp (Auditorium: :Auditorium, phòngMới, phòngChọn; Showtime: chặn, chưaChiếu, chưaMởBán) là các đối tượng của cùng một lớp nên mỗi cặp lớp chỉ một quan hệ. R-UC012-09 (CinemaManager - Cinema) không có link trong F7 vì control nhận cụm rạp từ CinemaManager rồi gửi message tới Cinema; căn cứ là tiền điều kiện của UC-012 (REQ-100) và BR-78. R-UC012-05 là aggregation vì nguồn không có câu về vòng đời phụ thuộc của phòng vào cụm rạp; R-UC012-06 là composition vì xoá phòng chiếu xoá cùng các ghế (luồng 1b3) và sức chứa 50 đến 400 (BR-144, Q-253).

## 9. Ma trận truy vết

| Bước UC | Message (STT) | Lớp tham gia (AC) |
|---|---|---|
| 1 | 1, 1.1 | AC-B-ManageAuditoriumsForm, AC-C-ManageAuditoriumsController |
| 2 | 1.1.1, 1.1.1 (trả về), 1.1.2, 1.1.2.1, 1.1.2.1 (trả về), 1.1.2 (trả về), 1.1.3 | AC-C-ManageAuditoriumsController, AC-E-CinemaManager, AC-E-Cinema, AC-E-Auditorium, AC-B-ManageAuditoriumsForm |
| 3 | 2, 2.1 | AC-B-ManageAuditoriumsForm, AC-C-ManageAuditoriumsController |
| 4 | 2.1.1, 2.1.1.1, 2.1.1.1.1, 2.1.2, 2.1.2 (trả về), 2.1.3, 2.1.3.1, 2.1.3 (trả về) | AC-C-ManageAuditoriumsController, AC-E-Auditorium, AC-E-Seat |
| 5 | 2.1.6, 2.1.6.1, 2.1.6 (trả về), 2.1.6a, 2.1.6a.1, 2.1.6a.2, 2.1.6a.2 (trả về), 2.1.6a.3, 2.1.6a.4, 2.1.6a.4 (trả về), 2.1.6a.5, 2.1.6a.5.1, 2.1.6a.5.1 (trả về), 2.1.6a.5 (trả về), 2.1.6a (trả về), 2.1.11a, 2.1.11a.1, 2.1.11a.1 (trả về), 2.1.11a (trả về) | AC-C-ManageAuditoriumsController, AC-E-Cinema, AC-E-Auditorium, AC-E-Showtime, AC-E-PriceList |
| 6 | 2.1.8, 2.1.8.1, 2.1.8 (trả về), 2.1.9, 2.1.12a, 2.1.12a.1, 2.1.12a (trả về), 2.1.13a | AC-C-ManageAuditoriumsController, AC-E-Auditorium, AC-B-ManageAuditoriumsForm |
| 1a | 1a | AC-B-ManageAuditoriumsForm |
| 1a1 | 1a.1, 1a.1.1, 1a.1.1 (trả về), 1a.1.2, 1a.1.2.1, 1a.1.2.1 (trả về), 1a.1.2 (trả về), 1a.1.3 | AC-B-ManageAuditoriumsForm, AC-C-ManageAuditoriumsController, AC-E-CinemaManager, AC-E-Cinema, AC-E-Auditorium |
| 1a2 | 2a, 2a.1, 2a.1.1, 2a.1.1 (trả về) | AC-B-ManageAuditoriumsForm, AC-C-ManageAuditoriumsController, AC-E-Auditorium |
| 1a3 | 2a.1.2, 2a.1.2.1, 2a.1.2.1 (trả về), 2a.1.2 (trả về), 2a.1.3 | AC-C-ManageAuditoriumsController, AC-E-Auditorium, AC-E-Seat, AC-B-ManageAuditoriumsForm |
| 1b | 1b | AC-B-ManageAuditoriumsForm |
| 1b1 | 1b.1, 1b.1.1, 1b.1.1 (trả về), 1b.1.2, 1b.1.2.1, 1b.1.2.1 (trả về), 1b.1.2 (trả về), 1b.1.3 | AC-B-ManageAuditoriumsForm, AC-C-ManageAuditoriumsController, AC-E-CinemaManager, AC-E-Cinema, AC-E-Auditorium |
| 1b2 | 2b, 2b.1, 2b.1.1, 2b.1.1 (trả về) | AC-B-ManageAuditoriumsForm, AC-C-ManageAuditoriumsController, AC-E-Auditorium |
| 1b3 | 2b.1.2, 2b.1.2.1, 2b.1.2.1 (trả về), 2b.1.2 (trả về) | AC-C-ManageAuditoriumsController, AC-E-Cinema, AC-E-Auditorium |
| 1b3a | 2b.1.3 | AC-C-ManageAuditoriumsController, AC-B-ManageAuditoriumsForm |
| 1b4 | 2b.1.4 | AC-C-ManageAuditoriumsController, AC-B-ManageAuditoriumsForm |
| 4a | 2.1.4 | AC-C-ManageAuditoriumsController, AC-B-ManageAuditoriumsForm |
| 4b | 2.1.5 | AC-C-ManageAuditoriumsController, AC-B-ManageAuditoriumsForm |
| 4d | 2.1.7, 2.1.8a | AC-C-ManageAuditoriumsController, AC-B-ManageAuditoriumsForm |
| 5a | 2.1.9a | AC-C-ManageAuditoriumsController, AC-B-ManageAuditoriumsForm |
| 5b | 2.1.10a | AC-C-ManageAuditoriumsController, AC-B-ManageAuditoriumsForm |
| 5c | 2.1.7a | AC-C-ManageAuditoriumsController, AC-B-ManageAuditoriumsForm |
| *a | 1*a, 1*a.1, 1*a.1.1 | AC-B-ManageAuditoriumsForm, AC-C-ManageAuditoriumsController |

## 10. File .drawio

Ba file nằm trong diagrams/: P07-sequence-UC-012.drawio (8 trang), P07-communication-UC-012.drawio (1 trang), P07-class-UC-012.drawio (1 trang). XML không nén, ID cell trùng ID trong bảng mô hình.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Trạng thái |
| --- | --- | --- | --- | --- |
| Q-245 | Ở bước 4 của luồng thêm, phim chưa tồn tại nhưng thông tin phim cần được kiểm. Phân tích để control tạo "phim dự kiến" (chưa vào danh sách phim) bằng // createMovie, phim dự kiến tự kiểm (// checkMovieInfoValid) rồi tự ghi vào danh sách phim ở bước 5 (// addToMovieList); khi sửa, phim đã chọn tự kiểm thông tin nhập và tự ghi (// saveMovieChanges). Cùng cách cho cụm rạp dự kiến (UC-011) và phòng chiếu dự kiến (UC-012). Có chấp nhận khái niệm phim, cụm rạp, phòng chiếu dự kiến không, hay control kiểm điều kiện hợp lệ trước khi tạo đối tượng? (Chấp nhận, như suất chiếu dự kiến ở Q-102 của UC-014 / Control kiểm rồi mới tạo). Đề xuất: chấp nhận, vì điều kiện hợp lệ là quy tắc thuộc dữ liệu của phim (Information Expert), control chỉ điều phối | AC-E-Movie; AC-E-Cinema; AC-E-Auditorium (// createAuditorium, // checkAuditoriumInfoValid); AC-E-Seat (// createSeat); SD1b message 2.1.1; P08 | P04 bước 4 (kiểm hợp lệ) đứng trước bước 5 (thêm vào cụm rạp) nhưng phòng chiếu mới và các ghế của nó chưa có đối tượng; Q-102 (UC-014) đã chấp nhận khái niệm tương tự | Gộp vào Q-245 (UC-010). Chờ chủ dự án chốt theo đề xuất ở X3 |
| Q-247 | "Kể từ lúc hiển thị" (BR-138, BR-142, BR-146) được so bằng mốc nào? (Mốc thay đổi gần nhất của chính phim, cụm rạp, phòng chiếu (lastChangedAt), như suất chiếu ở UC-014 và mục giá ở UC-013 / Số phiên bản tăng dần). Đề xuất: mốc thay đổi gần nhất của chính đối tượng ở mức phân tích, biểu diễn cụ thể (cột phiên bản hoặc tương đương) do P13 chọn | AC-E-Movie, AC-E-Cinema, AC-E-Auditorium (lastChangedAt, // checkUnchangedSinceDisplayed); SD2b message 2.1.6a.1; P13 | BR-138, BR-142, BR-146 chỉ nêu "đã bị yêu cầu khác sửa kể từ lúc hiển thị", không nêu cách so | Gộp vào Q-247 (UC-010). Chờ chủ dự án chốt theo đề xuất ở X3 |
| Q-249 | Sau khi sửa sơ đồ ghế, suất chiếu chưa mở bán dùng sơ đồ mới (BR-118, Q-210), nghĩa là trạng thái ghế của từng suất chiếu đó phải được tạo cho ghế mới và bỏ cho ghế không còn (P08 Q-109, EX-15). Phân tích để Auditorium gửi message tới từng suất chiếu chưa mở bán của phòng (// adoptSeatMap, trong loop) và Showtime tự cập nhật trạng thái ghế của mình (Showtime nắm SeatStatus, R-44), không vẽ message tới SeatStatus. Có chấp nhận không, hay vẽ thêm SeatStatus ngay ở UC-012? (Showtime cập nhật bên trong // adoptSeatMap / Vẽ message tới từng SeatStatus). Đề xuất: Showtime cập nhật bên trong | AC-E-Showtime (// adoptSeatMap), AC-E-SeatStatus; SD2c message 2.1.11a.1; P08 EX-15 | P04 hậu điều kiện và Mục 8 nêu "suất chiếu chưa mở bán dùng sơ đồ mới" nhưng không bước nào nêu ai cập nhật trạng thái ghế của các suất chiếu đó | Chờ chủ dự án chốt theo đề xuất ở X3 |
| Q-250 | BR-87 cần biết phòng có suất chiếu đã tới thời điểm mở bán mà chưa kết thúc (không kể suất chiếu đã xoá); BR-73 cần biết suất chiếu chưa tới giờ bắt đầu nào của phòng thiếu giá sau khi lưu. Auditorium nắm lịch của phòng nhưng mỗi suất chiếu giữ thời gian của mình. Phân tích giữ như UC-013 Q-98: một :Showtime "tìm được theo điều kiện" trả lời có hoặc không (// checkBlocksSeatMapEdit, // checkStaysPriced), và // checkStaysPriced hỏi bảng giá bằng // checkCoversShowtime của UC-014 với loại phòng, loại ghế sau khi lưu (chưa ghi). Có chấp nhận không, hay Auditorium lặp qua từng suất chiếu của phòng? (Showtime tìm theo điều kiện, một lifeline / Auditorium lặp qua từng suất chiếu rồi hỏi bảng giá). Đề xuất: Showtime tìm theo điều kiện, như UC-013 | AC-E-Showtime (// checkBlocksSeatMapEdit, // checkStaysPriced); AC-E-PriceList (// checkCoversShowtime); SD2b message 2.1.6a.4, 2.1.6a.5; R-UC012-07, R-UC012-08 | BR-87 và BR-73 nêu "có suất chiếu" nhưng không nêu cách duyệt; UC-013 Q-98 đã chấp nhận cách tìm theo điều kiện | Chờ chủ dự án chốt theo đề xuất ở X3 |
| Q-251 | Tên phòng chiếu duy nhất trong cụm rạp (BR-145) được P04 nêu ở bước 4 (luồng 4d), còn thao tác không chia cắt "Thêm phòng chiếu" ghi ở bước 5. Nếu kiểm tên ở bước 4 rồi ghi ở bước 5 thì hai yêu cầu cùng tên có thể cùng qua (M1 quy tắc 1). Phân tích gộp kiểm tên vào thao tác ghi (// addAuditorium của Cinema khi thêm; // checkEditAllowed của Auditorium khi sửa), luồng 4d báo từ chối khi thao tác ghi trả về tên đã thuộc phòng khác. Có chấp nhận không? (Kiểm tên cùng thao tác ghi / Kiểm ở bước 4 như thứ tự bước của P04, chấp nhận hai yêu cầu cùng tên cùng qua). Đề xuất: kiểm cùng thao tác ghi, báo bằng luồng 4d | AC-E-Cinema (// addAuditorium, // checkAuditoriumNameAvailable); AC-E-Auditorium (// checkEditAllowed); SD1c message 2.1.6; SD2b message 2.1.6a.2; luồng 4d | P04 luồng 4d đặt ở bước 4 nhưng bảng Thao tác nguyên tử ghi bước 5; 00-Concurrency.md M1 quy tắc 1 đòi kiểm và ghi cùng thao tác | Chờ chủ dự án chốt theo đề xuất ở X3 |
| Q-252 | Dữ liệu vào 2 và BR-135 yêu cầu phòng chọn ở bước 1a2, 1b2 thuộc cụm rạp của quản lý cụm rạp, nhưng P04 không có luồng khi phòng chọn không thuộc cụm rạp (ví dụ danh sách đã cũ hoặc gửi trực tiếp). Hệ thống xử lý thế nào? (Từ chối và thông báo BR-135, kết thúc thất bại, như Q-105 của UC-014 / Coi là không thể xảy ra vì danh sách chỉ chứa phòng của cụm rạp). Đề xuất: từ chối theo BR-135, kết thúc thất bại; phân tích vẽ message // checkBelongsToCinema ở SD2a, SD3 và ghi luồng ở Đề xuất sửa artifact trước | Luồng 1a2, 1b2; AC-E-Auditorium (// checkBelongsToCinema); SD2a message 2a.1.1; SD3 message 2b.1.1 | P04 Mục 3 không có luồng cho BR-135 tại 1a2, 1b2 | Chờ chủ dự án chốt theo đề xuất ở X3 |
| Q-253 | Sơ đồ ghế là thành phần của phòng chiếu (P02 CAND-38), xoá phòng xoá cùng các ghế (luồng 1b3), sức chứa bằng số ghế và nằm trong khoảng 50 đến 400 (BR-144), nhưng P08 R-39 ghi Aggregation A 1 - B 1..*. Quan hệ Auditorium - Seat là gì? (Composition, A 1 - B 50..400 / Aggregation A 1 - B 1..* như P08). Đề xuất: Composition với B 50..400; ghế bỏ khỏi sơ đồ mà trạng thái ghế của suất chiếu đã kết thúc hoặc đã xoá còn dùng (BR-118) là vấn đề lưu giữ lịch sử, P13 xử lý (xoá mềm), mức phân tích không biểu diễn | R-UC012-06; AC-E-Seat; P08 R-39; P13 seat | P08 R-39 chọn Aggregation theo Q-107 khi chưa có P07 của UC-012; luồng 1b3 và BR-144 là bằng chứng mới | Chờ chủ dự án chốt theo đề xuất ở X3 |
| Q-254 | Khi nhiều điều kiện cùng vi phạm ở bước 5 luồng sửa của UC-012, P04 chỉ nêu 5a kiểm trước 5b; chưa nêu vị trí của 5c (phòng đã bị yêu cầu khác sửa) và 4d (tên phòng đã dùng, kiểm trong thao tác ghi, Q-251). Thứ tự báo thế nào? (5c, 4d, 5a, 5b / 5a, 5b, 5c, 4d). Đề xuất: 5c, 4d, 5a, 5b, vì phòng đã bị yêu cầu khác sửa thì các kiểm tra theo dữ liệu hiển thị cũ không còn ý nghĩa (như BR-60, BR-63) | SD2b alt 5c, 4d, break 5a, break 5b; thứ tự kiểm trong // checkEditAllowed; P04 UC-012 bước 5 | P04 bước 5 nêu "kiểm trước 5b" cho 5a và không nêu thứ tự của 5c, 4d | Chờ chủ dự án chốt theo đề xuất ở X3 |

## Giả định

Không có (chế độ NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P04 | UC-012 luồng 1a2, 1b2, Dữ liệu vào 2 | Điều kiện hợp lệ nêu BR-135 cho phòng chọn nhưng không có luồng khi vi phạm (Q-252) | Bổ sung luồng 1a2a, 1b2a khi có trả lời Q-252, hoặc ghi rõ ở Mục 3 là không thể xảy ra |
| P04 | UC-012 bước 5, luồng 4d, 5a, 5b, 5c | Thứ tự kiểm của 5c và 4d chưa nêu (Q-254); 4d nằm ở bước 4 trong khi kiểm tên và ghi cùng một thao tác ở bước 5 (Q-251) | Ghi thứ tự kiểm ở bước 5 và nêu 4d được kiểm trong thao tác ghi khi có trả lời Q-251, Q-254 |
| P08 | AC-E-Auditorium, AC-E-Cinema, AC-E-Seat, AC-E-Showtime | Ba lớp Tạm (chờ P07 của UC-012, UC-011); UC-012 bổ sung trách nhiệm Cinema (provideAuditoriums, checkAuditoriumNameAvailable, addAuditorium, removeAuditorium), Auditorium (createAuditorium, checkAuditoriumInfoValid, calculateCapacity, checkCapacityInRange, provideAuditoriumDetail, checkUnchangedSinceDisplayed, checkEditAllowed, checkSeatMapChanged, applyChanges, checkNeverScheduled, lastChangedAt), Seat (createSeat, checkSeatValid) và Showtime (checkBlocksSeatMapEdit, checkStaysPriced, adoptSeatMap) | Cập nhật theo _AC-register.UC-012.pending.md khi X3 gộp sổ; đổi trạng thái Tạm sang Hoạt động cho Auditorium, Seat, Cinema |
| P08 | R-38 (Cinema - Auditorium) | R-38 ghi B 1..* nhưng cụm rạp mới chưa có phòng chiếu (UC-011, Q-212) và xoá phòng được (luồng 1b, BR-147), nên số phòng có thể là 0 | Đổi phía Auditorium thành 0..* |
| P08 | R-39 (Auditorium - Seat) | Q-253: xoá phòng xoá cùng các ghế và sức chứa 50 đến 400 (BR-144) | Đổi thành Composition A 1 - B 50..400 khi Q-253 được chốt |
| P08 | EX-15, X-19, X-21, F4b | EX-15 là khung chờ P07: lớp chủ Auditorium đúng; cần khoá thêm tên phòng ở Cinema (BR-145), mốc thay đổi (BR-146) và bỏ suất chiếu đã xoá khỏi BR-87, BR-73 (Q-209). Thêm phòng chiếu và xoá phòng chiếu chưa có đơn vị loại trừ | Xác nhận lại EX-15; thêm đơn vị loại trừ cho thêm phòng (khoá Cinema (X)) và xoá phòng (khoá Cinema (X), Auditorium (X), cặp X với EX-13, EX-15) |
| P07 | UC-005 bước 7, UC-013 luồng 1a3, UC-014 bước 8 và luồng 1b3 | UC-012 là đối thủ của các thao tác này (BR-136, BR-137) và đã có dòng chạy lại trong _sync-log; các file P07 đó chưa ghi đối thủ UC-012 | Khi chạy lại ghi đối thủ UC-012 bước 5 (SD2b, SD2c) và luồng 1b3 (SD3) ở UC-005 bước 7 (đổi loại phòng), UC-013 luồng 1a3 (bỏ giá), UC-014 bước 8 (lập, sửa suất chiếu của phòng) |
| P13 | auditorium, seat, seat_status | BR-145 cần duy nhất (cinema_id, name); BR-118 cần ghế lịch sử cho suất chiếu đã kết thúc; BR-147 cần kiểm trước khi xoá phòng; mốc thay đổi cho BR-146 (Q-247) | Đã nêu ở _sync-log; thêm cột phiên bản hoặc mốc thay đổi cho auditorium |

## Vấn đề còn mở

- Thao tác EX-15 (sửa phòng) gồm hai lời gọi của control tới Auditorium: // checkEditAllowed (SD2b, 2.1.6a) và // applyChanges (SD2c, 2.1.11a), cùng một thao tác không chia cắt. Tách hai lời gọi để mỗi trang không quá 3 fragment ở mức ngoài cùng; P08, P09 coi chúng là một đơn vị loại trừ lấy khoá một lần. Điểm tuần tự là đối tượng Auditorium của phòng (khoá hạng 2 của P08), bao PriceList (S), Showtime của phòng (S) và trạng thái ghế của suất chiếu chưa mở bán (X).
- Điểm tuần tự (M3 mục 2): BR-87, BR-73, BR-146 và loại trừ với UC-014, UC-005, UC-013 khớp với đối tượng Auditorium. BR-145 (tên phòng duy nhất trong cụm rạp) trải qua mọi phòng của cụm nên điểm tuần tự theo từng phòng chưa đủ: thêm phòng dùng Cinema (SD1c), nhưng đổi tên phòng khi sửa (SD2b, 2.1.6a.2 hỏi Cinema) cần khoá thêm Cinema cùng Auditorium. P08 cần lấy khoá Cinema theo hạng thấp hơn Auditorium cho cả thêm, sửa tên và xoá phòng.
- Thao tác xoá phòng (1b3) giữ ở Cinema // removeAuditorium hỏi Auditorium // checkNeverScheduled; loại trừ với UC-014 bước 8 (lập suất chiếu của phòng đang bị xoá, BR-136, BR-147) qua khoá Auditorium. P08 chưa có đơn vị loại trừ này (Đề xuất sửa artifact trước).
- Showtime có thêm 3 trách nhiệm (checkBlocksSeatMapEdit, checkStaysPriced, adoptSeatMap) cạnh 12 của UC-014 và các trách nhiệm của UC-005, UC-008, UC-009, UC-013; P08 theo dõi độ lớn lớp. Auditorium có 12 trách nhiệm trong UC-012 vì là lớp chủ của sơ đồ ghế và của thao tác sửa; không trách nhiệm nào nắm quy tắc tính toán thuộc dữ liệu của entity khác (mỗi điều kiện do lớp nắm dữ liệu trả lời).
- Trạng thái ghế của suất chiếu (SeatStatus) không xuất hiện: Showtime tự cập nhật bên trong // adoptSeatMap (Q-249). Suất chiếu đã kết thúc hoặc đã xoá không được cập nhật (BR-118): ghế bỏ khỏi sơ đồ vẫn được trạng thái ghế cũ tham chiếu nên Seat không bị xoá thật ở mức lưu trữ; P13 đã có đề xuất xoá mềm.
- BR-137 (chốt giá của UC-005 bước 7 với đổi loại phòng): UC-005 P07 đọc loại phòng qua thuộc tính của Showtime; P08 Q-110 đã chuyển sang suy ra từ Auditorium, nên điểm tuần tự của UC-005 bước 7 (khoá Auditorium (S), hạng 2) và của UC-012 (Auditorium (X)) trùng đối tượng, đúng phạm vi.
- ManageAuditoriumsController có 8 trách nhiệm (trong ngưỡng 2-10); số lớp là 8 (trong khoảng 4-12). ManageAuditoriumsForm có 12 trách nhiệm vì ba luồng (thêm, sửa, xoá) có thông báo và hiển thị riêng, đều chỉ giao tiếp với tác nhân, không kiểm quy tắc nghiệp vụ.
- Không có tác nhân thời gian và không có message hẹn mốc (A2): thời điểm mở bán là mốc của UC-005, UC-014, không do UC-012 tạo hay đổi (P04 Mục 8).
- Sơ đồ SD1b dùng chung cho luồng chính và luồng 1a; trang SD1c và SD2b bắt đầu bằng ref tới SD1b, nên ref chép cả nội dung SD1b (không có message bước 1-2). Luồng 1a theo SD2a rồi SD1b, SD2b, SD2c; luồng chính theo SD1a rồi SD1b, SD1c.
