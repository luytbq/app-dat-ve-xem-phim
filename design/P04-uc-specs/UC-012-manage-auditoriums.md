# P04 - Đặc tả use case UC-012 Quản lý phòng chiếu - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P04 |
| Phiên bản | 1.1 |
| Thay đổi 1.1 | Chốt Q-208 đến Q-214: luồng 1b (xoá phòng chưa từng có suất chiếu), luồng 4b, 4d, 5c, suất chiếu đã xoá không chặn BR-87, BR-73, sơ đồ ghế lịch sử, BR-144 đến BR-147 và bảng Thao tác nguyên tử |
| Đầu vào đã dùng | 00-Conventions.md; 00-Concurrency.md (M1); project-profile.md; yeu-cau-dat-ve.md; P00-problem-brief.md 1.11; P01-actors.md 1.2; P02-usecases.md 1.9; P03-usecase-model.md 1.2; _BR-register.md (đã gộp BR-01 đến BR-147); P05-glossary.md 1.2; P06-supplementary-spec.md 1.4 (BR-73, BR-87); P08-analysis-model.md 1.5 (EX-13, EX-15, X-19, X-21, Q-109); P13-data-model.md 1.5 (Q-136 đến Q-138, bảng auditorium, seat, seat_status); UC-005-book-tickets.md 1.14; UC-010-manage-movies.md 1.1 (Q-203); UC-011-manage-cinemas.md 1.1 (mẫu); UC-013-manage-price-list.md 1.4 (BR-73, BR-68); UC-014-schedule-showtimes.md 1.6 (điểm nối BR-84, BR-92) |
| Phạm vi | UC-012 |
| Mã Q, ASM cuối đã cấp | Q-214 (Q-208 đến Q-214 cấp ở use case này, đã trả lời); không có ASM (NGHIEM_NGAT) |

## 1. Thông tin chung

| Thuộc tính | Giá trị |
|---|---|
| Mã use case | UC-012 |
| Tên use case | Quản lý phòng chiếu (Manage Auditoriums) |
| Tác nhân chính | ACT-04 Quản lý cụm rạp |
| Tác nhân phụ | Không có |
| Mô tả ngắn | Use case này mô tả tương tác giữa quản lý cụm rạp và hệ thống khi quản lý cụm rạp muốn thêm phòng chiếu mới hoặc sửa phòng chiếu của cụm rạp mình, gồm loại phòng, các định dạng phim chiếu được và sơ đồ ghế. Kết quả là các phòng chiếu của cụm rạp có đúng loại phòng, sức chứa, định dạng chiếu được và sơ đồ ghế. |
| Sự kiện kích hoạt | Cụm rạp có phòng chiếu mới hoặc phòng chiếu thay đổi (EV-14) |
| Tiền điều kiện | Quản lý cụm rạp đã đăng nhập và đang có phiên làm việc (REQ-102).<br>Quản lý cụm rạp thuộc đúng một cụm rạp (REQ-100). |
| Hậu điều kiện (thành công) | Khi thêm phòng chiếu (luồng chính): cụm rạp của quản lý cụm rạp có thêm một phòng chiếu với tên, loại phòng, các định dạng phim chiếu được và sơ đồ ghế mà quản lý cụm rạp đã nhập; sức chứa của phòng bằng số ghế của sơ đồ ghế, ghế đôi tính một ghế (BR-06).<br>Khi sửa phòng chiếu (luồng 1a): phòng chiếu đã chọn có các giá trị mà quản lý cụm rạp đã nhập thay cho giá trị cũ; khi sơ đồ ghế thay đổi thì phòng không có suất chiếu đã tới thời điểm mở bán mà chưa kết thúc tại thời điểm hệ thống kiểm tra (BR-87); mọi suất chiếu chưa tới giờ bắt đầu của phòng vẫn đủ giá (BR-73).<br>Khi xoá phòng chiếu (luồng 1b): phòng chiếu đã chọn và các ghế của phòng không còn trong cụm rạp; phòng chưa từng có suất chiếu (BR-147).<br>Khi sơ đồ ghế thay đổi, suất chiếu chưa mở bán dùng sơ đồ mới; suất chiếu đã kết thúc hoặc đã xoá giữ sơ đồ ghế, loại ghế và sức chứa lúc suất chiếu mở bán (BR-118).<br>Trong cả hai trường hợp thêm và sửa, các suất chiếu đã lập không tự đổi (BR-84), giá của các lần giữ ghế đang có và của các vé đã bán không đổi (BR-65, BR-67). |
| Hậu điều kiện tối thiểu | Khi use case kết thúc thất bại, phòng chiếu, sơ đồ ghế, lịch chiếu, ghế đang giữ và vé của cụm rạp không thay đổi. |
| Quan hệ | Không có |
| Điểm mở rộng | Không có |
| REQ | REQ-56, REQ-57, REQ-58 (theo P02); REQ-02, REQ-16, REQ-87 (P02 Mục 5 đã gắn UC-012); REQ-162, REQ-03 (P02 Mục 5 đã gắn UC-012); REQ-102 (tiền điều kiện; P02 ghi "-"); REQ-100 (tham chiếu, UC-017); REQ-17 (tham chiếu, UC-005); REQ-55 (tham chiếu, UC-010); REQ-144, REQ-145 (tham chiếu, UC-014); REQ-149 (tham chiếu, UC-013, UC-005); REQ-151 (tham chiếu, UC-013, UC-014); REQ-105 (tham chiếu, UC-005); REQ-37, REQ-38 (tham chiếu, UC-013, UC-005); REQ-01 (liên quan Mục 8; P02 Mục 5 ghi chuyển P06); REQ-153, REQ-140, REQ-141 (căn cứ phụ của BR dẫn ở Mục 6) |

## 2. Luồng sự kiện chính

