# P07 - Phân tích use case UC-014 Lập lịch suất chiếu - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P07 |
| Phiên bản | 1.2 |
| Thay đổi 1.2 | Thêm luồng 8f (BR-92, MSG-83): từ chối đổi phòng chiếu của suất chiếu đã từng có vé, kể cả vé đã huỷ; thêm trách nhiệm // checkRoomChangeAllowed của Showtime và message 2.1.17[1a].4, 2.1.18[8f]; đánh số lại message 2.1.17[1a].4 đến .6 thành .5 đến .7; cập nhật 3 file .drawio; đồng bộ đầu vào đã dùng |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md; P04-uc-specs/UC-014-schedule-showtimes.md 1.4 (luồng 8f, BR-92); P08-analysis-model.md 1.4 (F4b EX-13); P12-class-design.md 1.3 (lượt PKG-27, Vấn đề còn mở 9); P11a-gui/ui-standards.md 1.3 (MSG-83); _review-final.md (RF-02); P01-actors.md 1.1; P02-usecases.md 1.8; P03-usecase-model.md 1.0; P05-glossary.md 1.1; P06-supplementary-spec.md 1.1; P04-uc-specs/_BR-register.md; P07-uc-analysis/UC-005-book-tickets-analysis.md 1.1 (sổ đăng ký AC: F1, F3.4, F8 b), Câu hỏi mở, Vấn đề còn mở); P07-uc-analysis/_review-P07-batch.md; mã Q đã cấp Q-101 đến Q-105 |
| Phạm vi | UC-014 |
| Mã Q, ASM cuối đã cấp | Q-105; không có ASM (NGHIEM_NGAT) |

## 1. Bối cảnh use case

| Thuộc tính | Giá trị |
|---|---|
| Mã và tên UC | UC-014 Lập lịch suất chiếu (Schedule Showtimes) |
| Tác nhân chính | ACT-04 Quản lý cụm rạp (Người) |
| Tác nhân phụ | Không có |
| Include (UC) | Không có |
| Được include bởi (UC) | Không có |
| Extend (UC, điểm mở rộng, điều kiện) | Không có |
| Được extend bởi (UC, điểm mở rộng, điều kiện) | Không có |
| Use case liên quan không qua include, extend | UC-005 Đặt vé: bước 7 (giữ ghế) loại trừ với bước 8 và luồng 1b3 của UC-014 trên cùng suất chiếu (BR-54); luồng 7d của UC-005 từ chối giữ ghế khi suất chiếu đã sửa hoặc xoá. UC-013 Thiết lập bảng giá: bỏ mục giá loại trừ với bước 8 (BR-68). UC-012 (phòng chiếu), UC-010 (phim): cung cấp dữ liệu phòng chiếu, phim (REQ-57, REQ-07, REQ-55, REQ-95). UC-006, UC-008, UC-015: dùng lại dữ liệu suất chiếu đã xoá (BR-58). UC-017: cấp tài khoản và cụm rạp của quản lý cụm rạp (REQ-100) |
| Tác nhân thời gian | Không có. P02 không có use case do tác nhân thời gian kích hoạt trên đối tượng mà UC-014 tạo, đổi hay xoá; P04 Mục 8 xác nhận không có bước hẹn hoặc huỷ mốc (F4.2 mục 17). Thời điểm mở bán (BR-01) và giờ bắt đầu (BR-45) được UC-005 so với thời điểm hiện tại mỗi khi có yêu cầu đặt vé. Không có message hẹn mốc |
| File P07 đã có được dùng làm sổ đăng ký AC | UC-005-book-tickets-analysis.md. Tái dùng AC-E-Showtime (UC-005 đã cấp mã và ghi chủ sở hữu UC-014), AC-E-PriceList (chủ sở hữu UC-013), AC-E-SeatHold và AC-E-Ticket (chỉ qua phép kiểm của Showtime ở bước 8, 1a3, 1b3). Các lớp còn lại của UC-005 (SeatStatus, Booking, PaymentTransaction, Customer, BoxOfficeClerk, PaymentGateway, EmailService) không tham gia UC-014 |

## 2. Đặc tả bổ sung

| Bước UC | Thực hiện bởi | Mô tả trong đặc tả | Mô tả bổ sung (hệ thống làm gì bên trong) | Nguồn (BR, GL, REQ) |
|---|---|---|---|---|
| 1 | Quản lý cụm rạp | Yêu cầu lập suất chiếu mới cho một phòng chiếu của cụm rạp. | Không đổi | REQ-60 |
| 2 | Hệ thống | Hiển thị các phòng chiếu của cụm rạp và danh sách phim (xem Dữ liệu ra 1). | Control lấy cụm rạp của quản lý cụm rạp từ hồ sơ quản lý. Từng phòng chiếu của cụm rạp cung cấp tên, loại phòng, các định dạng chiếu được; từng phim cung cấp tên, các định dạng phát hành, thời lượng, ngày khởi chiếu, ngày kết thúc chiếu; control chuyển cho boundary hiển thị. | REQ-57, REQ-07, REQ-55, REQ-95, REQ-100, GL-40, GL-37 |
| 3 | Quản lý cụm rạp | Chọn phim, định dạng, phòng chiếu và nhập ngày giờ bắt đầu, thời điểm mở bán của suất chiếu, rồi gửi (xem Dữ liệu vào 1). | Không đổi | REQ-61, GL-14, GL-53 |
| 4 | Hệ thống | Kiểm tra phòng chiếu đã chọn thuộc cụm rạp của quản lý cụm rạp (BR-46). | Control lấy cụm rạp của quản lý cụm rạp từ hồ sơ quản lý, phòng chiếu đã chọn đối chiếu cụm rạp của chính nó với cụm rạp đó. | BR-46, REQ-60, REQ-100 |
| 5 | Hệ thống | Kiểm tra định dạng là định dạng phát hành của phim (BR-47), phòng chiếu chiếu được định dạng (BR-48) và bảng giá của cụm rạp đủ giá cho suất chiếu (BR-69). | Phim đối chiếu định dạng với các định dạng phát hành của mình; phòng chiếu đối chiếu định dạng với các định dạng chiếu được của mình và cho biết loại phòng cùng các loại ghế có ít nhất một ghế. Bảng giá của cụm rạp kiểm có giá cho mọi loại ghế đó, theo loại phòng, định dạng và khung giờ xác định từ giờ bắt đầu (BR-12). | BR-47, BR-48, BR-69, BR-12, GL-26, GL-27, GL-22, REQ-62, REQ-63, REQ-145 |
| 6 | Hệ thống | Kiểm tra ngày chiếu trong khoảng chiếu của phim (BR-49), giờ bắt đầu sau thời điểm kiểm tra (BR-56) và thời điểm mở bán trước giờ bắt đầu (BR-55). | Phim kiểm ngày của giờ bắt đầu nằm trong khoảng từ ngày khởi chiếu tới ngày kết thúc chiếu của mình. Phòng chiếu tạo suất chiếu dự kiến từ dữ liệu nhập; suất chiếu dự kiến tự kiểm giờ bắt đầu sau thời điểm kiểm tra và thời điểm mở bán trước giờ bắt đầu (Q-102). | BR-49, BR-55, BR-56, REQ-97, REQ-137, REQ-138 |
| 7 | Hệ thống | Tính giờ kết thúc của suất chiếu từ giờ bắt đầu và thời lượng phim (BR-50). | Suất chiếu dự kiến lấy thời lượng từ phim của nó và tính giờ kết thúc bằng giờ bắt đầu cộng thời lượng. | BR-50, GL-15, REQ-98 |
| 8 | Hệ thống | Kiểm tra khoảng cách dọn phòng 15 phút và, khi sửa, suất chiếu chưa bị người khác sửa hoặc xoá, chưa tới giờ bắt đầu, không có ghế đang giữ, không có vé đã bán chưa huỷ, không đổi sang phòng chiếu khác khi suất chiếu đã từng có vé, bảng giá vẫn đủ giá, rồi lưu suất chiếu cùng thời điểm mở bán, tất cả là một thao tác không chia cắt. | Phòng chiếu đích thực hiện một thao tác không chia cắt: khi sửa, suất chiếu đang sửa kiểm chưa bị đổi từ lúc hiển thị, chưa tới giờ bắt đầu, không có lần giữ ghế còn hiệu lực và không có vé chưa huỷ (suất chiếu hỏi từng lần giữ ghế và từng vé), và nếu phòng chiếu đích khác phòng chiếu hiện tại thì suất chiếu chưa từng có vé nào, kể cả vé đã huỷ (BR-92); bảng giá kiểm còn đủ giá; phòng chiếu kiểm suất chiếu cách các suất chiếu khác trong phòng ít nhất 15 phút (bỏ qua chính suất chiếu đang sửa); rồi ghi suất chiếu vào lịch của phòng hoặc cập nhật suất chiếu đang sửa. Mọi kiểm tra không đạt thì không để lại thay đổi nào. Thao tác loại trừ với giữ ghế của UC-005 trên cùng suất chiếu và với bỏ mục giá của UC-013 (Q-101). | BR-51, BR-52, BR-53, BR-54, BR-57, BR-60, BR-68, BR-69, BR-92, GL-21, REQ-64, REQ-65, REQ-141, REQ-142, REQ-143, REQ-151 |
| 9 | Hệ thống | Thông báo lưu suất chiếu thành công và hiển thị suất chiếu đã lưu (xem Dữ liệu ra 2). | Suất chiếu cung cấp phim, định dạng, phòng chiếu, ngày giờ bắt đầu, giờ kết thúc, thời điểm mở bán; control chuyển cho boundary hiển thị. | Dữ liệu ra 2, BR-50 |
| 1a | Quản lý cụm rạp | Sửa suất chiếu (chọn sửa một suất chiếu đã lập thay vì lập mới). | Không đổi | REQ-65 |
| 1a1 | Hệ thống | Hiển thị các suất chiếu đã lập của các phòng chiếu thuộc cụm rạp (xem Dữ liệu ra 3). | Control lấy cụm rạp của quản lý cụm rạp; từng suất chiếu đã lập của các phòng chiếu thuộc cụm rạp cung cấp phim, định dạng, phòng chiếu, ngày giờ bắt đầu, giờ kết thúc, thời điểm mở bán và mốc thay đổi gần nhất để dùng ở bước 8. | BR-46, BR-60, Dữ liệu ra 3 |
| 1a2 | Quản lý cụm rạp | Chọn suất chiếu cần sửa (xem Dữ liệu vào 2). | Không đổi | Dữ liệu vào 2 |
| 1a3 | Hệ thống | Kiểm tra suất chiếu đã chọn chưa tới giờ bắt đầu, không có ghế đang được giữ và không có vé đã bán chưa bị huỷ. | Suất chiếu đối chiếu thời điểm kiểm tra với giờ bắt đầu của mình, rồi hỏi từng lần giữ ghế của mình còn hiệu lực không (cùng trách nhiệm của UC-005) và từng vé của mình đã huỷ chưa; không còn lần giữ ghế hiệu lực nào và mọi vé đều đã huỷ hoặc không có thì đạt. Kiểm 1a3b trước 1a3a. | BR-53, BR-57, GL-52 |
| 1a3a | Hệ thống | Từ chối sửa và thông báo quy tắc bị vi phạm (BR-53). | Suất chiếu cho biết có ghế đang giữ hoặc vé chưa huỷ, control chuyển lý do cho boundary; kết thúc thất bại. | BR-53 |
| 1a3b | Hệ thống | Từ chối sửa và thông báo quy tắc bị vi phạm (BR-57). | Suất chiếu cho biết đã tới giờ bắt đầu, control chuyển lý do cho boundary; kết thúc thất bại. | BR-57 |
| 1a4 | Hệ thống | Hiển thị thông tin hiện tại của suất chiếu cùng các phòng chiếu và danh sách phim để sửa. | Suất chiếu đã chọn cung cấp thông tin hiện tại và mốc thay đổi gần nhất; từng phòng chiếu và từng phim cung cấp thông tin như bước 2; control chuyển cho boundary, rồi tiếp tục bước 3. | Dữ liệu ra 1, Dữ liệu ra 2 |
| 1b | Quản lý cụm rạp | Xoá suất chiếu (chọn xoá một suất chiếu đã lập thay vì lập mới). | Không đổi | REQ-65 |
| 1b1 | Hệ thống | Hiển thị các suất chiếu đã lập của các phòng chiếu thuộc cụm rạp (xem Dữ liệu ra 3). | Như bước 1a1. | BR-46, BR-60, Dữ liệu ra 3 |
| 1b2 | Quản lý cụm rạp | Chọn suất chiếu cần xoá (xem Dữ liệu vào 2). | Không đổi | Dữ liệu vào 2 |
| 1b3 | Hệ thống | Kiểm tra suất chiếu chưa bị sửa hoặc xoá kể từ lúc hiển thị, chưa tới giờ bắt đầu, không có ghế đang giữ, không có vé chưa huỷ, rồi xoá khỏi lịch chiếu và giữ lại dữ liệu, tất cả là một thao tác không chia cắt. | Suất chiếu thực hiện một thao tác không chia cắt: kiểm chưa bị đổi từ lúc hiển thị, kiểm chưa tới giờ bắt đầu, kiểm không có lần giữ ghế còn hiệu lực và không có vé chưa huỷ (hỏi từng lần giữ ghế và từng vé), rồi chuyển sang trạng thái Đã xoá, ngừng bán vé, giữ lại dữ liệu. Thao tác loại trừ với giữ ghế của UC-005 trên cùng suất chiếu. | BR-53, BR-54, BR-57, BR-58, BR-60, GL-49, REQ-140 |
| 1b3a | Hệ thống | Từ chối xoá và thông báo quy tắc bị vi phạm (BR-53). | Control chuyển lý do suất chiếu có ghế đang giữ hoặc vé chưa huỷ cho boundary; không để lại thay đổi nào. | BR-53 |
| 1b3b | Hệ thống | Từ chối xoá và thông báo quy tắc bị vi phạm (BR-57). | Control chuyển lý do suất chiếu đã tới giờ bắt đầu cho boundary; không để lại thay đổi nào. | BR-57 |
| 1b3c | Hệ thống | Từ chối xoá, không ghi đè, và thông báo suất chiếu đã thay đổi hoặc không còn. | Suất chiếu cho biết đã bị sửa hoặc xoá kể từ lúc hiển thị; control chuyển thông báo cho boundary, không ghi đè thay đổi trước. | BR-60 |
| 1b4 | Hệ thống | Thông báo xoá suất chiếu thành công. | Control chuyển thông báo xoá thành công cho boundary. | REQ-140 |
| 4a | Hệ thống | Từ chối lưu suất chiếu và thông báo quy tắc bị vi phạm (BR-46). | Phòng chiếu cho biết không thuộc cụm rạp của quản lý cụm rạp, control chuyển lý do cho boundary; quay lại bước 3. | BR-46 |
| 5a | Hệ thống | Từ chối lưu suất chiếu và thông báo quy tắc bị vi phạm (BR-47). | Phim cho biết định dạng không phải định dạng phát hành, control chuyển lý do cho boundary; quay lại bước 3. | BR-47 |
| 5b | Hệ thống | Từ chối lưu suất chiếu và thông báo quy tắc bị vi phạm (BR-48). | Phòng chiếu cho biết không chiếu được định dạng, control chuyển lý do cho boundary; quay lại bước 3. | BR-48 |
| 5c | Hệ thống | Từ chối lưu suất chiếu và thông báo quy tắc bị vi phạm (BR-69). | Bảng giá cho biết chưa có giá cho mọi loại ghế của phòng chiếu, control chuyển lý do cho boundary; quay lại bước 3. | BR-69 |
| 6a | Hệ thống | Từ chối lưu suất chiếu và thông báo quy tắc bị vi phạm (BR-49). | Phim cho biết ngày chiếu nằm ngoài khoảng chiếu, control chuyển lý do cho boundary; quay lại bước 3. | BR-49 |
| 6b | Hệ thống | Từ chối lưu suất chiếu và thông báo quy tắc bị vi phạm (BR-56). | Suất chiếu dự kiến cho biết giờ bắt đầu không sau thời điểm kiểm tra, control chuyển lý do cho boundary; quay lại bước 3. | BR-56 |
| 6c | Hệ thống | Từ chối lưu suất chiếu và thông báo quy tắc bị vi phạm (BR-55). | Suất chiếu dự kiến cho biết thời điểm mở bán không trước giờ bắt đầu, control chuyển lý do cho boundary; quay lại bước 3. | BR-55 |
| 8a | Hệ thống | Khi sửa, tại thời điểm lưu có ghế đang giữ hoặc vé chưa huỷ: từ chối lưu thay đổi và thông báo quy tắc bị vi phạm (BR-53). | Suất chiếu đang sửa cho biết có ghế đang giữ hoặc vé chưa huỷ ngay trong thao tác không chia cắt; không để lại thay đổi nào, kết thúc thất bại. | BR-53, BR-54 |
| 8b | Hệ thống | Suất chiếu cách suất chiếu khác dưới 15 phút dọn phòng, kể cả khi suất xung đột vừa được lưu cùng lúc: từ chối lưu và thông báo quy tắc bị vi phạm (BR-51). | Phòng chiếu kiểm khoảng cách trong thao tác không chia cắt trên các suất chiếu của phòng nên thấy cả suất chiếu vừa lưu bởi yêu cầu khác; control chuyển lý do cho boundary; quay lại bước 3. | BR-51, BR-52 |
| 8c | Hệ thống | Khi sửa, suất chiếu đã bị người khác sửa hoặc xoá kể từ lúc hiển thị: từ chối lưu thay đổi, không ghi đè. | Suất chiếu đang sửa so mốc thay đổi đã hiển thị với mốc thay đổi gần nhất của mình; khác nhau thì từ chối, kết thúc thất bại; kiểm đầu tiên. | BR-60 |
| 8d | Hệ thống | Khi sửa, tại thời điểm lưu đã tới giờ bắt đầu: từ chối lưu thay đổi (BR-57). | Suất chiếu đang sửa đối chiếu thời điểm kiểm tra với giờ bắt đầu của mình; kết thúc thất bại. | BR-57 |
| 8e | Hệ thống | Tại thời điểm lưu bảng giá chưa có giá cho mọi loại ghế của phòng chiếu, kể cả khi một mục giá vừa được bỏ bởi UC-013: từ chối lưu (BR-69). | Bảng giá kiểm lại trong thao tác không chia cắt nên thấy cả mục giá vừa bỏ; control chuyển lý do cho boundary; quay lại bước 3; kiểm trước 8b. | BR-68, BR-69 |
| 8f | Hệ thống | Khi sửa, phòng chiếu đã chọn khác phòng chiếu hiện tại của suất chiếu và suất chiếu từng có vé, kể cả khi mọi vé đã huỷ: từ chối lưu thay đổi và thông báo quy tắc bị vi phạm (BR-92); muốn đổi phòng thì xoá suất chiếu rồi lập suất chiếu mới. | Phòng chiếu nhận // saveShowtime truyền chính nó cho suất chiếu đang sửa; suất chiếu đối chiếu với phòng chiếu hiện tại của mình, khác nhau thì kiểm tập vé của mình có vé nào không (vé đã huỷ vẫn tính, nên không hỏi trạng thái từng vé); có thì từ chối, không để lại thay đổi nào, control chuyển lý do cho boundary hiển thị theo MSG-83 (P11a), kết thúc thất bại. Kiểm sau 8a, trước 8e; trong cùng thao tác không chia cắt nên loại trừ với // holdSeats của UC-005. | BR-92, BR-54, MSG-83 |
| *a | Hệ thống | Quản lý cụm rạp huỷ yêu cầu tại bất kỳ bước nào trước bước 8: huỷ yêu cầu, không thay đổi suất chiếu nào. | Control bỏ yêu cầu đang xử lý và báo boundary yêu cầu đã huỷ; không có entity nào bị ghi. Có thể xảy ra tại mọi bước từ 1 đến 7 và trong luồng 1a, 1b trước 1a3, 1b3. | REQ-65 |

