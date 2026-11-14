# P07 - Phân tích use case UC-011 Quản lý cụm rạp - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P07 |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | 00-Conventions.md (C10); 00-Concurrency.md (M3); project-profile.md; P04-uc-specs/UC-011-manage-cinemas.md 1.1; P01-actors.md 1.2; P02-usecases.md 1.9; P03-usecase-model.md 1.2; P05-glossary.md 1.2; P06-supplementary-spec.md 1.4; P04-uc-specs/_BR-register.md; P08-analysis-model.md 1.5 (F3, F4b: AC-E-Cinema); P07-uc-analysis/UC-005-book-tickets-analysis.md (đầu lô; sổ đăng ký AC: F1, F3.4, F8 b), Câu hỏi mở, Vấn đề còn mở); P07-uc-analysis/UC-010-manage-movies-analysis.md (cùng phiên, mẫu và Q-245 đến Q-247); P07-uc-analysis/UC-013-manage-price-list-analysis.md (mẫu định dạng); P07-uc-analysis/UC-014-schedule-showtimes-analysis.md; _sync-log.md (Đầu vào cho lần chạy lại P07-P13, dòng UC-011); dải mã Q-245 đến Q-254 (đầu lô) |
| Phạm vi | UC-011 |
| Mã Q, ASM cuối đã cấp | Q-248 (Q-248 cấp ở use case này, chờ chủ dự án chốt theo đề xuất; Q-245 đến Q-247 cấp ở UC-010; dải được cấp Q-245 đến Q-254); không có ASM (NGHIEM_NGAT) |

## 1. Bối cảnh use case

| Thuộc tính | Giá trị |
|---|---|
| Mã và tên UC | UC-011 Quản lý cụm rạp (Manage Cinemas) |
| Tác nhân chính | ACT-05 Quản lý chuỗi (Người) |
| Tác nhân phụ | Không có |
| Include (UC) | Không có |
| Được include bởi (UC) | Không có |
| Extend (UC, điểm mở rộng, điều kiện) | Không có |
| Được extend bởi (UC, điểm mở rộng, điều kiện) | Không có |
| Use case liên quan không qua include, extend | UC-012, UC-013, UC-014, UC-017 dùng cụm rạp làm nơi đặt phòng chiếu, bảng giá, suất chiếu, nhân viên; chỉ đọc cụm rạp nên không cần loại trừ (P04 Mục 8). UC-004 lọc lịch chiếu theo tỉnh, thành phố và UC-015 báo cáo cụm rạp (chưa có P07) chỉ đọc; UC-005 ghi tên cụm rạp lên vé (REQ-105, BR-140) và không đọc lại sau khi bán |
| Tác nhân thời gian | Không có. P04 Mục 8 ghi không có bước hẹn hoặc huỷ mốc, và P02 không có use case do tác nhân thời gian kích hoạt trên dữ liệu cụm rạp, nên không có message hẹn mốc (A2) |
| File P07 đã có được dùng làm sổ đăng ký AC | UC-005-book-tickets-analysis.md (sổ gốc, trạng thái đầu lô). AC-E-Cinema chưa có trong file P07 nào (các file P07 dùng thuộc tính cinema rút gọn theo Q-81, Q-98); mã và tên lấy theo P08-analysis-model.md 1.5 (AC-E-Cinema, Tạm, chờ P07 của UC-011), UC-011 là chủ sở hữu. Phần mới của sổ ghi ở _AC-register.UC-011.pending.md (C10) |

## 2. Đặc tả bổ sung

| Bước UC | Thực hiện bởi | Mô tả trong đặc tả | Mô tả bổ sung (hệ thống làm gì bên trong) | Nguồn (BR, GL, REQ) |
|---|---|---|---|---|
| 1 | Quản lý chuỗi | Yêu cầu thêm cụm rạp mới vào danh sách cụm rạp của chuỗi. | Không đổi | REQ-54 |
| 2 | Hệ thống | Hiển thị danh sách cụm rạp hiện có của chuỗi (xem Dữ liệu ra 1). | Không có đối tượng nắm cả danh sách cụm rạp, nên control lấy từng cụm rạp của chuỗi và nhận của mỗi cụm rạp tên, tỉnh hoặc thành phố, địa chỉ rồi chuyển cho boundary hiển thị. | GL-03, REQ-54, Q-246 |
| 3 | Quản lý chuỗi | Nhập thông tin cụm rạp rồi gửi (xem Dữ liệu vào 1). | Không đổi | REQ-54, REQ-10 |
| 4 | Hệ thống | Kiểm tra thông tin cụm rạp hợp lệ theo điều kiện của Dữ liệu vào 1 (Q-204). | Control tạo cụm rạp dự kiến từ thông tin đã nhập (chưa vào danh sách cụm rạp). Cụm rạp dự kiến kiểm tên không để trống và tỉnh, thành phố không để trống; địa chỉ không bắt buộc. | Q-204, Q-245 |
| 5 | Hệ thống | Kiểm tra tên cụm rạp chưa thuộc cụm rạp nào khác (BR-141) và, với cụm rạp đã chọn ở luồng 1a, cụm rạp chưa bị yêu cầu khác sửa kể từ lúc hiển thị (BR-142), rồi lưu thông tin cụm rạp, thêm cụm rạp mới vào danh sách cụm rạp hoặc cập nhật cụm rạp đã chọn, tất cả là một thao tác không chia cắt. | Control tìm cụm rạp khác đã mang tên nhập (khi sửa không kể chính cụm rạp đang sửa) và hỏi nó; chưa có thì ghi. Thêm: cụm rạp dự kiến vào danh sách và đặt mốc thay đổi. Sửa: cụm rạp đã chọn so mốc thay đổi hiện tại với mốc lúc hiển thị, đạt thì ghi thông tin mới và đặt lại mốc. Kiểm tên và ghi cùng một thao tác. | BR-141, BR-142, Q-206, Q-207, Q-247, Q-248 |
| 6 | Hệ thống | Thông báo lưu cụm rạp thành công và hiển thị cụm rạp đã lưu (xem Dữ liệu ra 2). | Control nhận thông tin cụm rạp đã lưu từ cụm rạp và chuyển cho boundary hiển thị cùng thông báo thành công. | REQ-54 |
| 1a | Quản lý chuỗi | Quản lý chuỗi chọn sửa một cụm rạp đã có thay vì thêm cụm rạp mới. | Không đổi | REQ-54, EV-13 |
| 1a1 | Hệ thống | Hiển thị danh sách cụm rạp của chuỗi (xem Dữ liệu ra 1). | Như bước 2; boundary ghi lại mốc thay đổi của từng cụm rạp lúc hiển thị để gửi kèm yêu cầu lưu ở bước 5. | GL-03, BR-142, Q-246 |
| 1a2 | Quản lý chuỗi | Chọn cụm rạp cần sửa (xem Dữ liệu vào 2). | Không đổi | REQ-54 |
| 1a3 | Hệ thống | Hiển thị thông tin hiện tại của cụm rạp đã chọn để sửa (xem Dữ liệu ra 3). | Control lấy từ cụm rạp đã chọn tên, tỉnh hoặc thành phố, địa chỉ hiện tại và chuyển cho boundary hiển thị. | GL-03 |
| 4a | Hệ thống | Từ chối lưu và thông báo điều kiện bị vi phạm của từng trường. | Cụm rạp (dự kiến hoặc đã chọn) báo điều kiện bị vi phạm của từng trường, control chuyển cho boundary thông báo; danh sách cụm rạp không đổi, quản lý chuỗi nhập lại ở bước 3. | Q-204 |
| 5a | Hệ thống | Chỉ khi theo luồng 1a: cụm rạp đã bị yêu cầu khác sửa kể từ lúc hiển thị (BR-142). Từ chối lưu, không ghi đè thay đổi trước và thông báo quy tắc bị vi phạm. | Cụm rạp đã chọn báo mốc thay đổi hiện tại khác mốc lúc hiển thị, không ghi gì; control chuyển lý do cho boundary thông báo, quản lý chuỗi mở lại cụm rạp từ bước 1a1. | BR-142, Q-207, Q-247 |
| 5b | Hệ thống | Tên cụm rạp đã thuộc một cụm rạp khác, kể cả khi cụm rạp đó vừa được lưu cùng lúc bởi một yêu cầu khác (BR-141). Từ chối lưu và thông báo quy tắc bị vi phạm. | Cụm rạp khác cùng tên báo tên đã thuộc nó, control không ghi và chuyển quy tắc bị vi phạm cho boundary; quản lý chuỗi nhập lại ở bước 3. Cụm rạp vừa lưu cùng lúc cũng thấy được vì kiểm tên và ghi cùng một thao tác. | BR-141, Q-206, Q-248 |
| *a | Hệ thống | Tại bất kỳ bước nào trước bước 5, kể cả trong luồng 1a, quản lý chuỗi huỷ yêu cầu. Huỷ yêu cầu, không thay đổi danh sách cụm rạp. | Không có thời hạn; huỷ có thể xảy ra ở mọi bước từ 1 đến 4 và từ 1a đến 1a3. Control bỏ yêu cầu đang xử lý, danh sách cụm rạp không bị chạm tới. | P04 Mục 3 luồng *a |

