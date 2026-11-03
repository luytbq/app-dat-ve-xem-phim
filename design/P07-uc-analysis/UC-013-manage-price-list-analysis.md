# P07 - Phân tích use case UC-013 Quản lý bảng giá - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P07 |
| Phiên bản | 1.1 |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md; P04-uc-specs/UC-013-manage-price-list.md 1.2; P01-actors.md 1.1; P02-usecases.md 1.8; P03-usecase-model.md 1.0; P05-glossary.md 1.1; P06-supplementary-spec.md 1.1; P04-uc-specs/_BR-register.md; P07-uc-analysis/UC-005-book-tickets-analysis.md 1.1 (F1, F3.4, F8 b), Câu hỏi mở, Vấn đề còn mở) làm sổ đăng ký AC; P07-uc-analysis/_review-P07-batch.md |
| Phạm vi | UC-013 |
| Mã Q, ASM cuối đã cấp | Q-100; không có ASM (NGHIEM_NGAT) |

## 1. Bối cảnh use case

| Thuộc tính | Giá trị |
|---|---|
| Mã và tên UC | UC-013 Quản lý bảng giá (Manage Price List) |
| Tác nhân chính | ACT-04 Quản lý cụm rạp (Người) |
| Tác nhân phụ | Không có |
| Include (UC) | Không có |
| Được include bởi (UC) | Không có |
| Extend (UC, điểm mở rộng, điều kiện) | Không có |
| Được extend bởi (UC, điểm mở rộng, điều kiện) | Không có |
| Use case liên quan không qua include, extend | UC-005 chốt giá vé khi giữ ghế (bước 7) và loại trừ với việc lưu thay đổi bảng giá (BR-65, BR-71); UC-014 lưu suất chiếu (bước 8) loại trừ với việc bỏ mục giá (BR-64, BR-68, BR-69); UC-012 chưa đặc tả, có thể làm suất chiếu thiếu giá (BR-73); UC-017 sở hữu khái niệm nhân viên và cụm rạp của nhân viên. Q-83 (điểm tiếp nhận báo kết quả giao dịch của cổng) không liên quan tới UC-013: use case này không có tác nhân phụ và không nhận kết quả giao dịch, nên không có phụ thuộc cần ghi |
| Tác nhân thời gian | Không có. Thay đổi bảng giá có hiệu lực ngay khi lưu (BR-66), P04 Mục 8 ghi không có bước hẹn hoặc huỷ mốc, và P02 không có use case do tác nhân thời gian kích hoạt trên mục giá, nên không có message hẹn mốc (A2) |
| File P07 đã có được dùng làm sổ đăng ký AC | UC-005-book-tickets-analysis.md: dùng lại AC-E-PriceList (UC-005 ghi "Mới - chủ sở hữu UC-013"; UC-013 là chủ sở hữu nên bổ sung trách nhiệm) và AC-E-Showtime (chủ sở hữu UC-014) |

## 2. Đặc tả bổ sung

| Bước UC | Thực hiện bởi | Mô tả trong đặc tả | Mô tả bổ sung (hệ thống làm gì bên trong) | Nguồn (BR, GL, REQ) |
|---|---|---|---|---|
| 1 | Quản lý cụm rạp | Yêu cầu thiết lập bảng giá của cụm rạp. | Không đổi | REQ-59 |
| 2 | Hệ thống | Hiển thị bảng giá hiện tại của cụm rạp mà quản lý cụm rạp thuộc về. | Hồ sơ quản lý cụm rạp cho biết cụm rạp của quản lý, chỉ bảng giá của cụm đó được xem. Bảng giá lấy từng mục giá (loại phòng, định dạng phim, loại ghế, khung giờ chiếu, giá vé) và ghi lại tình trạng từng mục giá lúc hiển thị để so ở bước 5. | BR-61, BR-62, GL-01, GL-33, REQ-37, REQ-38 |
| 3 | Quản lý cụm rạp | Chọn tổ hợp loại phòng, định dạng phim, loại ghế và khung giờ chiếu, nhập giá vé của tổ hợp đó rồi gửi. | Không đổi | BR-11, BR-12 |
| 4 | Hệ thống | Kiểm tra giá vé đã nhập hợp lệ. | Bảng giá kiểm tra giá vé là số nguyên đồng lớn hơn 0, không có giá trị tối đa. Tổ hợp nào cũng đặt được giá, kể cả loại phòng cụm rạp chưa có, nên không kiểm tra tổ hợp. | BR-70, REQ-147 |
| 5 | Hệ thống | Kiểm tra mục giá của tổ hợp chưa bị yêu cầu khác đổi, tạo hoặc bỏ kể từ lúc hiển thị ở bước 2, rồi lưu giá vé cho tổ hợp với hiệu lực ngay, tất cả là một thao tác không chia cắt. | Bảng giá so tình trạng mục giá của tổ hợp với tình trạng lúc hiển thị (đã có, chưa có, mốc thay đổi), đạt thì tìm mục giá của tổ hợp hoặc tạo mới rồi ghi giá vé. Thao tác loại trừ với việc chốt giá của UC-005 bước 7 trên cùng bảng giá, nên lần giữ ghế chốt giá trước đó không bị đổi giá. Lần giữ ghế và vé đã bán giữ giá đã chốt ở ghế và ở vé, không đọc lại bảng giá. | BR-62, BR-63, BR-65, BR-66, BR-67, BR-71, REQ-148, REQ-149, REQ-150 |
| 6 | Hệ thống | Thông báo lưu giá thành công và hiển thị mục giá đã lưu. | Control nhận mục giá đã lưu từ bảng giá và chuyển cho boundary hiển thị cùng thông báo thành công. Có hiệu lực ngay, không có ngày hiệu lực hẹn trước. | BR-66, REQ-150 |
| 1a | Quản lý cụm rạp | Chọn bỏ giá của một tổ hợp thay vì đặt giá. | Không đổi | REQ-146 |
| 1a1 | Hệ thống | Hiển thị bảng giá hiện tại của cụm rạp mà quản lý cụm rạp thuộc về. | Như bước 2: xác định cụm rạp của quản lý, lấy từng mục giá và ghi tình trạng lúc hiển thị để so ở 1a3. | BR-61, GL-01, GL-33 |
| 1a2 | Quản lý cụm rạp | Chọn mục giá cần bỏ. | Không đổi | BR-61 |
| 1a3 | Hệ thống | Kiểm tra mục giá đã chọn chưa bị yêu cầu khác đổi hoặc bỏ kể từ lúc hiển thị ở bước 1a1 và cụm rạp không còn suất chiếu chưa tới giờ bắt đầu đang dùng mục giá đó, rồi bỏ mục giá khỏi bảng giá, tất cả là một thao tác không chia cắt với việc lưu suất chiếu của UC-014 và với việc chốt giá của UC-005. | Bảng giá so tình trạng mục giá với lúc hiển thị, rồi hỏi các suất chiếu của cụm rạp đang chưa tới giờ bắt đầu và còn trong lịch chiếu xem có suất nào cùng loại phòng, cùng định dạng, có ghế thuộc loại ghế của mục giá và có khung giờ của giờ bắt đầu bằng khung giờ của mục giá (đủ bốn yếu tố). Không có suất nào dùng thì bảng giá bỏ mục giá. Cùng thao tác với việc kiểm tra bảng giá rồi lưu suất chiếu của UC-014 và với việc chốt giá của UC-005, nên bên ghi nhận trước thắng. | BR-12, BR-57, BR-58, BR-63, BR-64, BR-68, BR-71, REQ-146, REQ-151 |
| 1a3a | Hệ thống | Mục giá đã chọn đã bị yêu cầu khác đổi hoặc bỏ kể từ lúc hiển thị ở bước 1a1; kiểm trước 1a3b. Từ chối bỏ giá, không ghi đè, và thông báo mục giá đã thay đổi hoặc không còn; quản lý cụm rạp mở lại bảng giá từ đầu. | Bảng giá báo tình trạng mục giá lúc hiển thị khác tình trạng hiện tại, không kiểm tra suất chiếu và không đổi bảng giá. Control chuyển lý do cho boundary thông báo. | BR-63 |
| 1a3b | Hệ thống | Cụm rạp còn suất chiếu chưa tới giờ bắt đầu đang dùng mục giá đã chọn, không thuộc 1a3a. Từ chối bỏ giá và thông báo quy tắc bị vi phạm. | Suất chiếu báo đang dùng mục giá, bảng giá giữ nguyên mục giá. Control chuyển quy tắc bị vi phạm cho boundary thông báo. | BR-64 |
| 1a4 | Hệ thống | Thông báo bỏ giá thành công. | Control chuyển kết quả bỏ giá thành công cho boundary hiển thị. Lần giữ ghế và vé đã bán không đổi giá. | BR-65, BR-66, BR-67 |
| 4a | Hệ thống | Giá vé đã nhập không hợp lệ. Từ chối lưu giá và thông báo quy tắc bị vi phạm. | Bảng giá báo giá vé không đạt điều kiện, control chuyển quy tắc bị vi phạm cho boundary thông báo; bảng giá không đổi, quản lý cụm rạp nhập lại ở bước 3. | BR-70 |
| 5a | Hệ thống | Mục giá của tổ hợp đã bị yêu cầu khác đổi, tạo hoặc bỏ kể từ lúc hiển thị. Từ chối lưu giá, không ghi đè, và thông báo mục giá đã thay đổi; quản lý cụm rạp mở lại bảng giá từ đầu. | Bảng giá báo tình trạng mục giá của tổ hợp khác tình trạng lúc hiển thị, không tạo mục giá và không ghi giá. Người lưu sau bị từ chối, thay đổi trước giữ nguyên. | BR-63, REQ-148 |
| *a | Hệ thống | Tại bất kỳ bước nào trước bước 5, kể cả trong luồng 1a trước bước 1a3, quản lý cụm rạp huỷ yêu cầu. Huỷ yêu cầu, không thay đổi bảng giá. | Không có thời hạn; huỷ có thể xảy ra ở mọi bước từ 1 đến 4 và từ 1a đến 1a2. Control bỏ yêu cầu đang xử lý, bảng giá không bị chạm tới. | P04 Mục 3 luồng *a |

