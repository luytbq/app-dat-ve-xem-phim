# P07 - Phân tích use case UC-010 Quản lý phim - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P07 |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | 00-Conventions.md (C10); 00-Concurrency.md (M3); project-profile.md; P04-uc-specs/UC-010-manage-movies.md 1.1; P01-actors.md 1.2; P02-usecases.md 1.9; P03-usecase-model.md 1.2; P05-glossary.md 1.2; P06-supplementary-spec.md 1.4; P04-uc-specs/_BR-register.md; P08-analysis-model.md 1.5 (F3, F4b: AC-E-Movie, EX-13); P07-uc-analysis/UC-005-book-tickets-analysis.md (đầu lô; sổ đăng ký AC: F1, F3.4, F8 b), Câu hỏi mở, Vấn đề còn mở); P07-uc-analysis/UC-014-schedule-showtimes-analysis.md (AC-E-Movie); P07-uc-analysis/UC-013-manage-price-list-analysis.md (mẫu định dạng); _sync-log.md (Đầu vào cho lần chạy lại P07-P13, dòng UC-010); dải mã Q-245 đến Q-254 (đầu lô) |
| Phạm vi | UC-010 |
| Mã Q, ASM cuối đã cấp | Q-247 (Q-245 đến Q-247 cấp ở use case này, chờ chủ dự án chốt theo đề xuất; dải được cấp Q-245 đến Q-254); không có ASM (NGHIEM_NGAT) |

## 1. Bối cảnh use case

| Thuộc tính | Giá trị |
|---|---|
| Mã và tên UC | UC-010 Quản lý phim (Manage Movies) |
| Tác nhân chính | ACT-05 Quản lý chuỗi (Người) |
| Tác nhân phụ | Không có |
| Include (UC) | Không có |
| Được include bởi (UC) | Không có |
| Extend (UC, điểm mở rộng, điều kiện) | Không có |
| Được extend bởi (UC, điểm mở rộng, điều kiện) | Không có |
| Use case liên quan không qua include, extend | UC-014 đọc phim ở bước 5 đến 7 (định dạng phát hành, khoảng chiếu, thời lượng) và lưu suất chiếu ở bước 8, loại trừ với việc lưu phim đã sửa (BR-139, BR-84); UC-003 chỉ đọc danh sách phim theo BR-76 (chưa có P07, không cần loại trừ); UC-005 ghi tên phim lên vé (REQ-105, BR-140) và không đọc lại phim sau khi bán |
| Tác nhân thời gian | Không có. P04 Mục 8 ghi không có bước hẹn hoặc huỷ mốc, và P02 không có use case do tác nhân thời gian kích hoạt trên dữ liệu phim, nên không có message hẹn mốc (A2) |
| File P07 đã có được dùng làm sổ đăng ký AC | UC-005-book-tickets-analysis.md (sổ gốc, trạng thái đầu lô) và UC-014-schedule-showtimes-analysis.md: dùng lại AC-E-Movie (UC-014 ghi "Mới - chạy song song, chờ P08 hợp nhất; chủ sở hữu UC-010"; UC-010 là chủ sở hữu nên bổ sung trách nhiệm và thuộc tính). Phần mới của sổ ghi ở _AC-register.UC-010.pending.md (C10) |

## 2. Đặc tả bổ sung

| Bước UC | Thực hiện bởi | Mô tả trong đặc tả | Mô tả bổ sung (hệ thống làm gì bên trong) | Nguồn (BR, GL, REQ) |
|---|---|---|---|---|
| 1 | Quản lý chuỗi | Yêu cầu thêm phim mới vào danh sách phim của chuỗi. | Không đổi | REQ-53 |
| 2 | Hệ thống | Hiển thị danh sách phim hiện có của chuỗi (xem Dữ liệu ra 1). | Không có đối tượng nắm cả danh sách phim, nên control lấy từng phim của chuỗi và nhận của mỗi phim tên, thể loại, thời lượng, độ tuổi được xem, các định dạng phát hành, ngày khởi chiếu, ngày kết thúc chiếu rồi chuyển cho boundary hiển thị. | GL-37, REQ-07, REQ-55, REQ-95, Q-246 |
| 3 | Quản lý chuỗi | Nhập thông tin phim, chọn các định dạng phát hành, nhập ngày khởi chiếu và ngày kết thúc chiếu rồi gửi (xem Dữ liệu vào 1; BR-134). | Không đổi | BR-134, GL-05 |
| 4 | Hệ thống | Kiểm tra thông tin phim hợp lệ theo điều kiện của Dữ liệu vào 1 (Q-196 đến Q-199). | Control tạo phim dự kiến từ thông tin đã nhập (chưa vào danh sách phim). Phim dự kiến kiểm tên không trống, thời lượng là số nguyên phút lớn hơn 0, độ tuổi là một nhãn trong P, K, T13, T16, T18, C, có một hoặc cả hai định dạng 2D, 3D, hai ngày hợp lệ và ngày kết thúc không trước ngày khởi chiếu. Tên được trùng tên phim khác nên không kiểm trùng. | BR-134, Q-196 đến Q-200, Q-245 |
| 5 | Hệ thống | Kiểm tra, với phim đã chọn ở luồng 1a, phim chưa bị yêu cầu khác sửa kể từ lúc hiển thị, rồi lưu thông tin phim, tất cả là một thao tác không chia cắt; thêm phim mới vào danh sách phim hoặc cập nhật phim đã chọn ở luồng 1a (BR-138; việc lưu xen với UC-014 bước 8: BR-139). | Thêm: phim dự kiến tự ghi vào danh sách phim, cấp mã phim và đặt mốc thay đổi. Sửa: phim đã chọn so mốc thay đổi hiện tại với mốc lúc hiển thị, đạt thì ghi thông tin mới và đặt lại mốc, tất cả trong một thao tác. Suất chiếu đã lập của phim không đổi. | BR-84, BR-138, BR-139, Q-200, Q-201, Q-202, Q-247 |
| 6 | Hệ thống | Thông báo lưu phim thành công và hiển thị phim đã lưu (xem Dữ liệu ra 2). | Control nhận thông tin phim đã lưu từ phim và chuyển cho boundary hiển thị cùng thông báo thành công. | REQ-07, REQ-95 |
| 1a | Quản lý chuỗi | Quản lý chuỗi chọn sửa một phim đã có thay vì thêm phim mới. | Không đổi | REQ-53, EV-12 |
| 1a1 | Hệ thống | Hiển thị danh sách phim của chuỗi (xem Dữ liệu ra 1). | Như bước 2; boundary ghi lại mốc thay đổi của từng phim lúc hiển thị để gửi kèm yêu cầu lưu ở bước 5. | GL-37, BR-138, Q-246 |
| 1a2 | Quản lý chuỗi | Chọn phim cần sửa (xem Dữ liệu vào 2). | Không đổi | REQ-53 |
| 1a3 | Hệ thống | Hiển thị thông tin hiện tại của phim đã chọn để sửa (xem Dữ liệu ra 3). | Control lấy từ phim đã chọn toàn bộ thông tin hiện tại (các trường của Dữ liệu vào 1 kèm mô tả, trailer) và chuyển cho boundary hiển thị. | GL-37 |
| 4a | Hệ thống | Từ chối lưu và thông báo điều kiện bị vi phạm của từng trường (BR-134 với định dạng phát hành). | Phim (dự kiến hoặc đã chọn) báo điều kiện bị vi phạm của từng trường, control chuyển cho boundary thông báo; danh sách phim không đổi, quản lý chuỗi nhập lại ở bước 3. | BR-134, Q-196 đến Q-199 |
| 5a | Hệ thống | Chỉ khi theo luồng 1a: phim đã bị yêu cầu khác sửa kể từ lúc hiển thị. Từ chối lưu, không ghi đè thay đổi trước và thông báo quy tắc bị vi phạm (BR-138). | Phim đã chọn báo mốc thay đổi hiện tại khác mốc lúc hiển thị, không ghi gì; control chuyển lý do cho boundary thông báo, quản lý chuỗi mở lại phim từ bước 1a1. | BR-138, Q-201, Q-247 |
| *a | Hệ thống | Tại bất kỳ bước nào trước bước 5, kể cả trong luồng 1a, quản lý chuỗi huỷ yêu cầu. Huỷ yêu cầu, không thay đổi danh sách phim. | Không có thời hạn; huỷ có thể xảy ra ở mọi bước từ 1 đến 4 và từ 1a đến 1a3. Control bỏ yêu cầu đang xử lý, danh sách phim không bị chạm tới. | P04 Mục 3 luồng *a |