| STT | Thực hiện bởi | Hành động |
|---|---|---|
| 1 | Quản lý cụm rạp | Yêu cầu thêm phòng chiếu mới cho cụm rạp của mình. |
| 2 | Hệ thống | Hiển thị các phòng chiếu hiện có của cụm rạp mà quản lý cụm rạp thuộc về (BR-135; xem Dữ liệu ra 1). |
| 3 | Quản lý cụm rạp | Nhập tên phòng chiếu, chọn loại phòng và các định dạng phim chiếu được, nhập sơ đồ ghế rồi gửi (xem Dữ liệu vào 1, Dữ liệu vào 1a; BR-74). |
| 4 | Hệ thống | Kiểm tra thông tin phòng chiếu và sơ đồ ghế hợp lệ theo điều kiện của Dữ liệu vào 1 (BR-144, BR-145). |
| 5 | Hệ thống | Kiểm tra, với phòng chiếu đã có ở luồng 1a, sơ đồ ghế chỉ thay đổi khi phòng không có suất chiếu đã tới thời điểm mở bán mà chưa kết thúc (BR-87) và việc đổi loại phòng hoặc loại ghế không làm suất chiếu chưa tới giờ bắt đầu của phòng thiếu giá (BR-73, BR-69), rồi lưu phòng chiếu cùng sơ đồ ghế vào cụm rạp của quản lý cụm rạp, tất cả là một thao tác không chia cắt với việc lưu suất chiếu của phòng, việc bỏ mục giá và việc chốt giá (BR-135, BR-136, BR-137), và với phòng chiếu đã chọn ở luồng 1a, phòng chưa bị yêu cầu khác sửa kể từ lúc hiển thị (BR-146); suất chiếu đã xoá không được tính khi kiểm BR-87 và BR-73 (Q-209). |
| 6 | Hệ thống | Thông báo lưu phòng chiếu thành công và hiển thị phòng chiếu đã lưu cùng sức chứa (xem Dữ liệu ra 2; BR-06). |

## 3. Luồng sự kiện thay thế và ngoại lệ

| STT | Điều kiện | Thực hiện bởi | Hành động | Quay lại / Kết thúc |
|---|---|---|---|---|
| 1a | Quản lý cụm rạp chọn sửa một phòng chiếu đã có thay vì thêm phòng chiếu mới | - | Sửa phòng chiếu | - |
| 1a1 | | Hệ thống | Hiển thị các phòng chiếu của cụm rạp mà quản lý cụm rạp thuộc về (BR-135; xem Dữ liệu ra 1). | |
| 1a2 | | Quản lý cụm rạp | Chọn phòng chiếu cần sửa (xem Dữ liệu vào 2). | |
| 1a3 | | Hệ thống | Hiển thị thông tin hiện tại của phòng chiếu đã chọn, gồm sơ đồ ghế, để sửa (xem Dữ liệu ra 3). | Tiếp tục bước 3 |
| 1b | Quản lý cụm rạp chọn xoá một phòng chiếu thay vì thêm phòng chiếu mới (Q-208) | - | Xoá phòng chiếu | - |
| 1b1 | | Hệ thống | Hiển thị các phòng chiếu của cụm rạp mà quản lý cụm rạp thuộc về (BR-135; xem Dữ liệu ra 1). | |
| 1b2 | | Quản lý cụm rạp | Chọn phòng chiếu cần xoá (xem Dữ liệu vào 2). | |
| 1b3 | | Hệ thống | Kiểm tra phòng chiếu chưa từng có suất chiếu, kể cả suất chiếu đã xoá (BR-147), rồi xoá phòng chiếu cùng các ghế của phòng, tất cả là một thao tác không chia cắt với việc lưu suất chiếu của phòng (BR-136). | |
| 1b3a | Phòng chiếu đã từng có suất chiếu, kể cả suất chiếu đã xoá (BR-147) | Hệ thống | Từ chối xoá, không đổi phòng chiếu và thông báo quy tắc bị vi phạm (BR-147). | Kết thúc use case (thất bại) |
| 1b4 | | Hệ thống | Thông báo xoá phòng chiếu thành công. | Kết thúc use case (thành công) |
| 4a | Thông tin phòng chiếu hoặc sơ đồ ghế không đạt điều kiện hợp lệ của Dữ liệu vào 1 hoặc Dữ liệu vào 1a | Hệ thống | Từ chối lưu và thông báo điều kiện bị vi phạm của từng trường. | Quay lại bước 3 |
| 4b | Sức chứa của sơ đồ ghế, ghế đôi tính một ghế, ngoài khoảng 50 đến 400 ghế (BR-144), không thuộc 4a | Hệ thống | Từ chối lưu và thông báo quy tắc bị vi phạm (BR-144). | Quay lại bước 3 |
| 4d | Tên phòng chiếu đã thuộc một phòng chiếu khác trong cùng cụm rạp (BR-145), không thuộc 4a, 4b | Hệ thống | Từ chối lưu và thông báo quy tắc bị vi phạm (BR-145). | Quay lại bước 3 |
| 5a | Sơ đồ ghế bị thay đổi và phòng chiếu có suất chiếu (không kể suất chiếu đã xoá, Q-209) đã tới thời điểm mở bán mà chưa kết thúc, so tại thời điểm hệ thống kiểm tra (BR-87); kiểm trước 5b | Hệ thống | Từ chối lưu, không đổi phòng chiếu và sơ đồ ghế, và thông báo quy tắc bị vi phạm (BR-87). | Kết thúc use case (thất bại) |
| 5b | Việc đổi loại phòng hoặc thêm loại ghế vào phòng làm ít nhất một suất chiếu chưa tới giờ bắt đầu của phòng (không kể suất chiếu đã xoá, Q-209) thiếu giá theo BR-69 (BR-73), không thuộc 5a | Hệ thống | Từ chối lưu và thông báo quy tắc bị vi phạm (BR-73). | Kết thúc use case (thất bại) |
| 5c | Chỉ khi theo luồng 1a: phòng chiếu đã bị yêu cầu khác sửa kể từ lúc hiển thị (BR-146) | Hệ thống | Từ chối lưu, không ghi đè thay đổi trước và thông báo quy tắc bị vi phạm (BR-146). | Quay lại bước 1a1 |
| *a | Tại bất kỳ bước nào trước bước 5 (trước bước 1b3 với luồng 1b), kể cả trong luồng 1a, quản lý cụm rạp huỷ yêu cầu | Hệ thống | Huỷ yêu cầu, không thay đổi phòng chiếu. | Kết thúc use case (thất bại) |

## 4. Luồng con

Không có

## 5. Dữ liệu vào và dữ liệu ra

Dữ liệu vào 1 (bước 3)