## 3. Tìm lớp phân tích

### 3.1 Bảng boundary

| Tác nhân (ACT) | Loại tác nhân | Boundary | Loại boundary | Mới hoặc tái dùng (AC, UC nguồn) | Lý do |
|---|---|---|---|---|---|
| ACT-05 Quản lý chuỗi | Người | ManageCinemasForm | Giao diện người dùng | Mới (AC-B-ManageCinemasForm) | Quản lý chuỗi xem danh sách cụm rạp, nhập thông tin cụm rạp, chọn cụm rạp cần sửa, huỷ và nhận thông báo kết quả. Một boundary cho cặp tác nhân và use case, không tách theo màn hình |

### 3.2 Bảng lọc danh từ

| STT | Danh từ hoặc cụm danh từ | Vị trí (bước UC, mục dữ liệu, BR) | Kết luận | Lý do |
|---|---|---|---|---|
| 1 | Quản lý chuỗi | Tác nhân chính | Loại - là tác nhân hoặc ngoài phạm vi | Tác nhân ACT-05; hồ sơ quản lý chuỗi không có hành vi trong use case (không phân quyền theo cụm rạp, BR-78) |
| 2 | Hệ thống | Các bước hệ thống | Loại - mơ hồ | Chỉ là bên thực hiện bước |
| 3 | Chuỗi | Mô tả ngắn, tiền điều kiện | Loại - là tác nhân hoặc ngoài phạm vi | Tên riêng của tổ chức CineBook (P05); Q-246 |
| 4 | Cụm rạp | Bước 2, 5, 1a1, 1a3, BR-141, BR-142 | Entity (AC-E-Cinema) | Có định danh, được tạo, sửa và kiểm tên duy nhất (GL-03). Mã theo P08; chủ sở hữu UC-011 |
| 5 | Danh sách cụm rạp | Bước 2, 1a1, Dữ liệu ra 1 | Loại - cấu trúc cài đặt | Kết quả liệt kê các cụm rạp; không có đối tượng nắm danh sách (Q-246) |
| 6 | Thông tin cụm rạp | Bước 3, 4, Dữ liệu vào 1 | Loại - trùng hoặc đồng nghĩa với Cinema | Tên chung của các trường của cụm rạp, không là khái niệm riêng |
| 7 | Tên cụm rạp | Dữ liệu vào 1 trường 1, BR-141 | Loại - thuộc tính của Cinema | name; duy nhất trong chuỗi (BR-141) |
| 8 | Tỉnh, thành phố | Dữ liệu vào 1 trường 2, Q-204 | Loại - thuộc tính của Cinema | province; văn bản bắt buộc, không có định danh và hành vi riêng; khách lọc lịch chiếu theo giá trị đã nhập |
| 9 | Địa chỉ | Dữ liệu vào 1 trường 3 | Loại - thuộc tính của Cinema | address; văn bản không bắt buộc (Q-137) |
| 10 | Mốc thay đổi lúc hiển thị | Bước 5, 5a, BR-142 | Loại - thuộc tính của Cinema | lastChangedAt; so với mốc hiện tại để biết cụm rạp đã bị sửa (Q-247) |
| 11 | Yêu cầu khác (sửa cùng cụm rạp) | Bước 5, 5a, BR-142 | Loại - thao tác hoặc sự kiện | Một lần lưu cụm rạp khác; hệ quả được so bằng mốc thay đổi |
| 12 | Thao tác không chia cắt | Bước 5, BR-141, BR-142 | Loại - thao tác hoặc sự kiện | Cách thực hiện, giao cho control điều phối Cinema // checkNameTaken và // addToCinemaList hoặc // saveCinemaChanges |
| 13 | Phòng chiếu | Hậu điều kiện, Mục 8 | Loại - không tham gia hành vi của use case này (khái niệm của UC-012) | Chỉ được nhắc tới để nói sửa cụm rạp không đổi phòng chiếu của cụm |
| 14 | Suất chiếu | Hậu điều kiện, Mục 8 | Loại - không tham gia hành vi của use case này (khái niệm của UC-014) | Không đọc hay ghi |
| 15 | Bảng giá | Hậu điều kiện, Mục 8 | Loại - không tham gia hành vi của use case này (khái niệm của UC-013) | Cụm rạp mới chưa có bảng giá; use case không tạo bảng giá |
| 16 | Nhân viên | Hậu điều kiện, Mục 8, BR-78 | Loại - không tham gia hành vi của use case này (khái niệm của UC-017) | Cụm rạp mới chưa có nhân viên; use case không đọc hay ghi nhân viên |
| 17 | Vé, tên cụm rạp ghi trên vé | Mục 8, BR-140 | Loại - không tham gia hành vi của use case này (khái niệm của UC-005) | Vé giữ tên cụm rạp lúc bán, use case không đọc vé |
| 18 | Khách (lọc lịch chiếu theo tỉnh, thành phố) | Dữ liệu vào 1 trường 2, REQ-10 | Loại - không tham gia hành vi của use case này (khái niệm của UC-004) | UC-004 đọc tỉnh, thành phố của cụm rạp, không cần loại trừ |
| 19 | 15 cụm rạp, 5 tỉnh, thành phố | Mục 8, REQ-01 | Loại - không tham gia hành vi của use case này (số liệu quy mô của P06) | Không đặt giới hạn cho use case |
| 20 | Thông báo, điều kiện vi phạm, quy tắc bị vi phạm | Bước 6, 4a, 5a, 5b | Loại - dữ liệu trao đổi qua boundary ManageCinemasForm | Không lưu |
| 21 | Phiên làm việc | Tiền điều kiện | Loại - là tác nhân hoặc ngoài phạm vi | Đăng nhập không mô hình hoá (project-profile mục 4) |
| 22 | Kết quả | Bước 6 | Loại - mơ hồ | Chỉ là thông báo thành công hoặc thất bại, đã tính ở dòng thông báo |

### 3.3 Bảng control

| Control | Use case điều phối | Mới hoặc tái dùng | Lý do (hoặc lý do không có control) |
|---|---|---|---|
| ManageCinemasController | UC-011 | Mới (AC-C-ManageCinemasController) | Một control cho use case: nhận yêu cầu từ boundary, điều phối hiển thị danh sách cụm rạp, tạo cụm rạp dự kiến, kiểm hợp lệ, kiểm tên, lưu, báo kết quả. Quy tắc điều kiện hợp lệ, tên trùng và mốc thay đổi nằm ở entity Cinema. Có 7 trách nhiệm |

### 3.4 Bảng lớp phân tích

