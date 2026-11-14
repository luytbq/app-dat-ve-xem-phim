# P04 - Đặc tả use case UC-014 Lập lịch suất chiếu - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P04 |
| Phiên bản | 1.6 |
| Thay đổi 1.6 | Bước 8 kiểm lại phim hiện hành (BR-47, BR-49, BR-50) theo BR-139, thêm luồng 8g, 8h; thêm UC-010 bước 5, UC-012 bước 5 và luồng 1b3 vào đối thủ của thao tác lưu suất chiếu (BR-136, BR-139, BR-147) |
| Thay đổi 1.5 | Thêm bảng Thao tác nguyên tử ở Mục 8 theo mô-đun đồng thời (2 thao tác); không đổi luồng và quy tắc nghiệp vụ |
| Thay đổi 1.4 | Thêm BR-92 và luồng 8f: không đổi phòng của suất chiếu đã từng có vé, kể cả vé đã huỷ (quyết định R13D-01 phương án A, review cuối RF-02); cập nhật activity diagram (A-8f, FINAL-11, E-63, E-64); đồng bộ đầu vào đã dùng (RF-06) |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md; yeu-cau-dat-ve.md (đã bổ sung trả lời Q-52 đến Q-67); P00-problem-brief.md 1.11; P01-actors.md 1.2; P02-usecases.md 1.9; P03-usecase-model.md 1.2; _BR-register.md (đã gộp BR-01 đến BR-147); P05-glossary.md 1.2; UC-005-book-tickets.md 1.14, UC-008-cancel-ticket.md 1.9, UC-013-manage-price-list.md 1.4 (mẫu và điểm nối); _review-UC-014.md (R14-01 đến R14-13); _review-UC-013.md (R13-02) |
| Phạm vi | UC-014 |
| Mã Q, ASM cuối đã cấp | Q-67 (cấp ở UC-013); Q-52 đến Q-61 đã trả lời; không có ASM (NGHIEM_NGAT) |

## 1. Thông tin chung

| Thuộc tính | Giá trị |
|---|---|
| Mã use case | UC-014 |
| Tên use case | Lập lịch suất chiếu (Schedule Showtimes) |
| Tác nhân chính | ACT-04 Quản lý cụm rạp |
| Tác nhân phụ | Không có |
| Mô tả ngắn | Use case này mô tả tương tác giữa quản lý cụm rạp và hệ thống khi quản lý cụm rạp muốn lập, sửa hoặc xoá suất chiếu cho các phòng chiếu của cụm rạp mình. Kết quả là phòng chiếu có lịch chiếu hợp lệ, kèm thời điểm mở bán của từng suất chiếu. |
| Sự kiện kích hoạt | Cụm rạp cần lên lịch chiếu (EV-16) |
| Tiền điều kiện | Quản lý cụm rạp đã đăng nhập và đang có phiên làm việc (REQ-102).<br>Quản lý cụm rạp thuộc đúng một cụm rạp (REQ-100). |
| Hậu điều kiện (thành công) | Suất chiếu mới được lưu với phim, định dạng, phòng chiếu, ngày giờ bắt đầu, giờ kết thúc và thời điểm mở bán; thời điểm mở bán trước giờ bắt đầu; trong phòng chiếu đó không có hai suất chiếu nào cách nhau dưới 15 phút dọn phòng.<br>Khi kết thúc ở luồng 1a: suất chiếu đã chọn được cập nhật theo thông tin mới, giữ khoảng cách dọn phòng 15 phút với các suất chiếu khác trong phòng chiếu.<br>Khi kết thúc ở luồng 1b: suất chiếu đã chọn không còn trong lịch chiếu của phòng chiếu và không còn bán vé; thông tin của suất chiếu vẫn được giữ cho vé đã huỷ, hoàn tiền và báo cáo (BR-58). |
| Hậu điều kiện tối thiểu | Khi use case kết thúc thất bại, các suất chiếu và lịch của phòng chiếu không thay đổi; ghế đang giữ và vé của suất chiếu không bị ảnh hưởng. |
| Quan hệ | Không có |
| Điểm mở rộng | Không có |
| REQ | REQ-60 đến REQ-65, REQ-86, REQ-97, REQ-98 (theo P02); REQ-137 đến REQ-145, REQ-151 (P02 Mục 5 đã gắn UC-014); REQ-102 (tiền điều kiện; P02 ghi "-"); REQ-100 (tham chiếu, UC-017); REQ-55, REQ-95 (tham chiếu, UC-010); REQ-07 (tham chiếu, UC-003, UC-010); REQ-02, REQ-57 (tham chiếu, UC-012); REQ-58 (tham chiếu, UC-012); REQ-96 (tham chiếu, UC-003); REQ-91, REQ-22, REQ-76 (tham chiếu, UC-005); REQ-135, REQ-152 (tham chiếu, UC-005); REQ-146 (tham chiếu, UC-013); REQ-36, REQ-116 (tham chiếu, UC-006); REQ-37, REQ-38 (tham chiếu, UC-013, UC-005); REQ-66, REQ-67, REQ-99 (tham chiếu, UC-015); REQ-162, REQ-53, REQ-56 (căn cứ phụ của BR dẫn ở Mục 6) |

## 2. Luồng sự kiện chính

| STT | Thực hiện bởi | Hành động |
|---|---|---|
| 1 | Quản lý cụm rạp | Yêu cầu lập suất chiếu mới cho một phòng chiếu của cụm rạp. |
| 2 | Hệ thống | Hiển thị các phòng chiếu của cụm rạp và danh sách phim (xem Dữ liệu ra 1). |
| 3 | Quản lý cụm rạp | Chọn phim, định dạng, phòng chiếu và nhập ngày giờ bắt đầu, thời điểm mở bán của suất chiếu, rồi gửi (xem Dữ liệu vào 1). |
| 4 | Hệ thống | Kiểm tra phòng chiếu đã chọn thuộc cụm rạp của quản lý cụm rạp (BR-46). |
| 5 | Hệ thống | Kiểm tra định dạng đã chọn là định dạng phát hành của phim (BR-47), phòng chiếu đã chọn chiếu được định dạng đó (BR-48) và bảng giá của cụm rạp có đủ giá cho suất chiếu: giá cho mọi loại ghế có trong phòng chiếu, ứng với khung giờ của giờ bắt đầu, theo loại phòng và định dạng đó (BR-69). |
| 6 | Hệ thống | Kiểm tra ngày chiếu nằm trong khoảng từ ngày khởi chiếu tới ngày kết thúc chiếu của phim (BR-49), giờ bắt đầu sau thời điểm kiểm tra (BR-56) và thời điểm mở bán trước giờ bắt đầu (BR-55). |
| 7 | Hệ thống | Tính giờ kết thúc của suất chiếu từ giờ bắt đầu và thời lượng phim (BR-50). |
| 8 | Hệ thống | Kiểm tra phim hiện hành (kể cả phim vừa được sửa) vẫn có định dạng của suất chiếu là định dạng phát hành và ngày chiếu trong khoảng chiếu (BR-47, BR-49), tính lại giờ kết thúc theo thời lượng của phim hiện hành (BR-50), phòng chiếu còn tồn tại, suất chiếu cách các suất chiếu khác trong phòng chiếu ít nhất 15 phút dọn phòng và, khi sửa, suất chiếu chưa bị người khác sửa hoặc xoá kể từ lúc hiển thị, chưa tới giờ bắt đầu, không có ghế đang được giữ và không có vé đã bán chưa bị huỷ, không đổi sang phòng chiếu khác khi suất chiếu đã từng có vé, và bảng giá của cụm rạp vẫn có đủ giá cho suất chiếu, rồi lưu suất chiếu cùng thời điểm mở bán, tất cả là một thao tác không chia cắt (BR-47, BR-49, BR-50, BR-51, BR-52, BR-53, BR-54, BR-57, BR-60, BR-68, BR-69, BR-92, BR-136, BR-139). |
| 9 | Hệ thống | Thông báo lưu suất chiếu thành công và hiển thị suất chiếu đã lưu (xem Dữ liệu ra 2). |

## 3. Luồng sự kiện thay thế và ngoại lệ