| STT | Trường dữ liệu | Mô tả | Bắt buộc | Điều kiện hợp lệ | Ví dụ |
|---|---|---|---|---|---|
| 1 | Tên phòng chiếu | Tên của phòng chiếu, vé và email ghi tên phòng chiếu (REQ-105) | Có | Không để trống; không trùng tên phòng khác trong cùng cụm rạp, phòng khác cụm được trùng (BR-145, Q-213) | Phòng 05 |
| 2 | Loại phòng | Loại của phòng chiếu | Có (REQ-57) | Một trong ba loại: phòng thường, 4DX, IMAX (REQ-02) | IMAX |
| 3 | Định dạng phim chiếu được | Các định dạng phim mà phòng chiếu được | Có (REQ-57) | Một hoặc cả hai định dạng 2D, 3D (REQ-55) | 2D, 3D |
| 4 | Sơ đồ ghế | Danh sách ghế của phòng chiếu (xem Dữ liệu vào 1a); sức chứa không nhập mà bằng số ghế, ghế đôi tính một ghế (BR-06, trả lời Q-137) | Có (REQ-57) | Sức chứa nằm trong khoảng 50 đến 400 ghế (BR-144, Q-211) | 120 ghế |

Dữ liệu vào 1a (bước 3, mỗi ghế của sơ đồ ghế)

| STT | Trường dữ liệu | Mô tả | Bắt buộc | Điều kiện hợp lệ | Ví dụ |
|---|---|---|---|---|---|
| 1 | Hàng | Mã hàng của vị trí ghế | Có | Không để trống | C |
| 2 | Số ghế | Số thứ tự của ghế trong hàng; lối đi biểu diễn bằng khoảng trống giữa các số ghế, không có ghế vật lý không dùng (trả lời Q-137) | Có | Số ghế; mỗi cặp hàng và số ghế có tối đa một ghế trong sơ đồ | 7 |
| 3 | Loại ghế | Loại của ghế | Có | Một trong ba loại: ghế thường, ghế VIP, ghế đôi (REQ-16); ghế đôi là một vị trí dành cho hai người, được bán như một ghế (BR-74) và tính một ghế khi đếm sức chứa (BR-06) | Ghế đôi |

Dữ liệu vào 2 (bước 1a2, 1b2)

| STT | Trường dữ liệu | Mô tả | Bắt buộc | Điều kiện hợp lệ | Ví dụ |
|---|---|---|---|---|---|
| 1 | Phòng chiếu cần sửa hoặc xoá | Một phòng chiếu trong danh sách ở Dữ liệu ra 1 | Có | Phòng chiếu thuộc cụm rạp của quản lý cụm rạp (BR-135) | Phòng 05 |

Dữ liệu ra 1 (bước 2, bước 1a1, bước 1b1)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Danh sách phòng chiếu | Với mỗi phòng chiếu của cụm rạp: tên, loại phòng, các định dạng chiếu được, sức chứa (REQ-56, REQ-57) | Sức chứa là số nguyên kèm "ghế"; các định dạng cách nhau bằng dấu phẩy; các trường còn lại là văn bản | Phòng 05, IMAX, 2D, 3D, 320 ghế |

Dữ liệu ra 2 (bước 6)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Phòng chiếu đã lưu | Tên, loại phòng, các định dạng chiếu được, sức chứa và số ghế theo từng loại ghế của phòng chiếu vừa lưu (BR-06) | Như Dữ liệu ra 1; số ghế theo loại ghế là số nguyên | Phòng 05, IMAX, 2D, 3D, 320 ghế (280 ghế thường, 30 ghế VIP, 10 ghế đôi) |

Dữ liệu ra 3 (bước 1a3)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Thông tin hiện tại của phòng chiếu | Tên, loại phòng, các định dạng chiếu được và từng ghế (hàng, số ghế, loại ghế) của phòng chiếu đã chọn | Như Dữ liệu ra 1; ghế dạng hàng kèm số ghế | Phòng 05, IMAX, 2D, 3D, ghế C7 ghế đôi |

## 6. Quy tắc nghiệp vụ