| AC | Stereotype | Tên | Trách nhiệm | Thuộc tính chính | Bước UC nguồn | Loại boundary | Mới hoặc tái dùng | GL |
|---|---|---|---|---|---|---|---|---|
| AC-B-ManageCinemasForm | boundary | ManageCinemasForm | // requestCinemaAddition: quản lý chuỗi yêu cầu thêm cụm rạp mới<br>// showCinemaList: hiển thị danh sách cụm rạp của chuỗi, giữ mốc thay đổi của từng cụm rạp lúc hiển thị<br>// enterCinemaInfo: quản lý chuỗi nhập tên, tỉnh hoặc thành phố, địa chỉ rồi gửi<br>// notifyRefusal: thông báo từ chối kèm điều kiện hoặc quy tắc bị vi phạm<br>// showSavedCinema: thông báo lưu cụm rạp thành công và hiển thị cụm rạp đã lưu<br>// requestCinemaEdit: quản lý chuỗi chọn sửa một cụm rạp đã có thay vì thêm cụm rạp mới<br>// selectCinemaToEdit: quản lý chuỗi chọn cụm rạp cần sửa<br>// showCinemaForEdit: hiển thị thông tin hiện tại của cụm rạp đã chọn để sửa<br>// cancelRequest: quản lý chuỗi huỷ yêu cầu | displayedCinemaList (Danh sách cụm rạp đang hiển thị, kèm mốc thay đổi của từng cụm rạp lúc hiển thị)<br>enteredCinemaInfo (Tên, tỉnh hoặc thành phố, địa chỉ đã nhập)<br>selectedCinema (Cụm rạp đã chọn để sửa) | 1, 2, 3, 6, 1a, 1a1, 1a2, 1a3, 4a, 5a, 5b, *a | Giao diện người dùng | Mới | GL-41 |
| AC-C-ManageCinemasController | control | ManageCinemasController | // startCinemaAddition: điều phối bước 1 và 2: lấy từng cụm rạp của chuỗi để hiển thị<br>// submitCinema: điều phối bước 4 đến 6 của luồng chính: tạo cụm rạp dự kiến, kiểm hợp lệ, kiểm tên, ghi vào danh sách cụm rạp, báo kết quả<br>// startCinemaEdit: điều phối bước 1a1: lấy từng cụm rạp của chuỗi để hiển thị<br>// selectCinema: điều phối bước 1a2 và 1a3: lấy thông tin hiện tại của cụm rạp đã chọn để hiển thị<br>// submitCinemaChanges: điều phối bước 4 đến 6 của luồng 1a: kiểm hợp lệ, kiểm tên, lưu thay đổi, báo kết quả<br>// cancelRequest: điều phối luồng *a: huỷ yêu cầu<br>// discardRequest: bỏ yêu cầu đang xử lý, không đổi danh sách cụm rạp (luồng *a) | - | 1, 2, 3, 4, 5, 6, 1a1, 1a2, 1a3, 4a, 5a, 5b, *a | - | Mới | - |
| AC-E-Cinema | entity | Cinema | // provideCinemaInfo: cung cấp tên, tỉnh hoặc thành phố, địa chỉ và mốc thay đổi để hiển thị<br>// createCinema: khởi tạo cụm rạp dự kiến từ thông tin cụm rạp đã nhập, chưa vào danh sách cụm rạp (Q-245)<br>// checkCinemaInfoValid: kiểm tra thông tin cụm rạp theo điều kiện hợp lệ của Dữ liệu vào 1 (tên và tỉnh, thành phố không để trống) và trả về điều kiện bị vi phạm của từng trường (Q-204)<br>// checkNameTaken: cho biết tên cụm rạp đã nhập đã thuộc cụm rạp này, tức cụm rạp khác cùng tên tìm được theo tên (BR-141, Q-248)<br>// addToCinemaList: ghi cụm rạp dự kiến vào danh sách cụm rạp và đặt mốc thay đổi; cụm rạp mới chưa có phòng chiếu, bảng giá và nhân viên<br>// saveCinemaChanges: thao tác không chia cắt: kiểm cụm rạp chưa bị sửa kể từ lúc hiển thị rồi ghi thông tin mới và đặt lại mốc thay đổi; phòng chiếu, suất chiếu và nhân viên của cụm rạp không đổi (BR-142)<br>// checkUnchangedSinceDisplayed: kiểm tra cụm rạp chưa bị yêu cầu khác sửa kể từ lúc hiển thị bằng cách so mốc thay đổi hiện tại với mốc lúc hiển thị (BR-142, Q-247) | name (Văn bản) (mới ở UC này)<br>province (Văn bản, tỉnh hoặc thành phố) (mới ở UC này)<br>address (Văn bản) (mới ở UC này)<br>lastChangedAt (Ngày giờ) (mới ở UC này) | 2, 4, 5, 1a1, 1a3 | - | Mới - chủ sở hữu UC-011 (mã và tên theo P08, trạng thái Tạm) | GL-03 |

Tổng cộng 3 lớp: 1 boundary, 1 control, 1 entity (dưới ngưỡng 4, lý do ở Vấn đề còn mở). Entity cốt lõi của chủ đề race condition: AC-E-Cinema (loại trừ giữa hai yêu cầu cùng sửa một cụm rạp: BR-142; giữa hai yêu cầu lưu cùng tên: BR-141). Phần mới của sổ trách nhiệm ghi ở _AC-register.UC-011.pending.md (C10); Bảng 2 của sổ không có dòng mới vì mọi điều kiện của UC-011 chỉ dùng ở một use case.

## 4. Phân bổ hành vi

| Bước UC | Trách nhiệm | Lớp nhận (AC) | Nguyên tắc | Lý do khi có lựa chọn khác |
|---|---|---|---|---|
| 1 | // requestCinemaAddition | AC-B-ManageCinemasForm | Giao tiếp tác nhân | - |
| 1 | // startCinemaAddition | AC-C-ManageCinemasController | Controller | - |
| 2 | // provideCinemaInfo | AC-E-Cinema | Information Expert | Thông tin cụm rạp nằm ở cụm rạp. Không có đối tượng toàn thể nắm danh sách cụm rạp (Q-246) nên control lặp, mỗi lượt hỏi một cụm rạp |
| 2 | // showCinemaList | AC-B-ManageCinemasForm | Giao tiếp tác nhân | - |
| 3 | // enterCinemaInfo | AC-B-ManageCinemasForm | Giao tiếp tác nhân | - |
| 3 | // submitCinema | AC-C-ManageCinemasController | Controller | - |
| 3 | // submitCinemaChanges | AC-C-ManageCinemasController | Controller | - |
| 4 | // createCinema | AC-E-Cinema | Creator | Control có dữ liệu khởi tạo và không có đối tượng chứa danh sách cụm rạp (Q-246); tạo cụm rạp dự kiến rồi để cụm rạp tự kiểm (Q-245) |
| 4 | // checkCinemaInfoValid | AC-E-Cinema | Information Expert | Điều kiện hợp lệ là quy tắc về giá trị của chính các trường cụm rạp; giao cho control là để quy tắc dữ liệu ở control |
| 5 | // checkNameTaken | AC-E-Cinema | Information Expert | Tên nằm ở từng cụm rạp; so tên nhập với tên của mình là việc của cụm rạp. Cụm rạp khác cùng tên được tìm theo tên nên control gửi message thẳng tới cụm rạp tìm được (A6 a); nếu không tìm được thì không có tên trùng. Không có đối tượng toàn thể nắm tập cụm rạp để so cả tập (Q-248) |
| 5 | // addToCinemaList | AC-E-Cinema | Information Expert | Cụm rạp dự kiến biết mọi trường của mình nên tự đặt mốc thay đổi khi vào danh sách; Q-246 không có đối tượng toàn thể để giao việc ghi vào danh sách |
| 5 | // saveCinemaChanges | AC-E-Cinema | Information Expert | Mốc thay đổi và thông tin cụm rạp nằm ở cụm rạp đã chọn; kiểm mốc rồi ghi phải là một thao tác (BR-142). Giao cho control thì kiểm và ghi tách rời |
| 5 | // checkUnchangedSinceDisplayed | AC-E-Cinema | Information Expert | Mốc thay đổi nằm ở cụm rạp; điều kiện chưa bị sửa kể từ lúc hiển thị chỉ định nghĩa ở cụm rạp |
| 6 | // showSavedCinema | AC-B-ManageCinemasForm | Giao tiếp tác nhân | - |
| 1a | // requestCinemaEdit | AC-B-ManageCinemasForm | Giao tiếp tác nhân | - |
| 1a1 | // startCinemaEdit | AC-C-ManageCinemasController | Controller | - |
| 1a1 | // provideCinemaInfo | AC-E-Cinema | Information Expert | Như bước 2 |
| 1a1 | // showCinemaList | AC-B-ManageCinemasForm | Giao tiếp tác nhân | - |
| 1a2 | // selectCinemaToEdit | AC-B-ManageCinemasForm | Giao tiếp tác nhân | - |
| 1a2 | // selectCinema | AC-C-ManageCinemasController | Controller | - |
| 1a3 | // provideCinemaInfo | AC-E-Cinema | Information Expert | Như bước 2 |
| 1a3 | // showCinemaForEdit | AC-B-ManageCinemasForm | Giao tiếp tác nhân | - |
| 4a | // notifyRefusal | AC-B-ManageCinemasForm | Giao tiếp tác nhân | - |
| 5a | // notifyRefusal | AC-B-ManageCinemasForm | Giao tiếp tác nhân | - |
| 5b | // notifyRefusal | AC-B-ManageCinemasForm | Giao tiếp tác nhân | - |
| *a | // cancelRequest | AC-B-ManageCinemasForm | Giao tiếp tác nhân / Controller | - |
| *a | // cancelRequest | AC-C-ManageCinemasController | Giao tiếp tác nhân / Controller | - |
| *a | // discardRequest | AC-C-ManageCinemasController | Controller | Control chỉ bỏ yêu cầu, không giữ dữ liệu nghiệp vụ nên không có lựa chọn khác |