| STT | Điều kiện | Thực hiện bởi | Hành động | Quay lại / Kết thúc |
|---|---|---|---|---|
| 1a | Quản lý cụm rạp chọn sửa một suất chiếu đã lập thay vì lập suất chiếu mới | - | Sửa suất chiếu | - |
| 1a1 | | Hệ thống | Hiển thị các suất chiếu đã lập của các phòng chiếu thuộc cụm rạp (BR-46; xem Dữ liệu ra 3). | |
| 1a2 | | Quản lý cụm rạp | Chọn suất chiếu cần sửa (xem Dữ liệu vào 2). | |
| 1a3 | | Hệ thống | Kiểm tra suất chiếu đã chọn chưa tới giờ bắt đầu (BR-57), không có ghế đang được giữ và không có vé đã bán chưa bị huỷ (BR-53). | |
| 1a3a | Suất chiếu đã chọn có ghế đang được giữ hoặc có vé đã bán chưa bị huỷ (BR-53); kiểm sau 1a3b | Hệ thống | Từ chối sửa và thông báo quy tắc bị vi phạm (BR-53). | Kết thúc use case (thất bại) |
| 1a3b | Suất chiếu đã chọn đã tới giờ bắt đầu, kể cả đã kết thúc (BR-57); kiểm trước 1a3a | Hệ thống | Từ chối sửa và thông báo quy tắc bị vi phạm (BR-57). | Kết thúc use case (thất bại) |
| 1a4 | | Hệ thống | Hiển thị thông tin hiện tại của suất chiếu cùng các phòng chiếu và danh sách phim để sửa (xem Dữ liệu ra 1, Dữ liệu ra 2). | Tiếp tục bước 3 |
| 1b | Quản lý cụm rạp chọn xoá một suất chiếu đã lập thay vì lập suất chiếu mới | - | Xoá suất chiếu | - |
| 1b1 | | Hệ thống | Hiển thị các suất chiếu đã lập của các phòng chiếu thuộc cụm rạp (BR-46; xem Dữ liệu ra 3). | |
| 1b2 | | Quản lý cụm rạp | Chọn suất chiếu cần xoá (xem Dữ liệu vào 2). | |
| 1b3 | | Hệ thống | Kiểm tra suất chiếu đã chọn chưa bị người khác sửa hoặc xoá kể từ lúc hiển thị danh sách, chưa tới giờ bắt đầu, không có ghế đang được giữ và không có vé đã bán chưa bị huỷ, rồi xoá suất chiếu khỏi lịch chiếu và giữ lại dữ liệu của suất chiếu, tất cả là một thao tác không chia cắt (BR-53, BR-54, BR-57, BR-58, BR-60). | |
| 1b3a | Suất chiếu đã chọn có ghế đang được giữ hoặc có vé đã bán chưa bị huỷ (BR-53); kiểm sau 1b3b | Hệ thống | Từ chối xoá và thông báo quy tắc bị vi phạm (BR-53). | Kết thúc use case (thất bại) |
| 1b3b | Suất chiếu đã chọn đã tới giờ bắt đầu, kể cả đã kết thúc (BR-57); kiểm sau 1b3c và trước 1b3a | Hệ thống | Từ chối xoá và thông báo quy tắc bị vi phạm (BR-57). | Kết thúc use case (thất bại) |
| 1b3c | Suất chiếu đã chọn đã bị người khác sửa hoặc xoá kể từ lúc hiển thị danh sách ở bước 1b1 (BR-60); kiểm trước 1b3b | Hệ thống | Từ chối xoá, không ghi đè, và thông báo suất chiếu đã thay đổi hoặc không còn; quản lý cụm rạp mở lại danh sách suất chiếu từ đầu (BR-60). | Kết thúc use case (thất bại) |
| 1b4 | | Hệ thống | Thông báo xoá suất chiếu thành công. | Kết thúc use case (thành công) |
| 4a | Phòng chiếu đã chọn không thuộc cụm rạp của quản lý cụm rạp (BR-46) | Hệ thống | Từ chối lưu suất chiếu và thông báo quy tắc bị vi phạm (BR-46). | Quay lại bước 3 |
| 5a | Định dạng đã chọn không là định dạng phát hành của phim (BR-47) | Hệ thống | Từ chối lưu suất chiếu và thông báo quy tắc bị vi phạm (BR-47). | Quay lại bước 3 |
| 5b | Định dạng đã chọn là định dạng phát hành của phim và phòng chiếu đã chọn không chiếu được định dạng đó (BR-48) | Hệ thống | Từ chối lưu suất chiếu và thông báo quy tắc bị vi phạm (BR-48). | Quay lại bước 3 |
| 5c | Phòng chiếu đã chọn chiếu được định dạng đã chọn và bảng giá của cụm rạp chưa có giá cho mọi loại ghế có trong phòng chiếu, ứng với khung giờ của giờ bắt đầu, theo loại phòng và định dạng đó (BR-69) | Hệ thống | Từ chối lưu suất chiếu và thông báo quy tắc bị vi phạm (BR-69). | Quay lại bước 3 |
| 6a | Ngày chiếu nằm ngoài khoảng từ ngày khởi chiếu tới ngày kết thúc chiếu của phim (BR-49) | Hệ thống | Từ chối lưu suất chiếu và thông báo quy tắc bị vi phạm (BR-49). | Quay lại bước 3 |
| 6b | Giờ bắt đầu không sau thời điểm hệ thống kiểm tra (BR-56), không thuộc 6a | Hệ thống | Từ chối lưu suất chiếu và thông báo quy tắc bị vi phạm (BR-56). | Quay lại bước 3 |
| 6c | Thời điểm mở bán không trước giờ bắt đầu (BR-55), không thuộc 6a, 6b | Hệ thống | Từ chối lưu suất chiếu và thông báo quy tắc bị vi phạm (BR-55). | Quay lại bước 3 |
| 8a | Quản lý cụm rạp đang sửa suất chiếu (luồng 1a) và tại thời điểm lưu suất chiếu có ghế đang được giữ hoặc có vé đã bán chưa bị huỷ (BR-53, BR-54), không thuộc 8c, 8d | Hệ thống | Từ chối lưu thay đổi và thông báo quy tắc bị vi phạm (BR-53). | Kết thúc use case (thất bại) |
| 8f | Quản lý cụm rạp đang sửa suất chiếu (luồng 1a), phòng chiếu đã chọn khác phòng chiếu hiện tại của suất chiếu và suất chiếu từng có vé, kể cả khi mọi vé đã huỷ (BR-92), không thuộc 8c, 8d, 8a; kiểm trước 8e | Hệ thống | Từ chối lưu thay đổi và thông báo quy tắc bị vi phạm (BR-92): không đổi phòng chiếu của suất chiếu đã từng có vé; muốn đổi phòng thì xoá suất chiếu rồi lập suất chiếu mới. | Kết thúc use case (thất bại) |
| 8g | Tại thời điểm lưu suất chiếu, phim vừa được sửa bởi UC-010 làm định dạng của suất chiếu không còn là định dạng phát hành (BR-47) hoặc ngày chiếu nằm ngoài khoảng chiếu (BR-49), kể cả khi phim được sửa sau lúc kiểm ở bước 5, 6 (BR-139), không thuộc 8c, 8d, 8a, 8f; kiểm trước 8e | Hệ thống | Từ chối lưu suất chiếu và thông báo quy tắc bị vi phạm (BR-47 hoặc BR-49). | Quay lại bước 3 |
| 8h | Tại thời điểm lưu suất chiếu, phòng chiếu đã chọn không còn vì vừa được xoá bởi UC-012 luồng 1b (BR-147, BR-136), không thuộc 8c, 8d | Hệ thống | Từ chối lưu suất chiếu và thông báo phòng chiếu không còn. | Quay lại bước 3 |
| 8e | Tại thời điểm lưu suất chiếu, bảng giá của cụm rạp chưa có giá cho mọi loại ghế có trong phòng chiếu, ứng với khung giờ của giờ bắt đầu, theo loại phòng và định dạng của suất chiếu, kể cả khi một mục giá vừa được bỏ bởi một yêu cầu khác của UC-013 (BR-68, BR-69), không thuộc 8a, 8c, 8d, 8f; kiểm trước 8b | Hệ thống | Từ chối lưu suất chiếu và thông báo quy tắc bị vi phạm (BR-69). | Quay lại bước 3 |
| 8b | Suất chiếu cách một suất chiếu khác trong phòng chiếu dưới 15 phút dọn phòng, kể cả khi suất chiếu xung đột vừa được lưu cùng lúc bởi một yêu cầu khác (BR-51, BR-52), không thuộc 8a, 8c, 8d, 8e, 8f | Hệ thống | Từ chối lưu suất chiếu và thông báo suất chiếu xung đột về thời gian dọn phòng (BR-51). | Quay lại bước 3 |
| 8c | Quản lý cụm rạp đang sửa suất chiếu (luồng 1a) và suất chiếu đã bị người khác sửa hoặc xoá kể từ lúc hiển thị ở bước 1a4 (BR-60); kiểm trước 8d, 8a, 8f, 8e, 8b | Hệ thống | Từ chối lưu thay đổi, không ghi đè, và thông báo suất chiếu đã thay đổi hoặc không còn; quản lý cụm rạp mở lại suất chiếu từ đầu (BR-60). | Kết thúc use case (thất bại) |
| 8d | Quản lý cụm rạp đang sửa suất chiếu (luồng 1a) và tại thời điểm lưu suất chiếu đã tới giờ bắt đầu (BR-57), không thuộc 8c; kiểm trước 8a, 8f, 8e, 8b | Hệ thống | Từ chối lưu thay đổi và thông báo quy tắc bị vi phạm (BR-57). | Kết thúc use case (thất bại) |
| *a | Tại bất kỳ bước nào trước bước 8, kể cả trong luồng 1a và 1b trước bước 1a3, 1b3, quản lý cụm rạp huỷ yêu cầu | Hệ thống | Huỷ yêu cầu, không thay đổi suất chiếu nào. | Kết thúc use case (thất bại) |

## 4. Luồng con

Không có

## 5. Dữ liệu vào và dữ liệu ra

Dữ liệu vào 1 (bước 3)

| STT | Trường dữ liệu | Mô tả | Bắt buộc | Điều kiện hợp lệ | Ví dụ |
|---|---|---|---|---|---|
| 1 | Phim | Phim được chiếu trong suất chiếu | Có | Một phim trong danh sách phim của chuỗi; ngày chiếu nằm trong khoảng chiếu của phim (BR-49) | Phim A |
| 2 | Định dạng | Định dạng chiếu của suất chiếu | Có | Một định dạng phát hành của phim (BR-47), 2D hoặc 3D (REQ-55); phòng chiếu đã chọn chiếu được định dạng này (BR-48); bảng giá của cụm rạp có giá cho loại phòng và định dạng này (BR-69) | 3D |
| 3 | Phòng chiếu | Phòng chiếu diễn ra suất chiếu | Có | Phòng chiếu thuộc cụm rạp của quản lý cụm rạp (BR-46); khi sửa, không khác phòng chiếu hiện tại nếu suất chiếu đã từng có vé, kể cả vé đã huỷ (BR-92) | Phòng 3 |
| 4 | Ngày giờ bắt đầu | Ngày và giờ bắt đầu suất chiếu; là mốc ngừng bán vé (BR-45) và xác định khung giờ chiếu để tính giá vé (BR-12) | Có | Ngày chiếu thuộc khoảng chiếu của phim (BR-49); sau thời điểm hệ thống kiểm tra (BR-56); giờ kết thúc cách suất chiếu khác trong phòng ít nhất 15 phút (BR-51); bảng giá của cụm rạp có giá cho khung giờ này của mọi loại ghế trong phòng chiếu (BR-69) | 15/11/2026 19:30 |
| 5 | Thời điểm mở bán | Thời điểm từ đó khách và nhân viên quầy được đặt hoặc mua vé của suất chiếu (BR-01) | Có (REQ-61) | Trước ngày giờ bắt đầu của suất chiếu (BR-55) | 10/11/2026 08:00 |