| BR | Quy tắc | Loại | Bước áp dụng | REQ | Trong sổ BR |
|---|---|---|---|---|---|
| BR-135 | Quản lý cụm rạp chỉ xem, thêm và sửa phòng chiếu, sơ đồ ghế của các phòng chiếu thuộc cụm rạp của mình. | Ràng buộc | 2, 5, 1a1, Dữ liệu vào 2 | REQ-56; REQ-100 (phụ) | Mới |
| BR-136 | Việc kiểm tra BR-73 và BR-87 rồi lưu thay đổi phòng chiếu hoặc sơ đồ ghế, với việc kiểm tra BR-69 rồi lưu suất chiếu lập hoặc sửa của phòng chiếu đó (UC-014 bước 8) và với việc kiểm tra BR-64 rồi bỏ mục giá (UC-013 luồng 1a3), không xen vào nhau: yêu cầu được ghi nhận trước thì thành công, yêu cầu ghi nhận sau thấy kết quả của yêu cầu trước và bị từ chối theo quy tắc của mình khi vi phạm. | Ràng buộc | 5, 5a, 5b | REQ-162, REQ-145; REQ-151 (phụ) | Mới |
| BR-137 | Việc chốt giá của một lần giữ ghế (UC-005 bước 7) và việc lưu thay đổi loại phòng của phòng chiếu không xen vào nhau: thay đổi được ghi nhận trước thì lần giữ ghế chốt giá theo loại phòng mới; thay đổi được ghi nhận sau thì không ảnh hưởng lần giữ ghế đó. | Ràng buộc | 5 | REQ-149; REQ-37, REQ-38 (phụ) | Mới |
| BR-118 | Suất chiếu đã kết thúc hoặc đã xoá giữ sơ đồ ghế, loại ghế và sức chứa lúc suất chiếu mở bán; sửa sơ đồ ghế của phòng chiếu sau đó không đổi vé, sức chứa và tỉ lệ lấp đầy của các suất chiếu đó; suất chiếu chưa mở bán dùng sơ đồ mới. | Ràng buộc | Hậu điều kiện, Mục 8 | REQ-153, REQ-58 (phụ); Q-186, Q-210 | Đã có |
| BR-144 | Sức chứa của phòng chiếu, ghế đôi tính một ghế (BR-06), nằm trong khoảng từ 50 đến 400 ghế. | Ràng buộc | 4, 4b, Dữ liệu vào 1 (trường 4) | REQ-03; REQ-57 (phụ); Q-211 | Mới |
| BR-145 | Tên phòng chiếu là duy nhất trong cùng một cụm rạp; hai phòng chiếu của hai cụm rạp khác nhau được trùng tên. | Ràng buộc | 4, 4d, Dữ liệu vào 1 (trường 1) | REQ-56, REQ-105 (phụ); Q-213 | Mới |
| BR-146 | Hai yêu cầu cùng sửa một phòng chiếu không xen vào nhau: yêu cầu ghi nhận trước thành công; yêu cầu ghi nhận sau bị từ chối, không ghi đè thay đổi trước, và quản lý cụm rạp phải mở lại phòng chiếu từ đầu. | Ràng buộc | 5, 5c | REQ-56; Q-214 | Mới |
| BR-147 | Chỉ xoá được phòng chiếu chưa từng có suất chiếu, kể cả suất chiếu đã xoá; phòng chiếu đã từng có suất chiếu không xoá được và không có trạng thái ngừng sử dụng. | Ràng buộc | 1b3, 1b3a | REQ-56; REQ-140, REQ-141 (phụ); Q-208 | Mới |
| BR-140 | Vé đã bán giữ tên phim, tên cụm rạp, tên phòng chiếu và loại phòng của lúc bán; sửa các thông tin này sau đó không đổi nội dung vé, lịch sử đặt vé và email đã gửi. | Ràng buộc | Mục 8 | REQ-105; REQ-149 (phụ); Q-203 | Đã có |
| BR-87 | Không được sửa sơ đồ ghế của phòng chiếu khi phòng có suất chiếu đã tới thời điểm mở bán mà chưa kết thúc, kể cả khi suất chiếu chưa có vé đã bán và chưa có ghế được giữ. | Ràng buộc | 5, 5a | REQ-162; REQ-58 (phụ) | Đã có |
| BR-73 | Việc sửa phòng chiếu không được làm suất chiếu chưa tới giờ bắt đầu của phòng chiếu đó thiếu giá theo BR-69. | Ràng buộc | 5, 5b | REQ-145; REQ-57, REQ-58 (phụ) | Đã có |
| BR-69 | Không được lập suất chiếu, hoặc sửa suất chiếu thành suất chiếu, khi bảng giá của cụm rạp chưa có giá cho mọi loại ghế có trong phòng chiếu (loại ghế mà phòng chiếu có ít nhất một ghế), ứng với khung giờ xác định theo giờ bắt đầu của suất chiếu (BR-12), theo loại phòng của phòng chiếu và định dạng phim của suất chiếu. | Ràng buộc | 5, 5b | REQ-145; REQ-37, REQ-38 (phụ) | Đã có |
| BR-06 | Ghế đôi được tính là một ghế khi đếm số ghế của một lần giữ ghế, sức chứa phòng và tỉ lệ lấp đầy. | Suy luận | 6, Dữ liệu vào 1 (trường 4), Dữ liệu vào 1a (trường 3), Dữ liệu ra 2 | REQ-87; REQ-17 (phụ) | Đã có |
| BR-74 | Một ghế đôi là một vị trí dành cho hai người và được bán như một ghế. | Sự kiện | 3, Dữ liệu vào 1a (trường 3) | REQ-17 | Đã có |
| BR-84 | Phim hoặc phòng chiếu thay đổi sau khi lập suất chiếu không làm suất chiếu đã lập tự đổi. | Ràng buộc | Hậu điều kiện, Mục 8 | REQ-144 | Đã có |

## 7. Yêu cầu đặc biệt

Không có

## 8. Thông tin bổ sung