## 3. Tìm lớp phân tích

### 3.1 Bảng boundary

| Tác nhân (ACT) | Loại tác nhân | Boundary | Loại boundary | Mới hoặc tái dùng (AC, UC nguồn) | Lý do |
|---|---|---|---|---|---|
| ACT-04 Quản lý cụm rạp | Người | ManagePriceListForm | Giao diện người dùng | Mới (AC-B-ManagePriceListForm) | Quản lý cụm rạp xem bảng giá, nhập giá, chọn mục giá bỏ, huỷ và nhận thông báo kết quả. Một boundary cho cặp tác nhân và use case, không tách theo màn hình |

### 3.2 Bảng lọc danh từ

| STT | Danh từ hoặc cụm danh từ | Vị trí (bước UC, mục dữ liệu, BR) | Kết luận | Lý do |
|---|---|---|---|---|
| 1 | Quản lý cụm rạp | Tác nhân chính, BR-61 | Loại - là tác nhân hoặc ngoài phạm vi | Tác nhân ACT-04. Hồ sơ của quản lý được giữ lại ở dòng 2 |
| 2 | Hồ sơ quản lý cụm rạp (cụm rạp mà quản lý thuộc về) | Bước 2, 1a1, BR-61, tiền điều kiện | Entity (AC-E-CinemaManager) | Entity biểu diễn thông tin về tác nhân, không phải bản thân tác nhân. Cho biết cụm rạp để chỉ xem và sửa bảng giá cụm mình; khái niệm do UC-017 quản lý (GL-42). Q-100 |
| 3 | Bảng giá | Bước 2, 5, 1a1, 1a3, Dữ liệu ra 1, BR-61, BR-62 | Entity (AC-E-PriceList) | Tái dùng mã của UC-005; có định danh theo cụm rạp, có hành vi trên mục giá của mình (GL-01) |
| 4 | Mục giá | Bước 5, 1a2, Dữ liệu vào 2, BR-62 | Entity (AC-E-PriceEntry) | Có bốn yếu tố làm khoá nghiệp vụ, có giá riêng, được tạo, đổi giá và bỏ khỏi bảng giá bằng các thao tác riêng (GL-33) |
| 5 | Tổ hợp (loại phòng, định dạng phim, loại ghế, khung giờ chiếu) | Bước 3, 5, BR-62 | Loại - thuộc tính của PriceEntry | P05 mục 3: cách gọi bốn yếu tố của mục giá, không phải khái niệm riêng |
| 6 | Loại phòng | Bước 3, 1a3, Dữ liệu vào 1, BR-11, BR-64 | Loại - thuộc tính của PriceEntry | Một trong ba giá trị (GL-27); phòng chiếu và loại phòng thuộc UC-012, ở đây chỉ là yếu tố của mục giá (auditoriumType) |
| 7 | Định dạng phim | Bước 3, 1a3, Dữ liệu vào 1, BR-64 | Loại - thuộc tính của PriceEntry | Một trong hai giá trị (GL-05); movieFormat |
| 8 | Loại ghế | Bước 3, 1a3, Dữ liệu vào 1, BR-64 | Loại - thuộc tính của PriceEntry | Một trong ba giá trị (GL-26); seatType |
| 9 | Khung giờ chiếu | Bước 3, 1a3, Dữ liệu vào 1, BR-11, BR-12 | Loại - thuộc tính của PriceEntry | Một trong bốn giá trị (GL-22); timeBand. Khung giờ của suất chiếu suy ra từ giờ bắt đầu khi cần |
| 10 | Giá vé | Bước 3, 4, 5, Dữ liệu vào 1 trường 5, BR-70 | Loại - thuộc tính của PriceEntry | Không có định danh và hành vi riêng (GL-10); ticketPrice. Điều kiện hợp lệ do PriceList kiểm tra |
| 11 | Suất chiếu | 1a3, 1a3b, BR-64, BR-68 | Entity (AC-E-Showtime) | Tái dùng mã của UC-005; use case hỏi suất chiếu có đang dùng mục giá không (GL-47). Chủ sở hữu UC-014 |
| 12 | Giờ bắt đầu | 1a3, BR-12, BR-64 | Loại - thuộc tính của Showtime | startTime (GL-14) |
| 13 | Lịch chiếu | 1a3b, BR-64 | Loại - trùng hoặc đồng nghĩa với Showtime | P05 mục 3: cách gọi tập hợp các suất chiếu, không phải thực thể riêng. Suất chiếu đã xoá khỏi lịch chiếu mang scheduleStatus, Q-98 |
| 14 | Phòng chiếu | 1a3, 1a3b, BR-64 | Loại - khái niệm do UC-012 tạo, use case này chỉ đọc qua entity Showtime | Loại phòng và loại ghế có trong phòng đọc qua suất chiếu, như UC-005 Q-81. Q-98 |
| 15 | Ghế | 1a3, 1a3b, BR-64 | Loại - khái niệm do UC-012 tạo, use case này chỉ đọc qua entity Showtime | Suất chiếu biết các ghế của mình; chỉ cần biết có ghế thuộc loại ghế của mục giá hay không |
| 16 | Cụm rạp | Bước 2, 1a3, BR-61 | Loại - thuộc tính của PriceList | Thuộc tính cinema của PriceList, CinemaManager và Showtime; chưa tách entity, như UC-005 Q-81 |
| 17 | Lần giữ ghế | Hậu điều kiện, BR-65, BR-71 | Loại - không tham gia hành vi của use case này (khái niệm của UC-005) | UC-013 không đọc hay ghi lần giữ ghế; giá đã chốt nằm ở lần giữ ghế do UC-005 bước 7 ghi, nên đổi giá không chạm tới nó |
| 18 | Vé đã bán, giá vé đã ghi trên vé | Hậu điều kiện, BR-67 | Loại - không tham gia hành vi của use case này (khái niệm của UC-005) | Vé giữ giá đã ghi (BR-67), use case không đọc vé |
| 19 | Số tiền hoàn, doanh thu | Mục 8, BR-67 | Loại - không tham gia hành vi của use case này (khái niệm của UC-008, UC-015) | Chỉ được nhắc tới để nói đổi giá không ảnh hưởng |
| 20 | Yêu cầu khác (của quản lý khác hoặc phiên khác) | Bước 5, 1a3, BR-63 | Loại - thao tác hoặc sự kiện | Là một lần đặt giá hoặc bỏ giá khác; hệ quả được so bằng tình trạng mục giá lúc hiển thị |
| 21 | Tình trạng mục giá lúc hiển thị | Bước 5, 1a3, BR-63 | Loại - thuộc tính của PriceList | entryChangeTimes: mốc thay đổi gần nhất của từng tổ hợp, kể cả tổ hợp đã bỏ. Q-99 |
| 22 | Thao tác không chia cắt | Bước 5, 1a3, BR-68, BR-71 | Loại - thao tác hoặc sự kiện | Cách thực hiện, được giao cho PriceList // savePriceEntry và // removePriceEntry |
| 23 | Ngày thường, cuối tuần, 17 giờ | Bước 3, BR-11, BR-12 | Loại - tham số của quy tắc BR-12 | Giá trị của khung giờ chiếu |
| 24 | Số nguyên đồng, giá trị tối đa, 72 mục giá | Dữ liệu vào 1, BR-70, Mục 8 | Loại - tham số của quy tắc BR-70 | Điều kiện hợp lệ và cận trên của số mục giá (BR-62) |
| 25 | Thông báo, lý do từ chối | Bước 6, 1a3a, 1a3b, 1a4, 4a, 5a | Loại - dữ liệu trao đổi qua boundary ManagePriceListForm | Không lưu |
| 26 | Phiên làm việc | Tiền điều kiện | Loại - là tác nhân hoặc ngoài phạm vi | Đăng nhập không mô hình hoá (project-profile mục 4) |
| 27 | Hệ thống | Các bước hệ thống | Loại - mơ hồ | Chỉ bên thực hiện bước |
| 28 | Kết quả | Bước 6, 1a4 | Loại - mơ hồ | Chỉ là thông báo thành công hoặc thất bại, đã tính ở dòng 25 |