Dữ liệu vào 2 (bước 1a2, 1b2)

| STT | Trường dữ liệu | Mô tả | Bắt buộc | Điều kiện hợp lệ | Ví dụ |
|---|---|---|---|---|---|
| 1 | Suất chiếu cần sửa hoặc xoá | Một suất chiếu đã lập trong danh sách ở Dữ liệu ra 3 | Có | Suất chiếu của phòng chiếu thuộc cụm rạp của quản lý cụm rạp (BR-46); chưa tới giờ bắt đầu (BR-57); không có ghế đang được giữ và không có vé đã bán chưa bị huỷ (BR-53) | Phim A, Phòng 3, 15/11/2026 19:30 |

Dữ liệu ra 1 (bước 2, bước 1a4)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Phòng chiếu | Với mỗi phòng chiếu của cụm rạp: tên phòng, loại phòng (phòng thường, 4DX hoặc IMAX), các định dạng chiếu được (REQ-57) | Văn bản | Phòng 3, phòng thường, 2D và 3D |
| 2 | Phim | Với mỗi phim: tên, các định dạng phát hành, thời lượng, ngày khởi chiếu, ngày kết thúc chiếu (REQ-07, REQ-55, REQ-95) | Thời lượng là số phút; ngày dạng dd/mm/yyyy; các trường còn lại là văn bản | Phim A, 2D và 3D, 120 phút, 01/11/2026, 30/11/2026 |

Dữ liệu ra 2 (bước 9, bước 1a4)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Suất chiếu | Phim, định dạng, phòng chiếu, ngày giờ bắt đầu, giờ kết thúc (BR-50), thời điểm mở bán | Ngày giờ dạng dd/mm/yyyy hh:mm; các trường còn lại là văn bản | Phim A, 3D, Phòng 3, 15/11/2026 19:30, 15/11/2026 21:30, 10/11/2026 08:00 |

Dữ liệu ra 3 (bước 1a1, 1b1)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Danh sách suất chiếu đã lập | Với mỗi suất chiếu của các phòng chiếu thuộc cụm rạp: phim, định dạng, phòng chiếu, ngày giờ bắt đầu, giờ kết thúc, thời điểm mở bán | Như Dữ liệu ra 2 | Phim A, 3D, Phòng 3, 15/11/2026 19:30, 15/11/2026 21:30, 10/11/2026 08:00 |

## 6. Quy tắc nghiệp vụ

| BR | Quy tắc | Loại | Bước áp dụng | REQ | Trong sổ BR |
|---|---|---|---|---|---|
| BR-01 | Trước thời điểm mở bán của suất chiếu, không ai được đặt hoặc mua vé của suất chiếu đó. | Ràng buộc | Dữ liệu vào 1 (chỉ mô tả trường; kiểm ở UC-005) | REQ-86; REQ-61 (phụ) | Đã có |
| BR-12 | Khung giờ chiếu xác định theo giờ bắt đầu của suất chiếu; cuối tuần gồm Thứ Bảy và Chủ nhật. | Suy luận | Dữ liệu vào 1 (chỉ mô tả trường; kiểm ở UC-005) | REQ-91 | Đã có |
| BR-45 | Từ giờ bắt đầu của suất chiếu, không ai được bắt đầu đặt hoặc mua vé của suất chiếu đó; quy tắc áp dụng cả khi bán tại quầy. | Ràng buộc | Dữ liệu vào 1 (chỉ mô tả trường; kiểm ở UC-005) | REQ-135; REQ-61, REQ-86 (phụ) | Đã có |
| BR-46 | Quản lý cụm rạp chỉ lập, sửa, xoá suất chiếu của các phòng chiếu thuộc cụm rạp của mình. | Ràng buộc | 1a1, 1b1, 4, 4a, Dữ liệu vào 1, Dữ liệu vào 2 | REQ-60; REQ-100 (phụ) | Mới |
| BR-47 | Định dạng của suất chiếu phải là một định dạng phát hành của phim. | Ràng buộc | 5, 5a, Dữ liệu vào 1 | REQ-62; REQ-55 (phụ) | Mới |
| BR-48 | Phòng chiếu của suất chiếu phải chiếu được định dạng của suất chiếu. | Ràng buộc | 5, 5b, Dữ liệu vào 1 | REQ-63; REQ-57 (phụ) | Mới |
| BR-49 | Ngày chiếu của suất chiếu phải nằm trong khoảng từ ngày khởi chiếu tới ngày kết thúc chiếu của phim. | Ràng buộc | 6, 6a, Dữ liệu vào 1 | REQ-97; REQ-95 (phụ) | Mới |
| BR-50 | Khi lập hoặc sửa suất chiếu, giờ kết thúc được tính bằng giờ bắt đầu cộng thời lượng phim tại thời điểm đó. | Tính toán | 7, Dữ liệu ra 2 | REQ-98; REQ-07 (phụ) | Mới |
| BR-51 | Hai suất chiếu trong cùng một phòng chiếu phải cách nhau ít nhất 15 phút dọn phòng, tính từ giờ kết thúc của suất trước. | Ràng buộc | 8, 8b, Dữ liệu vào 1 | REQ-64 | Mới |
| BR-52 | Việc kiểm tra khoảng cách giữa các suất chiếu trong phòng chiếu và việc lưu suất chiếu lập hoặc sửa là một thao tác không chia cắt trên các suất chiếu của phòng chiếu; khi hai yêu cầu lập hoặc sửa đồng thời (của hai quản lý cụm rạp hoặc hai phiên làm việc) cùng làm hai suất chiếu trong một phòng vi phạm khoảng cách dọn phòng, chỉ một yêu cầu được lưu. | Ràng buộc | 8, 8b | REQ-64 | Mới |
| BR-53 | Không được sửa hoặc xoá suất chiếu đang có ghế được giữ hoặc có vé đã bán chưa bị huỷ; ghế đã quá thời điểm hết hạn giữ ghế không còn là ghế được giữ, kể cả khi chưa được giải phóng. | Ràng buộc | 1a3, 1a3a, 1b3, 1b3a, 8, 8a, Dữ liệu vào 2 | REQ-65, REQ-141 | Mới |
| BR-54 | Việc giữ ghế của một suất chiếu và việc kiểm tra BR-53 rồi sửa hoặc xoá suất chiếu đó không xen vào nhau: nếu giữ ghế được ghi nhận trước thì sửa hoặc xoá bị từ chối theo BR-53; nếu sửa hoặc xoá được ghi nhận trước thì việc giữ ghế trên suất chiếu như tác nhân đã xem lúc chọn ghế bị từ chối vì suất chiếu đã thay đổi hoặc không còn. | Ràng buộc | 1b3, 8 | REQ-65, REQ-142 | Mới |
| BR-55 | Thời điểm mở bán của suất chiếu phải trước giờ bắt đầu của suất chiếu. | Ràng buộc | 6, 6c, Dữ liệu vào 1 | REQ-137; REQ-61, REQ-86, REQ-135 (phụ) | Mới |
| BR-56 | Khi lập suất chiếu mới hoặc sửa suất chiếu, giờ bắt đầu phải sau thời điểm hệ thống kiểm tra. | Ràng buộc | 6, 6b, Dữ liệu vào 1 | REQ-138 | Mới |
| BR-57 | Suất chiếu đã tới giờ bắt đầu, kể cả đã kết thúc, không được sửa hoặc xoá. | Ràng buộc | 1a3, 1a3b, 1b3, 1b3b, 8, 8d, Dữ liệu vào 2 | REQ-139 | Mới |
| BR-58 | Xoá suất chiếu là bỏ suất chiếu khỏi lịch chiếu và ngừng bán vé của suất chiếu đó; thông tin của suất chiếu vẫn được giữ cho vé đã huỷ, hoàn tiền (kể cả thanh toán trễ) và báo cáo. | Ràng buộc | 1b3 | REQ-140 | Mới |
| BR-92 | Không được đổi phòng chiếu của suất chiếu đã từng có vé, kể cả khi mọi vé của suất chiếu đó đã huỷ; muốn đổi phòng thì xoá suất chiếu đó theo các quy tắc xoá suất chiếu (BR-53, BR-57, BR-58) rồi lập suất chiếu mới. | Ràng buộc | 8, 8f, Dữ liệu vào 1 | REQ-65, REQ-141 | Mới |
| BR-60 | Khi suất chiếu đã bị người khác sửa hoặc xoá kể từ lúc quản lý cụm rạp được hiển thị, yêu cầu sửa hoặc xoá của quản lý cụm rạp sau bị từ chối và không ghi đè thay đổi trước. | Ràng buộc | 1b3, 1b3c, 8, 8c | REQ-143 | Mới |
| BR-64 | Không được bỏ mục giá khi cụm rạp còn suất chiếu chưa tới giờ bắt đầu và còn trong lịch chiếu mà loại phòng của phòng chiếu và định dạng bằng của mục giá, phòng chiếu có ít nhất một ghế thuộc loại ghế của mục giá, và khung giờ xác định theo giờ bắt đầu (BR-12) bằng khung giờ của mục giá. | Ràng buộc | Mục 8 (kiểm ở UC-013) | REQ-146; REQ-145 (phụ) | Đã có |
| BR-136 | Việc kiểm tra BR-73 và BR-87 rồi lưu thay đổi phòng chiếu hoặc sơ đồ ghế, với việc kiểm tra BR-69 rồi lưu suất chiếu lập hoặc sửa của phòng chiếu đó (UC-014 bước 8) và với việc kiểm tra BR-64 rồi bỏ mục giá (UC-013 luồng 1a3), không xen vào nhau: yêu cầu được ghi nhận trước thì thành công, yêu cầu ghi nhận sau thấy kết quả của yêu cầu trước và bị từ chối theo quy tắc của mình khi vi phạm. | Ràng buộc | 8, 8e, 8h | REQ-162, REQ-145; REQ-151 (phụ) | Đã có |
| BR-139 | Việc lưu phim đã sửa (UC-010 bước 5) và việc kiểm BR-47, BR-49, tính BR-50 rồi lưu suất chiếu lập hoặc sửa (UC-014 bước 5 đến 8) không xen vào nhau: phim sửa được ghi nhận trước thì bước 8 dùng phim hiện hành, thất bại thì quay lại bước 3 như BR-68 với bảng giá; phim sửa được ghi nhận sau không đổi suất chiếu đã lưu (BR-84). | Ràng buộc | 5, 6, 7, 8, 8g | REQ-53, REQ-144; REQ-97, REQ-98 (phụ) | Đã có |
| BR-147 | Chỉ xoá được phòng chiếu chưa từng có suất chiếu, kể cả suất chiếu đã xoá; phòng chiếu đã từng có suất chiếu không xoá được và không có trạng thái ngừng sử dụng. | Ràng buộc | 8h | REQ-56; REQ-140, REQ-141 (phụ) | Đã có |
| BR-68 | Việc kiểm tra BR-64 rồi bỏ mục giá và việc kiểm tra BR-69 rồi lưu suất chiếu lập hoặc sửa (UC-014 bước 8) không xen vào nhau: nếu suất chiếu được ghi nhận trước thì bỏ giá bị từ chối theo BR-64; nếu bỏ giá được ghi nhận trước thì lập hoặc sửa suất chiếu bị từ chối theo BR-69. | Ràng buộc | 8, 8e | REQ-151; REQ-145 (phụ) | Đã có |
| BR-69 | Không được lập suất chiếu, hoặc sửa suất chiếu thành suất chiếu, khi bảng giá của cụm rạp chưa có giá cho mọi loại ghế có trong phòng chiếu (loại ghế mà phòng chiếu có ít nhất một ghế), ứng với khung giờ xác định theo giờ bắt đầu của suất chiếu (BR-12), theo loại phòng của phòng chiếu và định dạng phim của suất chiếu. | Ràng buộc | 5, 5c, 8, 8e, Dữ liệu vào 1 (trường 2, 4) | REQ-145; REQ-37, REQ-38 (phụ) | Đã có |
| BR-84 | Phim hoặc phòng chiếu thay đổi sau khi lập suất chiếu không làm suất chiếu đã lập tự đổi. | Ràng buộc | Mục 8 | REQ-144 | Đã có |