- Luồng chính là kịch bản thêm phòng chiếu mới và luồng 1a là sửa phòng chiếu, theo hai vế của sự kiện kích hoạt EV-14 "phòng chiếu mới hoặc phòng chiếu thay đổi". Nguồn chỉ nêu "quản lý các phòng chiếu của cụm mình" (REQ-56) và P00 ghi không tách thao tác. Quản lý cụm rạp chọn thêm hoặc sửa thay cho bước 1, nên trên activity diagram decision D-1 đặt ngay sau INIT, trước A-1. Sơ đồ ghế là thành phần của phòng chiếu và được cập nhật cùng phòng (P02 CAND-38).
- Xoá phòng chiếu (Q-208, luồng 1b, BR-147): chỉ xoá được phòng chưa từng có suất chiếu, kể cả suất chiếu đã xoá; phòng đã từng có suất chiếu không xoá được và không có trạng thái ngừng sử dụng, vì dữ liệu suất chiếu, vé, hoàn tiền và báo cáo phải giữ (BR-58) và vé đã huỷ vẫn gắn với ghế của phòng cũ (BR-92). Muốn ngừng dùng phòng thì xoá các suất chiếu chưa chiếu của phòng ở UC-014.
- Sức chứa của phòng không nhập mà đếm từ các ghế của sơ đồ ghế, ghế đôi tính một ghế (BR-06, trả lời Q-137). Khoảng 50 đến 400 ghế (REQ-03) là điều kiện bắt buộc khi lưu sơ đồ ghế (BR-144, Q-211). Số phòng 4 đến 12 mỗi cụm rạp (REQ-01) chỉ là số liệu quy mô, không phải giới hạn cứng: cụm rạp mới bắt đầu với 0 phòng và hệ thống không chặn số phòng (Q-212).
- BR-87 chỉ chặn sửa sơ đồ ghế. Đổi tên phòng, loại phòng, định dạng chiếu được vẫn được khi phòng có suất chiếu đang bán, miễn không làm suất chiếu chưa tới giờ bắt đầu thiếu giá (BR-73). Giá của lần giữ ghế đang có và của vé đã bán không đổi (BR-65, BR-67); lần giữ ghế chốt giá sau khi đổi loại phòng dùng giá của loại phòng mới (BR-137). Suất chiếu đã lập không tự đổi khi phòng đổi định dạng chiếu được (BR-84, trả lời Q-58): suất chiếu đã lập có thể có định dạng mà phòng không còn chiếu được, BR-48 của UC-014 chỉ kiểm khi lập hoặc sửa suất chiếu.
- Điểm nối với UC-005 (lần giữ ghế đang chạy): lần giữ ghế chỉ tồn tại với suất chiếu đã tới thời điểm mở bán (BR-01) và chưa tới giờ bắt đầu khi giữ (BR-45); lần giữ ghế đang chạy kéo dài tối đa 10 phút (BR-10) nên suất chiếu của nó vẫn chưa kết thúc. Vì vậy BR-87 đã chặn sửa sơ đồ ghế của phòng có lần giữ ghế đang chạy hoặc vé chưa huỷ, và use case này không kiểm riêng ghế đang giữ hay vé đã bán. BR-87 chặt hơn REQ-58; ghế đã quá thời điểm hết hạn giữ ghế mà chưa được giải phóng vẫn chặn khi suất chiếu của nó chưa kết thúc, khác với BR-53 của UC-014.
- Mốc so sánh của BR-87 là thời điểm hệ thống kiểm tra yêu cầu sửa (sổ BR, ghi chú BR-87) và giờ kết thúc của suất chiếu theo BR-50. Suất chiếu tới thời điểm mở bán sau thời điểm kiểm tra không chặn lần sửa đó; lần giữ ghế trên suất chiếu đó đến sau và thấy phòng chiếu đã sửa (BR-136, P08 X-19).
- Điểm nối với UC-014 (lập suất chiếu và sơ đồ ghế): UC-014 bước 8 đọc loại phòng, các loại ghế, sơ đồ ghế của phòng để kiểm giá (BR-69) và để tạo trạng thái ghế của suất chiếu (P08 EX-13, trả lời Q-109). BR-136 là cặp loại trừ giữa hai use case như UC-013 Mục 8 yêu cầu (giống BR-68): lập suất chiếu được ghi nhận trước thì sửa sơ đồ ghế bị từ chối khi suất chiếu đã tới thời điểm mở bán (BR-87) hoặc sửa loại phòng, loại ghế bị từ chối khi thiếu giá (BR-73); sửa phòng được ghi nhận trước thì lập suất chiếu thấy phòng đã sửa. Suất chiếu lập với thời điểm mở bán đã qua là mở bán ngay nên BR-87 áp dụng ngay.
- Điểm nối với UC-013 (bỏ giá và sửa phòng): bỏ mục giá bị chặn khi cụm rạp còn suất chiếu chưa tới giờ bắt đầu dùng mục giá theo loại phòng hiện tại của phòng (BR-64). BR-136 loại trừ việc bỏ giá với việc đổi loại phòng, loại ghế (P08 X-21).
- Ảnh hưởng của sơ đồ ghế mới tới trạng thái ghế của từng suất chiếu (Q-210, BR-118): suất chiếu chưa mở bán dùng sơ đồ mới (P08 Q-109, EX-15); suất chiếu đã kết thúc hoặc đã xoá giữ sơ đồ ghế, loại ghế và sức chứa lúc suất chiếu mở bán, gắn với vé và lần giữ ghế đã kết thúc (BR-92, BR-58). Suất chiếu đã xoá không tính ở BR-87 và BR-73 vì không còn trong lịch chiếu và không bán vé (Q-209).
- Tên phòng và loại phòng được ghi trên vé (REQ-105). Vé đã bán hiển thị giá trị lúc bán, không đổi khi phòng đổi tên hoặc đổi loại (BR-140, Q-203).
- Bước 5 gộp mọi kiểm tra quyết định việc lưu và việc lưu thành một thao tác không chia cắt: nếu tách rời, UC-014 có thể lưu một suất chiếu đã mở bán giữa lúc kiểm BR-87 và lúc lưu sơ đồ ghế, hoặc lưu suất chiếu theo loại phòng cũ giữa lúc kiểm BR-73 và lúc lưu loại phòng mới. Cơ chế bảo đảm thuộc bước thiết kế (P07, P09).
- Thứ tự kiểm ở bước 5: 5a (BR-87) trước 5b (BR-73). Thông tin đã thấy sai về trạng thái bán của phòng thì kiểm giá không còn ý nghĩa; nguồn không nêu thứ tự báo khi nhiều điều kiện cùng vi phạm.
- Bước sinh theo quy tắc của prompt: bước 6 (báo kết quả cho quản lý cụm rạp); hành động "Từ chối ... và thông báo" ở luồng 4a, 5a, 5b; điểm quay lại bước 3 ở luồng 4a vì quản lý cụm rạp sửa được dữ liệu vi phạm. Luồng 5a, 5b kết thúc thất bại vì điều kiện thuộc use case khác (xoá suất chiếu ở UC-014, đặt giá ở UC-013), quản lý cụm rạp không sửa được ngay trong use case.
- Không có bước hẹn hoặc huỷ mốc (F4.2 mục 17): P01 không có tác nhân thời gian; thời điểm mở bán là mốc của UC-005 và UC-014, không do use case này tạo hay đổi.

Thao tác nguyên tử