## 3. Tìm lớp phân tích

### 3.1 Bảng boundary

| Tác nhân (ACT) | Loại tác nhân | Boundary | Loại boundary | Mới hoặc tái dùng (AC, UC nguồn) | Lý do |
|---|---|---|---|---|---|
| ACT-05 Quản lý chuỗi | Người | ManageMoviesForm | Giao diện người dùng | Mới (AC-B-ManageMoviesForm) | Quản lý chuỗi xem danh sách phim, nhập thông tin phim, chọn phim cần sửa, huỷ và nhận thông báo kết quả. Một boundary cho cặp tác nhân và use case, không tách theo màn hình |

### 3.2 Bảng lọc danh từ

| STT | Danh từ hoặc cụm danh từ | Vị trí (bước UC, mục dữ liệu, BR) | Kết luận | Lý do |
|---|---|---|---|---|
| 1 | Quản lý chuỗi | Tác nhân chính | Loại - là tác nhân hoặc ngoài phạm vi | Tác nhân ACT-05. Hồ sơ quản lý chuỗi không có hành vi trong use case (không đọc, ghi hay kiểm tra: use case không phân quyền theo cụm rạp, BR-78) nên không là entity |
| 2 | Hệ thống | Các bước hệ thống | Loại - mơ hồ | Chỉ là bên thực hiện bước |
| 3 | Chuỗi | Mô tả ngắn, tiền điều kiện | Loại - là tác nhân hoặc ngoài phạm vi | Tên riêng của tổ chức CineBook (P05), không là thực thể có hành vi; Q-246 |
| 4 | Phim | Bước 2, 5, 1a1, 1a3, BR-134, BR-138 | Entity (AC-E-Movie) | Tái dùng mã của UC-014; có định danh (mã phim), được tạo, sửa và kiểm tra điều kiện hợp lệ (GL-37). Chủ sở hữu UC-010 |
| 5 | Danh sách phim (của chuỗi) | Bước 2, 1a1, Dữ liệu ra 1 | Loại - cấu trúc cài đặt | Kết quả liệt kê các phim; P05 không coi danh sách là khái niệm riêng và không có đối tượng nắm danh sách (Q-246) |
| 6 | Thông tin phim | Bước 3, 4, Dữ liệu vào 1 | Loại - trùng hoặc đồng nghĩa với Movie | Tên chung của các trường của phim (REQ-07), không là khái niệm riêng |
| 7 | Tên phim | Dữ liệu vào 1 trường 1, BR-140 | Loại - thuộc tính của Movie | title; được trùng tên phim khác, phim phân biệt bằng mã phim (Q-200) |
| 8 | Mã phim | Q-200 | Loại - thuộc tính của Movie | movieCode, hệ thống cấp để phân biệt các phim, kể cả phim trùng tên |
| 9 | Thể loại | Dữ liệu vào 1 trường 2 | Loại - thuộc tính của Movie | genre; văn bản không bắt buộc, nguồn không nêu danh mục thể loại (Q-137) |
| 10 | Thời lượng | Dữ liệu vào 1 trường 3, Q-196 | Loại - thuộc tính của Movie | duration; số nguyên phút lớn hơn 0 (REQ-98) |
| 11 | Độ tuổi được xem | Dữ liệu vào 1 trường 4, Q-198 | Loại - thuộc tính của Movie | ageRating; một nhãn trong P, K, T13, T16, T18, C |
| 12 | Mô tả | Dữ liệu vào 1 trường 5 | Loại - thuộc tính của Movie | description; văn bản không bắt buộc |
| 13 | Trailer | Dữ liệu vào 1 trường 6, Q-199 | Loại - thuộc tính của Movie | trailer; đường dẫn dạng văn bản tới video đặt ngoài hệ thống, không có định danh và hành vi riêng |
| 14 | Định dạng phát hành | Bước 3, Dữ liệu vào 1 trường 7, BR-134 | Loại - thuộc tính của Movie | releaseFormats; một hoặc cả hai giá trị 2D, 3D (GL-05) |
| 15 | 2D, 3D | BR-134 | Loại - tham số của quy tắc BR-134 | Giá trị cho phép của định dạng phát hành |
| 16 | Ngày khởi chiếu | Dữ liệu vào 1 trường 8, BR-76 | Loại - thuộc tính của Movie | releaseDate |
| 17 | Ngày kết thúc chiếu | Dữ liệu vào 1 trường 9, BR-76 | Loại - thuộc tính của Movie | endOfRunDate; không trước ngày khởi chiếu, hai ngày bằng nhau là hợp lệ (Q-197) |
| 18 | Phim sắp chiếu, phim đang chiếu | Hậu điều kiện, BR-76 | Loại - giá trị suy ra từ Movie | Suy ra từ ngày khởi chiếu và ngày kết thúc chiếu khi UC-003 cần, không lưu (GL-38, GL-39) |
| 19 | Mốc thay đổi lúc hiển thị | Bước 5, 5a, BR-138 | Loại - thuộc tính của Movie | lastChangedAt; so với mốc hiện tại để biết phim đã bị sửa (Q-247) |
| 20 | Yêu cầu khác (sửa cùng phim) | Bước 5, 5a, BR-138 | Loại - thao tác hoặc sự kiện | Một lần lưu phim khác; hệ quả được so bằng mốc thay đổi |
| 21 | Thao tác không chia cắt | Bước 5, BR-138, BR-139 | Loại - thao tác hoặc sự kiện | Cách thực hiện, giao cho Movie // saveMovieChanges |
| 22 | Suất chiếu | Hậu điều kiện, BR-84, BR-139 | Loại - không tham gia hành vi của use case này (khái niệm của UC-014) | UC-010 không đọc hay ghi suất chiếu; suất chiếu đã lập không đổi vì use case không chạm tới (BR-84) |
| 23 | Vé, tên phim ghi trên vé | Mục 8, BR-140 | Loại - không tham gia hành vi của use case này (khái niệm của UC-005) | Vé giữ tên phim lúc bán, use case không đọc vé |
| 24 | Lịch sử đặt vé, email đã gửi | BR-140 | Loại - không tham gia hành vi của use case này (khái niệm của UC-005, UC-007) | Chỉ được nhắc tới để nói sửa tên phim không đổi chúng |
| 25 | Khách (tra cứu phim) | Mục 8 | Loại - không tham gia hành vi của use case này (khái niệm của UC-003) | UC-003 đọc danh sách phim, không cần loại trừ |
| 26 | Thông báo, điều kiện vi phạm, quy tắc bị vi phạm | Bước 6, 4a, 5a | Loại - dữ liệu trao đổi qua boundary ManageMoviesForm | Không lưu |
| 27 | Phiên làm việc | Tiền điều kiện | Loại - là tác nhân hoặc ngoài phạm vi | Đăng nhập không mô hình hoá (project-profile mục 4) |
| 28 | Số nguyên phút, giá trị tối đa | Dữ liệu vào 1 trường 3 | Loại - tham số của quy tắc Q-196 | Điều kiện hợp lệ của thời lượng, không có giá trị tối đa |
| 29 | Kết quả | Bước 6 | Loại - mơ hồ | Chỉ là thông báo thành công hoặc thất bại, đã tính ở dòng thông báo |