### 3.3 Bảng control

| Control | Use case điều phối | Mới hoặc tái dùng | Lý do (hoặc lý do không có control) |
|---|---|---|---|
| ManagePriceListController | UC-013 | Mới (AC-C-ManagePriceListController) | Một control cho use case: nhận yêu cầu từ boundary, điều phối hiển thị bảng giá, kiểm tra giá vé, lưu giá hoặc bỏ giá, báo kết quả cho boundary. Quy tắc về giá vé, mục giá, so tình trạng lúc hiển thị và suất chiếu đang dùng nằm ở entity. Có 6 trách nhiệm |

### 3.4 Bảng lớp phân tích

| AC | Stereotype | Tên | Trách nhiệm | Thuộc tính chính | Bước UC nguồn | Loại boundary | Mới hoặc tái dùng | GL |
|---|---|---|---|---|---|---|---|---|
| AC-B-ManagePriceListForm | boundary | ManagePriceListForm | // requestPriceListSetup: quản lý cụm rạp yêu cầu thiết lập bảng giá<br>// showPriceList: hiển thị bảng giá của cụm rạp, giữ tình trạng từng mục giá lúc hiển thị<br>// enterPriceEntry: quản lý cụm rạp chọn tổ hợp, nhập giá vé rồi gửi<br>// notifyRefusal: thông báo từ chối kèm quy tắc bị vi phạm hoặc lý do<br>// showSavedPriceEntry: thông báo lưu giá thành công và hiển thị mục giá đã lưu<br>// requestPriceRemoval: quản lý cụm rạp chọn bỏ giá thay vì đặt giá<br>// selectPriceEntryToRemove: quản lý cụm rạp chọn mục giá cần bỏ<br>// showRemovalSuccess: thông báo bỏ giá thành công<br>// cancelRequest: quản lý cụm rạp huỷ yêu cầu | displayedPriceList (Bảng giá đang hiển thị, kèm tình trạng từng mục giá lúc hiển thị)<br>enteredPriceEntry (Tổ hợp bốn yếu tố và giá vé đã nhập)<br>selectedPriceEntry (Mục giá đã chọn để bỏ) | 1, 2, 3, 4a, 5a, 6, 1a, 1a1, 1a2, 1a3a, 1a3b, 1a4, *a | Giao diện người dùng | Mới | GL-42 |
| AC-C-ManagePriceListController | control | ManagePriceListController | // startPriceListSetup: điều phối bước 1 và 2: xác định cụm rạp của quản lý, lấy bảng giá để hiển thị<br>// submitPriceEntry: điều phối bước 4 đến 6: kiểm tra giá vé, lưu giá, báo kết quả<br>// startPriceRemoval: điều phối bước 1a1: xác định cụm rạp của quản lý, lấy bảng giá để hiển thị<br>// submitPriceEntryRemoval: điều phối bước 1a3 và 1a4: bỏ giá, báo kết quả<br>// cancelRequest: điều phối luồng *a: huỷ yêu cầu<br>// discardRequest: bỏ yêu cầu, không đổi bảng giá (luồng *a) | - | 1 đến 6, 1a đến 1a4, 4a, 5a, *a | - | Mới | - |
| AC-E-CinemaManager | entity | CinemaManager | // provideCinema: cung cấp cụm rạp mà quản lý cụm rạp thuộc về, để chỉ xem và sửa bảng giá cụm mình (BR-61) | cinema (Cụm rạp của quản lý cụm rạp) | 2, 1a1 | - | Mới - chủ sở hữu UC-017 | GL-42 |
| AC-E-PriceList | entity | PriceList | // providePriceEntries: cung cấp các mục giá của bảng giá kèm tình trạng từng mục giá lúc hiển thị (BR-62)<br>// checkTicketPriceValid: kiểm tra giá vé là số nguyên đồng lớn hơn 0 (BR-70)<br>// savePriceEntry: thao tác không chia cắt: kiểm tra mục giá của tổ hợp chưa bị đổi, tạo mục giá hoặc đổi giá, có hiệu lực ngay (BR-62, BR-63, BR-66, BR-71)<br>// checkEntryUnchangedSinceDisplayed: kiểm tra mục giá của tổ hợp chưa bị yêu cầu khác đổi, tạo hoặc bỏ kể từ lúc hiển thị (BR-63)<br>// findOrCreatePriceEntry: tìm mục giá của tổ hợp, chưa có thì tạo mục giá mới trong bảng giá (BR-62)<br>// removePriceEntry: thao tác không chia cắt: kiểm tra mục giá chưa bị đổi, kiểm tra không còn suất chiếu đang dùng, bỏ mục giá (BR-63, BR-64, BR-68, BR-71)<br>// deletePriceEntry: bỏ mục giá khỏi bảng giá, ghi mốc thay đổi của tổ hợp<br>// determineTimeBand: xác định khung giờ chiếu từ giờ bắt đầu (BR-12), nơi duy nhất xác định khung giờ cho UC-005, UC-013 và UC-014 | cinema (Cụm rạp)<br>entryChangeTimes (Mốc thay đổi gần nhất của từng tổ hợp, kể cả tổ hợp đã bỏ) (mới ở UC này) | 2, 4, 5, 1a1, 1a3 | - | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-01 |
| AC-E-PriceEntry | entity | PriceEntry | // provideEntryInfo: cung cấp loại phòng, định dạng phim, loại ghế, khung giờ chiếu, giá vé và mốc thay đổi để hiển thị<br>// setTicketPrice: ghi giá vé của mục giá và mốc thay đổi, không đổi giá đã chốt của lần giữ ghế và vé đã bán (BR-65, BR-67) | auditoriumType (Văn bản)<br>movieFormat (Văn bản)<br>seatType (Văn bản)<br>timeBand (Văn bản)<br>ticketPrice (Số tiền)<br>lastChangedAt (Ngày giờ) | 2, 5, 1a1 | - | Mới - chạy song song, chờ P08 hợp nhất | GL-33 |
| AC-E-Showtime | entity | Showtime | // checkUsesPriceEntry: kiểm tra suất chiếu chưa tới giờ bắt đầu, còn trong lịch chiếu, cùng loại phòng, định dạng, khung giờ (hỏi PriceList xác định từ giờ bắt đầu) và có ghế thuộc loại ghế của mục giá (BR-64) | startTime (Ngày giờ)<br>movieFormat (Văn bản)<br>auditoriumType (Văn bản)<br>cinema (Cụm rạp)<br>scheduleStatus (Trạng thái: còn trong lịch chiếu hoặc đã xoá) (mới ở UC này) | 1a3, 1a3b | - | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-47 |