| Thao tác | Bước | Tài nguyên | Bất biến giữ được | Loại trừ với | Kết cục bên thua | Căn cứ |
|---|---|---|---|---|---|---|
| Lưu phòng chiếu và sơ đồ ghế (sửa phòng đã có) | 5 | Loại phòng, định dạng chiếu được và sơ đồ ghế của một phòng chiếu | Sơ đồ ghế chỉ đổi khi phòng không có suất chiếu đã tới thời điểm mở bán mà chưa kết thúc tại thời điểm kiểm tra (BR-87); suất chiếu chưa tới giờ bắt đầu của phòng vẫn đủ giá sau khi đổi loại phòng hoặc loại ghế (BR-73) | Chính nó (hai yêu cầu sửa cùng một phòng); UC-014 bước 8 (lập, sửa suất chiếu của phòng) và luồng 1b3 (xoá suất chiếu); UC-005 bước 7 (giữ ghế, chốt giá theo loại phòng); UC-013 luồng 1a3 (bỏ mục giá); UC-015, UC-016 (chưa đặc tả; chỉ đọc sức chứa, không cần loại trừ) | UC-014 bước 8 ghi nhận trước: sửa sơ đồ ghế bị từ chối theo BR-87 khi suất chiếu đã tới thời điểm mở bán, sửa loại phòng hoặc thêm loại ghế bị từ chối theo BR-73 khi thiếu giá; UC-012 ghi nhận trước: UC-014 bước 8 thấy phòng đã sửa và bị từ chối theo BR-69 khi thiếu giá. UC-014 luồng 1b3 xoá suất chiếu ghi nhận trước: suất chiếu đã xoá không chặn sửa sơ đồ ghế và không cần đủ giá (Q-209). UC-005 bước 7 ghi nhận trước (lần giữ ghế đã ghi): sửa sơ đồ ghế bị từ chối theo BR-87; đổi loại phòng thì lần giữ ghế giữ giá đã chốt theo loại phòng cũ (BR-137); UC-012 ghi nhận trước: lần giữ ghế chốt giá theo loại phòng mới (BR-137). UC-013 luồng 1a3 ghi nhận trước: đổi loại phòng hoặc thêm loại ghế bị từ chối theo BR-73 khi mục giá vừa bỏ làm thiếu giá; UC-012 ghi nhận trước: bỏ giá bị từ chối theo BR-64 khi còn suất chiếu chưa tới giờ bắt đầu dùng mục giá. Chính nó (hai yêu cầu sửa cùng một phòng): bên ghi nhận sau bị từ chối ở luồng 5c, không ghi đè (BR-146). | BR-87, BR-73, BR-118, BR-136, BR-137, BR-146; REQ-162, REQ-145, REQ-151; P08 EX-15, X-19, X-21 |
| Thêm phòng chiếu | 5 | Danh sách phòng chiếu của cụm rạp | Tên phòng duy nhất trong cụm rạp (BR-145); số phòng không bị giới hạn (Q-212) | Chính nó (hai yêu cầu thêm hoặc sửa phòng cùng tên trong cùng cụm rạp); UC-014 bước 2 (chỉ đọc danh sách phòng; phòng mới chưa có suất chiếu nên không tranh chấp) | Bên ghi nhận sau bị từ chối ở luồng 4d; cơ chế bảo đảm thuộc bước thiết kế | BR-145, Q-212, Q-213 |
| Kiểm tra phòng chưa từng có suất chiếu rồi xoá phòng và các ghế | 1b3 | Phòng chiếu, các ghế của phòng | Phòng đã từng có suất chiếu không bị xoá (BR-147); kiểm tra và xoá là một thao tác | Chính nó (hai yêu cầu xoá cùng một phòng); bước 5 trên cùng phòng; UC-014 bước 8 (lập suất chiếu của phòng) | UC-014 bước 8 ghi nhận trước: xoá bị từ chối ở luồng 1b3a. UC-012 xoá ghi nhận trước: UC-014 bước 8 thấy phòng không còn và bị từ chối. Hai yêu cầu xoá hoặc xoá với sửa: bên ghi nhận sau bị từ chối (BR-146) | BR-147, BR-146, Q-208 |

Mốc kết thúc của quá trình: suất chiếu "chưa kết thúc" của BR-87 tính theo giờ kết thúc của suất chiếu (BR-50), không theo lúc ghế được giải phóng hay lúc dọn dẹp xong. Trạng thái dở dang có lối ra: lần giữ ghế đang chạy chặn sửa sơ đồ ghế tới khi suất chiếu kết thúc, không để lại trạng thái dở dang do use case này; suất chiếu đã kết thúc hoặc đã xoá giữ sơ đồ ghế lúc mở bán, suất chiếu chưa mở bán dùng sơ đồ mới (BR-118, Q-210).

## 8a. Kịch bản chính

- KB1: Luồng chính --> quản lý cụm rạp thêm phòng chiếu mới với sơ đồ ghế thành công.
- KB2: Luồng 1a --> quản lý cụm rạp sửa tên, định dạng chiếu được hoặc sơ đồ ghế của phòng không có suất chiếu đã mở bán chưa kết thúc thành công.
- KB3: Luồng 1a + 5a --> sửa sơ đồ ghế bị từ chối vì phòng có suất chiếu đã tới thời điểm mở bán mà chưa kết thúc.
- KB4: Luồng 1a + 5b --> đổi loại phòng bị từ chối vì suất chiếu chưa tới giờ bắt đầu của phòng sẽ thiếu giá.
- KB5: Luồng chính + 4a --> thông tin phòng chiếu không hợp lệ, quay lại bước 3, nhập lại rồi lưu thành công.
- KB6: Luồng 1b --> phòng chưa từng có suất chiếu được xoá.
- KB7: Luồng 1b + 1b3a --> phòng đã từng có suất chiếu không xoá được.
- KB8: Luồng chính + 4b hoặc 4d --> sức chứa ngoài khoảng hoặc trùng tên phòng, quay lại bước 3.
- KB9: Luồng 1a + 5c --> phòng đã bị yêu cầu khác sửa, yêu cầu lưu sau bị từ chối, quản lý cụm rạp mở lại phòng từ đầu.

## 9. Activity diagram

File: diagrams/P04-activity-UC-012.drawio

Bảng đối chiếu

| Bước UC | Node |
|---|---|
| 1 | D-1, A-1 |
| 2 | A-2 |
| 3 | M-3, A-3 |
| 4, 4a | A-4, D-4, A-4a |
| 5, 5a, 5b | A-5, D-5, A-5a, A-5b, FINAL-1, FINAL-2 |
| 6 | A-6, FINAL-3 |
| 1a1, 1a2, 1a3 | A-1a1, A-1a2, A-1a3 |
| 1b đến 1b4 | N-1b |
| 4b, 4d | N-4bd |
| 5c | N-5c |
| *a | N-*a |

Bảng Node

