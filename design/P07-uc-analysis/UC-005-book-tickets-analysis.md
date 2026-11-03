# P07 - Phân tích use case UC-005 Đặt vé - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P07 |
| Phiên bản | 1.1 |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md; P04-uc-specs/UC-005-book-tickets.md 1.8; P01-actors.md 1.1; P02-usecases.md 1.8; P03-usecase-model.md 1.0; P05-glossary.md 1.1; P06-supplementary-spec.md 1.1; P04-uc-specs/_BR-register.md; P07-uc-analysis/_review-P07-batch.md; chưa có file P07 nào khác khi lập bản 1.0 (sổ đăng ký AC rỗng) |
| Phạm vi | UC-005 |
| Mã Q, ASM cuối đã cấp | Q-86; không có ASM (NGHIEM_NGAT) |

## 1. Bối cảnh use case

| Thuộc tính | Giá trị |
|---|---|
| Mã và tên UC | UC-005 Đặt vé (Book Tickets) |
| Tác nhân chính | ACT-01 Khách (Người); ACT-02 Nhân viên quầy (Người) |
| Tác nhân phụ | ACT-07 Cổng thanh toán (Hệ thống ngoài; nhận yêu cầu tạo giao dịch ở bước 10 và tự báo kết quả giao dịch ở bước 11); ACT-08 Dịch vụ email (Hệ thống ngoài; chỉ nhận email chứa vé) |
| Include (UC) | Không có |
| Được include bởi (UC) | Không có |
| Extend (UC, điểm mở rộng, điều kiện) | Không có |
| Được extend bởi (UC, điểm mở rộng, điều kiện) | Không có |
| Use case liên quan không qua include, extend | UC-006 Hoàn tiền thanh toán trễ: cùng nhận kết quả giao dịch của cổng qua control tiếp nhận dùng chung PaymentReportController (AC-C-PaymentReportController, UC-005 cấp mã và làm chủ), báo thành công đến sau thời điểm hết hạn hoặc sau trạng thái cuối của lần giữ ghế thuộc UC-006 (BR-14, BR-15, BR-37, BR-86; Q-83); UC-008 Huỷ vé đưa ghế về trống; UC-013 và UC-014 loại trừ với bước 7 (BR-54, BR-71) |
| Tác nhân thời gian | Không có. EV-06 (hết 10 phút giữ ghế) là luồng 7b của chính UC-005; P02 không có use case nào do tác nhân thời gian kích hoạt trên đối tượng mà UC-005 tạo, nên không có message hẹn mốc ngoài message chờ hết hạn (A2) |
| File P07 đã có được dùng làm sổ đăng ký AC | Không có (UC-005 là use case đầu tiên của P07; mọi mã AC dưới đây là mã cấp mới) |

## 2. Đặc tả bổ sung

| Bước UC | Thực hiện bởi | Mô tả trong đặc tả | Mô tả bổ sung (hệ thống làm gì bên trong) | Nguồn (BR, GL, REQ) |
|---|---|---|---|---|
| 1 | Khách / Nhân viên quầy | Chọn một suất chiếu cần mua vé. | Không đổi | REQ-13, REQ-45 |
| 2 | Hệ thống | Kiểm tra suất chiếu đã tới thời điểm mở bán và chưa tới giờ bắt đầu và, khi tác nhân là nhân viên quầy, suất chiếu thuộc cụm rạp của nhân viên quầy. | Suất chiếu đối chiếu thời điểm hiện tại với thời điểm mở bán và giờ bắt đầu của chính nó. Khi tác nhân là nhân viên quầy, suất chiếu còn đối chiếu cụm rạp của mình với cụm rạp của nhân viên quầy. | BR-01, BR-02, BR-45, GL-14, GL-53 |
| 3 | Hệ thống | Hiển thị sơ đồ ghế của suất chiếu và cập nhật trạng thái ghế khi người khác giữ hoặc mua ghế. | Suất chiếu lấy từ từng trạng thái ghế của mình vị trí ghế, loại ghế và trạng thái ghế (trống, đang được giữ, đã bán) rồi control chuyển cho boundary hiển thị. Mỗi lần trạng thái ghế của suất chiếu đổi, control báo các màn hình khác đang xem sơ đồ ghế của suất chiếu đó để cập nhật. | GL-46, GL-58, REQ-19, REQ-119 |
| 4 | Khách / Nhân viên quầy | Chọn các ghế muốn mua và xác nhận chọn ghế; ghế đang chọn vẫn ở trạng thái trống cho tới khi xác nhận. | Không đổi | BR-03, GL-08 |
| 5 | Hệ thống | Kiểm tra khách đã đăng nhập và tác nhân không có lần giữ ghế nào chưa kết thúc. | Control xác định khách của phiên đã đăng nhập chưa. Khách hoặc nhân viên quầy tự kiểm tra mình không có lần giữ ghế nào ở trạng thái Đang giữ; kiểm tra có hiệu lực nằm trong thao tác không chia cắt ở bước 7. | BR-04, GL-25 |
| 6 | Hệ thống | Kiểm tra số ghế đã chọn không vượt quá số ghế tối đa của một lần giữ ghế. | Suất chiếu kiểm tra các ghế chọn thuộc sơ đồ ghế của mình, có ít nhất một ghế và số ghế không vượt tối đa, ghế đôi tính là một ghế. | BR-05, BR-06, BR-74 |
| 7 | Hệ thống | Kiểm tra suất chiếu còn tồn tại và chưa bị sửa, tác nhân không có lần giữ ghế nào chưa kết thúc và mọi ghế đã chọn còn trống, xác định giá vé từng ghế theo bảng giá của cụm rạp, rồi giữ tạm cả nhóm ghế cùng giá đã xác định, tất cả là một thao tác không chia cắt. | Suất chiếu thực hiện một thao tác không chia cắt gồm: tạo lần giữ ghế và kiểm người giữ ghế không có lần giữ ghế chưa kết thúc, kiểm suất chiếu chưa bị sửa hoặc xoá kể từ lúc hiển thị sơ đồ ghế, chuyển từng ghế đã chọn sang đang được giữ khi ghế còn trống. Cũng trong thao tác đó, giá từng ghế do bảng giá của cụm rạp xác định theo loại phòng, định dạng phim, loại ghế và khung giờ chiếu (bảng giá tự xác định khung giờ từ giờ bắt đầu, BR-12) rồi được ghi vào trạng thái ghế; một điều kiện không đạt thì không ghế nào được giữ và không lần giữ ghế nào được ghi nhận. Thành công thì lần giữ ghế có thời điểm hết hạn bằng thời điểm giữ cộng 10 phút và control bắt đầu chờ thời điểm đó. | BR-04, BR-07, BR-08, BR-09, BR-10, BR-11, BR-12, BR-54, BR-65, BR-66, BR-71, BR-85, GL-52, GL-54 |
| 8 | Hệ thống | Hiển thị các ghế đã giữ, giá vé từng ghế đã xác định ở bước 7 và tổng tiền. | Lần giữ ghế lấy từ từng ghế đang giữ vị trí, loại ghế và giá đã chốt, và tính tổng tiền bằng tổng giá đã chốt (không tính lại giá). Control chuyển kết quả cho boundary hiển thị. Hết hạn giữ ghế có thể xảy ra tại mọi bước từ 8 đến 11 (luồng 7b). | BR-65, BR-10, GL-57, REQ-30 |
| 9 | Khách | Yêu cầu thanh toán trực tuyến. | Không đổi | REQ-28 |
| 10 | Hệ thống | Tạo giao dịch thanh toán cho tổng tiền đã hiển thị ở bước 8 qua cổng thanh toán, truyền kèm mã tham chiếu của lần giữ ghế và ghi nhận số tiền của giao dịch. | Control đưa tổng tiền và mã tham chiếu lần giữ ghế cho cổng thanh toán qua boundary của cổng, cổng trả mã giao dịch. Lần giữ ghế tạo giao dịch thanh toán thuộc mình, ghi mã giao dịch và số tiền (Q-85). | REQ-111, REQ-136, GL-12, GL-31, NFR-15 |
| 11 | Cổng thanh toán | Báo giao dịch thanh toán thành công. | Không đổi | REQ-29, NFR-16 |
| 12 | Hệ thống | Chuyển các ghế đang giữ sang trạng thái đã bán, lưu mã giao dịch do cổng thanh toán cấp và đánh dấu giao dịch đã xử lý. | Control tiếp nhận báo dùng chung (PaymentReportController) tìm lần giữ ghế theo mã giao dịch hoặc mã tham chiếu rồi giao cho lần giữ ghế một thao tác không chia cắt (settlePaymentReport) trả về một trong bốn kết quả: bán ghế, thanh toán trễ chờ hoàn, báo trùng, thất bại ghi nhận. Bán ghế khi giao dịch chưa xử lý và lần giữ ghế còn Đang giữ, chưa quá thời điểm hết hạn: đánh dấu giao dịch đã xử lý, chuyển từng ghế sang đã bán, chuyển lần giữ ghế sang Đã hoàn tất và tạo lần đặt cùng vé (bước 13) trong cùng thao tác. Lần giữ ghế Đang giữ mà đã quá hạn được chuyển sang Hết hạn trước; ba kết quả còn lại không bán ghế và được UC-006 xử lý tiếp. | BR-14, BR-15, BR-37, BR-85, BR-86, GL-17, GL-23, GL-51 |
| 13 | Hệ thống | Tạo một mã đặt vé cho lần đặt và cho mỗi ghế một vé có mã QR riêng. | Lần giữ ghế đã hoàn tất tạo lần đặt trong cùng thao tác của bước 12 (Q-84): lần đặt sinh mã đặt vé duy nhất toàn hệ thống và tạo cho mỗi ghế đã bán một vé ghi giá đã chốt và mã QR riêng. Thao tác không hoàn tất thì không có gì được ghi và giao dịch được xử lý như thanh toán trễ, hoàn toàn bộ (UC-006). | BR-67, BR-80, BR-85, GL-24, GL-28, GL-30, GL-59, REQ-105 |
| 14 | Hệ thống | Gửi các vé cho khách qua dịch vụ email. | Control tiếp nhận báo đưa các vé và địa chỉ email của khách cho dịch vụ email qua boundary dịch vụ email và không chờ kết quả. | BR-89, REQ-157, NFR-18 |
| 15 | Hệ thống | Thông báo đặt vé thành công và hiển thị mã đặt vé cùng các vé. | Lần đặt cung cấp mã đặt vé và nội dung từng vé của mình, control chuyển cho boundary hiển thị. | Dữ liệu ra 3, REQ-105 |
| 2a | Hệ thống | Từ chối bán vé và thông báo suất chiếu chưa mở bán. | Suất chiếu cho biết chưa tới thời điểm mở bán, control chuyển lý do cho boundary thông báo; không tạo gì. | BR-01 |
| 2b | Hệ thống | Từ chối bán vé và thông báo quy tắc bị vi phạm (suất chiếu khác cụm rạp). | Suất chiếu cho biết không thuộc cụm rạp của nhân viên quầy, control chuyển lý do cho boundary thông báo; không tạo gì. | BR-02 |
| 2c | Hệ thống | Từ chối bán vé và thông báo suất chiếu đã bắt đầu. | Suất chiếu cho biết đã tới giờ bắt đầu, control chuyển lý do cho boundary thông báo; không tạo gì. | BR-45 |
| 5a1 | Hệ thống | Yêu cầu khách đăng nhập, giữ nguyên các ghế khách đã chọn. | Control yêu cầu boundary hiển thị yêu cầu đăng nhập; các ghế đã chọn chưa phải lần giữ ghế nên vẫn ở trạng thái trống. | BR-03 |
| 5a2 | Khách | Cung cấp email hoặc số điện thoại cùng mật khẩu. | Không đổi | Dữ liệu vào 2, NFR-01, Q-82 |
| 5b | Hệ thống | Từ chối giữ ghế và thông báo quy tắc bị vi phạm (đang có lần giữ ghế chưa kết thúc). | Khách hoặc nhân viên quầy cho biết đang có lần giữ ghế ở trạng thái Đang giữ, control chuyển lý do cho boundary thông báo. | BR-04 |
| 6a | Hệ thống | Từ chối giữ ghế và thông báo số ghế tối đa. | Suất chiếu cho biết số ghế chọn vượt tối đa, control chuyển lý do cho boundary thông báo; tác nhân chọn lại ở bước 4. | BR-05, BR-06 |
| 7a | Hệ thống | Thông báo các ghế không còn trống và không giữ ghế nào. | Thao tác ở bước 7 gặp ghế không còn trống (đã bị giữ hoặc bán trước, kể cả người khác xác nhận cùng ghế ngay trước đó) nên không ghế nào được giữ; control chuyển danh sách ghế không còn trống cho boundary. | BR-07, BR-09 |
| 7b | Hệ thống | Tới thời điểm hết hạn giữ ghế mà chưa có thanh toán thành công (hoặc nhân viên quầy chưa xác nhận đã thu tiền): giải phóng các ghế đang giữ về trống và thông báo hết thời gian giữ ghế. | Control nhận sự kiện hết hạn; lần giữ ghế kiểm còn Đang giữ rồi chuyển sang Hết hạn ngay tại thời điểm hết hạn, hoặc giữ nguyên nếu đã Hết hạn từ trước do báo thanh toán đến muộn. Lần giữ ghế ở trạng thái Hết hạn thì giải phóng từng ghế còn đang giữ về trống chậm nhất 1 phút sau (REQ-76), việc giải phóng chạy lại được an toàn. Control báo các màn hình đang xem sơ đồ ghế cập nhật và boundary thông báo hết thời gian giữ ghế. | BR-10, BR-85, BR-86, GL-25, REQ-76, REQ-119, NFR-07 |
| 7c | Hệ thống | Từ chối giữ ghế và thông báo quy tắc bị vi phạm (đang có lần giữ ghế chưa kết thúc, kiểm trước 7a). | Người giữ ghế cho biết đang có lần giữ ghế ở trạng thái Đang giữ khi lần giữ ghế mới được tạo; toàn bộ thao tác không để lại thay đổi nào. | BR-04 |
| 7d | Hệ thống | Từ chối giữ ghế, không giữ ghế nào, thông báo suất chiếu đã thay đổi hoặc không còn. | Suất chiếu cho biết đã bị sửa hoặc xoá kể từ lúc hiển thị sơ đồ ghế; toàn bộ thao tác không để lại thay đổi nào. | BR-54 |
| 7e | Hệ thống | Từ chối giữ ghế, không giữ ghế nào, thông báo không xác định được giá vé. | Bảng giá cho biết không có giá cho ít nhất một ghế đã chọn; toàn bộ thao tác không để lại thay đổi nào. | BR-72, BR-11, BR-12 |
| 9a1 | Nhân viên quầy | Thu tiền mặt của khách mua tại quầy và xác nhận đã thu tiền. | Không đổi | BR-13, REQ-47, REQ-48 |
| 9a1a | Hệ thống | Xác nhận đã thu tiền tới sau thời điểm hết hạn giữ ghế: từ chối xác nhận, không chuyển ghế sang đã bán, thông báo nhân viên quầy trả lại tiền mặt; ghế giải phóng theo luồng 7b. | Lần giữ ghế so thời điểm xác nhận với thời điểm hết hạn trong cùng thao tác với việc bán ghế; quá hạn thì chuyển sang Hết hạn (nếu chưa) và trả kết quả quá hạn. Control chuyển yêu cầu trả lại tiền mặt cho boundary; việc giải phóng ghế do luồng 7b. | BR-10, BR-44, BR-85, BR-86 |
| 9a2 | Hệ thống | Chuyển các ghế đang giữ sang trạng thái đã bán (khi xác nhận tới trước thời điểm hết hạn). | Lần giữ ghế chuyển từng ghế đang giữ sang đã bán, chuyển sang Đã hoàn tất rồi tạo lần đặt cùng vé (9a3), tất cả cùng thao tác với việc so thời điểm xác nhận. | BR-44, BR-85 |
| 9a3 | Hệ thống | Tạo một mã đặt vé cho lần đặt và cho mỗi ghế một vé có mã QR riêng. | Như bước 13, trong cùng thao tác với 9a2. | BR-80, BR-67, GL-24, GL-59 |
| 9a4 | Hệ thống | Hiển thị mã đặt vé và các vé để in. | Lần đặt cung cấp mã đặt vé và nội dung từng vé, control chuyển cho boundary của nhân viên quầy. | Dữ liệu ra 3 |
| 9a5 | Nhân viên quầy | In vé cho khách mua tại quầy. | Không đổi | REQ-49 |
| 10a | Hệ thống | Cổng thanh toán từ chối hoặc không trả lời trong 30 giây: giữ nguyên lần giữ ghế, thông báo chưa tạo được thanh toán, quay lại bước 9. | Control chuyển thông báo chưa tạo được thanh toán cho boundary; lần giữ ghế và thời điểm hết hạn không đổi. | BR-90, REQ-158 |
| 11a | Hệ thống | Cổng báo giao dịch thất bại: giải phóng các ghế đang giữ về trống và thông báo thanh toán không thành công. | Cùng thao tác xử lý báo của bước 12 (settlePaymentReport): lần giữ ghế còn Đang giữ ghi nhận kết quả thất bại vào giao dịch và chuyển sang Thanh toán thất bại, rồi control giải phóng từng ghế về trống. Control báo các màn hình đang xem sơ đồ ghế cập nhật và boundary thông báo thanh toán không thành công. Lần giữ ghế đã kết thúc thì kết quả thất bại chỉ được ghi nhận (UC-006). | BR-85, BR-86, BR-15, GL-25 |
| *a | Hệ thống | Khách hoặc nhân viên quầy huỷ việc giữ ghế (từ bước 8 đến trước bước 11): giải phóng các ghế đang giữ về trống. | Lần giữ ghế kiểm còn Đang giữ, chuyển sang Đã huỷ rồi giải phóng từng ghế về trống. Control báo các màn hình đang xem sơ đồ ghế cập nhật; giao dịch thành công báo sau đó do UC-006 xử lý. | BR-15, BR-85, BR-86, GL-25 |

## 3. Tìm lớp phân tích

### 3.1 Bảng boundary

| Tác nhân (ACT) | Loại tác nhân | Boundary | Loại boundary | Mới hoặc tái dùng (AC, UC nguồn) | Lý do |
|---|---|---|---|---|---|
| ACT-01 Khách | Người | BookTicketsForm | Giao diện người dùng | Mới (AC-B-BookTicketsForm) | Khách chọn suất chiếu và ghế, đăng nhập, yêu cầu thanh toán, huỷ giữ ghế, nhận kết quả. Các khách khác đang xem cùng sơ đồ ghế (P01 gộp vào ACT-01) dùng cùng boundary này. |
| ACT-02 Nhân viên quầy | Người | CounterBookTicketsForm | Giao diện người dùng | Mới (AC-B-CounterBookTicketsForm) | Nhân viên quầy dùng chung luồng với khách (P02 U-R10 b) nhưng khác ở nhiều bước: không đăng nhập, kiểm tra cụm rạp, thu tiền mặt, in vé. Một boundary cho mỗi cặp tác nhân và use case. |
| ACT-07 Cổng thanh toán | Hệ thống ngoài | PaymentGateway | Giao diện hệ thống | Mới (AC-B-PaymentGateway); UC-006, UC-008 phải dùng lại mã này | Nhận yêu cầu tạo giao dịch và gửi kết quả giao dịch (GL-02). Tên theo hệ thống ngoài, không trùng tên entity nào (entity là PaymentTransaction). |
| ACT-08 Dịch vụ email | Hệ thống ngoài | EmailService | Giao diện hệ thống | Mới (AC-B-EmailService); UC-006 phải dùng lại mã này | Chỉ nhận email chứa vé từ hệ thống. Khách nhận vé qua email nhờ dịch vụ này và vẫn thấy vé trên màn hình ở bước 15 qua BookTicketsForm, nên không có boundary kênh thông báo riêng. |

Số boundary là 4, bằng số tác nhân tham gia trực tiếp (không có tác nhân thời gian). Máy in của máy tính tại quầy không là tác nhân (P01 Mục 1), việc in đi qua CounterBookTicketsForm.

### 3.2 Bảng lọc danh từ