## 7. Yêu cầu đặc biệt

Không có

## 8. Thông tin bổ sung

- Luồng chính là kịch bản lập suất chiếu mới (REQ-60). Sửa và xoá suất chiếu (REQ-65) là luồng 1a và 1b: quản lý cụm rạp chọn một trong ba thao tác thay cho bước 1, nên trên activity diagram decision D-1 đặt ngay sau INIT, trước A-1. Luồng 1a quay về bước 3 để nhập thông tin mới; bước 4 đến bước 8 áp dụng như khi lập, trong đó bước 8 cập nhật suất chiếu đã chọn và khi tính BR-51 bỏ qua chính suất chiếu đang sửa.
- Bước 8 gộp mọi kiểm tra quyết định việc lưu và việc lưu thành một thao tác không chia cắt: khoảng cách dọn phòng (BR-51, BR-52), bảng giá còn đủ giá cho suất chiếu (BR-68, BR-69) và, khi sửa, suất chiếu chưa bị người khác sửa hoặc xoá (BR-60), chưa tới giờ bắt đầu (BR-57), không có ghế đang giữ hoặc vé chưa huỷ (BR-53, BR-54). Phạm vi của thao tác là các suất chiếu của phòng chiếu đích và chính suất chiếu đang sửa. Khi sửa sang phòng chiếu khác, việc kiểm khoảng cách áp dụng cho phòng mới; phòng cũ chỉ bớt một suất chiếu nên không cần kiểm. Lý do: nếu tách rời, hai yêu cầu đồng thời đều thấy khoảng giờ còn trống rồi cùng lưu, vi phạm BR-51 (BR-52); và khách hoặc nhân viên quầy có thể giữ ghế (UC-005 bước 7) giữa lúc kiểm BR-53 và lúc lưu, khiến suất chiếu bị sửa khi đã có ghế giữ (BR-54). Điểm đua giữ ghế với sửa nằm ngay tại bước 8. Phim bị sửa bởi UC-010 xen vào giữa bước 5 đến 7 (đọc định dạng phát hành, khoảng chiếu, thời lượng) và bước 8 (lưu) được xử lý ở bước 8: bước 8 kiểm lại BR-47, BR-49, tính lại giờ kết thúc theo BR-50 với phim hiện hành, bên ghi nhận trước thành công, bên sau bị từ chối (luồng 8g quay lại bước 3, như BR-68 với bảng giá); phim sửa ghi nhận sau suất chiếu không đổi suất chiếu đã lưu (BR-84, BR-139). Sửa sơ đồ ghế, loại phòng của phòng chiếu bởi UC-012 bước 5 xen vào bước 8 theo BR-136 (BR-87, BR-73 từ chối bên ghi nhận sau); xoá phòng bởi UC-012 luồng 1b chỉ thành công khi phòng chưa từng có suất chiếu (BR-147), nên bước 8 ghi nhận trước thì xoá phòng bị từ chối, xoá phòng ghi nhận trước thì bước 8 bị từ chối ở luồng 8h. Việc kiểm bảng giá ở bước 8 loại trừ với việc bỏ mục giá của UC-013 (BR-68): quản lý cụm rạp khác có thể bỏ mục giá giữa lúc bước 5 kiểm sớm và bước 8 lưu; bên ghi nhận trước thành công, bên sau bị từ chối (luồng 8e quay lại bước 3, hoặc UC-013 luồng 1a3b). Cơ chế bảo đảm thuộc bước thiết kế (P07, P09). BR-52 là hệ quả của REQ-64 khi yêu cầu đồng thời, nguồn không quy định riêng.
- Luồng 1a3 kiểm sớm BR-57 và BR-53 để báo ngay khi chọn suất chiếu, nhưng không thay cho bước 8: giữa lúc chọn và lúc lưu, quản lý cụm rạp nhập thông tin trong một khoảng thời gian, trong đó khách hoặc nhân viên quầy có thể giữ ghế (UC-005 bước 7) hoặc suất chiếu có thể đã bị sửa, xoá bởi người khác. Với luồng 1b, kiểm tra và xoá là một thao tác (1b3).
- Thứ tự kiểm ở bước 8: 8c, 8d, 8a, 8e, rồi 8b. 8c đứng đầu vì khi thông tin quản lý cụm rạp đang sửa đã cũ thì các kiểm tra khác không còn ý nghĩa; 8d, 8a là trạng thái của chính suất chiếu, và nếu sửa bị từ chối thì không cần xét bảng giá, lịch phòng; 8e xét bảng giá trước 8b vì thiếu giá không sửa được bằng cách đổi giờ trong phòng đã chọn; nguồn không nêu thứ tự báo khi nhiều điều kiện cùng vi phạm. Ở luồng 1b3 thứ tự là 1b3c, 1b3b, 1b3a, ở luồng 1a3 là 1a3b rồi 1a3a.
- Ghế đã quá thời điểm hết hạn giữ ghế không còn chặn sửa hoặc xoá suất chiếu, kể cả khi chưa được giải phóng (trả lời Q-55, BR-53); mốc tính theo thời điểm hết hạn như BR-10, BR-14, BR-44 và UC-005 Mục 8, không theo thời điểm giải phóng (REQ-76). Việc giải phóng ghế đó (tối đa 1 phút sau thời điểm hết hạn) vẫn phải hoàn tất khi suất chiếu đã được sửa hoặc xoá trong khoảng này; cơ chế thuộc P07, P09.
- Xoá suất chiếu giữ lại dữ liệu của suất chiếu (trả lời Q-54, BR-58): vé đã huỷ, email hoàn tiền (tên phim, suất chiếu, REQ-116), lịch sử đặt vé và báo cáo doanh thu, tỉ lệ lấp đầy (REQ-66, REQ-67, REQ-99) vẫn tra được. Trường hợp đáng chú ý: thanh toán thành công báo về sau thời điểm hết hạn giữ ghế (UC-006, BR-14) khi lần giữ ghế đã không còn ghế đang giữ và chưa có vé nên BR-53 không chặn xoá; UC-006 vẫn hoàn toàn bộ tiền và gửi email có thông tin suất chiếu đã xoá.
- Đổi phòng chiếu của suất chiếu đã từng có vé bị chặn hẳn, kể cả khi mọi vé đã huỷ (BR-92, chủ dự án chốt): vé đã huỷ vẫn gắn với ghế của phòng cũ trong lịch sử đặt vé và email hoàn tiền. Muốn đổi phòng, quản lý cụm rạp xoá suất chiếu cũ (luồng 1b, giữ dữ liệu theo BR-58) rồi lập suất chiếu mới (luồng chính). Hệ quả: suất chiếu còn ghế đang được giữ hoặc còn vé chưa huỷ thì không đổi phòng được và cũng không xoá được (BR-53), phải chờ ghế hết hạn hoặc vé được huỷ (UC-008); suất chiếu đã tới giờ bắt đầu thì không đổi, không xoá (BR-57). Use case không có luồng nào buộc huỷ vé hay chuyển vé sang suất chiếu mới.
- Việc giữ ghế ở UC-005 bước 7 và việc kiểm tra BR-53 rồi sửa hoặc xoá loại trừ nhau trên cùng suất chiếu (BR-54). Chiều giữ ghế được ghi nhận trước: sửa hoặc xoá bị từ chối (BR-53). Chiều sửa hoặc xoá được ghi nhận trước: ghế khách đang chọn chưa giữ (BR-03) nên REQ-65 không chặn; khi khách xác nhận chọn ghế, UC-005 luồng 7d từ chối giữ ghế vì suất chiếu đã thay đổi hoặc không còn (trả lời Q-56).
- Hai quản lý cùng sửa một suất chiếu thì người lưu sau bị từ chối, không ghi đè (trả lời Q-57, BR-60): luồng 8c cho sửa, luồng 1b3c cho xoá. Đua có thể xảy ra giữa hai quản lý cụm rạp hoặc hai phiên làm việc của cùng một người.
- Phim (UC-010) đổi thời lượng, định dạng phát hành hoặc khoảng chiếu, hoặc phòng chiếu (UC-012) đổi định dạng chiếu được hay bị xoá, sau khi suất chiếu đã lập thì không tự đổi suất chiếu đã lập (trả lời Q-58, REQ-144). BR-47 đến BR-49, BR-51 và BR-69 chỉ kiểm, BR-50 chỉ tính, khi lập hoặc sửa suất chiếu; giờ kết thúc đã tính giữ nguyên cho tới khi suất chiếu được sửa (BR-84).
- Theo trả lời Q-61 (phương án A), UC-014 chặn từ gốc: bảng giá phải có giá cho mọi loại ghế có trong phòng chiếu, ứng với khung giờ của giờ bắt đầu, theo loại phòng và định dạng của suất chiếu (BR-69). BR-59 (trả lời Q-59) chỉ xét loại phòng và định dạng, là trường hợp riêng của BR-69 và đã gộp vào BR-69 trong sổ BR. Quản lý cụm rạp đặt giá ở UC-013 trước, lập suất chiếu sau. Giá bị bỏ khỏi bảng giá sau khi lập suất chiếu được chặn ở UC-013 (BR-64); UC-005 luồng 7e là lưới an toàn khi bảng giá vẫn thiếu giá (BR-72), chẳng hạn do UC-012 sửa phòng chiếu.
- "Ngày chiếu" ở BR-49 hiểu là ngày của ngày giờ bắt đầu (REQ-61); hai ngày khởi chiếu và kết thúc chiếu thuộc khoảng chiếu, theo REQ-96 (phim đang chiếu là phim chưa qua ngày kết thúc chiếu).
- "Ít nhất 15 phút" ở BR-51: giờ bắt đầu của suất sau không sớm hơn giờ kết thúc của suất trước cộng 15 phút; bằng đúng 15 phút là hợp lệ. Ví dụ (BR-50, BR-51): suất bắt đầu 19:30, phim 120 phút, giờ kết thúc 19:30 + 2 giờ = 21:30; suất kế tiếp trong phòng bắt đầu sớm nhất 21:30 + 15 phút = 21:45.
- "Giờ bắt đầu sau thời điểm hệ thống kiểm tra" ở BR-56: giờ bắt đầu bằng đúng thời điểm kiểm tra là đã qua, bị từ chối ở luồng 6b. Thời điểm mở bán chỉ ràng buộc phải trước giờ bắt đầu (BR-55); nguồn không ràng buộc nó so với thời điểm lập suất chiếu.
- Danh sách phòng chiếu, loại phòng và định dạng chiếu được lấy từ dữ liệu của UC-012 (REQ-57); danh sách phim, định dạng phát hành, thời lượng và khoảng chiếu lấy từ dữ liệu của UC-010 (REQ-07, REQ-55, REQ-95); bảng giá lấy từ dữ liệu của UC-013 (REQ-37, REQ-38). UC-012 không cho sửa sơ đồ ghế của phòng đang có suất chiếu chưa diễn ra đã bán vé hoặc có ghế đang giữ (REQ-58); UC-014 áp dụng điều kiện tương tự cho chính suất chiếu (BR-53).
- Giá vé của suất chiếu tính theo bảng giá của cụm rạp (UC-013) từ loại phòng, định dạng, loại ghế và khung giờ của giờ bắt đầu (BR-11, BR-12); UC-014 chỉ kiểm bảng giá có đủ giá (BR-69), không tính giá.
- Không có bước hẹn hoặc huỷ mốc (F4.2 mục 17): thời điểm mở bán (BR-01) và giờ bắt đầu (BR-45) được UC-005 so với thời điểm hiện tại mỗi khi có yêu cầu đặt vé, không có use case do tác nhân thời gian kích hoạt dùng chúng làm mốc.
- Bước sinh theo quy tắc của prompt: bước 9 và bước 1b4 (báo kết quả cho quản lý cụm rạp, Target 5a); hành động "Từ chối ... và thông báo quy tắc bị vi phạm" ở luồng 1a3a, 1a3b, 1b3a, 1b3b, 4a, 5a, 5b, 5c, 6a, 6b, 6c, 8a, 8b, 8d, 8e, 8f theo F5.7; luồng 8c, 1b3c là từ chối vì suất chiếu đã thay đổi, người dùng không sửa được tại chỗ; điểm quay lại bước 3 ở luồng 4a, 5a, 5b, 5c, 6a, 6b, 6c, 8b, 8e theo F5.7 vì quản lý cụm rạp sửa được dữ liệu vi phạm (với 5c, 8e: chọn phòng, định dạng hoặc giờ khác, hoặc bổ sung giá ở UC-013 rồi lập lại). Luồng 8c, 1b3c kết thúc thất bại vì quản lý cụm rạp phải mở lại suất chiếu hiện hành mới biết thông tin mới.