Thao tác không chia cắt theo bảng "Thao tác nguyên tử" của P04 Mục 8 (00-Concurrency.md M3 mục 1):

| Thao tác (P04 Mục 8) | Bước | Lớp điều phối | Lớp tham gia | Điểm tuần tự (M3 mục 2) |
|---|---|---|---|---|
| Lưu cụm rạp (thêm hoặc sửa) | 5 | AC-C-ManageCinemasController (SD1b: 2.1.4 và 2.1.6; SD2b: 3a.1.3 và 3a.1.5) | AC-E-Cinema (cụm rạp khác cùng tên, cụm rạp dự kiến hoặc cụm rạp đã chọn) | Hai bất biến có phạm vi khác nhau: "hai yêu cầu cùng sửa một cụm rạp" (BR-142) theo từng cụm rạp; "không có hai cụm rạp trùng tên trong chuỗi" (BR-141) trải qua mọi cụm rạp, nên điểm tuần tự theo từng cụm rạp là chưa đủ cho BR-141. Chưa khớp, ghi ở Vấn đề còn mở cho P08 (Q-248) |
| Thêm cụm rạp | 5 | AC-C-ManageCinemasController (SD1b: 2.1.4 và 2.1.6) | AC-E-Cinema (cụm rạp khác cùng tên, cụm rạp dự kiến) | Bất biến tên duy nhất (BR-141) trải qua mọi cụm rạp: hai yêu cầu cùng tên cùng lúc chỉ một yêu cầu được ghi, bên sau bị từ chối ở luồng 5b; kiểm tên và ghi nằm trong cùng thao tác |

## 5. Sequence diagram phân tích

File diagrams/P07-sequence-UC-011.drawio có 5 trang, đều dưới ngưỡng 30 message và 3 fragment ở mức ngoài cùng (không kể ref). Luồng chính tách thành SD1a (bước 1-2) và SD1b (bước 3-6) vì luồng 1a dùng chung bước 1-2 theo dạng riêng; luồng 4a, 5a, 5b quay lại bước trước nên dùng alt, không dùng break; luồng *a ở trang riêng.

### a) SD1a - Luồng chính, bước 1-2

Luồng thêm cụm rạp, đoạn bước 1-2. Danh sách cụm rạp được liệt kê trong loop vì không có đối tượng nắm cả danh sách (Q-246).

b) Bảng Node

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1a-L-A5 | Actor | :Quản lý chuỗi | - | - | Tác nhân (ACT-05) |
| SD1a-L-PF | Lifeline | :ManageCinemasForm | «boundary» | - | AC-B-ManageCinemasForm |
| SD1a-L-C | Lifeline | :ManageCinemasController | «control» | - | AC-C-ManageCinemasController |
| SD1a-L-CL | Lifeline | :Cinema | «entity» | - | AC-E-Cinema; mỗi cụm rạp của chuỗi khi liệt kê |
| SD1a-F1 | Fragment | loop [mỗi cụm rạp của chuỗi] | - | - | Bao các message của fragment |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1 | :Quản lý chuỗi | :ManageCinemasForm | // requestCinemaAddition | Đồng bộ | - | 1 |
| 1.1 | :ManageCinemasForm | :ManageCinemasController | // startCinemaAddition | Đồng bộ | - | 1 |
| 1.1.1 | :ManageCinemasController | :Cinema | // provideCinemaInfo | Đồng bộ | SD1a-F1 | 2 |
| 1.1.1 (trả về) | :Cinema | :ManageCinemasController | tên, tỉnh hoặc thành phố, địa chỉ, mốc thay đổi | Trả về | SD1a-F1 | 2 |
| 1.1.2 | :ManageCinemasController | :ManageCinemasForm | // showCinemaList (danh sách cụm rạp) | Đồng bộ | - | 2 |

### a) SD1b - Luồng chính, bước 3-6, 4a, 5b

Đoạn bước 3-6, bắt đầu bằng ref tới SD1a. Luồng 4a và 5b cùng quay lại bước 3 nên dùng alt, toán hạng luồng chính chỉ ghi guard và note. Cụm rạp mới chưa tồn tại ở bước 4 nên control tạo cụm rạp dự kiến (Q-245). Bước 5 do control điều phối: tìm cụm rạp khác cùng tên (tìm theo tên, A6 a, kết quả "đã có cụm rạp khác cùng tên" hoặc không, Q-248) rồi ghi cụm rạp dự kiến vào danh sách; hai message 2.1.4 và 2.1.6 là một thao tác không chia cắt (bảng cuối mục 4).

b) Bảng Node

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1b-L-A5 | Actor | :Quản lý chuỗi | - | - | Tác nhân (ACT-05) |
| SD1b-L-PF | Lifeline | :ManageCinemasForm | «boundary» | - | AC-B-ManageCinemasForm |
| SD1b-L-C | Lifeline | :ManageCinemasController | «control» | - | AC-C-ManageCinemasController |
| SD1b-L-CN | Lifeline | cụmRạpMới:Cinema | «entity» | - | AC-E-Cinema; cụm rạp dự kiến chưa vào danh sách cụm rạp (Q-245) |
| SD1b-L-CT | Lifeline | trùngTên:Cinema | «entity» | - | AC-E-Cinema; cụm rạp khác có cùng tên đã nhập, tìm theo tên (A6 a, Q-248) |
| SD1b-R1 | Fragment | ref SD1a - Luồng chính, bước 1-2 | - | - | ref, đặt ở mức ngoài cùng |
| SD1b-F1 | Fragment | alt [thông tin cụm rạp không đạt điều kiện hợp lệ (4a)] | - | - | Bao các message của fragment |
| SD1b-F1-O2 | Fragment | [thông tin cụm rạp hợp lệ] | - | SD1b-F1 | Toán hạng thứ 2; đường ngăn là edge SD1b-F1-O2-SEP nét đứt |
| SD1b-F2 | Fragment | alt [tên cụm rạp đã thuộc một cụm rạp khác (5b)] | - | - | Bao các message của fragment |
| SD1b-F2-O2 | Fragment | [tên cụm rạp chưa thuộc cụm rạp khác] | - | SD1b-F2 | Toán hạng thứ 2; đường ngăn là edge SD1b-F2-O2-SEP nét đứt |
| SD1b-N1 | Note | quay lại bước 3 | - | - | Chú thích |
| SD1b-N2 | Note | quay lại bước 3 | - | - | Chú thích |
| SD1b-N3 | Note | tiếp tục luồng chính | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 2 | :Quản lý chuỗi | :ManageCinemasForm | // enterCinemaInfo (tên cụm rạp, tỉnh hoặc thành phố, địa chỉ) | Đồng bộ | - | 3 |
| 2.1 | :ManageCinemasForm | :ManageCinemasController | // submitCinema (thông tin cụm rạp) | Đồng bộ | - | 3 |
| 2.1.1 | :ManageCinemasController | cụmRạpMới:Cinema | «create» // createCinema (thông tin cụm rạp đã nhập) | Tạo | - | 4 |
| 2.1.2 | :ManageCinemasController | cụmRạpMới:Cinema | // checkCinemaInfoValid | Đồng bộ | - | 4 |
| 2.1.2 (trả về) | cụmRạpMới:Cinema | :ManageCinemasController | thông tin hợp lệ hoặc điều kiện bị vi phạm của từng trường | Trả về | - | 4 |
| 2.1.3 | :ManageCinemasController | :ManageCinemasForm | // notifyRefusal (điều kiện bị vi phạm của từng trường) | Đồng bộ | SD1b-F1 | 4a |
| 2.1.4 | :ManageCinemasController | trùngTên:Cinema | // checkNameTaken (tên cụm rạp đã nhập, BR-141) | Đồng bộ | - | 5 |
| 2.1.4 (trả về) | trùngTên:Cinema | :ManageCinemasController | tên đã thuộc cụm rạp khác hoặc chưa | Trả về | - | 5 |
| 2.1.5 | :ManageCinemasController | :ManageCinemasForm | // notifyRefusal (tên cụm rạp đã thuộc cụm rạp khác, BR-141) | Đồng bộ | SD1b-F2 | 5b |
| 2.1.6 | :ManageCinemasController | cụmRạpMới:Cinema | // addToCinemaList | Đồng bộ | - | 5 |
| 2.1.6 (trả về) | cụmRạpMới:Cinema | :ManageCinemasController | cụm rạp đã lưu | Trả về | - | 5 |
| 2.1.7 | :ManageCinemasController | :ManageCinemasForm | // showSavedCinema (cụm rạp đã lưu) | Đồng bộ | - | 6 |