Tổng cộng 6 lớp: 1 boundary, 1 control, 4 entity. Entity cốt lõi của chủ đề race condition: AC-E-PriceList (loại trừ giữa hai quản lý cùng sửa một mục giá, giữa bỏ giá với lưu suất chiếu của UC-014 và giữa lưu giá với chốt giá của UC-005), AC-E-PriceEntry, AC-E-Showtime.

## 4. Phân bổ hành vi

| Bước UC | Trách nhiệm | Lớp nhận (AC) | Nguyên tắc | Lý do khi có lựa chọn khác |
|---|---|---|---|---|
| 1 | // requestPriceListSetup | AC-B-ManagePriceListForm | Giao tiếp tác nhân | - |
| 1, 2 | // startPriceListSetup | AC-C-ManagePriceListController | Controller | - |
| 2 | // provideCinema | AC-E-CinemaManager | Information Expert | Cụm rạp của quản lý nằm ở hồ sơ quản lý. Giao cho control thì control giữ dữ liệu nhân sự, cao coupling và mất cohesion |
| 2 | // providePriceEntries | AC-E-PriceList | Information Expert | Bảng giá là đối tượng toàn thể nắm các mục giá (BR-62), nên liệt kê để hiển thị giao cho bảng giá và nó gửi message tới từng mục giá trong loop; control lặp thì phải biết cấu trúc của bảng giá |
| 2 | // provideEntryInfo | AC-E-PriceEntry | Information Expert | - |
| 2 | // showPriceList | AC-B-ManagePriceListForm | Giao tiếp tác nhân | - |
| 3 | // enterPriceEntry | AC-B-ManagePriceListForm | Giao tiếp tác nhân | - |
| 3 | // submitPriceEntry | AC-C-ManagePriceListController | Controller | - |
| 4 | // checkTicketPriceValid | AC-E-PriceList | Information Expert | Giá vé là thuộc tính của mục giá nhưng mục giá của tổ hợp có thể chưa tồn tại lúc kiểm; bảng giá nắm quy tắc về mục giá (BR-62, BR-70). Giao cho control là để quy tắc dữ liệu ở control (god control) |
| 4a | // notifyRefusal | AC-B-ManagePriceListForm | Giao tiếp tác nhân | - |
| 5 | // savePriceEntry | AC-E-PriceList | Information Expert | Dữ liệu ở bảng giá (tập mục giá, mốc thay đổi) và ở mục giá (giá). Giao cho bảng giá vì nó là toàn thể, và vì chốt giá của UC-005 (// determineSeatPrice) cũng chạy trên bảng giá nên loại trừ BR-71 đặt tại một lớp. Giao cho control thì kiểm tra và ghi tách rời, vi phạm thao tác không chia cắt; giao cho mục giá thì không xử lý được tổ hợp chưa có mục giá |
| 5 | // checkEntryUnchangedSinceDisplayed | AC-E-PriceList | Information Expert | Mốc thay đổi của từng tổ hợp kể cả tổ hợp đã bỏ do bảng giá giữ, mục giá đã bỏ không còn để tự khai báo (Q-99) |
| 5 | // findOrCreatePriceEntry | AC-E-PriceList | Creator | Bảng giá chứa mục giá nên tạo mục giá mới (BR-62) |
| 5 | // setTicketPrice | AC-E-PriceEntry | Information Expert | - |
| 5a | // notifyRefusal | AC-B-ManagePriceListForm | Giao tiếp tác nhân | - |
| 6 | // showSavedPriceEntry | AC-B-ManagePriceListForm | Giao tiếp tác nhân | - |
| 1a | // requestPriceRemoval | AC-B-ManagePriceListForm | Giao tiếp tác nhân | - |
| 1a1 | // startPriceRemoval | AC-C-ManagePriceListController | Controller | - |
| 1a1 | // provideCinema, // providePriceEntries, // provideEntryInfo, // showPriceList | AC-E-CinemaManager, AC-E-PriceList, AC-E-PriceEntry, AC-B-ManagePriceListForm | Information Expert / Giao tiếp tác nhân | Như bước 2 |
| 1a2 | // selectPriceEntryToRemove | AC-B-ManagePriceListForm | Giao tiếp tác nhân | - |
| 1a3 | // submitPriceEntryRemoval | AC-C-ManagePriceListController | Controller | - |
| 1a3 | // removePriceEntry | AC-E-PriceList | Information Expert | Dữ liệu ở bảng giá (mục giá, mốc thay đổi) và ở suất chiếu (giờ bắt đầu, loại phòng, định dạng). Giao cho bảng giá điều phối thao tác không chia cắt và hỏi suất chiếu qua quan hệ giữa hai lớp, vì bước sau của UC-014 cũng chạy trên cặp này (BR-68). Control gọi lần lượt suất chiếu rồi bảng giá thì kiểm tra và bỏ bị chia cắt |
| 1a3 | // checkEntryUnchangedSinceDisplayed | AC-E-PriceList | Information Expert | Như bước 5 |
| 1a3 | // checkUsesPriceEntry | AC-E-Showtime | Information Expert | Suất chiếu giữ giờ bắt đầu, loại phòng, định dạng, trạng thái trong lịch chiếu và các ghế của mình; bảng giá chỉ truyền bốn yếu tố của mục giá, không đọc dữ liệu suất chiếu |
| 1a3 | // determineTimeBand | AC-E-PriceList | Information Expert | Khung giờ chỉ được xác định ở bảng giá cho cả UC-005, UC-013, UC-014 (BR-12, Q-104); Showtime hỏi PriceList thay vì tự xác định. |
| 1a3 | // deletePriceEntry | AC-E-PriceList | Information Expert | Bảng giá là toàn thể của mục giá nên bỏ mục giá (composition) |
| 1a3a | // notifyRefusal | AC-B-ManagePriceListForm | Giao tiếp tác nhân | - |
| 1a3b | // notifyRefusal | AC-B-ManagePriceListForm | Giao tiếp tác nhân | - |
| 1a4 | // showRemovalSuccess | AC-B-ManagePriceListForm | Giao tiếp tác nhân | - |
| *a | // cancelRequest | AC-B-ManagePriceListForm, AC-C-ManagePriceListController | Giao tiếp tác nhân / Controller | - |
| *a | // discardRequest | AC-C-ManagePriceListController | Controller | Control chỉ bỏ yêu cầu, không giữ dữ liệu nghiệp vụ nên không có lựa chọn khác |

## 5. Sequence diagram phân tích

File diagrams/P07-sequence-UC-013.drawio có 3 trang. Cả ba trang dưới ngưỡng 30 message và 3 fragment ở mức ngoài cùng. Mọi fragment break nằm trực tiếp ở mức ngoài cùng của trang.

### a) SD1 - Luồng chính, 4a, 5a

Luồng 4a là alt "quay lại bước 3" (toán hạng luồng chính chỉ ghi guard và note). Luồng 5a kết thúc use case nên dùng break ở mức ngoài cùng, đặt sau lời gọi lưu giá. Message 2.1.3.2 và 2.1.3.3 chỉ chạy khi 2.1.3.1 đạt (ghi bằng note); gộp tạo mục giá hoặc đổi giá vào một message tự gọi // findOrCreatePriceEntry để trang không vượt 3 fragment, việc tạo mục giá là Creator của bảng giá.