Thao tác nguyên tử:

| Thao tác | Bước | Tài nguyên | Bất biến giữ được | Loại trừ với | Kết cục bên thua | Căn cứ |
|---|---|---|---|---|---|---|
| Kiểm và lưu suất chiếu (lập hoặc sửa) | 8 | Lịch các suất chiếu của phòng chiếu; suất chiếu đang sửa; bảng giá của cụm rạp; ghế đang giữ và vé của suất chiếu đang sửa | Hai suất chiếu trong một phòng cách nhau ít nhất 15 phút dọn phòng; suất chiếu có ghế đang giữ còn hiệu lực hoặc vé chưa huỷ không bị sửa; yêu cầu sau không ghi đè thay đổi trước; bảng giá còn đủ giá cho suất chiếu đã lưu; không đổi phòng của suất chiếu đã từng có vé. Mọi kiểm tra và việc lưu là một thao tác | Chính nó (cùng phòng chiếu hoặc cùng suất chiếu); xoá suất chiếu (luồng 1b3); UC-005 bước 7 (giữ ghế) và bước 12, 9a2 (bán ghế, tạo vé); UC-008 bước 4 (huỷ vé); UC-013 bước 5 và luồng 1a3 (bỏ giá); UC-010 bước 5 (lưu phim, BR-139); UC-012 bước 5 (sửa loại phòng, loại ghế, sơ đồ ghế của phòng chiếu, BR-136) và luồng 1b3 (xoá phòng chiếu, BR-147) | Hai yêu cầu cùng phòng làm vi phạm khoảng cách: chỉ một yêu cầu được lưu, bên sau bị từ chối (luồng 8b). Cùng suất chiếu: bên sau thấy suất chiếu đã đổi và bị từ chối (luồng 8c). Giữ ghế ghi nhận trước thì sửa bị từ chối theo BR-53 (luồng 8a); sửa ghi nhận trước thì giữ ghế bị từ chối (UC-005 luồng 7d). Bán ghế, tạo vé: sửa thấy lần giữ ghế còn Đang giữ hoặc vé đã tạo, không thấy trạng thái dở dang. Huỷ vé ghi nhận trước thì sửa thấy vé đã huỷ. Bỏ giá ghi nhận trước thì lưu bị từ chối vì thiếu giá (luồng 8e); lưu ghi nhận trước thì bỏ giá bị từ chối (UC-013 luồng 1a3b). Phim sửa ghi nhận trước làm sai định dạng hoặc khoảng chiếu thì lưu bị từ chối (luồng 8g); phim sửa ghi nhận sau không đổi suất chiếu đã lưu (BR-84). UC-012 bước 5 ghi nhận trước thì lưu bị từ chối theo BR-69 khi thiếu giá (luồng 8e); lưu ghi nhận trước thì UC-012 sửa sơ đồ ghế bị từ chối theo BR-87 khi suất chiếu đã tới thời điểm mở bán, sửa loại phòng, loại ghế bị từ chối theo BR-73 khi thiếu giá. UC-012 luồng 1b3 ghi nhận trước thì lưu bị từ chối ở luồng 8h; lưu ghi nhận trước thì xoá phòng bị từ chối theo BR-147. Ghế đã quá thời điểm hết hạn mà chưa giải phóng không chặn sửa (BR-53), ghế đó vẫn được giải phóng theo UC-005 luồng 7b | BR-51, BR-52, BR-53, BR-54, BR-57, BR-60, BR-68, BR-69, BR-92, BR-136, BR-139, BR-147, REQ-64, REQ-65 |
| Kiểm và xoá suất chiếu khỏi lịch chiếu | 1b3 | Suất chiếu; ghế đang giữ và vé của suất chiếu | Suất chiếu có ghế đang giữ còn hiệu lực hoặc vé chưa huỷ không bị xoá; yêu cầu sau không ghi đè thay đổi trước; dữ liệu suất chiếu được giữ lại. Kiểm tra và xoá là một thao tác | Chính nó và sửa suất chiếu (cùng suất chiếu); UC-005 bước 7 (giữ ghế) và bước 12, 9a2 (bán ghế, tạo vé); UC-008 bước 4 (huỷ vé) | Bên sau thấy suất chiếu đã đổi hoặc không còn và bị từ chối (luồng 1b3c, 8c). Giữ ghế ghi nhận trước thì xoá bị từ chối theo BR-53 (luồng 1b3a); xoá ghi nhận trước thì giữ ghế bị từ chối (UC-005 luồng 7d). Sau khi xoá, việc giải phóng ghế đã hết hạn (UC-005 luồng 7b) và trả ghế của vé đã huỷ (UC-008 bước 7) vẫn chạy được nhờ dữ liệu suất chiếu được giữ lại | BR-53, BR-54, BR-57, BR-58, BR-60, REQ-65 |

## 8a. Kịch bản chính