| ID | Loại | Nhãn | Stereotype | Thuộc về (container) | Bước UC | Ghi chú |
|---|---|---|---|---|---|---|
| P-ACT-04 | Partition | Quản lý cụm rạp | - | - | - | x=0, w=560 |
| P-SYS | Partition | Hệ thống | - | - | - | x=560, w=600 |
| INIT | Initial | - | - | P-ACT-04 | - | x=130, y=60 (tương đối partition) |
| D-1 | Decision | - | - | P-ACT-04 | 1a | x=130, y=130 (tương đối partition) |
| A-1 | Action | Yêu cầu thêm phòng chiếu mới | - | P-ACT-04 | 1 | x=60, y=210 (tương đối partition) |
| A-2 | Action | Hiển thị phòng chiếu của cụm rạp | - | P-SYS | 2 | x=60, y=210 (tương đối partition) |
| M-3 | Merge | - | - | P-ACT-04 | 4a | x=130, y=330 (tương đối partition) |
| A-3 | Action | Nhập thông tin phòng và sơ đồ ghế | - | P-ACT-04 | 3 | x=60, y=400 (tương đối partition) |
| A-4 | Action | Kiểm tra thông tin phòng hợp lệ | - | P-SYS | 4 | x=60, y=400 (tương đối partition) |
| D-4 | Decision | - | - | P-SYS | 4a | x=130, y=500 (tương đối partition) |
| A-4a | Action | Từ chối: thông tin phòng không hợp lệ | - | P-SYS | 4a | x=320, y=490 (tương đối partition) |
| A-5 | Action | Kiểm tra điều kiện rồi lưu phòng chiếu | - | P-SYS | 5 | x=60, y=600 (tương đối partition) |
| D-5 | Decision | - | - | P-SYS | 5a, 5b | x=130, y=700 (tương đối partition) |
| A-5a | Action | Từ chối: phòng có suất chiếu đã mở bán (BR-87) | - | P-SYS | 5a | x=320, y=690 (tương đối partition) |
| A-5b | Action | Từ chối: suất chiếu thiếu giá (BR-73) | - | P-SYS | 5b | x=320, y=790 (tương đối partition) |
| A-6 | Action | Thông báo lưu phòng chiếu thành công | - | P-SYS | 6 | x=60, y=800 (tương đối partition) |
| FINAL-1 | ActivityFinal | - | - | P-SYS | 5a | x=520, y=700 (tương đối partition) |
| FINAL-2 | ActivityFinal | - | - | P-SYS | 5b | x=520, y=800 (tương đối partition) |
| FINAL-3 | ActivityFinal | - | - | P-SYS | 6 | x=130, y=900 (tương đối partition) |
| A-1a1 | Action | Hiển thị phòng chiếu của cụm rạp | - | P-SYS | 1a1 | x=60, y=1000 (tương đối partition) |
| A-1a2 | Action | Chọn phòng chiếu cần sửa | - | P-ACT-04 | 1a2 | x=300, y=1000 (tương đối partition) |
| A-1a3 | Action | Hiển thị thông tin hiện tại của phòng | - | P-SYS | 1a3 | x=60, y=1100 (tương đối partition) |
| N-1b | Note | 1b: Xoá phòng: hiển thị phòng, chọn phòng, kiểm tra chưa từng có suất chiếu rồi xoá phòng và ghế; 1b3a đã từng có suất chiếu: từ chối xoá, thất bại; 1b4 thành công (Q-208, BR-147) | - | P-SYS | 1b | x=330, y=1160, w=240, h=120 (tương đối partition) |
| N-4bd | Note | 4b, 4d: Sức chứa ngoài 50 đến 400 ghế hoặc trùng tên phòng trong cụm: từ chối lưu, quay lại bước 3 (BR-144, BR-145) | - | P-SYS | 4b, 4d | x=330, y=1300, w=240, h=100 (tương đối partition) |
| N-5c | Note | 5c: Chỉ khi theo luồng 1a: phòng đã bị yêu cầu khác sửa: từ chối lưu, không ghi đè, quay lại 1a1 (BR-146) | - | P-SYS | 5c | x=330, y=1420, w=240, h=100 (tương đối partition) |
| N-*a | Note | *a: Tại bất kỳ bước nào trước bước 5, kể cả trong luồng 1a, quản lý cụm rạp huỷ yêu cầu: hệ thống không đổi phòng chiếu, kết thúc (thất bại) | - | P-ACT-04 | *a | x=300, y=60 (tương đối partition) |

Bảng Edge

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú | Điểm uốn |
|---|---|---|---|---|---|---|
| E-01 | INIT | D-1 | ControlFlow | - | - | - |
| E-02 | D-1 | A-1 | ControlFlow | [thêm phòng chiếu] | - | - |
| E-03 | D-1 | A-1a1 | ControlFlow | [sửa phòng chiếu] | - | (290,150); (290,980); (710,980) |
| E-04 | A-1 | A-2 | ControlFlow | - | - | - |
| E-05 | A-2 | M-3 | ControlFlow | - | - | - |
| E-06 | M-3 | A-3 | ControlFlow | - | - | - |
| E-07 | A-3 | A-4 | ControlFlow | - | - | - |
| E-08 | A-4 | D-4 | ControlFlow | - | - | - |
| E-09 | D-4 | A-4a | ControlFlow | [thông tin phòng không hợp lệ] | - | - |
| E-10 | D-4 | A-5 | ControlFlow | [khác] | - | - |
| E-11 | A-4a | M-3 | ControlFlow | - | - | (970,470); (250,470); (250,310); (150,310) |
| E-12 | A-5 | D-5 | ControlFlow | - | - | - |
| E-13 | D-5 | A-5a | ControlFlow | [sơ đồ ghế đổi khi phòng có suất chiếu đã mở bán chưa kết thúc (BR-87)] | - | - |
| E-14 | D-5 | A-5b | ControlFlow | [loại phòng hoặc loại ghế mới làm suất chiếu thiếu giá (BR-73), không thuộc 5a] | - | - |
| E-15 | D-5 | A-6 | ControlFlow | [khác] | - | - |
| E-16 | A-5a | FINAL-1 | ControlFlow | - | - | - |
| E-17 | A-5b | FINAL-2 | ControlFlow | - | - | - |
| E-18 | A-6 | FINAL-3 | ControlFlow | - | - | - |
| E-19 | A-1a1 | A-1a2 | ControlFlow | - | - | - |
| E-20 | A-1a2 | A-1a3 | ControlFlow | - | - | - |
| E-21 | A-1a3 | M-3 | ControlFlow | - | - | (710,1080); (270,1080); (270,380); (120,380); (120,350) |