b) Bảng Node

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1-L-A4 | Actor | :Quản lý cụm rạp | - | - | Tác nhân (ACT-04) |
| SD1-L-PF | Lifeline | :ManagePriceListForm | «boundary» | - | AC-B-ManagePriceListForm |
| SD1-L-C | Lifeline | :ManagePriceListController | «control» | - | AC-C-ManagePriceListController |
| SD1-L-CM | Lifeline | :CinemaManager | «entity» | - | AC-E-CinemaManager |
| SD1-L-PL | Lifeline | :PriceList | «entity» | - | AC-E-PriceList |
| SD1-L-PE | Lifeline | :PriceEntry | «entity» | - | AC-E-PriceEntry |
| SD1-F1 | Fragment | loop [mỗi mục giá của bảng giá] | - | - | Bao các message của fragment |
| SD1-F2 | Fragment | alt [giá vé không hợp lệ (4a)] | - | - | Bao các message của fragment |
| SD1-F2-O2 | Fragment | [giá vé hợp lệ] | - | SD1-F2 | Toán hạng thứ hai; đường ngăn là edge SD1-F2-O2-SEP nét đứt |
| SD1-F3 | Fragment | break [mục giá của tổ hợp đã bị yêu cầu khác đổi, tạo hoặc bỏ kể từ lúc hiển thị (5a)] | - | - | Bao các message của fragment |
| SD1-N1 | Note | quay lại bước 3 | - | - | Chú thích |
| SD1-N2 | Note | tiếp tục luồng chính | - | - | Chú thích |
| SD1-N3 | Note | 2.1.3.2 và 2.1.3.3 chỉ chạy khi 2.1.3.1 đạt | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1 | :Quản lý cụm rạp | :ManagePriceListForm | // requestPriceListSetup | Đồng bộ | - | 1 |
| 1.1 | :ManagePriceListForm | :ManagePriceListController | // startPriceListSetup | Đồng bộ | - | 1 |
| 1.1.1 | :ManagePriceListController | :CinemaManager | // provideCinema (BR-61) | Đồng bộ | - | 2 |
| 1.1.1 (trả về) | :CinemaManager | :ManagePriceListController | cụm rạp của quản lý cụm rạp | Trả về | - | 2 |
| 1.1.2 | :ManagePriceListController | :PriceList | // providePriceEntries (cụm rạp) | Đồng bộ | - | 2 |
| 1.1.2.1 | :PriceList | :PriceEntry | // provideEntryInfo | Đồng bộ | SD1-F1 | 2 |
| 1.1.2.1 (trả về) | :PriceEntry | :PriceList | bốn yếu tố, giá vé, mốc thay đổi | Trả về | SD1-F1 | 2 |
| 1.1.2 (trả về) | :PriceList | :ManagePriceListController | bảng giá kèm tình trạng từng mục giá lúc hiển thị | Trả về | - | 2 |
| 1.1.3 | :ManagePriceListController | :ManagePriceListForm | // showPriceList (bảng giá, tình trạng lúc hiển thị) | Đồng bộ | - | 2 |
| 2 | :Quản lý cụm rạp | :ManagePriceListForm | // enterPriceEntry (tổ hợp, giá vé) | Đồng bộ | - | 3 |
| 2.1 | :ManagePriceListForm | :ManagePriceListController | // submitPriceEntry (tổ hợp, giá vé, tình trạng lúc hiển thị) | Đồng bộ | - | 3 |
| 2.1.1 | :ManagePriceListController | :PriceList | // checkTicketPriceValid (giá vé) | Đồng bộ | - | 4 |
| 2.1.1 (trả về) | :PriceList | :ManagePriceListController | giá vé hợp lệ hoặc không | Trả về | - | 4 |
| 2.1.2 | :ManagePriceListController | :ManagePriceListForm | // notifyRefusal (giá vé không hợp lệ, BR-70) | Đồng bộ | SD1-F2 | 4a |
| 2.1.3 | :ManagePriceListController | :PriceList | // savePriceEntry (tổ hợp, giá vé, tình trạng lúc hiển thị) | Đồng bộ | - | 5 |
| 2.1.3.1 | :PriceList | :PriceList | // checkEntryUnchangedSinceDisplayed (tổ hợp, tình trạng lúc hiển thị) | Tự gọi | - | 5 |
| 2.1.3.2 | :PriceList | :PriceList | // findOrCreatePriceEntry (tổ hợp) | Tự gọi | - | 5 |
| 2.1.3.3 | :PriceList | :PriceEntry | // setTicketPrice (giá vé) | Đồng bộ | - | 5 |
| 2.1.3 (trả về) | :PriceList | :ManagePriceListController | mục giá đã lưu, hoặc kết quả mục giá đã bị đổi | Trả về | - | 5 |
| 2.1.4 | :ManagePriceListController | :ManagePriceListForm | // notifyRefusal (mục giá đã thay đổi, mở lại bảng giá từ đầu, BR-63) | Đồng bộ | SD1-F3 | 5a |
| 2.1.5 | :ManagePriceListController | :ManagePriceListForm | // showSavedPriceEntry (mục giá đã lưu) | Đồng bộ | - | 6 |

### a) SD2 - Luồng 1a, 1a3a, 1a3b

Trang riêng vì luồng 1a rẽ ngay từ bước 1; STT dùng hậu tố a (1a, 2a) theo F5 c). Hai luồng kết thúc thất bại 1a3a, 1a3b dùng hai break ở mức ngoài cùng theo thứ tự kiểm của P04 (1a3a trước, guard của 1a3b nêu loại trừ 1a3a). Suất chiếu :Showtime là suất chiếu của cụm rạp chưa tới giờ bắt đầu, còn trong lịch chiếu, tìm theo điều kiện (A6 a); kết quả "có hoặc không có suất chiếu đang dùng mục giá". Bốn yếu tố truyền kèm message là dữ liệu của mục giá, Showtime so với giờ bắt đầu, loại phòng, định dạng và các ghế của mình. Message 2a.1.1.2 và 2a.1.1.3 chỉ chạy khi bước trước đạt (ghi bằng note).

b) Bảng Node

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD2-L-A4 | Actor | :Quản lý cụm rạp | - | - | Tác nhân (ACT-04) |
| SD2-L-PF | Lifeline | :ManagePriceListForm | «boundary» | - | AC-B-ManagePriceListForm |
| SD2-L-C | Lifeline | :ManagePriceListController | «control» | - | AC-C-ManagePriceListController |
| SD2-L-CM | Lifeline | :CinemaManager | «entity» | - | AC-E-CinemaManager |
| SD2-L-PL | Lifeline | :PriceList | «entity» | - | AC-E-PriceList |
| SD2-L-PE | Lifeline | :PriceEntry | «entity» | - | AC-E-PriceEntry |
| SD2-L-ST | Lifeline | :Showtime | «entity» | - | AC-E-Showtime |
| SD2-F1 | Fragment | loop [mỗi mục giá của bảng giá] | - | - | Bao các message của fragment |
| SD2-F2 | Fragment | break [mục giá đã bị yêu cầu khác đổi hoặc bỏ kể từ lúc hiển thị (1a3a)] | - | - | Bao các message của fragment |
| SD2-F3 | Fragment | break [cụm rạp còn suất chiếu chưa tới giờ bắt đầu đang dùng mục giá, không thuộc 1a3a (1a3b)] | - | - | Bao các message của fragment |
| SD2-N1 | Note | 2a.1.1.2 và 2a.1.1.3 chỉ chạy khi bước trước đạt | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1a | :Quản lý cụm rạp | :ManagePriceListForm | // requestPriceRemoval | Đồng bộ | - | 1a |
| 1a.1 | :ManagePriceListForm | :ManagePriceListController | // startPriceRemoval | Đồng bộ | - | 1a1 |
| 1a.1.1 | :ManagePriceListController | :CinemaManager | // provideCinema (BR-61) | Đồng bộ | - | 1a1 |
| 1a.1.1 (trả về) | :CinemaManager | :ManagePriceListController | cụm rạp của quản lý cụm rạp | Trả về | - | 1a1 |
| 1a.1.2 | :ManagePriceListController | :PriceList | // providePriceEntries (cụm rạp) | Đồng bộ | - | 1a1 |
| 1a.1.2.1 | :PriceList | :PriceEntry | // provideEntryInfo | Đồng bộ | SD2-F1 | 1a1 |
| 1a.1.2.1 (trả về) | :PriceEntry | :PriceList | bốn yếu tố, giá vé, mốc thay đổi | Trả về | SD2-F1 | 1a1 |
| 1a.1.2 (trả về) | :PriceList | :ManagePriceListController | bảng giá kèm tình trạng từng mục giá lúc hiển thị | Trả về | - | 1a1 |
| 1a.1.3 | :ManagePriceListController | :ManagePriceListForm | // showPriceList (bảng giá, tình trạng lúc hiển thị) | Đồng bộ | - | 1a1 |
| 2a | :Quản lý cụm rạp | :ManagePriceListForm | // selectPriceEntryToRemove (mục giá) | Đồng bộ | - | 1a2 |
| 2a.1 | :ManagePriceListForm | :ManagePriceListController | // submitPriceEntryRemoval (mục giá, tình trạng lúc hiển thị) | Đồng bộ | - | 1a3 |
| 2a.1.1 | :ManagePriceListController | :PriceList | // removePriceEntry (mục giá, tình trạng lúc hiển thị) | Đồng bộ | - | 1a3 |
| 2a.1.1.1 | :PriceList | :PriceList | // checkEntryUnchangedSinceDisplayed (mục giá, tình trạng lúc hiển thị) | Tự gọi | - | 1a3 |
| 2a.1.1.2 | :PriceList | :Showtime | // checkUsesPriceEntry (loại phòng, định dạng, loại ghế, khung giờ của mục giá) | Đồng bộ | - | 1a3 |
| 2a.1.1.2.1 | :Showtime | :PriceList | // determineTimeBand (giờ bắt đầu của suất chiếu) | Đồng bộ | - | 1a3 |
| 2a.1.1.2 (trả về) | :Showtime | :PriceList | có hoặc không có suất chiếu đang dùng mục giá | Trả về | - | 1a3 |
| 2a.1.1.3 | :PriceList | :PriceList | // deletePriceEntry (mục giá) | Tự gọi | - | 1a3 |
| 2a.1.1 (trả về) | :PriceList | :ManagePriceListController | đã bỏ mục giá, hoặc lý do từ chối | Trả về | - | 1a3 |
| 2a.1.2 | :ManagePriceListController | :ManagePriceListForm | // notifyRefusal (mục giá đã thay đổi hoặc không còn, mở lại bảng giá từ đầu, BR-63) | Đồng bộ | SD2-F2 | 1a3a |
| 2a.1.3 | :ManagePriceListController | :ManagePriceListForm | // notifyRefusal (còn suất chiếu đang dùng mục giá, BR-64) | Đồng bộ | SD2-F3 | 1a3b |
| 2a.1.4 | :ManagePriceListController | :ManagePriceListForm | // showRemovalSuccess | Đồng bộ | - | 1a4 |