| STT | Danh từ hoặc cụm danh từ | Vị trí (bước UC, mục dữ liệu, BR) | Kết luận | Lý do |
|---|---|---|---|---|
| 1 | suất chiếu | 1, 2, 3, 7; Dữ liệu ra 1; BR-01, BR-45, BR-54 | Entity AC-E-Showtime | Hệ thống lưu; có hành vi kiểm tra mở bán, giờ bắt đầu, chưa bị sửa, giữ ghế (GL-47). |
| 2 | thời điểm mở bán | 2, 2a; BR-01 | Loại - thuộc tính của Showtime | Thành phần của suất chiếu (GL-53). |
| 3 | giờ bắt đầu | 2, 2c; BR-12, BR-45 | Loại - thuộc tính của Showtime | Thành phần của suất chiếu (GL-14). |
| 4 | cụm rạp | 2, 2b; BR-02, BR-11 | Loại - khái niệm do UC-011 tạo, use case này chỉ đọc qua entity Showtime | Chỉ cần để so với cụm rạp của nhân viên quầy và tìm bảng giá; thuộc tính cinema của Showtime và BoxOfficeClerk (Q-81). |
| 5 | phòng chiếu, loại phòng | Dữ liệu ra 3; BR-11 | Loại - khái niệm do UC-012 tạo, use case này chỉ đọc qua entity Showtime | Loại phòng là yếu tố tính giá, đọc qua Showtime (auditoriumType) (Q-81). |
| 6 | phim, định dạng phim | Dữ liệu ra 1, 3; BR-11 | Loại - khái niệm do UC-010 tạo, use case này chỉ đọc qua entity Showtime | Định dạng phim của suất chiếu là yếu tố tính giá; tên phim chỉ hiển thị trên vé. |
| 7 | sơ đồ ghế | 3; Dữ liệu ra 1 | Loại - giá trị suy ra từ Showtime | Là tập trạng thái ghế của suất chiếu, tính khi hiển thị (GL-46). |
| 8 | ghế | 4, 6, 7; Dữ liệu vào 1 | Loại - khái niệm do UC-012 tạo, use case này chỉ đọc qua entity SeatStatus | Vị trí ngồi của phòng (GL-07); UC này chỉ cần vị trí và loại ghế của ghế trong suất chiếu, đọc qua SeatStatus (Q-81). |
| 9 | trạng thái ghế | 3, 7, 12; GL-58 | Entity AC-E-SeatStatus | Tình trạng của ghế trong một suất chiếu, có vòng đời riêng (trống, đang được giữ, đã bán) và được giữ, bán, giải phóng độc lập từng ghế. |
| 10 | vị trí ghế, loại ghế, ghế đôi | Dữ liệu vào 1, Dữ liệu ra 1; BR-06, BR-74 | Loại - thuộc tính của SeatStatus | Ghế đôi là một giá trị của loại ghế (GL-09, GL-26). |
| 11 | ghế đang chọn, các ghế đã chọn | 4; BR-03 | Loại - dữ liệu trao đổi qua boundary BookTicketsForm | Chưa là lần giữ ghế, ghế vẫn trống (GL-08); không lưu. |
| 12 | số ghế tối đa | 6; BR-05 | Loại - tham số của quy tắc BR-05 | Hằng số 8. |
| 13 | khách, người khác | 1, 3, 5 | Loại - là tác nhân hoặc ngoài phạm vi | ACT-01; "người khác" gộp vào ACT-01 (P01 Mục 4). |
| 14 | tài khoản khách | 5, 5a2; Dữ liệu vào 2 | Entity AC-E-Customer | Thông tin về tác nhân, không phải tác nhân: hệ thống lưu email, số điện thoại, mật khẩu, đối chiếu khi đăng nhập và biết các lần giữ ghế của khách (BR-04, GL-18). |
| 15 | email hoặc số điện thoại, mật khẩu | Dữ liệu vào 2 | Loại - thuộc tính của Customer | Không có định danh và hành vi riêng. |
| 16 | nhân viên quầy | 1, 2, 5, 9a | Entity AC-E-BoxOfficeClerk | Thông tin về tác nhân, không phải tác nhân: cụm rạp của nhân viên quầy (BR-02) và các lần giữ ghế của nhân viên quầy (BR-04, GL-35). |
| 17 | phiên làm việc, đăng nhập | Tiền điều kiện, 5 | Loại - cấu trúc cài đặt | Đăng nhập không là use case (hồ sơ dự án Mục 4); trạng thái phiên do control xác định, không là entity. |
| 18 | lần giữ ghế | 5, 7, 8, 12; BR-04, BR-07, BR-85 | Entity AC-E-SeatHold | Có vòng đời riêng (Đang giữ và bốn trạng thái cuối), thời điểm hết hạn, và là đơn vị xử lý tuần tự (GL-25). |
| 19 | lần giữ ghế chưa kết thúc | 5, 7; BR-04 | Loại - trùng hoặc đồng nghĩa với SeatHold | Là SeatHold ở trạng thái Đang giữ (GL-25). |
| 20 | trạng thái cuối, Đang giữ, Đã hoàn tất, Hết hạn, Đã huỷ, Thanh toán thất bại | 7b, 11a, *a; BR-86 | Loại - thuộc tính của SeatHold | Giá trị trạng thái (GL-25). |
| 21 | thời gian giữ ghế, thời điểm hết hạn giữ ghế, 10 phút | 7, 7b; BR-10 | Loại - thuộc tính của SeatHold | Thời điểm hết hạn là thuộc tính; 10 phút là tham số của BR-10 (GL-52, GL-54). |
| 22 | mã tham chiếu lần giữ ghế | 10 | Loại - thuộc tính của SeatHold | Định danh lần giữ ghế gửi cho cổng (GL-31). |
| 23 | bảng giá | 7; BR-11, BR-66 | Entity AC-E-PriceList | Nguồn xác định giá vé, có hành vi tra giá, loại trừ với bước 7 (BR-71) (GL-01). |
| 24 | mục giá | 7; BR-11, BR-72 | Loại - khái niệm do UC-013 tạo, use case này chỉ đọc qua entity PriceList | Dòng của bảng giá; PriceList tra giá, UC này không tạo hay sửa mục giá (GL-33). |
| 25 | giá vé | 7, 8, 13; BR-65, BR-67 | Loại - thuộc tính của SeatStatus | Giá chốt khi giữ ghế gắn với ghế đang giữ (heldPrice); vé đã bán giữ giá đã ghi (price của Ticket). |
| 26 | khung giờ chiếu | 7; BR-11, BR-12 | Loại - giá trị suy ra từ Showtime | Tính từ giờ bắt đầu khi cần (GL-22). |
| 27 | tổng tiền | 8, 10; Dữ liệu ra 2 | Loại - giá trị suy ra từ SeatHold | Tổng giá vé đã chốt của các ghế đang giữ, tính khi cần (GL-57). |
| 28 | giao dịch thanh toán | 10, 11, 12 | Entity AC-E-PaymentTransaction | Hệ thống lưu số tiền, mã giao dịch, đã xử lý hay chưa, kết quả; có hành vi đánh dấu đã xử lý một lần (BR-37) (GL-12). |
| 29 | mã giao dịch, số tiền của giao dịch, kết quả giao dịch | 10, 11, 12; REQ-111 | Loại - thuộc tính của PaymentTransaction | Không có định danh và hành vi riêng (GL-17, GL-29). |
| 30 | cổng thanh toán | 10, 11 | Loại - là tác nhân hoặc ngoài phạm vi | ACT-07; boundary là PaymentGateway. |
| 31 | dịch vụ email, email chứa vé | 14 | Loại - là tác nhân hoặc ngoài phạm vi | ACT-08; boundary là EmailService; nội dung email là dữ liệu trao đổi qua boundary, không lưu. |
| 32 | lần đặt | 13, 15; Dữ liệu ra 3 | Entity AC-E-Booking | Kết quả của lần giữ ghế được mua; tồn tại sau use case, định danh bằng mã đặt vé (GL-24). |
| 33 | mã đặt vé | 13, 15; BR-80 | Loại - thuộc tính của Booking | Định danh lần đặt (GL-28); việc sinh mã duy nhất là trách nhiệm của Booking. |
| 34 | vé | 13, 14, 15; Dữ liệu ra 3 | Entity AC-E-Ticket | Chứng từ cho một ghế, tồn tại sau use case, có trạng thái và mã QR riêng (GL-59). |
| 35 | mã QR, mã vé | 13; Dữ liệu ra 3 | Loại - thuộc tính của Ticket | Mã QR là hình mã hoá của mã vé (GL-30, GL-32). |
| 36 | tiền mặt | 9a1; BR-13 | Loại - tham số của quy tắc BR-13 | Hình thức thu tiền tại quầy, không có hành vi riêng. |
| 37 | xác nhận đã thu tiền, huỷ việc giữ ghế, báo kết quả thanh toán | 9a1, *a, 11 | Loại - thao tác hoặc sự kiện | Là thông điệp từ tác nhân hoặc cổng. |
| 38 | thời điểm nhận báo, thời điểm xác nhận | 12, 9a1a; BR-14, BR-44 | Loại - thao tác hoặc sự kiện | Thời điểm sự kiện, truyền như tham số khi xử lý. |
| 39 | thanh toán đến trễ, hoàn tiền, lần báo trùng, giao dịch thứ hai | Mục 8; BR-14, BR-15, BR-37 | Loại - không tham gia hành vi của use case này (khái niệm của UC-006) | Chỉ được nhắc tới để xác định ranh giới; UC-005 không đọc hay ghi chúng. |
| 40 | máy in, in vé | 9a5 | Loại - là tác nhân hoặc ngoài phạm vi | Máy in của máy tính tại quầy không là tác nhân (P01 Mục 1). |
| 41 | thông báo, thông tin, hệ thống, quy tắc | Nhiều bước | Loại - mơ hồ | Không phải khái niệm nghiệp vụ cụ thể; nội dung thông báo là dữ liệu trao đổi qua boundary. |
| 42 | log lỗi, thử gửi lại | Mục 8; BR-89 | Loại - cấu trúc cài đặt | Cơ chế gửi email thuộc thiết kế (P09), UC này chỉ gửi đi. |
| 43 | mốc hiển thị sơ đồ ghế | 7; BR-54 | Loại - dữ liệu trao đổi qua boundary BookTicketsForm | Thời điểm hiển thị sơ đồ ghế mà tác nhân đã xem, mang theo yêu cầu giữ ghế để Showtime đối chiếu với lastChangedAt. |

### 3.3 Bảng control

| Control | Use case điều phối | Mới hoặc tái dùng | Lý do (hoặc lý do không có control) |
|---|---|---|---|
| BookTicketsController | UC-005 | Mới (AC-C-BookTicketsController) | Control của UC-005 cho phần do tác nhân điều khiển: điều phối bước 1 đến 10, hết hạn giữ ghế (after BR-10), huỷ giữ ghế và xác nhận thu tiền mặt. Báo các màn hình khác cập nhật sơ đồ ghế bằng cách gửi message updateSeatMap tới boundary, không là trách nhiệm nhận riêng. Mọi quy tắc nghiệp vụ nằm ở entity. Có 9 trách nhiệm, trong khoảng 2-10. |
| PaymentReportController | UC-005, UC-006 | Mới (AC-C-PaymentReportController); UC-005 là chủ | Control tiếp nhận dùng chung mọi báo kết quả giao dịch của cổng (bước 11, 11a của UC-005; bước 1 của UC-006), khoá theo lần giữ ghế (BR-85). Tách riêng vì phần điều phối này dùng cho hai use case chưa include nhau (A5), nên control của UC này không gọi control của UC kia (F6). Nhánh bán ghế và thất bại khi lần giữ ghế còn hiệu lực mô tả ở UC-005; nhánh thanh toán trễ, báo trùng, thất bại muộn và hoàn tiền mô tả ở UC-006, cùng một trách nhiệm tiếp nhận handlePaymentReport. UC-006 không có control riêng. |

### 3.4 Bảng lớp phân tích

| AC | Stereotype | Tên | Trách nhiệm | Thuộc tính chính | Bước UC nguồn | Loại boundary | Mới hoặc tái dùng | GL |
|---|---|---|---|---|---|---|---|---|
| AC-B-BookTicketsForm | boundary | BookTicketsForm | // selectShowtime: tác nhân chọn suất chiếu cần mua vé<br>// showSeatMap: hiển thị sơ đồ ghế và trạng thái ghế của suất chiếu<br>// confirmSeatSelection: tác nhân xác nhận chọn các ghế muốn mua<br>// showHeldSeats: hiển thị các ghế đã giữ, giá vé từng ghế, tổng tiền<br>// requestOnlinePayment: khách yêu cầu thanh toán trực tuyến<br>// showBookingSuccess: thông báo đặt vé thành công, hiển thị mã đặt vé và các vé<br>// notifyRefusal: thông báo từ chối hoặc kết thúc thất bại kèm lý do<br>// requestLogin: yêu cầu khách đăng nhập, giữ nguyên các ghế đã chọn<br>// provideCredentials: khách nhập email hoặc số điện thoại và mật khẩu<br>// cancelSeatHold: tác nhân huỷ việc giữ ghế<br>// updateSeatMap: cập nhật sơ đồ ghế đang hiển thị khi trạng thái ghế của suất chiếu đổi (REQ-119) | selectedSeats (Các ghế đã chọn), credentials (Email hoặc số điện thoại, mật khẩu) | 1, 3, 4, 5a, 5b, 6a, 7a, 7b, 7c, 7d, 7e, 8, 9, 10a, 11a, 15, 12, *a | Giao diện người dùng | Mới | GL-18 |
| AC-B-CounterBookTicketsForm | boundary | CounterBookTicketsForm | // selectShowtime: nhân viên quầy chọn suất chiếu cần bán vé<br>// notifyRefusal: thông báo từ chối kèm lý do, kể cả yêu cầu trả lại tiền mặt<br>// showSeatMap: hiển thị sơ đồ ghế và trạng thái ghế của suất chiếu<br>// confirmSeatSelection: nhân viên quầy xác nhận chọn các ghế khách muốn mua<br>// showHeldSeats: hiển thị các ghế đã giữ, giá vé từng ghế, tổng tiền<br>// confirmCashReceived: nhân viên quầy xác nhận đã thu tiền mặt<br>// showTicketsForPrint: hiển thị mã đặt vé và các vé để in<br>// printTickets: nhân viên quầy in vé cho khách mua tại quầy<br>// updateSeatMap: cập nhật sơ đồ ghế đang hiển thị khi trạng thái ghế của suất chiếu đổi (REQ-119) | selectedSeats (Các ghế đã chọn) | 1, 2a, 2b, 2c, 3, 4, 8, 9a1, 9a1a, 9a4, 9a5, 9a2 | Giao diện người dùng | Mới | GL-35 |
| AC-B-PaymentGateway | boundary | PaymentGateway | // createPaymentTransaction: chuyển yêu cầu tạo giao dịch thanh toán tới cổng thanh toán<br>// reportTransactionResult: nhận kết quả giao dịch do cổng thanh toán báo về | - | 10, 11, 11a | Giao diện hệ thống | Mới | GL-02 |
| AC-B-EmailService | boundary | EmailService | // sendTicketsEmail: chuyển email chứa vé tới dịch vụ email | - | 14 | Giao diện hệ thống | Mới | - |
| AC-C-BookTicketsController | control | BookTicketsController | // startBooking: điều phối bước 2 và 3: kiểm tra suất chiếu rồi lấy sơ đồ ghế để hiển thị<br>// requestSeatHold: điều phối bước 5 đến 8: kiểm tra, giữ ghế, chờ hết hạn, hiển thị<br>// checkCustomerLoggedIn: xác định khách của phiên đã đăng nhập chưa<br>// startWaitingForHoldExpiry: bắt đầu chờ thời điểm hết hạn giữ ghế (BR-10)<br>// startOnlinePayment: điều phối bước 10: tạo giao dịch thanh toán, ghi nhận số tiền<br>// stopWaitingForHoldExpiry: ngừng chờ hết hạn khi tác nhân huỷ giữ ghế hoặc xác nhận thu tiền mặt<br>// handleHoldExpired: nhận sự kiện hết hạn, kết thúc lần giữ ghế và giải phóng ghế<br>// cancelSeatHold: điều phối việc huỷ giữ ghế và giải phóng ghế<br>// confirmCashReceived: điều phối bước 9a2 đến 9a4 khi nhân viên quầy xác nhận đã thu tiền mặt | - | 1 đến 10, 2a đến 10a, 9a1 đến 9a5, *a | - | Mới | - |
| AC-C-PaymentReportController | control | PaymentReportController | // handlePaymentReport: tiếp nhận mọi báo kết quả giao dịch của cổng, tìm lần giữ ghế theo mã giao dịch hoặc mã tham chiếu lần giữ ghế, giao SeatHold thao tác xử lý báo rồi điều phối theo kết quả: bán ghế (bước 12 đến 15), thất bại khi lần giữ ghế còn hiệu lực (11a); các kết quả còn lại do UC-006 điều phối tiếp | - | 11 đến 15, 11a | - | Mới; UC-006 dùng lại | - |
| AC-E-Customer | entity | Customer | // checkNoActiveSeatHold: kiểm tra khách không có lần giữ ghế nào chưa kết thúc (BR-04)<br>// authenticateCustomer: đối chiếu email hoặc số điện thoại và mật khẩu với tài khoản khách | email (Văn bản), phoneNumber (Văn bản), password (Văn bản) | 5, 5a2, 7 | - | Mới - chủ sở hữu UC-001 | GL-18 |
| AC-E-BoxOfficeClerk | entity | BoxOfficeClerk | // checkNoActiveSeatHold: kiểm tra nhân viên quầy không có lần giữ ghế nào chưa kết thúc (BR-04) | cinema (Cụm rạp của nhân viên quầy) | 2b, 5, 7 | - | Mới - chủ sở hữu UC-017 | GL-35 |
| AC-E-Showtime | entity | Showtime | // checkSaleOpen: kiểm tra đã tới thời điểm mở bán và chưa tới giờ bắt đầu (BR-01, BR-45)<br>// provideSeatMap: cung cấp sơ đồ ghế kèm trạng thái ghế của suất chiếu<br>// checkSeatSelectionLimit: kiểm tra các ghế chọn thuộc sơ đồ ghế và không vượt số ghế tối đa (BR-05, BR-06)<br>// holdSeats: thao tác không chia cắt: kiểm tra, giữ cả nhóm ghế và chốt giá vé; loại trừ theo suất chiếu và theo người giữ ghế (BR-04, BR-07, BR-09, BR-54, BR-65, BR-71)<br>// checkUnchangedSinceDisplayed: kiểm tra suất chiếu chưa bị sửa hoặc xoá kể từ lúc hiển thị sơ đồ ghế (BR-54)<br>// checkBelongsToCinema: kiểm tra suất chiếu thuộc cụm rạp của nhân viên quầy (BR-02) | startTime (Ngày giờ), saleOpenTime (Ngày giờ), movieFormat (Văn bản), auditoriumType (Văn bản), cinema (Cụm rạp), lastChangedAt (Ngày giờ) | 2, 2a, 2b, 2c, 3, 6, 7 | - | Mới - chủ sở hữu UC-014 | GL-47 |
| AC-E-PriceList | entity | PriceList | // determineSeatPrice: xác định giá vé theo loại phòng, định dạng phim, loại ghế và khung giờ do bảng giá tự xác định từ giờ bắt đầu (BR-11, BR-12, BR-72) | cinema (Cụm rạp) | 7, 7e | - | Mới - chủ sở hữu UC-013 | GL-01 |
| AC-E-SeatStatus | entity | SeatStatus | // provideSeatStatus: cung cấp vị trí, loại ghế và trạng thái ghế để hiển thị<br>// holdSeatFor: chuyển ghế sang đang được giữ cho một lần giữ ghế khi ghế còn trống (BR-07, BR-08, BR-09)<br>// recordHeldPrice: ghi giá vé đã chốt của ghế (BR-65)<br>// provideHeldSeatInfo: cung cấp vị trí, loại ghế và giá vé đã chốt của ghế đang giữ<br>// markSold: chuyển ghế đang giữ sang đã bán<br>// releaseSeat: chuyển ghế đang được giữ về trống; chạy lại không hại, chỉ đổi ghế còn thuộc lần giữ ghế đó | seatPosition (Mã hàng, số ghế), seatType (Văn bản), status (Trạng thái), heldPrice (Số tiền) | 3, 7, 8, 11, 12, 9a2, 7b, 11a, *a | - | Mới | GL-58 |
| AC-E-SeatHold | entity | SeatHold | // createSeatHold: tạo lần giữ ghế cho người giữ, đặt thời điểm hết hạn theo BR-10<br>// provideHoldSummary: cung cấp các ghế đã giữ, giá vé từng ghế, tổng tiền<br>// calculateTotalAmount: tính tổng tiền bằng tổng giá vé đã chốt của các ghế đã giữ<br>// recordPaymentTransaction: tạo giao dịch thanh toán gắn với lần giữ ghế, ghi số tiền (REQ-111); dùng cho cả giao dịch thứ hai của UC-006<br>// settlePaymentReport: trách nhiệm duy nhất xử lý báo kết quả giao dịch của cổng, thao tác không chia cắt theo lần giữ ghế, trả về một trong bốn kết quả: bán ghế (kiểm chưa xử lý, còn hiệu lực, đánh dấu đã xử lý, bán ghế, hoàn tất, tạo lần đặt cùng vé), thanh toán trễ chờ hoàn, báo trùng, thất bại ghi nhận; lần giữ ghế Đang giữ mà quá hạn được chuyển sang Hết hạn trước (BR-14, BR-15, BR-37, BR-85, BR-86)<br>// checkHoldStillActive: kiểm tra lần giữ ghế còn Đang giữ và chưa quá thời điểm hết hạn tại thời điểm xử lý; dùng chung cho UC-005, UC-006 và UC-014 (BR-04, BR-53, BR-85, BR-86)<br>// endHold: chuyển lần giữ ghế sang một trạng thái cuối (Đã hoàn tất, Hết hạn, Đã huỷ, Thanh toán thất bại); chỉ đổi khi chưa ở trạng thái cuối<br>// issueBooking: tạo lần đặt cho lần giữ ghế đã hoàn tất, trong cùng thao tác bán ghế<br>// expire: kết thúc lần giữ ghế ở trạng thái Hết hạn khi tới thời điểm hết hạn hoặc khi báo thanh toán đến sau thời điểm đó; không đổi nếu đã ở trạng thái cuối<br>// releaseHeldSeats: giải phóng từng ghế đang giữ về trống (chậm nhất 1 phút sau thời điểm hết hạn, REQ-76); chạy lại không hại và chạy được cả khi lần giữ ghế đã ở trạng thái cuối mà ghế còn đang giữ<br>// cancel: kết thúc lần giữ ghế ở trạng thái Đã huỷ khi tác nhân huỷ<br>// completeSaleOnCashConfirmation: thao tác không chia cắt theo lần giữ ghế khi nhân viên quầy xác nhận đã thu tiền: so thời điểm, bán ghế, hoàn tất, tạo lần đặt cùng vé (BR-44, BR-85) | holdRef (Văn bản), status (Trạng thái), holdTime (Ngày giờ), expiryTime (Ngày giờ) | 7, 7b, 7c, 8, 10, 11, 11a, 12, 13, 9a1a, 9a2, 9a3, *a | - | Mới | GL-25, GL-31, GL-52, GL-54 |
| AC-E-PaymentTransaction | entity | PaymentTransaction | // createPaymentTransaction: tạo giao dịch thanh toán với mã giao dịch và số tiền<br>// checkNotProcessed: kiểm tra giao dịch chưa dùng để tạo vé và chưa ghi nhận thanh toán trễ, nên chỉ báo đầu tiên được xử lý (BR-37)<br>// markProcessed: đánh dấu giao dịch đã xử lý để tạo vé<br>// recordFailedResult: ghi nhận kết quả thất bại của giao dịch | transactionCode (Văn bản), amount (Số tiền), processed (Trạng thái), result (Văn bản) | 10, 11a, 12 | - | Mới | GL-12, GL-29 |
| AC-E-Booking | entity | Booking | // createBooking: tạo lần đặt cho các ghế đã bán<br>// generateBookingCode: sinh mã đặt vé duy nhất toàn hệ thống (BR-80)<br>// provideBookingInfo: cung cấp mã đặt vé và nội dung các vé của lần đặt | bookingCode (Văn bản) | 13, 15, 9a3, 9a4 | - | Mới | GL-24, GL-28 |
| AC-E-Ticket | entity | Ticket | // createTicket: tạo vé cho một ghế, ghi giá vé đã chốt (BR-67)<br>// generateQrCode: sinh mã QR riêng của vé từ mã vé<br>// provideTicketContent: cung cấp nội dung vé để hiển thị hoặc gửi | ticketCode (Văn bản), qrCode (Hình ảnh), seatPosition (Mã hàng, số ghế), seatType (Văn bản), price (Số tiền), status (Trạng thái) | 13, 15, 9a3, 9a4 | - | Mới | GL-59, GL-30, GL-32 |