### 3.3 Bảng control

| Control | Use case điều phối | Mới hoặc tái dùng | Lý do (hoặc lý do không có control) |
|---|---|---|---|
| ManageMoviesController | UC-010 | Mới (AC-C-ManageMoviesController) | Một control cho use case: nhận yêu cầu từ boundary, điều phối hiển thị danh sách phim, tạo phim dự kiến, kiểm hợp lệ, lưu, báo kết quả. Quy tắc về điều kiện hợp lệ, mốc thay đổi và ghi phim nằm ở entity Movie. Có 7 trách nhiệm |

### 3.4 Bảng lớp phân tích

| AC | Stereotype | Tên | Trách nhiệm | Thuộc tính chính | Bước UC nguồn | Loại boundary | Mới hoặc tái dùng | GL |
|---|---|---|---|---|---|---|---|---|
| AC-B-ManageMoviesForm | boundary | ManageMoviesForm | // requestMovieAddition: quản lý chuỗi yêu cầu thêm phim mới<br>// showMovieList: hiển thị danh sách phim của chuỗi, giữ mốc thay đổi của từng phim lúc hiển thị<br>// enterMovieInfo: quản lý chuỗi nhập thông tin phim, chọn định dạng phát hành, nhập hai ngày rồi gửi<br>// notifyRefusal: thông báo từ chối kèm điều kiện hoặc quy tắc bị vi phạm<br>// showSavedMovie: thông báo lưu phim thành công và hiển thị phim đã lưu<br>// requestMovieEdit: quản lý chuỗi chọn sửa một phim đã có thay vì thêm phim mới<br>// selectMovieToEdit: quản lý chuỗi chọn phim cần sửa<br>// showMovieForEdit: hiển thị thông tin hiện tại của phim đã chọn để sửa<br>// cancelRequest: quản lý chuỗi huỷ yêu cầu | displayedMovieList (Danh sách phim đang hiển thị, kèm mốc thay đổi của từng phim lúc hiển thị)<br>enteredMovieInfo (Thông tin phim, định dạng phát hành và hai ngày đã nhập)<br>selectedMovie (Phim đã chọn để sửa) | 1, 2, 3, 6, 1a, 1a1, 1a2, 1a3, 4a, 5a, *a | Giao diện người dùng | Mới | GL-41 |
| AC-C-ManageMoviesController | control | ManageMoviesController | // startMovieAddition: điều phối bước 1 và 2: lấy từng phim của chuỗi để hiển thị<br>// submitMovie: điều phối bước 4 đến 6 của luồng chính: tạo phim dự kiến, kiểm hợp lệ, ghi vào danh sách phim, báo kết quả<br>// startMovieEdit: điều phối bước 1a1: lấy từng phim của chuỗi để hiển thị<br>// selectMovie: điều phối bước 1a2 và 1a3: lấy thông tin hiện tại của phim đã chọn để hiển thị<br>// submitMovieChanges: điều phối bước 4 đến 6 của luồng 1a: kiểm hợp lệ, lưu thay đổi, báo kết quả<br>// cancelRequest: điều phối luồng *a: huỷ yêu cầu<br>// discardRequest: bỏ yêu cầu đang xử lý, không đổi danh sách phim (luồng *a) | - | 1, 2, 3, 4, 5, 6, 1a1, 1a2, 1a3, 4a, 5a, *a | - | Mới | - |
| AC-E-Movie | entity | Movie | // provideMovieInfo: cung cấp tên, thể loại, thời lượng, độ tuổi được xem, các định dạng phát hành, ngày khởi chiếu, ngày kết thúc chiếu, mô tả, trailer và mốc thay đổi để hiển thị (UC-010 bổ sung thể loại, độ tuổi được xem, mô tả, trailer, mốc thay đổi vào nội dung đã có của UC-014)<br>// createMovie: khởi tạo phim dự kiến từ thông tin phim đã nhập, chưa vào danh sách phim (Q-245)<br>// checkMovieInfoValid: kiểm tra thông tin phim theo điều kiện hợp lệ của Dữ liệu vào 1 và trả về điều kiện bị vi phạm của từng trường (BR-134, Q-196 đến Q-199)<br>// addToMovieList: ghi phim dự kiến vào danh sách phim của chuỗi, cấp mã phim và đặt mốc thay đổi; tên được trùng tên phim khác (Q-200)<br>// saveMovieChanges: thao tác không chia cắt: kiểm phim chưa bị sửa kể từ lúc hiển thị, rồi ghi thông tin mới và đặt lại mốc thay đổi; suất chiếu đã lập không đổi (BR-84, BR-138, BR-139)<br>// checkUnchangedSinceDisplayed: kiểm tra phim chưa bị yêu cầu khác sửa kể từ lúc hiển thị bằng cách so mốc thay đổi hiện tại với mốc lúc hiển thị (BR-138, Q-247) | title (Văn bản)<br>releaseFormats (Văn bản)<br>duration (Số phút)<br>releaseDate (Ngày)<br>endOfRunDate (Ngày)<br>movieCode (Mã phim, hệ thống cấp, phân biệt các phim kể cả phim trùng tên) (mới ở UC này)<br>genre (Văn bản) (mới ở UC này)<br>ageRating (Nhãn: P, K, T13, T16, T18, C) (mới ở UC này)<br>description (Văn bản) (mới ở UC này)<br>trailer (Văn bản, đường dẫn tới video ngoài hệ thống) (mới ở UC này)<br>lastChangedAt (Ngày giờ) (mới ở UC này) | 2, 4, 5, 1a1, 1a3 | - | Tái dùng từ UC-014, bổ sung trách nhiệm | GL-37, GL-05 |

Tổng cộng 3 lớp: 1 boundary, 1 control, 1 entity (dưới ngưỡng 4, lý do ở Vấn đề còn mở). Entity cốt lõi của chủ đề race condition: AC-E-Movie (loại trừ giữa hai yêu cầu cùng sửa một phim: BR-138; giữa lưu phim và UC-014 bước 8: BR-139). Phần mới của sổ trách nhiệm ghi ở _AC-register.UC-010.pending.md (C10); Bảng 2 của sổ không có dòng mới vì mọi điều kiện của UC-010 chỉ dùng ở một use case.

## 4. Phân bổ hành vi