## 3. Tìm lớp phân tích

### 3.1 Bảng boundary

| Tác nhân (ACT) | Loại tác nhân | Boundary | Loại boundary | Mới hoặc tái dùng (AC, UC nguồn) | Lý do |
|---|---|---|---|---|---|
| ACT-04 Quản lý cụm rạp | Người | ScheduleShowtimesForm | Giao diện người dùng | Mới - chạy song song, chờ P08 hợp nhất (AC-B-ScheduleShowtimesForm) | Quản lý cụm rạp chọn lập, sửa hoặc xoá, nhập thông tin suất chiếu, chọn suất chiếu, huỷ yêu cầu và nhận mọi thông báo kết quả. Một boundary cho cặp tác nhân và use case; không tách theo màn hình |

Số boundary là 1, bằng số tác nhân tham gia (không có tác nhân phụ, không có tác nhân thời gian). Cổng thanh toán, dịch vụ email không tham gia UC-014.

### 3.2 Bảng lọc danh từ

| STT | Danh từ hoặc cụm danh từ | Vị trí (bước UC, mục dữ liệu, BR) | Kết luận | Lý do |
|---|---|---|---|---|
| 1 | quản lý cụm rạp | Mô tả ngắn, 1, 3, BR-46 | Loại - là tác nhân hoặc ngoài phạm vi | ACT-04, đã có boundary |
| 2 | cụm rạp của quản lý cụm rạp (thông tin về quản lý) | Tiền điều kiện, 2, 4, 1a1, BR-46 | Entity AC-E-CinemaManager | Hồ sơ quản lý cụm rạp (GL-42) biểu diễn thông tin về tác nhân, không phải bản thân tác nhân; hệ thống phải biết quản lý thuộc cụm rạp nào (REQ-100) |
| 3 | cụm rạp | 2, 4, 1a1, BR-46 | Loại - thuộc tính của AC-E-Auditorium | Giữ như UC-005: cụm rạp rút gọn thành thuộc tính cinema, chưa tách entity (Q-81) |
| 4 | phòng chiếu | 2, 3, 4, 5, 8 | Entity AC-E-Auditorium | GL-40; có hành vi riêng: kiểm cụm rạp, định dạng chiếu được, khoảng cách dọn phòng, tạo và ghi suất chiếu vào lịch |
| 5 | danh sách phim | 2, 1a4 | Loại - cấu trúc cài đặt | Kết quả liệt kê các phim |
| 6 | phim | 2, 3, 5, 6, 7 | Entity AC-E-Movie | GL-37; có hành vi: kiểm định dạng phát hành, khoảng chiếu, cung cấp thời lượng |
| 7 | suất chiếu, suất chiếu dự kiến | Mọi bước | Entity AC-E-Showtime | GL-47, tái dùng từ UC-005; suất chiếu dự kiến là Showtime chưa vào lịch phòng (Q-102) |
| 8 | suất chiếu đã xoá | 1b3, BR-58 | Loại - trùng hoặc đồng nghĩa với AC-E-Showtime | GL-49 là Showtime ở trạng thái Đã xoá (thuộc tính status) |
| 9 | danh sách suất chiếu đã lập | 1a1, 1b1 | Loại - cấu trúc cài đặt | Kết quả liệt kê các Showtime của cụm rạp |
| 10 | lịch chiếu của phòng chiếu | 8, BR-51, BR-52 | Loại - giá trị suy ra từ AC-E-Auditorium | Tập các suất chiếu của phòng, Auditorium nắm qua quan hệ với Showtime |
| 11 | định dạng (của suất chiếu) | 3, 5 | Loại - thuộc tính của AC-E-Showtime | movieFormat; GL-05 |
| 12 | định dạng phát hành | 5, BR-47 | Loại - thuộc tính của AC-E-Movie | releaseFormats |
| 13 | định dạng chiếu được | 2, 5, BR-48 | Loại - thuộc tính của AC-E-Auditorium | supportedFormats |
| 14 | loại phòng | 2, 5, BR-69 | Loại - thuộc tính của AC-E-Auditorium | auditoriumType; GL-27 |
| 15 | loại ghế | 5, BR-69 | Loại - thuộc tính của AC-E-Auditorium | seatTypes; GL-26 |
| 16 | ghế của phòng chiếu | 5, BR-69 | Loại - khái niệm do UC-012 tạo, use case này chỉ đọc qua entity AC-E-Auditorium | Chỉ cần biết loại ghế nào có ít nhất một ghế (provideSeatTypes); GL-07; Q-103 |
| 17 | bảng giá | 5, 8, BR-69 | Entity AC-E-PriceList | GL-01, tái dùng từ UC-005; có hành vi kiểm đủ giá |
| 18 | mục giá, giá | 5, 8, BR-69 | Loại - khái niệm do UC-013 tạo, use case này chỉ đọc qua entity AC-E-PriceList | GL-33; UC-014 chỉ kiểm có giá, không tính giá |
| 19 | khung giờ chiếu | 5, 8, BR-12 | Loại - giá trị suy ra từ giờ bắt đầu | GL-22, tính khi cần (Q-104) |
| 20 | giờ bắt đầu, ngày giờ bắt đầu | 3, 6, 8 | Loại - thuộc tính của AC-E-Showtime | startTime; GL-14 |
| 21 | ngày chiếu | 6, BR-49 | Loại - giá trị suy ra từ giờ bắt đầu | Ngày của ngày giờ bắt đầu (P04 Mục 8) |
| 22 | giờ kết thúc | 7, Dữ liệu ra 2 | Loại - thuộc tính của AC-E-Showtime | endTime; tính một lần và giữ nguyên (BR-50, BR-84); GL-15 |
| 23 | thời điểm mở bán | 3, 6 | Loại - thuộc tính của AC-E-Showtime | saleOpenTime; GL-53 |
| 24 | thời lượng phim | 7 | Loại - thuộc tính của AC-E-Movie | duration |
| 25 | ngày khởi chiếu, ngày kết thúc chiếu, khoảng chiếu | 6, BR-49 | Loại - thuộc tính của AC-E-Movie | releaseDate, endOfRunDate |
| 26 | thời điểm kiểm tra | 6, 8, BR-56, BR-57 | Loại - tham số của quy tắc BR-56 | Thời điểm hiện tại khi hệ thống kiểm tra |
| 27 | khoảng cách dọn phòng, 15 phút | 8, BR-51 | Loại - tham số của quy tắc BR-51 | GL-21; hằng số của quy tắc |
| 28 | mốc thay đổi, lúc hiển thị | 8c, 1b3c, BR-60 | Loại - thuộc tính của AC-E-Showtime | lastChangedAt, đã có ở UC-005 |
| 29 | ghế đang được giữ | 1a3, 8, 1b3, BR-53 | Loại - khái niệm do UC-005 tạo, use case này chỉ đọc qua entity AC-E-Showtime, hỏi qua SeatHold | Lần giữ ghế (GL-25) thuộc UC-005; Showtime nắm các lần giữ ghế của mình và hỏi từng lần giữ ghế còn hiệu lực không (SeatHold // checkHoldStillActive, BR-53). |
| 30 | thời điểm hết hạn giữ ghế | BR-53 | Loại - khái niệm do UC-005 tạo, use case này chỉ đọc qua entity AC-E-Showtime | GL-52; ghế quá hạn không còn chặn |
| 31 | vé đã bán chưa bị huỷ | 1a3, 8, 1b3, BR-53 | Loại - khái niệm do UC-005 tạo, use case này chỉ đọc qua entity AC-E-Showtime, hỏi qua Ticket | Vé (GL-59) thuộc UC-005; Showtime nắm các vé của mình và hỏi từng vé đã huỷ chưa (Ticket // checkNotCancelled). |
| 32 | người khác (sửa hoặc xoá) | 8c, 1b3c, BR-60 | Loại - là tác nhân hoặc ngoài phạm vi | Quản lý cụm rạp khác hoặc phiên làm việc khác (ACT-04) |
| 33 | thao tác không chia cắt | 8, 1b3, BR-52 | Loại - thao tác hoặc sự kiện | Đặc tính của trách nhiệm saveShowtime, removeFromSchedule |
| 34 | yêu cầu | 1, *a | Loại - thao tác hoặc sự kiện | Hành động của tác nhân |
| 35 | quy tắc bị vi phạm, thông báo | Mọi luồng từ chối | Loại - dữ liệu trao đổi qua boundary ScheduleShowtimesForm | Không lưu |
| 36 | phiên làm việc | Tiền điều kiện | Loại - là tác nhân hoặc ngoài phạm vi | Đăng nhập không là use case (hồ sơ dự án Mục 4) |
| 37 | vé đã huỷ, email hoàn tiền, hoàn tiền | BR-58, Mục 8 | Loại - không tham gia hành vi của use case này | Khái niệm của UC-006, UC-008; UC-014 chỉ giữ lại dữ liệu suất chiếu |
| 38 | báo cáo doanh thu, tỉ lệ lấp đầy | BR-58, Mục 8 | Loại - không tham gia hành vi của use case này | Khái niệm của UC-015, UC-016 |
| 39 | phòng chiếu hiện tại, phòng chiếu đã chọn (khi đổi phòng), suất chiếu từng có vé | 3, 8, 8f, BR-92, Dữ liệu vào 1 | Loại - thuộc tính hoặc giá trị suy ra từ AC-E-Showtime | Phòng chiếu hiện tại là thuộc tính auditorium của Showtime; "từng có vé" suy ra từ tập vé Showtime nắm (R-UC014-11), vé đã huỷ vẫn tính; không tạo khái niệm mới |

### 3.3 Bảng control

| Control | Use case điều phối | Mới hoặc tái dùng | Lý do (hoặc lý do không có control) |
|---|---|---|---|
| ScheduleShowtimesController | UC-014 | Mới - chạy song song, chờ P08 hợp nhất (AC-C-ScheduleShowtimesController) | Một control cho use case: điều phối trình tự lập, sửa, xoá, nhận yêu cầu từ boundary, lấy dữ liệu hiển thị, gọi các entity theo thứ tự kiểm của P04 và chuyển kết quả cho boundary. Quy tắc nghiệp vụ nằm ở entity. Có 8 trách nhiệm, trong ngưỡng 2-10 |

### 3.4 Bảng lớp phân tích

| AC | Stereotype | Tên | Trách nhiệm | Thuộc tính chính | Bước UC nguồn | Loại boundary | Mới hoặc tái dùng | GL |
|---|---|---|---|---|---|---|---|---|
| AC-B-ScheduleShowtimesForm | boundary | ScheduleShowtimesForm | // requestNewShowtime: quản lý cụm rạp yêu cầu lập suất chiếu mới<br>// requestEditShowtime: quản lý cụm rạp chọn sửa một suất chiếu đã lập<br>// requestDeleteShowtime: quản lý cụm rạp chọn xoá một suất chiếu đã lập<br>// showAuditoriumsAndMovies: hiển thị các phòng chiếu của cụm rạp và danh sách phim<br>// submitShowtimeInfo: quản lý cụm rạp chọn phim, định dạng, phòng chiếu, nhập giờ bắt đầu, thời điểm mở bán rồi gửi<br>// showShowtimes: hiển thị các suất chiếu đã lập của cụm rạp<br>// selectShowtimeToEdit: quản lý cụm rạp chọn suất chiếu cần sửa<br>// selectShowtimeToDelete: quản lý cụm rạp chọn suất chiếu cần xoá<br>// showShowtimeForEdit: hiển thị thông tin hiện tại của suất chiếu cùng các phòng chiếu và danh sách phim để sửa<br>// showSavedShowtime: thông báo lưu suất chiếu thành công và hiển thị suất chiếu đã lưu<br>// notifyDeleted: thông báo xoá suất chiếu thành công<br>// notifyRefusal: thông báo từ chối kèm quy tắc bị vi phạm, hoặc suất chiếu đã thay đổi hoặc không còn<br>// cancelRequest: quản lý cụm rạp huỷ yêu cầu<br>// showRequestCancelled: báo yêu cầu đã huỷ, không có suất chiếu nào thay đổi | showtimeInput (Phim, định dạng, phòng chiếu, giờ bắt đầu, thời điểm mở bán), selectedShowtime (Suất chiếu được chọn, mốc thay đổi đã hiển thị) | 1, 2, 3, 4a, 5a, 5b, 5c, 6a, 6b, 6c, 8a, 8b, 8c, 8d, 8e, 8f, 9, 1a, 1a1, 1a2, 1a3a, 1a3b, 1a4, 1b, 1b1, 1b2, 1b3a, 1b3b, 1b3c, 1b4, *a | Giao diện người dùng | Mới - chạy song song, chờ P08 hợp nhất | GL-42 |
| AC-C-ScheduleShowtimesController | control | ScheduleShowtimesController | // startScheduling: điều phối bước 2: lấy cụm rạp của quản lý, các phòng chiếu và phim để hiển thị<br>// requestSaveShowtime: điều phối bước 4 đến 9: kiểm phòng chiếu, định dạng, bảng giá, ngày giờ, tính giờ kết thúc, lưu suất chiếu và báo kết quả (lập mới hoặc sửa)<br>// startEditingShowtime: điều phối bước 1a1: lấy các suất chiếu đã lập của cụm rạp để hiển thị<br>// prepareShowtimeEdit: điều phối bước 1a3, 1a4: kiểm suất chiếu chọn chưa tới giờ bắt đầu và không có ghế giữ, vé chưa huỷ rồi hiển thị để sửa<br>// startDeletingShowtime: điều phối bước 1b1: lấy các suất chiếu đã lập của cụm rạp để hiển thị<br>// deleteShowtime: điều phối bước 1b3, 1b4: xoá suất chiếu khỏi lịch chiếu và báo kết quả<br>// cancelRequest: điều phối luồng *a: huỷ yêu cầu<br>// discardRequest: bỏ yêu cầu đang xử lý, không thay đổi suất chiếu nào | - | 1 đến 9, 1a1 đến 1a4, 1b1 đến 1b4, 4a đến 8f, *a | - | Mới - chạy song song, chờ P08 hợp nhất | - |
| AC-E-CinemaManager | entity | CinemaManager | // provideCinema: cung cấp cụm rạp mà quản lý cụm rạp thuộc về (BR-46, REQ-100) | cinema (Cụm rạp) | 2, 4, 1a1, 1b1 | - | Mới - chạy song song, chờ P08 hợp nhất; chủ sở hữu UC-017 | GL-42 |
| AC-E-Auditorium | entity | Auditorium | // provideAuditoriumInfo: cung cấp tên phòng, loại phòng, các định dạng chiếu được để hiển thị<br>// checkBelongsToCinema: kiểm tra phòng chiếu thuộc cụm rạp của quản lý cụm rạp (BR-46)<br>// checkSupportsFormat: kiểm tra phòng chiếu chiếu được định dạng đã chọn (BR-48)<br>// provideSeatTypes: cung cấp loại phòng và các loại ghế có ít nhất một ghế trong phòng chiếu (BR-69)<br>// draftShowtime: tạo suất chiếu dự kiến của phòng chiếu từ dữ liệu quản lý cụm rạp nhập (Creator)<br>// saveShowtime: thao tác không chia cắt: kiểm suất chiếu, bảng giá, khoảng cách dọn phòng rồi ghi suất chiếu vào lịch phòng (BR-51, BR-52, BR-53, BR-54, BR-57, BR-60, BR-68, BR-69, BR-92)<br>// checkRoomGap: kiểm tra suất chiếu cách các suất chiếu khác trong phòng ít nhất 15 phút dọn phòng (BR-51)<br>// addToSchedule: ghi suất chiếu dự kiến vào lịch chiếu của phòng | name (Văn bản), auditoriumType (Văn bản), supportedFormats (Văn bản), seatTypes (Văn bản), cinema (Cụm rạp) | 2, 4, 5, 6, 8, 1a4 | - | Mới - chạy song song, chờ P08 hợp nhất; chủ sở hữu UC-012 | GL-40, GL-21, GL-26, GL-27 |
| AC-E-Movie | entity | Movie | // provideMovieInfo: cung cấp tên, các định dạng phát hành, thời lượng, ngày khởi chiếu, ngày kết thúc chiếu để hiển thị<br>// checkReleasedInFormat: kiểm tra định dạng đã chọn là định dạng phát hành của phim (BR-47)<br>// checkWithinRunPeriod: kiểm tra ngày chiếu nằm trong khoảng từ ngày khởi chiếu tới ngày kết thúc chiếu (BR-49)<br>// provideDuration: cung cấp thời lượng phim để tính giờ kết thúc (BR-50) | title (Văn bản), releaseFormats (Văn bản), duration (Số phút), releaseDate (Ngày), endOfRunDate (Ngày) | 2, 5, 6, 7, 1a4 | - | Mới - chạy song song, chờ P08 hợp nhất; chủ sở hữu UC-010 | GL-37, GL-05 |
| AC-E-Showtime | entity | Showtime | // createShowtime: khởi tạo suất chiếu dự kiến với phim, định dạng, phòng chiếu, giờ bắt đầu, thời điểm mở bán<br>// checkStartAfter: kiểm tra giờ bắt đầu sau thời điểm kiểm tra (BR-56)<br>// checkSaleOpenBeforeStart: kiểm tra thời điểm mở bán trước giờ bắt đầu (BR-55)<br>// calculateEndTime: tính giờ kết thúc bằng giờ bắt đầu cộng thời lượng phim (BR-50)<br>// checkUnchangedSinceDisplayed: kiểm tra suất chiếu chưa bị sửa hoặc xoá kể từ lúc hiển thị cho quản lý cụm rạp (BR-60)<br>// checkNotStarted: kiểm tra suất chiếu chưa tới giờ bắt đầu (BR-57)<br>// checkNoActiveHoldOrSoldTicket: kiểm tra suất chiếu không có lần giữ ghế còn hiệu lực (hỏi từng lần giữ ghế) và không có vé chưa bị huỷ (hỏi từng vé) (BR-53)<br>// checkRoomChangeAllowed: khi phòng chiếu đích khác phòng chiếu hiện tại, kiểm tra suất chiếu chưa từng có vé nào, kể cả vé đã huỷ (BR-92)<br>// applyChanges: ghi thông tin mới của suất chiếu và đặt lại mốc thay đổi (BR-84)<br>// removeFromSchedule: thao tác không chia cắt: kiểm rồi xoá suất chiếu khỏi lịch chiếu, giữ lại dữ liệu (BR-53, BR-54, BR-57, BR-58, BR-60)<br>// markDeleted: đánh dấu suất chiếu Đã xoá, ngừng bán vé, giữ dữ liệu (BR-58)<br>// provideShowtimeInfo: cung cấp phim, định dạng, phòng chiếu, ngày giờ bắt đầu, giờ kết thúc, thời điểm mở bán, mốc thay đổi gần nhất để hiển thị | startTime (Ngày giờ), saleOpenTime (Ngày giờ), movieFormat (Văn bản), auditoriumType (Văn bản), cinema (Cụm rạp), lastChangedAt (Ngày giờ), movie (Phim) (mới ở UC này), auditorium (Phòng chiếu) (mới ở UC này), endTime (Ngày giờ) (mới ở UC này), status (Trạng thái: Trong lịch chiếu, Đã xoá) (mới ở UC này) | 6, 7, 8, 9, 1a1, 1a3, 1a4, 1b1, 1b3 | - | Tái dùng từ UC-005 (chủ sở hữu UC-014), bổ sung trách nhiệm | GL-47, GL-14, GL-15, GL-53, GL-49 |
| AC-E-PriceList | entity | PriceList | // checkCoversShowtime: kiểm tra bảng giá của cụm rạp có giá cho mọi loại ghế của phòng chiếu, ứng với khung giờ xác định từ giờ bắt đầu (BR-12), theo loại phòng và định dạng (BR-68, BR-69) | cinema (Cụm rạp) | 5, 8 | - | Tái dùng từ UC-005 (chủ sở hữu UC-013), bổ sung trách nhiệm | GL-01, GL-33, GL-22 |
| AC-E-SeatHold | entity | SeatHold | // checkHoldStillActive: kiểm tra lần giữ ghế còn hiệu lực tại thời điểm kiểm tra (trách nhiệm của UC-005, dùng chung với UC-006; BR-53, BR-85) | - | 8, 1a3, 1b3 | - | Tái dùng từ UC-005 | GL-25, GL-52 |
| AC-E-Ticket | entity | Ticket | // checkNotCancelled: kiểm tra vé chưa bị huỷ (BR-53) | - | 8, 1a3, 1b3 | - | Tái dùng từ UC-005, bổ sung trách nhiệm | GL-59, GL-60 |

Tổng cộng 9 lớp: 1 boundary, 1 control, 7 entity. Entity cốt lõi của chủ đề race condition và loại trừ: AC-E-Auditorium (// saveShowtime), AC-E-Showtime (// removeFromSchedule, // checkNoActiveHoldOrSoldTicket) và AC-E-PriceList (// checkCoversShowtime).

## 4. Phân bổ hành vi

| Bước UC | Trách nhiệm | Lớp nhận (AC) | Nguyên tắc | Lý do khi có lựa chọn khác |
|---|---|---|---|---|
| 1, 3, 1a, 1a2, 1b, 1b2, *a | // requestNewShowtime, // submitShowtimeInfo, // requestEditShowtime, // selectShowtimeToEdit, // requestDeleteShowtime, // selectShowtimeToDelete, // cancelRequest | AC-B-ScheduleShowtimesForm | Giao tiếp tác nhân | - |
| 1, 3, 1a, 1a2, 1b, 1b2, *a | // startScheduling, // requestSaveShowtime, // startEditingShowtime, // prepareShowtimeEdit, // startDeletingShowtime, // deleteShowtime, // cancelRequest, // discardRequest | AC-C-ScheduleShowtimesController | Controller | Boundary chỉ chuyển yêu cầu, không kiểm quy tắc nào |
| 2, 1a1, 1b1, 1a4 | // provideCinema | AC-E-CinemaManager | Information Expert | Hồ sơ quản lý giữ cụm rạp của quản lý (REQ-100); control không giữ dữ liệu này lâu dài |
| 2, 1a4 | // provideAuditoriumInfo, // provideMovieInfo | AC-E-Auditorium, AC-E-Movie | Information Expert | Không có đối tượng toàn thể (Cụm rạp rút gọn, Q-81; danh sách phim của chuỗi không là entity) nên control lặp và gửi message tới từng phần tử (A6) |
| 1a1, 1b1, 9, 1a4 | // provideShowtimeInfo | AC-E-Showtime | Information Expert | Như trên cho việc liệt kê các suất chiếu của cụm rạp |
| 2, 1a4 | // showAuditoriumsAndMovies, // showShowtimes, // showShowtimeForEdit | AC-B-ScheduleShowtimesForm | Giao tiếp tác nhân | - |
| 4 | // checkBelongsToCinema | AC-E-Auditorium | Information Expert | Phòng chiếu giữ cụm rạp của mình; quản lý chỉ cung cấp cụm rạp nên không để CinemaManager duyệt phòng chiếu (giảm coupling) |
| 4a, 5a, 5b, 5c, 6a, 6b, 6c, 8a, 8b, 8c, 8d, 8e, 8f, 1a3a, 1a3b, 1b3a, 1b3b, 1b3c | // notifyRefusal | AC-B-ScheduleShowtimesForm | Giao tiếp tác nhân | Lý do vi phạm do entity kiểm cho biết, control chuyển |
| 5 | // checkReleasedInFormat | AC-E-Movie | Information Expert | Phim giữ các định dạng phát hành |
| 5 | // checkSupportsFormat, // provideSeatTypes | AC-E-Auditorium | Information Expert | Phòng chiếu giữ định dạng chiếu được, loại phòng, loại ghế của các ghế (Q-103) |
| 5, 8 | // checkCoversShowtime | AC-E-PriceList | Information Expert | Bảng giá giữ các mục giá nên tự đối chiếu; khung giờ xác định từ giờ bắt đầu bên trong (Q-104). Cùng một trách nhiệm ở bước 5 (kiểm sớm) và bước 8 (kiểm lại trong thao tác không chia cắt) |
| 6 | // checkWithinRunPeriod | AC-E-Movie | Information Expert | Phim giữ ngày khởi chiếu, ngày kết thúc chiếu |
| 6 | // draftShowtime, // createShowtime | AC-E-Auditorium, AC-E-Showtime | Creator | Phòng chiếu chứa các suất chiếu nên tạo suất chiếu dự kiến; phương án khác là control tạo vì có dữ liệu nhập, bị loại vì control không nên tạo entity (Q-102) |
| 6 | // checkStartAfter, // checkSaleOpenBeforeStart | AC-E-Showtime | Information Expert | Giờ bắt đầu và thời điểm mở bán là dữ liệu của suất chiếu |
| 7 | // calculateEndTime, // provideDuration | AC-E-Showtime, AC-E-Movie | Information Expert | Giờ kết thúc là dữ liệu của suất chiếu; thời lượng nằm ở phim nên suất chiếu hỏi phim (phương án khác: Movie tính giờ kết thúc, bị loại vì giờ kết thúc thuộc suất chiếu) |
| 8 | // saveShowtime, // checkRoomGap, // addToSchedule | AC-E-Auditorium | Information Expert | Khoảng cách dọn phòng là kiểm tra trên tập suất chiếu mà phòng chiếu nắm: đó là trách nhiệm của đối tượng toàn thể, không gửi message tới từng suất chiếu (A6 b). BR-52 gắn thao tác không chia cắt với các suất chiếu của phòng chiếu nên phòng chiếu là chủ thao tác, thay vì Showtime (không tồn tại khi lập mới) hoặc control (không giữ quy tắc của entity) |
| 8 (khi sửa), 1a3, 1b3 | // checkUnchangedSinceDisplayed, // checkNotStarted, // checkNoActiveHoldOrSoldTicket | AC-E-Showtime | Information Expert | Suất chiếu nắm các lần giữ ghế và vé của mình; điều kiện "còn hiệu lực" của lần giữ ghế là dữ liệu của SeatHold nên suất chiếu hỏi từng lần giữ ghế và từng vé thay vì tự đọc (cần dữ liệu riêng của từng phần tử, A6); cùng đơn vị với // holdSeats của UC-005 để hai thao tác loại trừ nhau (BR-54) |
| 8 (khi sửa) | // checkRoomChangeAllowed | AC-E-Showtime | Information Expert | Suất chiếu nắm phòng chiếu hiện tại và tập vé của mình nên tự đối chiếu phòng và tự biết đã có vé nào chưa; vé đã huỷ vẫn tính nên không cần hỏi trạng thái từng vé, Ticket không thêm trách nhiệm. Phương án khác: Auditorium so phòng rồi hỏi từng vé, bị loại vì phòng chiếu hiện tại và tập vé là dữ liệu của suất chiếu. Cùng đơn vị thao tác với // holdSeats của UC-005 (BR-54) |
| 8 (khi sửa), 1a3, 1b3 | // checkHoldStillActive | AC-E-SeatHold | Information Expert | Một trách nhiệm "còn hiệu lực" của UC-005, dùng chung cho BR-04, BR-85 (UC-005, UC-006) và BR-53 (UC-014): lần giữ ghế quá hạn không còn chặn sửa hoặc xoá. |
| 8 (khi sửa), 1a3, 1b3 | // checkNotCancelled | AC-E-Ticket | Information Expert | Trạng thái huỷ là dữ liệu của vé (R-UC005-19). |
| 8 (khi sửa) | // applyChanges | AC-E-Showtime | Information Expert | Ghi thông tin mới và đặt lại mốc thay đổi, nhờ đó giữ ghế trên suất chiếu đã xem trước đó bị từ chối ở UC-005 (BR-54) |
| 1b3 | // removeFromSchedule, // markDeleted | AC-E-Showtime | Information Expert | Xoá là đổi trạng thái Đã xoá và giữ dữ liệu (BR-58); kiểm và ghi trong một thao tác của suất chiếu |
| 9, 1b4 | // showSavedShowtime, // notifyDeleted, // showRequestCancelled | AC-B-ScheduleShowtimesForm | Giao tiếp tác nhân | - |

## 5. Sequence diagram phân tích

File diagrams/P07-sequence-UC-014.drawio có 14 trang, mỗi trang một sơ đồ. ID cell của lifeline là "<ID trang>-L-<khoá>", ID cell của message là "<ID trang>-M-<STT>" (các ký tự [ ] ( ) * và dấu cách trong STT đổi thành _, message trả về thêm hậu tố -R). Luồng 1a và 1b rẽ tại message 1 của SD1a nên STT dùng hậu tố 1a, 1b; luồng 1a dùng lại message của luồng chính từ bước 3 nên message khác ở bước 8 mang STT của message luồng chính kèm "[1a]", message luồng kết thúc ở bước 8 kèm "[8c]", "[8d]", "[8a]", "[8f]", "[8e]", "[8b]". Luồng *a xảy ra trong một khoảng bước nên STT là "1*a". Các message luồng thay thế trong fragment dùng tiếp số của luồng chính.

### SD1a - Luồng chính bước 1, 2

a) Luồng thể hiện: Lập suất chiếu mới: yêu cầu lập, hệ thống hiển thị các phòng chiếu của cụm rạp và danh sách phim.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1a-L-A | Actor | :Quản lý cụm rạp | - | - | Tác nhân (ACT-04) |
| SD1a-L-F | Lifeline | :ScheduleShowtimesForm | «boundary» | - | AC-B-ScheduleShowtimesForm |
| SD1a-L-C | Lifeline | :ScheduleShowtimesController | «control» | - | AC-C-ScheduleShowtimesController |
| SD1a-L-CM | Lifeline | :CinemaManager | «entity» | - | AC-E-CinemaManager |
| SD1a-L-AU | Lifeline | :Auditorium | «entity» | - | AC-E-Auditorium |
| SD1a-L-MV | Lifeline | :Movie | «entity» | - | AC-E-Movie |
| SD1a-F1 | Fragment | loop [mỗi phòng chiếu của cụm rạp] | - | - | Bao các message của fragment |
| SD1a-F2 | Fragment | loop [mỗi phim trong danh sách phim] | - | - | Bao các message của fragment |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1 | :Quản lý cụm rạp | :ScheduleShowtimesForm | // requestNewShowtime | Đồng bộ | - | 1 |
| 1.1 | :ScheduleShowtimesForm | :ScheduleShowtimesController | // startScheduling | Đồng bộ | - | 1 |
| 1.1.1 | :ScheduleShowtimesController | :CinemaManager | // provideCinema | Đồng bộ | - | 2 |
| 1.1.1 (trả về) | :CinemaManager | :ScheduleShowtimesController | cụm rạp của quản lý cụm rạp | Trả về | - | 2 |
| 1.1.2 | :ScheduleShowtimesController | :Auditorium | // provideAuditoriumInfo (cụm rạp) | Đồng bộ | SD1a-F1 | 2 |
| 1.1.2 (trả về) | :Auditorium | :ScheduleShowtimesController | tên phòng, loại phòng, các định dạng chiếu được | Trả về | SD1a-F1 | 2 |
| 1.1.3 | :ScheduleShowtimesController | :Movie | // provideMovieInfo | Đồng bộ | SD1a-F2 | 2 |
| 1.1.3 (trả về) | :Movie | :ScheduleShowtimesController | tên, các định dạng phát hành, thời lượng, ngày khởi chiếu, ngày kết thúc chiếu | Trả về | SD1a-F2 | 2 |
| 1.1.4 | :ScheduleShowtimesController | :ScheduleShowtimesForm | // showAuditoriumsAndMovies (phòng chiếu, phim) | Đồng bộ | - | 2 |

### SD1b - Luồng chính bước 3, 4 và luồng 4a

a) Luồng thể hiện: Nhập thông tin suất chiếu, hệ thống kiểm tra phòng chiếu thuộc cụm rạp của quản lý cụm rạp; 4a quay lại bước 3.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1b-L-A | Actor | :Quản lý cụm rạp | - | - | Tác nhân (ACT-04) |
| SD1b-L-F | Lifeline | :ScheduleShowtimesForm | «boundary» | - | AC-B-ScheduleShowtimesForm |
| SD1b-L-C | Lifeline | :ScheduleShowtimesController | «control» | - | AC-C-ScheduleShowtimesController |
| SD1b-L-CM | Lifeline | :CinemaManager | «entity» | - | AC-E-CinemaManager |
| SD1b-L-AU | Lifeline | :Auditorium | «entity» | - | AC-E-Auditorium |
| SD1b-R1 | Fragment | ref SD1a - Luồng chính bước 1, 2 | - | - | ref, mức ngoài cùng |
| SD1b-F1 | Fragment | alt [phòng chiếu không thuộc cụm rạp của quản lý cụm rạp (4a)] | - | - | Bao các message của fragment |
| SD1b-F1-O2 | Fragment | [phòng chiếu thuộc cụm rạp] | - | SD1b-F1 | Toán hạng 2 của alt; đường ngăn là edge SD1b-F1-O2-SEP |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 2 | :Quản lý cụm rạp | :ScheduleShowtimesForm | // submitShowtimeInfo (phim, định dạng, phòng chiếu, giờ bắt đầu, thời điểm mở bán) | Đồng bộ | - | 3 |
| 2.1 | :ScheduleShowtimesForm | :ScheduleShowtimesController | // requestSaveShowtime (phim, định dạng, phòng chiếu, giờ bắt đầu, thời điểm mở bán) | Đồng bộ | - | 3 |
| 2.1.1 | :ScheduleShowtimesController | :CinemaManager | // provideCinema | Đồng bộ | - | 4 |
| 2.1.1 (trả về) | :CinemaManager | :ScheduleShowtimesController | cụm rạp của quản lý cụm rạp | Trả về | - | 4 |
| 2.1.2 | :ScheduleShowtimesController | :Auditorium | // checkBelongsToCinema (cụm rạp của quản lý cụm rạp) | Đồng bộ | - | 4 |
| 2.1.2 (trả về) | :Auditorium | :ScheduleShowtimesController | phòng chiếu có thuộc cụm rạp hay không | Trả về | - | 4 |
| 2.1.3 | :ScheduleShowtimesController | :ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-46 bị vi phạm) | Đồng bộ | SD1b-F1 | 4a |