### a) SD3 - Luồng *a

Trang riêng theo A2 và F5 c): bắt đầu bằng ref tới SD1 và SD2, note nêu khoảng message có thể xảy ra, STT lấy message đầu khoảng kèm mã luồng (1*a). Không có break vì huỷ có thể xảy ra tại nhiều điểm; không có message hoàn tác vì bảng giá chưa bị ghi.

b) Bảng Node

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD3-L-A4 | Actor | :Quản lý cụm rạp | - | - | Tác nhân (ACT-04) |
| SD3-L-PF | Lifeline | :ManagePriceListForm | «boundary» | - | AC-B-ManagePriceListForm |
| SD3-L-C | Lifeline | :ManagePriceListController | «control» | - | AC-C-ManagePriceListController |
| SD3-R1 | Fragment | ref SD1 - Luồng chính, 4a, 5a | - | - | ref |
| SD3-R2 | Fragment | ref SD2 - Luồng 1a, 1a3a, 1a3b | - | - | ref |
| SD3-N1 | Note | có thể xảy ra tại bất kỳ message nào từ 1 đến 2.1.2 của SD1 và từ 1a đến 2a.1 của SD2 | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1*a | :Quản lý cụm rạp | :ManagePriceListForm | // cancelRequest | Đồng bộ | - | *a |
| 1*a.1 | :ManagePriceListForm | :ManagePriceListController | // cancelRequest | Đồng bộ | - | *a |
| 1*a.1.1 | :ManagePriceListController | :ManagePriceListController | // discardRequest (không đổi bảng giá) | Tự gọi | - | *a |

## 6. Quy tắc tương tác giữa các lớp phân tích

| Vi phạm | Message hoặc link | Cách sửa đã áp dụng |
|---|---|---|
| Không có | - | - |

Hai điểm đã kiểm: PriceList gửi message tới PriceEntry (quan hệ composition) và tới Showtime (quan hệ R-UC013-05, chung với R-UC005-12); Showtime gọi chính nó. Actor chỉ gửi message tới ManagePriceListForm; ManagePriceListForm chỉ gửi tới ManagePriceListController; ManagePriceListController gọi CinemaManager, PriceList và ManagePriceListForm.

## 7. Communication diagram

File diagrams/P07-communication-UC-013.drawio có 1 trang CM1 cho mọi luồng (MUC_CHI_TIET là DAY_DU): luồng chính, 4a, 5a (SD1), 1a, 1a3a, 1a3b (SD2) và *a (SD3), giữ nguyên STT của sequence diagram. Message trả về không vẽ. Link tự nối của PriceList, Showtime, ManagePriceListController không sinh quan hệ VOPC. Guard của fragment ghi trong ngoặc vuông cuối message.

### Trang CM1 - Mọi luồng

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| CM1-O-A4 | Actor | :Quản lý cụm rạp | - | - | Tác nhân (ACT-04) |
| CM1-O-PF | Object | :ManagePriceListForm | «boundary» | - | AC-B-ManagePriceListForm |
| CM1-O-C | Object | :ManagePriceListController | «control» | - | AC-C-ManagePriceListController |
| CM1-O-CM | Object | :CinemaManager | «entity» | - | AC-E-CinemaManager |
| CM1-O-PL | Object | :PriceList | «entity» | - | AC-E-PriceList |
| CM1-O-PE | Object | :PriceEntry | «entity» | - | AC-E-PriceEntry |
| CM1-O-ST | Object | :Showtime | «entity» | - | AC-E-Showtime |

b) Bảng Edge

| ID | Nguồn | Đích | Loại | Nhãn | Chiều message |
|---|---|---|---|---|---|
| CM1-L1 | CM1-O-A4 | CM1-O-PF | Link | 1: // requestPriceListSetup (-->)<br>2: // enterPriceEntry (tổ hợp, giá vé) (-->)<br>1a: // requestPriceRemoval (-->)<br>2a: // selectPriceEntryToRemove (mục giá) (-->)<br>1*a: // cancelRequest (-->) | Nguồn-->Đích: 1, 2, 1a, 2a, 1*a |
| CM1-L2 | CM1-O-PF | CM1-O-C | Link | 1.1: // startPriceListSetup (-->)<br>1.1.3: // showPriceList (bảng giá, tình trạng lúc hiển thị) (<--)<br>2.1: // submitPriceEntry (tổ hợp, giá vé, tình trạng lúc hiển thị) (-->)<br>2.1.2: // notifyRefusal (giá vé không hợp lệ, BR-70) (<--) [giá vé không hợp lệ (4a)]<br>2.1.4: // notifyRefusal (mục giá đã thay đổi, mở lại bảng giá từ đầu, BR-63) (<--) [mục giá của tổ hợp đã bị yêu cầu khác đổi, tạo hoặc bỏ kể từ lúc hiển thị (5a)]<br>2.1.5: // showSavedPriceEntry (mục giá đã lưu) (<--)<br>1a.1: // startPriceRemoval (-->)<br>1a.1.3: // showPriceList (bảng giá, tình trạng lúc hiển thị) (<--)<br>2a.1: // submitPriceEntryRemoval (mục giá, tình trạng lúc hiển thị) (-->)<br>2a.1.2: // notifyRefusal (mục giá đã thay đổi hoặc không còn, mở lại bảng giá từ đầu, BR-63) (<--) [mục giá đã bị yêu cầu khác đổi hoặc bỏ kể từ lúc hiển thị (1a3a)]<br>2a.1.3: // notifyRefusal (còn suất chiếu đang dùng mục giá, BR-64) (<--) [cụm rạp còn suất chiếu chưa tới giờ bắt đầu đang dùng mục giá, không thuộc 1a3a (1a3b)]<br>2a.1.4: // showRemovalSuccess (<--)<br>1*a.1: // cancelRequest (-->) | Nguồn-->Đích: 1.1, 2.1, 1a.1, 2a.1, 1*a.1; Đích-->Nguồn: 1.1.3, 2.1.2, 2.1.4, 2.1.5, 1a.1.3, 2a.1.2, 2a.1.3, 2a.1.4 |
| CM1-L3 | CM1-O-C | CM1-O-CM | Link | 1.1.1: // provideCinema (BR-61) (-->)<br>1a.1.1: // provideCinema (BR-61) (-->) | Nguồn-->Đích: 1.1.1, 1a.1.1 |
| CM1-L4 | CM1-O-C | CM1-O-PL | Link | 1.1.2: // providePriceEntries (cụm rạp) (-->)<br>2.1.1: // checkTicketPriceValid (giá vé) (-->)<br>2.1.3: // savePriceEntry (tổ hợp, giá vé, tình trạng lúc hiển thị) (-->)<br>1a.1.2: // providePriceEntries (cụm rạp) (-->)<br>2a.1.1: // removePriceEntry (mục giá, tình trạng lúc hiển thị) (-->) | Nguồn-->Đích: 1.1.2, 2.1.1, 2.1.3, 1a.1.2, 2a.1.1 |
| CM1-L5 | CM1-O-PL | CM1-O-PE | Link | 1.1.2.1: // provideEntryInfo (-->) [lặp: mỗi mục giá của bảng giá]<br>2.1.3.3: // setTicketPrice (giá vé) (-->)<br>1a.1.2.1: // provideEntryInfo (-->) [lặp: mỗi mục giá của bảng giá] | Nguồn-->Đích: 1.1.2.1, 2.1.3.3, 1a.1.2.1 |
| CM1-L6 | CM1-O-PL | CM1-O-PL | Link | 2.1.3.1: // checkEntryUnchangedSinceDisplayed (tổ hợp, tình trạng lúc hiển thị) (-->)<br>2.1.3.2: // findOrCreatePriceEntry (tổ hợp) (-->)<br>2a.1.1.1: // checkEntryUnchangedSinceDisplayed (mục giá, tình trạng lúc hiển thị) (-->)<br>2a.1.1.3: // deletePriceEntry (mục giá) (-->) | Nguồn-->Đích: 2.1.3.1, 2.1.3.2, 2a.1.1.1, 2a.1.1.3 |
| CM1-L7 | CM1-O-PL | CM1-O-ST | Link | 2a.1.1.2: // checkUsesPriceEntry (loại phòng, định dạng, loại ghế, khung giờ của mục giá) (-->)<br>2a.1.1.2.1: // determineTimeBand (giờ bắt đầu của suất chiếu) (<--) | Nguồn-->Đích: 2a.1.1.2; Đích-->Nguồn: 2a.1.1.2.1 |
| CM1-L8 | CM1-O-C | CM1-O-C | Link | 1*a.1.1: // discardRequest (không đổi bảng giá) (-->) | Nguồn-->Đích: 1*a.1.1 |