Tổng cộng 15 lớp: 4 boundary, 2 control, 9 entity. Entity cốt lõi của chủ đề race condition, giữ ghế và giải phóng ghế: AC-E-SeatHold, AC-E-SeatStatus, AC-E-Showtime.

## 4. Phân bổ hành vi

| Bước UC | Trách nhiệm | Lớp nhận (AC) | Nguyên tắc | Lý do khi có lựa chọn khác |
|---|---|---|---|---|
| 1 | // selectShowtime | AC-B-BookTicketsForm | Giao tiếp tác nhân | - |
| 1 | // startBooking | AC-C-BookTicketsController | Controller | - |
| 2 | // checkSaleOpen | AC-E-Showtime | Information Expert | Thời điểm mở bán và giờ bắt đầu là dữ liệu của suất chiếu; giao control sẽ làm control giữ quy tắc thuộc dữ liệu của entity. |
| 2, 2b | // checkBelongsToCinema | AC-E-Showtime | Information Expert | Dữ liệu ở hai lớp: cụm rạp của suất chiếu (Showtime) và cụm rạp của nhân viên quầy (BoxOfficeClerk). Giao Showtime và nhận cụm rạp của nhân viên làm tham số, vì Showtime không có quan hệ cấu trúc với BoxOfficeClerk để hỏi trực tiếp; giao control làm control giữ quy tắc. |
| 2a, 2c | // notifyRefusal | AC-B-BookTicketsForm, AC-B-CounterBookTicketsForm | Giao tiếp tác nhân | - |
| 2b | // notifyRefusal | AC-B-CounterBookTicketsForm | Giao tiếp tác nhân | - |
| 3 | // provideSeatMap, provideSeatStatus | AC-E-Showtime, AC-E-SeatStatus | Information Expert | Showtime nắm các trạng thái ghế của mình nên lặp qua từng trạng thái ghế để liệt kê hiển thị. |
| 3 | // showSeatMap | AC-B-BookTicketsForm, AC-B-CounterBookTicketsForm | Giao tiếp tác nhân | - |
| 3 | // updateSeatMap | AC-B-BookTicketsForm, AC-B-CounterBookTicketsForm | Giao tiếp tác nhân | Entity không được gọi boundary (F6) nên control phát việc cập nhật tới các màn hình đang xem sau mỗi lần trạng thái ghế đổi (giữ, bán, trở về trống); người xem tại quầy dùng CounterBookTicketsForm với cùng message. |
| 4 | // confirmSeatSelection | AC-B-BookTicketsForm, AC-B-CounterBookTicketsForm | Giao tiếp tác nhân | - |
| 4 | // requestSeatHold | AC-C-BookTicketsController | Controller | - |
| 5 | // checkCustomerLoggedIn | AC-C-BookTicketsController | Controller | Trạng thái đăng nhập của phiên không là dữ liệu của entity nào; khách chưa đăng nhập chưa có Customer để hỏi. |
| 5 | // checkNoActiveSeatHold | AC-E-Customer, AC-E-BoxOfficeClerk | Information Expert | Người giữ ghế nắm các lần giữ ghế của mình (R-UC005-14, R-UC005-15). |
| 5a1 | // requestLogin | AC-B-BookTicketsForm | Giao tiếp tác nhân | - |
| 5a2 | // provideCredentials | AC-B-BookTicketsForm | Giao tiếp tác nhân | - |
| 5a2 | // authenticateCustomer | AC-E-Customer | Information Expert | Customer nắm email, số điện thoại, mật khẩu của tài khoản (Q-82). |
| 5b | // notifyRefusal | AC-B-BookTicketsForm | Giao tiếp tác nhân | - |
| 6 | // checkSeatSelectionLimit | AC-E-Showtime | Information Expert | Dữ liệu ở nhiều lớp: các ghế chọn thuộc sơ đồ ghế (Showtime nắm các trạng thái ghế) và lần giữ ghế chưa tồn tại ở bước 6 (tạo ở bước 7). Giao Showtime vì chọn tập theo điều kiện; giao control làm control giữ quy tắc BR-05. |
| 6a | // notifyRefusal | AC-B-BookTicketsForm | Giao tiếp tác nhân | - |
| 7 | // holdSeats | AC-E-Showtime | Information Expert | Thao tác không chia cắt kiểm-và-giữ-và-chốt-giá cần một lớp điều phối các bước nhỏ trên nhiều entity. Giao control: thành god control và lệch nguyên tắc entity nắm quy tắc. Giao SeatHold: chưa tồn tại lúc kiểm. Giao SeatStatus: chỉ biết một ghế, không đảm bảo giữ cả nhóm hoặc không ghế nào (BR-07). Chọn Showtime vì nắm mọi trạng thái ghế của suất chiếu, là đối tượng BR-54 loại trừ với sửa suất chiếu, và có quan hệ cấu trúc tới SeatHold và PriceList. |
| 7 | // createSeatHold | AC-E-SeatHold | Creator | Showtime ghi nhận các lần giữ ghế của suất chiếu (R-UC005-10) và có dữ liệu khởi tạo (người giữ ghế, suất chiếu). |
| 7, 7c | // checkNoActiveSeatHold (trong thao tác giữ ghế) | AC-E-Customer, AC-E-BoxOfficeClerk | Information Expert | Showtime không có quan hệ cấu trúc tới người giữ ghế; lần giữ ghế vừa tạo có, nên SeatHold hỏi người giữ ghế trong cùng thao tác. |
| 7, 7d | // checkUnchangedSinceDisplayed | AC-E-Showtime | Information Expert | lastChangedAt là dữ liệu của suất chiếu. |
| 7, 7a | // holdSeatFor | AC-E-SeatStatus | Information Expert | Trạng thái ghế biết ghế còn trống không và tự chuyển sang đang được giữ (BR-07, BR-08, BR-09). |
| 7, 7e | // determineSeatPrice | AC-E-PriceList | Information Expert | Bảng giá nắm các mục giá và tự xác định khung giờ từ giờ bắt đầu của suất chiếu (BR-11, BR-12, BR-72); Showtime không còn trách nhiệm xác định khung giờ (Q-104). |
| 7 | // recordHeldPrice | AC-E-SeatStatus | Information Expert | Giá chốt đi kèm ghế đang giữ, giữ nguyên tới hết lần giữ ghế (BR-65). |
| 7 | // startWaitingForHoldExpiry | AC-C-BookTicketsController | Controller | A2: control ghi nhận bắt đầu chờ thời hạn nội bộ. |
| 7a | // notifyRefusal | AC-B-BookTicketsForm | Giao tiếp tác nhân | - |
| 7c, 7d, 7e | // notifyRefusal | AC-B-BookTicketsForm | Giao tiếp tác nhân | - |
| 8 | // provideHoldSummary, calculateTotalAmount, provideHeldSeatInfo | AC-E-SeatHold, AC-E-SeatStatus | Information Expert | Tổng tiền cần giá của từng ghế đang giữ; SeatHold nắm tập ghế nên SeatHold tính tổng và lặp gom dữ liệu từng ghế. |
| 8 | // showHeldSeats | AC-B-BookTicketsForm, AC-B-CounterBookTicketsForm | Giao tiếp tác nhân | - |
| 9 | // requestOnlinePayment | AC-B-BookTicketsForm | Giao tiếp tác nhân | - |
| 9 | // startOnlinePayment | AC-C-BookTicketsController | Controller | - |
| 10 | // createPaymentTransaction | AC-B-PaymentGateway | Giao tiếp tác nhân | - |
| 10 | // recordPaymentTransaction | AC-E-SeatHold | Creator | Giao dịch thanh toán tạo cho tổng tiền của một lần giữ ghế; SeatHold ghi nhận giao dịch của mình và có tổng tiền. |
| 10 | // createPaymentTransaction (tạo đối tượng) | AC-E-PaymentTransaction | Creator | - |
| 10a | // notifyRefusal | AC-B-BookTicketsForm | Giao tiếp tác nhân | - |
| 11 | // reportTransactionResult | AC-B-PaymentGateway | Giao tiếp tác nhân | - |
| 11 | // handlePaymentReport | AC-C-PaymentReportController | Controller | Một control tiếp nhận mọi báo của cổng (Q-83), UC-005 là chủ; control của UC-005 không gọi control của UC-006 (F6). Control không dừng chờ hết hạn: sự kiện hết hạn chạy sau đó không đổi gì vì lần giữ ghế đã ở trạng thái cuối. |
| 12 | // settlePaymentReport, checkHoldStillActive, endHold, expire | AC-E-SeatHold | Information Expert | So thời điểm nhận báo với thời điểm hết hạn và với trạng thái lần giữ ghế là dữ liệu của SeatHold; SeatHold cũng là đơn vị xử lý tuần tự (BR-85). Một trách nhiệm xử lý báo duy nhất cho mọi kết quả, thay cho hai trách nhiệm tách đôi theo use case. Giao control làm control giữ quy tắc về hết hạn và trạng thái cuối. |
| 12 | // checkNotProcessed, markProcessed | AC-E-PaymentTransaction | Information Expert | Giao dịch biết đã xử lý chưa nên chỉ báo đầu tiên được xử lý (BR-37). |
| 12, 9a2 | // markSold | AC-E-SeatStatus | Information Expert | - |
| 13 | // issueBooking | AC-E-SeatHold | Information Expert | Lần giữ ghế đã hoàn tất dẫn tới tối đa một lần đặt (GL-24); nằm trong thao tác settlePaymentReport để không có trường hợp đã bán ghế mà không có vé (Q-84). |
| 13 | // createBooking | AC-E-Booking | Creator | SeatHold có dữ liệu khởi tạo (suất chiếu, ghế đã bán). |
| 13 | // generateBookingCode | AC-E-Booking | Information Expert | Mã đặt vé là mã của lần đặt, duy nhất toàn hệ thống (BR-80). |
| 13 | // createTicket, generateQrCode | AC-E-Ticket | Creator | Booking gồm mỗi ghế một vé nên Booking tạo vé; vé tự sinh mã QR riêng từ mã vé. |
| 14 | // sendTicketsEmail | AC-B-EmailService | Giao tiếp tác nhân | - |
| 15 | // provideBookingInfo, provideTicketContent | AC-E-Booking, AC-E-Ticket | Information Expert | Booking nắm các vé của lần đặt nên lặp gom nội dung từng vé. |
| 15 | // showBookingSuccess | AC-B-BookTicketsForm | Giao tiếp tác nhân | - |
| 7b | // handleHoldExpired | AC-C-BookTicketsController | Controller | A2: control nhận sự kiện hết hạn (after BR-10). |
| 7b | // expire, checkHoldStillActive, endHold | AC-E-SeatHold | Information Expert | Hết hạn và kiểm còn Đang giữ là dữ liệu của lần giữ ghế; xử lý tuần tự với báo thanh toán và huỷ giữ ghế (BR-85). |
| 7b, 11a, *a | // releaseHeldSeats, releaseSeat | AC-E-SeatHold, AC-E-SeatStatus | Information Expert | Giải phóng từng ghế của lần giữ ghế; tách khỏi chuyển trạng thái để giải phóng được chậm nhất 1 phút sau thời điểm hết hạn mà lần giữ ghế đã kết thúc đúng thời điểm (REQ-76, Mục 8). Phải chạy lại được an toàn, kể cả trên lần giữ ghế đã được báo thanh toán đến muộn chuyển sang Hết hạn trước khi ghế được giải phóng; chỉ ghế còn thuộc lần giữ ghế đó mới đổi. |
| 7b | // notifyRefusal | AC-B-BookTicketsForm | Giao tiếp tác nhân | - |
| 11a | // settlePaymentReport (kết quả thất bại), checkHoldStillActive, endHold | AC-E-SeatHold | Information Expert | Kết quả thất bại đi qua cùng trách nhiệm xử lý báo; lần giữ ghế còn Đang giữ thì kết thúc ở Thanh toán thất bại. |
| 11a | // recordFailedResult | AC-E-PaymentTransaction | Information Expert | - |
| 11a | // notifyRefusal | AC-B-BookTicketsForm | Giao tiếp tác nhân | - |
| *a | // cancelSeatHold | AC-B-BookTicketsForm, AC-C-BookTicketsController | Giao tiếp tác nhân, Controller | - |
| *a | // cancel | AC-E-SeatHold | Information Expert | - |
| 9a1 | // confirmCashReceived | AC-B-CounterBookTicketsForm, AC-C-BookTicketsController | Giao tiếp tác nhân, Controller | - |
| 9a1a, 9a2 | // completeSaleOnCashConfirmation, checkHoldStillActive, endHold | AC-E-SeatHold | Information Expert | So thời điểm xác nhận với thời điểm hết hạn và bán ghế là một thao tác không chia cắt theo lần giữ ghế (BR-44, BR-85); lý do như bước 12. |
| 9a1a | // notifyRefusal | AC-B-CounterBookTicketsForm | Giao tiếp tác nhân | - |
| 9a3 | // issueBooking, createBooking, generateBookingCode, createTicket, generateQrCode | AC-E-SeatHold, AC-E-Booking, AC-E-Ticket | Creator | Như bước 13, trong cùng thao tác completeSaleOnCashConfirmation. |
| 9a4 | // provideBookingInfo, provideTicketContent, showTicketsForPrint | AC-E-Booking, AC-E-Ticket, AC-B-CounterBookTicketsForm | Information Expert | Như bước 15. |
| 9a5 | // printTickets | AC-B-CounterBookTicketsForm | Giao tiếp tác nhân | - |

Bảng thao tác không chia cắt (trọng tâm chống race condition, giữ ghế và giải phóng ghế). Mức phân tích chỉ nêu lớp chịu trách nhiệm và những gì phải nằm trong cùng thao tác; cơ chế bảo đảm thuộc P09.

| Thao tác | Lớp và trách nhiệm | Phải nằm trong cùng thao tác | BR | Vì sao giao cho lớp này |
|---|---|---|---|---|
| Kiểm-và-giữ ghế và chốt giá (bước 7) | AC-E-Showtime, // holdSeats | Tạo lần giữ ghế, kiểm người giữ ghế không có lần giữ ghế chưa kết thúc, kiểm suất chiếu chưa đổi, kiểm và giữ mọi ghế đã chọn (cả nhóm hoặc không ghế nào), xác định và ghi giá từng ghế | BR-04, BR-07, BR-08, BR-09, BR-54, BR-65, BR-71, BR-72 | Showtime nắm các trạng thái ghế, là đối tượng loại trừ với sửa, xoá suất chiếu và đọc bảng giá của cụm rạp. Đơn vị loại trừ có hai chiều: suất chiếu (BR-54, BR-09) và người giữ ghế (BR-04, trải qua mọi suất chiếu), nên hai yêu cầu của cùng một người trên hai suất chiếu khác nhau cũng phải tuần tự ở điều kiện BR-04. Thất bại ở bất kỳ điều kiện nào thì không để lại lần giữ ghế hay ghế đang giữ nào (7a, 7c, 7d, 7e). |
| Xử lý báo kết quả thanh toán của cổng: so thời điểm với thời điểm hết hạn, bán ghế, tạo lần đặt và vé (bước 11, 12, 13) hoặc ghi nhận kết quả khác | AC-E-SeatHold, // settlePaymentReport | Kiểm giao dịch chưa xử lý, kiểm còn Đang giữ và chưa quá thời điểm hết hạn (quá hạn thì chuyển sang Hết hạn), đánh dấu giao dịch đã xử lý, chuyển các ghế sang đã bán, chuyển sang Đã hoàn tất, tạo lần đặt và vé; hoặc ghi nhận thanh toán trễ, báo trùng, thất bại (UC-006) | BR-14, BR-15, BR-37, BR-85, BR-86 | Thời điểm hết hạn và trạng thái là dữ liệu của SeatHold; xử lý tuần tự theo từng lần giữ ghế nên báo thành công đến cùng lúc hết hạn hoặc huỷ chỉ có một kết quả (Q-83, Q-84). Một trách nhiệm cho cả bốn kết quả nên không có báo nào bị hai bên cùng xử lý hoặc không bên nào xử lý. |
| So thời điểm xác nhận đã thu tiền với thời điểm hết hạn, bán ghế, tạo lần đặt và vé (bước 9a1a, 9a2, 9a3) | AC-E-SeatHold, // completeSaleOnCashConfirmation | Như dòng trên, không có giao dịch thanh toán | BR-44, BR-85 | Như dòng trên. |
| Kết thúc lần giữ ghế khi hết hạn, huỷ, thanh toán thất bại (7b, *a, 11a) | AC-E-SeatHold, // expire, // cancel và // settlePaymentReport (kết quả thất bại), đều dùng // checkHoldStillActive và // endHold | Kiểm còn Đang giữ rồi chuyển sang đúng một trạng thái cuối; đã ở trạng thái cuối thì không đổi | BR-85, BR-86 | Cùng một đơn vị xử lý tuần tự với bán ghế nên không thể vừa bán vừa giải phóng cùng một ghế. |
| Giải phóng ghế (7b, *a, 11a) | AC-E-SeatHold, // releaseHeldSeats; AC-E-SeatStatus, // releaseSeat | Chuyển từng ghế của lần giữ ghế về trống, chậm nhất 1 phút sau thời điểm hết hạn; chỉ ghế còn thuộc lần giữ ghế đó | BR-10, REQ-76 | Lần giữ ghế đã kết thúc đúng thời điểm hết hạn (BR-04) nên bước chuyển trạng thái và bước giải phóng ghế tách nhau. |

Đơn vị loại trừ của các thao tác không chia cắt trong bốn use case (đầu vào cho P08; P08 lập bảng chính thức, P09 chọn cơ chế):

| Thao tác không chia cắt | Lớp chủ | Lớp được đọc hoặc ghi trong thao tác | BR | Use case |
| --- | --- | --- | --- | --- |
| holdSeats | Showtime | PriceList (đọc), Customer hoặc BoxOfficeClerk (đọc), SeatHold (tạo), SeatStatus | BR-04, BR-07, BR-09, BR-54, BR-71 | UC-005 |
| settlePaymentReport, completeSaleOnCashConfirmation | SeatHold | PaymentTransaction, SeatStatus, Booking, Ticket | BR-37, BR-44, BR-85, BR-86 | UC-005, UC-006 |
| expire, cancel | SeatHold | - | BR-85, BR-86 | UC-005 |
| saveShowtime | Auditorium | PriceList (đọc), Showtime | BR-52, BR-54, BR-68 | UC-014 |
| removeFromSchedule | Showtime | SeatHold (đọc), Ticket (đọc) | BR-53, BR-54 | UC-014 |
| savePriceEntry | PriceList | PriceEntry | BR-63, BR-71 | UC-013 |
| removePriceEntry | PriceList | Showtime (đọc) | BR-63, BR-64, BR-68 | UC-013 |
| cancelTicket | Ticket | - | BR-21, BR-30 | UC-008 |
| admitTicket | Ticket | - | BR-21, BR-30 | UC-009 |

Thứ tự khoá cố định đề xuất: PriceList, Auditorium, Showtime, người giữ ghế, SeatHold, SeatStatus, PaymentTransaction, Ticket. Mọi thao tác lấy khoá theo thứ tự này kể cả khi lớp được đọc đứng trước lớp chủ (holdSeats lấy khoá bảng giá trước khoá suất chiếu, saveShowtime lấy khoá bảng giá trước khoá phòng chiếu), nên không có chu trình khoá giữa holdSeats, removePriceEntry và saveShowtime.

## 5. Sequence diagram phân tích

File diagrams/P07-sequence-UC-005.drawio có 17 trang, mỗi trang một sơ đồ. ID cell của lifeline là "<ID trang>-L-<khoá>", ID cell của message là "<ID trang>-M-<STT>" (các ký tự [ ] ( ) * trong STT đổi thành _, message trả về thêm hậu tố -R). Luồng thay thế rẽ tại message có STT 1.1.1 dùng STT 1.1.1a, 1.1.1c theo chữ của mã luồng; luồng xảy ra trong một khoảng bước dùng STT message đầu khoảng kèm mã luồng trong ngoặc, ví dụ 2.1.5(7b).1. Biến thể ACT-02 dùng hậu tố [ACT-02]. Lifeline w:BookTicketsForm là boundary của khách khác đang xem cùng sơ đồ ghế.

### SD1a - Luồng chính bước 1 đến 7