### SD1c - Luồng chính bước 5 đến 7 và luồng 5a, 5b, 5c, 6a, 6b, 6c

a) Luồng thể hiện: Kiểm định dạng, phòng chiếu, bảng giá (5); kiểm ngày chiếu, giờ bắt đầu, thời điểm mở bán (6); tính giờ kết thúc (7). Các luồng 5a, 5b, 5c, 6a, 6b, 6c quay lại bước 3.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1c-L-F | Lifeline | :ScheduleShowtimesForm | «boundary» | - | AC-B-ScheduleShowtimesForm |
| SD1c-L-C | Lifeline | :ScheduleShowtimesController | «control» | - | AC-C-ScheduleShowtimesController |
| SD1c-L-AU | Lifeline | :Auditorium | «entity» | - | AC-E-Auditorium |
| SD1c-L-MV | Lifeline | :Movie | «entity» | - | AC-E-Movie |
| SD1c-L-ST | Lifeline | :Showtime | «entity» | - | AC-E-Showtime; đỉnh lifeline đặt ngang message Tạo |
| SD1c-L-PL | Lifeline | :PriceList | «entity» | - | AC-E-PriceList |
| SD1c-R1 | Fragment | ref SD1b - Luồng chính bước 3, 4 và luồng 4a | - | - | ref, mức ngoài cùng |
| SD1c-F1 | Fragment | alt [định dạng không là định dạng phát hành (5a)] | - | - | Bao các message của fragment |
| SD1c-F1-O2 | Fragment | [phòng chiếu không chiếu được định dạng (5b)] | - | SD1c-F1 | Toán hạng 2 của alt; đường ngăn là edge SD1c-F1-O2-SEP |
| SD1c-F1-O3 | Fragment | [bảng giá chưa đủ giá (5c)] | - | SD1c-F1 | Toán hạng 3 của alt; đường ngăn là edge SD1c-F1-O3-SEP |
| SD1c-F1-O4 | Fragment | [định dạng, phòng chiếu và bảng giá hợp lệ] | - | SD1c-F1 | Toán hạng 4 của alt; đường ngăn là edge SD1c-F1-O4-SEP |
| SD1c-F2 | Fragment | alt [ngày chiếu ngoài khoảng chiếu của phim (6a)] | - | - | Bao các message của fragment |
| SD1c-F2-O2 | Fragment | [giờ bắt đầu không sau thời điểm kiểm tra (6b)] | - | SD1c-F2 | Toán hạng 2 của alt; đường ngăn là edge SD1c-F2-O2-SEP |
| SD1c-F2-O3 | Fragment | [thời điểm mở bán không trước giờ bắt đầu (6c)] | - | SD1c-F2 | Toán hạng 3 của alt; đường ngăn là edge SD1c-F2-O3-SEP |
| SD1c-F2-O4 | Fragment | [ngày chiếu, giờ bắt đầu và thời điểm mở bán hợp lệ] | - | SD1c-F2 | Toán hạng 4 của alt; đường ngăn là edge SD1c-F2-O4-SEP |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 2.1.4 | :ScheduleShowtimesController | :Movie | // checkReleasedInFormat (định dạng) | Đồng bộ | - | 5 |
| 2.1.4 (trả về) | :Movie | :ScheduleShowtimesController | định dạng có là định dạng phát hành của phim hay không | Trả về | - | 5 |
| 2.1.5 | :ScheduleShowtimesController | :Auditorium | // checkSupportsFormat (định dạng) | Đồng bộ | - | 5 |
| 2.1.5 (trả về) | :Auditorium | :ScheduleShowtimesController | phòng chiếu có chiếu được định dạng hay không | Trả về | - | 5 |
| 2.1.6 | :ScheduleShowtimesController | :Auditorium | // provideSeatTypes | Đồng bộ | - | 5 |
| 2.1.6 (trả về) | :Auditorium | :ScheduleShowtimesController | loại phòng, các loại ghế có trong phòng chiếu | Trả về | - | 5 |
| 2.1.7 | :ScheduleShowtimesController | :PriceList | // checkCoversShowtime (loại phòng, định dạng, các loại ghế, giờ bắt đầu) | Đồng bộ | - | 5 |
| 2.1.7 (trả về) | :PriceList | :ScheduleShowtimesController | bảng giá có đủ giá hay không | Trả về | - | 5 |
| 2.1.8 | :ScheduleShowtimesController | :ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-47 bị vi phạm) | Đồng bộ | SD1c-F1 | 5a |
| 2.1.9 | :ScheduleShowtimesController | :ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-48 bị vi phạm) | Đồng bộ | SD1c-F1 | 5b |
| 2.1.10 | :ScheduleShowtimesController | :ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-69 bị vi phạm) | Đồng bộ | SD1c-F1 | 5c |
| 2.1.11 | :ScheduleShowtimesController | :Movie | // checkWithinRunPeriod (ngày của giờ bắt đầu) | Đồng bộ | - | 6 |
| 2.1.11 (trả về) | :Movie | :ScheduleShowtimesController | ngày chiếu có nằm trong khoảng chiếu của phim hay không | Trả về | - | 6 |
| 2.1.12 | :ScheduleShowtimesController | :Auditorium | // draftShowtime (phim, định dạng, giờ bắt đầu, thời điểm mở bán) | Đồng bộ | - | 6 |
| 2.1.12.1 | :Auditorium | :Showtime | «create» // createShowtime (phim, định dạng, phòng chiếu, giờ bắt đầu, thời điểm mở bán) | Tạo | - | 6 |
| 2.1.12.1.1 | :Showtime | :Showtime | // checkStartAfter (thời điểm kiểm tra) | Tự gọi | - | 6 |
| 2.1.12.1.2 | :Showtime | :Showtime | // checkSaleOpenBeforeStart | Tự gọi | - | 6 |
| 2.1.12 (trả về) | :Auditorium | :ScheduleShowtimesController | suất chiếu dự kiến, giờ bắt đầu có sau thời điểm kiểm tra hay không, thời điểm mở bán có trước giờ bắt đầu hay không | Trả về | - | 6 |
| 2.1.13 | :ScheduleShowtimesController | :ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-49 bị vi phạm) | Đồng bộ | SD1c-F2 | 6a |
| 2.1.14 | :ScheduleShowtimesController | :ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-56 bị vi phạm) | Đồng bộ | SD1c-F2 | 6b |
| 2.1.15 | :ScheduleShowtimesController | :ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-55 bị vi phạm) | Đồng bộ | SD1c-F2 | 6c |
| 2.1.16 | :ScheduleShowtimesController | :Showtime | // calculateEndTime | Đồng bộ | - | 7 |
| 2.1.16.1 | :Showtime | :Movie | // provideDuration | Đồng bộ | - | 7 |
| 2.1.16.1 (trả về) | :Movie | :Showtime | thời lượng phim | Trả về | - | 7 |
| 2.1.16 (trả về) | :Showtime | :ScheduleShowtimesController | giờ kết thúc của suất chiếu dự kiến | Trả về | - | 7 |

