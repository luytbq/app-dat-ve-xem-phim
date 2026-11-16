# P11a - SCR-29 Lập hoặc sửa phòng chiếu (Create or edit auditorium) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 2.0; screen-list.md 2.0; screen-transition.md 2.0; P04 UC-012 1.2 (bước 3-6, luồng 1a3, 4a, 4b, 4d, 5a, 5b, 5c, *a, Dữ liệu vào 1, 1a, Dữ liệu ra 2, 3, BR-06, BR-73, BR-74, BR-87, BR-144, BR-145, BR-146); P05 GL-40, GL-50; P07 UC-012; P08-analysis-model.md 2.0 (F3); P10-design-elements.md 2.0 (F3, F4). Dải Q của phiên: Q-272 đến Q-281 (C10) |
| Phạm vi | SCR-29 |
| Mã Q, ASM cuối đã cấp | Q-276; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-29 |
| UC | UC-012 |
| Bước UC | 3, 4, 5, 6; luồng 1a3, 4a, 4b, 4d, 5a, 5b, 5c, *a |
| Tác nhân | ACT-04 Quản lý cụm rạp |
| Boundary AC | AC-B-ManageAuditoriumsForm (enterAuditoriumInfo, showAuditoriumForEdit, showSavedAuditorium, notifyRefusal, cancelRequest) |
| DC | DC-ManageAuditoriumsView |
| Loại màn hình | Con phụ thuộc (pop-up modal rộng) |
| Đến từ | SCR-28 (E-53) |
| Đi tới | Đóng ngầm định về SCR-28 |

## c) Hình ảnh màn hình