a) Luồng thể hiện: Chọn suất chiếu, chọn ghế, giữ ghế không chia cắt và chốt giá.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1a-L-K | Actor | :Khách | - | - | Tác nhân (ACT-01) |
| SD1a-L-BF | Lifeline | :BookTicketsForm | «boundary» | - | AC-B-BookTicketsForm |
| SD1a-L-WF | Lifeline | w:BookTicketsForm | «boundary» | - | Boundary của khách khác đang xem sơ đồ ghế (AC-B-BookTicketsForm) |
| SD1a-L-C | Lifeline | :BookTicketsController | «control» | - | AC-C-BookTicketsController |
| SD1a-L-CU | Lifeline | :Customer | «entity» | - | AC-E-Customer |
| SD1a-L-ST | Lifeline | :Showtime | «entity» | - | AC-E-Showtime |
| SD1a-L-PL | Lifeline | :PriceList | «entity» | - | AC-E-PriceList |
| SD1a-L-SH | Lifeline | :SeatHold | «entity» | - | Đỉnh lifeline đặt ngang message Tạo |
| SD1a-L-SS | Lifeline | :SeatStatus | «entity» | - | AC-E-SeatStatus |
| SD1a-F1 | Fragment | loop [mỗi ghế của sơ đồ ghế] | - | - | Bao các message của fragment |
| SD1a-F2 | Fragment | loop [mỗi ghế đã chọn] | - | - | Bao các message của fragment |
| SD1a-F3 | Fragment | loop [mỗi ghế đã chọn] | - | - | Bao các message của fragment |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1 | :Khách | :BookTicketsForm | // selectShowtime (suất chiếu) | Đồng bộ | - | 1 |
| 1.1 | :BookTicketsForm | :BookTicketsController | // startBooking (suất chiếu) | Đồng bộ | - | 1 |
| 1.1.1 | :BookTicketsController | :Showtime | // checkSaleOpen (thời điểm hiện tại) | Đồng bộ | - | 2 |
| 1.1.2 | :BookTicketsController | :Showtime | // provideSeatMap | Đồng bộ | - | 3 |
| 1.1.2.1 | :Showtime | :SeatStatus | // provideSeatStatus (vị trí, loại ghế, trạng thái ghế) | Đồng bộ | SD1a-F1 | 3 |
| 1.1.2 (trả về) | :Showtime | :BookTicketsController | sơ đồ ghế kèm trạng thái ghế | Trả về | - | 3 |
| 1.1.3 | :BookTicketsController | :BookTicketsForm | // showSeatMap (suất chiếu, sơ đồ ghế) | Đồng bộ | - | 3 |
| 2 | :Khách | :BookTicketsForm | // confirmSeatSelection (các ghế đã chọn) | Đồng bộ | - | 4 |
| 2.1 | :BookTicketsForm | :BookTicketsController | // requestSeatHold (các ghế đã chọn, khách đã đăng nhập nếu có) | Đồng bộ | - | 4 |
| 2.1.1 | :BookTicketsController | :BookTicketsController | // checkCustomerLoggedIn | Tự gọi | - | 5 |
| 2.1.2 | :BookTicketsController | :Customer | // checkNoActiveSeatHold | Đồng bộ | - | 5 |
| 2.1.3 | :BookTicketsController | :Showtime | // checkSeatSelectionLimit (các ghế đã chọn) | Đồng bộ | - | 6 |
| 2.1.4 | :BookTicketsController | :Showtime | // holdSeats (khách, các ghế đã chọn, mốc hiển thị sơ đồ ghế) | Đồng bộ | - | 7 |
| 2.1.4.1 | :Showtime | :SeatHold | «create» // createSeatHold (khách, suất chiếu) | Tạo | - | 7 |
| 2.1.4.1.1 | :SeatHold | :Customer | // checkNoActiveSeatHold | Đồng bộ | - | 7 |
| 2.1.4.2 | :Showtime | :Showtime | // checkUnchangedSinceDisplayed (mốc hiển thị sơ đồ ghế) | Tự gọi | - | 7 |
| 2.1.4.3 | :Showtime | :SeatStatus | // holdSeatFor (lần giữ ghế) | Đồng bộ | SD1a-F2 | 7 |
| 2.1.4.4 | :Showtime | :PriceList | // determineSeatPrice (loại phòng, định dạng phim, loại ghế, giờ bắt đầu) | Đồng bộ | SD1a-F3 | 7 |
| 2.1.4.4 (trả về) | :PriceList | :Showtime | giá vé của ghế | Trả về | SD1a-F3 | 7 |
| 2.1.4.5 | :Showtime | :SeatStatus | // recordHeldPrice (giá vé) | Đồng bộ | SD1a-F3 | 7 |
| 2.1.4 (trả về) | :Showtime | :BookTicketsController | lần giữ ghế đã tạo | Trả về | - | 7 |
| 2.1.5 | :BookTicketsController | :BookTicketsController | // startWaitingForHoldExpiry (BR-10) | Tự gọi | - | 7 |
| 2.1.6 | :BookTicketsController | w:BookTicketsForm | // updateSeatMap (ghế đã được giữ) | Đồng bộ | - | 3 |

### SD1b - Luồng chính bước 8 đến 12

a) Luồng thể hiện: Hiển thị ghế đã giữ, tạo giao dịch thanh toán, nhận kết quả giao dịch ở điểm tiếp nhận dùng chung và bán ghế.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1b-L-K | Actor | :Khách | - | - | Tác nhân (ACT-01) |
| SD1b-L-BF | Lifeline | :BookTicketsForm | «boundary» | - | AC-B-BookTicketsForm |
| SD1b-L-C | Lifeline | :BookTicketsController | «control» | - | AC-C-BookTicketsController |
| SD1b-L-PC | Lifeline | :PaymentReportController | «control» | - | AC-C-PaymentReportController |
| SD1b-L-SH | Lifeline | :SeatHold | «entity» | - | AC-E-SeatHold |
| SD1b-L-SS | Lifeline | :SeatStatus | «entity» | - | AC-E-SeatStatus |
| SD1b-L-PT | Lifeline | :PaymentTransaction | «entity» | - | Đỉnh lifeline đặt ngang message Tạo |
| SD1b-L-PG | Lifeline | :PaymentGateway | «boundary» | - | AC-B-PaymentGateway |
| SD1b-L-A7 | Actor | :Cổng thanh toán | - | - | Tác nhân (ACT-07) |
| SD1b-F1 | Fragment | loop [mỗi ghế đã giữ] | - | - | Bao các message của fragment |
| SD1b-F2 | Fragment | loop [mỗi ghế đang giữ] | - | - | Bao các message của fragment |
| SD1b-R1 | Fragment | ref SD1a - Luồng chính bước 1 đến 7 | - | - | ref |
| SD1b-N1 | Note | Thao tác không chia cắt theo lần giữ ghế (BR-37, BR-85, BR-86): các message 4.1.1.1 đến 4.1.1.5 ở trang này và 4.1.1.6 đến 4.1.1.6.1.2.1 ở SD1c xảy ra liền nhau; báo khác của cùng lần giữ ghế chờ đến lượt. | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 2.1.7 | :BookTicketsController | :SeatHold | // provideHoldSummary | Đồng bộ | - | 8 |
| 2.1.7.1 | :SeatHold | :SeatStatus | // provideHeldSeatInfo (vị trí, loại ghế, giá vé đã chốt) | Đồng bộ | SD1b-F1 | 8 |
| 2.1.7.2 | :SeatHold | :SeatHold | // calculateTotalAmount | Tự gọi | - | 8 |
| 2.1.7 (trả về) | :SeatHold | :BookTicketsController | các ghế đã giữ, giá vé từng ghế, tổng tiền | Trả về | - | 8 |
| 2.1.8 | :BookTicketsController | :BookTicketsForm | // showHeldSeats (ghế đã giữ, giá vé từng ghế, tổng tiền) | Đồng bộ | - | 8 |
| 3 | :Khách | :BookTicketsForm | // requestOnlinePayment | Đồng bộ | - | 9 |
| 3.1 | :BookTicketsForm | :BookTicketsController | // startOnlinePayment | Đồng bộ | - | 9 |
| 3.1.1 | :BookTicketsController | :PaymentGateway | // createPaymentTransaction (tổng tiền, mã tham chiếu lần giữ ghế) | Đồng bộ | - | 10 |
| 3.1.1.1 | :PaymentGateway | :Cổng thanh toán | // createPaymentTransaction (tổng tiền, mã tham chiếu lần giữ ghế) | Đồng bộ | - | 10 |
| 3.1.1.1 (trả về) | :Cổng thanh toán | :PaymentGateway | mã giao dịch | Trả về | - | 10 |
| 3.1.2 | :BookTicketsController | :SeatHold | // recordPaymentTransaction (mã giao dịch, tổng tiền) | Đồng bộ | - | 10 |
| 3.1.2.1 | :SeatHold | :PaymentTransaction | «create» // createPaymentTransaction (mã giao dịch, số tiền) | Tạo | - | 10 |
| 4 | :Cổng thanh toán | :PaymentGateway | // reportTransactionResult (thành công, mã giao dịch, mã tham chiếu lần giữ ghế, số tiền đã thanh toán) | Đồng bộ | - | 11 |
| 4.1 | :PaymentGateway | :PaymentReportController | // handlePaymentReport (thành công, mã giao dịch, mã tham chiếu lần giữ ghế, số tiền đã thanh toán, thời điểm nhận báo) | Đồng bộ | - | 11 |
| 4.1.1 | :PaymentReportController | :SeatHold | // settlePaymentReport (lần giữ ghế tìm theo mã giao dịch hoặc mã tham chiếu lần giữ ghế, kết quả, số tiền đã thanh toán, thời điểm nhận báo) | Đồng bộ | - | 12 |
| 4.1.1.1 | :SeatHold | :PaymentTransaction | // checkNotProcessed (mã giao dịch) | Đồng bộ | - | 12 |
| 4.1.1.2 | :SeatHold | :SeatHold | // checkHoldStillActive (thời điểm nhận báo) | Tự gọi | - | 12 |
| 4.1.1.3 | :SeatHold | :PaymentTransaction | // markProcessed (mã giao dịch) | Đồng bộ | - | 12 |
| 4.1.1.4 | :SeatHold | :SeatStatus | // markSold | Đồng bộ | SD1b-F2 | 12 |
| 4.1.1.5 | :SeatHold | :SeatHold | // endHold (Đã hoàn tất) | Tự gọi | - | 12 |

### SD1c - Luồng chính bước 13 đến 15

a) Luồng thể hiện: Tạo mã đặt vé và vé trong cùng thao tác bán ghế, báo cập nhật sơ đồ ghế, gửi email, hiển thị kết quả.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1c-L-BF | Lifeline | :BookTicketsForm | «boundary» | - | AC-B-BookTicketsForm |
| SD1c-L-WF | Lifeline | w:BookTicketsForm | «boundary» | - | Boundary của khách khác đang xem sơ đồ ghế (AC-B-BookTicketsForm) |
| SD1c-L-PC | Lifeline | :PaymentReportController | «control» | - | AC-C-PaymentReportController |
| SD1c-L-SH | Lifeline | :SeatHold | «entity» | - | AC-E-SeatHold |
| SD1c-L-BK | Lifeline | :Booking | «entity» | - | Đỉnh lifeline đặt ngang message Tạo |
| SD1c-L-TK | Lifeline | :Ticket | «entity» | - | Đỉnh lifeline đặt ngang message Tạo |
| SD1c-L-ES | Lifeline | :EmailService | «boundary» | - | AC-B-EmailService |
| SD1c-L-A8 | Actor | :Dịch vụ email | - | - | Tác nhân (ACT-08) |
| SD1c-F1 | Fragment | loop [mỗi ghế đã bán] | - | - | Bao các message của fragment |
| SD1c-F2 | Fragment | loop [mỗi vé của lần đặt] | - | - | Bao các message của fragment |
| SD1c-R1 | Fragment | ref SD1b - Luồng chính bước 8 đến 12 | - | - | ref |
| SD1c-N1 | Note | Bước 13 nằm trong thao tác settlePaymentReport (Q-84): lần đặt và vé không tạo được thì thao tác không hoàn tất và giao dịch được xử lý như thanh toán trễ (UC-006). | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 4.1.1.6 | :SeatHold | :SeatHold | // issueBooking | Tự gọi | - | 13 |
| 4.1.1.6.1 | :SeatHold | :Booking | «create» // createBooking (suất chiếu, các ghế đã bán) | Tạo | - | 13 |
| 4.1.1.6.1.1 | :Booking | :Booking | // generateBookingCode (BR-80) | Tự gọi | - | 13 |
| 4.1.1.6.1.2 | :Booking | :Ticket | «create» // createTicket (ghế, giá vé đã chốt, suất chiếu) | Tạo | SD1c-F1 | 13 |
| 4.1.1.6.1.2.1 | :Ticket | :Ticket | // generateQrCode | Tự gọi | SD1c-F1 | 13 |
| 4.1.1 (trả về) | :SeatHold | :PaymentReportController | kết quả: bán ghế, lần giữ ghế đã hoàn tất kèm lần đặt | Trả về | - | 12, 13 |
| 4.1.2 | :PaymentReportController | w:BookTicketsForm | // updateSeatMap (ghế đã bán) | Đồng bộ | - | 3 |
| 4.1.3 | :PaymentReportController | :EmailService | // sendTicketsEmail (khách, các vé) | Đồng bộ | - | 14 |
| 4.1.3.1 | :EmailService | :Dịch vụ email | // sendTicketsEmail (khách, các vé) | Đồng bộ | - | 14 |
| 4.1.4 | :PaymentReportController | :Booking | // provideBookingInfo | Đồng bộ | - | 15 |
| 4.1.4.1 | :Booking | :Ticket | // provideTicketContent | Đồng bộ | SD1c-F2 | 15 |
| 4.1.4 (trả về) | :Booking | :PaymentReportController | mã đặt vé và các vé | Trả về | - | 15 |
| 4.1.5 | :PaymentReportController | :BookTicketsForm | // showBookingSuccess (mã đặt vé, các vé) | Đồng bộ | - | 15 |

### SD2 - Luồng 2a và 2c

a) Luồng thể hiện: Từ chối bán vé khi chưa mở bán hoặc suất chiếu đã bắt đầu (tác nhân Khách).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD2-L-BF | Lifeline | :BookTicketsForm | «boundary» | - | AC-B-BookTicketsForm |
| SD2-L-C | Lifeline | :BookTicketsController | «control» | - | AC-C-BookTicketsController |
| SD2-F1 | Fragment | break [suất chiếu chưa tới thời điểm mở bán (BR-01)] | - | - | Bao các message của fragment |
| SD2-F2 | Fragment | break [suất chiếu đã tới giờ bắt đầu (BR-45)] | - | - | Bao các message của fragment |
| SD2-N1 | Note | Điểm rẽ: sau message 1.1.1 của SD1a | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1.1.1a.1 | :BookTicketsController | :BookTicketsForm | // notifyRefusal (chưa tới thời điểm mở bán, BR-01) | Đồng bộ | SD2-F1 | 2a |
| 1.1.1c.1 | :BookTicketsController | :BookTicketsForm | // notifyRefusal (suất chiếu đã bắt đầu, BR-45) | Đồng bộ | SD2-F2 | 2c |

### SD3 - Luồng 5a, 5b và 6a

a) Luồng thể hiện: Đăng nhập khi chưa đăng nhập, từ chối khi đang giữ ghế, từ chối khi vượt số ghế tối đa.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD3-L-K | Actor | :Khách | - | - | Tác nhân (ACT-01) |
| SD3-L-BF | Lifeline | :BookTicketsForm | «boundary» | - | AC-B-BookTicketsForm |
| SD3-L-C | Lifeline | :BookTicketsController | «control» | - | AC-C-BookTicketsController |
| SD3-L-CU | Lifeline | :Customer | «entity» | - | AC-E-Customer |
| SD3-F1 | Fragment | alt [khách chưa đăng nhập (5a)] | - | - | Bao các message của fragment |
| SD3-F1-O2 | Fragment | [khách đã đăng nhập] | - | SD3-F1 | Toán hạng thứ hai; đường ngăn là edge SD3-F1-O2-SEP nét đứt |
| SD3-F2 | Fragment | break [đã có lần giữ ghế chưa kết thúc (BR-04)] | - | - | Bao các message của fragment |
| SD3-F3 | Fragment | alt [số ghế đã chọn vượt số ghế tối đa (BR-05, BR-06)] | - | - | Bao các message của fragment |
| SD3-F3-O2 | Fragment | [số ghế không vượt tối đa] | - | SD3-F3 | Toán hạng thứ hai; đường ngăn là edge SD3-F3-O2-SEP nét đứt |
| SD3-N1 | Note | Điểm rẽ: 5a sau 2.1.1; 5b sau 2.1.2; 6a sau 2.1.3 của SD1a | - | - | Chú thích |
| SD3-N2 | Note | quay lại bước 5 | - | - | Chú thích |
| SD3-N3 | Note | tiếp tục luồng chính | - | - | Chú thích |
| SD3-N4 | Note | quay lại bước 4 | - | - | Chú thích |
| SD3-N5 | Note | tiếp tục luồng chính | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 2.1.1a.1 | :BookTicketsController | :BookTicketsForm | // requestLogin (giữ nguyên các ghế đã chọn, BR-03) | Đồng bộ | SD3-F1 | 5a1 |
| 2.1.1a.2 | :Khách | :BookTicketsForm | // provideCredentials (email hoặc số điện thoại, mật khẩu) | Đồng bộ | SD3-F1 | 5a2 |
| 2.1.1a.3 | :BookTicketsForm | :BookTicketsController | // requestSeatHold (các ghế đã chọn, thông tin đăng nhập) | Đồng bộ | SD3-F1 | 5a2 |
| 2.1.1a.4 | :BookTicketsController | :Customer | // authenticateCustomer (email hoặc số điện thoại, mật khẩu) | Đồng bộ | SD3-F1 | 5a2 |
| 2.1.2b.1 | :BookTicketsController | :BookTicketsForm | // notifyRefusal (đang có lần giữ ghế chưa kết thúc, BR-04) | Đồng bộ | SD3-F2 | 5b |
| 2.1.3a.1 | :BookTicketsController | :BookTicketsForm | // notifyRefusal (vượt số ghế tối đa, BR-05) | Đồng bộ | SD3-F3 | 6a |

### SD4 - Luồng 7c, 7d và 7e

a) Luồng thể hiện: Từ chối giữ ghế khi đang giữ ghế khác, khi suất chiếu đã đổi, khi thiếu giá.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD4-L-BF | Lifeline | :BookTicketsForm | «boundary» | - | AC-B-BookTicketsForm |
| SD4-L-C | Lifeline | :BookTicketsController | «control» | - | AC-C-BookTicketsController |
| SD4-F1 | Fragment | break [tác nhân đang có lần giữ ghế chưa kết thúc (BR-04)] | - | - | Bao các message của fragment |
| SD4-F2 | Fragment | break [không thuộc 7c; suất chiếu đã bị sửa hoặc xoá kể từ lúc hiển thị sơ đồ ghế (BR-54)] | - | - | Bao các message của fragment |
| SD4-F3 | Fragment | break [không thuộc 7c, 7d, 7a; thiếu giá cho ít nhất một ghế (BR-72)] | - | - | Bao các message của fragment |
| SD4-N1 | Note | Điểm rẽ: sau message 2.1.4 của SD1a; thao tác giữ ghế không để lại thay đổi nào. Thứ tự kiểm 7c, 7d, 7a (SD5), 7e | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 2.1.4c.1 | :BookTicketsController | :BookTicketsForm | // notifyRefusal (đang có lần giữ ghế chưa kết thúc, BR-04) | Đồng bộ | SD4-F1 | 7c |
| 2.1.4d.1 | :BookTicketsController | :BookTicketsForm | // notifyRefusal (suất chiếu đã thay đổi hoặc không còn, BR-54) | Đồng bộ | SD4-F2 | 7d |
| 2.1.4e.1 | :BookTicketsController | :BookTicketsForm | // notifyRefusal (không xác định được giá vé, BR-72) | Đồng bộ | SD4-F3 | 7e |

### SD5 - Luồng 7a

a) Luồng thể hiện: Có ghế đã chọn không còn trống, không giữ ghế nào, quay lại bước 3.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD5-L-BF | Lifeline | :BookTicketsForm | «boundary» | - | AC-B-BookTicketsForm |
| SD5-L-C | Lifeline | :BookTicketsController | «control» | - | AC-C-BookTicketsController |
| SD5-F1 | Fragment | alt [có ghế đã chọn không còn trống (BR-07, BR-09)] | - | - | Bao các message của fragment |
| SD5-F1-O2 | Fragment | [mọi ghế đã chọn còn trống] | - | SD5-F1 | Toán hạng thứ hai; đường ngăn là edge SD5-F1-O2-SEP nét đứt |
| SD5-N1 | Note | Điểm rẽ: sau message 2.1.4 của SD1a, sau khi loại 7c và 7d (SD4) | - | - | Chú thích |
| SD5-N2 | Note | quay lại bước 3 | - | - | Chú thích |
| SD5-N3 | Note | tiếp tục luồng chính | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 2.1.4a.1 | :BookTicketsController | :BookTicketsForm | // notifyRefusal (các ghế không còn trống, BR-07) | Đồng bộ | SD5-F1 | 7a |

### SD6 - Luồng 7b

a) Luồng thể hiện: Hết hạn giữ ghế, kết thúc lần giữ ghế (nếu chưa Hết hạn) và giải phóng ghế; việc giải phóng chạy lại được an toàn trên lần giữ ghế đã được báo thanh toán đến muộn chuyển sang Hết hạn.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD6-L-BF | Lifeline | :BookTicketsForm | «boundary» | - | AC-B-BookTicketsForm |
| SD6-L-WF | Lifeline | w:BookTicketsForm | «boundary» | - | Boundary của khách khác đang xem sơ đồ ghế (AC-B-BookTicketsForm) |
| SD6-L-C | Lifeline | :BookTicketsController | «control» | - | AC-C-BookTicketsController |
| SD6-L-SH | Lifeline | :SeatHold | «entity» | - | AC-E-SeatHold |
| SD6-L-SS | Lifeline | :SeatStatus | «entity» | - | AC-E-SeatStatus |
| SD6-F1 | Fragment | loop [mỗi ghế đang giữ] | - | SD6-F2 | Bao các message của fragment |
| SD6-F2 | Fragment | opt [lần giữ ghế ở trạng thái Hết hạn, vừa chuyển hoặc đã chuyển từ trước do báo thanh toán đến muộn] | - | - | Bao các message của fragment |
| SD6-R1 | Fragment | ref SD1b - Luồng chính bước 8 đến 12 | - | - | ref |
| SD6-N1 | Note | Có thể xảy ra tại bất kỳ message nào từ 2.1.5 đến trước 4.1 (bước 8 đến bước 11) | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 2.1.5(7b).1 | :BookTicketsController | :BookTicketsController | // after(BR-10) handleHoldExpired | Tự gọi | - | 7b |
| 2.1.5(7b).2 | :BookTicketsController | :SeatHold | // expire (thời điểm hiện tại) | Đồng bộ | - | 7b |
| 2.1.5(7b).2.1 | :SeatHold | :SeatHold | // checkHoldStillActive (thời điểm hiện tại) | Tự gọi | - | 7b |
| 2.1.5(7b).2.2 | :SeatHold | :SeatHold | // endHold (Hết hạn, nếu còn Đang giữ) | Tự gọi | - | 7b |
| 2.1.5(7b).2 (trả về) | :SeatHold | :BookTicketsController | trạng thái lần giữ ghế: Hết hạn hoặc trạng thái cuối khác | Trả về | - | 7b |
| 2.1.5(7b).3 | :BookTicketsController | :SeatHold | // releaseHeldSeats (chậm nhất 1 phút sau thời điểm hết hạn) | Đồng bộ | SD6-F2 | 7b |
| 2.1.5(7b).3.1 | :SeatHold | :SeatStatus | // releaseSeat | Đồng bộ | SD6-F1 | 7b |
| 2.1.5(7b).4 | :BookTicketsController | w:BookTicketsForm | // updateSeatMap (ghế đã trống) | Đồng bộ | SD6-F2 | 7b |
| 2.1.5(7b).5 | :BookTicketsController | :BookTicketsForm | // notifyRefusal (hết thời gian giữ ghế) | Đồng bộ | SD6-F2 | 7b |