### SD1d - Luồng chính bước 8, 9 và luồng 8b, 8e

a) Luồng thể hiện: Lưu suất chiếu trong một thao tác không chia cắt (kiểm bảng giá, kiểm khoảng cách dọn phòng, ghi vào lịch phòng), rồi báo kết quả. Các luồng 8e, 8b quay lại bước 3.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1d-L-F | Lifeline | :ScheduleShowtimesForm | «boundary» | - | AC-B-ScheduleShowtimesForm |
| SD1d-L-C | Lifeline | :ScheduleShowtimesController | «control» | - | AC-C-ScheduleShowtimesController |
| SD1d-L-AU | Lifeline | :Auditorium | «entity» | - | AC-E-Auditorium |
| SD1d-L-ST | Lifeline | :Showtime | «entity» | - | AC-E-Showtime |
| SD1d-L-PL | Lifeline | :PriceList | «entity» | - | AC-E-PriceList |
| SD1d-R1 | Fragment | ref SD1c - Luồng chính bước 5 đến 7 và luồng 5a, 5b, 5c, 6a, 6b, 6c | - | - | ref, mức ngoài cùng |
| SD1d-F1 | Fragment | alt [bảng giá chưa đủ giá khi lưu (8e)] | - | - | Bao các message của fragment |
| SD1d-F1-O2 | Fragment | [suất chiếu cách suất chiếu khác dưới 15 phút dọn phòng (8b)] | - | SD1d-F1 | Toán hạng 2 của alt; đường ngăn là edge SD1d-F1-O2-SEP |
| SD1d-F1-O3 | Fragment | [suất chiếu đã lưu] | - | SD1d-F1 | Toán hạng 3 của alt; đường ngăn là edge SD1d-F1-O3-SEP |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 2.1.17 | :ScheduleShowtimesController | :Auditorium | // saveShowtime (suất chiếu dự kiến, giờ kết thúc) | Đồng bộ | - | 8 |
| 2.1.17.1 | :Auditorium | :PriceList | // checkCoversShowtime (loại phòng, định dạng, loại ghế, giờ bắt đầu) | Đồng bộ | - | 8 |
| 2.1.17.1 (trả về) | :PriceList | :Auditorium | bảng giá có đủ giá hay không | Trả về | - | 8 |
| 2.1.17.2 | :Auditorium | :Auditorium | // checkRoomGap (suất chiếu dự kiến) | Tự gọi | - | 8 |
| 2.1.17.3 | :Auditorium | :Auditorium | // addToSchedule (suất chiếu dự kiến) | Tự gọi | - | 8 |
| 2.1.17 (trả về) | :Auditorium | :ScheduleShowtimesController | kết quả lưu: đã lưu, bảng giá thiếu giá hoặc vi phạm khoảng cách dọn phòng | Trả về | - | 8 |
| 2.1.18 | :ScheduleShowtimesController | :ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-69 bị vi phạm) | Đồng bộ | SD1d-F1 | 8e |
| 2.1.19 | :ScheduleShowtimesController | :ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-51 bị vi phạm) | Đồng bộ | SD1d-F1 | 8b |
| 2.1.20 | :ScheduleShowtimesController | :Showtime | // provideShowtimeInfo | Đồng bộ | - | 9 |
| 2.1.20 (trả về) | :Showtime | :ScheduleShowtimesController | phim, định dạng, phòng chiếu, ngày giờ bắt đầu, giờ kết thúc, thời điểm mở bán | Trả về | - | 9 |
| 2.1.21 | :ScheduleShowtimesController | :ScheduleShowtimesForm | // showSavedShowtime (suất chiếu đã lưu) | Đồng bộ | - | 9 |

### SD2a - Luồng 1a bước 1a1 đến 1a3 và luồng 1a3a, 1a3b

a) Luồng thể hiện: Chọn sửa, hiển thị các suất chiếu đã lập, chọn suất chiếu, kiểm chưa tới giờ bắt đầu. Luồng 1a3b kết thúc use case (thất bại). Việc kiểm không có ghế đang giữ, vé chưa huỷ (1a3, 1a3a) ở SD2c.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD2a-L-A | Actor | :Quản lý cụm rạp | - | - | Tác nhân (ACT-04) |
| SD2a-L-F | Lifeline | :ScheduleShowtimesForm | «boundary» | - | AC-B-ScheduleShowtimesForm |
| SD2a-L-C | Lifeline | :ScheduleShowtimesController | «control» | - | AC-C-ScheduleShowtimesController |
| SD2a-L-CM | Lifeline | :CinemaManager | «entity» | - | AC-E-CinemaManager |
| SD2a-L-ST | Lifeline | :Showtime | «entity» | - | AC-E-Showtime |
| SD2a-F1 | Fragment | loop [mỗi suất chiếu đã lập của các phòng chiếu thuộc cụm rạp] | - | - | Bao các message của fragment |
| SD2a-F2 | Fragment | break [suất chiếu đã tới giờ bắt đầu, kể cả đã kết thúc (1a3b)] | - | - | Bao các message của fragment |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1a | :Quản lý cụm rạp | :ScheduleShowtimesForm | // requestEditShowtime | Đồng bộ | - | 1a |
| 1a.1 | :ScheduleShowtimesForm | :ScheduleShowtimesController | // startEditingShowtime | Đồng bộ | - | 1a |
| 1a.1.1 | :ScheduleShowtimesController | :CinemaManager | // provideCinema | Đồng bộ | - | 1a1 |
| 1a.1.1 (trả về) | :CinemaManager | :ScheduleShowtimesController | cụm rạp của quản lý cụm rạp | Trả về | - | 1a1 |
| 1a.1.2 | :ScheduleShowtimesController | :Showtime | // provideShowtimeInfo | Đồng bộ | SD2a-F1 | 1a1 |
| 1a.1.2 (trả về) | :Showtime | :ScheduleShowtimesController | phim, định dạng, phòng chiếu, ngày giờ bắt đầu, giờ kết thúc, thời điểm mở bán, mốc thay đổi gần nhất | Trả về | SD2a-F1 | 1a1 |
| 1a.1.3 | :ScheduleShowtimesController | :ScheduleShowtimesForm | // showShowtimes (các suất chiếu đã lập) | Đồng bộ | - | 1a1 |
| 1a.2 | :Quản lý cụm rạp | :ScheduleShowtimesForm | // selectShowtimeToEdit (suất chiếu) | Đồng bộ | - | 1a2 |
| 1a.2.1 | :ScheduleShowtimesForm | :ScheduleShowtimesController | // prepareShowtimeEdit (suất chiếu) | Đồng bộ | - | 1a3 |
| 1a.2.1.1 | :ScheduleShowtimesController | :Showtime | // checkNotStarted (thời điểm kiểm tra) | Đồng bộ | - | 1a3 |
| 1a.2.1.1 (trả về) | :Showtime | :ScheduleShowtimesController | suất chiếu đã tới giờ bắt đầu hay chưa | Trả về | - | 1a3 |
| 1a.2.1.2 | :ScheduleShowtimesController | :ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-57 bị vi phạm) | Đồng bộ | SD2a-F2 | 1a3b |