```text
+----------------------------------------------------------------+
| Thêm phòng chiếu                                      [ Đóng ]   |
|----------------------------------------------------------------|
| (vùng thông điệp: MSG-03, MSG-96, MSG-104 đến MSG-107, MSG-114)  |
| * là bắt buộc                                                    |
| Tên phòng chiếu *     [ Phòng 05                              ]  |
| Loại phòng *          [ IMAX v ]                                 |
| Định dạng chiếu được *  [x] 2D   [x] 3D                          |
| Sơ đồ ghế *                                                      |
|  Thêm hàng: Mã hàng [ C ] Số ghế [ 16 ] Loại [ Ghế thường v ]    |
|                                           [ Thêm hàng ]          |
|  Hàng C  [C1] [C2] [C3] ... [C7*] ... [C16]          [ Xoá hàng ] |
|  Hàng D  [D1] [D2] [D3] ... [D16]                    [ Xoá hàng ] |
|  Chú giải: [ ] thường  [V] VIP  [ĐĐ] đôi (92 px)  [-] lối đi      |
|  Sức chứa: 320 ghế (280 thường, 30 VIP, 10 đôi). Cần 50-400 ghế.  |
|                       [ Huỷ yêu cầu ]  [ Lưu phòng chiếu ]        |
+----------------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Tiêu đề | h2 trong hộp: "Thêm phòng chiếu" hoặc "Sửa phòng chiếu"; nút Đóng | Đầu hộp | UI-STT 09, 21, 50 |
| Thông điệp | MSG-03, MSG-96, MSG-104 đến MSG-107, MSG-114, MSG-72, MSG-73 | Dưới tiêu đề hộp | UI-STT 08 |
| Nội dung | Ba trường nhập, bộ thêm hàng, lưới sơ đồ ghế, chú giải, dòng sức chứa | Giữa hộp, cuộn trong hộp | UC-012 Dữ liệu vào 1, 1a; UI-STT 52 |
| Hành động | Huỷ yêu cầu, Lưu phòng chiếu | Cuối hộp, căn phải | UI-STT 06 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiện hộp modal. Thêm mới: tên, loại phòng, định dạng để trống, sơ đồ ghế rỗng. Sửa: mang thông tin hiện tại của phòng gồm từng ghế (hàng, số ghế, loại ghế) | UC-012 bước 3, luồng 1a3, Dữ liệu ra 3 |
| 2 | Ô Tên phòng chiếu | Ô nhập | Rời trường | Kiểm bắt buộc (MSG-03) | UC-012 Dữ liệu vào 1 STT 1 |
| 3 | Danh sách Loại phòng | Danh sách chọn | Chọn | Chọn Thường, 4DX hoặc IMAX | UC-012 Dữ liệu vào 1 STT 2; REQ-02 |
| 4 | Ô chọn 2D, 3D | Ô chọn | Chọn | Chọn một hoặc cả hai định dạng chiếu được. Không chọn ô nào khi nhấn Lưu: MSG-96 | UC-012 Dữ liệu vào 1 STT 3; REQ-55 |
| 5 | Ô Mã hàng, ô Số ghế, danh sách Loại ghế (bộ thêm hàng) | Ô nhập, danh sách chọn | Rời trường | Mã hàng tự chuyển chữ hoa, bắt buộc (MSG-03); số ghế là số nguyên từ 1 (MSG-03) | UC-012 Dữ liệu vào 1a STT 1-3; UI-STT 52 |
| 6 | Nút Thêm hàng | Nút phụ | Nhấn | Thêm một hàng gồm các ghế số 1 đến số ghế đã nhập, cùng loại ghế đã chọn. Mã hàng đã có trong sơ đồ: MSG-114, không thêm | UC-012 Dữ liệu vào 1a STT 2 (mỗi cặp hàng và số ghế tối đa một ghế); MSG-114; Q-273 |
| 7 | Ô ghế trong lưới | Nút | Nhấn | Mở danh sách Ghế thường, Ghế VIP, Ghế đôi, Bỏ ghế. Bỏ ghế để lại khoảng trống là lối đi; ghế bỏ đi vẫn giữ số của các ghế còn lại | UC-012 Dữ liệu vào 1a STT 2, 3; BR-74; UI-STT 52 |
| 8 | Nút Xoá hàng | Nút phụ | Nhấn | Bỏ cả hàng khỏi sơ đồ ghế đang soạn (chưa lưu) | UC-012 Dữ liệu vào 1a; UI-STT 52 |
| 9 | Dòng Sức chứa | Vùng hiển thị | Khởi tạo | Cập nhật ngay mỗi khi sơ đồ đổi: số ghế mỗi loại và tổng, ghế đôi tính một ghế. Là số tính nhanh; sức chứa chính thức do hệ thống tính khi lưu | UC-012 Dữ liệu ra 2; BR-06; UI-STT 52 |
| 10 | Nút Lưu phòng chiếu | Nút chính | Nhấn | Kiểm các trường theo UI-STT 19, gửi (nút bận theo UI-STT 27). Hệ thống từ chối ở lại hộp, giữ dữ liệu: sức chứa ngoài 50-400 MSG-104; tên trùng phòng khác trong cụm MSG-105; sơ đồ ghế đổi khi phòng có suất chiếu đã tới thời điểm mở bán mà chưa kết thúc MSG-106; đổi loại phòng hoặc loại ghế làm suất chiếu chưa bắt đầu thiếu giá MSG-107. Phòng đã bị người khác sửa MSG-108 rồi đóng hộp, tải lại SCR-28. Thành công: MSG-109, đóng hộp, làm mới SCR-28 | UC-012 bước 4-6, luồng 4a, 4b, 4d, 5a, 5b, 5c; BR-73, BR-87, BR-144, BR-145, BR-146; MSG-104 đến MSG-109 |
| 11 | Nút Huỷ yêu cầu, nút Đóng | Nút phụ | Nhấn | Đóng hộp không lưu, về SCR-28 và hiện MSG-57 | UC-012 luồng *a; MSG-57 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Tên phòng chiếu | 50 | Chữ | Nhập, bắt buộc, căn trái | Không để trống; không trùng tên phòng khác trong cùng cụm rạp (BR-145), phòng khác cụm được trùng | Độ dài theo Q-273 | UC-012 Dữ liệu vào 1 STT 1; BR-145; Q-273 |
| Loại phòng | - | Lựa chọn | Chọn, bắt buộc | Thường, 4DX hoặc IMAX | - | UC-012 Dữ liệu vào 1 STT 2; REQ-02 |
| Định dạng chiếu được | - | Lựa chọn | Chọn, bắt buộc | Một hoặc cả hai trong 2D, 3D | - | UC-012 Dữ liệu vào 1 STT 3; REQ-55 |
| Mã hàng | 3 | Chữ | Nhập, bắt buộc, căn trái | Không để trống; mỗi mã hàng một dòng trong sơ đồ | Độ dài theo Q-273; tự chuyển chữ hoa | UC-012 Dữ liệu vào 1a STT 1; Q-273 |
| Số ghế | 3 | Số | Nhập (bộ thêm hàng), bắt buộc, căn phải | Số nguyên từ 1; mỗi cặp hàng và số ghế tối đa một ghế | Ô nhập nêu số ghế cho cả hàng; độ dài theo Q-273 | UC-012 Dữ liệu vào 1a STT 2; Q-273 |
| Loại ghế | - | Lựa chọn | Chọn, bắt buộc | Ghế thường, ghế VIP hoặc ghế đôi; ghế đôi bán như một ghế (BR-74) | Mỗi ô ghế có biểu tượng và chữ theo loại | UC-012 Dữ liệu vào 1a STT 3; BR-74 |
| Sức chứa (tính nhanh) | 3 | Số | Hiển thị, căn phải | Số ghế của sơ đồ, ghế đôi tính một ghế; hợp lệ 50-400 (BR-144) | Không nhập | UC-012 Dữ liệu vào 1 STT 4; BR-06, BR-144 |

## f) Kiểm tra dữ liệu nhập

| Trường | Thời điểm kiểm tra | Kiểm tra | MSG khi lỗi |
|---|---|---|---|
| Tên phòng chiếu | Rời trường; nhấn Lưu | Bắt buộc --> không trùng tên phòng khác trong cụm (hệ thống) | MSG-03; MSG-105 |
| Loại phòng | Nhấn Lưu | Bắt buộc có giá trị | MSG-03 |
| Định dạng chiếu được | Nhấn Lưu | Ít nhất một định dạng | MSG-96 |
| Mã hàng, Số ghế | Nhấn Thêm hàng | Bắt buộc --> mã hàng chưa có trong sơ đồ | MSG-03; MSG-114 |
| Sơ đồ ghế | Nhấn Lưu | Sức chứa 50-400 --> (hệ thống) phòng không có suất chiếu đã mở bán mà chưa kết thúc --> không làm suất chiếu chưa bắt đầu thiếu giá --> phòng chưa bị sửa | MSG-104; MSG-106; MSG-107; MSG-108 |

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-29 | Nielsen 5 Ngăn lỗi | Đạt | Dòng sức chứa cập nhật ngay và nêu khoảng 50-400 trước khi lưu | - |
| SCR-29 | WCAG 2.1.1 Bàn phím | Đạt | Lưới ghế dùng phím mũi tên, Enter mở danh sách loại ghế (UI-STT 52) | - |
| SCR-29 | WCAG 1.4.1 Không dùng màu làm tín hiệu duy nhất | Đạt | Ba loại ghế khác biểu tượng, chữ và độ rộng ô (UI-STT 52) | - |
| SCR-29 | WCAG 2.5.8 Vùng bấm tối thiểu | Đạt | Ô ghế 44 x 44 px (UI-STT 52) | - |
| SCR-29 | WCAG 1.4.10 Reflow | Không áp dụng | Lưới ghế là nội dung hai chiều, cuộn trong hộp như UI-STT 39 | Ghi ở UI-STT 52 |
| SCR-29 | WCAG 2.4.3, 2.4.11 | Đạt | Tiêu điểm bị giữ trong hộp và trả về khi đóng (UI-STT 21, 50) | - |
| SCR-29 | Baymard: giữ dữ liệu khi lỗi | Đạt | Mọi từ chối nghiệp vụ giữ nguyên sơ đồ đang soạn (UI-STT 20, 29(5)) | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 17-21, 25, 27-31, 33-35.

## h) Thông điệp mới

Không có. MSG-104 đến MSG-109, MSG-114 cấp ở ui-standards.md.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-273.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Cách nhập sơ đồ ghế (thêm hàng rồi chỉnh từng ghế) là quyết định trình bày; đặc tả chỉ yêu cầu nhập danh sách ghế gồm hàng, số ghế, loại ghế. Phòng có tới 400 ghế nên lưới cuộn trong hộp.