### SD7 - Luồng *a

a) Luồng thể hiện: Tác nhân huỷ việc giữ ghế, kết thúc lần giữ ghế và giải phóng ghế.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD7-L-K | Actor | :Khách | - | - | Tác nhân (ACT-01) |
| SD7-L-BF | Lifeline | :BookTicketsForm | «boundary» | - | AC-B-BookTicketsForm |
| SD7-L-WF | Lifeline | w:BookTicketsForm | «boundary» | - | Boundary của khách khác đang xem sơ đồ ghế (AC-B-BookTicketsForm) |
| SD7-L-C | Lifeline | :BookTicketsController | «control» | - | AC-C-BookTicketsController |
| SD7-L-SH | Lifeline | :SeatHold | «entity» | - | AC-E-SeatHold |
| SD7-L-SS | Lifeline | :SeatStatus | «entity» | - | AC-E-SeatStatus |
| SD7-F1 | Fragment | loop [mỗi ghế đang giữ] | - | - | Bao các message của fragment |
| SD7-R1 | Fragment | ref SD1b - Luồng chính bước 8 đến 12 | - | - | ref |
| SD7-N1 | Note | Có thể xảy ra tại bất kỳ message nào từ 2.1.7 đến trước 4.1 (bước 8 đến trước bước 11). Giao dịch báo thành công sau đó được PaymentReportController chuyển thành thanh toán trễ chờ hoàn (UC-006, BR-15) | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 2.1.7(*a) | :Khách | :BookTicketsForm | // cancelSeatHold | Đồng bộ | - | *a |
| 2.1.7(*a).1 | :BookTicketsForm | :BookTicketsController | // cancelSeatHold | Đồng bộ | - | *a |
| 2.1.7(*a).1.1 | :BookTicketsController | :BookTicketsController | // stopWaitingForHoldExpiry | Tự gọi | - | *a |
| 2.1.7(*a).1.2 | :BookTicketsController | :SeatHold | // cancel (thời điểm hiện tại) | Đồng bộ | - | *a |
| 2.1.7(*a).1.2.1 | :SeatHold | :SeatHold | // checkHoldStillActive (thời điểm hiện tại) | Tự gọi | - | *a |
| 2.1.7(*a).1.2.2 | :SeatHold | :SeatHold | // endHold (Đã huỷ) | Tự gọi | - | *a |
| 2.1.7(*a).1.3 | :BookTicketsController | :SeatHold | // releaseHeldSeats | Đồng bộ | - | *a |
| 2.1.7(*a).1.3.1 | :SeatHold | :SeatStatus | // releaseSeat | Đồng bộ | SD7-F1 | *a |
| 2.1.7(*a).1.4 | :BookTicketsController | w:BookTicketsForm | // updateSeatMap (ghế đã trống) | Đồng bộ | - | *a |

### SD8 - Luồng 10a

a) Luồng thể hiện: Cổng thanh toán từ chối hoặc không trả lời yêu cầu tạo giao dịch.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD8-L-BF | Lifeline | :BookTicketsForm | «boundary» | - | AC-B-BookTicketsForm |
| SD8-L-C | Lifeline | :BookTicketsController | «control» | - | AC-C-BookTicketsController |
| SD8-F1 | Fragment | alt [cổng từ chối hoặc không trả lời trong 30 giây (BR-90)] | - | - | Bao các message của fragment |
| SD8-F1-O2 | Fragment | [cổng tạo được giao dịch] | - | SD8-F1 | Toán hạng thứ hai; đường ngăn là edge SD8-F1-O2-SEP nét đứt |
| SD8-N1 | Note | Điểm rẽ: sau message 3.1.1 của SD1b; thời điểm hết hạn giữ ghế không đổi | - | - | Chú thích |
| SD8-N2 | Note | quay lại bước 9 | - | - | Chú thích |
| SD8-N3 | Note | tiếp tục luồng chính | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 3.1.1a.1 | :BookTicketsController | :BookTicketsForm | // notifyRefusal (chưa tạo được thanh toán, BR-90) | Đồng bộ | SD8-F1 | 10a |

### SD9 - Luồng 11a

a) Luồng thể hiện: Cổng báo giao dịch thất bại, kết thúc lần giữ ghế và giải phóng ghế.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD9-L-BF | Lifeline | :BookTicketsForm | «boundary» | - | AC-B-BookTicketsForm |
| SD9-L-WF | Lifeline | w:BookTicketsForm | «boundary» | - | Boundary của khách khác đang xem sơ đồ ghế (AC-B-BookTicketsForm) |
| SD9-L-PC | Lifeline | :PaymentReportController | «control» | - | AC-C-PaymentReportController |
| SD9-L-SH | Lifeline | :SeatHold | «entity» | - | AC-E-SeatHold |
| SD9-L-SS | Lifeline | :SeatStatus | «entity» | - | AC-E-SeatStatus |
| SD9-L-PT | Lifeline | :PaymentTransaction | «entity» | - | AC-E-PaymentTransaction |
| SD9-L-PG | Lifeline | :PaymentGateway | «boundary» | - | AC-B-PaymentGateway |
| SD9-L-A7 | Actor | :Cổng thanh toán | - | - | Tác nhân (ACT-07) |
| SD9-F1 | Fragment | break [cổng báo giao dịch thanh toán thất bại và lần giữ ghế còn Đang giữ, chưa quá thời điểm hết hạn] | - | - | Bao các message của fragment |
| SD9-N1 | Note | Điểm rẽ: thay cho message 4 của SD1b khi cổng báo thất bại. Lần giữ ghế đã kết thúc thì kết quả thất bại chỉ được ghi nhận và thuộc UC-006 | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 4a | :Cổng thanh toán | :PaymentGateway | // reportTransactionResult (thất bại, mã giao dịch, mã tham chiếu lần giữ ghế) | Đồng bộ | SD9-F1 | 11a |
| 4a.1 | :PaymentGateway | :PaymentReportController | // handlePaymentReport (thất bại, mã giao dịch, mã tham chiếu lần giữ ghế, thời điểm nhận báo) | Đồng bộ | SD9-F1 | 11a |
| 4a.1.1 | :PaymentReportController | :SeatHold | // settlePaymentReport (lần giữ ghế tìm theo mã giao dịch hoặc mã tham chiếu lần giữ ghế, kết quả, thời điểm nhận báo) | Đồng bộ | SD9-F1 | 11a |
| 4a.1.1.1 | :SeatHold | :SeatHold | // checkHoldStillActive (thời điểm nhận báo) | Tự gọi | SD9-F1 | 11a |
| 4a.1.1.2 | :SeatHold | :PaymentTransaction | // recordFailedResult | Đồng bộ | SD9-F1 | 11a |
| 4a.1.1.3 | :SeatHold | :SeatHold | // endHold (Thanh toán thất bại) | Tự gọi | SD9-F1 | 11a |
| 4a.1.1 (trả về) | :SeatHold | :PaymentReportController | kết quả: thất bại ghi nhận, lần giữ ghế vừa kết thúc và còn ghế đang giữ | Trả về | SD9-F1 | 11a |
| 4a.1.2 | :PaymentReportController | :SeatHold | // releaseHeldSeats | Đồng bộ | SD9-F1 | 11a |
| 4a.1.2.1 | :SeatHold | :SeatStatus | // releaseSeat | Đồng bộ | SD9-F1 | 11a |
| 4a.1.3 | :PaymentReportController | w:BookTicketsForm | // updateSeatMap (ghế đã trống) | Đồng bộ | SD9-F1 | 11a |
| 4a.1.4 | :PaymentReportController | :BookTicketsForm | // notifyRefusal (thanh toán không thành công) | Đồng bộ | SD9-F1 | 11a |

### SD10 - Báo thành công khi lần giữ ghế đã quá thời điểm hết hạn hoặc đã kết thúc

a) Luồng thể hiện: Báo thành công đến sau thời điểm hết hạn hoặc sau trạng thái cuối: chuyển Hết hạn nếu còn Đang giữ, trả kết quả không phải bán ghế cho điểm tiếp nhận (BR-14, BR-15, BR-37, BR-86).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD10-L-PC | Lifeline | :PaymentReportController | «control» | - | AC-C-PaymentReportController |
| SD10-L-SH | Lifeline | :SeatHold | «entity» | - | AC-E-SeatHold |
| SD10-F1 | Fragment | break [lần giữ ghế ở trạng thái Đang giữ nhưng đã quá thời điểm hết hạn (BR-14, BR-86)] | - | - | Bao các message của fragment |
| SD10-N1 | Note | Điểm rẽ: trong message 4.1.1 của SD1b, tại 4.1.1.2 (checkHoldStillActive) | - | - | Chú thích |
| SD10-N2 | Note | Lần giữ ghế được chuyển sang Hết hạn trước khi ghi nhận kết quả; ghế được giải phóng bởi sự kiện hết hạn của luồng 7b (SD6), chạy lại được an toàn. Kết quả trả về là thanh toán trễ chờ hoàn, báo trùng hoặc thất bại ghi nhận; phần tiếp theo thuộc UC-006, cùng PaymentReportController. | - | - | Chú thích |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 4.1.1.2x.1 | :SeatHold | :SeatHold | // expire (thời điểm nhận báo, nếu còn Đang giữ nhưng đã quá thời điểm hết hạn) | Tự gọi | SD10-F1 | 12 |
| 4.1.1 (trả về) | :SeatHold | :PaymentReportController | kết quả: thanh toán trễ chờ hoàn, báo trùng hoặc thất bại ghi nhận (UC-006) | Trả về | SD10-F1 | 12 |

### SD11a - Biến thể ACT-02, bước 1 đến 2 và luồng 2a, 2b, 2c

a) Luồng thể hiện: Nhân viên quầy chọn suất chiếu, kiểm tra mở bán, giờ bắt đầu và cụm rạp.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD11a-L-K2 | Actor | :Nhân viên quầy | - | - | Tác nhân (ACT-02) |
| SD11a-L-CF | Lifeline | :CounterBookTicketsForm | «boundary» | - | AC-B-CounterBookTicketsForm |
| SD11a-L-C | Lifeline | :BookTicketsController | «control» | - | AC-C-BookTicketsController |
| SD11a-L-ST | Lifeline | :Showtime | «entity» | - | AC-E-Showtime |
| SD11a-F1 | Fragment | break [suất chiếu chưa tới thời điểm mở bán (BR-01)] | - | - | Bao các message của fragment |
| SD11a-F2 | Fragment | break [suất chiếu không thuộc cụm rạp của nhân viên quầy (BR-02)] | - | - | Bao các message của fragment |
| SD11a-F3 | Fragment | break [suất chiếu đã tới giờ bắt đầu (BR-45), không thuộc 2b] | - | - | Bao các message của fragment |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1[ACT-02] | :Nhân viên quầy | :CounterBookTicketsForm | // selectShowtime (suất chiếu) | Đồng bộ | - | 1 |
| 1.1[ACT-02] | :CounterBookTicketsForm | :BookTicketsController | // startBooking (suất chiếu) | Đồng bộ | - | 1 |
| 1.1.1[ACT-02] | :BookTicketsController | :Showtime | // checkSaleOpen (thời điểm hiện tại) | Đồng bộ | - | 2 |
| 1.1.1a.1[ACT-02] | :BookTicketsController | :CounterBookTicketsForm | // notifyRefusal (chưa tới thời điểm mở bán, BR-01) | Đồng bộ | SD11a-F1 | 2a |
| 1.1.1b | :BookTicketsController | :Showtime | // checkBelongsToCinema (cụm rạp của nhân viên quầy) | Đồng bộ | - | 2 |
| 1.1.1b.1 | :BookTicketsController | :CounterBookTicketsForm | // notifyRefusal (khác cụm rạp, BR-02) | Đồng bộ | SD11a-F2 | 2b |
| 1.1.1c.1[ACT-02] | :BookTicketsController | :CounterBookTicketsForm | // notifyRefusal (suất chiếu đã bắt đầu, BR-45) | Đồng bộ | SD11a-F3 | 2c |

### SD11b - Biến thể ACT-02, bước 3 đến 7

a) Luồng thể hiện: Nhân viên quầy xem sơ đồ ghế, chọn ghế và giữ ghế (không có kiểm tra đăng nhập).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD11b-L-K2 | Actor | :Nhân viên quầy | - | - | Tác nhân (ACT-02) |
| SD11b-L-WF | Lifeline | w:BookTicketsForm | «boundary» | - | Boundary của khách khác đang xem sơ đồ ghế (AC-B-BookTicketsForm) |
| SD11b-L-CF | Lifeline | :CounterBookTicketsForm | «boundary» | - | AC-B-CounterBookTicketsForm |
| SD11b-L-C | Lifeline | :BookTicketsController | «control» | - | AC-C-BookTicketsController |
| SD11b-L-CL | Lifeline | :BoxOfficeClerk | «entity» | - | AC-E-BoxOfficeClerk |
| SD11b-L-ST | Lifeline | :Showtime | «entity» | - | AC-E-Showtime |
| SD11b-L-PL | Lifeline | :PriceList | «entity» | - | AC-E-PriceList |
| SD11b-L-SH | Lifeline | :SeatHold | «entity» | - | Đỉnh lifeline đặt ngang message Tạo |
| SD11b-L-SS | Lifeline | :SeatStatus | «entity» | - | AC-E-SeatStatus |
| SD11b-F1 | Fragment | loop [mỗi ghế của sơ đồ ghế] | - | - | Bao các message của fragment |
| SD11b-F2 | Fragment | loop [mỗi ghế đã chọn] | - | - | Bao các message của fragment |
| SD11b-F3 | Fragment | loop [mỗi ghế đã chọn] | - | - | Bao các message của fragment |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1.1.2[ACT-02] | :BookTicketsController | :Showtime | // provideSeatMap | Đồng bộ | - | 3 |
| 1.1.2.1[ACT-02] | :Showtime | :SeatStatus | // provideSeatStatus (vị trí, loại ghế, trạng thái ghế) | Đồng bộ | SD11b-F1 | 3 |
| 1.1.2[ACT-02] (trả về) | :Showtime | :BookTicketsController | sơ đồ ghế kèm trạng thái ghế | Trả về | - | 3 |
| 1.1.3[ACT-02] | :BookTicketsController | :CounterBookTicketsForm | // showSeatMap (suất chiếu, sơ đồ ghế) | Đồng bộ | - | 3 |
| 2[ACT-02] | :Nhân viên quầy | :CounterBookTicketsForm | // confirmSeatSelection (các ghế đã chọn) | Đồng bộ | - | 4 |
| 2.1[ACT-02] | :CounterBookTicketsForm | :BookTicketsController | // requestSeatHold (các ghế đã chọn) | Đồng bộ | - | 4 |
| 2.1.2[ACT-02] | :BookTicketsController | :BoxOfficeClerk | // checkNoActiveSeatHold | Đồng bộ | - | 5 |
| 2.1.3[ACT-02] | :BookTicketsController | :Showtime | // checkSeatSelectionLimit (các ghế đã chọn) | Đồng bộ | - | 6 |
| 2.1.4[ACT-02] | :BookTicketsController | :Showtime | // holdSeats (nhân viên quầy, các ghế đã chọn, mốc hiển thị sơ đồ ghế) | Đồng bộ | - | 7 |
| 2.1.4.1[ACT-02] | :Showtime | :SeatHold | «create» // createSeatHold (nhân viên quầy, suất chiếu) | Tạo | - | 7 |
| 2.1.4.1.1[ACT-02] | :SeatHold | :BoxOfficeClerk | // checkNoActiveSeatHold | Đồng bộ | - | 7 |
| 2.1.4.2[ACT-02] | :Showtime | :Showtime | // checkUnchangedSinceDisplayed (mốc hiển thị sơ đồ ghế) | Tự gọi | - | 7 |
| 2.1.4.3[ACT-02] | :Showtime | :SeatStatus | // holdSeatFor (lần giữ ghế) | Đồng bộ | SD11b-F2 | 7 |
| 2.1.4.4[ACT-02] | :Showtime | :PriceList | // determineSeatPrice (loại phòng, định dạng phim, loại ghế, giờ bắt đầu) | Đồng bộ | SD11b-F3 | 7 |
| 2.1.4.4[ACT-02] (trả về) | :PriceList | :Showtime | giá vé của ghế | Trả về | SD11b-F3 | 7 |
| 2.1.4.5[ACT-02] | :Showtime | :SeatStatus | // recordHeldPrice (giá vé) | Đồng bộ | SD11b-F3 | 7 |
| 2.1.4[ACT-02] (trả về) | :Showtime | :BookTicketsController | lần giữ ghế đã tạo | Trả về | - | 7 |
| 2.1.5[ACT-02] | :BookTicketsController | :BookTicketsController | // startWaitingForHoldExpiry (BR-10) | Tự gọi | - | 7 |
| 2.1.6[ACT-02] | :BookTicketsController | w:BookTicketsForm | // updateSeatMap (ghế đã được giữ) | Đồng bộ | - | 3 |

### SD11c - Biến thể ACT-02, bước 8, 9a1

a) Luồng thể hiện: Hiển thị ghế đã giữ, nhân viên quầy xác nhận đã thu tiền mặt.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD11c-L-K2 | Actor | :Nhân viên quầy | - | - | Tác nhân (ACT-02) |
| SD11c-L-CF | Lifeline | :CounterBookTicketsForm | «boundary» | - | AC-B-CounterBookTicketsForm |
| SD11c-L-C | Lifeline | :BookTicketsController | «control» | - | AC-C-BookTicketsController |
| SD11c-L-SH | Lifeline | :SeatHold | «entity» | - | AC-E-SeatHold |
| SD11c-L-SS | Lifeline | :SeatStatus | «entity» | - | AC-E-SeatStatus |
| SD11c-F1 | Fragment | loop [mỗi ghế đã giữ] | - | - | Bao các message của fragment |
| SD11c-R1 | Fragment | ref SD11b - Biến thể ACT-02, bước 3 đến 7 | - | - | ref |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 2.1.7[ACT-02] | :BookTicketsController | :SeatHold | // provideHoldSummary | Đồng bộ | - | 8 |
| 2.1.7.1[ACT-02] | :SeatHold | :SeatStatus | // provideHeldSeatInfo (vị trí, loại ghế, giá vé đã chốt) | Đồng bộ | SD11c-F1 | 8 |
| 2.1.7.2[ACT-02] | :SeatHold | :SeatHold | // calculateTotalAmount | Tự gọi | - | 8 |
| 2.1.7[ACT-02] (trả về) | :SeatHold | :BookTicketsController | các ghế đã giữ, giá vé từng ghế, tổng tiền | Trả về | - | 8 |
| 2.1.8[ACT-02] | :BookTicketsController | :CounterBookTicketsForm | // showHeldSeats (ghế đã giữ, giá vé từng ghế, tổng tiền) | Đồng bộ | - | 8 |
| 3a | :Nhân viên quầy | :CounterBookTicketsForm | // confirmCashReceived | Đồng bộ | - | 9a1 |
| 3a.1 | :CounterBookTicketsForm | :BookTicketsController | // confirmCashReceived | Đồng bộ | - | 9a1 |
| 3a.1.1 | :BookTicketsController | :BookTicketsController | // stopWaitingForHoldExpiry | Tự gọi | - | 9a1 |
| 3a.1.2 | :BookTicketsController | :SeatHold | // completeSaleOnCashConfirmation (thời điểm xác nhận) | Đồng bộ | - | 9a2 |
| 3a.1.2.1 | :SeatHold | :SeatHold | // checkHoldStillActive (thời điểm xác nhận) | Tự gọi | - | 9a2 |

### SD11d - Biến thể ACT-02, bước 9a2 và luồng 9a1a

a) Luồng thể hiện: So thời điểm xác nhận với thời điểm hết hạn, bán ghế hoặc từ chối xác nhận.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD11d-L-CF | Lifeline | :CounterBookTicketsForm | «boundary» | - | AC-B-CounterBookTicketsForm |
| SD11d-L-C | Lifeline | :BookTicketsController | «control» | - | AC-C-BookTicketsController |
| SD11d-L-SH | Lifeline | :SeatHold | «entity» | - | AC-E-SeatHold |
| SD11d-L-SS | Lifeline | :SeatStatus | «entity» | - | AC-E-SeatStatus |
| SD11d-F1 | Fragment | break [xác nhận đã thu tiền sau thời điểm hết hạn giữ ghế (BR-10, BR-44)] | - | - | Bao các message của fragment |
| SD11d-F2 | Fragment | loop [mỗi ghế đang giữ] | - | - | Bao các message của fragment |
| SD11d-R1 | Fragment | ref SD11c - Biến thể ACT-02, bước 8, 9a1 | - | - | ref |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 3a.1.2.1a.1 | :SeatHold | :SeatHold | // endHold (Hết hạn, nếu còn Đang giữ) | Tự gọi | SD11d-F1 | 9a1a |
| 3a.1.2.1a.2 | :BookTicketsController | :CounterBookTicketsForm | // notifyRefusal (từ chối xác nhận, trả lại tiền mặt đã thu cho khách, BR-44) | Đồng bộ | SD11d-F1 | 9a1a |
| 3a.1.2.2 | :SeatHold | :SeatStatus | // markSold | Đồng bộ | SD11d-F2 | 9a2 |
| 3a.1.2.3 | :SeatHold | :SeatHold | // endHold (Đã hoàn tất) | Tự gọi | - | 9a2 |

### SD11e - Biến thể ACT-02, bước 9a3 đến 9a5