### SD2c - Luồng 1a bước 1a3 (tiếp) và luồng 1a3a

a) Luồng thể hiện: Suất chiếu hỏi từng lần giữ ghế còn hiệu lực không và từng vé đã huỷ chưa. Luồng 1a3a kết thúc use case (thất bại).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD2c-L-F | Lifeline | :ScheduleShowtimesForm | «boundary» | - | AC-B-ScheduleShowtimesForm |
| SD2c-L-C | Lifeline | :ScheduleShowtimesController | «control» | - | AC-C-ScheduleShowtimesController |
| SD2c-L-ST | Lifeline | :Showtime | «entity» | - | AC-E-Showtime |
| SD2c-L-SH | Lifeline | :SeatHold | «entity» | - | AC-E-SeatHold |
| SD2c-L-TK | Lifeline | :Ticket | «entity» | - | AC-E-Ticket |
| SD2c-R1 | Fragment | ref SD2a - Luồng 1a bước 1a1 đến 1a3 và luồng 1a3b | - | - | ref, mức ngoài cùng |
| SD2c-F1 | Fragment | loop [mỗi lần giữ ghế của suất chiếu] | - | - | Bao các message của fragment |
| SD2c-F2 | Fragment | loop [mỗi vé của suất chiếu] | - | - | Bao các message của fragment |
| SD2c-F3 | Fragment | break [suất chiếu có ghế đang được giữ hoặc có vé đã bán chưa bị huỷ (1a3a)] | - | - | Bao các message của fragment |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1a.2.1.3 | :ScheduleShowtimesController | :Showtime | // checkNoActiveHoldOrSoldTicket (thời điểm kiểm tra) | Đồng bộ | - | 1a3 |
| 1a.2.1.3.1 | :Showtime | :SeatHold | // checkHoldStillActive (thời điểm kiểm tra) | Đồng bộ | SD2c-F1 | 1a3 |
| 1a.2.1.3.2 | :Showtime | :Ticket | // checkNotCancelled | Đồng bộ | SD2c-F2 | 1a3 |
| 1a.2.1.3 (trả về) | :Showtime | :ScheduleShowtimesController | suất chiếu có ghế đang được giữ hoặc có vé đã bán chưa bị huỷ hay không | Trả về | - | 1a3 |
| 1a.2.1.4 | :ScheduleShowtimesController | :ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-53 bị vi phạm) | Đồng bộ | SD2c-F3 | 1a3a |

### SD2b - Luồng 1a bước 1a4

a) Luồng thể hiện: Hiển thị thông tin hiện tại của suất chiếu cùng các phòng chiếu và danh sách phim để sửa, rồi tiếp tục bước 3.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD2b-L-F | Lifeline | :ScheduleShowtimesForm | «boundary» | - | AC-B-ScheduleShowtimesForm |
| SD2b-L-C | Lifeline | :ScheduleShowtimesController | «control» | - | AC-C-ScheduleShowtimesController |
| SD2b-L-AU | Lifeline | :Auditorium | «entity» | - | AC-E-Auditorium |
| SD2b-L-MV | Lifeline | :Movie | «entity» | - | AC-E-Movie |
| SD2b-L-ST | Lifeline | :Showtime | «entity» | - | AC-E-Showtime |
| SD2b-R1 | Fragment | ref SD2a - Luồng 1a bước 1a1 đến 1a3 và luồng 1a3a, 1a3b | - | - | ref, mức ngoài cùng |
| SD2b-F1 | Fragment | loop [mỗi phòng chiếu của cụm rạp] | - | - | Bao các message của fragment |
| SD2b-F2 | Fragment | loop [mỗi phim trong danh sách phim] | - | - | Bao các message của fragment |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1a.2.1.5 | :ScheduleShowtimesController | :Showtime | // provideShowtimeInfo | Đồng bộ | - | 1a4 |
| 1a.2.1.5 (trả về) | :Showtime | :ScheduleShowtimesController | phim, định dạng, phòng chiếu, ngày giờ bắt đầu, giờ kết thúc, thời điểm mở bán, mốc thay đổi gần nhất | Trả về | - | 1a4 |
| 1a.2.1.6 | :ScheduleShowtimesController | :Auditorium | // provideAuditoriumInfo (cụm rạp) | Đồng bộ | SD2b-F1 | 1a4 |
| 1a.2.1.6 (trả về) | :Auditorium | :ScheduleShowtimesController | tên phòng, loại phòng, các định dạng chiếu được | Trả về | SD2b-F1 | 1a4 |
| 1a.2.1.7 | :ScheduleShowtimesController | :Movie | // provideMovieInfo | Đồng bộ | SD2b-F2 | 1a4 |
| 1a.2.1.7 (trả về) | :Movie | :ScheduleShowtimesController | tên, các định dạng phát hành, thời lượng, ngày khởi chiếu, ngày kết thúc chiếu | Trả về | SD2b-F2 | 1a4 |
| 1a.2.1.8 | :ScheduleShowtimesController | :ScheduleShowtimesForm | // showShowtimeForEdit (suất chiếu, phòng chiếu, phim) | Đồng bộ | - | 1a4 |

### SD3a - Luồng 1a bước 8

a) Luồng thể hiện: Khi sửa, phòng chiếu đích thực hiện thao tác không chia cắt trên suất chiếu đang sửa, bảng giá và các suất chiếu của phòng; suất chiếu hỏi từng lần giữ ghế và từng vé, và khi phòng chiếu đích khác phòng chiếu hiện tại thì kiểm suất chiếu chưa từng có vé (8f). Thao tác loại trừ với // holdSeats của UC-005 trên cùng suất chiếu (BR-54). Các luồng 8c, 8d, 8a, 8f kết thúc use case (thất bại) ở SD3c.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD3a-L-C | Lifeline | :ScheduleShowtimesController | «control» | - | AC-C-ScheduleShowtimesController |
| SD3a-L-AU | Lifeline | :Auditorium | «entity» | - | AC-E-Auditorium |
| SD3a-L-ST | Lifeline | :Showtime | «entity» | - | AC-E-Showtime |
| SD3a-L-SH | Lifeline | :SeatHold | «entity» | - | AC-E-SeatHold |
| SD3a-L-TK | Lifeline | :Ticket | «entity» | - | AC-E-Ticket |
| SD3a-L-PL | Lifeline | :PriceList | «entity» | - | AC-E-PriceList |
| SD3a-R1 | Fragment | ref SD1c - Luồng chính bước 5 đến 7 và luồng 5a, 5b, 5c, 6a, 6b, 6c | - | - | ref, mức ngoài cùng |
| SD3a-F1 | Fragment | loop [mỗi lần giữ ghế của suất chiếu] | - | - | Bao các message của fragment |
| SD3a-F2 | Fragment | loop [mỗi vé của suất chiếu] | - | - | Bao các message của fragment |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 2.1.17[1a] | :ScheduleShowtimesController | :Auditorium | // saveShowtime (suất chiếu đang sửa, suất chiếu dự kiến, mốc thay đổi đã hiển thị, thời điểm kiểm tra) | Đồng bộ | - | 8 |
| 2.1.17[1a].1 | :Auditorium | :Showtime | // checkUnchangedSinceDisplayed (mốc thay đổi đã hiển thị) | Đồng bộ | - | 8 |
| 2.1.17[1a].2 | :Auditorium | :Showtime | // checkNotStarted (thời điểm kiểm tra) | Đồng bộ | - | 8 |
| 2.1.17[1a].3 | :Auditorium | :Showtime | // checkNoActiveHoldOrSoldTicket (thời điểm kiểm tra) | Đồng bộ | - | 8 |
| 2.1.17[1a].3.1 | :Showtime | :SeatHold | // checkHoldStillActive (thời điểm kiểm tra) | Đồng bộ | SD3a-F1 | 8 |
| 2.1.17[1a].3.2 | :Showtime | :Ticket | // checkNotCancelled | Đồng bộ | SD3a-F2 | 8 |
| 2.1.17[1a].4 | :Auditorium | :Showtime | // checkRoomChangeAllowed (phòng chiếu đích) | Đồng bộ | - | 8 |
| 2.1.17[1a].5 | :Auditorium | :PriceList | // checkCoversShowtime (loại phòng, định dạng, loại ghế, giờ bắt đầu) | Đồng bộ | - | 8 |
| 2.1.17[1a].6 | :Auditorium | :Auditorium | // checkRoomGap (suất chiếu dự kiến, bỏ qua suất chiếu đang sửa) | Tự gọi | - | 8 |
| 2.1.17[1a].7 | :Auditorium | :Showtime | // applyChanges (suất chiếu dự kiến) | Đồng bộ | - | 8 |
| 2.1.17[1a] (trả về) | :Auditorium | :ScheduleShowtimesController | kết quả lưu: đã lưu hoặc lý do bị từ chối (8c, 8d, 8a, 8f, 8e, 8b) | Trả về | - | 8 |

### SD3c - Luồng 8c, 8d, 8a, 8f

a) Luồng thể hiện: Kết quả lưu bị từ chối khi sửa: suất chiếu đã đổi (8c), đã tới giờ bắt đầu (8d), còn ghế đang giữ hoặc vé chưa huỷ (8a), đổi phòng chiếu của suất chiếu đã từng có vé (8f, thông báo theo MSG-83 của P11a). Cả bốn luồng kết thúc use case (thất bại).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD3c-L-F | Lifeline | :ScheduleShowtimesForm | «boundary» | - | AC-B-ScheduleShowtimesForm |
| SD3c-L-C | Lifeline | :ScheduleShowtimesController | «control» | - | AC-C-ScheduleShowtimesController |
| SD3c-R1 | Fragment | ref SD3a - Luồng 1a bước 8 | - | - | ref, mức ngoài cùng |
| SD3c-F1 | Fragment | break [suất chiếu đã bị người khác sửa hoặc xoá kể từ lúc hiển thị (8c)] | - | - | Bao các message của fragment |
| SD3c-F2 | Fragment | break [suất chiếu đã tới giờ bắt đầu (8d)] | - | - | Bao các message của fragment |
| SD3c-F3 | Fragment | break [suất chiếu có ghế đang được giữ hoặc có vé đã bán chưa bị huỷ (8a)] | - | - | Bao các message của fragment |
| SD3c-F4 | Fragment | break [đổi sang phòng chiếu khác khi suất chiếu đã từng có vé, kể cả vé đã huỷ (8f)] | - | - | Bao các message của fragment |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 2.1.18[8c] | :ScheduleShowtimesController | :ScheduleShowtimesForm | // notifyRefusal (suất chiếu đã thay đổi hoặc không còn, quy tắc BR-60) | Đồng bộ | SD3c-F1 | 8c |
| 2.1.18[8d] | :ScheduleShowtimesController | :ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-57 bị vi phạm) | Đồng bộ | SD3c-F2 | 8d |
| 2.1.18[8a] | :ScheduleShowtimesController | :ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-53 bị vi phạm) | Đồng bộ | SD3c-F3 | 8a |
| 2.1.18[8f] | :ScheduleShowtimesController | :ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-92 bị vi phạm) | Đồng bộ | SD3c-F4 | 8f |

### SD3b - Luồng 1a bước 8 (tiếp), luồng 8b, 8e và bước 9

a) Luồng thể hiện: Sau khi qua 8c, 8d, 8a, 8f: bảng giá thiếu giá (8e) hoặc vi phạm khoảng cách dọn phòng (8b) quay lại bước 3; còn lại báo lưu thành công (bước 9).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD3b-L-F | Lifeline | :ScheduleShowtimesForm | «boundary» | - | AC-B-ScheduleShowtimesForm |
| SD3b-L-C | Lifeline | :ScheduleShowtimesController | «control» | - | AC-C-ScheduleShowtimesController |
| SD3b-L-ST | Lifeline | :Showtime | «entity» | - | AC-E-Showtime |
| SD3b-R1 | Fragment | ref SD3c - Luồng 8c, 8d, 8a, 8f | - | - | ref, mức ngoài cùng |
| SD3b-F1 | Fragment | alt [bảng giá chưa đủ giá khi lưu (8e)] | - | - | Bao các message của fragment |
| SD3b-F1-O2 | Fragment | [suất chiếu cách suất chiếu khác dưới 15 phút dọn phòng (8b)] | - | SD3b-F1 | Toán hạng 2 của alt; đường ngăn là edge SD3b-F1-O2-SEP |
| SD3b-F1-O3 | Fragment | [suất chiếu đã được cập nhật] | - | SD3b-F1 | Toán hạng 3 của alt; đường ngăn là edge SD3b-F1-O3-SEP |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 2.1.19[8e] | :ScheduleShowtimesController | :ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-69 bị vi phạm) | Đồng bộ | SD3b-F1 | 8e |
| 2.1.19[8b] | :ScheduleShowtimesController | :ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-51 bị vi phạm) | Đồng bộ | SD3b-F1 | 8b |
| 2.1.20[1a] | :ScheduleShowtimesController | :Showtime | // provideShowtimeInfo | Đồng bộ | - | 9 |
| 2.1.20[1a] (trả về) | :Showtime | :ScheduleShowtimesController | phim, định dạng, phòng chiếu, ngày giờ bắt đầu, giờ kết thúc, thời điểm mở bán | Trả về | - | 9 |
| 2.1.21[1a] | :ScheduleShowtimesController | :ScheduleShowtimesForm | // showSavedShowtime (suất chiếu đã lưu) | Đồng bộ | - | 9 |

### SD4a - Luồng 1b bước 1b1, 1b2

a) Luồng thể hiện: Chọn xoá, hiển thị các suất chiếu đã lập, chọn suất chiếu cần xoá.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD4a-L-A | Actor | :Quản lý cụm rạp | - | - | Tác nhân (ACT-04) |
| SD4a-L-F | Lifeline | :ScheduleShowtimesForm | «boundary» | - | AC-B-ScheduleShowtimesForm |
| SD4a-L-C | Lifeline | :ScheduleShowtimesController | «control» | - | AC-C-ScheduleShowtimesController |
| SD4a-L-CM | Lifeline | :CinemaManager | «entity» | - | AC-E-CinemaManager |
| SD4a-L-ST | Lifeline | :Showtime | «entity» | - | AC-E-Showtime |
| SD4a-F1 | Fragment | loop [mỗi suất chiếu đã lập của các phòng chiếu thuộc cụm rạp] | - | - | Bao các message của fragment |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1b | :Quản lý cụm rạp | :ScheduleShowtimesForm | // requestDeleteShowtime | Đồng bộ | - | 1b |
| 1b.1 | :ScheduleShowtimesForm | :ScheduleShowtimesController | // startDeletingShowtime | Đồng bộ | - | 1b |
| 1b.1.1 | :ScheduleShowtimesController | :CinemaManager | // provideCinema | Đồng bộ | - | 1b1 |
| 1b.1.1 (trả về) | :CinemaManager | :ScheduleShowtimesController | cụm rạp của quản lý cụm rạp | Trả về | - | 1b1 |
| 1b.1.2 | :ScheduleShowtimesController | :Showtime | // provideShowtimeInfo | Đồng bộ | SD4a-F1 | 1b1 |
| 1b.1.2 (trả về) | :Showtime | :ScheduleShowtimesController | phim, định dạng, phòng chiếu, ngày giờ bắt đầu, giờ kết thúc, thời điểm mở bán, mốc thay đổi gần nhất | Trả về | SD4a-F1 | 1b1 |
| 1b.1.3 | :ScheduleShowtimesController | :ScheduleShowtimesForm | // showShowtimes (các suất chiếu đã lập) | Đồng bộ | - | 1b1 |
| 1b.2 | :Quản lý cụm rạp | :ScheduleShowtimesForm | // selectShowtimeToDelete (suất chiếu) | Đồng bộ | - | 1b2 |

### SD4b - Luồng 1b bước 1b3