- KB1: Luồng chính --> quản lý cụm rạp lập suất chiếu mới thành công.
- KB2: Luồng chính + 8b --> suất chiếu cách suất khác dưới 15 phút, quay lại bước 3, chọn giờ khác rồi lập thành công.
- KB3: Luồng 1a + luồng chính từ bước 3 --> sửa suất chiếu chưa có ghế giữ, vé thành công.
- KB4: Luồng 1a + 1a3a (hoặc 1a3b, 8a, 8d) --> sửa bị từ chối vì suất chiếu có ghế đang giữ, vé đã bán chưa huỷ hoặc đã tới giờ bắt đầu.
- KB4b: Luồng 1a + 8f --> đổi phòng của suất chiếu từng có vé bị từ chối; quản lý cụm rạp xoá suất chiếu (luồng 1b, khi BR-53 cho phép) rồi lập suất chiếu mới (luồng chính) ở phòng chiếu khác.
- KB5: Luồng 1b --> xoá suất chiếu chưa có ghế giữ, vé thành công, dữ liệu suất chiếu được giữ lại; với 1b3a (hoặc 1b3b) --> xoá bị từ chối.
- KB6: Luồng chính + 5c, 6b hoặc 6c --> bảng giá chưa đủ giá, giờ bắt đầu đã qua hoặc mở bán không trước giờ bắt đầu, quay lại bước 3, sửa dữ liệu rồi lập thành công.
- KB7: Luồng 1a + 8c (hoặc luồng 1b + 1b3c) --> hai quản lý cùng thao tác trên một suất chiếu, người lưu sau bị từ chối, không ghi đè.
- KB8: Luồng chính + 8e --> một mục giá bị bỏ ở UC-013 giữa lúc kiểm bảng giá (bước 5) và lúc lưu (bước 8), lưu suất chiếu bị từ chối, quay lại bước 3.

## 9. Activity diagram

File: diagrams/P04-activity-UC-014.drawio

Bảng đối chiếu

| Bước UC | Node |
|---|---|
| 1 | D-1, A-1 |
| 2 | A-2 |
| 3 | M-3, A-3 |
| 4, 4a | A-4, D-4, A-4a |
| 5, 5a, 5b, 5c | A-5, D-5, A-5a, A-5b, A-5c |
| 6, 6a, 6b, 6c | A-6, D-6, A-6a, A-6b, A-6c |
| 7 | A-7 |
| 8g, 8h | N-8g, N-8h |
| 8, 8a, 8b, 8c, 8d, 8e, 8f | A-8, D-8, A-8a, A-8b, A-8c, A-8d, A-8e, A-8f, FINAL-1, FINAL-6, FINAL-7, FINAL-11 |
| 9 | A-9, FINAL-2 |
| 1a1, 1a2, 1a3, 1a3a, 1a3b, 1a4 | A-1a1, A-1a2, A-1a3, D-1a3, A-1a3a, A-1a3b, FINAL-3, FINAL-8, A-1a4 |
| 1b1, 1b2, 1b3, 1b3a, 1b3b, 1b3c, 1b4 | A-1b1, A-1b2, A-1b3, D-1b3, A-1b3a, A-1b3b, A-1b3c, FINAL-4, FINAL-9, FINAL-10, A-1b4, FINAL-5 |
| *a | N-*a |

Bảng Node

| ID | Loại | Nhãn | Stereotype | Thuộc về (container) | Bước UC | Ghi chú |
|---|---|---|---|---|---|---|
| P-ACT-04 | Partition | Quản lý cụm rạp | - | - | - | x=0, w=560 |
| P-SYS | Partition | Hệ thống | - | - | - | x=560, w=691 |
| INIT | Initial | - | - | P-ACT-04 | - | x=130, y=60 (tương đối partition) |
| D-1 | Decision | - | - | P-ACT-04 | 1a, 1b | x=130, y=130 (tương đối partition) |
| A-1 | Action | Yêu cầu lập suất chiếu mới | - | P-ACT-04 | 1 | x=60, y=210 (tương đối partition) |
| A-2 | Action | Hiển thị phòng chiếu và phim | - | P-SYS | 2 | x=60, y=210 (tương đối partition) |
| M-3 | Merge | - | - | P-ACT-04 | 4a, 5a, 5b, 5c, 6a, 6b, 6c, 8b, 8e, 1a4 | x=130, y=330 (tương đối partition) |
| A-3 | Action | Nhập thông tin suất chiếu | - | P-ACT-04 | 3 | x=60, y=400 (tương đối partition) |
| A-4 | Action | Kiểm tra phòng thuộc cụm rạp | - | P-SYS | 4 | x=60, y=400 (tương đối partition) |
| D-4 | Decision | - | - | P-SYS | 4a | x=130, y=500 (tương đối partition) |
| A-4a | Action | Từ chối: phòng khác cụm rạp (BR-46) | - | P-SYS | 4a | x=320, y=490 (tương đối partition) |
| A-5 | Action | Kiểm tra định dạng, phòng và bảng giá | - | P-SYS | 5 | x=60, y=600 (tương đối partition) |
| D-5 | Decision | - | - | P-SYS | 5a, 5b, 5c | x=130, y=700 (tương đối partition) |
| A-5a | Action | Từ chối: không phải định dạng phát hành (BR-47) | - | P-SYS | 5a | x=320, y=690 (tương đối partition) |
| A-5b | Action | Từ chối: phòng không chiếu được định dạng (BR-48) | - | P-SYS | 5b | x=320, y=790 (tương đối partition) |
| A-5c | Action | Từ chối: bảng giá chưa đủ giá cho suất chiếu (BR-69) | - | P-SYS | 5c | x=320, y=890 (tương đối partition) |
| A-6 | Action | Kiểm tra ngày chiếu, giờ bắt đầu, mở bán | - | P-SYS | 6 | x=60, y=900 (tương đối partition) |
| D-6 | Decision | - | - | P-SYS | 6a, 6b, 6c | x=130, y=990 (tương đối partition) |
| A-6a | Action | Từ chối: ngày chiếu ngoài khoảng chiếu (BR-49) | - | P-SYS | 6a | x=320, y=980 (tương đối partition) |
| A-6b | Action | Từ chối: giờ bắt đầu đã qua (BR-56) | - | P-SYS | 6b | x=320, y=1080 (tương đối partition) |
| A-6c | Action | Từ chối: mở bán không trước giờ bắt đầu (BR-55) | - | P-SYS | 6c | x=320, y=1180 (tương đối partition) |
| A-7 | Action | Tính giờ kết thúc suất chiếu | - | P-SYS | 7 | x=60, y=1090 (tương đối partition) |
| A-8 | Action | Kiểm tra phòng, bảng giá, ghế giữ rồi lưu | - | P-SYS | 8 | x=60, y=1200 (tương đối partition) |
| D-8 | Decision | - | - | P-SYS | 8a, 8b, 8c, 8d, 8e, 8f | x=130, y=1300 (tương đối partition) |
| A-8c | Action | Từ chối: suất đã bị người khác sửa hoặc xoá (BR-60) | - | P-SYS | 8c | x=320, y=1290 (tương đối partition) |
| A-8d | Action | Từ chối: suất đã tới giờ bắt đầu (BR-57) | - | P-SYS | 8d | x=320, y=1390 (tương đối partition) |
| A-8a | Action | Từ chối: suất có ghế giữ hoặc vé đã bán (BR-53) | - | P-SYS | 8a | x=320, y=1490 (tương đối partition) |
| A-8e | Action | Từ chối: bảng giá chưa đủ giá khi lưu (BR-69) | - | P-SYS | 8e | x=320, y=1590 (tương đối partition) |
| A-8b | Action | Từ chối: vi phạm thời gian dọn phòng (BR-51) | - | P-SYS | 8b | x=320, y=1690 (tương đối partition) |
| A-8f | Action | Từ chối: đổi phòng của suất chiếu từng có vé (BR-92) | - | P-SYS | 8f | x=320, y=1790 (tương đối partition) |
| A-9 | Action | Thông báo lưu suất chiếu thành công | - | P-SYS | 9 | x=60, y=1400 (tương đối partition) |
| FINAL-6 | ActivityFinal | - | - | P-SYS | - | x=520, y=1300 (tương đối partition) |
| FINAL-7 | ActivityFinal | - | - | P-SYS | - | x=520, y=1400 (tương đối partition) |
| FINAL-11 | ActivityFinal | - | - | P-SYS | - | x=520, y=1800 (tương đối partition) |
| FINAL-1 | ActivityFinal | - | - | P-SYS | - | x=520, y=1500 (tương đối partition) |
| FINAL-2 | ActivityFinal | - | - | P-SYS | - | x=130, y=1500 (tương đối partition) |
| A-1a1 | Action | Hiển thị các suất chiếu đã lập của cụm rạp | - | P-SYS | 1a1 | x=60, y=1720 (tương đối partition) |
| A-1a2 | Action | Chọn suất chiếu cần sửa | - | P-ACT-04 | 1a2 | x=300, y=1720 (tương đối partition) |
| A-1a3 | Action | Kiểm tra giờ bắt đầu, ghế giữ và vé | - | P-SYS | 1a3 | x=60, y=1820 (tương đối partition) |
| D-1a3 | Decision | - | - | P-SYS | 1a3a, 1a3b | x=130, y=1920 (tương đối partition) |
| A-1a3a | Action | Từ chối sửa: suất có ghế giữ hoặc vé (BR-53) | - | P-SYS | 1a3a | x=320, y=1910 (tương đối partition) |
| A-1a3b | Action | Từ chối sửa: suất đã tới giờ bắt đầu (BR-57) | - | P-SYS | 1a3b | x=320, y=2010 (tương đối partition) |
| A-1a4 | Action | Hiển thị thông tin hiện tại của suất chiếu | - | P-SYS | 1a4 | x=60, y=2020 (tương đối partition) |
| FINAL-3 | ActivityFinal | - | - | P-SYS | - | x=520, y=1920 (tương đối partition) |
| FINAL-8 | ActivityFinal | - | - | P-SYS | - | x=520, y=2020 (tương đối partition) |
| A-1b1 | Action | Hiển thị các suất chiếu đã lập của cụm rạp | - | P-SYS | 1b1 | x=60, y=2150 (tương đối partition) |
| A-1b2 | Action | Chọn suất chiếu cần xoá | - | P-ACT-04 | 1b2 | x=300, y=2150 (tương đối partition) |
| A-1b3 | Action | Kiểm tra suất chiếu rồi xoá khỏi lịch | - | P-SYS | 1b3 | x=60, y=2250 (tương đối partition) |
| D-1b3 | Decision | - | - | P-SYS | 1b3a, 1b3b, 1b3c | x=130, y=2350 (tương đối partition) |
| A-1b3c | Action | Từ chối xoá: suất đã bị người khác sửa hoặc xoá (BR-60) | - | P-SYS | 1b3c | x=320, y=2340 (tương đối partition) |
| A-1b3b | Action | Từ chối xoá: suất đã tới giờ bắt đầu (BR-57) | - | P-SYS | 1b3b | x=320, y=2440 (tương đối partition) |
| A-1b3a | Action | Từ chối xoá: suất có ghế giữ hoặc vé (BR-53) | - | P-SYS | 1b3a | x=320, y=2540 (tương đối partition) |
| A-1b4 | Action | Thông báo xoá suất chiếu thành công | - | P-SYS | 1b4 | x=60, y=2450 (tương đối partition) |
| FINAL-10 | ActivityFinal | - | - | P-SYS | - | x=520, y=2350 (tương đối partition) |
| FINAL-9 | ActivityFinal | - | - | P-SYS | - | x=520, y=2450 (tương đối partition) |
| FINAL-4 | ActivityFinal | - | - | P-SYS | - | x=520, y=2550 (tương đối partition) |
| FINAL-5 | ActivityFinal | - | - | P-SYS | - | x=130, y=2550 (tương đối partition) |
| N-8g | Note | 8g: Phim vừa được sửa làm sai định dạng phát hành hoặc khoảng chiếu (BR-47, BR-49): từ chối lưu, quay lại bước 3 (BR-139) | - | P-SYS | 8g | x=60, y=2480, w=240, h=100 (tương đối partition) |
| N-8h | Note | 8h: Phòng chiếu đã bị xoá bởi UC-012: từ chối lưu, thông báo phòng không còn, quay lại bước 3 (BR-147) | - | P-SYS | 8h | x=330, y=2480, w=240, h=100 (tương đối partition) |
| N-*a | Note | *a: Tại bất kỳ bước nào trước bước 8, quản lý huỷ yêu cầu: hệ thống không lưu, kết thúc (thất bại) | - | P-ACT-04 | *a | x=300, y=50 (tương đối partition) |