### a) SD2a - Luồng 1a, bước 1a1-1a3

Luồng sửa cụm rạp, đoạn 1a-1a3, trang riêng vì rẽ ngay từ bước 1; STT dùng hậu tố a. Sau 1a3 quay lại bước 3 (SD2b).

b) Bảng Node

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD2a-L-A5 | Actor | :Quản lý chuỗi | - | - | Tác nhân (ACT-05) |
| SD2a-L-PF | Lifeline | :ManageCinemasForm | «boundary» | - | AC-B-ManageCinemasForm |
| SD2a-L-C | Lifeline | :ManageCinemasController | «control» | - | AC-C-ManageCinemasController |
| SD2a-L-CL | Lifeline | :Cinema | «entity» | - | AC-E-Cinema; mỗi cụm rạp của chuỗi khi liệt kê |
| SD2a-L-CS | Lifeline | cụmRạpChọn:Cinema | «entity» | - | AC-E-Cinema; cụm rạp đã chọn để sửa ở luồng 1a |
| SD2a-F1 | Fragment | loop [mỗi cụm rạp của chuỗi] | - | - | Bao các message của fragment |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1a | :Quản lý chuỗi | :ManageCinemasForm | // requestCinemaEdit | Đồng bộ | - | 1a |
| 1a.1 | :ManageCinemasForm | :ManageCinemasController | // startCinemaEdit | Đồng bộ | - | 1a1 |
| 1a.1.1 | :ManageCinemasController | :Cinema | // provideCinemaInfo | Đồng bộ | SD2a-F1 | 1a1 |
| 1a.1.1 (trả về) | :Cinema | :ManageCinemasController | tên, tỉnh hoặc thành phố, địa chỉ, mốc thay đổi | Trả về | SD2a-F1 | 1a1 |
| 1a.1.2 | :ManageCinemasController | :ManageCinemasForm | // showCinemaList (danh sách cụm rạp, mốc thay đổi lúc hiển thị) | Đồng bộ | - | 1a1 |
| 2a | :Quản lý chuỗi | :ManageCinemasForm | // selectCinemaToEdit (cụm rạp cần sửa) | Đồng bộ | - | 1a2 |
| 2a.1 | :ManageCinemasForm | :ManageCinemasController | // selectCinema (cụm rạp đã chọn) | Đồng bộ | - | 1a2 |
| 2a.1.1 | :ManageCinemasController | cụmRạpChọn:Cinema | // provideCinemaInfo (cụm rạp đã chọn) | Đồng bộ | - | 1a3 |
| 2a.1.1 (trả về) | cụmRạpChọn:Cinema | :ManageCinemasController | thông tin hiện tại của cụm rạp | Trả về | - | 1a3 |
| 2a.1.2 | :ManageCinemasController | :ManageCinemasForm | // showCinemaForEdit (thông tin hiện tại của cụm rạp) | Đồng bộ | - | 1a3 |

### a) SD2b - Luồng 1a, bước 3-6, 4a, 5a, 5b

Đoạn bước 3-6 của luồng sửa, bắt đầu bằng ref tới SD2a. Cụm rạp đã chọn tự kiểm và tự ghi. Luồng 4a, 5b quay lại bước 3, luồng 5a quay lại 1a1, cả ba dùng alt. Khi sửa, cụm rạp khác cùng tên không kể chính cụm rạp đang sửa. Message 3a.1.3 và 3a.1.5 là một thao tác không chia cắt (bảng cuối mục 4); kiểm "đã bị sửa" nằm trong 3a.1.5.1 nên 5a và 5b được báo theo thứ tự 5b trước 5a như bước 5 của P04.

b) Bảng Node

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD2b-L-A5 | Actor | :Quản lý chuỗi | - | - | Tác nhân (ACT-05) |
| SD2b-L-PF | Lifeline | :ManageCinemasForm | «boundary» | - | AC-B-ManageCinemasForm |
| SD2b-L-C | Lifeline | :ManageCinemasController | «control» | - | AC-C-ManageCinemasController |
| SD2b-L-CS | Lifeline | cụmRạpChọn:Cinema | «entity» | - | AC-E-Cinema; cụm rạp đã chọn để sửa ở luồng 1a |
| SD2b-L-CT | Lifeline | trùngTên:Cinema | «entity» | - | AC-E-Cinema; cụm rạp khác có cùng tên đã nhập, tìm theo tên (A6 a, Q-248) |
| SD2b-R1 | Fragment | ref SD2a - Luồng 1a, bước 1a1-1a3 | - | - | ref, đặt ở mức ngoài cùng |
| SD2b-F1 | Fragment | alt [thông tin cụm rạp không đạt điều kiện hợp lệ (4a)] | - | - | Bao các message của fragment |
| SD2b-F1-O2 | Fragment | [thông tin cụm rạp hợp lệ] | - | SD2b-F1 | Toán hạng thứ 2; đường ngăn là edge SD2b-F1-O2-SEP nét đứt |
| SD2b-F2 | Fragment | alt [tên cụm rạp đã thuộc một cụm rạp khác (5b)] | - | - | Bao các message của fragment |
| SD2b-F2-O2 | Fragment | [tên cụm rạp chưa thuộc cụm rạp khác] | - | SD2b-F2 | Toán hạng thứ 2; đường ngăn là edge SD2b-F2-O2-SEP nét đứt |
| SD2b-F3 | Fragment | alt [cụm rạp đã bị yêu cầu khác sửa kể từ lúc hiển thị (5a)] | - | - | Bao các message của fragment |
| SD2b-F3-O2 | Fragment | [cụm rạp chưa bị sửa kể từ lúc hiển thị] | - | SD2b-F3 | Toán hạng thứ 2; đường ngăn là edge SD2b-F3-O2-SEP nét đứt |
| SD2b-N1 | Note | quay lại bước 3 | - | - | Chú thích |
| SD2b-N2 | Note | quay lại bước 3 | - | - | Chú thích |
| SD2b-N3 | Note | quay lại bước 1a1 | - | - | Chú thích |
| SD2b-N4 | Note | tiếp tục luồng 1a | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 3a | :Quản lý chuỗi | :ManageCinemasForm | // enterCinemaInfo (thông tin cụm rạp đã sửa) | Đồng bộ | - | 3 |
| 3a.1 | :ManageCinemasForm | :ManageCinemasController | // submitCinemaChanges (thông tin cụm rạp, mốc thay đổi lúc hiển thị) | Đồng bộ | - | 3 |
| 3a.1.1 | :ManageCinemasController | cụmRạpChọn:Cinema | // checkCinemaInfoValid (thông tin cụm rạp đã sửa) | Đồng bộ | - | 4 |
| 3a.1.1 (trả về) | cụmRạpChọn:Cinema | :ManageCinemasController | thông tin hợp lệ hoặc điều kiện bị vi phạm của từng trường | Trả về | - | 4 |
| 3a.1.2 | :ManageCinemasController | :ManageCinemasForm | // notifyRefusal (điều kiện bị vi phạm của từng trường) | Đồng bộ | SD2b-F1 | 4a |
| 3a.1.3 | :ManageCinemasController | trùngTên:Cinema | // checkNameTaken (tên cụm rạp đã nhập, không kể cụm rạp đang sửa, BR-141) | Đồng bộ | - | 5 |
| 3a.1.3 (trả về) | trùngTên:Cinema | :ManageCinemasController | tên đã thuộc cụm rạp khác hoặc chưa | Trả về | - | 5 |
| 3a.1.4 | :ManageCinemasController | :ManageCinemasForm | // notifyRefusal (tên cụm rạp đã thuộc cụm rạp khác, BR-141) | Đồng bộ | SD2b-F2 | 5b |
| 3a.1.5 | :ManageCinemasController | cụmRạpChọn:Cinema | // saveCinemaChanges (thông tin cụm rạp đã sửa, mốc thay đổi lúc hiển thị) | Đồng bộ | - | 5 |
| 3a.1.5.1 | cụmRạpChọn:Cinema | cụmRạpChọn:Cinema | // checkUnchangedSinceDisplayed (mốc thay đổi lúc hiển thị, BR-142) | Tự gọi | - | 5 |
| 3a.1.5 (trả về) | cụmRạpChọn:Cinema | :ManageCinemasController | cụm rạp đã lưu, hoặc kết quả cụm rạp đã bị yêu cầu khác sửa | Trả về | - | 5 |
| 3a.1.6 | :ManageCinemasController | :ManageCinemasForm | // notifyRefusal (cụm rạp đã bị sửa, mở lại cụm rạp từ đầu, BR-142) | Đồng bộ | SD2b-F3 | 5a |
| 3a.1.7 | :ManageCinemasController | :ManageCinemasForm | // showSavedCinema (cụm rạp đã lưu) | Đồng bộ | - | 6 |