a) Luồng thể hiện: Kiểm và xoá suất chiếu khỏi lịch chiếu trong một thao tác không chia cắt, giữ lại dữ liệu của suất chiếu; suất chiếu hỏi từng lần giữ ghế và từng vé. Thao tác loại trừ với // holdSeats của UC-005 trên cùng suất chiếu (BR-54). Các luồng 1b3c, 1b3b, 1b3a kết thúc use case (thất bại) và bước 1b4 ở SD4c.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD4b-L-F | Lifeline | :ScheduleShowtimesForm | «boundary» | - | AC-B-ScheduleShowtimesForm |
| SD4b-L-C | Lifeline | :ScheduleShowtimesController | «control» | - | AC-C-ScheduleShowtimesController |
| SD4b-L-ST | Lifeline | :Showtime | «entity» | - | AC-E-Showtime |
| SD4b-L-SH | Lifeline | :SeatHold | «entity» | - | AC-E-SeatHold |
| SD4b-L-TK | Lifeline | :Ticket | «entity» | - | AC-E-Ticket |
| SD4b-R1 | Fragment | ref SD4a - Luồng 1b bước 1b1, 1b2 | - | - | ref, mức ngoài cùng |
| SD4b-F1 | Fragment | loop [mỗi lần giữ ghế của suất chiếu] | - | - | Bao các message của fragment |
| SD4b-F2 | Fragment | loop [mỗi vé của suất chiếu] | - | - | Bao các message của fragment |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1b.2.1 | :ScheduleShowtimesForm | :ScheduleShowtimesController | // deleteShowtime (suất chiếu, mốc thay đổi đã hiển thị) | Đồng bộ | - | 1b3 |
| 1b.2.1.1 | :ScheduleShowtimesController | :Showtime | // removeFromSchedule (mốc thay đổi đã hiển thị, thời điểm kiểm tra) | Đồng bộ | - | 1b3 |
| 1b.2.1.1.1 | :Showtime | :Showtime | // checkUnchangedSinceDisplayed (mốc thay đổi đã hiển thị) | Tự gọi | - | 1b3 |
| 1b.2.1.1.2 | :Showtime | :Showtime | // checkNotStarted (thời điểm kiểm tra) | Tự gọi | - | 1b3 |
| 1b.2.1.1.3 | :Showtime | :Showtime | // checkNoActiveHoldOrSoldTicket (thời điểm kiểm tra) | Tự gọi | - | 1b3 |
| 1b.2.1.1.3.1 | :Showtime | :SeatHold | // checkHoldStillActive (thời điểm kiểm tra) | Đồng bộ | SD4b-F1 | 1b3 |
| 1b.2.1.1.3.2 | :Showtime | :Ticket | // checkNotCancelled | Đồng bộ | SD4b-F2 | 1b3 |
| 1b.2.1.1.4 | :Showtime | :Showtime | // markDeleted | Tự gọi | - | 1b3 |
| 1b.2.1.1 (trả về) | :Showtime | :ScheduleShowtimesController | kết quả xoá: đã xoá hoặc lý do bị từ chối (1b3c, 1b3b, 1b3a) | Trả về | - | 1b3 |

### SD4c - Luồng 1b bước 1b4 và luồng 1b3a, 1b3b, 1b3c

a) Luồng thể hiện: Kết quả xoá: bị từ chối (1b3c, 1b3b, 1b3a, kết thúc thất bại) hoặc thông báo xoá thành công (1b4).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD4c-L-F | Lifeline | :ScheduleShowtimesForm | «boundary» | - | AC-B-ScheduleShowtimesForm |
| SD4c-L-C | Lifeline | :ScheduleShowtimesController | «control» | - | AC-C-ScheduleShowtimesController |
| SD4c-R1 | Fragment | ref SD4b - Luồng 1b bước 1b3 | - | - | ref, mức ngoài cùng |
| SD4c-F1 | Fragment | break [suất chiếu đã bị người khác sửa hoặc xoá kể từ lúc hiển thị (1b3c)] | - | - | Bao các message của fragment |
| SD4c-F2 | Fragment | break [suất chiếu đã tới giờ bắt đầu, kể cả đã kết thúc (1b3b)] | - | - | Bao các message của fragment |
| SD4c-F3 | Fragment | break [suất chiếu có ghế đang được giữ hoặc có vé đã bán chưa bị huỷ (1b3a)] | - | - | Bao các message của fragment |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1b.2.1.2 | :ScheduleShowtimesController | :ScheduleShowtimesForm | // notifyRefusal (suất chiếu đã thay đổi hoặc không còn, quy tắc BR-60) | Đồng bộ | SD4c-F1 | 1b3c |
| 1b.2.1.3 | :ScheduleShowtimesController | :ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-57 bị vi phạm) | Đồng bộ | SD4c-F2 | 1b3b |
| 1b.2.1.4 | :ScheduleShowtimesController | :ScheduleShowtimesForm | // notifyRefusal (quy tắc BR-53 bị vi phạm) | Đồng bộ | SD4c-F3 | 1b3a |
| 1b.2.1.5 | :ScheduleShowtimesController | :ScheduleShowtimesForm | // notifyDeleted (suất chiếu đã xoá) | Đồng bộ | - | 1b4 |

### SD5 - Luồng *a

a) Luồng thể hiện: Quản lý cụm rạp huỷ yêu cầu tại bất kỳ bước nào trước bước 8, kể cả trong luồng 1a, 1b trước 1a3, 1b3. Hệ thống không thay đổi suất chiếu nào.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD5-L-A | Actor | :Quản lý cụm rạp | - | - | Tác nhân (ACT-04) |
| SD5-L-F | Lifeline | :ScheduleShowtimesForm | «boundary» | - | AC-B-ScheduleShowtimesForm |
| SD5-L-C | Lifeline | :ScheduleShowtimesController | «control» | - | AC-C-ScheduleShowtimesController |
| SD5-R1 | Fragment | ref SD1c - Luồng chính bước 5 đến 7 và luồng 5a, 5b, 5c, 6a, 6b, 6c | - | - | ref, mức ngoài cùng |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1*a | :Quản lý cụm rạp | :ScheduleShowtimesForm | // cancelRequest | Đồng bộ | - | *a |
| 1*a.1 | :ScheduleShowtimesForm | :ScheduleShowtimesController | // cancelRequest | Đồng bộ | - | *a |
| 1*a.1.1 | :ScheduleShowtimesController | :ScheduleShowtimesController | // discardRequest (không thay đổi suất chiếu nào) | Tự gọi | - | *a |
| 1*a.1.2 | :ScheduleShowtimesController | :ScheduleShowtimesForm | // showRequestCancelled | Đồng bộ | - | *a |

## 6. Quy tắc tương tác giữa các lớp phân tích

Đã kiểm trên mọi message và mọi link: Actor chỉ gửi tới ScheduleShowtimesForm; ScheduleShowtimesForm chỉ gửi tới ScheduleShowtimesController và actor của nó; ScheduleShowtimesController gửi tới boundary và entity; entity chỉ gửi tới entity có quan hệ cấu trúc (Auditorium tới Showtime, Auditorium tới PriceList, Showtime tới Movie).

| Vi phạm | Message hoặc link | Cách sửa đã áp dụng |
|---|---|---|
| Không có | - | - |

## 7. Communication diagram

File diagrams/P07-communication-UC-014.drawio có 3 trang. MUC_CHI_TIET là DAY_DU nên có đủ luồng chính (SD1a đến SD1d, kể cả 4a, 5a, 5b, 5c, 6a, 6b, 6c, 8b, 8e), luồng 1a (SD2a, SD2c, SD2b, SD3a, SD3c, SD3b, kể cả 8f), luồng 1b (SD4a, SD4b, SD4c) và luồng *a (SD5), giữ STT của trang chứa luồng. ID cell đối tượng là "<ID trang>-O-<khoá>", link là "<ID trang>-L<số>".

### Trang CM1 - Luồng chính (SD1a, SD1b, SD1c, SD1d)

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| CM1-O-A | Actor | :Quản lý cụm rạp | - | - | Tác nhân (ACT-04) |
| CM1-O-F | Object | :ScheduleShowtimesForm | «boundary» | - | AC-B-ScheduleShowtimesForm |
| CM1-O-C | Object | :ScheduleShowtimesController | «control» | - | AC-C-ScheduleShowtimesController |
| CM1-O-CM | Object | :CinemaManager | «entity» | - | AC-E-CinemaManager |
| CM1-O-AU | Object | :Auditorium | «entity» | - | AC-E-Auditorium |
| CM1-O-MV | Object | :Movie | «entity» | - | AC-E-Movie |
| CM1-O-ST | Object | :Showtime | «entity» | - | AC-E-Showtime; đỉnh lifeline đặt ngang message Tạo |
| CM1-O-PL | Object | :PriceList | «entity» | - | AC-E-PriceList |

b) Bảng Edge (link)

| ID | Nguồn | Đích | Loại (Link) | Nhãn (các message theo STT) | Chiều message (Nguồn-->Đích hoặc Đích-->Nguồn) |
|---|---|---|---|---|---|
| CM1-L1 | CM1-O-A | CM1-O-F | Link | 1: // requestNewShowtime (-->)<br>2: // submitShowtimeInfo (phim, định dạng, phòng chiếu, giờ bắt đầu, thời điểm mở bán) (-->) | Nguồn-->Đích: 1, 2 |
| CM1-L2 | CM1-O-F | CM1-O-C | Link | 1.1: // startScheduling (-->)<br>1.1.4: // showAuditoriumsAndMovies (phòng chiếu, phim) (<--)<br>2.1: // requestSaveShowtime (phim, định dạng, phòng chiếu, giờ bắt đầu, thời điểm mở bán) (-->)<br>2.1.3: // notifyRefusal (quy tắc BR-46 bị vi phạm) (<--) [phòng chiếu không thuộc cụm rạp của quản lý cụm rạp (4a)]<br>2.1.8: // notifyRefusal (quy tắc BR-47 bị vi phạm) (<--) [định dạng không là định dạng phát hành (5a)]<br>2.1.9: // notifyRefusal (quy tắc BR-48 bị vi phạm) (<--) [định dạng không là định dạng phát hành (5a)]<br>2.1.10: // notifyRefusal (quy tắc BR-69 bị vi phạm) (<--) [định dạng không là định dạng phát hành (5a)]<br>2.1.13: // notifyRefusal (quy tắc BR-49 bị vi phạm) (<--) [ngày chiếu ngoài khoảng chiếu của phim (6a)]<br>2.1.14: // notifyRefusal (quy tắc BR-56 bị vi phạm) (<--) [ngày chiếu ngoài khoảng chiếu của phim (6a)]<br>2.1.15: // notifyRefusal (quy tắc BR-55 bị vi phạm) (<--) [ngày chiếu ngoài khoảng chiếu của phim (6a)]<br>2.1.18: // notifyRefusal (quy tắc BR-69 bị vi phạm) (<--) [bảng giá chưa đủ giá khi lưu (8e)]<br>2.1.19: // notifyRefusal (quy tắc BR-51 bị vi phạm) (<--) [bảng giá chưa đủ giá khi lưu (8e)]<br>2.1.21: // showSavedShowtime (suất chiếu đã lưu) (<--) | Nguồn-->Đích: 1.1, 2.1; Đích-->Nguồn: 1.1.4, 2.1.3, 2.1.8, 2.1.9, 2.1.10, 2.1.13, 2.1.14, 2.1.15, 2.1.18, 2.1.19, 2.1.21 |
| CM1-L3 | CM1-O-C | CM1-O-CM | Link | 1.1.1: // provideCinema (-->)<br>2.1.1: // provideCinema (-->) | Nguồn-->Đích: 1.1.1, 2.1.1 |
| CM1-L4 | CM1-O-C | CM1-O-AU | Link | 1.1.2: // provideAuditoriumInfo (cụm rạp) (-->) [lặp: mỗi phòng chiếu của cụm rạp]<br>2.1.2: // checkBelongsToCinema (cụm rạp của quản lý cụm rạp) (-->)<br>2.1.5: // checkSupportsFormat (định dạng) (-->)<br>2.1.6: // provideSeatTypes (-->)<br>2.1.12: // draftShowtime (phim, định dạng, giờ bắt đầu, thời điểm mở bán) (-->)<br>2.1.17: // saveShowtime (suất chiếu dự kiến, giờ kết thúc) (-->) | Nguồn-->Đích: 1.1.2, 2.1.2, 2.1.5, 2.1.6, 2.1.12, 2.1.17 |
| CM1-L5 | CM1-O-C | CM1-O-MV | Link | 1.1.3: // provideMovieInfo (-->) [lặp: mỗi phim trong danh sách phim]<br>2.1.4: // checkReleasedInFormat (định dạng) (-->)<br>2.1.11: // checkWithinRunPeriod (ngày của giờ bắt đầu) (-->) | Nguồn-->Đích: 1.1.3, 2.1.4, 2.1.11 |
| CM1-L6 | CM1-O-C | CM1-O-PL | Link | 2.1.7: // checkCoversShowtime (loại phòng, định dạng, các loại ghế, giờ bắt đầu) (-->) | Nguồn-->Đích: 2.1.7 |
| CM1-L7 | CM1-O-AU | CM1-O-ST | Link | 2.1.12.1: «create» // createShowtime (phim, định dạng, phòng chiếu, giờ bắt đầu, thời điểm mở bán) (-->) | Nguồn-->Đích: 2.1.12.1 |
| CM1-L8 | CM1-O-ST | CM1-O-ST | Link | 2.1.12.1.1: // checkStartAfter (thời điểm kiểm tra) (-->)<br>2.1.12.1.2: // checkSaleOpenBeforeStart (-->) | Nguồn-->Đích: 2.1.12.1.1, 2.1.12.1.2 |
| CM1-L9 | CM1-O-C | CM1-O-ST | Link | 2.1.16: // calculateEndTime (-->)<br>2.1.20: // provideShowtimeInfo (-->) | Nguồn-->Đích: 2.1.16, 2.1.20 |
| CM1-L10 | CM1-O-ST | CM1-O-MV | Link | 2.1.16.1: // provideDuration (-->) | Nguồn-->Đích: 2.1.16.1 |
| CM1-L11 | CM1-O-AU | CM1-O-PL | Link | 2.1.17.1: // checkCoversShowtime (loại phòng, định dạng, loại ghế, giờ bắt đầu) (-->) | Nguồn-->Đích: 2.1.17.1 |
| CM1-L12 | CM1-O-AU | CM1-O-AU | Link | 2.1.17.2: // checkRoomGap (suất chiếu dự kiến) (-->)<br>2.1.17.3: // addToSchedule (suất chiếu dự kiến) (-->) | Nguồn-->Đích: 2.1.17.2, 2.1.17.3 |

### Trang CM2 - Luồng 1a (SD2a, SD2c, SD2b, SD3a, SD3c, SD3b)

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| CM2-O-A | Actor | :Quản lý cụm rạp | - | - | Tác nhân (ACT-04) |
| CM2-O-F | Object | :ScheduleShowtimesForm | «boundary» | - | AC-B-ScheduleShowtimesForm |
| CM2-O-C | Object | :ScheduleShowtimesController | «control» | - | AC-C-ScheduleShowtimesController |
| CM2-O-CM | Object | :CinemaManager | «entity» | - | AC-E-CinemaManager |
| CM2-O-ST | Object | :Showtime | «entity» | - | AC-E-Showtime |
| CM2-O-SH | Object | :SeatHold | «entity» | - | AC-E-SeatHold |
| CM2-O-TK | Object | :Ticket | «entity» | - | AC-E-Ticket |
| CM2-O-AU | Object | :Auditorium | «entity» | - | AC-E-Auditorium |
| CM2-O-MV | Object | :Movie | «entity» | - | AC-E-Movie |
| CM2-O-PL | Object | :PriceList | «entity» | - | AC-E-PriceList |

b) Bảng Edge (link)