Bảng Edge

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú | Điểm uốn |
|---|---|---|---|---|---|---|
| E-01 | INIT | D-1 | ControlFlow | - | - | - |
| E-02 | D-1 | A-1 | ControlFlow | [lập suất chiếu mới] | - | - |
| E-03 | D-1 | A-1a1 | ControlFlow | [sửa suất chiếu] | - | (50,150); (50,1690); (710,1690) |
| E-04 | D-1 | A-1b1 | ControlFlow | [xoá suất chiếu] | - | (30,150); (30,2120); (710,2120) |
| E-05 | A-1 | A-2 | ControlFlow | - | - | - |
| E-06 | A-2 | M-3 | ControlFlow | - | - | (710,290); (150,290) |
| E-07 | M-3 | A-3 | ControlFlow | - | - | - |
| E-08 | A-3 | A-4 | ControlFlow | - | - | - |
| E-09 | A-4 | D-4 | ControlFlow | - | - | - |
| E-10 | D-4 | A-4a | ControlFlow | [phòng khác cụm rạp] | - | - |
| E-11 | D-4 | A-5 | ControlFlow | [khác] | - | - |
| E-12 | A-4a | M-3 | ControlFlow | - | - | (1140,520); (1140,370); (190,370); (190,350) |
| E-13 | A-5 | D-5 | ControlFlow | - | - | - |
| E-14 | D-5 | A-5a | ControlFlow | [không phải định dạng phát hành] | - | - |
| E-15 | D-5 | A-5b | ControlFlow | [phòng không chiếu được] | - | (840,720); (840,820) |
| E-16 | D-5 | A-5c | ControlFlow | [chưa đủ giá cho suất chiếu] | - | (840,720); (840,920) |
| E-17 | D-5 | A-6 | ControlFlow | [khác] | - | - |
| E-18 | A-5a | M-3 | ControlFlow | - | - | (1150,720); (1150,360); (190,360); (190,350) |
| E-19 | A-5b | M-3 | ControlFlow | - | - | (1160,820); (1160,350); (190,350) |
| E-20 | A-5c | M-3 | ControlFlow | - | - | (1170,920); (1170,340); (190,340); (190,350) |
| E-21 | A-6 | D-6 | ControlFlow | - | - | - |
| E-22 | D-6 | A-6a | ControlFlow | [ngoài khoảng chiếu] | - | - |
| E-23 | D-6 | A-6b | ControlFlow | [giờ bắt đầu đã qua] | - | (840,1010); (840,1110) |
| E-24 | D-6 | A-6c | ControlFlow | [mở bán không trước giờ bắt đầu] | - | (840,1010); (840,1210) |
| E-25 | D-6 | A-7 | ControlFlow | [khác] | - | - |
| E-26 | A-6a | M-3 | ControlFlow | - | - | (1180,1010); (1180,330); (190,330); (190,350) |
| E-27 | A-6b | M-3 | ControlFlow | - | - | (1190,1110); (1190,320); (190,320); (190,350) |
| E-28 | A-6c | M-3 | ControlFlow | - | - | (1200,1210); (1200,310); (190,310); (190,350) |
| E-29 | A-7 | A-8 | ControlFlow | - | - | - |
| E-30 | A-8 | D-8 | ControlFlow | - | - | - |
| E-31 | D-8 | A-8c | ControlFlow | [sửa, suất bị người khác đổi] | - | - |
| E-32 | D-8 | A-8d | ControlFlow | [sửa, đã tới giờ bắt đầu] | - | (840,1320); (840,1420) |
| E-33 | D-8 | A-8a | ControlFlow | [sửa, có ghế giữ hoặc vé] | - | (840,1320); (840,1520) |
| E-34 | D-8 | A-8b | ControlFlow | [vi phạm dọn phòng, không thuộc 8a, 8e, 8f] | - | (840,1320); (840,1720) |
| E-35 | D-8 | A-9 | ControlFlow | [khác] | - | - |
| E-36 | A-8c | FINAL-6 | ControlFlow | - | - | - |
| E-37 | A-8d | FINAL-7 | ControlFlow | - | - | - |
| E-38 | A-8a | FINAL-1 | ControlFlow | - | - | - |
| E-39 | A-8b | M-3 | ControlFlow | - | - | (1220,1720); (1220,280); (190,280); (190,350) |
| E-40 | A-9 | FINAL-2 | ControlFlow | - | - | - |
| E-41 | A-1a1 | A-1a2 | ControlFlow | - | - | - |
| E-42 | A-1a2 | A-1a3 | ControlFlow | - | - | (390,1850) |
| E-43 | A-1a3 | D-1a3 | ControlFlow | - | - | - |
| E-44 | D-1a3 | A-1a3a | ControlFlow | [có ghế giữ hoặc vé] | - | - |
| E-45 | D-1a3 | A-1a3b | ControlFlow | [đã tới giờ bắt đầu] | - | (840,1940); (840,2040) |
| E-46 | D-1a3 | A-1a4 | ControlFlow | [khác] | - | - |
| E-47 | A-1a3a | FINAL-3 | ControlFlow | - | - | - |
| E-48 | A-1a3b | FINAL-8 | ControlFlow | - | - | - |
| E-49 | A-1a4 | M-3 | ControlFlow | - | - | (580,2050); (580,380); (190,380); (190,350) |
| E-50 | A-1b1 | A-1b2 | ControlFlow | - | - | - |
| E-51 | A-1b2 | A-1b3 | ControlFlow | - | - | (390,2280) |
| E-52 | A-1b3 | D-1b3 | ControlFlow | - | - | - |
| E-53 | D-1b3 | A-1b3c | ControlFlow | [suất bị người khác sửa hoặc xoá] | - | - |
| E-54 | D-1b3 | A-1b3b | ControlFlow | [đã tới giờ bắt đầu] | - | (840,2370); (840,2470) |
| E-55 | D-1b3 | A-1b3a | ControlFlow | [có ghế giữ hoặc vé] | - | (840,2370); (840,2570) |
| E-56 | D-1b3 | A-1b4 | ControlFlow | [khác] | - | - |
| E-57 | A-1b3c | FINAL-10 | ControlFlow | - | - | - |
| E-58 | A-1b3b | FINAL-9 | ControlFlow | - | - | - |
| E-59 | A-1b3a | FINAL-4 | ControlFlow | - | - | - |
| E-60 | A-1b4 | FINAL-5 | ControlFlow | - | - | - |
| E-61 | D-8 | A-8e | ControlFlow | [thiếu giá, không thuộc 8c, 8d, 8a, 8f] | - | (840,1320); (840,1620) |
| E-62 | A-8e | M-3 | ControlFlow | - | - | (1210,1620); (1210,300); (190,300); (190,350) |
| E-63 | D-8 | A-8f | ControlFlow | [sửa, đổi phòng của suất từng có vé] | - | (840,1320); (840,1820) |
| E-64 | A-8f | FINAL-11 | ControlFlow | - | - | - |