a) Luồng thể hiện: Tạo mã đặt vé và vé trong cùng thao tác bán ghế tại quầy, hiển thị để in, nhân viên quầy in vé.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD11e-L-K2 | Actor | :Nhân viên quầy | - | - | Tác nhân (ACT-02) |
| SD11e-L-WF | Lifeline | w:BookTicketsForm | «boundary» | - | Boundary của khách khác đang xem sơ đồ ghế (AC-B-BookTicketsForm) |
| SD11e-L-CF | Lifeline | :CounterBookTicketsForm | «boundary» | - | AC-B-CounterBookTicketsForm |
| SD11e-L-C | Lifeline | :BookTicketsController | «control» | - | AC-C-BookTicketsController |
| SD11e-L-SH | Lifeline | :SeatHold | «entity» | - | AC-E-SeatHold |
| SD11e-L-BK | Lifeline | :Booking | «entity» | - | Đỉnh lifeline đặt ngang message Tạo |
| SD11e-L-TK | Lifeline | :Ticket | «entity» | - | Đỉnh lifeline đặt ngang message Tạo |
| SD11e-F1 | Fragment | loop [mỗi ghế đã bán] | - | - | Bao các message của fragment |
| SD11e-F2 | Fragment | loop [mỗi vé của lần đặt] | - | - | Bao các message của fragment |
| SD11e-R1 | Fragment | ref SD11d - Biến thể ACT-02, bước 9a2 và luồng 9a1a | - | - | ref |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 3a.1.2.4 | :SeatHold | :SeatHold | // issueBooking | Tự gọi | - | 9a3 |
| 3a.1.2.4.1 | :SeatHold | :Booking | «create» // createBooking (suất chiếu, các ghế đã bán) | Tạo | - | 9a3 |
| 3a.1.2.4.1.1 | :Booking | :Booking | // generateBookingCode (BR-80) | Tự gọi | - | 9a3 |
| 3a.1.2.4.1.2 | :Booking | :Ticket | «create» // createTicket (ghế, giá vé đã chốt, suất chiếu) | Tạo | SD11e-F1 | 9a3 |
| 3a.1.2.4.1.2.1 | :Ticket | :Ticket | // generateQrCode | Tự gọi | SD11e-F1 | 9a3 |
| 3a.1.2 (trả về) | :SeatHold | :BookTicketsController | lần giữ ghế đã hoàn tất kèm lần đặt | Trả về | - | 9a2, 9a3 |
| 3a.1.3 | :BookTicketsController | w:BookTicketsForm | // updateSeatMap (ghế đã bán) | Đồng bộ | - | 3 |
| 3a.1.4 | :BookTicketsController | :Booking | // provideBookingInfo | Đồng bộ | - | 9a4 |
| 3a.1.4.1 | :Booking | :Ticket | // provideTicketContent | Đồng bộ | SD11e-F2 | 9a4 |
| 3a.1.4 (trả về) | :Booking | :BookTicketsController | mã đặt vé và các vé | Trả về | - | 9a4 |
| 3a.1.5 | :BookTicketsController | :CounterBookTicketsForm | // showTicketsForPrint (mã đặt vé, các vé) | Đồng bộ | - | 9a4 |
| 3a.2 | :Nhân viên quầy | :CounterBookTicketsForm | // printTickets | Đồng bộ | - | 9a5 |

## 6. Quy tắc tương tác giữa các lớp phân tích

| Vi phạm | Message hoặc link | Cách sửa đã áp dụng |
|---|---|---|
| Không có | - | - |

## 7. Communication diagram

File diagrams/P07-communication-UC-005.drawio có 3 trang: trang CM1 cho luồng chính (SD1a, SD1b, SD1c), trang CM2 cho mọi luồng thay thế và ngoại lệ (SD2 đến SD10), trang CM3 cho biến thể ACT-02 (SD11a đến SD11e), giữ nguyên STT của sequence diagram. Message trả về không vẽ. Message ghi kèm guard trong ngoặc vuông khi nằm trong fragment alt, break hoặc loop. ID cell của đối tượng là "<ID trang>-O-<khoá>", ID cell của link là ID trong bảng Edge.

### Trang CM1 - Luồng chính (SD1a, SD1b, SD1c)

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| CM1-O-K | Actor | :Khách | - | - | Tác nhân (ACT-01) |
| CM1-O-BF | Object | :BookTicketsForm | «boundary» | - | AC-B-BookTicketsForm |
| CM1-O-WF | Object | w:BookTicketsForm | «boundary» | - | Boundary của khách khác đang xem sơ đồ ghế (AC-B-BookTicketsForm) |
| CM1-O-C | Object | :BookTicketsController | «control» | - | AC-C-BookTicketsController |
| CM1-O-CU | Object | :Customer | «entity» | - | AC-E-Customer |
| CM1-O-ST | Object | :Showtime | «entity» | - | AC-E-Showtime |
| CM1-O-PL | Object | :PriceList | «entity» | - | AC-E-PriceList |
| CM1-O-SH | Object | :SeatHold | «entity» | - | Đỉnh lifeline đặt ngang message Tạo |
| CM1-O-SS | Object | :SeatStatus | «entity» | - | AC-E-SeatStatus |
| CM1-O-PC | Object | :PaymentReportController | «control» | - | AC-C-PaymentReportController |
| CM1-O-PT | Object | :PaymentTransaction | «entity» | - | Đỉnh lifeline đặt ngang message Tạo |
| CM1-O-PG | Object | :PaymentGateway | «boundary» | - | AC-B-PaymentGateway |
| CM1-O-A7 | Actor | :Cổng thanh toán | - | - | Tác nhân (ACT-07) |
| CM1-O-BK | Object | :Booking | «entity» | - | Đỉnh lifeline đặt ngang message Tạo |
| CM1-O-TK | Object | :Ticket | «entity» | - | Đỉnh lifeline đặt ngang message Tạo |
| CM1-O-ES | Object | :EmailService | «boundary» | - | AC-B-EmailService |
| CM1-O-A8 | Actor | :Dịch vụ email | - | - | Tác nhân (ACT-08) |

b) Bảng Edge

| ID | Nguồn | Đích | Loại | Nhãn | Chiều message |
|---|---|---|---|---|---|
| CM1-L1 | CM1-O-K | CM1-O-BF | Link | 1: // selectShowtime (suất chiếu) (-->)<br>2: // confirmSeatSelection (các ghế đã chọn) (-->)<br>3: // requestOnlinePayment (-->) | Nguồn-->Đích: 1, 2, 3 |
| CM1-L2 | CM1-O-BF | CM1-O-C | Link | 1.1: // startBooking (suất chiếu) (-->)<br>1.1.3: // showSeatMap (suất chiếu, sơ đồ ghế) (<--)<br>2.1: // requestSeatHold (các ghế đã chọn, khách đã đăng nhập nếu có) (-->)<br>2.1.8: // showHeldSeats (ghế đã giữ, giá vé từng ghế, tổng tiền) (<--)<br>3.1: // startOnlinePayment (-->) | Nguồn-->Đích: 1.1, 2.1, 3.1; Đích-->Nguồn: 1.1.3, 2.1.8 |
| CM1-L3 | CM1-O-C | CM1-O-ST | Link | 1.1.1: // checkSaleOpen (thời điểm hiện tại) (-->)<br>1.1.2: // provideSeatMap (-->)<br>2.1.3: // checkSeatSelectionLimit (các ghế đã chọn) (-->)<br>2.1.4: // holdSeats (khách, các ghế đã chọn, mốc hiển thị sơ đồ ghế) (-->) | Nguồn-->Đích: 1.1.1, 1.1.2, 2.1.3, 2.1.4 |
| CM1-L4 | CM1-O-ST | CM1-O-SS | Link | 1.1.2.1: // provideSeatStatus (vị trí, loại ghế, trạng thái ghế) (-->) [lặp: mỗi ghế của sơ đồ ghế]<br>2.1.4.3: // holdSeatFor (lần giữ ghế) (-->) [lặp: mỗi ghế đã chọn]<br>2.1.4.5: // recordHeldPrice (giá vé) (-->) [lặp: mỗi ghế đã chọn] | Nguồn-->Đích: 1.1.2.1, 2.1.4.3, 2.1.4.5 |
| CM1-L5 | CM1-O-C | CM1-O-C | Link | 2.1.1: // checkCustomerLoggedIn (-->)<br>2.1.5: // startWaitingForHoldExpiry (BR-10) (-->) | Nguồn-->Đích: 2.1.1, 2.1.5 |
| CM1-L6 | CM1-O-C | CM1-O-CU | Link | 2.1.2: // checkNoActiveSeatHold (-->) | Nguồn-->Đích: 2.1.2 |
| CM1-L7 | CM1-O-ST | CM1-O-SH | Link | 2.1.4.1: «create» // createSeatHold (khách, suất chiếu) (-->) | Nguồn-->Đích: 2.1.4.1 |
| CM1-L8 | CM1-O-SH | CM1-O-CU | Link | 2.1.4.1.1: // checkNoActiveSeatHold (-->) | Nguồn-->Đích: 2.1.4.1.1 |
| CM1-L9 | CM1-O-ST | CM1-O-ST | Link | 2.1.4.2: // checkUnchangedSinceDisplayed (mốc hiển thị sơ đồ ghế) (-->) | Nguồn-->Đích: 2.1.4.2 |
| CM1-L10 | CM1-O-ST | CM1-O-PL | Link | 2.1.4.4: // determineSeatPrice (loại phòng, định dạng phim, loại ghế, giờ bắt đầu) (-->) [lặp: mỗi ghế đã chọn] | Nguồn-->Đích: 2.1.4.4 |
| CM1-L11 | CM1-O-C | CM1-O-WF | Link | 2.1.6: // updateSeatMap (ghế đã được giữ) (-->) | Nguồn-->Đích: 2.1.6 |
| CM1-L12 | CM1-O-C | CM1-O-SH | Link | 2.1.7: // provideHoldSummary (-->)<br>3.1.2: // recordPaymentTransaction (mã giao dịch, tổng tiền) (-->) | Nguồn-->Đích: 2.1.7, 3.1.2 |
| CM1-L13 | CM1-O-SH | CM1-O-SS | Link | 2.1.7.1: // provideHeldSeatInfo (vị trí, loại ghế, giá vé đã chốt) (-->) [lặp: mỗi ghế đã giữ]<br>4.1.1.4: // markSold (-->) [lặp: mỗi ghế đang giữ] | Nguồn-->Đích: 2.1.7.1, 4.1.1.4 |
| CM1-L14 | CM1-O-SH | CM1-O-SH | Link | 2.1.7.2: // calculateTotalAmount (-->)<br>4.1.1.2: // checkHoldStillActive (thời điểm nhận báo) (-->)<br>4.1.1.5: // endHold (Đã hoàn tất) (-->)<br>4.1.1.6: // issueBooking (-->) | Nguồn-->Đích: 2.1.7.2, 4.1.1.2, 4.1.1.5, 4.1.1.6 |
| CM1-L15 | CM1-O-C | CM1-O-PG | Link | 3.1.1: // createPaymentTransaction (tổng tiền, mã tham chiếu lần giữ ghế) (-->) | Nguồn-->Đích: 3.1.1 |
| CM1-L16 | CM1-O-PG | CM1-O-A7 | Link | 3.1.1.1: // createPaymentTransaction (tổng tiền, mã tham chiếu lần giữ ghế) (-->)<br>4: // reportTransactionResult (thành công, mã giao dịch, mã tham chiếu lần giữ ghế, số tiền đã thanh toán) (<--) | Nguồn-->Đích: 3.1.1.1; Đích-->Nguồn: 4 |
| CM1-L17 | CM1-O-SH | CM1-O-PT | Link | 3.1.2.1: «create» // createPaymentTransaction (mã giao dịch, số tiền) (-->)<br>4.1.1.1: // checkNotProcessed (mã giao dịch) (-->)<br>4.1.1.3: // markProcessed (mã giao dịch) (-->) | Nguồn-->Đích: 3.1.2.1, 4.1.1.1, 4.1.1.3 |
| CM1-L18 | CM1-O-PG | CM1-O-PC | Link | 4.1: // handlePaymentReport (thành công, mã giao dịch, mã tham chiếu lần giữ ghế, số tiền đã thanh toán, thời điểm nhận báo) (-->) | Nguồn-->Đích: 4.1 |
| CM1-L19 | CM1-O-PC | CM1-O-SH | Link | 4.1.1: // settlePaymentReport (lần giữ ghế tìm theo mã giao dịch hoặc mã tham chiếu lần giữ ghế, kết quả, số tiền đã thanh toán, thời điểm nhận báo) (-->) | Nguồn-->Đích: 4.1.1 |
| CM1-L20 | CM1-O-SH | CM1-O-BK | Link | 4.1.1.6.1: «create» // createBooking (suất chiếu, các ghế đã bán) (-->) | Nguồn-->Đích: 4.1.1.6.1 |
| CM1-L21 | CM1-O-BK | CM1-O-BK | Link | 4.1.1.6.1.1: // generateBookingCode (BR-80) (-->) | Nguồn-->Đích: 4.1.1.6.1.1 |
| CM1-L22 | CM1-O-BK | CM1-O-TK | Link | 4.1.1.6.1.2: «create» // createTicket (ghế, giá vé đã chốt, suất chiếu) (-->) [lặp: mỗi ghế đã bán]<br>4.1.4.1: // provideTicketContent (-->) [lặp: mỗi vé của lần đặt] | Nguồn-->Đích: 4.1.1.6.1.2, 4.1.4.1 |
| CM1-L23 | CM1-O-TK | CM1-O-TK | Link | 4.1.1.6.1.2.1: // generateQrCode (-->) [lặp: mỗi ghế đã bán] | Nguồn-->Đích: 4.1.1.6.1.2.1 |
| CM1-L24 | CM1-O-PC | CM1-O-WF | Link | 4.1.2: // updateSeatMap (ghế đã bán) (-->) | Nguồn-->Đích: 4.1.2 |
| CM1-L25 | CM1-O-PC | CM1-O-ES | Link | 4.1.3: // sendTicketsEmail (khách, các vé) (-->) | Nguồn-->Đích: 4.1.3 |
| CM1-L26 | CM1-O-ES | CM1-O-A8 | Link | 4.1.3.1: // sendTicketsEmail (khách, các vé) (-->) | Nguồn-->Đích: 4.1.3.1 |
| CM1-L27 | CM1-O-PC | CM1-O-BK | Link | 4.1.4: // provideBookingInfo (-->) | Nguồn-->Đích: 4.1.4 |
| CM1-L28 | CM1-O-PC | CM1-O-BF | Link | 4.1.5: // showBookingSuccess (mã đặt vé, các vé) (-->) | Nguồn-->Đích: 4.1.5 |

### Trang CM2 - Luồng thay thế và ngoại lệ (SD2 đến SD10)

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| CM2-O-BF | Object | :BookTicketsForm | «boundary» | - | AC-B-BookTicketsForm |
| CM2-O-C | Object | :BookTicketsController | «control» | - | AC-C-BookTicketsController |
| CM2-O-K | Actor | :Khách | - | - | Tác nhân (ACT-01) |
| CM2-O-CU | Object | :Customer | «entity» | - | AC-E-Customer |
| CM2-O-WF | Object | w:BookTicketsForm | «boundary» | - | Boundary của khách khác đang xem sơ đồ ghế (AC-B-BookTicketsForm) |
| CM2-O-SH | Object | :SeatHold | «entity» | - | AC-E-SeatHold |
| CM2-O-SS | Object | :SeatStatus | «entity» | - | AC-E-SeatStatus |
| CM2-O-PC | Object | :PaymentReportController | «control» | - | AC-C-PaymentReportController |
| CM2-O-PT | Object | :PaymentTransaction | «entity» | - | AC-E-PaymentTransaction |
| CM2-O-PG | Object | :PaymentGateway | «boundary» | - | AC-B-PaymentGateway |
| CM2-O-A7 | Actor | :Cổng thanh toán | - | - | Tác nhân (ACT-07) |

b) Bảng Edge

| ID | Nguồn | Đích | Loại | Nhãn | Chiều message |
|---|---|---|---|---|---|
| CM2-L1 | CM2-O-C | CM2-O-BF | Link | 1.1.1a.1: // notifyRefusal (chưa tới thời điểm mở bán, BR-01) (-->) [suất chiếu chưa tới thời điểm mở bán (BR-01)]<br>1.1.1c.1: // notifyRefusal (suất chiếu đã bắt đầu, BR-45) (-->) [suất chiếu đã tới giờ bắt đầu (BR-45)]<br>2.1.1a.1: // requestLogin (giữ nguyên các ghế đã chọn, BR-03) (-->) [khách chưa đăng nhập (5a)]<br>2.1.1a.3: // requestSeatHold (các ghế đã chọn, thông tin đăng nhập) (<--) [khách chưa đăng nhập (5a)]<br>2.1.2b.1: // notifyRefusal (đang có lần giữ ghế chưa kết thúc, BR-04) (-->) [đã có lần giữ ghế chưa kết thúc (BR-04)]<br>2.1.3a.1: // notifyRefusal (vượt số ghế tối đa, BR-05) (-->) [số ghế đã chọn vượt số ghế tối đa (BR-05, BR-06)]<br>2.1.4c.1: // notifyRefusal (đang có lần giữ ghế chưa kết thúc, BR-04) (-->) [tác nhân đang có lần giữ ghế chưa kết thúc (BR-04)]<br>2.1.4d.1: // notifyRefusal (suất chiếu đã thay đổi hoặc không còn, BR-54) (-->) [không thuộc 7c; suất chiếu đã bị sửa hoặc xoá kể từ lúc hiển thị sơ đồ ghế (BR-54)]<br>2.1.4e.1: // notifyRefusal (không xác định được giá vé, BR-72) (-->) [không thuộc 7c, 7d, 7a; thiếu giá cho ít nhất một ghế (BR-72)]<br>2.1.4a.1: // notifyRefusal (các ghế không còn trống, BR-07) (-->) [có ghế đã chọn không còn trống (BR-07, BR-09)]<br>2.1.5(7b).5: // notifyRefusal (hết thời gian giữ ghế) (-->) [lần giữ ghế ở trạng thái Hết hạn, vừa chuyển hoặc đã chuyển từ trước do báo thanh toán đến muộn]<br>2.1.7(*a).1: // cancelSeatHold (<--)<br>3.1.1a.1: // notifyRefusal (chưa tạo được thanh toán, BR-90) (-->) [cổng từ chối hoặc không trả lời trong 30 giây (BR-90)] | Nguồn-->Đích: 1.1.1a.1, 1.1.1c.1, 2.1.1a.1, 2.1.2b.1, 2.1.3a.1, 2.1.4c.1, 2.1.4d.1, 2.1.4e.1, 2.1.4a.1, 2.1.5(7b).5, 3.1.1a.1; Đích-->Nguồn: 2.1.1a.3, 2.1.7(*a).1 |
| CM2-L2 | CM2-O-K | CM2-O-BF | Link | 2.1.1a.2: // provideCredentials (email hoặc số điện thoại, mật khẩu) (-->) [khách chưa đăng nhập (5a)]<br>2.1.7(*a): // cancelSeatHold (-->) | Nguồn-->Đích: 2.1.1a.2, 2.1.7(*a) |
| CM2-L3 | CM2-O-C | CM2-O-CU | Link | 2.1.1a.4: // authenticateCustomer (email hoặc số điện thoại, mật khẩu) (-->) [khách chưa đăng nhập (5a)] | Nguồn-->Đích: 2.1.1a.4 |
| CM2-L4 | CM2-O-C | CM2-O-C | Link | 2.1.5(7b).1: // after(BR-10) handleHoldExpired (-->)<br>2.1.7(*a).1.1: // stopWaitingForHoldExpiry (-->) | Nguồn-->Đích: 2.1.5(7b).1, 2.1.7(*a).1.1 |
| CM2-L5 | CM2-O-C | CM2-O-SH | Link | 2.1.5(7b).2: // expire (thời điểm hiện tại) (-->)<br>2.1.5(7b).3: // releaseHeldSeats (chậm nhất 1 phút sau thời điểm hết hạn) (-->) [lần giữ ghế ở trạng thái Hết hạn, vừa chuyển hoặc đã chuyển từ trước do báo thanh toán đến muộn]<br>2.1.7(*a).1.2: // cancel (thời điểm hiện tại) (-->)<br>2.1.7(*a).1.3: // releaseHeldSeats (-->) | Nguồn-->Đích: 2.1.5(7b).2, 2.1.5(7b).3, 2.1.7(*a).1.2, 2.1.7(*a).1.3 |
| CM2-L6 | CM2-O-SH | CM2-O-SH | Link | 2.1.5(7b).2.1: // checkHoldStillActive (thời điểm hiện tại) (-->)<br>2.1.5(7b).2.2: // endHold (Hết hạn, nếu còn Đang giữ) (-->)<br>2.1.7(*a).1.2.1: // checkHoldStillActive (thời điểm hiện tại) (-->)<br>2.1.7(*a).1.2.2: // endHold (Đã huỷ) (-->)<br>4a.1.1.1: // checkHoldStillActive (thời điểm nhận báo) (-->) [cổng báo giao dịch thanh toán thất bại và lần giữ ghế còn Đang giữ, chưa quá thời điểm hết hạn]<br>4a.1.1.3: // endHold (Thanh toán thất bại) (-->) [cổng báo giao dịch thanh toán thất bại và lần giữ ghế còn Đang giữ, chưa quá thời điểm hết hạn]<br>4.1.1.2x.1: // expire (thời điểm nhận báo, nếu còn Đang giữ nhưng đã quá thời điểm hết hạn) (-->) [lần giữ ghế ở trạng thái Đang giữ nhưng đã quá thời điểm hết hạn (BR-14, BR-86)] | Nguồn-->Đích: 2.1.5(7b).2.1, 2.1.5(7b).2.2, 2.1.7(*a).1.2.1, 2.1.7(*a).1.2.2, 4a.1.1.1, 4a.1.1.3, 4.1.1.2x.1 |
| CM2-L7 | CM2-O-SH | CM2-O-SS | Link | 2.1.5(7b).3.1: // releaseSeat (-->) [lặp: mỗi ghế đang giữ]<br>2.1.7(*a).1.3.1: // releaseSeat (-->) [lặp: mỗi ghế đang giữ]<br>4a.1.2.1: // releaseSeat (-->) [cổng báo giao dịch thanh toán thất bại và lần giữ ghế còn Đang giữ, chưa quá thời điểm hết hạn] | Nguồn-->Đích: 2.1.5(7b).3.1, 2.1.7(*a).1.3.1, 4a.1.2.1 |
| CM2-L8 | CM2-O-C | CM2-O-WF | Link | 2.1.5(7b).4: // updateSeatMap (ghế đã trống) (-->) [lần giữ ghế ở trạng thái Hết hạn, vừa chuyển hoặc đã chuyển từ trước do báo thanh toán đến muộn]<br>2.1.7(*a).1.4: // updateSeatMap (ghế đã trống) (-->) | Nguồn-->Đích: 2.1.5(7b).4, 2.1.7(*a).1.4 |
| CM2-L9 | CM2-O-A7 | CM2-O-PG | Link | 4a: // reportTransactionResult (thất bại, mã giao dịch, mã tham chiếu lần giữ ghế) (-->) [cổng báo giao dịch thanh toán thất bại và lần giữ ghế còn Đang giữ, chưa quá thời điểm hết hạn] | Nguồn-->Đích: 4a |
| CM2-L10 | CM2-O-PG | CM2-O-PC | Link | 4a.1: // handlePaymentReport (thất bại, mã giao dịch, mã tham chiếu lần giữ ghế, thời điểm nhận báo) (-->) [cổng báo giao dịch thanh toán thất bại và lần giữ ghế còn Đang giữ, chưa quá thời điểm hết hạn] | Nguồn-->Đích: 4a.1 |
| CM2-L11 | CM2-O-PC | CM2-O-SH | Link | 4a.1.1: // settlePaymentReport (lần giữ ghế tìm theo mã giao dịch hoặc mã tham chiếu lần giữ ghế, kết quả, thời điểm nhận báo) (-->) [cổng báo giao dịch thanh toán thất bại và lần giữ ghế còn Đang giữ, chưa quá thời điểm hết hạn]<br>4a.1.2: // releaseHeldSeats (-->) [cổng báo giao dịch thanh toán thất bại và lần giữ ghế còn Đang giữ, chưa quá thời điểm hết hạn] | Nguồn-->Đích: 4a.1.1, 4a.1.2 |
| CM2-L12 | CM2-O-SH | CM2-O-PT | Link | 4a.1.1.2: // recordFailedResult (-->) [cổng báo giao dịch thanh toán thất bại và lần giữ ghế còn Đang giữ, chưa quá thời điểm hết hạn] | Nguồn-->Đích: 4a.1.1.2 |
| CM2-L13 | CM2-O-PC | CM2-O-WF | Link | 4a.1.3: // updateSeatMap (ghế đã trống) (-->) [cổng báo giao dịch thanh toán thất bại và lần giữ ghế còn Đang giữ, chưa quá thời điểm hết hạn] | Nguồn-->Đích: 4a.1.3 |
| CM2-L14 | CM2-O-PC | CM2-O-BF | Link | 4a.1.4: // notifyRefusal (thanh toán không thành công) (-->) [cổng báo giao dịch thanh toán thất bại và lần giữ ghế còn Đang giữ, chưa quá thời điểm hết hạn] | Nguồn-->Đích: 4a.1.4 |