| Bước UC | Trách nhiệm | Lớp nhận (AC) | Nguyên tắc | Lý do khi có lựa chọn khác |
|---|---|---|---|---|
| 1 | // requestMovieAddition | AC-B-ManageMoviesForm | Giao tiếp tác nhân | - |
| 1 | // startMovieAddition | AC-C-ManageMoviesController | Controller | - |
| 2 | // provideMovieInfo | AC-E-Movie | Information Expert | Thông tin phim nằm ở phim. Không có đối tượng toàn thể nắm danh sách phim (Q-246) nên control lặp, mỗi lượt hỏi một phim; giao cho control giữ dữ liệu phim thì control thành nơi chứa dữ liệu nghiệp vụ |
| 2 | // showMovieList | AC-B-ManageMoviesForm | Giao tiếp tác nhân | - |
| 3 | // enterMovieInfo | AC-B-ManageMoviesForm | Giao tiếp tác nhân | - |
| 3 | // submitMovie | AC-C-ManageMoviesController | Controller | - |
| 3 | // submitMovieChanges | AC-C-ManageMoviesController | Controller | - |
| 4 | // createMovie | AC-E-Movie | Creator | Control có dữ liệu khởi tạo và không có đối tượng chứa danh sách phim (Q-246); tạo phim dự kiến rồi để phim tự kiểm (Q-245). Kiểm bằng control rồi mới tạo thì quy tắc thuộc dữ liệu của phim nằm ở control (god control) |
| 4 | // checkMovieInfoValid | AC-E-Movie | Information Expert | Điều kiện hợp lệ là quy tắc về giá trị của chính các trường phim (BR-134, độ dài, miền giá trị, quan hệ giữa hai ngày); giao cho control là để quy tắc dữ liệu ở control. Boundary chỉ kiểm bắt buộc nhập, không kiểm quy tắc nghiệp vụ |
| 5 | // addToMovieList | AC-E-Movie | Information Expert | Phim dự kiến biết mọi trường của mình nên tự cấp mã phim và đặt mốc thay đổi khi vào danh sách; Q-246 không có đối tượng toàn thể để giao việc ghi vào danh sách |
| 5 | // saveMovieChanges | AC-E-Movie | Information Expert | Mốc thay đổi và thông tin phim nằm ở phim đã chọn; kiểm mốc rồi ghi thông tin phải là một thao tác (BR-138), nên cùng nằm trong phim. Giao cho control thì kiểm và ghi tách rời, vi phạm thao tác không chia cắt |
| 5 | // checkUnchangedSinceDisplayed | AC-E-Movie | Information Expert | Mốc thay đổi nằm ở phim; điều kiện phim chưa bị sửa kể từ lúc hiển thị chỉ định nghĩa ở phim |
| 6 | // showSavedMovie | AC-B-ManageMoviesForm | Giao tiếp tác nhân | - |
| 1a | // requestMovieEdit | AC-B-ManageMoviesForm | Giao tiếp tác nhân | - |
| 1a1 | // startMovieEdit | AC-C-ManageMoviesController | Controller | - |
| 1a1 | // provideMovieInfo | AC-E-Movie | Information Expert | Như bước 2 |
| 1a1 | // showMovieList | AC-B-ManageMoviesForm | Giao tiếp tác nhân | - |
| 1a2 | // selectMovieToEdit | AC-B-ManageMoviesForm | Giao tiếp tác nhân | - |
| 1a2 | // selectMovie | AC-C-ManageMoviesController | Controller | - |
| 1a3 | // provideMovieInfo | AC-E-Movie | Information Expert | Như bước 2 |
| 1a3 | // showMovieForEdit | AC-B-ManageMoviesForm | Giao tiếp tác nhân | - |
| 4a | // notifyRefusal | AC-B-ManageMoviesForm | Giao tiếp tác nhân | - |
| 5a | // notifyRefusal | AC-B-ManageMoviesForm | Giao tiếp tác nhân | - |
| *a | // cancelRequest | AC-B-ManageMoviesForm | Giao tiếp tác nhân / Controller | - |
| *a | // cancelRequest | AC-C-ManageMoviesController | Giao tiếp tác nhân / Controller | - |
| *a | // discardRequest | AC-C-ManageMoviesController | Controller | Control chỉ bỏ yêu cầu, không giữ dữ liệu nghiệp vụ nên không có lựa chọn khác |

Thao tác không chia cắt theo bảng "Thao tác nguyên tử" của P04 Mục 8 (00-Concurrency.md M3 mục 1):

| Thao tác (P04 Mục 8) | Bước | Lớp điều phối | Lớp tham gia | Điểm tuần tự (M3 mục 2) |
|---|---|---|---|---|
| Lưu phim (thêm hoặc sửa) | 5 | AC-C-ManageMoviesController (message 2.1.4 của SD1 và 3a.1.3 của SD2) | AC-E-Movie (phim dự kiến khi thêm, phim đã chọn khi sửa) | Chính đối tượng Movie theo mã phim. Bất biến "hai yêu cầu cùng sửa một phim không xen vào nhau" (BR-138) và loại trừ với UC-014 bước 8 đọc phim (BR-139) cùng tập là một phim, nên điểm tuần tự theo từng phim đủ phạm vi |
| Thêm phim | 5 | AC-C-ManageMoviesController (message 2.1.4 của SD1) | AC-E-Movie (phim dự kiến) | Không có bất biến chung vì tên được trùng (Q-200): hai yêu cầu thêm phim cùng lúc đều thành công, không cần điểm tuần tự |

## 5. Sequence diagram phân tích

File diagrams/P07-sequence-UC-010.drawio có 3 trang. Cả ba trang dưới ngưỡng 30 message và 3 fragment ở mức ngoài cùng. Luồng 4a và 5a quay lại bước trước nên dùng alt, không dùng break; luồng *a ở trang riêng.

### a) SD1 - Luồng chính, 4a

Luồng thêm phim. Luồng 4a là alt quay lại bước 3: toán hạng luồng chính chỉ ghi guard và note. Bước 2 liệt kê từng phim của chuỗi trong loop vì không có đối tượng nắm cả danh sách phim (Q-246); phim mới chưa tồn tại ở bước 4 nên control tạo phim dự kiến (Q-245) rồi hỏi phim dự kiến kiểm hợp lệ, sau đó ghi vào danh sách phim ở bước 5. Trang có 2 fragment, dưới ngưỡng 30 message.