Ghi chú sơ đồ: D-1 đặt trong partition của quản lý cụm rạp, ngay sau INIT, vì quản lý cụm rạp chọn thao tác lập, sửa hoặc xoá thay cho bước 1 (F5.2). Các luồng 4a, 5a, 5b, 5c, 6a, 6b, 6c, 8b, 8e và 1a4 quay lại merge node M-3 đặt ngay trước A-3; mười cạnh này dùng chung đoạn cuối đi vào M-3. Các guard của D-8 xét theo thứ tự từ trên xuống (8c, 8d, 8a, 8f, 8e, 8b), mỗi guard loại trừ các nhánh đứng trước; [khác] đi tới A-9; D-1a3 xét 1a3b trước 1a3a; D-1b3 xét 1b3c, 1b3b, 1b3a. Luồng *a chỉ thể hiện bằng note N-*a (F10.2). Luồng 1a3a, 1a3b, 1b3a, 1b3b, 1b3c, 8a, 8c, 8d, 8f kết thúc ở các activity final riêng.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ |
|---|---|---|---|
| Q-52 | Đã trả lời (Theo đề xuất: thời điểm mở bán phải trước giờ bắt đầu của suất chiếu), đề bài bổ sung Mục 16. Thời điểm mở bán của suất chiếu có điều kiện hợp lệ nào so với giờ bắt đầu? Nếu thời điểm mở bán không trước giờ bắt đầu thì suất chiếu không bao giờ bán được vé (BR-01, BR-45). | Dữ liệu vào 1 trường 5; bước 6, luồng 6c; BR-55 | Mục 16 chỉ nêu suất chiếu gồm thời điểm mở bán và không ai mua được vé trước thời điểm đó, không nêu ràng buộc giá trị |
| Q-53 | Đã trả lời (Theo đề xuất: không được lập suất chiếu mới hoặc sửa suất chiếu sang giờ bắt đầu đã qua; ý sửa, xoá suất đã tới giờ bắt đầu tách thành Q-60), đề bài bổ sung Mục 16. Có cho lập hoặc sửa suất chiếu với giờ bắt đầu đã qua không? | Dữ liệu vào 1 trường 4; bước 6, luồng 6b; BR-56 | Mục 16 không nêu giới hạn theo thời gian khi lập, sửa |
| Q-54 | Đã trả lời (Theo đề xuất: suất chiếu bị xoá khỏi lịch và không bán được nữa nhưng dữ liệu vẫn được giữ cho vé đã huỷ, hoàn tiền kể cả thanh toán trễ UC-006, và báo cáo), đề bài bổ sung Mục 16. Xoá suất chiếu từng có vé nhưng mọi vé đã huỷ, hoặc suất chiếu có thanh toán thành công báo về trễ (UC-006, BR-14; lúc đó không còn ghế giữ và chưa có vé nên BR-53 không chặn): xoá hẳn dữ liệu suất chiếu hay giữ lại để vé đã huỷ, email hoàn tiền (tên phim, suất chiếu; REQ-116), lịch sử đặt vé (UC-007) và báo cáo doanh thu (REQ-99) vẫn tra được? | Luồng 1b3; hậu điều kiện luồng 1b; BR-58; mô hình dữ liệu (P13); UC-006 luồng thanh toán trễ, BR-14, BR-40; UC-007, UC-015 | Mục 16 chỉ nêu "xoá" và cho phép khi vé đã bán đều đã huỷ, không nêu số phận dữ liệu suất chiếu |
| Q-55 | Đã trả lời (Theo đề xuất mới: ghế đã quá thời điểm hết hạn giữ ghế không còn chặn sửa hoặc xoá suất chiếu, kể cả khi chưa được giải phóng; hết hạn tính theo thời điểm hết hạn), đề bài bổ sung Mục 16. Ghế đã hết hạn giữ nhưng chưa được giải phóng (tối đa 1 phút, REQ-76) có còn là "ghế được giữ" theo REQ-65 không? Tiền lệ: Q-08 và BR-14 lấy mốc là thời điểm hết hạn kể cả khi ghế chưa được giải phóng; BR-44 và UC-005 Mục 8 cũng lấy mốc hết hạn. | Luồng 1a3a, 1b3a, 8a; BR-53; UC-005 Mục 8 | Mục 16 nêu "ghế được giữ"; Mục 19 cho phép ghế hết hạn được giải phóng trễ tới 1 phút |
| Q-56 | Đã trả lời (Theo đề xuất: từ chối giữ ghế khi khách hoặc nhân viên quầy xác nhận chọn ghế vì suất chiếu đã sửa hoặc xoá), đề bài bổ sung Mục 16. Quản lý cụm rạp xoá hoặc sửa (đổi phòng, giờ) suất chiếu trong lúc khách hoặc nhân viên quầy đang xem sơ đồ ghế của suất đó và chưa xác nhận chọn ghế (ghế chưa giữ nên REQ-65 không chặn, BR-03), rồi họ xác nhận chọn ghế: hệ thống xử lý thế nào? | UC-005 bước 7, luồng 7d; BR-54; Mục 8 | Mục 4 nêu ghế đang chọn vẫn trống cho tới khi xác nhận; Mục 16 chỉ cấm sửa, xoá khi đã có ghế giữ hoặc vé |
| Q-57 | Đã trả lời (Theo đề xuất: người lưu sau bị từ chối, không ghi đè), đề bài bổ sung Mục 16. Hai yêu cầu đồng thời (của hai quản lý cụm rạp hoặc hai phiên làm việc) cùng sửa hoặc xoá một suất chiếu, hoặc một người lưu sửa khi suất chiếu đã bị người kia sửa hoặc xoá từ lúc hiển thị: hệ thống xử lý thế nào? | Luồng 8c, 1b3c; BR-60 | Mục 16 không nêu trường hợp nhiều yêu cầu cùng thao tác trên một suất chiếu |
| Q-58 | Đã trả lời (Theo đề xuất: không tự đổi suất chiếu đã lập), đề bài bổ sung Mục 16. Phim (UC-010) đổi thời lượng, định dạng phát hành hoặc khoảng chiếu, hoặc phòng chiếu (UC-012) đổi định dạng chiếu được hay bị xoá, sau khi suất chiếu đã lập (kể cả đã có vé): suất chiếu hiện có xử lý thế nào, giờ kết thúc đã tính có tính lại không? | Hậu điều kiện; BR-50; Mục 8; UC-010, UC-012 | Mục 14, 15 và 16 không nêu ảnh hưởng của thay đổi phim, phòng lên suất chiếu đã lập |
| Q-59 | Đã trả lời (Theo đề xuất mới: không lập hoặc sửa thành suất chiếu khi bảng giá của cụm rạp chưa có giá cho đúng loại phòng và định dạng phim của suất chiếu), đề bài bổ sung Mục 16. Khi bảng giá của cụm rạp (UC-013) chưa có giá cho tổ hợp của suất chiếu, có chặn lập suất chiếu không? | Bước 5, luồng 5c; BR-69 (BR-59 đã gộp); UC-013; UC-005 bước 8 (BR-11; xem Q-61) | Mục 10, 15 và 16 không nêu quan hệ giữa việc lập suất chiếu và bảng giá |
| Q-60 | Đã trả lời (Theo đề xuất: suất chiếu đã tới giờ bắt đầu, kể cả đã kết thúc, không được sửa hoặc xoá), đề bài bổ sung Mục 16. Có cho sửa, xoá suất chiếu đã tới giờ bắt đầu (kể cả đã kết thúc) khi không có ghế giữ và vé chưa huỷ không? Tách từ Q-53 (ý b). | Luồng 1a3b, 1b3b, 8d; BR-57; lịch sử chiếu và báo cáo (REQ-66, REQ-67) | Mục 16 chỉ cấm sửa, xoá khi có ghế giữ hoặc vé chưa huỷ, không nêu giới hạn theo thời gian |
| Q-61 | Đã trả lời (Phương án A: chặn từ gốc, UC-014 kiểm bảng giá có đủ giá cho mọi loại ghế có trong phòng chiếu ứng với khung giờ của suất chiếu; UC-013 không cho bỏ mục giá đang được suất chiếu chưa tới giờ bắt đầu dùng; UC-005 giữ luồng từ chối làm lưới an toàn), đề bài bổ sung Mục 15, Mục 16. Khi bảng giá của cụm rạp thiếu giá cho loại ghế hoặc khung giờ của một ghế đã chọn, hoặc giá của loại phòng và định dạng bị bỏ khỏi bảng giá sau khi suất chiếu đã lập (BR-69, trước đây BR-59, chỉ kiểm lúc lập, sửa suất chiếu), UC-005 xử lý thế nào? | Bước 5, 8, luồng 5c, 8e; BR-69, BR-64, BR-68, BR-72; UC-005 bước 7, luồng 7e; UC-013 | Mục 10 nêu giá phụ thuộc bốn yếu tố, Mục 15 chỉ nêu quản lý cụm rạp thiết lập bảng giá, không nêu bảng giá phải đủ mọi tổ hợp |

## Đề xuất sửa artifact trước

Không có

## Vấn đề còn mở

- Phương án A của Q-61 giảm xác suất thiếu giá, không loại bỏ khả năng đó vì UC-012 chưa đặc tả; UC-005 luồng 7e là lưới an toàn (BR-72) và ràng buộc cho UC-012 ghi ở BR-73.
- Luồng chính có 9 bước, trong khoảng 3-15. Luồng 1a và 1b là hai kịch bản thao tác khác nhau trên cùng dữ liệu, gộp vào UC-014 theo P02 (CAND-41).
- Thứ tự kiểm 1a3b, 1a3a; 1b3c, 1b3b, 1b3a; 8c, 8d, 8a, 8b là lựa chọn của đặc tả này (Mục 8); nếu cần thứ tự khác, đổi điều kiện của các luồng.
- BR-52 và BR-54 mô tả cơ chế đồng thời; nguồn không có câu riêng về xử lý đồng thời giữa các yêu cầu lập lịch. BR-52 giữ REQ-64 làm căn cứ (bất biến khi yêu cầu đồng thời), BR-54 dựa vào REQ-65 và REQ-142 (trả lời Q-56).
- Bố cục activity diagram do công cụ sắp xếp tự động, vẫn còn vài cạnh giao nhau do luồng 1a, 1b và các cạnh quay lại bước 3 cùng đi qua hai partition; không cạnh nào cắt qua node, không node nào chồng nhau (đã kiểm bằng script theo hình chữ nhật bao của từng node).