### Trang CM3 - Biến thể ACT-02 (SD11a đến SD11e)

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| CM3-O-K2 | Actor | :Nhân viên quầy | - | - | Tác nhân (ACT-02) |
| CM3-O-CF | Object | :CounterBookTicketsForm | «boundary» | - | AC-B-CounterBookTicketsForm |
| CM3-O-C | Object | :BookTicketsController | «control» | - | AC-C-BookTicketsController |
| CM3-O-ST | Object | :Showtime | «entity» | - | AC-E-Showtime |
| CM3-O-WF | Object | w:BookTicketsForm | «boundary» | - | Boundary của khách khác đang xem sơ đồ ghế (AC-B-BookTicketsForm) |
| CM3-O-CL | Object | :BoxOfficeClerk | «entity» | - | AC-E-BoxOfficeClerk |
| CM3-O-PL | Object | :PriceList | «entity» | - | AC-E-PriceList |
| CM3-O-SH | Object | :SeatHold | «entity» | - | Đỉnh lifeline đặt ngang message Tạo |
| CM3-O-SS | Object | :SeatStatus | «entity» | - | AC-E-SeatStatus |
| CM3-O-BK | Object | :Booking | «entity» | - | Đỉnh lifeline đặt ngang message Tạo |
| CM3-O-TK | Object | :Ticket | «entity» | - | Đỉnh lifeline đặt ngang message Tạo |

b) Bảng Edge

| ID | Nguồn | Đích | Loại | Nhãn | Chiều message |
|---|---|---|---|---|---|
| CM3-L1 | CM3-O-K2 | CM3-O-CF | Link | 1[ACT-02]: // selectShowtime (suất chiếu) (-->)<br>2[ACT-02]: // confirmSeatSelection (các ghế đã chọn) (-->)<br>3a: // confirmCashReceived (-->)<br>3a.2: // printTickets (-->) | Nguồn-->Đích: 1[ACT-02], 2[ACT-02], 3a, 3a.2 |
| CM3-L2 | CM3-O-CF | CM3-O-C | Link | 1.1[ACT-02]: // startBooking (suất chiếu) (-->)<br>1.1.1a.1[ACT-02]: // notifyRefusal (chưa tới thời điểm mở bán, BR-01) (<--) [suất chiếu chưa tới thời điểm mở bán (BR-01)]<br>1.1.1b.1: // notifyRefusal (khác cụm rạp, BR-02) (<--) [suất chiếu không thuộc cụm rạp của nhân viên quầy (BR-02)]<br>1.1.1c.1[ACT-02]: // notifyRefusal (suất chiếu đã bắt đầu, BR-45) (<--) [suất chiếu đã tới giờ bắt đầu (BR-45), không thuộc 2b]<br>1.1.3[ACT-02]: // showSeatMap (suất chiếu, sơ đồ ghế) (<--)<br>2.1[ACT-02]: // requestSeatHold (các ghế đã chọn) (-->)<br>2.1.8[ACT-02]: // showHeldSeats (ghế đã giữ, giá vé từng ghế, tổng tiền) (<--)<br>3a.1: // confirmCashReceived (-->)<br>3a.1.2.1a.2: // notifyRefusal (từ chối xác nhận, trả lại tiền mặt đã thu cho khách, BR-44) (<--) [xác nhận đã thu tiền sau thời điểm hết hạn giữ ghế (BR-10, BR-44)]<br>3a.1.5: // showTicketsForPrint (mã đặt vé, các vé) (<--) | Nguồn-->Đích: 1.1[ACT-02], 2.1[ACT-02], 3a.1; Đích-->Nguồn: 1.1.1a.1[ACT-02], 1.1.1b.1, 1.1.1c.1[ACT-02], 1.1.3[ACT-02], 2.1.8[ACT-02], 3a.1.2.1a.2, 3a.1.5 |
| CM3-L3 | CM3-O-C | CM3-O-ST | Link | 1.1.1[ACT-02]: // checkSaleOpen (thời điểm hiện tại) (-->)<br>1.1.1b: // checkBelongsToCinema (cụm rạp của nhân viên quầy) (-->)<br>1.1.2[ACT-02]: // provideSeatMap (-->)<br>2.1.3[ACT-02]: // checkSeatSelectionLimit (các ghế đã chọn) (-->)<br>2.1.4[ACT-02]: // holdSeats (nhân viên quầy, các ghế đã chọn, mốc hiển thị sơ đồ ghế) (-->) | Nguồn-->Đích: 1.1.1[ACT-02], 1.1.1b, 1.1.2[ACT-02], 2.1.3[ACT-02], 2.1.4[ACT-02] |
| CM3-L4 | CM3-O-ST | CM3-O-SS | Link | 1.1.2.1[ACT-02]: // provideSeatStatus (vị trí, loại ghế, trạng thái ghế) (-->) [lặp: mỗi ghế của sơ đồ ghế]<br>2.1.4.3[ACT-02]: // holdSeatFor (lần giữ ghế) (-->) [lặp: mỗi ghế đã chọn]<br>2.1.4.5[ACT-02]: // recordHeldPrice (giá vé) (-->) [lặp: mỗi ghế đã chọn] | Nguồn-->Đích: 1.1.2.1[ACT-02], 2.1.4.3[ACT-02], 2.1.4.5[ACT-02] |
| CM3-L5 | CM3-O-C | CM3-O-CL | Link | 2.1.2[ACT-02]: // checkNoActiveSeatHold (-->) | Nguồn-->Đích: 2.1.2[ACT-02] |
| CM3-L6 | CM3-O-ST | CM3-O-SH | Link | 2.1.4.1[ACT-02]: «create» // createSeatHold (nhân viên quầy, suất chiếu) (-->) | Nguồn-->Đích: 2.1.4.1[ACT-02] |
| CM3-L7 | CM3-O-SH | CM3-O-CL | Link | 2.1.4.1.1[ACT-02]: // checkNoActiveSeatHold (-->) | Nguồn-->Đích: 2.1.4.1.1[ACT-02] |
| CM3-L8 | CM3-O-ST | CM3-O-ST | Link | 2.1.4.2[ACT-02]: // checkUnchangedSinceDisplayed (mốc hiển thị sơ đồ ghế) (-->) | Nguồn-->Đích: 2.1.4.2[ACT-02] |
| CM3-L9 | CM3-O-ST | CM3-O-PL | Link | 2.1.4.4[ACT-02]: // determineSeatPrice (loại phòng, định dạng phim, loại ghế, giờ bắt đầu) (-->) [lặp: mỗi ghế đã chọn] | Nguồn-->Đích: 2.1.4.4[ACT-02] |
| CM3-L10 | CM3-O-C | CM3-O-C | Link | 2.1.5[ACT-02]: // startWaitingForHoldExpiry (BR-10) (-->)<br>3a.1.1: // stopWaitingForHoldExpiry (-->) | Nguồn-->Đích: 2.1.5[ACT-02], 3a.1.1 |
| CM3-L11 | CM3-O-C | CM3-O-WF | Link | 2.1.6[ACT-02]: // updateSeatMap (ghế đã được giữ) (-->)<br>3a.1.3: // updateSeatMap (ghế đã bán) (-->) | Nguồn-->Đích: 2.1.6[ACT-02], 3a.1.3 |
| CM3-L12 | CM3-O-C | CM3-O-SH | Link | 2.1.7[ACT-02]: // provideHoldSummary (-->)<br>3a.1.2: // completeSaleOnCashConfirmation (thời điểm xác nhận) (-->) | Nguồn-->Đích: 2.1.7[ACT-02], 3a.1.2 |
| CM3-L13 | CM3-O-SH | CM3-O-SS | Link | 2.1.7.1[ACT-02]: // provideHeldSeatInfo (vị trí, loại ghế, giá vé đã chốt) (-->) [lặp: mỗi ghế đã giữ]<br>3a.1.2.2: // markSold (-->) [lặp: mỗi ghế đang giữ] | Nguồn-->Đích: 2.1.7.1[ACT-02], 3a.1.2.2 |
| CM3-L14 | CM3-O-SH | CM3-O-SH | Link | 2.1.7.2[ACT-02]: // calculateTotalAmount (-->)<br>3a.1.2.1: // checkHoldStillActive (thời điểm xác nhận) (-->)<br>3a.1.2.1a.1: // endHold (Hết hạn, nếu còn Đang giữ) (-->) [xác nhận đã thu tiền sau thời điểm hết hạn giữ ghế (BR-10, BR-44)]<br>3a.1.2.3: // endHold (Đã hoàn tất) (-->)<br>3a.1.2.4: // issueBooking (-->) | Nguồn-->Đích: 2.1.7.2[ACT-02], 3a.1.2.1, 3a.1.2.1a.1, 3a.1.2.3, 3a.1.2.4 |
| CM3-L15 | CM3-O-SH | CM3-O-BK | Link | 3a.1.2.4.1: «create» // createBooking (suất chiếu, các ghế đã bán) (-->) | Nguồn-->Đích: 3a.1.2.4.1 |
| CM3-L16 | CM3-O-BK | CM3-O-BK | Link | 3a.1.2.4.1.1: // generateBookingCode (BR-80) (-->) | Nguồn-->Đích: 3a.1.2.4.1.1 |
| CM3-L17 | CM3-O-BK | CM3-O-TK | Link | 3a.1.2.4.1.2: «create» // createTicket (ghế, giá vé đã chốt, suất chiếu) (-->) [lặp: mỗi ghế đã bán]<br>3a.1.4.1: // provideTicketContent (-->) [lặp: mỗi vé của lần đặt] | Nguồn-->Đích: 3a.1.2.4.1.2, 3a.1.4.1 |
| CM3-L18 | CM3-O-TK | CM3-O-TK | Link | 3a.1.2.4.1.2.1: // generateQrCode (-->) [lặp: mỗi ghế đã bán] | Nguồn-->Đích: 3a.1.2.4.1.2.1 |
| CM3-L19 | CM3-O-C | CM3-O-BK | Link | 3a.1.4: // provideBookingInfo (-->) | Nguồn-->Đích: 3a.1.4 |

## 8. VOPC

File diagrams/P07-class-UC-005.drawio. ID cell của lớp là mã AC; ngăn thuộc tính và ngăn trách nhiệm có ID "<mã AC>-ATTR" và "<mã AC>-RESP".

a) Bảng Node (lớp)

| ID (mã AC) | Loại (Class) | Nhãn (tên lớp) | Stereotype | Thuộc về | Ngăn thuộc tính | Ngăn trách nhiệm |
|---|---|---|---|---|---|---|
| AC-B-BookTicketsForm | Class | BookTicketsForm | «boundary» | - | selectedSeats (Các ghế đã chọn)<br>credentials (Email hoặc số điện thoại, mật khẩu) | // selectShowtime<br>// showSeatMap<br>// confirmSeatSelection<br>// showHeldSeats<br>// requestOnlinePayment<br>// showBookingSuccess<br>// notifyRefusal<br>// requestLogin<br>// provideCredentials<br>// cancelSeatHold<br>// updateSeatMap |
| AC-B-CounterBookTicketsForm | Class | CounterBookTicketsForm | «boundary» | - | selectedSeats (Các ghế đã chọn) | // selectShowtime<br>// notifyRefusal<br>// showSeatMap<br>// confirmSeatSelection<br>// showHeldSeats<br>// confirmCashReceived<br>// showTicketsForPrint<br>// printTickets<br>// updateSeatMap |
| AC-B-PaymentGateway | Class | PaymentGateway | «boundary» | - | - | // createPaymentTransaction<br>// reportTransactionResult |
| AC-B-EmailService | Class | EmailService | «boundary» | - | - | // sendTicketsEmail |
| AC-C-BookTicketsController | Class | BookTicketsController | «control» | - | - | // startBooking<br>// requestSeatHold<br>// checkCustomerLoggedIn<br>// startWaitingForHoldExpiry<br>// startOnlinePayment<br>// stopWaitingForHoldExpiry<br>// handleHoldExpired<br>// cancelSeatHold<br>// confirmCashReceived |
| AC-C-PaymentReportController | Class | PaymentReportController | «control» | - | - | // handlePaymentReport |
| AC-E-Customer | Class | Customer | «entity» | - | email (Văn bản)<br>phoneNumber (Văn bản)<br>password (Văn bản) | // checkNoActiveSeatHold<br>// authenticateCustomer |
| AC-E-BoxOfficeClerk | Class | BoxOfficeClerk | «entity» | - | cinema (Cụm rạp của nhân viên quầy) | // checkNoActiveSeatHold |
| AC-E-Showtime | Class | Showtime | «entity» | - | startTime (Ngày giờ)<br>saleOpenTime (Ngày giờ)<br>movieFormat (Văn bản)<br>auditoriumType (Văn bản)<br>cinema (Cụm rạp)<br>lastChangedAt (Ngày giờ) | // checkSaleOpen<br>// provideSeatMap<br>// checkSeatSelectionLimit<br>// holdSeats<br>// checkUnchangedSinceDisplayed<br>// checkBelongsToCinema |
| AC-E-PriceList | Class | PriceList | «entity» | - | cinema (Cụm rạp) | // determineSeatPrice |
| AC-E-SeatStatus | Class | SeatStatus | «entity» | - | seatPosition (Mã hàng, số ghế)<br>seatType (Văn bản)<br>status (Trạng thái)<br>heldPrice (Số tiền) | // provideSeatStatus<br>// holdSeatFor<br>// recordHeldPrice<br>// provideHeldSeatInfo<br>// markSold<br>// releaseSeat |
| AC-E-SeatHold | Class | SeatHold | «entity» | - | holdRef (Văn bản)<br>status (Trạng thái)<br>holdTime (Ngày giờ)<br>expiryTime (Ngày giờ) | // createSeatHold<br>// provideHoldSummary<br>// calculateTotalAmount<br>// recordPaymentTransaction<br>// settlePaymentReport<br>// checkHoldStillActive<br>// endHold<br>// issueBooking<br>// expire<br>// releaseHeldSeats<br>// cancel<br>// completeSaleOnCashConfirmation |
| AC-E-PaymentTransaction | Class | PaymentTransaction | «entity» | - | transactionCode (Văn bản)<br>amount (Số tiền)<br>processed (Trạng thái)<br>result (Văn bản) | // createPaymentTransaction<br>// checkNotProcessed<br>// markProcessed<br>// recordFailedResult |
| AC-E-Booking | Class | Booking | «entity» | - | bookingCode (Văn bản) | // createBooking<br>// generateBookingCode<br>// provideBookingInfo |
| AC-E-Ticket | Class | Ticket | «entity» | - | ticketCode (Văn bản)<br>qrCode (Hình ảnh)<br>seatPosition (Mã hàng, số ghế)<br>seatType (Văn bản)<br>price (Số tiền)<br>status (Trạng thái) | // createTicket<br>// generateQrCode<br>// provideTicketContent |

b) Bảng quan hệ

| ID | Lớp A | Lớp B | Loại | Multiplicity | Vai trò | Nguồn |
|---|---|---|---|---|---|---|
| R-UC005-01 | AC-B-BookTicketsForm | AC-C-BookTicketsController | Association | - | - | tạm thời; link F7: CM1-L2, CM1-L11, CM2-L1, CM2-L8, CM3-L11 |
| R-UC005-02 | AC-B-CounterBookTicketsForm | AC-C-BookTicketsController | Association | - | - | tạm thời; link F7: CM3-L2 |
| R-UC005-03 | AC-B-PaymentGateway | AC-C-BookTicketsController | Association | - | - | tạm thời; link F7: CM1-L15 |
| R-UC005-04 | AC-B-EmailService | AC-C-PaymentReportController | Association | - | - | tạm thời; link F7: CM1-L25 |
| R-UC005-05 | AC-C-BookTicketsController | AC-E-Customer | Association | - | - | tạm thời; link F7: CM1-L6, CM2-L3 |
| R-UC005-06 | AC-C-BookTicketsController | AC-E-BoxOfficeClerk | Association | - | - | tạm thời; link F7: CM3-L5 |
| R-UC005-07 | AC-C-BookTicketsController | AC-E-Showtime | Association | - | - | tạm thời; link F7: CM1-L3, CM3-L3 |
| R-UC005-08 | AC-C-BookTicketsController | AC-E-SeatHold | Association | - | - | tạm thời; link F7: CM1-L12, CM2-L5, CM3-L12 |
| R-UC005-09 | AC-C-BookTicketsController | AC-E-Booking | Association | - | - | tạm thời; link F7: CM3-L19 |
| R-UC005-10 | AC-E-Showtime | AC-E-SeatHold | Association | A 1 - B 0..* | - | Mỗi lần giữ ghế thuộc đúng một suất chiếu (GL-25, BR-07); link F7: CM1-L7, CM3-L6 |
| R-UC005-11 | AC-E-Showtime | AC-E-SeatStatus | Association | A 1 - B 1..* | - | Mỗi ghế của sơ đồ ghế có một trạng thái ghế trong suất chiếu (GL-58, Dữ liệu ra 1); cận trên theo sức chứa phòng, Q-81; link F7: CM1-L4, CM3-L4 |
| R-UC005-12 | AC-E-Showtime | AC-E-PriceList | Association | A 0..* - B 1 | - | Giá lấy theo bảng giá của cụm rạp có suất chiếu (BR-11, GL-01); đường qua Cụm rạp rút gọn, Q-81; link F7: CM1-L10, CM3-L9 |
| R-UC005-13 | AC-E-SeatHold | AC-E-SeatStatus | Association | A 0..* - B 1..8 | - | Lần giữ ghế giữ cả nhóm ghế, tối đa 8 ghế (BR-05, BR-07); tại một thời điểm một ghế chỉ thuộc một lần giữ ghế đang giữ (BR-08, BR-09), theo thời gian một trạng thái ghế qua nhiều lần giữ ghế; link F7: CM1-L13, CM2-L7, CM3-L13 |
| R-UC005-14 | AC-E-SeatHold | AC-E-Customer | Association | A 0..* - B 0..1 | - | Người giữ ghế là khách hoặc nhân viên quầy (GL-25, BR-04); phía B 0..1 vì hai quan hệ SH-CU và SH-CL loại trừ nhau, Q-86; link F7: CM1-L8 |
| R-UC005-15 | AC-E-SeatHold | AC-E-BoxOfficeClerk | Association | A 0..* - B 0..1 | - | Người giữ ghế là khách hoặc nhân viên quầy (GL-25, BR-04); Q-86; link F7: CM3-L7 |
| R-UC005-16 | AC-E-SeatHold | AC-E-PaymentTransaction | Association | A 1 - B 0..* | - | Giao dịch thanh toán tạo cho tổng tiền của một lần giữ ghế; thử lại tạo giao dịch mới (GL-12, Mục 8 đoạn 10a); link F7: CM1-L17, CM2-L12 |
| R-UC005-17 | AC-E-SeatHold | AC-E-Booking | Association | A 1 - B 0..1 | - | Một lần giữ ghế dẫn tới tối đa một lần đặt (GL-24); link F7: CM1-L20, CM3-L15 |
| R-UC005-18 | AC-E-Booking | AC-E-Ticket | Aggregation | A 1 - B 1..8 | - | Lần đặt gồm mỗi ghế một vé (GL-24); tối đa 8 ghế (BR-05); link F7: CM1-L22, CM3-L17 |
| R-UC005-19 | AC-E-Ticket | AC-E-Showtime | Association | A 0..* - B 1 | - | Vé thuộc đúng một ghế của một suất chiếu (GL-59, Dữ liệu ra 3); bằng chứng từ đặc tả, không có link |
| R-UC005-20 | AC-B-PaymentGateway | AC-C-PaymentReportController | Association | - | - | tạm thời; link F7: CM1-L18, CM2-L10 |
| R-UC005-21 | AC-C-PaymentReportController | AC-E-SeatHold | Association | - | - | tạm thời; link F7: CM1-L19, CM2-L11 |
| R-UC005-22 | AC-C-PaymentReportController | AC-E-Booking | Association | - | - | tạm thời; link F7: CM1-L27 |
| R-UC005-23 | AC-B-BookTicketsForm | AC-C-PaymentReportController | Association | - | - | tạm thời; link F7: CM1-L24, CM1-L28, CM2-L13, CM2-L14 |