b) Bảng Node

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1-L-A5 | Actor | :Quản lý chuỗi | - | - | Tác nhân (ACT-05) |
| SD1-L-PF | Lifeline | :ManageMoviesForm | «boundary» | - | AC-B-ManageMoviesForm |
| SD1-L-C | Lifeline | :ManageMoviesController | «control» | - | AC-C-ManageMoviesController |
| SD1-L-ML | Lifeline | :Movie | «entity» | - | AC-E-Movie; mỗi phim của chuỗi khi liệt kê |
| SD1-L-MN | Lifeline | phimMới:Movie | «entity» | - | AC-E-Movie; phim dự kiến chưa vào danh sách phim (Q-245) |
| SD1-F1 | Fragment | loop [mỗi phim của chuỗi] | - | - | Bao các message của fragment |
| SD1-F2 | Fragment | alt [thông tin phim không đạt điều kiện hợp lệ (4a)] | - | - | Bao các message của fragment |
| SD1-F2-O2 | Fragment | [thông tin phim hợp lệ] | - | SD1-F2 | Toán hạng thứ 2; đường ngăn là edge SD1-F2-O2-SEP nét đứt |
| SD1-N1 | Note | quay lại bước 3 | - | - | Chú thích |
| SD1-N2 | Note | tiếp tục luồng chính | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1 | :Quản lý chuỗi | :ManageMoviesForm | // requestMovieAddition | Đồng bộ | - | 1 |
| 1.1 | :ManageMoviesForm | :ManageMoviesController | // startMovieAddition | Đồng bộ | - | 1 |
| 1.1.1 | :ManageMoviesController | :Movie | // provideMovieInfo | Đồng bộ | SD1-F1 | 2 |
| 1.1.1 (trả về) | :Movie | :ManageMoviesController | thông tin phim, mốc thay đổi | Trả về | SD1-F1 | 2 |
| 1.1.2 | :ManageMoviesController | :ManageMoviesForm | // showMovieList (danh sách phim) | Đồng bộ | - | 2 |
| 2 | :Quản lý chuỗi | :ManageMoviesForm | // enterMovieInfo (thông tin phim, định dạng phát hành, ngày khởi chiếu, ngày kết thúc chiếu) | Đồng bộ | - | 3 |
| 2.1 | :ManageMoviesForm | :ManageMoviesController | // submitMovie (thông tin phim) | Đồng bộ | - | 3 |
| 2.1.1 | :ManageMoviesController | phimMới:Movie | «create» // createMovie (thông tin phim đã nhập) | Tạo | - | 4 |
| 2.1.2 | :ManageMoviesController | phimMới:Movie | // checkMovieInfoValid (BR-134) | Đồng bộ | - | 4 |
| 2.1.2 (trả về) | phimMới:Movie | :ManageMoviesController | thông tin hợp lệ hoặc điều kiện bị vi phạm của từng trường | Trả về | - | 4 |
| 2.1.3 | :ManageMoviesController | :ManageMoviesForm | // notifyRefusal (điều kiện bị vi phạm của từng trường, BR-134) | Đồng bộ | SD1-F2 | 4a |
| 2.1.4 | :ManageMoviesController | phimMới:Movie | // addToMovieList | Đồng bộ | - | 5 |
| 2.1.4 (trả về) | phimMới:Movie | :ManageMoviesController | phim đã lưu | Trả về | - | 5 |
| 2.1.5 | :ManageMoviesController | :ManageMoviesForm | // showSavedMovie (phim đã lưu) | Đồng bộ | - | 6 |

### a) SD2 - Luồng 1a, 4a, 5a

Luồng sửa phim, trang riêng vì rẽ ngay từ bước 1; STT dùng hậu tố a (1a, 2a, 3a). Sau 1a3 quay lại bước 3, bước 3 đến 6 vẽ tiếp trên cùng trang vì phim đã chọn tự kiểm tra và tự ghi (không cần phim dự kiến). Luồng 4a và 5a cùng quay lại (bước 3 và 1a1) nên dùng alt; 5a không kết thúc use case. Message 3a.1.3.1 chạy bên trong 3a.1.3, kết quả kiểm trả về cùng 3a.1.3. Trang có 3 fragment.

b) Bảng Node

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD2-L-A5 | Actor | :Quản lý chuỗi | - | - | Tác nhân (ACT-05) |
| SD2-L-PF | Lifeline | :ManageMoviesForm | «boundary» | - | AC-B-ManageMoviesForm |
| SD2-L-C | Lifeline | :ManageMoviesController | «control» | - | AC-C-ManageMoviesController |
| SD2-L-ML | Lifeline | :Movie | «entity» | - | AC-E-Movie; mỗi phim của chuỗi khi liệt kê |
| SD2-L-MS | Lifeline | phimChọn:Movie | «entity» | - | AC-E-Movie; phim đã chọn để sửa ở luồng 1a |
| SD2-F1 | Fragment | loop [mỗi phim của chuỗi] | - | - | Bao các message của fragment |
| SD2-F2 | Fragment | alt [thông tin phim không đạt điều kiện hợp lệ (4a)] | - | - | Bao các message của fragment |
| SD2-F2-O2 | Fragment | [thông tin phim hợp lệ] | - | SD2-F2 | Toán hạng thứ 2; đường ngăn là edge SD2-F2-O2-SEP nét đứt |
| SD2-F3 | Fragment | alt [phim đã bị yêu cầu khác sửa kể từ lúc hiển thị (5a)] | - | - | Bao các message của fragment |
| SD2-F3-O2 | Fragment | [phim chưa bị sửa kể từ lúc hiển thị] | - | SD2-F3 | Toán hạng thứ 2; đường ngăn là edge SD2-F3-O2-SEP nét đứt |
| SD2-N1 | Note | quay lại bước 3 | - | - | Chú thích |
| SD2-N2 | Note | quay lại bước 1a1 | - | - | Chú thích |
| SD2-N3 | Note | tiếp tục luồng 1a | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1a | :Quản lý chuỗi | :ManageMoviesForm | // requestMovieEdit | Đồng bộ | - | 1a |
| 1a.1 | :ManageMoviesForm | :ManageMoviesController | // startMovieEdit | Đồng bộ | - | 1a1 |
| 1a.1.1 | :ManageMoviesController | :Movie | // provideMovieInfo | Đồng bộ | SD2-F1 | 1a1 |
| 1a.1.1 (trả về) | :Movie | :ManageMoviesController | thông tin phim, mốc thay đổi | Trả về | SD2-F1 | 1a1 |
| 1a.1.2 | :ManageMoviesController | :ManageMoviesForm | // showMovieList (danh sách phim, mốc thay đổi lúc hiển thị) | Đồng bộ | - | 1a1 |
| 2a | :Quản lý chuỗi | :ManageMoviesForm | // selectMovieToEdit (phim cần sửa) | Đồng bộ | - | 1a2 |
| 2a.1 | :ManageMoviesForm | :ManageMoviesController | // selectMovie (phim đã chọn) | Đồng bộ | - | 1a2 |
| 2a.1.1 | :ManageMoviesController | phimChọn:Movie | // provideMovieInfo (phim đã chọn) | Đồng bộ | - | 1a3 |
| 2a.1.1 (trả về) | phimChọn:Movie | :ManageMoviesController | thông tin hiện tại của phim | Trả về | - | 1a3 |
| 2a.1.2 | :ManageMoviesController | :ManageMoviesForm | // showMovieForEdit (thông tin hiện tại của phim) | Đồng bộ | - | 1a3 |
| 3a | :Quản lý chuỗi | :ManageMoviesForm | // enterMovieInfo (thông tin phim đã sửa) | Đồng bộ | - | 3 |
| 3a.1 | :ManageMoviesForm | :ManageMoviesController | // submitMovieChanges (thông tin phim, mốc thay đổi lúc hiển thị) | Đồng bộ | - | 3 |
| 3a.1.1 | :ManageMoviesController | phimChọn:Movie | // checkMovieInfoValid (thông tin phim đã sửa, BR-134) | Đồng bộ | - | 4 |
| 3a.1.1 (trả về) | phimChọn:Movie | :ManageMoviesController | thông tin hợp lệ hoặc điều kiện bị vi phạm của từng trường | Trả về | - | 4 |
| 3a.1.2 | :ManageMoviesController | :ManageMoviesForm | // notifyRefusal (điều kiện bị vi phạm của từng trường, BR-134) | Đồng bộ | SD2-F2 | 4a |
| 3a.1.3 | :ManageMoviesController | phimChọn:Movie | // saveMovieChanges (thông tin phim đã sửa, mốc thay đổi lúc hiển thị) | Đồng bộ | - | 5 |
| 3a.1.3.1 | phimChọn:Movie | phimChọn:Movie | // checkUnchangedSinceDisplayed (mốc thay đổi lúc hiển thị, BR-138) | Tự gọi | - | 5 |
| 3a.1.3 (trả về) | phimChọn:Movie | :ManageMoviesController | phim đã lưu, hoặc kết quả phim đã bị yêu cầu khác sửa | Trả về | - | 5 |
| 3a.1.4 | :ManageMoviesController | :ManageMoviesForm | // notifyRefusal (phim đã bị sửa, mở lại phim từ đầu, BR-138) | Đồng bộ | SD2-F3 | 5a |
| 3a.1.5 | :ManageMoviesController | :ManageMoviesForm | // showSavedMovie (phim đã lưu) | Đồng bộ | - | 6 |