## 8. VOPC

File diagrams/P07-class-UC-013.drawio. ID cell của lớp là mã AC; ngăn thuộc tính và ngăn trách nhiệm có ID "<mã AC>-ATTR" và "<mã AC>-RESP".

a) Bảng Node (lớp)

| ID (mã AC) | Loại (Class) | Nhãn (tên lớp) | Stereotype | Thuộc về | Ngăn thuộc tính | Ngăn trách nhiệm |
|---|---|---|---|---|---|---|
| AC-B-ManagePriceListForm | Class | ManagePriceListForm | «boundary» | - | displayedPriceList (Bảng giá đang hiển thị, kèm tình trạng từng mục giá lúc hiển thị)<br>enteredPriceEntry (Tổ hợp bốn yếu tố và giá vé đã nhập)<br>selectedPriceEntry (Mục giá đã chọn để bỏ) | // requestPriceListSetup<br>// showPriceList<br>// enterPriceEntry<br>// notifyRefusal<br>// showSavedPriceEntry<br>// requestPriceRemoval<br>// selectPriceEntryToRemove<br>// showRemovalSuccess<br>// cancelRequest |
| AC-C-ManagePriceListController | Class | ManagePriceListController | «control» | - | - | // startPriceListSetup<br>// submitPriceEntry<br>// startPriceRemoval<br>// submitPriceEntryRemoval<br>// cancelRequest<br>// discardRequest |
| AC-E-CinemaManager | Class | CinemaManager | «entity» | - | cinema (Cụm rạp của quản lý cụm rạp) | // provideCinema |
| AC-E-PriceList | Class | PriceList | «entity» | - | cinema (Cụm rạp)<br>entryChangeTimes (Mốc thay đổi gần nhất của từng tổ hợp, kể cả tổ hợp đã bỏ) (mới ở UC này) | // providePriceEntries<br>// checkTicketPriceValid<br>// savePriceEntry<br>// checkEntryUnchangedSinceDisplayed<br>// findOrCreatePriceEntry<br>// removePriceEntry<br>// deletePriceEntry<br>// determineTimeBand |
| AC-E-PriceEntry | Class | PriceEntry | «entity» | - | auditoriumType (Văn bản)<br>movieFormat (Văn bản)<br>seatType (Văn bản)<br>timeBand (Văn bản)<br>ticketPrice (Số tiền)<br>lastChangedAt (Ngày giờ) | // provideEntryInfo<br>// setTicketPrice |
| AC-E-Showtime | Class | Showtime | «entity» | - | startTime (Ngày giờ)<br>movieFormat (Văn bản)<br>auditoriumType (Văn bản)<br>cinema (Cụm rạp)<br>scheduleStatus (Trạng thái: còn trong lịch chiếu hoặc đã xoá) (mới ở UC này) | // checkUsesPriceEntry |

b) Bảng quan hệ

| ID | Lớp A | Lớp B | Loại | Multiplicity | Vai trò | Nguồn |
|---|---|---|---|---|---|---|
| R-UC013-01 | AC-B-ManagePriceListForm | AC-C-ManagePriceListController | Association | - | - | tạm thời; link F7: CM1-L2 |
| R-UC013-02 | AC-C-ManagePriceListController | AC-E-CinemaManager | Association | - | - | tạm thời; link F7: CM1-L3 |
| R-UC013-03 | AC-C-ManagePriceListController | AC-E-PriceList | Association | - | - | tạm thời; link F7: CM1-L4 |
| R-UC013-04 | AC-E-PriceList | AC-E-PriceEntry | Composition | A 1 - B 0..72 | - | Bảng giá gồm các mục giá, mỗi tổ hợp bốn yếu tố tối đa một mục giá (BR-62, GL-01, GL-33); tối đa 3 x 2 x 3 x 4 = 72 mục giá mỗi cụm rạp (Mục 8); mục giá không tồn tại ngoài bảng giá của cụm rạp; link F7: CM1-L5 |
| R-UC013-05 | AC-E-Showtime | AC-E-PriceList | Association | A 0..* - B 1 | - | Giá lấy theo bảng giá của cụm rạp có suất chiếu (BR-11, GL-01); bỏ giá hỏi suất chiếu của cụm rạp có đang dùng mục giá (BR-64, BR-68); đường qua Cụm rạp rút gọn như R-UC005-12, Q-98; link F7: CM1-L7 |

Quan hệ ST-PL (R-UC013-05) trùng với R-UC005-12 về cặp lớp và multiplicity, P08 gộp. Quan hệ PL-PE là composition vì mục giá không tồn tại ngoài bảng giá của cụm rạp (BR-62) và bỏ mục giá là bỏ khỏi bảng giá (luồng 1a).

## 9. Ma trận truy vết