| ID | Nguồn | Đích | Loại (Link) | Nhãn (các message theo STT) | Chiều message (Nguồn-->Đích hoặc Đích-->Nguồn) |
|---|---|---|---|---|---|
| CM2-L1 | CM2-O-A | CM2-O-F | Link | 1a: // requestEditShowtime (-->)<br>1a.2: // selectShowtimeToEdit (suất chiếu) (-->) | Nguồn-->Đích: 1a, 1a.2 |
| CM2-L2 | CM2-O-F | CM2-O-C | Link | 1a.1: // startEditingShowtime (-->)<br>1a.1.3: // showShowtimes (các suất chiếu đã lập) (<--)<br>1a.2.1: // prepareShowtimeEdit (suất chiếu) (-->)<br>1a.2.1.2: // notifyRefusal (quy tắc BR-57 bị vi phạm) (<--) [suất chiếu đã tới giờ bắt đầu, kể cả đã kết thúc (1a3b)]<br>1a.2.1.4: // notifyRefusal (quy tắc BR-53 bị vi phạm) (<--) [suất chiếu có ghế đang được giữ hoặc có vé đã bán chưa bị huỷ (1a3a)]<br>1a.2.1.8: // showShowtimeForEdit (suất chiếu, phòng chiếu, phim) (<--)<br>2.1.18[8c]: // notifyRefusal (suất chiếu đã thay đổi hoặc không còn, quy tắc BR-60) (<--) [suất chiếu đã bị người khác sửa hoặc xoá kể từ lúc hiển thị (8c)]<br>2.1.18[8d]: // notifyRefusal (quy tắc BR-57 bị vi phạm) (<--) [suất chiếu đã tới giờ bắt đầu (8d)]<br>2.1.18[8a]: // notifyRefusal (quy tắc BR-53 bị vi phạm) (<--) [suất chiếu có ghế đang được giữ hoặc có vé đã bán chưa bị huỷ (8a)]<br>2.1.18[8f]: // notifyRefusal (quy tắc BR-92 bị vi phạm) (<--) [đổi sang phòng chiếu khác khi suất chiếu đã từng có vé (8f)]<br>2.1.19[8e]: // notifyRefusal (quy tắc BR-69 bị vi phạm) (<--) [bảng giá chưa đủ giá khi lưu (8e)]<br>2.1.19[8b]: // notifyRefusal (quy tắc BR-51 bị vi phạm) (<--) [bảng giá chưa đủ giá khi lưu (8e)]<br>2.1.21[1a]: // showSavedShowtime (suất chiếu đã lưu) (<--) | Nguồn-->Đích: 1a.1, 1a.2.1; Đích-->Nguồn: 1a.1.3, 1a.2.1.2, 1a.2.1.4, 1a.2.1.8, 2.1.18[8c], 2.1.18[8d], 2.1.18[8a], 2.1.18[8f], 2.1.19[8e], 2.1.19[8b], 2.1.21[1a] |
| CM2-L3 | CM2-O-C | CM2-O-CM | Link | 1a.1.1: // provideCinema (-->) | Nguồn-->Đích: 1a.1.1 |
| CM2-L4 | CM2-O-C | CM2-O-ST | Link | 1a.1.2: // provideShowtimeInfo (-->) [lặp: mỗi suất chiếu đã lập của các phòng chiếu thuộc cụm rạp]<br>1a.2.1.1: // checkNotStarted (thời điểm kiểm tra) (-->)<br>1a.2.1.3: // checkNoActiveHoldOrSoldTicket (thời điểm kiểm tra) (-->)<br>1a.2.1.5: // provideShowtimeInfo (-->)<br>2.1.20[1a]: // provideShowtimeInfo (-->) | Nguồn-->Đích: 1a.1.2, 1a.2.1.1, 1a.2.1.3, 1a.2.1.5, 2.1.20[1a] |
| CM2-L5 | CM2-O-ST | CM2-O-SH | Link | 1a.2.1.3.1: // checkHoldStillActive (thời điểm kiểm tra) (-->) [lặp: mỗi lần giữ ghế của suất chiếu]<br>2.1.17[1a].3.1: // checkHoldStillActive (thời điểm kiểm tra) (-->) [lặp: mỗi lần giữ ghế của suất chiếu] | Nguồn-->Đích: 1a.2.1.3.1, 2.1.17[1a].3.1 |
| CM2-L6 | CM2-O-ST | CM2-O-TK | Link | 1a.2.1.3.2: // checkNotCancelled (-->) [lặp: mỗi vé của suất chiếu]<br>2.1.17[1a].3.2: // checkNotCancelled (-->) [lặp: mỗi vé của suất chiếu] | Nguồn-->Đích: 1a.2.1.3.2, 2.1.17[1a].3.2 |
| CM2-L7 | CM2-O-C | CM2-O-AU | Link | 1a.2.1.6: // provideAuditoriumInfo (cụm rạp) (-->) [lặp: mỗi phòng chiếu của cụm rạp]<br>2.1.17[1a]: // saveShowtime (suất chiếu đang sửa, suất chiếu dự kiến, mốc thay đổi đã hiển thị, thời điểm kiểm tra) (-->) | Nguồn-->Đích: 1a.2.1.6, 2.1.17[1a] |
| CM2-L8 | CM2-O-C | CM2-O-MV | Link | 1a.2.1.7: // provideMovieInfo (-->) [lặp: mỗi phim trong danh sách phim] | Nguồn-->Đích: 1a.2.1.7 |
| CM2-L9 | CM2-O-AU | CM2-O-ST | Link | 2.1.17[1a].1: // checkUnchangedSinceDisplayed (mốc thay đổi đã hiển thị) (-->)<br>2.1.17[1a].2: // checkNotStarted (thời điểm kiểm tra) (-->)<br>2.1.17[1a].3: // checkNoActiveHoldOrSoldTicket (thời điểm kiểm tra) (-->)<br>2.1.17[1a].4: // checkRoomChangeAllowed (phòng chiếu đích) (-->)<br>2.1.17[1a].7: // applyChanges (suất chiếu dự kiến) (-->) | Nguồn-->Đích: 2.1.17[1a].1, 2.1.17[1a].2, 2.1.17[1a].3, 2.1.17[1a].4, 2.1.17[1a].7 |
| CM2-L10 | CM2-O-AU | CM2-O-PL | Link | 2.1.17[1a].5: // checkCoversShowtime (loại phòng, định dạng, loại ghế, giờ bắt đầu) (-->) | Nguồn-->Đích: 2.1.17[1a].5 |
| CM2-L11 | CM2-O-AU | CM2-O-AU | Link | 2.1.17[1a].6: // checkRoomGap (suất chiếu dự kiến, bỏ qua suất chiếu đang sửa) (-->) | Nguồn-->Đích: 2.1.17[1a].6 |

### Trang CM3 - Luồng 1b và *a (SD4a, SD4b, SD4c, SD5)

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| CM3-O-A | Actor | :Quản lý cụm rạp | - | - | Tác nhân (ACT-04) |
| CM3-O-F | Object | :ScheduleShowtimesForm | «boundary» | - | AC-B-ScheduleShowtimesForm |
| CM3-O-C | Object | :ScheduleShowtimesController | «control» | - | AC-C-ScheduleShowtimesController |
| CM3-O-CM | Object | :CinemaManager | «entity» | - | AC-E-CinemaManager |
| CM3-O-ST | Object | :Showtime | «entity» | - | AC-E-Showtime |
| CM3-O-SH | Object | :SeatHold | «entity» | - | AC-E-SeatHold |
| CM3-O-TK | Object | :Ticket | «entity» | - | AC-E-Ticket |

b) Bảng Edge (link)

| ID | Nguồn | Đích | Loại (Link) | Nhãn (các message theo STT) | Chiều message (Nguồn-->Đích hoặc Đích-->Nguồn) |
|---|---|---|---|---|---|
| CM3-L1 | CM3-O-A | CM3-O-F | Link | 1b: // requestDeleteShowtime (-->)<br>1b.2: // selectShowtimeToDelete (suất chiếu) (-->)<br>1*a: // cancelRequest (-->) | Nguồn-->Đích: 1b, 1b.2, 1*a |
| CM3-L2 | CM3-O-F | CM3-O-C | Link | 1b.1: // startDeletingShowtime (-->)<br>1b.1.3: // showShowtimes (các suất chiếu đã lập) (<--)<br>1b.2.1: // deleteShowtime (suất chiếu, mốc thay đổi đã hiển thị) (-->)<br>1b.2.1.2: // notifyRefusal (suất chiếu đã thay đổi hoặc không còn, quy tắc BR-60) (<--) [suất chiếu đã bị người khác sửa hoặc xoá kể từ lúc hiển thị (1b3c)]<br>1b.2.1.3: // notifyRefusal (quy tắc BR-57 bị vi phạm) (<--) [suất chiếu đã tới giờ bắt đầu, kể cả đã kết thúc (1b3b)]<br>1b.2.1.4: // notifyRefusal (quy tắc BR-53 bị vi phạm) (<--) [suất chiếu có ghế đang được giữ hoặc có vé đã bán chưa bị huỷ (1b3a)]<br>1b.2.1.5: // notifyDeleted (suất chiếu đã xoá) (<--)<br>1*a.1: // cancelRequest (-->)<br>1*a.1.2: // showRequestCancelled (<--) | Nguồn-->Đích: 1b.1, 1b.2.1, 1*a.1; Đích-->Nguồn: 1b.1.3, 1b.2.1.2, 1b.2.1.3, 1b.2.1.4, 1b.2.1.5, 1*a.1.2 |
| CM3-L3 | CM3-O-C | CM3-O-CM | Link | 1b.1.1: // provideCinema (-->) | Nguồn-->Đích: 1b.1.1 |
| CM3-L4 | CM3-O-C | CM3-O-ST | Link | 1b.1.2: // provideShowtimeInfo (-->) [lặp: mỗi suất chiếu đã lập của các phòng chiếu thuộc cụm rạp]<br>1b.2.1.1: // removeFromSchedule (mốc thay đổi đã hiển thị, thời điểm kiểm tra) (-->) | Nguồn-->Đích: 1b.1.2, 1b.2.1.1 |
| CM3-L5 | CM3-O-ST | CM3-O-ST | Link | 1b.2.1.1.1: // checkUnchangedSinceDisplayed (mốc thay đổi đã hiển thị) (-->)<br>1b.2.1.1.2: // checkNotStarted (thời điểm kiểm tra) (-->)<br>1b.2.1.1.3: // checkNoActiveHoldOrSoldTicket (thời điểm kiểm tra) (-->)<br>1b.2.1.1.4: // markDeleted (-->) | Nguồn-->Đích: 1b.2.1.1.1, 1b.2.1.1.2, 1b.2.1.1.3, 1b.2.1.1.4 |
| CM3-L6 | CM3-O-ST | CM3-O-SH | Link | 1b.2.1.1.3.1: // checkHoldStillActive (thời điểm kiểm tra) (-->) [lặp: mỗi lần giữ ghế của suất chiếu] | Nguồn-->Đích: 1b.2.1.1.3.1 |
| CM3-L7 | CM3-O-ST | CM3-O-TK | Link | 1b.2.1.1.3.2: // checkNotCancelled (-->) [lặp: mỗi vé của suất chiếu] | Nguồn-->Đích: 1b.2.1.1.3.2 |
| CM3-L8 | CM3-O-C | CM3-O-C | Link | 1*a.1.1: // discardRequest (không thay đổi suất chiếu nào) (-->) | Nguồn-->Đích: 1*a.1.1 |

## 8. VOPC

File diagrams/P07-class-UC-014.drawio. ID cell của lớp là mã AC; ngăn thuộc tính và ngăn trách nhiệm có ID "<mã AC>-ATTR" và "<mã AC>-RESP".

a) Bảng Node (lớp)

| ID (mã AC) | Loại (Class) | Nhãn (tên lớp) | Stereotype | Thuộc về | Ngăn thuộc tính | Ngăn trách nhiệm |
|---|---|---|---|---|---|---|
| AC-B-ScheduleShowtimesForm | Class | ScheduleShowtimesForm | «boundary» | - | showtimeInput (Phim, định dạng, phòng chiếu, giờ bắt đầu, thời điểm mở bán)<br>selectedShowtime (Suất chiếu được chọn, mốc thay đổi đã hiển thị) | // requestNewShowtime<br>// requestEditShowtime<br>// requestDeleteShowtime<br>// showAuditoriumsAndMovies<br>// submitShowtimeInfo<br>// showShowtimes<br>// selectShowtimeToEdit<br>// selectShowtimeToDelete<br>// showShowtimeForEdit<br>// showSavedShowtime<br>// notifyDeleted<br>// notifyRefusal<br>// cancelRequest<br>// showRequestCancelled |
| AC-C-ScheduleShowtimesController | Class | ScheduleShowtimesController | «control» | - | - | // startScheduling<br>// requestSaveShowtime<br>// startEditingShowtime<br>// prepareShowtimeEdit<br>// startDeletingShowtime<br>// deleteShowtime<br>// cancelRequest<br>// discardRequest |
| AC-E-CinemaManager | Class | CinemaManager | «entity» | - | cinema (Cụm rạp) | // provideCinema |
| AC-E-Auditorium | Class | Auditorium | «entity» | - | name (Văn bản)<br>auditoriumType (Văn bản)<br>supportedFormats (Văn bản)<br>seatTypes (Văn bản)<br>cinema (Cụm rạp) | // provideAuditoriumInfo<br>// checkBelongsToCinema<br>// checkSupportsFormat<br>// provideSeatTypes<br>// draftShowtime<br>// saveShowtime<br>// checkRoomGap<br>// addToSchedule |
| AC-E-Movie | Class | Movie | «entity» | - | title (Văn bản)<br>releaseFormats (Văn bản)<br>duration (Số phút)<br>releaseDate (Ngày)<br>endOfRunDate (Ngày) | // provideMovieInfo<br>// checkReleasedInFormat<br>// checkWithinRunPeriod<br>// provideDuration |
| AC-E-Showtime | Class | Showtime | «entity» | - | startTime (Ngày giờ)<br>saleOpenTime (Ngày giờ)<br>movieFormat (Văn bản)<br>auditoriumType (Văn bản)<br>cinema (Cụm rạp)<br>lastChangedAt (Ngày giờ)<br>movie (Phim) (mới ở UC này)<br>auditorium (Phòng chiếu) (mới ở UC này)<br>endTime (Ngày giờ) (mới ở UC này)<br>status (Trạng thái: Trong lịch chiếu, Đã xoá) (mới ở UC này) | // createShowtime<br>// checkStartAfter<br>// checkSaleOpenBeforeStart<br>// calculateEndTime<br>// checkUnchangedSinceDisplayed<br>// checkNotStarted<br>// checkNoActiveHoldOrSoldTicket<br>// checkRoomChangeAllowed<br>// applyChanges<br>// removeFromSchedule<br>// markDeleted<br>// provideShowtimeInfo |
| AC-E-SeatHold | Class | SeatHold | «entity» | - | - | // checkHoldStillActive |
| AC-E-Ticket | Class | Ticket | «entity» | - | - | // checkNotCancelled |
| AC-E-PriceList | Class | PriceList | «entity» | - | cinema (Cụm rạp) | // checkCoversShowtime |

b) Bảng quan hệ

| ID | Lớp A | Lớp B | Loại | Multiplicity | Vai trò | Nguồn |
|---|---|---|---|---|---|---|
| R-UC014-01 | AC-B-ScheduleShowtimesForm | AC-C-ScheduleShowtimesController | Association | - | - | tạm thời; link F7: CM1-L2, CM2-L2, CM3-L2 |
| R-UC014-02 | AC-C-ScheduleShowtimesController | AC-E-CinemaManager | Association | - | - | tạm thời; link F7: CM1-L3, CM2-L3, CM3-L3 |
| R-UC014-03 | AC-C-ScheduleShowtimesController | AC-E-Auditorium | Association | - | - | tạm thời; link F7: CM1-L4, CM2-L7 |
| R-UC014-04 | AC-C-ScheduleShowtimesController | AC-E-Movie | Association | - | - | tạm thời; link F7: CM1-L5, CM2-L8 |
| R-UC014-05 | AC-C-ScheduleShowtimesController | AC-E-Showtime | Association | - | - | tạm thời; link F7: CM1-L9, CM2-L4, CM3-L4 |
| R-UC014-06 | AC-C-ScheduleShowtimesController | AC-E-PriceList | Association | - | - | tạm thời; link F7: CM1-L6 |
| R-UC014-07 | AC-E-Auditorium | AC-E-Showtime | Association | A 1 - B 0..* | - | Suất chiếu diễn ra trong đúng một phòng chiếu và phòng chiếu có lịch chiếu gồm các suất chiếu (GL-47, BR-51, BR-52); link F7: CM1-L7, CM2-L9 |
| R-UC014-08 | AC-E-Auditorium | AC-E-PriceList | Association | A 0..* - B 1 | - | Giá lấy theo bảng giá của cụm rạp có phòng chiếu (GL-01, GL-03, BR-69); đường qua Cụm rạp rút gọn, Q-81; link F7: CM1-L11, CM2-L10 |
| R-UC014-09 | AC-E-Showtime | AC-E-Movie | Association | A 0..* - B 1 | - | Mỗi suất chiếu trình chiếu một phim (GL-47, BR-50); link F7: CM1-L10 |
| R-UC014-10 | AC-E-Showtime | AC-E-SeatHold | Association | A 1 - B 0..* | - | Mỗi lần giữ ghế thuộc đúng một suất chiếu (GL-25, BR-53); cùng R-UC005-10; link F7: CM2-L5, CM3-L6 |
| R-UC014-11 | AC-E-Ticket | AC-E-Showtime | Association | A 0..* - B 1 | - | Vé thuộc đúng một ghế của một suất chiếu (GL-59, BR-53); cùng R-UC005-19; link F7: CM2-L6, CM3-L7 |

## 9. Ma trận truy vết