### a) SD3 - Luồng *a

Trang riêng theo A2 và F5 c): bắt đầu bằng ref tới SD1 và SD2, note nêu khoảng message có thể xảy ra, STT lấy message đầu khoảng kèm mã luồng (1*a). Không có break vì huỷ có thể xảy ra tại nhiều điểm; không có message hoàn tác vì danh sách phim chưa bị ghi.

b) Bảng Node

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD3-L-A5 | Actor | :Quản lý chuỗi | - | - | Tác nhân (ACT-05) |
| SD3-L-PF | Lifeline | :ManageMoviesForm | «boundary» | - | AC-B-ManageMoviesForm |
| SD3-L-C | Lifeline | :ManageMoviesController | «control» | - | AC-C-ManageMoviesController |
| SD3-R1 | Fragment | ref SD1 - Luồng chính, 4a | - | - | ref, đặt ở mức ngoài cùng |
| SD3-R2 | Fragment | ref SD2 - Luồng 1a, 4a, 5a | - | - | ref, đặt ở mức ngoài cùng |
| SD3-N1 | Note | có thể xảy ra tại bất kỳ message nào từ 1 đến 2.1.3 của SD1 và từ 1a đến 3a.1.2 của SD2 (trước bước 5) | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1*a | :Quản lý chuỗi | :ManageMoviesForm | // cancelRequest | Đồng bộ | - | *a |
| 1*a.1 | :ManageMoviesForm | :ManageMoviesController | // cancelRequest | Đồng bộ | - | *a |
| 1*a.1.1 | :ManageMoviesController | :ManageMoviesController | // discardRequest (không đổi danh sách phim) | Tự gọi | - | *a |

## 6. Quy tắc tương tác giữa các lớp phân tích

| Vi phạm | Message hoặc link | Cách sửa đã áp dụng |
|---|---|---|
| Không có | - | - |

Đã kiểm: actor chỉ gửi message tới ManageMoviesForm; ManageMoviesForm chỉ gửi tới ManageMoviesController; ManageMoviesController gọi Movie và ManageMoviesForm; Movie chỉ gọi chính nó (3a.1.3.1). Không lifeline nào đại diện cho một tập: loop 1.1.1 và 1a.1.1 gửi message tới từng phim, mỗi lượt một đối tượng.

## 7. Communication diagram

File diagrams/P07-communication-UC-010.drawio có 1 trang CM1 cho mọi luồng (MUC_CHI_TIET là DAY_DU): luồng chính, 4a (SD1), 1a, 4a, 5a (SD2) và *a (SD3), giữ nguyên STT của sequence diagram. Message trả về không vẽ. Link tự nối của phimChọn:Movie và ManageMoviesController không sinh quan hệ VOPC. Guard của fragment ghi trong ngoặc vuông cuối message.

### Trang CM1 - Mọi luồng

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| CM1-O-A5 | Actor | :Quản lý chuỗi | - | - | Tác nhân (ACT-05) |
| CM1-O-PF | Object | :ManageMoviesForm | «boundary» | - | AC-B-ManageMoviesForm |
| CM1-O-C | Object | :ManageMoviesController | «control» | - | AC-C-ManageMoviesController |
| CM1-O-ML | Object | :Movie | «entity» | - | AC-E-Movie; mỗi phim của chuỗi khi liệt kê |
| CM1-O-MN | Object | phimMới:Movie | «entity» | - | AC-E-Movie; phim dự kiến chưa vào danh sách phim (Q-245) |
| CM1-O-MS | Object | phimChọn:Movie | «entity» | - | AC-E-Movie; phim đã chọn để sửa ở luồng 1a |

b) Bảng Edge

| ID | Nguồn | Đích | Loại | Nhãn | Chiều message |
|---|---|---|---|---|---|
| CM1-L1 | CM1-O-A5 | CM1-O-PF | Link | 1: // requestMovieAddition (-->)<br>2: // enterMovieInfo (thông tin phim, định dạng phát hành, ngày khởi chiếu, ngày kết thúc chiếu) (-->)<br>1a: // requestMovieEdit (-->)<br>2a: // selectMovieToEdit (phim cần sửa) (-->)<br>3a: // enterMovieInfo (thông tin phim đã sửa) (-->)<br>1*a: // cancelRequest (-->) | Nguồn-->Đích: 1, 2, 1a, 2a, 3a, 1*a |
| CM1-L2 | CM1-O-PF | CM1-O-C | Link | 1.1: // startMovieAddition (-->)<br>1.1.2: // showMovieList (danh sách phim) (<--)<br>2.1: // submitMovie (thông tin phim) (-->)<br>2.1.3: // notifyRefusal (điều kiện bị vi phạm của từng trường, BR-134) (<--) [thông tin phim không đạt điều kiện hợp lệ (4a)]<br>2.1.5: // showSavedMovie (phim đã lưu) (<--)<br>1a.1: // startMovieEdit (-->)<br>1a.1.2: // showMovieList (danh sách phim, mốc thay đổi lúc hiển thị) (<--)<br>2a.1: // selectMovie (phim đã chọn) (-->)<br>2a.1.2: // showMovieForEdit (thông tin hiện tại của phim) (<--)<br>3a.1: // submitMovieChanges (thông tin phim, mốc thay đổi lúc hiển thị) (-->)<br>3a.1.2: // notifyRefusal (điều kiện bị vi phạm của từng trường, BR-134) (<--) [thông tin phim không đạt điều kiện hợp lệ (4a)]<br>3a.1.4: // notifyRefusal (phim đã bị sửa, mở lại phim từ đầu, BR-138) (<--) [phim đã bị yêu cầu khác sửa kể từ lúc hiển thị (5a)]<br>3a.1.5: // showSavedMovie (phim đã lưu) (<--)<br>1*a.1: // cancelRequest (-->) | Nguồn-->Đích: 1.1, 2.1, 1a.1, 2a.1, 3a.1, 1*a.1; Đích-->Nguồn: 1.1.2, 2.1.3, 2.1.5, 1a.1.2, 2a.1.2, 3a.1.2, 3a.1.4, 3a.1.5 |
| CM1-L3 | CM1-O-C | CM1-O-ML | Link | 1.1.1: // provideMovieInfo (-->) [lặp: mỗi phim của chuỗi]<br>1a.1.1: // provideMovieInfo (-->) [lặp: mỗi phim của chuỗi] | Nguồn-->Đích: 1.1.1, 1a.1.1 |
| CM1-L4 | CM1-O-C | CM1-O-MN | Link | 2.1.1: «create» // createMovie (thông tin phim đã nhập) (-->)<br>2.1.2: // checkMovieInfoValid (BR-134) (-->)<br>2.1.4: // addToMovieList (-->) | Nguồn-->Đích: 2.1.1, 2.1.2, 2.1.4 |
| CM1-L5 | CM1-O-C | CM1-O-MS | Link | 2a.1.1: // provideMovieInfo (phim đã chọn) (-->)<br>3a.1.1: // checkMovieInfoValid (thông tin phim đã sửa, BR-134) (-->)<br>3a.1.3: // saveMovieChanges (thông tin phim đã sửa, mốc thay đổi lúc hiển thị) (-->) | Nguồn-->Đích: 2a.1.1, 3a.1.1, 3a.1.3 |
| CM1-L6 | CM1-O-MS | CM1-O-MS | Link | 3a.1.3.1: // checkUnchangedSinceDisplayed (mốc thay đổi lúc hiển thị, BR-138) (-->) | Nguồn-->Đích: 3a.1.3.1 |
| CM1-L7 | CM1-O-C | CM1-O-C | Link | 1*a.1.1: // discardRequest (không đổi danh sách phim) (-->) | Nguồn-->Đích: 1*a.1.1 |