| Bước UC | Message (STT) | Lớp tham gia (AC) |
|---|---|---|
| 1 | 1, 1.1 | AC-B-ManagePriceListForm, AC-C-ManagePriceListController |
| 2 | 1.1.1, 1.1.1 (trả về), 1.1.2, 1.1.2.1, 1.1.2.1 (trả về), 1.1.2 (trả về), 1.1.3 | AC-C-ManagePriceListController, AC-E-CinemaManager, AC-E-PriceList, AC-E-PriceEntry, AC-B-ManagePriceListForm |
| 3 | 2, 2.1 | AC-B-ManagePriceListForm, AC-C-ManagePriceListController |
| 4 | 2.1.1, 2.1.1 (trả về) | AC-C-ManagePriceListController, AC-E-PriceList |
| 5 | 2.1.3, 2.1.3.1, 2.1.3.2, 2.1.3.3, 2.1.3 (trả về) | AC-C-ManagePriceListController, AC-E-PriceList, AC-E-PriceEntry |
| 6 | 2.1.5 | AC-C-ManagePriceListController, AC-B-ManagePriceListForm |
| 1a | 1a | AC-B-ManagePriceListForm |
| 1a1 | 1a.1, 1a.1.1, 1a.1.1 (trả về), 1a.1.2, 1a.1.2.1, 1a.1.2.1 (trả về), 1a.1.2 (trả về), 1a.1.3 | AC-B-ManagePriceListForm, AC-C-ManagePriceListController, AC-E-CinemaManager, AC-E-PriceList, AC-E-PriceEntry |
| 1a2 | 2a | AC-B-ManagePriceListForm |
| 1a3 | 2a.1, 2a.1.1, 2a.1.1.1, 2a.1.1.2, 2a.1.1.2.1, 2a.1.1.2 (trả về), 2a.1.1.3, 2a.1.1 (trả về) | AC-B-ManagePriceListForm, AC-C-ManagePriceListController, AC-E-PriceList, AC-E-Showtime |
| 1a3a | 2a.1.2 | AC-C-ManagePriceListController, AC-B-ManagePriceListForm |
| 1a3b | 2a.1.3 | AC-C-ManagePriceListController, AC-B-ManagePriceListForm |
| 1a4 | 2a.1.4 | AC-C-ManagePriceListController, AC-B-ManagePriceListForm |
| 4a | 2.1.2 | AC-C-ManagePriceListController, AC-B-ManagePriceListForm |
| 5a | 2.1.4 | AC-C-ManagePriceListController, AC-B-ManagePriceListForm |
| *a | 1*a, 1*a.1, 1*a.1.1 | AC-B-ManagePriceListForm, AC-C-ManagePriceListController |

## 10. File .drawio

Ba file nằm trong diagrams/: P07-sequence-UC-013.drawio (3 trang), P07-communication-UC-013.drawio (1 trang), P07-class-UC-013.drawio (1 trang). XML không nén, ID cell trùng ID trong bảng mô hình.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Trạng thái |
| --- | --- | --- | --- | --- |
| Q-98 | Việc kiểm tra "cụm rạp còn suất chiếu chưa tới giờ bắt đầu, còn trong lịch chiếu, dùng mục giá" (BR-64) cần cụm rạp, lịch chiếu, phòng chiếu, ghế. Mô hình hoá thế nào? (Giữ rút gọn như UC-005 Q-81: Showtime tự biết giờ bắt đầu, loại phòng, định dạng, các ghế qua SeatStatus, scheduleStatus; ":Showtime" là suất chiếu tìm được theo điều kiện / Tách ngay Cinema, Auditorium, Seat, và một lớp nắm lịch chiếu của cụm rạp để đếm hoặc hỏi) | AC-E-Showtime, // checkUsesPriceEntry, scheduleStatus; SD2 message 2a.1.1.2; R-UC013-05; P08 | P05 mục 3 nói lịch chiếu không phải thực thể riêng, trong khi BR-64 cần hỏi một tập suất chiếu; UC-005 Q-81 đã rút gọn Cinema, Auditorium, Seat | Gộp vào Q-81 (UC-005). Đã trả lời: giữ rút gọn, P08 tách Cinema, Auditorium, Seat khi gộp. |
| Q-99 | "Kể từ lúc hiển thị" (BR-63) được so bằng mốc nào? (Mốc thay đổi theo từng tổ hợp, kể cả tổ hợp đã bỏ: người lưu sau chỉ bị từ chối khi chính tổ hợp đó đổi, như BR-63 viết / Một mốc thay đổi cho cả bảng giá: chặt hơn, từ chối cả khi tổ hợp khác đổi, trái BR-63) | AC-E-PriceList, entryChangeTimes, // checkEntryUnchangedSinceDisplayed; SD1 message 2.1.3.1; SD2 message 2a.1.1.1; P09 | P04 bước 5, 5a, 1a3a nêu "mục giá của tổ hợp đã bị đổi, tạo hoặc bỏ" nhưng mục giá đã bỏ không còn đối tượng để mang mốc, nên bảng giá phải giữ mốc của tổ hợp kể cả khi mục giá không còn. Phân tích này chọn phương án đầu | Đã trả lời: mốc theo từng tổ hợp, kể cả tổ hợp đã bỏ, đúng chữ BR-63; một mốc chung cho cả bảng giá sẽ từ chối cả khi tổ hợp khác đổi, trái BR-63 (theo đề xuất của review). |
| Q-100 | Quản lý cụm rạp và nhân viên quầy đều là nhân viên thuộc đúng một cụm rạp (GL-34, BR-78). Mô hình hoá hồ sơ quản lý cụm rạp thành CinemaManager riêng, như UC-005 tách BoxOfficeClerk, hay gộp các hồ sơ nhân viên thành một entity Staff có vai trò? (Hai entity riêng, giống UC-005 Q-86 / Một entity nhân viên có vai trò) | AC-E-CinemaManager, // provideCinema; P07 của UC-017; P08 | GL-34 là tên chung, GL-35 và GL-42 là hai thuật ngữ riêng; P01 không lập tác nhân "Nhân viên" | Gộp vào Q-86 (UC-005). Đã trả lời: hồ sơ quản lý cụm rạp là entity riêng CinemaManager như BoxOfficeClerk; P08 có thể thêm lớp cha nhân viên nếu cần. |

## Giả định

Không có (chế độ NGHIEM_NGAT).

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

- Cơ chế loại trừ ba chiều trên PriceList (hai yêu cầu sửa cùng mục giá: BR-63; bỏ giá và lưu suất chiếu của UC-014: BR-68; lưu giá và chốt giá của UC-005 bước 7: BR-71) chỉ được chỉ ra ở mức trách nhiệm: PriceList // savePriceEntry, PriceList // removePriceEntry là thao tác không chia cắt, đối ứng với Showtime // holdSeats của UC-005 và thao tác lưu suất chiếu của UC-014. Đơn vị loại trừ và thứ tự khoá đề xuất nằm trong bảng cuối mục 4 của UC-005; cơ chế khoá do P09 quyết.
- Giá chốt khi giữ ghế (BR-65): UC-013 không có message tới lần giữ ghế, ghế hay vé. Bảo đảm "đổi giá không ảnh hưởng lần giữ ghế đang có và vé đã bán" đến từ chỗ UC-005 ghi giá vào SeatStatus (heldPrice) và Ticket (price) khi giữ ghế, và từ việc loại trừ BR-71 giữa // savePriceEntry với // determineSeatPrice. P08 cần giữ SeatStatus, Ticket không có quan hệ đọc về PriceEntry sau lúc chốt giá.
- Chưa hết rủi ro thiếu giá (UC-012 chưa đặc tả, BR-73): UC-005 luồng 7e là lưới an toàn; không thuộc phân tích của UC-013.
- Khung giờ chiếu chỉ do PriceList xác định (// determineTimeBand, Q-104): Showtime không còn trách nhiệm này. Hai phép khớp bốn yếu tố giữa suất chiếu và mục giá có mục đích khác nhau (Showtime // checkUsesPriceEntry: suất chiếu có dùng một mục giá cụ thể; PriceList // checkCoversShowtime của UC-014: bảng giá có phủ mọi loại ghế của suất chiếu) nên giữ hai tên; P08 xem xét gộp phần so khớp bốn yếu tố về một nơi.
- AC-E-CinemaManager chỉ có một trách nhiệm // provideCinema (cung cấp cụm rạp), gần với get, cùng tên với UC-014; được giữ vì BR-61 yêu cầu quản lý chỉ xem và sửa bảng giá cụm mình và đặc tả không có hành vi khác trên hồ sơ quản lý. P08 xem xét lớp cha nhân viên theo Q-86, Q-100. Thuộc tính scheduleStatus của Showtime trùng nghĩa với status (UC-014); P08 gộp.
- AC-E-PriceEntry là lớp mới do UC-013 sở hữu, chưa có trong sổ AC của UC-005; P08 gộp trùng nếu P07 của UC-014 cũng đặt entity cho mục giá. AC-E-CinemaManager có thể trùng với entity của UC-014.
- ManagePriceListController có 6 trách nhiệm, trong ngưỡng 2-10; số lớp là 6, trong khoảng 4-12.