Ghi chú sơ đồ: D-1 đặt trong partition của quản lý cụm rạp, ngay sau INIT, vì quản lý cụm rạp chọn thêm hoặc sửa thay cho bước 1 (F5.2). Luồng 1a3 và luồng 4a quay lại merge node M-3 đặt ngay trước A-3, cùng điểm vào với cạnh từ A-2. Guard của D-5 xét theo thứ tự 5a, 5b; guard của 5b nêu loại trừ 5a; [khác] đi tới A-6. Luồng *a chỉ thể hiện bằng note N-*a (F10.2). Luồng 5a, 5b kết thúc ở các activity final riêng. Cạnh nào không ghi điểm uốn thì đường đi do trình vẽ đặt.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ |
|---|---|---|---|
| Q-208 | Đã trả lời (Theo đề xuất: Xoá được phòng chưa từng có suất chiếu (kể cả suất chiếu đã xoá); phòng đã từng có suất chiếu không xoá được và không có trạng thái ngừng sử dụng, muốn ngừng dùng thì xoá các suất chiếu chưa chiếu của phòng ở UC-014 (dữ liệu suất chiếu phải giữ, BR-58, BR-92)). Quản lý cụm rạp có được xoá hoặc ngừng sử dụng phòng chiếu không? Phòng đã có suất chiếu (đã chiếu, đã xoá, đang có vé hoặc ghế giữ) thì xử lý thế nào? | Luồng thay thế xoá phòng (chưa viết); hậu điều kiện; Mục 8; UC-014, UC-006; P13 khoá ngoại tới auditorium | REQ-56 chỉ nêu "quản lý các phòng chiếu", P00 ghi chưa tách thao tác; Q-58 (UC-014) nhắc phòng "bị xoá" nhưng không nêu có được xoá không |
| Q-209 | Đã trả lời (Theo đề xuất: Không tính: suất chiếu đã xoá không còn trong lịch chiếu và không bán vé nên không chặn sửa sơ đồ ghế, không cần đủ giá). Suất chiếu đã xoá (BR-58) có tính là suất chiếu chặn sửa sơ đồ ghế ở BR-87 và chặn đổi loại phòng, loại ghế ở BR-73 không? | Bước 5, luồng 5a, 5b; BR-87, BR-73; thao tác nguyên tử Lưu phòng chiếu | BR-87 nêu "suất chiếu đã tới thời điểm mở bán mà chưa kết thúc", BR-58 nêu suất chiếu đã xoá bị bỏ khỏi lịch và ngừng bán vé, không nêu quan hệ với hai quy tắc này |
| Q-210 | Đã trả lời (Theo đề xuất: Suất chiếu chưa mở bán dùng sơ đồ mới; suất chiếu đã kết thúc hoặc đã xoá giữ sơ đồ ghế, loại ghế và sức chứa lúc suất chiếu mở bán, để vé và báo cáo không đổi). Sau khi sửa sơ đồ ghế, sơ đồ mới áp dụng cho những suất chiếu nào của phòng: suất chiếu chưa mở bán, suất chiếu đã kết thúc (vé, báo cáo sức chứa và tỉ lệ lấp đầy) và suất chiếu đã xoá? | Hậu điều kiện; Mục 8; thao tác nguyên tử Lưu phòng chiếu (trạng thái ghế của suất chiếu); UC-015, UC-016, UC-007; P13 seat, seat_status | REQ-58 và REQ-162 chỉ nêu khi nào không được sửa, không nêu suất chiếu nào dùng sơ đồ mới; REQ-153 tính tỉ lệ lấp đầy theo sức chứa của phòng chiếu |
| Q-211 | Đã trả lời (Theo đề xuất: Có: sức chứa (ghế đôi tính một ghế, BR-06) phải từ 50 đến 400 ghế, ngoài khoảng thì bị từ chối khi lưu). Sức chứa từ 50 đến 400 ghế của phòng chiếu (REQ-03) có là điều kiện bắt buộc khi lưu sơ đồ ghế không? | Dữ liệu vào 1 (trường 4), bước 4, luồng 4a (hoặc luồng 4b mới); BR-06 | REQ-03 nằm trong đoạn mở đầu như số liệu quy mô, P02 chuyển P06, không nêu là điều kiện hợp lệ |
| Q-212 | Đã trả lời (Theo đề xuất: Không phải giới hạn cứng: là số liệu quy mô; cụm rạp mới bắt đầu với 0 phòng và hệ thống không chặn số phòng). Số phòng chiếu của một cụm rạp từ 4 đến 12 (REQ-01) có là giới hạn bắt buộc khi thêm phòng chiếu không? | Bước 4, luồng 4a (hoặc luồng 4b mới); UC-011 (cụm rạp mới chưa có phòng) | REQ-01 nằm trong đoạn mở đầu như số liệu quy mô, P02 chuyển P06, không nêu là giới hạn |
| Q-213 | Đã trả lời (Theo đề xuất: Duy nhất trong cùng một cụm rạp (vé ghi tên phòng, hai phòng cùng tên trong một cụm gây nhầm khi bán vé và soát vé); khác cụm được trùng). Tên phòng chiếu có phải là duy nhất trong cùng một cụm rạp không? | Dữ liệu vào 1 (trường 1), bước 4, luồng 4a (hoặc luồng 4b mới); P13 bảng auditorium | REQ-56, REQ-57 và REQ-105 không nêu điều kiện duy nhất của tên phòng |
| Q-214 | Đã trả lời (Theo đề xuất: Yêu cầu lưu sau bị từ chối, không ghi đè thay đổi trước, quản lý cụm rạp mở lại phòng từ đầu (như BR-60, BR-63)). Hai yêu cầu cùng sửa một phòng chiếu (của hai quản lý cụm rạp hoặc hai phiên làm việc của cùng một người), hoặc một yêu cầu lưu khi phòng đã bị yêu cầu kia sửa kể từ lúc hiển thị: xử lý thế nào? | Bước 5, luồng 1a (thêm luồng 5c); thao tác nguyên tử Lưu phòng chiếu | Nguồn chỉ nêu xử lý đồng thời cho suất chiếu (Mục 16) và bảng giá (Mục 15), không nêu cho phòng chiếu |

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P08 | EX-15, X-19, X-21 | EX-15 là khung chờ P07 của UC-012; BR-136, BR-137, BR-118 và Q-209 làm thay đổi phạm vi (suất chiếu đã xoá, suất chiếu đã kết thúc, lớp chủ của EX-15) | Xác nhận lại EX-15 và cặp X-19, X-21 khi P07 của UC-012 hoàn tất |
| P13 | seat, seat_status, auditorium | BR-118 cần giữ sơ đồ ghế lịch sử của suất chiếu đã kết thúc trong khi khoá ngoại fk_seat_status_seat chặn xoá ghế; BR-145 đòi tên phòng duy nhất trong cụm rạp; BR-147 cho xoá phòng chưa từng có suất chiếu | Thêm ràng buộc duy nhất (cinema_id, name) cho auditorium, phương án giữ ghế lịch sử (xoá mềm ghế), và kiểm khoá ngoại khi xoá phòng |

## Vấn đề còn mở

- Luồng chính có 6 bước, trong khoảng 3-15; bước 5 gộp nhiều kiểm tra và việc lưu vì cùng là một thao tác không chia cắt (00-Concurrency.md M1 quy tắc 1).
- Bố cục activity diagram đã kiểm: không đường nối nào cắt qua node, không node nào chồng nhau.