## 8. VOPC

File diagrams/P07-class-UC-010.drawio. ID cell của lớp là mã AC; ngăn thuộc tính và ngăn trách nhiệm có ID "<mã AC>-ATTR" và "<mã AC>-RESP".

a) Bảng Node (lớp)

| ID (mã AC) | Loại (Class) | Nhãn (tên lớp) | Stereotype | Thuộc về | Ngăn thuộc tính | Ngăn trách nhiệm |
|---|---|---|---|---|---|---|
| AC-B-ManageMoviesForm | Class | ManageMoviesForm | «boundary» | - | displayedMovieList (Danh sách phim đang hiển thị, kèm mốc thay đổi của từng phim lúc hiển thị)<br>enteredMovieInfo (Thông tin phim, định dạng phát hành và hai ngày đã nhập)<br>selectedMovie (Phim đã chọn để sửa) | // requestMovieAddition<br>// showMovieList<br>// enterMovieInfo<br>// notifyRefusal<br>// showSavedMovie<br>// requestMovieEdit<br>// selectMovieToEdit<br>// showMovieForEdit<br>// cancelRequest |
| AC-C-ManageMoviesController | Class | ManageMoviesController | «control» | - | - | // startMovieAddition<br>// submitMovie<br>// startMovieEdit<br>// selectMovie<br>// submitMovieChanges<br>// cancelRequest<br>// discardRequest |
| AC-E-Movie | Class | Movie | «entity» | - | title (Văn bản)<br>releaseFormats (Văn bản)<br>duration (Số phút)<br>releaseDate (Ngày)<br>endOfRunDate (Ngày)<br>movieCode (Mã phim, hệ thống cấp, phân biệt các phim kể cả phim trùng tên) (mới ở UC này)<br>genre (Văn bản) (mới ở UC này)<br>ageRating (Nhãn: P, K, T13, T16, T18, C) (mới ở UC này)<br>description (Văn bản) (mới ở UC này)<br>trailer (Văn bản, đường dẫn tới video ngoài hệ thống) (mới ở UC này)<br>lastChangedAt (Ngày giờ) (mới ở UC này) | // provideMovieInfo<br>// createMovie<br>// checkMovieInfoValid<br>// addToMovieList<br>// saveMovieChanges<br>// checkUnchangedSinceDisplayed |

b) Bảng quan hệ

| ID | Lớp A | Lớp B | Loại | Multiplicity | Vai trò | Nguồn |
|---|---|---|---|---|---|---|
| R-UC010-01 | AC-B-ManageMoviesForm | AC-C-ManageMoviesController | Association | - | - | tạm thời; link F7: CM1-L2 |
| R-UC010-02 | AC-C-ManageMoviesController | AC-E-Movie | Association | - | - | tạm thời; link F7: CM1-L3, CM1-L4, CM1-L5 (ba đối tượng Movie: phim trong danh sách, phim dự kiến, phim đã chọn) |

Ba lớp Movie (:Movie, phimMới:Movie, phimChọn:Movie) là ba đối tượng của cùng một lớp nên chỉ một quan hệ giữa ManageMoviesController và Movie. Không có quan hệ giữa các entity vì use case chỉ có một entity.

## 9. Ma trận truy vết

| Bước UC | Message (STT) | Lớp tham gia (AC) |
|---|---|---|
| 1 | 1, 1.1 | AC-B-ManageMoviesForm, AC-C-ManageMoviesController |
| 2 | 1.1.1, 1.1.1 (trả về), 1.1.2 | AC-C-ManageMoviesController, AC-E-Movie, AC-B-ManageMoviesForm |
| 3 | 2, 2.1, 3a, 3a.1 | AC-B-ManageMoviesForm, AC-C-ManageMoviesController |
| 4 | 2.1.1, 2.1.2, 2.1.2 (trả về), 3a.1.1, 3a.1.1 (trả về) | AC-C-ManageMoviesController, AC-E-Movie |
| 5 | 2.1.4, 2.1.4 (trả về), 3a.1.3, 3a.1.3.1, 3a.1.3 (trả về) | AC-C-ManageMoviesController, AC-E-Movie |
| 6 | 2.1.5, 3a.1.5 | AC-C-ManageMoviesController, AC-B-ManageMoviesForm |
| 1a | 1a | AC-B-ManageMoviesForm |
| 1a1 | 1a.1, 1a.1.1, 1a.1.1 (trả về), 1a.1.2 | AC-B-ManageMoviesForm, AC-C-ManageMoviesController, AC-E-Movie |
| 1a2 | 2a, 2a.1 | AC-B-ManageMoviesForm, AC-C-ManageMoviesController |
| 1a3 | 2a.1.1, 2a.1.1 (trả về), 2a.1.2 | AC-C-ManageMoviesController, AC-E-Movie, AC-B-ManageMoviesForm |
| 4a | 2.1.3, 3a.1.2 | AC-C-ManageMoviesController, AC-B-ManageMoviesForm |
| 5a | 3a.1.4 | AC-C-ManageMoviesController, AC-B-ManageMoviesForm |
| *a | 1*a, 1*a.1, 1*a.1.1 | AC-B-ManageMoviesForm, AC-C-ManageMoviesController |

## 10. File .drawio