### a) SD3 - Luồng *a

Trang riêng theo A2 và F5 c): bắt đầu bằng ref tới bốn trang trước, note nêu khoảng message có thể xảy ra, STT lấy message đầu khoảng kèm mã luồng (1*a). Không có break vì huỷ có thể xảy ra tại nhiều điểm; không có message hoàn tác vì danh sách cụm rạp chưa bị ghi.

b) Bảng Node

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD3-L-A5 | Actor | :Quản lý chuỗi | - | - | Tác nhân (ACT-05) |
| SD3-L-PF | Lifeline | :ManageCinemasForm | «boundary» | - | AC-B-ManageCinemasForm |
| SD3-L-C | Lifeline | :ManageCinemasController | «control» | - | AC-C-ManageCinemasController |
| SD3-R1 | Fragment | ref SD1a - Luồng chính, bước 1-2 | - | - | ref, đặt ở mức ngoài cùng |
| SD3-R2 | Fragment | ref SD1b - Luồng chính, bước 3-6, 4a, 5b | - | - | ref, đặt ở mức ngoài cùng |
| SD3-R3 | Fragment | ref SD2a - Luồng 1a, bước 1a1-1a3 | - | - | ref, đặt ở mức ngoài cùng |
| SD3-R4 | Fragment | ref SD2b - Luồng 1a, bước 3-6, 4a, 5a, 5b | - | - | ref, đặt ở mức ngoài cùng |
| SD3-N1 | Note | có thể xảy ra tại bất kỳ message nào từ 1 đến 2.1.3 của SD1a, SD1b và từ 1a đến 3a.1.2 của SD2a, SD2b (trước bước 5) | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1*a | :Quản lý chuỗi | :ManageCinemasForm | // cancelRequest | Đồng bộ | - | *a |
| 1*a.1 | :ManageCinemasForm | :ManageCinemasController | // cancelRequest | Đồng bộ | - | *a |
| 1*a.1.1 | :ManageCinemasController | :ManageCinemasController | // discardRequest (không đổi danh sách cụm rạp) | Tự gọi | - | *a |

## 6. Quy tắc tương tác giữa các lớp phân tích

| Vi phạm | Message hoặc link | Cách sửa đã áp dụng |
|---|---|---|
| Không có | - | - |

Đã kiểm: actor chỉ gửi message tới ManageCinemasForm; ManageCinemasForm chỉ gửi tới ManageCinemasController; ManageCinemasController gọi Cinema và ManageCinemasForm; Cinema chỉ gọi chính nó (3a.1.5.1). Không lifeline nào đại diện cho một tập: loop 1.1.1 và 1a.1.1 gửi message tới từng cụm rạp, mỗi lượt một đối tượng; trùngTên:Cinema là một cụm rạp tìm theo tên (A6 a).

## 7. Communication diagram

File diagrams/P07-communication-UC-011.drawio có 1 trang CM1 cho mọi luồng (MUC_CHI_TIET là DAY_DU): luồng chính, 4a, 5b (SD1a, SD1b), 1a, 4a, 5a, 5b (SD2a, SD2b) và *a (SD3), giữ nguyên STT của sequence diagram. Message trả về không vẽ. Link tự nối của cụmRạpChọn:Cinema và ManageCinemasController không sinh quan hệ VOPC. Guard của fragment ghi trong ngoặc vuông cuối message.

### Trang CM1 - Mọi luồng

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| CM1-O-A5 | Actor | :Quản lý chuỗi | - | - | Tác nhân (ACT-05) |
| CM1-O-PF | Object | :ManageCinemasForm | «boundary» | - | AC-B-ManageCinemasForm |
| CM1-O-C | Object | :ManageCinemasController | «control» | - | AC-C-ManageCinemasController |
| CM1-O-CL | Object | :Cinema | «entity» | - | AC-E-Cinema; mỗi cụm rạp của chuỗi khi liệt kê |
| CM1-O-CN | Object | cụmRạpMới:Cinema | «entity» | - | AC-E-Cinema; cụm rạp dự kiến chưa vào danh sách cụm rạp (Q-245) |
| CM1-O-CT | Object | trùngTên:Cinema | «entity» | - | AC-E-Cinema; cụm rạp khác có cùng tên đã nhập, tìm theo tên (A6 a, Q-248) |
| CM1-O-CS | Object | cụmRạpChọn:Cinema | «entity» | - | AC-E-Cinema; cụm rạp đã chọn để sửa ở luồng 1a |

b) Bảng Edge

| ID | Nguồn | Đích | Loại | Nhãn | Chiều message |
|---|---|---|---|---|---|
| CM1-L1 | CM1-O-A5 | CM1-O-PF | Link | 1: // requestCinemaAddition (-->)<br>2: // enterCinemaInfo (tên cụm rạp, tỉnh hoặc thành phố, địa chỉ) (-->)<br>1a: // requestCinemaEdit (-->)<br>2a: // selectCinemaToEdit (cụm rạp cần sửa) (-->)<br>3a: // enterCinemaInfo (thông tin cụm rạp đã sửa) (-->)<br>1*a: // cancelRequest (-->) | Nguồn-->Đích: 1, 2, 1a, 2a, 3a, 1*a |
| CM1-L2 | CM1-O-PF | CM1-O-C | Link | 1.1: // startCinemaAddition (-->)<br>1.1.2: // showCinemaList (danh sách cụm rạp) (<--)<br>2.1: // submitCinema (thông tin cụm rạp) (-->)<br>2.1.3: // notifyRefusal (điều kiện bị vi phạm của từng trường) (<--) [thông tin cụm rạp không đạt điều kiện hợp lệ (4a)]<br>2.1.5: // notifyRefusal (tên cụm rạp đã thuộc cụm rạp khác, BR-141) (<--) [tên cụm rạp đã thuộc một cụm rạp khác (5b)]<br>2.1.7: // showSavedCinema (cụm rạp đã lưu) (<--)<br>1a.1: // startCinemaEdit (-->)<br>1a.1.2: // showCinemaList (danh sách cụm rạp, mốc thay đổi lúc hiển thị) (<--)<br>2a.1: // selectCinema (cụm rạp đã chọn) (-->)<br>2a.1.2: // showCinemaForEdit (thông tin hiện tại của cụm rạp) (<--)<br>3a.1: // submitCinemaChanges (thông tin cụm rạp, mốc thay đổi lúc hiển thị) (-->)<br>3a.1.2: // notifyRefusal (điều kiện bị vi phạm của từng trường) (<--) [thông tin cụm rạp không đạt điều kiện hợp lệ (4a)]<br>3a.1.4: // notifyRefusal (tên cụm rạp đã thuộc cụm rạp khác, BR-141) (<--) [tên cụm rạp đã thuộc một cụm rạp khác (5b)]<br>3a.1.6: // notifyRefusal (cụm rạp đã bị sửa, mở lại cụm rạp từ đầu, BR-142) (<--) [cụm rạp đã bị yêu cầu khác sửa kể từ lúc hiển thị (5a)]<br>3a.1.7: // showSavedCinema (cụm rạp đã lưu) (<--)<br>1*a.1: // cancelRequest (-->) | Nguồn-->Đích: 1.1, 2.1, 1a.1, 2a.1, 3a.1, 1*a.1; Đích-->Nguồn: 1.1.2, 2.1.3, 2.1.5, 2.1.7, 1a.1.2, 2a.1.2, 3a.1.2, 3a.1.4, 3a.1.6, 3a.1.7 |
| CM1-L3 | CM1-O-C | CM1-O-CL | Link | 1.1.1: // provideCinemaInfo (-->) [lặp: mỗi cụm rạp của chuỗi]<br>1a.1.1: // provideCinemaInfo (-->) [lặp: mỗi cụm rạp của chuỗi] | Nguồn-->Đích: 1.1.1, 1a.1.1 |
| CM1-L4 | CM1-O-C | CM1-O-CN | Link | 2.1.1: «create» // createCinema (thông tin cụm rạp đã nhập) (-->)<br>2.1.2: // checkCinemaInfoValid (-->)<br>2.1.6: // addToCinemaList (-->) | Nguồn-->Đích: 2.1.1, 2.1.2, 2.1.6 |
| CM1-L5 | CM1-O-C | CM1-O-CT | Link | 2.1.4: // checkNameTaken (tên cụm rạp đã nhập, BR-141) (-->)<br>3a.1.3: // checkNameTaken (tên cụm rạp đã nhập, không kể cụm rạp đang sửa, BR-141) (-->) | Nguồn-->Đích: 2.1.4, 3a.1.3 |
| CM1-L6 | CM1-O-C | CM1-O-CS | Link | 2a.1.1: // provideCinemaInfo (cụm rạp đã chọn) (-->)<br>3a.1.1: // checkCinemaInfoValid (thông tin cụm rạp đã sửa) (-->)<br>3a.1.5: // saveCinemaChanges (thông tin cụm rạp đã sửa, mốc thay đổi lúc hiển thị) (-->) | Nguồn-->Đích: 2a.1.1, 3a.1.1, 3a.1.5 |
| CM1-L7 | CM1-O-CS | CM1-O-CS | Link | 3a.1.5.1: // checkUnchangedSinceDisplayed (mốc thay đổi lúc hiển thị, BR-142) (-->) | Nguồn-->Đích: 3a.1.5.1 |
| CM1-L8 | CM1-O-C | CM1-O-C | Link | 1*a.1.1: // discardRequest (không đổi danh sách cụm rạp) (-->) | Nguồn-->Đích: 1*a.1.1 |