| Bước UC | Message (STT) | Lớp tham gia (AC) |
|---|---|---|
| 1 | 1, 1.1 | AC-B-ScheduleShowtimesForm, AC-C-ScheduleShowtimesController |
| 2 | 1.1.1, 1.1.1 (trả về), 1.1.2, 1.1.2 (trả về), 1.1.3, 1.1.3 (trả về), 1.1.4 | AC-C-ScheduleShowtimesController, AC-E-CinemaManager, AC-E-Auditorium, AC-E-Movie, AC-B-ScheduleShowtimesForm |
| 3 | 2, 2.1 | AC-B-ScheduleShowtimesForm, AC-C-ScheduleShowtimesController |
| 4 | 2.1.1, 2.1.1 (trả về), 2.1.2, 2.1.2 (trả về) | AC-C-ScheduleShowtimesController, AC-E-CinemaManager, AC-E-Auditorium |
| 5 | 2.1.4, 2.1.4 (trả về), 2.1.5, 2.1.5 (trả về), 2.1.6, 2.1.6 (trả về), 2.1.7, 2.1.7 (trả về) | AC-C-ScheduleShowtimesController, AC-E-Movie, AC-E-Auditorium, AC-E-PriceList |
| 6 | 2.1.11, 2.1.11 (trả về), 2.1.12, 2.1.12.1, 2.1.12.1.1, 2.1.12.1.2, 2.1.12 (trả về) | AC-C-ScheduleShowtimesController, AC-E-Movie, AC-E-Auditorium, AC-E-Showtime |
| 7 | 2.1.16, 2.1.16.1, 2.1.16.1 (trả về), 2.1.16 (trả về) | AC-C-ScheduleShowtimesController, AC-E-Showtime, AC-E-Movie |
| 8 | 2.1.17, 2.1.17.1, 2.1.17.1 (trả về), 2.1.17.2, 2.1.17.3, 2.1.17 (trả về), 2.1.17[1a], 2.1.17[1a].1, 2.1.17[1a].2, 2.1.17[1a].3, 2.1.17[1a].3.1, 2.1.17[1a].3.2, 2.1.17[1a].4, 2.1.17[1a].5, 2.1.17[1a].6, 2.1.17[1a].7, 2.1.17[1a] (trả về) | AC-C-ScheduleShowtimesController, AC-E-Auditorium, AC-E-PriceList, AC-E-Showtime, AC-E-SeatHold, AC-E-Ticket |
| 9 | 2.1.20, 2.1.20 (trả về), 2.1.21, 2.1.20[1a], 2.1.20[1a] (trả về), 2.1.21[1a] | AC-C-ScheduleShowtimesController, AC-E-Showtime, AC-B-ScheduleShowtimesForm |
| 1a | 1a, 1a.1 | AC-B-ScheduleShowtimesForm, AC-C-ScheduleShowtimesController |
| 1a1 | 1a.1.1, 1a.1.1 (trả về), 1a.1.2, 1a.1.2 (trả về), 1a.1.3 | AC-C-ScheduleShowtimesController, AC-E-CinemaManager, AC-E-Showtime, AC-B-ScheduleShowtimesForm |
| 1a2 | 1a.2 | AC-B-ScheduleShowtimesForm |
| 1a3 | 1a.2.1, 1a.2.1.1, 1a.2.1.1 (trả về), 1a.2.1.3, 1a.2.1.3.1, 1a.2.1.3.2, 1a.2.1.3 (trả về) | AC-B-ScheduleShowtimesForm, AC-C-ScheduleShowtimesController, AC-E-Showtime, AC-E-SeatHold, AC-E-Ticket |
| 1a3a | 1a.2.1.4 | AC-C-ScheduleShowtimesController, AC-B-ScheduleShowtimesForm |
| 1a3b | 1a.2.1.2 | AC-C-ScheduleShowtimesController, AC-B-ScheduleShowtimesForm |
| 1a4 | 1a.2.1.5, 1a.2.1.5 (trả về), 1a.2.1.6, 1a.2.1.6 (trả về), 1a.2.1.7, 1a.2.1.7 (trả về), 1a.2.1.8 | AC-C-ScheduleShowtimesController, AC-E-Showtime, AC-E-Auditorium, AC-E-Movie, AC-B-ScheduleShowtimesForm |
| 1b | 1b, 1b.1 | AC-B-ScheduleShowtimesForm, AC-C-ScheduleShowtimesController |
| 1b1 | 1b.1.1, 1b.1.1 (trả về), 1b.1.2, 1b.1.2 (trả về), 1b.1.3 | AC-C-ScheduleShowtimesController, AC-E-CinemaManager, AC-E-Showtime, AC-B-ScheduleShowtimesForm |
| 1b2 | 1b.2 | AC-B-ScheduleShowtimesForm |
| 1b3 | 1b.2.1, 1b.2.1.1, 1b.2.1.1.1, 1b.2.1.1.2, 1b.2.1.1.3, 1b.2.1.1.3.1, 1b.2.1.1.3.2, 1b.2.1.1.4, 1b.2.1.1 (trả về) | AC-B-ScheduleShowtimesForm, AC-C-ScheduleShowtimesController, AC-E-Showtime, AC-E-SeatHold, AC-E-Ticket |
| 1b3a | 1b.2.1.4 | AC-C-ScheduleShowtimesController, AC-B-ScheduleShowtimesForm |
| 1b3b | 1b.2.1.3 | AC-C-ScheduleShowtimesController, AC-B-ScheduleShowtimesForm |
| 1b3c | 1b.2.1.2 | AC-C-ScheduleShowtimesController, AC-B-ScheduleShowtimesForm |
| 1b4 | 1b.2.1.5 | AC-C-ScheduleShowtimesController, AC-B-ScheduleShowtimesForm |
| 4a | 2.1.3 | AC-C-ScheduleShowtimesController, AC-B-ScheduleShowtimesForm |
| 5a | 2.1.8 | AC-C-ScheduleShowtimesController, AC-B-ScheduleShowtimesForm |
| 5b | 2.1.9 | AC-C-ScheduleShowtimesController, AC-B-ScheduleShowtimesForm |
| 5c | 2.1.10 | AC-C-ScheduleShowtimesController, AC-B-ScheduleShowtimesForm |
| 6a | 2.1.13 | AC-C-ScheduleShowtimesController, AC-B-ScheduleShowtimesForm |
| 6b | 2.1.14 | AC-C-ScheduleShowtimesController, AC-B-ScheduleShowtimesForm |
| 6c | 2.1.15 | AC-C-ScheduleShowtimesController, AC-B-ScheduleShowtimesForm |
| 8a | 2.1.18[8a] | AC-C-ScheduleShowtimesController, AC-B-ScheduleShowtimesForm |
| 8b | 2.1.19, 2.1.19[8b] | AC-C-ScheduleShowtimesController, AC-B-ScheduleShowtimesForm |
| 8c | 2.1.18[8c] | AC-C-ScheduleShowtimesController, AC-B-ScheduleShowtimesForm |
| 8d | 2.1.18[8d] | AC-C-ScheduleShowtimesController, AC-B-ScheduleShowtimesForm |
| 8e | 2.1.18, 2.1.19[8e] | AC-C-ScheduleShowtimesController, AC-B-ScheduleShowtimesForm |
| 8f | 2.1.17[1a].4, 2.1.18[8f] | AC-C-ScheduleShowtimesController, AC-B-ScheduleShowtimesForm, AC-E-Auditorium, AC-E-Showtime |
| *a | 1*a, 1*a.1, 1*a.1.1, 1*a.1.2 | AC-B-ScheduleShowtimesForm, AC-C-ScheduleShowtimesController |

## 10. File .drawio

Ba file nằm trong diagrams/: P07-sequence-UC-014.drawio (14 trang), P07-communication-UC-014.drawio (3 trang), P07-class-UC-014.drawio (1 trang). XML không nén, ID cell trùng ID trong bảng mô hình.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Trạng thái |
| --- | --- | --- | --- | --- |
| Q-101 | Thao tác không chia cắt ở bước 8 và luồng 1b3 phải loại trừ với ba bên: giữ ghế của UC-005 (khoá theo suất chiếu, BR-54), lập hoặc sửa suất chiếu khác cùng phòng chiếu (khoá theo phòng chiếu, BR-52) và bỏ mục giá của UC-013 (khoá theo bảng giá, BR-68). Phân tích đặt // saveShowtime ở Auditorium (bao trùm phòng chiếu đích, suất chiếu đang sửa, bảng giá) và // removeFromSchedule ở Showtime, còn // holdSeats của UC-005 ở Showtime. Có chấp nhận phạm vi này, tức là // saveShowtime phải loại trừ với // holdSeats trên cùng suất chiếu đang sửa và với việc bỏ mục giá trên cùng bảng giá, hay đơn vị loại trừ khác? (Giữ như phân tích, P09 chọn cơ chế / Gom thao tác về một đối tượng duy nhất) | AC-E-Auditorium, AC-E-Showtime, AC-E-PriceList; // saveShowtime, // removeFromSchedule, // checkNoActiveHoldOrSoldTicket; SD1d, SD3a, SD4b; P07 UC-005 (// holdSeats), P07 UC-013; P09 | P04 Mục 8 chỉ nêu "cơ chế bảo đảm thuộc bước thiết kế"; BR-52 nói theo phòng chiếu, BR-54 theo suất chiếu, BR-68 theo bảng giá | Đã trả lời: chấp nhận phạm vi thao tác không chia cắt của saveShowtime và removeFromSchedule; P09 chọn cơ chế, đơn vị loại trừ và thứ tự khoá đề xuất nằm trong bảng cuối mục 4 của UC-005 (theo đề xuất của review). |
| Q-102 | Ở bước 6 và 7 suất chiếu mới chưa tồn tại nhưng giờ bắt đầu, thời điểm mở bán, giờ kết thúc cần được kiểm và tính. Phân tích tạo "suất chiếu dự kiến" (Showtime chưa vào lịch phòng) do Auditorium tạo (// draftShowtime) rồi ghi vào lịch ở bước 8 (// addToSchedule); khi sửa, suất chiếu dự kiến mang thông tin mới và // applyChanges chép vào suất chiếu đang sửa. Có chấp nhận khái niệm suất chiếu dự kiến, hay kiểm giờ bằng trách nhiệm không cần đối tượng (control hoặc Auditorium)? (Chấp nhận suất chiếu dự kiến / Kiểm bằng Auditorium) | AC-E-Auditorium (// draftShowtime), AC-E-Showtime (// createShowtime, // checkStartAfter, // checkSaleOpenBeforeStart, // calculateEndTime, // applyChanges); SD1c; F4 | P04 bước 6, 7 nêu kiểm tra và tính nhưng không nêu đối tượng giữ dữ liệu nhập trước khi lưu | Đã trả lời: chấp nhận khái niệm suất chiếu dự kiến (chưa vào lịch phòng), vì bước 6, 7 cần kiểm và tính trước khi lưu (theo đề xuất của review). |
| Q-103 | BR-69 cần loại ghế có ít nhất một ghế của phòng chiếu. Phân tích rút gọn thành thuộc tính seatTypes của Auditorium (không tạo entity Seat, như Q-81 của UC-005 cho SeatStatus). Có tách entity Seat và đường Auditorium - Seat ngay ở UC-014 không? (Giữ như phân tích, P08 hợp nhất khi có P07 của UC-012 / Tách ngay) | AC-E-Auditorium (seatTypes, // provideSeatTypes); R-UC014-07; P08 | GL-07 (Ghế) và GL-46 chưa có P07 của UC-012; P04 UC-014 không nêu cấu trúc ghế của phòng | Gộp vào Q-81 (UC-005). Đã trả lời: giữ rút gọn, P08 tách Seat cùng Auditorium, Cinema. |
| Q-104 | Khung giờ chiếu (BR-12) ở UC-005 do Showtime xác định (// determineTimeBand). Ở UC-014 bước 5 suất chiếu chưa tồn tại nên PriceList tự xác định từ giờ bắt đầu bên trong // checkCoversShowtime. Giữ hai nơi hay hợp nhất một trách nhiệm xác định khung giờ? (Giữ, PriceList tự xác định / Chuyển // determineTimeBand sang PriceList và UC-005 hỏi PriceList / Showtime xác định cả hai chỗ qua suất chiếu dự kiến) | AC-E-PriceList (// checkCoversShowtime, // determineTimeBand); P08 | BR-12 chỉ nêu "khung giờ xác định theo giờ bắt đầu của suất chiếu", không nêu đối tượng thực hiện | Đã trả lời: hợp nhất một nơi ở PriceList (// determineTimeBand); UC-005 và UC-013 hỏi PriceList, Showtime không còn xác định khung giờ (theo đề xuất của review). |
| Q-105 | Dữ liệu vào 2 và BR-46 yêu cầu suất chiếu được chọn ở bước 1a2, 1b2 thuộc phòng chiếu của cụm rạp, nhưng P04 không có luồng khi suất chiếu chọn không thuộc cụm rạp (ví dụ danh sách đã cũ hoặc gửi trực tiếp). Hệ thống xử lý thế nào? (Từ chối và thông báo BR-46 như luồng 4a, kết thúc thất bại / Coi là không thể xảy ra vì danh sách chỉ chứa suất chiếu của cụm rạp) | Luồng 1a2, 1a3, 1b2, 1b3; AC-E-Showtime (cần // checkBelongsToCinema như UC-005), AC-C-ScheduleShowtimesController | P04 Mục 3 không có luồng cho BR-46 tại 1a2, 1b2 | Gộp vào Q-95 (UC-009). Đã trả lời: thông báo từ chối theo BR-46 như luồng 4a, kết thúc thất bại; luồng ghi ở Đề xuất sửa artifact trước. |

## Giả định

Không có (chế độ NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P04 | UC-014 luồng 1a2, 1b2, Dữ liệu vào 2 | Điều kiện hợp lệ nêu BR-46 cho suất chiếu được chọn nhưng không có luồng khi vi phạm (Q-105) | Bổ sung luồng 1a3c, 1b3d khi có trả lời Q-105, hoặc ghi rõ ở Mục 3 là không thể xảy ra |

## Vấn đề còn mở

- AC-E-CinemaManager chỉ có trách nhiệm // provideCinema: đặc tả UC-014 không có hành vi nào khác trên hồ sơ quản lý cụm rạp (dữ liệu thuộc UC-017). Giữ lại để control không giữ dữ liệu cụm rạp và quy tắc F6 áp dụng thống nhất; P08 xem xét lớp cha nhân viên cùng BoxOfficeClerk và TicketChecker (Q-86, Q-100).
- Thao tác không chia cắt ở bước 8 bao trùm Auditorium, Showtime, PriceList và loại trừ với // holdSeats (UC-005) và việc bỏ mục giá (UC-013). Phân tích chỉ chỉ ra phạm vi (Q-101); đơn vị loại trừ và thứ tự khoá đề xuất nằm trong bảng cuối mục 4 của UC-005, cơ chế chọn ở P09.
- // checkNoActiveHoldOrSoldTicket hỏi từng lần giữ ghế qua SeatHold // checkHoldStillActive (trách nhiệm "còn hiệu lực" dùng chung với UC-005, UC-006) và từng vé qua Ticket // checkNotCancelled, nên quy tắc "ghế quá hạn không còn chặn" (BR-53) nằm ở SeatHold. SD2a, SD3a, SD4b tách trang SD2c, SD3c, SD4c để mỗi trang không quá 3 fragment ở mức ngoài cùng.
- Ghế quá thời điểm hết hạn giữ ghế không còn chặn sửa hoặc xoá (BR-53) nhưng việc giải phóng chúng (tối đa 1 phút sau thời điểm hết hạn, REQ-76) do control UC-005 nhận sự kiện hết hạn và phải hoàn tất kể cả khi suất chiếu đã sửa hoặc ở trạng thái Đã xoá. UC-014 không giải phóng ghế; sự kiện hết hạn của UC-005 và xử lý báo thanh toán (UC-005, UC-006) vẫn tra được suất chiếu đã sửa hoặc Đã xoá (BR-58). Việc xoá suất chiếu cũng không làm UC-008, UC-006 mất dữ liệu suất chiếu.
- Việc liệt kê phòng chiếu, phim, suất chiếu (SD1a, SD2a, SD2b, SD4a) vẽ loop vì không có đối tượng toàn thể nắm tập (Cụm rạp rút gọn, Q-81); nếu P08 tách entity Cinema thì chuyển trách nhiệm liệt kê cho Cinema.
- Auditorium gọi PriceList (R-UC014-08) dựa trên Cụm rạp rút gọn (Q-81); nếu tách Cinema thì đường Auditorium - Cinema - PriceList thay quan hệ trực tiếp.
- Showtime có 12 trách nhiệm trong UC-014 cộng trách nhiệm UC-005, nên P08 cần theo dõi độ lớn lớp (khoảng 23 sau gộp); các thuộc tính movie, auditorium, status trùng nghĩa với movieName, movieTitle, auditoriumName, scheduleStatus của UC-006, UC-009, UC-013 và P08 gộp. // provideShowtimeInfo khác // provideShowtimeForChecking của UC-009 ở nội dung. Không có trách nhiệm nào nắm quy tắc tính toán thuộc dữ liệu của entity khác.
- Mới: các lớp do UC-014 tạo ghi "Mới - chạy song song, chờ P08 hợp nhất" (ScheduleShowtimesForm, ScheduleShowtimesController, CinemaManager, Auditorium, Movie).
- Luồng 8f: P08 EX-13 và P12 (lượt PKG-27, Vấn đề còn mở 9) mô tả kiểm "chưa từng có vé" nhưng chưa đặt tên thao tác riêng; P12 đặt kiểm trong // applyChanges dưới khoá Ticket S hạng 8. P07 tách thành // checkRoomChangeAllowed của Showtime để thấy rõ thứ tự kiểm 8c, 8d, 8a, 8f, 8e, 8b của P04; khi thiết kế PKG-27 có thể gộp vào // applyChanges mà không đổi thứ tự kiểm hay thông điệp.