- Ghi chú VOPC: {xor} giữa R-UC005-14 và R-UC005-15: mỗi lần giữ ghế gắn đúng một trong Customer hoặc BoxOfficeClerk (Q-86).

## 9. Ma trận truy vết

| Bước UC | Message (STT) | Lớp tham gia (AC) |
|---|---|---|
| 1 | 1, 1.1, 1[ACT-02], 1.1[ACT-02] | AC-B-BookTicketsForm, AC-C-BookTicketsController, AC-B-CounterBookTicketsForm |
| 2 | 1.1.1, 1.1.1[ACT-02], 1.1.1b | AC-C-BookTicketsController, AC-E-Showtime |
| 3 | 1.1.2, 1.1.2.1, 1.1.2 (trả về), 1.1.3, 2.1.6, 4.1.2, 1.1.2[ACT-02], 1.1.2.1[ACT-02], 1.1.2[ACT-02] (trả về), 1.1.3[ACT-02], 2.1.6[ACT-02], 3a.1.3 | AC-C-BookTicketsController, AC-E-Showtime, AC-E-SeatStatus, AC-B-BookTicketsForm, AC-C-PaymentReportController, AC-B-CounterBookTicketsForm |
| 4 | 2, 2.1, 2[ACT-02], 2.1[ACT-02] | AC-B-BookTicketsForm, AC-C-BookTicketsController, AC-B-CounterBookTicketsForm |
| 5 | 2.1.1, 2.1.2, 2.1.2[ACT-02] | AC-C-BookTicketsController, AC-E-Customer, AC-E-BoxOfficeClerk |
| 6 | 2.1.3, 2.1.3[ACT-02] | AC-C-BookTicketsController, AC-E-Showtime |
| 7 | 2.1.4, 2.1.4.1, 2.1.4.1.1, 2.1.4.2, 2.1.4.3, 2.1.4.4, 2.1.4.4 (trả về), 2.1.4.5, 2.1.4 (trả về), 2.1.5, 2.1.4[ACT-02], 2.1.4.1[ACT-02], 2.1.4.1.1[ACT-02], 2.1.4.2[ACT-02], 2.1.4.3[ACT-02], 2.1.4.4[ACT-02], 2.1.4.4[ACT-02] (trả về), 2.1.4.5[ACT-02], 2.1.4[ACT-02] (trả về), 2.1.5[ACT-02] | AC-C-BookTicketsController, AC-E-Showtime, AC-E-SeatHold, AC-E-Customer, AC-E-SeatStatus, AC-E-PriceList, AC-E-BoxOfficeClerk |
| 8 | 2.1.7, 2.1.7.1, 2.1.7.2, 2.1.7 (trả về), 2.1.8, 2.1.7[ACT-02], 2.1.7.1[ACT-02], 2.1.7.2[ACT-02], 2.1.7[ACT-02] (trả về), 2.1.8[ACT-02] | AC-C-BookTicketsController, AC-E-SeatHold, AC-E-SeatStatus, AC-B-BookTicketsForm, AC-B-CounterBookTicketsForm |
| 9 | 3, 3.1 | AC-B-BookTicketsForm, AC-C-BookTicketsController |
| 10 | 3.1.1, 3.1.1.1, 3.1.1.1 (trả về), 3.1.2, 3.1.2.1 | AC-C-BookTicketsController, AC-B-PaymentGateway, AC-E-SeatHold, AC-E-PaymentTransaction |
| 11 | 4, 4.1 | AC-B-PaymentGateway, AC-C-PaymentReportController |
| 12 | 4.1.1, 4.1.1.1, 4.1.1.2, 4.1.1.3, 4.1.1.4, 4.1.1.5, 4.1.1 (trả về), 4.1.1.2x.1 | AC-C-PaymentReportController, AC-E-SeatHold, AC-E-PaymentTransaction, AC-E-SeatStatus |
| 13 | 4.1.1.6, 4.1.1.6.1, 4.1.1.6.1.1, 4.1.1.6.1.2, 4.1.1.6.1.2.1, 4.1.1 (trả về) | AC-E-SeatHold, AC-E-Booking, AC-E-Ticket, AC-C-PaymentReportController |
| 14 | 4.1.3, 4.1.3.1 | AC-C-PaymentReportController, AC-B-EmailService |
| 15 | 4.1.4, 4.1.4.1, 4.1.4 (trả về), 4.1.5 | AC-C-PaymentReportController, AC-E-Booking, AC-E-Ticket, AC-B-BookTicketsForm |
| 2a | 1.1.1a.1, 1.1.1a.1[ACT-02] | AC-C-BookTicketsController, AC-B-BookTicketsForm, AC-B-CounterBookTicketsForm |
| 2b | 1.1.1b.1 | AC-C-BookTicketsController, AC-B-CounterBookTicketsForm |
| 2c | 1.1.1c.1, 1.1.1c.1[ACT-02] | AC-C-BookTicketsController, AC-B-BookTicketsForm, AC-B-CounterBookTicketsForm |
| 5a1 | 2.1.1a.1 | AC-C-BookTicketsController, AC-B-BookTicketsForm |
| 5a2 | 2.1.1a.2, 2.1.1a.3, 2.1.1a.4 | AC-B-BookTicketsForm, AC-C-BookTicketsController, AC-E-Customer |
| 5b | 2.1.2b.1 | AC-C-BookTicketsController, AC-B-BookTicketsForm |
| 6a | 2.1.3a.1 | AC-C-BookTicketsController, AC-B-BookTicketsForm |
| 7a | 2.1.4a.1 | AC-C-BookTicketsController, AC-B-BookTicketsForm |
| 7b | 2.1.5(7b).1, 2.1.5(7b).2, 2.1.5(7b).2.1, 2.1.5(7b).2.2, 2.1.5(7b).2 (trả về), 2.1.5(7b).3, 2.1.5(7b).3.1, 2.1.5(7b).4, 2.1.5(7b).5 | AC-C-BookTicketsController, AC-E-SeatHold, AC-E-SeatStatus, AC-B-BookTicketsForm |
| 7c | 2.1.4c.1 | AC-C-BookTicketsController, AC-B-BookTicketsForm |
| 7d | 2.1.4d.1 | AC-C-BookTicketsController, AC-B-BookTicketsForm |
| 7e | 2.1.4e.1 | AC-C-BookTicketsController, AC-B-BookTicketsForm |
| 9a1 | 3a, 3a.1, 3a.1.1 | AC-B-CounterBookTicketsForm, AC-C-BookTicketsController |
| 9a1a | 3a.1.2.1a.1, 3a.1.2.1a.2 | AC-E-SeatHold, AC-C-BookTicketsController, AC-B-CounterBookTicketsForm |
| 9a2 | 3a.1.2, 3a.1.2.1, 3a.1.2.2, 3a.1.2.3, 3a.1.2 (trả về) | AC-C-BookTicketsController, AC-E-SeatHold, AC-E-SeatStatus |
| 9a3 | 3a.1.2.4, 3a.1.2.4.1, 3a.1.2.4.1.1, 3a.1.2.4.1.2, 3a.1.2.4.1.2.1, 3a.1.2 (trả về) | AC-E-SeatHold, AC-E-Booking, AC-E-Ticket, AC-C-BookTicketsController |
| 9a4 | 3a.1.4, 3a.1.4.1, 3a.1.4 (trả về), 3a.1.5 | AC-C-BookTicketsController, AC-E-Booking, AC-E-Ticket, AC-B-CounterBookTicketsForm |
| 9a5 | 3a.2 | AC-B-CounterBookTicketsForm |
| 10a | 3.1.1a.1 | AC-C-BookTicketsController, AC-B-BookTicketsForm |
| 11a | 4a, 4a.1, 4a.1.1, 4a.1.1.1, 4a.1.1.2, 4a.1.1.3, 4a.1.1 (trả về), 4a.1.2, 4a.1.2.1, 4a.1.3, 4a.1.4 | AC-B-PaymentGateway, AC-C-PaymentReportController, AC-E-SeatHold, AC-E-PaymentTransaction, AC-E-SeatStatus, AC-B-BookTicketsForm |
| *a | 2.1.7(*a), 2.1.7(*a).1, 2.1.7(*a).1.1, 2.1.7(*a).1.2, 2.1.7(*a).1.2.1, 2.1.7(*a).1.2.2, 2.1.7(*a).1.3, 2.1.7(*a).1.3.1, 2.1.7(*a).1.4 | AC-B-BookTicketsForm, AC-C-BookTicketsController, AC-E-SeatHold, AC-E-SeatStatus |

## 10. File .drawio

Ba file nằm trong diagrams/: P07-sequence-UC-005.drawio (17 trang), P07-communication-UC-005.drawio (3 trang), P07-class-UC-005.drawio (1 trang). XML không nén, ID cell trùng ID trong bảng mô hình.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Trạng thái |
| --- | --- | --- | --- | --- |
| Q-81 | Ở mức phân tích, UC-005 dùng một entity SeatStatus (ghế trong một suất chiếu, kèm vị trí ghế, loại ghế, trạng thái ghế, giá chốt), đọc cụm rạp, phòng chiếu, loại phòng qua Showtime và nối Showtime với PriceList bằng một liên kết rút gọn. Có tách thêm entity Seat, Auditorium, Cinema và đường Showtime - Auditorium - Cinema - PriceList ngay ở UC-005 không? (Giữ như phân tích này, P08 hợp nhất khi có P07 của UC-011, UC-012 / Tách ngay) | AC-E-SeatStatus, AC-E-Showtime, AC-E-PriceList; R-UC005-11, R-UC005-12; P08 | GL-07 và GL-58 là hai thuật ngữ (Q-70); P04 UC-005 không nêu cấu trúc phòng chiếu và cụm rạp | Đã trả lời: giữ như phân tích hiện tại, P08 tách Seat, Auditorium, Cinema khi gộp (theo đề xuất của review). Gộp: Q-98, Q-103 gộp vào Q-81. |
| Q-82 | Khi email hoặc số điện thoại và mật khẩu khách cung cấp ở bước 5a2 không khớp tài khoản nào thì hệ thống xử lý thế nào? (Báo sai thông tin và cho nhập lại, quay lại 5a2 / Phương án khác như giới hạn số lần sai) | Luồng 5a2; AC-E-Customer, // authenticateCustomer | P04 5a2 chỉ nêu điều kiện hợp lệ của Dữ liệu vào 2, không nêu luồng khi không khớp | Đã trả lời: báo thông tin không đúng và cho nhập lại ở bước 5a2, không đặt giới hạn số lần nhập sai (theo đề xuất của review); luồng 5a2a ghi ở Đề xuất sửa artifact trước. |
| Q-83 | Kết quả giao dịch do cổng báo được UC-005 (bước 11, 12) và UC-006 (Hoàn tiền thanh toán trễ) cùng xử lý tùy thời điểm nhận và trạng thái lần giữ ghế (BR-85, BR-86). Control nào tiếp nhận báo đầu tiên và chuyển giao khi báo thuộc UC-006? (A: control của UC-005 tiếp nhận mọi báo thành công và chuyển tới UC-006 khi lần giữ ghế đã kết thúc, như SD10 / B: một điểm tiếp nhận riêng quyết định UC rồi gọi UC-005 hoặc UC-006 / C: UC-006 tiếp nhận mọi báo) | SD10, bước 11, 12; AC-B-PaymentGateway; P07 của UC-006; P03 | UC-005 Mục 8 và UC-006 Mục 8 cùng nêu thao tác không chia cắt theo lần giữ ghế, nhưng P03 không có quan hệ giữa hai use case và ACT-07 là tác nhân chính của UC-006, tác nhân phụ của UC-005 | Đã trả lời: một control dùng chung (PaymentReportController) tiếp nhận mọi báo kết quả giao dịch của cổng, khoá theo lần giữ ghế (Q-79); một trách nhiệm duy nhất SeatHold.settlePaymentReport trả về bán ghế, thanh toán trễ chờ hoàn, báo trùng hoặc thất bại ghi nhận; lần giữ ghế Đang giữ mà quá hạn chuyển sang Hết hạn trước, việc giải phóng ghế chạy lại được; sau đó nhánh bán ghế (UC-005) hoặc hoàn tiền (UC-006). UC-005 là chủ của control, của settlePaymentReport và checkHoldStillActive. Gộp: Q-88 gộp vào Q-83. |
| Q-84 | Bước 13 (tạo mã đặt vé và vé) có thuộc cùng thao tác không chia cắt với bước 12 (chuyển ghế sang đã bán) không; nếu tạo mã đặt vé hoặc vé không thành công sau khi ghế đã sang đã bán thì xử lý thế nào? (Cùng thao tác: hoặc cả hai có hiệu lực hoặc không có gì / Tách riêng như P04 và bổ sung luồng lỗi) | AC-E-SeatHold, // settlePaymentReport, // issueBooking; SD1b, SD1c; BR-85 | P04 Mục 8 chỉ nêu bước 11 và 12 là một thao tác; bước 13 đứng riêng và không có luồng lỗi | Đã trả lời: bước 13 cùng thao tác với bước 12, cả khi thu tiền mặt (9a3); thao tác không hoàn tất thì giao dịch xử lý như thanh toán trễ, hoàn toàn bộ (UC-006); gửi email (bước 14) ngoài thao tác (BR-89). Cập nhật P04 ghi ở Đề xuất sửa artifact trước. |
| Q-85 | Mã giao dịch do cổng cấp được hệ thống biết và ghi lúc tạo giao dịch (bước 10) hay chỉ lưu khi cổng báo thành công (bước 12)? (Biết lúc tạo, ghi cùng số tiền ở bước 10, bước 12 chỉ đối chiếu / Chỉ lưu ở bước 12) | AC-E-PaymentTransaction, transactionCode; // recordPaymentTransaction, // markProcessed | Bước 10 chỉ nêu ghi nhận số tiền, bước 12 nêu lưu mã giao dịch, GL-11 coi mã giao dịch thuộc giao dịch hệ thống đã tạo | Đã trả lời: mã giao dịch biết lúc tạo ở bước 10, bước 12 chỉ đối chiếu; ngoại lệ khi cổng không trả lời trong 30 giây (10a) thì giao dịch thứ hai được nhận ra bằng mã tham chiếu lần giữ ghế (UC-006). Gộp: Q-90 gộp vào Q-85. |
| Q-86 | BR-04 áp dụng cho khách và nhân viên quầy. Mô hình hoá thành hai entity Customer và BoxOfficeClerk, mỗi lần giữ ghế gắn đúng một trong hai, hay một khái niệm người giữ ghế dùng chung? (Hai entity, loại trừ nhau / Một khái niệm chung) | R-UC005-14, R-UC005-15; AC-E-SeatHold; P08 | GL-18 và GL-35 là hai thuật ngữ riêng, GL-25 viết "một Khách hoặc Nhân viên quầy" | Đã trả lời: hai entity Customer và BoxOfficeClerk, mỗi lần giữ ghế gắn đúng một trong hai, ràng buộc {xor} ghi trên VOPC. Gộp: Q-100 gộp vào Q-86. |

## Giả định

Không có (chế độ NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P04 | UC-005 bước 14 | BR-89 (dịch vụ email lỗi lúc gửi vé) chỉ nằm ở Mục 8, luồng thay thế không có mã luồng tương ứng nên không có message lỗi ở P07 | Thêm luồng 14a (dịch vụ email từ chối hoặc không phản hồi: vé giữ nguyên hiệu lực, thử gửi lại, ghi log lỗi, tiếp tục bước 15) hoặc ghi rõ ở Mục 3 là bước 14 không có luồng thay thế |
| P04 | UC-005 luồng 5a2a | Chưa có luồng cho thông tin đăng nhập không khớp (Q-82) | Thêm luồng 5a2a: báo thông tin không đúng và cho nhập lại ở bước 5a2, không giới hạn số lần nhập sai |
| P04 | UC-005 Mục 8, BR-85 | Bước 13 (tạo lần đặt và vé) không nằm trong thao tác không chia cắt của bước 11 và 12 (Q-84) | Nêu rõ bước 11 đến 13 là một thao tác theo lần giữ ghế; thao tác không hoàn tất thì giao dịch được xử lý như thanh toán trễ (hoàn toàn bộ, UC-006) |
| P04 | UC-005 bước 12 | Ghi "lưu mã giao dịch" trong khi mã giao dịch đã ghi ở bước 10 (Q-85) | Sửa thành "đối chiếu mã giao dịch và đánh dấu giao dịch đã xử lý" |
| P03 | Quan hệ UC-005 và UC-006 | Hai use case dùng chung điểm tiếp nhận báo kết quả giao dịch (PaymentReportController) nhưng P03 không có quan hệ giữa chúng (Q-83) | Thêm quan hệ giữa UC-005 và UC-006 qua điểm tiếp nhận dùng chung |

## Vấn đề còn mở

- Số lớp là 15, vượt ngưỡng 12: 4 boundary, 2 control, 9 entity. Không có entity là thuộc tính trá hình. Nguyên nhân là UC gộp hai kênh bán (hai boundary người dùng, hai entity người giữ ghế), 4 entity do UC khác sở hữu (Showtime, PriceList, Customer, BoxOfficeClerk) và 5 entity do UC-005 tạo (SeatStatus, SeatHold, PaymentTransaction, Booking, Ticket). Hai kênh đã được gộp có chủ đích ở P02 U-R10 b nên không đề xuất sửa P02.
- BookTicketsController có 9 trách nhiệm; ba trong đó là message tự gọi theo A2 (startWaitingForHoldExpiry, stopWaitingForHoldExpiry, handleHoldExpired). Việc báo các màn hình khác cập nhật sơ đồ ghế là message updateSeatMap gửi tới boundary (có trong F3.4 của BookTicketsForm và CounterBookTicketsForm; mọi message updateSeatMap vẽ tới boundary của khách khác nên CounterBookTicketsForm không có lifeline riêng), không là trách nhiệm nhận của control. PaymentReportController có 1 trách nhiệm trong UC-005 (handlePaymentReport), 6 trách nhiệm tính cả UC-006, trong khoảng 2-10; không giữ quy tắc thuộc dữ liệu của entity.
- Chủ của trách nhiệm xử lý báo kết quả giao dịch: UC-005 làm chủ PaymentReportController, SeatHold.settlePaymentReport và SeatHold.checkHoldStillActive. UC-006 dùng lại đúng các trách nhiệm này và chỉ mô tả nhánh thanh toán trễ, báo trùng, thất bại muộn và hoàn tiền. Control tiếp nhận không dừng chờ hết hạn khi bán ghế: sự kiện hết hạn chạy sau đó gặp lần giữ ghế đã ở trạng thái cuối nên không đổi gì (SD6).
- Trách nhiệm // releaseHeldSeats phải chạy lại không hại và chạy được trên lần giữ ghế đã ở trạng thái cuối mà ghế còn đang giữ, vì báo thanh toán đến muộn chuyển lần giữ ghế sang Hết hạn trước khi sự kiện hết hạn giải phóng ghế (SD6, SD10). P08 xem xét một trách nhiệm giải phóng ghế có tiền điều kiện thay cho // releaseSeat, // releaseSoldSeat (UC-008) và // releaseTicketSeat.
- Thao tác giữ ghế ở bước 7 loại trừ theo hai chiều: suất chiếu (BR-54, BR-09) và người giữ ghế (BR-04, trải qua mọi suất chiếu), cùng bảng giá (BR-71), trước khi lần giữ ghế tồn tại, trong khi BR-85 chỉ khoá theo lần giữ ghế đã có. Phân tích chỉ chỉ ra Showtime, // holdSeats là thao tác không chia cắt và nêu đơn vị loại trừ của mọi thao tác ở bảng cuối mục 4; cơ chế loại trừ chọn ở P09.
- Sự kiện after(BR-10) và việc giải phóng ghế chậm nhất 1 phút (REQ-76) phải xảy ra kể cả khi tác nhân đã rời phiên; control của UC-005 chịu trách nhiệm nhận sự kiện, cơ chế hẹn giờ do P09, P12 thiết kế. Sự kiện hết hạn và xử lý báo thanh toán chạy được trên lần giữ ghế của suất chiếu Đã xoá (BR-58, UC-014).
- Luồng 7b và *a vẽ với Khách. Khi tác nhân là nhân viên quầy, các message giống nhau với CounterBookTicketsForm thay BookTicketsForm và BoxOfficeClerk thay Customer, không vẽ trang riêng.
- PaymentGateway, EmailService được UC-006 và UC-008 dùng lại đúng mã; SeatStatus được UC-008 dùng lại với // releaseSoldSeat (điều kiện khác // releaseSeat). Khung giờ chiếu do PriceList xác định (Q-104), Showtime không còn trách nhiệm xác định khung giờ.
- Danh sách gộp đầu vào cho P08 liên quan UC-005: (1) SeatHold: một trách nhiệm xử lý báo (settlePaymentReport) và một trách nhiệm "còn hiệu lực" (checkHoldStillActive) dùng chung UC-005, UC-006, UC-014; (2) SeatHold kết thúc: endHold làm lõi, expire, cancel và nhánh thất bại của settlePaymentReport gọi endHold; (3) PaymentGateway: một reportTransactionResult cho UC-005 và UC-006; (4) PaymentTransaction: tạo qua SeatHold.recordPaymentTransaction cho cả giao dịch thứ hai; (5) Ticket: cancelTicket và admitTicket cùng bộ giá trị trạng thái; (6) Showtime: gộp thuộc tính movieName, movieTitle, movie, auditoriumType, auditoriumName, auditorium, scheduleStatus, status, lastChangedAt và các cặp checkUnchangedSinceDisplayed với checkUnchangedSinceListed; (7) nhân viên: CinemaManager, BoxOfficeClerk, TicketChecker theo Q-86; (8) ghế, phòng, cụm rạp tách theo Q-81; (9) Booking: giữ provideBookingInfo cho phần cùng nghĩa.