## 8. VOPC

File diagrams/P07-class-UC-011.drawio. ID cell của lớp là mã AC; ngăn thuộc tính và ngăn trách nhiệm có ID "<mã AC>-ATTR" và "<mã AC>-RESP".

a) Bảng Node (lớp)

| ID (mã AC) | Loại (Class) | Nhãn (tên lớp) | Stereotype | Thuộc về | Ngăn thuộc tính | Ngăn trách nhiệm |
|---|---|---|---|---|---|---|
| AC-B-ManageCinemasForm | Class | ManageCinemasForm | «boundary» | - | displayedCinemaList (Danh sách cụm rạp đang hiển thị, kèm mốc thay đổi của từng cụm rạp lúc hiển thị)<br>enteredCinemaInfo (Tên, tỉnh hoặc thành phố, địa chỉ đã nhập)<br>selectedCinema (Cụm rạp đã chọn để sửa) | // requestCinemaAddition<br>// showCinemaList<br>// enterCinemaInfo<br>// notifyRefusal<br>// showSavedCinema<br>// requestCinemaEdit<br>// selectCinemaToEdit<br>// showCinemaForEdit<br>// cancelRequest |
| AC-C-ManageCinemasController | Class | ManageCinemasController | «control» | - | - | // startCinemaAddition<br>// submitCinema<br>// startCinemaEdit<br>// selectCinema<br>// submitCinemaChanges<br>// cancelRequest<br>// discardRequest |
| AC-E-Cinema | Class | Cinema | «entity» | - | name (Văn bản) (mới ở UC này)<br>province (Văn bản, tỉnh hoặc thành phố) (mới ở UC này)<br>address (Văn bản) (mới ở UC này)<br>lastChangedAt (Ngày giờ) (mới ở UC này) | // provideCinemaInfo<br>// createCinema<br>// checkCinemaInfoValid<br>// checkNameTaken<br>// addToCinemaList<br>// saveCinemaChanges<br>// checkUnchangedSinceDisplayed |

b) Bảng quan hệ

| ID | Lớp A | Lớp B | Loại | Multiplicity | Vai trò | Nguồn |
|---|---|---|---|---|---|---|
| R-UC011-01 | AC-B-ManageCinemasForm | AC-C-ManageCinemasController | Association | - | - | tạm thời; link F7: CM1-L2 |
| R-UC011-02 | AC-C-ManageCinemasController | AC-E-Cinema | Association | - | - | tạm thời; link F7: CM1-L3 đến CM1-L6 (bốn đối tượng Cinema: cụm rạp trong danh sách, cụm rạp dự kiến, cụm rạp trùng tên, cụm rạp đã chọn) |

Bốn lifeline :Cinema, cụmRạpMới:Cinema, trùngTên:Cinema, cụmRạpChọn:Cinema là các đối tượng của cùng một lớp nên chỉ một quan hệ giữa ManageCinemasController và Cinema. Không có quan hệ giữa các entity vì use case chỉ có một entity.

## 9. Ma trận truy vết

| Bước UC | Message (STT) | Lớp tham gia (AC) |
|---|---|---|
| 1 | 1, 1.1 | AC-B-ManageCinemasForm, AC-C-ManageCinemasController |
| 2 | 1.1.1, 1.1.1 (trả về), 1.1.2 | AC-C-ManageCinemasController, AC-E-Cinema, AC-B-ManageCinemasForm |
| 3 | 2, 2.1, 3a, 3a.1 | AC-B-ManageCinemasForm, AC-C-ManageCinemasController |
| 4 | 2.1.1, 2.1.2, 2.1.2 (trả về), 3a.1.1, 3a.1.1 (trả về) | AC-C-ManageCinemasController, AC-E-Cinema |
| 5 | 2.1.4, 2.1.4 (trả về), 2.1.6, 2.1.6 (trả về), 3a.1.3, 3a.1.3 (trả về), 3a.1.5, 3a.1.5.1, 3a.1.5 (trả về) | AC-C-ManageCinemasController, AC-E-Cinema |
| 6 | 2.1.7, 3a.1.7 | AC-C-ManageCinemasController, AC-B-ManageCinemasForm |
| 1a | 1a | AC-B-ManageCinemasForm |
| 1a1 | 1a.1, 1a.1.1, 1a.1.1 (trả về), 1a.1.2 | AC-B-ManageCinemasForm, AC-C-ManageCinemasController, AC-E-Cinema |
| 1a2 | 2a, 2a.1 | AC-B-ManageCinemasForm, AC-C-ManageCinemasController |
| 1a3 | 2a.1.1, 2a.1.1 (trả về), 2a.1.2 | AC-C-ManageCinemasController, AC-E-Cinema, AC-B-ManageCinemasForm |
| 4a | 2.1.3, 3a.1.2 | AC-C-ManageCinemasController, AC-B-ManageCinemasForm |
| 5a | 3a.1.6 | AC-C-ManageCinemasController, AC-B-ManageCinemasForm |
| 5b | 2.1.5, 3a.1.4 | AC-C-ManageCinemasController, AC-B-ManageCinemasForm |
| *a | 1*a, 1*a.1, 1*a.1.1 | AC-B-ManageCinemasForm, AC-C-ManageCinemasController |

## 10. File .drawio