Ba file nằm trong diagrams/: P07-sequence-UC-010.drawio (3 trang), P07-communication-UC-010.drawio (1 trang), P07-class-UC-010.drawio (1 trang). XML không nén, ID cell trùng ID trong bảng mô hình.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Trạng thái |
| --- | --- | --- | --- | --- |
| Q-245 | Ở bước 4 của luồng thêm, phim chưa tồn tại nhưng thông tin phim cần được kiểm. Phân tích để control tạo "phim dự kiến" (chưa vào danh sách phim) bằng // createMovie, phim dự kiến tự kiểm (// checkMovieInfoValid) rồi tự ghi vào danh sách phim ở bước 5 (// addToMovieList); khi sửa, phim đã chọn tự kiểm thông tin nhập và tự ghi (// saveMovieChanges). Cùng cách cho cụm rạp dự kiến (UC-011) và phòng chiếu dự kiến (UC-012). Có chấp nhận khái niệm phim, cụm rạp, phòng chiếu dự kiến không, hay control kiểm điều kiện hợp lệ trước khi tạo đối tượng? (Chấp nhận, như suất chiếu dự kiến ở Q-102 của UC-014 / Control kiểm rồi mới tạo). Đề xuất: chấp nhận, vì điều kiện hợp lệ là quy tắc thuộc dữ liệu của phim (Information Expert), control chỉ điều phối | AC-E-Movie (// createMovie, // checkMovieInfoValid, // addToMovieList); AC-E-Cinema; AC-E-Auditorium; SD1 message 2.1.1; P08 | P04 bước 4 (kiểm hợp lệ) đứng trước bước 5 (thêm vào danh sách) nhưng phim mới chưa có đối tượng; Q-102 (UC-014) đã chấp nhận khái niệm tương tự | Chờ chủ dự án chốt theo đề xuất ở X3 |
| Q-246 | Danh sách phim (UC-010 bước 2, 1a1) và danh sách cụm rạp (UC-011 bước 2, 1a1) cần đi qua từng phần tử, nhưng P05 không có thực thể nắm cả danh sách (chuỗi là tên riêng của tổ chức, danh sách là cấu trúc cài đặt). Ai nắm tập? (Control lặp, mỗi lượt hỏi một phim hoặc một cụm rạp, như danh sách phim ở UC-014 / Thêm entity chuỗi nắm danh sách phim và danh sách cụm rạp). Đề xuất: control lặp, không thêm entity chuỗi; P08 xét lại khi cần điểm tuần tự theo tập (Q-248) | AC-C-ManageMoviesController (message 1.1.1, 1a.1.1 lặp); AC-C-ManageCinemasController; P08 | GL-37, GL-03 không nêu danh sách là khái niệm; GL-41 chỉ nêu quản lý chuỗi "quản lý danh sách phim, danh sách cụm rạp" | Chờ chủ dự án chốt theo đề xuất ở X3 |
| Q-247 | "Kể từ lúc hiển thị" (BR-138, BR-142, BR-146) được so bằng mốc nào? (Mốc thay đổi gần nhất của chính phim, cụm rạp, phòng chiếu (lastChangedAt), như suất chiếu ở UC-014 và mục giá ở UC-013 / Số phiên bản tăng dần). Đề xuất: mốc thay đổi gần nhất của chính đối tượng ở mức phân tích, biểu diễn cụ thể (cột phiên bản hoặc tương đương) do P13 chọn | AC-E-Movie, AC-E-Cinema, AC-E-Auditorium (lastChangedAt, // checkUnchangedSinceDisplayed); SD2 message 3a.1.3.1; P13 | BR-138, BR-142, BR-146 chỉ nêu "đã bị yêu cầu khác sửa kể từ lúc hiển thị", không nêu cách so | Chờ chủ dự án chốt theo đề xuất ở X3 |

## Giả định

Không có (chế độ NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P08 | AC-E-Movie | Lớp đang ở trạng thái Tạm; UC-010 bổ sung thuộc tính movieCode, genre, ageRating (nhãn P, K, T13, T16, T18, C), description, trailer, lastChangedAt và trách nhiệm createMovie, checkMovieInfoValid, addToMovieList, saveMovieChanges, checkUnchangedSinceDisplayed | Cập nhật AC-E-Movie theo _AC-register.UC-010.pending.md khi X3 gộp sổ; đổi trạng thái Tạm sang Hoạt động |
| P08 | EX-13, F4b mục 6 | Movie chưa là đơn vị khoá nhưng UC-014 bước 8 đọc phim trong cùng thao tác không chia cắt với lưu phim (BR-139); lưu phim sửa (// saveMovieChanges) chưa có đơn vị loại trừ | Thêm Movie (S) vào bộ khoá EX-13 và một đơn vị loại trừ mới cho lưu phim (lớp chủ Movie, khoá Movie (X)), cùng cặp X với EX-13 (BR-138, BR-139; đã nêu ở P04 UC-010 và SY-52) |
| P13 | TBL movie | Mốc thay đổi để so "kể từ lúc hiển thị" (Q-247) và mã phim phân biệt phim trùng tên (Q-200) chưa có chỗ biểu diễn | Chọn cột phiên bản hoặc mốc thay đổi cho movie; mã phim là khoá chính, không có ràng buộc duy nhất cho tên phim |

## Vấn đề còn mở

- UC-010 có 3 lớp (dưới ngưỡng 4 của F3.4): use case chỉ thêm và sửa một entity Movie và mọi danh từ khác đã loại ở F3.2 có lý do (suất chiếu, vé, lịch sử đặt vé thuộc use case khác; hồ sơ quản lý chuỗi không có hành vi vì use case không phân quyền theo cụm rạp, BR-78). Không bỏ sót entity.
- Điểm tuần tự (M3 mục 2): bất biến của Lưu phim theo từng phim (BR-138) và loại trừ với UC-014 bước 8 (BR-139) cùng một phạm vi là đối tượng Movie, nên khớp. P08 EX-13 chưa lấy khoá Movie nên cần thêm (Đề xuất sửa artifact trước). Phim sửa ghi nhận sau lúc UC-014 lưu suất chiếu không đổi suất chiếu đã lưu (BR-84); UC-014 bước 8 kiểm lại BR-47, BR-49 và tính lại BR-50 theo phim hiện hành là phần của P07 UC-014 (luồng 8g, đã ghi ở _sync-log).
- Thêm phim không có bất biến chung (tên được trùng, Q-200), nên không có điểm tuần tự; phân tích không thêm điều kiện kiểm tên.
- BR-140 (vé giữ tên phim lúc bán): UC-010 không có message tới vé, lần đặt hay email. Bảo đảm đến từ chỗ UC-005 ghi tên phim vào vé khi tạo vé; P08 cần giữ Ticket không có quan hệ đọc về Movie sau lúc bán.
- Danh sách phim được lặp ở control (Q-246). Nếu P08 thêm entity nắm danh sách phim thì chuyển trách nhiệm liệt kê và trách nhiệm ghi phim dự kiến cho entity đó.
- AC-E-Movie tăng thêm 6 trách nhiệm cùng 4 trách nhiệm của UC-014; UC-003 (chưa có P07) sẽ thêm trách nhiệm đọc theo BR-76, P08 theo dõi độ lớn lớp. // provideMovieInfo giữ một tên cho hai use case vì cùng ý nghĩa, UC-010 chỉ mở rộng nội dung cung cấp.
- ManageMoviesController có 7 trách nhiệm (trong ngưỡng 2-10), không giữ quy tắc thuộc dữ liệu của phim. Không có tác nhân thời gian và không có message hẹn mốc (A2): P04 Mục 8 ghi không có bước hẹn hoặc huỷ mốc.
- Trang SD2 vẽ luồng 1a từ 1a đến bước 6 vì phim đã chọn tự kiểm tra và tự ghi; đây là lý do SD2 có 3 fragment ở mức ngoài cùng (loop, hai alt), đúng ngưỡng.