Ba file nằm trong diagrams/: P07-sequence-UC-011.drawio (5 trang), P07-communication-UC-011.drawio (1 trang), P07-class-UC-011.drawio (1 trang). XML không nén, ID cell trùng ID trong bảng mô hình.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Trạng thái |
| --- | --- | --- | --- | --- |
| Q-245 | Ở bước 4 của luồng thêm, phim chưa tồn tại nhưng thông tin phim cần được kiểm. Phân tích để control tạo "phim dự kiến" (chưa vào danh sách phim) bằng // createMovie, phim dự kiến tự kiểm (// checkMovieInfoValid) rồi tự ghi vào danh sách phim ở bước 5 (// addToMovieList); khi sửa, phim đã chọn tự kiểm thông tin nhập và tự ghi (// saveMovieChanges). Cùng cách cho cụm rạp dự kiến (UC-011) và phòng chiếu dự kiến (UC-012). Có chấp nhận khái niệm phim, cụm rạp, phòng chiếu dự kiến không, hay control kiểm điều kiện hợp lệ trước khi tạo đối tượng? (Chấp nhận, như suất chiếu dự kiến ở Q-102 của UC-014 / Control kiểm rồi mới tạo). Đề xuất: chấp nhận, vì điều kiện hợp lệ là quy tắc thuộc dữ liệu của phim (Information Expert), control chỉ điều phối | AC-E-Movie (// createMovie, // checkMovieInfoValid, // addToMovieList); AC-E-Cinema (// createCinema, // checkCinemaInfoValid, // addToCinemaList); AC-E-Auditorium; SD1b message 2.1.1; P08 | P04 bước 4 (kiểm hợp lệ) đứng trước bước 5 (thêm vào danh sách) nhưng cụm rạp mới chưa có đối tượng; Q-102 (UC-014) đã chấp nhận khái niệm tương tự | Gộp vào Q-245 (UC-010). Chờ chủ dự án chốt theo đề xuất ở X3 |
| Q-246 | Danh sách phim (UC-010 bước 2, 1a1) và danh sách cụm rạp (UC-011 bước 2, 1a1) cần đi qua từng phần tử, nhưng P05 không có thực thể nắm cả danh sách (chuỗi là tên riêng của tổ chức, danh sách là cấu trúc cài đặt). Ai nắm tập? (Control lặp, mỗi lượt hỏi một phim hoặc một cụm rạp, như danh sách phim ở UC-014 / Thêm entity chuỗi nắm danh sách phim và danh sách cụm rạp). Đề xuất: control lặp, không thêm entity chuỗi; P08 xét lại khi cần điểm tuần tự theo tập (Q-248) | AC-C-ManageMoviesController; AC-C-ManageCinemasController (message 1.1.1, 1a.1.1 lặp); P08 | GL-37, GL-03 không nêu danh sách là khái niệm; GL-41 chỉ nêu quản lý chuỗi "quản lý danh sách phim, danh sách cụm rạp" | Gộp vào Q-246 (UC-010). Chờ chủ dự án chốt theo đề xuất ở X3 |
| Q-247 | "Kể từ lúc hiển thị" (BR-138, BR-142, BR-146) được so bằng mốc nào? (Mốc thay đổi gần nhất của chính phim, cụm rạp, phòng chiếu (lastChangedAt), như suất chiếu ở UC-014 và mục giá ở UC-013 / Số phiên bản tăng dần). Đề xuất: mốc thay đổi gần nhất của chính đối tượng ở mức phân tích, biểu diễn cụ thể (cột phiên bản hoặc tương đương) do P13 chọn | AC-E-Movie, AC-E-Cinema, AC-E-Auditorium (lastChangedAt, // checkUnchangedSinceDisplayed); SD2b message 3a.1.5.1; P13 | BR-138, BR-142, BR-146 chỉ nêu "đã bị yêu cầu khác sửa kể từ lúc hiển thị", không nêu cách so | Gộp vào Q-247 (UC-010). Chờ chủ dự án chốt theo đề xuất ở X3 |
| Q-248 | Tên cụm rạp duy nhất trong cả chuỗi (BR-141) cần so với mọi cụm rạp khác, nhưng không có đối tượng nắm tập cụm rạp (Q-246). Phân tích để control tìm cụm rạp khác cùng tên (coi như tìm theo khoá, A6 a) rồi hỏi cụm rạp tìm được (// checkNameTaken); kiểm tên và ghi (// addToCinemaList hoặc // saveCinemaChanges) là một thao tác do control điều phối. Điểm tuần tự của thao tác này phải bao mọi cụm rạp (bất biến trải qua cả chuỗi), không chỉ từng cụm rạp (M3 mục 2). Có chấp nhận cách tìm theo tên rồi hỏi và để P08 thêm điểm tuần tự theo tập cụm rạp, hay thêm entity nắm tập cụm rạp ngay ở P07? (Tìm theo tên, P08 thêm điểm tuần tự theo tập tên cụm rạp / Thêm entity chuỗi nắm tập cụm rạp). Đề xuất: tìm theo tên; P08 thêm đơn vị loại trừ cho lưu cụm rạp với khoá theo tập tên cụm rạp | AC-E-Cinema (// checkNameTaken); SD1b message 2.1.4, 2.1.6; SD2b message 3a.1.3, 3a.1.5; P08 F4b; P09 | BR-141 "không có hai cụm rạp trùng tên trong chuỗi" trải qua mọi cụm rạp; luồng 5b nêu cả trường hợp cụm rạp cùng tên "vừa được lưu cùng lúc bởi một yêu cầu khác" | Chờ chủ dự án chốt theo đề xuất ở X3 |

## Giả định

Không có (chế độ NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P08 | AC-E-Cinema | Lớp đang ở trạng thái Tạm (chờ P07 của UC-011); UC-011 là chủ sở hữu, bổ sung thuộc tính name, province, address, lastChangedAt và trách nhiệm provideCinemaInfo, createCinema, checkCinemaInfoValid, checkNameTaken, addToCinemaList, saveCinemaChanges, checkUnchangedSinceDisplayed | Cập nhật AC-E-Cinema theo _AC-register.UC-011.pending.md khi X3 gộp sổ; đổi trạng thái Tạm sang Hoạt động; thêm tỉnh, thành phố (đã có ở _sync-log, UC-011 Q-204) |
| P08 | F4a, F4b (đơn vị loại trừ) | Lưu cụm rạp chưa có đơn vị loại trừ; bất biến tên duy nhất (BR-141) trải qua mọi cụm rạp nên khoá theo từng cụm rạp không đủ (Q-248) | Thêm đơn vị loại trừ cho lưu cụm rạp (UC-011, lớp chủ Cinema): khoá theo tập tên cụm rạp để giữ BR-141 và khoá Cinema (X) để giữ BR-142; xác nhận không có cặp X với use case khác vì các use case khác chỉ đọc cụm rạp |
| P13 | TBL cinema | Tên duy nhất toàn chuỗi (BR-141) và mốc thay đổi để so "kể từ lúc hiển thị" (Q-247) | Ràng buộc duy nhất cho tên cụm rạp (đã có ở _sync-log) và cột phiên bản hoặc mốc thay đổi |

## Vấn đề còn mở

- UC-011 có 3 lớp (dưới ngưỡng 4 của F3.4): use case chỉ thêm và sửa một entity Cinema; phòng chiếu, suất chiếu, bảng giá, nhân viên đã loại ở F3.2 vì use case không đọc hay ghi chúng (hậu điều kiện chỉ nêu chúng vẫn thuộc cụm rạp). Không bỏ sót entity.
- Điểm tuần tự (M3 mục 2): BR-142 theo từng cụm rạp khớp với đối tượng Cinema, nhưng BR-141 (tên duy nhất toàn chuỗi) trải qua mọi cụm rạp, chưa khớp với điểm tuần tự theo từng cụm rạp. Phân tích chỉ chỉ ra phạm vi; P08 thêm đơn vị loại trừ có khoá theo tập tên cụm rạp (Q-248), cơ chế do P09.
- Cụm rạp không bị xoá (Q-205) và mọi use case khác chỉ đọc thông tin cụm rạp (UC-004 lọc theo tỉnh, thành phố; UC-017 gán nhân viên; UC-015), nên UC-011 không có cặp loại trừ với use case khác. P08 giữ quan hệ cụm rạp - phòng chiếu - bảng giá - nhân viên ở các lớp đã có, UC-011 chỉ chạm tới thuộc tính của cụm rạp.
- BR-140 (vé giữ tên cụm rạp lúc bán): UC-011 không có message tới vé hay email; P08 cần giữ Ticket không có quan hệ đọc về Cinema sau lúc bán (như UC-010).
- Danh sách cụm rạp được lặp ở control (Q-246). Nếu P08 thêm entity nắm tập cụm rạp thì trách nhiệm liệt kê, kiểm tên và ghi cụm rạp dự kiến chuyển cho entity đó và điểm tuần tự theo tập tự nhiên nằm ở đó.
- UC-012 dùng cùng lớp AC-E-Cinema (mã theo P08) và bổ sung trách nhiệm quản lý phòng chiếu; UC-014 hiện dùng thuộc tính cinema rút gọn, P08 đã thay bằng đường tới Cinema.
- ManageCinemasController có 7 trách nhiệm (trong ngưỡng 2-10), không giữ quy tắc thuộc dữ liệu của cụm rạp. Không có tác nhân thời gian, không có message hẹn mốc (A2).
- Thứ tự báo khi vừa tên trùng vừa cụm rạp đã bị sửa: P04 không nêu; phân tích báo 5b trước 5a theo thứ tự chữ của bước 5 (Q-254 hỏi chung cho UC-012; UC-011 theo kết quả trả lời).
